; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 7900  (per function: 312 461 461 81 81 357 412 412 279 279 81 365 430 585 1141 352 783 215 488 325)
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
     159:	je     20c <botlish_fn_1+0x10c>
     15f:	mov    QWORD PTR [rsp+0x10],rax
     164:	mov    r15,rax
     167:	mov    esi,0x1
     16c:	mov    r14,rsi
     16f:	mov    QWORD PTR [rsp+0x18],0x1
     178:	mov    rax,rsi
     17b:	and    rax,rbx
     17e:	mov    r14,rsi
     181:	test   rax,0x1
     187:	jne    1b0 <botlish_fn_1+0xb0>
     18d:	mov    rdx,rbx
     190:	mov    rsi,r14
     193:	mov    rdi,r13
     196:	call   19b <botlish_fn_1+0x9b>
			197: R_X86_64_PLT32	rt_int_cmp-0x4
     19b:	mov    ecx,0x2
     1a0:	test   rax,rax
     1a3:	cmovl  rcx,QWORD PTR [rip+0xe5]        # 290 <botlish_fn_1+0x190>
     1ab:	jmp    1c3 <botlish_fn_1+0xc3>
     1b0:	mov    ecx,0x2
     1b5:	mov    rsi,r14
     1b8:	cmp    rsi,rbx
     1bb:	cmovl  rcx,QWORD PTR [rip+0xcd]        # 290 <botlish_fn_1+0x190>
     1c3:	cmp    rcx,0x6
     1c7:	je     1f2 <botlish_fn_1+0xf2>
     1cd:	mov    rax,r15
     1d0:	mov    rbx,QWORD PTR [rsp+0x30]
     1d5:	mov    r12,QWORD PTR [rsp+0x38]
     1da:	mov    r13,QWORD PTR [rsp+0x40]
     1df:	mov    r14,QWORD PTR [rsp+0x48]
     1e4:	mov    r15,QWORD PTR [rsp+0x50]
     1e9:	add    rsp,0x60
     1ed:	mov    rsp,rbp
     1f0:	pop    rbp
     1f1:	ret
     1f2:	mov    rcx,r12
     1f5:	mov    rdx,r14
     1f8:	mov    rsi,r15
     1fb:	mov    rdi,r13
     1fe:	call   203 <botlish_fn_1+0x103>
			1ff: R_X86_64_PLT32	rt_mutarray_set-0x4
     203:	test   rax,rax
     206:	jne    231 <botlish_fn_1+0x131>
     20c:	xor    rax,rax
     20f:	mov    rbx,QWORD PTR [rsp+0x30]
     214:	mov    r12,QWORD PTR [rsp+0x38]
     219:	mov    r13,QWORD PTR [rsp+0x40]
     21e:	mov    r14,QWORD PTR [rsp+0x48]
     223:	mov    r15,QWORD PTR [rsp+0x50]
     228:	add    rsp,0x60
     22c:	mov    rsp,rbp
     22f:	pop    rbp
     230:	ret
     231:	mov    QWORD PTR [rsp+0x20],0x3
     23a:	mov    rsi,r14
     23d:	test   rsi,0x1
     244:	je     26a <botlish_fn_1+0x16a>
     24a:	mov    rsi,r14
     24d:	mov    rcx,rsi
     250:	add    rcx,0x2
     254:	seto   al
     257:	test   al,al
     259:	jne    26a <botlish_fn_1+0x16a>
     25f:	mov    rsi,rcx
     262:	mov    r14,rcx
     265:	jmp    280 <botlish_fn_1+0x180>
     26a:	mov    edx,0x3
     26f:	mov    rsi,r14
     272:	mov    rdi,r13
     275:	call   27a <botlish_fn_1+0x17a>
			276: R_X86_64_PLT32	rt_int_add-0x4
     27a:	mov    rsi,rax
     27d:	mov    r14,rax
     280:	mov    QWORD PTR [rsp+0x18],rsi
     285:	mov    rsi,r14
     288:	jmp    178 <botlish_fn_1+0x78>
     28d:	add    BYTE PTR [rax],al
     28f:	add    BYTE PTR [rsi],al
     291:	add    BYTE PTR [rax],al
     293:	add    BYTE PTR [rax],al
     295:	add    BYTE PTR [rax],al
	...

0000000000000298 <botlish_entry_1: mutable_array::create<int, str>>:
     298:	push   rbp
     299:	mov    rbp,rsp
     29c:	mov    rsi,QWORD PTR [rdx]
     29f:	mov    rdx,QWORD PTR [rdx+0x8]
     2a3:	call   2a8 <botlish_entry_1+0x10>
			2a4: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutable_array::create<int, str>
     2a8:	mov    rsp,rbp
     2ab:	pop    rbp
     2ac:	ret
     2ad:	add    BYTE PTR [rax],al
	...

00000000000002b0 <botlish_fn_2: mutable_array::create<int, List[str]>>:
     2b0:	push   rbp
     2b1:	mov    rbp,rsp
     2b4:	sub    rsp,0x60
     2b8:	mov    QWORD PTR [rsp+0x30],rbx
     2bd:	mov    QWORD PTR [rsp+0x38],r12
     2c2:	mov    QWORD PTR [rsp+0x40],r13
     2c7:	mov    QWORD PTR [rsp+0x48],r14
     2cc:	mov    QWORD PTR [rsp+0x50],r15
     2d1:	mov    r13,rdi
     2d4:	mov    QWORD PTR [rsp+0x10],0x0
     2dd:	mov    QWORD PTR [rsp+0x18],0x0
     2e6:	mov    QWORD PTR [rsp+0x20],0x0
     2ef:	mov    QWORD PTR [rsp],rsi
     2f3:	mov    QWORD PTR [rsp+0x8],rdx
     2f8:	mov    r12,rdx
     2fb:	mov    rbx,rsi
     2fe:	mov    rdi,r13
     301:	call   306 <botlish_fn_2+0x56>
			302: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     306:	test   rax,rax
     309:	je     3bc <botlish_fn_2+0x10c>
     30f:	mov    QWORD PTR [rsp+0x10],rax
     314:	mov    r15,rax
     317:	mov    esi,0x1
     31c:	mov    r14,rsi
     31f:	mov    QWORD PTR [rsp+0x18],0x1
     328:	mov    rax,rsi
     32b:	and    rax,rbx
     32e:	mov    r14,rsi
     331:	test   rax,0x1
     337:	jne    360 <botlish_fn_2+0xb0>
     33d:	mov    rdx,rbx
     340:	mov    rsi,r14
     343:	mov    rdi,r13
     346:	call   34b <botlish_fn_2+0x9b>
			347: R_X86_64_PLT32	rt_int_cmp-0x4
     34b:	mov    ecx,0x2
     350:	test   rax,rax
     353:	cmovl  rcx,QWORD PTR [rip+0xe5]        # 440 <botlish_fn_2+0x190>
     35b:	jmp    373 <botlish_fn_2+0xc3>
     360:	mov    ecx,0x2
     365:	mov    rsi,r14
     368:	cmp    rsi,rbx
     36b:	cmovl  rcx,QWORD PTR [rip+0xcd]        # 440 <botlish_fn_2+0x190>
     373:	cmp    rcx,0x6
     377:	je     3a2 <botlish_fn_2+0xf2>
     37d:	mov    rax,r15
     380:	mov    rbx,QWORD PTR [rsp+0x30]
     385:	mov    r12,QWORD PTR [rsp+0x38]
     38a:	mov    r13,QWORD PTR [rsp+0x40]
     38f:	mov    r14,QWORD PTR [rsp+0x48]
     394:	mov    r15,QWORD PTR [rsp+0x50]
     399:	add    rsp,0x60
     39d:	mov    rsp,rbp
     3a0:	pop    rbp
     3a1:	ret
     3a2:	mov    rcx,r12
     3a5:	mov    rdx,r14
     3a8:	mov    rsi,r15
     3ab:	mov    rdi,r13
     3ae:	call   3b3 <botlish_fn_2+0x103>
			3af: R_X86_64_PLT32	rt_mutarray_set-0x4
     3b3:	test   rax,rax
     3b6:	jne    3e1 <botlish_fn_2+0x131>
     3bc:	xor    rax,rax
     3bf:	mov    rbx,QWORD PTR [rsp+0x30]
     3c4:	mov    r12,QWORD PTR [rsp+0x38]
     3c9:	mov    r13,QWORD PTR [rsp+0x40]
     3ce:	mov    r14,QWORD PTR [rsp+0x48]
     3d3:	mov    r15,QWORD PTR [rsp+0x50]
     3d8:	add    rsp,0x60
     3dc:	mov    rsp,rbp
     3df:	pop    rbp
     3e0:	ret
     3e1:	mov    QWORD PTR [rsp+0x20],0x3
     3ea:	mov    rsi,r14
     3ed:	test   rsi,0x1
     3f4:	je     41a <botlish_fn_2+0x16a>
     3fa:	mov    rsi,r14
     3fd:	mov    rcx,rsi
     400:	add    rcx,0x2
     404:	seto   al
     407:	test   al,al
     409:	jne    41a <botlish_fn_2+0x16a>
     40f:	mov    rsi,rcx
     412:	mov    r14,rcx
     415:	jmp    430 <botlish_fn_2+0x180>
     41a:	mov    edx,0x3
     41f:	mov    rsi,r14
     422:	mov    rdi,r13
     425:	call   42a <botlish_fn_2+0x17a>
			426: R_X86_64_PLT32	rt_int_add-0x4
     42a:	mov    rsi,rax
     42d:	mov    r14,rax
     430:	mov    QWORD PTR [rsp+0x18],rsi
     435:	mov    rsi,r14
     438:	jmp    328 <botlish_fn_2+0x78>
     43d:	add    BYTE PTR [rax],al
     43f:	add    BYTE PTR [rsi],al
     441:	add    BYTE PTR [rax],al
     443:	add    BYTE PTR [rax],al
     445:	add    BYTE PTR [rax],al
	...

0000000000000448 <botlish_entry_2: mutable_array::create<int, List[str]>>:
     448:	push   rbp
     449:	mov    rbp,rsp
     44c:	mov    rsi,QWORD PTR [rdx]
     44f:	mov    rdx,QWORD PTR [rdx+0x8]
     453:	call   458 <botlish_entry_2+0x10>
			454: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutable_array::create<int, List[str]>
     458:	mov    rsp,rbp
     45b:	pop    rbp
     45c:	ret

000000000000045d <botlish_fn_3: geo_new<str>>:
     45d:	push   rbp
     45e:	mov    rbp,rsp
     461:	sub    rsp,0x10
     465:	mov    QWORD PTR [rsp],rsi
     469:	mov    rdx,rsi
     46c:	mov    esi,0x3
     471:	mov    QWORD PTR [rsp+0x8],0x3
     47a:	call   47f <botlish_fn_3+0x22>
			47b: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutable_array::create<int, str>
     47f:	test   rax,rax
     482:	jne    494 <botlish_fn_3+0x37>
     488:	xor    rax,rax
     48b:	add    rsp,0x10
     48f:	mov    rsp,rbp
     492:	pop    rbp
     493:	ret
     494:	add    rsp,0x10
     498:	mov    rsp,rbp
     49b:	pop    rbp
     49c:	ret

000000000000049d <botlish_entry_3: geo_new<str>>:
     49d:	push   rbp
     49e:	mov    rbp,rsp
     4a1:	mov    rsi,QWORD PTR [rdx]
     4a4:	call   4a9 <botlish_entry_3+0xc>
			4a5: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<str>
     4a9:	mov    rsp,rbp
     4ac:	pop    rbp
     4ad:	ret

00000000000004ae <botlish_fn_4: geo_new<List[str]>>:
     4ae:	push   rbp
     4af:	mov    rbp,rsp
     4b2:	sub    rsp,0x10
     4b6:	mov    QWORD PTR [rsp],rsi
     4ba:	mov    rdx,rsi
     4bd:	mov    esi,0x3
     4c2:	mov    QWORD PTR [rsp+0x8],0x3
     4cb:	call   4d0 <botlish_fn_4+0x22>
			4cc: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutable_array::create<int, List[str]>
     4d0:	test   rax,rax
     4d3:	jne    4e5 <botlish_fn_4+0x37>
     4d9:	xor    rax,rax
     4dc:	add    rsp,0x10
     4e0:	mov    rsp,rbp
     4e3:	pop    rbp
     4e4:	ret
     4e5:	add    rsp,0x10
     4e9:	mov    rsp,rbp
     4ec:	pop    rbp
     4ed:	ret

00000000000004ee <botlish_entry_4: geo_new<List[str]>>:
     4ee:	push   rbp
     4ef:	mov    rbp,rsp
     4f2:	mov    rsi,QWORD PTR [rdx]
     4f5:	call   4fa <botlish_entry_4+0xc>
			4f6: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<List[str]>
     4fa:	mov    rsp,rbp
     4fd:	pop    rbp
     4fe:	ret
	...

0000000000000500 <botlish_fn_5: geo_new_capacity<int, int>>:
     500:	push   rbp
     501:	mov    rbp,rsp
     504:	sub    rsp,0x40
     508:	mov    QWORD PTR [rsp+0x20],rbx
     50d:	mov    QWORD PTR [rsp+0x28],r12
     512:	mov    QWORD PTR [rsp+0x30],r13
     517:	mov    r12,rdi
     51a:	mov    QWORD PTR [rsp],rsi
     51e:	mov    QWORD PTR [rsp+0x8],rdx
     523:	mov    rbx,rdx
     526:	mov    QWORD PTR [rsp+0x10],0x5
     52f:	test   rsi,0x1
     536:	je     558 <botlish_fn_5+0x58>
     53c:	mov    rax,rsi
     53f:	sar    rax,1
     542:	imul   QWORD PTR [rip+0xdf]        # 628 <botlish_fn_5+0x128>
     549:	seto   cl
     54c:	or     rax,0x1
     550:	test   cl,cl
     552:	je     565 <botlish_fn_5+0x65>
     558:	mov    edx,0x5
     55d:	mov    rdi,r12
     560:	call   565 <botlish_fn_5+0x65>
			561: R_X86_64_PLT32	rt_int_mul-0x4
     565:	mov    rcx,rax
     568:	and    rcx,rbx
     56b:	mov    r13,rax
     56e:	test   rcx,0x1
     575:	jne    5a1 <botlish_fn_5+0xa1>
     57b:	mov    rdx,rbx
     57e:	mov    rsi,r13
     581:	mov    rdi,r12
     584:	call   589 <botlish_fn_5+0x89>
			585: R_X86_64_PLT32	rt_int_cmp-0x4
     589:	mov    ecx,0x2
     58e:	test   rax,rax
     591:	cmovle rcx,QWORD PTR [rip+0x97]        # 630 <botlish_fn_5+0x130>
     599:	mov    rax,r13
     59c:	jmp    5b4 <botlish_fn_5+0xb4>
     5a1:	mov    ecx,0x2
     5a6:	mov    rax,r13
     5a9:	cmp    rax,rbx
     5ac:	cmovle rcx,QWORD PTR [rip+0x7c]        # 630 <botlish_fn_5+0x130>
     5b4:	cmp    rcx,0x6
     5b8:	je     5d6 <botlish_fn_5+0xd6>
     5be:	mov    rbx,QWORD PTR [rsp+0x20]
     5c3:	mov    r12,QWORD PTR [rsp+0x28]
     5c8:	mov    r13,QWORD PTR [rsp+0x30]
     5cd:	add    rsp,0x40
     5d1:	mov    rsp,rbp
     5d4:	pop    rbp
     5d5:	ret
     5d6:	mov    QWORD PTR [rsp],0x3
     5de:	test   rbx,0x1
     5e5:	je     5fd <botlish_fn_5+0xfd>
     5eb:	mov    rax,rbx
     5ee:	add    rax,0x2
     5f2:	seto   cl
     5f5:	test   cl,cl
     5f7:	je     60d <botlish_fn_5+0x10d>
     5fd:	mov    edx,0x3
     602:	mov    rsi,rbx
     605:	mov    rdi,r12
     608:	call   60d <botlish_fn_5+0x10d>
			609: R_X86_64_PLT32	rt_int_add-0x4
     60d:	mov    rbx,QWORD PTR [rsp+0x20]
     612:	mov    r12,QWORD PTR [rsp+0x28]
     617:	mov    r13,QWORD PTR [rsp+0x30]
     61c:	add    rsp,0x40
     620:	mov    rsp,rbp
     623:	pop    rbp
     624:	ret
     625:	add    BYTE PTR [rax],al
     627:	add    BYTE PTR [rax+rax*1],al
     62a:	add    BYTE PTR [rax],al
     62c:	add    BYTE PTR [rax],al
     62e:	add    BYTE PTR [rax],al
     630:	(bad)
     631:	add    BYTE PTR [rax],al
     633:	add    BYTE PTR [rax],al
     635:	add    BYTE PTR [rax],al
	...

0000000000000638 <botlish_entry_5: geo_new_capacity<int, int>>:
     638:	push   rbp
     639:	mov    rbp,rsp
     63c:	mov    rsi,QWORD PTR [rdx]
     63f:	mov    rdx,QWORD PTR [rdx+0x8]
     643:	call   648 <botlish_entry_5+0x10>
			644: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new_capacity<int, int>
     648:	mov    rsp,rbp
     64b:	pop    rbp
     64c:	ret
     64d:	add    BYTE PTR [rax],al
	...

0000000000000650 <botlish_fn_6: geo_grow<mutarray, int, str>>:
     650:	push   rbp
     651:	mov    rbp,rsp
     654:	sub    rsp,0x50
     658:	mov    QWORD PTR [rsp+0x20],rbx
     65d:	mov    QWORD PTR [rsp+0x28],r12
     662:	mov    QWORD PTR [rsp+0x30],r13
     667:	mov    QWORD PTR [rsp+0x38],r14
     66c:	mov    QWORD PTR [rsp+0x40],r15
     671:	mov    r13,rdi
     674:	mov    QWORD PTR [rsp],rsi
     678:	mov    r12,rsi
     67b:	mov    QWORD PTR [rsp+0x8],rdx
     680:	mov    rbx,rdx
     683:	mov    QWORD PTR [rsp+0x10],rcx
     688:	mov    r14,rcx
     68b:	mov    rsi,r12
     68e:	mov    rdi,r13
     691:	call   696 <botlish_fn_6+0x46>
			692: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     696:	mov    r15,rax
     699:	mov    QWORD PTR [rsp+0x18],rax
     69e:	mov    rcx,rbx
     6a1:	and    rcx,rax
     6a4:	test   rcx,0x1
     6ab:	jne    6d7 <botlish_fn_6+0x87>
     6b1:	mov    rdx,r15
     6b4:	mov    rsi,rbx
     6b7:	mov    rdi,r13
     6ba:	call   6bf <botlish_fn_6+0x6f>
			6bb: R_X86_64_PLT32	rt_int_cmp-0x4
     6bf:	mov    ecx,0x2
     6c4:	test   rax,rax
     6c7:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 7b8 <botlish_fn_6+0x168>
     6cf:	mov    rax,r15
     6d2:	jmp    6ea <botlish_fn_6+0x9a>
     6d7:	mov    ecx,0x2
     6dc:	mov    rax,r15
     6df:	cmp    rbx,rax
     6e2:	cmovl  rcx,QWORD PTR [rip+0xce]        # 7b8 <botlish_fn_6+0x168>
     6ea:	cmp    rcx,0x6
     6ee:	je     78e <botlish_fn_6+0x13e>
     6f4:	mov    rsi,rax
     6f7:	mov    rdx,rbx
     6fa:	mov    rdi,r13
     6fd:	call   702 <botlish_fn_6+0xb2>
			6fe: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new_capacity<int, int>
     702:	mov    QWORD PTR [rsp+0x18],rax
     707:	mov    rdx,r14
     70a:	mov    rsi,rax
     70d:	mov    rdi,r13
     710:	call   715 <botlish_fn_6+0xc5>
			711: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutable_array::create<int, str>
     715:	test   rax,rax
     718:	mov    r14,rax
     71b:	je     744 <botlish_fn_6+0xf4>
     721:	mov    r8d,0x1
     727:	mov    rcx,r12
     72a:	mov    rdi,r13
     72d:	mov    r9,rbx
     730:	mov    rsi,r14
     733:	mov    rdx,r8
     736:	call   73b <botlish_fn_6+0xeb>
			737: R_X86_64_PLT32	rt_mutarray_copy-0x4
     73b:	test   rax,rax
     73e:	jne    769 <botlish_fn_6+0x119>
     744:	xor    rax,rax
     747:	mov    rbx,QWORD PTR [rsp+0x20]
     74c:	mov    r12,QWORD PTR [rsp+0x28]
     751:	mov    r13,QWORD PTR [rsp+0x30]
     756:	mov    r14,QWORD PTR [rsp+0x38]
     75b:	mov    r15,QWORD PTR [rsp+0x40]
     760:	add    rsp,0x50
     764:	mov    rsp,rbp
     767:	pop    rbp
     768:	ret
     769:	mov    rax,r14
     76c:	mov    rbx,QWORD PTR [rsp+0x20]
     771:	mov    r12,QWORD PTR [rsp+0x28]
     776:	mov    r13,QWORD PTR [rsp+0x30]
     77b:	mov    r14,QWORD PTR [rsp+0x38]
     780:	mov    r15,QWORD PTR [rsp+0x40]
     785:	add    rsp,0x50
     789:	mov    rsp,rbp
     78c:	pop    rbp
     78d:	ret
     78e:	mov    rax,r12
     791:	mov    rbx,QWORD PTR [rsp+0x20]
     796:	mov    r12,QWORD PTR [rsp+0x28]
     79b:	mov    r13,QWORD PTR [rsp+0x30]
     7a0:	mov    r14,QWORD PTR [rsp+0x38]
     7a5:	mov    r15,QWORD PTR [rsp+0x40]
     7aa:	add    rsp,0x50
     7ae:	mov    rsp,rbp
     7b1:	pop    rbp
     7b2:	ret
     7b3:	add    BYTE PTR [rax],al
     7b5:	add    BYTE PTR [rax],al
     7b7:	add    BYTE PTR [rsi],al
     7b9:	add    BYTE PTR [rax],al
     7bb:	add    BYTE PTR [rax],al
     7bd:	add    BYTE PTR [rax],al
	...

00000000000007c0 <botlish_entry_6: geo_grow<mutarray, int, str>>:
     7c0:	push   rbp
     7c1:	mov    rbp,rsp
     7c4:	mov    rsi,QWORD PTR [rdx]
     7c7:	mov    r8,QWORD PTR [rdx+0x8]
     7cb:	mov    rcx,QWORD PTR [rdx+0x10]
     7cf:	mov    rdx,r8
     7d2:	call   7d7 <botlish_entry_6+0x17>
			7d3: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_grow<mutarray, int, str>
     7d7:	mov    rsp,rbp
     7da:	pop    rbp
     7db:	ret
     7dc:	add    BYTE PTR [rax],al
	...

00000000000007e0 <botlish_fn_7: geo_grow<mutarray, int, List[str]>>:
     7e0:	push   rbp
     7e1:	mov    rbp,rsp
     7e4:	sub    rsp,0x50
     7e8:	mov    QWORD PTR [rsp+0x20],rbx
     7ed:	mov    QWORD PTR [rsp+0x28],r12
     7f2:	mov    QWORD PTR [rsp+0x30],r13
     7f7:	mov    QWORD PTR [rsp+0x38],r14
     7fc:	mov    QWORD PTR [rsp+0x40],r15
     801:	mov    r13,rdi
     804:	mov    QWORD PTR [rsp],rsi
     808:	mov    r12,rsi
     80b:	mov    QWORD PTR [rsp+0x8],rdx
     810:	mov    rbx,rdx
     813:	mov    QWORD PTR [rsp+0x10],rcx
     818:	mov    r14,rcx
     81b:	mov    rsi,r12
     81e:	mov    rdi,r13
     821:	call   826 <botlish_fn_7+0x46>
			822: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     826:	mov    r15,rax
     829:	mov    QWORD PTR [rsp+0x18],rax
     82e:	mov    rcx,rbx
     831:	and    rcx,rax
     834:	test   rcx,0x1
     83b:	jne    867 <botlish_fn_7+0x87>
     841:	mov    rdx,r15
     844:	mov    rsi,rbx
     847:	mov    rdi,r13
     84a:	call   84f <botlish_fn_7+0x6f>
			84b: R_X86_64_PLT32	rt_int_cmp-0x4
     84f:	mov    ecx,0x2
     854:	test   rax,rax
     857:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 948 <botlish_fn_7+0x168>
     85f:	mov    rax,r15
     862:	jmp    87a <botlish_fn_7+0x9a>
     867:	mov    ecx,0x2
     86c:	mov    rax,r15
     86f:	cmp    rbx,rax
     872:	cmovl  rcx,QWORD PTR [rip+0xce]        # 948 <botlish_fn_7+0x168>
     87a:	cmp    rcx,0x6
     87e:	je     91e <botlish_fn_7+0x13e>
     884:	mov    rsi,rax
     887:	mov    rdx,rbx
     88a:	mov    rdi,r13
     88d:	call   892 <botlish_fn_7+0xb2>
			88e: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new_capacity<int, int>
     892:	mov    QWORD PTR [rsp+0x18],rax
     897:	mov    rdx,r14
     89a:	mov    rsi,rax
     89d:	mov    rdi,r13
     8a0:	call   8a5 <botlish_fn_7+0xc5>
			8a1: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutable_array::create<int, List[str]>
     8a5:	test   rax,rax
     8a8:	mov    r14,rax
     8ab:	je     8d4 <botlish_fn_7+0xf4>
     8b1:	mov    r8d,0x1
     8b7:	mov    rcx,r12
     8ba:	mov    rdi,r13
     8bd:	mov    r9,rbx
     8c0:	mov    rsi,r14
     8c3:	mov    rdx,r8
     8c6:	call   8cb <botlish_fn_7+0xeb>
			8c7: R_X86_64_PLT32	rt_mutarray_copy-0x4
     8cb:	test   rax,rax
     8ce:	jne    8f9 <botlish_fn_7+0x119>
     8d4:	xor    rax,rax
     8d7:	mov    rbx,QWORD PTR [rsp+0x20]
     8dc:	mov    r12,QWORD PTR [rsp+0x28]
     8e1:	mov    r13,QWORD PTR [rsp+0x30]
     8e6:	mov    r14,QWORD PTR [rsp+0x38]
     8eb:	mov    r15,QWORD PTR [rsp+0x40]
     8f0:	add    rsp,0x50
     8f4:	mov    rsp,rbp
     8f7:	pop    rbp
     8f8:	ret
     8f9:	mov    rax,r14
     8fc:	mov    rbx,QWORD PTR [rsp+0x20]
     901:	mov    r12,QWORD PTR [rsp+0x28]
     906:	mov    r13,QWORD PTR [rsp+0x30]
     90b:	mov    r14,QWORD PTR [rsp+0x38]
     910:	mov    r15,QWORD PTR [rsp+0x40]
     915:	add    rsp,0x50
     919:	mov    rsp,rbp
     91c:	pop    rbp
     91d:	ret
     91e:	mov    rax,r12
     921:	mov    rbx,QWORD PTR [rsp+0x20]
     926:	mov    r12,QWORD PTR [rsp+0x28]
     92b:	mov    r13,QWORD PTR [rsp+0x30]
     930:	mov    r14,QWORD PTR [rsp+0x38]
     935:	mov    r15,QWORD PTR [rsp+0x40]
     93a:	add    rsp,0x50
     93e:	mov    rsp,rbp
     941:	pop    rbp
     942:	ret
     943:	add    BYTE PTR [rax],al
     945:	add    BYTE PTR [rax],al
     947:	add    BYTE PTR [rsi],al
     949:	add    BYTE PTR [rax],al
     94b:	add    BYTE PTR [rax],al
     94d:	add    BYTE PTR [rax],al
	...

0000000000000950 <botlish_entry_7: geo_grow<mutarray, int, List[str]>>:
     950:	push   rbp
     951:	mov    rbp,rsp
     954:	mov    rsi,QWORD PTR [rdx]
     957:	mov    r8,QWORD PTR [rdx+0x8]
     95b:	mov    rcx,QWORD PTR [rdx+0x10]
     95f:	mov    rdx,r8
     962:	call   967 <botlish_entry_7+0x17>
			963: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_grow<mutarray, int, List[str]>
     967:	mov    rsp,rbp
     96a:	pop    rbp
     96b:	ret

000000000000096c <botlish_fn_8: geo_append<mutarray, int, str>>:
     96c:	push   rbp
     96d:	mov    rbp,rsp
     970:	sub    rsp,0x40
     974:	mov    QWORD PTR [rsp+0x20],rbx
     979:	mov    QWORD PTR [rsp+0x28],r12
     97e:	mov    QWORD PTR [rsp+0x30],r13
     983:	mov    QWORD PTR [rsp+0x38],r14
     988:	mov    rbx,rdi
     98b:	mov    QWORD PTR [rsp],rsi
     98f:	mov    QWORD PTR [rsp+0x8],rdx
     994:	mov    r14,rdx
     997:	mov    QWORD PTR [rsp+0x10],rcx
     99c:	mov    r13,rcx
     99f:	mov    rcx,r13
     9a2:	mov    rdx,r14
     9a5:	mov    rdi,rbx
     9a8:	call   9ad <botlish_fn_8+0x41>
			9a9: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_grow<mutarray, int, str>
     9ad:	test   rax,rax
     9b0:	je     a19 <botlish_fn_8+0xad>
     9b6:	xor    ecx,ecx
     9b8:	test   rax,0x7
     9be:	je     9cc <botlish_fn_8+0x60>
     9c4:	mov    r12,rax
     9c7:	jmp    9da <botlish_fn_8+0x6e>
     9cc:	movzx  rcx,BYTE PTR [rax]
     9d0:	mov    r12,rax
     9d3:	rex cmp cl,0x8
     9d7:	sete   cl
     9da:	test   cl,cl
     9dc:	jne    9ff <botlish_fn_8+0x93>
     9e2:	mov    rdi,rbx
     9e5:	mov    rax,QWORD PTR [rdi+0x10]
     9e9:	mov    rcx,QWORD PTR [rax+0x8]
     9ed:	mov    edx,0x8
     9f2:	mov    rsi,r12
     9f5:	call   9fa <botlish_fn_8+0x8e>
			9f6: R_X86_64_PLT32	rt_type_error-0x4
     9fa:	jmp    a19 <botlish_fn_8+0xad>
     9ff:	mov    rcx,r13
     a02:	mov    rdx,r14
     a05:	mov    rdi,rbx
     a08:	mov    rsi,r12
     a0b:	call   a10 <botlish_fn_8+0xa4>
			a0c: R_X86_64_PLT32	rt_mutarray_set-0x4
     a10:	test   rax,rax
     a13:	jne    a39 <botlish_fn_8+0xcd>
     a19:	xor    rax,rax
     a1c:	mov    rbx,QWORD PTR [rsp+0x20]
     a21:	mov    r12,QWORD PTR [rsp+0x28]
     a26:	mov    r13,QWORD PTR [rsp+0x30]
     a2b:	mov    r14,QWORD PTR [rsp+0x38]
     a30:	add    rsp,0x40
     a34:	mov    rsp,rbp
     a37:	pop    rbp
     a38:	ret
     a39:	mov    rax,r12
     a3c:	mov    rbx,QWORD PTR [rsp+0x20]
     a41:	mov    r12,QWORD PTR [rsp+0x28]
     a46:	mov    r13,QWORD PTR [rsp+0x30]
     a4b:	mov    r14,QWORD PTR [rsp+0x38]
     a50:	add    rsp,0x40
     a54:	mov    rsp,rbp
     a57:	pop    rbp
     a58:	ret

0000000000000a59 <botlish_entry_8: geo_append<mutarray, int, str>>:
     a59:	push   rbp
     a5a:	mov    rbp,rsp
     a5d:	mov    rsi,QWORD PTR [rdx]
     a60:	mov    r8,QWORD PTR [rdx+0x8]
     a64:	mov    rcx,QWORD PTR [rdx+0x10]
     a68:	mov    rdx,r8
     a6b:	call   a70 <botlish_entry_8+0x17>
			a6c: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
     a70:	mov    rsp,rbp
     a73:	pop    rbp
     a74:	ret

0000000000000a75 <botlish_fn_9: geo_append<mutarray, int, List[str]>>:
     a75:	push   rbp
     a76:	mov    rbp,rsp
     a79:	sub    rsp,0x40
     a7d:	mov    QWORD PTR [rsp+0x20],rbx
     a82:	mov    QWORD PTR [rsp+0x28],r12
     a87:	mov    QWORD PTR [rsp+0x30],r13
     a8c:	mov    QWORD PTR [rsp+0x38],r14
     a91:	mov    rbx,rdi
     a94:	mov    QWORD PTR [rsp],rsi
     a98:	mov    QWORD PTR [rsp+0x8],rdx
     a9d:	mov    r14,rdx
     aa0:	mov    QWORD PTR [rsp+0x10],rcx
     aa5:	mov    r13,rcx
     aa8:	mov    rcx,r13
     aab:	mov    rdx,r14
     aae:	mov    rdi,rbx
     ab1:	call   ab6 <botlish_fn_9+0x41>
			ab2: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_grow<mutarray, int, List[str]>
     ab6:	test   rax,rax
     ab9:	je     b22 <botlish_fn_9+0xad>
     abf:	xor    ecx,ecx
     ac1:	test   rax,0x7
     ac7:	je     ad5 <botlish_fn_9+0x60>
     acd:	mov    r12,rax
     ad0:	jmp    ae3 <botlish_fn_9+0x6e>
     ad5:	movzx  rcx,BYTE PTR [rax]
     ad9:	mov    r12,rax
     adc:	rex cmp cl,0x8
     ae0:	sete   cl
     ae3:	test   cl,cl
     ae5:	jne    b08 <botlish_fn_9+0x93>
     aeb:	mov    rdi,rbx
     aee:	mov    rax,QWORD PTR [rdi+0x10]
     af2:	mov    rcx,QWORD PTR [rax+0x8]
     af6:	mov    edx,0x8
     afb:	mov    rsi,r12
     afe:	call   b03 <botlish_fn_9+0x8e>
			aff: R_X86_64_PLT32	rt_type_error-0x4
     b03:	jmp    b22 <botlish_fn_9+0xad>
     b08:	mov    rcx,r13
     b0b:	mov    rdx,r14
     b0e:	mov    rdi,rbx
     b11:	mov    rsi,r12
     b14:	call   b19 <botlish_fn_9+0xa4>
			b15: R_X86_64_PLT32	rt_mutarray_set-0x4
     b19:	test   rax,rax
     b1c:	jne    b42 <botlish_fn_9+0xcd>
     b22:	xor    rax,rax
     b25:	mov    rbx,QWORD PTR [rsp+0x20]
     b2a:	mov    r12,QWORD PTR [rsp+0x28]
     b2f:	mov    r13,QWORD PTR [rsp+0x30]
     b34:	mov    r14,QWORD PTR [rsp+0x38]
     b39:	add    rsp,0x40
     b3d:	mov    rsp,rbp
     b40:	pop    rbp
     b41:	ret
     b42:	mov    rax,r12
     b45:	mov    rbx,QWORD PTR [rsp+0x20]
     b4a:	mov    r12,QWORD PTR [rsp+0x28]
     b4f:	mov    r13,QWORD PTR [rsp+0x30]
     b54:	mov    r14,QWORD PTR [rsp+0x38]
     b59:	add    rsp,0x40
     b5d:	mov    rsp,rbp
     b60:	pop    rbp
     b61:	ret

0000000000000b62 <botlish_entry_9: geo_append<mutarray, int, List[str]>>:
     b62:	push   rbp
     b63:	mov    rbp,rsp
     b66:	mov    rsi,QWORD PTR [rdx]
     b69:	mov    r8,QWORD PTR [rdx+0x8]
     b6d:	mov    rcx,QWORD PTR [rdx+0x10]
     b71:	mov    rdx,r8
     b74:	call   b79 <botlish_entry_9+0x17>
			b75: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
     b79:	mov    rsp,rbp
     b7c:	pop    rbp
     b7d:	ret

0000000000000b7e <botlish_fn_10: geo_finish<mutarray, int>>:
     b7e:	push   rbp
     b7f:	mov    rbp,rsp
     b82:	sub    rsp,0x10
     b86:	mov    QWORD PTR [rsp],rsi
     b8a:	mov    QWORD PTR [rsp+0x8],rdx
     b8f:	call   b94 <botlish_fn_10+0x16>
			b90: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     b94:	test   rax,rax
     b97:	jne    ba9 <botlish_fn_10+0x2b>
     b9d:	xor    rax,rax
     ba0:	add    rsp,0x10
     ba4:	mov    rsp,rbp
     ba7:	pop    rbp
     ba8:	ret
     ba9:	add    rsp,0x10
     bad:	mov    rsp,rbp
     bb0:	pop    rbp
     bb1:	ret

0000000000000bb2 <botlish_entry_10: geo_finish<mutarray, int>>:
     bb2:	push   rbp
     bb3:	mov    rbp,rsp
     bb6:	mov    rsi,QWORD PTR [rdx]
     bb9:	mov    rdx,QWORD PTR [rdx+0x8]
     bbd:	call   bc2 <botlish_entry_10+0x10>
			bbe: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
     bc2:	mov    rsp,rbp
     bc5:	pop    rbp
     bc6:	ret
	...

0000000000000bc8 <botlish_fn_11: peek<str, int>>:
     bc8:	push   rbp
     bc9:	mov    rbp,rsp
     bcc:	sub    rsp,0x40
     bd0:	mov    QWORD PTR [rsp+0x20],rbx
     bd5:	mov    QWORD PTR [rsp+0x28],r12
     bda:	mov    QWORD PTR [rsp+0x30],r13
     bdf:	mov    r13,rdi
     be2:	mov    QWORD PTR [rsp],rsi
     be6:	mov    r12,rsi
     be9:	mov    QWORD PTR [rsp+0x8],rdx
     bee:	mov    rbx,rdx
     bf1:	mov    rsi,r12
     bf4:	mov    rdi,r13
     bf7:	call   bfc <botlish_fn_11+0x34>
			bf8: R_X86_64_PLT32	rt_str_len-0x4
     bfc:	mov    rcx,rbx
     bff:	and    rcx,rax
     c02:	mov    rdx,rax
     c05:	test   rcx,0x1
     c0c:	jne    c32 <botlish_fn_11+0x6a>
     c12:	mov    rsi,rbx
     c15:	mov    rdi,r13
     c18:	call   c1d <botlish_fn_11+0x55>
			c19: R_X86_64_PLT32	rt_int_cmp-0x4
     c1d:	mov    ecx,0x2
     c22:	test   rax,rax
     c25:	cmovge rcx,QWORD PTR [rip+0xd3]        # d00 <botlish_fn_11+0x138>
     c2d:	jmp    c42 <botlish_fn_11+0x7a>
     c32:	mov    ecx,0x2
     c37:	cmp    rbx,rdx
     c3a:	cmovge rcx,QWORD PTR [rip+0xbe]        # d00 <botlish_fn_11+0x138>
     c42:	cmp    rcx,0x6
     c46:	je     cd6 <botlish_fn_11+0x10e>
     c4c:	mov    QWORD PTR [rsp+0x10],0x3
     c55:	test   rbx,0x1
     c5c:	je     c74 <botlish_fn_11+0xac>
     c62:	mov    rcx,rbx
     c65:	add    rcx,0x2
     c69:	seto   al
     c6c:	test   al,al
     c6e:	je     c87 <botlish_fn_11+0xbf>
     c74:	mov    edx,0x3
     c79:	mov    rsi,rbx
     c7c:	mov    rdi,r13
     c7f:	call   c84 <botlish_fn_11+0xbc>
			c80: R_X86_64_PLT32	rt_int_add-0x4
     c84:	mov    rcx,rax
     c87:	mov    QWORD PTR [rsp+0x10],rcx
     c8c:	mov    rdx,rbx
     c8f:	mov    rsi,r12
     c92:	mov    rdi,r13
     c95:	call   c9a <botlish_fn_11+0xd2>
			c96: R_X86_64_PLT32	rt_substr-0x4
     c9a:	test   rax,rax
     c9d:	jne    cbe <botlish_fn_11+0xf6>
     ca3:	xor    rax,rax
     ca6:	mov    rbx,QWORD PTR [rsp+0x20]
     cab:	mov    r12,QWORD PTR [rsp+0x28]
     cb0:	mov    r13,QWORD PTR [rsp+0x30]
     cb5:	add    rsp,0x40
     cb9:	mov    rsp,rbp
     cbc:	pop    rbp
     cbd:	ret
     cbe:	mov    rbx,QWORD PTR [rsp+0x20]
     cc3:	mov    r12,QWORD PTR [rsp+0x28]
     cc8:	mov    r13,QWORD PTR [rsp+0x30]
     ccd:	add    rsp,0x40
     cd1:	mov    rsp,rbp
     cd4:	pop    rbp
     cd5:	ret
     cd6:	mov    rdi,r13
     cd9:	mov    rax,QWORD PTR [rdi+0x10]
     cdd:	mov    rax,QWORD PTR [rax+0x10]
     ce1:	mov    rbx,QWORD PTR [rsp+0x20]
     ce6:	mov    r12,QWORD PTR [rsp+0x28]
     ceb:	mov    r13,QWORD PTR [rsp+0x30]
     cf0:	add    rsp,0x40
     cf4:	mov    rsp,rbp
     cf7:	pop    rbp
     cf8:	ret
     cf9:	add    BYTE PTR [rax],al
     cfb:	add    BYTE PTR [rax],al
     cfd:	add    BYTE PTR [rax],al
     cff:	add    BYTE PTR [rsi],al
     d01:	add    BYTE PTR [rax],al
     d03:	add    BYTE PTR [rax],al
     d05:	add    BYTE PTR [rax],al
	...

0000000000000d08 <botlish_entry_11: peek<str, int>>:
     d08:	push   rbp
     d09:	mov    rbp,rsp
     d0c:	mov    rsi,QWORD PTR [rdx]
     d0f:	mov    rdx,QWORD PTR [rdx+0x8]
     d13:	call   d18 <botlish_entry_11+0x10>
			d14: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
     d18:	mov    rsp,rbp
     d1b:	pop    rbp
     d1c:	ret
     d1d:	add    BYTE PTR [rax],al
	...

0000000000000d20 <botlish_fn_12: peek<str, int>>:
     d20:	push   rbp
     d21:	mov    rbp,rsp
     d24:	sub    rsp,0x50
     d28:	mov    QWORD PTR [rsp+0x20],rbx
     d2d:	mov    QWORD PTR [rsp+0x28],r12
     d32:	mov    QWORD PTR [rsp+0x30],r13
     d37:	mov    QWORD PTR [rsp+0x38],r14
     d3c:	mov    QWORD PTR [rsp+0x40],r15
     d41:	mov    r12,rcx
     d44:	mov    r14,rdi
     d47:	mov    QWORD PTR [rsp],rsi
     d4b:	mov    r13,rsi
     d4e:	mov    QWORD PTR [rsp+0x8],rdx
     d53:	mov    rbx,rdx
     d56:	mov    rsi,r13
     d59:	mov    rdi,r14
     d5c:	call   d61 <botlish_fn_12+0x41>
			d5d: R_X86_64_PLT32	rt_str_len-0x4
     d61:	mov    rcx,rbx
     d64:	and    rcx,rax
     d67:	mov    rdx,rax
     d6a:	test   rcx,0x1
     d71:	jne    d97 <botlish_fn_12+0x77>
     d77:	mov    rsi,rbx
     d7a:	mov    rdi,r14
     d7d:	call   d82 <botlish_fn_12+0x62>
			d7e: R_X86_64_PLT32	rt_int_cmp-0x4
     d82:	mov    ecx,0x2
     d87:	test   rax,rax
     d8a:	cmovge rcx,QWORD PTR [rip+0x11e]        # eb0 <botlish_fn_12+0x190>
     d92:	jmp    da7 <botlish_fn_12+0x87>
     d97:	mov    ecx,0x2
     d9c:	cmp    rbx,rdx
     d9f:	cmovge rcx,QWORD PTR [rip+0x109]        # eb0 <botlish_fn_12+0x190>
     da7:	cmp    rcx,0x6
     dab:	je     e6b <botlish_fn_12+0x14b>
     db1:	mov    QWORD PTR [rsp+0x10],0x3
     dba:	test   rbx,0x1
     dc1:	je     de4 <botlish_fn_12+0xc4>
     dc7:	mov    rax,rbx
     dca:	add    rax,0x2
     dce:	seto   cl
     dd1:	test   cl,cl
     dd3:	jne    de4 <botlish_fn_12+0xc4>
     dd9:	mov    rdi,r14
     ddc:	mov    r15,rax
     ddf:	jmp    dfa <botlish_fn_12+0xda>
     de4:	mov    edx,0x3
     de9:	mov    rsi,rbx
     dec:	mov    rdi,r14
     def:	call   df4 <botlish_fn_12+0xd4>
			df0: R_X86_64_PLT32	rt_int_add-0x4
     df4:	mov    r15,rax
     df7:	mov    rdi,r14
     dfa:	mov    rdi,r14
     dfd:	mov    rcx,r15
     e00:	mov    rdx,rbx
     e03:	mov    rsi,r13
     e06:	call   e0b <botlish_fn_12+0xeb>
			e07: R_X86_64_PLT32	rt_str_region_check-0x4
     e0b:	test   rax,rax
     e0e:	jne    e39 <botlish_fn_12+0x119>
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
    1a76:	mov    r12,rdx
    1a79:	mov    QWORD PTR [rsp+0x10],rcx
    1a7e:	mov    QWORD PTR [rsp+0x18],r8
    1a83:	mov    rbx,rsi
    1a86:	mov    r14,r8
    1a89:	mov    r15,rcx
    1a8c:	mov    rsi,rbx
    1a8f:	mov    rdi,r13
    1a92:	call   1a97 <botlish_fn_18+0x57>
			1a93: R_X86_64_PLT32	rt_str_len-0x4
    1a97:	mov    rcx,r12
    1a9a:	and    rcx,rax
    1a9d:	mov    rdx,rax
    1aa0:	test   rcx,0x1
    1aa7:	jne    1acd <botlish_fn_18+0x8d>
    1aad:	mov    rsi,r12
    1ab0:	mov    rdi,r13
    1ab3:	call   1ab8 <botlish_fn_18+0x78>
			1ab4: R_X86_64_PLT32	rt_int_cmp-0x4
    1ab8:	mov    ecx,0x2
    1abd:	test   rax,rax
    1ac0:	cmovge rcx,QWORD PTR [rip+0x128]        # 1bf0 <botlish_fn_18+0x1b0>
    1ac8:	jmp    1add <botlish_fn_18+0x9d>
    1acd:	mov    ecx,0x2
    1ad2:	cmp    r12,rdx
    1ad5:	cmovge rcx,QWORD PTR [rip+0x113]        # 1bf0 <botlish_fn_18+0x1b0>
    1add:	cmp    rcx,0x6
    1ae1:	je     1b8c <botlish_fn_18+0x14c>
    1ae7:	mov    rdx,r12
    1aea:	mov    rsi,rbx
    1aed:	mov    rdi,r13
    1af0:	call   1af5 <botlish_fn_18+0xb5>
			1af1: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int>
    1af5:	test   rax,rax
    1af8:	je     1ba3 <botlish_fn_18+0x163>
    1afe:	mov    QWORD PTR [rsp+0x8],rax
    1b03:	mov    rcx,rax
    1b06:	mov    QWORD PTR [rsp+0x20],rdx
    1b0b:	mov    rsi,r15
    1b0e:	mov    r12,rdx
    1b11:	mov    rdx,r14
    1b14:	mov    rdi,r13
    1b17:	call   1b1c <botlish_fn_18+0xdc>
			1b18: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
    1b1c:	test   rax,rax
    1b1f:	je     1ba3 <botlish_fn_18+0x163>
    1b25:	mov    QWORD PTR [rsp+0x8],rax
    1b2a:	mov    r15,rax
    1b2d:	mov    QWORD PTR [rsp+0x10],0x3
    1b36:	mov    rsi,r14
    1b39:	test   rsi,0x1
    1b40:	je     1b5b <botlish_fn_18+0x11b>
    1b46:	mov    rsi,r14
    1b49:	mov    rax,rsi
    1b4c:	add    rax,0x2
    1b50:	seto   cl
    1b53:	test   cl,cl
    1b55:	je     1b6b <botlish_fn_18+0x12b>
    1b5b:	mov    edx,0x3
    1b60:	mov    rsi,r14
    1b63:	mov    rdi,r13
    1b66:	call   1b6b <botlish_fn_18+0x12b>
			1b67: R_X86_64_PLT32	rt_int_add-0x4
    1b6b:	mov    QWORD PTR [rsp],rbx
    1b6f:	mov    rdx,r12
    1b72:	mov    QWORD PTR [rsp+0x8],rdx
    1b77:	mov    rcx,r15
    1b7a:	mov    QWORD PTR [rsp+0x10],rcx
    1b7f:	mov    QWORD PTR [rsp+0x18],rax
    1b84:	mov    r14,rax
    1b87:	jmp    1a8c <botlish_fn_18+0x4c>
    1b8c:	mov    rdx,r14
    1b8f:	mov    rsi,r15
    1b92:	mov    rdi,r13
    1b95:	call   1b9a <botlish_fn_18+0x15a>
			1b96: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    1b9a:	test   rax,rax
    1b9d:	jne    1bc8 <botlish_fn_18+0x188>
    1ba3:	xor    rax,rax
    1ba6:	mov    rbx,QWORD PTR [rsp+0x30]
    1bab:	mov    r12,QWORD PTR [rsp+0x38]
    1bb0:	mov    r13,QWORD PTR [rsp+0x40]
    1bb5:	mov    r14,QWORD PTR [rsp+0x48]
    1bba:	mov    r15,QWORD PTR [rsp+0x50]
    1bbf:	add    rsp,0x60
    1bc3:	mov    rsp,rbp
    1bc6:	pop    rbp
    1bc7:	ret
    1bc8:	mov    rbx,QWORD PTR [rsp+0x30]
    1bcd:	mov    r12,QWORD PTR [rsp+0x38]
    1bd2:	mov    r13,QWORD PTR [rsp+0x40]
    1bd7:	mov    r14,QWORD PTR [rsp+0x48]
    1bdc:	mov    r15,QWORD PTR [rsp+0x50]
    1be1:	add    rsp,0x60
    1be5:	mov    rsp,rbp
    1be8:	pop    rbp
    1be9:	ret
    1bea:	add    BYTE PTR [rax],al
    1bec:	add    BYTE PTR [rax],al
    1bee:	add    BYTE PTR [rax],al
    1bf0:	(bad)
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
    1c51:	mov    r12,rsi
    1c54:	mov    rsi,r12
    1c57:	mov    rdi,rbx
    1c5a:	call   1c5f <botlish_fn_19+0x47>
			1c5b: R_X86_64_PLT32	rt_str_len-0x4
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

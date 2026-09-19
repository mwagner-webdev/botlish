; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 6932  (per function: 169 168 437 517 396 396 171 453 502 677 887 470 837 584 268)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> geo_new<generic>
;   botlish_fn_2 / botlish_entry_2 -> geo_new_capacity<int, int>
;   botlish_fn_3 / botlish_entry_3 -> geo_grow<mutarray, int>
;   botlish_fn_4 / botlish_entry_4 -> geo_append<list[mutarray, int], str>
;   botlish_fn_5 / botlish_entry_5 -> geo_append<list[mutarray, int], list>
;   botlish_fn_6 / botlish_entry_6 -> geo_finish<list[mutarray, int]>
;   botlish_fn_7 / botlish_entry_7 -> peek<str, int>
;   botlish_fn_8 / botlish_entry_8 -> peek<str, int>
;   botlish_fn_9 / botlish_entry_9 -> scan_unquoted<str, int, int>
;   botlish_fn_10 / botlish_entry_10 -> scan_quoted<str, int, str>
;   botlish_fn_11 / botlish_entry_11 -> scan_field<str, int>
;   botlish_fn_12 / botlish_entry_12 -> scan_record<str, int, list[mutarray, int]>
;   botlish_fn_13 / botlish_entry_13 -> scan_records<str, int, list[mutarray, int]>
;   botlish_fn_14 / botlish_entry_14 -> csv_parse<str>


csv_geometric.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x10
       8:	mov    QWORD PTR [rsp],r13
       c:	mov    QWORD PTR [rsp+0x8],r14
      11:	mov    r13,QWORD PTR [rdi]
      14:	mov    rax,QWORD PTR [rdi+0x8]
      18:	lea    rcx,[r13+0x8]
      1c:	cmp    rcx,rax
      1f:	ja     7b <botlish_fn_0+0x7b>
      25:	lea    rax,[r13+0x8]
      29:	mov    QWORD PTR [rdi],rax
      2c:	mov    rax,QWORD PTR [rdi+0x10]
      30:	mov    r14,rdi
      33:	mov    rsi,QWORD PTR [rax]
      36:	mov    QWORD PTR [r13+0x0],rsi
      3a:	call   3f <botlish_fn_0+0x3f>
			3b: R_X86_64_PLT32	botlish_fn_14-0x4 ; csv_parse<str>
      3f:	test   rax,rax
      42:	jne    63 <botlish_fn_0+0x63>
      48:	mov    rdi,r14
      4b:	mov    QWORD PTR [rdi],r13
      4e:	xor    rax,rax
      51:	mov    r13,QWORD PTR [rsp]
      55:	mov    r14,QWORD PTR [rsp+0x8]
      5a:	add    rsp,0x10
      5e:	mov    rsp,rbp
      61:	pop    rbp
      62:	ret
      63:	mov    rdi,r14
      66:	mov    QWORD PTR [rdi],r13
      69:	mov    r13,QWORD PTR [rsp]
      6d:	mov    r14,QWORD PTR [rsp+0x8]
      72:	add    rsp,0x10
      76:	mov    rsp,rbp
      79:	pop    rbp
      7a:	ret
      7b:	call   80 <botlish_fn_0+0x80>
			7c: R_X86_64_PLT32	rt_stack_overflow-0x4
      80:	xor    rax,rax
      83:	mov    r13,QWORD PTR [rsp]
      87:	mov    r14,QWORD PTR [rsp+0x8]
      8c:	add    rsp,0x10
      90:	mov    rsp,rbp
      93:	pop    rbp
      94:	ret

0000000000000095 <botlish_entry_0: <program entry>>:
      95:	push   rbp
      96:	mov    rbp,rsp
      99:	call   9e <botlish_entry_0+0x9>
			9a: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      9e:	mov    rsp,rbp
      a1:	pop    rbp
      a2:	ret

00000000000000a3 <botlish_fn_1: geo_new<generic>>:
      a3:	push   rbp
      a4:	mov    rbp,rsp
      a7:	sub    rsp,0x30
      ab:	mov    QWORD PTR [rsp+0x10],rbx
      b0:	mov    QWORD PTR [rsp+0x18],r12
      b5:	mov    QWORD PTR [rsp+0x20],r13
      ba:	mov    r12,QWORD PTR [rdi+0x20]
      be:	mov    r13,QWORD PTR [rdi+0x28]
      c2:	lea    r9,[rsp]
      c6:	mov    QWORD PTR [rdi+0x20],r9
      ca:	mov    QWORD PTR [rdi+0x28],0x1
      d2:	mov    rbx,rdi
      d5:	mov    esi,0x1
      da:	mov    QWORD PTR [rsp],0x1
      e2:	mov    rdi,rbx
      e5:	call   ea <botlish_fn_1+0x47>
			e6: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      ea:	test   rax,rax
      ed:	jne    119 <botlish_fn_1+0x76>
      f3:	mov    QWORD PTR [rbx+0x20],r12
      f7:	mov    QWORD PTR [rbx+0x28],r13
      fb:	xor    rdx,rdx
      fe:	mov    rax,rdx
     101:	mov    rbx,QWORD PTR [rsp+0x10]
     106:	mov    r12,QWORD PTR [rsp+0x18]
     10b:	mov    r13,QWORD PTR [rsp+0x20]
     110:	add    rsp,0x30
     114:	mov    rsp,rbp
     117:	pop    rbp
     118:	ret
     119:	mov    QWORD PTR [rbx+0x20],r12
     11d:	mov    QWORD PTR [rbx+0x28],r13
     121:	mov    edx,0x1
     126:	mov    rbx,QWORD PTR [rsp+0x10]
     12b:	mov    r12,QWORD PTR [rsp+0x18]
     130:	mov    r13,QWORD PTR [rsp+0x20]
     135:	add    rsp,0x30
     139:	mov    rsp,rbp
     13c:	pop    rbp
     13d:	ret

000000000000013e <botlish_entry_1: geo_new<generic>>:
     13e:	push   rbp
     13f:	mov    rbp,rsp
     142:	ud2
     144:	add    BYTE PTR [rax],al
	...

0000000000000148 <botlish_fn_2: geo_new_capacity<int, int>>:
     148:	push   rbp
     149:	mov    rbp,rsp
     14c:	sub    rsp,0x50
     150:	mov    QWORD PTR [rsp+0x20],rbx
     155:	mov    QWORD PTR [rsp+0x28],r12
     15a:	mov    QWORD PTR [rsp+0x30],r13
     15f:	mov    QWORD PTR [rsp+0x38],r14
     164:	mov    QWORD PTR [rsp+0x40],r15
     169:	mov    rbx,QWORD PTR [rdi+0x20]
     16d:	mov    r13,QWORD PTR [rdi+0x28]
     171:	lea    rax,[rsp]
     175:	mov    QWORD PTR [rdi+0x20],rax
     179:	mov    QWORD PTR [rdi+0x28],0x3
     181:	mov    QWORD PTR [rsp],rsi
     185:	mov    QWORD PTR [rsp+0x8],rdx
     18a:	mov    r14,rdx
     18d:	mov    QWORD PTR [rsp+0x10],0x5
     196:	test   rsi,0x1
     19d:	je     1c7 <botlish_fn_2+0x7f>
     1a3:	mov    rax,rsi
     1a6:	sar    rax,1
     1a9:	imul   QWORD PTR [rip+0x110]        # 2c0 <botlish_fn_2+0x178>
     1b0:	seto   cl
     1b3:	or     rax,0x1
     1b7:	test   cl,cl
     1b9:	jne    1c7 <botlish_fn_2+0x7f>
     1bf:	mov    r12,rdi
     1c2:	jmp    1d4 <botlish_fn_2+0x8c>
     1c7:	mov    edx,0x5
     1cc:	mov    r12,rdi
     1cf:	call   1d4 <botlish_fn_2+0x8c>
			1d0: R_X86_64_PLT32	rt_int_mul-0x4
     1d4:	mov    rcx,rax
     1d7:	and    rcx,r14
     1da:	mov    r15,rax
     1dd:	test   rcx,0x1
     1e4:	jne    210 <botlish_fn_2+0xc8>
     1ea:	mov    rdx,r14
     1ed:	mov    rsi,r15
     1f0:	mov    rdi,r12
     1f3:	call   1f8 <botlish_fn_2+0xb0>
			1f4: R_X86_64_PLT32	rt_int_cmp-0x4
     1f8:	mov    ecx,0x2
     1fd:	test   rax,rax
     200:	cmovle rcx,QWORD PTR [rip+0xc0]        # 2c8 <botlish_fn_2+0x180>
     208:	mov    rax,r15
     20b:	jmp    223 <botlish_fn_2+0xdb>
     210:	mov    ecx,0x2
     215:	mov    rax,r15
     218:	cmp    rax,r14
     21b:	cmovle rcx,QWORD PTR [rip+0xa5]        # 2c8 <botlish_fn_2+0x180>
     223:	cmp    rcx,0x6
     227:	je     259 <botlish_fn_2+0x111>
     22d:	mov    QWORD PTR [r12+0x20],rbx
     232:	mov    QWORD PTR [r12+0x28],r13
     237:	mov    rbx,QWORD PTR [rsp+0x20]
     23c:	mov    r12,QWORD PTR [rsp+0x28]
     241:	mov    r13,QWORD PTR [rsp+0x30]
     246:	mov    r14,QWORD PTR [rsp+0x38]
     24b:	mov    r15,QWORD PTR [rsp+0x40]
     250:	add    rsp,0x50
     254:	mov    rsp,rbp
     257:	pop    rbp
     258:	ret
     259:	mov    QWORD PTR [rsp],0x3
     261:	test   r14,0x1
     268:	je     280 <botlish_fn_2+0x138>
     26e:	mov    rax,r14
     271:	add    rax,0x2
     275:	seto   cl
     278:	test   cl,cl
     27a:	je     290 <botlish_fn_2+0x148>
     280:	mov    edx,0x3
     285:	mov    rsi,r14
     288:	mov    rdi,r12
     28b:	call   290 <botlish_fn_2+0x148>
			28c: R_X86_64_PLT32	rt_int_add-0x4
     290:	mov    QWORD PTR [r12+0x20],rbx
     295:	mov    QWORD PTR [r12+0x28],r13
     29a:	mov    rbx,QWORD PTR [rsp+0x20]
     29f:	mov    r12,QWORD PTR [rsp+0x28]
     2a4:	mov    r13,QWORD PTR [rsp+0x30]
     2a9:	mov    r14,QWORD PTR [rsp+0x38]
     2ae:	mov    r15,QWORD PTR [rsp+0x40]
     2b3:	add    rsp,0x50
     2b7:	mov    rsp,rbp
     2ba:	pop    rbp
     2bb:	ret
     2bc:	add    BYTE PTR [rax],al
     2be:	add    BYTE PTR [rax],al
     2c0:	add    al,0x0
     2c2:	add    BYTE PTR [rax],al
     2c4:	add    BYTE PTR [rax],al
     2c6:	add    BYTE PTR [rax],al
     2c8:	(bad)
     2c9:	add    BYTE PTR [rax],al
     2cb:	add    BYTE PTR [rax],al
     2cd:	add    BYTE PTR [rax],al
	...

00000000000002d0 <botlish_entry_2: geo_new_capacity<int, int>>:
     2d0:	push   rbp
     2d1:	mov    rbp,rsp
     2d4:	mov    rsi,QWORD PTR [rdx]
     2d7:	mov    rdx,QWORD PTR [rdx+0x8]
     2db:	call   2e0 <botlish_entry_2+0x10>
			2dc: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     2e0:	mov    rsp,rbp
     2e3:	pop    rbp
     2e4:	ret
     2e5:	add    BYTE PTR [rax],al
	...

00000000000002e8 <botlish_fn_3: geo_grow<mutarray, int>>:
     2e8:	push   rbp
     2e9:	mov    rbp,rsp
     2ec:	sub    rsp,0x30
     2f0:	mov    QWORD PTR [rsp],rbx
     2f4:	mov    QWORD PTR [rsp+0x8],r12
     2f9:	mov    QWORD PTR [rsp+0x10],r13
     2fe:	mov    QWORD PTR [rsp+0x18],r14
     303:	mov    QWORD PTR [rsp+0x20],r15
     308:	mov    rbx,QWORD PTR [rdi]
     30b:	mov    rax,QWORD PTR [rdi+0x8]
     30f:	lea    rcx,[rbx+0x18]
     313:	cmp    rcx,rax
     316:	ja     481 <botlish_fn_3+0x199>
     31c:	lea    rax,[rbx+0x18]
     320:	mov    QWORD PTR [rdi],rax
     323:	mov    r13,rdi
     326:	mov    QWORD PTR [rbx],rsi
     329:	mov    r14,rsi
     32c:	mov    QWORD PTR [rbx+0x8],rdx
     330:	mov    r12,rdx
     333:	mov    rsi,r14
     336:	mov    rdi,r13
     339:	call   33e <botlish_fn_3+0x56>
			33a: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     33e:	mov    r15,rax
     341:	mov    QWORD PTR [rbx+0x10],rax
     345:	mov    rcx,r12
     348:	and    rcx,rax
     34b:	test   rcx,0x1
     352:	jne    37e <botlish_fn_3+0x96>
     358:	mov    rdx,r15
     35b:	mov    rsi,r12
     35e:	mov    rdi,r13
     361:	call   366 <botlish_fn_3+0x7e>
			362: R_X86_64_PLT32	rt_int_cmp-0x4
     366:	mov    ecx,0x2
     36b:	test   rax,rax
     36e:	cmovl  rcx,QWORD PTR [rip+0x13a]        # 4b0 <botlish_fn_3+0x1c8>
     376:	mov    rax,r15
     379:	jmp    391 <botlish_fn_3+0xa9>
     37e:	mov    ecx,0x2
     383:	mov    rax,r15
     386:	cmp    r12,rax
     389:	cmovl  rcx,QWORD PTR [rip+0x11f]        # 4b0 <botlish_fn_3+0x1c8>
     391:	cmp    rcx,0x6
     395:	je     457 <botlish_fn_3+0x16f>
     39b:	mov    rsi,rax
     39e:	mov    rdx,r12
     3a1:	mov    rdi,r13
     3a4:	call   3a9 <botlish_fn_3+0xc1>
			3a5: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     3a9:	test   rax,rax
     3ac:	jne    3ba <botlish_fn_3+0xd2>
     3b2:	mov    rdi,r13
     3b5:	jmp    403 <botlish_fn_3+0x11b>
     3ba:	mov    QWORD PTR [rbx+0x10],rax
     3be:	mov    rsi,rax
     3c1:	mov    rdi,r13
     3c4:	call   3c9 <botlish_fn_3+0xe1>
			3c5: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     3c9:	test   rax,rax
     3cc:	mov    r15,rax
     3cf:	jne    3dd <botlish_fn_3+0xf5>
     3d5:	mov    rdi,r13
     3d8:	jmp    403 <botlish_fn_3+0x11b>
     3dd:	mov    r8d,0x1
     3e3:	mov    rcx,r14
     3e6:	mov    r9,r12
     3e9:	mov    rsi,r15
     3ec:	mov    rdi,r13
     3ef:	mov    rdx,r8
     3f2:	call   3f7 <botlish_fn_3+0x10f>
			3f3: R_X86_64_PLT32	rt_mutarray_copy-0x4
     3f7:	test   rax,rax
     3fa:	jne    42d <botlish_fn_3+0x145>
     400:	mov    rdi,r13
     403:	mov    rdi,r13
     406:	mov    QWORD PTR [rdi],rbx
     409:	xor    rax,rax
     40c:	mov    rbx,QWORD PTR [rsp]
     410:	mov    r12,QWORD PTR [rsp+0x8]
     415:	mov    r13,QWORD PTR [rsp+0x10]
     41a:	mov    r14,QWORD PTR [rsp+0x18]
     41f:	mov    r15,QWORD PTR [rsp+0x20]
     424:	add    rsp,0x30
     428:	mov    rsp,rbp
     42b:	pop    rbp
     42c:	ret
     42d:	mov    rdi,r13
     430:	mov    QWORD PTR [rdi],rbx
     433:	mov    rax,r15
     436:	mov    rbx,QWORD PTR [rsp]
     43a:	mov    r12,QWORD PTR [rsp+0x8]
     43f:	mov    r13,QWORD PTR [rsp+0x10]
     444:	mov    r14,QWORD PTR [rsp+0x18]
     449:	mov    r15,QWORD PTR [rsp+0x20]
     44e:	add    rsp,0x30
     452:	mov    rsp,rbp
     455:	pop    rbp
     456:	ret
     457:	mov    rdi,r13
     45a:	mov    QWORD PTR [rdi],rbx
     45d:	mov    rax,r14
     460:	mov    rbx,QWORD PTR [rsp]
     464:	mov    r12,QWORD PTR [rsp+0x8]
     469:	mov    r13,QWORD PTR [rsp+0x10]
     46e:	mov    r14,QWORD PTR [rsp+0x18]
     473:	mov    r15,QWORD PTR [rsp+0x20]
     478:	add    rsp,0x30
     47c:	mov    rsp,rbp
     47f:	pop    rbp
     480:	ret
     481:	mov    r13,rdi
     484:	call   489 <botlish_fn_3+0x1a1>
			485: R_X86_64_PLT32	rt_stack_overflow-0x4
     489:	xor    rax,rax
     48c:	mov    rbx,QWORD PTR [rsp]
     490:	mov    r12,QWORD PTR [rsp+0x8]
     495:	mov    r13,QWORD PTR [rsp+0x10]
     49a:	mov    r14,QWORD PTR [rsp+0x18]
     49f:	mov    r15,QWORD PTR [rsp+0x20]
     4a4:	add    rsp,0x30
     4a8:	mov    rsp,rbp
     4ab:	pop    rbp
     4ac:	ret
     4ad:	add    BYTE PTR [rax],al
     4af:	add    BYTE PTR [rsi],al
     4b1:	add    BYTE PTR [rax],al
     4b3:	add    BYTE PTR [rax],al
     4b5:	add    BYTE PTR [rax],al
	...

00000000000004b8 <botlish_entry_3: geo_grow<mutarray, int>>:
     4b8:	push   rbp
     4b9:	mov    rbp,rsp
     4bc:	mov    rsi,QWORD PTR [rdx]
     4bf:	mov    rdx,QWORD PTR [rdx+0x8]
     4c3:	call   4c8 <botlish_entry_3+0x10>
			4c4: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     4c8:	mov    rsp,rbp
     4cb:	pop    rbp
     4cc:	ret

00000000000004cd <botlish_fn_4: geo_append<list[mutarray, int], str>>:
     4cd:	push   rbp
     4ce:	mov    rbp,rsp
     4d1:	sub    rsp,0x30
     4d5:	mov    QWORD PTR [rsp],rbx
     4d9:	mov    QWORD PTR [rsp+0x8],r12
     4de:	mov    QWORD PTR [rsp+0x10],r13
     4e3:	mov    QWORD PTR [rsp+0x18],r14
     4e8:	mov    QWORD PTR [rsp+0x20],r15
     4ed:	mov    r12,QWORD PTR [rdi]
     4f0:	mov    r8,QWORD PTR [rdi+0x8]
     4f4:	lea    rax,[r12+0x18]
     4f9:	cmp    rax,r8
     4fc:	ja     60f <botlish_fn_4+0x142>
     502:	lea    rax,[r12+0x18]
     507:	mov    QWORD PTR [rdi],rax
     50a:	mov    r13,rdi
     50d:	mov    QWORD PTR [r12],rsi
     511:	mov    QWORD PTR [r12+0x8],rdx
     516:	mov    rdi,rdx
     519:	mov    QWORD PTR [r12+0x10],rcx
     51e:	mov    r15,rcx
     521:	mov    rbx,rdi
     524:	mov    rdx,rbx
     527:	mov    rdi,r13
     52a:	call   52f <botlish_fn_4+0x62>
			52b: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     52f:	test   rax,rax
     532:	mov    r14,rax
     535:	jne    543 <botlish_fn_4+0x76>
     53b:	mov    rdi,r13
     53e:	jmp    567 <botlish_fn_4+0x9a>
     543:	mov    rax,r14
     546:	mov    QWORD PTR [r12],rax
     54a:	mov    rcx,r15
     54d:	mov    rdx,rbx
     550:	mov    rsi,r14
     553:	mov    rdi,r13
     556:	call   55b <botlish_fn_4+0x8e>
			557: R_X86_64_PLT32	rt_mutarray_set-0x4
     55b:	test   rax,rax
     55e:	jne    594 <botlish_fn_4+0xc7>
     564:	mov    rdi,r13
     567:	mov    rdi,r13
     56a:	mov    QWORD PTR [rdi],r12
     56d:	xor    rdx,rdx
     570:	mov    rax,rdx
     573:	mov    rbx,QWORD PTR [rsp]
     577:	mov    r12,QWORD PTR [rsp+0x8]
     57c:	mov    r13,QWORD PTR [rsp+0x10]
     581:	mov    r14,QWORD PTR [rsp+0x18]
     586:	mov    r15,QWORD PTR [rsp+0x20]
     58b:	add    rsp,0x30
     58f:	mov    rsp,rbp
     592:	pop    rbp
     593:	ret
     594:	mov    QWORD PTR [r12+0x10],0x3
     59d:	test   rbx,0x1
     5a4:	jne    5b2 <botlish_fn_4+0xe5>
     5aa:	mov    rdi,rbx
     5ad:	jmp    5cf <botlish_fn_4+0x102>
     5b2:	mov    rdx,rbx
     5b5:	add    rdx,0x2
     5b9:	mov    rdi,rbx
     5bc:	seto   al
     5bf:	test   al,al
     5c1:	jne    5cf <botlish_fn_4+0x102>
     5c7:	mov    rdi,r13
     5ca:	jmp    5e5 <botlish_fn_4+0x118>
     5cf:	mov    edx,0x3
     5d4:	mov    rsi,rdi
     5d7:	mov    rdi,r13
     5da:	call   5df <botlish_fn_4+0x112>
			5db: R_X86_64_PLT32	rt_int_add-0x4
     5df:	mov    rdx,rax
     5e2:	mov    rdi,r13
     5e5:	mov    rdi,r13
     5e8:	mov    QWORD PTR [rdi],r12
     5eb:	mov    rax,r14
     5ee:	mov    rbx,QWORD PTR [rsp]
     5f2:	mov    r12,QWORD PTR [rsp+0x8]
     5f7:	mov    r13,QWORD PTR [rsp+0x10]
     5fc:	mov    r14,QWORD PTR [rsp+0x18]
     601:	mov    r15,QWORD PTR [rsp+0x20]
     606:	add    rsp,0x30
     60a:	mov    rsp,rbp
     60d:	pop    rbp
     60e:	ret
     60f:	mov    r13,rdi
     612:	call   617 <botlish_fn_4+0x14a>
			613: R_X86_64_PLT32	rt_stack_overflow-0x4
     617:	xor    rdx,rdx
     61a:	mov    rax,rdx
     61d:	mov    rbx,QWORD PTR [rsp]
     621:	mov    r12,QWORD PTR [rsp+0x8]
     626:	mov    r13,QWORD PTR [rsp+0x10]
     62b:	mov    r14,QWORD PTR [rsp+0x18]
     630:	mov    r15,QWORD PTR [rsp+0x20]
     635:	add    rsp,0x30
     639:	mov    rsp,rbp
     63c:	pop    rbp
     63d:	ret

000000000000063e <botlish_entry_4: geo_append<list[mutarray, int], str>>:
     63e:	push   rbp
     63f:	mov    rbp,rsp
     642:	ud2

0000000000000644 <botlish_fn_5: geo_append<list[mutarray, int], list>>:
     644:	push   rbp
     645:	mov    rbp,rsp
     648:	sub    rsp,0x30
     64c:	mov    QWORD PTR [rsp],rbx
     650:	mov    QWORD PTR [rsp+0x8],r12
     655:	mov    QWORD PTR [rsp+0x10],r13
     65a:	mov    QWORD PTR [rsp+0x18],r14
     65f:	mov    QWORD PTR [rsp+0x20],r15
     664:	mov    r12,QWORD PTR [rdi]
     667:	mov    r8,QWORD PTR [rdi+0x8]
     66b:	lea    rax,[r12+0x18]
     670:	cmp    rax,r8
     673:	ja     786 <botlish_fn_5+0x142>
     679:	lea    rax,[r12+0x18]
     67e:	mov    QWORD PTR [rdi],rax
     681:	mov    r13,rdi
     684:	mov    QWORD PTR [r12],rsi
     688:	mov    QWORD PTR [r12+0x8],rdx
     68d:	mov    rdi,rdx
     690:	mov    QWORD PTR [r12+0x10],rcx
     695:	mov    r15,rcx
     698:	mov    rbx,rdi
     69b:	mov    rdx,rbx
     69e:	mov    rdi,r13
     6a1:	call   6a6 <botlish_fn_5+0x62>
			6a2: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     6a6:	test   rax,rax
     6a9:	mov    r14,rax
     6ac:	jne    6ba <botlish_fn_5+0x76>
     6b2:	mov    rdi,r13
     6b5:	jmp    6de <botlish_fn_5+0x9a>
     6ba:	mov    rax,r14
     6bd:	mov    QWORD PTR [r12],rax
     6c1:	mov    rcx,r15
     6c4:	mov    rdx,rbx
     6c7:	mov    rsi,r14
     6ca:	mov    rdi,r13
     6cd:	call   6d2 <botlish_fn_5+0x8e>
			6ce: R_X86_64_PLT32	rt_mutarray_set-0x4
     6d2:	test   rax,rax
     6d5:	jne    70b <botlish_fn_5+0xc7>
     6db:	mov    rdi,r13
     6de:	mov    rdi,r13
     6e1:	mov    QWORD PTR [rdi],r12
     6e4:	xor    rdx,rdx
     6e7:	mov    rax,rdx
     6ea:	mov    rbx,QWORD PTR [rsp]
     6ee:	mov    r12,QWORD PTR [rsp+0x8]
     6f3:	mov    r13,QWORD PTR [rsp+0x10]
     6f8:	mov    r14,QWORD PTR [rsp+0x18]
     6fd:	mov    r15,QWORD PTR [rsp+0x20]
     702:	add    rsp,0x30
     706:	mov    rsp,rbp
     709:	pop    rbp
     70a:	ret
     70b:	mov    QWORD PTR [r12+0x10],0x3
     714:	test   rbx,0x1
     71b:	jne    729 <botlish_fn_5+0xe5>
     721:	mov    rdi,rbx
     724:	jmp    746 <botlish_fn_5+0x102>
     729:	mov    rdx,rbx
     72c:	add    rdx,0x2
     730:	mov    rdi,rbx
     733:	seto   al
     736:	test   al,al
     738:	jne    746 <botlish_fn_5+0x102>
     73e:	mov    rdi,r13
     741:	jmp    75c <botlish_fn_5+0x118>
     746:	mov    edx,0x3
     74b:	mov    rsi,rdi
     74e:	mov    rdi,r13
     751:	call   756 <botlish_fn_5+0x112>
			752: R_X86_64_PLT32	rt_int_add-0x4
     756:	mov    rdx,rax
     759:	mov    rdi,r13
     75c:	mov    rdi,r13
     75f:	mov    QWORD PTR [rdi],r12
     762:	mov    rax,r14
     765:	mov    rbx,QWORD PTR [rsp]
     769:	mov    r12,QWORD PTR [rsp+0x8]
     76e:	mov    r13,QWORD PTR [rsp+0x10]
     773:	mov    r14,QWORD PTR [rsp+0x18]
     778:	mov    r15,QWORD PTR [rsp+0x20]
     77d:	add    rsp,0x30
     781:	mov    rsp,rbp
     784:	pop    rbp
     785:	ret
     786:	mov    r13,rdi
     789:	call   78e <botlish_fn_5+0x14a>
			78a: R_X86_64_PLT32	rt_stack_overflow-0x4
     78e:	xor    rdx,rdx
     791:	mov    rax,rdx
     794:	mov    rbx,QWORD PTR [rsp]
     798:	mov    r12,QWORD PTR [rsp+0x8]
     79d:	mov    r13,QWORD PTR [rsp+0x10]
     7a2:	mov    r14,QWORD PTR [rsp+0x18]
     7a7:	mov    r15,QWORD PTR [rsp+0x20]
     7ac:	add    rsp,0x30
     7b0:	mov    rsp,rbp
     7b3:	pop    rbp
     7b4:	ret

00000000000007b5 <botlish_entry_5: geo_append<list[mutarray, int], list>>:
     7b5:	push   rbp
     7b6:	mov    rbp,rsp
     7b9:	ud2

00000000000007bb <botlish_fn_6: geo_finish<list[mutarray, int]>>:
     7bb:	push   rbp
     7bc:	mov    rbp,rsp
     7bf:	sub    rsp,0x30
     7c3:	mov    QWORD PTR [rsp+0x10],rbx
     7c8:	mov    QWORD PTR [rsp+0x18],r12
     7cd:	mov    QWORD PTR [rsp+0x20],r13
     7d2:	mov    r12,QWORD PTR [rdi+0x20]
     7d6:	mov    r13,QWORD PTR [rdi+0x28]
     7da:	lea    r9,[rsp]
     7de:	mov    QWORD PTR [rdi+0x20],r9
     7e2:	mov    QWORD PTR [rdi+0x28],0x2
     7ea:	mov    rbx,rdi
     7ed:	mov    QWORD PTR [rsp],rsi
     7f1:	mov    QWORD PTR [rsp+0x8],rdx
     7f6:	mov    rdi,rbx
     7f9:	call   7fe <botlish_fn_6+0x43>
			7fa: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     7fe:	test   rax,rax
     801:	jne    82a <botlish_fn_6+0x6f>
     807:	mov    QWORD PTR [rbx+0x20],r12
     80b:	mov    QWORD PTR [rbx+0x28],r13
     80f:	xor    rax,rax
     812:	mov    rbx,QWORD PTR [rsp+0x10]
     817:	mov    r12,QWORD PTR [rsp+0x18]
     81c:	mov    r13,QWORD PTR [rsp+0x20]
     821:	add    rsp,0x30
     825:	mov    rsp,rbp
     828:	pop    rbp
     829:	ret
     82a:	mov    QWORD PTR [rbx+0x20],r12
     82e:	mov    QWORD PTR [rbx+0x28],r13
     832:	mov    rbx,QWORD PTR [rsp+0x10]
     837:	mov    r12,QWORD PTR [rsp+0x18]
     83c:	mov    r13,QWORD PTR [rsp+0x20]
     841:	add    rsp,0x30
     845:	mov    rsp,rbp
     848:	pop    rbp
     849:	ret

000000000000084a <botlish_entry_6: geo_finish<list[mutarray, int]>>:
     84a:	push   rbp
     84b:	mov    rbp,rsp
     84e:	mov    rsi,QWORD PTR [rdx]
     851:	mov    rdx,QWORD PTR [rdx+0x8]
     855:	call   85a <botlish_entry_6+0x10>
			856: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
     85a:	mov    rsp,rbp
     85d:	pop    rbp
     85e:	ret
	...

0000000000000860 <botlish_fn_7: peek<str, int>>:
     860:	push   rbp
     861:	mov    rbp,rsp
     864:	sub    rsp,0x50
     868:	mov    QWORD PTR [rsp+0x20],rbx
     86d:	mov    QWORD PTR [rsp+0x28],r12
     872:	mov    QWORD PTR [rsp+0x30],r13
     877:	mov    QWORD PTR [rsp+0x38],r14
     87c:	mov    QWORD PTR [rsp+0x40],r15
     881:	mov    rbx,QWORD PTR [rdi+0x20]
     885:	mov    r14,QWORD PTR [rdi+0x28]
     889:	lea    rax,[rsp]
     88d:	mov    QWORD PTR [rdi+0x20],rax
     891:	mov    QWORD PTR [rdi+0x28],0x3
     899:	mov    QWORD PTR [rsp],rsi
     89d:	mov    r15,rsi
     8a0:	mov    QWORD PTR [rsp+0x8],rdx
     8a5:	mov    r13,rdx
     8a8:	mov    r12,rdi
     8ab:	mov    rsi,r15
     8ae:	call   8b3 <botlish_fn_7+0x53>
			8af: R_X86_64_PLT32	rt_str_len-0x4
     8b3:	mov    rcx,r13
     8b6:	and    rcx,rax
     8b9:	mov    rdx,rax
     8bc:	test   rcx,0x1
     8c3:	jne    8e9 <botlish_fn_7+0x89>
     8c9:	mov    rsi,r13
     8cc:	mov    rdi,r12
     8cf:	call   8d4 <botlish_fn_7+0x74>
			8d0: R_X86_64_PLT32	rt_int_cmp-0x4
     8d4:	mov    ecx,0x2
     8d9:	test   rax,rax
     8dc:	cmovge rcx,QWORD PTR [rip+0x10c]        # 9f0 <botlish_fn_7+0x190>
     8e4:	jmp    8f9 <botlish_fn_7+0x99>
     8e9:	mov    ecx,0x2
     8ee:	cmp    r13,rdx
     8f1:	cmovge rcx,QWORD PTR [rip+0xf7]        # 9f0 <botlish_fn_7+0x190>
     8f9:	cmp    rcx,0x6
     8fd:	je     9b5 <botlish_fn_7+0x155>
     903:	mov    QWORD PTR [rsp+0x10],0x3
     90c:	test   r13,0x1
     913:	je     92b <botlish_fn_7+0xcb>
     919:	mov    rcx,r13
     91c:	add    rcx,0x2
     920:	seto   al
     923:	test   al,al
     925:	je     93e <botlish_fn_7+0xde>
     92b:	mov    edx,0x3
     930:	mov    rsi,r13
     933:	mov    rdi,r12
     936:	call   93b <botlish_fn_7+0xdb>
			937: R_X86_64_PLT32	rt_int_add-0x4
     93b:	mov    rcx,rax
     93e:	mov    QWORD PTR [rsp+0x10],rcx
     943:	mov    rdx,r13
     946:	mov    rsi,r15
     949:	mov    rdi,r12
     94c:	call   951 <botlish_fn_7+0xf1>
			94d: R_X86_64_PLT32	rt_substr-0x4
     951:	test   rax,rax
     954:	jne    989 <botlish_fn_7+0x129>
     95a:	mov    QWORD PTR [r12+0x20],rbx
     95f:	mov    QWORD PTR [r12+0x28],r14
     964:	xor    rax,rax
     967:	mov    rbx,QWORD PTR [rsp+0x20]
     96c:	mov    r12,QWORD PTR [rsp+0x28]
     971:	mov    r13,QWORD PTR [rsp+0x30]
     976:	mov    r14,QWORD PTR [rsp+0x38]
     97b:	mov    r15,QWORD PTR [rsp+0x40]
     980:	add    rsp,0x50
     984:	mov    rsp,rbp
     987:	pop    rbp
     988:	ret
     989:	mov    QWORD PTR [r12+0x20],rbx
     98e:	mov    QWORD PTR [r12+0x28],r14
     993:	mov    rbx,QWORD PTR [rsp+0x20]
     998:	mov    r12,QWORD PTR [rsp+0x28]
     99d:	mov    r13,QWORD PTR [rsp+0x30]
     9a2:	mov    r14,QWORD PTR [rsp+0x38]
     9a7:	mov    r15,QWORD PTR [rsp+0x40]
     9ac:	add    rsp,0x50
     9b0:	mov    rsp,rbp
     9b3:	pop    rbp
     9b4:	ret
     9b5:	mov    rax,QWORD PTR [r12+0x10]
     9ba:	mov    rax,QWORD PTR [rax+0x8]
     9be:	mov    QWORD PTR [r12+0x20],rbx
     9c3:	mov    QWORD PTR [r12+0x28],r14
     9c8:	mov    rbx,QWORD PTR [rsp+0x20]
     9cd:	mov    r12,QWORD PTR [rsp+0x28]
     9d2:	mov    r13,QWORD PTR [rsp+0x30]
     9d7:	mov    r14,QWORD PTR [rsp+0x38]
     9dc:	mov    r15,QWORD PTR [rsp+0x40]
     9e1:	add    rsp,0x50
     9e5:	mov    rsp,rbp
     9e8:	pop    rbp
     9e9:	ret
     9ea:	add    BYTE PTR [rax],al
     9ec:	add    BYTE PTR [rax],al
     9ee:	add    BYTE PTR [rax],al
     9f0:	(bad)
     9f1:	add    BYTE PTR [rax],al
     9f3:	add    BYTE PTR [rax],al
     9f5:	add    BYTE PTR [rax],al
	...

00000000000009f8 <botlish_entry_7: peek<str, int>>:
     9f8:	push   rbp
     9f9:	mov    rbp,rsp
     9fc:	mov    rsi,QWORD PTR [rdx]
     9ff:	mov    rdx,QWORD PTR [rdx+0x8]
     a03:	call   a08 <botlish_entry_7+0x10>
			a04: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
     a08:	mov    rsp,rbp
     a0b:	pop    rbp
     a0c:	ret
     a0d:	add    BYTE PTR [rax],al
	...

0000000000000a10 <botlish_fn_8: peek<str, int>>:
     a10:	push   rbp
     a11:	mov    rbp,rsp
     a14:	sub    rsp,0x60
     a18:	mov    QWORD PTR [rsp+0x30],rbx
     a1d:	mov    QWORD PTR [rsp+0x38],r12
     a22:	mov    QWORD PTR [rsp+0x40],r13
     a27:	mov    QWORD PTR [rsp+0x48],r14
     a2c:	mov    QWORD PTR [rsp+0x50],r15
     a31:	mov    r15,rcx
     a34:	mov    rbx,QWORD PTR [rdi+0x20]
     a38:	mov    r14,QWORD PTR [rdi+0x28]
     a3c:	lea    rax,[rsp]
     a40:	mov    QWORD PTR [rdi+0x20],rax
     a44:	mov    QWORD PTR [rdi+0x28],0x3
     a4c:	mov    QWORD PTR [rsp],rsi
     a50:	mov    QWORD PTR [rsp+0x18],rsi
     a55:	mov    QWORD PTR [rsp+0x8],rdx
     a5a:	mov    r13,rdx
     a5d:	mov    r12,rdi
     a60:	mov    rsi,QWORD PTR [rsp+0x18]
     a65:	call   a6a <botlish_fn_8+0x5a>
			a66: R_X86_64_PLT32	rt_str_len-0x4
     a6a:	mov    rcx,r13
     a6d:	and    rcx,rax
     a70:	mov    rdx,rax
     a73:	test   rcx,0x1
     a7a:	jne    aa0 <botlish_fn_8+0x90>
     a80:	mov    rsi,r13
     a83:	mov    rdi,r12
     a86:	call   a8b <botlish_fn_8+0x7b>
			a87: R_X86_64_PLT32	rt_int_cmp-0x4
     a8b:	mov    ecx,0x2
     a90:	test   rax,rax
     a93:	cmovge rcx,QWORD PTR [rip+0x13d]        # bd8 <botlish_fn_8+0x1c8>
     a9b:	jmp    ab0 <botlish_fn_8+0xa0>
     aa0:	mov    ecx,0x2
     aa5:	cmp    r13,rdx
     aa8:	cmovge rcx,QWORD PTR [rip+0x128]        # bd8 <botlish_fn_8+0x1c8>
     ab0:	cmp    rcx,0x6
     ab4:	je     b8e <botlish_fn_8+0x17e>
     aba:	mov    QWORD PTR [rsp+0x10],0x3
     ac3:	test   r13,0x1
     aca:	je     aec <botlish_fn_8+0xdc>
     ad0:	mov    rax,r13
     ad3:	add    rax,0x2
     ad7:	seto   cl
     ada:	test   cl,cl
     adc:	jne    aec <botlish_fn_8+0xdc>
     ae2:	mov    QWORD PTR [rsp+0x20],rax
     ae7:	jmp    b01 <botlish_fn_8+0xf1>
     aec:	mov    edx,0x3
     af1:	mov    rsi,r13
     af4:	mov    rdi,r12
     af7:	call   afc <botlish_fn_8+0xec>
			af8: R_X86_64_PLT32	rt_int_add-0x4
     afc:	mov    QWORD PTR [rsp+0x20],rax
     b01:	mov    rcx,QWORD PTR [rsp+0x20]
     b06:	mov    rdx,r13
     b09:	mov    rsi,QWORD PTR [rsp+0x18]
     b0e:	mov    rdi,r12
     b11:	call   b16 <botlish_fn_8+0x106>
			b12: R_X86_64_PLT32	rt_str_region_check-0x4
     b16:	test   rax,rax
     b19:	jne    b4e <botlish_fn_8+0x13e>
     b1f:	mov    QWORD PTR [r12+0x20],rbx
     b24:	mov    QWORD PTR [r12+0x28],r14
     b29:	xor    rax,rax
     b2c:	mov    rbx,QWORD PTR [rsp+0x30]
     b31:	mov    r12,QWORD PTR [rsp+0x38]
     b36:	mov    r13,QWORD PTR [rsp+0x40]
     b3b:	mov    r14,QWORD PTR [rsp+0x48]
     b40:	mov    r15,QWORD PTR [rsp+0x50]
     b45:	add    rsp,0x60
     b49:	mov    rsp,rbp
     b4c:	pop    rbp
     b4d:	ret
     b4e:	mov    QWORD PTR [r12+0x20],rbx
     b53:	mov    QWORD PTR [r12+0x28],r14
     b58:	mov    rcx,r15
     b5b:	mov    QWORD PTR [rcx],r13
     b5e:	mov    rax,QWORD PTR [rsp+0x20]
     b63:	mov    QWORD PTR [rcx+0x8],rax
     b67:	mov    rax,QWORD PTR [rsp+0x18]
     b6c:	mov    rbx,QWORD PTR [rsp+0x30]
     b71:	mov    r12,QWORD PTR [rsp+0x38]
     b76:	mov    r13,QWORD PTR [rsp+0x40]
     b7b:	mov    r14,QWORD PTR [rsp+0x48]
     b80:	mov    r15,QWORD PTR [rsp+0x50]
     b85:	add    rsp,0x60
     b89:	mov    rsp,rbp
     b8c:	pop    rbp
     b8d:	ret
     b8e:	mov    rcx,r15
     b91:	mov    rax,QWORD PTR [r12+0x10]
     b96:	mov    rax,QWORD PTR [rax+0x8]
     b9a:	mov    QWORD PTR [r12+0x20],rbx
     b9f:	mov    QWORD PTR [r12+0x28],r14
     ba4:	mov    QWORD PTR [rcx],0x1
     bab:	mov    QWORD PTR [rcx+0x8],0x1
     bb3:	mov    rbx,QWORD PTR [rsp+0x30]
     bb8:	mov    r12,QWORD PTR [rsp+0x38]
     bbd:	mov    r13,QWORD PTR [rsp+0x40]
     bc2:	mov    r14,QWORD PTR [rsp+0x48]
     bc7:	mov    r15,QWORD PTR [rsp+0x50]
     bcc:	add    rsp,0x60
     bd0:	mov    rsp,rbp
     bd3:	pop    rbp
     bd4:	ret
     bd5:	add    BYTE PTR [rax],al
     bd7:	add    BYTE PTR [rsi],al
     bd9:	add    BYTE PTR [rax],al
     bdb:	add    BYTE PTR [rax],al
     bdd:	add    BYTE PTR [rax],al
	...

0000000000000be0 <botlish_entry_8: peek<str, int>>:
     be0:	push   rbp
     be1:	mov    rbp,rsp
     be4:	ud2

0000000000000be6 <botlish_fn_9: scan_unquoted<str, int, int>>:
     be6:	push   rbp
     be7:	mov    rbp,rsp
     bea:	sub    rsp,0x60
     bee:	mov    QWORD PTR [rsp+0x30],rbx
     bf3:	mov    QWORD PTR [rsp+0x38],r12
     bf8:	mov    QWORD PTR [rsp+0x40],r13
     bfd:	mov    QWORD PTR [rsp+0x48],r14
     c02:	mov    QWORD PTR [rsp+0x50],r15
     c07:	mov    r14,QWORD PTR [rdi]
     c0a:	mov    rax,QWORD PTR [rdi+0x8]
     c0e:	lea    r8,[r14+0x20]
     c12:	cmp    r8,rax
     c15:	ja     e26 <botlish_fn_9+0x240>
     c1b:	lea    rax,[r14+0x20]
     c1f:	mov    QWORD PTR [rdi],rax
     c22:	mov    r15,rdi
     c25:	mov    QWORD PTR [r14+0x18],0x0
     c2d:	mov    QWORD PTR [r14],rsi
     c30:	mov    QWORD PTR [rsp+0x10],rsi
     c35:	mov    QWORD PTR [r14+0x8],rdx
     c39:	mov    QWORD PTR [rsp+0x18],rdx
     c3e:	mov    QWORD PTR [r14+0x10],rcx
     c42:	lea    rbx,[rsp]
     c46:	mov    QWORD PTR [rsp+0x20],rcx
     c4b:	mov    rcx,rbx
     c4e:	mov    rdx,QWORD PTR [rsp+0x20]
     c53:	mov    rsi,QWORD PTR [rsp+0x10]
     c58:	mov    rdi,r15
     c5b:	call   c60 <botlish_fn_9+0x7a>
			c5c: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     c60:	mov    rcx,rax
     c63:	mov    QWORD PTR [rsp+0x28],rax
     c68:	test   rax,rcx
     c6b:	jne    c79 <botlish_fn_9+0x93>
     c71:	mov    rdi,r15
     c74:	jmp    dcb <botlish_fn_9+0x1e5>
     c79:	mov    r12,QWORD PTR [rsp]
     c7d:	mov    r13,QWORD PTR [rsp+0x8]
     c82:	mov    rdi,r15
     c85:	mov    rcx,QWORD PTR [rdi+0x10]
     c89:	mov    r8,QWORD PTR [rcx+0x8]
     c8d:	mov    rcx,r13
     c90:	mov    rdx,r12
     c93:	mov    rsi,QWORD PTR [rsp+0x28]
     c98:	call   c9d <botlish_fn_9+0xb7>
			c99: R_X86_64_PLT32	rt_str_region_eq-0x4
     c9d:	cmp    rax,0x6
     ca1:	je     ce0 <botlish_fn_9+0xfa>
     ca7:	mov    rdi,r15
     caa:	mov    rax,QWORD PTR [rdi+0x10]
     cae:	mov    r8,QWORD PTR [rax+0x10]
     cb2:	mov    rcx,r13
     cb5:	mov    rdx,r12
     cb8:	mov    rsi,QWORD PTR [rsp+0x28]
     cbd:	call   cc2 <botlish_fn_9+0xdc>
			cbe: R_X86_64_PLT32	rt_str_region_eq-0x4
     cc2:	cmp    rax,0x6
     cc6:	je     cd6 <botlish_fn_9+0xf0>
     ccc:	mov    eax,0x2
     cd1:	jmp    ce5 <botlish_fn_9+0xff>
     cd6:	mov    eax,0x6
     cdb:	jmp    ce5 <botlish_fn_9+0xff>
     ce0:	mov    eax,0x6
     ce5:	cmp    rax,0x6
     ce9:	je     d28 <botlish_fn_9+0x142>
     cef:	mov    rdi,r15
     cf2:	mov    rcx,QWORD PTR [rdi+0x10]
     cf6:	mov    r8,QWORD PTR [rcx+0x18]
     cfa:	mov    rcx,r13
     cfd:	mov    rdx,r12
     d00:	mov    rsi,QWORD PTR [rsp+0x28]
     d05:	call   d0a <botlish_fn_9+0x124>
			d06: R_X86_64_PLT32	rt_str_region_eq-0x4
     d0a:	cmp    rax,0x6
     d0e:	je     d1e <botlish_fn_9+0x138>
     d14:	mov    eax,0x2
     d19:	jmp    d2d <botlish_fn_9+0x147>
     d1e:	mov    eax,0x6
     d23:	jmp    d2d <botlish_fn_9+0x147>
     d28:	mov    eax,0x6
     d2d:	cmp    rax,0x6
     d31:	je     da8 <botlish_fn_9+0x1c2>
     d37:	mov    QWORD PTR [r14+0x18],0x3
     d3f:	mov    rsi,QWORD PTR [rsp+0x20]
     d44:	test   rsi,0x1
     d4b:	je     d72 <botlish_fn_9+0x18c>
     d51:	mov    rsi,QWORD PTR [rsp+0x20]
     d56:	mov    rax,rsi
     d59:	add    rax,0x2
     d5d:	seto   cl
     d60:	test   cl,cl
     d62:	jne    d72 <botlish_fn_9+0x18c>
     d68:	mov    rsi,QWORD PTR [rsp+0x10]
     d6d:	jmp    d89 <botlish_fn_9+0x1a3>
     d72:	mov    edx,0x3
     d77:	mov    rsi,QWORD PTR [rsp+0x20]
     d7c:	mov    rdi,r15
     d7f:	call   d84 <botlish_fn_9+0x19e>
			d80: R_X86_64_PLT32	rt_int_add-0x4
     d84:	mov    rsi,QWORD PTR [rsp+0x10]
     d89:	mov    QWORD PTR [r14],rsi
     d8c:	mov    rdx,QWORD PTR [rsp+0x18]
     d91:	mov    QWORD PTR [r14+0x8],rdx
     d95:	mov    QWORD PTR [r14+0x10],rax
     d99:	mov    QWORD PTR [rsp+0x10],rsi
     d9e:	mov    QWORD PTR [rsp+0x20],rax
     da3:	jmp    c4b <botlish_fn_9+0x65>
     da8:	mov    rdx,QWORD PTR [rsp+0x18]
     dad:	mov    rsi,QWORD PTR [rsp+0x10]
     db2:	mov    rcx,QWORD PTR [rsp+0x20]
     db7:	mov    rdi,r15
     dba:	call   dbf <botlish_fn_9+0x1d9>
			dbb: R_X86_64_PLT32	rt_substr-0x4
     dbf:	test   rax,rax
     dc2:	jne    df9 <botlish_fn_9+0x213>
     dc8:	mov    rdi,r15
     dcb:	mov    rdi,r15
     dce:	mov    QWORD PTR [rdi],r14
     dd1:	xor    rdx,rdx
     dd4:	mov    rax,rdx
     dd7:	mov    rbx,QWORD PTR [rsp+0x30]
     ddc:	mov    r12,QWORD PTR [rsp+0x38]
     de1:	mov    r13,QWORD PTR [rsp+0x40]
     de6:	mov    r14,QWORD PTR [rsp+0x48]
     deb:	mov    r15,QWORD PTR [rsp+0x50]
     df0:	add    rsp,0x60
     df4:	mov    rsp,rbp
     df7:	pop    rbp
     df8:	ret
     df9:	mov    rdi,r15
     dfc:	mov    QWORD PTR [rdi],r14
     dff:	mov    rdx,QWORD PTR [rsp+0x20]
     e04:	mov    rbx,QWORD PTR [rsp+0x30]
     e09:	mov    r12,QWORD PTR [rsp+0x38]
     e0e:	mov    r13,QWORD PTR [rsp+0x40]
     e13:	mov    r14,QWORD PTR [rsp+0x48]
     e18:	mov    r15,QWORD PTR [rsp+0x50]
     e1d:	add    rsp,0x60
     e21:	mov    rsp,rbp
     e24:	pop    rbp
     e25:	ret
     e26:	mov    r15,rdi
     e29:	call   e2e <botlish_fn_9+0x248>
			e2a: R_X86_64_PLT32	rt_stack_overflow-0x4
     e2e:	xor    rdx,rdx
     e31:	mov    rax,rdx
     e34:	mov    rbx,QWORD PTR [rsp+0x30]
     e39:	mov    r12,QWORD PTR [rsp+0x38]
     e3e:	mov    r13,QWORD PTR [rsp+0x40]
     e43:	mov    r14,QWORD PTR [rsp+0x48]
     e48:	mov    r15,QWORD PTR [rsp+0x50]
     e4d:	add    rsp,0x60
     e51:	mov    rsp,rbp
     e54:	pop    rbp
     e55:	ret

0000000000000e56 <botlish_entry_9: scan_unquoted<str, int, int>>:
     e56:	push   rbp
     e57:	mov    rbp,rsp
     e5a:	ud2

0000000000000e5c <botlish_fn_10: scan_quoted<str, int, str>>:
     e5c:	push   rbp
     e5d:	mov    rbp,rsp
     e60:	sub    rsp,0x50
     e64:	mov    QWORD PTR [rsp+0x20],rbx
     e69:	mov    QWORD PTR [rsp+0x28],r12
     e6e:	mov    QWORD PTR [rsp+0x30],r13
     e73:	mov    QWORD PTR [rsp+0x38],r14
     e78:	mov    QWORD PTR [rsp+0x40],r15
     e7d:	mov    r13,QWORD PTR [rdi]
     e80:	mov    rax,QWORD PTR [rdi+0x8]
     e84:	lea    r8,[r13+0x28]
     e88:	cmp    r8,rax
     e8b:	ja     115d <botlish_fn_10+0x301>
     e91:	lea    rax,[r13+0x28]
     e95:	mov    QWORD PTR [rdi],rax
     e98:	mov    r14,rdi
     e9b:	mov    QWORD PTR [r13+0x18],0x0
     ea3:	mov    QWORD PTR [r13+0x20],0x0
     eab:	mov    QWORD PTR [r13+0x0],rsi
     eaf:	mov    QWORD PTR [r13+0x8],rdx
     eb3:	mov    QWORD PTR [r13+0x10],rcx
     eb7:	lea    rbx,[rsp]
     ebb:	mov    r12,rsi
     ebe:	mov    r15,rdx
     ec1:	mov    QWORD PTR [rsp+0x10],rcx
     ec6:	mov    rdx,r15
     ec9:	mov    rsi,r12
     ecc:	mov    rdi,r14
     ecf:	call   ed4 <botlish_fn_10+0x78>
			ed0: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
     ed4:	test   rax,rax
     ed7:	jne    ee5 <botlish_fn_10+0x89>
     edd:	mov    rdi,r14
     ee0:	jmp    1116 <botlish_fn_10+0x2ba>
     ee5:	mov    QWORD PTR [r13+0x18],rax
     ee9:	mov    rdi,r14
     eec:	mov    QWORD PTR [rsp+0x18],rax
     ef1:	mov    rdx,QWORD PTR [rdi+0x10]
     ef5:	mov    rsi,QWORD PTR [rdx+0x20]
     ef9:	mov    edx,0x1
     efe:	mov    ecx,0x3
     f03:	mov    r8,QWORD PTR [rsp+0x18]
     f08:	call   f0d <botlish_fn_10+0xb1>
			f09: R_X86_64_PLT32	rt_str_region_eq-0x4
     f0d:	cmp    rax,0x6
     f11:	je     f9e <botlish_fn_10+0x142>
     f17:	mov    QWORD PTR [r13+0x20],0x3
     f1f:	mov    rsi,r15
     f22:	test   rsi,0x1
     f29:	je     f4b <botlish_fn_10+0xef>
     f2f:	mov    r8,rsi
     f32:	add    r8,0x2
     f36:	seto   r10b
     f3a:	test   r10b,r10b
     f3d:	jne    f4b <botlish_fn_10+0xef>
     f43:	mov    rsi,r8
     f46:	jmp    f5b <botlish_fn_10+0xff>
     f4b:	mov    edx,0x3
     f50:	mov    rdi,r14
     f53:	call   f58 <botlish_fn_10+0xfc>
			f54: R_X86_64_PLT32	rt_int_add-0x4
     f58:	mov    rsi,rax
     f5b:	mov    QWORD PTR [r13+0x8],rsi
     f5f:	mov    r15,rsi
     f62:	mov    rsi,QWORD PTR [rsp+0x10]
     f67:	mov    rdx,QWORD PTR [rsp+0x18]
     f6c:	mov    rdi,r14
     f6f:	call   f74 <botlish_fn_10+0x118>
			f70: R_X86_64_PLT32	rt_str_cat-0x4
     f74:	test   rax,rax
     f77:	jne    f85 <botlish_fn_10+0x129>
     f7d:	mov    rdi,r14
     f80:	jmp    1116 <botlish_fn_10+0x2ba>
     f85:	mov    QWORD PTR [r13+0x0],r12
     f89:	mov    rsi,r15
     f8c:	mov    QWORD PTR [r13+0x8],rsi
     f90:	mov    QWORD PTR [r13+0x10],rax
     f94:	mov    QWORD PTR [rsp+0x10],rax
     f99:	jmp    ec6 <botlish_fn_10+0x6a>
     f9e:	mov    QWORD PTR [r13+0x18],0x3
     fa6:	mov    rsi,r15
     fa9:	test   rsi,0x1
     fb0:	je     fcb <botlish_fn_10+0x16f>
     fb6:	mov    rsi,r15
     fb9:	mov    rdx,rsi
     fbc:	add    rdx,0x2
     fc0:	seto   al
     fc3:	test   al,al
     fc5:	je     fde <botlish_fn_10+0x182>
     fcb:	mov    edx,0x3
     fd0:	mov    rsi,r15
     fd3:	mov    rdi,r14
     fd6:	call   fdb <botlish_fn_10+0x17f>
			fd7: R_X86_64_PLT32	rt_int_add-0x4
     fdb:	mov    rdx,rax
     fde:	mov    QWORD PTR [r13+0x18],rdx
     fe2:	mov    rcx,rbx
     fe5:	mov    rsi,r12
     fe8:	mov    rdi,r14
     feb:	call   ff0 <botlish_fn_10+0x194>
			fec: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     ff0:	test   rax,rax
     ff3:	mov    rsi,rax
     ff6:	jne    1004 <botlish_fn_10+0x1a8>
     ffc:	mov    rdi,r14
     fff:	jmp    1116 <botlish_fn_10+0x2ba>
    1004:	mov    rdx,QWORD PTR [rsp]
    1008:	mov    rcx,QWORD PTR [rsp+0x8]
    100d:	mov    rdi,r14
    1010:	mov    rax,QWORD PTR [rdi+0x10]
    1014:	mov    r8,QWORD PTR [rax+0x20]
    1018:	call   101d <botlish_fn_10+0x1c1>
			1019: R_X86_64_PLT32	rt_str_region_eq-0x4
    101d:	cmp    rax,0x6
    1021:	je     109f <botlish_fn_10+0x243>
    1027:	mov    QWORD PTR [r13+0x0],0x3
    102f:	mov    rsi,r15
    1032:	test   rsi,0x1
    1039:	je     105c <botlish_fn_10+0x200>
    103f:	mov    rsi,r15
    1042:	mov    rdx,rsi
    1045:	add    rdx,0x2
    1049:	seto   al
    104c:	test   al,al
    104e:	jne    105c <botlish_fn_10+0x200>
    1054:	mov    rdi,r14
    1057:	jmp    1072 <botlish_fn_10+0x216>
    105c:	mov    edx,0x3
    1061:	mov    rsi,r15
    1064:	mov    rdi,r14
    1067:	call   106c <botlish_fn_10+0x210>
			1068: R_X86_64_PLT32	rt_int_add-0x4
    106c:	mov    rdx,rax
    106f:	mov    rdi,r14
    1072:	mov    rdi,r14
    1075:	mov    QWORD PTR [rdi],r13
    1078:	mov    rax,QWORD PTR [rsp+0x10]
    107d:	mov    rbx,QWORD PTR [rsp+0x20]
    1082:	mov    r12,QWORD PTR [rsp+0x28]
    1087:	mov    r13,QWORD PTR [rsp+0x30]
    108c:	mov    r14,QWORD PTR [rsp+0x38]
    1091:	mov    r15,QWORD PTR [rsp+0x40]
    1096:	add    rsp,0x50
    109a:	mov    rsp,rbp
    109d:	pop    rbp
    109e:	ret
    109f:	mov    QWORD PTR [r13+0x18],0x5
    10a7:	mov    rsi,r15
    10aa:	test   rsi,0x1
    10b1:	je     10d7 <botlish_fn_10+0x27b>
    10b7:	mov    rsi,r15
    10ba:	mov    rax,rsi
    10bd:	add    rax,0x4
    10c1:	seto   cl
    10c4:	test   cl,cl
    10c6:	jne    10d7 <botlish_fn_10+0x27b>
    10cc:	mov    rsi,rax
    10cf:	mov    r15,rax
    10d2:	jmp    10ed <botlish_fn_10+0x291>
    10d7:	mov    edx,0x5
    10dc:	mov    rsi,r15
    10df:	mov    rdi,r14
    10e2:	call   10e7 <botlish_fn_10+0x28b>
			10e3: R_X86_64_PLT32	rt_int_add-0x4
    10e7:	mov    rsi,rax
    10ea:	mov    r15,rax
    10ed:	mov    QWORD PTR [r13+0x8],rsi
    10f1:	mov    rdi,r14
    10f4:	mov    rax,QWORD PTR [rdi+0x10]
    10f8:	mov    rdx,QWORD PTR [rax+0x20]
    10fc:	mov    QWORD PTR [r13+0x18],rdx
    1100:	mov    rsi,QWORD PTR [rsp+0x10]
    1105:	call   110a <botlish_fn_10+0x2ae>
			1106: R_X86_64_PLT32	rt_str_cat-0x4
    110a:	test   rax,rax
    110d:	jne    1144 <botlish_fn_10+0x2e8>
    1113:	mov    rdi,r14
    1116:	mov    rdi,r14
    1119:	mov    QWORD PTR [rdi],r13
    111c:	xor    rdx,rdx
    111f:	mov    rax,rdx
    1122:	mov    rbx,QWORD PTR [rsp+0x20]
    1127:	mov    r12,QWORD PTR [rsp+0x28]
    112c:	mov    r13,QWORD PTR [rsp+0x30]
    1131:	mov    r14,QWORD PTR [rsp+0x38]
    1136:	mov    r15,QWORD PTR [rsp+0x40]
    113b:	add    rsp,0x50
    113f:	mov    rsp,rbp
    1142:	pop    rbp
    1143:	ret
    1144:	mov    QWORD PTR [r13+0x0],r12
    1148:	mov    rsi,r15
    114b:	mov    QWORD PTR [r13+0x8],rsi
    114f:	mov    QWORD PTR [r13+0x10],rax
    1153:	mov    QWORD PTR [rsp+0x10],rax
    1158:	jmp    ec6 <botlish_fn_10+0x6a>
    115d:	mov    r14,rdi
    1160:	call   1165 <botlish_fn_10+0x309>
			1161: R_X86_64_PLT32	rt_stack_overflow-0x4
    1165:	xor    rdx,rdx
    1168:	mov    rax,rdx
    116b:	mov    rbx,QWORD PTR [rsp+0x20]
    1170:	mov    r12,QWORD PTR [rsp+0x28]
    1175:	mov    r13,QWORD PTR [rsp+0x30]
    117a:	mov    r14,QWORD PTR [rsp+0x38]
    117f:	mov    r15,QWORD PTR [rsp+0x40]
    1184:	add    rsp,0x50
    1188:	mov    rsp,rbp
    118b:	pop    rbp
    118c:	ret

000000000000118d <botlish_entry_10: scan_quoted<str, int, str>>:
    118d:	push   rbp
    118e:	mov    rbp,rsp
    1191:	ud2

0000000000001193 <botlish_fn_11: scan_field<str, int>>:
    1193:	push   rbp
    1194:	mov    rbp,rsp
    1197:	sub    rsp,0x30
    119b:	mov    QWORD PTR [rsp+0x10],rbx
    11a0:	mov    QWORD PTR [rsp+0x18],r12
    11a5:	mov    QWORD PTR [rsp+0x20],r13
    11aa:	mov    QWORD PTR [rsp+0x28],r14
    11af:	mov    rbx,QWORD PTR [rdi]
    11b2:	mov    rax,QWORD PTR [rdi+0x8]
    11b6:	lea    rcx,[rbx+0x18]
    11ba:	cmp    rcx,rax
    11bd:	ja     1320 <botlish_fn_11+0x18d>
    11c3:	lea    rax,[rbx+0x18]
    11c7:	mov    QWORD PTR [rdi],rax
    11ca:	mov    r12,rdi
    11cd:	mov    QWORD PTR [rbx+0x10],0x0
    11d5:	mov    QWORD PTR [rbx],rsi
    11d8:	mov    r13,rsi
    11db:	mov    QWORD PTR [rbx+0x8],rdx
    11df:	mov    r14,rdx
    11e2:	lea    rcx,[rsp]
    11e6:	mov    rdx,r14
    11e9:	mov    rsi,r13
    11ec:	mov    rdi,r12
    11ef:	call   11f4 <botlish_fn_11+0x61>
			11f0: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    11f4:	test   rax,rax
    11f7:	mov    rsi,rax
    11fa:	jne    1208 <botlish_fn_11+0x75>
    1200:	mov    rdi,r12
    1203:	jmp    12d4 <botlish_fn_11+0x141>
    1208:	mov    rdx,QWORD PTR [rsp]
    120c:	mov    rcx,QWORD PTR [rsp+0x8]
    1211:	mov    rdi,r12
    1214:	mov    rax,QWORD PTR [rdi+0x10]
    1218:	mov    r8,QWORD PTR [rax+0x20]
    121c:	call   1221 <botlish_fn_11+0x8e>
			121d: R_X86_64_PLT32	rt_str_region_eq-0x4
    1221:	cmp    rax,0x6
    1225:	je     1270 <botlish_fn_11+0xdd>
    122b:	mov    rcx,r14
    122e:	mov    rsi,r13
    1231:	mov    rdi,r12
    1234:	mov    rdx,rcx
    1237:	call   123c <botlish_fn_11+0xa9>
			1238: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_unquoted<str, int, int>
    123c:	test   rax,rax
    123f:	jne    124d <botlish_fn_11+0xba>
    1245:	mov    rdi,r12
    1248:	jmp    12d4 <botlish_fn_11+0x141>
    124d:	mov    rdi,r12
    1250:	mov    QWORD PTR [rdi],rbx
    1253:	mov    rbx,QWORD PTR [rsp+0x10]
    1258:	mov    r12,QWORD PTR [rsp+0x18]
    125d:	mov    r13,QWORD PTR [rsp+0x20]
    1262:	mov    r14,QWORD PTR [rsp+0x28]
    1267:	add    rsp,0x30
    126b:	mov    rsp,rbp
    126e:	pop    rbp
    126f:	ret
    1270:	mov    QWORD PTR [rbx+0x10],0x3
    1278:	mov    rdx,r14
    127b:	test   rdx,0x1
    1282:	je     129a <botlish_fn_11+0x107>
    1288:	mov    rdx,r14
    128b:	add    rdx,0x2
    128f:	seto   al
    1292:	test   al,al
    1294:	je     12ad <botlish_fn_11+0x11a>
    129a:	mov    edx,0x3
    129f:	mov    rsi,r14
    12a2:	mov    rdi,r12
    12a5:	call   12aa <botlish_fn_11+0x117>
			12a6: R_X86_64_PLT32	rt_int_add-0x4
    12aa:	mov    rdx,rax
    12ad:	mov    QWORD PTR [rbx+0x8],rdx
    12b1:	mov    rdi,r12
    12b4:	mov    rax,QWORD PTR [rdi+0x10]
    12b8:	mov    rcx,QWORD PTR [rax+0x8]
    12bc:	mov    QWORD PTR [rbx+0x10],rcx
    12c0:	mov    rsi,r13
    12c3:	call   12c8 <botlish_fn_11+0x135>
			12c4: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_quoted<str, int, str>
    12c8:	test   rax,rax
    12cb:	jne    12fd <botlish_fn_11+0x16a>
    12d1:	mov    rdi,r12
    12d4:	mov    rdi,r12
    12d7:	mov    QWORD PTR [rdi],rbx
    12da:	xor    rdx,rdx
    12dd:	mov    rax,rdx
    12e0:	mov    rbx,QWORD PTR [rsp+0x10]
    12e5:	mov    r12,QWORD PTR [rsp+0x18]
    12ea:	mov    r13,QWORD PTR [rsp+0x20]
    12ef:	mov    r14,QWORD PTR [rsp+0x28]
    12f4:	add    rsp,0x30
    12f8:	mov    rsp,rbp
    12fb:	pop    rbp
    12fc:	ret
    12fd:	mov    rdi,r12
    1300:	mov    QWORD PTR [rdi],rbx
    1303:	mov    rbx,QWORD PTR [rsp+0x10]
    1308:	mov    r12,QWORD PTR [rsp+0x18]
    130d:	mov    r13,QWORD PTR [rsp+0x20]
    1312:	mov    r14,QWORD PTR [rsp+0x28]
    1317:	add    rsp,0x30
    131b:	mov    rsp,rbp
    131e:	pop    rbp
    131f:	ret
    1320:	mov    r12,rdi
    1323:	call   1328 <botlish_fn_11+0x195>
			1324: R_X86_64_PLT32	rt_stack_overflow-0x4
    1328:	xor    rdx,rdx
    132b:	mov    rax,rdx
    132e:	mov    rbx,QWORD PTR [rsp+0x10]
    1333:	mov    r12,QWORD PTR [rsp+0x18]
    1338:	mov    r13,QWORD PTR [rsp+0x20]
    133d:	mov    r14,QWORD PTR [rsp+0x28]
    1342:	add    rsp,0x30
    1346:	mov    rsp,rbp
    1349:	pop    rbp
    134a:	ret

000000000000134b <botlish_entry_11: scan_field<str, int>>:
    134b:	push   rbp
    134c:	mov    rbp,rsp
    134f:	ud2

0000000000001351 <botlish_fn_12: scan_record<str, int, list[mutarray, int]>>:
    1351:	push   rbp
    1352:	mov    rbp,rsp
    1355:	sub    rsp,0x70
    1359:	mov    QWORD PTR [rsp+0x40],rbx
    135e:	mov    QWORD PTR [rsp+0x48],r12
    1363:	mov    QWORD PTR [rsp+0x50],r13
    1368:	mov    QWORD PTR [rsp+0x58],r14
    136d:	mov    QWORD PTR [rsp+0x60],r15
    1372:	mov    r13,QWORD PTR [rdi]
    1375:	mov    rax,QWORD PTR [rdi+0x8]
    1379:	lea    r9,[r13+0x28]
    137d:	cmp    r9,rax
    1380:	ja     1641 <botlish_fn_12+0x2f0>
    1386:	lea    rax,[r13+0x28]
    138a:	mov    QWORD PTR [rdi],rax
    138d:	mov    QWORD PTR [rsp+0x10],rdi
    1392:	mov    QWORD PTR [r13+0x20],0x0
    139a:	mov    QWORD PTR [r13+0x0],rsi
    139e:	mov    QWORD PTR [r13+0x8],rdx
    13a2:	mov    QWORD PTR [r13+0x10],rcx
    13a6:	mov    QWORD PTR [r13+0x18],r8
    13aa:	lea    rbx,[rsp]
    13ae:	mov    r12,rsi
    13b1:	mov    r14,r8
    13b4:	mov    r15,rcx
    13b7:	mov    rsi,r12
    13ba:	mov    rdi,QWORD PTR [rsp+0x10]
    13bf:	call   13c4 <botlish_fn_12+0x73>
			13c0: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_field<str, int>
    13c4:	test   rax,rax
    13c7:	jne    13d7 <botlish_fn_12+0x86>
    13cd:	mov    rdi,QWORD PTR [rsp+0x10]
    13d2:	jmp    1518 <botlish_fn_12+0x1c7>
    13d7:	mov    QWORD PTR [r13+0x8],rax
    13db:	mov    rcx,rax
    13de:	mov    QWORD PTR [r13+0x20],rdx
    13e2:	mov    QWORD PTR [rsp+0x30],rdx
    13e7:	mov    rsi,r15
    13ea:	mov    rdx,r14
    13ed:	mov    rdi,QWORD PTR [rsp+0x10]
    13f2:	call   13f7 <botlish_fn_12+0xa6>
			13f3: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
    13f7:	test   rax,rax
    13fa:	jne    140a <botlish_fn_12+0xb9>
    1400:	mov    rdi,QWORD PTR [rsp+0x10]
    1405:	jmp    1518 <botlish_fn_12+0x1c7>
    140a:	mov    QWORD PTR [r13+0x8],rax
    140e:	mov    QWORD PTR [rsp+0x20],rax
    1413:	mov    QWORD PTR [r13+0x10],rdx
    1417:	mov    QWORD PTR [rsp+0x28],rdx
    141c:	mov    rcx,rbx
    141f:	mov    rdx,QWORD PTR [rsp+0x30]
    1424:	mov    rsi,r12
    1427:	mov    rdi,QWORD PTR [rsp+0x10]
    142c:	call   1431 <botlish_fn_12+0xe0>
			142d: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    1431:	test   rax,rax
    1434:	mov    QWORD PTR [rsp+0x18],rax
    1439:	jne    1449 <botlish_fn_12+0xf8>
    143f:	mov    rdi,QWORD PTR [rsp+0x10]
    1444:	jmp    1518 <botlish_fn_12+0x1c7>
    1449:	mov    r15,QWORD PTR [rsp]
    144d:	mov    r14,QWORD PTR [rsp+0x8]
    1452:	mov    rdi,QWORD PTR [rsp+0x10]
    1457:	mov    rcx,QWORD PTR [rdi+0x10]
    145b:	mov    r8,QWORD PTR [rcx+0x10]
    145f:	mov    rcx,r14
    1462:	mov    rdx,r15
    1465:	mov    rsi,QWORD PTR [rsp+0x18]
    146a:	call   146f <botlish_fn_12+0x11e>
			146b: R_X86_64_PLT32	rt_str_region_eq-0x4
    146f:	cmp    rax,0x6
    1473:	je     15d0 <botlish_fn_12+0x27f>
    1479:	mov    rdi,QWORD PTR [rsp+0x10]
    147e:	mov    rsi,QWORD PTR [rdi+0x10]
    1482:	mov    r8,QWORD PTR [rsi+0x18]
    1486:	mov    rcx,r14
    1489:	mov    rdx,r15
    148c:	mov    rsi,QWORD PTR [rsp+0x18]
    1491:	call   1496 <botlish_fn_12+0x145>
			1492: R_X86_64_PLT32	rt_str_region_eq-0x4
    1496:	cmp    rax,0x6
    149a:	je     14f6 <botlish_fn_12+0x1a5>
    14a0:	mov    rdx,QWORD PTR [rsp+0x28]
    14a5:	mov    rsi,QWORD PTR [rsp+0x20]
    14aa:	mov    rdi,QWORD PTR [rsp+0x10]
    14af:	call   14b4 <botlish_fn_12+0x163>
			14b0: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    14b4:	test   rax,rax
    14b7:	jne    14c7 <botlish_fn_12+0x176>
    14bd:	mov    rdi,QWORD PTR [rsp+0x10]
    14c2:	jmp    1518 <botlish_fn_12+0x1c7>
    14c7:	mov    rdi,QWORD PTR [rsp+0x10]
    14cc:	mov    QWORD PTR [rdi],r13
    14cf:	mov    rdx,QWORD PTR [rsp+0x30]
    14d4:	mov    rbx,QWORD PTR [rsp+0x40]
    14d9:	mov    r12,QWORD PTR [rsp+0x48]
    14de:	mov    r13,QWORD PTR [rsp+0x50]
    14e3:	mov    r14,QWORD PTR [rsp+0x58]
    14e8:	mov    r15,QWORD PTR [rsp+0x60]
    14ed:	add    rsp,0x70
    14f1:	mov    rsp,rbp
    14f4:	pop    rbp
    14f5:	ret
    14f6:	mov    rdx,QWORD PTR [rsp+0x28]
    14fb:	mov    rsi,QWORD PTR [rsp+0x20]
    1500:	mov    rdi,QWORD PTR [rsp+0x10]
    1505:	call   150a <botlish_fn_12+0x1b9>
			1506: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    150a:	test   rax,rax
    150d:	jne    1548 <botlish_fn_12+0x1f7>
    1513:	mov    rdi,QWORD PTR [rsp+0x10]
    1518:	mov    rdi,QWORD PTR [rsp+0x10]
    151d:	mov    QWORD PTR [rdi],r13
    1520:	xor    rdx,rdx
    1523:	mov    rax,rdx
    1526:	mov    rbx,QWORD PTR [rsp+0x40]
    152b:	mov    r12,QWORD PTR [rsp+0x48]
    1530:	mov    r13,QWORD PTR [rsp+0x50]
    1535:	mov    r14,QWORD PTR [rsp+0x58]
    153a:	mov    r15,QWORD PTR [rsp+0x60]
    153f:	add    rsp,0x70
    1543:	mov    rsp,rbp
    1546:	pop    rbp
    1547:	ret
    1548:	mov    QWORD PTR [r13+0x0],rax
    154c:	mov    rbx,rax
    154f:	mov    QWORD PTR [r13+0x8],0x3
    1557:	mov    rdx,QWORD PTR [rsp+0x30]
    155c:	test   rdx,0x1
    1563:	je     1587 <botlish_fn_12+0x236>
    1569:	mov    rdx,QWORD PTR [rsp+0x30]
    156e:	add    rdx,0x2
    1572:	seto   al
    1575:	test   al,al
    1577:	jne    1587 <botlish_fn_12+0x236>
    157d:	mov    rdi,QWORD PTR [rsp+0x10]
    1582:	jmp    15a3 <botlish_fn_12+0x252>
    1587:	mov    edx,0x3
    158c:	mov    rsi,QWORD PTR [rsp+0x30]
    1591:	mov    rdi,QWORD PTR [rsp+0x10]
    1596:	call   159b <botlish_fn_12+0x24a>
			1597: R_X86_64_PLT32	rt_int_add-0x4
    159b:	mov    rdx,rax
    159e:	mov    rdi,QWORD PTR [rsp+0x10]
    15a3:	mov    rdi,QWORD PTR [rsp+0x10]
    15a8:	mov    QWORD PTR [rdi],r13
    15ab:	mov    rax,rbx
    15ae:	mov    rbx,QWORD PTR [rsp+0x40]
    15b3:	mov    r12,QWORD PTR [rsp+0x48]
    15b8:	mov    r13,QWORD PTR [rsp+0x50]
    15bd:	mov    r14,QWORD PTR [rsp+0x58]
    15c2:	mov    r15,QWORD PTR [rsp+0x60]
    15c7:	add    rsp,0x70
    15cb:	mov    rsp,rbp
    15ce:	pop    rbp
    15cf:	ret
    15d0:	mov    rsi,QWORD PTR [rsp+0x30]
    15d5:	mov    edx,0x3
    15da:	mov    r9,rdx
    15dd:	mov    QWORD PTR [r13+0x18],0x3
    15e5:	test   rsi,0x1
    15ec:	jne    15fa <botlish_fn_12+0x2a9>
    15f2:	mov    rdx,r9
    15f5:	jmp    160f <botlish_fn_12+0x2be>
    15fa:	mov    rdx,rsi
    15fd:	add    rdx,0x2
    1601:	seto   al
    1604:	test   al,al
    1606:	je     161c <botlish_fn_12+0x2cb>
    160c:	mov    rdx,r9
    160f:	mov    rdi,QWORD PTR [rsp+0x10]
    1614:	call   1619 <botlish_fn_12+0x2c8>
			1615: R_X86_64_PLT32	rt_int_add-0x4
    1619:	mov    rdx,rax
    161c:	mov    QWORD PTR [r13+0x0],r12
    1620:	mov    QWORD PTR [r13+0x8],rdx
    1624:	mov    rsi,QWORD PTR [rsp+0x20]
    1629:	mov    QWORD PTR [r13+0x10],rsi
    162d:	mov    rax,QWORD PTR [rsp+0x28]
    1632:	mov    QWORD PTR [r13+0x18],rax
    1636:	mov    r14,rax
    1639:	mov    r15,rsi
    163c:	jmp    13b7 <botlish_fn_12+0x66>
    1641:	mov    QWORD PTR [rsp+0x10],rdi
    1646:	call   164b <botlish_fn_12+0x2fa>
			1647: R_X86_64_PLT32	rt_stack_overflow-0x4
    164b:	xor    rdx,rdx
    164e:	mov    rax,rdx
    1651:	mov    rbx,QWORD PTR [rsp+0x40]
    1656:	mov    r12,QWORD PTR [rsp+0x48]
    165b:	mov    r13,QWORD PTR [rsp+0x50]
    1660:	mov    r14,QWORD PTR [rsp+0x58]
    1665:	mov    r15,QWORD PTR [rsp+0x60]
    166a:	add    rsp,0x70
    166e:	mov    rsp,rbp
    1671:	pop    rbp
    1672:	ret

0000000000001673 <botlish_entry_12: scan_record<str, int, list[mutarray, int]>>:
    1673:	push   rbp
    1674:	mov    rbp,rsp
    1677:	ud2
    1679:	add    BYTE PTR [rax],al
    167b:	add    BYTE PTR [rax],al
    167d:	add    BYTE PTR [rax],al
	...

0000000000001680 <botlish_fn_13: scan_records<str, int, list[mutarray, int]>>:
    1680:	push   rbp
    1681:	mov    rbp,rsp
    1684:	sub    rsp,0x40
    1688:	mov    QWORD PTR [rsp+0x10],rbx
    168d:	mov    QWORD PTR [rsp+0x18],r12
    1692:	mov    QWORD PTR [rsp+0x20],r13
    1697:	mov    QWORD PTR [rsp+0x28],r14
    169c:	mov    QWORD PTR [rsp+0x30],r15
    16a1:	mov    r12,QWORD PTR [rdi]
    16a4:	mov    rax,QWORD PTR [rdi+0x8]
    16a8:	lea    r9,[r12+0x30]
    16ad:	cmp    r9,rax
    16b0:	ja     1859 <botlish_fn_13+0x1d9>
    16b6:	lea    rax,[r12+0x30]
    16bb:	mov    QWORD PTR [rdi],rax
    16be:	mov    r14,rdi
    16c1:	mov    QWORD PTR [r12+0x20],0x0
    16ca:	mov    QWORD PTR [r12+0x28],0x0
    16d3:	mov    QWORD PTR [r12],rsi
    16d7:	mov    QWORD PTR [r12+0x8],rdx
    16dc:	mov    r13,rdx
    16df:	mov    QWORD PTR [r12+0x10],rcx
    16e4:	mov    QWORD PTR [r12+0x18],r8
    16e9:	mov    rbx,rsi
    16ec:	mov    r15,r8
    16ef:	mov    QWORD PTR [rsp],rcx
    16f3:	mov    rsi,rbx
    16f6:	mov    rdi,r14
    16f9:	call   16fe <botlish_fn_13+0x7e>
			16fa: R_X86_64_PLT32	rt_str_len-0x4
    16fe:	mov    rcx,r13
    1701:	and    rcx,rax
    1704:	mov    rdx,rax
    1707:	test   rcx,0x1
    170e:	jne    1734 <botlish_fn_13+0xb4>
    1714:	mov    rsi,r13
    1717:	mov    rdi,r14
    171a:	call   171f <botlish_fn_13+0x9f>
			171b: R_X86_64_PLT32	rt_int_cmp-0x4
    171f:	mov    ecx,0x2
    1724:	test   rax,rax
    1727:	cmovge rcx,QWORD PTR [rip+0x159]        # 1888 <botlish_fn_13+0x208>
    172f:	jmp    1747 <botlish_fn_13+0xc7>
    1734:	mov    ecx,0x2
    1739:	mov    rax,r13
    173c:	cmp    rax,rdx
    173f:	cmovge rcx,QWORD PTR [rip+0x141]        # 1888 <botlish_fn_13+0x208>
    1747:	cmp    rcx,0x6
    174b:	je     17eb <botlish_fn_13+0x16b>
    1751:	mov    rdi,r14
    1754:	call   1759 <botlish_fn_13+0xd9>
			1755: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1759:	test   rax,rax
    175c:	jne    176a <botlish_fn_13+0xea>
    1762:	mov    rdi,r14
    1765:	jmp    1806 <botlish_fn_13+0x186>
    176a:	mov    QWORD PTR [r12+0x20],rax
    176f:	mov    rcx,rax
    1772:	mov    QWORD PTR [r12+0x28],rdx
    1777:	mov    r8,rdx
    177a:	mov    rdx,r13
    177d:	mov    rsi,rbx
    1780:	mov    rdi,r14
    1783:	call   1788 <botlish_fn_13+0x108>
			1784: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_record<str, int, list[mutarray, int]>
    1788:	test   rax,rax
    178b:	jne    1799 <botlish_fn_13+0x119>
    1791:	mov    rdi,r14
    1794:	jmp    1806 <botlish_fn_13+0x186>
    1799:	mov    QWORD PTR [r12+0x8],rax
    179e:	mov    rcx,rax
    17a1:	mov    QWORD PTR [r12+0x20],rdx
    17a6:	mov    r13,rdx
    17a9:	mov    rsi,QWORD PTR [rsp]
    17ad:	mov    rdx,r15
    17b0:	mov    rdi,r14
    17b3:	call   17b8 <botlish_fn_13+0x138>
			17b4: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    17b8:	test   rax,rax
    17bb:	jne    17c9 <botlish_fn_13+0x149>
    17c1:	mov    rdi,r14
    17c4:	jmp    1806 <botlish_fn_13+0x186>
    17c9:	mov    QWORD PTR [r12],rbx
    17cd:	mov    rcx,r13
    17d0:	mov    QWORD PTR [r12+0x8],rcx
    17d5:	mov    QWORD PTR [r12+0x10],rax
    17da:	mov    QWORD PTR [r12+0x18],rdx
    17df:	mov    r15,rdx
    17e2:	mov    QWORD PTR [rsp],rax
    17e6:	jmp    16f3 <botlish_fn_13+0x73>
    17eb:	mov    rdx,r15
    17ee:	mov    rsi,QWORD PTR [rsp]
    17f2:	mov    rdi,r14
    17f5:	call   17fa <botlish_fn_13+0x17a>
			17f6: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    17fa:	test   rax,rax
    17fd:	jne    1831 <botlish_fn_13+0x1b1>
    1803:	mov    rdi,r14
    1806:	mov    rdi,r14
    1809:	mov    QWORD PTR [rdi],r12
    180c:	xor    rax,rax
    180f:	mov    rbx,QWORD PTR [rsp+0x10]
    1814:	mov    r12,QWORD PTR [rsp+0x18]
    1819:	mov    r13,QWORD PTR [rsp+0x20]
    181e:	mov    r14,QWORD PTR [rsp+0x28]
    1823:	mov    r15,QWORD PTR [rsp+0x30]
    1828:	add    rsp,0x40
    182c:	mov    rsp,rbp
    182f:	pop    rbp
    1830:	ret
    1831:	mov    rdi,r14
    1834:	mov    QWORD PTR [rdi],r12
    1837:	mov    rbx,QWORD PTR [rsp+0x10]
    183c:	mov    r12,QWORD PTR [rsp+0x18]
    1841:	mov    r13,QWORD PTR [rsp+0x20]
    1846:	mov    r14,QWORD PTR [rsp+0x28]
    184b:	mov    r15,QWORD PTR [rsp+0x30]
    1850:	add    rsp,0x40
    1854:	mov    rsp,rbp
    1857:	pop    rbp
    1858:	ret
    1859:	mov    r14,rdi
    185c:	call   1861 <botlish_fn_13+0x1e1>
			185d: R_X86_64_PLT32	rt_stack_overflow-0x4
    1861:	xor    rax,rax
    1864:	mov    rbx,QWORD PTR [rsp+0x10]
    1869:	mov    r12,QWORD PTR [rsp+0x18]
    186e:	mov    r13,QWORD PTR [rsp+0x20]
    1873:	mov    r14,QWORD PTR [rsp+0x28]
    1878:	mov    r15,QWORD PTR [rsp+0x30]
    187d:	add    rsp,0x40
    1881:	mov    rsp,rbp
    1884:	pop    rbp
    1885:	ret
    1886:	add    BYTE PTR [rax],al
    1888:	(bad)
    1889:	add    BYTE PTR [rax],al
    188b:	add    BYTE PTR [rax],al
    188d:	add    BYTE PTR [rax],al
	...

0000000000001890 <botlish_entry_13: scan_records<str, int, list[mutarray, int]>>:
    1890:	push   rbp
    1891:	mov    rbp,rsp
    1894:	mov    rsi,QWORD PTR [rdx]
    1897:	mov    r9,QWORD PTR [rdx+0x8]
    189b:	mov    rcx,QWORD PTR [rdx+0x10]
    189f:	mov    r8,QWORD PTR [rdx+0x18]
    18a3:	mov    rdx,r9
    18a6:	call   18ab <botlish_entry_13+0x1b>
			18a7: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    18ab:	mov    rsp,rbp
    18ae:	pop    rbp
    18af:	ret

00000000000018b0 <botlish_fn_14: csv_parse<str>>:
    18b0:	push   rbp
    18b1:	mov    rbp,rsp
    18b4:	sub    rsp,0x20
    18b8:	mov    QWORD PTR [rsp],rbx
    18bc:	mov    QWORD PTR [rsp+0x8],r12
    18c1:	mov    QWORD PTR [rsp+0x10],r15
    18c6:	mov    r15,QWORD PTR [rdi]
    18c9:	mov    rax,QWORD PTR [rdi+0x8]
    18cd:	lea    rcx,[r15+0x20]
    18d1:	cmp    rcx,rax
    18d4:	ja     1982 <botlish_fn_14+0xd2>
    18da:	lea    rax,[r15+0x20]
    18de:	mov    QWORD PTR [rdi],rax
    18e1:	mov    rbx,rdi
    18e4:	mov    QWORD PTR [r15+0x10],0x0
    18ec:	mov    QWORD PTR [r15+0x18],0x0
    18f4:	mov    QWORD PTR [r15],rsi
    18f7:	mov    r12,rsi
    18fa:	mov    QWORD PTR [r15+0x8],0x1
    1902:	mov    rdi,rbx
    1905:	call   190a <botlish_fn_14+0x5a>
			1906: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    190a:	test   rax,rax
    190d:	jne    191b <botlish_fn_14+0x6b>
    1913:	mov    rdi,rbx
    1916:	jmp    1945 <botlish_fn_14+0x95>
    191b:	mov    QWORD PTR [r15+0x10],rax
    191f:	mov    rcx,rax
    1922:	mov    QWORD PTR [r15+0x18],rdx
    1926:	mov    r8,rdx
    1929:	mov    edx,0x1
    192e:	mov    rsi,r12
    1931:	mov    rdi,rbx
    1934:	call   1939 <botlish_fn_14+0x89>
			1935: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    1939:	test   rax,rax
    193c:	jne    1965 <botlish_fn_14+0xb5>
    1942:	mov    rdi,rbx
    1945:	mov    rdi,rbx
    1948:	mov    QWORD PTR [rdi],r15
    194b:	xor    rax,rax
    194e:	mov    rbx,QWORD PTR [rsp]
    1952:	mov    r12,QWORD PTR [rsp+0x8]
    1957:	mov    r15,QWORD PTR [rsp+0x10]
    195c:	add    rsp,0x20
    1960:	mov    rsp,rbp
    1963:	pop    rbp
    1964:	ret
    1965:	mov    rdi,rbx
    1968:	mov    QWORD PTR [rdi],r15
    196b:	mov    rbx,QWORD PTR [rsp]
    196f:	mov    r12,QWORD PTR [rsp+0x8]
    1974:	mov    r15,QWORD PTR [rsp+0x10]
    1979:	add    rsp,0x20
    197d:	mov    rsp,rbp
    1980:	pop    rbp
    1981:	ret
    1982:	mov    rbx,rdi
    1985:	call   198a <botlish_fn_14+0xda>
			1986: R_X86_64_PLT32	rt_stack_overflow-0x4
    198a:	xor    rax,rax
    198d:	mov    rbx,QWORD PTR [rsp]
    1991:	mov    r12,QWORD PTR [rsp+0x8]
    1996:	mov    r15,QWORD PTR [rsp+0x10]
    199b:	add    rsp,0x20
    199f:	mov    rsp,rbp
    19a2:	pop    rbp
    19a3:	ret

00000000000019a4 <botlish_entry_14: csv_parse<str>>:
    19a4:	push   rbp
    19a5:	mov    rbp,rsp
    19a8:	mov    rsi,QWORD PTR [rdx]
    19ab:	call   19b0 <botlish_entry_14+0xc>
			19ac: R_X86_64_PLT32	botlish_fn_14-0x4 ; csv_parse<str>
    19b0:	mov    rsp,rbp
    19b3:	pop    rbp
    19b4:	ret

; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 7334  (per function: 312 315 757 757 504 625 365 438 585 1141 352 641 388 154)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> chunked_new<generic>
;   botlish_fn_2 / botlish_entry_2 -> chunked_append<ChunkedBuilder, str>
;   botlish_fn_3 / botlish_entry_3 -> chunked_append<ChunkedBuilder, list>
;   botlish_fn_4 / botlish_entry_4 -> chunked_copy_chunks<list, int, mutarray, int>
;   botlish_fn_5 / botlish_entry_5 -> chunked_finish<ChunkedBuilder>
;   botlish_fn_6 / botlish_entry_6 -> peek<str, int>
;   botlish_fn_7 / botlish_entry_7 -> peek<str, int>
;   botlish_fn_8 / botlish_entry_8 -> scan_unquoted<str, int, int>
;   botlish_fn_9 / botlish_entry_9 -> scan_quoted<str, int, str>
;   botlish_fn_10 / botlish_entry_10 -> scan_field<str, int>
;   botlish_fn_11 / botlish_entry_11 -> scan_record<str, int, ChunkedBuilder>
;   botlish_fn_12 / botlish_entry_12 -> scan_records<str, int, ChunkedBuilder>
;   botlish_fn_13 / botlish_entry_13 -> csv_parse<str>


csv_chunked.asm.o:     file format elf64-x86-64


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
			1c: R_X86_64_PLT32	botlish_fn_13-0x4 ; csv_parse<str>
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

00000000000000f9 <botlish_fn_1: chunked_new<generic>>:
      f9:	push   rbp
      fa:	mov    rbp,rsp
      fd:	sub    rsp,0x60
     101:	mov    QWORD PTR [rsp+0x40],rbx
     106:	mov    QWORD PTR [rsp+0x48],r12
     10b:	mov    QWORD PTR [rsp+0x50],r13
     110:	mov    rbx,rdi
     113:	mov    QWORD PTR [rsp],0x0
     11b:	mov    QWORD PTR [rsp+0x8],0x0
     124:	mov    QWORD PTR [rsp+0x10],0x0
     12d:	mov    QWORD PTR [rsp+0x18],0x0
     136:	xor    rdx,rdx
     139:	mov    rdi,rbx
     13c:	mov    rsi,rdx
     13f:	call   144 <botlish_fn_1+0x4b>
			140: R_X86_64_PLT32	rt_list_new-0x4
     144:	test   rax,rax
     147:	je     1a8 <botlish_fn_1+0xaf>
     14d:	mov    QWORD PTR [rsp],rax
     151:	mov    r12,rax
     154:	mov    esi,0x81
     159:	mov    QWORD PTR [rsp+0x8],0x81
     162:	mov    rdi,rbx
     165:	call   16a <botlish_fn_1+0x71>
			166: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     16a:	test   rax,rax
     16d:	je     1a8 <botlish_fn_1+0xaf>
     173:	mov    QWORD PTR [rsp+0x8],rax
     178:	mov    r13,rax
     17b:	mov    esi,0x3
     180:	mov    QWORD PTR [rsp+0x10],0x3
     189:	mov    edx,0x1
     18e:	mov    QWORD PTR [rsp+0x18],0x1
     197:	mov    rdi,rbx
     19a:	call   19f <botlish_fn_1+0xa6>
			19b: R_X86_64_PLT32	rt_mutarray_create-0x4
     19f:	test   rax,rax
     1a2:	jne    1c3 <botlish_fn_1+0xca>
     1a8:	xor    rax,rax
     1ab:	mov    rbx,QWORD PTR [rsp+0x40]
     1b0:	mov    r12,QWORD PTR [rsp+0x48]
     1b5:	mov    r13,QWORD PTR [rsp+0x50]
     1ba:	add    rsp,0x60
     1be:	mov    rsp,rbp
     1c1:	pop    rbp
     1c2:	ret
     1c3:	mov    QWORD PTR [rsp+0x10],rax
     1c8:	lea    rcx,[rsp+0x20]
     1cd:	mov    rdx,r12
     1d0:	mov    QWORD PTR [rsp+0x20],rdx
     1d5:	mov    rdx,r13
     1d8:	mov    QWORD PTR [rsp+0x28],rdx
     1dd:	mov    QWORD PTR [rsp+0x30],rax
     1e2:	xor    rsi,rsi
     1e5:	mov    edx,0x3
     1ea:	mov    rdi,rbx
     1ed:	call   1f2 <botlish_fn_1+0xf9>
			1ee: R_X86_64_PLT32	rt_struct_new-0x4
     1f2:	mov    rbx,QWORD PTR [rsp+0x40]
     1f7:	mov    r12,QWORD PTR [rsp+0x48]
     1fc:	mov    r13,QWORD PTR [rsp+0x50]
     201:	add    rsp,0x60
     205:	mov    rsp,rbp
     208:	pop    rbp
     209:	ret

000000000000020a <botlish_entry_1: chunked_new<generic>>:
     20a:	push   rbp
     20b:	mov    rbp,rsp
     20e:	call   213 <botlish_entry_1+0x9>
			20f: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
     213:	mov    rsp,rbp
     216:	pop    rbp
     217:	ret

0000000000000218 <botlish_fn_2: chunked_append<ChunkedBuilder, str>>:
     218:	push   rbp
     219:	mov    rbp,rsp
     21c:	sub    rsp,0x70
     220:	mov    QWORD PTR [rsp+0x40],rbx
     225:	mov    QWORD PTR [rsp+0x48],r12
     22a:	mov    QWORD PTR [rsp+0x50],r13
     22f:	mov    QWORD PTR [rsp+0x58],r14
     234:	mov    QWORD PTR [rsp+0x60],r15
     239:	mov    r13,rdi
     23c:	mov    QWORD PTR [rsp+0x18],0x0
     245:	mov    QWORD PTR [rsp+0x20],0x0
     24e:	mov    QWORD PTR [rsp],rsi
     252:	mov    QWORD PTR [rsp+0x8],rdx
     257:	mov    r15,rdx
     25a:	mov    rax,QWORD PTR [rsi+0x18]
     25e:	mov    r14,rsi
     261:	mov    rsi,QWORD PTR [rax+0x10]
     265:	mov    edx,0x1
     26a:	mov    rdi,r13
     26d:	call   272 <botlish_fn_2+0x5a>
			26e: R_X86_64_PLT32	rt_mutarray_get-0x4
     272:	mov    rcx,rax
     275:	mov    r12,rax
     278:	test   rax,rcx
     27b:	je     436 <botlish_fn_2+0x21e>
     281:	mov    rax,r12
     284:	mov    QWORD PTR [rsp+0x8],rax
     289:	test   rax,0x1
     28f:	jne    2ba <botlish_fn_2+0xa2>
     295:	mov    edx,0x81
     29a:	mov    rsi,r12
     29d:	mov    rdi,r13
     2a0:	call   2a5 <botlish_fn_2+0x8d>
			2a1: R_X86_64_PLT32	rt_int_cmp-0x4
     2a5:	mov    ecx,0x2
     2aa:	test   rax,rax
     2ad:	cmove  rcx,QWORD PTR [rip+0x1fb]        # 4b0 <botlish_fn_2+0x298>
     2b5:	jmp    2ce <botlish_fn_2+0xb6>
     2ba:	mov    ecx,0x2
     2bf:	cmp    r12,0x81
     2c6:	cmove  rcx,QWORD PTR [rip+0x1e2]        # 4b0 <botlish_fn_2+0x298>
     2ce:	cmp    rcx,0x6
     2d2:	je     38e <botlish_fn_2+0x176>
     2d8:	mov    rbx,r14
     2db:	mov    rcx,QWORD PTR [rbx+0x18]
     2df:	mov    rsi,QWORD PTR [rcx+0x8]
     2e3:	mov    rcx,r15
     2e6:	mov    rdx,r12
     2e9:	mov    rdi,r13
     2ec:	call   2f1 <botlish_fn_2+0xd9>
			2ed: R_X86_64_PLT32	rt_mutarray_set-0x4
     2f1:	test   rax,rax
     2f4:	je     436 <botlish_fn_2+0x21e>
     2fa:	mov    rcx,QWORD PTR [rbx+0x18]
     2fe:	mov    r14,rbx
     301:	mov    rbx,QWORD PTR [rcx+0x10]
     305:	mov    QWORD PTR [rsp+0x10],rbx
     30a:	mov    QWORD PTR [rsp+0x18],0x1
     313:	mov    QWORD PTR [rsp+0x20],0x3
     31c:	test   r12,0x1
     323:	je     33d <botlish_fn_2+0x125>
     329:	mov    rcx,r12
     32c:	add    rcx,0x2
     330:	seto   r8b
     334:	test   r8b,r8b
     337:	je     350 <botlish_fn_2+0x138>
     33d:	mov    edx,0x3
     342:	mov    rsi,r12
     345:	mov    rdi,r13
     348:	call   34d <botlish_fn_2+0x135>
			349: R_X86_64_PLT32	rt_int_add-0x4
     34d:	mov    rcx,rax
     350:	mov    edx,0x1
     355:	mov    rsi,rbx
     358:	mov    rdi,r13
     35b:	call   360 <botlish_fn_2+0x148>
			35c: R_X86_64_PLT32	rt_mutarray_set-0x4
     360:	test   rax,rax
     363:	je     436 <botlish_fn_2+0x21e>
     369:	mov    rax,r14
     36c:	mov    rbx,QWORD PTR [rsp+0x40]
     371:	mov    r12,QWORD PTR [rsp+0x48]
     376:	mov    r13,QWORD PTR [rsp+0x50]
     37b:	mov    r14,QWORD PTR [rsp+0x58]
     380:	mov    r15,QWORD PTR [rsp+0x60]
     385:	add    rsp,0x70
     389:	mov    rsp,rbp
     38c:	pop    rbp
     38d:	ret
     38e:	mov    esi,0x81
     393:	mov    QWORD PTR [rsp+0x10],0x81
     39c:	mov    rdi,r13
     39f:	call   3a4 <botlish_fn_2+0x18c>
			3a0: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     3a4:	test   rax,rax
     3a7:	je     436 <botlish_fn_2+0x21e>
     3ad:	mov    QWORD PTR [rsp],rax
     3b1:	mov    r12,rax
     3b4:	mov    edx,0x1
     3b9:	mov    rcx,r15
     3bc:	mov    rsi,r12
     3bf:	mov    rdi,r13
     3c2:	call   3c7 <botlish_fn_2+0x1af>
			3c3: R_X86_64_PLT32	rt_mutarray_set-0x4
     3c7:	test   rax,rax
     3ca:	je     436 <botlish_fn_2+0x21e>
     3d0:	mov    rax,r14
     3d3:	mov    rax,QWORD PTR [rax+0x18]
     3d7:	mov    rsi,QWORD PTR [rax]
     3da:	mov    QWORD PTR [rsp+0x8],rsi
     3df:	mov    rax,r14
     3e2:	mov    rax,QWORD PTR [rax+0x18]
     3e6:	mov    rdx,QWORD PTR [rax+0x8]
     3ea:	mov    QWORD PTR [rsp+0x10],rdx
     3ef:	mov    rdi,r13
     3f2:	call   3f7 <botlish_fn_2+0x1df>
			3f3: R_X86_64_PLT32	rt_list_append-0x4
     3f7:	test   rax,rax
     3fa:	je     436 <botlish_fn_2+0x21e>
     400:	mov    QWORD PTR [rsp+0x8],rax
     405:	mov    r14,rax
     408:	mov    edx,0x3
     40d:	mov    rbx,rdx
     410:	mov    QWORD PTR [rsp+0x10],0x3
     419:	mov    QWORD PTR [rsp+0x18],0x3
     422:	mov    rsi,rbx
     425:	mov    rdi,r13
     428:	call   42d <botlish_fn_2+0x215>
			429: R_X86_64_PLT32	rt_mutarray_create-0x4
     42d:	test   rax,rax
     430:	jne    45b <botlish_fn_2+0x243>
     436:	xor    rax,rax
     439:	mov    rbx,QWORD PTR [rsp+0x40]
     43e:	mov    r12,QWORD PTR [rsp+0x48]
     443:	mov    r13,QWORD PTR [rsp+0x50]
     448:	mov    r14,QWORD PTR [rsp+0x58]
     44d:	mov    r15,QWORD PTR [rsp+0x60]
     452:	add    rsp,0x70
     456:	mov    rsp,rbp
     459:	pop    rbp
     45a:	ret
     45b:	mov    QWORD PTR [rsp+0x10],rax
     460:	lea    rcx,[rsp+0x28]
     465:	mov    rdx,r14
     468:	mov    QWORD PTR [rsp+0x28],rdx
     46d:	mov    rdx,r12
     470:	mov    QWORD PTR [rsp+0x30],rdx
     475:	mov    QWORD PTR [rsp+0x38],rax
     47a:	xor    rsi,rsi
     47d:	mov    rdx,rbx
     480:	mov    rdi,r13
     483:	call   488 <botlish_fn_2+0x270>
			484: R_X86_64_PLT32	rt_struct_new-0x4
     488:	mov    rbx,QWORD PTR [rsp+0x40]
     48d:	mov    r12,QWORD PTR [rsp+0x48]
     492:	mov    r13,QWORD PTR [rsp+0x50]
     497:	mov    r14,QWORD PTR [rsp+0x58]
     49c:	mov    r15,QWORD PTR [rsp+0x60]
     4a1:	add    rsp,0x70
     4a5:	mov    rsp,rbp
     4a8:	pop    rbp
     4a9:	ret
     4aa:	add    BYTE PTR [rax],al
     4ac:	add    BYTE PTR [rax],al
     4ae:	add    BYTE PTR [rax],al
     4b0:	(bad)
     4b1:	add    BYTE PTR [rax],al
     4b3:	add    BYTE PTR [rax],al
     4b5:	add    BYTE PTR [rax],al
	...

00000000000004b8 <botlish_entry_2: chunked_append<ChunkedBuilder, str>>:
     4b8:	push   rbp
     4b9:	mov    rbp,rsp
     4bc:	mov    rsi,QWORD PTR [rdx]
     4bf:	mov    rdx,QWORD PTR [rdx+0x8]
     4c3:	call   4c8 <botlish_entry_2+0x10>
			4c4: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<ChunkedBuilder, str>
     4c8:	mov    rsp,rbp
     4cb:	pop    rbp
     4cc:	ret
     4cd:	add    BYTE PTR [rax],al
	...

00000000000004d0 <botlish_fn_3: chunked_append<ChunkedBuilder, list>>:
     4d0:	push   rbp
     4d1:	mov    rbp,rsp
     4d4:	sub    rsp,0x70
     4d8:	mov    QWORD PTR [rsp+0x40],rbx
     4dd:	mov    QWORD PTR [rsp+0x48],r12
     4e2:	mov    QWORD PTR [rsp+0x50],r13
     4e7:	mov    QWORD PTR [rsp+0x58],r14
     4ec:	mov    QWORD PTR [rsp+0x60],r15
     4f1:	mov    r13,rdi
     4f4:	mov    QWORD PTR [rsp+0x18],0x0
     4fd:	mov    QWORD PTR [rsp+0x20],0x0
     506:	mov    QWORD PTR [rsp],rsi
     50a:	mov    QWORD PTR [rsp+0x8],rdx
     50f:	mov    r15,rdx
     512:	mov    rax,QWORD PTR [rsi+0x18]
     516:	mov    r14,rsi
     519:	mov    rsi,QWORD PTR [rax+0x10]
     51d:	mov    edx,0x1
     522:	mov    rdi,r13
     525:	call   52a <botlish_fn_3+0x5a>
			526: R_X86_64_PLT32	rt_mutarray_get-0x4
     52a:	mov    rcx,rax
     52d:	mov    r12,rax
     530:	test   rax,rcx
     533:	je     6ee <botlish_fn_3+0x21e>
     539:	mov    rax,r12
     53c:	mov    QWORD PTR [rsp+0x8],rax
     541:	test   rax,0x1
     547:	jne    572 <botlish_fn_3+0xa2>
     54d:	mov    edx,0x81
     552:	mov    rsi,r12
     555:	mov    rdi,r13
     558:	call   55d <botlish_fn_3+0x8d>
			559: R_X86_64_PLT32	rt_int_cmp-0x4
     55d:	mov    ecx,0x2
     562:	test   rax,rax
     565:	cmove  rcx,QWORD PTR [rip+0x1fb]        # 768 <botlish_fn_3+0x298>
     56d:	jmp    586 <botlish_fn_3+0xb6>
     572:	mov    ecx,0x2
     577:	cmp    r12,0x81
     57e:	cmove  rcx,QWORD PTR [rip+0x1e2]        # 768 <botlish_fn_3+0x298>
     586:	cmp    rcx,0x6
     58a:	je     646 <botlish_fn_3+0x176>
     590:	mov    rbx,r14
     593:	mov    rcx,QWORD PTR [rbx+0x18]
     597:	mov    rsi,QWORD PTR [rcx+0x8]
     59b:	mov    rcx,r15
     59e:	mov    rdx,r12
     5a1:	mov    rdi,r13
     5a4:	call   5a9 <botlish_fn_3+0xd9>
			5a5: R_X86_64_PLT32	rt_mutarray_set-0x4
     5a9:	test   rax,rax
     5ac:	je     6ee <botlish_fn_3+0x21e>
     5b2:	mov    rcx,QWORD PTR [rbx+0x18]
     5b6:	mov    r14,rbx
     5b9:	mov    rbx,QWORD PTR [rcx+0x10]
     5bd:	mov    QWORD PTR [rsp+0x10],rbx
     5c2:	mov    QWORD PTR [rsp+0x18],0x1
     5cb:	mov    QWORD PTR [rsp+0x20],0x3
     5d4:	test   r12,0x1
     5db:	je     5f5 <botlish_fn_3+0x125>
     5e1:	mov    rcx,r12
     5e4:	add    rcx,0x2
     5e8:	seto   r8b
     5ec:	test   r8b,r8b
     5ef:	je     608 <botlish_fn_3+0x138>
     5f5:	mov    edx,0x3
     5fa:	mov    rsi,r12
     5fd:	mov    rdi,r13
     600:	call   605 <botlish_fn_3+0x135>
			601: R_X86_64_PLT32	rt_int_add-0x4
     605:	mov    rcx,rax
     608:	mov    edx,0x1
     60d:	mov    rsi,rbx
     610:	mov    rdi,r13
     613:	call   618 <botlish_fn_3+0x148>
			614: R_X86_64_PLT32	rt_mutarray_set-0x4
     618:	test   rax,rax
     61b:	je     6ee <botlish_fn_3+0x21e>
     621:	mov    rax,r14
     624:	mov    rbx,QWORD PTR [rsp+0x40]
     629:	mov    r12,QWORD PTR [rsp+0x48]
     62e:	mov    r13,QWORD PTR [rsp+0x50]
     633:	mov    r14,QWORD PTR [rsp+0x58]
     638:	mov    r15,QWORD PTR [rsp+0x60]
     63d:	add    rsp,0x70
     641:	mov    rsp,rbp
     644:	pop    rbp
     645:	ret
     646:	mov    esi,0x81
     64b:	mov    QWORD PTR [rsp+0x10],0x81
     654:	mov    rdi,r13
     657:	call   65c <botlish_fn_3+0x18c>
			658: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     65c:	test   rax,rax
     65f:	je     6ee <botlish_fn_3+0x21e>
     665:	mov    QWORD PTR [rsp],rax
     669:	mov    r12,rax
     66c:	mov    edx,0x1
     671:	mov    rcx,r15
     674:	mov    rsi,r12
     677:	mov    rdi,r13
     67a:	call   67f <botlish_fn_3+0x1af>
			67b: R_X86_64_PLT32	rt_mutarray_set-0x4
     67f:	test   rax,rax
     682:	je     6ee <botlish_fn_3+0x21e>
     688:	mov    rax,r14
     68b:	mov    rax,QWORD PTR [rax+0x18]
     68f:	mov    rsi,QWORD PTR [rax]
     692:	mov    QWORD PTR [rsp+0x8],rsi
     697:	mov    rax,r14
     69a:	mov    rax,QWORD PTR [rax+0x18]
     69e:	mov    rdx,QWORD PTR [rax+0x8]
     6a2:	mov    QWORD PTR [rsp+0x10],rdx
     6a7:	mov    rdi,r13
     6aa:	call   6af <botlish_fn_3+0x1df>
			6ab: R_X86_64_PLT32	rt_list_append-0x4
     6af:	test   rax,rax
     6b2:	je     6ee <botlish_fn_3+0x21e>
     6b8:	mov    QWORD PTR [rsp+0x8],rax
     6bd:	mov    r14,rax
     6c0:	mov    edx,0x3
     6c5:	mov    rbx,rdx
     6c8:	mov    QWORD PTR [rsp+0x10],0x3
     6d1:	mov    QWORD PTR [rsp+0x18],0x3
     6da:	mov    rsi,rbx
     6dd:	mov    rdi,r13
     6e0:	call   6e5 <botlish_fn_3+0x215>
			6e1: R_X86_64_PLT32	rt_mutarray_create-0x4
     6e5:	test   rax,rax
     6e8:	jne    713 <botlish_fn_3+0x243>
     6ee:	xor    rax,rax
     6f1:	mov    rbx,QWORD PTR [rsp+0x40]
     6f6:	mov    r12,QWORD PTR [rsp+0x48]
     6fb:	mov    r13,QWORD PTR [rsp+0x50]
     700:	mov    r14,QWORD PTR [rsp+0x58]
     705:	mov    r15,QWORD PTR [rsp+0x60]
     70a:	add    rsp,0x70
     70e:	mov    rsp,rbp
     711:	pop    rbp
     712:	ret
     713:	mov    QWORD PTR [rsp+0x10],rax
     718:	lea    rcx,[rsp+0x28]
     71d:	mov    rdx,r14
     720:	mov    QWORD PTR [rsp+0x28],rdx
     725:	mov    rdx,r12
     728:	mov    QWORD PTR [rsp+0x30],rdx
     72d:	mov    QWORD PTR [rsp+0x38],rax
     732:	xor    rsi,rsi
     735:	mov    rdx,rbx
     738:	mov    rdi,r13
     73b:	call   740 <botlish_fn_3+0x270>
			73c: R_X86_64_PLT32	rt_struct_new-0x4
     740:	mov    rbx,QWORD PTR [rsp+0x40]
     745:	mov    r12,QWORD PTR [rsp+0x48]
     74a:	mov    r13,QWORD PTR [rsp+0x50]
     74f:	mov    r14,QWORD PTR [rsp+0x58]
     754:	mov    r15,QWORD PTR [rsp+0x60]
     759:	add    rsp,0x70
     75d:	mov    rsp,rbp
     760:	pop    rbp
     761:	ret
     762:	add    BYTE PTR [rax],al
     764:	add    BYTE PTR [rax],al
     766:	add    BYTE PTR [rax],al
     768:	(bad)
     769:	add    BYTE PTR [rax],al
     76b:	add    BYTE PTR [rax],al
     76d:	add    BYTE PTR [rax],al
	...

0000000000000770 <botlish_entry_3: chunked_append<ChunkedBuilder, list>>:
     770:	push   rbp
     771:	mov    rbp,rsp
     774:	mov    rsi,QWORD PTR [rdx]
     777:	mov    rdx,QWORD PTR [rdx+0x8]
     77b:	call   780 <botlish_entry_3+0x10>
			77c: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<ChunkedBuilder, list>
     780:	mov    rsp,rbp
     783:	pop    rbp
     784:	ret

0000000000000785 <botlish_fn_4: chunked_copy_chunks<list, int, mutarray, int>>:
     785:	push   rbp
     786:	mov    rbp,rsp
     789:	sub    rsp,0x50
     78d:	mov    QWORD PTR [rsp+0x20],rbx
     792:	mov    QWORD PTR [rsp+0x28],r12
     797:	mov    QWORD PTR [rsp+0x30],r13
     79c:	mov    QWORD PTR [rsp+0x38],r14
     7a1:	mov    QWORD PTR [rsp+0x40],r15
     7a6:	mov    r14,rdi
     7a9:	mov    QWORD PTR [rsp],rsi
     7ad:	mov    QWORD PTR [rsp+0x8],rcx
     7b2:	mov    r12,rcx
     7b5:	mov    QWORD PTR [rsp+0x10],r8
     7ba:	sar    rdx,1
     7bd:	mov    rbx,rdx
     7c0:	mov    r13,rsi
     7c3:	mov    r15,r8
     7c6:	mov    rsi,r13
     7c9:	mov    rdi,r14
     7cc:	call   7d1 <botlish_fn_4+0x4c>
			7cd: R_X86_64_PLT32	rt_list_len-0x4
     7d1:	sar    rax,1
     7d4:	cmp    rbx,rax
     7d7:	jge    912 <botlish_fn_4+0x18d>
     7dd:	mov    rdx,QWORD PTR [r13+0x8]
     7e1:	mov    rcx,rbx
     7e4:	shl    rcx,1
     7e7:	or     rcx,0x1
     7eb:	sar    rcx,1
     7ee:	cmp    rcx,rdx
     7f1:	jb     81d <botlish_fn_4+0x98>
     7f7:	mov    rdx,rbx
     7fa:	shl    rdx,1
     7fd:	or     rdx,0x1
     801:	mov    rsi,r13
     804:	mov    rdi,r14
     807:	call   80c <botlish_fn_4+0x87>
			808: R_X86_64_PLT32	rt_list_get-0x4
     80c:	test   rax,rax
     80f:	je     888 <botlish_fn_4+0x103>
     815:	mov    rsi,rax
     818:	jmp    828 <botlish_fn_4+0xa3>
     81d:	mov    rax,QWORD PTR [r13+0x10]
     821:	mov    rax,QWORD PTR [rax+rcx*8]
     825:	mov    rsi,rax
     828:	xor    ecx,ecx
     82a:	test   rsi,0x7
     831:	jne    840 <botlish_fn_4+0xbb>
     837:	movzx  rax,BYTE PTR [rsi]
     83b:	cmp    al,0x8
     83d:	sete   cl
     840:	test   cl,cl
     842:	jne    862 <botlish_fn_4+0xdd>
     848:	mov    rdi,r14
     84b:	mov    rax,QWORD PTR [rdi+0x10]
     84f:	mov    rcx,QWORD PTR [rax+0x8]
     853:	mov    edx,0x8
     858:	call   85d <botlish_fn_4+0xd8>
			859: R_X86_64_PLT32	rt_type_error-0x4
     85d:	jmp    888 <botlish_fn_4+0x103>
     862:	mov    rcx,rsi
     865:	mov    r8d,0x1
     86b:	mov    r9d,0x81
     871:	mov    rdx,r15
     874:	mov    rsi,r12
     877:	mov    rdi,r14
     87a:	call   87f <botlish_fn_4+0xfa>
			87b: R_X86_64_PLT32	rt_mutarray_copy-0x4
     87f:	test   rax,rax
     882:	jne    8ad <botlish_fn_4+0x128>
     888:	xor    rax,rax
     88b:	mov    rbx,QWORD PTR [rsp+0x20]
     890:	mov    r12,QWORD PTR [rsp+0x28]
     895:	mov    r13,QWORD PTR [rsp+0x30]
     89a:	mov    r14,QWORD PTR [rsp+0x38]
     89f:	mov    r15,QWORD PTR [rsp+0x40]
     8a4:	add    rsp,0x50
     8a8:	mov    rsp,rbp
     8ab:	pop    rbp
     8ac:	ret
     8ad:	mov    QWORD PTR [rsp+0x18],0x81
     8b6:	mov    rsi,r15
     8b9:	test   rsi,0x1
     8c0:	je     8e5 <botlish_fn_4+0x160>
     8c6:	mov    rdi,rsi
     8c9:	add    rdi,0x80
     8d0:	seto   r9b
     8d4:	test   r9b,r9b
     8d7:	jne    8e5 <botlish_fn_4+0x160>
     8dd:	mov    rsi,rdi
     8e0:	jmp    8f5 <botlish_fn_4+0x170>
     8e5:	mov    edx,0x81
     8ea:	mov    rdi,r14
     8ed:	call   8f2 <botlish_fn_4+0x16d>
			8ee: R_X86_64_PLT32	rt_int_add-0x4
     8f2:	mov    rsi,rax
     8f5:	mov    QWORD PTR [rsp],r13
     8f9:	mov    QWORD PTR [rsp+0x8],r12
     8fe:	mov    QWORD PTR [rsp+0x10],rsi
     903:	add    rbx,0x1
     90a:	mov    r15,rsi
     90d:	jmp    7c6 <botlish_fn_4+0x41>
     912:	mov    rax,r12
     915:	mov    rbx,QWORD PTR [rsp+0x20]
     91a:	mov    r12,QWORD PTR [rsp+0x28]
     91f:	mov    r13,QWORD PTR [rsp+0x30]
     924:	mov    r14,QWORD PTR [rsp+0x38]
     929:	mov    r15,QWORD PTR [rsp+0x40]
     92e:	add    rsp,0x50
     932:	mov    rsp,rbp
     935:	pop    rbp
     936:	ret

0000000000000937 <botlish_entry_4: chunked_copy_chunks<list, int, mutarray, int>>:
     937:	push   rbp
     938:	mov    rbp,rsp
     93b:	mov    rsi,QWORD PTR [rdx]
     93e:	mov    r9,QWORD PTR [rdx+0x8]
     942:	mov    rcx,QWORD PTR [rdx+0x10]
     946:	mov    r8,QWORD PTR [rdx+0x18]
     94a:	mov    rdx,r9
     94d:	call   952 <botlish_entry_4+0x1b>
			94e: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_copy_chunks<list, int, mutarray, int>
     952:	mov    rsp,rbp
     955:	pop    rbp
     956:	ret
	...

0000000000000958 <botlish_fn_5: chunked_finish<ChunkedBuilder>>:
     958:	push   rbp
     959:	mov    rbp,rsp
     95c:	sub    rsp,0x80
     963:	mov    QWORD PTR [rsp+0x50],rbx
     968:	mov    QWORD PTR [rsp+0x58],r12
     96d:	mov    QWORD PTR [rsp+0x60],r13
     972:	mov    QWORD PTR [rsp+0x68],r14
     977:	mov    QWORD PTR [rsp+0x70],r15
     97c:	mov    r14,rdi
     97f:	mov    QWORD PTR [rsp+0x20],0x0
     988:	mov    QWORD PTR [rsp+0x28],0x0
     991:	mov    QWORD PTR [rsp+0x30],0x0
     99a:	mov    QWORD PTR [rsp+0x38],0x0
     9a3:	mov    QWORD PTR [rsp],rsi
     9a7:	mov    rax,QWORD PTR [rsi+0x18]
     9ab:	mov    rbx,rsi
     9ae:	mov    rsi,QWORD PTR [rax+0x10]
     9b2:	mov    edx,0x1
     9b7:	mov    rdi,r14
     9ba:	call   9bf <botlish_fn_5+0x67>
			9bb: R_X86_64_PLT32	rt_mutarray_get-0x4
     9bf:	test   rax,rax
     9c2:	je     b2a <botlish_fn_5+0x1d2>
     9c8:	mov    QWORD PTR [rsp+0x8],rax
     9cd:	mov    r13,rax
     9d0:	mov    rax,QWORD PTR [rbx+0x18]
     9d4:	mov    rsi,QWORD PTR [rax]
     9d7:	mov    rdi,r14
     9da:	call   9df <botlish_fn_5+0x87>
			9db: R_X86_64_PLT32	rt_list_len-0x4
     9df:	mov    QWORD PTR [rsp+0x10],rax
     9e4:	mov    QWORD PTR [rsp+0x18],0x81
     9ed:	test   rax,0x1
     9f3:	mov    rsi,rax
     9f6:	je     a23 <botlish_fn_5+0xcb>
     9fc:	mov    rcx,rsi
     9ff:	mov    rax,rcx
     a02:	sar    rax,1
     a05:	imul   QWORD PTR [rip+0x16c]        # b78 <botlish_fn_5+0x220>
     a0c:	seto   cl
     a0f:	or     rax,0x1
     a13:	test   cl,cl
     a15:	jne    a23 <botlish_fn_5+0xcb>
     a1b:	mov    rdx,rax
     a1e:	jmp    a33 <botlish_fn_5+0xdb>
     a23:	mov    edx,0x81
     a28:	mov    rdi,r14
     a2b:	call   a30 <botlish_fn_5+0xd8>
			a2c: R_X86_64_PLT32	rt_int_mul-0x4
     a30:	mov    rdx,rax
     a33:	mov    QWORD PTR [rsp+0x10],rdx
     a38:	mov    rax,rdx
     a3b:	and    rax,r13
     a3e:	test   rax,0x1
     a44:	jne    a52 <botlish_fn_5+0xfa>
     a4a:	mov    r15,rdx
     a4d:	jmp    a6a <botlish_fn_5+0x112>
     a52:	lea    rcx,[r13-0x1]
     a56:	mov    r12,rdx
     a59:	add    r12,rcx
     a5c:	mov    r15,rdx
     a5f:	seto   al
     a62:	test   al,al
     a64:	je     a7b <botlish_fn_5+0x123>
     a6a:	mov    rdx,r13
     a6d:	mov    rsi,r15
     a70:	mov    rdi,r14
     a73:	call   a78 <botlish_fn_5+0x120>
			a74: R_X86_64_PLT32	rt_int_add-0x4
     a78:	mov    r12,rax
     a7b:	mov    QWORD PTR [rsp+0x18],r12
     a80:	mov    rcx,QWORD PTR [rbx+0x18]
     a84:	mov    rsi,QWORD PTR [rcx]
     a87:	mov    QWORD PTR [rsp+0x20],rsi
     a8c:	mov    QWORD PTR [rsp+0x40],rsi
     a91:	mov    QWORD PTR [rsp+0x28],0x1
     a9a:	mov    rsi,r12
     a9d:	mov    rdi,r14
     aa0:	call   aa5 <botlish_fn_5+0x14d>
			aa1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     aa5:	test   rax,rax
     aa8:	je     b2a <botlish_fn_5+0x1d2>
     aae:	mov    QWORD PTR [rsp+0x30],rax
     ab3:	mov    rcx,rax
     ab6:	mov    r8d,0x1
     abc:	mov    QWORD PTR [rsp+0x38],0x1
     ac5:	mov    rsi,QWORD PTR [rsp+0x40]
     aca:	mov    rdi,r14
     acd:	mov    rdx,r8
     ad0:	call   ad5 <botlish_fn_5+0x17d>
			ad1: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_copy_chunks<list, int, mutarray, int>
     ad5:	test   rax,rax
     ad8:	je     b2a <botlish_fn_5+0x1d2>
     ade:	mov    QWORD PTR [rsp],rax
     ae2:	mov    QWORD PTR [rsp+0x40],rax
     ae7:	mov    rcx,QWORD PTR [rbx+0x18]
     aeb:	mov    rcx,QWORD PTR [rcx+0x8]
     aef:	mov    r8d,0x1
     af5:	mov    rdx,r15
     af8:	mov    r9,r13
     afb:	mov    rsi,QWORD PTR [rsp+0x40]
     b00:	mov    rdi,r14
     b03:	call   b08 <botlish_fn_5+0x1b0>
			b04: R_X86_64_PLT32	rt_mutarray_copy-0x4
     b08:	test   rax,rax
     b0b:	je     b2a <botlish_fn_5+0x1d2>
     b11:	mov    rdx,r12
     b14:	mov    rsi,QWORD PTR [rsp+0x40]
     b19:	mov    rdi,r14
     b1c:	call   b21 <botlish_fn_5+0x1c9>
			b1d: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     b21:	test   rax,rax
     b24:	jne    b52 <botlish_fn_5+0x1fa>
     b2a:	xor    rax,rax
     b2d:	mov    rbx,QWORD PTR [rsp+0x50]
     b32:	mov    r12,QWORD PTR [rsp+0x58]
     b37:	mov    r13,QWORD PTR [rsp+0x60]
     b3c:	mov    r14,QWORD PTR [rsp+0x68]
     b41:	mov    r15,QWORD PTR [rsp+0x70]
     b46:	add    rsp,0x80
     b4d:	mov    rsp,rbp
     b50:	pop    rbp
     b51:	ret
     b52:	mov    rbx,QWORD PTR [rsp+0x50]
     b57:	mov    r12,QWORD PTR [rsp+0x58]
     b5c:	mov    r13,QWORD PTR [rsp+0x60]
     b61:	mov    r14,QWORD PTR [rsp+0x68]
     b66:	mov    r15,QWORD PTR [rsp+0x70]
     b6b:	add    rsp,0x80
     b72:	mov    rsp,rbp
     b75:	pop    rbp
     b76:	ret
     b77:	add    BYTE PTR [rax+0x0],al
     b7d:	add    BYTE PTR [rax],al
	...

0000000000000b80 <botlish_entry_5: chunked_finish<ChunkedBuilder>>:
     b80:	push   rbp
     b81:	mov    rbp,rsp
     b84:	mov    rsi,QWORD PTR [rdx]
     b87:	call   b8c <botlish_entry_5+0xc>
			b88: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_finish<ChunkedBuilder>
     b8c:	mov    rsp,rbp
     b8f:	pop    rbp
     b90:	ret
     b91:	add    BYTE PTR [rax],al
     b93:	add    BYTE PTR [rax],al
     b95:	add    BYTE PTR [rax],al
	...

0000000000000b98 <botlish_fn_6: peek<str, int>>:
     b98:	push   rbp
     b99:	mov    rbp,rsp
     b9c:	sub    rsp,0x40
     ba0:	mov    QWORD PTR [rsp+0x20],rbx
     ba5:	mov    QWORD PTR [rsp+0x28],r12
     baa:	mov    QWORD PTR [rsp+0x30],r13
     baf:	mov    rbx,rdx
     bb2:	mov    r13,rdi
     bb5:	mov    QWORD PTR [rsp],rsi
     bb9:	mov    QWORD PTR [rsp+0x8],rdx
     bbe:	mov    rdx,QWORD PTR [rsi+0x8]
     bc2:	mov    r12,rsi
     bc5:	shl    rdx,1
     bc8:	mov    rax,rdx
     bcb:	or     rax,0x1
     bcf:	mov    rcx,rbx
     bd2:	and    rcx,rax
     bd5:	test   rcx,0x1
     bdc:	jne    c06 <botlish_fn_6+0x6e>
     be2:	or     rdx,0x1
     be6:	mov    rsi,rbx
     be9:	mov    rdi,r13
     bec:	call   bf1 <botlish_fn_6+0x59>
			bed: R_X86_64_PLT32	rt_int_cmp-0x4
     bf1:	mov    ecx,0x2
     bf6:	test   rax,rax
     bf9:	cmovge rcx,QWORD PTR [rip+0xd7]        # cd8 <botlish_fn_6+0x140>
     c01:	jmp    c1a <botlish_fn_6+0x82>
     c06:	or     rdx,0x1
     c0a:	mov    ecx,0x2
     c0f:	cmp    rbx,rdx
     c12:	cmovge rcx,QWORD PTR [rip+0xbe]        # cd8 <botlish_fn_6+0x140>
     c1a:	cmp    rcx,0x6
     c1e:	je     cae <botlish_fn_6+0x116>
     c24:	mov    QWORD PTR [rsp+0x10],0x3
     c2d:	test   rbx,0x1
     c34:	je     c4c <botlish_fn_6+0xb4>
     c3a:	mov    rcx,rbx
     c3d:	add    rcx,0x2
     c41:	seto   al
     c44:	test   al,al
     c46:	je     c5f <botlish_fn_6+0xc7>
     c4c:	mov    edx,0x3
     c51:	mov    rsi,rbx
     c54:	mov    rdi,r13
     c57:	call   c5c <botlish_fn_6+0xc4>
			c58: R_X86_64_PLT32	rt_int_add-0x4
     c5c:	mov    rcx,rax
     c5f:	mov    QWORD PTR [rsp+0x10],rcx
     c64:	mov    rdx,rbx
     c67:	mov    rsi,r12
     c6a:	mov    rdi,r13
     c6d:	call   c72 <botlish_fn_6+0xda>
			c6e: R_X86_64_PLT32	rt_substr-0x4
     c72:	test   rax,rax
     c75:	jne    c96 <botlish_fn_6+0xfe>
     c7b:	xor    rax,rax
     c7e:	mov    rbx,QWORD PTR [rsp+0x20]
     c83:	mov    r12,QWORD PTR [rsp+0x28]
     c88:	mov    r13,QWORD PTR [rsp+0x30]
     c8d:	add    rsp,0x40
     c91:	mov    rsp,rbp
     c94:	pop    rbp
     c95:	ret
     c96:	mov    rbx,QWORD PTR [rsp+0x20]
     c9b:	mov    r12,QWORD PTR [rsp+0x28]
     ca0:	mov    r13,QWORD PTR [rsp+0x30]
     ca5:	add    rsp,0x40
     ca9:	mov    rsp,rbp
     cac:	pop    rbp
     cad:	ret
     cae:	mov    rdi,r13
     cb1:	mov    rax,QWORD PTR [rdi+0x10]
     cb5:	mov    rax,QWORD PTR [rax+0x10]
     cb9:	mov    rbx,QWORD PTR [rsp+0x20]
     cbe:	mov    r12,QWORD PTR [rsp+0x28]
     cc3:	mov    r13,QWORD PTR [rsp+0x30]
     cc8:	add    rsp,0x40
     ccc:	mov    rsp,rbp
     ccf:	pop    rbp
     cd0:	ret
     cd1:	add    BYTE PTR [rax],al
     cd3:	add    BYTE PTR [rax],al
     cd5:	add    BYTE PTR [rax],al
     cd7:	add    BYTE PTR [rsi],al
     cd9:	add    BYTE PTR [rax],al
     cdb:	add    BYTE PTR [rax],al
     cdd:	add    BYTE PTR [rax],al
	...

0000000000000ce0 <botlish_entry_6: peek<str, int>>:
     ce0:	push   rbp
     ce1:	mov    rbp,rsp
     ce4:	mov    rsi,QWORD PTR [rdx]
     ce7:	mov    rdx,QWORD PTR [rdx+0x8]
     ceb:	call   cf0 <botlish_entry_6+0x10>
			cec: R_X86_64_PLT32	botlish_fn_6-0x4 ; peek<str, int>
     cf0:	mov    rsp,rbp
     cf3:	pop    rbp
     cf4:	ret
     cf5:	add    BYTE PTR [rax],al
	...

0000000000000cf8 <botlish_fn_7: peek<str, int>>:
     cf8:	push   rbp
     cf9:	mov    rbp,rsp
     cfc:	sub    rsp,0x50
     d00:	mov    QWORD PTR [rsp+0x20],rbx
     d05:	mov    QWORD PTR [rsp+0x28],r12
     d0a:	mov    QWORD PTR [rsp+0x30],r13
     d0f:	mov    QWORD PTR [rsp+0x38],r14
     d14:	mov    QWORD PTR [rsp+0x40],r15
     d19:	mov    rbx,rdx
     d1c:	mov    r12,rcx
     d1f:	mov    r14,rdi
     d22:	mov    QWORD PTR [rsp],rsi
     d26:	mov    QWORD PTR [rsp+0x8],rdx
     d2b:	mov    rdx,QWORD PTR [rsi+0x8]
     d2f:	mov    r13,rsi
     d32:	shl    rdx,1
     d35:	mov    rax,rdx
     d38:	or     rax,0x1
     d3c:	mov    rcx,rbx
     d3f:	and    rcx,rax
     d42:	test   rcx,0x1
     d49:	jne    d73 <botlish_fn_7+0x7b>
     d4f:	or     rdx,0x1
     d53:	mov    rsi,rbx
     d56:	mov    rdi,r14
     d59:	call   d5e <botlish_fn_7+0x66>
			d5a: R_X86_64_PLT32	rt_int_cmp-0x4
     d5e:	mov    ecx,0x2
     d63:	test   rax,rax
     d66:	cmovge rcx,QWORD PTR [rip+0x122]        # e90 <botlish_fn_7+0x198>
     d6e:	jmp    d87 <botlish_fn_7+0x8f>
     d73:	or     rdx,0x1
     d77:	mov    ecx,0x2
     d7c:	cmp    rbx,rdx
     d7f:	cmovge rcx,QWORD PTR [rip+0x109]        # e90 <botlish_fn_7+0x198>
     d87:	cmp    rcx,0x6
     d8b:	je     e4b <botlish_fn_7+0x153>
     d91:	mov    QWORD PTR [rsp+0x10],0x3
     d9a:	test   rbx,0x1
     da1:	je     dc4 <botlish_fn_7+0xcc>
     da7:	mov    rax,rbx
     daa:	add    rax,0x2
     dae:	seto   cl
     db1:	test   cl,cl
     db3:	jne    dc4 <botlish_fn_7+0xcc>
     db9:	mov    rdi,r14
     dbc:	mov    r15,rax
     dbf:	jmp    dda <botlish_fn_7+0xe2>
     dc4:	mov    edx,0x3
     dc9:	mov    rsi,rbx
     dcc:	mov    rdi,r14
     dcf:	call   dd4 <botlish_fn_7+0xdc>
			dd0: R_X86_64_PLT32	rt_int_add-0x4
     dd4:	mov    r15,rax
     dd7:	mov    rdi,r14
     dda:	mov    rdi,r14
     ddd:	mov    rcx,r15
     de0:	mov    rdx,rbx
     de3:	mov    rsi,r13
     de6:	call   deb <botlish_fn_7+0xf3>
			de7: R_X86_64_PLT32	rt_str_region_check-0x4
     deb:	test   rax,rax
     dee:	jne    e19 <botlish_fn_7+0x121>
     df4:	xor    rax,rax
     df7:	mov    rbx,QWORD PTR [rsp+0x20]
     dfc:	mov    r12,QWORD PTR [rsp+0x28]
     e01:	mov    r13,QWORD PTR [rsp+0x30]
     e06:	mov    r14,QWORD PTR [rsp+0x38]
     e0b:	mov    r15,QWORD PTR [rsp+0x40]
     e10:	add    rsp,0x50
     e14:	mov    rsp,rbp
     e17:	pop    rbp
     e18:	ret
     e19:	mov    rcx,r12
     e1c:	mov    QWORD PTR [rcx],rbx
     e1f:	mov    rax,r15
     e22:	mov    QWORD PTR [rcx+0x8],rax
     e26:	mov    rax,r13
     e29:	mov    rbx,QWORD PTR [rsp+0x20]
     e2e:	mov    r12,QWORD PTR [rsp+0x28]
     e33:	mov    r13,QWORD PTR [rsp+0x30]
     e38:	mov    r14,QWORD PTR [rsp+0x38]
     e3d:	mov    r15,QWORD PTR [rsp+0x40]
     e42:	add    rsp,0x50
     e46:	mov    rsp,rbp
     e49:	pop    rbp
     e4a:	ret
     e4b:	mov    rcx,r12
     e4e:	mov    rdi,r14
     e51:	mov    rax,QWORD PTR [rdi+0x10]
     e55:	mov    rax,QWORD PTR [rax+0x10]
     e59:	mov    QWORD PTR [rcx],0x1
     e60:	mov    QWORD PTR [rcx+0x8],0x1
     e68:	mov    rbx,QWORD PTR [rsp+0x20]
     e6d:	mov    r12,QWORD PTR [rsp+0x28]
     e72:	mov    r13,QWORD PTR [rsp+0x30]
     e77:	mov    r14,QWORD PTR [rsp+0x38]
     e7c:	mov    r15,QWORD PTR [rsp+0x40]
     e81:	add    rsp,0x50
     e85:	mov    rsp,rbp
     e88:	pop    rbp
     e89:	ret
     e8a:	add    BYTE PTR [rax],al
     e8c:	add    BYTE PTR [rax],al
     e8e:	add    BYTE PTR [rax],al
     e90:	(bad)
     e91:	add    BYTE PTR [rax],al
     e93:	add    BYTE PTR [rax],al
     e95:	add    BYTE PTR [rax],al
	...

0000000000000e98 <botlish_entry_7: peek<str, int>>:
     e98:	push   rbp
     e99:	mov    rbp,rsp
     e9c:	ud2

0000000000000e9e <botlish_fn_8: scan_unquoted<str, int, int>>:
     e9e:	push   rbp
     e9f:	mov    rbp,rsp
     ea2:	sub    rsp,0x80
     ea9:	mov    QWORD PTR [rsp+0x50],rbx
     eae:	mov    QWORD PTR [rsp+0x58],r12
     eb3:	mov    QWORD PTR [rsp+0x60],r13
     eb8:	mov    QWORD PTR [rsp+0x68],r14
     ebd:	mov    QWORD PTR [rsp+0x70],r15
     ec2:	mov    QWORD PTR [rsp+0x30],rdi
     ec7:	mov    QWORD PTR [rsp+0x18],0x0
     ed0:	mov    QWORD PTR [rsp],rsi
     ed4:	mov    r15,rsi
     ed7:	mov    QWORD PTR [rsp+0x8],rdx
     edc:	mov    r14,rdx
     edf:	mov    QWORD PTR [rsp+0x10],rcx
     ee4:	lea    r13,[rsp+0x20]
     ee9:	mov    QWORD PTR [rsp+0x38],rcx
     eee:	mov    rcx,r13
     ef1:	mov    rdx,QWORD PTR [rsp+0x38]
     ef6:	mov    rsi,r15
     ef9:	mov    rdi,QWORD PTR [rsp+0x30]
     efe:	call   f03 <botlish_fn_8+0x65>
			eff: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
     f03:	mov    rsi,rax
     f06:	mov    QWORD PTR [rsp+0x40],rax
     f0b:	test   rax,rsi
     f0e:	je     1068 <botlish_fn_8+0x1ca>
     f14:	mov    rbx,QWORD PTR [rsp+0x20]
     f19:	mov    r12,QWORD PTR [rsp+0x28]
     f1e:	mov    rdi,QWORD PTR [rsp+0x30]
     f23:	mov    rcx,QWORD PTR [rdi+0x10]
     f27:	mov    r8,QWORD PTR [rcx+0x10]
     f2b:	mov    rcx,r12
     f2e:	mov    rdx,rbx
     f31:	mov    rsi,QWORD PTR [rsp+0x40]
     f36:	call   f3b <botlish_fn_8+0x9d>
			f37: R_X86_64_PLT32	rt_str_region_eq-0x4
     f3b:	cmp    rax,0x6
     f3f:	je     f80 <botlish_fn_8+0xe2>
     f45:	mov    rdi,QWORD PTR [rsp+0x30]
     f4a:	mov    rax,QWORD PTR [rdi+0x10]
     f4e:	mov    r8,QWORD PTR [rax+0x18]
     f52:	mov    rcx,r12
     f55:	mov    rdx,rbx
     f58:	mov    rsi,QWORD PTR [rsp+0x40]
     f5d:	call   f62 <botlish_fn_8+0xc4>
			f5e: R_X86_64_PLT32	rt_str_region_eq-0x4
     f62:	cmp    rax,0x6
     f66:	je     f76 <botlish_fn_8+0xd8>
     f6c:	mov    eax,0x2
     f71:	jmp    f85 <botlish_fn_8+0xe7>
     f76:	mov    eax,0x6
     f7b:	jmp    f85 <botlish_fn_8+0xe7>
     f80:	mov    eax,0x6
     f85:	cmp    rax,0x6
     f89:	je     fca <botlish_fn_8+0x12c>
     f8f:	mov    rdi,QWORD PTR [rsp+0x30]
     f94:	mov    rax,QWORD PTR [rdi+0x10]
     f98:	mov    r8,QWORD PTR [rax+0x20]
     f9c:	mov    rcx,r12
     f9f:	mov    rdx,rbx
     fa2:	mov    rsi,QWORD PTR [rsp+0x40]
     fa7:	call   fac <botlish_fn_8+0x10e>
			fa8: R_X86_64_PLT32	rt_str_region_eq-0x4
     fac:	cmp    rax,0x6
     fb0:	je     fc0 <botlish_fn_8+0x122>
     fb6:	mov    eax,0x2
     fbb:	jmp    fcf <botlish_fn_8+0x131>
     fc0:	mov    eax,0x6
     fc5:	jmp    fcf <botlish_fn_8+0x131>
     fca:	mov    eax,0x6
     fcf:	cmp    rax,0x6
     fd3:	je     104a <botlish_fn_8+0x1ac>
     fd9:	mov    QWORD PTR [rsp+0x18],0x3
     fe2:	mov    rsi,QWORD PTR [rsp+0x38]
     fe7:	test   rsi,0x1
     fee:	je     1015 <botlish_fn_8+0x177>
     ff4:	mov    rsi,QWORD PTR [rsp+0x38]
     ff9:	mov    rax,rsi
     ffc:	add    rax,0x2
    1000:	seto   sil
    1004:	test   sil,sil
    1007:	jne    1015 <botlish_fn_8+0x177>
    100d:	mov    rsi,r15
    1010:	jmp    102c <botlish_fn_8+0x18e>
    1015:	mov    edx,0x3
    101a:	mov    rsi,QWORD PTR [rsp+0x38]
    101f:	mov    rdi,QWORD PTR [rsp+0x30]
    1024:	call   1029 <botlish_fn_8+0x18b>
			1025: R_X86_64_PLT32	rt_int_add-0x4
    1029:	mov    rsi,r15
    102c:	mov    QWORD PTR [rsp],rsi
    1030:	mov    rdx,r14
    1033:	mov    QWORD PTR [rsp+0x8],rdx
    1038:	mov    QWORD PTR [rsp+0x10],rax
    103d:	mov    r15,rsi
    1040:	mov    QWORD PTR [rsp+0x38],rax
    1045:	jmp    eee <botlish_fn_8+0x50>
    104a:	mov    rdx,r14
    104d:	mov    rsi,r15
    1050:	mov    rdi,QWORD PTR [rsp+0x30]
    1055:	mov    rcx,QWORD PTR [rsp+0x38]
    105a:	call   105f <botlish_fn_8+0x1c1>
			105b: R_X86_64_PLT32	rt_substr-0x4
    105f:	test   rax,rax
    1062:	jne    1093 <botlish_fn_8+0x1f5>
    1068:	xor    rdx,rdx
    106b:	mov    rax,rdx
    106e:	mov    rbx,QWORD PTR [rsp+0x50]
    1073:	mov    r12,QWORD PTR [rsp+0x58]
    1078:	mov    r13,QWORD PTR [rsp+0x60]
    107d:	mov    r14,QWORD PTR [rsp+0x68]
    1082:	mov    r15,QWORD PTR [rsp+0x70]
    1087:	add    rsp,0x80
    108e:	mov    rsp,rbp
    1091:	pop    rbp
    1092:	ret
    1093:	mov    rdx,QWORD PTR [rsp+0x38]
    1098:	mov    rbx,QWORD PTR [rsp+0x50]
    109d:	mov    r12,QWORD PTR [rsp+0x58]
    10a2:	mov    r13,QWORD PTR [rsp+0x60]
    10a7:	mov    r14,QWORD PTR [rsp+0x68]
    10ac:	mov    r15,QWORD PTR [rsp+0x70]
    10b1:	add    rsp,0x80
    10b8:	mov    rsp,rbp
    10bb:	pop    rbp
    10bc:	ret

00000000000010bd <botlish_entry_8: scan_unquoted<str, int, int>>:
    10bd:	push   rbp
    10be:	mov    rbp,rsp
    10c1:	ud2

00000000000010c3 <botlish_fn_9: scan_quoted<str, int, str>>:
    10c3:	push   rbp
    10c4:	mov    rbp,rsp
    10c7:	sub    rsp,0xd0
    10ce:	mov    QWORD PTR [rsp+0xa0],rbx
    10d6:	mov    QWORD PTR [rsp+0xa8],r12
    10de:	mov    QWORD PTR [rsp+0xb0],r13
    10e6:	mov    QWORD PTR [rsp+0xb8],r14
    10ee:	mov    QWORD PTR [rsp+0xc0],r15
    10f6:	mov    QWORD PTR [rsp+0x88],rdi
    10fe:	mov    QWORD PTR [rsp+0x18],0x0
    1107:	mov    QWORD PTR [rsp+0x20],0x0
    1110:	mov    QWORD PTR [rsp],rsi
    1114:	mov    QWORD PTR [rsp+0x8],rdx
    1119:	mov    QWORD PTR [rsp+0x10],rcx
    111e:	mov    r13,rcx
    1121:	lea    r14,[rsp+0x68]
    1126:	lea    rbx,[rsp+0x28]
    112b:	mov    r12,rsi
    112e:	mov    QWORD PTR [rsp+0x90],rdx
    1136:	mov    rdx,QWORD PTR [rsp+0x90]
    113e:	mov    rsi,r12
    1141:	mov    rdi,QWORD PTR [rsp+0x88]
    1149:	call   114e <botlish_fn_9+0x8b>
			114a: R_X86_64_PLT32	botlish_fn_6-0x4 ; peek<str, int>
    114e:	test   rax,rax
    1151:	je     149a <botlish_fn_9+0x3d7>
    1157:	mov    QWORD PTR [rsp+0x18],rax
    115c:	mov    rsi,QWORD PTR [rax+0x8]
    1160:	mov    rcx,rax
    1163:	mov    rax,0xffffffffffffffff
    116a:	test   rsi,rsi
    116d:	jne    117b <botlish_fn_9+0xb8>
    1173:	mov    r15,rcx
    1176:	jmp    11a6 <botlish_fn_9+0xe3>
    117b:	mov    r15,rcx
    117e:	movzx  rdi,BYTE PTR [r15+0x18]
    1183:	test   rdi,rdi
    1186:	jne    11a1 <botlish_fn_9+0xde>
    118c:	mov    rsi,r15
    118f:	mov    rdi,QWORD PTR [rsp+0x88]
    1197:	call   119c <botlish_fn_9+0xd9>
			1198: R_X86_64_PLT32	rt_str_to_short-0x4
    119c:	jmp    11a6 <botlish_fn_9+0xe3>
    11a1:	movzx  rax,BYTE PTR [r15+0x19]
    11a6:	cmp    rax,0x22
    11aa:	je     126a <botlish_fn_9+0x1a7>
    11b0:	mov    QWORD PTR [rsp+0x20],0x3
    11b9:	mov    rsi,QWORD PTR [rsp+0x90]
    11c1:	test   rsi,0x1
    11c8:	je     11e8 <botlish_fn_9+0x125>
    11ce:	mov    rax,rsi
    11d1:	add    rax,0x2
    11d5:	seto   cl
    11d8:	test   cl,cl
    11da:	jne    11e8 <botlish_fn_9+0x125>
    11e0:	mov    rsi,rax
    11e3:	jmp    11fd <botlish_fn_9+0x13a>
    11e8:	mov    edx,0x3
    11ed:	mov    rdi,QWORD PTR [rsp+0x88]
    11f5:	call   11fa <botlish_fn_9+0x137>
			11f6: R_X86_64_PLT32	rt_int_add-0x4
    11fa:	mov    rsi,rax
    11fd:	mov    QWORD PTR [rsp+0x8],rsi
    1202:	mov    QWORD PTR [rsp+0x90],rsi
    120a:	mov    QWORD PTR [rsp+0x68],0x0
    1213:	mov    QWORD PTR [rsp+0x70],r13
    1218:	mov    QWORD PTR [rsp+0x78],0x0
    1221:	mov    QWORD PTR [rsp+0x80],r15
    1229:	mov    esi,0x2
    122e:	mov    edx,0x4
    1233:	mov    rcx,r14
    1236:	mov    rdi,QWORD PTR [rsp+0x88]
    123e:	call   1243 <botlish_fn_9+0x180>
			123f: R_X86_64_PLT32	rt_construct-0x4
    1243:	test   rax,rax
    1246:	je     149a <botlish_fn_9+0x3d7>
    124c:	mov    QWORD PTR [rsp],r12
    1250:	mov    rsi,QWORD PTR [rsp+0x90]
    1258:	mov    QWORD PTR [rsp+0x8],rsi
    125d:	mov    QWORD PTR [rsp+0x10],rax
    1262:	mov    r13,rax
    1265:	jmp    1136 <botlish_fn_9+0x73>
    126a:	mov    QWORD PTR [rsp+0x18],0x3
    1273:	mov    rsi,QWORD PTR [rsp+0x90]
    127b:	test   rsi,0x1
    1282:	je     12a2 <botlish_fn_9+0x1df>
    1288:	mov    rsi,QWORD PTR [rsp+0x90]
    1290:	mov    rdx,rsi
    1293:	add    rdx,0x2
    1297:	seto   al
    129a:	test   al,al
    129c:	je     12bf <botlish_fn_9+0x1fc>
    12a2:	mov    edx,0x3
    12a7:	mov    rsi,QWORD PTR [rsp+0x90]
    12af:	mov    rdi,QWORD PTR [rsp+0x88]
    12b7:	call   12bc <botlish_fn_9+0x1f9>
			12b8: R_X86_64_PLT32	rt_int_add-0x4
    12bc:	mov    rdx,rax
    12bf:	mov    QWORD PTR [rsp+0x18],rdx
    12c4:	mov    rcx,rbx
    12c7:	mov    rsi,r12
    12ca:	mov    rdi,QWORD PTR [rsp+0x88]
    12d2:	call   12d7 <botlish_fn_9+0x214>
			12d3: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
    12d7:	test   rax,rax
    12da:	mov    rsi,rax
    12dd:	je     149a <botlish_fn_9+0x3d7>
    12e3:	mov    rdx,QWORD PTR [rsp+0x28]
    12e8:	mov    rcx,QWORD PTR [rsp+0x30]
    12ed:	mov    rdi,QWORD PTR [rsp+0x88]
    12f5:	mov    rax,QWORD PTR [rdi+0x10]
    12f9:	mov    r8,QWORD PTR [rax+0x28]
    12fd:	call   1302 <botlish_fn_9+0x23f>
			12fe: R_X86_64_PLT32	rt_str_region_eq-0x4
    1302:	cmp    rax,0x6
    1306:	je     13d8 <botlish_fn_9+0x315>
    130c:	xor    rsi,rsi
    130f:	lea    rcx,[rsp+0x58]
    1314:	mov    QWORD PTR [rsp+0x58],0x0
    131d:	mov    QWORD PTR [rsp+0x60],r13
    1322:	mov    edx,0x2
    1327:	mov    rdi,QWORD PTR [rsp+0x88]
    132f:	call   1334 <botlish_fn_9+0x271>
			1330: R_X86_64_PLT32	rt_construct-0x4
    1334:	test   rax,rax
    1337:	je     149a <botlish_fn_9+0x3d7>
    133d:	mov    QWORD PTR [rsp],rax
    1341:	mov    rbx,rax
    1344:	mov    QWORD PTR [rsp+0x10],0x3
    134d:	mov    rsi,QWORD PTR [rsp+0x90]
    1355:	test   rsi,0x1
    135c:	je     1384 <botlish_fn_9+0x2c1>
    1362:	mov    rsi,QWORD PTR [rsp+0x90]
    136a:	mov    rdx,rsi
    136d:	add    rdx,0x2
    1371:	seto   al
    1374:	test   al,al
    1376:	jne    1384 <botlish_fn_9+0x2c1>
    137c:	mov    rax,rbx
    137f:	jmp    13a4 <botlish_fn_9+0x2e1>
    1384:	mov    edx,0x3
    1389:	mov    rsi,QWORD PTR [rsp+0x90]
    1391:	mov    rdi,QWORD PTR [rsp+0x88]
    1399:	call   139e <botlish_fn_9+0x2db>
			139a: R_X86_64_PLT32	rt_int_add-0x4
    139e:	mov    rdx,rax
    13a1:	mov    rax,rbx
    13a4:	mov    rbx,QWORD PTR [rsp+0xa0]
    13ac:	mov    r12,QWORD PTR [rsp+0xa8]
    13b4:	mov    r13,QWORD PTR [rsp+0xb0]
    13bc:	mov    r14,QWORD PTR [rsp+0xb8]
    13c4:	mov    r15,QWORD PTR [rsp+0xc0]
    13cc:	add    rsp,0xd0
    13d3:	mov    rsp,rbp
    13d6:	pop    rbp
    13d7:	ret
    13d8:	mov    QWORD PTR [rsp+0x18],0x5
    13e1:	mov    rsi,QWORD PTR [rsp+0x90]
    13e9:	test   rsi,0x1
    13f0:	je     1422 <botlish_fn_9+0x35f>
    13f6:	mov    rsi,QWORD PTR [rsp+0x90]
    13fe:	mov    rdi,rsi
    1401:	add    rdi,0x4
    1405:	seto   r9b
    1409:	test   r9b,r9b
    140c:	jne    1422 <botlish_fn_9+0x35f>
    1412:	mov    rsi,rdi
    1415:	mov    QWORD PTR [rsp+0x90],rdi
    141d:	jmp    1447 <botlish_fn_9+0x384>
    1422:	mov    edx,0x5
    1427:	mov    rsi,QWORD PTR [rsp+0x90]
    142f:	mov    rdi,QWORD PTR [rsp+0x88]
    1437:	call   143c <botlish_fn_9+0x379>
			1438: R_X86_64_PLT32	rt_int_add-0x4
    143c:	mov    rsi,rax
    143f:	mov    QWORD PTR [rsp+0x90],rax
    1447:	mov    QWORD PTR [rsp+0x8],rsi
    144c:	mov    rdi,QWORD PTR [rsp+0x88]
    1454:	mov    rax,QWORD PTR [rdi+0x10]
    1458:	mov    rax,QWORD PTR [rax+0x28]
    145c:	mov    QWORD PTR [rsp+0x18],rax
    1461:	lea    rcx,[rsp+0x38]
    1466:	mov    QWORD PTR [rsp+0x38],0x0
    146f:	mov    QWORD PTR [rsp+0x40],r13
    1474:	mov    QWORD PTR [rsp+0x48],0x0
    147d:	mov    QWORD PTR [rsp+0x50],rax
    1482:	mov    esi,0x2
    1487:	mov    edx,0x4
    148c:	call   1491 <botlish_fn_9+0x3ce>
			148d: R_X86_64_PLT32	rt_construct-0x4
    1491:	test   rax,rax
    1494:	jne    14d4 <botlish_fn_9+0x411>
    149a:	xor    rdx,rdx
    149d:	mov    rax,rdx
    14a0:	mov    rbx,QWORD PTR [rsp+0xa0]
    14a8:	mov    r12,QWORD PTR [rsp+0xa8]
    14b0:	mov    r13,QWORD PTR [rsp+0xb0]
    14b8:	mov    r14,QWORD PTR [rsp+0xb8]
    14c0:	mov    r15,QWORD PTR [rsp+0xc0]
    14c8:	add    rsp,0xd0
    14cf:	mov    rsp,rbp
    14d2:	pop    rbp
    14d3:	ret
    14d4:	mov    QWORD PTR [rsp],r12
    14d8:	mov    rsi,QWORD PTR [rsp+0x90]
    14e0:	mov    QWORD PTR [rsp+0x8],rsi
    14e5:	mov    QWORD PTR [rsp+0x10],rax
    14ea:	mov    r13,rax
    14ed:	jmp    1136 <botlish_fn_9+0x73>

00000000000014f2 <botlish_entry_9: scan_quoted<str, int, str>>:
    14f2:	push   rbp
    14f3:	mov    rbp,rsp
    14f6:	ud2

00000000000014f8 <botlish_fn_10: scan_field<str, int>>:
    14f8:	push   rbp
    14f9:	mov    rbp,rsp
    14fc:	sub    rsp,0x50
    1500:	mov    QWORD PTR [rsp+0x30],rbx
    1505:	mov    QWORD PTR [rsp+0x38],r12
    150a:	mov    QWORD PTR [rsp+0x40],r13
    150f:	mov    r12,rdi
    1512:	mov    r13,rdx
    1515:	mov    QWORD PTR [rsp+0x10],0x0
    151e:	mov    QWORD PTR [rsp],rsi
    1522:	mov    rbx,rsi
    1525:	mov    QWORD PTR [rsp+0x8],rdx
    152a:	lea    rcx,[rsp+0x18]
    152f:	mov    rdx,r13
    1532:	mov    rsi,rbx
    1535:	mov    rdi,r12
    1538:	call   153d <botlish_fn_10+0x45>
			1539: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
    153d:	test   rax,rax
    1540:	mov    rsi,rax
    1543:	je     160e <botlish_fn_10+0x116>
    1549:	mov    rdx,QWORD PTR [rsp+0x18]
    154e:	mov    rcx,QWORD PTR [rsp+0x20]
    1553:	mov    rdi,r12
    1556:	mov    rax,QWORD PTR [rdi+0x10]
    155a:	mov    r8,QWORD PTR [rax+0x28]
    155e:	call   1563 <botlish_fn_10+0x6b>
			155f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1563:	cmp    rax,0x6
    1567:	je     159f <botlish_fn_10+0xa7>
    156d:	mov    rcx,r13
    1570:	mov    rsi,rbx
    1573:	mov    rdi,r12
    1576:	mov    rdx,rcx
    1579:	call   157e <botlish_fn_10+0x86>
			157a: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_unquoted<str, int, int>
    157e:	test   rax,rax
    1581:	je     160e <botlish_fn_10+0x116>
    1587:	mov    rbx,QWORD PTR [rsp+0x30]
    158c:	mov    r12,QWORD PTR [rsp+0x38]
    1591:	mov    r13,QWORD PTR [rsp+0x40]
    1596:	add    rsp,0x50
    159a:	mov    rsp,rbp
    159d:	pop    rbp
    159e:	ret
    159f:	mov    rcx,r13
    15a2:	mov    QWORD PTR [rsp+0x10],0x3
    15ab:	test   rcx,0x1
    15b2:	jne    15c0 <botlish_fn_10+0xc8>
    15b8:	mov    r13,rcx
    15bb:	jmp    15d5 <botlish_fn_10+0xdd>
    15c0:	mov    rdx,rcx
    15c3:	add    rdx,0x2
    15c7:	mov    r13,rcx
    15ca:	seto   al
    15cd:	test   al,al
    15cf:	je     15e8 <botlish_fn_10+0xf0>
    15d5:	mov    edx,0x3
    15da:	mov    rsi,r13
    15dd:	mov    rdi,r12
    15e0:	call   15e5 <botlish_fn_10+0xed>
			15e1: R_X86_64_PLT32	rt_int_add-0x4
    15e5:	mov    rdx,rax
    15e8:	mov    QWORD PTR [rsp+0x8],rdx
    15ed:	mov    rdi,r12
    15f0:	mov    rax,QWORD PTR [rdi+0x10]
    15f4:	mov    rcx,QWORD PTR [rax+0x10]
    15f8:	mov    QWORD PTR [rsp+0x10],rcx
    15fd:	mov    rsi,rbx
    1600:	call   1605 <botlish_fn_10+0x10d>
			1601: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_quoted<str, int, str>
    1605:	test   rax,rax
    1608:	jne    162c <botlish_fn_10+0x134>
    160e:	xor    rdx,rdx
    1611:	mov    rax,rdx
    1614:	mov    rbx,QWORD PTR [rsp+0x30]
    1619:	mov    r12,QWORD PTR [rsp+0x38]
    161e:	mov    r13,QWORD PTR [rsp+0x40]
    1623:	add    rsp,0x50
    1627:	mov    rsp,rbp
    162a:	pop    rbp
    162b:	ret
    162c:	mov    rbx,QWORD PTR [rsp+0x30]
    1631:	mov    r12,QWORD PTR [rsp+0x38]
    1636:	mov    r13,QWORD PTR [rsp+0x40]
    163b:	add    rsp,0x50
    163f:	mov    rsp,rbp
    1642:	pop    rbp
    1643:	ret

0000000000001644 <botlish_entry_10: scan_field<str, int>>:
    1644:	push   rbp
    1645:	mov    rbp,rsp
    1648:	ud2

000000000000164a <botlish_fn_11: scan_record<str, int, ChunkedBuilder>>:
    164a:	push   rbp
    164b:	mov    rbp,rsp
    164e:	sub    rsp,0x80
    1655:	mov    QWORD PTR [rsp+0x50],rbx
    165a:	mov    QWORD PTR [rsp+0x58],r12
    165f:	mov    QWORD PTR [rsp+0x60],r13
    1664:	mov    QWORD PTR [rsp+0x68],r14
    1669:	mov    QWORD PTR [rsp+0x70],r15
    166e:	mov    r15,rdi
    1671:	mov    QWORD PTR [rsp+0x18],0x0
    167a:	mov    QWORD PTR [rsp],rsi
    167e:	mov    QWORD PTR [rsp+0x8],rdx
    1683:	mov    QWORD PTR [rsp+0x10],rcx
    1688:	lea    r14,[rsp+0x20]
    168d:	mov    rbx,rsi
    1690:	mov    r12,rcx
    1693:	mov    rsi,rbx
    1696:	mov    rdi,r15
    1699:	call   169e <botlish_fn_11+0x54>
			169a: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_field<str, int>
    169e:	test   rax,rax
    16a1:	je     17a2 <botlish_fn_11+0x158>
    16a7:	mov    QWORD PTR [rsp+0x8],rax
    16ac:	mov    QWORD PTR [rsp+0x18],rdx
    16b1:	mov    QWORD PTR [rsp+0x40],rdx
    16b6:	mov    rsi,r12
    16b9:	mov    rdx,rax
    16bc:	mov    rdi,r15
    16bf:	call   16c4 <botlish_fn_11+0x7a>
			16c0: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<ChunkedBuilder, str>
    16c4:	test   rax,rax
    16c7:	je     17a2 <botlish_fn_11+0x158>
    16cd:	mov    QWORD PTR [rsp+0x8],rax
    16d2:	mov    QWORD PTR [rsp+0x38],rax
    16d7:	mov    rcx,r14
    16da:	mov    rdx,QWORD PTR [rsp+0x40]
    16df:	mov    rsi,rbx
    16e2:	mov    rdi,r15
    16e5:	call   16ea <botlish_fn_11+0xa0>
			16e6: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
    16ea:	test   rax,rax
    16ed:	mov    QWORD PTR [rsp+0x30],rax
    16f2:	je     17a2 <botlish_fn_11+0x158>
    16f8:	mov    r12,QWORD PTR [rsp+0x20]
    16fd:	mov    r13,QWORD PTR [rsp+0x28]
    1702:	mov    rdi,r15
    1705:	mov    rcx,QWORD PTR [rdi+0x10]
    1709:	mov    r8,QWORD PTR [rcx+0x18]
    170d:	mov    rcx,r13
    1710:	mov    rdx,r12
    1713:	mov    rsi,QWORD PTR [rsp+0x30]
    1718:	call   171d <botlish_fn_11+0xd3>
			1719: R_X86_64_PLT32	rt_str_region_eq-0x4
    171d:	cmp    rax,0x6
    1721:	je     184a <botlish_fn_11+0x200>
    1727:	mov    rdi,r15
    172a:	mov    rax,QWORD PTR [rdi+0x10]
    172e:	mov    r8,QWORD PTR [rax+0x20]
    1732:	mov    rcx,r13
    1735:	mov    rdx,r12
    1738:	mov    rsi,QWORD PTR [rsp+0x30]
    173d:	call   1742 <botlish_fn_11+0xf8>
			173e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1742:	cmp    rax,0x6
    1746:	je     178c <botlish_fn_11+0x142>
    174c:	mov    rsi,QWORD PTR [rsp+0x38]
    1751:	mov    rdi,r15
    1754:	call   1759 <botlish_fn_11+0x10f>
			1755: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_finish<ChunkedBuilder>
    1759:	test   rax,rax
    175c:	je     17a2 <botlish_fn_11+0x158>
    1762:	mov    rdx,QWORD PTR [rsp+0x40]
    1767:	mov    rbx,QWORD PTR [rsp+0x50]
    176c:	mov    r12,QWORD PTR [rsp+0x58]
    1771:	mov    r13,QWORD PTR [rsp+0x60]
    1776:	mov    r14,QWORD PTR [rsp+0x68]
    177b:	mov    r15,QWORD PTR [rsp+0x70]
    1780:	add    rsp,0x80
    1787:	mov    rsp,rbp
    178a:	pop    rbp
    178b:	ret
    178c:	mov    rsi,QWORD PTR [rsp+0x38]
    1791:	mov    rdi,r15
    1794:	call   1799 <botlish_fn_11+0x14f>
			1795: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_finish<ChunkedBuilder>
    1799:	test   rax,rax
    179c:	jne    17cd <botlish_fn_11+0x183>
    17a2:	xor    rdx,rdx
    17a5:	mov    rax,rdx
    17a8:	mov    rbx,QWORD PTR [rsp+0x50]
    17ad:	mov    r12,QWORD PTR [rsp+0x58]
    17b2:	mov    r13,QWORD PTR [rsp+0x60]
    17b7:	mov    r14,QWORD PTR [rsp+0x68]
    17bc:	mov    r15,QWORD PTR [rsp+0x70]
    17c1:	add    rsp,0x80
    17c8:	mov    rsp,rbp
    17cb:	pop    rbp
    17cc:	ret
    17cd:	mov    QWORD PTR [rsp],rax
    17d1:	mov    rbx,rax
    17d4:	mov    QWORD PTR [rsp+0x8],0x3
    17dd:	mov    rdx,QWORD PTR [rsp+0x40]
    17e2:	test   rdx,0x1
    17e9:	je     180d <botlish_fn_11+0x1c3>
    17ef:	mov    rdx,QWORD PTR [rsp+0x40]
    17f4:	add    rdx,0x2
    17f8:	seto   sil
    17fc:	test   sil,sil
    17ff:	jne    180d <botlish_fn_11+0x1c3>
    1805:	mov    rax,rbx
    1808:	jmp    1825 <botlish_fn_11+0x1db>
    180d:	mov    edx,0x3
    1812:	mov    rsi,QWORD PTR [rsp+0x40]
    1817:	mov    rdi,r15
    181a:	call   181f <botlish_fn_11+0x1d5>
			181b: R_X86_64_PLT32	rt_int_add-0x4
    181f:	mov    rdx,rax
    1822:	mov    rax,rbx
    1825:	mov    rbx,QWORD PTR [rsp+0x50]
    182a:	mov    r12,QWORD PTR [rsp+0x58]
    182f:	mov    r13,QWORD PTR [rsp+0x60]
    1834:	mov    r14,QWORD PTR [rsp+0x68]
    1839:	mov    r15,QWORD PTR [rsp+0x70]
    183e:	add    rsp,0x80
    1845:	mov    rsp,rbp
    1848:	pop    rbp
    1849:	ret
    184a:	mov    rsi,QWORD PTR [rsp+0x40]
    184f:	mov    edx,0x3
    1854:	mov    rcx,rdx
    1857:	mov    QWORD PTR [rsp+0x10],0x3
    1860:	test   rsi,0x1
    1867:	jne    1875 <botlish_fn_11+0x22b>
    186d:	mov    rdx,rcx
    1870:	jmp    188a <botlish_fn_11+0x240>
    1875:	mov    rdx,rsi
    1878:	add    rdx,0x2
    187c:	seto   al
    187f:	test   al,al
    1881:	je     1895 <botlish_fn_11+0x24b>
    1887:	mov    rdx,rcx
    188a:	mov    rdi,r15
    188d:	call   1892 <botlish_fn_11+0x248>
			188e: R_X86_64_PLT32	rt_int_add-0x4
    1892:	mov    rdx,rax
    1895:	mov    QWORD PTR [rsp],rbx
    1899:	mov    QWORD PTR [rsp+0x8],rdx
    189e:	mov    rsi,QWORD PTR [rsp+0x38]
    18a3:	mov    QWORD PTR [rsp+0x10],rsi
    18a8:	mov    r12,rsi
    18ab:	jmp    1693 <botlish_fn_11+0x49>

00000000000018b0 <botlish_entry_11: scan_record<str, int, ChunkedBuilder>>:
    18b0:	push   rbp
    18b1:	mov    rbp,rsp
    18b4:	ud2
	...

00000000000018b8 <botlish_fn_12: scan_records<str, int, ChunkedBuilder>>:
    18b8:	push   rbp
    18b9:	mov    rbp,rsp
    18bc:	sub    rsp,0x40
    18c0:	mov    QWORD PTR [rsp+0x20],rbx
    18c5:	mov    QWORD PTR [rsp+0x28],r12
    18ca:	mov    QWORD PTR [rsp+0x30],r13
    18cf:	mov    QWORD PTR [rsp+0x38],r14
    18d4:	mov    r13,rdi
    18d7:	mov    QWORD PTR [rsp+0x18],0x0
    18e0:	mov    QWORD PTR [rsp],rsi
    18e4:	mov    QWORD PTR [rsp+0x8],rdx
    18e9:	mov    r12,rdx
    18ec:	mov    QWORD PTR [rsp+0x10],rcx
    18f1:	mov    rbx,rsi
    18f4:	mov    r14,rcx
    18f7:	mov    rdx,QWORD PTR [rbx+0x8]
    18fb:	shl    rdx,1
    18fe:	or     rdx,0x1
    1902:	mov    rax,r12
    1905:	and    rax,rdx
    1908:	test   rax,0x1
    190e:	jne    1934 <botlish_fn_12+0x7c>
    1914:	mov    rsi,r12
    1917:	mov    rdi,r13
    191a:	call   191f <botlish_fn_12+0x67>
			191b: R_X86_64_PLT32	rt_int_cmp-0x4
    191f:	mov    ecx,0x2
    1924:	test   rax,rax
    1927:	cmovge rcx,QWORD PTR [rip+0xe1]        # 1a10 <botlish_fn_12+0x158>
    192f:	jmp    1947 <botlish_fn_12+0x8f>
    1934:	mov    ecx,0x2
    1939:	mov    rax,r12
    193c:	cmp    rax,rdx
    193f:	cmovge rcx,QWORD PTR [rip+0xc9]        # 1a10 <botlish_fn_12+0x158>
    1947:	cmp    rcx,0x6
    194b:	je     19be <botlish_fn_12+0x106>
    1951:	mov    rdi,r13
    1954:	call   1959 <botlish_fn_12+0xa1>
			1955: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    1959:	test   rax,rax
    195c:	je     19d2 <botlish_fn_12+0x11a>
    1962:	mov    QWORD PTR [rsp+0x18],rax
    1967:	mov    rcx,rax
    196a:	mov    rdx,r12
    196d:	mov    rsi,rbx
    1970:	mov    rdi,r13
    1973:	call   1978 <botlish_fn_12+0xc0>
			1974: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_record<str, int, ChunkedBuilder>
    1978:	test   rax,rax
    197b:	je     19d2 <botlish_fn_12+0x11a>
    1981:	mov    QWORD PTR [rsp+0x8],rax
    1986:	mov    QWORD PTR [rsp+0x18],rdx
    198b:	mov    r12,rdx
    198e:	mov    rsi,r14
    1991:	mov    rdx,rax
    1994:	mov    rdi,r13
    1997:	call   199c <botlish_fn_12+0xe4>
			1998: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<ChunkedBuilder, list>
    199c:	test   rax,rax
    199f:	je     19d2 <botlish_fn_12+0x11a>
    19a5:	mov    QWORD PTR [rsp],rbx
    19a9:	mov    rdx,r12
    19ac:	mov    QWORD PTR [rsp+0x8],rdx
    19b1:	mov    QWORD PTR [rsp+0x10],rax
    19b6:	mov    r14,rax
    19b9:	jmp    18f7 <botlish_fn_12+0x3f>
    19be:	mov    rsi,r14
    19c1:	mov    rdi,r13
    19c4:	call   19c9 <botlish_fn_12+0x111>
			19c5: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_finish<ChunkedBuilder>
    19c9:	test   rax,rax
    19cc:	jne    19f2 <botlish_fn_12+0x13a>
    19d2:	xor    rax,rax
    19d5:	mov    rbx,QWORD PTR [rsp+0x20]
    19da:	mov    r12,QWORD PTR [rsp+0x28]
    19df:	mov    r13,QWORD PTR [rsp+0x30]
    19e4:	mov    r14,QWORD PTR [rsp+0x38]
    19e9:	add    rsp,0x40
    19ed:	mov    rsp,rbp
    19f0:	pop    rbp
    19f1:	ret
    19f2:	mov    rbx,QWORD PTR [rsp+0x20]
    19f7:	mov    r12,QWORD PTR [rsp+0x28]
    19fc:	mov    r13,QWORD PTR [rsp+0x30]
    1a01:	mov    r14,QWORD PTR [rsp+0x38]
    1a06:	add    rsp,0x40
    1a0a:	mov    rsp,rbp
    1a0d:	pop    rbp
    1a0e:	ret
    1a0f:	add    BYTE PTR [rsi],al
    1a11:	add    BYTE PTR [rax],al
    1a13:	add    BYTE PTR [rax],al
    1a15:	add    BYTE PTR [rax],al
	...

0000000000001a18 <botlish_entry_12: scan_records<str, int, ChunkedBuilder>>:
    1a18:	push   rbp
    1a19:	mov    rbp,rsp
    1a1c:	mov    rsi,QWORD PTR [rdx]
    1a1f:	mov    r8,QWORD PTR [rdx+0x8]
    1a23:	mov    rcx,QWORD PTR [rdx+0x10]
    1a27:	mov    rdx,r8
    1a2a:	call   1a2f <botlish_entry_12+0x17>
			1a2b: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_records<str, int, ChunkedBuilder>
    1a2f:	mov    rsp,rbp
    1a32:	pop    rbp
    1a33:	ret

0000000000001a34 <botlish_fn_13: csv_parse<str>>:
    1a34:	push   rbp
    1a35:	mov    rbp,rsp
    1a38:	sub    rsp,0x30
    1a3c:	mov    QWORD PTR [rsp+0x20],r12
    1a41:	mov    QWORD PTR [rsp+0x28],r13
    1a46:	mov    r13,rdi
    1a49:	mov    QWORD PTR [rsp+0x10],0x0
    1a52:	mov    QWORD PTR [rsp],rsi
    1a56:	mov    r12,rsi
    1a59:	mov    QWORD PTR [rsp+0x8],0x1
    1a62:	mov    rdi,r13
    1a65:	call   1a6a <botlish_fn_13+0x36>
			1a66: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    1a6a:	test   rax,rax
    1a6d:	je     1a94 <botlish_fn_13+0x60>
    1a73:	mov    QWORD PTR [rsp+0x10],rax
    1a78:	mov    rcx,rax
    1a7b:	mov    edx,0x1
    1a80:	mov    rsi,r12
    1a83:	mov    rdi,r13
    1a86:	call   1a8b <botlish_fn_13+0x57>
			1a87: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_records<str, int, ChunkedBuilder>
    1a8b:	test   rax,rax
    1a8e:	jne    1aaa <botlish_fn_13+0x76>
    1a94:	xor    rax,rax
    1a97:	mov    r12,QWORD PTR [rsp+0x20]
    1a9c:	mov    r13,QWORD PTR [rsp+0x28]
    1aa1:	add    rsp,0x30
    1aa5:	mov    rsp,rbp
    1aa8:	pop    rbp
    1aa9:	ret
    1aaa:	mov    r12,QWORD PTR [rsp+0x20]
    1aaf:	mov    r13,QWORD PTR [rsp+0x28]
    1ab4:	add    rsp,0x30
    1ab8:	mov    rsp,rbp
    1abb:	pop    rbp
    1abc:	ret

0000000000001abd <botlish_entry_13: csv_parse<str>>:
    1abd:	push   rbp
    1abe:	mov    rbp,rsp
    1ac1:	mov    rsi,QWORD PTR [rdx]
    1ac4:	call   1ac9 <botlish_entry_13+0xc>
			1ac5: R_X86_64_PLT32	botlish_fn_13-0x4 ; csv_parse<str>
    1ac9:	mov    rsp,rbp
    1acc:	pop    rbp
    1acd:	ret

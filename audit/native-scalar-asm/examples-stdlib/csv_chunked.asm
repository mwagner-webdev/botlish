; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 6885  (per function: 312 315 757 757 504 625 365 309 526 932 311 630 388 154)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> chunked_new<generic>
;   botlish_fn_2 / botlish_entry_2 -> chunked_append<ChunkedBuilder, str>
;   botlish_fn_3 / botlish_entry_3 -> chunked_append<ChunkedBuilder, list>
;   botlish_fn_4 / botlish_entry_4 -> chunked_copy_chunks<list, int, mutarray, int>
;   botlish_fn_5 / botlish_entry_5 -> chunked_finish<ChunkedBuilder>
;   botlish_fn_6 / botlish_entry_6 -> peek<str, int>
;   botlish_fn_7 / botlish_entry_7 -> quote_at?<str, int>
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

0000000000000cf8 <botlish_fn_7: quote_at?<str, int>>:
     cf8:	push   rbp
     cf9:	mov    rbp,rsp
     cfc:	sub    rsp,0x20
     d00:	mov    QWORD PTR [rsp],rbx
     d04:	mov    QWORD PTR [rsp+0x8],r12
     d09:	mov    QWORD PTR [rsp+0x10],r13
     d0e:	mov    rbx,rdx
     d11:	mov    r13,rdi
     d14:	mov    rdx,QWORD PTR [rsi+0x8]
     d18:	mov    r12,rsi
     d1b:	shl    rdx,1
     d1e:	mov    rax,rdx
     d21:	or     rax,0x1
     d25:	mov    rcx,rbx
     d28:	and    rcx,rax
     d2b:	test   rcx,0x1
     d32:	jne    d5c <botlish_fn_7+0x64>
     d38:	or     rdx,0x1
     d3c:	mov    rsi,rbx
     d3f:	mov    rdi,r13
     d42:	call   d47 <botlish_fn_7+0x4f>
			d43: R_X86_64_PLT32	rt_int_cmp-0x4
     d47:	mov    ecx,0x2
     d4c:	test   rax,rax
     d4f:	cmovl  rcx,QWORD PTR [rip+0xa1]        # df8 <botlish_fn_7+0x100>
     d57:	jmp    d73 <botlish_fn_7+0x7b>
     d5c:	or     rdx,0x1
     d60:	mov    ecx,0x2
     d65:	mov    rax,rbx
     d68:	cmp    rax,rdx
     d6b:	cmovl  rcx,QWORD PTR [rip+0x85]        # df8 <botlish_fn_7+0x100>
     d73:	mov    eax,0x6
     d78:	cmp    rcx,0x6
     d7c:	je     d8f <botlish_fn_7+0x97>
     d82:	mov    eax,0x2
     d87:	mov    r12,rax
     d8a:	jmp    ddc <botlish_fn_7+0xe4>
     d8f:	mov    rdi,r13
     d92:	mov    rsi,r12
     d95:	mov    r12,rax
     d98:	mov    rdx,rbx
     d9b:	call   da0 <botlish_fn_7+0xa8>
			d9c: R_X86_64_PLT32	rt_str_char_at-0x4
     da0:	test   rax,rax
     da3:	jne    dc3 <botlish_fn_7+0xcb>
     da9:	xor    rax,rax
     dac:	mov    rbx,QWORD PTR [rsp]
     db0:	mov    r12,QWORD PTR [rsp+0x8]
     db5:	mov    r13,QWORD PTR [rsp+0x10]
     dba:	add    rsp,0x20
     dbe:	mov    rsp,rbp
     dc1:	pop    rbp
     dc2:	ret
     dc3:	cmp    rax,0x114
     dc9:	je     dd9 <botlish_fn_7+0xe1>
     dcf:	mov    eax,0x2
     dd4:	jmp    ddc <botlish_fn_7+0xe4>
     dd9:	mov    rax,r12
     ddc:	mov    rbx,QWORD PTR [rsp]
     de0:	mov    r12,QWORD PTR [rsp+0x8]
     de5:	mov    r13,QWORD PTR [rsp+0x10]
     dea:	add    rsp,0x20
     dee:	mov    rsp,rbp
     df1:	pop    rbp
     df2:	ret
     df3:	add    BYTE PTR [rax],al
     df5:	add    BYTE PTR [rax],al
     df7:	add    BYTE PTR [rsi],al
     df9:	add    BYTE PTR [rax],al
     dfb:	add    BYTE PTR [rax],al
     dfd:	add    BYTE PTR [rax],al
	...

0000000000000e00 <botlish_entry_7: quote_at?<str, int>>:
     e00:	push   rbp
     e01:	mov    rbp,rsp
     e04:	mov    rsi,QWORD PTR [rdx]
     e07:	mov    rdx,QWORD PTR [rdx+0x8]
     e0b:	call   e10 <botlish_entry_7+0x10>
			e0c: R_X86_64_PLT32	botlish_fn_7-0x4 ; quote_at?<str, int>
     e10:	mov    rsp,rbp
     e13:	pop    rbp
     e14:	ret
     e15:	add    BYTE PTR [rax],al
	...

0000000000000e18 <botlish_fn_8: scan_unquoted<str, int, int>>:
     e18:	push   rbp
     e19:	mov    rbp,rsp
     e1c:	sub    rsp,0x40
     e20:	mov    QWORD PTR [rsp+0x20],rbx
     e25:	mov    QWORD PTR [rsp+0x28],r12
     e2a:	mov    QWORD PTR [rsp+0x30],r13
     e2f:	mov    QWORD PTR [rsp+0x38],r14
     e34:	mov    r14,rdi
     e37:	mov    QWORD PTR [rsp+0x18],0x0
     e40:	mov    QWORD PTR [rsp],rsi
     e44:	mov    r13,rsi
     e47:	mov    QWORD PTR [rsp+0x8],rdx
     e4c:	mov    rbx,rdx
     e4f:	mov    QWORD PTR [rsp+0x10],rcx
     e54:	mov    r12,rcx
     e57:	mov    rdx,QWORD PTR [rsi+0x8]
     e5b:	mov    r13,rsi
     e5e:	shl    rdx,1
     e61:	or     rdx,0x1
     e65:	mov    rax,r12
     e68:	and    rax,rdx
     e6b:	test   rax,0x1
     e71:	jne    e97 <botlish_fn_8+0x7f>
     e77:	mov    rsi,r12
     e7a:	mov    rdi,r14
     e7d:	call   e82 <botlish_fn_8+0x6a>
			e7e: R_X86_64_PLT32	rt_int_cmp-0x4
     e82:	mov    ecx,0x2
     e87:	test   rax,rax
     e8a:	cmovl  rcx,QWORD PTR [rip+0x17e]        # 1010 <botlish_fn_8+0x1f8>
     e92:	jmp    eaa <botlish_fn_8+0x92>
     e97:	mov    ecx,0x2
     e9c:	mov    rsi,r12
     e9f:	cmp    rsi,rdx
     ea2:	cmovl  rcx,QWORD PTR [rip+0x166]        # 1010 <botlish_fn_8+0x1f8>
     eaa:	cmp    rcx,0x6
     eae:	je     ec2 <botlish_fn_8+0xaa>
     eb4:	mov    rdx,rbx
     eb7:	mov    rsi,r13
     eba:	mov    rdi,r14
     ebd:	jmp    f4d <botlish_fn_8+0x135>
     ec2:	mov    rdx,r12
     ec5:	mov    rsi,r13
     ec8:	mov    rdi,r14
     ecb:	call   ed0 <botlish_fn_8+0xb8>
			ecc: R_X86_64_PLT32	rt_str_char_at-0x4
     ed0:	test   rax,rax
     ed3:	je     f64 <botlish_fn_8+0x14c>
     ed9:	cmp    rax,0x164
     edf:	je     eef <botlish_fn_8+0xd7>
     ee5:	mov    ecx,0x6
     eea:	jmp    ef4 <botlish_fn_8+0xdc>
     eef:	mov    ecx,0x2
     ef4:	cmp    rcx,0x6
     ef8:	je     f08 <botlish_fn_8+0xf0>
     efe:	mov    eax,0x2
     f03:	jmp    f3a <botlish_fn_8+0x122>
     f08:	cmp    rax,0x54
     f0c:	je     f1c <botlish_fn_8+0x104>
     f12:	mov    eax,0x6
     f17:	jmp    f21 <botlish_fn_8+0x109>
     f1c:	mov    eax,0x2
     f21:	cmp    rax,0x6
     f25:	je     f35 <botlish_fn_8+0x11d>
     f2b:	mov    eax,0x2
     f30:	jmp    f3a <botlish_fn_8+0x122>
     f35:	mov    eax,0x6
     f3a:	cmp    rax,0x6
     f3e:	je     fa7 <botlish_fn_8+0x18f>
     f44:	mov    rdx,rbx
     f47:	mov    rsi,r13
     f4a:	mov    rdi,r14
     f4d:	mov    rsi,r13
     f50:	mov    rdi,r14
     f53:	mov    rcx,r12
     f56:	call   f5b <botlish_fn_8+0x143>
			f57: R_X86_64_PLT32	rt_substr-0x4
     f5b:	test   rax,rax
     f5e:	jne    f87 <botlish_fn_8+0x16f>
     f64:	xor    rdx,rdx
     f67:	mov    rax,rdx
     f6a:	mov    rbx,QWORD PTR [rsp+0x20]
     f6f:	mov    r12,QWORD PTR [rsp+0x28]
     f74:	mov    r13,QWORD PTR [rsp+0x30]
     f79:	mov    r14,QWORD PTR [rsp+0x38]
     f7e:	add    rsp,0x40
     f82:	mov    rsp,rbp
     f85:	pop    rbp
     f86:	ret
     f87:	mov    rdx,r12
     f8a:	mov    rbx,QWORD PTR [rsp+0x20]
     f8f:	mov    r12,QWORD PTR [rsp+0x28]
     f94:	mov    r13,QWORD PTR [rsp+0x30]
     f99:	mov    r14,QWORD PTR [rsp+0x38]
     f9e:	add    rsp,0x40
     fa2:	mov    rsp,rbp
     fa5:	pop    rbp
     fa6:	ret
     fa7:	mov    QWORD PTR [rsp+0x18],0x3
     fb0:	mov    rdx,r12
     fb3:	test   rdx,0x1
     fba:	je     fdd <botlish_fn_8+0x1c5>
     fc0:	mov    rdx,r12
     fc3:	mov    rax,rdx
     fc6:	add    rax,0x2
     fca:	seto   cl
     fcd:	test   cl,cl
     fcf:	jne    fdd <botlish_fn_8+0x1c5>
     fd5:	mov    rsi,r13
     fd8:	jmp    ff0 <botlish_fn_8+0x1d8>
     fdd:	mov    edx,0x3
     fe2:	mov    rsi,r12
     fe5:	mov    rdi,r14
     fe8:	call   fed <botlish_fn_8+0x1d5>
			fe9: R_X86_64_PLT32	rt_int_add-0x4
     fed:	mov    rsi,r13
     ff0:	mov    rsi,r13
     ff3:	mov    QWORD PTR [rsp],rsi
     ff7:	mov    rdx,rbx
     ffa:	mov    QWORD PTR [rsp+0x8],rdx
     fff:	mov    QWORD PTR [rsp+0x10],rax
    1004:	mov    r12,rax
    1007:	jmp    e57 <botlish_fn_8+0x3f>
    100c:	add    BYTE PTR [rax],al
    100e:	add    BYTE PTR [rax],al
    1010:	(bad)
    1011:	add    BYTE PTR [rax],al
    1013:	add    BYTE PTR [rax],al
    1015:	add    BYTE PTR [rax],al
	...

0000000000001018 <botlish_entry_8: scan_unquoted<str, int, int>>:
    1018:	push   rbp
    1019:	mov    rbp,rsp
    101c:	ud2

000000000000101e <botlish_fn_9: scan_quoted<str, int, str>>:
    101e:	push   rbp
    101f:	mov    rbp,rsp
    1022:	sub    rsp,0xb0
    1029:	mov    QWORD PTR [rsp+0x80],rbx
    1031:	mov    QWORD PTR [rsp+0x88],r12
    1039:	mov    QWORD PTR [rsp+0x90],r13
    1041:	mov    QWORD PTR [rsp+0x98],r14
    1049:	mov    QWORD PTR [rsp+0xa0],r15
    1051:	mov    r15,rdi
    1054:	mov    QWORD PTR [rsp+0x18],0x0
    105d:	mov    QWORD PTR [rsp+0x20],0x0
    1066:	mov    QWORD PTR [rsp],rsi
    106a:	mov    QWORD PTR [rsp+0x8],rdx
    106f:	mov    QWORD PTR [rsp+0x10],rcx
    1074:	mov    r13,rcx
    1077:	lea    r12,[rsp+0x58]
    107c:	mov    rbx,rsi
    107f:	mov    QWORD PTR [rsp+0x78],rdx
    1084:	mov    rdx,QWORD PTR [rsp+0x78]
    1089:	mov    rsi,rbx
    108c:	mov    rdi,r15
    108f:	call   1094 <botlish_fn_9+0x76>
			1090: R_X86_64_PLT32	botlish_fn_6-0x4 ; peek<str, int>
    1094:	test   rax,rax
    1097:	je     1333 <botlish_fn_9+0x315>
    109d:	mov    QWORD PTR [rsp+0x18],rax
    10a2:	mov    r14,rax
    10a5:	mov    rdx,QWORD PTR [rsp+0x78]
    10aa:	mov    rsi,rbx
    10ad:	mov    rdi,r15
    10b0:	call   10b5 <botlish_fn_9+0x97>
			10b1: R_X86_64_PLT32	botlish_fn_7-0x4 ; quote_at?<str, int>
    10b5:	test   rax,rax
    10b8:	je     1333 <botlish_fn_9+0x315>
    10be:	cmp    rax,0x6
    10c2:	je     117b <botlish_fn_9+0x15d>
    10c8:	mov    QWORD PTR [rsp+0x20],0x3
    10d1:	mov    rsi,QWORD PTR [rsp+0x78]
    10d6:	test   rsi,0x1
    10dd:	je     1107 <botlish_fn_9+0xe9>
    10e3:	mov    rsi,QWORD PTR [rsp+0x78]
    10e8:	mov    rcx,rsi
    10eb:	add    rcx,0x2
    10ef:	seto   dl
    10f2:	test   dl,dl
    10f4:	jne    1107 <botlish_fn_9+0xe9>
    10fa:	mov    rsi,rcx
    10fd:	mov    QWORD PTR [rsp+0x78],rcx
    1102:	jmp    1121 <botlish_fn_9+0x103>
    1107:	mov    edx,0x3
    110c:	mov    rsi,QWORD PTR [rsp+0x78]
    1111:	mov    rdi,r15
    1114:	call   1119 <botlish_fn_9+0xfb>
			1115: R_X86_64_PLT32	rt_int_add-0x4
    1119:	mov    rsi,rax
    111c:	mov    QWORD PTR [rsp+0x78],rax
    1121:	mov    QWORD PTR [rsp+0x8],rsi
    1126:	mov    QWORD PTR [rsp+0x58],0x0
    112f:	mov    QWORD PTR [rsp+0x60],r13
    1134:	mov    QWORD PTR [rsp+0x68],0x0
    113d:	mov    QWORD PTR [rsp+0x70],r14
    1142:	mov    esi,0x2
    1147:	mov    edx,0x4
    114c:	mov    rcx,r12
    114f:	mov    rdi,r15
    1152:	call   1157 <botlish_fn_9+0x139>
			1153: R_X86_64_PLT32	rt_construct-0x4
    1157:	test   rax,rax
    115a:	je     1333 <botlish_fn_9+0x315>
    1160:	mov    QWORD PTR [rsp],rbx
    1164:	mov    rsi,QWORD PTR [rsp+0x78]
    1169:	mov    QWORD PTR [rsp+0x8],rsi
    116e:	mov    QWORD PTR [rsp+0x10],rax
    1173:	mov    r13,rax
    1176:	jmp    1084 <botlish_fn_9+0x66>
    117b:	mov    QWORD PTR [rsp+0x20],0x3
    1184:	mov    rsi,QWORD PTR [rsp+0x78]
    1189:	test   rsi,0x1
    1190:	je     11ad <botlish_fn_9+0x18f>
    1196:	mov    rsi,QWORD PTR [rsp+0x78]
    119b:	mov    rdx,rsi
    119e:	add    rdx,0x2
    11a2:	seto   al
    11a5:	test   al,al
    11a7:	je     11c2 <botlish_fn_9+0x1a4>
    11ad:	mov    edx,0x3
    11b2:	mov    rsi,QWORD PTR [rsp+0x78]
    11b7:	mov    rdi,r15
    11ba:	call   11bf <botlish_fn_9+0x1a1>
			11bb: R_X86_64_PLT32	rt_int_add-0x4
    11bf:	mov    rdx,rax
    11c2:	mov    rsi,rbx
    11c5:	mov    rdi,r15
    11c8:	call   11cd <botlish_fn_9+0x1af>
			11c9: R_X86_64_PLT32	botlish_fn_7-0x4 ; quote_at?<str, int>
    11cd:	test   rax,rax
    11d0:	je     1333 <botlish_fn_9+0x315>
    11d6:	cmp    rax,0x6
    11da:	je     1299 <botlish_fn_9+0x27b>
    11e0:	xor    rsi,rsi
    11e3:	lea    rcx,[rsp+0x48]
    11e8:	mov    QWORD PTR [rsp+0x48],0x0
    11f1:	mov    QWORD PTR [rsp+0x50],r13
    11f6:	mov    edx,0x2
    11fb:	mov    rdi,r15
    11fe:	call   1203 <botlish_fn_9+0x1e5>
			11ff: R_X86_64_PLT32	rt_construct-0x4
    1203:	test   rax,rax
    1206:	je     1333 <botlish_fn_9+0x315>
    120c:	mov    QWORD PTR [rsp],rax
    1210:	mov    r12,rax
    1213:	mov    QWORD PTR [rsp+0x10],0x3
    121c:	mov    rsi,QWORD PTR [rsp+0x78]
    1221:	test   rsi,0x1
    1228:	je     124d <botlish_fn_9+0x22f>
    122e:	mov    rsi,QWORD PTR [rsp+0x78]
    1233:	mov    rdx,rsi
    1236:	add    rdx,0x2
    123a:	seto   al
    123d:	test   al,al
    123f:	jne    124d <botlish_fn_9+0x22f>
    1245:	mov    rax,r12
    1248:	jmp    1265 <botlish_fn_9+0x247>
    124d:	mov    edx,0x3
    1252:	mov    rsi,QWORD PTR [rsp+0x78]
    1257:	mov    rdi,r15
    125a:	call   125f <botlish_fn_9+0x241>
			125b: R_X86_64_PLT32	rt_int_add-0x4
    125f:	mov    rdx,rax
    1262:	mov    rax,r12
    1265:	mov    rbx,QWORD PTR [rsp+0x80]
    126d:	mov    r12,QWORD PTR [rsp+0x88]
    1275:	mov    r13,QWORD PTR [rsp+0x90]
    127d:	mov    r14,QWORD PTR [rsp+0x98]
    1285:	mov    r15,QWORD PTR [rsp+0xa0]
    128d:	add    rsp,0xb0
    1294:	mov    rsp,rbp
    1297:	pop    rbp
    1298:	ret
    1299:	mov    QWORD PTR [rsp+0x20],0x5
    12a2:	mov    rsi,QWORD PTR [rsp+0x78]
    12a7:	test   rsi,0x1
    12ae:	je     12d8 <botlish_fn_9+0x2ba>
    12b4:	mov    rsi,QWORD PTR [rsp+0x78]
    12b9:	mov    rcx,rsi
    12bc:	add    rcx,0x4
    12c0:	seto   al
    12c3:	test   al,al
    12c5:	jne    12d8 <botlish_fn_9+0x2ba>
    12cb:	mov    rsi,rcx
    12ce:	mov    QWORD PTR [rsp+0x78],rcx
    12d3:	jmp    12f2 <botlish_fn_9+0x2d4>
    12d8:	mov    edx,0x5
    12dd:	mov    rsi,QWORD PTR [rsp+0x78]
    12e2:	mov    rdi,r15
    12e5:	call   12ea <botlish_fn_9+0x2cc>
			12e6: R_X86_64_PLT32	rt_int_add-0x4
    12ea:	mov    rsi,rax
    12ed:	mov    QWORD PTR [rsp+0x78],rax
    12f2:	mov    QWORD PTR [rsp+0x8],rsi
    12f7:	lea    rcx,[rsp+0x28]
    12fc:	mov    QWORD PTR [rsp+0x28],0x0
    1305:	mov    QWORD PTR [rsp+0x30],r13
    130a:	mov    QWORD PTR [rsp+0x38],0x0
    1313:	mov    QWORD PTR [rsp+0x40],r14
    1318:	mov    esi,0x2
    131d:	mov    edx,0x4
    1322:	mov    rdi,r15
    1325:	call   132a <botlish_fn_9+0x30c>
			1326: R_X86_64_PLT32	rt_construct-0x4
    132a:	test   rax,rax
    132d:	jne    136d <botlish_fn_9+0x34f>
    1333:	xor    rdx,rdx
    1336:	mov    rax,rdx
    1339:	mov    rbx,QWORD PTR [rsp+0x80]
    1341:	mov    r12,QWORD PTR [rsp+0x88]
    1349:	mov    r13,QWORD PTR [rsp+0x90]
    1351:	mov    r14,QWORD PTR [rsp+0x98]
    1359:	mov    r15,QWORD PTR [rsp+0xa0]
    1361:	add    rsp,0xb0
    1368:	mov    rsp,rbp
    136b:	pop    rbp
    136c:	ret
    136d:	mov    QWORD PTR [rsp],rbx
    1371:	mov    rsi,QWORD PTR [rsp+0x78]
    1376:	mov    QWORD PTR [rsp+0x8],rsi
    137b:	mov    QWORD PTR [rsp+0x10],rax
    1380:	mov    r13,rax
    1383:	jmp    1084 <botlish_fn_9+0x66>

0000000000001388 <botlish_entry_9: scan_quoted<str, int, str>>:
    1388:	push   rbp
    1389:	mov    rbp,rsp
    138c:	ud2

000000000000138e <botlish_fn_10: scan_field<str, int>>:
    138e:	push   rbp
    138f:	mov    rbp,rsp
    1392:	sub    rsp,0x40
    1396:	mov    QWORD PTR [rsp+0x20],rbx
    139b:	mov    QWORD PTR [rsp+0x28],r12
    13a0:	mov    QWORD PTR [rsp+0x30],r13
    13a5:	mov    r12,rdi
    13a8:	mov    r13,rdx
    13ab:	mov    QWORD PTR [rsp+0x10],0x0
    13b4:	mov    QWORD PTR [rsp],rsi
    13b8:	mov    rbx,rsi
    13bb:	mov    QWORD PTR [rsp+0x8],rdx
    13c0:	mov    rdx,r13
    13c3:	mov    rsi,rbx
    13c6:	mov    rdi,r12
    13c9:	call   13ce <botlish_fn_10+0x40>
			13ca: R_X86_64_PLT32	botlish_fn_7-0x4 ; quote_at?<str, int>
    13ce:	test   rax,rax
    13d1:	je     1482 <botlish_fn_10+0xf4>
    13d7:	cmp    rax,0x6
    13db:	je     1413 <botlish_fn_10+0x85>
    13e1:	mov    rcx,r13
    13e4:	mov    rsi,rbx
    13e7:	mov    rdi,r12
    13ea:	mov    rdx,rcx
    13ed:	call   13f2 <botlish_fn_10+0x64>
			13ee: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_unquoted<str, int, int>
    13f2:	test   rax,rax
    13f5:	je     1482 <botlish_fn_10+0xf4>
    13fb:	mov    rbx,QWORD PTR [rsp+0x20]
    1400:	mov    r12,QWORD PTR [rsp+0x28]
    1405:	mov    r13,QWORD PTR [rsp+0x30]
    140a:	add    rsp,0x40
    140e:	mov    rsp,rbp
    1411:	pop    rbp
    1412:	ret
    1413:	mov    rcx,r13
    1416:	mov    QWORD PTR [rsp+0x10],0x3
    141f:	test   rcx,0x1
    1426:	jne    1434 <botlish_fn_10+0xa6>
    142c:	mov    r13,rcx
    142f:	jmp    1449 <botlish_fn_10+0xbb>
    1434:	mov    rdx,rcx
    1437:	add    rdx,0x2
    143b:	mov    r13,rcx
    143e:	seto   al
    1441:	test   al,al
    1443:	je     145c <botlish_fn_10+0xce>
    1449:	mov    edx,0x3
    144e:	mov    rsi,r13
    1451:	mov    rdi,r12
    1454:	call   1459 <botlish_fn_10+0xcb>
			1455: R_X86_64_PLT32	rt_int_add-0x4
    1459:	mov    rdx,rax
    145c:	mov    QWORD PTR [rsp+0x8],rdx
    1461:	mov    rdi,r12
    1464:	mov    rax,QWORD PTR [rdi+0x10]
    1468:	mov    rcx,QWORD PTR [rax+0x10]
    146c:	mov    QWORD PTR [rsp+0x10],rcx
    1471:	mov    rsi,rbx
    1474:	call   1479 <botlish_fn_10+0xeb>
			1475: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_quoted<str, int, str>
    1479:	test   rax,rax
    147c:	jne    14a0 <botlish_fn_10+0x112>
    1482:	xor    rdx,rdx
    1485:	mov    rax,rdx
    1488:	mov    rbx,QWORD PTR [rsp+0x20]
    148d:	mov    r12,QWORD PTR [rsp+0x28]
    1492:	mov    r13,QWORD PTR [rsp+0x30]
    1497:	add    rsp,0x40
    149b:	mov    rsp,rbp
    149e:	pop    rbp
    149f:	ret
    14a0:	mov    rbx,QWORD PTR [rsp+0x20]
    14a5:	mov    r12,QWORD PTR [rsp+0x28]
    14aa:	mov    r13,QWORD PTR [rsp+0x30]
    14af:	add    rsp,0x40
    14b3:	mov    rsp,rbp
    14b6:	pop    rbp
    14b7:	ret

00000000000014b8 <botlish_entry_10: scan_field<str, int>>:
    14b8:	push   rbp
    14b9:	mov    rbp,rsp
    14bc:	ud2
	...

00000000000014c0 <botlish_fn_11: scan_record<str, int, ChunkedBuilder>>:
    14c0:	push   rbp
    14c1:	mov    rbp,rsp
    14c4:	sub    rsp,0x40
    14c8:	mov    QWORD PTR [rsp+0x20],rbx
    14cd:	mov    QWORD PTR [rsp+0x28],r12
    14d2:	mov    QWORD PTR [rsp+0x30],r13
    14d7:	mov    QWORD PTR [rsp+0x38],r14
    14dc:	mov    r12,rdi
    14df:	mov    QWORD PTR [rsp+0x18],0x0
    14e8:	mov    QWORD PTR [rsp],rsi
    14ec:	mov    QWORD PTR [rsp+0x8],rdx
    14f1:	mov    QWORD PTR [rsp+0x10],rcx
    14f6:	mov    rbx,rsi
    14f9:	mov    r13,rcx
    14fc:	mov    rsi,rbx
    14ff:	mov    rdi,r12
    1502:	call   1507 <botlish_fn_11+0x47>
			1503: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_field<str, int>
    1507:	test   rax,rax
    150a:	je     161c <botlish_fn_11+0x15c>
    1510:	mov    QWORD PTR [rsp+0x8],rax
    1515:	mov    QWORD PTR [rsp+0x18],rdx
    151a:	mov    rsi,r13
    151d:	mov    r13,rdx
    1520:	mov    rdx,rax
    1523:	mov    rdi,r12
    1526:	call   152b <botlish_fn_11+0x6b>
			1527: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<ChunkedBuilder, str>
    152b:	test   rax,rax
    152e:	je     161c <botlish_fn_11+0x15c>
    1534:	mov    QWORD PTR [rsp+0x8],rax
    1539:	mov    r14,rax
    153c:	mov    rdx,QWORD PTR [rbx+0x8]
    1540:	shl    rdx,1
    1543:	or     rdx,0x1
    1547:	mov    rsi,r13
    154a:	mov    rax,rsi
    154d:	and    rax,rdx
    1550:	test   rax,0x1
    1556:	jne    157c <botlish_fn_11+0xbc>
    155c:	mov    rsi,r13
    155f:	mov    rdi,r12
    1562:	call   1567 <botlish_fn_11+0xa7>
			1563: R_X86_64_PLT32	rt_int_cmp-0x4
    1567:	mov    ecx,0x2
    156c:	test   rax,rax
    156f:	cmovl  rcx,QWORD PTR [rip+0x199]        # 1710 <botlish_fn_11+0x250>
    1577:	jmp    158f <botlish_fn_11+0xcf>
    157c:	mov    ecx,0x2
    1581:	mov    rax,r13
    1584:	cmp    rax,rdx
    1587:	cmovl  rcx,QWORD PTR [rip+0x181]        # 1710 <botlish_fn_11+0x250>
    158f:	cmp    rcx,0x6
    1593:	je     15a4 <botlish_fn_11+0xe4>
    1599:	mov    rsi,r14
    159c:	mov    rdi,r12
    159f:	jmp    15d7 <botlish_fn_11+0x117>
    15a4:	mov    rdx,r13
    15a7:	mov    rsi,rbx
    15aa:	mov    rdi,r12
    15ad:	call   15b2 <botlish_fn_11+0xf2>
			15ae: R_X86_64_PLT32	rt_str_char_at-0x4
    15b2:	test   rax,rax
    15b5:	je     161c <botlish_fn_11+0x15c>
    15bb:	cmp    rax,0x164
    15c1:	je     16ac <botlish_fn_11+0x1ec>
    15c7:	cmp    rax,0x54
    15cb:	je     1608 <botlish_fn_11+0x148>
    15d1:	mov    rsi,r14
    15d4:	mov    rdi,r12
    15d7:	mov    rdi,r12
    15da:	call   15df <botlish_fn_11+0x11f>
			15db: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_finish<ChunkedBuilder>
    15df:	test   rax,rax
    15e2:	je     161c <botlish_fn_11+0x15c>
    15e8:	mov    rdx,r13
    15eb:	mov    rbx,QWORD PTR [rsp+0x20]
    15f0:	mov    r12,QWORD PTR [rsp+0x28]
    15f5:	mov    r13,QWORD PTR [rsp+0x30]
    15fa:	mov    r14,QWORD PTR [rsp+0x38]
    15ff:	add    rsp,0x40
    1603:	mov    rsp,rbp
    1606:	pop    rbp
    1607:	ret
    1608:	mov    rsi,r14
    160b:	mov    rdi,r12
    160e:	call   1613 <botlish_fn_11+0x153>
			160f: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_finish<ChunkedBuilder>
    1613:	test   rax,rax
    1616:	jne    163f <botlish_fn_11+0x17f>
    161c:	xor    rdx,rdx
    161f:	mov    rax,rdx
    1622:	mov    rbx,QWORD PTR [rsp+0x20]
    1627:	mov    r12,QWORD PTR [rsp+0x28]
    162c:	mov    r13,QWORD PTR [rsp+0x30]
    1631:	mov    r14,QWORD PTR [rsp+0x38]
    1636:	add    rsp,0x40
    163a:	mov    rsp,rbp
    163d:	pop    rbp
    163e:	ret
    163f:	mov    QWORD PTR [rsp],rax
    1643:	mov    rbx,rax
    1646:	mov    QWORD PTR [rsp+0x8],0x3
    164f:	mov    rdx,r13
    1652:	test   rdx,0x1
    1659:	je     1679 <botlish_fn_11+0x1b9>
    165f:	mov    rdx,r13
    1662:	add    rdx,0x2
    1666:	seto   al
    1669:	test   al,al
    166b:	jne    1679 <botlish_fn_11+0x1b9>
    1671:	mov    rax,rbx
    1674:	jmp    168f <botlish_fn_11+0x1cf>
    1679:	mov    edx,0x3
    167e:	mov    rsi,r13
    1681:	mov    rdi,r12
    1684:	call   1689 <botlish_fn_11+0x1c9>
			1685: R_X86_64_PLT32	rt_int_add-0x4
    1689:	mov    rdx,rax
    168c:	mov    rax,rbx
    168f:	mov    rbx,QWORD PTR [rsp+0x20]
    1694:	mov    r12,QWORD PTR [rsp+0x28]
    1699:	mov    r13,QWORD PTR [rsp+0x30]
    169e:	mov    r14,QWORD PTR [rsp+0x38]
    16a3:	add    rsp,0x40
    16a7:	mov    rsp,rbp
    16aa:	pop    rbp
    16ab:	ret
    16ac:	mov    rsi,r13
    16af:	mov    edx,0x3
    16b4:	mov    rcx,rdx
    16b7:	mov    QWORD PTR [rsp+0x10],0x3
    16c0:	test   rsi,0x1
    16c7:	jne    16d5 <botlish_fn_11+0x215>
    16cd:	mov    rdx,rcx
    16d0:	jmp    16ea <botlish_fn_11+0x22a>
    16d5:	mov    rdx,rsi
    16d8:	add    rdx,0x2
    16dc:	seto   al
    16df:	test   al,al
    16e1:	je     16f5 <botlish_fn_11+0x235>
    16e7:	mov    rdx,rcx
    16ea:	mov    rdi,r12
    16ed:	call   16f2 <botlish_fn_11+0x232>
			16ee: R_X86_64_PLT32	rt_int_add-0x4
    16f2:	mov    rdx,rax
    16f5:	mov    QWORD PTR [rsp],rbx
    16f9:	mov    QWORD PTR [rsp+0x8],rdx
    16fe:	mov    rsi,r14
    1701:	mov    QWORD PTR [rsp+0x10],rsi
    1706:	mov    r13,rsi
    1709:	jmp    14fc <botlish_fn_11+0x3c>
    170e:	add    BYTE PTR [rax],al
    1710:	(bad)
    1711:	add    BYTE PTR [rax],al
    1713:	add    BYTE PTR [rax],al
    1715:	add    BYTE PTR [rax],al
	...

0000000000001718 <botlish_entry_11: scan_record<str, int, ChunkedBuilder>>:
    1718:	push   rbp
    1719:	mov    rbp,rsp
    171c:	ud2
	...

0000000000001720 <botlish_fn_12: scan_records<str, int, ChunkedBuilder>>:
    1720:	push   rbp
    1721:	mov    rbp,rsp
    1724:	sub    rsp,0x40
    1728:	mov    QWORD PTR [rsp+0x20],rbx
    172d:	mov    QWORD PTR [rsp+0x28],r12
    1732:	mov    QWORD PTR [rsp+0x30],r13
    1737:	mov    QWORD PTR [rsp+0x38],r14
    173c:	mov    r13,rdi
    173f:	mov    QWORD PTR [rsp+0x18],0x0
    1748:	mov    QWORD PTR [rsp],rsi
    174c:	mov    QWORD PTR [rsp+0x8],rdx
    1751:	mov    r12,rdx
    1754:	mov    QWORD PTR [rsp+0x10],rcx
    1759:	mov    rbx,rsi
    175c:	mov    r14,rcx
    175f:	mov    rdx,QWORD PTR [rbx+0x8]
    1763:	shl    rdx,1
    1766:	or     rdx,0x1
    176a:	mov    rax,r12
    176d:	and    rax,rdx
    1770:	test   rax,0x1
    1776:	jne    179c <botlish_fn_12+0x7c>
    177c:	mov    rsi,r12
    177f:	mov    rdi,r13
    1782:	call   1787 <botlish_fn_12+0x67>
			1783: R_X86_64_PLT32	rt_int_cmp-0x4
    1787:	mov    ecx,0x2
    178c:	test   rax,rax
    178f:	cmovge rcx,QWORD PTR [rip+0xe1]        # 1878 <botlish_fn_12+0x158>
    1797:	jmp    17af <botlish_fn_12+0x8f>
    179c:	mov    ecx,0x2
    17a1:	mov    rax,r12
    17a4:	cmp    rax,rdx
    17a7:	cmovge rcx,QWORD PTR [rip+0xc9]        # 1878 <botlish_fn_12+0x158>
    17af:	cmp    rcx,0x6
    17b3:	je     1826 <botlish_fn_12+0x106>
    17b9:	mov    rdi,r13
    17bc:	call   17c1 <botlish_fn_12+0xa1>
			17bd: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    17c1:	test   rax,rax
    17c4:	je     183a <botlish_fn_12+0x11a>
    17ca:	mov    QWORD PTR [rsp+0x18],rax
    17cf:	mov    rcx,rax
    17d2:	mov    rdx,r12
    17d5:	mov    rsi,rbx
    17d8:	mov    rdi,r13
    17db:	call   17e0 <botlish_fn_12+0xc0>
			17dc: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_record<str, int, ChunkedBuilder>
    17e0:	test   rax,rax
    17e3:	je     183a <botlish_fn_12+0x11a>
    17e9:	mov    QWORD PTR [rsp+0x8],rax
    17ee:	mov    QWORD PTR [rsp+0x18],rdx
    17f3:	mov    r12,rdx
    17f6:	mov    rsi,r14
    17f9:	mov    rdx,rax
    17fc:	mov    rdi,r13
    17ff:	call   1804 <botlish_fn_12+0xe4>
			1800: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<ChunkedBuilder, list>
    1804:	test   rax,rax
    1807:	je     183a <botlish_fn_12+0x11a>
    180d:	mov    QWORD PTR [rsp],rbx
    1811:	mov    rdx,r12
    1814:	mov    QWORD PTR [rsp+0x8],rdx
    1819:	mov    QWORD PTR [rsp+0x10],rax
    181e:	mov    r14,rax
    1821:	jmp    175f <botlish_fn_12+0x3f>
    1826:	mov    rsi,r14
    1829:	mov    rdi,r13
    182c:	call   1831 <botlish_fn_12+0x111>
			182d: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_finish<ChunkedBuilder>
    1831:	test   rax,rax
    1834:	jne    185a <botlish_fn_12+0x13a>
    183a:	xor    rax,rax
    183d:	mov    rbx,QWORD PTR [rsp+0x20]
    1842:	mov    r12,QWORD PTR [rsp+0x28]
    1847:	mov    r13,QWORD PTR [rsp+0x30]
    184c:	mov    r14,QWORD PTR [rsp+0x38]
    1851:	add    rsp,0x40
    1855:	mov    rsp,rbp
    1858:	pop    rbp
    1859:	ret
    185a:	mov    rbx,QWORD PTR [rsp+0x20]
    185f:	mov    r12,QWORD PTR [rsp+0x28]
    1864:	mov    r13,QWORD PTR [rsp+0x30]
    1869:	mov    r14,QWORD PTR [rsp+0x38]
    186e:	add    rsp,0x40
    1872:	mov    rsp,rbp
    1875:	pop    rbp
    1876:	ret
    1877:	add    BYTE PTR [rsi],al
    1879:	add    BYTE PTR [rax],al
    187b:	add    BYTE PTR [rax],al
    187d:	add    BYTE PTR [rax],al
	...

0000000000001880 <botlish_entry_12: scan_records<str, int, ChunkedBuilder>>:
    1880:	push   rbp
    1881:	mov    rbp,rsp
    1884:	mov    rsi,QWORD PTR [rdx]
    1887:	mov    r8,QWORD PTR [rdx+0x8]
    188b:	mov    rcx,QWORD PTR [rdx+0x10]
    188f:	mov    rdx,r8
    1892:	call   1897 <botlish_entry_12+0x17>
			1893: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_records<str, int, ChunkedBuilder>
    1897:	mov    rsp,rbp
    189a:	pop    rbp
    189b:	ret

000000000000189c <botlish_fn_13: csv_parse<str>>:
    189c:	push   rbp
    189d:	mov    rbp,rsp
    18a0:	sub    rsp,0x30
    18a4:	mov    QWORD PTR [rsp+0x20],r12
    18a9:	mov    QWORD PTR [rsp+0x28],r13
    18ae:	mov    r13,rdi
    18b1:	mov    QWORD PTR [rsp+0x10],0x0
    18ba:	mov    QWORD PTR [rsp],rsi
    18be:	mov    r12,rsi
    18c1:	mov    QWORD PTR [rsp+0x8],0x1
    18ca:	mov    rdi,r13
    18cd:	call   18d2 <botlish_fn_13+0x36>
			18ce: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    18d2:	test   rax,rax
    18d5:	je     18fc <botlish_fn_13+0x60>
    18db:	mov    QWORD PTR [rsp+0x10],rax
    18e0:	mov    rcx,rax
    18e3:	mov    edx,0x1
    18e8:	mov    rsi,r12
    18eb:	mov    rdi,r13
    18ee:	call   18f3 <botlish_fn_13+0x57>
			18ef: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_records<str, int, ChunkedBuilder>
    18f3:	test   rax,rax
    18f6:	jne    1912 <botlish_fn_13+0x76>
    18fc:	xor    rax,rax
    18ff:	mov    r12,QWORD PTR [rsp+0x20]
    1904:	mov    r13,QWORD PTR [rsp+0x28]
    1909:	add    rsp,0x30
    190d:	mov    rsp,rbp
    1910:	pop    rbp
    1911:	ret
    1912:	mov    r12,QWORD PTR [rsp+0x20]
    1917:	mov    r13,QWORD PTR [rsp+0x28]
    191c:	add    rsp,0x30
    1920:	mov    rsp,rbp
    1923:	pop    rbp
    1924:	ret

0000000000001925 <botlish_entry_13: csv_parse<str>>:
    1925:	push   rbp
    1926:	mov    rbp,rsp
    1929:	mov    rsi,QWORD PTR [rdx]
    192c:	call   1931 <botlish_entry_13+0xc>
			192d: R_X86_64_PLT32	botlish_fn_13-0x4 ; csv_parse<str>
    1931:	mov    rsp,rbp
    1934:	pop    rbp
    1935:	ret

; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 13223  (per function: 181 28 333 726 726 726 726 824 752 734 734 365 430 703 925 482 1013 1030 694 780 311)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> chunk_size<generic>
;   botlish_fn_2 / botlish_entry_2 -> chunked_new<generic>
;   botlish_fn_3 / botlish_entry_3 -> chunked_append<list[list<never>, mutarray, int], str>
;   botlish_fn_4 / botlish_entry_4 -> chunked_append<list[list<mutarray>, mutarray, int], str>
;   botlish_fn_5 / botlish_entry_5 -> chunked_append<list[list<never>, mutarray, int], list>
;   botlish_fn_6 / botlish_entry_6 -> chunked_append<list[list<mutarray>, mutarray, int], list>
;   botlish_fn_7 / botlish_entry_7 -> chunked_copy_chunks<list<never>, int, mutarray, int>
;   botlish_fn_8 / botlish_entry_8 -> chunked_copy_chunks<list<mutarray>, int, mutarray, int>
;   botlish_fn_9 / botlish_entry_9 -> chunked_finish<list[list<never>, mutarray, int]>
;   botlish_fn_10 / botlish_entry_10 -> chunked_finish<list[list<mutarray>, mutarray, int]>
;   botlish_fn_11 / botlish_entry_11 -> peek<str, int>
;   botlish_fn_12 / botlish_entry_12 -> peek<str, int>
;   botlish_fn_13 / botlish_entry_13 -> scan_unquoted<str, int, int>
;   botlish_fn_14 / botlish_entry_14 -> scan_quoted<str, int, str>
;   botlish_fn_15 / botlish_entry_15 -> scan_field<str, int>
;   botlish_fn_16 / botlish_entry_16 -> scan_record<str, int, list[list<never>, mutarray, int]>
;   botlish_fn_17 / botlish_entry_17 -> scan_record<str, int, list[list<mutarray>, mutarray, int]>
;   botlish_fn_18 / botlish_entry_18 -> scan_records<str, int, list[list<never>, mutarray, int]>
;   botlish_fn_19 / botlish_entry_19 -> scan_records<str, int, list[list<mutarray>, mutarray, int]>
;   botlish_fn_20 / botlish_entry_20 -> csv_parse<str>


csv_chunked.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x20
       8:	mov    QWORD PTR [rsp+0x10],r13
       d:	mov    QWORD PTR [rsp+0x18],r14
      12:	mov    r13,QWORD PTR [rdi]
      15:	mov    rax,QWORD PTR [rdi+0x8]
      19:	lea    rcx,[r13+0x8]
      1d:	cmp    rcx,rax
      20:	ja     86 <botlish_fn_0+0x86>
      26:	lea    rax,[r13+0x8]
      2a:	mov    QWORD PTR [rdi],rax
      2d:	mov    QWORD PTR [r13+0x0],0x0
      35:	mov    rax,QWORD PTR [rdi+0x10]
      39:	mov    r14,rdi
      3c:	mov    rsi,QWORD PTR [rax]
      3f:	mov    QWORD PTR [rsp],rsi
      43:	call   48 <botlish_fn_0+0x48>
			44: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
      48:	test   rax,rax
      4b:	jne    6d <botlish_fn_0+0x6d>
      51:	mov    rdi,r14
      54:	mov    QWORD PTR [rdi],r13
      57:	xor    rax,rax
      5a:	mov    r13,QWORD PTR [rsp+0x10]
      5f:	mov    r14,QWORD PTR [rsp+0x18]
      64:	add    rsp,0x20
      68:	mov    rsp,rbp
      6b:	pop    rbp
      6c:	ret
      6d:	mov    rdi,r14
      70:	mov    QWORD PTR [rdi],r13
      73:	mov    r13,QWORD PTR [rsp+0x10]
      78:	mov    r14,QWORD PTR [rsp+0x18]
      7d:	add    rsp,0x20
      81:	mov    rsp,rbp
      84:	pop    rbp
      85:	ret
      86:	call   8b <botlish_fn_0+0x8b>
			87: R_X86_64_PLT32	rt_stack_overflow-0x4
      8b:	xor    rax,rax
      8e:	mov    r13,QWORD PTR [rsp+0x10]
      93:	mov    r14,QWORD PTR [rsp+0x18]
      98:	add    rsp,0x20
      9c:	mov    rsp,rbp
      9f:	pop    rbp
      a0:	ret

00000000000000a1 <botlish_entry_0: <program entry>>:
      a1:	push   rbp
      a2:	mov    rbp,rsp
      a5:	call   aa <botlish_entry_0+0x9>
			a6: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      aa:	mov    rsp,rbp
      ad:	pop    rbp
      ae:	ret

00000000000000af <botlish_fn_1: chunk_size<generic>>:
      af:	push   rbp
      b0:	mov    rbp,rsp
      b3:	mov    eax,0x81
      b8:	mov    rsp,rbp
      bb:	pop    rbp
      bc:	ret

00000000000000bd <botlish_entry_1: chunk_size<generic>>:
      bd:	push   rbp
      be:	mov    rbp,rsp
      c1:	call   c6 <botlish_entry_1+0x9>
			c2: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
      c6:	mov    rsp,rbp
      c9:	pop    rbp
      ca:	ret

00000000000000cb <botlish_fn_2: chunked_new<generic>>:
      cb:	push   rbp
      cc:	mov    rbp,rsp
      cf:	sub    rsp,0x30
      d3:	mov    QWORD PTR [rsp+0x10],rbx
      d8:	mov    QWORD PTR [rsp+0x18],r12
      dd:	mov    QWORD PTR [rsp+0x20],r13
      e2:	mov    QWORD PTR [rsp+0x28],r14
      e7:	mov    r13,rsi
      ea:	mov    rbx,QWORD PTR [rdi]
      ed:	mov    rax,QWORD PTR [rdi+0x8]
      f1:	lea    rcx,[rbx+0x8]
      f5:	cmp    rcx,rax
      f8:	ja     1d5 <botlish_fn_2+0x10a>
      fe:	lea    rax,[rbx+0x8]
     102:	mov    QWORD PTR [rdi],rax
     105:	mov    r12,rdi
     108:	mov    QWORD PTR [rbx],0x0
     10f:	mov    QWORD PTR [rsp],0x0
     117:	mov    QWORD PTR [rsp+0x8],0x0
     120:	xor    rdx,rdx
     123:	mov    rdi,r12
     126:	mov    rsi,rdx
     129:	call   12e <botlish_fn_2+0x63>
			12a: R_X86_64_PLT32	rt_list_new-0x4
     12e:	test   rax,rax
     131:	jne    13f <botlish_fn_2+0x74>
     137:	mov    rdi,r12
     13a:	jmp    17b <botlish_fn_2+0xb0>
     13f:	mov    QWORD PTR [rsp],rax
     143:	mov    r14,rax
     146:	mov    rdi,r12
     149:	call   14e <botlish_fn_2+0x83>
			14a: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     14e:	test   rax,rax
     151:	jne    15f <botlish_fn_2+0x94>
     157:	mov    rdi,r12
     15a:	jmp    17b <botlish_fn_2+0xb0>
     15f:	mov    QWORD PTR [rsp+0x8],rax
     164:	mov    rsi,rax
     167:	mov    rdi,r12
     16a:	call   16f <botlish_fn_2+0xa4>
			16b: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     16f:	test   rax,rax
     172:	jne    1a1 <botlish_fn_2+0xd6>
     178:	mov    rdi,r12
     17b:	mov    rdi,r12
     17e:	mov    QWORD PTR [rdi],rbx
     181:	xor    rax,rax
     184:	mov    rbx,QWORD PTR [rsp+0x10]
     189:	mov    r12,QWORD PTR [rsp+0x18]
     18e:	mov    r13,QWORD PTR [rsp+0x20]
     193:	mov    r14,QWORD PTR [rsp+0x28]
     198:	add    rsp,0x30
     19c:	mov    rsp,rbp
     19f:	pop    rbp
     1a0:	ret
     1a1:	mov    rdi,r12
     1a4:	mov    QWORD PTR [rdi],rbx
     1a7:	mov    rsi,r13
     1aa:	mov    QWORD PTR [rsi],rax
     1ad:	mov    QWORD PTR [rsi+0x8],0x1
     1b5:	mov    rax,r14
     1b8:	mov    rbx,QWORD PTR [rsp+0x10]
     1bd:	mov    r12,QWORD PTR [rsp+0x18]
     1c2:	mov    r13,QWORD PTR [rsp+0x20]
     1c7:	mov    r14,QWORD PTR [rsp+0x28]
     1cc:	add    rsp,0x30
     1d0:	mov    rsp,rbp
     1d3:	pop    rbp
     1d4:	ret
     1d5:	mov    r12,rdi
     1d8:	call   1dd <botlish_fn_2+0x112>
			1d9: R_X86_64_PLT32	rt_stack_overflow-0x4
     1dd:	xor    rax,rax
     1e0:	mov    rbx,QWORD PTR [rsp+0x10]
     1e5:	mov    r12,QWORD PTR [rsp+0x18]
     1ea:	mov    r13,QWORD PTR [rsp+0x20]
     1ef:	mov    r14,QWORD PTR [rsp+0x28]
     1f4:	add    rsp,0x30
     1f8:	mov    rsp,rbp
     1fb:	pop    rbp
     1fc:	ret

00000000000001fd <botlish_entry_2: chunked_new<generic>>:
     1fd:	push   rbp
     1fe:	mov    rbp,rsp
     201:	ud2
     203:	add    BYTE PTR [rax],al
     205:	add    BYTE PTR [rax],al
	...

0000000000000208 <botlish_fn_3: chunked_append<list[list<never>, mutarray, int], str>>:
     208:	push   rbp
     209:	mov    rbp,rsp
     20c:	sub    rsp,0x60
     210:	mov    QWORD PTR [rsp+0x30],rbx
     215:	mov    QWORD PTR [rsp+0x38],r12
     21a:	mov    QWORD PTR [rsp+0x40],r13
     21f:	mov    QWORD PTR [rsp+0x48],r14
     224:	mov    QWORD PTR [rsp+0x50],r15
     229:	mov    rbx,r9
     22c:	mov    r13,QWORD PTR [rdi]
     22f:	mov    rax,QWORD PTR [rdi+0x8]
     233:	lea    r9,[r13+0x8]
     237:	cmp    r9,rax
     23a:	ja     468 <botlish_fn_3+0x260>
     240:	lea    rax,[r13+0x8]
     244:	mov    QWORD PTR [rdi],rax
     247:	mov    r14,rdi
     24a:	mov    QWORD PTR [r13+0x0],0x0
     252:	mov    QWORD PTR [rsp],rsi
     256:	mov    r15,rsi
     259:	mov    QWORD PTR [rsp+0x8],rdx
     25e:	mov    QWORD PTR [rsp+0x20],rdx
     263:	mov    QWORD PTR [rsp+0x10],rcx
     268:	mov    r12,rcx
     26b:	mov    QWORD PTR [rsp+0x18],r8
     270:	mov    QWORD PTR [rsp+0x28],r8
     275:	mov    rdi,r14
     278:	call   27d <botlish_fn_3+0x75>
			279: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     27d:	test   rax,rax
     280:	jne    28e <botlish_fn_3+0x86>
     286:	mov    rdi,r14
     289:	jmp    404 <botlish_fn_3+0x1fc>
     28e:	mov    rcx,r12
     291:	and    rcx,rax
     294:	mov    rdx,rax
     297:	test   rcx,0x1
     29e:	jne    2c4 <botlish_fn_3+0xbc>
     2a4:	mov    rsi,r12
     2a7:	mov    rdi,r14
     2aa:	call   2af <botlish_fn_3+0xa7>
			2ab: R_X86_64_PLT32	rt_int_cmp-0x4
     2af:	mov    ecx,0x2
     2b4:	test   rax,rax
     2b7:	cmove  rcx,QWORD PTR [rip+0x1d9]        # 498 <botlish_fn_3+0x290>
     2bf:	jmp    2d4 <botlish_fn_3+0xcc>
     2c4:	mov    ecx,0x2
     2c9:	cmp    r12,rdx
     2cc:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 498 <botlish_fn_3+0x290>
     2d4:	cmp    rcx,0x6
     2d8:	je     37e <botlish_fn_3+0x176>
     2de:	mov    rcx,QWORD PTR [rsp+0x28]
     2e3:	mov    rdx,r12
     2e6:	mov    rsi,QWORD PTR [rsp+0x20]
     2eb:	mov    rdi,r14
     2ee:	call   2f3 <botlish_fn_3+0xeb>
			2ef: R_X86_64_PLT32	rt_mutarray_set-0x4
     2f3:	test   rax,rax
     2f6:	jne    304 <botlish_fn_3+0xfc>
     2fc:	mov    rdi,r14
     2ff:	jmp    404 <botlish_fn_3+0x1fc>
     304:	mov    QWORD PTR [rsp+0x18],0x3
     30d:	test   r12,0x1
     314:	je     334 <botlish_fn_3+0x12c>
     31a:	mov    rax,r12
     31d:	add    rax,0x2
     321:	seto   cl
     324:	test   cl,cl
     326:	jne    334 <botlish_fn_3+0x12c>
     32c:	mov    rdi,r14
     32f:	jmp    347 <botlish_fn_3+0x13f>
     334:	mov    edx,0x3
     339:	mov    rsi,r12
     33c:	mov    rdi,r14
     33f:	call   344 <botlish_fn_3+0x13c>
			340: R_X86_64_PLT32	rt_int_add-0x4
     344:	mov    rdi,r14
     347:	mov    rdi,r14
     34a:	mov    QWORD PTR [rdi],r13
     34d:	mov    rdx,QWORD PTR [rsp+0x20]
     352:	mov    QWORD PTR [rbx],rdx
     355:	mov    QWORD PTR [rbx+0x8],rax
     359:	mov    rax,r15
     35c:	mov    rbx,QWORD PTR [rsp+0x30]
     361:	mov    r12,QWORD PTR [rsp+0x38]
     366:	mov    r13,QWORD PTR [rsp+0x40]
     36b:	mov    r14,QWORD PTR [rsp+0x48]
     370:	mov    r15,QWORD PTR [rsp+0x50]
     375:	add    rsp,0x60
     379:	mov    rsp,rbp
     37c:	pop    rbp
     37d:	ret
     37e:	mov    rdx,QWORD PTR [rsp+0x20]
     383:	mov    rsi,r15
     386:	mov    rdi,r14
     389:	call   38e <botlish_fn_3+0x186>
			38a: R_X86_64_PLT32	rt_list_append-0x4
     38e:	test   rax,rax
     391:	jne    39f <botlish_fn_3+0x197>
     397:	mov    rdi,r14
     39a:	jmp    404 <botlish_fn_3+0x1fc>
     39f:	mov    QWORD PTR [rsp],rax
     3a3:	mov    r12,rax
     3a6:	mov    rdi,r14
     3a9:	call   3ae <botlish_fn_3+0x1a6>
			3aa: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     3ae:	test   rax,rax
     3b1:	jne    3bf <botlish_fn_3+0x1b7>
     3b7:	mov    rdi,r14
     3ba:	jmp    404 <botlish_fn_3+0x1fc>
     3bf:	mov    QWORD PTR [rsp+0x8],rax
     3c4:	mov    rsi,rax
     3c7:	mov    rdi,r14
     3ca:	call   3cf <botlish_fn_3+0x1c7>
			3cb: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     3cf:	test   rax,rax
     3d2:	mov    r15,rax
     3d5:	jne    3e3 <botlish_fn_3+0x1db>
     3db:	mov    rdi,r14
     3de:	jmp    404 <botlish_fn_3+0x1fc>
     3e3:	mov    edx,0x1
     3e8:	mov    rcx,QWORD PTR [rsp+0x28]
     3ed:	mov    rsi,r15
     3f0:	mov    rdi,r14
     3f3:	call   3f8 <botlish_fn_3+0x1f0>
			3f4: R_X86_64_PLT32	rt_mutarray_set-0x4
     3f8:	test   rax,rax
     3fb:	jne    42f <botlish_fn_3+0x227>
     401:	mov    rdi,r14
     404:	mov    rdi,r14
     407:	mov    QWORD PTR [rdi],r13
     40a:	xor    rax,rax
     40d:	mov    rbx,QWORD PTR [rsp+0x30]
     412:	mov    r12,QWORD PTR [rsp+0x38]
     417:	mov    r13,QWORD PTR [rsp+0x40]
     41c:	mov    r14,QWORD PTR [rsp+0x48]
     421:	mov    r15,QWORD PTR [rsp+0x50]
     426:	add    rsp,0x60
     42a:	mov    rsp,rbp
     42d:	pop    rbp
     42e:	ret
     42f:	mov    rdi,r14
     432:	mov    QWORD PTR [rdi],r13
     435:	mov    rax,r15
     438:	mov    QWORD PTR [rbx],rax
     43b:	mov    QWORD PTR [rbx+0x8],0x3
     443:	mov    rax,r12
     446:	mov    rbx,QWORD PTR [rsp+0x30]
     44b:	mov    r12,QWORD PTR [rsp+0x38]
     450:	mov    r13,QWORD PTR [rsp+0x40]
     455:	mov    r14,QWORD PTR [rsp+0x48]
     45a:	mov    r15,QWORD PTR [rsp+0x50]
     45f:	add    rsp,0x60
     463:	mov    rsp,rbp
     466:	pop    rbp
     467:	ret
     468:	mov    r14,rdi
     46b:	call   470 <botlish_fn_3+0x268>
			46c: R_X86_64_PLT32	rt_stack_overflow-0x4
     470:	xor    rax,rax
     473:	mov    rbx,QWORD PTR [rsp+0x30]
     478:	mov    r12,QWORD PTR [rsp+0x38]
     47d:	mov    r13,QWORD PTR [rsp+0x40]
     482:	mov    r14,QWORD PTR [rsp+0x48]
     487:	mov    r15,QWORD PTR [rsp+0x50]
     48c:	add    rsp,0x60
     490:	mov    rsp,rbp
     493:	pop    rbp
     494:	ret
     495:	add    BYTE PTR [rax],al
     497:	add    BYTE PTR [rsi],al
     499:	add    BYTE PTR [rax],al
     49b:	add    BYTE PTR [rax],al
     49d:	add    BYTE PTR [rax],al
	...

00000000000004a0 <botlish_entry_3: chunked_append<list[list<never>, mutarray, int], str>>:
     4a0:	push   rbp
     4a1:	mov    rbp,rsp
     4a4:	ud2
	...

00000000000004a8 <botlish_fn_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     4a8:	push   rbp
     4a9:	mov    rbp,rsp
     4ac:	sub    rsp,0x60
     4b0:	mov    QWORD PTR [rsp+0x30],rbx
     4b5:	mov    QWORD PTR [rsp+0x38],r12
     4ba:	mov    QWORD PTR [rsp+0x40],r13
     4bf:	mov    QWORD PTR [rsp+0x48],r14
     4c4:	mov    QWORD PTR [rsp+0x50],r15
     4c9:	mov    rbx,r9
     4cc:	mov    r13,QWORD PTR [rdi]
     4cf:	mov    rax,QWORD PTR [rdi+0x8]
     4d3:	lea    r9,[r13+0x8]
     4d7:	cmp    r9,rax
     4da:	ja     708 <botlish_fn_4+0x260>
     4e0:	lea    rax,[r13+0x8]
     4e4:	mov    QWORD PTR [rdi],rax
     4e7:	mov    r14,rdi
     4ea:	mov    QWORD PTR [r13+0x0],0x0
     4f2:	mov    QWORD PTR [rsp],rsi
     4f6:	mov    r15,rsi
     4f9:	mov    QWORD PTR [rsp+0x8],rdx
     4fe:	mov    QWORD PTR [rsp+0x20],rdx
     503:	mov    QWORD PTR [rsp+0x10],rcx
     508:	mov    r12,rcx
     50b:	mov    QWORD PTR [rsp+0x18],r8
     510:	mov    QWORD PTR [rsp+0x28],r8
     515:	mov    rdi,r14
     518:	call   51d <botlish_fn_4+0x75>
			519: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     51d:	test   rax,rax
     520:	jne    52e <botlish_fn_4+0x86>
     526:	mov    rdi,r14
     529:	jmp    6a4 <botlish_fn_4+0x1fc>
     52e:	mov    rcx,r12
     531:	and    rcx,rax
     534:	mov    rdx,rax
     537:	test   rcx,0x1
     53e:	jne    564 <botlish_fn_4+0xbc>
     544:	mov    rsi,r12
     547:	mov    rdi,r14
     54a:	call   54f <botlish_fn_4+0xa7>
			54b: R_X86_64_PLT32	rt_int_cmp-0x4
     54f:	mov    ecx,0x2
     554:	test   rax,rax
     557:	cmove  rcx,QWORD PTR [rip+0x1d9]        # 738 <botlish_fn_4+0x290>
     55f:	jmp    574 <botlish_fn_4+0xcc>
     564:	mov    ecx,0x2
     569:	cmp    r12,rdx
     56c:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 738 <botlish_fn_4+0x290>
     574:	cmp    rcx,0x6
     578:	je     61e <botlish_fn_4+0x176>
     57e:	mov    rcx,QWORD PTR [rsp+0x28]
     583:	mov    rdx,r12
     586:	mov    rsi,QWORD PTR [rsp+0x20]
     58b:	mov    rdi,r14
     58e:	call   593 <botlish_fn_4+0xeb>
			58f: R_X86_64_PLT32	rt_mutarray_set-0x4
     593:	test   rax,rax
     596:	jne    5a4 <botlish_fn_4+0xfc>
     59c:	mov    rdi,r14
     59f:	jmp    6a4 <botlish_fn_4+0x1fc>
     5a4:	mov    QWORD PTR [rsp+0x18],0x3
     5ad:	test   r12,0x1
     5b4:	je     5d4 <botlish_fn_4+0x12c>
     5ba:	mov    rax,r12
     5bd:	add    rax,0x2
     5c1:	seto   cl
     5c4:	test   cl,cl
     5c6:	jne    5d4 <botlish_fn_4+0x12c>
     5cc:	mov    rdi,r14
     5cf:	jmp    5e7 <botlish_fn_4+0x13f>
     5d4:	mov    edx,0x3
     5d9:	mov    rsi,r12
     5dc:	mov    rdi,r14
     5df:	call   5e4 <botlish_fn_4+0x13c>
			5e0: R_X86_64_PLT32	rt_int_add-0x4
     5e4:	mov    rdi,r14
     5e7:	mov    rdi,r14
     5ea:	mov    QWORD PTR [rdi],r13
     5ed:	mov    rdx,QWORD PTR [rsp+0x20]
     5f2:	mov    QWORD PTR [rbx],rdx
     5f5:	mov    QWORD PTR [rbx+0x8],rax
     5f9:	mov    rax,r15
     5fc:	mov    rbx,QWORD PTR [rsp+0x30]
     601:	mov    r12,QWORD PTR [rsp+0x38]
     606:	mov    r13,QWORD PTR [rsp+0x40]
     60b:	mov    r14,QWORD PTR [rsp+0x48]
     610:	mov    r15,QWORD PTR [rsp+0x50]
     615:	add    rsp,0x60
     619:	mov    rsp,rbp
     61c:	pop    rbp
     61d:	ret
     61e:	mov    rdx,QWORD PTR [rsp+0x20]
     623:	mov    rsi,r15
     626:	mov    rdi,r14
     629:	call   62e <botlish_fn_4+0x186>
			62a: R_X86_64_PLT32	rt_list_append-0x4
     62e:	test   rax,rax
     631:	jne    63f <botlish_fn_4+0x197>
     637:	mov    rdi,r14
     63a:	jmp    6a4 <botlish_fn_4+0x1fc>
     63f:	mov    QWORD PTR [rsp],rax
     643:	mov    r12,rax
     646:	mov    rdi,r14
     649:	call   64e <botlish_fn_4+0x1a6>
			64a: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     64e:	test   rax,rax
     651:	jne    65f <botlish_fn_4+0x1b7>
     657:	mov    rdi,r14
     65a:	jmp    6a4 <botlish_fn_4+0x1fc>
     65f:	mov    QWORD PTR [rsp+0x8],rax
     664:	mov    rsi,rax
     667:	mov    rdi,r14
     66a:	call   66f <botlish_fn_4+0x1c7>
			66b: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     66f:	test   rax,rax
     672:	mov    r15,rax
     675:	jne    683 <botlish_fn_4+0x1db>
     67b:	mov    rdi,r14
     67e:	jmp    6a4 <botlish_fn_4+0x1fc>
     683:	mov    edx,0x1
     688:	mov    rcx,QWORD PTR [rsp+0x28]
     68d:	mov    rsi,r15
     690:	mov    rdi,r14
     693:	call   698 <botlish_fn_4+0x1f0>
			694: R_X86_64_PLT32	rt_mutarray_set-0x4
     698:	test   rax,rax
     69b:	jne    6cf <botlish_fn_4+0x227>
     6a1:	mov    rdi,r14
     6a4:	mov    rdi,r14
     6a7:	mov    QWORD PTR [rdi],r13
     6aa:	xor    rax,rax
     6ad:	mov    rbx,QWORD PTR [rsp+0x30]
     6b2:	mov    r12,QWORD PTR [rsp+0x38]
     6b7:	mov    r13,QWORD PTR [rsp+0x40]
     6bc:	mov    r14,QWORD PTR [rsp+0x48]
     6c1:	mov    r15,QWORD PTR [rsp+0x50]
     6c6:	add    rsp,0x60
     6ca:	mov    rsp,rbp
     6cd:	pop    rbp
     6ce:	ret
     6cf:	mov    rdi,r14
     6d2:	mov    QWORD PTR [rdi],r13
     6d5:	mov    rax,r15
     6d8:	mov    QWORD PTR [rbx],rax
     6db:	mov    QWORD PTR [rbx+0x8],0x3
     6e3:	mov    rax,r12
     6e6:	mov    rbx,QWORD PTR [rsp+0x30]
     6eb:	mov    r12,QWORD PTR [rsp+0x38]
     6f0:	mov    r13,QWORD PTR [rsp+0x40]
     6f5:	mov    r14,QWORD PTR [rsp+0x48]
     6fa:	mov    r15,QWORD PTR [rsp+0x50]
     6ff:	add    rsp,0x60
     703:	mov    rsp,rbp
     706:	pop    rbp
     707:	ret
     708:	mov    r14,rdi
     70b:	call   710 <botlish_fn_4+0x268>
			70c: R_X86_64_PLT32	rt_stack_overflow-0x4
     710:	xor    rax,rax
     713:	mov    rbx,QWORD PTR [rsp+0x30]
     718:	mov    r12,QWORD PTR [rsp+0x38]
     71d:	mov    r13,QWORD PTR [rsp+0x40]
     722:	mov    r14,QWORD PTR [rsp+0x48]
     727:	mov    r15,QWORD PTR [rsp+0x50]
     72c:	add    rsp,0x60
     730:	mov    rsp,rbp
     733:	pop    rbp
     734:	ret
     735:	add    BYTE PTR [rax],al
     737:	add    BYTE PTR [rsi],al
     739:	add    BYTE PTR [rax],al
     73b:	add    BYTE PTR [rax],al
     73d:	add    BYTE PTR [rax],al
	...

0000000000000740 <botlish_entry_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     740:	push   rbp
     741:	mov    rbp,rsp
     744:	ud2
	...

0000000000000748 <botlish_fn_5: chunked_append<list[list<never>, mutarray, int], list>>:
     748:	push   rbp
     749:	mov    rbp,rsp
     74c:	sub    rsp,0x60
     750:	mov    QWORD PTR [rsp+0x30],rbx
     755:	mov    QWORD PTR [rsp+0x38],r12
     75a:	mov    QWORD PTR [rsp+0x40],r13
     75f:	mov    QWORD PTR [rsp+0x48],r14
     764:	mov    QWORD PTR [rsp+0x50],r15
     769:	mov    rbx,r9
     76c:	mov    r13,QWORD PTR [rdi]
     76f:	mov    rax,QWORD PTR [rdi+0x8]
     773:	lea    r9,[r13+0x8]
     777:	cmp    r9,rax
     77a:	ja     9a8 <botlish_fn_5+0x260>
     780:	lea    rax,[r13+0x8]
     784:	mov    QWORD PTR [rdi],rax
     787:	mov    r14,rdi
     78a:	mov    QWORD PTR [r13+0x0],0x0
     792:	mov    QWORD PTR [rsp],rsi
     796:	mov    r15,rsi
     799:	mov    QWORD PTR [rsp+0x8],rdx
     79e:	mov    QWORD PTR [rsp+0x20],rdx
     7a3:	mov    QWORD PTR [rsp+0x10],rcx
     7a8:	mov    r12,rcx
     7ab:	mov    QWORD PTR [rsp+0x18],r8
     7b0:	mov    QWORD PTR [rsp+0x28],r8
     7b5:	mov    rdi,r14
     7b8:	call   7bd <botlish_fn_5+0x75>
			7b9: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     7bd:	test   rax,rax
     7c0:	jne    7ce <botlish_fn_5+0x86>
     7c6:	mov    rdi,r14
     7c9:	jmp    944 <botlish_fn_5+0x1fc>
     7ce:	mov    rcx,r12
     7d1:	and    rcx,rax
     7d4:	mov    rdx,rax
     7d7:	test   rcx,0x1
     7de:	jne    804 <botlish_fn_5+0xbc>
     7e4:	mov    rsi,r12
     7e7:	mov    rdi,r14
     7ea:	call   7ef <botlish_fn_5+0xa7>
			7eb: R_X86_64_PLT32	rt_int_cmp-0x4
     7ef:	mov    ecx,0x2
     7f4:	test   rax,rax
     7f7:	cmove  rcx,QWORD PTR [rip+0x1d9]        # 9d8 <botlish_fn_5+0x290>
     7ff:	jmp    814 <botlish_fn_5+0xcc>
     804:	mov    ecx,0x2
     809:	cmp    r12,rdx
     80c:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 9d8 <botlish_fn_5+0x290>
     814:	cmp    rcx,0x6
     818:	je     8be <botlish_fn_5+0x176>
     81e:	mov    rcx,QWORD PTR [rsp+0x28]
     823:	mov    rdx,r12
     826:	mov    rsi,QWORD PTR [rsp+0x20]
     82b:	mov    rdi,r14
     82e:	call   833 <botlish_fn_5+0xeb>
			82f: R_X86_64_PLT32	rt_mutarray_set-0x4
     833:	test   rax,rax
     836:	jne    844 <botlish_fn_5+0xfc>
     83c:	mov    rdi,r14
     83f:	jmp    944 <botlish_fn_5+0x1fc>
     844:	mov    QWORD PTR [rsp+0x18],0x3
     84d:	test   r12,0x1
     854:	je     874 <botlish_fn_5+0x12c>
     85a:	mov    rax,r12
     85d:	add    rax,0x2
     861:	seto   cl
     864:	test   cl,cl
     866:	jne    874 <botlish_fn_5+0x12c>
     86c:	mov    rdi,r14
     86f:	jmp    887 <botlish_fn_5+0x13f>
     874:	mov    edx,0x3
     879:	mov    rsi,r12
     87c:	mov    rdi,r14
     87f:	call   884 <botlish_fn_5+0x13c>
			880: R_X86_64_PLT32	rt_int_add-0x4
     884:	mov    rdi,r14
     887:	mov    rdi,r14
     88a:	mov    QWORD PTR [rdi],r13
     88d:	mov    rdx,QWORD PTR [rsp+0x20]
     892:	mov    QWORD PTR [rbx],rdx
     895:	mov    QWORD PTR [rbx+0x8],rax
     899:	mov    rax,r15
     89c:	mov    rbx,QWORD PTR [rsp+0x30]
     8a1:	mov    r12,QWORD PTR [rsp+0x38]
     8a6:	mov    r13,QWORD PTR [rsp+0x40]
     8ab:	mov    r14,QWORD PTR [rsp+0x48]
     8b0:	mov    r15,QWORD PTR [rsp+0x50]
     8b5:	add    rsp,0x60
     8b9:	mov    rsp,rbp
     8bc:	pop    rbp
     8bd:	ret
     8be:	mov    rdx,QWORD PTR [rsp+0x20]
     8c3:	mov    rsi,r15
     8c6:	mov    rdi,r14
     8c9:	call   8ce <botlish_fn_5+0x186>
			8ca: R_X86_64_PLT32	rt_list_append-0x4
     8ce:	test   rax,rax
     8d1:	jne    8df <botlish_fn_5+0x197>
     8d7:	mov    rdi,r14
     8da:	jmp    944 <botlish_fn_5+0x1fc>
     8df:	mov    QWORD PTR [rsp],rax
     8e3:	mov    r12,rax
     8e6:	mov    rdi,r14
     8e9:	call   8ee <botlish_fn_5+0x1a6>
			8ea: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     8ee:	test   rax,rax
     8f1:	jne    8ff <botlish_fn_5+0x1b7>
     8f7:	mov    rdi,r14
     8fa:	jmp    944 <botlish_fn_5+0x1fc>
     8ff:	mov    QWORD PTR [rsp+0x8],rax
     904:	mov    rsi,rax
     907:	mov    rdi,r14
     90a:	call   90f <botlish_fn_5+0x1c7>
			90b: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     90f:	test   rax,rax
     912:	mov    r15,rax
     915:	jne    923 <botlish_fn_5+0x1db>
     91b:	mov    rdi,r14
     91e:	jmp    944 <botlish_fn_5+0x1fc>
     923:	mov    edx,0x1
     928:	mov    rcx,QWORD PTR [rsp+0x28]
     92d:	mov    rsi,r15
     930:	mov    rdi,r14
     933:	call   938 <botlish_fn_5+0x1f0>
			934: R_X86_64_PLT32	rt_mutarray_set-0x4
     938:	test   rax,rax
     93b:	jne    96f <botlish_fn_5+0x227>
     941:	mov    rdi,r14
     944:	mov    rdi,r14
     947:	mov    QWORD PTR [rdi],r13
     94a:	xor    rax,rax
     94d:	mov    rbx,QWORD PTR [rsp+0x30]
     952:	mov    r12,QWORD PTR [rsp+0x38]
     957:	mov    r13,QWORD PTR [rsp+0x40]
     95c:	mov    r14,QWORD PTR [rsp+0x48]
     961:	mov    r15,QWORD PTR [rsp+0x50]
     966:	add    rsp,0x60
     96a:	mov    rsp,rbp
     96d:	pop    rbp
     96e:	ret
     96f:	mov    rdi,r14
     972:	mov    QWORD PTR [rdi],r13
     975:	mov    rax,r15
     978:	mov    QWORD PTR [rbx],rax
     97b:	mov    QWORD PTR [rbx+0x8],0x3
     983:	mov    rax,r12
     986:	mov    rbx,QWORD PTR [rsp+0x30]
     98b:	mov    r12,QWORD PTR [rsp+0x38]
     990:	mov    r13,QWORD PTR [rsp+0x40]
     995:	mov    r14,QWORD PTR [rsp+0x48]
     99a:	mov    r15,QWORD PTR [rsp+0x50]
     99f:	add    rsp,0x60
     9a3:	mov    rsp,rbp
     9a6:	pop    rbp
     9a7:	ret
     9a8:	mov    r14,rdi
     9ab:	call   9b0 <botlish_fn_5+0x268>
			9ac: R_X86_64_PLT32	rt_stack_overflow-0x4
     9b0:	xor    rax,rax
     9b3:	mov    rbx,QWORD PTR [rsp+0x30]
     9b8:	mov    r12,QWORD PTR [rsp+0x38]
     9bd:	mov    r13,QWORD PTR [rsp+0x40]
     9c2:	mov    r14,QWORD PTR [rsp+0x48]
     9c7:	mov    r15,QWORD PTR [rsp+0x50]
     9cc:	add    rsp,0x60
     9d0:	mov    rsp,rbp
     9d3:	pop    rbp
     9d4:	ret
     9d5:	add    BYTE PTR [rax],al
     9d7:	add    BYTE PTR [rsi],al
     9d9:	add    BYTE PTR [rax],al
     9db:	add    BYTE PTR [rax],al
     9dd:	add    BYTE PTR [rax],al
	...

00000000000009e0 <botlish_entry_5: chunked_append<list[list<never>, mutarray, int], list>>:
     9e0:	push   rbp
     9e1:	mov    rbp,rsp
     9e4:	ud2
	...

00000000000009e8 <botlish_fn_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     9e8:	push   rbp
     9e9:	mov    rbp,rsp
     9ec:	sub    rsp,0x60
     9f0:	mov    QWORD PTR [rsp+0x30],rbx
     9f5:	mov    QWORD PTR [rsp+0x38],r12
     9fa:	mov    QWORD PTR [rsp+0x40],r13
     9ff:	mov    QWORD PTR [rsp+0x48],r14
     a04:	mov    QWORD PTR [rsp+0x50],r15
     a09:	mov    rbx,r9
     a0c:	mov    r13,QWORD PTR [rdi]
     a0f:	mov    rax,QWORD PTR [rdi+0x8]
     a13:	lea    r9,[r13+0x8]
     a17:	cmp    r9,rax
     a1a:	ja     c48 <botlish_fn_6+0x260>
     a20:	lea    rax,[r13+0x8]
     a24:	mov    QWORD PTR [rdi],rax
     a27:	mov    r14,rdi
     a2a:	mov    QWORD PTR [r13+0x0],0x0
     a32:	mov    QWORD PTR [rsp],rsi
     a36:	mov    r15,rsi
     a39:	mov    QWORD PTR [rsp+0x8],rdx
     a3e:	mov    QWORD PTR [rsp+0x20],rdx
     a43:	mov    QWORD PTR [rsp+0x10],rcx
     a48:	mov    r12,rcx
     a4b:	mov    QWORD PTR [rsp+0x18],r8
     a50:	mov    QWORD PTR [rsp+0x28],r8
     a55:	mov    rdi,r14
     a58:	call   a5d <botlish_fn_6+0x75>
			a59: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     a5d:	test   rax,rax
     a60:	jne    a6e <botlish_fn_6+0x86>
     a66:	mov    rdi,r14
     a69:	jmp    be4 <botlish_fn_6+0x1fc>
     a6e:	mov    rcx,r12
     a71:	and    rcx,rax
     a74:	mov    rdx,rax
     a77:	test   rcx,0x1
     a7e:	jne    aa4 <botlish_fn_6+0xbc>
     a84:	mov    rsi,r12
     a87:	mov    rdi,r14
     a8a:	call   a8f <botlish_fn_6+0xa7>
			a8b: R_X86_64_PLT32	rt_int_cmp-0x4
     a8f:	mov    ecx,0x2
     a94:	test   rax,rax
     a97:	cmove  rcx,QWORD PTR [rip+0x1d9]        # c78 <botlish_fn_6+0x290>
     a9f:	jmp    ab4 <botlish_fn_6+0xcc>
     aa4:	mov    ecx,0x2
     aa9:	cmp    r12,rdx
     aac:	cmove  rcx,QWORD PTR [rip+0x1c4]        # c78 <botlish_fn_6+0x290>
     ab4:	cmp    rcx,0x6
     ab8:	je     b5e <botlish_fn_6+0x176>
     abe:	mov    rcx,QWORD PTR [rsp+0x28]
     ac3:	mov    rdx,r12
     ac6:	mov    rsi,QWORD PTR [rsp+0x20]
     acb:	mov    rdi,r14
     ace:	call   ad3 <botlish_fn_6+0xeb>
			acf: R_X86_64_PLT32	rt_mutarray_set-0x4
     ad3:	test   rax,rax
     ad6:	jne    ae4 <botlish_fn_6+0xfc>
     adc:	mov    rdi,r14
     adf:	jmp    be4 <botlish_fn_6+0x1fc>
     ae4:	mov    QWORD PTR [rsp+0x18],0x3
     aed:	test   r12,0x1
     af4:	je     b14 <botlish_fn_6+0x12c>
     afa:	mov    rax,r12
     afd:	add    rax,0x2
     b01:	seto   cl
     b04:	test   cl,cl
     b06:	jne    b14 <botlish_fn_6+0x12c>
     b0c:	mov    rdi,r14
     b0f:	jmp    b27 <botlish_fn_6+0x13f>
     b14:	mov    edx,0x3
     b19:	mov    rsi,r12
     b1c:	mov    rdi,r14
     b1f:	call   b24 <botlish_fn_6+0x13c>
			b20: R_X86_64_PLT32	rt_int_add-0x4
     b24:	mov    rdi,r14
     b27:	mov    rdi,r14
     b2a:	mov    QWORD PTR [rdi],r13
     b2d:	mov    rdx,QWORD PTR [rsp+0x20]
     b32:	mov    QWORD PTR [rbx],rdx
     b35:	mov    QWORD PTR [rbx+0x8],rax
     b39:	mov    rax,r15
     b3c:	mov    rbx,QWORD PTR [rsp+0x30]
     b41:	mov    r12,QWORD PTR [rsp+0x38]
     b46:	mov    r13,QWORD PTR [rsp+0x40]
     b4b:	mov    r14,QWORD PTR [rsp+0x48]
     b50:	mov    r15,QWORD PTR [rsp+0x50]
     b55:	add    rsp,0x60
     b59:	mov    rsp,rbp
     b5c:	pop    rbp
     b5d:	ret
     b5e:	mov    rdx,QWORD PTR [rsp+0x20]
     b63:	mov    rsi,r15
     b66:	mov    rdi,r14
     b69:	call   b6e <botlish_fn_6+0x186>
			b6a: R_X86_64_PLT32	rt_list_append-0x4
     b6e:	test   rax,rax
     b71:	jne    b7f <botlish_fn_6+0x197>
     b77:	mov    rdi,r14
     b7a:	jmp    be4 <botlish_fn_6+0x1fc>
     b7f:	mov    QWORD PTR [rsp],rax
     b83:	mov    r12,rax
     b86:	mov    rdi,r14
     b89:	call   b8e <botlish_fn_6+0x1a6>
			b8a: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     b8e:	test   rax,rax
     b91:	jne    b9f <botlish_fn_6+0x1b7>
     b97:	mov    rdi,r14
     b9a:	jmp    be4 <botlish_fn_6+0x1fc>
     b9f:	mov    QWORD PTR [rsp+0x8],rax
     ba4:	mov    rsi,rax
     ba7:	mov    rdi,r14
     baa:	call   baf <botlish_fn_6+0x1c7>
			bab: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     baf:	test   rax,rax
     bb2:	mov    r15,rax
     bb5:	jne    bc3 <botlish_fn_6+0x1db>
     bbb:	mov    rdi,r14
     bbe:	jmp    be4 <botlish_fn_6+0x1fc>
     bc3:	mov    edx,0x1
     bc8:	mov    rcx,QWORD PTR [rsp+0x28]
     bcd:	mov    rsi,r15
     bd0:	mov    rdi,r14
     bd3:	call   bd8 <botlish_fn_6+0x1f0>
			bd4: R_X86_64_PLT32	rt_mutarray_set-0x4
     bd8:	test   rax,rax
     bdb:	jne    c0f <botlish_fn_6+0x227>
     be1:	mov    rdi,r14
     be4:	mov    rdi,r14
     be7:	mov    QWORD PTR [rdi],r13
     bea:	xor    rax,rax
     bed:	mov    rbx,QWORD PTR [rsp+0x30]
     bf2:	mov    r12,QWORD PTR [rsp+0x38]
     bf7:	mov    r13,QWORD PTR [rsp+0x40]
     bfc:	mov    r14,QWORD PTR [rsp+0x48]
     c01:	mov    r15,QWORD PTR [rsp+0x50]
     c06:	add    rsp,0x60
     c0a:	mov    rsp,rbp
     c0d:	pop    rbp
     c0e:	ret
     c0f:	mov    rdi,r14
     c12:	mov    QWORD PTR [rdi],r13
     c15:	mov    rax,r15
     c18:	mov    QWORD PTR [rbx],rax
     c1b:	mov    QWORD PTR [rbx+0x8],0x3
     c23:	mov    rax,r12
     c26:	mov    rbx,QWORD PTR [rsp+0x30]
     c2b:	mov    r12,QWORD PTR [rsp+0x38]
     c30:	mov    r13,QWORD PTR [rsp+0x40]
     c35:	mov    r14,QWORD PTR [rsp+0x48]
     c3a:	mov    r15,QWORD PTR [rsp+0x50]
     c3f:	add    rsp,0x60
     c43:	mov    rsp,rbp
     c46:	pop    rbp
     c47:	ret
     c48:	mov    r14,rdi
     c4b:	call   c50 <botlish_fn_6+0x268>
			c4c: R_X86_64_PLT32	rt_stack_overflow-0x4
     c50:	xor    rax,rax
     c53:	mov    rbx,QWORD PTR [rsp+0x30]
     c58:	mov    r12,QWORD PTR [rsp+0x38]
     c5d:	mov    r13,QWORD PTR [rsp+0x40]
     c62:	mov    r14,QWORD PTR [rsp+0x48]
     c67:	mov    r15,QWORD PTR [rsp+0x50]
     c6c:	add    rsp,0x60
     c70:	mov    rsp,rbp
     c73:	pop    rbp
     c74:	ret
     c75:	add    BYTE PTR [rax],al
     c77:	add    BYTE PTR [rsi],al
     c79:	add    BYTE PTR [rax],al
     c7b:	add    BYTE PTR [rax],al
     c7d:	add    BYTE PTR [rax],al
	...

0000000000000c80 <botlish_entry_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     c80:	push   rbp
     c81:	mov    rbp,rsp
     c84:	ud2
	...

0000000000000c88 <botlish_fn_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
     c88:	push   rbp
     c89:	mov    rbp,rsp
     c8c:	sub    rsp,0x70
     c90:	mov    QWORD PTR [rsp+0x40],rbx
     c95:	mov    QWORD PTR [rsp+0x48],r12
     c9a:	mov    QWORD PTR [rsp+0x50],r13
     c9f:	mov    QWORD PTR [rsp+0x58],r14
     ca4:	mov    QWORD PTR [rsp+0x60],r15
     ca9:	mov    r14,QWORD PTR [rdi]
     cac:	mov    rax,QWORD PTR [rdi+0x8]
     cb0:	lea    r9,[r14+0x8]
     cb4:	cmp    r9,rax
     cb7:	ja     f3d <botlish_fn_7+0x2b5>
     cbd:	lea    rax,[r14+0x8]
     cc1:	mov    QWORD PTR [rdi],rax
     cc4:	mov    r15,rdi
     cc7:	mov    QWORD PTR [r14],0x0
     cce:	mov    QWORD PTR [rsp],rsi
     cd2:	mov    QWORD PTR [rsp+0x8],rdx
     cd7:	mov    rbx,rdx
     cda:	mov    QWORD PTR [rsp+0x10],rcx
     cdf:	mov    QWORD PTR [rsp+0x30],rcx
     ce4:	mov    QWORD PTR [rsp+0x18],r8
     ce9:	mov    r12,rsi
     cec:	mov    QWORD PTR [rsp+0x38],r8
     cf1:	mov    rsi,r12
     cf4:	mov    rdi,r15
     cf7:	call   cfc <botlish_fn_7+0x74>
			cf8: R_X86_64_PLT32	rt_list_len-0x4
     cfc:	mov    r13,rbx
     cff:	mov    rcx,r13
     d02:	and    rcx,rax
     d05:	mov    rdx,rax
     d08:	test   rcx,0x1
     d0f:	jne    d35 <botlish_fn_7+0xad>
     d15:	mov    rsi,r13
     d18:	mov    rdi,r15
     d1b:	call   d20 <botlish_fn_7+0x98>
			d1c: R_X86_64_PLT32	rt_int_cmp-0x4
     d20:	mov    ecx,0x2
     d25:	test   rax,rax
     d28:	cmovge rcx,QWORD PTR [rip+0x240]        # f70 <botlish_fn_7+0x2e8>
     d30:	jmp    d45 <botlish_fn_7+0xbd>
     d35:	mov    ecx,0x2
     d3a:	cmp    r13,rdx
     d3d:	cmovge rcx,QWORD PTR [rip+0x22b]        # f70 <botlish_fn_7+0x2e8>
     d45:	cmp    rcx,0x6
     d49:	je     f10 <botlish_fn_7+0x288>
     d4f:	test   r13,0x1
     d56:	je     d70 <botlish_fn_7+0xe8>
     d5c:	mov    rax,QWORD PTR [r12+0x8]
     d61:	mov    r11,r13
     d64:	sar    r11,1
     d67:	cmp    r11,rax
     d6a:	jb     d97 <botlish_fn_7+0x10f>
     d70:	mov    rdx,r13
     d73:	mov    rsi,r12
     d76:	mov    rdi,r15
     d79:	call   d7e <botlish_fn_7+0xf6>
			d7a: R_X86_64_PLT32	rt_list_get-0x4
     d7e:	test   rax,rax
     d81:	jne    d8f <botlish_fn_7+0x107>
     d87:	mov    rdi,r15
     d8a:	jmp    e6c <botlish_fn_7+0x1e4>
     d8f:	mov    rsi,rax
     d92:	jmp    da3 <botlish_fn_7+0x11b>
     d97:	mov    rax,QWORD PTR [r12+0x10]
     d9c:	mov    rax,QWORD PTR [rax+r11*8]
     da0:	mov    rsi,rax
     da3:	mov    QWORD PTR [rsp+0x20],rsi
     da8:	mov    rbx,rsi
     dab:	mov    QWORD PTR [rsp+0x28],0x1
     db4:	mov    rdi,r15
     db7:	call   dbc <botlish_fn_7+0x134>
			db8: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     dbc:	test   rax,rax
     dbf:	mov    r9,rax
     dc2:	jne    dd0 <botlish_fn_7+0x148>
     dc8:	mov    rdi,r15
     dcb:	jmp    e6c <botlish_fn_7+0x1e4>
     dd0:	xor    eax,eax
     dd2:	mov    rsi,rbx
     dd5:	test   rsi,0x7
     ddc:	jne    deb <botlish_fn_7+0x163>
     de2:	movzx  rax,BYTE PTR [rsi]
     de6:	cmp    al,0x8
     de8:	sete   al
     deb:	test   al,al
     ded:	jne    e10 <botlish_fn_7+0x188>
     df3:	mov    rdi,r15
     df6:	mov    rax,QWORD PTR [rdi+0x10]
     dfa:	mov    rcx,QWORD PTR [rax+0x8]
     dfe:	mov    edx,0x8
     e03:	call   e08 <botlish_fn_7+0x180>
			e04: R_X86_64_PLT32	rt_type_error-0x4
     e08:	mov    rdi,r15
     e0b:	jmp    e6c <botlish_fn_7+0x1e4>
     e10:	mov    rbx,rsi
     e13:	mov    r8d,0x1
     e19:	mov    rcx,rbx
     e1c:	mov    rbx,QWORD PTR [rsp+0x30]
     e21:	mov    rdx,QWORD PTR [rsp+0x38]
     e26:	mov    rsi,rbx
     e29:	mov    rdi,r15
     e2c:	call   e31 <botlish_fn_7+0x1a9>
			e2d: R_X86_64_PLT32	rt_mutarray_copy-0x4
     e31:	test   rax,rax
     e34:	jne    e42 <botlish_fn_7+0x1ba>
     e3a:	mov    rdi,r15
     e3d:	jmp    e6c <botlish_fn_7+0x1e4>
     e42:	sar    r13,1
     e45:	add    r13,0x1
     e4c:	shl    r13,1
     e4f:	or     r13,0x1
     e53:	mov    QWORD PTR [rsp+0x8],r13
     e58:	mov    rdi,r15
     e5b:	call   e60 <botlish_fn_7+0x1d8>
			e5c: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     e60:	test   rax,rax
     e63:	jne    e97 <botlish_fn_7+0x20f>
     e69:	mov    rdi,r15
     e6c:	mov    rdi,r15
     e6f:	mov    QWORD PTR [rdi],r14
     e72:	xor    rax,rax
     e75:	mov    rbx,QWORD PTR [rsp+0x40]
     e7a:	mov    r12,QWORD PTR [rsp+0x48]
     e7f:	mov    r13,QWORD PTR [rsp+0x50]
     e84:	mov    r14,QWORD PTR [rsp+0x58]
     e89:	mov    r15,QWORD PTR [rsp+0x60]
     e8e:	add    rsp,0x70
     e92:	mov    rsp,rbp
     e95:	pop    rbp
     e96:	ret
     e97:	mov    QWORD PTR [rsp+0x20],rax
     e9c:	mov    rsi,QWORD PTR [rsp+0x38]
     ea1:	mov    rcx,rsi
     ea4:	and    rcx,rax
     ea7:	test   rcx,0x1
     eae:	jne    ec1 <botlish_fn_7+0x239>
     eb4:	mov    rdx,rax
     eb7:	mov    rsi,QWORD PTR [rsp+0x38]
     ebc:	jmp    ee3 <botlish_fn_7+0x25b>
     ec1:	lea    rcx,[rax-0x1]
     ec5:	mov    rdx,rax
     ec8:	mov    rsi,QWORD PTR [rsp+0x38]
     ecd:	mov    rax,rsi
     ed0:	add    rax,rcx
     ed3:	seto   cl
     ed6:	test   cl,cl
     ed8:	je     eeb <botlish_fn_7+0x263>
     ede:	mov    rsi,QWORD PTR [rsp+0x38]
     ee3:	mov    rdi,r15
     ee6:	call   eeb <botlish_fn_7+0x263>
			ee7: R_X86_64_PLT32	rt_int_add-0x4
     eeb:	mov    QWORD PTR [rsp],r12
     eef:	mov    QWORD PTR [rsp+0x8],r13
     ef4:	mov    QWORD PTR [rsp+0x10],rbx
     ef9:	mov    QWORD PTR [rsp+0x18],rax
     efe:	mov    QWORD PTR [rsp+0x38],rax
     f03:	mov    QWORD PTR [rsp+0x30],rbx
     f08:	mov    rbx,r13
     f0b:	jmp    cf1 <botlish_fn_7+0x69>
     f10:	mov    rdi,r15
     f13:	mov    QWORD PTR [rdi],r14
     f16:	mov    rax,QWORD PTR [rsp+0x38]
     f1b:	mov    rbx,QWORD PTR [rsp+0x40]
     f20:	mov    r12,QWORD PTR [rsp+0x48]
     f25:	mov    r13,QWORD PTR [rsp+0x50]
     f2a:	mov    r14,QWORD PTR [rsp+0x58]
     f2f:	mov    r15,QWORD PTR [rsp+0x60]
     f34:	add    rsp,0x70
     f38:	mov    rsp,rbp
     f3b:	pop    rbp
     f3c:	ret
     f3d:	mov    r15,rdi
     f40:	call   f45 <botlish_fn_7+0x2bd>
			f41: R_X86_64_PLT32	rt_stack_overflow-0x4
     f45:	xor    rax,rax
     f48:	mov    rbx,QWORD PTR [rsp+0x40]
     f4d:	mov    r12,QWORD PTR [rsp+0x48]
     f52:	mov    r13,QWORD PTR [rsp+0x50]
     f57:	mov    r14,QWORD PTR [rsp+0x58]
     f5c:	mov    r15,QWORD PTR [rsp+0x60]
     f61:	add    rsp,0x70
     f65:	mov    rsp,rbp
     f68:	pop    rbp
     f69:	ret
     f6a:	add    BYTE PTR [rax],al
     f6c:	add    BYTE PTR [rax],al
     f6e:	add    BYTE PTR [rax],al
     f70:	(bad)
     f71:	add    BYTE PTR [rax],al
     f73:	add    BYTE PTR [rax],al
     f75:	add    BYTE PTR [rax],al
	...

0000000000000f78 <botlish_entry_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
     f78:	push   rbp
     f79:	mov    rbp,rsp
     f7c:	mov    rsi,QWORD PTR [rdx]
     f7f:	mov    r9,QWORD PTR [rdx+0x8]
     f83:	mov    rcx,QWORD PTR [rdx+0x10]
     f87:	mov    r8,QWORD PTR [rdx+0x18]
     f8b:	mov    rdx,r9
     f8e:	call   f93 <botlish_entry_7+0x1b>
			f8f: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
     f93:	mov    rsp,rbp
     f96:	pop    rbp
     f97:	ret

0000000000000f98 <botlish_fn_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
     f98:	push   rbp
     f99:	mov    rbp,rsp
     f9c:	sub    rsp,0x70
     fa0:	mov    QWORD PTR [rsp+0x40],rbx
     fa5:	mov    QWORD PTR [rsp+0x48],r12
     faa:	mov    QWORD PTR [rsp+0x50],r13
     faf:	mov    QWORD PTR [rsp+0x58],r14
     fb4:	mov    QWORD PTR [rsp+0x60],r15
     fb9:	mov    r14,QWORD PTR [rdi]
     fbc:	mov    rax,QWORD PTR [rdi+0x8]
     fc0:	lea    r9,[r14+0x8]
     fc4:	cmp    r9,rax
     fc7:	ja     11f7 <botlish_fn_8+0x25f>
     fcd:	lea    rax,[r14+0x8]
     fd1:	mov    QWORD PTR [rdi],rax
     fd4:	mov    r15,rdi
     fd7:	mov    QWORD PTR [r14],0x0
     fde:	mov    QWORD PTR [rsp],rsi
     fe2:	mov    QWORD PTR [rsp+0x8],rdx
     fe7:	mov    r12,rdx
     fea:	mov    QWORD PTR [rsp+0x10],rcx
     fef:	mov    r13,rcx
     ff2:	mov    QWORD PTR [rsp+0x18],r8
     ff7:	mov    rbx,rsi
     ffa:	mov    QWORD PTR [rsp+0x30],r8
     fff:	mov    rsi,rbx
    1002:	mov    rdi,r15
    1005:	call   100a <botlish_fn_8+0x72>
			1006: R_X86_64_PLT32	rt_list_len-0x4
    100a:	mov    rcx,r12
    100d:	and    rcx,rax
    1010:	mov    rdx,rax
    1013:	test   rcx,0x1
    101a:	jne    1040 <botlish_fn_8+0xa8>
    1020:	mov    rsi,r12
    1023:	mov    rdi,r15
    1026:	call   102b <botlish_fn_8+0x93>
			1027: R_X86_64_PLT32	rt_int_cmp-0x4
    102b:	mov    ecx,0x2
    1030:	test   rax,rax
    1033:	cmovge rcx,QWORD PTR [rip+0x1ed]        # 1228 <botlish_fn_8+0x290>
    103b:	jmp    1050 <botlish_fn_8+0xb8>
    1040:	mov    ecx,0x2
    1045:	cmp    r12,rdx
    1048:	cmovge rcx,QWORD PTR [rip+0x1d8]        # 1228 <botlish_fn_8+0x290>
    1050:	cmp    rcx,0x6
    1054:	je     11ca <botlish_fn_8+0x232>
    105a:	test   r12,0x1
    1061:	je     107a <botlish_fn_8+0xe2>
    1067:	mov    rsi,QWORD PTR [rbx+0x8]
    106b:	mov    rdx,r12
    106e:	sar    rdx,1
    1071:	cmp    rdx,rsi
    1074:	jb     10a1 <botlish_fn_8+0x109>
    107a:	mov    rdx,r12
    107d:	mov    rsi,rbx
    1080:	mov    rdi,r15
    1083:	call   1088 <botlish_fn_8+0xf0>
			1084: R_X86_64_PLT32	rt_list_get-0x4
    1088:	test   rax,rax
    108b:	jne    1099 <botlish_fn_8+0x101>
    1091:	mov    rdi,r15
    1094:	jmp    112e <botlish_fn_8+0x196>
    1099:	mov    rcx,rax
    109c:	jmp    10a9 <botlish_fn_8+0x111>
    10a1:	mov    r9,QWORD PTR [rbx+0x10]
    10a5:	mov    rcx,QWORD PTR [r9+rdx*8]
    10a9:	mov    QWORD PTR [rsp+0x20],rcx
    10ae:	mov    QWORD PTR [rsp+0x38],rcx
    10b3:	mov    QWORD PTR [rsp+0x28],0x1
    10bc:	mov    rdi,r15
    10bf:	call   10c4 <botlish_fn_8+0x12c>
			10c0: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    10c4:	test   rax,rax
    10c7:	mov    r9,rax
    10ca:	jne    10d8 <botlish_fn_8+0x140>
    10d0:	mov    rdi,r15
    10d3:	jmp    112e <botlish_fn_8+0x196>
    10d8:	mov    r8d,0x1
    10de:	mov    rcx,QWORD PTR [rsp+0x38]
    10e3:	mov    rdx,QWORD PTR [rsp+0x30]
    10e8:	mov    rsi,r13
    10eb:	mov    rdi,r15
    10ee:	call   10f3 <botlish_fn_8+0x15b>
			10ef: R_X86_64_PLT32	rt_mutarray_copy-0x4
    10f3:	test   rax,rax
    10f6:	jne    1104 <botlish_fn_8+0x16c>
    10fc:	mov    rdi,r15
    10ff:	jmp    112e <botlish_fn_8+0x196>
    1104:	sar    r12,1
    1107:	add    r12,0x1
    110e:	shl    r12,1
    1111:	or     r12,0x1
    1115:	mov    QWORD PTR [rsp+0x8],r12
    111a:	mov    rdi,r15
    111d:	call   1122 <botlish_fn_8+0x18a>
			111e: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    1122:	test   rax,rax
    1125:	jne    1159 <botlish_fn_8+0x1c1>
    112b:	mov    rdi,r15
    112e:	mov    rdi,r15
    1131:	mov    QWORD PTR [rdi],r14
    1134:	xor    rax,rax
    1137:	mov    rbx,QWORD PTR [rsp+0x40]
    113c:	mov    r12,QWORD PTR [rsp+0x48]
    1141:	mov    r13,QWORD PTR [rsp+0x50]
    1146:	mov    r14,QWORD PTR [rsp+0x58]
    114b:	mov    r15,QWORD PTR [rsp+0x60]
    1150:	add    rsp,0x70
    1154:	mov    rsp,rbp
    1157:	pop    rbp
    1158:	ret
    1159:	mov    QWORD PTR [rsp+0x20],rax
    115e:	mov    rsi,QWORD PTR [rsp+0x30]
    1163:	mov    rcx,rsi
    1166:	and    rcx,rax
    1169:	test   rcx,0x1
    1170:	jne    1183 <botlish_fn_8+0x1eb>
    1176:	mov    rdx,rax
    1179:	mov    rsi,QWORD PTR [rsp+0x30]
    117e:	jmp    11a5 <botlish_fn_8+0x20d>
    1183:	lea    rcx,[rax-0x1]
    1187:	mov    rdx,rax
    118a:	mov    rsi,QWORD PTR [rsp+0x30]
    118f:	mov    rax,rsi
    1192:	add    rax,rcx
    1195:	seto   cl
    1198:	test   cl,cl
    119a:	je     11ad <botlish_fn_8+0x215>
    11a0:	mov    rsi,QWORD PTR [rsp+0x30]
    11a5:	mov    rdi,r15
    11a8:	call   11ad <botlish_fn_8+0x215>
			11a9: R_X86_64_PLT32	rt_int_add-0x4
    11ad:	mov    QWORD PTR [rsp],rbx
    11b1:	mov    QWORD PTR [rsp+0x8],r12
    11b6:	mov    QWORD PTR [rsp+0x10],r13
    11bb:	mov    QWORD PTR [rsp+0x18],rax
    11c0:	mov    QWORD PTR [rsp+0x30],rax
    11c5:	jmp    fff <botlish_fn_8+0x67>
    11ca:	mov    rdi,r15
    11cd:	mov    QWORD PTR [rdi],r14
    11d0:	mov    rax,QWORD PTR [rsp+0x30]
    11d5:	mov    rbx,QWORD PTR [rsp+0x40]
    11da:	mov    r12,QWORD PTR [rsp+0x48]
    11df:	mov    r13,QWORD PTR [rsp+0x50]
    11e4:	mov    r14,QWORD PTR [rsp+0x58]
    11e9:	mov    r15,QWORD PTR [rsp+0x60]
    11ee:	add    rsp,0x70
    11f2:	mov    rsp,rbp
    11f5:	pop    rbp
    11f6:	ret
    11f7:	mov    r15,rdi
    11fa:	call   11ff <botlish_fn_8+0x267>
			11fb: R_X86_64_PLT32	rt_stack_overflow-0x4
    11ff:	xor    rax,rax
    1202:	mov    rbx,QWORD PTR [rsp+0x40]
    1207:	mov    r12,QWORD PTR [rsp+0x48]
    120c:	mov    r13,QWORD PTR [rsp+0x50]
    1211:	mov    r14,QWORD PTR [rsp+0x58]
    1216:	mov    r15,QWORD PTR [rsp+0x60]
    121b:	add    rsp,0x70
    121f:	mov    rsp,rbp
    1222:	pop    rbp
    1223:	ret
    1224:	add    BYTE PTR [rax],al
    1226:	add    BYTE PTR [rax],al
    1228:	(bad)
    1229:	add    BYTE PTR [rax],al
    122b:	add    BYTE PTR [rax],al
    122d:	add    BYTE PTR [rax],al
	...

0000000000001230 <botlish_entry_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
    1230:	push   rbp
    1231:	mov    rbp,rsp
    1234:	mov    rsi,QWORD PTR [rdx]
    1237:	mov    r9,QWORD PTR [rdx+0x8]
    123b:	mov    rcx,QWORD PTR [rdx+0x10]
    123f:	mov    r8,QWORD PTR [rdx+0x18]
    1243:	mov    rdx,r9
    1246:	call   124b <botlish_entry_8+0x1b>
			1247: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    124b:	mov    rsp,rbp
    124e:	pop    rbp
    124f:	ret

0000000000001250 <botlish_fn_9: chunked_finish<list[list<never>, mutarray, int]>>:
    1250:	push   rbp
    1251:	mov    rbp,rsp
    1254:	sub    rsp,0x80
    125b:	mov    QWORD PTR [rsp+0x50],rbx
    1260:	mov    QWORD PTR [rsp+0x58],r12
    1265:	mov    QWORD PTR [rsp+0x60],r13
    126a:	mov    QWORD PTR [rsp+0x68],r14
    126f:	mov    QWORD PTR [rsp+0x70],r15
    1274:	mov    r12,QWORD PTR [rdi]
    1277:	mov    rax,QWORD PTR [rdi+0x8]
    127b:	lea    r8,[r12+0x8]
    1280:	cmp    r8,rax
    1283:	ja     14b4 <botlish_fn_9+0x264>
    1289:	lea    rax,[r12+0x8]
    128e:	mov    QWORD PTR [rdi],rax
    1291:	mov    r14,rdi
    1294:	mov    QWORD PTR [r12],0x0
    129c:	mov    QWORD PTR [rsp+0x20],0x0
    12a5:	mov    QWORD PTR [rsp+0x28],0x0
    12ae:	mov    QWORD PTR [rsp+0x30],0x0
    12b7:	mov    QWORD PTR [rsp],rsi
    12bb:	mov    QWORD PTR [rsp+0x38],rsi
    12c0:	mov    QWORD PTR [rsp+0x8],rdx
    12c5:	mov    r15,rdx
    12c8:	mov    QWORD PTR [rsp+0x10],rcx
    12cd:	mov    rbx,rcx
    12d0:	mov    rsi,QWORD PTR [rsp+0x38]
    12d5:	mov    rdi,r14
    12d8:	call   12dd <botlish_fn_9+0x8d>
			12d9: R_X86_64_PLT32	rt_list_len-0x4
    12dd:	mov    QWORD PTR [rsp+0x18],rax
    12e2:	mov    r13,rax
    12e5:	mov    rdi,r14
    12e8:	call   12ed <botlish_fn_9+0x9d>
			12e9: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    12ed:	test   rax,rax
    12f0:	jne    12fe <botlish_fn_9+0xae>
    12f6:	mov    rdi,r14
    12f9:	jmp    145b <botlish_fn_9+0x20b>
    12fe:	mov    QWORD PTR [rsp+0x20],rax
    1303:	mov    rcx,r13
    1306:	mov    rdx,rcx
    1309:	and    rdx,rax
    130c:	mov    rsi,rax
    130f:	test   rdx,0x1
    1316:	jne    1327 <botlish_fn_9+0xd7>
    131c:	mov    rdx,rsi
    131f:	mov    rsi,rcx
    1322:	jmp    135c <botlish_fn_9+0x10c>
    1327:	mov    rax,rcx
    132a:	sar    rax,1
    132d:	mov    r13,rcx
    1330:	mov    rcx,rsi
    1333:	lea    rdx,[rcx-0x1]
    1337:	imul   rdx
    133a:	seto   cl
    133d:	or     rax,0x1
    1341:	test   cl,cl
    1343:	je     1354 <botlish_fn_9+0x104>
    1349:	mov    rdx,rsi
    134c:	mov    rsi,r13
    134f:	jmp    135c <botlish_fn_9+0x10c>
    1354:	mov    rsi,rax
    1357:	jmp    1367 <botlish_fn_9+0x117>
    135c:	mov    rdi,r14
    135f:	call   1364 <botlish_fn_9+0x114>
			1360: R_X86_64_PLT32	rt_int_mul-0x4
    1364:	mov    rsi,rax
    1367:	mov    QWORD PTR [rsp+0x18],rsi
    136c:	mov    rax,rsi
    136f:	and    rax,rbx
    1372:	test   rax,0x1
    1378:	je     1393 <botlish_fn_9+0x143>
    137e:	lea    rax,[rbx-0x1]
    1382:	mov    r13,rsi
    1385:	add    r13,rax
    1388:	seto   cl
    138b:	test   cl,cl
    138d:	je     13a1 <botlish_fn_9+0x151>
    1393:	mov    rdx,rbx
    1396:	mov    rdi,r14
    1399:	call   139e <botlish_fn_9+0x14e>
			139a: R_X86_64_PLT32	rt_int_add-0x4
    139e:	mov    r13,rax
    13a1:	mov    QWORD PTR [rsp+0x18],r13
    13a6:	mov    rsi,r13
    13a9:	mov    rdi,r14
    13ac:	call   13b1 <botlish_fn_9+0x161>
			13ad: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    13b1:	mov    rcx,rax
    13b4:	mov    QWORD PTR [rsp+0x40],rax
    13b9:	test   rax,rcx
    13bc:	jne    13ca <botlish_fn_9+0x17a>
    13c2:	mov    rdi,r14
    13c5:	jmp    145b <botlish_fn_9+0x20b>
    13ca:	mov    rax,QWORD PTR [rsp+0x40]
    13cf:	mov    QWORD PTR [rsp+0x20],rax
    13d4:	mov    r8d,0x1
    13da:	mov    QWORD PTR [rsp+0x28],0x1
    13e3:	mov    QWORD PTR [rsp+0x30],0x1
    13ec:	mov    rsi,QWORD PTR [rsp+0x38]
    13f1:	mov    rcx,QWORD PTR [rsp+0x40]
    13f6:	mov    rdi,r14
    13f9:	mov    rdx,r8
    13fc:	call   1401 <botlish_fn_9+0x1b1>
			13fd: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
    1401:	test   rax,rax
    1404:	mov    rdx,rax
    1407:	jne    1415 <botlish_fn_9+0x1c5>
    140d:	mov    rdi,r14
    1410:	jmp    145b <botlish_fn_9+0x20b>
    1415:	mov    r8d,0x1
    141b:	mov    rcx,r15
    141e:	mov    r9,rbx
    1421:	mov    rsi,QWORD PTR [rsp+0x40]
    1426:	mov    rdi,r14
    1429:	call   142e <botlish_fn_9+0x1de>
			142a: R_X86_64_PLT32	rt_mutarray_copy-0x4
    142e:	test   rax,rax
    1431:	jne    143f <botlish_fn_9+0x1ef>
    1437:	mov    rdi,r14
    143a:	jmp    145b <botlish_fn_9+0x20b>
    143f:	mov    rdx,r13
    1442:	mov    rsi,QWORD PTR [rsp+0x40]
    1447:	mov    rdi,r14
    144a:	call   144f <botlish_fn_9+0x1ff>
			144b: R_X86_64_PLT32	rt_mutarray_freeze-0x4
    144f:	test   rax,rax
    1452:	jne    1489 <botlish_fn_9+0x239>
    1458:	mov    rdi,r14
    145b:	mov    rdi,r14
    145e:	mov    QWORD PTR [rdi],r12
    1461:	xor    rax,rax
    1464:	mov    rbx,QWORD PTR [rsp+0x50]
    1469:	mov    r12,QWORD PTR [rsp+0x58]
    146e:	mov    r13,QWORD PTR [rsp+0x60]
    1473:	mov    r14,QWORD PTR [rsp+0x68]
    1478:	mov    r15,QWORD PTR [rsp+0x70]
    147d:	add    rsp,0x80
    1484:	mov    rsp,rbp
    1487:	pop    rbp
    1488:	ret
    1489:	mov    rdi,r14
    148c:	mov    QWORD PTR [rdi],r12
    148f:	mov    rbx,QWORD PTR [rsp+0x50]
    1494:	mov    r12,QWORD PTR [rsp+0x58]
    1499:	mov    r13,QWORD PTR [rsp+0x60]
    149e:	mov    r14,QWORD PTR [rsp+0x68]
    14a3:	mov    r15,QWORD PTR [rsp+0x70]
    14a8:	add    rsp,0x80
    14af:	mov    rsp,rbp
    14b2:	pop    rbp
    14b3:	ret
    14b4:	mov    r14,rdi
    14b7:	call   14bc <botlish_fn_9+0x26c>
			14b8: R_X86_64_PLT32	rt_stack_overflow-0x4
    14bc:	xor    rax,rax
    14bf:	mov    rbx,QWORD PTR [rsp+0x50]
    14c4:	mov    r12,QWORD PTR [rsp+0x58]
    14c9:	mov    r13,QWORD PTR [rsp+0x60]
    14ce:	mov    r14,QWORD PTR [rsp+0x68]
    14d3:	mov    r15,QWORD PTR [rsp+0x70]
    14d8:	add    rsp,0x80
    14df:	mov    rsp,rbp
    14e2:	pop    rbp
    14e3:	ret

00000000000014e4 <botlish_entry_9: chunked_finish<list[list<never>, mutarray, int]>>:
    14e4:	push   rbp
    14e5:	mov    rbp,rsp
    14e8:	mov    rsi,QWORD PTR [rdx]
    14eb:	mov    r8,QWORD PTR [rdx+0x8]
    14ef:	mov    rcx,QWORD PTR [rdx+0x10]
    14f3:	mov    rdx,r8
    14f6:	call   14fb <botlish_entry_9+0x17>
			14f7: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    14fb:	mov    rsp,rbp
    14fe:	pop    rbp
    14ff:	ret

0000000000001500 <botlish_fn_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    1500:	push   rbp
    1501:	mov    rbp,rsp
    1504:	sub    rsp,0x80
    150b:	mov    QWORD PTR [rsp+0x50],rbx
    1510:	mov    QWORD PTR [rsp+0x58],r12
    1515:	mov    QWORD PTR [rsp+0x60],r13
    151a:	mov    QWORD PTR [rsp+0x68],r14
    151f:	mov    QWORD PTR [rsp+0x70],r15
    1524:	mov    r12,QWORD PTR [rdi]
    1527:	mov    rax,QWORD PTR [rdi+0x8]
    152b:	lea    r8,[r12+0x8]
    1530:	cmp    r8,rax
    1533:	ja     1764 <botlish_fn_10+0x264>
    1539:	lea    rax,[r12+0x8]
    153e:	mov    QWORD PTR [rdi],rax
    1541:	mov    r14,rdi
    1544:	mov    QWORD PTR [r12],0x0
    154c:	mov    QWORD PTR [rsp+0x20],0x0
    1555:	mov    QWORD PTR [rsp+0x28],0x0
    155e:	mov    QWORD PTR [rsp+0x30],0x0
    1567:	mov    QWORD PTR [rsp],rsi
    156b:	mov    QWORD PTR [rsp+0x38],rsi
    1570:	mov    QWORD PTR [rsp+0x8],rdx
    1575:	mov    r15,rdx
    1578:	mov    QWORD PTR [rsp+0x10],rcx
    157d:	mov    rbx,rcx
    1580:	mov    rsi,QWORD PTR [rsp+0x38]
    1585:	mov    rdi,r14
    1588:	call   158d <botlish_fn_10+0x8d>
			1589: R_X86_64_PLT32	rt_list_len-0x4
    158d:	mov    QWORD PTR [rsp+0x18],rax
    1592:	mov    r13,rax
    1595:	mov    rdi,r14
    1598:	call   159d <botlish_fn_10+0x9d>
			1599: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    159d:	test   rax,rax
    15a0:	jne    15ae <botlish_fn_10+0xae>
    15a6:	mov    rdi,r14
    15a9:	jmp    170b <botlish_fn_10+0x20b>
    15ae:	mov    QWORD PTR [rsp+0x20],rax
    15b3:	mov    rcx,r13
    15b6:	mov    rdx,rcx
    15b9:	and    rdx,rax
    15bc:	mov    rsi,rax
    15bf:	test   rdx,0x1
    15c6:	jne    15d7 <botlish_fn_10+0xd7>
    15cc:	mov    rdx,rsi
    15cf:	mov    rsi,rcx
    15d2:	jmp    160c <botlish_fn_10+0x10c>
    15d7:	mov    rax,rcx
    15da:	sar    rax,1
    15dd:	mov    r13,rcx
    15e0:	mov    rcx,rsi
    15e3:	lea    rdx,[rcx-0x1]
    15e7:	imul   rdx
    15ea:	seto   cl
    15ed:	or     rax,0x1
    15f1:	test   cl,cl
    15f3:	je     1604 <botlish_fn_10+0x104>
    15f9:	mov    rdx,rsi
    15fc:	mov    rsi,r13
    15ff:	jmp    160c <botlish_fn_10+0x10c>
    1604:	mov    rsi,rax
    1607:	jmp    1617 <botlish_fn_10+0x117>
    160c:	mov    rdi,r14
    160f:	call   1614 <botlish_fn_10+0x114>
			1610: R_X86_64_PLT32	rt_int_mul-0x4
    1614:	mov    rsi,rax
    1617:	mov    QWORD PTR [rsp+0x18],rsi
    161c:	mov    rax,rsi
    161f:	and    rax,rbx
    1622:	test   rax,0x1
    1628:	je     1643 <botlish_fn_10+0x143>
    162e:	lea    rax,[rbx-0x1]
    1632:	mov    r13,rsi
    1635:	add    r13,rax
    1638:	seto   cl
    163b:	test   cl,cl
    163d:	je     1651 <botlish_fn_10+0x151>
    1643:	mov    rdx,rbx
    1646:	mov    rdi,r14
    1649:	call   164e <botlish_fn_10+0x14e>
			164a: R_X86_64_PLT32	rt_int_add-0x4
    164e:	mov    r13,rax
    1651:	mov    QWORD PTR [rsp+0x18],r13
    1656:	mov    rsi,r13
    1659:	mov    rdi,r14
    165c:	call   1661 <botlish_fn_10+0x161>
			165d: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1661:	mov    rcx,rax
    1664:	mov    QWORD PTR [rsp+0x40],rax
    1669:	test   rax,rcx
    166c:	jne    167a <botlish_fn_10+0x17a>
    1672:	mov    rdi,r14
    1675:	jmp    170b <botlish_fn_10+0x20b>
    167a:	mov    rax,QWORD PTR [rsp+0x40]
    167f:	mov    QWORD PTR [rsp+0x20],rax
    1684:	mov    r8d,0x1
    168a:	mov    QWORD PTR [rsp+0x28],0x1
    1693:	mov    QWORD PTR [rsp+0x30],0x1
    169c:	mov    rsi,QWORD PTR [rsp+0x38]
    16a1:	mov    rcx,QWORD PTR [rsp+0x40]
    16a6:	mov    rdi,r14
    16a9:	mov    rdx,r8
    16ac:	call   16b1 <botlish_fn_10+0x1b1>
			16ad: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    16b1:	test   rax,rax
    16b4:	mov    rdx,rax
    16b7:	jne    16c5 <botlish_fn_10+0x1c5>
    16bd:	mov    rdi,r14
    16c0:	jmp    170b <botlish_fn_10+0x20b>
    16c5:	mov    r8d,0x1
    16cb:	mov    rcx,r15
    16ce:	mov    r9,rbx
    16d1:	mov    rsi,QWORD PTR [rsp+0x40]
    16d6:	mov    rdi,r14
    16d9:	call   16de <botlish_fn_10+0x1de>
			16da: R_X86_64_PLT32	rt_mutarray_copy-0x4
    16de:	test   rax,rax
    16e1:	jne    16ef <botlish_fn_10+0x1ef>
    16e7:	mov    rdi,r14
    16ea:	jmp    170b <botlish_fn_10+0x20b>
    16ef:	mov    rdx,r13
    16f2:	mov    rsi,QWORD PTR [rsp+0x40]
    16f7:	mov    rdi,r14
    16fa:	call   16ff <botlish_fn_10+0x1ff>
			16fb: R_X86_64_PLT32	rt_mutarray_freeze-0x4
    16ff:	test   rax,rax
    1702:	jne    1739 <botlish_fn_10+0x239>
    1708:	mov    rdi,r14
    170b:	mov    rdi,r14
    170e:	mov    QWORD PTR [rdi],r12
    1711:	xor    rax,rax
    1714:	mov    rbx,QWORD PTR [rsp+0x50]
    1719:	mov    r12,QWORD PTR [rsp+0x58]
    171e:	mov    r13,QWORD PTR [rsp+0x60]
    1723:	mov    r14,QWORD PTR [rsp+0x68]
    1728:	mov    r15,QWORD PTR [rsp+0x70]
    172d:	add    rsp,0x80
    1734:	mov    rsp,rbp
    1737:	pop    rbp
    1738:	ret
    1739:	mov    rdi,r14
    173c:	mov    QWORD PTR [rdi],r12
    173f:	mov    rbx,QWORD PTR [rsp+0x50]
    1744:	mov    r12,QWORD PTR [rsp+0x58]
    1749:	mov    r13,QWORD PTR [rsp+0x60]
    174e:	mov    r14,QWORD PTR [rsp+0x68]
    1753:	mov    r15,QWORD PTR [rsp+0x70]
    1758:	add    rsp,0x80
    175f:	mov    rsp,rbp
    1762:	pop    rbp
    1763:	ret
    1764:	mov    r14,rdi
    1767:	call   176c <botlish_fn_10+0x26c>
			1768: R_X86_64_PLT32	rt_stack_overflow-0x4
    176c:	xor    rax,rax
    176f:	mov    rbx,QWORD PTR [rsp+0x50]
    1774:	mov    r12,QWORD PTR [rsp+0x58]
    1779:	mov    r13,QWORD PTR [rsp+0x60]
    177e:	mov    r14,QWORD PTR [rsp+0x68]
    1783:	mov    r15,QWORD PTR [rsp+0x70]
    1788:	add    rsp,0x80
    178f:	mov    rsp,rbp
    1792:	pop    rbp
    1793:	ret

0000000000001794 <botlish_entry_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    1794:	push   rbp
    1795:	mov    rbp,rsp
    1798:	mov    rsi,QWORD PTR [rdx]
    179b:	mov    r8,QWORD PTR [rdx+0x8]
    179f:	mov    rcx,QWORD PTR [rdx+0x10]
    17a3:	mov    rdx,r8
    17a6:	call   17ab <botlish_entry_10+0x17>
			17a7: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    17ab:	mov    rsp,rbp
    17ae:	pop    rbp
    17af:	ret

00000000000017b0 <botlish_fn_11: peek<str, int>>:
    17b0:	push   rbp
    17b1:	mov    rbp,rsp
    17b4:	sub    rsp,0x40
    17b8:	mov    QWORD PTR [rsp+0x20],rbx
    17bd:	mov    QWORD PTR [rsp+0x28],r12
    17c2:	mov    QWORD PTR [rsp+0x30],r13
    17c7:	mov    r13,rdi
    17ca:	mov    QWORD PTR [rsp],rsi
    17ce:	mov    r12,rsi
    17d1:	mov    QWORD PTR [rsp+0x8],rdx
    17d6:	mov    rbx,rdx
    17d9:	mov    rsi,r12
    17dc:	mov    rdi,r13
    17df:	call   17e4 <botlish_fn_11+0x34>
			17e0: R_X86_64_PLT32	rt_str_len-0x4
    17e4:	mov    rcx,rbx
    17e7:	and    rcx,rax
    17ea:	mov    rdx,rax
    17ed:	test   rcx,0x1
    17f4:	jne    181a <botlish_fn_11+0x6a>
    17fa:	mov    rsi,rbx
    17fd:	mov    rdi,r13
    1800:	call   1805 <botlish_fn_11+0x55>
			1801: R_X86_64_PLT32	rt_int_cmp-0x4
    1805:	mov    ecx,0x2
    180a:	test   rax,rax
    180d:	cmovge rcx,QWORD PTR [rip+0xd3]        # 18e8 <botlish_fn_11+0x138>
    1815:	jmp    182a <botlish_fn_11+0x7a>
    181a:	mov    ecx,0x2
    181f:	cmp    rbx,rdx
    1822:	cmovge rcx,QWORD PTR [rip+0xbe]        # 18e8 <botlish_fn_11+0x138>
    182a:	cmp    rcx,0x6
    182e:	je     18be <botlish_fn_11+0x10e>
    1834:	mov    QWORD PTR [rsp+0x10],0x3
    183d:	test   rbx,0x1
    1844:	je     185c <botlish_fn_11+0xac>
    184a:	mov    rcx,rbx
    184d:	add    rcx,0x2
    1851:	seto   al
    1854:	test   al,al
    1856:	je     186f <botlish_fn_11+0xbf>
    185c:	mov    edx,0x3
    1861:	mov    rsi,rbx
    1864:	mov    rdi,r13
    1867:	call   186c <botlish_fn_11+0xbc>
			1868: R_X86_64_PLT32	rt_int_add-0x4
    186c:	mov    rcx,rax
    186f:	mov    QWORD PTR [rsp+0x10],rcx
    1874:	mov    rdx,rbx
    1877:	mov    rsi,r12
    187a:	mov    rdi,r13
    187d:	call   1882 <botlish_fn_11+0xd2>
			187e: R_X86_64_PLT32	rt_substr-0x4
    1882:	test   rax,rax
    1885:	jne    18a6 <botlish_fn_11+0xf6>
    188b:	xor    rax,rax
    188e:	mov    rbx,QWORD PTR [rsp+0x20]
    1893:	mov    r12,QWORD PTR [rsp+0x28]
    1898:	mov    r13,QWORD PTR [rsp+0x30]
    189d:	add    rsp,0x40
    18a1:	mov    rsp,rbp
    18a4:	pop    rbp
    18a5:	ret
    18a6:	mov    rbx,QWORD PTR [rsp+0x20]
    18ab:	mov    r12,QWORD PTR [rsp+0x28]
    18b0:	mov    r13,QWORD PTR [rsp+0x30]
    18b5:	add    rsp,0x40
    18b9:	mov    rsp,rbp
    18bc:	pop    rbp
    18bd:	ret
    18be:	mov    rdi,r13
    18c1:	mov    rax,QWORD PTR [rdi+0x10]
    18c5:	mov    rax,QWORD PTR [rax+0x10]
    18c9:	mov    rbx,QWORD PTR [rsp+0x20]
    18ce:	mov    r12,QWORD PTR [rsp+0x28]
    18d3:	mov    r13,QWORD PTR [rsp+0x30]
    18d8:	add    rsp,0x40
    18dc:	mov    rsp,rbp
    18df:	pop    rbp
    18e0:	ret
    18e1:	add    BYTE PTR [rax],al
    18e3:	add    BYTE PTR [rax],al
    18e5:	add    BYTE PTR [rax],al
    18e7:	add    BYTE PTR [rsi],al
    18e9:	add    BYTE PTR [rax],al
    18eb:	add    BYTE PTR [rax],al
    18ed:	add    BYTE PTR [rax],al
	...

00000000000018f0 <botlish_entry_11: peek<str, int>>:
    18f0:	push   rbp
    18f1:	mov    rbp,rsp
    18f4:	mov    rsi,QWORD PTR [rdx]
    18f7:	mov    rdx,QWORD PTR [rdx+0x8]
    18fb:	call   1900 <botlish_entry_11+0x10>
			18fc: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1900:	mov    rsp,rbp
    1903:	pop    rbp
    1904:	ret
    1905:	add    BYTE PTR [rax],al
	...

0000000000001908 <botlish_fn_12: peek<str, int>>:
    1908:	push   rbp
    1909:	mov    rbp,rsp
    190c:	sub    rsp,0x50
    1910:	mov    QWORD PTR [rsp+0x20],rbx
    1915:	mov    QWORD PTR [rsp+0x28],r12
    191a:	mov    QWORD PTR [rsp+0x30],r13
    191f:	mov    QWORD PTR [rsp+0x38],r14
    1924:	mov    QWORD PTR [rsp+0x40],r15
    1929:	mov    r12,rcx
    192c:	mov    r14,rdi
    192f:	mov    QWORD PTR [rsp],rsi
    1933:	mov    r13,rsi
    1936:	mov    QWORD PTR [rsp+0x8],rdx
    193b:	mov    rbx,rdx
    193e:	mov    rsi,r13
    1941:	mov    rdi,r14
    1944:	call   1949 <botlish_fn_12+0x41>
			1945: R_X86_64_PLT32	rt_str_len-0x4
    1949:	mov    rcx,rbx
    194c:	and    rcx,rax
    194f:	mov    rdx,rax
    1952:	test   rcx,0x1
    1959:	jne    197f <botlish_fn_12+0x77>
    195f:	mov    rsi,rbx
    1962:	mov    rdi,r14
    1965:	call   196a <botlish_fn_12+0x62>
			1966: R_X86_64_PLT32	rt_int_cmp-0x4
    196a:	mov    ecx,0x2
    196f:	test   rax,rax
    1972:	cmovge rcx,QWORD PTR [rip+0x11e]        # 1a98 <botlish_fn_12+0x190>
    197a:	jmp    198f <botlish_fn_12+0x87>
    197f:	mov    ecx,0x2
    1984:	cmp    rbx,rdx
    1987:	cmovge rcx,QWORD PTR [rip+0x109]        # 1a98 <botlish_fn_12+0x190>
    198f:	cmp    rcx,0x6
    1993:	je     1a53 <botlish_fn_12+0x14b>
    1999:	mov    QWORD PTR [rsp+0x10],0x3
    19a2:	test   rbx,0x1
    19a9:	je     19cc <botlish_fn_12+0xc4>
    19af:	mov    rax,rbx
    19b2:	add    rax,0x2
    19b6:	seto   cl
    19b9:	test   cl,cl
    19bb:	jne    19cc <botlish_fn_12+0xc4>
    19c1:	mov    rdi,r14
    19c4:	mov    r15,rax
    19c7:	jmp    19e2 <botlish_fn_12+0xda>
    19cc:	mov    edx,0x3
    19d1:	mov    rsi,rbx
    19d4:	mov    rdi,r14
    19d7:	call   19dc <botlish_fn_12+0xd4>
			19d8: R_X86_64_PLT32	rt_int_add-0x4
    19dc:	mov    r15,rax
    19df:	mov    rdi,r14
    19e2:	mov    rdi,r14
    19e5:	mov    rcx,r15
    19e8:	mov    rdx,rbx
    19eb:	mov    rsi,r13
    19ee:	call   19f3 <botlish_fn_12+0xeb>
			19ef: R_X86_64_PLT32	rt_str_region_check-0x4
    19f3:	test   rax,rax
    19f6:	jne    1a21 <botlish_fn_12+0x119>
    19fc:	xor    rax,rax
    19ff:	mov    rbx,QWORD PTR [rsp+0x20]
    1a04:	mov    r12,QWORD PTR [rsp+0x28]
    1a09:	mov    r13,QWORD PTR [rsp+0x30]
    1a0e:	mov    r14,QWORD PTR [rsp+0x38]
    1a13:	mov    r15,QWORD PTR [rsp+0x40]
    1a18:	add    rsp,0x50
    1a1c:	mov    rsp,rbp
    1a1f:	pop    rbp
    1a20:	ret
    1a21:	mov    rcx,r12
    1a24:	mov    QWORD PTR [rcx],rbx
    1a27:	mov    rax,r15
    1a2a:	mov    QWORD PTR [rcx+0x8],rax
    1a2e:	mov    rax,r13
    1a31:	mov    rbx,QWORD PTR [rsp+0x20]
    1a36:	mov    r12,QWORD PTR [rsp+0x28]
    1a3b:	mov    r13,QWORD PTR [rsp+0x30]
    1a40:	mov    r14,QWORD PTR [rsp+0x38]
    1a45:	mov    r15,QWORD PTR [rsp+0x40]
    1a4a:	add    rsp,0x50
    1a4e:	mov    rsp,rbp
    1a51:	pop    rbp
    1a52:	ret
    1a53:	mov    rcx,r12
    1a56:	mov    rdi,r14
    1a59:	mov    rax,QWORD PTR [rdi+0x10]
    1a5d:	mov    rax,QWORD PTR [rax+0x10]
    1a61:	mov    QWORD PTR [rcx],0x1
    1a68:	mov    QWORD PTR [rcx+0x8],0x1
    1a70:	mov    rbx,QWORD PTR [rsp+0x20]
    1a75:	mov    r12,QWORD PTR [rsp+0x28]
    1a7a:	mov    r13,QWORD PTR [rsp+0x30]
    1a7f:	mov    r14,QWORD PTR [rsp+0x38]
    1a84:	mov    r15,QWORD PTR [rsp+0x40]
    1a89:	add    rsp,0x50
    1a8d:	mov    rsp,rbp
    1a90:	pop    rbp
    1a91:	ret
    1a92:	add    BYTE PTR [rax],al
    1a94:	add    BYTE PTR [rax],al
    1a96:	add    BYTE PTR [rax],al
    1a98:	(bad)
    1a99:	add    BYTE PTR [rax],al
    1a9b:	add    BYTE PTR [rax],al
    1a9d:	add    BYTE PTR [rax],al
	...

0000000000001aa0 <botlish_entry_12: peek<str, int>>:
    1aa0:	push   rbp
    1aa1:	mov    rbp,rsp
    1aa4:	ud2

0000000000001aa6 <botlish_fn_13: scan_unquoted<str, int, int>>:
    1aa6:	push   rbp
    1aa7:	mov    rbp,rsp
    1aaa:	sub    rsp,0x80
    1ab1:	mov    QWORD PTR [rsp+0x50],rbx
    1ab6:	mov    QWORD PTR [rsp+0x58],r12
    1abb:	mov    QWORD PTR [rsp+0x60],r13
    1ac0:	mov    QWORD PTR [rsp+0x68],r14
    1ac5:	mov    QWORD PTR [rsp+0x70],r15
    1aca:	mov    r14,QWORD PTR [rdi]
    1acd:	mov    rax,QWORD PTR [rdi+0x8]
    1ad1:	lea    r8,[r14+0x8]
    1ad5:	cmp    r8,rax
    1ad8:	ja     1d00 <botlish_fn_13+0x25a>
    1ade:	lea    rax,[r14+0x8]
    1ae2:	mov    QWORD PTR [rdi],rax
    1ae5:	mov    r15,rdi
    1ae8:	mov    QWORD PTR [r14],0x0
    1aef:	mov    QWORD PTR [rsp+0x18],0x0
    1af8:	mov    QWORD PTR [rsp],rsi
    1afc:	mov    QWORD PTR [rsp+0x30],rsi
    1b01:	mov    QWORD PTR [rsp+0x8],rdx
    1b06:	mov    QWORD PTR [rsp+0x38],rdx
    1b0b:	mov    QWORD PTR [rsp+0x10],rcx
    1b10:	lea    rbx,[rsp+0x20]
    1b15:	mov    QWORD PTR [rsp+0x40],rcx
    1b1a:	mov    rcx,rbx
    1b1d:	mov    rdx,QWORD PTR [rsp+0x40]
    1b22:	mov    rsi,QWORD PTR [rsp+0x30]
    1b27:	mov    rdi,r15
    1b2a:	call   1b2f <botlish_fn_13+0x89>
			1b2b: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1b2f:	mov    rcx,rax
    1b32:	mov    QWORD PTR [rsp+0x48],rax
    1b37:	test   rax,rcx
    1b3a:	jne    1b48 <botlish_fn_13+0xa2>
    1b40:	mov    rdi,r15
    1b43:	jmp    1c9f <botlish_fn_13+0x1f9>
    1b48:	mov    r12,QWORD PTR [rsp+0x20]
    1b4d:	mov    r13,QWORD PTR [rsp+0x28]
    1b52:	mov    rdi,r15
    1b55:	mov    rcx,QWORD PTR [rdi+0x10]
    1b59:	mov    r8,QWORD PTR [rcx+0x10]
    1b5d:	mov    rcx,r13
    1b60:	mov    rdx,r12
    1b63:	mov    rsi,QWORD PTR [rsp+0x48]
    1b68:	call   1b6d <botlish_fn_13+0xc7>
			1b69: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b6d:	cmp    rax,0x6
    1b71:	je     1bb0 <botlish_fn_13+0x10a>
    1b77:	mov    rdi,r15
    1b7a:	mov    rax,QWORD PTR [rdi+0x10]
    1b7e:	mov    r8,QWORD PTR [rax+0x18]
    1b82:	mov    rcx,r13
    1b85:	mov    rdx,r12
    1b88:	mov    rsi,QWORD PTR [rsp+0x48]
    1b8d:	call   1b92 <botlish_fn_13+0xec>
			1b8e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b92:	cmp    rax,0x6
    1b96:	je     1ba6 <botlish_fn_13+0x100>
    1b9c:	mov    eax,0x2
    1ba1:	jmp    1bb5 <botlish_fn_13+0x10f>
    1ba6:	mov    eax,0x6
    1bab:	jmp    1bb5 <botlish_fn_13+0x10f>
    1bb0:	mov    eax,0x6
    1bb5:	cmp    rax,0x6
    1bb9:	je     1bf8 <botlish_fn_13+0x152>
    1bbf:	mov    rdi,r15
    1bc2:	mov    rdx,QWORD PTR [rdi+0x10]
    1bc6:	mov    r8,QWORD PTR [rdx+0x20]
    1bca:	mov    rcx,r13
    1bcd:	mov    rdx,r12
    1bd0:	mov    rsi,QWORD PTR [rsp+0x48]
    1bd5:	call   1bda <botlish_fn_13+0x134>
			1bd6: R_X86_64_PLT32	rt_str_region_eq-0x4
    1bda:	cmp    rax,0x6
    1bde:	je     1bee <botlish_fn_13+0x148>
    1be4:	mov    eax,0x2
    1be9:	jmp    1bfd <botlish_fn_13+0x157>
    1bee:	mov    eax,0x6
    1bf3:	jmp    1bfd <botlish_fn_13+0x157>
    1bf8:	mov    eax,0x6
    1bfd:	cmp    rax,0x6
    1c01:	je     1c7c <botlish_fn_13+0x1d6>
    1c07:	mov    QWORD PTR [rsp+0x18],0x3
    1c10:	mov    rsi,QWORD PTR [rsp+0x40]
    1c15:	test   rsi,0x1
    1c1c:	je     1c43 <botlish_fn_13+0x19d>
    1c22:	mov    rsi,QWORD PTR [rsp+0x40]
    1c27:	mov    rax,rsi
    1c2a:	add    rax,0x2
    1c2e:	seto   cl
    1c31:	test   cl,cl
    1c33:	jne    1c43 <botlish_fn_13+0x19d>
    1c39:	mov    rsi,QWORD PTR [rsp+0x30]
    1c3e:	jmp    1c5a <botlish_fn_13+0x1b4>
    1c43:	mov    edx,0x3
    1c48:	mov    rsi,QWORD PTR [rsp+0x40]
    1c4d:	mov    rdi,r15
    1c50:	call   1c55 <botlish_fn_13+0x1af>
			1c51: R_X86_64_PLT32	rt_int_add-0x4
    1c55:	mov    rsi,QWORD PTR [rsp+0x30]
    1c5a:	mov    QWORD PTR [rsp],rsi
    1c5e:	mov    rdx,QWORD PTR [rsp+0x38]
    1c63:	mov    QWORD PTR [rsp+0x8],rdx
    1c68:	mov    QWORD PTR [rsp+0x10],rax
    1c6d:	mov    QWORD PTR [rsp+0x30],rsi
    1c72:	mov    QWORD PTR [rsp+0x40],rax
    1c77:	jmp    1b1a <botlish_fn_13+0x74>
    1c7c:	mov    rdx,QWORD PTR [rsp+0x38]
    1c81:	mov    rsi,QWORD PTR [rsp+0x30]
    1c86:	mov    rcx,QWORD PTR [rsp+0x40]
    1c8b:	mov    rdi,r15
    1c8e:	call   1c93 <botlish_fn_13+0x1ed>
			1c8f: R_X86_64_PLT32	rt_substr-0x4
    1c93:	test   rax,rax
    1c96:	jne    1cd0 <botlish_fn_13+0x22a>
    1c9c:	mov    rdi,r15
    1c9f:	mov    rdi,r15
    1ca2:	mov    QWORD PTR [rdi],r14
    1ca5:	xor    rdx,rdx
    1ca8:	mov    rax,rdx
    1cab:	mov    rbx,QWORD PTR [rsp+0x50]
    1cb0:	mov    r12,QWORD PTR [rsp+0x58]
    1cb5:	mov    r13,QWORD PTR [rsp+0x60]
    1cba:	mov    r14,QWORD PTR [rsp+0x68]
    1cbf:	mov    r15,QWORD PTR [rsp+0x70]
    1cc4:	add    rsp,0x80
    1ccb:	mov    rsp,rbp
    1cce:	pop    rbp
    1ccf:	ret
    1cd0:	mov    rdi,r15
    1cd3:	mov    QWORD PTR [rdi],r14
    1cd6:	mov    rdx,QWORD PTR [rsp+0x40]
    1cdb:	mov    rbx,QWORD PTR [rsp+0x50]
    1ce0:	mov    r12,QWORD PTR [rsp+0x58]
    1ce5:	mov    r13,QWORD PTR [rsp+0x60]
    1cea:	mov    r14,QWORD PTR [rsp+0x68]
    1cef:	mov    r15,QWORD PTR [rsp+0x70]
    1cf4:	add    rsp,0x80
    1cfb:	mov    rsp,rbp
    1cfe:	pop    rbp
    1cff:	ret
    1d00:	mov    r15,rdi
    1d03:	call   1d08 <botlish_fn_13+0x262>
			1d04: R_X86_64_PLT32	rt_stack_overflow-0x4
    1d08:	xor    rdx,rdx
    1d0b:	mov    rax,rdx
    1d0e:	mov    rbx,QWORD PTR [rsp+0x50]
    1d13:	mov    r12,QWORD PTR [rsp+0x58]
    1d18:	mov    r13,QWORD PTR [rsp+0x60]
    1d1d:	mov    r14,QWORD PTR [rsp+0x68]
    1d22:	mov    r15,QWORD PTR [rsp+0x70]
    1d27:	add    rsp,0x80
    1d2e:	mov    rsp,rbp
    1d31:	pop    rbp
    1d32:	ret

0000000000001d33 <botlish_entry_13: scan_unquoted<str, int, int>>:
    1d33:	push   rbp
    1d34:	mov    rbp,rsp
    1d37:	ud2

0000000000001d39 <botlish_fn_14: scan_quoted<str, int, str>>:
    1d39:	push   rbp
    1d3a:	mov    rbp,rsp
    1d3d:	sub    rsp,0x80
    1d44:	mov    QWORD PTR [rsp+0x50],rbx
    1d49:	mov    QWORD PTR [rsp+0x58],r12
    1d4e:	mov    QWORD PTR [rsp+0x60],r13
    1d53:	mov    QWORD PTR [rsp+0x68],r14
    1d58:	mov    QWORD PTR [rsp+0x70],r15
    1d5d:	mov    r13,QWORD PTR [rdi]
    1d60:	mov    rax,QWORD PTR [rdi+0x8]
    1d64:	lea    r8,[r13+0x8]
    1d68:	cmp    r8,rax
    1d6b:	ja     205d <botlish_fn_14+0x324>
    1d71:	lea    rax,[r13+0x8]
    1d75:	mov    QWORD PTR [rdi],rax
    1d78:	mov    r14,rdi
    1d7b:	mov    QWORD PTR [r13+0x0],0x0
    1d83:	mov    QWORD PTR [rsp+0x18],0x0
    1d8c:	mov    QWORD PTR [rsp+0x20],0x0
    1d95:	mov    QWORD PTR [rsp],rsi
    1d99:	mov    QWORD PTR [rsp+0x8],rdx
    1d9e:	mov    QWORD PTR [rsp+0x10],rcx
    1da3:	lea    rbx,[rsp+0x28]
    1da8:	mov    r12,rsi
    1dab:	mov    r15,rdx
    1dae:	mov    QWORD PTR [rsp+0x38],rcx
    1db3:	mov    rdx,r15
    1db6:	mov    rsi,r12
    1db9:	mov    rdi,r14
    1dbc:	call   1dc1 <botlish_fn_14+0x88>
			1dbd: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1dc1:	test   rax,rax
    1dc4:	jne    1dd2 <botlish_fn_14+0x99>
    1dca:	mov    rdi,r14
    1dcd:	jmp    2011 <botlish_fn_14+0x2d8>
    1dd2:	mov    QWORD PTR [rsp+0x18],rax
    1dd7:	mov    rdi,r14
    1dda:	mov    QWORD PTR [rsp+0x40],rax
    1ddf:	mov    rsi,QWORD PTR [rdi+0x10]
    1de3:	mov    rsi,QWORD PTR [rsi+0x28]
    1de7:	mov    edx,0x1
    1dec:	mov    ecx,0x3
    1df1:	mov    r8,QWORD PTR [rsp+0x40]
    1df6:	call   1dfb <botlish_fn_14+0xc2>
			1df7: R_X86_64_PLT32	rt_str_region_eq-0x4
    1dfb:	cmp    rax,0x6
    1dff:	je     1e90 <botlish_fn_14+0x157>
    1e05:	mov    QWORD PTR [rsp+0x20],0x3
    1e0e:	mov    rsi,r15
    1e11:	test   rsi,0x1
    1e18:	je     1e3a <botlish_fn_14+0x101>
    1e1e:	mov    r9,rsi
    1e21:	add    r9,0x2
    1e25:	seto   r11b
    1e29:	test   r11b,r11b
    1e2c:	jne    1e3a <botlish_fn_14+0x101>
    1e32:	mov    rsi,r9
    1e35:	jmp    1e4a <botlish_fn_14+0x111>
    1e3a:	mov    edx,0x3
    1e3f:	mov    rdi,r14
    1e42:	call   1e47 <botlish_fn_14+0x10e>
			1e43: R_X86_64_PLT32	rt_int_add-0x4
    1e47:	mov    rsi,rax
    1e4a:	mov    QWORD PTR [rsp+0x8],rsi
    1e4f:	mov    r15,rsi
    1e52:	mov    rsi,QWORD PTR [rsp+0x38]
    1e57:	mov    rdx,QWORD PTR [rsp+0x40]
    1e5c:	mov    rdi,r14
    1e5f:	call   1e64 <botlish_fn_14+0x12b>
			1e60: R_X86_64_PLT32	rt_str_cat-0x4
    1e64:	test   rax,rax
    1e67:	jne    1e75 <botlish_fn_14+0x13c>
    1e6d:	mov    rdi,r14
    1e70:	jmp    2011 <botlish_fn_14+0x2d8>
    1e75:	mov    QWORD PTR [rsp],r12
    1e79:	mov    rsi,r15
    1e7c:	mov    QWORD PTR [rsp+0x8],rsi
    1e81:	mov    QWORD PTR [rsp+0x10],rax
    1e86:	mov    QWORD PTR [rsp+0x38],rax
    1e8b:	jmp    1db3 <botlish_fn_14+0x7a>
    1e90:	mov    QWORD PTR [rsp+0x18],0x3
    1e99:	mov    rsi,r15
    1e9c:	test   rsi,0x1
    1ea3:	je     1ebe <botlish_fn_14+0x185>
    1ea9:	mov    rsi,r15
    1eac:	mov    rdx,rsi
    1eaf:	add    rdx,0x2
    1eb3:	seto   al
    1eb6:	test   al,al
    1eb8:	je     1ed1 <botlish_fn_14+0x198>
    1ebe:	mov    edx,0x3
    1ec3:	mov    rsi,r15
    1ec6:	mov    rdi,r14
    1ec9:	call   1ece <botlish_fn_14+0x195>
			1eca: R_X86_64_PLT32	rt_int_add-0x4
    1ece:	mov    rdx,rax
    1ed1:	mov    QWORD PTR [rsp+0x18],rdx
    1ed6:	mov    rcx,rbx
    1ed9:	mov    rsi,r12
    1edc:	mov    rdi,r14
    1edf:	call   1ee4 <botlish_fn_14+0x1ab>
			1ee0: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1ee4:	test   rax,rax
    1ee7:	mov    rsi,rax
    1eea:	jne    1ef8 <botlish_fn_14+0x1bf>
    1ef0:	mov    rdi,r14
    1ef3:	jmp    2011 <botlish_fn_14+0x2d8>
    1ef8:	mov    rdx,QWORD PTR [rsp+0x28]
    1efd:	mov    rcx,QWORD PTR [rsp+0x30]
    1f02:	mov    rdi,r14
    1f05:	mov    rax,QWORD PTR [rdi+0x10]
    1f09:	mov    r8,QWORD PTR [rax+0x28]
    1f0d:	call   1f12 <botlish_fn_14+0x1d9>
			1f0e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f12:	cmp    rax,0x6
    1f16:	je     1f97 <botlish_fn_14+0x25e>
    1f1c:	mov    QWORD PTR [rsp],0x3
    1f24:	mov    rsi,r15
    1f27:	test   rsi,0x1
    1f2e:	je     1f51 <botlish_fn_14+0x218>
    1f34:	mov    rsi,r15
    1f37:	mov    rdx,rsi
    1f3a:	add    rdx,0x2
    1f3e:	seto   al
    1f41:	test   al,al
    1f43:	jne    1f51 <botlish_fn_14+0x218>
    1f49:	mov    rdi,r14
    1f4c:	jmp    1f67 <botlish_fn_14+0x22e>
    1f51:	mov    edx,0x3
    1f56:	mov    rsi,r15
    1f59:	mov    rdi,r14
    1f5c:	call   1f61 <botlish_fn_14+0x228>
			1f5d: R_X86_64_PLT32	rt_int_add-0x4
    1f61:	mov    rdx,rax
    1f64:	mov    rdi,r14
    1f67:	mov    rdi,r14
    1f6a:	mov    QWORD PTR [rdi],r13
    1f6d:	mov    rax,QWORD PTR [rsp+0x38]
    1f72:	mov    rbx,QWORD PTR [rsp+0x50]
    1f77:	mov    r12,QWORD PTR [rsp+0x58]
    1f7c:	mov    r13,QWORD PTR [rsp+0x60]
    1f81:	mov    r14,QWORD PTR [rsp+0x68]
    1f86:	mov    r15,QWORD PTR [rsp+0x70]
    1f8b:	add    rsp,0x80
    1f92:	mov    rsp,rbp
    1f95:	pop    rbp
    1f96:	ret
    1f97:	mov    QWORD PTR [rsp+0x18],0x5
    1fa0:	mov    rsi,r15
    1fa3:	test   rsi,0x1
    1faa:	je     1fd0 <botlish_fn_14+0x297>
    1fb0:	mov    rsi,r15
    1fb3:	mov    rax,rsi
    1fb6:	add    rax,0x4
    1fba:	seto   cl
    1fbd:	test   cl,cl
    1fbf:	jne    1fd0 <botlish_fn_14+0x297>
    1fc5:	mov    rsi,rax
    1fc8:	mov    r15,rax
    1fcb:	jmp    1fe6 <botlish_fn_14+0x2ad>
    1fd0:	mov    edx,0x5
    1fd5:	mov    rsi,r15
    1fd8:	mov    rdi,r14
    1fdb:	call   1fe0 <botlish_fn_14+0x2a7>
			1fdc: R_X86_64_PLT32	rt_int_add-0x4
    1fe0:	mov    rsi,rax
    1fe3:	mov    r15,rax
    1fe6:	mov    QWORD PTR [rsp+0x8],rsi
    1feb:	mov    rdi,r14
    1fee:	mov    rax,QWORD PTR [rdi+0x10]
    1ff2:	mov    rdx,QWORD PTR [rax+0x28]
    1ff6:	mov    QWORD PTR [rsp+0x18],rdx
    1ffb:	mov    rsi,QWORD PTR [rsp+0x38]
    2000:	call   2005 <botlish_fn_14+0x2cc>
			2001: R_X86_64_PLT32	rt_str_cat-0x4
    2005:	test   rax,rax
    2008:	jne    2042 <botlish_fn_14+0x309>
    200e:	mov    rdi,r14
    2011:	mov    rdi,r14
    2014:	mov    QWORD PTR [rdi],r13
    2017:	xor    rdx,rdx
    201a:	mov    rax,rdx
    201d:	mov    rbx,QWORD PTR [rsp+0x50]
    2022:	mov    r12,QWORD PTR [rsp+0x58]
    2027:	mov    r13,QWORD PTR [rsp+0x60]
    202c:	mov    r14,QWORD PTR [rsp+0x68]
    2031:	mov    r15,QWORD PTR [rsp+0x70]
    2036:	add    rsp,0x80
    203d:	mov    rsp,rbp
    2040:	pop    rbp
    2041:	ret
    2042:	mov    QWORD PTR [rsp],r12
    2046:	mov    rsi,r15
    2049:	mov    QWORD PTR [rsp+0x8],rsi
    204e:	mov    QWORD PTR [rsp+0x10],rax
    2053:	mov    QWORD PTR [rsp+0x38],rax
    2058:	jmp    1db3 <botlish_fn_14+0x7a>
    205d:	mov    r14,rdi
    2060:	call   2065 <botlish_fn_14+0x32c>
			2061: R_X86_64_PLT32	rt_stack_overflow-0x4
    2065:	xor    rdx,rdx
    2068:	mov    rax,rdx
    206b:	mov    rbx,QWORD PTR [rsp+0x50]
    2070:	mov    r12,QWORD PTR [rsp+0x58]
    2075:	mov    r13,QWORD PTR [rsp+0x60]
    207a:	mov    r14,QWORD PTR [rsp+0x68]
    207f:	mov    r15,QWORD PTR [rsp+0x70]
    2084:	add    rsp,0x80
    208b:	mov    rsp,rbp
    208e:	pop    rbp
    208f:	ret

0000000000002090 <botlish_entry_14: scan_quoted<str, int, str>>:
    2090:	push   rbp
    2091:	mov    rbp,rsp
    2094:	ud2

0000000000002096 <botlish_fn_15: scan_field<str, int>>:
    2096:	push   rbp
    2097:	mov    rbp,rsp
    209a:	sub    rsp,0x50
    209e:	mov    QWORD PTR [rsp+0x30],rbx
    20a3:	mov    QWORD PTR [rsp+0x38],r12
    20a8:	mov    QWORD PTR [rsp+0x40],r13
    20ad:	mov    QWORD PTR [rsp+0x48],r14
    20b2:	mov    rbx,QWORD PTR [rdi]
    20b5:	mov    rax,QWORD PTR [rdi+0x8]
    20b9:	lea    rcx,[rbx+0x8]
    20bd:	cmp    rcx,rax
    20c0:	ja     2232 <botlish_fn_15+0x19c>
    20c6:	lea    rax,[rbx+0x8]
    20ca:	mov    QWORD PTR [rdi],rax
    20cd:	mov    r12,rdi
    20d0:	mov    QWORD PTR [rbx],0x0
    20d7:	mov    QWORD PTR [rsp+0x10],0x0
    20e0:	mov    QWORD PTR [rsp],rsi
    20e4:	mov    r13,rsi
    20e7:	mov    QWORD PTR [rsp+0x8],rdx
    20ec:	mov    r14,rdx
    20ef:	lea    rcx,[rsp+0x18]
    20f4:	mov    rdx,r14
    20f7:	mov    rsi,r13
    20fa:	mov    rdi,r12
    20fd:	call   2102 <botlish_fn_15+0x6c>
			20fe: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    2102:	test   rax,rax
    2105:	mov    rsi,rax
    2108:	jne    2116 <botlish_fn_15+0x80>
    210e:	mov    rdi,r12
    2111:	jmp    21e6 <botlish_fn_15+0x150>
    2116:	mov    rdx,QWORD PTR [rsp+0x18]
    211b:	mov    rcx,QWORD PTR [rsp+0x20]
    2120:	mov    rdi,r12
    2123:	mov    rax,QWORD PTR [rdi+0x10]
    2127:	mov    r8,QWORD PTR [rax+0x28]
    212b:	call   2130 <botlish_fn_15+0x9a>
			212c: R_X86_64_PLT32	rt_str_region_eq-0x4
    2130:	cmp    rax,0x6
    2134:	je     217f <botlish_fn_15+0xe9>
    213a:	mov    rcx,r14
    213d:	mov    rsi,r13
    2140:	mov    rdi,r12
    2143:	mov    rdx,rcx
    2146:	call   214b <botlish_fn_15+0xb5>
			2147: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    214b:	test   rax,rax
    214e:	jne    215c <botlish_fn_15+0xc6>
    2154:	mov    rdi,r12
    2157:	jmp    21e6 <botlish_fn_15+0x150>
    215c:	mov    rdi,r12
    215f:	mov    QWORD PTR [rdi],rbx
    2162:	mov    rbx,QWORD PTR [rsp+0x30]
    2167:	mov    r12,QWORD PTR [rsp+0x38]
    216c:	mov    r13,QWORD PTR [rsp+0x40]
    2171:	mov    r14,QWORD PTR [rsp+0x48]
    2176:	add    rsp,0x50
    217a:	mov    rsp,rbp
    217d:	pop    rbp
    217e:	ret
    217f:	mov    QWORD PTR [rsp+0x10],0x3
    2188:	mov    rdx,r14
    218b:	test   rdx,0x1
    2192:	je     21aa <botlish_fn_15+0x114>
    2198:	mov    rdx,r14
    219b:	add    rdx,0x2
    219f:	seto   al
    21a2:	test   al,al
    21a4:	je     21bd <botlish_fn_15+0x127>
    21aa:	mov    edx,0x3
    21af:	mov    rsi,r14
    21b2:	mov    rdi,r12
    21b5:	call   21ba <botlish_fn_15+0x124>
			21b6: R_X86_64_PLT32	rt_int_add-0x4
    21ba:	mov    rdx,rax
    21bd:	mov    QWORD PTR [rsp+0x8],rdx
    21c2:	mov    rdi,r12
    21c5:	mov    rax,QWORD PTR [rdi+0x10]
    21c9:	mov    rcx,QWORD PTR [rax+0x10]
    21cd:	mov    QWORD PTR [rsp+0x10],rcx
    21d2:	mov    rsi,r13
    21d5:	call   21da <botlish_fn_15+0x144>
			21d6: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    21da:	test   rax,rax
    21dd:	jne    220f <botlish_fn_15+0x179>
    21e3:	mov    rdi,r12
    21e6:	mov    rdi,r12
    21e9:	mov    QWORD PTR [rdi],rbx
    21ec:	xor    rdx,rdx
    21ef:	mov    rax,rdx
    21f2:	mov    rbx,QWORD PTR [rsp+0x30]
    21f7:	mov    r12,QWORD PTR [rsp+0x38]
    21fc:	mov    r13,QWORD PTR [rsp+0x40]
    2201:	mov    r14,QWORD PTR [rsp+0x48]
    2206:	add    rsp,0x50
    220a:	mov    rsp,rbp
    220d:	pop    rbp
    220e:	ret
    220f:	mov    rdi,r12
    2212:	mov    QWORD PTR [rdi],rbx
    2215:	mov    rbx,QWORD PTR [rsp+0x30]
    221a:	mov    r12,QWORD PTR [rsp+0x38]
    221f:	mov    r13,QWORD PTR [rsp+0x40]
    2224:	mov    r14,QWORD PTR [rsp+0x48]
    2229:	add    rsp,0x50
    222d:	mov    rsp,rbp
    2230:	pop    rbp
    2231:	ret
    2232:	mov    r12,rdi
    2235:	call   223a <botlish_fn_15+0x1a4>
			2236: R_X86_64_PLT32	rt_stack_overflow-0x4
    223a:	xor    rdx,rdx
    223d:	mov    rax,rdx
    2240:	mov    rbx,QWORD PTR [rsp+0x30]
    2245:	mov    r12,QWORD PTR [rsp+0x38]
    224a:	mov    r13,QWORD PTR [rsp+0x40]
    224f:	mov    r14,QWORD PTR [rsp+0x48]
    2254:	add    rsp,0x50
    2258:	mov    rsp,rbp
    225b:	pop    rbp
    225c:	ret

000000000000225d <botlish_entry_15: scan_field<str, int>>:
    225d:	push   rbp
    225e:	mov    rbp,rsp
    2261:	ud2

0000000000002263 <botlish_fn_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    2263:	push   rbp
    2264:	mov    rbp,rsp
    2267:	sub    rsp,0xb0
    226e:	mov    QWORD PTR [rsp+0x80],rbx
    2276:	mov    QWORD PTR [rsp+0x88],r12
    227e:	mov    QWORD PTR [rsp+0x90],r13
    2286:	mov    QWORD PTR [rsp+0x98],r14
    228e:	mov    QWORD PTR [rsp+0xa0],r15
    2296:	mov    rbx,QWORD PTR [rdi]
    2299:	mov    rax,QWORD PTR [rdi+0x8]
    229d:	lea    r10,[rbx+0x8]
    22a1:	cmp    r10,rax
    22a4:	ja     25f4 <botlish_fn_16+0x391>
    22aa:	lea    rax,[rbx+0x8]
    22ae:	mov    QWORD PTR [rdi],rax
    22b1:	mov    r14,rdi
    22b4:	mov    QWORD PTR [rbx],0x0
    22bb:	mov    QWORD PTR [rsp+0x28],0x0
    22c4:	mov    QWORD PTR [rsp],rsi
    22c8:	mov    QWORD PTR [rsp+0x50],rsi
    22cd:	mov    QWORD PTR [rsp+0x8],rdx
    22d2:	mov    QWORD PTR [rsp+0x10],rcx
    22d7:	mov    QWORD PTR [rsp+0x58],rcx
    22dc:	mov    QWORD PTR [rsp+0x18],r8
    22e1:	mov    r13,r8
    22e4:	mov    QWORD PTR [rsp+0x20],r9
    22e9:	mov    r12,r9
    22ec:	mov    rsi,QWORD PTR [rsp+0x50]
    22f1:	mov    rdi,r14
    22f4:	call   22f9 <botlish_fn_16+0x96>
			22f5: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    22f9:	test   rax,rax
    22fc:	jne    230a <botlish_fn_16+0xa7>
    2302:	mov    rdi,r14
    2305:	jmp    257a <botlish_fn_16+0x317>
    230a:	mov    QWORD PTR [rsp+0x8],rax
    230f:	mov    r8,rax
    2312:	mov    QWORD PTR [rsp+0x28],rdx
    2317:	mov    r15,rdx
    231a:	lea    r9,[rsp+0x30]
    231f:	mov    rcx,r12
    2322:	mov    rdx,r13
    2325:	mov    rsi,QWORD PTR [rsp+0x58]
    232a:	mov    rdi,r14
    232d:	call   2332 <botlish_fn_16+0xcf>
			232e: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[list<never>, mutarray, int], str>
    2332:	test   rax,rax
    2335:	jne    2343 <botlish_fn_16+0xe0>
    233b:	mov    rdi,r14
    233e:	jmp    257a <botlish_fn_16+0x317>
    2343:	mov    QWORD PTR [rsp+0x8],rax
    2348:	mov    QWORD PTR [rsp+0x70],rax
    234d:	mov    rdx,QWORD PTR [rsp+0x30]
    2352:	mov    QWORD PTR [rsp+0x10],rdx
    2357:	mov    QWORD PTR [rsp+0x68],rdx
    235c:	mov    rcx,QWORD PTR [rsp+0x38]
    2361:	mov    QWORD PTR [rsp+0x18],rcx
    2366:	mov    QWORD PTR [rsp+0x60],rcx
    236b:	lea    rcx,[rsp+0x40]
    2370:	mov    rdx,r15
    2373:	mov    rsi,QWORD PTR [rsp+0x50]
    2378:	mov    rdi,r14
    237b:	call   2380 <botlish_fn_16+0x11d>
			237c: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    2380:	test   rax,rax
    2383:	mov    QWORD PTR [rsp+0x58],rax
    2388:	jne    2396 <botlish_fn_16+0x133>
    238e:	mov    rdi,r14
    2391:	jmp    257a <botlish_fn_16+0x317>
    2396:	mov    r13,QWORD PTR [rsp+0x40]
    239b:	mov    r12,QWORD PTR [rsp+0x48]
    23a0:	mov    rdi,r14
    23a3:	mov    rsi,QWORD PTR [rdi+0x10]
    23a7:	mov    r8,QWORD PTR [rsi+0x18]
    23ab:	mov    rcx,r12
    23ae:	mov    rdx,r13
    23b1:	mov    rsi,QWORD PTR [rsp+0x58]
    23b6:	call   23bb <botlish_fn_16+0x158>
			23b7: R_X86_64_PLT32	rt_str_region_eq-0x4
    23bb:	cmp    rax,0x6
    23bf:	je     2504 <botlish_fn_16+0x2a1>
    23c5:	mov    rdi,r14
    23c8:	mov    r9,QWORD PTR [rdi+0x10]
    23cc:	mov    r8,QWORD PTR [r9+0x20]
    23d0:	mov    rcx,r12
    23d3:	mov    rdx,r13
    23d6:	mov    rsi,QWORD PTR [rsp+0x58]
    23db:	call   23e0 <botlish_fn_16+0x17d>
			23dc: R_X86_64_PLT32	rt_str_region_eq-0x4
    23e0:	cmp    rax,0x6
    23e4:	je     244f <botlish_fn_16+0x1ec>
    23ea:	mov    rcx,QWORD PTR [rsp+0x60]
    23ef:	mov    rdx,QWORD PTR [rsp+0x68]
    23f4:	mov    rsi,QWORD PTR [rsp+0x70]
    23f9:	mov    rdi,r14
    23fc:	call   2401 <botlish_fn_16+0x19e>
			23fd: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2401:	test   rax,rax
    2404:	jne    2412 <botlish_fn_16+0x1af>
    240a:	mov    rdi,r14
    240d:	jmp    257a <botlish_fn_16+0x317>
    2412:	mov    rdi,r14
    2415:	mov    QWORD PTR [rdi],rbx
    2418:	mov    rdx,r15
    241b:	mov    rbx,QWORD PTR [rsp+0x80]
    2423:	mov    r12,QWORD PTR [rsp+0x88]
    242b:	mov    r13,QWORD PTR [rsp+0x90]
    2433:	mov    r14,QWORD PTR [rsp+0x98]
    243b:	mov    r15,QWORD PTR [rsp+0xa0]
    2443:	add    rsp,0xb0
    244a:	mov    rsp,rbp
    244d:	pop    rbp
    244e:	ret
    244f:	mov    rcx,QWORD PTR [rsp+0x60]
    2454:	mov    rdx,QWORD PTR [rsp+0x68]
    2459:	mov    rsi,QWORD PTR [rsp+0x70]
    245e:	mov    rdi,r14
    2461:	call   2466 <botlish_fn_16+0x203>
			2462: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2466:	test   rax,rax
    2469:	jne    2477 <botlish_fn_16+0x214>
    246f:	mov    rdi,r14
    2472:	jmp    257a <botlish_fn_16+0x317>
    2477:	mov    QWORD PTR [rsp],rax
    247b:	mov    r12,rax
    247e:	mov    QWORD PTR [rsp+0x8],0x3
    2487:	mov    rdx,r15
    248a:	test   rdx,0x1
    2491:	je     24b1 <botlish_fn_16+0x24e>
    2497:	mov    rdx,r15
    249a:	add    rdx,0x2
    249e:	seto   al
    24a1:	test   al,al
    24a3:	jne    24b1 <botlish_fn_16+0x24e>
    24a9:	mov    rdi,r14
    24ac:	jmp    24c7 <botlish_fn_16+0x264>
    24b1:	mov    edx,0x3
    24b6:	mov    rsi,r15
    24b9:	mov    rdi,r14
    24bc:	call   24c1 <botlish_fn_16+0x25e>
			24bd: R_X86_64_PLT32	rt_int_add-0x4
    24c1:	mov    rdx,rax
    24c4:	mov    rdi,r14
    24c7:	mov    rdi,r14
    24ca:	mov    QWORD PTR [rdi],rbx
    24cd:	mov    rax,r12
    24d0:	mov    rbx,QWORD PTR [rsp+0x80]
    24d8:	mov    r12,QWORD PTR [rsp+0x88]
    24e0:	mov    r13,QWORD PTR [rsp+0x90]
    24e8:	mov    r14,QWORD PTR [rsp+0x98]
    24f0:	mov    r15,QWORD PTR [rsp+0xa0]
    24f8:	add    rsp,0xb0
    24ff:	mov    rsp,rbp
    2502:	pop    rbp
    2503:	ret
    2504:	mov    rsi,r15
    2507:	mov    edx,0x3
    250c:	mov    rcx,rdx
    250f:	mov    QWORD PTR [rsp+0x20],0x3
    2518:	test   rsi,0x1
    251f:	jne    252d <botlish_fn_16+0x2ca>
    2525:	mov    rdx,rcx
    2528:	jmp    2542 <botlish_fn_16+0x2df>
    252d:	mov    rdx,rsi
    2530:	add    rdx,0x2
    2534:	seto   al
    2537:	test   al,al
    2539:	je     254d <botlish_fn_16+0x2ea>
    253f:	mov    rdx,rcx
    2542:	mov    rdi,r14
    2545:	call   254a <botlish_fn_16+0x2e7>
			2546: R_X86_64_PLT32	rt_int_add-0x4
    254a:	mov    rdx,rax
    254d:	mov    QWORD PTR [rsp+0x20],rdx
    2552:	mov    rcx,QWORD PTR [rsp+0x70]
    2557:	mov    rsi,QWORD PTR [rsp+0x50]
    255c:	mov    r8,QWORD PTR [rsp+0x68]
    2561:	mov    r9,QWORD PTR [rsp+0x60]
    2566:	mov    rdi,r14
    2569:	call   256e <botlish_fn_16+0x30b>
			256a: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int, list[list<mutarray>, mutarray, int]>
    256e:	test   rax,rax
    2571:	jne    25ba <botlish_fn_16+0x357>
    2577:	mov    rdi,r14
    257a:	mov    rdi,r14
    257d:	mov    QWORD PTR [rdi],rbx
    2580:	xor    rdx,rdx
    2583:	mov    rax,rdx
    2586:	mov    rbx,QWORD PTR [rsp+0x80]
    258e:	mov    r12,QWORD PTR [rsp+0x88]
    2596:	mov    r13,QWORD PTR [rsp+0x90]
    259e:	mov    r14,QWORD PTR [rsp+0x98]
    25a6:	mov    r15,QWORD PTR [rsp+0xa0]
    25ae:	add    rsp,0xb0
    25b5:	mov    rsp,rbp
    25b8:	pop    rbp
    25b9:	ret
    25ba:	mov    rdi,r14
    25bd:	mov    QWORD PTR [rdi],rbx
    25c0:	mov    rbx,QWORD PTR [rsp+0x80]
    25c8:	mov    r12,QWORD PTR [rsp+0x88]
    25d0:	mov    r13,QWORD PTR [rsp+0x90]
    25d8:	mov    r14,QWORD PTR [rsp+0x98]
    25e0:	mov    r15,QWORD PTR [rsp+0xa0]
    25e8:	add    rsp,0xb0
    25ef:	mov    rsp,rbp
    25f2:	pop    rbp
    25f3:	ret
    25f4:	mov    r14,rdi
    25f7:	call   25fc <botlish_fn_16+0x399>
			25f8: R_X86_64_PLT32	rt_stack_overflow-0x4
    25fc:	xor    rdx,rdx
    25ff:	mov    rax,rdx
    2602:	mov    rbx,QWORD PTR [rsp+0x80]
    260a:	mov    r12,QWORD PTR [rsp+0x88]
    2612:	mov    r13,QWORD PTR [rsp+0x90]
    261a:	mov    r14,QWORD PTR [rsp+0x98]
    2622:	mov    r15,QWORD PTR [rsp+0xa0]
    262a:	add    rsp,0xb0
    2631:	mov    rsp,rbp
    2634:	pop    rbp
    2635:	ret

0000000000002636 <botlish_entry_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    2636:	push   rbp
    2637:	mov    rbp,rsp
    263a:	ud2

000000000000263c <botlish_fn_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    263c:	push   rbp
    263d:	mov    rbp,rsp
    2640:	sub    rsp,0xc0
    2647:	mov    QWORD PTR [rsp+0x90],rbx
    264f:	mov    QWORD PTR [rsp+0x98],r12
    2657:	mov    QWORD PTR [rsp+0xa0],r13
    265f:	mov    QWORD PTR [rsp+0xa8],r14
    2667:	mov    QWORD PTR [rsp+0xb0],r15
    266f:	mov    r14,QWORD PTR [rdi]
    2672:	mov    rax,QWORD PTR [rdi+0x8]
    2676:	lea    r10,[r14+0x8]
    267a:	cmp    r10,rax
    267d:	ja     29dc <botlish_fn_17+0x3a0>
    2683:	lea    rax,[r14+0x8]
    2687:	mov    QWORD PTR [rdi],rax
    268a:	mov    QWORD PTR [rsp+0x50],rdi
    268f:	mov    QWORD PTR [r14],0x0
    2696:	mov    QWORD PTR [rsp+0x28],0x0
    269f:	mov    QWORD PTR [rsp],rsi
    26a3:	mov    QWORD PTR [rsp+0x8],rdx
    26a8:	mov    QWORD PTR [rsp+0x10],rcx
    26ad:	mov    QWORD PTR [rsp+0x18],r8
    26b2:	mov    QWORD PTR [rsp+0x20],r9
    26b7:	lea    r12,[rsp+0x30]
    26bc:	mov    QWORD PTR [rsp+0x80],r12
    26c4:	lea    r12,[rsp+0x40]
    26c9:	mov    rbx,rcx
    26cc:	mov    r13,rsi
    26cf:	mov    QWORD PTR [rsp+0x58],r8
    26d4:	mov    QWORD PTR [rsp+0x60],r9
    26d9:	mov    rsi,r13
    26dc:	mov    rdi,QWORD PTR [rsp+0x50]
    26e1:	call   26e6 <botlish_fn_17+0xaa>
			26e2: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    26e6:	mov    QWORD PTR [rsp+0x78],rdx
    26eb:	test   rax,rax
    26ee:	jne    26fe <botlish_fn_17+0xc2>
    26f4:	mov    rdi,QWORD PTR [rsp+0x50]
    26f9:	jmp    2883 <botlish_fn_17+0x247>
    26fe:	mov    QWORD PTR [rsp+0x8],rax
    2703:	mov    rdx,QWORD PTR [rsp+0x78]
    2708:	mov    r8,rax
    270b:	mov    QWORD PTR [rsp+0x28],rdx
    2710:	mov    rcx,QWORD PTR [rsp+0x60]
    2715:	mov    rdx,QWORD PTR [rsp+0x58]
    271a:	mov    rsi,rbx
    271d:	mov    rdi,QWORD PTR [rsp+0x50]
    2722:	mov    r9,QWORD PTR [rsp+0x80]
    272a:	call   272f <botlish_fn_17+0xf3>
			272b: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], str>
    272f:	test   rax,rax
    2732:	jne    2742 <botlish_fn_17+0x106>
    2738:	mov    rdi,QWORD PTR [rsp+0x50]
    273d:	jmp    2883 <botlish_fn_17+0x247>
    2742:	mov    QWORD PTR [rsp+0x8],rax
    2747:	mov    QWORD PTR [rsp+0x70],rax
    274c:	mov    rdx,QWORD PTR [rsp+0x30]
    2751:	mov    QWORD PTR [rsp+0x58],rdx
    2756:	mov    QWORD PTR [rsp+0x10],rdx
    275b:	mov    rcx,QWORD PTR [rsp+0x38]
    2760:	mov    QWORD PTR [rsp+0x18],rcx
    2765:	mov    QWORD PTR [rsp+0x60],rcx
    276a:	mov    rcx,r12
    276d:	mov    rdx,QWORD PTR [rsp+0x78]
    2772:	mov    rsi,r13
    2775:	mov    rdi,QWORD PTR [rsp+0x50]
    277a:	call   277f <botlish_fn_17+0x143>
			277b: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    277f:	test   rax,rax
    2782:	mov    QWORD PTR [rsp+0x68],rax
    2787:	jne    2797 <botlish_fn_17+0x15b>
    278d:	mov    rdi,QWORD PTR [rsp+0x50]
    2792:	jmp    2883 <botlish_fn_17+0x247>
    2797:	mov    rbx,QWORD PTR [rsp+0x40]
    279c:	mov    r15,QWORD PTR [rsp+0x48]
    27a1:	mov    rdi,QWORD PTR [rsp+0x50]
    27a6:	mov    r8,QWORD PTR [rdi+0x10]
    27aa:	mov    r8,QWORD PTR [r8+0x18]
    27ae:	mov    rcx,r15
    27b1:	mov    rdx,rbx
    27b4:	mov    rsi,QWORD PTR [rsp+0x68]
    27b9:	call   27be <botlish_fn_17+0x182>
			27ba: R_X86_64_PLT32	rt_str_region_eq-0x4
    27be:	cmp    rax,0x6
    27c2:	je     2960 <botlish_fn_17+0x324>
    27c8:	mov    rdi,QWORD PTR [rsp+0x50]
    27cd:	mov    r11,QWORD PTR [rdi+0x10]
    27d1:	mov    r8,QWORD PTR [r11+0x20]
    27d5:	mov    rcx,r15
    27d8:	mov    rdx,rbx
    27db:	mov    rsi,QWORD PTR [rsp+0x68]
    27e0:	call   27e5 <botlish_fn_17+0x1a9>
			27e1: R_X86_64_PLT32	rt_str_region_eq-0x4
    27e5:	cmp    rax,0x6
    27e9:	je     285c <botlish_fn_17+0x220>
    27ef:	mov    rcx,QWORD PTR [rsp+0x60]
    27f4:	mov    rdx,QWORD PTR [rsp+0x58]
    27f9:	mov    rsi,QWORD PTR [rsp+0x70]
    27fe:	mov    rdi,QWORD PTR [rsp+0x50]
    2803:	call   2808 <botlish_fn_17+0x1cc>
			2804: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2808:	test   rax,rax
    280b:	jne    281b <botlish_fn_17+0x1df>
    2811:	mov    rdi,QWORD PTR [rsp+0x50]
    2816:	jmp    2883 <botlish_fn_17+0x247>
    281b:	mov    rdi,QWORD PTR [rsp+0x50]
    2820:	mov    QWORD PTR [rdi],r14
    2823:	mov    rdx,QWORD PTR [rsp+0x78]
    2828:	mov    rbx,QWORD PTR [rsp+0x90]
    2830:	mov    r12,QWORD PTR [rsp+0x98]
    2838:	mov    r13,QWORD PTR [rsp+0xa0]
    2840:	mov    r14,QWORD PTR [rsp+0xa8]
    2848:	mov    r15,QWORD PTR [rsp+0xb0]
    2850:	add    rsp,0xc0
    2857:	mov    rsp,rbp
    285a:	pop    rbp
    285b:	ret
    285c:	mov    rcx,QWORD PTR [rsp+0x60]
    2861:	mov    rdx,QWORD PTR [rsp+0x58]
    2866:	mov    rsi,QWORD PTR [rsp+0x70]
    286b:	mov    rdi,QWORD PTR [rsp+0x50]
    2870:	call   2875 <botlish_fn_17+0x239>
			2871: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2875:	test   rax,rax
    2878:	jne    28c5 <botlish_fn_17+0x289>
    287e:	mov    rdi,QWORD PTR [rsp+0x50]
    2883:	mov    rdi,QWORD PTR [rsp+0x50]
    2888:	mov    QWORD PTR [rdi],r14
    288b:	xor    rdx,rdx
    288e:	mov    rax,rdx
    2891:	mov    rbx,QWORD PTR [rsp+0x90]
    2899:	mov    r12,QWORD PTR [rsp+0x98]
    28a1:	mov    r13,QWORD PTR [rsp+0xa0]
    28a9:	mov    r14,QWORD PTR [rsp+0xa8]
    28b1:	mov    r15,QWORD PTR [rsp+0xb0]
    28b9:	add    rsp,0xc0
    28c0:	mov    rsp,rbp
    28c3:	pop    rbp
    28c4:	ret
    28c5:	mov    QWORD PTR [rsp],rax
    28c9:	mov    rbx,rax
    28cc:	mov    QWORD PTR [rsp+0x8],0x3
    28d5:	mov    rdx,QWORD PTR [rsp+0x78]
    28da:	test   rdx,0x1
    28e1:	je     2905 <botlish_fn_17+0x2c9>
    28e7:	mov    rdx,QWORD PTR [rsp+0x78]
    28ec:	add    rdx,0x2
    28f0:	seto   al
    28f3:	test   al,al
    28f5:	jne    2905 <botlish_fn_17+0x2c9>
    28fb:	mov    rdi,QWORD PTR [rsp+0x50]
    2900:	jmp    2921 <botlish_fn_17+0x2e5>
    2905:	mov    edx,0x3
    290a:	mov    rsi,QWORD PTR [rsp+0x78]
    290f:	mov    rdi,QWORD PTR [rsp+0x50]
    2914:	call   2919 <botlish_fn_17+0x2dd>
			2915: R_X86_64_PLT32	rt_int_add-0x4
    2919:	mov    rdx,rax
    291c:	mov    rdi,QWORD PTR [rsp+0x50]
    2921:	mov    rdi,QWORD PTR [rsp+0x50]
    2926:	mov    QWORD PTR [rdi],r14
    2929:	mov    rax,rbx
    292c:	mov    rbx,QWORD PTR [rsp+0x90]
    2934:	mov    r12,QWORD PTR [rsp+0x98]
    293c:	mov    r13,QWORD PTR [rsp+0xa0]
    2944:	mov    r14,QWORD PTR [rsp+0xa8]
    294c:	mov    r15,QWORD PTR [rsp+0xb0]
    2954:	add    rsp,0xc0
    295b:	mov    rsp,rbp
    295e:	pop    rbp
    295f:	ret
    2960:	mov    rsi,QWORD PTR [rsp+0x78]
    2965:	mov    edx,0x3
    296a:	mov    rcx,rdx
    296d:	mov    QWORD PTR [rsp+0x20],0x3
    2976:	test   rsi,0x1
    297d:	jne    298b <botlish_fn_17+0x34f>
    2983:	mov    rdx,rcx
    2986:	jmp    29a0 <botlish_fn_17+0x364>
    298b:	mov    rdx,rsi
    298e:	add    rdx,0x2
    2992:	seto   al
    2995:	test   al,al
    2997:	je     29ad <botlish_fn_17+0x371>
    299d:	mov    rdx,rcx
    29a0:	mov    rdi,QWORD PTR [rsp+0x50]
    29a5:	call   29aa <botlish_fn_17+0x36e>
			29a6: R_X86_64_PLT32	rt_int_add-0x4
    29aa:	mov    rdx,rax
    29ad:	mov    QWORD PTR [rsp],r13
    29b1:	mov    QWORD PTR [rsp+0x8],rdx
    29b6:	mov    rsi,QWORD PTR [rsp+0x70]
    29bb:	mov    QWORD PTR [rsp+0x10],rsi
    29c0:	mov    rax,QWORD PTR [rsp+0x58]
    29c5:	mov    QWORD PTR [rsp+0x18],rax
    29ca:	mov    rcx,QWORD PTR [rsp+0x60]
    29cf:	mov    QWORD PTR [rsp+0x20],rcx
    29d4:	mov    rbx,rsi
    29d7:	jmp    26d9 <botlish_fn_17+0x9d>
    29dc:	mov    QWORD PTR [rsp+0x50],rdi
    29e1:	call   29e6 <botlish_fn_17+0x3aa>
			29e2: R_X86_64_PLT32	rt_stack_overflow-0x4
    29e6:	xor    rdx,rdx
    29e9:	mov    rax,rdx
    29ec:	mov    rbx,QWORD PTR [rsp+0x90]
    29f4:	mov    r12,QWORD PTR [rsp+0x98]
    29fc:	mov    r13,QWORD PTR [rsp+0xa0]
    2a04:	mov    r14,QWORD PTR [rsp+0xa8]
    2a0c:	mov    r15,QWORD PTR [rsp+0xb0]
    2a14:	add    rsp,0xc0
    2a1b:	mov    rsp,rbp
    2a1e:	pop    rbp
    2a1f:	ret

0000000000002a20 <botlish_entry_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    2a20:	push   rbp
    2a21:	mov    rbp,rsp
    2a24:	ud2

0000000000002a26 <botlish_fn_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    2a26:	push   rbp
    2a27:	mov    rbp,rsp
    2a2a:	sub    rsp,0xa0
    2a31:	mov    QWORD PTR [rsp+0x70],rbx
    2a36:	mov    QWORD PTR [rsp+0x78],r12
    2a3b:	mov    QWORD PTR [rsp+0x80],r13
    2a43:	mov    QWORD PTR [rsp+0x88],r14
    2a4b:	mov    QWORD PTR [rsp+0x90],r15
    2a53:	mov    rbx,QWORD PTR [rdi]
    2a56:	mov    rax,QWORD PTR [rdi+0x8]
    2a5a:	lea    r10,[rbx+0x8]
    2a5e:	cmp    r10,rax
    2a61:	ja     2c71 <botlish_fn_18+0x24b>
    2a67:	lea    rax,[rbx+0x8]
    2a6b:	mov    QWORD PTR [rdi],rax
    2a6e:	mov    r12,rdi
    2a71:	mov    QWORD PTR [rbx],0x0
    2a78:	mov    QWORD PTR [rsp+0x28],0x0
    2a81:	mov    QWORD PTR [rsp+0x30],0x0
    2a8a:	mov    QWORD PTR [rsp+0x38],0x0
    2a93:	mov    QWORD PTR [rsp],rsi
    2a97:	mov    r13,rsi
    2a9a:	mov    QWORD PTR [rsp+0x8],rdx
    2a9f:	mov    QWORD PTR [rsp+0x60],rdx
    2aa4:	mov    QWORD PTR [rsp+0x10],rcx
    2aa9:	mov    QWORD PTR [rsp+0x68],rcx
    2aae:	mov    QWORD PTR [rsp+0x18],r8
    2ab3:	mov    r15,r8
    2ab6:	mov    QWORD PTR [rsp+0x20],r9
    2abb:	mov    r14,r9
    2abe:	mov    rsi,r13
    2ac1:	mov    rdi,r12
    2ac4:	call   2ac9 <botlish_fn_18+0xa3>
			2ac5: R_X86_64_PLT32	rt_str_len-0x4
    2ac9:	mov    rdx,QWORD PTR [rsp+0x60]
    2ace:	mov    rcx,rdx
    2ad1:	sar    rcx,1
    2ad4:	sar    rax,1
    2ad7:	cmp    rcx,rax
    2ada:	jge    2be7 <botlish_fn_18+0x1c1>
    2ae0:	lea    rsi,[rsp+0x40]
    2ae5:	mov    rdi,r12
    2ae8:	call   2aed <botlish_fn_18+0xc7>
			2ae9: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    2aed:	test   rax,rax
    2af0:	jne    2afe <botlish_fn_18+0xd8>
    2af6:	mov    rdi,r12
    2af9:	jmp    2c06 <botlish_fn_18+0x1e0>
    2afe:	mov    QWORD PTR [rsp+0x28],rax
    2b03:	mov    rcx,rax
    2b06:	mov    r8,QWORD PTR [rsp+0x40]
    2b0b:	mov    QWORD PTR [rsp+0x30],r8
    2b10:	mov    r9,QWORD PTR [rsp+0x48]
    2b15:	mov    QWORD PTR [rsp+0x38],r9
    2b1a:	mov    rdx,QWORD PTR [rsp+0x60]
    2b1f:	mov    rsi,r13
    2b22:	mov    rdi,r12
    2b25:	call   2b2a <botlish_fn_18+0x104>
			2b26: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    2b2a:	test   rax,rax
    2b2d:	jne    2b3b <botlish_fn_18+0x115>
    2b33:	mov    rdi,r12
    2b36:	jmp    2c06 <botlish_fn_18+0x1e0>
    2b3b:	mov    QWORD PTR [rsp+0x8],rax
    2b40:	mov    r8,rax
    2b43:	mov    QWORD PTR [rsp+0x28],rdx
    2b48:	mov    QWORD PTR [rsp+0x60],rdx
    2b4d:	lea    r9,[rsp+0x50]
    2b52:	mov    rcx,r14
    2b55:	mov    rdx,r15
    2b58:	mov    rsi,QWORD PTR [rsp+0x68]
    2b5d:	mov    rdi,r12
    2b60:	call   2b65 <botlish_fn_18+0x13f>
			2b61: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[list<never>, mutarray, int], list>
    2b65:	test   rax,rax
    2b68:	jne    2b76 <botlish_fn_18+0x150>
    2b6e:	mov    rdi,r12
    2b71:	jmp    2c06 <botlish_fn_18+0x1e0>
    2b76:	mov    QWORD PTR [rsp+0x8],rax
    2b7b:	mov    rcx,rax
    2b7e:	mov    r8,QWORD PTR [rsp+0x50]
    2b83:	mov    QWORD PTR [rsp+0x10],r8
    2b88:	mov    r9,QWORD PTR [rsp+0x58]
    2b8d:	mov    QWORD PTR [rsp+0x18],r9
    2b92:	mov    rdx,QWORD PTR [rsp+0x60]
    2b97:	mov    rsi,r13
    2b9a:	mov    rdi,r12
    2b9d:	call   2ba2 <botlish_fn_18+0x17c>
			2b9e: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    2ba2:	test   rax,rax
    2ba5:	jne    2bb3 <botlish_fn_18+0x18d>
    2bab:	mov    rdi,r12
    2bae:	jmp    2c06 <botlish_fn_18+0x1e0>
    2bb3:	mov    rdi,r12
    2bb6:	mov    QWORD PTR [rdi],rbx
    2bb9:	mov    rbx,QWORD PTR [rsp+0x70]
    2bbe:	mov    r12,QWORD PTR [rsp+0x78]
    2bc3:	mov    r13,QWORD PTR [rsp+0x80]
    2bcb:	mov    r14,QWORD PTR [rsp+0x88]
    2bd3:	mov    r15,QWORD PTR [rsp+0x90]
    2bdb:	add    rsp,0xa0
    2be2:	mov    rsp,rbp
    2be5:	pop    rbp
    2be6:	ret
    2be7:	mov    rcx,r14
    2bea:	mov    rdx,r15
    2bed:	mov    rsi,QWORD PTR [rsp+0x68]
    2bf2:	mov    rdi,r12
    2bf5:	call   2bfa <botlish_fn_18+0x1d4>
			2bf6: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    2bfa:	test   rax,rax
    2bfd:	jne    2c3d <botlish_fn_18+0x217>
    2c03:	mov    rdi,r12
    2c06:	mov    rdi,r12
    2c09:	mov    QWORD PTR [rdi],rbx
    2c0c:	xor    rax,rax
    2c0f:	mov    rbx,QWORD PTR [rsp+0x70]
    2c14:	mov    r12,QWORD PTR [rsp+0x78]
    2c19:	mov    r13,QWORD PTR [rsp+0x80]
    2c21:	mov    r14,QWORD PTR [rsp+0x88]
    2c29:	mov    r15,QWORD PTR [rsp+0x90]
    2c31:	add    rsp,0xa0
    2c38:	mov    rsp,rbp
    2c3b:	pop    rbp
    2c3c:	ret
    2c3d:	mov    rdi,r12
    2c40:	mov    QWORD PTR [rdi],rbx
    2c43:	mov    rbx,QWORD PTR [rsp+0x70]
    2c48:	mov    r12,QWORD PTR [rsp+0x78]
    2c4d:	mov    r13,QWORD PTR [rsp+0x80]
    2c55:	mov    r14,QWORD PTR [rsp+0x88]
    2c5d:	mov    r15,QWORD PTR [rsp+0x90]
    2c65:	add    rsp,0xa0
    2c6c:	mov    rsp,rbp
    2c6f:	pop    rbp
    2c70:	ret
    2c71:	mov    r12,rdi
    2c74:	call   2c79 <botlish_fn_18+0x253>
			2c75: R_X86_64_PLT32	rt_stack_overflow-0x4
    2c79:	xor    rax,rax
    2c7c:	mov    rbx,QWORD PTR [rsp+0x70]
    2c81:	mov    r12,QWORD PTR [rsp+0x78]
    2c86:	mov    r13,QWORD PTR [rsp+0x80]
    2c8e:	mov    r14,QWORD PTR [rsp+0x88]
    2c96:	mov    r15,QWORD PTR [rsp+0x90]
    2c9e:	add    rsp,0xa0
    2ca5:	mov    rsp,rbp
    2ca8:	pop    rbp
    2ca9:	ret

0000000000002caa <botlish_entry_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    2caa:	push   rbp
    2cab:	mov    rbp,rsp
    2cae:	mov    rsi,QWORD PTR [rdx]
    2cb1:	mov    r10,QWORD PTR [rdx+0x8]
    2cb5:	mov    rcx,QWORD PTR [rdx+0x10]
    2cb9:	mov    r8,QWORD PTR [rdx+0x18]
    2cbd:	mov    r9,QWORD PTR [rdx+0x20]
    2cc1:	mov    rdx,r10
    2cc4:	call   2cc9 <botlish_entry_18+0x1f>
			2cc5: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    2cc9:	mov    rsp,rbp
    2ccc:	pop    rbp
    2ccd:	ret
	...

0000000000002cd0 <botlish_fn_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    2cd0:	push   rbp
    2cd1:	mov    rbp,rsp
    2cd4:	sub    rsp,0xb0
    2cdb:	mov    QWORD PTR [rsp+0x80],rbx
    2ce3:	mov    QWORD PTR [rsp+0x88],r12
    2ceb:	mov    QWORD PTR [rsp+0x90],r13
    2cf3:	mov    QWORD PTR [rsp+0x98],r14
    2cfb:	mov    QWORD PTR [rsp+0xa0],r15
    2d03:	mov    r14,QWORD PTR [rdi]
    2d06:	mov    rax,QWORD PTR [rdi+0x8]
    2d0a:	lea    r10,[r14+0x8]
    2d0e:	cmp    r10,rax
    2d11:	ja     2f57 <botlish_fn_19+0x287>
    2d17:	lea    rax,[r14+0x8]
    2d1b:	mov    QWORD PTR [rdi],rax
    2d1e:	mov    QWORD PTR [rsp+0x60],rdi
    2d23:	mov    QWORD PTR [r14],0x0
    2d2a:	mov    QWORD PTR [rsp+0x28],0x0
    2d33:	mov    QWORD PTR [rsp+0x30],0x0
    2d3c:	mov    QWORD PTR [rsp+0x38],0x0
    2d45:	mov    QWORD PTR [rsp],rsi
    2d49:	mov    QWORD PTR [rsp+0x8],rdx
    2d4e:	mov    r15,rdx
    2d51:	mov    QWORD PTR [rsp+0x10],rcx
    2d56:	mov    QWORD PTR [rsp+0x18],r8
    2d5b:	mov    QWORD PTR [rsp+0x20],r9
    2d60:	lea    rbx,[rsp+0x40]
    2d65:	lea    r12,[rsp+0x50]
    2d6a:	mov    r13,rsi
    2d6d:	mov    QWORD PTR [rsp+0x68],rcx
    2d72:	mov    QWORD PTR [rsp+0x70],r8
    2d77:	mov    QWORD PTR [rsp+0x78],r9
    2d7c:	mov    rsi,r13
    2d7f:	mov    rdi,QWORD PTR [rsp+0x60]
    2d84:	call   2d89 <botlish_fn_19+0xb9>
			2d85: R_X86_64_PLT32	rt_str_len-0x4
    2d89:	mov    rcx,r15
    2d8c:	and    rcx,rax
    2d8f:	mov    rdx,rax
    2d92:	test   rcx,0x1
    2d99:	jne    2dc1 <botlish_fn_19+0xf1>
    2d9f:	mov    rsi,r15
    2da2:	mov    rdi,QWORD PTR [rsp+0x60]
    2da7:	call   2dac <botlish_fn_19+0xdc>
			2da8: R_X86_64_PLT32	rt_int_cmp-0x4
    2dac:	mov    ecx,0x2
    2db1:	test   rax,rax
    2db4:	cmovge rcx,QWORD PTR [rip+0x1dc]        # 2f98 <botlish_fn_19+0x2c8>
    2dbc:	jmp    2dd4 <botlish_fn_19+0x104>
    2dc1:	mov    ecx,0x2
    2dc6:	mov    rax,r15
    2dc9:	cmp    rax,rdx
    2dcc:	cmovge rcx,QWORD PTR [rip+0x1c4]        # 2f98 <botlish_fn_19+0x2c8>
    2dd4:	cmp    rcx,0x6
    2dd8:	je     2eb5 <botlish_fn_19+0x1e5>
    2dde:	mov    rsi,rbx
    2de1:	mov    rdi,QWORD PTR [rsp+0x60]
    2de6:	call   2deb <botlish_fn_19+0x11b>
			2de7: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    2deb:	test   rax,rax
    2dee:	jne    2dfe <botlish_fn_19+0x12e>
    2df4:	mov    rdi,QWORD PTR [rsp+0x60]
    2df9:	jmp    2edc <botlish_fn_19+0x20c>
    2dfe:	mov    QWORD PTR [rsp+0x28],rax
    2e03:	mov    rcx,rax
    2e06:	mov    r8,QWORD PTR [rsp+0x40]
    2e0b:	mov    QWORD PTR [rsp+0x30],r8
    2e10:	mov    r9,QWORD PTR [rsp+0x48]
    2e15:	mov    QWORD PTR [rsp+0x38],r9
    2e1a:	mov    rdx,r15
    2e1d:	mov    rsi,r13
    2e20:	mov    rdi,QWORD PTR [rsp+0x60]
    2e25:	call   2e2a <botlish_fn_19+0x15a>
			2e26: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    2e2a:	test   rax,rax
    2e2d:	jne    2e3d <botlish_fn_19+0x16d>
    2e33:	mov    rdi,QWORD PTR [rsp+0x60]
    2e38:	jmp    2edc <botlish_fn_19+0x20c>
    2e3d:	mov    QWORD PTR [rsp+0x8],rax
    2e42:	mov    r8,rax
    2e45:	mov    QWORD PTR [rsp+0x28],rdx
    2e4a:	mov    r15,rdx
    2e4d:	mov    rsi,QWORD PTR [rsp+0x68]
    2e52:	mov    rdx,QWORD PTR [rsp+0x70]
    2e57:	mov    rcx,QWORD PTR [rsp+0x78]
    2e5c:	mov    rdi,QWORD PTR [rsp+0x60]
    2e61:	mov    r9,r12
    2e64:	call   2e69 <botlish_fn_19+0x199>
			2e65: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], list>
    2e69:	test   rax,rax
    2e6c:	jne    2e7c <botlish_fn_19+0x1ac>
    2e72:	mov    rdi,QWORD PTR [rsp+0x60]
    2e77:	jmp    2edc <botlish_fn_19+0x20c>
    2e7c:	mov    rdx,QWORD PTR [rsp+0x50]
    2e81:	mov    rcx,QWORD PTR [rsp+0x58]
    2e86:	mov    QWORD PTR [rsp],r13
    2e8a:	mov    rsi,r15
    2e8d:	mov    QWORD PTR [rsp+0x8],rsi
    2e92:	mov    QWORD PTR [rsp+0x10],rax
    2e97:	mov    QWORD PTR [rsp+0x18],rdx
    2e9c:	mov    QWORD PTR [rsp+0x20],rcx
    2ea1:	mov    QWORD PTR [rsp+0x68],rax
    2ea6:	mov    QWORD PTR [rsp+0x70],rdx
    2eab:	mov    QWORD PTR [rsp+0x78],rcx
    2eb0:	jmp    2d7c <botlish_fn_19+0xac>
    2eb5:	mov    rcx,QWORD PTR [rsp+0x78]
    2eba:	mov    rdx,QWORD PTR [rsp+0x70]
    2ebf:	mov    rsi,QWORD PTR [rsp+0x68]
    2ec4:	mov    rdi,QWORD PTR [rsp+0x60]
    2ec9:	call   2ece <botlish_fn_19+0x1fe>
			2eca: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2ece:	test   rax,rax
    2ed1:	jne    2f1b <botlish_fn_19+0x24b>
    2ed7:	mov    rdi,QWORD PTR [rsp+0x60]
    2edc:	mov    rdi,QWORD PTR [rsp+0x60]
    2ee1:	mov    QWORD PTR [rdi],r14
    2ee4:	xor    rax,rax
    2ee7:	mov    rbx,QWORD PTR [rsp+0x80]
    2eef:	mov    r12,QWORD PTR [rsp+0x88]
    2ef7:	mov    r13,QWORD PTR [rsp+0x90]
    2eff:	mov    r14,QWORD PTR [rsp+0x98]
    2f07:	mov    r15,QWORD PTR [rsp+0xa0]
    2f0f:	add    rsp,0xb0
    2f16:	mov    rsp,rbp
    2f19:	pop    rbp
    2f1a:	ret
    2f1b:	mov    rdi,QWORD PTR [rsp+0x60]
    2f20:	mov    QWORD PTR [rdi],r14
    2f23:	mov    rbx,QWORD PTR [rsp+0x80]
    2f2b:	mov    r12,QWORD PTR [rsp+0x88]
    2f33:	mov    r13,QWORD PTR [rsp+0x90]
    2f3b:	mov    r14,QWORD PTR [rsp+0x98]
    2f43:	mov    r15,QWORD PTR [rsp+0xa0]
    2f4b:	add    rsp,0xb0
    2f52:	mov    rsp,rbp
    2f55:	pop    rbp
    2f56:	ret
    2f57:	mov    QWORD PTR [rsp+0x60],rdi
    2f5c:	call   2f61 <botlish_fn_19+0x291>
			2f5d: R_X86_64_PLT32	rt_stack_overflow-0x4
    2f61:	xor    rax,rax
    2f64:	mov    rbx,QWORD PTR [rsp+0x80]
    2f6c:	mov    r12,QWORD PTR [rsp+0x88]
    2f74:	mov    r13,QWORD PTR [rsp+0x90]
    2f7c:	mov    r14,QWORD PTR [rsp+0x98]
    2f84:	mov    r15,QWORD PTR [rsp+0xa0]
    2f8c:	add    rsp,0xb0
    2f93:	mov    rsp,rbp
    2f96:	pop    rbp
    2f97:	ret
    2f98:	(bad)
    2f99:	add    BYTE PTR [rax],al
    2f9b:	add    BYTE PTR [rax],al
    2f9d:	add    BYTE PTR [rax],al
	...

0000000000002fa0 <botlish_entry_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    2fa0:	push   rbp
    2fa1:	mov    rbp,rsp
    2fa4:	mov    rsi,QWORD PTR [rdx]
    2fa7:	mov    r10,QWORD PTR [rdx+0x8]
    2fab:	mov    rcx,QWORD PTR [rdx+0x10]
    2faf:	mov    r8,QWORD PTR [rdx+0x18]
    2fb3:	mov    r9,QWORD PTR [rdx+0x20]
    2fb7:	mov    rdx,r10
    2fba:	call   2fbf <botlish_entry_19+0x1f>
			2fbb: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    2fbf:	mov    rsp,rbp
    2fc2:	pop    rbp
    2fc3:	ret

0000000000002fc4 <botlish_fn_20: csv_parse<str>>:
    2fc4:	push   rbp
    2fc5:	mov    rbp,rsp
    2fc8:	sub    rsp,0x60
    2fcc:	mov    QWORD PTR [rsp+0x40],rbx
    2fd1:	mov    QWORD PTR [rsp+0x48],r12
    2fd6:	mov    QWORD PTR [rsp+0x50],r13
    2fdb:	mov    rbx,QWORD PTR [rdi]
    2fde:	mov    rax,QWORD PTR [rdi+0x8]
    2fe2:	lea    rcx,[rbx+0x8]
    2fe6:	cmp    rcx,rax
    2fe9:	ja     30c0 <botlish_fn_20+0xfc>
    2fef:	lea    rax,[rbx+0x8]
    2ff3:	mov    QWORD PTR [rdi],rax
    2ff6:	mov    r12,rdi
    2ff9:	mov    QWORD PTR [rbx],0x0
    3000:	mov    QWORD PTR [rsp+0x10],0x0
    3009:	mov    QWORD PTR [rsp+0x18],0x0
    3012:	mov    QWORD PTR [rsp+0x20],0x0
    301b:	mov    QWORD PTR [rsp],rsi
    301f:	mov    r13,rsi
    3022:	mov    QWORD PTR [rsp+0x8],0x1
    302b:	lea    rsi,[rsp+0x28]
    3030:	mov    rdi,r12
    3033:	call   3038 <botlish_fn_20+0x74>
			3034: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    3038:	test   rax,rax
    303b:	jne    3049 <botlish_fn_20+0x85>
    3041:	mov    rdi,r12
    3044:	jmp    3081 <botlish_fn_20+0xbd>
    3049:	mov    QWORD PTR [rsp+0x10],rax
    304e:	mov    rcx,rax
    3051:	mov    r8,QWORD PTR [rsp+0x28]
    3056:	mov    QWORD PTR [rsp+0x18],r8
    305b:	mov    r9,QWORD PTR [rsp+0x30]
    3060:	mov    QWORD PTR [rsp+0x20],r9
    3065:	mov    edx,0x1
    306a:	mov    rsi,r13
    306d:	mov    rdi,r12
    3070:	call   3075 <botlish_fn_20+0xb1>
			3071: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    3075:	test   rax,rax
    3078:	jne    30a2 <botlish_fn_20+0xde>
    307e:	mov    rdi,r12
    3081:	mov    rdi,r12
    3084:	mov    QWORD PTR [rdi],rbx
    3087:	xor    rax,rax
    308a:	mov    rbx,QWORD PTR [rsp+0x40]
    308f:	mov    r12,QWORD PTR [rsp+0x48]
    3094:	mov    r13,QWORD PTR [rsp+0x50]
    3099:	add    rsp,0x60
    309d:	mov    rsp,rbp
    30a0:	pop    rbp
    30a1:	ret
    30a2:	mov    rdi,r12
    30a5:	mov    QWORD PTR [rdi],rbx
    30a8:	mov    rbx,QWORD PTR [rsp+0x40]
    30ad:	mov    r12,QWORD PTR [rsp+0x48]
    30b2:	mov    r13,QWORD PTR [rsp+0x50]
    30b7:	add    rsp,0x60
    30bb:	mov    rsp,rbp
    30be:	pop    rbp
    30bf:	ret
    30c0:	mov    r12,rdi
    30c3:	call   30c8 <botlish_fn_20+0x104>
			30c4: R_X86_64_PLT32	rt_stack_overflow-0x4
    30c8:	xor    rax,rax
    30cb:	mov    rbx,QWORD PTR [rsp+0x40]
    30d0:	mov    r12,QWORD PTR [rsp+0x48]
    30d5:	mov    r13,QWORD PTR [rsp+0x50]
    30da:	add    rsp,0x60
    30de:	mov    rsp,rbp
    30e1:	pop    rbp
    30e2:	ret

00000000000030e3 <botlish_entry_20: csv_parse<str>>:
    30e3:	push   rbp
    30e4:	mov    rbp,rsp
    30e7:	mov    rsi,QWORD PTR [rdx]
    30ea:	call   30ef <botlish_entry_20+0xc>
			30eb: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    30ef:	mov    rsp,rbp
    30f2:	pop    rbp
    30f3:	ret

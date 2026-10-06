; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10470  (per function: 312 195 534 534 534 534 498 418 540 540 365 438 585 1141 352 799 833 525 596 197)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> chunked_new<generic>
;   botlish_fn_2 / botlish_entry_2 -> chunked_append<list[List[never], mutarray, int], str>
;   botlish_fn_3 / botlish_entry_3 -> chunked_append<list[List[mutarray], mutarray, int], str>
;   botlish_fn_4 / botlish_entry_4 -> chunked_append<list[List[never], mutarray, int], list>
;   botlish_fn_5 / botlish_entry_5 -> chunked_append<list[List[mutarray], mutarray, int], list>
;   botlish_fn_6 / botlish_entry_6 -> chunked_copy_chunks<List[never], int, mutarray, int>
;   botlish_fn_7 / botlish_entry_7 -> chunked_copy_chunks<List[mutarray], int, mutarray, int>
;   botlish_fn_8 / botlish_entry_8 -> chunked_finish<list[List[never], mutarray, int]>
;   botlish_fn_9 / botlish_entry_9 -> chunked_finish<list[List[mutarray], mutarray, int]>
;   botlish_fn_10 / botlish_entry_10 -> peek<str, int>
;   botlish_fn_11 / botlish_entry_11 -> peek<str, int>
;   botlish_fn_12 / botlish_entry_12 -> scan_unquoted<str, int, int>
;   botlish_fn_13 / botlish_entry_13 -> scan_quoted<str, int, str>
;   botlish_fn_14 / botlish_entry_14 -> scan_field<str, int>
;   botlish_fn_15 / botlish_entry_15 -> scan_record<str, int, list[List[never], mutarray, int]>
;   botlish_fn_16 / botlish_entry_16 -> scan_record<str, int, list[List[mutarray], mutarray, int]>
;   botlish_fn_17 / botlish_entry_17 -> scan_records<str, int, list[List[never], mutarray, int]>
;   botlish_fn_18 / botlish_entry_18 -> scan_records<str, int, list[List[mutarray], mutarray, int]>
;   botlish_fn_19 / botlish_entry_19 -> csv_parse<str>


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

00000000000000f9 <botlish_fn_1: chunked_new<generic>>:
      f9:	push   rbp
      fa:	mov    rbp,rsp
      fd:	sub    rsp,0x30
     101:	mov    QWORD PTR [rsp+0x10],r12
     106:	mov    QWORD PTR [rsp+0x18],r13
     10b:	mov    QWORD PTR [rsp+0x20],r15
     110:	mov    r12,rsi
     113:	mov    r13,rdi
     116:	mov    QWORD PTR [rsp],0x0
     11e:	mov    QWORD PTR [rsp+0x8],0x0
     127:	xor    rdx,rdx
     12a:	mov    rdi,r13
     12d:	mov    rsi,rdx
     130:	call   135 <botlish_fn_1+0x3c>
			131: R_X86_64_PLT32	rt_list_new-0x4
     135:	test   rax,rax
     138:	je     164 <botlish_fn_1+0x6b>
     13e:	mov    QWORD PTR [rsp],rax
     142:	mov    r15,rax
     145:	mov    esi,0x81
     14a:	mov    QWORD PTR [rsp+0x8],0x81
     153:	mov    rdi,r13
     156:	call   15b <botlish_fn_1+0x62>
			157: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     15b:	test   rax,rax
     15e:	jne    17f <botlish_fn_1+0x86>
     164:	xor    rax,rax
     167:	mov    r12,QWORD PTR [rsp+0x10]
     16c:	mov    r13,QWORD PTR [rsp+0x18]
     171:	mov    r15,QWORD PTR [rsp+0x20]
     176:	add    rsp,0x30
     17a:	mov    rsp,rbp
     17d:	pop    rbp
     17e:	ret
     17f:	mov    rsi,r12
     182:	mov    QWORD PTR [rsi],rax
     185:	mov    QWORD PTR [rsi+0x8],0x1
     18d:	mov    rax,r15
     190:	mov    r12,QWORD PTR [rsp+0x10]
     195:	mov    r13,QWORD PTR [rsp+0x18]
     19a:	mov    r15,QWORD PTR [rsp+0x20]
     19f:	add    rsp,0x30
     1a3:	mov    rsp,rbp
     1a6:	pop    rbp
     1a7:	ret

00000000000001a8 <botlish_entry_1: chunked_new<generic>>:
     1a8:	push   rbp
     1a9:	mov    rbp,rsp
     1ac:	ud2
	...

00000000000001b0 <botlish_fn_2: chunked_append<list[List[never], mutarray, int], str>>:
     1b0:	push   rbp
     1b1:	mov    rbp,rsp
     1b4:	sub    rsp,0x60
     1b8:	mov    QWORD PTR [rsp+0x30],rbx
     1bd:	mov    QWORD PTR [rsp+0x38],r12
     1c2:	mov    QWORD PTR [rsp+0x40],r13
     1c7:	mov    QWORD PTR [rsp+0x48],r14
     1cc:	mov    QWORD PTR [rsp+0x50],r15
     1d1:	mov    rbx,rcx
     1d4:	mov    r12,r9
     1d7:	mov    r15,rdi
     1da:	mov    QWORD PTR [rsp],rsi
     1de:	mov    r13,rsi
     1e1:	mov    QWORD PTR [rsp+0x8],rdx
     1e6:	mov    r14,rdx
     1e9:	mov    QWORD PTR [rsp+0x10],r8
     1ee:	mov    QWORD PTR [rsp+0x20],r8
     1f3:	mov    rcx,rbx
     1f6:	test   rcx,0x1
     1fd:	jne    228 <botlish_fn_2+0x78>
     203:	mov    edx,0x81
     208:	mov    rsi,rbx
     20b:	mov    rdi,r15
     20e:	call   213 <botlish_fn_2+0x63>
			20f: R_X86_64_PLT32	rt_int_cmp-0x4
     213:	mov    ecx,0x2
     218:	test   rax,rax
     21b:	cmove  rcx,QWORD PTR [rip+0x16d]        # 390 <botlish_fn_2+0x1e0>
     223:	jmp    23c <botlish_fn_2+0x8c>
     228:	mov    ecx,0x2
     22d:	cmp    rbx,0x81
     234:	cmove  rcx,QWORD PTR [rip+0x154]        # 390 <botlish_fn_2+0x1e0>
     23c:	cmp    rcx,0x6
     240:	je     2d7 <botlish_fn_2+0x127>
     246:	mov    rcx,QWORD PTR [rsp+0x20]
     24b:	mov    rdx,rbx
     24e:	mov    rsi,r14
     251:	mov    rdi,r15
     254:	call   259 <botlish_fn_2+0xa9>
			255: R_X86_64_PLT32	rt_mutarray_set-0x4
     259:	test   rax,rax
     25c:	je     336 <botlish_fn_2+0x186>
     262:	mov    QWORD PTR [rsp+0x18],0x3
     26b:	test   rbx,0x1
     272:	je     295 <botlish_fn_2+0xe5>
     278:	mov    rax,rbx
     27b:	add    rax,0x2
     27f:	seto   cl
     282:	test   cl,cl
     284:	jne    295 <botlish_fn_2+0xe5>
     28a:	mov    rdx,r14
     28d:	mov    rbx,r12
     290:	jmp    2ab <botlish_fn_2+0xfb>
     295:	mov    edx,0x3
     29a:	mov    rsi,rbx
     29d:	mov    rdi,r15
     2a0:	call   2a5 <botlish_fn_2+0xf5>
			2a1: R_X86_64_PLT32	rt_int_add-0x4
     2a5:	mov    rdx,r14
     2a8:	mov    rbx,r12
     2ab:	mov    QWORD PTR [rbx],rdx
     2ae:	mov    QWORD PTR [rbx+0x8],rax
     2b2:	mov    rax,r13
     2b5:	mov    rbx,QWORD PTR [rsp+0x30]
     2ba:	mov    r12,QWORD PTR [rsp+0x38]
     2bf:	mov    r13,QWORD PTR [rsp+0x40]
     2c4:	mov    r14,QWORD PTR [rsp+0x48]
     2c9:	mov    r15,QWORD PTR [rsp+0x50]
     2ce:	add    rsp,0x60
     2d2:	mov    rsp,rbp
     2d5:	pop    rbp
     2d6:	ret
     2d7:	mov    rbx,r12
     2da:	mov    esi,0x81
     2df:	mov    QWORD PTR [rsp+0x18],0x81
     2e8:	mov    rdi,r15
     2eb:	call   2f0 <botlish_fn_2+0x140>
			2ec: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     2f0:	test   rax,rax
     2f3:	je     336 <botlish_fn_2+0x186>
     2f9:	mov    QWORD PTR [rsp+0x10],rax
     2fe:	mov    r12,rax
     301:	mov    edx,0x1
     306:	mov    rcx,QWORD PTR [rsp+0x20]
     30b:	mov    rsi,r12
     30e:	mov    rdi,r15
     311:	call   316 <botlish_fn_2+0x166>
			312: R_X86_64_PLT32	rt_mutarray_set-0x4
     316:	test   rax,rax
     319:	je     336 <botlish_fn_2+0x186>
     31f:	mov    rdx,r14
     322:	mov    rsi,r13
     325:	mov    rdi,r15
     328:	call   32d <botlish_fn_2+0x17d>
			329: R_X86_64_PLT32	rt_list_append-0x4
     32d:	test   rax,rax
     330:	jne    35b <botlish_fn_2+0x1ab>
     336:	xor    rax,rax
     339:	mov    rbx,QWORD PTR [rsp+0x30]
     33e:	mov    r12,QWORD PTR [rsp+0x38]
     343:	mov    r13,QWORD PTR [rsp+0x40]
     348:	mov    r14,QWORD PTR [rsp+0x48]
     34d:	mov    r15,QWORD PTR [rsp+0x50]
     352:	add    rsp,0x60
     356:	mov    rsp,rbp
     359:	pop    rbp
     35a:	ret
     35b:	mov    rcx,r12
     35e:	mov    QWORD PTR [rbx],rcx
     361:	mov    QWORD PTR [rbx+0x8],0x3
     369:	mov    rbx,QWORD PTR [rsp+0x30]
     36e:	mov    r12,QWORD PTR [rsp+0x38]
     373:	mov    r13,QWORD PTR [rsp+0x40]
     378:	mov    r14,QWORD PTR [rsp+0x48]
     37d:	mov    r15,QWORD PTR [rsp+0x50]
     382:	add    rsp,0x60
     386:	mov    rsp,rbp
     389:	pop    rbp
     38a:	ret
     38b:	add    BYTE PTR [rax],al
     38d:	add    BYTE PTR [rax],al
     38f:	add    BYTE PTR [rsi],al
     391:	add    BYTE PTR [rax],al
     393:	add    BYTE PTR [rax],al
     395:	add    BYTE PTR [rax],al
	...

0000000000000398 <botlish_entry_2: chunked_append<list[List[never], mutarray, int], str>>:
     398:	push   rbp
     399:	mov    rbp,rsp
     39c:	ud2
	...

00000000000003a0 <botlish_fn_3: chunked_append<list[List[mutarray], mutarray, int], str>>:
     3a0:	push   rbp
     3a1:	mov    rbp,rsp
     3a4:	sub    rsp,0x60
     3a8:	mov    QWORD PTR [rsp+0x30],rbx
     3ad:	mov    QWORD PTR [rsp+0x38],r12
     3b2:	mov    QWORD PTR [rsp+0x40],r13
     3b7:	mov    QWORD PTR [rsp+0x48],r14
     3bc:	mov    QWORD PTR [rsp+0x50],r15
     3c1:	mov    rbx,rcx
     3c4:	mov    r12,r9
     3c7:	mov    r15,rdi
     3ca:	mov    QWORD PTR [rsp],rsi
     3ce:	mov    r13,rsi
     3d1:	mov    QWORD PTR [rsp+0x8],rdx
     3d6:	mov    r14,rdx
     3d9:	mov    QWORD PTR [rsp+0x10],r8
     3de:	mov    QWORD PTR [rsp+0x20],r8
     3e3:	mov    rcx,rbx
     3e6:	test   rcx,0x1
     3ed:	jne    418 <botlish_fn_3+0x78>
     3f3:	mov    edx,0x81
     3f8:	mov    rsi,rbx
     3fb:	mov    rdi,r15
     3fe:	call   403 <botlish_fn_3+0x63>
			3ff: R_X86_64_PLT32	rt_int_cmp-0x4
     403:	mov    ecx,0x2
     408:	test   rax,rax
     40b:	cmove  rcx,QWORD PTR [rip+0x16d]        # 580 <botlish_fn_3+0x1e0>
     413:	jmp    42c <botlish_fn_3+0x8c>
     418:	mov    ecx,0x2
     41d:	cmp    rbx,0x81
     424:	cmove  rcx,QWORD PTR [rip+0x154]        # 580 <botlish_fn_3+0x1e0>
     42c:	cmp    rcx,0x6
     430:	je     4c7 <botlish_fn_3+0x127>
     436:	mov    rcx,QWORD PTR [rsp+0x20]
     43b:	mov    rdx,rbx
     43e:	mov    rsi,r14
     441:	mov    rdi,r15
     444:	call   449 <botlish_fn_3+0xa9>
			445: R_X86_64_PLT32	rt_mutarray_set-0x4
     449:	test   rax,rax
     44c:	je     526 <botlish_fn_3+0x186>
     452:	mov    QWORD PTR [rsp+0x18],0x3
     45b:	test   rbx,0x1
     462:	je     485 <botlish_fn_3+0xe5>
     468:	mov    rax,rbx
     46b:	add    rax,0x2
     46f:	seto   cl
     472:	test   cl,cl
     474:	jne    485 <botlish_fn_3+0xe5>
     47a:	mov    rdx,r14
     47d:	mov    rbx,r12
     480:	jmp    49b <botlish_fn_3+0xfb>
     485:	mov    edx,0x3
     48a:	mov    rsi,rbx
     48d:	mov    rdi,r15
     490:	call   495 <botlish_fn_3+0xf5>
			491: R_X86_64_PLT32	rt_int_add-0x4
     495:	mov    rdx,r14
     498:	mov    rbx,r12
     49b:	mov    QWORD PTR [rbx],rdx
     49e:	mov    QWORD PTR [rbx+0x8],rax
     4a2:	mov    rax,r13
     4a5:	mov    rbx,QWORD PTR [rsp+0x30]
     4aa:	mov    r12,QWORD PTR [rsp+0x38]
     4af:	mov    r13,QWORD PTR [rsp+0x40]
     4b4:	mov    r14,QWORD PTR [rsp+0x48]
     4b9:	mov    r15,QWORD PTR [rsp+0x50]
     4be:	add    rsp,0x60
     4c2:	mov    rsp,rbp
     4c5:	pop    rbp
     4c6:	ret
     4c7:	mov    rbx,r12
     4ca:	mov    esi,0x81
     4cf:	mov    QWORD PTR [rsp+0x18],0x81
     4d8:	mov    rdi,r15
     4db:	call   4e0 <botlish_fn_3+0x140>
			4dc: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     4e0:	test   rax,rax
     4e3:	je     526 <botlish_fn_3+0x186>
     4e9:	mov    QWORD PTR [rsp+0x10],rax
     4ee:	mov    r12,rax
     4f1:	mov    edx,0x1
     4f6:	mov    rcx,QWORD PTR [rsp+0x20]
     4fb:	mov    rsi,r12
     4fe:	mov    rdi,r15
     501:	call   506 <botlish_fn_3+0x166>
			502: R_X86_64_PLT32	rt_mutarray_set-0x4
     506:	test   rax,rax
     509:	je     526 <botlish_fn_3+0x186>
     50f:	mov    rdx,r14
     512:	mov    rsi,r13
     515:	mov    rdi,r15
     518:	call   51d <botlish_fn_3+0x17d>
			519: R_X86_64_PLT32	rt_list_append-0x4
     51d:	test   rax,rax
     520:	jne    54b <botlish_fn_3+0x1ab>
     526:	xor    rax,rax
     529:	mov    rbx,QWORD PTR [rsp+0x30]
     52e:	mov    r12,QWORD PTR [rsp+0x38]
     533:	mov    r13,QWORD PTR [rsp+0x40]
     538:	mov    r14,QWORD PTR [rsp+0x48]
     53d:	mov    r15,QWORD PTR [rsp+0x50]
     542:	add    rsp,0x60
     546:	mov    rsp,rbp
     549:	pop    rbp
     54a:	ret
     54b:	mov    rcx,r12
     54e:	mov    QWORD PTR [rbx],rcx
     551:	mov    QWORD PTR [rbx+0x8],0x3
     559:	mov    rbx,QWORD PTR [rsp+0x30]
     55e:	mov    r12,QWORD PTR [rsp+0x38]
     563:	mov    r13,QWORD PTR [rsp+0x40]
     568:	mov    r14,QWORD PTR [rsp+0x48]
     56d:	mov    r15,QWORD PTR [rsp+0x50]
     572:	add    rsp,0x60
     576:	mov    rsp,rbp
     579:	pop    rbp
     57a:	ret
     57b:	add    BYTE PTR [rax],al
     57d:	add    BYTE PTR [rax],al
     57f:	add    BYTE PTR [rsi],al
     581:	add    BYTE PTR [rax],al
     583:	add    BYTE PTR [rax],al
     585:	add    BYTE PTR [rax],al
	...

0000000000000588 <botlish_entry_3: chunked_append<list[List[mutarray], mutarray, int], str>>:
     588:	push   rbp
     589:	mov    rbp,rsp
     58c:	ud2
	...

0000000000000590 <botlish_fn_4: chunked_append<list[List[never], mutarray, int], list>>:
     590:	push   rbp
     591:	mov    rbp,rsp
     594:	sub    rsp,0x60
     598:	mov    QWORD PTR [rsp+0x30],rbx
     59d:	mov    QWORD PTR [rsp+0x38],r12
     5a2:	mov    QWORD PTR [rsp+0x40],r13
     5a7:	mov    QWORD PTR [rsp+0x48],r14
     5ac:	mov    QWORD PTR [rsp+0x50],r15
     5b1:	mov    rbx,rcx
     5b4:	mov    r12,r9
     5b7:	mov    r15,rdi
     5ba:	mov    QWORD PTR [rsp],rsi
     5be:	mov    r13,rsi
     5c1:	mov    QWORD PTR [rsp+0x8],rdx
     5c6:	mov    r14,rdx
     5c9:	mov    QWORD PTR [rsp+0x10],r8
     5ce:	mov    QWORD PTR [rsp+0x20],r8
     5d3:	mov    rcx,rbx
     5d6:	test   rcx,0x1
     5dd:	jne    608 <botlish_fn_4+0x78>
     5e3:	mov    edx,0x81
     5e8:	mov    rsi,rbx
     5eb:	mov    rdi,r15
     5ee:	call   5f3 <botlish_fn_4+0x63>
			5ef: R_X86_64_PLT32	rt_int_cmp-0x4
     5f3:	mov    ecx,0x2
     5f8:	test   rax,rax
     5fb:	cmove  rcx,QWORD PTR [rip+0x16d]        # 770 <botlish_fn_4+0x1e0>
     603:	jmp    61c <botlish_fn_4+0x8c>
     608:	mov    ecx,0x2
     60d:	cmp    rbx,0x81
     614:	cmove  rcx,QWORD PTR [rip+0x154]        # 770 <botlish_fn_4+0x1e0>
     61c:	cmp    rcx,0x6
     620:	je     6b7 <botlish_fn_4+0x127>
     626:	mov    rcx,QWORD PTR [rsp+0x20]
     62b:	mov    rdx,rbx
     62e:	mov    rsi,r14
     631:	mov    rdi,r15
     634:	call   639 <botlish_fn_4+0xa9>
			635: R_X86_64_PLT32	rt_mutarray_set-0x4
     639:	test   rax,rax
     63c:	je     716 <botlish_fn_4+0x186>
     642:	mov    QWORD PTR [rsp+0x18],0x3
     64b:	test   rbx,0x1
     652:	je     675 <botlish_fn_4+0xe5>
     658:	mov    rax,rbx
     65b:	add    rax,0x2
     65f:	seto   cl
     662:	test   cl,cl
     664:	jne    675 <botlish_fn_4+0xe5>
     66a:	mov    rdx,r14
     66d:	mov    rbx,r12
     670:	jmp    68b <botlish_fn_4+0xfb>
     675:	mov    edx,0x3
     67a:	mov    rsi,rbx
     67d:	mov    rdi,r15
     680:	call   685 <botlish_fn_4+0xf5>
			681: R_X86_64_PLT32	rt_int_add-0x4
     685:	mov    rdx,r14
     688:	mov    rbx,r12
     68b:	mov    QWORD PTR [rbx],rdx
     68e:	mov    QWORD PTR [rbx+0x8],rax
     692:	mov    rax,r13
     695:	mov    rbx,QWORD PTR [rsp+0x30]
     69a:	mov    r12,QWORD PTR [rsp+0x38]
     69f:	mov    r13,QWORD PTR [rsp+0x40]
     6a4:	mov    r14,QWORD PTR [rsp+0x48]
     6a9:	mov    r15,QWORD PTR [rsp+0x50]
     6ae:	add    rsp,0x60
     6b2:	mov    rsp,rbp
     6b5:	pop    rbp
     6b6:	ret
     6b7:	mov    rbx,r12
     6ba:	mov    esi,0x81
     6bf:	mov    QWORD PTR [rsp+0x18],0x81
     6c8:	mov    rdi,r15
     6cb:	call   6d0 <botlish_fn_4+0x140>
			6cc: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     6d0:	test   rax,rax
     6d3:	je     716 <botlish_fn_4+0x186>
     6d9:	mov    QWORD PTR [rsp+0x10],rax
     6de:	mov    r12,rax
     6e1:	mov    edx,0x1
     6e6:	mov    rcx,QWORD PTR [rsp+0x20]
     6eb:	mov    rsi,r12
     6ee:	mov    rdi,r15
     6f1:	call   6f6 <botlish_fn_4+0x166>
			6f2: R_X86_64_PLT32	rt_mutarray_set-0x4
     6f6:	test   rax,rax
     6f9:	je     716 <botlish_fn_4+0x186>
     6ff:	mov    rdx,r14
     702:	mov    rsi,r13
     705:	mov    rdi,r15
     708:	call   70d <botlish_fn_4+0x17d>
			709: R_X86_64_PLT32	rt_list_append-0x4
     70d:	test   rax,rax
     710:	jne    73b <botlish_fn_4+0x1ab>
     716:	xor    rax,rax
     719:	mov    rbx,QWORD PTR [rsp+0x30]
     71e:	mov    r12,QWORD PTR [rsp+0x38]
     723:	mov    r13,QWORD PTR [rsp+0x40]
     728:	mov    r14,QWORD PTR [rsp+0x48]
     72d:	mov    r15,QWORD PTR [rsp+0x50]
     732:	add    rsp,0x60
     736:	mov    rsp,rbp
     739:	pop    rbp
     73a:	ret
     73b:	mov    rcx,r12
     73e:	mov    QWORD PTR [rbx],rcx
     741:	mov    QWORD PTR [rbx+0x8],0x3
     749:	mov    rbx,QWORD PTR [rsp+0x30]
     74e:	mov    r12,QWORD PTR [rsp+0x38]
     753:	mov    r13,QWORD PTR [rsp+0x40]
     758:	mov    r14,QWORD PTR [rsp+0x48]
     75d:	mov    r15,QWORD PTR [rsp+0x50]
     762:	add    rsp,0x60
     766:	mov    rsp,rbp
     769:	pop    rbp
     76a:	ret
     76b:	add    BYTE PTR [rax],al
     76d:	add    BYTE PTR [rax],al
     76f:	add    BYTE PTR [rsi],al
     771:	add    BYTE PTR [rax],al
     773:	add    BYTE PTR [rax],al
     775:	add    BYTE PTR [rax],al
	...

0000000000000778 <botlish_entry_4: chunked_append<list[List[never], mutarray, int], list>>:
     778:	push   rbp
     779:	mov    rbp,rsp
     77c:	ud2
	...

0000000000000780 <botlish_fn_5: chunked_append<list[List[mutarray], mutarray, int], list>>:
     780:	push   rbp
     781:	mov    rbp,rsp
     784:	sub    rsp,0x60
     788:	mov    QWORD PTR [rsp+0x30],rbx
     78d:	mov    QWORD PTR [rsp+0x38],r12
     792:	mov    QWORD PTR [rsp+0x40],r13
     797:	mov    QWORD PTR [rsp+0x48],r14
     79c:	mov    QWORD PTR [rsp+0x50],r15
     7a1:	mov    rbx,rcx
     7a4:	mov    r12,r9
     7a7:	mov    r15,rdi
     7aa:	mov    QWORD PTR [rsp],rsi
     7ae:	mov    r13,rsi
     7b1:	mov    QWORD PTR [rsp+0x8],rdx
     7b6:	mov    r14,rdx
     7b9:	mov    QWORD PTR [rsp+0x10],r8
     7be:	mov    QWORD PTR [rsp+0x20],r8
     7c3:	mov    rcx,rbx
     7c6:	test   rcx,0x1
     7cd:	jne    7f8 <botlish_fn_5+0x78>
     7d3:	mov    edx,0x81
     7d8:	mov    rsi,rbx
     7db:	mov    rdi,r15
     7de:	call   7e3 <botlish_fn_5+0x63>
			7df: R_X86_64_PLT32	rt_int_cmp-0x4
     7e3:	mov    ecx,0x2
     7e8:	test   rax,rax
     7eb:	cmove  rcx,QWORD PTR [rip+0x16d]        # 960 <botlish_fn_5+0x1e0>
     7f3:	jmp    80c <botlish_fn_5+0x8c>
     7f8:	mov    ecx,0x2
     7fd:	cmp    rbx,0x81
     804:	cmove  rcx,QWORD PTR [rip+0x154]        # 960 <botlish_fn_5+0x1e0>
     80c:	cmp    rcx,0x6
     810:	je     8a7 <botlish_fn_5+0x127>
     816:	mov    rcx,QWORD PTR [rsp+0x20]
     81b:	mov    rdx,rbx
     81e:	mov    rsi,r14
     821:	mov    rdi,r15
     824:	call   829 <botlish_fn_5+0xa9>
			825: R_X86_64_PLT32	rt_mutarray_set-0x4
     829:	test   rax,rax
     82c:	je     906 <botlish_fn_5+0x186>
     832:	mov    QWORD PTR [rsp+0x18],0x3
     83b:	test   rbx,0x1
     842:	je     865 <botlish_fn_5+0xe5>
     848:	mov    rax,rbx
     84b:	add    rax,0x2
     84f:	seto   cl
     852:	test   cl,cl
     854:	jne    865 <botlish_fn_5+0xe5>
     85a:	mov    rdx,r14
     85d:	mov    rbx,r12
     860:	jmp    87b <botlish_fn_5+0xfb>
     865:	mov    edx,0x3
     86a:	mov    rsi,rbx
     86d:	mov    rdi,r15
     870:	call   875 <botlish_fn_5+0xf5>
			871: R_X86_64_PLT32	rt_int_add-0x4
     875:	mov    rdx,r14
     878:	mov    rbx,r12
     87b:	mov    QWORD PTR [rbx],rdx
     87e:	mov    QWORD PTR [rbx+0x8],rax
     882:	mov    rax,r13
     885:	mov    rbx,QWORD PTR [rsp+0x30]
     88a:	mov    r12,QWORD PTR [rsp+0x38]
     88f:	mov    r13,QWORD PTR [rsp+0x40]
     894:	mov    r14,QWORD PTR [rsp+0x48]
     899:	mov    r15,QWORD PTR [rsp+0x50]
     89e:	add    rsp,0x60
     8a2:	mov    rsp,rbp
     8a5:	pop    rbp
     8a6:	ret
     8a7:	mov    rbx,r12
     8aa:	mov    esi,0x81
     8af:	mov    QWORD PTR [rsp+0x18],0x81
     8b8:	mov    rdi,r15
     8bb:	call   8c0 <botlish_fn_5+0x140>
			8bc: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     8c0:	test   rax,rax
     8c3:	je     906 <botlish_fn_5+0x186>
     8c9:	mov    QWORD PTR [rsp+0x10],rax
     8ce:	mov    r12,rax
     8d1:	mov    edx,0x1
     8d6:	mov    rcx,QWORD PTR [rsp+0x20]
     8db:	mov    rsi,r12
     8de:	mov    rdi,r15
     8e1:	call   8e6 <botlish_fn_5+0x166>
			8e2: R_X86_64_PLT32	rt_mutarray_set-0x4
     8e6:	test   rax,rax
     8e9:	je     906 <botlish_fn_5+0x186>
     8ef:	mov    rdx,r14
     8f2:	mov    rsi,r13
     8f5:	mov    rdi,r15
     8f8:	call   8fd <botlish_fn_5+0x17d>
			8f9: R_X86_64_PLT32	rt_list_append-0x4
     8fd:	test   rax,rax
     900:	jne    92b <botlish_fn_5+0x1ab>
     906:	xor    rax,rax
     909:	mov    rbx,QWORD PTR [rsp+0x30]
     90e:	mov    r12,QWORD PTR [rsp+0x38]
     913:	mov    r13,QWORD PTR [rsp+0x40]
     918:	mov    r14,QWORD PTR [rsp+0x48]
     91d:	mov    r15,QWORD PTR [rsp+0x50]
     922:	add    rsp,0x60
     926:	mov    rsp,rbp
     929:	pop    rbp
     92a:	ret
     92b:	mov    rcx,r12
     92e:	mov    QWORD PTR [rbx],rcx
     931:	mov    QWORD PTR [rbx+0x8],0x3
     939:	mov    rbx,QWORD PTR [rsp+0x30]
     93e:	mov    r12,QWORD PTR [rsp+0x38]
     943:	mov    r13,QWORD PTR [rsp+0x40]
     948:	mov    r14,QWORD PTR [rsp+0x48]
     94d:	mov    r15,QWORD PTR [rsp+0x50]
     952:	add    rsp,0x60
     956:	mov    rsp,rbp
     959:	pop    rbp
     95a:	ret
     95b:	add    BYTE PTR [rax],al
     95d:	add    BYTE PTR [rax],al
     95f:	add    BYTE PTR [rsi],al
     961:	add    BYTE PTR [rax],al
     963:	add    BYTE PTR [rax],al
     965:	add    BYTE PTR [rax],al
	...

0000000000000968 <botlish_entry_5: chunked_append<list[List[mutarray], mutarray, int], list>>:
     968:	push   rbp
     969:	mov    rbp,rsp
     96c:	ud2

000000000000096e <botlish_fn_6: chunked_copy_chunks<List[never], int, mutarray, int>>:
     96e:	push   rbp
     96f:	mov    rbp,rsp
     972:	sub    rsp,0x50
     976:	mov    QWORD PTR [rsp+0x20],rbx
     97b:	mov    QWORD PTR [rsp+0x28],r12
     980:	mov    QWORD PTR [rsp+0x30],r13
     985:	mov    QWORD PTR [rsp+0x38],r14
     98a:	mov    QWORD PTR [rsp+0x40],r15
     98f:	mov    r14,rdi
     992:	mov    QWORD PTR [rsp],rsi
     996:	mov    QWORD PTR [rsp+0x8],rcx
     99b:	mov    r12,rcx
     99e:	mov    QWORD PTR [rsp+0x10],r8
     9a3:	sar    rdx,1
     9a6:	mov    rbx,rdx
     9a9:	mov    r13,rsi
     9ac:	mov    r15,r8
     9af:	mov    rsi,r13
     9b2:	mov    rdi,r14
     9b5:	call   9ba <botlish_fn_6+0x4c>
			9b6: R_X86_64_PLT32	rt_list_len-0x4
     9ba:	sar    rax,1
     9bd:	cmp    rbx,rax
     9c0:	jge    af5 <botlish_fn_6+0x187>
     9c6:	mov    rcx,QWORD PTR [r13+0x8]
     9ca:	mov    rax,rbx
     9cd:	shl    rax,1
     9d0:	or     rax,0x1
     9d4:	sar    rax,1
     9d7:	cmp    rax,rcx
     9da:	jb     a06 <botlish_fn_6+0x98>
     9e0:	mov    rdx,rbx
     9e3:	shl    rdx,1
     9e6:	or     rdx,0x1
     9ea:	mov    rsi,r13
     9ed:	mov    rdi,r14
     9f0:	call   9f5 <botlish_fn_6+0x87>
			9f1: R_X86_64_PLT32	rt_list_get-0x4
     9f5:	test   rax,rax
     9f8:	je     a71 <botlish_fn_6+0x103>
     9fe:	mov    rsi,rax
     a01:	jmp    a11 <botlish_fn_6+0xa3>
     a06:	mov    rcx,QWORD PTR [r13+0x10]
     a0a:	mov    rax,QWORD PTR [rcx+rax*8]
     a0e:	mov    rsi,rax
     a11:	xor    eax,eax
     a13:	test   rsi,0x7
     a1a:	jne    a29 <botlish_fn_6+0xbb>
     a20:	movzx  rax,BYTE PTR [rsi]
     a24:	cmp    al,0x8
     a26:	sete   al
     a29:	test   al,al
     a2b:	jne    a4b <botlish_fn_6+0xdd>
     a31:	mov    rdi,r14
     a34:	mov    rax,QWORD PTR [rdi+0x10]
     a38:	mov    rcx,QWORD PTR [rax+0x8]
     a3c:	mov    edx,0x8
     a41:	call   a46 <botlish_fn_6+0xd8>
			a42: R_X86_64_PLT32	rt_type_error-0x4
     a46:	jmp    a71 <botlish_fn_6+0x103>
     a4b:	mov    rcx,rsi
     a4e:	mov    r8d,0x1
     a54:	mov    r9d,0x81
     a5a:	mov    rdx,r15
     a5d:	mov    rsi,r12
     a60:	mov    rdi,r14
     a63:	call   a68 <botlish_fn_6+0xfa>
			a64: R_X86_64_PLT32	rt_mutarray_copy-0x4
     a68:	test   rax,rax
     a6b:	jne    a96 <botlish_fn_6+0x128>
     a71:	xor    rax,rax
     a74:	mov    rbx,QWORD PTR [rsp+0x20]
     a79:	mov    r12,QWORD PTR [rsp+0x28]
     a7e:	mov    r13,QWORD PTR [rsp+0x30]
     a83:	mov    r14,QWORD PTR [rsp+0x38]
     a88:	mov    r15,QWORD PTR [rsp+0x40]
     a8d:	add    rsp,0x50
     a91:	mov    rsp,rbp
     a94:	pop    rbp
     a95:	ret
     a96:	mov    QWORD PTR [rsp+0x18],0x81
     a9f:	mov    rsi,r15
     aa2:	test   rsi,0x1
     aa9:	je     ac8 <botlish_fn_6+0x15a>
     aaf:	mov    rsi,r15
     ab2:	mov    rax,rsi
     ab5:	add    rax,0x80
     abb:	seto   r9b
     abf:	test   r9b,r9b
     ac2:	je     ad8 <botlish_fn_6+0x16a>
     ac8:	mov    edx,0x81
     acd:	mov    rsi,r15
     ad0:	mov    rdi,r14
     ad3:	call   ad8 <botlish_fn_6+0x16a>
			ad4: R_X86_64_PLT32	rt_int_add-0x4
     ad8:	mov    QWORD PTR [rsp],r13
     adc:	mov    QWORD PTR [rsp+0x8],r12
     ae1:	mov    QWORD PTR [rsp+0x10],rax
     ae6:	add    rbx,0x1
     aed:	mov    r15,rax
     af0:	jmp    9af <botlish_fn_6+0x41>
     af5:	mov    rax,r15
     af8:	mov    rbx,QWORD PTR [rsp+0x20]
     afd:	mov    r12,QWORD PTR [rsp+0x28]
     b02:	mov    r13,QWORD PTR [rsp+0x30]
     b07:	mov    r14,QWORD PTR [rsp+0x38]
     b0c:	mov    r15,QWORD PTR [rsp+0x40]
     b11:	add    rsp,0x50
     b15:	mov    rsp,rbp
     b18:	pop    rbp
     b19:	ret

0000000000000b1a <botlish_entry_6: chunked_copy_chunks<List[never], int, mutarray, int>>:
     b1a:	push   rbp
     b1b:	mov    rbp,rsp
     b1e:	mov    rsi,QWORD PTR [rdx]
     b21:	mov    r9,QWORD PTR [rdx+0x8]
     b25:	mov    rcx,QWORD PTR [rdx+0x10]
     b29:	mov    r8,QWORD PTR [rdx+0x18]
     b2d:	mov    rdx,r9
     b30:	call   b35 <botlish_entry_6+0x1b>
			b31: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_copy_chunks<List[never], int, mutarray, int>
     b35:	mov    rsp,rbp
     b38:	pop    rbp
     b39:	ret

0000000000000b3a <botlish_fn_7: chunked_copy_chunks<List[mutarray], int, mutarray, int>>:
     b3a:	push   rbp
     b3b:	mov    rbp,rsp
     b3e:	sub    rsp,0x50
     b42:	mov    QWORD PTR [rsp+0x20],rbx
     b47:	mov    QWORD PTR [rsp+0x28],r12
     b4c:	mov    QWORD PTR [rsp+0x30],r13
     b51:	mov    QWORD PTR [rsp+0x38],r14
     b56:	mov    QWORD PTR [rsp+0x40],r15
     b5b:	mov    r14,rdi
     b5e:	mov    QWORD PTR [rsp],rsi
     b62:	mov    QWORD PTR [rsp+0x8],rcx
     b67:	mov    r13,rcx
     b6a:	mov    QWORD PTR [rsp+0x10],r8
     b6f:	sar    rdx,1
     b72:	mov    rbx,rdx
     b75:	mov    r12,rsi
     b78:	mov    r15,r8
     b7b:	mov    rsi,r12
     b7e:	mov    rdi,r14
     b81:	call   b86 <botlish_fn_7+0x4c>
			b82: R_X86_64_PLT32	rt_list_len-0x4
     b86:	sar    rax,1
     b89:	cmp    rbx,rax
     b8c:	jge    c7b <botlish_fn_7+0x141>
     b92:	mov    rdx,QWORD PTR [r12+0x8]
     b97:	mov    rcx,rbx
     b9a:	shl    rcx,1
     b9d:	or     rcx,0x1
     ba1:	sar    rcx,1
     ba4:	cmp    rcx,rdx
     ba7:	jb     bd3 <botlish_fn_7+0x99>
     bad:	mov    rdx,rbx
     bb0:	shl    rdx,1
     bb3:	or     rdx,0x1
     bb7:	mov    rsi,r12
     bba:	mov    rdi,r14
     bbd:	call   bc2 <botlish_fn_7+0x88>
			bbe: R_X86_64_PLT32	rt_list_get-0x4
     bc2:	test   rax,rax
     bc5:	je     bff <botlish_fn_7+0xc5>
     bcb:	mov    rcx,rax
     bce:	jmp    bdc <botlish_fn_7+0xa2>
     bd3:	mov    rax,QWORD PTR [r12+0x10]
     bd8:	mov    rcx,QWORD PTR [rax+rcx*8]
     bdc:	mov    r8d,0x1
     be2:	mov    r9d,0x81
     be8:	mov    rdx,r15
     beb:	mov    rsi,r13
     bee:	mov    rdi,r14
     bf1:	call   bf6 <botlish_fn_7+0xbc>
			bf2: R_X86_64_PLT32	rt_mutarray_copy-0x4
     bf6:	test   rax,rax
     bf9:	jne    c24 <botlish_fn_7+0xea>
     bff:	xor    rax,rax
     c02:	mov    rbx,QWORD PTR [rsp+0x20]
     c07:	mov    r12,QWORD PTR [rsp+0x28]
     c0c:	mov    r13,QWORD PTR [rsp+0x30]
     c11:	mov    r14,QWORD PTR [rsp+0x38]
     c16:	mov    r15,QWORD PTR [rsp+0x40]
     c1b:	add    rsp,0x50
     c1f:	mov    rsp,rbp
     c22:	pop    rbp
     c23:	ret
     c24:	mov    QWORD PTR [rsp+0x18],0x81
     c2d:	mov    rsi,r15
     c30:	test   rsi,0x1
     c37:	je     c51 <botlish_fn_7+0x117>
     c3d:	mov    rax,rsi
     c40:	add    rax,0x80
     c46:	seto   cl
     c49:	test   cl,cl
     c4b:	je     c5e <botlish_fn_7+0x124>
     c51:	mov    edx,0x81
     c56:	mov    rdi,r14
     c59:	call   c5e <botlish_fn_7+0x124>
			c5a: R_X86_64_PLT32	rt_int_add-0x4
     c5e:	mov    QWORD PTR [rsp],r12
     c62:	mov    QWORD PTR [rsp+0x8],r13
     c67:	mov    QWORD PTR [rsp+0x10],rax
     c6c:	add    rbx,0x1
     c73:	mov    r15,rax
     c76:	jmp    b7b <botlish_fn_7+0x41>
     c7b:	mov    rax,r15
     c7e:	mov    rbx,QWORD PTR [rsp+0x20]
     c83:	mov    r12,QWORD PTR [rsp+0x28]
     c88:	mov    r13,QWORD PTR [rsp+0x30]
     c8d:	mov    r14,QWORD PTR [rsp+0x38]
     c92:	mov    r15,QWORD PTR [rsp+0x40]
     c97:	add    rsp,0x50
     c9b:	mov    rsp,rbp
     c9e:	pop    rbp
     c9f:	ret

0000000000000ca0 <botlish_entry_7: chunked_copy_chunks<List[mutarray], int, mutarray, int>>:
     ca0:	push   rbp
     ca1:	mov    rbp,rsp
     ca4:	mov    rsi,QWORD PTR [rdx]
     ca7:	mov    r9,QWORD PTR [rdx+0x8]
     cab:	mov    rcx,QWORD PTR [rdx+0x10]
     caf:	mov    r8,QWORD PTR [rdx+0x18]
     cb3:	mov    rdx,r9
     cb6:	call   cbb <botlish_entry_7+0x1b>
			cb7: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<List[mutarray], int, mutarray, int>
     cbb:	mov    rsp,rbp
     cbe:	pop    rbp
     cbf:	ret

0000000000000cc0 <botlish_fn_8: chunked_finish<list[List[never], mutarray, int]>>:
     cc0:	push   rbp
     cc1:	mov    rbp,rsp
     cc4:	sub    rsp,0x70
     cc8:	mov    QWORD PTR [rsp+0x40],rbx
     ccd:	mov    QWORD PTR [rsp+0x48],r12
     cd2:	mov    QWORD PTR [rsp+0x50],r13
     cd7:	mov    QWORD PTR [rsp+0x58],r14
     cdc:	mov    QWORD PTR [rsp+0x60],r15
     ce1:	mov    r13,rdi
     ce4:	mov    QWORD PTR [rsp+0x28],0x0
     ced:	mov    QWORD PTR [rsp+0x30],0x0
     cf6:	mov    QWORD PTR [rsp],rsi
     cfa:	mov    r15,rsi
     cfd:	mov    QWORD PTR [rsp+0x8],rdx
     d02:	mov    r14,rdx
     d05:	mov    QWORD PTR [rsp+0x10],rcx
     d0a:	mov    r12,rcx
     d0d:	mov    rsi,r15
     d10:	mov    rdi,r13
     d13:	call   d18 <botlish_fn_8+0x58>
			d14: R_X86_64_PLT32	rt_list_len-0x4
     d18:	mov    QWORD PTR [rsp+0x18],rax
     d1d:	mov    QWORD PTR [rsp+0x20],0x81
     d26:	test   rax,0x1
     d2c:	mov    rsi,rax
     d2f:	je     d5c <botlish_fn_8+0x9c>
     d35:	mov    rdx,rsi
     d38:	mov    rax,rdx
     d3b:	sar    rax,1
     d3e:	imul   QWORD PTR [rip+0x14b]        # e90 <botlish_fn_8+0x1d0>
     d45:	seto   cl
     d48:	or     rax,0x1
     d4c:	test   cl,cl
     d4e:	jne    d5c <botlish_fn_8+0x9c>
     d54:	mov    rsi,rax
     d57:	jmp    d6c <botlish_fn_8+0xac>
     d5c:	mov    edx,0x81
     d61:	mov    rdi,r13
     d64:	call   d69 <botlish_fn_8+0xa9>
			d65: R_X86_64_PLT32	rt_int_mul-0x4
     d69:	mov    rsi,rax
     d6c:	mov    QWORD PTR [rsp+0x18],rsi
     d71:	mov    rax,rsi
     d74:	and    rax,r12
     d77:	test   rax,0x1
     d7d:	je     d99 <botlish_fn_8+0xd9>
     d83:	lea    rcx,[r12-0x1]
     d88:	mov    rbx,rsi
     d8b:	add    rbx,rcx
     d8e:	seto   al
     d91:	test   al,al
     d93:	je     da7 <botlish_fn_8+0xe7>
     d99:	mov    rdx,r12
     d9c:	mov    rdi,r13
     d9f:	call   da4 <botlish_fn_8+0xe4>
			da0: R_X86_64_PLT32	rt_int_add-0x4
     da4:	mov    rbx,rax
     da7:	mov    QWORD PTR [rsp+0x18],rbx
     dac:	mov    rsi,rbx
     daf:	mov    rdi,r13
     db2:	call   db7 <botlish_fn_8+0xf7>
			db3: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     db7:	mov    rcx,rax
     dba:	mov    QWORD PTR [rsp+0x38],rax
     dbf:	test   rax,rcx
     dc2:	je     e44 <botlish_fn_8+0x184>
     dc8:	mov    rax,QWORD PTR [rsp+0x38]
     dcd:	mov    QWORD PTR [rsp+0x20],rax
     dd2:	mov    r8d,0x1
     dd8:	mov    QWORD PTR [rsp+0x28],0x1
     de1:	mov    QWORD PTR [rsp+0x30],0x1
     dea:	mov    rsi,r15
     ded:	mov    rcx,QWORD PTR [rsp+0x38]
     df2:	mov    rdi,r13
     df5:	mov    rdx,r8
     df8:	call   dfd <botlish_fn_8+0x13d>
			df9: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_copy_chunks<List[never], int, mutarray, int>
     dfd:	test   rax,rax
     e00:	mov    rdx,rax
     e03:	je     e44 <botlish_fn_8+0x184>
     e09:	mov    r8d,0x1
     e0f:	mov    rcx,r14
     e12:	mov    r9,r12
     e15:	mov    rsi,QWORD PTR [rsp+0x38]
     e1a:	mov    rdi,r13
     e1d:	call   e22 <botlish_fn_8+0x162>
			e1e: R_X86_64_PLT32	rt_mutarray_copy-0x4
     e22:	test   rax,rax
     e25:	je     e44 <botlish_fn_8+0x184>
     e2b:	mov    rdx,rbx
     e2e:	mov    rsi,QWORD PTR [rsp+0x38]
     e33:	mov    rdi,r13
     e36:	call   e3b <botlish_fn_8+0x17b>
			e37: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     e3b:	test   rax,rax
     e3e:	jne    e69 <botlish_fn_8+0x1a9>
     e44:	xor    rax,rax
     e47:	mov    rbx,QWORD PTR [rsp+0x40]
     e4c:	mov    r12,QWORD PTR [rsp+0x48]
     e51:	mov    r13,QWORD PTR [rsp+0x50]
     e56:	mov    r14,QWORD PTR [rsp+0x58]
     e5b:	mov    r15,QWORD PTR [rsp+0x60]
     e60:	add    rsp,0x70
     e64:	mov    rsp,rbp
     e67:	pop    rbp
     e68:	ret
     e69:	mov    rbx,QWORD PTR [rsp+0x40]
     e6e:	mov    r12,QWORD PTR [rsp+0x48]
     e73:	mov    r13,QWORD PTR [rsp+0x50]
     e78:	mov    r14,QWORD PTR [rsp+0x58]
     e7d:	mov    r15,QWORD PTR [rsp+0x60]
     e82:	add    rsp,0x70
     e86:	mov    rsp,rbp
     e89:	pop    rbp
     e8a:	ret
     e8b:	add    BYTE PTR [rax],al
     e8d:	add    BYTE PTR [rax],al
     e8f:	add    BYTE PTR [rax+0x0],al
     e95:	add    BYTE PTR [rax],al
	...

0000000000000e98 <botlish_entry_8: chunked_finish<list[List[never], mutarray, int]>>:
     e98:	push   rbp
     e99:	mov    rbp,rsp
     e9c:	mov    rsi,QWORD PTR [rdx]
     e9f:	mov    r8,QWORD PTR [rdx+0x8]
     ea3:	mov    rcx,QWORD PTR [rdx+0x10]
     ea7:	mov    rdx,r8
     eaa:	call   eaf <botlish_entry_8+0x17>
			eab: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[List[never], mutarray, int]>
     eaf:	mov    rsp,rbp
     eb2:	pop    rbp
     eb3:	ret
     eb4:	add    BYTE PTR [rax],al
	...

0000000000000eb8 <botlish_fn_9: chunked_finish<list[List[mutarray], mutarray, int]>>:
     eb8:	push   rbp
     eb9:	mov    rbp,rsp
     ebc:	sub    rsp,0x70
     ec0:	mov    QWORD PTR [rsp+0x40],rbx
     ec5:	mov    QWORD PTR [rsp+0x48],r12
     eca:	mov    QWORD PTR [rsp+0x50],r13
     ecf:	mov    QWORD PTR [rsp+0x58],r14
     ed4:	mov    QWORD PTR [rsp+0x60],r15
     ed9:	mov    r13,rdi
     edc:	mov    QWORD PTR [rsp+0x28],0x0
     ee5:	mov    QWORD PTR [rsp+0x30],0x0
     eee:	mov    QWORD PTR [rsp],rsi
     ef2:	mov    r15,rsi
     ef5:	mov    QWORD PTR [rsp+0x8],rdx
     efa:	mov    r14,rdx
     efd:	mov    QWORD PTR [rsp+0x10],rcx
     f02:	mov    r12,rcx
     f05:	mov    rsi,r15
     f08:	mov    rdi,r13
     f0b:	call   f10 <botlish_fn_9+0x58>
			f0c: R_X86_64_PLT32	rt_list_len-0x4
     f10:	mov    QWORD PTR [rsp+0x18],rax
     f15:	mov    QWORD PTR [rsp+0x20],0x81
     f1e:	test   rax,0x1
     f24:	mov    rsi,rax
     f27:	je     f54 <botlish_fn_9+0x9c>
     f2d:	mov    rdx,rsi
     f30:	mov    rax,rdx
     f33:	sar    rax,1
     f36:	imul   QWORD PTR [rip+0x14b]        # 1088 <botlish_fn_9+0x1d0>
     f3d:	seto   cl
     f40:	or     rax,0x1
     f44:	test   cl,cl
     f46:	jne    f54 <botlish_fn_9+0x9c>
     f4c:	mov    rsi,rax
     f4f:	jmp    f64 <botlish_fn_9+0xac>
     f54:	mov    edx,0x81
     f59:	mov    rdi,r13
     f5c:	call   f61 <botlish_fn_9+0xa9>
			f5d: R_X86_64_PLT32	rt_int_mul-0x4
     f61:	mov    rsi,rax
     f64:	mov    QWORD PTR [rsp+0x18],rsi
     f69:	mov    rax,rsi
     f6c:	and    rax,r12
     f6f:	test   rax,0x1
     f75:	je     f91 <botlish_fn_9+0xd9>
     f7b:	lea    rcx,[r12-0x1]
     f80:	mov    rbx,rsi
     f83:	add    rbx,rcx
     f86:	seto   al
     f89:	test   al,al
     f8b:	je     f9f <botlish_fn_9+0xe7>
     f91:	mov    rdx,r12
     f94:	mov    rdi,r13
     f97:	call   f9c <botlish_fn_9+0xe4>
			f98: R_X86_64_PLT32	rt_int_add-0x4
     f9c:	mov    rbx,rax
     f9f:	mov    QWORD PTR [rsp+0x18],rbx
     fa4:	mov    rsi,rbx
     fa7:	mov    rdi,r13
     faa:	call   faf <botlish_fn_9+0xf7>
			fab: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     faf:	mov    rcx,rax
     fb2:	mov    QWORD PTR [rsp+0x38],rax
     fb7:	test   rax,rcx
     fba:	je     103c <botlish_fn_9+0x184>
     fc0:	mov    rax,QWORD PTR [rsp+0x38]
     fc5:	mov    QWORD PTR [rsp+0x20],rax
     fca:	mov    r8d,0x1
     fd0:	mov    QWORD PTR [rsp+0x28],0x1
     fd9:	mov    QWORD PTR [rsp+0x30],0x1
     fe2:	mov    rsi,r15
     fe5:	mov    rcx,QWORD PTR [rsp+0x38]
     fea:	mov    rdi,r13
     fed:	mov    rdx,r8
     ff0:	call   ff5 <botlish_fn_9+0x13d>
			ff1: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<List[mutarray], int, mutarray, int>
     ff5:	test   rax,rax
     ff8:	mov    rdx,rax
     ffb:	je     103c <botlish_fn_9+0x184>
    1001:	mov    r8d,0x1
    1007:	mov    rcx,r14
    100a:	mov    r9,r12
    100d:	mov    rsi,QWORD PTR [rsp+0x38]
    1012:	mov    rdi,r13
    1015:	call   101a <botlish_fn_9+0x162>
			1016: R_X86_64_PLT32	rt_mutarray_copy-0x4
    101a:	test   rax,rax
    101d:	je     103c <botlish_fn_9+0x184>
    1023:	mov    rdx,rbx
    1026:	mov    rsi,QWORD PTR [rsp+0x38]
    102b:	mov    rdi,r13
    102e:	call   1033 <botlish_fn_9+0x17b>
			102f: R_X86_64_PLT32	rt_mutarray_freeze-0x4
    1033:	test   rax,rax
    1036:	jne    1061 <botlish_fn_9+0x1a9>
    103c:	xor    rax,rax
    103f:	mov    rbx,QWORD PTR [rsp+0x40]
    1044:	mov    r12,QWORD PTR [rsp+0x48]
    1049:	mov    r13,QWORD PTR [rsp+0x50]
    104e:	mov    r14,QWORD PTR [rsp+0x58]
    1053:	mov    r15,QWORD PTR [rsp+0x60]
    1058:	add    rsp,0x70
    105c:	mov    rsp,rbp
    105f:	pop    rbp
    1060:	ret
    1061:	mov    rbx,QWORD PTR [rsp+0x40]
    1066:	mov    r12,QWORD PTR [rsp+0x48]
    106b:	mov    r13,QWORD PTR [rsp+0x50]
    1070:	mov    r14,QWORD PTR [rsp+0x58]
    1075:	mov    r15,QWORD PTR [rsp+0x60]
    107a:	add    rsp,0x70
    107e:	mov    rsp,rbp
    1081:	pop    rbp
    1082:	ret
    1083:	add    BYTE PTR [rax],al
    1085:	add    BYTE PTR [rax],al
    1087:	add    BYTE PTR [rax+0x0],al
    108d:	add    BYTE PTR [rax],al
	...

0000000000001090 <botlish_entry_9: chunked_finish<list[List[mutarray], mutarray, int]>>:
    1090:	push   rbp
    1091:	mov    rbp,rsp
    1094:	mov    rsi,QWORD PTR [rdx]
    1097:	mov    r8,QWORD PTR [rdx+0x8]
    109b:	mov    rcx,QWORD PTR [rdx+0x10]
    109f:	mov    rdx,r8
    10a2:	call   10a7 <botlish_entry_9+0x17>
			10a3: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    10a7:	mov    rsp,rbp
    10aa:	pop    rbp
    10ab:	ret
    10ac:	add    BYTE PTR [rax],al
	...

00000000000010b0 <botlish_fn_10: peek<str, int>>:
    10b0:	push   rbp
    10b1:	mov    rbp,rsp
    10b4:	sub    rsp,0x40
    10b8:	mov    QWORD PTR [rsp+0x20],rbx
    10bd:	mov    QWORD PTR [rsp+0x28],r12
    10c2:	mov    QWORD PTR [rsp+0x30],r13
    10c7:	mov    rbx,rdx
    10ca:	mov    r13,rdi
    10cd:	mov    QWORD PTR [rsp],rsi
    10d1:	mov    QWORD PTR [rsp+0x8],rdx
    10d6:	mov    rdx,QWORD PTR [rsi+0x8]
    10da:	mov    r12,rsi
    10dd:	shl    rdx,1
    10e0:	mov    rax,rdx
    10e3:	or     rax,0x1
    10e7:	mov    rcx,rbx
    10ea:	and    rcx,rax
    10ed:	test   rcx,0x1
    10f4:	jne    111e <botlish_fn_10+0x6e>
    10fa:	or     rdx,0x1
    10fe:	mov    rsi,rbx
    1101:	mov    rdi,r13
    1104:	call   1109 <botlish_fn_10+0x59>
			1105: R_X86_64_PLT32	rt_int_cmp-0x4
    1109:	mov    ecx,0x2
    110e:	test   rax,rax
    1111:	cmovge rcx,QWORD PTR [rip+0xd7]        # 11f0 <botlish_fn_10+0x140>
    1119:	jmp    1132 <botlish_fn_10+0x82>
    111e:	or     rdx,0x1
    1122:	mov    ecx,0x2
    1127:	cmp    rbx,rdx
    112a:	cmovge rcx,QWORD PTR [rip+0xbe]        # 11f0 <botlish_fn_10+0x140>
    1132:	cmp    rcx,0x6
    1136:	je     11c6 <botlish_fn_10+0x116>
    113c:	mov    QWORD PTR [rsp+0x10],0x3
    1145:	test   rbx,0x1
    114c:	je     1164 <botlish_fn_10+0xb4>
    1152:	mov    rcx,rbx
    1155:	add    rcx,0x2
    1159:	seto   al
    115c:	test   al,al
    115e:	je     1177 <botlish_fn_10+0xc7>
    1164:	mov    edx,0x3
    1169:	mov    rsi,rbx
    116c:	mov    rdi,r13
    116f:	call   1174 <botlish_fn_10+0xc4>
			1170: R_X86_64_PLT32	rt_int_add-0x4
    1174:	mov    rcx,rax
    1177:	mov    QWORD PTR [rsp+0x10],rcx
    117c:	mov    rdx,rbx
    117f:	mov    rsi,r12
    1182:	mov    rdi,r13
    1185:	call   118a <botlish_fn_10+0xda>
			1186: R_X86_64_PLT32	rt_substr-0x4
    118a:	test   rax,rax
    118d:	jne    11ae <botlish_fn_10+0xfe>
    1193:	xor    rax,rax
    1196:	mov    rbx,QWORD PTR [rsp+0x20]
    119b:	mov    r12,QWORD PTR [rsp+0x28]
    11a0:	mov    r13,QWORD PTR [rsp+0x30]
    11a5:	add    rsp,0x40
    11a9:	mov    rsp,rbp
    11ac:	pop    rbp
    11ad:	ret
    11ae:	mov    rbx,QWORD PTR [rsp+0x20]
    11b3:	mov    r12,QWORD PTR [rsp+0x28]
    11b8:	mov    r13,QWORD PTR [rsp+0x30]
    11bd:	add    rsp,0x40
    11c1:	mov    rsp,rbp
    11c4:	pop    rbp
    11c5:	ret
    11c6:	mov    rdi,r13
    11c9:	mov    rax,QWORD PTR [rdi+0x10]
    11cd:	mov    rax,QWORD PTR [rax+0x10]
    11d1:	mov    rbx,QWORD PTR [rsp+0x20]
    11d6:	mov    r12,QWORD PTR [rsp+0x28]
    11db:	mov    r13,QWORD PTR [rsp+0x30]
    11e0:	add    rsp,0x40
    11e4:	mov    rsp,rbp
    11e7:	pop    rbp
    11e8:	ret
    11e9:	add    BYTE PTR [rax],al
    11eb:	add    BYTE PTR [rax],al
    11ed:	add    BYTE PTR [rax],al
    11ef:	add    BYTE PTR [rsi],al
    11f1:	add    BYTE PTR [rax],al
    11f3:	add    BYTE PTR [rax],al
    11f5:	add    BYTE PTR [rax],al
	...

00000000000011f8 <botlish_entry_10: peek<str, int>>:
    11f8:	push   rbp
    11f9:	mov    rbp,rsp
    11fc:	mov    rsi,QWORD PTR [rdx]
    11ff:	mov    rdx,QWORD PTR [rdx+0x8]
    1203:	call   1208 <botlish_entry_10+0x10>
			1204: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    1208:	mov    rsp,rbp
    120b:	pop    rbp
    120c:	ret
    120d:	add    BYTE PTR [rax],al
	...

0000000000001210 <botlish_fn_11: peek<str, int>>:
    1210:	push   rbp
    1211:	mov    rbp,rsp
    1214:	sub    rsp,0x50
    1218:	mov    QWORD PTR [rsp+0x20],rbx
    121d:	mov    QWORD PTR [rsp+0x28],r12
    1222:	mov    QWORD PTR [rsp+0x30],r13
    1227:	mov    QWORD PTR [rsp+0x38],r14
    122c:	mov    QWORD PTR [rsp+0x40],r15
    1231:	mov    rbx,rdx
    1234:	mov    r12,rcx
    1237:	mov    r14,rdi
    123a:	mov    QWORD PTR [rsp],rsi
    123e:	mov    QWORD PTR [rsp+0x8],rdx
    1243:	mov    rdx,QWORD PTR [rsi+0x8]
    1247:	mov    r13,rsi
    124a:	shl    rdx,1
    124d:	mov    rax,rdx
    1250:	or     rax,0x1
    1254:	mov    rcx,rbx
    1257:	and    rcx,rax
    125a:	test   rcx,0x1
    1261:	jne    128b <botlish_fn_11+0x7b>
    1267:	or     rdx,0x1
    126b:	mov    rsi,rbx
    126e:	mov    rdi,r14
    1271:	call   1276 <botlish_fn_11+0x66>
			1272: R_X86_64_PLT32	rt_int_cmp-0x4
    1276:	mov    ecx,0x2
    127b:	test   rax,rax
    127e:	cmovge rcx,QWORD PTR [rip+0x122]        # 13a8 <botlish_fn_11+0x198>
    1286:	jmp    129f <botlish_fn_11+0x8f>
    128b:	or     rdx,0x1
    128f:	mov    ecx,0x2
    1294:	cmp    rbx,rdx
    1297:	cmovge rcx,QWORD PTR [rip+0x109]        # 13a8 <botlish_fn_11+0x198>
    129f:	cmp    rcx,0x6
    12a3:	je     1363 <botlish_fn_11+0x153>
    12a9:	mov    QWORD PTR [rsp+0x10],0x3
    12b2:	test   rbx,0x1
    12b9:	je     12dc <botlish_fn_11+0xcc>
    12bf:	mov    rax,rbx
    12c2:	add    rax,0x2
    12c6:	seto   cl
    12c9:	test   cl,cl
    12cb:	jne    12dc <botlish_fn_11+0xcc>
    12d1:	mov    rdi,r14
    12d4:	mov    r15,rax
    12d7:	jmp    12f2 <botlish_fn_11+0xe2>
    12dc:	mov    edx,0x3
    12e1:	mov    rsi,rbx
    12e4:	mov    rdi,r14
    12e7:	call   12ec <botlish_fn_11+0xdc>
			12e8: R_X86_64_PLT32	rt_int_add-0x4
    12ec:	mov    r15,rax
    12ef:	mov    rdi,r14
    12f2:	mov    rdi,r14
    12f5:	mov    rcx,r15
    12f8:	mov    rdx,rbx
    12fb:	mov    rsi,r13
    12fe:	call   1303 <botlish_fn_11+0xf3>
			12ff: R_X86_64_PLT32	rt_str_region_check-0x4
    1303:	test   rax,rax
    1306:	jne    1331 <botlish_fn_11+0x121>
    130c:	xor    rax,rax
    130f:	mov    rbx,QWORD PTR [rsp+0x20]
    1314:	mov    r12,QWORD PTR [rsp+0x28]
    1319:	mov    r13,QWORD PTR [rsp+0x30]
    131e:	mov    r14,QWORD PTR [rsp+0x38]
    1323:	mov    r15,QWORD PTR [rsp+0x40]
    1328:	add    rsp,0x50
    132c:	mov    rsp,rbp
    132f:	pop    rbp
    1330:	ret
    1331:	mov    rcx,r12
    1334:	mov    QWORD PTR [rcx],rbx
    1337:	mov    rax,r15
    133a:	mov    QWORD PTR [rcx+0x8],rax
    133e:	mov    rax,r13
    1341:	mov    rbx,QWORD PTR [rsp+0x20]
    1346:	mov    r12,QWORD PTR [rsp+0x28]
    134b:	mov    r13,QWORD PTR [rsp+0x30]
    1350:	mov    r14,QWORD PTR [rsp+0x38]
    1355:	mov    r15,QWORD PTR [rsp+0x40]
    135a:	add    rsp,0x50
    135e:	mov    rsp,rbp
    1361:	pop    rbp
    1362:	ret
    1363:	mov    rcx,r12
    1366:	mov    rdi,r14
    1369:	mov    rax,QWORD PTR [rdi+0x10]
    136d:	mov    rax,QWORD PTR [rax+0x10]
    1371:	mov    QWORD PTR [rcx],0x1
    1378:	mov    QWORD PTR [rcx+0x8],0x1
    1380:	mov    rbx,QWORD PTR [rsp+0x20]
    1385:	mov    r12,QWORD PTR [rsp+0x28]
    138a:	mov    r13,QWORD PTR [rsp+0x30]
    138f:	mov    r14,QWORD PTR [rsp+0x38]
    1394:	mov    r15,QWORD PTR [rsp+0x40]
    1399:	add    rsp,0x50
    139d:	mov    rsp,rbp
    13a0:	pop    rbp
    13a1:	ret
    13a2:	add    BYTE PTR [rax],al
    13a4:	add    BYTE PTR [rax],al
    13a6:	add    BYTE PTR [rax],al
    13a8:	(bad)
    13a9:	add    BYTE PTR [rax],al
    13ab:	add    BYTE PTR [rax],al
    13ad:	add    BYTE PTR [rax],al
	...

00000000000013b0 <botlish_entry_11: peek<str, int>>:
    13b0:	push   rbp
    13b1:	mov    rbp,rsp
    13b4:	ud2

00000000000013b6 <botlish_fn_12: scan_unquoted<str, int, int>>:
    13b6:	push   rbp
    13b7:	mov    rbp,rsp
    13ba:	sub    rsp,0x80
    13c1:	mov    QWORD PTR [rsp+0x50],rbx
    13c6:	mov    QWORD PTR [rsp+0x58],r12
    13cb:	mov    QWORD PTR [rsp+0x60],r13
    13d0:	mov    QWORD PTR [rsp+0x68],r14
    13d5:	mov    QWORD PTR [rsp+0x70],r15
    13da:	mov    QWORD PTR [rsp+0x30],rdi
    13df:	mov    QWORD PTR [rsp+0x18],0x0
    13e8:	mov    QWORD PTR [rsp],rsi
    13ec:	mov    r15,rsi
    13ef:	mov    QWORD PTR [rsp+0x8],rdx
    13f4:	mov    r14,rdx
    13f7:	mov    QWORD PTR [rsp+0x10],rcx
    13fc:	lea    r13,[rsp+0x20]
    1401:	mov    QWORD PTR [rsp+0x38],rcx
    1406:	mov    rcx,r13
    1409:	mov    rdx,QWORD PTR [rsp+0x38]
    140e:	mov    rsi,r15
    1411:	mov    rdi,QWORD PTR [rsp+0x30]
    1416:	call   141b <botlish_fn_12+0x65>
			1417: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    141b:	mov    rsi,rax
    141e:	mov    QWORD PTR [rsp+0x40],rax
    1423:	test   rax,rsi
    1426:	je     1580 <botlish_fn_12+0x1ca>
    142c:	mov    rbx,QWORD PTR [rsp+0x20]
    1431:	mov    r12,QWORD PTR [rsp+0x28]
    1436:	mov    rdi,QWORD PTR [rsp+0x30]
    143b:	mov    rcx,QWORD PTR [rdi+0x10]
    143f:	mov    r8,QWORD PTR [rcx+0x10]
    1443:	mov    rcx,r12
    1446:	mov    rdx,rbx
    1449:	mov    rsi,QWORD PTR [rsp+0x40]
    144e:	call   1453 <botlish_fn_12+0x9d>
			144f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1453:	cmp    rax,0x6
    1457:	je     1498 <botlish_fn_12+0xe2>
    145d:	mov    rdi,QWORD PTR [rsp+0x30]
    1462:	mov    rax,QWORD PTR [rdi+0x10]
    1466:	mov    r8,QWORD PTR [rax+0x18]
    146a:	mov    rcx,r12
    146d:	mov    rdx,rbx
    1470:	mov    rsi,QWORD PTR [rsp+0x40]
    1475:	call   147a <botlish_fn_12+0xc4>
			1476: R_X86_64_PLT32	rt_str_region_eq-0x4
    147a:	cmp    rax,0x6
    147e:	je     148e <botlish_fn_12+0xd8>
    1484:	mov    eax,0x2
    1489:	jmp    149d <botlish_fn_12+0xe7>
    148e:	mov    eax,0x6
    1493:	jmp    149d <botlish_fn_12+0xe7>
    1498:	mov    eax,0x6
    149d:	cmp    rax,0x6
    14a1:	je     14e2 <botlish_fn_12+0x12c>
    14a7:	mov    rdi,QWORD PTR [rsp+0x30]
    14ac:	mov    rax,QWORD PTR [rdi+0x10]
    14b0:	mov    r8,QWORD PTR [rax+0x20]
    14b4:	mov    rcx,r12
    14b7:	mov    rdx,rbx
    14ba:	mov    rsi,QWORD PTR [rsp+0x40]
    14bf:	call   14c4 <botlish_fn_12+0x10e>
			14c0: R_X86_64_PLT32	rt_str_region_eq-0x4
    14c4:	cmp    rax,0x6
    14c8:	je     14d8 <botlish_fn_12+0x122>
    14ce:	mov    eax,0x2
    14d3:	jmp    14e7 <botlish_fn_12+0x131>
    14d8:	mov    eax,0x6
    14dd:	jmp    14e7 <botlish_fn_12+0x131>
    14e2:	mov    eax,0x6
    14e7:	cmp    rax,0x6
    14eb:	je     1562 <botlish_fn_12+0x1ac>
    14f1:	mov    QWORD PTR [rsp+0x18],0x3
    14fa:	mov    rsi,QWORD PTR [rsp+0x38]
    14ff:	test   rsi,0x1
    1506:	je     152d <botlish_fn_12+0x177>
    150c:	mov    rsi,QWORD PTR [rsp+0x38]
    1511:	mov    rax,rsi
    1514:	add    rax,0x2
    1518:	seto   sil
    151c:	test   sil,sil
    151f:	jne    152d <botlish_fn_12+0x177>
    1525:	mov    rsi,r15
    1528:	jmp    1544 <botlish_fn_12+0x18e>
    152d:	mov    edx,0x3
    1532:	mov    rsi,QWORD PTR [rsp+0x38]
    1537:	mov    rdi,QWORD PTR [rsp+0x30]
    153c:	call   1541 <botlish_fn_12+0x18b>
			153d: R_X86_64_PLT32	rt_int_add-0x4
    1541:	mov    rsi,r15
    1544:	mov    QWORD PTR [rsp],rsi
    1548:	mov    rdx,r14
    154b:	mov    QWORD PTR [rsp+0x8],rdx
    1550:	mov    QWORD PTR [rsp+0x10],rax
    1555:	mov    r15,rsi
    1558:	mov    QWORD PTR [rsp+0x38],rax
    155d:	jmp    1406 <botlish_fn_12+0x50>
    1562:	mov    rdx,r14
    1565:	mov    rsi,r15
    1568:	mov    rdi,QWORD PTR [rsp+0x30]
    156d:	mov    rcx,QWORD PTR [rsp+0x38]
    1572:	call   1577 <botlish_fn_12+0x1c1>
			1573: R_X86_64_PLT32	rt_substr-0x4
    1577:	test   rax,rax
    157a:	jne    15ab <botlish_fn_12+0x1f5>
    1580:	xor    rdx,rdx
    1583:	mov    rax,rdx
    1586:	mov    rbx,QWORD PTR [rsp+0x50]
    158b:	mov    r12,QWORD PTR [rsp+0x58]
    1590:	mov    r13,QWORD PTR [rsp+0x60]
    1595:	mov    r14,QWORD PTR [rsp+0x68]
    159a:	mov    r15,QWORD PTR [rsp+0x70]
    159f:	add    rsp,0x80
    15a6:	mov    rsp,rbp
    15a9:	pop    rbp
    15aa:	ret
    15ab:	mov    rdx,QWORD PTR [rsp+0x38]
    15b0:	mov    rbx,QWORD PTR [rsp+0x50]
    15b5:	mov    r12,QWORD PTR [rsp+0x58]
    15ba:	mov    r13,QWORD PTR [rsp+0x60]
    15bf:	mov    r14,QWORD PTR [rsp+0x68]
    15c4:	mov    r15,QWORD PTR [rsp+0x70]
    15c9:	add    rsp,0x80
    15d0:	mov    rsp,rbp
    15d3:	pop    rbp
    15d4:	ret

00000000000015d5 <botlish_entry_12: scan_unquoted<str, int, int>>:
    15d5:	push   rbp
    15d6:	mov    rbp,rsp
    15d9:	ud2

00000000000015db <botlish_fn_13: scan_quoted<str, int, str>>:
    15db:	push   rbp
    15dc:	mov    rbp,rsp
    15df:	sub    rsp,0xd0
    15e6:	mov    QWORD PTR [rsp+0xa0],rbx
    15ee:	mov    QWORD PTR [rsp+0xa8],r12
    15f6:	mov    QWORD PTR [rsp+0xb0],r13
    15fe:	mov    QWORD PTR [rsp+0xb8],r14
    1606:	mov    QWORD PTR [rsp+0xc0],r15
    160e:	mov    QWORD PTR [rsp+0x88],rdi
    1616:	mov    QWORD PTR [rsp+0x18],0x0
    161f:	mov    QWORD PTR [rsp+0x20],0x0
    1628:	mov    QWORD PTR [rsp],rsi
    162c:	mov    QWORD PTR [rsp+0x8],rdx
    1631:	mov    QWORD PTR [rsp+0x10],rcx
    1636:	mov    r13,rcx
    1639:	lea    r14,[rsp+0x68]
    163e:	lea    rbx,[rsp+0x28]
    1643:	mov    r12,rsi
    1646:	mov    QWORD PTR [rsp+0x90],rdx
    164e:	mov    rdx,QWORD PTR [rsp+0x90]
    1656:	mov    rsi,r12
    1659:	mov    rdi,QWORD PTR [rsp+0x88]
    1661:	call   1666 <botlish_fn_13+0x8b>
			1662: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    1666:	test   rax,rax
    1669:	je     19b2 <botlish_fn_13+0x3d7>
    166f:	mov    QWORD PTR [rsp+0x18],rax
    1674:	mov    rsi,QWORD PTR [rax+0x8]
    1678:	mov    rcx,rax
    167b:	mov    rax,0xffffffffffffffff
    1682:	test   rsi,rsi
    1685:	jne    1693 <botlish_fn_13+0xb8>
    168b:	mov    r15,rcx
    168e:	jmp    16be <botlish_fn_13+0xe3>
    1693:	mov    r15,rcx
    1696:	movzx  rdi,BYTE PTR [r15+0x18]
    169b:	test   rdi,rdi
    169e:	jne    16b9 <botlish_fn_13+0xde>
    16a4:	mov    rsi,r15
    16a7:	mov    rdi,QWORD PTR [rsp+0x88]
    16af:	call   16b4 <botlish_fn_13+0xd9>
			16b0: R_X86_64_PLT32	rt_str_to_short-0x4
    16b4:	jmp    16be <botlish_fn_13+0xe3>
    16b9:	movzx  rax,BYTE PTR [r15+0x19]
    16be:	cmp    rax,0x22
    16c2:	je     1782 <botlish_fn_13+0x1a7>
    16c8:	mov    QWORD PTR [rsp+0x20],0x3
    16d1:	mov    rsi,QWORD PTR [rsp+0x90]
    16d9:	test   rsi,0x1
    16e0:	je     1700 <botlish_fn_13+0x125>
    16e6:	mov    rax,rsi
    16e9:	add    rax,0x2
    16ed:	seto   cl
    16f0:	test   cl,cl
    16f2:	jne    1700 <botlish_fn_13+0x125>
    16f8:	mov    rsi,rax
    16fb:	jmp    1715 <botlish_fn_13+0x13a>
    1700:	mov    edx,0x3
    1705:	mov    rdi,QWORD PTR [rsp+0x88]
    170d:	call   1712 <botlish_fn_13+0x137>
			170e: R_X86_64_PLT32	rt_int_add-0x4
    1712:	mov    rsi,rax
    1715:	mov    QWORD PTR [rsp+0x8],rsi
    171a:	mov    QWORD PTR [rsp+0x90],rsi
    1722:	mov    QWORD PTR [rsp+0x68],0x0
    172b:	mov    QWORD PTR [rsp+0x70],r13
    1730:	mov    QWORD PTR [rsp+0x78],0x0
    1739:	mov    QWORD PTR [rsp+0x80],r15
    1741:	mov    esi,0x2
    1746:	mov    edx,0x4
    174b:	mov    rcx,r14
    174e:	mov    rdi,QWORD PTR [rsp+0x88]
    1756:	call   175b <botlish_fn_13+0x180>
			1757: R_X86_64_PLT32	rt_construct-0x4
    175b:	test   rax,rax
    175e:	je     19b2 <botlish_fn_13+0x3d7>
    1764:	mov    QWORD PTR [rsp],r12
    1768:	mov    rsi,QWORD PTR [rsp+0x90]
    1770:	mov    QWORD PTR [rsp+0x8],rsi
    1775:	mov    QWORD PTR [rsp+0x10],rax
    177a:	mov    r13,rax
    177d:	jmp    164e <botlish_fn_13+0x73>
    1782:	mov    QWORD PTR [rsp+0x18],0x3
    178b:	mov    rsi,QWORD PTR [rsp+0x90]
    1793:	test   rsi,0x1
    179a:	je     17ba <botlish_fn_13+0x1df>
    17a0:	mov    rsi,QWORD PTR [rsp+0x90]
    17a8:	mov    rdx,rsi
    17ab:	add    rdx,0x2
    17af:	seto   al
    17b2:	test   al,al
    17b4:	je     17d7 <botlish_fn_13+0x1fc>
    17ba:	mov    edx,0x3
    17bf:	mov    rsi,QWORD PTR [rsp+0x90]
    17c7:	mov    rdi,QWORD PTR [rsp+0x88]
    17cf:	call   17d4 <botlish_fn_13+0x1f9>
			17d0: R_X86_64_PLT32	rt_int_add-0x4
    17d4:	mov    rdx,rax
    17d7:	mov    QWORD PTR [rsp+0x18],rdx
    17dc:	mov    rcx,rbx
    17df:	mov    rsi,r12
    17e2:	mov    rdi,QWORD PTR [rsp+0x88]
    17ea:	call   17ef <botlish_fn_13+0x214>
			17eb: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    17ef:	test   rax,rax
    17f2:	mov    rsi,rax
    17f5:	je     19b2 <botlish_fn_13+0x3d7>
    17fb:	mov    rdx,QWORD PTR [rsp+0x28]
    1800:	mov    rcx,QWORD PTR [rsp+0x30]
    1805:	mov    rdi,QWORD PTR [rsp+0x88]
    180d:	mov    rax,QWORD PTR [rdi+0x10]
    1811:	mov    r8,QWORD PTR [rax+0x28]
    1815:	call   181a <botlish_fn_13+0x23f>
			1816: R_X86_64_PLT32	rt_str_region_eq-0x4
    181a:	cmp    rax,0x6
    181e:	je     18f0 <botlish_fn_13+0x315>
    1824:	xor    rsi,rsi
    1827:	lea    rcx,[rsp+0x58]
    182c:	mov    QWORD PTR [rsp+0x58],0x0
    1835:	mov    QWORD PTR [rsp+0x60],r13
    183a:	mov    edx,0x2
    183f:	mov    rdi,QWORD PTR [rsp+0x88]
    1847:	call   184c <botlish_fn_13+0x271>
			1848: R_X86_64_PLT32	rt_construct-0x4
    184c:	test   rax,rax
    184f:	je     19b2 <botlish_fn_13+0x3d7>
    1855:	mov    QWORD PTR [rsp],rax
    1859:	mov    rbx,rax
    185c:	mov    QWORD PTR [rsp+0x10],0x3
    1865:	mov    rsi,QWORD PTR [rsp+0x90]
    186d:	test   rsi,0x1
    1874:	je     189c <botlish_fn_13+0x2c1>
    187a:	mov    rsi,QWORD PTR [rsp+0x90]
    1882:	mov    rdx,rsi
    1885:	add    rdx,0x2
    1889:	seto   al
    188c:	test   al,al
    188e:	jne    189c <botlish_fn_13+0x2c1>
    1894:	mov    rax,rbx
    1897:	jmp    18bc <botlish_fn_13+0x2e1>
    189c:	mov    edx,0x3
    18a1:	mov    rsi,QWORD PTR [rsp+0x90]
    18a9:	mov    rdi,QWORD PTR [rsp+0x88]
    18b1:	call   18b6 <botlish_fn_13+0x2db>
			18b2: R_X86_64_PLT32	rt_int_add-0x4
    18b6:	mov    rdx,rax
    18b9:	mov    rax,rbx
    18bc:	mov    rbx,QWORD PTR [rsp+0xa0]
    18c4:	mov    r12,QWORD PTR [rsp+0xa8]
    18cc:	mov    r13,QWORD PTR [rsp+0xb0]
    18d4:	mov    r14,QWORD PTR [rsp+0xb8]
    18dc:	mov    r15,QWORD PTR [rsp+0xc0]
    18e4:	add    rsp,0xd0
    18eb:	mov    rsp,rbp
    18ee:	pop    rbp
    18ef:	ret
    18f0:	mov    QWORD PTR [rsp+0x18],0x5
    18f9:	mov    rsi,QWORD PTR [rsp+0x90]
    1901:	test   rsi,0x1
    1908:	je     193a <botlish_fn_13+0x35f>
    190e:	mov    rsi,QWORD PTR [rsp+0x90]
    1916:	mov    rdi,rsi
    1919:	add    rdi,0x4
    191d:	seto   r9b
    1921:	test   r9b,r9b
    1924:	jne    193a <botlish_fn_13+0x35f>
    192a:	mov    rsi,rdi
    192d:	mov    QWORD PTR [rsp+0x90],rdi
    1935:	jmp    195f <botlish_fn_13+0x384>
    193a:	mov    edx,0x5
    193f:	mov    rsi,QWORD PTR [rsp+0x90]
    1947:	mov    rdi,QWORD PTR [rsp+0x88]
    194f:	call   1954 <botlish_fn_13+0x379>
			1950: R_X86_64_PLT32	rt_int_add-0x4
    1954:	mov    rsi,rax
    1957:	mov    QWORD PTR [rsp+0x90],rax
    195f:	mov    QWORD PTR [rsp+0x8],rsi
    1964:	mov    rdi,QWORD PTR [rsp+0x88]
    196c:	mov    rax,QWORD PTR [rdi+0x10]
    1970:	mov    rax,QWORD PTR [rax+0x28]
    1974:	mov    QWORD PTR [rsp+0x18],rax
    1979:	lea    rcx,[rsp+0x38]
    197e:	mov    QWORD PTR [rsp+0x38],0x0
    1987:	mov    QWORD PTR [rsp+0x40],r13
    198c:	mov    QWORD PTR [rsp+0x48],0x0
    1995:	mov    QWORD PTR [rsp+0x50],rax
    199a:	mov    esi,0x2
    199f:	mov    edx,0x4
    19a4:	call   19a9 <botlish_fn_13+0x3ce>
			19a5: R_X86_64_PLT32	rt_construct-0x4
    19a9:	test   rax,rax
    19ac:	jne    19ec <botlish_fn_13+0x411>
    19b2:	xor    rdx,rdx
    19b5:	mov    rax,rdx
    19b8:	mov    rbx,QWORD PTR [rsp+0xa0]
    19c0:	mov    r12,QWORD PTR [rsp+0xa8]
    19c8:	mov    r13,QWORD PTR [rsp+0xb0]
    19d0:	mov    r14,QWORD PTR [rsp+0xb8]
    19d8:	mov    r15,QWORD PTR [rsp+0xc0]
    19e0:	add    rsp,0xd0
    19e7:	mov    rsp,rbp
    19ea:	pop    rbp
    19eb:	ret
    19ec:	mov    QWORD PTR [rsp],r12
    19f0:	mov    rsi,QWORD PTR [rsp+0x90]
    19f8:	mov    QWORD PTR [rsp+0x8],rsi
    19fd:	mov    QWORD PTR [rsp+0x10],rax
    1a02:	mov    r13,rax
    1a05:	jmp    164e <botlish_fn_13+0x73>

0000000000001a0a <botlish_entry_13: scan_quoted<str, int, str>>:
    1a0a:	push   rbp
    1a0b:	mov    rbp,rsp
    1a0e:	ud2

0000000000001a10 <botlish_fn_14: scan_field<str, int>>:
    1a10:	push   rbp
    1a11:	mov    rbp,rsp
    1a14:	sub    rsp,0x50
    1a18:	mov    QWORD PTR [rsp+0x30],rbx
    1a1d:	mov    QWORD PTR [rsp+0x38],r12
    1a22:	mov    QWORD PTR [rsp+0x40],r13
    1a27:	mov    r12,rdi
    1a2a:	mov    r13,rdx
    1a2d:	mov    QWORD PTR [rsp+0x10],0x0
    1a36:	mov    QWORD PTR [rsp],rsi
    1a3a:	mov    rbx,rsi
    1a3d:	mov    QWORD PTR [rsp+0x8],rdx
    1a42:	lea    rcx,[rsp+0x18]
    1a47:	mov    rdx,r13
    1a4a:	mov    rsi,rbx
    1a4d:	mov    rdi,r12
    1a50:	call   1a55 <botlish_fn_14+0x45>
			1a51: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1a55:	test   rax,rax
    1a58:	mov    rsi,rax
    1a5b:	je     1b26 <botlish_fn_14+0x116>
    1a61:	mov    rdx,QWORD PTR [rsp+0x18]
    1a66:	mov    rcx,QWORD PTR [rsp+0x20]
    1a6b:	mov    rdi,r12
    1a6e:	mov    rax,QWORD PTR [rdi+0x10]
    1a72:	mov    r8,QWORD PTR [rax+0x28]
    1a76:	call   1a7b <botlish_fn_14+0x6b>
			1a77: R_X86_64_PLT32	rt_str_region_eq-0x4
    1a7b:	cmp    rax,0x6
    1a7f:	je     1ab7 <botlish_fn_14+0xa7>
    1a85:	mov    rcx,r13
    1a88:	mov    rsi,rbx
    1a8b:	mov    rdi,r12
    1a8e:	mov    rdx,rcx
    1a91:	call   1a96 <botlish_fn_14+0x86>
			1a92: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_unquoted<str, int, int>
    1a96:	test   rax,rax
    1a99:	je     1b26 <botlish_fn_14+0x116>
    1a9f:	mov    rbx,QWORD PTR [rsp+0x30]
    1aa4:	mov    r12,QWORD PTR [rsp+0x38]
    1aa9:	mov    r13,QWORD PTR [rsp+0x40]
    1aae:	add    rsp,0x50
    1ab2:	mov    rsp,rbp
    1ab5:	pop    rbp
    1ab6:	ret
    1ab7:	mov    rcx,r13
    1aba:	mov    QWORD PTR [rsp+0x10],0x3
    1ac3:	test   rcx,0x1
    1aca:	jne    1ad8 <botlish_fn_14+0xc8>
    1ad0:	mov    r13,rcx
    1ad3:	jmp    1aed <botlish_fn_14+0xdd>
    1ad8:	mov    rdx,rcx
    1adb:	add    rdx,0x2
    1adf:	mov    r13,rcx
    1ae2:	seto   al
    1ae5:	test   al,al
    1ae7:	je     1b00 <botlish_fn_14+0xf0>
    1aed:	mov    edx,0x3
    1af2:	mov    rsi,r13
    1af5:	mov    rdi,r12
    1af8:	call   1afd <botlish_fn_14+0xed>
			1af9: R_X86_64_PLT32	rt_int_add-0x4
    1afd:	mov    rdx,rax
    1b00:	mov    QWORD PTR [rsp+0x8],rdx
    1b05:	mov    rdi,r12
    1b08:	mov    rax,QWORD PTR [rdi+0x10]
    1b0c:	mov    rcx,QWORD PTR [rax+0x10]
    1b10:	mov    QWORD PTR [rsp+0x10],rcx
    1b15:	mov    rsi,rbx
    1b18:	call   1b1d <botlish_fn_14+0x10d>
			1b19: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_quoted<str, int, str>
    1b1d:	test   rax,rax
    1b20:	jne    1b44 <botlish_fn_14+0x134>
    1b26:	xor    rdx,rdx
    1b29:	mov    rax,rdx
    1b2c:	mov    rbx,QWORD PTR [rsp+0x30]
    1b31:	mov    r12,QWORD PTR [rsp+0x38]
    1b36:	mov    r13,QWORD PTR [rsp+0x40]
    1b3b:	add    rsp,0x50
    1b3f:	mov    rsp,rbp
    1b42:	pop    rbp
    1b43:	ret
    1b44:	mov    rbx,QWORD PTR [rsp+0x30]
    1b49:	mov    r12,QWORD PTR [rsp+0x38]
    1b4e:	mov    r13,QWORD PTR [rsp+0x40]
    1b53:	add    rsp,0x50
    1b57:	mov    rsp,rbp
    1b5a:	pop    rbp
    1b5b:	ret

0000000000001b5c <botlish_entry_14: scan_field<str, int>>:
    1b5c:	push   rbp
    1b5d:	mov    rbp,rsp
    1b60:	ud2

0000000000001b62 <botlish_fn_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1b62:	push   rbp
    1b63:	mov    rbp,rsp
    1b66:	sub    rsp,0xa0
    1b6d:	mov    QWORD PTR [rsp+0x70],rbx
    1b72:	mov    QWORD PTR [rsp+0x78],r12
    1b77:	mov    QWORD PTR [rsp+0x80],r13
    1b7f:	mov    QWORD PTR [rsp+0x88],r14
    1b87:	mov    QWORD PTR [rsp+0x90],r15
    1b8f:	mov    r13,rdi
    1b92:	mov    QWORD PTR [rsp+0x28],0x0
    1b9b:	mov    QWORD PTR [rsp],rsi
    1b9f:	mov    r15,rsi
    1ba2:	mov    QWORD PTR [rsp+0x8],rdx
    1ba7:	mov    QWORD PTR [rsp+0x10],rcx
    1bac:	mov    QWORD PTR [rsp+0x50],rcx
    1bb1:	mov    QWORD PTR [rsp+0x18],r8
    1bb6:	mov    r12,r8
    1bb9:	mov    QWORD PTR [rsp+0x20],r9
    1bbe:	mov    rbx,r9
    1bc1:	mov    rsi,r15
    1bc4:	mov    rdi,r13
    1bc7:	call   1bcc <botlish_fn_15+0x6a>
			1bc8: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1bcc:	test   rax,rax
    1bcf:	je     1e03 <botlish_fn_15+0x2a1>
    1bd5:	mov    QWORD PTR [rsp+0x8],rax
    1bda:	mov    r8,rax
    1bdd:	mov    QWORD PTR [rsp+0x28],rdx
    1be2:	mov    r14,rdx
    1be5:	lea    r9,[rsp+0x30]
    1bea:	mov    rcx,rbx
    1bed:	mov    rdx,r12
    1bf0:	mov    rsi,QWORD PTR [rsp+0x50]
    1bf5:	mov    rdi,r13
    1bf8:	call   1bfd <botlish_fn_15+0x9b>
			1bf9: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<list[List[never], mutarray, int], str>
    1bfd:	test   rax,rax
    1c00:	je     1e03 <botlish_fn_15+0x2a1>
    1c06:	mov    QWORD PTR [rsp+0x8],rax
    1c0b:	mov    QWORD PTR [rsp+0x68],rax
    1c10:	mov    rdx,QWORD PTR [rsp+0x30]
    1c15:	mov    QWORD PTR [rsp+0x10],rdx
    1c1a:	mov    QWORD PTR [rsp+0x60],rdx
    1c1f:	mov    rcx,QWORD PTR [rsp+0x38]
    1c24:	mov    QWORD PTR [rsp+0x18],rcx
    1c29:	mov    QWORD PTR [rsp+0x58],rcx
    1c2e:	lea    rcx,[rsp+0x40]
    1c33:	mov    rdx,r14
    1c36:	mov    rsi,r15
    1c39:	mov    rdi,r13
    1c3c:	call   1c41 <botlish_fn_15+0xdf>
			1c3d: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1c41:	test   rax,rax
    1c44:	mov    QWORD PTR [rsp+0x50],rax
    1c49:	je     1e03 <botlish_fn_15+0x2a1>
    1c4f:	mov    r12,QWORD PTR [rsp+0x40]
    1c54:	mov    rbx,QWORD PTR [rsp+0x48]
    1c59:	mov    rdi,r13
    1c5c:	mov    rcx,QWORD PTR [rdi+0x10]
    1c60:	mov    r8,QWORD PTR [rcx+0x18]
    1c64:	mov    rcx,rbx
    1c67:	mov    rdx,r12
    1c6a:	mov    rsi,QWORD PTR [rsp+0x50]
    1c6f:	call   1c74 <botlish_fn_15+0x112>
			1c70: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c74:	cmp    rax,0x6
    1c78:	je     1d92 <botlish_fn_15+0x230>
    1c7e:	mov    rdi,r13
    1c81:	mov    rax,QWORD PTR [rdi+0x10]
    1c85:	mov    r8,QWORD PTR [rax+0x20]
    1c89:	mov    rcx,rbx
    1c8c:	mov    rdx,r12
    1c8f:	mov    rsi,QWORD PTR [rsp+0x50]
    1c94:	call   1c99 <botlish_fn_15+0x137>
			1c95: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c99:	cmp    rax,0x6
    1c9d:	je     1cf4 <botlish_fn_15+0x192>
    1ca3:	mov    rcx,QWORD PTR [rsp+0x58]
    1ca8:	mov    rdx,QWORD PTR [rsp+0x60]
    1cad:	mov    rsi,QWORD PTR [rsp+0x68]
    1cb2:	mov    rdi,r13
    1cb5:	call   1cba <botlish_fn_15+0x158>
			1cb6: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1cba:	test   rax,rax
    1cbd:	je     1e03 <botlish_fn_15+0x2a1>
    1cc3:	mov    rdx,r14
    1cc6:	mov    rbx,QWORD PTR [rsp+0x70]
    1ccb:	mov    r12,QWORD PTR [rsp+0x78]
    1cd0:	mov    r13,QWORD PTR [rsp+0x80]
    1cd8:	mov    r14,QWORD PTR [rsp+0x88]
    1ce0:	mov    r15,QWORD PTR [rsp+0x90]
    1ce8:	add    rsp,0xa0
    1cef:	mov    rsp,rbp
    1cf2:	pop    rbp
    1cf3:	ret
    1cf4:	mov    rcx,QWORD PTR [rsp+0x58]
    1cf9:	mov    rdx,QWORD PTR [rsp+0x60]
    1cfe:	mov    rsi,QWORD PTR [rsp+0x68]
    1d03:	mov    rdi,r13
    1d06:	call   1d0b <botlish_fn_15+0x1a9>
			1d07: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1d0b:	test   rax,rax
    1d0e:	je     1e03 <botlish_fn_15+0x2a1>
    1d14:	mov    QWORD PTR [rsp],rax
    1d18:	mov    rbx,rax
    1d1b:	mov    QWORD PTR [rsp+0x8],0x3
    1d24:	mov    rdx,r14
    1d27:	test   rdx,0x1
    1d2e:	je     1d4e <botlish_fn_15+0x1ec>
    1d34:	mov    rdx,r14
    1d37:	add    rdx,0x2
    1d3b:	seto   al
    1d3e:	test   al,al
    1d40:	jne    1d4e <botlish_fn_15+0x1ec>
    1d46:	mov    rax,rbx
    1d49:	jmp    1d64 <botlish_fn_15+0x202>
    1d4e:	mov    edx,0x3
    1d53:	mov    rsi,r14
    1d56:	mov    rdi,r13
    1d59:	call   1d5e <botlish_fn_15+0x1fc>
			1d5a: R_X86_64_PLT32	rt_int_add-0x4
    1d5e:	mov    rdx,rax
    1d61:	mov    rax,rbx
    1d64:	mov    rbx,QWORD PTR [rsp+0x70]
    1d69:	mov    r12,QWORD PTR [rsp+0x78]
    1d6e:	mov    r13,QWORD PTR [rsp+0x80]
    1d76:	mov    r14,QWORD PTR [rsp+0x88]
    1d7e:	mov    r15,QWORD PTR [rsp+0x90]
    1d86:	add    rsp,0xa0
    1d8d:	mov    rsp,rbp
    1d90:	pop    rbp
    1d91:	ret
    1d92:	mov    rsi,r14
    1d95:	mov    edx,0x3
    1d9a:	mov    rcx,rdx
    1d9d:	mov    QWORD PTR [rsp+0x20],0x3
    1da6:	test   rsi,0x1
    1dad:	jne    1dbb <botlish_fn_15+0x259>
    1db3:	mov    rdx,rcx
    1db6:	jmp    1dd0 <botlish_fn_15+0x26e>
    1dbb:	mov    rdx,rsi
    1dbe:	add    rdx,0x2
    1dc2:	seto   al
    1dc5:	test   al,al
    1dc7:	je     1ddb <botlish_fn_15+0x279>
    1dcd:	mov    rdx,rcx
    1dd0:	mov    rdi,r13
    1dd3:	call   1dd8 <botlish_fn_15+0x276>
			1dd4: R_X86_64_PLT32	rt_int_add-0x4
    1dd8:	mov    rdx,rax
    1ddb:	mov    QWORD PTR [rsp+0x20],rdx
    1de0:	mov    rcx,QWORD PTR [rsp+0x68]
    1de5:	mov    rsi,r15
    1de8:	mov    rdi,r13
    1deb:	mov    r8,QWORD PTR [rsp+0x60]
    1df0:	mov    r9,QWORD PTR [rsp+0x58]
    1df5:	call   1dfa <botlish_fn_15+0x298>
			1df6: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[List[mutarray], mutarray, int]>
    1dfa:	test   rax,rax
    1dfd:	jne    1e37 <botlish_fn_15+0x2d5>
    1e03:	xor    rdx,rdx
    1e06:	mov    rax,rdx
    1e09:	mov    rbx,QWORD PTR [rsp+0x70]
    1e0e:	mov    r12,QWORD PTR [rsp+0x78]
    1e13:	mov    r13,QWORD PTR [rsp+0x80]
    1e1b:	mov    r14,QWORD PTR [rsp+0x88]
    1e23:	mov    r15,QWORD PTR [rsp+0x90]
    1e2b:	add    rsp,0xa0
    1e32:	mov    rsp,rbp
    1e35:	pop    rbp
    1e36:	ret
    1e37:	mov    rbx,QWORD PTR [rsp+0x70]
    1e3c:	mov    r12,QWORD PTR [rsp+0x78]
    1e41:	mov    r13,QWORD PTR [rsp+0x80]
    1e49:	mov    r14,QWORD PTR [rsp+0x88]
    1e51:	mov    r15,QWORD PTR [rsp+0x90]
    1e59:	add    rsp,0xa0
    1e60:	mov    rsp,rbp
    1e63:	pop    rbp
    1e64:	ret

0000000000001e65 <botlish_entry_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1e65:	push   rbp
    1e66:	mov    rbp,rsp
    1e69:	ud2

0000000000001e6b <botlish_fn_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    1e6b:	push   rbp
    1e6c:	mov    rbp,rsp
    1e6f:	sub    rsp,0xb0
    1e76:	mov    QWORD PTR [rsp+0x80],rbx
    1e7e:	mov    QWORD PTR [rsp+0x88],r12
    1e86:	mov    QWORD PTR [rsp+0x90],r13
    1e8e:	mov    QWORD PTR [rsp+0x98],r14
    1e96:	mov    QWORD PTR [rsp+0xa0],r15
    1e9e:	mov    QWORD PTR [rsp+0x50],rdi
    1ea3:	mov    QWORD PTR [rsp+0x28],0x0
    1eac:	mov    QWORD PTR [rsp],rsi
    1eb0:	mov    QWORD PTR [rsp+0x8],rdx
    1eb5:	mov    QWORD PTR [rsp+0x10],rcx
    1eba:	mov    QWORD PTR [rsp+0x18],r8
    1ebf:	mov    QWORD PTR [rsp+0x20],r9
    1ec4:	lea    r15,[rsp+0x30]
    1ec9:	lea    rbx,[rsp+0x40]
    1ece:	mov    r12,rsi
    1ed1:	mov    r13,rcx
    1ed4:	mov    QWORD PTR [rsp+0x58],r8
    1ed9:	mov    QWORD PTR [rsp+0x60],r9
    1ede:	mov    rsi,r12
    1ee1:	mov    rdi,QWORD PTR [rsp+0x50]
    1ee6:	call   1eeb <botlish_fn_16+0x80>
			1ee7: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1eeb:	mov    QWORD PTR [rsp+0x78],rdx
    1ef0:	test   rax,rax
    1ef3:	je     204e <botlish_fn_16+0x1e3>
    1ef9:	mov    QWORD PTR [rsp+0x8],rax
    1efe:	mov    rdx,QWORD PTR [rsp+0x78]
    1f03:	mov    r8,rax
    1f06:	mov    QWORD PTR [rsp+0x28],rdx
    1f0b:	mov    rcx,QWORD PTR [rsp+0x60]
    1f10:	mov    rdx,QWORD PTR [rsp+0x58]
    1f15:	mov    rsi,r13
    1f18:	mov    rdi,QWORD PTR [rsp+0x50]
    1f1d:	mov    r9,r15
    1f20:	call   1f25 <botlish_fn_16+0xba>
			1f21: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[List[mutarray], mutarray, int], str>
    1f25:	test   rax,rax
    1f28:	je     204e <botlish_fn_16+0x1e3>
    1f2e:	mov    QWORD PTR [rsp+0x8],rax
    1f33:	mov    QWORD PTR [rsp+0x70],rax
    1f38:	mov    rdx,QWORD PTR [rsp+0x30]
    1f3d:	mov    QWORD PTR [rsp+0x58],rdx
    1f42:	mov    QWORD PTR [rsp+0x10],rdx
    1f47:	mov    rcx,QWORD PTR [rsp+0x38]
    1f4c:	mov    QWORD PTR [rsp+0x18],rcx
    1f51:	mov    QWORD PTR [rsp+0x60],rcx
    1f56:	mov    rcx,rbx
    1f59:	mov    rdx,QWORD PTR [rsp+0x78]
    1f5e:	mov    rsi,r12
    1f61:	mov    rdi,QWORD PTR [rsp+0x50]
    1f66:	call   1f6b <botlish_fn_16+0x100>
			1f67: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1f6b:	test   rax,rax
    1f6e:	mov    QWORD PTR [rsp+0x68],rax
    1f73:	je     204e <botlish_fn_16+0x1e3>
    1f79:	mov    r13,QWORD PTR [rsp+0x40]
    1f7e:	mov    r14,QWORD PTR [rsp+0x48]
    1f83:	mov    rdi,QWORD PTR [rsp+0x50]
    1f88:	mov    rcx,QWORD PTR [rdi+0x10]
    1f8c:	mov    r8,QWORD PTR [rcx+0x18]
    1f90:	mov    rcx,r14
    1f93:	mov    rdx,r13
    1f96:	mov    rsi,QWORD PTR [rsp+0x68]
    1f9b:	call   1fa0 <botlish_fn_16+0x135>
			1f9c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1fa0:	cmp    rax,0x6
    1fa4:	je     2114 <botlish_fn_16+0x2a9>
    1faa:	mov    rdi,QWORD PTR [rsp+0x50]
    1faf:	mov    rax,QWORD PTR [rdi+0x10]
    1fb3:	mov    r8,QWORD PTR [rax+0x20]
    1fb7:	mov    rcx,r14
    1fba:	mov    rdx,r13
    1fbd:	mov    rsi,QWORD PTR [rsp+0x68]
    1fc2:	call   1fc7 <botlish_fn_16+0x15c>
			1fc3: R_X86_64_PLT32	rt_str_region_eq-0x4
    1fc7:	cmp    rax,0x6
    1fcb:	je     202c <botlish_fn_16+0x1c1>
    1fd1:	mov    rcx,QWORD PTR [rsp+0x60]
    1fd6:	mov    rdx,QWORD PTR [rsp+0x58]
    1fdb:	mov    rsi,QWORD PTR [rsp+0x70]
    1fe0:	mov    rdi,QWORD PTR [rsp+0x50]
    1fe5:	call   1fea <botlish_fn_16+0x17f>
			1fe6: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1fea:	test   rax,rax
    1fed:	je     204e <botlish_fn_16+0x1e3>
    1ff3:	mov    rdx,QWORD PTR [rsp+0x78]
    1ff8:	mov    rbx,QWORD PTR [rsp+0x80]
    2000:	mov    r12,QWORD PTR [rsp+0x88]
    2008:	mov    r13,QWORD PTR [rsp+0x90]
    2010:	mov    r14,QWORD PTR [rsp+0x98]
    2018:	mov    r15,QWORD PTR [rsp+0xa0]
    2020:	add    rsp,0xb0
    2027:	mov    rsp,rbp
    202a:	pop    rbp
    202b:	ret
    202c:	mov    rcx,QWORD PTR [rsp+0x60]
    2031:	mov    rdx,QWORD PTR [rsp+0x58]
    2036:	mov    rsi,QWORD PTR [rsp+0x70]
    203b:	mov    rdi,QWORD PTR [rsp+0x50]
    2040:	call   2045 <botlish_fn_16+0x1da>
			2041: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    2045:	test   rax,rax
    2048:	jne    2088 <botlish_fn_16+0x21d>
    204e:	xor    rdx,rdx
    2051:	mov    rax,rdx
    2054:	mov    rbx,QWORD PTR [rsp+0x80]
    205c:	mov    r12,QWORD PTR [rsp+0x88]
    2064:	mov    r13,QWORD PTR [rsp+0x90]
    206c:	mov    r14,QWORD PTR [rsp+0x98]
    2074:	mov    r15,QWORD PTR [rsp+0xa0]
    207c:	add    rsp,0xb0
    2083:	mov    rsp,rbp
    2086:	pop    rbp
    2087:	ret
    2088:	mov    QWORD PTR [rsp],rax
    208c:	mov    rbx,rax
    208f:	mov    QWORD PTR [rsp+0x8],0x3
    2098:	mov    rdx,QWORD PTR [rsp+0x78]
    209d:	test   rdx,0x1
    20a4:	je     20c6 <botlish_fn_16+0x25b>
    20aa:	mov    rdx,QWORD PTR [rsp+0x78]
    20af:	add    rdx,0x2
    20b3:	seto   al
    20b6:	test   al,al
    20b8:	jne    20c6 <botlish_fn_16+0x25b>
    20be:	mov    rax,rbx
    20c1:	jmp    20e0 <botlish_fn_16+0x275>
    20c6:	mov    edx,0x3
    20cb:	mov    rsi,QWORD PTR [rsp+0x78]
    20d0:	mov    rdi,QWORD PTR [rsp+0x50]
    20d5:	call   20da <botlish_fn_16+0x26f>
			20d6: R_X86_64_PLT32	rt_int_add-0x4
    20da:	mov    rdx,rax
    20dd:	mov    rax,rbx
    20e0:	mov    rbx,QWORD PTR [rsp+0x80]
    20e8:	mov    r12,QWORD PTR [rsp+0x88]
    20f0:	mov    r13,QWORD PTR [rsp+0x90]
    20f8:	mov    r14,QWORD PTR [rsp+0x98]
    2100:	mov    r15,QWORD PTR [rsp+0xa0]
    2108:	add    rsp,0xb0
    210f:	mov    rsp,rbp
    2112:	pop    rbp
    2113:	ret
    2114:	mov    rsi,QWORD PTR [rsp+0x78]
    2119:	mov    edx,0x3
    211e:	mov    r10,rdx
    2121:	mov    QWORD PTR [rsp+0x20],0x3
    212a:	test   rsi,0x1
    2131:	jne    213f <botlish_fn_16+0x2d4>
    2137:	mov    rdx,r10
    213a:	jmp    2154 <botlish_fn_16+0x2e9>
    213f:	mov    rdx,rsi
    2142:	add    rdx,0x2
    2146:	seto   al
    2149:	test   al,al
    214b:	je     2161 <botlish_fn_16+0x2f6>
    2151:	mov    rdx,r10
    2154:	mov    rdi,QWORD PTR [rsp+0x50]
    2159:	call   215e <botlish_fn_16+0x2f3>
			215a: R_X86_64_PLT32	rt_int_add-0x4
    215e:	mov    rdx,rax
    2161:	mov    QWORD PTR [rsp],r12
    2165:	mov    QWORD PTR [rsp+0x8],rdx
    216a:	mov    rsi,QWORD PTR [rsp+0x70]
    216f:	mov    QWORD PTR [rsp+0x10],rsi
    2174:	mov    rax,QWORD PTR [rsp+0x58]
    2179:	mov    QWORD PTR [rsp+0x18],rax
    217e:	mov    rcx,QWORD PTR [rsp+0x60]
    2183:	mov    QWORD PTR [rsp+0x20],rcx
    2188:	mov    r13,rsi
    218b:	jmp    1ede <botlish_fn_16+0x73>

0000000000002190 <botlish_entry_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    2190:	push   rbp
    2191:	mov    rbp,rsp
    2194:	ud2

0000000000002196 <botlish_fn_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    2196:	push   rbp
    2197:	mov    rbp,rsp
    219a:	sub    rsp,0xa0
    21a1:	mov    QWORD PTR [rsp+0x70],rbx
    21a6:	mov    QWORD PTR [rsp+0x78],r12
    21ab:	mov    QWORD PTR [rsp+0x80],r13
    21b3:	mov    QWORD PTR [rsp+0x88],r14
    21bb:	mov    QWORD PTR [rsp+0x90],r15
    21c3:	mov    r12,rdi
    21c6:	mov    QWORD PTR [rsp+0x28],0x0
    21cf:	mov    QWORD PTR [rsp+0x30],0x0
    21d8:	mov    QWORD PTR [rsp+0x38],0x0
    21e1:	mov    QWORD PTR [rsp],rsi
    21e5:	mov    QWORD PTR [rsp+0x8],rdx
    21ea:	mov    QWORD PTR [rsp+0x10],rcx
    21ef:	mov    r15,rcx
    21f2:	mov    QWORD PTR [rsp+0x18],r8
    21f7:	mov    r14,r8
    21fa:	mov    QWORD PTR [rsp+0x20],r9
    21ff:	mov    r13,r9
    2202:	mov    rax,QWORD PTR [rsi+0x8]
    2206:	mov    rbx,rsi
    2209:	mov    rcx,rdx
    220c:	sar    rcx,1
    220f:	mov    QWORD PTR [rsp+0x60],rdx
    2214:	shl    rax,1
    2217:	or     rax,0x1
    221b:	sar    rax,1
    221e:	cmp    rcx,rax
    2221:	jge    2306 <botlish_fn_17+0x170>
    2227:	lea    rsi,[rsp+0x40]
    222c:	mov    rdi,r12
    222f:	call   2234 <botlish_fn_17+0x9e>
			2230: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2234:	test   rax,rax
    2237:	je     2320 <botlish_fn_17+0x18a>
    223d:	mov    QWORD PTR [rsp+0x28],rax
    2242:	mov    rcx,rax
    2245:	mov    r8,QWORD PTR [rsp+0x40]
    224a:	mov    QWORD PTR [rsp+0x30],r8
    224f:	mov    r9,QWORD PTR [rsp+0x48]
    2254:	mov    QWORD PTR [rsp+0x38],r9
    2259:	mov    rdx,QWORD PTR [rsp+0x60]
    225e:	mov    rsi,rbx
    2261:	mov    rdi,r12
    2264:	call   2269 <botlish_fn_17+0xd3>
			2265: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    2269:	test   rax,rax
    226c:	je     2320 <botlish_fn_17+0x18a>
    2272:	mov    QWORD PTR [rsp+0x8],rax
    2277:	mov    r8,rax
    227a:	mov    QWORD PTR [rsp+0x28],rdx
    227f:	mov    QWORD PTR [rsp+0x60],rdx
    2284:	lea    r9,[rsp+0x50]
    2289:	mov    rcx,r13
    228c:	mov    rdx,r14
    228f:	mov    rsi,r15
    2292:	mov    rdi,r12
    2295:	call   229a <botlish_fn_17+0x104>
			2296: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[List[never], mutarray, int], list>
    229a:	test   rax,rax
    229d:	je     2320 <botlish_fn_17+0x18a>
    22a3:	mov    QWORD PTR [rsp+0x8],rax
    22a8:	mov    rcx,rax
    22ab:	mov    r8,QWORD PTR [rsp+0x50]
    22b0:	mov    QWORD PTR [rsp+0x10],r8
    22b5:	mov    r9,QWORD PTR [rsp+0x58]
    22ba:	mov    QWORD PTR [rsp+0x18],r9
    22bf:	mov    rdx,QWORD PTR [rsp+0x60]
    22c4:	mov    rsi,rbx
    22c7:	mov    rdi,r12
    22ca:	call   22cf <botlish_fn_17+0x139>
			22cb: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    22cf:	test   rax,rax
    22d2:	je     2320 <botlish_fn_17+0x18a>
    22d8:	mov    rbx,QWORD PTR [rsp+0x70]
    22dd:	mov    r12,QWORD PTR [rsp+0x78]
    22e2:	mov    r13,QWORD PTR [rsp+0x80]
    22ea:	mov    r14,QWORD PTR [rsp+0x88]
    22f2:	mov    r15,QWORD PTR [rsp+0x90]
    22fa:	add    rsp,0xa0
    2301:	mov    rsp,rbp
    2304:	pop    rbp
    2305:	ret
    2306:	mov    rcx,r13
    2309:	mov    rdx,r14
    230c:	mov    rsi,r15
    230f:	mov    rdi,r12
    2312:	call   2317 <botlish_fn_17+0x181>
			2313: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[List[never], mutarray, int]>
    2317:	test   rax,rax
    231a:	jne    2351 <botlish_fn_17+0x1bb>
    2320:	xor    rax,rax
    2323:	mov    rbx,QWORD PTR [rsp+0x70]
    2328:	mov    r12,QWORD PTR [rsp+0x78]
    232d:	mov    r13,QWORD PTR [rsp+0x80]
    2335:	mov    r14,QWORD PTR [rsp+0x88]
    233d:	mov    r15,QWORD PTR [rsp+0x90]
    2345:	add    rsp,0xa0
    234c:	mov    rsp,rbp
    234f:	pop    rbp
    2350:	ret
    2351:	mov    rbx,QWORD PTR [rsp+0x70]
    2356:	mov    r12,QWORD PTR [rsp+0x78]
    235b:	mov    r13,QWORD PTR [rsp+0x80]
    2363:	mov    r14,QWORD PTR [rsp+0x88]
    236b:	mov    r15,QWORD PTR [rsp+0x90]
    2373:	add    rsp,0xa0
    237a:	mov    rsp,rbp
    237d:	pop    rbp
    237e:	ret

000000000000237f <botlish_entry_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    237f:	push   rbp
    2380:	mov    rbp,rsp
    2383:	mov    rsi,QWORD PTR [rdx]
    2386:	mov    r10,QWORD PTR [rdx+0x8]
    238a:	mov    rcx,QWORD PTR [rdx+0x10]
    238e:	mov    r8,QWORD PTR [rdx+0x18]
    2392:	mov    r9,QWORD PTR [rdx+0x20]
    2396:	mov    rdx,r10
    2399:	call   239e <botlish_entry_17+0x1f>
			239a: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    239e:	mov    rsp,rbp
    23a1:	pop    rbp
    23a2:	ret
    23a3:	add    BYTE PTR [rax],al
    23a5:	add    BYTE PTR [rax],al
	...

00000000000023a8 <botlish_fn_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    23a8:	push   rbp
    23a9:	mov    rbp,rsp
    23ac:	sub    rsp,0xb0
    23b3:	mov    QWORD PTR [rsp+0x80],rbx
    23bb:	mov    QWORD PTR [rsp+0x88],r12
    23c3:	mov    QWORD PTR [rsp+0x90],r13
    23cb:	mov    QWORD PTR [rsp+0x98],r14
    23d3:	mov    QWORD PTR [rsp+0xa0],r15
    23db:	mov    r15,rdi
    23de:	mov    QWORD PTR [rsp+0x28],0x0
    23e7:	mov    QWORD PTR [rsp+0x30],0x0
    23f0:	mov    QWORD PTR [rsp+0x38],0x0
    23f9:	mov    QWORD PTR [rsp],rsi
    23fd:	mov    QWORD PTR [rsp+0x8],rdx
    2402:	mov    r14,rdx
    2405:	mov    QWORD PTR [rsp+0x10],rcx
    240a:	mov    QWORD PTR [rsp+0x18],r8
    240f:	mov    QWORD PTR [rsp+0x20],r9
    2414:	lea    r13,[rsp+0x40]
    2419:	lea    rbx,[rsp+0x50]
    241e:	mov    r12,rsi
    2421:	mov    QWORD PTR [rsp+0x60],rcx
    2426:	mov    QWORD PTR [rsp+0x68],r8
    242b:	mov    QWORD PTR [rsp+0x70],r9
    2430:	mov    rdx,QWORD PTR [r12+0x8]
    2435:	shl    rdx,1
    2438:	or     rdx,0x1
    243c:	mov    rax,r14
    243f:	and    rax,rdx
    2442:	test   rax,0x1
    2448:	jne    246e <botlish_fn_18+0xc6>
    244e:	mov    rsi,r14
    2451:	mov    rdi,r15
    2454:	call   2459 <botlish_fn_18+0xb1>
			2455: R_X86_64_PLT32	rt_int_cmp-0x4
    2459:	mov    ecx,0x2
    245e:	test   rax,rax
    2461:	cmovge rcx,QWORD PTR [rip+0x167]        # 25d0 <botlish_fn_18+0x228>
    2469:	jmp    2481 <botlish_fn_18+0xd9>
    246e:	mov    ecx,0x2
    2473:	mov    r11,r14
    2476:	cmp    r11,rdx
    2479:	cmovge rcx,QWORD PTR [rip+0x14f]        # 25d0 <botlish_fn_18+0x228>
    2481:	cmp    rcx,0x6
    2485:	je     253e <botlish_fn_18+0x196>
    248b:	mov    rsi,r13
    248e:	mov    rdi,r15
    2491:	call   2496 <botlish_fn_18+0xee>
			2492: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2496:	test   rax,rax
    2499:	je     255e <botlish_fn_18+0x1b6>
    249f:	mov    QWORD PTR [rsp+0x28],rax
    24a4:	mov    rcx,rax
    24a7:	mov    r8,QWORD PTR [rsp+0x40]
    24ac:	mov    QWORD PTR [rsp+0x30],r8
    24b1:	mov    r9,QWORD PTR [rsp+0x48]
    24b6:	mov    QWORD PTR [rsp+0x38],r9
    24bb:	mov    rdx,r14
    24be:	mov    rsi,r12
    24c1:	mov    rdi,r15
    24c4:	call   24c9 <botlish_fn_18+0x121>
			24c5: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    24c9:	test   rax,rax
    24cc:	je     255e <botlish_fn_18+0x1b6>
    24d2:	mov    QWORD PTR [rsp+0x8],rax
    24d7:	mov    r8,rax
    24da:	mov    QWORD PTR [rsp+0x28],rdx
    24df:	mov    r14,rdx
    24e2:	mov    rsi,QWORD PTR [rsp+0x60]
    24e7:	mov    rdx,QWORD PTR [rsp+0x68]
    24ec:	mov    rcx,QWORD PTR [rsp+0x70]
    24f1:	mov    rdi,r15
    24f4:	mov    r9,rbx
    24f7:	call   24fc <botlish_fn_18+0x154>
			24f8: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[List[mutarray], mutarray, int], list>
    24fc:	test   rax,rax
    24ff:	je     255e <botlish_fn_18+0x1b6>
    2505:	mov    rdx,QWORD PTR [rsp+0x50]
    250a:	mov    rcx,QWORD PTR [rsp+0x58]
    250f:	mov    QWORD PTR [rsp],r12
    2513:	mov    rsi,r14
    2516:	mov    QWORD PTR [rsp+0x8],rsi
    251b:	mov    QWORD PTR [rsp+0x10],rax
    2520:	mov    QWORD PTR [rsp+0x18],rdx
    2525:	mov    QWORD PTR [rsp+0x20],rcx
    252a:	mov    QWORD PTR [rsp+0x60],rax
    252f:	mov    QWORD PTR [rsp+0x68],rdx
    2534:	mov    QWORD PTR [rsp+0x70],rcx
    2539:	jmp    2430 <botlish_fn_18+0x88>
    253e:	mov    rcx,QWORD PTR [rsp+0x70]
    2543:	mov    rdx,QWORD PTR [rsp+0x68]
    2548:	mov    rsi,QWORD PTR [rsp+0x60]
    254d:	mov    rdi,r15
    2550:	call   2555 <botlish_fn_18+0x1ad>
			2551: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    2555:	test   rax,rax
    2558:	jne    2595 <botlish_fn_18+0x1ed>
    255e:	xor    rax,rax
    2561:	mov    rbx,QWORD PTR [rsp+0x80]
    2569:	mov    r12,QWORD PTR [rsp+0x88]
    2571:	mov    r13,QWORD PTR [rsp+0x90]
    2579:	mov    r14,QWORD PTR [rsp+0x98]
    2581:	mov    r15,QWORD PTR [rsp+0xa0]
    2589:	add    rsp,0xb0
    2590:	mov    rsp,rbp
    2593:	pop    rbp
    2594:	ret
    2595:	mov    rbx,QWORD PTR [rsp+0x80]
    259d:	mov    r12,QWORD PTR [rsp+0x88]
    25a5:	mov    r13,QWORD PTR [rsp+0x90]
    25ad:	mov    r14,QWORD PTR [rsp+0x98]
    25b5:	mov    r15,QWORD PTR [rsp+0xa0]
    25bd:	add    rsp,0xb0
    25c4:	mov    rsp,rbp
    25c7:	pop    rbp
    25c8:	ret
    25c9:	add    BYTE PTR [rax],al
    25cb:	add    BYTE PTR [rax],al
    25cd:	add    BYTE PTR [rax],al
    25cf:	add    BYTE PTR [rsi],al
    25d1:	add    BYTE PTR [rax],al
    25d3:	add    BYTE PTR [rax],al
    25d5:	add    BYTE PTR [rax],al
	...

00000000000025d8 <botlish_entry_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    25d8:	push   rbp
    25d9:	mov    rbp,rsp
    25dc:	mov    rsi,QWORD PTR [rdx]
    25df:	mov    r10,QWORD PTR [rdx+0x8]
    25e3:	mov    rcx,QWORD PTR [rdx+0x10]
    25e7:	mov    r8,QWORD PTR [rdx+0x18]
    25eb:	mov    r9,QWORD PTR [rdx+0x20]
    25ef:	mov    rdx,r10
    25f2:	call   25f7 <botlish_entry_18+0x1f>
			25f3: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    25f7:	mov    rsp,rbp
    25fa:	pop    rbp
    25fb:	ret

00000000000025fc <botlish_fn_19: csv_parse<str>>:
    25fc:	push   rbp
    25fd:	mov    rbp,rsp
    2600:	sub    rsp,0x50
    2604:	mov    QWORD PTR [rsp+0x40],r12
    2609:	mov    QWORD PTR [rsp+0x48],r13
    260e:	mov    r13,rdi
    2611:	mov    QWORD PTR [rsp+0x10],0x0
    261a:	mov    QWORD PTR [rsp+0x18],0x0
    2623:	mov    QWORD PTR [rsp+0x20],0x0
    262c:	mov    QWORD PTR [rsp],rsi
    2630:	mov    r12,rsi
    2633:	mov    QWORD PTR [rsp+0x8],0x1
    263c:	lea    rsi,[rsp+0x28]
    2641:	mov    rdi,r13
    2644:	call   2649 <botlish_fn_19+0x4d>
			2645: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2649:	test   rax,rax
    264c:	je     2687 <botlish_fn_19+0x8b>
    2652:	mov    QWORD PTR [rsp+0x10],rax
    2657:	mov    rcx,rax
    265a:	mov    r8,QWORD PTR [rsp+0x28]
    265f:	mov    QWORD PTR [rsp+0x18],r8
    2664:	mov    r9,QWORD PTR [rsp+0x30]
    2669:	mov    QWORD PTR [rsp+0x20],r9
    266e:	mov    edx,0x1
    2673:	mov    rsi,r12
    2676:	mov    rdi,r13
    2679:	call   267e <botlish_fn_19+0x82>
			267a: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    267e:	test   rax,rax
    2681:	jne    269d <botlish_fn_19+0xa1>
    2687:	xor    rax,rax
    268a:	mov    r12,QWORD PTR [rsp+0x40]
    268f:	mov    r13,QWORD PTR [rsp+0x48]
    2694:	add    rsp,0x50
    2698:	mov    rsp,rbp
    269b:	pop    rbp
    269c:	ret
    269d:	mov    r12,QWORD PTR [rsp+0x40]
    26a2:	mov    r13,QWORD PTR [rsp+0x48]
    26a7:	add    rsp,0x50
    26ab:	mov    rsp,rbp
    26ae:	pop    rbp
    26af:	ret

00000000000026b0 <botlish_entry_19: csv_parse<str>>:
    26b0:	push   rbp
    26b1:	mov    rbp,rsp
    26b4:	mov    rsi,QWORD PTR [rdx]
    26b7:	call   26bc <botlish_entry_19+0xc>
			26b8: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    26bc:	mov    rsp,rbp
    26bf:	pop    rbp
    26c0:	ret

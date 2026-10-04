; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10490  (per function: 312 195 534 534 534 534 498 418 540 540 365 430 585 1141 352 799 833 537 612 197)
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
    10c7:	mov    r13,rdi
    10ca:	mov    QWORD PTR [rsp],rsi
    10ce:	mov    r12,rsi
    10d1:	mov    QWORD PTR [rsp+0x8],rdx
    10d6:	mov    rbx,rdx
    10d9:	mov    rsi,r12
    10dc:	mov    rdi,r13
    10df:	call   10e4 <botlish_fn_10+0x34>
			10e0: R_X86_64_PLT32	rt_str_len-0x4
    10e4:	mov    rcx,rbx
    10e7:	and    rcx,rax
    10ea:	mov    rdx,rax
    10ed:	test   rcx,0x1
    10f4:	jne    111a <botlish_fn_10+0x6a>
    10fa:	mov    rsi,rbx
    10fd:	mov    rdi,r13
    1100:	call   1105 <botlish_fn_10+0x55>
			1101: R_X86_64_PLT32	rt_int_cmp-0x4
    1105:	mov    ecx,0x2
    110a:	test   rax,rax
    110d:	cmovge rcx,QWORD PTR [rip+0xd3]        # 11e8 <botlish_fn_10+0x138>
    1115:	jmp    112a <botlish_fn_10+0x7a>
    111a:	mov    ecx,0x2
    111f:	cmp    rbx,rdx
    1122:	cmovge rcx,QWORD PTR [rip+0xbe]        # 11e8 <botlish_fn_10+0x138>
    112a:	cmp    rcx,0x6
    112e:	je     11be <botlish_fn_10+0x10e>
    1134:	mov    QWORD PTR [rsp+0x10],0x3
    113d:	test   rbx,0x1
    1144:	je     115c <botlish_fn_10+0xac>
    114a:	mov    rcx,rbx
    114d:	add    rcx,0x2
    1151:	seto   al
    1154:	test   al,al
    1156:	je     116f <botlish_fn_10+0xbf>
    115c:	mov    edx,0x3
    1161:	mov    rsi,rbx
    1164:	mov    rdi,r13
    1167:	call   116c <botlish_fn_10+0xbc>
			1168: R_X86_64_PLT32	rt_int_add-0x4
    116c:	mov    rcx,rax
    116f:	mov    QWORD PTR [rsp+0x10],rcx
    1174:	mov    rdx,rbx
    1177:	mov    rsi,r12
    117a:	mov    rdi,r13
    117d:	call   1182 <botlish_fn_10+0xd2>
			117e: R_X86_64_PLT32	rt_substr-0x4
    1182:	test   rax,rax
    1185:	jne    11a6 <botlish_fn_10+0xf6>
    118b:	xor    rax,rax
    118e:	mov    rbx,QWORD PTR [rsp+0x20]
    1193:	mov    r12,QWORD PTR [rsp+0x28]
    1198:	mov    r13,QWORD PTR [rsp+0x30]
    119d:	add    rsp,0x40
    11a1:	mov    rsp,rbp
    11a4:	pop    rbp
    11a5:	ret
    11a6:	mov    rbx,QWORD PTR [rsp+0x20]
    11ab:	mov    r12,QWORD PTR [rsp+0x28]
    11b0:	mov    r13,QWORD PTR [rsp+0x30]
    11b5:	add    rsp,0x40
    11b9:	mov    rsp,rbp
    11bc:	pop    rbp
    11bd:	ret
    11be:	mov    rdi,r13
    11c1:	mov    rax,QWORD PTR [rdi+0x10]
    11c5:	mov    rax,QWORD PTR [rax+0x10]
    11c9:	mov    rbx,QWORD PTR [rsp+0x20]
    11ce:	mov    r12,QWORD PTR [rsp+0x28]
    11d3:	mov    r13,QWORD PTR [rsp+0x30]
    11d8:	add    rsp,0x40
    11dc:	mov    rsp,rbp
    11df:	pop    rbp
    11e0:	ret
    11e1:	add    BYTE PTR [rax],al
    11e3:	add    BYTE PTR [rax],al
    11e5:	add    BYTE PTR [rax],al
    11e7:	add    BYTE PTR [rsi],al
    11e9:	add    BYTE PTR [rax],al
    11eb:	add    BYTE PTR [rax],al
    11ed:	add    BYTE PTR [rax],al
	...

00000000000011f0 <botlish_entry_10: peek<str, int>>:
    11f0:	push   rbp
    11f1:	mov    rbp,rsp
    11f4:	mov    rsi,QWORD PTR [rdx]
    11f7:	mov    rdx,QWORD PTR [rdx+0x8]
    11fb:	call   1200 <botlish_entry_10+0x10>
			11fc: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    1200:	mov    rsp,rbp
    1203:	pop    rbp
    1204:	ret
    1205:	add    BYTE PTR [rax],al
	...

0000000000001208 <botlish_fn_11: peek<str, int>>:
    1208:	push   rbp
    1209:	mov    rbp,rsp
    120c:	sub    rsp,0x50
    1210:	mov    QWORD PTR [rsp+0x20],rbx
    1215:	mov    QWORD PTR [rsp+0x28],r12
    121a:	mov    QWORD PTR [rsp+0x30],r13
    121f:	mov    QWORD PTR [rsp+0x38],r14
    1224:	mov    QWORD PTR [rsp+0x40],r15
    1229:	mov    r12,rcx
    122c:	mov    r14,rdi
    122f:	mov    QWORD PTR [rsp],rsi
    1233:	mov    r13,rsi
    1236:	mov    QWORD PTR [rsp+0x8],rdx
    123b:	mov    rbx,rdx
    123e:	mov    rsi,r13
    1241:	mov    rdi,r14
    1244:	call   1249 <botlish_fn_11+0x41>
			1245: R_X86_64_PLT32	rt_str_len-0x4
    1249:	mov    rcx,rbx
    124c:	and    rcx,rax
    124f:	mov    rdx,rax
    1252:	test   rcx,0x1
    1259:	jne    127f <botlish_fn_11+0x77>
    125f:	mov    rsi,rbx
    1262:	mov    rdi,r14
    1265:	call   126a <botlish_fn_11+0x62>
			1266: R_X86_64_PLT32	rt_int_cmp-0x4
    126a:	mov    ecx,0x2
    126f:	test   rax,rax
    1272:	cmovge rcx,QWORD PTR [rip+0x11e]        # 1398 <botlish_fn_11+0x190>
    127a:	jmp    128f <botlish_fn_11+0x87>
    127f:	mov    ecx,0x2
    1284:	cmp    rbx,rdx
    1287:	cmovge rcx,QWORD PTR [rip+0x109]        # 1398 <botlish_fn_11+0x190>
    128f:	cmp    rcx,0x6
    1293:	je     1353 <botlish_fn_11+0x14b>
    1299:	mov    QWORD PTR [rsp+0x10],0x3
    12a2:	test   rbx,0x1
    12a9:	je     12cc <botlish_fn_11+0xc4>
    12af:	mov    rax,rbx
    12b2:	add    rax,0x2
    12b6:	seto   cl
    12b9:	test   cl,cl
    12bb:	jne    12cc <botlish_fn_11+0xc4>
    12c1:	mov    rdi,r14
    12c4:	mov    r15,rax
    12c7:	jmp    12e2 <botlish_fn_11+0xda>
    12cc:	mov    edx,0x3
    12d1:	mov    rsi,rbx
    12d4:	mov    rdi,r14
    12d7:	call   12dc <botlish_fn_11+0xd4>
			12d8: R_X86_64_PLT32	rt_int_add-0x4
    12dc:	mov    r15,rax
    12df:	mov    rdi,r14
    12e2:	mov    rdi,r14
    12e5:	mov    rcx,r15
    12e8:	mov    rdx,rbx
    12eb:	mov    rsi,r13
    12ee:	call   12f3 <botlish_fn_11+0xeb>
			12ef: R_X86_64_PLT32	rt_str_region_check-0x4
    12f3:	test   rax,rax
    12f6:	jne    1321 <botlish_fn_11+0x119>
    12fc:	xor    rax,rax
    12ff:	mov    rbx,QWORD PTR [rsp+0x20]
    1304:	mov    r12,QWORD PTR [rsp+0x28]
    1309:	mov    r13,QWORD PTR [rsp+0x30]
    130e:	mov    r14,QWORD PTR [rsp+0x38]
    1313:	mov    r15,QWORD PTR [rsp+0x40]
    1318:	add    rsp,0x50
    131c:	mov    rsp,rbp
    131f:	pop    rbp
    1320:	ret
    1321:	mov    rcx,r12
    1324:	mov    QWORD PTR [rcx],rbx
    1327:	mov    rax,r15
    132a:	mov    QWORD PTR [rcx+0x8],rax
    132e:	mov    rax,r13
    1331:	mov    rbx,QWORD PTR [rsp+0x20]
    1336:	mov    r12,QWORD PTR [rsp+0x28]
    133b:	mov    r13,QWORD PTR [rsp+0x30]
    1340:	mov    r14,QWORD PTR [rsp+0x38]
    1345:	mov    r15,QWORD PTR [rsp+0x40]
    134a:	add    rsp,0x50
    134e:	mov    rsp,rbp
    1351:	pop    rbp
    1352:	ret
    1353:	mov    rcx,r12
    1356:	mov    rdi,r14
    1359:	mov    rax,QWORD PTR [rdi+0x10]
    135d:	mov    rax,QWORD PTR [rax+0x10]
    1361:	mov    QWORD PTR [rcx],0x1
    1368:	mov    QWORD PTR [rcx+0x8],0x1
    1370:	mov    rbx,QWORD PTR [rsp+0x20]
    1375:	mov    r12,QWORD PTR [rsp+0x28]
    137a:	mov    r13,QWORD PTR [rsp+0x30]
    137f:	mov    r14,QWORD PTR [rsp+0x38]
    1384:	mov    r15,QWORD PTR [rsp+0x40]
    1389:	add    rsp,0x50
    138d:	mov    rsp,rbp
    1390:	pop    rbp
    1391:	ret
    1392:	add    BYTE PTR [rax],al
    1394:	add    BYTE PTR [rax],al
    1396:	add    BYTE PTR [rax],al
    1398:	(bad)
    1399:	add    BYTE PTR [rax],al
    139b:	add    BYTE PTR [rax],al
    139d:	add    BYTE PTR [rax],al
	...

00000000000013a0 <botlish_entry_11: peek<str, int>>:
    13a0:	push   rbp
    13a1:	mov    rbp,rsp
    13a4:	ud2

00000000000013a6 <botlish_fn_12: scan_unquoted<str, int, int>>:
    13a6:	push   rbp
    13a7:	mov    rbp,rsp
    13aa:	sub    rsp,0x80
    13b1:	mov    QWORD PTR [rsp+0x50],rbx
    13b6:	mov    QWORD PTR [rsp+0x58],r12
    13bb:	mov    QWORD PTR [rsp+0x60],r13
    13c0:	mov    QWORD PTR [rsp+0x68],r14
    13c5:	mov    QWORD PTR [rsp+0x70],r15
    13ca:	mov    QWORD PTR [rsp+0x30],rdi
    13cf:	mov    QWORD PTR [rsp+0x18],0x0
    13d8:	mov    QWORD PTR [rsp],rsi
    13dc:	mov    r15,rsi
    13df:	mov    QWORD PTR [rsp+0x8],rdx
    13e4:	mov    r14,rdx
    13e7:	mov    QWORD PTR [rsp+0x10],rcx
    13ec:	lea    r13,[rsp+0x20]
    13f1:	mov    QWORD PTR [rsp+0x38],rcx
    13f6:	mov    rcx,r13
    13f9:	mov    rdx,QWORD PTR [rsp+0x38]
    13fe:	mov    rsi,r15
    1401:	mov    rdi,QWORD PTR [rsp+0x30]
    1406:	call   140b <botlish_fn_12+0x65>
			1407: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    140b:	mov    rsi,rax
    140e:	mov    QWORD PTR [rsp+0x40],rax
    1413:	test   rax,rsi
    1416:	je     1570 <botlish_fn_12+0x1ca>
    141c:	mov    rbx,QWORD PTR [rsp+0x20]
    1421:	mov    r12,QWORD PTR [rsp+0x28]
    1426:	mov    rdi,QWORD PTR [rsp+0x30]
    142b:	mov    rcx,QWORD PTR [rdi+0x10]
    142f:	mov    r8,QWORD PTR [rcx+0x10]
    1433:	mov    rcx,r12
    1436:	mov    rdx,rbx
    1439:	mov    rsi,QWORD PTR [rsp+0x40]
    143e:	call   1443 <botlish_fn_12+0x9d>
			143f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1443:	cmp    rax,0x6
    1447:	je     1488 <botlish_fn_12+0xe2>
    144d:	mov    rdi,QWORD PTR [rsp+0x30]
    1452:	mov    rax,QWORD PTR [rdi+0x10]
    1456:	mov    r8,QWORD PTR [rax+0x18]
    145a:	mov    rcx,r12
    145d:	mov    rdx,rbx
    1460:	mov    rsi,QWORD PTR [rsp+0x40]
    1465:	call   146a <botlish_fn_12+0xc4>
			1466: R_X86_64_PLT32	rt_str_region_eq-0x4
    146a:	cmp    rax,0x6
    146e:	je     147e <botlish_fn_12+0xd8>
    1474:	mov    eax,0x2
    1479:	jmp    148d <botlish_fn_12+0xe7>
    147e:	mov    eax,0x6
    1483:	jmp    148d <botlish_fn_12+0xe7>
    1488:	mov    eax,0x6
    148d:	cmp    rax,0x6
    1491:	je     14d2 <botlish_fn_12+0x12c>
    1497:	mov    rdi,QWORD PTR [rsp+0x30]
    149c:	mov    rax,QWORD PTR [rdi+0x10]
    14a0:	mov    r8,QWORD PTR [rax+0x20]
    14a4:	mov    rcx,r12
    14a7:	mov    rdx,rbx
    14aa:	mov    rsi,QWORD PTR [rsp+0x40]
    14af:	call   14b4 <botlish_fn_12+0x10e>
			14b0: R_X86_64_PLT32	rt_str_region_eq-0x4
    14b4:	cmp    rax,0x6
    14b8:	je     14c8 <botlish_fn_12+0x122>
    14be:	mov    eax,0x2
    14c3:	jmp    14d7 <botlish_fn_12+0x131>
    14c8:	mov    eax,0x6
    14cd:	jmp    14d7 <botlish_fn_12+0x131>
    14d2:	mov    eax,0x6
    14d7:	cmp    rax,0x6
    14db:	je     1552 <botlish_fn_12+0x1ac>
    14e1:	mov    QWORD PTR [rsp+0x18],0x3
    14ea:	mov    rsi,QWORD PTR [rsp+0x38]
    14ef:	test   rsi,0x1
    14f6:	je     151d <botlish_fn_12+0x177>
    14fc:	mov    rsi,QWORD PTR [rsp+0x38]
    1501:	mov    rax,rsi
    1504:	add    rax,0x2
    1508:	seto   sil
    150c:	test   sil,sil
    150f:	jne    151d <botlish_fn_12+0x177>
    1515:	mov    rsi,r15
    1518:	jmp    1534 <botlish_fn_12+0x18e>
    151d:	mov    edx,0x3
    1522:	mov    rsi,QWORD PTR [rsp+0x38]
    1527:	mov    rdi,QWORD PTR [rsp+0x30]
    152c:	call   1531 <botlish_fn_12+0x18b>
			152d: R_X86_64_PLT32	rt_int_add-0x4
    1531:	mov    rsi,r15
    1534:	mov    QWORD PTR [rsp],rsi
    1538:	mov    rdx,r14
    153b:	mov    QWORD PTR [rsp+0x8],rdx
    1540:	mov    QWORD PTR [rsp+0x10],rax
    1545:	mov    r15,rsi
    1548:	mov    QWORD PTR [rsp+0x38],rax
    154d:	jmp    13f6 <botlish_fn_12+0x50>
    1552:	mov    rdx,r14
    1555:	mov    rsi,r15
    1558:	mov    rdi,QWORD PTR [rsp+0x30]
    155d:	mov    rcx,QWORD PTR [rsp+0x38]
    1562:	call   1567 <botlish_fn_12+0x1c1>
			1563: R_X86_64_PLT32	rt_substr-0x4
    1567:	test   rax,rax
    156a:	jne    159b <botlish_fn_12+0x1f5>
    1570:	xor    rdx,rdx
    1573:	mov    rax,rdx
    1576:	mov    rbx,QWORD PTR [rsp+0x50]
    157b:	mov    r12,QWORD PTR [rsp+0x58]
    1580:	mov    r13,QWORD PTR [rsp+0x60]
    1585:	mov    r14,QWORD PTR [rsp+0x68]
    158a:	mov    r15,QWORD PTR [rsp+0x70]
    158f:	add    rsp,0x80
    1596:	mov    rsp,rbp
    1599:	pop    rbp
    159a:	ret
    159b:	mov    rdx,QWORD PTR [rsp+0x38]
    15a0:	mov    rbx,QWORD PTR [rsp+0x50]
    15a5:	mov    r12,QWORD PTR [rsp+0x58]
    15aa:	mov    r13,QWORD PTR [rsp+0x60]
    15af:	mov    r14,QWORD PTR [rsp+0x68]
    15b4:	mov    r15,QWORD PTR [rsp+0x70]
    15b9:	add    rsp,0x80
    15c0:	mov    rsp,rbp
    15c3:	pop    rbp
    15c4:	ret

00000000000015c5 <botlish_entry_12: scan_unquoted<str, int, int>>:
    15c5:	push   rbp
    15c6:	mov    rbp,rsp
    15c9:	ud2

00000000000015cb <botlish_fn_13: scan_quoted<str, int, str>>:
    15cb:	push   rbp
    15cc:	mov    rbp,rsp
    15cf:	sub    rsp,0xd0
    15d6:	mov    QWORD PTR [rsp+0xa0],rbx
    15de:	mov    QWORD PTR [rsp+0xa8],r12
    15e6:	mov    QWORD PTR [rsp+0xb0],r13
    15ee:	mov    QWORD PTR [rsp+0xb8],r14
    15f6:	mov    QWORD PTR [rsp+0xc0],r15
    15fe:	mov    QWORD PTR [rsp+0x88],rdi
    1606:	mov    QWORD PTR [rsp+0x18],0x0
    160f:	mov    QWORD PTR [rsp+0x20],0x0
    1618:	mov    QWORD PTR [rsp],rsi
    161c:	mov    QWORD PTR [rsp+0x8],rdx
    1621:	mov    QWORD PTR [rsp+0x10],rcx
    1626:	mov    r13,rcx
    1629:	lea    r14,[rsp+0x68]
    162e:	lea    rbx,[rsp+0x28]
    1633:	mov    r12,rsi
    1636:	mov    QWORD PTR [rsp+0x90],rdx
    163e:	mov    rdx,QWORD PTR [rsp+0x90]
    1646:	mov    rsi,r12
    1649:	mov    rdi,QWORD PTR [rsp+0x88]
    1651:	call   1656 <botlish_fn_13+0x8b>
			1652: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    1656:	test   rax,rax
    1659:	je     19a2 <botlish_fn_13+0x3d7>
    165f:	mov    QWORD PTR [rsp+0x18],rax
    1664:	mov    rsi,QWORD PTR [rax+0x8]
    1668:	mov    rcx,rax
    166b:	mov    rax,0xffffffffffffffff
    1672:	test   rsi,rsi
    1675:	jne    1683 <botlish_fn_13+0xb8>
    167b:	mov    r15,rcx
    167e:	jmp    16ae <botlish_fn_13+0xe3>
    1683:	mov    r15,rcx
    1686:	movzx  rdi,BYTE PTR [r15+0x18]
    168b:	test   rdi,rdi
    168e:	jne    16a9 <botlish_fn_13+0xde>
    1694:	mov    rsi,r15
    1697:	mov    rdi,QWORD PTR [rsp+0x88]
    169f:	call   16a4 <botlish_fn_13+0xd9>
			16a0: R_X86_64_PLT32	rt_str_to_short-0x4
    16a4:	jmp    16ae <botlish_fn_13+0xe3>
    16a9:	movzx  rax,BYTE PTR [r15+0x19]
    16ae:	cmp    rax,0x22
    16b2:	je     1772 <botlish_fn_13+0x1a7>
    16b8:	mov    QWORD PTR [rsp+0x20],0x3
    16c1:	mov    rsi,QWORD PTR [rsp+0x90]
    16c9:	test   rsi,0x1
    16d0:	je     16f0 <botlish_fn_13+0x125>
    16d6:	mov    rax,rsi
    16d9:	add    rax,0x2
    16dd:	seto   cl
    16e0:	test   cl,cl
    16e2:	jne    16f0 <botlish_fn_13+0x125>
    16e8:	mov    rsi,rax
    16eb:	jmp    1705 <botlish_fn_13+0x13a>
    16f0:	mov    edx,0x3
    16f5:	mov    rdi,QWORD PTR [rsp+0x88]
    16fd:	call   1702 <botlish_fn_13+0x137>
			16fe: R_X86_64_PLT32	rt_int_add-0x4
    1702:	mov    rsi,rax
    1705:	mov    QWORD PTR [rsp+0x8],rsi
    170a:	mov    QWORD PTR [rsp+0x90],rsi
    1712:	mov    QWORD PTR [rsp+0x68],0x0
    171b:	mov    QWORD PTR [rsp+0x70],r13
    1720:	mov    QWORD PTR [rsp+0x78],0x0
    1729:	mov    QWORD PTR [rsp+0x80],r15
    1731:	mov    esi,0x2
    1736:	mov    edx,0x4
    173b:	mov    rcx,r14
    173e:	mov    rdi,QWORD PTR [rsp+0x88]
    1746:	call   174b <botlish_fn_13+0x180>
			1747: R_X86_64_PLT32	rt_construct-0x4
    174b:	test   rax,rax
    174e:	je     19a2 <botlish_fn_13+0x3d7>
    1754:	mov    QWORD PTR [rsp],r12
    1758:	mov    rsi,QWORD PTR [rsp+0x90]
    1760:	mov    QWORD PTR [rsp+0x8],rsi
    1765:	mov    QWORD PTR [rsp+0x10],rax
    176a:	mov    r13,rax
    176d:	jmp    163e <botlish_fn_13+0x73>
    1772:	mov    QWORD PTR [rsp+0x18],0x3
    177b:	mov    rsi,QWORD PTR [rsp+0x90]
    1783:	test   rsi,0x1
    178a:	je     17aa <botlish_fn_13+0x1df>
    1790:	mov    rsi,QWORD PTR [rsp+0x90]
    1798:	mov    rdx,rsi
    179b:	add    rdx,0x2
    179f:	seto   al
    17a2:	test   al,al
    17a4:	je     17c7 <botlish_fn_13+0x1fc>
    17aa:	mov    edx,0x3
    17af:	mov    rsi,QWORD PTR [rsp+0x90]
    17b7:	mov    rdi,QWORD PTR [rsp+0x88]
    17bf:	call   17c4 <botlish_fn_13+0x1f9>
			17c0: R_X86_64_PLT32	rt_int_add-0x4
    17c4:	mov    rdx,rax
    17c7:	mov    QWORD PTR [rsp+0x18],rdx
    17cc:	mov    rcx,rbx
    17cf:	mov    rsi,r12
    17d2:	mov    rdi,QWORD PTR [rsp+0x88]
    17da:	call   17df <botlish_fn_13+0x214>
			17db: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    17df:	test   rax,rax
    17e2:	mov    rsi,rax
    17e5:	je     19a2 <botlish_fn_13+0x3d7>
    17eb:	mov    rdx,QWORD PTR [rsp+0x28]
    17f0:	mov    rcx,QWORD PTR [rsp+0x30]
    17f5:	mov    rdi,QWORD PTR [rsp+0x88]
    17fd:	mov    rax,QWORD PTR [rdi+0x10]
    1801:	mov    r8,QWORD PTR [rax+0x28]
    1805:	call   180a <botlish_fn_13+0x23f>
			1806: R_X86_64_PLT32	rt_str_region_eq-0x4
    180a:	cmp    rax,0x6
    180e:	je     18e0 <botlish_fn_13+0x315>
    1814:	xor    rsi,rsi
    1817:	lea    rcx,[rsp+0x58]
    181c:	mov    QWORD PTR [rsp+0x58],0x0
    1825:	mov    QWORD PTR [rsp+0x60],r13
    182a:	mov    edx,0x2
    182f:	mov    rdi,QWORD PTR [rsp+0x88]
    1837:	call   183c <botlish_fn_13+0x271>
			1838: R_X86_64_PLT32	rt_construct-0x4
    183c:	test   rax,rax
    183f:	je     19a2 <botlish_fn_13+0x3d7>
    1845:	mov    QWORD PTR [rsp],rax
    1849:	mov    rbx,rax
    184c:	mov    QWORD PTR [rsp+0x10],0x3
    1855:	mov    rsi,QWORD PTR [rsp+0x90]
    185d:	test   rsi,0x1
    1864:	je     188c <botlish_fn_13+0x2c1>
    186a:	mov    rsi,QWORD PTR [rsp+0x90]
    1872:	mov    rdx,rsi
    1875:	add    rdx,0x2
    1879:	seto   al
    187c:	test   al,al
    187e:	jne    188c <botlish_fn_13+0x2c1>
    1884:	mov    rax,rbx
    1887:	jmp    18ac <botlish_fn_13+0x2e1>
    188c:	mov    edx,0x3
    1891:	mov    rsi,QWORD PTR [rsp+0x90]
    1899:	mov    rdi,QWORD PTR [rsp+0x88]
    18a1:	call   18a6 <botlish_fn_13+0x2db>
			18a2: R_X86_64_PLT32	rt_int_add-0x4
    18a6:	mov    rdx,rax
    18a9:	mov    rax,rbx
    18ac:	mov    rbx,QWORD PTR [rsp+0xa0]
    18b4:	mov    r12,QWORD PTR [rsp+0xa8]
    18bc:	mov    r13,QWORD PTR [rsp+0xb0]
    18c4:	mov    r14,QWORD PTR [rsp+0xb8]
    18cc:	mov    r15,QWORD PTR [rsp+0xc0]
    18d4:	add    rsp,0xd0
    18db:	mov    rsp,rbp
    18de:	pop    rbp
    18df:	ret
    18e0:	mov    QWORD PTR [rsp+0x18],0x5
    18e9:	mov    rsi,QWORD PTR [rsp+0x90]
    18f1:	test   rsi,0x1
    18f8:	je     192a <botlish_fn_13+0x35f>
    18fe:	mov    rsi,QWORD PTR [rsp+0x90]
    1906:	mov    rdi,rsi
    1909:	add    rdi,0x4
    190d:	seto   r9b
    1911:	test   r9b,r9b
    1914:	jne    192a <botlish_fn_13+0x35f>
    191a:	mov    rsi,rdi
    191d:	mov    QWORD PTR [rsp+0x90],rdi
    1925:	jmp    194f <botlish_fn_13+0x384>
    192a:	mov    edx,0x5
    192f:	mov    rsi,QWORD PTR [rsp+0x90]
    1937:	mov    rdi,QWORD PTR [rsp+0x88]
    193f:	call   1944 <botlish_fn_13+0x379>
			1940: R_X86_64_PLT32	rt_int_add-0x4
    1944:	mov    rsi,rax
    1947:	mov    QWORD PTR [rsp+0x90],rax
    194f:	mov    QWORD PTR [rsp+0x8],rsi
    1954:	mov    rdi,QWORD PTR [rsp+0x88]
    195c:	mov    rax,QWORD PTR [rdi+0x10]
    1960:	mov    rax,QWORD PTR [rax+0x28]
    1964:	mov    QWORD PTR [rsp+0x18],rax
    1969:	lea    rcx,[rsp+0x38]
    196e:	mov    QWORD PTR [rsp+0x38],0x0
    1977:	mov    QWORD PTR [rsp+0x40],r13
    197c:	mov    QWORD PTR [rsp+0x48],0x0
    1985:	mov    QWORD PTR [rsp+0x50],rax
    198a:	mov    esi,0x2
    198f:	mov    edx,0x4
    1994:	call   1999 <botlish_fn_13+0x3ce>
			1995: R_X86_64_PLT32	rt_construct-0x4
    1999:	test   rax,rax
    199c:	jne    19dc <botlish_fn_13+0x411>
    19a2:	xor    rdx,rdx
    19a5:	mov    rax,rdx
    19a8:	mov    rbx,QWORD PTR [rsp+0xa0]
    19b0:	mov    r12,QWORD PTR [rsp+0xa8]
    19b8:	mov    r13,QWORD PTR [rsp+0xb0]
    19c0:	mov    r14,QWORD PTR [rsp+0xb8]
    19c8:	mov    r15,QWORD PTR [rsp+0xc0]
    19d0:	add    rsp,0xd0
    19d7:	mov    rsp,rbp
    19da:	pop    rbp
    19db:	ret
    19dc:	mov    QWORD PTR [rsp],r12
    19e0:	mov    rsi,QWORD PTR [rsp+0x90]
    19e8:	mov    QWORD PTR [rsp+0x8],rsi
    19ed:	mov    QWORD PTR [rsp+0x10],rax
    19f2:	mov    r13,rax
    19f5:	jmp    163e <botlish_fn_13+0x73>

00000000000019fa <botlish_entry_13: scan_quoted<str, int, str>>:
    19fa:	push   rbp
    19fb:	mov    rbp,rsp
    19fe:	ud2

0000000000001a00 <botlish_fn_14: scan_field<str, int>>:
    1a00:	push   rbp
    1a01:	mov    rbp,rsp
    1a04:	sub    rsp,0x50
    1a08:	mov    QWORD PTR [rsp+0x30],rbx
    1a0d:	mov    QWORD PTR [rsp+0x38],r12
    1a12:	mov    QWORD PTR [rsp+0x40],r13
    1a17:	mov    r12,rdi
    1a1a:	mov    r13,rdx
    1a1d:	mov    QWORD PTR [rsp+0x10],0x0
    1a26:	mov    QWORD PTR [rsp],rsi
    1a2a:	mov    rbx,rsi
    1a2d:	mov    QWORD PTR [rsp+0x8],rdx
    1a32:	lea    rcx,[rsp+0x18]
    1a37:	mov    rdx,r13
    1a3a:	mov    rsi,rbx
    1a3d:	mov    rdi,r12
    1a40:	call   1a45 <botlish_fn_14+0x45>
			1a41: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1a45:	test   rax,rax
    1a48:	mov    rsi,rax
    1a4b:	je     1b16 <botlish_fn_14+0x116>
    1a51:	mov    rdx,QWORD PTR [rsp+0x18]
    1a56:	mov    rcx,QWORD PTR [rsp+0x20]
    1a5b:	mov    rdi,r12
    1a5e:	mov    rax,QWORD PTR [rdi+0x10]
    1a62:	mov    r8,QWORD PTR [rax+0x28]
    1a66:	call   1a6b <botlish_fn_14+0x6b>
			1a67: R_X86_64_PLT32	rt_str_region_eq-0x4
    1a6b:	cmp    rax,0x6
    1a6f:	je     1aa7 <botlish_fn_14+0xa7>
    1a75:	mov    rcx,r13
    1a78:	mov    rsi,rbx
    1a7b:	mov    rdi,r12
    1a7e:	mov    rdx,rcx
    1a81:	call   1a86 <botlish_fn_14+0x86>
			1a82: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_unquoted<str, int, int>
    1a86:	test   rax,rax
    1a89:	je     1b16 <botlish_fn_14+0x116>
    1a8f:	mov    rbx,QWORD PTR [rsp+0x30]
    1a94:	mov    r12,QWORD PTR [rsp+0x38]
    1a99:	mov    r13,QWORD PTR [rsp+0x40]
    1a9e:	add    rsp,0x50
    1aa2:	mov    rsp,rbp
    1aa5:	pop    rbp
    1aa6:	ret
    1aa7:	mov    rcx,r13
    1aaa:	mov    QWORD PTR [rsp+0x10],0x3
    1ab3:	test   rcx,0x1
    1aba:	jne    1ac8 <botlish_fn_14+0xc8>
    1ac0:	mov    r13,rcx
    1ac3:	jmp    1add <botlish_fn_14+0xdd>
    1ac8:	mov    rdx,rcx
    1acb:	add    rdx,0x2
    1acf:	mov    r13,rcx
    1ad2:	seto   al
    1ad5:	test   al,al
    1ad7:	je     1af0 <botlish_fn_14+0xf0>
    1add:	mov    edx,0x3
    1ae2:	mov    rsi,r13
    1ae5:	mov    rdi,r12
    1ae8:	call   1aed <botlish_fn_14+0xed>
			1ae9: R_X86_64_PLT32	rt_int_add-0x4
    1aed:	mov    rdx,rax
    1af0:	mov    QWORD PTR [rsp+0x8],rdx
    1af5:	mov    rdi,r12
    1af8:	mov    rax,QWORD PTR [rdi+0x10]
    1afc:	mov    rcx,QWORD PTR [rax+0x10]
    1b00:	mov    QWORD PTR [rsp+0x10],rcx
    1b05:	mov    rsi,rbx
    1b08:	call   1b0d <botlish_fn_14+0x10d>
			1b09: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_quoted<str, int, str>
    1b0d:	test   rax,rax
    1b10:	jne    1b34 <botlish_fn_14+0x134>
    1b16:	xor    rdx,rdx
    1b19:	mov    rax,rdx
    1b1c:	mov    rbx,QWORD PTR [rsp+0x30]
    1b21:	mov    r12,QWORD PTR [rsp+0x38]
    1b26:	mov    r13,QWORD PTR [rsp+0x40]
    1b2b:	add    rsp,0x50
    1b2f:	mov    rsp,rbp
    1b32:	pop    rbp
    1b33:	ret
    1b34:	mov    rbx,QWORD PTR [rsp+0x30]
    1b39:	mov    r12,QWORD PTR [rsp+0x38]
    1b3e:	mov    r13,QWORD PTR [rsp+0x40]
    1b43:	add    rsp,0x50
    1b47:	mov    rsp,rbp
    1b4a:	pop    rbp
    1b4b:	ret

0000000000001b4c <botlish_entry_14: scan_field<str, int>>:
    1b4c:	push   rbp
    1b4d:	mov    rbp,rsp
    1b50:	ud2

0000000000001b52 <botlish_fn_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1b52:	push   rbp
    1b53:	mov    rbp,rsp
    1b56:	sub    rsp,0xa0
    1b5d:	mov    QWORD PTR [rsp+0x70],rbx
    1b62:	mov    QWORD PTR [rsp+0x78],r12
    1b67:	mov    QWORD PTR [rsp+0x80],r13
    1b6f:	mov    QWORD PTR [rsp+0x88],r14
    1b77:	mov    QWORD PTR [rsp+0x90],r15
    1b7f:	mov    r13,rdi
    1b82:	mov    QWORD PTR [rsp+0x28],0x0
    1b8b:	mov    QWORD PTR [rsp],rsi
    1b8f:	mov    r15,rsi
    1b92:	mov    QWORD PTR [rsp+0x8],rdx
    1b97:	mov    QWORD PTR [rsp+0x10],rcx
    1b9c:	mov    QWORD PTR [rsp+0x50],rcx
    1ba1:	mov    QWORD PTR [rsp+0x18],r8
    1ba6:	mov    r12,r8
    1ba9:	mov    QWORD PTR [rsp+0x20],r9
    1bae:	mov    rbx,r9
    1bb1:	mov    rsi,r15
    1bb4:	mov    rdi,r13
    1bb7:	call   1bbc <botlish_fn_15+0x6a>
			1bb8: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1bbc:	test   rax,rax
    1bbf:	je     1df3 <botlish_fn_15+0x2a1>
    1bc5:	mov    QWORD PTR [rsp+0x8],rax
    1bca:	mov    r8,rax
    1bcd:	mov    QWORD PTR [rsp+0x28],rdx
    1bd2:	mov    r14,rdx
    1bd5:	lea    r9,[rsp+0x30]
    1bda:	mov    rcx,rbx
    1bdd:	mov    rdx,r12
    1be0:	mov    rsi,QWORD PTR [rsp+0x50]
    1be5:	mov    rdi,r13
    1be8:	call   1bed <botlish_fn_15+0x9b>
			1be9: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<list[List[never], mutarray, int], str>
    1bed:	test   rax,rax
    1bf0:	je     1df3 <botlish_fn_15+0x2a1>
    1bf6:	mov    QWORD PTR [rsp+0x8],rax
    1bfb:	mov    QWORD PTR [rsp+0x68],rax
    1c00:	mov    rdx,QWORD PTR [rsp+0x30]
    1c05:	mov    QWORD PTR [rsp+0x10],rdx
    1c0a:	mov    QWORD PTR [rsp+0x60],rdx
    1c0f:	mov    rcx,QWORD PTR [rsp+0x38]
    1c14:	mov    QWORD PTR [rsp+0x18],rcx
    1c19:	mov    QWORD PTR [rsp+0x58],rcx
    1c1e:	lea    rcx,[rsp+0x40]
    1c23:	mov    rdx,r14
    1c26:	mov    rsi,r15
    1c29:	mov    rdi,r13
    1c2c:	call   1c31 <botlish_fn_15+0xdf>
			1c2d: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1c31:	test   rax,rax
    1c34:	mov    QWORD PTR [rsp+0x50],rax
    1c39:	je     1df3 <botlish_fn_15+0x2a1>
    1c3f:	mov    r12,QWORD PTR [rsp+0x40]
    1c44:	mov    rbx,QWORD PTR [rsp+0x48]
    1c49:	mov    rdi,r13
    1c4c:	mov    rcx,QWORD PTR [rdi+0x10]
    1c50:	mov    r8,QWORD PTR [rcx+0x18]
    1c54:	mov    rcx,rbx
    1c57:	mov    rdx,r12
    1c5a:	mov    rsi,QWORD PTR [rsp+0x50]
    1c5f:	call   1c64 <botlish_fn_15+0x112>
			1c60: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c64:	cmp    rax,0x6
    1c68:	je     1d82 <botlish_fn_15+0x230>
    1c6e:	mov    rdi,r13
    1c71:	mov    rax,QWORD PTR [rdi+0x10]
    1c75:	mov    r8,QWORD PTR [rax+0x20]
    1c79:	mov    rcx,rbx
    1c7c:	mov    rdx,r12
    1c7f:	mov    rsi,QWORD PTR [rsp+0x50]
    1c84:	call   1c89 <botlish_fn_15+0x137>
			1c85: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c89:	cmp    rax,0x6
    1c8d:	je     1ce4 <botlish_fn_15+0x192>
    1c93:	mov    rcx,QWORD PTR [rsp+0x58]
    1c98:	mov    rdx,QWORD PTR [rsp+0x60]
    1c9d:	mov    rsi,QWORD PTR [rsp+0x68]
    1ca2:	mov    rdi,r13
    1ca5:	call   1caa <botlish_fn_15+0x158>
			1ca6: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1caa:	test   rax,rax
    1cad:	je     1df3 <botlish_fn_15+0x2a1>
    1cb3:	mov    rdx,r14
    1cb6:	mov    rbx,QWORD PTR [rsp+0x70]
    1cbb:	mov    r12,QWORD PTR [rsp+0x78]
    1cc0:	mov    r13,QWORD PTR [rsp+0x80]
    1cc8:	mov    r14,QWORD PTR [rsp+0x88]
    1cd0:	mov    r15,QWORD PTR [rsp+0x90]
    1cd8:	add    rsp,0xa0
    1cdf:	mov    rsp,rbp
    1ce2:	pop    rbp
    1ce3:	ret
    1ce4:	mov    rcx,QWORD PTR [rsp+0x58]
    1ce9:	mov    rdx,QWORD PTR [rsp+0x60]
    1cee:	mov    rsi,QWORD PTR [rsp+0x68]
    1cf3:	mov    rdi,r13
    1cf6:	call   1cfb <botlish_fn_15+0x1a9>
			1cf7: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1cfb:	test   rax,rax
    1cfe:	je     1df3 <botlish_fn_15+0x2a1>
    1d04:	mov    QWORD PTR [rsp],rax
    1d08:	mov    rbx,rax
    1d0b:	mov    QWORD PTR [rsp+0x8],0x3
    1d14:	mov    rdx,r14
    1d17:	test   rdx,0x1
    1d1e:	je     1d3e <botlish_fn_15+0x1ec>
    1d24:	mov    rdx,r14
    1d27:	add    rdx,0x2
    1d2b:	seto   al
    1d2e:	test   al,al
    1d30:	jne    1d3e <botlish_fn_15+0x1ec>
    1d36:	mov    rax,rbx
    1d39:	jmp    1d54 <botlish_fn_15+0x202>
    1d3e:	mov    edx,0x3
    1d43:	mov    rsi,r14
    1d46:	mov    rdi,r13
    1d49:	call   1d4e <botlish_fn_15+0x1fc>
			1d4a: R_X86_64_PLT32	rt_int_add-0x4
    1d4e:	mov    rdx,rax
    1d51:	mov    rax,rbx
    1d54:	mov    rbx,QWORD PTR [rsp+0x70]
    1d59:	mov    r12,QWORD PTR [rsp+0x78]
    1d5e:	mov    r13,QWORD PTR [rsp+0x80]
    1d66:	mov    r14,QWORD PTR [rsp+0x88]
    1d6e:	mov    r15,QWORD PTR [rsp+0x90]
    1d76:	add    rsp,0xa0
    1d7d:	mov    rsp,rbp
    1d80:	pop    rbp
    1d81:	ret
    1d82:	mov    rsi,r14
    1d85:	mov    edx,0x3
    1d8a:	mov    rcx,rdx
    1d8d:	mov    QWORD PTR [rsp+0x20],0x3
    1d96:	test   rsi,0x1
    1d9d:	jne    1dab <botlish_fn_15+0x259>
    1da3:	mov    rdx,rcx
    1da6:	jmp    1dc0 <botlish_fn_15+0x26e>
    1dab:	mov    rdx,rsi
    1dae:	add    rdx,0x2
    1db2:	seto   al
    1db5:	test   al,al
    1db7:	je     1dcb <botlish_fn_15+0x279>
    1dbd:	mov    rdx,rcx
    1dc0:	mov    rdi,r13
    1dc3:	call   1dc8 <botlish_fn_15+0x276>
			1dc4: R_X86_64_PLT32	rt_int_add-0x4
    1dc8:	mov    rdx,rax
    1dcb:	mov    QWORD PTR [rsp+0x20],rdx
    1dd0:	mov    rcx,QWORD PTR [rsp+0x68]
    1dd5:	mov    rsi,r15
    1dd8:	mov    rdi,r13
    1ddb:	mov    r8,QWORD PTR [rsp+0x60]
    1de0:	mov    r9,QWORD PTR [rsp+0x58]
    1de5:	call   1dea <botlish_fn_15+0x298>
			1de6: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[List[mutarray], mutarray, int]>
    1dea:	test   rax,rax
    1ded:	jne    1e27 <botlish_fn_15+0x2d5>
    1df3:	xor    rdx,rdx
    1df6:	mov    rax,rdx
    1df9:	mov    rbx,QWORD PTR [rsp+0x70]
    1dfe:	mov    r12,QWORD PTR [rsp+0x78]
    1e03:	mov    r13,QWORD PTR [rsp+0x80]
    1e0b:	mov    r14,QWORD PTR [rsp+0x88]
    1e13:	mov    r15,QWORD PTR [rsp+0x90]
    1e1b:	add    rsp,0xa0
    1e22:	mov    rsp,rbp
    1e25:	pop    rbp
    1e26:	ret
    1e27:	mov    rbx,QWORD PTR [rsp+0x70]
    1e2c:	mov    r12,QWORD PTR [rsp+0x78]
    1e31:	mov    r13,QWORD PTR [rsp+0x80]
    1e39:	mov    r14,QWORD PTR [rsp+0x88]
    1e41:	mov    r15,QWORD PTR [rsp+0x90]
    1e49:	add    rsp,0xa0
    1e50:	mov    rsp,rbp
    1e53:	pop    rbp
    1e54:	ret

0000000000001e55 <botlish_entry_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1e55:	push   rbp
    1e56:	mov    rbp,rsp
    1e59:	ud2

0000000000001e5b <botlish_fn_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    1e5b:	push   rbp
    1e5c:	mov    rbp,rsp
    1e5f:	sub    rsp,0xb0
    1e66:	mov    QWORD PTR [rsp+0x80],rbx
    1e6e:	mov    QWORD PTR [rsp+0x88],r12
    1e76:	mov    QWORD PTR [rsp+0x90],r13
    1e7e:	mov    QWORD PTR [rsp+0x98],r14
    1e86:	mov    QWORD PTR [rsp+0xa0],r15
    1e8e:	mov    QWORD PTR [rsp+0x50],rdi
    1e93:	mov    QWORD PTR [rsp+0x28],0x0
    1e9c:	mov    QWORD PTR [rsp],rsi
    1ea0:	mov    QWORD PTR [rsp+0x8],rdx
    1ea5:	mov    QWORD PTR [rsp+0x10],rcx
    1eaa:	mov    QWORD PTR [rsp+0x18],r8
    1eaf:	mov    QWORD PTR [rsp+0x20],r9
    1eb4:	lea    r15,[rsp+0x30]
    1eb9:	lea    rbx,[rsp+0x40]
    1ebe:	mov    r12,rsi
    1ec1:	mov    r13,rcx
    1ec4:	mov    QWORD PTR [rsp+0x58],r8
    1ec9:	mov    QWORD PTR [rsp+0x60],r9
    1ece:	mov    rsi,r12
    1ed1:	mov    rdi,QWORD PTR [rsp+0x50]
    1ed6:	call   1edb <botlish_fn_16+0x80>
			1ed7: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1edb:	mov    QWORD PTR [rsp+0x78],rdx
    1ee0:	test   rax,rax
    1ee3:	je     203e <botlish_fn_16+0x1e3>
    1ee9:	mov    QWORD PTR [rsp+0x8],rax
    1eee:	mov    rdx,QWORD PTR [rsp+0x78]
    1ef3:	mov    r8,rax
    1ef6:	mov    QWORD PTR [rsp+0x28],rdx
    1efb:	mov    rcx,QWORD PTR [rsp+0x60]
    1f00:	mov    rdx,QWORD PTR [rsp+0x58]
    1f05:	mov    rsi,r13
    1f08:	mov    rdi,QWORD PTR [rsp+0x50]
    1f0d:	mov    r9,r15
    1f10:	call   1f15 <botlish_fn_16+0xba>
			1f11: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[List[mutarray], mutarray, int], str>
    1f15:	test   rax,rax
    1f18:	je     203e <botlish_fn_16+0x1e3>
    1f1e:	mov    QWORD PTR [rsp+0x8],rax
    1f23:	mov    QWORD PTR [rsp+0x70],rax
    1f28:	mov    rdx,QWORD PTR [rsp+0x30]
    1f2d:	mov    QWORD PTR [rsp+0x58],rdx
    1f32:	mov    QWORD PTR [rsp+0x10],rdx
    1f37:	mov    rcx,QWORD PTR [rsp+0x38]
    1f3c:	mov    QWORD PTR [rsp+0x18],rcx
    1f41:	mov    QWORD PTR [rsp+0x60],rcx
    1f46:	mov    rcx,rbx
    1f49:	mov    rdx,QWORD PTR [rsp+0x78]
    1f4e:	mov    rsi,r12
    1f51:	mov    rdi,QWORD PTR [rsp+0x50]
    1f56:	call   1f5b <botlish_fn_16+0x100>
			1f57: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1f5b:	test   rax,rax
    1f5e:	mov    QWORD PTR [rsp+0x68],rax
    1f63:	je     203e <botlish_fn_16+0x1e3>
    1f69:	mov    r13,QWORD PTR [rsp+0x40]
    1f6e:	mov    r14,QWORD PTR [rsp+0x48]
    1f73:	mov    rdi,QWORD PTR [rsp+0x50]
    1f78:	mov    rcx,QWORD PTR [rdi+0x10]
    1f7c:	mov    r8,QWORD PTR [rcx+0x18]
    1f80:	mov    rcx,r14
    1f83:	mov    rdx,r13
    1f86:	mov    rsi,QWORD PTR [rsp+0x68]
    1f8b:	call   1f90 <botlish_fn_16+0x135>
			1f8c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f90:	cmp    rax,0x6
    1f94:	je     2104 <botlish_fn_16+0x2a9>
    1f9a:	mov    rdi,QWORD PTR [rsp+0x50]
    1f9f:	mov    rax,QWORD PTR [rdi+0x10]
    1fa3:	mov    r8,QWORD PTR [rax+0x20]
    1fa7:	mov    rcx,r14
    1faa:	mov    rdx,r13
    1fad:	mov    rsi,QWORD PTR [rsp+0x68]
    1fb2:	call   1fb7 <botlish_fn_16+0x15c>
			1fb3: R_X86_64_PLT32	rt_str_region_eq-0x4
    1fb7:	cmp    rax,0x6
    1fbb:	je     201c <botlish_fn_16+0x1c1>
    1fc1:	mov    rcx,QWORD PTR [rsp+0x60]
    1fc6:	mov    rdx,QWORD PTR [rsp+0x58]
    1fcb:	mov    rsi,QWORD PTR [rsp+0x70]
    1fd0:	mov    rdi,QWORD PTR [rsp+0x50]
    1fd5:	call   1fda <botlish_fn_16+0x17f>
			1fd6: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1fda:	test   rax,rax
    1fdd:	je     203e <botlish_fn_16+0x1e3>
    1fe3:	mov    rdx,QWORD PTR [rsp+0x78]
    1fe8:	mov    rbx,QWORD PTR [rsp+0x80]
    1ff0:	mov    r12,QWORD PTR [rsp+0x88]
    1ff8:	mov    r13,QWORD PTR [rsp+0x90]
    2000:	mov    r14,QWORD PTR [rsp+0x98]
    2008:	mov    r15,QWORD PTR [rsp+0xa0]
    2010:	add    rsp,0xb0
    2017:	mov    rsp,rbp
    201a:	pop    rbp
    201b:	ret
    201c:	mov    rcx,QWORD PTR [rsp+0x60]
    2021:	mov    rdx,QWORD PTR [rsp+0x58]
    2026:	mov    rsi,QWORD PTR [rsp+0x70]
    202b:	mov    rdi,QWORD PTR [rsp+0x50]
    2030:	call   2035 <botlish_fn_16+0x1da>
			2031: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    2035:	test   rax,rax
    2038:	jne    2078 <botlish_fn_16+0x21d>
    203e:	xor    rdx,rdx
    2041:	mov    rax,rdx
    2044:	mov    rbx,QWORD PTR [rsp+0x80]
    204c:	mov    r12,QWORD PTR [rsp+0x88]
    2054:	mov    r13,QWORD PTR [rsp+0x90]
    205c:	mov    r14,QWORD PTR [rsp+0x98]
    2064:	mov    r15,QWORD PTR [rsp+0xa0]
    206c:	add    rsp,0xb0
    2073:	mov    rsp,rbp
    2076:	pop    rbp
    2077:	ret
    2078:	mov    QWORD PTR [rsp],rax
    207c:	mov    rbx,rax
    207f:	mov    QWORD PTR [rsp+0x8],0x3
    2088:	mov    rdx,QWORD PTR [rsp+0x78]
    208d:	test   rdx,0x1
    2094:	je     20b6 <botlish_fn_16+0x25b>
    209a:	mov    rdx,QWORD PTR [rsp+0x78]
    209f:	add    rdx,0x2
    20a3:	seto   al
    20a6:	test   al,al
    20a8:	jne    20b6 <botlish_fn_16+0x25b>
    20ae:	mov    rax,rbx
    20b1:	jmp    20d0 <botlish_fn_16+0x275>
    20b6:	mov    edx,0x3
    20bb:	mov    rsi,QWORD PTR [rsp+0x78]
    20c0:	mov    rdi,QWORD PTR [rsp+0x50]
    20c5:	call   20ca <botlish_fn_16+0x26f>
			20c6: R_X86_64_PLT32	rt_int_add-0x4
    20ca:	mov    rdx,rax
    20cd:	mov    rax,rbx
    20d0:	mov    rbx,QWORD PTR [rsp+0x80]
    20d8:	mov    r12,QWORD PTR [rsp+0x88]
    20e0:	mov    r13,QWORD PTR [rsp+0x90]
    20e8:	mov    r14,QWORD PTR [rsp+0x98]
    20f0:	mov    r15,QWORD PTR [rsp+0xa0]
    20f8:	add    rsp,0xb0
    20ff:	mov    rsp,rbp
    2102:	pop    rbp
    2103:	ret
    2104:	mov    rsi,QWORD PTR [rsp+0x78]
    2109:	mov    edx,0x3
    210e:	mov    r10,rdx
    2111:	mov    QWORD PTR [rsp+0x20],0x3
    211a:	test   rsi,0x1
    2121:	jne    212f <botlish_fn_16+0x2d4>
    2127:	mov    rdx,r10
    212a:	jmp    2144 <botlish_fn_16+0x2e9>
    212f:	mov    rdx,rsi
    2132:	add    rdx,0x2
    2136:	seto   al
    2139:	test   al,al
    213b:	je     2151 <botlish_fn_16+0x2f6>
    2141:	mov    rdx,r10
    2144:	mov    rdi,QWORD PTR [rsp+0x50]
    2149:	call   214e <botlish_fn_16+0x2f3>
			214a: R_X86_64_PLT32	rt_int_add-0x4
    214e:	mov    rdx,rax
    2151:	mov    QWORD PTR [rsp],r12
    2155:	mov    QWORD PTR [rsp+0x8],rdx
    215a:	mov    rsi,QWORD PTR [rsp+0x70]
    215f:	mov    QWORD PTR [rsp+0x10],rsi
    2164:	mov    rax,QWORD PTR [rsp+0x58]
    2169:	mov    QWORD PTR [rsp+0x18],rax
    216e:	mov    rcx,QWORD PTR [rsp+0x60]
    2173:	mov    QWORD PTR [rsp+0x20],rcx
    2178:	mov    r13,rsi
    217b:	jmp    1ece <botlish_fn_16+0x73>

0000000000002180 <botlish_entry_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    2180:	push   rbp
    2181:	mov    rbp,rsp
    2184:	ud2

0000000000002186 <botlish_fn_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    2186:	push   rbp
    2187:	mov    rbp,rsp
    218a:	sub    rsp,0xa0
    2191:	mov    QWORD PTR [rsp+0x70],rbx
    2196:	mov    QWORD PTR [rsp+0x78],r12
    219b:	mov    QWORD PTR [rsp+0x80],r13
    21a3:	mov    QWORD PTR [rsp+0x88],r14
    21ab:	mov    QWORD PTR [rsp+0x90],r15
    21b3:	mov    r12,rdi
    21b6:	mov    QWORD PTR [rsp+0x28],0x0
    21bf:	mov    QWORD PTR [rsp+0x30],0x0
    21c8:	mov    QWORD PTR [rsp+0x38],0x0
    21d1:	mov    QWORD PTR [rsp],rsi
    21d5:	mov    rbx,rsi
    21d8:	mov    QWORD PTR [rsp+0x8],rdx
    21dd:	mov    QWORD PTR [rsp+0x60],rdx
    21e2:	mov    QWORD PTR [rsp+0x10],rcx
    21e7:	mov    r15,rcx
    21ea:	mov    QWORD PTR [rsp+0x18],r8
    21ef:	mov    r14,r8
    21f2:	mov    QWORD PTR [rsp+0x20],r9
    21f7:	mov    r13,r9
    21fa:	mov    rsi,rbx
    21fd:	mov    rdi,r12
    2200:	call   2205 <botlish_fn_17+0x7f>
			2201: R_X86_64_PLT32	rt_str_len-0x4
    2205:	mov    rdx,QWORD PTR [rsp+0x60]
    220a:	mov    rcx,rdx
    220d:	sar    rcx,1
    2210:	sar    rax,1
    2213:	cmp    rcx,rax
    2216:	jge    22fb <botlish_fn_17+0x175>
    221c:	lea    rsi,[rsp+0x40]
    2221:	mov    rdi,r12
    2224:	call   2229 <botlish_fn_17+0xa3>
			2225: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2229:	test   rax,rax
    222c:	je     2315 <botlish_fn_17+0x18f>
    2232:	mov    QWORD PTR [rsp+0x28],rax
    2237:	mov    rcx,rax
    223a:	mov    r8,QWORD PTR [rsp+0x40]
    223f:	mov    QWORD PTR [rsp+0x30],r8
    2244:	mov    r9,QWORD PTR [rsp+0x48]
    2249:	mov    QWORD PTR [rsp+0x38],r9
    224e:	mov    rdx,QWORD PTR [rsp+0x60]
    2253:	mov    rsi,rbx
    2256:	mov    rdi,r12
    2259:	call   225e <botlish_fn_17+0xd8>
			225a: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    225e:	test   rax,rax
    2261:	je     2315 <botlish_fn_17+0x18f>
    2267:	mov    QWORD PTR [rsp+0x8],rax
    226c:	mov    r8,rax
    226f:	mov    QWORD PTR [rsp+0x28],rdx
    2274:	mov    QWORD PTR [rsp+0x60],rdx
    2279:	lea    r9,[rsp+0x50]
    227e:	mov    rcx,r13
    2281:	mov    rdx,r14
    2284:	mov    rsi,r15
    2287:	mov    rdi,r12
    228a:	call   228f <botlish_fn_17+0x109>
			228b: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[List[never], mutarray, int], list>
    228f:	test   rax,rax
    2292:	je     2315 <botlish_fn_17+0x18f>
    2298:	mov    QWORD PTR [rsp+0x8],rax
    229d:	mov    rcx,rax
    22a0:	mov    r8,QWORD PTR [rsp+0x50]
    22a5:	mov    QWORD PTR [rsp+0x10],r8
    22aa:	mov    r9,QWORD PTR [rsp+0x58]
    22af:	mov    QWORD PTR [rsp+0x18],r9
    22b4:	mov    rdx,QWORD PTR [rsp+0x60]
    22b9:	mov    rsi,rbx
    22bc:	mov    rdi,r12
    22bf:	call   22c4 <botlish_fn_17+0x13e>
			22c0: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    22c4:	test   rax,rax
    22c7:	je     2315 <botlish_fn_17+0x18f>
    22cd:	mov    rbx,QWORD PTR [rsp+0x70]
    22d2:	mov    r12,QWORD PTR [rsp+0x78]
    22d7:	mov    r13,QWORD PTR [rsp+0x80]
    22df:	mov    r14,QWORD PTR [rsp+0x88]
    22e7:	mov    r15,QWORD PTR [rsp+0x90]
    22ef:	add    rsp,0xa0
    22f6:	mov    rsp,rbp
    22f9:	pop    rbp
    22fa:	ret
    22fb:	mov    rcx,r13
    22fe:	mov    rdx,r14
    2301:	mov    rsi,r15
    2304:	mov    rdi,r12
    2307:	call   230c <botlish_fn_17+0x186>
			2308: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[List[never], mutarray, int]>
    230c:	test   rax,rax
    230f:	jne    2346 <botlish_fn_17+0x1c0>
    2315:	xor    rax,rax
    2318:	mov    rbx,QWORD PTR [rsp+0x70]
    231d:	mov    r12,QWORD PTR [rsp+0x78]
    2322:	mov    r13,QWORD PTR [rsp+0x80]
    232a:	mov    r14,QWORD PTR [rsp+0x88]
    2332:	mov    r15,QWORD PTR [rsp+0x90]
    233a:	add    rsp,0xa0
    2341:	mov    rsp,rbp
    2344:	pop    rbp
    2345:	ret
    2346:	mov    rbx,QWORD PTR [rsp+0x70]
    234b:	mov    r12,QWORD PTR [rsp+0x78]
    2350:	mov    r13,QWORD PTR [rsp+0x80]
    2358:	mov    r14,QWORD PTR [rsp+0x88]
    2360:	mov    r15,QWORD PTR [rsp+0x90]
    2368:	add    rsp,0xa0
    236f:	mov    rsp,rbp
    2372:	pop    rbp
    2373:	ret

0000000000002374 <botlish_entry_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    2374:	push   rbp
    2375:	mov    rbp,rsp
    2378:	mov    rsi,QWORD PTR [rdx]
    237b:	mov    r10,QWORD PTR [rdx+0x8]
    237f:	mov    rcx,QWORD PTR [rdx+0x10]
    2383:	mov    r8,QWORD PTR [rdx+0x18]
    2387:	mov    r9,QWORD PTR [rdx+0x20]
    238b:	mov    rdx,r10
    238e:	call   2393 <botlish_entry_17+0x1f>
			238f: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    2393:	mov    rsp,rbp
    2396:	pop    rbp
    2397:	ret

0000000000002398 <botlish_fn_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    2398:	push   rbp
    2399:	mov    rbp,rsp
    239c:	sub    rsp,0xb0
    23a3:	mov    QWORD PTR [rsp+0x80],rbx
    23ab:	mov    QWORD PTR [rsp+0x88],r12
    23b3:	mov    QWORD PTR [rsp+0x90],r13
    23bb:	mov    QWORD PTR [rsp+0x98],r14
    23c3:	mov    QWORD PTR [rsp+0xa0],r15
    23cb:	mov    r15,rdi
    23ce:	mov    QWORD PTR [rsp+0x28],0x0
    23d7:	mov    QWORD PTR [rsp+0x30],0x0
    23e0:	mov    QWORD PTR [rsp+0x38],0x0
    23e9:	mov    QWORD PTR [rsp],rsi
    23ed:	mov    QWORD PTR [rsp+0x8],rdx
    23f2:	mov    r14,rdx
    23f5:	mov    QWORD PTR [rsp+0x10],rcx
    23fa:	mov    QWORD PTR [rsp+0x18],r8
    23ff:	mov    QWORD PTR [rsp+0x20],r9
    2404:	lea    r13,[rsp+0x40]
    2409:	lea    rbx,[rsp+0x50]
    240e:	mov    r12,rsi
    2411:	mov    QWORD PTR [rsp+0x60],rcx
    2416:	mov    QWORD PTR [rsp+0x68],r8
    241b:	mov    QWORD PTR [rsp+0x70],r9
    2420:	mov    rsi,r12
    2423:	mov    rdi,r15
    2426:	call   242b <botlish_fn_18+0x93>
			2427: R_X86_64_PLT32	rt_str_len-0x4
    242b:	mov    rcx,r14
    242e:	and    rcx,rax
    2431:	mov    rdx,rax
    2434:	test   rcx,0x1
    243b:	jne    2461 <botlish_fn_18+0xc9>
    2441:	mov    rsi,r14
    2444:	mov    rdi,r15
    2447:	call   244c <botlish_fn_18+0xb4>
			2448: R_X86_64_PLT32	rt_int_cmp-0x4
    244c:	mov    ecx,0x2
    2451:	test   rax,rax
    2454:	cmovge rcx,QWORD PTR [rip+0x164]        # 25c0 <botlish_fn_18+0x228>
    245c:	jmp    2474 <botlish_fn_18+0xdc>
    2461:	mov    ecx,0x2
    2466:	mov    rdi,r14
    2469:	cmp    rdi,rdx
    246c:	cmovge rcx,QWORD PTR [rip+0x14c]        # 25c0 <botlish_fn_18+0x228>
    2474:	cmp    rcx,0x6
    2478:	je     2531 <botlish_fn_18+0x199>
    247e:	mov    rsi,r13
    2481:	mov    rdi,r15
    2484:	call   2489 <botlish_fn_18+0xf1>
			2485: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2489:	test   rax,rax
    248c:	je     2551 <botlish_fn_18+0x1b9>
    2492:	mov    QWORD PTR [rsp+0x28],rax
    2497:	mov    rcx,rax
    249a:	mov    r8,QWORD PTR [rsp+0x40]
    249f:	mov    QWORD PTR [rsp+0x30],r8
    24a4:	mov    r9,QWORD PTR [rsp+0x48]
    24a9:	mov    QWORD PTR [rsp+0x38],r9
    24ae:	mov    rdx,r14
    24b1:	mov    rsi,r12
    24b4:	mov    rdi,r15
    24b7:	call   24bc <botlish_fn_18+0x124>
			24b8: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    24bc:	test   rax,rax
    24bf:	je     2551 <botlish_fn_18+0x1b9>
    24c5:	mov    QWORD PTR [rsp+0x8],rax
    24ca:	mov    r8,rax
    24cd:	mov    QWORD PTR [rsp+0x28],rdx
    24d2:	mov    r14,rdx
    24d5:	mov    rsi,QWORD PTR [rsp+0x60]
    24da:	mov    rdx,QWORD PTR [rsp+0x68]
    24df:	mov    rcx,QWORD PTR [rsp+0x70]
    24e4:	mov    rdi,r15
    24e7:	mov    r9,rbx
    24ea:	call   24ef <botlish_fn_18+0x157>
			24eb: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[List[mutarray], mutarray, int], list>
    24ef:	test   rax,rax
    24f2:	je     2551 <botlish_fn_18+0x1b9>
    24f8:	mov    rdx,QWORD PTR [rsp+0x50]
    24fd:	mov    rcx,QWORD PTR [rsp+0x58]
    2502:	mov    QWORD PTR [rsp],r12
    2506:	mov    rsi,r14
    2509:	mov    QWORD PTR [rsp+0x8],rsi
    250e:	mov    QWORD PTR [rsp+0x10],rax
    2513:	mov    QWORD PTR [rsp+0x18],rdx
    2518:	mov    QWORD PTR [rsp+0x20],rcx
    251d:	mov    QWORD PTR [rsp+0x60],rax
    2522:	mov    QWORD PTR [rsp+0x68],rdx
    2527:	mov    QWORD PTR [rsp+0x70],rcx
    252c:	jmp    2420 <botlish_fn_18+0x88>
    2531:	mov    rcx,QWORD PTR [rsp+0x70]
    2536:	mov    rdx,QWORD PTR [rsp+0x68]
    253b:	mov    rsi,QWORD PTR [rsp+0x60]
    2540:	mov    rdi,r15
    2543:	call   2548 <botlish_fn_18+0x1b0>
			2544: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    2548:	test   rax,rax
    254b:	jne    2588 <botlish_fn_18+0x1f0>
    2551:	xor    rax,rax
    2554:	mov    rbx,QWORD PTR [rsp+0x80]
    255c:	mov    r12,QWORD PTR [rsp+0x88]
    2564:	mov    r13,QWORD PTR [rsp+0x90]
    256c:	mov    r14,QWORD PTR [rsp+0x98]
    2574:	mov    r15,QWORD PTR [rsp+0xa0]
    257c:	add    rsp,0xb0
    2583:	mov    rsp,rbp
    2586:	pop    rbp
    2587:	ret
    2588:	mov    rbx,QWORD PTR [rsp+0x80]
    2590:	mov    r12,QWORD PTR [rsp+0x88]
    2598:	mov    r13,QWORD PTR [rsp+0x90]
    25a0:	mov    r14,QWORD PTR [rsp+0x98]
    25a8:	mov    r15,QWORD PTR [rsp+0xa0]
    25b0:	add    rsp,0xb0
    25b7:	mov    rsp,rbp
    25ba:	pop    rbp
    25bb:	ret
    25bc:	add    BYTE PTR [rax],al
    25be:	add    BYTE PTR [rax],al
    25c0:	(bad)
    25c1:	add    BYTE PTR [rax],al
    25c3:	add    BYTE PTR [rax],al
    25c5:	add    BYTE PTR [rax],al
	...

00000000000025c8 <botlish_entry_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    25c8:	push   rbp
    25c9:	mov    rbp,rsp
    25cc:	mov    rsi,QWORD PTR [rdx]
    25cf:	mov    r10,QWORD PTR [rdx+0x8]
    25d3:	mov    rcx,QWORD PTR [rdx+0x10]
    25d7:	mov    r8,QWORD PTR [rdx+0x18]
    25db:	mov    r9,QWORD PTR [rdx+0x20]
    25df:	mov    rdx,r10
    25e2:	call   25e7 <botlish_entry_18+0x1f>
			25e3: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    25e7:	mov    rsp,rbp
    25ea:	pop    rbp
    25eb:	ret

00000000000025ec <botlish_fn_19: csv_parse<str>>:
    25ec:	push   rbp
    25ed:	mov    rbp,rsp
    25f0:	sub    rsp,0x50
    25f4:	mov    QWORD PTR [rsp+0x40],r12
    25f9:	mov    QWORD PTR [rsp+0x48],r13
    25fe:	mov    r13,rdi
    2601:	mov    QWORD PTR [rsp+0x10],0x0
    260a:	mov    QWORD PTR [rsp+0x18],0x0
    2613:	mov    QWORD PTR [rsp+0x20],0x0
    261c:	mov    QWORD PTR [rsp],rsi
    2620:	mov    r12,rsi
    2623:	mov    QWORD PTR [rsp+0x8],0x1
    262c:	lea    rsi,[rsp+0x28]
    2631:	mov    rdi,r13
    2634:	call   2639 <botlish_fn_19+0x4d>
			2635: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2639:	test   rax,rax
    263c:	je     2677 <botlish_fn_19+0x8b>
    2642:	mov    QWORD PTR [rsp+0x10],rax
    2647:	mov    rcx,rax
    264a:	mov    r8,QWORD PTR [rsp+0x28]
    264f:	mov    QWORD PTR [rsp+0x18],r8
    2654:	mov    r9,QWORD PTR [rsp+0x30]
    2659:	mov    QWORD PTR [rsp+0x20],r9
    265e:	mov    edx,0x1
    2663:	mov    rsi,r12
    2666:	mov    rdi,r13
    2669:	call   266e <botlish_fn_19+0x82>
			266a: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    266e:	test   rax,rax
    2671:	jne    268d <botlish_fn_19+0xa1>
    2677:	xor    rax,rax
    267a:	mov    r12,QWORD PTR [rsp+0x40]
    267f:	mov    r13,QWORD PTR [rsp+0x48]
    2684:	add    rsp,0x50
    2688:	mov    rsp,rbp
    268b:	pop    rbp
    268c:	ret
    268d:	mov    r12,QWORD PTR [rsp+0x40]
    2692:	mov    r13,QWORD PTR [rsp+0x48]
    2697:	add    rsp,0x50
    269b:	mov    rsp,rbp
    269e:	pop    rbp
    269f:	ret

00000000000026a0 <botlish_entry_19: csv_parse<str>>:
    26a0:	push   rbp
    26a1:	mov    rbp,rsp
    26a4:	mov    rsi,QWORD PTR [rdx]
    26a7:	call   26ac <botlish_entry_19+0xc>
			26a8: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    26ac:	mov    rsp,rbp
    26af:	pop    rbp
    26b0:	ret

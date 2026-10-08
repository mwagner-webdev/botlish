; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10219  (per function: 312 195 534 534 534 534 279 418 508 540 365 438 585 1141 352 799 833 525 596 197)
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
     972:	sub    rsp,0x20
     976:	mov    QWORD PTR [rsp],rbx
     97a:	mov    QWORD PTR [rsp+0x8],r12
     97f:	mov    QWORD PTR [rsp+0x10],r13
     984:	mov    QWORD PTR [rsp+0x18],r14
     989:	mov    rbx,rdi
     98c:	mov    r12,rdx
     98f:	mov    r13,rsi
     992:	mov    r14,r8
     995:	mov    rsi,r13
     998:	mov    rdi,rbx
     99b:	call   9a0 <botlish_fn_6+0x32>
			99c: R_X86_64_PLT32	rt_list_len-0x4
     9a0:	mov    rdx,r12
     9a3:	mov    rcx,rdx
     9a6:	sar    rcx,1
     9a9:	sar    rax,1
     9ac:	cmp    rcx,rax
     9af:	jge    a31 <botlish_fn_6+0xc3>
     9b5:	test   rdx,0x1
     9bc:	jne    9ca <botlish_fn_6+0x5c>
     9c2:	mov    rsi,r13
     9c5:	jmp    9da <botlish_fn_6+0x6c>
     9ca:	mov    rsi,r13
     9cd:	mov    rax,QWORD PTR [rsi+0x8]
     9d1:	cmp    rcx,rax
     9d4:	jb     9f3 <botlish_fn_6+0x85>
     9da:	mov    rdi,rbx
     9dd:	call   9e2 <botlish_fn_6+0x74>
			9de: R_X86_64_PLT32	rt_list_get-0x4
     9e2:	test   rax,rax
     9e5:	je     a12 <botlish_fn_6+0xa4>
     9eb:	mov    rdi,rbx
     9ee:	jmp    9fe <botlish_fn_6+0x90>
     9f3:	mov    rax,QWORD PTR [rsi+0x10]
     9f7:	mov    rax,QWORD PTR [rax+rcx*8]
     9fb:	mov    rdi,rbx
     9fe:	mov    rdi,rbx
     a01:	mov    rax,QWORD PTR [rdi+0x10]
     a05:	mov    rsi,QWORD PTR [rax+0x8]
     a09:	mov    rdx,QWORD PTR [rax+0x10]
     a0d:	call   a12 <botlish_fn_6+0xa4>
			a0e: R_X86_64_PLT32	rt_raise-0x4
     a12:	xor    rax,rax
     a15:	mov    rbx,QWORD PTR [rsp]
     a19:	mov    r12,QWORD PTR [rsp+0x8]
     a1e:	mov    r13,QWORD PTR [rsp+0x10]
     a23:	mov    r14,QWORD PTR [rsp+0x18]
     a28:	add    rsp,0x20
     a2c:	mov    rsp,rbp
     a2f:	pop    rbp
     a30:	ret
     a31:	mov    rax,r14
     a34:	mov    rbx,QWORD PTR [rsp]
     a38:	mov    r12,QWORD PTR [rsp+0x8]
     a3d:	mov    r13,QWORD PTR [rsp+0x10]
     a42:	mov    r14,QWORD PTR [rsp+0x18]
     a47:	add    rsp,0x20
     a4b:	mov    rsp,rbp
     a4e:	pop    rbp
     a4f:	ret

0000000000000a50 <botlish_entry_6: chunked_copy_chunks<List[never], int, mutarray, int>>:
     a50:	push   rbp
     a51:	mov    rbp,rsp
     a54:	mov    rsi,QWORD PTR [rdx]
     a57:	mov    r9,QWORD PTR [rdx+0x8]
     a5b:	mov    rcx,QWORD PTR [rdx+0x10]
     a5f:	mov    r8,QWORD PTR [rdx+0x18]
     a63:	mov    rdx,r9
     a66:	call   a6b <botlish_entry_6+0x1b>
			a67: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_copy_chunks<List[never], int, mutarray, int>
     a6b:	mov    rsp,rbp
     a6e:	pop    rbp
     a6f:	ret

0000000000000a70 <botlish_fn_7: chunked_copy_chunks<List[mutarray], int, mutarray, int>>:
     a70:	push   rbp
     a71:	mov    rbp,rsp
     a74:	sub    rsp,0x50
     a78:	mov    QWORD PTR [rsp+0x20],rbx
     a7d:	mov    QWORD PTR [rsp+0x28],r12
     a82:	mov    QWORD PTR [rsp+0x30],r13
     a87:	mov    QWORD PTR [rsp+0x38],r14
     a8c:	mov    QWORD PTR [rsp+0x40],r15
     a91:	mov    r14,rdi
     a94:	mov    QWORD PTR [rsp],rsi
     a98:	mov    QWORD PTR [rsp+0x8],rcx
     a9d:	mov    r13,rcx
     aa0:	mov    QWORD PTR [rsp+0x10],r8
     aa5:	sar    rdx,1
     aa8:	mov    rbx,rdx
     aab:	mov    r12,rsi
     aae:	mov    r15,r8
     ab1:	mov    rsi,r12
     ab4:	mov    rdi,r14
     ab7:	call   abc <botlish_fn_7+0x4c>
			ab8: R_X86_64_PLT32	rt_list_len-0x4
     abc:	sar    rax,1
     abf:	cmp    rbx,rax
     ac2:	jge    bb1 <botlish_fn_7+0x141>
     ac8:	mov    rdx,QWORD PTR [r12+0x8]
     acd:	mov    rcx,rbx
     ad0:	shl    rcx,1
     ad3:	or     rcx,0x1
     ad7:	sar    rcx,1
     ada:	cmp    rcx,rdx
     add:	jb     b09 <botlish_fn_7+0x99>
     ae3:	mov    rdx,rbx
     ae6:	shl    rdx,1
     ae9:	or     rdx,0x1
     aed:	mov    rsi,r12
     af0:	mov    rdi,r14
     af3:	call   af8 <botlish_fn_7+0x88>
			af4: R_X86_64_PLT32	rt_list_get-0x4
     af8:	test   rax,rax
     afb:	je     b35 <botlish_fn_7+0xc5>
     b01:	mov    rcx,rax
     b04:	jmp    b12 <botlish_fn_7+0xa2>
     b09:	mov    rax,QWORD PTR [r12+0x10]
     b0e:	mov    rcx,QWORD PTR [rax+rcx*8]
     b12:	mov    r8d,0x1
     b18:	mov    r9d,0x81
     b1e:	mov    rdx,r15
     b21:	mov    rsi,r13
     b24:	mov    rdi,r14
     b27:	call   b2c <botlish_fn_7+0xbc>
			b28: R_X86_64_PLT32	rt_mutarray_copy-0x4
     b2c:	test   rax,rax
     b2f:	jne    b5a <botlish_fn_7+0xea>
     b35:	xor    rax,rax
     b38:	mov    rbx,QWORD PTR [rsp+0x20]
     b3d:	mov    r12,QWORD PTR [rsp+0x28]
     b42:	mov    r13,QWORD PTR [rsp+0x30]
     b47:	mov    r14,QWORD PTR [rsp+0x38]
     b4c:	mov    r15,QWORD PTR [rsp+0x40]
     b51:	add    rsp,0x50
     b55:	mov    rsp,rbp
     b58:	pop    rbp
     b59:	ret
     b5a:	mov    QWORD PTR [rsp+0x18],0x81
     b63:	mov    rsi,r15
     b66:	test   rsi,0x1
     b6d:	je     b87 <botlish_fn_7+0x117>
     b73:	mov    rax,rsi
     b76:	add    rax,0x80
     b7c:	seto   cl
     b7f:	test   cl,cl
     b81:	je     b94 <botlish_fn_7+0x124>
     b87:	mov    edx,0x81
     b8c:	mov    rdi,r14
     b8f:	call   b94 <botlish_fn_7+0x124>
			b90: R_X86_64_PLT32	rt_int_add-0x4
     b94:	mov    QWORD PTR [rsp],r12
     b98:	mov    QWORD PTR [rsp+0x8],r13
     b9d:	mov    QWORD PTR [rsp+0x10],rax
     ba2:	add    rbx,0x1
     ba9:	mov    r15,rax
     bac:	jmp    ab1 <botlish_fn_7+0x41>
     bb1:	mov    rax,r15
     bb4:	mov    rbx,QWORD PTR [rsp+0x20]
     bb9:	mov    r12,QWORD PTR [rsp+0x28]
     bbe:	mov    r13,QWORD PTR [rsp+0x30]
     bc3:	mov    r14,QWORD PTR [rsp+0x38]
     bc8:	mov    r15,QWORD PTR [rsp+0x40]
     bcd:	add    rsp,0x50
     bd1:	mov    rsp,rbp
     bd4:	pop    rbp
     bd5:	ret

0000000000000bd6 <botlish_entry_7: chunked_copy_chunks<List[mutarray], int, mutarray, int>>:
     bd6:	push   rbp
     bd7:	mov    rbp,rsp
     bda:	mov    rsi,QWORD PTR [rdx]
     bdd:	mov    r9,QWORD PTR [rdx+0x8]
     be1:	mov    rcx,QWORD PTR [rdx+0x10]
     be5:	mov    r8,QWORD PTR [rdx+0x18]
     be9:	mov    rdx,r9
     bec:	call   bf1 <botlish_entry_7+0x1b>
			bed: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<List[mutarray], int, mutarray, int>
     bf1:	mov    rsp,rbp
     bf4:	pop    rbp
     bf5:	ret
	...

0000000000000bf8 <botlish_fn_8: chunked_finish<list[List[never], mutarray, int]>>:
     bf8:	push   rbp
     bf9:	mov    rbp,rsp
     bfc:	sub    rsp,0x60
     c00:	mov    QWORD PTR [rsp+0x30],rbx
     c05:	mov    QWORD PTR [rsp+0x38],r12
     c0a:	mov    QWORD PTR [rsp+0x40],r13
     c0f:	mov    QWORD PTR [rsp+0x48],r14
     c14:	mov    QWORD PTR [rsp+0x50],r15
     c19:	mov    r13,rdi
     c1c:	mov    QWORD PTR [rsp],rsi
     c20:	mov    r15,rsi
     c23:	mov    QWORD PTR [rsp+0x8],rdx
     c28:	mov    r14,rdx
     c2b:	mov    QWORD PTR [rsp+0x10],rcx
     c30:	mov    r12,rcx
     c33:	mov    rsi,r15
     c36:	mov    rdi,r13
     c39:	call   c3e <botlish_fn_8+0x46>
			c3a: R_X86_64_PLT32	rt_list_len-0x4
     c3e:	mov    QWORD PTR [rsp+0x18],rax
     c43:	mov    QWORD PTR [rsp+0x20],0x81
     c4c:	test   rax,0x1
     c52:	mov    rsi,rax
     c55:	je     c82 <botlish_fn_8+0x8a>
     c5b:	mov    rcx,rsi
     c5e:	mov    rax,rcx
     c61:	sar    rax,1
     c64:	imul   QWORD PTR [rip+0x135]        # da0 <botlish_fn_8+0x1a8>
     c6b:	seto   cl
     c6e:	or     rax,0x1
     c72:	test   cl,cl
     c74:	jne    c82 <botlish_fn_8+0x8a>
     c7a:	mov    rsi,rax
     c7d:	jmp    c92 <botlish_fn_8+0x9a>
     c82:	mov    edx,0x81
     c87:	mov    rdi,r13
     c8a:	call   c8f <botlish_fn_8+0x97>
			c8b: R_X86_64_PLT32	rt_int_mul-0x4
     c8f:	mov    rsi,rax
     c92:	mov    QWORD PTR [rsp+0x18],rsi
     c97:	mov    rax,rsi
     c9a:	and    rax,r12
     c9d:	test   rax,0x1
     ca3:	je     cbf <botlish_fn_8+0xc7>
     ca9:	lea    rcx,[r12-0x1]
     cae:	mov    rbx,rsi
     cb1:	add    rbx,rcx
     cb4:	seto   al
     cb7:	test   al,al
     cb9:	je     ccd <botlish_fn_8+0xd5>
     cbf:	mov    rdx,r12
     cc2:	mov    rdi,r13
     cc5:	call   cca <botlish_fn_8+0xd2>
			cc6: R_X86_64_PLT32	rt_int_add-0x4
     cca:	mov    rbx,rax
     ccd:	mov    QWORD PTR [rsp+0x18],rbx
     cd2:	mov    rsi,rbx
     cd5:	mov    rdi,r13
     cd8:	call   cdd <botlish_fn_8+0xe5>
			cd9: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     cdd:	mov    rcx,rax
     ce0:	mov    QWORD PTR [rsp+0x28],rax
     ce5:	test   rax,rcx
     ce8:	je     d57 <botlish_fn_8+0x15f>
     cee:	mov    rax,QWORD PTR [rsp+0x28]
     cf3:	mov    QWORD PTR [rsp],rax
     cf7:	mov    r8d,0x1
     cfd:	mov    rsi,r15
     d00:	mov    rcx,QWORD PTR [rsp+0x28]
     d05:	mov    rdi,r13
     d08:	mov    rdx,r8
     d0b:	call   d10 <botlish_fn_8+0x118>
			d0c: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_copy_chunks<List[never], int, mutarray, int>
     d10:	test   rax,rax
     d13:	je     d57 <botlish_fn_8+0x15f>
     d19:	mov    r8d,0x1
     d1f:	mov    rcx,r14
     d22:	mov    r9,r12
     d25:	mov    rsi,QWORD PTR [rsp+0x28]
     d2a:	mov    rdi,r13
     d2d:	mov    rdx,r8
     d30:	call   d35 <botlish_fn_8+0x13d>
			d31: R_X86_64_PLT32	rt_mutarray_copy-0x4
     d35:	test   rax,rax
     d38:	je     d57 <botlish_fn_8+0x15f>
     d3e:	mov    rdx,rbx
     d41:	mov    rsi,QWORD PTR [rsp+0x28]
     d46:	mov    rdi,r13
     d49:	call   d4e <botlish_fn_8+0x156>
			d4a: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     d4e:	test   rax,rax
     d51:	jne    d7c <botlish_fn_8+0x184>
     d57:	xor    rax,rax
     d5a:	mov    rbx,QWORD PTR [rsp+0x30]
     d5f:	mov    r12,QWORD PTR [rsp+0x38]
     d64:	mov    r13,QWORD PTR [rsp+0x40]
     d69:	mov    r14,QWORD PTR [rsp+0x48]
     d6e:	mov    r15,QWORD PTR [rsp+0x50]
     d73:	add    rsp,0x60
     d77:	mov    rsp,rbp
     d7a:	pop    rbp
     d7b:	ret
     d7c:	mov    rbx,QWORD PTR [rsp+0x30]
     d81:	mov    r12,QWORD PTR [rsp+0x38]
     d86:	mov    r13,QWORD PTR [rsp+0x40]
     d8b:	mov    r14,QWORD PTR [rsp+0x48]
     d90:	mov    r15,QWORD PTR [rsp+0x50]
     d95:	add    rsp,0x60
     d99:	mov    rsp,rbp
     d9c:	pop    rbp
     d9d:	ret
     d9e:	add    BYTE PTR [rax],al
     da0:	add    BYTE PTR [rax],0x0
     da3:	add    BYTE PTR [rax],al
     da5:	add    BYTE PTR [rax],al
	...

0000000000000da8 <botlish_entry_8: chunked_finish<list[List[never], mutarray, int]>>:
     da8:	push   rbp
     da9:	mov    rbp,rsp
     dac:	mov    rsi,QWORD PTR [rdx]
     daf:	mov    r8,QWORD PTR [rdx+0x8]
     db3:	mov    rcx,QWORD PTR [rdx+0x10]
     db7:	mov    rdx,r8
     dba:	call   dbf <botlish_entry_8+0x17>
			dbb: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[List[never], mutarray, int]>
     dbf:	mov    rsp,rbp
     dc2:	pop    rbp
     dc3:	ret
     dc4:	add    BYTE PTR [rax],al
	...

0000000000000dc8 <botlish_fn_9: chunked_finish<list[List[mutarray], mutarray, int]>>:
     dc8:	push   rbp
     dc9:	mov    rbp,rsp
     dcc:	sub    rsp,0x70
     dd0:	mov    QWORD PTR [rsp+0x40],rbx
     dd5:	mov    QWORD PTR [rsp+0x48],r12
     dda:	mov    QWORD PTR [rsp+0x50],r13
     ddf:	mov    QWORD PTR [rsp+0x58],r14
     de4:	mov    QWORD PTR [rsp+0x60],r15
     de9:	mov    r13,rdi
     dec:	mov    QWORD PTR [rsp+0x28],0x0
     df5:	mov    QWORD PTR [rsp+0x30],0x0
     dfe:	mov    QWORD PTR [rsp],rsi
     e02:	mov    r15,rsi
     e05:	mov    QWORD PTR [rsp+0x8],rdx
     e0a:	mov    r14,rdx
     e0d:	mov    QWORD PTR [rsp+0x10],rcx
     e12:	mov    r12,rcx
     e15:	mov    rsi,r15
     e18:	mov    rdi,r13
     e1b:	call   e20 <botlish_fn_9+0x58>
			e1c: R_X86_64_PLT32	rt_list_len-0x4
     e20:	mov    QWORD PTR [rsp+0x18],rax
     e25:	mov    QWORD PTR [rsp+0x20],0x81
     e2e:	test   rax,0x1
     e34:	mov    rsi,rax
     e37:	je     e64 <botlish_fn_9+0x9c>
     e3d:	mov    rdx,rsi
     e40:	mov    rax,rdx
     e43:	sar    rax,1
     e46:	imul   QWORD PTR [rip+0x14b]        # f98 <botlish_fn_9+0x1d0>
     e4d:	seto   cl
     e50:	or     rax,0x1
     e54:	test   cl,cl
     e56:	jne    e64 <botlish_fn_9+0x9c>
     e5c:	mov    rsi,rax
     e5f:	jmp    e74 <botlish_fn_9+0xac>
     e64:	mov    edx,0x81
     e69:	mov    rdi,r13
     e6c:	call   e71 <botlish_fn_9+0xa9>
			e6d: R_X86_64_PLT32	rt_int_mul-0x4
     e71:	mov    rsi,rax
     e74:	mov    QWORD PTR [rsp+0x18],rsi
     e79:	mov    rax,rsi
     e7c:	and    rax,r12
     e7f:	test   rax,0x1
     e85:	je     ea1 <botlish_fn_9+0xd9>
     e8b:	lea    rcx,[r12-0x1]
     e90:	mov    rbx,rsi
     e93:	add    rbx,rcx
     e96:	seto   al
     e99:	test   al,al
     e9b:	je     eaf <botlish_fn_9+0xe7>
     ea1:	mov    rdx,r12
     ea4:	mov    rdi,r13
     ea7:	call   eac <botlish_fn_9+0xe4>
			ea8: R_X86_64_PLT32	rt_int_add-0x4
     eac:	mov    rbx,rax
     eaf:	mov    QWORD PTR [rsp+0x18],rbx
     eb4:	mov    rsi,rbx
     eb7:	mov    rdi,r13
     eba:	call   ebf <botlish_fn_9+0xf7>
			ebb: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     ebf:	mov    rcx,rax
     ec2:	mov    QWORD PTR [rsp+0x38],rax
     ec7:	test   rax,rcx
     eca:	je     f4c <botlish_fn_9+0x184>
     ed0:	mov    rax,QWORD PTR [rsp+0x38]
     ed5:	mov    QWORD PTR [rsp+0x20],rax
     eda:	mov    r8d,0x1
     ee0:	mov    QWORD PTR [rsp+0x28],0x1
     ee9:	mov    QWORD PTR [rsp+0x30],0x1
     ef2:	mov    rsi,r15
     ef5:	mov    rcx,QWORD PTR [rsp+0x38]
     efa:	mov    rdi,r13
     efd:	mov    rdx,r8
     f00:	call   f05 <botlish_fn_9+0x13d>
			f01: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<List[mutarray], int, mutarray, int>
     f05:	test   rax,rax
     f08:	mov    rdx,rax
     f0b:	je     f4c <botlish_fn_9+0x184>
     f11:	mov    r8d,0x1
     f17:	mov    rcx,r14
     f1a:	mov    r9,r12
     f1d:	mov    rsi,QWORD PTR [rsp+0x38]
     f22:	mov    rdi,r13
     f25:	call   f2a <botlish_fn_9+0x162>
			f26: R_X86_64_PLT32	rt_mutarray_copy-0x4
     f2a:	test   rax,rax
     f2d:	je     f4c <botlish_fn_9+0x184>
     f33:	mov    rdx,rbx
     f36:	mov    rsi,QWORD PTR [rsp+0x38]
     f3b:	mov    rdi,r13
     f3e:	call   f43 <botlish_fn_9+0x17b>
			f3f: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     f43:	test   rax,rax
     f46:	jne    f71 <botlish_fn_9+0x1a9>
     f4c:	xor    rax,rax
     f4f:	mov    rbx,QWORD PTR [rsp+0x40]
     f54:	mov    r12,QWORD PTR [rsp+0x48]
     f59:	mov    r13,QWORD PTR [rsp+0x50]
     f5e:	mov    r14,QWORD PTR [rsp+0x58]
     f63:	mov    r15,QWORD PTR [rsp+0x60]
     f68:	add    rsp,0x70
     f6c:	mov    rsp,rbp
     f6f:	pop    rbp
     f70:	ret
     f71:	mov    rbx,QWORD PTR [rsp+0x40]
     f76:	mov    r12,QWORD PTR [rsp+0x48]
     f7b:	mov    r13,QWORD PTR [rsp+0x50]
     f80:	mov    r14,QWORD PTR [rsp+0x58]
     f85:	mov    r15,QWORD PTR [rsp+0x60]
     f8a:	add    rsp,0x70
     f8e:	mov    rsp,rbp
     f91:	pop    rbp
     f92:	ret
     f93:	add    BYTE PTR [rax],al
     f95:	add    BYTE PTR [rax],al
     f97:	add    BYTE PTR [rax+0x0],al
     f9d:	add    BYTE PTR [rax],al
	...

0000000000000fa0 <botlish_entry_9: chunked_finish<list[List[mutarray], mutarray, int]>>:
     fa0:	push   rbp
     fa1:	mov    rbp,rsp
     fa4:	mov    rsi,QWORD PTR [rdx]
     fa7:	mov    r8,QWORD PTR [rdx+0x8]
     fab:	mov    rcx,QWORD PTR [rdx+0x10]
     faf:	mov    rdx,r8
     fb2:	call   fb7 <botlish_entry_9+0x17>
			fb3: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
     fb7:	mov    rsp,rbp
     fba:	pop    rbp
     fbb:	ret
     fbc:	add    BYTE PTR [rax],al
	...

0000000000000fc0 <botlish_fn_10: peek<str, int>>:
     fc0:	push   rbp
     fc1:	mov    rbp,rsp
     fc4:	sub    rsp,0x40
     fc8:	mov    QWORD PTR [rsp+0x20],rbx
     fcd:	mov    QWORD PTR [rsp+0x28],r12
     fd2:	mov    QWORD PTR [rsp+0x30],r13
     fd7:	mov    rbx,rdx
     fda:	mov    r13,rdi
     fdd:	mov    QWORD PTR [rsp],rsi
     fe1:	mov    QWORD PTR [rsp+0x8],rdx
     fe6:	mov    rdx,QWORD PTR [rsi+0x8]
     fea:	mov    r12,rsi
     fed:	shl    rdx,1
     ff0:	mov    rax,rdx
     ff3:	or     rax,0x1
     ff7:	mov    rcx,rbx
     ffa:	and    rcx,rax
     ffd:	test   rcx,0x1
    1004:	jne    102e <botlish_fn_10+0x6e>
    100a:	or     rdx,0x1
    100e:	mov    rsi,rbx
    1011:	mov    rdi,r13
    1014:	call   1019 <botlish_fn_10+0x59>
			1015: R_X86_64_PLT32	rt_int_cmp-0x4
    1019:	mov    ecx,0x2
    101e:	test   rax,rax
    1021:	cmovge rcx,QWORD PTR [rip+0xd7]        # 1100 <botlish_fn_10+0x140>
    1029:	jmp    1042 <botlish_fn_10+0x82>
    102e:	or     rdx,0x1
    1032:	mov    ecx,0x2
    1037:	cmp    rbx,rdx
    103a:	cmovge rcx,QWORD PTR [rip+0xbe]        # 1100 <botlish_fn_10+0x140>
    1042:	cmp    rcx,0x6
    1046:	je     10d6 <botlish_fn_10+0x116>
    104c:	mov    QWORD PTR [rsp+0x10],0x3
    1055:	test   rbx,0x1
    105c:	je     1074 <botlish_fn_10+0xb4>
    1062:	mov    rcx,rbx
    1065:	add    rcx,0x2
    1069:	seto   al
    106c:	test   al,al
    106e:	je     1087 <botlish_fn_10+0xc7>
    1074:	mov    edx,0x3
    1079:	mov    rsi,rbx
    107c:	mov    rdi,r13
    107f:	call   1084 <botlish_fn_10+0xc4>
			1080: R_X86_64_PLT32	rt_int_add-0x4
    1084:	mov    rcx,rax
    1087:	mov    QWORD PTR [rsp+0x10],rcx
    108c:	mov    rdx,rbx
    108f:	mov    rsi,r12
    1092:	mov    rdi,r13
    1095:	call   109a <botlish_fn_10+0xda>
			1096: R_X86_64_PLT32	rt_substr-0x4
    109a:	test   rax,rax
    109d:	jne    10be <botlish_fn_10+0xfe>
    10a3:	xor    rax,rax
    10a6:	mov    rbx,QWORD PTR [rsp+0x20]
    10ab:	mov    r12,QWORD PTR [rsp+0x28]
    10b0:	mov    r13,QWORD PTR [rsp+0x30]
    10b5:	add    rsp,0x40
    10b9:	mov    rsp,rbp
    10bc:	pop    rbp
    10bd:	ret
    10be:	mov    rbx,QWORD PTR [rsp+0x20]
    10c3:	mov    r12,QWORD PTR [rsp+0x28]
    10c8:	mov    r13,QWORD PTR [rsp+0x30]
    10cd:	add    rsp,0x40
    10d1:	mov    rsp,rbp
    10d4:	pop    rbp
    10d5:	ret
    10d6:	mov    rdi,r13
    10d9:	mov    rax,QWORD PTR [rdi+0x10]
    10dd:	mov    rax,QWORD PTR [rax+0x18]
    10e1:	mov    rbx,QWORD PTR [rsp+0x20]
    10e6:	mov    r12,QWORD PTR [rsp+0x28]
    10eb:	mov    r13,QWORD PTR [rsp+0x30]
    10f0:	add    rsp,0x40
    10f4:	mov    rsp,rbp
    10f7:	pop    rbp
    10f8:	ret
    10f9:	add    BYTE PTR [rax],al
    10fb:	add    BYTE PTR [rax],al
    10fd:	add    BYTE PTR [rax],al
    10ff:	add    BYTE PTR [rsi],al
    1101:	add    BYTE PTR [rax],al
    1103:	add    BYTE PTR [rax],al
    1105:	add    BYTE PTR [rax],al
	...

0000000000001108 <botlish_entry_10: peek<str, int>>:
    1108:	push   rbp
    1109:	mov    rbp,rsp
    110c:	mov    rsi,QWORD PTR [rdx]
    110f:	mov    rdx,QWORD PTR [rdx+0x8]
    1113:	call   1118 <botlish_entry_10+0x10>
			1114: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    1118:	mov    rsp,rbp
    111b:	pop    rbp
    111c:	ret
    111d:	add    BYTE PTR [rax],al
	...

0000000000001120 <botlish_fn_11: peek<str, int>>:
    1120:	push   rbp
    1121:	mov    rbp,rsp
    1124:	sub    rsp,0x50
    1128:	mov    QWORD PTR [rsp+0x20],rbx
    112d:	mov    QWORD PTR [rsp+0x28],r12
    1132:	mov    QWORD PTR [rsp+0x30],r13
    1137:	mov    QWORD PTR [rsp+0x38],r14
    113c:	mov    QWORD PTR [rsp+0x40],r15
    1141:	mov    rbx,rdx
    1144:	mov    r12,rcx
    1147:	mov    r14,rdi
    114a:	mov    QWORD PTR [rsp],rsi
    114e:	mov    QWORD PTR [rsp+0x8],rdx
    1153:	mov    rdx,QWORD PTR [rsi+0x8]
    1157:	mov    r13,rsi
    115a:	shl    rdx,1
    115d:	mov    rax,rdx
    1160:	or     rax,0x1
    1164:	mov    rcx,rbx
    1167:	and    rcx,rax
    116a:	test   rcx,0x1
    1171:	jne    119b <botlish_fn_11+0x7b>
    1177:	or     rdx,0x1
    117b:	mov    rsi,rbx
    117e:	mov    rdi,r14
    1181:	call   1186 <botlish_fn_11+0x66>
			1182: R_X86_64_PLT32	rt_int_cmp-0x4
    1186:	mov    ecx,0x2
    118b:	test   rax,rax
    118e:	cmovge rcx,QWORD PTR [rip+0x122]        # 12b8 <botlish_fn_11+0x198>
    1196:	jmp    11af <botlish_fn_11+0x8f>
    119b:	or     rdx,0x1
    119f:	mov    ecx,0x2
    11a4:	cmp    rbx,rdx
    11a7:	cmovge rcx,QWORD PTR [rip+0x109]        # 12b8 <botlish_fn_11+0x198>
    11af:	cmp    rcx,0x6
    11b3:	je     1273 <botlish_fn_11+0x153>
    11b9:	mov    QWORD PTR [rsp+0x10],0x3
    11c2:	test   rbx,0x1
    11c9:	je     11ec <botlish_fn_11+0xcc>
    11cf:	mov    rax,rbx
    11d2:	add    rax,0x2
    11d6:	seto   cl
    11d9:	test   cl,cl
    11db:	jne    11ec <botlish_fn_11+0xcc>
    11e1:	mov    rdi,r14
    11e4:	mov    r15,rax
    11e7:	jmp    1202 <botlish_fn_11+0xe2>
    11ec:	mov    edx,0x3
    11f1:	mov    rsi,rbx
    11f4:	mov    rdi,r14
    11f7:	call   11fc <botlish_fn_11+0xdc>
			11f8: R_X86_64_PLT32	rt_int_add-0x4
    11fc:	mov    r15,rax
    11ff:	mov    rdi,r14
    1202:	mov    rdi,r14
    1205:	mov    rcx,r15
    1208:	mov    rdx,rbx
    120b:	mov    rsi,r13
    120e:	call   1213 <botlish_fn_11+0xf3>
			120f: R_X86_64_PLT32	rt_str_region_check-0x4
    1213:	test   rax,rax
    1216:	jne    1241 <botlish_fn_11+0x121>
    121c:	xor    rax,rax
    121f:	mov    rbx,QWORD PTR [rsp+0x20]
    1224:	mov    r12,QWORD PTR [rsp+0x28]
    1229:	mov    r13,QWORD PTR [rsp+0x30]
    122e:	mov    r14,QWORD PTR [rsp+0x38]
    1233:	mov    r15,QWORD PTR [rsp+0x40]
    1238:	add    rsp,0x50
    123c:	mov    rsp,rbp
    123f:	pop    rbp
    1240:	ret
    1241:	mov    rcx,r12
    1244:	mov    QWORD PTR [rcx],rbx
    1247:	mov    rax,r15
    124a:	mov    QWORD PTR [rcx+0x8],rax
    124e:	mov    rax,r13
    1251:	mov    rbx,QWORD PTR [rsp+0x20]
    1256:	mov    r12,QWORD PTR [rsp+0x28]
    125b:	mov    r13,QWORD PTR [rsp+0x30]
    1260:	mov    r14,QWORD PTR [rsp+0x38]
    1265:	mov    r15,QWORD PTR [rsp+0x40]
    126a:	add    rsp,0x50
    126e:	mov    rsp,rbp
    1271:	pop    rbp
    1272:	ret
    1273:	mov    rcx,r12
    1276:	mov    rdi,r14
    1279:	mov    rax,QWORD PTR [rdi+0x10]
    127d:	mov    rax,QWORD PTR [rax+0x18]
    1281:	mov    QWORD PTR [rcx],0x1
    1288:	mov    QWORD PTR [rcx+0x8],0x1
    1290:	mov    rbx,QWORD PTR [rsp+0x20]
    1295:	mov    r12,QWORD PTR [rsp+0x28]
    129a:	mov    r13,QWORD PTR [rsp+0x30]
    129f:	mov    r14,QWORD PTR [rsp+0x38]
    12a4:	mov    r15,QWORD PTR [rsp+0x40]
    12a9:	add    rsp,0x50
    12ad:	mov    rsp,rbp
    12b0:	pop    rbp
    12b1:	ret
    12b2:	add    BYTE PTR [rax],al
    12b4:	add    BYTE PTR [rax],al
    12b6:	add    BYTE PTR [rax],al
    12b8:	(bad)
    12b9:	add    BYTE PTR [rax],al
    12bb:	add    BYTE PTR [rax],al
    12bd:	add    BYTE PTR [rax],al
	...

00000000000012c0 <botlish_entry_11: peek<str, int>>:
    12c0:	push   rbp
    12c1:	mov    rbp,rsp
    12c4:	ud2

00000000000012c6 <botlish_fn_12: scan_unquoted<str, int, int>>:
    12c6:	push   rbp
    12c7:	mov    rbp,rsp
    12ca:	sub    rsp,0x80
    12d1:	mov    QWORD PTR [rsp+0x50],rbx
    12d6:	mov    QWORD PTR [rsp+0x58],r12
    12db:	mov    QWORD PTR [rsp+0x60],r13
    12e0:	mov    QWORD PTR [rsp+0x68],r14
    12e5:	mov    QWORD PTR [rsp+0x70],r15
    12ea:	mov    QWORD PTR [rsp+0x30],rdi
    12ef:	mov    QWORD PTR [rsp+0x18],0x0
    12f8:	mov    QWORD PTR [rsp],rsi
    12fc:	mov    r15,rsi
    12ff:	mov    QWORD PTR [rsp+0x8],rdx
    1304:	mov    r14,rdx
    1307:	mov    QWORD PTR [rsp+0x10],rcx
    130c:	lea    r13,[rsp+0x20]
    1311:	mov    QWORD PTR [rsp+0x38],rcx
    1316:	mov    rcx,r13
    1319:	mov    rdx,QWORD PTR [rsp+0x38]
    131e:	mov    rsi,r15
    1321:	mov    rdi,QWORD PTR [rsp+0x30]
    1326:	call   132b <botlish_fn_12+0x65>
			1327: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    132b:	mov    rsi,rax
    132e:	mov    QWORD PTR [rsp+0x40],rax
    1333:	test   rax,rsi
    1336:	je     1490 <botlish_fn_12+0x1ca>
    133c:	mov    rbx,QWORD PTR [rsp+0x20]
    1341:	mov    r12,QWORD PTR [rsp+0x28]
    1346:	mov    rdi,QWORD PTR [rsp+0x30]
    134b:	mov    rcx,QWORD PTR [rdi+0x10]
    134f:	mov    r8,QWORD PTR [rcx+0x18]
    1353:	mov    rcx,r12
    1356:	mov    rdx,rbx
    1359:	mov    rsi,QWORD PTR [rsp+0x40]
    135e:	call   1363 <botlish_fn_12+0x9d>
			135f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1363:	cmp    rax,0x6
    1367:	je     13a8 <botlish_fn_12+0xe2>
    136d:	mov    rdi,QWORD PTR [rsp+0x30]
    1372:	mov    rax,QWORD PTR [rdi+0x10]
    1376:	mov    r8,QWORD PTR [rax+0x20]
    137a:	mov    rcx,r12
    137d:	mov    rdx,rbx
    1380:	mov    rsi,QWORD PTR [rsp+0x40]
    1385:	call   138a <botlish_fn_12+0xc4>
			1386: R_X86_64_PLT32	rt_str_region_eq-0x4
    138a:	cmp    rax,0x6
    138e:	je     139e <botlish_fn_12+0xd8>
    1394:	mov    eax,0x2
    1399:	jmp    13ad <botlish_fn_12+0xe7>
    139e:	mov    eax,0x6
    13a3:	jmp    13ad <botlish_fn_12+0xe7>
    13a8:	mov    eax,0x6
    13ad:	cmp    rax,0x6
    13b1:	je     13f2 <botlish_fn_12+0x12c>
    13b7:	mov    rdi,QWORD PTR [rsp+0x30]
    13bc:	mov    rax,QWORD PTR [rdi+0x10]
    13c0:	mov    r8,QWORD PTR [rax+0x28]
    13c4:	mov    rcx,r12
    13c7:	mov    rdx,rbx
    13ca:	mov    rsi,QWORD PTR [rsp+0x40]
    13cf:	call   13d4 <botlish_fn_12+0x10e>
			13d0: R_X86_64_PLT32	rt_str_region_eq-0x4
    13d4:	cmp    rax,0x6
    13d8:	je     13e8 <botlish_fn_12+0x122>
    13de:	mov    eax,0x2
    13e3:	jmp    13f7 <botlish_fn_12+0x131>
    13e8:	mov    eax,0x6
    13ed:	jmp    13f7 <botlish_fn_12+0x131>
    13f2:	mov    eax,0x6
    13f7:	cmp    rax,0x6
    13fb:	je     1472 <botlish_fn_12+0x1ac>
    1401:	mov    QWORD PTR [rsp+0x18],0x3
    140a:	mov    rsi,QWORD PTR [rsp+0x38]
    140f:	test   rsi,0x1
    1416:	je     143d <botlish_fn_12+0x177>
    141c:	mov    rsi,QWORD PTR [rsp+0x38]
    1421:	mov    rax,rsi
    1424:	add    rax,0x2
    1428:	seto   sil
    142c:	test   sil,sil
    142f:	jne    143d <botlish_fn_12+0x177>
    1435:	mov    rsi,r15
    1438:	jmp    1454 <botlish_fn_12+0x18e>
    143d:	mov    edx,0x3
    1442:	mov    rsi,QWORD PTR [rsp+0x38]
    1447:	mov    rdi,QWORD PTR [rsp+0x30]
    144c:	call   1451 <botlish_fn_12+0x18b>
			144d: R_X86_64_PLT32	rt_int_add-0x4
    1451:	mov    rsi,r15
    1454:	mov    QWORD PTR [rsp],rsi
    1458:	mov    rdx,r14
    145b:	mov    QWORD PTR [rsp+0x8],rdx
    1460:	mov    QWORD PTR [rsp+0x10],rax
    1465:	mov    r15,rsi
    1468:	mov    QWORD PTR [rsp+0x38],rax
    146d:	jmp    1316 <botlish_fn_12+0x50>
    1472:	mov    rdx,r14
    1475:	mov    rsi,r15
    1478:	mov    rdi,QWORD PTR [rsp+0x30]
    147d:	mov    rcx,QWORD PTR [rsp+0x38]
    1482:	call   1487 <botlish_fn_12+0x1c1>
			1483: R_X86_64_PLT32	rt_substr-0x4
    1487:	test   rax,rax
    148a:	jne    14bb <botlish_fn_12+0x1f5>
    1490:	xor    rdx,rdx
    1493:	mov    rax,rdx
    1496:	mov    rbx,QWORD PTR [rsp+0x50]
    149b:	mov    r12,QWORD PTR [rsp+0x58]
    14a0:	mov    r13,QWORD PTR [rsp+0x60]
    14a5:	mov    r14,QWORD PTR [rsp+0x68]
    14aa:	mov    r15,QWORD PTR [rsp+0x70]
    14af:	add    rsp,0x80
    14b6:	mov    rsp,rbp
    14b9:	pop    rbp
    14ba:	ret
    14bb:	mov    rdx,QWORD PTR [rsp+0x38]
    14c0:	mov    rbx,QWORD PTR [rsp+0x50]
    14c5:	mov    r12,QWORD PTR [rsp+0x58]
    14ca:	mov    r13,QWORD PTR [rsp+0x60]
    14cf:	mov    r14,QWORD PTR [rsp+0x68]
    14d4:	mov    r15,QWORD PTR [rsp+0x70]
    14d9:	add    rsp,0x80
    14e0:	mov    rsp,rbp
    14e3:	pop    rbp
    14e4:	ret

00000000000014e5 <botlish_entry_12: scan_unquoted<str, int, int>>:
    14e5:	push   rbp
    14e6:	mov    rbp,rsp
    14e9:	ud2

00000000000014eb <botlish_fn_13: scan_quoted<str, int, str>>:
    14eb:	push   rbp
    14ec:	mov    rbp,rsp
    14ef:	sub    rsp,0xd0
    14f6:	mov    QWORD PTR [rsp+0xa0],rbx
    14fe:	mov    QWORD PTR [rsp+0xa8],r12
    1506:	mov    QWORD PTR [rsp+0xb0],r13
    150e:	mov    QWORD PTR [rsp+0xb8],r14
    1516:	mov    QWORD PTR [rsp+0xc0],r15
    151e:	mov    QWORD PTR [rsp+0x88],rdi
    1526:	mov    QWORD PTR [rsp+0x18],0x0
    152f:	mov    QWORD PTR [rsp+0x20],0x0
    1538:	mov    QWORD PTR [rsp],rsi
    153c:	mov    QWORD PTR [rsp+0x8],rdx
    1541:	mov    QWORD PTR [rsp+0x10],rcx
    1546:	mov    r13,rcx
    1549:	lea    r14,[rsp+0x68]
    154e:	lea    rbx,[rsp+0x28]
    1553:	mov    r12,rsi
    1556:	mov    QWORD PTR [rsp+0x90],rdx
    155e:	mov    rdx,QWORD PTR [rsp+0x90]
    1566:	mov    rsi,r12
    1569:	mov    rdi,QWORD PTR [rsp+0x88]
    1571:	call   1576 <botlish_fn_13+0x8b>
			1572: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    1576:	test   rax,rax
    1579:	je     18c2 <botlish_fn_13+0x3d7>
    157f:	mov    QWORD PTR [rsp+0x18],rax
    1584:	mov    rsi,QWORD PTR [rax+0x8]
    1588:	mov    rcx,rax
    158b:	mov    rax,0xffffffffffffffff
    1592:	test   rsi,rsi
    1595:	jne    15a3 <botlish_fn_13+0xb8>
    159b:	mov    r15,rcx
    159e:	jmp    15ce <botlish_fn_13+0xe3>
    15a3:	mov    r15,rcx
    15a6:	movzx  rdi,BYTE PTR [r15+0x18]
    15ab:	test   rdi,rdi
    15ae:	jne    15c9 <botlish_fn_13+0xde>
    15b4:	mov    rsi,r15
    15b7:	mov    rdi,QWORD PTR [rsp+0x88]
    15bf:	call   15c4 <botlish_fn_13+0xd9>
			15c0: R_X86_64_PLT32	rt_str_to_short-0x4
    15c4:	jmp    15ce <botlish_fn_13+0xe3>
    15c9:	movzx  rax,BYTE PTR [r15+0x19]
    15ce:	cmp    rax,0x22
    15d2:	je     1692 <botlish_fn_13+0x1a7>
    15d8:	mov    QWORD PTR [rsp+0x20],0x3
    15e1:	mov    rsi,QWORD PTR [rsp+0x90]
    15e9:	test   rsi,0x1
    15f0:	je     1610 <botlish_fn_13+0x125>
    15f6:	mov    rax,rsi
    15f9:	add    rax,0x2
    15fd:	seto   cl
    1600:	test   cl,cl
    1602:	jne    1610 <botlish_fn_13+0x125>
    1608:	mov    rsi,rax
    160b:	jmp    1625 <botlish_fn_13+0x13a>
    1610:	mov    edx,0x3
    1615:	mov    rdi,QWORD PTR [rsp+0x88]
    161d:	call   1622 <botlish_fn_13+0x137>
			161e: R_X86_64_PLT32	rt_int_add-0x4
    1622:	mov    rsi,rax
    1625:	mov    QWORD PTR [rsp+0x8],rsi
    162a:	mov    QWORD PTR [rsp+0x90],rsi
    1632:	mov    QWORD PTR [rsp+0x68],0x0
    163b:	mov    QWORD PTR [rsp+0x70],r13
    1640:	mov    QWORD PTR [rsp+0x78],0x0
    1649:	mov    QWORD PTR [rsp+0x80],r15
    1651:	mov    esi,0x2
    1656:	mov    edx,0x4
    165b:	mov    rcx,r14
    165e:	mov    rdi,QWORD PTR [rsp+0x88]
    1666:	call   166b <botlish_fn_13+0x180>
			1667: R_X86_64_PLT32	rt_construct-0x4
    166b:	test   rax,rax
    166e:	je     18c2 <botlish_fn_13+0x3d7>
    1674:	mov    QWORD PTR [rsp],r12
    1678:	mov    rsi,QWORD PTR [rsp+0x90]
    1680:	mov    QWORD PTR [rsp+0x8],rsi
    1685:	mov    QWORD PTR [rsp+0x10],rax
    168a:	mov    r13,rax
    168d:	jmp    155e <botlish_fn_13+0x73>
    1692:	mov    QWORD PTR [rsp+0x18],0x3
    169b:	mov    rsi,QWORD PTR [rsp+0x90]
    16a3:	test   rsi,0x1
    16aa:	je     16ca <botlish_fn_13+0x1df>
    16b0:	mov    rsi,QWORD PTR [rsp+0x90]
    16b8:	mov    rdx,rsi
    16bb:	add    rdx,0x2
    16bf:	seto   al
    16c2:	test   al,al
    16c4:	je     16e7 <botlish_fn_13+0x1fc>
    16ca:	mov    edx,0x3
    16cf:	mov    rsi,QWORD PTR [rsp+0x90]
    16d7:	mov    rdi,QWORD PTR [rsp+0x88]
    16df:	call   16e4 <botlish_fn_13+0x1f9>
			16e0: R_X86_64_PLT32	rt_int_add-0x4
    16e4:	mov    rdx,rax
    16e7:	mov    QWORD PTR [rsp+0x18],rdx
    16ec:	mov    rcx,rbx
    16ef:	mov    rsi,r12
    16f2:	mov    rdi,QWORD PTR [rsp+0x88]
    16fa:	call   16ff <botlish_fn_13+0x214>
			16fb: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    16ff:	test   rax,rax
    1702:	mov    rsi,rax
    1705:	je     18c2 <botlish_fn_13+0x3d7>
    170b:	mov    rdx,QWORD PTR [rsp+0x28]
    1710:	mov    rcx,QWORD PTR [rsp+0x30]
    1715:	mov    rdi,QWORD PTR [rsp+0x88]
    171d:	mov    rax,QWORD PTR [rdi+0x10]
    1721:	mov    r8,QWORD PTR [rax+0x30]
    1725:	call   172a <botlish_fn_13+0x23f>
			1726: R_X86_64_PLT32	rt_str_region_eq-0x4
    172a:	cmp    rax,0x6
    172e:	je     1800 <botlish_fn_13+0x315>
    1734:	xor    rsi,rsi
    1737:	lea    rcx,[rsp+0x58]
    173c:	mov    QWORD PTR [rsp+0x58],0x0
    1745:	mov    QWORD PTR [rsp+0x60],r13
    174a:	mov    edx,0x2
    174f:	mov    rdi,QWORD PTR [rsp+0x88]
    1757:	call   175c <botlish_fn_13+0x271>
			1758: R_X86_64_PLT32	rt_construct-0x4
    175c:	test   rax,rax
    175f:	je     18c2 <botlish_fn_13+0x3d7>
    1765:	mov    QWORD PTR [rsp],rax
    1769:	mov    rbx,rax
    176c:	mov    QWORD PTR [rsp+0x10],0x3
    1775:	mov    rsi,QWORD PTR [rsp+0x90]
    177d:	test   rsi,0x1
    1784:	je     17ac <botlish_fn_13+0x2c1>
    178a:	mov    rsi,QWORD PTR [rsp+0x90]
    1792:	mov    rdx,rsi
    1795:	add    rdx,0x2
    1799:	seto   al
    179c:	test   al,al
    179e:	jne    17ac <botlish_fn_13+0x2c1>
    17a4:	mov    rax,rbx
    17a7:	jmp    17cc <botlish_fn_13+0x2e1>
    17ac:	mov    edx,0x3
    17b1:	mov    rsi,QWORD PTR [rsp+0x90]
    17b9:	mov    rdi,QWORD PTR [rsp+0x88]
    17c1:	call   17c6 <botlish_fn_13+0x2db>
			17c2: R_X86_64_PLT32	rt_int_add-0x4
    17c6:	mov    rdx,rax
    17c9:	mov    rax,rbx
    17cc:	mov    rbx,QWORD PTR [rsp+0xa0]
    17d4:	mov    r12,QWORD PTR [rsp+0xa8]
    17dc:	mov    r13,QWORD PTR [rsp+0xb0]
    17e4:	mov    r14,QWORD PTR [rsp+0xb8]
    17ec:	mov    r15,QWORD PTR [rsp+0xc0]
    17f4:	add    rsp,0xd0
    17fb:	mov    rsp,rbp
    17fe:	pop    rbp
    17ff:	ret
    1800:	mov    QWORD PTR [rsp+0x18],0x5
    1809:	mov    rsi,QWORD PTR [rsp+0x90]
    1811:	test   rsi,0x1
    1818:	je     184a <botlish_fn_13+0x35f>
    181e:	mov    rsi,QWORD PTR [rsp+0x90]
    1826:	mov    rdi,rsi
    1829:	add    rdi,0x4
    182d:	seto   r9b
    1831:	test   r9b,r9b
    1834:	jne    184a <botlish_fn_13+0x35f>
    183a:	mov    rsi,rdi
    183d:	mov    QWORD PTR [rsp+0x90],rdi
    1845:	jmp    186f <botlish_fn_13+0x384>
    184a:	mov    edx,0x5
    184f:	mov    rsi,QWORD PTR [rsp+0x90]
    1857:	mov    rdi,QWORD PTR [rsp+0x88]
    185f:	call   1864 <botlish_fn_13+0x379>
			1860: R_X86_64_PLT32	rt_int_add-0x4
    1864:	mov    rsi,rax
    1867:	mov    QWORD PTR [rsp+0x90],rax
    186f:	mov    QWORD PTR [rsp+0x8],rsi
    1874:	mov    rdi,QWORD PTR [rsp+0x88]
    187c:	mov    rax,QWORD PTR [rdi+0x10]
    1880:	mov    rax,QWORD PTR [rax+0x30]
    1884:	mov    QWORD PTR [rsp+0x18],rax
    1889:	lea    rcx,[rsp+0x38]
    188e:	mov    QWORD PTR [rsp+0x38],0x0
    1897:	mov    QWORD PTR [rsp+0x40],r13
    189c:	mov    QWORD PTR [rsp+0x48],0x0
    18a5:	mov    QWORD PTR [rsp+0x50],rax
    18aa:	mov    esi,0x2
    18af:	mov    edx,0x4
    18b4:	call   18b9 <botlish_fn_13+0x3ce>
			18b5: R_X86_64_PLT32	rt_construct-0x4
    18b9:	test   rax,rax
    18bc:	jne    18fc <botlish_fn_13+0x411>
    18c2:	xor    rdx,rdx
    18c5:	mov    rax,rdx
    18c8:	mov    rbx,QWORD PTR [rsp+0xa0]
    18d0:	mov    r12,QWORD PTR [rsp+0xa8]
    18d8:	mov    r13,QWORD PTR [rsp+0xb0]
    18e0:	mov    r14,QWORD PTR [rsp+0xb8]
    18e8:	mov    r15,QWORD PTR [rsp+0xc0]
    18f0:	add    rsp,0xd0
    18f7:	mov    rsp,rbp
    18fa:	pop    rbp
    18fb:	ret
    18fc:	mov    QWORD PTR [rsp],r12
    1900:	mov    rsi,QWORD PTR [rsp+0x90]
    1908:	mov    QWORD PTR [rsp+0x8],rsi
    190d:	mov    QWORD PTR [rsp+0x10],rax
    1912:	mov    r13,rax
    1915:	jmp    155e <botlish_fn_13+0x73>

000000000000191a <botlish_entry_13: scan_quoted<str, int, str>>:
    191a:	push   rbp
    191b:	mov    rbp,rsp
    191e:	ud2

0000000000001920 <botlish_fn_14: scan_field<str, int>>:
    1920:	push   rbp
    1921:	mov    rbp,rsp
    1924:	sub    rsp,0x50
    1928:	mov    QWORD PTR [rsp+0x30],rbx
    192d:	mov    QWORD PTR [rsp+0x38],r12
    1932:	mov    QWORD PTR [rsp+0x40],r13
    1937:	mov    r12,rdi
    193a:	mov    r13,rdx
    193d:	mov    QWORD PTR [rsp+0x10],0x0
    1946:	mov    QWORD PTR [rsp],rsi
    194a:	mov    rbx,rsi
    194d:	mov    QWORD PTR [rsp+0x8],rdx
    1952:	lea    rcx,[rsp+0x18]
    1957:	mov    rdx,r13
    195a:	mov    rsi,rbx
    195d:	mov    rdi,r12
    1960:	call   1965 <botlish_fn_14+0x45>
			1961: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1965:	test   rax,rax
    1968:	mov    rsi,rax
    196b:	je     1a36 <botlish_fn_14+0x116>
    1971:	mov    rdx,QWORD PTR [rsp+0x18]
    1976:	mov    rcx,QWORD PTR [rsp+0x20]
    197b:	mov    rdi,r12
    197e:	mov    rax,QWORD PTR [rdi+0x10]
    1982:	mov    r8,QWORD PTR [rax+0x30]
    1986:	call   198b <botlish_fn_14+0x6b>
			1987: R_X86_64_PLT32	rt_str_region_eq-0x4
    198b:	cmp    rax,0x6
    198f:	je     19c7 <botlish_fn_14+0xa7>
    1995:	mov    rcx,r13
    1998:	mov    rsi,rbx
    199b:	mov    rdi,r12
    199e:	mov    rdx,rcx
    19a1:	call   19a6 <botlish_fn_14+0x86>
			19a2: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_unquoted<str, int, int>
    19a6:	test   rax,rax
    19a9:	je     1a36 <botlish_fn_14+0x116>
    19af:	mov    rbx,QWORD PTR [rsp+0x30]
    19b4:	mov    r12,QWORD PTR [rsp+0x38]
    19b9:	mov    r13,QWORD PTR [rsp+0x40]
    19be:	add    rsp,0x50
    19c2:	mov    rsp,rbp
    19c5:	pop    rbp
    19c6:	ret
    19c7:	mov    rcx,r13
    19ca:	mov    QWORD PTR [rsp+0x10],0x3
    19d3:	test   rcx,0x1
    19da:	jne    19e8 <botlish_fn_14+0xc8>
    19e0:	mov    r13,rcx
    19e3:	jmp    19fd <botlish_fn_14+0xdd>
    19e8:	mov    rdx,rcx
    19eb:	add    rdx,0x2
    19ef:	mov    r13,rcx
    19f2:	seto   al
    19f5:	test   al,al
    19f7:	je     1a10 <botlish_fn_14+0xf0>
    19fd:	mov    edx,0x3
    1a02:	mov    rsi,r13
    1a05:	mov    rdi,r12
    1a08:	call   1a0d <botlish_fn_14+0xed>
			1a09: R_X86_64_PLT32	rt_int_add-0x4
    1a0d:	mov    rdx,rax
    1a10:	mov    QWORD PTR [rsp+0x8],rdx
    1a15:	mov    rdi,r12
    1a18:	mov    rax,QWORD PTR [rdi+0x10]
    1a1c:	mov    rcx,QWORD PTR [rax+0x18]
    1a20:	mov    QWORD PTR [rsp+0x10],rcx
    1a25:	mov    rsi,rbx
    1a28:	call   1a2d <botlish_fn_14+0x10d>
			1a29: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_quoted<str, int, str>
    1a2d:	test   rax,rax
    1a30:	jne    1a54 <botlish_fn_14+0x134>
    1a36:	xor    rdx,rdx
    1a39:	mov    rax,rdx
    1a3c:	mov    rbx,QWORD PTR [rsp+0x30]
    1a41:	mov    r12,QWORD PTR [rsp+0x38]
    1a46:	mov    r13,QWORD PTR [rsp+0x40]
    1a4b:	add    rsp,0x50
    1a4f:	mov    rsp,rbp
    1a52:	pop    rbp
    1a53:	ret
    1a54:	mov    rbx,QWORD PTR [rsp+0x30]
    1a59:	mov    r12,QWORD PTR [rsp+0x38]
    1a5e:	mov    r13,QWORD PTR [rsp+0x40]
    1a63:	add    rsp,0x50
    1a67:	mov    rsp,rbp
    1a6a:	pop    rbp
    1a6b:	ret

0000000000001a6c <botlish_entry_14: scan_field<str, int>>:
    1a6c:	push   rbp
    1a6d:	mov    rbp,rsp
    1a70:	ud2

0000000000001a72 <botlish_fn_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1a72:	push   rbp
    1a73:	mov    rbp,rsp
    1a76:	sub    rsp,0xa0
    1a7d:	mov    QWORD PTR [rsp+0x70],rbx
    1a82:	mov    QWORD PTR [rsp+0x78],r12
    1a87:	mov    QWORD PTR [rsp+0x80],r13
    1a8f:	mov    QWORD PTR [rsp+0x88],r14
    1a97:	mov    QWORD PTR [rsp+0x90],r15
    1a9f:	mov    r13,rdi
    1aa2:	mov    QWORD PTR [rsp+0x28],0x0
    1aab:	mov    QWORD PTR [rsp],rsi
    1aaf:	mov    r15,rsi
    1ab2:	mov    QWORD PTR [rsp+0x8],rdx
    1ab7:	mov    QWORD PTR [rsp+0x10],rcx
    1abc:	mov    QWORD PTR [rsp+0x50],rcx
    1ac1:	mov    QWORD PTR [rsp+0x18],r8
    1ac6:	mov    r12,r8
    1ac9:	mov    QWORD PTR [rsp+0x20],r9
    1ace:	mov    rbx,r9
    1ad1:	mov    rsi,r15
    1ad4:	mov    rdi,r13
    1ad7:	call   1adc <botlish_fn_15+0x6a>
			1ad8: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1adc:	test   rax,rax
    1adf:	je     1d13 <botlish_fn_15+0x2a1>
    1ae5:	mov    QWORD PTR [rsp+0x8],rax
    1aea:	mov    r8,rax
    1aed:	mov    QWORD PTR [rsp+0x28],rdx
    1af2:	mov    r14,rdx
    1af5:	lea    r9,[rsp+0x30]
    1afa:	mov    rcx,rbx
    1afd:	mov    rdx,r12
    1b00:	mov    rsi,QWORD PTR [rsp+0x50]
    1b05:	mov    rdi,r13
    1b08:	call   1b0d <botlish_fn_15+0x9b>
			1b09: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<list[List[never], mutarray, int], str>
    1b0d:	test   rax,rax
    1b10:	je     1d13 <botlish_fn_15+0x2a1>
    1b16:	mov    QWORD PTR [rsp+0x8],rax
    1b1b:	mov    QWORD PTR [rsp+0x68],rax
    1b20:	mov    rdx,QWORD PTR [rsp+0x30]
    1b25:	mov    QWORD PTR [rsp+0x10],rdx
    1b2a:	mov    QWORD PTR [rsp+0x60],rdx
    1b2f:	mov    rcx,QWORD PTR [rsp+0x38]
    1b34:	mov    QWORD PTR [rsp+0x18],rcx
    1b39:	mov    QWORD PTR [rsp+0x58],rcx
    1b3e:	lea    rcx,[rsp+0x40]
    1b43:	mov    rdx,r14
    1b46:	mov    rsi,r15
    1b49:	mov    rdi,r13
    1b4c:	call   1b51 <botlish_fn_15+0xdf>
			1b4d: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1b51:	test   rax,rax
    1b54:	mov    QWORD PTR [rsp+0x50],rax
    1b59:	je     1d13 <botlish_fn_15+0x2a1>
    1b5f:	mov    r12,QWORD PTR [rsp+0x40]
    1b64:	mov    rbx,QWORD PTR [rsp+0x48]
    1b69:	mov    rdi,r13
    1b6c:	mov    rcx,QWORD PTR [rdi+0x10]
    1b70:	mov    r8,QWORD PTR [rcx+0x20]
    1b74:	mov    rcx,rbx
    1b77:	mov    rdx,r12
    1b7a:	mov    rsi,QWORD PTR [rsp+0x50]
    1b7f:	call   1b84 <botlish_fn_15+0x112>
			1b80: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b84:	cmp    rax,0x6
    1b88:	je     1ca2 <botlish_fn_15+0x230>
    1b8e:	mov    rdi,r13
    1b91:	mov    rax,QWORD PTR [rdi+0x10]
    1b95:	mov    r8,QWORD PTR [rax+0x28]
    1b99:	mov    rcx,rbx
    1b9c:	mov    rdx,r12
    1b9f:	mov    rsi,QWORD PTR [rsp+0x50]
    1ba4:	call   1ba9 <botlish_fn_15+0x137>
			1ba5: R_X86_64_PLT32	rt_str_region_eq-0x4
    1ba9:	cmp    rax,0x6
    1bad:	je     1c04 <botlish_fn_15+0x192>
    1bb3:	mov    rcx,QWORD PTR [rsp+0x58]
    1bb8:	mov    rdx,QWORD PTR [rsp+0x60]
    1bbd:	mov    rsi,QWORD PTR [rsp+0x68]
    1bc2:	mov    rdi,r13
    1bc5:	call   1bca <botlish_fn_15+0x158>
			1bc6: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1bca:	test   rax,rax
    1bcd:	je     1d13 <botlish_fn_15+0x2a1>
    1bd3:	mov    rdx,r14
    1bd6:	mov    rbx,QWORD PTR [rsp+0x70]
    1bdb:	mov    r12,QWORD PTR [rsp+0x78]
    1be0:	mov    r13,QWORD PTR [rsp+0x80]
    1be8:	mov    r14,QWORD PTR [rsp+0x88]
    1bf0:	mov    r15,QWORD PTR [rsp+0x90]
    1bf8:	add    rsp,0xa0
    1bff:	mov    rsp,rbp
    1c02:	pop    rbp
    1c03:	ret
    1c04:	mov    rcx,QWORD PTR [rsp+0x58]
    1c09:	mov    rdx,QWORD PTR [rsp+0x60]
    1c0e:	mov    rsi,QWORD PTR [rsp+0x68]
    1c13:	mov    rdi,r13
    1c16:	call   1c1b <botlish_fn_15+0x1a9>
			1c17: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1c1b:	test   rax,rax
    1c1e:	je     1d13 <botlish_fn_15+0x2a1>
    1c24:	mov    QWORD PTR [rsp],rax
    1c28:	mov    rbx,rax
    1c2b:	mov    QWORD PTR [rsp+0x8],0x3
    1c34:	mov    rdx,r14
    1c37:	test   rdx,0x1
    1c3e:	je     1c5e <botlish_fn_15+0x1ec>
    1c44:	mov    rdx,r14
    1c47:	add    rdx,0x2
    1c4b:	seto   al
    1c4e:	test   al,al
    1c50:	jne    1c5e <botlish_fn_15+0x1ec>
    1c56:	mov    rax,rbx
    1c59:	jmp    1c74 <botlish_fn_15+0x202>
    1c5e:	mov    edx,0x3
    1c63:	mov    rsi,r14
    1c66:	mov    rdi,r13
    1c69:	call   1c6e <botlish_fn_15+0x1fc>
			1c6a: R_X86_64_PLT32	rt_int_add-0x4
    1c6e:	mov    rdx,rax
    1c71:	mov    rax,rbx
    1c74:	mov    rbx,QWORD PTR [rsp+0x70]
    1c79:	mov    r12,QWORD PTR [rsp+0x78]
    1c7e:	mov    r13,QWORD PTR [rsp+0x80]
    1c86:	mov    r14,QWORD PTR [rsp+0x88]
    1c8e:	mov    r15,QWORD PTR [rsp+0x90]
    1c96:	add    rsp,0xa0
    1c9d:	mov    rsp,rbp
    1ca0:	pop    rbp
    1ca1:	ret
    1ca2:	mov    rsi,r14
    1ca5:	mov    edx,0x3
    1caa:	mov    rcx,rdx
    1cad:	mov    QWORD PTR [rsp+0x20],0x3
    1cb6:	test   rsi,0x1
    1cbd:	jne    1ccb <botlish_fn_15+0x259>
    1cc3:	mov    rdx,rcx
    1cc6:	jmp    1ce0 <botlish_fn_15+0x26e>
    1ccb:	mov    rdx,rsi
    1cce:	add    rdx,0x2
    1cd2:	seto   al
    1cd5:	test   al,al
    1cd7:	je     1ceb <botlish_fn_15+0x279>
    1cdd:	mov    rdx,rcx
    1ce0:	mov    rdi,r13
    1ce3:	call   1ce8 <botlish_fn_15+0x276>
			1ce4: R_X86_64_PLT32	rt_int_add-0x4
    1ce8:	mov    rdx,rax
    1ceb:	mov    QWORD PTR [rsp+0x20],rdx
    1cf0:	mov    rcx,QWORD PTR [rsp+0x68]
    1cf5:	mov    rsi,r15
    1cf8:	mov    rdi,r13
    1cfb:	mov    r8,QWORD PTR [rsp+0x60]
    1d00:	mov    r9,QWORD PTR [rsp+0x58]
    1d05:	call   1d0a <botlish_fn_15+0x298>
			1d06: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[List[mutarray], mutarray, int]>
    1d0a:	test   rax,rax
    1d0d:	jne    1d47 <botlish_fn_15+0x2d5>
    1d13:	xor    rdx,rdx
    1d16:	mov    rax,rdx
    1d19:	mov    rbx,QWORD PTR [rsp+0x70]
    1d1e:	mov    r12,QWORD PTR [rsp+0x78]
    1d23:	mov    r13,QWORD PTR [rsp+0x80]
    1d2b:	mov    r14,QWORD PTR [rsp+0x88]
    1d33:	mov    r15,QWORD PTR [rsp+0x90]
    1d3b:	add    rsp,0xa0
    1d42:	mov    rsp,rbp
    1d45:	pop    rbp
    1d46:	ret
    1d47:	mov    rbx,QWORD PTR [rsp+0x70]
    1d4c:	mov    r12,QWORD PTR [rsp+0x78]
    1d51:	mov    r13,QWORD PTR [rsp+0x80]
    1d59:	mov    r14,QWORD PTR [rsp+0x88]
    1d61:	mov    r15,QWORD PTR [rsp+0x90]
    1d69:	add    rsp,0xa0
    1d70:	mov    rsp,rbp
    1d73:	pop    rbp
    1d74:	ret

0000000000001d75 <botlish_entry_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1d75:	push   rbp
    1d76:	mov    rbp,rsp
    1d79:	ud2

0000000000001d7b <botlish_fn_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    1d7b:	push   rbp
    1d7c:	mov    rbp,rsp
    1d7f:	sub    rsp,0xb0
    1d86:	mov    QWORD PTR [rsp+0x80],rbx
    1d8e:	mov    QWORD PTR [rsp+0x88],r12
    1d96:	mov    QWORD PTR [rsp+0x90],r13
    1d9e:	mov    QWORD PTR [rsp+0x98],r14
    1da6:	mov    QWORD PTR [rsp+0xa0],r15
    1dae:	mov    QWORD PTR [rsp+0x50],rdi
    1db3:	mov    QWORD PTR [rsp+0x28],0x0
    1dbc:	mov    QWORD PTR [rsp],rsi
    1dc0:	mov    QWORD PTR [rsp+0x8],rdx
    1dc5:	mov    QWORD PTR [rsp+0x10],rcx
    1dca:	mov    QWORD PTR [rsp+0x18],r8
    1dcf:	mov    QWORD PTR [rsp+0x20],r9
    1dd4:	lea    r15,[rsp+0x30]
    1dd9:	lea    rbx,[rsp+0x40]
    1dde:	mov    r12,rsi
    1de1:	mov    r13,rcx
    1de4:	mov    QWORD PTR [rsp+0x58],r8
    1de9:	mov    QWORD PTR [rsp+0x60],r9
    1dee:	mov    rsi,r12
    1df1:	mov    rdi,QWORD PTR [rsp+0x50]
    1df6:	call   1dfb <botlish_fn_16+0x80>
			1df7: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1dfb:	mov    QWORD PTR [rsp+0x78],rdx
    1e00:	test   rax,rax
    1e03:	je     1f5e <botlish_fn_16+0x1e3>
    1e09:	mov    QWORD PTR [rsp+0x8],rax
    1e0e:	mov    rdx,QWORD PTR [rsp+0x78]
    1e13:	mov    r8,rax
    1e16:	mov    QWORD PTR [rsp+0x28],rdx
    1e1b:	mov    rcx,QWORD PTR [rsp+0x60]
    1e20:	mov    rdx,QWORD PTR [rsp+0x58]
    1e25:	mov    rsi,r13
    1e28:	mov    rdi,QWORD PTR [rsp+0x50]
    1e2d:	mov    r9,r15
    1e30:	call   1e35 <botlish_fn_16+0xba>
			1e31: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[List[mutarray], mutarray, int], str>
    1e35:	test   rax,rax
    1e38:	je     1f5e <botlish_fn_16+0x1e3>
    1e3e:	mov    QWORD PTR [rsp+0x8],rax
    1e43:	mov    QWORD PTR [rsp+0x70],rax
    1e48:	mov    rdx,QWORD PTR [rsp+0x30]
    1e4d:	mov    QWORD PTR [rsp+0x58],rdx
    1e52:	mov    QWORD PTR [rsp+0x10],rdx
    1e57:	mov    rcx,QWORD PTR [rsp+0x38]
    1e5c:	mov    QWORD PTR [rsp+0x18],rcx
    1e61:	mov    QWORD PTR [rsp+0x60],rcx
    1e66:	mov    rcx,rbx
    1e69:	mov    rdx,QWORD PTR [rsp+0x78]
    1e6e:	mov    rsi,r12
    1e71:	mov    rdi,QWORD PTR [rsp+0x50]
    1e76:	call   1e7b <botlish_fn_16+0x100>
			1e77: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1e7b:	test   rax,rax
    1e7e:	mov    QWORD PTR [rsp+0x68],rax
    1e83:	je     1f5e <botlish_fn_16+0x1e3>
    1e89:	mov    r13,QWORD PTR [rsp+0x40]
    1e8e:	mov    r14,QWORD PTR [rsp+0x48]
    1e93:	mov    rdi,QWORD PTR [rsp+0x50]
    1e98:	mov    rcx,QWORD PTR [rdi+0x10]
    1e9c:	mov    r8,QWORD PTR [rcx+0x20]
    1ea0:	mov    rcx,r14
    1ea3:	mov    rdx,r13
    1ea6:	mov    rsi,QWORD PTR [rsp+0x68]
    1eab:	call   1eb0 <botlish_fn_16+0x135>
			1eac: R_X86_64_PLT32	rt_str_region_eq-0x4
    1eb0:	cmp    rax,0x6
    1eb4:	je     2024 <botlish_fn_16+0x2a9>
    1eba:	mov    rdi,QWORD PTR [rsp+0x50]
    1ebf:	mov    rax,QWORD PTR [rdi+0x10]
    1ec3:	mov    r8,QWORD PTR [rax+0x28]
    1ec7:	mov    rcx,r14
    1eca:	mov    rdx,r13
    1ecd:	mov    rsi,QWORD PTR [rsp+0x68]
    1ed2:	call   1ed7 <botlish_fn_16+0x15c>
			1ed3: R_X86_64_PLT32	rt_str_region_eq-0x4
    1ed7:	cmp    rax,0x6
    1edb:	je     1f3c <botlish_fn_16+0x1c1>
    1ee1:	mov    rcx,QWORD PTR [rsp+0x60]
    1ee6:	mov    rdx,QWORD PTR [rsp+0x58]
    1eeb:	mov    rsi,QWORD PTR [rsp+0x70]
    1ef0:	mov    rdi,QWORD PTR [rsp+0x50]
    1ef5:	call   1efa <botlish_fn_16+0x17f>
			1ef6: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1efa:	test   rax,rax
    1efd:	je     1f5e <botlish_fn_16+0x1e3>
    1f03:	mov    rdx,QWORD PTR [rsp+0x78]
    1f08:	mov    rbx,QWORD PTR [rsp+0x80]
    1f10:	mov    r12,QWORD PTR [rsp+0x88]
    1f18:	mov    r13,QWORD PTR [rsp+0x90]
    1f20:	mov    r14,QWORD PTR [rsp+0x98]
    1f28:	mov    r15,QWORD PTR [rsp+0xa0]
    1f30:	add    rsp,0xb0
    1f37:	mov    rsp,rbp
    1f3a:	pop    rbp
    1f3b:	ret
    1f3c:	mov    rcx,QWORD PTR [rsp+0x60]
    1f41:	mov    rdx,QWORD PTR [rsp+0x58]
    1f46:	mov    rsi,QWORD PTR [rsp+0x70]
    1f4b:	mov    rdi,QWORD PTR [rsp+0x50]
    1f50:	call   1f55 <botlish_fn_16+0x1da>
			1f51: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1f55:	test   rax,rax
    1f58:	jne    1f98 <botlish_fn_16+0x21d>
    1f5e:	xor    rdx,rdx
    1f61:	mov    rax,rdx
    1f64:	mov    rbx,QWORD PTR [rsp+0x80]
    1f6c:	mov    r12,QWORD PTR [rsp+0x88]
    1f74:	mov    r13,QWORD PTR [rsp+0x90]
    1f7c:	mov    r14,QWORD PTR [rsp+0x98]
    1f84:	mov    r15,QWORD PTR [rsp+0xa0]
    1f8c:	add    rsp,0xb0
    1f93:	mov    rsp,rbp
    1f96:	pop    rbp
    1f97:	ret
    1f98:	mov    QWORD PTR [rsp],rax
    1f9c:	mov    rbx,rax
    1f9f:	mov    QWORD PTR [rsp+0x8],0x3
    1fa8:	mov    rdx,QWORD PTR [rsp+0x78]
    1fad:	test   rdx,0x1
    1fb4:	je     1fd6 <botlish_fn_16+0x25b>
    1fba:	mov    rdx,QWORD PTR [rsp+0x78]
    1fbf:	add    rdx,0x2
    1fc3:	seto   al
    1fc6:	test   al,al
    1fc8:	jne    1fd6 <botlish_fn_16+0x25b>
    1fce:	mov    rax,rbx
    1fd1:	jmp    1ff0 <botlish_fn_16+0x275>
    1fd6:	mov    edx,0x3
    1fdb:	mov    rsi,QWORD PTR [rsp+0x78]
    1fe0:	mov    rdi,QWORD PTR [rsp+0x50]
    1fe5:	call   1fea <botlish_fn_16+0x26f>
			1fe6: R_X86_64_PLT32	rt_int_add-0x4
    1fea:	mov    rdx,rax
    1fed:	mov    rax,rbx
    1ff0:	mov    rbx,QWORD PTR [rsp+0x80]
    1ff8:	mov    r12,QWORD PTR [rsp+0x88]
    2000:	mov    r13,QWORD PTR [rsp+0x90]
    2008:	mov    r14,QWORD PTR [rsp+0x98]
    2010:	mov    r15,QWORD PTR [rsp+0xa0]
    2018:	add    rsp,0xb0
    201f:	mov    rsp,rbp
    2022:	pop    rbp
    2023:	ret
    2024:	mov    rsi,QWORD PTR [rsp+0x78]
    2029:	mov    edx,0x3
    202e:	mov    r10,rdx
    2031:	mov    QWORD PTR [rsp+0x20],0x3
    203a:	test   rsi,0x1
    2041:	jne    204f <botlish_fn_16+0x2d4>
    2047:	mov    rdx,r10
    204a:	jmp    2064 <botlish_fn_16+0x2e9>
    204f:	mov    rdx,rsi
    2052:	add    rdx,0x2
    2056:	seto   al
    2059:	test   al,al
    205b:	je     2071 <botlish_fn_16+0x2f6>
    2061:	mov    rdx,r10
    2064:	mov    rdi,QWORD PTR [rsp+0x50]
    2069:	call   206e <botlish_fn_16+0x2f3>
			206a: R_X86_64_PLT32	rt_int_add-0x4
    206e:	mov    rdx,rax
    2071:	mov    QWORD PTR [rsp],r12
    2075:	mov    QWORD PTR [rsp+0x8],rdx
    207a:	mov    rsi,QWORD PTR [rsp+0x70]
    207f:	mov    QWORD PTR [rsp+0x10],rsi
    2084:	mov    rax,QWORD PTR [rsp+0x58]
    2089:	mov    QWORD PTR [rsp+0x18],rax
    208e:	mov    rcx,QWORD PTR [rsp+0x60]
    2093:	mov    QWORD PTR [rsp+0x20],rcx
    2098:	mov    r13,rsi
    209b:	jmp    1dee <botlish_fn_16+0x73>

00000000000020a0 <botlish_entry_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    20a0:	push   rbp
    20a1:	mov    rbp,rsp
    20a4:	ud2

00000000000020a6 <botlish_fn_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    20a6:	push   rbp
    20a7:	mov    rbp,rsp
    20aa:	sub    rsp,0xa0
    20b1:	mov    QWORD PTR [rsp+0x70],rbx
    20b6:	mov    QWORD PTR [rsp+0x78],r12
    20bb:	mov    QWORD PTR [rsp+0x80],r13
    20c3:	mov    QWORD PTR [rsp+0x88],r14
    20cb:	mov    QWORD PTR [rsp+0x90],r15
    20d3:	mov    r12,rdi
    20d6:	mov    QWORD PTR [rsp+0x28],0x0
    20df:	mov    QWORD PTR [rsp+0x30],0x0
    20e8:	mov    QWORD PTR [rsp+0x38],0x0
    20f1:	mov    QWORD PTR [rsp],rsi
    20f5:	mov    QWORD PTR [rsp+0x8],rdx
    20fa:	mov    QWORD PTR [rsp+0x10],rcx
    20ff:	mov    r15,rcx
    2102:	mov    QWORD PTR [rsp+0x18],r8
    2107:	mov    r14,r8
    210a:	mov    QWORD PTR [rsp+0x20],r9
    210f:	mov    r13,r9
    2112:	mov    rax,QWORD PTR [rsi+0x8]
    2116:	mov    rbx,rsi
    2119:	mov    rcx,rdx
    211c:	sar    rcx,1
    211f:	mov    QWORD PTR [rsp+0x60],rdx
    2124:	shl    rax,1
    2127:	or     rax,0x1
    212b:	sar    rax,1
    212e:	cmp    rcx,rax
    2131:	jge    2216 <botlish_fn_17+0x170>
    2137:	lea    rsi,[rsp+0x40]
    213c:	mov    rdi,r12
    213f:	call   2144 <botlish_fn_17+0x9e>
			2140: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2144:	test   rax,rax
    2147:	je     2230 <botlish_fn_17+0x18a>
    214d:	mov    QWORD PTR [rsp+0x28],rax
    2152:	mov    rcx,rax
    2155:	mov    r8,QWORD PTR [rsp+0x40]
    215a:	mov    QWORD PTR [rsp+0x30],r8
    215f:	mov    r9,QWORD PTR [rsp+0x48]
    2164:	mov    QWORD PTR [rsp+0x38],r9
    2169:	mov    rdx,QWORD PTR [rsp+0x60]
    216e:	mov    rsi,rbx
    2171:	mov    rdi,r12
    2174:	call   2179 <botlish_fn_17+0xd3>
			2175: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    2179:	test   rax,rax
    217c:	je     2230 <botlish_fn_17+0x18a>
    2182:	mov    QWORD PTR [rsp+0x8],rax
    2187:	mov    r8,rax
    218a:	mov    QWORD PTR [rsp+0x28],rdx
    218f:	mov    QWORD PTR [rsp+0x60],rdx
    2194:	lea    r9,[rsp+0x50]
    2199:	mov    rcx,r13
    219c:	mov    rdx,r14
    219f:	mov    rsi,r15
    21a2:	mov    rdi,r12
    21a5:	call   21aa <botlish_fn_17+0x104>
			21a6: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[List[never], mutarray, int], list>
    21aa:	test   rax,rax
    21ad:	je     2230 <botlish_fn_17+0x18a>
    21b3:	mov    QWORD PTR [rsp+0x8],rax
    21b8:	mov    rcx,rax
    21bb:	mov    r8,QWORD PTR [rsp+0x50]
    21c0:	mov    QWORD PTR [rsp+0x10],r8
    21c5:	mov    r9,QWORD PTR [rsp+0x58]
    21ca:	mov    QWORD PTR [rsp+0x18],r9
    21cf:	mov    rdx,QWORD PTR [rsp+0x60]
    21d4:	mov    rsi,rbx
    21d7:	mov    rdi,r12
    21da:	call   21df <botlish_fn_17+0x139>
			21db: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    21df:	test   rax,rax
    21e2:	je     2230 <botlish_fn_17+0x18a>
    21e8:	mov    rbx,QWORD PTR [rsp+0x70]
    21ed:	mov    r12,QWORD PTR [rsp+0x78]
    21f2:	mov    r13,QWORD PTR [rsp+0x80]
    21fa:	mov    r14,QWORD PTR [rsp+0x88]
    2202:	mov    r15,QWORD PTR [rsp+0x90]
    220a:	add    rsp,0xa0
    2211:	mov    rsp,rbp
    2214:	pop    rbp
    2215:	ret
    2216:	mov    rcx,r13
    2219:	mov    rdx,r14
    221c:	mov    rsi,r15
    221f:	mov    rdi,r12
    2222:	call   2227 <botlish_fn_17+0x181>
			2223: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[List[never], mutarray, int]>
    2227:	test   rax,rax
    222a:	jne    2261 <botlish_fn_17+0x1bb>
    2230:	xor    rax,rax
    2233:	mov    rbx,QWORD PTR [rsp+0x70]
    2238:	mov    r12,QWORD PTR [rsp+0x78]
    223d:	mov    r13,QWORD PTR [rsp+0x80]
    2245:	mov    r14,QWORD PTR [rsp+0x88]
    224d:	mov    r15,QWORD PTR [rsp+0x90]
    2255:	add    rsp,0xa0
    225c:	mov    rsp,rbp
    225f:	pop    rbp
    2260:	ret
    2261:	mov    rbx,QWORD PTR [rsp+0x70]
    2266:	mov    r12,QWORD PTR [rsp+0x78]
    226b:	mov    r13,QWORD PTR [rsp+0x80]
    2273:	mov    r14,QWORD PTR [rsp+0x88]
    227b:	mov    r15,QWORD PTR [rsp+0x90]
    2283:	add    rsp,0xa0
    228a:	mov    rsp,rbp
    228d:	pop    rbp
    228e:	ret

000000000000228f <botlish_entry_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    228f:	push   rbp
    2290:	mov    rbp,rsp
    2293:	mov    rsi,QWORD PTR [rdx]
    2296:	mov    r10,QWORD PTR [rdx+0x8]
    229a:	mov    rcx,QWORD PTR [rdx+0x10]
    229e:	mov    r8,QWORD PTR [rdx+0x18]
    22a2:	mov    r9,QWORD PTR [rdx+0x20]
    22a6:	mov    rdx,r10
    22a9:	call   22ae <botlish_entry_17+0x1f>
			22aa: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    22ae:	mov    rsp,rbp
    22b1:	pop    rbp
    22b2:	ret
    22b3:	add    BYTE PTR [rax],al
    22b5:	add    BYTE PTR [rax],al
	...

00000000000022b8 <botlish_fn_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    22b8:	push   rbp
    22b9:	mov    rbp,rsp
    22bc:	sub    rsp,0xb0
    22c3:	mov    QWORD PTR [rsp+0x80],rbx
    22cb:	mov    QWORD PTR [rsp+0x88],r12
    22d3:	mov    QWORD PTR [rsp+0x90],r13
    22db:	mov    QWORD PTR [rsp+0x98],r14
    22e3:	mov    QWORD PTR [rsp+0xa0],r15
    22eb:	mov    r15,rdi
    22ee:	mov    QWORD PTR [rsp+0x28],0x0
    22f7:	mov    QWORD PTR [rsp+0x30],0x0
    2300:	mov    QWORD PTR [rsp+0x38],0x0
    2309:	mov    QWORD PTR [rsp],rsi
    230d:	mov    QWORD PTR [rsp+0x8],rdx
    2312:	mov    r14,rdx
    2315:	mov    QWORD PTR [rsp+0x10],rcx
    231a:	mov    QWORD PTR [rsp+0x18],r8
    231f:	mov    QWORD PTR [rsp+0x20],r9
    2324:	lea    r13,[rsp+0x40]
    2329:	lea    rbx,[rsp+0x50]
    232e:	mov    r12,rsi
    2331:	mov    QWORD PTR [rsp+0x60],rcx
    2336:	mov    QWORD PTR [rsp+0x68],r8
    233b:	mov    QWORD PTR [rsp+0x70],r9
    2340:	mov    rdx,QWORD PTR [r12+0x8]
    2345:	shl    rdx,1
    2348:	or     rdx,0x1
    234c:	mov    rax,r14
    234f:	and    rax,rdx
    2352:	test   rax,0x1
    2358:	jne    237e <botlish_fn_18+0xc6>
    235e:	mov    rsi,r14
    2361:	mov    rdi,r15
    2364:	call   2369 <botlish_fn_18+0xb1>
			2365: R_X86_64_PLT32	rt_int_cmp-0x4
    2369:	mov    ecx,0x2
    236e:	test   rax,rax
    2371:	cmovge rcx,QWORD PTR [rip+0x167]        # 24e0 <botlish_fn_18+0x228>
    2379:	jmp    2391 <botlish_fn_18+0xd9>
    237e:	mov    ecx,0x2
    2383:	mov    r11,r14
    2386:	cmp    r11,rdx
    2389:	cmovge rcx,QWORD PTR [rip+0x14f]        # 24e0 <botlish_fn_18+0x228>
    2391:	cmp    rcx,0x6
    2395:	je     244e <botlish_fn_18+0x196>
    239b:	mov    rsi,r13
    239e:	mov    rdi,r15
    23a1:	call   23a6 <botlish_fn_18+0xee>
			23a2: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    23a6:	test   rax,rax
    23a9:	je     246e <botlish_fn_18+0x1b6>
    23af:	mov    QWORD PTR [rsp+0x28],rax
    23b4:	mov    rcx,rax
    23b7:	mov    r8,QWORD PTR [rsp+0x40]
    23bc:	mov    QWORD PTR [rsp+0x30],r8
    23c1:	mov    r9,QWORD PTR [rsp+0x48]
    23c6:	mov    QWORD PTR [rsp+0x38],r9
    23cb:	mov    rdx,r14
    23ce:	mov    rsi,r12
    23d1:	mov    rdi,r15
    23d4:	call   23d9 <botlish_fn_18+0x121>
			23d5: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    23d9:	test   rax,rax
    23dc:	je     246e <botlish_fn_18+0x1b6>
    23e2:	mov    QWORD PTR [rsp+0x8],rax
    23e7:	mov    r8,rax
    23ea:	mov    QWORD PTR [rsp+0x28],rdx
    23ef:	mov    r14,rdx
    23f2:	mov    rsi,QWORD PTR [rsp+0x60]
    23f7:	mov    rdx,QWORD PTR [rsp+0x68]
    23fc:	mov    rcx,QWORD PTR [rsp+0x70]
    2401:	mov    rdi,r15
    2404:	mov    r9,rbx
    2407:	call   240c <botlish_fn_18+0x154>
			2408: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[List[mutarray], mutarray, int], list>
    240c:	test   rax,rax
    240f:	je     246e <botlish_fn_18+0x1b6>
    2415:	mov    rdx,QWORD PTR [rsp+0x50]
    241a:	mov    rcx,QWORD PTR [rsp+0x58]
    241f:	mov    QWORD PTR [rsp],r12
    2423:	mov    rsi,r14
    2426:	mov    QWORD PTR [rsp+0x8],rsi
    242b:	mov    QWORD PTR [rsp+0x10],rax
    2430:	mov    QWORD PTR [rsp+0x18],rdx
    2435:	mov    QWORD PTR [rsp+0x20],rcx
    243a:	mov    QWORD PTR [rsp+0x60],rax
    243f:	mov    QWORD PTR [rsp+0x68],rdx
    2444:	mov    QWORD PTR [rsp+0x70],rcx
    2449:	jmp    2340 <botlish_fn_18+0x88>
    244e:	mov    rcx,QWORD PTR [rsp+0x70]
    2453:	mov    rdx,QWORD PTR [rsp+0x68]
    2458:	mov    rsi,QWORD PTR [rsp+0x60]
    245d:	mov    rdi,r15
    2460:	call   2465 <botlish_fn_18+0x1ad>
			2461: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    2465:	test   rax,rax
    2468:	jne    24a5 <botlish_fn_18+0x1ed>
    246e:	xor    rax,rax
    2471:	mov    rbx,QWORD PTR [rsp+0x80]
    2479:	mov    r12,QWORD PTR [rsp+0x88]
    2481:	mov    r13,QWORD PTR [rsp+0x90]
    2489:	mov    r14,QWORD PTR [rsp+0x98]
    2491:	mov    r15,QWORD PTR [rsp+0xa0]
    2499:	add    rsp,0xb0
    24a0:	mov    rsp,rbp
    24a3:	pop    rbp
    24a4:	ret
    24a5:	mov    rbx,QWORD PTR [rsp+0x80]
    24ad:	mov    r12,QWORD PTR [rsp+0x88]
    24b5:	mov    r13,QWORD PTR [rsp+0x90]
    24bd:	mov    r14,QWORD PTR [rsp+0x98]
    24c5:	mov    r15,QWORD PTR [rsp+0xa0]
    24cd:	add    rsp,0xb0
    24d4:	mov    rsp,rbp
    24d7:	pop    rbp
    24d8:	ret
    24d9:	add    BYTE PTR [rax],al
    24db:	add    BYTE PTR [rax],al
    24dd:	add    BYTE PTR [rax],al
    24df:	add    BYTE PTR [rsi],al
    24e1:	add    BYTE PTR [rax],al
    24e3:	add    BYTE PTR [rax],al
    24e5:	add    BYTE PTR [rax],al
	...

00000000000024e8 <botlish_entry_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    24e8:	push   rbp
    24e9:	mov    rbp,rsp
    24ec:	mov    rsi,QWORD PTR [rdx]
    24ef:	mov    r10,QWORD PTR [rdx+0x8]
    24f3:	mov    rcx,QWORD PTR [rdx+0x10]
    24f7:	mov    r8,QWORD PTR [rdx+0x18]
    24fb:	mov    r9,QWORD PTR [rdx+0x20]
    24ff:	mov    rdx,r10
    2502:	call   2507 <botlish_entry_18+0x1f>
			2503: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    2507:	mov    rsp,rbp
    250a:	pop    rbp
    250b:	ret

000000000000250c <botlish_fn_19: csv_parse<str>>:
    250c:	push   rbp
    250d:	mov    rbp,rsp
    2510:	sub    rsp,0x50
    2514:	mov    QWORD PTR [rsp+0x40],r12
    2519:	mov    QWORD PTR [rsp+0x48],r13
    251e:	mov    r13,rdi
    2521:	mov    QWORD PTR [rsp+0x10],0x0
    252a:	mov    QWORD PTR [rsp+0x18],0x0
    2533:	mov    QWORD PTR [rsp+0x20],0x0
    253c:	mov    QWORD PTR [rsp],rsi
    2540:	mov    r12,rsi
    2543:	mov    QWORD PTR [rsp+0x8],0x1
    254c:	lea    rsi,[rsp+0x28]
    2551:	mov    rdi,r13
    2554:	call   2559 <botlish_fn_19+0x4d>
			2555: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2559:	test   rax,rax
    255c:	je     2597 <botlish_fn_19+0x8b>
    2562:	mov    QWORD PTR [rsp+0x10],rax
    2567:	mov    rcx,rax
    256a:	mov    r8,QWORD PTR [rsp+0x28]
    256f:	mov    QWORD PTR [rsp+0x18],r8
    2574:	mov    r9,QWORD PTR [rsp+0x30]
    2579:	mov    QWORD PTR [rsp+0x20],r9
    257e:	mov    edx,0x1
    2583:	mov    rsi,r12
    2586:	mov    rdi,r13
    2589:	call   258e <botlish_fn_19+0x82>
			258a: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    258e:	test   rax,rax
    2591:	jne    25ad <botlish_fn_19+0xa1>
    2597:	xor    rax,rax
    259a:	mov    r12,QWORD PTR [rsp+0x40]
    259f:	mov    r13,QWORD PTR [rsp+0x48]
    25a4:	add    rsp,0x50
    25a8:	mov    rsp,rbp
    25ab:	pop    rbp
    25ac:	ret
    25ad:	mov    r12,QWORD PTR [rsp+0x40]
    25b2:	mov    r13,QWORD PTR [rsp+0x48]
    25b7:	add    rsp,0x50
    25bb:	mov    rsp,rbp
    25be:	pop    rbp
    25bf:	ret

00000000000025c0 <botlish_entry_19: csv_parse<str>>:
    25c0:	push   rbp
    25c1:	mov    rbp,rsp
    25c4:	mov    rsi,QWORD PTR [rdx]
    25c7:	call   25cc <botlish_entry_19+0xc>
			25c8: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    25cc:	mov    rsp,rbp
    25cf:	pop    rbp
    25d0:	ret

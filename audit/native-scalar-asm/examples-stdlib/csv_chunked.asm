; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10103  (per function: 68 195 542 542 542 542 592 520 540 540 365 430 585 770 352 799 833 537 612 197)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> chunked_new<generic>
;   botlish_fn_2 / botlish_entry_2 -> chunked_append<list[list<never>, mutarray, int], str>
;   botlish_fn_3 / botlish_entry_3 -> chunked_append<list[list<mutarray>, mutarray, int], str>
;   botlish_fn_4 / botlish_entry_4 -> chunked_append<list[list<never>, mutarray, int], list>
;   botlish_fn_5 / botlish_entry_5 -> chunked_append<list[list<mutarray>, mutarray, int], list>
;   botlish_fn_6 / botlish_entry_6 -> chunked_copy_chunks<list<never>, int, mutarray, int>
;   botlish_fn_7 / botlish_entry_7 -> chunked_copy_chunks<list<mutarray>, int, mutarray, int>
;   botlish_fn_8 / botlish_entry_8 -> chunked_finish<list[list<never>, mutarray, int]>
;   botlish_fn_9 / botlish_entry_9 -> chunked_finish<list[list<mutarray>, mutarray, int]>
;   botlish_fn_10 / botlish_entry_10 -> peek<str, int>
;   botlish_fn_11 / botlish_entry_11 -> peek<str, int>
;   botlish_fn_12 / botlish_entry_12 -> scan_unquoted<str, int, int>
;   botlish_fn_13 / botlish_entry_13 -> scan_quoted<str, int, str>
;   botlish_fn_14 / botlish_entry_14 -> scan_field<str, int>
;   botlish_fn_15 / botlish_entry_15 -> scan_record<str, int, list[list<never>, mutarray, int]>
;   botlish_fn_16 / botlish_entry_16 -> scan_record<str, int, list[list<mutarray>, mutarray, int]>
;   botlish_fn_17 / botlish_entry_17 -> scan_records<str, int, list[list<never>, mutarray, int]>
;   botlish_fn_18 / botlish_entry_18 -> scan_records<str, int, list[list<mutarray>, mutarray, int]>
;   botlish_fn_19 / botlish_entry_19 -> csv_parse<str>


csv_chunked.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x10
       8:	mov    r8,QWORD PTR [rdi+0x10]
       c:	mov    rsi,QWORD PTR [r8]
       f:	mov    QWORD PTR [rsp],rsi
      13:	call   18 <botlish_fn_0+0x18>
			14: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
      18:	test   rax,rax
      1b:	jne    2d <botlish_fn_0+0x2d>
      21:	xor    rax,rax
      24:	add    rsp,0x10
      28:	mov    rsp,rbp
      2b:	pop    rbp
      2c:	ret
      2d:	add    rsp,0x10
      31:	mov    rsp,rbp
      34:	pop    rbp
      35:	ret

0000000000000036 <botlish_entry_0: <program entry>>:
      36:	push   rbp
      37:	mov    rbp,rsp
      3a:	call   3f <botlish_entry_0+0x9>
			3b: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      3f:	mov    rsp,rbp
      42:	pop    rbp
      43:	ret

0000000000000044 <botlish_fn_1: chunked_new<generic>>:
      44:	push   rbp
      45:	mov    rbp,rsp
      48:	sub    rsp,0x30
      4c:	mov    QWORD PTR [rsp+0x10],r12
      51:	mov    QWORD PTR [rsp+0x18],r13
      56:	mov    QWORD PTR [rsp+0x20],r15
      5b:	mov    r12,rsi
      5e:	mov    r13,rdi
      61:	mov    QWORD PTR [rsp],0x0
      69:	mov    QWORD PTR [rsp+0x8],0x0
      72:	xor    rdx,rdx
      75:	mov    rdi,r13
      78:	mov    rsi,rdx
      7b:	call   80 <botlish_fn_1+0x3c>
			7c: R_X86_64_PLT32	rt_list_new-0x4
      80:	test   rax,rax
      83:	je     af <botlish_fn_1+0x6b>
      89:	mov    QWORD PTR [rsp],rax
      8d:	mov    r15,rax
      90:	mov    esi,0x81
      95:	mov    QWORD PTR [rsp+0x8],0x81
      9e:	mov    rdi,r13
      a1:	call   a6 <botlish_fn_1+0x62>
			a2: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      a6:	test   rax,rax
      a9:	jne    ca <botlish_fn_1+0x86>
      af:	xor    rax,rax
      b2:	mov    r12,QWORD PTR [rsp+0x10]
      b7:	mov    r13,QWORD PTR [rsp+0x18]
      bc:	mov    r15,QWORD PTR [rsp+0x20]
      c1:	add    rsp,0x30
      c5:	mov    rsp,rbp
      c8:	pop    rbp
      c9:	ret
      ca:	mov    rsi,r12
      cd:	mov    QWORD PTR [rsi],rax
      d0:	mov    QWORD PTR [rsi+0x8],0x1
      d8:	mov    rax,r15
      db:	mov    r12,QWORD PTR [rsp+0x10]
      e0:	mov    r13,QWORD PTR [rsp+0x18]
      e5:	mov    r15,QWORD PTR [rsp+0x20]
      ea:	add    rsp,0x30
      ee:	mov    rsp,rbp
      f1:	pop    rbp
      f2:	ret

00000000000000f3 <botlish_entry_1: chunked_new<generic>>:
      f3:	push   rbp
      f4:	mov    rbp,rsp
      f7:	ud2
      f9:	add    BYTE PTR [rax],al
      fb:	add    BYTE PTR [rax],al
      fd:	add    BYTE PTR [rax],al
	...

0000000000000100 <botlish_fn_2: chunked_append<list[list<never>, mutarray, int], str>>:
     100:	push   rbp
     101:	mov    rbp,rsp
     104:	sub    rsp,0x60
     108:	mov    QWORD PTR [rsp+0x30],rbx
     10d:	mov    QWORD PTR [rsp+0x38],r12
     112:	mov    QWORD PTR [rsp+0x40],r13
     117:	mov    QWORD PTR [rsp+0x48],r14
     11c:	mov    QWORD PTR [rsp+0x50],r15
     121:	mov    rbx,rcx
     124:	mov    r12,r9
     127:	mov    r13,rdi
     12a:	mov    QWORD PTR [rsp+0x18],0x0
     133:	mov    QWORD PTR [rsp],rsi
     137:	mov    r14,rsi
     13a:	mov    QWORD PTR [rsp+0x8],rdx
     13f:	mov    r15,rdx
     142:	mov    QWORD PTR [rsp+0x10],r8
     147:	mov    QWORD PTR [rsp+0x20],r8
     14c:	mov    rcx,rbx
     14f:	test   rcx,0x1
     156:	jne    181 <botlish_fn_2+0x81>
     15c:	mov    edx,0x81
     161:	mov    rsi,rbx
     164:	mov    rdi,r13
     167:	call   16c <botlish_fn_2+0x6c>
			168: R_X86_64_PLT32	rt_int_cmp-0x4
     16c:	mov    ecx,0x2
     171:	test   rax,rax
     174:	cmove  rcx,QWORD PTR [rip+0x174]        # 2f0 <botlish_fn_2+0x1f0>
     17c:	jmp    195 <botlish_fn_2+0x95>
     181:	mov    ecx,0x2
     186:	cmp    rbx,0x81
     18d:	cmove  rcx,QWORD PTR [rip+0x15b]        # 2f0 <botlish_fn_2+0x1f0>
     195:	cmp    rcx,0x6
     199:	je     230 <botlish_fn_2+0x130>
     19f:	mov    rcx,QWORD PTR [rsp+0x20]
     1a4:	mov    rdx,rbx
     1a7:	mov    rsi,r15
     1aa:	mov    rdi,r13
     1ad:	call   1b2 <botlish_fn_2+0xb2>
			1ae: R_X86_64_PLT32	rt_mutarray_set-0x4
     1b2:	test   rax,rax
     1b5:	je     291 <botlish_fn_2+0x191>
     1bb:	mov    QWORD PTR [rsp+0x18],0x3
     1c4:	test   rbx,0x1
     1cb:	je     1ee <botlish_fn_2+0xee>
     1d1:	mov    rax,rbx
     1d4:	add    rax,0x2
     1d8:	seto   cl
     1db:	test   cl,cl
     1dd:	jne    1ee <botlish_fn_2+0xee>
     1e3:	mov    rdx,r15
     1e6:	mov    rbx,r12
     1e9:	jmp    204 <botlish_fn_2+0x104>
     1ee:	mov    edx,0x3
     1f3:	mov    rsi,rbx
     1f6:	mov    rdi,r13
     1f9:	call   1fe <botlish_fn_2+0xfe>
			1fa: R_X86_64_PLT32	rt_int_add-0x4
     1fe:	mov    rdx,r15
     201:	mov    rbx,r12
     204:	mov    QWORD PTR [rbx],rdx
     207:	mov    QWORD PTR [rbx+0x8],rax
     20b:	mov    rax,r14
     20e:	mov    rbx,QWORD PTR [rsp+0x30]
     213:	mov    r12,QWORD PTR [rsp+0x38]
     218:	mov    r13,QWORD PTR [rsp+0x40]
     21d:	mov    r14,QWORD PTR [rsp+0x48]
     222:	mov    r15,QWORD PTR [rsp+0x50]
     227:	add    rsp,0x60
     22b:	mov    rsp,rbp
     22e:	pop    rbp
     22f:	ret
     230:	mov    rdx,r15
     233:	mov    rbx,r12
     236:	mov    rsi,r14
     239:	mov    rdi,r13
     23c:	call   241 <botlish_fn_2+0x141>
			23d: R_X86_64_PLT32	rt_list_append-0x4
     241:	test   rax,rax
     244:	je     291 <botlish_fn_2+0x191>
     24a:	mov    QWORD PTR [rsp],rax
     24e:	mov    r12,rax
     251:	mov    esi,0x81
     256:	mov    QWORD PTR [rsp+0x8],0x81
     25f:	mov    rdi,r13
     262:	call   267 <botlish_fn_2+0x167>
			263: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     267:	test   rax,rax
     26a:	mov    r14,rax
     26d:	je     291 <botlish_fn_2+0x191>
     273:	mov    edx,0x1
     278:	mov    rcx,QWORD PTR [rsp+0x20]
     27d:	mov    rdi,r13
     280:	mov    rsi,r14
     283:	call   288 <botlish_fn_2+0x188>
			284: R_X86_64_PLT32	rt_mutarray_set-0x4
     288:	test   rax,rax
     28b:	jne    2b6 <botlish_fn_2+0x1b6>
     291:	xor    rax,rax
     294:	mov    rbx,QWORD PTR [rsp+0x30]
     299:	mov    r12,QWORD PTR [rsp+0x38]
     29e:	mov    r13,QWORD PTR [rsp+0x40]
     2a3:	mov    r14,QWORD PTR [rsp+0x48]
     2a8:	mov    r15,QWORD PTR [rsp+0x50]
     2ad:	add    rsp,0x60
     2b1:	mov    rsp,rbp
     2b4:	pop    rbp
     2b5:	ret
     2b6:	mov    rax,r14
     2b9:	mov    QWORD PTR [rbx],rax
     2bc:	mov    QWORD PTR [rbx+0x8],0x3
     2c4:	mov    rax,r12
     2c7:	mov    rbx,QWORD PTR [rsp+0x30]
     2cc:	mov    r12,QWORD PTR [rsp+0x38]
     2d1:	mov    r13,QWORD PTR [rsp+0x40]
     2d6:	mov    r14,QWORD PTR [rsp+0x48]
     2db:	mov    r15,QWORD PTR [rsp+0x50]
     2e0:	add    rsp,0x60
     2e4:	mov    rsp,rbp
     2e7:	pop    rbp
     2e8:	ret
     2e9:	add    BYTE PTR [rax],al
     2eb:	add    BYTE PTR [rax],al
     2ed:	add    BYTE PTR [rax],al
     2ef:	add    BYTE PTR [rsi],al
     2f1:	add    BYTE PTR [rax],al
     2f3:	add    BYTE PTR [rax],al
     2f5:	add    BYTE PTR [rax],al
	...

00000000000002f8 <botlish_entry_2: chunked_append<list[list<never>, mutarray, int], str>>:
     2f8:	push   rbp
     2f9:	mov    rbp,rsp
     2fc:	ud2
	...

0000000000000300 <botlish_fn_3: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     300:	push   rbp
     301:	mov    rbp,rsp
     304:	sub    rsp,0x60
     308:	mov    QWORD PTR [rsp+0x30],rbx
     30d:	mov    QWORD PTR [rsp+0x38],r12
     312:	mov    QWORD PTR [rsp+0x40],r13
     317:	mov    QWORD PTR [rsp+0x48],r14
     31c:	mov    QWORD PTR [rsp+0x50],r15
     321:	mov    rbx,rcx
     324:	mov    r12,r9
     327:	mov    r13,rdi
     32a:	mov    QWORD PTR [rsp+0x18],0x0
     333:	mov    QWORD PTR [rsp],rsi
     337:	mov    r14,rsi
     33a:	mov    QWORD PTR [rsp+0x8],rdx
     33f:	mov    r15,rdx
     342:	mov    QWORD PTR [rsp+0x10],r8
     347:	mov    QWORD PTR [rsp+0x20],r8
     34c:	mov    rcx,rbx
     34f:	test   rcx,0x1
     356:	jne    381 <botlish_fn_3+0x81>
     35c:	mov    edx,0x81
     361:	mov    rsi,rbx
     364:	mov    rdi,r13
     367:	call   36c <botlish_fn_3+0x6c>
			368: R_X86_64_PLT32	rt_int_cmp-0x4
     36c:	mov    ecx,0x2
     371:	test   rax,rax
     374:	cmove  rcx,QWORD PTR [rip+0x174]        # 4f0 <botlish_fn_3+0x1f0>
     37c:	jmp    395 <botlish_fn_3+0x95>
     381:	mov    ecx,0x2
     386:	cmp    rbx,0x81
     38d:	cmove  rcx,QWORD PTR [rip+0x15b]        # 4f0 <botlish_fn_3+0x1f0>
     395:	cmp    rcx,0x6
     399:	je     430 <botlish_fn_3+0x130>
     39f:	mov    rcx,QWORD PTR [rsp+0x20]
     3a4:	mov    rdx,rbx
     3a7:	mov    rsi,r15
     3aa:	mov    rdi,r13
     3ad:	call   3b2 <botlish_fn_3+0xb2>
			3ae: R_X86_64_PLT32	rt_mutarray_set-0x4
     3b2:	test   rax,rax
     3b5:	je     491 <botlish_fn_3+0x191>
     3bb:	mov    QWORD PTR [rsp+0x18],0x3
     3c4:	test   rbx,0x1
     3cb:	je     3ee <botlish_fn_3+0xee>
     3d1:	mov    rax,rbx
     3d4:	add    rax,0x2
     3d8:	seto   cl
     3db:	test   cl,cl
     3dd:	jne    3ee <botlish_fn_3+0xee>
     3e3:	mov    rdx,r15
     3e6:	mov    rbx,r12
     3e9:	jmp    404 <botlish_fn_3+0x104>
     3ee:	mov    edx,0x3
     3f3:	mov    rsi,rbx
     3f6:	mov    rdi,r13
     3f9:	call   3fe <botlish_fn_3+0xfe>
			3fa: R_X86_64_PLT32	rt_int_add-0x4
     3fe:	mov    rdx,r15
     401:	mov    rbx,r12
     404:	mov    QWORD PTR [rbx],rdx
     407:	mov    QWORD PTR [rbx+0x8],rax
     40b:	mov    rax,r14
     40e:	mov    rbx,QWORD PTR [rsp+0x30]
     413:	mov    r12,QWORD PTR [rsp+0x38]
     418:	mov    r13,QWORD PTR [rsp+0x40]
     41d:	mov    r14,QWORD PTR [rsp+0x48]
     422:	mov    r15,QWORD PTR [rsp+0x50]
     427:	add    rsp,0x60
     42b:	mov    rsp,rbp
     42e:	pop    rbp
     42f:	ret
     430:	mov    rdx,r15
     433:	mov    rbx,r12
     436:	mov    rsi,r14
     439:	mov    rdi,r13
     43c:	call   441 <botlish_fn_3+0x141>
			43d: R_X86_64_PLT32	rt_list_append-0x4
     441:	test   rax,rax
     444:	je     491 <botlish_fn_3+0x191>
     44a:	mov    QWORD PTR [rsp],rax
     44e:	mov    r12,rax
     451:	mov    esi,0x81
     456:	mov    QWORD PTR [rsp+0x8],0x81
     45f:	mov    rdi,r13
     462:	call   467 <botlish_fn_3+0x167>
			463: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     467:	test   rax,rax
     46a:	mov    r14,rax
     46d:	je     491 <botlish_fn_3+0x191>
     473:	mov    edx,0x1
     478:	mov    rcx,QWORD PTR [rsp+0x20]
     47d:	mov    rdi,r13
     480:	mov    rsi,r14
     483:	call   488 <botlish_fn_3+0x188>
			484: R_X86_64_PLT32	rt_mutarray_set-0x4
     488:	test   rax,rax
     48b:	jne    4b6 <botlish_fn_3+0x1b6>
     491:	xor    rax,rax
     494:	mov    rbx,QWORD PTR [rsp+0x30]
     499:	mov    r12,QWORD PTR [rsp+0x38]
     49e:	mov    r13,QWORD PTR [rsp+0x40]
     4a3:	mov    r14,QWORD PTR [rsp+0x48]
     4a8:	mov    r15,QWORD PTR [rsp+0x50]
     4ad:	add    rsp,0x60
     4b1:	mov    rsp,rbp
     4b4:	pop    rbp
     4b5:	ret
     4b6:	mov    rax,r14
     4b9:	mov    QWORD PTR [rbx],rax
     4bc:	mov    QWORD PTR [rbx+0x8],0x3
     4c4:	mov    rax,r12
     4c7:	mov    rbx,QWORD PTR [rsp+0x30]
     4cc:	mov    r12,QWORD PTR [rsp+0x38]
     4d1:	mov    r13,QWORD PTR [rsp+0x40]
     4d6:	mov    r14,QWORD PTR [rsp+0x48]
     4db:	mov    r15,QWORD PTR [rsp+0x50]
     4e0:	add    rsp,0x60
     4e4:	mov    rsp,rbp
     4e7:	pop    rbp
     4e8:	ret
     4e9:	add    BYTE PTR [rax],al
     4eb:	add    BYTE PTR [rax],al
     4ed:	add    BYTE PTR [rax],al
     4ef:	add    BYTE PTR [rsi],al
     4f1:	add    BYTE PTR [rax],al
     4f3:	add    BYTE PTR [rax],al
     4f5:	add    BYTE PTR [rax],al
	...

00000000000004f8 <botlish_entry_3: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     4f8:	push   rbp
     4f9:	mov    rbp,rsp
     4fc:	ud2
	...

0000000000000500 <botlish_fn_4: chunked_append<list[list<never>, mutarray, int], list>>:
     500:	push   rbp
     501:	mov    rbp,rsp
     504:	sub    rsp,0x60
     508:	mov    QWORD PTR [rsp+0x30],rbx
     50d:	mov    QWORD PTR [rsp+0x38],r12
     512:	mov    QWORD PTR [rsp+0x40],r13
     517:	mov    QWORD PTR [rsp+0x48],r14
     51c:	mov    QWORD PTR [rsp+0x50],r15
     521:	mov    rbx,rcx
     524:	mov    r12,r9
     527:	mov    r13,rdi
     52a:	mov    QWORD PTR [rsp+0x18],0x0
     533:	mov    QWORD PTR [rsp],rsi
     537:	mov    r14,rsi
     53a:	mov    QWORD PTR [rsp+0x8],rdx
     53f:	mov    r15,rdx
     542:	mov    QWORD PTR [rsp+0x10],r8
     547:	mov    QWORD PTR [rsp+0x20],r8
     54c:	mov    rcx,rbx
     54f:	test   rcx,0x1
     556:	jne    581 <botlish_fn_4+0x81>
     55c:	mov    edx,0x81
     561:	mov    rsi,rbx
     564:	mov    rdi,r13
     567:	call   56c <botlish_fn_4+0x6c>
			568: R_X86_64_PLT32	rt_int_cmp-0x4
     56c:	mov    ecx,0x2
     571:	test   rax,rax
     574:	cmove  rcx,QWORD PTR [rip+0x174]        # 6f0 <botlish_fn_4+0x1f0>
     57c:	jmp    595 <botlish_fn_4+0x95>
     581:	mov    ecx,0x2
     586:	cmp    rbx,0x81
     58d:	cmove  rcx,QWORD PTR [rip+0x15b]        # 6f0 <botlish_fn_4+0x1f0>
     595:	cmp    rcx,0x6
     599:	je     630 <botlish_fn_4+0x130>
     59f:	mov    rcx,QWORD PTR [rsp+0x20]
     5a4:	mov    rdx,rbx
     5a7:	mov    rsi,r15
     5aa:	mov    rdi,r13
     5ad:	call   5b2 <botlish_fn_4+0xb2>
			5ae: R_X86_64_PLT32	rt_mutarray_set-0x4
     5b2:	test   rax,rax
     5b5:	je     691 <botlish_fn_4+0x191>
     5bb:	mov    QWORD PTR [rsp+0x18],0x3
     5c4:	test   rbx,0x1
     5cb:	je     5ee <botlish_fn_4+0xee>
     5d1:	mov    rax,rbx
     5d4:	add    rax,0x2
     5d8:	seto   cl
     5db:	test   cl,cl
     5dd:	jne    5ee <botlish_fn_4+0xee>
     5e3:	mov    rdx,r15
     5e6:	mov    rbx,r12
     5e9:	jmp    604 <botlish_fn_4+0x104>
     5ee:	mov    edx,0x3
     5f3:	mov    rsi,rbx
     5f6:	mov    rdi,r13
     5f9:	call   5fe <botlish_fn_4+0xfe>
			5fa: R_X86_64_PLT32	rt_int_add-0x4
     5fe:	mov    rdx,r15
     601:	mov    rbx,r12
     604:	mov    QWORD PTR [rbx],rdx
     607:	mov    QWORD PTR [rbx+0x8],rax
     60b:	mov    rax,r14
     60e:	mov    rbx,QWORD PTR [rsp+0x30]
     613:	mov    r12,QWORD PTR [rsp+0x38]
     618:	mov    r13,QWORD PTR [rsp+0x40]
     61d:	mov    r14,QWORD PTR [rsp+0x48]
     622:	mov    r15,QWORD PTR [rsp+0x50]
     627:	add    rsp,0x60
     62b:	mov    rsp,rbp
     62e:	pop    rbp
     62f:	ret
     630:	mov    rdx,r15
     633:	mov    rbx,r12
     636:	mov    rsi,r14
     639:	mov    rdi,r13
     63c:	call   641 <botlish_fn_4+0x141>
			63d: R_X86_64_PLT32	rt_list_append-0x4
     641:	test   rax,rax
     644:	je     691 <botlish_fn_4+0x191>
     64a:	mov    QWORD PTR [rsp],rax
     64e:	mov    r12,rax
     651:	mov    esi,0x81
     656:	mov    QWORD PTR [rsp+0x8],0x81
     65f:	mov    rdi,r13
     662:	call   667 <botlish_fn_4+0x167>
			663: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     667:	test   rax,rax
     66a:	mov    r14,rax
     66d:	je     691 <botlish_fn_4+0x191>
     673:	mov    edx,0x1
     678:	mov    rcx,QWORD PTR [rsp+0x20]
     67d:	mov    rdi,r13
     680:	mov    rsi,r14
     683:	call   688 <botlish_fn_4+0x188>
			684: R_X86_64_PLT32	rt_mutarray_set-0x4
     688:	test   rax,rax
     68b:	jne    6b6 <botlish_fn_4+0x1b6>
     691:	xor    rax,rax
     694:	mov    rbx,QWORD PTR [rsp+0x30]
     699:	mov    r12,QWORD PTR [rsp+0x38]
     69e:	mov    r13,QWORD PTR [rsp+0x40]
     6a3:	mov    r14,QWORD PTR [rsp+0x48]
     6a8:	mov    r15,QWORD PTR [rsp+0x50]
     6ad:	add    rsp,0x60
     6b1:	mov    rsp,rbp
     6b4:	pop    rbp
     6b5:	ret
     6b6:	mov    rax,r14
     6b9:	mov    QWORD PTR [rbx],rax
     6bc:	mov    QWORD PTR [rbx+0x8],0x3
     6c4:	mov    rax,r12
     6c7:	mov    rbx,QWORD PTR [rsp+0x30]
     6cc:	mov    r12,QWORD PTR [rsp+0x38]
     6d1:	mov    r13,QWORD PTR [rsp+0x40]
     6d6:	mov    r14,QWORD PTR [rsp+0x48]
     6db:	mov    r15,QWORD PTR [rsp+0x50]
     6e0:	add    rsp,0x60
     6e4:	mov    rsp,rbp
     6e7:	pop    rbp
     6e8:	ret
     6e9:	add    BYTE PTR [rax],al
     6eb:	add    BYTE PTR [rax],al
     6ed:	add    BYTE PTR [rax],al
     6ef:	add    BYTE PTR [rsi],al
     6f1:	add    BYTE PTR [rax],al
     6f3:	add    BYTE PTR [rax],al
     6f5:	add    BYTE PTR [rax],al
	...

00000000000006f8 <botlish_entry_4: chunked_append<list[list<never>, mutarray, int], list>>:
     6f8:	push   rbp
     6f9:	mov    rbp,rsp
     6fc:	ud2
	...

0000000000000700 <botlish_fn_5: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     700:	push   rbp
     701:	mov    rbp,rsp
     704:	sub    rsp,0x60
     708:	mov    QWORD PTR [rsp+0x30],rbx
     70d:	mov    QWORD PTR [rsp+0x38],r12
     712:	mov    QWORD PTR [rsp+0x40],r13
     717:	mov    QWORD PTR [rsp+0x48],r14
     71c:	mov    QWORD PTR [rsp+0x50],r15
     721:	mov    rbx,rcx
     724:	mov    r12,r9
     727:	mov    r13,rdi
     72a:	mov    QWORD PTR [rsp+0x18],0x0
     733:	mov    QWORD PTR [rsp],rsi
     737:	mov    r14,rsi
     73a:	mov    QWORD PTR [rsp+0x8],rdx
     73f:	mov    r15,rdx
     742:	mov    QWORD PTR [rsp+0x10],r8
     747:	mov    QWORD PTR [rsp+0x20],r8
     74c:	mov    rcx,rbx
     74f:	test   rcx,0x1
     756:	jne    781 <botlish_fn_5+0x81>
     75c:	mov    edx,0x81
     761:	mov    rsi,rbx
     764:	mov    rdi,r13
     767:	call   76c <botlish_fn_5+0x6c>
			768: R_X86_64_PLT32	rt_int_cmp-0x4
     76c:	mov    ecx,0x2
     771:	test   rax,rax
     774:	cmove  rcx,QWORD PTR [rip+0x174]        # 8f0 <botlish_fn_5+0x1f0>
     77c:	jmp    795 <botlish_fn_5+0x95>
     781:	mov    ecx,0x2
     786:	cmp    rbx,0x81
     78d:	cmove  rcx,QWORD PTR [rip+0x15b]        # 8f0 <botlish_fn_5+0x1f0>
     795:	cmp    rcx,0x6
     799:	je     830 <botlish_fn_5+0x130>
     79f:	mov    rcx,QWORD PTR [rsp+0x20]
     7a4:	mov    rdx,rbx
     7a7:	mov    rsi,r15
     7aa:	mov    rdi,r13
     7ad:	call   7b2 <botlish_fn_5+0xb2>
			7ae: R_X86_64_PLT32	rt_mutarray_set-0x4
     7b2:	test   rax,rax
     7b5:	je     891 <botlish_fn_5+0x191>
     7bb:	mov    QWORD PTR [rsp+0x18],0x3
     7c4:	test   rbx,0x1
     7cb:	je     7ee <botlish_fn_5+0xee>
     7d1:	mov    rax,rbx
     7d4:	add    rax,0x2
     7d8:	seto   cl
     7db:	test   cl,cl
     7dd:	jne    7ee <botlish_fn_5+0xee>
     7e3:	mov    rdx,r15
     7e6:	mov    rbx,r12
     7e9:	jmp    804 <botlish_fn_5+0x104>
     7ee:	mov    edx,0x3
     7f3:	mov    rsi,rbx
     7f6:	mov    rdi,r13
     7f9:	call   7fe <botlish_fn_5+0xfe>
			7fa: R_X86_64_PLT32	rt_int_add-0x4
     7fe:	mov    rdx,r15
     801:	mov    rbx,r12
     804:	mov    QWORD PTR [rbx],rdx
     807:	mov    QWORD PTR [rbx+0x8],rax
     80b:	mov    rax,r14
     80e:	mov    rbx,QWORD PTR [rsp+0x30]
     813:	mov    r12,QWORD PTR [rsp+0x38]
     818:	mov    r13,QWORD PTR [rsp+0x40]
     81d:	mov    r14,QWORD PTR [rsp+0x48]
     822:	mov    r15,QWORD PTR [rsp+0x50]
     827:	add    rsp,0x60
     82b:	mov    rsp,rbp
     82e:	pop    rbp
     82f:	ret
     830:	mov    rdx,r15
     833:	mov    rbx,r12
     836:	mov    rsi,r14
     839:	mov    rdi,r13
     83c:	call   841 <botlish_fn_5+0x141>
			83d: R_X86_64_PLT32	rt_list_append-0x4
     841:	test   rax,rax
     844:	je     891 <botlish_fn_5+0x191>
     84a:	mov    QWORD PTR [rsp],rax
     84e:	mov    r12,rax
     851:	mov    esi,0x81
     856:	mov    QWORD PTR [rsp+0x8],0x81
     85f:	mov    rdi,r13
     862:	call   867 <botlish_fn_5+0x167>
			863: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     867:	test   rax,rax
     86a:	mov    r14,rax
     86d:	je     891 <botlish_fn_5+0x191>
     873:	mov    edx,0x1
     878:	mov    rcx,QWORD PTR [rsp+0x20]
     87d:	mov    rdi,r13
     880:	mov    rsi,r14
     883:	call   888 <botlish_fn_5+0x188>
			884: R_X86_64_PLT32	rt_mutarray_set-0x4
     888:	test   rax,rax
     88b:	jne    8b6 <botlish_fn_5+0x1b6>
     891:	xor    rax,rax
     894:	mov    rbx,QWORD PTR [rsp+0x30]
     899:	mov    r12,QWORD PTR [rsp+0x38]
     89e:	mov    r13,QWORD PTR [rsp+0x40]
     8a3:	mov    r14,QWORD PTR [rsp+0x48]
     8a8:	mov    r15,QWORD PTR [rsp+0x50]
     8ad:	add    rsp,0x60
     8b1:	mov    rsp,rbp
     8b4:	pop    rbp
     8b5:	ret
     8b6:	mov    rax,r14
     8b9:	mov    QWORD PTR [rbx],rax
     8bc:	mov    QWORD PTR [rbx+0x8],0x3
     8c4:	mov    rax,r12
     8c7:	mov    rbx,QWORD PTR [rsp+0x30]
     8cc:	mov    r12,QWORD PTR [rsp+0x38]
     8d1:	mov    r13,QWORD PTR [rsp+0x40]
     8d6:	mov    r14,QWORD PTR [rsp+0x48]
     8db:	mov    r15,QWORD PTR [rsp+0x50]
     8e0:	add    rsp,0x60
     8e4:	mov    rsp,rbp
     8e7:	pop    rbp
     8e8:	ret
     8e9:	add    BYTE PTR [rax],al
     8eb:	add    BYTE PTR [rax],al
     8ed:	add    BYTE PTR [rax],al
     8ef:	add    BYTE PTR [rsi],al
     8f1:	add    BYTE PTR [rax],al
     8f3:	add    BYTE PTR [rax],al
     8f5:	add    BYTE PTR [rax],al
	...

00000000000008f8 <botlish_entry_5: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     8f8:	push   rbp
     8f9:	mov    rbp,rsp
     8fc:	ud2
	...

0000000000000900 <botlish_fn_6: chunked_copy_chunks<list<never>, int, mutarray, int>>:
     900:	push   rbp
     901:	mov    rbp,rsp
     904:	sub    rsp,0x60
     908:	mov    QWORD PTR [rsp+0x30],rbx
     90d:	mov    QWORD PTR [rsp+0x38],r12
     912:	mov    QWORD PTR [rsp+0x40],r13
     917:	mov    QWORD PTR [rsp+0x48],r14
     91c:	mov    QWORD PTR [rsp+0x50],r15
     921:	mov    rbx,rdx
     924:	mov    r14,rdi
     927:	mov    QWORD PTR [rsp],rsi
     92b:	mov    QWORD PTR [rsp+0x8],rcx
     930:	mov    r12,rcx
     933:	mov    QWORD PTR [rsp+0x10],r8
     938:	mov    r13,rsi
     93b:	mov    r15,r8
     93e:	mov    rsi,r13
     941:	mov    rdi,r14
     944:	call   949 <botlish_fn_6+0x49>
			945: R_X86_64_PLT32	rt_list_len-0x4
     949:	mov    rcx,rbx
     94c:	and    rcx,rax
     94f:	mov    rdx,rax
     952:	test   rcx,0x1
     959:	jne    97f <botlish_fn_6+0x7f>
     95f:	mov    rsi,rbx
     962:	mov    rdi,r14
     965:	call   96a <botlish_fn_6+0x6a>
			966: R_X86_64_PLT32	rt_int_cmp-0x4
     96a:	mov    ecx,0x2
     96f:	test   rax,rax
     972:	cmovge rcx,QWORD PTR [rip+0x17e]        # af8 <botlish_fn_6+0x1f8>
     97a:	jmp    98f <botlish_fn_6+0x8f>
     97f:	mov    ecx,0x2
     984:	cmp    rbx,rdx
     987:	cmovge rcx,QWORD PTR [rip+0x169]        # af8 <botlish_fn_6+0x1f8>
     98f:	cmp    rcx,0x6
     993:	je     ad3 <botlish_fn_6+0x1d3>
     999:	test   rbx,0x1
     9a0:	je     9b9 <botlish_fn_6+0xb9>
     9a6:	mov    rcx,QWORD PTR [r13+0x8]
     9aa:	mov    rax,rbx
     9ad:	sar    rax,1
     9b0:	cmp    rax,rcx
     9b3:	jb     9d8 <botlish_fn_6+0xd8>
     9b9:	mov    rdx,rbx
     9bc:	mov    rsi,r13
     9bf:	mov    rdi,r14
     9c2:	call   9c7 <botlish_fn_6+0xc7>
			9c3: R_X86_64_PLT32	rt_list_get-0x4
     9c7:	test   rax,rax
     9ca:	je     a42 <botlish_fn_6+0x142>
     9d0:	mov    rsi,rax
     9d3:	jmp    9e0 <botlish_fn_6+0xe0>
     9d8:	mov    rsi,QWORD PTR [r13+0x10]
     9dc:	mov    rsi,QWORD PTR [rsi+rax*8]
     9e0:	xor    eax,eax
     9e2:	test   rsi,0x7
     9e9:	jne    9fa <botlish_fn_6+0xfa>
     9ef:	movzx  r8,BYTE PTR [rsi]
     9f3:	cmp    r8b,0x8
     9f7:	sete   al
     9fa:	test   al,al
     9fc:	jne    a1c <botlish_fn_6+0x11c>
     a02:	mov    rdi,r14
     a05:	mov    rax,QWORD PTR [rdi+0x10]
     a09:	mov    rcx,QWORD PTR [rax+0x8]
     a0d:	mov    edx,0x8
     a12:	call   a17 <botlish_fn_6+0x117>
			a13: R_X86_64_PLT32	rt_type_error-0x4
     a17:	jmp    a42 <botlish_fn_6+0x142>
     a1c:	mov    rcx,rsi
     a1f:	mov    r8d,0x1
     a25:	mov    r9d,0x81
     a2b:	mov    rdx,r15
     a2e:	mov    rsi,r12
     a31:	mov    rdi,r14
     a34:	call   a39 <botlish_fn_6+0x139>
			a35: R_X86_64_PLT32	rt_mutarray_copy-0x4
     a39:	test   rax,rax
     a3c:	jne    a67 <botlish_fn_6+0x167>
     a42:	xor    rax,rax
     a45:	mov    rbx,QWORD PTR [rsp+0x30]
     a4a:	mov    r12,QWORD PTR [rsp+0x38]
     a4f:	mov    r13,QWORD PTR [rsp+0x40]
     a54:	mov    r14,QWORD PTR [rsp+0x48]
     a59:	mov    r15,QWORD PTR [rsp+0x50]
     a5e:	add    rsp,0x60
     a62:	mov    rsp,rbp
     a65:	pop    rbp
     a66:	ret
     a67:	sar    rbx,1
     a6a:	add    rbx,0x1
     a71:	shl    rbx,1
     a74:	or     rbx,0x1
     a78:	mov    QWORD PTR [rsp+0x18],rbx
     a7d:	mov    QWORD PTR [rsp+0x20],0x81
     a86:	mov    rsi,r15
     a89:	test   rsi,0x1
     a90:	je     aad <botlish_fn_6+0x1ad>
     a96:	mov    rsi,r15
     a99:	mov    rax,rsi
     a9c:	add    rax,0x80
     aa2:	seto   cl
     aa5:	test   cl,cl
     aa7:	je     abd <botlish_fn_6+0x1bd>
     aad:	mov    edx,0x81
     ab2:	mov    rsi,r15
     ab5:	mov    rdi,r14
     ab8:	call   abd <botlish_fn_6+0x1bd>
			ab9: R_X86_64_PLT32	rt_int_add-0x4
     abd:	mov    QWORD PTR [rsp],r13
     ac1:	mov    QWORD PTR [rsp+0x8],r12
     ac6:	mov    QWORD PTR [rsp+0x10],rax
     acb:	mov    r15,rax
     ace:	jmp    93e <botlish_fn_6+0x3e>
     ad3:	mov    rax,r15
     ad6:	mov    rbx,QWORD PTR [rsp+0x30]
     adb:	mov    r12,QWORD PTR [rsp+0x38]
     ae0:	mov    r13,QWORD PTR [rsp+0x40]
     ae5:	mov    r14,QWORD PTR [rsp+0x48]
     aea:	mov    r15,QWORD PTR [rsp+0x50]
     aef:	add    rsp,0x60
     af3:	mov    rsp,rbp
     af6:	pop    rbp
     af7:	ret
     af8:	(bad)
     af9:	add    BYTE PTR [rax],al
     afb:	add    BYTE PTR [rax],al
     afd:	add    BYTE PTR [rax],al
	...

0000000000000b00 <botlish_entry_6: chunked_copy_chunks<list<never>, int, mutarray, int>>:
     b00:	push   rbp
     b01:	mov    rbp,rsp
     b04:	mov    rsi,QWORD PTR [rdx]
     b07:	mov    r9,QWORD PTR [rdx+0x8]
     b0b:	mov    rcx,QWORD PTR [rdx+0x10]
     b0f:	mov    r8,QWORD PTR [rdx+0x18]
     b13:	mov    rdx,r9
     b16:	call   b1b <botlish_entry_6+0x1b>
			b17: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
     b1b:	mov    rsp,rbp
     b1e:	pop    rbp
     b1f:	ret

0000000000000b20 <botlish_fn_7: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
     b20:	push   rbp
     b21:	mov    rbp,rsp
     b24:	sub    rsp,0x60
     b28:	mov    QWORD PTR [rsp+0x30],rbx
     b2d:	mov    QWORD PTR [rsp+0x38],r12
     b32:	mov    QWORD PTR [rsp+0x40],r13
     b37:	mov    QWORD PTR [rsp+0x48],r14
     b3c:	mov    QWORD PTR [rsp+0x50],r15
     b41:	mov    rbx,rdx
     b44:	mov    r15,rdi
     b47:	mov    QWORD PTR [rsp],rsi
     b4b:	mov    QWORD PTR [rsp+0x8],rcx
     b50:	mov    r13,rcx
     b53:	mov    QWORD PTR [rsp+0x10],r8
     b58:	mov    r12,rsi
     b5b:	mov    r14,r8
     b5e:	mov    rsi,r12
     b61:	mov    rdi,r15
     b64:	call   b69 <botlish_fn_7+0x49>
			b65: R_X86_64_PLT32	rt_list_len-0x4
     b69:	mov    rcx,rbx
     b6c:	and    rcx,rax
     b6f:	mov    rdx,rax
     b72:	test   rcx,0x1
     b79:	jne    b9f <botlish_fn_7+0x7f>
     b7f:	mov    rsi,rbx
     b82:	mov    rdi,r15
     b85:	call   b8a <botlish_fn_7+0x6a>
			b86: R_X86_64_PLT32	rt_int_cmp-0x4
     b8a:	mov    ecx,0x2
     b8f:	test   rax,rax
     b92:	cmovge rcx,QWORD PTR [rip+0x156]        # cf0 <botlish_fn_7+0x1d0>
     b9a:	jmp    baf <botlish_fn_7+0x8f>
     b9f:	mov    ecx,0x2
     ba4:	cmp    rbx,rdx
     ba7:	cmovge rcx,QWORD PTR [rip+0x141]        # cf0 <botlish_fn_7+0x1d0>
     baf:	cmp    rcx,0x6
     bb3:	je     cc6 <botlish_fn_7+0x1a6>
     bb9:	test   rbx,0x1
     bc0:	je     bda <botlish_fn_7+0xba>
     bc6:	mov    rax,QWORD PTR [r12+0x8]
     bcb:	mov    rcx,rbx
     bce:	sar    rcx,1
     bd1:	cmp    rcx,rax
     bd4:	jb     bfe <botlish_fn_7+0xde>
     bda:	mov    rdx,rbx
     bdd:	mov    rsi,r12
     be0:	mov    rdi,r15
     be3:	call   be8 <botlish_fn_7+0xc8>
			be4: R_X86_64_PLT32	rt_list_get-0x4
     be8:	test   rax,rax
     beb:	je     c34 <botlish_fn_7+0x114>
     bf1:	mov    rcx,rax
     bf4:	mov    QWORD PTR [rsp+0x28],r14
     bf9:	jmp    c0c <botlish_fn_7+0xec>
     bfe:	mov    rax,QWORD PTR [r12+0x10]
     c03:	mov    rcx,QWORD PTR [rax+rcx*8]
     c07:	mov    QWORD PTR [rsp+0x28],r14
     c0c:	mov    r8d,0x1
     c12:	mov    r9d,0x81
     c18:	mov    r14,r13
     c1b:	mov    rdx,QWORD PTR [rsp+0x28]
     c20:	mov    rsi,r14
     c23:	mov    rdi,r15
     c26:	call   c2b <botlish_fn_7+0x10b>
			c27: R_X86_64_PLT32	rt_mutarray_copy-0x4
     c2b:	test   rax,rax
     c2e:	jne    c59 <botlish_fn_7+0x139>
     c34:	xor    rax,rax
     c37:	mov    rbx,QWORD PTR [rsp+0x30]
     c3c:	mov    r12,QWORD PTR [rsp+0x38]
     c41:	mov    r13,QWORD PTR [rsp+0x40]
     c46:	mov    r14,QWORD PTR [rsp+0x48]
     c4b:	mov    r15,QWORD PTR [rsp+0x50]
     c50:	add    rsp,0x60
     c54:	mov    rsp,rbp
     c57:	pop    rbp
     c58:	ret
     c59:	sar    rbx,1
     c5c:	add    rbx,0x1
     c63:	shl    rbx,1
     c66:	or     rbx,0x1
     c6a:	mov    QWORD PTR [rsp+0x18],rbx
     c6f:	mov    QWORD PTR [rsp+0x20],0x81
     c78:	mov    rsi,QWORD PTR [rsp+0x28]
     c7d:	test   rsi,0x1
     c84:	je     ca0 <botlish_fn_7+0x180>
     c8a:	mov    rax,rsi
     c8d:	add    rax,0x80
     c93:	seto   dil
     c97:	test   dil,dil
     c9a:	je     cad <botlish_fn_7+0x18d>
     ca0:	mov    edx,0x81
     ca5:	mov    rdi,r15
     ca8:	call   cad <botlish_fn_7+0x18d>
			ca9: R_X86_64_PLT32	rt_int_add-0x4
     cad:	mov    QWORD PTR [rsp],r12
     cb1:	mov    QWORD PTR [rsp+0x8],r14
     cb6:	mov    QWORD PTR [rsp+0x10],rax
     cbb:	mov    r13,r14
     cbe:	mov    r14,rax
     cc1:	jmp    b5e <botlish_fn_7+0x3e>
     cc6:	mov    rax,r14
     cc9:	mov    rbx,QWORD PTR [rsp+0x30]
     cce:	mov    r12,QWORD PTR [rsp+0x38]
     cd3:	mov    r13,QWORD PTR [rsp+0x40]
     cd8:	mov    r14,QWORD PTR [rsp+0x48]
     cdd:	mov    r15,QWORD PTR [rsp+0x50]
     ce2:	add    rsp,0x60
     ce6:	mov    rsp,rbp
     ce9:	pop    rbp
     cea:	ret
     ceb:	add    BYTE PTR [rax],al
     ced:	add    BYTE PTR [rax],al
     cef:	add    BYTE PTR [rsi],al
     cf1:	add    BYTE PTR [rax],al
     cf3:	add    BYTE PTR [rax],al
     cf5:	add    BYTE PTR [rax],al
	...

0000000000000cf8 <botlish_entry_7: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
     cf8:	push   rbp
     cf9:	mov    rbp,rsp
     cfc:	mov    rsi,QWORD PTR [rdx]
     cff:	mov    r9,QWORD PTR [rdx+0x8]
     d03:	mov    rcx,QWORD PTR [rdx+0x10]
     d07:	mov    r8,QWORD PTR [rdx+0x18]
     d0b:	mov    rdx,r9
     d0e:	call   d13 <botlish_entry_7+0x1b>
			d0f: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
     d13:	mov    rsp,rbp
     d16:	pop    rbp
     d17:	ret

0000000000000d18 <botlish_fn_8: chunked_finish<list[list<never>, mutarray, int]>>:
     d18:	push   rbp
     d19:	mov    rbp,rsp
     d1c:	sub    rsp,0x70
     d20:	mov    QWORD PTR [rsp+0x40],rbx
     d25:	mov    QWORD PTR [rsp+0x48],r12
     d2a:	mov    QWORD PTR [rsp+0x50],r13
     d2f:	mov    QWORD PTR [rsp+0x58],r14
     d34:	mov    QWORD PTR [rsp+0x60],r15
     d39:	mov    r13,rdi
     d3c:	mov    QWORD PTR [rsp+0x28],0x0
     d45:	mov    QWORD PTR [rsp+0x30],0x0
     d4e:	mov    QWORD PTR [rsp],rsi
     d52:	mov    r15,rsi
     d55:	mov    QWORD PTR [rsp+0x8],rdx
     d5a:	mov    r14,rdx
     d5d:	mov    QWORD PTR [rsp+0x10],rcx
     d62:	mov    r12,rcx
     d65:	mov    rsi,r15
     d68:	mov    rdi,r13
     d6b:	call   d70 <botlish_fn_8+0x58>
			d6c: R_X86_64_PLT32	rt_list_len-0x4
     d70:	mov    QWORD PTR [rsp+0x18],rax
     d75:	mov    QWORD PTR [rsp+0x20],0x81
     d7e:	test   rax,0x1
     d84:	mov    rsi,rax
     d87:	je     db4 <botlish_fn_8+0x9c>
     d8d:	mov    rdx,rsi
     d90:	mov    rax,rdx
     d93:	sar    rax,1
     d96:	imul   QWORD PTR [rip+0x14b]        # ee8 <botlish_fn_8+0x1d0>
     d9d:	seto   cl
     da0:	or     rax,0x1
     da4:	test   cl,cl
     da6:	jne    db4 <botlish_fn_8+0x9c>
     dac:	mov    rsi,rax
     daf:	jmp    dc4 <botlish_fn_8+0xac>
     db4:	mov    edx,0x81
     db9:	mov    rdi,r13
     dbc:	call   dc1 <botlish_fn_8+0xa9>
			dbd: R_X86_64_PLT32	rt_int_mul-0x4
     dc1:	mov    rsi,rax
     dc4:	mov    QWORD PTR [rsp+0x18],rsi
     dc9:	mov    rax,rsi
     dcc:	and    rax,r12
     dcf:	test   rax,0x1
     dd5:	je     df1 <botlish_fn_8+0xd9>
     ddb:	lea    rcx,[r12-0x1]
     de0:	mov    rbx,rsi
     de3:	add    rbx,rcx
     de6:	seto   al
     de9:	test   al,al
     deb:	je     dff <botlish_fn_8+0xe7>
     df1:	mov    rdx,r12
     df4:	mov    rdi,r13
     df7:	call   dfc <botlish_fn_8+0xe4>
			df8: R_X86_64_PLT32	rt_int_add-0x4
     dfc:	mov    rbx,rax
     dff:	mov    QWORD PTR [rsp+0x18],rbx
     e04:	mov    rsi,rbx
     e07:	mov    rdi,r13
     e0a:	call   e0f <botlish_fn_8+0xf7>
			e0b: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     e0f:	mov    rcx,rax
     e12:	mov    QWORD PTR [rsp+0x38],rax
     e17:	test   rax,rcx
     e1a:	je     e9c <botlish_fn_8+0x184>
     e20:	mov    rax,QWORD PTR [rsp+0x38]
     e25:	mov    QWORD PTR [rsp+0x20],rax
     e2a:	mov    r8d,0x1
     e30:	mov    QWORD PTR [rsp+0x28],0x1
     e39:	mov    QWORD PTR [rsp+0x30],0x1
     e42:	mov    rsi,r15
     e45:	mov    rcx,QWORD PTR [rsp+0x38]
     e4a:	mov    rdi,r13
     e4d:	mov    rdx,r8
     e50:	call   e55 <botlish_fn_8+0x13d>
			e51: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
     e55:	test   rax,rax
     e58:	mov    rdx,rax
     e5b:	je     e9c <botlish_fn_8+0x184>
     e61:	mov    r8d,0x1
     e67:	mov    rcx,r14
     e6a:	mov    r9,r12
     e6d:	mov    rsi,QWORD PTR [rsp+0x38]
     e72:	mov    rdi,r13
     e75:	call   e7a <botlish_fn_8+0x162>
			e76: R_X86_64_PLT32	rt_mutarray_copy-0x4
     e7a:	test   rax,rax
     e7d:	je     e9c <botlish_fn_8+0x184>
     e83:	mov    rdx,rbx
     e86:	mov    rsi,QWORD PTR [rsp+0x38]
     e8b:	mov    rdi,r13
     e8e:	call   e93 <botlish_fn_8+0x17b>
			e8f: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     e93:	test   rax,rax
     e96:	jne    ec1 <botlish_fn_8+0x1a9>
     e9c:	xor    rax,rax
     e9f:	mov    rbx,QWORD PTR [rsp+0x40]
     ea4:	mov    r12,QWORD PTR [rsp+0x48]
     ea9:	mov    r13,QWORD PTR [rsp+0x50]
     eae:	mov    r14,QWORD PTR [rsp+0x58]
     eb3:	mov    r15,QWORD PTR [rsp+0x60]
     eb8:	add    rsp,0x70
     ebc:	mov    rsp,rbp
     ebf:	pop    rbp
     ec0:	ret
     ec1:	mov    rbx,QWORD PTR [rsp+0x40]
     ec6:	mov    r12,QWORD PTR [rsp+0x48]
     ecb:	mov    r13,QWORD PTR [rsp+0x50]
     ed0:	mov    r14,QWORD PTR [rsp+0x58]
     ed5:	mov    r15,QWORD PTR [rsp+0x60]
     eda:	add    rsp,0x70
     ede:	mov    rsp,rbp
     ee1:	pop    rbp
     ee2:	ret
     ee3:	add    BYTE PTR [rax],al
     ee5:	add    BYTE PTR [rax],al
     ee7:	add    BYTE PTR [rax+0x0],al
     eed:	add    BYTE PTR [rax],al
	...

0000000000000ef0 <botlish_entry_8: chunked_finish<list[list<never>, mutarray, int]>>:
     ef0:	push   rbp
     ef1:	mov    rbp,rsp
     ef4:	mov    rsi,QWORD PTR [rdx]
     ef7:	mov    r8,QWORD PTR [rdx+0x8]
     efb:	mov    rcx,QWORD PTR [rdx+0x10]
     eff:	mov    rdx,r8
     f02:	call   f07 <botlish_entry_8+0x17>
			f03: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
     f07:	mov    rsp,rbp
     f0a:	pop    rbp
     f0b:	ret
     f0c:	add    BYTE PTR [rax],al
	...

0000000000000f10 <botlish_fn_9: chunked_finish<list[list<mutarray>, mutarray, int]>>:
     f10:	push   rbp
     f11:	mov    rbp,rsp
     f14:	sub    rsp,0x70
     f18:	mov    QWORD PTR [rsp+0x40],rbx
     f1d:	mov    QWORD PTR [rsp+0x48],r12
     f22:	mov    QWORD PTR [rsp+0x50],r13
     f27:	mov    QWORD PTR [rsp+0x58],r14
     f2c:	mov    QWORD PTR [rsp+0x60],r15
     f31:	mov    r13,rdi
     f34:	mov    QWORD PTR [rsp+0x28],0x0
     f3d:	mov    QWORD PTR [rsp+0x30],0x0
     f46:	mov    QWORD PTR [rsp],rsi
     f4a:	mov    r15,rsi
     f4d:	mov    QWORD PTR [rsp+0x8],rdx
     f52:	mov    r14,rdx
     f55:	mov    QWORD PTR [rsp+0x10],rcx
     f5a:	mov    r12,rcx
     f5d:	mov    rsi,r15
     f60:	mov    rdi,r13
     f63:	call   f68 <botlish_fn_9+0x58>
			f64: R_X86_64_PLT32	rt_list_len-0x4
     f68:	mov    QWORD PTR [rsp+0x18],rax
     f6d:	mov    QWORD PTR [rsp+0x20],0x81
     f76:	test   rax,0x1
     f7c:	mov    rsi,rax
     f7f:	je     fac <botlish_fn_9+0x9c>
     f85:	mov    rdx,rsi
     f88:	mov    rax,rdx
     f8b:	sar    rax,1
     f8e:	imul   QWORD PTR [rip+0x14b]        # 10e0 <botlish_fn_9+0x1d0>
     f95:	seto   cl
     f98:	or     rax,0x1
     f9c:	test   cl,cl
     f9e:	jne    fac <botlish_fn_9+0x9c>
     fa4:	mov    rsi,rax
     fa7:	jmp    fbc <botlish_fn_9+0xac>
     fac:	mov    edx,0x81
     fb1:	mov    rdi,r13
     fb4:	call   fb9 <botlish_fn_9+0xa9>
			fb5: R_X86_64_PLT32	rt_int_mul-0x4
     fb9:	mov    rsi,rax
     fbc:	mov    QWORD PTR [rsp+0x18],rsi
     fc1:	mov    rax,rsi
     fc4:	and    rax,r12
     fc7:	test   rax,0x1
     fcd:	je     fe9 <botlish_fn_9+0xd9>
     fd3:	lea    rcx,[r12-0x1]
     fd8:	mov    rbx,rsi
     fdb:	add    rbx,rcx
     fde:	seto   al
     fe1:	test   al,al
     fe3:	je     ff7 <botlish_fn_9+0xe7>
     fe9:	mov    rdx,r12
     fec:	mov    rdi,r13
     fef:	call   ff4 <botlish_fn_9+0xe4>
			ff0: R_X86_64_PLT32	rt_int_add-0x4
     ff4:	mov    rbx,rax
     ff7:	mov    QWORD PTR [rsp+0x18],rbx
     ffc:	mov    rsi,rbx
     fff:	mov    rdi,r13
    1002:	call   1007 <botlish_fn_9+0xf7>
			1003: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1007:	mov    rcx,rax
    100a:	mov    QWORD PTR [rsp+0x38],rax
    100f:	test   rax,rcx
    1012:	je     1094 <botlish_fn_9+0x184>
    1018:	mov    rax,QWORD PTR [rsp+0x38]
    101d:	mov    QWORD PTR [rsp+0x20],rax
    1022:	mov    r8d,0x1
    1028:	mov    QWORD PTR [rsp+0x28],0x1
    1031:	mov    QWORD PTR [rsp+0x30],0x1
    103a:	mov    rsi,r15
    103d:	mov    rcx,QWORD PTR [rsp+0x38]
    1042:	mov    rdi,r13
    1045:	mov    rdx,r8
    1048:	call   104d <botlish_fn_9+0x13d>
			1049: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    104d:	test   rax,rax
    1050:	mov    rdx,rax
    1053:	je     1094 <botlish_fn_9+0x184>
    1059:	mov    r8d,0x1
    105f:	mov    rcx,r14
    1062:	mov    r9,r12
    1065:	mov    rsi,QWORD PTR [rsp+0x38]
    106a:	mov    rdi,r13
    106d:	call   1072 <botlish_fn_9+0x162>
			106e: R_X86_64_PLT32	rt_mutarray_copy-0x4
    1072:	test   rax,rax
    1075:	je     1094 <botlish_fn_9+0x184>
    107b:	mov    rdx,rbx
    107e:	mov    rsi,QWORD PTR [rsp+0x38]
    1083:	mov    rdi,r13
    1086:	call   108b <botlish_fn_9+0x17b>
			1087: R_X86_64_PLT32	rt_mutarray_freeze-0x4
    108b:	test   rax,rax
    108e:	jne    10b9 <botlish_fn_9+0x1a9>
    1094:	xor    rax,rax
    1097:	mov    rbx,QWORD PTR [rsp+0x40]
    109c:	mov    r12,QWORD PTR [rsp+0x48]
    10a1:	mov    r13,QWORD PTR [rsp+0x50]
    10a6:	mov    r14,QWORD PTR [rsp+0x58]
    10ab:	mov    r15,QWORD PTR [rsp+0x60]
    10b0:	add    rsp,0x70
    10b4:	mov    rsp,rbp
    10b7:	pop    rbp
    10b8:	ret
    10b9:	mov    rbx,QWORD PTR [rsp+0x40]
    10be:	mov    r12,QWORD PTR [rsp+0x48]
    10c3:	mov    r13,QWORD PTR [rsp+0x50]
    10c8:	mov    r14,QWORD PTR [rsp+0x58]
    10cd:	mov    r15,QWORD PTR [rsp+0x60]
    10d2:	add    rsp,0x70
    10d6:	mov    rsp,rbp
    10d9:	pop    rbp
    10da:	ret
    10db:	add    BYTE PTR [rax],al
    10dd:	add    BYTE PTR [rax],al
    10df:	add    BYTE PTR [rax+0x0],al
    10e5:	add    BYTE PTR [rax],al
	...

00000000000010e8 <botlish_entry_9: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    10e8:	push   rbp
    10e9:	mov    rbp,rsp
    10ec:	mov    rsi,QWORD PTR [rdx]
    10ef:	mov    r8,QWORD PTR [rdx+0x8]
    10f3:	mov    rcx,QWORD PTR [rdx+0x10]
    10f7:	mov    rdx,r8
    10fa:	call   10ff <botlish_entry_9+0x17>
			10fb: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    10ff:	mov    rsp,rbp
    1102:	pop    rbp
    1103:	ret
    1104:	add    BYTE PTR [rax],al
	...

0000000000001108 <botlish_fn_10: peek<str, int>>:
    1108:	push   rbp
    1109:	mov    rbp,rsp
    110c:	sub    rsp,0x40
    1110:	mov    QWORD PTR [rsp+0x20],rbx
    1115:	mov    QWORD PTR [rsp+0x28],r12
    111a:	mov    QWORD PTR [rsp+0x30],r13
    111f:	mov    r13,rdi
    1122:	mov    QWORD PTR [rsp],rsi
    1126:	mov    r12,rsi
    1129:	mov    QWORD PTR [rsp+0x8],rdx
    112e:	mov    rbx,rdx
    1131:	mov    rsi,r12
    1134:	mov    rdi,r13
    1137:	call   113c <botlish_fn_10+0x34>
			1138: R_X86_64_PLT32	rt_str_len-0x4
    113c:	mov    rcx,rbx
    113f:	and    rcx,rax
    1142:	mov    rdx,rax
    1145:	test   rcx,0x1
    114c:	jne    1172 <botlish_fn_10+0x6a>
    1152:	mov    rsi,rbx
    1155:	mov    rdi,r13
    1158:	call   115d <botlish_fn_10+0x55>
			1159: R_X86_64_PLT32	rt_int_cmp-0x4
    115d:	mov    ecx,0x2
    1162:	test   rax,rax
    1165:	cmovge rcx,QWORD PTR [rip+0xd3]        # 1240 <botlish_fn_10+0x138>
    116d:	jmp    1182 <botlish_fn_10+0x7a>
    1172:	mov    ecx,0x2
    1177:	cmp    rbx,rdx
    117a:	cmovge rcx,QWORD PTR [rip+0xbe]        # 1240 <botlish_fn_10+0x138>
    1182:	cmp    rcx,0x6
    1186:	je     1216 <botlish_fn_10+0x10e>
    118c:	mov    QWORD PTR [rsp+0x10],0x3
    1195:	test   rbx,0x1
    119c:	je     11b4 <botlish_fn_10+0xac>
    11a2:	mov    rcx,rbx
    11a5:	add    rcx,0x2
    11a9:	seto   al
    11ac:	test   al,al
    11ae:	je     11c7 <botlish_fn_10+0xbf>
    11b4:	mov    edx,0x3
    11b9:	mov    rsi,rbx
    11bc:	mov    rdi,r13
    11bf:	call   11c4 <botlish_fn_10+0xbc>
			11c0: R_X86_64_PLT32	rt_int_add-0x4
    11c4:	mov    rcx,rax
    11c7:	mov    QWORD PTR [rsp+0x10],rcx
    11cc:	mov    rdx,rbx
    11cf:	mov    rsi,r12
    11d2:	mov    rdi,r13
    11d5:	call   11da <botlish_fn_10+0xd2>
			11d6: R_X86_64_PLT32	rt_substr-0x4
    11da:	test   rax,rax
    11dd:	jne    11fe <botlish_fn_10+0xf6>
    11e3:	xor    rax,rax
    11e6:	mov    rbx,QWORD PTR [rsp+0x20]
    11eb:	mov    r12,QWORD PTR [rsp+0x28]
    11f0:	mov    r13,QWORD PTR [rsp+0x30]
    11f5:	add    rsp,0x40
    11f9:	mov    rsp,rbp
    11fc:	pop    rbp
    11fd:	ret
    11fe:	mov    rbx,QWORD PTR [rsp+0x20]
    1203:	mov    r12,QWORD PTR [rsp+0x28]
    1208:	mov    r13,QWORD PTR [rsp+0x30]
    120d:	add    rsp,0x40
    1211:	mov    rsp,rbp
    1214:	pop    rbp
    1215:	ret
    1216:	mov    rdi,r13
    1219:	mov    rax,QWORD PTR [rdi+0x10]
    121d:	mov    rax,QWORD PTR [rax+0x10]
    1221:	mov    rbx,QWORD PTR [rsp+0x20]
    1226:	mov    r12,QWORD PTR [rsp+0x28]
    122b:	mov    r13,QWORD PTR [rsp+0x30]
    1230:	add    rsp,0x40
    1234:	mov    rsp,rbp
    1237:	pop    rbp
    1238:	ret
    1239:	add    BYTE PTR [rax],al
    123b:	add    BYTE PTR [rax],al
    123d:	add    BYTE PTR [rax],al
    123f:	add    BYTE PTR [rsi],al
    1241:	add    BYTE PTR [rax],al
    1243:	add    BYTE PTR [rax],al
    1245:	add    BYTE PTR [rax],al
	...

0000000000001248 <botlish_entry_10: peek<str, int>>:
    1248:	push   rbp
    1249:	mov    rbp,rsp
    124c:	mov    rsi,QWORD PTR [rdx]
    124f:	mov    rdx,QWORD PTR [rdx+0x8]
    1253:	call   1258 <botlish_entry_10+0x10>
			1254: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    1258:	mov    rsp,rbp
    125b:	pop    rbp
    125c:	ret
    125d:	add    BYTE PTR [rax],al
	...

0000000000001260 <botlish_fn_11: peek<str, int>>:
    1260:	push   rbp
    1261:	mov    rbp,rsp
    1264:	sub    rsp,0x50
    1268:	mov    QWORD PTR [rsp+0x20],rbx
    126d:	mov    QWORD PTR [rsp+0x28],r12
    1272:	mov    QWORD PTR [rsp+0x30],r13
    1277:	mov    QWORD PTR [rsp+0x38],r14
    127c:	mov    QWORD PTR [rsp+0x40],r15
    1281:	mov    r12,rcx
    1284:	mov    r14,rdi
    1287:	mov    QWORD PTR [rsp],rsi
    128b:	mov    r13,rsi
    128e:	mov    QWORD PTR [rsp+0x8],rdx
    1293:	mov    rbx,rdx
    1296:	mov    rsi,r13
    1299:	mov    rdi,r14
    129c:	call   12a1 <botlish_fn_11+0x41>
			129d: R_X86_64_PLT32	rt_str_len-0x4
    12a1:	mov    rcx,rbx
    12a4:	and    rcx,rax
    12a7:	mov    rdx,rax
    12aa:	test   rcx,0x1
    12b1:	jne    12d7 <botlish_fn_11+0x77>
    12b7:	mov    rsi,rbx
    12ba:	mov    rdi,r14
    12bd:	call   12c2 <botlish_fn_11+0x62>
			12be: R_X86_64_PLT32	rt_int_cmp-0x4
    12c2:	mov    ecx,0x2
    12c7:	test   rax,rax
    12ca:	cmovge rcx,QWORD PTR [rip+0x11e]        # 13f0 <botlish_fn_11+0x190>
    12d2:	jmp    12e7 <botlish_fn_11+0x87>
    12d7:	mov    ecx,0x2
    12dc:	cmp    rbx,rdx
    12df:	cmovge rcx,QWORD PTR [rip+0x109]        # 13f0 <botlish_fn_11+0x190>
    12e7:	cmp    rcx,0x6
    12eb:	je     13ab <botlish_fn_11+0x14b>
    12f1:	mov    QWORD PTR [rsp+0x10],0x3
    12fa:	test   rbx,0x1
    1301:	je     1324 <botlish_fn_11+0xc4>
    1307:	mov    rax,rbx
    130a:	add    rax,0x2
    130e:	seto   cl
    1311:	test   cl,cl
    1313:	jne    1324 <botlish_fn_11+0xc4>
    1319:	mov    rdi,r14
    131c:	mov    r15,rax
    131f:	jmp    133a <botlish_fn_11+0xda>
    1324:	mov    edx,0x3
    1329:	mov    rsi,rbx
    132c:	mov    rdi,r14
    132f:	call   1334 <botlish_fn_11+0xd4>
			1330: R_X86_64_PLT32	rt_int_add-0x4
    1334:	mov    r15,rax
    1337:	mov    rdi,r14
    133a:	mov    rdi,r14
    133d:	mov    rcx,r15
    1340:	mov    rdx,rbx
    1343:	mov    rsi,r13
    1346:	call   134b <botlish_fn_11+0xeb>
			1347: R_X86_64_PLT32	rt_str_region_check-0x4
    134b:	test   rax,rax
    134e:	jne    1379 <botlish_fn_11+0x119>
    1354:	xor    rax,rax
    1357:	mov    rbx,QWORD PTR [rsp+0x20]
    135c:	mov    r12,QWORD PTR [rsp+0x28]
    1361:	mov    r13,QWORD PTR [rsp+0x30]
    1366:	mov    r14,QWORD PTR [rsp+0x38]
    136b:	mov    r15,QWORD PTR [rsp+0x40]
    1370:	add    rsp,0x50
    1374:	mov    rsp,rbp
    1377:	pop    rbp
    1378:	ret
    1379:	mov    rcx,r12
    137c:	mov    QWORD PTR [rcx],rbx
    137f:	mov    rax,r15
    1382:	mov    QWORD PTR [rcx+0x8],rax
    1386:	mov    rax,r13
    1389:	mov    rbx,QWORD PTR [rsp+0x20]
    138e:	mov    r12,QWORD PTR [rsp+0x28]
    1393:	mov    r13,QWORD PTR [rsp+0x30]
    1398:	mov    r14,QWORD PTR [rsp+0x38]
    139d:	mov    r15,QWORD PTR [rsp+0x40]
    13a2:	add    rsp,0x50
    13a6:	mov    rsp,rbp
    13a9:	pop    rbp
    13aa:	ret
    13ab:	mov    rcx,r12
    13ae:	mov    rdi,r14
    13b1:	mov    rax,QWORD PTR [rdi+0x10]
    13b5:	mov    rax,QWORD PTR [rax+0x10]
    13b9:	mov    QWORD PTR [rcx],0x1
    13c0:	mov    QWORD PTR [rcx+0x8],0x1
    13c8:	mov    rbx,QWORD PTR [rsp+0x20]
    13cd:	mov    r12,QWORD PTR [rsp+0x28]
    13d2:	mov    r13,QWORD PTR [rsp+0x30]
    13d7:	mov    r14,QWORD PTR [rsp+0x38]
    13dc:	mov    r15,QWORD PTR [rsp+0x40]
    13e1:	add    rsp,0x50
    13e5:	mov    rsp,rbp
    13e8:	pop    rbp
    13e9:	ret
    13ea:	add    BYTE PTR [rax],al
    13ec:	add    BYTE PTR [rax],al
    13ee:	add    BYTE PTR [rax],al
    13f0:	(bad)
    13f1:	add    BYTE PTR [rax],al
    13f3:	add    BYTE PTR [rax],al
    13f5:	add    BYTE PTR [rax],al
	...

00000000000013f8 <botlish_entry_11: peek<str, int>>:
    13f8:	push   rbp
    13f9:	mov    rbp,rsp
    13fc:	ud2

00000000000013fe <botlish_fn_12: scan_unquoted<str, int, int>>:
    13fe:	push   rbp
    13ff:	mov    rbp,rsp
    1402:	sub    rsp,0x80
    1409:	mov    QWORD PTR [rsp+0x50],rbx
    140e:	mov    QWORD PTR [rsp+0x58],r12
    1413:	mov    QWORD PTR [rsp+0x60],r13
    1418:	mov    QWORD PTR [rsp+0x68],r14
    141d:	mov    QWORD PTR [rsp+0x70],r15
    1422:	mov    QWORD PTR [rsp+0x30],rdi
    1427:	mov    QWORD PTR [rsp+0x18],0x0
    1430:	mov    QWORD PTR [rsp],rsi
    1434:	mov    r15,rsi
    1437:	mov    QWORD PTR [rsp+0x8],rdx
    143c:	mov    r14,rdx
    143f:	mov    QWORD PTR [rsp+0x10],rcx
    1444:	lea    r13,[rsp+0x20]
    1449:	mov    QWORD PTR [rsp+0x38],rcx
    144e:	mov    rcx,r13
    1451:	mov    rdx,QWORD PTR [rsp+0x38]
    1456:	mov    rsi,r15
    1459:	mov    rdi,QWORD PTR [rsp+0x30]
    145e:	call   1463 <botlish_fn_12+0x65>
			145f: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1463:	mov    rsi,rax
    1466:	mov    QWORD PTR [rsp+0x40],rax
    146b:	test   rax,rsi
    146e:	je     15c8 <botlish_fn_12+0x1ca>
    1474:	mov    rbx,QWORD PTR [rsp+0x20]
    1479:	mov    r12,QWORD PTR [rsp+0x28]
    147e:	mov    rdi,QWORD PTR [rsp+0x30]
    1483:	mov    rcx,QWORD PTR [rdi+0x10]
    1487:	mov    r8,QWORD PTR [rcx+0x10]
    148b:	mov    rcx,r12
    148e:	mov    rdx,rbx
    1491:	mov    rsi,QWORD PTR [rsp+0x40]
    1496:	call   149b <botlish_fn_12+0x9d>
			1497: R_X86_64_PLT32	rt_str_region_eq-0x4
    149b:	cmp    rax,0x6
    149f:	je     14e0 <botlish_fn_12+0xe2>
    14a5:	mov    rdi,QWORD PTR [rsp+0x30]
    14aa:	mov    rax,QWORD PTR [rdi+0x10]
    14ae:	mov    r8,QWORD PTR [rax+0x18]
    14b2:	mov    rcx,r12
    14b5:	mov    rdx,rbx
    14b8:	mov    rsi,QWORD PTR [rsp+0x40]
    14bd:	call   14c2 <botlish_fn_12+0xc4>
			14be: R_X86_64_PLT32	rt_str_region_eq-0x4
    14c2:	cmp    rax,0x6
    14c6:	je     14d6 <botlish_fn_12+0xd8>
    14cc:	mov    eax,0x2
    14d1:	jmp    14e5 <botlish_fn_12+0xe7>
    14d6:	mov    eax,0x6
    14db:	jmp    14e5 <botlish_fn_12+0xe7>
    14e0:	mov    eax,0x6
    14e5:	cmp    rax,0x6
    14e9:	je     152a <botlish_fn_12+0x12c>
    14ef:	mov    rdi,QWORD PTR [rsp+0x30]
    14f4:	mov    rax,QWORD PTR [rdi+0x10]
    14f8:	mov    r8,QWORD PTR [rax+0x20]
    14fc:	mov    rcx,r12
    14ff:	mov    rdx,rbx
    1502:	mov    rsi,QWORD PTR [rsp+0x40]
    1507:	call   150c <botlish_fn_12+0x10e>
			1508: R_X86_64_PLT32	rt_str_region_eq-0x4
    150c:	cmp    rax,0x6
    1510:	je     1520 <botlish_fn_12+0x122>
    1516:	mov    eax,0x2
    151b:	jmp    152f <botlish_fn_12+0x131>
    1520:	mov    eax,0x6
    1525:	jmp    152f <botlish_fn_12+0x131>
    152a:	mov    eax,0x6
    152f:	cmp    rax,0x6
    1533:	je     15aa <botlish_fn_12+0x1ac>
    1539:	mov    QWORD PTR [rsp+0x18],0x3
    1542:	mov    rsi,QWORD PTR [rsp+0x38]
    1547:	test   rsi,0x1
    154e:	je     1575 <botlish_fn_12+0x177>
    1554:	mov    rsi,QWORD PTR [rsp+0x38]
    1559:	mov    rax,rsi
    155c:	add    rax,0x2
    1560:	seto   sil
    1564:	test   sil,sil
    1567:	jne    1575 <botlish_fn_12+0x177>
    156d:	mov    rsi,r15
    1570:	jmp    158c <botlish_fn_12+0x18e>
    1575:	mov    edx,0x3
    157a:	mov    rsi,QWORD PTR [rsp+0x38]
    157f:	mov    rdi,QWORD PTR [rsp+0x30]
    1584:	call   1589 <botlish_fn_12+0x18b>
			1585: R_X86_64_PLT32	rt_int_add-0x4
    1589:	mov    rsi,r15
    158c:	mov    QWORD PTR [rsp],rsi
    1590:	mov    rdx,r14
    1593:	mov    QWORD PTR [rsp+0x8],rdx
    1598:	mov    QWORD PTR [rsp+0x10],rax
    159d:	mov    r15,rsi
    15a0:	mov    QWORD PTR [rsp+0x38],rax
    15a5:	jmp    144e <botlish_fn_12+0x50>
    15aa:	mov    rdx,r14
    15ad:	mov    rsi,r15
    15b0:	mov    rdi,QWORD PTR [rsp+0x30]
    15b5:	mov    rcx,QWORD PTR [rsp+0x38]
    15ba:	call   15bf <botlish_fn_12+0x1c1>
			15bb: R_X86_64_PLT32	rt_substr-0x4
    15bf:	test   rax,rax
    15c2:	jne    15f3 <botlish_fn_12+0x1f5>
    15c8:	xor    rdx,rdx
    15cb:	mov    rax,rdx
    15ce:	mov    rbx,QWORD PTR [rsp+0x50]
    15d3:	mov    r12,QWORD PTR [rsp+0x58]
    15d8:	mov    r13,QWORD PTR [rsp+0x60]
    15dd:	mov    r14,QWORD PTR [rsp+0x68]
    15e2:	mov    r15,QWORD PTR [rsp+0x70]
    15e7:	add    rsp,0x80
    15ee:	mov    rsp,rbp
    15f1:	pop    rbp
    15f2:	ret
    15f3:	mov    rdx,QWORD PTR [rsp+0x38]
    15f8:	mov    rbx,QWORD PTR [rsp+0x50]
    15fd:	mov    r12,QWORD PTR [rsp+0x58]
    1602:	mov    r13,QWORD PTR [rsp+0x60]
    1607:	mov    r14,QWORD PTR [rsp+0x68]
    160c:	mov    r15,QWORD PTR [rsp+0x70]
    1611:	add    rsp,0x80
    1618:	mov    rsp,rbp
    161b:	pop    rbp
    161c:	ret

000000000000161d <botlish_entry_12: scan_unquoted<str, int, int>>:
    161d:	push   rbp
    161e:	mov    rbp,rsp
    1621:	ud2

0000000000001623 <botlish_fn_13: scan_quoted<str, int, str>>:
    1623:	push   rbp
    1624:	mov    rbp,rsp
    1627:	sub    rsp,0x70
    162b:	mov    QWORD PTR [rsp+0x40],rbx
    1630:	mov    QWORD PTR [rsp+0x48],r12
    1635:	mov    QWORD PTR [rsp+0x50],r13
    163a:	mov    QWORD PTR [rsp+0x58],r14
    163f:	mov    QWORD PTR [rsp+0x60],r15
    1644:	mov    r13,rdi
    1647:	mov    QWORD PTR [rsp+0x18],0x0
    1650:	mov    QWORD PTR [rsp+0x20],0x0
    1659:	mov    QWORD PTR [rsp],rsi
    165d:	mov    QWORD PTR [rsp+0x8],rdx
    1662:	mov    QWORD PTR [rsp+0x10],rcx
    1667:	lea    r12,[rsp+0x28]
    166c:	mov    rbx,rsi
    166f:	mov    r14,rdx
    1672:	mov    r15,rcx
    1675:	mov    rdx,r14
    1678:	mov    rsi,rbx
    167b:	mov    rdi,r13
    167e:	call   1683 <botlish_fn_13+0x60>
			167f: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    1683:	test   rax,rax
    1686:	je     18a2 <botlish_fn_13+0x27f>
    168c:	mov    QWORD PTR [rsp+0x18],rax
    1691:	mov    rdi,r13
    1694:	mov    QWORD PTR [rsp+0x38],rax
    1699:	mov    rcx,QWORD PTR [rdi+0x10]
    169d:	mov    rsi,QWORD PTR [rcx+0x28]
    16a1:	mov    edx,0x1
    16a6:	mov    ecx,0x3
    16ab:	mov    r8,QWORD PTR [rsp+0x38]
    16b0:	call   16b5 <botlish_fn_13+0x92>
			16b1: R_X86_64_PLT32	rt_str_region_eq-0x4
    16b5:	cmp    rax,0x6
    16b9:	je     173c <botlish_fn_13+0x119>
    16bf:	mov    QWORD PTR [rsp+0x20],0x3
    16c8:	mov    rsi,r14
    16cb:	test   rsi,0x1
    16d2:	je     16f2 <botlish_fn_13+0xcf>
    16d8:	mov    rax,rsi
    16db:	add    rax,0x2
    16df:	seto   cl
    16e2:	test   cl,cl
    16e4:	jne    16f2 <botlish_fn_13+0xcf>
    16ea:	mov    rsi,rax
    16ed:	jmp    1702 <botlish_fn_13+0xdf>
    16f2:	mov    edx,0x3
    16f7:	mov    rdi,r13
    16fa:	call   16ff <botlish_fn_13+0xdc>
			16fb: R_X86_64_PLT32	rt_int_add-0x4
    16ff:	mov    rsi,rax
    1702:	mov    QWORD PTR [rsp+0x8],rsi
    1707:	mov    r14,rsi
    170a:	mov    rsi,r15
    170d:	mov    rdx,QWORD PTR [rsp+0x38]
    1712:	mov    rdi,r13
    1715:	call   171a <botlish_fn_13+0xf7>
			1716: R_X86_64_PLT32	rt_str_cat-0x4
    171a:	test   rax,rax
    171d:	je     18a2 <botlish_fn_13+0x27f>
    1723:	mov    QWORD PTR [rsp],rbx
    1727:	mov    rsi,r14
    172a:	mov    QWORD PTR [rsp+0x8],rsi
    172f:	mov    QWORD PTR [rsp+0x10],rax
    1734:	mov    r15,rax
    1737:	jmp    1675 <botlish_fn_13+0x52>
    173c:	mov    QWORD PTR [rsp+0x18],0x3
    1745:	mov    rsi,r14
    1748:	test   rsi,0x1
    174f:	je     176a <botlish_fn_13+0x147>
    1755:	mov    rsi,r14
    1758:	mov    rdx,rsi
    175b:	add    rdx,0x2
    175f:	seto   al
    1762:	test   al,al
    1764:	je     177d <botlish_fn_13+0x15a>
    176a:	mov    edx,0x3
    176f:	mov    rsi,r14
    1772:	mov    rdi,r13
    1775:	call   177a <botlish_fn_13+0x157>
			1776: R_X86_64_PLT32	rt_int_add-0x4
    177a:	mov    rdx,rax
    177d:	mov    QWORD PTR [rsp+0x18],rdx
    1782:	mov    rcx,r12
    1785:	mov    rsi,rbx
    1788:	mov    rdi,r13
    178b:	call   1790 <botlish_fn_13+0x16d>
			178c: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1790:	test   rax,rax
    1793:	mov    rsi,rax
    1796:	je     18a2 <botlish_fn_13+0x27f>
    179c:	mov    rdx,QWORD PTR [rsp+0x28]
    17a1:	mov    rcx,QWORD PTR [rsp+0x30]
    17a6:	mov    rdi,r13
    17a9:	mov    rax,QWORD PTR [rdi+0x10]
    17ad:	mov    r8,QWORD PTR [rax+0x28]
    17b1:	call   17b6 <botlish_fn_13+0x193>
			17b2: R_X86_64_PLT32	rt_str_region_eq-0x4
    17b6:	cmp    rax,0x6
    17ba:	je     182d <botlish_fn_13+0x20a>
    17c0:	mov    QWORD PTR [rsp],0x3
    17c8:	mov    rsi,r14
    17cb:	test   rsi,0x1
    17d2:	je     17f5 <botlish_fn_13+0x1d2>
    17d8:	mov    rsi,r14
    17db:	mov    rdx,rsi
    17de:	add    rdx,0x2
    17e2:	seto   al
    17e5:	test   al,al
    17e7:	jne    17f5 <botlish_fn_13+0x1d2>
    17ed:	mov    rax,r15
    17f0:	jmp    180b <botlish_fn_13+0x1e8>
    17f5:	mov    edx,0x3
    17fa:	mov    rsi,r14
    17fd:	mov    rdi,r13
    1800:	call   1805 <botlish_fn_13+0x1e2>
			1801: R_X86_64_PLT32	rt_int_add-0x4
    1805:	mov    rdx,rax
    1808:	mov    rax,r15
    180b:	mov    rbx,QWORD PTR [rsp+0x40]
    1810:	mov    r12,QWORD PTR [rsp+0x48]
    1815:	mov    r13,QWORD PTR [rsp+0x50]
    181a:	mov    r14,QWORD PTR [rsp+0x58]
    181f:	mov    r15,QWORD PTR [rsp+0x60]
    1824:	add    rsp,0x70
    1828:	mov    rsp,rbp
    182b:	pop    rbp
    182c:	ret
    182d:	mov    QWORD PTR [rsp+0x18],0x5
    1836:	mov    rsi,r14
    1839:	test   rsi,0x1
    1840:	je     1866 <botlish_fn_13+0x243>
    1846:	mov    rsi,r14
    1849:	mov    rax,rsi
    184c:	add    rax,0x4
    1850:	seto   cl
    1853:	test   cl,cl
    1855:	jne    1866 <botlish_fn_13+0x243>
    185b:	mov    rsi,rax
    185e:	mov    r14,rax
    1861:	jmp    187c <botlish_fn_13+0x259>
    1866:	mov    edx,0x5
    186b:	mov    rsi,r14
    186e:	mov    rdi,r13
    1871:	call   1876 <botlish_fn_13+0x253>
			1872: R_X86_64_PLT32	rt_int_add-0x4
    1876:	mov    rsi,rax
    1879:	mov    r14,rax
    187c:	mov    QWORD PTR [rsp+0x8],rsi
    1881:	mov    rdi,r13
    1884:	mov    rax,QWORD PTR [rdi+0x10]
    1888:	mov    rdx,QWORD PTR [rax+0x28]
    188c:	mov    QWORD PTR [rsp+0x18],rdx
    1891:	mov    rsi,r15
    1894:	call   1899 <botlish_fn_13+0x276>
			1895: R_X86_64_PLT32	rt_str_cat-0x4
    1899:	test   rax,rax
    189c:	jne    18ca <botlish_fn_13+0x2a7>
    18a2:	xor    rdx,rdx
    18a5:	mov    rax,rdx
    18a8:	mov    rbx,QWORD PTR [rsp+0x40]
    18ad:	mov    r12,QWORD PTR [rsp+0x48]
    18b2:	mov    r13,QWORD PTR [rsp+0x50]
    18b7:	mov    r14,QWORD PTR [rsp+0x58]
    18bc:	mov    r15,QWORD PTR [rsp+0x60]
    18c1:	add    rsp,0x70
    18c5:	mov    rsp,rbp
    18c8:	pop    rbp
    18c9:	ret
    18ca:	mov    QWORD PTR [rsp],rbx
    18ce:	mov    rsi,r14
    18d1:	mov    QWORD PTR [rsp+0x8],rsi
    18d6:	mov    QWORD PTR [rsp+0x10],rax
    18db:	mov    r15,rax
    18de:	jmp    1675 <botlish_fn_13+0x52>

00000000000018e3 <botlish_entry_13: scan_quoted<str, int, str>>:
    18e3:	push   rbp
    18e4:	mov    rbp,rsp
    18e7:	ud2

00000000000018e9 <botlish_fn_14: scan_field<str, int>>:
    18e9:	push   rbp
    18ea:	mov    rbp,rsp
    18ed:	sub    rsp,0x50
    18f1:	mov    QWORD PTR [rsp+0x30],rbx
    18f6:	mov    QWORD PTR [rsp+0x38],r12
    18fb:	mov    QWORD PTR [rsp+0x40],r13
    1900:	mov    r12,rdi
    1903:	mov    r13,rdx
    1906:	mov    QWORD PTR [rsp+0x10],0x0
    190f:	mov    QWORD PTR [rsp],rsi
    1913:	mov    rbx,rsi
    1916:	mov    QWORD PTR [rsp+0x8],rdx
    191b:	lea    rcx,[rsp+0x18]
    1920:	mov    rdx,r13
    1923:	mov    rsi,rbx
    1926:	mov    rdi,r12
    1929:	call   192e <botlish_fn_14+0x45>
			192a: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    192e:	test   rax,rax
    1931:	mov    rsi,rax
    1934:	je     19ff <botlish_fn_14+0x116>
    193a:	mov    rdx,QWORD PTR [rsp+0x18]
    193f:	mov    rcx,QWORD PTR [rsp+0x20]
    1944:	mov    rdi,r12
    1947:	mov    rax,QWORD PTR [rdi+0x10]
    194b:	mov    r8,QWORD PTR [rax+0x28]
    194f:	call   1954 <botlish_fn_14+0x6b>
			1950: R_X86_64_PLT32	rt_str_region_eq-0x4
    1954:	cmp    rax,0x6
    1958:	je     1990 <botlish_fn_14+0xa7>
    195e:	mov    rcx,r13
    1961:	mov    rsi,rbx
    1964:	mov    rdi,r12
    1967:	mov    rdx,rcx
    196a:	call   196f <botlish_fn_14+0x86>
			196b: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_unquoted<str, int, int>
    196f:	test   rax,rax
    1972:	je     19ff <botlish_fn_14+0x116>
    1978:	mov    rbx,QWORD PTR [rsp+0x30]
    197d:	mov    r12,QWORD PTR [rsp+0x38]
    1982:	mov    r13,QWORD PTR [rsp+0x40]
    1987:	add    rsp,0x50
    198b:	mov    rsp,rbp
    198e:	pop    rbp
    198f:	ret
    1990:	mov    rcx,r13
    1993:	mov    QWORD PTR [rsp+0x10],0x3
    199c:	test   rcx,0x1
    19a3:	jne    19b1 <botlish_fn_14+0xc8>
    19a9:	mov    r13,rcx
    19ac:	jmp    19c6 <botlish_fn_14+0xdd>
    19b1:	mov    rdx,rcx
    19b4:	add    rdx,0x2
    19b8:	mov    r13,rcx
    19bb:	seto   al
    19be:	test   al,al
    19c0:	je     19d9 <botlish_fn_14+0xf0>
    19c6:	mov    edx,0x3
    19cb:	mov    rsi,r13
    19ce:	mov    rdi,r12
    19d1:	call   19d6 <botlish_fn_14+0xed>
			19d2: R_X86_64_PLT32	rt_int_add-0x4
    19d6:	mov    rdx,rax
    19d9:	mov    QWORD PTR [rsp+0x8],rdx
    19de:	mov    rdi,r12
    19e1:	mov    rax,QWORD PTR [rdi+0x10]
    19e5:	mov    rcx,QWORD PTR [rax+0x10]
    19e9:	mov    QWORD PTR [rsp+0x10],rcx
    19ee:	mov    rsi,rbx
    19f1:	call   19f6 <botlish_fn_14+0x10d>
			19f2: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_quoted<str, int, str>
    19f6:	test   rax,rax
    19f9:	jne    1a1d <botlish_fn_14+0x134>
    19ff:	xor    rdx,rdx
    1a02:	mov    rax,rdx
    1a05:	mov    rbx,QWORD PTR [rsp+0x30]
    1a0a:	mov    r12,QWORD PTR [rsp+0x38]
    1a0f:	mov    r13,QWORD PTR [rsp+0x40]
    1a14:	add    rsp,0x50
    1a18:	mov    rsp,rbp
    1a1b:	pop    rbp
    1a1c:	ret
    1a1d:	mov    rbx,QWORD PTR [rsp+0x30]
    1a22:	mov    r12,QWORD PTR [rsp+0x38]
    1a27:	mov    r13,QWORD PTR [rsp+0x40]
    1a2c:	add    rsp,0x50
    1a30:	mov    rsp,rbp
    1a33:	pop    rbp
    1a34:	ret

0000000000001a35 <botlish_entry_14: scan_field<str, int>>:
    1a35:	push   rbp
    1a36:	mov    rbp,rsp
    1a39:	ud2

0000000000001a3b <botlish_fn_15: scan_record<str, int, list[list<never>, mutarray, int]>>:
    1a3b:	push   rbp
    1a3c:	mov    rbp,rsp
    1a3f:	sub    rsp,0xa0
    1a46:	mov    QWORD PTR [rsp+0x70],rbx
    1a4b:	mov    QWORD PTR [rsp+0x78],r12
    1a50:	mov    QWORD PTR [rsp+0x80],r13
    1a58:	mov    QWORD PTR [rsp+0x88],r14
    1a60:	mov    QWORD PTR [rsp+0x90],r15
    1a68:	mov    r13,rdi
    1a6b:	mov    QWORD PTR [rsp+0x28],0x0
    1a74:	mov    QWORD PTR [rsp],rsi
    1a78:	mov    r15,rsi
    1a7b:	mov    QWORD PTR [rsp+0x8],rdx
    1a80:	mov    QWORD PTR [rsp+0x10],rcx
    1a85:	mov    QWORD PTR [rsp+0x50],rcx
    1a8a:	mov    QWORD PTR [rsp+0x18],r8
    1a8f:	mov    r12,r8
    1a92:	mov    QWORD PTR [rsp+0x20],r9
    1a97:	mov    rbx,r9
    1a9a:	mov    rsi,r15
    1a9d:	mov    rdi,r13
    1aa0:	call   1aa5 <botlish_fn_15+0x6a>
			1aa1: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1aa5:	test   rax,rax
    1aa8:	je     1cdc <botlish_fn_15+0x2a1>
    1aae:	mov    QWORD PTR [rsp+0x8],rax
    1ab3:	mov    r8,rax
    1ab6:	mov    QWORD PTR [rsp+0x28],rdx
    1abb:	mov    r14,rdx
    1abe:	lea    r9,[rsp+0x30]
    1ac3:	mov    rcx,rbx
    1ac6:	mov    rdx,r12
    1ac9:	mov    rsi,QWORD PTR [rsp+0x50]
    1ace:	mov    rdi,r13
    1ad1:	call   1ad6 <botlish_fn_15+0x9b>
			1ad2: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<list[list<never>, mutarray, int], str>
    1ad6:	test   rax,rax
    1ad9:	je     1cdc <botlish_fn_15+0x2a1>
    1adf:	mov    QWORD PTR [rsp+0x8],rax
    1ae4:	mov    QWORD PTR [rsp+0x68],rax
    1ae9:	mov    rdx,QWORD PTR [rsp+0x30]
    1aee:	mov    QWORD PTR [rsp+0x10],rdx
    1af3:	mov    QWORD PTR [rsp+0x60],rdx
    1af8:	mov    rcx,QWORD PTR [rsp+0x38]
    1afd:	mov    QWORD PTR [rsp+0x18],rcx
    1b02:	mov    QWORD PTR [rsp+0x58],rcx
    1b07:	lea    rcx,[rsp+0x40]
    1b0c:	mov    rdx,r14
    1b0f:	mov    rsi,r15
    1b12:	mov    rdi,r13
    1b15:	call   1b1a <botlish_fn_15+0xdf>
			1b16: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1b1a:	test   rax,rax
    1b1d:	mov    QWORD PTR [rsp+0x50],rax
    1b22:	je     1cdc <botlish_fn_15+0x2a1>
    1b28:	mov    r12,QWORD PTR [rsp+0x40]
    1b2d:	mov    rbx,QWORD PTR [rsp+0x48]
    1b32:	mov    rdi,r13
    1b35:	mov    rcx,QWORD PTR [rdi+0x10]
    1b39:	mov    r8,QWORD PTR [rcx+0x18]
    1b3d:	mov    rcx,rbx
    1b40:	mov    rdx,r12
    1b43:	mov    rsi,QWORD PTR [rsp+0x50]
    1b48:	call   1b4d <botlish_fn_15+0x112>
			1b49: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b4d:	cmp    rax,0x6
    1b51:	je     1c6b <botlish_fn_15+0x230>
    1b57:	mov    rdi,r13
    1b5a:	mov    rax,QWORD PTR [rdi+0x10]
    1b5e:	mov    r8,QWORD PTR [rax+0x20]
    1b62:	mov    rcx,rbx
    1b65:	mov    rdx,r12
    1b68:	mov    rsi,QWORD PTR [rsp+0x50]
    1b6d:	call   1b72 <botlish_fn_15+0x137>
			1b6e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b72:	cmp    rax,0x6
    1b76:	je     1bcd <botlish_fn_15+0x192>
    1b7c:	mov    rcx,QWORD PTR [rsp+0x58]
    1b81:	mov    rdx,QWORD PTR [rsp+0x60]
    1b86:	mov    rsi,QWORD PTR [rsp+0x68]
    1b8b:	mov    rdi,r13
    1b8e:	call   1b93 <botlish_fn_15+0x158>
			1b8f: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1b93:	test   rax,rax
    1b96:	je     1cdc <botlish_fn_15+0x2a1>
    1b9c:	mov    rdx,r14
    1b9f:	mov    rbx,QWORD PTR [rsp+0x70]
    1ba4:	mov    r12,QWORD PTR [rsp+0x78]
    1ba9:	mov    r13,QWORD PTR [rsp+0x80]
    1bb1:	mov    r14,QWORD PTR [rsp+0x88]
    1bb9:	mov    r15,QWORD PTR [rsp+0x90]
    1bc1:	add    rsp,0xa0
    1bc8:	mov    rsp,rbp
    1bcb:	pop    rbp
    1bcc:	ret
    1bcd:	mov    rcx,QWORD PTR [rsp+0x58]
    1bd2:	mov    rdx,QWORD PTR [rsp+0x60]
    1bd7:	mov    rsi,QWORD PTR [rsp+0x68]
    1bdc:	mov    rdi,r13
    1bdf:	call   1be4 <botlish_fn_15+0x1a9>
			1be0: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1be4:	test   rax,rax
    1be7:	je     1cdc <botlish_fn_15+0x2a1>
    1bed:	mov    QWORD PTR [rsp],rax
    1bf1:	mov    rbx,rax
    1bf4:	mov    QWORD PTR [rsp+0x8],0x3
    1bfd:	mov    rdx,r14
    1c00:	test   rdx,0x1
    1c07:	je     1c27 <botlish_fn_15+0x1ec>
    1c0d:	mov    rdx,r14
    1c10:	add    rdx,0x2
    1c14:	seto   al
    1c17:	test   al,al
    1c19:	jne    1c27 <botlish_fn_15+0x1ec>
    1c1f:	mov    rax,rbx
    1c22:	jmp    1c3d <botlish_fn_15+0x202>
    1c27:	mov    edx,0x3
    1c2c:	mov    rsi,r14
    1c2f:	mov    rdi,r13
    1c32:	call   1c37 <botlish_fn_15+0x1fc>
			1c33: R_X86_64_PLT32	rt_int_add-0x4
    1c37:	mov    rdx,rax
    1c3a:	mov    rax,rbx
    1c3d:	mov    rbx,QWORD PTR [rsp+0x70]
    1c42:	mov    r12,QWORD PTR [rsp+0x78]
    1c47:	mov    r13,QWORD PTR [rsp+0x80]
    1c4f:	mov    r14,QWORD PTR [rsp+0x88]
    1c57:	mov    r15,QWORD PTR [rsp+0x90]
    1c5f:	add    rsp,0xa0
    1c66:	mov    rsp,rbp
    1c69:	pop    rbp
    1c6a:	ret
    1c6b:	mov    rsi,r14
    1c6e:	mov    edx,0x3
    1c73:	mov    rcx,rdx
    1c76:	mov    QWORD PTR [rsp+0x20],0x3
    1c7f:	test   rsi,0x1
    1c86:	jne    1c94 <botlish_fn_15+0x259>
    1c8c:	mov    rdx,rcx
    1c8f:	jmp    1ca9 <botlish_fn_15+0x26e>
    1c94:	mov    rdx,rsi
    1c97:	add    rdx,0x2
    1c9b:	seto   al
    1c9e:	test   al,al
    1ca0:	je     1cb4 <botlish_fn_15+0x279>
    1ca6:	mov    rdx,rcx
    1ca9:	mov    rdi,r13
    1cac:	call   1cb1 <botlish_fn_15+0x276>
			1cad: R_X86_64_PLT32	rt_int_add-0x4
    1cb1:	mov    rdx,rax
    1cb4:	mov    QWORD PTR [rsp+0x20],rdx
    1cb9:	mov    rcx,QWORD PTR [rsp+0x68]
    1cbe:	mov    rsi,r15
    1cc1:	mov    rdi,r13
    1cc4:	mov    r8,QWORD PTR [rsp+0x60]
    1cc9:	mov    r9,QWORD PTR [rsp+0x58]
    1cce:	call   1cd3 <botlish_fn_15+0x298>
			1ccf: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<mutarray>, mutarray, int]>
    1cd3:	test   rax,rax
    1cd6:	jne    1d10 <botlish_fn_15+0x2d5>
    1cdc:	xor    rdx,rdx
    1cdf:	mov    rax,rdx
    1ce2:	mov    rbx,QWORD PTR [rsp+0x70]
    1ce7:	mov    r12,QWORD PTR [rsp+0x78]
    1cec:	mov    r13,QWORD PTR [rsp+0x80]
    1cf4:	mov    r14,QWORD PTR [rsp+0x88]
    1cfc:	mov    r15,QWORD PTR [rsp+0x90]
    1d04:	add    rsp,0xa0
    1d0b:	mov    rsp,rbp
    1d0e:	pop    rbp
    1d0f:	ret
    1d10:	mov    rbx,QWORD PTR [rsp+0x70]
    1d15:	mov    r12,QWORD PTR [rsp+0x78]
    1d1a:	mov    r13,QWORD PTR [rsp+0x80]
    1d22:	mov    r14,QWORD PTR [rsp+0x88]
    1d2a:	mov    r15,QWORD PTR [rsp+0x90]
    1d32:	add    rsp,0xa0
    1d39:	mov    rsp,rbp
    1d3c:	pop    rbp
    1d3d:	ret

0000000000001d3e <botlish_entry_15: scan_record<str, int, list[list<never>, mutarray, int]>>:
    1d3e:	push   rbp
    1d3f:	mov    rbp,rsp
    1d42:	ud2

0000000000001d44 <botlish_fn_16: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    1d44:	push   rbp
    1d45:	mov    rbp,rsp
    1d48:	sub    rsp,0xb0
    1d4f:	mov    QWORD PTR [rsp+0x80],rbx
    1d57:	mov    QWORD PTR [rsp+0x88],r12
    1d5f:	mov    QWORD PTR [rsp+0x90],r13
    1d67:	mov    QWORD PTR [rsp+0x98],r14
    1d6f:	mov    QWORD PTR [rsp+0xa0],r15
    1d77:	mov    QWORD PTR [rsp+0x50],rdi
    1d7c:	mov    QWORD PTR [rsp+0x28],0x0
    1d85:	mov    QWORD PTR [rsp],rsi
    1d89:	mov    QWORD PTR [rsp+0x8],rdx
    1d8e:	mov    QWORD PTR [rsp+0x10],rcx
    1d93:	mov    QWORD PTR [rsp+0x18],r8
    1d98:	mov    QWORD PTR [rsp+0x20],r9
    1d9d:	lea    r15,[rsp+0x30]
    1da2:	lea    rbx,[rsp+0x40]
    1da7:	mov    r12,rsi
    1daa:	mov    r13,rcx
    1dad:	mov    QWORD PTR [rsp+0x58],r8
    1db2:	mov    QWORD PTR [rsp+0x60],r9
    1db7:	mov    rsi,r12
    1dba:	mov    rdi,QWORD PTR [rsp+0x50]
    1dbf:	call   1dc4 <botlish_fn_16+0x80>
			1dc0: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1dc4:	mov    QWORD PTR [rsp+0x78],rdx
    1dc9:	test   rax,rax
    1dcc:	je     1f27 <botlish_fn_16+0x1e3>
    1dd2:	mov    QWORD PTR [rsp+0x8],rax
    1dd7:	mov    rdx,QWORD PTR [rsp+0x78]
    1ddc:	mov    r8,rax
    1ddf:	mov    QWORD PTR [rsp+0x28],rdx
    1de4:	mov    rcx,QWORD PTR [rsp+0x60]
    1de9:	mov    rdx,QWORD PTR [rsp+0x58]
    1dee:	mov    rsi,r13
    1df1:	mov    rdi,QWORD PTR [rsp+0x50]
    1df6:	mov    r9,r15
    1df9:	call   1dfe <botlish_fn_16+0xba>
			1dfa: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], str>
    1dfe:	test   rax,rax
    1e01:	je     1f27 <botlish_fn_16+0x1e3>
    1e07:	mov    QWORD PTR [rsp+0x8],rax
    1e0c:	mov    QWORD PTR [rsp+0x70],rax
    1e11:	mov    rdx,QWORD PTR [rsp+0x30]
    1e16:	mov    QWORD PTR [rsp+0x58],rdx
    1e1b:	mov    QWORD PTR [rsp+0x10],rdx
    1e20:	mov    rcx,QWORD PTR [rsp+0x38]
    1e25:	mov    QWORD PTR [rsp+0x18],rcx
    1e2a:	mov    QWORD PTR [rsp+0x60],rcx
    1e2f:	mov    rcx,rbx
    1e32:	mov    rdx,QWORD PTR [rsp+0x78]
    1e37:	mov    rsi,r12
    1e3a:	mov    rdi,QWORD PTR [rsp+0x50]
    1e3f:	call   1e44 <botlish_fn_16+0x100>
			1e40: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1e44:	test   rax,rax
    1e47:	mov    QWORD PTR [rsp+0x68],rax
    1e4c:	je     1f27 <botlish_fn_16+0x1e3>
    1e52:	mov    r13,QWORD PTR [rsp+0x40]
    1e57:	mov    r14,QWORD PTR [rsp+0x48]
    1e5c:	mov    rdi,QWORD PTR [rsp+0x50]
    1e61:	mov    rcx,QWORD PTR [rdi+0x10]
    1e65:	mov    r8,QWORD PTR [rcx+0x18]
    1e69:	mov    rcx,r14
    1e6c:	mov    rdx,r13
    1e6f:	mov    rsi,QWORD PTR [rsp+0x68]
    1e74:	call   1e79 <botlish_fn_16+0x135>
			1e75: R_X86_64_PLT32	rt_str_region_eq-0x4
    1e79:	cmp    rax,0x6
    1e7d:	je     1fed <botlish_fn_16+0x2a9>
    1e83:	mov    rdi,QWORD PTR [rsp+0x50]
    1e88:	mov    rax,QWORD PTR [rdi+0x10]
    1e8c:	mov    r8,QWORD PTR [rax+0x20]
    1e90:	mov    rcx,r14
    1e93:	mov    rdx,r13
    1e96:	mov    rsi,QWORD PTR [rsp+0x68]
    1e9b:	call   1ea0 <botlish_fn_16+0x15c>
			1e9c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1ea0:	cmp    rax,0x6
    1ea4:	je     1f05 <botlish_fn_16+0x1c1>
    1eaa:	mov    rcx,QWORD PTR [rsp+0x60]
    1eaf:	mov    rdx,QWORD PTR [rsp+0x58]
    1eb4:	mov    rsi,QWORD PTR [rsp+0x70]
    1eb9:	mov    rdi,QWORD PTR [rsp+0x50]
    1ebe:	call   1ec3 <botlish_fn_16+0x17f>
			1ebf: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1ec3:	test   rax,rax
    1ec6:	je     1f27 <botlish_fn_16+0x1e3>
    1ecc:	mov    rdx,QWORD PTR [rsp+0x78]
    1ed1:	mov    rbx,QWORD PTR [rsp+0x80]
    1ed9:	mov    r12,QWORD PTR [rsp+0x88]
    1ee1:	mov    r13,QWORD PTR [rsp+0x90]
    1ee9:	mov    r14,QWORD PTR [rsp+0x98]
    1ef1:	mov    r15,QWORD PTR [rsp+0xa0]
    1ef9:	add    rsp,0xb0
    1f00:	mov    rsp,rbp
    1f03:	pop    rbp
    1f04:	ret
    1f05:	mov    rcx,QWORD PTR [rsp+0x60]
    1f0a:	mov    rdx,QWORD PTR [rsp+0x58]
    1f0f:	mov    rsi,QWORD PTR [rsp+0x70]
    1f14:	mov    rdi,QWORD PTR [rsp+0x50]
    1f19:	call   1f1e <botlish_fn_16+0x1da>
			1f1a: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1f1e:	test   rax,rax
    1f21:	jne    1f61 <botlish_fn_16+0x21d>
    1f27:	xor    rdx,rdx
    1f2a:	mov    rax,rdx
    1f2d:	mov    rbx,QWORD PTR [rsp+0x80]
    1f35:	mov    r12,QWORD PTR [rsp+0x88]
    1f3d:	mov    r13,QWORD PTR [rsp+0x90]
    1f45:	mov    r14,QWORD PTR [rsp+0x98]
    1f4d:	mov    r15,QWORD PTR [rsp+0xa0]
    1f55:	add    rsp,0xb0
    1f5c:	mov    rsp,rbp
    1f5f:	pop    rbp
    1f60:	ret
    1f61:	mov    QWORD PTR [rsp],rax
    1f65:	mov    rbx,rax
    1f68:	mov    QWORD PTR [rsp+0x8],0x3
    1f71:	mov    rdx,QWORD PTR [rsp+0x78]
    1f76:	test   rdx,0x1
    1f7d:	je     1f9f <botlish_fn_16+0x25b>
    1f83:	mov    rdx,QWORD PTR [rsp+0x78]
    1f88:	add    rdx,0x2
    1f8c:	seto   al
    1f8f:	test   al,al
    1f91:	jne    1f9f <botlish_fn_16+0x25b>
    1f97:	mov    rax,rbx
    1f9a:	jmp    1fb9 <botlish_fn_16+0x275>
    1f9f:	mov    edx,0x3
    1fa4:	mov    rsi,QWORD PTR [rsp+0x78]
    1fa9:	mov    rdi,QWORD PTR [rsp+0x50]
    1fae:	call   1fb3 <botlish_fn_16+0x26f>
			1faf: R_X86_64_PLT32	rt_int_add-0x4
    1fb3:	mov    rdx,rax
    1fb6:	mov    rax,rbx
    1fb9:	mov    rbx,QWORD PTR [rsp+0x80]
    1fc1:	mov    r12,QWORD PTR [rsp+0x88]
    1fc9:	mov    r13,QWORD PTR [rsp+0x90]
    1fd1:	mov    r14,QWORD PTR [rsp+0x98]
    1fd9:	mov    r15,QWORD PTR [rsp+0xa0]
    1fe1:	add    rsp,0xb0
    1fe8:	mov    rsp,rbp
    1feb:	pop    rbp
    1fec:	ret
    1fed:	mov    rsi,QWORD PTR [rsp+0x78]
    1ff2:	mov    edx,0x3
    1ff7:	mov    r10,rdx
    1ffa:	mov    QWORD PTR [rsp+0x20],0x3
    2003:	test   rsi,0x1
    200a:	jne    2018 <botlish_fn_16+0x2d4>
    2010:	mov    rdx,r10
    2013:	jmp    202d <botlish_fn_16+0x2e9>
    2018:	mov    rdx,rsi
    201b:	add    rdx,0x2
    201f:	seto   al
    2022:	test   al,al
    2024:	je     203a <botlish_fn_16+0x2f6>
    202a:	mov    rdx,r10
    202d:	mov    rdi,QWORD PTR [rsp+0x50]
    2032:	call   2037 <botlish_fn_16+0x2f3>
			2033: R_X86_64_PLT32	rt_int_add-0x4
    2037:	mov    rdx,rax
    203a:	mov    QWORD PTR [rsp],r12
    203e:	mov    QWORD PTR [rsp+0x8],rdx
    2043:	mov    rsi,QWORD PTR [rsp+0x70]
    2048:	mov    QWORD PTR [rsp+0x10],rsi
    204d:	mov    rax,QWORD PTR [rsp+0x58]
    2052:	mov    QWORD PTR [rsp+0x18],rax
    2057:	mov    rcx,QWORD PTR [rsp+0x60]
    205c:	mov    QWORD PTR [rsp+0x20],rcx
    2061:	mov    r13,rsi
    2064:	jmp    1db7 <botlish_fn_16+0x73>

0000000000002069 <botlish_entry_16: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    2069:	push   rbp
    206a:	mov    rbp,rsp
    206d:	ud2

000000000000206f <botlish_fn_17: scan_records<str, int, list[list<never>, mutarray, int]>>:
    206f:	push   rbp
    2070:	mov    rbp,rsp
    2073:	sub    rsp,0xa0
    207a:	mov    QWORD PTR [rsp+0x70],rbx
    207f:	mov    QWORD PTR [rsp+0x78],r12
    2084:	mov    QWORD PTR [rsp+0x80],r13
    208c:	mov    QWORD PTR [rsp+0x88],r14
    2094:	mov    QWORD PTR [rsp+0x90],r15
    209c:	mov    r12,rdi
    209f:	mov    QWORD PTR [rsp+0x28],0x0
    20a8:	mov    QWORD PTR [rsp+0x30],0x0
    20b1:	mov    QWORD PTR [rsp+0x38],0x0
    20ba:	mov    QWORD PTR [rsp],rsi
    20be:	mov    rbx,rsi
    20c1:	mov    QWORD PTR [rsp+0x8],rdx
    20c6:	mov    QWORD PTR [rsp+0x60],rdx
    20cb:	mov    QWORD PTR [rsp+0x10],rcx
    20d0:	mov    r15,rcx
    20d3:	mov    QWORD PTR [rsp+0x18],r8
    20d8:	mov    r14,r8
    20db:	mov    QWORD PTR [rsp+0x20],r9
    20e0:	mov    r13,r9
    20e3:	mov    rsi,rbx
    20e6:	mov    rdi,r12
    20e9:	call   20ee <botlish_fn_17+0x7f>
			20ea: R_X86_64_PLT32	rt_str_len-0x4
    20ee:	mov    rdx,QWORD PTR [rsp+0x60]
    20f3:	mov    rcx,rdx
    20f6:	sar    rcx,1
    20f9:	sar    rax,1
    20fc:	cmp    rcx,rax
    20ff:	jge    21e4 <botlish_fn_17+0x175>
    2105:	lea    rsi,[rsp+0x40]
    210a:	mov    rdi,r12
    210d:	call   2112 <botlish_fn_17+0xa3>
			210e: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2112:	test   rax,rax
    2115:	je     21fe <botlish_fn_17+0x18f>
    211b:	mov    QWORD PTR [rsp+0x28],rax
    2120:	mov    rcx,rax
    2123:	mov    r8,QWORD PTR [rsp+0x40]
    2128:	mov    QWORD PTR [rsp+0x30],r8
    212d:	mov    r9,QWORD PTR [rsp+0x48]
    2132:	mov    QWORD PTR [rsp+0x38],r9
    2137:	mov    rdx,QWORD PTR [rsp+0x60]
    213c:	mov    rsi,rbx
    213f:	mov    rdi,r12
    2142:	call   2147 <botlish_fn_17+0xd8>
			2143: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    2147:	test   rax,rax
    214a:	je     21fe <botlish_fn_17+0x18f>
    2150:	mov    QWORD PTR [rsp+0x8],rax
    2155:	mov    r8,rax
    2158:	mov    QWORD PTR [rsp+0x28],rdx
    215d:	mov    QWORD PTR [rsp+0x60],rdx
    2162:	lea    r9,[rsp+0x50]
    2167:	mov    rcx,r13
    216a:	mov    rdx,r14
    216d:	mov    rsi,r15
    2170:	mov    rdi,r12
    2173:	call   2178 <botlish_fn_17+0x109>
			2174: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[list<never>, mutarray, int], list>
    2178:	test   rax,rax
    217b:	je     21fe <botlish_fn_17+0x18f>
    2181:	mov    QWORD PTR [rsp+0x8],rax
    2186:	mov    rcx,rax
    2189:	mov    r8,QWORD PTR [rsp+0x50]
    218e:	mov    QWORD PTR [rsp+0x10],r8
    2193:	mov    r9,QWORD PTR [rsp+0x58]
    2198:	mov    QWORD PTR [rsp+0x18],r9
    219d:	mov    rdx,QWORD PTR [rsp+0x60]
    21a2:	mov    rsi,rbx
    21a5:	mov    rdi,r12
    21a8:	call   21ad <botlish_fn_17+0x13e>
			21a9: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    21ad:	test   rax,rax
    21b0:	je     21fe <botlish_fn_17+0x18f>
    21b6:	mov    rbx,QWORD PTR [rsp+0x70]
    21bb:	mov    r12,QWORD PTR [rsp+0x78]
    21c0:	mov    r13,QWORD PTR [rsp+0x80]
    21c8:	mov    r14,QWORD PTR [rsp+0x88]
    21d0:	mov    r15,QWORD PTR [rsp+0x90]
    21d8:	add    rsp,0xa0
    21df:	mov    rsp,rbp
    21e2:	pop    rbp
    21e3:	ret
    21e4:	mov    rcx,r13
    21e7:	mov    rdx,r14
    21ea:	mov    rsi,r15
    21ed:	mov    rdi,r12
    21f0:	call   21f5 <botlish_fn_17+0x186>
			21f1: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    21f5:	test   rax,rax
    21f8:	jne    222f <botlish_fn_17+0x1c0>
    21fe:	xor    rax,rax
    2201:	mov    rbx,QWORD PTR [rsp+0x70]
    2206:	mov    r12,QWORD PTR [rsp+0x78]
    220b:	mov    r13,QWORD PTR [rsp+0x80]
    2213:	mov    r14,QWORD PTR [rsp+0x88]
    221b:	mov    r15,QWORD PTR [rsp+0x90]
    2223:	add    rsp,0xa0
    222a:	mov    rsp,rbp
    222d:	pop    rbp
    222e:	ret
    222f:	mov    rbx,QWORD PTR [rsp+0x70]
    2234:	mov    r12,QWORD PTR [rsp+0x78]
    2239:	mov    r13,QWORD PTR [rsp+0x80]
    2241:	mov    r14,QWORD PTR [rsp+0x88]
    2249:	mov    r15,QWORD PTR [rsp+0x90]
    2251:	add    rsp,0xa0
    2258:	mov    rsp,rbp
    225b:	pop    rbp
    225c:	ret

000000000000225d <botlish_entry_17: scan_records<str, int, list[list<never>, mutarray, int]>>:
    225d:	push   rbp
    225e:	mov    rbp,rsp
    2261:	mov    rsi,QWORD PTR [rdx]
    2264:	mov    r10,QWORD PTR [rdx+0x8]
    2268:	mov    rcx,QWORD PTR [rdx+0x10]
    226c:	mov    r8,QWORD PTR [rdx+0x18]
    2270:	mov    r9,QWORD PTR [rdx+0x20]
    2274:	mov    rdx,r10
    2277:	call   227c <botlish_entry_17+0x1f>
			2278: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    227c:	mov    rsp,rbp
    227f:	pop    rbp
    2280:	ret
    2281:	add    BYTE PTR [rax],al
    2283:	add    BYTE PTR [rax],al
    2285:	add    BYTE PTR [rax],al
	...

0000000000002288 <botlish_fn_18: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    2288:	push   rbp
    2289:	mov    rbp,rsp
    228c:	sub    rsp,0xb0
    2293:	mov    QWORD PTR [rsp+0x80],rbx
    229b:	mov    QWORD PTR [rsp+0x88],r12
    22a3:	mov    QWORD PTR [rsp+0x90],r13
    22ab:	mov    QWORD PTR [rsp+0x98],r14
    22b3:	mov    QWORD PTR [rsp+0xa0],r15
    22bb:	mov    r15,rdi
    22be:	mov    QWORD PTR [rsp+0x28],0x0
    22c7:	mov    QWORD PTR [rsp+0x30],0x0
    22d0:	mov    QWORD PTR [rsp+0x38],0x0
    22d9:	mov    QWORD PTR [rsp],rsi
    22dd:	mov    QWORD PTR [rsp+0x8],rdx
    22e2:	mov    r14,rdx
    22e5:	mov    QWORD PTR [rsp+0x10],rcx
    22ea:	mov    QWORD PTR [rsp+0x18],r8
    22ef:	mov    QWORD PTR [rsp+0x20],r9
    22f4:	lea    r13,[rsp+0x40]
    22f9:	lea    rbx,[rsp+0x50]
    22fe:	mov    r12,rsi
    2301:	mov    QWORD PTR [rsp+0x60],rcx
    2306:	mov    QWORD PTR [rsp+0x68],r8
    230b:	mov    QWORD PTR [rsp+0x70],r9
    2310:	mov    rsi,r12
    2313:	mov    rdi,r15
    2316:	call   231b <botlish_fn_18+0x93>
			2317: R_X86_64_PLT32	rt_str_len-0x4
    231b:	mov    rcx,r14
    231e:	and    rcx,rax
    2321:	mov    rdx,rax
    2324:	test   rcx,0x1
    232b:	jne    2351 <botlish_fn_18+0xc9>
    2331:	mov    rsi,r14
    2334:	mov    rdi,r15
    2337:	call   233c <botlish_fn_18+0xb4>
			2338: R_X86_64_PLT32	rt_int_cmp-0x4
    233c:	mov    ecx,0x2
    2341:	test   rax,rax
    2344:	cmovge rcx,QWORD PTR [rip+0x164]        # 24b0 <botlish_fn_18+0x228>
    234c:	jmp    2364 <botlish_fn_18+0xdc>
    2351:	mov    ecx,0x2
    2356:	mov    rdi,r14
    2359:	cmp    rdi,rdx
    235c:	cmovge rcx,QWORD PTR [rip+0x14c]        # 24b0 <botlish_fn_18+0x228>
    2364:	cmp    rcx,0x6
    2368:	je     2421 <botlish_fn_18+0x199>
    236e:	mov    rsi,r13
    2371:	mov    rdi,r15
    2374:	call   2379 <botlish_fn_18+0xf1>
			2375: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2379:	test   rax,rax
    237c:	je     2441 <botlish_fn_18+0x1b9>
    2382:	mov    QWORD PTR [rsp+0x28],rax
    2387:	mov    rcx,rax
    238a:	mov    r8,QWORD PTR [rsp+0x40]
    238f:	mov    QWORD PTR [rsp+0x30],r8
    2394:	mov    r9,QWORD PTR [rsp+0x48]
    2399:	mov    QWORD PTR [rsp+0x38],r9
    239e:	mov    rdx,r14
    23a1:	mov    rsi,r12
    23a4:	mov    rdi,r15
    23a7:	call   23ac <botlish_fn_18+0x124>
			23a8: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    23ac:	test   rax,rax
    23af:	je     2441 <botlish_fn_18+0x1b9>
    23b5:	mov    QWORD PTR [rsp+0x8],rax
    23ba:	mov    r8,rax
    23bd:	mov    QWORD PTR [rsp+0x28],rdx
    23c2:	mov    r14,rdx
    23c5:	mov    rsi,QWORD PTR [rsp+0x60]
    23ca:	mov    rdx,QWORD PTR [rsp+0x68]
    23cf:	mov    rcx,QWORD PTR [rsp+0x70]
    23d4:	mov    rdi,r15
    23d7:	mov    r9,rbx
    23da:	call   23df <botlish_fn_18+0x157>
			23db: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], list>
    23df:	test   rax,rax
    23e2:	je     2441 <botlish_fn_18+0x1b9>
    23e8:	mov    rdx,QWORD PTR [rsp+0x50]
    23ed:	mov    rcx,QWORD PTR [rsp+0x58]
    23f2:	mov    QWORD PTR [rsp],r12
    23f6:	mov    rsi,r14
    23f9:	mov    QWORD PTR [rsp+0x8],rsi
    23fe:	mov    QWORD PTR [rsp+0x10],rax
    2403:	mov    QWORD PTR [rsp+0x18],rdx
    2408:	mov    QWORD PTR [rsp+0x20],rcx
    240d:	mov    QWORD PTR [rsp+0x60],rax
    2412:	mov    QWORD PTR [rsp+0x68],rdx
    2417:	mov    QWORD PTR [rsp+0x70],rcx
    241c:	jmp    2310 <botlish_fn_18+0x88>
    2421:	mov    rcx,QWORD PTR [rsp+0x70]
    2426:	mov    rdx,QWORD PTR [rsp+0x68]
    242b:	mov    rsi,QWORD PTR [rsp+0x60]
    2430:	mov    rdi,r15
    2433:	call   2438 <botlish_fn_18+0x1b0>
			2434: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2438:	test   rax,rax
    243b:	jne    2478 <botlish_fn_18+0x1f0>
    2441:	xor    rax,rax
    2444:	mov    rbx,QWORD PTR [rsp+0x80]
    244c:	mov    r12,QWORD PTR [rsp+0x88]
    2454:	mov    r13,QWORD PTR [rsp+0x90]
    245c:	mov    r14,QWORD PTR [rsp+0x98]
    2464:	mov    r15,QWORD PTR [rsp+0xa0]
    246c:	add    rsp,0xb0
    2473:	mov    rsp,rbp
    2476:	pop    rbp
    2477:	ret
    2478:	mov    rbx,QWORD PTR [rsp+0x80]
    2480:	mov    r12,QWORD PTR [rsp+0x88]
    2488:	mov    r13,QWORD PTR [rsp+0x90]
    2490:	mov    r14,QWORD PTR [rsp+0x98]
    2498:	mov    r15,QWORD PTR [rsp+0xa0]
    24a0:	add    rsp,0xb0
    24a7:	mov    rsp,rbp
    24aa:	pop    rbp
    24ab:	ret
    24ac:	add    BYTE PTR [rax],al
    24ae:	add    BYTE PTR [rax],al
    24b0:	(bad)
    24b1:	add    BYTE PTR [rax],al
    24b3:	add    BYTE PTR [rax],al
    24b5:	add    BYTE PTR [rax],al
	...

00000000000024b8 <botlish_entry_18: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    24b8:	push   rbp
    24b9:	mov    rbp,rsp
    24bc:	mov    rsi,QWORD PTR [rdx]
    24bf:	mov    r10,QWORD PTR [rdx+0x8]
    24c3:	mov    rcx,QWORD PTR [rdx+0x10]
    24c7:	mov    r8,QWORD PTR [rdx+0x18]
    24cb:	mov    r9,QWORD PTR [rdx+0x20]
    24cf:	mov    rdx,r10
    24d2:	call   24d7 <botlish_entry_18+0x1f>
			24d3: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    24d7:	mov    rsp,rbp
    24da:	pop    rbp
    24db:	ret

00000000000024dc <botlish_fn_19: csv_parse<str>>:
    24dc:	push   rbp
    24dd:	mov    rbp,rsp
    24e0:	sub    rsp,0x50
    24e4:	mov    QWORD PTR [rsp+0x40],r12
    24e9:	mov    QWORD PTR [rsp+0x48],r13
    24ee:	mov    r13,rdi
    24f1:	mov    QWORD PTR [rsp+0x10],0x0
    24fa:	mov    QWORD PTR [rsp+0x18],0x0
    2503:	mov    QWORD PTR [rsp+0x20],0x0
    250c:	mov    QWORD PTR [rsp],rsi
    2510:	mov    r12,rsi
    2513:	mov    QWORD PTR [rsp+0x8],0x1
    251c:	lea    rsi,[rsp+0x28]
    2521:	mov    rdi,r13
    2524:	call   2529 <botlish_fn_19+0x4d>
			2525: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2529:	test   rax,rax
    252c:	je     2567 <botlish_fn_19+0x8b>
    2532:	mov    QWORD PTR [rsp+0x10],rax
    2537:	mov    rcx,rax
    253a:	mov    r8,QWORD PTR [rsp+0x28]
    253f:	mov    QWORD PTR [rsp+0x18],r8
    2544:	mov    r9,QWORD PTR [rsp+0x30]
    2549:	mov    QWORD PTR [rsp+0x20],r9
    254e:	mov    edx,0x1
    2553:	mov    rsi,r12
    2556:	mov    rdi,r13
    2559:	call   255e <botlish_fn_19+0x82>
			255a: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    255e:	test   rax,rax
    2561:	jne    257d <botlish_fn_19+0xa1>
    2567:	xor    rax,rax
    256a:	mov    r12,QWORD PTR [rsp+0x40]
    256f:	mov    r13,QWORD PTR [rsp+0x48]
    2574:	add    rsp,0x50
    2578:	mov    rsp,rbp
    257b:	pop    rbp
    257c:	ret
    257d:	mov    r12,QWORD PTR [rsp+0x40]
    2582:	mov    r13,QWORD PTR [rsp+0x48]
    2587:	add    rsp,0x50
    258b:	mov    rsp,rbp
    258e:	pop    rbp
    258f:	ret

0000000000002590 <botlish_entry_19: csv_parse<str>>:
    2590:	push   rbp
    2591:	mov    rbp,rsp
    2594:	mov    rsi,QWORD PTR [rdx]
    2597:	call   259c <botlish_entry_19+0xc>
			2598: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    259c:	mov    rsp,rbp
    259f:	pop    rbp
    25a0:	ret

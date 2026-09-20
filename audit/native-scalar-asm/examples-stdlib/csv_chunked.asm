; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10496  (per function: 68 28 206 574 574 574 574 672 592 577 577 365 430 585 770 352 799 833 537 612 197)
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
       4:	sub    rsp,0x10
       8:	mov    r8,QWORD PTR [rdi+0x10]
       c:	mov    rsi,QWORD PTR [r8]
       f:	mov    QWORD PTR [rsp],rsi
      13:	call   18 <botlish_fn_0+0x18>
			14: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
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

0000000000000044 <botlish_fn_1: chunk_size<generic>>:
      44:	push   rbp
      45:	mov    rbp,rsp
      48:	mov    eax,0x81
      4d:	mov    rsp,rbp
      50:	pop    rbp
      51:	ret

0000000000000052 <botlish_entry_1: chunk_size<generic>>:
      52:	push   rbp
      53:	mov    rbp,rsp
      56:	call   5b <botlish_entry_1+0x9>
			57: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
      5b:	mov    rsp,rbp
      5e:	pop    rbp
      5f:	ret

0000000000000060 <botlish_fn_2: chunked_new<generic>>:
      60:	push   rbp
      61:	mov    rbp,rsp
      64:	sub    rsp,0x30
      68:	mov    QWORD PTR [rsp+0x10],rbx
      6d:	mov    QWORD PTR [rsp+0x18],r12
      72:	mov    QWORD PTR [rsp+0x20],r13
      77:	mov    r12,rsi
      7a:	mov    r13,rdi
      7d:	mov    QWORD PTR [rsp],0x0
      85:	mov    QWORD PTR [rsp+0x8],0x0
      8e:	xor    rdx,rdx
      91:	mov    rdi,r13
      94:	mov    rsi,rdx
      97:	call   9c <botlish_fn_2+0x3c>
			98: R_X86_64_PLT32	rt_list_new-0x4
      9c:	test   rax,rax
      9f:	je     d6 <botlish_fn_2+0x76>
      a5:	mov    QWORD PTR [rsp],rax
      a9:	mov    rbx,rax
      ac:	mov    rdi,r13
      af:	call   b4 <botlish_fn_2+0x54>
			b0: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
      b4:	test   rax,rax
      b7:	je     d6 <botlish_fn_2+0x76>
      bd:	mov    QWORD PTR [rsp+0x8],rax
      c2:	mov    rsi,rax
      c5:	mov    rdi,r13
      c8:	call   cd <botlish_fn_2+0x6d>
			c9: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      cd:	test   rax,rax
      d0:	jne    f1 <botlish_fn_2+0x91>
      d6:	xor    rax,rax
      d9:	mov    rbx,QWORD PTR [rsp+0x10]
      de:	mov    r12,QWORD PTR [rsp+0x18]
      e3:	mov    r13,QWORD PTR [rsp+0x20]
      e8:	add    rsp,0x30
      ec:	mov    rsp,rbp
      ef:	pop    rbp
      f0:	ret
      f1:	mov    rsi,r12
      f4:	mov    QWORD PTR [rsi],rax
      f7:	mov    QWORD PTR [rsi+0x8],0x1
      ff:	mov    rax,rbx
     102:	mov    rbx,QWORD PTR [rsp+0x10]
     107:	mov    r12,QWORD PTR [rsp+0x18]
     10c:	mov    r13,QWORD PTR [rsp+0x20]
     111:	add    rsp,0x30
     115:	mov    rsp,rbp
     118:	pop    rbp
     119:	ret

000000000000011a <botlish_entry_2: chunked_new<generic>>:
     11a:	push   rbp
     11b:	mov    rbp,rsp
     11e:	ud2

0000000000000120 <botlish_fn_3: chunked_append<list[list<never>, mutarray, int], str>>:
     120:	push   rbp
     121:	mov    rbp,rsp
     124:	sub    rsp,0x60
     128:	mov    QWORD PTR [rsp+0x30],rbx
     12d:	mov    QWORD PTR [rsp+0x38],r12
     132:	mov    QWORD PTR [rsp+0x40],r13
     137:	mov    QWORD PTR [rsp+0x48],r14
     13c:	mov    QWORD PTR [rsp+0x50],r15
     141:	mov    r12,r9
     144:	mov    r13,rdi
     147:	mov    QWORD PTR [rsp],rsi
     14b:	mov    r14,rsi
     14e:	mov    QWORD PTR [rsp+0x8],rdx
     153:	mov    r15,rdx
     156:	mov    QWORD PTR [rsp+0x10],rcx
     15b:	mov    rbx,rcx
     15e:	mov    QWORD PTR [rsp+0x18],r8
     163:	mov    QWORD PTR [rsp+0x20],r8
     168:	mov    rdi,r13
     16b:	call   170 <botlish_fn_3+0x50>
			16c: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     170:	test   rax,rax
     173:	je     2bf <botlish_fn_3+0x19f>
     179:	mov    rcx,rbx
     17c:	and    rcx,rax
     17f:	mov    rdx,rax
     182:	test   rcx,0x1
     189:	jne    1af <botlish_fn_3+0x8f>
     18f:	mov    rsi,rbx
     192:	mov    rdi,r13
     195:	call   19a <botlish_fn_3+0x7a>
			196: R_X86_64_PLT32	rt_int_cmp-0x4
     19a:	mov    ecx,0x2
     19f:	test   rax,rax
     1a2:	cmove  rcx,QWORD PTR [rip+0x176]        # 320 <botlish_fn_3+0x200>
     1aa:	jmp    1bf <botlish_fn_3+0x9f>
     1af:	mov    ecx,0x2
     1b4:	cmp    rbx,rdx
     1b7:	cmove  rcx,QWORD PTR [rip+0x161]        # 320 <botlish_fn_3+0x200>
     1bf:	cmp    rcx,0x6
     1c3:	je     256 <botlish_fn_3+0x136>
     1c9:	mov    rcx,QWORD PTR [rsp+0x20]
     1ce:	mov    rdx,rbx
     1d1:	mov    rsi,r15
     1d4:	mov    rdi,r13
     1d7:	call   1dc <botlish_fn_3+0xbc>
			1d8: R_X86_64_PLT32	rt_mutarray_set-0x4
     1dc:	test   rax,rax
     1df:	je     2bf <botlish_fn_3+0x19f>
     1e5:	mov    QWORD PTR [rsp+0x18],0x3
     1ee:	test   rbx,0x1
     1f5:	je     215 <botlish_fn_3+0xf5>
     1fb:	mov    rax,rbx
     1fe:	add    rax,0x2
     202:	seto   cl
     205:	test   cl,cl
     207:	jne    215 <botlish_fn_3+0xf5>
     20d:	mov    rdx,r15
     210:	jmp    228 <botlish_fn_3+0x108>
     215:	mov    edx,0x3
     21a:	mov    rsi,rbx
     21d:	mov    rdi,r13
     220:	call   225 <botlish_fn_3+0x105>
			221: R_X86_64_PLT32	rt_int_add-0x4
     225:	mov    rdx,r15
     228:	mov    QWORD PTR [r12],rdx
     22c:	mov    QWORD PTR [r12+0x8],rax
     231:	mov    rax,r14
     234:	mov    rbx,QWORD PTR [rsp+0x30]
     239:	mov    r12,QWORD PTR [rsp+0x38]
     23e:	mov    r13,QWORD PTR [rsp+0x40]
     243:	mov    r14,QWORD PTR [rsp+0x48]
     248:	mov    r15,QWORD PTR [rsp+0x50]
     24d:	add    rsp,0x60
     251:	mov    rsp,rbp
     254:	pop    rbp
     255:	ret
     256:	mov    rdx,r15
     259:	mov    rsi,r14
     25c:	mov    rdi,r13
     25f:	call   264 <botlish_fn_3+0x144>
			260: R_X86_64_PLT32	rt_list_append-0x4
     264:	test   rax,rax
     267:	je     2bf <botlish_fn_3+0x19f>
     26d:	mov    QWORD PTR [rsp],rax
     271:	mov    rbx,rax
     274:	mov    rdi,r13
     277:	call   27c <botlish_fn_3+0x15c>
			278: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     27c:	test   rax,rax
     27f:	je     2bf <botlish_fn_3+0x19f>
     285:	mov    QWORD PTR [rsp+0x8],rax
     28a:	mov    rsi,rax
     28d:	mov    rdi,r13
     290:	call   295 <botlish_fn_3+0x175>
			291: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     295:	test   rax,rax
     298:	mov    r14,rax
     29b:	je     2bf <botlish_fn_3+0x19f>
     2a1:	mov    edx,0x1
     2a6:	mov    rcx,QWORD PTR [rsp+0x20]
     2ab:	mov    rdi,r13
     2ae:	mov    rsi,r14
     2b1:	call   2b6 <botlish_fn_3+0x196>
			2b2: R_X86_64_PLT32	rt_mutarray_set-0x4
     2b6:	test   rax,rax
     2b9:	jne    2e4 <botlish_fn_3+0x1c4>
     2bf:	xor    rax,rax
     2c2:	mov    rbx,QWORD PTR [rsp+0x30]
     2c7:	mov    r12,QWORD PTR [rsp+0x38]
     2cc:	mov    r13,QWORD PTR [rsp+0x40]
     2d1:	mov    r14,QWORD PTR [rsp+0x48]
     2d6:	mov    r15,QWORD PTR [rsp+0x50]
     2db:	add    rsp,0x60
     2df:	mov    rsp,rbp
     2e2:	pop    rbp
     2e3:	ret
     2e4:	mov    rax,r14
     2e7:	mov    QWORD PTR [r12],rax
     2eb:	mov    QWORD PTR [r12+0x8],0x3
     2f4:	mov    rax,rbx
     2f7:	mov    rbx,QWORD PTR [rsp+0x30]
     2fc:	mov    r12,QWORD PTR [rsp+0x38]
     301:	mov    r13,QWORD PTR [rsp+0x40]
     306:	mov    r14,QWORD PTR [rsp+0x48]
     30b:	mov    r15,QWORD PTR [rsp+0x50]
     310:	add    rsp,0x60
     314:	mov    rsp,rbp
     317:	pop    rbp
     318:	ret
     319:	add    BYTE PTR [rax],al
     31b:	add    BYTE PTR [rax],al
     31d:	add    BYTE PTR [rax],al
     31f:	add    BYTE PTR [rsi],al
     321:	add    BYTE PTR [rax],al
     323:	add    BYTE PTR [rax],al
     325:	add    BYTE PTR [rax],al
	...

0000000000000328 <botlish_entry_3: chunked_append<list[list<never>, mutarray, int], str>>:
     328:	push   rbp
     329:	mov    rbp,rsp
     32c:	ud2
	...

0000000000000330 <botlish_fn_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     330:	push   rbp
     331:	mov    rbp,rsp
     334:	sub    rsp,0x60
     338:	mov    QWORD PTR [rsp+0x30],rbx
     33d:	mov    QWORD PTR [rsp+0x38],r12
     342:	mov    QWORD PTR [rsp+0x40],r13
     347:	mov    QWORD PTR [rsp+0x48],r14
     34c:	mov    QWORD PTR [rsp+0x50],r15
     351:	mov    r12,r9
     354:	mov    r13,rdi
     357:	mov    QWORD PTR [rsp],rsi
     35b:	mov    r14,rsi
     35e:	mov    QWORD PTR [rsp+0x8],rdx
     363:	mov    r15,rdx
     366:	mov    QWORD PTR [rsp+0x10],rcx
     36b:	mov    rbx,rcx
     36e:	mov    QWORD PTR [rsp+0x18],r8
     373:	mov    QWORD PTR [rsp+0x20],r8
     378:	mov    rdi,r13
     37b:	call   380 <botlish_fn_4+0x50>
			37c: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     380:	test   rax,rax
     383:	je     4cf <botlish_fn_4+0x19f>
     389:	mov    rcx,rbx
     38c:	and    rcx,rax
     38f:	mov    rdx,rax
     392:	test   rcx,0x1
     399:	jne    3bf <botlish_fn_4+0x8f>
     39f:	mov    rsi,rbx
     3a2:	mov    rdi,r13
     3a5:	call   3aa <botlish_fn_4+0x7a>
			3a6: R_X86_64_PLT32	rt_int_cmp-0x4
     3aa:	mov    ecx,0x2
     3af:	test   rax,rax
     3b2:	cmove  rcx,QWORD PTR [rip+0x176]        # 530 <botlish_fn_4+0x200>
     3ba:	jmp    3cf <botlish_fn_4+0x9f>
     3bf:	mov    ecx,0x2
     3c4:	cmp    rbx,rdx
     3c7:	cmove  rcx,QWORD PTR [rip+0x161]        # 530 <botlish_fn_4+0x200>
     3cf:	cmp    rcx,0x6
     3d3:	je     466 <botlish_fn_4+0x136>
     3d9:	mov    rcx,QWORD PTR [rsp+0x20]
     3de:	mov    rdx,rbx
     3e1:	mov    rsi,r15
     3e4:	mov    rdi,r13
     3e7:	call   3ec <botlish_fn_4+0xbc>
			3e8: R_X86_64_PLT32	rt_mutarray_set-0x4
     3ec:	test   rax,rax
     3ef:	je     4cf <botlish_fn_4+0x19f>
     3f5:	mov    QWORD PTR [rsp+0x18],0x3
     3fe:	test   rbx,0x1
     405:	je     425 <botlish_fn_4+0xf5>
     40b:	mov    rax,rbx
     40e:	add    rax,0x2
     412:	seto   cl
     415:	test   cl,cl
     417:	jne    425 <botlish_fn_4+0xf5>
     41d:	mov    rdx,r15
     420:	jmp    438 <botlish_fn_4+0x108>
     425:	mov    edx,0x3
     42a:	mov    rsi,rbx
     42d:	mov    rdi,r13
     430:	call   435 <botlish_fn_4+0x105>
			431: R_X86_64_PLT32	rt_int_add-0x4
     435:	mov    rdx,r15
     438:	mov    QWORD PTR [r12],rdx
     43c:	mov    QWORD PTR [r12+0x8],rax
     441:	mov    rax,r14
     444:	mov    rbx,QWORD PTR [rsp+0x30]
     449:	mov    r12,QWORD PTR [rsp+0x38]
     44e:	mov    r13,QWORD PTR [rsp+0x40]
     453:	mov    r14,QWORD PTR [rsp+0x48]
     458:	mov    r15,QWORD PTR [rsp+0x50]
     45d:	add    rsp,0x60
     461:	mov    rsp,rbp
     464:	pop    rbp
     465:	ret
     466:	mov    rdx,r15
     469:	mov    rsi,r14
     46c:	mov    rdi,r13
     46f:	call   474 <botlish_fn_4+0x144>
			470: R_X86_64_PLT32	rt_list_append-0x4
     474:	test   rax,rax
     477:	je     4cf <botlish_fn_4+0x19f>
     47d:	mov    QWORD PTR [rsp],rax
     481:	mov    rbx,rax
     484:	mov    rdi,r13
     487:	call   48c <botlish_fn_4+0x15c>
			488: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     48c:	test   rax,rax
     48f:	je     4cf <botlish_fn_4+0x19f>
     495:	mov    QWORD PTR [rsp+0x8],rax
     49a:	mov    rsi,rax
     49d:	mov    rdi,r13
     4a0:	call   4a5 <botlish_fn_4+0x175>
			4a1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     4a5:	test   rax,rax
     4a8:	mov    r14,rax
     4ab:	je     4cf <botlish_fn_4+0x19f>
     4b1:	mov    edx,0x1
     4b6:	mov    rcx,QWORD PTR [rsp+0x20]
     4bb:	mov    rdi,r13
     4be:	mov    rsi,r14
     4c1:	call   4c6 <botlish_fn_4+0x196>
			4c2: R_X86_64_PLT32	rt_mutarray_set-0x4
     4c6:	test   rax,rax
     4c9:	jne    4f4 <botlish_fn_4+0x1c4>
     4cf:	xor    rax,rax
     4d2:	mov    rbx,QWORD PTR [rsp+0x30]
     4d7:	mov    r12,QWORD PTR [rsp+0x38]
     4dc:	mov    r13,QWORD PTR [rsp+0x40]
     4e1:	mov    r14,QWORD PTR [rsp+0x48]
     4e6:	mov    r15,QWORD PTR [rsp+0x50]
     4eb:	add    rsp,0x60
     4ef:	mov    rsp,rbp
     4f2:	pop    rbp
     4f3:	ret
     4f4:	mov    rax,r14
     4f7:	mov    QWORD PTR [r12],rax
     4fb:	mov    QWORD PTR [r12+0x8],0x3
     504:	mov    rax,rbx
     507:	mov    rbx,QWORD PTR [rsp+0x30]
     50c:	mov    r12,QWORD PTR [rsp+0x38]
     511:	mov    r13,QWORD PTR [rsp+0x40]
     516:	mov    r14,QWORD PTR [rsp+0x48]
     51b:	mov    r15,QWORD PTR [rsp+0x50]
     520:	add    rsp,0x60
     524:	mov    rsp,rbp
     527:	pop    rbp
     528:	ret
     529:	add    BYTE PTR [rax],al
     52b:	add    BYTE PTR [rax],al
     52d:	add    BYTE PTR [rax],al
     52f:	add    BYTE PTR [rsi],al
     531:	add    BYTE PTR [rax],al
     533:	add    BYTE PTR [rax],al
     535:	add    BYTE PTR [rax],al
	...

0000000000000538 <botlish_entry_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     538:	push   rbp
     539:	mov    rbp,rsp
     53c:	ud2
	...

0000000000000540 <botlish_fn_5: chunked_append<list[list<never>, mutarray, int], list>>:
     540:	push   rbp
     541:	mov    rbp,rsp
     544:	sub    rsp,0x60
     548:	mov    QWORD PTR [rsp+0x30],rbx
     54d:	mov    QWORD PTR [rsp+0x38],r12
     552:	mov    QWORD PTR [rsp+0x40],r13
     557:	mov    QWORD PTR [rsp+0x48],r14
     55c:	mov    QWORD PTR [rsp+0x50],r15
     561:	mov    r12,r9
     564:	mov    r13,rdi
     567:	mov    QWORD PTR [rsp],rsi
     56b:	mov    r14,rsi
     56e:	mov    QWORD PTR [rsp+0x8],rdx
     573:	mov    r15,rdx
     576:	mov    QWORD PTR [rsp+0x10],rcx
     57b:	mov    rbx,rcx
     57e:	mov    QWORD PTR [rsp+0x18],r8
     583:	mov    QWORD PTR [rsp+0x20],r8
     588:	mov    rdi,r13
     58b:	call   590 <botlish_fn_5+0x50>
			58c: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     590:	test   rax,rax
     593:	je     6df <botlish_fn_5+0x19f>
     599:	mov    rcx,rbx
     59c:	and    rcx,rax
     59f:	mov    rdx,rax
     5a2:	test   rcx,0x1
     5a9:	jne    5cf <botlish_fn_5+0x8f>
     5af:	mov    rsi,rbx
     5b2:	mov    rdi,r13
     5b5:	call   5ba <botlish_fn_5+0x7a>
			5b6: R_X86_64_PLT32	rt_int_cmp-0x4
     5ba:	mov    ecx,0x2
     5bf:	test   rax,rax
     5c2:	cmove  rcx,QWORD PTR [rip+0x176]        # 740 <botlish_fn_5+0x200>
     5ca:	jmp    5df <botlish_fn_5+0x9f>
     5cf:	mov    ecx,0x2
     5d4:	cmp    rbx,rdx
     5d7:	cmove  rcx,QWORD PTR [rip+0x161]        # 740 <botlish_fn_5+0x200>
     5df:	cmp    rcx,0x6
     5e3:	je     676 <botlish_fn_5+0x136>
     5e9:	mov    rcx,QWORD PTR [rsp+0x20]
     5ee:	mov    rdx,rbx
     5f1:	mov    rsi,r15
     5f4:	mov    rdi,r13
     5f7:	call   5fc <botlish_fn_5+0xbc>
			5f8: R_X86_64_PLT32	rt_mutarray_set-0x4
     5fc:	test   rax,rax
     5ff:	je     6df <botlish_fn_5+0x19f>
     605:	mov    QWORD PTR [rsp+0x18],0x3
     60e:	test   rbx,0x1
     615:	je     635 <botlish_fn_5+0xf5>
     61b:	mov    rax,rbx
     61e:	add    rax,0x2
     622:	seto   cl
     625:	test   cl,cl
     627:	jne    635 <botlish_fn_5+0xf5>
     62d:	mov    rdx,r15
     630:	jmp    648 <botlish_fn_5+0x108>
     635:	mov    edx,0x3
     63a:	mov    rsi,rbx
     63d:	mov    rdi,r13
     640:	call   645 <botlish_fn_5+0x105>
			641: R_X86_64_PLT32	rt_int_add-0x4
     645:	mov    rdx,r15
     648:	mov    QWORD PTR [r12],rdx
     64c:	mov    QWORD PTR [r12+0x8],rax
     651:	mov    rax,r14
     654:	mov    rbx,QWORD PTR [rsp+0x30]
     659:	mov    r12,QWORD PTR [rsp+0x38]
     65e:	mov    r13,QWORD PTR [rsp+0x40]
     663:	mov    r14,QWORD PTR [rsp+0x48]
     668:	mov    r15,QWORD PTR [rsp+0x50]
     66d:	add    rsp,0x60
     671:	mov    rsp,rbp
     674:	pop    rbp
     675:	ret
     676:	mov    rdx,r15
     679:	mov    rsi,r14
     67c:	mov    rdi,r13
     67f:	call   684 <botlish_fn_5+0x144>
			680: R_X86_64_PLT32	rt_list_append-0x4
     684:	test   rax,rax
     687:	je     6df <botlish_fn_5+0x19f>
     68d:	mov    QWORD PTR [rsp],rax
     691:	mov    rbx,rax
     694:	mov    rdi,r13
     697:	call   69c <botlish_fn_5+0x15c>
			698: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     69c:	test   rax,rax
     69f:	je     6df <botlish_fn_5+0x19f>
     6a5:	mov    QWORD PTR [rsp+0x8],rax
     6aa:	mov    rsi,rax
     6ad:	mov    rdi,r13
     6b0:	call   6b5 <botlish_fn_5+0x175>
			6b1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     6b5:	test   rax,rax
     6b8:	mov    r14,rax
     6bb:	je     6df <botlish_fn_5+0x19f>
     6c1:	mov    edx,0x1
     6c6:	mov    rcx,QWORD PTR [rsp+0x20]
     6cb:	mov    rdi,r13
     6ce:	mov    rsi,r14
     6d1:	call   6d6 <botlish_fn_5+0x196>
			6d2: R_X86_64_PLT32	rt_mutarray_set-0x4
     6d6:	test   rax,rax
     6d9:	jne    704 <botlish_fn_5+0x1c4>
     6df:	xor    rax,rax
     6e2:	mov    rbx,QWORD PTR [rsp+0x30]
     6e7:	mov    r12,QWORD PTR [rsp+0x38]
     6ec:	mov    r13,QWORD PTR [rsp+0x40]
     6f1:	mov    r14,QWORD PTR [rsp+0x48]
     6f6:	mov    r15,QWORD PTR [rsp+0x50]
     6fb:	add    rsp,0x60
     6ff:	mov    rsp,rbp
     702:	pop    rbp
     703:	ret
     704:	mov    rax,r14
     707:	mov    QWORD PTR [r12],rax
     70b:	mov    QWORD PTR [r12+0x8],0x3
     714:	mov    rax,rbx
     717:	mov    rbx,QWORD PTR [rsp+0x30]
     71c:	mov    r12,QWORD PTR [rsp+0x38]
     721:	mov    r13,QWORD PTR [rsp+0x40]
     726:	mov    r14,QWORD PTR [rsp+0x48]
     72b:	mov    r15,QWORD PTR [rsp+0x50]
     730:	add    rsp,0x60
     734:	mov    rsp,rbp
     737:	pop    rbp
     738:	ret
     739:	add    BYTE PTR [rax],al
     73b:	add    BYTE PTR [rax],al
     73d:	add    BYTE PTR [rax],al
     73f:	add    BYTE PTR [rsi],al
     741:	add    BYTE PTR [rax],al
     743:	add    BYTE PTR [rax],al
     745:	add    BYTE PTR [rax],al
	...

0000000000000748 <botlish_entry_5: chunked_append<list[list<never>, mutarray, int], list>>:
     748:	push   rbp
     749:	mov    rbp,rsp
     74c:	ud2
	...

0000000000000750 <botlish_fn_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     750:	push   rbp
     751:	mov    rbp,rsp
     754:	sub    rsp,0x60
     758:	mov    QWORD PTR [rsp+0x30],rbx
     75d:	mov    QWORD PTR [rsp+0x38],r12
     762:	mov    QWORD PTR [rsp+0x40],r13
     767:	mov    QWORD PTR [rsp+0x48],r14
     76c:	mov    QWORD PTR [rsp+0x50],r15
     771:	mov    r12,r9
     774:	mov    r13,rdi
     777:	mov    QWORD PTR [rsp],rsi
     77b:	mov    r14,rsi
     77e:	mov    QWORD PTR [rsp+0x8],rdx
     783:	mov    r15,rdx
     786:	mov    QWORD PTR [rsp+0x10],rcx
     78b:	mov    rbx,rcx
     78e:	mov    QWORD PTR [rsp+0x18],r8
     793:	mov    QWORD PTR [rsp+0x20],r8
     798:	mov    rdi,r13
     79b:	call   7a0 <botlish_fn_6+0x50>
			79c: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     7a0:	test   rax,rax
     7a3:	je     8ef <botlish_fn_6+0x19f>
     7a9:	mov    rcx,rbx
     7ac:	and    rcx,rax
     7af:	mov    rdx,rax
     7b2:	test   rcx,0x1
     7b9:	jne    7df <botlish_fn_6+0x8f>
     7bf:	mov    rsi,rbx
     7c2:	mov    rdi,r13
     7c5:	call   7ca <botlish_fn_6+0x7a>
			7c6: R_X86_64_PLT32	rt_int_cmp-0x4
     7ca:	mov    ecx,0x2
     7cf:	test   rax,rax
     7d2:	cmove  rcx,QWORD PTR [rip+0x176]        # 950 <botlish_fn_6+0x200>
     7da:	jmp    7ef <botlish_fn_6+0x9f>
     7df:	mov    ecx,0x2
     7e4:	cmp    rbx,rdx
     7e7:	cmove  rcx,QWORD PTR [rip+0x161]        # 950 <botlish_fn_6+0x200>
     7ef:	cmp    rcx,0x6
     7f3:	je     886 <botlish_fn_6+0x136>
     7f9:	mov    rcx,QWORD PTR [rsp+0x20]
     7fe:	mov    rdx,rbx
     801:	mov    rsi,r15
     804:	mov    rdi,r13
     807:	call   80c <botlish_fn_6+0xbc>
			808: R_X86_64_PLT32	rt_mutarray_set-0x4
     80c:	test   rax,rax
     80f:	je     8ef <botlish_fn_6+0x19f>
     815:	mov    QWORD PTR [rsp+0x18],0x3
     81e:	test   rbx,0x1
     825:	je     845 <botlish_fn_6+0xf5>
     82b:	mov    rax,rbx
     82e:	add    rax,0x2
     832:	seto   cl
     835:	test   cl,cl
     837:	jne    845 <botlish_fn_6+0xf5>
     83d:	mov    rdx,r15
     840:	jmp    858 <botlish_fn_6+0x108>
     845:	mov    edx,0x3
     84a:	mov    rsi,rbx
     84d:	mov    rdi,r13
     850:	call   855 <botlish_fn_6+0x105>
			851: R_X86_64_PLT32	rt_int_add-0x4
     855:	mov    rdx,r15
     858:	mov    QWORD PTR [r12],rdx
     85c:	mov    QWORD PTR [r12+0x8],rax
     861:	mov    rax,r14
     864:	mov    rbx,QWORD PTR [rsp+0x30]
     869:	mov    r12,QWORD PTR [rsp+0x38]
     86e:	mov    r13,QWORD PTR [rsp+0x40]
     873:	mov    r14,QWORD PTR [rsp+0x48]
     878:	mov    r15,QWORD PTR [rsp+0x50]
     87d:	add    rsp,0x60
     881:	mov    rsp,rbp
     884:	pop    rbp
     885:	ret
     886:	mov    rdx,r15
     889:	mov    rsi,r14
     88c:	mov    rdi,r13
     88f:	call   894 <botlish_fn_6+0x144>
			890: R_X86_64_PLT32	rt_list_append-0x4
     894:	test   rax,rax
     897:	je     8ef <botlish_fn_6+0x19f>
     89d:	mov    QWORD PTR [rsp],rax
     8a1:	mov    rbx,rax
     8a4:	mov    rdi,r13
     8a7:	call   8ac <botlish_fn_6+0x15c>
			8a8: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     8ac:	test   rax,rax
     8af:	je     8ef <botlish_fn_6+0x19f>
     8b5:	mov    QWORD PTR [rsp+0x8],rax
     8ba:	mov    rsi,rax
     8bd:	mov    rdi,r13
     8c0:	call   8c5 <botlish_fn_6+0x175>
			8c1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     8c5:	test   rax,rax
     8c8:	mov    r14,rax
     8cb:	je     8ef <botlish_fn_6+0x19f>
     8d1:	mov    edx,0x1
     8d6:	mov    rcx,QWORD PTR [rsp+0x20]
     8db:	mov    rdi,r13
     8de:	mov    rsi,r14
     8e1:	call   8e6 <botlish_fn_6+0x196>
			8e2: R_X86_64_PLT32	rt_mutarray_set-0x4
     8e6:	test   rax,rax
     8e9:	jne    914 <botlish_fn_6+0x1c4>
     8ef:	xor    rax,rax
     8f2:	mov    rbx,QWORD PTR [rsp+0x30]
     8f7:	mov    r12,QWORD PTR [rsp+0x38]
     8fc:	mov    r13,QWORD PTR [rsp+0x40]
     901:	mov    r14,QWORD PTR [rsp+0x48]
     906:	mov    r15,QWORD PTR [rsp+0x50]
     90b:	add    rsp,0x60
     90f:	mov    rsp,rbp
     912:	pop    rbp
     913:	ret
     914:	mov    rax,r14
     917:	mov    QWORD PTR [r12],rax
     91b:	mov    QWORD PTR [r12+0x8],0x3
     924:	mov    rax,rbx
     927:	mov    rbx,QWORD PTR [rsp+0x30]
     92c:	mov    r12,QWORD PTR [rsp+0x38]
     931:	mov    r13,QWORD PTR [rsp+0x40]
     936:	mov    r14,QWORD PTR [rsp+0x48]
     93b:	mov    r15,QWORD PTR [rsp+0x50]
     940:	add    rsp,0x60
     944:	mov    rsp,rbp
     947:	pop    rbp
     948:	ret
     949:	add    BYTE PTR [rax],al
     94b:	add    BYTE PTR [rax],al
     94d:	add    BYTE PTR [rax],al
     94f:	add    BYTE PTR [rsi],al
     951:	add    BYTE PTR [rax],al
     953:	add    BYTE PTR [rax],al
     955:	add    BYTE PTR [rax],al
	...

0000000000000958 <botlish_entry_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     958:	push   rbp
     959:	mov    rbp,rsp
     95c:	ud2
	...

0000000000000960 <botlish_fn_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
     960:	push   rbp
     961:	mov    rbp,rsp
     964:	sub    rsp,0x70
     968:	mov    QWORD PTR [rsp+0x40],rbx
     96d:	mov    QWORD PTR [rsp+0x48],r12
     972:	mov    QWORD PTR [rsp+0x50],r13
     977:	mov    QWORD PTR [rsp+0x58],r14
     97c:	mov    QWORD PTR [rsp+0x60],r15
     981:	mov    r14,rdi
     984:	mov    QWORD PTR [rsp],rsi
     988:	mov    QWORD PTR [rsp+0x8],rdx
     98d:	mov    rbx,rdx
     990:	mov    QWORD PTR [rsp+0x10],rcx
     995:	mov    r12,rcx
     998:	mov    QWORD PTR [rsp+0x18],r8
     99d:	mov    r13,rsi
     9a0:	mov    r15,r8
     9a3:	mov    rsi,r13
     9a6:	mov    rdi,r14
     9a9:	call   9ae <botlish_fn_7+0x4e>
			9aa: R_X86_64_PLT32	rt_list_len-0x4
     9ae:	mov    rcx,rbx
     9b1:	and    rcx,rax
     9b4:	mov    rdx,rax
     9b7:	test   rcx,0x1
     9be:	jne    9e4 <botlish_fn_7+0x84>
     9c4:	mov    rsi,rbx
     9c7:	mov    rdi,r14
     9ca:	call   9cf <botlish_fn_7+0x6f>
			9cb: R_X86_64_PLT32	rt_int_cmp-0x4
     9cf:	mov    ecx,0x2
     9d4:	test   rax,rax
     9d7:	cmovge rcx,QWORD PTR [rip+0x1d1]        # bb0 <botlish_fn_7+0x250>
     9df:	jmp    9f4 <botlish_fn_7+0x94>
     9e4:	mov    ecx,0x2
     9e9:	cmp    rbx,rdx
     9ec:	cmovge rcx,QWORD PTR [rip+0x1bc]        # bb0 <botlish_fn_7+0x250>
     9f4:	cmp    rcx,0x6
     9f8:	je     b88 <botlish_fn_7+0x228>
     9fe:	test   rbx,0x1
     a05:	je     a1e <botlish_fn_7+0xbe>
     a0b:	mov    rcx,QWORD PTR [r13+0x8]
     a0f:	mov    rax,rbx
     a12:	sar    rax,1
     a15:	cmp    rax,rcx
     a18:	jb     a3d <botlish_fn_7+0xdd>
     a1e:	mov    rdx,rbx
     a21:	mov    rsi,r13
     a24:	mov    rdi,r14
     a27:	call   a2c <botlish_fn_7+0xcc>
			a28: R_X86_64_PLT32	rt_list_get-0x4
     a2c:	test   rax,rax
     a2f:	je     afc <botlish_fn_7+0x19c>
     a35:	mov    rsi,rax
     a38:	jmp    a48 <botlish_fn_7+0xe8>
     a3d:	mov    rdi,QWORD PTR [r13+0x10]
     a41:	mov    rdi,QWORD PTR [rdi+rax*8]
     a45:	mov    rsi,rdi
     a48:	mov    QWORD PTR [rsp+0x20],rsi
     a4d:	mov    QWORD PTR [rsp+0x30],rsi
     a52:	mov    QWORD PTR [rsp+0x28],0x1
     a5b:	mov    rdi,r14
     a5e:	call   a63 <botlish_fn_7+0x103>
			a5f: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     a63:	test   rax,rax
     a66:	mov    r9,rax
     a69:	je     afc <botlish_fn_7+0x19c>
     a6f:	xor    eax,eax
     a71:	mov    rsi,QWORD PTR [rsp+0x30]
     a76:	test   rsi,0x7
     a7d:	jne    a8c <botlish_fn_7+0x12c>
     a83:	movzx  rax,BYTE PTR [rsi]
     a87:	cmp    al,0x8
     a89:	sete   al
     a8c:	test   al,al
     a8e:	jne    aae <botlish_fn_7+0x14e>
     a94:	mov    rdi,r14
     a97:	mov    rax,QWORD PTR [rdi+0x10]
     a9b:	mov    rcx,QWORD PTR [rax+0x8]
     a9f:	mov    edx,0x8
     aa4:	call   aa9 <botlish_fn_7+0x149>
			aa5: R_X86_64_PLT32	rt_type_error-0x4
     aa9:	jmp    afc <botlish_fn_7+0x19c>
     aae:	mov    QWORD PTR [rsp+0x30],rsi
     ab3:	mov    r8d,0x1
     ab9:	mov    rcx,QWORD PTR [rsp+0x30]
     abe:	mov    rdx,r15
     ac1:	mov    rsi,r12
     ac4:	mov    rdi,r14
     ac7:	call   acc <botlish_fn_7+0x16c>
			ac8: R_X86_64_PLT32	rt_mutarray_copy-0x4
     acc:	test   rax,rax
     acf:	je     afc <botlish_fn_7+0x19c>
     ad5:	sar    rbx,1
     ad8:	add    rbx,0x1
     adf:	shl    rbx,1
     ae2:	or     rbx,0x1
     ae6:	mov    QWORD PTR [rsp+0x8],rbx
     aeb:	mov    rdi,r14
     aee:	call   af3 <botlish_fn_7+0x193>
			aef: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     af3:	test   rax,rax
     af6:	jne    b21 <botlish_fn_7+0x1c1>
     afc:	xor    rax,rax
     aff:	mov    rbx,QWORD PTR [rsp+0x40]
     b04:	mov    r12,QWORD PTR [rsp+0x48]
     b09:	mov    r13,QWORD PTR [rsp+0x50]
     b0e:	mov    r14,QWORD PTR [rsp+0x58]
     b13:	mov    r15,QWORD PTR [rsp+0x60]
     b18:	add    rsp,0x70
     b1c:	mov    rsp,rbp
     b1f:	pop    rbp
     b20:	ret
     b21:	mov    QWORD PTR [rsp+0x20],rax
     b26:	mov    rsi,r15
     b29:	mov    rcx,rsi
     b2c:	and    rcx,rax
     b2f:	test   rcx,0x1
     b36:	jne    b47 <botlish_fn_7+0x1e7>
     b3c:	mov    rdx,rax
     b3f:	mov    rsi,r15
     b42:	jmp    b65 <botlish_fn_7+0x205>
     b47:	lea    rcx,[rax-0x1]
     b4b:	mov    rdx,rax
     b4e:	mov    rsi,r15
     b51:	mov    rax,rsi
     b54:	add    rax,rcx
     b57:	seto   cl
     b5a:	test   cl,cl
     b5c:	je     b6d <botlish_fn_7+0x20d>
     b62:	mov    rsi,r15
     b65:	mov    rdi,r14
     b68:	call   b6d <botlish_fn_7+0x20d>
			b69: R_X86_64_PLT32	rt_int_add-0x4
     b6d:	mov    QWORD PTR [rsp],r13
     b71:	mov    QWORD PTR [rsp+0x8],rbx
     b76:	mov    QWORD PTR [rsp+0x10],r12
     b7b:	mov    QWORD PTR [rsp+0x18],rax
     b80:	mov    r15,rax
     b83:	jmp    9a3 <botlish_fn_7+0x43>
     b88:	mov    rax,r15
     b8b:	mov    rbx,QWORD PTR [rsp+0x40]
     b90:	mov    r12,QWORD PTR [rsp+0x48]
     b95:	mov    r13,QWORD PTR [rsp+0x50]
     b9a:	mov    r14,QWORD PTR [rsp+0x58]
     b9f:	mov    r15,QWORD PTR [rsp+0x60]
     ba4:	add    rsp,0x70
     ba8:	mov    rsp,rbp
     bab:	pop    rbp
     bac:	ret
     bad:	add    BYTE PTR [rax],al
     baf:	add    BYTE PTR [rsi],al
     bb1:	add    BYTE PTR [rax],al
     bb3:	add    BYTE PTR [rax],al
     bb5:	add    BYTE PTR [rax],al
	...

0000000000000bb8 <botlish_entry_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
     bb8:	push   rbp
     bb9:	mov    rbp,rsp
     bbc:	mov    rsi,QWORD PTR [rdx]
     bbf:	mov    r9,QWORD PTR [rdx+0x8]
     bc3:	mov    rcx,QWORD PTR [rdx+0x10]
     bc7:	mov    r8,QWORD PTR [rdx+0x18]
     bcb:	mov    rdx,r9
     bce:	call   bd3 <botlish_entry_7+0x1b>
			bcf: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
     bd3:	mov    rsp,rbp
     bd6:	pop    rbp
     bd7:	ret

0000000000000bd8 <botlish_fn_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
     bd8:	push   rbp
     bd9:	mov    rbp,rsp
     bdc:	sub    rsp,0x70
     be0:	mov    QWORD PTR [rsp+0x40],rbx
     be5:	mov    QWORD PTR [rsp+0x48],r12
     bea:	mov    QWORD PTR [rsp+0x50],r13
     bef:	mov    QWORD PTR [rsp+0x58],r14
     bf4:	mov    QWORD PTR [rsp+0x60],r15
     bf9:	mov    r14,rdi
     bfc:	mov    QWORD PTR [rsp],rsi
     c00:	mov    QWORD PTR [rsp+0x8],rdx
     c05:	mov    rbx,rdx
     c08:	mov    QWORD PTR [rsp+0x10],rcx
     c0d:	mov    r12,rcx
     c10:	mov    QWORD PTR [rsp+0x18],r8
     c15:	mov    r13,rsi
     c18:	mov    r15,r8
     c1b:	mov    rsi,r13
     c1e:	mov    rdi,r14
     c21:	call   c26 <botlish_fn_8+0x4e>
			c22: R_X86_64_PLT32	rt_list_len-0x4
     c26:	mov    rcx,rbx
     c29:	and    rcx,rax
     c2c:	mov    rdx,rax
     c2f:	test   rcx,0x1
     c36:	jne    c5c <botlish_fn_8+0x84>
     c3c:	mov    rsi,rbx
     c3f:	mov    rdi,r14
     c42:	call   c47 <botlish_fn_8+0x6f>
			c43: R_X86_64_PLT32	rt_int_cmp-0x4
     c47:	mov    ecx,0x2
     c4c:	test   rax,rax
     c4f:	cmovge rcx,QWORD PTR [rip+0x189]        # de0 <botlish_fn_8+0x208>
     c57:	jmp    c6c <botlish_fn_8+0x94>
     c5c:	mov    ecx,0x2
     c61:	cmp    rbx,rdx
     c64:	cmovge rcx,QWORD PTR [rip+0x174]        # de0 <botlish_fn_8+0x208>
     c6c:	cmp    rcx,0x6
     c70:	je     db9 <botlish_fn_8+0x1e1>
     c76:	test   rbx,0x1
     c7d:	je     c96 <botlish_fn_8+0xbe>
     c83:	mov    rcx,QWORD PTR [r13+0x8]
     c87:	mov    rax,rbx
     c8a:	sar    rax,1
     c8d:	cmp    rax,rcx
     c90:	jb     cb5 <botlish_fn_8+0xdd>
     c96:	mov    rdx,rbx
     c99:	mov    rsi,r13
     c9c:	mov    rdi,r14
     c9f:	call   ca4 <botlish_fn_8+0xcc>
			ca0: R_X86_64_PLT32	rt_list_get-0x4
     ca4:	test   rax,rax
     ca7:	je     d2d <botlish_fn_8+0x155>
     cad:	mov    rcx,rax
     cb0:	jmp    cbd <botlish_fn_8+0xe5>
     cb5:	mov    rcx,QWORD PTR [r13+0x10]
     cb9:	mov    rcx,QWORD PTR [rcx+rax*8]
     cbd:	mov    QWORD PTR [rsp+0x20],rcx
     cc2:	mov    QWORD PTR [rsp+0x30],rcx
     cc7:	mov    QWORD PTR [rsp+0x28],0x1
     cd0:	mov    rdi,r14
     cd3:	call   cd8 <botlish_fn_8+0x100>
			cd4: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     cd8:	test   rax,rax
     cdb:	mov    r9,rax
     cde:	je     d2d <botlish_fn_8+0x155>
     ce4:	mov    r8d,0x1
     cea:	mov    rcx,QWORD PTR [rsp+0x30]
     cef:	mov    rdx,r15
     cf2:	mov    rsi,r12
     cf5:	mov    rdi,r14
     cf8:	call   cfd <botlish_fn_8+0x125>
			cf9: R_X86_64_PLT32	rt_mutarray_copy-0x4
     cfd:	test   rax,rax
     d00:	je     d2d <botlish_fn_8+0x155>
     d06:	sar    rbx,1
     d09:	add    rbx,0x1
     d10:	shl    rbx,1
     d13:	or     rbx,0x1
     d17:	mov    QWORD PTR [rsp+0x8],rbx
     d1c:	mov    rdi,r14
     d1f:	call   d24 <botlish_fn_8+0x14c>
			d20: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     d24:	test   rax,rax
     d27:	jne    d52 <botlish_fn_8+0x17a>
     d2d:	xor    rax,rax
     d30:	mov    rbx,QWORD PTR [rsp+0x40]
     d35:	mov    r12,QWORD PTR [rsp+0x48]
     d3a:	mov    r13,QWORD PTR [rsp+0x50]
     d3f:	mov    r14,QWORD PTR [rsp+0x58]
     d44:	mov    r15,QWORD PTR [rsp+0x60]
     d49:	add    rsp,0x70
     d4d:	mov    rsp,rbp
     d50:	pop    rbp
     d51:	ret
     d52:	mov    QWORD PTR [rsp+0x20],rax
     d57:	mov    rsi,r15
     d5a:	mov    rcx,rsi
     d5d:	and    rcx,rax
     d60:	test   rcx,0x1
     d67:	jne    d78 <botlish_fn_8+0x1a0>
     d6d:	mov    rdx,rax
     d70:	mov    rsi,r15
     d73:	jmp    d96 <botlish_fn_8+0x1be>
     d78:	lea    rcx,[rax-0x1]
     d7c:	mov    rdx,rax
     d7f:	mov    rsi,r15
     d82:	mov    rax,rsi
     d85:	add    rax,rcx
     d88:	seto   cl
     d8b:	test   cl,cl
     d8d:	je     d9e <botlish_fn_8+0x1c6>
     d93:	mov    rsi,r15
     d96:	mov    rdi,r14
     d99:	call   d9e <botlish_fn_8+0x1c6>
			d9a: R_X86_64_PLT32	rt_int_add-0x4
     d9e:	mov    QWORD PTR [rsp],r13
     da2:	mov    QWORD PTR [rsp+0x8],rbx
     da7:	mov    QWORD PTR [rsp+0x10],r12
     dac:	mov    QWORD PTR [rsp+0x18],rax
     db1:	mov    r15,rax
     db4:	jmp    c1b <botlish_fn_8+0x43>
     db9:	mov    rax,r15
     dbc:	mov    rbx,QWORD PTR [rsp+0x40]
     dc1:	mov    r12,QWORD PTR [rsp+0x48]
     dc6:	mov    r13,QWORD PTR [rsp+0x50]
     dcb:	mov    r14,QWORD PTR [rsp+0x58]
     dd0:	mov    r15,QWORD PTR [rsp+0x60]
     dd5:	add    rsp,0x70
     dd9:	mov    rsp,rbp
     ddc:	pop    rbp
     ddd:	ret
     dde:	add    BYTE PTR [rax],al
     de0:	(bad)
     de1:	add    BYTE PTR [rax],al
     de3:	add    BYTE PTR [rax],al
     de5:	add    BYTE PTR [rax],al
	...

0000000000000de8 <botlish_entry_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
     de8:	push   rbp
     de9:	mov    rbp,rsp
     dec:	mov    rsi,QWORD PTR [rdx]
     def:	mov    r9,QWORD PTR [rdx+0x8]
     df3:	mov    rcx,QWORD PTR [rdx+0x10]
     df7:	mov    r8,QWORD PTR [rdx+0x18]
     dfb:	mov    rdx,r9
     dfe:	call   e03 <botlish_entry_8+0x1b>
			dff: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
     e03:	mov    rsp,rbp
     e06:	pop    rbp
     e07:	ret

0000000000000e08 <botlish_fn_9: chunked_finish<list[list<never>, mutarray, int]>>:
     e08:	push   rbp
     e09:	mov    rbp,rsp
     e0c:	sub    rsp,0x70
     e10:	mov    QWORD PTR [rsp+0x40],rbx
     e15:	mov    QWORD PTR [rsp+0x48],r12
     e1a:	mov    QWORD PTR [rsp+0x50],r13
     e1f:	mov    QWORD PTR [rsp+0x58],r14
     e24:	mov    QWORD PTR [rsp+0x60],r15
     e29:	mov    r13,rdi
     e2c:	mov    QWORD PTR [rsp+0x20],0x0
     e35:	mov    QWORD PTR [rsp+0x28],0x0
     e3e:	mov    QWORD PTR [rsp+0x30],0x0
     e47:	mov    QWORD PTR [rsp],rsi
     e4b:	mov    r15,rsi
     e4e:	mov    QWORD PTR [rsp+0x8],rdx
     e53:	mov    r14,rdx
     e56:	mov    QWORD PTR [rsp+0x10],rcx
     e5b:	mov    r12,rcx
     e5e:	mov    rsi,r15
     e61:	mov    rdi,r13
     e64:	call   e69 <botlish_fn_9+0x61>
			e65: R_X86_64_PLT32	rt_list_len-0x4
     e69:	mov    QWORD PTR [rsp+0x18],rax
     e6e:	mov    rbx,rax
     e71:	mov    rdi,r13
     e74:	call   e79 <botlish_fn_9+0x71>
			e75: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     e79:	test   rax,rax
     e7c:	je     fc3 <botlish_fn_9+0x1bb>
     e82:	mov    QWORD PTR [rsp+0x20],rax
     e87:	mov    rcx,rbx
     e8a:	mov    rdx,rcx
     e8d:	and    rdx,rax
     e90:	mov    rsi,rax
     e93:	test   rdx,0x1
     e9a:	jne    eab <botlish_fn_9+0xa3>
     ea0:	mov    rdx,rsi
     ea3:	mov    rsi,rcx
     ea6:	jmp    ee0 <botlish_fn_9+0xd8>
     eab:	mov    rax,rcx
     eae:	sar    rax,1
     eb1:	mov    rbx,rcx
     eb4:	mov    r9,rsi
     eb7:	lea    rcx,[r9-0x1]
     ebb:	imul   rcx
     ebe:	seto   cl
     ec1:	or     rax,0x1
     ec5:	test   cl,cl
     ec7:	je     ed8 <botlish_fn_9+0xd0>
     ecd:	mov    rdx,rsi
     ed0:	mov    rsi,rbx
     ed3:	jmp    ee0 <botlish_fn_9+0xd8>
     ed8:	mov    rsi,rax
     edb:	jmp    eeb <botlish_fn_9+0xe3>
     ee0:	mov    rdi,r13
     ee3:	call   ee8 <botlish_fn_9+0xe0>
			ee4: R_X86_64_PLT32	rt_int_mul-0x4
     ee8:	mov    rsi,rax
     eeb:	mov    QWORD PTR [rsp+0x18],rsi
     ef0:	mov    rax,rsi
     ef3:	and    rax,r12
     ef6:	test   rax,0x1
     efc:	je     f18 <botlish_fn_9+0x110>
     f02:	lea    rcx,[r12-0x1]
     f07:	mov    rbx,rsi
     f0a:	add    rbx,rcx
     f0d:	seto   al
     f10:	test   al,al
     f12:	je     f26 <botlish_fn_9+0x11e>
     f18:	mov    rdx,r12
     f1b:	mov    rdi,r13
     f1e:	call   f23 <botlish_fn_9+0x11b>
			f1f: R_X86_64_PLT32	rt_int_add-0x4
     f23:	mov    rbx,rax
     f26:	mov    QWORD PTR [rsp+0x18],rbx
     f2b:	mov    rsi,rbx
     f2e:	mov    rdi,r13
     f31:	call   f36 <botlish_fn_9+0x12e>
			f32: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     f36:	mov    rcx,rax
     f39:	mov    QWORD PTR [rsp+0x38],rax
     f3e:	test   rax,rcx
     f41:	je     fc3 <botlish_fn_9+0x1bb>
     f47:	mov    rax,QWORD PTR [rsp+0x38]
     f4c:	mov    QWORD PTR [rsp+0x20],rax
     f51:	mov    r8d,0x1
     f57:	mov    QWORD PTR [rsp+0x28],0x1
     f60:	mov    QWORD PTR [rsp+0x30],0x1
     f69:	mov    rsi,r15
     f6c:	mov    rcx,QWORD PTR [rsp+0x38]
     f71:	mov    rdi,r13
     f74:	mov    rdx,r8
     f77:	call   f7c <botlish_fn_9+0x174>
			f78: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
     f7c:	test   rax,rax
     f7f:	mov    rdx,rax
     f82:	je     fc3 <botlish_fn_9+0x1bb>
     f88:	mov    r8d,0x1
     f8e:	mov    rcx,r14
     f91:	mov    r9,r12
     f94:	mov    rsi,QWORD PTR [rsp+0x38]
     f99:	mov    rdi,r13
     f9c:	call   fa1 <botlish_fn_9+0x199>
			f9d: R_X86_64_PLT32	rt_mutarray_copy-0x4
     fa1:	test   rax,rax
     fa4:	je     fc3 <botlish_fn_9+0x1bb>
     faa:	mov    rdx,rbx
     fad:	mov    rsi,QWORD PTR [rsp+0x38]
     fb2:	mov    rdi,r13
     fb5:	call   fba <botlish_fn_9+0x1b2>
			fb6: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     fba:	test   rax,rax
     fbd:	jne    fe8 <botlish_fn_9+0x1e0>
     fc3:	xor    rax,rax
     fc6:	mov    rbx,QWORD PTR [rsp+0x40]
     fcb:	mov    r12,QWORD PTR [rsp+0x48]
     fd0:	mov    r13,QWORD PTR [rsp+0x50]
     fd5:	mov    r14,QWORD PTR [rsp+0x58]
     fda:	mov    r15,QWORD PTR [rsp+0x60]
     fdf:	add    rsp,0x70
     fe3:	mov    rsp,rbp
     fe6:	pop    rbp
     fe7:	ret
     fe8:	mov    rbx,QWORD PTR [rsp+0x40]
     fed:	mov    r12,QWORD PTR [rsp+0x48]
     ff2:	mov    r13,QWORD PTR [rsp+0x50]
     ff7:	mov    r14,QWORD PTR [rsp+0x58]
     ffc:	mov    r15,QWORD PTR [rsp+0x60]
    1001:	add    rsp,0x70
    1005:	mov    rsp,rbp
    1008:	pop    rbp
    1009:	ret

000000000000100a <botlish_entry_9: chunked_finish<list[list<never>, mutarray, int]>>:
    100a:	push   rbp
    100b:	mov    rbp,rsp
    100e:	mov    rsi,QWORD PTR [rdx]
    1011:	mov    r8,QWORD PTR [rdx+0x8]
    1015:	mov    rcx,QWORD PTR [rdx+0x10]
    1019:	mov    rdx,r8
    101c:	call   1021 <botlish_entry_9+0x17>
			101d: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    1021:	mov    rsp,rbp
    1024:	pop    rbp
    1025:	ret

0000000000001026 <botlish_fn_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    1026:	push   rbp
    1027:	mov    rbp,rsp
    102a:	sub    rsp,0x70
    102e:	mov    QWORD PTR [rsp+0x40],rbx
    1033:	mov    QWORD PTR [rsp+0x48],r12
    1038:	mov    QWORD PTR [rsp+0x50],r13
    103d:	mov    QWORD PTR [rsp+0x58],r14
    1042:	mov    QWORD PTR [rsp+0x60],r15
    1047:	mov    r13,rdi
    104a:	mov    QWORD PTR [rsp+0x20],0x0
    1053:	mov    QWORD PTR [rsp+0x28],0x0
    105c:	mov    QWORD PTR [rsp+0x30],0x0
    1065:	mov    QWORD PTR [rsp],rsi
    1069:	mov    r15,rsi
    106c:	mov    QWORD PTR [rsp+0x8],rdx
    1071:	mov    r14,rdx
    1074:	mov    QWORD PTR [rsp+0x10],rcx
    1079:	mov    r12,rcx
    107c:	mov    rsi,r15
    107f:	mov    rdi,r13
    1082:	call   1087 <botlish_fn_10+0x61>
			1083: R_X86_64_PLT32	rt_list_len-0x4
    1087:	mov    QWORD PTR [rsp+0x18],rax
    108c:	mov    rbx,rax
    108f:	mov    rdi,r13
    1092:	call   1097 <botlish_fn_10+0x71>
			1093: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    1097:	test   rax,rax
    109a:	je     11e1 <botlish_fn_10+0x1bb>
    10a0:	mov    QWORD PTR [rsp+0x20],rax
    10a5:	mov    rcx,rbx
    10a8:	mov    rdx,rcx
    10ab:	and    rdx,rax
    10ae:	mov    rsi,rax
    10b1:	test   rdx,0x1
    10b8:	jne    10c9 <botlish_fn_10+0xa3>
    10be:	mov    rdx,rsi
    10c1:	mov    rsi,rcx
    10c4:	jmp    10fe <botlish_fn_10+0xd8>
    10c9:	mov    rax,rcx
    10cc:	sar    rax,1
    10cf:	mov    rbx,rcx
    10d2:	mov    r9,rsi
    10d5:	lea    rcx,[r9-0x1]
    10d9:	imul   rcx
    10dc:	seto   cl
    10df:	or     rax,0x1
    10e3:	test   cl,cl
    10e5:	je     10f6 <botlish_fn_10+0xd0>
    10eb:	mov    rdx,rsi
    10ee:	mov    rsi,rbx
    10f1:	jmp    10fe <botlish_fn_10+0xd8>
    10f6:	mov    rsi,rax
    10f9:	jmp    1109 <botlish_fn_10+0xe3>
    10fe:	mov    rdi,r13
    1101:	call   1106 <botlish_fn_10+0xe0>
			1102: R_X86_64_PLT32	rt_int_mul-0x4
    1106:	mov    rsi,rax
    1109:	mov    QWORD PTR [rsp+0x18],rsi
    110e:	mov    rax,rsi
    1111:	and    rax,r12
    1114:	test   rax,0x1
    111a:	je     1136 <botlish_fn_10+0x110>
    1120:	lea    rcx,[r12-0x1]
    1125:	mov    rbx,rsi
    1128:	add    rbx,rcx
    112b:	seto   al
    112e:	test   al,al
    1130:	je     1144 <botlish_fn_10+0x11e>
    1136:	mov    rdx,r12
    1139:	mov    rdi,r13
    113c:	call   1141 <botlish_fn_10+0x11b>
			113d: R_X86_64_PLT32	rt_int_add-0x4
    1141:	mov    rbx,rax
    1144:	mov    QWORD PTR [rsp+0x18],rbx
    1149:	mov    rsi,rbx
    114c:	mov    rdi,r13
    114f:	call   1154 <botlish_fn_10+0x12e>
			1150: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1154:	mov    rcx,rax
    1157:	mov    QWORD PTR [rsp+0x38],rax
    115c:	test   rax,rcx
    115f:	je     11e1 <botlish_fn_10+0x1bb>
    1165:	mov    rax,QWORD PTR [rsp+0x38]
    116a:	mov    QWORD PTR [rsp+0x20],rax
    116f:	mov    r8d,0x1
    1175:	mov    QWORD PTR [rsp+0x28],0x1
    117e:	mov    QWORD PTR [rsp+0x30],0x1
    1187:	mov    rsi,r15
    118a:	mov    rcx,QWORD PTR [rsp+0x38]
    118f:	mov    rdi,r13
    1192:	mov    rdx,r8
    1195:	call   119a <botlish_fn_10+0x174>
			1196: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    119a:	test   rax,rax
    119d:	mov    rdx,rax
    11a0:	je     11e1 <botlish_fn_10+0x1bb>
    11a6:	mov    r8d,0x1
    11ac:	mov    rcx,r14
    11af:	mov    r9,r12
    11b2:	mov    rsi,QWORD PTR [rsp+0x38]
    11b7:	mov    rdi,r13
    11ba:	call   11bf <botlish_fn_10+0x199>
			11bb: R_X86_64_PLT32	rt_mutarray_copy-0x4
    11bf:	test   rax,rax
    11c2:	je     11e1 <botlish_fn_10+0x1bb>
    11c8:	mov    rdx,rbx
    11cb:	mov    rsi,QWORD PTR [rsp+0x38]
    11d0:	mov    rdi,r13
    11d3:	call   11d8 <botlish_fn_10+0x1b2>
			11d4: R_X86_64_PLT32	rt_mutarray_freeze-0x4
    11d8:	test   rax,rax
    11db:	jne    1206 <botlish_fn_10+0x1e0>
    11e1:	xor    rax,rax
    11e4:	mov    rbx,QWORD PTR [rsp+0x40]
    11e9:	mov    r12,QWORD PTR [rsp+0x48]
    11ee:	mov    r13,QWORD PTR [rsp+0x50]
    11f3:	mov    r14,QWORD PTR [rsp+0x58]
    11f8:	mov    r15,QWORD PTR [rsp+0x60]
    11fd:	add    rsp,0x70
    1201:	mov    rsp,rbp
    1204:	pop    rbp
    1205:	ret
    1206:	mov    rbx,QWORD PTR [rsp+0x40]
    120b:	mov    r12,QWORD PTR [rsp+0x48]
    1210:	mov    r13,QWORD PTR [rsp+0x50]
    1215:	mov    r14,QWORD PTR [rsp+0x58]
    121a:	mov    r15,QWORD PTR [rsp+0x60]
    121f:	add    rsp,0x70
    1223:	mov    rsp,rbp
    1226:	pop    rbp
    1227:	ret

0000000000001228 <botlish_entry_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    1228:	push   rbp
    1229:	mov    rbp,rsp
    122c:	mov    rsi,QWORD PTR [rdx]
    122f:	mov    r8,QWORD PTR [rdx+0x8]
    1233:	mov    rcx,QWORD PTR [rdx+0x10]
    1237:	mov    rdx,r8
    123a:	call   123f <botlish_entry_10+0x17>
			123b: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    123f:	mov    rsp,rbp
    1242:	pop    rbp
    1243:	ret
    1244:	add    BYTE PTR [rax],al
	...

0000000000001248 <botlish_fn_11: peek<str, int>>:
    1248:	push   rbp
    1249:	mov    rbp,rsp
    124c:	sub    rsp,0x40
    1250:	mov    QWORD PTR [rsp+0x20],rbx
    1255:	mov    QWORD PTR [rsp+0x28],r12
    125a:	mov    QWORD PTR [rsp+0x30],r13
    125f:	mov    r13,rdi
    1262:	mov    QWORD PTR [rsp],rsi
    1266:	mov    r12,rsi
    1269:	mov    QWORD PTR [rsp+0x8],rdx
    126e:	mov    rbx,rdx
    1271:	mov    rsi,r12
    1274:	mov    rdi,r13
    1277:	call   127c <botlish_fn_11+0x34>
			1278: R_X86_64_PLT32	rt_str_len-0x4
    127c:	mov    rcx,rbx
    127f:	and    rcx,rax
    1282:	mov    rdx,rax
    1285:	test   rcx,0x1
    128c:	jne    12b2 <botlish_fn_11+0x6a>
    1292:	mov    rsi,rbx
    1295:	mov    rdi,r13
    1298:	call   129d <botlish_fn_11+0x55>
			1299: R_X86_64_PLT32	rt_int_cmp-0x4
    129d:	mov    ecx,0x2
    12a2:	test   rax,rax
    12a5:	cmovge rcx,QWORD PTR [rip+0xd3]        # 1380 <botlish_fn_11+0x138>
    12ad:	jmp    12c2 <botlish_fn_11+0x7a>
    12b2:	mov    ecx,0x2
    12b7:	cmp    rbx,rdx
    12ba:	cmovge rcx,QWORD PTR [rip+0xbe]        # 1380 <botlish_fn_11+0x138>
    12c2:	cmp    rcx,0x6
    12c6:	je     1356 <botlish_fn_11+0x10e>
    12cc:	mov    QWORD PTR [rsp+0x10],0x3
    12d5:	test   rbx,0x1
    12dc:	je     12f4 <botlish_fn_11+0xac>
    12e2:	mov    rcx,rbx
    12e5:	add    rcx,0x2
    12e9:	seto   al
    12ec:	test   al,al
    12ee:	je     1307 <botlish_fn_11+0xbf>
    12f4:	mov    edx,0x3
    12f9:	mov    rsi,rbx
    12fc:	mov    rdi,r13
    12ff:	call   1304 <botlish_fn_11+0xbc>
			1300: R_X86_64_PLT32	rt_int_add-0x4
    1304:	mov    rcx,rax
    1307:	mov    QWORD PTR [rsp+0x10],rcx
    130c:	mov    rdx,rbx
    130f:	mov    rsi,r12
    1312:	mov    rdi,r13
    1315:	call   131a <botlish_fn_11+0xd2>
			1316: R_X86_64_PLT32	rt_substr-0x4
    131a:	test   rax,rax
    131d:	jne    133e <botlish_fn_11+0xf6>
    1323:	xor    rax,rax
    1326:	mov    rbx,QWORD PTR [rsp+0x20]
    132b:	mov    r12,QWORD PTR [rsp+0x28]
    1330:	mov    r13,QWORD PTR [rsp+0x30]
    1335:	add    rsp,0x40
    1339:	mov    rsp,rbp
    133c:	pop    rbp
    133d:	ret
    133e:	mov    rbx,QWORD PTR [rsp+0x20]
    1343:	mov    r12,QWORD PTR [rsp+0x28]
    1348:	mov    r13,QWORD PTR [rsp+0x30]
    134d:	add    rsp,0x40
    1351:	mov    rsp,rbp
    1354:	pop    rbp
    1355:	ret
    1356:	mov    rdi,r13
    1359:	mov    rax,QWORD PTR [rdi+0x10]
    135d:	mov    rax,QWORD PTR [rax+0x10]
    1361:	mov    rbx,QWORD PTR [rsp+0x20]
    1366:	mov    r12,QWORD PTR [rsp+0x28]
    136b:	mov    r13,QWORD PTR [rsp+0x30]
    1370:	add    rsp,0x40
    1374:	mov    rsp,rbp
    1377:	pop    rbp
    1378:	ret
    1379:	add    BYTE PTR [rax],al
    137b:	add    BYTE PTR [rax],al
    137d:	add    BYTE PTR [rax],al
    137f:	add    BYTE PTR [rsi],al
    1381:	add    BYTE PTR [rax],al
    1383:	add    BYTE PTR [rax],al
    1385:	add    BYTE PTR [rax],al
	...

0000000000001388 <botlish_entry_11: peek<str, int>>:
    1388:	push   rbp
    1389:	mov    rbp,rsp
    138c:	mov    rsi,QWORD PTR [rdx]
    138f:	mov    rdx,QWORD PTR [rdx+0x8]
    1393:	call   1398 <botlish_entry_11+0x10>
			1394: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1398:	mov    rsp,rbp
    139b:	pop    rbp
    139c:	ret
    139d:	add    BYTE PTR [rax],al
	...

00000000000013a0 <botlish_fn_12: peek<str, int>>:
    13a0:	push   rbp
    13a1:	mov    rbp,rsp
    13a4:	sub    rsp,0x50
    13a8:	mov    QWORD PTR [rsp+0x20],rbx
    13ad:	mov    QWORD PTR [rsp+0x28],r12
    13b2:	mov    QWORD PTR [rsp+0x30],r13
    13b7:	mov    QWORD PTR [rsp+0x38],r14
    13bc:	mov    QWORD PTR [rsp+0x40],r15
    13c1:	mov    r12,rcx
    13c4:	mov    r14,rdi
    13c7:	mov    QWORD PTR [rsp],rsi
    13cb:	mov    r13,rsi
    13ce:	mov    QWORD PTR [rsp+0x8],rdx
    13d3:	mov    rbx,rdx
    13d6:	mov    rsi,r13
    13d9:	mov    rdi,r14
    13dc:	call   13e1 <botlish_fn_12+0x41>
			13dd: R_X86_64_PLT32	rt_str_len-0x4
    13e1:	mov    rcx,rbx
    13e4:	and    rcx,rax
    13e7:	mov    rdx,rax
    13ea:	test   rcx,0x1
    13f1:	jne    1417 <botlish_fn_12+0x77>
    13f7:	mov    rsi,rbx
    13fa:	mov    rdi,r14
    13fd:	call   1402 <botlish_fn_12+0x62>
			13fe: R_X86_64_PLT32	rt_int_cmp-0x4
    1402:	mov    ecx,0x2
    1407:	test   rax,rax
    140a:	cmovge rcx,QWORD PTR [rip+0x11e]        # 1530 <botlish_fn_12+0x190>
    1412:	jmp    1427 <botlish_fn_12+0x87>
    1417:	mov    ecx,0x2
    141c:	cmp    rbx,rdx
    141f:	cmovge rcx,QWORD PTR [rip+0x109]        # 1530 <botlish_fn_12+0x190>
    1427:	cmp    rcx,0x6
    142b:	je     14eb <botlish_fn_12+0x14b>
    1431:	mov    QWORD PTR [rsp+0x10],0x3
    143a:	test   rbx,0x1
    1441:	je     1464 <botlish_fn_12+0xc4>
    1447:	mov    rax,rbx
    144a:	add    rax,0x2
    144e:	seto   cl
    1451:	test   cl,cl
    1453:	jne    1464 <botlish_fn_12+0xc4>
    1459:	mov    rdi,r14
    145c:	mov    r15,rax
    145f:	jmp    147a <botlish_fn_12+0xda>
    1464:	mov    edx,0x3
    1469:	mov    rsi,rbx
    146c:	mov    rdi,r14
    146f:	call   1474 <botlish_fn_12+0xd4>
			1470: R_X86_64_PLT32	rt_int_add-0x4
    1474:	mov    r15,rax
    1477:	mov    rdi,r14
    147a:	mov    rdi,r14
    147d:	mov    rcx,r15
    1480:	mov    rdx,rbx
    1483:	mov    rsi,r13
    1486:	call   148b <botlish_fn_12+0xeb>
			1487: R_X86_64_PLT32	rt_str_region_check-0x4
    148b:	test   rax,rax
    148e:	jne    14b9 <botlish_fn_12+0x119>
    1494:	xor    rax,rax
    1497:	mov    rbx,QWORD PTR [rsp+0x20]
    149c:	mov    r12,QWORD PTR [rsp+0x28]
    14a1:	mov    r13,QWORD PTR [rsp+0x30]
    14a6:	mov    r14,QWORD PTR [rsp+0x38]
    14ab:	mov    r15,QWORD PTR [rsp+0x40]
    14b0:	add    rsp,0x50
    14b4:	mov    rsp,rbp
    14b7:	pop    rbp
    14b8:	ret
    14b9:	mov    rcx,r12
    14bc:	mov    QWORD PTR [rcx],rbx
    14bf:	mov    rax,r15
    14c2:	mov    QWORD PTR [rcx+0x8],rax
    14c6:	mov    rax,r13
    14c9:	mov    rbx,QWORD PTR [rsp+0x20]
    14ce:	mov    r12,QWORD PTR [rsp+0x28]
    14d3:	mov    r13,QWORD PTR [rsp+0x30]
    14d8:	mov    r14,QWORD PTR [rsp+0x38]
    14dd:	mov    r15,QWORD PTR [rsp+0x40]
    14e2:	add    rsp,0x50
    14e6:	mov    rsp,rbp
    14e9:	pop    rbp
    14ea:	ret
    14eb:	mov    rcx,r12
    14ee:	mov    rdi,r14
    14f1:	mov    rax,QWORD PTR [rdi+0x10]
    14f5:	mov    rax,QWORD PTR [rax+0x10]
    14f9:	mov    QWORD PTR [rcx],0x1
    1500:	mov    QWORD PTR [rcx+0x8],0x1
    1508:	mov    rbx,QWORD PTR [rsp+0x20]
    150d:	mov    r12,QWORD PTR [rsp+0x28]
    1512:	mov    r13,QWORD PTR [rsp+0x30]
    1517:	mov    r14,QWORD PTR [rsp+0x38]
    151c:	mov    r15,QWORD PTR [rsp+0x40]
    1521:	add    rsp,0x50
    1525:	mov    rsp,rbp
    1528:	pop    rbp
    1529:	ret
    152a:	add    BYTE PTR [rax],al
    152c:	add    BYTE PTR [rax],al
    152e:	add    BYTE PTR [rax],al
    1530:	(bad)
    1531:	add    BYTE PTR [rax],al
    1533:	add    BYTE PTR [rax],al
    1535:	add    BYTE PTR [rax],al
	...

0000000000001538 <botlish_entry_12: peek<str, int>>:
    1538:	push   rbp
    1539:	mov    rbp,rsp
    153c:	ud2

000000000000153e <botlish_fn_13: scan_unquoted<str, int, int>>:
    153e:	push   rbp
    153f:	mov    rbp,rsp
    1542:	sub    rsp,0x80
    1549:	mov    QWORD PTR [rsp+0x50],rbx
    154e:	mov    QWORD PTR [rsp+0x58],r12
    1553:	mov    QWORD PTR [rsp+0x60],r13
    1558:	mov    QWORD PTR [rsp+0x68],r14
    155d:	mov    QWORD PTR [rsp+0x70],r15
    1562:	mov    QWORD PTR [rsp+0x30],rdi
    1567:	mov    QWORD PTR [rsp+0x18],0x0
    1570:	mov    QWORD PTR [rsp],rsi
    1574:	mov    r15,rsi
    1577:	mov    QWORD PTR [rsp+0x8],rdx
    157c:	mov    r14,rdx
    157f:	mov    QWORD PTR [rsp+0x10],rcx
    1584:	lea    r13,[rsp+0x20]
    1589:	mov    QWORD PTR [rsp+0x38],rcx
    158e:	mov    rcx,r13
    1591:	mov    rdx,QWORD PTR [rsp+0x38]
    1596:	mov    rsi,r15
    1599:	mov    rdi,QWORD PTR [rsp+0x30]
    159e:	call   15a3 <botlish_fn_13+0x65>
			159f: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    15a3:	mov    rsi,rax
    15a6:	mov    QWORD PTR [rsp+0x40],rax
    15ab:	test   rax,rsi
    15ae:	je     1708 <botlish_fn_13+0x1ca>
    15b4:	mov    rbx,QWORD PTR [rsp+0x20]
    15b9:	mov    r12,QWORD PTR [rsp+0x28]
    15be:	mov    rdi,QWORD PTR [rsp+0x30]
    15c3:	mov    rcx,QWORD PTR [rdi+0x10]
    15c7:	mov    r8,QWORD PTR [rcx+0x10]
    15cb:	mov    rcx,r12
    15ce:	mov    rdx,rbx
    15d1:	mov    rsi,QWORD PTR [rsp+0x40]
    15d6:	call   15db <botlish_fn_13+0x9d>
			15d7: R_X86_64_PLT32	rt_str_region_eq-0x4
    15db:	cmp    rax,0x6
    15df:	je     1620 <botlish_fn_13+0xe2>
    15e5:	mov    rdi,QWORD PTR [rsp+0x30]
    15ea:	mov    rax,QWORD PTR [rdi+0x10]
    15ee:	mov    r8,QWORD PTR [rax+0x18]
    15f2:	mov    rcx,r12
    15f5:	mov    rdx,rbx
    15f8:	mov    rsi,QWORD PTR [rsp+0x40]
    15fd:	call   1602 <botlish_fn_13+0xc4>
			15fe: R_X86_64_PLT32	rt_str_region_eq-0x4
    1602:	cmp    rax,0x6
    1606:	je     1616 <botlish_fn_13+0xd8>
    160c:	mov    eax,0x2
    1611:	jmp    1625 <botlish_fn_13+0xe7>
    1616:	mov    eax,0x6
    161b:	jmp    1625 <botlish_fn_13+0xe7>
    1620:	mov    eax,0x6
    1625:	cmp    rax,0x6
    1629:	je     166a <botlish_fn_13+0x12c>
    162f:	mov    rdi,QWORD PTR [rsp+0x30]
    1634:	mov    rax,QWORD PTR [rdi+0x10]
    1638:	mov    r8,QWORD PTR [rax+0x20]
    163c:	mov    rcx,r12
    163f:	mov    rdx,rbx
    1642:	mov    rsi,QWORD PTR [rsp+0x40]
    1647:	call   164c <botlish_fn_13+0x10e>
			1648: R_X86_64_PLT32	rt_str_region_eq-0x4
    164c:	cmp    rax,0x6
    1650:	je     1660 <botlish_fn_13+0x122>
    1656:	mov    eax,0x2
    165b:	jmp    166f <botlish_fn_13+0x131>
    1660:	mov    eax,0x6
    1665:	jmp    166f <botlish_fn_13+0x131>
    166a:	mov    eax,0x6
    166f:	cmp    rax,0x6
    1673:	je     16ea <botlish_fn_13+0x1ac>
    1679:	mov    QWORD PTR [rsp+0x18],0x3
    1682:	mov    rsi,QWORD PTR [rsp+0x38]
    1687:	test   rsi,0x1
    168e:	je     16b5 <botlish_fn_13+0x177>
    1694:	mov    rsi,QWORD PTR [rsp+0x38]
    1699:	mov    rax,rsi
    169c:	add    rax,0x2
    16a0:	seto   sil
    16a4:	test   sil,sil
    16a7:	jne    16b5 <botlish_fn_13+0x177>
    16ad:	mov    rsi,r15
    16b0:	jmp    16cc <botlish_fn_13+0x18e>
    16b5:	mov    edx,0x3
    16ba:	mov    rsi,QWORD PTR [rsp+0x38]
    16bf:	mov    rdi,QWORD PTR [rsp+0x30]
    16c4:	call   16c9 <botlish_fn_13+0x18b>
			16c5: R_X86_64_PLT32	rt_int_add-0x4
    16c9:	mov    rsi,r15
    16cc:	mov    QWORD PTR [rsp],rsi
    16d0:	mov    rdx,r14
    16d3:	mov    QWORD PTR [rsp+0x8],rdx
    16d8:	mov    QWORD PTR [rsp+0x10],rax
    16dd:	mov    r15,rsi
    16e0:	mov    QWORD PTR [rsp+0x38],rax
    16e5:	jmp    158e <botlish_fn_13+0x50>
    16ea:	mov    rdx,r14
    16ed:	mov    rsi,r15
    16f0:	mov    rdi,QWORD PTR [rsp+0x30]
    16f5:	mov    rcx,QWORD PTR [rsp+0x38]
    16fa:	call   16ff <botlish_fn_13+0x1c1>
			16fb: R_X86_64_PLT32	rt_substr-0x4
    16ff:	test   rax,rax
    1702:	jne    1733 <botlish_fn_13+0x1f5>
    1708:	xor    rdx,rdx
    170b:	mov    rax,rdx
    170e:	mov    rbx,QWORD PTR [rsp+0x50]
    1713:	mov    r12,QWORD PTR [rsp+0x58]
    1718:	mov    r13,QWORD PTR [rsp+0x60]
    171d:	mov    r14,QWORD PTR [rsp+0x68]
    1722:	mov    r15,QWORD PTR [rsp+0x70]
    1727:	add    rsp,0x80
    172e:	mov    rsp,rbp
    1731:	pop    rbp
    1732:	ret
    1733:	mov    rdx,QWORD PTR [rsp+0x38]
    1738:	mov    rbx,QWORD PTR [rsp+0x50]
    173d:	mov    r12,QWORD PTR [rsp+0x58]
    1742:	mov    r13,QWORD PTR [rsp+0x60]
    1747:	mov    r14,QWORD PTR [rsp+0x68]
    174c:	mov    r15,QWORD PTR [rsp+0x70]
    1751:	add    rsp,0x80
    1758:	mov    rsp,rbp
    175b:	pop    rbp
    175c:	ret

000000000000175d <botlish_entry_13: scan_unquoted<str, int, int>>:
    175d:	push   rbp
    175e:	mov    rbp,rsp
    1761:	ud2

0000000000001763 <botlish_fn_14: scan_quoted<str, int, str>>:
    1763:	push   rbp
    1764:	mov    rbp,rsp
    1767:	sub    rsp,0x70
    176b:	mov    QWORD PTR [rsp+0x40],rbx
    1770:	mov    QWORD PTR [rsp+0x48],r12
    1775:	mov    QWORD PTR [rsp+0x50],r13
    177a:	mov    QWORD PTR [rsp+0x58],r14
    177f:	mov    QWORD PTR [rsp+0x60],r15
    1784:	mov    r13,rdi
    1787:	mov    QWORD PTR [rsp+0x18],0x0
    1790:	mov    QWORD PTR [rsp+0x20],0x0
    1799:	mov    QWORD PTR [rsp],rsi
    179d:	mov    QWORD PTR [rsp+0x8],rdx
    17a2:	mov    QWORD PTR [rsp+0x10],rcx
    17a7:	lea    r12,[rsp+0x28]
    17ac:	mov    rbx,rsi
    17af:	mov    r14,rdx
    17b2:	mov    r15,rcx
    17b5:	mov    rdx,r14
    17b8:	mov    rsi,rbx
    17bb:	mov    rdi,r13
    17be:	call   17c3 <botlish_fn_14+0x60>
			17bf: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    17c3:	test   rax,rax
    17c6:	je     19e2 <botlish_fn_14+0x27f>
    17cc:	mov    QWORD PTR [rsp+0x18],rax
    17d1:	mov    rdi,r13
    17d4:	mov    QWORD PTR [rsp+0x38],rax
    17d9:	mov    rcx,QWORD PTR [rdi+0x10]
    17dd:	mov    rsi,QWORD PTR [rcx+0x28]
    17e1:	mov    edx,0x1
    17e6:	mov    ecx,0x3
    17eb:	mov    r8,QWORD PTR [rsp+0x38]
    17f0:	call   17f5 <botlish_fn_14+0x92>
			17f1: R_X86_64_PLT32	rt_str_region_eq-0x4
    17f5:	cmp    rax,0x6
    17f9:	je     187c <botlish_fn_14+0x119>
    17ff:	mov    QWORD PTR [rsp+0x20],0x3
    1808:	mov    rsi,r14
    180b:	test   rsi,0x1
    1812:	je     1832 <botlish_fn_14+0xcf>
    1818:	mov    rax,rsi
    181b:	add    rax,0x2
    181f:	seto   cl
    1822:	test   cl,cl
    1824:	jne    1832 <botlish_fn_14+0xcf>
    182a:	mov    rsi,rax
    182d:	jmp    1842 <botlish_fn_14+0xdf>
    1832:	mov    edx,0x3
    1837:	mov    rdi,r13
    183a:	call   183f <botlish_fn_14+0xdc>
			183b: R_X86_64_PLT32	rt_int_add-0x4
    183f:	mov    rsi,rax
    1842:	mov    QWORD PTR [rsp+0x8],rsi
    1847:	mov    r14,rsi
    184a:	mov    rsi,r15
    184d:	mov    rdx,QWORD PTR [rsp+0x38]
    1852:	mov    rdi,r13
    1855:	call   185a <botlish_fn_14+0xf7>
			1856: R_X86_64_PLT32	rt_str_cat-0x4
    185a:	test   rax,rax
    185d:	je     19e2 <botlish_fn_14+0x27f>
    1863:	mov    QWORD PTR [rsp],rbx
    1867:	mov    rsi,r14
    186a:	mov    QWORD PTR [rsp+0x8],rsi
    186f:	mov    QWORD PTR [rsp+0x10],rax
    1874:	mov    r15,rax
    1877:	jmp    17b5 <botlish_fn_14+0x52>
    187c:	mov    QWORD PTR [rsp+0x18],0x3
    1885:	mov    rsi,r14
    1888:	test   rsi,0x1
    188f:	je     18aa <botlish_fn_14+0x147>
    1895:	mov    rsi,r14
    1898:	mov    rdx,rsi
    189b:	add    rdx,0x2
    189f:	seto   al
    18a2:	test   al,al
    18a4:	je     18bd <botlish_fn_14+0x15a>
    18aa:	mov    edx,0x3
    18af:	mov    rsi,r14
    18b2:	mov    rdi,r13
    18b5:	call   18ba <botlish_fn_14+0x157>
			18b6: R_X86_64_PLT32	rt_int_add-0x4
    18ba:	mov    rdx,rax
    18bd:	mov    QWORD PTR [rsp+0x18],rdx
    18c2:	mov    rcx,r12
    18c5:	mov    rsi,rbx
    18c8:	mov    rdi,r13
    18cb:	call   18d0 <botlish_fn_14+0x16d>
			18cc: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    18d0:	test   rax,rax
    18d3:	mov    rsi,rax
    18d6:	je     19e2 <botlish_fn_14+0x27f>
    18dc:	mov    rdx,QWORD PTR [rsp+0x28]
    18e1:	mov    rcx,QWORD PTR [rsp+0x30]
    18e6:	mov    rdi,r13
    18e9:	mov    rax,QWORD PTR [rdi+0x10]
    18ed:	mov    r8,QWORD PTR [rax+0x28]
    18f1:	call   18f6 <botlish_fn_14+0x193>
			18f2: R_X86_64_PLT32	rt_str_region_eq-0x4
    18f6:	cmp    rax,0x6
    18fa:	je     196d <botlish_fn_14+0x20a>
    1900:	mov    QWORD PTR [rsp],0x3
    1908:	mov    rsi,r14
    190b:	test   rsi,0x1
    1912:	je     1935 <botlish_fn_14+0x1d2>
    1918:	mov    rsi,r14
    191b:	mov    rdx,rsi
    191e:	add    rdx,0x2
    1922:	seto   al
    1925:	test   al,al
    1927:	jne    1935 <botlish_fn_14+0x1d2>
    192d:	mov    rax,r15
    1930:	jmp    194b <botlish_fn_14+0x1e8>
    1935:	mov    edx,0x3
    193a:	mov    rsi,r14
    193d:	mov    rdi,r13
    1940:	call   1945 <botlish_fn_14+0x1e2>
			1941: R_X86_64_PLT32	rt_int_add-0x4
    1945:	mov    rdx,rax
    1948:	mov    rax,r15
    194b:	mov    rbx,QWORD PTR [rsp+0x40]
    1950:	mov    r12,QWORD PTR [rsp+0x48]
    1955:	mov    r13,QWORD PTR [rsp+0x50]
    195a:	mov    r14,QWORD PTR [rsp+0x58]
    195f:	mov    r15,QWORD PTR [rsp+0x60]
    1964:	add    rsp,0x70
    1968:	mov    rsp,rbp
    196b:	pop    rbp
    196c:	ret
    196d:	mov    QWORD PTR [rsp+0x18],0x5
    1976:	mov    rsi,r14
    1979:	test   rsi,0x1
    1980:	je     19a6 <botlish_fn_14+0x243>
    1986:	mov    rsi,r14
    1989:	mov    rax,rsi
    198c:	add    rax,0x4
    1990:	seto   cl
    1993:	test   cl,cl
    1995:	jne    19a6 <botlish_fn_14+0x243>
    199b:	mov    rsi,rax
    199e:	mov    r14,rax
    19a1:	jmp    19bc <botlish_fn_14+0x259>
    19a6:	mov    edx,0x5
    19ab:	mov    rsi,r14
    19ae:	mov    rdi,r13
    19b1:	call   19b6 <botlish_fn_14+0x253>
			19b2: R_X86_64_PLT32	rt_int_add-0x4
    19b6:	mov    rsi,rax
    19b9:	mov    r14,rax
    19bc:	mov    QWORD PTR [rsp+0x8],rsi
    19c1:	mov    rdi,r13
    19c4:	mov    rax,QWORD PTR [rdi+0x10]
    19c8:	mov    rdx,QWORD PTR [rax+0x28]
    19cc:	mov    QWORD PTR [rsp+0x18],rdx
    19d1:	mov    rsi,r15
    19d4:	call   19d9 <botlish_fn_14+0x276>
			19d5: R_X86_64_PLT32	rt_str_cat-0x4
    19d9:	test   rax,rax
    19dc:	jne    1a0a <botlish_fn_14+0x2a7>
    19e2:	xor    rdx,rdx
    19e5:	mov    rax,rdx
    19e8:	mov    rbx,QWORD PTR [rsp+0x40]
    19ed:	mov    r12,QWORD PTR [rsp+0x48]
    19f2:	mov    r13,QWORD PTR [rsp+0x50]
    19f7:	mov    r14,QWORD PTR [rsp+0x58]
    19fc:	mov    r15,QWORD PTR [rsp+0x60]
    1a01:	add    rsp,0x70
    1a05:	mov    rsp,rbp
    1a08:	pop    rbp
    1a09:	ret
    1a0a:	mov    QWORD PTR [rsp],rbx
    1a0e:	mov    rsi,r14
    1a11:	mov    QWORD PTR [rsp+0x8],rsi
    1a16:	mov    QWORD PTR [rsp+0x10],rax
    1a1b:	mov    r15,rax
    1a1e:	jmp    17b5 <botlish_fn_14+0x52>

0000000000001a23 <botlish_entry_14: scan_quoted<str, int, str>>:
    1a23:	push   rbp
    1a24:	mov    rbp,rsp
    1a27:	ud2

0000000000001a29 <botlish_fn_15: scan_field<str, int>>:
    1a29:	push   rbp
    1a2a:	mov    rbp,rsp
    1a2d:	sub    rsp,0x50
    1a31:	mov    QWORD PTR [rsp+0x30],rbx
    1a36:	mov    QWORD PTR [rsp+0x38],r12
    1a3b:	mov    QWORD PTR [rsp+0x40],r13
    1a40:	mov    r12,rdi
    1a43:	mov    r13,rdx
    1a46:	mov    QWORD PTR [rsp+0x10],0x0
    1a4f:	mov    QWORD PTR [rsp],rsi
    1a53:	mov    rbx,rsi
    1a56:	mov    QWORD PTR [rsp+0x8],rdx
    1a5b:	lea    rcx,[rsp+0x18]
    1a60:	mov    rdx,r13
    1a63:	mov    rsi,rbx
    1a66:	mov    rdi,r12
    1a69:	call   1a6e <botlish_fn_15+0x45>
			1a6a: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1a6e:	test   rax,rax
    1a71:	mov    rsi,rax
    1a74:	je     1b3f <botlish_fn_15+0x116>
    1a7a:	mov    rdx,QWORD PTR [rsp+0x18]
    1a7f:	mov    rcx,QWORD PTR [rsp+0x20]
    1a84:	mov    rdi,r12
    1a87:	mov    rax,QWORD PTR [rdi+0x10]
    1a8b:	mov    r8,QWORD PTR [rax+0x28]
    1a8f:	call   1a94 <botlish_fn_15+0x6b>
			1a90: R_X86_64_PLT32	rt_str_region_eq-0x4
    1a94:	cmp    rax,0x6
    1a98:	je     1ad0 <botlish_fn_15+0xa7>
    1a9e:	mov    rcx,r13
    1aa1:	mov    rsi,rbx
    1aa4:	mov    rdi,r12
    1aa7:	mov    rdx,rcx
    1aaa:	call   1aaf <botlish_fn_15+0x86>
			1aab: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    1aaf:	test   rax,rax
    1ab2:	je     1b3f <botlish_fn_15+0x116>
    1ab8:	mov    rbx,QWORD PTR [rsp+0x30]
    1abd:	mov    r12,QWORD PTR [rsp+0x38]
    1ac2:	mov    r13,QWORD PTR [rsp+0x40]
    1ac7:	add    rsp,0x50
    1acb:	mov    rsp,rbp
    1ace:	pop    rbp
    1acf:	ret
    1ad0:	mov    rcx,r13
    1ad3:	mov    QWORD PTR [rsp+0x10],0x3
    1adc:	test   rcx,0x1
    1ae3:	jne    1af1 <botlish_fn_15+0xc8>
    1ae9:	mov    r13,rcx
    1aec:	jmp    1b06 <botlish_fn_15+0xdd>
    1af1:	mov    rdx,rcx
    1af4:	add    rdx,0x2
    1af8:	mov    r13,rcx
    1afb:	seto   al
    1afe:	test   al,al
    1b00:	je     1b19 <botlish_fn_15+0xf0>
    1b06:	mov    edx,0x3
    1b0b:	mov    rsi,r13
    1b0e:	mov    rdi,r12
    1b11:	call   1b16 <botlish_fn_15+0xed>
			1b12: R_X86_64_PLT32	rt_int_add-0x4
    1b16:	mov    rdx,rax
    1b19:	mov    QWORD PTR [rsp+0x8],rdx
    1b1e:	mov    rdi,r12
    1b21:	mov    rax,QWORD PTR [rdi+0x10]
    1b25:	mov    rcx,QWORD PTR [rax+0x10]
    1b29:	mov    QWORD PTR [rsp+0x10],rcx
    1b2e:	mov    rsi,rbx
    1b31:	call   1b36 <botlish_fn_15+0x10d>
			1b32: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    1b36:	test   rax,rax
    1b39:	jne    1b5d <botlish_fn_15+0x134>
    1b3f:	xor    rdx,rdx
    1b42:	mov    rax,rdx
    1b45:	mov    rbx,QWORD PTR [rsp+0x30]
    1b4a:	mov    r12,QWORD PTR [rsp+0x38]
    1b4f:	mov    r13,QWORD PTR [rsp+0x40]
    1b54:	add    rsp,0x50
    1b58:	mov    rsp,rbp
    1b5b:	pop    rbp
    1b5c:	ret
    1b5d:	mov    rbx,QWORD PTR [rsp+0x30]
    1b62:	mov    r12,QWORD PTR [rsp+0x38]
    1b67:	mov    r13,QWORD PTR [rsp+0x40]
    1b6c:	add    rsp,0x50
    1b70:	mov    rsp,rbp
    1b73:	pop    rbp
    1b74:	ret

0000000000001b75 <botlish_entry_15: scan_field<str, int>>:
    1b75:	push   rbp
    1b76:	mov    rbp,rsp
    1b79:	ud2

0000000000001b7b <botlish_fn_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    1b7b:	push   rbp
    1b7c:	mov    rbp,rsp
    1b7f:	sub    rsp,0xa0
    1b86:	mov    QWORD PTR [rsp+0x70],rbx
    1b8b:	mov    QWORD PTR [rsp+0x78],r12
    1b90:	mov    QWORD PTR [rsp+0x80],r13
    1b98:	mov    QWORD PTR [rsp+0x88],r14
    1ba0:	mov    QWORD PTR [rsp+0x90],r15
    1ba8:	mov    r13,rdi
    1bab:	mov    QWORD PTR [rsp+0x28],0x0
    1bb4:	mov    QWORD PTR [rsp],rsi
    1bb8:	mov    r15,rsi
    1bbb:	mov    QWORD PTR [rsp+0x8],rdx
    1bc0:	mov    QWORD PTR [rsp+0x10],rcx
    1bc5:	mov    QWORD PTR [rsp+0x50],rcx
    1bca:	mov    QWORD PTR [rsp+0x18],r8
    1bcf:	mov    r12,r8
    1bd2:	mov    QWORD PTR [rsp+0x20],r9
    1bd7:	mov    rbx,r9
    1bda:	mov    rsi,r15
    1bdd:	mov    rdi,r13
    1be0:	call   1be5 <botlish_fn_16+0x6a>
			1be1: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    1be5:	test   rax,rax
    1be8:	je     1e1c <botlish_fn_16+0x2a1>
    1bee:	mov    QWORD PTR [rsp+0x8],rax
    1bf3:	mov    r8,rax
    1bf6:	mov    QWORD PTR [rsp+0x28],rdx
    1bfb:	mov    r14,rdx
    1bfe:	lea    r9,[rsp+0x30]
    1c03:	mov    rcx,rbx
    1c06:	mov    rdx,r12
    1c09:	mov    rsi,QWORD PTR [rsp+0x50]
    1c0e:	mov    rdi,r13
    1c11:	call   1c16 <botlish_fn_16+0x9b>
			1c12: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[list<never>, mutarray, int], str>
    1c16:	test   rax,rax
    1c19:	je     1e1c <botlish_fn_16+0x2a1>
    1c1f:	mov    QWORD PTR [rsp+0x8],rax
    1c24:	mov    QWORD PTR [rsp+0x68],rax
    1c29:	mov    rdx,QWORD PTR [rsp+0x30]
    1c2e:	mov    QWORD PTR [rsp+0x10],rdx
    1c33:	mov    QWORD PTR [rsp+0x60],rdx
    1c38:	mov    rcx,QWORD PTR [rsp+0x38]
    1c3d:	mov    QWORD PTR [rsp+0x18],rcx
    1c42:	mov    QWORD PTR [rsp+0x58],rcx
    1c47:	lea    rcx,[rsp+0x40]
    1c4c:	mov    rdx,r14
    1c4f:	mov    rsi,r15
    1c52:	mov    rdi,r13
    1c55:	call   1c5a <botlish_fn_16+0xdf>
			1c56: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1c5a:	test   rax,rax
    1c5d:	mov    QWORD PTR [rsp+0x50],rax
    1c62:	je     1e1c <botlish_fn_16+0x2a1>
    1c68:	mov    r12,QWORD PTR [rsp+0x40]
    1c6d:	mov    rbx,QWORD PTR [rsp+0x48]
    1c72:	mov    rdi,r13
    1c75:	mov    rcx,QWORD PTR [rdi+0x10]
    1c79:	mov    r8,QWORD PTR [rcx+0x18]
    1c7d:	mov    rcx,rbx
    1c80:	mov    rdx,r12
    1c83:	mov    rsi,QWORD PTR [rsp+0x50]
    1c88:	call   1c8d <botlish_fn_16+0x112>
			1c89: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c8d:	cmp    rax,0x6
    1c91:	je     1dab <botlish_fn_16+0x230>
    1c97:	mov    rdi,r13
    1c9a:	mov    rax,QWORD PTR [rdi+0x10]
    1c9e:	mov    r8,QWORD PTR [rax+0x20]
    1ca2:	mov    rcx,rbx
    1ca5:	mov    rdx,r12
    1ca8:	mov    rsi,QWORD PTR [rsp+0x50]
    1cad:	call   1cb2 <botlish_fn_16+0x137>
			1cae: R_X86_64_PLT32	rt_str_region_eq-0x4
    1cb2:	cmp    rax,0x6
    1cb6:	je     1d0d <botlish_fn_16+0x192>
    1cbc:	mov    rcx,QWORD PTR [rsp+0x58]
    1cc1:	mov    rdx,QWORD PTR [rsp+0x60]
    1cc6:	mov    rsi,QWORD PTR [rsp+0x68]
    1ccb:	mov    rdi,r13
    1cce:	call   1cd3 <botlish_fn_16+0x158>
			1ccf: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1cd3:	test   rax,rax
    1cd6:	je     1e1c <botlish_fn_16+0x2a1>
    1cdc:	mov    rdx,r14
    1cdf:	mov    rbx,QWORD PTR [rsp+0x70]
    1ce4:	mov    r12,QWORD PTR [rsp+0x78]
    1ce9:	mov    r13,QWORD PTR [rsp+0x80]
    1cf1:	mov    r14,QWORD PTR [rsp+0x88]
    1cf9:	mov    r15,QWORD PTR [rsp+0x90]
    1d01:	add    rsp,0xa0
    1d08:	mov    rsp,rbp
    1d0b:	pop    rbp
    1d0c:	ret
    1d0d:	mov    rcx,QWORD PTR [rsp+0x58]
    1d12:	mov    rdx,QWORD PTR [rsp+0x60]
    1d17:	mov    rsi,QWORD PTR [rsp+0x68]
    1d1c:	mov    rdi,r13
    1d1f:	call   1d24 <botlish_fn_16+0x1a9>
			1d20: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1d24:	test   rax,rax
    1d27:	je     1e1c <botlish_fn_16+0x2a1>
    1d2d:	mov    QWORD PTR [rsp],rax
    1d31:	mov    rbx,rax
    1d34:	mov    QWORD PTR [rsp+0x8],0x3
    1d3d:	mov    rdx,r14
    1d40:	test   rdx,0x1
    1d47:	je     1d67 <botlish_fn_16+0x1ec>
    1d4d:	mov    rdx,r14
    1d50:	add    rdx,0x2
    1d54:	seto   al
    1d57:	test   al,al
    1d59:	jne    1d67 <botlish_fn_16+0x1ec>
    1d5f:	mov    rax,rbx
    1d62:	jmp    1d7d <botlish_fn_16+0x202>
    1d67:	mov    edx,0x3
    1d6c:	mov    rsi,r14
    1d6f:	mov    rdi,r13
    1d72:	call   1d77 <botlish_fn_16+0x1fc>
			1d73: R_X86_64_PLT32	rt_int_add-0x4
    1d77:	mov    rdx,rax
    1d7a:	mov    rax,rbx
    1d7d:	mov    rbx,QWORD PTR [rsp+0x70]
    1d82:	mov    r12,QWORD PTR [rsp+0x78]
    1d87:	mov    r13,QWORD PTR [rsp+0x80]
    1d8f:	mov    r14,QWORD PTR [rsp+0x88]
    1d97:	mov    r15,QWORD PTR [rsp+0x90]
    1d9f:	add    rsp,0xa0
    1da6:	mov    rsp,rbp
    1da9:	pop    rbp
    1daa:	ret
    1dab:	mov    rsi,r14
    1dae:	mov    edx,0x3
    1db3:	mov    rcx,rdx
    1db6:	mov    QWORD PTR [rsp+0x20],0x3
    1dbf:	test   rsi,0x1
    1dc6:	jne    1dd4 <botlish_fn_16+0x259>
    1dcc:	mov    rdx,rcx
    1dcf:	jmp    1de9 <botlish_fn_16+0x26e>
    1dd4:	mov    rdx,rsi
    1dd7:	add    rdx,0x2
    1ddb:	seto   al
    1dde:	test   al,al
    1de0:	je     1df4 <botlish_fn_16+0x279>
    1de6:	mov    rdx,rcx
    1de9:	mov    rdi,r13
    1dec:	call   1df1 <botlish_fn_16+0x276>
			1ded: R_X86_64_PLT32	rt_int_add-0x4
    1df1:	mov    rdx,rax
    1df4:	mov    QWORD PTR [rsp+0x20],rdx
    1df9:	mov    rcx,QWORD PTR [rsp+0x68]
    1dfe:	mov    rsi,r15
    1e01:	mov    rdi,r13
    1e04:	mov    r8,QWORD PTR [rsp+0x60]
    1e09:	mov    r9,QWORD PTR [rsp+0x58]
    1e0e:	call   1e13 <botlish_fn_16+0x298>
			1e0f: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int, list[list<mutarray>, mutarray, int]>
    1e13:	test   rax,rax
    1e16:	jne    1e50 <botlish_fn_16+0x2d5>
    1e1c:	xor    rdx,rdx
    1e1f:	mov    rax,rdx
    1e22:	mov    rbx,QWORD PTR [rsp+0x70]
    1e27:	mov    r12,QWORD PTR [rsp+0x78]
    1e2c:	mov    r13,QWORD PTR [rsp+0x80]
    1e34:	mov    r14,QWORD PTR [rsp+0x88]
    1e3c:	mov    r15,QWORD PTR [rsp+0x90]
    1e44:	add    rsp,0xa0
    1e4b:	mov    rsp,rbp
    1e4e:	pop    rbp
    1e4f:	ret
    1e50:	mov    rbx,QWORD PTR [rsp+0x70]
    1e55:	mov    r12,QWORD PTR [rsp+0x78]
    1e5a:	mov    r13,QWORD PTR [rsp+0x80]
    1e62:	mov    r14,QWORD PTR [rsp+0x88]
    1e6a:	mov    r15,QWORD PTR [rsp+0x90]
    1e72:	add    rsp,0xa0
    1e79:	mov    rsp,rbp
    1e7c:	pop    rbp
    1e7d:	ret

0000000000001e7e <botlish_entry_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    1e7e:	push   rbp
    1e7f:	mov    rbp,rsp
    1e82:	ud2

0000000000001e84 <botlish_fn_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    1e84:	push   rbp
    1e85:	mov    rbp,rsp
    1e88:	sub    rsp,0xb0
    1e8f:	mov    QWORD PTR [rsp+0x80],rbx
    1e97:	mov    QWORD PTR [rsp+0x88],r12
    1e9f:	mov    QWORD PTR [rsp+0x90],r13
    1ea7:	mov    QWORD PTR [rsp+0x98],r14
    1eaf:	mov    QWORD PTR [rsp+0xa0],r15
    1eb7:	mov    QWORD PTR [rsp+0x50],rdi
    1ebc:	mov    QWORD PTR [rsp+0x28],0x0
    1ec5:	mov    QWORD PTR [rsp],rsi
    1ec9:	mov    QWORD PTR [rsp+0x8],rdx
    1ece:	mov    QWORD PTR [rsp+0x10],rcx
    1ed3:	mov    QWORD PTR [rsp+0x18],r8
    1ed8:	mov    QWORD PTR [rsp+0x20],r9
    1edd:	lea    r15,[rsp+0x30]
    1ee2:	lea    rbx,[rsp+0x40]
    1ee7:	mov    r12,rsi
    1eea:	mov    r13,rcx
    1eed:	mov    QWORD PTR [rsp+0x58],r8
    1ef2:	mov    QWORD PTR [rsp+0x60],r9
    1ef7:	mov    rsi,r12
    1efa:	mov    rdi,QWORD PTR [rsp+0x50]
    1eff:	call   1f04 <botlish_fn_17+0x80>
			1f00: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    1f04:	mov    QWORD PTR [rsp+0x78],rdx
    1f09:	test   rax,rax
    1f0c:	je     2067 <botlish_fn_17+0x1e3>
    1f12:	mov    QWORD PTR [rsp+0x8],rax
    1f17:	mov    rdx,QWORD PTR [rsp+0x78]
    1f1c:	mov    r8,rax
    1f1f:	mov    QWORD PTR [rsp+0x28],rdx
    1f24:	mov    rcx,QWORD PTR [rsp+0x60]
    1f29:	mov    rdx,QWORD PTR [rsp+0x58]
    1f2e:	mov    rsi,r13
    1f31:	mov    rdi,QWORD PTR [rsp+0x50]
    1f36:	mov    r9,r15
    1f39:	call   1f3e <botlish_fn_17+0xba>
			1f3a: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], str>
    1f3e:	test   rax,rax
    1f41:	je     2067 <botlish_fn_17+0x1e3>
    1f47:	mov    QWORD PTR [rsp+0x8],rax
    1f4c:	mov    QWORD PTR [rsp+0x70],rax
    1f51:	mov    rdx,QWORD PTR [rsp+0x30]
    1f56:	mov    QWORD PTR [rsp+0x58],rdx
    1f5b:	mov    QWORD PTR [rsp+0x10],rdx
    1f60:	mov    rcx,QWORD PTR [rsp+0x38]
    1f65:	mov    QWORD PTR [rsp+0x18],rcx
    1f6a:	mov    QWORD PTR [rsp+0x60],rcx
    1f6f:	mov    rcx,rbx
    1f72:	mov    rdx,QWORD PTR [rsp+0x78]
    1f77:	mov    rsi,r12
    1f7a:	mov    rdi,QWORD PTR [rsp+0x50]
    1f7f:	call   1f84 <botlish_fn_17+0x100>
			1f80: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1f84:	test   rax,rax
    1f87:	mov    QWORD PTR [rsp+0x68],rax
    1f8c:	je     2067 <botlish_fn_17+0x1e3>
    1f92:	mov    r13,QWORD PTR [rsp+0x40]
    1f97:	mov    r14,QWORD PTR [rsp+0x48]
    1f9c:	mov    rdi,QWORD PTR [rsp+0x50]
    1fa1:	mov    rcx,QWORD PTR [rdi+0x10]
    1fa5:	mov    r8,QWORD PTR [rcx+0x18]
    1fa9:	mov    rcx,r14
    1fac:	mov    rdx,r13
    1faf:	mov    rsi,QWORD PTR [rsp+0x68]
    1fb4:	call   1fb9 <botlish_fn_17+0x135>
			1fb5: R_X86_64_PLT32	rt_str_region_eq-0x4
    1fb9:	cmp    rax,0x6
    1fbd:	je     212d <botlish_fn_17+0x2a9>
    1fc3:	mov    rdi,QWORD PTR [rsp+0x50]
    1fc8:	mov    rax,QWORD PTR [rdi+0x10]
    1fcc:	mov    r8,QWORD PTR [rax+0x20]
    1fd0:	mov    rcx,r14
    1fd3:	mov    rdx,r13
    1fd6:	mov    rsi,QWORD PTR [rsp+0x68]
    1fdb:	call   1fe0 <botlish_fn_17+0x15c>
			1fdc: R_X86_64_PLT32	rt_str_region_eq-0x4
    1fe0:	cmp    rax,0x6
    1fe4:	je     2045 <botlish_fn_17+0x1c1>
    1fea:	mov    rcx,QWORD PTR [rsp+0x60]
    1fef:	mov    rdx,QWORD PTR [rsp+0x58]
    1ff4:	mov    rsi,QWORD PTR [rsp+0x70]
    1ff9:	mov    rdi,QWORD PTR [rsp+0x50]
    1ffe:	call   2003 <botlish_fn_17+0x17f>
			1fff: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2003:	test   rax,rax
    2006:	je     2067 <botlish_fn_17+0x1e3>
    200c:	mov    rdx,QWORD PTR [rsp+0x78]
    2011:	mov    rbx,QWORD PTR [rsp+0x80]
    2019:	mov    r12,QWORD PTR [rsp+0x88]
    2021:	mov    r13,QWORD PTR [rsp+0x90]
    2029:	mov    r14,QWORD PTR [rsp+0x98]
    2031:	mov    r15,QWORD PTR [rsp+0xa0]
    2039:	add    rsp,0xb0
    2040:	mov    rsp,rbp
    2043:	pop    rbp
    2044:	ret
    2045:	mov    rcx,QWORD PTR [rsp+0x60]
    204a:	mov    rdx,QWORD PTR [rsp+0x58]
    204f:	mov    rsi,QWORD PTR [rsp+0x70]
    2054:	mov    rdi,QWORD PTR [rsp+0x50]
    2059:	call   205e <botlish_fn_17+0x1da>
			205a: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    205e:	test   rax,rax
    2061:	jne    20a1 <botlish_fn_17+0x21d>
    2067:	xor    rdx,rdx
    206a:	mov    rax,rdx
    206d:	mov    rbx,QWORD PTR [rsp+0x80]
    2075:	mov    r12,QWORD PTR [rsp+0x88]
    207d:	mov    r13,QWORD PTR [rsp+0x90]
    2085:	mov    r14,QWORD PTR [rsp+0x98]
    208d:	mov    r15,QWORD PTR [rsp+0xa0]
    2095:	add    rsp,0xb0
    209c:	mov    rsp,rbp
    209f:	pop    rbp
    20a0:	ret
    20a1:	mov    QWORD PTR [rsp],rax
    20a5:	mov    rbx,rax
    20a8:	mov    QWORD PTR [rsp+0x8],0x3
    20b1:	mov    rdx,QWORD PTR [rsp+0x78]
    20b6:	test   rdx,0x1
    20bd:	je     20df <botlish_fn_17+0x25b>
    20c3:	mov    rdx,QWORD PTR [rsp+0x78]
    20c8:	add    rdx,0x2
    20cc:	seto   al
    20cf:	test   al,al
    20d1:	jne    20df <botlish_fn_17+0x25b>
    20d7:	mov    rax,rbx
    20da:	jmp    20f9 <botlish_fn_17+0x275>
    20df:	mov    edx,0x3
    20e4:	mov    rsi,QWORD PTR [rsp+0x78]
    20e9:	mov    rdi,QWORD PTR [rsp+0x50]
    20ee:	call   20f3 <botlish_fn_17+0x26f>
			20ef: R_X86_64_PLT32	rt_int_add-0x4
    20f3:	mov    rdx,rax
    20f6:	mov    rax,rbx
    20f9:	mov    rbx,QWORD PTR [rsp+0x80]
    2101:	mov    r12,QWORD PTR [rsp+0x88]
    2109:	mov    r13,QWORD PTR [rsp+0x90]
    2111:	mov    r14,QWORD PTR [rsp+0x98]
    2119:	mov    r15,QWORD PTR [rsp+0xa0]
    2121:	add    rsp,0xb0
    2128:	mov    rsp,rbp
    212b:	pop    rbp
    212c:	ret
    212d:	mov    rsi,QWORD PTR [rsp+0x78]
    2132:	mov    edx,0x3
    2137:	mov    r10,rdx
    213a:	mov    QWORD PTR [rsp+0x20],0x3
    2143:	test   rsi,0x1
    214a:	jne    2158 <botlish_fn_17+0x2d4>
    2150:	mov    rdx,r10
    2153:	jmp    216d <botlish_fn_17+0x2e9>
    2158:	mov    rdx,rsi
    215b:	add    rdx,0x2
    215f:	seto   al
    2162:	test   al,al
    2164:	je     217a <botlish_fn_17+0x2f6>
    216a:	mov    rdx,r10
    216d:	mov    rdi,QWORD PTR [rsp+0x50]
    2172:	call   2177 <botlish_fn_17+0x2f3>
			2173: R_X86_64_PLT32	rt_int_add-0x4
    2177:	mov    rdx,rax
    217a:	mov    QWORD PTR [rsp],r12
    217e:	mov    QWORD PTR [rsp+0x8],rdx
    2183:	mov    rsi,QWORD PTR [rsp+0x70]
    2188:	mov    QWORD PTR [rsp+0x10],rsi
    218d:	mov    rax,QWORD PTR [rsp+0x58]
    2192:	mov    QWORD PTR [rsp+0x18],rax
    2197:	mov    rcx,QWORD PTR [rsp+0x60]
    219c:	mov    QWORD PTR [rsp+0x20],rcx
    21a1:	mov    r13,rsi
    21a4:	jmp    1ef7 <botlish_fn_17+0x73>

00000000000021a9 <botlish_entry_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    21a9:	push   rbp
    21aa:	mov    rbp,rsp
    21ad:	ud2

00000000000021af <botlish_fn_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    21af:	push   rbp
    21b0:	mov    rbp,rsp
    21b3:	sub    rsp,0xa0
    21ba:	mov    QWORD PTR [rsp+0x70],rbx
    21bf:	mov    QWORD PTR [rsp+0x78],r12
    21c4:	mov    QWORD PTR [rsp+0x80],r13
    21cc:	mov    QWORD PTR [rsp+0x88],r14
    21d4:	mov    QWORD PTR [rsp+0x90],r15
    21dc:	mov    r12,rdi
    21df:	mov    QWORD PTR [rsp+0x28],0x0
    21e8:	mov    QWORD PTR [rsp+0x30],0x0
    21f1:	mov    QWORD PTR [rsp+0x38],0x0
    21fa:	mov    QWORD PTR [rsp],rsi
    21fe:	mov    rbx,rsi
    2201:	mov    QWORD PTR [rsp+0x8],rdx
    2206:	mov    QWORD PTR [rsp+0x60],rdx
    220b:	mov    QWORD PTR [rsp+0x10],rcx
    2210:	mov    r15,rcx
    2213:	mov    QWORD PTR [rsp+0x18],r8
    2218:	mov    r14,r8
    221b:	mov    QWORD PTR [rsp+0x20],r9
    2220:	mov    r13,r9
    2223:	mov    rsi,rbx
    2226:	mov    rdi,r12
    2229:	call   222e <botlish_fn_18+0x7f>
			222a: R_X86_64_PLT32	rt_str_len-0x4
    222e:	mov    rdx,QWORD PTR [rsp+0x60]
    2233:	mov    rcx,rdx
    2236:	sar    rcx,1
    2239:	sar    rax,1
    223c:	cmp    rcx,rax
    223f:	jge    2324 <botlish_fn_18+0x175>
    2245:	lea    rsi,[rsp+0x40]
    224a:	mov    rdi,r12
    224d:	call   2252 <botlish_fn_18+0xa3>
			224e: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    2252:	test   rax,rax
    2255:	je     233e <botlish_fn_18+0x18f>
    225b:	mov    QWORD PTR [rsp+0x28],rax
    2260:	mov    rcx,rax
    2263:	mov    r8,QWORD PTR [rsp+0x40]
    2268:	mov    QWORD PTR [rsp+0x30],r8
    226d:	mov    r9,QWORD PTR [rsp+0x48]
    2272:	mov    QWORD PTR [rsp+0x38],r9
    2277:	mov    rdx,QWORD PTR [rsp+0x60]
    227c:	mov    rsi,rbx
    227f:	mov    rdi,r12
    2282:	call   2287 <botlish_fn_18+0xd8>
			2283: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    2287:	test   rax,rax
    228a:	je     233e <botlish_fn_18+0x18f>
    2290:	mov    QWORD PTR [rsp+0x8],rax
    2295:	mov    r8,rax
    2298:	mov    QWORD PTR [rsp+0x28],rdx
    229d:	mov    QWORD PTR [rsp+0x60],rdx
    22a2:	lea    r9,[rsp+0x50]
    22a7:	mov    rcx,r13
    22aa:	mov    rdx,r14
    22ad:	mov    rsi,r15
    22b0:	mov    rdi,r12
    22b3:	call   22b8 <botlish_fn_18+0x109>
			22b4: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[list<never>, mutarray, int], list>
    22b8:	test   rax,rax
    22bb:	je     233e <botlish_fn_18+0x18f>
    22c1:	mov    QWORD PTR [rsp+0x8],rax
    22c6:	mov    rcx,rax
    22c9:	mov    r8,QWORD PTR [rsp+0x50]
    22ce:	mov    QWORD PTR [rsp+0x10],r8
    22d3:	mov    r9,QWORD PTR [rsp+0x58]
    22d8:	mov    QWORD PTR [rsp+0x18],r9
    22dd:	mov    rdx,QWORD PTR [rsp+0x60]
    22e2:	mov    rsi,rbx
    22e5:	mov    rdi,r12
    22e8:	call   22ed <botlish_fn_18+0x13e>
			22e9: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    22ed:	test   rax,rax
    22f0:	je     233e <botlish_fn_18+0x18f>
    22f6:	mov    rbx,QWORD PTR [rsp+0x70]
    22fb:	mov    r12,QWORD PTR [rsp+0x78]
    2300:	mov    r13,QWORD PTR [rsp+0x80]
    2308:	mov    r14,QWORD PTR [rsp+0x88]
    2310:	mov    r15,QWORD PTR [rsp+0x90]
    2318:	add    rsp,0xa0
    231f:	mov    rsp,rbp
    2322:	pop    rbp
    2323:	ret
    2324:	mov    rcx,r13
    2327:	mov    rdx,r14
    232a:	mov    rsi,r15
    232d:	mov    rdi,r12
    2330:	call   2335 <botlish_fn_18+0x186>
			2331: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    2335:	test   rax,rax
    2338:	jne    236f <botlish_fn_18+0x1c0>
    233e:	xor    rax,rax
    2341:	mov    rbx,QWORD PTR [rsp+0x70]
    2346:	mov    r12,QWORD PTR [rsp+0x78]
    234b:	mov    r13,QWORD PTR [rsp+0x80]
    2353:	mov    r14,QWORD PTR [rsp+0x88]
    235b:	mov    r15,QWORD PTR [rsp+0x90]
    2363:	add    rsp,0xa0
    236a:	mov    rsp,rbp
    236d:	pop    rbp
    236e:	ret
    236f:	mov    rbx,QWORD PTR [rsp+0x70]
    2374:	mov    r12,QWORD PTR [rsp+0x78]
    2379:	mov    r13,QWORD PTR [rsp+0x80]
    2381:	mov    r14,QWORD PTR [rsp+0x88]
    2389:	mov    r15,QWORD PTR [rsp+0x90]
    2391:	add    rsp,0xa0
    2398:	mov    rsp,rbp
    239b:	pop    rbp
    239c:	ret

000000000000239d <botlish_entry_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    239d:	push   rbp
    239e:	mov    rbp,rsp
    23a1:	mov    rsi,QWORD PTR [rdx]
    23a4:	mov    r10,QWORD PTR [rdx+0x8]
    23a8:	mov    rcx,QWORD PTR [rdx+0x10]
    23ac:	mov    r8,QWORD PTR [rdx+0x18]
    23b0:	mov    r9,QWORD PTR [rdx+0x20]
    23b4:	mov    rdx,r10
    23b7:	call   23bc <botlish_entry_18+0x1f>
			23b8: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    23bc:	mov    rsp,rbp
    23bf:	pop    rbp
    23c0:	ret
    23c1:	add    BYTE PTR [rax],al
    23c3:	add    BYTE PTR [rax],al
    23c5:	add    BYTE PTR [rax],al
	...

00000000000023c8 <botlish_fn_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    23c8:	push   rbp
    23c9:	mov    rbp,rsp
    23cc:	sub    rsp,0xb0
    23d3:	mov    QWORD PTR [rsp+0x80],rbx
    23db:	mov    QWORD PTR [rsp+0x88],r12
    23e3:	mov    QWORD PTR [rsp+0x90],r13
    23eb:	mov    QWORD PTR [rsp+0x98],r14
    23f3:	mov    QWORD PTR [rsp+0xa0],r15
    23fb:	mov    r15,rdi
    23fe:	mov    QWORD PTR [rsp+0x28],0x0
    2407:	mov    QWORD PTR [rsp+0x30],0x0
    2410:	mov    QWORD PTR [rsp+0x38],0x0
    2419:	mov    QWORD PTR [rsp],rsi
    241d:	mov    QWORD PTR [rsp+0x8],rdx
    2422:	mov    r14,rdx
    2425:	mov    QWORD PTR [rsp+0x10],rcx
    242a:	mov    QWORD PTR [rsp+0x18],r8
    242f:	mov    QWORD PTR [rsp+0x20],r9
    2434:	lea    r13,[rsp+0x40]
    2439:	lea    rbx,[rsp+0x50]
    243e:	mov    r12,rsi
    2441:	mov    QWORD PTR [rsp+0x60],rcx
    2446:	mov    QWORD PTR [rsp+0x68],r8
    244b:	mov    QWORD PTR [rsp+0x70],r9
    2450:	mov    rsi,r12
    2453:	mov    rdi,r15
    2456:	call   245b <botlish_fn_19+0x93>
			2457: R_X86_64_PLT32	rt_str_len-0x4
    245b:	mov    rcx,r14
    245e:	and    rcx,rax
    2461:	mov    rdx,rax
    2464:	test   rcx,0x1
    246b:	jne    2491 <botlish_fn_19+0xc9>
    2471:	mov    rsi,r14
    2474:	mov    rdi,r15
    2477:	call   247c <botlish_fn_19+0xb4>
			2478: R_X86_64_PLT32	rt_int_cmp-0x4
    247c:	mov    ecx,0x2
    2481:	test   rax,rax
    2484:	cmovge rcx,QWORD PTR [rip+0x164]        # 25f0 <botlish_fn_19+0x228>
    248c:	jmp    24a4 <botlish_fn_19+0xdc>
    2491:	mov    ecx,0x2
    2496:	mov    rdi,r14
    2499:	cmp    rdi,rdx
    249c:	cmovge rcx,QWORD PTR [rip+0x14c]        # 25f0 <botlish_fn_19+0x228>
    24a4:	cmp    rcx,0x6
    24a8:	je     2561 <botlish_fn_19+0x199>
    24ae:	mov    rsi,r13
    24b1:	mov    rdi,r15
    24b4:	call   24b9 <botlish_fn_19+0xf1>
			24b5: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    24b9:	test   rax,rax
    24bc:	je     2581 <botlish_fn_19+0x1b9>
    24c2:	mov    QWORD PTR [rsp+0x28],rax
    24c7:	mov    rcx,rax
    24ca:	mov    r8,QWORD PTR [rsp+0x40]
    24cf:	mov    QWORD PTR [rsp+0x30],r8
    24d4:	mov    r9,QWORD PTR [rsp+0x48]
    24d9:	mov    QWORD PTR [rsp+0x38],r9
    24de:	mov    rdx,r14
    24e1:	mov    rsi,r12
    24e4:	mov    rdi,r15
    24e7:	call   24ec <botlish_fn_19+0x124>
			24e8: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    24ec:	test   rax,rax
    24ef:	je     2581 <botlish_fn_19+0x1b9>
    24f5:	mov    QWORD PTR [rsp+0x8],rax
    24fa:	mov    r8,rax
    24fd:	mov    QWORD PTR [rsp+0x28],rdx
    2502:	mov    r14,rdx
    2505:	mov    rsi,QWORD PTR [rsp+0x60]
    250a:	mov    rdx,QWORD PTR [rsp+0x68]
    250f:	mov    rcx,QWORD PTR [rsp+0x70]
    2514:	mov    rdi,r15
    2517:	mov    r9,rbx
    251a:	call   251f <botlish_fn_19+0x157>
			251b: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], list>
    251f:	test   rax,rax
    2522:	je     2581 <botlish_fn_19+0x1b9>
    2528:	mov    rdx,QWORD PTR [rsp+0x50]
    252d:	mov    rcx,QWORD PTR [rsp+0x58]
    2532:	mov    QWORD PTR [rsp],r12
    2536:	mov    rsi,r14
    2539:	mov    QWORD PTR [rsp+0x8],rsi
    253e:	mov    QWORD PTR [rsp+0x10],rax
    2543:	mov    QWORD PTR [rsp+0x18],rdx
    2548:	mov    QWORD PTR [rsp+0x20],rcx
    254d:	mov    QWORD PTR [rsp+0x60],rax
    2552:	mov    QWORD PTR [rsp+0x68],rdx
    2557:	mov    QWORD PTR [rsp+0x70],rcx
    255c:	jmp    2450 <botlish_fn_19+0x88>
    2561:	mov    rcx,QWORD PTR [rsp+0x70]
    2566:	mov    rdx,QWORD PTR [rsp+0x68]
    256b:	mov    rsi,QWORD PTR [rsp+0x60]
    2570:	mov    rdi,r15
    2573:	call   2578 <botlish_fn_19+0x1b0>
			2574: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2578:	test   rax,rax
    257b:	jne    25b8 <botlish_fn_19+0x1f0>
    2581:	xor    rax,rax
    2584:	mov    rbx,QWORD PTR [rsp+0x80]
    258c:	mov    r12,QWORD PTR [rsp+0x88]
    2594:	mov    r13,QWORD PTR [rsp+0x90]
    259c:	mov    r14,QWORD PTR [rsp+0x98]
    25a4:	mov    r15,QWORD PTR [rsp+0xa0]
    25ac:	add    rsp,0xb0
    25b3:	mov    rsp,rbp
    25b6:	pop    rbp
    25b7:	ret
    25b8:	mov    rbx,QWORD PTR [rsp+0x80]
    25c0:	mov    r12,QWORD PTR [rsp+0x88]
    25c8:	mov    r13,QWORD PTR [rsp+0x90]
    25d0:	mov    r14,QWORD PTR [rsp+0x98]
    25d8:	mov    r15,QWORD PTR [rsp+0xa0]
    25e0:	add    rsp,0xb0
    25e7:	mov    rsp,rbp
    25ea:	pop    rbp
    25eb:	ret
    25ec:	add    BYTE PTR [rax],al
    25ee:	add    BYTE PTR [rax],al
    25f0:	(bad)
    25f1:	add    BYTE PTR [rax],al
    25f3:	add    BYTE PTR [rax],al
    25f5:	add    BYTE PTR [rax],al
	...

00000000000025f8 <botlish_entry_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    25f8:	push   rbp
    25f9:	mov    rbp,rsp
    25fc:	mov    rsi,QWORD PTR [rdx]
    25ff:	mov    r10,QWORD PTR [rdx+0x8]
    2603:	mov    rcx,QWORD PTR [rdx+0x10]
    2607:	mov    r8,QWORD PTR [rdx+0x18]
    260b:	mov    r9,QWORD PTR [rdx+0x20]
    260f:	mov    rdx,r10
    2612:	call   2617 <botlish_entry_19+0x1f>
			2613: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    2617:	mov    rsp,rbp
    261a:	pop    rbp
    261b:	ret

000000000000261c <botlish_fn_20: csv_parse<str>>:
    261c:	push   rbp
    261d:	mov    rbp,rsp
    2620:	sub    rsp,0x50
    2624:	mov    QWORD PTR [rsp+0x40],r12
    2629:	mov    QWORD PTR [rsp+0x48],r13
    262e:	mov    r13,rdi
    2631:	mov    QWORD PTR [rsp+0x10],0x0
    263a:	mov    QWORD PTR [rsp+0x18],0x0
    2643:	mov    QWORD PTR [rsp+0x20],0x0
    264c:	mov    QWORD PTR [rsp],rsi
    2650:	mov    r12,rsi
    2653:	mov    QWORD PTR [rsp+0x8],0x1
    265c:	lea    rsi,[rsp+0x28]
    2661:	mov    rdi,r13
    2664:	call   2669 <botlish_fn_20+0x4d>
			2665: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    2669:	test   rax,rax
    266c:	je     26a7 <botlish_fn_20+0x8b>
    2672:	mov    QWORD PTR [rsp+0x10],rax
    2677:	mov    rcx,rax
    267a:	mov    r8,QWORD PTR [rsp+0x28]
    267f:	mov    QWORD PTR [rsp+0x18],r8
    2684:	mov    r9,QWORD PTR [rsp+0x30]
    2689:	mov    QWORD PTR [rsp+0x20],r9
    268e:	mov    edx,0x1
    2693:	mov    rsi,r12
    2696:	mov    rdi,r13
    2699:	call   269e <botlish_fn_20+0x82>
			269a: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    269e:	test   rax,rax
    26a1:	jne    26bd <botlish_fn_20+0xa1>
    26a7:	xor    rax,rax
    26aa:	mov    r12,QWORD PTR [rsp+0x40]
    26af:	mov    r13,QWORD PTR [rsp+0x48]
    26b4:	add    rsp,0x50
    26b8:	mov    rsp,rbp
    26bb:	pop    rbp
    26bc:	ret
    26bd:	mov    r12,QWORD PTR [rsp+0x40]
    26c2:	mov    r13,QWORD PTR [rsp+0x48]
    26c7:	add    rsp,0x50
    26cb:	mov    rsp,rbp
    26ce:	pop    rbp
    26cf:	ret

00000000000026d0 <botlish_entry_20: csv_parse<str>>:
    26d0:	push   rbp
    26d1:	mov    rbp,rsp
    26d4:	mov    rsi,QWORD PTR [rdx]
    26d7:	call   26dc <botlish_entry_20+0xc>
			26d8: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    26dc:	mov    rsp,rbp
    26df:	pop    rbp
    26e0:	ret

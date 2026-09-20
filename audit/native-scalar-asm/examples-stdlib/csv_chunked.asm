; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10516  (per function: 68 28 212 574 574 574 574 664 592 588 588 365 430 585 770 352 799 833 537 612 197)
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
      9f:	je     dc <botlish_fn_2+0x7c>
      a5:	mov    QWORD PTR [rsp],rax
      a9:	mov    rbx,rax
      ac:	mov    rdi,r13
      af:	call   b4 <botlish_fn_2+0x54>
			b0: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
      b4:	test   rax,rax
      b7:	je     dc <botlish_fn_2+0x7c>
      bd:	mov    esi,0x81
      c2:	mov    QWORD PTR [rsp+0x8],0x81
      cb:	mov    rdi,r13
      ce:	call   d3 <botlish_fn_2+0x73>
			cf: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      d3:	test   rax,rax
      d6:	jne    f7 <botlish_fn_2+0x97>
      dc:	xor    rax,rax
      df:	mov    rbx,QWORD PTR [rsp+0x10]
      e4:	mov    r12,QWORD PTR [rsp+0x18]
      e9:	mov    r13,QWORD PTR [rsp+0x20]
      ee:	add    rsp,0x30
      f2:	mov    rsp,rbp
      f5:	pop    rbp
      f6:	ret
      f7:	mov    rsi,r12
      fa:	mov    QWORD PTR [rsi],rax
      fd:	mov    QWORD PTR [rsi+0x8],0x1
     105:	mov    rax,rbx
     108:	mov    rbx,QWORD PTR [rsp+0x10]
     10d:	mov    r12,QWORD PTR [rsp+0x18]
     112:	mov    r13,QWORD PTR [rsp+0x20]
     117:	add    rsp,0x30
     11b:	mov    rsp,rbp
     11e:	pop    rbp
     11f:	ret

0000000000000120 <botlish_entry_2: chunked_new<generic>>:
     120:	push   rbp
     121:	mov    rbp,rsp
     124:	ud2
	...

0000000000000128 <botlish_fn_3: chunked_append<list[list<never>, mutarray, int], str>>:
     128:	push   rbp
     129:	mov    rbp,rsp
     12c:	sub    rsp,0x60
     130:	mov    QWORD PTR [rsp+0x30],rbx
     135:	mov    QWORD PTR [rsp+0x38],r12
     13a:	mov    QWORD PTR [rsp+0x40],r13
     13f:	mov    QWORD PTR [rsp+0x48],r14
     144:	mov    QWORD PTR [rsp+0x50],r15
     149:	mov    r12,r9
     14c:	mov    r13,rdi
     14f:	mov    QWORD PTR [rsp],rsi
     153:	mov    r14,rsi
     156:	mov    QWORD PTR [rsp+0x8],rdx
     15b:	mov    r15,rdx
     15e:	mov    QWORD PTR [rsp+0x10],rcx
     163:	mov    rbx,rcx
     166:	mov    QWORD PTR [rsp+0x18],r8
     16b:	mov    QWORD PTR [rsp+0x20],r8
     170:	mov    rdi,r13
     173:	call   178 <botlish_fn_3+0x50>
			174: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     178:	test   rax,rax
     17b:	je     2cd <botlish_fn_3+0x1a5>
     181:	test   rbx,0x1
     188:	jne    1b3 <botlish_fn_3+0x8b>
     18e:	mov    edx,0x81
     193:	mov    rsi,rbx
     196:	mov    rdi,r13
     199:	call   19e <botlish_fn_3+0x76>
			19a: R_X86_64_PLT32	rt_int_cmp-0x4
     19e:	mov    ecx,0x2
     1a3:	test   rax,rax
     1a6:	cmove  rcx,QWORD PTR [rip+0x17a]        # 328 <botlish_fn_3+0x200>
     1ae:	jmp    1c7 <botlish_fn_3+0x9f>
     1b3:	mov    ecx,0x2
     1b8:	cmp    rbx,0x81
     1bf:	cmove  rcx,QWORD PTR [rip+0x161]        # 328 <botlish_fn_3+0x200>
     1c7:	cmp    rcx,0x6
     1cb:	je     25e <botlish_fn_3+0x136>
     1d1:	mov    rcx,QWORD PTR [rsp+0x20]
     1d6:	mov    rdx,rbx
     1d9:	mov    rsi,r15
     1dc:	mov    rdi,r13
     1df:	call   1e4 <botlish_fn_3+0xbc>
			1e0: R_X86_64_PLT32	rt_mutarray_set-0x4
     1e4:	test   rax,rax
     1e7:	je     2cd <botlish_fn_3+0x1a5>
     1ed:	mov    QWORD PTR [rsp+0x18],0x3
     1f6:	test   rbx,0x1
     1fd:	je     21d <botlish_fn_3+0xf5>
     203:	mov    rax,rbx
     206:	add    rax,0x2
     20a:	seto   cl
     20d:	test   cl,cl
     20f:	jne    21d <botlish_fn_3+0xf5>
     215:	mov    rdx,r15
     218:	jmp    230 <botlish_fn_3+0x108>
     21d:	mov    edx,0x3
     222:	mov    rsi,rbx
     225:	mov    rdi,r13
     228:	call   22d <botlish_fn_3+0x105>
			229: R_X86_64_PLT32	rt_int_add-0x4
     22d:	mov    rdx,r15
     230:	mov    QWORD PTR [r12],rdx
     234:	mov    QWORD PTR [r12+0x8],rax
     239:	mov    rax,r14
     23c:	mov    rbx,QWORD PTR [rsp+0x30]
     241:	mov    r12,QWORD PTR [rsp+0x38]
     246:	mov    r13,QWORD PTR [rsp+0x40]
     24b:	mov    r14,QWORD PTR [rsp+0x48]
     250:	mov    r15,QWORD PTR [rsp+0x50]
     255:	add    rsp,0x60
     259:	mov    rsp,rbp
     25c:	pop    rbp
     25d:	ret
     25e:	mov    rdx,r15
     261:	mov    rsi,r14
     264:	mov    rdi,r13
     267:	call   26c <botlish_fn_3+0x144>
			268: R_X86_64_PLT32	rt_list_append-0x4
     26c:	test   rax,rax
     26f:	je     2cd <botlish_fn_3+0x1a5>
     275:	mov    QWORD PTR [rsp],rax
     279:	mov    rbx,rax
     27c:	mov    rdi,r13
     27f:	call   284 <botlish_fn_3+0x15c>
			280: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     284:	test   rax,rax
     287:	je     2cd <botlish_fn_3+0x1a5>
     28d:	mov    esi,0x81
     292:	mov    QWORD PTR [rsp+0x8],0x81
     29b:	mov    rdi,r13
     29e:	call   2a3 <botlish_fn_3+0x17b>
			29f: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     2a3:	test   rax,rax
     2a6:	mov    r14,rax
     2a9:	je     2cd <botlish_fn_3+0x1a5>
     2af:	mov    edx,0x1
     2b4:	mov    rcx,QWORD PTR [rsp+0x20]
     2b9:	mov    rdi,r13
     2bc:	mov    rsi,r14
     2bf:	call   2c4 <botlish_fn_3+0x19c>
			2c0: R_X86_64_PLT32	rt_mutarray_set-0x4
     2c4:	test   rax,rax
     2c7:	jne    2f2 <botlish_fn_3+0x1ca>
     2cd:	xor    rax,rax
     2d0:	mov    rbx,QWORD PTR [rsp+0x30]
     2d5:	mov    r12,QWORD PTR [rsp+0x38]
     2da:	mov    r13,QWORD PTR [rsp+0x40]
     2df:	mov    r14,QWORD PTR [rsp+0x48]
     2e4:	mov    r15,QWORD PTR [rsp+0x50]
     2e9:	add    rsp,0x60
     2ed:	mov    rsp,rbp
     2f0:	pop    rbp
     2f1:	ret
     2f2:	mov    rax,r14
     2f5:	mov    QWORD PTR [r12],rax
     2f9:	mov    QWORD PTR [r12+0x8],0x3
     302:	mov    rax,rbx
     305:	mov    rbx,QWORD PTR [rsp+0x30]
     30a:	mov    r12,QWORD PTR [rsp+0x38]
     30f:	mov    r13,QWORD PTR [rsp+0x40]
     314:	mov    r14,QWORD PTR [rsp+0x48]
     319:	mov    r15,QWORD PTR [rsp+0x50]
     31e:	add    rsp,0x60
     322:	mov    rsp,rbp
     325:	pop    rbp
     326:	ret
     327:	add    BYTE PTR [rsi],al
     329:	add    BYTE PTR [rax],al
     32b:	add    BYTE PTR [rax],al
     32d:	add    BYTE PTR [rax],al
	...

0000000000000330 <botlish_entry_3: chunked_append<list[list<never>, mutarray, int], str>>:
     330:	push   rbp
     331:	mov    rbp,rsp
     334:	ud2
	...

0000000000000338 <botlish_fn_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     338:	push   rbp
     339:	mov    rbp,rsp
     33c:	sub    rsp,0x60
     340:	mov    QWORD PTR [rsp+0x30],rbx
     345:	mov    QWORD PTR [rsp+0x38],r12
     34a:	mov    QWORD PTR [rsp+0x40],r13
     34f:	mov    QWORD PTR [rsp+0x48],r14
     354:	mov    QWORD PTR [rsp+0x50],r15
     359:	mov    r12,r9
     35c:	mov    r13,rdi
     35f:	mov    QWORD PTR [rsp],rsi
     363:	mov    r14,rsi
     366:	mov    QWORD PTR [rsp+0x8],rdx
     36b:	mov    r15,rdx
     36e:	mov    QWORD PTR [rsp+0x10],rcx
     373:	mov    rbx,rcx
     376:	mov    QWORD PTR [rsp+0x18],r8
     37b:	mov    QWORD PTR [rsp+0x20],r8
     380:	mov    rdi,r13
     383:	call   388 <botlish_fn_4+0x50>
			384: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     388:	test   rax,rax
     38b:	je     4dd <botlish_fn_4+0x1a5>
     391:	test   rbx,0x1
     398:	jne    3c3 <botlish_fn_4+0x8b>
     39e:	mov    edx,0x81
     3a3:	mov    rsi,rbx
     3a6:	mov    rdi,r13
     3a9:	call   3ae <botlish_fn_4+0x76>
			3aa: R_X86_64_PLT32	rt_int_cmp-0x4
     3ae:	mov    ecx,0x2
     3b3:	test   rax,rax
     3b6:	cmove  rcx,QWORD PTR [rip+0x17a]        # 538 <botlish_fn_4+0x200>
     3be:	jmp    3d7 <botlish_fn_4+0x9f>
     3c3:	mov    ecx,0x2
     3c8:	cmp    rbx,0x81
     3cf:	cmove  rcx,QWORD PTR [rip+0x161]        # 538 <botlish_fn_4+0x200>
     3d7:	cmp    rcx,0x6
     3db:	je     46e <botlish_fn_4+0x136>
     3e1:	mov    rcx,QWORD PTR [rsp+0x20]
     3e6:	mov    rdx,rbx
     3e9:	mov    rsi,r15
     3ec:	mov    rdi,r13
     3ef:	call   3f4 <botlish_fn_4+0xbc>
			3f0: R_X86_64_PLT32	rt_mutarray_set-0x4
     3f4:	test   rax,rax
     3f7:	je     4dd <botlish_fn_4+0x1a5>
     3fd:	mov    QWORD PTR [rsp+0x18],0x3
     406:	test   rbx,0x1
     40d:	je     42d <botlish_fn_4+0xf5>
     413:	mov    rax,rbx
     416:	add    rax,0x2
     41a:	seto   cl
     41d:	test   cl,cl
     41f:	jne    42d <botlish_fn_4+0xf5>
     425:	mov    rdx,r15
     428:	jmp    440 <botlish_fn_4+0x108>
     42d:	mov    edx,0x3
     432:	mov    rsi,rbx
     435:	mov    rdi,r13
     438:	call   43d <botlish_fn_4+0x105>
			439: R_X86_64_PLT32	rt_int_add-0x4
     43d:	mov    rdx,r15
     440:	mov    QWORD PTR [r12],rdx
     444:	mov    QWORD PTR [r12+0x8],rax
     449:	mov    rax,r14
     44c:	mov    rbx,QWORD PTR [rsp+0x30]
     451:	mov    r12,QWORD PTR [rsp+0x38]
     456:	mov    r13,QWORD PTR [rsp+0x40]
     45b:	mov    r14,QWORD PTR [rsp+0x48]
     460:	mov    r15,QWORD PTR [rsp+0x50]
     465:	add    rsp,0x60
     469:	mov    rsp,rbp
     46c:	pop    rbp
     46d:	ret
     46e:	mov    rdx,r15
     471:	mov    rsi,r14
     474:	mov    rdi,r13
     477:	call   47c <botlish_fn_4+0x144>
			478: R_X86_64_PLT32	rt_list_append-0x4
     47c:	test   rax,rax
     47f:	je     4dd <botlish_fn_4+0x1a5>
     485:	mov    QWORD PTR [rsp],rax
     489:	mov    rbx,rax
     48c:	mov    rdi,r13
     48f:	call   494 <botlish_fn_4+0x15c>
			490: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     494:	test   rax,rax
     497:	je     4dd <botlish_fn_4+0x1a5>
     49d:	mov    esi,0x81
     4a2:	mov    QWORD PTR [rsp+0x8],0x81
     4ab:	mov    rdi,r13
     4ae:	call   4b3 <botlish_fn_4+0x17b>
			4af: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     4b3:	test   rax,rax
     4b6:	mov    r14,rax
     4b9:	je     4dd <botlish_fn_4+0x1a5>
     4bf:	mov    edx,0x1
     4c4:	mov    rcx,QWORD PTR [rsp+0x20]
     4c9:	mov    rdi,r13
     4cc:	mov    rsi,r14
     4cf:	call   4d4 <botlish_fn_4+0x19c>
			4d0: R_X86_64_PLT32	rt_mutarray_set-0x4
     4d4:	test   rax,rax
     4d7:	jne    502 <botlish_fn_4+0x1ca>
     4dd:	xor    rax,rax
     4e0:	mov    rbx,QWORD PTR [rsp+0x30]
     4e5:	mov    r12,QWORD PTR [rsp+0x38]
     4ea:	mov    r13,QWORD PTR [rsp+0x40]
     4ef:	mov    r14,QWORD PTR [rsp+0x48]
     4f4:	mov    r15,QWORD PTR [rsp+0x50]
     4f9:	add    rsp,0x60
     4fd:	mov    rsp,rbp
     500:	pop    rbp
     501:	ret
     502:	mov    rax,r14
     505:	mov    QWORD PTR [r12],rax
     509:	mov    QWORD PTR [r12+0x8],0x3
     512:	mov    rax,rbx
     515:	mov    rbx,QWORD PTR [rsp+0x30]
     51a:	mov    r12,QWORD PTR [rsp+0x38]
     51f:	mov    r13,QWORD PTR [rsp+0x40]
     524:	mov    r14,QWORD PTR [rsp+0x48]
     529:	mov    r15,QWORD PTR [rsp+0x50]
     52e:	add    rsp,0x60
     532:	mov    rsp,rbp
     535:	pop    rbp
     536:	ret
     537:	add    BYTE PTR [rsi],al
     539:	add    BYTE PTR [rax],al
     53b:	add    BYTE PTR [rax],al
     53d:	add    BYTE PTR [rax],al
	...

0000000000000540 <botlish_entry_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     540:	push   rbp
     541:	mov    rbp,rsp
     544:	ud2
	...

0000000000000548 <botlish_fn_5: chunked_append<list[list<never>, mutarray, int], list>>:
     548:	push   rbp
     549:	mov    rbp,rsp
     54c:	sub    rsp,0x60
     550:	mov    QWORD PTR [rsp+0x30],rbx
     555:	mov    QWORD PTR [rsp+0x38],r12
     55a:	mov    QWORD PTR [rsp+0x40],r13
     55f:	mov    QWORD PTR [rsp+0x48],r14
     564:	mov    QWORD PTR [rsp+0x50],r15
     569:	mov    r12,r9
     56c:	mov    r13,rdi
     56f:	mov    QWORD PTR [rsp],rsi
     573:	mov    r14,rsi
     576:	mov    QWORD PTR [rsp+0x8],rdx
     57b:	mov    r15,rdx
     57e:	mov    QWORD PTR [rsp+0x10],rcx
     583:	mov    rbx,rcx
     586:	mov    QWORD PTR [rsp+0x18],r8
     58b:	mov    QWORD PTR [rsp+0x20],r8
     590:	mov    rdi,r13
     593:	call   598 <botlish_fn_5+0x50>
			594: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     598:	test   rax,rax
     59b:	je     6ed <botlish_fn_5+0x1a5>
     5a1:	test   rbx,0x1
     5a8:	jne    5d3 <botlish_fn_5+0x8b>
     5ae:	mov    edx,0x81
     5b3:	mov    rsi,rbx
     5b6:	mov    rdi,r13
     5b9:	call   5be <botlish_fn_5+0x76>
			5ba: R_X86_64_PLT32	rt_int_cmp-0x4
     5be:	mov    ecx,0x2
     5c3:	test   rax,rax
     5c6:	cmove  rcx,QWORD PTR [rip+0x17a]        # 748 <botlish_fn_5+0x200>
     5ce:	jmp    5e7 <botlish_fn_5+0x9f>
     5d3:	mov    ecx,0x2
     5d8:	cmp    rbx,0x81
     5df:	cmove  rcx,QWORD PTR [rip+0x161]        # 748 <botlish_fn_5+0x200>
     5e7:	cmp    rcx,0x6
     5eb:	je     67e <botlish_fn_5+0x136>
     5f1:	mov    rcx,QWORD PTR [rsp+0x20]
     5f6:	mov    rdx,rbx
     5f9:	mov    rsi,r15
     5fc:	mov    rdi,r13
     5ff:	call   604 <botlish_fn_5+0xbc>
			600: R_X86_64_PLT32	rt_mutarray_set-0x4
     604:	test   rax,rax
     607:	je     6ed <botlish_fn_5+0x1a5>
     60d:	mov    QWORD PTR [rsp+0x18],0x3
     616:	test   rbx,0x1
     61d:	je     63d <botlish_fn_5+0xf5>
     623:	mov    rax,rbx
     626:	add    rax,0x2
     62a:	seto   cl
     62d:	test   cl,cl
     62f:	jne    63d <botlish_fn_5+0xf5>
     635:	mov    rdx,r15
     638:	jmp    650 <botlish_fn_5+0x108>
     63d:	mov    edx,0x3
     642:	mov    rsi,rbx
     645:	mov    rdi,r13
     648:	call   64d <botlish_fn_5+0x105>
			649: R_X86_64_PLT32	rt_int_add-0x4
     64d:	mov    rdx,r15
     650:	mov    QWORD PTR [r12],rdx
     654:	mov    QWORD PTR [r12+0x8],rax
     659:	mov    rax,r14
     65c:	mov    rbx,QWORD PTR [rsp+0x30]
     661:	mov    r12,QWORD PTR [rsp+0x38]
     666:	mov    r13,QWORD PTR [rsp+0x40]
     66b:	mov    r14,QWORD PTR [rsp+0x48]
     670:	mov    r15,QWORD PTR [rsp+0x50]
     675:	add    rsp,0x60
     679:	mov    rsp,rbp
     67c:	pop    rbp
     67d:	ret
     67e:	mov    rdx,r15
     681:	mov    rsi,r14
     684:	mov    rdi,r13
     687:	call   68c <botlish_fn_5+0x144>
			688: R_X86_64_PLT32	rt_list_append-0x4
     68c:	test   rax,rax
     68f:	je     6ed <botlish_fn_5+0x1a5>
     695:	mov    QWORD PTR [rsp],rax
     699:	mov    rbx,rax
     69c:	mov    rdi,r13
     69f:	call   6a4 <botlish_fn_5+0x15c>
			6a0: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     6a4:	test   rax,rax
     6a7:	je     6ed <botlish_fn_5+0x1a5>
     6ad:	mov    esi,0x81
     6b2:	mov    QWORD PTR [rsp+0x8],0x81
     6bb:	mov    rdi,r13
     6be:	call   6c3 <botlish_fn_5+0x17b>
			6bf: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     6c3:	test   rax,rax
     6c6:	mov    r14,rax
     6c9:	je     6ed <botlish_fn_5+0x1a5>
     6cf:	mov    edx,0x1
     6d4:	mov    rcx,QWORD PTR [rsp+0x20]
     6d9:	mov    rdi,r13
     6dc:	mov    rsi,r14
     6df:	call   6e4 <botlish_fn_5+0x19c>
			6e0: R_X86_64_PLT32	rt_mutarray_set-0x4
     6e4:	test   rax,rax
     6e7:	jne    712 <botlish_fn_5+0x1ca>
     6ed:	xor    rax,rax
     6f0:	mov    rbx,QWORD PTR [rsp+0x30]
     6f5:	mov    r12,QWORD PTR [rsp+0x38]
     6fa:	mov    r13,QWORD PTR [rsp+0x40]
     6ff:	mov    r14,QWORD PTR [rsp+0x48]
     704:	mov    r15,QWORD PTR [rsp+0x50]
     709:	add    rsp,0x60
     70d:	mov    rsp,rbp
     710:	pop    rbp
     711:	ret
     712:	mov    rax,r14
     715:	mov    QWORD PTR [r12],rax
     719:	mov    QWORD PTR [r12+0x8],0x3
     722:	mov    rax,rbx
     725:	mov    rbx,QWORD PTR [rsp+0x30]
     72a:	mov    r12,QWORD PTR [rsp+0x38]
     72f:	mov    r13,QWORD PTR [rsp+0x40]
     734:	mov    r14,QWORD PTR [rsp+0x48]
     739:	mov    r15,QWORD PTR [rsp+0x50]
     73e:	add    rsp,0x60
     742:	mov    rsp,rbp
     745:	pop    rbp
     746:	ret
     747:	add    BYTE PTR [rsi],al
     749:	add    BYTE PTR [rax],al
     74b:	add    BYTE PTR [rax],al
     74d:	add    BYTE PTR [rax],al
	...

0000000000000750 <botlish_entry_5: chunked_append<list[list<never>, mutarray, int], list>>:
     750:	push   rbp
     751:	mov    rbp,rsp
     754:	ud2
	...

0000000000000758 <botlish_fn_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     758:	push   rbp
     759:	mov    rbp,rsp
     75c:	sub    rsp,0x60
     760:	mov    QWORD PTR [rsp+0x30],rbx
     765:	mov    QWORD PTR [rsp+0x38],r12
     76a:	mov    QWORD PTR [rsp+0x40],r13
     76f:	mov    QWORD PTR [rsp+0x48],r14
     774:	mov    QWORD PTR [rsp+0x50],r15
     779:	mov    r12,r9
     77c:	mov    r13,rdi
     77f:	mov    QWORD PTR [rsp],rsi
     783:	mov    r14,rsi
     786:	mov    QWORD PTR [rsp+0x8],rdx
     78b:	mov    r15,rdx
     78e:	mov    QWORD PTR [rsp+0x10],rcx
     793:	mov    rbx,rcx
     796:	mov    QWORD PTR [rsp+0x18],r8
     79b:	mov    QWORD PTR [rsp+0x20],r8
     7a0:	mov    rdi,r13
     7a3:	call   7a8 <botlish_fn_6+0x50>
			7a4: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     7a8:	test   rax,rax
     7ab:	je     8fd <botlish_fn_6+0x1a5>
     7b1:	test   rbx,0x1
     7b8:	jne    7e3 <botlish_fn_6+0x8b>
     7be:	mov    edx,0x81
     7c3:	mov    rsi,rbx
     7c6:	mov    rdi,r13
     7c9:	call   7ce <botlish_fn_6+0x76>
			7ca: R_X86_64_PLT32	rt_int_cmp-0x4
     7ce:	mov    ecx,0x2
     7d3:	test   rax,rax
     7d6:	cmove  rcx,QWORD PTR [rip+0x17a]        # 958 <botlish_fn_6+0x200>
     7de:	jmp    7f7 <botlish_fn_6+0x9f>
     7e3:	mov    ecx,0x2
     7e8:	cmp    rbx,0x81
     7ef:	cmove  rcx,QWORD PTR [rip+0x161]        # 958 <botlish_fn_6+0x200>
     7f7:	cmp    rcx,0x6
     7fb:	je     88e <botlish_fn_6+0x136>
     801:	mov    rcx,QWORD PTR [rsp+0x20]
     806:	mov    rdx,rbx
     809:	mov    rsi,r15
     80c:	mov    rdi,r13
     80f:	call   814 <botlish_fn_6+0xbc>
			810: R_X86_64_PLT32	rt_mutarray_set-0x4
     814:	test   rax,rax
     817:	je     8fd <botlish_fn_6+0x1a5>
     81d:	mov    QWORD PTR [rsp+0x18],0x3
     826:	test   rbx,0x1
     82d:	je     84d <botlish_fn_6+0xf5>
     833:	mov    rax,rbx
     836:	add    rax,0x2
     83a:	seto   cl
     83d:	test   cl,cl
     83f:	jne    84d <botlish_fn_6+0xf5>
     845:	mov    rdx,r15
     848:	jmp    860 <botlish_fn_6+0x108>
     84d:	mov    edx,0x3
     852:	mov    rsi,rbx
     855:	mov    rdi,r13
     858:	call   85d <botlish_fn_6+0x105>
			859: R_X86_64_PLT32	rt_int_add-0x4
     85d:	mov    rdx,r15
     860:	mov    QWORD PTR [r12],rdx
     864:	mov    QWORD PTR [r12+0x8],rax
     869:	mov    rax,r14
     86c:	mov    rbx,QWORD PTR [rsp+0x30]
     871:	mov    r12,QWORD PTR [rsp+0x38]
     876:	mov    r13,QWORD PTR [rsp+0x40]
     87b:	mov    r14,QWORD PTR [rsp+0x48]
     880:	mov    r15,QWORD PTR [rsp+0x50]
     885:	add    rsp,0x60
     889:	mov    rsp,rbp
     88c:	pop    rbp
     88d:	ret
     88e:	mov    rdx,r15
     891:	mov    rsi,r14
     894:	mov    rdi,r13
     897:	call   89c <botlish_fn_6+0x144>
			898: R_X86_64_PLT32	rt_list_append-0x4
     89c:	test   rax,rax
     89f:	je     8fd <botlish_fn_6+0x1a5>
     8a5:	mov    QWORD PTR [rsp],rax
     8a9:	mov    rbx,rax
     8ac:	mov    rdi,r13
     8af:	call   8b4 <botlish_fn_6+0x15c>
			8b0: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     8b4:	test   rax,rax
     8b7:	je     8fd <botlish_fn_6+0x1a5>
     8bd:	mov    esi,0x81
     8c2:	mov    QWORD PTR [rsp+0x8],0x81
     8cb:	mov    rdi,r13
     8ce:	call   8d3 <botlish_fn_6+0x17b>
			8cf: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     8d3:	test   rax,rax
     8d6:	mov    r14,rax
     8d9:	je     8fd <botlish_fn_6+0x1a5>
     8df:	mov    edx,0x1
     8e4:	mov    rcx,QWORD PTR [rsp+0x20]
     8e9:	mov    rdi,r13
     8ec:	mov    rsi,r14
     8ef:	call   8f4 <botlish_fn_6+0x19c>
			8f0: R_X86_64_PLT32	rt_mutarray_set-0x4
     8f4:	test   rax,rax
     8f7:	jne    922 <botlish_fn_6+0x1ca>
     8fd:	xor    rax,rax
     900:	mov    rbx,QWORD PTR [rsp+0x30]
     905:	mov    r12,QWORD PTR [rsp+0x38]
     90a:	mov    r13,QWORD PTR [rsp+0x40]
     90f:	mov    r14,QWORD PTR [rsp+0x48]
     914:	mov    r15,QWORD PTR [rsp+0x50]
     919:	add    rsp,0x60
     91d:	mov    rsp,rbp
     920:	pop    rbp
     921:	ret
     922:	mov    rax,r14
     925:	mov    QWORD PTR [r12],rax
     929:	mov    QWORD PTR [r12+0x8],0x3
     932:	mov    rax,rbx
     935:	mov    rbx,QWORD PTR [rsp+0x30]
     93a:	mov    r12,QWORD PTR [rsp+0x38]
     93f:	mov    r13,QWORD PTR [rsp+0x40]
     944:	mov    r14,QWORD PTR [rsp+0x48]
     949:	mov    r15,QWORD PTR [rsp+0x50]
     94e:	add    rsp,0x60
     952:	mov    rsp,rbp
     955:	pop    rbp
     956:	ret
     957:	add    BYTE PTR [rsi],al
     959:	add    BYTE PTR [rax],al
     95b:	add    BYTE PTR [rax],al
     95d:	add    BYTE PTR [rax],al
	...

0000000000000960 <botlish_entry_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     960:	push   rbp
     961:	mov    rbp,rsp
     964:	ud2
	...

0000000000000968 <botlish_fn_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
     968:	push   rbp
     969:	mov    rbp,rsp
     96c:	sub    rsp,0x70
     970:	mov    QWORD PTR [rsp+0x40],rbx
     975:	mov    QWORD PTR [rsp+0x48],r12
     97a:	mov    QWORD PTR [rsp+0x50],r13
     97f:	mov    QWORD PTR [rsp+0x58],r14
     984:	mov    QWORD PTR [rsp+0x60],r15
     989:	mov    r14,rdi
     98c:	mov    QWORD PTR [rsp],rsi
     990:	mov    QWORD PTR [rsp+0x8],rdx
     995:	mov    rbx,rdx
     998:	mov    QWORD PTR [rsp+0x10],rcx
     99d:	mov    r12,rcx
     9a0:	mov    QWORD PTR [rsp+0x18],r8
     9a5:	mov    r13,rsi
     9a8:	mov    r15,r8
     9ab:	mov    rsi,r13
     9ae:	mov    rdi,r14
     9b1:	call   9b6 <botlish_fn_7+0x4e>
			9b2: R_X86_64_PLT32	rt_list_len-0x4
     9b6:	mov    rcx,rbx
     9b9:	and    rcx,rax
     9bc:	mov    rdx,rax
     9bf:	test   rcx,0x1
     9c6:	jne    9ec <botlish_fn_7+0x84>
     9cc:	mov    rsi,rbx
     9cf:	mov    rdi,r14
     9d2:	call   9d7 <botlish_fn_7+0x6f>
			9d3: R_X86_64_PLT32	rt_int_cmp-0x4
     9d7:	mov    ecx,0x2
     9dc:	test   rax,rax
     9df:	cmovge rcx,QWORD PTR [rip+0x1c9]        # bb0 <botlish_fn_7+0x248>
     9e7:	jmp    9fc <botlish_fn_7+0x94>
     9ec:	mov    ecx,0x2
     9f1:	cmp    rbx,rdx
     9f4:	cmovge rcx,QWORD PTR [rip+0x1b4]        # bb0 <botlish_fn_7+0x248>
     9fc:	cmp    rcx,0x6
     a00:	je     b87 <botlish_fn_7+0x21f>
     a06:	test   rbx,0x1
     a0d:	je     a26 <botlish_fn_7+0xbe>
     a13:	mov    rcx,QWORD PTR [r13+0x8]
     a17:	mov    rax,rbx
     a1a:	sar    rax,1
     a1d:	cmp    rax,rcx
     a20:	jb     a45 <botlish_fn_7+0xdd>
     a26:	mov    rdx,rbx
     a29:	mov    rsi,r13
     a2c:	mov    rdi,r14
     a2f:	call   a34 <botlish_fn_7+0xcc>
			a30: R_X86_64_PLT32	rt_list_get-0x4
     a34:	test   rax,rax
     a37:	je     b07 <botlish_fn_7+0x19f>
     a3d:	mov    rsi,rax
     a40:	jmp    a50 <botlish_fn_7+0xe8>
     a45:	mov    rdi,QWORD PTR [r13+0x10]
     a49:	mov    rdi,QWORD PTR [rdi+rax*8]
     a4d:	mov    rsi,rdi
     a50:	mov    QWORD PTR [rsp+0x20],rsi
     a55:	mov    QWORD PTR [rsp+0x30],rsi
     a5a:	mov    QWORD PTR [rsp+0x28],0x1
     a63:	mov    rdi,r14
     a66:	call   a6b <botlish_fn_7+0x103>
			a67: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     a6b:	test   rax,rax
     a6e:	je     b07 <botlish_fn_7+0x19f>
     a74:	xor    eax,eax
     a76:	mov    rsi,QWORD PTR [rsp+0x30]
     a7b:	test   rsi,0x7
     a82:	jne    a91 <botlish_fn_7+0x129>
     a88:	movzx  rax,BYTE PTR [rsi]
     a8c:	cmp    al,0x8
     a8e:	sete   al
     a91:	test   al,al
     a93:	jne    ab3 <botlish_fn_7+0x14b>
     a99:	mov    rdi,r14
     a9c:	mov    rax,QWORD PTR [rdi+0x10]
     aa0:	mov    rcx,QWORD PTR [rax+0x8]
     aa4:	mov    edx,0x8
     aa9:	call   aae <botlish_fn_7+0x146>
			aaa: R_X86_64_PLT32	rt_type_error-0x4
     aae:	jmp    b07 <botlish_fn_7+0x19f>
     ab3:	mov    QWORD PTR [rsp+0x30],rsi
     ab8:	mov    r8d,0x1
     abe:	mov    r9d,0x81
     ac4:	mov    rcx,QWORD PTR [rsp+0x30]
     ac9:	mov    rdx,r15
     acc:	mov    rsi,r12
     acf:	mov    rdi,r14
     ad2:	call   ad7 <botlish_fn_7+0x16f>
			ad3: R_X86_64_PLT32	rt_mutarray_copy-0x4
     ad7:	test   rax,rax
     ada:	je     b07 <botlish_fn_7+0x19f>
     ae0:	sar    rbx,1
     ae3:	add    rbx,0x1
     aea:	shl    rbx,1
     aed:	or     rbx,0x1
     af1:	mov    QWORD PTR [rsp+0x8],rbx
     af6:	mov    rdi,r14
     af9:	call   afe <botlish_fn_7+0x196>
			afa: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     afe:	test   rax,rax
     b01:	jne    b2c <botlish_fn_7+0x1c4>
     b07:	xor    rax,rax
     b0a:	mov    rbx,QWORD PTR [rsp+0x40]
     b0f:	mov    r12,QWORD PTR [rsp+0x48]
     b14:	mov    r13,QWORD PTR [rsp+0x50]
     b19:	mov    r14,QWORD PTR [rsp+0x58]
     b1e:	mov    r15,QWORD PTR [rsp+0x60]
     b23:	add    rsp,0x70
     b27:	mov    rsp,rbp
     b2a:	pop    rbp
     b2b:	ret
     b2c:	mov    QWORD PTR [rsp+0x20],0x81
     b35:	mov    rsi,r15
     b38:	test   rsi,0x1
     b3f:	je     b5c <botlish_fn_7+0x1f4>
     b45:	mov    rsi,r15
     b48:	mov    rax,rsi
     b4b:	add    rax,0x80
     b51:	seto   cl
     b54:	test   cl,cl
     b56:	je     b6c <botlish_fn_7+0x204>
     b5c:	mov    edx,0x81
     b61:	mov    rsi,r15
     b64:	mov    rdi,r14
     b67:	call   b6c <botlish_fn_7+0x204>
			b68: R_X86_64_PLT32	rt_int_add-0x4
     b6c:	mov    QWORD PTR [rsp],r13
     b70:	mov    QWORD PTR [rsp+0x8],rbx
     b75:	mov    QWORD PTR [rsp+0x10],r12
     b7a:	mov    QWORD PTR [rsp+0x18],rax
     b7f:	mov    r15,rax
     b82:	jmp    9ab <botlish_fn_7+0x43>
     b87:	mov    rax,r15
     b8a:	mov    rbx,QWORD PTR [rsp+0x40]
     b8f:	mov    r12,QWORD PTR [rsp+0x48]
     b94:	mov    r13,QWORD PTR [rsp+0x50]
     b99:	mov    r14,QWORD PTR [rsp+0x58]
     b9e:	mov    r15,QWORD PTR [rsp+0x60]
     ba3:	add    rsp,0x70
     ba7:	mov    rsp,rbp
     baa:	pop    rbp
     bab:	ret
     bac:	add    BYTE PTR [rax],al
     bae:	add    BYTE PTR [rax],al
     bb0:	(bad)
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
     c4f:	cmovge rcx,QWORD PTR [rip+0x181]        # dd8 <botlish_fn_8+0x200>
     c57:	jmp    c6c <botlish_fn_8+0x94>
     c5c:	mov    ecx,0x2
     c61:	cmp    rbx,rdx
     c64:	cmovge rcx,QWORD PTR [rip+0x16c]        # dd8 <botlish_fn_8+0x200>
     c6c:	cmp    rcx,0x6
     c70:	je     db0 <botlish_fn_8+0x1d8>
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
     ca7:	je     d30 <botlish_fn_8+0x158>
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
     cdb:	je     d30 <botlish_fn_8+0x158>
     ce1:	mov    r8d,0x1
     ce7:	mov    r9d,0x81
     ced:	mov    rcx,QWORD PTR [rsp+0x30]
     cf2:	mov    rdx,r15
     cf5:	mov    rsi,r12
     cf8:	mov    rdi,r14
     cfb:	call   d00 <botlish_fn_8+0x128>
			cfc: R_X86_64_PLT32	rt_mutarray_copy-0x4
     d00:	test   rax,rax
     d03:	je     d30 <botlish_fn_8+0x158>
     d09:	sar    rbx,1
     d0c:	add    rbx,0x1
     d13:	shl    rbx,1
     d16:	or     rbx,0x1
     d1a:	mov    QWORD PTR [rsp+0x8],rbx
     d1f:	mov    rdi,r14
     d22:	call   d27 <botlish_fn_8+0x14f>
			d23: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     d27:	test   rax,rax
     d2a:	jne    d55 <botlish_fn_8+0x17d>
     d30:	xor    rax,rax
     d33:	mov    rbx,QWORD PTR [rsp+0x40]
     d38:	mov    r12,QWORD PTR [rsp+0x48]
     d3d:	mov    r13,QWORD PTR [rsp+0x50]
     d42:	mov    r14,QWORD PTR [rsp+0x58]
     d47:	mov    r15,QWORD PTR [rsp+0x60]
     d4c:	add    rsp,0x70
     d50:	mov    rsp,rbp
     d53:	pop    rbp
     d54:	ret
     d55:	mov    QWORD PTR [rsp+0x20],0x81
     d5e:	mov    rsi,r15
     d61:	test   rsi,0x1
     d68:	je     d85 <botlish_fn_8+0x1ad>
     d6e:	mov    rsi,r15
     d71:	mov    rax,rsi
     d74:	add    rax,0x80
     d7a:	seto   cl
     d7d:	test   cl,cl
     d7f:	je     d95 <botlish_fn_8+0x1bd>
     d85:	mov    edx,0x81
     d8a:	mov    rsi,r15
     d8d:	mov    rdi,r14
     d90:	call   d95 <botlish_fn_8+0x1bd>
			d91: R_X86_64_PLT32	rt_int_add-0x4
     d95:	mov    QWORD PTR [rsp],r13
     d99:	mov    QWORD PTR [rsp+0x8],rbx
     d9e:	mov    QWORD PTR [rsp+0x10],r12
     da3:	mov    QWORD PTR [rsp+0x18],rax
     da8:	mov    r15,rax
     dab:	jmp    c1b <botlish_fn_8+0x43>
     db0:	mov    rax,r15
     db3:	mov    rbx,QWORD PTR [rsp+0x40]
     db8:	mov    r12,QWORD PTR [rsp+0x48]
     dbd:	mov    r13,QWORD PTR [rsp+0x50]
     dc2:	mov    r14,QWORD PTR [rsp+0x58]
     dc7:	mov    r15,QWORD PTR [rsp+0x60]
     dcc:	add    rsp,0x70
     dd0:	mov    rsp,rbp
     dd3:	pop    rbp
     dd4:	ret
     dd5:	add    BYTE PTR [rax],al
     dd7:	add    BYTE PTR [rsi],al
     dd9:	add    BYTE PTR [rax],al
     ddb:	add    BYTE PTR [rax],al
     ddd:	add    BYTE PTR [rax],al
	...

0000000000000de0 <botlish_entry_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
     de0:	push   rbp
     de1:	mov    rbp,rsp
     de4:	mov    rsi,QWORD PTR [rdx]
     de7:	mov    r9,QWORD PTR [rdx+0x8]
     deb:	mov    rcx,QWORD PTR [rdx+0x10]
     def:	mov    r8,QWORD PTR [rdx+0x18]
     df3:	mov    rdx,r9
     df6:	call   dfb <botlish_entry_8+0x1b>
			df7: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
     dfb:	mov    rsp,rbp
     dfe:	pop    rbp
     dff:	ret

0000000000000e00 <botlish_fn_9: chunked_finish<list[list<never>, mutarray, int]>>:
     e00:	push   rbp
     e01:	mov    rbp,rsp
     e04:	sub    rsp,0x70
     e08:	mov    QWORD PTR [rsp+0x40],rbx
     e0d:	mov    QWORD PTR [rsp+0x48],r12
     e12:	mov    QWORD PTR [rsp+0x50],r13
     e17:	mov    QWORD PTR [rsp+0x58],r14
     e1c:	mov    QWORD PTR [rsp+0x60],r15
     e21:	mov    r13,rdi
     e24:	mov    QWORD PTR [rsp+0x20],0x0
     e2d:	mov    QWORD PTR [rsp+0x28],0x0
     e36:	mov    QWORD PTR [rsp+0x30],0x0
     e3f:	mov    QWORD PTR [rsp],rsi
     e43:	mov    r15,rsi
     e46:	mov    QWORD PTR [rsp+0x8],rdx
     e4b:	mov    r14,rdx
     e4e:	mov    QWORD PTR [rsp+0x10],rcx
     e53:	mov    r12,rcx
     e56:	mov    rsi,r15
     e59:	mov    rdi,r13
     e5c:	call   e61 <botlish_fn_9+0x61>
			e5d: R_X86_64_PLT32	rt_list_len-0x4
     e61:	mov    QWORD PTR [rsp+0x18],rax
     e66:	mov    rbx,rax
     e69:	mov    rdi,r13
     e6c:	call   e71 <botlish_fn_9+0x71>
			e6d: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     e71:	test   rax,rax
     e74:	je     fad <botlish_fn_9+0x1ad>
     e7a:	mov    QWORD PTR [rsp+0x20],0x81
     e83:	mov    rsi,rbx
     e86:	test   rsi,0x1
     e8d:	jne    e9b <botlish_fn_9+0x9b>
     e93:	mov    rbx,rsi
     e96:	jmp    ec2 <botlish_fn_9+0xc2>
     e9b:	mov    rax,rsi
     e9e:	sar    rax,1
     ea1:	mov    rbx,rsi
     ea4:	imul   QWORD PTR [rip+0x14d]        # ff8 <botlish_fn_9+0x1f8>
     eab:	seto   cl
     eae:	or     rax,0x1
     eb2:	test   cl,cl
     eb4:	jne    ec2 <botlish_fn_9+0xc2>
     eba:	mov    rsi,rax
     ebd:	jmp    ed5 <botlish_fn_9+0xd5>
     ec2:	mov    edx,0x81
     ec7:	mov    rsi,rbx
     eca:	mov    rdi,r13
     ecd:	call   ed2 <botlish_fn_9+0xd2>
			ece: R_X86_64_PLT32	rt_int_mul-0x4
     ed2:	mov    rsi,rax
     ed5:	mov    QWORD PTR [rsp+0x18],rsi
     eda:	mov    rax,rsi
     edd:	and    rax,r12
     ee0:	test   rax,0x1
     ee6:	je     f02 <botlish_fn_9+0x102>
     eec:	lea    rcx,[r12-0x1]
     ef1:	mov    rbx,rsi
     ef4:	add    rbx,rcx
     ef7:	seto   al
     efa:	test   al,al
     efc:	je     f10 <botlish_fn_9+0x110>
     f02:	mov    rdx,r12
     f05:	mov    rdi,r13
     f08:	call   f0d <botlish_fn_9+0x10d>
			f09: R_X86_64_PLT32	rt_int_add-0x4
     f0d:	mov    rbx,rax
     f10:	mov    QWORD PTR [rsp+0x18],rbx
     f15:	mov    rsi,rbx
     f18:	mov    rdi,r13
     f1b:	call   f20 <botlish_fn_9+0x120>
			f1c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     f20:	mov    rcx,rax
     f23:	mov    QWORD PTR [rsp+0x38],rax
     f28:	test   rax,rcx
     f2b:	je     fad <botlish_fn_9+0x1ad>
     f31:	mov    rax,QWORD PTR [rsp+0x38]
     f36:	mov    QWORD PTR [rsp+0x20],rax
     f3b:	mov    r8d,0x1
     f41:	mov    QWORD PTR [rsp+0x28],0x1
     f4a:	mov    QWORD PTR [rsp+0x30],0x1
     f53:	mov    rsi,r15
     f56:	mov    rcx,QWORD PTR [rsp+0x38]
     f5b:	mov    rdi,r13
     f5e:	mov    rdx,r8
     f61:	call   f66 <botlish_fn_9+0x166>
			f62: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
     f66:	test   rax,rax
     f69:	mov    rdx,rax
     f6c:	je     fad <botlish_fn_9+0x1ad>
     f72:	mov    r8d,0x1
     f78:	mov    rcx,r14
     f7b:	mov    r9,r12
     f7e:	mov    rsi,QWORD PTR [rsp+0x38]
     f83:	mov    rdi,r13
     f86:	call   f8b <botlish_fn_9+0x18b>
			f87: R_X86_64_PLT32	rt_mutarray_copy-0x4
     f8b:	test   rax,rax
     f8e:	je     fad <botlish_fn_9+0x1ad>
     f94:	mov    rdx,rbx
     f97:	mov    rsi,QWORD PTR [rsp+0x38]
     f9c:	mov    rdi,r13
     f9f:	call   fa4 <botlish_fn_9+0x1a4>
			fa0: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     fa4:	test   rax,rax
     fa7:	jne    fd2 <botlish_fn_9+0x1d2>
     fad:	xor    rax,rax
     fb0:	mov    rbx,QWORD PTR [rsp+0x40]
     fb5:	mov    r12,QWORD PTR [rsp+0x48]
     fba:	mov    r13,QWORD PTR [rsp+0x50]
     fbf:	mov    r14,QWORD PTR [rsp+0x58]
     fc4:	mov    r15,QWORD PTR [rsp+0x60]
     fc9:	add    rsp,0x70
     fcd:	mov    rsp,rbp
     fd0:	pop    rbp
     fd1:	ret
     fd2:	mov    rbx,QWORD PTR [rsp+0x40]
     fd7:	mov    r12,QWORD PTR [rsp+0x48]
     fdc:	mov    r13,QWORD PTR [rsp+0x50]
     fe1:	mov    r14,QWORD PTR [rsp+0x58]
     fe6:	mov    r15,QWORD PTR [rsp+0x60]
     feb:	add    rsp,0x70
     fef:	mov    rsp,rbp
     ff2:	pop    rbp
     ff3:	ret
     ff4:	add    BYTE PTR [rax],al
     ff6:	add    BYTE PTR [rax],al
     ff8:	add    BYTE PTR [rax],0x0
     ffb:	add    BYTE PTR [rax],al
     ffd:	add    BYTE PTR [rax],al
	...

0000000000001000 <botlish_entry_9: chunked_finish<list[list<never>, mutarray, int]>>:
    1000:	push   rbp
    1001:	mov    rbp,rsp
    1004:	mov    rsi,QWORD PTR [rdx]
    1007:	mov    r8,QWORD PTR [rdx+0x8]
    100b:	mov    rcx,QWORD PTR [rdx+0x10]
    100f:	mov    rdx,r8
    1012:	call   1017 <botlish_entry_9+0x17>
			1013: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    1017:	mov    rsp,rbp
    101a:	pop    rbp
    101b:	ret
    101c:	add    BYTE PTR [rax],al
	...

0000000000001020 <botlish_fn_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    1020:	push   rbp
    1021:	mov    rbp,rsp
    1024:	sub    rsp,0x70
    1028:	mov    QWORD PTR [rsp+0x40],rbx
    102d:	mov    QWORD PTR [rsp+0x48],r12
    1032:	mov    QWORD PTR [rsp+0x50],r13
    1037:	mov    QWORD PTR [rsp+0x58],r14
    103c:	mov    QWORD PTR [rsp+0x60],r15
    1041:	mov    r13,rdi
    1044:	mov    QWORD PTR [rsp+0x20],0x0
    104d:	mov    QWORD PTR [rsp+0x28],0x0
    1056:	mov    QWORD PTR [rsp+0x30],0x0
    105f:	mov    QWORD PTR [rsp],rsi
    1063:	mov    r15,rsi
    1066:	mov    QWORD PTR [rsp+0x8],rdx
    106b:	mov    r14,rdx
    106e:	mov    QWORD PTR [rsp+0x10],rcx
    1073:	mov    r12,rcx
    1076:	mov    rsi,r15
    1079:	mov    rdi,r13
    107c:	call   1081 <botlish_fn_10+0x61>
			107d: R_X86_64_PLT32	rt_list_len-0x4
    1081:	mov    QWORD PTR [rsp+0x18],rax
    1086:	mov    rbx,rax
    1089:	mov    rdi,r13
    108c:	call   1091 <botlish_fn_10+0x71>
			108d: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    1091:	test   rax,rax
    1094:	je     11cd <botlish_fn_10+0x1ad>
    109a:	mov    QWORD PTR [rsp+0x20],0x81
    10a3:	mov    rsi,rbx
    10a6:	test   rsi,0x1
    10ad:	jne    10bb <botlish_fn_10+0x9b>
    10b3:	mov    rbx,rsi
    10b6:	jmp    10e2 <botlish_fn_10+0xc2>
    10bb:	mov    rax,rsi
    10be:	sar    rax,1
    10c1:	mov    rbx,rsi
    10c4:	imul   QWORD PTR [rip+0x14d]        # 1218 <botlish_fn_10+0x1f8>
    10cb:	seto   cl
    10ce:	or     rax,0x1
    10d2:	test   cl,cl
    10d4:	jne    10e2 <botlish_fn_10+0xc2>
    10da:	mov    rsi,rax
    10dd:	jmp    10f5 <botlish_fn_10+0xd5>
    10e2:	mov    edx,0x81
    10e7:	mov    rsi,rbx
    10ea:	mov    rdi,r13
    10ed:	call   10f2 <botlish_fn_10+0xd2>
			10ee: R_X86_64_PLT32	rt_int_mul-0x4
    10f2:	mov    rsi,rax
    10f5:	mov    QWORD PTR [rsp+0x18],rsi
    10fa:	mov    rax,rsi
    10fd:	and    rax,r12
    1100:	test   rax,0x1
    1106:	je     1122 <botlish_fn_10+0x102>
    110c:	lea    rcx,[r12-0x1]
    1111:	mov    rbx,rsi
    1114:	add    rbx,rcx
    1117:	seto   al
    111a:	test   al,al
    111c:	je     1130 <botlish_fn_10+0x110>
    1122:	mov    rdx,r12
    1125:	mov    rdi,r13
    1128:	call   112d <botlish_fn_10+0x10d>
			1129: R_X86_64_PLT32	rt_int_add-0x4
    112d:	mov    rbx,rax
    1130:	mov    QWORD PTR [rsp+0x18],rbx
    1135:	mov    rsi,rbx
    1138:	mov    rdi,r13
    113b:	call   1140 <botlish_fn_10+0x120>
			113c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1140:	mov    rcx,rax
    1143:	mov    QWORD PTR [rsp+0x38],rax
    1148:	test   rax,rcx
    114b:	je     11cd <botlish_fn_10+0x1ad>
    1151:	mov    rax,QWORD PTR [rsp+0x38]
    1156:	mov    QWORD PTR [rsp+0x20],rax
    115b:	mov    r8d,0x1
    1161:	mov    QWORD PTR [rsp+0x28],0x1
    116a:	mov    QWORD PTR [rsp+0x30],0x1
    1173:	mov    rsi,r15
    1176:	mov    rcx,QWORD PTR [rsp+0x38]
    117b:	mov    rdi,r13
    117e:	mov    rdx,r8
    1181:	call   1186 <botlish_fn_10+0x166>
			1182: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    1186:	test   rax,rax
    1189:	mov    rdx,rax
    118c:	je     11cd <botlish_fn_10+0x1ad>
    1192:	mov    r8d,0x1
    1198:	mov    rcx,r14
    119b:	mov    r9,r12
    119e:	mov    rsi,QWORD PTR [rsp+0x38]
    11a3:	mov    rdi,r13
    11a6:	call   11ab <botlish_fn_10+0x18b>
			11a7: R_X86_64_PLT32	rt_mutarray_copy-0x4
    11ab:	test   rax,rax
    11ae:	je     11cd <botlish_fn_10+0x1ad>
    11b4:	mov    rdx,rbx
    11b7:	mov    rsi,QWORD PTR [rsp+0x38]
    11bc:	mov    rdi,r13
    11bf:	call   11c4 <botlish_fn_10+0x1a4>
			11c0: R_X86_64_PLT32	rt_mutarray_freeze-0x4
    11c4:	test   rax,rax
    11c7:	jne    11f2 <botlish_fn_10+0x1d2>
    11cd:	xor    rax,rax
    11d0:	mov    rbx,QWORD PTR [rsp+0x40]
    11d5:	mov    r12,QWORD PTR [rsp+0x48]
    11da:	mov    r13,QWORD PTR [rsp+0x50]
    11df:	mov    r14,QWORD PTR [rsp+0x58]
    11e4:	mov    r15,QWORD PTR [rsp+0x60]
    11e9:	add    rsp,0x70
    11ed:	mov    rsp,rbp
    11f0:	pop    rbp
    11f1:	ret
    11f2:	mov    rbx,QWORD PTR [rsp+0x40]
    11f7:	mov    r12,QWORD PTR [rsp+0x48]
    11fc:	mov    r13,QWORD PTR [rsp+0x50]
    1201:	mov    r14,QWORD PTR [rsp+0x58]
    1206:	mov    r15,QWORD PTR [rsp+0x60]
    120b:	add    rsp,0x70
    120f:	mov    rsp,rbp
    1212:	pop    rbp
    1213:	ret
    1214:	add    BYTE PTR [rax],al
    1216:	add    BYTE PTR [rax],al
    1218:	add    BYTE PTR [rax],0x0
    121b:	add    BYTE PTR [rax],al
    121d:	add    BYTE PTR [rax],al
	...

0000000000001220 <botlish_entry_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    1220:	push   rbp
    1221:	mov    rbp,rsp
    1224:	mov    rsi,QWORD PTR [rdx]
    1227:	mov    r8,QWORD PTR [rdx+0x8]
    122b:	mov    rcx,QWORD PTR [rdx+0x10]
    122f:	mov    rdx,r8
    1232:	call   1237 <botlish_entry_10+0x17>
			1233: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1237:	mov    rsp,rbp
    123a:	pop    rbp
    123b:	ret
    123c:	add    BYTE PTR [rax],al
	...

0000000000001240 <botlish_fn_11: peek<str, int>>:
    1240:	push   rbp
    1241:	mov    rbp,rsp
    1244:	sub    rsp,0x40
    1248:	mov    QWORD PTR [rsp+0x20],rbx
    124d:	mov    QWORD PTR [rsp+0x28],r12
    1252:	mov    QWORD PTR [rsp+0x30],r13
    1257:	mov    r13,rdi
    125a:	mov    QWORD PTR [rsp],rsi
    125e:	mov    r12,rsi
    1261:	mov    QWORD PTR [rsp+0x8],rdx
    1266:	mov    rbx,rdx
    1269:	mov    rsi,r12
    126c:	mov    rdi,r13
    126f:	call   1274 <botlish_fn_11+0x34>
			1270: R_X86_64_PLT32	rt_str_len-0x4
    1274:	mov    rcx,rbx
    1277:	and    rcx,rax
    127a:	mov    rdx,rax
    127d:	test   rcx,0x1
    1284:	jne    12aa <botlish_fn_11+0x6a>
    128a:	mov    rsi,rbx
    128d:	mov    rdi,r13
    1290:	call   1295 <botlish_fn_11+0x55>
			1291: R_X86_64_PLT32	rt_int_cmp-0x4
    1295:	mov    ecx,0x2
    129a:	test   rax,rax
    129d:	cmovge rcx,QWORD PTR [rip+0xd3]        # 1378 <botlish_fn_11+0x138>
    12a5:	jmp    12ba <botlish_fn_11+0x7a>
    12aa:	mov    ecx,0x2
    12af:	cmp    rbx,rdx
    12b2:	cmovge rcx,QWORD PTR [rip+0xbe]        # 1378 <botlish_fn_11+0x138>
    12ba:	cmp    rcx,0x6
    12be:	je     134e <botlish_fn_11+0x10e>
    12c4:	mov    QWORD PTR [rsp+0x10],0x3
    12cd:	test   rbx,0x1
    12d4:	je     12ec <botlish_fn_11+0xac>
    12da:	mov    rcx,rbx
    12dd:	add    rcx,0x2
    12e1:	seto   al
    12e4:	test   al,al
    12e6:	je     12ff <botlish_fn_11+0xbf>
    12ec:	mov    edx,0x3
    12f1:	mov    rsi,rbx
    12f4:	mov    rdi,r13
    12f7:	call   12fc <botlish_fn_11+0xbc>
			12f8: R_X86_64_PLT32	rt_int_add-0x4
    12fc:	mov    rcx,rax
    12ff:	mov    QWORD PTR [rsp+0x10],rcx
    1304:	mov    rdx,rbx
    1307:	mov    rsi,r12
    130a:	mov    rdi,r13
    130d:	call   1312 <botlish_fn_11+0xd2>
			130e: R_X86_64_PLT32	rt_substr-0x4
    1312:	test   rax,rax
    1315:	jne    1336 <botlish_fn_11+0xf6>
    131b:	xor    rax,rax
    131e:	mov    rbx,QWORD PTR [rsp+0x20]
    1323:	mov    r12,QWORD PTR [rsp+0x28]
    1328:	mov    r13,QWORD PTR [rsp+0x30]
    132d:	add    rsp,0x40
    1331:	mov    rsp,rbp
    1334:	pop    rbp
    1335:	ret
    1336:	mov    rbx,QWORD PTR [rsp+0x20]
    133b:	mov    r12,QWORD PTR [rsp+0x28]
    1340:	mov    r13,QWORD PTR [rsp+0x30]
    1345:	add    rsp,0x40
    1349:	mov    rsp,rbp
    134c:	pop    rbp
    134d:	ret
    134e:	mov    rdi,r13
    1351:	mov    rax,QWORD PTR [rdi+0x10]
    1355:	mov    rax,QWORD PTR [rax+0x10]
    1359:	mov    rbx,QWORD PTR [rsp+0x20]
    135e:	mov    r12,QWORD PTR [rsp+0x28]
    1363:	mov    r13,QWORD PTR [rsp+0x30]
    1368:	add    rsp,0x40
    136c:	mov    rsp,rbp
    136f:	pop    rbp
    1370:	ret
    1371:	add    BYTE PTR [rax],al
    1373:	add    BYTE PTR [rax],al
    1375:	add    BYTE PTR [rax],al
    1377:	add    BYTE PTR [rsi],al
    1379:	add    BYTE PTR [rax],al
    137b:	add    BYTE PTR [rax],al
    137d:	add    BYTE PTR [rax],al
	...

0000000000001380 <botlish_entry_11: peek<str, int>>:
    1380:	push   rbp
    1381:	mov    rbp,rsp
    1384:	mov    rsi,QWORD PTR [rdx]
    1387:	mov    rdx,QWORD PTR [rdx+0x8]
    138b:	call   1390 <botlish_entry_11+0x10>
			138c: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1390:	mov    rsp,rbp
    1393:	pop    rbp
    1394:	ret
    1395:	add    BYTE PTR [rax],al
	...

0000000000001398 <botlish_fn_12: peek<str, int>>:
    1398:	push   rbp
    1399:	mov    rbp,rsp
    139c:	sub    rsp,0x50
    13a0:	mov    QWORD PTR [rsp+0x20],rbx
    13a5:	mov    QWORD PTR [rsp+0x28],r12
    13aa:	mov    QWORD PTR [rsp+0x30],r13
    13af:	mov    QWORD PTR [rsp+0x38],r14
    13b4:	mov    QWORD PTR [rsp+0x40],r15
    13b9:	mov    r12,rcx
    13bc:	mov    r14,rdi
    13bf:	mov    QWORD PTR [rsp],rsi
    13c3:	mov    r13,rsi
    13c6:	mov    QWORD PTR [rsp+0x8],rdx
    13cb:	mov    rbx,rdx
    13ce:	mov    rsi,r13
    13d1:	mov    rdi,r14
    13d4:	call   13d9 <botlish_fn_12+0x41>
			13d5: R_X86_64_PLT32	rt_str_len-0x4
    13d9:	mov    rcx,rbx
    13dc:	and    rcx,rax
    13df:	mov    rdx,rax
    13e2:	test   rcx,0x1
    13e9:	jne    140f <botlish_fn_12+0x77>
    13ef:	mov    rsi,rbx
    13f2:	mov    rdi,r14
    13f5:	call   13fa <botlish_fn_12+0x62>
			13f6: R_X86_64_PLT32	rt_int_cmp-0x4
    13fa:	mov    ecx,0x2
    13ff:	test   rax,rax
    1402:	cmovge rcx,QWORD PTR [rip+0x11e]        # 1528 <botlish_fn_12+0x190>
    140a:	jmp    141f <botlish_fn_12+0x87>
    140f:	mov    ecx,0x2
    1414:	cmp    rbx,rdx
    1417:	cmovge rcx,QWORD PTR [rip+0x109]        # 1528 <botlish_fn_12+0x190>
    141f:	cmp    rcx,0x6
    1423:	je     14e3 <botlish_fn_12+0x14b>
    1429:	mov    QWORD PTR [rsp+0x10],0x3
    1432:	test   rbx,0x1
    1439:	je     145c <botlish_fn_12+0xc4>
    143f:	mov    rax,rbx
    1442:	add    rax,0x2
    1446:	seto   cl
    1449:	test   cl,cl
    144b:	jne    145c <botlish_fn_12+0xc4>
    1451:	mov    rdi,r14
    1454:	mov    r15,rax
    1457:	jmp    1472 <botlish_fn_12+0xda>
    145c:	mov    edx,0x3
    1461:	mov    rsi,rbx
    1464:	mov    rdi,r14
    1467:	call   146c <botlish_fn_12+0xd4>
			1468: R_X86_64_PLT32	rt_int_add-0x4
    146c:	mov    r15,rax
    146f:	mov    rdi,r14
    1472:	mov    rdi,r14
    1475:	mov    rcx,r15
    1478:	mov    rdx,rbx
    147b:	mov    rsi,r13
    147e:	call   1483 <botlish_fn_12+0xeb>
			147f: R_X86_64_PLT32	rt_str_region_check-0x4
    1483:	test   rax,rax
    1486:	jne    14b1 <botlish_fn_12+0x119>
    148c:	xor    rax,rax
    148f:	mov    rbx,QWORD PTR [rsp+0x20]
    1494:	mov    r12,QWORD PTR [rsp+0x28]
    1499:	mov    r13,QWORD PTR [rsp+0x30]
    149e:	mov    r14,QWORD PTR [rsp+0x38]
    14a3:	mov    r15,QWORD PTR [rsp+0x40]
    14a8:	add    rsp,0x50
    14ac:	mov    rsp,rbp
    14af:	pop    rbp
    14b0:	ret
    14b1:	mov    rcx,r12
    14b4:	mov    QWORD PTR [rcx],rbx
    14b7:	mov    rax,r15
    14ba:	mov    QWORD PTR [rcx+0x8],rax
    14be:	mov    rax,r13
    14c1:	mov    rbx,QWORD PTR [rsp+0x20]
    14c6:	mov    r12,QWORD PTR [rsp+0x28]
    14cb:	mov    r13,QWORD PTR [rsp+0x30]
    14d0:	mov    r14,QWORD PTR [rsp+0x38]
    14d5:	mov    r15,QWORD PTR [rsp+0x40]
    14da:	add    rsp,0x50
    14de:	mov    rsp,rbp
    14e1:	pop    rbp
    14e2:	ret
    14e3:	mov    rcx,r12
    14e6:	mov    rdi,r14
    14e9:	mov    rax,QWORD PTR [rdi+0x10]
    14ed:	mov    rax,QWORD PTR [rax+0x10]
    14f1:	mov    QWORD PTR [rcx],0x1
    14f8:	mov    QWORD PTR [rcx+0x8],0x1
    1500:	mov    rbx,QWORD PTR [rsp+0x20]
    1505:	mov    r12,QWORD PTR [rsp+0x28]
    150a:	mov    r13,QWORD PTR [rsp+0x30]
    150f:	mov    r14,QWORD PTR [rsp+0x38]
    1514:	mov    r15,QWORD PTR [rsp+0x40]
    1519:	add    rsp,0x50
    151d:	mov    rsp,rbp
    1520:	pop    rbp
    1521:	ret
    1522:	add    BYTE PTR [rax],al
    1524:	add    BYTE PTR [rax],al
    1526:	add    BYTE PTR [rax],al
    1528:	(bad)
    1529:	add    BYTE PTR [rax],al
    152b:	add    BYTE PTR [rax],al
    152d:	add    BYTE PTR [rax],al
	...

0000000000001530 <botlish_entry_12: peek<str, int>>:
    1530:	push   rbp
    1531:	mov    rbp,rsp
    1534:	ud2

0000000000001536 <botlish_fn_13: scan_unquoted<str, int, int>>:
    1536:	push   rbp
    1537:	mov    rbp,rsp
    153a:	sub    rsp,0x80
    1541:	mov    QWORD PTR [rsp+0x50],rbx
    1546:	mov    QWORD PTR [rsp+0x58],r12
    154b:	mov    QWORD PTR [rsp+0x60],r13
    1550:	mov    QWORD PTR [rsp+0x68],r14
    1555:	mov    QWORD PTR [rsp+0x70],r15
    155a:	mov    QWORD PTR [rsp+0x30],rdi
    155f:	mov    QWORD PTR [rsp+0x18],0x0
    1568:	mov    QWORD PTR [rsp],rsi
    156c:	mov    r15,rsi
    156f:	mov    QWORD PTR [rsp+0x8],rdx
    1574:	mov    r14,rdx
    1577:	mov    QWORD PTR [rsp+0x10],rcx
    157c:	lea    r13,[rsp+0x20]
    1581:	mov    QWORD PTR [rsp+0x38],rcx
    1586:	mov    rcx,r13
    1589:	mov    rdx,QWORD PTR [rsp+0x38]
    158e:	mov    rsi,r15
    1591:	mov    rdi,QWORD PTR [rsp+0x30]
    1596:	call   159b <botlish_fn_13+0x65>
			1597: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    159b:	mov    rsi,rax
    159e:	mov    QWORD PTR [rsp+0x40],rax
    15a3:	test   rax,rsi
    15a6:	je     1700 <botlish_fn_13+0x1ca>
    15ac:	mov    rbx,QWORD PTR [rsp+0x20]
    15b1:	mov    r12,QWORD PTR [rsp+0x28]
    15b6:	mov    rdi,QWORD PTR [rsp+0x30]
    15bb:	mov    rcx,QWORD PTR [rdi+0x10]
    15bf:	mov    r8,QWORD PTR [rcx+0x10]
    15c3:	mov    rcx,r12
    15c6:	mov    rdx,rbx
    15c9:	mov    rsi,QWORD PTR [rsp+0x40]
    15ce:	call   15d3 <botlish_fn_13+0x9d>
			15cf: R_X86_64_PLT32	rt_str_region_eq-0x4
    15d3:	cmp    rax,0x6
    15d7:	je     1618 <botlish_fn_13+0xe2>
    15dd:	mov    rdi,QWORD PTR [rsp+0x30]
    15e2:	mov    rax,QWORD PTR [rdi+0x10]
    15e6:	mov    r8,QWORD PTR [rax+0x18]
    15ea:	mov    rcx,r12
    15ed:	mov    rdx,rbx
    15f0:	mov    rsi,QWORD PTR [rsp+0x40]
    15f5:	call   15fa <botlish_fn_13+0xc4>
			15f6: R_X86_64_PLT32	rt_str_region_eq-0x4
    15fa:	cmp    rax,0x6
    15fe:	je     160e <botlish_fn_13+0xd8>
    1604:	mov    eax,0x2
    1609:	jmp    161d <botlish_fn_13+0xe7>
    160e:	mov    eax,0x6
    1613:	jmp    161d <botlish_fn_13+0xe7>
    1618:	mov    eax,0x6
    161d:	cmp    rax,0x6
    1621:	je     1662 <botlish_fn_13+0x12c>
    1627:	mov    rdi,QWORD PTR [rsp+0x30]
    162c:	mov    rax,QWORD PTR [rdi+0x10]
    1630:	mov    r8,QWORD PTR [rax+0x20]
    1634:	mov    rcx,r12
    1637:	mov    rdx,rbx
    163a:	mov    rsi,QWORD PTR [rsp+0x40]
    163f:	call   1644 <botlish_fn_13+0x10e>
			1640: R_X86_64_PLT32	rt_str_region_eq-0x4
    1644:	cmp    rax,0x6
    1648:	je     1658 <botlish_fn_13+0x122>
    164e:	mov    eax,0x2
    1653:	jmp    1667 <botlish_fn_13+0x131>
    1658:	mov    eax,0x6
    165d:	jmp    1667 <botlish_fn_13+0x131>
    1662:	mov    eax,0x6
    1667:	cmp    rax,0x6
    166b:	je     16e2 <botlish_fn_13+0x1ac>
    1671:	mov    QWORD PTR [rsp+0x18],0x3
    167a:	mov    rsi,QWORD PTR [rsp+0x38]
    167f:	test   rsi,0x1
    1686:	je     16ad <botlish_fn_13+0x177>
    168c:	mov    rsi,QWORD PTR [rsp+0x38]
    1691:	mov    rax,rsi
    1694:	add    rax,0x2
    1698:	seto   sil
    169c:	test   sil,sil
    169f:	jne    16ad <botlish_fn_13+0x177>
    16a5:	mov    rsi,r15
    16a8:	jmp    16c4 <botlish_fn_13+0x18e>
    16ad:	mov    edx,0x3
    16b2:	mov    rsi,QWORD PTR [rsp+0x38]
    16b7:	mov    rdi,QWORD PTR [rsp+0x30]
    16bc:	call   16c1 <botlish_fn_13+0x18b>
			16bd: R_X86_64_PLT32	rt_int_add-0x4
    16c1:	mov    rsi,r15
    16c4:	mov    QWORD PTR [rsp],rsi
    16c8:	mov    rdx,r14
    16cb:	mov    QWORD PTR [rsp+0x8],rdx
    16d0:	mov    QWORD PTR [rsp+0x10],rax
    16d5:	mov    r15,rsi
    16d8:	mov    QWORD PTR [rsp+0x38],rax
    16dd:	jmp    1586 <botlish_fn_13+0x50>
    16e2:	mov    rdx,r14
    16e5:	mov    rsi,r15
    16e8:	mov    rdi,QWORD PTR [rsp+0x30]
    16ed:	mov    rcx,QWORD PTR [rsp+0x38]
    16f2:	call   16f7 <botlish_fn_13+0x1c1>
			16f3: R_X86_64_PLT32	rt_substr-0x4
    16f7:	test   rax,rax
    16fa:	jne    172b <botlish_fn_13+0x1f5>
    1700:	xor    rdx,rdx
    1703:	mov    rax,rdx
    1706:	mov    rbx,QWORD PTR [rsp+0x50]
    170b:	mov    r12,QWORD PTR [rsp+0x58]
    1710:	mov    r13,QWORD PTR [rsp+0x60]
    1715:	mov    r14,QWORD PTR [rsp+0x68]
    171a:	mov    r15,QWORD PTR [rsp+0x70]
    171f:	add    rsp,0x80
    1726:	mov    rsp,rbp
    1729:	pop    rbp
    172a:	ret
    172b:	mov    rdx,QWORD PTR [rsp+0x38]
    1730:	mov    rbx,QWORD PTR [rsp+0x50]
    1735:	mov    r12,QWORD PTR [rsp+0x58]
    173a:	mov    r13,QWORD PTR [rsp+0x60]
    173f:	mov    r14,QWORD PTR [rsp+0x68]
    1744:	mov    r15,QWORD PTR [rsp+0x70]
    1749:	add    rsp,0x80
    1750:	mov    rsp,rbp
    1753:	pop    rbp
    1754:	ret

0000000000001755 <botlish_entry_13: scan_unquoted<str, int, int>>:
    1755:	push   rbp
    1756:	mov    rbp,rsp
    1759:	ud2

000000000000175b <botlish_fn_14: scan_quoted<str, int, str>>:
    175b:	push   rbp
    175c:	mov    rbp,rsp
    175f:	sub    rsp,0x70
    1763:	mov    QWORD PTR [rsp+0x40],rbx
    1768:	mov    QWORD PTR [rsp+0x48],r12
    176d:	mov    QWORD PTR [rsp+0x50],r13
    1772:	mov    QWORD PTR [rsp+0x58],r14
    1777:	mov    QWORD PTR [rsp+0x60],r15
    177c:	mov    r13,rdi
    177f:	mov    QWORD PTR [rsp+0x18],0x0
    1788:	mov    QWORD PTR [rsp+0x20],0x0
    1791:	mov    QWORD PTR [rsp],rsi
    1795:	mov    QWORD PTR [rsp+0x8],rdx
    179a:	mov    QWORD PTR [rsp+0x10],rcx
    179f:	lea    r12,[rsp+0x28]
    17a4:	mov    rbx,rsi
    17a7:	mov    r14,rdx
    17aa:	mov    r15,rcx
    17ad:	mov    rdx,r14
    17b0:	mov    rsi,rbx
    17b3:	mov    rdi,r13
    17b6:	call   17bb <botlish_fn_14+0x60>
			17b7: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    17bb:	test   rax,rax
    17be:	je     19da <botlish_fn_14+0x27f>
    17c4:	mov    QWORD PTR [rsp+0x18],rax
    17c9:	mov    rdi,r13
    17cc:	mov    QWORD PTR [rsp+0x38],rax
    17d1:	mov    rcx,QWORD PTR [rdi+0x10]
    17d5:	mov    rsi,QWORD PTR [rcx+0x28]
    17d9:	mov    edx,0x1
    17de:	mov    ecx,0x3
    17e3:	mov    r8,QWORD PTR [rsp+0x38]
    17e8:	call   17ed <botlish_fn_14+0x92>
			17e9: R_X86_64_PLT32	rt_str_region_eq-0x4
    17ed:	cmp    rax,0x6
    17f1:	je     1874 <botlish_fn_14+0x119>
    17f7:	mov    QWORD PTR [rsp+0x20],0x3
    1800:	mov    rsi,r14
    1803:	test   rsi,0x1
    180a:	je     182a <botlish_fn_14+0xcf>
    1810:	mov    rax,rsi
    1813:	add    rax,0x2
    1817:	seto   cl
    181a:	test   cl,cl
    181c:	jne    182a <botlish_fn_14+0xcf>
    1822:	mov    rsi,rax
    1825:	jmp    183a <botlish_fn_14+0xdf>
    182a:	mov    edx,0x3
    182f:	mov    rdi,r13
    1832:	call   1837 <botlish_fn_14+0xdc>
			1833: R_X86_64_PLT32	rt_int_add-0x4
    1837:	mov    rsi,rax
    183a:	mov    QWORD PTR [rsp+0x8],rsi
    183f:	mov    r14,rsi
    1842:	mov    rsi,r15
    1845:	mov    rdx,QWORD PTR [rsp+0x38]
    184a:	mov    rdi,r13
    184d:	call   1852 <botlish_fn_14+0xf7>
			184e: R_X86_64_PLT32	rt_str_cat-0x4
    1852:	test   rax,rax
    1855:	je     19da <botlish_fn_14+0x27f>
    185b:	mov    QWORD PTR [rsp],rbx
    185f:	mov    rsi,r14
    1862:	mov    QWORD PTR [rsp+0x8],rsi
    1867:	mov    QWORD PTR [rsp+0x10],rax
    186c:	mov    r15,rax
    186f:	jmp    17ad <botlish_fn_14+0x52>
    1874:	mov    QWORD PTR [rsp+0x18],0x3
    187d:	mov    rsi,r14
    1880:	test   rsi,0x1
    1887:	je     18a2 <botlish_fn_14+0x147>
    188d:	mov    rsi,r14
    1890:	mov    rdx,rsi
    1893:	add    rdx,0x2
    1897:	seto   al
    189a:	test   al,al
    189c:	je     18b5 <botlish_fn_14+0x15a>
    18a2:	mov    edx,0x3
    18a7:	mov    rsi,r14
    18aa:	mov    rdi,r13
    18ad:	call   18b2 <botlish_fn_14+0x157>
			18ae: R_X86_64_PLT32	rt_int_add-0x4
    18b2:	mov    rdx,rax
    18b5:	mov    QWORD PTR [rsp+0x18],rdx
    18ba:	mov    rcx,r12
    18bd:	mov    rsi,rbx
    18c0:	mov    rdi,r13
    18c3:	call   18c8 <botlish_fn_14+0x16d>
			18c4: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    18c8:	test   rax,rax
    18cb:	mov    rsi,rax
    18ce:	je     19da <botlish_fn_14+0x27f>
    18d4:	mov    rdx,QWORD PTR [rsp+0x28]
    18d9:	mov    rcx,QWORD PTR [rsp+0x30]
    18de:	mov    rdi,r13
    18e1:	mov    rax,QWORD PTR [rdi+0x10]
    18e5:	mov    r8,QWORD PTR [rax+0x28]
    18e9:	call   18ee <botlish_fn_14+0x193>
			18ea: R_X86_64_PLT32	rt_str_region_eq-0x4
    18ee:	cmp    rax,0x6
    18f2:	je     1965 <botlish_fn_14+0x20a>
    18f8:	mov    QWORD PTR [rsp],0x3
    1900:	mov    rsi,r14
    1903:	test   rsi,0x1
    190a:	je     192d <botlish_fn_14+0x1d2>
    1910:	mov    rsi,r14
    1913:	mov    rdx,rsi
    1916:	add    rdx,0x2
    191a:	seto   al
    191d:	test   al,al
    191f:	jne    192d <botlish_fn_14+0x1d2>
    1925:	mov    rax,r15
    1928:	jmp    1943 <botlish_fn_14+0x1e8>
    192d:	mov    edx,0x3
    1932:	mov    rsi,r14
    1935:	mov    rdi,r13
    1938:	call   193d <botlish_fn_14+0x1e2>
			1939: R_X86_64_PLT32	rt_int_add-0x4
    193d:	mov    rdx,rax
    1940:	mov    rax,r15
    1943:	mov    rbx,QWORD PTR [rsp+0x40]
    1948:	mov    r12,QWORD PTR [rsp+0x48]
    194d:	mov    r13,QWORD PTR [rsp+0x50]
    1952:	mov    r14,QWORD PTR [rsp+0x58]
    1957:	mov    r15,QWORD PTR [rsp+0x60]
    195c:	add    rsp,0x70
    1960:	mov    rsp,rbp
    1963:	pop    rbp
    1964:	ret
    1965:	mov    QWORD PTR [rsp+0x18],0x5
    196e:	mov    rsi,r14
    1971:	test   rsi,0x1
    1978:	je     199e <botlish_fn_14+0x243>
    197e:	mov    rsi,r14
    1981:	mov    rax,rsi
    1984:	add    rax,0x4
    1988:	seto   cl
    198b:	test   cl,cl
    198d:	jne    199e <botlish_fn_14+0x243>
    1993:	mov    rsi,rax
    1996:	mov    r14,rax
    1999:	jmp    19b4 <botlish_fn_14+0x259>
    199e:	mov    edx,0x5
    19a3:	mov    rsi,r14
    19a6:	mov    rdi,r13
    19a9:	call   19ae <botlish_fn_14+0x253>
			19aa: R_X86_64_PLT32	rt_int_add-0x4
    19ae:	mov    rsi,rax
    19b1:	mov    r14,rax
    19b4:	mov    QWORD PTR [rsp+0x8],rsi
    19b9:	mov    rdi,r13
    19bc:	mov    rax,QWORD PTR [rdi+0x10]
    19c0:	mov    rdx,QWORD PTR [rax+0x28]
    19c4:	mov    QWORD PTR [rsp+0x18],rdx
    19c9:	mov    rsi,r15
    19cc:	call   19d1 <botlish_fn_14+0x276>
			19cd: R_X86_64_PLT32	rt_str_cat-0x4
    19d1:	test   rax,rax
    19d4:	jne    1a02 <botlish_fn_14+0x2a7>
    19da:	xor    rdx,rdx
    19dd:	mov    rax,rdx
    19e0:	mov    rbx,QWORD PTR [rsp+0x40]
    19e5:	mov    r12,QWORD PTR [rsp+0x48]
    19ea:	mov    r13,QWORD PTR [rsp+0x50]
    19ef:	mov    r14,QWORD PTR [rsp+0x58]
    19f4:	mov    r15,QWORD PTR [rsp+0x60]
    19f9:	add    rsp,0x70
    19fd:	mov    rsp,rbp
    1a00:	pop    rbp
    1a01:	ret
    1a02:	mov    QWORD PTR [rsp],rbx
    1a06:	mov    rsi,r14
    1a09:	mov    QWORD PTR [rsp+0x8],rsi
    1a0e:	mov    QWORD PTR [rsp+0x10],rax
    1a13:	mov    r15,rax
    1a16:	jmp    17ad <botlish_fn_14+0x52>

0000000000001a1b <botlish_entry_14: scan_quoted<str, int, str>>:
    1a1b:	push   rbp
    1a1c:	mov    rbp,rsp
    1a1f:	ud2

0000000000001a21 <botlish_fn_15: scan_field<str, int>>:
    1a21:	push   rbp
    1a22:	mov    rbp,rsp
    1a25:	sub    rsp,0x50
    1a29:	mov    QWORD PTR [rsp+0x30],rbx
    1a2e:	mov    QWORD PTR [rsp+0x38],r12
    1a33:	mov    QWORD PTR [rsp+0x40],r13
    1a38:	mov    r12,rdi
    1a3b:	mov    r13,rdx
    1a3e:	mov    QWORD PTR [rsp+0x10],0x0
    1a47:	mov    QWORD PTR [rsp],rsi
    1a4b:	mov    rbx,rsi
    1a4e:	mov    QWORD PTR [rsp+0x8],rdx
    1a53:	lea    rcx,[rsp+0x18]
    1a58:	mov    rdx,r13
    1a5b:	mov    rsi,rbx
    1a5e:	mov    rdi,r12
    1a61:	call   1a66 <botlish_fn_15+0x45>
			1a62: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1a66:	test   rax,rax
    1a69:	mov    rsi,rax
    1a6c:	je     1b37 <botlish_fn_15+0x116>
    1a72:	mov    rdx,QWORD PTR [rsp+0x18]
    1a77:	mov    rcx,QWORD PTR [rsp+0x20]
    1a7c:	mov    rdi,r12
    1a7f:	mov    rax,QWORD PTR [rdi+0x10]
    1a83:	mov    r8,QWORD PTR [rax+0x28]
    1a87:	call   1a8c <botlish_fn_15+0x6b>
			1a88: R_X86_64_PLT32	rt_str_region_eq-0x4
    1a8c:	cmp    rax,0x6
    1a90:	je     1ac8 <botlish_fn_15+0xa7>
    1a96:	mov    rcx,r13
    1a99:	mov    rsi,rbx
    1a9c:	mov    rdi,r12
    1a9f:	mov    rdx,rcx
    1aa2:	call   1aa7 <botlish_fn_15+0x86>
			1aa3: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    1aa7:	test   rax,rax
    1aaa:	je     1b37 <botlish_fn_15+0x116>
    1ab0:	mov    rbx,QWORD PTR [rsp+0x30]
    1ab5:	mov    r12,QWORD PTR [rsp+0x38]
    1aba:	mov    r13,QWORD PTR [rsp+0x40]
    1abf:	add    rsp,0x50
    1ac3:	mov    rsp,rbp
    1ac6:	pop    rbp
    1ac7:	ret
    1ac8:	mov    rcx,r13
    1acb:	mov    QWORD PTR [rsp+0x10],0x3
    1ad4:	test   rcx,0x1
    1adb:	jne    1ae9 <botlish_fn_15+0xc8>
    1ae1:	mov    r13,rcx
    1ae4:	jmp    1afe <botlish_fn_15+0xdd>
    1ae9:	mov    rdx,rcx
    1aec:	add    rdx,0x2
    1af0:	mov    r13,rcx
    1af3:	seto   al
    1af6:	test   al,al
    1af8:	je     1b11 <botlish_fn_15+0xf0>
    1afe:	mov    edx,0x3
    1b03:	mov    rsi,r13
    1b06:	mov    rdi,r12
    1b09:	call   1b0e <botlish_fn_15+0xed>
			1b0a: R_X86_64_PLT32	rt_int_add-0x4
    1b0e:	mov    rdx,rax
    1b11:	mov    QWORD PTR [rsp+0x8],rdx
    1b16:	mov    rdi,r12
    1b19:	mov    rax,QWORD PTR [rdi+0x10]
    1b1d:	mov    rcx,QWORD PTR [rax+0x10]
    1b21:	mov    QWORD PTR [rsp+0x10],rcx
    1b26:	mov    rsi,rbx
    1b29:	call   1b2e <botlish_fn_15+0x10d>
			1b2a: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    1b2e:	test   rax,rax
    1b31:	jne    1b55 <botlish_fn_15+0x134>
    1b37:	xor    rdx,rdx
    1b3a:	mov    rax,rdx
    1b3d:	mov    rbx,QWORD PTR [rsp+0x30]
    1b42:	mov    r12,QWORD PTR [rsp+0x38]
    1b47:	mov    r13,QWORD PTR [rsp+0x40]
    1b4c:	add    rsp,0x50
    1b50:	mov    rsp,rbp
    1b53:	pop    rbp
    1b54:	ret
    1b55:	mov    rbx,QWORD PTR [rsp+0x30]
    1b5a:	mov    r12,QWORD PTR [rsp+0x38]
    1b5f:	mov    r13,QWORD PTR [rsp+0x40]
    1b64:	add    rsp,0x50
    1b68:	mov    rsp,rbp
    1b6b:	pop    rbp
    1b6c:	ret

0000000000001b6d <botlish_entry_15: scan_field<str, int>>:
    1b6d:	push   rbp
    1b6e:	mov    rbp,rsp
    1b71:	ud2

0000000000001b73 <botlish_fn_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    1b73:	push   rbp
    1b74:	mov    rbp,rsp
    1b77:	sub    rsp,0xa0
    1b7e:	mov    QWORD PTR [rsp+0x70],rbx
    1b83:	mov    QWORD PTR [rsp+0x78],r12
    1b88:	mov    QWORD PTR [rsp+0x80],r13
    1b90:	mov    QWORD PTR [rsp+0x88],r14
    1b98:	mov    QWORD PTR [rsp+0x90],r15
    1ba0:	mov    r13,rdi
    1ba3:	mov    QWORD PTR [rsp+0x28],0x0
    1bac:	mov    QWORD PTR [rsp],rsi
    1bb0:	mov    r15,rsi
    1bb3:	mov    QWORD PTR [rsp+0x8],rdx
    1bb8:	mov    QWORD PTR [rsp+0x10],rcx
    1bbd:	mov    QWORD PTR [rsp+0x50],rcx
    1bc2:	mov    QWORD PTR [rsp+0x18],r8
    1bc7:	mov    r12,r8
    1bca:	mov    QWORD PTR [rsp+0x20],r9
    1bcf:	mov    rbx,r9
    1bd2:	mov    rsi,r15
    1bd5:	mov    rdi,r13
    1bd8:	call   1bdd <botlish_fn_16+0x6a>
			1bd9: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    1bdd:	test   rax,rax
    1be0:	je     1e14 <botlish_fn_16+0x2a1>
    1be6:	mov    QWORD PTR [rsp+0x8],rax
    1beb:	mov    r8,rax
    1bee:	mov    QWORD PTR [rsp+0x28],rdx
    1bf3:	mov    r14,rdx
    1bf6:	lea    r9,[rsp+0x30]
    1bfb:	mov    rcx,rbx
    1bfe:	mov    rdx,r12
    1c01:	mov    rsi,QWORD PTR [rsp+0x50]
    1c06:	mov    rdi,r13
    1c09:	call   1c0e <botlish_fn_16+0x9b>
			1c0a: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[list<never>, mutarray, int], str>
    1c0e:	test   rax,rax
    1c11:	je     1e14 <botlish_fn_16+0x2a1>
    1c17:	mov    QWORD PTR [rsp+0x8],rax
    1c1c:	mov    QWORD PTR [rsp+0x68],rax
    1c21:	mov    rdx,QWORD PTR [rsp+0x30]
    1c26:	mov    QWORD PTR [rsp+0x10],rdx
    1c2b:	mov    QWORD PTR [rsp+0x60],rdx
    1c30:	mov    rcx,QWORD PTR [rsp+0x38]
    1c35:	mov    QWORD PTR [rsp+0x18],rcx
    1c3a:	mov    QWORD PTR [rsp+0x58],rcx
    1c3f:	lea    rcx,[rsp+0x40]
    1c44:	mov    rdx,r14
    1c47:	mov    rsi,r15
    1c4a:	mov    rdi,r13
    1c4d:	call   1c52 <botlish_fn_16+0xdf>
			1c4e: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1c52:	test   rax,rax
    1c55:	mov    QWORD PTR [rsp+0x50],rax
    1c5a:	je     1e14 <botlish_fn_16+0x2a1>
    1c60:	mov    r12,QWORD PTR [rsp+0x40]
    1c65:	mov    rbx,QWORD PTR [rsp+0x48]
    1c6a:	mov    rdi,r13
    1c6d:	mov    rcx,QWORD PTR [rdi+0x10]
    1c71:	mov    r8,QWORD PTR [rcx+0x18]
    1c75:	mov    rcx,rbx
    1c78:	mov    rdx,r12
    1c7b:	mov    rsi,QWORD PTR [rsp+0x50]
    1c80:	call   1c85 <botlish_fn_16+0x112>
			1c81: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c85:	cmp    rax,0x6
    1c89:	je     1da3 <botlish_fn_16+0x230>
    1c8f:	mov    rdi,r13
    1c92:	mov    rax,QWORD PTR [rdi+0x10]
    1c96:	mov    r8,QWORD PTR [rax+0x20]
    1c9a:	mov    rcx,rbx
    1c9d:	mov    rdx,r12
    1ca0:	mov    rsi,QWORD PTR [rsp+0x50]
    1ca5:	call   1caa <botlish_fn_16+0x137>
			1ca6: R_X86_64_PLT32	rt_str_region_eq-0x4
    1caa:	cmp    rax,0x6
    1cae:	je     1d05 <botlish_fn_16+0x192>
    1cb4:	mov    rcx,QWORD PTR [rsp+0x58]
    1cb9:	mov    rdx,QWORD PTR [rsp+0x60]
    1cbe:	mov    rsi,QWORD PTR [rsp+0x68]
    1cc3:	mov    rdi,r13
    1cc6:	call   1ccb <botlish_fn_16+0x158>
			1cc7: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1ccb:	test   rax,rax
    1cce:	je     1e14 <botlish_fn_16+0x2a1>
    1cd4:	mov    rdx,r14
    1cd7:	mov    rbx,QWORD PTR [rsp+0x70]
    1cdc:	mov    r12,QWORD PTR [rsp+0x78]
    1ce1:	mov    r13,QWORD PTR [rsp+0x80]
    1ce9:	mov    r14,QWORD PTR [rsp+0x88]
    1cf1:	mov    r15,QWORD PTR [rsp+0x90]
    1cf9:	add    rsp,0xa0
    1d00:	mov    rsp,rbp
    1d03:	pop    rbp
    1d04:	ret
    1d05:	mov    rcx,QWORD PTR [rsp+0x58]
    1d0a:	mov    rdx,QWORD PTR [rsp+0x60]
    1d0f:	mov    rsi,QWORD PTR [rsp+0x68]
    1d14:	mov    rdi,r13
    1d17:	call   1d1c <botlish_fn_16+0x1a9>
			1d18: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1d1c:	test   rax,rax
    1d1f:	je     1e14 <botlish_fn_16+0x2a1>
    1d25:	mov    QWORD PTR [rsp],rax
    1d29:	mov    rbx,rax
    1d2c:	mov    QWORD PTR [rsp+0x8],0x3
    1d35:	mov    rdx,r14
    1d38:	test   rdx,0x1
    1d3f:	je     1d5f <botlish_fn_16+0x1ec>
    1d45:	mov    rdx,r14
    1d48:	add    rdx,0x2
    1d4c:	seto   al
    1d4f:	test   al,al
    1d51:	jne    1d5f <botlish_fn_16+0x1ec>
    1d57:	mov    rax,rbx
    1d5a:	jmp    1d75 <botlish_fn_16+0x202>
    1d5f:	mov    edx,0x3
    1d64:	mov    rsi,r14
    1d67:	mov    rdi,r13
    1d6a:	call   1d6f <botlish_fn_16+0x1fc>
			1d6b: R_X86_64_PLT32	rt_int_add-0x4
    1d6f:	mov    rdx,rax
    1d72:	mov    rax,rbx
    1d75:	mov    rbx,QWORD PTR [rsp+0x70]
    1d7a:	mov    r12,QWORD PTR [rsp+0x78]
    1d7f:	mov    r13,QWORD PTR [rsp+0x80]
    1d87:	mov    r14,QWORD PTR [rsp+0x88]
    1d8f:	mov    r15,QWORD PTR [rsp+0x90]
    1d97:	add    rsp,0xa0
    1d9e:	mov    rsp,rbp
    1da1:	pop    rbp
    1da2:	ret
    1da3:	mov    rsi,r14
    1da6:	mov    edx,0x3
    1dab:	mov    rcx,rdx
    1dae:	mov    QWORD PTR [rsp+0x20],0x3
    1db7:	test   rsi,0x1
    1dbe:	jne    1dcc <botlish_fn_16+0x259>
    1dc4:	mov    rdx,rcx
    1dc7:	jmp    1de1 <botlish_fn_16+0x26e>
    1dcc:	mov    rdx,rsi
    1dcf:	add    rdx,0x2
    1dd3:	seto   al
    1dd6:	test   al,al
    1dd8:	je     1dec <botlish_fn_16+0x279>
    1dde:	mov    rdx,rcx
    1de1:	mov    rdi,r13
    1de4:	call   1de9 <botlish_fn_16+0x276>
			1de5: R_X86_64_PLT32	rt_int_add-0x4
    1de9:	mov    rdx,rax
    1dec:	mov    QWORD PTR [rsp+0x20],rdx
    1df1:	mov    rcx,QWORD PTR [rsp+0x68]
    1df6:	mov    rsi,r15
    1df9:	mov    rdi,r13
    1dfc:	mov    r8,QWORD PTR [rsp+0x60]
    1e01:	mov    r9,QWORD PTR [rsp+0x58]
    1e06:	call   1e0b <botlish_fn_16+0x298>
			1e07: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int, list[list<mutarray>, mutarray, int]>
    1e0b:	test   rax,rax
    1e0e:	jne    1e48 <botlish_fn_16+0x2d5>
    1e14:	xor    rdx,rdx
    1e17:	mov    rax,rdx
    1e1a:	mov    rbx,QWORD PTR [rsp+0x70]
    1e1f:	mov    r12,QWORD PTR [rsp+0x78]
    1e24:	mov    r13,QWORD PTR [rsp+0x80]
    1e2c:	mov    r14,QWORD PTR [rsp+0x88]
    1e34:	mov    r15,QWORD PTR [rsp+0x90]
    1e3c:	add    rsp,0xa0
    1e43:	mov    rsp,rbp
    1e46:	pop    rbp
    1e47:	ret
    1e48:	mov    rbx,QWORD PTR [rsp+0x70]
    1e4d:	mov    r12,QWORD PTR [rsp+0x78]
    1e52:	mov    r13,QWORD PTR [rsp+0x80]
    1e5a:	mov    r14,QWORD PTR [rsp+0x88]
    1e62:	mov    r15,QWORD PTR [rsp+0x90]
    1e6a:	add    rsp,0xa0
    1e71:	mov    rsp,rbp
    1e74:	pop    rbp
    1e75:	ret

0000000000001e76 <botlish_entry_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    1e76:	push   rbp
    1e77:	mov    rbp,rsp
    1e7a:	ud2

0000000000001e7c <botlish_fn_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    1e7c:	push   rbp
    1e7d:	mov    rbp,rsp
    1e80:	sub    rsp,0xb0
    1e87:	mov    QWORD PTR [rsp+0x80],rbx
    1e8f:	mov    QWORD PTR [rsp+0x88],r12
    1e97:	mov    QWORD PTR [rsp+0x90],r13
    1e9f:	mov    QWORD PTR [rsp+0x98],r14
    1ea7:	mov    QWORD PTR [rsp+0xa0],r15
    1eaf:	mov    QWORD PTR [rsp+0x50],rdi
    1eb4:	mov    QWORD PTR [rsp+0x28],0x0
    1ebd:	mov    QWORD PTR [rsp],rsi
    1ec1:	mov    QWORD PTR [rsp+0x8],rdx
    1ec6:	mov    QWORD PTR [rsp+0x10],rcx
    1ecb:	mov    QWORD PTR [rsp+0x18],r8
    1ed0:	mov    QWORD PTR [rsp+0x20],r9
    1ed5:	lea    r15,[rsp+0x30]
    1eda:	lea    rbx,[rsp+0x40]
    1edf:	mov    r12,rsi
    1ee2:	mov    r13,rcx
    1ee5:	mov    QWORD PTR [rsp+0x58],r8
    1eea:	mov    QWORD PTR [rsp+0x60],r9
    1eef:	mov    rsi,r12
    1ef2:	mov    rdi,QWORD PTR [rsp+0x50]
    1ef7:	call   1efc <botlish_fn_17+0x80>
			1ef8: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    1efc:	mov    QWORD PTR [rsp+0x78],rdx
    1f01:	test   rax,rax
    1f04:	je     205f <botlish_fn_17+0x1e3>
    1f0a:	mov    QWORD PTR [rsp+0x8],rax
    1f0f:	mov    rdx,QWORD PTR [rsp+0x78]
    1f14:	mov    r8,rax
    1f17:	mov    QWORD PTR [rsp+0x28],rdx
    1f1c:	mov    rcx,QWORD PTR [rsp+0x60]
    1f21:	mov    rdx,QWORD PTR [rsp+0x58]
    1f26:	mov    rsi,r13
    1f29:	mov    rdi,QWORD PTR [rsp+0x50]
    1f2e:	mov    r9,r15
    1f31:	call   1f36 <botlish_fn_17+0xba>
			1f32: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], str>
    1f36:	test   rax,rax
    1f39:	je     205f <botlish_fn_17+0x1e3>
    1f3f:	mov    QWORD PTR [rsp+0x8],rax
    1f44:	mov    QWORD PTR [rsp+0x70],rax
    1f49:	mov    rdx,QWORD PTR [rsp+0x30]
    1f4e:	mov    QWORD PTR [rsp+0x58],rdx
    1f53:	mov    QWORD PTR [rsp+0x10],rdx
    1f58:	mov    rcx,QWORD PTR [rsp+0x38]
    1f5d:	mov    QWORD PTR [rsp+0x18],rcx
    1f62:	mov    QWORD PTR [rsp+0x60],rcx
    1f67:	mov    rcx,rbx
    1f6a:	mov    rdx,QWORD PTR [rsp+0x78]
    1f6f:	mov    rsi,r12
    1f72:	mov    rdi,QWORD PTR [rsp+0x50]
    1f77:	call   1f7c <botlish_fn_17+0x100>
			1f78: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1f7c:	test   rax,rax
    1f7f:	mov    QWORD PTR [rsp+0x68],rax
    1f84:	je     205f <botlish_fn_17+0x1e3>
    1f8a:	mov    r13,QWORD PTR [rsp+0x40]
    1f8f:	mov    r14,QWORD PTR [rsp+0x48]
    1f94:	mov    rdi,QWORD PTR [rsp+0x50]
    1f99:	mov    rcx,QWORD PTR [rdi+0x10]
    1f9d:	mov    r8,QWORD PTR [rcx+0x18]
    1fa1:	mov    rcx,r14
    1fa4:	mov    rdx,r13
    1fa7:	mov    rsi,QWORD PTR [rsp+0x68]
    1fac:	call   1fb1 <botlish_fn_17+0x135>
			1fad: R_X86_64_PLT32	rt_str_region_eq-0x4
    1fb1:	cmp    rax,0x6
    1fb5:	je     2125 <botlish_fn_17+0x2a9>
    1fbb:	mov    rdi,QWORD PTR [rsp+0x50]
    1fc0:	mov    rax,QWORD PTR [rdi+0x10]
    1fc4:	mov    r8,QWORD PTR [rax+0x20]
    1fc8:	mov    rcx,r14
    1fcb:	mov    rdx,r13
    1fce:	mov    rsi,QWORD PTR [rsp+0x68]
    1fd3:	call   1fd8 <botlish_fn_17+0x15c>
			1fd4: R_X86_64_PLT32	rt_str_region_eq-0x4
    1fd8:	cmp    rax,0x6
    1fdc:	je     203d <botlish_fn_17+0x1c1>
    1fe2:	mov    rcx,QWORD PTR [rsp+0x60]
    1fe7:	mov    rdx,QWORD PTR [rsp+0x58]
    1fec:	mov    rsi,QWORD PTR [rsp+0x70]
    1ff1:	mov    rdi,QWORD PTR [rsp+0x50]
    1ff6:	call   1ffb <botlish_fn_17+0x17f>
			1ff7: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1ffb:	test   rax,rax
    1ffe:	je     205f <botlish_fn_17+0x1e3>
    2004:	mov    rdx,QWORD PTR [rsp+0x78]
    2009:	mov    rbx,QWORD PTR [rsp+0x80]
    2011:	mov    r12,QWORD PTR [rsp+0x88]
    2019:	mov    r13,QWORD PTR [rsp+0x90]
    2021:	mov    r14,QWORD PTR [rsp+0x98]
    2029:	mov    r15,QWORD PTR [rsp+0xa0]
    2031:	add    rsp,0xb0
    2038:	mov    rsp,rbp
    203b:	pop    rbp
    203c:	ret
    203d:	mov    rcx,QWORD PTR [rsp+0x60]
    2042:	mov    rdx,QWORD PTR [rsp+0x58]
    2047:	mov    rsi,QWORD PTR [rsp+0x70]
    204c:	mov    rdi,QWORD PTR [rsp+0x50]
    2051:	call   2056 <botlish_fn_17+0x1da>
			2052: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2056:	test   rax,rax
    2059:	jne    2099 <botlish_fn_17+0x21d>
    205f:	xor    rdx,rdx
    2062:	mov    rax,rdx
    2065:	mov    rbx,QWORD PTR [rsp+0x80]
    206d:	mov    r12,QWORD PTR [rsp+0x88]
    2075:	mov    r13,QWORD PTR [rsp+0x90]
    207d:	mov    r14,QWORD PTR [rsp+0x98]
    2085:	mov    r15,QWORD PTR [rsp+0xa0]
    208d:	add    rsp,0xb0
    2094:	mov    rsp,rbp
    2097:	pop    rbp
    2098:	ret
    2099:	mov    QWORD PTR [rsp],rax
    209d:	mov    rbx,rax
    20a0:	mov    QWORD PTR [rsp+0x8],0x3
    20a9:	mov    rdx,QWORD PTR [rsp+0x78]
    20ae:	test   rdx,0x1
    20b5:	je     20d7 <botlish_fn_17+0x25b>
    20bb:	mov    rdx,QWORD PTR [rsp+0x78]
    20c0:	add    rdx,0x2
    20c4:	seto   al
    20c7:	test   al,al
    20c9:	jne    20d7 <botlish_fn_17+0x25b>
    20cf:	mov    rax,rbx
    20d2:	jmp    20f1 <botlish_fn_17+0x275>
    20d7:	mov    edx,0x3
    20dc:	mov    rsi,QWORD PTR [rsp+0x78]
    20e1:	mov    rdi,QWORD PTR [rsp+0x50]
    20e6:	call   20eb <botlish_fn_17+0x26f>
			20e7: R_X86_64_PLT32	rt_int_add-0x4
    20eb:	mov    rdx,rax
    20ee:	mov    rax,rbx
    20f1:	mov    rbx,QWORD PTR [rsp+0x80]
    20f9:	mov    r12,QWORD PTR [rsp+0x88]
    2101:	mov    r13,QWORD PTR [rsp+0x90]
    2109:	mov    r14,QWORD PTR [rsp+0x98]
    2111:	mov    r15,QWORD PTR [rsp+0xa0]
    2119:	add    rsp,0xb0
    2120:	mov    rsp,rbp
    2123:	pop    rbp
    2124:	ret
    2125:	mov    rsi,QWORD PTR [rsp+0x78]
    212a:	mov    edx,0x3
    212f:	mov    r10,rdx
    2132:	mov    QWORD PTR [rsp+0x20],0x3
    213b:	test   rsi,0x1
    2142:	jne    2150 <botlish_fn_17+0x2d4>
    2148:	mov    rdx,r10
    214b:	jmp    2165 <botlish_fn_17+0x2e9>
    2150:	mov    rdx,rsi
    2153:	add    rdx,0x2
    2157:	seto   al
    215a:	test   al,al
    215c:	je     2172 <botlish_fn_17+0x2f6>
    2162:	mov    rdx,r10
    2165:	mov    rdi,QWORD PTR [rsp+0x50]
    216a:	call   216f <botlish_fn_17+0x2f3>
			216b: R_X86_64_PLT32	rt_int_add-0x4
    216f:	mov    rdx,rax
    2172:	mov    QWORD PTR [rsp],r12
    2176:	mov    QWORD PTR [rsp+0x8],rdx
    217b:	mov    rsi,QWORD PTR [rsp+0x70]
    2180:	mov    QWORD PTR [rsp+0x10],rsi
    2185:	mov    rax,QWORD PTR [rsp+0x58]
    218a:	mov    QWORD PTR [rsp+0x18],rax
    218f:	mov    rcx,QWORD PTR [rsp+0x60]
    2194:	mov    QWORD PTR [rsp+0x20],rcx
    2199:	mov    r13,rsi
    219c:	jmp    1eef <botlish_fn_17+0x73>

00000000000021a1 <botlish_entry_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    21a1:	push   rbp
    21a2:	mov    rbp,rsp
    21a5:	ud2

00000000000021a7 <botlish_fn_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    21a7:	push   rbp
    21a8:	mov    rbp,rsp
    21ab:	sub    rsp,0xa0
    21b2:	mov    QWORD PTR [rsp+0x70],rbx
    21b7:	mov    QWORD PTR [rsp+0x78],r12
    21bc:	mov    QWORD PTR [rsp+0x80],r13
    21c4:	mov    QWORD PTR [rsp+0x88],r14
    21cc:	mov    QWORD PTR [rsp+0x90],r15
    21d4:	mov    r12,rdi
    21d7:	mov    QWORD PTR [rsp+0x28],0x0
    21e0:	mov    QWORD PTR [rsp+0x30],0x0
    21e9:	mov    QWORD PTR [rsp+0x38],0x0
    21f2:	mov    QWORD PTR [rsp],rsi
    21f6:	mov    rbx,rsi
    21f9:	mov    QWORD PTR [rsp+0x8],rdx
    21fe:	mov    QWORD PTR [rsp+0x60],rdx
    2203:	mov    QWORD PTR [rsp+0x10],rcx
    2208:	mov    r15,rcx
    220b:	mov    QWORD PTR [rsp+0x18],r8
    2210:	mov    r14,r8
    2213:	mov    QWORD PTR [rsp+0x20],r9
    2218:	mov    r13,r9
    221b:	mov    rsi,rbx
    221e:	mov    rdi,r12
    2221:	call   2226 <botlish_fn_18+0x7f>
			2222: R_X86_64_PLT32	rt_str_len-0x4
    2226:	mov    rdx,QWORD PTR [rsp+0x60]
    222b:	mov    rcx,rdx
    222e:	sar    rcx,1
    2231:	sar    rax,1
    2234:	cmp    rcx,rax
    2237:	jge    231c <botlish_fn_18+0x175>
    223d:	lea    rsi,[rsp+0x40]
    2242:	mov    rdi,r12
    2245:	call   224a <botlish_fn_18+0xa3>
			2246: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    224a:	test   rax,rax
    224d:	je     2336 <botlish_fn_18+0x18f>
    2253:	mov    QWORD PTR [rsp+0x28],rax
    2258:	mov    rcx,rax
    225b:	mov    r8,QWORD PTR [rsp+0x40]
    2260:	mov    QWORD PTR [rsp+0x30],r8
    2265:	mov    r9,QWORD PTR [rsp+0x48]
    226a:	mov    QWORD PTR [rsp+0x38],r9
    226f:	mov    rdx,QWORD PTR [rsp+0x60]
    2274:	mov    rsi,rbx
    2277:	mov    rdi,r12
    227a:	call   227f <botlish_fn_18+0xd8>
			227b: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    227f:	test   rax,rax
    2282:	je     2336 <botlish_fn_18+0x18f>
    2288:	mov    QWORD PTR [rsp+0x8],rax
    228d:	mov    r8,rax
    2290:	mov    QWORD PTR [rsp+0x28],rdx
    2295:	mov    QWORD PTR [rsp+0x60],rdx
    229a:	lea    r9,[rsp+0x50]
    229f:	mov    rcx,r13
    22a2:	mov    rdx,r14
    22a5:	mov    rsi,r15
    22a8:	mov    rdi,r12
    22ab:	call   22b0 <botlish_fn_18+0x109>
			22ac: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[list<never>, mutarray, int], list>
    22b0:	test   rax,rax
    22b3:	je     2336 <botlish_fn_18+0x18f>
    22b9:	mov    QWORD PTR [rsp+0x8],rax
    22be:	mov    rcx,rax
    22c1:	mov    r8,QWORD PTR [rsp+0x50]
    22c6:	mov    QWORD PTR [rsp+0x10],r8
    22cb:	mov    r9,QWORD PTR [rsp+0x58]
    22d0:	mov    QWORD PTR [rsp+0x18],r9
    22d5:	mov    rdx,QWORD PTR [rsp+0x60]
    22da:	mov    rsi,rbx
    22dd:	mov    rdi,r12
    22e0:	call   22e5 <botlish_fn_18+0x13e>
			22e1: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    22e5:	test   rax,rax
    22e8:	je     2336 <botlish_fn_18+0x18f>
    22ee:	mov    rbx,QWORD PTR [rsp+0x70]
    22f3:	mov    r12,QWORD PTR [rsp+0x78]
    22f8:	mov    r13,QWORD PTR [rsp+0x80]
    2300:	mov    r14,QWORD PTR [rsp+0x88]
    2308:	mov    r15,QWORD PTR [rsp+0x90]
    2310:	add    rsp,0xa0
    2317:	mov    rsp,rbp
    231a:	pop    rbp
    231b:	ret
    231c:	mov    rcx,r13
    231f:	mov    rdx,r14
    2322:	mov    rsi,r15
    2325:	mov    rdi,r12
    2328:	call   232d <botlish_fn_18+0x186>
			2329: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    232d:	test   rax,rax
    2330:	jne    2367 <botlish_fn_18+0x1c0>
    2336:	xor    rax,rax
    2339:	mov    rbx,QWORD PTR [rsp+0x70]
    233e:	mov    r12,QWORD PTR [rsp+0x78]
    2343:	mov    r13,QWORD PTR [rsp+0x80]
    234b:	mov    r14,QWORD PTR [rsp+0x88]
    2353:	mov    r15,QWORD PTR [rsp+0x90]
    235b:	add    rsp,0xa0
    2362:	mov    rsp,rbp
    2365:	pop    rbp
    2366:	ret
    2367:	mov    rbx,QWORD PTR [rsp+0x70]
    236c:	mov    r12,QWORD PTR [rsp+0x78]
    2371:	mov    r13,QWORD PTR [rsp+0x80]
    2379:	mov    r14,QWORD PTR [rsp+0x88]
    2381:	mov    r15,QWORD PTR [rsp+0x90]
    2389:	add    rsp,0xa0
    2390:	mov    rsp,rbp
    2393:	pop    rbp
    2394:	ret

0000000000002395 <botlish_entry_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    2395:	push   rbp
    2396:	mov    rbp,rsp
    2399:	mov    rsi,QWORD PTR [rdx]
    239c:	mov    r10,QWORD PTR [rdx+0x8]
    23a0:	mov    rcx,QWORD PTR [rdx+0x10]
    23a4:	mov    r8,QWORD PTR [rdx+0x18]
    23a8:	mov    r9,QWORD PTR [rdx+0x20]
    23ac:	mov    rdx,r10
    23af:	call   23b4 <botlish_entry_18+0x1f>
			23b0: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    23b4:	mov    rsp,rbp
    23b7:	pop    rbp
    23b8:	ret
    23b9:	add    BYTE PTR [rax],al
    23bb:	add    BYTE PTR [rax],al
    23bd:	add    BYTE PTR [rax],al
	...

00000000000023c0 <botlish_fn_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    23c0:	push   rbp
    23c1:	mov    rbp,rsp
    23c4:	sub    rsp,0xb0
    23cb:	mov    QWORD PTR [rsp+0x80],rbx
    23d3:	mov    QWORD PTR [rsp+0x88],r12
    23db:	mov    QWORD PTR [rsp+0x90],r13
    23e3:	mov    QWORD PTR [rsp+0x98],r14
    23eb:	mov    QWORD PTR [rsp+0xa0],r15
    23f3:	mov    r15,rdi
    23f6:	mov    QWORD PTR [rsp+0x28],0x0
    23ff:	mov    QWORD PTR [rsp+0x30],0x0
    2408:	mov    QWORD PTR [rsp+0x38],0x0
    2411:	mov    QWORD PTR [rsp],rsi
    2415:	mov    QWORD PTR [rsp+0x8],rdx
    241a:	mov    r14,rdx
    241d:	mov    QWORD PTR [rsp+0x10],rcx
    2422:	mov    QWORD PTR [rsp+0x18],r8
    2427:	mov    QWORD PTR [rsp+0x20],r9
    242c:	lea    r13,[rsp+0x40]
    2431:	lea    rbx,[rsp+0x50]
    2436:	mov    r12,rsi
    2439:	mov    QWORD PTR [rsp+0x60],rcx
    243e:	mov    QWORD PTR [rsp+0x68],r8
    2443:	mov    QWORD PTR [rsp+0x70],r9
    2448:	mov    rsi,r12
    244b:	mov    rdi,r15
    244e:	call   2453 <botlish_fn_19+0x93>
			244f: R_X86_64_PLT32	rt_str_len-0x4
    2453:	mov    rcx,r14
    2456:	and    rcx,rax
    2459:	mov    rdx,rax
    245c:	test   rcx,0x1
    2463:	jne    2489 <botlish_fn_19+0xc9>
    2469:	mov    rsi,r14
    246c:	mov    rdi,r15
    246f:	call   2474 <botlish_fn_19+0xb4>
			2470: R_X86_64_PLT32	rt_int_cmp-0x4
    2474:	mov    ecx,0x2
    2479:	test   rax,rax
    247c:	cmovge rcx,QWORD PTR [rip+0x164]        # 25e8 <botlish_fn_19+0x228>
    2484:	jmp    249c <botlish_fn_19+0xdc>
    2489:	mov    ecx,0x2
    248e:	mov    rdi,r14
    2491:	cmp    rdi,rdx
    2494:	cmovge rcx,QWORD PTR [rip+0x14c]        # 25e8 <botlish_fn_19+0x228>
    249c:	cmp    rcx,0x6
    24a0:	je     2559 <botlish_fn_19+0x199>
    24a6:	mov    rsi,r13
    24a9:	mov    rdi,r15
    24ac:	call   24b1 <botlish_fn_19+0xf1>
			24ad: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    24b1:	test   rax,rax
    24b4:	je     2579 <botlish_fn_19+0x1b9>
    24ba:	mov    QWORD PTR [rsp+0x28],rax
    24bf:	mov    rcx,rax
    24c2:	mov    r8,QWORD PTR [rsp+0x40]
    24c7:	mov    QWORD PTR [rsp+0x30],r8
    24cc:	mov    r9,QWORD PTR [rsp+0x48]
    24d1:	mov    QWORD PTR [rsp+0x38],r9
    24d6:	mov    rdx,r14
    24d9:	mov    rsi,r12
    24dc:	mov    rdi,r15
    24df:	call   24e4 <botlish_fn_19+0x124>
			24e0: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    24e4:	test   rax,rax
    24e7:	je     2579 <botlish_fn_19+0x1b9>
    24ed:	mov    QWORD PTR [rsp+0x8],rax
    24f2:	mov    r8,rax
    24f5:	mov    QWORD PTR [rsp+0x28],rdx
    24fa:	mov    r14,rdx
    24fd:	mov    rsi,QWORD PTR [rsp+0x60]
    2502:	mov    rdx,QWORD PTR [rsp+0x68]
    2507:	mov    rcx,QWORD PTR [rsp+0x70]
    250c:	mov    rdi,r15
    250f:	mov    r9,rbx
    2512:	call   2517 <botlish_fn_19+0x157>
			2513: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], list>
    2517:	test   rax,rax
    251a:	je     2579 <botlish_fn_19+0x1b9>
    2520:	mov    rdx,QWORD PTR [rsp+0x50]
    2525:	mov    rcx,QWORD PTR [rsp+0x58]
    252a:	mov    QWORD PTR [rsp],r12
    252e:	mov    rsi,r14
    2531:	mov    QWORD PTR [rsp+0x8],rsi
    2536:	mov    QWORD PTR [rsp+0x10],rax
    253b:	mov    QWORD PTR [rsp+0x18],rdx
    2540:	mov    QWORD PTR [rsp+0x20],rcx
    2545:	mov    QWORD PTR [rsp+0x60],rax
    254a:	mov    QWORD PTR [rsp+0x68],rdx
    254f:	mov    QWORD PTR [rsp+0x70],rcx
    2554:	jmp    2448 <botlish_fn_19+0x88>
    2559:	mov    rcx,QWORD PTR [rsp+0x70]
    255e:	mov    rdx,QWORD PTR [rsp+0x68]
    2563:	mov    rsi,QWORD PTR [rsp+0x60]
    2568:	mov    rdi,r15
    256b:	call   2570 <botlish_fn_19+0x1b0>
			256c: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2570:	test   rax,rax
    2573:	jne    25b0 <botlish_fn_19+0x1f0>
    2579:	xor    rax,rax
    257c:	mov    rbx,QWORD PTR [rsp+0x80]
    2584:	mov    r12,QWORD PTR [rsp+0x88]
    258c:	mov    r13,QWORD PTR [rsp+0x90]
    2594:	mov    r14,QWORD PTR [rsp+0x98]
    259c:	mov    r15,QWORD PTR [rsp+0xa0]
    25a4:	add    rsp,0xb0
    25ab:	mov    rsp,rbp
    25ae:	pop    rbp
    25af:	ret
    25b0:	mov    rbx,QWORD PTR [rsp+0x80]
    25b8:	mov    r12,QWORD PTR [rsp+0x88]
    25c0:	mov    r13,QWORD PTR [rsp+0x90]
    25c8:	mov    r14,QWORD PTR [rsp+0x98]
    25d0:	mov    r15,QWORD PTR [rsp+0xa0]
    25d8:	add    rsp,0xb0
    25df:	mov    rsp,rbp
    25e2:	pop    rbp
    25e3:	ret
    25e4:	add    BYTE PTR [rax],al
    25e6:	add    BYTE PTR [rax],al
    25e8:	(bad)
    25e9:	add    BYTE PTR [rax],al
    25eb:	add    BYTE PTR [rax],al
    25ed:	add    BYTE PTR [rax],al
	...

00000000000025f0 <botlish_entry_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    25f0:	push   rbp
    25f1:	mov    rbp,rsp
    25f4:	mov    rsi,QWORD PTR [rdx]
    25f7:	mov    r10,QWORD PTR [rdx+0x8]
    25fb:	mov    rcx,QWORD PTR [rdx+0x10]
    25ff:	mov    r8,QWORD PTR [rdx+0x18]
    2603:	mov    r9,QWORD PTR [rdx+0x20]
    2607:	mov    rdx,r10
    260a:	call   260f <botlish_entry_19+0x1f>
			260b: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    260f:	mov    rsp,rbp
    2612:	pop    rbp
    2613:	ret

0000000000002614 <botlish_fn_20: csv_parse<str>>:
    2614:	push   rbp
    2615:	mov    rbp,rsp
    2618:	sub    rsp,0x50
    261c:	mov    QWORD PTR [rsp+0x40],r12
    2621:	mov    QWORD PTR [rsp+0x48],r13
    2626:	mov    r13,rdi
    2629:	mov    QWORD PTR [rsp+0x10],0x0
    2632:	mov    QWORD PTR [rsp+0x18],0x0
    263b:	mov    QWORD PTR [rsp+0x20],0x0
    2644:	mov    QWORD PTR [rsp],rsi
    2648:	mov    r12,rsi
    264b:	mov    QWORD PTR [rsp+0x8],0x1
    2654:	lea    rsi,[rsp+0x28]
    2659:	mov    rdi,r13
    265c:	call   2661 <botlish_fn_20+0x4d>
			265d: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    2661:	test   rax,rax
    2664:	je     269f <botlish_fn_20+0x8b>
    266a:	mov    QWORD PTR [rsp+0x10],rax
    266f:	mov    rcx,rax
    2672:	mov    r8,QWORD PTR [rsp+0x28]
    2677:	mov    QWORD PTR [rsp+0x18],r8
    267c:	mov    r9,QWORD PTR [rsp+0x30]
    2681:	mov    QWORD PTR [rsp+0x20],r9
    2686:	mov    edx,0x1
    268b:	mov    rsi,r12
    268e:	mov    rdi,r13
    2691:	call   2696 <botlish_fn_20+0x82>
			2692: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    2696:	test   rax,rax
    2699:	jne    26b5 <botlish_fn_20+0xa1>
    269f:	xor    rax,rax
    26a2:	mov    r12,QWORD PTR [rsp+0x40]
    26a7:	mov    r13,QWORD PTR [rsp+0x48]
    26ac:	add    rsp,0x50
    26b0:	mov    rsp,rbp
    26b3:	pop    rbp
    26b4:	ret
    26b5:	mov    r12,QWORD PTR [rsp+0x40]
    26ba:	mov    r13,QWORD PTR [rsp+0x48]
    26bf:	add    rsp,0x50
    26c3:	mov    rsp,rbp
    26c6:	pop    rbp
    26c7:	ret

00000000000026c8 <botlish_entry_20: csv_parse<str>>:
    26c8:	push   rbp
    26c9:	mov    rbp,rsp
    26cc:	mov    rsi,QWORD PTR [rdx]
    26cf:	call   26d4 <botlish_entry_20+0xc>
			26d0: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    26d4:	mov    rsp,rbp
    26d7:	pop    rbp
    26d8:	ret

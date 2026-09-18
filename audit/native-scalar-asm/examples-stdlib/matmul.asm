; source:  examples/stdlib/matmul.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5271  (per function: 944 857 609 732 718 844 567)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> dot<list<int>, list<list<int>>, int, int, int, int>
;   botlish_fn_2 / botlish_entry_2 -> product_row<list<int>, list<list<int>>, int, int, list<never>>
;   botlish_fn_3 / botlish_entry_3 -> product_row<list<int>, list<list<int>>, int, int, list<int>>
;   botlish_fn_4 / botlish_entry_4 -> product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>
;   botlish_fn_5 / botlish_entry_5 -> product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>
;   botlish_fn_6 / botlish_entry_6 -> matmul<list<list<int>>, list<list<int>>>


matmul.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0xc0
       b:	mov    QWORD PTR [rsp+0x90],rbx
      13:	mov    QWORD PTR [rsp+0x98],r12
      1b:	mov    QWORD PTR [rsp+0xa0],r13
      23:	mov    QWORD PTR [rsp+0xa8],r14
      2b:	mov    QWORD PTR [rsp+0xb0],r15
      33:	mov    r12,QWORD PTR [rdi]
      36:	mov    rax,QWORD PTR [rdi+0x8]
      3a:	lea    rcx,[r12+0x28]
      3f:	cmp    rcx,rax
      42:	ja     347 <botlish_fn_0+0x347>
      48:	lea    rax,[r12+0x28]
      4d:	mov    QWORD PTR [rdi],rax
      50:	mov    r13,rdi
      53:	mov    QWORD PTR [r12],0x0
      5b:	mov    QWORD PTR [r12+0x8],0x0
      64:	mov    QWORD PTR [r12+0x10],0x0
      6d:	mov    QWORD PTR [r12+0x18],0x0
      76:	mov    QWORD PTR [r12+0x20],0x0
      7f:	mov    esi,0x3
      84:	mov    QWORD PTR [r12],0x3
      8c:	mov    QWORD PTR [r12+0x8],0x5
      95:	mov    QWORD PTR [r12+0x10],0x7
      9e:	lea    rdx,[rsp]
      a2:	mov    QWORD PTR [rsp],0x3
      aa:	mov    QWORD PTR [rsp+0x8],0x5
      b3:	mov    QWORD PTR [rsp+0x10],0x7
      bc:	mov    rax,QWORD PTR [rip+0x0]        # c3 <botlish_fn_0+0xc3>
			bf: R_X86_64_GOTPCREL	rt_list_new-0x4
      c3:	mov    rdi,r13
      c6:	call   rax
      c8:	test   rax,rax
      cb:	jne    d9 <botlish_fn_0+0xd9>
      d1:	mov    rdi,r13
      d4:	jmp    2d0 <botlish_fn_0+0x2d0>
      d9:	mov    QWORD PTR [r12],rax
      dd:	mov    rbx,rax
      e0:	mov    QWORD PTR [r12+0x8],0x9
      e9:	mov    QWORD PTR [r12+0x10],0xb
      f2:	mov    QWORD PTR [r12+0x18],0xd
      fb:	lea    rdx,[rsp+0x18]
     100:	mov    QWORD PTR [rsp+0x18],0x9
     109:	mov    QWORD PTR [rsp+0x20],0xb
     112:	mov    QWORD PTR [rsp+0x28],0xd
     11b:	mov    esi,0x3
     120:	mov    r8,QWORD PTR [rip+0x0]        # 127 <botlish_fn_0+0x127>
			123: R_X86_64_GOTPCREL	rt_list_new-0x4
     127:	mov    rdi,r13
     12a:	call   r8
     12d:	test   rax,rax
     130:	jne    13e <botlish_fn_0+0x13e>
     136:	mov    rdi,r13
     139:	jmp    2d0 <botlish_fn_0+0x2d0>
     13e:	mov    QWORD PTR [r12+0x8],rax
     143:	lea    rdx,[rsp+0x30]
     148:	mov    rcx,rbx
     14b:	mov    QWORD PTR [rsp+0x30],rcx
     150:	mov    QWORD PTR [rsp+0x38],rax
     155:	mov    esi,0x2
     15a:	mov    r8,QWORD PTR [rip+0x0]        # 161 <botlish_fn_0+0x161>
			15d: R_X86_64_GOTPCREL	rt_list_new-0x4
     161:	mov    rdi,r13
     164:	call   r8
     167:	test   rax,rax
     16a:	jne    178 <botlish_fn_0+0x178>
     170:	mov    rdi,r13
     173:	jmp    2d0 <botlish_fn_0+0x2d0>
     178:	mov    QWORD PTR [r12],rax
     17c:	mov    r14,rax
     17f:	mov    QWORD PTR [r12+0x8],0xf
     188:	mov    QWORD PTR [r12+0x10],0x11
     191:	lea    rdx,[rsp+0x40]
     196:	mov    QWORD PTR [rsp+0x40],0xf
     19f:	mov    QWORD PTR [rsp+0x48],0x11
     1a8:	mov    esi,0x2
     1ad:	mov    rax,QWORD PTR [rip+0x0]        # 1b4 <botlish_fn_0+0x1b4>
			1b0: R_X86_64_GOTPCREL	rt_list_new-0x4
     1b4:	mov    rdi,r13
     1b7:	call   rax
     1b9:	mov    rbx,rax
     1bc:	test   rbx,rbx
     1bf:	jne    1cd <botlish_fn_0+0x1cd>
     1c5:	mov    rdi,r13
     1c8:	jmp    2d0 <botlish_fn_0+0x2d0>
     1cd:	mov    QWORD PTR [r12+0x8],rbx
     1d2:	mov    QWORD PTR [r12+0x10],0x13
     1db:	mov    QWORD PTR [r12+0x18],0x15
     1e4:	lea    rdx,[rsp+0x50]
     1e9:	mov    QWORD PTR [rsp+0x50],0x13
     1f2:	mov    QWORD PTR [rsp+0x58],0x15
     1fb:	mov    esi,0x2
     200:	mov    rax,QWORD PTR [rip+0x0]        # 207 <botlish_fn_0+0x207>
			203: R_X86_64_GOTPCREL	rt_list_new-0x4
     207:	mov    rdi,r13
     20a:	call   rax
     20c:	test   rax,rax
     20f:	jne    21d <botlish_fn_0+0x21d>
     215:	mov    rdi,r13
     218:	jmp    2d0 <botlish_fn_0+0x2d0>
     21d:	mov    QWORD PTR [r12+0x10],rax
     222:	mov    r15,rax
     225:	mov    QWORD PTR [r12+0x18],0x17
     22e:	mov    QWORD PTR [r12+0x20],0x19
     237:	lea    rdx,[rsp+0x60]
     23c:	mov    QWORD PTR [rsp+0x60],0x17
     245:	mov    QWORD PTR [rsp+0x68],0x19
     24e:	mov    esi,0x2
     253:	mov    rax,QWORD PTR [rip+0x0]        # 25a <botlish_fn_0+0x25a>
			256: R_X86_64_GOTPCREL	rt_list_new-0x4
     25a:	mov    rdi,r13
     25d:	call   rax
     25f:	test   rax,rax
     262:	jne    270 <botlish_fn_0+0x270>
     268:	mov    rdi,r13
     26b:	jmp    2d0 <botlish_fn_0+0x2d0>
     270:	mov    QWORD PTR [r12+0x18],rax
     275:	lea    rdx,[rsp+0x70]
     27a:	mov    QWORD PTR [rsp+0x70],rbx
     27f:	mov    rcx,r15
     282:	mov    QWORD PTR [rsp+0x78],rcx
     287:	mov    QWORD PTR [rsp+0x80],rax
     28f:	mov    esi,0x3
     294:	mov    rax,QWORD PTR [rip+0x0]        # 29b <botlish_fn_0+0x29b>
			297: R_X86_64_GOTPCREL	rt_list_new-0x4
     29b:	mov    rdi,r13
     29e:	call   rax
     2a0:	test   rax,rax
     2a3:	jne    2b1 <botlish_fn_0+0x2b1>
     2a9:	mov    rdi,r13
     2ac:	jmp    2d0 <botlish_fn_0+0x2d0>
     2b1:	mov    QWORD PTR [r12+0x8],rax
     2b6:	mov    rdx,rax
     2b9:	mov    rsi,r14
     2bc:	mov    rdi,r13
     2bf:	call   2c4 <botlish_fn_0+0x2c4>
			2c0: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<list<list<int>>, list<list<int>>>
     2c4:	test   rax,rax
     2c7:	jne    30d <botlish_fn_0+0x30d>
     2cd:	mov    rdi,r13
     2d0:	mov    rdi,r13
     2d3:	mov    QWORD PTR [rdi],r12
     2d6:	xor    rax,rax
     2d9:	mov    rbx,QWORD PTR [rsp+0x90]
     2e1:	mov    r12,QWORD PTR [rsp+0x98]
     2e9:	mov    r13,QWORD PTR [rsp+0xa0]
     2f1:	mov    r14,QWORD PTR [rsp+0xa8]
     2f9:	mov    r15,QWORD PTR [rsp+0xb0]
     301:	add    rsp,0xc0
     308:	mov    rsp,rbp
     30b:	pop    rbp
     30c:	ret
     30d:	mov    rdi,r13
     310:	mov    QWORD PTR [rdi],r12
     313:	mov    rbx,QWORD PTR [rsp+0x90]
     31b:	mov    r12,QWORD PTR [rsp+0x98]
     323:	mov    r13,QWORD PTR [rsp+0xa0]
     32b:	mov    r14,QWORD PTR [rsp+0xa8]
     333:	mov    r15,QWORD PTR [rsp+0xb0]
     33b:	add    rsp,0xc0
     342:	mov    rsp,rbp
     345:	pop    rbp
     346:	ret
     347:	mov    r13,rdi
     34a:	mov    rax,QWORD PTR [rip+0x0]        # 351 <botlish_fn_0+0x351>
			34d: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     351:	call   rax
     353:	xor    rax,rax
     356:	mov    rbx,QWORD PTR [rsp+0x90]
     35e:	mov    r12,QWORD PTR [rsp+0x98]
     366:	mov    r13,QWORD PTR [rsp+0xa0]
     36e:	mov    r14,QWORD PTR [rsp+0xa8]
     376:	mov    r15,QWORD PTR [rsp+0xb0]
     37e:	add    rsp,0xc0
     385:	mov    rsp,rbp
     388:	pop    rbp
     389:	ret

000000000000038a <botlish_entry_0: <program entry>>:
     38a:	push   rbp
     38b:	mov    rbp,rsp
     38e:	call   393 <botlish_entry_0+0x9>
			38f: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     393:	mov    rsp,rbp
     396:	pop    rbp
     397:	ret

0000000000000398 <botlish_fn_1: dot<list<int>, list<list<int>>, int, int, int, int>>:
     398:	push   rbp
     399:	mov    rbp,rsp
     39c:	sub    rsp,0x60
     3a0:	mov    QWORD PTR [rsp+0x30],rbx
     3a5:	mov    QWORD PTR [rsp+0x38],r12
     3aa:	mov    QWORD PTR [rsp+0x40],r13
     3af:	mov    QWORD PTR [rsp+0x48],r14
     3b4:	mov    QWORD PTR [rsp+0x50],r15
     3b9:	mov    r10,QWORD PTR [rbp+0x10]
     3bd:	mov    rbx,QWORD PTR [rdi]
     3c0:	mov    r11,QWORD PTR [rdi+0x8]
     3c4:	lea    rax,[rbx+0x30]
     3c8:	cmp    rax,r11
     3cb:	ja     679 <botlish_fn_1+0x2e1>
     3d1:	lea    r11,[rbx+0x30]
     3d5:	mov    QWORD PTR [rdi],r11
     3d8:	mov    QWORD PTR [rsp],rdi
     3dc:	mov    QWORD PTR [rbx],0x0
     3e3:	mov    QWORD PTR [rbx+0x8],0x0
     3eb:	mov    QWORD PTR [rbx+0x10],0x0
     3f3:	mov    QWORD PTR [rbx+0x18],0x0
     3fb:	mov    QWORD PTR [rbx+0x20],0x0
     403:	mov    QWORD PTR [rbx+0x28],0x0
     40b:	mov    QWORD PTR [rbx],rsi
     40e:	mov    QWORD PTR [rbx+0x8],rdx
     412:	mov    r15,rdx
     415:	mov    QWORD PTR [rbx+0x10],rcx
     419:	mov    QWORD PTR [rbx+0x18],r10
     41d:	sar    r8,1
     420:	sar    r9,1
     423:	mov    QWORD PTR [rsp+0x20],r9
     428:	mov    rax,rcx
     42b:	sar    rax,1
     42e:	mov    r13,rcx
     431:	mov    QWORD PTR [rsp+0x18],rax
     436:	mov    rcx,QWORD PTR [rsp+0x20]
     43b:	mov    r12,r8
     43e:	mov    QWORD PTR [rsp+0x8],r10
     443:	cmp    r12,rcx
     446:	mov    QWORD PTR [rsp+0x20],rcx
     44b:	je     64b <botlish_fn_1+0x2b3>
     451:	mov    r14,rsi
     454:	mov    rcx,QWORD PTR [r14+0x8]
     458:	mov    rax,r12
     45b:	shl    rax,1
     45e:	or     rax,0x1
     462:	sar    rax,1
     465:	cmp    rax,rcx
     468:	jb     4a2 <botlish_fn_1+0x10a>
     46e:	mov    rdx,r12
     471:	shl    rdx,1
     474:	or     rdx,0x1
     478:	mov    rax,QWORD PTR [rip+0x0]        # 47f <botlish_fn_1+0xe7>
			47b: R_X86_64_GOTPCREL	rt_list_get-0x4
     47f:	mov    rsi,r14
     482:	mov    rdi,QWORD PTR [rsp]
     486:	call   rax
     488:	test   rax,rax
     48b:	jne    49a <botlish_fn_1+0x102>
     491:	mov    rdi,QWORD PTR [rsp]
     495:	jmp    545 <botlish_fn_1+0x1ad>
     49a:	mov    rsi,rax
     49d:	jmp    4aa <botlish_fn_1+0x112>
     4a2:	mov    rcx,QWORD PTR [r14+0x10]
     4a6:	mov    rsi,QWORD PTR [rcx+rax*8]
     4aa:	mov    QWORD PTR [rbx+0x20],rsi
     4ae:	mov    QWORD PTR [rsp+0x10],rsi
     4b3:	mov    rcx,QWORD PTR [r15+0x8]
     4b7:	mov    rax,r12
     4ba:	shl    rax,1
     4bd:	or     rax,0x1
     4c1:	sar    rax,1
     4c4:	cmp    rax,rcx
     4c7:	jb     501 <botlish_fn_1+0x169>
     4cd:	mov    rdx,r12
     4d0:	shl    rdx,1
     4d3:	or     rdx,0x1
     4d7:	mov    rax,QWORD PTR [rip+0x0]        # 4de <botlish_fn_1+0x146>
			4da: R_X86_64_GOTPCREL	rt_list_get-0x4
     4de:	mov    rsi,r15
     4e1:	mov    rdi,QWORD PTR [rsp]
     4e5:	call   rax
     4e7:	test   rax,rax
     4ea:	jne    4f9 <botlish_fn_1+0x161>
     4f0:	mov    rdi,QWORD PTR [rsp]
     4f4:	jmp    545 <botlish_fn_1+0x1ad>
     4f9:	mov    rsi,rax
     4fc:	jmp    509 <botlish_fn_1+0x171>
     501:	mov    rcx,QWORD PTR [r15+0x10]
     505:	mov    rsi,QWORD PTR [rcx+rax*8]
     509:	test   r13,0x1
     510:	je     528 <botlish_fn_1+0x190>
     516:	mov    rax,QWORD PTR [rsi+0x8]
     51a:	mov    rcx,QWORD PTR [rsp+0x18]
     51f:	cmp    rcx,rax
     522:	jb     579 <botlish_fn_1+0x1e1>
     528:	mov    rax,QWORD PTR [rip+0x0]        # 52f <botlish_fn_1+0x197>
			52b: R_X86_64_GOTPCREL	rt_list_get-0x4
     52f:	mov    rdx,r13
     532:	mov    rdi,QWORD PTR [rsp]
     536:	call   rax
     538:	test   rax,rax
     53b:	jne    571 <botlish_fn_1+0x1d9>
     541:	mov    rdi,QWORD PTR [rsp]
     545:	mov    rdi,QWORD PTR [rsp]
     549:	mov    QWORD PTR [rdi],rbx
     54c:	xor    rax,rax
     54f:	mov    rbx,QWORD PTR [rsp+0x30]
     554:	mov    r12,QWORD PTR [rsp+0x38]
     559:	mov    r13,QWORD PTR [rsp+0x40]
     55e:	mov    r14,QWORD PTR [rsp+0x48]
     563:	mov    r15,QWORD PTR [rsp+0x50]
     568:	add    rsp,0x60
     56c:	mov    rsp,rbp
     56f:	pop    rbp
     570:	ret
     571:	mov    rdx,rax
     574:	jmp    586 <botlish_fn_1+0x1ee>
     579:	mov    rax,QWORD PTR [rsi+0x10]
     57d:	mov    rcx,QWORD PTR [rsp+0x18]
     582:	mov    rdx,QWORD PTR [rax+rcx*8]
     586:	mov    QWORD PTR [rbx+0x28],rdx
     58a:	mov    rsi,QWORD PTR [rsp+0x10]
     58f:	mov    rax,rsi
     592:	and    rax,rdx
     595:	test   rax,0x1
     59b:	jne    5a9 <botlish_fn_1+0x211>
     5a1:	mov    rdi,rdx
     5a4:	jmp    5d0 <botlish_fn_1+0x238>
     5a9:	mov    rax,rsi
     5ac:	sar    rax,1
     5af:	lea    rcx,[rdx-0x1]
     5b3:	mov    rdi,rdx
     5b6:	imul   rcx
     5b9:	seto   cl
     5bc:	or     rax,0x1
     5c0:	test   cl,cl
     5c2:	jne    5d0 <botlish_fn_1+0x238>
     5c8:	mov    rdx,rax
     5cb:	jmp    5e3 <botlish_fn_1+0x24b>
     5d0:	mov    rax,QWORD PTR [rip+0x0]        # 5d7 <botlish_fn_1+0x23f>
			5d3: R_X86_64_GOTPCREL	rt_int_mul-0x4
     5d7:	mov    rdx,rdi
     5da:	mov    rdi,QWORD PTR [rsp]
     5de:	call   rax
     5e0:	mov    rdx,rax
     5e3:	mov    QWORD PTR [rbx+0x20],rdx
     5e7:	mov    rsi,QWORD PTR [rsp+0x8]
     5ec:	mov    rax,rsi
     5ef:	and    rax,rdx
     5f2:	test   rax,0x1
     5f8:	je     615 <botlish_fn_1+0x27d>
     5fe:	lea    rdi,[rdx-0x1]
     602:	mov    rax,rsi
     605:	add    rax,rdi
     608:	seto   dil
     60c:	test   dil,dil
     60f:	je     623 <botlish_fn_1+0x28b>
     615:	mov    r8,QWORD PTR [rip+0x0]        # 61c <botlish_fn_1+0x284>
			618: R_X86_64_GOTPCREL	rt_int_add-0x4
     61c:	mov    rdi,QWORD PTR [rsp]
     620:	call   r8
     623:	mov    QWORD PTR [rbx],r14
     626:	mov    QWORD PTR [rbx+0x8],r15
     62a:	mov    QWORD PTR [rbx+0x10],r13
     62e:	mov    QWORD PTR [rbx+0x18],rax
     632:	add    r12,0x1
     639:	mov    rcx,QWORD PTR [rsp+0x20]
     63e:	mov    rsi,r14
     641:	mov    QWORD PTR [rsp+0x8],rax
     646:	jmp    443 <botlish_fn_1+0xab>
     64b:	mov    rdi,QWORD PTR [rsp]
     64f:	mov    QWORD PTR [rdi],rbx
     652:	mov    rax,QWORD PTR [rsp+0x8]
     657:	mov    rbx,QWORD PTR [rsp+0x30]
     65c:	mov    r12,QWORD PTR [rsp+0x38]
     661:	mov    r13,QWORD PTR [rsp+0x40]
     666:	mov    r14,QWORD PTR [rsp+0x48]
     66b:	mov    r15,QWORD PTR [rsp+0x50]
     670:	add    rsp,0x60
     674:	mov    rsp,rbp
     677:	pop    rbp
     678:	ret
     679:	mov    QWORD PTR [rsp],rdi
     67d:	mov    rax,QWORD PTR [rip+0x0]        # 684 <botlish_fn_1+0x2ec>
			680: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     684:	call   rax
     686:	xor    rax,rax
     689:	mov    rbx,QWORD PTR [rsp+0x30]
     68e:	mov    r12,QWORD PTR [rsp+0x38]
     693:	mov    r13,QWORD PTR [rsp+0x40]
     698:	mov    r14,QWORD PTR [rsp+0x48]
     69d:	mov    r15,QWORD PTR [rsp+0x50]
     6a2:	add    rsp,0x60
     6a6:	mov    rsp,rbp
     6a9:	pop    rbp
     6aa:	ret

00000000000006ab <botlish_entry_1: dot<list<int>, list<list<int>>, int, int, int, int>>:
     6ab:	push   rbp
     6ac:	mov    rbp,rsp
     6af:	sub    rsp,0x10
     6b3:	mov    rsi,QWORD PTR [rdx]
     6b6:	mov    r10,QWORD PTR [rdx+0x8]
     6ba:	mov    rcx,QWORD PTR [rdx+0x10]
     6be:	mov    r8,QWORD PTR [rdx+0x18]
     6c2:	mov    r9,QWORD PTR [rdx+0x20]
     6c6:	mov    r11,QWORD PTR [rdx+0x28]
     6ca:	mov    QWORD PTR [rsp],r11
     6ce:	mov    rdx,r10
     6d1:	call   6d6 <botlish_entry_1+0x2b>
			6d2: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     6d6:	add    rsp,0x10
     6da:	mov    rsp,rbp
     6dd:	pop    rbp
     6de:	ret

00000000000006df <botlish_fn_2: product_row<list<int>, list<list<int>>, int, int, list<never>>>:
     6df:	push   rbp
     6e0:	mov    rbp,rsp
     6e3:	sub    rsp,0x60
     6e7:	mov    QWORD PTR [rsp+0x30],rbx
     6ec:	mov    QWORD PTR [rsp+0x38],r12
     6f1:	mov    QWORD PTR [rsp+0x40],r13
     6f6:	mov    QWORD PTR [rsp+0x48],r14
     6fb:	mov    QWORD PTR [rsp+0x50],r15
     700:	mov    r13,QWORD PTR [rdi]
     703:	mov    rax,QWORD PTR [rdi+0x8]
     707:	lea    r10,[r13+0x40]
     70b:	cmp    r10,rax
     70e:	ja     8e1 <botlish_fn_2+0x202>
     714:	lea    rax,[r13+0x40]
     718:	mov    QWORD PTR [rdi],rax
     71b:	mov    r14,rdi
     71e:	mov    QWORD PTR [r13+0x0],0x0
     726:	mov    QWORD PTR [r13+0x8],0x0
     72e:	mov    QWORD PTR [r13+0x10],0x0
     736:	mov    QWORD PTR [r13+0x18],0x0
     73e:	mov    QWORD PTR [r13+0x20],0x0
     746:	mov    QWORD PTR [r13+0x28],0x0
     74e:	mov    QWORD PTR [r13+0x30],0x0
     756:	mov    QWORD PTR [r13+0x38],0x0
     75e:	mov    QWORD PTR [r13+0x0],rsi
     762:	mov    QWORD PTR [rsp+0x10],rsi
     767:	mov    QWORD PTR [r13+0x8],rdx
     76b:	mov    QWORD PTR [rsp+0x18],rdx
     770:	mov    QWORD PTR [r13+0x10],rcx
     774:	mov    QWORD PTR [r13+0x18],r8
     778:	mov    QWORD PTR [r13+0x20],r9
     77c:	mov    QWORD PTR [rsp+0x28],r9
     781:	mov    rbx,rcx
     784:	sar    rbx,1
     787:	mov    QWORD PTR [rsp+0x20],rcx
     78c:	mov    rax,r8
     78f:	sar    rax,1
     792:	mov    r15,r8
     795:	cmp    rbx,rax
     798:	je     8b4 <botlish_fn_2+0x1d5>
     79e:	mov    r12d,0x1
     7a4:	mov    QWORD PTR [r13+0x28],0x1
     7ac:	mov    rax,QWORD PTR [rip+0x0]        # 7b3 <botlish_fn_2+0xd4>
			7af: R_X86_64_GOTPCREL	rt_list_len-0x4
     7b3:	mov    rsi,QWORD PTR [rsp+0x10]
     7b8:	mov    rdi,r14
     7bb:	call   rax
     7bd:	mov    QWORD PTR [r13+0x30],rax
     7c1:	mov    QWORD PTR [r13+0x38],0x1
     7c9:	mov    QWORD PTR [rsp],r12
     7cd:	mov    rcx,QWORD PTR [rsp+0x20]
     7d2:	mov    r8,r12
     7d5:	mov    r9,rax
     7d8:	mov    rdx,QWORD PTR [rsp+0x18]
     7dd:	mov    rsi,QWORD PTR [rsp+0x10]
     7e2:	mov    rdi,r14
     7e5:	call   7ea <botlish_fn_2+0x10b>
			7e6: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     7ea:	test   rax,rax
     7ed:	jne    7fb <botlish_fn_2+0x11c>
     7f3:	mov    rdi,r14
     7f6:	jmp    861 <botlish_fn_2+0x182>
     7fb:	mov    QWORD PTR [r13+0x10],rax
     7ff:	mov    rdx,rax
     802:	lea    rcx,[rbx+0x1]
     806:	shl    rcx,1
     809:	or     rcx,0x1
     80d:	mov    QWORD PTR [r13+0x28],rcx
     811:	mov    rbx,rcx
     814:	mov    rax,QWORD PTR [rip+0x0]        # 81b <botlish_fn_2+0x13c>
			817: R_X86_64_GOTPCREL	rt_list_append-0x4
     81b:	mov    rsi,QWORD PTR [rsp+0x28]
     820:	mov    rdi,r14
     823:	call   rax
     825:	test   rax,rax
     828:	jne    836 <botlish_fn_2+0x157>
     82e:	mov    rdi,r14
     831:	jmp    861 <botlish_fn_2+0x182>
     836:	mov    QWORD PTR [r13+0x10],rax
     83a:	mov    rcx,rbx
     83d:	mov    rdx,QWORD PTR [rsp+0x18]
     842:	mov    rsi,QWORD PTR [rsp+0x10]
     847:	mov    r8,r15
     84a:	mov    r9,rax
     84d:	mov    rdi,r14
     850:	call   855 <botlish_fn_2+0x176>
			851: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<int>>
     855:	test   rax,rax
     858:	jne    88c <botlish_fn_2+0x1ad>
     85e:	mov    rdi,r14
     861:	mov    rdi,r14
     864:	mov    QWORD PTR [rdi],r13
     867:	xor    rax,rax
     86a:	mov    rbx,QWORD PTR [rsp+0x30]
     86f:	mov    r12,QWORD PTR [rsp+0x38]
     874:	mov    r13,QWORD PTR [rsp+0x40]
     879:	mov    r14,QWORD PTR [rsp+0x48]
     87e:	mov    r15,QWORD PTR [rsp+0x50]
     883:	add    rsp,0x60
     887:	mov    rsp,rbp
     88a:	pop    rbp
     88b:	ret
     88c:	mov    rdi,r14
     88f:	mov    QWORD PTR [rdi],r13
     892:	mov    rbx,QWORD PTR [rsp+0x30]
     897:	mov    r12,QWORD PTR [rsp+0x38]
     89c:	mov    r13,QWORD PTR [rsp+0x40]
     8a1:	mov    r14,QWORD PTR [rsp+0x48]
     8a6:	mov    r15,QWORD PTR [rsp+0x50]
     8ab:	add    rsp,0x60
     8af:	mov    rsp,rbp
     8b2:	pop    rbp
     8b3:	ret
     8b4:	mov    rdi,r14
     8b7:	mov    QWORD PTR [rdi],r13
     8ba:	mov    rax,QWORD PTR [rsp+0x28]
     8bf:	mov    rbx,QWORD PTR [rsp+0x30]
     8c4:	mov    r12,QWORD PTR [rsp+0x38]
     8c9:	mov    r13,QWORD PTR [rsp+0x40]
     8ce:	mov    r14,QWORD PTR [rsp+0x48]
     8d3:	mov    r15,QWORD PTR [rsp+0x50]
     8d8:	add    rsp,0x60
     8dc:	mov    rsp,rbp
     8df:	pop    rbp
     8e0:	ret
     8e1:	mov    r14,rdi
     8e4:	mov    r8,QWORD PTR [rip+0x0]        # 8eb <botlish_fn_2+0x20c>
			8e7: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     8eb:	call   r8
     8ee:	xor    rax,rax
     8f1:	mov    rbx,QWORD PTR [rsp+0x30]
     8f6:	mov    r12,QWORD PTR [rsp+0x38]
     8fb:	mov    r13,QWORD PTR [rsp+0x40]
     900:	mov    r14,QWORD PTR [rsp+0x48]
     905:	mov    r15,QWORD PTR [rsp+0x50]
     90a:	add    rsp,0x60
     90e:	mov    rsp,rbp
     911:	pop    rbp
     912:	ret

0000000000000913 <botlish_entry_2: product_row<list<int>, list<list<int>>, int, int, list<never>>>:
     913:	push   rbp
     914:	mov    rbp,rsp
     917:	mov    rsi,QWORD PTR [rdx]
     91a:	mov    r10,QWORD PTR [rdx+0x8]
     91e:	mov    rcx,QWORD PTR [rdx+0x10]
     922:	mov    r8,QWORD PTR [rdx+0x18]
     926:	mov    r9,QWORD PTR [rdx+0x20]
     92a:	mov    rdx,r10
     92d:	call   932 <botlish_entry_2+0x1f>
			92e: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
     932:	mov    rsp,rbp
     935:	pop    rbp
     936:	ret
	...

0000000000000938 <botlish_fn_3: product_row<list<int>, list<list<int>>, int, int, list<int>>>:
     938:	push   rbp
     939:	mov    rbp,rsp
     93c:	sub    rsp,0x60
     940:	mov    QWORD PTR [rsp+0x30],rbx
     945:	mov    QWORD PTR [rsp+0x38],r12
     94a:	mov    QWORD PTR [rsp+0x40],r13
     94f:	mov    QWORD PTR [rsp+0x48],r14
     954:	mov    QWORD PTR [rsp+0x50],r15
     959:	mov    r10,r8
     95c:	mov    r14,QWORD PTR [rdi]
     95f:	mov    rax,QWORD PTR [rdi+0x8]
     963:	lea    r8,[r14+0x38]
     967:	cmp    r8,rax
     96a:	ja     ba8 <botlish_fn_3+0x270>
     970:	lea    rax,[r14+0x38]
     974:	mov    QWORD PTR [rdi],rax
     977:	mov    r15,rdi
     97a:	mov    QWORD PTR [r14],0x0
     981:	mov    QWORD PTR [r14+0x8],0x0
     989:	mov    QWORD PTR [r14+0x10],0x0
     991:	mov    QWORD PTR [r14+0x18],0x0
     999:	mov    QWORD PTR [r14+0x20],0x0
     9a1:	mov    QWORD PTR [r14+0x28],0x0
     9a9:	mov    QWORD PTR [r14+0x30],0x0
     9b1:	mov    QWORD PTR [r14],rsi
     9b4:	mov    r12,rsi
     9b7:	mov    QWORD PTR [r14+0x8],rdx
     9bb:	mov    QWORD PTR [rsp+0x10],rdx
     9c0:	mov    QWORD PTR [r14+0x10],rcx
     9c4:	mov    QWORD PTR [r14+0x18],r9
     9c8:	mov    rbx,r10
     9cb:	mov    rsi,rcx
     9ce:	mov    QWORD PTR [rsp+0x20],r9
     9d3:	mov    rax,rbx
     9d6:	or     rax,0x1
     9da:	mov    rcx,rsi
     9dd:	and    rcx,rax
     9e0:	mov    QWORD PTR [rsp+0x18],rsi
     9e5:	test   rcx,0x1
     9ec:	jne    a1f <botlish_fn_3+0xe7>
     9f2:	mov    rdx,rbx
     9f5:	or     rdx,0x1
     9f9:	mov    rax,QWORD PTR [rip+0x0]        # a00 <botlish_fn_3+0xc8>
			9fc: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     a00:	mov    rsi,QWORD PTR [rsp+0x18]
     a05:	mov    rdi,r15
     a08:	call   rax
     a0a:	mov    ecx,0x2
     a0f:	test   rax,rax
     a12:	cmove  rcx,QWORD PTR [rip+0x1c6]        # be0 <botlish_fn_3+0x2a8>
     a1a:	jmp    a3b <botlish_fn_3+0x103>
     a1f:	mov    rax,rbx
     a22:	or     rax,0x1
     a26:	mov    ecx,0x2
     a2b:	mov    rsi,QWORD PTR [rsp+0x18]
     a30:	cmp    rsi,rax
     a33:	cmove  rcx,QWORD PTR [rip+0x1a5]        # be0 <botlish_fn_3+0x2a8>
     a3b:	cmp    rcx,0x6
     a3f:	je     b7b <botlish_fn_3+0x243>
     a45:	mov    r13d,0x1
     a4b:	mov    QWORD PTR [r14+0x20],0x1
     a53:	mov    r8,QWORD PTR [rip+0x0]        # a5a <botlish_fn_3+0x122>
			a56: R_X86_64_GOTPCREL	rt_list_len-0x4
     a5a:	mov    rsi,r12
     a5d:	mov    rdi,r15
     a60:	call   r8
     a63:	mov    QWORD PTR [r14+0x28],rax
     a67:	mov    QWORD PTR [r14+0x30],0x1
     a6f:	mov    QWORD PTR [rsp],r13
     a73:	mov    r9,rax
     a76:	mov    r8,r13
     a79:	mov    r13,QWORD PTR [rsp+0x10]
     a7e:	mov    rcx,QWORD PTR [rsp+0x18]
     a83:	mov    rdx,r13
     a86:	mov    rsi,r12
     a89:	mov    rdi,r15
     a8c:	call   a91 <botlish_fn_3+0x159>
			a8d: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     a91:	test   rax,rax
     a94:	jne    aa2 <botlish_fn_3+0x16a>
     a9a:	mov    rdi,r15
     a9d:	jmp    b2d <botlish_fn_3+0x1f5>
     aa2:	mov    QWORD PTR [r14+0x20],rax
     aa6:	mov    QWORD PTR [rsp+0x28],rax
     aab:	mov    QWORD PTR [r14+0x28],0x3
     ab3:	mov    rsi,QWORD PTR [rsp+0x18]
     ab8:	test   rsi,0x1
     abf:	je     ae9 <botlish_fn_3+0x1b1>
     ac5:	mov    rsi,QWORD PTR [rsp+0x18]
     aca:	mov    rax,rsi
     acd:	add    rax,0x2
     ad1:	seto   cl
     ad4:	test   cl,cl
     ad6:	jne    ae9 <botlish_fn_3+0x1b1>
     adc:	mov    rsi,rax
     adf:	mov    QWORD PTR [rsp+0x18],rax
     ae4:	jmp    b07 <botlish_fn_3+0x1cf>
     ae9:	mov    edx,0x3
     aee:	mov    rax,QWORD PTR [rip+0x0]        # af5 <botlish_fn_3+0x1bd>
			af1: R_X86_64_GOTPCREL	rt_int_add-0x4
     af5:	mov    rsi,QWORD PTR [rsp+0x18]
     afa:	mov    rdi,r15
     afd:	call   rax
     aff:	mov    rsi,rax
     b02:	mov    QWORD PTR [rsp+0x18],rax
     b07:	mov    QWORD PTR [r14+0x10],rsi
     b0b:	mov    rax,QWORD PTR [rip+0x0]        # b12 <botlish_fn_3+0x1da>
			b0e: R_X86_64_GOTPCREL	rt_list_append-0x4
     b12:	mov    rdx,QWORD PTR [rsp+0x28]
     b17:	mov    rsi,QWORD PTR [rsp+0x20]
     b1c:	mov    rdi,r15
     b1f:	call   rax
     b21:	test   rax,rax
     b24:	jne    b58 <botlish_fn_3+0x220>
     b2a:	mov    rdi,r15
     b2d:	mov    rdi,r15
     b30:	mov    QWORD PTR [rdi],r14
     b33:	xor    rax,rax
     b36:	mov    rbx,QWORD PTR [rsp+0x30]
     b3b:	mov    r12,QWORD PTR [rsp+0x38]
     b40:	mov    r13,QWORD PTR [rsp+0x40]
     b45:	mov    r14,QWORD PTR [rsp+0x48]
     b4a:	mov    r15,QWORD PTR [rsp+0x50]
     b4f:	add    rsp,0x60
     b53:	mov    rsp,rbp
     b56:	pop    rbp
     b57:	ret
     b58:	mov    QWORD PTR [r14],r12
     b5b:	mov    QWORD PTR [r14+0x8],r13
     b5f:	mov    rsi,QWORD PTR [rsp+0x18]
     b64:	mov    QWORD PTR [r14+0x10],rsi
     b68:	mov    QWORD PTR [r14+0x18],rax
     b6c:	mov    QWORD PTR [rsp+0x10],r13
     b71:	mov    QWORD PTR [rsp+0x20],rax
     b76:	jmp    9d3 <botlish_fn_3+0x9b>
     b7b:	mov    rdi,r15
     b7e:	mov    QWORD PTR [rdi],r14
     b81:	mov    rax,QWORD PTR [rsp+0x20]
     b86:	mov    rbx,QWORD PTR [rsp+0x30]
     b8b:	mov    r12,QWORD PTR [rsp+0x38]
     b90:	mov    r13,QWORD PTR [rsp+0x40]
     b95:	mov    r14,QWORD PTR [rsp+0x48]
     b9a:	mov    r15,QWORD PTR [rsp+0x50]
     b9f:	add    rsp,0x60
     ba3:	mov    rsp,rbp
     ba6:	pop    rbp
     ba7:	ret
     ba8:	mov    r15,rdi
     bab:	mov    rax,QWORD PTR [rip+0x0]        # bb2 <botlish_fn_3+0x27a>
			bae: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     bb2:	call   rax
     bb4:	xor    rax,rax
     bb7:	mov    rbx,QWORD PTR [rsp+0x30]
     bbc:	mov    r12,QWORD PTR [rsp+0x38]
     bc1:	mov    r13,QWORD PTR [rsp+0x40]
     bc6:	mov    r14,QWORD PTR [rsp+0x48]
     bcb:	mov    r15,QWORD PTR [rsp+0x50]
     bd0:	add    rsp,0x60
     bd4:	mov    rsp,rbp
     bd7:	pop    rbp
     bd8:	ret
     bd9:	add    BYTE PTR [rax],al
     bdb:	add    BYTE PTR [rax],al
     bdd:	add    BYTE PTR [rax],al
     bdf:	add    BYTE PTR [rsi],al
     be1:	add    BYTE PTR [rax],al
     be3:	add    BYTE PTR [rax],al
     be5:	add    BYTE PTR [rax],al
	...

0000000000000be8 <botlish_entry_3: product_row<list<int>, list<list<int>>, int, int, list<int>>>:
     be8:	push   rbp
     be9:	mov    rbp,rsp
     bec:	mov    rsi,QWORD PTR [rdx]
     bef:	mov    r10,QWORD PTR [rdx+0x8]
     bf3:	mov    rcx,QWORD PTR [rdx+0x10]
     bf7:	mov    r8,QWORD PTR [rdx+0x18]
     bfb:	mov    r9,QWORD PTR [rdx+0x20]
     bff:	mov    rdx,r10
     c02:	call   c07 <botlish_entry_3+0x1f>
			c03: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<int>>
     c07:	mov    rsp,rbp
     c0a:	pop    rbp
     c0b:	ret

0000000000000c0c <botlish_fn_4: product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>>:
     c0c:	push   rbp
     c0d:	mov    rbp,rsp
     c10:	sub    rsp,0x50
     c14:	mov    QWORD PTR [rsp+0x20],rbx
     c19:	mov    QWORD PTR [rsp+0x28],r12
     c1e:	mov    QWORD PTR [rsp+0x30],r13
     c23:	mov    QWORD PTR [rsp+0x38],r14
     c28:	mov    QWORD PTR [rsp+0x40],r15
     c2d:	mov    rbx,rcx
     c30:	mov    r12,QWORD PTR [rdi]
     c33:	mov    rax,QWORD PTR [rdi+0x8]
     c37:	lea    rcx,[r12+0x38]
     c3c:	cmp    rcx,rax
     c3f:	ja     e76 <botlish_fn_4+0x26a>
     c45:	lea    rax,[r12+0x38]
     c4a:	mov    QWORD PTR [rdi],rax
     c4d:	mov    r13,rdi
     c50:	mov    QWORD PTR [r12],0x0
     c58:	mov    QWORD PTR [r12+0x8],0x0
     c61:	mov    QWORD PTR [r12+0x10],0x0
     c6a:	mov    QWORD PTR [r12+0x18],0x0
     c73:	mov    QWORD PTR [r12+0x20],0x0
     c7c:	mov    QWORD PTR [r12+0x28],0x0
     c85:	mov    QWORD PTR [r12+0x30],0x0
     c8e:	mov    QWORD PTR [r12],rsi
     c92:	mov    QWORD PTR [rsp],rsi
     c96:	mov    QWORD PTR [r12+0x8],rdx
     c9b:	mov    r15,rdx
     c9e:	mov    QWORD PTR [r12+0x10],r8
     ca3:	mov    r14,r8
     ca6:	mov    QWORD PTR [r12+0x18],r9
     cab:	mov    QWORD PTR [rsp+0x8],r9
     cb0:	mov    rax,QWORD PTR [rip+0x0]        # cb7 <botlish_fn_4+0xab>
			cb3: R_X86_64_GOTPCREL	rt_list_len-0x4
     cb7:	mov    rsi,QWORD PTR [rsp]
     cbb:	mov    rdi,r13
     cbe:	call   rax
     cc0:	mov    rcx,rbx
     cc3:	sar    rbx,1
     cc6:	sar    rax,1
     cc9:	cmp    rbx,rax
     ccc:	je     e49 <botlish_fn_4+0x23d>
     cd2:	test   rcx,0x1
     cd9:	je     cf0 <botlish_fn_4+0xe4>
     cdf:	mov    rsi,QWORD PTR [rsp]
     ce3:	mov    rax,QWORD PTR [rsi+0x8]
     ce7:	cmp    rbx,rax
     cea:	jb     d1c <botlish_fn_4+0x110>
     cf0:	mov    rax,QWORD PTR [rip+0x0]        # cf7 <botlish_fn_4+0xeb>
			cf3: R_X86_64_GOTPCREL	rt_list_get-0x4
     cf7:	mov    rdx,rcx
     cfa:	mov    rsi,QWORD PTR [rsp]
     cfe:	mov    rdi,r13
     d01:	call   rax
     d03:	test   rax,rax
     d06:	jne    d14 <botlish_fn_4+0x108>
     d0c:	mov    rdi,r13
     d0f:	jmp    df6 <botlish_fn_4+0x1ea>
     d14:	mov    rsi,rax
     d17:	jmp    d28 <botlish_fn_4+0x11c>
     d1c:	mov    rsi,QWORD PTR [rsp]
     d20:	mov    rsi,QWORD PTR [rsi+0x10]
     d24:	mov    rsi,QWORD PTR [rsi+rbx*8]
     d28:	mov    QWORD PTR [r12+0x20],rsi
     d2d:	mov    QWORD PTR [rsp+0x10],rsi
     d32:	mov    QWORD PTR [r12+0x28],0x1
     d3b:	xor    rdx,rdx
     d3e:	mov    r8,QWORD PTR [rip+0x0]        # d45 <botlish_fn_4+0x139>
			d41: R_X86_64_GOTPCREL	rt_list_new-0x4
     d45:	mov    rdi,r13
     d48:	mov    rsi,rdx
     d4b:	call   r8
     d4e:	test   rax,rax
     d51:	jne    d5f <botlish_fn_4+0x153>
     d57:	mov    rdi,r13
     d5a:	jmp    df6 <botlish_fn_4+0x1ea>
     d5f:	mov    QWORD PTR [r12+0x30],rax
     d64:	mov    r9,rax
     d67:	mov    ecx,0x1
     d6c:	mov    rsi,QWORD PTR [rsp+0x10]
     d71:	mov    rdx,r15
     d74:	mov    rdi,r13
     d77:	mov    r8,r14
     d7a:	call   d7f <botlish_fn_4+0x173>
			d7b: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
     d7f:	test   rax,rax
     d82:	jne    d90 <botlish_fn_4+0x184>
     d88:	mov    rdi,r13
     d8b:	jmp    df6 <botlish_fn_4+0x1ea>
     d90:	mov    QWORD PTR [r12+0x20],rax
     d95:	mov    rdx,rax
     d98:	lea    rcx,[rbx+0x1]
     d9c:	shl    rcx,1
     d9f:	or     rcx,0x1
     da3:	mov    QWORD PTR [r12+0x28],rcx
     da8:	mov    rbx,rcx
     dab:	mov    rax,QWORD PTR [rip+0x0]        # db2 <botlish_fn_4+0x1a6>
			dae: R_X86_64_GOTPCREL	rt_list_append-0x4
     db2:	mov    rsi,QWORD PTR [rsp+0x8]
     db7:	mov    rdi,r13
     dba:	call   rax
     dbc:	test   rax,rax
     dbf:	jne    dcd <botlish_fn_4+0x1c1>
     dc5:	mov    rdi,r13
     dc8:	jmp    df6 <botlish_fn_4+0x1ea>
     dcd:	mov    QWORD PTR [r12+0x18],rax
     dd2:	mov    rcx,rbx
     dd5:	mov    rdx,r15
     dd8:	mov    rsi,QWORD PTR [rsp]
     ddc:	mov    r8,r14
     ddf:	mov    r9,rax
     de2:	mov    rdi,r13
     de5:	call   dea <botlish_fn_4+0x1de>
			de6: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>
     dea:	test   rax,rax
     ded:	jne    e21 <botlish_fn_4+0x215>
     df3:	mov    rdi,r13
     df6:	mov    rdi,r13
     df9:	mov    QWORD PTR [rdi],r12
     dfc:	xor    rax,rax
     dff:	mov    rbx,QWORD PTR [rsp+0x20]
     e04:	mov    r12,QWORD PTR [rsp+0x28]
     e09:	mov    r13,QWORD PTR [rsp+0x30]
     e0e:	mov    r14,QWORD PTR [rsp+0x38]
     e13:	mov    r15,QWORD PTR [rsp+0x40]
     e18:	add    rsp,0x50
     e1c:	mov    rsp,rbp
     e1f:	pop    rbp
     e20:	ret
     e21:	mov    rdi,r13
     e24:	mov    QWORD PTR [rdi],r12
     e27:	mov    rbx,QWORD PTR [rsp+0x20]
     e2c:	mov    r12,QWORD PTR [rsp+0x28]
     e31:	mov    r13,QWORD PTR [rsp+0x30]
     e36:	mov    r14,QWORD PTR [rsp+0x38]
     e3b:	mov    r15,QWORD PTR [rsp+0x40]
     e40:	add    rsp,0x50
     e44:	mov    rsp,rbp
     e47:	pop    rbp
     e48:	ret
     e49:	mov    rdi,r13
     e4c:	mov    QWORD PTR [rdi],r12
     e4f:	mov    rax,QWORD PTR [rsp+0x8]
     e54:	mov    rbx,QWORD PTR [rsp+0x20]
     e59:	mov    r12,QWORD PTR [rsp+0x28]
     e5e:	mov    r13,QWORD PTR [rsp+0x30]
     e63:	mov    r14,QWORD PTR [rsp+0x38]
     e68:	mov    r15,QWORD PTR [rsp+0x40]
     e6d:	add    rsp,0x50
     e71:	mov    rsp,rbp
     e74:	pop    rbp
     e75:	ret
     e76:	mov    r13,rdi
     e79:	mov    rax,QWORD PTR [rip+0x0]        # e80 <botlish_fn_4+0x274>
			e7c: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     e80:	call   rax
     e82:	xor    rax,rax
     e85:	mov    rbx,QWORD PTR [rsp+0x20]
     e8a:	mov    r12,QWORD PTR [rsp+0x28]
     e8f:	mov    r13,QWORD PTR [rsp+0x30]
     e94:	mov    r14,QWORD PTR [rsp+0x38]
     e99:	mov    r15,QWORD PTR [rsp+0x40]
     e9e:	add    rsp,0x50
     ea2:	mov    rsp,rbp
     ea5:	pop    rbp
     ea6:	ret

0000000000000ea7 <botlish_entry_4: product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>>:
     ea7:	push   rbp
     ea8:	mov    rbp,rsp
     eab:	mov    rsi,QWORD PTR [rdx]
     eae:	mov    r10,QWORD PTR [rdx+0x8]
     eb2:	mov    rcx,QWORD PTR [rdx+0x10]
     eb6:	mov    r8,QWORD PTR [rdx+0x18]
     eba:	mov    r9,QWORD PTR [rdx+0x20]
     ebe:	mov    rdx,r10
     ec1:	call   ec6 <botlish_entry_4+0x1f>
			ec2: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>
     ec6:	mov    rsp,rbp
     ec9:	pop    rbp
     eca:	ret
     ecb:	add    BYTE PTR [rax],al
     ecd:	add    BYTE PTR [rax],al
	...

0000000000000ed0 <botlish_fn_5: product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>>:
     ed0:	push   rbp
     ed1:	mov    rbp,rsp
     ed4:	sub    rsp,0x50
     ed8:	mov    QWORD PTR [rsp+0x20],rbx
     edd:	mov    QWORD PTR [rsp+0x28],r12
     ee2:	mov    QWORD PTR [rsp+0x30],r13
     ee7:	mov    QWORD PTR [rsp+0x38],r14
     eec:	mov    QWORD PTR [rsp+0x40],r15
     ef1:	mov    r12,r8
     ef4:	mov    r14,QWORD PTR [rdi]
     ef7:	mov    rax,QWORD PTR [rdi+0x8]
     efb:	lea    r8,[r14+0x40]
     eff:	cmp    r8,rax
     f02:	ja     11a7 <botlish_fn_5+0x2d7>
     f08:	lea    rax,[r14+0x40]
     f0c:	mov    QWORD PTR [rdi],rax
     f0f:	mov    r15,rdi
     f12:	mov    QWORD PTR [r14],0x0
     f19:	mov    QWORD PTR [r14+0x8],0x0
     f21:	mov    QWORD PTR [r14+0x10],0x0
     f29:	mov    QWORD PTR [r14+0x18],0x0
     f31:	mov    QWORD PTR [r14+0x20],0x0
     f39:	mov    QWORD PTR [r14+0x28],0x0
     f41:	mov    QWORD PTR [r14+0x30],0x0
     f49:	mov    QWORD PTR [r14+0x38],0x0
     f51:	mov    QWORD PTR [r14],rsi
     f54:	mov    QWORD PTR [r14+0x8],rdx
     f58:	mov    r13,rdx
     f5b:	mov    QWORD PTR [r14+0x10],rcx
     f5f:	mov    QWORD PTR [r14+0x18],r9
     f63:	mov    QWORD PTR [rsp],rcx
     f67:	mov    QWORD PTR [rsp+0x8],r9
     f6c:	mov    r8,QWORD PTR [rip+0x0]        # f73 <botlish_fn_5+0xa3>
			f6f: R_X86_64_GOTPCREL	rt_list_len-0x4
     f73:	mov    rbx,rsi
     f76:	mov    rdi,r15
     f79:	call   r8
     f7c:	mov    rsi,QWORD PTR [rsp]
     f80:	mov    rdi,rsi
     f83:	and    rdi,rax
     f86:	mov    rdx,rax
     f89:	test   rdi,0x1
     f90:	jne    fbc <botlish_fn_5+0xec>
     f96:	mov    r8,QWORD PTR [rip+0x0]        # f9d <botlish_fn_5+0xcd>
			f99: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     f9d:	mov    rsi,QWORD PTR [rsp]
     fa1:	mov    rdi,r15
     fa4:	call   r8
     fa7:	mov    ecx,0x2
     fac:	test   rax,rax
     faf:	cmove  rcx,QWORD PTR [rip+0x221]        # 11d8 <botlish_fn_5+0x308>
     fb7:	jmp    fd0 <botlish_fn_5+0x100>
     fbc:	mov    ecx,0x2
     fc1:	mov    rsi,QWORD PTR [rsp]
     fc5:	cmp    rsi,rdx
     fc8:	cmove  rcx,QWORD PTR [rip+0x208]        # 11d8 <botlish_fn_5+0x308>
     fd0:	cmp    rcx,0x6
     fd4:	je     117a <botlish_fn_5+0x2aa>
     fda:	mov    rsi,QWORD PTR [rsp]
     fde:	test   rsi,0x1
     fe5:	je     1002 <botlish_fn_5+0x132>
     feb:	mov    rcx,QWORD PTR [rbx+0x8]
     fef:	mov    rsi,QWORD PTR [rsp]
     ff3:	mov    rax,rsi
     ff6:	sar    rax,1
     ff9:	cmp    rax,rcx
     ffc:	jb     102e <botlish_fn_5+0x15e>
    1002:	mov    rax,QWORD PTR [rip+0x0]        # 1009 <botlish_fn_5+0x139>
			1005: R_X86_64_GOTPCREL	rt_list_get-0x4
    1009:	mov    rdx,QWORD PTR [rsp]
    100d:	mov    rsi,rbx
    1010:	mov    rdi,r15
    1013:	call   rax
    1015:	test   rax,rax
    1018:	jne    1026 <botlish_fn_5+0x156>
    101e:	mov    rdi,r15
    1021:	jmp    112f <botlish_fn_5+0x25f>
    1026:	mov    rsi,rax
    1029:	jmp    1036 <botlish_fn_5+0x166>
    102e:	mov    rcx,QWORD PTR [rbx+0x10]
    1032:	mov    rsi,QWORD PTR [rcx+rax*8]
    1036:	mov    QWORD PTR [r14+0x20],rsi
    103a:	mov    QWORD PTR [rsp+0x10],rsi
    103f:	mov    QWORD PTR [r14+0x28],0x1
    1047:	mov    rax,r12
    104a:	or     rax,0x1
    104e:	mov    QWORD PTR [r14+0x30],rax
    1052:	xor    rdx,rdx
    1055:	mov    rax,QWORD PTR [rip+0x0]        # 105c <botlish_fn_5+0x18c>
			1058: R_X86_64_GOTPCREL	rt_list_new-0x4
    105c:	mov    rdi,r15
    105f:	mov    rsi,rdx
    1062:	call   rax
    1064:	test   rax,rax
    1067:	jne    1075 <botlish_fn_5+0x1a5>
    106d:	mov    rdi,r15
    1070:	jmp    112f <botlish_fn_5+0x25f>
    1075:	mov    QWORD PTR [r14+0x38],rax
    1079:	mov    r9,rax
    107c:	mov    ecx,0x1
    1081:	mov    r8,r12
    1084:	or     r8,0x1
    1088:	mov    rsi,QWORD PTR [rsp+0x10]
    108d:	mov    rdx,r13
    1090:	mov    rdi,r15
    1093:	call   1098 <botlish_fn_5+0x1c8>
			1094: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
    1098:	test   rax,rax
    109b:	jne    10a9 <botlish_fn_5+0x1d9>
    10a1:	mov    rdi,r15
    10a4:	jmp    112f <botlish_fn_5+0x25f>
    10a9:	mov    QWORD PTR [r14+0x20],rax
    10ad:	mov    QWORD PTR [rsp+0x10],rax
    10b2:	mov    QWORD PTR [r14+0x28],0x3
    10ba:	mov    rsi,QWORD PTR [rsp]
    10be:	test   rsi,0x1
    10c5:	je     10ed <botlish_fn_5+0x21d>
    10cb:	mov    rsi,QWORD PTR [rsp]
    10cf:	mov    rax,rsi
    10d2:	add    rax,0x2
    10d6:	seto   cl
    10d9:	test   cl,cl
    10db:	jne    10ed <botlish_fn_5+0x21d>
    10e1:	mov    rsi,rax
    10e4:	mov    QWORD PTR [rsp],rax
    10e8:	jmp    1109 <botlish_fn_5+0x239>
    10ed:	mov    edx,0x3
    10f2:	mov    rax,QWORD PTR [rip+0x0]        # 10f9 <botlish_fn_5+0x229>
			10f5: R_X86_64_GOTPCREL	rt_int_add-0x4
    10f9:	mov    rsi,QWORD PTR [rsp]
    10fd:	mov    rdi,r15
    1100:	call   rax
    1102:	mov    rsi,rax
    1105:	mov    QWORD PTR [rsp],rax
    1109:	mov    QWORD PTR [r14+0x10],rsi
    110d:	mov    rax,QWORD PTR [rip+0x0]        # 1114 <botlish_fn_5+0x244>
			1110: R_X86_64_GOTPCREL	rt_list_append-0x4
    1114:	mov    rdx,QWORD PTR [rsp+0x10]
    1119:	mov    rsi,QWORD PTR [rsp+0x8]
    111e:	mov    rdi,r15
    1121:	call   rax
    1123:	test   rax,rax
    1126:	jne    115a <botlish_fn_5+0x28a>
    112c:	mov    rdi,r15
    112f:	mov    rdi,r15
    1132:	mov    QWORD PTR [rdi],r14
    1135:	xor    rax,rax
    1138:	mov    rbx,QWORD PTR [rsp+0x20]
    113d:	mov    r12,QWORD PTR [rsp+0x28]
    1142:	mov    r13,QWORD PTR [rsp+0x30]
    1147:	mov    r14,QWORD PTR [rsp+0x38]
    114c:	mov    r15,QWORD PTR [rsp+0x40]
    1151:	add    rsp,0x50
    1155:	mov    rsp,rbp
    1158:	pop    rbp
    1159:	ret
    115a:	mov    QWORD PTR [r14],rbx
    115d:	mov    QWORD PTR [r14+0x8],r13
    1161:	mov    rsi,QWORD PTR [rsp]
    1165:	mov    QWORD PTR [r14+0x10],rsi
    1169:	mov    QWORD PTR [r14+0x18],rax
    116d:	mov    rsi,rbx
    1170:	mov    QWORD PTR [rsp+0x8],rax
    1175:	jmp    f6c <botlish_fn_5+0x9c>
    117a:	mov    rdi,r15
    117d:	mov    QWORD PTR [rdi],r14
    1180:	mov    rax,QWORD PTR [rsp+0x8]
    1185:	mov    rbx,QWORD PTR [rsp+0x20]
    118a:	mov    r12,QWORD PTR [rsp+0x28]
    118f:	mov    r13,QWORD PTR [rsp+0x30]
    1194:	mov    r14,QWORD PTR [rsp+0x38]
    1199:	mov    r15,QWORD PTR [rsp+0x40]
    119e:	add    rsp,0x50
    11a2:	mov    rsp,rbp
    11a5:	pop    rbp
    11a6:	ret
    11a7:	mov    r15,rdi
    11aa:	mov    rax,QWORD PTR [rip+0x0]        # 11b1 <botlish_fn_5+0x2e1>
			11ad: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    11b1:	call   rax
    11b3:	xor    rax,rax
    11b6:	mov    rbx,QWORD PTR [rsp+0x20]
    11bb:	mov    r12,QWORD PTR [rsp+0x28]
    11c0:	mov    r13,QWORD PTR [rsp+0x30]
    11c5:	mov    r14,QWORD PTR [rsp+0x38]
    11ca:	mov    r15,QWORD PTR [rsp+0x40]
    11cf:	add    rsp,0x50
    11d3:	mov    rsp,rbp
    11d6:	pop    rbp
    11d7:	ret
    11d8:	(bad)
    11d9:	add    BYTE PTR [rax],al
    11db:	add    BYTE PTR [rax],al
    11dd:	add    BYTE PTR [rax],al
	...

00000000000011e0 <botlish_entry_5: product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>>:
    11e0:	push   rbp
    11e1:	mov    rbp,rsp
    11e4:	mov    rsi,QWORD PTR [rdx]
    11e7:	mov    r10,QWORD PTR [rdx+0x8]
    11eb:	mov    rcx,QWORD PTR [rdx+0x10]
    11ef:	mov    r8,QWORD PTR [rdx+0x18]
    11f3:	mov    r9,QWORD PTR [rdx+0x20]
    11f7:	mov    rdx,r10
    11fa:	call   11ff <botlish_entry_5+0x1f>
			11fb: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>
    11ff:	mov    rsp,rbp
    1202:	pop    rbp
    1203:	ret

0000000000001204 <botlish_fn_6: matmul<list<list<int>>, list<list<int>>>>:
    1204:	push   rbp
    1205:	mov    rbp,rsp
    1208:	sub    rsp,0x30
    120c:	mov    QWORD PTR [rsp],rbx
    1210:	mov    QWORD PTR [rsp+0x8],r12
    1215:	mov    QWORD PTR [rsp+0x10],r13
    121a:	mov    QWORD PTR [rsp+0x18],r14
    121f:	mov    QWORD PTR [rsp+0x20],r15
    1224:	mov    r12,QWORD PTR [rdi]
    1227:	mov    rax,QWORD PTR [rdi+0x8]
    122b:	lea    rcx,[r12+0x28]
    1230:	cmp    rcx,rax
    1233:	ja     13e4 <botlish_fn_6+0x1e0>
    1239:	lea    rax,[r12+0x28]
    123e:	mov    QWORD PTR [rdi],rax
    1241:	mov    r13,rdi
    1244:	mov    QWORD PTR [r12],0x0
    124c:	mov    QWORD PTR [r12+0x8],0x0
    1255:	mov    QWORD PTR [r12+0x10],0x0
    125e:	mov    QWORD PTR [r12+0x18],0x0
    1267:	mov    QWORD PTR [r12+0x20],0x0
    1270:	mov    QWORD PTR [r12],rsi
    1274:	mov    r14,rsi
    1277:	mov    QWORD PTR [r12+0x8],rdx
    127c:	mov    rbx,rdx
    127f:	mov    rax,QWORD PTR [rip+0x0]        # 1286 <botlish_fn_6+0x82>
			1282: R_X86_64_GOTPCREL	rt_list_len-0x4
    1286:	mov    rsi,r14
    1289:	mov    rdi,r13
    128c:	call   rax
    128e:	sar    rax,1
    1291:	test   rax,rax
    1294:	je     1374 <botlish_fn_6+0x170>
    129a:	mov    QWORD PTR [r12+0x10],0x1
    12a3:	mov    rax,QWORD PTR [rbx+0x8]
    12a7:	test   rax,rax
    12aa:	jne    12dd <botlish_fn_6+0xd9>
    12b0:	mov    edx,0x1
    12b5:	mov    rax,QWORD PTR [rip+0x0]        # 12bc <botlish_fn_6+0xb8>
			12b8: R_X86_64_GOTPCREL	rt_list_get-0x4
    12bc:	mov    rsi,rbx
    12bf:	mov    rdi,r13
    12c2:	call   rax
    12c4:	test   rax,rax
    12c7:	jne    12d5 <botlish_fn_6+0xd1>
    12cd:	mov    rdi,r13
    12d0:	jmp    1393 <botlish_fn_6+0x18f>
    12d5:	mov    rsi,rax
    12d8:	jmp    12e7 <botlish_fn_6+0xe3>
    12dd:	mov    rdx,rbx
    12e0:	mov    rax,QWORD PTR [rdx+0x10]
    12e4:	mov    rsi,QWORD PTR [rax]
    12e7:	mov    rax,QWORD PTR [rip+0x0]        # 12ee <botlish_fn_6+0xea>
			12ea: R_X86_64_GOTPCREL	rt_list_len-0x4
    12ee:	mov    rdi,r13
    12f1:	call   rax
    12f3:	mov    QWORD PTR [r12+0x18],rax
    12f8:	mov    r15,rax
    12fb:	xor    rdx,rdx
    12fe:	mov    rax,QWORD PTR [rip+0x0]        # 1305 <botlish_fn_6+0x101>
			1301: R_X86_64_GOTPCREL	rt_list_new-0x4
    1305:	mov    rdi,r13
    1308:	mov    rsi,rdx
    130b:	call   rax
    130d:	test   rax,rax
    1310:	jne    131e <botlish_fn_6+0x11a>
    1316:	mov    rdi,r13
    1319:	jmp    1393 <botlish_fn_6+0x18f>
    131e:	mov    QWORD PTR [r12+0x20],rax
    1323:	mov    r9,rax
    1326:	mov    ecx,0x1
    132b:	mov    rdx,rbx
    132e:	mov    rsi,r14
    1331:	mov    r8,r15
    1334:	mov    rdi,r13
    1337:	call   133c <botlish_fn_6+0x138>
			1338: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>
    133c:	test   rax,rax
    133f:	jne    134d <botlish_fn_6+0x149>
    1345:	mov    rdi,r13
    1348:	jmp    1393 <botlish_fn_6+0x18f>
    134d:	mov    rdi,r13
    1350:	mov    QWORD PTR [rdi],r12
    1353:	mov    rbx,QWORD PTR [rsp]
    1357:	mov    r12,QWORD PTR [rsp+0x8]
    135c:	mov    r13,QWORD PTR [rsp+0x10]
    1361:	mov    r14,QWORD PTR [rsp+0x18]
    1366:	mov    r15,QWORD PTR [rsp+0x20]
    136b:	add    rsp,0x30
    136f:	mov    rsp,rbp
    1372:	pop    rbp
    1373:	ret
    1374:	xor    rdx,rdx
    1377:	mov    r8,QWORD PTR [rip+0x0]        # 137e <botlish_fn_6+0x17a>
			137a: R_X86_64_GOTPCREL	rt_list_new-0x4
    137e:	mov    rdi,r13
    1381:	mov    rsi,rdx
    1384:	call   r8
    1387:	test   rax,rax
    138a:	jne    13bd <botlish_fn_6+0x1b9>
    1390:	mov    rdi,r13
    1393:	mov    rdi,r13
    1396:	mov    QWORD PTR [rdi],r12
    1399:	xor    rax,rax
    139c:	mov    rbx,QWORD PTR [rsp]
    13a0:	mov    r12,QWORD PTR [rsp+0x8]
    13a5:	mov    r13,QWORD PTR [rsp+0x10]
    13aa:	mov    r14,QWORD PTR [rsp+0x18]
    13af:	mov    r15,QWORD PTR [rsp+0x20]
    13b4:	add    rsp,0x30
    13b8:	mov    rsp,rbp
    13bb:	pop    rbp
    13bc:	ret
    13bd:	mov    rdi,r13
    13c0:	mov    QWORD PTR [rdi],r12
    13c3:	mov    rbx,QWORD PTR [rsp]
    13c7:	mov    r12,QWORD PTR [rsp+0x8]
    13cc:	mov    r13,QWORD PTR [rsp+0x10]
    13d1:	mov    r14,QWORD PTR [rsp+0x18]
    13d6:	mov    r15,QWORD PTR [rsp+0x20]
    13db:	add    rsp,0x30
    13df:	mov    rsp,rbp
    13e2:	pop    rbp
    13e3:	ret
    13e4:	mov    r13,rdi
    13e7:	mov    rax,QWORD PTR [rip+0x0]        # 13ee <botlish_fn_6+0x1ea>
			13ea: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    13ee:	call   rax
    13f0:	xor    rax,rax
    13f3:	mov    rbx,QWORD PTR [rsp]
    13f7:	mov    r12,QWORD PTR [rsp+0x8]
    13fc:	mov    r13,QWORD PTR [rsp+0x10]
    1401:	mov    r14,QWORD PTR [rsp+0x18]
    1406:	mov    r15,QWORD PTR [rsp+0x20]
    140b:	add    rsp,0x30
    140f:	mov    rsp,rbp
    1412:	pop    rbp
    1413:	ret

0000000000001414 <botlish_entry_6: matmul<list<list<int>>, list<list<int>>>>:
    1414:	push   rbp
    1415:	mov    rbp,rsp
    1418:	mov    rsi,QWORD PTR [rdx]
    141b:	mov    rdx,QWORD PTR [rdx+0x8]
    141f:	call   1424 <botlish_entry_6+0x10>
			1420: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<list<list<int>>, list<list<int>>>
    1424:	mov    rsp,rbp
    1427:	pop    rbp
    1428:	ret

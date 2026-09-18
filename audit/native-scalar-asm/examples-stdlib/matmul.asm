; source:  examples/stdlib/matmul.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 4991  (per function: 944 724 609 732 668 788 526)
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
     3bd:	mov    r13,QWORD PTR [rdi]
     3c0:	mov    rax,QWORD PTR [rdi+0x8]
     3c4:	lea    r11,[r13+0x30]
     3c8:	cmp    r11,rax
     3cb:	ja     5f4 <botlish_fn_1+0x25c>
     3d1:	lea    rax,[r13+0x30]
     3d5:	mov    QWORD PTR [rdi],rax
     3d8:	mov    QWORD PTR [rsp],rdi
     3dc:	mov    QWORD PTR [r13+0x0],0x0
     3e4:	mov    QWORD PTR [r13+0x8],0x0
     3ec:	mov    QWORD PTR [r13+0x10],0x0
     3f4:	mov    QWORD PTR [r13+0x18],0x0
     3fc:	mov    QWORD PTR [r13+0x20],0x0
     404:	mov    QWORD PTR [r13+0x28],0x0
     40c:	mov    QWORD PTR [r13+0x0],rsi
     410:	mov    QWORD PTR [r13+0x8],rdx
     414:	mov    r14,rdx
     417:	mov    QWORD PTR [r13+0x10],rcx
     41b:	mov    r15,rcx
     41e:	mov    QWORD PTR [r13+0x18],r10
     422:	sar    r8,1
     425:	sar    r9,1
     428:	mov    QWORD PTR [rsp+0x20],r9
     42d:	mov    r12,r8
     430:	mov    QWORD PTR [rsp+0x8],r10
     435:	cmp    r12,r9
     438:	mov    QWORD PTR [rsp+0x20],r9
     43d:	je     5c6 <botlish_fn_1+0x22e>
     443:	mov    rdx,r12
     446:	shl    rdx,1
     449:	or     rdx,0x1
     44d:	mov    QWORD PTR [rsp+0x18],rdx
     452:	mov    r8,QWORD PTR [rip+0x0]        # 459 <botlish_fn_1+0xc1>
			455: R_X86_64_GOTPCREL	rt_list_get-0x4
     459:	mov    rbx,rsi
     45c:	mov    rdi,QWORD PTR [rsp]
     460:	call   r8
     463:	test   rax,rax
     466:	jne    475 <botlish_fn_1+0xdd>
     46c:	mov    rdi,QWORD PTR [rsp]
     470:	jmp    4c7 <botlish_fn_1+0x12f>
     475:	mov    QWORD PTR [r13+0x20],rax
     479:	mov    QWORD PTR [rsp+0x10],rax
     47e:	mov    r8,QWORD PTR [rip+0x0]        # 485 <botlish_fn_1+0xed>
			481: R_X86_64_GOTPCREL	rt_list_get-0x4
     485:	mov    rdx,QWORD PTR [rsp+0x18]
     48a:	mov    rsi,r14
     48d:	mov    rdi,QWORD PTR [rsp]
     491:	call   r8
     494:	test   rax,rax
     497:	mov    rsi,rax
     49a:	jne    4a9 <botlish_fn_1+0x111>
     4a0:	mov    rdi,QWORD PTR [rsp]
     4a4:	jmp    4c7 <botlish_fn_1+0x12f>
     4a9:	mov    r9,QWORD PTR [rip+0x0]        # 4b0 <botlish_fn_1+0x118>
			4ac: R_X86_64_GOTPCREL	rt_list_get-0x4
     4b0:	mov    rdx,r15
     4b3:	mov    rdi,QWORD PTR [rsp]
     4b7:	call   r9
     4ba:	test   rax,rax
     4bd:	jne    4f3 <botlish_fn_1+0x15b>
     4c3:	mov    rdi,QWORD PTR [rsp]
     4c7:	mov    rdi,QWORD PTR [rsp]
     4cb:	mov    QWORD PTR [rdi],r13
     4ce:	xor    rax,rax
     4d1:	mov    rbx,QWORD PTR [rsp+0x30]
     4d6:	mov    r12,QWORD PTR [rsp+0x38]
     4db:	mov    r13,QWORD PTR [rsp+0x40]
     4e0:	mov    r14,QWORD PTR [rsp+0x48]
     4e5:	mov    r15,QWORD PTR [rsp+0x50]
     4ea:	add    rsp,0x60
     4ee:	mov    rsp,rbp
     4f1:	pop    rbp
     4f2:	ret
     4f3:	mov    QWORD PTR [r13+0x28],rax
     4f7:	mov    rcx,QWORD PTR [rsp+0x10]
     4fc:	mov    rdx,rcx
     4ff:	and    rdx,rax
     502:	mov    rdi,rax
     505:	test   rdx,0x1
     50c:	jne    51c <botlish_fn_1+0x184>
     512:	mov    QWORD PTR [rsp+0x10],rcx
     517:	jmp    548 <botlish_fn_1+0x1b0>
     51c:	mov    rax,rcx
     51f:	sar    rax,1
     522:	mov    rsi,rdi
     525:	mov    QWORD PTR [rsp+0x10],rcx
     52a:	lea    rcx,[rsi-0x1]
     52e:	imul   rcx
     531:	seto   cl
     534:	or     rax,0x1
     538:	test   cl,cl
     53a:	jne    548 <botlish_fn_1+0x1b0>
     540:	mov    rdx,rax
     543:	jmp    560 <botlish_fn_1+0x1c8>
     548:	mov    rax,QWORD PTR [rip+0x0]        # 54f <botlish_fn_1+0x1b7>
			54b: R_X86_64_GOTPCREL	rt_int_mul-0x4
     54f:	mov    rdx,rdi
     552:	mov    rsi,QWORD PTR [rsp+0x10]
     557:	mov    rdi,QWORD PTR [rsp]
     55b:	call   rax
     55d:	mov    rdx,rax
     560:	mov    QWORD PTR [r13+0x20],rdx
     564:	mov    rsi,QWORD PTR [rsp+0x8]
     569:	mov    rax,rsi
     56c:	and    rax,rdx
     56f:	test   rax,0x1
     575:	je     590 <botlish_fn_1+0x1f8>
     57b:	lea    rcx,[rdx-0x1]
     57f:	mov    rax,rsi
     582:	add    rax,rcx
     585:	seto   cl
     588:	test   cl,cl
     58a:	je     59d <botlish_fn_1+0x205>
     590:	mov    rax,QWORD PTR [rip+0x0]        # 597 <botlish_fn_1+0x1ff>
			593: R_X86_64_GOTPCREL	rt_int_add-0x4
     597:	mov    rdi,QWORD PTR [rsp]
     59b:	call   rax
     59d:	mov    QWORD PTR [r13+0x0],rbx
     5a1:	mov    QWORD PTR [r13+0x8],r14
     5a5:	mov    QWORD PTR [r13+0x10],r15
     5a9:	mov    QWORD PTR [r13+0x18],rax
     5ad:	add    r12,0x1
     5b4:	mov    rsi,rbx
     5b7:	mov    r9,QWORD PTR [rsp+0x20]
     5bc:	mov    QWORD PTR [rsp+0x8],rax
     5c1:	jmp    435 <botlish_fn_1+0x9d>
     5c6:	mov    rdi,QWORD PTR [rsp]
     5ca:	mov    QWORD PTR [rdi],r13
     5cd:	mov    rax,QWORD PTR [rsp+0x8]
     5d2:	mov    rbx,QWORD PTR [rsp+0x30]
     5d7:	mov    r12,QWORD PTR [rsp+0x38]
     5dc:	mov    r13,QWORD PTR [rsp+0x40]
     5e1:	mov    r14,QWORD PTR [rsp+0x48]
     5e6:	mov    r15,QWORD PTR [rsp+0x50]
     5eb:	add    rsp,0x60
     5ef:	mov    rsp,rbp
     5f2:	pop    rbp
     5f3:	ret
     5f4:	mov    QWORD PTR [rsp],rdi
     5f8:	mov    rax,QWORD PTR [rip+0x0]        # 5ff <botlish_fn_1+0x267>
			5fb: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     5ff:	call   rax
     601:	xor    rax,rax
     604:	mov    rbx,QWORD PTR [rsp+0x30]
     609:	mov    r12,QWORD PTR [rsp+0x38]
     60e:	mov    r13,QWORD PTR [rsp+0x40]
     613:	mov    r14,QWORD PTR [rsp+0x48]
     618:	mov    r15,QWORD PTR [rsp+0x50]
     61d:	add    rsp,0x60
     621:	mov    rsp,rbp
     624:	pop    rbp
     625:	ret

0000000000000626 <botlish_entry_1: dot<list<int>, list<list<int>>, int, int, int, int>>:
     626:	push   rbp
     627:	mov    rbp,rsp
     62a:	sub    rsp,0x10
     62e:	mov    rsi,QWORD PTR [rdx]
     631:	mov    r10,QWORD PTR [rdx+0x8]
     635:	mov    rcx,QWORD PTR [rdx+0x10]
     639:	mov    r8,QWORD PTR [rdx+0x18]
     63d:	mov    r9,QWORD PTR [rdx+0x20]
     641:	mov    r11,QWORD PTR [rdx+0x28]
     645:	mov    QWORD PTR [rsp],r11
     649:	mov    rdx,r10
     64c:	call   651 <botlish_entry_1+0x2b>
			64d: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     651:	add    rsp,0x10
     655:	mov    rsp,rbp
     658:	pop    rbp
     659:	ret

000000000000065a <botlish_fn_2: product_row<list<int>, list<list<int>>, int, int, list<never>>>:
     65a:	push   rbp
     65b:	mov    rbp,rsp
     65e:	sub    rsp,0x60
     662:	mov    QWORD PTR [rsp+0x30],rbx
     667:	mov    QWORD PTR [rsp+0x38],r12
     66c:	mov    QWORD PTR [rsp+0x40],r13
     671:	mov    QWORD PTR [rsp+0x48],r14
     676:	mov    QWORD PTR [rsp+0x50],r15
     67b:	mov    r13,QWORD PTR [rdi]
     67e:	mov    rax,QWORD PTR [rdi+0x8]
     682:	lea    r10,[r13+0x40]
     686:	cmp    r10,rax
     689:	ja     85c <botlish_fn_2+0x202>
     68f:	lea    rax,[r13+0x40]
     693:	mov    QWORD PTR [rdi],rax
     696:	mov    r14,rdi
     699:	mov    QWORD PTR [r13+0x0],0x0
     6a1:	mov    QWORD PTR [r13+0x8],0x0
     6a9:	mov    QWORD PTR [r13+0x10],0x0
     6b1:	mov    QWORD PTR [r13+0x18],0x0
     6b9:	mov    QWORD PTR [r13+0x20],0x0
     6c1:	mov    QWORD PTR [r13+0x28],0x0
     6c9:	mov    QWORD PTR [r13+0x30],0x0
     6d1:	mov    QWORD PTR [r13+0x38],0x0
     6d9:	mov    QWORD PTR [r13+0x0],rsi
     6dd:	mov    QWORD PTR [rsp+0x10],rsi
     6e2:	mov    QWORD PTR [r13+0x8],rdx
     6e6:	mov    QWORD PTR [rsp+0x18],rdx
     6eb:	mov    QWORD PTR [r13+0x10],rcx
     6ef:	mov    QWORD PTR [r13+0x18],r8
     6f3:	mov    QWORD PTR [r13+0x20],r9
     6f7:	mov    QWORD PTR [rsp+0x28],r9
     6fc:	mov    rbx,rcx
     6ff:	sar    rbx,1
     702:	mov    QWORD PTR [rsp+0x20],rcx
     707:	mov    rax,r8
     70a:	sar    rax,1
     70d:	mov    r15,r8
     710:	cmp    rbx,rax
     713:	je     82f <botlish_fn_2+0x1d5>
     719:	mov    r12d,0x1
     71f:	mov    QWORD PTR [r13+0x28],0x1
     727:	mov    rax,QWORD PTR [rip+0x0]        # 72e <botlish_fn_2+0xd4>
			72a: R_X86_64_GOTPCREL	rt_list_len-0x4
     72e:	mov    rsi,QWORD PTR [rsp+0x10]
     733:	mov    rdi,r14
     736:	call   rax
     738:	mov    QWORD PTR [r13+0x30],rax
     73c:	mov    QWORD PTR [r13+0x38],0x1
     744:	mov    QWORD PTR [rsp],r12
     748:	mov    rcx,QWORD PTR [rsp+0x20]
     74d:	mov    r8,r12
     750:	mov    r9,rax
     753:	mov    rdx,QWORD PTR [rsp+0x18]
     758:	mov    rsi,QWORD PTR [rsp+0x10]
     75d:	mov    rdi,r14
     760:	call   765 <botlish_fn_2+0x10b>
			761: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     765:	test   rax,rax
     768:	jne    776 <botlish_fn_2+0x11c>
     76e:	mov    rdi,r14
     771:	jmp    7dc <botlish_fn_2+0x182>
     776:	mov    QWORD PTR [r13+0x10],rax
     77a:	mov    rdx,rax
     77d:	lea    rcx,[rbx+0x1]
     781:	shl    rcx,1
     784:	or     rcx,0x1
     788:	mov    QWORD PTR [r13+0x28],rcx
     78c:	mov    rbx,rcx
     78f:	mov    rax,QWORD PTR [rip+0x0]        # 796 <botlish_fn_2+0x13c>
			792: R_X86_64_GOTPCREL	rt_list_append-0x4
     796:	mov    rsi,QWORD PTR [rsp+0x28]
     79b:	mov    rdi,r14
     79e:	call   rax
     7a0:	test   rax,rax
     7a3:	jne    7b1 <botlish_fn_2+0x157>
     7a9:	mov    rdi,r14
     7ac:	jmp    7dc <botlish_fn_2+0x182>
     7b1:	mov    QWORD PTR [r13+0x10],rax
     7b5:	mov    rcx,rbx
     7b8:	mov    rdx,QWORD PTR [rsp+0x18]
     7bd:	mov    rsi,QWORD PTR [rsp+0x10]
     7c2:	mov    r8,r15
     7c5:	mov    r9,rax
     7c8:	mov    rdi,r14
     7cb:	call   7d0 <botlish_fn_2+0x176>
			7cc: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<int>>
     7d0:	test   rax,rax
     7d3:	jne    807 <botlish_fn_2+0x1ad>
     7d9:	mov    rdi,r14
     7dc:	mov    rdi,r14
     7df:	mov    QWORD PTR [rdi],r13
     7e2:	xor    rax,rax
     7e5:	mov    rbx,QWORD PTR [rsp+0x30]
     7ea:	mov    r12,QWORD PTR [rsp+0x38]
     7ef:	mov    r13,QWORD PTR [rsp+0x40]
     7f4:	mov    r14,QWORD PTR [rsp+0x48]
     7f9:	mov    r15,QWORD PTR [rsp+0x50]
     7fe:	add    rsp,0x60
     802:	mov    rsp,rbp
     805:	pop    rbp
     806:	ret
     807:	mov    rdi,r14
     80a:	mov    QWORD PTR [rdi],r13
     80d:	mov    rbx,QWORD PTR [rsp+0x30]
     812:	mov    r12,QWORD PTR [rsp+0x38]
     817:	mov    r13,QWORD PTR [rsp+0x40]
     81c:	mov    r14,QWORD PTR [rsp+0x48]
     821:	mov    r15,QWORD PTR [rsp+0x50]
     826:	add    rsp,0x60
     82a:	mov    rsp,rbp
     82d:	pop    rbp
     82e:	ret
     82f:	mov    rdi,r14
     832:	mov    QWORD PTR [rdi],r13
     835:	mov    rax,QWORD PTR [rsp+0x28]
     83a:	mov    rbx,QWORD PTR [rsp+0x30]
     83f:	mov    r12,QWORD PTR [rsp+0x38]
     844:	mov    r13,QWORD PTR [rsp+0x40]
     849:	mov    r14,QWORD PTR [rsp+0x48]
     84e:	mov    r15,QWORD PTR [rsp+0x50]
     853:	add    rsp,0x60
     857:	mov    rsp,rbp
     85a:	pop    rbp
     85b:	ret
     85c:	mov    r14,rdi
     85f:	mov    r8,QWORD PTR [rip+0x0]        # 866 <botlish_fn_2+0x20c>
			862: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     866:	call   r8
     869:	xor    rax,rax
     86c:	mov    rbx,QWORD PTR [rsp+0x30]
     871:	mov    r12,QWORD PTR [rsp+0x38]
     876:	mov    r13,QWORD PTR [rsp+0x40]
     87b:	mov    r14,QWORD PTR [rsp+0x48]
     880:	mov    r15,QWORD PTR [rsp+0x50]
     885:	add    rsp,0x60
     889:	mov    rsp,rbp
     88c:	pop    rbp
     88d:	ret

000000000000088e <botlish_entry_2: product_row<list<int>, list<list<int>>, int, int, list<never>>>:
     88e:	push   rbp
     88f:	mov    rbp,rsp
     892:	mov    rsi,QWORD PTR [rdx]
     895:	mov    r10,QWORD PTR [rdx+0x8]
     899:	mov    rcx,QWORD PTR [rdx+0x10]
     89d:	mov    r8,QWORD PTR [rdx+0x18]
     8a1:	mov    r9,QWORD PTR [rdx+0x20]
     8a5:	mov    rdx,r10
     8a8:	call   8ad <botlish_entry_2+0x1f>
			8a9: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
     8ad:	mov    rsp,rbp
     8b0:	pop    rbp
     8b1:	ret
     8b2:	add    BYTE PTR [rax],al
     8b4:	add    BYTE PTR [rax],al
	...

00000000000008b8 <botlish_fn_3: product_row<list<int>, list<list<int>>, int, int, list<int>>>:
     8b8:	push   rbp
     8b9:	mov    rbp,rsp
     8bc:	sub    rsp,0x60
     8c0:	mov    QWORD PTR [rsp+0x30],rbx
     8c5:	mov    QWORD PTR [rsp+0x38],r12
     8ca:	mov    QWORD PTR [rsp+0x40],r13
     8cf:	mov    QWORD PTR [rsp+0x48],r14
     8d4:	mov    QWORD PTR [rsp+0x50],r15
     8d9:	mov    r10,r8
     8dc:	mov    r14,QWORD PTR [rdi]
     8df:	mov    rax,QWORD PTR [rdi+0x8]
     8e3:	lea    r8,[r14+0x38]
     8e7:	cmp    r8,rax
     8ea:	ja     b28 <botlish_fn_3+0x270>
     8f0:	lea    rax,[r14+0x38]
     8f4:	mov    QWORD PTR [rdi],rax
     8f7:	mov    r15,rdi
     8fa:	mov    QWORD PTR [r14],0x0
     901:	mov    QWORD PTR [r14+0x8],0x0
     909:	mov    QWORD PTR [r14+0x10],0x0
     911:	mov    QWORD PTR [r14+0x18],0x0
     919:	mov    QWORD PTR [r14+0x20],0x0
     921:	mov    QWORD PTR [r14+0x28],0x0
     929:	mov    QWORD PTR [r14+0x30],0x0
     931:	mov    QWORD PTR [r14],rsi
     934:	mov    r12,rsi
     937:	mov    QWORD PTR [r14+0x8],rdx
     93b:	mov    QWORD PTR [rsp+0x10],rdx
     940:	mov    QWORD PTR [r14+0x10],rcx
     944:	mov    QWORD PTR [r14+0x18],r9
     948:	mov    rbx,r10
     94b:	mov    rsi,rcx
     94e:	mov    QWORD PTR [rsp+0x20],r9
     953:	mov    rax,rbx
     956:	or     rax,0x1
     95a:	mov    rcx,rsi
     95d:	and    rcx,rax
     960:	mov    QWORD PTR [rsp+0x18],rsi
     965:	test   rcx,0x1
     96c:	jne    99f <botlish_fn_3+0xe7>
     972:	mov    rdx,rbx
     975:	or     rdx,0x1
     979:	mov    rax,QWORD PTR [rip+0x0]        # 980 <botlish_fn_3+0xc8>
			97c: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     980:	mov    rsi,QWORD PTR [rsp+0x18]
     985:	mov    rdi,r15
     988:	call   rax
     98a:	mov    ecx,0x2
     98f:	test   rax,rax
     992:	cmove  rcx,QWORD PTR [rip+0x1c6]        # b60 <botlish_fn_3+0x2a8>
     99a:	jmp    9bb <botlish_fn_3+0x103>
     99f:	mov    rax,rbx
     9a2:	or     rax,0x1
     9a6:	mov    ecx,0x2
     9ab:	mov    rsi,QWORD PTR [rsp+0x18]
     9b0:	cmp    rsi,rax
     9b3:	cmove  rcx,QWORD PTR [rip+0x1a5]        # b60 <botlish_fn_3+0x2a8>
     9bb:	cmp    rcx,0x6
     9bf:	je     afb <botlish_fn_3+0x243>
     9c5:	mov    r13d,0x1
     9cb:	mov    QWORD PTR [r14+0x20],0x1
     9d3:	mov    r8,QWORD PTR [rip+0x0]        # 9da <botlish_fn_3+0x122>
			9d6: R_X86_64_GOTPCREL	rt_list_len-0x4
     9da:	mov    rsi,r12
     9dd:	mov    rdi,r15
     9e0:	call   r8
     9e3:	mov    QWORD PTR [r14+0x28],rax
     9e7:	mov    QWORD PTR [r14+0x30],0x1
     9ef:	mov    QWORD PTR [rsp],r13
     9f3:	mov    r9,rax
     9f6:	mov    r8,r13
     9f9:	mov    r13,QWORD PTR [rsp+0x10]
     9fe:	mov    rcx,QWORD PTR [rsp+0x18]
     a03:	mov    rdx,r13
     a06:	mov    rsi,r12
     a09:	mov    rdi,r15
     a0c:	call   a11 <botlish_fn_3+0x159>
			a0d: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     a11:	test   rax,rax
     a14:	jne    a22 <botlish_fn_3+0x16a>
     a1a:	mov    rdi,r15
     a1d:	jmp    aad <botlish_fn_3+0x1f5>
     a22:	mov    QWORD PTR [r14+0x20],rax
     a26:	mov    QWORD PTR [rsp+0x28],rax
     a2b:	mov    QWORD PTR [r14+0x28],0x3
     a33:	mov    rsi,QWORD PTR [rsp+0x18]
     a38:	test   rsi,0x1
     a3f:	je     a69 <botlish_fn_3+0x1b1>
     a45:	mov    rsi,QWORD PTR [rsp+0x18]
     a4a:	mov    rax,rsi
     a4d:	add    rax,0x2
     a51:	seto   cl
     a54:	test   cl,cl
     a56:	jne    a69 <botlish_fn_3+0x1b1>
     a5c:	mov    rsi,rax
     a5f:	mov    QWORD PTR [rsp+0x18],rax
     a64:	jmp    a87 <botlish_fn_3+0x1cf>
     a69:	mov    edx,0x3
     a6e:	mov    rax,QWORD PTR [rip+0x0]        # a75 <botlish_fn_3+0x1bd>
			a71: R_X86_64_GOTPCREL	rt_int_add-0x4
     a75:	mov    rsi,QWORD PTR [rsp+0x18]
     a7a:	mov    rdi,r15
     a7d:	call   rax
     a7f:	mov    rsi,rax
     a82:	mov    QWORD PTR [rsp+0x18],rax
     a87:	mov    QWORD PTR [r14+0x10],rsi
     a8b:	mov    rax,QWORD PTR [rip+0x0]        # a92 <botlish_fn_3+0x1da>
			a8e: R_X86_64_GOTPCREL	rt_list_append-0x4
     a92:	mov    rdx,QWORD PTR [rsp+0x28]
     a97:	mov    rsi,QWORD PTR [rsp+0x20]
     a9c:	mov    rdi,r15
     a9f:	call   rax
     aa1:	test   rax,rax
     aa4:	jne    ad8 <botlish_fn_3+0x220>
     aaa:	mov    rdi,r15
     aad:	mov    rdi,r15
     ab0:	mov    QWORD PTR [rdi],r14
     ab3:	xor    rax,rax
     ab6:	mov    rbx,QWORD PTR [rsp+0x30]
     abb:	mov    r12,QWORD PTR [rsp+0x38]
     ac0:	mov    r13,QWORD PTR [rsp+0x40]
     ac5:	mov    r14,QWORD PTR [rsp+0x48]
     aca:	mov    r15,QWORD PTR [rsp+0x50]
     acf:	add    rsp,0x60
     ad3:	mov    rsp,rbp
     ad6:	pop    rbp
     ad7:	ret
     ad8:	mov    QWORD PTR [r14],r12
     adb:	mov    QWORD PTR [r14+0x8],r13
     adf:	mov    rsi,QWORD PTR [rsp+0x18]
     ae4:	mov    QWORD PTR [r14+0x10],rsi
     ae8:	mov    QWORD PTR [r14+0x18],rax
     aec:	mov    QWORD PTR [rsp+0x10],r13
     af1:	mov    QWORD PTR [rsp+0x20],rax
     af6:	jmp    953 <botlish_fn_3+0x9b>
     afb:	mov    rdi,r15
     afe:	mov    QWORD PTR [rdi],r14
     b01:	mov    rax,QWORD PTR [rsp+0x20]
     b06:	mov    rbx,QWORD PTR [rsp+0x30]
     b0b:	mov    r12,QWORD PTR [rsp+0x38]
     b10:	mov    r13,QWORD PTR [rsp+0x40]
     b15:	mov    r14,QWORD PTR [rsp+0x48]
     b1a:	mov    r15,QWORD PTR [rsp+0x50]
     b1f:	add    rsp,0x60
     b23:	mov    rsp,rbp
     b26:	pop    rbp
     b27:	ret
     b28:	mov    r15,rdi
     b2b:	mov    rax,QWORD PTR [rip+0x0]        # b32 <botlish_fn_3+0x27a>
			b2e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     b32:	call   rax
     b34:	xor    rax,rax
     b37:	mov    rbx,QWORD PTR [rsp+0x30]
     b3c:	mov    r12,QWORD PTR [rsp+0x38]
     b41:	mov    r13,QWORD PTR [rsp+0x40]
     b46:	mov    r14,QWORD PTR [rsp+0x48]
     b4b:	mov    r15,QWORD PTR [rsp+0x50]
     b50:	add    rsp,0x60
     b54:	mov    rsp,rbp
     b57:	pop    rbp
     b58:	ret
     b59:	add    BYTE PTR [rax],al
     b5b:	add    BYTE PTR [rax],al
     b5d:	add    BYTE PTR [rax],al
     b5f:	add    BYTE PTR [rsi],al
     b61:	add    BYTE PTR [rax],al
     b63:	add    BYTE PTR [rax],al
     b65:	add    BYTE PTR [rax],al
	...

0000000000000b68 <botlish_entry_3: product_row<list<int>, list<list<int>>, int, int, list<int>>>:
     b68:	push   rbp
     b69:	mov    rbp,rsp
     b6c:	mov    rsi,QWORD PTR [rdx]
     b6f:	mov    r10,QWORD PTR [rdx+0x8]
     b73:	mov    rcx,QWORD PTR [rdx+0x10]
     b77:	mov    r8,QWORD PTR [rdx+0x18]
     b7b:	mov    r9,QWORD PTR [rdx+0x20]
     b7f:	mov    rdx,r10
     b82:	call   b87 <botlish_entry_3+0x1f>
			b83: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<int>>
     b87:	mov    rsp,rbp
     b8a:	pop    rbp
     b8b:	ret

0000000000000b8c <botlish_fn_4: product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>>:
     b8c:	push   rbp
     b8d:	mov    rbp,rsp
     b90:	sub    rsp,0x50
     b94:	mov    QWORD PTR [rsp+0x20],rbx
     b99:	mov    QWORD PTR [rsp+0x28],r12
     b9e:	mov    QWORD PTR [rsp+0x30],r13
     ba3:	mov    QWORD PTR [rsp+0x38],r14
     ba8:	mov    QWORD PTR [rsp+0x40],r15
     bad:	mov    rbx,rcx
     bb0:	mov    r12,QWORD PTR [rdi]
     bb3:	mov    rax,QWORD PTR [rdi+0x8]
     bb7:	lea    rcx,[r12+0x38]
     bbc:	cmp    rcx,rax
     bbf:	ja     dc4 <botlish_fn_4+0x238>
     bc5:	lea    rax,[r12+0x38]
     bca:	mov    QWORD PTR [rdi],rax
     bcd:	mov    r13,rdi
     bd0:	mov    QWORD PTR [r12],0x0
     bd8:	mov    QWORD PTR [r12+0x8],0x0
     be1:	mov    QWORD PTR [r12+0x10],0x0
     bea:	mov    QWORD PTR [r12+0x18],0x0
     bf3:	mov    QWORD PTR [r12+0x20],0x0
     bfc:	mov    QWORD PTR [r12+0x28],0x0
     c05:	mov    QWORD PTR [r12+0x30],0x0
     c0e:	mov    QWORD PTR [r12],rsi
     c12:	mov    QWORD PTR [rsp],rsi
     c16:	mov    QWORD PTR [r12+0x8],rdx
     c1b:	mov    r15,rdx
     c1e:	mov    QWORD PTR [r12+0x10],r8
     c23:	mov    r14,r8
     c26:	mov    QWORD PTR [r12+0x18],r9
     c2b:	mov    QWORD PTR [rsp+0x8],r9
     c30:	mov    rax,QWORD PTR [rip+0x0]        # c37 <botlish_fn_4+0xab>
			c33: R_X86_64_GOTPCREL	rt_list_len-0x4
     c37:	mov    rsi,QWORD PTR [rsp]
     c3b:	mov    rdi,r13
     c3e:	call   rax
     c40:	mov    rcx,rbx
     c43:	sar    rbx,1
     c46:	sar    rax,1
     c49:	cmp    rbx,rax
     c4c:	je     d97 <botlish_fn_4+0x20b>
     c52:	mov    rax,QWORD PTR [rip+0x0]        # c59 <botlish_fn_4+0xcd>
			c55: R_X86_64_GOTPCREL	rt_list_get-0x4
     c59:	mov    rdx,rcx
     c5c:	mov    rsi,QWORD PTR [rsp]
     c60:	mov    rdi,r13
     c63:	call   rax
     c65:	test   rax,rax
     c68:	jne    c76 <botlish_fn_4+0xea>
     c6e:	mov    rdi,r13
     c71:	jmp    d44 <botlish_fn_4+0x1b8>
     c76:	mov    QWORD PTR [r12+0x20],rax
     c7b:	mov    QWORD PTR [rsp+0x10],rax
     c80:	mov    QWORD PTR [r12+0x28],0x1
     c89:	xor    rdx,rdx
     c8c:	mov    rax,QWORD PTR [rip+0x0]        # c93 <botlish_fn_4+0x107>
			c8f: R_X86_64_GOTPCREL	rt_list_new-0x4
     c93:	mov    rdi,r13
     c96:	mov    rsi,rdx
     c99:	call   rax
     c9b:	test   rax,rax
     c9e:	jne    cac <botlish_fn_4+0x120>
     ca4:	mov    rdi,r13
     ca7:	jmp    d44 <botlish_fn_4+0x1b8>
     cac:	mov    QWORD PTR [r12+0x30],rax
     cb1:	mov    r9,rax
     cb4:	mov    ecx,0x1
     cb9:	mov    rsi,QWORD PTR [rsp+0x10]
     cbe:	mov    rdx,r15
     cc1:	mov    rdi,r13
     cc4:	mov    r8,r14
     cc7:	call   ccc <botlish_fn_4+0x140>
			cc8: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
     ccc:	test   rax,rax
     ccf:	jne    cdd <botlish_fn_4+0x151>
     cd5:	mov    rdi,r13
     cd8:	jmp    d44 <botlish_fn_4+0x1b8>
     cdd:	mov    QWORD PTR [r12+0x20],rax
     ce2:	mov    rdx,rax
     ce5:	lea    rcx,[rbx+0x1]
     ce9:	shl    rcx,1
     cec:	or     rcx,0x1
     cf0:	mov    QWORD PTR [r12+0x28],rcx
     cf5:	mov    rbx,rcx
     cf8:	mov    r8,QWORD PTR [rip+0x0]        # cff <botlish_fn_4+0x173>
			cfb: R_X86_64_GOTPCREL	rt_list_append-0x4
     cff:	mov    rsi,QWORD PTR [rsp+0x8]
     d04:	mov    rdi,r13
     d07:	call   r8
     d0a:	test   rax,rax
     d0d:	jne    d1b <botlish_fn_4+0x18f>
     d13:	mov    rdi,r13
     d16:	jmp    d44 <botlish_fn_4+0x1b8>
     d1b:	mov    QWORD PTR [r12+0x18],rax
     d20:	mov    rcx,rbx
     d23:	mov    rdx,r15
     d26:	mov    rsi,QWORD PTR [rsp]
     d2a:	mov    r8,r14
     d2d:	mov    r9,rax
     d30:	mov    rdi,r13
     d33:	call   d38 <botlish_fn_4+0x1ac>
			d34: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>
     d38:	test   rax,rax
     d3b:	jne    d6f <botlish_fn_4+0x1e3>
     d41:	mov    rdi,r13
     d44:	mov    rdi,r13
     d47:	mov    QWORD PTR [rdi],r12
     d4a:	xor    rax,rax
     d4d:	mov    rbx,QWORD PTR [rsp+0x20]
     d52:	mov    r12,QWORD PTR [rsp+0x28]
     d57:	mov    r13,QWORD PTR [rsp+0x30]
     d5c:	mov    r14,QWORD PTR [rsp+0x38]
     d61:	mov    r15,QWORD PTR [rsp+0x40]
     d66:	add    rsp,0x50
     d6a:	mov    rsp,rbp
     d6d:	pop    rbp
     d6e:	ret
     d6f:	mov    rdi,r13
     d72:	mov    QWORD PTR [rdi],r12
     d75:	mov    rbx,QWORD PTR [rsp+0x20]
     d7a:	mov    r12,QWORD PTR [rsp+0x28]
     d7f:	mov    r13,QWORD PTR [rsp+0x30]
     d84:	mov    r14,QWORD PTR [rsp+0x38]
     d89:	mov    r15,QWORD PTR [rsp+0x40]
     d8e:	add    rsp,0x50
     d92:	mov    rsp,rbp
     d95:	pop    rbp
     d96:	ret
     d97:	mov    rdi,r13
     d9a:	mov    QWORD PTR [rdi],r12
     d9d:	mov    rax,QWORD PTR [rsp+0x8]
     da2:	mov    rbx,QWORD PTR [rsp+0x20]
     da7:	mov    r12,QWORD PTR [rsp+0x28]
     dac:	mov    r13,QWORD PTR [rsp+0x30]
     db1:	mov    r14,QWORD PTR [rsp+0x38]
     db6:	mov    r15,QWORD PTR [rsp+0x40]
     dbb:	add    rsp,0x50
     dbf:	mov    rsp,rbp
     dc2:	pop    rbp
     dc3:	ret
     dc4:	mov    r13,rdi
     dc7:	mov    rax,QWORD PTR [rip+0x0]        # dce <botlish_fn_4+0x242>
			dca: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     dce:	call   rax
     dd0:	xor    rax,rax
     dd3:	mov    rbx,QWORD PTR [rsp+0x20]
     dd8:	mov    r12,QWORD PTR [rsp+0x28]
     ddd:	mov    r13,QWORD PTR [rsp+0x30]
     de2:	mov    r14,QWORD PTR [rsp+0x38]
     de7:	mov    r15,QWORD PTR [rsp+0x40]
     dec:	add    rsp,0x50
     df0:	mov    rsp,rbp
     df3:	pop    rbp
     df4:	ret

0000000000000df5 <botlish_entry_4: product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>>:
     df5:	push   rbp
     df6:	mov    rbp,rsp
     df9:	mov    rsi,QWORD PTR [rdx]
     dfc:	mov    r10,QWORD PTR [rdx+0x8]
     e00:	mov    rcx,QWORD PTR [rdx+0x10]
     e04:	mov    r8,QWORD PTR [rdx+0x18]
     e08:	mov    r9,QWORD PTR [rdx+0x20]
     e0c:	mov    rdx,r10
     e0f:	call   e14 <botlish_entry_4+0x1f>
			e10: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>
     e14:	mov    rsp,rbp
     e17:	pop    rbp
     e18:	ret
     e19:	add    BYTE PTR [rax],al
     e1b:	add    BYTE PTR [rax],al
     e1d:	add    BYTE PTR [rax],al
	...

0000000000000e20 <botlish_fn_5: product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>>:
     e20:	push   rbp
     e21:	mov    rbp,rsp
     e24:	sub    rsp,0x50
     e28:	mov    QWORD PTR [rsp+0x20],rbx
     e2d:	mov    QWORD PTR [rsp+0x28],r12
     e32:	mov    QWORD PTR [rsp+0x30],r13
     e37:	mov    QWORD PTR [rsp+0x38],r14
     e3c:	mov    QWORD PTR [rsp+0x40],r15
     e41:	mov    rbx,r8
     e44:	mov    r14,QWORD PTR [rdi]
     e47:	mov    rax,QWORD PTR [rdi+0x8]
     e4b:	lea    r8,[r14+0x40]
     e4f:	cmp    r8,rax
     e52:	ja     10be <botlish_fn_5+0x29e>
     e58:	lea    rax,[r14+0x40]
     e5c:	mov    QWORD PTR [rdi],rax
     e5f:	mov    r15,rdi
     e62:	mov    QWORD PTR [r14],0x0
     e69:	mov    QWORD PTR [r14+0x8],0x0
     e71:	mov    QWORD PTR [r14+0x10],0x0
     e79:	mov    QWORD PTR [r14+0x18],0x0
     e81:	mov    QWORD PTR [r14+0x20],0x0
     e89:	mov    QWORD PTR [r14+0x28],0x0
     e91:	mov    QWORD PTR [r14+0x30],0x0
     e99:	mov    QWORD PTR [r14+0x38],0x0
     ea1:	mov    QWORD PTR [r14],rsi
     ea4:	mov    QWORD PTR [r14+0x8],rdx
     ea8:	mov    r13,rdx
     eab:	mov    QWORD PTR [r14+0x10],rcx
     eaf:	mov    QWORD PTR [r14+0x18],r9
     eb3:	mov    QWORD PTR [rsp],rcx
     eb7:	mov    QWORD PTR [rsp+0x8],r9
     ebc:	mov    rax,QWORD PTR [rip+0x0]        # ec3 <botlish_fn_5+0xa3>
			ebf: R_X86_64_GOTPCREL	rt_list_len-0x4
     ec3:	mov    r12,rsi
     ec6:	mov    rdi,r15
     ec9:	call   rax
     ecb:	mov    rsi,QWORD PTR [rsp]
     ecf:	mov    rcx,rsi
     ed2:	and    rcx,rax
     ed5:	mov    rdx,rax
     ed8:	test   rcx,0x1
     edf:	jne    f0a <botlish_fn_5+0xea>
     ee5:	mov    rcx,QWORD PTR [rip+0x0]        # eec <botlish_fn_5+0xcc>
			ee8: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     eec:	mov    rsi,QWORD PTR [rsp]
     ef0:	mov    rdi,r15
     ef3:	call   rcx
     ef5:	mov    ecx,0x2
     efa:	test   rax,rax
     efd:	cmove  rcx,QWORD PTR [rip+0x1eb]        # 10f0 <botlish_fn_5+0x2d0>
     f05:	jmp    f1e <botlish_fn_5+0xfe>
     f0a:	mov    ecx,0x2
     f0f:	mov    rsi,QWORD PTR [rsp]
     f13:	cmp    rsi,rdx
     f16:	cmove  rcx,QWORD PTR [rip+0x1d2]        # 10f0 <botlish_fn_5+0x2d0>
     f1e:	cmp    rcx,0x6
     f22:	je     1091 <botlish_fn_5+0x271>
     f28:	mov    r8,QWORD PTR [rip+0x0]        # f2f <botlish_fn_5+0x10f>
			f2b: R_X86_64_GOTPCREL	rt_list_get-0x4
     f2f:	mov    rdx,QWORD PTR [rsp]
     f33:	mov    rsi,r12
     f36:	mov    rdi,r15
     f39:	call   r8
     f3c:	test   rax,rax
     f3f:	jne    f4d <botlish_fn_5+0x12d>
     f45:	mov    rdi,r15
     f48:	jmp    1046 <botlish_fn_5+0x226>
     f4d:	mov    QWORD PTR [r14+0x20],rax
     f51:	mov    QWORD PTR [rsp+0x10],rax
     f56:	mov    QWORD PTR [r14+0x28],0x1
     f5e:	mov    rax,rbx
     f61:	or     rax,0x1
     f65:	mov    QWORD PTR [r14+0x30],rax
     f69:	xor    rdx,rdx
     f6c:	mov    rax,QWORD PTR [rip+0x0]        # f73 <botlish_fn_5+0x153>
			f6f: R_X86_64_GOTPCREL	rt_list_new-0x4
     f73:	mov    rdi,r15
     f76:	mov    rsi,rdx
     f79:	call   rax
     f7b:	test   rax,rax
     f7e:	jne    f8c <botlish_fn_5+0x16c>
     f84:	mov    rdi,r15
     f87:	jmp    1046 <botlish_fn_5+0x226>
     f8c:	mov    QWORD PTR [r14+0x38],rax
     f90:	mov    r9,rax
     f93:	mov    ecx,0x1
     f98:	mov    r8,rbx
     f9b:	or     r8,0x1
     f9f:	mov    rsi,QWORD PTR [rsp+0x10]
     fa4:	mov    rdx,r13
     fa7:	mov    rdi,r15
     faa:	call   faf <botlish_fn_5+0x18f>
			fab: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
     faf:	test   rax,rax
     fb2:	jne    fc0 <botlish_fn_5+0x1a0>
     fb8:	mov    rdi,r15
     fbb:	jmp    1046 <botlish_fn_5+0x226>
     fc0:	mov    QWORD PTR [r14+0x20],rax
     fc4:	mov    QWORD PTR [rsp+0x10],rax
     fc9:	mov    QWORD PTR [r14+0x28],0x3
     fd1:	mov    rsi,QWORD PTR [rsp]
     fd5:	test   rsi,0x1
     fdc:	je     1004 <botlish_fn_5+0x1e4>
     fe2:	mov    rsi,QWORD PTR [rsp]
     fe6:	mov    rax,rsi
     fe9:	add    rax,0x2
     fed:	seto   cl
     ff0:	test   cl,cl
     ff2:	jne    1004 <botlish_fn_5+0x1e4>
     ff8:	mov    rsi,rax
     ffb:	mov    QWORD PTR [rsp],rax
     fff:	jmp    1020 <botlish_fn_5+0x200>
    1004:	mov    edx,0x3
    1009:	mov    rax,QWORD PTR [rip+0x0]        # 1010 <botlish_fn_5+0x1f0>
			100c: R_X86_64_GOTPCREL	rt_int_add-0x4
    1010:	mov    rsi,QWORD PTR [rsp]
    1014:	mov    rdi,r15
    1017:	call   rax
    1019:	mov    rsi,rax
    101c:	mov    QWORD PTR [rsp],rax
    1020:	mov    QWORD PTR [r14+0x10],rsi
    1024:	mov    rax,QWORD PTR [rip+0x0]        # 102b <botlish_fn_5+0x20b>
			1027: R_X86_64_GOTPCREL	rt_list_append-0x4
    102b:	mov    rdx,QWORD PTR [rsp+0x10]
    1030:	mov    rsi,QWORD PTR [rsp+0x8]
    1035:	mov    rdi,r15
    1038:	call   rax
    103a:	test   rax,rax
    103d:	jne    1071 <botlish_fn_5+0x251>
    1043:	mov    rdi,r15
    1046:	mov    rdi,r15
    1049:	mov    QWORD PTR [rdi],r14
    104c:	xor    rax,rax
    104f:	mov    rbx,QWORD PTR [rsp+0x20]
    1054:	mov    r12,QWORD PTR [rsp+0x28]
    1059:	mov    r13,QWORD PTR [rsp+0x30]
    105e:	mov    r14,QWORD PTR [rsp+0x38]
    1063:	mov    r15,QWORD PTR [rsp+0x40]
    1068:	add    rsp,0x50
    106c:	mov    rsp,rbp
    106f:	pop    rbp
    1070:	ret
    1071:	mov    QWORD PTR [r14],r12
    1074:	mov    QWORD PTR [r14+0x8],r13
    1078:	mov    rsi,QWORD PTR [rsp]
    107c:	mov    QWORD PTR [r14+0x10],rsi
    1080:	mov    QWORD PTR [r14+0x18],rax
    1084:	mov    rsi,r12
    1087:	mov    QWORD PTR [rsp+0x8],rax
    108c:	jmp    ebc <botlish_fn_5+0x9c>
    1091:	mov    rdi,r15
    1094:	mov    QWORD PTR [rdi],r14
    1097:	mov    rax,QWORD PTR [rsp+0x8]
    109c:	mov    rbx,QWORD PTR [rsp+0x20]
    10a1:	mov    r12,QWORD PTR [rsp+0x28]
    10a6:	mov    r13,QWORD PTR [rsp+0x30]
    10ab:	mov    r14,QWORD PTR [rsp+0x38]
    10b0:	mov    r15,QWORD PTR [rsp+0x40]
    10b5:	add    rsp,0x50
    10b9:	mov    rsp,rbp
    10bc:	pop    rbp
    10bd:	ret
    10be:	mov    r15,rdi
    10c1:	mov    rax,QWORD PTR [rip+0x0]        # 10c8 <botlish_fn_5+0x2a8>
			10c4: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    10c8:	call   rax
    10ca:	xor    rax,rax
    10cd:	mov    rbx,QWORD PTR [rsp+0x20]
    10d2:	mov    r12,QWORD PTR [rsp+0x28]
    10d7:	mov    r13,QWORD PTR [rsp+0x30]
    10dc:	mov    r14,QWORD PTR [rsp+0x38]
    10e1:	mov    r15,QWORD PTR [rsp+0x40]
    10e6:	add    rsp,0x50
    10ea:	mov    rsp,rbp
    10ed:	pop    rbp
    10ee:	ret
    10ef:	add    BYTE PTR [rsi],al
    10f1:	add    BYTE PTR [rax],al
    10f3:	add    BYTE PTR [rax],al
    10f5:	add    BYTE PTR [rax],al
	...

00000000000010f8 <botlish_entry_5: product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>>:
    10f8:	push   rbp
    10f9:	mov    rbp,rsp
    10fc:	mov    rsi,QWORD PTR [rdx]
    10ff:	mov    r10,QWORD PTR [rdx+0x8]
    1103:	mov    rcx,QWORD PTR [rdx+0x10]
    1107:	mov    r8,QWORD PTR [rdx+0x18]
    110b:	mov    r9,QWORD PTR [rdx+0x20]
    110f:	mov    rdx,r10
    1112:	call   1117 <botlish_entry_5+0x1f>
			1113: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>
    1117:	mov    rsp,rbp
    111a:	pop    rbp
    111b:	ret

000000000000111c <botlish_fn_6: matmul<list<list<int>>, list<list<int>>>>:
    111c:	push   rbp
    111d:	mov    rbp,rsp
    1120:	sub    rsp,0x30
    1124:	mov    QWORD PTR [rsp],rbx
    1128:	mov    QWORD PTR [rsp+0x8],r12
    112d:	mov    QWORD PTR [rsp+0x10],r13
    1132:	mov    QWORD PTR [rsp+0x18],r14
    1137:	mov    QWORD PTR [rsp+0x20],r15
    113c:	mov    rbx,QWORD PTR [rdi]
    113f:	mov    rax,QWORD PTR [rdi+0x8]
    1143:	lea    rcx,[rbx+0x28]
    1147:	cmp    rcx,rax
    114a:	ja     12d3 <botlish_fn_6+0x1b7>
    1150:	lea    rax,[rbx+0x28]
    1154:	mov    QWORD PTR [rdi],rax
    1157:	mov    r12,rdi
    115a:	mov    QWORD PTR [rbx],0x0
    1161:	mov    QWORD PTR [rbx+0x8],0x0
    1169:	mov    QWORD PTR [rbx+0x10],0x0
    1171:	mov    QWORD PTR [rbx+0x18],0x0
    1179:	mov    QWORD PTR [rbx+0x20],0x0
    1181:	mov    QWORD PTR [rbx],rsi
    1184:	mov    r14,rsi
    1187:	mov    QWORD PTR [rbx+0x8],rdx
    118b:	mov    r13,rdx
    118e:	mov    rax,QWORD PTR [rip+0x0]        # 1195 <botlish_fn_6+0x79>
			1191: R_X86_64_GOTPCREL	rt_list_len-0x4
    1195:	mov    rsi,r14
    1198:	mov    rdi,r12
    119b:	call   rax
    119d:	sar    rax,1
    11a0:	test   rax,rax
    11a3:	je     1264 <botlish_fn_6+0x148>
    11a9:	mov    edx,0x1
    11ae:	mov    QWORD PTR [rbx+0x10],0x1
    11b6:	mov    rax,QWORD PTR [rip+0x0]        # 11bd <botlish_fn_6+0xa1>
			11b9: R_X86_64_GOTPCREL	rt_list_get-0x4
    11bd:	mov    rsi,r13
    11c0:	mov    rdi,r12
    11c3:	call   rax
    11c5:	test   rax,rax
    11c8:	mov    rsi,rax
    11cb:	jne    11d9 <botlish_fn_6+0xbd>
    11d1:	mov    rdi,r12
    11d4:	jmp    1282 <botlish_fn_6+0x166>
    11d9:	mov    rax,QWORD PTR [rip+0x0]        # 11e0 <botlish_fn_6+0xc4>
			11dc: R_X86_64_GOTPCREL	rt_list_len-0x4
    11e0:	mov    rdi,r12
    11e3:	call   rax
    11e5:	mov    QWORD PTR [rbx+0x18],rax
    11e9:	mov    r15,rax
    11ec:	xor    rdx,rdx
    11ef:	mov    rax,QWORD PTR [rip+0x0]        # 11f6 <botlish_fn_6+0xda>
			11f2: R_X86_64_GOTPCREL	rt_list_new-0x4
    11f6:	mov    rdi,r12
    11f9:	mov    rsi,rdx
    11fc:	call   rax
    11fe:	test   rax,rax
    1201:	jne    120f <botlish_fn_6+0xf3>
    1207:	mov    rdi,r12
    120a:	jmp    1282 <botlish_fn_6+0x166>
    120f:	mov    QWORD PTR [rbx+0x20],rax
    1213:	mov    r9,rax
    1216:	mov    ecx,0x1
    121b:	mov    rdx,r13
    121e:	mov    rsi,r14
    1221:	mov    r8,r15
    1224:	mov    rdi,r12
    1227:	call   122c <botlish_fn_6+0x110>
			1228: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>
    122c:	test   rax,rax
    122f:	jne    123d <botlish_fn_6+0x121>
    1235:	mov    rdi,r12
    1238:	jmp    1282 <botlish_fn_6+0x166>
    123d:	mov    rdi,r12
    1240:	mov    QWORD PTR [rdi],rbx
    1243:	mov    rbx,QWORD PTR [rsp]
    1247:	mov    r12,QWORD PTR [rsp+0x8]
    124c:	mov    r13,QWORD PTR [rsp+0x10]
    1251:	mov    r14,QWORD PTR [rsp+0x18]
    1256:	mov    r15,QWORD PTR [rsp+0x20]
    125b:	add    rsp,0x30
    125f:	mov    rsp,rbp
    1262:	pop    rbp
    1263:	ret
    1264:	xor    rdx,rdx
    1267:	mov    rax,QWORD PTR [rip+0x0]        # 126e <botlish_fn_6+0x152>
			126a: R_X86_64_GOTPCREL	rt_list_new-0x4
    126e:	mov    rdi,r12
    1271:	mov    rsi,rdx
    1274:	call   rax
    1276:	test   rax,rax
    1279:	jne    12ac <botlish_fn_6+0x190>
    127f:	mov    rdi,r12
    1282:	mov    rdi,r12
    1285:	mov    QWORD PTR [rdi],rbx
    1288:	xor    rax,rax
    128b:	mov    rbx,QWORD PTR [rsp]
    128f:	mov    r12,QWORD PTR [rsp+0x8]
    1294:	mov    r13,QWORD PTR [rsp+0x10]
    1299:	mov    r14,QWORD PTR [rsp+0x18]
    129e:	mov    r15,QWORD PTR [rsp+0x20]
    12a3:	add    rsp,0x30
    12a7:	mov    rsp,rbp
    12aa:	pop    rbp
    12ab:	ret
    12ac:	mov    rdi,r12
    12af:	mov    QWORD PTR [rdi],rbx
    12b2:	mov    rbx,QWORD PTR [rsp]
    12b6:	mov    r12,QWORD PTR [rsp+0x8]
    12bb:	mov    r13,QWORD PTR [rsp+0x10]
    12c0:	mov    r14,QWORD PTR [rsp+0x18]
    12c5:	mov    r15,QWORD PTR [rsp+0x20]
    12ca:	add    rsp,0x30
    12ce:	mov    rsp,rbp
    12d1:	pop    rbp
    12d2:	ret
    12d3:	mov    r12,rdi
    12d6:	mov    rsi,QWORD PTR [rip+0x0]        # 12dd <botlish_fn_6+0x1c1>
			12d9: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    12dd:	call   rsi
    12df:	xor    rax,rax
    12e2:	mov    rbx,QWORD PTR [rsp]
    12e6:	mov    r12,QWORD PTR [rsp+0x8]
    12eb:	mov    r13,QWORD PTR [rsp+0x10]
    12f0:	mov    r14,QWORD PTR [rsp+0x18]
    12f5:	mov    r15,QWORD PTR [rsp+0x20]
    12fa:	add    rsp,0x30
    12fe:	mov    rsp,rbp
    1301:	pop    rbp
    1302:	ret

0000000000001303 <botlish_entry_6: matmul<list<list<int>>, list<list<int>>>>:
    1303:	push   rbp
    1304:	mov    rbp,rsp
    1307:	mov    rsi,QWORD PTR [rdx]
    130a:	mov    rdx,QWORD PTR [rdx+0x8]
    130e:	call   1313 <botlish_entry_6+0x10>
			130f: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<list<list<int>>, list<list<int>>>
    1313:	mov    rsp,rbp
    1316:	pop    rbp
    1317:	ret

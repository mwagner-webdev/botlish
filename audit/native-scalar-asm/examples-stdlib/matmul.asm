; source:  examples/stdlib/matmul.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 4949  (per function: 917 808 544 676 665 788 551)
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
      42:	ja     30f <botlish_fn_0+0x30f>
      48:	lea    rax,[r12+0x28]
      4d:	mov    QWORD PTR [rdi],rax
      50:	mov    r13,rdi
      53:	mov    QWORD PTR [r12+0x18],0x0
      5c:	mov    QWORD PTR [r12+0x20],0x0
      65:	mov    esi,0x3
      6a:	mov    QWORD PTR [r12],0x3
      72:	mov    QWORD PTR [r12+0x8],0x5
      7b:	mov    QWORD PTR [r12+0x10],0x7
      84:	lea    rdx,[rsp]
      88:	mov    QWORD PTR [rsp],0x3
      90:	mov    QWORD PTR [rsp+0x8],0x5
      99:	mov    QWORD PTR [rsp+0x10],0x7
      a2:	mov    rdi,r13
      a5:	call   aa <botlish_fn_0+0xaa>
			a6: R_X86_64_PLT32	rt_list_new-0x4
      aa:	test   rax,rax
      ad:	jne    bb <botlish_fn_0+0xbb>
      b3:	mov    rdi,r13
      b6:	jmp    298 <botlish_fn_0+0x298>
      bb:	mov    QWORD PTR [r12],rax
      bf:	mov    rbx,rax
      c2:	mov    QWORD PTR [r12+0x8],0x9
      cb:	mov    QWORD PTR [r12+0x10],0xb
      d4:	mov    QWORD PTR [r12+0x18],0xd
      dd:	lea    rdx,[rsp+0x18]
      e2:	mov    QWORD PTR [rsp+0x18],0x9
      eb:	mov    QWORD PTR [rsp+0x20],0xb
      f4:	mov    QWORD PTR [rsp+0x28],0xd
      fd:	mov    esi,0x3
     102:	mov    rdi,r13
     105:	call   10a <botlish_fn_0+0x10a>
			106: R_X86_64_PLT32	rt_list_new-0x4
     10a:	test   rax,rax
     10d:	jne    11b <botlish_fn_0+0x11b>
     113:	mov    rdi,r13
     116:	jmp    298 <botlish_fn_0+0x298>
     11b:	mov    QWORD PTR [r12+0x8],rax
     120:	lea    rdx,[rsp+0x30]
     125:	mov    rcx,rbx
     128:	mov    QWORD PTR [rsp+0x30],rcx
     12d:	mov    QWORD PTR [rsp+0x38],rax
     132:	mov    esi,0x2
     137:	mov    rdi,r13
     13a:	call   13f <botlish_fn_0+0x13f>
			13b: R_X86_64_PLT32	rt_list_new-0x4
     13f:	test   rax,rax
     142:	jne    150 <botlish_fn_0+0x150>
     148:	mov    rdi,r13
     14b:	jmp    298 <botlish_fn_0+0x298>
     150:	mov    QWORD PTR [r12],rax
     154:	mov    r14,rax
     157:	mov    QWORD PTR [r12+0x8],0xf
     160:	mov    QWORD PTR [r12+0x10],0x11
     169:	lea    rdx,[rsp+0x40]
     16e:	mov    QWORD PTR [rsp+0x40],0xf
     177:	mov    QWORD PTR [rsp+0x48],0x11
     180:	mov    esi,0x2
     185:	mov    rdi,r13
     188:	call   18d <botlish_fn_0+0x18d>
			189: R_X86_64_PLT32	rt_list_new-0x4
     18d:	mov    rbx,rax
     190:	test   rbx,rbx
     193:	jne    1a1 <botlish_fn_0+0x1a1>
     199:	mov    rdi,r13
     19c:	jmp    298 <botlish_fn_0+0x298>
     1a1:	mov    QWORD PTR [r12+0x8],rbx
     1a6:	mov    QWORD PTR [r12+0x10],0x13
     1af:	mov    QWORD PTR [r12+0x18],0x15
     1b8:	lea    rdx,[rsp+0x50]
     1bd:	mov    QWORD PTR [rsp+0x50],0x13
     1c6:	mov    QWORD PTR [rsp+0x58],0x15
     1cf:	mov    esi,0x2
     1d4:	mov    rdi,r13
     1d7:	call   1dc <botlish_fn_0+0x1dc>
			1d8: R_X86_64_PLT32	rt_list_new-0x4
     1dc:	test   rax,rax
     1df:	jne    1ed <botlish_fn_0+0x1ed>
     1e5:	mov    rdi,r13
     1e8:	jmp    298 <botlish_fn_0+0x298>
     1ed:	mov    QWORD PTR [r12+0x10],rax
     1f2:	mov    r15,rax
     1f5:	mov    QWORD PTR [r12+0x18],0x17
     1fe:	mov    QWORD PTR [r12+0x20],0x19
     207:	lea    rdx,[rsp+0x60]
     20c:	mov    QWORD PTR [rsp+0x60],0x17
     215:	mov    QWORD PTR [rsp+0x68],0x19
     21e:	mov    esi,0x2
     223:	mov    rdi,r13
     226:	call   22b <botlish_fn_0+0x22b>
			227: R_X86_64_PLT32	rt_list_new-0x4
     22b:	test   rax,rax
     22e:	jne    23c <botlish_fn_0+0x23c>
     234:	mov    rdi,r13
     237:	jmp    298 <botlish_fn_0+0x298>
     23c:	mov    QWORD PTR [r12+0x18],rax
     241:	lea    rdx,[rsp+0x70]
     246:	mov    QWORD PTR [rsp+0x70],rbx
     24b:	mov    rcx,r15
     24e:	mov    QWORD PTR [rsp+0x78],rcx
     253:	mov    QWORD PTR [rsp+0x80],rax
     25b:	mov    esi,0x3
     260:	mov    rdi,r13
     263:	call   268 <botlish_fn_0+0x268>
			264: R_X86_64_PLT32	rt_list_new-0x4
     268:	test   rax,rax
     26b:	jne    279 <botlish_fn_0+0x279>
     271:	mov    rdi,r13
     274:	jmp    298 <botlish_fn_0+0x298>
     279:	mov    QWORD PTR [r12+0x8],rax
     27e:	mov    rdx,rax
     281:	mov    rsi,r14
     284:	mov    rdi,r13
     287:	call   28c <botlish_fn_0+0x28c>
			288: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<list<list<int>>, list<list<int>>>
     28c:	test   rax,rax
     28f:	jne    2d5 <botlish_fn_0+0x2d5>
     295:	mov    rdi,r13
     298:	mov    rdi,r13
     29b:	mov    QWORD PTR [rdi],r12
     29e:	xor    rax,rax
     2a1:	mov    rbx,QWORD PTR [rsp+0x90]
     2a9:	mov    r12,QWORD PTR [rsp+0x98]
     2b1:	mov    r13,QWORD PTR [rsp+0xa0]
     2b9:	mov    r14,QWORD PTR [rsp+0xa8]
     2c1:	mov    r15,QWORD PTR [rsp+0xb0]
     2c9:	add    rsp,0xc0
     2d0:	mov    rsp,rbp
     2d3:	pop    rbp
     2d4:	ret
     2d5:	mov    rdi,r13
     2d8:	mov    QWORD PTR [rdi],r12
     2db:	mov    rbx,QWORD PTR [rsp+0x90]
     2e3:	mov    r12,QWORD PTR [rsp+0x98]
     2eb:	mov    r13,QWORD PTR [rsp+0xa0]
     2f3:	mov    r14,QWORD PTR [rsp+0xa8]
     2fb:	mov    r15,QWORD PTR [rsp+0xb0]
     303:	add    rsp,0xc0
     30a:	mov    rsp,rbp
     30d:	pop    rbp
     30e:	ret
     30f:	mov    r13,rdi
     312:	call   317 <botlish_fn_0+0x317>
			313: R_X86_64_PLT32	rt_stack_overflow-0x4
     317:	xor    rax,rax
     31a:	mov    rbx,QWORD PTR [rsp+0x90]
     322:	mov    r12,QWORD PTR [rsp+0x98]
     32a:	mov    r13,QWORD PTR [rsp+0xa0]
     332:	mov    r14,QWORD PTR [rsp+0xa8]
     33a:	mov    r15,QWORD PTR [rsp+0xb0]
     342:	add    rsp,0xc0
     349:	mov    rsp,rbp
     34c:	pop    rbp
     34d:	ret

000000000000034e <botlish_entry_0: <program entry>>:
     34e:	push   rbp
     34f:	mov    rbp,rsp
     352:	call   357 <botlish_entry_0+0x9>
			353: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     357:	mov    rsp,rbp
     35a:	pop    rbp
     35b:	ret

000000000000035c <botlish_fn_1: dot<list<int>, list<list<int>>, int, int, int, int>>:
     35c:	push   rbp
     35d:	mov    rbp,rsp
     360:	sub    rsp,0x60
     364:	mov    QWORD PTR [rsp+0x30],rbx
     369:	mov    QWORD PTR [rsp+0x38],r12
     36e:	mov    QWORD PTR [rsp+0x40],r13
     373:	mov    QWORD PTR [rsp+0x48],r14
     378:	mov    QWORD PTR [rsp+0x50],r15
     37d:	mov    r10,QWORD PTR [rbp+0x10]
     381:	mov    r12,QWORD PTR [rdi]
     384:	mov    r11,QWORD PTR [rdi+0x8]
     388:	lea    rax,[r12+0x30]
     38d:	cmp    rax,r11
     390:	ja     607 <botlish_fn_1+0x2ab>
     396:	lea    r11,[r12+0x30]
     39b:	mov    QWORD PTR [rdi],r11
     39e:	mov    QWORD PTR [rsp],rdi
     3a2:	mov    QWORD PTR [r12],rsi
     3a6:	mov    r11,rsi
     3a9:	mov    QWORD PTR [r12+0x8],rdx
     3ae:	mov    r15,rdx
     3b1:	mov    QWORD PTR [r12+0x10],rcx
     3b6:	mov    QWORD PTR [r12+0x18],r10
     3bb:	sar    r8,1
     3be:	mov    rsi,r8
     3c1:	sar    r9,1
     3c4:	mov    QWORD PTR [rsp+0x20],r9
     3c9:	mov    r8,rcx
     3cc:	sar    r8,1
     3cf:	mov    r13,rcx
     3d2:	mov    QWORD PTR [rsp+0x18],r8
     3d7:	mov    rcx,QWORD PTR [rsp+0x20]
     3dc:	mov    rbx,rsi
     3df:	mov    QWORD PTR [rsp+0x8],r10
     3e4:	cmp    rbx,rcx
     3e7:	mov    QWORD PTR [rsp+0x20],rcx
     3ec:	je     5d9 <botlish_fn_1+0x27d>
     3f2:	mov    r14,r11
     3f5:	mov    rax,QWORD PTR [r14+0x8]
     3f9:	mov    r11,rbx
     3fc:	shl    r11,1
     3ff:	or     r11,0x1
     403:	sar    r11,1
     406:	cmp    r11,rax
     409:	jb     43f <botlish_fn_1+0xe3>
     40f:	mov    rdx,rbx
     412:	shl    rdx,1
     415:	or     rdx,0x1
     419:	mov    rsi,r14
     41c:	mov    rdi,QWORD PTR [rsp]
     420:	call   425 <botlish_fn_1+0xc9>
			421: R_X86_64_PLT32	rt_list_get-0x4
     425:	test   rax,rax
     428:	jne    437 <botlish_fn_1+0xdb>
     42e:	mov    rdi,QWORD PTR [rsp]
     432:	jmp    4db <botlish_fn_1+0x17f>
     437:	mov    rsi,rax
     43a:	jmp    447 <botlish_fn_1+0xeb>
     43f:	mov    rax,QWORD PTR [r14+0x10]
     443:	mov    rsi,QWORD PTR [rax+r11*8]
     447:	mov    QWORD PTR [r12+0x20],rsi
     44c:	mov    QWORD PTR [rsp+0x10],rsi
     451:	mov    rcx,QWORD PTR [r15+0x8]
     455:	mov    rax,rbx
     458:	shl    rax,1
     45b:	or     rax,0x1
     45f:	sar    rax,1
     462:	cmp    rax,rcx
     465:	jb     49b <botlish_fn_1+0x13f>
     46b:	mov    rdx,rbx
     46e:	shl    rdx,1
     471:	or     rdx,0x1
     475:	mov    rsi,r15
     478:	mov    rdi,QWORD PTR [rsp]
     47c:	call   481 <botlish_fn_1+0x125>
			47d: R_X86_64_PLT32	rt_list_get-0x4
     481:	test   rax,rax
     484:	jne    493 <botlish_fn_1+0x137>
     48a:	mov    rdi,QWORD PTR [rsp]
     48e:	jmp    4db <botlish_fn_1+0x17f>
     493:	mov    rsi,rax
     496:	jmp    4a3 <botlish_fn_1+0x147>
     49b:	mov    rcx,QWORD PTR [r15+0x10]
     49f:	mov    rsi,QWORD PTR [rcx+rax*8]
     4a3:	test   r13,0x1
     4aa:	je     4c2 <botlish_fn_1+0x166>
     4b0:	mov    rax,QWORD PTR [rsi+0x8]
     4b4:	mov    rcx,QWORD PTR [rsp+0x18]
     4b9:	cmp    rcx,rax
     4bc:	jb     50f <botlish_fn_1+0x1b3>
     4c2:	mov    rdx,r13
     4c5:	mov    rdi,QWORD PTR [rsp]
     4c9:	call   4ce <botlish_fn_1+0x172>
			4ca: R_X86_64_PLT32	rt_list_get-0x4
     4ce:	test   rax,rax
     4d1:	jne    507 <botlish_fn_1+0x1ab>
     4d7:	mov    rdi,QWORD PTR [rsp]
     4db:	mov    rdi,QWORD PTR [rsp]
     4df:	mov    QWORD PTR [rdi],r12
     4e2:	xor    rax,rax
     4e5:	mov    rbx,QWORD PTR [rsp+0x30]
     4ea:	mov    r12,QWORD PTR [rsp+0x38]
     4ef:	mov    r13,QWORD PTR [rsp+0x40]
     4f4:	mov    r14,QWORD PTR [rsp+0x48]
     4f9:	mov    r15,QWORD PTR [rsp+0x50]
     4fe:	add    rsp,0x60
     502:	mov    rsp,rbp
     505:	pop    rbp
     506:	ret
     507:	mov    rdx,rax
     50a:	jmp    51c <botlish_fn_1+0x1c0>
     50f:	mov    rax,QWORD PTR [rsi+0x10]
     513:	mov    rcx,QWORD PTR [rsp+0x18]
     518:	mov    rdx,QWORD PTR [rax+rcx*8]
     51c:	mov    QWORD PTR [r12+0x28],rdx
     521:	mov    rsi,QWORD PTR [rsp+0x10]
     526:	mov    rax,rsi
     529:	and    rax,rdx
     52c:	test   rax,0x1
     532:	je     567 <botlish_fn_1+0x20b>
     538:	mov    rax,rsi
     53b:	sar    rax,1
     53e:	lea    rcx,[rdx-0x1]
     542:	mov    rdi,rdx
     545:	imul   rcx
     548:	seto   cl
     54b:	or     rax,0x1
     54f:	test   cl,cl
     551:	je     55f <botlish_fn_1+0x203>
     557:	mov    rdx,rdi
     55a:	jmp    567 <botlish_fn_1+0x20b>
     55f:	mov    rdx,rax
     562:	jmp    573 <botlish_fn_1+0x217>
     567:	mov    rdi,QWORD PTR [rsp]
     56b:	call   570 <botlish_fn_1+0x214>
			56c: R_X86_64_PLT32	rt_int_mul-0x4
     570:	mov    rdx,rax
     573:	mov    QWORD PTR [r12+0x20],rdx
     578:	mov    rsi,QWORD PTR [rsp+0x8]
     57d:	mov    rax,rsi
     580:	and    rax,rdx
     583:	test   rax,0x1
     589:	je     5a4 <botlish_fn_1+0x248>
     58f:	lea    rcx,[rdx-0x1]
     593:	mov    rax,rsi
     596:	add    rax,rcx
     599:	seto   cl
     59c:	test   cl,cl
     59e:	je     5ad <botlish_fn_1+0x251>
     5a4:	mov    rdi,QWORD PTR [rsp]
     5a8:	call   5ad <botlish_fn_1+0x251>
			5a9: R_X86_64_PLT32	rt_int_add-0x4
     5ad:	mov    QWORD PTR [r12],r14
     5b1:	mov    QWORD PTR [r12+0x8],r15
     5b6:	mov    QWORD PTR [r12+0x10],r13
     5bb:	mov    QWORD PTR [r12+0x18],rax
     5c0:	add    rbx,0x1
     5c7:	mov    rcx,QWORD PTR [rsp+0x20]
     5cc:	mov    r11,r14
     5cf:	mov    QWORD PTR [rsp+0x8],rax
     5d4:	jmp    3e4 <botlish_fn_1+0x88>
     5d9:	mov    rdi,QWORD PTR [rsp]
     5dd:	mov    QWORD PTR [rdi],r12
     5e0:	mov    rax,QWORD PTR [rsp+0x8]
     5e5:	mov    rbx,QWORD PTR [rsp+0x30]
     5ea:	mov    r12,QWORD PTR [rsp+0x38]
     5ef:	mov    r13,QWORD PTR [rsp+0x40]
     5f4:	mov    r14,QWORD PTR [rsp+0x48]
     5f9:	mov    r15,QWORD PTR [rsp+0x50]
     5fe:	add    rsp,0x60
     602:	mov    rsp,rbp
     605:	pop    rbp
     606:	ret
     607:	mov    QWORD PTR [rsp],rdi
     60b:	call   610 <botlish_fn_1+0x2b4>
			60c: R_X86_64_PLT32	rt_stack_overflow-0x4
     610:	xor    rax,rax
     613:	mov    rbx,QWORD PTR [rsp+0x30]
     618:	mov    r12,QWORD PTR [rsp+0x38]
     61d:	mov    r13,QWORD PTR [rsp+0x40]
     622:	mov    r14,QWORD PTR [rsp+0x48]
     627:	mov    r15,QWORD PTR [rsp+0x50]
     62c:	add    rsp,0x60
     630:	mov    rsp,rbp
     633:	pop    rbp
     634:	ret

0000000000000635 <botlish_entry_1: dot<list<int>, list<list<int>>, int, int, int, int>>:
     635:	push   rbp
     636:	mov    rbp,rsp
     639:	sub    rsp,0x10
     63d:	mov    rsi,QWORD PTR [rdx]
     640:	mov    r10,QWORD PTR [rdx+0x8]
     644:	mov    rcx,QWORD PTR [rdx+0x10]
     648:	mov    r8,QWORD PTR [rdx+0x18]
     64c:	mov    r9,QWORD PTR [rdx+0x20]
     650:	mov    r11,QWORD PTR [rdx+0x28]
     654:	mov    QWORD PTR [rsp],r11
     658:	mov    rdx,r10
     65b:	call   660 <botlish_entry_1+0x2b>
			65c: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     660:	add    rsp,0x10
     664:	mov    rsp,rbp
     667:	pop    rbp
     668:	ret

0000000000000669 <botlish_fn_2: product_row<list<int>, list<list<int>>, int, int, list<never>>>:
     669:	push   rbp
     66a:	mov    rbp,rsp
     66d:	sub    rsp,0x60
     671:	mov    QWORD PTR [rsp+0x30],rbx
     676:	mov    QWORD PTR [rsp+0x38],r12
     67b:	mov    QWORD PTR [rsp+0x40],r13
     680:	mov    QWORD PTR [rsp+0x48],r14
     685:	mov    QWORD PTR [rsp+0x50],r15
     68a:	mov    r13,QWORD PTR [rdi]
     68d:	mov    rax,QWORD PTR [rdi+0x8]
     691:	lea    r10,[r13+0x40]
     695:	cmp    r10,rax
     698:	ja     823 <botlish_fn_2+0x1ba>
     69e:	lea    rax,[r13+0x40]
     6a2:	mov    QWORD PTR [rdi],rax
     6a5:	mov    r14,rdi
     6a8:	mov    QWORD PTR [r13+0x0],rsi
     6ac:	mov    QWORD PTR [rsp+0x10],rsi
     6b1:	mov    QWORD PTR [r13+0x8],rdx
     6b5:	mov    QWORD PTR [rsp+0x18],rdx
     6ba:	mov    QWORD PTR [r13+0x10],rcx
     6be:	mov    QWORD PTR [r13+0x18],r8
     6c2:	mov    QWORD PTR [r13+0x20],r9
     6c6:	mov    QWORD PTR [rsp+0x28],r9
     6cb:	mov    rbx,rcx
     6ce:	sar    rbx,1
     6d1:	mov    QWORD PTR [rsp+0x20],rcx
     6d6:	mov    rax,r8
     6d9:	sar    rax,1
     6dc:	mov    r15,r8
     6df:	cmp    rbx,rax
     6e2:	je     7f6 <botlish_fn_2+0x18d>
     6e8:	mov    r12d,0x1
     6ee:	mov    QWORD PTR [r13+0x28],0x1
     6f6:	mov    rsi,QWORD PTR [rsp+0x10]
     6fb:	mov    rdi,r14
     6fe:	call   703 <botlish_fn_2+0x9a>
			6ff: R_X86_64_PLT32	rt_list_len-0x4
     703:	mov    QWORD PTR [r13+0x30],rax
     707:	mov    QWORD PTR [r13+0x38],0x1
     70f:	mov    QWORD PTR [rsp],r12
     713:	mov    rcx,QWORD PTR [rsp+0x20]
     718:	mov    r8,r12
     71b:	mov    r9,rax
     71e:	mov    rdx,QWORD PTR [rsp+0x18]
     723:	mov    rsi,QWORD PTR [rsp+0x10]
     728:	mov    rdi,r14
     72b:	call   730 <botlish_fn_2+0xc7>
			72c: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     730:	test   rax,rax
     733:	jne    741 <botlish_fn_2+0xd8>
     739:	mov    rdi,r14
     73c:	jmp    7a3 <botlish_fn_2+0x13a>
     741:	mov    QWORD PTR [r13+0x10],rax
     745:	mov    rdx,rax
     748:	lea    rcx,[rbx+0x1]
     74c:	shl    rcx,1
     74f:	or     rcx,0x1
     753:	mov    QWORD PTR [r13+0x28],rcx
     757:	mov    rbx,rcx
     75a:	mov    rsi,QWORD PTR [rsp+0x28]
     75f:	mov    rdi,r14
     762:	call   767 <botlish_fn_2+0xfe>
			763: R_X86_64_PLT32	rt_list_append-0x4
     767:	test   rax,rax
     76a:	jne    778 <botlish_fn_2+0x10f>
     770:	mov    rdi,r14
     773:	jmp    7a3 <botlish_fn_2+0x13a>
     778:	mov    QWORD PTR [r13+0x10],rax
     77c:	mov    rcx,rbx
     77f:	mov    rdx,QWORD PTR [rsp+0x18]
     784:	mov    rsi,QWORD PTR [rsp+0x10]
     789:	mov    r8,r15
     78c:	mov    r9,rax
     78f:	mov    rdi,r14
     792:	call   797 <botlish_fn_2+0x12e>
			793: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<int>>
     797:	test   rax,rax
     79a:	jne    7ce <botlish_fn_2+0x165>
     7a0:	mov    rdi,r14
     7a3:	mov    rdi,r14
     7a6:	mov    QWORD PTR [rdi],r13
     7a9:	xor    rax,rax
     7ac:	mov    rbx,QWORD PTR [rsp+0x30]
     7b1:	mov    r12,QWORD PTR [rsp+0x38]
     7b6:	mov    r13,QWORD PTR [rsp+0x40]
     7bb:	mov    r14,QWORD PTR [rsp+0x48]
     7c0:	mov    r15,QWORD PTR [rsp+0x50]
     7c5:	add    rsp,0x60
     7c9:	mov    rsp,rbp
     7cc:	pop    rbp
     7cd:	ret
     7ce:	mov    rdi,r14
     7d1:	mov    QWORD PTR [rdi],r13
     7d4:	mov    rbx,QWORD PTR [rsp+0x30]
     7d9:	mov    r12,QWORD PTR [rsp+0x38]
     7de:	mov    r13,QWORD PTR [rsp+0x40]
     7e3:	mov    r14,QWORD PTR [rsp+0x48]
     7e8:	mov    r15,QWORD PTR [rsp+0x50]
     7ed:	add    rsp,0x60
     7f1:	mov    rsp,rbp
     7f4:	pop    rbp
     7f5:	ret
     7f6:	mov    rdi,r14
     7f9:	mov    QWORD PTR [rdi],r13
     7fc:	mov    rax,QWORD PTR [rsp+0x28]
     801:	mov    rbx,QWORD PTR [rsp+0x30]
     806:	mov    r12,QWORD PTR [rsp+0x38]
     80b:	mov    r13,QWORD PTR [rsp+0x40]
     810:	mov    r14,QWORD PTR [rsp+0x48]
     815:	mov    r15,QWORD PTR [rsp+0x50]
     81a:	add    rsp,0x60
     81e:	mov    rsp,rbp
     821:	pop    rbp
     822:	ret
     823:	mov    r14,rdi
     826:	call   82b <botlish_fn_2+0x1c2>
			827: R_X86_64_PLT32	rt_stack_overflow-0x4
     82b:	xor    rax,rax
     82e:	mov    rbx,QWORD PTR [rsp+0x30]
     833:	mov    r12,QWORD PTR [rsp+0x38]
     838:	mov    r13,QWORD PTR [rsp+0x40]
     83d:	mov    r14,QWORD PTR [rsp+0x48]
     842:	mov    r15,QWORD PTR [rsp+0x50]
     847:	add    rsp,0x60
     84b:	mov    rsp,rbp
     84e:	pop    rbp
     84f:	ret

0000000000000850 <botlish_entry_2: product_row<list<int>, list<list<int>>, int, int, list<never>>>:
     850:	push   rbp
     851:	mov    rbp,rsp
     854:	mov    rsi,QWORD PTR [rdx]
     857:	mov    r10,QWORD PTR [rdx+0x8]
     85b:	mov    rcx,QWORD PTR [rdx+0x10]
     85f:	mov    r8,QWORD PTR [rdx+0x18]
     863:	mov    r9,QWORD PTR [rdx+0x20]
     867:	mov    rdx,r10
     86a:	call   86f <botlish_entry_2+0x1f>
			86b: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
     86f:	mov    rsp,rbp
     872:	pop    rbp
     873:	ret
     874:	add    BYTE PTR [rax],al
	...

0000000000000878 <botlish_fn_3: product_row<list<int>, list<list<int>>, int, int, list<int>>>:
     878:	push   rbp
     879:	mov    rbp,rsp
     87c:	sub    rsp,0x60
     880:	mov    QWORD PTR [rsp+0x30],rbx
     885:	mov    QWORD PTR [rsp+0x38],r12
     88a:	mov    QWORD PTR [rsp+0x40],r13
     88f:	mov    QWORD PTR [rsp+0x48],r14
     894:	mov    QWORD PTR [rsp+0x50],r15
     899:	mov    r10,r8
     89c:	mov    r13,QWORD PTR [rdi]
     89f:	mov    rax,QWORD PTR [rdi+0x8]
     8a3:	lea    r8,[r13+0x38]
     8a7:	cmp    r8,rax
     8aa:	ja     aa4 <botlish_fn_3+0x22c>
     8b0:	lea    rax,[r13+0x38]
     8b4:	mov    QWORD PTR [rdi],rax
     8b7:	mov    r15,rdi
     8ba:	mov    QWORD PTR [r13+0x0],rsi
     8be:	mov    r12,rsi
     8c1:	mov    QWORD PTR [r13+0x8],rdx
     8c5:	mov    QWORD PTR [rsp+0x10],rdx
     8ca:	mov    QWORD PTR [r13+0x10],rcx
     8ce:	mov    QWORD PTR [r13+0x18],r9
     8d2:	mov    rbx,r10
     8d5:	mov    rsi,rcx
     8d8:	mov    QWORD PTR [rsp+0x20],r9
     8dd:	mov    rax,rbx
     8e0:	or     rax,0x1
     8e4:	mov    rcx,rsi
     8e7:	and    rcx,rax
     8ea:	mov    QWORD PTR [rsp+0x18],rsi
     8ef:	test   rcx,0x1
     8f6:	jne    925 <botlish_fn_3+0xad>
     8fc:	mov    rdx,rbx
     8ff:	or     rdx,0x1
     903:	mov    rsi,QWORD PTR [rsp+0x18]
     908:	mov    rdi,r15
     90b:	call   910 <botlish_fn_3+0x98>
			90c: R_X86_64_PLT32	rt_int_cmp-0x4
     910:	mov    ecx,0x2
     915:	test   rax,rax
     918:	cmove  rcx,QWORD PTR [rip+0x1b8]        # ad8 <botlish_fn_3+0x260>
     920:	jmp    941 <botlish_fn_3+0xc9>
     925:	mov    rax,rbx
     928:	or     rax,0x1
     92c:	mov    ecx,0x2
     931:	mov    rsi,QWORD PTR [rsp+0x18]
     936:	cmp    rsi,rax
     939:	cmove  rcx,QWORD PTR [rip+0x197]        # ad8 <botlish_fn_3+0x260>
     941:	cmp    rcx,0x6
     945:	je     a77 <botlish_fn_3+0x1ff>
     94b:	mov    r14d,0x1
     951:	mov    QWORD PTR [r13+0x20],0x1
     959:	mov    rsi,r12
     95c:	mov    rdi,r15
     95f:	call   964 <botlish_fn_3+0xec>
			960: R_X86_64_PLT32	rt_list_len-0x4
     964:	mov    QWORD PTR [r13+0x28],rax
     968:	mov    QWORD PTR [r13+0x30],0x1
     970:	mov    QWORD PTR [rsp],r14
     974:	mov    r9,rax
     977:	mov    r8,r14
     97a:	mov    r14,QWORD PTR [rsp+0x10]
     97f:	mov    rcx,QWORD PTR [rsp+0x18]
     984:	mov    rdx,r14
     987:	mov    rsi,r12
     98a:	mov    rdi,r15
     98d:	call   992 <botlish_fn_3+0x11a>
			98e: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<list<int>, list<list<int>>, int, int, int, int>
     992:	test   rax,rax
     995:	jne    9a3 <botlish_fn_3+0x12b>
     99b:	mov    rdi,r15
     99e:	jmp    a28 <botlish_fn_3+0x1b0>
     9a3:	mov    QWORD PTR [r13+0x20],rax
     9a7:	mov    QWORD PTR [rsp+0x28],rax
     9ac:	mov    QWORD PTR [r13+0x28],0x3
     9b4:	mov    rsi,QWORD PTR [rsp+0x18]
     9b9:	test   rsi,0x1
     9c0:	je     9ec <botlish_fn_3+0x174>
     9c6:	mov    rsi,QWORD PTR [rsp+0x18]
     9cb:	mov    rcx,rsi
     9ce:	add    rcx,0x2
     9d2:	seto   sil
     9d6:	test   sil,sil
     9d9:	jne    9ec <botlish_fn_3+0x174>
     9df:	mov    rsi,rcx
     9e2:	mov    QWORD PTR [rsp+0x18],rcx
     9e7:	jmp    a06 <botlish_fn_3+0x18e>
     9ec:	mov    edx,0x3
     9f1:	mov    rsi,QWORD PTR [rsp+0x18]
     9f6:	mov    rdi,r15
     9f9:	call   9fe <botlish_fn_3+0x186>
			9fa: R_X86_64_PLT32	rt_int_add-0x4
     9fe:	mov    rsi,rax
     a01:	mov    QWORD PTR [rsp+0x18],rax
     a06:	mov    QWORD PTR [r13+0x10],rsi
     a0a:	mov    rdx,QWORD PTR [rsp+0x28]
     a0f:	mov    rsi,QWORD PTR [rsp+0x20]
     a14:	mov    rdi,r15
     a17:	call   a1c <botlish_fn_3+0x1a4>
			a18: R_X86_64_PLT32	rt_list_append-0x4
     a1c:	test   rax,rax
     a1f:	jne    a53 <botlish_fn_3+0x1db>
     a25:	mov    rdi,r15
     a28:	mov    rdi,r15
     a2b:	mov    QWORD PTR [rdi],r13
     a2e:	xor    rax,rax
     a31:	mov    rbx,QWORD PTR [rsp+0x30]
     a36:	mov    r12,QWORD PTR [rsp+0x38]
     a3b:	mov    r13,QWORD PTR [rsp+0x40]
     a40:	mov    r14,QWORD PTR [rsp+0x48]
     a45:	mov    r15,QWORD PTR [rsp+0x50]
     a4a:	add    rsp,0x60
     a4e:	mov    rsp,rbp
     a51:	pop    rbp
     a52:	ret
     a53:	mov    QWORD PTR [r13+0x0],r12
     a57:	mov    QWORD PTR [r13+0x8],r14
     a5b:	mov    rsi,QWORD PTR [rsp+0x18]
     a60:	mov    QWORD PTR [r13+0x10],rsi
     a64:	mov    QWORD PTR [r13+0x18],rax
     a68:	mov    QWORD PTR [rsp+0x10],r14
     a6d:	mov    QWORD PTR [rsp+0x20],rax
     a72:	jmp    8dd <botlish_fn_3+0x65>
     a77:	mov    rdi,r15
     a7a:	mov    QWORD PTR [rdi],r13
     a7d:	mov    rax,QWORD PTR [rsp+0x20]
     a82:	mov    rbx,QWORD PTR [rsp+0x30]
     a87:	mov    r12,QWORD PTR [rsp+0x38]
     a8c:	mov    r13,QWORD PTR [rsp+0x40]
     a91:	mov    r14,QWORD PTR [rsp+0x48]
     a96:	mov    r15,QWORD PTR [rsp+0x50]
     a9b:	add    rsp,0x60
     a9f:	mov    rsp,rbp
     aa2:	pop    rbp
     aa3:	ret
     aa4:	mov    r15,rdi
     aa7:	call   aac <botlish_fn_3+0x234>
			aa8: R_X86_64_PLT32	rt_stack_overflow-0x4
     aac:	xor    rax,rax
     aaf:	mov    rbx,QWORD PTR [rsp+0x30]
     ab4:	mov    r12,QWORD PTR [rsp+0x38]
     ab9:	mov    r13,QWORD PTR [rsp+0x40]
     abe:	mov    r14,QWORD PTR [rsp+0x48]
     ac3:	mov    r15,QWORD PTR [rsp+0x50]
     ac8:	add    rsp,0x60
     acc:	mov    rsp,rbp
     acf:	pop    rbp
     ad0:	ret
     ad1:	add    BYTE PTR [rax],al
     ad3:	add    BYTE PTR [rax],al
     ad5:	add    BYTE PTR [rax],al
     ad7:	add    BYTE PTR [rsi],al
     ad9:	add    BYTE PTR [rax],al
     adb:	add    BYTE PTR [rax],al
     add:	add    BYTE PTR [rax],al
	...

0000000000000ae0 <botlish_entry_3: product_row<list<int>, list<list<int>>, int, int, list<int>>>:
     ae0:	push   rbp
     ae1:	mov    rbp,rsp
     ae4:	mov    rsi,QWORD PTR [rdx]
     ae7:	mov    r10,QWORD PTR [rdx+0x8]
     aeb:	mov    rcx,QWORD PTR [rdx+0x10]
     aef:	mov    r8,QWORD PTR [rdx+0x18]
     af3:	mov    r9,QWORD PTR [rdx+0x20]
     af7:	mov    rdx,r10
     afa:	call   aff <botlish_entry_3+0x1f>
			afb: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<int>>
     aff:	mov    rsp,rbp
     b02:	pop    rbp
     b03:	ret

0000000000000b04 <botlish_fn_4: product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>>:
     b04:	push   rbp
     b05:	mov    rbp,rsp
     b08:	sub    rsp,0x50
     b0c:	mov    QWORD PTR [rsp+0x20],rbx
     b11:	mov    QWORD PTR [rsp+0x28],r12
     b16:	mov    QWORD PTR [rsp+0x30],r13
     b1b:	mov    QWORD PTR [rsp+0x38],r14
     b20:	mov    QWORD PTR [rsp+0x40],r15
     b25:	mov    rbx,rcx
     b28:	mov    r12,QWORD PTR [rdi]
     b2b:	mov    rax,QWORD PTR [rdi+0x8]
     b2f:	lea    rcx,[r12+0x38]
     b34:	cmp    rcx,rax
     b37:	ja     d30 <botlish_fn_4+0x22c>
     b3d:	lea    rax,[r12+0x38]
     b42:	mov    QWORD PTR [rdi],rax
     b45:	mov    r13,rdi
     b48:	mov    QWORD PTR [r12+0x30],0x0
     b51:	mov    QWORD PTR [r12],rsi
     b55:	mov    QWORD PTR [rsp],rsi
     b59:	mov    QWORD PTR [r12+0x8],rdx
     b5e:	mov    r15,rdx
     b61:	mov    QWORD PTR [r12+0x10],r8
     b66:	mov    r14,r8
     b69:	mov    QWORD PTR [r12+0x18],r9
     b6e:	mov    QWORD PTR [rsp+0x8],r9
     b73:	mov    rsi,QWORD PTR [rsp]
     b77:	mov    rdi,r13
     b7a:	call   b7f <botlish_fn_4+0x7b>
			b7b: R_X86_64_PLT32	rt_list_len-0x4
     b7f:	mov    rcx,rbx
     b82:	sar    rbx,1
     b85:	sar    rax,1
     b88:	cmp    rbx,rax
     b8b:	je     d03 <botlish_fn_4+0x1ff>
     b91:	test   rcx,0x1
     b98:	jne    ba6 <botlish_fn_4+0xa2>
     b9e:	mov    rdx,rcx
     ba1:	jmp    bba <botlish_fn_4+0xb6>
     ba6:	mov    rsi,QWORD PTR [rsp]
     baa:	mov    rax,QWORD PTR [rsi+0x8]
     bae:	cmp    rbx,rax
     bb1:	jb     bdf <botlish_fn_4+0xdb>
     bb7:	mov    rdx,rcx
     bba:	mov    rsi,QWORD PTR [rsp]
     bbe:	mov    rdi,r13
     bc1:	call   bc6 <botlish_fn_4+0xc2>
			bc2: R_X86_64_PLT32	rt_list_get-0x4
     bc6:	test   rax,rax
     bc9:	jne    bd7 <botlish_fn_4+0xd3>
     bcf:	mov    rdi,r13
     bd2:	jmp    cb0 <botlish_fn_4+0x1ac>
     bd7:	mov    rsi,rax
     bda:	jmp    beb <botlish_fn_4+0xe7>
     bdf:	mov    rsi,QWORD PTR [rsp]
     be3:	mov    rax,QWORD PTR [rsi+0x10]
     be7:	mov    rsi,QWORD PTR [rax+rbx*8]
     beb:	mov    QWORD PTR [r12+0x20],rsi
     bf0:	mov    QWORD PTR [rsp+0x10],rsi
     bf5:	mov    QWORD PTR [r12+0x28],0x1
     bfe:	xor    rdx,rdx
     c01:	mov    rdi,r13
     c04:	mov    rsi,rdx
     c07:	call   c0c <botlish_fn_4+0x108>
			c08: R_X86_64_PLT32	rt_list_new-0x4
     c0c:	test   rax,rax
     c0f:	jne    c1d <botlish_fn_4+0x119>
     c15:	mov    rdi,r13
     c18:	jmp    cb0 <botlish_fn_4+0x1ac>
     c1d:	mov    QWORD PTR [r12+0x30],rax
     c22:	mov    r9,rax
     c25:	mov    ecx,0x1
     c2a:	mov    rsi,QWORD PTR [rsp+0x10]
     c2f:	mov    rdx,r15
     c32:	mov    rdi,r13
     c35:	mov    r8,r14
     c38:	call   c3d <botlish_fn_4+0x139>
			c39: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
     c3d:	test   rax,rax
     c40:	jne    c4e <botlish_fn_4+0x14a>
     c46:	mov    rdi,r13
     c49:	jmp    cb0 <botlish_fn_4+0x1ac>
     c4e:	mov    QWORD PTR [r12+0x20],rax
     c53:	mov    rdx,rax
     c56:	lea    rcx,[rbx+0x1]
     c5a:	shl    rcx,1
     c5d:	or     rcx,0x1
     c61:	mov    QWORD PTR [r12+0x28],rcx
     c66:	mov    rbx,rcx
     c69:	mov    rsi,QWORD PTR [rsp+0x8]
     c6e:	mov    rdi,r13
     c71:	call   c76 <botlish_fn_4+0x172>
			c72: R_X86_64_PLT32	rt_list_append-0x4
     c76:	test   rax,rax
     c79:	jne    c87 <botlish_fn_4+0x183>
     c7f:	mov    rdi,r13
     c82:	jmp    cb0 <botlish_fn_4+0x1ac>
     c87:	mov    QWORD PTR [r12+0x18],rax
     c8c:	mov    rcx,rbx
     c8f:	mov    rdx,r15
     c92:	mov    rsi,QWORD PTR [rsp]
     c96:	mov    r8,r14
     c99:	mov    r9,rax
     c9c:	mov    rdi,r13
     c9f:	call   ca4 <botlish_fn_4+0x1a0>
			ca0: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>
     ca4:	test   rax,rax
     ca7:	jne    cdb <botlish_fn_4+0x1d7>
     cad:	mov    rdi,r13
     cb0:	mov    rdi,r13
     cb3:	mov    QWORD PTR [rdi],r12
     cb6:	xor    rax,rax
     cb9:	mov    rbx,QWORD PTR [rsp+0x20]
     cbe:	mov    r12,QWORD PTR [rsp+0x28]
     cc3:	mov    r13,QWORD PTR [rsp+0x30]
     cc8:	mov    r14,QWORD PTR [rsp+0x38]
     ccd:	mov    r15,QWORD PTR [rsp+0x40]
     cd2:	add    rsp,0x50
     cd6:	mov    rsp,rbp
     cd9:	pop    rbp
     cda:	ret
     cdb:	mov    rdi,r13
     cde:	mov    QWORD PTR [rdi],r12
     ce1:	mov    rbx,QWORD PTR [rsp+0x20]
     ce6:	mov    r12,QWORD PTR [rsp+0x28]
     ceb:	mov    r13,QWORD PTR [rsp+0x30]
     cf0:	mov    r14,QWORD PTR [rsp+0x38]
     cf5:	mov    r15,QWORD PTR [rsp+0x40]
     cfa:	add    rsp,0x50
     cfe:	mov    rsp,rbp
     d01:	pop    rbp
     d02:	ret
     d03:	mov    rdi,r13
     d06:	mov    QWORD PTR [rdi],r12
     d09:	mov    rax,QWORD PTR [rsp+0x8]
     d0e:	mov    rbx,QWORD PTR [rsp+0x20]
     d13:	mov    r12,QWORD PTR [rsp+0x28]
     d18:	mov    r13,QWORD PTR [rsp+0x30]
     d1d:	mov    r14,QWORD PTR [rsp+0x38]
     d22:	mov    r15,QWORD PTR [rsp+0x40]
     d27:	add    rsp,0x50
     d2b:	mov    rsp,rbp
     d2e:	pop    rbp
     d2f:	ret
     d30:	mov    r13,rdi
     d33:	call   d38 <botlish_fn_4+0x234>
			d34: R_X86_64_PLT32	rt_stack_overflow-0x4
     d38:	xor    rax,rax
     d3b:	mov    rbx,QWORD PTR [rsp+0x20]
     d40:	mov    r12,QWORD PTR [rsp+0x28]
     d45:	mov    r13,QWORD PTR [rsp+0x30]
     d4a:	mov    r14,QWORD PTR [rsp+0x38]
     d4f:	mov    r15,QWORD PTR [rsp+0x40]
     d54:	add    rsp,0x50
     d58:	mov    rsp,rbp
     d5b:	pop    rbp
     d5c:	ret

0000000000000d5d <botlish_entry_4: product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>>:
     d5d:	push   rbp
     d5e:	mov    rbp,rsp
     d61:	mov    rsi,QWORD PTR [rdx]
     d64:	mov    r10,QWORD PTR [rdx+0x8]
     d68:	mov    rcx,QWORD PTR [rdx+0x10]
     d6c:	mov    r8,QWORD PTR [rdx+0x18]
     d70:	mov    r9,QWORD PTR [rdx+0x20]
     d74:	mov    rdx,r10
     d77:	call   d7c <botlish_entry_4+0x1f>
			d78: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>
     d7c:	mov    rsp,rbp
     d7f:	pop    rbp
     d80:	ret
     d81:	add    BYTE PTR [rax],al
     d83:	add    BYTE PTR [rax],al
     d85:	add    BYTE PTR [rax],al
	...

0000000000000d88 <botlish_fn_5: product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>>:
     d88:	push   rbp
     d89:	mov    rbp,rsp
     d8c:	sub    rsp,0x50
     d90:	mov    QWORD PTR [rsp+0x20],rbx
     d95:	mov    QWORD PTR [rsp+0x28],r12
     d9a:	mov    QWORD PTR [rsp+0x30],r13
     d9f:	mov    QWORD PTR [rsp+0x38],r14
     da4:	mov    QWORD PTR [rsp+0x40],r15
     da9:	mov    r12,r8
     dac:	mov    r14,QWORD PTR [rdi]
     daf:	mov    rax,QWORD PTR [rdi+0x8]
     db3:	lea    r8,[r14+0x40]
     db7:	cmp    r8,rax
     dba:	ja     100e <botlish_fn_5+0x286>
     dc0:	lea    rax,[r14+0x40]
     dc4:	mov    QWORD PTR [rdi],rax
     dc7:	mov    r15,rdi
     dca:	mov    QWORD PTR [r14+0x38],0x0
     dd2:	mov    QWORD PTR [r14],rsi
     dd5:	mov    QWORD PTR [r14+0x8],rdx
     dd9:	mov    r13,rdx
     ddc:	mov    QWORD PTR [r14+0x10],rcx
     de0:	mov    QWORD PTR [r14+0x18],r9
     de4:	mov    rbx,rsi
     de7:	mov    QWORD PTR [rsp],rcx
     deb:	mov    QWORD PTR [rsp+0x8],r9
     df0:	mov    rsi,rbx
     df3:	mov    rdi,r15
     df6:	call   dfb <botlish_fn_5+0x73>
			df7: R_X86_64_PLT32	rt_list_len-0x4
     dfb:	mov    rsi,QWORD PTR [rsp]
     dff:	mov    rcx,rsi
     e02:	and    rcx,rax
     e05:	mov    rdx,rax
     e08:	test   rcx,0x1
     e0f:	jne    e36 <botlish_fn_5+0xae>
     e15:	mov    rsi,QWORD PTR [rsp]
     e19:	mov    rdi,r15
     e1c:	call   e21 <botlish_fn_5+0x99>
			e1d: R_X86_64_PLT32	rt_int_cmp-0x4
     e21:	mov    ecx,0x2
     e26:	test   rax,rax
     e29:	cmove  rcx,QWORD PTR [rip+0x20f]        # 1040 <botlish_fn_5+0x2b8>
     e31:	jmp    e4a <botlish_fn_5+0xc2>
     e36:	mov    ecx,0x2
     e3b:	mov    rsi,QWORD PTR [rsp]
     e3f:	cmp    rsi,rdx
     e42:	cmove  rcx,QWORD PTR [rip+0x1f6]        # 1040 <botlish_fn_5+0x2b8>
     e4a:	cmp    rcx,0x6
     e4e:	je     fe1 <botlish_fn_5+0x259>
     e54:	mov    rsi,QWORD PTR [rsp]
     e58:	test   rsi,0x1
     e5f:	je     e7c <botlish_fn_5+0xf4>
     e65:	mov    rsi,QWORD PTR [rbx+0x8]
     e69:	mov    rax,QWORD PTR [rsp]
     e6d:	mov    rdx,rax
     e70:	sar    rdx,1
     e73:	cmp    rdx,rsi
     e76:	jb     ea4 <botlish_fn_5+0x11c>
     e7c:	mov    rdx,QWORD PTR [rsp]
     e80:	mov    rsi,rbx
     e83:	mov    rdi,r15
     e86:	call   e8b <botlish_fn_5+0x103>
			e87: R_X86_64_PLT32	rt_list_get-0x4
     e8b:	test   rax,rax
     e8e:	jne    e9c <botlish_fn_5+0x114>
     e94:	mov    rdi,r15
     e97:	jmp    f99 <botlish_fn_5+0x211>
     e9c:	mov    rsi,rax
     e9f:	jmp    eac <botlish_fn_5+0x124>
     ea4:	mov    r9,QWORD PTR [rbx+0x10]
     ea8:	mov    rsi,QWORD PTR [r9+rdx*8]
     eac:	mov    QWORD PTR [r14+0x20],rsi
     eb0:	mov    QWORD PTR [rsp+0x10],rsi
     eb5:	mov    QWORD PTR [r14+0x28],0x1
     ebd:	mov    rax,r12
     ec0:	or     rax,0x1
     ec4:	mov    QWORD PTR [r14+0x30],rax
     ec8:	xor    rdx,rdx
     ecb:	mov    rdi,r15
     ece:	mov    rsi,rdx
     ed1:	call   ed6 <botlish_fn_5+0x14e>
			ed2: R_X86_64_PLT32	rt_list_new-0x4
     ed6:	test   rax,rax
     ed9:	jne    ee7 <botlish_fn_5+0x15f>
     edf:	mov    rdi,r15
     ee2:	jmp    f99 <botlish_fn_5+0x211>
     ee7:	mov    QWORD PTR [r14+0x38],rax
     eeb:	mov    r9,rax
     eee:	mov    ecx,0x1
     ef3:	mov    r8,r12
     ef6:	or     r8,0x1
     efa:	mov    rsi,QWORD PTR [rsp+0x10]
     eff:	mov    rdx,r13
     f02:	mov    rdi,r15
     f05:	call   f0a <botlish_fn_5+0x182>
			f06: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<list<int>, list<list<int>>, int, int, list<never>>
     f0a:	test   rax,rax
     f0d:	jne    f1b <botlish_fn_5+0x193>
     f13:	mov    rdi,r15
     f16:	jmp    f99 <botlish_fn_5+0x211>
     f1b:	mov    QWORD PTR [r14+0x20],rax
     f1f:	mov    QWORD PTR [rsp+0x10],rax
     f24:	mov    QWORD PTR [r14+0x28],0x3
     f2c:	mov    rsi,QWORD PTR [rsp]
     f30:	test   rsi,0x1
     f37:	je     f5f <botlish_fn_5+0x1d7>
     f3d:	mov    rsi,QWORD PTR [rsp]
     f41:	mov    rax,rsi
     f44:	add    rax,0x2
     f48:	seto   cl
     f4b:	test   cl,cl
     f4d:	jne    f5f <botlish_fn_5+0x1d7>
     f53:	mov    rsi,rax
     f56:	mov    QWORD PTR [rsp],rax
     f5a:	jmp    f77 <botlish_fn_5+0x1ef>
     f5f:	mov    edx,0x3
     f64:	mov    rsi,QWORD PTR [rsp]
     f68:	mov    rdi,r15
     f6b:	call   f70 <botlish_fn_5+0x1e8>
			f6c: R_X86_64_PLT32	rt_int_add-0x4
     f70:	mov    rsi,rax
     f73:	mov    QWORD PTR [rsp],rax
     f77:	mov    QWORD PTR [r14+0x10],rsi
     f7b:	mov    rdx,QWORD PTR [rsp+0x10]
     f80:	mov    rsi,QWORD PTR [rsp+0x8]
     f85:	mov    rdi,r15
     f88:	call   f8d <botlish_fn_5+0x205>
			f89: R_X86_64_PLT32	rt_list_append-0x4
     f8d:	test   rax,rax
     f90:	jne    fc4 <botlish_fn_5+0x23c>
     f96:	mov    rdi,r15
     f99:	mov    rdi,r15
     f9c:	mov    QWORD PTR [rdi],r14
     f9f:	xor    rax,rax
     fa2:	mov    rbx,QWORD PTR [rsp+0x20]
     fa7:	mov    r12,QWORD PTR [rsp+0x28]
     fac:	mov    r13,QWORD PTR [rsp+0x30]
     fb1:	mov    r14,QWORD PTR [rsp+0x38]
     fb6:	mov    r15,QWORD PTR [rsp+0x40]
     fbb:	add    rsp,0x50
     fbf:	mov    rsp,rbp
     fc2:	pop    rbp
     fc3:	ret
     fc4:	mov    QWORD PTR [r14],rbx
     fc7:	mov    QWORD PTR [r14+0x8],r13
     fcb:	mov    rsi,QWORD PTR [rsp]
     fcf:	mov    QWORD PTR [r14+0x10],rsi
     fd3:	mov    QWORD PTR [r14+0x18],rax
     fd7:	mov    QWORD PTR [rsp+0x8],rax
     fdc:	jmp    df0 <botlish_fn_5+0x68>
     fe1:	mov    rdi,r15
     fe4:	mov    QWORD PTR [rdi],r14
     fe7:	mov    rax,QWORD PTR [rsp+0x8]
     fec:	mov    rbx,QWORD PTR [rsp+0x20]
     ff1:	mov    r12,QWORD PTR [rsp+0x28]
     ff6:	mov    r13,QWORD PTR [rsp+0x30]
     ffb:	mov    r14,QWORD PTR [rsp+0x38]
    1000:	mov    r15,QWORD PTR [rsp+0x40]
    1005:	add    rsp,0x50
    1009:	mov    rsp,rbp
    100c:	pop    rbp
    100d:	ret
    100e:	mov    r15,rdi
    1011:	call   1016 <botlish_fn_5+0x28e>
			1012: R_X86_64_PLT32	rt_stack_overflow-0x4
    1016:	xor    rax,rax
    1019:	mov    rbx,QWORD PTR [rsp+0x20]
    101e:	mov    r12,QWORD PTR [rsp+0x28]
    1023:	mov    r13,QWORD PTR [rsp+0x30]
    1028:	mov    r14,QWORD PTR [rsp+0x38]
    102d:	mov    r15,QWORD PTR [rsp+0x40]
    1032:	add    rsp,0x50
    1036:	mov    rsp,rbp
    1039:	pop    rbp
    103a:	ret
    103b:	add    BYTE PTR [rax],al
    103d:	add    BYTE PTR [rax],al
    103f:	add    BYTE PTR [rsi],al
    1041:	add    BYTE PTR [rax],al
    1043:	add    BYTE PTR [rax],al
    1045:	add    BYTE PTR [rax],al
	...

0000000000001048 <botlish_entry_5: product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>>:
    1048:	push   rbp
    1049:	mov    rbp,rsp
    104c:	mov    rsi,QWORD PTR [rdx]
    104f:	mov    r10,QWORD PTR [rdx+0x8]
    1053:	mov    rcx,QWORD PTR [rdx+0x10]
    1057:	mov    r8,QWORD PTR [rdx+0x18]
    105b:	mov    r9,QWORD PTR [rdx+0x20]
    105f:	mov    rdx,r10
    1062:	call   1067 <botlish_entry_5+0x1f>
			1063: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<list<int>>>
    1067:	mov    rsp,rbp
    106a:	pop    rbp
    106b:	ret

000000000000106c <botlish_fn_6: matmul<list<list<int>>, list<list<int>>>>:
    106c:	push   rbp
    106d:	mov    rbp,rsp
    1070:	sub    rsp,0x30
    1074:	mov    QWORD PTR [rsp],rbx
    1078:	mov    QWORD PTR [rsp+0x8],r12
    107d:	mov    QWORD PTR [rsp+0x10],r13
    1082:	mov    QWORD PTR [rsp+0x18],r14
    1087:	mov    QWORD PTR [rsp+0x20],r15
    108c:	mov    r12,QWORD PTR [rdi]
    108f:	mov    rax,QWORD PTR [rdi+0x8]
    1093:	lea    rcx,[r12+0x28]
    1098:	cmp    rcx,rax
    109b:	ja     1226 <botlish_fn_6+0x1ba>
    10a1:	lea    rax,[r12+0x28]
    10a6:	mov    QWORD PTR [rdi],rax
    10a9:	mov    r13,rdi
    10ac:	mov    QWORD PTR [r12+0x10],0x0
    10b5:	mov    QWORD PTR [r12+0x18],0x0
    10be:	mov    QWORD PTR [r12+0x20],0x0
    10c7:	mov    QWORD PTR [r12],rsi
    10cb:	mov    r14,rsi
    10ce:	mov    QWORD PTR [r12+0x8],rdx
    10d3:	mov    rbx,rdx
    10d6:	mov    rsi,r14
    10d9:	mov    rdi,r13
    10dc:	call   10e1 <botlish_fn_6+0x75>
			10dd: R_X86_64_PLT32	rt_list_len-0x4
    10e1:	sar    rax,1
    10e4:	test   rax,rax
    10e7:	je     11bb <botlish_fn_6+0x14f>
    10ed:	mov    QWORD PTR [r12+0x10],0x1
    10f6:	mov    rax,QWORD PTR [rbx+0x8]
    10fa:	test   rax,rax
    10fd:	jne    112c <botlish_fn_6+0xc0>
    1103:	mov    edx,0x1
    1108:	mov    rsi,rbx
    110b:	mov    rdi,r13
    110e:	call   1113 <botlish_fn_6+0xa7>
			110f: R_X86_64_PLT32	rt_list_get-0x4
    1113:	test   rax,rax
    1116:	jne    1124 <botlish_fn_6+0xb8>
    111c:	mov    rdi,r13
    111f:	jmp    11d5 <botlish_fn_6+0x169>
    1124:	mov    rsi,rax
    1127:	jmp    1136 <botlish_fn_6+0xca>
    112c:	mov    rdx,rbx
    112f:	mov    rax,QWORD PTR [rdx+0x10]
    1133:	mov    rsi,QWORD PTR [rax]
    1136:	mov    rdi,r13
    1139:	call   113e <botlish_fn_6+0xd2>
			113a: R_X86_64_PLT32	rt_list_len-0x4
    113e:	mov    QWORD PTR [r12+0x18],rax
    1143:	mov    r15,rax
    1146:	xor    rdx,rdx
    1149:	mov    rdi,r13
    114c:	mov    rsi,rdx
    114f:	call   1154 <botlish_fn_6+0xe8>
			1150: R_X86_64_PLT32	rt_list_new-0x4
    1154:	test   rax,rax
    1157:	jne    1165 <botlish_fn_6+0xf9>
    115d:	mov    rdi,r13
    1160:	jmp    11d5 <botlish_fn_6+0x169>
    1165:	mov    QWORD PTR [r12+0x20],rax
    116a:	mov    r9,rax
    116d:	mov    ecx,0x1
    1172:	mov    rdx,rbx
    1175:	mov    rsi,r14
    1178:	mov    r8,r15
    117b:	mov    rdi,r13
    117e:	call   1183 <botlish_fn_6+0x117>
			117f: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<list<list<int>>, list<list<int>>, int, int, list<never>>
    1183:	test   rax,rax
    1186:	jne    1194 <botlish_fn_6+0x128>
    118c:	mov    rdi,r13
    118f:	jmp    11d5 <botlish_fn_6+0x169>
    1194:	mov    rdi,r13
    1197:	mov    QWORD PTR [rdi],r12
    119a:	mov    rbx,QWORD PTR [rsp]
    119e:	mov    r12,QWORD PTR [rsp+0x8]
    11a3:	mov    r13,QWORD PTR [rsp+0x10]
    11a8:	mov    r14,QWORD PTR [rsp+0x18]
    11ad:	mov    r15,QWORD PTR [rsp+0x20]
    11b2:	add    rsp,0x30
    11b6:	mov    rsp,rbp
    11b9:	pop    rbp
    11ba:	ret
    11bb:	xor    rdx,rdx
    11be:	mov    rdi,r13
    11c1:	mov    rsi,rdx
    11c4:	call   11c9 <botlish_fn_6+0x15d>
			11c5: R_X86_64_PLT32	rt_list_new-0x4
    11c9:	test   rax,rax
    11cc:	jne    11ff <botlish_fn_6+0x193>
    11d2:	mov    rdi,r13
    11d5:	mov    rdi,r13
    11d8:	mov    QWORD PTR [rdi],r12
    11db:	xor    rax,rax
    11de:	mov    rbx,QWORD PTR [rsp]
    11e2:	mov    r12,QWORD PTR [rsp+0x8]
    11e7:	mov    r13,QWORD PTR [rsp+0x10]
    11ec:	mov    r14,QWORD PTR [rsp+0x18]
    11f1:	mov    r15,QWORD PTR [rsp+0x20]
    11f6:	add    rsp,0x30
    11fa:	mov    rsp,rbp
    11fd:	pop    rbp
    11fe:	ret
    11ff:	mov    rdi,r13
    1202:	mov    QWORD PTR [rdi],r12
    1205:	mov    rbx,QWORD PTR [rsp]
    1209:	mov    r12,QWORD PTR [rsp+0x8]
    120e:	mov    r13,QWORD PTR [rsp+0x10]
    1213:	mov    r14,QWORD PTR [rsp+0x18]
    1218:	mov    r15,QWORD PTR [rsp+0x20]
    121d:	add    rsp,0x30
    1221:	mov    rsp,rbp
    1224:	pop    rbp
    1225:	ret
    1226:	mov    r13,rdi
    1229:	call   122e <botlish_fn_6+0x1c2>
			122a: R_X86_64_PLT32	rt_stack_overflow-0x4
    122e:	xor    rax,rax
    1231:	mov    rbx,QWORD PTR [rsp]
    1235:	mov    r12,QWORD PTR [rsp+0x8]
    123a:	mov    r13,QWORD PTR [rsp+0x10]
    123f:	mov    r14,QWORD PTR [rsp+0x18]
    1244:	mov    r15,QWORD PTR [rsp+0x20]
    1249:	add    rsp,0x30
    124d:	mov    rsp,rbp
    1250:	pop    rbp
    1251:	ret

0000000000001252 <botlish_entry_6: matmul<list<list<int>>, list<list<int>>>>:
    1252:	push   rbp
    1253:	mov    rbp,rsp
    1256:	mov    rsi,QWORD PTR [rdx]
    1259:	mov    rdx,QWORD PTR [rdx+0x8]
    125d:	call   1262 <botlish_entry_6+0x10>
			125e: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<list<list<int>>, list<list<int>>>
    1262:	mov    rsp,rbp
    1265:	pop    rbp
    1266:	ret

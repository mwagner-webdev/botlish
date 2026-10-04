; source:  examples/stdlib/matmul.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 4755  (per function: 822 703 545 772 613 892 408)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> dot<List[int], List[List[int]], int, int, int, int>
;   botlish_fn_2 / botlish_entry_2 -> product_row<List[int], List[List[int]], int, int, List[never]>
;   botlish_fn_3 / botlish_entry_3 -> product_row<List[int], List[List[int]], int, int, List[int]>
;   botlish_fn_4 / botlish_entry_4 -> product_rows<List[List[int]], List[List[int]], int, int, List[never]>
;   botlish_fn_5 / botlish_entry_5 -> product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>
;   botlish_fn_6 / botlish_entry_6 -> matmul<List[List[int]], List[List[int]]>


matmul.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0xd0
       b:	mov    QWORD PTR [rsp+0xb0],rbx
      13:	mov    QWORD PTR [rsp+0xb8],r12
      1b:	mov    QWORD PTR [rsp+0xc0],r13
      23:	mov    QWORD PTR [rsp+0xc8],r14
      2b:	mov    rbx,rdi
      2e:	mov    QWORD PTR [rsp+0x18],0x0
      37:	mov    QWORD PTR [rsp+0x20],0x0
      40:	mov    esi,0x3
      45:	mov    QWORD PTR [rsp],0x3
      4d:	mov    QWORD PTR [rsp+0x8],0x5
      56:	mov    QWORD PTR [rsp+0x10],0x7
      5f:	lea    rdx,[rsp+0x28]
      64:	mov    QWORD PTR [rsp+0x28],0x3
      6d:	mov    QWORD PTR [rsp+0x30],0x5
      76:	mov    QWORD PTR [rsp+0x38],0x7
      7f:	mov    rdi,rbx
      82:	call   87 <botlish_fn_0+0x87>
			83: R_X86_64_PLT32	rt_list_new-0x4
      87:	test   rax,rax
      8a:	je     252 <botlish_fn_0+0x252>
      90:	mov    QWORD PTR [rsp],rax
      94:	mov    r12,rax
      97:	mov    QWORD PTR [rsp+0x8],0x9
      a0:	mov    QWORD PTR [rsp+0x10],0xb
      a9:	mov    QWORD PTR [rsp+0x18],0xd
      b2:	lea    rdx,[rsp+0x40]
      b7:	mov    QWORD PTR [rsp+0x40],0x9
      c0:	mov    QWORD PTR [rsp+0x48],0xb
      c9:	mov    QWORD PTR [rsp+0x50],0xd
      d2:	mov    esi,0x3
      d7:	mov    rdi,rbx
      da:	call   df <botlish_fn_0+0xdf>
			db: R_X86_64_PLT32	rt_list_new-0x4
      df:	test   rax,rax
      e2:	je     252 <botlish_fn_0+0x252>
      e8:	mov    QWORD PTR [rsp+0x8],rax
      ed:	lea    rdx,[rsp+0x58]
      f2:	mov    r9,r12
      f5:	mov    QWORD PTR [rsp+0x58],r9
      fa:	mov    QWORD PTR [rsp+0x60],rax
      ff:	mov    esi,0x2
     104:	mov    rdi,rbx
     107:	call   10c <botlish_fn_0+0x10c>
			108: R_X86_64_PLT32	rt_list_new-0x4
     10c:	test   rax,rax
     10f:	je     252 <botlish_fn_0+0x252>
     115:	mov    QWORD PTR [rsp],rax
     119:	mov    r12,rax
     11c:	mov    QWORD PTR [rsp+0x8],0xf
     125:	mov    QWORD PTR [rsp+0x10],0x11
     12e:	lea    rdx,[rsp+0x68]
     133:	mov    QWORD PTR [rsp+0x68],0xf
     13c:	mov    QWORD PTR [rsp+0x70],0x11
     145:	mov    esi,0x2
     14a:	mov    rdi,rbx
     14d:	call   152 <botlish_fn_0+0x152>
			14e: R_X86_64_PLT32	rt_list_new-0x4
     152:	test   rax,rax
     155:	je     252 <botlish_fn_0+0x252>
     15b:	mov    QWORD PTR [rsp+0x8],rax
     160:	mov    r13,rax
     163:	mov    QWORD PTR [rsp+0x10],0x13
     16c:	mov    QWORD PTR [rsp+0x18],0x15
     175:	lea    rdx,[rsp+0x78]
     17a:	mov    QWORD PTR [rsp+0x78],0x13
     183:	mov    QWORD PTR [rsp+0x80],0x15
     18f:	mov    esi,0x2
     194:	mov    rdi,rbx
     197:	call   19c <botlish_fn_0+0x19c>
			198: R_X86_64_PLT32	rt_list_new-0x4
     19c:	test   rax,rax
     19f:	je     252 <botlish_fn_0+0x252>
     1a5:	mov    QWORD PTR [rsp+0x10],rax
     1aa:	mov    r14,rax
     1ad:	mov    QWORD PTR [rsp+0x18],0x17
     1b6:	mov    QWORD PTR [rsp+0x20],0x19
     1bf:	lea    rdx,[rsp+0x88]
     1c7:	mov    QWORD PTR [rsp+0x88],0x17
     1d3:	mov    QWORD PTR [rsp+0x90],0x19
     1df:	mov    esi,0x2
     1e4:	mov    rdi,rbx
     1e7:	call   1ec <botlish_fn_0+0x1ec>
			1e8: R_X86_64_PLT32	rt_list_new-0x4
     1ec:	test   rax,rax
     1ef:	je     252 <botlish_fn_0+0x252>
     1f5:	mov    QWORD PTR [rsp+0x18],rax
     1fa:	lea    rdx,[rsp+0x98]
     202:	mov    rcx,r13
     205:	mov    QWORD PTR [rsp+0x98],rcx
     20d:	mov    rcx,r14
     210:	mov    QWORD PTR [rsp+0xa0],rcx
     218:	mov    QWORD PTR [rsp+0xa8],rax
     220:	mov    esi,0x3
     225:	mov    rdi,rbx
     228:	call   22d <botlish_fn_0+0x22d>
			229: R_X86_64_PLT32	rt_list_new-0x4
     22d:	test   rax,rax
     230:	je     252 <botlish_fn_0+0x252>
     236:	mov    QWORD PTR [rsp+0x8],rax
     23b:	mov    rdx,rax
     23e:	mov    rsi,r12
     241:	mov    rdi,rbx
     244:	call   249 <botlish_fn_0+0x249>
			245: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<List[List[int]], List[List[int]]>
     249:	test   rax,rax
     24c:	jne    2b4 <botlish_fn_0+0x2b4>
     252:	mov    rdi,rbx
     255:	call   25a <botlish_fn_0+0x25a>
			256: R_X86_64_PLT32	rt_declared_error-0x4
     25a:	cmp    rax,0x40000001
     260:	jne    285 <botlish_fn_0+0x285>
     266:	mov    rdi,rbx
     269:	call   26e <botlish_fn_0+0x26e>
			26a: R_X86_64_PLT32	rt_clear_declared_error-0x4
     26e:	xor    rdx,rdx
     271:	mov    rdi,rbx
     274:	mov    rsi,rdx
     277:	call   27c <botlish_fn_0+0x27c>
			278: R_X86_64_PLT32	rt_list_new-0x4
     27c:	test   rax,rax
     27f:	jne    2b4 <botlish_fn_0+0x2b4>
     285:	xor    rax,rax
     288:	mov    rbx,QWORD PTR [rsp+0xb0]
     290:	mov    r12,QWORD PTR [rsp+0xb8]
     298:	mov    r13,QWORD PTR [rsp+0xc0]
     2a0:	mov    r14,QWORD PTR [rsp+0xc8]
     2a8:	add    rsp,0xd0
     2af:	mov    rsp,rbp
     2b2:	pop    rbp
     2b3:	ret
     2b4:	mov    rbx,QWORD PTR [rsp+0xb0]
     2bc:	mov    r12,QWORD PTR [rsp+0xb8]
     2c4:	mov    r13,QWORD PTR [rsp+0xc0]
     2cc:	mov    r14,QWORD PTR [rsp+0xc8]
     2d4:	add    rsp,0xd0
     2db:	mov    rsp,rbp
     2de:	pop    rbp
     2df:	ret

00000000000002e0 <botlish_entry_0: <program entry>>:
     2e0:	push   rbp
     2e1:	mov    rbp,rsp
     2e4:	call   2e9 <botlish_entry_0+0x9>
			2e5: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     2e9:	mov    rsp,rbp
     2ec:	pop    rbp
     2ed:	ret

00000000000002ee <botlish_fn_1: dot<List[int], List[List[int]], int, int, int, int>>:
     2ee:	push   rbp
     2ef:	mov    rbp,rsp
     2f2:	sub    rsp,0x80
     2f9:	mov    QWORD PTR [rsp+0x50],rbx
     2fe:	mov    QWORD PTR [rsp+0x58],r12
     303:	mov    QWORD PTR [rsp+0x60],r13
     308:	mov    QWORD PTR [rsp+0x68],r14
     30d:	mov    QWORD PTR [rsp+0x70],r15
     312:	mov    QWORD PTR [rsp+0x30],rdi
     317:	mov    QWORD PTR [rsp+0x38],r9
     31c:	mov    rdi,QWORD PTR [rbp+0x10]
     320:	mov    QWORD PTR [rsp],rsi
     324:	mov    r9,rsi
     327:	mov    QWORD PTR [rsp+0x8],rdx
     32c:	mov    r14,rdx
     32f:	mov    QWORD PTR [rsp+0x10],rcx
     334:	mov    QWORD PTR [rsp+0x18],rdi
     339:	sar    r8,1
     33c:	mov    rbx,rcx
     33f:	sar    rbx,1
     342:	mov    r15,rcx
     345:	mov    rsi,QWORD PTR [rsp+0x38]
     34a:	mov    r12,r8
     34d:	mov    QWORD PTR [rsp+0x40],rdi
     352:	cmp    r12,rsi
     355:	mov    QWORD PTR [rsp+0x38],rsi
     35a:	je     528 <botlish_fn_1+0x23a>
     360:	mov    r13,r9
     363:	mov    rdx,QWORD PTR [r13+0x8]
     367:	mov    rax,r12
     36a:	shl    rax,1
     36d:	or     rax,0x1
     371:	sar    rax,1
     374:	cmp    rax,rdx
     377:	jb     3a5 <botlish_fn_1+0xb7>
     37d:	mov    rdx,r12
     380:	shl    rdx,1
     383:	or     rdx,0x1
     387:	mov    rsi,r13
     38a:	mov    rdi,QWORD PTR [rsp+0x30]
     38f:	call   394 <botlish_fn_1+0xa6>
			390: R_X86_64_PLT32	rt_list_get-0x4
     394:	test   rax,rax
     397:	je     431 <botlish_fn_1+0x143>
     39d:	mov    rsi,rax
     3a0:	jmp    3ad <botlish_fn_1+0xbf>
     3a5:	mov    r8,QWORD PTR [r13+0x10]
     3a9:	mov    rsi,QWORD PTR [r8+rax*8]
     3ad:	mov    QWORD PTR [rsp+0x20],rsi
     3b2:	mov    QWORD PTR [rsp+0x48],rsi
     3b7:	mov    r11,QWORD PTR [r14+0x8]
     3bb:	mov    r9,r12
     3be:	shl    r9,1
     3c1:	or     r9,0x1
     3c5:	sar    r9,1
     3c8:	cmp    r9,r11
     3cb:	jb     3f9 <botlish_fn_1+0x10b>
     3d1:	mov    rdx,r12
     3d4:	shl    rdx,1
     3d7:	or     rdx,0x1
     3db:	mov    rsi,r14
     3de:	mov    rdi,QWORD PTR [rsp+0x30]
     3e3:	call   3e8 <botlish_fn_1+0xfa>
			3e4: R_X86_64_PLT32	rt_list_get-0x4
     3e8:	test   rax,rax
     3eb:	je     431 <botlish_fn_1+0x143>
     3f1:	mov    rsi,rax
     3f4:	jmp    401 <botlish_fn_1+0x113>
     3f9:	mov    rax,QWORD PTR [r14+0x10]
     3fd:	mov    rsi,QWORD PTR [rax+r9*8]
     401:	test   r15,0x1
     408:	je     41b <botlish_fn_1+0x12d>
     40e:	mov    rax,QWORD PTR [rsi+0x8]
     412:	cmp    rbx,rax
     415:	jb     461 <botlish_fn_1+0x173>
     41b:	mov    rdx,r15
     41e:	mov    rdi,QWORD PTR [rsp+0x30]
     423:	call   428 <botlish_fn_1+0x13a>
			424: R_X86_64_PLT32	rt_list_get-0x4
     428:	test   rax,rax
     42b:	jne    459 <botlish_fn_1+0x16b>
     431:	xor    rax,rax
     434:	mov    rbx,QWORD PTR [rsp+0x50]
     439:	mov    r12,QWORD PTR [rsp+0x58]
     43e:	mov    r13,QWORD PTR [rsp+0x60]
     443:	mov    r14,QWORD PTR [rsp+0x68]
     448:	mov    r15,QWORD PTR [rsp+0x70]
     44d:	add    rsp,0x80
     454:	mov    rsp,rbp
     457:	pop    rbp
     458:	ret
     459:	mov    rdx,rax
     45c:	jmp    469 <botlish_fn_1+0x17b>
     461:	mov    rax,QWORD PTR [rsi+0x10]
     465:	mov    rdx,QWORD PTR [rax+rbx*8]
     469:	mov    QWORD PTR [rsp+0x28],rdx
     46e:	mov    rsi,QWORD PTR [rsp+0x48]
     473:	mov    rax,rsi
     476:	and    rax,rdx
     479:	test   rax,0x1
     47f:	je     4b4 <botlish_fn_1+0x1c6>
     485:	mov    rax,rsi
     488:	sar    rax,1
     48b:	lea    rcx,[rdx-0x1]
     48f:	mov    r11,rdx
     492:	imul   rcx
     495:	seto   cl
     498:	or     rax,0x1
     49c:	test   cl,cl
     49e:	je     4ac <botlish_fn_1+0x1be>
     4a4:	mov    rdx,r11
     4a7:	jmp    4b4 <botlish_fn_1+0x1c6>
     4ac:	mov    rdx,rax
     4af:	jmp    4c1 <botlish_fn_1+0x1d3>
     4b4:	mov    rdi,QWORD PTR [rsp+0x30]
     4b9:	call   4be <botlish_fn_1+0x1d0>
			4ba: R_X86_64_PLT32	rt_int_mul-0x4
     4be:	mov    rdx,rax
     4c1:	mov    QWORD PTR [rsp+0x20],rdx
     4c6:	mov    rsi,QWORD PTR [rsp+0x40]
     4cb:	mov    rax,rsi
     4ce:	and    rax,rdx
     4d1:	test   rax,0x1
     4d7:	je     4f2 <botlish_fn_1+0x204>
     4dd:	lea    rcx,[rdx-0x1]
     4e1:	mov    rax,rsi
     4e4:	add    rax,rcx
     4e7:	seto   cl
     4ea:	test   cl,cl
     4ec:	je     4fc <botlish_fn_1+0x20e>
     4f2:	mov    rdi,QWORD PTR [rsp+0x30]
     4f7:	call   4fc <botlish_fn_1+0x20e>
			4f8: R_X86_64_PLT32	rt_int_add-0x4
     4fc:	mov    QWORD PTR [rsp],r13
     500:	mov    QWORD PTR [rsp+0x8],r14
     505:	mov    QWORD PTR [rsp+0x10],r15
     50a:	mov    QWORD PTR [rsp+0x18],rax
     50f:	add    r12,0x1
     516:	mov    rsi,QWORD PTR [rsp+0x38]
     51b:	mov    r9,r13
     51e:	mov    QWORD PTR [rsp+0x40],rax
     523:	jmp    352 <botlish_fn_1+0x64>
     528:	mov    rax,QWORD PTR [rsp+0x40]
     52d:	mov    rbx,QWORD PTR [rsp+0x50]
     532:	mov    r12,QWORD PTR [rsp+0x58]
     537:	mov    r13,QWORD PTR [rsp+0x60]
     53c:	mov    r14,QWORD PTR [rsp+0x68]
     541:	mov    r15,QWORD PTR [rsp+0x70]
     546:	add    rsp,0x80
     54d:	mov    rsp,rbp
     550:	pop    rbp
     551:	ret

0000000000000552 <botlish_entry_1: dot<List[int], List[List[int]], int, int, int, int>>:
     552:	push   rbp
     553:	mov    rbp,rsp
     556:	sub    rsp,0x10
     55a:	mov    rsi,QWORD PTR [rdx]
     55d:	mov    r10,QWORD PTR [rdx+0x8]
     561:	mov    rcx,QWORD PTR [rdx+0x10]
     565:	mov    r8,QWORD PTR [rdx+0x18]
     569:	mov    r9,QWORD PTR [rdx+0x20]
     56d:	mov    r11,QWORD PTR [rdx+0x28]
     571:	sar    r9,1
     574:	mov    QWORD PTR [rsp],r11
     578:	mov    rdx,r10
     57b:	call   580 <botlish_entry_1+0x2e>
			57c: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<List[int], List[List[int]], int, int, int, int>
     580:	add    rsp,0x10
     584:	mov    rsp,rbp
     587:	pop    rbp
     588:	ret

0000000000000589 <botlish_fn_2: product_row<List[int], List[List[int]], int, int, List[never]>>:
     589:	push   rbp
     58a:	mov    rbp,rsp
     58d:	sub    rsp,0xb0
     594:	mov    QWORD PTR [rsp+0x80],rbx
     59c:	mov    QWORD PTR [rsp+0x88],r12
     5a4:	mov    QWORD PTR [rsp+0x90],r13
     5ac:	mov    QWORD PTR [rsp+0x98],r14
     5b4:	mov    QWORD PTR [rsp+0xa0],r15
     5bc:	mov    QWORD PTR [rsp+0x68],rdi
     5c1:	mov    QWORD PTR [rsp+0x10],rsi
     5c6:	mov    r15,rsi
     5c9:	mov    QWORD PTR [rsp+0x18],rdx
     5ce:	mov    r14,rdx
     5d1:	mov    QWORD PTR [rsp+0x20],rcx
     5d6:	mov    QWORD PTR [rsp+0x28],r8
     5db:	mov    QWORD PTR [rsp+0x30],r9
     5e0:	mov    QWORD PTR [rsp+0x78],r9
     5e5:	mov    rbx,rcx
     5e8:	sar    rbx,1
     5eb:	mov    QWORD PTR [rsp+0x70],rcx
     5f0:	mov    rax,r8
     5f3:	sar    rax,1
     5f6:	mov    r13,r8
     5f9:	cmp    rbx,rax
     5fc:	je     73f <botlish_fn_2+0x1b6>
     602:	mov    r12d,0x1
     608:	mov    QWORD PTR [rsp+0x38],0x1
     611:	mov    rsi,r15
     614:	mov    rdi,QWORD PTR [rsp+0x68]
     619:	call   61e <botlish_fn_2+0x95>
			61a: R_X86_64_PLT32	rt_list_len-0x4
     61e:	mov    QWORD PTR [rsp+0x40],0x1
     627:	mov    r9,rax
     62a:	sar    r9,1
     62d:	mov    QWORD PTR [rsp],r12
     631:	mov    rcx,QWORD PTR [rsp+0x70]
     636:	mov    r8,r12
     639:	mov    rdx,r14
     63c:	mov    rsi,r15
     63f:	mov    rdi,QWORD PTR [rsp+0x68]
     644:	call   649 <botlish_fn_2+0xc0>
			645: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<List[int], List[List[int]], int, int, int, int>
     649:	test   rax,rax
     64c:	je     6d4 <botlish_fn_2+0x14b>
     652:	mov    QWORD PTR [rsp+0x20],rax
     657:	lea    rcx,[rbx+0x1]
     65b:	shl    rcx,1
     65e:	or     rcx,0x1
     662:	mov    QWORD PTR [rsp+0x38],rcx
     667:	mov    rbx,rcx
     66a:	lea    rcx,[rsp+0x48]
     66f:	mov    QWORD PTR [rsp+0x48],0x0
     678:	mov    r9,QWORD PTR [rsp+0x78]
     67d:	mov    QWORD PTR [rsp+0x50],r9
     682:	mov    QWORD PTR [rsp+0x58],0x2
     68b:	mov    QWORD PTR [rsp+0x60],rax
     690:	mov    esi,0x3
     695:	mov    edx,0x4
     69a:	mov    rdi,QWORD PTR [rsp+0x68]
     69f:	call   6a4 <botlish_fn_2+0x11b>
			6a0: R_X86_64_PLT32	rt_construct-0x4
     6a4:	test   rax,rax
     6a7:	je     6d4 <botlish_fn_2+0x14b>
     6ad:	mov    QWORD PTR [rsp+0x20],rax
     6b2:	mov    rcx,rbx
     6b5:	mov    rdx,r14
     6b8:	mov    rsi,r15
     6bb:	mov    rdi,QWORD PTR [rsp+0x68]
     6c0:	mov    r8,r13
     6c3:	mov    r9,rax
     6c6:	call   6cb <botlish_fn_2+0x142>
			6c7: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<List[int], List[List[int]], int, int, List[int]>
     6cb:	test   rax,rax
     6ce:	jne    70b <botlish_fn_2+0x182>
     6d4:	xor    rax,rax
     6d7:	mov    rbx,QWORD PTR [rsp+0x80]
     6df:	mov    r12,QWORD PTR [rsp+0x88]
     6e7:	mov    r13,QWORD PTR [rsp+0x90]
     6ef:	mov    r14,QWORD PTR [rsp+0x98]
     6f7:	mov    r15,QWORD PTR [rsp+0xa0]
     6ff:	add    rsp,0xb0
     706:	mov    rsp,rbp
     709:	pop    rbp
     70a:	ret
     70b:	mov    rbx,QWORD PTR [rsp+0x80]
     713:	mov    r12,QWORD PTR [rsp+0x88]
     71b:	mov    r13,QWORD PTR [rsp+0x90]
     723:	mov    r14,QWORD PTR [rsp+0x98]
     72b:	mov    r15,QWORD PTR [rsp+0xa0]
     733:	add    rsp,0xb0
     73a:	mov    rsp,rbp
     73d:	pop    rbp
     73e:	ret
     73f:	mov    rax,QWORD PTR [rsp+0x78]
     744:	mov    rbx,QWORD PTR [rsp+0x80]
     74c:	mov    r12,QWORD PTR [rsp+0x88]
     754:	mov    r13,QWORD PTR [rsp+0x90]
     75c:	mov    r14,QWORD PTR [rsp+0x98]
     764:	mov    r15,QWORD PTR [rsp+0xa0]
     76c:	add    rsp,0xb0
     773:	mov    rsp,rbp
     776:	pop    rbp
     777:	ret

0000000000000778 <botlish_entry_2: product_row<List[int], List[List[int]], int, int, List[never]>>:
     778:	push   rbp
     779:	mov    rbp,rsp
     77c:	mov    rsi,QWORD PTR [rdx]
     77f:	mov    r10,QWORD PTR [rdx+0x8]
     783:	mov    rcx,QWORD PTR [rdx+0x10]
     787:	mov    r8,QWORD PTR [rdx+0x18]
     78b:	mov    r9,QWORD PTR [rdx+0x20]
     78f:	mov    rdx,r10
     792:	call   797 <botlish_entry_2+0x1f>
			793: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<List[int], List[List[int]], int, int, List[never]>
     797:	mov    rsp,rbp
     79a:	pop    rbp
     79b:	ret
     79c:	add    BYTE PTR [rax],al
	...

00000000000007a0 <botlish_fn_3: product_row<List[int], List[List[int]], int, int, List[int]>>:
     7a0:	push   rbp
     7a1:	mov    rbp,rsp
     7a4:	sub    rsp,0xc0
     7ab:	mov    QWORD PTR [rsp+0x90],rbx
     7b3:	mov    QWORD PTR [rsp+0x98],r12
     7bb:	mov    QWORD PTR [rsp+0xa0],r13
     7c3:	mov    QWORD PTR [rsp+0xa8],r14
     7cb:	mov    QWORD PTR [rsp+0xb0],r15
     7d3:	mov    r15,rdi
     7d6:	mov    QWORD PTR [rsp+0x30],0x0
     7df:	mov    QWORD PTR [rsp+0x38],0x0
     7e8:	mov    QWORD PTR [rsp+0x10],rsi
     7ed:	mov    r12,rsi
     7f0:	mov    QWORD PTR [rsp+0x18],rdx
     7f5:	mov    QWORD PTR [rsp+0x70],rdx
     7fa:	mov    QWORD PTR [rsp+0x20],rcx
     7ff:	mov    QWORD PTR [rsp+0x28],r9
     804:	mov    QWORD PTR [rsp+0x80],r9
     80c:	lea    r14,[rsp+0x50]
     811:	mov    rbx,r8
     814:	mov    rsi,rcx
     817:	mov    rax,rbx
     81a:	or     rax,0x1
     81e:	mov    rcx,rsi
     821:	and    rcx,rax
     824:	mov    QWORD PTR [rsp+0x78],rsi
     829:	test   rcx,0x1
     830:	jne    85f <botlish_fn_3+0xbf>
     836:	mov    rdx,rbx
     839:	or     rdx,0x1
     83d:	mov    rsi,QWORD PTR [rsp+0x78]
     842:	mov    rdi,r15
     845:	call   84a <botlish_fn_3+0xaa>
			846: R_X86_64_PLT32	rt_int_cmp-0x4
     84a:	mov    ecx,0x2
     84f:	test   rax,rax
     852:	cmove  rcx,QWORD PTR [rip+0x1fe]        # a58 <botlish_fn_3+0x2b8>
     85a:	jmp    87b <botlish_fn_3+0xdb>
     85f:	mov    rax,rbx
     862:	or     rax,0x1
     866:	mov    ecx,0x2
     86b:	mov    rsi,QWORD PTR [rsp+0x78]
     870:	cmp    rsi,rax
     873:	cmove  rcx,QWORD PTR [rip+0x1dd]        # a58 <botlish_fn_3+0x2b8>
     87b:	cmp    rcx,0x6
     87f:	je     9b6 <botlish_fn_3+0x216>
     885:	mov    r13d,0x1
     88b:	mov    QWORD PTR [rsp+0x30],0x1
     894:	mov    rsi,r12
     897:	mov    rdi,r15
     89a:	call   89f <botlish_fn_3+0xff>
			89b: R_X86_64_PLT32	rt_list_len-0x4
     89f:	mov    QWORD PTR [rsp+0x38],0x1
     8a8:	mov    r9,rax
     8ab:	sar    r9,1
     8ae:	mov    QWORD PTR [rsp],r13
     8b2:	mov    r8,r13
     8b5:	mov    r13,QWORD PTR [rsp+0x70]
     8ba:	mov    rcx,QWORD PTR [rsp+0x78]
     8bf:	mov    rdx,r13
     8c2:	mov    rsi,r12
     8c5:	mov    rdi,r15
     8c8:	call   8cd <botlish_fn_3+0x12d>
			8c9: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<List[int], List[List[int]], int, int, int, int>
     8cd:	test   rax,rax
     8d0:	je     9ec <botlish_fn_3+0x24c>
     8d6:	mov    QWORD PTR [rsp+0x30],rax
     8db:	mov    QWORD PTR [rsp+0x88],rax
     8e3:	mov    QWORD PTR [rsp+0x38],0x3
     8ec:	mov    rsi,QWORD PTR [rsp+0x78]
     8f1:	test   rsi,0x1
     8f8:	je     922 <botlish_fn_3+0x182>
     8fe:	mov    rsi,QWORD PTR [rsp+0x78]
     903:	mov    rcx,rsi
     906:	add    rcx,0x2
     90a:	seto   dl
     90d:	test   dl,dl
     90f:	jne    922 <botlish_fn_3+0x182>
     915:	mov    rsi,rcx
     918:	mov    QWORD PTR [rsp+0x78],rcx
     91d:	jmp    93c <botlish_fn_3+0x19c>
     922:	mov    edx,0x3
     927:	mov    rsi,QWORD PTR [rsp+0x78]
     92c:	mov    rdi,r15
     92f:	call   934 <botlish_fn_3+0x194>
			930: R_X86_64_PLT32	rt_int_add-0x4
     934:	mov    rsi,rax
     937:	mov    QWORD PTR [rsp+0x78],rax
     93c:	mov    QWORD PTR [rsp+0x20],rsi
     941:	mov    QWORD PTR [rsp+0x50],0x0
     94a:	mov    r9,QWORD PTR [rsp+0x80]
     952:	mov    QWORD PTR [rsp+0x58],r9
     957:	mov    QWORD PTR [rsp+0x60],0x2
     960:	mov    rax,QWORD PTR [rsp+0x88]
     968:	mov    QWORD PTR [rsp+0x68],rax
     96d:	mov    esi,0x3
     972:	mov    edx,0x4
     977:	mov    rcx,r14
     97a:	mov    rdi,r15
     97d:	call   982 <botlish_fn_3+0x1e2>
			97e: R_X86_64_PLT32	rt_construct-0x4
     982:	test   rax,rax
     985:	je     9ec <botlish_fn_3+0x24c>
     98b:	mov    QWORD PTR [rsp+0x10],r12
     990:	mov    QWORD PTR [rsp+0x18],r13
     995:	mov    rsi,QWORD PTR [rsp+0x78]
     99a:	mov    QWORD PTR [rsp+0x20],rsi
     99f:	mov    QWORD PTR [rsp+0x28],rax
     9a4:	mov    QWORD PTR [rsp+0x70],r13
     9a9:	mov    QWORD PTR [rsp+0x80],rax
     9b1:	jmp    817 <botlish_fn_3+0x77>
     9b6:	mov    r9,QWORD PTR [rsp+0x80]
     9be:	lea    rcx,[rsp+0x40]
     9c3:	mov    QWORD PTR [rsp+0x40],0x0
     9cc:	mov    QWORD PTR [rsp+0x48],r9
     9d1:	mov    esi,0x1
     9d6:	mov    edx,0x2
     9db:	mov    rdi,r15
     9de:	call   9e3 <botlish_fn_3+0x243>
			9df: R_X86_64_PLT32	rt_construct-0x4
     9e3:	test   rax,rax
     9e6:	jne    a23 <botlish_fn_3+0x283>
     9ec:	xor    rax,rax
     9ef:	mov    rbx,QWORD PTR [rsp+0x90]
     9f7:	mov    r12,QWORD PTR [rsp+0x98]
     9ff:	mov    r13,QWORD PTR [rsp+0xa0]
     a07:	mov    r14,QWORD PTR [rsp+0xa8]
     a0f:	mov    r15,QWORD PTR [rsp+0xb0]
     a17:	add    rsp,0xc0
     a1e:	mov    rsp,rbp
     a21:	pop    rbp
     a22:	ret
     a23:	mov    rbx,QWORD PTR [rsp+0x90]
     a2b:	mov    r12,QWORD PTR [rsp+0x98]
     a33:	mov    r13,QWORD PTR [rsp+0xa0]
     a3b:	mov    r14,QWORD PTR [rsp+0xa8]
     a43:	mov    r15,QWORD PTR [rsp+0xb0]
     a4b:	add    rsp,0xc0
     a52:	mov    rsp,rbp
     a55:	pop    rbp
     a56:	ret
     a57:	add    BYTE PTR [rsi],al
     a59:	add    BYTE PTR [rax],al
     a5b:	add    BYTE PTR [rax],al
     a5d:	add    BYTE PTR [rax],al
	...

0000000000000a60 <botlish_entry_3: product_row<List[int], List[List[int]], int, int, List[int]>>:
     a60:	push   rbp
     a61:	mov    rbp,rsp
     a64:	mov    rsi,QWORD PTR [rdx]
     a67:	mov    r10,QWORD PTR [rdx+0x8]
     a6b:	mov    rcx,QWORD PTR [rdx+0x10]
     a6f:	mov    r8,QWORD PTR [rdx+0x18]
     a73:	mov    r9,QWORD PTR [rdx+0x20]
     a77:	mov    rdx,r10
     a7a:	call   a7f <botlish_entry_3+0x1f>
			a7b: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<List[int], List[List[int]], int, int, List[int]>
     a7f:	mov    rsp,rbp
     a82:	pop    rbp
     a83:	ret

0000000000000a84 <botlish_fn_4: product_rows<List[List[int]], List[List[int]], int, int, List[never]>>:
     a84:	push   rbp
     a85:	mov    rbp,rsp
     a88:	sub    rsp,0xa0
     a8f:	mov    QWORD PTR [rsp+0x70],rbx
     a94:	mov    QWORD PTR [rsp+0x78],r12
     a99:	mov    QWORD PTR [rsp+0x80],r13
     aa1:	mov    QWORD PTR [rsp+0x88],r14
     aa9:	mov    QWORD PTR [rsp+0x90],r15
     ab1:	mov    rbx,rcx
     ab4:	mov    r15,rdi
     ab7:	mov    QWORD PTR [rsp+0x30],0x0
     ac0:	mov    QWORD PTR [rsp],rsi
     ac4:	mov    r14,rsi
     ac7:	mov    QWORD PTR [rsp+0x8],rdx
     acc:	mov    r13,rdx
     acf:	mov    QWORD PTR [rsp+0x10],r8
     ad4:	mov    r12,r8
     ad7:	mov    QWORD PTR [rsp+0x18],r9
     adc:	mov    QWORD PTR [rsp+0x58],r9
     ae1:	mov    rsi,r14
     ae4:	mov    rdi,r15
     ae7:	call   aec <botlish_fn_4+0x68>
			ae8: R_X86_64_PLT32	rt_list_len-0x4
     aec:	mov    rcx,rbx
     aef:	sar    rbx,1
     af2:	sar    rax,1
     af5:	cmp    rbx,rax
     af8:	je     c7d <botlish_fn_4+0x1f9>
     afe:	test   rcx,0x1
     b05:	jne    b13 <botlish_fn_4+0x8f>
     b0b:	mov    rdx,rcx
     b0e:	jmp    b26 <botlish_fn_4+0xa2>
     b13:	mov    rsi,r14
     b16:	mov    rax,QWORD PTR [rsi+0x8]
     b1a:	cmp    rbx,rax
     b1d:	jb     b42 <botlish_fn_4+0xbe>
     b23:	mov    rdx,rcx
     b26:	mov    rsi,r14
     b29:	mov    rdi,r15
     b2c:	call   b31 <botlish_fn_4+0xad>
			b2d: R_X86_64_PLT32	rt_list_get-0x4
     b31:	test   rax,rax
     b34:	je     c1e <botlish_fn_4+0x19a>
     b3a:	mov    rsi,rax
     b3d:	jmp    b4d <botlish_fn_4+0xc9>
     b42:	mov    rsi,r14
     b45:	mov    rax,QWORD PTR [rsi+0x10]
     b49:	mov    rsi,QWORD PTR [rax+rbx*8]
     b4d:	mov    QWORD PTR [rsp+0x20],rsi
     b52:	mov    QWORD PTR [rsp+0x60],rsi
     b57:	mov    QWORD PTR [rsp+0x28],0x1
     b60:	xor    rdx,rdx
     b63:	mov    rdi,r15
     b66:	mov    rsi,rdx
     b69:	call   b6e <botlish_fn_4+0xea>
			b6a: R_X86_64_PLT32	rt_list_new-0x4
     b6e:	test   rax,rax
     b71:	je     c1e <botlish_fn_4+0x19a>
     b77:	mov    QWORD PTR [rsp+0x30],rax
     b7c:	mov    r9,rax
     b7f:	mov    ecx,0x1
     b84:	mov    rsi,QWORD PTR [rsp+0x60]
     b89:	mov    rdx,r13
     b8c:	mov    rdi,r15
     b8f:	mov    r8,r12
     b92:	call   b97 <botlish_fn_4+0x113>
			b93: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<List[int], List[List[int]], int, int, List[never]>
     b97:	test   rax,rax
     b9a:	je     c1e <botlish_fn_4+0x19a>
     ba0:	mov    QWORD PTR [rsp+0x20],rax
     ba5:	lea    rcx,[rbx+0x1]
     ba9:	shl    rcx,1
     bac:	or     rcx,0x1
     bb0:	mov    QWORD PTR [rsp+0x28],rcx
     bb5:	mov    rbx,rcx
     bb8:	lea    rcx,[rsp+0x38]
     bbd:	mov    QWORD PTR [rsp+0x38],0x0
     bc6:	mov    r9,QWORD PTR [rsp+0x58]
     bcb:	mov    QWORD PTR [rsp+0x40],r9
     bd0:	mov    QWORD PTR [rsp+0x48],0x2
     bd9:	mov    QWORD PTR [rsp+0x50],rax
     bde:	mov    esi,0x3
     be3:	mov    edx,0x4
     be8:	mov    rdi,r15
     beb:	call   bf0 <botlish_fn_4+0x16c>
			bec: R_X86_64_PLT32	rt_construct-0x4
     bf0:	test   rax,rax
     bf3:	je     c1e <botlish_fn_4+0x19a>
     bf9:	mov    QWORD PTR [rsp+0x18],rax
     bfe:	mov    rcx,rbx
     c01:	mov    rdx,r13
     c04:	mov    rsi,r14
     c07:	mov    rdi,r15
     c0a:	mov    r8,r12
     c0d:	mov    r9,rax
     c10:	call   c15 <botlish_fn_4+0x191>
			c11: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>
     c15:	test   rax,rax
     c18:	jne    c4f <botlish_fn_4+0x1cb>
     c1e:	xor    rax,rax
     c21:	mov    rbx,QWORD PTR [rsp+0x70]
     c26:	mov    r12,QWORD PTR [rsp+0x78]
     c2b:	mov    r13,QWORD PTR [rsp+0x80]
     c33:	mov    r14,QWORD PTR [rsp+0x88]
     c3b:	mov    r15,QWORD PTR [rsp+0x90]
     c43:	add    rsp,0xa0
     c4a:	mov    rsp,rbp
     c4d:	pop    rbp
     c4e:	ret
     c4f:	mov    rbx,QWORD PTR [rsp+0x70]
     c54:	mov    r12,QWORD PTR [rsp+0x78]
     c59:	mov    r13,QWORD PTR [rsp+0x80]
     c61:	mov    r14,QWORD PTR [rsp+0x88]
     c69:	mov    r15,QWORD PTR [rsp+0x90]
     c71:	add    rsp,0xa0
     c78:	mov    rsp,rbp
     c7b:	pop    rbp
     c7c:	ret
     c7d:	mov    rax,QWORD PTR [rsp+0x58]
     c82:	mov    rbx,QWORD PTR [rsp+0x70]
     c87:	mov    r12,QWORD PTR [rsp+0x78]
     c8c:	mov    r13,QWORD PTR [rsp+0x80]
     c94:	mov    r14,QWORD PTR [rsp+0x88]
     c9c:	mov    r15,QWORD PTR [rsp+0x90]
     ca4:	add    rsp,0xa0
     cab:	mov    rsp,rbp
     cae:	pop    rbp
     caf:	ret

0000000000000cb0 <botlish_entry_4: product_rows<List[List[int]], List[List[int]], int, int, List[never]>>:
     cb0:	push   rbp
     cb1:	mov    rbp,rsp
     cb4:	mov    rsi,QWORD PTR [rdx]
     cb7:	mov    r10,QWORD PTR [rdx+0x8]
     cbb:	mov    rcx,QWORD PTR [rdx+0x10]
     cbf:	mov    r8,QWORD PTR [rdx+0x18]
     cc3:	mov    r9,QWORD PTR [rdx+0x20]
     cc7:	mov    rdx,r10
     cca:	call   ccf <botlish_entry_4+0x1f>
			ccb: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[never]>
     ccf:	mov    rsp,rbp
     cd2:	pop    rbp
     cd3:	ret
     cd4:	add    BYTE PTR [rax],al
	...

0000000000000cd8 <botlish_fn_5: product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>>:
     cd8:	push   rbp
     cd9:	mov    rbp,rsp
     cdc:	sub    rsp,0xc0
     ce3:	mov    QWORD PTR [rsp+0x90],rbx
     ceb:	mov    QWORD PTR [rsp+0x98],r12
     cf3:	mov    QWORD PTR [rsp+0xa0],r13
     cfb:	mov    QWORD PTR [rsp+0xa8],r14
     d03:	mov    QWORD PTR [rsp+0xb0],r15
     d0b:	mov    r12,r8
     d0e:	mov    r15,rdi
     d11:	mov    QWORD PTR [rsp+0x20],0x0
     d1a:	mov    QWORD PTR [rsp+0x28],0x0
     d23:	mov    QWORD PTR [rsp+0x30],0x0
     d2c:	mov    QWORD PTR [rsp+0x38],0x0
     d35:	mov    QWORD PTR [rsp],rsi
     d39:	mov    QWORD PTR [rsp+0x8],rdx
     d3e:	mov    r13,rdx
     d41:	mov    QWORD PTR [rsp+0x10],rcx
     d46:	mov    QWORD PTR [rsp+0x18],r9
     d4b:	mov    QWORD PTR [rsp+0x78],r9
     d50:	lea    r14,[rsp+0x50]
     d55:	mov    rbx,rsi
     d58:	mov    QWORD PTR [rsp+0x70],rcx
     d5d:	mov    rsi,rbx
     d60:	mov    rdi,r15
     d63:	call   d68 <botlish_fn_5+0x90>
			d64: R_X86_64_PLT32	rt_list_len-0x4
     d68:	mov    rsi,QWORD PTR [rsp+0x70]
     d6d:	mov    rcx,rsi
     d70:	and    rcx,rax
     d73:	mov    rdx,rax
     d76:	test   rcx,0x1
     d7d:	jne    da5 <botlish_fn_5+0xcd>
     d83:	mov    rsi,QWORD PTR [rsp+0x70]
     d88:	mov    rdi,r15
     d8b:	call   d90 <botlish_fn_5+0xb8>
			d8c: R_X86_64_PLT32	rt_int_cmp-0x4
     d90:	mov    ecx,0x2
     d95:	test   rax,rax
     d98:	cmove  rcx,QWORD PTR [rip+0x258]        # ff8 <botlish_fn_5+0x320>
     da0:	jmp    dba <botlish_fn_5+0xe2>
     da5:	mov    ecx,0x2
     daa:	mov    rsi,QWORD PTR [rsp+0x70]
     daf:	cmp    rsi,rdx
     db2:	cmove  rcx,QWORD PTR [rip+0x23e]        # ff8 <botlish_fn_5+0x320>
     dba:	cmp    rcx,0x6
     dbe:	je     f54 <botlish_fn_5+0x27c>
     dc4:	mov    rsi,QWORD PTR [rsp+0x70]
     dc9:	test   rsi,0x1
     dd0:	je     dee <botlish_fn_5+0x116>
     dd6:	mov    rsi,QWORD PTR [rbx+0x8]
     dda:	mov    rax,QWORD PTR [rsp+0x70]
     ddf:	mov    rdx,rax
     de2:	sar    rdx,1
     de5:	cmp    rdx,rsi
     de8:	jb     e0f <botlish_fn_5+0x137>
     dee:	mov    rdx,QWORD PTR [rsp+0x70]
     df3:	mov    rsi,rbx
     df6:	mov    rdi,r15
     df9:	call   dfe <botlish_fn_5+0x126>
			dfa: R_X86_64_PLT32	rt_list_get-0x4
     dfe:	test   rax,rax
     e01:	je     f87 <botlish_fn_5+0x2af>
     e07:	mov    rsi,rax
     e0a:	jmp    e17 <botlish_fn_5+0x13f>
     e0f:	mov    r9,QWORD PTR [rbx+0x10]
     e13:	mov    rsi,QWORD PTR [r9+rdx*8]
     e17:	mov    QWORD PTR [rsp+0x20],rsi
     e1c:	mov    QWORD PTR [rsp+0x80],rsi
     e24:	mov    QWORD PTR [rsp+0x28],0x1
     e2d:	mov    rax,r12
     e30:	or     rax,0x1
     e34:	mov    QWORD PTR [rsp+0x30],rax
     e39:	xor    rdx,rdx
     e3c:	mov    rdi,r15
     e3f:	mov    rsi,rdx
     e42:	call   e47 <botlish_fn_5+0x16f>
			e43: R_X86_64_PLT32	rt_list_new-0x4
     e47:	test   rax,rax
     e4a:	je     f87 <botlish_fn_5+0x2af>
     e50:	mov    QWORD PTR [rsp+0x38],rax
     e55:	mov    r9,rax
     e58:	mov    ecx,0x1
     e5d:	mov    r8,r12
     e60:	or     r8,0x1
     e64:	mov    rsi,QWORD PTR [rsp+0x80]
     e6c:	mov    rdx,r13
     e6f:	mov    rdi,r15
     e72:	call   e77 <botlish_fn_5+0x19f>
			e73: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<List[int], List[List[int]], int, int, List[never]>
     e77:	test   rax,rax
     e7a:	je     f87 <botlish_fn_5+0x2af>
     e80:	mov    QWORD PTR [rsp+0x20],rax
     e85:	mov    QWORD PTR [rsp+0x80],rax
     e8d:	mov    QWORD PTR [rsp+0x28],0x3
     e96:	mov    rsi,QWORD PTR [rsp+0x70]
     e9b:	test   rsi,0x1
     ea2:	je     ecc <botlish_fn_5+0x1f4>
     ea8:	mov    rsi,QWORD PTR [rsp+0x70]
     ead:	mov    rcx,rsi
     eb0:	add    rcx,0x2
     eb4:	seto   al
     eb7:	test   al,al
     eb9:	jne    ecc <botlish_fn_5+0x1f4>
     ebf:	mov    rsi,rcx
     ec2:	mov    QWORD PTR [rsp+0x70],rcx
     ec7:	jmp    ee6 <botlish_fn_5+0x20e>
     ecc:	mov    edx,0x3
     ed1:	mov    rsi,QWORD PTR [rsp+0x70]
     ed6:	mov    rdi,r15
     ed9:	call   ede <botlish_fn_5+0x206>
			eda: R_X86_64_PLT32	rt_int_add-0x4
     ede:	mov    rsi,rax
     ee1:	mov    QWORD PTR [rsp+0x70],rax
     ee6:	mov    QWORD PTR [rsp+0x10],rsi
     eeb:	mov    QWORD PTR [rsp+0x50],0x0
     ef4:	mov    r9,QWORD PTR [rsp+0x78]
     ef9:	mov    QWORD PTR [rsp+0x58],r9
     efe:	mov    QWORD PTR [rsp+0x60],0x2
     f07:	mov    rax,QWORD PTR [rsp+0x80]
     f0f:	mov    QWORD PTR [rsp+0x68],rax
     f14:	mov    esi,0x3
     f19:	mov    edx,0x4
     f1e:	mov    rcx,r14
     f21:	mov    rdi,r15
     f24:	call   f29 <botlish_fn_5+0x251>
			f25: R_X86_64_PLT32	rt_construct-0x4
     f29:	test   rax,rax
     f2c:	je     f87 <botlish_fn_5+0x2af>
     f32:	mov    QWORD PTR [rsp],rbx
     f36:	mov    QWORD PTR [rsp+0x8],r13
     f3b:	mov    rsi,QWORD PTR [rsp+0x70]
     f40:	mov    QWORD PTR [rsp+0x10],rsi
     f45:	mov    QWORD PTR [rsp+0x18],rax
     f4a:	mov    QWORD PTR [rsp+0x78],rax
     f4f:	jmp    d5d <botlish_fn_5+0x85>
     f54:	mov    r9,QWORD PTR [rsp+0x78]
     f59:	lea    rcx,[rsp+0x40]
     f5e:	mov    QWORD PTR [rsp+0x40],0x0
     f67:	mov    QWORD PTR [rsp+0x48],r9
     f6c:	mov    esi,0x1
     f71:	mov    edx,0x2
     f76:	mov    rdi,r15
     f79:	call   f7e <botlish_fn_5+0x2a6>
			f7a: R_X86_64_PLT32	rt_construct-0x4
     f7e:	test   rax,rax
     f81:	jne    fbe <botlish_fn_5+0x2e6>
     f87:	xor    rax,rax
     f8a:	mov    rbx,QWORD PTR [rsp+0x90]
     f92:	mov    r12,QWORD PTR [rsp+0x98]
     f9a:	mov    r13,QWORD PTR [rsp+0xa0]
     fa2:	mov    r14,QWORD PTR [rsp+0xa8]
     faa:	mov    r15,QWORD PTR [rsp+0xb0]
     fb2:	add    rsp,0xc0
     fb9:	mov    rsp,rbp
     fbc:	pop    rbp
     fbd:	ret
     fbe:	mov    rbx,QWORD PTR [rsp+0x90]
     fc6:	mov    r12,QWORD PTR [rsp+0x98]
     fce:	mov    r13,QWORD PTR [rsp+0xa0]
     fd6:	mov    r14,QWORD PTR [rsp+0xa8]
     fde:	mov    r15,QWORD PTR [rsp+0xb0]
     fe6:	add    rsp,0xc0
     fed:	mov    rsp,rbp
     ff0:	pop    rbp
     ff1:	ret
     ff2:	add    BYTE PTR [rax],al
     ff4:	add    BYTE PTR [rax],al
     ff6:	add    BYTE PTR [rax],al
     ff8:	(bad)
     ff9:	add    BYTE PTR [rax],al
     ffb:	add    BYTE PTR [rax],al
     ffd:	add    BYTE PTR [rax],al
	...

0000000000001000 <botlish_entry_5: product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>>:
    1000:	push   rbp
    1001:	mov    rbp,rsp
    1004:	mov    rsi,QWORD PTR [rdx]
    1007:	mov    r10,QWORD PTR [rdx+0x8]
    100b:	mov    rcx,QWORD PTR [rdx+0x10]
    100f:	mov    r8,QWORD PTR [rdx+0x18]
    1013:	mov    r9,QWORD PTR [rdx+0x20]
    1017:	mov    rdx,r10
    101a:	call   101f <botlish_entry_5+0x1f>
			101b: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>
    101f:	mov    rsp,rbp
    1022:	pop    rbp
    1023:	ret

0000000000001024 <botlish_fn_6: matmul<List[List[int]], List[List[int]]>>:
    1024:	push   rbp
    1025:	mov    rbp,rsp
    1028:	sub    rsp,0x50
    102c:	mov    QWORD PTR [rsp+0x30],rbx
    1031:	mov    QWORD PTR [rsp+0x38],r12
    1036:	mov    QWORD PTR [rsp+0x40],r13
    103b:	mov    QWORD PTR [rsp+0x48],r14
    1040:	mov    r12,rdi
    1043:	mov    QWORD PTR [rsp+0x10],0x0
    104c:	mov    QWORD PTR [rsp+0x18],0x0
    1055:	mov    QWORD PTR [rsp+0x20],0x0
    105e:	mov    QWORD PTR [rsp],rsi
    1062:	mov    r13,rsi
    1065:	mov    QWORD PTR [rsp+0x8],rdx
    106a:	mov    rbx,rdx
    106d:	mov    rsi,r13
    1070:	mov    rdi,r12
    1073:	call   1078 <botlish_fn_6+0x54>
			1074: R_X86_64_PLT32	rt_list_len-0x4
    1078:	sar    rax,1
    107b:	test   rax,rax
    107e:	je     1130 <botlish_fn_6+0x10c>
    1084:	mov    QWORD PTR [rsp+0x10],0x1
    108d:	mov    rax,QWORD PTR [rbx+0x8]
    1091:	test   rax,rax
    1094:	jne    10bb <botlish_fn_6+0x97>
    109a:	mov    edx,0x1
    109f:	mov    rsi,rbx
    10a2:	mov    rdi,r12
    10a5:	call   10aa <botlish_fn_6+0x86>
			10a6: R_X86_64_PLT32	rt_list_get-0x4
    10aa:	test   rax,rax
    10ad:	je     1147 <botlish_fn_6+0x123>
    10b3:	mov    rsi,rax
    10b6:	jmp    10c5 <botlish_fn_6+0xa1>
    10bb:	mov    rdx,rbx
    10be:	mov    rax,QWORD PTR [rdx+0x10]
    10c2:	mov    rsi,QWORD PTR [rax]
    10c5:	mov    rdi,r12
    10c8:	call   10cd <botlish_fn_6+0xa9>
			10c9: R_X86_64_PLT32	rt_list_len-0x4
    10cd:	mov    QWORD PTR [rsp+0x18],rax
    10d2:	mov    r14,rax
    10d5:	xor    rdx,rdx
    10d8:	mov    rdi,r12
    10db:	mov    rsi,rdx
    10de:	call   10e3 <botlish_fn_6+0xbf>
			10df: R_X86_64_PLT32	rt_list_new-0x4
    10e3:	test   rax,rax
    10e6:	je     1147 <botlish_fn_6+0x123>
    10ec:	mov    QWORD PTR [rsp+0x20],rax
    10f1:	mov    r9,rax
    10f4:	mov    ecx,0x1
    10f9:	mov    rdx,rbx
    10fc:	mov    rsi,r13
    10ff:	mov    rdi,r12
    1102:	mov    r8,r14
    1105:	call   110a <botlish_fn_6+0xe6>
			1106: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[never]>
    110a:	test   rax,rax
    110d:	je     1147 <botlish_fn_6+0x123>
    1113:	mov    rbx,QWORD PTR [rsp+0x30]
    1118:	mov    r12,QWORD PTR [rsp+0x38]
    111d:	mov    r13,QWORD PTR [rsp+0x40]
    1122:	mov    r14,QWORD PTR [rsp+0x48]
    1127:	add    rsp,0x50
    112b:	mov    rsp,rbp
    112e:	pop    rbp
    112f:	ret
    1130:	xor    rdx,rdx
    1133:	mov    rdi,r12
    1136:	mov    rsi,rdx
    1139:	call   113e <botlish_fn_6+0x11a>
			113a: R_X86_64_PLT32	rt_list_new-0x4
    113e:	test   rax,rax
    1141:	jne    1167 <botlish_fn_6+0x143>
    1147:	xor    rax,rax
    114a:	mov    rbx,QWORD PTR [rsp+0x30]
    114f:	mov    r12,QWORD PTR [rsp+0x38]
    1154:	mov    r13,QWORD PTR [rsp+0x40]
    1159:	mov    r14,QWORD PTR [rsp+0x48]
    115e:	add    rsp,0x50
    1162:	mov    rsp,rbp
    1165:	pop    rbp
    1166:	ret
    1167:	mov    rbx,QWORD PTR [rsp+0x30]
    116c:	mov    r12,QWORD PTR [rsp+0x38]
    1171:	mov    r13,QWORD PTR [rsp+0x40]
    1176:	mov    r14,QWORD PTR [rsp+0x48]
    117b:	add    rsp,0x50
    117f:	mov    rsp,rbp
    1182:	pop    rbp
    1183:	ret

0000000000001184 <botlish_entry_6: matmul<List[List[int]], List[List[int]]>>:
    1184:	push   rbp
    1185:	mov    rbp,rsp
    1188:	mov    rsi,QWORD PTR [rdx]
    118b:	mov    rdx,QWORD PTR [rdx+0x8]
    118f:	call   1194 <botlish_entry_6+0x10>
			1190: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<List[List[int]], List[List[int]]>
    1194:	mov    rsp,rbp
    1197:	pop    rbp
    1198:	ret

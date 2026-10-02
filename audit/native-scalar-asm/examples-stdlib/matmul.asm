; source:  examples/stdlib/matmul.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 4683  (per function: 750 703 545 772 613 892 408)
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
      f2:	mov    rsi,r12
      f5:	mov    QWORD PTR [rsp+0x58],rsi
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
     24c:	jne    281 <botlish_fn_0+0x281>
     252:	xor    rax,rax
     255:	mov    rbx,QWORD PTR [rsp+0xb0]
     25d:	mov    r12,QWORD PTR [rsp+0xb8]
     265:	mov    r13,QWORD PTR [rsp+0xc0]
     26d:	mov    r14,QWORD PTR [rsp+0xc8]
     275:	add    rsp,0xd0
     27c:	mov    rsp,rbp
     27f:	pop    rbp
     280:	ret
     281:	mov    rbx,QWORD PTR [rsp+0xb0]
     289:	mov    r12,QWORD PTR [rsp+0xb8]
     291:	mov    r13,QWORD PTR [rsp+0xc0]
     299:	mov    r14,QWORD PTR [rsp+0xc8]
     2a1:	add    rsp,0xd0
     2a8:	mov    rsp,rbp
     2ab:	pop    rbp
     2ac:	ret

00000000000002ad <botlish_entry_0: <program entry>>:
     2ad:	push   rbp
     2ae:	mov    rbp,rsp
     2b1:	call   2b6 <botlish_entry_0+0x9>
			2b2: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     2b6:	mov    rsp,rbp
     2b9:	pop    rbp
     2ba:	ret

00000000000002bb <botlish_fn_1: dot<List[int], List[List[int]], int, int, int, int>>:
     2bb:	push   rbp
     2bc:	mov    rbp,rsp
     2bf:	sub    rsp,0x80
     2c6:	mov    QWORD PTR [rsp+0x50],rbx
     2cb:	mov    QWORD PTR [rsp+0x58],r12
     2d0:	mov    QWORD PTR [rsp+0x60],r13
     2d5:	mov    QWORD PTR [rsp+0x68],r14
     2da:	mov    QWORD PTR [rsp+0x70],r15
     2df:	mov    QWORD PTR [rsp+0x30],rdi
     2e4:	mov    QWORD PTR [rsp+0x38],r9
     2e9:	mov    rdi,QWORD PTR [rbp+0x10]
     2ed:	mov    QWORD PTR [rsp],rsi
     2f1:	mov    r9,rsi
     2f4:	mov    QWORD PTR [rsp+0x8],rdx
     2f9:	mov    r14,rdx
     2fc:	mov    QWORD PTR [rsp+0x10],rcx
     301:	mov    QWORD PTR [rsp+0x18],rdi
     306:	sar    r8,1
     309:	mov    rbx,rcx
     30c:	sar    rbx,1
     30f:	mov    r15,rcx
     312:	mov    rsi,QWORD PTR [rsp+0x38]
     317:	mov    r12,r8
     31a:	mov    QWORD PTR [rsp+0x40],rdi
     31f:	cmp    r12,rsi
     322:	mov    QWORD PTR [rsp+0x38],rsi
     327:	je     4f5 <botlish_fn_1+0x23a>
     32d:	mov    r13,r9
     330:	mov    rdx,QWORD PTR [r13+0x8]
     334:	mov    rax,r12
     337:	shl    rax,1
     33a:	or     rax,0x1
     33e:	sar    rax,1
     341:	cmp    rax,rdx
     344:	jb     372 <botlish_fn_1+0xb7>
     34a:	mov    rdx,r12
     34d:	shl    rdx,1
     350:	or     rdx,0x1
     354:	mov    rsi,r13
     357:	mov    rdi,QWORD PTR [rsp+0x30]
     35c:	call   361 <botlish_fn_1+0xa6>
			35d: R_X86_64_PLT32	rt_list_get-0x4
     361:	test   rax,rax
     364:	je     3fe <botlish_fn_1+0x143>
     36a:	mov    rsi,rax
     36d:	jmp    37a <botlish_fn_1+0xbf>
     372:	mov    r8,QWORD PTR [r13+0x10]
     376:	mov    rsi,QWORD PTR [r8+rax*8]
     37a:	mov    QWORD PTR [rsp+0x20],rsi
     37f:	mov    QWORD PTR [rsp+0x48],rsi
     384:	mov    r11,QWORD PTR [r14+0x8]
     388:	mov    r9,r12
     38b:	shl    r9,1
     38e:	or     r9,0x1
     392:	sar    r9,1
     395:	cmp    r9,r11
     398:	jb     3c6 <botlish_fn_1+0x10b>
     39e:	mov    rdx,r12
     3a1:	shl    rdx,1
     3a4:	or     rdx,0x1
     3a8:	mov    rsi,r14
     3ab:	mov    rdi,QWORD PTR [rsp+0x30]
     3b0:	call   3b5 <botlish_fn_1+0xfa>
			3b1: R_X86_64_PLT32	rt_list_get-0x4
     3b5:	test   rax,rax
     3b8:	je     3fe <botlish_fn_1+0x143>
     3be:	mov    rsi,rax
     3c1:	jmp    3ce <botlish_fn_1+0x113>
     3c6:	mov    rax,QWORD PTR [r14+0x10]
     3ca:	mov    rsi,QWORD PTR [rax+r9*8]
     3ce:	test   r15,0x1
     3d5:	je     3e8 <botlish_fn_1+0x12d>
     3db:	mov    rax,QWORD PTR [rsi+0x8]
     3df:	cmp    rbx,rax
     3e2:	jb     42e <botlish_fn_1+0x173>
     3e8:	mov    rdx,r15
     3eb:	mov    rdi,QWORD PTR [rsp+0x30]
     3f0:	call   3f5 <botlish_fn_1+0x13a>
			3f1: R_X86_64_PLT32	rt_list_get-0x4
     3f5:	test   rax,rax
     3f8:	jne    426 <botlish_fn_1+0x16b>
     3fe:	xor    rax,rax
     401:	mov    rbx,QWORD PTR [rsp+0x50]
     406:	mov    r12,QWORD PTR [rsp+0x58]
     40b:	mov    r13,QWORD PTR [rsp+0x60]
     410:	mov    r14,QWORD PTR [rsp+0x68]
     415:	mov    r15,QWORD PTR [rsp+0x70]
     41a:	add    rsp,0x80
     421:	mov    rsp,rbp
     424:	pop    rbp
     425:	ret
     426:	mov    rdx,rax
     429:	jmp    436 <botlish_fn_1+0x17b>
     42e:	mov    rax,QWORD PTR [rsi+0x10]
     432:	mov    rdx,QWORD PTR [rax+rbx*8]
     436:	mov    QWORD PTR [rsp+0x28],rdx
     43b:	mov    rsi,QWORD PTR [rsp+0x48]
     440:	mov    rax,rsi
     443:	and    rax,rdx
     446:	test   rax,0x1
     44c:	je     481 <botlish_fn_1+0x1c6>
     452:	mov    rax,rsi
     455:	sar    rax,1
     458:	lea    rcx,[rdx-0x1]
     45c:	mov    r11,rdx
     45f:	imul   rcx
     462:	seto   cl
     465:	or     rax,0x1
     469:	test   cl,cl
     46b:	je     479 <botlish_fn_1+0x1be>
     471:	mov    rdx,r11
     474:	jmp    481 <botlish_fn_1+0x1c6>
     479:	mov    rdx,rax
     47c:	jmp    48e <botlish_fn_1+0x1d3>
     481:	mov    rdi,QWORD PTR [rsp+0x30]
     486:	call   48b <botlish_fn_1+0x1d0>
			487: R_X86_64_PLT32	rt_int_mul-0x4
     48b:	mov    rdx,rax
     48e:	mov    QWORD PTR [rsp+0x20],rdx
     493:	mov    rsi,QWORD PTR [rsp+0x40]
     498:	mov    rax,rsi
     49b:	and    rax,rdx
     49e:	test   rax,0x1
     4a4:	je     4bf <botlish_fn_1+0x204>
     4aa:	lea    rcx,[rdx-0x1]
     4ae:	mov    rax,rsi
     4b1:	add    rax,rcx
     4b4:	seto   cl
     4b7:	test   cl,cl
     4b9:	je     4c9 <botlish_fn_1+0x20e>
     4bf:	mov    rdi,QWORD PTR [rsp+0x30]
     4c4:	call   4c9 <botlish_fn_1+0x20e>
			4c5: R_X86_64_PLT32	rt_int_add-0x4
     4c9:	mov    QWORD PTR [rsp],r13
     4cd:	mov    QWORD PTR [rsp+0x8],r14
     4d2:	mov    QWORD PTR [rsp+0x10],r15
     4d7:	mov    QWORD PTR [rsp+0x18],rax
     4dc:	add    r12,0x1
     4e3:	mov    rsi,QWORD PTR [rsp+0x38]
     4e8:	mov    r9,r13
     4eb:	mov    QWORD PTR [rsp+0x40],rax
     4f0:	jmp    31f <botlish_fn_1+0x64>
     4f5:	mov    rax,QWORD PTR [rsp+0x40]
     4fa:	mov    rbx,QWORD PTR [rsp+0x50]
     4ff:	mov    r12,QWORD PTR [rsp+0x58]
     504:	mov    r13,QWORD PTR [rsp+0x60]
     509:	mov    r14,QWORD PTR [rsp+0x68]
     50e:	mov    r15,QWORD PTR [rsp+0x70]
     513:	add    rsp,0x80
     51a:	mov    rsp,rbp
     51d:	pop    rbp
     51e:	ret

000000000000051f <botlish_entry_1: dot<List[int], List[List[int]], int, int, int, int>>:
     51f:	push   rbp
     520:	mov    rbp,rsp
     523:	sub    rsp,0x10
     527:	mov    rsi,QWORD PTR [rdx]
     52a:	mov    r10,QWORD PTR [rdx+0x8]
     52e:	mov    rcx,QWORD PTR [rdx+0x10]
     532:	mov    r8,QWORD PTR [rdx+0x18]
     536:	mov    r9,QWORD PTR [rdx+0x20]
     53a:	mov    r11,QWORD PTR [rdx+0x28]
     53e:	sar    r9,1
     541:	mov    QWORD PTR [rsp],r11
     545:	mov    rdx,r10
     548:	call   54d <botlish_entry_1+0x2e>
			549: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<List[int], List[List[int]], int, int, int, int>
     54d:	add    rsp,0x10
     551:	mov    rsp,rbp
     554:	pop    rbp
     555:	ret

0000000000000556 <botlish_fn_2: product_row<List[int], List[List[int]], int, int, List[never]>>:
     556:	push   rbp
     557:	mov    rbp,rsp
     55a:	sub    rsp,0xb0
     561:	mov    QWORD PTR [rsp+0x80],rbx
     569:	mov    QWORD PTR [rsp+0x88],r12
     571:	mov    QWORD PTR [rsp+0x90],r13
     579:	mov    QWORD PTR [rsp+0x98],r14
     581:	mov    QWORD PTR [rsp+0xa0],r15
     589:	mov    QWORD PTR [rsp+0x68],rdi
     58e:	mov    QWORD PTR [rsp+0x10],rsi
     593:	mov    r15,rsi
     596:	mov    QWORD PTR [rsp+0x18],rdx
     59b:	mov    r14,rdx
     59e:	mov    QWORD PTR [rsp+0x20],rcx
     5a3:	mov    QWORD PTR [rsp+0x28],r8
     5a8:	mov    QWORD PTR [rsp+0x30],r9
     5ad:	mov    QWORD PTR [rsp+0x78],r9
     5b2:	mov    rbx,rcx
     5b5:	sar    rbx,1
     5b8:	mov    QWORD PTR [rsp+0x70],rcx
     5bd:	mov    rax,r8
     5c0:	sar    rax,1
     5c3:	mov    r13,r8
     5c6:	cmp    rbx,rax
     5c9:	je     70c <botlish_fn_2+0x1b6>
     5cf:	mov    r12d,0x1
     5d5:	mov    QWORD PTR [rsp+0x38],0x1
     5de:	mov    rsi,r15
     5e1:	mov    rdi,QWORD PTR [rsp+0x68]
     5e6:	call   5eb <botlish_fn_2+0x95>
			5e7: R_X86_64_PLT32	rt_list_len-0x4
     5eb:	mov    QWORD PTR [rsp+0x40],0x1
     5f4:	mov    r9,rax
     5f7:	sar    r9,1
     5fa:	mov    QWORD PTR [rsp],r12
     5fe:	mov    rcx,QWORD PTR [rsp+0x70]
     603:	mov    r8,r12
     606:	mov    rdx,r14
     609:	mov    rsi,r15
     60c:	mov    rdi,QWORD PTR [rsp+0x68]
     611:	call   616 <botlish_fn_2+0xc0>
			612: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<List[int], List[List[int]], int, int, int, int>
     616:	test   rax,rax
     619:	je     6a1 <botlish_fn_2+0x14b>
     61f:	mov    QWORD PTR [rsp+0x20],rax
     624:	lea    rcx,[rbx+0x1]
     628:	shl    rcx,1
     62b:	or     rcx,0x1
     62f:	mov    QWORD PTR [rsp+0x38],rcx
     634:	mov    rbx,rcx
     637:	lea    rcx,[rsp+0x48]
     63c:	mov    QWORD PTR [rsp+0x48],0x0
     645:	mov    r9,QWORD PTR [rsp+0x78]
     64a:	mov    QWORD PTR [rsp+0x50],r9
     64f:	mov    QWORD PTR [rsp+0x58],0x2
     658:	mov    QWORD PTR [rsp+0x60],rax
     65d:	mov    esi,0x3
     662:	mov    edx,0x4
     667:	mov    rdi,QWORD PTR [rsp+0x68]
     66c:	call   671 <botlish_fn_2+0x11b>
			66d: R_X86_64_PLT32	rt_construct-0x4
     671:	test   rax,rax
     674:	je     6a1 <botlish_fn_2+0x14b>
     67a:	mov    QWORD PTR [rsp+0x20],rax
     67f:	mov    rcx,rbx
     682:	mov    rdx,r14
     685:	mov    rsi,r15
     688:	mov    rdi,QWORD PTR [rsp+0x68]
     68d:	mov    r8,r13
     690:	mov    r9,rax
     693:	call   698 <botlish_fn_2+0x142>
			694: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<List[int], List[List[int]], int, int, List[int]>
     698:	test   rax,rax
     69b:	jne    6d8 <botlish_fn_2+0x182>
     6a1:	xor    rax,rax
     6a4:	mov    rbx,QWORD PTR [rsp+0x80]
     6ac:	mov    r12,QWORD PTR [rsp+0x88]
     6b4:	mov    r13,QWORD PTR [rsp+0x90]
     6bc:	mov    r14,QWORD PTR [rsp+0x98]
     6c4:	mov    r15,QWORD PTR [rsp+0xa0]
     6cc:	add    rsp,0xb0
     6d3:	mov    rsp,rbp
     6d6:	pop    rbp
     6d7:	ret
     6d8:	mov    rbx,QWORD PTR [rsp+0x80]
     6e0:	mov    r12,QWORD PTR [rsp+0x88]
     6e8:	mov    r13,QWORD PTR [rsp+0x90]
     6f0:	mov    r14,QWORD PTR [rsp+0x98]
     6f8:	mov    r15,QWORD PTR [rsp+0xa0]
     700:	add    rsp,0xb0
     707:	mov    rsp,rbp
     70a:	pop    rbp
     70b:	ret
     70c:	mov    rax,QWORD PTR [rsp+0x78]
     711:	mov    rbx,QWORD PTR [rsp+0x80]
     719:	mov    r12,QWORD PTR [rsp+0x88]
     721:	mov    r13,QWORD PTR [rsp+0x90]
     729:	mov    r14,QWORD PTR [rsp+0x98]
     731:	mov    r15,QWORD PTR [rsp+0xa0]
     739:	add    rsp,0xb0
     740:	mov    rsp,rbp
     743:	pop    rbp
     744:	ret

0000000000000745 <botlish_entry_2: product_row<List[int], List[List[int]], int, int, List[never]>>:
     745:	push   rbp
     746:	mov    rbp,rsp
     749:	mov    rsi,QWORD PTR [rdx]
     74c:	mov    r10,QWORD PTR [rdx+0x8]
     750:	mov    rcx,QWORD PTR [rdx+0x10]
     754:	mov    r8,QWORD PTR [rdx+0x18]
     758:	mov    r9,QWORD PTR [rdx+0x20]
     75c:	mov    rdx,r10
     75f:	call   764 <botlish_entry_2+0x1f>
			760: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<List[int], List[List[int]], int, int, List[never]>
     764:	mov    rsp,rbp
     767:	pop    rbp
     768:	ret
     769:	add    BYTE PTR [rax],al
     76b:	add    BYTE PTR [rax],al
     76d:	add    BYTE PTR [rax],al
	...

0000000000000770 <botlish_fn_3: product_row<List[int], List[List[int]], int, int, List[int]>>:
     770:	push   rbp
     771:	mov    rbp,rsp
     774:	sub    rsp,0xc0
     77b:	mov    QWORD PTR [rsp+0x90],rbx
     783:	mov    QWORD PTR [rsp+0x98],r12
     78b:	mov    QWORD PTR [rsp+0xa0],r13
     793:	mov    QWORD PTR [rsp+0xa8],r14
     79b:	mov    QWORD PTR [rsp+0xb0],r15
     7a3:	mov    r15,rdi
     7a6:	mov    QWORD PTR [rsp+0x30],0x0
     7af:	mov    QWORD PTR [rsp+0x38],0x0
     7b8:	mov    QWORD PTR [rsp+0x10],rsi
     7bd:	mov    r12,rsi
     7c0:	mov    QWORD PTR [rsp+0x18],rdx
     7c5:	mov    QWORD PTR [rsp+0x70],rdx
     7ca:	mov    QWORD PTR [rsp+0x20],rcx
     7cf:	mov    QWORD PTR [rsp+0x28],r9
     7d4:	mov    QWORD PTR [rsp+0x80],r9
     7dc:	lea    r14,[rsp+0x50]
     7e1:	mov    rbx,r8
     7e4:	mov    rsi,rcx
     7e7:	mov    rax,rbx
     7ea:	or     rax,0x1
     7ee:	mov    rcx,rsi
     7f1:	and    rcx,rax
     7f4:	mov    QWORD PTR [rsp+0x78],rsi
     7f9:	test   rcx,0x1
     800:	jne    82f <botlish_fn_3+0xbf>
     806:	mov    rdx,rbx
     809:	or     rdx,0x1
     80d:	mov    rsi,QWORD PTR [rsp+0x78]
     812:	mov    rdi,r15
     815:	call   81a <botlish_fn_3+0xaa>
			816: R_X86_64_PLT32	rt_int_cmp-0x4
     81a:	mov    ecx,0x2
     81f:	test   rax,rax
     822:	cmove  rcx,QWORD PTR [rip+0x1fe]        # a28 <botlish_fn_3+0x2b8>
     82a:	jmp    84b <botlish_fn_3+0xdb>
     82f:	mov    rax,rbx
     832:	or     rax,0x1
     836:	mov    ecx,0x2
     83b:	mov    rsi,QWORD PTR [rsp+0x78]
     840:	cmp    rsi,rax
     843:	cmove  rcx,QWORD PTR [rip+0x1dd]        # a28 <botlish_fn_3+0x2b8>
     84b:	cmp    rcx,0x6
     84f:	je     986 <botlish_fn_3+0x216>
     855:	mov    r13d,0x1
     85b:	mov    QWORD PTR [rsp+0x30],0x1
     864:	mov    rsi,r12
     867:	mov    rdi,r15
     86a:	call   86f <botlish_fn_3+0xff>
			86b: R_X86_64_PLT32	rt_list_len-0x4
     86f:	mov    QWORD PTR [rsp+0x38],0x1
     878:	mov    r9,rax
     87b:	sar    r9,1
     87e:	mov    QWORD PTR [rsp],r13
     882:	mov    r8,r13
     885:	mov    r13,QWORD PTR [rsp+0x70]
     88a:	mov    rcx,QWORD PTR [rsp+0x78]
     88f:	mov    rdx,r13
     892:	mov    rsi,r12
     895:	mov    rdi,r15
     898:	call   89d <botlish_fn_3+0x12d>
			899: R_X86_64_PLT32	botlish_fn_1-0x4 ; dot<List[int], List[List[int]], int, int, int, int>
     89d:	test   rax,rax
     8a0:	je     9bc <botlish_fn_3+0x24c>
     8a6:	mov    QWORD PTR [rsp+0x30],rax
     8ab:	mov    QWORD PTR [rsp+0x88],rax
     8b3:	mov    QWORD PTR [rsp+0x38],0x3
     8bc:	mov    rsi,QWORD PTR [rsp+0x78]
     8c1:	test   rsi,0x1
     8c8:	je     8f2 <botlish_fn_3+0x182>
     8ce:	mov    rsi,QWORD PTR [rsp+0x78]
     8d3:	mov    rcx,rsi
     8d6:	add    rcx,0x2
     8da:	seto   dl
     8dd:	test   dl,dl
     8df:	jne    8f2 <botlish_fn_3+0x182>
     8e5:	mov    rsi,rcx
     8e8:	mov    QWORD PTR [rsp+0x78],rcx
     8ed:	jmp    90c <botlish_fn_3+0x19c>
     8f2:	mov    edx,0x3
     8f7:	mov    rsi,QWORD PTR [rsp+0x78]
     8fc:	mov    rdi,r15
     8ff:	call   904 <botlish_fn_3+0x194>
			900: R_X86_64_PLT32	rt_int_add-0x4
     904:	mov    rsi,rax
     907:	mov    QWORD PTR [rsp+0x78],rax
     90c:	mov    QWORD PTR [rsp+0x20],rsi
     911:	mov    QWORD PTR [rsp+0x50],0x0
     91a:	mov    r9,QWORD PTR [rsp+0x80]
     922:	mov    QWORD PTR [rsp+0x58],r9
     927:	mov    QWORD PTR [rsp+0x60],0x2
     930:	mov    rax,QWORD PTR [rsp+0x88]
     938:	mov    QWORD PTR [rsp+0x68],rax
     93d:	mov    esi,0x3
     942:	mov    edx,0x4
     947:	mov    rcx,r14
     94a:	mov    rdi,r15
     94d:	call   952 <botlish_fn_3+0x1e2>
			94e: R_X86_64_PLT32	rt_construct-0x4
     952:	test   rax,rax
     955:	je     9bc <botlish_fn_3+0x24c>
     95b:	mov    QWORD PTR [rsp+0x10],r12
     960:	mov    QWORD PTR [rsp+0x18],r13
     965:	mov    rsi,QWORD PTR [rsp+0x78]
     96a:	mov    QWORD PTR [rsp+0x20],rsi
     96f:	mov    QWORD PTR [rsp+0x28],rax
     974:	mov    QWORD PTR [rsp+0x70],r13
     979:	mov    QWORD PTR [rsp+0x80],rax
     981:	jmp    7e7 <botlish_fn_3+0x77>
     986:	mov    r9,QWORD PTR [rsp+0x80]
     98e:	lea    rcx,[rsp+0x40]
     993:	mov    QWORD PTR [rsp+0x40],0x0
     99c:	mov    QWORD PTR [rsp+0x48],r9
     9a1:	mov    esi,0x1
     9a6:	mov    edx,0x2
     9ab:	mov    rdi,r15
     9ae:	call   9b3 <botlish_fn_3+0x243>
			9af: R_X86_64_PLT32	rt_construct-0x4
     9b3:	test   rax,rax
     9b6:	jne    9f3 <botlish_fn_3+0x283>
     9bc:	xor    rax,rax
     9bf:	mov    rbx,QWORD PTR [rsp+0x90]
     9c7:	mov    r12,QWORD PTR [rsp+0x98]
     9cf:	mov    r13,QWORD PTR [rsp+0xa0]
     9d7:	mov    r14,QWORD PTR [rsp+0xa8]
     9df:	mov    r15,QWORD PTR [rsp+0xb0]
     9e7:	add    rsp,0xc0
     9ee:	mov    rsp,rbp
     9f1:	pop    rbp
     9f2:	ret
     9f3:	mov    rbx,QWORD PTR [rsp+0x90]
     9fb:	mov    r12,QWORD PTR [rsp+0x98]
     a03:	mov    r13,QWORD PTR [rsp+0xa0]
     a0b:	mov    r14,QWORD PTR [rsp+0xa8]
     a13:	mov    r15,QWORD PTR [rsp+0xb0]
     a1b:	add    rsp,0xc0
     a22:	mov    rsp,rbp
     a25:	pop    rbp
     a26:	ret
     a27:	add    BYTE PTR [rsi],al
     a29:	add    BYTE PTR [rax],al
     a2b:	add    BYTE PTR [rax],al
     a2d:	add    BYTE PTR [rax],al
	...

0000000000000a30 <botlish_entry_3: product_row<List[int], List[List[int]], int, int, List[int]>>:
     a30:	push   rbp
     a31:	mov    rbp,rsp
     a34:	mov    rsi,QWORD PTR [rdx]
     a37:	mov    r10,QWORD PTR [rdx+0x8]
     a3b:	mov    rcx,QWORD PTR [rdx+0x10]
     a3f:	mov    r8,QWORD PTR [rdx+0x18]
     a43:	mov    r9,QWORD PTR [rdx+0x20]
     a47:	mov    rdx,r10
     a4a:	call   a4f <botlish_entry_3+0x1f>
			a4b: R_X86_64_PLT32	botlish_fn_3-0x4 ; product_row<List[int], List[List[int]], int, int, List[int]>
     a4f:	mov    rsp,rbp
     a52:	pop    rbp
     a53:	ret

0000000000000a54 <botlish_fn_4: product_rows<List[List[int]], List[List[int]], int, int, List[never]>>:
     a54:	push   rbp
     a55:	mov    rbp,rsp
     a58:	sub    rsp,0xa0
     a5f:	mov    QWORD PTR [rsp+0x70],rbx
     a64:	mov    QWORD PTR [rsp+0x78],r12
     a69:	mov    QWORD PTR [rsp+0x80],r13
     a71:	mov    QWORD PTR [rsp+0x88],r14
     a79:	mov    QWORD PTR [rsp+0x90],r15
     a81:	mov    rbx,rcx
     a84:	mov    r15,rdi
     a87:	mov    QWORD PTR [rsp+0x30],0x0
     a90:	mov    QWORD PTR [rsp],rsi
     a94:	mov    r14,rsi
     a97:	mov    QWORD PTR [rsp+0x8],rdx
     a9c:	mov    r13,rdx
     a9f:	mov    QWORD PTR [rsp+0x10],r8
     aa4:	mov    r12,r8
     aa7:	mov    QWORD PTR [rsp+0x18],r9
     aac:	mov    QWORD PTR [rsp+0x58],r9
     ab1:	mov    rsi,r14
     ab4:	mov    rdi,r15
     ab7:	call   abc <botlish_fn_4+0x68>
			ab8: R_X86_64_PLT32	rt_list_len-0x4
     abc:	mov    rcx,rbx
     abf:	sar    rbx,1
     ac2:	sar    rax,1
     ac5:	cmp    rbx,rax
     ac8:	je     c4d <botlish_fn_4+0x1f9>
     ace:	test   rcx,0x1
     ad5:	jne    ae3 <botlish_fn_4+0x8f>
     adb:	mov    rdx,rcx
     ade:	jmp    af6 <botlish_fn_4+0xa2>
     ae3:	mov    rsi,r14
     ae6:	mov    rax,QWORD PTR [rsi+0x8]
     aea:	cmp    rbx,rax
     aed:	jb     b12 <botlish_fn_4+0xbe>
     af3:	mov    rdx,rcx
     af6:	mov    rsi,r14
     af9:	mov    rdi,r15
     afc:	call   b01 <botlish_fn_4+0xad>
			afd: R_X86_64_PLT32	rt_list_get-0x4
     b01:	test   rax,rax
     b04:	je     bee <botlish_fn_4+0x19a>
     b0a:	mov    rsi,rax
     b0d:	jmp    b1d <botlish_fn_4+0xc9>
     b12:	mov    rsi,r14
     b15:	mov    rax,QWORD PTR [rsi+0x10]
     b19:	mov    rsi,QWORD PTR [rax+rbx*8]
     b1d:	mov    QWORD PTR [rsp+0x20],rsi
     b22:	mov    QWORD PTR [rsp+0x60],rsi
     b27:	mov    QWORD PTR [rsp+0x28],0x1
     b30:	xor    rdx,rdx
     b33:	mov    rdi,r15
     b36:	mov    rsi,rdx
     b39:	call   b3e <botlish_fn_4+0xea>
			b3a: R_X86_64_PLT32	rt_list_new-0x4
     b3e:	test   rax,rax
     b41:	je     bee <botlish_fn_4+0x19a>
     b47:	mov    QWORD PTR [rsp+0x30],rax
     b4c:	mov    r9,rax
     b4f:	mov    ecx,0x1
     b54:	mov    rsi,QWORD PTR [rsp+0x60]
     b59:	mov    rdx,r13
     b5c:	mov    rdi,r15
     b5f:	mov    r8,r12
     b62:	call   b67 <botlish_fn_4+0x113>
			b63: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<List[int], List[List[int]], int, int, List[never]>
     b67:	test   rax,rax
     b6a:	je     bee <botlish_fn_4+0x19a>
     b70:	mov    QWORD PTR [rsp+0x20],rax
     b75:	lea    rcx,[rbx+0x1]
     b79:	shl    rcx,1
     b7c:	or     rcx,0x1
     b80:	mov    QWORD PTR [rsp+0x28],rcx
     b85:	mov    rbx,rcx
     b88:	lea    rcx,[rsp+0x38]
     b8d:	mov    QWORD PTR [rsp+0x38],0x0
     b96:	mov    r9,QWORD PTR [rsp+0x58]
     b9b:	mov    QWORD PTR [rsp+0x40],r9
     ba0:	mov    QWORD PTR [rsp+0x48],0x2
     ba9:	mov    QWORD PTR [rsp+0x50],rax
     bae:	mov    esi,0x3
     bb3:	mov    edx,0x4
     bb8:	mov    rdi,r15
     bbb:	call   bc0 <botlish_fn_4+0x16c>
			bbc: R_X86_64_PLT32	rt_construct-0x4
     bc0:	test   rax,rax
     bc3:	je     bee <botlish_fn_4+0x19a>
     bc9:	mov    QWORD PTR [rsp+0x18],rax
     bce:	mov    rcx,rbx
     bd1:	mov    rdx,r13
     bd4:	mov    rsi,r14
     bd7:	mov    rdi,r15
     bda:	mov    r8,r12
     bdd:	mov    r9,rax
     be0:	call   be5 <botlish_fn_4+0x191>
			be1: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>
     be5:	test   rax,rax
     be8:	jne    c1f <botlish_fn_4+0x1cb>
     bee:	xor    rax,rax
     bf1:	mov    rbx,QWORD PTR [rsp+0x70]
     bf6:	mov    r12,QWORD PTR [rsp+0x78]
     bfb:	mov    r13,QWORD PTR [rsp+0x80]
     c03:	mov    r14,QWORD PTR [rsp+0x88]
     c0b:	mov    r15,QWORD PTR [rsp+0x90]
     c13:	add    rsp,0xa0
     c1a:	mov    rsp,rbp
     c1d:	pop    rbp
     c1e:	ret
     c1f:	mov    rbx,QWORD PTR [rsp+0x70]
     c24:	mov    r12,QWORD PTR [rsp+0x78]
     c29:	mov    r13,QWORD PTR [rsp+0x80]
     c31:	mov    r14,QWORD PTR [rsp+0x88]
     c39:	mov    r15,QWORD PTR [rsp+0x90]
     c41:	add    rsp,0xa0
     c48:	mov    rsp,rbp
     c4b:	pop    rbp
     c4c:	ret
     c4d:	mov    rax,QWORD PTR [rsp+0x58]
     c52:	mov    rbx,QWORD PTR [rsp+0x70]
     c57:	mov    r12,QWORD PTR [rsp+0x78]
     c5c:	mov    r13,QWORD PTR [rsp+0x80]
     c64:	mov    r14,QWORD PTR [rsp+0x88]
     c6c:	mov    r15,QWORD PTR [rsp+0x90]
     c74:	add    rsp,0xa0
     c7b:	mov    rsp,rbp
     c7e:	pop    rbp
     c7f:	ret

0000000000000c80 <botlish_entry_4: product_rows<List[List[int]], List[List[int]], int, int, List[never]>>:
     c80:	push   rbp
     c81:	mov    rbp,rsp
     c84:	mov    rsi,QWORD PTR [rdx]
     c87:	mov    r10,QWORD PTR [rdx+0x8]
     c8b:	mov    rcx,QWORD PTR [rdx+0x10]
     c8f:	mov    r8,QWORD PTR [rdx+0x18]
     c93:	mov    r9,QWORD PTR [rdx+0x20]
     c97:	mov    rdx,r10
     c9a:	call   c9f <botlish_entry_4+0x1f>
			c9b: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[never]>
     c9f:	mov    rsp,rbp
     ca2:	pop    rbp
     ca3:	ret
     ca4:	add    BYTE PTR [rax],al
	...

0000000000000ca8 <botlish_fn_5: product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>>:
     ca8:	push   rbp
     ca9:	mov    rbp,rsp
     cac:	sub    rsp,0xc0
     cb3:	mov    QWORD PTR [rsp+0x90],rbx
     cbb:	mov    QWORD PTR [rsp+0x98],r12
     cc3:	mov    QWORD PTR [rsp+0xa0],r13
     ccb:	mov    QWORD PTR [rsp+0xa8],r14
     cd3:	mov    QWORD PTR [rsp+0xb0],r15
     cdb:	mov    r12,r8
     cde:	mov    r15,rdi
     ce1:	mov    QWORD PTR [rsp+0x20],0x0
     cea:	mov    QWORD PTR [rsp+0x28],0x0
     cf3:	mov    QWORD PTR [rsp+0x30],0x0
     cfc:	mov    QWORD PTR [rsp+0x38],0x0
     d05:	mov    QWORD PTR [rsp],rsi
     d09:	mov    QWORD PTR [rsp+0x8],rdx
     d0e:	mov    r13,rdx
     d11:	mov    QWORD PTR [rsp+0x10],rcx
     d16:	mov    QWORD PTR [rsp+0x18],r9
     d1b:	mov    QWORD PTR [rsp+0x78],r9
     d20:	lea    r14,[rsp+0x50]
     d25:	mov    rbx,rsi
     d28:	mov    QWORD PTR [rsp+0x70],rcx
     d2d:	mov    rsi,rbx
     d30:	mov    rdi,r15
     d33:	call   d38 <botlish_fn_5+0x90>
			d34: R_X86_64_PLT32	rt_list_len-0x4
     d38:	mov    rsi,QWORD PTR [rsp+0x70]
     d3d:	mov    rcx,rsi
     d40:	and    rcx,rax
     d43:	mov    rdx,rax
     d46:	test   rcx,0x1
     d4d:	jne    d75 <botlish_fn_5+0xcd>
     d53:	mov    rsi,QWORD PTR [rsp+0x70]
     d58:	mov    rdi,r15
     d5b:	call   d60 <botlish_fn_5+0xb8>
			d5c: R_X86_64_PLT32	rt_int_cmp-0x4
     d60:	mov    ecx,0x2
     d65:	test   rax,rax
     d68:	cmove  rcx,QWORD PTR [rip+0x258]        # fc8 <botlish_fn_5+0x320>
     d70:	jmp    d8a <botlish_fn_5+0xe2>
     d75:	mov    ecx,0x2
     d7a:	mov    rsi,QWORD PTR [rsp+0x70]
     d7f:	cmp    rsi,rdx
     d82:	cmove  rcx,QWORD PTR [rip+0x23e]        # fc8 <botlish_fn_5+0x320>
     d8a:	cmp    rcx,0x6
     d8e:	je     f24 <botlish_fn_5+0x27c>
     d94:	mov    rsi,QWORD PTR [rsp+0x70]
     d99:	test   rsi,0x1
     da0:	je     dbe <botlish_fn_5+0x116>
     da6:	mov    rsi,QWORD PTR [rbx+0x8]
     daa:	mov    rax,QWORD PTR [rsp+0x70]
     daf:	mov    rdx,rax
     db2:	sar    rdx,1
     db5:	cmp    rdx,rsi
     db8:	jb     ddf <botlish_fn_5+0x137>
     dbe:	mov    rdx,QWORD PTR [rsp+0x70]
     dc3:	mov    rsi,rbx
     dc6:	mov    rdi,r15
     dc9:	call   dce <botlish_fn_5+0x126>
			dca: R_X86_64_PLT32	rt_list_get-0x4
     dce:	test   rax,rax
     dd1:	je     f57 <botlish_fn_5+0x2af>
     dd7:	mov    rsi,rax
     dda:	jmp    de7 <botlish_fn_5+0x13f>
     ddf:	mov    r9,QWORD PTR [rbx+0x10]
     de3:	mov    rsi,QWORD PTR [r9+rdx*8]
     de7:	mov    QWORD PTR [rsp+0x20],rsi
     dec:	mov    QWORD PTR [rsp+0x80],rsi
     df4:	mov    QWORD PTR [rsp+0x28],0x1
     dfd:	mov    rax,r12
     e00:	or     rax,0x1
     e04:	mov    QWORD PTR [rsp+0x30],rax
     e09:	xor    rdx,rdx
     e0c:	mov    rdi,r15
     e0f:	mov    rsi,rdx
     e12:	call   e17 <botlish_fn_5+0x16f>
			e13: R_X86_64_PLT32	rt_list_new-0x4
     e17:	test   rax,rax
     e1a:	je     f57 <botlish_fn_5+0x2af>
     e20:	mov    QWORD PTR [rsp+0x38],rax
     e25:	mov    r9,rax
     e28:	mov    ecx,0x1
     e2d:	mov    r8,r12
     e30:	or     r8,0x1
     e34:	mov    rsi,QWORD PTR [rsp+0x80]
     e3c:	mov    rdx,r13
     e3f:	mov    rdi,r15
     e42:	call   e47 <botlish_fn_5+0x19f>
			e43: R_X86_64_PLT32	botlish_fn_2-0x4 ; product_row<List[int], List[List[int]], int, int, List[never]>
     e47:	test   rax,rax
     e4a:	je     f57 <botlish_fn_5+0x2af>
     e50:	mov    QWORD PTR [rsp+0x20],rax
     e55:	mov    QWORD PTR [rsp+0x80],rax
     e5d:	mov    QWORD PTR [rsp+0x28],0x3
     e66:	mov    rsi,QWORD PTR [rsp+0x70]
     e6b:	test   rsi,0x1
     e72:	je     e9c <botlish_fn_5+0x1f4>
     e78:	mov    rsi,QWORD PTR [rsp+0x70]
     e7d:	mov    rcx,rsi
     e80:	add    rcx,0x2
     e84:	seto   al
     e87:	test   al,al
     e89:	jne    e9c <botlish_fn_5+0x1f4>
     e8f:	mov    rsi,rcx
     e92:	mov    QWORD PTR [rsp+0x70],rcx
     e97:	jmp    eb6 <botlish_fn_5+0x20e>
     e9c:	mov    edx,0x3
     ea1:	mov    rsi,QWORD PTR [rsp+0x70]
     ea6:	mov    rdi,r15
     ea9:	call   eae <botlish_fn_5+0x206>
			eaa: R_X86_64_PLT32	rt_int_add-0x4
     eae:	mov    rsi,rax
     eb1:	mov    QWORD PTR [rsp+0x70],rax
     eb6:	mov    QWORD PTR [rsp+0x10],rsi
     ebb:	mov    QWORD PTR [rsp+0x50],0x0
     ec4:	mov    r9,QWORD PTR [rsp+0x78]
     ec9:	mov    QWORD PTR [rsp+0x58],r9
     ece:	mov    QWORD PTR [rsp+0x60],0x2
     ed7:	mov    rax,QWORD PTR [rsp+0x80]
     edf:	mov    QWORD PTR [rsp+0x68],rax
     ee4:	mov    esi,0x3
     ee9:	mov    edx,0x4
     eee:	mov    rcx,r14
     ef1:	mov    rdi,r15
     ef4:	call   ef9 <botlish_fn_5+0x251>
			ef5: R_X86_64_PLT32	rt_construct-0x4
     ef9:	test   rax,rax
     efc:	je     f57 <botlish_fn_5+0x2af>
     f02:	mov    QWORD PTR [rsp],rbx
     f06:	mov    QWORD PTR [rsp+0x8],r13
     f0b:	mov    rsi,QWORD PTR [rsp+0x70]
     f10:	mov    QWORD PTR [rsp+0x10],rsi
     f15:	mov    QWORD PTR [rsp+0x18],rax
     f1a:	mov    QWORD PTR [rsp+0x78],rax
     f1f:	jmp    d2d <botlish_fn_5+0x85>
     f24:	mov    r9,QWORD PTR [rsp+0x78]
     f29:	lea    rcx,[rsp+0x40]
     f2e:	mov    QWORD PTR [rsp+0x40],0x0
     f37:	mov    QWORD PTR [rsp+0x48],r9
     f3c:	mov    esi,0x1
     f41:	mov    edx,0x2
     f46:	mov    rdi,r15
     f49:	call   f4e <botlish_fn_5+0x2a6>
			f4a: R_X86_64_PLT32	rt_construct-0x4
     f4e:	test   rax,rax
     f51:	jne    f8e <botlish_fn_5+0x2e6>
     f57:	xor    rax,rax
     f5a:	mov    rbx,QWORD PTR [rsp+0x90]
     f62:	mov    r12,QWORD PTR [rsp+0x98]
     f6a:	mov    r13,QWORD PTR [rsp+0xa0]
     f72:	mov    r14,QWORD PTR [rsp+0xa8]
     f7a:	mov    r15,QWORD PTR [rsp+0xb0]
     f82:	add    rsp,0xc0
     f89:	mov    rsp,rbp
     f8c:	pop    rbp
     f8d:	ret
     f8e:	mov    rbx,QWORD PTR [rsp+0x90]
     f96:	mov    r12,QWORD PTR [rsp+0x98]
     f9e:	mov    r13,QWORD PTR [rsp+0xa0]
     fa6:	mov    r14,QWORD PTR [rsp+0xa8]
     fae:	mov    r15,QWORD PTR [rsp+0xb0]
     fb6:	add    rsp,0xc0
     fbd:	mov    rsp,rbp
     fc0:	pop    rbp
     fc1:	ret
     fc2:	add    BYTE PTR [rax],al
     fc4:	add    BYTE PTR [rax],al
     fc6:	add    BYTE PTR [rax],al
     fc8:	(bad)
     fc9:	add    BYTE PTR [rax],al
     fcb:	add    BYTE PTR [rax],al
     fcd:	add    BYTE PTR [rax],al
	...

0000000000000fd0 <botlish_entry_5: product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>>:
     fd0:	push   rbp
     fd1:	mov    rbp,rsp
     fd4:	mov    rsi,QWORD PTR [rdx]
     fd7:	mov    r10,QWORD PTR [rdx+0x8]
     fdb:	mov    rcx,QWORD PTR [rdx+0x10]
     fdf:	mov    r8,QWORD PTR [rdx+0x18]
     fe3:	mov    r9,QWORD PTR [rdx+0x20]
     fe7:	mov    rdx,r10
     fea:	call   fef <botlish_entry_5+0x1f>
			feb: R_X86_64_PLT32	botlish_fn_5-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[List[int]]>
     fef:	mov    rsp,rbp
     ff2:	pop    rbp
     ff3:	ret

0000000000000ff4 <botlish_fn_6: matmul<List[List[int]], List[List[int]]>>:
     ff4:	push   rbp
     ff5:	mov    rbp,rsp
     ff8:	sub    rsp,0x50
     ffc:	mov    QWORD PTR [rsp+0x30],rbx
    1001:	mov    QWORD PTR [rsp+0x38],r12
    1006:	mov    QWORD PTR [rsp+0x40],r13
    100b:	mov    QWORD PTR [rsp+0x48],r14
    1010:	mov    r12,rdi
    1013:	mov    QWORD PTR [rsp+0x10],0x0
    101c:	mov    QWORD PTR [rsp+0x18],0x0
    1025:	mov    QWORD PTR [rsp+0x20],0x0
    102e:	mov    QWORD PTR [rsp],rsi
    1032:	mov    r13,rsi
    1035:	mov    QWORD PTR [rsp+0x8],rdx
    103a:	mov    rbx,rdx
    103d:	mov    rsi,r13
    1040:	mov    rdi,r12
    1043:	call   1048 <botlish_fn_6+0x54>
			1044: R_X86_64_PLT32	rt_list_len-0x4
    1048:	sar    rax,1
    104b:	test   rax,rax
    104e:	je     1100 <botlish_fn_6+0x10c>
    1054:	mov    QWORD PTR [rsp+0x10],0x1
    105d:	mov    rax,QWORD PTR [rbx+0x8]
    1061:	test   rax,rax
    1064:	jne    108b <botlish_fn_6+0x97>
    106a:	mov    edx,0x1
    106f:	mov    rsi,rbx
    1072:	mov    rdi,r12
    1075:	call   107a <botlish_fn_6+0x86>
			1076: R_X86_64_PLT32	rt_list_get-0x4
    107a:	test   rax,rax
    107d:	je     1117 <botlish_fn_6+0x123>
    1083:	mov    rsi,rax
    1086:	jmp    1095 <botlish_fn_6+0xa1>
    108b:	mov    rdx,rbx
    108e:	mov    rax,QWORD PTR [rdx+0x10]
    1092:	mov    rsi,QWORD PTR [rax]
    1095:	mov    rdi,r12
    1098:	call   109d <botlish_fn_6+0xa9>
			1099: R_X86_64_PLT32	rt_list_len-0x4
    109d:	mov    QWORD PTR [rsp+0x18],rax
    10a2:	mov    r14,rax
    10a5:	xor    rdx,rdx
    10a8:	mov    rdi,r12
    10ab:	mov    rsi,rdx
    10ae:	call   10b3 <botlish_fn_6+0xbf>
			10af: R_X86_64_PLT32	rt_list_new-0x4
    10b3:	test   rax,rax
    10b6:	je     1117 <botlish_fn_6+0x123>
    10bc:	mov    QWORD PTR [rsp+0x20],rax
    10c1:	mov    r9,rax
    10c4:	mov    ecx,0x1
    10c9:	mov    rdx,rbx
    10cc:	mov    rsi,r13
    10cf:	mov    rdi,r12
    10d2:	mov    r8,r14
    10d5:	call   10da <botlish_fn_6+0xe6>
			10d6: R_X86_64_PLT32	botlish_fn_4-0x4 ; product_rows<List[List[int]], List[List[int]], int, int, List[never]>
    10da:	test   rax,rax
    10dd:	je     1117 <botlish_fn_6+0x123>
    10e3:	mov    rbx,QWORD PTR [rsp+0x30]
    10e8:	mov    r12,QWORD PTR [rsp+0x38]
    10ed:	mov    r13,QWORD PTR [rsp+0x40]
    10f2:	mov    r14,QWORD PTR [rsp+0x48]
    10f7:	add    rsp,0x50
    10fb:	mov    rsp,rbp
    10fe:	pop    rbp
    10ff:	ret
    1100:	xor    rdx,rdx
    1103:	mov    rdi,r12
    1106:	mov    rsi,rdx
    1109:	call   110e <botlish_fn_6+0x11a>
			110a: R_X86_64_PLT32	rt_list_new-0x4
    110e:	test   rax,rax
    1111:	jne    1137 <botlish_fn_6+0x143>
    1117:	xor    rax,rax
    111a:	mov    rbx,QWORD PTR [rsp+0x30]
    111f:	mov    r12,QWORD PTR [rsp+0x38]
    1124:	mov    r13,QWORD PTR [rsp+0x40]
    1129:	mov    r14,QWORD PTR [rsp+0x48]
    112e:	add    rsp,0x50
    1132:	mov    rsp,rbp
    1135:	pop    rbp
    1136:	ret
    1137:	mov    rbx,QWORD PTR [rsp+0x30]
    113c:	mov    r12,QWORD PTR [rsp+0x38]
    1141:	mov    r13,QWORD PTR [rsp+0x40]
    1146:	mov    r14,QWORD PTR [rsp+0x48]
    114b:	add    rsp,0x50
    114f:	mov    rsp,rbp
    1152:	pop    rbp
    1153:	ret

0000000000001154 <botlish_entry_6: matmul<List[List[int]], List[List[int]]>>:
    1154:	push   rbp
    1155:	mov    rbp,rsp
    1158:	mov    rsi,QWORD PTR [rdx]
    115b:	mov    rdx,QWORD PTR [rdx+0x8]
    115f:	call   1164 <botlish_entry_6+0x10>
			1160: R_X86_64_PLT32	botlish_fn_6-0x4 ; matmul<List[List[int]], List[List[int]]>
    1164:	mov    rsp,rbp
    1167:	pop    rbp
    1168:	ret

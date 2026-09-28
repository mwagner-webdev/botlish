; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5626  (per function: 68 78 357 381 272 272 81 365 430 585 1063 352 695 456 171)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> geo_new<generic>
;   botlish_fn_2 / botlish_entry_2 -> geo_new_capacity<int, int>
;   botlish_fn_3 / botlish_entry_3 -> geo_grow<mutarray, int>
;   botlish_fn_4 / botlish_entry_4 -> geo_append<list[mutarray, int], str>
;   botlish_fn_5 / botlish_entry_5 -> geo_append<list[mutarray, int], list>
;   botlish_fn_6 / botlish_entry_6 -> geo_finish<list[mutarray, int]>
;   botlish_fn_7 / botlish_entry_7 -> peek<str, int>
;   botlish_fn_8 / botlish_entry_8 -> peek<str, int>
;   botlish_fn_9 / botlish_entry_9 -> scan_unquoted<str, int, int>
;   botlish_fn_10 / botlish_entry_10 -> scan_quoted<str, int, str>
;   botlish_fn_11 / botlish_entry_11 -> scan_field<str, int>
;   botlish_fn_12 / botlish_entry_12 -> scan_record<str, int, list[mutarray, int]>
;   botlish_fn_13 / botlish_entry_13 -> scan_records<str, int, list[mutarray, int]>
;   botlish_fn_14 / botlish_entry_14 -> csv_parse<str>


csv_geometric.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x10
       8:	mov    r8,QWORD PTR [rdi+0x10]
       c:	mov    rsi,QWORD PTR [r8]
       f:	mov    QWORD PTR [rsp],rsi
      13:	call   18 <botlish_fn_0+0x18>
			14: R_X86_64_PLT32	botlish_fn_14-0x4 ; csv_parse<str>
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

0000000000000044 <botlish_fn_1: geo_new<generic>>:
      44:	push   rbp
      45:	mov    rbp,rsp
      48:	sub    rsp,0x10
      4c:	mov    esi,0x1
      51:	mov    QWORD PTR [rsp],0x1
      59:	call   5e <botlish_fn_1+0x1a>
			5a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      5e:	test   rax,rax
      61:	jne    76 <botlish_fn_1+0x32>
      67:	xor    rdx,rdx
      6a:	mov    rax,rdx
      6d:	add    rsp,0x10
      71:	mov    rsp,rbp
      74:	pop    rbp
      75:	ret
      76:	mov    edx,0x1
      7b:	add    rsp,0x10
      7f:	mov    rsp,rbp
      82:	pop    rbp
      83:	ret

0000000000000084 <botlish_entry_1: geo_new<generic>>:
      84:	push   rbp
      85:	mov    rbp,rsp
      88:	ud2
      8a:	add    BYTE PTR [rax],al
      8c:	add    BYTE PTR [rax],al
	...

0000000000000090 <botlish_fn_2: geo_new_capacity<int, int>>:
      90:	push   rbp
      91:	mov    rbp,rsp
      94:	sub    rsp,0x40
      98:	mov    QWORD PTR [rsp+0x20],rbx
      9d:	mov    QWORD PTR [rsp+0x28],r12
      a2:	mov    QWORD PTR [rsp+0x30],r13
      a7:	mov    r12,rdi
      aa:	mov    QWORD PTR [rsp],rsi
      ae:	mov    QWORD PTR [rsp+0x8],rdx
      b3:	mov    rbx,rdx
      b6:	mov    QWORD PTR [rsp+0x10],0x5
      bf:	test   rsi,0x1
      c6:	je     e8 <botlish_fn_2+0x58>
      cc:	mov    rax,rsi
      cf:	sar    rax,1
      d2:	imul   QWORD PTR [rip+0xdf]        # 1b8 <botlish_fn_2+0x128>
      d9:	seto   cl
      dc:	or     rax,0x1
      e0:	test   cl,cl
      e2:	je     f5 <botlish_fn_2+0x65>
      e8:	mov    edx,0x5
      ed:	mov    rdi,r12
      f0:	call   f5 <botlish_fn_2+0x65>
			f1: R_X86_64_PLT32	rt_int_mul-0x4
      f5:	mov    rcx,rax
      f8:	and    rcx,rbx
      fb:	mov    r13,rax
      fe:	test   rcx,0x1
     105:	jne    131 <botlish_fn_2+0xa1>
     10b:	mov    rdx,rbx
     10e:	mov    rsi,r13
     111:	mov    rdi,r12
     114:	call   119 <botlish_fn_2+0x89>
			115: R_X86_64_PLT32	rt_int_cmp-0x4
     119:	mov    ecx,0x2
     11e:	test   rax,rax
     121:	cmovle rcx,QWORD PTR [rip+0x97]        # 1c0 <botlish_fn_2+0x130>
     129:	mov    rax,r13
     12c:	jmp    144 <botlish_fn_2+0xb4>
     131:	mov    ecx,0x2
     136:	mov    rax,r13
     139:	cmp    rax,rbx
     13c:	cmovle rcx,QWORD PTR [rip+0x7c]        # 1c0 <botlish_fn_2+0x130>
     144:	cmp    rcx,0x6
     148:	je     166 <botlish_fn_2+0xd6>
     14e:	mov    rbx,QWORD PTR [rsp+0x20]
     153:	mov    r12,QWORD PTR [rsp+0x28]
     158:	mov    r13,QWORD PTR [rsp+0x30]
     15d:	add    rsp,0x40
     161:	mov    rsp,rbp
     164:	pop    rbp
     165:	ret
     166:	mov    QWORD PTR [rsp],0x3
     16e:	test   rbx,0x1
     175:	je     18d <botlish_fn_2+0xfd>
     17b:	mov    rax,rbx
     17e:	add    rax,0x2
     182:	seto   cl
     185:	test   cl,cl
     187:	je     19d <botlish_fn_2+0x10d>
     18d:	mov    edx,0x3
     192:	mov    rsi,rbx
     195:	mov    rdi,r12
     198:	call   19d <botlish_fn_2+0x10d>
			199: R_X86_64_PLT32	rt_int_add-0x4
     19d:	mov    rbx,QWORD PTR [rsp+0x20]
     1a2:	mov    r12,QWORD PTR [rsp+0x28]
     1a7:	mov    r13,QWORD PTR [rsp+0x30]
     1ac:	add    rsp,0x40
     1b0:	mov    rsp,rbp
     1b3:	pop    rbp
     1b4:	ret
     1b5:	add    BYTE PTR [rax],al
     1b7:	add    BYTE PTR [rax+rax*1],al
     1ba:	add    BYTE PTR [rax],al
     1bc:	add    BYTE PTR [rax],al
     1be:	add    BYTE PTR [rax],al
     1c0:	(bad)
     1c1:	add    BYTE PTR [rax],al
     1c3:	add    BYTE PTR [rax],al
     1c5:	add    BYTE PTR [rax],al
	...

00000000000001c8 <botlish_entry_2: geo_new_capacity<int, int>>:
     1c8:	push   rbp
     1c9:	mov    rbp,rsp
     1cc:	mov    rsi,QWORD PTR [rdx]
     1cf:	mov    rdx,QWORD PTR [rdx+0x8]
     1d3:	call   1d8 <botlish_entry_2+0x10>
			1d4: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     1d8:	mov    rsp,rbp
     1db:	pop    rbp
     1dc:	ret
     1dd:	add    BYTE PTR [rax],al
	...

00000000000001e0 <botlish_fn_3: geo_grow<mutarray, int>>:
     1e0:	push   rbp
     1e1:	mov    rbp,rsp
     1e4:	sub    rsp,0x40
     1e8:	mov    QWORD PTR [rsp+0x20],rbx
     1ed:	mov    QWORD PTR [rsp+0x28],r12
     1f2:	mov    QWORD PTR [rsp+0x30],r13
     1f7:	mov    QWORD PTR [rsp+0x38],r14
     1fc:	mov    r13,rdi
     1ff:	mov    QWORD PTR [rsp],rsi
     203:	mov    r12,rsi
     206:	mov    QWORD PTR [rsp+0x8],rdx
     20b:	mov    rbx,rdx
     20e:	mov    rsi,r12
     211:	mov    rdi,r13
     214:	call   219 <botlish_fn_3+0x39>
			215: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     219:	mov    r14,rax
     21c:	mov    QWORD PTR [rsp+0x10],rax
     221:	mov    rcx,rbx
     224:	and    rcx,rax
     227:	test   rcx,0x1
     22e:	jne    25a <botlish_fn_3+0x7a>
     234:	mov    rdx,r14
     237:	mov    rsi,rbx
     23a:	mov    rdi,r13
     23d:	call   242 <botlish_fn_3+0x62>
			23e: R_X86_64_PLT32	rt_int_cmp-0x4
     242:	mov    ecx,0x2
     247:	test   rax,rax
     24a:	cmovl  rcx,QWORD PTR [rip+0xd6]        # 328 <botlish_fn_3+0x148>
     252:	mov    rax,r14
     255:	jmp    26d <botlish_fn_3+0x8d>
     25a:	mov    ecx,0x2
     25f:	mov    rax,r14
     262:	cmp    rbx,rax
     265:	cmovl  rcx,QWORD PTR [rip+0xbb]        # 328 <botlish_fn_3+0x148>
     26d:	cmp    rcx,0x6
     271:	je     304 <botlish_fn_3+0x124>
     277:	mov    rsi,rax
     27a:	mov    rdx,rbx
     27d:	mov    rdi,r13
     280:	call   285 <botlish_fn_3+0xa5>
			281: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     285:	mov    QWORD PTR [rsp+0x10],rax
     28a:	mov    rsi,rax
     28d:	mov    rdi,r13
     290:	call   295 <botlish_fn_3+0xb5>
			291: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     295:	test   rax,rax
     298:	mov    r14,rax
     29b:	je     2c4 <botlish_fn_3+0xe4>
     2a1:	mov    r8d,0x1
     2a7:	mov    rcx,r12
     2aa:	mov    rdi,r13
     2ad:	mov    r9,rbx
     2b0:	mov    rsi,r14
     2b3:	mov    rdx,r8
     2b6:	call   2bb <botlish_fn_3+0xdb>
			2b7: R_X86_64_PLT32	rt_mutarray_copy-0x4
     2bb:	test   rax,rax
     2be:	jne    2e4 <botlish_fn_3+0x104>
     2c4:	xor    rax,rax
     2c7:	mov    rbx,QWORD PTR [rsp+0x20]
     2cc:	mov    r12,QWORD PTR [rsp+0x28]
     2d1:	mov    r13,QWORD PTR [rsp+0x30]
     2d6:	mov    r14,QWORD PTR [rsp+0x38]
     2db:	add    rsp,0x40
     2df:	mov    rsp,rbp
     2e2:	pop    rbp
     2e3:	ret
     2e4:	mov    rax,r14
     2e7:	mov    rbx,QWORD PTR [rsp+0x20]
     2ec:	mov    r12,QWORD PTR [rsp+0x28]
     2f1:	mov    r13,QWORD PTR [rsp+0x30]
     2f6:	mov    r14,QWORD PTR [rsp+0x38]
     2fb:	add    rsp,0x40
     2ff:	mov    rsp,rbp
     302:	pop    rbp
     303:	ret
     304:	mov    rax,r12
     307:	mov    rbx,QWORD PTR [rsp+0x20]
     30c:	mov    r12,QWORD PTR [rsp+0x28]
     311:	mov    r13,QWORD PTR [rsp+0x30]
     316:	mov    r14,QWORD PTR [rsp+0x38]
     31b:	add    rsp,0x40
     31f:	mov    rsp,rbp
     322:	pop    rbp
     323:	ret
     324:	add    BYTE PTR [rax],al
     326:	add    BYTE PTR [rax],al
     328:	(bad)
     329:	add    BYTE PTR [rax],al
     32b:	add    BYTE PTR [rax],al
     32d:	add    BYTE PTR [rax],al
	...

0000000000000330 <botlish_entry_3: geo_grow<mutarray, int>>:
     330:	push   rbp
     331:	mov    rbp,rsp
     334:	mov    rsi,QWORD PTR [rdx]
     337:	mov    rdx,QWORD PTR [rdx+0x8]
     33b:	call   340 <botlish_entry_3+0x10>
			33c: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     340:	mov    rsp,rbp
     343:	pop    rbp
     344:	ret

0000000000000345 <botlish_fn_4: geo_append<list[mutarray, int], str>>:
     345:	push   rbp
     346:	mov    rbp,rsp
     349:	sub    rsp,0x40
     34d:	mov    QWORD PTR [rsp+0x20],rbx
     352:	mov    QWORD PTR [rsp+0x28],r12
     357:	mov    QWORD PTR [rsp+0x30],r13
     35c:	mov    r12,rdi
     35f:	mov    QWORD PTR [rsp],rsi
     363:	mov    QWORD PTR [rsp+0x8],rdx
     368:	mov    rdi,rdx
     36b:	mov    QWORD PTR [rsp+0x10],rcx
     370:	mov    r13,rcx
     373:	mov    rbx,rdi
     376:	mov    rdx,rbx
     379:	mov    rdi,r12
     37c:	call   381 <botlish_fn_4+0x3c>
			37d: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     381:	test   rax,rax
     384:	je     3ab <botlish_fn_4+0x66>
     38a:	mov    QWORD PTR [rsp],rax
     38e:	mov    rcx,r13
     391:	mov    r13,rax
     394:	mov    rdx,rbx
     397:	mov    rsi,r13
     39a:	mov    rdi,r12
     39d:	call   3a2 <botlish_fn_4+0x5d>
			39e: R_X86_64_PLT32	rt_mutarray_set-0x4
     3a2:	test   rax,rax
     3a5:	jne    3c9 <botlish_fn_4+0x84>
     3ab:	xor    rdx,rdx
     3ae:	mov    rax,rdx
     3b1:	mov    rbx,QWORD PTR [rsp+0x20]
     3b6:	mov    r12,QWORD PTR [rsp+0x28]
     3bb:	mov    r13,QWORD PTR [rsp+0x30]
     3c0:	add    rsp,0x40
     3c4:	mov    rsp,rbp
     3c7:	pop    rbp
     3c8:	ret
     3c9:	mov    QWORD PTR [rsp+0x10],0x3
     3d2:	test   rbx,0x1
     3d9:	jne    3e7 <botlish_fn_4+0xa2>
     3df:	mov    rdi,rbx
     3e2:	jmp    404 <botlish_fn_4+0xbf>
     3e7:	mov    rdx,rbx
     3ea:	add    rdx,0x2
     3ee:	mov    rdi,rbx
     3f1:	seto   al
     3f4:	test   al,al
     3f6:	jne    404 <botlish_fn_4+0xbf>
     3fc:	mov    rax,r13
     3ff:	jmp    41a <botlish_fn_4+0xd5>
     404:	mov    edx,0x3
     409:	mov    rsi,rdi
     40c:	mov    rdi,r12
     40f:	call   414 <botlish_fn_4+0xcf>
			410: R_X86_64_PLT32	rt_int_add-0x4
     414:	mov    rdx,rax
     417:	mov    rax,r13
     41a:	mov    rbx,QWORD PTR [rsp+0x20]
     41f:	mov    r12,QWORD PTR [rsp+0x28]
     424:	mov    r13,QWORD PTR [rsp+0x30]
     429:	add    rsp,0x40
     42d:	mov    rsp,rbp
     430:	pop    rbp
     431:	ret

0000000000000432 <botlish_entry_4: geo_append<list[mutarray, int], str>>:
     432:	push   rbp
     433:	mov    rbp,rsp
     436:	ud2

0000000000000438 <botlish_fn_5: geo_append<list[mutarray, int], list>>:
     438:	push   rbp
     439:	mov    rbp,rsp
     43c:	sub    rsp,0x40
     440:	mov    QWORD PTR [rsp+0x20],rbx
     445:	mov    QWORD PTR [rsp+0x28],r12
     44a:	mov    QWORD PTR [rsp+0x30],r13
     44f:	mov    r12,rdi
     452:	mov    QWORD PTR [rsp],rsi
     456:	mov    QWORD PTR [rsp+0x8],rdx
     45b:	mov    rdi,rdx
     45e:	mov    QWORD PTR [rsp+0x10],rcx
     463:	mov    r13,rcx
     466:	mov    rbx,rdi
     469:	mov    rdx,rbx
     46c:	mov    rdi,r12
     46f:	call   474 <botlish_fn_5+0x3c>
			470: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     474:	test   rax,rax
     477:	je     49e <botlish_fn_5+0x66>
     47d:	mov    QWORD PTR [rsp],rax
     481:	mov    rcx,r13
     484:	mov    r13,rax
     487:	mov    rdx,rbx
     48a:	mov    rsi,r13
     48d:	mov    rdi,r12
     490:	call   495 <botlish_fn_5+0x5d>
			491: R_X86_64_PLT32	rt_mutarray_set-0x4
     495:	test   rax,rax
     498:	jne    4bc <botlish_fn_5+0x84>
     49e:	xor    rdx,rdx
     4a1:	mov    rax,rdx
     4a4:	mov    rbx,QWORD PTR [rsp+0x20]
     4a9:	mov    r12,QWORD PTR [rsp+0x28]
     4ae:	mov    r13,QWORD PTR [rsp+0x30]
     4b3:	add    rsp,0x40
     4b7:	mov    rsp,rbp
     4ba:	pop    rbp
     4bb:	ret
     4bc:	mov    QWORD PTR [rsp+0x10],0x3
     4c5:	test   rbx,0x1
     4cc:	jne    4da <botlish_fn_5+0xa2>
     4d2:	mov    rdi,rbx
     4d5:	jmp    4f7 <botlish_fn_5+0xbf>
     4da:	mov    rdx,rbx
     4dd:	add    rdx,0x2
     4e1:	mov    rdi,rbx
     4e4:	seto   al
     4e7:	test   al,al
     4e9:	jne    4f7 <botlish_fn_5+0xbf>
     4ef:	mov    rax,r13
     4f2:	jmp    50d <botlish_fn_5+0xd5>
     4f7:	mov    edx,0x3
     4fc:	mov    rsi,rdi
     4ff:	mov    rdi,r12
     502:	call   507 <botlish_fn_5+0xcf>
			503: R_X86_64_PLT32	rt_int_add-0x4
     507:	mov    rdx,rax
     50a:	mov    rax,r13
     50d:	mov    rbx,QWORD PTR [rsp+0x20]
     512:	mov    r12,QWORD PTR [rsp+0x28]
     517:	mov    r13,QWORD PTR [rsp+0x30]
     51c:	add    rsp,0x40
     520:	mov    rsp,rbp
     523:	pop    rbp
     524:	ret

0000000000000525 <botlish_entry_5: geo_append<list[mutarray, int], list>>:
     525:	push   rbp
     526:	mov    rbp,rsp
     529:	ud2

000000000000052b <botlish_fn_6: geo_finish<list[mutarray, int]>>:
     52b:	push   rbp
     52c:	mov    rbp,rsp
     52f:	sub    rsp,0x10
     533:	mov    QWORD PTR [rsp],rsi
     537:	mov    QWORD PTR [rsp+0x8],rdx
     53c:	call   541 <botlish_fn_6+0x16>
			53d: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     541:	test   rax,rax
     544:	jne    556 <botlish_fn_6+0x2b>
     54a:	xor    rax,rax
     54d:	add    rsp,0x10
     551:	mov    rsp,rbp
     554:	pop    rbp
     555:	ret
     556:	add    rsp,0x10
     55a:	mov    rsp,rbp
     55d:	pop    rbp
     55e:	ret

000000000000055f <botlish_entry_6: geo_finish<list[mutarray, int]>>:
     55f:	push   rbp
     560:	mov    rbp,rsp
     563:	mov    rsi,QWORD PTR [rdx]
     566:	mov    rdx,QWORD PTR [rdx+0x8]
     56a:	call   56f <botlish_entry_6+0x10>
			56b: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
     56f:	mov    rsp,rbp
     572:	pop    rbp
     573:	ret
     574:	add    BYTE PTR [rax],al
	...

0000000000000578 <botlish_fn_7: peek<str, int>>:
     578:	push   rbp
     579:	mov    rbp,rsp
     57c:	sub    rsp,0x40
     580:	mov    QWORD PTR [rsp+0x20],rbx
     585:	mov    QWORD PTR [rsp+0x28],r12
     58a:	mov    QWORD PTR [rsp+0x30],r13
     58f:	mov    r13,rdi
     592:	mov    QWORD PTR [rsp],rsi
     596:	mov    r12,rsi
     599:	mov    QWORD PTR [rsp+0x8],rdx
     59e:	mov    rbx,rdx
     5a1:	mov    rsi,r12
     5a4:	mov    rdi,r13
     5a7:	call   5ac <botlish_fn_7+0x34>
			5a8: R_X86_64_PLT32	rt_str_len-0x4
     5ac:	mov    rcx,rbx
     5af:	and    rcx,rax
     5b2:	mov    rdx,rax
     5b5:	test   rcx,0x1
     5bc:	jne    5e2 <botlish_fn_7+0x6a>
     5c2:	mov    rsi,rbx
     5c5:	mov    rdi,r13
     5c8:	call   5cd <botlish_fn_7+0x55>
			5c9: R_X86_64_PLT32	rt_int_cmp-0x4
     5cd:	mov    ecx,0x2
     5d2:	test   rax,rax
     5d5:	cmovge rcx,QWORD PTR [rip+0xd3]        # 6b0 <botlish_fn_7+0x138>
     5dd:	jmp    5f2 <botlish_fn_7+0x7a>
     5e2:	mov    ecx,0x2
     5e7:	cmp    rbx,rdx
     5ea:	cmovge rcx,QWORD PTR [rip+0xbe]        # 6b0 <botlish_fn_7+0x138>
     5f2:	cmp    rcx,0x6
     5f6:	je     686 <botlish_fn_7+0x10e>
     5fc:	mov    QWORD PTR [rsp+0x10],0x3
     605:	test   rbx,0x1
     60c:	je     624 <botlish_fn_7+0xac>
     612:	mov    rcx,rbx
     615:	add    rcx,0x2
     619:	seto   al
     61c:	test   al,al
     61e:	je     637 <botlish_fn_7+0xbf>
     624:	mov    edx,0x3
     629:	mov    rsi,rbx
     62c:	mov    rdi,r13
     62f:	call   634 <botlish_fn_7+0xbc>
			630: R_X86_64_PLT32	rt_int_add-0x4
     634:	mov    rcx,rax
     637:	mov    QWORD PTR [rsp+0x10],rcx
     63c:	mov    rdx,rbx
     63f:	mov    rsi,r12
     642:	mov    rdi,r13
     645:	call   64a <botlish_fn_7+0xd2>
			646: R_X86_64_PLT32	rt_substr-0x4
     64a:	test   rax,rax
     64d:	jne    66e <botlish_fn_7+0xf6>
     653:	xor    rax,rax
     656:	mov    rbx,QWORD PTR [rsp+0x20]
     65b:	mov    r12,QWORD PTR [rsp+0x28]
     660:	mov    r13,QWORD PTR [rsp+0x30]
     665:	add    rsp,0x40
     669:	mov    rsp,rbp
     66c:	pop    rbp
     66d:	ret
     66e:	mov    rbx,QWORD PTR [rsp+0x20]
     673:	mov    r12,QWORD PTR [rsp+0x28]
     678:	mov    r13,QWORD PTR [rsp+0x30]
     67d:	add    rsp,0x40
     681:	mov    rsp,rbp
     684:	pop    rbp
     685:	ret
     686:	mov    rdi,r13
     689:	mov    rax,QWORD PTR [rdi+0x10]
     68d:	mov    rax,QWORD PTR [rax+0x8]
     691:	mov    rbx,QWORD PTR [rsp+0x20]
     696:	mov    r12,QWORD PTR [rsp+0x28]
     69b:	mov    r13,QWORD PTR [rsp+0x30]
     6a0:	add    rsp,0x40
     6a4:	mov    rsp,rbp
     6a7:	pop    rbp
     6a8:	ret
     6a9:	add    BYTE PTR [rax],al
     6ab:	add    BYTE PTR [rax],al
     6ad:	add    BYTE PTR [rax],al
     6af:	add    BYTE PTR [rsi],al
     6b1:	add    BYTE PTR [rax],al
     6b3:	add    BYTE PTR [rax],al
     6b5:	add    BYTE PTR [rax],al
	...

00000000000006b8 <botlish_entry_7: peek<str, int>>:
     6b8:	push   rbp
     6b9:	mov    rbp,rsp
     6bc:	mov    rsi,QWORD PTR [rdx]
     6bf:	mov    rdx,QWORD PTR [rdx+0x8]
     6c3:	call   6c8 <botlish_entry_7+0x10>
			6c4: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
     6c8:	mov    rsp,rbp
     6cb:	pop    rbp
     6cc:	ret
     6cd:	add    BYTE PTR [rax],al
	...

00000000000006d0 <botlish_fn_8: peek<str, int>>:
     6d0:	push   rbp
     6d1:	mov    rbp,rsp
     6d4:	sub    rsp,0x50
     6d8:	mov    QWORD PTR [rsp+0x20],rbx
     6dd:	mov    QWORD PTR [rsp+0x28],r12
     6e2:	mov    QWORD PTR [rsp+0x30],r13
     6e7:	mov    QWORD PTR [rsp+0x38],r14
     6ec:	mov    QWORD PTR [rsp+0x40],r15
     6f1:	mov    r12,rcx
     6f4:	mov    r14,rdi
     6f7:	mov    QWORD PTR [rsp],rsi
     6fb:	mov    r13,rsi
     6fe:	mov    QWORD PTR [rsp+0x8],rdx
     703:	mov    rbx,rdx
     706:	mov    rsi,r13
     709:	mov    rdi,r14
     70c:	call   711 <botlish_fn_8+0x41>
			70d: R_X86_64_PLT32	rt_str_len-0x4
     711:	mov    rcx,rbx
     714:	and    rcx,rax
     717:	mov    rdx,rax
     71a:	test   rcx,0x1
     721:	jne    747 <botlish_fn_8+0x77>
     727:	mov    rsi,rbx
     72a:	mov    rdi,r14
     72d:	call   732 <botlish_fn_8+0x62>
			72e: R_X86_64_PLT32	rt_int_cmp-0x4
     732:	mov    ecx,0x2
     737:	test   rax,rax
     73a:	cmovge rcx,QWORD PTR [rip+0x11e]        # 860 <botlish_fn_8+0x190>
     742:	jmp    757 <botlish_fn_8+0x87>
     747:	mov    ecx,0x2
     74c:	cmp    rbx,rdx
     74f:	cmovge rcx,QWORD PTR [rip+0x109]        # 860 <botlish_fn_8+0x190>
     757:	cmp    rcx,0x6
     75b:	je     81b <botlish_fn_8+0x14b>
     761:	mov    QWORD PTR [rsp+0x10],0x3
     76a:	test   rbx,0x1
     771:	je     794 <botlish_fn_8+0xc4>
     777:	mov    rax,rbx
     77a:	add    rax,0x2
     77e:	seto   cl
     781:	test   cl,cl
     783:	jne    794 <botlish_fn_8+0xc4>
     789:	mov    rdi,r14
     78c:	mov    r15,rax
     78f:	jmp    7aa <botlish_fn_8+0xda>
     794:	mov    edx,0x3
     799:	mov    rsi,rbx
     79c:	mov    rdi,r14
     79f:	call   7a4 <botlish_fn_8+0xd4>
			7a0: R_X86_64_PLT32	rt_int_add-0x4
     7a4:	mov    r15,rax
     7a7:	mov    rdi,r14
     7aa:	mov    rdi,r14
     7ad:	mov    rcx,r15
     7b0:	mov    rdx,rbx
     7b3:	mov    rsi,r13
     7b6:	call   7bb <botlish_fn_8+0xeb>
			7b7: R_X86_64_PLT32	rt_str_region_check-0x4
     7bb:	test   rax,rax
     7be:	jne    7e9 <botlish_fn_8+0x119>
     7c4:	xor    rax,rax
     7c7:	mov    rbx,QWORD PTR [rsp+0x20]
     7cc:	mov    r12,QWORD PTR [rsp+0x28]
     7d1:	mov    r13,QWORD PTR [rsp+0x30]
     7d6:	mov    r14,QWORD PTR [rsp+0x38]
     7db:	mov    r15,QWORD PTR [rsp+0x40]
     7e0:	add    rsp,0x50
     7e4:	mov    rsp,rbp
     7e7:	pop    rbp
     7e8:	ret
     7e9:	mov    rcx,r12
     7ec:	mov    QWORD PTR [rcx],rbx
     7ef:	mov    rax,r15
     7f2:	mov    QWORD PTR [rcx+0x8],rax
     7f6:	mov    rax,r13
     7f9:	mov    rbx,QWORD PTR [rsp+0x20]
     7fe:	mov    r12,QWORD PTR [rsp+0x28]
     803:	mov    r13,QWORD PTR [rsp+0x30]
     808:	mov    r14,QWORD PTR [rsp+0x38]
     80d:	mov    r15,QWORD PTR [rsp+0x40]
     812:	add    rsp,0x50
     816:	mov    rsp,rbp
     819:	pop    rbp
     81a:	ret
     81b:	mov    rcx,r12
     81e:	mov    rdi,r14
     821:	mov    rax,QWORD PTR [rdi+0x10]
     825:	mov    rax,QWORD PTR [rax+0x8]
     829:	mov    QWORD PTR [rcx],0x1
     830:	mov    QWORD PTR [rcx+0x8],0x1
     838:	mov    rbx,QWORD PTR [rsp+0x20]
     83d:	mov    r12,QWORD PTR [rsp+0x28]
     842:	mov    r13,QWORD PTR [rsp+0x30]
     847:	mov    r14,QWORD PTR [rsp+0x38]
     84c:	mov    r15,QWORD PTR [rsp+0x40]
     851:	add    rsp,0x50
     855:	mov    rsp,rbp
     858:	pop    rbp
     859:	ret
     85a:	add    BYTE PTR [rax],al
     85c:	add    BYTE PTR [rax],al
     85e:	add    BYTE PTR [rax],al
     860:	(bad)
     861:	add    BYTE PTR [rax],al
     863:	add    BYTE PTR [rax],al
     865:	add    BYTE PTR [rax],al
	...

0000000000000868 <botlish_entry_8: peek<str, int>>:
     868:	push   rbp
     869:	mov    rbp,rsp
     86c:	ud2

000000000000086e <botlish_fn_9: scan_unquoted<str, int, int>>:
     86e:	push   rbp
     86f:	mov    rbp,rsp
     872:	sub    rsp,0x80
     879:	mov    QWORD PTR [rsp+0x50],rbx
     87e:	mov    QWORD PTR [rsp+0x58],r12
     883:	mov    QWORD PTR [rsp+0x60],r13
     888:	mov    QWORD PTR [rsp+0x68],r14
     88d:	mov    QWORD PTR [rsp+0x70],r15
     892:	mov    QWORD PTR [rsp+0x30],rdi
     897:	mov    QWORD PTR [rsp+0x18],0x0
     8a0:	mov    QWORD PTR [rsp],rsi
     8a4:	mov    r15,rsi
     8a7:	mov    QWORD PTR [rsp+0x8],rdx
     8ac:	mov    r14,rdx
     8af:	mov    QWORD PTR [rsp+0x10],rcx
     8b4:	lea    r13,[rsp+0x20]
     8b9:	mov    QWORD PTR [rsp+0x38],rcx
     8be:	mov    rcx,r13
     8c1:	mov    rdx,QWORD PTR [rsp+0x38]
     8c6:	mov    rsi,r15
     8c9:	mov    rdi,QWORD PTR [rsp+0x30]
     8ce:	call   8d3 <botlish_fn_9+0x65>
			8cf: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     8d3:	mov    rsi,rax
     8d6:	mov    QWORD PTR [rsp+0x40],rax
     8db:	test   rax,rsi
     8de:	je     a38 <botlish_fn_9+0x1ca>
     8e4:	mov    rbx,QWORD PTR [rsp+0x20]
     8e9:	mov    r12,QWORD PTR [rsp+0x28]
     8ee:	mov    rdi,QWORD PTR [rsp+0x30]
     8f3:	mov    rcx,QWORD PTR [rdi+0x10]
     8f7:	mov    r8,QWORD PTR [rcx+0x8]
     8fb:	mov    rcx,r12
     8fe:	mov    rdx,rbx
     901:	mov    rsi,QWORD PTR [rsp+0x40]
     906:	call   90b <botlish_fn_9+0x9d>
			907: R_X86_64_PLT32	rt_str_region_eq-0x4
     90b:	cmp    rax,0x6
     90f:	je     950 <botlish_fn_9+0xe2>
     915:	mov    rdi,QWORD PTR [rsp+0x30]
     91a:	mov    rax,QWORD PTR [rdi+0x10]
     91e:	mov    r8,QWORD PTR [rax+0x10]
     922:	mov    rcx,r12
     925:	mov    rdx,rbx
     928:	mov    rsi,QWORD PTR [rsp+0x40]
     92d:	call   932 <botlish_fn_9+0xc4>
			92e: R_X86_64_PLT32	rt_str_region_eq-0x4
     932:	cmp    rax,0x6
     936:	je     946 <botlish_fn_9+0xd8>
     93c:	mov    eax,0x2
     941:	jmp    955 <botlish_fn_9+0xe7>
     946:	mov    eax,0x6
     94b:	jmp    955 <botlish_fn_9+0xe7>
     950:	mov    eax,0x6
     955:	cmp    rax,0x6
     959:	je     99a <botlish_fn_9+0x12c>
     95f:	mov    rdi,QWORD PTR [rsp+0x30]
     964:	mov    rax,QWORD PTR [rdi+0x10]
     968:	mov    r8,QWORD PTR [rax+0x18]
     96c:	mov    rcx,r12
     96f:	mov    rdx,rbx
     972:	mov    rsi,QWORD PTR [rsp+0x40]
     977:	call   97c <botlish_fn_9+0x10e>
			978: R_X86_64_PLT32	rt_str_region_eq-0x4
     97c:	cmp    rax,0x6
     980:	je     990 <botlish_fn_9+0x122>
     986:	mov    eax,0x2
     98b:	jmp    99f <botlish_fn_9+0x131>
     990:	mov    eax,0x6
     995:	jmp    99f <botlish_fn_9+0x131>
     99a:	mov    eax,0x6
     99f:	cmp    rax,0x6
     9a3:	je     a1a <botlish_fn_9+0x1ac>
     9a9:	mov    QWORD PTR [rsp+0x18],0x3
     9b2:	mov    rsi,QWORD PTR [rsp+0x38]
     9b7:	test   rsi,0x1
     9be:	je     9e5 <botlish_fn_9+0x177>
     9c4:	mov    rsi,QWORD PTR [rsp+0x38]
     9c9:	mov    rax,rsi
     9cc:	add    rax,0x2
     9d0:	seto   sil
     9d4:	test   sil,sil
     9d7:	jne    9e5 <botlish_fn_9+0x177>
     9dd:	mov    rsi,r15
     9e0:	jmp    9fc <botlish_fn_9+0x18e>
     9e5:	mov    edx,0x3
     9ea:	mov    rsi,QWORD PTR [rsp+0x38]
     9ef:	mov    rdi,QWORD PTR [rsp+0x30]
     9f4:	call   9f9 <botlish_fn_9+0x18b>
			9f5: R_X86_64_PLT32	rt_int_add-0x4
     9f9:	mov    rsi,r15
     9fc:	mov    QWORD PTR [rsp],rsi
     a00:	mov    rdx,r14
     a03:	mov    QWORD PTR [rsp+0x8],rdx
     a08:	mov    QWORD PTR [rsp+0x10],rax
     a0d:	mov    r15,rsi
     a10:	mov    QWORD PTR [rsp+0x38],rax
     a15:	jmp    8be <botlish_fn_9+0x50>
     a1a:	mov    rdx,r14
     a1d:	mov    rsi,r15
     a20:	mov    rdi,QWORD PTR [rsp+0x30]
     a25:	mov    rcx,QWORD PTR [rsp+0x38]
     a2a:	call   a2f <botlish_fn_9+0x1c1>
			a2b: R_X86_64_PLT32	rt_substr-0x4
     a2f:	test   rax,rax
     a32:	jne    a63 <botlish_fn_9+0x1f5>
     a38:	xor    rdx,rdx
     a3b:	mov    rax,rdx
     a3e:	mov    rbx,QWORD PTR [rsp+0x50]
     a43:	mov    r12,QWORD PTR [rsp+0x58]
     a48:	mov    r13,QWORD PTR [rsp+0x60]
     a4d:	mov    r14,QWORD PTR [rsp+0x68]
     a52:	mov    r15,QWORD PTR [rsp+0x70]
     a57:	add    rsp,0x80
     a5e:	mov    rsp,rbp
     a61:	pop    rbp
     a62:	ret
     a63:	mov    rdx,QWORD PTR [rsp+0x38]
     a68:	mov    rbx,QWORD PTR [rsp+0x50]
     a6d:	mov    r12,QWORD PTR [rsp+0x58]
     a72:	mov    r13,QWORD PTR [rsp+0x60]
     a77:	mov    r14,QWORD PTR [rsp+0x68]
     a7c:	mov    r15,QWORD PTR [rsp+0x70]
     a81:	add    rsp,0x80
     a88:	mov    rsp,rbp
     a8b:	pop    rbp
     a8c:	ret

0000000000000a8d <botlish_entry_9: scan_unquoted<str, int, int>>:
     a8d:	push   rbp
     a8e:	mov    rbp,rsp
     a91:	ud2

0000000000000a93 <botlish_fn_10: scan_quoted<str, int, str>>:
     a93:	push   rbp
     a94:	mov    rbp,rsp
     a97:	sub    rsp,0xd0
     a9e:	mov    QWORD PTR [rsp+0xa0],rbx
     aa6:	mov    QWORD PTR [rsp+0xa8],r12
     aae:	mov    QWORD PTR [rsp+0xb0],r13
     ab6:	mov    QWORD PTR [rsp+0xb8],r14
     abe:	mov    QWORD PTR [rsp+0xc0],r15
     ac6:	mov    r15,rdi
     ac9:	mov    QWORD PTR [rsp+0x18],0x0
     ad2:	mov    QWORD PTR [rsp+0x20],0x0
     adb:	mov    QWORD PTR [rsp],rsi
     adf:	mov    QWORD PTR [rsp+0x8],rdx
     ae4:	mov    QWORD PTR [rsp+0x10],rcx
     ae9:	mov    r13,rcx
     aec:	lea    r14,[rsp+0x68]
     af1:	lea    rbx,[rsp+0x28]
     af6:	mov    r12,rsi
     af9:	mov    QWORD PTR [rsp+0x88],rdx
     b01:	mov    rdx,QWORD PTR [rsp+0x88]
     b09:	mov    rsi,r12
     b0c:	mov    rdi,r15
     b0f:	call   b14 <botlish_fn_10+0x81>
			b10: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
     b14:	test   rax,rax
     b17:	je     e1b <botlish_fn_10+0x388>
     b1d:	mov    QWORD PTR [rsp+0x18],rax
     b22:	mov    rdi,r15
     b25:	mov    QWORD PTR [rsp+0x90],rax
     b2d:	mov    rsi,QWORD PTR [rdi+0x10]
     b31:	mov    rsi,QWORD PTR [rsi+0x20]
     b35:	mov    edx,0x1
     b3a:	mov    ecx,0x3
     b3f:	mov    r8,QWORD PTR [rsp+0x90]
     b47:	call   b4c <botlish_fn_10+0xb9>
			b48: R_X86_64_PLT32	rt_str_region_eq-0x4
     b4c:	cmp    rax,0x6
     b50:	je     c10 <botlish_fn_10+0x17d>
     b56:	mov    QWORD PTR [rsp+0x20],0x3
     b5f:	mov    rsi,QWORD PTR [rsp+0x88]
     b67:	test   rsi,0x1
     b6e:	je     b90 <botlish_fn_10+0xfd>
     b74:	mov    r9,rsi
     b77:	add    r9,0x2
     b7b:	seto   r11b
     b7f:	test   r11b,r11b
     b82:	jne    b90 <botlish_fn_10+0xfd>
     b88:	mov    rsi,r9
     b8b:	jmp    ba0 <botlish_fn_10+0x10d>
     b90:	mov    edx,0x3
     b95:	mov    rdi,r15
     b98:	call   b9d <botlish_fn_10+0x10a>
			b99: R_X86_64_PLT32	rt_int_add-0x4
     b9d:	mov    rsi,rax
     ba0:	mov    QWORD PTR [rsp+0x8],rsi
     ba5:	mov    QWORD PTR [rsp+0x88],rsi
     bad:	mov    QWORD PTR [rsp+0x68],0x0
     bb6:	mov    QWORD PTR [rsp+0x70],r13
     bbb:	mov    QWORD PTR [rsp+0x78],0x0
     bc4:	mov    rax,QWORD PTR [rsp+0x90]
     bcc:	mov    QWORD PTR [rsp+0x80],rax
     bd4:	mov    esi,0x2
     bd9:	mov    edx,0x4
     bde:	mov    rcx,r14
     be1:	mov    rdi,r15
     be4:	call   be9 <botlish_fn_10+0x156>
			be5: R_X86_64_PLT32	rt_construct-0x4
     be9:	test   rax,rax
     bec:	je     e1b <botlish_fn_10+0x388>
     bf2:	mov    QWORD PTR [rsp],r12
     bf6:	mov    rsi,QWORD PTR [rsp+0x88]
     bfe:	mov    QWORD PTR [rsp+0x8],rsi
     c03:	mov    QWORD PTR [rsp+0x10],rax
     c08:	mov    r13,rax
     c0b:	jmp    b01 <botlish_fn_10+0x6e>
     c10:	mov    QWORD PTR [rsp+0x18],0x3
     c19:	mov    rsi,QWORD PTR [rsp+0x88]
     c21:	test   rsi,0x1
     c28:	je     c48 <botlish_fn_10+0x1b5>
     c2e:	mov    rsi,QWORD PTR [rsp+0x88]
     c36:	mov    rdx,rsi
     c39:	add    rdx,0x2
     c3d:	seto   al
     c40:	test   al,al
     c42:	je     c60 <botlish_fn_10+0x1cd>
     c48:	mov    edx,0x3
     c4d:	mov    rsi,QWORD PTR [rsp+0x88]
     c55:	mov    rdi,r15
     c58:	call   c5d <botlish_fn_10+0x1ca>
			c59: R_X86_64_PLT32	rt_int_add-0x4
     c5d:	mov    rdx,rax
     c60:	mov    QWORD PTR [rsp+0x18],rdx
     c65:	mov    rcx,rbx
     c68:	mov    rsi,r12
     c6b:	mov    rdi,r15
     c6e:	call   c73 <botlish_fn_10+0x1e0>
			c6f: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     c73:	test   rax,rax
     c76:	mov    rsi,rax
     c79:	je     e1b <botlish_fn_10+0x388>
     c7f:	mov    rdx,QWORD PTR [rsp+0x28]
     c84:	mov    rcx,QWORD PTR [rsp+0x30]
     c89:	mov    rdi,r15
     c8c:	mov    rax,QWORD PTR [rdi+0x10]
     c90:	mov    r8,QWORD PTR [rax+0x20]
     c94:	call   c99 <botlish_fn_10+0x206>
			c95: R_X86_64_PLT32	rt_str_region_eq-0x4
     c99:	cmp    rax,0x6
     c9d:	je     d65 <botlish_fn_10+0x2d2>
     ca3:	xor    rsi,rsi
     ca6:	lea    rcx,[rsp+0x58]
     cab:	mov    QWORD PTR [rsp+0x58],0x0
     cb4:	mov    QWORD PTR [rsp+0x60],r13
     cb9:	mov    edx,0x2
     cbe:	mov    rdi,r15
     cc1:	call   cc6 <botlish_fn_10+0x233>
			cc2: R_X86_64_PLT32	rt_construct-0x4
     cc6:	test   rax,rax
     cc9:	je     e1b <botlish_fn_10+0x388>
     ccf:	mov    QWORD PTR [rsp],rax
     cd3:	mov    rbx,rax
     cd6:	mov    QWORD PTR [rsp+0x10],0x3
     cdf:	mov    rsi,QWORD PTR [rsp+0x88]
     ce7:	test   rsi,0x1
     cee:	je     d16 <botlish_fn_10+0x283>
     cf4:	mov    rsi,QWORD PTR [rsp+0x88]
     cfc:	mov    rdx,rsi
     cff:	add    rdx,0x2
     d03:	seto   al
     d06:	test   al,al
     d08:	jne    d16 <botlish_fn_10+0x283>
     d0e:	mov    rax,rbx
     d11:	jmp    d31 <botlish_fn_10+0x29e>
     d16:	mov    edx,0x3
     d1b:	mov    rsi,QWORD PTR [rsp+0x88]
     d23:	mov    rdi,r15
     d26:	call   d2b <botlish_fn_10+0x298>
			d27: R_X86_64_PLT32	rt_int_add-0x4
     d2b:	mov    rdx,rax
     d2e:	mov    rax,rbx
     d31:	mov    rbx,QWORD PTR [rsp+0xa0]
     d39:	mov    r12,QWORD PTR [rsp+0xa8]
     d41:	mov    r13,QWORD PTR [rsp+0xb0]
     d49:	mov    r14,QWORD PTR [rsp+0xb8]
     d51:	mov    r15,QWORD PTR [rsp+0xc0]
     d59:	add    rsp,0xd0
     d60:	mov    rsp,rbp
     d63:	pop    rbp
     d64:	ret
     d65:	mov    QWORD PTR [rsp+0x18],0x5
     d6e:	mov    rsi,QWORD PTR [rsp+0x88]
     d76:	test   rsi,0x1
     d7d:	je     dad <botlish_fn_10+0x31a>
     d83:	mov    rsi,QWORD PTR [rsp+0x88]
     d8b:	mov    rax,rsi
     d8e:	add    rax,0x4
     d92:	seto   cl
     d95:	test   cl,cl
     d97:	jne    dad <botlish_fn_10+0x31a>
     d9d:	mov    rsi,rax
     da0:	mov    QWORD PTR [rsp+0x88],rax
     da8:	jmp    dcd <botlish_fn_10+0x33a>
     dad:	mov    edx,0x5
     db2:	mov    rsi,QWORD PTR [rsp+0x88]
     dba:	mov    rdi,r15
     dbd:	call   dc2 <botlish_fn_10+0x32f>
			dbe: R_X86_64_PLT32	rt_int_add-0x4
     dc2:	mov    rsi,rax
     dc5:	mov    QWORD PTR [rsp+0x88],rax
     dcd:	mov    QWORD PTR [rsp+0x8],rsi
     dd2:	mov    rdi,r15
     dd5:	mov    rsi,QWORD PTR [rdi+0x10]
     dd9:	mov    rsi,QWORD PTR [rsi+0x20]
     ddd:	mov    QWORD PTR [rsp+0x18],rsi
     de2:	lea    rcx,[rsp+0x38]
     de7:	mov    QWORD PTR [rsp+0x38],0x0
     df0:	mov    QWORD PTR [rsp+0x40],r13
     df5:	mov    QWORD PTR [rsp+0x48],0x0
     dfe:	mov    QWORD PTR [rsp+0x50],rsi
     e03:	mov    esi,0x2
     e08:	mov    edx,0x4
     e0d:	call   e12 <botlish_fn_10+0x37f>
			e0e: R_X86_64_PLT32	rt_construct-0x4
     e12:	test   rax,rax
     e15:	jne    e55 <botlish_fn_10+0x3c2>
     e1b:	xor    rdx,rdx
     e1e:	mov    rax,rdx
     e21:	mov    rbx,QWORD PTR [rsp+0xa0]
     e29:	mov    r12,QWORD PTR [rsp+0xa8]
     e31:	mov    r13,QWORD PTR [rsp+0xb0]
     e39:	mov    r14,QWORD PTR [rsp+0xb8]
     e41:	mov    r15,QWORD PTR [rsp+0xc0]
     e49:	add    rsp,0xd0
     e50:	mov    rsp,rbp
     e53:	pop    rbp
     e54:	ret
     e55:	mov    QWORD PTR [rsp],r12
     e59:	mov    rsi,QWORD PTR [rsp+0x88]
     e61:	mov    QWORD PTR [rsp+0x8],rsi
     e66:	mov    QWORD PTR [rsp+0x10],rax
     e6b:	mov    r13,rax
     e6e:	jmp    b01 <botlish_fn_10+0x6e>

0000000000000e73 <botlish_entry_10: scan_quoted<str, int, str>>:
     e73:	push   rbp
     e74:	mov    rbp,rsp
     e77:	ud2

0000000000000e79 <botlish_fn_11: scan_field<str, int>>:
     e79:	push   rbp
     e7a:	mov    rbp,rsp
     e7d:	sub    rsp,0x50
     e81:	mov    QWORD PTR [rsp+0x30],rbx
     e86:	mov    QWORD PTR [rsp+0x38],r12
     e8b:	mov    QWORD PTR [rsp+0x40],r13
     e90:	mov    r12,rdi
     e93:	mov    r13,rdx
     e96:	mov    QWORD PTR [rsp+0x10],0x0
     e9f:	mov    QWORD PTR [rsp],rsi
     ea3:	mov    rbx,rsi
     ea6:	mov    QWORD PTR [rsp+0x8],rdx
     eab:	lea    rcx,[rsp+0x18]
     eb0:	mov    rdx,r13
     eb3:	mov    rsi,rbx
     eb6:	mov    rdi,r12
     eb9:	call   ebe <botlish_fn_11+0x45>
			eba: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     ebe:	test   rax,rax
     ec1:	mov    rsi,rax
     ec4:	je     f8f <botlish_fn_11+0x116>
     eca:	mov    rdx,QWORD PTR [rsp+0x18]
     ecf:	mov    rcx,QWORD PTR [rsp+0x20]
     ed4:	mov    rdi,r12
     ed7:	mov    rax,QWORD PTR [rdi+0x10]
     edb:	mov    r8,QWORD PTR [rax+0x20]
     edf:	call   ee4 <botlish_fn_11+0x6b>
			ee0: R_X86_64_PLT32	rt_str_region_eq-0x4
     ee4:	cmp    rax,0x6
     ee8:	je     f20 <botlish_fn_11+0xa7>
     eee:	mov    rcx,r13
     ef1:	mov    rsi,rbx
     ef4:	mov    rdi,r12
     ef7:	mov    rdx,rcx
     efa:	call   eff <botlish_fn_11+0x86>
			efb: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_unquoted<str, int, int>
     eff:	test   rax,rax
     f02:	je     f8f <botlish_fn_11+0x116>
     f08:	mov    rbx,QWORD PTR [rsp+0x30]
     f0d:	mov    r12,QWORD PTR [rsp+0x38]
     f12:	mov    r13,QWORD PTR [rsp+0x40]
     f17:	add    rsp,0x50
     f1b:	mov    rsp,rbp
     f1e:	pop    rbp
     f1f:	ret
     f20:	mov    rcx,r13
     f23:	mov    QWORD PTR [rsp+0x10],0x3
     f2c:	test   rcx,0x1
     f33:	jne    f41 <botlish_fn_11+0xc8>
     f39:	mov    r13,rcx
     f3c:	jmp    f56 <botlish_fn_11+0xdd>
     f41:	mov    rdx,rcx
     f44:	add    rdx,0x2
     f48:	mov    r13,rcx
     f4b:	seto   al
     f4e:	test   al,al
     f50:	je     f69 <botlish_fn_11+0xf0>
     f56:	mov    edx,0x3
     f5b:	mov    rsi,r13
     f5e:	mov    rdi,r12
     f61:	call   f66 <botlish_fn_11+0xed>
			f62: R_X86_64_PLT32	rt_int_add-0x4
     f66:	mov    rdx,rax
     f69:	mov    QWORD PTR [rsp+0x8],rdx
     f6e:	mov    rdi,r12
     f71:	mov    rax,QWORD PTR [rdi+0x10]
     f75:	mov    rcx,QWORD PTR [rax+0x8]
     f79:	mov    QWORD PTR [rsp+0x10],rcx
     f7e:	mov    rsi,rbx
     f81:	call   f86 <botlish_fn_11+0x10d>
			f82: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_quoted<str, int, str>
     f86:	test   rax,rax
     f89:	jne    fad <botlish_fn_11+0x134>
     f8f:	xor    rdx,rdx
     f92:	mov    rax,rdx
     f95:	mov    rbx,QWORD PTR [rsp+0x30]
     f9a:	mov    r12,QWORD PTR [rsp+0x38]
     f9f:	mov    r13,QWORD PTR [rsp+0x40]
     fa4:	add    rsp,0x50
     fa8:	mov    rsp,rbp
     fab:	pop    rbp
     fac:	ret
     fad:	mov    rbx,QWORD PTR [rsp+0x30]
     fb2:	mov    r12,QWORD PTR [rsp+0x38]
     fb7:	mov    r13,QWORD PTR [rsp+0x40]
     fbc:	add    rsp,0x50
     fc0:	mov    rsp,rbp
     fc3:	pop    rbp
     fc4:	ret

0000000000000fc5 <botlish_entry_11: scan_field<str, int>>:
     fc5:	push   rbp
     fc6:	mov    rbp,rsp
     fc9:	ud2

0000000000000fcb <botlish_fn_12: scan_record<str, int, list[mutarray, int]>>:
     fcb:	push   rbp
     fcc:	mov    rbp,rsp
     fcf:	sub    rsp,0x90
     fd6:	mov    QWORD PTR [rsp+0x60],rbx
     fdb:	mov    QWORD PTR [rsp+0x68],r12
     fe0:	mov    QWORD PTR [rsp+0x70],r13
     fe5:	mov    QWORD PTR [rsp+0x78],r14
     fea:	mov    QWORD PTR [rsp+0x80],r15
     ff2:	mov    r15,rdi
     ff5:	mov    QWORD PTR [rsp+0x20],0x0
     ffe:	mov    QWORD PTR [rsp],rsi
    1002:	mov    QWORD PTR [rsp+0x8],rdx
    1007:	mov    QWORD PTR [rsp+0x10],rcx
    100c:	mov    QWORD PTR [rsp+0x18],r8
    1011:	lea    r14,[rsp+0x28]
    1016:	mov    rbx,rsi
    1019:	mov    r12,r8
    101c:	mov    r13,rcx
    101f:	mov    rsi,rbx
    1022:	mov    rdi,r15
    1025:	call   102a <botlish_fn_12+0x5f>
			1026: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_field<str, int>
    102a:	test   rax,rax
    102d:	je     1148 <botlish_fn_12+0x17d>
    1033:	mov    QWORD PTR [rsp+0x8],rax
    1038:	mov    rcx,rax
    103b:	mov    QWORD PTR [rsp+0x20],rdx
    1040:	mov    QWORD PTR [rsp+0x50],rdx
    1045:	mov    rsi,r13
    1048:	mov    rdx,r12
    104b:	mov    rdi,r15
    104e:	call   1053 <botlish_fn_12+0x88>
			104f: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
    1053:	test   rax,rax
    1056:	je     1148 <botlish_fn_12+0x17d>
    105c:	mov    QWORD PTR [rsp+0x8],rax
    1061:	mov    QWORD PTR [rsp+0x40],rax
    1066:	mov    QWORD PTR [rsp+0x10],rdx
    106b:	mov    QWORD PTR [rsp+0x48],rdx
    1070:	mov    rcx,r14
    1073:	mov    rdx,QWORD PTR [rsp+0x50]
    1078:	mov    rsi,rbx
    107b:	mov    rdi,r15
    107e:	call   1083 <botlish_fn_12+0xb8>
			107f: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
    1083:	test   rax,rax
    1086:	mov    QWORD PTR [rsp+0x38],rax
    108b:	je     1148 <botlish_fn_12+0x17d>
    1091:	mov    r12,QWORD PTR [rsp+0x28]
    1096:	mov    r13,QWORD PTR [rsp+0x30]
    109b:	mov    rdi,r15
    109e:	mov    rcx,QWORD PTR [rdi+0x10]
    10a2:	mov    r8,QWORD PTR [rcx+0x10]
    10a6:	mov    rcx,r13
    10a9:	mov    rdx,r12
    10ac:	mov    rsi,QWORD PTR [rsp+0x38]
    10b1:	call   10b6 <botlish_fn_12+0xeb>
			10b2: R_X86_64_PLT32	rt_str_region_eq-0x4
    10b6:	cmp    rax,0x6
    10ba:	je     11f6 <botlish_fn_12+0x22b>
    10c0:	mov    rdi,r15
    10c3:	mov    rax,QWORD PTR [rdi+0x10]
    10c7:	mov    r8,QWORD PTR [rax+0x18]
    10cb:	mov    rcx,r13
    10ce:	mov    rdx,r12
    10d1:	mov    rsi,QWORD PTR [rsp+0x38]
    10d6:	call   10db <botlish_fn_12+0x110>
			10d7: R_X86_64_PLT32	rt_str_region_eq-0x4
    10db:	cmp    rax,0x6
    10df:	je     112d <botlish_fn_12+0x162>
    10e5:	mov    rdx,QWORD PTR [rsp+0x48]
    10ea:	mov    rsi,QWORD PTR [rsp+0x40]
    10ef:	mov    rdi,r15
    10f2:	call   10f7 <botlish_fn_12+0x12c>
			10f3: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    10f7:	test   rax,rax
    10fa:	je     1148 <botlish_fn_12+0x17d>
    1100:	mov    rdx,QWORD PTR [rsp+0x50]
    1105:	mov    rbx,QWORD PTR [rsp+0x60]
    110a:	mov    r12,QWORD PTR [rsp+0x68]
    110f:	mov    r13,QWORD PTR [rsp+0x70]
    1114:	mov    r14,QWORD PTR [rsp+0x78]
    1119:	mov    r15,QWORD PTR [rsp+0x80]
    1121:	add    rsp,0x90
    1128:	mov    rsp,rbp
    112b:	pop    rbp
    112c:	ret
    112d:	mov    rdx,QWORD PTR [rsp+0x48]
    1132:	mov    rsi,QWORD PTR [rsp+0x40]
    1137:	mov    rdi,r15
    113a:	call   113f <botlish_fn_12+0x174>
			113b: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    113f:	test   rax,rax
    1142:	jne    1176 <botlish_fn_12+0x1ab>
    1148:	xor    rdx,rdx
    114b:	mov    rax,rdx
    114e:	mov    rbx,QWORD PTR [rsp+0x60]
    1153:	mov    r12,QWORD PTR [rsp+0x68]
    1158:	mov    r13,QWORD PTR [rsp+0x70]
    115d:	mov    r14,QWORD PTR [rsp+0x78]
    1162:	mov    r15,QWORD PTR [rsp+0x80]
    116a:	add    rsp,0x90
    1171:	mov    rsp,rbp
    1174:	pop    rbp
    1175:	ret
    1176:	mov    QWORD PTR [rsp],rax
    117a:	mov    r12,rax
    117d:	mov    QWORD PTR [rsp+0x8],0x3
    1186:	mov    rdx,QWORD PTR [rsp+0x50]
    118b:	test   rdx,0x1
    1192:	je     11b6 <botlish_fn_12+0x1eb>
    1198:	mov    rdx,QWORD PTR [rsp+0x50]
    119d:	add    rdx,0x2
    11a1:	seto   r10b
    11a5:	test   r10b,r10b
    11a8:	jne    11b6 <botlish_fn_12+0x1eb>
    11ae:	mov    rax,r12
    11b1:	jmp    11ce <botlish_fn_12+0x203>
    11b6:	mov    edx,0x3
    11bb:	mov    rsi,QWORD PTR [rsp+0x50]
    11c0:	mov    rdi,r15
    11c3:	call   11c8 <botlish_fn_12+0x1fd>
			11c4: R_X86_64_PLT32	rt_int_add-0x4
    11c8:	mov    rdx,rax
    11cb:	mov    rax,r12
    11ce:	mov    rbx,QWORD PTR [rsp+0x60]
    11d3:	mov    r12,QWORD PTR [rsp+0x68]
    11d8:	mov    r13,QWORD PTR [rsp+0x70]
    11dd:	mov    r14,QWORD PTR [rsp+0x78]
    11e2:	mov    r15,QWORD PTR [rsp+0x80]
    11ea:	add    rsp,0x90
    11f1:	mov    rsp,rbp
    11f4:	pop    rbp
    11f5:	ret
    11f6:	mov    rsi,QWORD PTR [rsp+0x50]
    11fb:	mov    edx,0x3
    1200:	mov    rcx,rdx
    1203:	mov    QWORD PTR [rsp+0x18],0x3
    120c:	test   rsi,0x1
    1213:	jne    1221 <botlish_fn_12+0x256>
    1219:	mov    rdx,rcx
    121c:	jmp    1236 <botlish_fn_12+0x26b>
    1221:	mov    rdx,rsi
    1224:	add    rdx,0x2
    1228:	seto   al
    122b:	test   al,al
    122d:	je     1241 <botlish_fn_12+0x276>
    1233:	mov    rdx,rcx
    1236:	mov    rdi,r15
    1239:	call   123e <botlish_fn_12+0x273>
			123a: R_X86_64_PLT32	rt_int_add-0x4
    123e:	mov    rdx,rax
    1241:	mov    QWORD PTR [rsp],rbx
    1245:	mov    QWORD PTR [rsp+0x8],rdx
    124a:	mov    rsi,QWORD PTR [rsp+0x40]
    124f:	mov    QWORD PTR [rsp+0x10],rsi
    1254:	mov    r11,QWORD PTR [rsp+0x48]
    1259:	mov    QWORD PTR [rsp+0x18],r11
    125e:	mov    r12,r11
    1261:	mov    r13,rsi
    1264:	jmp    101f <botlish_fn_12+0x54>

0000000000001269 <botlish_entry_12: scan_record<str, int, list[mutarray, int]>>:
    1269:	push   rbp
    126a:	mov    rbp,rsp
    126d:	ud2
	...

0000000000001270 <botlish_fn_13: scan_records<str, int, list[mutarray, int]>>:
    1270:	push   rbp
    1271:	mov    rbp,rsp
    1274:	sub    rsp,0x60
    1278:	mov    QWORD PTR [rsp+0x30],rbx
    127d:	mov    QWORD PTR [rsp+0x38],r12
    1282:	mov    QWORD PTR [rsp+0x40],r13
    1287:	mov    QWORD PTR [rsp+0x48],r14
    128c:	mov    QWORD PTR [rsp+0x50],r15
    1291:	mov    r13,rdi
    1294:	mov    QWORD PTR [rsp+0x20],0x0
    129d:	mov    QWORD PTR [rsp+0x28],0x0
    12a6:	mov    QWORD PTR [rsp],rsi
    12aa:	mov    QWORD PTR [rsp+0x8],rdx
    12af:	mov    r12,rdx
    12b2:	mov    QWORD PTR [rsp+0x10],rcx
    12b7:	mov    QWORD PTR [rsp+0x18],r8
    12bc:	mov    rbx,rsi
    12bf:	mov    r14,r8
    12c2:	mov    r15,rcx
    12c5:	mov    rsi,rbx
    12c8:	mov    rdi,r13
    12cb:	call   12d0 <botlish_fn_13+0x60>
			12cc: R_X86_64_PLT32	rt_str_len-0x4
    12d0:	mov    rcx,r12
    12d3:	and    rcx,rax
    12d6:	mov    rdx,rax
    12d9:	test   rcx,0x1
    12e0:	jne    1306 <botlish_fn_13+0x96>
    12e6:	mov    rsi,r12
    12e9:	mov    rdi,r13
    12ec:	call   12f1 <botlish_fn_13+0x81>
			12ed: R_X86_64_PLT32	rt_int_cmp-0x4
    12f1:	mov    ecx,0x2
    12f6:	test   rax,rax
    12f9:	cmovge rcx,QWORD PTR [rip+0x107]        # 1408 <botlish_fn_13+0x198>
    1301:	jmp    1319 <botlish_fn_13+0xa9>
    1306:	mov    ecx,0x2
    130b:	mov    rax,r12
    130e:	cmp    rax,rdx
    1311:	cmovge rcx,QWORD PTR [rip+0xef]        # 1408 <botlish_fn_13+0x198>
    1319:	cmp    rcx,0x6
    131d:	je     13a3 <botlish_fn_13+0x133>
    1323:	mov    rdi,r13
    1326:	call   132b <botlish_fn_13+0xbb>
			1327: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    132b:	test   rax,rax
    132e:	je     13ba <botlish_fn_13+0x14a>
    1334:	mov    QWORD PTR [rsp+0x20],rax
    1339:	mov    rcx,rax
    133c:	mov    QWORD PTR [rsp+0x28],rdx
    1341:	mov    r8,rdx
    1344:	mov    rdx,r12
    1347:	mov    rsi,rbx
    134a:	mov    rdi,r13
    134d:	call   1352 <botlish_fn_13+0xe2>
			134e: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_record<str, int, list[mutarray, int]>
    1352:	test   rax,rax
    1355:	je     13ba <botlish_fn_13+0x14a>
    135b:	mov    QWORD PTR [rsp+0x8],rax
    1360:	mov    rcx,rax
    1363:	mov    QWORD PTR [rsp+0x20],rdx
    1368:	mov    r12,rdx
    136b:	mov    rsi,r15
    136e:	mov    rdx,r14
    1371:	mov    rdi,r13
    1374:	call   1379 <botlish_fn_13+0x109>
			1375: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    1379:	test   rax,rax
    137c:	je     13ba <botlish_fn_13+0x14a>
    1382:	mov    QWORD PTR [rsp],rbx
    1386:	mov    rcx,r12
    1389:	mov    QWORD PTR [rsp+0x8],rcx
    138e:	mov    QWORD PTR [rsp+0x10],rax
    1393:	mov    QWORD PTR [rsp+0x18],rdx
    1398:	mov    r14,rdx
    139b:	mov    r15,rax
    139e:	jmp    12c5 <botlish_fn_13+0x55>
    13a3:	mov    rdx,r14
    13a6:	mov    rsi,r15
    13a9:	mov    rdi,r13
    13ac:	call   13b1 <botlish_fn_13+0x141>
			13ad: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    13b1:	test   rax,rax
    13b4:	jne    13df <botlish_fn_13+0x16f>
    13ba:	xor    rax,rax
    13bd:	mov    rbx,QWORD PTR [rsp+0x30]
    13c2:	mov    r12,QWORD PTR [rsp+0x38]
    13c7:	mov    r13,QWORD PTR [rsp+0x40]
    13cc:	mov    r14,QWORD PTR [rsp+0x48]
    13d1:	mov    r15,QWORD PTR [rsp+0x50]
    13d6:	add    rsp,0x60
    13da:	mov    rsp,rbp
    13dd:	pop    rbp
    13de:	ret
    13df:	mov    rbx,QWORD PTR [rsp+0x30]
    13e4:	mov    r12,QWORD PTR [rsp+0x38]
    13e9:	mov    r13,QWORD PTR [rsp+0x40]
    13ee:	mov    r14,QWORD PTR [rsp+0x48]
    13f3:	mov    r15,QWORD PTR [rsp+0x50]
    13f8:	add    rsp,0x60
    13fc:	mov    rsp,rbp
    13ff:	pop    rbp
    1400:	ret
    1401:	add    BYTE PTR [rax],al
    1403:	add    BYTE PTR [rax],al
    1405:	add    BYTE PTR [rax],al
    1407:	add    BYTE PTR [rsi],al
    1409:	add    BYTE PTR [rax],al
    140b:	add    BYTE PTR [rax],al
    140d:	add    BYTE PTR [rax],al
	...

0000000000001410 <botlish_entry_13: scan_records<str, int, list[mutarray, int]>>:
    1410:	push   rbp
    1411:	mov    rbp,rsp
    1414:	mov    rsi,QWORD PTR [rdx]
    1417:	mov    r9,QWORD PTR [rdx+0x8]
    141b:	mov    rcx,QWORD PTR [rdx+0x10]
    141f:	mov    r8,QWORD PTR [rdx+0x18]
    1423:	mov    rdx,r9
    1426:	call   142b <botlish_entry_13+0x1b>
			1427: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    142b:	mov    rsp,rbp
    142e:	pop    rbp
    142f:	ret

0000000000001430 <botlish_fn_14: csv_parse<str>>:
    1430:	push   rbp
    1431:	mov    rbp,rsp
    1434:	sub    rsp,0x30
    1438:	mov    QWORD PTR [rsp+0x20],r12
    143d:	mov    QWORD PTR [rsp+0x28],r13
    1442:	mov    r13,rdi
    1445:	mov    QWORD PTR [rsp+0x10],0x0
    144e:	mov    QWORD PTR [rsp+0x18],0x0
    1457:	mov    QWORD PTR [rsp],rsi
    145b:	mov    r12,rsi
    145e:	mov    QWORD PTR [rsp+0x8],0x1
    1467:	mov    rdi,r13
    146a:	call   146f <botlish_fn_14+0x3f>
			146b: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    146f:	test   rax,rax
    1472:	je     14a1 <botlish_fn_14+0x71>
    1478:	mov    QWORD PTR [rsp+0x10],rax
    147d:	mov    rcx,rax
    1480:	mov    QWORD PTR [rsp+0x18],rdx
    1485:	mov    r8,rdx
    1488:	mov    edx,0x1
    148d:	mov    rsi,r12
    1490:	mov    rdi,r13
    1493:	call   1498 <botlish_fn_14+0x68>
			1494: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    1498:	test   rax,rax
    149b:	jne    14b7 <botlish_fn_14+0x87>
    14a1:	xor    rax,rax
    14a4:	mov    r12,QWORD PTR [rsp+0x20]
    14a9:	mov    r13,QWORD PTR [rsp+0x28]
    14ae:	add    rsp,0x30
    14b2:	mov    rsp,rbp
    14b5:	pop    rbp
    14b6:	ret
    14b7:	mov    r12,QWORD PTR [rsp+0x20]
    14bc:	mov    r13,QWORD PTR [rsp+0x28]
    14c1:	add    rsp,0x30
    14c5:	mov    rsp,rbp
    14c8:	pop    rbp
    14c9:	ret

00000000000014ca <botlish_entry_14: csv_parse<str>>:
    14ca:	push   rbp
    14cb:	mov    rbp,rsp
    14ce:	mov    rsi,QWORD PTR [rdx]
    14d1:	call   14d6 <botlish_entry_14+0xc>
			14d2: R_X86_64_PLT32	botlish_fn_14-0x4 ; csv_parse<str>
    14d6:	mov    rsp,rbp
    14d9:	pop    rbp
    14da:	ret

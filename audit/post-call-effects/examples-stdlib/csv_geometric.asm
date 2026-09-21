; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5333  (per function: 68 78 357 381 272 272 81 365 430 585 770 352 695 456 171)
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
     a97:	sub    rsp,0x70
     a9b:	mov    QWORD PTR [rsp+0x40],rbx
     aa0:	mov    QWORD PTR [rsp+0x48],r12
     aa5:	mov    QWORD PTR [rsp+0x50],r13
     aaa:	mov    QWORD PTR [rsp+0x58],r14
     aaf:	mov    QWORD PTR [rsp+0x60],r15
     ab4:	mov    r13,rdi
     ab7:	mov    QWORD PTR [rsp+0x18],0x0
     ac0:	mov    QWORD PTR [rsp+0x20],0x0
     ac9:	mov    QWORD PTR [rsp],rsi
     acd:	mov    QWORD PTR [rsp+0x8],rdx
     ad2:	mov    QWORD PTR [rsp+0x10],rcx
     ad7:	lea    r12,[rsp+0x28]
     adc:	mov    rbx,rsi
     adf:	mov    r14,rdx
     ae2:	mov    r15,rcx
     ae5:	mov    rdx,r14
     ae8:	mov    rsi,rbx
     aeb:	mov    rdi,r13
     aee:	call   af3 <botlish_fn_10+0x60>
			aef: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
     af3:	test   rax,rax
     af6:	je     d12 <botlish_fn_10+0x27f>
     afc:	mov    QWORD PTR [rsp+0x18],rax
     b01:	mov    rdi,r13
     b04:	mov    QWORD PTR [rsp+0x38],rax
     b09:	mov    rcx,QWORD PTR [rdi+0x10]
     b0d:	mov    rsi,QWORD PTR [rcx+0x20]
     b11:	mov    edx,0x1
     b16:	mov    ecx,0x3
     b1b:	mov    r8,QWORD PTR [rsp+0x38]
     b20:	call   b25 <botlish_fn_10+0x92>
			b21: R_X86_64_PLT32	rt_str_region_eq-0x4
     b25:	cmp    rax,0x6
     b29:	je     bac <botlish_fn_10+0x119>
     b2f:	mov    QWORD PTR [rsp+0x20],0x3
     b38:	mov    rsi,r14
     b3b:	test   rsi,0x1
     b42:	je     b62 <botlish_fn_10+0xcf>
     b48:	mov    rax,rsi
     b4b:	add    rax,0x2
     b4f:	seto   cl
     b52:	test   cl,cl
     b54:	jne    b62 <botlish_fn_10+0xcf>
     b5a:	mov    rsi,rax
     b5d:	jmp    b72 <botlish_fn_10+0xdf>
     b62:	mov    edx,0x3
     b67:	mov    rdi,r13
     b6a:	call   b6f <botlish_fn_10+0xdc>
			b6b: R_X86_64_PLT32	rt_int_add-0x4
     b6f:	mov    rsi,rax
     b72:	mov    QWORD PTR [rsp+0x8],rsi
     b77:	mov    r14,rsi
     b7a:	mov    rsi,r15
     b7d:	mov    rdx,QWORD PTR [rsp+0x38]
     b82:	mov    rdi,r13
     b85:	call   b8a <botlish_fn_10+0xf7>
			b86: R_X86_64_PLT32	rt_str_cat-0x4
     b8a:	test   rax,rax
     b8d:	je     d12 <botlish_fn_10+0x27f>
     b93:	mov    QWORD PTR [rsp],rbx
     b97:	mov    rsi,r14
     b9a:	mov    QWORD PTR [rsp+0x8],rsi
     b9f:	mov    QWORD PTR [rsp+0x10],rax
     ba4:	mov    r15,rax
     ba7:	jmp    ae5 <botlish_fn_10+0x52>
     bac:	mov    QWORD PTR [rsp+0x18],0x3
     bb5:	mov    rsi,r14
     bb8:	test   rsi,0x1
     bbf:	je     bda <botlish_fn_10+0x147>
     bc5:	mov    rsi,r14
     bc8:	mov    rdx,rsi
     bcb:	add    rdx,0x2
     bcf:	seto   al
     bd2:	test   al,al
     bd4:	je     bed <botlish_fn_10+0x15a>
     bda:	mov    edx,0x3
     bdf:	mov    rsi,r14
     be2:	mov    rdi,r13
     be5:	call   bea <botlish_fn_10+0x157>
			be6: R_X86_64_PLT32	rt_int_add-0x4
     bea:	mov    rdx,rax
     bed:	mov    QWORD PTR [rsp+0x18],rdx
     bf2:	mov    rcx,r12
     bf5:	mov    rsi,rbx
     bf8:	mov    rdi,r13
     bfb:	call   c00 <botlish_fn_10+0x16d>
			bfc: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     c00:	test   rax,rax
     c03:	mov    rsi,rax
     c06:	je     d12 <botlish_fn_10+0x27f>
     c0c:	mov    rdx,QWORD PTR [rsp+0x28]
     c11:	mov    rcx,QWORD PTR [rsp+0x30]
     c16:	mov    rdi,r13
     c19:	mov    rax,QWORD PTR [rdi+0x10]
     c1d:	mov    r8,QWORD PTR [rax+0x20]
     c21:	call   c26 <botlish_fn_10+0x193>
			c22: R_X86_64_PLT32	rt_str_region_eq-0x4
     c26:	cmp    rax,0x6
     c2a:	je     c9d <botlish_fn_10+0x20a>
     c30:	mov    QWORD PTR [rsp],0x3
     c38:	mov    rsi,r14
     c3b:	test   rsi,0x1
     c42:	je     c65 <botlish_fn_10+0x1d2>
     c48:	mov    rsi,r14
     c4b:	mov    rdx,rsi
     c4e:	add    rdx,0x2
     c52:	seto   al
     c55:	test   al,al
     c57:	jne    c65 <botlish_fn_10+0x1d2>
     c5d:	mov    rax,r15
     c60:	jmp    c7b <botlish_fn_10+0x1e8>
     c65:	mov    edx,0x3
     c6a:	mov    rsi,r14
     c6d:	mov    rdi,r13
     c70:	call   c75 <botlish_fn_10+0x1e2>
			c71: R_X86_64_PLT32	rt_int_add-0x4
     c75:	mov    rdx,rax
     c78:	mov    rax,r15
     c7b:	mov    rbx,QWORD PTR [rsp+0x40]
     c80:	mov    r12,QWORD PTR [rsp+0x48]
     c85:	mov    r13,QWORD PTR [rsp+0x50]
     c8a:	mov    r14,QWORD PTR [rsp+0x58]
     c8f:	mov    r15,QWORD PTR [rsp+0x60]
     c94:	add    rsp,0x70
     c98:	mov    rsp,rbp
     c9b:	pop    rbp
     c9c:	ret
     c9d:	mov    QWORD PTR [rsp+0x18],0x5
     ca6:	mov    rsi,r14
     ca9:	test   rsi,0x1
     cb0:	je     cd6 <botlish_fn_10+0x243>
     cb6:	mov    rsi,r14
     cb9:	mov    rax,rsi
     cbc:	add    rax,0x4
     cc0:	seto   cl
     cc3:	test   cl,cl
     cc5:	jne    cd6 <botlish_fn_10+0x243>
     ccb:	mov    rsi,rax
     cce:	mov    r14,rax
     cd1:	jmp    cec <botlish_fn_10+0x259>
     cd6:	mov    edx,0x5
     cdb:	mov    rsi,r14
     cde:	mov    rdi,r13
     ce1:	call   ce6 <botlish_fn_10+0x253>
			ce2: R_X86_64_PLT32	rt_int_add-0x4
     ce6:	mov    rsi,rax
     ce9:	mov    r14,rax
     cec:	mov    QWORD PTR [rsp+0x8],rsi
     cf1:	mov    rdi,r13
     cf4:	mov    rax,QWORD PTR [rdi+0x10]
     cf8:	mov    rdx,QWORD PTR [rax+0x20]
     cfc:	mov    QWORD PTR [rsp+0x18],rdx
     d01:	mov    rsi,r15
     d04:	call   d09 <botlish_fn_10+0x276>
			d05: R_X86_64_PLT32	rt_str_cat-0x4
     d09:	test   rax,rax
     d0c:	jne    d3a <botlish_fn_10+0x2a7>
     d12:	xor    rdx,rdx
     d15:	mov    rax,rdx
     d18:	mov    rbx,QWORD PTR [rsp+0x40]
     d1d:	mov    r12,QWORD PTR [rsp+0x48]
     d22:	mov    r13,QWORD PTR [rsp+0x50]
     d27:	mov    r14,QWORD PTR [rsp+0x58]
     d2c:	mov    r15,QWORD PTR [rsp+0x60]
     d31:	add    rsp,0x70
     d35:	mov    rsp,rbp
     d38:	pop    rbp
     d39:	ret
     d3a:	mov    QWORD PTR [rsp],rbx
     d3e:	mov    rsi,r14
     d41:	mov    QWORD PTR [rsp+0x8],rsi
     d46:	mov    QWORD PTR [rsp+0x10],rax
     d4b:	mov    r15,rax
     d4e:	jmp    ae5 <botlish_fn_10+0x52>

0000000000000d53 <botlish_entry_10: scan_quoted<str, int, str>>:
     d53:	push   rbp
     d54:	mov    rbp,rsp
     d57:	ud2

0000000000000d59 <botlish_fn_11: scan_field<str, int>>:
     d59:	push   rbp
     d5a:	mov    rbp,rsp
     d5d:	sub    rsp,0x50
     d61:	mov    QWORD PTR [rsp+0x30],rbx
     d66:	mov    QWORD PTR [rsp+0x38],r12
     d6b:	mov    QWORD PTR [rsp+0x40],r13
     d70:	mov    r12,rdi
     d73:	mov    r13,rdx
     d76:	mov    QWORD PTR [rsp+0x10],0x0
     d7f:	mov    QWORD PTR [rsp],rsi
     d83:	mov    rbx,rsi
     d86:	mov    QWORD PTR [rsp+0x8],rdx
     d8b:	lea    rcx,[rsp+0x18]
     d90:	mov    rdx,r13
     d93:	mov    rsi,rbx
     d96:	mov    rdi,r12
     d99:	call   d9e <botlish_fn_11+0x45>
			d9a: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     d9e:	test   rax,rax
     da1:	mov    rsi,rax
     da4:	je     e6f <botlish_fn_11+0x116>
     daa:	mov    rdx,QWORD PTR [rsp+0x18]
     daf:	mov    rcx,QWORD PTR [rsp+0x20]
     db4:	mov    rdi,r12
     db7:	mov    rax,QWORD PTR [rdi+0x10]
     dbb:	mov    r8,QWORD PTR [rax+0x20]
     dbf:	call   dc4 <botlish_fn_11+0x6b>
			dc0: R_X86_64_PLT32	rt_str_region_eq-0x4
     dc4:	cmp    rax,0x6
     dc8:	je     e00 <botlish_fn_11+0xa7>
     dce:	mov    rcx,r13
     dd1:	mov    rsi,rbx
     dd4:	mov    rdi,r12
     dd7:	mov    rdx,rcx
     dda:	call   ddf <botlish_fn_11+0x86>
			ddb: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_unquoted<str, int, int>
     ddf:	test   rax,rax
     de2:	je     e6f <botlish_fn_11+0x116>
     de8:	mov    rbx,QWORD PTR [rsp+0x30]
     ded:	mov    r12,QWORD PTR [rsp+0x38]
     df2:	mov    r13,QWORD PTR [rsp+0x40]
     df7:	add    rsp,0x50
     dfb:	mov    rsp,rbp
     dfe:	pop    rbp
     dff:	ret
     e00:	mov    rcx,r13
     e03:	mov    QWORD PTR [rsp+0x10],0x3
     e0c:	test   rcx,0x1
     e13:	jne    e21 <botlish_fn_11+0xc8>
     e19:	mov    r13,rcx
     e1c:	jmp    e36 <botlish_fn_11+0xdd>
     e21:	mov    rdx,rcx
     e24:	add    rdx,0x2
     e28:	mov    r13,rcx
     e2b:	seto   al
     e2e:	test   al,al
     e30:	je     e49 <botlish_fn_11+0xf0>
     e36:	mov    edx,0x3
     e3b:	mov    rsi,r13
     e3e:	mov    rdi,r12
     e41:	call   e46 <botlish_fn_11+0xed>
			e42: R_X86_64_PLT32	rt_int_add-0x4
     e46:	mov    rdx,rax
     e49:	mov    QWORD PTR [rsp+0x8],rdx
     e4e:	mov    rdi,r12
     e51:	mov    rax,QWORD PTR [rdi+0x10]
     e55:	mov    rcx,QWORD PTR [rax+0x8]
     e59:	mov    QWORD PTR [rsp+0x10],rcx
     e5e:	mov    rsi,rbx
     e61:	call   e66 <botlish_fn_11+0x10d>
			e62: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_quoted<str, int, str>
     e66:	test   rax,rax
     e69:	jne    e8d <botlish_fn_11+0x134>
     e6f:	xor    rdx,rdx
     e72:	mov    rax,rdx
     e75:	mov    rbx,QWORD PTR [rsp+0x30]
     e7a:	mov    r12,QWORD PTR [rsp+0x38]
     e7f:	mov    r13,QWORD PTR [rsp+0x40]
     e84:	add    rsp,0x50
     e88:	mov    rsp,rbp
     e8b:	pop    rbp
     e8c:	ret
     e8d:	mov    rbx,QWORD PTR [rsp+0x30]
     e92:	mov    r12,QWORD PTR [rsp+0x38]
     e97:	mov    r13,QWORD PTR [rsp+0x40]
     e9c:	add    rsp,0x50
     ea0:	mov    rsp,rbp
     ea3:	pop    rbp
     ea4:	ret

0000000000000ea5 <botlish_entry_11: scan_field<str, int>>:
     ea5:	push   rbp
     ea6:	mov    rbp,rsp
     ea9:	ud2

0000000000000eab <botlish_fn_12: scan_record<str, int, list[mutarray, int]>>:
     eab:	push   rbp
     eac:	mov    rbp,rsp
     eaf:	sub    rsp,0x90
     eb6:	mov    QWORD PTR [rsp+0x60],rbx
     ebb:	mov    QWORD PTR [rsp+0x68],r12
     ec0:	mov    QWORD PTR [rsp+0x70],r13
     ec5:	mov    QWORD PTR [rsp+0x78],r14
     eca:	mov    QWORD PTR [rsp+0x80],r15
     ed2:	mov    r15,rdi
     ed5:	mov    QWORD PTR [rsp+0x20],0x0
     ede:	mov    QWORD PTR [rsp],rsi
     ee2:	mov    QWORD PTR [rsp+0x8],rdx
     ee7:	mov    QWORD PTR [rsp+0x10],rcx
     eec:	mov    QWORD PTR [rsp+0x18],r8
     ef1:	lea    r14,[rsp+0x28]
     ef6:	mov    rbx,rsi
     ef9:	mov    r12,r8
     efc:	mov    r13,rcx
     eff:	mov    rsi,rbx
     f02:	mov    rdi,r15
     f05:	call   f0a <botlish_fn_12+0x5f>
			f06: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_field<str, int>
     f0a:	test   rax,rax
     f0d:	je     1028 <botlish_fn_12+0x17d>
     f13:	mov    QWORD PTR [rsp+0x8],rax
     f18:	mov    rcx,rax
     f1b:	mov    QWORD PTR [rsp+0x20],rdx
     f20:	mov    QWORD PTR [rsp+0x50],rdx
     f25:	mov    rsi,r13
     f28:	mov    rdx,r12
     f2b:	mov    rdi,r15
     f2e:	call   f33 <botlish_fn_12+0x88>
			f2f: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
     f33:	test   rax,rax
     f36:	je     1028 <botlish_fn_12+0x17d>
     f3c:	mov    QWORD PTR [rsp+0x8],rax
     f41:	mov    QWORD PTR [rsp+0x40],rax
     f46:	mov    QWORD PTR [rsp+0x10],rdx
     f4b:	mov    QWORD PTR [rsp+0x48],rdx
     f50:	mov    rcx,r14
     f53:	mov    rdx,QWORD PTR [rsp+0x50]
     f58:	mov    rsi,rbx
     f5b:	mov    rdi,r15
     f5e:	call   f63 <botlish_fn_12+0xb8>
			f5f: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     f63:	test   rax,rax
     f66:	mov    QWORD PTR [rsp+0x38],rax
     f6b:	je     1028 <botlish_fn_12+0x17d>
     f71:	mov    r12,QWORD PTR [rsp+0x28]
     f76:	mov    r13,QWORD PTR [rsp+0x30]
     f7b:	mov    rdi,r15
     f7e:	mov    rcx,QWORD PTR [rdi+0x10]
     f82:	mov    r8,QWORD PTR [rcx+0x10]
     f86:	mov    rcx,r13
     f89:	mov    rdx,r12
     f8c:	mov    rsi,QWORD PTR [rsp+0x38]
     f91:	call   f96 <botlish_fn_12+0xeb>
			f92: R_X86_64_PLT32	rt_str_region_eq-0x4
     f96:	cmp    rax,0x6
     f9a:	je     10d6 <botlish_fn_12+0x22b>
     fa0:	mov    rdi,r15
     fa3:	mov    rax,QWORD PTR [rdi+0x10]
     fa7:	mov    r8,QWORD PTR [rax+0x18]
     fab:	mov    rcx,r13
     fae:	mov    rdx,r12
     fb1:	mov    rsi,QWORD PTR [rsp+0x38]
     fb6:	call   fbb <botlish_fn_12+0x110>
			fb7: R_X86_64_PLT32	rt_str_region_eq-0x4
     fbb:	cmp    rax,0x6
     fbf:	je     100d <botlish_fn_12+0x162>
     fc5:	mov    rdx,QWORD PTR [rsp+0x48]
     fca:	mov    rsi,QWORD PTR [rsp+0x40]
     fcf:	mov    rdi,r15
     fd2:	call   fd7 <botlish_fn_12+0x12c>
			fd3: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
     fd7:	test   rax,rax
     fda:	je     1028 <botlish_fn_12+0x17d>
     fe0:	mov    rdx,QWORD PTR [rsp+0x50]
     fe5:	mov    rbx,QWORD PTR [rsp+0x60]
     fea:	mov    r12,QWORD PTR [rsp+0x68]
     fef:	mov    r13,QWORD PTR [rsp+0x70]
     ff4:	mov    r14,QWORD PTR [rsp+0x78]
     ff9:	mov    r15,QWORD PTR [rsp+0x80]
    1001:	add    rsp,0x90
    1008:	mov    rsp,rbp
    100b:	pop    rbp
    100c:	ret
    100d:	mov    rdx,QWORD PTR [rsp+0x48]
    1012:	mov    rsi,QWORD PTR [rsp+0x40]
    1017:	mov    rdi,r15
    101a:	call   101f <botlish_fn_12+0x174>
			101b: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    101f:	test   rax,rax
    1022:	jne    1056 <botlish_fn_12+0x1ab>
    1028:	xor    rdx,rdx
    102b:	mov    rax,rdx
    102e:	mov    rbx,QWORD PTR [rsp+0x60]
    1033:	mov    r12,QWORD PTR [rsp+0x68]
    1038:	mov    r13,QWORD PTR [rsp+0x70]
    103d:	mov    r14,QWORD PTR [rsp+0x78]
    1042:	mov    r15,QWORD PTR [rsp+0x80]
    104a:	add    rsp,0x90
    1051:	mov    rsp,rbp
    1054:	pop    rbp
    1055:	ret
    1056:	mov    QWORD PTR [rsp],rax
    105a:	mov    r12,rax
    105d:	mov    QWORD PTR [rsp+0x8],0x3
    1066:	mov    rdx,QWORD PTR [rsp+0x50]
    106b:	test   rdx,0x1
    1072:	je     1096 <botlish_fn_12+0x1eb>
    1078:	mov    rdx,QWORD PTR [rsp+0x50]
    107d:	add    rdx,0x2
    1081:	seto   r10b
    1085:	test   r10b,r10b
    1088:	jne    1096 <botlish_fn_12+0x1eb>
    108e:	mov    rax,r12
    1091:	jmp    10ae <botlish_fn_12+0x203>
    1096:	mov    edx,0x3
    109b:	mov    rsi,QWORD PTR [rsp+0x50]
    10a0:	mov    rdi,r15
    10a3:	call   10a8 <botlish_fn_12+0x1fd>
			10a4: R_X86_64_PLT32	rt_int_add-0x4
    10a8:	mov    rdx,rax
    10ab:	mov    rax,r12
    10ae:	mov    rbx,QWORD PTR [rsp+0x60]
    10b3:	mov    r12,QWORD PTR [rsp+0x68]
    10b8:	mov    r13,QWORD PTR [rsp+0x70]
    10bd:	mov    r14,QWORD PTR [rsp+0x78]
    10c2:	mov    r15,QWORD PTR [rsp+0x80]
    10ca:	add    rsp,0x90
    10d1:	mov    rsp,rbp
    10d4:	pop    rbp
    10d5:	ret
    10d6:	mov    rsi,QWORD PTR [rsp+0x50]
    10db:	mov    edx,0x3
    10e0:	mov    rcx,rdx
    10e3:	mov    QWORD PTR [rsp+0x18],0x3
    10ec:	test   rsi,0x1
    10f3:	jne    1101 <botlish_fn_12+0x256>
    10f9:	mov    rdx,rcx
    10fc:	jmp    1116 <botlish_fn_12+0x26b>
    1101:	mov    rdx,rsi
    1104:	add    rdx,0x2
    1108:	seto   al
    110b:	test   al,al
    110d:	je     1121 <botlish_fn_12+0x276>
    1113:	mov    rdx,rcx
    1116:	mov    rdi,r15
    1119:	call   111e <botlish_fn_12+0x273>
			111a: R_X86_64_PLT32	rt_int_add-0x4
    111e:	mov    rdx,rax
    1121:	mov    QWORD PTR [rsp],rbx
    1125:	mov    QWORD PTR [rsp+0x8],rdx
    112a:	mov    rsi,QWORD PTR [rsp+0x40]
    112f:	mov    QWORD PTR [rsp+0x10],rsi
    1134:	mov    r11,QWORD PTR [rsp+0x48]
    1139:	mov    QWORD PTR [rsp+0x18],r11
    113e:	mov    r12,r11
    1141:	mov    r13,rsi
    1144:	jmp    eff <botlish_fn_12+0x54>

0000000000001149 <botlish_entry_12: scan_record<str, int, list[mutarray, int]>>:
    1149:	push   rbp
    114a:	mov    rbp,rsp
    114d:	ud2
	...

0000000000001150 <botlish_fn_13: scan_records<str, int, list[mutarray, int]>>:
    1150:	push   rbp
    1151:	mov    rbp,rsp
    1154:	sub    rsp,0x60
    1158:	mov    QWORD PTR [rsp+0x30],rbx
    115d:	mov    QWORD PTR [rsp+0x38],r12
    1162:	mov    QWORD PTR [rsp+0x40],r13
    1167:	mov    QWORD PTR [rsp+0x48],r14
    116c:	mov    QWORD PTR [rsp+0x50],r15
    1171:	mov    r13,rdi
    1174:	mov    QWORD PTR [rsp+0x20],0x0
    117d:	mov    QWORD PTR [rsp+0x28],0x0
    1186:	mov    QWORD PTR [rsp],rsi
    118a:	mov    QWORD PTR [rsp+0x8],rdx
    118f:	mov    r12,rdx
    1192:	mov    QWORD PTR [rsp+0x10],rcx
    1197:	mov    QWORD PTR [rsp+0x18],r8
    119c:	mov    rbx,rsi
    119f:	mov    r14,r8
    11a2:	mov    r15,rcx
    11a5:	mov    rsi,rbx
    11a8:	mov    rdi,r13
    11ab:	call   11b0 <botlish_fn_13+0x60>
			11ac: R_X86_64_PLT32	rt_str_len-0x4
    11b0:	mov    rcx,r12
    11b3:	and    rcx,rax
    11b6:	mov    rdx,rax
    11b9:	test   rcx,0x1
    11c0:	jne    11e6 <botlish_fn_13+0x96>
    11c6:	mov    rsi,r12
    11c9:	mov    rdi,r13
    11cc:	call   11d1 <botlish_fn_13+0x81>
			11cd: R_X86_64_PLT32	rt_int_cmp-0x4
    11d1:	mov    ecx,0x2
    11d6:	test   rax,rax
    11d9:	cmovge rcx,QWORD PTR [rip+0x107]        # 12e8 <botlish_fn_13+0x198>
    11e1:	jmp    11f9 <botlish_fn_13+0xa9>
    11e6:	mov    ecx,0x2
    11eb:	mov    rax,r12
    11ee:	cmp    rax,rdx
    11f1:	cmovge rcx,QWORD PTR [rip+0xef]        # 12e8 <botlish_fn_13+0x198>
    11f9:	cmp    rcx,0x6
    11fd:	je     1283 <botlish_fn_13+0x133>
    1203:	mov    rdi,r13
    1206:	call   120b <botlish_fn_13+0xbb>
			1207: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    120b:	test   rax,rax
    120e:	je     129a <botlish_fn_13+0x14a>
    1214:	mov    QWORD PTR [rsp+0x20],rax
    1219:	mov    rcx,rax
    121c:	mov    QWORD PTR [rsp+0x28],rdx
    1221:	mov    r8,rdx
    1224:	mov    rdx,r12
    1227:	mov    rsi,rbx
    122a:	mov    rdi,r13
    122d:	call   1232 <botlish_fn_13+0xe2>
			122e: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_record<str, int, list[mutarray, int]>
    1232:	test   rax,rax
    1235:	je     129a <botlish_fn_13+0x14a>
    123b:	mov    QWORD PTR [rsp+0x8],rax
    1240:	mov    rcx,rax
    1243:	mov    QWORD PTR [rsp+0x20],rdx
    1248:	mov    r12,rdx
    124b:	mov    rsi,r15
    124e:	mov    rdx,r14
    1251:	mov    rdi,r13
    1254:	call   1259 <botlish_fn_13+0x109>
			1255: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    1259:	test   rax,rax
    125c:	je     129a <botlish_fn_13+0x14a>
    1262:	mov    QWORD PTR [rsp],rbx
    1266:	mov    rcx,r12
    1269:	mov    QWORD PTR [rsp+0x8],rcx
    126e:	mov    QWORD PTR [rsp+0x10],rax
    1273:	mov    QWORD PTR [rsp+0x18],rdx
    1278:	mov    r14,rdx
    127b:	mov    r15,rax
    127e:	jmp    11a5 <botlish_fn_13+0x55>
    1283:	mov    rdx,r14
    1286:	mov    rsi,r15
    1289:	mov    rdi,r13
    128c:	call   1291 <botlish_fn_13+0x141>
			128d: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    1291:	test   rax,rax
    1294:	jne    12bf <botlish_fn_13+0x16f>
    129a:	xor    rax,rax
    129d:	mov    rbx,QWORD PTR [rsp+0x30]
    12a2:	mov    r12,QWORD PTR [rsp+0x38]
    12a7:	mov    r13,QWORD PTR [rsp+0x40]
    12ac:	mov    r14,QWORD PTR [rsp+0x48]
    12b1:	mov    r15,QWORD PTR [rsp+0x50]
    12b6:	add    rsp,0x60
    12ba:	mov    rsp,rbp
    12bd:	pop    rbp
    12be:	ret
    12bf:	mov    rbx,QWORD PTR [rsp+0x30]
    12c4:	mov    r12,QWORD PTR [rsp+0x38]
    12c9:	mov    r13,QWORD PTR [rsp+0x40]
    12ce:	mov    r14,QWORD PTR [rsp+0x48]
    12d3:	mov    r15,QWORD PTR [rsp+0x50]
    12d8:	add    rsp,0x60
    12dc:	mov    rsp,rbp
    12df:	pop    rbp
    12e0:	ret
    12e1:	add    BYTE PTR [rax],al
    12e3:	add    BYTE PTR [rax],al
    12e5:	add    BYTE PTR [rax],al
    12e7:	add    BYTE PTR [rsi],al
    12e9:	add    BYTE PTR [rax],al
    12eb:	add    BYTE PTR [rax],al
    12ed:	add    BYTE PTR [rax],al
	...

00000000000012f0 <botlish_entry_13: scan_records<str, int, list[mutarray, int]>>:
    12f0:	push   rbp
    12f1:	mov    rbp,rsp
    12f4:	mov    rsi,QWORD PTR [rdx]
    12f7:	mov    r9,QWORD PTR [rdx+0x8]
    12fb:	mov    rcx,QWORD PTR [rdx+0x10]
    12ff:	mov    r8,QWORD PTR [rdx+0x18]
    1303:	mov    rdx,r9
    1306:	call   130b <botlish_entry_13+0x1b>
			1307: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    130b:	mov    rsp,rbp
    130e:	pop    rbp
    130f:	ret

0000000000001310 <botlish_fn_14: csv_parse<str>>:
    1310:	push   rbp
    1311:	mov    rbp,rsp
    1314:	sub    rsp,0x30
    1318:	mov    QWORD PTR [rsp+0x20],r12
    131d:	mov    QWORD PTR [rsp+0x28],r13
    1322:	mov    r13,rdi
    1325:	mov    QWORD PTR [rsp+0x10],0x0
    132e:	mov    QWORD PTR [rsp+0x18],0x0
    1337:	mov    QWORD PTR [rsp],rsi
    133b:	mov    r12,rsi
    133e:	mov    QWORD PTR [rsp+0x8],0x1
    1347:	mov    rdi,r13
    134a:	call   134f <botlish_fn_14+0x3f>
			134b: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    134f:	test   rax,rax
    1352:	je     1381 <botlish_fn_14+0x71>
    1358:	mov    QWORD PTR [rsp+0x10],rax
    135d:	mov    rcx,rax
    1360:	mov    QWORD PTR [rsp+0x18],rdx
    1365:	mov    r8,rdx
    1368:	mov    edx,0x1
    136d:	mov    rsi,r12
    1370:	mov    rdi,r13
    1373:	call   1378 <botlish_fn_14+0x68>
			1374: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    1378:	test   rax,rax
    137b:	jne    1397 <botlish_fn_14+0x87>
    1381:	xor    rax,rax
    1384:	mov    r12,QWORD PTR [rsp+0x20]
    1389:	mov    r13,QWORD PTR [rsp+0x28]
    138e:	add    rsp,0x30
    1392:	mov    rsp,rbp
    1395:	pop    rbp
    1396:	ret
    1397:	mov    r12,QWORD PTR [rsp+0x20]
    139c:	mov    r13,QWORD PTR [rsp+0x28]
    13a1:	add    rsp,0x30
    13a5:	mov    rsp,rbp
    13a8:	pop    rbp
    13a9:	ret

00000000000013aa <botlish_entry_14: csv_parse<str>>:
    13aa:	push   rbp
    13ab:	mov    rbp,rsp
    13ae:	mov    rsi,QWORD PTR [rdx]
    13b1:	call   13b6 <botlish_entry_14+0xc>
			13b2: R_X86_64_PLT32	botlish_fn_14-0x4 ; csv_parse<str>
    13b6:	mov    rsp,rbp
    13b9:	pop    rbp
    13ba:	ret

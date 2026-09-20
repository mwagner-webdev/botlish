; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5349  (per function: 68 78 357 397 272 272 81 365 430 585 770 352 695 456 171)
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
     24a:	cmovl  rcx,QWORD PTR [rip+0xde]        # 330 <botlish_fn_3+0x150>
     252:	mov    rax,r14
     255:	jmp    26d <botlish_fn_3+0x8d>
     25a:	mov    ecx,0x2
     25f:	mov    rax,r14
     262:	cmp    rbx,rax
     265:	cmovl  rcx,QWORD PTR [rip+0xc3]        # 330 <botlish_fn_3+0x150>
     26d:	cmp    rcx,0x6
     271:	je     30d <botlish_fn_3+0x12d>
     277:	mov    rsi,rax
     27a:	mov    rdx,rbx
     27d:	mov    rdi,r13
     280:	call   285 <botlish_fn_3+0xa5>
			281: R_X86_64_PLT32	botlish_fn_2-0x4 ; geo_new_capacity<int, int>
     285:	test   rax,rax
     288:	je     2cd <botlish_fn_3+0xed>
     28e:	mov    QWORD PTR [rsp+0x10],rax
     293:	mov    rsi,rax
     296:	mov    rdi,r13
     299:	call   29e <botlish_fn_3+0xbe>
			29a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     29e:	test   rax,rax
     2a1:	mov    r14,rax
     2a4:	je     2cd <botlish_fn_3+0xed>
     2aa:	mov    r8d,0x1
     2b0:	mov    rcx,r12
     2b3:	mov    rdi,r13
     2b6:	mov    r9,rbx
     2b9:	mov    rsi,r14
     2bc:	mov    rdx,r8
     2bf:	call   2c4 <botlish_fn_3+0xe4>
			2c0: R_X86_64_PLT32	rt_mutarray_copy-0x4
     2c4:	test   rax,rax
     2c7:	jne    2ed <botlish_fn_3+0x10d>
     2cd:	xor    rax,rax
     2d0:	mov    rbx,QWORD PTR [rsp+0x20]
     2d5:	mov    r12,QWORD PTR [rsp+0x28]
     2da:	mov    r13,QWORD PTR [rsp+0x30]
     2df:	mov    r14,QWORD PTR [rsp+0x38]
     2e4:	add    rsp,0x40
     2e8:	mov    rsp,rbp
     2eb:	pop    rbp
     2ec:	ret
     2ed:	mov    rax,r14
     2f0:	mov    rbx,QWORD PTR [rsp+0x20]
     2f5:	mov    r12,QWORD PTR [rsp+0x28]
     2fa:	mov    r13,QWORD PTR [rsp+0x30]
     2ff:	mov    r14,QWORD PTR [rsp+0x38]
     304:	add    rsp,0x40
     308:	mov    rsp,rbp
     30b:	pop    rbp
     30c:	ret
     30d:	mov    rax,r12
     310:	mov    rbx,QWORD PTR [rsp+0x20]
     315:	mov    r12,QWORD PTR [rsp+0x28]
     31a:	mov    r13,QWORD PTR [rsp+0x30]
     31f:	mov    r14,QWORD PTR [rsp+0x38]
     324:	add    rsp,0x40
     328:	mov    rsp,rbp
     32b:	pop    rbp
     32c:	ret
     32d:	add    BYTE PTR [rax],al
     32f:	add    BYTE PTR [rsi],al
     331:	add    BYTE PTR [rax],al
     333:	add    BYTE PTR [rax],al
     335:	add    BYTE PTR [rax],al
	...

0000000000000338 <botlish_entry_3: geo_grow<mutarray, int>>:
     338:	push   rbp
     339:	mov    rbp,rsp
     33c:	mov    rsi,QWORD PTR [rdx]
     33f:	mov    rdx,QWORD PTR [rdx+0x8]
     343:	call   348 <botlish_entry_3+0x10>
			344: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     348:	mov    rsp,rbp
     34b:	pop    rbp
     34c:	ret

000000000000034d <botlish_fn_4: geo_append<list[mutarray, int], str>>:
     34d:	push   rbp
     34e:	mov    rbp,rsp
     351:	sub    rsp,0x40
     355:	mov    QWORD PTR [rsp+0x20],rbx
     35a:	mov    QWORD PTR [rsp+0x28],r12
     35f:	mov    QWORD PTR [rsp+0x30],r13
     364:	mov    r12,rdi
     367:	mov    QWORD PTR [rsp],rsi
     36b:	mov    QWORD PTR [rsp+0x8],rdx
     370:	mov    rdi,rdx
     373:	mov    QWORD PTR [rsp+0x10],rcx
     378:	mov    r13,rcx
     37b:	mov    rbx,rdi
     37e:	mov    rdx,rbx
     381:	mov    rdi,r12
     384:	call   389 <botlish_fn_4+0x3c>
			385: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     389:	test   rax,rax
     38c:	je     3b3 <botlish_fn_4+0x66>
     392:	mov    QWORD PTR [rsp],rax
     396:	mov    rcx,r13
     399:	mov    r13,rax
     39c:	mov    rdx,rbx
     39f:	mov    rsi,r13
     3a2:	mov    rdi,r12
     3a5:	call   3aa <botlish_fn_4+0x5d>
			3a6: R_X86_64_PLT32	rt_mutarray_set-0x4
     3aa:	test   rax,rax
     3ad:	jne    3d1 <botlish_fn_4+0x84>
     3b3:	xor    rdx,rdx
     3b6:	mov    rax,rdx
     3b9:	mov    rbx,QWORD PTR [rsp+0x20]
     3be:	mov    r12,QWORD PTR [rsp+0x28]
     3c3:	mov    r13,QWORD PTR [rsp+0x30]
     3c8:	add    rsp,0x40
     3cc:	mov    rsp,rbp
     3cf:	pop    rbp
     3d0:	ret
     3d1:	mov    QWORD PTR [rsp+0x10],0x3
     3da:	test   rbx,0x1
     3e1:	jne    3ef <botlish_fn_4+0xa2>
     3e7:	mov    rdi,rbx
     3ea:	jmp    40c <botlish_fn_4+0xbf>
     3ef:	mov    rdx,rbx
     3f2:	add    rdx,0x2
     3f6:	mov    rdi,rbx
     3f9:	seto   al
     3fc:	test   al,al
     3fe:	jne    40c <botlish_fn_4+0xbf>
     404:	mov    rax,r13
     407:	jmp    422 <botlish_fn_4+0xd5>
     40c:	mov    edx,0x3
     411:	mov    rsi,rdi
     414:	mov    rdi,r12
     417:	call   41c <botlish_fn_4+0xcf>
			418: R_X86_64_PLT32	rt_int_add-0x4
     41c:	mov    rdx,rax
     41f:	mov    rax,r13
     422:	mov    rbx,QWORD PTR [rsp+0x20]
     427:	mov    r12,QWORD PTR [rsp+0x28]
     42c:	mov    r13,QWORD PTR [rsp+0x30]
     431:	add    rsp,0x40
     435:	mov    rsp,rbp
     438:	pop    rbp
     439:	ret

000000000000043a <botlish_entry_4: geo_append<list[mutarray, int], str>>:
     43a:	push   rbp
     43b:	mov    rbp,rsp
     43e:	ud2

0000000000000440 <botlish_fn_5: geo_append<list[mutarray, int], list>>:
     440:	push   rbp
     441:	mov    rbp,rsp
     444:	sub    rsp,0x40
     448:	mov    QWORD PTR [rsp+0x20],rbx
     44d:	mov    QWORD PTR [rsp+0x28],r12
     452:	mov    QWORD PTR [rsp+0x30],r13
     457:	mov    r12,rdi
     45a:	mov    QWORD PTR [rsp],rsi
     45e:	mov    QWORD PTR [rsp+0x8],rdx
     463:	mov    rdi,rdx
     466:	mov    QWORD PTR [rsp+0x10],rcx
     46b:	mov    r13,rcx
     46e:	mov    rbx,rdi
     471:	mov    rdx,rbx
     474:	mov    rdi,r12
     477:	call   47c <botlish_fn_5+0x3c>
			478: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_grow<mutarray, int>
     47c:	test   rax,rax
     47f:	je     4a6 <botlish_fn_5+0x66>
     485:	mov    QWORD PTR [rsp],rax
     489:	mov    rcx,r13
     48c:	mov    r13,rax
     48f:	mov    rdx,rbx
     492:	mov    rsi,r13
     495:	mov    rdi,r12
     498:	call   49d <botlish_fn_5+0x5d>
			499: R_X86_64_PLT32	rt_mutarray_set-0x4
     49d:	test   rax,rax
     4a0:	jne    4c4 <botlish_fn_5+0x84>
     4a6:	xor    rdx,rdx
     4a9:	mov    rax,rdx
     4ac:	mov    rbx,QWORD PTR [rsp+0x20]
     4b1:	mov    r12,QWORD PTR [rsp+0x28]
     4b6:	mov    r13,QWORD PTR [rsp+0x30]
     4bb:	add    rsp,0x40
     4bf:	mov    rsp,rbp
     4c2:	pop    rbp
     4c3:	ret
     4c4:	mov    QWORD PTR [rsp+0x10],0x3
     4cd:	test   rbx,0x1
     4d4:	jne    4e2 <botlish_fn_5+0xa2>
     4da:	mov    rdi,rbx
     4dd:	jmp    4ff <botlish_fn_5+0xbf>
     4e2:	mov    rdx,rbx
     4e5:	add    rdx,0x2
     4e9:	mov    rdi,rbx
     4ec:	seto   al
     4ef:	test   al,al
     4f1:	jne    4ff <botlish_fn_5+0xbf>
     4f7:	mov    rax,r13
     4fa:	jmp    515 <botlish_fn_5+0xd5>
     4ff:	mov    edx,0x3
     504:	mov    rsi,rdi
     507:	mov    rdi,r12
     50a:	call   50f <botlish_fn_5+0xcf>
			50b: R_X86_64_PLT32	rt_int_add-0x4
     50f:	mov    rdx,rax
     512:	mov    rax,r13
     515:	mov    rbx,QWORD PTR [rsp+0x20]
     51a:	mov    r12,QWORD PTR [rsp+0x28]
     51f:	mov    r13,QWORD PTR [rsp+0x30]
     524:	add    rsp,0x40
     528:	mov    rsp,rbp
     52b:	pop    rbp
     52c:	ret

000000000000052d <botlish_entry_5: geo_append<list[mutarray, int], list>>:
     52d:	push   rbp
     52e:	mov    rbp,rsp
     531:	ud2

0000000000000533 <botlish_fn_6: geo_finish<list[mutarray, int]>>:
     533:	push   rbp
     534:	mov    rbp,rsp
     537:	sub    rsp,0x10
     53b:	mov    QWORD PTR [rsp],rsi
     53f:	mov    QWORD PTR [rsp+0x8],rdx
     544:	call   549 <botlish_fn_6+0x16>
			545: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     549:	test   rax,rax
     54c:	jne    55e <botlish_fn_6+0x2b>
     552:	xor    rax,rax
     555:	add    rsp,0x10
     559:	mov    rsp,rbp
     55c:	pop    rbp
     55d:	ret
     55e:	add    rsp,0x10
     562:	mov    rsp,rbp
     565:	pop    rbp
     566:	ret

0000000000000567 <botlish_entry_6: geo_finish<list[mutarray, int]>>:
     567:	push   rbp
     568:	mov    rbp,rsp
     56b:	mov    rsi,QWORD PTR [rdx]
     56e:	mov    rdx,QWORD PTR [rdx+0x8]
     572:	call   577 <botlish_entry_6+0x10>
			573: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
     577:	mov    rsp,rbp
     57a:	pop    rbp
     57b:	ret
     57c:	add    BYTE PTR [rax],al
	...

0000000000000580 <botlish_fn_7: peek<str, int>>:
     580:	push   rbp
     581:	mov    rbp,rsp
     584:	sub    rsp,0x40
     588:	mov    QWORD PTR [rsp+0x20],rbx
     58d:	mov    QWORD PTR [rsp+0x28],r12
     592:	mov    QWORD PTR [rsp+0x30],r13
     597:	mov    r13,rdi
     59a:	mov    QWORD PTR [rsp],rsi
     59e:	mov    r12,rsi
     5a1:	mov    QWORD PTR [rsp+0x8],rdx
     5a6:	mov    rbx,rdx
     5a9:	mov    rsi,r12
     5ac:	mov    rdi,r13
     5af:	call   5b4 <botlish_fn_7+0x34>
			5b0: R_X86_64_PLT32	rt_str_len-0x4
     5b4:	mov    rcx,rbx
     5b7:	and    rcx,rax
     5ba:	mov    rdx,rax
     5bd:	test   rcx,0x1
     5c4:	jne    5ea <botlish_fn_7+0x6a>
     5ca:	mov    rsi,rbx
     5cd:	mov    rdi,r13
     5d0:	call   5d5 <botlish_fn_7+0x55>
			5d1: R_X86_64_PLT32	rt_int_cmp-0x4
     5d5:	mov    ecx,0x2
     5da:	test   rax,rax
     5dd:	cmovge rcx,QWORD PTR [rip+0xd3]        # 6b8 <botlish_fn_7+0x138>
     5e5:	jmp    5fa <botlish_fn_7+0x7a>
     5ea:	mov    ecx,0x2
     5ef:	cmp    rbx,rdx
     5f2:	cmovge rcx,QWORD PTR [rip+0xbe]        # 6b8 <botlish_fn_7+0x138>
     5fa:	cmp    rcx,0x6
     5fe:	je     68e <botlish_fn_7+0x10e>
     604:	mov    QWORD PTR [rsp+0x10],0x3
     60d:	test   rbx,0x1
     614:	je     62c <botlish_fn_7+0xac>
     61a:	mov    rcx,rbx
     61d:	add    rcx,0x2
     621:	seto   al
     624:	test   al,al
     626:	je     63f <botlish_fn_7+0xbf>
     62c:	mov    edx,0x3
     631:	mov    rsi,rbx
     634:	mov    rdi,r13
     637:	call   63c <botlish_fn_7+0xbc>
			638: R_X86_64_PLT32	rt_int_add-0x4
     63c:	mov    rcx,rax
     63f:	mov    QWORD PTR [rsp+0x10],rcx
     644:	mov    rdx,rbx
     647:	mov    rsi,r12
     64a:	mov    rdi,r13
     64d:	call   652 <botlish_fn_7+0xd2>
			64e: R_X86_64_PLT32	rt_substr-0x4
     652:	test   rax,rax
     655:	jne    676 <botlish_fn_7+0xf6>
     65b:	xor    rax,rax
     65e:	mov    rbx,QWORD PTR [rsp+0x20]
     663:	mov    r12,QWORD PTR [rsp+0x28]
     668:	mov    r13,QWORD PTR [rsp+0x30]
     66d:	add    rsp,0x40
     671:	mov    rsp,rbp
     674:	pop    rbp
     675:	ret
     676:	mov    rbx,QWORD PTR [rsp+0x20]
     67b:	mov    r12,QWORD PTR [rsp+0x28]
     680:	mov    r13,QWORD PTR [rsp+0x30]
     685:	add    rsp,0x40
     689:	mov    rsp,rbp
     68c:	pop    rbp
     68d:	ret
     68e:	mov    rdi,r13
     691:	mov    rax,QWORD PTR [rdi+0x10]
     695:	mov    rax,QWORD PTR [rax+0x8]
     699:	mov    rbx,QWORD PTR [rsp+0x20]
     69e:	mov    r12,QWORD PTR [rsp+0x28]
     6a3:	mov    r13,QWORD PTR [rsp+0x30]
     6a8:	add    rsp,0x40
     6ac:	mov    rsp,rbp
     6af:	pop    rbp
     6b0:	ret
     6b1:	add    BYTE PTR [rax],al
     6b3:	add    BYTE PTR [rax],al
     6b5:	add    BYTE PTR [rax],al
     6b7:	add    BYTE PTR [rsi],al
     6b9:	add    BYTE PTR [rax],al
     6bb:	add    BYTE PTR [rax],al
     6bd:	add    BYTE PTR [rax],al
	...

00000000000006c0 <botlish_entry_7: peek<str, int>>:
     6c0:	push   rbp
     6c1:	mov    rbp,rsp
     6c4:	mov    rsi,QWORD PTR [rdx]
     6c7:	mov    rdx,QWORD PTR [rdx+0x8]
     6cb:	call   6d0 <botlish_entry_7+0x10>
			6cc: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
     6d0:	mov    rsp,rbp
     6d3:	pop    rbp
     6d4:	ret
     6d5:	add    BYTE PTR [rax],al
	...

00000000000006d8 <botlish_fn_8: peek<str, int>>:
     6d8:	push   rbp
     6d9:	mov    rbp,rsp
     6dc:	sub    rsp,0x50
     6e0:	mov    QWORD PTR [rsp+0x20],rbx
     6e5:	mov    QWORD PTR [rsp+0x28],r12
     6ea:	mov    QWORD PTR [rsp+0x30],r13
     6ef:	mov    QWORD PTR [rsp+0x38],r14
     6f4:	mov    QWORD PTR [rsp+0x40],r15
     6f9:	mov    r12,rcx
     6fc:	mov    r14,rdi
     6ff:	mov    QWORD PTR [rsp],rsi
     703:	mov    r13,rsi
     706:	mov    QWORD PTR [rsp+0x8],rdx
     70b:	mov    rbx,rdx
     70e:	mov    rsi,r13
     711:	mov    rdi,r14
     714:	call   719 <botlish_fn_8+0x41>
			715: R_X86_64_PLT32	rt_str_len-0x4
     719:	mov    rcx,rbx
     71c:	and    rcx,rax
     71f:	mov    rdx,rax
     722:	test   rcx,0x1
     729:	jne    74f <botlish_fn_8+0x77>
     72f:	mov    rsi,rbx
     732:	mov    rdi,r14
     735:	call   73a <botlish_fn_8+0x62>
			736: R_X86_64_PLT32	rt_int_cmp-0x4
     73a:	mov    ecx,0x2
     73f:	test   rax,rax
     742:	cmovge rcx,QWORD PTR [rip+0x11e]        # 868 <botlish_fn_8+0x190>
     74a:	jmp    75f <botlish_fn_8+0x87>
     74f:	mov    ecx,0x2
     754:	cmp    rbx,rdx
     757:	cmovge rcx,QWORD PTR [rip+0x109]        # 868 <botlish_fn_8+0x190>
     75f:	cmp    rcx,0x6
     763:	je     823 <botlish_fn_8+0x14b>
     769:	mov    QWORD PTR [rsp+0x10],0x3
     772:	test   rbx,0x1
     779:	je     79c <botlish_fn_8+0xc4>
     77f:	mov    rax,rbx
     782:	add    rax,0x2
     786:	seto   cl
     789:	test   cl,cl
     78b:	jne    79c <botlish_fn_8+0xc4>
     791:	mov    rdi,r14
     794:	mov    r15,rax
     797:	jmp    7b2 <botlish_fn_8+0xda>
     79c:	mov    edx,0x3
     7a1:	mov    rsi,rbx
     7a4:	mov    rdi,r14
     7a7:	call   7ac <botlish_fn_8+0xd4>
			7a8: R_X86_64_PLT32	rt_int_add-0x4
     7ac:	mov    r15,rax
     7af:	mov    rdi,r14
     7b2:	mov    rdi,r14
     7b5:	mov    rcx,r15
     7b8:	mov    rdx,rbx
     7bb:	mov    rsi,r13
     7be:	call   7c3 <botlish_fn_8+0xeb>
			7bf: R_X86_64_PLT32	rt_str_region_check-0x4
     7c3:	test   rax,rax
     7c6:	jne    7f1 <botlish_fn_8+0x119>
     7cc:	xor    rax,rax
     7cf:	mov    rbx,QWORD PTR [rsp+0x20]
     7d4:	mov    r12,QWORD PTR [rsp+0x28]
     7d9:	mov    r13,QWORD PTR [rsp+0x30]
     7de:	mov    r14,QWORD PTR [rsp+0x38]
     7e3:	mov    r15,QWORD PTR [rsp+0x40]
     7e8:	add    rsp,0x50
     7ec:	mov    rsp,rbp
     7ef:	pop    rbp
     7f0:	ret
     7f1:	mov    rcx,r12
     7f4:	mov    QWORD PTR [rcx],rbx
     7f7:	mov    rax,r15
     7fa:	mov    QWORD PTR [rcx+0x8],rax
     7fe:	mov    rax,r13
     801:	mov    rbx,QWORD PTR [rsp+0x20]
     806:	mov    r12,QWORD PTR [rsp+0x28]
     80b:	mov    r13,QWORD PTR [rsp+0x30]
     810:	mov    r14,QWORD PTR [rsp+0x38]
     815:	mov    r15,QWORD PTR [rsp+0x40]
     81a:	add    rsp,0x50
     81e:	mov    rsp,rbp
     821:	pop    rbp
     822:	ret
     823:	mov    rcx,r12
     826:	mov    rdi,r14
     829:	mov    rax,QWORD PTR [rdi+0x10]
     82d:	mov    rax,QWORD PTR [rax+0x8]
     831:	mov    QWORD PTR [rcx],0x1
     838:	mov    QWORD PTR [rcx+0x8],0x1
     840:	mov    rbx,QWORD PTR [rsp+0x20]
     845:	mov    r12,QWORD PTR [rsp+0x28]
     84a:	mov    r13,QWORD PTR [rsp+0x30]
     84f:	mov    r14,QWORD PTR [rsp+0x38]
     854:	mov    r15,QWORD PTR [rsp+0x40]
     859:	add    rsp,0x50
     85d:	mov    rsp,rbp
     860:	pop    rbp
     861:	ret
     862:	add    BYTE PTR [rax],al
     864:	add    BYTE PTR [rax],al
     866:	add    BYTE PTR [rax],al
     868:	(bad)
     869:	add    BYTE PTR [rax],al
     86b:	add    BYTE PTR [rax],al
     86d:	add    BYTE PTR [rax],al
	...

0000000000000870 <botlish_entry_8: peek<str, int>>:
     870:	push   rbp
     871:	mov    rbp,rsp
     874:	ud2

0000000000000876 <botlish_fn_9: scan_unquoted<str, int, int>>:
     876:	push   rbp
     877:	mov    rbp,rsp
     87a:	sub    rsp,0x80
     881:	mov    QWORD PTR [rsp+0x50],rbx
     886:	mov    QWORD PTR [rsp+0x58],r12
     88b:	mov    QWORD PTR [rsp+0x60],r13
     890:	mov    QWORD PTR [rsp+0x68],r14
     895:	mov    QWORD PTR [rsp+0x70],r15
     89a:	mov    QWORD PTR [rsp+0x30],rdi
     89f:	mov    QWORD PTR [rsp+0x18],0x0
     8a8:	mov    QWORD PTR [rsp],rsi
     8ac:	mov    r15,rsi
     8af:	mov    QWORD PTR [rsp+0x8],rdx
     8b4:	mov    r14,rdx
     8b7:	mov    QWORD PTR [rsp+0x10],rcx
     8bc:	lea    r13,[rsp+0x20]
     8c1:	mov    QWORD PTR [rsp+0x38],rcx
     8c6:	mov    rcx,r13
     8c9:	mov    rdx,QWORD PTR [rsp+0x38]
     8ce:	mov    rsi,r15
     8d1:	mov    rdi,QWORD PTR [rsp+0x30]
     8d6:	call   8db <botlish_fn_9+0x65>
			8d7: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     8db:	mov    rsi,rax
     8de:	mov    QWORD PTR [rsp+0x40],rax
     8e3:	test   rax,rsi
     8e6:	je     a40 <botlish_fn_9+0x1ca>
     8ec:	mov    rbx,QWORD PTR [rsp+0x20]
     8f1:	mov    r12,QWORD PTR [rsp+0x28]
     8f6:	mov    rdi,QWORD PTR [rsp+0x30]
     8fb:	mov    rcx,QWORD PTR [rdi+0x10]
     8ff:	mov    r8,QWORD PTR [rcx+0x8]
     903:	mov    rcx,r12
     906:	mov    rdx,rbx
     909:	mov    rsi,QWORD PTR [rsp+0x40]
     90e:	call   913 <botlish_fn_9+0x9d>
			90f: R_X86_64_PLT32	rt_str_region_eq-0x4
     913:	cmp    rax,0x6
     917:	je     958 <botlish_fn_9+0xe2>
     91d:	mov    rdi,QWORD PTR [rsp+0x30]
     922:	mov    rax,QWORD PTR [rdi+0x10]
     926:	mov    r8,QWORD PTR [rax+0x10]
     92a:	mov    rcx,r12
     92d:	mov    rdx,rbx
     930:	mov    rsi,QWORD PTR [rsp+0x40]
     935:	call   93a <botlish_fn_9+0xc4>
			936: R_X86_64_PLT32	rt_str_region_eq-0x4
     93a:	cmp    rax,0x6
     93e:	je     94e <botlish_fn_9+0xd8>
     944:	mov    eax,0x2
     949:	jmp    95d <botlish_fn_9+0xe7>
     94e:	mov    eax,0x6
     953:	jmp    95d <botlish_fn_9+0xe7>
     958:	mov    eax,0x6
     95d:	cmp    rax,0x6
     961:	je     9a2 <botlish_fn_9+0x12c>
     967:	mov    rdi,QWORD PTR [rsp+0x30]
     96c:	mov    rax,QWORD PTR [rdi+0x10]
     970:	mov    r8,QWORD PTR [rax+0x18]
     974:	mov    rcx,r12
     977:	mov    rdx,rbx
     97a:	mov    rsi,QWORD PTR [rsp+0x40]
     97f:	call   984 <botlish_fn_9+0x10e>
			980: R_X86_64_PLT32	rt_str_region_eq-0x4
     984:	cmp    rax,0x6
     988:	je     998 <botlish_fn_9+0x122>
     98e:	mov    eax,0x2
     993:	jmp    9a7 <botlish_fn_9+0x131>
     998:	mov    eax,0x6
     99d:	jmp    9a7 <botlish_fn_9+0x131>
     9a2:	mov    eax,0x6
     9a7:	cmp    rax,0x6
     9ab:	je     a22 <botlish_fn_9+0x1ac>
     9b1:	mov    QWORD PTR [rsp+0x18],0x3
     9ba:	mov    rsi,QWORD PTR [rsp+0x38]
     9bf:	test   rsi,0x1
     9c6:	je     9ed <botlish_fn_9+0x177>
     9cc:	mov    rsi,QWORD PTR [rsp+0x38]
     9d1:	mov    rax,rsi
     9d4:	add    rax,0x2
     9d8:	seto   sil
     9dc:	test   sil,sil
     9df:	jne    9ed <botlish_fn_9+0x177>
     9e5:	mov    rsi,r15
     9e8:	jmp    a04 <botlish_fn_9+0x18e>
     9ed:	mov    edx,0x3
     9f2:	mov    rsi,QWORD PTR [rsp+0x38]
     9f7:	mov    rdi,QWORD PTR [rsp+0x30]
     9fc:	call   a01 <botlish_fn_9+0x18b>
			9fd: R_X86_64_PLT32	rt_int_add-0x4
     a01:	mov    rsi,r15
     a04:	mov    QWORD PTR [rsp],rsi
     a08:	mov    rdx,r14
     a0b:	mov    QWORD PTR [rsp+0x8],rdx
     a10:	mov    QWORD PTR [rsp+0x10],rax
     a15:	mov    r15,rsi
     a18:	mov    QWORD PTR [rsp+0x38],rax
     a1d:	jmp    8c6 <botlish_fn_9+0x50>
     a22:	mov    rdx,r14
     a25:	mov    rsi,r15
     a28:	mov    rdi,QWORD PTR [rsp+0x30]
     a2d:	mov    rcx,QWORD PTR [rsp+0x38]
     a32:	call   a37 <botlish_fn_9+0x1c1>
			a33: R_X86_64_PLT32	rt_substr-0x4
     a37:	test   rax,rax
     a3a:	jne    a6b <botlish_fn_9+0x1f5>
     a40:	xor    rdx,rdx
     a43:	mov    rax,rdx
     a46:	mov    rbx,QWORD PTR [rsp+0x50]
     a4b:	mov    r12,QWORD PTR [rsp+0x58]
     a50:	mov    r13,QWORD PTR [rsp+0x60]
     a55:	mov    r14,QWORD PTR [rsp+0x68]
     a5a:	mov    r15,QWORD PTR [rsp+0x70]
     a5f:	add    rsp,0x80
     a66:	mov    rsp,rbp
     a69:	pop    rbp
     a6a:	ret
     a6b:	mov    rdx,QWORD PTR [rsp+0x38]
     a70:	mov    rbx,QWORD PTR [rsp+0x50]
     a75:	mov    r12,QWORD PTR [rsp+0x58]
     a7a:	mov    r13,QWORD PTR [rsp+0x60]
     a7f:	mov    r14,QWORD PTR [rsp+0x68]
     a84:	mov    r15,QWORD PTR [rsp+0x70]
     a89:	add    rsp,0x80
     a90:	mov    rsp,rbp
     a93:	pop    rbp
     a94:	ret

0000000000000a95 <botlish_entry_9: scan_unquoted<str, int, int>>:
     a95:	push   rbp
     a96:	mov    rbp,rsp
     a99:	ud2

0000000000000a9b <botlish_fn_10: scan_quoted<str, int, str>>:
     a9b:	push   rbp
     a9c:	mov    rbp,rsp
     a9f:	sub    rsp,0x70
     aa3:	mov    QWORD PTR [rsp+0x40],rbx
     aa8:	mov    QWORD PTR [rsp+0x48],r12
     aad:	mov    QWORD PTR [rsp+0x50],r13
     ab2:	mov    QWORD PTR [rsp+0x58],r14
     ab7:	mov    QWORD PTR [rsp+0x60],r15
     abc:	mov    r13,rdi
     abf:	mov    QWORD PTR [rsp+0x18],0x0
     ac8:	mov    QWORD PTR [rsp+0x20],0x0
     ad1:	mov    QWORD PTR [rsp],rsi
     ad5:	mov    QWORD PTR [rsp+0x8],rdx
     ada:	mov    QWORD PTR [rsp+0x10],rcx
     adf:	lea    r12,[rsp+0x28]
     ae4:	mov    rbx,rsi
     ae7:	mov    r14,rdx
     aea:	mov    r15,rcx
     aed:	mov    rdx,r14
     af0:	mov    rsi,rbx
     af3:	mov    rdi,r13
     af6:	call   afb <botlish_fn_10+0x60>
			af7: R_X86_64_PLT32	botlish_fn_7-0x4 ; peek<str, int>
     afb:	test   rax,rax
     afe:	je     d1a <botlish_fn_10+0x27f>
     b04:	mov    QWORD PTR [rsp+0x18],rax
     b09:	mov    rdi,r13
     b0c:	mov    QWORD PTR [rsp+0x38],rax
     b11:	mov    rcx,QWORD PTR [rdi+0x10]
     b15:	mov    rsi,QWORD PTR [rcx+0x20]
     b19:	mov    edx,0x1
     b1e:	mov    ecx,0x3
     b23:	mov    r8,QWORD PTR [rsp+0x38]
     b28:	call   b2d <botlish_fn_10+0x92>
			b29: R_X86_64_PLT32	rt_str_region_eq-0x4
     b2d:	cmp    rax,0x6
     b31:	je     bb4 <botlish_fn_10+0x119>
     b37:	mov    QWORD PTR [rsp+0x20],0x3
     b40:	mov    rsi,r14
     b43:	test   rsi,0x1
     b4a:	je     b6a <botlish_fn_10+0xcf>
     b50:	mov    rax,rsi
     b53:	add    rax,0x2
     b57:	seto   cl
     b5a:	test   cl,cl
     b5c:	jne    b6a <botlish_fn_10+0xcf>
     b62:	mov    rsi,rax
     b65:	jmp    b7a <botlish_fn_10+0xdf>
     b6a:	mov    edx,0x3
     b6f:	mov    rdi,r13
     b72:	call   b77 <botlish_fn_10+0xdc>
			b73: R_X86_64_PLT32	rt_int_add-0x4
     b77:	mov    rsi,rax
     b7a:	mov    QWORD PTR [rsp+0x8],rsi
     b7f:	mov    r14,rsi
     b82:	mov    rsi,r15
     b85:	mov    rdx,QWORD PTR [rsp+0x38]
     b8a:	mov    rdi,r13
     b8d:	call   b92 <botlish_fn_10+0xf7>
			b8e: R_X86_64_PLT32	rt_str_cat-0x4
     b92:	test   rax,rax
     b95:	je     d1a <botlish_fn_10+0x27f>
     b9b:	mov    QWORD PTR [rsp],rbx
     b9f:	mov    rsi,r14
     ba2:	mov    QWORD PTR [rsp+0x8],rsi
     ba7:	mov    QWORD PTR [rsp+0x10],rax
     bac:	mov    r15,rax
     baf:	jmp    aed <botlish_fn_10+0x52>
     bb4:	mov    QWORD PTR [rsp+0x18],0x3
     bbd:	mov    rsi,r14
     bc0:	test   rsi,0x1
     bc7:	je     be2 <botlish_fn_10+0x147>
     bcd:	mov    rsi,r14
     bd0:	mov    rdx,rsi
     bd3:	add    rdx,0x2
     bd7:	seto   al
     bda:	test   al,al
     bdc:	je     bf5 <botlish_fn_10+0x15a>
     be2:	mov    edx,0x3
     be7:	mov    rsi,r14
     bea:	mov    rdi,r13
     bed:	call   bf2 <botlish_fn_10+0x157>
			bee: R_X86_64_PLT32	rt_int_add-0x4
     bf2:	mov    rdx,rax
     bf5:	mov    QWORD PTR [rsp+0x18],rdx
     bfa:	mov    rcx,r12
     bfd:	mov    rsi,rbx
     c00:	mov    rdi,r13
     c03:	call   c08 <botlish_fn_10+0x16d>
			c04: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     c08:	test   rax,rax
     c0b:	mov    rsi,rax
     c0e:	je     d1a <botlish_fn_10+0x27f>
     c14:	mov    rdx,QWORD PTR [rsp+0x28]
     c19:	mov    rcx,QWORD PTR [rsp+0x30]
     c1e:	mov    rdi,r13
     c21:	mov    rax,QWORD PTR [rdi+0x10]
     c25:	mov    r8,QWORD PTR [rax+0x20]
     c29:	call   c2e <botlish_fn_10+0x193>
			c2a: R_X86_64_PLT32	rt_str_region_eq-0x4
     c2e:	cmp    rax,0x6
     c32:	je     ca5 <botlish_fn_10+0x20a>
     c38:	mov    QWORD PTR [rsp],0x3
     c40:	mov    rsi,r14
     c43:	test   rsi,0x1
     c4a:	je     c6d <botlish_fn_10+0x1d2>
     c50:	mov    rsi,r14
     c53:	mov    rdx,rsi
     c56:	add    rdx,0x2
     c5a:	seto   al
     c5d:	test   al,al
     c5f:	jne    c6d <botlish_fn_10+0x1d2>
     c65:	mov    rax,r15
     c68:	jmp    c83 <botlish_fn_10+0x1e8>
     c6d:	mov    edx,0x3
     c72:	mov    rsi,r14
     c75:	mov    rdi,r13
     c78:	call   c7d <botlish_fn_10+0x1e2>
			c79: R_X86_64_PLT32	rt_int_add-0x4
     c7d:	mov    rdx,rax
     c80:	mov    rax,r15
     c83:	mov    rbx,QWORD PTR [rsp+0x40]
     c88:	mov    r12,QWORD PTR [rsp+0x48]
     c8d:	mov    r13,QWORD PTR [rsp+0x50]
     c92:	mov    r14,QWORD PTR [rsp+0x58]
     c97:	mov    r15,QWORD PTR [rsp+0x60]
     c9c:	add    rsp,0x70
     ca0:	mov    rsp,rbp
     ca3:	pop    rbp
     ca4:	ret
     ca5:	mov    QWORD PTR [rsp+0x18],0x5
     cae:	mov    rsi,r14
     cb1:	test   rsi,0x1
     cb8:	je     cde <botlish_fn_10+0x243>
     cbe:	mov    rsi,r14
     cc1:	mov    rax,rsi
     cc4:	add    rax,0x4
     cc8:	seto   cl
     ccb:	test   cl,cl
     ccd:	jne    cde <botlish_fn_10+0x243>
     cd3:	mov    rsi,rax
     cd6:	mov    r14,rax
     cd9:	jmp    cf4 <botlish_fn_10+0x259>
     cde:	mov    edx,0x5
     ce3:	mov    rsi,r14
     ce6:	mov    rdi,r13
     ce9:	call   cee <botlish_fn_10+0x253>
			cea: R_X86_64_PLT32	rt_int_add-0x4
     cee:	mov    rsi,rax
     cf1:	mov    r14,rax
     cf4:	mov    QWORD PTR [rsp+0x8],rsi
     cf9:	mov    rdi,r13
     cfc:	mov    rax,QWORD PTR [rdi+0x10]
     d00:	mov    rdx,QWORD PTR [rax+0x20]
     d04:	mov    QWORD PTR [rsp+0x18],rdx
     d09:	mov    rsi,r15
     d0c:	call   d11 <botlish_fn_10+0x276>
			d0d: R_X86_64_PLT32	rt_str_cat-0x4
     d11:	test   rax,rax
     d14:	jne    d42 <botlish_fn_10+0x2a7>
     d1a:	xor    rdx,rdx
     d1d:	mov    rax,rdx
     d20:	mov    rbx,QWORD PTR [rsp+0x40]
     d25:	mov    r12,QWORD PTR [rsp+0x48]
     d2a:	mov    r13,QWORD PTR [rsp+0x50]
     d2f:	mov    r14,QWORD PTR [rsp+0x58]
     d34:	mov    r15,QWORD PTR [rsp+0x60]
     d39:	add    rsp,0x70
     d3d:	mov    rsp,rbp
     d40:	pop    rbp
     d41:	ret
     d42:	mov    QWORD PTR [rsp],rbx
     d46:	mov    rsi,r14
     d49:	mov    QWORD PTR [rsp+0x8],rsi
     d4e:	mov    QWORD PTR [rsp+0x10],rax
     d53:	mov    r15,rax
     d56:	jmp    aed <botlish_fn_10+0x52>

0000000000000d5b <botlish_entry_10: scan_quoted<str, int, str>>:
     d5b:	push   rbp
     d5c:	mov    rbp,rsp
     d5f:	ud2

0000000000000d61 <botlish_fn_11: scan_field<str, int>>:
     d61:	push   rbp
     d62:	mov    rbp,rsp
     d65:	sub    rsp,0x50
     d69:	mov    QWORD PTR [rsp+0x30],rbx
     d6e:	mov    QWORD PTR [rsp+0x38],r12
     d73:	mov    QWORD PTR [rsp+0x40],r13
     d78:	mov    r12,rdi
     d7b:	mov    r13,rdx
     d7e:	mov    QWORD PTR [rsp+0x10],0x0
     d87:	mov    QWORD PTR [rsp],rsi
     d8b:	mov    rbx,rsi
     d8e:	mov    QWORD PTR [rsp+0x8],rdx
     d93:	lea    rcx,[rsp+0x18]
     d98:	mov    rdx,r13
     d9b:	mov    rsi,rbx
     d9e:	mov    rdi,r12
     da1:	call   da6 <botlish_fn_11+0x45>
			da2: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     da6:	test   rax,rax
     da9:	mov    rsi,rax
     dac:	je     e77 <botlish_fn_11+0x116>
     db2:	mov    rdx,QWORD PTR [rsp+0x18]
     db7:	mov    rcx,QWORD PTR [rsp+0x20]
     dbc:	mov    rdi,r12
     dbf:	mov    rax,QWORD PTR [rdi+0x10]
     dc3:	mov    r8,QWORD PTR [rax+0x20]
     dc7:	call   dcc <botlish_fn_11+0x6b>
			dc8: R_X86_64_PLT32	rt_str_region_eq-0x4
     dcc:	cmp    rax,0x6
     dd0:	je     e08 <botlish_fn_11+0xa7>
     dd6:	mov    rcx,r13
     dd9:	mov    rsi,rbx
     ddc:	mov    rdi,r12
     ddf:	mov    rdx,rcx
     de2:	call   de7 <botlish_fn_11+0x86>
			de3: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_unquoted<str, int, int>
     de7:	test   rax,rax
     dea:	je     e77 <botlish_fn_11+0x116>
     df0:	mov    rbx,QWORD PTR [rsp+0x30]
     df5:	mov    r12,QWORD PTR [rsp+0x38]
     dfa:	mov    r13,QWORD PTR [rsp+0x40]
     dff:	add    rsp,0x50
     e03:	mov    rsp,rbp
     e06:	pop    rbp
     e07:	ret
     e08:	mov    rcx,r13
     e0b:	mov    QWORD PTR [rsp+0x10],0x3
     e14:	test   rcx,0x1
     e1b:	jne    e29 <botlish_fn_11+0xc8>
     e21:	mov    r13,rcx
     e24:	jmp    e3e <botlish_fn_11+0xdd>
     e29:	mov    rdx,rcx
     e2c:	add    rdx,0x2
     e30:	mov    r13,rcx
     e33:	seto   al
     e36:	test   al,al
     e38:	je     e51 <botlish_fn_11+0xf0>
     e3e:	mov    edx,0x3
     e43:	mov    rsi,r13
     e46:	mov    rdi,r12
     e49:	call   e4e <botlish_fn_11+0xed>
			e4a: R_X86_64_PLT32	rt_int_add-0x4
     e4e:	mov    rdx,rax
     e51:	mov    QWORD PTR [rsp+0x8],rdx
     e56:	mov    rdi,r12
     e59:	mov    rax,QWORD PTR [rdi+0x10]
     e5d:	mov    rcx,QWORD PTR [rax+0x8]
     e61:	mov    QWORD PTR [rsp+0x10],rcx
     e66:	mov    rsi,rbx
     e69:	call   e6e <botlish_fn_11+0x10d>
			e6a: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_quoted<str, int, str>
     e6e:	test   rax,rax
     e71:	jne    e95 <botlish_fn_11+0x134>
     e77:	xor    rdx,rdx
     e7a:	mov    rax,rdx
     e7d:	mov    rbx,QWORD PTR [rsp+0x30]
     e82:	mov    r12,QWORD PTR [rsp+0x38]
     e87:	mov    r13,QWORD PTR [rsp+0x40]
     e8c:	add    rsp,0x50
     e90:	mov    rsp,rbp
     e93:	pop    rbp
     e94:	ret
     e95:	mov    rbx,QWORD PTR [rsp+0x30]
     e9a:	mov    r12,QWORD PTR [rsp+0x38]
     e9f:	mov    r13,QWORD PTR [rsp+0x40]
     ea4:	add    rsp,0x50
     ea8:	mov    rsp,rbp
     eab:	pop    rbp
     eac:	ret

0000000000000ead <botlish_entry_11: scan_field<str, int>>:
     ead:	push   rbp
     eae:	mov    rbp,rsp
     eb1:	ud2

0000000000000eb3 <botlish_fn_12: scan_record<str, int, list[mutarray, int]>>:
     eb3:	push   rbp
     eb4:	mov    rbp,rsp
     eb7:	sub    rsp,0x90
     ebe:	mov    QWORD PTR [rsp+0x60],rbx
     ec3:	mov    QWORD PTR [rsp+0x68],r12
     ec8:	mov    QWORD PTR [rsp+0x70],r13
     ecd:	mov    QWORD PTR [rsp+0x78],r14
     ed2:	mov    QWORD PTR [rsp+0x80],r15
     eda:	mov    r15,rdi
     edd:	mov    QWORD PTR [rsp+0x20],0x0
     ee6:	mov    QWORD PTR [rsp],rsi
     eea:	mov    QWORD PTR [rsp+0x8],rdx
     eef:	mov    QWORD PTR [rsp+0x10],rcx
     ef4:	mov    QWORD PTR [rsp+0x18],r8
     ef9:	lea    r14,[rsp+0x28]
     efe:	mov    rbx,rsi
     f01:	mov    r12,r8
     f04:	mov    r13,rcx
     f07:	mov    rsi,rbx
     f0a:	mov    rdi,r15
     f0d:	call   f12 <botlish_fn_12+0x5f>
			f0e: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_field<str, int>
     f12:	test   rax,rax
     f15:	je     1030 <botlish_fn_12+0x17d>
     f1b:	mov    QWORD PTR [rsp+0x8],rax
     f20:	mov    rcx,rax
     f23:	mov    QWORD PTR [rsp+0x20],rdx
     f28:	mov    QWORD PTR [rsp+0x50],rdx
     f2d:	mov    rsi,r13
     f30:	mov    rdx,r12
     f33:	mov    rdi,r15
     f36:	call   f3b <botlish_fn_12+0x88>
			f37: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_append<list[mutarray, int], str>
     f3b:	test   rax,rax
     f3e:	je     1030 <botlish_fn_12+0x17d>
     f44:	mov    QWORD PTR [rsp+0x8],rax
     f49:	mov    QWORD PTR [rsp+0x40],rax
     f4e:	mov    QWORD PTR [rsp+0x10],rdx
     f53:	mov    QWORD PTR [rsp+0x48],rdx
     f58:	mov    rcx,r14
     f5b:	mov    rdx,QWORD PTR [rsp+0x50]
     f60:	mov    rsi,rbx
     f63:	mov    rdi,r15
     f66:	call   f6b <botlish_fn_12+0xb8>
			f67: R_X86_64_PLT32	botlish_fn_8-0x4 ; peek<str, int>
     f6b:	test   rax,rax
     f6e:	mov    QWORD PTR [rsp+0x38],rax
     f73:	je     1030 <botlish_fn_12+0x17d>
     f79:	mov    r12,QWORD PTR [rsp+0x28]
     f7e:	mov    r13,QWORD PTR [rsp+0x30]
     f83:	mov    rdi,r15
     f86:	mov    rcx,QWORD PTR [rdi+0x10]
     f8a:	mov    r8,QWORD PTR [rcx+0x10]
     f8e:	mov    rcx,r13
     f91:	mov    rdx,r12
     f94:	mov    rsi,QWORD PTR [rsp+0x38]
     f99:	call   f9e <botlish_fn_12+0xeb>
			f9a: R_X86_64_PLT32	rt_str_region_eq-0x4
     f9e:	cmp    rax,0x6
     fa2:	je     10de <botlish_fn_12+0x22b>
     fa8:	mov    rdi,r15
     fab:	mov    rax,QWORD PTR [rdi+0x10]
     faf:	mov    r8,QWORD PTR [rax+0x18]
     fb3:	mov    rcx,r13
     fb6:	mov    rdx,r12
     fb9:	mov    rsi,QWORD PTR [rsp+0x38]
     fbe:	call   fc3 <botlish_fn_12+0x110>
			fbf: R_X86_64_PLT32	rt_str_region_eq-0x4
     fc3:	cmp    rax,0x6
     fc7:	je     1015 <botlish_fn_12+0x162>
     fcd:	mov    rdx,QWORD PTR [rsp+0x48]
     fd2:	mov    rsi,QWORD PTR [rsp+0x40]
     fd7:	mov    rdi,r15
     fda:	call   fdf <botlish_fn_12+0x12c>
			fdb: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
     fdf:	test   rax,rax
     fe2:	je     1030 <botlish_fn_12+0x17d>
     fe8:	mov    rdx,QWORD PTR [rsp+0x50]
     fed:	mov    rbx,QWORD PTR [rsp+0x60]
     ff2:	mov    r12,QWORD PTR [rsp+0x68]
     ff7:	mov    r13,QWORD PTR [rsp+0x70]
     ffc:	mov    r14,QWORD PTR [rsp+0x78]
    1001:	mov    r15,QWORD PTR [rsp+0x80]
    1009:	add    rsp,0x90
    1010:	mov    rsp,rbp
    1013:	pop    rbp
    1014:	ret
    1015:	mov    rdx,QWORD PTR [rsp+0x48]
    101a:	mov    rsi,QWORD PTR [rsp+0x40]
    101f:	mov    rdi,r15
    1022:	call   1027 <botlish_fn_12+0x174>
			1023: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    1027:	test   rax,rax
    102a:	jne    105e <botlish_fn_12+0x1ab>
    1030:	xor    rdx,rdx
    1033:	mov    rax,rdx
    1036:	mov    rbx,QWORD PTR [rsp+0x60]
    103b:	mov    r12,QWORD PTR [rsp+0x68]
    1040:	mov    r13,QWORD PTR [rsp+0x70]
    1045:	mov    r14,QWORD PTR [rsp+0x78]
    104a:	mov    r15,QWORD PTR [rsp+0x80]
    1052:	add    rsp,0x90
    1059:	mov    rsp,rbp
    105c:	pop    rbp
    105d:	ret
    105e:	mov    QWORD PTR [rsp],rax
    1062:	mov    r12,rax
    1065:	mov    QWORD PTR [rsp+0x8],0x3
    106e:	mov    rdx,QWORD PTR [rsp+0x50]
    1073:	test   rdx,0x1
    107a:	je     109e <botlish_fn_12+0x1eb>
    1080:	mov    rdx,QWORD PTR [rsp+0x50]
    1085:	add    rdx,0x2
    1089:	seto   r10b
    108d:	test   r10b,r10b
    1090:	jne    109e <botlish_fn_12+0x1eb>
    1096:	mov    rax,r12
    1099:	jmp    10b6 <botlish_fn_12+0x203>
    109e:	mov    edx,0x3
    10a3:	mov    rsi,QWORD PTR [rsp+0x50]
    10a8:	mov    rdi,r15
    10ab:	call   10b0 <botlish_fn_12+0x1fd>
			10ac: R_X86_64_PLT32	rt_int_add-0x4
    10b0:	mov    rdx,rax
    10b3:	mov    rax,r12
    10b6:	mov    rbx,QWORD PTR [rsp+0x60]
    10bb:	mov    r12,QWORD PTR [rsp+0x68]
    10c0:	mov    r13,QWORD PTR [rsp+0x70]
    10c5:	mov    r14,QWORD PTR [rsp+0x78]
    10ca:	mov    r15,QWORD PTR [rsp+0x80]
    10d2:	add    rsp,0x90
    10d9:	mov    rsp,rbp
    10dc:	pop    rbp
    10dd:	ret
    10de:	mov    rsi,QWORD PTR [rsp+0x50]
    10e3:	mov    edx,0x3
    10e8:	mov    rcx,rdx
    10eb:	mov    QWORD PTR [rsp+0x18],0x3
    10f4:	test   rsi,0x1
    10fb:	jne    1109 <botlish_fn_12+0x256>
    1101:	mov    rdx,rcx
    1104:	jmp    111e <botlish_fn_12+0x26b>
    1109:	mov    rdx,rsi
    110c:	add    rdx,0x2
    1110:	seto   al
    1113:	test   al,al
    1115:	je     1129 <botlish_fn_12+0x276>
    111b:	mov    rdx,rcx
    111e:	mov    rdi,r15
    1121:	call   1126 <botlish_fn_12+0x273>
			1122: R_X86_64_PLT32	rt_int_add-0x4
    1126:	mov    rdx,rax
    1129:	mov    QWORD PTR [rsp],rbx
    112d:	mov    QWORD PTR [rsp+0x8],rdx
    1132:	mov    rsi,QWORD PTR [rsp+0x40]
    1137:	mov    QWORD PTR [rsp+0x10],rsi
    113c:	mov    r11,QWORD PTR [rsp+0x48]
    1141:	mov    QWORD PTR [rsp+0x18],r11
    1146:	mov    r12,r11
    1149:	mov    r13,rsi
    114c:	jmp    f07 <botlish_fn_12+0x54>

0000000000001151 <botlish_entry_12: scan_record<str, int, list[mutarray, int]>>:
    1151:	push   rbp
    1152:	mov    rbp,rsp
    1155:	ud2
	...

0000000000001158 <botlish_fn_13: scan_records<str, int, list[mutarray, int]>>:
    1158:	push   rbp
    1159:	mov    rbp,rsp
    115c:	sub    rsp,0x60
    1160:	mov    QWORD PTR [rsp+0x30],rbx
    1165:	mov    QWORD PTR [rsp+0x38],r12
    116a:	mov    QWORD PTR [rsp+0x40],r13
    116f:	mov    QWORD PTR [rsp+0x48],r14
    1174:	mov    QWORD PTR [rsp+0x50],r15
    1179:	mov    r13,rdi
    117c:	mov    QWORD PTR [rsp+0x20],0x0
    1185:	mov    QWORD PTR [rsp+0x28],0x0
    118e:	mov    QWORD PTR [rsp],rsi
    1192:	mov    QWORD PTR [rsp+0x8],rdx
    1197:	mov    r12,rdx
    119a:	mov    QWORD PTR [rsp+0x10],rcx
    119f:	mov    QWORD PTR [rsp+0x18],r8
    11a4:	mov    rbx,rsi
    11a7:	mov    r14,r8
    11aa:	mov    r15,rcx
    11ad:	mov    rsi,rbx
    11b0:	mov    rdi,r13
    11b3:	call   11b8 <botlish_fn_13+0x60>
			11b4: R_X86_64_PLT32	rt_str_len-0x4
    11b8:	mov    rcx,r12
    11bb:	and    rcx,rax
    11be:	mov    rdx,rax
    11c1:	test   rcx,0x1
    11c8:	jne    11ee <botlish_fn_13+0x96>
    11ce:	mov    rsi,r12
    11d1:	mov    rdi,r13
    11d4:	call   11d9 <botlish_fn_13+0x81>
			11d5: R_X86_64_PLT32	rt_int_cmp-0x4
    11d9:	mov    ecx,0x2
    11de:	test   rax,rax
    11e1:	cmovge rcx,QWORD PTR [rip+0x107]        # 12f0 <botlish_fn_13+0x198>
    11e9:	jmp    1201 <botlish_fn_13+0xa9>
    11ee:	mov    ecx,0x2
    11f3:	mov    rax,r12
    11f6:	cmp    rax,rdx
    11f9:	cmovge rcx,QWORD PTR [rip+0xef]        # 12f0 <botlish_fn_13+0x198>
    1201:	cmp    rcx,0x6
    1205:	je     128b <botlish_fn_13+0x133>
    120b:	mov    rdi,r13
    120e:	call   1213 <botlish_fn_13+0xbb>
			120f: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1213:	test   rax,rax
    1216:	je     12a2 <botlish_fn_13+0x14a>
    121c:	mov    QWORD PTR [rsp+0x20],rax
    1221:	mov    rcx,rax
    1224:	mov    QWORD PTR [rsp+0x28],rdx
    1229:	mov    r8,rdx
    122c:	mov    rdx,r12
    122f:	mov    rsi,rbx
    1232:	mov    rdi,r13
    1235:	call   123a <botlish_fn_13+0xe2>
			1236: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_record<str, int, list[mutarray, int]>
    123a:	test   rax,rax
    123d:	je     12a2 <botlish_fn_13+0x14a>
    1243:	mov    QWORD PTR [rsp+0x8],rax
    1248:	mov    rcx,rax
    124b:	mov    QWORD PTR [rsp+0x20],rdx
    1250:	mov    r12,rdx
    1253:	mov    rsi,r15
    1256:	mov    rdx,r14
    1259:	mov    rdi,r13
    125c:	call   1261 <botlish_fn_13+0x109>
			125d: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_append<list[mutarray, int], list>
    1261:	test   rax,rax
    1264:	je     12a2 <botlish_fn_13+0x14a>
    126a:	mov    QWORD PTR [rsp],rbx
    126e:	mov    rcx,r12
    1271:	mov    QWORD PTR [rsp+0x8],rcx
    1276:	mov    QWORD PTR [rsp+0x10],rax
    127b:	mov    QWORD PTR [rsp+0x18],rdx
    1280:	mov    r14,rdx
    1283:	mov    r15,rax
    1286:	jmp    11ad <botlish_fn_13+0x55>
    128b:	mov    rdx,r14
    128e:	mov    rsi,r15
    1291:	mov    rdi,r13
    1294:	call   1299 <botlish_fn_13+0x141>
			1295: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_finish<list[mutarray, int]>
    1299:	test   rax,rax
    129c:	jne    12c7 <botlish_fn_13+0x16f>
    12a2:	xor    rax,rax
    12a5:	mov    rbx,QWORD PTR [rsp+0x30]
    12aa:	mov    r12,QWORD PTR [rsp+0x38]
    12af:	mov    r13,QWORD PTR [rsp+0x40]
    12b4:	mov    r14,QWORD PTR [rsp+0x48]
    12b9:	mov    r15,QWORD PTR [rsp+0x50]
    12be:	add    rsp,0x60
    12c2:	mov    rsp,rbp
    12c5:	pop    rbp
    12c6:	ret
    12c7:	mov    rbx,QWORD PTR [rsp+0x30]
    12cc:	mov    r12,QWORD PTR [rsp+0x38]
    12d1:	mov    r13,QWORD PTR [rsp+0x40]
    12d6:	mov    r14,QWORD PTR [rsp+0x48]
    12db:	mov    r15,QWORD PTR [rsp+0x50]
    12e0:	add    rsp,0x60
    12e4:	mov    rsp,rbp
    12e7:	pop    rbp
    12e8:	ret
    12e9:	add    BYTE PTR [rax],al
    12eb:	add    BYTE PTR [rax],al
    12ed:	add    BYTE PTR [rax],al
    12ef:	add    BYTE PTR [rsi],al
    12f1:	add    BYTE PTR [rax],al
    12f3:	add    BYTE PTR [rax],al
    12f5:	add    BYTE PTR [rax],al
	...

00000000000012f8 <botlish_entry_13: scan_records<str, int, list[mutarray, int]>>:
    12f8:	push   rbp
    12f9:	mov    rbp,rsp
    12fc:	mov    rsi,QWORD PTR [rdx]
    12ff:	mov    r9,QWORD PTR [rdx+0x8]
    1303:	mov    rcx,QWORD PTR [rdx+0x10]
    1307:	mov    r8,QWORD PTR [rdx+0x18]
    130b:	mov    rdx,r9
    130e:	call   1313 <botlish_entry_13+0x1b>
			130f: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    1313:	mov    rsp,rbp
    1316:	pop    rbp
    1317:	ret

0000000000001318 <botlish_fn_14: csv_parse<str>>:
    1318:	push   rbp
    1319:	mov    rbp,rsp
    131c:	sub    rsp,0x30
    1320:	mov    QWORD PTR [rsp+0x20],r12
    1325:	mov    QWORD PTR [rsp+0x28],r13
    132a:	mov    r13,rdi
    132d:	mov    QWORD PTR [rsp+0x10],0x0
    1336:	mov    QWORD PTR [rsp+0x18],0x0
    133f:	mov    QWORD PTR [rsp],rsi
    1343:	mov    r12,rsi
    1346:	mov    QWORD PTR [rsp+0x8],0x1
    134f:	mov    rdi,r13
    1352:	call   1357 <botlish_fn_14+0x3f>
			1353: R_X86_64_PLT32	botlish_fn_1-0x4 ; geo_new<generic>
    1357:	test   rax,rax
    135a:	je     1389 <botlish_fn_14+0x71>
    1360:	mov    QWORD PTR [rsp+0x10],rax
    1365:	mov    rcx,rax
    1368:	mov    QWORD PTR [rsp+0x18],rdx
    136d:	mov    r8,rdx
    1370:	mov    edx,0x1
    1375:	mov    rsi,r12
    1378:	mov    rdi,r13
    137b:	call   1380 <botlish_fn_14+0x68>
			137c: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_records<str, int, list[mutarray, int]>
    1380:	test   rax,rax
    1383:	jne    139f <botlish_fn_14+0x87>
    1389:	xor    rax,rax
    138c:	mov    r12,QWORD PTR [rsp+0x20]
    1391:	mov    r13,QWORD PTR [rsp+0x28]
    1396:	add    rsp,0x30
    139a:	mov    rsp,rbp
    139d:	pop    rbp
    139e:	ret
    139f:	mov    r12,QWORD PTR [rsp+0x20]
    13a4:	mov    r13,QWORD PTR [rsp+0x28]
    13a9:	add    rsp,0x30
    13ad:	mov    rsp,rbp
    13b0:	pop    rbp
    13b1:	ret

00000000000013b2 <botlish_entry_14: csv_parse<str>>:
    13b2:	push   rbp
    13b3:	mov    rbp,rsp
    13b6:	mov    rsi,QWORD PTR [rdx]
    13b9:	call   13be <botlish_entry_14+0xc>
			13ba: R_X86_64_PLT32	botlish_fn_14-0x4 ; csv_parse<str>
    13be:	mov    rsp,rbp
    13c1:	pop    rbp
    13c2:	ret

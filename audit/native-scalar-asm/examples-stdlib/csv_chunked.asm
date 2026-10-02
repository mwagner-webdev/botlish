; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10246  (per function: 68 195 534 534 534 534 498 418 540 540 365 430 585 1141 352 799 833 537 612 197)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> chunked_new<generic>
;   botlish_fn_2 / botlish_entry_2 -> chunked_append<list[List[never], mutarray, int], str>
;   botlish_fn_3 / botlish_entry_3 -> chunked_append<list[List[mutarray], mutarray, int], str>
;   botlish_fn_4 / botlish_entry_4 -> chunked_append<list[List[never], mutarray, int], list>
;   botlish_fn_5 / botlish_entry_5 -> chunked_append<list[List[mutarray], mutarray, int], list>
;   botlish_fn_6 / botlish_entry_6 -> chunked_copy_chunks<List[never], int, mutarray, int>
;   botlish_fn_7 / botlish_entry_7 -> chunked_copy_chunks<List[mutarray], int, mutarray, int>
;   botlish_fn_8 / botlish_entry_8 -> chunked_finish<list[List[never], mutarray, int]>
;   botlish_fn_9 / botlish_entry_9 -> chunked_finish<list[List[mutarray], mutarray, int]>
;   botlish_fn_10 / botlish_entry_10 -> peek<str, int>
;   botlish_fn_11 / botlish_entry_11 -> peek<str, int>
;   botlish_fn_12 / botlish_entry_12 -> scan_unquoted<str, int, int>
;   botlish_fn_13 / botlish_entry_13 -> scan_quoted<str, int, str>
;   botlish_fn_14 / botlish_entry_14 -> scan_field<str, int>
;   botlish_fn_15 / botlish_entry_15 -> scan_record<str, int, list[List[never], mutarray, int]>
;   botlish_fn_16 / botlish_entry_16 -> scan_record<str, int, list[List[mutarray], mutarray, int]>
;   botlish_fn_17 / botlish_entry_17 -> scan_records<str, int, list[List[never], mutarray, int]>
;   botlish_fn_18 / botlish_entry_18 -> scan_records<str, int, list[List[mutarray], mutarray, int]>
;   botlish_fn_19 / botlish_entry_19 -> csv_parse<str>


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
			14: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
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

0000000000000044 <botlish_fn_1: chunked_new<generic>>:
      44:	push   rbp
      45:	mov    rbp,rsp
      48:	sub    rsp,0x30
      4c:	mov    QWORD PTR [rsp+0x10],r12
      51:	mov    QWORD PTR [rsp+0x18],r13
      56:	mov    QWORD PTR [rsp+0x20],r15
      5b:	mov    r12,rsi
      5e:	mov    r13,rdi
      61:	mov    QWORD PTR [rsp],0x0
      69:	mov    QWORD PTR [rsp+0x8],0x0
      72:	xor    rdx,rdx
      75:	mov    rdi,r13
      78:	mov    rsi,rdx
      7b:	call   80 <botlish_fn_1+0x3c>
			7c: R_X86_64_PLT32	rt_list_new-0x4
      80:	test   rax,rax
      83:	je     af <botlish_fn_1+0x6b>
      89:	mov    QWORD PTR [rsp],rax
      8d:	mov    r15,rax
      90:	mov    esi,0x81
      95:	mov    QWORD PTR [rsp+0x8],0x81
      9e:	mov    rdi,r13
      a1:	call   a6 <botlish_fn_1+0x62>
			a2: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      a6:	test   rax,rax
      a9:	jne    ca <botlish_fn_1+0x86>
      af:	xor    rax,rax
      b2:	mov    r12,QWORD PTR [rsp+0x10]
      b7:	mov    r13,QWORD PTR [rsp+0x18]
      bc:	mov    r15,QWORD PTR [rsp+0x20]
      c1:	add    rsp,0x30
      c5:	mov    rsp,rbp
      c8:	pop    rbp
      c9:	ret
      ca:	mov    rsi,r12
      cd:	mov    QWORD PTR [rsi],rax
      d0:	mov    QWORD PTR [rsi+0x8],0x1
      d8:	mov    rax,r15
      db:	mov    r12,QWORD PTR [rsp+0x10]
      e0:	mov    r13,QWORD PTR [rsp+0x18]
      e5:	mov    r15,QWORD PTR [rsp+0x20]
      ea:	add    rsp,0x30
      ee:	mov    rsp,rbp
      f1:	pop    rbp
      f2:	ret

00000000000000f3 <botlish_entry_1: chunked_new<generic>>:
      f3:	push   rbp
      f4:	mov    rbp,rsp
      f7:	ud2
      f9:	add    BYTE PTR [rax],al
      fb:	add    BYTE PTR [rax],al
      fd:	add    BYTE PTR [rax],al
	...

0000000000000100 <botlish_fn_2: chunked_append<list[List[never], mutarray, int], str>>:
     100:	push   rbp
     101:	mov    rbp,rsp
     104:	sub    rsp,0x60
     108:	mov    QWORD PTR [rsp+0x30],rbx
     10d:	mov    QWORD PTR [rsp+0x38],r12
     112:	mov    QWORD PTR [rsp+0x40],r13
     117:	mov    QWORD PTR [rsp+0x48],r14
     11c:	mov    QWORD PTR [rsp+0x50],r15
     121:	mov    rbx,rcx
     124:	mov    r12,r9
     127:	mov    r15,rdi
     12a:	mov    QWORD PTR [rsp],rsi
     12e:	mov    r13,rsi
     131:	mov    QWORD PTR [rsp+0x8],rdx
     136:	mov    r14,rdx
     139:	mov    QWORD PTR [rsp+0x10],r8
     13e:	mov    QWORD PTR [rsp+0x20],r8
     143:	mov    rcx,rbx
     146:	test   rcx,0x1
     14d:	jne    178 <botlish_fn_2+0x78>
     153:	mov    edx,0x81
     158:	mov    rsi,rbx
     15b:	mov    rdi,r15
     15e:	call   163 <botlish_fn_2+0x63>
			15f: R_X86_64_PLT32	rt_int_cmp-0x4
     163:	mov    ecx,0x2
     168:	test   rax,rax
     16b:	cmove  rcx,QWORD PTR [rip+0x16d]        # 2e0 <botlish_fn_2+0x1e0>
     173:	jmp    18c <botlish_fn_2+0x8c>
     178:	mov    ecx,0x2
     17d:	cmp    rbx,0x81
     184:	cmove  rcx,QWORD PTR [rip+0x154]        # 2e0 <botlish_fn_2+0x1e0>
     18c:	cmp    rcx,0x6
     190:	je     227 <botlish_fn_2+0x127>
     196:	mov    rcx,QWORD PTR [rsp+0x20]
     19b:	mov    rdx,rbx
     19e:	mov    rsi,r14
     1a1:	mov    rdi,r15
     1a4:	call   1a9 <botlish_fn_2+0xa9>
			1a5: R_X86_64_PLT32	rt_mutarray_set-0x4
     1a9:	test   rax,rax
     1ac:	je     286 <botlish_fn_2+0x186>
     1b2:	mov    QWORD PTR [rsp+0x18],0x3
     1bb:	test   rbx,0x1
     1c2:	je     1e5 <botlish_fn_2+0xe5>
     1c8:	mov    rax,rbx
     1cb:	add    rax,0x2
     1cf:	seto   cl
     1d2:	test   cl,cl
     1d4:	jne    1e5 <botlish_fn_2+0xe5>
     1da:	mov    rdx,r14
     1dd:	mov    rbx,r12
     1e0:	jmp    1fb <botlish_fn_2+0xfb>
     1e5:	mov    edx,0x3
     1ea:	mov    rsi,rbx
     1ed:	mov    rdi,r15
     1f0:	call   1f5 <botlish_fn_2+0xf5>
			1f1: R_X86_64_PLT32	rt_int_add-0x4
     1f5:	mov    rdx,r14
     1f8:	mov    rbx,r12
     1fb:	mov    QWORD PTR [rbx],rdx
     1fe:	mov    QWORD PTR [rbx+0x8],rax
     202:	mov    rax,r13
     205:	mov    rbx,QWORD PTR [rsp+0x30]
     20a:	mov    r12,QWORD PTR [rsp+0x38]
     20f:	mov    r13,QWORD PTR [rsp+0x40]
     214:	mov    r14,QWORD PTR [rsp+0x48]
     219:	mov    r15,QWORD PTR [rsp+0x50]
     21e:	add    rsp,0x60
     222:	mov    rsp,rbp
     225:	pop    rbp
     226:	ret
     227:	mov    rbx,r12
     22a:	mov    esi,0x81
     22f:	mov    QWORD PTR [rsp+0x18],0x81
     238:	mov    rdi,r15
     23b:	call   240 <botlish_fn_2+0x140>
			23c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     240:	test   rax,rax
     243:	je     286 <botlish_fn_2+0x186>
     249:	mov    QWORD PTR [rsp+0x10],rax
     24e:	mov    r12,rax
     251:	mov    edx,0x1
     256:	mov    rcx,QWORD PTR [rsp+0x20]
     25b:	mov    rsi,r12
     25e:	mov    rdi,r15
     261:	call   266 <botlish_fn_2+0x166>
			262: R_X86_64_PLT32	rt_mutarray_set-0x4
     266:	test   rax,rax
     269:	je     286 <botlish_fn_2+0x186>
     26f:	mov    rdx,r14
     272:	mov    rsi,r13
     275:	mov    rdi,r15
     278:	call   27d <botlish_fn_2+0x17d>
			279: R_X86_64_PLT32	rt_list_append-0x4
     27d:	test   rax,rax
     280:	jne    2ab <botlish_fn_2+0x1ab>
     286:	xor    rax,rax
     289:	mov    rbx,QWORD PTR [rsp+0x30]
     28e:	mov    r12,QWORD PTR [rsp+0x38]
     293:	mov    r13,QWORD PTR [rsp+0x40]
     298:	mov    r14,QWORD PTR [rsp+0x48]
     29d:	mov    r15,QWORD PTR [rsp+0x50]
     2a2:	add    rsp,0x60
     2a6:	mov    rsp,rbp
     2a9:	pop    rbp
     2aa:	ret
     2ab:	mov    rcx,r12
     2ae:	mov    QWORD PTR [rbx],rcx
     2b1:	mov    QWORD PTR [rbx+0x8],0x3
     2b9:	mov    rbx,QWORD PTR [rsp+0x30]
     2be:	mov    r12,QWORD PTR [rsp+0x38]
     2c3:	mov    r13,QWORD PTR [rsp+0x40]
     2c8:	mov    r14,QWORD PTR [rsp+0x48]
     2cd:	mov    r15,QWORD PTR [rsp+0x50]
     2d2:	add    rsp,0x60
     2d6:	mov    rsp,rbp
     2d9:	pop    rbp
     2da:	ret
     2db:	add    BYTE PTR [rax],al
     2dd:	add    BYTE PTR [rax],al
     2df:	add    BYTE PTR [rsi],al
     2e1:	add    BYTE PTR [rax],al
     2e3:	add    BYTE PTR [rax],al
     2e5:	add    BYTE PTR [rax],al
	...

00000000000002e8 <botlish_entry_2: chunked_append<list[List[never], mutarray, int], str>>:
     2e8:	push   rbp
     2e9:	mov    rbp,rsp
     2ec:	ud2
	...

00000000000002f0 <botlish_fn_3: chunked_append<list[List[mutarray], mutarray, int], str>>:
     2f0:	push   rbp
     2f1:	mov    rbp,rsp
     2f4:	sub    rsp,0x60
     2f8:	mov    QWORD PTR [rsp+0x30],rbx
     2fd:	mov    QWORD PTR [rsp+0x38],r12
     302:	mov    QWORD PTR [rsp+0x40],r13
     307:	mov    QWORD PTR [rsp+0x48],r14
     30c:	mov    QWORD PTR [rsp+0x50],r15
     311:	mov    rbx,rcx
     314:	mov    r12,r9
     317:	mov    r15,rdi
     31a:	mov    QWORD PTR [rsp],rsi
     31e:	mov    r13,rsi
     321:	mov    QWORD PTR [rsp+0x8],rdx
     326:	mov    r14,rdx
     329:	mov    QWORD PTR [rsp+0x10],r8
     32e:	mov    QWORD PTR [rsp+0x20],r8
     333:	mov    rcx,rbx
     336:	test   rcx,0x1
     33d:	jne    368 <botlish_fn_3+0x78>
     343:	mov    edx,0x81
     348:	mov    rsi,rbx
     34b:	mov    rdi,r15
     34e:	call   353 <botlish_fn_3+0x63>
			34f: R_X86_64_PLT32	rt_int_cmp-0x4
     353:	mov    ecx,0x2
     358:	test   rax,rax
     35b:	cmove  rcx,QWORD PTR [rip+0x16d]        # 4d0 <botlish_fn_3+0x1e0>
     363:	jmp    37c <botlish_fn_3+0x8c>
     368:	mov    ecx,0x2
     36d:	cmp    rbx,0x81
     374:	cmove  rcx,QWORD PTR [rip+0x154]        # 4d0 <botlish_fn_3+0x1e0>
     37c:	cmp    rcx,0x6
     380:	je     417 <botlish_fn_3+0x127>
     386:	mov    rcx,QWORD PTR [rsp+0x20]
     38b:	mov    rdx,rbx
     38e:	mov    rsi,r14
     391:	mov    rdi,r15
     394:	call   399 <botlish_fn_3+0xa9>
			395: R_X86_64_PLT32	rt_mutarray_set-0x4
     399:	test   rax,rax
     39c:	je     476 <botlish_fn_3+0x186>
     3a2:	mov    QWORD PTR [rsp+0x18],0x3
     3ab:	test   rbx,0x1
     3b2:	je     3d5 <botlish_fn_3+0xe5>
     3b8:	mov    rax,rbx
     3bb:	add    rax,0x2
     3bf:	seto   cl
     3c2:	test   cl,cl
     3c4:	jne    3d5 <botlish_fn_3+0xe5>
     3ca:	mov    rdx,r14
     3cd:	mov    rbx,r12
     3d0:	jmp    3eb <botlish_fn_3+0xfb>
     3d5:	mov    edx,0x3
     3da:	mov    rsi,rbx
     3dd:	mov    rdi,r15
     3e0:	call   3e5 <botlish_fn_3+0xf5>
			3e1: R_X86_64_PLT32	rt_int_add-0x4
     3e5:	mov    rdx,r14
     3e8:	mov    rbx,r12
     3eb:	mov    QWORD PTR [rbx],rdx
     3ee:	mov    QWORD PTR [rbx+0x8],rax
     3f2:	mov    rax,r13
     3f5:	mov    rbx,QWORD PTR [rsp+0x30]
     3fa:	mov    r12,QWORD PTR [rsp+0x38]
     3ff:	mov    r13,QWORD PTR [rsp+0x40]
     404:	mov    r14,QWORD PTR [rsp+0x48]
     409:	mov    r15,QWORD PTR [rsp+0x50]
     40e:	add    rsp,0x60
     412:	mov    rsp,rbp
     415:	pop    rbp
     416:	ret
     417:	mov    rbx,r12
     41a:	mov    esi,0x81
     41f:	mov    QWORD PTR [rsp+0x18],0x81
     428:	mov    rdi,r15
     42b:	call   430 <botlish_fn_3+0x140>
			42c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     430:	test   rax,rax
     433:	je     476 <botlish_fn_3+0x186>
     439:	mov    QWORD PTR [rsp+0x10],rax
     43e:	mov    r12,rax
     441:	mov    edx,0x1
     446:	mov    rcx,QWORD PTR [rsp+0x20]
     44b:	mov    rsi,r12
     44e:	mov    rdi,r15
     451:	call   456 <botlish_fn_3+0x166>
			452: R_X86_64_PLT32	rt_mutarray_set-0x4
     456:	test   rax,rax
     459:	je     476 <botlish_fn_3+0x186>
     45f:	mov    rdx,r14
     462:	mov    rsi,r13
     465:	mov    rdi,r15
     468:	call   46d <botlish_fn_3+0x17d>
			469: R_X86_64_PLT32	rt_list_append-0x4
     46d:	test   rax,rax
     470:	jne    49b <botlish_fn_3+0x1ab>
     476:	xor    rax,rax
     479:	mov    rbx,QWORD PTR [rsp+0x30]
     47e:	mov    r12,QWORD PTR [rsp+0x38]
     483:	mov    r13,QWORD PTR [rsp+0x40]
     488:	mov    r14,QWORD PTR [rsp+0x48]
     48d:	mov    r15,QWORD PTR [rsp+0x50]
     492:	add    rsp,0x60
     496:	mov    rsp,rbp
     499:	pop    rbp
     49a:	ret
     49b:	mov    rcx,r12
     49e:	mov    QWORD PTR [rbx],rcx
     4a1:	mov    QWORD PTR [rbx+0x8],0x3
     4a9:	mov    rbx,QWORD PTR [rsp+0x30]
     4ae:	mov    r12,QWORD PTR [rsp+0x38]
     4b3:	mov    r13,QWORD PTR [rsp+0x40]
     4b8:	mov    r14,QWORD PTR [rsp+0x48]
     4bd:	mov    r15,QWORD PTR [rsp+0x50]
     4c2:	add    rsp,0x60
     4c6:	mov    rsp,rbp
     4c9:	pop    rbp
     4ca:	ret
     4cb:	add    BYTE PTR [rax],al
     4cd:	add    BYTE PTR [rax],al
     4cf:	add    BYTE PTR [rsi],al
     4d1:	add    BYTE PTR [rax],al
     4d3:	add    BYTE PTR [rax],al
     4d5:	add    BYTE PTR [rax],al
	...

00000000000004d8 <botlish_entry_3: chunked_append<list[List[mutarray], mutarray, int], str>>:
     4d8:	push   rbp
     4d9:	mov    rbp,rsp
     4dc:	ud2
	...

00000000000004e0 <botlish_fn_4: chunked_append<list[List[never], mutarray, int], list>>:
     4e0:	push   rbp
     4e1:	mov    rbp,rsp
     4e4:	sub    rsp,0x60
     4e8:	mov    QWORD PTR [rsp+0x30],rbx
     4ed:	mov    QWORD PTR [rsp+0x38],r12
     4f2:	mov    QWORD PTR [rsp+0x40],r13
     4f7:	mov    QWORD PTR [rsp+0x48],r14
     4fc:	mov    QWORD PTR [rsp+0x50],r15
     501:	mov    rbx,rcx
     504:	mov    r12,r9
     507:	mov    r15,rdi
     50a:	mov    QWORD PTR [rsp],rsi
     50e:	mov    r13,rsi
     511:	mov    QWORD PTR [rsp+0x8],rdx
     516:	mov    r14,rdx
     519:	mov    QWORD PTR [rsp+0x10],r8
     51e:	mov    QWORD PTR [rsp+0x20],r8
     523:	mov    rcx,rbx
     526:	test   rcx,0x1
     52d:	jne    558 <botlish_fn_4+0x78>
     533:	mov    edx,0x81
     538:	mov    rsi,rbx
     53b:	mov    rdi,r15
     53e:	call   543 <botlish_fn_4+0x63>
			53f: R_X86_64_PLT32	rt_int_cmp-0x4
     543:	mov    ecx,0x2
     548:	test   rax,rax
     54b:	cmove  rcx,QWORD PTR [rip+0x16d]        # 6c0 <botlish_fn_4+0x1e0>
     553:	jmp    56c <botlish_fn_4+0x8c>
     558:	mov    ecx,0x2
     55d:	cmp    rbx,0x81
     564:	cmove  rcx,QWORD PTR [rip+0x154]        # 6c0 <botlish_fn_4+0x1e0>
     56c:	cmp    rcx,0x6
     570:	je     607 <botlish_fn_4+0x127>
     576:	mov    rcx,QWORD PTR [rsp+0x20]
     57b:	mov    rdx,rbx
     57e:	mov    rsi,r14
     581:	mov    rdi,r15
     584:	call   589 <botlish_fn_4+0xa9>
			585: R_X86_64_PLT32	rt_mutarray_set-0x4
     589:	test   rax,rax
     58c:	je     666 <botlish_fn_4+0x186>
     592:	mov    QWORD PTR [rsp+0x18],0x3
     59b:	test   rbx,0x1
     5a2:	je     5c5 <botlish_fn_4+0xe5>
     5a8:	mov    rax,rbx
     5ab:	add    rax,0x2
     5af:	seto   cl
     5b2:	test   cl,cl
     5b4:	jne    5c5 <botlish_fn_4+0xe5>
     5ba:	mov    rdx,r14
     5bd:	mov    rbx,r12
     5c0:	jmp    5db <botlish_fn_4+0xfb>
     5c5:	mov    edx,0x3
     5ca:	mov    rsi,rbx
     5cd:	mov    rdi,r15
     5d0:	call   5d5 <botlish_fn_4+0xf5>
			5d1: R_X86_64_PLT32	rt_int_add-0x4
     5d5:	mov    rdx,r14
     5d8:	mov    rbx,r12
     5db:	mov    QWORD PTR [rbx],rdx
     5de:	mov    QWORD PTR [rbx+0x8],rax
     5e2:	mov    rax,r13
     5e5:	mov    rbx,QWORD PTR [rsp+0x30]
     5ea:	mov    r12,QWORD PTR [rsp+0x38]
     5ef:	mov    r13,QWORD PTR [rsp+0x40]
     5f4:	mov    r14,QWORD PTR [rsp+0x48]
     5f9:	mov    r15,QWORD PTR [rsp+0x50]
     5fe:	add    rsp,0x60
     602:	mov    rsp,rbp
     605:	pop    rbp
     606:	ret
     607:	mov    rbx,r12
     60a:	mov    esi,0x81
     60f:	mov    QWORD PTR [rsp+0x18],0x81
     618:	mov    rdi,r15
     61b:	call   620 <botlish_fn_4+0x140>
			61c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     620:	test   rax,rax
     623:	je     666 <botlish_fn_4+0x186>
     629:	mov    QWORD PTR [rsp+0x10],rax
     62e:	mov    r12,rax
     631:	mov    edx,0x1
     636:	mov    rcx,QWORD PTR [rsp+0x20]
     63b:	mov    rsi,r12
     63e:	mov    rdi,r15
     641:	call   646 <botlish_fn_4+0x166>
			642: R_X86_64_PLT32	rt_mutarray_set-0x4
     646:	test   rax,rax
     649:	je     666 <botlish_fn_4+0x186>
     64f:	mov    rdx,r14
     652:	mov    rsi,r13
     655:	mov    rdi,r15
     658:	call   65d <botlish_fn_4+0x17d>
			659: R_X86_64_PLT32	rt_list_append-0x4
     65d:	test   rax,rax
     660:	jne    68b <botlish_fn_4+0x1ab>
     666:	xor    rax,rax
     669:	mov    rbx,QWORD PTR [rsp+0x30]
     66e:	mov    r12,QWORD PTR [rsp+0x38]
     673:	mov    r13,QWORD PTR [rsp+0x40]
     678:	mov    r14,QWORD PTR [rsp+0x48]
     67d:	mov    r15,QWORD PTR [rsp+0x50]
     682:	add    rsp,0x60
     686:	mov    rsp,rbp
     689:	pop    rbp
     68a:	ret
     68b:	mov    rcx,r12
     68e:	mov    QWORD PTR [rbx],rcx
     691:	mov    QWORD PTR [rbx+0x8],0x3
     699:	mov    rbx,QWORD PTR [rsp+0x30]
     69e:	mov    r12,QWORD PTR [rsp+0x38]
     6a3:	mov    r13,QWORD PTR [rsp+0x40]
     6a8:	mov    r14,QWORD PTR [rsp+0x48]
     6ad:	mov    r15,QWORD PTR [rsp+0x50]
     6b2:	add    rsp,0x60
     6b6:	mov    rsp,rbp
     6b9:	pop    rbp
     6ba:	ret
     6bb:	add    BYTE PTR [rax],al
     6bd:	add    BYTE PTR [rax],al
     6bf:	add    BYTE PTR [rsi],al
     6c1:	add    BYTE PTR [rax],al
     6c3:	add    BYTE PTR [rax],al
     6c5:	add    BYTE PTR [rax],al
	...

00000000000006c8 <botlish_entry_4: chunked_append<list[List[never], mutarray, int], list>>:
     6c8:	push   rbp
     6c9:	mov    rbp,rsp
     6cc:	ud2
	...

00000000000006d0 <botlish_fn_5: chunked_append<list[List[mutarray], mutarray, int], list>>:
     6d0:	push   rbp
     6d1:	mov    rbp,rsp
     6d4:	sub    rsp,0x60
     6d8:	mov    QWORD PTR [rsp+0x30],rbx
     6dd:	mov    QWORD PTR [rsp+0x38],r12
     6e2:	mov    QWORD PTR [rsp+0x40],r13
     6e7:	mov    QWORD PTR [rsp+0x48],r14
     6ec:	mov    QWORD PTR [rsp+0x50],r15
     6f1:	mov    rbx,rcx
     6f4:	mov    r12,r9
     6f7:	mov    r15,rdi
     6fa:	mov    QWORD PTR [rsp],rsi
     6fe:	mov    r13,rsi
     701:	mov    QWORD PTR [rsp+0x8],rdx
     706:	mov    r14,rdx
     709:	mov    QWORD PTR [rsp+0x10],r8
     70e:	mov    QWORD PTR [rsp+0x20],r8
     713:	mov    rcx,rbx
     716:	test   rcx,0x1
     71d:	jne    748 <botlish_fn_5+0x78>
     723:	mov    edx,0x81
     728:	mov    rsi,rbx
     72b:	mov    rdi,r15
     72e:	call   733 <botlish_fn_5+0x63>
			72f: R_X86_64_PLT32	rt_int_cmp-0x4
     733:	mov    ecx,0x2
     738:	test   rax,rax
     73b:	cmove  rcx,QWORD PTR [rip+0x16d]        # 8b0 <botlish_fn_5+0x1e0>
     743:	jmp    75c <botlish_fn_5+0x8c>
     748:	mov    ecx,0x2
     74d:	cmp    rbx,0x81
     754:	cmove  rcx,QWORD PTR [rip+0x154]        # 8b0 <botlish_fn_5+0x1e0>
     75c:	cmp    rcx,0x6
     760:	je     7f7 <botlish_fn_5+0x127>
     766:	mov    rcx,QWORD PTR [rsp+0x20]
     76b:	mov    rdx,rbx
     76e:	mov    rsi,r14
     771:	mov    rdi,r15
     774:	call   779 <botlish_fn_5+0xa9>
			775: R_X86_64_PLT32	rt_mutarray_set-0x4
     779:	test   rax,rax
     77c:	je     856 <botlish_fn_5+0x186>
     782:	mov    QWORD PTR [rsp+0x18],0x3
     78b:	test   rbx,0x1
     792:	je     7b5 <botlish_fn_5+0xe5>
     798:	mov    rax,rbx
     79b:	add    rax,0x2
     79f:	seto   cl
     7a2:	test   cl,cl
     7a4:	jne    7b5 <botlish_fn_5+0xe5>
     7aa:	mov    rdx,r14
     7ad:	mov    rbx,r12
     7b0:	jmp    7cb <botlish_fn_5+0xfb>
     7b5:	mov    edx,0x3
     7ba:	mov    rsi,rbx
     7bd:	mov    rdi,r15
     7c0:	call   7c5 <botlish_fn_5+0xf5>
			7c1: R_X86_64_PLT32	rt_int_add-0x4
     7c5:	mov    rdx,r14
     7c8:	mov    rbx,r12
     7cb:	mov    QWORD PTR [rbx],rdx
     7ce:	mov    QWORD PTR [rbx+0x8],rax
     7d2:	mov    rax,r13
     7d5:	mov    rbx,QWORD PTR [rsp+0x30]
     7da:	mov    r12,QWORD PTR [rsp+0x38]
     7df:	mov    r13,QWORD PTR [rsp+0x40]
     7e4:	mov    r14,QWORD PTR [rsp+0x48]
     7e9:	mov    r15,QWORD PTR [rsp+0x50]
     7ee:	add    rsp,0x60
     7f2:	mov    rsp,rbp
     7f5:	pop    rbp
     7f6:	ret
     7f7:	mov    rbx,r12
     7fa:	mov    esi,0x81
     7ff:	mov    QWORD PTR [rsp+0x18],0x81
     808:	mov    rdi,r15
     80b:	call   810 <botlish_fn_5+0x140>
			80c: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     810:	test   rax,rax
     813:	je     856 <botlish_fn_5+0x186>
     819:	mov    QWORD PTR [rsp+0x10],rax
     81e:	mov    r12,rax
     821:	mov    edx,0x1
     826:	mov    rcx,QWORD PTR [rsp+0x20]
     82b:	mov    rsi,r12
     82e:	mov    rdi,r15
     831:	call   836 <botlish_fn_5+0x166>
			832: R_X86_64_PLT32	rt_mutarray_set-0x4
     836:	test   rax,rax
     839:	je     856 <botlish_fn_5+0x186>
     83f:	mov    rdx,r14
     842:	mov    rsi,r13
     845:	mov    rdi,r15
     848:	call   84d <botlish_fn_5+0x17d>
			849: R_X86_64_PLT32	rt_list_append-0x4
     84d:	test   rax,rax
     850:	jne    87b <botlish_fn_5+0x1ab>
     856:	xor    rax,rax
     859:	mov    rbx,QWORD PTR [rsp+0x30]
     85e:	mov    r12,QWORD PTR [rsp+0x38]
     863:	mov    r13,QWORD PTR [rsp+0x40]
     868:	mov    r14,QWORD PTR [rsp+0x48]
     86d:	mov    r15,QWORD PTR [rsp+0x50]
     872:	add    rsp,0x60
     876:	mov    rsp,rbp
     879:	pop    rbp
     87a:	ret
     87b:	mov    rcx,r12
     87e:	mov    QWORD PTR [rbx],rcx
     881:	mov    QWORD PTR [rbx+0x8],0x3
     889:	mov    rbx,QWORD PTR [rsp+0x30]
     88e:	mov    r12,QWORD PTR [rsp+0x38]
     893:	mov    r13,QWORD PTR [rsp+0x40]
     898:	mov    r14,QWORD PTR [rsp+0x48]
     89d:	mov    r15,QWORD PTR [rsp+0x50]
     8a2:	add    rsp,0x60
     8a6:	mov    rsp,rbp
     8a9:	pop    rbp
     8aa:	ret
     8ab:	add    BYTE PTR [rax],al
     8ad:	add    BYTE PTR [rax],al
     8af:	add    BYTE PTR [rsi],al
     8b1:	add    BYTE PTR [rax],al
     8b3:	add    BYTE PTR [rax],al
     8b5:	add    BYTE PTR [rax],al
	...

00000000000008b8 <botlish_entry_5: chunked_append<list[List[mutarray], mutarray, int], list>>:
     8b8:	push   rbp
     8b9:	mov    rbp,rsp
     8bc:	ud2

00000000000008be <botlish_fn_6: chunked_copy_chunks<List[never], int, mutarray, int>>:
     8be:	push   rbp
     8bf:	mov    rbp,rsp
     8c2:	sub    rsp,0x50
     8c6:	mov    QWORD PTR [rsp+0x20],rbx
     8cb:	mov    QWORD PTR [rsp+0x28],r12
     8d0:	mov    QWORD PTR [rsp+0x30],r13
     8d5:	mov    QWORD PTR [rsp+0x38],r14
     8da:	mov    QWORD PTR [rsp+0x40],r15
     8df:	mov    r14,rdi
     8e2:	mov    QWORD PTR [rsp],rsi
     8e6:	mov    QWORD PTR [rsp+0x8],rcx
     8eb:	mov    r12,rcx
     8ee:	mov    QWORD PTR [rsp+0x10],r8
     8f3:	sar    rdx,1
     8f6:	mov    rbx,rdx
     8f9:	mov    r13,rsi
     8fc:	mov    r15,r8
     8ff:	mov    rsi,r13
     902:	mov    rdi,r14
     905:	call   90a <botlish_fn_6+0x4c>
			906: R_X86_64_PLT32	rt_list_len-0x4
     90a:	sar    rax,1
     90d:	cmp    rbx,rax
     910:	jge    a45 <botlish_fn_6+0x187>
     916:	mov    rcx,QWORD PTR [r13+0x8]
     91a:	mov    rax,rbx
     91d:	shl    rax,1
     920:	or     rax,0x1
     924:	sar    rax,1
     927:	cmp    rax,rcx
     92a:	jb     956 <botlish_fn_6+0x98>
     930:	mov    rdx,rbx
     933:	shl    rdx,1
     936:	or     rdx,0x1
     93a:	mov    rsi,r13
     93d:	mov    rdi,r14
     940:	call   945 <botlish_fn_6+0x87>
			941: R_X86_64_PLT32	rt_list_get-0x4
     945:	test   rax,rax
     948:	je     9c1 <botlish_fn_6+0x103>
     94e:	mov    rsi,rax
     951:	jmp    961 <botlish_fn_6+0xa3>
     956:	mov    rcx,QWORD PTR [r13+0x10]
     95a:	mov    rax,QWORD PTR [rcx+rax*8]
     95e:	mov    rsi,rax
     961:	xor    eax,eax
     963:	test   rsi,0x7
     96a:	jne    979 <botlish_fn_6+0xbb>
     970:	movzx  rax,BYTE PTR [rsi]
     974:	cmp    al,0x8
     976:	sete   al
     979:	test   al,al
     97b:	jne    99b <botlish_fn_6+0xdd>
     981:	mov    rdi,r14
     984:	mov    rax,QWORD PTR [rdi+0x10]
     988:	mov    rcx,QWORD PTR [rax+0x8]
     98c:	mov    edx,0x8
     991:	call   996 <botlish_fn_6+0xd8>
			992: R_X86_64_PLT32	rt_type_error-0x4
     996:	jmp    9c1 <botlish_fn_6+0x103>
     99b:	mov    rcx,rsi
     99e:	mov    r8d,0x1
     9a4:	mov    r9d,0x81
     9aa:	mov    rdx,r15
     9ad:	mov    rsi,r12
     9b0:	mov    rdi,r14
     9b3:	call   9b8 <botlish_fn_6+0xfa>
			9b4: R_X86_64_PLT32	rt_mutarray_copy-0x4
     9b8:	test   rax,rax
     9bb:	jne    9e6 <botlish_fn_6+0x128>
     9c1:	xor    rax,rax
     9c4:	mov    rbx,QWORD PTR [rsp+0x20]
     9c9:	mov    r12,QWORD PTR [rsp+0x28]
     9ce:	mov    r13,QWORD PTR [rsp+0x30]
     9d3:	mov    r14,QWORD PTR [rsp+0x38]
     9d8:	mov    r15,QWORD PTR [rsp+0x40]
     9dd:	add    rsp,0x50
     9e1:	mov    rsp,rbp
     9e4:	pop    rbp
     9e5:	ret
     9e6:	mov    QWORD PTR [rsp+0x18],0x81
     9ef:	mov    rsi,r15
     9f2:	test   rsi,0x1
     9f9:	je     a18 <botlish_fn_6+0x15a>
     9ff:	mov    rsi,r15
     a02:	mov    rax,rsi
     a05:	add    rax,0x80
     a0b:	seto   r9b
     a0f:	test   r9b,r9b
     a12:	je     a28 <botlish_fn_6+0x16a>
     a18:	mov    edx,0x81
     a1d:	mov    rsi,r15
     a20:	mov    rdi,r14
     a23:	call   a28 <botlish_fn_6+0x16a>
			a24: R_X86_64_PLT32	rt_int_add-0x4
     a28:	mov    QWORD PTR [rsp],r13
     a2c:	mov    QWORD PTR [rsp+0x8],r12
     a31:	mov    QWORD PTR [rsp+0x10],rax
     a36:	add    rbx,0x1
     a3d:	mov    r15,rax
     a40:	jmp    8ff <botlish_fn_6+0x41>
     a45:	mov    rax,r15
     a48:	mov    rbx,QWORD PTR [rsp+0x20]
     a4d:	mov    r12,QWORD PTR [rsp+0x28]
     a52:	mov    r13,QWORD PTR [rsp+0x30]
     a57:	mov    r14,QWORD PTR [rsp+0x38]
     a5c:	mov    r15,QWORD PTR [rsp+0x40]
     a61:	add    rsp,0x50
     a65:	mov    rsp,rbp
     a68:	pop    rbp
     a69:	ret

0000000000000a6a <botlish_entry_6: chunked_copy_chunks<List[never], int, mutarray, int>>:
     a6a:	push   rbp
     a6b:	mov    rbp,rsp
     a6e:	mov    rsi,QWORD PTR [rdx]
     a71:	mov    r9,QWORD PTR [rdx+0x8]
     a75:	mov    rcx,QWORD PTR [rdx+0x10]
     a79:	mov    r8,QWORD PTR [rdx+0x18]
     a7d:	mov    rdx,r9
     a80:	call   a85 <botlish_entry_6+0x1b>
			a81: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_copy_chunks<List[never], int, mutarray, int>
     a85:	mov    rsp,rbp
     a88:	pop    rbp
     a89:	ret

0000000000000a8a <botlish_fn_7: chunked_copy_chunks<List[mutarray], int, mutarray, int>>:
     a8a:	push   rbp
     a8b:	mov    rbp,rsp
     a8e:	sub    rsp,0x50
     a92:	mov    QWORD PTR [rsp+0x20],rbx
     a97:	mov    QWORD PTR [rsp+0x28],r12
     a9c:	mov    QWORD PTR [rsp+0x30],r13
     aa1:	mov    QWORD PTR [rsp+0x38],r14
     aa6:	mov    QWORD PTR [rsp+0x40],r15
     aab:	mov    r14,rdi
     aae:	mov    QWORD PTR [rsp],rsi
     ab2:	mov    QWORD PTR [rsp+0x8],rcx
     ab7:	mov    r13,rcx
     aba:	mov    QWORD PTR [rsp+0x10],r8
     abf:	sar    rdx,1
     ac2:	mov    rbx,rdx
     ac5:	mov    r12,rsi
     ac8:	mov    r15,r8
     acb:	mov    rsi,r12
     ace:	mov    rdi,r14
     ad1:	call   ad6 <botlish_fn_7+0x4c>
			ad2: R_X86_64_PLT32	rt_list_len-0x4
     ad6:	sar    rax,1
     ad9:	cmp    rbx,rax
     adc:	jge    bcb <botlish_fn_7+0x141>
     ae2:	mov    rdx,QWORD PTR [r12+0x8]
     ae7:	mov    rcx,rbx
     aea:	shl    rcx,1
     aed:	or     rcx,0x1
     af1:	sar    rcx,1
     af4:	cmp    rcx,rdx
     af7:	jb     b23 <botlish_fn_7+0x99>
     afd:	mov    rdx,rbx
     b00:	shl    rdx,1
     b03:	or     rdx,0x1
     b07:	mov    rsi,r12
     b0a:	mov    rdi,r14
     b0d:	call   b12 <botlish_fn_7+0x88>
			b0e: R_X86_64_PLT32	rt_list_get-0x4
     b12:	test   rax,rax
     b15:	je     b4f <botlish_fn_7+0xc5>
     b1b:	mov    rcx,rax
     b1e:	jmp    b2c <botlish_fn_7+0xa2>
     b23:	mov    rax,QWORD PTR [r12+0x10]
     b28:	mov    rcx,QWORD PTR [rax+rcx*8]
     b2c:	mov    r8d,0x1
     b32:	mov    r9d,0x81
     b38:	mov    rdx,r15
     b3b:	mov    rsi,r13
     b3e:	mov    rdi,r14
     b41:	call   b46 <botlish_fn_7+0xbc>
			b42: R_X86_64_PLT32	rt_mutarray_copy-0x4
     b46:	test   rax,rax
     b49:	jne    b74 <botlish_fn_7+0xea>
     b4f:	xor    rax,rax
     b52:	mov    rbx,QWORD PTR [rsp+0x20]
     b57:	mov    r12,QWORD PTR [rsp+0x28]
     b5c:	mov    r13,QWORD PTR [rsp+0x30]
     b61:	mov    r14,QWORD PTR [rsp+0x38]
     b66:	mov    r15,QWORD PTR [rsp+0x40]
     b6b:	add    rsp,0x50
     b6f:	mov    rsp,rbp
     b72:	pop    rbp
     b73:	ret
     b74:	mov    QWORD PTR [rsp+0x18],0x81
     b7d:	mov    rsi,r15
     b80:	test   rsi,0x1
     b87:	je     ba1 <botlish_fn_7+0x117>
     b8d:	mov    rax,rsi
     b90:	add    rax,0x80
     b96:	seto   cl
     b99:	test   cl,cl
     b9b:	je     bae <botlish_fn_7+0x124>
     ba1:	mov    edx,0x81
     ba6:	mov    rdi,r14
     ba9:	call   bae <botlish_fn_7+0x124>
			baa: R_X86_64_PLT32	rt_int_add-0x4
     bae:	mov    QWORD PTR [rsp],r12
     bb2:	mov    QWORD PTR [rsp+0x8],r13
     bb7:	mov    QWORD PTR [rsp+0x10],rax
     bbc:	add    rbx,0x1
     bc3:	mov    r15,rax
     bc6:	jmp    acb <botlish_fn_7+0x41>
     bcb:	mov    rax,r15
     bce:	mov    rbx,QWORD PTR [rsp+0x20]
     bd3:	mov    r12,QWORD PTR [rsp+0x28]
     bd8:	mov    r13,QWORD PTR [rsp+0x30]
     bdd:	mov    r14,QWORD PTR [rsp+0x38]
     be2:	mov    r15,QWORD PTR [rsp+0x40]
     be7:	add    rsp,0x50
     beb:	mov    rsp,rbp
     bee:	pop    rbp
     bef:	ret

0000000000000bf0 <botlish_entry_7: chunked_copy_chunks<List[mutarray], int, mutarray, int>>:
     bf0:	push   rbp
     bf1:	mov    rbp,rsp
     bf4:	mov    rsi,QWORD PTR [rdx]
     bf7:	mov    r9,QWORD PTR [rdx+0x8]
     bfb:	mov    rcx,QWORD PTR [rdx+0x10]
     bff:	mov    r8,QWORD PTR [rdx+0x18]
     c03:	mov    rdx,r9
     c06:	call   c0b <botlish_entry_7+0x1b>
			c07: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<List[mutarray], int, mutarray, int>
     c0b:	mov    rsp,rbp
     c0e:	pop    rbp
     c0f:	ret

0000000000000c10 <botlish_fn_8: chunked_finish<list[List[never], mutarray, int]>>:
     c10:	push   rbp
     c11:	mov    rbp,rsp
     c14:	sub    rsp,0x70
     c18:	mov    QWORD PTR [rsp+0x40],rbx
     c1d:	mov    QWORD PTR [rsp+0x48],r12
     c22:	mov    QWORD PTR [rsp+0x50],r13
     c27:	mov    QWORD PTR [rsp+0x58],r14
     c2c:	mov    QWORD PTR [rsp+0x60],r15
     c31:	mov    r13,rdi
     c34:	mov    QWORD PTR [rsp+0x28],0x0
     c3d:	mov    QWORD PTR [rsp+0x30],0x0
     c46:	mov    QWORD PTR [rsp],rsi
     c4a:	mov    r15,rsi
     c4d:	mov    QWORD PTR [rsp+0x8],rdx
     c52:	mov    r14,rdx
     c55:	mov    QWORD PTR [rsp+0x10],rcx
     c5a:	mov    r12,rcx
     c5d:	mov    rsi,r15
     c60:	mov    rdi,r13
     c63:	call   c68 <botlish_fn_8+0x58>
			c64: R_X86_64_PLT32	rt_list_len-0x4
     c68:	mov    QWORD PTR [rsp+0x18],rax
     c6d:	mov    QWORD PTR [rsp+0x20],0x81
     c76:	test   rax,0x1
     c7c:	mov    rsi,rax
     c7f:	je     cac <botlish_fn_8+0x9c>
     c85:	mov    rdx,rsi
     c88:	mov    rax,rdx
     c8b:	sar    rax,1
     c8e:	imul   QWORD PTR [rip+0x14b]        # de0 <botlish_fn_8+0x1d0>
     c95:	seto   cl
     c98:	or     rax,0x1
     c9c:	test   cl,cl
     c9e:	jne    cac <botlish_fn_8+0x9c>
     ca4:	mov    rsi,rax
     ca7:	jmp    cbc <botlish_fn_8+0xac>
     cac:	mov    edx,0x81
     cb1:	mov    rdi,r13
     cb4:	call   cb9 <botlish_fn_8+0xa9>
			cb5: R_X86_64_PLT32	rt_int_mul-0x4
     cb9:	mov    rsi,rax
     cbc:	mov    QWORD PTR [rsp+0x18],rsi
     cc1:	mov    rax,rsi
     cc4:	and    rax,r12
     cc7:	test   rax,0x1
     ccd:	je     ce9 <botlish_fn_8+0xd9>
     cd3:	lea    rcx,[r12-0x1]
     cd8:	mov    rbx,rsi
     cdb:	add    rbx,rcx
     cde:	seto   al
     ce1:	test   al,al
     ce3:	je     cf7 <botlish_fn_8+0xe7>
     ce9:	mov    rdx,r12
     cec:	mov    rdi,r13
     cef:	call   cf4 <botlish_fn_8+0xe4>
			cf0: R_X86_64_PLT32	rt_int_add-0x4
     cf4:	mov    rbx,rax
     cf7:	mov    QWORD PTR [rsp+0x18],rbx
     cfc:	mov    rsi,rbx
     cff:	mov    rdi,r13
     d02:	call   d07 <botlish_fn_8+0xf7>
			d03: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     d07:	mov    rcx,rax
     d0a:	mov    QWORD PTR [rsp+0x38],rax
     d0f:	test   rax,rcx
     d12:	je     d94 <botlish_fn_8+0x184>
     d18:	mov    rax,QWORD PTR [rsp+0x38]
     d1d:	mov    QWORD PTR [rsp+0x20],rax
     d22:	mov    r8d,0x1
     d28:	mov    QWORD PTR [rsp+0x28],0x1
     d31:	mov    QWORD PTR [rsp+0x30],0x1
     d3a:	mov    rsi,r15
     d3d:	mov    rcx,QWORD PTR [rsp+0x38]
     d42:	mov    rdi,r13
     d45:	mov    rdx,r8
     d48:	call   d4d <botlish_fn_8+0x13d>
			d49: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_copy_chunks<List[never], int, mutarray, int>
     d4d:	test   rax,rax
     d50:	mov    rdx,rax
     d53:	je     d94 <botlish_fn_8+0x184>
     d59:	mov    r8d,0x1
     d5f:	mov    rcx,r14
     d62:	mov    r9,r12
     d65:	mov    rsi,QWORD PTR [rsp+0x38]
     d6a:	mov    rdi,r13
     d6d:	call   d72 <botlish_fn_8+0x162>
			d6e: R_X86_64_PLT32	rt_mutarray_copy-0x4
     d72:	test   rax,rax
     d75:	je     d94 <botlish_fn_8+0x184>
     d7b:	mov    rdx,rbx
     d7e:	mov    rsi,QWORD PTR [rsp+0x38]
     d83:	mov    rdi,r13
     d86:	call   d8b <botlish_fn_8+0x17b>
			d87: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     d8b:	test   rax,rax
     d8e:	jne    db9 <botlish_fn_8+0x1a9>
     d94:	xor    rax,rax
     d97:	mov    rbx,QWORD PTR [rsp+0x40]
     d9c:	mov    r12,QWORD PTR [rsp+0x48]
     da1:	mov    r13,QWORD PTR [rsp+0x50]
     da6:	mov    r14,QWORD PTR [rsp+0x58]
     dab:	mov    r15,QWORD PTR [rsp+0x60]
     db0:	add    rsp,0x70
     db4:	mov    rsp,rbp
     db7:	pop    rbp
     db8:	ret
     db9:	mov    rbx,QWORD PTR [rsp+0x40]
     dbe:	mov    r12,QWORD PTR [rsp+0x48]
     dc3:	mov    r13,QWORD PTR [rsp+0x50]
     dc8:	mov    r14,QWORD PTR [rsp+0x58]
     dcd:	mov    r15,QWORD PTR [rsp+0x60]
     dd2:	add    rsp,0x70
     dd6:	mov    rsp,rbp
     dd9:	pop    rbp
     dda:	ret
     ddb:	add    BYTE PTR [rax],al
     ddd:	add    BYTE PTR [rax],al
     ddf:	add    BYTE PTR [rax+0x0],al
     de5:	add    BYTE PTR [rax],al
	...

0000000000000de8 <botlish_entry_8: chunked_finish<list[List[never], mutarray, int]>>:
     de8:	push   rbp
     de9:	mov    rbp,rsp
     dec:	mov    rsi,QWORD PTR [rdx]
     def:	mov    r8,QWORD PTR [rdx+0x8]
     df3:	mov    rcx,QWORD PTR [rdx+0x10]
     df7:	mov    rdx,r8
     dfa:	call   dff <botlish_entry_8+0x17>
			dfb: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[List[never], mutarray, int]>
     dff:	mov    rsp,rbp
     e02:	pop    rbp
     e03:	ret
     e04:	add    BYTE PTR [rax],al
	...

0000000000000e08 <botlish_fn_9: chunked_finish<list[List[mutarray], mutarray, int]>>:
     e08:	push   rbp
     e09:	mov    rbp,rsp
     e0c:	sub    rsp,0x70
     e10:	mov    QWORD PTR [rsp+0x40],rbx
     e15:	mov    QWORD PTR [rsp+0x48],r12
     e1a:	mov    QWORD PTR [rsp+0x50],r13
     e1f:	mov    QWORD PTR [rsp+0x58],r14
     e24:	mov    QWORD PTR [rsp+0x60],r15
     e29:	mov    r13,rdi
     e2c:	mov    QWORD PTR [rsp+0x28],0x0
     e35:	mov    QWORD PTR [rsp+0x30],0x0
     e3e:	mov    QWORD PTR [rsp],rsi
     e42:	mov    r15,rsi
     e45:	mov    QWORD PTR [rsp+0x8],rdx
     e4a:	mov    r14,rdx
     e4d:	mov    QWORD PTR [rsp+0x10],rcx
     e52:	mov    r12,rcx
     e55:	mov    rsi,r15
     e58:	mov    rdi,r13
     e5b:	call   e60 <botlish_fn_9+0x58>
			e5c: R_X86_64_PLT32	rt_list_len-0x4
     e60:	mov    QWORD PTR [rsp+0x18],rax
     e65:	mov    QWORD PTR [rsp+0x20],0x81
     e6e:	test   rax,0x1
     e74:	mov    rsi,rax
     e77:	je     ea4 <botlish_fn_9+0x9c>
     e7d:	mov    rdx,rsi
     e80:	mov    rax,rdx
     e83:	sar    rax,1
     e86:	imul   QWORD PTR [rip+0x14b]        # fd8 <botlish_fn_9+0x1d0>
     e8d:	seto   cl
     e90:	or     rax,0x1
     e94:	test   cl,cl
     e96:	jne    ea4 <botlish_fn_9+0x9c>
     e9c:	mov    rsi,rax
     e9f:	jmp    eb4 <botlish_fn_9+0xac>
     ea4:	mov    edx,0x81
     ea9:	mov    rdi,r13
     eac:	call   eb1 <botlish_fn_9+0xa9>
			ead: R_X86_64_PLT32	rt_int_mul-0x4
     eb1:	mov    rsi,rax
     eb4:	mov    QWORD PTR [rsp+0x18],rsi
     eb9:	mov    rax,rsi
     ebc:	and    rax,r12
     ebf:	test   rax,0x1
     ec5:	je     ee1 <botlish_fn_9+0xd9>
     ecb:	lea    rcx,[r12-0x1]
     ed0:	mov    rbx,rsi
     ed3:	add    rbx,rcx
     ed6:	seto   al
     ed9:	test   al,al
     edb:	je     eef <botlish_fn_9+0xe7>
     ee1:	mov    rdx,r12
     ee4:	mov    rdi,r13
     ee7:	call   eec <botlish_fn_9+0xe4>
			ee8: R_X86_64_PLT32	rt_int_add-0x4
     eec:	mov    rbx,rax
     eef:	mov    QWORD PTR [rsp+0x18],rbx
     ef4:	mov    rsi,rbx
     ef7:	mov    rdi,r13
     efa:	call   eff <botlish_fn_9+0xf7>
			efb: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     eff:	mov    rcx,rax
     f02:	mov    QWORD PTR [rsp+0x38],rax
     f07:	test   rax,rcx
     f0a:	je     f8c <botlish_fn_9+0x184>
     f10:	mov    rax,QWORD PTR [rsp+0x38]
     f15:	mov    QWORD PTR [rsp+0x20],rax
     f1a:	mov    r8d,0x1
     f20:	mov    QWORD PTR [rsp+0x28],0x1
     f29:	mov    QWORD PTR [rsp+0x30],0x1
     f32:	mov    rsi,r15
     f35:	mov    rcx,QWORD PTR [rsp+0x38]
     f3a:	mov    rdi,r13
     f3d:	mov    rdx,r8
     f40:	call   f45 <botlish_fn_9+0x13d>
			f41: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<List[mutarray], int, mutarray, int>
     f45:	test   rax,rax
     f48:	mov    rdx,rax
     f4b:	je     f8c <botlish_fn_9+0x184>
     f51:	mov    r8d,0x1
     f57:	mov    rcx,r14
     f5a:	mov    r9,r12
     f5d:	mov    rsi,QWORD PTR [rsp+0x38]
     f62:	mov    rdi,r13
     f65:	call   f6a <botlish_fn_9+0x162>
			f66: R_X86_64_PLT32	rt_mutarray_copy-0x4
     f6a:	test   rax,rax
     f6d:	je     f8c <botlish_fn_9+0x184>
     f73:	mov    rdx,rbx
     f76:	mov    rsi,QWORD PTR [rsp+0x38]
     f7b:	mov    rdi,r13
     f7e:	call   f83 <botlish_fn_9+0x17b>
			f7f: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     f83:	test   rax,rax
     f86:	jne    fb1 <botlish_fn_9+0x1a9>
     f8c:	xor    rax,rax
     f8f:	mov    rbx,QWORD PTR [rsp+0x40]
     f94:	mov    r12,QWORD PTR [rsp+0x48]
     f99:	mov    r13,QWORD PTR [rsp+0x50]
     f9e:	mov    r14,QWORD PTR [rsp+0x58]
     fa3:	mov    r15,QWORD PTR [rsp+0x60]
     fa8:	add    rsp,0x70
     fac:	mov    rsp,rbp
     faf:	pop    rbp
     fb0:	ret
     fb1:	mov    rbx,QWORD PTR [rsp+0x40]
     fb6:	mov    r12,QWORD PTR [rsp+0x48]
     fbb:	mov    r13,QWORD PTR [rsp+0x50]
     fc0:	mov    r14,QWORD PTR [rsp+0x58]
     fc5:	mov    r15,QWORD PTR [rsp+0x60]
     fca:	add    rsp,0x70
     fce:	mov    rsp,rbp
     fd1:	pop    rbp
     fd2:	ret
     fd3:	add    BYTE PTR [rax],al
     fd5:	add    BYTE PTR [rax],al
     fd7:	add    BYTE PTR [rax+0x0],al
     fdd:	add    BYTE PTR [rax],al
	...

0000000000000fe0 <botlish_entry_9: chunked_finish<list[List[mutarray], mutarray, int]>>:
     fe0:	push   rbp
     fe1:	mov    rbp,rsp
     fe4:	mov    rsi,QWORD PTR [rdx]
     fe7:	mov    r8,QWORD PTR [rdx+0x8]
     feb:	mov    rcx,QWORD PTR [rdx+0x10]
     fef:	mov    rdx,r8
     ff2:	call   ff7 <botlish_entry_9+0x17>
			ff3: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
     ff7:	mov    rsp,rbp
     ffa:	pop    rbp
     ffb:	ret
     ffc:	add    BYTE PTR [rax],al
	...

0000000000001000 <botlish_fn_10: peek<str, int>>:
    1000:	push   rbp
    1001:	mov    rbp,rsp
    1004:	sub    rsp,0x40
    1008:	mov    QWORD PTR [rsp+0x20],rbx
    100d:	mov    QWORD PTR [rsp+0x28],r12
    1012:	mov    QWORD PTR [rsp+0x30],r13
    1017:	mov    r13,rdi
    101a:	mov    QWORD PTR [rsp],rsi
    101e:	mov    r12,rsi
    1021:	mov    QWORD PTR [rsp+0x8],rdx
    1026:	mov    rbx,rdx
    1029:	mov    rsi,r12
    102c:	mov    rdi,r13
    102f:	call   1034 <botlish_fn_10+0x34>
			1030: R_X86_64_PLT32	rt_str_len-0x4
    1034:	mov    rcx,rbx
    1037:	and    rcx,rax
    103a:	mov    rdx,rax
    103d:	test   rcx,0x1
    1044:	jne    106a <botlish_fn_10+0x6a>
    104a:	mov    rsi,rbx
    104d:	mov    rdi,r13
    1050:	call   1055 <botlish_fn_10+0x55>
			1051: R_X86_64_PLT32	rt_int_cmp-0x4
    1055:	mov    ecx,0x2
    105a:	test   rax,rax
    105d:	cmovge rcx,QWORD PTR [rip+0xd3]        # 1138 <botlish_fn_10+0x138>
    1065:	jmp    107a <botlish_fn_10+0x7a>
    106a:	mov    ecx,0x2
    106f:	cmp    rbx,rdx
    1072:	cmovge rcx,QWORD PTR [rip+0xbe]        # 1138 <botlish_fn_10+0x138>
    107a:	cmp    rcx,0x6
    107e:	je     110e <botlish_fn_10+0x10e>
    1084:	mov    QWORD PTR [rsp+0x10],0x3
    108d:	test   rbx,0x1
    1094:	je     10ac <botlish_fn_10+0xac>
    109a:	mov    rcx,rbx
    109d:	add    rcx,0x2
    10a1:	seto   al
    10a4:	test   al,al
    10a6:	je     10bf <botlish_fn_10+0xbf>
    10ac:	mov    edx,0x3
    10b1:	mov    rsi,rbx
    10b4:	mov    rdi,r13
    10b7:	call   10bc <botlish_fn_10+0xbc>
			10b8: R_X86_64_PLT32	rt_int_add-0x4
    10bc:	mov    rcx,rax
    10bf:	mov    QWORD PTR [rsp+0x10],rcx
    10c4:	mov    rdx,rbx
    10c7:	mov    rsi,r12
    10ca:	mov    rdi,r13
    10cd:	call   10d2 <botlish_fn_10+0xd2>
			10ce: R_X86_64_PLT32	rt_substr-0x4
    10d2:	test   rax,rax
    10d5:	jne    10f6 <botlish_fn_10+0xf6>
    10db:	xor    rax,rax
    10de:	mov    rbx,QWORD PTR [rsp+0x20]
    10e3:	mov    r12,QWORD PTR [rsp+0x28]
    10e8:	mov    r13,QWORD PTR [rsp+0x30]
    10ed:	add    rsp,0x40
    10f1:	mov    rsp,rbp
    10f4:	pop    rbp
    10f5:	ret
    10f6:	mov    rbx,QWORD PTR [rsp+0x20]
    10fb:	mov    r12,QWORD PTR [rsp+0x28]
    1100:	mov    r13,QWORD PTR [rsp+0x30]
    1105:	add    rsp,0x40
    1109:	mov    rsp,rbp
    110c:	pop    rbp
    110d:	ret
    110e:	mov    rdi,r13
    1111:	mov    rax,QWORD PTR [rdi+0x10]
    1115:	mov    rax,QWORD PTR [rax+0x10]
    1119:	mov    rbx,QWORD PTR [rsp+0x20]
    111e:	mov    r12,QWORD PTR [rsp+0x28]
    1123:	mov    r13,QWORD PTR [rsp+0x30]
    1128:	add    rsp,0x40
    112c:	mov    rsp,rbp
    112f:	pop    rbp
    1130:	ret
    1131:	add    BYTE PTR [rax],al
    1133:	add    BYTE PTR [rax],al
    1135:	add    BYTE PTR [rax],al
    1137:	add    BYTE PTR [rsi],al
    1139:	add    BYTE PTR [rax],al
    113b:	add    BYTE PTR [rax],al
    113d:	add    BYTE PTR [rax],al
	...

0000000000001140 <botlish_entry_10: peek<str, int>>:
    1140:	push   rbp
    1141:	mov    rbp,rsp
    1144:	mov    rsi,QWORD PTR [rdx]
    1147:	mov    rdx,QWORD PTR [rdx+0x8]
    114b:	call   1150 <botlish_entry_10+0x10>
			114c: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    1150:	mov    rsp,rbp
    1153:	pop    rbp
    1154:	ret
    1155:	add    BYTE PTR [rax],al
	...

0000000000001158 <botlish_fn_11: peek<str, int>>:
    1158:	push   rbp
    1159:	mov    rbp,rsp
    115c:	sub    rsp,0x50
    1160:	mov    QWORD PTR [rsp+0x20],rbx
    1165:	mov    QWORD PTR [rsp+0x28],r12
    116a:	mov    QWORD PTR [rsp+0x30],r13
    116f:	mov    QWORD PTR [rsp+0x38],r14
    1174:	mov    QWORD PTR [rsp+0x40],r15
    1179:	mov    r12,rcx
    117c:	mov    r14,rdi
    117f:	mov    QWORD PTR [rsp],rsi
    1183:	mov    r13,rsi
    1186:	mov    QWORD PTR [rsp+0x8],rdx
    118b:	mov    rbx,rdx
    118e:	mov    rsi,r13
    1191:	mov    rdi,r14
    1194:	call   1199 <botlish_fn_11+0x41>
			1195: R_X86_64_PLT32	rt_str_len-0x4
    1199:	mov    rcx,rbx
    119c:	and    rcx,rax
    119f:	mov    rdx,rax
    11a2:	test   rcx,0x1
    11a9:	jne    11cf <botlish_fn_11+0x77>
    11af:	mov    rsi,rbx
    11b2:	mov    rdi,r14
    11b5:	call   11ba <botlish_fn_11+0x62>
			11b6: R_X86_64_PLT32	rt_int_cmp-0x4
    11ba:	mov    ecx,0x2
    11bf:	test   rax,rax
    11c2:	cmovge rcx,QWORD PTR [rip+0x11e]        # 12e8 <botlish_fn_11+0x190>
    11ca:	jmp    11df <botlish_fn_11+0x87>
    11cf:	mov    ecx,0x2
    11d4:	cmp    rbx,rdx
    11d7:	cmovge rcx,QWORD PTR [rip+0x109]        # 12e8 <botlish_fn_11+0x190>
    11df:	cmp    rcx,0x6
    11e3:	je     12a3 <botlish_fn_11+0x14b>
    11e9:	mov    QWORD PTR [rsp+0x10],0x3
    11f2:	test   rbx,0x1
    11f9:	je     121c <botlish_fn_11+0xc4>
    11ff:	mov    rax,rbx
    1202:	add    rax,0x2
    1206:	seto   cl
    1209:	test   cl,cl
    120b:	jne    121c <botlish_fn_11+0xc4>
    1211:	mov    rdi,r14
    1214:	mov    r15,rax
    1217:	jmp    1232 <botlish_fn_11+0xda>
    121c:	mov    edx,0x3
    1221:	mov    rsi,rbx
    1224:	mov    rdi,r14
    1227:	call   122c <botlish_fn_11+0xd4>
			1228: R_X86_64_PLT32	rt_int_add-0x4
    122c:	mov    r15,rax
    122f:	mov    rdi,r14
    1232:	mov    rdi,r14
    1235:	mov    rcx,r15
    1238:	mov    rdx,rbx
    123b:	mov    rsi,r13
    123e:	call   1243 <botlish_fn_11+0xeb>
			123f: R_X86_64_PLT32	rt_str_region_check-0x4
    1243:	test   rax,rax
    1246:	jne    1271 <botlish_fn_11+0x119>
    124c:	xor    rax,rax
    124f:	mov    rbx,QWORD PTR [rsp+0x20]
    1254:	mov    r12,QWORD PTR [rsp+0x28]
    1259:	mov    r13,QWORD PTR [rsp+0x30]
    125e:	mov    r14,QWORD PTR [rsp+0x38]
    1263:	mov    r15,QWORD PTR [rsp+0x40]
    1268:	add    rsp,0x50
    126c:	mov    rsp,rbp
    126f:	pop    rbp
    1270:	ret
    1271:	mov    rcx,r12
    1274:	mov    QWORD PTR [rcx],rbx
    1277:	mov    rax,r15
    127a:	mov    QWORD PTR [rcx+0x8],rax
    127e:	mov    rax,r13
    1281:	mov    rbx,QWORD PTR [rsp+0x20]
    1286:	mov    r12,QWORD PTR [rsp+0x28]
    128b:	mov    r13,QWORD PTR [rsp+0x30]
    1290:	mov    r14,QWORD PTR [rsp+0x38]
    1295:	mov    r15,QWORD PTR [rsp+0x40]
    129a:	add    rsp,0x50
    129e:	mov    rsp,rbp
    12a1:	pop    rbp
    12a2:	ret
    12a3:	mov    rcx,r12
    12a6:	mov    rdi,r14
    12a9:	mov    rax,QWORD PTR [rdi+0x10]
    12ad:	mov    rax,QWORD PTR [rax+0x10]
    12b1:	mov    QWORD PTR [rcx],0x1
    12b8:	mov    QWORD PTR [rcx+0x8],0x1
    12c0:	mov    rbx,QWORD PTR [rsp+0x20]
    12c5:	mov    r12,QWORD PTR [rsp+0x28]
    12ca:	mov    r13,QWORD PTR [rsp+0x30]
    12cf:	mov    r14,QWORD PTR [rsp+0x38]
    12d4:	mov    r15,QWORD PTR [rsp+0x40]
    12d9:	add    rsp,0x50
    12dd:	mov    rsp,rbp
    12e0:	pop    rbp
    12e1:	ret
    12e2:	add    BYTE PTR [rax],al
    12e4:	add    BYTE PTR [rax],al
    12e6:	add    BYTE PTR [rax],al
    12e8:	(bad)
    12e9:	add    BYTE PTR [rax],al
    12eb:	add    BYTE PTR [rax],al
    12ed:	add    BYTE PTR [rax],al
	...

00000000000012f0 <botlish_entry_11: peek<str, int>>:
    12f0:	push   rbp
    12f1:	mov    rbp,rsp
    12f4:	ud2

00000000000012f6 <botlish_fn_12: scan_unquoted<str, int, int>>:
    12f6:	push   rbp
    12f7:	mov    rbp,rsp
    12fa:	sub    rsp,0x80
    1301:	mov    QWORD PTR [rsp+0x50],rbx
    1306:	mov    QWORD PTR [rsp+0x58],r12
    130b:	mov    QWORD PTR [rsp+0x60],r13
    1310:	mov    QWORD PTR [rsp+0x68],r14
    1315:	mov    QWORD PTR [rsp+0x70],r15
    131a:	mov    QWORD PTR [rsp+0x30],rdi
    131f:	mov    QWORD PTR [rsp+0x18],0x0
    1328:	mov    QWORD PTR [rsp],rsi
    132c:	mov    r15,rsi
    132f:	mov    QWORD PTR [rsp+0x8],rdx
    1334:	mov    r14,rdx
    1337:	mov    QWORD PTR [rsp+0x10],rcx
    133c:	lea    r13,[rsp+0x20]
    1341:	mov    QWORD PTR [rsp+0x38],rcx
    1346:	mov    rcx,r13
    1349:	mov    rdx,QWORD PTR [rsp+0x38]
    134e:	mov    rsi,r15
    1351:	mov    rdi,QWORD PTR [rsp+0x30]
    1356:	call   135b <botlish_fn_12+0x65>
			1357: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    135b:	mov    rsi,rax
    135e:	mov    QWORD PTR [rsp+0x40],rax
    1363:	test   rax,rsi
    1366:	je     14c0 <botlish_fn_12+0x1ca>
    136c:	mov    rbx,QWORD PTR [rsp+0x20]
    1371:	mov    r12,QWORD PTR [rsp+0x28]
    1376:	mov    rdi,QWORD PTR [rsp+0x30]
    137b:	mov    rcx,QWORD PTR [rdi+0x10]
    137f:	mov    r8,QWORD PTR [rcx+0x10]
    1383:	mov    rcx,r12
    1386:	mov    rdx,rbx
    1389:	mov    rsi,QWORD PTR [rsp+0x40]
    138e:	call   1393 <botlish_fn_12+0x9d>
			138f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1393:	cmp    rax,0x6
    1397:	je     13d8 <botlish_fn_12+0xe2>
    139d:	mov    rdi,QWORD PTR [rsp+0x30]
    13a2:	mov    rax,QWORD PTR [rdi+0x10]
    13a6:	mov    r8,QWORD PTR [rax+0x18]
    13aa:	mov    rcx,r12
    13ad:	mov    rdx,rbx
    13b0:	mov    rsi,QWORD PTR [rsp+0x40]
    13b5:	call   13ba <botlish_fn_12+0xc4>
			13b6: R_X86_64_PLT32	rt_str_region_eq-0x4
    13ba:	cmp    rax,0x6
    13be:	je     13ce <botlish_fn_12+0xd8>
    13c4:	mov    eax,0x2
    13c9:	jmp    13dd <botlish_fn_12+0xe7>
    13ce:	mov    eax,0x6
    13d3:	jmp    13dd <botlish_fn_12+0xe7>
    13d8:	mov    eax,0x6
    13dd:	cmp    rax,0x6
    13e1:	je     1422 <botlish_fn_12+0x12c>
    13e7:	mov    rdi,QWORD PTR [rsp+0x30]
    13ec:	mov    rax,QWORD PTR [rdi+0x10]
    13f0:	mov    r8,QWORD PTR [rax+0x20]
    13f4:	mov    rcx,r12
    13f7:	mov    rdx,rbx
    13fa:	mov    rsi,QWORD PTR [rsp+0x40]
    13ff:	call   1404 <botlish_fn_12+0x10e>
			1400: R_X86_64_PLT32	rt_str_region_eq-0x4
    1404:	cmp    rax,0x6
    1408:	je     1418 <botlish_fn_12+0x122>
    140e:	mov    eax,0x2
    1413:	jmp    1427 <botlish_fn_12+0x131>
    1418:	mov    eax,0x6
    141d:	jmp    1427 <botlish_fn_12+0x131>
    1422:	mov    eax,0x6
    1427:	cmp    rax,0x6
    142b:	je     14a2 <botlish_fn_12+0x1ac>
    1431:	mov    QWORD PTR [rsp+0x18],0x3
    143a:	mov    rsi,QWORD PTR [rsp+0x38]
    143f:	test   rsi,0x1
    1446:	je     146d <botlish_fn_12+0x177>
    144c:	mov    rsi,QWORD PTR [rsp+0x38]
    1451:	mov    rax,rsi
    1454:	add    rax,0x2
    1458:	seto   sil
    145c:	test   sil,sil
    145f:	jne    146d <botlish_fn_12+0x177>
    1465:	mov    rsi,r15
    1468:	jmp    1484 <botlish_fn_12+0x18e>
    146d:	mov    edx,0x3
    1472:	mov    rsi,QWORD PTR [rsp+0x38]
    1477:	mov    rdi,QWORD PTR [rsp+0x30]
    147c:	call   1481 <botlish_fn_12+0x18b>
			147d: R_X86_64_PLT32	rt_int_add-0x4
    1481:	mov    rsi,r15
    1484:	mov    QWORD PTR [rsp],rsi
    1488:	mov    rdx,r14
    148b:	mov    QWORD PTR [rsp+0x8],rdx
    1490:	mov    QWORD PTR [rsp+0x10],rax
    1495:	mov    r15,rsi
    1498:	mov    QWORD PTR [rsp+0x38],rax
    149d:	jmp    1346 <botlish_fn_12+0x50>
    14a2:	mov    rdx,r14
    14a5:	mov    rsi,r15
    14a8:	mov    rdi,QWORD PTR [rsp+0x30]
    14ad:	mov    rcx,QWORD PTR [rsp+0x38]
    14b2:	call   14b7 <botlish_fn_12+0x1c1>
			14b3: R_X86_64_PLT32	rt_substr-0x4
    14b7:	test   rax,rax
    14ba:	jne    14eb <botlish_fn_12+0x1f5>
    14c0:	xor    rdx,rdx
    14c3:	mov    rax,rdx
    14c6:	mov    rbx,QWORD PTR [rsp+0x50]
    14cb:	mov    r12,QWORD PTR [rsp+0x58]
    14d0:	mov    r13,QWORD PTR [rsp+0x60]
    14d5:	mov    r14,QWORD PTR [rsp+0x68]
    14da:	mov    r15,QWORD PTR [rsp+0x70]
    14df:	add    rsp,0x80
    14e6:	mov    rsp,rbp
    14e9:	pop    rbp
    14ea:	ret
    14eb:	mov    rdx,QWORD PTR [rsp+0x38]
    14f0:	mov    rbx,QWORD PTR [rsp+0x50]
    14f5:	mov    r12,QWORD PTR [rsp+0x58]
    14fa:	mov    r13,QWORD PTR [rsp+0x60]
    14ff:	mov    r14,QWORD PTR [rsp+0x68]
    1504:	mov    r15,QWORD PTR [rsp+0x70]
    1509:	add    rsp,0x80
    1510:	mov    rsp,rbp
    1513:	pop    rbp
    1514:	ret

0000000000001515 <botlish_entry_12: scan_unquoted<str, int, int>>:
    1515:	push   rbp
    1516:	mov    rbp,rsp
    1519:	ud2

000000000000151b <botlish_fn_13: scan_quoted<str, int, str>>:
    151b:	push   rbp
    151c:	mov    rbp,rsp
    151f:	sub    rsp,0xd0
    1526:	mov    QWORD PTR [rsp+0xa0],rbx
    152e:	mov    QWORD PTR [rsp+0xa8],r12
    1536:	mov    QWORD PTR [rsp+0xb0],r13
    153e:	mov    QWORD PTR [rsp+0xb8],r14
    1546:	mov    QWORD PTR [rsp+0xc0],r15
    154e:	mov    QWORD PTR [rsp+0x88],rdi
    1556:	mov    QWORD PTR [rsp+0x18],0x0
    155f:	mov    QWORD PTR [rsp+0x20],0x0
    1568:	mov    QWORD PTR [rsp],rsi
    156c:	mov    QWORD PTR [rsp+0x8],rdx
    1571:	mov    QWORD PTR [rsp+0x10],rcx
    1576:	mov    r13,rcx
    1579:	lea    r14,[rsp+0x68]
    157e:	lea    rbx,[rsp+0x28]
    1583:	mov    r12,rsi
    1586:	mov    QWORD PTR [rsp+0x90],rdx
    158e:	mov    rdx,QWORD PTR [rsp+0x90]
    1596:	mov    rsi,r12
    1599:	mov    rdi,QWORD PTR [rsp+0x88]
    15a1:	call   15a6 <botlish_fn_13+0x8b>
			15a2: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    15a6:	test   rax,rax
    15a9:	je     18f2 <botlish_fn_13+0x3d7>
    15af:	mov    QWORD PTR [rsp+0x18],rax
    15b4:	mov    rsi,QWORD PTR [rax+0x8]
    15b8:	mov    rcx,rax
    15bb:	mov    rax,0xffffffffffffffff
    15c2:	test   rsi,rsi
    15c5:	jne    15d3 <botlish_fn_13+0xb8>
    15cb:	mov    r15,rcx
    15ce:	jmp    15fe <botlish_fn_13+0xe3>
    15d3:	mov    r15,rcx
    15d6:	movzx  rdi,BYTE PTR [r15+0x18]
    15db:	test   rdi,rdi
    15de:	jne    15f9 <botlish_fn_13+0xde>
    15e4:	mov    rsi,r15
    15e7:	mov    rdi,QWORD PTR [rsp+0x88]
    15ef:	call   15f4 <botlish_fn_13+0xd9>
			15f0: R_X86_64_PLT32	rt_str_to_short-0x4
    15f4:	jmp    15fe <botlish_fn_13+0xe3>
    15f9:	movzx  rax,BYTE PTR [r15+0x19]
    15fe:	cmp    rax,0x22
    1602:	je     16c2 <botlish_fn_13+0x1a7>
    1608:	mov    QWORD PTR [rsp+0x20],0x3
    1611:	mov    rsi,QWORD PTR [rsp+0x90]
    1619:	test   rsi,0x1
    1620:	je     1640 <botlish_fn_13+0x125>
    1626:	mov    rax,rsi
    1629:	add    rax,0x2
    162d:	seto   cl
    1630:	test   cl,cl
    1632:	jne    1640 <botlish_fn_13+0x125>
    1638:	mov    rsi,rax
    163b:	jmp    1655 <botlish_fn_13+0x13a>
    1640:	mov    edx,0x3
    1645:	mov    rdi,QWORD PTR [rsp+0x88]
    164d:	call   1652 <botlish_fn_13+0x137>
			164e: R_X86_64_PLT32	rt_int_add-0x4
    1652:	mov    rsi,rax
    1655:	mov    QWORD PTR [rsp+0x8],rsi
    165a:	mov    QWORD PTR [rsp+0x90],rsi
    1662:	mov    QWORD PTR [rsp+0x68],0x0
    166b:	mov    QWORD PTR [rsp+0x70],r13
    1670:	mov    QWORD PTR [rsp+0x78],0x0
    1679:	mov    QWORD PTR [rsp+0x80],r15
    1681:	mov    esi,0x2
    1686:	mov    edx,0x4
    168b:	mov    rcx,r14
    168e:	mov    rdi,QWORD PTR [rsp+0x88]
    1696:	call   169b <botlish_fn_13+0x180>
			1697: R_X86_64_PLT32	rt_construct-0x4
    169b:	test   rax,rax
    169e:	je     18f2 <botlish_fn_13+0x3d7>
    16a4:	mov    QWORD PTR [rsp],r12
    16a8:	mov    rsi,QWORD PTR [rsp+0x90]
    16b0:	mov    QWORD PTR [rsp+0x8],rsi
    16b5:	mov    QWORD PTR [rsp+0x10],rax
    16ba:	mov    r13,rax
    16bd:	jmp    158e <botlish_fn_13+0x73>
    16c2:	mov    QWORD PTR [rsp+0x18],0x3
    16cb:	mov    rsi,QWORD PTR [rsp+0x90]
    16d3:	test   rsi,0x1
    16da:	je     16fa <botlish_fn_13+0x1df>
    16e0:	mov    rsi,QWORD PTR [rsp+0x90]
    16e8:	mov    rdx,rsi
    16eb:	add    rdx,0x2
    16ef:	seto   al
    16f2:	test   al,al
    16f4:	je     1717 <botlish_fn_13+0x1fc>
    16fa:	mov    edx,0x3
    16ff:	mov    rsi,QWORD PTR [rsp+0x90]
    1707:	mov    rdi,QWORD PTR [rsp+0x88]
    170f:	call   1714 <botlish_fn_13+0x1f9>
			1710: R_X86_64_PLT32	rt_int_add-0x4
    1714:	mov    rdx,rax
    1717:	mov    QWORD PTR [rsp+0x18],rdx
    171c:	mov    rcx,rbx
    171f:	mov    rsi,r12
    1722:	mov    rdi,QWORD PTR [rsp+0x88]
    172a:	call   172f <botlish_fn_13+0x214>
			172b: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    172f:	test   rax,rax
    1732:	mov    rsi,rax
    1735:	je     18f2 <botlish_fn_13+0x3d7>
    173b:	mov    rdx,QWORD PTR [rsp+0x28]
    1740:	mov    rcx,QWORD PTR [rsp+0x30]
    1745:	mov    rdi,QWORD PTR [rsp+0x88]
    174d:	mov    rax,QWORD PTR [rdi+0x10]
    1751:	mov    r8,QWORD PTR [rax+0x28]
    1755:	call   175a <botlish_fn_13+0x23f>
			1756: R_X86_64_PLT32	rt_str_region_eq-0x4
    175a:	cmp    rax,0x6
    175e:	je     1830 <botlish_fn_13+0x315>
    1764:	xor    rsi,rsi
    1767:	lea    rcx,[rsp+0x58]
    176c:	mov    QWORD PTR [rsp+0x58],0x0
    1775:	mov    QWORD PTR [rsp+0x60],r13
    177a:	mov    edx,0x2
    177f:	mov    rdi,QWORD PTR [rsp+0x88]
    1787:	call   178c <botlish_fn_13+0x271>
			1788: R_X86_64_PLT32	rt_construct-0x4
    178c:	test   rax,rax
    178f:	je     18f2 <botlish_fn_13+0x3d7>
    1795:	mov    QWORD PTR [rsp],rax
    1799:	mov    rbx,rax
    179c:	mov    QWORD PTR [rsp+0x10],0x3
    17a5:	mov    rsi,QWORD PTR [rsp+0x90]
    17ad:	test   rsi,0x1
    17b4:	je     17dc <botlish_fn_13+0x2c1>
    17ba:	mov    rsi,QWORD PTR [rsp+0x90]
    17c2:	mov    rdx,rsi
    17c5:	add    rdx,0x2
    17c9:	seto   al
    17cc:	test   al,al
    17ce:	jne    17dc <botlish_fn_13+0x2c1>
    17d4:	mov    rax,rbx
    17d7:	jmp    17fc <botlish_fn_13+0x2e1>
    17dc:	mov    edx,0x3
    17e1:	mov    rsi,QWORD PTR [rsp+0x90]
    17e9:	mov    rdi,QWORD PTR [rsp+0x88]
    17f1:	call   17f6 <botlish_fn_13+0x2db>
			17f2: R_X86_64_PLT32	rt_int_add-0x4
    17f6:	mov    rdx,rax
    17f9:	mov    rax,rbx
    17fc:	mov    rbx,QWORD PTR [rsp+0xa0]
    1804:	mov    r12,QWORD PTR [rsp+0xa8]
    180c:	mov    r13,QWORD PTR [rsp+0xb0]
    1814:	mov    r14,QWORD PTR [rsp+0xb8]
    181c:	mov    r15,QWORD PTR [rsp+0xc0]
    1824:	add    rsp,0xd0
    182b:	mov    rsp,rbp
    182e:	pop    rbp
    182f:	ret
    1830:	mov    QWORD PTR [rsp+0x18],0x5
    1839:	mov    rsi,QWORD PTR [rsp+0x90]
    1841:	test   rsi,0x1
    1848:	je     187a <botlish_fn_13+0x35f>
    184e:	mov    rsi,QWORD PTR [rsp+0x90]
    1856:	mov    rdi,rsi
    1859:	add    rdi,0x4
    185d:	seto   r9b
    1861:	test   r9b,r9b
    1864:	jne    187a <botlish_fn_13+0x35f>
    186a:	mov    rsi,rdi
    186d:	mov    QWORD PTR [rsp+0x90],rdi
    1875:	jmp    189f <botlish_fn_13+0x384>
    187a:	mov    edx,0x5
    187f:	mov    rsi,QWORD PTR [rsp+0x90]
    1887:	mov    rdi,QWORD PTR [rsp+0x88]
    188f:	call   1894 <botlish_fn_13+0x379>
			1890: R_X86_64_PLT32	rt_int_add-0x4
    1894:	mov    rsi,rax
    1897:	mov    QWORD PTR [rsp+0x90],rax
    189f:	mov    QWORD PTR [rsp+0x8],rsi
    18a4:	mov    rdi,QWORD PTR [rsp+0x88]
    18ac:	mov    rax,QWORD PTR [rdi+0x10]
    18b0:	mov    rax,QWORD PTR [rax+0x28]
    18b4:	mov    QWORD PTR [rsp+0x18],rax
    18b9:	lea    rcx,[rsp+0x38]
    18be:	mov    QWORD PTR [rsp+0x38],0x0
    18c7:	mov    QWORD PTR [rsp+0x40],r13
    18cc:	mov    QWORD PTR [rsp+0x48],0x0
    18d5:	mov    QWORD PTR [rsp+0x50],rax
    18da:	mov    esi,0x2
    18df:	mov    edx,0x4
    18e4:	call   18e9 <botlish_fn_13+0x3ce>
			18e5: R_X86_64_PLT32	rt_construct-0x4
    18e9:	test   rax,rax
    18ec:	jne    192c <botlish_fn_13+0x411>
    18f2:	xor    rdx,rdx
    18f5:	mov    rax,rdx
    18f8:	mov    rbx,QWORD PTR [rsp+0xa0]
    1900:	mov    r12,QWORD PTR [rsp+0xa8]
    1908:	mov    r13,QWORD PTR [rsp+0xb0]
    1910:	mov    r14,QWORD PTR [rsp+0xb8]
    1918:	mov    r15,QWORD PTR [rsp+0xc0]
    1920:	add    rsp,0xd0
    1927:	mov    rsp,rbp
    192a:	pop    rbp
    192b:	ret
    192c:	mov    QWORD PTR [rsp],r12
    1930:	mov    rsi,QWORD PTR [rsp+0x90]
    1938:	mov    QWORD PTR [rsp+0x8],rsi
    193d:	mov    QWORD PTR [rsp+0x10],rax
    1942:	mov    r13,rax
    1945:	jmp    158e <botlish_fn_13+0x73>

000000000000194a <botlish_entry_13: scan_quoted<str, int, str>>:
    194a:	push   rbp
    194b:	mov    rbp,rsp
    194e:	ud2

0000000000001950 <botlish_fn_14: scan_field<str, int>>:
    1950:	push   rbp
    1951:	mov    rbp,rsp
    1954:	sub    rsp,0x50
    1958:	mov    QWORD PTR [rsp+0x30],rbx
    195d:	mov    QWORD PTR [rsp+0x38],r12
    1962:	mov    QWORD PTR [rsp+0x40],r13
    1967:	mov    r12,rdi
    196a:	mov    r13,rdx
    196d:	mov    QWORD PTR [rsp+0x10],0x0
    1976:	mov    QWORD PTR [rsp],rsi
    197a:	mov    rbx,rsi
    197d:	mov    QWORD PTR [rsp+0x8],rdx
    1982:	lea    rcx,[rsp+0x18]
    1987:	mov    rdx,r13
    198a:	mov    rsi,rbx
    198d:	mov    rdi,r12
    1990:	call   1995 <botlish_fn_14+0x45>
			1991: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1995:	test   rax,rax
    1998:	mov    rsi,rax
    199b:	je     1a66 <botlish_fn_14+0x116>
    19a1:	mov    rdx,QWORD PTR [rsp+0x18]
    19a6:	mov    rcx,QWORD PTR [rsp+0x20]
    19ab:	mov    rdi,r12
    19ae:	mov    rax,QWORD PTR [rdi+0x10]
    19b2:	mov    r8,QWORD PTR [rax+0x28]
    19b6:	call   19bb <botlish_fn_14+0x6b>
			19b7: R_X86_64_PLT32	rt_str_region_eq-0x4
    19bb:	cmp    rax,0x6
    19bf:	je     19f7 <botlish_fn_14+0xa7>
    19c5:	mov    rcx,r13
    19c8:	mov    rsi,rbx
    19cb:	mov    rdi,r12
    19ce:	mov    rdx,rcx
    19d1:	call   19d6 <botlish_fn_14+0x86>
			19d2: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_unquoted<str, int, int>
    19d6:	test   rax,rax
    19d9:	je     1a66 <botlish_fn_14+0x116>
    19df:	mov    rbx,QWORD PTR [rsp+0x30]
    19e4:	mov    r12,QWORD PTR [rsp+0x38]
    19e9:	mov    r13,QWORD PTR [rsp+0x40]
    19ee:	add    rsp,0x50
    19f2:	mov    rsp,rbp
    19f5:	pop    rbp
    19f6:	ret
    19f7:	mov    rcx,r13
    19fa:	mov    QWORD PTR [rsp+0x10],0x3
    1a03:	test   rcx,0x1
    1a0a:	jne    1a18 <botlish_fn_14+0xc8>
    1a10:	mov    r13,rcx
    1a13:	jmp    1a2d <botlish_fn_14+0xdd>
    1a18:	mov    rdx,rcx
    1a1b:	add    rdx,0x2
    1a1f:	mov    r13,rcx
    1a22:	seto   al
    1a25:	test   al,al
    1a27:	je     1a40 <botlish_fn_14+0xf0>
    1a2d:	mov    edx,0x3
    1a32:	mov    rsi,r13
    1a35:	mov    rdi,r12
    1a38:	call   1a3d <botlish_fn_14+0xed>
			1a39: R_X86_64_PLT32	rt_int_add-0x4
    1a3d:	mov    rdx,rax
    1a40:	mov    QWORD PTR [rsp+0x8],rdx
    1a45:	mov    rdi,r12
    1a48:	mov    rax,QWORD PTR [rdi+0x10]
    1a4c:	mov    rcx,QWORD PTR [rax+0x10]
    1a50:	mov    QWORD PTR [rsp+0x10],rcx
    1a55:	mov    rsi,rbx
    1a58:	call   1a5d <botlish_fn_14+0x10d>
			1a59: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_quoted<str, int, str>
    1a5d:	test   rax,rax
    1a60:	jne    1a84 <botlish_fn_14+0x134>
    1a66:	xor    rdx,rdx
    1a69:	mov    rax,rdx
    1a6c:	mov    rbx,QWORD PTR [rsp+0x30]
    1a71:	mov    r12,QWORD PTR [rsp+0x38]
    1a76:	mov    r13,QWORD PTR [rsp+0x40]
    1a7b:	add    rsp,0x50
    1a7f:	mov    rsp,rbp
    1a82:	pop    rbp
    1a83:	ret
    1a84:	mov    rbx,QWORD PTR [rsp+0x30]
    1a89:	mov    r12,QWORD PTR [rsp+0x38]
    1a8e:	mov    r13,QWORD PTR [rsp+0x40]
    1a93:	add    rsp,0x50
    1a97:	mov    rsp,rbp
    1a9a:	pop    rbp
    1a9b:	ret

0000000000001a9c <botlish_entry_14: scan_field<str, int>>:
    1a9c:	push   rbp
    1a9d:	mov    rbp,rsp
    1aa0:	ud2

0000000000001aa2 <botlish_fn_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1aa2:	push   rbp
    1aa3:	mov    rbp,rsp
    1aa6:	sub    rsp,0xa0
    1aad:	mov    QWORD PTR [rsp+0x70],rbx
    1ab2:	mov    QWORD PTR [rsp+0x78],r12
    1ab7:	mov    QWORD PTR [rsp+0x80],r13
    1abf:	mov    QWORD PTR [rsp+0x88],r14
    1ac7:	mov    QWORD PTR [rsp+0x90],r15
    1acf:	mov    r13,rdi
    1ad2:	mov    QWORD PTR [rsp+0x28],0x0
    1adb:	mov    QWORD PTR [rsp],rsi
    1adf:	mov    r15,rsi
    1ae2:	mov    QWORD PTR [rsp+0x8],rdx
    1ae7:	mov    QWORD PTR [rsp+0x10],rcx
    1aec:	mov    QWORD PTR [rsp+0x50],rcx
    1af1:	mov    QWORD PTR [rsp+0x18],r8
    1af6:	mov    r12,r8
    1af9:	mov    QWORD PTR [rsp+0x20],r9
    1afe:	mov    rbx,r9
    1b01:	mov    rsi,r15
    1b04:	mov    rdi,r13
    1b07:	call   1b0c <botlish_fn_15+0x6a>
			1b08: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1b0c:	test   rax,rax
    1b0f:	je     1d43 <botlish_fn_15+0x2a1>
    1b15:	mov    QWORD PTR [rsp+0x8],rax
    1b1a:	mov    r8,rax
    1b1d:	mov    QWORD PTR [rsp+0x28],rdx
    1b22:	mov    r14,rdx
    1b25:	lea    r9,[rsp+0x30]
    1b2a:	mov    rcx,rbx
    1b2d:	mov    rdx,r12
    1b30:	mov    rsi,QWORD PTR [rsp+0x50]
    1b35:	mov    rdi,r13
    1b38:	call   1b3d <botlish_fn_15+0x9b>
			1b39: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<list[List[never], mutarray, int], str>
    1b3d:	test   rax,rax
    1b40:	je     1d43 <botlish_fn_15+0x2a1>
    1b46:	mov    QWORD PTR [rsp+0x8],rax
    1b4b:	mov    QWORD PTR [rsp+0x68],rax
    1b50:	mov    rdx,QWORD PTR [rsp+0x30]
    1b55:	mov    QWORD PTR [rsp+0x10],rdx
    1b5a:	mov    QWORD PTR [rsp+0x60],rdx
    1b5f:	mov    rcx,QWORD PTR [rsp+0x38]
    1b64:	mov    QWORD PTR [rsp+0x18],rcx
    1b69:	mov    QWORD PTR [rsp+0x58],rcx
    1b6e:	lea    rcx,[rsp+0x40]
    1b73:	mov    rdx,r14
    1b76:	mov    rsi,r15
    1b79:	mov    rdi,r13
    1b7c:	call   1b81 <botlish_fn_15+0xdf>
			1b7d: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1b81:	test   rax,rax
    1b84:	mov    QWORD PTR [rsp+0x50],rax
    1b89:	je     1d43 <botlish_fn_15+0x2a1>
    1b8f:	mov    r12,QWORD PTR [rsp+0x40]
    1b94:	mov    rbx,QWORD PTR [rsp+0x48]
    1b99:	mov    rdi,r13
    1b9c:	mov    rcx,QWORD PTR [rdi+0x10]
    1ba0:	mov    r8,QWORD PTR [rcx+0x18]
    1ba4:	mov    rcx,rbx
    1ba7:	mov    rdx,r12
    1baa:	mov    rsi,QWORD PTR [rsp+0x50]
    1baf:	call   1bb4 <botlish_fn_15+0x112>
			1bb0: R_X86_64_PLT32	rt_str_region_eq-0x4
    1bb4:	cmp    rax,0x6
    1bb8:	je     1cd2 <botlish_fn_15+0x230>
    1bbe:	mov    rdi,r13
    1bc1:	mov    rax,QWORD PTR [rdi+0x10]
    1bc5:	mov    r8,QWORD PTR [rax+0x20]
    1bc9:	mov    rcx,rbx
    1bcc:	mov    rdx,r12
    1bcf:	mov    rsi,QWORD PTR [rsp+0x50]
    1bd4:	call   1bd9 <botlish_fn_15+0x137>
			1bd5: R_X86_64_PLT32	rt_str_region_eq-0x4
    1bd9:	cmp    rax,0x6
    1bdd:	je     1c34 <botlish_fn_15+0x192>
    1be3:	mov    rcx,QWORD PTR [rsp+0x58]
    1be8:	mov    rdx,QWORD PTR [rsp+0x60]
    1bed:	mov    rsi,QWORD PTR [rsp+0x68]
    1bf2:	mov    rdi,r13
    1bf5:	call   1bfa <botlish_fn_15+0x158>
			1bf6: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1bfa:	test   rax,rax
    1bfd:	je     1d43 <botlish_fn_15+0x2a1>
    1c03:	mov    rdx,r14
    1c06:	mov    rbx,QWORD PTR [rsp+0x70]
    1c0b:	mov    r12,QWORD PTR [rsp+0x78]
    1c10:	mov    r13,QWORD PTR [rsp+0x80]
    1c18:	mov    r14,QWORD PTR [rsp+0x88]
    1c20:	mov    r15,QWORD PTR [rsp+0x90]
    1c28:	add    rsp,0xa0
    1c2f:	mov    rsp,rbp
    1c32:	pop    rbp
    1c33:	ret
    1c34:	mov    rcx,QWORD PTR [rsp+0x58]
    1c39:	mov    rdx,QWORD PTR [rsp+0x60]
    1c3e:	mov    rsi,QWORD PTR [rsp+0x68]
    1c43:	mov    rdi,r13
    1c46:	call   1c4b <botlish_fn_15+0x1a9>
			1c47: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1c4b:	test   rax,rax
    1c4e:	je     1d43 <botlish_fn_15+0x2a1>
    1c54:	mov    QWORD PTR [rsp],rax
    1c58:	mov    rbx,rax
    1c5b:	mov    QWORD PTR [rsp+0x8],0x3
    1c64:	mov    rdx,r14
    1c67:	test   rdx,0x1
    1c6e:	je     1c8e <botlish_fn_15+0x1ec>
    1c74:	mov    rdx,r14
    1c77:	add    rdx,0x2
    1c7b:	seto   al
    1c7e:	test   al,al
    1c80:	jne    1c8e <botlish_fn_15+0x1ec>
    1c86:	mov    rax,rbx
    1c89:	jmp    1ca4 <botlish_fn_15+0x202>
    1c8e:	mov    edx,0x3
    1c93:	mov    rsi,r14
    1c96:	mov    rdi,r13
    1c99:	call   1c9e <botlish_fn_15+0x1fc>
			1c9a: R_X86_64_PLT32	rt_int_add-0x4
    1c9e:	mov    rdx,rax
    1ca1:	mov    rax,rbx
    1ca4:	mov    rbx,QWORD PTR [rsp+0x70]
    1ca9:	mov    r12,QWORD PTR [rsp+0x78]
    1cae:	mov    r13,QWORD PTR [rsp+0x80]
    1cb6:	mov    r14,QWORD PTR [rsp+0x88]
    1cbe:	mov    r15,QWORD PTR [rsp+0x90]
    1cc6:	add    rsp,0xa0
    1ccd:	mov    rsp,rbp
    1cd0:	pop    rbp
    1cd1:	ret
    1cd2:	mov    rsi,r14
    1cd5:	mov    edx,0x3
    1cda:	mov    rcx,rdx
    1cdd:	mov    QWORD PTR [rsp+0x20],0x3
    1ce6:	test   rsi,0x1
    1ced:	jne    1cfb <botlish_fn_15+0x259>
    1cf3:	mov    rdx,rcx
    1cf6:	jmp    1d10 <botlish_fn_15+0x26e>
    1cfb:	mov    rdx,rsi
    1cfe:	add    rdx,0x2
    1d02:	seto   al
    1d05:	test   al,al
    1d07:	je     1d1b <botlish_fn_15+0x279>
    1d0d:	mov    rdx,rcx
    1d10:	mov    rdi,r13
    1d13:	call   1d18 <botlish_fn_15+0x276>
			1d14: R_X86_64_PLT32	rt_int_add-0x4
    1d18:	mov    rdx,rax
    1d1b:	mov    QWORD PTR [rsp+0x20],rdx
    1d20:	mov    rcx,QWORD PTR [rsp+0x68]
    1d25:	mov    rsi,r15
    1d28:	mov    rdi,r13
    1d2b:	mov    r8,QWORD PTR [rsp+0x60]
    1d30:	mov    r9,QWORD PTR [rsp+0x58]
    1d35:	call   1d3a <botlish_fn_15+0x298>
			1d36: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[List[mutarray], mutarray, int]>
    1d3a:	test   rax,rax
    1d3d:	jne    1d77 <botlish_fn_15+0x2d5>
    1d43:	xor    rdx,rdx
    1d46:	mov    rax,rdx
    1d49:	mov    rbx,QWORD PTR [rsp+0x70]
    1d4e:	mov    r12,QWORD PTR [rsp+0x78]
    1d53:	mov    r13,QWORD PTR [rsp+0x80]
    1d5b:	mov    r14,QWORD PTR [rsp+0x88]
    1d63:	mov    r15,QWORD PTR [rsp+0x90]
    1d6b:	add    rsp,0xa0
    1d72:	mov    rsp,rbp
    1d75:	pop    rbp
    1d76:	ret
    1d77:	mov    rbx,QWORD PTR [rsp+0x70]
    1d7c:	mov    r12,QWORD PTR [rsp+0x78]
    1d81:	mov    r13,QWORD PTR [rsp+0x80]
    1d89:	mov    r14,QWORD PTR [rsp+0x88]
    1d91:	mov    r15,QWORD PTR [rsp+0x90]
    1d99:	add    rsp,0xa0
    1da0:	mov    rsp,rbp
    1da3:	pop    rbp
    1da4:	ret

0000000000001da5 <botlish_entry_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1da5:	push   rbp
    1da6:	mov    rbp,rsp
    1da9:	ud2

0000000000001dab <botlish_fn_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    1dab:	push   rbp
    1dac:	mov    rbp,rsp
    1daf:	sub    rsp,0xb0
    1db6:	mov    QWORD PTR [rsp+0x80],rbx
    1dbe:	mov    QWORD PTR [rsp+0x88],r12
    1dc6:	mov    QWORD PTR [rsp+0x90],r13
    1dce:	mov    QWORD PTR [rsp+0x98],r14
    1dd6:	mov    QWORD PTR [rsp+0xa0],r15
    1dde:	mov    QWORD PTR [rsp+0x50],rdi
    1de3:	mov    QWORD PTR [rsp+0x28],0x0
    1dec:	mov    QWORD PTR [rsp],rsi
    1df0:	mov    QWORD PTR [rsp+0x8],rdx
    1df5:	mov    QWORD PTR [rsp+0x10],rcx
    1dfa:	mov    QWORD PTR [rsp+0x18],r8
    1dff:	mov    QWORD PTR [rsp+0x20],r9
    1e04:	lea    r15,[rsp+0x30]
    1e09:	lea    rbx,[rsp+0x40]
    1e0e:	mov    r12,rsi
    1e11:	mov    r13,rcx
    1e14:	mov    QWORD PTR [rsp+0x58],r8
    1e19:	mov    QWORD PTR [rsp+0x60],r9
    1e1e:	mov    rsi,r12
    1e21:	mov    rdi,QWORD PTR [rsp+0x50]
    1e26:	call   1e2b <botlish_fn_16+0x80>
			1e27: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1e2b:	mov    QWORD PTR [rsp+0x78],rdx
    1e30:	test   rax,rax
    1e33:	je     1f8e <botlish_fn_16+0x1e3>
    1e39:	mov    QWORD PTR [rsp+0x8],rax
    1e3e:	mov    rdx,QWORD PTR [rsp+0x78]
    1e43:	mov    r8,rax
    1e46:	mov    QWORD PTR [rsp+0x28],rdx
    1e4b:	mov    rcx,QWORD PTR [rsp+0x60]
    1e50:	mov    rdx,QWORD PTR [rsp+0x58]
    1e55:	mov    rsi,r13
    1e58:	mov    rdi,QWORD PTR [rsp+0x50]
    1e5d:	mov    r9,r15
    1e60:	call   1e65 <botlish_fn_16+0xba>
			1e61: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[List[mutarray], mutarray, int], str>
    1e65:	test   rax,rax
    1e68:	je     1f8e <botlish_fn_16+0x1e3>
    1e6e:	mov    QWORD PTR [rsp+0x8],rax
    1e73:	mov    QWORD PTR [rsp+0x70],rax
    1e78:	mov    rdx,QWORD PTR [rsp+0x30]
    1e7d:	mov    QWORD PTR [rsp+0x58],rdx
    1e82:	mov    QWORD PTR [rsp+0x10],rdx
    1e87:	mov    rcx,QWORD PTR [rsp+0x38]
    1e8c:	mov    QWORD PTR [rsp+0x18],rcx
    1e91:	mov    QWORD PTR [rsp+0x60],rcx
    1e96:	mov    rcx,rbx
    1e99:	mov    rdx,QWORD PTR [rsp+0x78]
    1e9e:	mov    rsi,r12
    1ea1:	mov    rdi,QWORD PTR [rsp+0x50]
    1ea6:	call   1eab <botlish_fn_16+0x100>
			1ea7: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1eab:	test   rax,rax
    1eae:	mov    QWORD PTR [rsp+0x68],rax
    1eb3:	je     1f8e <botlish_fn_16+0x1e3>
    1eb9:	mov    r13,QWORD PTR [rsp+0x40]
    1ebe:	mov    r14,QWORD PTR [rsp+0x48]
    1ec3:	mov    rdi,QWORD PTR [rsp+0x50]
    1ec8:	mov    rcx,QWORD PTR [rdi+0x10]
    1ecc:	mov    r8,QWORD PTR [rcx+0x18]
    1ed0:	mov    rcx,r14
    1ed3:	mov    rdx,r13
    1ed6:	mov    rsi,QWORD PTR [rsp+0x68]
    1edb:	call   1ee0 <botlish_fn_16+0x135>
			1edc: R_X86_64_PLT32	rt_str_region_eq-0x4
    1ee0:	cmp    rax,0x6
    1ee4:	je     2054 <botlish_fn_16+0x2a9>
    1eea:	mov    rdi,QWORD PTR [rsp+0x50]
    1eef:	mov    rax,QWORD PTR [rdi+0x10]
    1ef3:	mov    r8,QWORD PTR [rax+0x20]
    1ef7:	mov    rcx,r14
    1efa:	mov    rdx,r13
    1efd:	mov    rsi,QWORD PTR [rsp+0x68]
    1f02:	call   1f07 <botlish_fn_16+0x15c>
			1f03: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f07:	cmp    rax,0x6
    1f0b:	je     1f6c <botlish_fn_16+0x1c1>
    1f11:	mov    rcx,QWORD PTR [rsp+0x60]
    1f16:	mov    rdx,QWORD PTR [rsp+0x58]
    1f1b:	mov    rsi,QWORD PTR [rsp+0x70]
    1f20:	mov    rdi,QWORD PTR [rsp+0x50]
    1f25:	call   1f2a <botlish_fn_16+0x17f>
			1f26: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1f2a:	test   rax,rax
    1f2d:	je     1f8e <botlish_fn_16+0x1e3>
    1f33:	mov    rdx,QWORD PTR [rsp+0x78]
    1f38:	mov    rbx,QWORD PTR [rsp+0x80]
    1f40:	mov    r12,QWORD PTR [rsp+0x88]
    1f48:	mov    r13,QWORD PTR [rsp+0x90]
    1f50:	mov    r14,QWORD PTR [rsp+0x98]
    1f58:	mov    r15,QWORD PTR [rsp+0xa0]
    1f60:	add    rsp,0xb0
    1f67:	mov    rsp,rbp
    1f6a:	pop    rbp
    1f6b:	ret
    1f6c:	mov    rcx,QWORD PTR [rsp+0x60]
    1f71:	mov    rdx,QWORD PTR [rsp+0x58]
    1f76:	mov    rsi,QWORD PTR [rsp+0x70]
    1f7b:	mov    rdi,QWORD PTR [rsp+0x50]
    1f80:	call   1f85 <botlish_fn_16+0x1da>
			1f81: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1f85:	test   rax,rax
    1f88:	jne    1fc8 <botlish_fn_16+0x21d>
    1f8e:	xor    rdx,rdx
    1f91:	mov    rax,rdx
    1f94:	mov    rbx,QWORD PTR [rsp+0x80]
    1f9c:	mov    r12,QWORD PTR [rsp+0x88]
    1fa4:	mov    r13,QWORD PTR [rsp+0x90]
    1fac:	mov    r14,QWORD PTR [rsp+0x98]
    1fb4:	mov    r15,QWORD PTR [rsp+0xa0]
    1fbc:	add    rsp,0xb0
    1fc3:	mov    rsp,rbp
    1fc6:	pop    rbp
    1fc7:	ret
    1fc8:	mov    QWORD PTR [rsp],rax
    1fcc:	mov    rbx,rax
    1fcf:	mov    QWORD PTR [rsp+0x8],0x3
    1fd8:	mov    rdx,QWORD PTR [rsp+0x78]
    1fdd:	test   rdx,0x1
    1fe4:	je     2006 <botlish_fn_16+0x25b>
    1fea:	mov    rdx,QWORD PTR [rsp+0x78]
    1fef:	add    rdx,0x2
    1ff3:	seto   al
    1ff6:	test   al,al
    1ff8:	jne    2006 <botlish_fn_16+0x25b>
    1ffe:	mov    rax,rbx
    2001:	jmp    2020 <botlish_fn_16+0x275>
    2006:	mov    edx,0x3
    200b:	mov    rsi,QWORD PTR [rsp+0x78]
    2010:	mov    rdi,QWORD PTR [rsp+0x50]
    2015:	call   201a <botlish_fn_16+0x26f>
			2016: R_X86_64_PLT32	rt_int_add-0x4
    201a:	mov    rdx,rax
    201d:	mov    rax,rbx
    2020:	mov    rbx,QWORD PTR [rsp+0x80]
    2028:	mov    r12,QWORD PTR [rsp+0x88]
    2030:	mov    r13,QWORD PTR [rsp+0x90]
    2038:	mov    r14,QWORD PTR [rsp+0x98]
    2040:	mov    r15,QWORD PTR [rsp+0xa0]
    2048:	add    rsp,0xb0
    204f:	mov    rsp,rbp
    2052:	pop    rbp
    2053:	ret
    2054:	mov    rsi,QWORD PTR [rsp+0x78]
    2059:	mov    edx,0x3
    205e:	mov    r10,rdx
    2061:	mov    QWORD PTR [rsp+0x20],0x3
    206a:	test   rsi,0x1
    2071:	jne    207f <botlish_fn_16+0x2d4>
    2077:	mov    rdx,r10
    207a:	jmp    2094 <botlish_fn_16+0x2e9>
    207f:	mov    rdx,rsi
    2082:	add    rdx,0x2
    2086:	seto   al
    2089:	test   al,al
    208b:	je     20a1 <botlish_fn_16+0x2f6>
    2091:	mov    rdx,r10
    2094:	mov    rdi,QWORD PTR [rsp+0x50]
    2099:	call   209e <botlish_fn_16+0x2f3>
			209a: R_X86_64_PLT32	rt_int_add-0x4
    209e:	mov    rdx,rax
    20a1:	mov    QWORD PTR [rsp],r12
    20a5:	mov    QWORD PTR [rsp+0x8],rdx
    20aa:	mov    rsi,QWORD PTR [rsp+0x70]
    20af:	mov    QWORD PTR [rsp+0x10],rsi
    20b4:	mov    rax,QWORD PTR [rsp+0x58]
    20b9:	mov    QWORD PTR [rsp+0x18],rax
    20be:	mov    rcx,QWORD PTR [rsp+0x60]
    20c3:	mov    QWORD PTR [rsp+0x20],rcx
    20c8:	mov    r13,rsi
    20cb:	jmp    1e1e <botlish_fn_16+0x73>

00000000000020d0 <botlish_entry_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    20d0:	push   rbp
    20d1:	mov    rbp,rsp
    20d4:	ud2

00000000000020d6 <botlish_fn_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    20d6:	push   rbp
    20d7:	mov    rbp,rsp
    20da:	sub    rsp,0xa0
    20e1:	mov    QWORD PTR [rsp+0x70],rbx
    20e6:	mov    QWORD PTR [rsp+0x78],r12
    20eb:	mov    QWORD PTR [rsp+0x80],r13
    20f3:	mov    QWORD PTR [rsp+0x88],r14
    20fb:	mov    QWORD PTR [rsp+0x90],r15
    2103:	mov    r12,rdi
    2106:	mov    QWORD PTR [rsp+0x28],0x0
    210f:	mov    QWORD PTR [rsp+0x30],0x0
    2118:	mov    QWORD PTR [rsp+0x38],0x0
    2121:	mov    QWORD PTR [rsp],rsi
    2125:	mov    rbx,rsi
    2128:	mov    QWORD PTR [rsp+0x8],rdx
    212d:	mov    QWORD PTR [rsp+0x60],rdx
    2132:	mov    QWORD PTR [rsp+0x10],rcx
    2137:	mov    r15,rcx
    213a:	mov    QWORD PTR [rsp+0x18],r8
    213f:	mov    r14,r8
    2142:	mov    QWORD PTR [rsp+0x20],r9
    2147:	mov    r13,r9
    214a:	mov    rsi,rbx
    214d:	mov    rdi,r12
    2150:	call   2155 <botlish_fn_17+0x7f>
			2151: R_X86_64_PLT32	rt_str_len-0x4
    2155:	mov    rdx,QWORD PTR [rsp+0x60]
    215a:	mov    rcx,rdx
    215d:	sar    rcx,1
    2160:	sar    rax,1
    2163:	cmp    rcx,rax
    2166:	jge    224b <botlish_fn_17+0x175>
    216c:	lea    rsi,[rsp+0x40]
    2171:	mov    rdi,r12
    2174:	call   2179 <botlish_fn_17+0xa3>
			2175: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2179:	test   rax,rax
    217c:	je     2265 <botlish_fn_17+0x18f>
    2182:	mov    QWORD PTR [rsp+0x28],rax
    2187:	mov    rcx,rax
    218a:	mov    r8,QWORD PTR [rsp+0x40]
    218f:	mov    QWORD PTR [rsp+0x30],r8
    2194:	mov    r9,QWORD PTR [rsp+0x48]
    2199:	mov    QWORD PTR [rsp+0x38],r9
    219e:	mov    rdx,QWORD PTR [rsp+0x60]
    21a3:	mov    rsi,rbx
    21a6:	mov    rdi,r12
    21a9:	call   21ae <botlish_fn_17+0xd8>
			21aa: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    21ae:	test   rax,rax
    21b1:	je     2265 <botlish_fn_17+0x18f>
    21b7:	mov    QWORD PTR [rsp+0x8],rax
    21bc:	mov    r8,rax
    21bf:	mov    QWORD PTR [rsp+0x28],rdx
    21c4:	mov    QWORD PTR [rsp+0x60],rdx
    21c9:	lea    r9,[rsp+0x50]
    21ce:	mov    rcx,r13
    21d1:	mov    rdx,r14
    21d4:	mov    rsi,r15
    21d7:	mov    rdi,r12
    21da:	call   21df <botlish_fn_17+0x109>
			21db: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[List[never], mutarray, int], list>
    21df:	test   rax,rax
    21e2:	je     2265 <botlish_fn_17+0x18f>
    21e8:	mov    QWORD PTR [rsp+0x8],rax
    21ed:	mov    rcx,rax
    21f0:	mov    r8,QWORD PTR [rsp+0x50]
    21f5:	mov    QWORD PTR [rsp+0x10],r8
    21fa:	mov    r9,QWORD PTR [rsp+0x58]
    21ff:	mov    QWORD PTR [rsp+0x18],r9
    2204:	mov    rdx,QWORD PTR [rsp+0x60]
    2209:	mov    rsi,rbx
    220c:	mov    rdi,r12
    220f:	call   2214 <botlish_fn_17+0x13e>
			2210: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    2214:	test   rax,rax
    2217:	je     2265 <botlish_fn_17+0x18f>
    221d:	mov    rbx,QWORD PTR [rsp+0x70]
    2222:	mov    r12,QWORD PTR [rsp+0x78]
    2227:	mov    r13,QWORD PTR [rsp+0x80]
    222f:	mov    r14,QWORD PTR [rsp+0x88]
    2237:	mov    r15,QWORD PTR [rsp+0x90]
    223f:	add    rsp,0xa0
    2246:	mov    rsp,rbp
    2249:	pop    rbp
    224a:	ret
    224b:	mov    rcx,r13
    224e:	mov    rdx,r14
    2251:	mov    rsi,r15
    2254:	mov    rdi,r12
    2257:	call   225c <botlish_fn_17+0x186>
			2258: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[List[never], mutarray, int]>
    225c:	test   rax,rax
    225f:	jne    2296 <botlish_fn_17+0x1c0>
    2265:	xor    rax,rax
    2268:	mov    rbx,QWORD PTR [rsp+0x70]
    226d:	mov    r12,QWORD PTR [rsp+0x78]
    2272:	mov    r13,QWORD PTR [rsp+0x80]
    227a:	mov    r14,QWORD PTR [rsp+0x88]
    2282:	mov    r15,QWORD PTR [rsp+0x90]
    228a:	add    rsp,0xa0
    2291:	mov    rsp,rbp
    2294:	pop    rbp
    2295:	ret
    2296:	mov    rbx,QWORD PTR [rsp+0x70]
    229b:	mov    r12,QWORD PTR [rsp+0x78]
    22a0:	mov    r13,QWORD PTR [rsp+0x80]
    22a8:	mov    r14,QWORD PTR [rsp+0x88]
    22b0:	mov    r15,QWORD PTR [rsp+0x90]
    22b8:	add    rsp,0xa0
    22bf:	mov    rsp,rbp
    22c2:	pop    rbp
    22c3:	ret

00000000000022c4 <botlish_entry_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    22c4:	push   rbp
    22c5:	mov    rbp,rsp
    22c8:	mov    rsi,QWORD PTR [rdx]
    22cb:	mov    r10,QWORD PTR [rdx+0x8]
    22cf:	mov    rcx,QWORD PTR [rdx+0x10]
    22d3:	mov    r8,QWORD PTR [rdx+0x18]
    22d7:	mov    r9,QWORD PTR [rdx+0x20]
    22db:	mov    rdx,r10
    22de:	call   22e3 <botlish_entry_17+0x1f>
			22df: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    22e3:	mov    rsp,rbp
    22e6:	pop    rbp
    22e7:	ret

00000000000022e8 <botlish_fn_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    22e8:	push   rbp
    22e9:	mov    rbp,rsp
    22ec:	sub    rsp,0xb0
    22f3:	mov    QWORD PTR [rsp+0x80],rbx
    22fb:	mov    QWORD PTR [rsp+0x88],r12
    2303:	mov    QWORD PTR [rsp+0x90],r13
    230b:	mov    QWORD PTR [rsp+0x98],r14
    2313:	mov    QWORD PTR [rsp+0xa0],r15
    231b:	mov    r15,rdi
    231e:	mov    QWORD PTR [rsp+0x28],0x0
    2327:	mov    QWORD PTR [rsp+0x30],0x0
    2330:	mov    QWORD PTR [rsp+0x38],0x0
    2339:	mov    QWORD PTR [rsp],rsi
    233d:	mov    QWORD PTR [rsp+0x8],rdx
    2342:	mov    r14,rdx
    2345:	mov    QWORD PTR [rsp+0x10],rcx
    234a:	mov    QWORD PTR [rsp+0x18],r8
    234f:	mov    QWORD PTR [rsp+0x20],r9
    2354:	lea    r13,[rsp+0x40]
    2359:	lea    rbx,[rsp+0x50]
    235e:	mov    r12,rsi
    2361:	mov    QWORD PTR [rsp+0x60],rcx
    2366:	mov    QWORD PTR [rsp+0x68],r8
    236b:	mov    QWORD PTR [rsp+0x70],r9
    2370:	mov    rsi,r12
    2373:	mov    rdi,r15
    2376:	call   237b <botlish_fn_18+0x93>
			2377: R_X86_64_PLT32	rt_str_len-0x4
    237b:	mov    rcx,r14
    237e:	and    rcx,rax
    2381:	mov    rdx,rax
    2384:	test   rcx,0x1
    238b:	jne    23b1 <botlish_fn_18+0xc9>
    2391:	mov    rsi,r14
    2394:	mov    rdi,r15
    2397:	call   239c <botlish_fn_18+0xb4>
			2398: R_X86_64_PLT32	rt_int_cmp-0x4
    239c:	mov    ecx,0x2
    23a1:	test   rax,rax
    23a4:	cmovge rcx,QWORD PTR [rip+0x164]        # 2510 <botlish_fn_18+0x228>
    23ac:	jmp    23c4 <botlish_fn_18+0xdc>
    23b1:	mov    ecx,0x2
    23b6:	mov    rdi,r14
    23b9:	cmp    rdi,rdx
    23bc:	cmovge rcx,QWORD PTR [rip+0x14c]        # 2510 <botlish_fn_18+0x228>
    23c4:	cmp    rcx,0x6
    23c8:	je     2481 <botlish_fn_18+0x199>
    23ce:	mov    rsi,r13
    23d1:	mov    rdi,r15
    23d4:	call   23d9 <botlish_fn_18+0xf1>
			23d5: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    23d9:	test   rax,rax
    23dc:	je     24a1 <botlish_fn_18+0x1b9>
    23e2:	mov    QWORD PTR [rsp+0x28],rax
    23e7:	mov    rcx,rax
    23ea:	mov    r8,QWORD PTR [rsp+0x40]
    23ef:	mov    QWORD PTR [rsp+0x30],r8
    23f4:	mov    r9,QWORD PTR [rsp+0x48]
    23f9:	mov    QWORD PTR [rsp+0x38],r9
    23fe:	mov    rdx,r14
    2401:	mov    rsi,r12
    2404:	mov    rdi,r15
    2407:	call   240c <botlish_fn_18+0x124>
			2408: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    240c:	test   rax,rax
    240f:	je     24a1 <botlish_fn_18+0x1b9>
    2415:	mov    QWORD PTR [rsp+0x8],rax
    241a:	mov    r8,rax
    241d:	mov    QWORD PTR [rsp+0x28],rdx
    2422:	mov    r14,rdx
    2425:	mov    rsi,QWORD PTR [rsp+0x60]
    242a:	mov    rdx,QWORD PTR [rsp+0x68]
    242f:	mov    rcx,QWORD PTR [rsp+0x70]
    2434:	mov    rdi,r15
    2437:	mov    r9,rbx
    243a:	call   243f <botlish_fn_18+0x157>
			243b: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[List[mutarray], mutarray, int], list>
    243f:	test   rax,rax
    2442:	je     24a1 <botlish_fn_18+0x1b9>
    2448:	mov    rdx,QWORD PTR [rsp+0x50]
    244d:	mov    rcx,QWORD PTR [rsp+0x58]
    2452:	mov    QWORD PTR [rsp],r12
    2456:	mov    rsi,r14
    2459:	mov    QWORD PTR [rsp+0x8],rsi
    245e:	mov    QWORD PTR [rsp+0x10],rax
    2463:	mov    QWORD PTR [rsp+0x18],rdx
    2468:	mov    QWORD PTR [rsp+0x20],rcx
    246d:	mov    QWORD PTR [rsp+0x60],rax
    2472:	mov    QWORD PTR [rsp+0x68],rdx
    2477:	mov    QWORD PTR [rsp+0x70],rcx
    247c:	jmp    2370 <botlish_fn_18+0x88>
    2481:	mov    rcx,QWORD PTR [rsp+0x70]
    2486:	mov    rdx,QWORD PTR [rsp+0x68]
    248b:	mov    rsi,QWORD PTR [rsp+0x60]
    2490:	mov    rdi,r15
    2493:	call   2498 <botlish_fn_18+0x1b0>
			2494: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    2498:	test   rax,rax
    249b:	jne    24d8 <botlish_fn_18+0x1f0>
    24a1:	xor    rax,rax
    24a4:	mov    rbx,QWORD PTR [rsp+0x80]
    24ac:	mov    r12,QWORD PTR [rsp+0x88]
    24b4:	mov    r13,QWORD PTR [rsp+0x90]
    24bc:	mov    r14,QWORD PTR [rsp+0x98]
    24c4:	mov    r15,QWORD PTR [rsp+0xa0]
    24cc:	add    rsp,0xb0
    24d3:	mov    rsp,rbp
    24d6:	pop    rbp
    24d7:	ret
    24d8:	mov    rbx,QWORD PTR [rsp+0x80]
    24e0:	mov    r12,QWORD PTR [rsp+0x88]
    24e8:	mov    r13,QWORD PTR [rsp+0x90]
    24f0:	mov    r14,QWORD PTR [rsp+0x98]
    24f8:	mov    r15,QWORD PTR [rsp+0xa0]
    2500:	add    rsp,0xb0
    2507:	mov    rsp,rbp
    250a:	pop    rbp
    250b:	ret
    250c:	add    BYTE PTR [rax],al
    250e:	add    BYTE PTR [rax],al
    2510:	(bad)
    2511:	add    BYTE PTR [rax],al
    2513:	add    BYTE PTR [rax],al
    2515:	add    BYTE PTR [rax],al
	...

0000000000002518 <botlish_entry_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    2518:	push   rbp
    2519:	mov    rbp,rsp
    251c:	mov    rsi,QWORD PTR [rdx]
    251f:	mov    r10,QWORD PTR [rdx+0x8]
    2523:	mov    rcx,QWORD PTR [rdx+0x10]
    2527:	mov    r8,QWORD PTR [rdx+0x18]
    252b:	mov    r9,QWORD PTR [rdx+0x20]
    252f:	mov    rdx,r10
    2532:	call   2537 <botlish_entry_18+0x1f>
			2533: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    2537:	mov    rsp,rbp
    253a:	pop    rbp
    253b:	ret

000000000000253c <botlish_fn_19: csv_parse<str>>:
    253c:	push   rbp
    253d:	mov    rbp,rsp
    2540:	sub    rsp,0x50
    2544:	mov    QWORD PTR [rsp+0x40],r12
    2549:	mov    QWORD PTR [rsp+0x48],r13
    254e:	mov    r13,rdi
    2551:	mov    QWORD PTR [rsp+0x10],0x0
    255a:	mov    QWORD PTR [rsp+0x18],0x0
    2563:	mov    QWORD PTR [rsp+0x20],0x0
    256c:	mov    QWORD PTR [rsp],rsi
    2570:	mov    r12,rsi
    2573:	mov    QWORD PTR [rsp+0x8],0x1
    257c:	lea    rsi,[rsp+0x28]
    2581:	mov    rdi,r13
    2584:	call   2589 <botlish_fn_19+0x4d>
			2585: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2589:	test   rax,rax
    258c:	je     25c7 <botlish_fn_19+0x8b>
    2592:	mov    QWORD PTR [rsp+0x10],rax
    2597:	mov    rcx,rax
    259a:	mov    r8,QWORD PTR [rsp+0x28]
    259f:	mov    QWORD PTR [rsp+0x18],r8
    25a4:	mov    r9,QWORD PTR [rsp+0x30]
    25a9:	mov    QWORD PTR [rsp+0x20],r9
    25ae:	mov    edx,0x1
    25b3:	mov    rsi,r12
    25b6:	mov    rdi,r13
    25b9:	call   25be <botlish_fn_19+0x82>
			25ba: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    25be:	test   rax,rax
    25c1:	jne    25dd <botlish_fn_19+0xa1>
    25c7:	xor    rax,rax
    25ca:	mov    r12,QWORD PTR [rsp+0x40]
    25cf:	mov    r13,QWORD PTR [rsp+0x48]
    25d4:	add    rsp,0x50
    25d8:	mov    rsp,rbp
    25db:	pop    rbp
    25dc:	ret
    25dd:	mov    r12,QWORD PTR [rsp+0x40]
    25e2:	mov    r13,QWORD PTR [rsp+0x48]
    25e7:	add    rsp,0x50
    25eb:	mov    rsp,rbp
    25ee:	pop    rbp
    25ef:	ret

00000000000025f0 <botlish_entry_19: csv_parse<str>>:
    25f0:	push   rbp
    25f1:	mov    rbp,rsp
    25f4:	mov    rsi,QWORD PTR [rdx]
    25f7:	call   25fc <botlish_entry_19+0xc>
			25f8: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    25fc:	mov    rsp,rbp
    25ff:	pop    rbp
    2600:	ret

; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10168  (per function: 68 195 534 534 534 534 498 418 540 540 365 430 585 1063 352 799 833 537 612 197)
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
    154e:	mov    r15,rdi
    1551:	mov    QWORD PTR [rsp+0x18],0x0
    155a:	mov    QWORD PTR [rsp+0x20],0x0
    1563:	mov    QWORD PTR [rsp],rsi
    1567:	mov    QWORD PTR [rsp+0x8],rdx
    156c:	mov    QWORD PTR [rsp+0x10],rcx
    1571:	mov    r13,rcx
    1574:	lea    r14,[rsp+0x68]
    1579:	lea    rbx,[rsp+0x28]
    157e:	mov    r12,rsi
    1581:	mov    QWORD PTR [rsp+0x88],rdx
    1589:	mov    rdx,QWORD PTR [rsp+0x88]
    1591:	mov    rsi,r12
    1594:	mov    rdi,r15
    1597:	call   159c <botlish_fn_13+0x81>
			1598: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    159c:	test   rax,rax
    159f:	je     18a3 <botlish_fn_13+0x388>
    15a5:	mov    QWORD PTR [rsp+0x18],rax
    15aa:	mov    rdi,r15
    15ad:	mov    QWORD PTR [rsp+0x90],rax
    15b5:	mov    rsi,QWORD PTR [rdi+0x10]
    15b9:	mov    rsi,QWORD PTR [rsi+0x28]
    15bd:	mov    edx,0x1
    15c2:	mov    ecx,0x3
    15c7:	mov    r8,QWORD PTR [rsp+0x90]
    15cf:	call   15d4 <botlish_fn_13+0xb9>
			15d0: R_X86_64_PLT32	rt_str_region_eq-0x4
    15d4:	cmp    rax,0x6
    15d8:	je     1698 <botlish_fn_13+0x17d>
    15de:	mov    QWORD PTR [rsp+0x20],0x3
    15e7:	mov    rsi,QWORD PTR [rsp+0x88]
    15ef:	test   rsi,0x1
    15f6:	je     1618 <botlish_fn_13+0xfd>
    15fc:	mov    r9,rsi
    15ff:	add    r9,0x2
    1603:	seto   r11b
    1607:	test   r11b,r11b
    160a:	jne    1618 <botlish_fn_13+0xfd>
    1610:	mov    rsi,r9
    1613:	jmp    1628 <botlish_fn_13+0x10d>
    1618:	mov    edx,0x3
    161d:	mov    rdi,r15
    1620:	call   1625 <botlish_fn_13+0x10a>
			1621: R_X86_64_PLT32	rt_int_add-0x4
    1625:	mov    rsi,rax
    1628:	mov    QWORD PTR [rsp+0x8],rsi
    162d:	mov    QWORD PTR [rsp+0x88],rsi
    1635:	mov    QWORD PTR [rsp+0x68],0x0
    163e:	mov    QWORD PTR [rsp+0x70],r13
    1643:	mov    QWORD PTR [rsp+0x78],0x0
    164c:	mov    rax,QWORD PTR [rsp+0x90]
    1654:	mov    QWORD PTR [rsp+0x80],rax
    165c:	mov    esi,0x2
    1661:	mov    edx,0x4
    1666:	mov    rcx,r14
    1669:	mov    rdi,r15
    166c:	call   1671 <botlish_fn_13+0x156>
			166d: R_X86_64_PLT32	rt_construct-0x4
    1671:	test   rax,rax
    1674:	je     18a3 <botlish_fn_13+0x388>
    167a:	mov    QWORD PTR [rsp],r12
    167e:	mov    rsi,QWORD PTR [rsp+0x88]
    1686:	mov    QWORD PTR [rsp+0x8],rsi
    168b:	mov    QWORD PTR [rsp+0x10],rax
    1690:	mov    r13,rax
    1693:	jmp    1589 <botlish_fn_13+0x6e>
    1698:	mov    QWORD PTR [rsp+0x18],0x3
    16a1:	mov    rsi,QWORD PTR [rsp+0x88]
    16a9:	test   rsi,0x1
    16b0:	je     16d0 <botlish_fn_13+0x1b5>
    16b6:	mov    rsi,QWORD PTR [rsp+0x88]
    16be:	mov    rdx,rsi
    16c1:	add    rdx,0x2
    16c5:	seto   al
    16c8:	test   al,al
    16ca:	je     16e8 <botlish_fn_13+0x1cd>
    16d0:	mov    edx,0x3
    16d5:	mov    rsi,QWORD PTR [rsp+0x88]
    16dd:	mov    rdi,r15
    16e0:	call   16e5 <botlish_fn_13+0x1ca>
			16e1: R_X86_64_PLT32	rt_int_add-0x4
    16e5:	mov    rdx,rax
    16e8:	mov    QWORD PTR [rsp+0x18],rdx
    16ed:	mov    rcx,rbx
    16f0:	mov    rsi,r12
    16f3:	mov    rdi,r15
    16f6:	call   16fb <botlish_fn_13+0x1e0>
			16f7: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    16fb:	test   rax,rax
    16fe:	mov    rsi,rax
    1701:	je     18a3 <botlish_fn_13+0x388>
    1707:	mov    rdx,QWORD PTR [rsp+0x28]
    170c:	mov    rcx,QWORD PTR [rsp+0x30]
    1711:	mov    rdi,r15
    1714:	mov    rax,QWORD PTR [rdi+0x10]
    1718:	mov    r8,QWORD PTR [rax+0x28]
    171c:	call   1721 <botlish_fn_13+0x206>
			171d: R_X86_64_PLT32	rt_str_region_eq-0x4
    1721:	cmp    rax,0x6
    1725:	je     17ed <botlish_fn_13+0x2d2>
    172b:	xor    rsi,rsi
    172e:	lea    rcx,[rsp+0x58]
    1733:	mov    QWORD PTR [rsp+0x58],0x0
    173c:	mov    QWORD PTR [rsp+0x60],r13
    1741:	mov    edx,0x2
    1746:	mov    rdi,r15
    1749:	call   174e <botlish_fn_13+0x233>
			174a: R_X86_64_PLT32	rt_construct-0x4
    174e:	test   rax,rax
    1751:	je     18a3 <botlish_fn_13+0x388>
    1757:	mov    QWORD PTR [rsp],rax
    175b:	mov    rbx,rax
    175e:	mov    QWORD PTR [rsp+0x10],0x3
    1767:	mov    rsi,QWORD PTR [rsp+0x88]
    176f:	test   rsi,0x1
    1776:	je     179e <botlish_fn_13+0x283>
    177c:	mov    rsi,QWORD PTR [rsp+0x88]
    1784:	mov    rdx,rsi
    1787:	add    rdx,0x2
    178b:	seto   al
    178e:	test   al,al
    1790:	jne    179e <botlish_fn_13+0x283>
    1796:	mov    rax,rbx
    1799:	jmp    17b9 <botlish_fn_13+0x29e>
    179e:	mov    edx,0x3
    17a3:	mov    rsi,QWORD PTR [rsp+0x88]
    17ab:	mov    rdi,r15
    17ae:	call   17b3 <botlish_fn_13+0x298>
			17af: R_X86_64_PLT32	rt_int_add-0x4
    17b3:	mov    rdx,rax
    17b6:	mov    rax,rbx
    17b9:	mov    rbx,QWORD PTR [rsp+0xa0]
    17c1:	mov    r12,QWORD PTR [rsp+0xa8]
    17c9:	mov    r13,QWORD PTR [rsp+0xb0]
    17d1:	mov    r14,QWORD PTR [rsp+0xb8]
    17d9:	mov    r15,QWORD PTR [rsp+0xc0]
    17e1:	add    rsp,0xd0
    17e8:	mov    rsp,rbp
    17eb:	pop    rbp
    17ec:	ret
    17ed:	mov    QWORD PTR [rsp+0x18],0x5
    17f6:	mov    rsi,QWORD PTR [rsp+0x88]
    17fe:	test   rsi,0x1
    1805:	je     1835 <botlish_fn_13+0x31a>
    180b:	mov    rsi,QWORD PTR [rsp+0x88]
    1813:	mov    rax,rsi
    1816:	add    rax,0x4
    181a:	seto   cl
    181d:	test   cl,cl
    181f:	jne    1835 <botlish_fn_13+0x31a>
    1825:	mov    rsi,rax
    1828:	mov    QWORD PTR [rsp+0x88],rax
    1830:	jmp    1855 <botlish_fn_13+0x33a>
    1835:	mov    edx,0x5
    183a:	mov    rsi,QWORD PTR [rsp+0x88]
    1842:	mov    rdi,r15
    1845:	call   184a <botlish_fn_13+0x32f>
			1846: R_X86_64_PLT32	rt_int_add-0x4
    184a:	mov    rsi,rax
    184d:	mov    QWORD PTR [rsp+0x88],rax
    1855:	mov    QWORD PTR [rsp+0x8],rsi
    185a:	mov    rdi,r15
    185d:	mov    rsi,QWORD PTR [rdi+0x10]
    1861:	mov    rsi,QWORD PTR [rsi+0x28]
    1865:	mov    QWORD PTR [rsp+0x18],rsi
    186a:	lea    rcx,[rsp+0x38]
    186f:	mov    QWORD PTR [rsp+0x38],0x0
    1878:	mov    QWORD PTR [rsp+0x40],r13
    187d:	mov    QWORD PTR [rsp+0x48],0x0
    1886:	mov    QWORD PTR [rsp+0x50],rsi
    188b:	mov    esi,0x2
    1890:	mov    edx,0x4
    1895:	call   189a <botlish_fn_13+0x37f>
			1896: R_X86_64_PLT32	rt_construct-0x4
    189a:	test   rax,rax
    189d:	jne    18dd <botlish_fn_13+0x3c2>
    18a3:	xor    rdx,rdx
    18a6:	mov    rax,rdx
    18a9:	mov    rbx,QWORD PTR [rsp+0xa0]
    18b1:	mov    r12,QWORD PTR [rsp+0xa8]
    18b9:	mov    r13,QWORD PTR [rsp+0xb0]
    18c1:	mov    r14,QWORD PTR [rsp+0xb8]
    18c9:	mov    r15,QWORD PTR [rsp+0xc0]
    18d1:	add    rsp,0xd0
    18d8:	mov    rsp,rbp
    18db:	pop    rbp
    18dc:	ret
    18dd:	mov    QWORD PTR [rsp],r12
    18e1:	mov    rsi,QWORD PTR [rsp+0x88]
    18e9:	mov    QWORD PTR [rsp+0x8],rsi
    18ee:	mov    QWORD PTR [rsp+0x10],rax
    18f3:	mov    r13,rax
    18f6:	jmp    1589 <botlish_fn_13+0x6e>

00000000000018fb <botlish_entry_13: scan_quoted<str, int, str>>:
    18fb:	push   rbp
    18fc:	mov    rbp,rsp
    18ff:	ud2

0000000000001901 <botlish_fn_14: scan_field<str, int>>:
    1901:	push   rbp
    1902:	mov    rbp,rsp
    1905:	sub    rsp,0x50
    1909:	mov    QWORD PTR [rsp+0x30],rbx
    190e:	mov    QWORD PTR [rsp+0x38],r12
    1913:	mov    QWORD PTR [rsp+0x40],r13
    1918:	mov    r12,rdi
    191b:	mov    r13,rdx
    191e:	mov    QWORD PTR [rsp+0x10],0x0
    1927:	mov    QWORD PTR [rsp],rsi
    192b:	mov    rbx,rsi
    192e:	mov    QWORD PTR [rsp+0x8],rdx
    1933:	lea    rcx,[rsp+0x18]
    1938:	mov    rdx,r13
    193b:	mov    rsi,rbx
    193e:	mov    rdi,r12
    1941:	call   1946 <botlish_fn_14+0x45>
			1942: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1946:	test   rax,rax
    1949:	mov    rsi,rax
    194c:	je     1a17 <botlish_fn_14+0x116>
    1952:	mov    rdx,QWORD PTR [rsp+0x18]
    1957:	mov    rcx,QWORD PTR [rsp+0x20]
    195c:	mov    rdi,r12
    195f:	mov    rax,QWORD PTR [rdi+0x10]
    1963:	mov    r8,QWORD PTR [rax+0x28]
    1967:	call   196c <botlish_fn_14+0x6b>
			1968: R_X86_64_PLT32	rt_str_region_eq-0x4
    196c:	cmp    rax,0x6
    1970:	je     19a8 <botlish_fn_14+0xa7>
    1976:	mov    rcx,r13
    1979:	mov    rsi,rbx
    197c:	mov    rdi,r12
    197f:	mov    rdx,rcx
    1982:	call   1987 <botlish_fn_14+0x86>
			1983: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_unquoted<str, int, int>
    1987:	test   rax,rax
    198a:	je     1a17 <botlish_fn_14+0x116>
    1990:	mov    rbx,QWORD PTR [rsp+0x30]
    1995:	mov    r12,QWORD PTR [rsp+0x38]
    199a:	mov    r13,QWORD PTR [rsp+0x40]
    199f:	add    rsp,0x50
    19a3:	mov    rsp,rbp
    19a6:	pop    rbp
    19a7:	ret
    19a8:	mov    rcx,r13
    19ab:	mov    QWORD PTR [rsp+0x10],0x3
    19b4:	test   rcx,0x1
    19bb:	jne    19c9 <botlish_fn_14+0xc8>
    19c1:	mov    r13,rcx
    19c4:	jmp    19de <botlish_fn_14+0xdd>
    19c9:	mov    rdx,rcx
    19cc:	add    rdx,0x2
    19d0:	mov    r13,rcx
    19d3:	seto   al
    19d6:	test   al,al
    19d8:	je     19f1 <botlish_fn_14+0xf0>
    19de:	mov    edx,0x3
    19e3:	mov    rsi,r13
    19e6:	mov    rdi,r12
    19e9:	call   19ee <botlish_fn_14+0xed>
			19ea: R_X86_64_PLT32	rt_int_add-0x4
    19ee:	mov    rdx,rax
    19f1:	mov    QWORD PTR [rsp+0x8],rdx
    19f6:	mov    rdi,r12
    19f9:	mov    rax,QWORD PTR [rdi+0x10]
    19fd:	mov    rcx,QWORD PTR [rax+0x10]
    1a01:	mov    QWORD PTR [rsp+0x10],rcx
    1a06:	mov    rsi,rbx
    1a09:	call   1a0e <botlish_fn_14+0x10d>
			1a0a: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_quoted<str, int, str>
    1a0e:	test   rax,rax
    1a11:	jne    1a35 <botlish_fn_14+0x134>
    1a17:	xor    rdx,rdx
    1a1a:	mov    rax,rdx
    1a1d:	mov    rbx,QWORD PTR [rsp+0x30]
    1a22:	mov    r12,QWORD PTR [rsp+0x38]
    1a27:	mov    r13,QWORD PTR [rsp+0x40]
    1a2c:	add    rsp,0x50
    1a30:	mov    rsp,rbp
    1a33:	pop    rbp
    1a34:	ret
    1a35:	mov    rbx,QWORD PTR [rsp+0x30]
    1a3a:	mov    r12,QWORD PTR [rsp+0x38]
    1a3f:	mov    r13,QWORD PTR [rsp+0x40]
    1a44:	add    rsp,0x50
    1a48:	mov    rsp,rbp
    1a4b:	pop    rbp
    1a4c:	ret

0000000000001a4d <botlish_entry_14: scan_field<str, int>>:
    1a4d:	push   rbp
    1a4e:	mov    rbp,rsp
    1a51:	ud2

0000000000001a53 <botlish_fn_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1a53:	push   rbp
    1a54:	mov    rbp,rsp
    1a57:	sub    rsp,0xa0
    1a5e:	mov    QWORD PTR [rsp+0x70],rbx
    1a63:	mov    QWORD PTR [rsp+0x78],r12
    1a68:	mov    QWORD PTR [rsp+0x80],r13
    1a70:	mov    QWORD PTR [rsp+0x88],r14
    1a78:	mov    QWORD PTR [rsp+0x90],r15
    1a80:	mov    r13,rdi
    1a83:	mov    QWORD PTR [rsp+0x28],0x0
    1a8c:	mov    QWORD PTR [rsp],rsi
    1a90:	mov    r15,rsi
    1a93:	mov    QWORD PTR [rsp+0x8],rdx
    1a98:	mov    QWORD PTR [rsp+0x10],rcx
    1a9d:	mov    QWORD PTR [rsp+0x50],rcx
    1aa2:	mov    QWORD PTR [rsp+0x18],r8
    1aa7:	mov    r12,r8
    1aaa:	mov    QWORD PTR [rsp+0x20],r9
    1aaf:	mov    rbx,r9
    1ab2:	mov    rsi,r15
    1ab5:	mov    rdi,r13
    1ab8:	call   1abd <botlish_fn_15+0x6a>
			1ab9: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1abd:	test   rax,rax
    1ac0:	je     1cf4 <botlish_fn_15+0x2a1>
    1ac6:	mov    QWORD PTR [rsp+0x8],rax
    1acb:	mov    r8,rax
    1ace:	mov    QWORD PTR [rsp+0x28],rdx
    1ad3:	mov    r14,rdx
    1ad6:	lea    r9,[rsp+0x30]
    1adb:	mov    rcx,rbx
    1ade:	mov    rdx,r12
    1ae1:	mov    rsi,QWORD PTR [rsp+0x50]
    1ae6:	mov    rdi,r13
    1ae9:	call   1aee <botlish_fn_15+0x9b>
			1aea: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<list[List[never], mutarray, int], str>
    1aee:	test   rax,rax
    1af1:	je     1cf4 <botlish_fn_15+0x2a1>
    1af7:	mov    QWORD PTR [rsp+0x8],rax
    1afc:	mov    QWORD PTR [rsp+0x68],rax
    1b01:	mov    rdx,QWORD PTR [rsp+0x30]
    1b06:	mov    QWORD PTR [rsp+0x10],rdx
    1b0b:	mov    QWORD PTR [rsp+0x60],rdx
    1b10:	mov    rcx,QWORD PTR [rsp+0x38]
    1b15:	mov    QWORD PTR [rsp+0x18],rcx
    1b1a:	mov    QWORD PTR [rsp+0x58],rcx
    1b1f:	lea    rcx,[rsp+0x40]
    1b24:	mov    rdx,r14
    1b27:	mov    rsi,r15
    1b2a:	mov    rdi,r13
    1b2d:	call   1b32 <botlish_fn_15+0xdf>
			1b2e: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1b32:	test   rax,rax
    1b35:	mov    QWORD PTR [rsp+0x50],rax
    1b3a:	je     1cf4 <botlish_fn_15+0x2a1>
    1b40:	mov    r12,QWORD PTR [rsp+0x40]
    1b45:	mov    rbx,QWORD PTR [rsp+0x48]
    1b4a:	mov    rdi,r13
    1b4d:	mov    rcx,QWORD PTR [rdi+0x10]
    1b51:	mov    r8,QWORD PTR [rcx+0x18]
    1b55:	mov    rcx,rbx
    1b58:	mov    rdx,r12
    1b5b:	mov    rsi,QWORD PTR [rsp+0x50]
    1b60:	call   1b65 <botlish_fn_15+0x112>
			1b61: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b65:	cmp    rax,0x6
    1b69:	je     1c83 <botlish_fn_15+0x230>
    1b6f:	mov    rdi,r13
    1b72:	mov    rax,QWORD PTR [rdi+0x10]
    1b76:	mov    r8,QWORD PTR [rax+0x20]
    1b7a:	mov    rcx,rbx
    1b7d:	mov    rdx,r12
    1b80:	mov    rsi,QWORD PTR [rsp+0x50]
    1b85:	call   1b8a <botlish_fn_15+0x137>
			1b86: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b8a:	cmp    rax,0x6
    1b8e:	je     1be5 <botlish_fn_15+0x192>
    1b94:	mov    rcx,QWORD PTR [rsp+0x58]
    1b99:	mov    rdx,QWORD PTR [rsp+0x60]
    1b9e:	mov    rsi,QWORD PTR [rsp+0x68]
    1ba3:	mov    rdi,r13
    1ba6:	call   1bab <botlish_fn_15+0x158>
			1ba7: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1bab:	test   rax,rax
    1bae:	je     1cf4 <botlish_fn_15+0x2a1>
    1bb4:	mov    rdx,r14
    1bb7:	mov    rbx,QWORD PTR [rsp+0x70]
    1bbc:	mov    r12,QWORD PTR [rsp+0x78]
    1bc1:	mov    r13,QWORD PTR [rsp+0x80]
    1bc9:	mov    r14,QWORD PTR [rsp+0x88]
    1bd1:	mov    r15,QWORD PTR [rsp+0x90]
    1bd9:	add    rsp,0xa0
    1be0:	mov    rsp,rbp
    1be3:	pop    rbp
    1be4:	ret
    1be5:	mov    rcx,QWORD PTR [rsp+0x58]
    1bea:	mov    rdx,QWORD PTR [rsp+0x60]
    1bef:	mov    rsi,QWORD PTR [rsp+0x68]
    1bf4:	mov    rdi,r13
    1bf7:	call   1bfc <botlish_fn_15+0x1a9>
			1bf8: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1bfc:	test   rax,rax
    1bff:	je     1cf4 <botlish_fn_15+0x2a1>
    1c05:	mov    QWORD PTR [rsp],rax
    1c09:	mov    rbx,rax
    1c0c:	mov    QWORD PTR [rsp+0x8],0x3
    1c15:	mov    rdx,r14
    1c18:	test   rdx,0x1
    1c1f:	je     1c3f <botlish_fn_15+0x1ec>
    1c25:	mov    rdx,r14
    1c28:	add    rdx,0x2
    1c2c:	seto   al
    1c2f:	test   al,al
    1c31:	jne    1c3f <botlish_fn_15+0x1ec>
    1c37:	mov    rax,rbx
    1c3a:	jmp    1c55 <botlish_fn_15+0x202>
    1c3f:	mov    edx,0x3
    1c44:	mov    rsi,r14
    1c47:	mov    rdi,r13
    1c4a:	call   1c4f <botlish_fn_15+0x1fc>
			1c4b: R_X86_64_PLT32	rt_int_add-0x4
    1c4f:	mov    rdx,rax
    1c52:	mov    rax,rbx
    1c55:	mov    rbx,QWORD PTR [rsp+0x70]
    1c5a:	mov    r12,QWORD PTR [rsp+0x78]
    1c5f:	mov    r13,QWORD PTR [rsp+0x80]
    1c67:	mov    r14,QWORD PTR [rsp+0x88]
    1c6f:	mov    r15,QWORD PTR [rsp+0x90]
    1c77:	add    rsp,0xa0
    1c7e:	mov    rsp,rbp
    1c81:	pop    rbp
    1c82:	ret
    1c83:	mov    rsi,r14
    1c86:	mov    edx,0x3
    1c8b:	mov    rcx,rdx
    1c8e:	mov    QWORD PTR [rsp+0x20],0x3
    1c97:	test   rsi,0x1
    1c9e:	jne    1cac <botlish_fn_15+0x259>
    1ca4:	mov    rdx,rcx
    1ca7:	jmp    1cc1 <botlish_fn_15+0x26e>
    1cac:	mov    rdx,rsi
    1caf:	add    rdx,0x2
    1cb3:	seto   al
    1cb6:	test   al,al
    1cb8:	je     1ccc <botlish_fn_15+0x279>
    1cbe:	mov    rdx,rcx
    1cc1:	mov    rdi,r13
    1cc4:	call   1cc9 <botlish_fn_15+0x276>
			1cc5: R_X86_64_PLT32	rt_int_add-0x4
    1cc9:	mov    rdx,rax
    1ccc:	mov    QWORD PTR [rsp+0x20],rdx
    1cd1:	mov    rcx,QWORD PTR [rsp+0x68]
    1cd6:	mov    rsi,r15
    1cd9:	mov    rdi,r13
    1cdc:	mov    r8,QWORD PTR [rsp+0x60]
    1ce1:	mov    r9,QWORD PTR [rsp+0x58]
    1ce6:	call   1ceb <botlish_fn_15+0x298>
			1ce7: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[List[mutarray], mutarray, int]>
    1ceb:	test   rax,rax
    1cee:	jne    1d28 <botlish_fn_15+0x2d5>
    1cf4:	xor    rdx,rdx
    1cf7:	mov    rax,rdx
    1cfa:	mov    rbx,QWORD PTR [rsp+0x70]
    1cff:	mov    r12,QWORD PTR [rsp+0x78]
    1d04:	mov    r13,QWORD PTR [rsp+0x80]
    1d0c:	mov    r14,QWORD PTR [rsp+0x88]
    1d14:	mov    r15,QWORD PTR [rsp+0x90]
    1d1c:	add    rsp,0xa0
    1d23:	mov    rsp,rbp
    1d26:	pop    rbp
    1d27:	ret
    1d28:	mov    rbx,QWORD PTR [rsp+0x70]
    1d2d:	mov    r12,QWORD PTR [rsp+0x78]
    1d32:	mov    r13,QWORD PTR [rsp+0x80]
    1d3a:	mov    r14,QWORD PTR [rsp+0x88]
    1d42:	mov    r15,QWORD PTR [rsp+0x90]
    1d4a:	add    rsp,0xa0
    1d51:	mov    rsp,rbp
    1d54:	pop    rbp
    1d55:	ret

0000000000001d56 <botlish_entry_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1d56:	push   rbp
    1d57:	mov    rbp,rsp
    1d5a:	ud2

0000000000001d5c <botlish_fn_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    1d5c:	push   rbp
    1d5d:	mov    rbp,rsp
    1d60:	sub    rsp,0xb0
    1d67:	mov    QWORD PTR [rsp+0x80],rbx
    1d6f:	mov    QWORD PTR [rsp+0x88],r12
    1d77:	mov    QWORD PTR [rsp+0x90],r13
    1d7f:	mov    QWORD PTR [rsp+0x98],r14
    1d87:	mov    QWORD PTR [rsp+0xa0],r15
    1d8f:	mov    QWORD PTR [rsp+0x50],rdi
    1d94:	mov    QWORD PTR [rsp+0x28],0x0
    1d9d:	mov    QWORD PTR [rsp],rsi
    1da1:	mov    QWORD PTR [rsp+0x8],rdx
    1da6:	mov    QWORD PTR [rsp+0x10],rcx
    1dab:	mov    QWORD PTR [rsp+0x18],r8
    1db0:	mov    QWORD PTR [rsp+0x20],r9
    1db5:	lea    r15,[rsp+0x30]
    1dba:	lea    rbx,[rsp+0x40]
    1dbf:	mov    r12,rsi
    1dc2:	mov    r13,rcx
    1dc5:	mov    QWORD PTR [rsp+0x58],r8
    1dca:	mov    QWORD PTR [rsp+0x60],r9
    1dcf:	mov    rsi,r12
    1dd2:	mov    rdi,QWORD PTR [rsp+0x50]
    1dd7:	call   1ddc <botlish_fn_16+0x80>
			1dd8: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1ddc:	mov    QWORD PTR [rsp+0x78],rdx
    1de1:	test   rax,rax
    1de4:	je     1f3f <botlish_fn_16+0x1e3>
    1dea:	mov    QWORD PTR [rsp+0x8],rax
    1def:	mov    rdx,QWORD PTR [rsp+0x78]
    1df4:	mov    r8,rax
    1df7:	mov    QWORD PTR [rsp+0x28],rdx
    1dfc:	mov    rcx,QWORD PTR [rsp+0x60]
    1e01:	mov    rdx,QWORD PTR [rsp+0x58]
    1e06:	mov    rsi,r13
    1e09:	mov    rdi,QWORD PTR [rsp+0x50]
    1e0e:	mov    r9,r15
    1e11:	call   1e16 <botlish_fn_16+0xba>
			1e12: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[List[mutarray], mutarray, int], str>
    1e16:	test   rax,rax
    1e19:	je     1f3f <botlish_fn_16+0x1e3>
    1e1f:	mov    QWORD PTR [rsp+0x8],rax
    1e24:	mov    QWORD PTR [rsp+0x70],rax
    1e29:	mov    rdx,QWORD PTR [rsp+0x30]
    1e2e:	mov    QWORD PTR [rsp+0x58],rdx
    1e33:	mov    QWORD PTR [rsp+0x10],rdx
    1e38:	mov    rcx,QWORD PTR [rsp+0x38]
    1e3d:	mov    QWORD PTR [rsp+0x18],rcx
    1e42:	mov    QWORD PTR [rsp+0x60],rcx
    1e47:	mov    rcx,rbx
    1e4a:	mov    rdx,QWORD PTR [rsp+0x78]
    1e4f:	mov    rsi,r12
    1e52:	mov    rdi,QWORD PTR [rsp+0x50]
    1e57:	call   1e5c <botlish_fn_16+0x100>
			1e58: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1e5c:	test   rax,rax
    1e5f:	mov    QWORD PTR [rsp+0x68],rax
    1e64:	je     1f3f <botlish_fn_16+0x1e3>
    1e6a:	mov    r13,QWORD PTR [rsp+0x40]
    1e6f:	mov    r14,QWORD PTR [rsp+0x48]
    1e74:	mov    rdi,QWORD PTR [rsp+0x50]
    1e79:	mov    rcx,QWORD PTR [rdi+0x10]
    1e7d:	mov    r8,QWORD PTR [rcx+0x18]
    1e81:	mov    rcx,r14
    1e84:	mov    rdx,r13
    1e87:	mov    rsi,QWORD PTR [rsp+0x68]
    1e8c:	call   1e91 <botlish_fn_16+0x135>
			1e8d: R_X86_64_PLT32	rt_str_region_eq-0x4
    1e91:	cmp    rax,0x6
    1e95:	je     2005 <botlish_fn_16+0x2a9>
    1e9b:	mov    rdi,QWORD PTR [rsp+0x50]
    1ea0:	mov    rax,QWORD PTR [rdi+0x10]
    1ea4:	mov    r8,QWORD PTR [rax+0x20]
    1ea8:	mov    rcx,r14
    1eab:	mov    rdx,r13
    1eae:	mov    rsi,QWORD PTR [rsp+0x68]
    1eb3:	call   1eb8 <botlish_fn_16+0x15c>
			1eb4: R_X86_64_PLT32	rt_str_region_eq-0x4
    1eb8:	cmp    rax,0x6
    1ebc:	je     1f1d <botlish_fn_16+0x1c1>
    1ec2:	mov    rcx,QWORD PTR [rsp+0x60]
    1ec7:	mov    rdx,QWORD PTR [rsp+0x58]
    1ecc:	mov    rsi,QWORD PTR [rsp+0x70]
    1ed1:	mov    rdi,QWORD PTR [rsp+0x50]
    1ed6:	call   1edb <botlish_fn_16+0x17f>
			1ed7: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1edb:	test   rax,rax
    1ede:	je     1f3f <botlish_fn_16+0x1e3>
    1ee4:	mov    rdx,QWORD PTR [rsp+0x78]
    1ee9:	mov    rbx,QWORD PTR [rsp+0x80]
    1ef1:	mov    r12,QWORD PTR [rsp+0x88]
    1ef9:	mov    r13,QWORD PTR [rsp+0x90]
    1f01:	mov    r14,QWORD PTR [rsp+0x98]
    1f09:	mov    r15,QWORD PTR [rsp+0xa0]
    1f11:	add    rsp,0xb0
    1f18:	mov    rsp,rbp
    1f1b:	pop    rbp
    1f1c:	ret
    1f1d:	mov    rcx,QWORD PTR [rsp+0x60]
    1f22:	mov    rdx,QWORD PTR [rsp+0x58]
    1f27:	mov    rsi,QWORD PTR [rsp+0x70]
    1f2c:	mov    rdi,QWORD PTR [rsp+0x50]
    1f31:	call   1f36 <botlish_fn_16+0x1da>
			1f32: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1f36:	test   rax,rax
    1f39:	jne    1f79 <botlish_fn_16+0x21d>
    1f3f:	xor    rdx,rdx
    1f42:	mov    rax,rdx
    1f45:	mov    rbx,QWORD PTR [rsp+0x80]
    1f4d:	mov    r12,QWORD PTR [rsp+0x88]
    1f55:	mov    r13,QWORD PTR [rsp+0x90]
    1f5d:	mov    r14,QWORD PTR [rsp+0x98]
    1f65:	mov    r15,QWORD PTR [rsp+0xa0]
    1f6d:	add    rsp,0xb0
    1f74:	mov    rsp,rbp
    1f77:	pop    rbp
    1f78:	ret
    1f79:	mov    QWORD PTR [rsp],rax
    1f7d:	mov    rbx,rax
    1f80:	mov    QWORD PTR [rsp+0x8],0x3
    1f89:	mov    rdx,QWORD PTR [rsp+0x78]
    1f8e:	test   rdx,0x1
    1f95:	je     1fb7 <botlish_fn_16+0x25b>
    1f9b:	mov    rdx,QWORD PTR [rsp+0x78]
    1fa0:	add    rdx,0x2
    1fa4:	seto   al
    1fa7:	test   al,al
    1fa9:	jne    1fb7 <botlish_fn_16+0x25b>
    1faf:	mov    rax,rbx
    1fb2:	jmp    1fd1 <botlish_fn_16+0x275>
    1fb7:	mov    edx,0x3
    1fbc:	mov    rsi,QWORD PTR [rsp+0x78]
    1fc1:	mov    rdi,QWORD PTR [rsp+0x50]
    1fc6:	call   1fcb <botlish_fn_16+0x26f>
			1fc7: R_X86_64_PLT32	rt_int_add-0x4
    1fcb:	mov    rdx,rax
    1fce:	mov    rax,rbx
    1fd1:	mov    rbx,QWORD PTR [rsp+0x80]
    1fd9:	mov    r12,QWORD PTR [rsp+0x88]
    1fe1:	mov    r13,QWORD PTR [rsp+0x90]
    1fe9:	mov    r14,QWORD PTR [rsp+0x98]
    1ff1:	mov    r15,QWORD PTR [rsp+0xa0]
    1ff9:	add    rsp,0xb0
    2000:	mov    rsp,rbp
    2003:	pop    rbp
    2004:	ret
    2005:	mov    rsi,QWORD PTR [rsp+0x78]
    200a:	mov    edx,0x3
    200f:	mov    r10,rdx
    2012:	mov    QWORD PTR [rsp+0x20],0x3
    201b:	test   rsi,0x1
    2022:	jne    2030 <botlish_fn_16+0x2d4>
    2028:	mov    rdx,r10
    202b:	jmp    2045 <botlish_fn_16+0x2e9>
    2030:	mov    rdx,rsi
    2033:	add    rdx,0x2
    2037:	seto   al
    203a:	test   al,al
    203c:	je     2052 <botlish_fn_16+0x2f6>
    2042:	mov    rdx,r10
    2045:	mov    rdi,QWORD PTR [rsp+0x50]
    204a:	call   204f <botlish_fn_16+0x2f3>
			204b: R_X86_64_PLT32	rt_int_add-0x4
    204f:	mov    rdx,rax
    2052:	mov    QWORD PTR [rsp],r12
    2056:	mov    QWORD PTR [rsp+0x8],rdx
    205b:	mov    rsi,QWORD PTR [rsp+0x70]
    2060:	mov    QWORD PTR [rsp+0x10],rsi
    2065:	mov    rax,QWORD PTR [rsp+0x58]
    206a:	mov    QWORD PTR [rsp+0x18],rax
    206f:	mov    rcx,QWORD PTR [rsp+0x60]
    2074:	mov    QWORD PTR [rsp+0x20],rcx
    2079:	mov    r13,rsi
    207c:	jmp    1dcf <botlish_fn_16+0x73>

0000000000002081 <botlish_entry_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    2081:	push   rbp
    2082:	mov    rbp,rsp
    2085:	ud2

0000000000002087 <botlish_fn_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    2087:	push   rbp
    2088:	mov    rbp,rsp
    208b:	sub    rsp,0xa0
    2092:	mov    QWORD PTR [rsp+0x70],rbx
    2097:	mov    QWORD PTR [rsp+0x78],r12
    209c:	mov    QWORD PTR [rsp+0x80],r13
    20a4:	mov    QWORD PTR [rsp+0x88],r14
    20ac:	mov    QWORD PTR [rsp+0x90],r15
    20b4:	mov    r12,rdi
    20b7:	mov    QWORD PTR [rsp+0x28],0x0
    20c0:	mov    QWORD PTR [rsp+0x30],0x0
    20c9:	mov    QWORD PTR [rsp+0x38],0x0
    20d2:	mov    QWORD PTR [rsp],rsi
    20d6:	mov    rbx,rsi
    20d9:	mov    QWORD PTR [rsp+0x8],rdx
    20de:	mov    QWORD PTR [rsp+0x60],rdx
    20e3:	mov    QWORD PTR [rsp+0x10],rcx
    20e8:	mov    r15,rcx
    20eb:	mov    QWORD PTR [rsp+0x18],r8
    20f0:	mov    r14,r8
    20f3:	mov    QWORD PTR [rsp+0x20],r9
    20f8:	mov    r13,r9
    20fb:	mov    rsi,rbx
    20fe:	mov    rdi,r12
    2101:	call   2106 <botlish_fn_17+0x7f>
			2102: R_X86_64_PLT32	rt_str_len-0x4
    2106:	mov    rdx,QWORD PTR [rsp+0x60]
    210b:	mov    rcx,rdx
    210e:	sar    rcx,1
    2111:	sar    rax,1
    2114:	cmp    rcx,rax
    2117:	jge    21fc <botlish_fn_17+0x175>
    211d:	lea    rsi,[rsp+0x40]
    2122:	mov    rdi,r12
    2125:	call   212a <botlish_fn_17+0xa3>
			2126: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    212a:	test   rax,rax
    212d:	je     2216 <botlish_fn_17+0x18f>
    2133:	mov    QWORD PTR [rsp+0x28],rax
    2138:	mov    rcx,rax
    213b:	mov    r8,QWORD PTR [rsp+0x40]
    2140:	mov    QWORD PTR [rsp+0x30],r8
    2145:	mov    r9,QWORD PTR [rsp+0x48]
    214a:	mov    QWORD PTR [rsp+0x38],r9
    214f:	mov    rdx,QWORD PTR [rsp+0x60]
    2154:	mov    rsi,rbx
    2157:	mov    rdi,r12
    215a:	call   215f <botlish_fn_17+0xd8>
			215b: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    215f:	test   rax,rax
    2162:	je     2216 <botlish_fn_17+0x18f>
    2168:	mov    QWORD PTR [rsp+0x8],rax
    216d:	mov    r8,rax
    2170:	mov    QWORD PTR [rsp+0x28],rdx
    2175:	mov    QWORD PTR [rsp+0x60],rdx
    217a:	lea    r9,[rsp+0x50]
    217f:	mov    rcx,r13
    2182:	mov    rdx,r14
    2185:	mov    rsi,r15
    2188:	mov    rdi,r12
    218b:	call   2190 <botlish_fn_17+0x109>
			218c: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[List[never], mutarray, int], list>
    2190:	test   rax,rax
    2193:	je     2216 <botlish_fn_17+0x18f>
    2199:	mov    QWORD PTR [rsp+0x8],rax
    219e:	mov    rcx,rax
    21a1:	mov    r8,QWORD PTR [rsp+0x50]
    21a6:	mov    QWORD PTR [rsp+0x10],r8
    21ab:	mov    r9,QWORD PTR [rsp+0x58]
    21b0:	mov    QWORD PTR [rsp+0x18],r9
    21b5:	mov    rdx,QWORD PTR [rsp+0x60]
    21ba:	mov    rsi,rbx
    21bd:	mov    rdi,r12
    21c0:	call   21c5 <botlish_fn_17+0x13e>
			21c1: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    21c5:	test   rax,rax
    21c8:	je     2216 <botlish_fn_17+0x18f>
    21ce:	mov    rbx,QWORD PTR [rsp+0x70]
    21d3:	mov    r12,QWORD PTR [rsp+0x78]
    21d8:	mov    r13,QWORD PTR [rsp+0x80]
    21e0:	mov    r14,QWORD PTR [rsp+0x88]
    21e8:	mov    r15,QWORD PTR [rsp+0x90]
    21f0:	add    rsp,0xa0
    21f7:	mov    rsp,rbp
    21fa:	pop    rbp
    21fb:	ret
    21fc:	mov    rcx,r13
    21ff:	mov    rdx,r14
    2202:	mov    rsi,r15
    2205:	mov    rdi,r12
    2208:	call   220d <botlish_fn_17+0x186>
			2209: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[List[never], mutarray, int]>
    220d:	test   rax,rax
    2210:	jne    2247 <botlish_fn_17+0x1c0>
    2216:	xor    rax,rax
    2219:	mov    rbx,QWORD PTR [rsp+0x70]
    221e:	mov    r12,QWORD PTR [rsp+0x78]
    2223:	mov    r13,QWORD PTR [rsp+0x80]
    222b:	mov    r14,QWORD PTR [rsp+0x88]
    2233:	mov    r15,QWORD PTR [rsp+0x90]
    223b:	add    rsp,0xa0
    2242:	mov    rsp,rbp
    2245:	pop    rbp
    2246:	ret
    2247:	mov    rbx,QWORD PTR [rsp+0x70]
    224c:	mov    r12,QWORD PTR [rsp+0x78]
    2251:	mov    r13,QWORD PTR [rsp+0x80]
    2259:	mov    r14,QWORD PTR [rsp+0x88]
    2261:	mov    r15,QWORD PTR [rsp+0x90]
    2269:	add    rsp,0xa0
    2270:	mov    rsp,rbp
    2273:	pop    rbp
    2274:	ret

0000000000002275 <botlish_entry_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    2275:	push   rbp
    2276:	mov    rbp,rsp
    2279:	mov    rsi,QWORD PTR [rdx]
    227c:	mov    r10,QWORD PTR [rdx+0x8]
    2280:	mov    rcx,QWORD PTR [rdx+0x10]
    2284:	mov    r8,QWORD PTR [rdx+0x18]
    2288:	mov    r9,QWORD PTR [rdx+0x20]
    228c:	mov    rdx,r10
    228f:	call   2294 <botlish_entry_17+0x1f>
			2290: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    2294:	mov    rsp,rbp
    2297:	pop    rbp
    2298:	ret
    2299:	add    BYTE PTR [rax],al
    229b:	add    BYTE PTR [rax],al
    229d:	add    BYTE PTR [rax],al
	...

00000000000022a0 <botlish_fn_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    22a0:	push   rbp
    22a1:	mov    rbp,rsp
    22a4:	sub    rsp,0xb0
    22ab:	mov    QWORD PTR [rsp+0x80],rbx
    22b3:	mov    QWORD PTR [rsp+0x88],r12
    22bb:	mov    QWORD PTR [rsp+0x90],r13
    22c3:	mov    QWORD PTR [rsp+0x98],r14
    22cb:	mov    QWORD PTR [rsp+0xa0],r15
    22d3:	mov    r15,rdi
    22d6:	mov    QWORD PTR [rsp+0x28],0x0
    22df:	mov    QWORD PTR [rsp+0x30],0x0
    22e8:	mov    QWORD PTR [rsp+0x38],0x0
    22f1:	mov    QWORD PTR [rsp],rsi
    22f5:	mov    QWORD PTR [rsp+0x8],rdx
    22fa:	mov    r14,rdx
    22fd:	mov    QWORD PTR [rsp+0x10],rcx
    2302:	mov    QWORD PTR [rsp+0x18],r8
    2307:	mov    QWORD PTR [rsp+0x20],r9
    230c:	lea    r13,[rsp+0x40]
    2311:	lea    rbx,[rsp+0x50]
    2316:	mov    r12,rsi
    2319:	mov    QWORD PTR [rsp+0x60],rcx
    231e:	mov    QWORD PTR [rsp+0x68],r8
    2323:	mov    QWORD PTR [rsp+0x70],r9
    2328:	mov    rsi,r12
    232b:	mov    rdi,r15
    232e:	call   2333 <botlish_fn_18+0x93>
			232f: R_X86_64_PLT32	rt_str_len-0x4
    2333:	mov    rcx,r14
    2336:	and    rcx,rax
    2339:	mov    rdx,rax
    233c:	test   rcx,0x1
    2343:	jne    2369 <botlish_fn_18+0xc9>
    2349:	mov    rsi,r14
    234c:	mov    rdi,r15
    234f:	call   2354 <botlish_fn_18+0xb4>
			2350: R_X86_64_PLT32	rt_int_cmp-0x4
    2354:	mov    ecx,0x2
    2359:	test   rax,rax
    235c:	cmovge rcx,QWORD PTR [rip+0x164]        # 24c8 <botlish_fn_18+0x228>
    2364:	jmp    237c <botlish_fn_18+0xdc>
    2369:	mov    ecx,0x2
    236e:	mov    rdi,r14
    2371:	cmp    rdi,rdx
    2374:	cmovge rcx,QWORD PTR [rip+0x14c]        # 24c8 <botlish_fn_18+0x228>
    237c:	cmp    rcx,0x6
    2380:	je     2439 <botlish_fn_18+0x199>
    2386:	mov    rsi,r13
    2389:	mov    rdi,r15
    238c:	call   2391 <botlish_fn_18+0xf1>
			238d: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2391:	test   rax,rax
    2394:	je     2459 <botlish_fn_18+0x1b9>
    239a:	mov    QWORD PTR [rsp+0x28],rax
    239f:	mov    rcx,rax
    23a2:	mov    r8,QWORD PTR [rsp+0x40]
    23a7:	mov    QWORD PTR [rsp+0x30],r8
    23ac:	mov    r9,QWORD PTR [rsp+0x48]
    23b1:	mov    QWORD PTR [rsp+0x38],r9
    23b6:	mov    rdx,r14
    23b9:	mov    rsi,r12
    23bc:	mov    rdi,r15
    23bf:	call   23c4 <botlish_fn_18+0x124>
			23c0: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    23c4:	test   rax,rax
    23c7:	je     2459 <botlish_fn_18+0x1b9>
    23cd:	mov    QWORD PTR [rsp+0x8],rax
    23d2:	mov    r8,rax
    23d5:	mov    QWORD PTR [rsp+0x28],rdx
    23da:	mov    r14,rdx
    23dd:	mov    rsi,QWORD PTR [rsp+0x60]
    23e2:	mov    rdx,QWORD PTR [rsp+0x68]
    23e7:	mov    rcx,QWORD PTR [rsp+0x70]
    23ec:	mov    rdi,r15
    23ef:	mov    r9,rbx
    23f2:	call   23f7 <botlish_fn_18+0x157>
			23f3: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[List[mutarray], mutarray, int], list>
    23f7:	test   rax,rax
    23fa:	je     2459 <botlish_fn_18+0x1b9>
    2400:	mov    rdx,QWORD PTR [rsp+0x50]
    2405:	mov    rcx,QWORD PTR [rsp+0x58]
    240a:	mov    QWORD PTR [rsp],r12
    240e:	mov    rsi,r14
    2411:	mov    QWORD PTR [rsp+0x8],rsi
    2416:	mov    QWORD PTR [rsp+0x10],rax
    241b:	mov    QWORD PTR [rsp+0x18],rdx
    2420:	mov    QWORD PTR [rsp+0x20],rcx
    2425:	mov    QWORD PTR [rsp+0x60],rax
    242a:	mov    QWORD PTR [rsp+0x68],rdx
    242f:	mov    QWORD PTR [rsp+0x70],rcx
    2434:	jmp    2328 <botlish_fn_18+0x88>
    2439:	mov    rcx,QWORD PTR [rsp+0x70]
    243e:	mov    rdx,QWORD PTR [rsp+0x68]
    2443:	mov    rsi,QWORD PTR [rsp+0x60]
    2448:	mov    rdi,r15
    244b:	call   2450 <botlish_fn_18+0x1b0>
			244c: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    2450:	test   rax,rax
    2453:	jne    2490 <botlish_fn_18+0x1f0>
    2459:	xor    rax,rax
    245c:	mov    rbx,QWORD PTR [rsp+0x80]
    2464:	mov    r12,QWORD PTR [rsp+0x88]
    246c:	mov    r13,QWORD PTR [rsp+0x90]
    2474:	mov    r14,QWORD PTR [rsp+0x98]
    247c:	mov    r15,QWORD PTR [rsp+0xa0]
    2484:	add    rsp,0xb0
    248b:	mov    rsp,rbp
    248e:	pop    rbp
    248f:	ret
    2490:	mov    rbx,QWORD PTR [rsp+0x80]
    2498:	mov    r12,QWORD PTR [rsp+0x88]
    24a0:	mov    r13,QWORD PTR [rsp+0x90]
    24a8:	mov    r14,QWORD PTR [rsp+0x98]
    24b0:	mov    r15,QWORD PTR [rsp+0xa0]
    24b8:	add    rsp,0xb0
    24bf:	mov    rsp,rbp
    24c2:	pop    rbp
    24c3:	ret
    24c4:	add    BYTE PTR [rax],al
    24c6:	add    BYTE PTR [rax],al
    24c8:	(bad)
    24c9:	add    BYTE PTR [rax],al
    24cb:	add    BYTE PTR [rax],al
    24cd:	add    BYTE PTR [rax],al
	...

00000000000024d0 <botlish_entry_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    24d0:	push   rbp
    24d1:	mov    rbp,rsp
    24d4:	mov    rsi,QWORD PTR [rdx]
    24d7:	mov    r10,QWORD PTR [rdx+0x8]
    24db:	mov    rcx,QWORD PTR [rdx+0x10]
    24df:	mov    r8,QWORD PTR [rdx+0x18]
    24e3:	mov    r9,QWORD PTR [rdx+0x20]
    24e7:	mov    rdx,r10
    24ea:	call   24ef <botlish_entry_18+0x1f>
			24eb: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    24ef:	mov    rsp,rbp
    24f2:	pop    rbp
    24f3:	ret

00000000000024f4 <botlish_fn_19: csv_parse<str>>:
    24f4:	push   rbp
    24f5:	mov    rbp,rsp
    24f8:	sub    rsp,0x50
    24fc:	mov    QWORD PTR [rsp+0x40],r12
    2501:	mov    QWORD PTR [rsp+0x48],r13
    2506:	mov    r13,rdi
    2509:	mov    QWORD PTR [rsp+0x10],0x0
    2512:	mov    QWORD PTR [rsp+0x18],0x0
    251b:	mov    QWORD PTR [rsp+0x20],0x0
    2524:	mov    QWORD PTR [rsp],rsi
    2528:	mov    r12,rsi
    252b:	mov    QWORD PTR [rsp+0x8],0x1
    2534:	lea    rsi,[rsp+0x28]
    2539:	mov    rdi,r13
    253c:	call   2541 <botlish_fn_19+0x4d>
			253d: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2541:	test   rax,rax
    2544:	je     257f <botlish_fn_19+0x8b>
    254a:	mov    QWORD PTR [rsp+0x10],rax
    254f:	mov    rcx,rax
    2552:	mov    r8,QWORD PTR [rsp+0x28]
    2557:	mov    QWORD PTR [rsp+0x18],r8
    255c:	mov    r9,QWORD PTR [rsp+0x30]
    2561:	mov    QWORD PTR [rsp+0x20],r9
    2566:	mov    edx,0x1
    256b:	mov    rsi,r12
    256e:	mov    rdi,r13
    2571:	call   2576 <botlish_fn_19+0x82>
			2572: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    2576:	test   rax,rax
    2579:	jne    2595 <botlish_fn_19+0xa1>
    257f:	xor    rax,rax
    2582:	mov    r12,QWORD PTR [rsp+0x40]
    2587:	mov    r13,QWORD PTR [rsp+0x48]
    258c:	add    rsp,0x50
    2590:	mov    rsp,rbp
    2593:	pop    rbp
    2594:	ret
    2595:	mov    r12,QWORD PTR [rsp+0x40]
    259a:	mov    r13,QWORD PTR [rsp+0x48]
    259f:	add    rsp,0x50
    25a3:	mov    rsp,rbp
    25a6:	pop    rbp
    25a7:	ret

00000000000025a8 <botlish_entry_19: csv_parse<str>>:
    25a8:	push   rbp
    25a9:	mov    rbp,rsp
    25ac:	mov    rsi,QWORD PTR [rdx]
    25af:	call   25b4 <botlish_entry_19+0xc>
			25b0: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    25b4:	mov    rsp,rbp
    25b7:	pop    rbp
    25b8:	ret

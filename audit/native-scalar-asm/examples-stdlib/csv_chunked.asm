; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10725  (per function: 68 195 534 534 534 534 498 418 540 540 365 430 664 1122 364 985 1034 549 620 197)
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
    12fa:	sub    rsp,0x90
    1301:	mov    QWORD PTR [rsp+0x60],rbx
    1306:	mov    QWORD PTR [rsp+0x68],r12
    130b:	mov    QWORD PTR [rsp+0x70],r13
    1310:	mov    QWORD PTR [rsp+0x78],r14
    1315:	mov    QWORD PTR [rsp+0x80],r15
    131d:	mov    r14,rdi
    1320:	mov    QWORD PTR [rsp+0x18],0x0
    1329:	mov    QWORD PTR [rsp],rsi
    132d:	mov    QWORD PTR [rsp+0x40],rsi
    1332:	mov    QWORD PTR [rsp+0x8],rdx
    1337:	mov    r15,rdx
    133a:	mov    QWORD PTR [rsp+0x10],rcx
    133f:	lea    r13,[rsp+0x20]
    1344:	mov    QWORD PTR [rsp+0x48],rcx
    1349:	mov    rcx,r13
    134c:	mov    rdx,QWORD PTR [rsp+0x48]
    1351:	mov    rsi,QWORD PTR [rsp+0x40]
    1356:	mov    rdi,r14
    1359:	call   135e <botlish_fn_12+0x68>
			135a: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    135e:	mov    r10,rax
    1361:	mov    QWORD PTR [rsp+0x50],rax
    1366:	test   rax,r10
    1369:	je     14cb <botlish_fn_12+0x1d5>
    136f:	mov    rbx,QWORD PTR [rsp+0x20]
    1374:	mov    r12,QWORD PTR [rsp+0x28]
    1379:	mov    rdi,r14
    137c:	mov    rcx,QWORD PTR [rdi+0x10]
    1380:	mov    r8,QWORD PTR [rcx+0x10]
    1384:	mov    rcx,r12
    1387:	mov    rdx,rbx
    138a:	mov    rsi,QWORD PTR [rsp+0x50]
    138f:	call   1394 <botlish_fn_12+0x9e>
			1390: R_X86_64_PLT32	rt_str_region_eq-0x4
    1394:	cmp    rax,0x6
    1398:	je     13d7 <botlish_fn_12+0xe1>
    139e:	mov    rdi,r14
    13a1:	mov    rax,QWORD PTR [rdi+0x10]
    13a5:	mov    r8,QWORD PTR [rax+0x18]
    13a9:	mov    rcx,r12
    13ac:	mov    rdx,rbx
    13af:	mov    rsi,QWORD PTR [rsp+0x50]
    13b4:	call   13b9 <botlish_fn_12+0xc3>
			13b5: R_X86_64_PLT32	rt_str_region_eq-0x4
    13b9:	cmp    rax,0x6
    13bd:	je     13cd <botlish_fn_12+0xd7>
    13c3:	mov    eax,0x2
    13c8:	jmp    13dc <botlish_fn_12+0xe6>
    13cd:	mov    eax,0x6
    13d2:	jmp    13dc <botlish_fn_12+0xe6>
    13d7:	mov    eax,0x6
    13dc:	cmp    rax,0x6
    13e0:	je     141f <botlish_fn_12+0x129>
    13e6:	mov    rdi,r14
    13e9:	mov    rax,QWORD PTR [rdi+0x10]
    13ed:	mov    r8,QWORD PTR [rax+0x20]
    13f1:	mov    rcx,r12
    13f4:	mov    rdx,rbx
    13f7:	mov    rsi,QWORD PTR [rsp+0x50]
    13fc:	call   1401 <botlish_fn_12+0x10b>
			13fd: R_X86_64_PLT32	rt_str_region_eq-0x4
    1401:	cmp    rax,0x6
    1405:	je     1415 <botlish_fn_12+0x11f>
    140b:	mov    eax,0x2
    1410:	jmp    1424 <botlish_fn_12+0x12e>
    1415:	mov    eax,0x6
    141a:	jmp    1424 <botlish_fn_12+0x12e>
    141f:	mov    eax,0x6
    1424:	cmp    rax,0x6
    1428:	je     14ad <botlish_fn_12+0x1b7>
    142e:	mov    QWORD PTR [rsp+0x18],0x3
    1437:	mov    rsi,QWORD PTR [rsp+0x48]
    143c:	test   rsi,0x1
    1443:	je     1471 <botlish_fn_12+0x17b>
    1449:	mov    rsi,QWORD PTR [rsp+0x48]
    144e:	mov    rdi,rsi
    1451:	add    rdi,0x2
    1455:	seto   r9b
    1459:	test   r9b,r9b
    145c:	jne    1471 <botlish_fn_12+0x17b>
    1462:	mov    rsi,QWORD PTR [rsp+0x40]
    1467:	mov    QWORD PTR [rsp+0x48],rdi
    146c:	jmp    148d <botlish_fn_12+0x197>
    1471:	mov    edx,0x3
    1476:	mov    rsi,QWORD PTR [rsp+0x48]
    147b:	mov    rdi,r14
    147e:	call   1483 <botlish_fn_12+0x18d>
			147f: R_X86_64_PLT32	rt_int_add-0x4
    1483:	mov    rsi,QWORD PTR [rsp+0x40]
    1488:	mov    QWORD PTR [rsp+0x48],rax
    148d:	mov    QWORD PTR [rsp],rsi
    1491:	mov    rdx,r15
    1494:	mov    QWORD PTR [rsp+0x8],rdx
    1499:	mov    rax,QWORD PTR [rsp+0x48]
    149e:	mov    QWORD PTR [rsp+0x10],rax
    14a3:	mov    QWORD PTR [rsp+0x40],rsi
    14a8:	jmp    1349 <botlish_fn_12+0x53>
    14ad:	mov    rdx,r15
    14b0:	mov    rsi,QWORD PTR [rsp+0x40]
    14b5:	mov    rcx,QWORD PTR [rsp+0x48]
    14ba:	mov    rdi,r14
    14bd:	call   14c2 <botlish_fn_12+0x1cc>
			14be: R_X86_64_PLT32	rt_substr-0x4
    14c2:	test   rax,rax
    14c5:	jne    14f6 <botlish_fn_12+0x200>
    14cb:	xor    rax,rax
    14ce:	mov    rbx,QWORD PTR [rsp+0x60]
    14d3:	mov    r12,QWORD PTR [rsp+0x68]
    14d8:	mov    r13,QWORD PTR [rsp+0x70]
    14dd:	mov    r14,QWORD PTR [rsp+0x78]
    14e2:	mov    r15,QWORD PTR [rsp+0x80]
    14ea:	add    rsp,0x90
    14f1:	mov    rsp,rbp
    14f4:	pop    rbp
    14f5:	ret
    14f6:	mov    QWORD PTR [rsp],rax
    14fa:	lea    rcx,[rsp+0x30]
    14ff:	mov    QWORD PTR [rsp+0x30],rax
    1504:	mov    rsi,QWORD PTR [rsp+0x48]
    1509:	mov    QWORD PTR [rsp+0x38],rsi
    150e:	mov    esi,0x1
    1513:	mov    edx,0x2
    1518:	mov    rdi,r14
    151b:	call   1520 <botlish_fn_12+0x22a>
			151c: R_X86_64_PLT32	rt_struct_new-0x4
    1520:	mov    rbx,QWORD PTR [rsp+0x60]
    1525:	mov    r12,QWORD PTR [rsp+0x68]
    152a:	mov    r13,QWORD PTR [rsp+0x70]
    152f:	mov    r14,QWORD PTR [rsp+0x78]
    1534:	mov    r15,QWORD PTR [rsp+0x80]
    153c:	add    rsp,0x90
    1543:	mov    rsp,rbp
    1546:	pop    rbp
    1547:	ret

0000000000001548 <botlish_entry_12: scan_unquoted<str, int, int>>:
    1548:	push   rbp
    1549:	mov    rbp,rsp
    154c:	mov    rsi,QWORD PTR [rdx]
    154f:	mov    r8,QWORD PTR [rdx+0x8]
    1553:	mov    rcx,QWORD PTR [rdx+0x10]
    1557:	mov    rdx,r8
    155a:	call   155f <botlish_entry_12+0x17>
			155b: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_unquoted<str, int, int>
    155f:	mov    rsp,rbp
    1562:	pop    rbp
    1563:	ret

0000000000001564 <botlish_fn_13: scan_quoted<str, int, str>>:
    1564:	push   rbp
    1565:	mov    rbp,rsp
    1568:	sub    rsp,0xe0
    156f:	mov    QWORD PTR [rsp+0xb0],rbx
    1577:	mov    QWORD PTR [rsp+0xb8],r12
    157f:	mov    QWORD PTR [rsp+0xc0],r13
    1587:	mov    QWORD PTR [rsp+0xc8],r14
    158f:	mov    QWORD PTR [rsp+0xd0],r15
    1597:	mov    r14,rdi
    159a:	mov    QWORD PTR [rsp+0x18],0x0
    15a3:	mov    QWORD PTR [rsp+0x20],0x0
    15ac:	mov    QWORD PTR [rsp],rsi
    15b0:	mov    QWORD PTR [rsp+0x8],rdx
    15b5:	mov    QWORD PTR [rsp+0x10],rcx
    15ba:	mov    r12,rcx
    15bd:	lea    r13,[rsp+0x78]
    15c2:	lea    rbx,[rsp+0x28]
    15c7:	mov    r15,rsi
    15ca:	mov    QWORD PTR [rsp+0x98],rdx
    15d2:	mov    rdx,QWORD PTR [rsp+0x98]
    15da:	mov    rsi,r15
    15dd:	mov    rdi,r14
    15e0:	call   15e5 <botlish_fn_13+0x81>
			15e1: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    15e5:	test   rax,rax
    15e8:	je     190a <botlish_fn_13+0x3a6>
    15ee:	mov    QWORD PTR [rsp+0x18],rax
    15f3:	mov    rdi,r14
    15f6:	mov    QWORD PTR [rsp+0xa0],rax
    15fe:	mov    rdi,QWORD PTR [rdi+0x10]
    1602:	mov    rsi,QWORD PTR [rdi+0x28]
    1606:	mov    edx,0x1
    160b:	mov    ecx,0x3
    1610:	mov    rdi,r14
    1613:	mov    r8,QWORD PTR [rsp+0xa0]
    161b:	call   1620 <botlish_fn_13+0xbc>
			161c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1620:	cmp    rax,0x6
    1624:	je     16e8 <botlish_fn_13+0x184>
    162a:	mov    QWORD PTR [rsp+0x20],0x3
    1633:	mov    rsi,QWORD PTR [rsp+0x98]
    163b:	test   rsi,0x1
    1642:	je     1662 <botlish_fn_13+0xfe>
    1648:	mov    rcx,rsi
    164b:	add    rcx,0x2
    164f:	seto   al
    1652:	test   al,al
    1654:	jne    1662 <botlish_fn_13+0xfe>
    165a:	mov    rsi,rcx
    165d:	jmp    1672 <botlish_fn_13+0x10e>
    1662:	mov    edx,0x3
    1667:	mov    rdi,r14
    166a:	call   166f <botlish_fn_13+0x10b>
			166b: R_X86_64_PLT32	rt_int_add-0x4
    166f:	mov    rsi,rax
    1672:	mov    QWORD PTR [rsp+0x8],rsi
    1677:	mov    QWORD PTR [rsp+0x98],rsi
    167f:	mov    QWORD PTR [rsp+0x78],0x0
    1688:	mov    QWORD PTR [rsp+0x80],r12
    1690:	mov    QWORD PTR [rsp+0x88],0x0
    169c:	mov    rax,QWORD PTR [rsp+0xa0]
    16a4:	mov    QWORD PTR [rsp+0x90],rax
    16ac:	mov    esi,0x2
    16b1:	mov    edx,0x4
    16b6:	mov    rcx,r13
    16b9:	mov    rdi,r14
    16bc:	call   16c1 <botlish_fn_13+0x15d>
			16bd: R_X86_64_PLT32	rt_construct-0x4
    16c1:	test   rax,rax
    16c4:	je     190a <botlish_fn_13+0x3a6>
    16ca:	mov    QWORD PTR [rsp],r15
    16ce:	mov    rsi,QWORD PTR [rsp+0x98]
    16d6:	mov    QWORD PTR [rsp+0x8],rsi
    16db:	mov    QWORD PTR [rsp+0x10],rax
    16e0:	mov    r12,rax
    16e3:	jmp    15d2 <botlish_fn_13+0x6e>
    16e8:	mov    QWORD PTR [rsp+0x18],0x3
    16f1:	mov    rsi,QWORD PTR [rsp+0x98]
    16f9:	test   rsi,0x1
    1700:	je     1720 <botlish_fn_13+0x1bc>
    1706:	mov    rsi,QWORD PTR [rsp+0x98]
    170e:	mov    rdx,rsi
    1711:	add    rdx,0x2
    1715:	seto   al
    1718:	test   al,al
    171a:	je     1738 <botlish_fn_13+0x1d4>
    1720:	mov    edx,0x3
    1725:	mov    rsi,QWORD PTR [rsp+0x98]
    172d:	mov    rdi,r14
    1730:	call   1735 <botlish_fn_13+0x1d1>
			1731: R_X86_64_PLT32	rt_int_add-0x4
    1735:	mov    rdx,rax
    1738:	mov    QWORD PTR [rsp+0x18],rdx
    173d:	mov    rcx,rbx
    1740:	mov    rsi,r15
    1743:	mov    rdi,r14
    1746:	call   174b <botlish_fn_13+0x1e7>
			1747: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    174b:	test   rax,rax
    174e:	mov    rsi,rax
    1751:	je     190a <botlish_fn_13+0x3a6>
    1757:	mov    rdx,QWORD PTR [rsp+0x28]
    175c:	mov    rcx,QWORD PTR [rsp+0x30]
    1761:	mov    rdi,r14
    1764:	mov    rax,QWORD PTR [rdi+0x10]
    1768:	mov    r8,QWORD PTR [rax+0x28]
    176c:	call   1771 <botlish_fn_13+0x20d>
			176d: R_X86_64_PLT32	rt_str_region_eq-0x4
    1771:	cmp    rax,0x6
    1775:	je     1858 <botlish_fn_13+0x2f4>
    177b:	xor    rsi,rsi
    177e:	lea    rcx,[rsp+0x58]
    1783:	mov    QWORD PTR [rsp+0x58],0x0
    178c:	mov    QWORD PTR [rsp+0x60],r12
    1791:	mov    edx,0x2
    1796:	mov    rdi,r14
    1799:	call   179e <botlish_fn_13+0x23a>
			179a: R_X86_64_PLT32	rt_construct-0x4
    179e:	test   rax,rax
    17a1:	je     190a <botlish_fn_13+0x3a6>
    17a7:	mov    QWORD PTR [rsp],rax
    17ab:	mov    rbx,rax
    17ae:	mov    QWORD PTR [rsp+0x10],0x3
    17b7:	mov    rsi,QWORD PTR [rsp+0x98]
    17bf:	test   rsi,0x1
    17c6:	je     17e6 <botlish_fn_13+0x282>
    17cc:	mov    rsi,QWORD PTR [rsp+0x98]
    17d4:	mov    rax,rsi
    17d7:	add    rax,0x2
    17db:	seto   cl
    17de:	test   cl,cl
    17e0:	je     17fb <botlish_fn_13+0x297>
    17e6:	mov    edx,0x3
    17eb:	mov    rsi,QWORD PTR [rsp+0x98]
    17f3:	mov    rdi,r14
    17f6:	call   17fb <botlish_fn_13+0x297>
			17f7: R_X86_64_PLT32	rt_int_add-0x4
    17fb:	mov    QWORD PTR [rsp+0x8],rax
    1800:	lea    rcx,[rsp+0x68]
    1805:	mov    rdx,rbx
    1808:	mov    QWORD PTR [rsp+0x68],rdx
    180d:	mov    QWORD PTR [rsp+0x70],rax
    1812:	mov    esi,0x1
    1817:	mov    edx,0x2
    181c:	mov    rdi,r14
    181f:	call   1824 <botlish_fn_13+0x2c0>
			1820: R_X86_64_PLT32	rt_struct_new-0x4
    1824:	mov    rbx,QWORD PTR [rsp+0xb0]
    182c:	mov    r12,QWORD PTR [rsp+0xb8]
    1834:	mov    r13,QWORD PTR [rsp+0xc0]
    183c:	mov    r14,QWORD PTR [rsp+0xc8]
    1844:	mov    r15,QWORD PTR [rsp+0xd0]
    184c:	add    rsp,0xe0
    1853:	mov    rsp,rbp
    1856:	pop    rbp
    1857:	ret
    1858:	mov    QWORD PTR [rsp+0x18],0x5
    1861:	mov    rsi,QWORD PTR [rsp+0x98]
    1869:	test   rsi,0x1
    1870:	je     189c <botlish_fn_13+0x338>
    1876:	mov    rsi,QWORD PTR [rsp+0x98]
    187e:	add    rsi,0x4
    1882:	seto   r8b
    1886:	test   r8b,r8b
    1889:	jne    189c <botlish_fn_13+0x338>
    188f:	mov    QWORD PTR [rsp+0x98],rsi
    1897:	jmp    18bc <botlish_fn_13+0x358>
    189c:	mov    edx,0x5
    18a1:	mov    rsi,QWORD PTR [rsp+0x98]
    18a9:	mov    rdi,r14
    18ac:	call   18b1 <botlish_fn_13+0x34d>
			18ad: R_X86_64_PLT32	rt_int_add-0x4
    18b1:	mov    rsi,rax
    18b4:	mov    QWORD PTR [rsp+0x98],rax
    18bc:	mov    QWORD PTR [rsp+0x8],rsi
    18c1:	mov    rdi,r14
    18c4:	mov    rax,QWORD PTR [rdi+0x10]
    18c8:	mov    rax,QWORD PTR [rax+0x28]
    18cc:	mov    QWORD PTR [rsp+0x18],rax
    18d1:	lea    rcx,[rsp+0x38]
    18d6:	mov    QWORD PTR [rsp+0x38],0x0
    18df:	mov    QWORD PTR [rsp+0x40],r12
    18e4:	mov    QWORD PTR [rsp+0x48],0x0
    18ed:	mov    QWORD PTR [rsp+0x50],rax
    18f2:	mov    esi,0x2
    18f7:	mov    edx,0x4
    18fc:	call   1901 <botlish_fn_13+0x39d>
			18fd: R_X86_64_PLT32	rt_construct-0x4
    1901:	test   rax,rax
    1904:	jne    1941 <botlish_fn_13+0x3dd>
    190a:	xor    rax,rax
    190d:	mov    rbx,QWORD PTR [rsp+0xb0]
    1915:	mov    r12,QWORD PTR [rsp+0xb8]
    191d:	mov    r13,QWORD PTR [rsp+0xc0]
    1925:	mov    r14,QWORD PTR [rsp+0xc8]
    192d:	mov    r15,QWORD PTR [rsp+0xd0]
    1935:	add    rsp,0xe0
    193c:	mov    rsp,rbp
    193f:	pop    rbp
    1940:	ret
    1941:	mov    QWORD PTR [rsp],r15
    1945:	mov    rsi,QWORD PTR [rsp+0x98]
    194d:	mov    QWORD PTR [rsp+0x8],rsi
    1952:	mov    QWORD PTR [rsp+0x10],rax
    1957:	mov    r12,rax
    195a:	jmp    15d2 <botlish_fn_13+0x6e>

000000000000195f <botlish_entry_13: scan_quoted<str, int, str>>:
    195f:	push   rbp
    1960:	mov    rbp,rsp
    1963:	mov    rsi,QWORD PTR [rdx]
    1966:	mov    r8,QWORD PTR [rdx+0x8]
    196a:	mov    rcx,QWORD PTR [rdx+0x10]
    196e:	mov    rdx,r8
    1971:	call   1976 <botlish_entry_13+0x17>
			1972: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_quoted<str, int, str>
    1976:	mov    rsp,rbp
    1979:	pop    rbp
    197a:	ret

000000000000197b <botlish_fn_14: scan_field<str, int>>:
    197b:	push   rbp
    197c:	mov    rbp,rsp
    197f:	sub    rsp,0x50
    1983:	mov    QWORD PTR [rsp+0x30],rbx
    1988:	mov    QWORD PTR [rsp+0x38],r12
    198d:	mov    QWORD PTR [rsp+0x40],r13
    1992:	mov    r12,rdi
    1995:	mov    r13,rdx
    1998:	mov    QWORD PTR [rsp+0x10],0x0
    19a1:	mov    QWORD PTR [rsp],rsi
    19a5:	mov    rbx,rsi
    19a8:	mov    QWORD PTR [rsp+0x8],rdx
    19ad:	lea    rcx,[rsp+0x18]
    19b2:	mov    rdx,r13
    19b5:	mov    rsi,rbx
    19b8:	mov    rdi,r12
    19bb:	call   19c0 <botlish_fn_14+0x45>
			19bc: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    19c0:	test   rax,rax
    19c3:	mov    rsi,rax
    19c6:	je     1a91 <botlish_fn_14+0x116>
    19cc:	mov    rdx,QWORD PTR [rsp+0x18]
    19d1:	mov    rcx,QWORD PTR [rsp+0x20]
    19d6:	mov    rdi,r12
    19d9:	mov    rax,QWORD PTR [rdi+0x10]
    19dd:	mov    r8,QWORD PTR [rax+0x28]
    19e1:	call   19e6 <botlish_fn_14+0x6b>
			19e2: R_X86_64_PLT32	rt_str_region_eq-0x4
    19e6:	cmp    rax,0x6
    19ea:	je     1a22 <botlish_fn_14+0xa7>
    19f0:	mov    rcx,r13
    19f3:	mov    rsi,rbx
    19f6:	mov    rdi,r12
    19f9:	mov    rdx,rcx
    19fc:	call   1a01 <botlish_fn_14+0x86>
			19fd: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_unquoted<str, int, int>
    1a01:	test   rax,rax
    1a04:	je     1a91 <botlish_fn_14+0x116>
    1a0a:	mov    rbx,QWORD PTR [rsp+0x30]
    1a0f:	mov    r12,QWORD PTR [rsp+0x38]
    1a14:	mov    r13,QWORD PTR [rsp+0x40]
    1a19:	add    rsp,0x50
    1a1d:	mov    rsp,rbp
    1a20:	pop    rbp
    1a21:	ret
    1a22:	mov    rcx,r13
    1a25:	mov    QWORD PTR [rsp+0x10],0x3
    1a2e:	test   rcx,0x1
    1a35:	jne    1a43 <botlish_fn_14+0xc8>
    1a3b:	mov    r13,rcx
    1a3e:	jmp    1a58 <botlish_fn_14+0xdd>
    1a43:	mov    rdx,rcx
    1a46:	add    rdx,0x2
    1a4a:	mov    r13,rcx
    1a4d:	seto   al
    1a50:	test   al,al
    1a52:	je     1a6b <botlish_fn_14+0xf0>
    1a58:	mov    edx,0x3
    1a5d:	mov    rsi,r13
    1a60:	mov    rdi,r12
    1a63:	call   1a68 <botlish_fn_14+0xed>
			1a64: R_X86_64_PLT32	rt_int_add-0x4
    1a68:	mov    rdx,rax
    1a6b:	mov    QWORD PTR [rsp+0x8],rdx
    1a70:	mov    rdi,r12
    1a73:	mov    rax,QWORD PTR [rdi+0x10]
    1a77:	mov    rcx,QWORD PTR [rax+0x10]
    1a7b:	mov    QWORD PTR [rsp+0x10],rcx
    1a80:	mov    rsi,rbx
    1a83:	call   1a88 <botlish_fn_14+0x10d>
			1a84: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_quoted<str, int, str>
    1a88:	test   rax,rax
    1a8b:	jne    1aac <botlish_fn_14+0x131>
    1a91:	xor    rax,rax
    1a94:	mov    rbx,QWORD PTR [rsp+0x30]
    1a99:	mov    r12,QWORD PTR [rsp+0x38]
    1a9e:	mov    r13,QWORD PTR [rsp+0x40]
    1aa3:	add    rsp,0x50
    1aa7:	mov    rsp,rbp
    1aaa:	pop    rbp
    1aab:	ret
    1aac:	mov    rbx,QWORD PTR [rsp+0x30]
    1ab1:	mov    r12,QWORD PTR [rsp+0x38]
    1ab6:	mov    r13,QWORD PTR [rsp+0x40]
    1abb:	add    rsp,0x50
    1abf:	mov    rsp,rbp
    1ac2:	pop    rbp
    1ac3:	ret

0000000000001ac4 <botlish_entry_14: scan_field<str, int>>:
    1ac4:	push   rbp
    1ac5:	mov    rbp,rsp
    1ac8:	mov    rsi,QWORD PTR [rdx]
    1acb:	mov    rdx,QWORD PTR [rdx+0x8]
    1acf:	call   1ad4 <botlish_entry_14+0x10>
			1ad0: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1ad4:	mov    rsp,rbp
    1ad7:	pop    rbp
    1ad8:	ret

0000000000001ad9 <botlish_fn_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1ad9:	push   rbp
    1ada:	mov    rbp,rsp
    1add:	sub    rsp,0xc0
    1ae4:	mov    QWORD PTR [rsp+0x90],rbx
    1aec:	mov    QWORD PTR [rsp+0x98],r12
    1af4:	mov    QWORD PTR [rsp+0xa0],r13
    1afc:	mov    QWORD PTR [rsp+0xa8],r14
    1b04:	mov    QWORD PTR [rsp+0xb0],r15
    1b0c:	mov    rbx,rdi
    1b0f:	mov    QWORD PTR [rsp+0x28],0x0
    1b18:	mov    QWORD PTR [rsp],rsi
    1b1c:	mov    r14,rsi
    1b1f:	mov    QWORD PTR [rsp+0x8],rdx
    1b24:	mov    QWORD PTR [rsp+0x10],rcx
    1b29:	mov    r15,rcx
    1b2c:	mov    QWORD PTR [rsp+0x18],r8
    1b31:	mov    r13,r8
    1b34:	mov    QWORD PTR [rsp+0x20],r9
    1b39:	mov    r12,r9
    1b3c:	mov    rsi,r14
    1b3f:	mov    rdi,rbx
    1b42:	call   1b47 <botlish_fn_15+0x6e>
			1b43: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1b47:	test   rax,rax
    1b4a:	je     1e03 <botlish_fn_15+0x32a>
    1b50:	mov    QWORD PTR [rsp+0x8],rax
    1b55:	mov    rcx,QWORD PTR [rax+0x18]
    1b59:	mov    QWORD PTR [rsp+0x70],rax
    1b5e:	mov    r8,QWORD PTR [rcx]
    1b61:	mov    QWORD PTR [rsp+0x28],r8
    1b66:	lea    r9,[rsp+0x30]
    1b6b:	mov    rcx,r12
    1b6e:	mov    rdx,r13
    1b71:	mov    rsi,r15
    1b74:	mov    rdi,rbx
    1b77:	call   1b7c <botlish_fn_15+0xa3>
			1b78: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<list[List[never], mutarray, int], str>
    1b7c:	test   rax,rax
    1b7f:	je     1e03 <botlish_fn_15+0x32a>
    1b85:	mov    QWORD PTR [rsp+0x8],rax
    1b8a:	mov    QWORD PTR [rsp+0x88],rax
    1b92:	mov    rdx,QWORD PTR [rsp+0x30]
    1b97:	mov    QWORD PTR [rsp+0x10],rdx
    1b9c:	mov    QWORD PTR [rsp+0x80],rdx
    1ba4:	mov    rcx,QWORD PTR [rsp+0x38]
    1ba9:	mov    QWORD PTR [rsp+0x18],rcx
    1bae:	mov    rax,QWORD PTR [rsp+0x70]
    1bb3:	mov    QWORD PTR [rsp+0x78],rcx
    1bb8:	mov    rsi,QWORD PTR [rax+0x18]
    1bbc:	mov    rsi,QWORD PTR [rsi+0x8]
    1bc0:	mov    QWORD PTR [rsp+0x20],rsi
    1bc5:	mov    r15,rsi
    1bc8:	lea    rcx,[rsp+0x40]
    1bcd:	mov    rdx,r15
    1bd0:	mov    rsi,r14
    1bd3:	mov    rdi,rbx
    1bd6:	call   1bdb <botlish_fn_15+0x102>
			1bd7: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1bdb:	test   rax,rax
    1bde:	mov    QWORD PTR [rsp+0x70],rax
    1be3:	je     1e03 <botlish_fn_15+0x32a>
    1be9:	mov    r13,QWORD PTR [rsp+0x40]
    1bee:	mov    r12,QWORD PTR [rsp+0x48]
    1bf3:	mov    rdi,rbx
    1bf6:	mov    r9,QWORD PTR [rdi+0x10]
    1bfa:	mov    r8,QWORD PTR [r9+0x18]
    1bfe:	mov    rcx,r12
    1c01:	mov    rdx,r13
    1c04:	mov    rsi,QWORD PTR [rsp+0x70]
    1c09:	call   1c0e <botlish_fn_15+0x135>
			1c0a: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c0e:	cmp    rax,0x6
    1c12:	je     1d83 <botlish_fn_15+0x2aa>
    1c18:	mov    rdi,rbx
    1c1b:	mov    rax,QWORD PTR [rdi+0x10]
    1c1f:	mov    r8,QWORD PTR [rax+0x20]
    1c23:	mov    rcx,r12
    1c26:	mov    rdx,r13
    1c29:	mov    rsi,QWORD PTR [rsp+0x70]
    1c2e:	call   1c33 <botlish_fn_15+0x15a>
			1c2f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c33:	cmp    rax,0x6
    1c37:	je     1cbd <botlish_fn_15+0x1e4>
    1c3d:	mov    rcx,QWORD PTR [rsp+0x78]
    1c42:	mov    rdx,QWORD PTR [rsp+0x80]
    1c4a:	mov    rsi,QWORD PTR [rsp+0x88]
    1c52:	mov    rdi,rbx
    1c55:	call   1c5a <botlish_fn_15+0x181>
			1c56: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1c5a:	test   rax,rax
    1c5d:	je     1e03 <botlish_fn_15+0x32a>
    1c63:	mov    QWORD PTR [rsp],rax
    1c67:	lea    rcx,[rsp+0x60]
    1c6c:	mov    QWORD PTR [rsp+0x60],rax
    1c71:	mov    rsi,r15
    1c74:	mov    QWORD PTR [rsp+0x68],rsi
    1c79:	xor    rsi,rsi
    1c7c:	mov    edx,0x2
    1c81:	mov    rdi,rbx
    1c84:	call   1c89 <botlish_fn_15+0x1b0>
			1c85: R_X86_64_PLT32	rt_struct_new-0x4
    1c89:	mov    rbx,QWORD PTR [rsp+0x90]
    1c91:	mov    r12,QWORD PTR [rsp+0x98]
    1c99:	mov    r13,QWORD PTR [rsp+0xa0]
    1ca1:	mov    r14,QWORD PTR [rsp+0xa8]
    1ca9:	mov    r15,QWORD PTR [rsp+0xb0]
    1cb1:	add    rsp,0xc0
    1cb8:	mov    rsp,rbp
    1cbb:	pop    rbp
    1cbc:	ret
    1cbd:	mov    rcx,QWORD PTR [rsp+0x78]
    1cc2:	mov    rdx,QWORD PTR [rsp+0x80]
    1cca:	mov    rsi,QWORD PTR [rsp+0x88]
    1cd2:	mov    rdi,rbx
    1cd5:	call   1cda <botlish_fn_15+0x201>
			1cd6: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1cda:	test   rax,rax
    1cdd:	je     1e03 <botlish_fn_15+0x32a>
    1ce3:	mov    QWORD PTR [rsp],rax
    1ce7:	mov    r12,rax
    1cea:	mov    QWORD PTR [rsp+0x8],0x3
    1cf3:	mov    rsi,r15
    1cf6:	test   rsi,0x1
    1cfd:	je     1d18 <botlish_fn_15+0x23f>
    1d03:	mov    rsi,r15
    1d06:	mov    rax,rsi
    1d09:	add    rax,0x2
    1d0d:	seto   cl
    1d10:	test   cl,cl
    1d12:	je     1d28 <botlish_fn_15+0x24f>
    1d18:	mov    edx,0x3
    1d1d:	mov    rsi,r15
    1d20:	mov    rdi,rbx
    1d23:	call   1d28 <botlish_fn_15+0x24f>
			1d24: R_X86_64_PLT32	rt_int_add-0x4
    1d28:	mov    QWORD PTR [rsp+0x8],rax
    1d2d:	lea    rcx,[rsp+0x50]
    1d32:	mov    rdx,r12
    1d35:	mov    QWORD PTR [rsp+0x50],rdx
    1d3a:	mov    QWORD PTR [rsp+0x58],rax
    1d3f:	xor    rsi,rsi
    1d42:	mov    edx,0x2
    1d47:	mov    rdi,rbx
    1d4a:	call   1d4f <botlish_fn_15+0x276>
			1d4b: R_X86_64_PLT32	rt_struct_new-0x4
    1d4f:	mov    rbx,QWORD PTR [rsp+0x90]
    1d57:	mov    r12,QWORD PTR [rsp+0x98]
    1d5f:	mov    r13,QWORD PTR [rsp+0xa0]
    1d67:	mov    r14,QWORD PTR [rsp+0xa8]
    1d6f:	mov    r15,QWORD PTR [rsp+0xb0]
    1d77:	add    rsp,0xc0
    1d7e:	mov    rsp,rbp
    1d81:	pop    rbp
    1d82:	ret
    1d83:	mov    edx,0x3
    1d88:	mov    rcx,rdx
    1d8b:	mov    QWORD PTR [rsp+0x28],0x3
    1d94:	mov    rsi,r15
    1d97:	test   rsi,0x1
    1d9e:	jne    1daf <botlish_fn_15+0x2d6>
    1da4:	mov    rdx,rcx
    1da7:	mov    rsi,r15
    1daa:	jmp    1dca <botlish_fn_15+0x2f1>
    1daf:	mov    rsi,r15
    1db2:	mov    rdx,rsi
    1db5:	add    rdx,0x2
    1db9:	seto   al
    1dbc:	test   al,al
    1dbe:	je     1dd5 <botlish_fn_15+0x2fc>
    1dc4:	mov    rdx,rcx
    1dc7:	mov    rsi,r15
    1dca:	mov    rdi,rbx
    1dcd:	call   1dd2 <botlish_fn_15+0x2f9>
			1dce: R_X86_64_PLT32	rt_int_add-0x4
    1dd2:	mov    rdx,rax
    1dd5:	mov    QWORD PTR [rsp+0x20],rdx
    1dda:	mov    rcx,QWORD PTR [rsp+0x88]
    1de2:	mov    rsi,r14
    1de5:	mov    rdi,rbx
    1de8:	mov    r8,QWORD PTR [rsp+0x80]
    1df0:	mov    r9,QWORD PTR [rsp+0x78]
    1df5:	call   1dfa <botlish_fn_15+0x321>
			1df6: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[List[mutarray], mutarray, int]>
    1dfa:	test   rax,rax
    1dfd:	jne    1e3a <botlish_fn_15+0x361>
    1e03:	xor    rax,rax
    1e06:	mov    rbx,QWORD PTR [rsp+0x90]
    1e0e:	mov    r12,QWORD PTR [rsp+0x98]
    1e16:	mov    r13,QWORD PTR [rsp+0xa0]
    1e1e:	mov    r14,QWORD PTR [rsp+0xa8]
    1e26:	mov    r15,QWORD PTR [rsp+0xb0]
    1e2e:	add    rsp,0xc0
    1e35:	mov    rsp,rbp
    1e38:	pop    rbp
    1e39:	ret
    1e3a:	mov    rbx,QWORD PTR [rsp+0x90]
    1e42:	mov    r12,QWORD PTR [rsp+0x98]
    1e4a:	mov    r13,QWORD PTR [rsp+0xa0]
    1e52:	mov    r14,QWORD PTR [rsp+0xa8]
    1e5a:	mov    r15,QWORD PTR [rsp+0xb0]
    1e62:	add    rsp,0xc0
    1e69:	mov    rsp,rbp
    1e6c:	pop    rbp
    1e6d:	ret

0000000000001e6e <botlish_entry_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1e6e:	push   rbp
    1e6f:	mov    rbp,rsp
    1e72:	mov    rsi,QWORD PTR [rdx]
    1e75:	mov    r10,QWORD PTR [rdx+0x8]
    1e79:	mov    rcx,QWORD PTR [rdx+0x10]
    1e7d:	mov    r8,QWORD PTR [rdx+0x18]
    1e81:	mov    r9,QWORD PTR [rdx+0x20]
    1e85:	mov    rdx,r10
    1e88:	call   1e8d <botlish_entry_15+0x1f>
			1e89: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    1e8d:	mov    rsp,rbp
    1e90:	pop    rbp
    1e91:	ret

0000000000001e92 <botlish_fn_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    1e92:	push   rbp
    1e93:	mov    rbp,rsp
    1e96:	sub    rsp,0xd0
    1e9d:	mov    QWORD PTR [rsp+0xa0],rbx
    1ea5:	mov    QWORD PTR [rsp+0xa8],r12
    1ead:	mov    QWORD PTR [rsp+0xb0],r13
    1eb5:	mov    QWORD PTR [rsp+0xb8],r14
    1ebd:	mov    QWORD PTR [rsp+0xc0],r15
    1ec5:	mov    QWORD PTR [rsp+0x70],rdi
    1eca:	mov    QWORD PTR [rsp+0x28],0x0
    1ed3:	mov    QWORD PTR [rsp],rsi
    1ed7:	mov    QWORD PTR [rsp+0x8],rdx
    1edc:	mov    QWORD PTR [rsp+0x10],rcx
    1ee1:	mov    QWORD PTR [rsp+0x18],r8
    1ee6:	mov    QWORD PTR [rsp+0x20],r9
    1eeb:	lea    r13,[rsp+0x30]
    1ef0:	lea    rbx,[rsp+0x40]
    1ef5:	mov    r12,rsi
    1ef8:	mov    r14,rcx
    1efb:	mov    QWORD PTR [rsp+0x78],r8
    1f00:	mov    QWORD PTR [rsp+0x80],r9
    1f08:	mov    rsi,r12
    1f0b:	mov    rdi,QWORD PTR [rsp+0x70]
    1f10:	call   1f15 <botlish_fn_16+0x83>
			1f11: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1f15:	test   rax,rax
    1f18:	je     20d6 <botlish_fn_16+0x244>
    1f1e:	mov    QWORD PTR [rsp+0x8],rax
    1f23:	mov    rcx,QWORD PTR [rax+0x18]
    1f27:	mov    r15,rax
    1f2a:	mov    r8,QWORD PTR [rcx]
    1f2d:	mov    QWORD PTR [rsp+0x28],r8
    1f32:	mov    rcx,QWORD PTR [rsp+0x80]
    1f3a:	mov    rdx,QWORD PTR [rsp+0x78]
    1f3f:	mov    rsi,r14
    1f42:	mov    rdi,QWORD PTR [rsp+0x70]
    1f47:	mov    r9,r13
    1f4a:	call   1f4f <botlish_fn_16+0xbd>
			1f4b: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[List[mutarray], mutarray, int], str>
    1f4f:	test   rax,rax
    1f52:	je     20d6 <botlish_fn_16+0x244>
    1f58:	mov    QWORD PTR [rsp+0x8],rax
    1f5d:	mov    QWORD PTR [rsp+0x98],rax
    1f65:	mov    rdx,QWORD PTR [rsp+0x30]
    1f6a:	mov    QWORD PTR [rsp+0x10],rdx
    1f6f:	mov    QWORD PTR [rsp+0x78],rdx
    1f74:	mov    rcx,QWORD PTR [rsp+0x38]
    1f79:	mov    QWORD PTR [rsp+0x18],rcx
    1f7e:	mov    rax,r15
    1f81:	mov    QWORD PTR [rsp+0x80],rcx
    1f89:	mov    r8,QWORD PTR [rax+0x18]
    1f8d:	mov    rsi,QWORD PTR [r8+0x8]
    1f91:	mov    QWORD PTR [rsp+0x20],rsi
    1f96:	mov    QWORD PTR [rsp+0x90],rsi
    1f9e:	mov    rcx,rbx
    1fa1:	mov    rdx,QWORD PTR [rsp+0x90]
    1fa9:	mov    rsi,r12
    1fac:	mov    rdi,QWORD PTR [rsp+0x70]
    1fb1:	call   1fb6 <botlish_fn_16+0x124>
			1fb2: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1fb6:	test   rax,rax
    1fb9:	mov    QWORD PTR [rsp+0x88],rax
    1fc1:	je     20d6 <botlish_fn_16+0x244>
    1fc7:	mov    r15,QWORD PTR [rsp+0x40]
    1fcc:	mov    r14,QWORD PTR [rsp+0x48]
    1fd1:	mov    rdi,QWORD PTR [rsp+0x70]
    1fd6:	mov    rcx,QWORD PTR [rdi+0x10]
    1fda:	mov    r8,QWORD PTR [rcx+0x18]
    1fde:	mov    rcx,r14
    1fe1:	mov    rdx,r15
    1fe4:	mov    rsi,QWORD PTR [rsp+0x88]
    1fec:	call   1ff1 <botlish_fn_16+0x15f>
			1fed: R_X86_64_PLT32	rt_str_region_eq-0x4
    1ff1:	cmp    rax,0x6
    1ff5:	je     21c0 <botlish_fn_16+0x32e>
    1ffb:	mov    rdi,QWORD PTR [rsp+0x70]
    2000:	mov    rax,QWORD PTR [rdi+0x10]
    2004:	mov    r8,QWORD PTR [rax+0x20]
    2008:	mov    rcx,r14
    200b:	mov    rdx,r15
    200e:	mov    rsi,QWORD PTR [rsp+0x88]
    2016:	call   201b <botlish_fn_16+0x189>
			2017: R_X86_64_PLT32	rt_str_region_eq-0x4
    201b:	cmp    rax,0x6
    201f:	je     20ae <botlish_fn_16+0x21c>
    2025:	mov    rcx,QWORD PTR [rsp+0x80]
    202d:	mov    rdx,QWORD PTR [rsp+0x78]
    2032:	mov    rsi,QWORD PTR [rsp+0x98]
    203a:	mov    rdi,QWORD PTR [rsp+0x70]
    203f:	call   2044 <botlish_fn_16+0x1b2>
			2040: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    2044:	test   rax,rax
    2047:	je     20d6 <botlish_fn_16+0x244>
    204d:	mov    QWORD PTR [rsp],rax
    2051:	lea    rcx,[rsp+0x60]
    2056:	mov    QWORD PTR [rsp+0x60],rax
    205b:	mov    rsi,QWORD PTR [rsp+0x90]
    2063:	mov    QWORD PTR [rsp+0x68],rsi
    2068:	xor    rsi,rsi
    206b:	mov    edx,0x2
    2070:	mov    rdi,QWORD PTR [rsp+0x70]
    2075:	call   207a <botlish_fn_16+0x1e8>
			2076: R_X86_64_PLT32	rt_struct_new-0x4
    207a:	mov    rbx,QWORD PTR [rsp+0xa0]
    2082:	mov    r12,QWORD PTR [rsp+0xa8]
    208a:	mov    r13,QWORD PTR [rsp+0xb0]
    2092:	mov    r14,QWORD PTR [rsp+0xb8]
    209a:	mov    r15,QWORD PTR [rsp+0xc0]
    20a2:	add    rsp,0xd0
    20a9:	mov    rsp,rbp
    20ac:	pop    rbp
    20ad:	ret
    20ae:	mov    rcx,QWORD PTR [rsp+0x80]
    20b6:	mov    rdx,QWORD PTR [rsp+0x78]
    20bb:	mov    rsi,QWORD PTR [rsp+0x98]
    20c3:	mov    rdi,QWORD PTR [rsp+0x70]
    20c8:	call   20cd <botlish_fn_16+0x23b>
			20c9: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    20cd:	test   rax,rax
    20d0:	jne    210d <botlish_fn_16+0x27b>
    20d6:	xor    rax,rax
    20d9:	mov    rbx,QWORD PTR [rsp+0xa0]
    20e1:	mov    r12,QWORD PTR [rsp+0xa8]
    20e9:	mov    r13,QWORD PTR [rsp+0xb0]
    20f1:	mov    r14,QWORD PTR [rsp+0xb8]
    20f9:	mov    r15,QWORD PTR [rsp+0xc0]
    2101:	add    rsp,0xd0
    2108:	mov    rsp,rbp
    210b:	pop    rbp
    210c:	ret
    210d:	mov    QWORD PTR [rsp],rax
    2111:	mov    rbx,rax
    2114:	mov    QWORD PTR [rsp+0x8],0x3
    211d:	mov    rsi,QWORD PTR [rsp+0x90]
    2125:	test   rsi,0x1
    212c:	je     214c <botlish_fn_16+0x2ba>
    2132:	mov    rsi,QWORD PTR [rsp+0x90]
    213a:	mov    rax,rsi
    213d:	add    rax,0x2
    2141:	seto   cl
    2144:	test   cl,cl
    2146:	je     2163 <botlish_fn_16+0x2d1>
    214c:	mov    edx,0x3
    2151:	mov    rsi,QWORD PTR [rsp+0x90]
    2159:	mov    rdi,QWORD PTR [rsp+0x70]
    215e:	call   2163 <botlish_fn_16+0x2d1>
			215f: R_X86_64_PLT32	rt_int_add-0x4
    2163:	mov    QWORD PTR [rsp+0x8],rax
    2168:	lea    rcx,[rsp+0x50]
    216d:	mov    rdx,rbx
    2170:	mov    QWORD PTR [rsp+0x50],rdx
    2175:	mov    QWORD PTR [rsp+0x58],rax
    217a:	xor    rsi,rsi
    217d:	mov    edx,0x2
    2182:	mov    rdi,QWORD PTR [rsp+0x70]
    2187:	call   218c <botlish_fn_16+0x2fa>
			2188: R_X86_64_PLT32	rt_struct_new-0x4
    218c:	mov    rbx,QWORD PTR [rsp+0xa0]
    2194:	mov    r12,QWORD PTR [rsp+0xa8]
    219c:	mov    r13,QWORD PTR [rsp+0xb0]
    21a4:	mov    r14,QWORD PTR [rsp+0xb8]
    21ac:	mov    r15,QWORD PTR [rsp+0xc0]
    21b4:	add    rsp,0xd0
    21bb:	mov    rsp,rbp
    21be:	pop    rbp
    21bf:	ret
    21c0:	mov    edx,0x3
    21c5:	mov    rcx,rdx
    21c8:	mov    QWORD PTR [rsp+0x28],0x3
    21d1:	mov    rsi,QWORD PTR [rsp+0x90]
    21d9:	test   rsi,0x1
    21e0:	jne    21f6 <botlish_fn_16+0x364>
    21e6:	mov    rdx,rcx
    21e9:	mov    rsi,QWORD PTR [rsp+0x90]
    21f1:	jmp    221b <botlish_fn_16+0x389>
    21f6:	mov    rsi,QWORD PTR [rsp+0x90]
    21fe:	mov    rdx,rsi
    2201:	add    rdx,0x2
    2205:	seto   al
    2208:	test   al,al
    220a:	je     2228 <botlish_fn_16+0x396>
    2210:	mov    rdx,rcx
    2213:	mov    rsi,QWORD PTR [rsp+0x90]
    221b:	mov    rdi,QWORD PTR [rsp+0x70]
    2220:	call   2225 <botlish_fn_16+0x393>
			2221: R_X86_64_PLT32	rt_int_add-0x4
    2225:	mov    rdx,rax
    2228:	mov    QWORD PTR [rsp],r12
    222c:	mov    QWORD PTR [rsp+0x8],rdx
    2231:	mov    rsi,QWORD PTR [rsp+0x98]
    2239:	mov    QWORD PTR [rsp+0x10],rsi
    223e:	mov    rdi,QWORD PTR [rsp+0x78]
    2243:	mov    QWORD PTR [rsp+0x18],rdi
    2248:	mov    rcx,QWORD PTR [rsp+0x80]
    2250:	mov    QWORD PTR [rsp+0x20],rcx
    2255:	mov    r14,rsi
    2258:	jmp    1f08 <botlish_fn_16+0x76>

000000000000225d <botlish_entry_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    225d:	push   rbp
    225e:	mov    rbp,rsp
    2261:	mov    rsi,QWORD PTR [rdx]
    2264:	mov    r10,QWORD PTR [rdx+0x8]
    2268:	mov    rcx,QWORD PTR [rdx+0x10]
    226c:	mov    r8,QWORD PTR [rdx+0x18]
    2270:	mov    r9,QWORD PTR [rdx+0x20]
    2274:	mov    rdx,r10
    2277:	call   227c <botlish_entry_16+0x1f>
			2278: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[List[mutarray], mutarray, int]>
    227c:	mov    rsp,rbp
    227f:	pop    rbp
    2280:	ret

0000000000002281 <botlish_fn_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    2281:	push   rbp
    2282:	mov    rbp,rsp
    2285:	sub    rsp,0xa0
    228c:	mov    QWORD PTR [rsp+0x70],rbx
    2291:	mov    QWORD PTR [rsp+0x78],r12
    2296:	mov    QWORD PTR [rsp+0x80],r13
    229e:	mov    QWORD PTR [rsp+0x88],r14
    22a6:	mov    QWORD PTR [rsp+0x90],r15
    22ae:	mov    r12,rdi
    22b1:	mov    QWORD PTR [rsp+0x28],0x0
    22ba:	mov    QWORD PTR [rsp+0x30],0x0
    22c3:	mov    QWORD PTR [rsp+0x38],0x0
    22cc:	mov    QWORD PTR [rsp],rsi
    22d0:	mov    rbx,rsi
    22d3:	mov    QWORD PTR [rsp+0x8],rdx
    22d8:	mov    QWORD PTR [rsp+0x60],rdx
    22dd:	mov    QWORD PTR [rsp+0x10],rcx
    22e2:	mov    r15,rcx
    22e5:	mov    QWORD PTR [rsp+0x18],r8
    22ea:	mov    r14,r8
    22ed:	mov    QWORD PTR [rsp+0x20],r9
    22f2:	mov    r13,r9
    22f5:	mov    rsi,rbx
    22f8:	mov    rdi,r12
    22fb:	call   2300 <botlish_fn_17+0x7f>
			22fc: R_X86_64_PLT32	rt_str_len-0x4
    2300:	mov    rdx,QWORD PTR [rsp+0x60]
    2305:	mov    rcx,rdx
    2308:	sar    rcx,1
    230b:	sar    rax,1
    230e:	cmp    rcx,rax
    2311:	jge    2402 <botlish_fn_17+0x181>
    2317:	lea    rsi,[rsp+0x40]
    231c:	mov    rdi,r12
    231f:	call   2324 <botlish_fn_17+0xa3>
			2320: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2324:	test   rax,rax
    2327:	je     241c <botlish_fn_17+0x19b>
    232d:	mov    QWORD PTR [rsp+0x28],rax
    2332:	mov    rcx,rax
    2335:	mov    r8,QWORD PTR [rsp+0x40]
    233a:	mov    QWORD PTR [rsp+0x30],r8
    233f:	mov    r9,QWORD PTR [rsp+0x48]
    2344:	mov    QWORD PTR [rsp+0x38],r9
    2349:	mov    rdx,QWORD PTR [rsp+0x60]
    234e:	mov    rsi,rbx
    2351:	mov    rdi,r12
    2354:	call   2359 <botlish_fn_17+0xd8>
			2355: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    2359:	test   rax,rax
    235c:	je     241c <botlish_fn_17+0x19b>
    2362:	mov    rcx,QWORD PTR [rax+0x18]
    2366:	mov    rdx,QWORD PTR [rcx+0x8]
    236a:	mov    QWORD PTR [rsp+0x8],rdx
    236f:	mov    QWORD PTR [rsp+0x60],rdx
    2374:	mov    rax,QWORD PTR [rax+0x18]
    2378:	mov    r8,QWORD PTR [rax]
    237b:	mov    QWORD PTR [rsp+0x28],r8
    2380:	lea    r9,[rsp+0x50]
    2385:	mov    rcx,r13
    2388:	mov    rdx,r14
    238b:	mov    rsi,r15
    238e:	mov    rdi,r12
    2391:	call   2396 <botlish_fn_17+0x115>
			2392: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[List[never], mutarray, int], list>
    2396:	test   rax,rax
    2399:	je     241c <botlish_fn_17+0x19b>
    239f:	mov    QWORD PTR [rsp+0x10],rax
    23a4:	mov    rcx,rax
    23a7:	mov    r8,QWORD PTR [rsp+0x50]
    23ac:	mov    QWORD PTR [rsp+0x18],r8
    23b1:	mov    r9,QWORD PTR [rsp+0x58]
    23b6:	mov    QWORD PTR [rsp+0x20],r9
    23bb:	mov    rdx,QWORD PTR [rsp+0x60]
    23c0:	mov    rsi,rbx
    23c3:	mov    rdi,r12
    23c6:	call   23cb <botlish_fn_17+0x14a>
			23c7: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    23cb:	test   rax,rax
    23ce:	je     241c <botlish_fn_17+0x19b>
    23d4:	mov    rbx,QWORD PTR [rsp+0x70]
    23d9:	mov    r12,QWORD PTR [rsp+0x78]
    23de:	mov    r13,QWORD PTR [rsp+0x80]
    23e6:	mov    r14,QWORD PTR [rsp+0x88]
    23ee:	mov    r15,QWORD PTR [rsp+0x90]
    23f6:	add    rsp,0xa0
    23fd:	mov    rsp,rbp
    2400:	pop    rbp
    2401:	ret
    2402:	mov    rcx,r13
    2405:	mov    rdx,r14
    2408:	mov    rsi,r15
    240b:	mov    rdi,r12
    240e:	call   2413 <botlish_fn_17+0x192>
			240f: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[List[never], mutarray, int]>
    2413:	test   rax,rax
    2416:	jne    244d <botlish_fn_17+0x1cc>
    241c:	xor    rax,rax
    241f:	mov    rbx,QWORD PTR [rsp+0x70]
    2424:	mov    r12,QWORD PTR [rsp+0x78]
    2429:	mov    r13,QWORD PTR [rsp+0x80]
    2431:	mov    r14,QWORD PTR [rsp+0x88]
    2439:	mov    r15,QWORD PTR [rsp+0x90]
    2441:	add    rsp,0xa0
    2448:	mov    rsp,rbp
    244b:	pop    rbp
    244c:	ret
    244d:	mov    rbx,QWORD PTR [rsp+0x70]
    2452:	mov    r12,QWORD PTR [rsp+0x78]
    2457:	mov    r13,QWORD PTR [rsp+0x80]
    245f:	mov    r14,QWORD PTR [rsp+0x88]
    2467:	mov    r15,QWORD PTR [rsp+0x90]
    246f:	add    rsp,0xa0
    2476:	mov    rsp,rbp
    2479:	pop    rbp
    247a:	ret

000000000000247b <botlish_entry_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    247b:	push   rbp
    247c:	mov    rbp,rsp
    247f:	mov    rsi,QWORD PTR [rdx]
    2482:	mov    r10,QWORD PTR [rdx+0x8]
    2486:	mov    rcx,QWORD PTR [rdx+0x10]
    248a:	mov    r8,QWORD PTR [rdx+0x18]
    248e:	mov    r9,QWORD PTR [rdx+0x20]
    2492:	mov    rdx,r10
    2495:	call   249a <botlish_entry_17+0x1f>
			2496: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    249a:	mov    rsp,rbp
    249d:	pop    rbp
    249e:	ret
	...

00000000000024a0 <botlish_fn_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    24a0:	push   rbp
    24a1:	mov    rbp,rsp
    24a4:	sub    rsp,0xb0
    24ab:	mov    QWORD PTR [rsp+0x80],rbx
    24b3:	mov    QWORD PTR [rsp+0x88],r12
    24bb:	mov    QWORD PTR [rsp+0x90],r13
    24c3:	mov    QWORD PTR [rsp+0x98],r14
    24cb:	mov    QWORD PTR [rsp+0xa0],r15
    24d3:	mov    r15,rdi
    24d6:	mov    QWORD PTR [rsp+0x28],0x0
    24df:	mov    QWORD PTR [rsp+0x30],0x0
    24e8:	mov    QWORD PTR [rsp+0x38],0x0
    24f1:	mov    QWORD PTR [rsp],rsi
    24f5:	mov    QWORD PTR [rsp+0x8],rdx
    24fa:	mov    r14,rdx
    24fd:	mov    QWORD PTR [rsp+0x10],rcx
    2502:	mov    QWORD PTR [rsp+0x18],r8
    2507:	mov    QWORD PTR [rsp+0x20],r9
    250c:	lea    r13,[rsp+0x40]
    2511:	lea    rbx,[rsp+0x50]
    2516:	mov    r12,rsi
    2519:	mov    QWORD PTR [rsp+0x60],rcx
    251e:	mov    QWORD PTR [rsp+0x68],r8
    2523:	mov    QWORD PTR [rsp+0x70],r9
    2528:	mov    rsi,r12
    252b:	mov    rdi,r15
    252e:	call   2533 <botlish_fn_18+0x93>
			252f: R_X86_64_PLT32	rt_str_len-0x4
    2533:	mov    rcx,r14
    2536:	and    rcx,rax
    2539:	mov    rdx,rax
    253c:	test   rcx,0x1
    2543:	jne    2569 <botlish_fn_18+0xc9>
    2549:	mov    rsi,r14
    254c:	mov    rdi,r15
    254f:	call   2554 <botlish_fn_18+0xb4>
			2550: R_X86_64_PLT32	rt_int_cmp-0x4
    2554:	mov    ecx,0x2
    2559:	test   rax,rax
    255c:	cmovge rcx,QWORD PTR [rip+0x16c]        # 26d0 <botlish_fn_18+0x230>
    2564:	jmp    257c <botlish_fn_18+0xdc>
    2569:	mov    ecx,0x2
    256e:	mov    r8,r14
    2571:	cmp    r8,rdx
    2574:	cmovge rcx,QWORD PTR [rip+0x154]        # 26d0 <botlish_fn_18+0x230>
    257c:	cmp    rcx,0x6
    2580:	je     2645 <botlish_fn_18+0x1a5>
    2586:	mov    rsi,r13
    2589:	mov    rdi,r15
    258c:	call   2591 <botlish_fn_18+0xf1>
			258d: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2591:	test   rax,rax
    2594:	je     2665 <botlish_fn_18+0x1c5>
    259a:	mov    QWORD PTR [rsp+0x28],rax
    259f:	mov    rcx,rax
    25a2:	mov    r8,QWORD PTR [rsp+0x40]
    25a7:	mov    QWORD PTR [rsp+0x30],r8
    25ac:	mov    r9,QWORD PTR [rsp+0x48]
    25b1:	mov    QWORD PTR [rsp+0x38],r9
    25b6:	mov    rdx,r14
    25b9:	mov    rsi,r12
    25bc:	mov    rdi,r15
    25bf:	call   25c4 <botlish_fn_18+0x124>
			25c0: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    25c4:	test   rax,rax
    25c7:	je     2665 <botlish_fn_18+0x1c5>
    25cd:	mov    rcx,QWORD PTR [rax+0x18]
    25d1:	mov    rdx,QWORD PTR [rcx+0x8]
    25d5:	mov    r14,rdx
    25d8:	mov    QWORD PTR [rsp+0x8],rdx
    25dd:	mov    rax,QWORD PTR [rax+0x18]
    25e1:	mov    r8,QWORD PTR [rax]
    25e4:	mov    QWORD PTR [rsp+0x28],r8
    25e9:	mov    rcx,QWORD PTR [rsp+0x70]
    25ee:	mov    rdx,QWORD PTR [rsp+0x68]
    25f3:	mov    rsi,QWORD PTR [rsp+0x60]
    25f8:	mov    rdi,r15
    25fb:	mov    r9,rbx
    25fe:	call   2603 <botlish_fn_18+0x163>
			25ff: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[List[mutarray], mutarray, int], list>
    2603:	test   rax,rax
    2606:	je     2665 <botlish_fn_18+0x1c5>
    260c:	mov    rdx,QWORD PTR [rsp+0x50]
    2611:	mov    rcx,QWORD PTR [rsp+0x58]
    2616:	mov    QWORD PTR [rsp],r12
    261a:	mov    rsi,r14
    261d:	mov    QWORD PTR [rsp+0x8],rsi
    2622:	mov    QWORD PTR [rsp+0x10],rax
    2627:	mov    QWORD PTR [rsp+0x18],rdx
    262c:	mov    QWORD PTR [rsp+0x20],rcx
    2631:	mov    QWORD PTR [rsp+0x60],rax
    2636:	mov    QWORD PTR [rsp+0x68],rdx
    263b:	mov    QWORD PTR [rsp+0x70],rcx
    2640:	jmp    2528 <botlish_fn_18+0x88>
    2645:	mov    rcx,QWORD PTR [rsp+0x70]
    264a:	mov    rdx,QWORD PTR [rsp+0x68]
    264f:	mov    rsi,QWORD PTR [rsp+0x60]
    2654:	mov    rdi,r15
    2657:	call   265c <botlish_fn_18+0x1bc>
			2658: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    265c:	test   rax,rax
    265f:	jne    269c <botlish_fn_18+0x1fc>
    2665:	xor    rax,rax
    2668:	mov    rbx,QWORD PTR [rsp+0x80]
    2670:	mov    r12,QWORD PTR [rsp+0x88]
    2678:	mov    r13,QWORD PTR [rsp+0x90]
    2680:	mov    r14,QWORD PTR [rsp+0x98]
    2688:	mov    r15,QWORD PTR [rsp+0xa0]
    2690:	add    rsp,0xb0
    2697:	mov    rsp,rbp
    269a:	pop    rbp
    269b:	ret
    269c:	mov    rbx,QWORD PTR [rsp+0x80]
    26a4:	mov    r12,QWORD PTR [rsp+0x88]
    26ac:	mov    r13,QWORD PTR [rsp+0x90]
    26b4:	mov    r14,QWORD PTR [rsp+0x98]
    26bc:	mov    r15,QWORD PTR [rsp+0xa0]
    26c4:	add    rsp,0xb0
    26cb:	mov    rsp,rbp
    26ce:	pop    rbp
    26cf:	ret
    26d0:	(bad)
    26d1:	add    BYTE PTR [rax],al
    26d3:	add    BYTE PTR [rax],al
    26d5:	add    BYTE PTR [rax],al
	...

00000000000026d8 <botlish_entry_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    26d8:	push   rbp
    26d9:	mov    rbp,rsp
    26dc:	mov    rsi,QWORD PTR [rdx]
    26df:	mov    r10,QWORD PTR [rdx+0x8]
    26e3:	mov    rcx,QWORD PTR [rdx+0x10]
    26e7:	mov    r8,QWORD PTR [rdx+0x18]
    26eb:	mov    r9,QWORD PTR [rdx+0x20]
    26ef:	mov    rdx,r10
    26f2:	call   26f7 <botlish_entry_18+0x1f>
			26f3: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    26f7:	mov    rsp,rbp
    26fa:	pop    rbp
    26fb:	ret

00000000000026fc <botlish_fn_19: csv_parse<str>>:
    26fc:	push   rbp
    26fd:	mov    rbp,rsp
    2700:	sub    rsp,0x50
    2704:	mov    QWORD PTR [rsp+0x40],r12
    2709:	mov    QWORD PTR [rsp+0x48],r13
    270e:	mov    r13,rdi
    2711:	mov    QWORD PTR [rsp+0x10],0x0
    271a:	mov    QWORD PTR [rsp+0x18],0x0
    2723:	mov    QWORD PTR [rsp+0x20],0x0
    272c:	mov    QWORD PTR [rsp],rsi
    2730:	mov    r12,rsi
    2733:	mov    QWORD PTR [rsp+0x8],0x1
    273c:	lea    rsi,[rsp+0x28]
    2741:	mov    rdi,r13
    2744:	call   2749 <botlish_fn_19+0x4d>
			2745: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2749:	test   rax,rax
    274c:	je     2787 <botlish_fn_19+0x8b>
    2752:	mov    QWORD PTR [rsp+0x10],rax
    2757:	mov    rcx,rax
    275a:	mov    r8,QWORD PTR [rsp+0x28]
    275f:	mov    QWORD PTR [rsp+0x18],r8
    2764:	mov    r9,QWORD PTR [rsp+0x30]
    2769:	mov    QWORD PTR [rsp+0x20],r9
    276e:	mov    edx,0x1
    2773:	mov    rsi,r12
    2776:	mov    rdi,r13
    2779:	call   277e <botlish_fn_19+0x82>
			277a: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    277e:	test   rax,rax
    2781:	jne    279d <botlish_fn_19+0xa1>
    2787:	xor    rax,rax
    278a:	mov    r12,QWORD PTR [rsp+0x40]
    278f:	mov    r13,QWORD PTR [rsp+0x48]
    2794:	add    rsp,0x50
    2798:	mov    rsp,rbp
    279b:	pop    rbp
    279c:	ret
    279d:	mov    r12,QWORD PTR [rsp+0x40]
    27a2:	mov    r13,QWORD PTR [rsp+0x48]
    27a7:	add    rsp,0x50
    27ab:	mov    rsp,rbp
    27ae:	pop    rbp
    27af:	ret

00000000000027b0 <botlish_entry_19: csv_parse<str>>:
    27b0:	push   rbp
    27b1:	mov    rbp,rsp
    27b4:	mov    rsi,QWORD PTR [rdx]
    27b7:	call   27bc <botlish_entry_19+0xc>
			27b8: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    27bc:	mov    rsp,rbp
    27bf:	pop    rbp
    27c0:	ret

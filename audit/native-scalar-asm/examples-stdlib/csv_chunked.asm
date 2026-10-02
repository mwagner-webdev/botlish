; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10151  (per function: 68 195 534 534 534 534 498 418 540 540 365 430 585 1046 352 799 833 537 612 197)
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
    151b:	add    BYTE PTR [rax],al
    151d:	add    BYTE PTR [rax],al
	...

0000000000001520 <botlish_fn_13: scan_quoted<str, int, str>>:
    1520:	push   rbp
    1521:	mov    rbp,rsp
    1524:	sub    rsp,0xd0
    152b:	mov    QWORD PTR [rsp+0xa0],rbx
    1533:	mov    QWORD PTR [rsp+0xa8],r12
    153b:	mov    QWORD PTR [rsp+0xb0],r13
    1543:	mov    QWORD PTR [rsp+0xb8],r14
    154b:	mov    QWORD PTR [rsp+0xc0],r15
    1553:	mov    r15,rdi
    1556:	mov    QWORD PTR [rsp+0x18],0x0
    155f:	mov    QWORD PTR [rsp+0x20],0x0
    1568:	mov    QWORD PTR [rsp],rsi
    156c:	mov    QWORD PTR [rsp+0x8],rdx
    1571:	mov    QWORD PTR [rsp+0x10],rcx
    1576:	mov    r13,rcx
    1579:	lea    r14,[rsp+0x68]
    157e:	lea    rbx,[rsp+0x28]
    1583:	mov    r12,rsi
    1586:	mov    QWORD PTR [rsp+0x88],rdx
    158e:	mov    rdx,QWORD PTR [rsp+0x88]
    1596:	mov    rsi,r12
    1599:	mov    rdi,r15
    159c:	call   15a1 <botlish_fn_13+0x81>
			159d: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    15a1:	test   rax,rax
    15a4:	je     1898 <botlish_fn_13+0x378>
    15aa:	mov    QWORD PTR [rsp+0x18],rax
    15af:	mov    rdx,QWORD PTR [rax+0x8]
    15b3:	mov    ecx,DWORD PTR [rax+0x14]
    15b6:	mov    QWORD PTR [rsp+0x90],rax
    15be:	test   rdx,rdx
    15c1:	cmove  rcx,QWORD PTR [rip+0x327]        # 18f0 <botlish_fn_13+0x3d0>
    15c9:	cmp    rcx,0x22
    15cd:	je     168d <botlish_fn_13+0x16d>
    15d3:	mov    QWORD PTR [rsp+0x20],0x3
    15dc:	mov    rsi,QWORD PTR [rsp+0x88]
    15e4:	test   rsi,0x1
    15eb:	je     160d <botlish_fn_13+0xed>
    15f1:	mov    r8,rsi
    15f4:	add    r8,0x2
    15f8:	seto   r10b
    15fc:	test   r10b,r10b
    15ff:	jne    160d <botlish_fn_13+0xed>
    1605:	mov    rsi,r8
    1608:	jmp    161d <botlish_fn_13+0xfd>
    160d:	mov    edx,0x3
    1612:	mov    rdi,r15
    1615:	call   161a <botlish_fn_13+0xfa>
			1616: R_X86_64_PLT32	rt_int_add-0x4
    161a:	mov    rsi,rax
    161d:	mov    QWORD PTR [rsp+0x8],rsi
    1622:	mov    QWORD PTR [rsp+0x88],rsi
    162a:	mov    QWORD PTR [rsp+0x68],0x0
    1633:	mov    QWORD PTR [rsp+0x70],r13
    1638:	mov    QWORD PTR [rsp+0x78],0x0
    1641:	mov    rax,QWORD PTR [rsp+0x90]
    1649:	mov    QWORD PTR [rsp+0x80],rax
    1651:	mov    esi,0x2
    1656:	mov    edx,0x4
    165b:	mov    rcx,r14
    165e:	mov    rdi,r15
    1661:	call   1666 <botlish_fn_13+0x146>
			1662: R_X86_64_PLT32	rt_construct-0x4
    1666:	test   rax,rax
    1669:	je     1898 <botlish_fn_13+0x378>
    166f:	mov    QWORD PTR [rsp],r12
    1673:	mov    rsi,QWORD PTR [rsp+0x88]
    167b:	mov    QWORD PTR [rsp+0x8],rsi
    1680:	mov    QWORD PTR [rsp+0x10],rax
    1685:	mov    r13,rax
    1688:	jmp    158e <botlish_fn_13+0x6e>
    168d:	mov    QWORD PTR [rsp+0x18],0x3
    1696:	mov    rsi,QWORD PTR [rsp+0x88]
    169e:	test   rsi,0x1
    16a5:	je     16c5 <botlish_fn_13+0x1a5>
    16ab:	mov    rsi,QWORD PTR [rsp+0x88]
    16b3:	mov    rdx,rsi
    16b6:	add    rdx,0x2
    16ba:	seto   al
    16bd:	test   al,al
    16bf:	je     16dd <botlish_fn_13+0x1bd>
    16c5:	mov    edx,0x3
    16ca:	mov    rsi,QWORD PTR [rsp+0x88]
    16d2:	mov    rdi,r15
    16d5:	call   16da <botlish_fn_13+0x1ba>
			16d6: R_X86_64_PLT32	rt_int_add-0x4
    16da:	mov    rdx,rax
    16dd:	mov    QWORD PTR [rsp+0x18],rdx
    16e2:	mov    rcx,rbx
    16e5:	mov    rsi,r12
    16e8:	mov    rdi,r15
    16eb:	call   16f0 <botlish_fn_13+0x1d0>
			16ec: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    16f0:	test   rax,rax
    16f3:	mov    rsi,rax
    16f6:	je     1898 <botlish_fn_13+0x378>
    16fc:	mov    rdx,QWORD PTR [rsp+0x28]
    1701:	mov    rcx,QWORD PTR [rsp+0x30]
    1706:	mov    rdi,r15
    1709:	mov    rax,QWORD PTR [rdi+0x10]
    170d:	mov    r8,QWORD PTR [rax+0x28]
    1711:	call   1716 <botlish_fn_13+0x1f6>
			1712: R_X86_64_PLT32	rt_str_region_eq-0x4
    1716:	cmp    rax,0x6
    171a:	je     17e2 <botlish_fn_13+0x2c2>
    1720:	xor    rsi,rsi
    1723:	lea    rcx,[rsp+0x58]
    1728:	mov    QWORD PTR [rsp+0x58],0x0
    1731:	mov    QWORD PTR [rsp+0x60],r13
    1736:	mov    edx,0x2
    173b:	mov    rdi,r15
    173e:	call   1743 <botlish_fn_13+0x223>
			173f: R_X86_64_PLT32	rt_construct-0x4
    1743:	test   rax,rax
    1746:	je     1898 <botlish_fn_13+0x378>
    174c:	mov    QWORD PTR [rsp],rax
    1750:	mov    rbx,rax
    1753:	mov    QWORD PTR [rsp+0x10],0x3
    175c:	mov    rsi,QWORD PTR [rsp+0x88]
    1764:	test   rsi,0x1
    176b:	je     1793 <botlish_fn_13+0x273>
    1771:	mov    rsi,QWORD PTR [rsp+0x88]
    1779:	mov    rdx,rsi
    177c:	add    rdx,0x2
    1780:	seto   al
    1783:	test   al,al
    1785:	jne    1793 <botlish_fn_13+0x273>
    178b:	mov    rax,rbx
    178e:	jmp    17ae <botlish_fn_13+0x28e>
    1793:	mov    edx,0x3
    1798:	mov    rsi,QWORD PTR [rsp+0x88]
    17a0:	mov    rdi,r15
    17a3:	call   17a8 <botlish_fn_13+0x288>
			17a4: R_X86_64_PLT32	rt_int_add-0x4
    17a8:	mov    rdx,rax
    17ab:	mov    rax,rbx
    17ae:	mov    rbx,QWORD PTR [rsp+0xa0]
    17b6:	mov    r12,QWORD PTR [rsp+0xa8]
    17be:	mov    r13,QWORD PTR [rsp+0xb0]
    17c6:	mov    r14,QWORD PTR [rsp+0xb8]
    17ce:	mov    r15,QWORD PTR [rsp+0xc0]
    17d6:	add    rsp,0xd0
    17dd:	mov    rsp,rbp
    17e0:	pop    rbp
    17e1:	ret
    17e2:	mov    QWORD PTR [rsp+0x18],0x5
    17eb:	mov    rsi,QWORD PTR [rsp+0x88]
    17f3:	test   rsi,0x1
    17fa:	je     182a <botlish_fn_13+0x30a>
    1800:	mov    rsi,QWORD PTR [rsp+0x88]
    1808:	mov    rax,rsi
    180b:	add    rax,0x4
    180f:	seto   cl
    1812:	test   cl,cl
    1814:	jne    182a <botlish_fn_13+0x30a>
    181a:	mov    rsi,rax
    181d:	mov    QWORD PTR [rsp+0x88],rax
    1825:	jmp    184a <botlish_fn_13+0x32a>
    182a:	mov    edx,0x5
    182f:	mov    rsi,QWORD PTR [rsp+0x88]
    1837:	mov    rdi,r15
    183a:	call   183f <botlish_fn_13+0x31f>
			183b: R_X86_64_PLT32	rt_int_add-0x4
    183f:	mov    rsi,rax
    1842:	mov    QWORD PTR [rsp+0x88],rax
    184a:	mov    QWORD PTR [rsp+0x8],rsi
    184f:	mov    rdi,r15
    1852:	mov    rsi,QWORD PTR [rdi+0x10]
    1856:	mov    rsi,QWORD PTR [rsi+0x28]
    185a:	mov    QWORD PTR [rsp+0x18],rsi
    185f:	lea    rcx,[rsp+0x38]
    1864:	mov    QWORD PTR [rsp+0x38],0x0
    186d:	mov    QWORD PTR [rsp+0x40],r13
    1872:	mov    QWORD PTR [rsp+0x48],0x0
    187b:	mov    QWORD PTR [rsp+0x50],rsi
    1880:	mov    esi,0x2
    1885:	mov    edx,0x4
    188a:	call   188f <botlish_fn_13+0x36f>
			188b: R_X86_64_PLT32	rt_construct-0x4
    188f:	test   rax,rax
    1892:	jne    18d2 <botlish_fn_13+0x3b2>
    1898:	xor    rdx,rdx
    189b:	mov    rax,rdx
    189e:	mov    rbx,QWORD PTR [rsp+0xa0]
    18a6:	mov    r12,QWORD PTR [rsp+0xa8]
    18ae:	mov    r13,QWORD PTR [rsp+0xb0]
    18b6:	mov    r14,QWORD PTR [rsp+0xb8]
    18be:	mov    r15,QWORD PTR [rsp+0xc0]
    18c6:	add    rsp,0xd0
    18cd:	mov    rsp,rbp
    18d0:	pop    rbp
    18d1:	ret
    18d2:	mov    QWORD PTR [rsp],r12
    18d6:	mov    rsi,QWORD PTR [rsp+0x88]
    18de:	mov    QWORD PTR [rsp+0x8],rsi
    18e3:	mov    QWORD PTR [rsp+0x10],rax
    18e8:	mov    r13,rax
    18eb:	jmp    158e <botlish_fn_13+0x6e>
    18f0:	(bad)
    18f1:	(bad)
    18f2:	(bad)
    18f3:	(bad)
    18f4:	(bad)
    18f5:	(bad)
    18f6:	(bad)
    18f7:	.byte 0xff

00000000000018f8 <botlish_entry_13: scan_quoted<str, int, str>>:
    18f8:	push   rbp
    18f9:	mov    rbp,rsp
    18fc:	ud2

00000000000018fe <botlish_fn_14: scan_field<str, int>>:
    18fe:	push   rbp
    18ff:	mov    rbp,rsp
    1902:	sub    rsp,0x50
    1906:	mov    QWORD PTR [rsp+0x30],rbx
    190b:	mov    QWORD PTR [rsp+0x38],r12
    1910:	mov    QWORD PTR [rsp+0x40],r13
    1915:	mov    r12,rdi
    1918:	mov    r13,rdx
    191b:	mov    QWORD PTR [rsp+0x10],0x0
    1924:	mov    QWORD PTR [rsp],rsi
    1928:	mov    rbx,rsi
    192b:	mov    QWORD PTR [rsp+0x8],rdx
    1930:	lea    rcx,[rsp+0x18]
    1935:	mov    rdx,r13
    1938:	mov    rsi,rbx
    193b:	mov    rdi,r12
    193e:	call   1943 <botlish_fn_14+0x45>
			193f: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1943:	test   rax,rax
    1946:	mov    rsi,rax
    1949:	je     1a14 <botlish_fn_14+0x116>
    194f:	mov    rdx,QWORD PTR [rsp+0x18]
    1954:	mov    rcx,QWORD PTR [rsp+0x20]
    1959:	mov    rdi,r12
    195c:	mov    rax,QWORD PTR [rdi+0x10]
    1960:	mov    r8,QWORD PTR [rax+0x28]
    1964:	call   1969 <botlish_fn_14+0x6b>
			1965: R_X86_64_PLT32	rt_str_region_eq-0x4
    1969:	cmp    rax,0x6
    196d:	je     19a5 <botlish_fn_14+0xa7>
    1973:	mov    rcx,r13
    1976:	mov    rsi,rbx
    1979:	mov    rdi,r12
    197c:	mov    rdx,rcx
    197f:	call   1984 <botlish_fn_14+0x86>
			1980: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_unquoted<str, int, int>
    1984:	test   rax,rax
    1987:	je     1a14 <botlish_fn_14+0x116>
    198d:	mov    rbx,QWORD PTR [rsp+0x30]
    1992:	mov    r12,QWORD PTR [rsp+0x38]
    1997:	mov    r13,QWORD PTR [rsp+0x40]
    199c:	add    rsp,0x50
    19a0:	mov    rsp,rbp
    19a3:	pop    rbp
    19a4:	ret
    19a5:	mov    rcx,r13
    19a8:	mov    QWORD PTR [rsp+0x10],0x3
    19b1:	test   rcx,0x1
    19b8:	jne    19c6 <botlish_fn_14+0xc8>
    19be:	mov    r13,rcx
    19c1:	jmp    19db <botlish_fn_14+0xdd>
    19c6:	mov    rdx,rcx
    19c9:	add    rdx,0x2
    19cd:	mov    r13,rcx
    19d0:	seto   al
    19d3:	test   al,al
    19d5:	je     19ee <botlish_fn_14+0xf0>
    19db:	mov    edx,0x3
    19e0:	mov    rsi,r13
    19e3:	mov    rdi,r12
    19e6:	call   19eb <botlish_fn_14+0xed>
			19e7: R_X86_64_PLT32	rt_int_add-0x4
    19eb:	mov    rdx,rax
    19ee:	mov    QWORD PTR [rsp+0x8],rdx
    19f3:	mov    rdi,r12
    19f6:	mov    rax,QWORD PTR [rdi+0x10]
    19fa:	mov    rcx,QWORD PTR [rax+0x10]
    19fe:	mov    QWORD PTR [rsp+0x10],rcx
    1a03:	mov    rsi,rbx
    1a06:	call   1a0b <botlish_fn_14+0x10d>
			1a07: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_quoted<str, int, str>
    1a0b:	test   rax,rax
    1a0e:	jne    1a32 <botlish_fn_14+0x134>
    1a14:	xor    rdx,rdx
    1a17:	mov    rax,rdx
    1a1a:	mov    rbx,QWORD PTR [rsp+0x30]
    1a1f:	mov    r12,QWORD PTR [rsp+0x38]
    1a24:	mov    r13,QWORD PTR [rsp+0x40]
    1a29:	add    rsp,0x50
    1a2d:	mov    rsp,rbp
    1a30:	pop    rbp
    1a31:	ret
    1a32:	mov    rbx,QWORD PTR [rsp+0x30]
    1a37:	mov    r12,QWORD PTR [rsp+0x38]
    1a3c:	mov    r13,QWORD PTR [rsp+0x40]
    1a41:	add    rsp,0x50
    1a45:	mov    rsp,rbp
    1a48:	pop    rbp
    1a49:	ret

0000000000001a4a <botlish_entry_14: scan_field<str, int>>:
    1a4a:	push   rbp
    1a4b:	mov    rbp,rsp
    1a4e:	ud2

0000000000001a50 <botlish_fn_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1a50:	push   rbp
    1a51:	mov    rbp,rsp
    1a54:	sub    rsp,0xa0
    1a5b:	mov    QWORD PTR [rsp+0x70],rbx
    1a60:	mov    QWORD PTR [rsp+0x78],r12
    1a65:	mov    QWORD PTR [rsp+0x80],r13
    1a6d:	mov    QWORD PTR [rsp+0x88],r14
    1a75:	mov    QWORD PTR [rsp+0x90],r15
    1a7d:	mov    r13,rdi
    1a80:	mov    QWORD PTR [rsp+0x28],0x0
    1a89:	mov    QWORD PTR [rsp],rsi
    1a8d:	mov    r15,rsi
    1a90:	mov    QWORD PTR [rsp+0x8],rdx
    1a95:	mov    QWORD PTR [rsp+0x10],rcx
    1a9a:	mov    QWORD PTR [rsp+0x50],rcx
    1a9f:	mov    QWORD PTR [rsp+0x18],r8
    1aa4:	mov    r12,r8
    1aa7:	mov    QWORD PTR [rsp+0x20],r9
    1aac:	mov    rbx,r9
    1aaf:	mov    rsi,r15
    1ab2:	mov    rdi,r13
    1ab5:	call   1aba <botlish_fn_15+0x6a>
			1ab6: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1aba:	test   rax,rax
    1abd:	je     1cf1 <botlish_fn_15+0x2a1>
    1ac3:	mov    QWORD PTR [rsp+0x8],rax
    1ac8:	mov    r8,rax
    1acb:	mov    QWORD PTR [rsp+0x28],rdx
    1ad0:	mov    r14,rdx
    1ad3:	lea    r9,[rsp+0x30]
    1ad8:	mov    rcx,rbx
    1adb:	mov    rdx,r12
    1ade:	mov    rsi,QWORD PTR [rsp+0x50]
    1ae3:	mov    rdi,r13
    1ae6:	call   1aeb <botlish_fn_15+0x9b>
			1ae7: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<list[List[never], mutarray, int], str>
    1aeb:	test   rax,rax
    1aee:	je     1cf1 <botlish_fn_15+0x2a1>
    1af4:	mov    QWORD PTR [rsp+0x8],rax
    1af9:	mov    QWORD PTR [rsp+0x68],rax
    1afe:	mov    rdx,QWORD PTR [rsp+0x30]
    1b03:	mov    QWORD PTR [rsp+0x10],rdx
    1b08:	mov    QWORD PTR [rsp+0x60],rdx
    1b0d:	mov    rcx,QWORD PTR [rsp+0x38]
    1b12:	mov    QWORD PTR [rsp+0x18],rcx
    1b17:	mov    QWORD PTR [rsp+0x58],rcx
    1b1c:	lea    rcx,[rsp+0x40]
    1b21:	mov    rdx,r14
    1b24:	mov    rsi,r15
    1b27:	mov    rdi,r13
    1b2a:	call   1b2f <botlish_fn_15+0xdf>
			1b2b: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1b2f:	test   rax,rax
    1b32:	mov    QWORD PTR [rsp+0x50],rax
    1b37:	je     1cf1 <botlish_fn_15+0x2a1>
    1b3d:	mov    r12,QWORD PTR [rsp+0x40]
    1b42:	mov    rbx,QWORD PTR [rsp+0x48]
    1b47:	mov    rdi,r13
    1b4a:	mov    rcx,QWORD PTR [rdi+0x10]
    1b4e:	mov    r8,QWORD PTR [rcx+0x18]
    1b52:	mov    rcx,rbx
    1b55:	mov    rdx,r12
    1b58:	mov    rsi,QWORD PTR [rsp+0x50]
    1b5d:	call   1b62 <botlish_fn_15+0x112>
			1b5e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b62:	cmp    rax,0x6
    1b66:	je     1c80 <botlish_fn_15+0x230>
    1b6c:	mov    rdi,r13
    1b6f:	mov    rax,QWORD PTR [rdi+0x10]
    1b73:	mov    r8,QWORD PTR [rax+0x20]
    1b77:	mov    rcx,rbx
    1b7a:	mov    rdx,r12
    1b7d:	mov    rsi,QWORD PTR [rsp+0x50]
    1b82:	call   1b87 <botlish_fn_15+0x137>
			1b83: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b87:	cmp    rax,0x6
    1b8b:	je     1be2 <botlish_fn_15+0x192>
    1b91:	mov    rcx,QWORD PTR [rsp+0x58]
    1b96:	mov    rdx,QWORD PTR [rsp+0x60]
    1b9b:	mov    rsi,QWORD PTR [rsp+0x68]
    1ba0:	mov    rdi,r13
    1ba3:	call   1ba8 <botlish_fn_15+0x158>
			1ba4: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1ba8:	test   rax,rax
    1bab:	je     1cf1 <botlish_fn_15+0x2a1>
    1bb1:	mov    rdx,r14
    1bb4:	mov    rbx,QWORD PTR [rsp+0x70]
    1bb9:	mov    r12,QWORD PTR [rsp+0x78]
    1bbe:	mov    r13,QWORD PTR [rsp+0x80]
    1bc6:	mov    r14,QWORD PTR [rsp+0x88]
    1bce:	mov    r15,QWORD PTR [rsp+0x90]
    1bd6:	add    rsp,0xa0
    1bdd:	mov    rsp,rbp
    1be0:	pop    rbp
    1be1:	ret
    1be2:	mov    rcx,QWORD PTR [rsp+0x58]
    1be7:	mov    rdx,QWORD PTR [rsp+0x60]
    1bec:	mov    rsi,QWORD PTR [rsp+0x68]
    1bf1:	mov    rdi,r13
    1bf4:	call   1bf9 <botlish_fn_15+0x1a9>
			1bf5: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1bf9:	test   rax,rax
    1bfc:	je     1cf1 <botlish_fn_15+0x2a1>
    1c02:	mov    QWORD PTR [rsp],rax
    1c06:	mov    rbx,rax
    1c09:	mov    QWORD PTR [rsp+0x8],0x3
    1c12:	mov    rdx,r14
    1c15:	test   rdx,0x1
    1c1c:	je     1c3c <botlish_fn_15+0x1ec>
    1c22:	mov    rdx,r14
    1c25:	add    rdx,0x2
    1c29:	seto   al
    1c2c:	test   al,al
    1c2e:	jne    1c3c <botlish_fn_15+0x1ec>
    1c34:	mov    rax,rbx
    1c37:	jmp    1c52 <botlish_fn_15+0x202>
    1c3c:	mov    edx,0x3
    1c41:	mov    rsi,r14
    1c44:	mov    rdi,r13
    1c47:	call   1c4c <botlish_fn_15+0x1fc>
			1c48: R_X86_64_PLT32	rt_int_add-0x4
    1c4c:	mov    rdx,rax
    1c4f:	mov    rax,rbx
    1c52:	mov    rbx,QWORD PTR [rsp+0x70]
    1c57:	mov    r12,QWORD PTR [rsp+0x78]
    1c5c:	mov    r13,QWORD PTR [rsp+0x80]
    1c64:	mov    r14,QWORD PTR [rsp+0x88]
    1c6c:	mov    r15,QWORD PTR [rsp+0x90]
    1c74:	add    rsp,0xa0
    1c7b:	mov    rsp,rbp
    1c7e:	pop    rbp
    1c7f:	ret
    1c80:	mov    rsi,r14
    1c83:	mov    edx,0x3
    1c88:	mov    rcx,rdx
    1c8b:	mov    QWORD PTR [rsp+0x20],0x3
    1c94:	test   rsi,0x1
    1c9b:	jne    1ca9 <botlish_fn_15+0x259>
    1ca1:	mov    rdx,rcx
    1ca4:	jmp    1cbe <botlish_fn_15+0x26e>
    1ca9:	mov    rdx,rsi
    1cac:	add    rdx,0x2
    1cb0:	seto   al
    1cb3:	test   al,al
    1cb5:	je     1cc9 <botlish_fn_15+0x279>
    1cbb:	mov    rdx,rcx
    1cbe:	mov    rdi,r13
    1cc1:	call   1cc6 <botlish_fn_15+0x276>
			1cc2: R_X86_64_PLT32	rt_int_add-0x4
    1cc6:	mov    rdx,rax
    1cc9:	mov    QWORD PTR [rsp+0x20],rdx
    1cce:	mov    rcx,QWORD PTR [rsp+0x68]
    1cd3:	mov    rsi,r15
    1cd6:	mov    rdi,r13
    1cd9:	mov    r8,QWORD PTR [rsp+0x60]
    1cde:	mov    r9,QWORD PTR [rsp+0x58]
    1ce3:	call   1ce8 <botlish_fn_15+0x298>
			1ce4: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[List[mutarray], mutarray, int]>
    1ce8:	test   rax,rax
    1ceb:	jne    1d25 <botlish_fn_15+0x2d5>
    1cf1:	xor    rdx,rdx
    1cf4:	mov    rax,rdx
    1cf7:	mov    rbx,QWORD PTR [rsp+0x70]
    1cfc:	mov    r12,QWORD PTR [rsp+0x78]
    1d01:	mov    r13,QWORD PTR [rsp+0x80]
    1d09:	mov    r14,QWORD PTR [rsp+0x88]
    1d11:	mov    r15,QWORD PTR [rsp+0x90]
    1d19:	add    rsp,0xa0
    1d20:	mov    rsp,rbp
    1d23:	pop    rbp
    1d24:	ret
    1d25:	mov    rbx,QWORD PTR [rsp+0x70]
    1d2a:	mov    r12,QWORD PTR [rsp+0x78]
    1d2f:	mov    r13,QWORD PTR [rsp+0x80]
    1d37:	mov    r14,QWORD PTR [rsp+0x88]
    1d3f:	mov    r15,QWORD PTR [rsp+0x90]
    1d47:	add    rsp,0xa0
    1d4e:	mov    rsp,rbp
    1d51:	pop    rbp
    1d52:	ret

0000000000001d53 <botlish_entry_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1d53:	push   rbp
    1d54:	mov    rbp,rsp
    1d57:	ud2

0000000000001d59 <botlish_fn_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    1d59:	push   rbp
    1d5a:	mov    rbp,rsp
    1d5d:	sub    rsp,0xb0
    1d64:	mov    QWORD PTR [rsp+0x80],rbx
    1d6c:	mov    QWORD PTR [rsp+0x88],r12
    1d74:	mov    QWORD PTR [rsp+0x90],r13
    1d7c:	mov    QWORD PTR [rsp+0x98],r14
    1d84:	mov    QWORD PTR [rsp+0xa0],r15
    1d8c:	mov    QWORD PTR [rsp+0x50],rdi
    1d91:	mov    QWORD PTR [rsp+0x28],0x0
    1d9a:	mov    QWORD PTR [rsp],rsi
    1d9e:	mov    QWORD PTR [rsp+0x8],rdx
    1da3:	mov    QWORD PTR [rsp+0x10],rcx
    1da8:	mov    QWORD PTR [rsp+0x18],r8
    1dad:	mov    QWORD PTR [rsp+0x20],r9
    1db2:	lea    r15,[rsp+0x30]
    1db7:	lea    rbx,[rsp+0x40]
    1dbc:	mov    r12,rsi
    1dbf:	mov    r13,rcx
    1dc2:	mov    QWORD PTR [rsp+0x58],r8
    1dc7:	mov    QWORD PTR [rsp+0x60],r9
    1dcc:	mov    rsi,r12
    1dcf:	mov    rdi,QWORD PTR [rsp+0x50]
    1dd4:	call   1dd9 <botlish_fn_16+0x80>
			1dd5: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1dd9:	mov    QWORD PTR [rsp+0x78],rdx
    1dde:	test   rax,rax
    1de1:	je     1f3c <botlish_fn_16+0x1e3>
    1de7:	mov    QWORD PTR [rsp+0x8],rax
    1dec:	mov    rdx,QWORD PTR [rsp+0x78]
    1df1:	mov    r8,rax
    1df4:	mov    QWORD PTR [rsp+0x28],rdx
    1df9:	mov    rcx,QWORD PTR [rsp+0x60]
    1dfe:	mov    rdx,QWORD PTR [rsp+0x58]
    1e03:	mov    rsi,r13
    1e06:	mov    rdi,QWORD PTR [rsp+0x50]
    1e0b:	mov    r9,r15
    1e0e:	call   1e13 <botlish_fn_16+0xba>
			1e0f: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[List[mutarray], mutarray, int], str>
    1e13:	test   rax,rax
    1e16:	je     1f3c <botlish_fn_16+0x1e3>
    1e1c:	mov    QWORD PTR [rsp+0x8],rax
    1e21:	mov    QWORD PTR [rsp+0x70],rax
    1e26:	mov    rdx,QWORD PTR [rsp+0x30]
    1e2b:	mov    QWORD PTR [rsp+0x58],rdx
    1e30:	mov    QWORD PTR [rsp+0x10],rdx
    1e35:	mov    rcx,QWORD PTR [rsp+0x38]
    1e3a:	mov    QWORD PTR [rsp+0x18],rcx
    1e3f:	mov    QWORD PTR [rsp+0x60],rcx
    1e44:	mov    rcx,rbx
    1e47:	mov    rdx,QWORD PTR [rsp+0x78]
    1e4c:	mov    rsi,r12
    1e4f:	mov    rdi,QWORD PTR [rsp+0x50]
    1e54:	call   1e59 <botlish_fn_16+0x100>
			1e55: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1e59:	test   rax,rax
    1e5c:	mov    QWORD PTR [rsp+0x68],rax
    1e61:	je     1f3c <botlish_fn_16+0x1e3>
    1e67:	mov    r13,QWORD PTR [rsp+0x40]
    1e6c:	mov    r14,QWORD PTR [rsp+0x48]
    1e71:	mov    rdi,QWORD PTR [rsp+0x50]
    1e76:	mov    rcx,QWORD PTR [rdi+0x10]
    1e7a:	mov    r8,QWORD PTR [rcx+0x18]
    1e7e:	mov    rcx,r14
    1e81:	mov    rdx,r13
    1e84:	mov    rsi,QWORD PTR [rsp+0x68]
    1e89:	call   1e8e <botlish_fn_16+0x135>
			1e8a: R_X86_64_PLT32	rt_str_region_eq-0x4
    1e8e:	cmp    rax,0x6
    1e92:	je     2002 <botlish_fn_16+0x2a9>
    1e98:	mov    rdi,QWORD PTR [rsp+0x50]
    1e9d:	mov    rax,QWORD PTR [rdi+0x10]
    1ea1:	mov    r8,QWORD PTR [rax+0x20]
    1ea5:	mov    rcx,r14
    1ea8:	mov    rdx,r13
    1eab:	mov    rsi,QWORD PTR [rsp+0x68]
    1eb0:	call   1eb5 <botlish_fn_16+0x15c>
			1eb1: R_X86_64_PLT32	rt_str_region_eq-0x4
    1eb5:	cmp    rax,0x6
    1eb9:	je     1f1a <botlish_fn_16+0x1c1>
    1ebf:	mov    rcx,QWORD PTR [rsp+0x60]
    1ec4:	mov    rdx,QWORD PTR [rsp+0x58]
    1ec9:	mov    rsi,QWORD PTR [rsp+0x70]
    1ece:	mov    rdi,QWORD PTR [rsp+0x50]
    1ed3:	call   1ed8 <botlish_fn_16+0x17f>
			1ed4: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1ed8:	test   rax,rax
    1edb:	je     1f3c <botlish_fn_16+0x1e3>
    1ee1:	mov    rdx,QWORD PTR [rsp+0x78]
    1ee6:	mov    rbx,QWORD PTR [rsp+0x80]
    1eee:	mov    r12,QWORD PTR [rsp+0x88]
    1ef6:	mov    r13,QWORD PTR [rsp+0x90]
    1efe:	mov    r14,QWORD PTR [rsp+0x98]
    1f06:	mov    r15,QWORD PTR [rsp+0xa0]
    1f0e:	add    rsp,0xb0
    1f15:	mov    rsp,rbp
    1f18:	pop    rbp
    1f19:	ret
    1f1a:	mov    rcx,QWORD PTR [rsp+0x60]
    1f1f:	mov    rdx,QWORD PTR [rsp+0x58]
    1f24:	mov    rsi,QWORD PTR [rsp+0x70]
    1f29:	mov    rdi,QWORD PTR [rsp+0x50]
    1f2e:	call   1f33 <botlish_fn_16+0x1da>
			1f2f: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1f33:	test   rax,rax
    1f36:	jne    1f76 <botlish_fn_16+0x21d>
    1f3c:	xor    rdx,rdx
    1f3f:	mov    rax,rdx
    1f42:	mov    rbx,QWORD PTR [rsp+0x80]
    1f4a:	mov    r12,QWORD PTR [rsp+0x88]
    1f52:	mov    r13,QWORD PTR [rsp+0x90]
    1f5a:	mov    r14,QWORD PTR [rsp+0x98]
    1f62:	mov    r15,QWORD PTR [rsp+0xa0]
    1f6a:	add    rsp,0xb0
    1f71:	mov    rsp,rbp
    1f74:	pop    rbp
    1f75:	ret
    1f76:	mov    QWORD PTR [rsp],rax
    1f7a:	mov    rbx,rax
    1f7d:	mov    QWORD PTR [rsp+0x8],0x3
    1f86:	mov    rdx,QWORD PTR [rsp+0x78]
    1f8b:	test   rdx,0x1
    1f92:	je     1fb4 <botlish_fn_16+0x25b>
    1f98:	mov    rdx,QWORD PTR [rsp+0x78]
    1f9d:	add    rdx,0x2
    1fa1:	seto   al
    1fa4:	test   al,al
    1fa6:	jne    1fb4 <botlish_fn_16+0x25b>
    1fac:	mov    rax,rbx
    1faf:	jmp    1fce <botlish_fn_16+0x275>
    1fb4:	mov    edx,0x3
    1fb9:	mov    rsi,QWORD PTR [rsp+0x78]
    1fbe:	mov    rdi,QWORD PTR [rsp+0x50]
    1fc3:	call   1fc8 <botlish_fn_16+0x26f>
			1fc4: R_X86_64_PLT32	rt_int_add-0x4
    1fc8:	mov    rdx,rax
    1fcb:	mov    rax,rbx
    1fce:	mov    rbx,QWORD PTR [rsp+0x80]
    1fd6:	mov    r12,QWORD PTR [rsp+0x88]
    1fde:	mov    r13,QWORD PTR [rsp+0x90]
    1fe6:	mov    r14,QWORD PTR [rsp+0x98]
    1fee:	mov    r15,QWORD PTR [rsp+0xa0]
    1ff6:	add    rsp,0xb0
    1ffd:	mov    rsp,rbp
    2000:	pop    rbp
    2001:	ret
    2002:	mov    rsi,QWORD PTR [rsp+0x78]
    2007:	mov    edx,0x3
    200c:	mov    r10,rdx
    200f:	mov    QWORD PTR [rsp+0x20],0x3
    2018:	test   rsi,0x1
    201f:	jne    202d <botlish_fn_16+0x2d4>
    2025:	mov    rdx,r10
    2028:	jmp    2042 <botlish_fn_16+0x2e9>
    202d:	mov    rdx,rsi
    2030:	add    rdx,0x2
    2034:	seto   al
    2037:	test   al,al
    2039:	je     204f <botlish_fn_16+0x2f6>
    203f:	mov    rdx,r10
    2042:	mov    rdi,QWORD PTR [rsp+0x50]
    2047:	call   204c <botlish_fn_16+0x2f3>
			2048: R_X86_64_PLT32	rt_int_add-0x4
    204c:	mov    rdx,rax
    204f:	mov    QWORD PTR [rsp],r12
    2053:	mov    QWORD PTR [rsp+0x8],rdx
    2058:	mov    rsi,QWORD PTR [rsp+0x70]
    205d:	mov    QWORD PTR [rsp+0x10],rsi
    2062:	mov    rax,QWORD PTR [rsp+0x58]
    2067:	mov    QWORD PTR [rsp+0x18],rax
    206c:	mov    rcx,QWORD PTR [rsp+0x60]
    2071:	mov    QWORD PTR [rsp+0x20],rcx
    2076:	mov    r13,rsi
    2079:	jmp    1dcc <botlish_fn_16+0x73>

000000000000207e <botlish_entry_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    207e:	push   rbp
    207f:	mov    rbp,rsp
    2082:	ud2

0000000000002084 <botlish_fn_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    2084:	push   rbp
    2085:	mov    rbp,rsp
    2088:	sub    rsp,0xa0
    208f:	mov    QWORD PTR [rsp+0x70],rbx
    2094:	mov    QWORD PTR [rsp+0x78],r12
    2099:	mov    QWORD PTR [rsp+0x80],r13
    20a1:	mov    QWORD PTR [rsp+0x88],r14
    20a9:	mov    QWORD PTR [rsp+0x90],r15
    20b1:	mov    r12,rdi
    20b4:	mov    QWORD PTR [rsp+0x28],0x0
    20bd:	mov    QWORD PTR [rsp+0x30],0x0
    20c6:	mov    QWORD PTR [rsp+0x38],0x0
    20cf:	mov    QWORD PTR [rsp],rsi
    20d3:	mov    rbx,rsi
    20d6:	mov    QWORD PTR [rsp+0x8],rdx
    20db:	mov    QWORD PTR [rsp+0x60],rdx
    20e0:	mov    QWORD PTR [rsp+0x10],rcx
    20e5:	mov    r15,rcx
    20e8:	mov    QWORD PTR [rsp+0x18],r8
    20ed:	mov    r14,r8
    20f0:	mov    QWORD PTR [rsp+0x20],r9
    20f5:	mov    r13,r9
    20f8:	mov    rsi,rbx
    20fb:	mov    rdi,r12
    20fe:	call   2103 <botlish_fn_17+0x7f>
			20ff: R_X86_64_PLT32	rt_str_len-0x4
    2103:	mov    rdx,QWORD PTR [rsp+0x60]
    2108:	mov    rcx,rdx
    210b:	sar    rcx,1
    210e:	sar    rax,1
    2111:	cmp    rcx,rax
    2114:	jge    21f9 <botlish_fn_17+0x175>
    211a:	lea    rsi,[rsp+0x40]
    211f:	mov    rdi,r12
    2122:	call   2127 <botlish_fn_17+0xa3>
			2123: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2127:	test   rax,rax
    212a:	je     2213 <botlish_fn_17+0x18f>
    2130:	mov    QWORD PTR [rsp+0x28],rax
    2135:	mov    rcx,rax
    2138:	mov    r8,QWORD PTR [rsp+0x40]
    213d:	mov    QWORD PTR [rsp+0x30],r8
    2142:	mov    r9,QWORD PTR [rsp+0x48]
    2147:	mov    QWORD PTR [rsp+0x38],r9
    214c:	mov    rdx,QWORD PTR [rsp+0x60]
    2151:	mov    rsi,rbx
    2154:	mov    rdi,r12
    2157:	call   215c <botlish_fn_17+0xd8>
			2158: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    215c:	test   rax,rax
    215f:	je     2213 <botlish_fn_17+0x18f>
    2165:	mov    QWORD PTR [rsp+0x8],rax
    216a:	mov    r8,rax
    216d:	mov    QWORD PTR [rsp+0x28],rdx
    2172:	mov    QWORD PTR [rsp+0x60],rdx
    2177:	lea    r9,[rsp+0x50]
    217c:	mov    rcx,r13
    217f:	mov    rdx,r14
    2182:	mov    rsi,r15
    2185:	mov    rdi,r12
    2188:	call   218d <botlish_fn_17+0x109>
			2189: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[List[never], mutarray, int], list>
    218d:	test   rax,rax
    2190:	je     2213 <botlish_fn_17+0x18f>
    2196:	mov    QWORD PTR [rsp+0x8],rax
    219b:	mov    rcx,rax
    219e:	mov    r8,QWORD PTR [rsp+0x50]
    21a3:	mov    QWORD PTR [rsp+0x10],r8
    21a8:	mov    r9,QWORD PTR [rsp+0x58]
    21ad:	mov    QWORD PTR [rsp+0x18],r9
    21b2:	mov    rdx,QWORD PTR [rsp+0x60]
    21b7:	mov    rsi,rbx
    21ba:	mov    rdi,r12
    21bd:	call   21c2 <botlish_fn_17+0x13e>
			21be: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    21c2:	test   rax,rax
    21c5:	je     2213 <botlish_fn_17+0x18f>
    21cb:	mov    rbx,QWORD PTR [rsp+0x70]
    21d0:	mov    r12,QWORD PTR [rsp+0x78]
    21d5:	mov    r13,QWORD PTR [rsp+0x80]
    21dd:	mov    r14,QWORD PTR [rsp+0x88]
    21e5:	mov    r15,QWORD PTR [rsp+0x90]
    21ed:	add    rsp,0xa0
    21f4:	mov    rsp,rbp
    21f7:	pop    rbp
    21f8:	ret
    21f9:	mov    rcx,r13
    21fc:	mov    rdx,r14
    21ff:	mov    rsi,r15
    2202:	mov    rdi,r12
    2205:	call   220a <botlish_fn_17+0x186>
			2206: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[List[never], mutarray, int]>
    220a:	test   rax,rax
    220d:	jne    2244 <botlish_fn_17+0x1c0>
    2213:	xor    rax,rax
    2216:	mov    rbx,QWORD PTR [rsp+0x70]
    221b:	mov    r12,QWORD PTR [rsp+0x78]
    2220:	mov    r13,QWORD PTR [rsp+0x80]
    2228:	mov    r14,QWORD PTR [rsp+0x88]
    2230:	mov    r15,QWORD PTR [rsp+0x90]
    2238:	add    rsp,0xa0
    223f:	mov    rsp,rbp
    2242:	pop    rbp
    2243:	ret
    2244:	mov    rbx,QWORD PTR [rsp+0x70]
    2249:	mov    r12,QWORD PTR [rsp+0x78]
    224e:	mov    r13,QWORD PTR [rsp+0x80]
    2256:	mov    r14,QWORD PTR [rsp+0x88]
    225e:	mov    r15,QWORD PTR [rsp+0x90]
    2266:	add    rsp,0xa0
    226d:	mov    rsp,rbp
    2270:	pop    rbp
    2271:	ret

0000000000002272 <botlish_entry_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    2272:	push   rbp
    2273:	mov    rbp,rsp
    2276:	mov    rsi,QWORD PTR [rdx]
    2279:	mov    r10,QWORD PTR [rdx+0x8]
    227d:	mov    rcx,QWORD PTR [rdx+0x10]
    2281:	mov    r8,QWORD PTR [rdx+0x18]
    2285:	mov    r9,QWORD PTR [rdx+0x20]
    2289:	mov    rdx,r10
    228c:	call   2291 <botlish_entry_17+0x1f>
			228d: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    2291:	mov    rsp,rbp
    2294:	pop    rbp
    2295:	ret
	...

0000000000002298 <botlish_fn_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    2298:	push   rbp
    2299:	mov    rbp,rsp
    229c:	sub    rsp,0xb0
    22a3:	mov    QWORD PTR [rsp+0x80],rbx
    22ab:	mov    QWORD PTR [rsp+0x88],r12
    22b3:	mov    QWORD PTR [rsp+0x90],r13
    22bb:	mov    QWORD PTR [rsp+0x98],r14
    22c3:	mov    QWORD PTR [rsp+0xa0],r15
    22cb:	mov    r15,rdi
    22ce:	mov    QWORD PTR [rsp+0x28],0x0
    22d7:	mov    QWORD PTR [rsp+0x30],0x0
    22e0:	mov    QWORD PTR [rsp+0x38],0x0
    22e9:	mov    QWORD PTR [rsp],rsi
    22ed:	mov    QWORD PTR [rsp+0x8],rdx
    22f2:	mov    r14,rdx
    22f5:	mov    QWORD PTR [rsp+0x10],rcx
    22fa:	mov    QWORD PTR [rsp+0x18],r8
    22ff:	mov    QWORD PTR [rsp+0x20],r9
    2304:	lea    r13,[rsp+0x40]
    2309:	lea    rbx,[rsp+0x50]
    230e:	mov    r12,rsi
    2311:	mov    QWORD PTR [rsp+0x60],rcx
    2316:	mov    QWORD PTR [rsp+0x68],r8
    231b:	mov    QWORD PTR [rsp+0x70],r9
    2320:	mov    rsi,r12
    2323:	mov    rdi,r15
    2326:	call   232b <botlish_fn_18+0x93>
			2327: R_X86_64_PLT32	rt_str_len-0x4
    232b:	mov    rcx,r14
    232e:	and    rcx,rax
    2331:	mov    rdx,rax
    2334:	test   rcx,0x1
    233b:	jne    2361 <botlish_fn_18+0xc9>
    2341:	mov    rsi,r14
    2344:	mov    rdi,r15
    2347:	call   234c <botlish_fn_18+0xb4>
			2348: R_X86_64_PLT32	rt_int_cmp-0x4
    234c:	mov    ecx,0x2
    2351:	test   rax,rax
    2354:	cmovge rcx,QWORD PTR [rip+0x164]        # 24c0 <botlish_fn_18+0x228>
    235c:	jmp    2374 <botlish_fn_18+0xdc>
    2361:	mov    ecx,0x2
    2366:	mov    rdi,r14
    2369:	cmp    rdi,rdx
    236c:	cmovge rcx,QWORD PTR [rip+0x14c]        # 24c0 <botlish_fn_18+0x228>
    2374:	cmp    rcx,0x6
    2378:	je     2431 <botlish_fn_18+0x199>
    237e:	mov    rsi,r13
    2381:	mov    rdi,r15
    2384:	call   2389 <botlish_fn_18+0xf1>
			2385: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2389:	test   rax,rax
    238c:	je     2451 <botlish_fn_18+0x1b9>
    2392:	mov    QWORD PTR [rsp+0x28],rax
    2397:	mov    rcx,rax
    239a:	mov    r8,QWORD PTR [rsp+0x40]
    239f:	mov    QWORD PTR [rsp+0x30],r8
    23a4:	mov    r9,QWORD PTR [rsp+0x48]
    23a9:	mov    QWORD PTR [rsp+0x38],r9
    23ae:	mov    rdx,r14
    23b1:	mov    rsi,r12
    23b4:	mov    rdi,r15
    23b7:	call   23bc <botlish_fn_18+0x124>
			23b8: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    23bc:	test   rax,rax
    23bf:	je     2451 <botlish_fn_18+0x1b9>
    23c5:	mov    QWORD PTR [rsp+0x8],rax
    23ca:	mov    r8,rax
    23cd:	mov    QWORD PTR [rsp+0x28],rdx
    23d2:	mov    r14,rdx
    23d5:	mov    rsi,QWORD PTR [rsp+0x60]
    23da:	mov    rdx,QWORD PTR [rsp+0x68]
    23df:	mov    rcx,QWORD PTR [rsp+0x70]
    23e4:	mov    rdi,r15
    23e7:	mov    r9,rbx
    23ea:	call   23ef <botlish_fn_18+0x157>
			23eb: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[List[mutarray], mutarray, int], list>
    23ef:	test   rax,rax
    23f2:	je     2451 <botlish_fn_18+0x1b9>
    23f8:	mov    rdx,QWORD PTR [rsp+0x50]
    23fd:	mov    rcx,QWORD PTR [rsp+0x58]
    2402:	mov    QWORD PTR [rsp],r12
    2406:	mov    rsi,r14
    2409:	mov    QWORD PTR [rsp+0x8],rsi
    240e:	mov    QWORD PTR [rsp+0x10],rax
    2413:	mov    QWORD PTR [rsp+0x18],rdx
    2418:	mov    QWORD PTR [rsp+0x20],rcx
    241d:	mov    QWORD PTR [rsp+0x60],rax
    2422:	mov    QWORD PTR [rsp+0x68],rdx
    2427:	mov    QWORD PTR [rsp+0x70],rcx
    242c:	jmp    2320 <botlish_fn_18+0x88>
    2431:	mov    rcx,QWORD PTR [rsp+0x70]
    2436:	mov    rdx,QWORD PTR [rsp+0x68]
    243b:	mov    rsi,QWORD PTR [rsp+0x60]
    2440:	mov    rdi,r15
    2443:	call   2448 <botlish_fn_18+0x1b0>
			2444: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    2448:	test   rax,rax
    244b:	jne    2488 <botlish_fn_18+0x1f0>
    2451:	xor    rax,rax
    2454:	mov    rbx,QWORD PTR [rsp+0x80]
    245c:	mov    r12,QWORD PTR [rsp+0x88]
    2464:	mov    r13,QWORD PTR [rsp+0x90]
    246c:	mov    r14,QWORD PTR [rsp+0x98]
    2474:	mov    r15,QWORD PTR [rsp+0xa0]
    247c:	add    rsp,0xb0
    2483:	mov    rsp,rbp
    2486:	pop    rbp
    2487:	ret
    2488:	mov    rbx,QWORD PTR [rsp+0x80]
    2490:	mov    r12,QWORD PTR [rsp+0x88]
    2498:	mov    r13,QWORD PTR [rsp+0x90]
    24a0:	mov    r14,QWORD PTR [rsp+0x98]
    24a8:	mov    r15,QWORD PTR [rsp+0xa0]
    24b0:	add    rsp,0xb0
    24b7:	mov    rsp,rbp
    24ba:	pop    rbp
    24bb:	ret
    24bc:	add    BYTE PTR [rax],al
    24be:	add    BYTE PTR [rax],al
    24c0:	(bad)
    24c1:	add    BYTE PTR [rax],al
    24c3:	add    BYTE PTR [rax],al
    24c5:	add    BYTE PTR [rax],al
	...

00000000000024c8 <botlish_entry_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    24c8:	push   rbp
    24c9:	mov    rbp,rsp
    24cc:	mov    rsi,QWORD PTR [rdx]
    24cf:	mov    r10,QWORD PTR [rdx+0x8]
    24d3:	mov    rcx,QWORD PTR [rdx+0x10]
    24d7:	mov    r8,QWORD PTR [rdx+0x18]
    24db:	mov    r9,QWORD PTR [rdx+0x20]
    24df:	mov    rdx,r10
    24e2:	call   24e7 <botlish_entry_18+0x1f>
			24e3: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    24e7:	mov    rsp,rbp
    24ea:	pop    rbp
    24eb:	ret

00000000000024ec <botlish_fn_19: csv_parse<str>>:
    24ec:	push   rbp
    24ed:	mov    rbp,rsp
    24f0:	sub    rsp,0x50
    24f4:	mov    QWORD PTR [rsp+0x40],r12
    24f9:	mov    QWORD PTR [rsp+0x48],r13
    24fe:	mov    r13,rdi
    2501:	mov    QWORD PTR [rsp+0x10],0x0
    250a:	mov    QWORD PTR [rsp+0x18],0x0
    2513:	mov    QWORD PTR [rsp+0x20],0x0
    251c:	mov    QWORD PTR [rsp],rsi
    2520:	mov    r12,rsi
    2523:	mov    QWORD PTR [rsp+0x8],0x1
    252c:	lea    rsi,[rsp+0x28]
    2531:	mov    rdi,r13
    2534:	call   2539 <botlish_fn_19+0x4d>
			2535: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2539:	test   rax,rax
    253c:	je     2577 <botlish_fn_19+0x8b>
    2542:	mov    QWORD PTR [rsp+0x10],rax
    2547:	mov    rcx,rax
    254a:	mov    r8,QWORD PTR [rsp+0x28]
    254f:	mov    QWORD PTR [rsp+0x18],r8
    2554:	mov    r9,QWORD PTR [rsp+0x30]
    2559:	mov    QWORD PTR [rsp+0x20],r9
    255e:	mov    edx,0x1
    2563:	mov    rsi,r12
    2566:	mov    rdi,r13
    2569:	call   256e <botlish_fn_19+0x82>
			256a: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    256e:	test   rax,rax
    2571:	jne    258d <botlish_fn_19+0xa1>
    2577:	xor    rax,rax
    257a:	mov    r12,QWORD PTR [rsp+0x40]
    257f:	mov    r13,QWORD PTR [rsp+0x48]
    2584:	add    rsp,0x50
    2588:	mov    rsp,rbp
    258b:	pop    rbp
    258c:	ret
    258d:	mov    r12,QWORD PTR [rsp+0x40]
    2592:	mov    r13,QWORD PTR [rsp+0x48]
    2597:	add    rsp,0x50
    259b:	mov    rsp,rbp
    259e:	pop    rbp
    259f:	ret

00000000000025a0 <botlish_entry_19: csv_parse<str>>:
    25a0:	push   rbp
    25a1:	mov    rbp,rsp
    25a4:	mov    rsi,QWORD PTR [rdx]
    25a7:	call   25ac <botlish_entry_19+0xc>
			25a8: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    25ac:	mov    rsp,rbp
    25af:	pop    rbp
    25b0:	ret

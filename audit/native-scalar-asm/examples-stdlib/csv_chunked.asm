; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10142  (per function: 68 195 534 534 534 534 501 421 524 524 365 430 585 1063 352 799 833 537 612 197)
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
     8df:	mov    rbx,rdx
     8e2:	mov    r14,rdi
     8e5:	mov    QWORD PTR [rsp],rsi
     8e9:	mov    QWORD PTR [rsp+0x8],rcx
     8ee:	mov    r12,rcx
     8f1:	mov    QWORD PTR [rsp+0x10],r8
     8f6:	mov    r13,rsi
     8f9:	mov    r15,r8
     8fc:	mov    rsi,r13
     8ff:	mov    rdi,r14
     902:	call   907 <botlish_fn_6+0x49>
			903: R_X86_64_PLT32	rt_list_len-0x4
     907:	sar    rax,1
     90a:	cmp    rbx,rax
     90d:	jge    a42 <botlish_fn_6+0x184>
     913:	mov    rcx,QWORD PTR [r13+0x8]
     917:	mov    rax,rbx
     91a:	shl    rax,1
     91d:	or     rax,0x1
     921:	sar    rax,1
     924:	cmp    rax,rcx
     927:	jb     953 <botlish_fn_6+0x95>
     92d:	mov    rdx,rbx
     930:	shl    rdx,1
     933:	or     rdx,0x1
     937:	mov    rsi,r13
     93a:	mov    rdi,r14
     93d:	call   942 <botlish_fn_6+0x84>
			93e: R_X86_64_PLT32	rt_list_get-0x4
     942:	test   rax,rax
     945:	je     9be <botlish_fn_6+0x100>
     94b:	mov    rsi,rax
     94e:	jmp    95e <botlish_fn_6+0xa0>
     953:	mov    rcx,QWORD PTR [r13+0x10]
     957:	mov    rax,QWORD PTR [rcx+rax*8]
     95b:	mov    rsi,rax
     95e:	xor    eax,eax
     960:	test   rsi,0x7
     967:	jne    976 <botlish_fn_6+0xb8>
     96d:	movzx  rax,BYTE PTR [rsi]
     971:	cmp    al,0x8
     973:	sete   al
     976:	test   al,al
     978:	jne    998 <botlish_fn_6+0xda>
     97e:	mov    rdi,r14
     981:	mov    rax,QWORD PTR [rdi+0x10]
     985:	mov    rcx,QWORD PTR [rax+0x8]
     989:	mov    edx,0x8
     98e:	call   993 <botlish_fn_6+0xd5>
			98f: R_X86_64_PLT32	rt_type_error-0x4
     993:	jmp    9be <botlish_fn_6+0x100>
     998:	mov    rcx,rsi
     99b:	mov    r8d,0x1
     9a1:	mov    r9d,0x81
     9a7:	mov    rdx,r15
     9aa:	mov    rsi,r12
     9ad:	mov    rdi,r14
     9b0:	call   9b5 <botlish_fn_6+0xf7>
			9b1: R_X86_64_PLT32	rt_mutarray_copy-0x4
     9b5:	test   rax,rax
     9b8:	jne    9e3 <botlish_fn_6+0x125>
     9be:	xor    rax,rax
     9c1:	mov    rbx,QWORD PTR [rsp+0x20]
     9c6:	mov    r12,QWORD PTR [rsp+0x28]
     9cb:	mov    r13,QWORD PTR [rsp+0x30]
     9d0:	mov    r14,QWORD PTR [rsp+0x38]
     9d5:	mov    r15,QWORD PTR [rsp+0x40]
     9da:	add    rsp,0x50
     9de:	mov    rsp,rbp
     9e1:	pop    rbp
     9e2:	ret
     9e3:	mov    QWORD PTR [rsp+0x18],0x81
     9ec:	mov    rsi,r15
     9ef:	test   rsi,0x1
     9f6:	je     a15 <botlish_fn_6+0x157>
     9fc:	mov    rsi,r15
     9ff:	mov    rax,rsi
     a02:	add    rax,0x80
     a08:	seto   r8b
     a0c:	test   r8b,r8b
     a0f:	je     a25 <botlish_fn_6+0x167>
     a15:	mov    edx,0x81
     a1a:	mov    rsi,r15
     a1d:	mov    rdi,r14
     a20:	call   a25 <botlish_fn_6+0x167>
			a21: R_X86_64_PLT32	rt_int_add-0x4
     a25:	mov    QWORD PTR [rsp],r13
     a29:	mov    QWORD PTR [rsp+0x8],r12
     a2e:	mov    QWORD PTR [rsp+0x10],rax
     a33:	add    rbx,0x1
     a3a:	mov    r15,rax
     a3d:	jmp    8fc <botlish_fn_6+0x3e>
     a42:	mov    rax,r15
     a45:	mov    rbx,QWORD PTR [rsp+0x20]
     a4a:	mov    r12,QWORD PTR [rsp+0x28]
     a4f:	mov    r13,QWORD PTR [rsp+0x30]
     a54:	mov    r14,QWORD PTR [rsp+0x38]
     a59:	mov    r15,QWORD PTR [rsp+0x40]
     a5e:	add    rsp,0x50
     a62:	mov    rsp,rbp
     a65:	pop    rbp
     a66:	ret

0000000000000a67 <botlish_entry_6: chunked_copy_chunks<List[never], int, mutarray, int>>:
     a67:	push   rbp
     a68:	mov    rbp,rsp
     a6b:	mov    rsi,QWORD PTR [rdx]
     a6e:	mov    r8,QWORD PTR [rdx+0x8]
     a72:	mov    r9,r8
     a75:	mov    rcx,QWORD PTR [rdx+0x10]
     a79:	mov    r8,QWORD PTR [rdx+0x18]
     a7d:	mov    rdx,r9
     a80:	sar    rdx,1
     a83:	call   a88 <botlish_entry_6+0x21>
			a84: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_copy_chunks<List[never], int, mutarray, int>
     a88:	mov    rsp,rbp
     a8b:	pop    rbp
     a8c:	ret

0000000000000a8d <botlish_fn_7: chunked_copy_chunks<List[mutarray], int, mutarray, int>>:
     a8d:	push   rbp
     a8e:	mov    rbp,rsp
     a91:	sub    rsp,0x50
     a95:	mov    QWORD PTR [rsp+0x20],rbx
     a9a:	mov    QWORD PTR [rsp+0x28],r12
     a9f:	mov    QWORD PTR [rsp+0x30],r13
     aa4:	mov    QWORD PTR [rsp+0x38],r14
     aa9:	mov    QWORD PTR [rsp+0x40],r15
     aae:	mov    rbx,rdx
     ab1:	mov    r14,rdi
     ab4:	mov    QWORD PTR [rsp],rsi
     ab8:	mov    QWORD PTR [rsp+0x8],rcx
     abd:	mov    r13,rcx
     ac0:	mov    QWORD PTR [rsp+0x10],r8
     ac5:	mov    r12,rsi
     ac8:	mov    r15,r8
     acb:	mov    rsi,r12
     ace:	mov    rdi,r14
     ad1:	call   ad6 <botlish_fn_7+0x49>
			ad2: R_X86_64_PLT32	rt_list_len-0x4
     ad6:	sar    rax,1
     ad9:	cmp    rbx,rax
     adc:	jge    bcb <botlish_fn_7+0x13e>
     ae2:	mov    rdx,QWORD PTR [r12+0x8]
     ae7:	mov    rcx,rbx
     aea:	shl    rcx,1
     aed:	or     rcx,0x1
     af1:	sar    rcx,1
     af4:	cmp    rcx,rdx
     af7:	jb     b23 <botlish_fn_7+0x96>
     afd:	mov    rdx,rbx
     b00:	shl    rdx,1
     b03:	or     rdx,0x1
     b07:	mov    rsi,r12
     b0a:	mov    rdi,r14
     b0d:	call   b12 <botlish_fn_7+0x85>
			b0e: R_X86_64_PLT32	rt_list_get-0x4
     b12:	test   rax,rax
     b15:	je     b4f <botlish_fn_7+0xc2>
     b1b:	mov    rcx,rax
     b1e:	jmp    b2c <botlish_fn_7+0x9f>
     b23:	mov    rax,QWORD PTR [r12+0x10]
     b28:	mov    rcx,QWORD PTR [rax+rcx*8]
     b2c:	mov    r8d,0x1
     b32:	mov    r9d,0x81
     b38:	mov    rdx,r15
     b3b:	mov    rsi,r13
     b3e:	mov    rdi,r14
     b41:	call   b46 <botlish_fn_7+0xb9>
			b42: R_X86_64_PLT32	rt_mutarray_copy-0x4
     b46:	test   rax,rax
     b49:	jne    b74 <botlish_fn_7+0xe7>
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
     b87:	je     ba1 <botlish_fn_7+0x114>
     b8d:	mov    rax,rsi
     b90:	add    rax,0x80
     b96:	seto   cl
     b99:	test   cl,cl
     b9b:	je     bae <botlish_fn_7+0x121>
     ba1:	mov    edx,0x81
     ba6:	mov    rdi,r14
     ba9:	call   bae <botlish_fn_7+0x121>
			baa: R_X86_64_PLT32	rt_int_add-0x4
     bae:	mov    QWORD PTR [rsp],r12
     bb2:	mov    QWORD PTR [rsp+0x8],r13
     bb7:	mov    QWORD PTR [rsp+0x10],rax
     bbc:	add    rbx,0x1
     bc3:	mov    r15,rax
     bc6:	jmp    acb <botlish_fn_7+0x3e>
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
     bf7:	mov    r8,QWORD PTR [rdx+0x8]
     bfb:	mov    r9,r8
     bfe:	mov    rcx,QWORD PTR [rdx+0x10]
     c02:	mov    r8,QWORD PTR [rdx+0x18]
     c06:	mov    rdx,r9
     c09:	sar    rdx,1
     c0c:	call   c11 <botlish_entry_7+0x21>
			c0d: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<List[mutarray], int, mutarray, int>
     c11:	mov    rsp,rbp
     c14:	pop    rbp
     c15:	ret
	...

0000000000000c18 <botlish_fn_8: chunked_finish<list[List[never], mutarray, int]>>:
     c18:	push   rbp
     c19:	mov    rbp,rsp
     c1c:	sub    rsp,0x70
     c20:	mov    QWORD PTR [rsp+0x40],rbx
     c25:	mov    QWORD PTR [rsp+0x48],r12
     c2a:	mov    QWORD PTR [rsp+0x50],r13
     c2f:	mov    QWORD PTR [rsp+0x58],r14
     c34:	mov    QWORD PTR [rsp+0x60],r15
     c39:	mov    r13,rdi
     c3c:	mov    QWORD PTR [rsp+0x28],0x0
     c45:	mov    QWORD PTR [rsp],rsi
     c49:	mov    r15,rsi
     c4c:	mov    QWORD PTR [rsp+0x8],rdx
     c51:	mov    r14,rdx
     c54:	mov    QWORD PTR [rsp+0x10],rcx
     c59:	mov    r12,rcx
     c5c:	mov    rsi,r15
     c5f:	mov    rdi,r13
     c62:	call   c67 <botlish_fn_8+0x4f>
			c63: R_X86_64_PLT32	rt_list_len-0x4
     c67:	mov    QWORD PTR [rsp+0x18],rax
     c6c:	mov    QWORD PTR [rsp+0x20],0x81
     c75:	test   rax,0x1
     c7b:	mov    rsi,rax
     c7e:	je     ca8 <botlish_fn_8+0x90>
     c84:	mov    rax,rsi
     c87:	sar    rax,1
     c8a:	imul   QWORD PTR [rip+0x13f]        # dd0 <botlish_fn_8+0x1b8>
     c91:	seto   cl
     c94:	or     rax,0x1
     c98:	test   cl,cl
     c9a:	jne    ca8 <botlish_fn_8+0x90>
     ca0:	mov    rsi,rax
     ca3:	jmp    cb8 <botlish_fn_8+0xa0>
     ca8:	mov    edx,0x81
     cad:	mov    rdi,r13
     cb0:	call   cb5 <botlish_fn_8+0x9d>
			cb1: R_X86_64_PLT32	rt_int_mul-0x4
     cb5:	mov    rsi,rax
     cb8:	mov    QWORD PTR [rsp+0x18],rsi
     cbd:	mov    rax,rsi
     cc0:	and    rax,r12
     cc3:	test   rax,0x1
     cc9:	je     ce5 <botlish_fn_8+0xcd>
     ccf:	lea    rcx,[r12-0x1]
     cd4:	mov    rbx,rsi
     cd7:	add    rbx,rcx
     cda:	seto   al
     cdd:	test   al,al
     cdf:	je     cf3 <botlish_fn_8+0xdb>
     ce5:	mov    rdx,r12
     ce8:	mov    rdi,r13
     ceb:	call   cf0 <botlish_fn_8+0xd8>
			cec: R_X86_64_PLT32	rt_int_add-0x4
     cf0:	mov    rbx,rax
     cf3:	mov    QWORD PTR [rsp+0x18],rbx
     cf8:	mov    rsi,rbx
     cfb:	mov    rdi,r13
     cfe:	call   d03 <botlish_fn_8+0xeb>
			cff: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     d03:	mov    rcx,rax
     d06:	mov    QWORD PTR [rsp+0x30],rax
     d0b:	test   rax,rcx
     d0e:	je     d87 <botlish_fn_8+0x16f>
     d14:	mov    rax,QWORD PTR [rsp+0x30]
     d19:	mov    QWORD PTR [rsp+0x20],rax
     d1e:	mov    r8d,0x1
     d24:	mov    QWORD PTR [rsp+0x28],0x1
     d2d:	xor    rdx,rdx
     d30:	mov    rsi,r15
     d33:	mov    rcx,QWORD PTR [rsp+0x30]
     d38:	mov    rdi,r13
     d3b:	call   d40 <botlish_fn_8+0x128>
			d3c: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_copy_chunks<List[never], int, mutarray, int>
     d40:	test   rax,rax
     d43:	mov    rdx,rax
     d46:	je     d87 <botlish_fn_8+0x16f>
     d4c:	mov    r8d,0x1
     d52:	mov    rcx,r14
     d55:	mov    r9,r12
     d58:	mov    rsi,QWORD PTR [rsp+0x30]
     d5d:	mov    rdi,r13
     d60:	call   d65 <botlish_fn_8+0x14d>
			d61: R_X86_64_PLT32	rt_mutarray_copy-0x4
     d65:	test   rax,rax
     d68:	je     d87 <botlish_fn_8+0x16f>
     d6e:	mov    rdx,rbx
     d71:	mov    rsi,QWORD PTR [rsp+0x30]
     d76:	mov    rdi,r13
     d79:	call   d7e <botlish_fn_8+0x166>
			d7a: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     d7e:	test   rax,rax
     d81:	jne    dac <botlish_fn_8+0x194>
     d87:	xor    rax,rax
     d8a:	mov    rbx,QWORD PTR [rsp+0x40]
     d8f:	mov    r12,QWORD PTR [rsp+0x48]
     d94:	mov    r13,QWORD PTR [rsp+0x50]
     d99:	mov    r14,QWORD PTR [rsp+0x58]
     d9e:	mov    r15,QWORD PTR [rsp+0x60]
     da3:	add    rsp,0x70
     da7:	mov    rsp,rbp
     daa:	pop    rbp
     dab:	ret
     dac:	mov    rbx,QWORD PTR [rsp+0x40]
     db1:	mov    r12,QWORD PTR [rsp+0x48]
     db6:	mov    r13,QWORD PTR [rsp+0x50]
     dbb:	mov    r14,QWORD PTR [rsp+0x58]
     dc0:	mov    r15,QWORD PTR [rsp+0x60]
     dc5:	add    rsp,0x70
     dc9:	mov    rsp,rbp
     dcc:	pop    rbp
     dcd:	ret
     dce:	add    BYTE PTR [rax],al
     dd0:	add    BYTE PTR [rax],0x0
     dd3:	add    BYTE PTR [rax],al
     dd5:	add    BYTE PTR [rax],al
	...

0000000000000dd8 <botlish_entry_8: chunked_finish<list[List[never], mutarray, int]>>:
     dd8:	push   rbp
     dd9:	mov    rbp,rsp
     ddc:	mov    rsi,QWORD PTR [rdx]
     ddf:	mov    r8,QWORD PTR [rdx+0x8]
     de3:	mov    rcx,QWORD PTR [rdx+0x10]
     de7:	mov    rdx,r8
     dea:	call   def <botlish_entry_8+0x17>
			deb: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[List[never], mutarray, int]>
     def:	mov    rsp,rbp
     df2:	pop    rbp
     df3:	ret
     df4:	add    BYTE PTR [rax],al
	...

0000000000000df8 <botlish_fn_9: chunked_finish<list[List[mutarray], mutarray, int]>>:
     df8:	push   rbp
     df9:	mov    rbp,rsp
     dfc:	sub    rsp,0x70
     e00:	mov    QWORD PTR [rsp+0x40],rbx
     e05:	mov    QWORD PTR [rsp+0x48],r12
     e0a:	mov    QWORD PTR [rsp+0x50],r13
     e0f:	mov    QWORD PTR [rsp+0x58],r14
     e14:	mov    QWORD PTR [rsp+0x60],r15
     e19:	mov    r13,rdi
     e1c:	mov    QWORD PTR [rsp+0x28],0x0
     e25:	mov    QWORD PTR [rsp],rsi
     e29:	mov    r15,rsi
     e2c:	mov    QWORD PTR [rsp+0x8],rdx
     e31:	mov    r14,rdx
     e34:	mov    QWORD PTR [rsp+0x10],rcx
     e39:	mov    r12,rcx
     e3c:	mov    rsi,r15
     e3f:	mov    rdi,r13
     e42:	call   e47 <botlish_fn_9+0x4f>
			e43: R_X86_64_PLT32	rt_list_len-0x4
     e47:	mov    QWORD PTR [rsp+0x18],rax
     e4c:	mov    QWORD PTR [rsp+0x20],0x81
     e55:	test   rax,0x1
     e5b:	mov    rsi,rax
     e5e:	je     e88 <botlish_fn_9+0x90>
     e64:	mov    rax,rsi
     e67:	sar    rax,1
     e6a:	imul   QWORD PTR [rip+0x13f]        # fb0 <botlish_fn_9+0x1b8>
     e71:	seto   cl
     e74:	or     rax,0x1
     e78:	test   cl,cl
     e7a:	jne    e88 <botlish_fn_9+0x90>
     e80:	mov    rsi,rax
     e83:	jmp    e98 <botlish_fn_9+0xa0>
     e88:	mov    edx,0x81
     e8d:	mov    rdi,r13
     e90:	call   e95 <botlish_fn_9+0x9d>
			e91: R_X86_64_PLT32	rt_int_mul-0x4
     e95:	mov    rsi,rax
     e98:	mov    QWORD PTR [rsp+0x18],rsi
     e9d:	mov    rax,rsi
     ea0:	and    rax,r12
     ea3:	test   rax,0x1
     ea9:	je     ec5 <botlish_fn_9+0xcd>
     eaf:	lea    rcx,[r12-0x1]
     eb4:	mov    rbx,rsi
     eb7:	add    rbx,rcx
     eba:	seto   al
     ebd:	test   al,al
     ebf:	je     ed3 <botlish_fn_9+0xdb>
     ec5:	mov    rdx,r12
     ec8:	mov    rdi,r13
     ecb:	call   ed0 <botlish_fn_9+0xd8>
			ecc: R_X86_64_PLT32	rt_int_add-0x4
     ed0:	mov    rbx,rax
     ed3:	mov    QWORD PTR [rsp+0x18],rbx
     ed8:	mov    rsi,rbx
     edb:	mov    rdi,r13
     ede:	call   ee3 <botlish_fn_9+0xeb>
			edf: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     ee3:	mov    rcx,rax
     ee6:	mov    QWORD PTR [rsp+0x30],rax
     eeb:	test   rax,rcx
     eee:	je     f67 <botlish_fn_9+0x16f>
     ef4:	mov    rax,QWORD PTR [rsp+0x30]
     ef9:	mov    QWORD PTR [rsp+0x20],rax
     efe:	mov    r8d,0x1
     f04:	mov    QWORD PTR [rsp+0x28],0x1
     f0d:	xor    rdx,rdx
     f10:	mov    rsi,r15
     f13:	mov    rcx,QWORD PTR [rsp+0x30]
     f18:	mov    rdi,r13
     f1b:	call   f20 <botlish_fn_9+0x128>
			f1c: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<List[mutarray], int, mutarray, int>
     f20:	test   rax,rax
     f23:	mov    rdx,rax
     f26:	je     f67 <botlish_fn_9+0x16f>
     f2c:	mov    r8d,0x1
     f32:	mov    rcx,r14
     f35:	mov    r9,r12
     f38:	mov    rsi,QWORD PTR [rsp+0x30]
     f3d:	mov    rdi,r13
     f40:	call   f45 <botlish_fn_9+0x14d>
			f41: R_X86_64_PLT32	rt_mutarray_copy-0x4
     f45:	test   rax,rax
     f48:	je     f67 <botlish_fn_9+0x16f>
     f4e:	mov    rdx,rbx
     f51:	mov    rsi,QWORD PTR [rsp+0x30]
     f56:	mov    rdi,r13
     f59:	call   f5e <botlish_fn_9+0x166>
			f5a: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     f5e:	test   rax,rax
     f61:	jne    f8c <botlish_fn_9+0x194>
     f67:	xor    rax,rax
     f6a:	mov    rbx,QWORD PTR [rsp+0x40]
     f6f:	mov    r12,QWORD PTR [rsp+0x48]
     f74:	mov    r13,QWORD PTR [rsp+0x50]
     f79:	mov    r14,QWORD PTR [rsp+0x58]
     f7e:	mov    r15,QWORD PTR [rsp+0x60]
     f83:	add    rsp,0x70
     f87:	mov    rsp,rbp
     f8a:	pop    rbp
     f8b:	ret
     f8c:	mov    rbx,QWORD PTR [rsp+0x40]
     f91:	mov    r12,QWORD PTR [rsp+0x48]
     f96:	mov    r13,QWORD PTR [rsp+0x50]
     f9b:	mov    r14,QWORD PTR [rsp+0x58]
     fa0:	mov    r15,QWORD PTR [rsp+0x60]
     fa5:	add    rsp,0x70
     fa9:	mov    rsp,rbp
     fac:	pop    rbp
     fad:	ret
     fae:	add    BYTE PTR [rax],al
     fb0:	add    BYTE PTR [rax],0x0
     fb3:	add    BYTE PTR [rax],al
     fb5:	add    BYTE PTR [rax],al
	...

0000000000000fb8 <botlish_entry_9: chunked_finish<list[List[mutarray], mutarray, int]>>:
     fb8:	push   rbp
     fb9:	mov    rbp,rsp
     fbc:	mov    rsi,QWORD PTR [rdx]
     fbf:	mov    r8,QWORD PTR [rdx+0x8]
     fc3:	mov    rcx,QWORD PTR [rdx+0x10]
     fc7:	mov    rdx,r8
     fca:	call   fcf <botlish_entry_9+0x17>
			fcb: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
     fcf:	mov    rsp,rbp
     fd2:	pop    rbp
     fd3:	ret
     fd4:	add    BYTE PTR [rax],al
	...

0000000000000fd8 <botlish_fn_10: peek<str, int>>:
     fd8:	push   rbp
     fd9:	mov    rbp,rsp
     fdc:	sub    rsp,0x40
     fe0:	mov    QWORD PTR [rsp+0x20],rbx
     fe5:	mov    QWORD PTR [rsp+0x28],r12
     fea:	mov    QWORD PTR [rsp+0x30],r13
     fef:	mov    r13,rdi
     ff2:	mov    QWORD PTR [rsp],rsi
     ff6:	mov    r12,rsi
     ff9:	mov    QWORD PTR [rsp+0x8],rdx
     ffe:	mov    rbx,rdx
    1001:	mov    rsi,r12
    1004:	mov    rdi,r13
    1007:	call   100c <botlish_fn_10+0x34>
			1008: R_X86_64_PLT32	rt_str_len-0x4
    100c:	mov    rcx,rbx
    100f:	and    rcx,rax
    1012:	mov    rdx,rax
    1015:	test   rcx,0x1
    101c:	jne    1042 <botlish_fn_10+0x6a>
    1022:	mov    rsi,rbx
    1025:	mov    rdi,r13
    1028:	call   102d <botlish_fn_10+0x55>
			1029: R_X86_64_PLT32	rt_int_cmp-0x4
    102d:	mov    ecx,0x2
    1032:	test   rax,rax
    1035:	cmovge rcx,QWORD PTR [rip+0xd3]        # 1110 <botlish_fn_10+0x138>
    103d:	jmp    1052 <botlish_fn_10+0x7a>
    1042:	mov    ecx,0x2
    1047:	cmp    rbx,rdx
    104a:	cmovge rcx,QWORD PTR [rip+0xbe]        # 1110 <botlish_fn_10+0x138>
    1052:	cmp    rcx,0x6
    1056:	je     10e6 <botlish_fn_10+0x10e>
    105c:	mov    QWORD PTR [rsp+0x10],0x3
    1065:	test   rbx,0x1
    106c:	je     1084 <botlish_fn_10+0xac>
    1072:	mov    rcx,rbx
    1075:	add    rcx,0x2
    1079:	seto   al
    107c:	test   al,al
    107e:	je     1097 <botlish_fn_10+0xbf>
    1084:	mov    edx,0x3
    1089:	mov    rsi,rbx
    108c:	mov    rdi,r13
    108f:	call   1094 <botlish_fn_10+0xbc>
			1090: R_X86_64_PLT32	rt_int_add-0x4
    1094:	mov    rcx,rax
    1097:	mov    QWORD PTR [rsp+0x10],rcx
    109c:	mov    rdx,rbx
    109f:	mov    rsi,r12
    10a2:	mov    rdi,r13
    10a5:	call   10aa <botlish_fn_10+0xd2>
			10a6: R_X86_64_PLT32	rt_substr-0x4
    10aa:	test   rax,rax
    10ad:	jne    10ce <botlish_fn_10+0xf6>
    10b3:	xor    rax,rax
    10b6:	mov    rbx,QWORD PTR [rsp+0x20]
    10bb:	mov    r12,QWORD PTR [rsp+0x28]
    10c0:	mov    r13,QWORD PTR [rsp+0x30]
    10c5:	add    rsp,0x40
    10c9:	mov    rsp,rbp
    10cc:	pop    rbp
    10cd:	ret
    10ce:	mov    rbx,QWORD PTR [rsp+0x20]
    10d3:	mov    r12,QWORD PTR [rsp+0x28]
    10d8:	mov    r13,QWORD PTR [rsp+0x30]
    10dd:	add    rsp,0x40
    10e1:	mov    rsp,rbp
    10e4:	pop    rbp
    10e5:	ret
    10e6:	mov    rdi,r13
    10e9:	mov    rax,QWORD PTR [rdi+0x10]
    10ed:	mov    rax,QWORD PTR [rax+0x10]
    10f1:	mov    rbx,QWORD PTR [rsp+0x20]
    10f6:	mov    r12,QWORD PTR [rsp+0x28]
    10fb:	mov    r13,QWORD PTR [rsp+0x30]
    1100:	add    rsp,0x40
    1104:	mov    rsp,rbp
    1107:	pop    rbp
    1108:	ret
    1109:	add    BYTE PTR [rax],al
    110b:	add    BYTE PTR [rax],al
    110d:	add    BYTE PTR [rax],al
    110f:	add    BYTE PTR [rsi],al
    1111:	add    BYTE PTR [rax],al
    1113:	add    BYTE PTR [rax],al
    1115:	add    BYTE PTR [rax],al
	...

0000000000001118 <botlish_entry_10: peek<str, int>>:
    1118:	push   rbp
    1119:	mov    rbp,rsp
    111c:	mov    rsi,QWORD PTR [rdx]
    111f:	mov    rdx,QWORD PTR [rdx+0x8]
    1123:	call   1128 <botlish_entry_10+0x10>
			1124: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    1128:	mov    rsp,rbp
    112b:	pop    rbp
    112c:	ret
    112d:	add    BYTE PTR [rax],al
	...

0000000000001130 <botlish_fn_11: peek<str, int>>:
    1130:	push   rbp
    1131:	mov    rbp,rsp
    1134:	sub    rsp,0x50
    1138:	mov    QWORD PTR [rsp+0x20],rbx
    113d:	mov    QWORD PTR [rsp+0x28],r12
    1142:	mov    QWORD PTR [rsp+0x30],r13
    1147:	mov    QWORD PTR [rsp+0x38],r14
    114c:	mov    QWORD PTR [rsp+0x40],r15
    1151:	mov    r12,rcx
    1154:	mov    r14,rdi
    1157:	mov    QWORD PTR [rsp],rsi
    115b:	mov    r13,rsi
    115e:	mov    QWORD PTR [rsp+0x8],rdx
    1163:	mov    rbx,rdx
    1166:	mov    rsi,r13
    1169:	mov    rdi,r14
    116c:	call   1171 <botlish_fn_11+0x41>
			116d: R_X86_64_PLT32	rt_str_len-0x4
    1171:	mov    rcx,rbx
    1174:	and    rcx,rax
    1177:	mov    rdx,rax
    117a:	test   rcx,0x1
    1181:	jne    11a7 <botlish_fn_11+0x77>
    1187:	mov    rsi,rbx
    118a:	mov    rdi,r14
    118d:	call   1192 <botlish_fn_11+0x62>
			118e: R_X86_64_PLT32	rt_int_cmp-0x4
    1192:	mov    ecx,0x2
    1197:	test   rax,rax
    119a:	cmovge rcx,QWORD PTR [rip+0x11e]        # 12c0 <botlish_fn_11+0x190>
    11a2:	jmp    11b7 <botlish_fn_11+0x87>
    11a7:	mov    ecx,0x2
    11ac:	cmp    rbx,rdx
    11af:	cmovge rcx,QWORD PTR [rip+0x109]        # 12c0 <botlish_fn_11+0x190>
    11b7:	cmp    rcx,0x6
    11bb:	je     127b <botlish_fn_11+0x14b>
    11c1:	mov    QWORD PTR [rsp+0x10],0x3
    11ca:	test   rbx,0x1
    11d1:	je     11f4 <botlish_fn_11+0xc4>
    11d7:	mov    rax,rbx
    11da:	add    rax,0x2
    11de:	seto   cl
    11e1:	test   cl,cl
    11e3:	jne    11f4 <botlish_fn_11+0xc4>
    11e9:	mov    rdi,r14
    11ec:	mov    r15,rax
    11ef:	jmp    120a <botlish_fn_11+0xda>
    11f4:	mov    edx,0x3
    11f9:	mov    rsi,rbx
    11fc:	mov    rdi,r14
    11ff:	call   1204 <botlish_fn_11+0xd4>
			1200: R_X86_64_PLT32	rt_int_add-0x4
    1204:	mov    r15,rax
    1207:	mov    rdi,r14
    120a:	mov    rdi,r14
    120d:	mov    rcx,r15
    1210:	mov    rdx,rbx
    1213:	mov    rsi,r13
    1216:	call   121b <botlish_fn_11+0xeb>
			1217: R_X86_64_PLT32	rt_str_region_check-0x4
    121b:	test   rax,rax
    121e:	jne    1249 <botlish_fn_11+0x119>
    1224:	xor    rax,rax
    1227:	mov    rbx,QWORD PTR [rsp+0x20]
    122c:	mov    r12,QWORD PTR [rsp+0x28]
    1231:	mov    r13,QWORD PTR [rsp+0x30]
    1236:	mov    r14,QWORD PTR [rsp+0x38]
    123b:	mov    r15,QWORD PTR [rsp+0x40]
    1240:	add    rsp,0x50
    1244:	mov    rsp,rbp
    1247:	pop    rbp
    1248:	ret
    1249:	mov    rcx,r12
    124c:	mov    QWORD PTR [rcx],rbx
    124f:	mov    rax,r15
    1252:	mov    QWORD PTR [rcx+0x8],rax
    1256:	mov    rax,r13
    1259:	mov    rbx,QWORD PTR [rsp+0x20]
    125e:	mov    r12,QWORD PTR [rsp+0x28]
    1263:	mov    r13,QWORD PTR [rsp+0x30]
    1268:	mov    r14,QWORD PTR [rsp+0x38]
    126d:	mov    r15,QWORD PTR [rsp+0x40]
    1272:	add    rsp,0x50
    1276:	mov    rsp,rbp
    1279:	pop    rbp
    127a:	ret
    127b:	mov    rcx,r12
    127e:	mov    rdi,r14
    1281:	mov    rax,QWORD PTR [rdi+0x10]
    1285:	mov    rax,QWORD PTR [rax+0x10]
    1289:	mov    QWORD PTR [rcx],0x1
    1290:	mov    QWORD PTR [rcx+0x8],0x1
    1298:	mov    rbx,QWORD PTR [rsp+0x20]
    129d:	mov    r12,QWORD PTR [rsp+0x28]
    12a2:	mov    r13,QWORD PTR [rsp+0x30]
    12a7:	mov    r14,QWORD PTR [rsp+0x38]
    12ac:	mov    r15,QWORD PTR [rsp+0x40]
    12b1:	add    rsp,0x50
    12b5:	mov    rsp,rbp
    12b8:	pop    rbp
    12b9:	ret
    12ba:	add    BYTE PTR [rax],al
    12bc:	add    BYTE PTR [rax],al
    12be:	add    BYTE PTR [rax],al
    12c0:	(bad)
    12c1:	add    BYTE PTR [rax],al
    12c3:	add    BYTE PTR [rax],al
    12c5:	add    BYTE PTR [rax],al
	...

00000000000012c8 <botlish_entry_11: peek<str, int>>:
    12c8:	push   rbp
    12c9:	mov    rbp,rsp
    12cc:	ud2

00000000000012ce <botlish_fn_12: scan_unquoted<str, int, int>>:
    12ce:	push   rbp
    12cf:	mov    rbp,rsp
    12d2:	sub    rsp,0x80
    12d9:	mov    QWORD PTR [rsp+0x50],rbx
    12de:	mov    QWORD PTR [rsp+0x58],r12
    12e3:	mov    QWORD PTR [rsp+0x60],r13
    12e8:	mov    QWORD PTR [rsp+0x68],r14
    12ed:	mov    QWORD PTR [rsp+0x70],r15
    12f2:	mov    QWORD PTR [rsp+0x30],rdi
    12f7:	mov    QWORD PTR [rsp+0x18],0x0
    1300:	mov    QWORD PTR [rsp],rsi
    1304:	mov    r15,rsi
    1307:	mov    QWORD PTR [rsp+0x8],rdx
    130c:	mov    r14,rdx
    130f:	mov    QWORD PTR [rsp+0x10],rcx
    1314:	lea    r13,[rsp+0x20]
    1319:	mov    QWORD PTR [rsp+0x38],rcx
    131e:	mov    rcx,r13
    1321:	mov    rdx,QWORD PTR [rsp+0x38]
    1326:	mov    rsi,r15
    1329:	mov    rdi,QWORD PTR [rsp+0x30]
    132e:	call   1333 <botlish_fn_12+0x65>
			132f: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1333:	mov    rsi,rax
    1336:	mov    QWORD PTR [rsp+0x40],rax
    133b:	test   rax,rsi
    133e:	je     1498 <botlish_fn_12+0x1ca>
    1344:	mov    rbx,QWORD PTR [rsp+0x20]
    1349:	mov    r12,QWORD PTR [rsp+0x28]
    134e:	mov    rdi,QWORD PTR [rsp+0x30]
    1353:	mov    rcx,QWORD PTR [rdi+0x10]
    1357:	mov    r8,QWORD PTR [rcx+0x10]
    135b:	mov    rcx,r12
    135e:	mov    rdx,rbx
    1361:	mov    rsi,QWORD PTR [rsp+0x40]
    1366:	call   136b <botlish_fn_12+0x9d>
			1367: R_X86_64_PLT32	rt_str_region_eq-0x4
    136b:	cmp    rax,0x6
    136f:	je     13b0 <botlish_fn_12+0xe2>
    1375:	mov    rdi,QWORD PTR [rsp+0x30]
    137a:	mov    rax,QWORD PTR [rdi+0x10]
    137e:	mov    r8,QWORD PTR [rax+0x18]
    1382:	mov    rcx,r12
    1385:	mov    rdx,rbx
    1388:	mov    rsi,QWORD PTR [rsp+0x40]
    138d:	call   1392 <botlish_fn_12+0xc4>
			138e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1392:	cmp    rax,0x6
    1396:	je     13a6 <botlish_fn_12+0xd8>
    139c:	mov    eax,0x2
    13a1:	jmp    13b5 <botlish_fn_12+0xe7>
    13a6:	mov    eax,0x6
    13ab:	jmp    13b5 <botlish_fn_12+0xe7>
    13b0:	mov    eax,0x6
    13b5:	cmp    rax,0x6
    13b9:	je     13fa <botlish_fn_12+0x12c>
    13bf:	mov    rdi,QWORD PTR [rsp+0x30]
    13c4:	mov    rax,QWORD PTR [rdi+0x10]
    13c8:	mov    r8,QWORD PTR [rax+0x20]
    13cc:	mov    rcx,r12
    13cf:	mov    rdx,rbx
    13d2:	mov    rsi,QWORD PTR [rsp+0x40]
    13d7:	call   13dc <botlish_fn_12+0x10e>
			13d8: R_X86_64_PLT32	rt_str_region_eq-0x4
    13dc:	cmp    rax,0x6
    13e0:	je     13f0 <botlish_fn_12+0x122>
    13e6:	mov    eax,0x2
    13eb:	jmp    13ff <botlish_fn_12+0x131>
    13f0:	mov    eax,0x6
    13f5:	jmp    13ff <botlish_fn_12+0x131>
    13fa:	mov    eax,0x6
    13ff:	cmp    rax,0x6
    1403:	je     147a <botlish_fn_12+0x1ac>
    1409:	mov    QWORD PTR [rsp+0x18],0x3
    1412:	mov    rsi,QWORD PTR [rsp+0x38]
    1417:	test   rsi,0x1
    141e:	je     1445 <botlish_fn_12+0x177>
    1424:	mov    rsi,QWORD PTR [rsp+0x38]
    1429:	mov    rax,rsi
    142c:	add    rax,0x2
    1430:	seto   sil
    1434:	test   sil,sil
    1437:	jne    1445 <botlish_fn_12+0x177>
    143d:	mov    rsi,r15
    1440:	jmp    145c <botlish_fn_12+0x18e>
    1445:	mov    edx,0x3
    144a:	mov    rsi,QWORD PTR [rsp+0x38]
    144f:	mov    rdi,QWORD PTR [rsp+0x30]
    1454:	call   1459 <botlish_fn_12+0x18b>
			1455: R_X86_64_PLT32	rt_int_add-0x4
    1459:	mov    rsi,r15
    145c:	mov    QWORD PTR [rsp],rsi
    1460:	mov    rdx,r14
    1463:	mov    QWORD PTR [rsp+0x8],rdx
    1468:	mov    QWORD PTR [rsp+0x10],rax
    146d:	mov    r15,rsi
    1470:	mov    QWORD PTR [rsp+0x38],rax
    1475:	jmp    131e <botlish_fn_12+0x50>
    147a:	mov    rdx,r14
    147d:	mov    rsi,r15
    1480:	mov    rdi,QWORD PTR [rsp+0x30]
    1485:	mov    rcx,QWORD PTR [rsp+0x38]
    148a:	call   148f <botlish_fn_12+0x1c1>
			148b: R_X86_64_PLT32	rt_substr-0x4
    148f:	test   rax,rax
    1492:	jne    14c3 <botlish_fn_12+0x1f5>
    1498:	xor    rdx,rdx
    149b:	mov    rax,rdx
    149e:	mov    rbx,QWORD PTR [rsp+0x50]
    14a3:	mov    r12,QWORD PTR [rsp+0x58]
    14a8:	mov    r13,QWORD PTR [rsp+0x60]
    14ad:	mov    r14,QWORD PTR [rsp+0x68]
    14b2:	mov    r15,QWORD PTR [rsp+0x70]
    14b7:	add    rsp,0x80
    14be:	mov    rsp,rbp
    14c1:	pop    rbp
    14c2:	ret
    14c3:	mov    rdx,QWORD PTR [rsp+0x38]
    14c8:	mov    rbx,QWORD PTR [rsp+0x50]
    14cd:	mov    r12,QWORD PTR [rsp+0x58]
    14d2:	mov    r13,QWORD PTR [rsp+0x60]
    14d7:	mov    r14,QWORD PTR [rsp+0x68]
    14dc:	mov    r15,QWORD PTR [rsp+0x70]
    14e1:	add    rsp,0x80
    14e8:	mov    rsp,rbp
    14eb:	pop    rbp
    14ec:	ret

00000000000014ed <botlish_entry_12: scan_unquoted<str, int, int>>:
    14ed:	push   rbp
    14ee:	mov    rbp,rsp
    14f1:	ud2

00000000000014f3 <botlish_fn_13: scan_quoted<str, int, str>>:
    14f3:	push   rbp
    14f4:	mov    rbp,rsp
    14f7:	sub    rsp,0xd0
    14fe:	mov    QWORD PTR [rsp+0xa0],rbx
    1506:	mov    QWORD PTR [rsp+0xa8],r12
    150e:	mov    QWORD PTR [rsp+0xb0],r13
    1516:	mov    QWORD PTR [rsp+0xb8],r14
    151e:	mov    QWORD PTR [rsp+0xc0],r15
    1526:	mov    r15,rdi
    1529:	mov    QWORD PTR [rsp+0x18],0x0
    1532:	mov    QWORD PTR [rsp+0x20],0x0
    153b:	mov    QWORD PTR [rsp],rsi
    153f:	mov    QWORD PTR [rsp+0x8],rdx
    1544:	mov    QWORD PTR [rsp+0x10],rcx
    1549:	mov    r13,rcx
    154c:	lea    r14,[rsp+0x68]
    1551:	lea    rbx,[rsp+0x28]
    1556:	mov    r12,rsi
    1559:	mov    QWORD PTR [rsp+0x88],rdx
    1561:	mov    rdx,QWORD PTR [rsp+0x88]
    1569:	mov    rsi,r12
    156c:	mov    rdi,r15
    156f:	call   1574 <botlish_fn_13+0x81>
			1570: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    1574:	test   rax,rax
    1577:	je     187b <botlish_fn_13+0x388>
    157d:	mov    QWORD PTR [rsp+0x18],rax
    1582:	mov    rdi,r15
    1585:	mov    QWORD PTR [rsp+0x90],rax
    158d:	mov    rsi,QWORD PTR [rdi+0x10]
    1591:	mov    rsi,QWORD PTR [rsi+0x28]
    1595:	mov    edx,0x1
    159a:	mov    ecx,0x3
    159f:	mov    r8,QWORD PTR [rsp+0x90]
    15a7:	call   15ac <botlish_fn_13+0xb9>
			15a8: R_X86_64_PLT32	rt_str_region_eq-0x4
    15ac:	cmp    rax,0x6
    15b0:	je     1670 <botlish_fn_13+0x17d>
    15b6:	mov    QWORD PTR [rsp+0x20],0x3
    15bf:	mov    rsi,QWORD PTR [rsp+0x88]
    15c7:	test   rsi,0x1
    15ce:	je     15f0 <botlish_fn_13+0xfd>
    15d4:	mov    r9,rsi
    15d7:	add    r9,0x2
    15db:	seto   r11b
    15df:	test   r11b,r11b
    15e2:	jne    15f0 <botlish_fn_13+0xfd>
    15e8:	mov    rsi,r9
    15eb:	jmp    1600 <botlish_fn_13+0x10d>
    15f0:	mov    edx,0x3
    15f5:	mov    rdi,r15
    15f8:	call   15fd <botlish_fn_13+0x10a>
			15f9: R_X86_64_PLT32	rt_int_add-0x4
    15fd:	mov    rsi,rax
    1600:	mov    QWORD PTR [rsp+0x8],rsi
    1605:	mov    QWORD PTR [rsp+0x88],rsi
    160d:	mov    QWORD PTR [rsp+0x68],0x0
    1616:	mov    QWORD PTR [rsp+0x70],r13
    161b:	mov    QWORD PTR [rsp+0x78],0x0
    1624:	mov    rax,QWORD PTR [rsp+0x90]
    162c:	mov    QWORD PTR [rsp+0x80],rax
    1634:	mov    esi,0x2
    1639:	mov    edx,0x4
    163e:	mov    rcx,r14
    1641:	mov    rdi,r15
    1644:	call   1649 <botlish_fn_13+0x156>
			1645: R_X86_64_PLT32	rt_construct-0x4
    1649:	test   rax,rax
    164c:	je     187b <botlish_fn_13+0x388>
    1652:	mov    QWORD PTR [rsp],r12
    1656:	mov    rsi,QWORD PTR [rsp+0x88]
    165e:	mov    QWORD PTR [rsp+0x8],rsi
    1663:	mov    QWORD PTR [rsp+0x10],rax
    1668:	mov    r13,rax
    166b:	jmp    1561 <botlish_fn_13+0x6e>
    1670:	mov    QWORD PTR [rsp+0x18],0x3
    1679:	mov    rsi,QWORD PTR [rsp+0x88]
    1681:	test   rsi,0x1
    1688:	je     16a8 <botlish_fn_13+0x1b5>
    168e:	mov    rsi,QWORD PTR [rsp+0x88]
    1696:	mov    rdx,rsi
    1699:	add    rdx,0x2
    169d:	seto   al
    16a0:	test   al,al
    16a2:	je     16c0 <botlish_fn_13+0x1cd>
    16a8:	mov    edx,0x3
    16ad:	mov    rsi,QWORD PTR [rsp+0x88]
    16b5:	mov    rdi,r15
    16b8:	call   16bd <botlish_fn_13+0x1ca>
			16b9: R_X86_64_PLT32	rt_int_add-0x4
    16bd:	mov    rdx,rax
    16c0:	mov    QWORD PTR [rsp+0x18],rdx
    16c5:	mov    rcx,rbx
    16c8:	mov    rsi,r12
    16cb:	mov    rdi,r15
    16ce:	call   16d3 <botlish_fn_13+0x1e0>
			16cf: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    16d3:	test   rax,rax
    16d6:	mov    rsi,rax
    16d9:	je     187b <botlish_fn_13+0x388>
    16df:	mov    rdx,QWORD PTR [rsp+0x28]
    16e4:	mov    rcx,QWORD PTR [rsp+0x30]
    16e9:	mov    rdi,r15
    16ec:	mov    rax,QWORD PTR [rdi+0x10]
    16f0:	mov    r8,QWORD PTR [rax+0x28]
    16f4:	call   16f9 <botlish_fn_13+0x206>
			16f5: R_X86_64_PLT32	rt_str_region_eq-0x4
    16f9:	cmp    rax,0x6
    16fd:	je     17c5 <botlish_fn_13+0x2d2>
    1703:	xor    rsi,rsi
    1706:	lea    rcx,[rsp+0x58]
    170b:	mov    QWORD PTR [rsp+0x58],0x0
    1714:	mov    QWORD PTR [rsp+0x60],r13
    1719:	mov    edx,0x2
    171e:	mov    rdi,r15
    1721:	call   1726 <botlish_fn_13+0x233>
			1722: R_X86_64_PLT32	rt_construct-0x4
    1726:	test   rax,rax
    1729:	je     187b <botlish_fn_13+0x388>
    172f:	mov    QWORD PTR [rsp],rax
    1733:	mov    rbx,rax
    1736:	mov    QWORD PTR [rsp+0x10],0x3
    173f:	mov    rsi,QWORD PTR [rsp+0x88]
    1747:	test   rsi,0x1
    174e:	je     1776 <botlish_fn_13+0x283>
    1754:	mov    rsi,QWORD PTR [rsp+0x88]
    175c:	mov    rdx,rsi
    175f:	add    rdx,0x2
    1763:	seto   al
    1766:	test   al,al
    1768:	jne    1776 <botlish_fn_13+0x283>
    176e:	mov    rax,rbx
    1771:	jmp    1791 <botlish_fn_13+0x29e>
    1776:	mov    edx,0x3
    177b:	mov    rsi,QWORD PTR [rsp+0x88]
    1783:	mov    rdi,r15
    1786:	call   178b <botlish_fn_13+0x298>
			1787: R_X86_64_PLT32	rt_int_add-0x4
    178b:	mov    rdx,rax
    178e:	mov    rax,rbx
    1791:	mov    rbx,QWORD PTR [rsp+0xa0]
    1799:	mov    r12,QWORD PTR [rsp+0xa8]
    17a1:	mov    r13,QWORD PTR [rsp+0xb0]
    17a9:	mov    r14,QWORD PTR [rsp+0xb8]
    17b1:	mov    r15,QWORD PTR [rsp+0xc0]
    17b9:	add    rsp,0xd0
    17c0:	mov    rsp,rbp
    17c3:	pop    rbp
    17c4:	ret
    17c5:	mov    QWORD PTR [rsp+0x18],0x5
    17ce:	mov    rsi,QWORD PTR [rsp+0x88]
    17d6:	test   rsi,0x1
    17dd:	je     180d <botlish_fn_13+0x31a>
    17e3:	mov    rsi,QWORD PTR [rsp+0x88]
    17eb:	mov    rax,rsi
    17ee:	add    rax,0x4
    17f2:	seto   cl
    17f5:	test   cl,cl
    17f7:	jne    180d <botlish_fn_13+0x31a>
    17fd:	mov    rsi,rax
    1800:	mov    QWORD PTR [rsp+0x88],rax
    1808:	jmp    182d <botlish_fn_13+0x33a>
    180d:	mov    edx,0x5
    1812:	mov    rsi,QWORD PTR [rsp+0x88]
    181a:	mov    rdi,r15
    181d:	call   1822 <botlish_fn_13+0x32f>
			181e: R_X86_64_PLT32	rt_int_add-0x4
    1822:	mov    rsi,rax
    1825:	mov    QWORD PTR [rsp+0x88],rax
    182d:	mov    QWORD PTR [rsp+0x8],rsi
    1832:	mov    rdi,r15
    1835:	mov    rsi,QWORD PTR [rdi+0x10]
    1839:	mov    rsi,QWORD PTR [rsi+0x28]
    183d:	mov    QWORD PTR [rsp+0x18],rsi
    1842:	lea    rcx,[rsp+0x38]
    1847:	mov    QWORD PTR [rsp+0x38],0x0
    1850:	mov    QWORD PTR [rsp+0x40],r13
    1855:	mov    QWORD PTR [rsp+0x48],0x0
    185e:	mov    QWORD PTR [rsp+0x50],rsi
    1863:	mov    esi,0x2
    1868:	mov    edx,0x4
    186d:	call   1872 <botlish_fn_13+0x37f>
			186e: R_X86_64_PLT32	rt_construct-0x4
    1872:	test   rax,rax
    1875:	jne    18b5 <botlish_fn_13+0x3c2>
    187b:	xor    rdx,rdx
    187e:	mov    rax,rdx
    1881:	mov    rbx,QWORD PTR [rsp+0xa0]
    1889:	mov    r12,QWORD PTR [rsp+0xa8]
    1891:	mov    r13,QWORD PTR [rsp+0xb0]
    1899:	mov    r14,QWORD PTR [rsp+0xb8]
    18a1:	mov    r15,QWORD PTR [rsp+0xc0]
    18a9:	add    rsp,0xd0
    18b0:	mov    rsp,rbp
    18b3:	pop    rbp
    18b4:	ret
    18b5:	mov    QWORD PTR [rsp],r12
    18b9:	mov    rsi,QWORD PTR [rsp+0x88]
    18c1:	mov    QWORD PTR [rsp+0x8],rsi
    18c6:	mov    QWORD PTR [rsp+0x10],rax
    18cb:	mov    r13,rax
    18ce:	jmp    1561 <botlish_fn_13+0x6e>

00000000000018d3 <botlish_entry_13: scan_quoted<str, int, str>>:
    18d3:	push   rbp
    18d4:	mov    rbp,rsp
    18d7:	ud2

00000000000018d9 <botlish_fn_14: scan_field<str, int>>:
    18d9:	push   rbp
    18da:	mov    rbp,rsp
    18dd:	sub    rsp,0x50
    18e1:	mov    QWORD PTR [rsp+0x30],rbx
    18e6:	mov    QWORD PTR [rsp+0x38],r12
    18eb:	mov    QWORD PTR [rsp+0x40],r13
    18f0:	mov    r12,rdi
    18f3:	mov    r13,rdx
    18f6:	mov    QWORD PTR [rsp+0x10],0x0
    18ff:	mov    QWORD PTR [rsp],rsi
    1903:	mov    rbx,rsi
    1906:	mov    QWORD PTR [rsp+0x8],rdx
    190b:	lea    rcx,[rsp+0x18]
    1910:	mov    rdx,r13
    1913:	mov    rsi,rbx
    1916:	mov    rdi,r12
    1919:	call   191e <botlish_fn_14+0x45>
			191a: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    191e:	test   rax,rax
    1921:	mov    rsi,rax
    1924:	je     19ef <botlish_fn_14+0x116>
    192a:	mov    rdx,QWORD PTR [rsp+0x18]
    192f:	mov    rcx,QWORD PTR [rsp+0x20]
    1934:	mov    rdi,r12
    1937:	mov    rax,QWORD PTR [rdi+0x10]
    193b:	mov    r8,QWORD PTR [rax+0x28]
    193f:	call   1944 <botlish_fn_14+0x6b>
			1940: R_X86_64_PLT32	rt_str_region_eq-0x4
    1944:	cmp    rax,0x6
    1948:	je     1980 <botlish_fn_14+0xa7>
    194e:	mov    rcx,r13
    1951:	mov    rsi,rbx
    1954:	mov    rdi,r12
    1957:	mov    rdx,rcx
    195a:	call   195f <botlish_fn_14+0x86>
			195b: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_unquoted<str, int, int>
    195f:	test   rax,rax
    1962:	je     19ef <botlish_fn_14+0x116>
    1968:	mov    rbx,QWORD PTR [rsp+0x30]
    196d:	mov    r12,QWORD PTR [rsp+0x38]
    1972:	mov    r13,QWORD PTR [rsp+0x40]
    1977:	add    rsp,0x50
    197b:	mov    rsp,rbp
    197e:	pop    rbp
    197f:	ret
    1980:	mov    rcx,r13
    1983:	mov    QWORD PTR [rsp+0x10],0x3
    198c:	test   rcx,0x1
    1993:	jne    19a1 <botlish_fn_14+0xc8>
    1999:	mov    r13,rcx
    199c:	jmp    19b6 <botlish_fn_14+0xdd>
    19a1:	mov    rdx,rcx
    19a4:	add    rdx,0x2
    19a8:	mov    r13,rcx
    19ab:	seto   al
    19ae:	test   al,al
    19b0:	je     19c9 <botlish_fn_14+0xf0>
    19b6:	mov    edx,0x3
    19bb:	mov    rsi,r13
    19be:	mov    rdi,r12
    19c1:	call   19c6 <botlish_fn_14+0xed>
			19c2: R_X86_64_PLT32	rt_int_add-0x4
    19c6:	mov    rdx,rax
    19c9:	mov    QWORD PTR [rsp+0x8],rdx
    19ce:	mov    rdi,r12
    19d1:	mov    rax,QWORD PTR [rdi+0x10]
    19d5:	mov    rcx,QWORD PTR [rax+0x10]
    19d9:	mov    QWORD PTR [rsp+0x10],rcx
    19de:	mov    rsi,rbx
    19e1:	call   19e6 <botlish_fn_14+0x10d>
			19e2: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_quoted<str, int, str>
    19e6:	test   rax,rax
    19e9:	jne    1a0d <botlish_fn_14+0x134>
    19ef:	xor    rdx,rdx
    19f2:	mov    rax,rdx
    19f5:	mov    rbx,QWORD PTR [rsp+0x30]
    19fa:	mov    r12,QWORD PTR [rsp+0x38]
    19ff:	mov    r13,QWORD PTR [rsp+0x40]
    1a04:	add    rsp,0x50
    1a08:	mov    rsp,rbp
    1a0b:	pop    rbp
    1a0c:	ret
    1a0d:	mov    rbx,QWORD PTR [rsp+0x30]
    1a12:	mov    r12,QWORD PTR [rsp+0x38]
    1a17:	mov    r13,QWORD PTR [rsp+0x40]
    1a1c:	add    rsp,0x50
    1a20:	mov    rsp,rbp
    1a23:	pop    rbp
    1a24:	ret

0000000000001a25 <botlish_entry_14: scan_field<str, int>>:
    1a25:	push   rbp
    1a26:	mov    rbp,rsp
    1a29:	ud2

0000000000001a2b <botlish_fn_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1a2b:	push   rbp
    1a2c:	mov    rbp,rsp
    1a2f:	sub    rsp,0xa0
    1a36:	mov    QWORD PTR [rsp+0x70],rbx
    1a3b:	mov    QWORD PTR [rsp+0x78],r12
    1a40:	mov    QWORD PTR [rsp+0x80],r13
    1a48:	mov    QWORD PTR [rsp+0x88],r14
    1a50:	mov    QWORD PTR [rsp+0x90],r15
    1a58:	mov    r13,rdi
    1a5b:	mov    QWORD PTR [rsp+0x28],0x0
    1a64:	mov    QWORD PTR [rsp],rsi
    1a68:	mov    r15,rsi
    1a6b:	mov    QWORD PTR [rsp+0x8],rdx
    1a70:	mov    QWORD PTR [rsp+0x10],rcx
    1a75:	mov    QWORD PTR [rsp+0x50],rcx
    1a7a:	mov    QWORD PTR [rsp+0x18],r8
    1a7f:	mov    r12,r8
    1a82:	mov    QWORD PTR [rsp+0x20],r9
    1a87:	mov    rbx,r9
    1a8a:	mov    rsi,r15
    1a8d:	mov    rdi,r13
    1a90:	call   1a95 <botlish_fn_15+0x6a>
			1a91: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1a95:	test   rax,rax
    1a98:	je     1ccc <botlish_fn_15+0x2a1>
    1a9e:	mov    QWORD PTR [rsp+0x8],rax
    1aa3:	mov    r8,rax
    1aa6:	mov    QWORD PTR [rsp+0x28],rdx
    1aab:	mov    r14,rdx
    1aae:	lea    r9,[rsp+0x30]
    1ab3:	mov    rcx,rbx
    1ab6:	mov    rdx,r12
    1ab9:	mov    rsi,QWORD PTR [rsp+0x50]
    1abe:	mov    rdi,r13
    1ac1:	call   1ac6 <botlish_fn_15+0x9b>
			1ac2: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<list[List[never], mutarray, int], str>
    1ac6:	test   rax,rax
    1ac9:	je     1ccc <botlish_fn_15+0x2a1>
    1acf:	mov    QWORD PTR [rsp+0x8],rax
    1ad4:	mov    QWORD PTR [rsp+0x68],rax
    1ad9:	mov    rdx,QWORD PTR [rsp+0x30]
    1ade:	mov    QWORD PTR [rsp+0x10],rdx
    1ae3:	mov    QWORD PTR [rsp+0x60],rdx
    1ae8:	mov    rcx,QWORD PTR [rsp+0x38]
    1aed:	mov    QWORD PTR [rsp+0x18],rcx
    1af2:	mov    QWORD PTR [rsp+0x58],rcx
    1af7:	lea    rcx,[rsp+0x40]
    1afc:	mov    rdx,r14
    1aff:	mov    rsi,r15
    1b02:	mov    rdi,r13
    1b05:	call   1b0a <botlish_fn_15+0xdf>
			1b06: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1b0a:	test   rax,rax
    1b0d:	mov    QWORD PTR [rsp+0x50],rax
    1b12:	je     1ccc <botlish_fn_15+0x2a1>
    1b18:	mov    r12,QWORD PTR [rsp+0x40]
    1b1d:	mov    rbx,QWORD PTR [rsp+0x48]
    1b22:	mov    rdi,r13
    1b25:	mov    rcx,QWORD PTR [rdi+0x10]
    1b29:	mov    r8,QWORD PTR [rcx+0x18]
    1b2d:	mov    rcx,rbx
    1b30:	mov    rdx,r12
    1b33:	mov    rsi,QWORD PTR [rsp+0x50]
    1b38:	call   1b3d <botlish_fn_15+0x112>
			1b39: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b3d:	cmp    rax,0x6
    1b41:	je     1c5b <botlish_fn_15+0x230>
    1b47:	mov    rdi,r13
    1b4a:	mov    rax,QWORD PTR [rdi+0x10]
    1b4e:	mov    r8,QWORD PTR [rax+0x20]
    1b52:	mov    rcx,rbx
    1b55:	mov    rdx,r12
    1b58:	mov    rsi,QWORD PTR [rsp+0x50]
    1b5d:	call   1b62 <botlish_fn_15+0x137>
			1b5e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b62:	cmp    rax,0x6
    1b66:	je     1bbd <botlish_fn_15+0x192>
    1b6c:	mov    rcx,QWORD PTR [rsp+0x58]
    1b71:	mov    rdx,QWORD PTR [rsp+0x60]
    1b76:	mov    rsi,QWORD PTR [rsp+0x68]
    1b7b:	mov    rdi,r13
    1b7e:	call   1b83 <botlish_fn_15+0x158>
			1b7f: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1b83:	test   rax,rax
    1b86:	je     1ccc <botlish_fn_15+0x2a1>
    1b8c:	mov    rdx,r14
    1b8f:	mov    rbx,QWORD PTR [rsp+0x70]
    1b94:	mov    r12,QWORD PTR [rsp+0x78]
    1b99:	mov    r13,QWORD PTR [rsp+0x80]
    1ba1:	mov    r14,QWORD PTR [rsp+0x88]
    1ba9:	mov    r15,QWORD PTR [rsp+0x90]
    1bb1:	add    rsp,0xa0
    1bb8:	mov    rsp,rbp
    1bbb:	pop    rbp
    1bbc:	ret
    1bbd:	mov    rcx,QWORD PTR [rsp+0x58]
    1bc2:	mov    rdx,QWORD PTR [rsp+0x60]
    1bc7:	mov    rsi,QWORD PTR [rsp+0x68]
    1bcc:	mov    rdi,r13
    1bcf:	call   1bd4 <botlish_fn_15+0x1a9>
			1bd0: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1bd4:	test   rax,rax
    1bd7:	je     1ccc <botlish_fn_15+0x2a1>
    1bdd:	mov    QWORD PTR [rsp],rax
    1be1:	mov    rbx,rax
    1be4:	mov    QWORD PTR [rsp+0x8],0x3
    1bed:	mov    rdx,r14
    1bf0:	test   rdx,0x1
    1bf7:	je     1c17 <botlish_fn_15+0x1ec>
    1bfd:	mov    rdx,r14
    1c00:	add    rdx,0x2
    1c04:	seto   al
    1c07:	test   al,al
    1c09:	jne    1c17 <botlish_fn_15+0x1ec>
    1c0f:	mov    rax,rbx
    1c12:	jmp    1c2d <botlish_fn_15+0x202>
    1c17:	mov    edx,0x3
    1c1c:	mov    rsi,r14
    1c1f:	mov    rdi,r13
    1c22:	call   1c27 <botlish_fn_15+0x1fc>
			1c23: R_X86_64_PLT32	rt_int_add-0x4
    1c27:	mov    rdx,rax
    1c2a:	mov    rax,rbx
    1c2d:	mov    rbx,QWORD PTR [rsp+0x70]
    1c32:	mov    r12,QWORD PTR [rsp+0x78]
    1c37:	mov    r13,QWORD PTR [rsp+0x80]
    1c3f:	mov    r14,QWORD PTR [rsp+0x88]
    1c47:	mov    r15,QWORD PTR [rsp+0x90]
    1c4f:	add    rsp,0xa0
    1c56:	mov    rsp,rbp
    1c59:	pop    rbp
    1c5a:	ret
    1c5b:	mov    rsi,r14
    1c5e:	mov    edx,0x3
    1c63:	mov    rcx,rdx
    1c66:	mov    QWORD PTR [rsp+0x20],0x3
    1c6f:	test   rsi,0x1
    1c76:	jne    1c84 <botlish_fn_15+0x259>
    1c7c:	mov    rdx,rcx
    1c7f:	jmp    1c99 <botlish_fn_15+0x26e>
    1c84:	mov    rdx,rsi
    1c87:	add    rdx,0x2
    1c8b:	seto   al
    1c8e:	test   al,al
    1c90:	je     1ca4 <botlish_fn_15+0x279>
    1c96:	mov    rdx,rcx
    1c99:	mov    rdi,r13
    1c9c:	call   1ca1 <botlish_fn_15+0x276>
			1c9d: R_X86_64_PLT32	rt_int_add-0x4
    1ca1:	mov    rdx,rax
    1ca4:	mov    QWORD PTR [rsp+0x20],rdx
    1ca9:	mov    rcx,QWORD PTR [rsp+0x68]
    1cae:	mov    rsi,r15
    1cb1:	mov    rdi,r13
    1cb4:	mov    r8,QWORD PTR [rsp+0x60]
    1cb9:	mov    r9,QWORD PTR [rsp+0x58]
    1cbe:	call   1cc3 <botlish_fn_15+0x298>
			1cbf: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[List[mutarray], mutarray, int]>
    1cc3:	test   rax,rax
    1cc6:	jne    1d00 <botlish_fn_15+0x2d5>
    1ccc:	xor    rdx,rdx
    1ccf:	mov    rax,rdx
    1cd2:	mov    rbx,QWORD PTR [rsp+0x70]
    1cd7:	mov    r12,QWORD PTR [rsp+0x78]
    1cdc:	mov    r13,QWORD PTR [rsp+0x80]
    1ce4:	mov    r14,QWORD PTR [rsp+0x88]
    1cec:	mov    r15,QWORD PTR [rsp+0x90]
    1cf4:	add    rsp,0xa0
    1cfb:	mov    rsp,rbp
    1cfe:	pop    rbp
    1cff:	ret
    1d00:	mov    rbx,QWORD PTR [rsp+0x70]
    1d05:	mov    r12,QWORD PTR [rsp+0x78]
    1d0a:	mov    r13,QWORD PTR [rsp+0x80]
    1d12:	mov    r14,QWORD PTR [rsp+0x88]
    1d1a:	mov    r15,QWORD PTR [rsp+0x90]
    1d22:	add    rsp,0xa0
    1d29:	mov    rsp,rbp
    1d2c:	pop    rbp
    1d2d:	ret

0000000000001d2e <botlish_entry_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1d2e:	push   rbp
    1d2f:	mov    rbp,rsp
    1d32:	ud2

0000000000001d34 <botlish_fn_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    1d34:	push   rbp
    1d35:	mov    rbp,rsp
    1d38:	sub    rsp,0xb0
    1d3f:	mov    QWORD PTR [rsp+0x80],rbx
    1d47:	mov    QWORD PTR [rsp+0x88],r12
    1d4f:	mov    QWORD PTR [rsp+0x90],r13
    1d57:	mov    QWORD PTR [rsp+0x98],r14
    1d5f:	mov    QWORD PTR [rsp+0xa0],r15
    1d67:	mov    QWORD PTR [rsp+0x50],rdi
    1d6c:	mov    QWORD PTR [rsp+0x28],0x0
    1d75:	mov    QWORD PTR [rsp],rsi
    1d79:	mov    QWORD PTR [rsp+0x8],rdx
    1d7e:	mov    QWORD PTR [rsp+0x10],rcx
    1d83:	mov    QWORD PTR [rsp+0x18],r8
    1d88:	mov    QWORD PTR [rsp+0x20],r9
    1d8d:	lea    r15,[rsp+0x30]
    1d92:	lea    rbx,[rsp+0x40]
    1d97:	mov    r12,rsi
    1d9a:	mov    r13,rcx
    1d9d:	mov    QWORD PTR [rsp+0x58],r8
    1da2:	mov    QWORD PTR [rsp+0x60],r9
    1da7:	mov    rsi,r12
    1daa:	mov    rdi,QWORD PTR [rsp+0x50]
    1daf:	call   1db4 <botlish_fn_16+0x80>
			1db0: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1db4:	mov    QWORD PTR [rsp+0x78],rdx
    1db9:	test   rax,rax
    1dbc:	je     1f17 <botlish_fn_16+0x1e3>
    1dc2:	mov    QWORD PTR [rsp+0x8],rax
    1dc7:	mov    rdx,QWORD PTR [rsp+0x78]
    1dcc:	mov    r8,rax
    1dcf:	mov    QWORD PTR [rsp+0x28],rdx
    1dd4:	mov    rcx,QWORD PTR [rsp+0x60]
    1dd9:	mov    rdx,QWORD PTR [rsp+0x58]
    1dde:	mov    rsi,r13
    1de1:	mov    rdi,QWORD PTR [rsp+0x50]
    1de6:	mov    r9,r15
    1de9:	call   1dee <botlish_fn_16+0xba>
			1dea: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[List[mutarray], mutarray, int], str>
    1dee:	test   rax,rax
    1df1:	je     1f17 <botlish_fn_16+0x1e3>
    1df7:	mov    QWORD PTR [rsp+0x8],rax
    1dfc:	mov    QWORD PTR [rsp+0x70],rax
    1e01:	mov    rdx,QWORD PTR [rsp+0x30]
    1e06:	mov    QWORD PTR [rsp+0x58],rdx
    1e0b:	mov    QWORD PTR [rsp+0x10],rdx
    1e10:	mov    rcx,QWORD PTR [rsp+0x38]
    1e15:	mov    QWORD PTR [rsp+0x18],rcx
    1e1a:	mov    QWORD PTR [rsp+0x60],rcx
    1e1f:	mov    rcx,rbx
    1e22:	mov    rdx,QWORD PTR [rsp+0x78]
    1e27:	mov    rsi,r12
    1e2a:	mov    rdi,QWORD PTR [rsp+0x50]
    1e2f:	call   1e34 <botlish_fn_16+0x100>
			1e30: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1e34:	test   rax,rax
    1e37:	mov    QWORD PTR [rsp+0x68],rax
    1e3c:	je     1f17 <botlish_fn_16+0x1e3>
    1e42:	mov    r13,QWORD PTR [rsp+0x40]
    1e47:	mov    r14,QWORD PTR [rsp+0x48]
    1e4c:	mov    rdi,QWORD PTR [rsp+0x50]
    1e51:	mov    rcx,QWORD PTR [rdi+0x10]
    1e55:	mov    r8,QWORD PTR [rcx+0x18]
    1e59:	mov    rcx,r14
    1e5c:	mov    rdx,r13
    1e5f:	mov    rsi,QWORD PTR [rsp+0x68]
    1e64:	call   1e69 <botlish_fn_16+0x135>
			1e65: R_X86_64_PLT32	rt_str_region_eq-0x4
    1e69:	cmp    rax,0x6
    1e6d:	je     1fdd <botlish_fn_16+0x2a9>
    1e73:	mov    rdi,QWORD PTR [rsp+0x50]
    1e78:	mov    rax,QWORD PTR [rdi+0x10]
    1e7c:	mov    r8,QWORD PTR [rax+0x20]
    1e80:	mov    rcx,r14
    1e83:	mov    rdx,r13
    1e86:	mov    rsi,QWORD PTR [rsp+0x68]
    1e8b:	call   1e90 <botlish_fn_16+0x15c>
			1e8c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1e90:	cmp    rax,0x6
    1e94:	je     1ef5 <botlish_fn_16+0x1c1>
    1e9a:	mov    rcx,QWORD PTR [rsp+0x60]
    1e9f:	mov    rdx,QWORD PTR [rsp+0x58]
    1ea4:	mov    rsi,QWORD PTR [rsp+0x70]
    1ea9:	mov    rdi,QWORD PTR [rsp+0x50]
    1eae:	call   1eb3 <botlish_fn_16+0x17f>
			1eaf: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1eb3:	test   rax,rax
    1eb6:	je     1f17 <botlish_fn_16+0x1e3>
    1ebc:	mov    rdx,QWORD PTR [rsp+0x78]
    1ec1:	mov    rbx,QWORD PTR [rsp+0x80]
    1ec9:	mov    r12,QWORD PTR [rsp+0x88]
    1ed1:	mov    r13,QWORD PTR [rsp+0x90]
    1ed9:	mov    r14,QWORD PTR [rsp+0x98]
    1ee1:	mov    r15,QWORD PTR [rsp+0xa0]
    1ee9:	add    rsp,0xb0
    1ef0:	mov    rsp,rbp
    1ef3:	pop    rbp
    1ef4:	ret
    1ef5:	mov    rcx,QWORD PTR [rsp+0x60]
    1efa:	mov    rdx,QWORD PTR [rsp+0x58]
    1eff:	mov    rsi,QWORD PTR [rsp+0x70]
    1f04:	mov    rdi,QWORD PTR [rsp+0x50]
    1f09:	call   1f0e <botlish_fn_16+0x1da>
			1f0a: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1f0e:	test   rax,rax
    1f11:	jne    1f51 <botlish_fn_16+0x21d>
    1f17:	xor    rdx,rdx
    1f1a:	mov    rax,rdx
    1f1d:	mov    rbx,QWORD PTR [rsp+0x80]
    1f25:	mov    r12,QWORD PTR [rsp+0x88]
    1f2d:	mov    r13,QWORD PTR [rsp+0x90]
    1f35:	mov    r14,QWORD PTR [rsp+0x98]
    1f3d:	mov    r15,QWORD PTR [rsp+0xa0]
    1f45:	add    rsp,0xb0
    1f4c:	mov    rsp,rbp
    1f4f:	pop    rbp
    1f50:	ret
    1f51:	mov    QWORD PTR [rsp],rax
    1f55:	mov    rbx,rax
    1f58:	mov    QWORD PTR [rsp+0x8],0x3
    1f61:	mov    rdx,QWORD PTR [rsp+0x78]
    1f66:	test   rdx,0x1
    1f6d:	je     1f8f <botlish_fn_16+0x25b>
    1f73:	mov    rdx,QWORD PTR [rsp+0x78]
    1f78:	add    rdx,0x2
    1f7c:	seto   al
    1f7f:	test   al,al
    1f81:	jne    1f8f <botlish_fn_16+0x25b>
    1f87:	mov    rax,rbx
    1f8a:	jmp    1fa9 <botlish_fn_16+0x275>
    1f8f:	mov    edx,0x3
    1f94:	mov    rsi,QWORD PTR [rsp+0x78]
    1f99:	mov    rdi,QWORD PTR [rsp+0x50]
    1f9e:	call   1fa3 <botlish_fn_16+0x26f>
			1f9f: R_X86_64_PLT32	rt_int_add-0x4
    1fa3:	mov    rdx,rax
    1fa6:	mov    rax,rbx
    1fa9:	mov    rbx,QWORD PTR [rsp+0x80]
    1fb1:	mov    r12,QWORD PTR [rsp+0x88]
    1fb9:	mov    r13,QWORD PTR [rsp+0x90]
    1fc1:	mov    r14,QWORD PTR [rsp+0x98]
    1fc9:	mov    r15,QWORD PTR [rsp+0xa0]
    1fd1:	add    rsp,0xb0
    1fd8:	mov    rsp,rbp
    1fdb:	pop    rbp
    1fdc:	ret
    1fdd:	mov    rsi,QWORD PTR [rsp+0x78]
    1fe2:	mov    edx,0x3
    1fe7:	mov    r10,rdx
    1fea:	mov    QWORD PTR [rsp+0x20],0x3
    1ff3:	test   rsi,0x1
    1ffa:	jne    2008 <botlish_fn_16+0x2d4>
    2000:	mov    rdx,r10
    2003:	jmp    201d <botlish_fn_16+0x2e9>
    2008:	mov    rdx,rsi
    200b:	add    rdx,0x2
    200f:	seto   al
    2012:	test   al,al
    2014:	je     202a <botlish_fn_16+0x2f6>
    201a:	mov    rdx,r10
    201d:	mov    rdi,QWORD PTR [rsp+0x50]
    2022:	call   2027 <botlish_fn_16+0x2f3>
			2023: R_X86_64_PLT32	rt_int_add-0x4
    2027:	mov    rdx,rax
    202a:	mov    QWORD PTR [rsp],r12
    202e:	mov    QWORD PTR [rsp+0x8],rdx
    2033:	mov    rsi,QWORD PTR [rsp+0x70]
    2038:	mov    QWORD PTR [rsp+0x10],rsi
    203d:	mov    rax,QWORD PTR [rsp+0x58]
    2042:	mov    QWORD PTR [rsp+0x18],rax
    2047:	mov    rcx,QWORD PTR [rsp+0x60]
    204c:	mov    QWORD PTR [rsp+0x20],rcx
    2051:	mov    r13,rsi
    2054:	jmp    1da7 <botlish_fn_16+0x73>

0000000000002059 <botlish_entry_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    2059:	push   rbp
    205a:	mov    rbp,rsp
    205d:	ud2

000000000000205f <botlish_fn_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    205f:	push   rbp
    2060:	mov    rbp,rsp
    2063:	sub    rsp,0xa0
    206a:	mov    QWORD PTR [rsp+0x70],rbx
    206f:	mov    QWORD PTR [rsp+0x78],r12
    2074:	mov    QWORD PTR [rsp+0x80],r13
    207c:	mov    QWORD PTR [rsp+0x88],r14
    2084:	mov    QWORD PTR [rsp+0x90],r15
    208c:	mov    r12,rdi
    208f:	mov    QWORD PTR [rsp+0x28],0x0
    2098:	mov    QWORD PTR [rsp+0x30],0x0
    20a1:	mov    QWORD PTR [rsp+0x38],0x0
    20aa:	mov    QWORD PTR [rsp],rsi
    20ae:	mov    rbx,rsi
    20b1:	mov    QWORD PTR [rsp+0x8],rdx
    20b6:	mov    QWORD PTR [rsp+0x60],rdx
    20bb:	mov    QWORD PTR [rsp+0x10],rcx
    20c0:	mov    r15,rcx
    20c3:	mov    QWORD PTR [rsp+0x18],r8
    20c8:	mov    r14,r8
    20cb:	mov    QWORD PTR [rsp+0x20],r9
    20d0:	mov    r13,r9
    20d3:	mov    rsi,rbx
    20d6:	mov    rdi,r12
    20d9:	call   20de <botlish_fn_17+0x7f>
			20da: R_X86_64_PLT32	rt_str_len-0x4
    20de:	mov    rdx,QWORD PTR [rsp+0x60]
    20e3:	mov    rcx,rdx
    20e6:	sar    rcx,1
    20e9:	sar    rax,1
    20ec:	cmp    rcx,rax
    20ef:	jge    21d4 <botlish_fn_17+0x175>
    20f5:	lea    rsi,[rsp+0x40]
    20fa:	mov    rdi,r12
    20fd:	call   2102 <botlish_fn_17+0xa3>
			20fe: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2102:	test   rax,rax
    2105:	je     21ee <botlish_fn_17+0x18f>
    210b:	mov    QWORD PTR [rsp+0x28],rax
    2110:	mov    rcx,rax
    2113:	mov    r8,QWORD PTR [rsp+0x40]
    2118:	mov    QWORD PTR [rsp+0x30],r8
    211d:	mov    r9,QWORD PTR [rsp+0x48]
    2122:	mov    QWORD PTR [rsp+0x38],r9
    2127:	mov    rdx,QWORD PTR [rsp+0x60]
    212c:	mov    rsi,rbx
    212f:	mov    rdi,r12
    2132:	call   2137 <botlish_fn_17+0xd8>
			2133: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    2137:	test   rax,rax
    213a:	je     21ee <botlish_fn_17+0x18f>
    2140:	mov    QWORD PTR [rsp+0x8],rax
    2145:	mov    r8,rax
    2148:	mov    QWORD PTR [rsp+0x28],rdx
    214d:	mov    QWORD PTR [rsp+0x60],rdx
    2152:	lea    r9,[rsp+0x50]
    2157:	mov    rcx,r13
    215a:	mov    rdx,r14
    215d:	mov    rsi,r15
    2160:	mov    rdi,r12
    2163:	call   2168 <botlish_fn_17+0x109>
			2164: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[List[never], mutarray, int], list>
    2168:	test   rax,rax
    216b:	je     21ee <botlish_fn_17+0x18f>
    2171:	mov    QWORD PTR [rsp+0x8],rax
    2176:	mov    rcx,rax
    2179:	mov    r8,QWORD PTR [rsp+0x50]
    217e:	mov    QWORD PTR [rsp+0x10],r8
    2183:	mov    r9,QWORD PTR [rsp+0x58]
    2188:	mov    QWORD PTR [rsp+0x18],r9
    218d:	mov    rdx,QWORD PTR [rsp+0x60]
    2192:	mov    rsi,rbx
    2195:	mov    rdi,r12
    2198:	call   219d <botlish_fn_17+0x13e>
			2199: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    219d:	test   rax,rax
    21a0:	je     21ee <botlish_fn_17+0x18f>
    21a6:	mov    rbx,QWORD PTR [rsp+0x70]
    21ab:	mov    r12,QWORD PTR [rsp+0x78]
    21b0:	mov    r13,QWORD PTR [rsp+0x80]
    21b8:	mov    r14,QWORD PTR [rsp+0x88]
    21c0:	mov    r15,QWORD PTR [rsp+0x90]
    21c8:	add    rsp,0xa0
    21cf:	mov    rsp,rbp
    21d2:	pop    rbp
    21d3:	ret
    21d4:	mov    rcx,r13
    21d7:	mov    rdx,r14
    21da:	mov    rsi,r15
    21dd:	mov    rdi,r12
    21e0:	call   21e5 <botlish_fn_17+0x186>
			21e1: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[List[never], mutarray, int]>
    21e5:	test   rax,rax
    21e8:	jne    221f <botlish_fn_17+0x1c0>
    21ee:	xor    rax,rax
    21f1:	mov    rbx,QWORD PTR [rsp+0x70]
    21f6:	mov    r12,QWORD PTR [rsp+0x78]
    21fb:	mov    r13,QWORD PTR [rsp+0x80]
    2203:	mov    r14,QWORD PTR [rsp+0x88]
    220b:	mov    r15,QWORD PTR [rsp+0x90]
    2213:	add    rsp,0xa0
    221a:	mov    rsp,rbp
    221d:	pop    rbp
    221e:	ret
    221f:	mov    rbx,QWORD PTR [rsp+0x70]
    2224:	mov    r12,QWORD PTR [rsp+0x78]
    2229:	mov    r13,QWORD PTR [rsp+0x80]
    2231:	mov    r14,QWORD PTR [rsp+0x88]
    2239:	mov    r15,QWORD PTR [rsp+0x90]
    2241:	add    rsp,0xa0
    2248:	mov    rsp,rbp
    224b:	pop    rbp
    224c:	ret

000000000000224d <botlish_entry_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    224d:	push   rbp
    224e:	mov    rbp,rsp
    2251:	mov    rsi,QWORD PTR [rdx]
    2254:	mov    r10,QWORD PTR [rdx+0x8]
    2258:	mov    rcx,QWORD PTR [rdx+0x10]
    225c:	mov    r8,QWORD PTR [rdx+0x18]
    2260:	mov    r9,QWORD PTR [rdx+0x20]
    2264:	mov    rdx,r10
    2267:	call   226c <botlish_entry_17+0x1f>
			2268: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    226c:	mov    rsp,rbp
    226f:	pop    rbp
    2270:	ret
    2271:	add    BYTE PTR [rax],al
    2273:	add    BYTE PTR [rax],al
    2275:	add    BYTE PTR [rax],al
	...

0000000000002278 <botlish_fn_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    2278:	push   rbp
    2279:	mov    rbp,rsp
    227c:	sub    rsp,0xb0
    2283:	mov    QWORD PTR [rsp+0x80],rbx
    228b:	mov    QWORD PTR [rsp+0x88],r12
    2293:	mov    QWORD PTR [rsp+0x90],r13
    229b:	mov    QWORD PTR [rsp+0x98],r14
    22a3:	mov    QWORD PTR [rsp+0xa0],r15
    22ab:	mov    r15,rdi
    22ae:	mov    QWORD PTR [rsp+0x28],0x0
    22b7:	mov    QWORD PTR [rsp+0x30],0x0
    22c0:	mov    QWORD PTR [rsp+0x38],0x0
    22c9:	mov    QWORD PTR [rsp],rsi
    22cd:	mov    QWORD PTR [rsp+0x8],rdx
    22d2:	mov    r14,rdx
    22d5:	mov    QWORD PTR [rsp+0x10],rcx
    22da:	mov    QWORD PTR [rsp+0x18],r8
    22df:	mov    QWORD PTR [rsp+0x20],r9
    22e4:	lea    r13,[rsp+0x40]
    22e9:	lea    rbx,[rsp+0x50]
    22ee:	mov    r12,rsi
    22f1:	mov    QWORD PTR [rsp+0x60],rcx
    22f6:	mov    QWORD PTR [rsp+0x68],r8
    22fb:	mov    QWORD PTR [rsp+0x70],r9
    2300:	mov    rsi,r12
    2303:	mov    rdi,r15
    2306:	call   230b <botlish_fn_18+0x93>
			2307: R_X86_64_PLT32	rt_str_len-0x4
    230b:	mov    rcx,r14
    230e:	and    rcx,rax
    2311:	mov    rdx,rax
    2314:	test   rcx,0x1
    231b:	jne    2341 <botlish_fn_18+0xc9>
    2321:	mov    rsi,r14
    2324:	mov    rdi,r15
    2327:	call   232c <botlish_fn_18+0xb4>
			2328: R_X86_64_PLT32	rt_int_cmp-0x4
    232c:	mov    ecx,0x2
    2331:	test   rax,rax
    2334:	cmovge rcx,QWORD PTR [rip+0x164]        # 24a0 <botlish_fn_18+0x228>
    233c:	jmp    2354 <botlish_fn_18+0xdc>
    2341:	mov    ecx,0x2
    2346:	mov    rdi,r14
    2349:	cmp    rdi,rdx
    234c:	cmovge rcx,QWORD PTR [rip+0x14c]        # 24a0 <botlish_fn_18+0x228>
    2354:	cmp    rcx,0x6
    2358:	je     2411 <botlish_fn_18+0x199>
    235e:	mov    rsi,r13
    2361:	mov    rdi,r15
    2364:	call   2369 <botlish_fn_18+0xf1>
			2365: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2369:	test   rax,rax
    236c:	je     2431 <botlish_fn_18+0x1b9>
    2372:	mov    QWORD PTR [rsp+0x28],rax
    2377:	mov    rcx,rax
    237a:	mov    r8,QWORD PTR [rsp+0x40]
    237f:	mov    QWORD PTR [rsp+0x30],r8
    2384:	mov    r9,QWORD PTR [rsp+0x48]
    2389:	mov    QWORD PTR [rsp+0x38],r9
    238e:	mov    rdx,r14
    2391:	mov    rsi,r12
    2394:	mov    rdi,r15
    2397:	call   239c <botlish_fn_18+0x124>
			2398: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    239c:	test   rax,rax
    239f:	je     2431 <botlish_fn_18+0x1b9>
    23a5:	mov    QWORD PTR [rsp+0x8],rax
    23aa:	mov    r8,rax
    23ad:	mov    QWORD PTR [rsp+0x28],rdx
    23b2:	mov    r14,rdx
    23b5:	mov    rsi,QWORD PTR [rsp+0x60]
    23ba:	mov    rdx,QWORD PTR [rsp+0x68]
    23bf:	mov    rcx,QWORD PTR [rsp+0x70]
    23c4:	mov    rdi,r15
    23c7:	mov    r9,rbx
    23ca:	call   23cf <botlish_fn_18+0x157>
			23cb: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[List[mutarray], mutarray, int], list>
    23cf:	test   rax,rax
    23d2:	je     2431 <botlish_fn_18+0x1b9>
    23d8:	mov    rdx,QWORD PTR [rsp+0x50]
    23dd:	mov    rcx,QWORD PTR [rsp+0x58]
    23e2:	mov    QWORD PTR [rsp],r12
    23e6:	mov    rsi,r14
    23e9:	mov    QWORD PTR [rsp+0x8],rsi
    23ee:	mov    QWORD PTR [rsp+0x10],rax
    23f3:	mov    QWORD PTR [rsp+0x18],rdx
    23f8:	mov    QWORD PTR [rsp+0x20],rcx
    23fd:	mov    QWORD PTR [rsp+0x60],rax
    2402:	mov    QWORD PTR [rsp+0x68],rdx
    2407:	mov    QWORD PTR [rsp+0x70],rcx
    240c:	jmp    2300 <botlish_fn_18+0x88>
    2411:	mov    rcx,QWORD PTR [rsp+0x70]
    2416:	mov    rdx,QWORD PTR [rsp+0x68]
    241b:	mov    rsi,QWORD PTR [rsp+0x60]
    2420:	mov    rdi,r15
    2423:	call   2428 <botlish_fn_18+0x1b0>
			2424: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    2428:	test   rax,rax
    242b:	jne    2468 <botlish_fn_18+0x1f0>
    2431:	xor    rax,rax
    2434:	mov    rbx,QWORD PTR [rsp+0x80]
    243c:	mov    r12,QWORD PTR [rsp+0x88]
    2444:	mov    r13,QWORD PTR [rsp+0x90]
    244c:	mov    r14,QWORD PTR [rsp+0x98]
    2454:	mov    r15,QWORD PTR [rsp+0xa0]
    245c:	add    rsp,0xb0
    2463:	mov    rsp,rbp
    2466:	pop    rbp
    2467:	ret
    2468:	mov    rbx,QWORD PTR [rsp+0x80]
    2470:	mov    r12,QWORD PTR [rsp+0x88]
    2478:	mov    r13,QWORD PTR [rsp+0x90]
    2480:	mov    r14,QWORD PTR [rsp+0x98]
    2488:	mov    r15,QWORD PTR [rsp+0xa0]
    2490:	add    rsp,0xb0
    2497:	mov    rsp,rbp
    249a:	pop    rbp
    249b:	ret
    249c:	add    BYTE PTR [rax],al
    249e:	add    BYTE PTR [rax],al
    24a0:	(bad)
    24a1:	add    BYTE PTR [rax],al
    24a3:	add    BYTE PTR [rax],al
    24a5:	add    BYTE PTR [rax],al
	...

00000000000024a8 <botlish_entry_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    24a8:	push   rbp
    24a9:	mov    rbp,rsp
    24ac:	mov    rsi,QWORD PTR [rdx]
    24af:	mov    r10,QWORD PTR [rdx+0x8]
    24b3:	mov    rcx,QWORD PTR [rdx+0x10]
    24b7:	mov    r8,QWORD PTR [rdx+0x18]
    24bb:	mov    r9,QWORD PTR [rdx+0x20]
    24bf:	mov    rdx,r10
    24c2:	call   24c7 <botlish_entry_18+0x1f>
			24c3: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    24c7:	mov    rsp,rbp
    24ca:	pop    rbp
    24cb:	ret

00000000000024cc <botlish_fn_19: csv_parse<str>>:
    24cc:	push   rbp
    24cd:	mov    rbp,rsp
    24d0:	sub    rsp,0x50
    24d4:	mov    QWORD PTR [rsp+0x40],r12
    24d9:	mov    QWORD PTR [rsp+0x48],r13
    24de:	mov    r13,rdi
    24e1:	mov    QWORD PTR [rsp+0x10],0x0
    24ea:	mov    QWORD PTR [rsp+0x18],0x0
    24f3:	mov    QWORD PTR [rsp+0x20],0x0
    24fc:	mov    QWORD PTR [rsp],rsi
    2500:	mov    r12,rsi
    2503:	mov    QWORD PTR [rsp+0x8],0x1
    250c:	lea    rsi,[rsp+0x28]
    2511:	mov    rdi,r13
    2514:	call   2519 <botlish_fn_19+0x4d>
			2515: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2519:	test   rax,rax
    251c:	je     2557 <botlish_fn_19+0x8b>
    2522:	mov    QWORD PTR [rsp+0x10],rax
    2527:	mov    rcx,rax
    252a:	mov    r8,QWORD PTR [rsp+0x28]
    252f:	mov    QWORD PTR [rsp+0x18],r8
    2534:	mov    r9,QWORD PTR [rsp+0x30]
    2539:	mov    QWORD PTR [rsp+0x20],r9
    253e:	mov    edx,0x1
    2543:	mov    rsi,r12
    2546:	mov    rdi,r13
    2549:	call   254e <botlish_fn_19+0x82>
			254a: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    254e:	test   rax,rax
    2551:	jne    256d <botlish_fn_19+0xa1>
    2557:	xor    rax,rax
    255a:	mov    r12,QWORD PTR [rsp+0x40]
    255f:	mov    r13,QWORD PTR [rsp+0x48]
    2564:	add    rsp,0x50
    2568:	mov    rsp,rbp
    256b:	pop    rbp
    256c:	ret
    256d:	mov    r12,QWORD PTR [rsp+0x40]
    2572:	mov    r13,QWORD PTR [rsp+0x48]
    2577:	add    rsp,0x50
    257b:	mov    rsp,rbp
    257e:	pop    rbp
    257f:	ret

0000000000002580 <botlish_entry_19: csv_parse<str>>:
    2580:	push   rbp
    2581:	mov    rbp,rsp
    2584:	mov    rsi,QWORD PTR [rdx]
    2587:	call   258c <botlish_entry_19+0xc>
			2588: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    258c:	mov    rsp,rbp
    258f:	pop    rbp
    2590:	ret

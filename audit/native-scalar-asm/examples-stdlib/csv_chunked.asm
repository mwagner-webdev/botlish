; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10364  (per function: 68 195 534 534 534 534 592 520 540 540 365 430 585 1063 352 799 833 537 612 197)
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
	...

00000000000008c0 <botlish_fn_6: chunked_copy_chunks<List[never], int, mutarray, int>>:
     8c0:	push   rbp
     8c1:	mov    rbp,rsp
     8c4:	sub    rsp,0x60
     8c8:	mov    QWORD PTR [rsp+0x30],rbx
     8cd:	mov    QWORD PTR [rsp+0x38],r12
     8d2:	mov    QWORD PTR [rsp+0x40],r13
     8d7:	mov    QWORD PTR [rsp+0x48],r14
     8dc:	mov    QWORD PTR [rsp+0x50],r15
     8e1:	mov    rbx,rdx
     8e4:	mov    r14,rdi
     8e7:	mov    QWORD PTR [rsp],rsi
     8eb:	mov    QWORD PTR [rsp+0x8],rcx
     8f0:	mov    r12,rcx
     8f3:	mov    QWORD PTR [rsp+0x10],r8
     8f8:	mov    r13,rsi
     8fb:	mov    r15,r8
     8fe:	mov    rsi,r13
     901:	mov    rdi,r14
     904:	call   909 <botlish_fn_6+0x49>
			905: R_X86_64_PLT32	rt_list_len-0x4
     909:	mov    rcx,rbx
     90c:	and    rcx,rax
     90f:	mov    rdx,rax
     912:	test   rcx,0x1
     919:	jne    93f <botlish_fn_6+0x7f>
     91f:	mov    rsi,rbx
     922:	mov    rdi,r14
     925:	call   92a <botlish_fn_6+0x6a>
			926: R_X86_64_PLT32	rt_int_cmp-0x4
     92a:	mov    ecx,0x2
     92f:	test   rax,rax
     932:	cmovge rcx,QWORD PTR [rip+0x17e]        # ab8 <botlish_fn_6+0x1f8>
     93a:	jmp    94f <botlish_fn_6+0x8f>
     93f:	mov    ecx,0x2
     944:	cmp    rbx,rdx
     947:	cmovge rcx,QWORD PTR [rip+0x169]        # ab8 <botlish_fn_6+0x1f8>
     94f:	cmp    rcx,0x6
     953:	je     a93 <botlish_fn_6+0x1d3>
     959:	test   rbx,0x1
     960:	je     979 <botlish_fn_6+0xb9>
     966:	mov    rcx,QWORD PTR [r13+0x8]
     96a:	mov    rax,rbx
     96d:	sar    rax,1
     970:	cmp    rax,rcx
     973:	jb     998 <botlish_fn_6+0xd8>
     979:	mov    rdx,rbx
     97c:	mov    rsi,r13
     97f:	mov    rdi,r14
     982:	call   987 <botlish_fn_6+0xc7>
			983: R_X86_64_PLT32	rt_list_get-0x4
     987:	test   rax,rax
     98a:	je     a02 <botlish_fn_6+0x142>
     990:	mov    rsi,rax
     993:	jmp    9a0 <botlish_fn_6+0xe0>
     998:	mov    rsi,QWORD PTR [r13+0x10]
     99c:	mov    rsi,QWORD PTR [rsi+rax*8]
     9a0:	xor    eax,eax
     9a2:	test   rsi,0x7
     9a9:	jne    9ba <botlish_fn_6+0xfa>
     9af:	movzx  r8,BYTE PTR [rsi]
     9b3:	cmp    r8b,0x8
     9b7:	sete   al
     9ba:	test   al,al
     9bc:	jne    9dc <botlish_fn_6+0x11c>
     9c2:	mov    rdi,r14
     9c5:	mov    rax,QWORD PTR [rdi+0x10]
     9c9:	mov    rcx,QWORD PTR [rax+0x8]
     9cd:	mov    edx,0x8
     9d2:	call   9d7 <botlish_fn_6+0x117>
			9d3: R_X86_64_PLT32	rt_type_error-0x4
     9d7:	jmp    a02 <botlish_fn_6+0x142>
     9dc:	mov    rcx,rsi
     9df:	mov    r8d,0x1
     9e5:	mov    r9d,0x81
     9eb:	mov    rdx,r15
     9ee:	mov    rsi,r12
     9f1:	mov    rdi,r14
     9f4:	call   9f9 <botlish_fn_6+0x139>
			9f5: R_X86_64_PLT32	rt_mutarray_copy-0x4
     9f9:	test   rax,rax
     9fc:	jne    a27 <botlish_fn_6+0x167>
     a02:	xor    rax,rax
     a05:	mov    rbx,QWORD PTR [rsp+0x30]
     a0a:	mov    r12,QWORD PTR [rsp+0x38]
     a0f:	mov    r13,QWORD PTR [rsp+0x40]
     a14:	mov    r14,QWORD PTR [rsp+0x48]
     a19:	mov    r15,QWORD PTR [rsp+0x50]
     a1e:	add    rsp,0x60
     a22:	mov    rsp,rbp
     a25:	pop    rbp
     a26:	ret
     a27:	sar    rbx,1
     a2a:	add    rbx,0x1
     a31:	shl    rbx,1
     a34:	or     rbx,0x1
     a38:	mov    QWORD PTR [rsp+0x18],rbx
     a3d:	mov    QWORD PTR [rsp+0x20],0x81
     a46:	mov    rsi,r15
     a49:	test   rsi,0x1
     a50:	je     a6d <botlish_fn_6+0x1ad>
     a56:	mov    rsi,r15
     a59:	mov    rax,rsi
     a5c:	add    rax,0x80
     a62:	seto   cl
     a65:	test   cl,cl
     a67:	je     a7d <botlish_fn_6+0x1bd>
     a6d:	mov    edx,0x81
     a72:	mov    rsi,r15
     a75:	mov    rdi,r14
     a78:	call   a7d <botlish_fn_6+0x1bd>
			a79: R_X86_64_PLT32	rt_int_add-0x4
     a7d:	mov    QWORD PTR [rsp],r13
     a81:	mov    QWORD PTR [rsp+0x8],r12
     a86:	mov    QWORD PTR [rsp+0x10],rax
     a8b:	mov    r15,rax
     a8e:	jmp    8fe <botlish_fn_6+0x3e>
     a93:	mov    rax,r15
     a96:	mov    rbx,QWORD PTR [rsp+0x30]
     a9b:	mov    r12,QWORD PTR [rsp+0x38]
     aa0:	mov    r13,QWORD PTR [rsp+0x40]
     aa5:	mov    r14,QWORD PTR [rsp+0x48]
     aaa:	mov    r15,QWORD PTR [rsp+0x50]
     aaf:	add    rsp,0x60
     ab3:	mov    rsp,rbp
     ab6:	pop    rbp
     ab7:	ret
     ab8:	(bad)
     ab9:	add    BYTE PTR [rax],al
     abb:	add    BYTE PTR [rax],al
     abd:	add    BYTE PTR [rax],al
	...

0000000000000ac0 <botlish_entry_6: chunked_copy_chunks<List[never], int, mutarray, int>>:
     ac0:	push   rbp
     ac1:	mov    rbp,rsp
     ac4:	mov    rsi,QWORD PTR [rdx]
     ac7:	mov    r9,QWORD PTR [rdx+0x8]
     acb:	mov    rcx,QWORD PTR [rdx+0x10]
     acf:	mov    r8,QWORD PTR [rdx+0x18]
     ad3:	mov    rdx,r9
     ad6:	call   adb <botlish_entry_6+0x1b>
			ad7: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_copy_chunks<List[never], int, mutarray, int>
     adb:	mov    rsp,rbp
     ade:	pop    rbp
     adf:	ret

0000000000000ae0 <botlish_fn_7: chunked_copy_chunks<List[mutarray], int, mutarray, int>>:
     ae0:	push   rbp
     ae1:	mov    rbp,rsp
     ae4:	sub    rsp,0x60
     ae8:	mov    QWORD PTR [rsp+0x30],rbx
     aed:	mov    QWORD PTR [rsp+0x38],r12
     af2:	mov    QWORD PTR [rsp+0x40],r13
     af7:	mov    QWORD PTR [rsp+0x48],r14
     afc:	mov    QWORD PTR [rsp+0x50],r15
     b01:	mov    rbx,rdx
     b04:	mov    r15,rdi
     b07:	mov    QWORD PTR [rsp],rsi
     b0b:	mov    QWORD PTR [rsp+0x8],rcx
     b10:	mov    r13,rcx
     b13:	mov    QWORD PTR [rsp+0x10],r8
     b18:	mov    r12,rsi
     b1b:	mov    r14,r8
     b1e:	mov    rsi,r12
     b21:	mov    rdi,r15
     b24:	call   b29 <botlish_fn_7+0x49>
			b25: R_X86_64_PLT32	rt_list_len-0x4
     b29:	mov    rcx,rbx
     b2c:	and    rcx,rax
     b2f:	mov    rdx,rax
     b32:	test   rcx,0x1
     b39:	jne    b5f <botlish_fn_7+0x7f>
     b3f:	mov    rsi,rbx
     b42:	mov    rdi,r15
     b45:	call   b4a <botlish_fn_7+0x6a>
			b46: R_X86_64_PLT32	rt_int_cmp-0x4
     b4a:	mov    ecx,0x2
     b4f:	test   rax,rax
     b52:	cmovge rcx,QWORD PTR [rip+0x156]        # cb0 <botlish_fn_7+0x1d0>
     b5a:	jmp    b6f <botlish_fn_7+0x8f>
     b5f:	mov    ecx,0x2
     b64:	cmp    rbx,rdx
     b67:	cmovge rcx,QWORD PTR [rip+0x141]        # cb0 <botlish_fn_7+0x1d0>
     b6f:	cmp    rcx,0x6
     b73:	je     c86 <botlish_fn_7+0x1a6>
     b79:	test   rbx,0x1
     b80:	je     b9a <botlish_fn_7+0xba>
     b86:	mov    rax,QWORD PTR [r12+0x8]
     b8b:	mov    rcx,rbx
     b8e:	sar    rcx,1
     b91:	cmp    rcx,rax
     b94:	jb     bbe <botlish_fn_7+0xde>
     b9a:	mov    rdx,rbx
     b9d:	mov    rsi,r12
     ba0:	mov    rdi,r15
     ba3:	call   ba8 <botlish_fn_7+0xc8>
			ba4: R_X86_64_PLT32	rt_list_get-0x4
     ba8:	test   rax,rax
     bab:	je     bf4 <botlish_fn_7+0x114>
     bb1:	mov    rcx,rax
     bb4:	mov    QWORD PTR [rsp+0x28],r14
     bb9:	jmp    bcc <botlish_fn_7+0xec>
     bbe:	mov    rax,QWORD PTR [r12+0x10]
     bc3:	mov    rcx,QWORD PTR [rax+rcx*8]
     bc7:	mov    QWORD PTR [rsp+0x28],r14
     bcc:	mov    r8d,0x1
     bd2:	mov    r9d,0x81
     bd8:	mov    r14,r13
     bdb:	mov    rdx,QWORD PTR [rsp+0x28]
     be0:	mov    rsi,r14
     be3:	mov    rdi,r15
     be6:	call   beb <botlish_fn_7+0x10b>
			be7: R_X86_64_PLT32	rt_mutarray_copy-0x4
     beb:	test   rax,rax
     bee:	jne    c19 <botlish_fn_7+0x139>
     bf4:	xor    rax,rax
     bf7:	mov    rbx,QWORD PTR [rsp+0x30]
     bfc:	mov    r12,QWORD PTR [rsp+0x38]
     c01:	mov    r13,QWORD PTR [rsp+0x40]
     c06:	mov    r14,QWORD PTR [rsp+0x48]
     c0b:	mov    r15,QWORD PTR [rsp+0x50]
     c10:	add    rsp,0x60
     c14:	mov    rsp,rbp
     c17:	pop    rbp
     c18:	ret
     c19:	sar    rbx,1
     c1c:	add    rbx,0x1
     c23:	shl    rbx,1
     c26:	or     rbx,0x1
     c2a:	mov    QWORD PTR [rsp+0x18],rbx
     c2f:	mov    QWORD PTR [rsp+0x20],0x81
     c38:	mov    rsi,QWORD PTR [rsp+0x28]
     c3d:	test   rsi,0x1
     c44:	je     c60 <botlish_fn_7+0x180>
     c4a:	mov    rax,rsi
     c4d:	add    rax,0x80
     c53:	seto   dil
     c57:	test   dil,dil
     c5a:	je     c6d <botlish_fn_7+0x18d>
     c60:	mov    edx,0x81
     c65:	mov    rdi,r15
     c68:	call   c6d <botlish_fn_7+0x18d>
			c69: R_X86_64_PLT32	rt_int_add-0x4
     c6d:	mov    QWORD PTR [rsp],r12
     c71:	mov    QWORD PTR [rsp+0x8],r14
     c76:	mov    QWORD PTR [rsp+0x10],rax
     c7b:	mov    r13,r14
     c7e:	mov    r14,rax
     c81:	jmp    b1e <botlish_fn_7+0x3e>
     c86:	mov    rax,r14
     c89:	mov    rbx,QWORD PTR [rsp+0x30]
     c8e:	mov    r12,QWORD PTR [rsp+0x38]
     c93:	mov    r13,QWORD PTR [rsp+0x40]
     c98:	mov    r14,QWORD PTR [rsp+0x48]
     c9d:	mov    r15,QWORD PTR [rsp+0x50]
     ca2:	add    rsp,0x60
     ca6:	mov    rsp,rbp
     ca9:	pop    rbp
     caa:	ret
     cab:	add    BYTE PTR [rax],al
     cad:	add    BYTE PTR [rax],al
     caf:	add    BYTE PTR [rsi],al
     cb1:	add    BYTE PTR [rax],al
     cb3:	add    BYTE PTR [rax],al
     cb5:	add    BYTE PTR [rax],al
	...

0000000000000cb8 <botlish_entry_7: chunked_copy_chunks<List[mutarray], int, mutarray, int>>:
     cb8:	push   rbp
     cb9:	mov    rbp,rsp
     cbc:	mov    rsi,QWORD PTR [rdx]
     cbf:	mov    r9,QWORD PTR [rdx+0x8]
     cc3:	mov    rcx,QWORD PTR [rdx+0x10]
     cc7:	mov    r8,QWORD PTR [rdx+0x18]
     ccb:	mov    rdx,r9
     cce:	call   cd3 <botlish_entry_7+0x1b>
			ccf: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<List[mutarray], int, mutarray, int>
     cd3:	mov    rsp,rbp
     cd6:	pop    rbp
     cd7:	ret

0000000000000cd8 <botlish_fn_8: chunked_finish<list[List[never], mutarray, int]>>:
     cd8:	push   rbp
     cd9:	mov    rbp,rsp
     cdc:	sub    rsp,0x70
     ce0:	mov    QWORD PTR [rsp+0x40],rbx
     ce5:	mov    QWORD PTR [rsp+0x48],r12
     cea:	mov    QWORD PTR [rsp+0x50],r13
     cef:	mov    QWORD PTR [rsp+0x58],r14
     cf4:	mov    QWORD PTR [rsp+0x60],r15
     cf9:	mov    r13,rdi
     cfc:	mov    QWORD PTR [rsp+0x28],0x0
     d05:	mov    QWORD PTR [rsp+0x30],0x0
     d0e:	mov    QWORD PTR [rsp],rsi
     d12:	mov    r15,rsi
     d15:	mov    QWORD PTR [rsp+0x8],rdx
     d1a:	mov    r14,rdx
     d1d:	mov    QWORD PTR [rsp+0x10],rcx
     d22:	mov    r12,rcx
     d25:	mov    rsi,r15
     d28:	mov    rdi,r13
     d2b:	call   d30 <botlish_fn_8+0x58>
			d2c: R_X86_64_PLT32	rt_list_len-0x4
     d30:	mov    QWORD PTR [rsp+0x18],rax
     d35:	mov    QWORD PTR [rsp+0x20],0x81
     d3e:	test   rax,0x1
     d44:	mov    rsi,rax
     d47:	je     d74 <botlish_fn_8+0x9c>
     d4d:	mov    rdx,rsi
     d50:	mov    rax,rdx
     d53:	sar    rax,1
     d56:	imul   QWORD PTR [rip+0x14b]        # ea8 <botlish_fn_8+0x1d0>
     d5d:	seto   cl
     d60:	or     rax,0x1
     d64:	test   cl,cl
     d66:	jne    d74 <botlish_fn_8+0x9c>
     d6c:	mov    rsi,rax
     d6f:	jmp    d84 <botlish_fn_8+0xac>
     d74:	mov    edx,0x81
     d79:	mov    rdi,r13
     d7c:	call   d81 <botlish_fn_8+0xa9>
			d7d: R_X86_64_PLT32	rt_int_mul-0x4
     d81:	mov    rsi,rax
     d84:	mov    QWORD PTR [rsp+0x18],rsi
     d89:	mov    rax,rsi
     d8c:	and    rax,r12
     d8f:	test   rax,0x1
     d95:	je     db1 <botlish_fn_8+0xd9>
     d9b:	lea    rcx,[r12-0x1]
     da0:	mov    rbx,rsi
     da3:	add    rbx,rcx
     da6:	seto   al
     da9:	test   al,al
     dab:	je     dbf <botlish_fn_8+0xe7>
     db1:	mov    rdx,r12
     db4:	mov    rdi,r13
     db7:	call   dbc <botlish_fn_8+0xe4>
			db8: R_X86_64_PLT32	rt_int_add-0x4
     dbc:	mov    rbx,rax
     dbf:	mov    QWORD PTR [rsp+0x18],rbx
     dc4:	mov    rsi,rbx
     dc7:	mov    rdi,r13
     dca:	call   dcf <botlish_fn_8+0xf7>
			dcb: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     dcf:	mov    rcx,rax
     dd2:	mov    QWORD PTR [rsp+0x38],rax
     dd7:	test   rax,rcx
     dda:	je     e5c <botlish_fn_8+0x184>
     de0:	mov    rax,QWORD PTR [rsp+0x38]
     de5:	mov    QWORD PTR [rsp+0x20],rax
     dea:	mov    r8d,0x1
     df0:	mov    QWORD PTR [rsp+0x28],0x1
     df9:	mov    QWORD PTR [rsp+0x30],0x1
     e02:	mov    rsi,r15
     e05:	mov    rcx,QWORD PTR [rsp+0x38]
     e0a:	mov    rdi,r13
     e0d:	mov    rdx,r8
     e10:	call   e15 <botlish_fn_8+0x13d>
			e11: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_copy_chunks<List[never], int, mutarray, int>
     e15:	test   rax,rax
     e18:	mov    rdx,rax
     e1b:	je     e5c <botlish_fn_8+0x184>
     e21:	mov    r8d,0x1
     e27:	mov    rcx,r14
     e2a:	mov    r9,r12
     e2d:	mov    rsi,QWORD PTR [rsp+0x38]
     e32:	mov    rdi,r13
     e35:	call   e3a <botlish_fn_8+0x162>
			e36: R_X86_64_PLT32	rt_mutarray_copy-0x4
     e3a:	test   rax,rax
     e3d:	je     e5c <botlish_fn_8+0x184>
     e43:	mov    rdx,rbx
     e46:	mov    rsi,QWORD PTR [rsp+0x38]
     e4b:	mov    rdi,r13
     e4e:	call   e53 <botlish_fn_8+0x17b>
			e4f: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     e53:	test   rax,rax
     e56:	jne    e81 <botlish_fn_8+0x1a9>
     e5c:	xor    rax,rax
     e5f:	mov    rbx,QWORD PTR [rsp+0x40]
     e64:	mov    r12,QWORD PTR [rsp+0x48]
     e69:	mov    r13,QWORD PTR [rsp+0x50]
     e6e:	mov    r14,QWORD PTR [rsp+0x58]
     e73:	mov    r15,QWORD PTR [rsp+0x60]
     e78:	add    rsp,0x70
     e7c:	mov    rsp,rbp
     e7f:	pop    rbp
     e80:	ret
     e81:	mov    rbx,QWORD PTR [rsp+0x40]
     e86:	mov    r12,QWORD PTR [rsp+0x48]
     e8b:	mov    r13,QWORD PTR [rsp+0x50]
     e90:	mov    r14,QWORD PTR [rsp+0x58]
     e95:	mov    r15,QWORD PTR [rsp+0x60]
     e9a:	add    rsp,0x70
     e9e:	mov    rsp,rbp
     ea1:	pop    rbp
     ea2:	ret
     ea3:	add    BYTE PTR [rax],al
     ea5:	add    BYTE PTR [rax],al
     ea7:	add    BYTE PTR [rax+0x0],al
     ead:	add    BYTE PTR [rax],al
	...

0000000000000eb0 <botlish_entry_8: chunked_finish<list[List[never], mutarray, int]>>:
     eb0:	push   rbp
     eb1:	mov    rbp,rsp
     eb4:	mov    rsi,QWORD PTR [rdx]
     eb7:	mov    r8,QWORD PTR [rdx+0x8]
     ebb:	mov    rcx,QWORD PTR [rdx+0x10]
     ebf:	mov    rdx,r8
     ec2:	call   ec7 <botlish_entry_8+0x17>
			ec3: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[List[never], mutarray, int]>
     ec7:	mov    rsp,rbp
     eca:	pop    rbp
     ecb:	ret
     ecc:	add    BYTE PTR [rax],al
	...

0000000000000ed0 <botlish_fn_9: chunked_finish<list[List[mutarray], mutarray, int]>>:
     ed0:	push   rbp
     ed1:	mov    rbp,rsp
     ed4:	sub    rsp,0x70
     ed8:	mov    QWORD PTR [rsp+0x40],rbx
     edd:	mov    QWORD PTR [rsp+0x48],r12
     ee2:	mov    QWORD PTR [rsp+0x50],r13
     ee7:	mov    QWORD PTR [rsp+0x58],r14
     eec:	mov    QWORD PTR [rsp+0x60],r15
     ef1:	mov    r13,rdi
     ef4:	mov    QWORD PTR [rsp+0x28],0x0
     efd:	mov    QWORD PTR [rsp+0x30],0x0
     f06:	mov    QWORD PTR [rsp],rsi
     f0a:	mov    r15,rsi
     f0d:	mov    QWORD PTR [rsp+0x8],rdx
     f12:	mov    r14,rdx
     f15:	mov    QWORD PTR [rsp+0x10],rcx
     f1a:	mov    r12,rcx
     f1d:	mov    rsi,r15
     f20:	mov    rdi,r13
     f23:	call   f28 <botlish_fn_9+0x58>
			f24: R_X86_64_PLT32	rt_list_len-0x4
     f28:	mov    QWORD PTR [rsp+0x18],rax
     f2d:	mov    QWORD PTR [rsp+0x20],0x81
     f36:	test   rax,0x1
     f3c:	mov    rsi,rax
     f3f:	je     f6c <botlish_fn_9+0x9c>
     f45:	mov    rdx,rsi
     f48:	mov    rax,rdx
     f4b:	sar    rax,1
     f4e:	imul   QWORD PTR [rip+0x14b]        # 10a0 <botlish_fn_9+0x1d0>
     f55:	seto   cl
     f58:	or     rax,0x1
     f5c:	test   cl,cl
     f5e:	jne    f6c <botlish_fn_9+0x9c>
     f64:	mov    rsi,rax
     f67:	jmp    f7c <botlish_fn_9+0xac>
     f6c:	mov    edx,0x81
     f71:	mov    rdi,r13
     f74:	call   f79 <botlish_fn_9+0xa9>
			f75: R_X86_64_PLT32	rt_int_mul-0x4
     f79:	mov    rsi,rax
     f7c:	mov    QWORD PTR [rsp+0x18],rsi
     f81:	mov    rax,rsi
     f84:	and    rax,r12
     f87:	test   rax,0x1
     f8d:	je     fa9 <botlish_fn_9+0xd9>
     f93:	lea    rcx,[r12-0x1]
     f98:	mov    rbx,rsi
     f9b:	add    rbx,rcx
     f9e:	seto   al
     fa1:	test   al,al
     fa3:	je     fb7 <botlish_fn_9+0xe7>
     fa9:	mov    rdx,r12
     fac:	mov    rdi,r13
     faf:	call   fb4 <botlish_fn_9+0xe4>
			fb0: R_X86_64_PLT32	rt_int_add-0x4
     fb4:	mov    rbx,rax
     fb7:	mov    QWORD PTR [rsp+0x18],rbx
     fbc:	mov    rsi,rbx
     fbf:	mov    rdi,r13
     fc2:	call   fc7 <botlish_fn_9+0xf7>
			fc3: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     fc7:	mov    rcx,rax
     fca:	mov    QWORD PTR [rsp+0x38],rax
     fcf:	test   rax,rcx
     fd2:	je     1054 <botlish_fn_9+0x184>
     fd8:	mov    rax,QWORD PTR [rsp+0x38]
     fdd:	mov    QWORD PTR [rsp+0x20],rax
     fe2:	mov    r8d,0x1
     fe8:	mov    QWORD PTR [rsp+0x28],0x1
     ff1:	mov    QWORD PTR [rsp+0x30],0x1
     ffa:	mov    rsi,r15
     ffd:	mov    rcx,QWORD PTR [rsp+0x38]
    1002:	mov    rdi,r13
    1005:	mov    rdx,r8
    1008:	call   100d <botlish_fn_9+0x13d>
			1009: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<List[mutarray], int, mutarray, int>
    100d:	test   rax,rax
    1010:	mov    rdx,rax
    1013:	je     1054 <botlish_fn_9+0x184>
    1019:	mov    r8d,0x1
    101f:	mov    rcx,r14
    1022:	mov    r9,r12
    1025:	mov    rsi,QWORD PTR [rsp+0x38]
    102a:	mov    rdi,r13
    102d:	call   1032 <botlish_fn_9+0x162>
			102e: R_X86_64_PLT32	rt_mutarray_copy-0x4
    1032:	test   rax,rax
    1035:	je     1054 <botlish_fn_9+0x184>
    103b:	mov    rdx,rbx
    103e:	mov    rsi,QWORD PTR [rsp+0x38]
    1043:	mov    rdi,r13
    1046:	call   104b <botlish_fn_9+0x17b>
			1047: R_X86_64_PLT32	rt_mutarray_freeze-0x4
    104b:	test   rax,rax
    104e:	jne    1079 <botlish_fn_9+0x1a9>
    1054:	xor    rax,rax
    1057:	mov    rbx,QWORD PTR [rsp+0x40]
    105c:	mov    r12,QWORD PTR [rsp+0x48]
    1061:	mov    r13,QWORD PTR [rsp+0x50]
    1066:	mov    r14,QWORD PTR [rsp+0x58]
    106b:	mov    r15,QWORD PTR [rsp+0x60]
    1070:	add    rsp,0x70
    1074:	mov    rsp,rbp
    1077:	pop    rbp
    1078:	ret
    1079:	mov    rbx,QWORD PTR [rsp+0x40]
    107e:	mov    r12,QWORD PTR [rsp+0x48]
    1083:	mov    r13,QWORD PTR [rsp+0x50]
    1088:	mov    r14,QWORD PTR [rsp+0x58]
    108d:	mov    r15,QWORD PTR [rsp+0x60]
    1092:	add    rsp,0x70
    1096:	mov    rsp,rbp
    1099:	pop    rbp
    109a:	ret
    109b:	add    BYTE PTR [rax],al
    109d:	add    BYTE PTR [rax],al
    109f:	add    BYTE PTR [rax+0x0],al
    10a5:	add    BYTE PTR [rax],al
	...

00000000000010a8 <botlish_entry_9: chunked_finish<list[List[mutarray], mutarray, int]>>:
    10a8:	push   rbp
    10a9:	mov    rbp,rsp
    10ac:	mov    rsi,QWORD PTR [rdx]
    10af:	mov    r8,QWORD PTR [rdx+0x8]
    10b3:	mov    rcx,QWORD PTR [rdx+0x10]
    10b7:	mov    rdx,r8
    10ba:	call   10bf <botlish_entry_9+0x17>
			10bb: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    10bf:	mov    rsp,rbp
    10c2:	pop    rbp
    10c3:	ret
    10c4:	add    BYTE PTR [rax],al
	...

00000000000010c8 <botlish_fn_10: peek<str, int>>:
    10c8:	push   rbp
    10c9:	mov    rbp,rsp
    10cc:	sub    rsp,0x40
    10d0:	mov    QWORD PTR [rsp+0x20],rbx
    10d5:	mov    QWORD PTR [rsp+0x28],r12
    10da:	mov    QWORD PTR [rsp+0x30],r13
    10df:	mov    r13,rdi
    10e2:	mov    QWORD PTR [rsp],rsi
    10e6:	mov    r12,rsi
    10e9:	mov    QWORD PTR [rsp+0x8],rdx
    10ee:	mov    rbx,rdx
    10f1:	mov    rsi,r12
    10f4:	mov    rdi,r13
    10f7:	call   10fc <botlish_fn_10+0x34>
			10f8: R_X86_64_PLT32	rt_str_len-0x4
    10fc:	mov    rcx,rbx
    10ff:	and    rcx,rax
    1102:	mov    rdx,rax
    1105:	test   rcx,0x1
    110c:	jne    1132 <botlish_fn_10+0x6a>
    1112:	mov    rsi,rbx
    1115:	mov    rdi,r13
    1118:	call   111d <botlish_fn_10+0x55>
			1119: R_X86_64_PLT32	rt_int_cmp-0x4
    111d:	mov    ecx,0x2
    1122:	test   rax,rax
    1125:	cmovge rcx,QWORD PTR [rip+0xd3]        # 1200 <botlish_fn_10+0x138>
    112d:	jmp    1142 <botlish_fn_10+0x7a>
    1132:	mov    ecx,0x2
    1137:	cmp    rbx,rdx
    113a:	cmovge rcx,QWORD PTR [rip+0xbe]        # 1200 <botlish_fn_10+0x138>
    1142:	cmp    rcx,0x6
    1146:	je     11d6 <botlish_fn_10+0x10e>
    114c:	mov    QWORD PTR [rsp+0x10],0x3
    1155:	test   rbx,0x1
    115c:	je     1174 <botlish_fn_10+0xac>
    1162:	mov    rcx,rbx
    1165:	add    rcx,0x2
    1169:	seto   al
    116c:	test   al,al
    116e:	je     1187 <botlish_fn_10+0xbf>
    1174:	mov    edx,0x3
    1179:	mov    rsi,rbx
    117c:	mov    rdi,r13
    117f:	call   1184 <botlish_fn_10+0xbc>
			1180: R_X86_64_PLT32	rt_int_add-0x4
    1184:	mov    rcx,rax
    1187:	mov    QWORD PTR [rsp+0x10],rcx
    118c:	mov    rdx,rbx
    118f:	mov    rsi,r12
    1192:	mov    rdi,r13
    1195:	call   119a <botlish_fn_10+0xd2>
			1196: R_X86_64_PLT32	rt_substr-0x4
    119a:	test   rax,rax
    119d:	jne    11be <botlish_fn_10+0xf6>
    11a3:	xor    rax,rax
    11a6:	mov    rbx,QWORD PTR [rsp+0x20]
    11ab:	mov    r12,QWORD PTR [rsp+0x28]
    11b0:	mov    r13,QWORD PTR [rsp+0x30]
    11b5:	add    rsp,0x40
    11b9:	mov    rsp,rbp
    11bc:	pop    rbp
    11bd:	ret
    11be:	mov    rbx,QWORD PTR [rsp+0x20]
    11c3:	mov    r12,QWORD PTR [rsp+0x28]
    11c8:	mov    r13,QWORD PTR [rsp+0x30]
    11cd:	add    rsp,0x40
    11d1:	mov    rsp,rbp
    11d4:	pop    rbp
    11d5:	ret
    11d6:	mov    rdi,r13
    11d9:	mov    rax,QWORD PTR [rdi+0x10]
    11dd:	mov    rax,QWORD PTR [rax+0x10]
    11e1:	mov    rbx,QWORD PTR [rsp+0x20]
    11e6:	mov    r12,QWORD PTR [rsp+0x28]
    11eb:	mov    r13,QWORD PTR [rsp+0x30]
    11f0:	add    rsp,0x40
    11f4:	mov    rsp,rbp
    11f7:	pop    rbp
    11f8:	ret
    11f9:	add    BYTE PTR [rax],al
    11fb:	add    BYTE PTR [rax],al
    11fd:	add    BYTE PTR [rax],al
    11ff:	add    BYTE PTR [rsi],al
    1201:	add    BYTE PTR [rax],al
    1203:	add    BYTE PTR [rax],al
    1205:	add    BYTE PTR [rax],al
	...

0000000000001208 <botlish_entry_10: peek<str, int>>:
    1208:	push   rbp
    1209:	mov    rbp,rsp
    120c:	mov    rsi,QWORD PTR [rdx]
    120f:	mov    rdx,QWORD PTR [rdx+0x8]
    1213:	call   1218 <botlish_entry_10+0x10>
			1214: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    1218:	mov    rsp,rbp
    121b:	pop    rbp
    121c:	ret
    121d:	add    BYTE PTR [rax],al
	...

0000000000001220 <botlish_fn_11: peek<str, int>>:
    1220:	push   rbp
    1221:	mov    rbp,rsp
    1224:	sub    rsp,0x50
    1228:	mov    QWORD PTR [rsp+0x20],rbx
    122d:	mov    QWORD PTR [rsp+0x28],r12
    1232:	mov    QWORD PTR [rsp+0x30],r13
    1237:	mov    QWORD PTR [rsp+0x38],r14
    123c:	mov    QWORD PTR [rsp+0x40],r15
    1241:	mov    r12,rcx
    1244:	mov    r14,rdi
    1247:	mov    QWORD PTR [rsp],rsi
    124b:	mov    r13,rsi
    124e:	mov    QWORD PTR [rsp+0x8],rdx
    1253:	mov    rbx,rdx
    1256:	mov    rsi,r13
    1259:	mov    rdi,r14
    125c:	call   1261 <botlish_fn_11+0x41>
			125d: R_X86_64_PLT32	rt_str_len-0x4
    1261:	mov    rcx,rbx
    1264:	and    rcx,rax
    1267:	mov    rdx,rax
    126a:	test   rcx,0x1
    1271:	jne    1297 <botlish_fn_11+0x77>
    1277:	mov    rsi,rbx
    127a:	mov    rdi,r14
    127d:	call   1282 <botlish_fn_11+0x62>
			127e: R_X86_64_PLT32	rt_int_cmp-0x4
    1282:	mov    ecx,0x2
    1287:	test   rax,rax
    128a:	cmovge rcx,QWORD PTR [rip+0x11e]        # 13b0 <botlish_fn_11+0x190>
    1292:	jmp    12a7 <botlish_fn_11+0x87>
    1297:	mov    ecx,0x2
    129c:	cmp    rbx,rdx
    129f:	cmovge rcx,QWORD PTR [rip+0x109]        # 13b0 <botlish_fn_11+0x190>
    12a7:	cmp    rcx,0x6
    12ab:	je     136b <botlish_fn_11+0x14b>
    12b1:	mov    QWORD PTR [rsp+0x10],0x3
    12ba:	test   rbx,0x1
    12c1:	je     12e4 <botlish_fn_11+0xc4>
    12c7:	mov    rax,rbx
    12ca:	add    rax,0x2
    12ce:	seto   cl
    12d1:	test   cl,cl
    12d3:	jne    12e4 <botlish_fn_11+0xc4>
    12d9:	mov    rdi,r14
    12dc:	mov    r15,rax
    12df:	jmp    12fa <botlish_fn_11+0xda>
    12e4:	mov    edx,0x3
    12e9:	mov    rsi,rbx
    12ec:	mov    rdi,r14
    12ef:	call   12f4 <botlish_fn_11+0xd4>
			12f0: R_X86_64_PLT32	rt_int_add-0x4
    12f4:	mov    r15,rax
    12f7:	mov    rdi,r14
    12fa:	mov    rdi,r14
    12fd:	mov    rcx,r15
    1300:	mov    rdx,rbx
    1303:	mov    rsi,r13
    1306:	call   130b <botlish_fn_11+0xeb>
			1307: R_X86_64_PLT32	rt_str_region_check-0x4
    130b:	test   rax,rax
    130e:	jne    1339 <botlish_fn_11+0x119>
    1314:	xor    rax,rax
    1317:	mov    rbx,QWORD PTR [rsp+0x20]
    131c:	mov    r12,QWORD PTR [rsp+0x28]
    1321:	mov    r13,QWORD PTR [rsp+0x30]
    1326:	mov    r14,QWORD PTR [rsp+0x38]
    132b:	mov    r15,QWORD PTR [rsp+0x40]
    1330:	add    rsp,0x50
    1334:	mov    rsp,rbp
    1337:	pop    rbp
    1338:	ret
    1339:	mov    rcx,r12
    133c:	mov    QWORD PTR [rcx],rbx
    133f:	mov    rax,r15
    1342:	mov    QWORD PTR [rcx+0x8],rax
    1346:	mov    rax,r13
    1349:	mov    rbx,QWORD PTR [rsp+0x20]
    134e:	mov    r12,QWORD PTR [rsp+0x28]
    1353:	mov    r13,QWORD PTR [rsp+0x30]
    1358:	mov    r14,QWORD PTR [rsp+0x38]
    135d:	mov    r15,QWORD PTR [rsp+0x40]
    1362:	add    rsp,0x50
    1366:	mov    rsp,rbp
    1369:	pop    rbp
    136a:	ret
    136b:	mov    rcx,r12
    136e:	mov    rdi,r14
    1371:	mov    rax,QWORD PTR [rdi+0x10]
    1375:	mov    rax,QWORD PTR [rax+0x10]
    1379:	mov    QWORD PTR [rcx],0x1
    1380:	mov    QWORD PTR [rcx+0x8],0x1
    1388:	mov    rbx,QWORD PTR [rsp+0x20]
    138d:	mov    r12,QWORD PTR [rsp+0x28]
    1392:	mov    r13,QWORD PTR [rsp+0x30]
    1397:	mov    r14,QWORD PTR [rsp+0x38]
    139c:	mov    r15,QWORD PTR [rsp+0x40]
    13a1:	add    rsp,0x50
    13a5:	mov    rsp,rbp
    13a8:	pop    rbp
    13a9:	ret
    13aa:	add    BYTE PTR [rax],al
    13ac:	add    BYTE PTR [rax],al
    13ae:	add    BYTE PTR [rax],al
    13b0:	(bad)
    13b1:	add    BYTE PTR [rax],al
    13b3:	add    BYTE PTR [rax],al
    13b5:	add    BYTE PTR [rax],al
	...

00000000000013b8 <botlish_entry_11: peek<str, int>>:
    13b8:	push   rbp
    13b9:	mov    rbp,rsp
    13bc:	ud2

00000000000013be <botlish_fn_12: scan_unquoted<str, int, int>>:
    13be:	push   rbp
    13bf:	mov    rbp,rsp
    13c2:	sub    rsp,0x80
    13c9:	mov    QWORD PTR [rsp+0x50],rbx
    13ce:	mov    QWORD PTR [rsp+0x58],r12
    13d3:	mov    QWORD PTR [rsp+0x60],r13
    13d8:	mov    QWORD PTR [rsp+0x68],r14
    13dd:	mov    QWORD PTR [rsp+0x70],r15
    13e2:	mov    QWORD PTR [rsp+0x30],rdi
    13e7:	mov    QWORD PTR [rsp+0x18],0x0
    13f0:	mov    QWORD PTR [rsp],rsi
    13f4:	mov    r15,rsi
    13f7:	mov    QWORD PTR [rsp+0x8],rdx
    13fc:	mov    r14,rdx
    13ff:	mov    QWORD PTR [rsp+0x10],rcx
    1404:	lea    r13,[rsp+0x20]
    1409:	mov    QWORD PTR [rsp+0x38],rcx
    140e:	mov    rcx,r13
    1411:	mov    rdx,QWORD PTR [rsp+0x38]
    1416:	mov    rsi,r15
    1419:	mov    rdi,QWORD PTR [rsp+0x30]
    141e:	call   1423 <botlish_fn_12+0x65>
			141f: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1423:	mov    rsi,rax
    1426:	mov    QWORD PTR [rsp+0x40],rax
    142b:	test   rax,rsi
    142e:	je     1588 <botlish_fn_12+0x1ca>
    1434:	mov    rbx,QWORD PTR [rsp+0x20]
    1439:	mov    r12,QWORD PTR [rsp+0x28]
    143e:	mov    rdi,QWORD PTR [rsp+0x30]
    1443:	mov    rcx,QWORD PTR [rdi+0x10]
    1447:	mov    r8,QWORD PTR [rcx+0x10]
    144b:	mov    rcx,r12
    144e:	mov    rdx,rbx
    1451:	mov    rsi,QWORD PTR [rsp+0x40]
    1456:	call   145b <botlish_fn_12+0x9d>
			1457: R_X86_64_PLT32	rt_str_region_eq-0x4
    145b:	cmp    rax,0x6
    145f:	je     14a0 <botlish_fn_12+0xe2>
    1465:	mov    rdi,QWORD PTR [rsp+0x30]
    146a:	mov    rax,QWORD PTR [rdi+0x10]
    146e:	mov    r8,QWORD PTR [rax+0x18]
    1472:	mov    rcx,r12
    1475:	mov    rdx,rbx
    1478:	mov    rsi,QWORD PTR [rsp+0x40]
    147d:	call   1482 <botlish_fn_12+0xc4>
			147e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1482:	cmp    rax,0x6
    1486:	je     1496 <botlish_fn_12+0xd8>
    148c:	mov    eax,0x2
    1491:	jmp    14a5 <botlish_fn_12+0xe7>
    1496:	mov    eax,0x6
    149b:	jmp    14a5 <botlish_fn_12+0xe7>
    14a0:	mov    eax,0x6
    14a5:	cmp    rax,0x6
    14a9:	je     14ea <botlish_fn_12+0x12c>
    14af:	mov    rdi,QWORD PTR [rsp+0x30]
    14b4:	mov    rax,QWORD PTR [rdi+0x10]
    14b8:	mov    r8,QWORD PTR [rax+0x20]
    14bc:	mov    rcx,r12
    14bf:	mov    rdx,rbx
    14c2:	mov    rsi,QWORD PTR [rsp+0x40]
    14c7:	call   14cc <botlish_fn_12+0x10e>
			14c8: R_X86_64_PLT32	rt_str_region_eq-0x4
    14cc:	cmp    rax,0x6
    14d0:	je     14e0 <botlish_fn_12+0x122>
    14d6:	mov    eax,0x2
    14db:	jmp    14ef <botlish_fn_12+0x131>
    14e0:	mov    eax,0x6
    14e5:	jmp    14ef <botlish_fn_12+0x131>
    14ea:	mov    eax,0x6
    14ef:	cmp    rax,0x6
    14f3:	je     156a <botlish_fn_12+0x1ac>
    14f9:	mov    QWORD PTR [rsp+0x18],0x3
    1502:	mov    rsi,QWORD PTR [rsp+0x38]
    1507:	test   rsi,0x1
    150e:	je     1535 <botlish_fn_12+0x177>
    1514:	mov    rsi,QWORD PTR [rsp+0x38]
    1519:	mov    rax,rsi
    151c:	add    rax,0x2
    1520:	seto   sil
    1524:	test   sil,sil
    1527:	jne    1535 <botlish_fn_12+0x177>
    152d:	mov    rsi,r15
    1530:	jmp    154c <botlish_fn_12+0x18e>
    1535:	mov    edx,0x3
    153a:	mov    rsi,QWORD PTR [rsp+0x38]
    153f:	mov    rdi,QWORD PTR [rsp+0x30]
    1544:	call   1549 <botlish_fn_12+0x18b>
			1545: R_X86_64_PLT32	rt_int_add-0x4
    1549:	mov    rsi,r15
    154c:	mov    QWORD PTR [rsp],rsi
    1550:	mov    rdx,r14
    1553:	mov    QWORD PTR [rsp+0x8],rdx
    1558:	mov    QWORD PTR [rsp+0x10],rax
    155d:	mov    r15,rsi
    1560:	mov    QWORD PTR [rsp+0x38],rax
    1565:	jmp    140e <botlish_fn_12+0x50>
    156a:	mov    rdx,r14
    156d:	mov    rsi,r15
    1570:	mov    rdi,QWORD PTR [rsp+0x30]
    1575:	mov    rcx,QWORD PTR [rsp+0x38]
    157a:	call   157f <botlish_fn_12+0x1c1>
			157b: R_X86_64_PLT32	rt_substr-0x4
    157f:	test   rax,rax
    1582:	jne    15b3 <botlish_fn_12+0x1f5>
    1588:	xor    rdx,rdx
    158b:	mov    rax,rdx
    158e:	mov    rbx,QWORD PTR [rsp+0x50]
    1593:	mov    r12,QWORD PTR [rsp+0x58]
    1598:	mov    r13,QWORD PTR [rsp+0x60]
    159d:	mov    r14,QWORD PTR [rsp+0x68]
    15a2:	mov    r15,QWORD PTR [rsp+0x70]
    15a7:	add    rsp,0x80
    15ae:	mov    rsp,rbp
    15b1:	pop    rbp
    15b2:	ret
    15b3:	mov    rdx,QWORD PTR [rsp+0x38]
    15b8:	mov    rbx,QWORD PTR [rsp+0x50]
    15bd:	mov    r12,QWORD PTR [rsp+0x58]
    15c2:	mov    r13,QWORD PTR [rsp+0x60]
    15c7:	mov    r14,QWORD PTR [rsp+0x68]
    15cc:	mov    r15,QWORD PTR [rsp+0x70]
    15d1:	add    rsp,0x80
    15d8:	mov    rsp,rbp
    15db:	pop    rbp
    15dc:	ret

00000000000015dd <botlish_entry_12: scan_unquoted<str, int, int>>:
    15dd:	push   rbp
    15de:	mov    rbp,rsp
    15e1:	ud2

00000000000015e3 <botlish_fn_13: scan_quoted<str, int, str>>:
    15e3:	push   rbp
    15e4:	mov    rbp,rsp
    15e7:	sub    rsp,0xd0
    15ee:	mov    QWORD PTR [rsp+0xa0],rbx
    15f6:	mov    QWORD PTR [rsp+0xa8],r12
    15fe:	mov    QWORD PTR [rsp+0xb0],r13
    1606:	mov    QWORD PTR [rsp+0xb8],r14
    160e:	mov    QWORD PTR [rsp+0xc0],r15
    1616:	mov    r15,rdi
    1619:	mov    QWORD PTR [rsp+0x18],0x0
    1622:	mov    QWORD PTR [rsp+0x20],0x0
    162b:	mov    QWORD PTR [rsp],rsi
    162f:	mov    QWORD PTR [rsp+0x8],rdx
    1634:	mov    QWORD PTR [rsp+0x10],rcx
    1639:	mov    r13,rcx
    163c:	lea    r14,[rsp+0x68]
    1641:	lea    rbx,[rsp+0x28]
    1646:	mov    r12,rsi
    1649:	mov    QWORD PTR [rsp+0x88],rdx
    1651:	mov    rdx,QWORD PTR [rsp+0x88]
    1659:	mov    rsi,r12
    165c:	mov    rdi,r15
    165f:	call   1664 <botlish_fn_13+0x81>
			1660: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    1664:	test   rax,rax
    1667:	je     196b <botlish_fn_13+0x388>
    166d:	mov    QWORD PTR [rsp+0x18],rax
    1672:	mov    rdi,r15
    1675:	mov    QWORD PTR [rsp+0x90],rax
    167d:	mov    rsi,QWORD PTR [rdi+0x10]
    1681:	mov    rsi,QWORD PTR [rsi+0x28]
    1685:	mov    edx,0x1
    168a:	mov    ecx,0x3
    168f:	mov    r8,QWORD PTR [rsp+0x90]
    1697:	call   169c <botlish_fn_13+0xb9>
			1698: R_X86_64_PLT32	rt_str_region_eq-0x4
    169c:	cmp    rax,0x6
    16a0:	je     1760 <botlish_fn_13+0x17d>
    16a6:	mov    QWORD PTR [rsp+0x20],0x3
    16af:	mov    rsi,QWORD PTR [rsp+0x88]
    16b7:	test   rsi,0x1
    16be:	je     16e0 <botlish_fn_13+0xfd>
    16c4:	mov    r9,rsi
    16c7:	add    r9,0x2
    16cb:	seto   r11b
    16cf:	test   r11b,r11b
    16d2:	jne    16e0 <botlish_fn_13+0xfd>
    16d8:	mov    rsi,r9
    16db:	jmp    16f0 <botlish_fn_13+0x10d>
    16e0:	mov    edx,0x3
    16e5:	mov    rdi,r15
    16e8:	call   16ed <botlish_fn_13+0x10a>
			16e9: R_X86_64_PLT32	rt_int_add-0x4
    16ed:	mov    rsi,rax
    16f0:	mov    QWORD PTR [rsp+0x8],rsi
    16f5:	mov    QWORD PTR [rsp+0x88],rsi
    16fd:	mov    QWORD PTR [rsp+0x68],0x0
    1706:	mov    QWORD PTR [rsp+0x70],r13
    170b:	mov    QWORD PTR [rsp+0x78],0x0
    1714:	mov    rax,QWORD PTR [rsp+0x90]
    171c:	mov    QWORD PTR [rsp+0x80],rax
    1724:	mov    esi,0x2
    1729:	mov    edx,0x4
    172e:	mov    rcx,r14
    1731:	mov    rdi,r15
    1734:	call   1739 <botlish_fn_13+0x156>
			1735: R_X86_64_PLT32	rt_construct-0x4
    1739:	test   rax,rax
    173c:	je     196b <botlish_fn_13+0x388>
    1742:	mov    QWORD PTR [rsp],r12
    1746:	mov    rsi,QWORD PTR [rsp+0x88]
    174e:	mov    QWORD PTR [rsp+0x8],rsi
    1753:	mov    QWORD PTR [rsp+0x10],rax
    1758:	mov    r13,rax
    175b:	jmp    1651 <botlish_fn_13+0x6e>
    1760:	mov    QWORD PTR [rsp+0x18],0x3
    1769:	mov    rsi,QWORD PTR [rsp+0x88]
    1771:	test   rsi,0x1
    1778:	je     1798 <botlish_fn_13+0x1b5>
    177e:	mov    rsi,QWORD PTR [rsp+0x88]
    1786:	mov    rdx,rsi
    1789:	add    rdx,0x2
    178d:	seto   al
    1790:	test   al,al
    1792:	je     17b0 <botlish_fn_13+0x1cd>
    1798:	mov    edx,0x3
    179d:	mov    rsi,QWORD PTR [rsp+0x88]
    17a5:	mov    rdi,r15
    17a8:	call   17ad <botlish_fn_13+0x1ca>
			17a9: R_X86_64_PLT32	rt_int_add-0x4
    17ad:	mov    rdx,rax
    17b0:	mov    QWORD PTR [rsp+0x18],rdx
    17b5:	mov    rcx,rbx
    17b8:	mov    rsi,r12
    17bb:	mov    rdi,r15
    17be:	call   17c3 <botlish_fn_13+0x1e0>
			17bf: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    17c3:	test   rax,rax
    17c6:	mov    rsi,rax
    17c9:	je     196b <botlish_fn_13+0x388>
    17cf:	mov    rdx,QWORD PTR [rsp+0x28]
    17d4:	mov    rcx,QWORD PTR [rsp+0x30]
    17d9:	mov    rdi,r15
    17dc:	mov    rax,QWORD PTR [rdi+0x10]
    17e0:	mov    r8,QWORD PTR [rax+0x28]
    17e4:	call   17e9 <botlish_fn_13+0x206>
			17e5: R_X86_64_PLT32	rt_str_region_eq-0x4
    17e9:	cmp    rax,0x6
    17ed:	je     18b5 <botlish_fn_13+0x2d2>
    17f3:	xor    rsi,rsi
    17f6:	lea    rcx,[rsp+0x58]
    17fb:	mov    QWORD PTR [rsp+0x58],0x0
    1804:	mov    QWORD PTR [rsp+0x60],r13
    1809:	mov    edx,0x2
    180e:	mov    rdi,r15
    1811:	call   1816 <botlish_fn_13+0x233>
			1812: R_X86_64_PLT32	rt_construct-0x4
    1816:	test   rax,rax
    1819:	je     196b <botlish_fn_13+0x388>
    181f:	mov    QWORD PTR [rsp],rax
    1823:	mov    rbx,rax
    1826:	mov    QWORD PTR [rsp+0x10],0x3
    182f:	mov    rsi,QWORD PTR [rsp+0x88]
    1837:	test   rsi,0x1
    183e:	je     1866 <botlish_fn_13+0x283>
    1844:	mov    rsi,QWORD PTR [rsp+0x88]
    184c:	mov    rdx,rsi
    184f:	add    rdx,0x2
    1853:	seto   al
    1856:	test   al,al
    1858:	jne    1866 <botlish_fn_13+0x283>
    185e:	mov    rax,rbx
    1861:	jmp    1881 <botlish_fn_13+0x29e>
    1866:	mov    edx,0x3
    186b:	mov    rsi,QWORD PTR [rsp+0x88]
    1873:	mov    rdi,r15
    1876:	call   187b <botlish_fn_13+0x298>
			1877: R_X86_64_PLT32	rt_int_add-0x4
    187b:	mov    rdx,rax
    187e:	mov    rax,rbx
    1881:	mov    rbx,QWORD PTR [rsp+0xa0]
    1889:	mov    r12,QWORD PTR [rsp+0xa8]
    1891:	mov    r13,QWORD PTR [rsp+0xb0]
    1899:	mov    r14,QWORD PTR [rsp+0xb8]
    18a1:	mov    r15,QWORD PTR [rsp+0xc0]
    18a9:	add    rsp,0xd0
    18b0:	mov    rsp,rbp
    18b3:	pop    rbp
    18b4:	ret
    18b5:	mov    QWORD PTR [rsp+0x18],0x5
    18be:	mov    rsi,QWORD PTR [rsp+0x88]
    18c6:	test   rsi,0x1
    18cd:	je     18fd <botlish_fn_13+0x31a>
    18d3:	mov    rsi,QWORD PTR [rsp+0x88]
    18db:	mov    rax,rsi
    18de:	add    rax,0x4
    18e2:	seto   cl
    18e5:	test   cl,cl
    18e7:	jne    18fd <botlish_fn_13+0x31a>
    18ed:	mov    rsi,rax
    18f0:	mov    QWORD PTR [rsp+0x88],rax
    18f8:	jmp    191d <botlish_fn_13+0x33a>
    18fd:	mov    edx,0x5
    1902:	mov    rsi,QWORD PTR [rsp+0x88]
    190a:	mov    rdi,r15
    190d:	call   1912 <botlish_fn_13+0x32f>
			190e: R_X86_64_PLT32	rt_int_add-0x4
    1912:	mov    rsi,rax
    1915:	mov    QWORD PTR [rsp+0x88],rax
    191d:	mov    QWORD PTR [rsp+0x8],rsi
    1922:	mov    rdi,r15
    1925:	mov    rsi,QWORD PTR [rdi+0x10]
    1929:	mov    rsi,QWORD PTR [rsi+0x28]
    192d:	mov    QWORD PTR [rsp+0x18],rsi
    1932:	lea    rcx,[rsp+0x38]
    1937:	mov    QWORD PTR [rsp+0x38],0x0
    1940:	mov    QWORD PTR [rsp+0x40],r13
    1945:	mov    QWORD PTR [rsp+0x48],0x0
    194e:	mov    QWORD PTR [rsp+0x50],rsi
    1953:	mov    esi,0x2
    1958:	mov    edx,0x4
    195d:	call   1962 <botlish_fn_13+0x37f>
			195e: R_X86_64_PLT32	rt_construct-0x4
    1962:	test   rax,rax
    1965:	jne    19a5 <botlish_fn_13+0x3c2>
    196b:	xor    rdx,rdx
    196e:	mov    rax,rdx
    1971:	mov    rbx,QWORD PTR [rsp+0xa0]
    1979:	mov    r12,QWORD PTR [rsp+0xa8]
    1981:	mov    r13,QWORD PTR [rsp+0xb0]
    1989:	mov    r14,QWORD PTR [rsp+0xb8]
    1991:	mov    r15,QWORD PTR [rsp+0xc0]
    1999:	add    rsp,0xd0
    19a0:	mov    rsp,rbp
    19a3:	pop    rbp
    19a4:	ret
    19a5:	mov    QWORD PTR [rsp],r12
    19a9:	mov    rsi,QWORD PTR [rsp+0x88]
    19b1:	mov    QWORD PTR [rsp+0x8],rsi
    19b6:	mov    QWORD PTR [rsp+0x10],rax
    19bb:	mov    r13,rax
    19be:	jmp    1651 <botlish_fn_13+0x6e>

00000000000019c3 <botlish_entry_13: scan_quoted<str, int, str>>:
    19c3:	push   rbp
    19c4:	mov    rbp,rsp
    19c7:	ud2

00000000000019c9 <botlish_fn_14: scan_field<str, int>>:
    19c9:	push   rbp
    19ca:	mov    rbp,rsp
    19cd:	sub    rsp,0x50
    19d1:	mov    QWORD PTR [rsp+0x30],rbx
    19d6:	mov    QWORD PTR [rsp+0x38],r12
    19db:	mov    QWORD PTR [rsp+0x40],r13
    19e0:	mov    r12,rdi
    19e3:	mov    r13,rdx
    19e6:	mov    QWORD PTR [rsp+0x10],0x0
    19ef:	mov    QWORD PTR [rsp],rsi
    19f3:	mov    rbx,rsi
    19f6:	mov    QWORD PTR [rsp+0x8],rdx
    19fb:	lea    rcx,[rsp+0x18]
    1a00:	mov    rdx,r13
    1a03:	mov    rsi,rbx
    1a06:	mov    rdi,r12
    1a09:	call   1a0e <botlish_fn_14+0x45>
			1a0a: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1a0e:	test   rax,rax
    1a11:	mov    rsi,rax
    1a14:	je     1adf <botlish_fn_14+0x116>
    1a1a:	mov    rdx,QWORD PTR [rsp+0x18]
    1a1f:	mov    rcx,QWORD PTR [rsp+0x20]
    1a24:	mov    rdi,r12
    1a27:	mov    rax,QWORD PTR [rdi+0x10]
    1a2b:	mov    r8,QWORD PTR [rax+0x28]
    1a2f:	call   1a34 <botlish_fn_14+0x6b>
			1a30: R_X86_64_PLT32	rt_str_region_eq-0x4
    1a34:	cmp    rax,0x6
    1a38:	je     1a70 <botlish_fn_14+0xa7>
    1a3e:	mov    rcx,r13
    1a41:	mov    rsi,rbx
    1a44:	mov    rdi,r12
    1a47:	mov    rdx,rcx
    1a4a:	call   1a4f <botlish_fn_14+0x86>
			1a4b: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_unquoted<str, int, int>
    1a4f:	test   rax,rax
    1a52:	je     1adf <botlish_fn_14+0x116>
    1a58:	mov    rbx,QWORD PTR [rsp+0x30]
    1a5d:	mov    r12,QWORD PTR [rsp+0x38]
    1a62:	mov    r13,QWORD PTR [rsp+0x40]
    1a67:	add    rsp,0x50
    1a6b:	mov    rsp,rbp
    1a6e:	pop    rbp
    1a6f:	ret
    1a70:	mov    rcx,r13
    1a73:	mov    QWORD PTR [rsp+0x10],0x3
    1a7c:	test   rcx,0x1
    1a83:	jne    1a91 <botlish_fn_14+0xc8>
    1a89:	mov    r13,rcx
    1a8c:	jmp    1aa6 <botlish_fn_14+0xdd>
    1a91:	mov    rdx,rcx
    1a94:	add    rdx,0x2
    1a98:	mov    r13,rcx
    1a9b:	seto   al
    1a9e:	test   al,al
    1aa0:	je     1ab9 <botlish_fn_14+0xf0>
    1aa6:	mov    edx,0x3
    1aab:	mov    rsi,r13
    1aae:	mov    rdi,r12
    1ab1:	call   1ab6 <botlish_fn_14+0xed>
			1ab2: R_X86_64_PLT32	rt_int_add-0x4
    1ab6:	mov    rdx,rax
    1ab9:	mov    QWORD PTR [rsp+0x8],rdx
    1abe:	mov    rdi,r12
    1ac1:	mov    rax,QWORD PTR [rdi+0x10]
    1ac5:	mov    rcx,QWORD PTR [rax+0x10]
    1ac9:	mov    QWORD PTR [rsp+0x10],rcx
    1ace:	mov    rsi,rbx
    1ad1:	call   1ad6 <botlish_fn_14+0x10d>
			1ad2: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_quoted<str, int, str>
    1ad6:	test   rax,rax
    1ad9:	jne    1afd <botlish_fn_14+0x134>
    1adf:	xor    rdx,rdx
    1ae2:	mov    rax,rdx
    1ae5:	mov    rbx,QWORD PTR [rsp+0x30]
    1aea:	mov    r12,QWORD PTR [rsp+0x38]
    1aef:	mov    r13,QWORD PTR [rsp+0x40]
    1af4:	add    rsp,0x50
    1af8:	mov    rsp,rbp
    1afb:	pop    rbp
    1afc:	ret
    1afd:	mov    rbx,QWORD PTR [rsp+0x30]
    1b02:	mov    r12,QWORD PTR [rsp+0x38]
    1b07:	mov    r13,QWORD PTR [rsp+0x40]
    1b0c:	add    rsp,0x50
    1b10:	mov    rsp,rbp
    1b13:	pop    rbp
    1b14:	ret

0000000000001b15 <botlish_entry_14: scan_field<str, int>>:
    1b15:	push   rbp
    1b16:	mov    rbp,rsp
    1b19:	ud2

0000000000001b1b <botlish_fn_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1b1b:	push   rbp
    1b1c:	mov    rbp,rsp
    1b1f:	sub    rsp,0xa0
    1b26:	mov    QWORD PTR [rsp+0x70],rbx
    1b2b:	mov    QWORD PTR [rsp+0x78],r12
    1b30:	mov    QWORD PTR [rsp+0x80],r13
    1b38:	mov    QWORD PTR [rsp+0x88],r14
    1b40:	mov    QWORD PTR [rsp+0x90],r15
    1b48:	mov    r13,rdi
    1b4b:	mov    QWORD PTR [rsp+0x28],0x0
    1b54:	mov    QWORD PTR [rsp],rsi
    1b58:	mov    r15,rsi
    1b5b:	mov    QWORD PTR [rsp+0x8],rdx
    1b60:	mov    QWORD PTR [rsp+0x10],rcx
    1b65:	mov    QWORD PTR [rsp+0x50],rcx
    1b6a:	mov    QWORD PTR [rsp+0x18],r8
    1b6f:	mov    r12,r8
    1b72:	mov    QWORD PTR [rsp+0x20],r9
    1b77:	mov    rbx,r9
    1b7a:	mov    rsi,r15
    1b7d:	mov    rdi,r13
    1b80:	call   1b85 <botlish_fn_15+0x6a>
			1b81: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1b85:	test   rax,rax
    1b88:	je     1dbc <botlish_fn_15+0x2a1>
    1b8e:	mov    QWORD PTR [rsp+0x8],rax
    1b93:	mov    r8,rax
    1b96:	mov    QWORD PTR [rsp+0x28],rdx
    1b9b:	mov    r14,rdx
    1b9e:	lea    r9,[rsp+0x30]
    1ba3:	mov    rcx,rbx
    1ba6:	mov    rdx,r12
    1ba9:	mov    rsi,QWORD PTR [rsp+0x50]
    1bae:	mov    rdi,r13
    1bb1:	call   1bb6 <botlish_fn_15+0x9b>
			1bb2: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<list[List[never], mutarray, int], str>
    1bb6:	test   rax,rax
    1bb9:	je     1dbc <botlish_fn_15+0x2a1>
    1bbf:	mov    QWORD PTR [rsp+0x8],rax
    1bc4:	mov    QWORD PTR [rsp+0x68],rax
    1bc9:	mov    rdx,QWORD PTR [rsp+0x30]
    1bce:	mov    QWORD PTR [rsp+0x10],rdx
    1bd3:	mov    QWORD PTR [rsp+0x60],rdx
    1bd8:	mov    rcx,QWORD PTR [rsp+0x38]
    1bdd:	mov    QWORD PTR [rsp+0x18],rcx
    1be2:	mov    QWORD PTR [rsp+0x58],rcx
    1be7:	lea    rcx,[rsp+0x40]
    1bec:	mov    rdx,r14
    1bef:	mov    rsi,r15
    1bf2:	mov    rdi,r13
    1bf5:	call   1bfa <botlish_fn_15+0xdf>
			1bf6: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1bfa:	test   rax,rax
    1bfd:	mov    QWORD PTR [rsp+0x50],rax
    1c02:	je     1dbc <botlish_fn_15+0x2a1>
    1c08:	mov    r12,QWORD PTR [rsp+0x40]
    1c0d:	mov    rbx,QWORD PTR [rsp+0x48]
    1c12:	mov    rdi,r13
    1c15:	mov    rcx,QWORD PTR [rdi+0x10]
    1c19:	mov    r8,QWORD PTR [rcx+0x18]
    1c1d:	mov    rcx,rbx
    1c20:	mov    rdx,r12
    1c23:	mov    rsi,QWORD PTR [rsp+0x50]
    1c28:	call   1c2d <botlish_fn_15+0x112>
			1c29: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c2d:	cmp    rax,0x6
    1c31:	je     1d4b <botlish_fn_15+0x230>
    1c37:	mov    rdi,r13
    1c3a:	mov    rax,QWORD PTR [rdi+0x10]
    1c3e:	mov    r8,QWORD PTR [rax+0x20]
    1c42:	mov    rcx,rbx
    1c45:	mov    rdx,r12
    1c48:	mov    rsi,QWORD PTR [rsp+0x50]
    1c4d:	call   1c52 <botlish_fn_15+0x137>
			1c4e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c52:	cmp    rax,0x6
    1c56:	je     1cad <botlish_fn_15+0x192>
    1c5c:	mov    rcx,QWORD PTR [rsp+0x58]
    1c61:	mov    rdx,QWORD PTR [rsp+0x60]
    1c66:	mov    rsi,QWORD PTR [rsp+0x68]
    1c6b:	mov    rdi,r13
    1c6e:	call   1c73 <botlish_fn_15+0x158>
			1c6f: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1c73:	test   rax,rax
    1c76:	je     1dbc <botlish_fn_15+0x2a1>
    1c7c:	mov    rdx,r14
    1c7f:	mov    rbx,QWORD PTR [rsp+0x70]
    1c84:	mov    r12,QWORD PTR [rsp+0x78]
    1c89:	mov    r13,QWORD PTR [rsp+0x80]
    1c91:	mov    r14,QWORD PTR [rsp+0x88]
    1c99:	mov    r15,QWORD PTR [rsp+0x90]
    1ca1:	add    rsp,0xa0
    1ca8:	mov    rsp,rbp
    1cab:	pop    rbp
    1cac:	ret
    1cad:	mov    rcx,QWORD PTR [rsp+0x58]
    1cb2:	mov    rdx,QWORD PTR [rsp+0x60]
    1cb7:	mov    rsi,QWORD PTR [rsp+0x68]
    1cbc:	mov    rdi,r13
    1cbf:	call   1cc4 <botlish_fn_15+0x1a9>
			1cc0: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1cc4:	test   rax,rax
    1cc7:	je     1dbc <botlish_fn_15+0x2a1>
    1ccd:	mov    QWORD PTR [rsp],rax
    1cd1:	mov    rbx,rax
    1cd4:	mov    QWORD PTR [rsp+0x8],0x3
    1cdd:	mov    rdx,r14
    1ce0:	test   rdx,0x1
    1ce7:	je     1d07 <botlish_fn_15+0x1ec>
    1ced:	mov    rdx,r14
    1cf0:	add    rdx,0x2
    1cf4:	seto   al
    1cf7:	test   al,al
    1cf9:	jne    1d07 <botlish_fn_15+0x1ec>
    1cff:	mov    rax,rbx
    1d02:	jmp    1d1d <botlish_fn_15+0x202>
    1d07:	mov    edx,0x3
    1d0c:	mov    rsi,r14
    1d0f:	mov    rdi,r13
    1d12:	call   1d17 <botlish_fn_15+0x1fc>
			1d13: R_X86_64_PLT32	rt_int_add-0x4
    1d17:	mov    rdx,rax
    1d1a:	mov    rax,rbx
    1d1d:	mov    rbx,QWORD PTR [rsp+0x70]
    1d22:	mov    r12,QWORD PTR [rsp+0x78]
    1d27:	mov    r13,QWORD PTR [rsp+0x80]
    1d2f:	mov    r14,QWORD PTR [rsp+0x88]
    1d37:	mov    r15,QWORD PTR [rsp+0x90]
    1d3f:	add    rsp,0xa0
    1d46:	mov    rsp,rbp
    1d49:	pop    rbp
    1d4a:	ret
    1d4b:	mov    rsi,r14
    1d4e:	mov    edx,0x3
    1d53:	mov    rcx,rdx
    1d56:	mov    QWORD PTR [rsp+0x20],0x3
    1d5f:	test   rsi,0x1
    1d66:	jne    1d74 <botlish_fn_15+0x259>
    1d6c:	mov    rdx,rcx
    1d6f:	jmp    1d89 <botlish_fn_15+0x26e>
    1d74:	mov    rdx,rsi
    1d77:	add    rdx,0x2
    1d7b:	seto   al
    1d7e:	test   al,al
    1d80:	je     1d94 <botlish_fn_15+0x279>
    1d86:	mov    rdx,rcx
    1d89:	mov    rdi,r13
    1d8c:	call   1d91 <botlish_fn_15+0x276>
			1d8d: R_X86_64_PLT32	rt_int_add-0x4
    1d91:	mov    rdx,rax
    1d94:	mov    QWORD PTR [rsp+0x20],rdx
    1d99:	mov    rcx,QWORD PTR [rsp+0x68]
    1d9e:	mov    rsi,r15
    1da1:	mov    rdi,r13
    1da4:	mov    r8,QWORD PTR [rsp+0x60]
    1da9:	mov    r9,QWORD PTR [rsp+0x58]
    1dae:	call   1db3 <botlish_fn_15+0x298>
			1daf: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[List[mutarray], mutarray, int]>
    1db3:	test   rax,rax
    1db6:	jne    1df0 <botlish_fn_15+0x2d5>
    1dbc:	xor    rdx,rdx
    1dbf:	mov    rax,rdx
    1dc2:	mov    rbx,QWORD PTR [rsp+0x70]
    1dc7:	mov    r12,QWORD PTR [rsp+0x78]
    1dcc:	mov    r13,QWORD PTR [rsp+0x80]
    1dd4:	mov    r14,QWORD PTR [rsp+0x88]
    1ddc:	mov    r15,QWORD PTR [rsp+0x90]
    1de4:	add    rsp,0xa0
    1deb:	mov    rsp,rbp
    1dee:	pop    rbp
    1def:	ret
    1df0:	mov    rbx,QWORD PTR [rsp+0x70]
    1df5:	mov    r12,QWORD PTR [rsp+0x78]
    1dfa:	mov    r13,QWORD PTR [rsp+0x80]
    1e02:	mov    r14,QWORD PTR [rsp+0x88]
    1e0a:	mov    r15,QWORD PTR [rsp+0x90]
    1e12:	add    rsp,0xa0
    1e19:	mov    rsp,rbp
    1e1c:	pop    rbp
    1e1d:	ret

0000000000001e1e <botlish_entry_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1e1e:	push   rbp
    1e1f:	mov    rbp,rsp
    1e22:	ud2

0000000000001e24 <botlish_fn_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    1e24:	push   rbp
    1e25:	mov    rbp,rsp
    1e28:	sub    rsp,0xb0
    1e2f:	mov    QWORD PTR [rsp+0x80],rbx
    1e37:	mov    QWORD PTR [rsp+0x88],r12
    1e3f:	mov    QWORD PTR [rsp+0x90],r13
    1e47:	mov    QWORD PTR [rsp+0x98],r14
    1e4f:	mov    QWORD PTR [rsp+0xa0],r15
    1e57:	mov    QWORD PTR [rsp+0x50],rdi
    1e5c:	mov    QWORD PTR [rsp+0x28],0x0
    1e65:	mov    QWORD PTR [rsp],rsi
    1e69:	mov    QWORD PTR [rsp+0x8],rdx
    1e6e:	mov    QWORD PTR [rsp+0x10],rcx
    1e73:	mov    QWORD PTR [rsp+0x18],r8
    1e78:	mov    QWORD PTR [rsp+0x20],r9
    1e7d:	lea    r15,[rsp+0x30]
    1e82:	lea    rbx,[rsp+0x40]
    1e87:	mov    r12,rsi
    1e8a:	mov    r13,rcx
    1e8d:	mov    QWORD PTR [rsp+0x58],r8
    1e92:	mov    QWORD PTR [rsp+0x60],r9
    1e97:	mov    rsi,r12
    1e9a:	mov    rdi,QWORD PTR [rsp+0x50]
    1e9f:	call   1ea4 <botlish_fn_16+0x80>
			1ea0: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1ea4:	mov    QWORD PTR [rsp+0x78],rdx
    1ea9:	test   rax,rax
    1eac:	je     2007 <botlish_fn_16+0x1e3>
    1eb2:	mov    QWORD PTR [rsp+0x8],rax
    1eb7:	mov    rdx,QWORD PTR [rsp+0x78]
    1ebc:	mov    r8,rax
    1ebf:	mov    QWORD PTR [rsp+0x28],rdx
    1ec4:	mov    rcx,QWORD PTR [rsp+0x60]
    1ec9:	mov    rdx,QWORD PTR [rsp+0x58]
    1ece:	mov    rsi,r13
    1ed1:	mov    rdi,QWORD PTR [rsp+0x50]
    1ed6:	mov    r9,r15
    1ed9:	call   1ede <botlish_fn_16+0xba>
			1eda: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[List[mutarray], mutarray, int], str>
    1ede:	test   rax,rax
    1ee1:	je     2007 <botlish_fn_16+0x1e3>
    1ee7:	mov    QWORD PTR [rsp+0x8],rax
    1eec:	mov    QWORD PTR [rsp+0x70],rax
    1ef1:	mov    rdx,QWORD PTR [rsp+0x30]
    1ef6:	mov    QWORD PTR [rsp+0x58],rdx
    1efb:	mov    QWORD PTR [rsp+0x10],rdx
    1f00:	mov    rcx,QWORD PTR [rsp+0x38]
    1f05:	mov    QWORD PTR [rsp+0x18],rcx
    1f0a:	mov    QWORD PTR [rsp+0x60],rcx
    1f0f:	mov    rcx,rbx
    1f12:	mov    rdx,QWORD PTR [rsp+0x78]
    1f17:	mov    rsi,r12
    1f1a:	mov    rdi,QWORD PTR [rsp+0x50]
    1f1f:	call   1f24 <botlish_fn_16+0x100>
			1f20: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1f24:	test   rax,rax
    1f27:	mov    QWORD PTR [rsp+0x68],rax
    1f2c:	je     2007 <botlish_fn_16+0x1e3>
    1f32:	mov    r13,QWORD PTR [rsp+0x40]
    1f37:	mov    r14,QWORD PTR [rsp+0x48]
    1f3c:	mov    rdi,QWORD PTR [rsp+0x50]
    1f41:	mov    rcx,QWORD PTR [rdi+0x10]
    1f45:	mov    r8,QWORD PTR [rcx+0x18]
    1f49:	mov    rcx,r14
    1f4c:	mov    rdx,r13
    1f4f:	mov    rsi,QWORD PTR [rsp+0x68]
    1f54:	call   1f59 <botlish_fn_16+0x135>
			1f55: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f59:	cmp    rax,0x6
    1f5d:	je     20cd <botlish_fn_16+0x2a9>
    1f63:	mov    rdi,QWORD PTR [rsp+0x50]
    1f68:	mov    rax,QWORD PTR [rdi+0x10]
    1f6c:	mov    r8,QWORD PTR [rax+0x20]
    1f70:	mov    rcx,r14
    1f73:	mov    rdx,r13
    1f76:	mov    rsi,QWORD PTR [rsp+0x68]
    1f7b:	call   1f80 <botlish_fn_16+0x15c>
			1f7c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f80:	cmp    rax,0x6
    1f84:	je     1fe5 <botlish_fn_16+0x1c1>
    1f8a:	mov    rcx,QWORD PTR [rsp+0x60]
    1f8f:	mov    rdx,QWORD PTR [rsp+0x58]
    1f94:	mov    rsi,QWORD PTR [rsp+0x70]
    1f99:	mov    rdi,QWORD PTR [rsp+0x50]
    1f9e:	call   1fa3 <botlish_fn_16+0x17f>
			1f9f: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1fa3:	test   rax,rax
    1fa6:	je     2007 <botlish_fn_16+0x1e3>
    1fac:	mov    rdx,QWORD PTR [rsp+0x78]
    1fb1:	mov    rbx,QWORD PTR [rsp+0x80]
    1fb9:	mov    r12,QWORD PTR [rsp+0x88]
    1fc1:	mov    r13,QWORD PTR [rsp+0x90]
    1fc9:	mov    r14,QWORD PTR [rsp+0x98]
    1fd1:	mov    r15,QWORD PTR [rsp+0xa0]
    1fd9:	add    rsp,0xb0
    1fe0:	mov    rsp,rbp
    1fe3:	pop    rbp
    1fe4:	ret
    1fe5:	mov    rcx,QWORD PTR [rsp+0x60]
    1fea:	mov    rdx,QWORD PTR [rsp+0x58]
    1fef:	mov    rsi,QWORD PTR [rsp+0x70]
    1ff4:	mov    rdi,QWORD PTR [rsp+0x50]
    1ff9:	call   1ffe <botlish_fn_16+0x1da>
			1ffa: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1ffe:	test   rax,rax
    2001:	jne    2041 <botlish_fn_16+0x21d>
    2007:	xor    rdx,rdx
    200a:	mov    rax,rdx
    200d:	mov    rbx,QWORD PTR [rsp+0x80]
    2015:	mov    r12,QWORD PTR [rsp+0x88]
    201d:	mov    r13,QWORD PTR [rsp+0x90]
    2025:	mov    r14,QWORD PTR [rsp+0x98]
    202d:	mov    r15,QWORD PTR [rsp+0xa0]
    2035:	add    rsp,0xb0
    203c:	mov    rsp,rbp
    203f:	pop    rbp
    2040:	ret
    2041:	mov    QWORD PTR [rsp],rax
    2045:	mov    rbx,rax
    2048:	mov    QWORD PTR [rsp+0x8],0x3
    2051:	mov    rdx,QWORD PTR [rsp+0x78]
    2056:	test   rdx,0x1
    205d:	je     207f <botlish_fn_16+0x25b>
    2063:	mov    rdx,QWORD PTR [rsp+0x78]
    2068:	add    rdx,0x2
    206c:	seto   al
    206f:	test   al,al
    2071:	jne    207f <botlish_fn_16+0x25b>
    2077:	mov    rax,rbx
    207a:	jmp    2099 <botlish_fn_16+0x275>
    207f:	mov    edx,0x3
    2084:	mov    rsi,QWORD PTR [rsp+0x78]
    2089:	mov    rdi,QWORD PTR [rsp+0x50]
    208e:	call   2093 <botlish_fn_16+0x26f>
			208f: R_X86_64_PLT32	rt_int_add-0x4
    2093:	mov    rdx,rax
    2096:	mov    rax,rbx
    2099:	mov    rbx,QWORD PTR [rsp+0x80]
    20a1:	mov    r12,QWORD PTR [rsp+0x88]
    20a9:	mov    r13,QWORD PTR [rsp+0x90]
    20b1:	mov    r14,QWORD PTR [rsp+0x98]
    20b9:	mov    r15,QWORD PTR [rsp+0xa0]
    20c1:	add    rsp,0xb0
    20c8:	mov    rsp,rbp
    20cb:	pop    rbp
    20cc:	ret
    20cd:	mov    rsi,QWORD PTR [rsp+0x78]
    20d2:	mov    edx,0x3
    20d7:	mov    r10,rdx
    20da:	mov    QWORD PTR [rsp+0x20],0x3
    20e3:	test   rsi,0x1
    20ea:	jne    20f8 <botlish_fn_16+0x2d4>
    20f0:	mov    rdx,r10
    20f3:	jmp    210d <botlish_fn_16+0x2e9>
    20f8:	mov    rdx,rsi
    20fb:	add    rdx,0x2
    20ff:	seto   al
    2102:	test   al,al
    2104:	je     211a <botlish_fn_16+0x2f6>
    210a:	mov    rdx,r10
    210d:	mov    rdi,QWORD PTR [rsp+0x50]
    2112:	call   2117 <botlish_fn_16+0x2f3>
			2113: R_X86_64_PLT32	rt_int_add-0x4
    2117:	mov    rdx,rax
    211a:	mov    QWORD PTR [rsp],r12
    211e:	mov    QWORD PTR [rsp+0x8],rdx
    2123:	mov    rsi,QWORD PTR [rsp+0x70]
    2128:	mov    QWORD PTR [rsp+0x10],rsi
    212d:	mov    rax,QWORD PTR [rsp+0x58]
    2132:	mov    QWORD PTR [rsp+0x18],rax
    2137:	mov    rcx,QWORD PTR [rsp+0x60]
    213c:	mov    QWORD PTR [rsp+0x20],rcx
    2141:	mov    r13,rsi
    2144:	jmp    1e97 <botlish_fn_16+0x73>

0000000000002149 <botlish_entry_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    2149:	push   rbp
    214a:	mov    rbp,rsp
    214d:	ud2

000000000000214f <botlish_fn_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    214f:	push   rbp
    2150:	mov    rbp,rsp
    2153:	sub    rsp,0xa0
    215a:	mov    QWORD PTR [rsp+0x70],rbx
    215f:	mov    QWORD PTR [rsp+0x78],r12
    2164:	mov    QWORD PTR [rsp+0x80],r13
    216c:	mov    QWORD PTR [rsp+0x88],r14
    2174:	mov    QWORD PTR [rsp+0x90],r15
    217c:	mov    r12,rdi
    217f:	mov    QWORD PTR [rsp+0x28],0x0
    2188:	mov    QWORD PTR [rsp+0x30],0x0
    2191:	mov    QWORD PTR [rsp+0x38],0x0
    219a:	mov    QWORD PTR [rsp],rsi
    219e:	mov    rbx,rsi
    21a1:	mov    QWORD PTR [rsp+0x8],rdx
    21a6:	mov    QWORD PTR [rsp+0x60],rdx
    21ab:	mov    QWORD PTR [rsp+0x10],rcx
    21b0:	mov    r15,rcx
    21b3:	mov    QWORD PTR [rsp+0x18],r8
    21b8:	mov    r14,r8
    21bb:	mov    QWORD PTR [rsp+0x20],r9
    21c0:	mov    r13,r9
    21c3:	mov    rsi,rbx
    21c6:	mov    rdi,r12
    21c9:	call   21ce <botlish_fn_17+0x7f>
			21ca: R_X86_64_PLT32	rt_str_len-0x4
    21ce:	mov    rdx,QWORD PTR [rsp+0x60]
    21d3:	mov    rcx,rdx
    21d6:	sar    rcx,1
    21d9:	sar    rax,1
    21dc:	cmp    rcx,rax
    21df:	jge    22c4 <botlish_fn_17+0x175>
    21e5:	lea    rsi,[rsp+0x40]
    21ea:	mov    rdi,r12
    21ed:	call   21f2 <botlish_fn_17+0xa3>
			21ee: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    21f2:	test   rax,rax
    21f5:	je     22de <botlish_fn_17+0x18f>
    21fb:	mov    QWORD PTR [rsp+0x28],rax
    2200:	mov    rcx,rax
    2203:	mov    r8,QWORD PTR [rsp+0x40]
    2208:	mov    QWORD PTR [rsp+0x30],r8
    220d:	mov    r9,QWORD PTR [rsp+0x48]
    2212:	mov    QWORD PTR [rsp+0x38],r9
    2217:	mov    rdx,QWORD PTR [rsp+0x60]
    221c:	mov    rsi,rbx
    221f:	mov    rdi,r12
    2222:	call   2227 <botlish_fn_17+0xd8>
			2223: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    2227:	test   rax,rax
    222a:	je     22de <botlish_fn_17+0x18f>
    2230:	mov    QWORD PTR [rsp+0x8],rax
    2235:	mov    r8,rax
    2238:	mov    QWORD PTR [rsp+0x28],rdx
    223d:	mov    QWORD PTR [rsp+0x60],rdx
    2242:	lea    r9,[rsp+0x50]
    2247:	mov    rcx,r13
    224a:	mov    rdx,r14
    224d:	mov    rsi,r15
    2250:	mov    rdi,r12
    2253:	call   2258 <botlish_fn_17+0x109>
			2254: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[List[never], mutarray, int], list>
    2258:	test   rax,rax
    225b:	je     22de <botlish_fn_17+0x18f>
    2261:	mov    QWORD PTR [rsp+0x8],rax
    2266:	mov    rcx,rax
    2269:	mov    r8,QWORD PTR [rsp+0x50]
    226e:	mov    QWORD PTR [rsp+0x10],r8
    2273:	mov    r9,QWORD PTR [rsp+0x58]
    2278:	mov    QWORD PTR [rsp+0x18],r9
    227d:	mov    rdx,QWORD PTR [rsp+0x60]
    2282:	mov    rsi,rbx
    2285:	mov    rdi,r12
    2288:	call   228d <botlish_fn_17+0x13e>
			2289: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    228d:	test   rax,rax
    2290:	je     22de <botlish_fn_17+0x18f>
    2296:	mov    rbx,QWORD PTR [rsp+0x70]
    229b:	mov    r12,QWORD PTR [rsp+0x78]
    22a0:	mov    r13,QWORD PTR [rsp+0x80]
    22a8:	mov    r14,QWORD PTR [rsp+0x88]
    22b0:	mov    r15,QWORD PTR [rsp+0x90]
    22b8:	add    rsp,0xa0
    22bf:	mov    rsp,rbp
    22c2:	pop    rbp
    22c3:	ret
    22c4:	mov    rcx,r13
    22c7:	mov    rdx,r14
    22ca:	mov    rsi,r15
    22cd:	mov    rdi,r12
    22d0:	call   22d5 <botlish_fn_17+0x186>
			22d1: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[List[never], mutarray, int]>
    22d5:	test   rax,rax
    22d8:	jne    230f <botlish_fn_17+0x1c0>
    22de:	xor    rax,rax
    22e1:	mov    rbx,QWORD PTR [rsp+0x70]
    22e6:	mov    r12,QWORD PTR [rsp+0x78]
    22eb:	mov    r13,QWORD PTR [rsp+0x80]
    22f3:	mov    r14,QWORD PTR [rsp+0x88]
    22fb:	mov    r15,QWORD PTR [rsp+0x90]
    2303:	add    rsp,0xa0
    230a:	mov    rsp,rbp
    230d:	pop    rbp
    230e:	ret
    230f:	mov    rbx,QWORD PTR [rsp+0x70]
    2314:	mov    r12,QWORD PTR [rsp+0x78]
    2319:	mov    r13,QWORD PTR [rsp+0x80]
    2321:	mov    r14,QWORD PTR [rsp+0x88]
    2329:	mov    r15,QWORD PTR [rsp+0x90]
    2331:	add    rsp,0xa0
    2338:	mov    rsp,rbp
    233b:	pop    rbp
    233c:	ret

000000000000233d <botlish_entry_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    233d:	push   rbp
    233e:	mov    rbp,rsp
    2341:	mov    rsi,QWORD PTR [rdx]
    2344:	mov    r10,QWORD PTR [rdx+0x8]
    2348:	mov    rcx,QWORD PTR [rdx+0x10]
    234c:	mov    r8,QWORD PTR [rdx+0x18]
    2350:	mov    r9,QWORD PTR [rdx+0x20]
    2354:	mov    rdx,r10
    2357:	call   235c <botlish_entry_17+0x1f>
			2358: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    235c:	mov    rsp,rbp
    235f:	pop    rbp
    2360:	ret
    2361:	add    BYTE PTR [rax],al
    2363:	add    BYTE PTR [rax],al
    2365:	add    BYTE PTR [rax],al
	...

0000000000002368 <botlish_fn_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    2368:	push   rbp
    2369:	mov    rbp,rsp
    236c:	sub    rsp,0xb0
    2373:	mov    QWORD PTR [rsp+0x80],rbx
    237b:	mov    QWORD PTR [rsp+0x88],r12
    2383:	mov    QWORD PTR [rsp+0x90],r13
    238b:	mov    QWORD PTR [rsp+0x98],r14
    2393:	mov    QWORD PTR [rsp+0xa0],r15
    239b:	mov    r15,rdi
    239e:	mov    QWORD PTR [rsp+0x28],0x0
    23a7:	mov    QWORD PTR [rsp+0x30],0x0
    23b0:	mov    QWORD PTR [rsp+0x38],0x0
    23b9:	mov    QWORD PTR [rsp],rsi
    23bd:	mov    QWORD PTR [rsp+0x8],rdx
    23c2:	mov    r14,rdx
    23c5:	mov    QWORD PTR [rsp+0x10],rcx
    23ca:	mov    QWORD PTR [rsp+0x18],r8
    23cf:	mov    QWORD PTR [rsp+0x20],r9
    23d4:	lea    r13,[rsp+0x40]
    23d9:	lea    rbx,[rsp+0x50]
    23de:	mov    r12,rsi
    23e1:	mov    QWORD PTR [rsp+0x60],rcx
    23e6:	mov    QWORD PTR [rsp+0x68],r8
    23eb:	mov    QWORD PTR [rsp+0x70],r9
    23f0:	mov    rsi,r12
    23f3:	mov    rdi,r15
    23f6:	call   23fb <botlish_fn_18+0x93>
			23f7: R_X86_64_PLT32	rt_str_len-0x4
    23fb:	mov    rcx,r14
    23fe:	and    rcx,rax
    2401:	mov    rdx,rax
    2404:	test   rcx,0x1
    240b:	jne    2431 <botlish_fn_18+0xc9>
    2411:	mov    rsi,r14
    2414:	mov    rdi,r15
    2417:	call   241c <botlish_fn_18+0xb4>
			2418: R_X86_64_PLT32	rt_int_cmp-0x4
    241c:	mov    ecx,0x2
    2421:	test   rax,rax
    2424:	cmovge rcx,QWORD PTR [rip+0x164]        # 2590 <botlish_fn_18+0x228>
    242c:	jmp    2444 <botlish_fn_18+0xdc>
    2431:	mov    ecx,0x2
    2436:	mov    rdi,r14
    2439:	cmp    rdi,rdx
    243c:	cmovge rcx,QWORD PTR [rip+0x14c]        # 2590 <botlish_fn_18+0x228>
    2444:	cmp    rcx,0x6
    2448:	je     2501 <botlish_fn_18+0x199>
    244e:	mov    rsi,r13
    2451:	mov    rdi,r15
    2454:	call   2459 <botlish_fn_18+0xf1>
			2455: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2459:	test   rax,rax
    245c:	je     2521 <botlish_fn_18+0x1b9>
    2462:	mov    QWORD PTR [rsp+0x28],rax
    2467:	mov    rcx,rax
    246a:	mov    r8,QWORD PTR [rsp+0x40]
    246f:	mov    QWORD PTR [rsp+0x30],r8
    2474:	mov    r9,QWORD PTR [rsp+0x48]
    2479:	mov    QWORD PTR [rsp+0x38],r9
    247e:	mov    rdx,r14
    2481:	mov    rsi,r12
    2484:	mov    rdi,r15
    2487:	call   248c <botlish_fn_18+0x124>
			2488: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    248c:	test   rax,rax
    248f:	je     2521 <botlish_fn_18+0x1b9>
    2495:	mov    QWORD PTR [rsp+0x8],rax
    249a:	mov    r8,rax
    249d:	mov    QWORD PTR [rsp+0x28],rdx
    24a2:	mov    r14,rdx
    24a5:	mov    rsi,QWORD PTR [rsp+0x60]
    24aa:	mov    rdx,QWORD PTR [rsp+0x68]
    24af:	mov    rcx,QWORD PTR [rsp+0x70]
    24b4:	mov    rdi,r15
    24b7:	mov    r9,rbx
    24ba:	call   24bf <botlish_fn_18+0x157>
			24bb: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[List[mutarray], mutarray, int], list>
    24bf:	test   rax,rax
    24c2:	je     2521 <botlish_fn_18+0x1b9>
    24c8:	mov    rdx,QWORD PTR [rsp+0x50]
    24cd:	mov    rcx,QWORD PTR [rsp+0x58]
    24d2:	mov    QWORD PTR [rsp],r12
    24d6:	mov    rsi,r14
    24d9:	mov    QWORD PTR [rsp+0x8],rsi
    24de:	mov    QWORD PTR [rsp+0x10],rax
    24e3:	mov    QWORD PTR [rsp+0x18],rdx
    24e8:	mov    QWORD PTR [rsp+0x20],rcx
    24ed:	mov    QWORD PTR [rsp+0x60],rax
    24f2:	mov    QWORD PTR [rsp+0x68],rdx
    24f7:	mov    QWORD PTR [rsp+0x70],rcx
    24fc:	jmp    23f0 <botlish_fn_18+0x88>
    2501:	mov    rcx,QWORD PTR [rsp+0x70]
    2506:	mov    rdx,QWORD PTR [rsp+0x68]
    250b:	mov    rsi,QWORD PTR [rsp+0x60]
    2510:	mov    rdi,r15
    2513:	call   2518 <botlish_fn_18+0x1b0>
			2514: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    2518:	test   rax,rax
    251b:	jne    2558 <botlish_fn_18+0x1f0>
    2521:	xor    rax,rax
    2524:	mov    rbx,QWORD PTR [rsp+0x80]
    252c:	mov    r12,QWORD PTR [rsp+0x88]
    2534:	mov    r13,QWORD PTR [rsp+0x90]
    253c:	mov    r14,QWORD PTR [rsp+0x98]
    2544:	mov    r15,QWORD PTR [rsp+0xa0]
    254c:	add    rsp,0xb0
    2553:	mov    rsp,rbp
    2556:	pop    rbp
    2557:	ret
    2558:	mov    rbx,QWORD PTR [rsp+0x80]
    2560:	mov    r12,QWORD PTR [rsp+0x88]
    2568:	mov    r13,QWORD PTR [rsp+0x90]
    2570:	mov    r14,QWORD PTR [rsp+0x98]
    2578:	mov    r15,QWORD PTR [rsp+0xa0]
    2580:	add    rsp,0xb0
    2587:	mov    rsp,rbp
    258a:	pop    rbp
    258b:	ret
    258c:	add    BYTE PTR [rax],al
    258e:	add    BYTE PTR [rax],al
    2590:	(bad)
    2591:	add    BYTE PTR [rax],al
    2593:	add    BYTE PTR [rax],al
    2595:	add    BYTE PTR [rax],al
	...

0000000000002598 <botlish_entry_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    2598:	push   rbp
    2599:	mov    rbp,rsp
    259c:	mov    rsi,QWORD PTR [rdx]
    259f:	mov    r10,QWORD PTR [rdx+0x8]
    25a3:	mov    rcx,QWORD PTR [rdx+0x10]
    25a7:	mov    r8,QWORD PTR [rdx+0x18]
    25ab:	mov    r9,QWORD PTR [rdx+0x20]
    25af:	mov    rdx,r10
    25b2:	call   25b7 <botlish_entry_18+0x1f>
			25b3: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    25b7:	mov    rsp,rbp
    25ba:	pop    rbp
    25bb:	ret

00000000000025bc <botlish_fn_19: csv_parse<str>>:
    25bc:	push   rbp
    25bd:	mov    rbp,rsp
    25c0:	sub    rsp,0x50
    25c4:	mov    QWORD PTR [rsp+0x40],r12
    25c9:	mov    QWORD PTR [rsp+0x48],r13
    25ce:	mov    r13,rdi
    25d1:	mov    QWORD PTR [rsp+0x10],0x0
    25da:	mov    QWORD PTR [rsp+0x18],0x0
    25e3:	mov    QWORD PTR [rsp+0x20],0x0
    25ec:	mov    QWORD PTR [rsp],rsi
    25f0:	mov    r12,rsi
    25f3:	mov    QWORD PTR [rsp+0x8],0x1
    25fc:	lea    rsi,[rsp+0x28]
    2601:	mov    rdi,r13
    2604:	call   2609 <botlish_fn_19+0x4d>
			2605: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2609:	test   rax,rax
    260c:	je     2647 <botlish_fn_19+0x8b>
    2612:	mov    QWORD PTR [rsp+0x10],rax
    2617:	mov    rcx,rax
    261a:	mov    r8,QWORD PTR [rsp+0x28]
    261f:	mov    QWORD PTR [rsp+0x18],r8
    2624:	mov    r9,QWORD PTR [rsp+0x30]
    2629:	mov    QWORD PTR [rsp+0x20],r9
    262e:	mov    edx,0x1
    2633:	mov    rsi,r12
    2636:	mov    rdi,r13
    2639:	call   263e <botlish_fn_19+0x82>
			263a: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    263e:	test   rax,rax
    2641:	jne    265d <botlish_fn_19+0xa1>
    2647:	xor    rax,rax
    264a:	mov    r12,QWORD PTR [rsp+0x40]
    264f:	mov    r13,QWORD PTR [rsp+0x48]
    2654:	add    rsp,0x50
    2658:	mov    rsp,rbp
    265b:	pop    rbp
    265c:	ret
    265d:	mov    r12,QWORD PTR [rsp+0x40]
    2662:	mov    r13,QWORD PTR [rsp+0x48]
    2667:	add    rsp,0x50
    266b:	mov    rsp,rbp
    266e:	pop    rbp
    266f:	ret

0000000000002670 <botlish_entry_19: csv_parse<str>>:
    2670:	push   rbp
    2671:	mov    rbp,rsp
    2674:	mov    rsi,QWORD PTR [rdx]
    2677:	call   267c <botlish_entry_19+0xc>
			2678: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    267c:	mov    rsp,rbp
    267f:	pop    rbp
    2680:	ret

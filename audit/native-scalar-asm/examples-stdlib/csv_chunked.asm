; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10305  (per function: 68 195 534 534 534 534 498 418 540 540 496 430 585 1069 352 799 833 537 612 197)
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
    1017:	mov    QWORD PTR [rsp+0x38],r14
    101c:	mov    r13,rdi
    101f:	mov    QWORD PTR [rsp],rsi
    1023:	mov    r12,rsi
    1026:	mov    QWORD PTR [rsp+0x8],rdx
    102b:	mov    rbx,rdx
    102e:	mov    rsi,r12
    1031:	mov    rdi,r13
    1034:	call   1039 <botlish_fn_10+0x39>
			1035: R_X86_64_PLT32	rt_str_len-0x4
    1039:	mov    rcx,rbx
    103c:	and    rcx,rax
    103f:	mov    rdx,rax
    1042:	test   rcx,0x1
    1049:	jne    106f <botlish_fn_10+0x6f>
    104f:	mov    rsi,rbx
    1052:	mov    rdi,r13
    1055:	call   105a <botlish_fn_10+0x5a>
			1056: R_X86_64_PLT32	rt_int_cmp-0x4
    105a:	mov    ecx,0x2
    105f:	test   rax,rax
    1062:	cmovge rcx,QWORD PTR [rip+0x106]        # 1170 <botlish_fn_10+0x170>
    106a:	jmp    1082 <botlish_fn_10+0x82>
    106f:	mov    ecx,0x2
    1074:	mov    rax,rbx
    1077:	cmp    rax,rdx
    107a:	cmovge rcx,QWORD PTR [rip+0xee]        # 1170 <botlish_fn_10+0x170>
    1082:	cmp    rcx,0x6
    1086:	je     1140 <botlish_fn_10+0x140>
    108c:	mov    QWORD PTR [rsp+0x10],0x3
    1095:	mov    rdx,rbx
    1098:	test   rdx,0x1
    109f:	je     10bd <botlish_fn_10+0xbd>
    10a5:	mov    rdx,rbx
    10a8:	mov    rcx,rdx
    10ab:	add    rcx,0x2
    10af:	mov    r14,rcx
    10b2:	seto   al
    10b5:	test   al,al
    10b7:	je     10d0 <botlish_fn_10+0xd0>
    10bd:	mov    edx,0x3
    10c2:	mov    rsi,rbx
    10c5:	mov    rdi,r13
    10c8:	call   10cd <botlish_fn_10+0xcd>
			10c9: R_X86_64_PLT32	rt_int_add-0x4
    10cd:	mov    r14,rax
    10d0:	mov    rcx,r14
    10d3:	mov    rdx,rbx
    10d6:	mov    rsi,r12
    10d9:	mov    rdi,r13
    10dc:	call   10e1 <botlish_fn_10+0xe1>
			10dd: R_X86_64_PLT32	rt_str_region_check-0x4
    10e1:	test   rax,rax
    10e4:	jne    110d <botlish_fn_10+0x10d>
    10ea:	xor    rdx,rdx
    10ed:	mov    rax,rdx
    10f0:	mov    rbx,QWORD PTR [rsp+0x20]
    10f5:	mov    r12,QWORD PTR [rsp+0x28]
    10fa:	mov    r13,QWORD PTR [rsp+0x30]
    10ff:	mov    r14,QWORD PTR [rsp+0x38]
    1104:	add    rsp,0x40
    1108:	mov    rsp,rbp
    110b:	pop    rbp
    110c:	ret
    110d:	mov    rcx,r14
    1110:	mov    rdx,rbx
    1113:	mov    rsi,r12
    1116:	mov    rdi,r13
    1119:	call   111e <botlish_fn_10+0x11e>
			111a: R_X86_64_PLT32	rt_str_slice_short-0x4
    111e:	mov    edx,0x1
    1123:	mov    rbx,QWORD PTR [rsp+0x20]
    1128:	mov    r12,QWORD PTR [rsp+0x28]
    112d:	mov    r13,QWORD PTR [rsp+0x30]
    1132:	mov    r14,QWORD PTR [rsp+0x38]
    1137:	add    rsp,0x40
    113b:	mov    rsp,rbp
    113e:	pop    rbp
    113f:	ret
    1140:	mov    rax,0xffffffffffffffff
    1147:	mov    edx,0x1
    114c:	mov    rbx,QWORD PTR [rsp+0x20]
    1151:	mov    r12,QWORD PTR [rsp+0x28]
    1156:	mov    r13,QWORD PTR [rsp+0x30]
    115b:	mov    r14,QWORD PTR [rsp+0x38]
    1160:	add    rsp,0x40
    1164:	mov    rsp,rbp
    1167:	pop    rbp
    1168:	ret
    1169:	add    BYTE PTR [rax],al
    116b:	add    BYTE PTR [rax],al
    116d:	add    BYTE PTR [rax],al
    116f:	add    BYTE PTR [rsi],al
    1171:	add    BYTE PTR [rax],al
    1173:	add    BYTE PTR [rax],al
    1175:	add    BYTE PTR [rax],al
	...

0000000000001178 <botlish_entry_10: peek<str, int>>:
    1178:	push   rbp
    1179:	mov    rbp,rsp
    117c:	sub    rsp,0x10
    1180:	mov    QWORD PTR [rsp],r12
    1184:	mov    QWORD PTR [rsp+0x8],r15
    1189:	mov    r15,rdi
    118c:	mov    rsi,QWORD PTR [rdx]
    118f:	mov    rdx,QWORD PTR [rdx+0x8]
    1193:	call   1198 <botlish_entry_10+0x20>
			1194: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    1198:	mov    r12,rdx
    119b:	mov    r10,QWORD PTR [rip+0x0]        # 11a2 <botlish_entry_10+0x2a>
			119e: R_X86_64_GOTPCREL	rt_short_to_str-0x4
    11a2:	mov    rsi,rax
    11a5:	mov    rdi,r15
    11a8:	call   r10
    11ab:	mov    rcx,rax
    11ae:	xor    rax,rax
    11b1:	mov    rdx,r12
    11b4:	test   rdx,rdx
    11b7:	cmovne rax,rcx
    11bb:	mov    r12,QWORD PTR [rsp]
    11bf:	mov    r15,QWORD PTR [rsp+0x8]
    11c4:	add    rsp,0x10
    11c8:	mov    rsp,rbp
    11cb:	pop    rbp
    11cc:	ret
    11cd:	add    BYTE PTR [rax],al
	...

00000000000011d0 <botlish_fn_11: peek<str, int>>:
    11d0:	push   rbp
    11d1:	mov    rbp,rsp
    11d4:	sub    rsp,0x50
    11d8:	mov    QWORD PTR [rsp+0x20],rbx
    11dd:	mov    QWORD PTR [rsp+0x28],r12
    11e2:	mov    QWORD PTR [rsp+0x30],r13
    11e7:	mov    QWORD PTR [rsp+0x38],r14
    11ec:	mov    QWORD PTR [rsp+0x40],r15
    11f1:	mov    r12,rcx
    11f4:	mov    r14,rdi
    11f7:	mov    QWORD PTR [rsp],rsi
    11fb:	mov    r13,rsi
    11fe:	mov    QWORD PTR [rsp+0x8],rdx
    1203:	mov    rbx,rdx
    1206:	mov    rsi,r13
    1209:	mov    rdi,r14
    120c:	call   1211 <botlish_fn_11+0x41>
			120d: R_X86_64_PLT32	rt_str_len-0x4
    1211:	mov    rcx,rbx
    1214:	and    rcx,rax
    1217:	mov    rdx,rax
    121a:	test   rcx,0x1
    1221:	jne    1247 <botlish_fn_11+0x77>
    1227:	mov    rsi,rbx
    122a:	mov    rdi,r14
    122d:	call   1232 <botlish_fn_11+0x62>
			122e: R_X86_64_PLT32	rt_int_cmp-0x4
    1232:	mov    ecx,0x2
    1237:	test   rax,rax
    123a:	cmovge rcx,QWORD PTR [rip+0x11e]        # 1360 <botlish_fn_11+0x190>
    1242:	jmp    1257 <botlish_fn_11+0x87>
    1247:	mov    ecx,0x2
    124c:	cmp    rbx,rdx
    124f:	cmovge rcx,QWORD PTR [rip+0x109]        # 1360 <botlish_fn_11+0x190>
    1257:	cmp    rcx,0x6
    125b:	je     131b <botlish_fn_11+0x14b>
    1261:	mov    QWORD PTR [rsp+0x10],0x3
    126a:	test   rbx,0x1
    1271:	je     1294 <botlish_fn_11+0xc4>
    1277:	mov    rax,rbx
    127a:	add    rax,0x2
    127e:	seto   cl
    1281:	test   cl,cl
    1283:	jne    1294 <botlish_fn_11+0xc4>
    1289:	mov    rdi,r14
    128c:	mov    r15,rax
    128f:	jmp    12aa <botlish_fn_11+0xda>
    1294:	mov    edx,0x3
    1299:	mov    rsi,rbx
    129c:	mov    rdi,r14
    129f:	call   12a4 <botlish_fn_11+0xd4>
			12a0: R_X86_64_PLT32	rt_int_add-0x4
    12a4:	mov    r15,rax
    12a7:	mov    rdi,r14
    12aa:	mov    rdi,r14
    12ad:	mov    rcx,r15
    12b0:	mov    rdx,rbx
    12b3:	mov    rsi,r13
    12b6:	call   12bb <botlish_fn_11+0xeb>
			12b7: R_X86_64_PLT32	rt_str_region_check-0x4
    12bb:	test   rax,rax
    12be:	jne    12e9 <botlish_fn_11+0x119>
    12c4:	xor    rax,rax
    12c7:	mov    rbx,QWORD PTR [rsp+0x20]
    12cc:	mov    r12,QWORD PTR [rsp+0x28]
    12d1:	mov    r13,QWORD PTR [rsp+0x30]
    12d6:	mov    r14,QWORD PTR [rsp+0x38]
    12db:	mov    r15,QWORD PTR [rsp+0x40]
    12e0:	add    rsp,0x50
    12e4:	mov    rsp,rbp
    12e7:	pop    rbp
    12e8:	ret
    12e9:	mov    rcx,r12
    12ec:	mov    QWORD PTR [rcx],rbx
    12ef:	mov    rax,r15
    12f2:	mov    QWORD PTR [rcx+0x8],rax
    12f6:	mov    rax,r13
    12f9:	mov    rbx,QWORD PTR [rsp+0x20]
    12fe:	mov    r12,QWORD PTR [rsp+0x28]
    1303:	mov    r13,QWORD PTR [rsp+0x30]
    1308:	mov    r14,QWORD PTR [rsp+0x38]
    130d:	mov    r15,QWORD PTR [rsp+0x40]
    1312:	add    rsp,0x50
    1316:	mov    rsp,rbp
    1319:	pop    rbp
    131a:	ret
    131b:	mov    rcx,r12
    131e:	mov    rdi,r14
    1321:	mov    rax,QWORD PTR [rdi+0x10]
    1325:	mov    rax,QWORD PTR [rax+0x10]
    1329:	mov    QWORD PTR [rcx],0x1
    1330:	mov    QWORD PTR [rcx+0x8],0x1
    1338:	mov    rbx,QWORD PTR [rsp+0x20]
    133d:	mov    r12,QWORD PTR [rsp+0x28]
    1342:	mov    r13,QWORD PTR [rsp+0x30]
    1347:	mov    r14,QWORD PTR [rsp+0x38]
    134c:	mov    r15,QWORD PTR [rsp+0x40]
    1351:	add    rsp,0x50
    1355:	mov    rsp,rbp
    1358:	pop    rbp
    1359:	ret
    135a:	add    BYTE PTR [rax],al
    135c:	add    BYTE PTR [rax],al
    135e:	add    BYTE PTR [rax],al
    1360:	(bad)
    1361:	add    BYTE PTR [rax],al
    1363:	add    BYTE PTR [rax],al
    1365:	add    BYTE PTR [rax],al
	...

0000000000001368 <botlish_entry_11: peek<str, int>>:
    1368:	push   rbp
    1369:	mov    rbp,rsp
    136c:	ud2

000000000000136e <botlish_fn_12: scan_unquoted<str, int, int>>:
    136e:	push   rbp
    136f:	mov    rbp,rsp
    1372:	sub    rsp,0x80
    1379:	mov    QWORD PTR [rsp+0x50],rbx
    137e:	mov    QWORD PTR [rsp+0x58],r12
    1383:	mov    QWORD PTR [rsp+0x60],r13
    1388:	mov    QWORD PTR [rsp+0x68],r14
    138d:	mov    QWORD PTR [rsp+0x70],r15
    1392:	mov    QWORD PTR [rsp+0x30],rdi
    1397:	mov    QWORD PTR [rsp+0x18],0x0
    13a0:	mov    QWORD PTR [rsp],rsi
    13a4:	mov    r15,rsi
    13a7:	mov    QWORD PTR [rsp+0x8],rdx
    13ac:	mov    r14,rdx
    13af:	mov    QWORD PTR [rsp+0x10],rcx
    13b4:	lea    r13,[rsp+0x20]
    13b9:	mov    QWORD PTR [rsp+0x38],rcx
    13be:	mov    rcx,r13
    13c1:	mov    rdx,QWORD PTR [rsp+0x38]
    13c6:	mov    rsi,r15
    13c9:	mov    rdi,QWORD PTR [rsp+0x30]
    13ce:	call   13d3 <botlish_fn_12+0x65>
			13cf: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    13d3:	mov    rsi,rax
    13d6:	mov    QWORD PTR [rsp+0x40],rax
    13db:	test   rax,rsi
    13de:	je     1538 <botlish_fn_12+0x1ca>
    13e4:	mov    rbx,QWORD PTR [rsp+0x20]
    13e9:	mov    r12,QWORD PTR [rsp+0x28]
    13ee:	mov    rdi,QWORD PTR [rsp+0x30]
    13f3:	mov    rcx,QWORD PTR [rdi+0x10]
    13f7:	mov    r8,QWORD PTR [rcx+0x10]
    13fb:	mov    rcx,r12
    13fe:	mov    rdx,rbx
    1401:	mov    rsi,QWORD PTR [rsp+0x40]
    1406:	call   140b <botlish_fn_12+0x9d>
			1407: R_X86_64_PLT32	rt_str_region_eq-0x4
    140b:	cmp    rax,0x6
    140f:	je     1450 <botlish_fn_12+0xe2>
    1415:	mov    rdi,QWORD PTR [rsp+0x30]
    141a:	mov    rax,QWORD PTR [rdi+0x10]
    141e:	mov    r8,QWORD PTR [rax+0x18]
    1422:	mov    rcx,r12
    1425:	mov    rdx,rbx
    1428:	mov    rsi,QWORD PTR [rsp+0x40]
    142d:	call   1432 <botlish_fn_12+0xc4>
			142e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1432:	cmp    rax,0x6
    1436:	je     1446 <botlish_fn_12+0xd8>
    143c:	mov    eax,0x2
    1441:	jmp    1455 <botlish_fn_12+0xe7>
    1446:	mov    eax,0x6
    144b:	jmp    1455 <botlish_fn_12+0xe7>
    1450:	mov    eax,0x6
    1455:	cmp    rax,0x6
    1459:	je     149a <botlish_fn_12+0x12c>
    145f:	mov    rdi,QWORD PTR [rsp+0x30]
    1464:	mov    rax,QWORD PTR [rdi+0x10]
    1468:	mov    r8,QWORD PTR [rax+0x20]
    146c:	mov    rcx,r12
    146f:	mov    rdx,rbx
    1472:	mov    rsi,QWORD PTR [rsp+0x40]
    1477:	call   147c <botlish_fn_12+0x10e>
			1478: R_X86_64_PLT32	rt_str_region_eq-0x4
    147c:	cmp    rax,0x6
    1480:	je     1490 <botlish_fn_12+0x122>
    1486:	mov    eax,0x2
    148b:	jmp    149f <botlish_fn_12+0x131>
    1490:	mov    eax,0x6
    1495:	jmp    149f <botlish_fn_12+0x131>
    149a:	mov    eax,0x6
    149f:	cmp    rax,0x6
    14a3:	je     151a <botlish_fn_12+0x1ac>
    14a9:	mov    QWORD PTR [rsp+0x18],0x3
    14b2:	mov    rsi,QWORD PTR [rsp+0x38]
    14b7:	test   rsi,0x1
    14be:	je     14e5 <botlish_fn_12+0x177>
    14c4:	mov    rsi,QWORD PTR [rsp+0x38]
    14c9:	mov    rax,rsi
    14cc:	add    rax,0x2
    14d0:	seto   sil
    14d4:	test   sil,sil
    14d7:	jne    14e5 <botlish_fn_12+0x177>
    14dd:	mov    rsi,r15
    14e0:	jmp    14fc <botlish_fn_12+0x18e>
    14e5:	mov    edx,0x3
    14ea:	mov    rsi,QWORD PTR [rsp+0x38]
    14ef:	mov    rdi,QWORD PTR [rsp+0x30]
    14f4:	call   14f9 <botlish_fn_12+0x18b>
			14f5: R_X86_64_PLT32	rt_int_add-0x4
    14f9:	mov    rsi,r15
    14fc:	mov    QWORD PTR [rsp],rsi
    1500:	mov    rdx,r14
    1503:	mov    QWORD PTR [rsp+0x8],rdx
    1508:	mov    QWORD PTR [rsp+0x10],rax
    150d:	mov    r15,rsi
    1510:	mov    QWORD PTR [rsp+0x38],rax
    1515:	jmp    13be <botlish_fn_12+0x50>
    151a:	mov    rdx,r14
    151d:	mov    rsi,r15
    1520:	mov    rdi,QWORD PTR [rsp+0x30]
    1525:	mov    rcx,QWORD PTR [rsp+0x38]
    152a:	call   152f <botlish_fn_12+0x1c1>
			152b: R_X86_64_PLT32	rt_substr-0x4
    152f:	test   rax,rax
    1532:	jne    1563 <botlish_fn_12+0x1f5>
    1538:	xor    rdx,rdx
    153b:	mov    rax,rdx
    153e:	mov    rbx,QWORD PTR [rsp+0x50]
    1543:	mov    r12,QWORD PTR [rsp+0x58]
    1548:	mov    r13,QWORD PTR [rsp+0x60]
    154d:	mov    r14,QWORD PTR [rsp+0x68]
    1552:	mov    r15,QWORD PTR [rsp+0x70]
    1557:	add    rsp,0x80
    155e:	mov    rsp,rbp
    1561:	pop    rbp
    1562:	ret
    1563:	mov    rdx,QWORD PTR [rsp+0x38]
    1568:	mov    rbx,QWORD PTR [rsp+0x50]
    156d:	mov    r12,QWORD PTR [rsp+0x58]
    1572:	mov    r13,QWORD PTR [rsp+0x60]
    1577:	mov    r14,QWORD PTR [rsp+0x68]
    157c:	mov    r15,QWORD PTR [rsp+0x70]
    1581:	add    rsp,0x80
    1588:	mov    rsp,rbp
    158b:	pop    rbp
    158c:	ret

000000000000158d <botlish_entry_12: scan_unquoted<str, int, int>>:
    158d:	push   rbp
    158e:	mov    rbp,rsp
    1591:	ud2

0000000000001593 <botlish_fn_13: scan_quoted<str, int, str>>:
    1593:	push   rbp
    1594:	mov    rbp,rsp
    1597:	sub    rsp,0xc0
    159e:	mov    QWORD PTR [rsp+0x90],rbx
    15a6:	mov    QWORD PTR [rsp+0x98],r12
    15ae:	mov    QWORD PTR [rsp+0xa0],r13
    15b6:	mov    QWORD PTR [rsp+0xa8],r14
    15be:	mov    QWORD PTR [rsp+0xb0],r15
    15c6:	mov    r15,rdi
    15c9:	mov    QWORD PTR [rsp+0x18],0x0
    15d2:	mov    QWORD PTR [rsp],rsi
    15d6:	mov    QWORD PTR [rsp+0x8],rdx
    15db:	mov    QWORD PTR [rsp+0x10],rcx
    15e0:	mov    r13,rcx
    15e3:	lea    r14,[rsp+0x60]
    15e8:	lea    rbx,[rsp+0x20]
    15ed:	mov    r12,rsi
    15f0:	mov    QWORD PTR [rsp+0x80],rdx
    15f8:	mov    rdx,QWORD PTR [rsp+0x80]
    1600:	mov    rsi,r12
    1603:	mov    rdi,r15
    1606:	call   160b <botlish_fn_13+0x78>
			1607: R_X86_64_PLT32	botlish_fn_10-0x4 ; peek<str, int>
    160b:	test   rdx,rdx
    160e:	je     192b <botlish_fn_13+0x398>
    1614:	cmp    rax,0x22
    1618:	mov    QWORD PTR [rsp+0x88],rax
    1620:	je     1724 <botlish_fn_13+0x191>
    1626:	mov    QWORD PTR [rsp+0x18],0x3
    162f:	mov    rsi,QWORD PTR [rsp+0x80]
    1637:	test   rsi,0x1
    163e:	je     1660 <botlish_fn_13+0xcd>
    1644:	mov    rdi,rsi
    1647:	add    rdi,0x2
    164b:	seto   r8b
    164f:	test   r8b,r8b
    1652:	jne    1660 <botlish_fn_13+0xcd>
    1658:	mov    rsi,rdi
    165b:	jmp    1670 <botlish_fn_13+0xdd>
    1660:	mov    edx,0x3
    1665:	mov    rdi,r15
    1668:	call   166d <botlish_fn_13+0xda>
			1669: R_X86_64_PLT32	rt_int_add-0x4
    166d:	mov    rsi,rax
    1670:	mov    QWORD PTR [rsp+0x8],rsi
    1675:	mov    rax,QWORD PTR [rsp+0x88]
    167d:	mov    QWORD PTR [rsp+0x80],rsi
    1685:	lea    rcx,[rax+0x1]
    1689:	cmp    rcx,0x101
    1690:	jb     16a3 <botlish_fn_13+0x110>
    1696:	mov    rsi,QWORD PTR [rsp+0x88]
    169e:	jmp    16bf <botlish_fn_13+0x12c>
    16a3:	mov    rdi,r15
    16a6:	mov    rax,QWORD PTR [rdi+rcx*8+0x648]
    16ae:	test   rax,rax
    16b1:	jne    16c7 <botlish_fn_13+0x134>
    16b7:	mov    rsi,QWORD PTR [rsp+0x88]
    16bf:	mov    rdi,r15
    16c2:	call   16c7 <botlish_fn_13+0x134>
			16c3: R_X86_64_PLT32	rt_short_to_str-0x4
    16c7:	mov    QWORD PTR [rsp+0x18],rax
    16cc:	mov    QWORD PTR [rsp+0x60],0x0
    16d5:	mov    QWORD PTR [rsp+0x68],r13
    16da:	mov    QWORD PTR [rsp+0x70],0x0
    16e3:	mov    QWORD PTR [rsp+0x78],rax
    16e8:	mov    esi,0x2
    16ed:	mov    edx,0x4
    16f2:	mov    rcx,r14
    16f5:	mov    rdi,r15
    16f8:	call   16fd <botlish_fn_13+0x16a>
			16f9: R_X86_64_PLT32	rt_construct-0x4
    16fd:	test   rax,rax
    1700:	je     192b <botlish_fn_13+0x398>
    1706:	mov    QWORD PTR [rsp],r12
    170a:	mov    rsi,QWORD PTR [rsp+0x80]
    1712:	mov    QWORD PTR [rsp+0x8],rsi
    1717:	mov    QWORD PTR [rsp+0x10],rax
    171c:	mov    r13,rax
    171f:	jmp    15f8 <botlish_fn_13+0x65>
    1724:	mov    QWORD PTR [rsp+0x18],0x3
    172d:	mov    rsi,QWORD PTR [rsp+0x80]
    1735:	test   rsi,0x1
    173c:	je     175c <botlish_fn_13+0x1c9>
    1742:	mov    rsi,QWORD PTR [rsp+0x80]
    174a:	mov    rdx,rsi
    174d:	add    rdx,0x2
    1751:	seto   al
    1754:	test   al,al
    1756:	je     1774 <botlish_fn_13+0x1e1>
    175c:	mov    edx,0x3
    1761:	mov    rsi,QWORD PTR [rsp+0x80]
    1769:	mov    rdi,r15
    176c:	call   1771 <botlish_fn_13+0x1de>
			176d: R_X86_64_PLT32	rt_int_add-0x4
    1771:	mov    rdx,rax
    1774:	mov    QWORD PTR [rsp+0x18],rdx
    1779:	mov    rcx,rbx
    177c:	mov    rsi,r12
    177f:	mov    rdi,r15
    1782:	call   1787 <botlish_fn_13+0x1f4>
			1783: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1787:	test   rax,rax
    178a:	mov    rsi,rax
    178d:	je     192b <botlish_fn_13+0x398>
    1793:	mov    rdx,QWORD PTR [rsp+0x20]
    1798:	mov    rcx,QWORD PTR [rsp+0x28]
    179d:	mov    rdi,r15
    17a0:	mov    rax,QWORD PTR [rdi+0x10]
    17a4:	mov    r8,QWORD PTR [rax+0x28]
    17a8:	call   17ad <botlish_fn_13+0x21a>
			17a9: R_X86_64_PLT32	rt_str_region_eq-0x4
    17ad:	cmp    rax,0x6
    17b1:	je     1879 <botlish_fn_13+0x2e6>
    17b7:	xor    rsi,rsi
    17ba:	lea    rcx,[rsp+0x50]
    17bf:	mov    QWORD PTR [rsp+0x50],0x0
    17c8:	mov    QWORD PTR [rsp+0x58],r13
    17cd:	mov    edx,0x2
    17d2:	mov    rdi,r15
    17d5:	call   17da <botlish_fn_13+0x247>
			17d6: R_X86_64_PLT32	rt_construct-0x4
    17da:	test   rax,rax
    17dd:	je     192b <botlish_fn_13+0x398>
    17e3:	mov    QWORD PTR [rsp],rax
    17e7:	mov    rbx,rax
    17ea:	mov    QWORD PTR [rsp+0x10],0x3
    17f3:	mov    rsi,QWORD PTR [rsp+0x80]
    17fb:	test   rsi,0x1
    1802:	je     182a <botlish_fn_13+0x297>
    1808:	mov    rsi,QWORD PTR [rsp+0x80]
    1810:	mov    rdx,rsi
    1813:	add    rdx,0x2
    1817:	seto   al
    181a:	test   al,al
    181c:	jne    182a <botlish_fn_13+0x297>
    1822:	mov    rax,rbx
    1825:	jmp    1845 <botlish_fn_13+0x2b2>
    182a:	mov    edx,0x3
    182f:	mov    rsi,QWORD PTR [rsp+0x80]
    1837:	mov    rdi,r15
    183a:	call   183f <botlish_fn_13+0x2ac>
			183b: R_X86_64_PLT32	rt_int_add-0x4
    183f:	mov    rdx,rax
    1842:	mov    rax,rbx
    1845:	mov    rbx,QWORD PTR [rsp+0x90]
    184d:	mov    r12,QWORD PTR [rsp+0x98]
    1855:	mov    r13,QWORD PTR [rsp+0xa0]
    185d:	mov    r14,QWORD PTR [rsp+0xa8]
    1865:	mov    r15,QWORD PTR [rsp+0xb0]
    186d:	add    rsp,0xc0
    1874:	mov    rsp,rbp
    1877:	pop    rbp
    1878:	ret
    1879:	mov    QWORD PTR [rsp+0x18],0x5
    1882:	mov    rsi,QWORD PTR [rsp+0x80]
    188a:	test   rsi,0x1
    1891:	je     18bd <botlish_fn_13+0x32a>
    1897:	mov    rsi,QWORD PTR [rsp+0x80]
    189f:	add    rsi,0x4
    18a3:	seto   dil
    18a7:	test   dil,dil
    18aa:	jne    18bd <botlish_fn_13+0x32a>
    18b0:	mov    QWORD PTR [rsp+0x80],rsi
    18b8:	jmp    18dd <botlish_fn_13+0x34a>
    18bd:	mov    edx,0x5
    18c2:	mov    rsi,QWORD PTR [rsp+0x80]
    18ca:	mov    rdi,r15
    18cd:	call   18d2 <botlish_fn_13+0x33f>
			18ce: R_X86_64_PLT32	rt_int_add-0x4
    18d2:	mov    rsi,rax
    18d5:	mov    QWORD PTR [rsp+0x80],rax
    18dd:	mov    QWORD PTR [rsp+0x8],rsi
    18e2:	mov    rdi,r15
    18e5:	mov    rax,QWORD PTR [rdi+0x10]
    18e9:	mov    rax,QWORD PTR [rax+0x28]
    18ed:	mov    QWORD PTR [rsp+0x18],rax
    18f2:	lea    rcx,[rsp+0x30]
    18f7:	mov    QWORD PTR [rsp+0x30],0x0
    1900:	mov    QWORD PTR [rsp+0x38],r13
    1905:	mov    QWORD PTR [rsp+0x40],0x0
    190e:	mov    QWORD PTR [rsp+0x48],rax
    1913:	mov    esi,0x2
    1918:	mov    edx,0x4
    191d:	call   1922 <botlish_fn_13+0x38f>
			191e: R_X86_64_PLT32	rt_construct-0x4
    1922:	test   rax,rax
    1925:	jne    1965 <botlish_fn_13+0x3d2>
    192b:	xor    rdx,rdx
    192e:	mov    rax,rdx
    1931:	mov    rbx,QWORD PTR [rsp+0x90]
    1939:	mov    r12,QWORD PTR [rsp+0x98]
    1941:	mov    r13,QWORD PTR [rsp+0xa0]
    1949:	mov    r14,QWORD PTR [rsp+0xa8]
    1951:	mov    r15,QWORD PTR [rsp+0xb0]
    1959:	add    rsp,0xc0
    1960:	mov    rsp,rbp
    1963:	pop    rbp
    1964:	ret
    1965:	mov    QWORD PTR [rsp],r12
    1969:	mov    rsi,QWORD PTR [rsp+0x80]
    1971:	mov    QWORD PTR [rsp+0x8],rsi
    1976:	mov    QWORD PTR [rsp+0x10],rax
    197b:	mov    r13,rax
    197e:	jmp    15f8 <botlish_fn_13+0x65>

0000000000001983 <botlish_entry_13: scan_quoted<str, int, str>>:
    1983:	push   rbp
    1984:	mov    rbp,rsp
    1987:	ud2

0000000000001989 <botlish_fn_14: scan_field<str, int>>:
    1989:	push   rbp
    198a:	mov    rbp,rsp
    198d:	sub    rsp,0x50
    1991:	mov    QWORD PTR [rsp+0x30],rbx
    1996:	mov    QWORD PTR [rsp+0x38],r12
    199b:	mov    QWORD PTR [rsp+0x40],r13
    19a0:	mov    r12,rdi
    19a3:	mov    r13,rdx
    19a6:	mov    QWORD PTR [rsp+0x10],0x0
    19af:	mov    QWORD PTR [rsp],rsi
    19b3:	mov    rbx,rsi
    19b6:	mov    QWORD PTR [rsp+0x8],rdx
    19bb:	lea    rcx,[rsp+0x18]
    19c0:	mov    rdx,r13
    19c3:	mov    rsi,rbx
    19c6:	mov    rdi,r12
    19c9:	call   19ce <botlish_fn_14+0x45>
			19ca: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    19ce:	test   rax,rax
    19d1:	mov    rsi,rax
    19d4:	je     1a9f <botlish_fn_14+0x116>
    19da:	mov    rdx,QWORD PTR [rsp+0x18]
    19df:	mov    rcx,QWORD PTR [rsp+0x20]
    19e4:	mov    rdi,r12
    19e7:	mov    rax,QWORD PTR [rdi+0x10]
    19eb:	mov    r8,QWORD PTR [rax+0x28]
    19ef:	call   19f4 <botlish_fn_14+0x6b>
			19f0: R_X86_64_PLT32	rt_str_region_eq-0x4
    19f4:	cmp    rax,0x6
    19f8:	je     1a30 <botlish_fn_14+0xa7>
    19fe:	mov    rcx,r13
    1a01:	mov    rsi,rbx
    1a04:	mov    rdi,r12
    1a07:	mov    rdx,rcx
    1a0a:	call   1a0f <botlish_fn_14+0x86>
			1a0b: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_unquoted<str, int, int>
    1a0f:	test   rax,rax
    1a12:	je     1a9f <botlish_fn_14+0x116>
    1a18:	mov    rbx,QWORD PTR [rsp+0x30]
    1a1d:	mov    r12,QWORD PTR [rsp+0x38]
    1a22:	mov    r13,QWORD PTR [rsp+0x40]
    1a27:	add    rsp,0x50
    1a2b:	mov    rsp,rbp
    1a2e:	pop    rbp
    1a2f:	ret
    1a30:	mov    rcx,r13
    1a33:	mov    QWORD PTR [rsp+0x10],0x3
    1a3c:	test   rcx,0x1
    1a43:	jne    1a51 <botlish_fn_14+0xc8>
    1a49:	mov    r13,rcx
    1a4c:	jmp    1a66 <botlish_fn_14+0xdd>
    1a51:	mov    rdx,rcx
    1a54:	add    rdx,0x2
    1a58:	mov    r13,rcx
    1a5b:	seto   al
    1a5e:	test   al,al
    1a60:	je     1a79 <botlish_fn_14+0xf0>
    1a66:	mov    edx,0x3
    1a6b:	mov    rsi,r13
    1a6e:	mov    rdi,r12
    1a71:	call   1a76 <botlish_fn_14+0xed>
			1a72: R_X86_64_PLT32	rt_int_add-0x4
    1a76:	mov    rdx,rax
    1a79:	mov    QWORD PTR [rsp+0x8],rdx
    1a7e:	mov    rdi,r12
    1a81:	mov    rax,QWORD PTR [rdi+0x10]
    1a85:	mov    rcx,QWORD PTR [rax+0x10]
    1a89:	mov    QWORD PTR [rsp+0x10],rcx
    1a8e:	mov    rsi,rbx
    1a91:	call   1a96 <botlish_fn_14+0x10d>
			1a92: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_quoted<str, int, str>
    1a96:	test   rax,rax
    1a99:	jne    1abd <botlish_fn_14+0x134>
    1a9f:	xor    rdx,rdx
    1aa2:	mov    rax,rdx
    1aa5:	mov    rbx,QWORD PTR [rsp+0x30]
    1aaa:	mov    r12,QWORD PTR [rsp+0x38]
    1aaf:	mov    r13,QWORD PTR [rsp+0x40]
    1ab4:	add    rsp,0x50
    1ab8:	mov    rsp,rbp
    1abb:	pop    rbp
    1abc:	ret
    1abd:	mov    rbx,QWORD PTR [rsp+0x30]
    1ac2:	mov    r12,QWORD PTR [rsp+0x38]
    1ac7:	mov    r13,QWORD PTR [rsp+0x40]
    1acc:	add    rsp,0x50
    1ad0:	mov    rsp,rbp
    1ad3:	pop    rbp
    1ad4:	ret

0000000000001ad5 <botlish_entry_14: scan_field<str, int>>:
    1ad5:	push   rbp
    1ad6:	mov    rbp,rsp
    1ad9:	ud2

0000000000001adb <botlish_fn_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1adb:	push   rbp
    1adc:	mov    rbp,rsp
    1adf:	sub    rsp,0xa0
    1ae6:	mov    QWORD PTR [rsp+0x70],rbx
    1aeb:	mov    QWORD PTR [rsp+0x78],r12
    1af0:	mov    QWORD PTR [rsp+0x80],r13
    1af8:	mov    QWORD PTR [rsp+0x88],r14
    1b00:	mov    QWORD PTR [rsp+0x90],r15
    1b08:	mov    r13,rdi
    1b0b:	mov    QWORD PTR [rsp+0x28],0x0
    1b14:	mov    QWORD PTR [rsp],rsi
    1b18:	mov    r15,rsi
    1b1b:	mov    QWORD PTR [rsp+0x8],rdx
    1b20:	mov    QWORD PTR [rsp+0x10],rcx
    1b25:	mov    QWORD PTR [rsp+0x50],rcx
    1b2a:	mov    QWORD PTR [rsp+0x18],r8
    1b2f:	mov    r12,r8
    1b32:	mov    QWORD PTR [rsp+0x20],r9
    1b37:	mov    rbx,r9
    1b3a:	mov    rsi,r15
    1b3d:	mov    rdi,r13
    1b40:	call   1b45 <botlish_fn_15+0x6a>
			1b41: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1b45:	test   rax,rax
    1b48:	je     1d7c <botlish_fn_15+0x2a1>
    1b4e:	mov    QWORD PTR [rsp+0x8],rax
    1b53:	mov    r8,rax
    1b56:	mov    QWORD PTR [rsp+0x28],rdx
    1b5b:	mov    r14,rdx
    1b5e:	lea    r9,[rsp+0x30]
    1b63:	mov    rcx,rbx
    1b66:	mov    rdx,r12
    1b69:	mov    rsi,QWORD PTR [rsp+0x50]
    1b6e:	mov    rdi,r13
    1b71:	call   1b76 <botlish_fn_15+0x9b>
			1b72: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_append<list[List[never], mutarray, int], str>
    1b76:	test   rax,rax
    1b79:	je     1d7c <botlish_fn_15+0x2a1>
    1b7f:	mov    QWORD PTR [rsp+0x8],rax
    1b84:	mov    QWORD PTR [rsp+0x68],rax
    1b89:	mov    rdx,QWORD PTR [rsp+0x30]
    1b8e:	mov    QWORD PTR [rsp+0x10],rdx
    1b93:	mov    QWORD PTR [rsp+0x60],rdx
    1b98:	mov    rcx,QWORD PTR [rsp+0x38]
    1b9d:	mov    QWORD PTR [rsp+0x18],rcx
    1ba2:	mov    QWORD PTR [rsp+0x58],rcx
    1ba7:	lea    rcx,[rsp+0x40]
    1bac:	mov    rdx,r14
    1baf:	mov    rsi,r15
    1bb2:	mov    rdi,r13
    1bb5:	call   1bba <botlish_fn_15+0xdf>
			1bb6: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1bba:	test   rax,rax
    1bbd:	mov    QWORD PTR [rsp+0x50],rax
    1bc2:	je     1d7c <botlish_fn_15+0x2a1>
    1bc8:	mov    r12,QWORD PTR [rsp+0x40]
    1bcd:	mov    rbx,QWORD PTR [rsp+0x48]
    1bd2:	mov    rdi,r13
    1bd5:	mov    rcx,QWORD PTR [rdi+0x10]
    1bd9:	mov    r8,QWORD PTR [rcx+0x18]
    1bdd:	mov    rcx,rbx
    1be0:	mov    rdx,r12
    1be3:	mov    rsi,QWORD PTR [rsp+0x50]
    1be8:	call   1bed <botlish_fn_15+0x112>
			1be9: R_X86_64_PLT32	rt_str_region_eq-0x4
    1bed:	cmp    rax,0x6
    1bf1:	je     1d0b <botlish_fn_15+0x230>
    1bf7:	mov    rdi,r13
    1bfa:	mov    rax,QWORD PTR [rdi+0x10]
    1bfe:	mov    r8,QWORD PTR [rax+0x20]
    1c02:	mov    rcx,rbx
    1c05:	mov    rdx,r12
    1c08:	mov    rsi,QWORD PTR [rsp+0x50]
    1c0d:	call   1c12 <botlish_fn_15+0x137>
			1c0e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c12:	cmp    rax,0x6
    1c16:	je     1c6d <botlish_fn_15+0x192>
    1c1c:	mov    rcx,QWORD PTR [rsp+0x58]
    1c21:	mov    rdx,QWORD PTR [rsp+0x60]
    1c26:	mov    rsi,QWORD PTR [rsp+0x68]
    1c2b:	mov    rdi,r13
    1c2e:	call   1c33 <botlish_fn_15+0x158>
			1c2f: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1c33:	test   rax,rax
    1c36:	je     1d7c <botlish_fn_15+0x2a1>
    1c3c:	mov    rdx,r14
    1c3f:	mov    rbx,QWORD PTR [rsp+0x70]
    1c44:	mov    r12,QWORD PTR [rsp+0x78]
    1c49:	mov    r13,QWORD PTR [rsp+0x80]
    1c51:	mov    r14,QWORD PTR [rsp+0x88]
    1c59:	mov    r15,QWORD PTR [rsp+0x90]
    1c61:	add    rsp,0xa0
    1c68:	mov    rsp,rbp
    1c6b:	pop    rbp
    1c6c:	ret
    1c6d:	mov    rcx,QWORD PTR [rsp+0x58]
    1c72:	mov    rdx,QWORD PTR [rsp+0x60]
    1c77:	mov    rsi,QWORD PTR [rsp+0x68]
    1c7c:	mov    rdi,r13
    1c7f:	call   1c84 <botlish_fn_15+0x1a9>
			1c80: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1c84:	test   rax,rax
    1c87:	je     1d7c <botlish_fn_15+0x2a1>
    1c8d:	mov    QWORD PTR [rsp],rax
    1c91:	mov    rbx,rax
    1c94:	mov    QWORD PTR [rsp+0x8],0x3
    1c9d:	mov    rdx,r14
    1ca0:	test   rdx,0x1
    1ca7:	je     1cc7 <botlish_fn_15+0x1ec>
    1cad:	mov    rdx,r14
    1cb0:	add    rdx,0x2
    1cb4:	seto   al
    1cb7:	test   al,al
    1cb9:	jne    1cc7 <botlish_fn_15+0x1ec>
    1cbf:	mov    rax,rbx
    1cc2:	jmp    1cdd <botlish_fn_15+0x202>
    1cc7:	mov    edx,0x3
    1ccc:	mov    rsi,r14
    1ccf:	mov    rdi,r13
    1cd2:	call   1cd7 <botlish_fn_15+0x1fc>
			1cd3: R_X86_64_PLT32	rt_int_add-0x4
    1cd7:	mov    rdx,rax
    1cda:	mov    rax,rbx
    1cdd:	mov    rbx,QWORD PTR [rsp+0x70]
    1ce2:	mov    r12,QWORD PTR [rsp+0x78]
    1ce7:	mov    r13,QWORD PTR [rsp+0x80]
    1cef:	mov    r14,QWORD PTR [rsp+0x88]
    1cf7:	mov    r15,QWORD PTR [rsp+0x90]
    1cff:	add    rsp,0xa0
    1d06:	mov    rsp,rbp
    1d09:	pop    rbp
    1d0a:	ret
    1d0b:	mov    rsi,r14
    1d0e:	mov    edx,0x3
    1d13:	mov    rcx,rdx
    1d16:	mov    QWORD PTR [rsp+0x20],0x3
    1d1f:	test   rsi,0x1
    1d26:	jne    1d34 <botlish_fn_15+0x259>
    1d2c:	mov    rdx,rcx
    1d2f:	jmp    1d49 <botlish_fn_15+0x26e>
    1d34:	mov    rdx,rsi
    1d37:	add    rdx,0x2
    1d3b:	seto   al
    1d3e:	test   al,al
    1d40:	je     1d54 <botlish_fn_15+0x279>
    1d46:	mov    rdx,rcx
    1d49:	mov    rdi,r13
    1d4c:	call   1d51 <botlish_fn_15+0x276>
			1d4d: R_X86_64_PLT32	rt_int_add-0x4
    1d51:	mov    rdx,rax
    1d54:	mov    QWORD PTR [rsp+0x20],rdx
    1d59:	mov    rcx,QWORD PTR [rsp+0x68]
    1d5e:	mov    rsi,r15
    1d61:	mov    rdi,r13
    1d64:	mov    r8,QWORD PTR [rsp+0x60]
    1d69:	mov    r9,QWORD PTR [rsp+0x58]
    1d6e:	call   1d73 <botlish_fn_15+0x298>
			1d6f: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[List[mutarray], mutarray, int]>
    1d73:	test   rax,rax
    1d76:	jne    1db0 <botlish_fn_15+0x2d5>
    1d7c:	xor    rdx,rdx
    1d7f:	mov    rax,rdx
    1d82:	mov    rbx,QWORD PTR [rsp+0x70]
    1d87:	mov    r12,QWORD PTR [rsp+0x78]
    1d8c:	mov    r13,QWORD PTR [rsp+0x80]
    1d94:	mov    r14,QWORD PTR [rsp+0x88]
    1d9c:	mov    r15,QWORD PTR [rsp+0x90]
    1da4:	add    rsp,0xa0
    1dab:	mov    rsp,rbp
    1dae:	pop    rbp
    1daf:	ret
    1db0:	mov    rbx,QWORD PTR [rsp+0x70]
    1db5:	mov    r12,QWORD PTR [rsp+0x78]
    1dba:	mov    r13,QWORD PTR [rsp+0x80]
    1dc2:	mov    r14,QWORD PTR [rsp+0x88]
    1dca:	mov    r15,QWORD PTR [rsp+0x90]
    1dd2:	add    rsp,0xa0
    1dd9:	mov    rsp,rbp
    1ddc:	pop    rbp
    1ddd:	ret

0000000000001dde <botlish_entry_15: scan_record<str, int, list[List[never], mutarray, int]>>:
    1dde:	push   rbp
    1ddf:	mov    rbp,rsp
    1de2:	ud2

0000000000001de4 <botlish_fn_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    1de4:	push   rbp
    1de5:	mov    rbp,rsp
    1de8:	sub    rsp,0xb0
    1def:	mov    QWORD PTR [rsp+0x80],rbx
    1df7:	mov    QWORD PTR [rsp+0x88],r12
    1dff:	mov    QWORD PTR [rsp+0x90],r13
    1e07:	mov    QWORD PTR [rsp+0x98],r14
    1e0f:	mov    QWORD PTR [rsp+0xa0],r15
    1e17:	mov    QWORD PTR [rsp+0x50],rdi
    1e1c:	mov    QWORD PTR [rsp+0x28],0x0
    1e25:	mov    QWORD PTR [rsp],rsi
    1e29:	mov    QWORD PTR [rsp+0x8],rdx
    1e2e:	mov    QWORD PTR [rsp+0x10],rcx
    1e33:	mov    QWORD PTR [rsp+0x18],r8
    1e38:	mov    QWORD PTR [rsp+0x20],r9
    1e3d:	lea    r15,[rsp+0x30]
    1e42:	lea    rbx,[rsp+0x40]
    1e47:	mov    r12,rsi
    1e4a:	mov    r13,rcx
    1e4d:	mov    QWORD PTR [rsp+0x58],r8
    1e52:	mov    QWORD PTR [rsp+0x60],r9
    1e57:	mov    rsi,r12
    1e5a:	mov    rdi,QWORD PTR [rsp+0x50]
    1e5f:	call   1e64 <botlish_fn_16+0x80>
			1e60: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_field<str, int>
    1e64:	mov    QWORD PTR [rsp+0x78],rdx
    1e69:	test   rax,rax
    1e6c:	je     1fc7 <botlish_fn_16+0x1e3>
    1e72:	mov    QWORD PTR [rsp+0x8],rax
    1e77:	mov    rdx,QWORD PTR [rsp+0x78]
    1e7c:	mov    r8,rax
    1e7f:	mov    QWORD PTR [rsp+0x28],rdx
    1e84:	mov    rcx,QWORD PTR [rsp+0x60]
    1e89:	mov    rdx,QWORD PTR [rsp+0x58]
    1e8e:	mov    rsi,r13
    1e91:	mov    rdi,QWORD PTR [rsp+0x50]
    1e96:	mov    r9,r15
    1e99:	call   1e9e <botlish_fn_16+0xba>
			1e9a: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[List[mutarray], mutarray, int], str>
    1e9e:	test   rax,rax
    1ea1:	je     1fc7 <botlish_fn_16+0x1e3>
    1ea7:	mov    QWORD PTR [rsp+0x8],rax
    1eac:	mov    QWORD PTR [rsp+0x70],rax
    1eb1:	mov    rdx,QWORD PTR [rsp+0x30]
    1eb6:	mov    QWORD PTR [rsp+0x58],rdx
    1ebb:	mov    QWORD PTR [rsp+0x10],rdx
    1ec0:	mov    rcx,QWORD PTR [rsp+0x38]
    1ec5:	mov    QWORD PTR [rsp+0x18],rcx
    1eca:	mov    QWORD PTR [rsp+0x60],rcx
    1ecf:	mov    rcx,rbx
    1ed2:	mov    rdx,QWORD PTR [rsp+0x78]
    1ed7:	mov    rsi,r12
    1eda:	mov    rdi,QWORD PTR [rsp+0x50]
    1edf:	call   1ee4 <botlish_fn_16+0x100>
			1ee0: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1ee4:	test   rax,rax
    1ee7:	mov    QWORD PTR [rsp+0x68],rax
    1eec:	je     1fc7 <botlish_fn_16+0x1e3>
    1ef2:	mov    r13,QWORD PTR [rsp+0x40]
    1ef7:	mov    r14,QWORD PTR [rsp+0x48]
    1efc:	mov    rdi,QWORD PTR [rsp+0x50]
    1f01:	mov    rcx,QWORD PTR [rdi+0x10]
    1f05:	mov    r8,QWORD PTR [rcx+0x18]
    1f09:	mov    rcx,r14
    1f0c:	mov    rdx,r13
    1f0f:	mov    rsi,QWORD PTR [rsp+0x68]
    1f14:	call   1f19 <botlish_fn_16+0x135>
			1f15: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f19:	cmp    rax,0x6
    1f1d:	je     208d <botlish_fn_16+0x2a9>
    1f23:	mov    rdi,QWORD PTR [rsp+0x50]
    1f28:	mov    rax,QWORD PTR [rdi+0x10]
    1f2c:	mov    r8,QWORD PTR [rax+0x20]
    1f30:	mov    rcx,r14
    1f33:	mov    rdx,r13
    1f36:	mov    rsi,QWORD PTR [rsp+0x68]
    1f3b:	call   1f40 <botlish_fn_16+0x15c>
			1f3c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f40:	cmp    rax,0x6
    1f44:	je     1fa5 <botlish_fn_16+0x1c1>
    1f4a:	mov    rcx,QWORD PTR [rsp+0x60]
    1f4f:	mov    rdx,QWORD PTR [rsp+0x58]
    1f54:	mov    rsi,QWORD PTR [rsp+0x70]
    1f59:	mov    rdi,QWORD PTR [rsp+0x50]
    1f5e:	call   1f63 <botlish_fn_16+0x17f>
			1f5f: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1f63:	test   rax,rax
    1f66:	je     1fc7 <botlish_fn_16+0x1e3>
    1f6c:	mov    rdx,QWORD PTR [rsp+0x78]
    1f71:	mov    rbx,QWORD PTR [rsp+0x80]
    1f79:	mov    r12,QWORD PTR [rsp+0x88]
    1f81:	mov    r13,QWORD PTR [rsp+0x90]
    1f89:	mov    r14,QWORD PTR [rsp+0x98]
    1f91:	mov    r15,QWORD PTR [rsp+0xa0]
    1f99:	add    rsp,0xb0
    1fa0:	mov    rsp,rbp
    1fa3:	pop    rbp
    1fa4:	ret
    1fa5:	mov    rcx,QWORD PTR [rsp+0x60]
    1faa:	mov    rdx,QWORD PTR [rsp+0x58]
    1faf:	mov    rsi,QWORD PTR [rsp+0x70]
    1fb4:	mov    rdi,QWORD PTR [rsp+0x50]
    1fb9:	call   1fbe <botlish_fn_16+0x1da>
			1fba: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    1fbe:	test   rax,rax
    1fc1:	jne    2001 <botlish_fn_16+0x21d>
    1fc7:	xor    rdx,rdx
    1fca:	mov    rax,rdx
    1fcd:	mov    rbx,QWORD PTR [rsp+0x80]
    1fd5:	mov    r12,QWORD PTR [rsp+0x88]
    1fdd:	mov    r13,QWORD PTR [rsp+0x90]
    1fe5:	mov    r14,QWORD PTR [rsp+0x98]
    1fed:	mov    r15,QWORD PTR [rsp+0xa0]
    1ff5:	add    rsp,0xb0
    1ffc:	mov    rsp,rbp
    1fff:	pop    rbp
    2000:	ret
    2001:	mov    QWORD PTR [rsp],rax
    2005:	mov    rbx,rax
    2008:	mov    QWORD PTR [rsp+0x8],0x3
    2011:	mov    rdx,QWORD PTR [rsp+0x78]
    2016:	test   rdx,0x1
    201d:	je     203f <botlish_fn_16+0x25b>
    2023:	mov    rdx,QWORD PTR [rsp+0x78]
    2028:	add    rdx,0x2
    202c:	seto   al
    202f:	test   al,al
    2031:	jne    203f <botlish_fn_16+0x25b>
    2037:	mov    rax,rbx
    203a:	jmp    2059 <botlish_fn_16+0x275>
    203f:	mov    edx,0x3
    2044:	mov    rsi,QWORD PTR [rsp+0x78]
    2049:	mov    rdi,QWORD PTR [rsp+0x50]
    204e:	call   2053 <botlish_fn_16+0x26f>
			204f: R_X86_64_PLT32	rt_int_add-0x4
    2053:	mov    rdx,rax
    2056:	mov    rax,rbx
    2059:	mov    rbx,QWORD PTR [rsp+0x80]
    2061:	mov    r12,QWORD PTR [rsp+0x88]
    2069:	mov    r13,QWORD PTR [rsp+0x90]
    2071:	mov    r14,QWORD PTR [rsp+0x98]
    2079:	mov    r15,QWORD PTR [rsp+0xa0]
    2081:	add    rsp,0xb0
    2088:	mov    rsp,rbp
    208b:	pop    rbp
    208c:	ret
    208d:	mov    rsi,QWORD PTR [rsp+0x78]
    2092:	mov    edx,0x3
    2097:	mov    r10,rdx
    209a:	mov    QWORD PTR [rsp+0x20],0x3
    20a3:	test   rsi,0x1
    20aa:	jne    20b8 <botlish_fn_16+0x2d4>
    20b0:	mov    rdx,r10
    20b3:	jmp    20cd <botlish_fn_16+0x2e9>
    20b8:	mov    rdx,rsi
    20bb:	add    rdx,0x2
    20bf:	seto   al
    20c2:	test   al,al
    20c4:	je     20da <botlish_fn_16+0x2f6>
    20ca:	mov    rdx,r10
    20cd:	mov    rdi,QWORD PTR [rsp+0x50]
    20d2:	call   20d7 <botlish_fn_16+0x2f3>
			20d3: R_X86_64_PLT32	rt_int_add-0x4
    20d7:	mov    rdx,rax
    20da:	mov    QWORD PTR [rsp],r12
    20de:	mov    QWORD PTR [rsp+0x8],rdx
    20e3:	mov    rsi,QWORD PTR [rsp+0x70]
    20e8:	mov    QWORD PTR [rsp+0x10],rsi
    20ed:	mov    rax,QWORD PTR [rsp+0x58]
    20f2:	mov    QWORD PTR [rsp+0x18],rax
    20f7:	mov    rcx,QWORD PTR [rsp+0x60]
    20fc:	mov    QWORD PTR [rsp+0x20],rcx
    2101:	mov    r13,rsi
    2104:	jmp    1e57 <botlish_fn_16+0x73>

0000000000002109 <botlish_entry_16: scan_record<str, int, list[List[mutarray], mutarray, int]>>:
    2109:	push   rbp
    210a:	mov    rbp,rsp
    210d:	ud2

000000000000210f <botlish_fn_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    210f:	push   rbp
    2110:	mov    rbp,rsp
    2113:	sub    rsp,0xa0
    211a:	mov    QWORD PTR [rsp+0x70],rbx
    211f:	mov    QWORD PTR [rsp+0x78],r12
    2124:	mov    QWORD PTR [rsp+0x80],r13
    212c:	mov    QWORD PTR [rsp+0x88],r14
    2134:	mov    QWORD PTR [rsp+0x90],r15
    213c:	mov    r12,rdi
    213f:	mov    QWORD PTR [rsp+0x28],0x0
    2148:	mov    QWORD PTR [rsp+0x30],0x0
    2151:	mov    QWORD PTR [rsp+0x38],0x0
    215a:	mov    QWORD PTR [rsp],rsi
    215e:	mov    rbx,rsi
    2161:	mov    QWORD PTR [rsp+0x8],rdx
    2166:	mov    QWORD PTR [rsp+0x60],rdx
    216b:	mov    QWORD PTR [rsp+0x10],rcx
    2170:	mov    r15,rcx
    2173:	mov    QWORD PTR [rsp+0x18],r8
    2178:	mov    r14,r8
    217b:	mov    QWORD PTR [rsp+0x20],r9
    2180:	mov    r13,r9
    2183:	mov    rsi,rbx
    2186:	mov    rdi,r12
    2189:	call   218e <botlish_fn_17+0x7f>
			218a: R_X86_64_PLT32	rt_str_len-0x4
    218e:	mov    rdx,QWORD PTR [rsp+0x60]
    2193:	mov    rcx,rdx
    2196:	sar    rcx,1
    2199:	sar    rax,1
    219c:	cmp    rcx,rax
    219f:	jge    2284 <botlish_fn_17+0x175>
    21a5:	lea    rsi,[rsp+0x40]
    21aa:	mov    rdi,r12
    21ad:	call   21b2 <botlish_fn_17+0xa3>
			21ae: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    21b2:	test   rax,rax
    21b5:	je     229e <botlish_fn_17+0x18f>
    21bb:	mov    QWORD PTR [rsp+0x28],rax
    21c0:	mov    rcx,rax
    21c3:	mov    r8,QWORD PTR [rsp+0x40]
    21c8:	mov    QWORD PTR [rsp+0x30],r8
    21cd:	mov    r9,QWORD PTR [rsp+0x48]
    21d2:	mov    QWORD PTR [rsp+0x38],r9
    21d7:	mov    rdx,QWORD PTR [rsp+0x60]
    21dc:	mov    rsi,rbx
    21df:	mov    rdi,r12
    21e2:	call   21e7 <botlish_fn_17+0xd8>
			21e3: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    21e7:	test   rax,rax
    21ea:	je     229e <botlish_fn_17+0x18f>
    21f0:	mov    QWORD PTR [rsp+0x8],rax
    21f5:	mov    r8,rax
    21f8:	mov    QWORD PTR [rsp+0x28],rdx
    21fd:	mov    QWORD PTR [rsp+0x60],rdx
    2202:	lea    r9,[rsp+0x50]
    2207:	mov    rcx,r13
    220a:	mov    rdx,r14
    220d:	mov    rsi,r15
    2210:	mov    rdi,r12
    2213:	call   2218 <botlish_fn_17+0x109>
			2214: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[List[never], mutarray, int], list>
    2218:	test   rax,rax
    221b:	je     229e <botlish_fn_17+0x18f>
    2221:	mov    QWORD PTR [rsp+0x8],rax
    2226:	mov    rcx,rax
    2229:	mov    r8,QWORD PTR [rsp+0x50]
    222e:	mov    QWORD PTR [rsp+0x10],r8
    2233:	mov    r9,QWORD PTR [rsp+0x58]
    2238:	mov    QWORD PTR [rsp+0x18],r9
    223d:	mov    rdx,QWORD PTR [rsp+0x60]
    2242:	mov    rsi,rbx
    2245:	mov    rdi,r12
    2248:	call   224d <botlish_fn_17+0x13e>
			2249: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    224d:	test   rax,rax
    2250:	je     229e <botlish_fn_17+0x18f>
    2256:	mov    rbx,QWORD PTR [rsp+0x70]
    225b:	mov    r12,QWORD PTR [rsp+0x78]
    2260:	mov    r13,QWORD PTR [rsp+0x80]
    2268:	mov    r14,QWORD PTR [rsp+0x88]
    2270:	mov    r15,QWORD PTR [rsp+0x90]
    2278:	add    rsp,0xa0
    227f:	mov    rsp,rbp
    2282:	pop    rbp
    2283:	ret
    2284:	mov    rcx,r13
    2287:	mov    rdx,r14
    228a:	mov    rsi,r15
    228d:	mov    rdi,r12
    2290:	call   2295 <botlish_fn_17+0x186>
			2291: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_finish<list[List[never], mutarray, int]>
    2295:	test   rax,rax
    2298:	jne    22cf <botlish_fn_17+0x1c0>
    229e:	xor    rax,rax
    22a1:	mov    rbx,QWORD PTR [rsp+0x70]
    22a6:	mov    r12,QWORD PTR [rsp+0x78]
    22ab:	mov    r13,QWORD PTR [rsp+0x80]
    22b3:	mov    r14,QWORD PTR [rsp+0x88]
    22bb:	mov    r15,QWORD PTR [rsp+0x90]
    22c3:	add    rsp,0xa0
    22ca:	mov    rsp,rbp
    22cd:	pop    rbp
    22ce:	ret
    22cf:	mov    rbx,QWORD PTR [rsp+0x70]
    22d4:	mov    r12,QWORD PTR [rsp+0x78]
    22d9:	mov    r13,QWORD PTR [rsp+0x80]
    22e1:	mov    r14,QWORD PTR [rsp+0x88]
    22e9:	mov    r15,QWORD PTR [rsp+0x90]
    22f1:	add    rsp,0xa0
    22f8:	mov    rsp,rbp
    22fb:	pop    rbp
    22fc:	ret

00000000000022fd <botlish_entry_17: scan_records<str, int, list[List[never], mutarray, int]>>:
    22fd:	push   rbp
    22fe:	mov    rbp,rsp
    2301:	mov    rsi,QWORD PTR [rdx]
    2304:	mov    r10,QWORD PTR [rdx+0x8]
    2308:	mov    rcx,QWORD PTR [rdx+0x10]
    230c:	mov    r8,QWORD PTR [rdx+0x18]
    2310:	mov    r9,QWORD PTR [rdx+0x20]
    2314:	mov    rdx,r10
    2317:	call   231c <botlish_entry_17+0x1f>
			2318: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    231c:	mov    rsp,rbp
    231f:	pop    rbp
    2320:	ret
    2321:	add    BYTE PTR [rax],al
    2323:	add    BYTE PTR [rax],al
    2325:	add    BYTE PTR [rax],al
	...

0000000000002328 <botlish_fn_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    2328:	push   rbp
    2329:	mov    rbp,rsp
    232c:	sub    rsp,0xb0
    2333:	mov    QWORD PTR [rsp+0x80],rbx
    233b:	mov    QWORD PTR [rsp+0x88],r12
    2343:	mov    QWORD PTR [rsp+0x90],r13
    234b:	mov    QWORD PTR [rsp+0x98],r14
    2353:	mov    QWORD PTR [rsp+0xa0],r15
    235b:	mov    r15,rdi
    235e:	mov    QWORD PTR [rsp+0x28],0x0
    2367:	mov    QWORD PTR [rsp+0x30],0x0
    2370:	mov    QWORD PTR [rsp+0x38],0x0
    2379:	mov    QWORD PTR [rsp],rsi
    237d:	mov    QWORD PTR [rsp+0x8],rdx
    2382:	mov    r14,rdx
    2385:	mov    QWORD PTR [rsp+0x10],rcx
    238a:	mov    QWORD PTR [rsp+0x18],r8
    238f:	mov    QWORD PTR [rsp+0x20],r9
    2394:	lea    r13,[rsp+0x40]
    2399:	lea    rbx,[rsp+0x50]
    239e:	mov    r12,rsi
    23a1:	mov    QWORD PTR [rsp+0x60],rcx
    23a6:	mov    QWORD PTR [rsp+0x68],r8
    23ab:	mov    QWORD PTR [rsp+0x70],r9
    23b0:	mov    rsi,r12
    23b3:	mov    rdi,r15
    23b6:	call   23bb <botlish_fn_18+0x93>
			23b7: R_X86_64_PLT32	rt_str_len-0x4
    23bb:	mov    rcx,r14
    23be:	and    rcx,rax
    23c1:	mov    rdx,rax
    23c4:	test   rcx,0x1
    23cb:	jne    23f1 <botlish_fn_18+0xc9>
    23d1:	mov    rsi,r14
    23d4:	mov    rdi,r15
    23d7:	call   23dc <botlish_fn_18+0xb4>
			23d8: R_X86_64_PLT32	rt_int_cmp-0x4
    23dc:	mov    ecx,0x2
    23e1:	test   rax,rax
    23e4:	cmovge rcx,QWORD PTR [rip+0x164]        # 2550 <botlish_fn_18+0x228>
    23ec:	jmp    2404 <botlish_fn_18+0xdc>
    23f1:	mov    ecx,0x2
    23f6:	mov    rdi,r14
    23f9:	cmp    rdi,rdx
    23fc:	cmovge rcx,QWORD PTR [rip+0x14c]        # 2550 <botlish_fn_18+0x228>
    2404:	cmp    rcx,0x6
    2408:	je     24c1 <botlish_fn_18+0x199>
    240e:	mov    rsi,r13
    2411:	mov    rdi,r15
    2414:	call   2419 <botlish_fn_18+0xf1>
			2415: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    2419:	test   rax,rax
    241c:	je     24e1 <botlish_fn_18+0x1b9>
    2422:	mov    QWORD PTR [rsp+0x28],rax
    2427:	mov    rcx,rax
    242a:	mov    r8,QWORD PTR [rsp+0x40]
    242f:	mov    QWORD PTR [rsp+0x30],r8
    2434:	mov    r9,QWORD PTR [rsp+0x48]
    2439:	mov    QWORD PTR [rsp+0x38],r9
    243e:	mov    rdx,r14
    2441:	mov    rsi,r12
    2444:	mov    rdi,r15
    2447:	call   244c <botlish_fn_18+0x124>
			2448: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_record<str, int, list[List[never], mutarray, int]>
    244c:	test   rax,rax
    244f:	je     24e1 <botlish_fn_18+0x1b9>
    2455:	mov    QWORD PTR [rsp+0x8],rax
    245a:	mov    r8,rax
    245d:	mov    QWORD PTR [rsp+0x28],rdx
    2462:	mov    r14,rdx
    2465:	mov    rsi,QWORD PTR [rsp+0x60]
    246a:	mov    rdx,QWORD PTR [rsp+0x68]
    246f:	mov    rcx,QWORD PTR [rsp+0x70]
    2474:	mov    rdi,r15
    2477:	mov    r9,rbx
    247a:	call   247f <botlish_fn_18+0x157>
			247b: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[List[mutarray], mutarray, int], list>
    247f:	test   rax,rax
    2482:	je     24e1 <botlish_fn_18+0x1b9>
    2488:	mov    rdx,QWORD PTR [rsp+0x50]
    248d:	mov    rcx,QWORD PTR [rsp+0x58]
    2492:	mov    QWORD PTR [rsp],r12
    2496:	mov    rsi,r14
    2499:	mov    QWORD PTR [rsp+0x8],rsi
    249e:	mov    QWORD PTR [rsp+0x10],rax
    24a3:	mov    QWORD PTR [rsp+0x18],rdx
    24a8:	mov    QWORD PTR [rsp+0x20],rcx
    24ad:	mov    QWORD PTR [rsp+0x60],rax
    24b2:	mov    QWORD PTR [rsp+0x68],rdx
    24b7:	mov    QWORD PTR [rsp+0x70],rcx
    24bc:	jmp    23b0 <botlish_fn_18+0x88>
    24c1:	mov    rcx,QWORD PTR [rsp+0x70]
    24c6:	mov    rdx,QWORD PTR [rsp+0x68]
    24cb:	mov    rsi,QWORD PTR [rsp+0x60]
    24d0:	mov    rdi,r15
    24d3:	call   24d8 <botlish_fn_18+0x1b0>
			24d4: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[List[mutarray], mutarray, int]>
    24d8:	test   rax,rax
    24db:	jne    2518 <botlish_fn_18+0x1f0>
    24e1:	xor    rax,rax
    24e4:	mov    rbx,QWORD PTR [rsp+0x80]
    24ec:	mov    r12,QWORD PTR [rsp+0x88]
    24f4:	mov    r13,QWORD PTR [rsp+0x90]
    24fc:	mov    r14,QWORD PTR [rsp+0x98]
    2504:	mov    r15,QWORD PTR [rsp+0xa0]
    250c:	add    rsp,0xb0
    2513:	mov    rsp,rbp
    2516:	pop    rbp
    2517:	ret
    2518:	mov    rbx,QWORD PTR [rsp+0x80]
    2520:	mov    r12,QWORD PTR [rsp+0x88]
    2528:	mov    r13,QWORD PTR [rsp+0x90]
    2530:	mov    r14,QWORD PTR [rsp+0x98]
    2538:	mov    r15,QWORD PTR [rsp+0xa0]
    2540:	add    rsp,0xb0
    2547:	mov    rsp,rbp
    254a:	pop    rbp
    254b:	ret
    254c:	add    BYTE PTR [rax],al
    254e:	add    BYTE PTR [rax],al
    2550:	(bad)
    2551:	add    BYTE PTR [rax],al
    2553:	add    BYTE PTR [rax],al
    2555:	add    BYTE PTR [rax],al
	...

0000000000002558 <botlish_entry_18: scan_records<str, int, list[List[mutarray], mutarray, int]>>:
    2558:	push   rbp
    2559:	mov    rbp,rsp
    255c:	mov    rsi,QWORD PTR [rdx]
    255f:	mov    r10,QWORD PTR [rdx+0x8]
    2563:	mov    rcx,QWORD PTR [rdx+0x10]
    2567:	mov    r8,QWORD PTR [rdx+0x18]
    256b:	mov    r9,QWORD PTR [rdx+0x20]
    256f:	mov    rdx,r10
    2572:	call   2577 <botlish_entry_18+0x1f>
			2573: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[List[mutarray], mutarray, int]>
    2577:	mov    rsp,rbp
    257a:	pop    rbp
    257b:	ret

000000000000257c <botlish_fn_19: csv_parse<str>>:
    257c:	push   rbp
    257d:	mov    rbp,rsp
    2580:	sub    rsp,0x50
    2584:	mov    QWORD PTR [rsp+0x40],r12
    2589:	mov    QWORD PTR [rsp+0x48],r13
    258e:	mov    r13,rdi
    2591:	mov    QWORD PTR [rsp+0x10],0x0
    259a:	mov    QWORD PTR [rsp+0x18],0x0
    25a3:	mov    QWORD PTR [rsp+0x20],0x0
    25ac:	mov    QWORD PTR [rsp],rsi
    25b0:	mov    r12,rsi
    25b3:	mov    QWORD PTR [rsp+0x8],0x1
    25bc:	lea    rsi,[rsp+0x28]
    25c1:	mov    rdi,r13
    25c4:	call   25c9 <botlish_fn_19+0x4d>
			25c5: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunked_new<generic>
    25c9:	test   rax,rax
    25cc:	je     2607 <botlish_fn_19+0x8b>
    25d2:	mov    QWORD PTR [rsp+0x10],rax
    25d7:	mov    rcx,rax
    25da:	mov    r8,QWORD PTR [rsp+0x28]
    25df:	mov    QWORD PTR [rsp+0x18],r8
    25e4:	mov    r9,QWORD PTR [rsp+0x30]
    25e9:	mov    QWORD PTR [rsp+0x20],r9
    25ee:	mov    edx,0x1
    25f3:	mov    rsi,r12
    25f6:	mov    rdi,r13
    25f9:	call   25fe <botlish_fn_19+0x82>
			25fa: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_records<str, int, list[List[never], mutarray, int]>
    25fe:	test   rax,rax
    2601:	jne    261d <botlish_fn_19+0xa1>
    2607:	xor    rax,rax
    260a:	mov    r12,QWORD PTR [rsp+0x40]
    260f:	mov    r13,QWORD PTR [rsp+0x48]
    2614:	add    rsp,0x50
    2618:	mov    rsp,rbp
    261b:	pop    rbp
    261c:	ret
    261d:	mov    r12,QWORD PTR [rsp+0x40]
    2622:	mov    r13,QWORD PTR [rsp+0x48]
    2627:	add    rsp,0x50
    262b:	mov    rsp,rbp
    262e:	pop    rbp
    262f:	ret

0000000000002630 <botlish_entry_19: csv_parse<str>>:
    2630:	push   rbp
    2631:	mov    rbp,rsp
    2634:	mov    rsi,QWORD PTR [rdx]
    2637:	call   263c <botlish_entry_19+0xc>
			2638: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    263c:	mov    rsp,rbp
    263f:	pop    rbp
    2640:	ret

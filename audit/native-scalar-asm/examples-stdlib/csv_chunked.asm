; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 12781  (per function: 169 71 318 702 702 702 702 808 728 710 710 469 534 677 887 470 899 936 609 684 294)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> chunk_size<generic>
;   botlish_fn_2 / botlish_entry_2 -> chunked_new<generic>
;   botlish_fn_3 / botlish_entry_3 -> chunked_append<list[list<never>, mutarray, int], str>
;   botlish_fn_4 / botlish_entry_4 -> chunked_append<list[list<mutarray>, mutarray, int], str>
;   botlish_fn_5 / botlish_entry_5 -> chunked_append<list[list<never>, mutarray, int], list>
;   botlish_fn_6 / botlish_entry_6 -> chunked_append<list[list<mutarray>, mutarray, int], list>
;   botlish_fn_7 / botlish_entry_7 -> chunked_copy_chunks<list<never>, int, mutarray, int>
;   botlish_fn_8 / botlish_entry_8 -> chunked_copy_chunks<list<mutarray>, int, mutarray, int>
;   botlish_fn_9 / botlish_entry_9 -> chunked_finish<list[list<never>, mutarray, int]>
;   botlish_fn_10 / botlish_entry_10 -> chunked_finish<list[list<mutarray>, mutarray, int]>
;   botlish_fn_11 / botlish_entry_11 -> peek<str, int>
;   botlish_fn_12 / botlish_entry_12 -> peek<str, int>
;   botlish_fn_13 / botlish_entry_13 -> scan_unquoted<str, int, int>
;   botlish_fn_14 / botlish_entry_14 -> scan_quoted<str, int, str>
;   botlish_fn_15 / botlish_entry_15 -> scan_field<str, int>
;   botlish_fn_16 / botlish_entry_16 -> scan_record<str, int, list[list<never>, mutarray, int]>
;   botlish_fn_17 / botlish_entry_17 -> scan_record<str, int, list[list<mutarray>, mutarray, int]>
;   botlish_fn_18 / botlish_entry_18 -> scan_records<str, int, list[list<never>, mutarray, int]>
;   botlish_fn_19 / botlish_entry_19 -> scan_records<str, int, list[list<mutarray>, mutarray, int]>
;   botlish_fn_20 / botlish_entry_20 -> csv_parse<str>


csv_chunked.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x10
       8:	mov    QWORD PTR [rsp],r13
       c:	mov    QWORD PTR [rsp+0x8],r14
      11:	mov    r13,QWORD PTR [rdi]
      14:	mov    rax,QWORD PTR [rdi+0x8]
      18:	lea    rcx,[r13+0x8]
      1c:	cmp    rcx,rax
      1f:	ja     7b <botlish_fn_0+0x7b>
      25:	lea    rax,[r13+0x8]
      29:	mov    QWORD PTR [rdi],rax
      2c:	mov    rax,QWORD PTR [rdi+0x10]
      30:	mov    r14,rdi
      33:	mov    rsi,QWORD PTR [rax]
      36:	mov    QWORD PTR [r13+0x0],rsi
      3a:	call   3f <botlish_fn_0+0x3f>
			3b: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
      3f:	test   rax,rax
      42:	jne    63 <botlish_fn_0+0x63>
      48:	mov    rdi,r14
      4b:	mov    QWORD PTR [rdi],r13
      4e:	xor    rax,rax
      51:	mov    r13,QWORD PTR [rsp]
      55:	mov    r14,QWORD PTR [rsp+0x8]
      5a:	add    rsp,0x10
      5e:	mov    rsp,rbp
      61:	pop    rbp
      62:	ret
      63:	mov    rdi,r14
      66:	mov    QWORD PTR [rdi],r13
      69:	mov    r13,QWORD PTR [rsp]
      6d:	mov    r14,QWORD PTR [rsp+0x8]
      72:	add    rsp,0x10
      76:	mov    rsp,rbp
      79:	pop    rbp
      7a:	ret
      7b:	call   80 <botlish_fn_0+0x80>
			7c: R_X86_64_PLT32	rt_stack_overflow-0x4
      80:	xor    rax,rax
      83:	mov    r13,QWORD PTR [rsp]
      87:	mov    r14,QWORD PTR [rsp+0x8]
      8c:	add    rsp,0x10
      90:	mov    rsp,rbp
      93:	pop    rbp
      94:	ret

0000000000000095 <botlish_entry_0: <program entry>>:
      95:	push   rbp
      96:	mov    rbp,rsp
      99:	call   9e <botlish_entry_0+0x9>
			9a: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      9e:	mov    rsp,rbp
      a1:	pop    rbp
      a2:	ret

00000000000000a3 <botlish_fn_1: chunk_size<generic>>:
      a3:	push   rbp
      a4:	mov    rbp,rsp
      a7:	mov    r8,QWORD PTR [rdi]
      aa:	mov    r9,QWORD PTR [rdi+0x8]
      ae:	lea    r10,[r8+0x8]
      b2:	cmp    r10,r9
      b5:	ja     c8 <botlish_fn_1+0x25>
      bb:	mov    QWORD PTR [rdi],r8
      be:	mov    eax,0x81
      c3:	mov    rsp,rbp
      c6:	pop    rbp
      c7:	ret
      c8:	call   cd <botlish_fn_1+0x2a>
			c9: R_X86_64_PLT32	rt_stack_overflow-0x4
      cd:	xor    rax,rax
      d0:	mov    rsp,rbp
      d3:	pop    rbp
      d4:	ret

00000000000000d5 <botlish_entry_1: chunk_size<generic>>:
      d5:	push   rbp
      d6:	mov    rbp,rsp
      d9:	call   de <botlish_entry_1+0x9>
			da: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
      de:	mov    rsp,rbp
      e1:	pop    rbp
      e2:	ret

00000000000000e3 <botlish_fn_2: chunked_new<generic>>:
      e3:	push   rbp
      e4:	mov    rbp,rsp
      e7:	sub    rsp,0x20
      eb:	mov    QWORD PTR [rsp],rbx
      ef:	mov    QWORD PTR [rsp+0x8],r12
      f4:	mov    QWORD PTR [rsp+0x10],r13
      f9:	mov    QWORD PTR [rsp+0x18],r14
      fe:	mov    r13,rsi
     101:	mov    rbx,QWORD PTR [rdi]
     104:	mov    rax,QWORD PTR [rdi+0x8]
     108:	lea    rcx,[rbx+0x10]
     10c:	cmp    rcx,rax
     10f:	ja     1df <botlish_fn_2+0xfc>
     115:	lea    rax,[rbx+0x10]
     119:	mov    QWORD PTR [rdi],rax
     11c:	mov    r12,rdi
     11f:	mov    QWORD PTR [rbx],0x0
     126:	mov    QWORD PTR [rbx+0x8],0x0
     12e:	xor    rdx,rdx
     131:	mov    rdi,r12
     134:	mov    rsi,rdx
     137:	call   13c <botlish_fn_2+0x59>
			138: R_X86_64_PLT32	rt_list_new-0x4
     13c:	test   rax,rax
     13f:	jne    14d <botlish_fn_2+0x6a>
     145:	mov    rdi,r12
     148:	jmp    187 <botlish_fn_2+0xa4>
     14d:	mov    QWORD PTR [rbx],rax
     150:	mov    r14,rax
     153:	mov    rdi,r12
     156:	call   15b <botlish_fn_2+0x78>
			157: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     15b:	test   rax,rax
     15e:	jne    16c <botlish_fn_2+0x89>
     164:	mov    rdi,r12
     167:	jmp    187 <botlish_fn_2+0xa4>
     16c:	mov    QWORD PTR [rbx+0x8],rax
     170:	mov    rsi,rax
     173:	mov    rdi,r12
     176:	call   17b <botlish_fn_2+0x98>
			177: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     17b:	test   rax,rax
     17e:	jne    1ac <botlish_fn_2+0xc9>
     184:	mov    rdi,r12
     187:	mov    rdi,r12
     18a:	mov    QWORD PTR [rdi],rbx
     18d:	xor    rax,rax
     190:	mov    rbx,QWORD PTR [rsp]
     194:	mov    r12,QWORD PTR [rsp+0x8]
     199:	mov    r13,QWORD PTR [rsp+0x10]
     19e:	mov    r14,QWORD PTR [rsp+0x18]
     1a3:	add    rsp,0x20
     1a7:	mov    rsp,rbp
     1aa:	pop    rbp
     1ab:	ret
     1ac:	mov    rdi,r12
     1af:	mov    QWORD PTR [rdi],rbx
     1b2:	mov    rsi,r13
     1b5:	mov    QWORD PTR [rsi],rax
     1b8:	mov    QWORD PTR [rsi+0x8],0x1
     1c0:	mov    rax,r14
     1c3:	mov    rbx,QWORD PTR [rsp]
     1c7:	mov    r12,QWORD PTR [rsp+0x8]
     1cc:	mov    r13,QWORD PTR [rsp+0x10]
     1d1:	mov    r14,QWORD PTR [rsp+0x18]
     1d6:	add    rsp,0x20
     1da:	mov    rsp,rbp
     1dd:	pop    rbp
     1de:	ret
     1df:	mov    r12,rdi
     1e2:	call   1e7 <botlish_fn_2+0x104>
			1e3: R_X86_64_PLT32	rt_stack_overflow-0x4
     1e7:	xor    rax,rax
     1ea:	mov    rbx,QWORD PTR [rsp]
     1ee:	mov    r12,QWORD PTR [rsp+0x8]
     1f3:	mov    r13,QWORD PTR [rsp+0x10]
     1f8:	mov    r14,QWORD PTR [rsp+0x18]
     1fd:	add    rsp,0x20
     201:	mov    rsp,rbp
     204:	pop    rbp
     205:	ret

0000000000000206 <botlish_entry_2: chunked_new<generic>>:
     206:	push   rbp
     207:	mov    rbp,rsp
     20a:	ud2
     20c:	add    BYTE PTR [rax],al
	...

0000000000000210 <botlish_fn_3: chunked_append<list[list<never>, mutarray, int], str>>:
     210:	push   rbp
     211:	mov    rbp,rsp
     214:	sub    rsp,0x40
     218:	mov    QWORD PTR [rsp+0x10],rbx
     21d:	mov    QWORD PTR [rsp+0x18],r12
     222:	mov    QWORD PTR [rsp+0x20],r13
     227:	mov    QWORD PTR [rsp+0x28],r14
     22c:	mov    QWORD PTR [rsp+0x30],r15
     231:	mov    rbx,r9
     234:	mov    r13,QWORD PTR [rdi]
     237:	mov    rax,QWORD PTR [rdi+0x8]
     23b:	lea    r9,[r13+0x20]
     23f:	cmp    r9,rax
     242:	ja     45f <botlish_fn_3+0x24f>
     248:	lea    rax,[r13+0x20]
     24c:	mov    QWORD PTR [rdi],rax
     24f:	mov    r14,rdi
     252:	mov    QWORD PTR [r13+0x0],rsi
     256:	mov    r15,rsi
     259:	mov    QWORD PTR [r13+0x8],rdx
     25d:	mov    QWORD PTR [rsp],rdx
     261:	mov    QWORD PTR [r13+0x10],rcx
     265:	mov    r12,rcx
     268:	mov    QWORD PTR [r13+0x18],r8
     26c:	mov    QWORD PTR [rsp+0x8],r8
     271:	mov    rdi,r14
     274:	call   279 <botlish_fn_3+0x69>
			275: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     279:	test   rax,rax
     27c:	jne    28a <botlish_fn_3+0x7a>
     282:	mov    rdi,r14
     285:	jmp    3fb <botlish_fn_3+0x1eb>
     28a:	mov    rcx,r12
     28d:	and    rcx,rax
     290:	mov    rdx,rax
     293:	test   rcx,0x1
     29a:	jne    2c0 <botlish_fn_3+0xb0>
     2a0:	mov    rsi,r12
     2a3:	mov    rdi,r14
     2a6:	call   2ab <botlish_fn_3+0x9b>
			2a7: R_X86_64_PLT32	rt_int_cmp-0x4
     2ab:	mov    ecx,0x2
     2b0:	test   rax,rax
     2b3:	cmove  rcx,QWORD PTR [rip+0x1d5]        # 490 <botlish_fn_3+0x280>
     2bb:	jmp    2d0 <botlish_fn_3+0xc0>
     2c0:	mov    ecx,0x2
     2c5:	cmp    r12,rdx
     2c8:	cmove  rcx,QWORD PTR [rip+0x1c0]        # 490 <botlish_fn_3+0x280>
     2d0:	cmp    rcx,0x6
     2d4:	je     377 <botlish_fn_3+0x167>
     2da:	mov    rcx,QWORD PTR [rsp+0x8]
     2df:	mov    rdx,r12
     2e2:	mov    rsi,QWORD PTR [rsp]
     2e6:	mov    rdi,r14
     2e9:	call   2ee <botlish_fn_3+0xde>
			2ea: R_X86_64_PLT32	rt_mutarray_set-0x4
     2ee:	test   rax,rax
     2f1:	jne    2ff <botlish_fn_3+0xef>
     2f7:	mov    rdi,r14
     2fa:	jmp    3fb <botlish_fn_3+0x1eb>
     2ff:	mov    QWORD PTR [r13+0x18],0x3
     307:	test   r12,0x1
     30e:	je     32e <botlish_fn_3+0x11e>
     314:	mov    rax,r12
     317:	add    rax,0x2
     31b:	seto   cl
     31e:	test   cl,cl
     320:	jne    32e <botlish_fn_3+0x11e>
     326:	mov    rdi,r14
     329:	jmp    341 <botlish_fn_3+0x131>
     32e:	mov    edx,0x3
     333:	mov    rsi,r12
     336:	mov    rdi,r14
     339:	call   33e <botlish_fn_3+0x12e>
			33a: R_X86_64_PLT32	rt_int_add-0x4
     33e:	mov    rdi,r14
     341:	mov    rdi,r14
     344:	mov    QWORD PTR [rdi],r13
     347:	mov    rdx,QWORD PTR [rsp]
     34b:	mov    QWORD PTR [rbx],rdx
     34e:	mov    QWORD PTR [rbx+0x8],rax
     352:	mov    rax,r15
     355:	mov    rbx,QWORD PTR [rsp+0x10]
     35a:	mov    r12,QWORD PTR [rsp+0x18]
     35f:	mov    r13,QWORD PTR [rsp+0x20]
     364:	mov    r14,QWORD PTR [rsp+0x28]
     369:	mov    r15,QWORD PTR [rsp+0x30]
     36e:	add    rsp,0x40
     372:	mov    rsp,rbp
     375:	pop    rbp
     376:	ret
     377:	mov    rdx,QWORD PTR [rsp]
     37b:	mov    rsi,r15
     37e:	mov    rdi,r14
     381:	call   386 <botlish_fn_3+0x176>
			382: R_X86_64_PLT32	rt_list_append-0x4
     386:	test   rax,rax
     389:	jne    397 <botlish_fn_3+0x187>
     38f:	mov    rdi,r14
     392:	jmp    3fb <botlish_fn_3+0x1eb>
     397:	mov    QWORD PTR [r13+0x0],rax
     39b:	mov    r12,rax
     39e:	mov    rdi,r14
     3a1:	call   3a6 <botlish_fn_3+0x196>
			3a2: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     3a6:	test   rax,rax
     3a9:	jne    3b7 <botlish_fn_3+0x1a7>
     3af:	mov    rdi,r14
     3b2:	jmp    3fb <botlish_fn_3+0x1eb>
     3b7:	mov    QWORD PTR [r13+0x8],rax
     3bb:	mov    rsi,rax
     3be:	mov    rdi,r14
     3c1:	call   3c6 <botlish_fn_3+0x1b6>
			3c2: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     3c6:	test   rax,rax
     3c9:	mov    r15,rax
     3cc:	jne    3da <botlish_fn_3+0x1ca>
     3d2:	mov    rdi,r14
     3d5:	jmp    3fb <botlish_fn_3+0x1eb>
     3da:	mov    edx,0x1
     3df:	mov    rcx,QWORD PTR [rsp+0x8]
     3e4:	mov    rsi,r15
     3e7:	mov    rdi,r14
     3ea:	call   3ef <botlish_fn_3+0x1df>
			3eb: R_X86_64_PLT32	rt_mutarray_set-0x4
     3ef:	test   rax,rax
     3f2:	jne    426 <botlish_fn_3+0x216>
     3f8:	mov    rdi,r14
     3fb:	mov    rdi,r14
     3fe:	mov    QWORD PTR [rdi],r13
     401:	xor    rax,rax
     404:	mov    rbx,QWORD PTR [rsp+0x10]
     409:	mov    r12,QWORD PTR [rsp+0x18]
     40e:	mov    r13,QWORD PTR [rsp+0x20]
     413:	mov    r14,QWORD PTR [rsp+0x28]
     418:	mov    r15,QWORD PTR [rsp+0x30]
     41d:	add    rsp,0x40
     421:	mov    rsp,rbp
     424:	pop    rbp
     425:	ret
     426:	mov    rdi,r14
     429:	mov    QWORD PTR [rdi],r13
     42c:	mov    rax,r15
     42f:	mov    QWORD PTR [rbx],rax
     432:	mov    QWORD PTR [rbx+0x8],0x3
     43a:	mov    rax,r12
     43d:	mov    rbx,QWORD PTR [rsp+0x10]
     442:	mov    r12,QWORD PTR [rsp+0x18]
     447:	mov    r13,QWORD PTR [rsp+0x20]
     44c:	mov    r14,QWORD PTR [rsp+0x28]
     451:	mov    r15,QWORD PTR [rsp+0x30]
     456:	add    rsp,0x40
     45a:	mov    rsp,rbp
     45d:	pop    rbp
     45e:	ret
     45f:	mov    r14,rdi
     462:	call   467 <botlish_fn_3+0x257>
			463: R_X86_64_PLT32	rt_stack_overflow-0x4
     467:	xor    rax,rax
     46a:	mov    rbx,QWORD PTR [rsp+0x10]
     46f:	mov    r12,QWORD PTR [rsp+0x18]
     474:	mov    r13,QWORD PTR [rsp+0x20]
     479:	mov    r14,QWORD PTR [rsp+0x28]
     47e:	mov    r15,QWORD PTR [rsp+0x30]
     483:	add    rsp,0x40
     487:	mov    rsp,rbp
     48a:	pop    rbp
     48b:	ret
     48c:	add    BYTE PTR [rax],al
     48e:	add    BYTE PTR [rax],al
     490:	(bad)
     491:	add    BYTE PTR [rax],al
     493:	add    BYTE PTR [rax],al
     495:	add    BYTE PTR [rax],al
	...

0000000000000498 <botlish_entry_3: chunked_append<list[list<never>, mutarray, int], str>>:
     498:	push   rbp
     499:	mov    rbp,rsp
     49c:	ud2
	...

00000000000004a0 <botlish_fn_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     4a0:	push   rbp
     4a1:	mov    rbp,rsp
     4a4:	sub    rsp,0x40
     4a8:	mov    QWORD PTR [rsp+0x10],rbx
     4ad:	mov    QWORD PTR [rsp+0x18],r12
     4b2:	mov    QWORD PTR [rsp+0x20],r13
     4b7:	mov    QWORD PTR [rsp+0x28],r14
     4bc:	mov    QWORD PTR [rsp+0x30],r15
     4c1:	mov    rbx,r9
     4c4:	mov    r13,QWORD PTR [rdi]
     4c7:	mov    rax,QWORD PTR [rdi+0x8]
     4cb:	lea    r9,[r13+0x20]
     4cf:	cmp    r9,rax
     4d2:	ja     6ef <botlish_fn_4+0x24f>
     4d8:	lea    rax,[r13+0x20]
     4dc:	mov    QWORD PTR [rdi],rax
     4df:	mov    r14,rdi
     4e2:	mov    QWORD PTR [r13+0x0],rsi
     4e6:	mov    r15,rsi
     4e9:	mov    QWORD PTR [r13+0x8],rdx
     4ed:	mov    QWORD PTR [rsp],rdx
     4f1:	mov    QWORD PTR [r13+0x10],rcx
     4f5:	mov    r12,rcx
     4f8:	mov    QWORD PTR [r13+0x18],r8
     4fc:	mov    QWORD PTR [rsp+0x8],r8
     501:	mov    rdi,r14
     504:	call   509 <botlish_fn_4+0x69>
			505: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     509:	test   rax,rax
     50c:	jne    51a <botlish_fn_4+0x7a>
     512:	mov    rdi,r14
     515:	jmp    68b <botlish_fn_4+0x1eb>
     51a:	mov    rcx,r12
     51d:	and    rcx,rax
     520:	mov    rdx,rax
     523:	test   rcx,0x1
     52a:	jne    550 <botlish_fn_4+0xb0>
     530:	mov    rsi,r12
     533:	mov    rdi,r14
     536:	call   53b <botlish_fn_4+0x9b>
			537: R_X86_64_PLT32	rt_int_cmp-0x4
     53b:	mov    ecx,0x2
     540:	test   rax,rax
     543:	cmove  rcx,QWORD PTR [rip+0x1d5]        # 720 <botlish_fn_4+0x280>
     54b:	jmp    560 <botlish_fn_4+0xc0>
     550:	mov    ecx,0x2
     555:	cmp    r12,rdx
     558:	cmove  rcx,QWORD PTR [rip+0x1c0]        # 720 <botlish_fn_4+0x280>
     560:	cmp    rcx,0x6
     564:	je     607 <botlish_fn_4+0x167>
     56a:	mov    rcx,QWORD PTR [rsp+0x8]
     56f:	mov    rdx,r12
     572:	mov    rsi,QWORD PTR [rsp]
     576:	mov    rdi,r14
     579:	call   57e <botlish_fn_4+0xde>
			57a: R_X86_64_PLT32	rt_mutarray_set-0x4
     57e:	test   rax,rax
     581:	jne    58f <botlish_fn_4+0xef>
     587:	mov    rdi,r14
     58a:	jmp    68b <botlish_fn_4+0x1eb>
     58f:	mov    QWORD PTR [r13+0x18],0x3
     597:	test   r12,0x1
     59e:	je     5be <botlish_fn_4+0x11e>
     5a4:	mov    rax,r12
     5a7:	add    rax,0x2
     5ab:	seto   cl
     5ae:	test   cl,cl
     5b0:	jne    5be <botlish_fn_4+0x11e>
     5b6:	mov    rdi,r14
     5b9:	jmp    5d1 <botlish_fn_4+0x131>
     5be:	mov    edx,0x3
     5c3:	mov    rsi,r12
     5c6:	mov    rdi,r14
     5c9:	call   5ce <botlish_fn_4+0x12e>
			5ca: R_X86_64_PLT32	rt_int_add-0x4
     5ce:	mov    rdi,r14
     5d1:	mov    rdi,r14
     5d4:	mov    QWORD PTR [rdi],r13
     5d7:	mov    rdx,QWORD PTR [rsp]
     5db:	mov    QWORD PTR [rbx],rdx
     5de:	mov    QWORD PTR [rbx+0x8],rax
     5e2:	mov    rax,r15
     5e5:	mov    rbx,QWORD PTR [rsp+0x10]
     5ea:	mov    r12,QWORD PTR [rsp+0x18]
     5ef:	mov    r13,QWORD PTR [rsp+0x20]
     5f4:	mov    r14,QWORD PTR [rsp+0x28]
     5f9:	mov    r15,QWORD PTR [rsp+0x30]
     5fe:	add    rsp,0x40
     602:	mov    rsp,rbp
     605:	pop    rbp
     606:	ret
     607:	mov    rdx,QWORD PTR [rsp]
     60b:	mov    rsi,r15
     60e:	mov    rdi,r14
     611:	call   616 <botlish_fn_4+0x176>
			612: R_X86_64_PLT32	rt_list_append-0x4
     616:	test   rax,rax
     619:	jne    627 <botlish_fn_4+0x187>
     61f:	mov    rdi,r14
     622:	jmp    68b <botlish_fn_4+0x1eb>
     627:	mov    QWORD PTR [r13+0x0],rax
     62b:	mov    r12,rax
     62e:	mov    rdi,r14
     631:	call   636 <botlish_fn_4+0x196>
			632: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     636:	test   rax,rax
     639:	jne    647 <botlish_fn_4+0x1a7>
     63f:	mov    rdi,r14
     642:	jmp    68b <botlish_fn_4+0x1eb>
     647:	mov    QWORD PTR [r13+0x8],rax
     64b:	mov    rsi,rax
     64e:	mov    rdi,r14
     651:	call   656 <botlish_fn_4+0x1b6>
			652: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     656:	test   rax,rax
     659:	mov    r15,rax
     65c:	jne    66a <botlish_fn_4+0x1ca>
     662:	mov    rdi,r14
     665:	jmp    68b <botlish_fn_4+0x1eb>
     66a:	mov    edx,0x1
     66f:	mov    rcx,QWORD PTR [rsp+0x8]
     674:	mov    rsi,r15
     677:	mov    rdi,r14
     67a:	call   67f <botlish_fn_4+0x1df>
			67b: R_X86_64_PLT32	rt_mutarray_set-0x4
     67f:	test   rax,rax
     682:	jne    6b6 <botlish_fn_4+0x216>
     688:	mov    rdi,r14
     68b:	mov    rdi,r14
     68e:	mov    QWORD PTR [rdi],r13
     691:	xor    rax,rax
     694:	mov    rbx,QWORD PTR [rsp+0x10]
     699:	mov    r12,QWORD PTR [rsp+0x18]
     69e:	mov    r13,QWORD PTR [rsp+0x20]
     6a3:	mov    r14,QWORD PTR [rsp+0x28]
     6a8:	mov    r15,QWORD PTR [rsp+0x30]
     6ad:	add    rsp,0x40
     6b1:	mov    rsp,rbp
     6b4:	pop    rbp
     6b5:	ret
     6b6:	mov    rdi,r14
     6b9:	mov    QWORD PTR [rdi],r13
     6bc:	mov    rax,r15
     6bf:	mov    QWORD PTR [rbx],rax
     6c2:	mov    QWORD PTR [rbx+0x8],0x3
     6ca:	mov    rax,r12
     6cd:	mov    rbx,QWORD PTR [rsp+0x10]
     6d2:	mov    r12,QWORD PTR [rsp+0x18]
     6d7:	mov    r13,QWORD PTR [rsp+0x20]
     6dc:	mov    r14,QWORD PTR [rsp+0x28]
     6e1:	mov    r15,QWORD PTR [rsp+0x30]
     6e6:	add    rsp,0x40
     6ea:	mov    rsp,rbp
     6ed:	pop    rbp
     6ee:	ret
     6ef:	mov    r14,rdi
     6f2:	call   6f7 <botlish_fn_4+0x257>
			6f3: R_X86_64_PLT32	rt_stack_overflow-0x4
     6f7:	xor    rax,rax
     6fa:	mov    rbx,QWORD PTR [rsp+0x10]
     6ff:	mov    r12,QWORD PTR [rsp+0x18]
     704:	mov    r13,QWORD PTR [rsp+0x20]
     709:	mov    r14,QWORD PTR [rsp+0x28]
     70e:	mov    r15,QWORD PTR [rsp+0x30]
     713:	add    rsp,0x40
     717:	mov    rsp,rbp
     71a:	pop    rbp
     71b:	ret
     71c:	add    BYTE PTR [rax],al
     71e:	add    BYTE PTR [rax],al
     720:	(bad)
     721:	add    BYTE PTR [rax],al
     723:	add    BYTE PTR [rax],al
     725:	add    BYTE PTR [rax],al
	...

0000000000000728 <botlish_entry_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     728:	push   rbp
     729:	mov    rbp,rsp
     72c:	ud2
	...

0000000000000730 <botlish_fn_5: chunked_append<list[list<never>, mutarray, int], list>>:
     730:	push   rbp
     731:	mov    rbp,rsp
     734:	sub    rsp,0x40
     738:	mov    QWORD PTR [rsp+0x10],rbx
     73d:	mov    QWORD PTR [rsp+0x18],r12
     742:	mov    QWORD PTR [rsp+0x20],r13
     747:	mov    QWORD PTR [rsp+0x28],r14
     74c:	mov    QWORD PTR [rsp+0x30],r15
     751:	mov    rbx,r9
     754:	mov    r13,QWORD PTR [rdi]
     757:	mov    rax,QWORD PTR [rdi+0x8]
     75b:	lea    r9,[r13+0x20]
     75f:	cmp    r9,rax
     762:	ja     97f <botlish_fn_5+0x24f>
     768:	lea    rax,[r13+0x20]
     76c:	mov    QWORD PTR [rdi],rax
     76f:	mov    r14,rdi
     772:	mov    QWORD PTR [r13+0x0],rsi
     776:	mov    r15,rsi
     779:	mov    QWORD PTR [r13+0x8],rdx
     77d:	mov    QWORD PTR [rsp],rdx
     781:	mov    QWORD PTR [r13+0x10],rcx
     785:	mov    r12,rcx
     788:	mov    QWORD PTR [r13+0x18],r8
     78c:	mov    QWORD PTR [rsp+0x8],r8
     791:	mov    rdi,r14
     794:	call   799 <botlish_fn_5+0x69>
			795: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     799:	test   rax,rax
     79c:	jne    7aa <botlish_fn_5+0x7a>
     7a2:	mov    rdi,r14
     7a5:	jmp    91b <botlish_fn_5+0x1eb>
     7aa:	mov    rcx,r12
     7ad:	and    rcx,rax
     7b0:	mov    rdx,rax
     7b3:	test   rcx,0x1
     7ba:	jne    7e0 <botlish_fn_5+0xb0>
     7c0:	mov    rsi,r12
     7c3:	mov    rdi,r14
     7c6:	call   7cb <botlish_fn_5+0x9b>
			7c7: R_X86_64_PLT32	rt_int_cmp-0x4
     7cb:	mov    ecx,0x2
     7d0:	test   rax,rax
     7d3:	cmove  rcx,QWORD PTR [rip+0x1d5]        # 9b0 <botlish_fn_5+0x280>
     7db:	jmp    7f0 <botlish_fn_5+0xc0>
     7e0:	mov    ecx,0x2
     7e5:	cmp    r12,rdx
     7e8:	cmove  rcx,QWORD PTR [rip+0x1c0]        # 9b0 <botlish_fn_5+0x280>
     7f0:	cmp    rcx,0x6
     7f4:	je     897 <botlish_fn_5+0x167>
     7fa:	mov    rcx,QWORD PTR [rsp+0x8]
     7ff:	mov    rdx,r12
     802:	mov    rsi,QWORD PTR [rsp]
     806:	mov    rdi,r14
     809:	call   80e <botlish_fn_5+0xde>
			80a: R_X86_64_PLT32	rt_mutarray_set-0x4
     80e:	test   rax,rax
     811:	jne    81f <botlish_fn_5+0xef>
     817:	mov    rdi,r14
     81a:	jmp    91b <botlish_fn_5+0x1eb>
     81f:	mov    QWORD PTR [r13+0x18],0x3
     827:	test   r12,0x1
     82e:	je     84e <botlish_fn_5+0x11e>
     834:	mov    rax,r12
     837:	add    rax,0x2
     83b:	seto   cl
     83e:	test   cl,cl
     840:	jne    84e <botlish_fn_5+0x11e>
     846:	mov    rdi,r14
     849:	jmp    861 <botlish_fn_5+0x131>
     84e:	mov    edx,0x3
     853:	mov    rsi,r12
     856:	mov    rdi,r14
     859:	call   85e <botlish_fn_5+0x12e>
			85a: R_X86_64_PLT32	rt_int_add-0x4
     85e:	mov    rdi,r14
     861:	mov    rdi,r14
     864:	mov    QWORD PTR [rdi],r13
     867:	mov    rdx,QWORD PTR [rsp]
     86b:	mov    QWORD PTR [rbx],rdx
     86e:	mov    QWORD PTR [rbx+0x8],rax
     872:	mov    rax,r15
     875:	mov    rbx,QWORD PTR [rsp+0x10]
     87a:	mov    r12,QWORD PTR [rsp+0x18]
     87f:	mov    r13,QWORD PTR [rsp+0x20]
     884:	mov    r14,QWORD PTR [rsp+0x28]
     889:	mov    r15,QWORD PTR [rsp+0x30]
     88e:	add    rsp,0x40
     892:	mov    rsp,rbp
     895:	pop    rbp
     896:	ret
     897:	mov    rdx,QWORD PTR [rsp]
     89b:	mov    rsi,r15
     89e:	mov    rdi,r14
     8a1:	call   8a6 <botlish_fn_5+0x176>
			8a2: R_X86_64_PLT32	rt_list_append-0x4
     8a6:	test   rax,rax
     8a9:	jne    8b7 <botlish_fn_5+0x187>
     8af:	mov    rdi,r14
     8b2:	jmp    91b <botlish_fn_5+0x1eb>
     8b7:	mov    QWORD PTR [r13+0x0],rax
     8bb:	mov    r12,rax
     8be:	mov    rdi,r14
     8c1:	call   8c6 <botlish_fn_5+0x196>
			8c2: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     8c6:	test   rax,rax
     8c9:	jne    8d7 <botlish_fn_5+0x1a7>
     8cf:	mov    rdi,r14
     8d2:	jmp    91b <botlish_fn_5+0x1eb>
     8d7:	mov    QWORD PTR [r13+0x8],rax
     8db:	mov    rsi,rax
     8de:	mov    rdi,r14
     8e1:	call   8e6 <botlish_fn_5+0x1b6>
			8e2: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     8e6:	test   rax,rax
     8e9:	mov    r15,rax
     8ec:	jne    8fa <botlish_fn_5+0x1ca>
     8f2:	mov    rdi,r14
     8f5:	jmp    91b <botlish_fn_5+0x1eb>
     8fa:	mov    edx,0x1
     8ff:	mov    rcx,QWORD PTR [rsp+0x8]
     904:	mov    rsi,r15
     907:	mov    rdi,r14
     90a:	call   90f <botlish_fn_5+0x1df>
			90b: R_X86_64_PLT32	rt_mutarray_set-0x4
     90f:	test   rax,rax
     912:	jne    946 <botlish_fn_5+0x216>
     918:	mov    rdi,r14
     91b:	mov    rdi,r14
     91e:	mov    QWORD PTR [rdi],r13
     921:	xor    rax,rax
     924:	mov    rbx,QWORD PTR [rsp+0x10]
     929:	mov    r12,QWORD PTR [rsp+0x18]
     92e:	mov    r13,QWORD PTR [rsp+0x20]
     933:	mov    r14,QWORD PTR [rsp+0x28]
     938:	mov    r15,QWORD PTR [rsp+0x30]
     93d:	add    rsp,0x40
     941:	mov    rsp,rbp
     944:	pop    rbp
     945:	ret
     946:	mov    rdi,r14
     949:	mov    QWORD PTR [rdi],r13
     94c:	mov    rax,r15
     94f:	mov    QWORD PTR [rbx],rax
     952:	mov    QWORD PTR [rbx+0x8],0x3
     95a:	mov    rax,r12
     95d:	mov    rbx,QWORD PTR [rsp+0x10]
     962:	mov    r12,QWORD PTR [rsp+0x18]
     967:	mov    r13,QWORD PTR [rsp+0x20]
     96c:	mov    r14,QWORD PTR [rsp+0x28]
     971:	mov    r15,QWORD PTR [rsp+0x30]
     976:	add    rsp,0x40
     97a:	mov    rsp,rbp
     97d:	pop    rbp
     97e:	ret
     97f:	mov    r14,rdi
     982:	call   987 <botlish_fn_5+0x257>
			983: R_X86_64_PLT32	rt_stack_overflow-0x4
     987:	xor    rax,rax
     98a:	mov    rbx,QWORD PTR [rsp+0x10]
     98f:	mov    r12,QWORD PTR [rsp+0x18]
     994:	mov    r13,QWORD PTR [rsp+0x20]
     999:	mov    r14,QWORD PTR [rsp+0x28]
     99e:	mov    r15,QWORD PTR [rsp+0x30]
     9a3:	add    rsp,0x40
     9a7:	mov    rsp,rbp
     9aa:	pop    rbp
     9ab:	ret
     9ac:	add    BYTE PTR [rax],al
     9ae:	add    BYTE PTR [rax],al
     9b0:	(bad)
     9b1:	add    BYTE PTR [rax],al
     9b3:	add    BYTE PTR [rax],al
     9b5:	add    BYTE PTR [rax],al
	...

00000000000009b8 <botlish_entry_5: chunked_append<list[list<never>, mutarray, int], list>>:
     9b8:	push   rbp
     9b9:	mov    rbp,rsp
     9bc:	ud2
	...

00000000000009c0 <botlish_fn_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     9c0:	push   rbp
     9c1:	mov    rbp,rsp
     9c4:	sub    rsp,0x40
     9c8:	mov    QWORD PTR [rsp+0x10],rbx
     9cd:	mov    QWORD PTR [rsp+0x18],r12
     9d2:	mov    QWORD PTR [rsp+0x20],r13
     9d7:	mov    QWORD PTR [rsp+0x28],r14
     9dc:	mov    QWORD PTR [rsp+0x30],r15
     9e1:	mov    rbx,r9
     9e4:	mov    r13,QWORD PTR [rdi]
     9e7:	mov    rax,QWORD PTR [rdi+0x8]
     9eb:	lea    r9,[r13+0x20]
     9ef:	cmp    r9,rax
     9f2:	ja     c0f <botlish_fn_6+0x24f>
     9f8:	lea    rax,[r13+0x20]
     9fc:	mov    QWORD PTR [rdi],rax
     9ff:	mov    r14,rdi
     a02:	mov    QWORD PTR [r13+0x0],rsi
     a06:	mov    r15,rsi
     a09:	mov    QWORD PTR [r13+0x8],rdx
     a0d:	mov    QWORD PTR [rsp],rdx
     a11:	mov    QWORD PTR [r13+0x10],rcx
     a15:	mov    r12,rcx
     a18:	mov    QWORD PTR [r13+0x18],r8
     a1c:	mov    QWORD PTR [rsp+0x8],r8
     a21:	mov    rdi,r14
     a24:	call   a29 <botlish_fn_6+0x69>
			a25: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     a29:	test   rax,rax
     a2c:	jne    a3a <botlish_fn_6+0x7a>
     a32:	mov    rdi,r14
     a35:	jmp    bab <botlish_fn_6+0x1eb>
     a3a:	mov    rcx,r12
     a3d:	and    rcx,rax
     a40:	mov    rdx,rax
     a43:	test   rcx,0x1
     a4a:	jne    a70 <botlish_fn_6+0xb0>
     a50:	mov    rsi,r12
     a53:	mov    rdi,r14
     a56:	call   a5b <botlish_fn_6+0x9b>
			a57: R_X86_64_PLT32	rt_int_cmp-0x4
     a5b:	mov    ecx,0x2
     a60:	test   rax,rax
     a63:	cmove  rcx,QWORD PTR [rip+0x1d5]        # c40 <botlish_fn_6+0x280>
     a6b:	jmp    a80 <botlish_fn_6+0xc0>
     a70:	mov    ecx,0x2
     a75:	cmp    r12,rdx
     a78:	cmove  rcx,QWORD PTR [rip+0x1c0]        # c40 <botlish_fn_6+0x280>
     a80:	cmp    rcx,0x6
     a84:	je     b27 <botlish_fn_6+0x167>
     a8a:	mov    rcx,QWORD PTR [rsp+0x8]
     a8f:	mov    rdx,r12
     a92:	mov    rsi,QWORD PTR [rsp]
     a96:	mov    rdi,r14
     a99:	call   a9e <botlish_fn_6+0xde>
			a9a: R_X86_64_PLT32	rt_mutarray_set-0x4
     a9e:	test   rax,rax
     aa1:	jne    aaf <botlish_fn_6+0xef>
     aa7:	mov    rdi,r14
     aaa:	jmp    bab <botlish_fn_6+0x1eb>
     aaf:	mov    QWORD PTR [r13+0x18],0x3
     ab7:	test   r12,0x1
     abe:	je     ade <botlish_fn_6+0x11e>
     ac4:	mov    rax,r12
     ac7:	add    rax,0x2
     acb:	seto   cl
     ace:	test   cl,cl
     ad0:	jne    ade <botlish_fn_6+0x11e>
     ad6:	mov    rdi,r14
     ad9:	jmp    af1 <botlish_fn_6+0x131>
     ade:	mov    edx,0x3
     ae3:	mov    rsi,r12
     ae6:	mov    rdi,r14
     ae9:	call   aee <botlish_fn_6+0x12e>
			aea: R_X86_64_PLT32	rt_int_add-0x4
     aee:	mov    rdi,r14
     af1:	mov    rdi,r14
     af4:	mov    QWORD PTR [rdi],r13
     af7:	mov    rdx,QWORD PTR [rsp]
     afb:	mov    QWORD PTR [rbx],rdx
     afe:	mov    QWORD PTR [rbx+0x8],rax
     b02:	mov    rax,r15
     b05:	mov    rbx,QWORD PTR [rsp+0x10]
     b0a:	mov    r12,QWORD PTR [rsp+0x18]
     b0f:	mov    r13,QWORD PTR [rsp+0x20]
     b14:	mov    r14,QWORD PTR [rsp+0x28]
     b19:	mov    r15,QWORD PTR [rsp+0x30]
     b1e:	add    rsp,0x40
     b22:	mov    rsp,rbp
     b25:	pop    rbp
     b26:	ret
     b27:	mov    rdx,QWORD PTR [rsp]
     b2b:	mov    rsi,r15
     b2e:	mov    rdi,r14
     b31:	call   b36 <botlish_fn_6+0x176>
			b32: R_X86_64_PLT32	rt_list_append-0x4
     b36:	test   rax,rax
     b39:	jne    b47 <botlish_fn_6+0x187>
     b3f:	mov    rdi,r14
     b42:	jmp    bab <botlish_fn_6+0x1eb>
     b47:	mov    QWORD PTR [r13+0x0],rax
     b4b:	mov    r12,rax
     b4e:	mov    rdi,r14
     b51:	call   b56 <botlish_fn_6+0x196>
			b52: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     b56:	test   rax,rax
     b59:	jne    b67 <botlish_fn_6+0x1a7>
     b5f:	mov    rdi,r14
     b62:	jmp    bab <botlish_fn_6+0x1eb>
     b67:	mov    QWORD PTR [r13+0x8],rax
     b6b:	mov    rsi,rax
     b6e:	mov    rdi,r14
     b71:	call   b76 <botlish_fn_6+0x1b6>
			b72: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     b76:	test   rax,rax
     b79:	mov    r15,rax
     b7c:	jne    b8a <botlish_fn_6+0x1ca>
     b82:	mov    rdi,r14
     b85:	jmp    bab <botlish_fn_6+0x1eb>
     b8a:	mov    edx,0x1
     b8f:	mov    rcx,QWORD PTR [rsp+0x8]
     b94:	mov    rsi,r15
     b97:	mov    rdi,r14
     b9a:	call   b9f <botlish_fn_6+0x1df>
			b9b: R_X86_64_PLT32	rt_mutarray_set-0x4
     b9f:	test   rax,rax
     ba2:	jne    bd6 <botlish_fn_6+0x216>
     ba8:	mov    rdi,r14
     bab:	mov    rdi,r14
     bae:	mov    QWORD PTR [rdi],r13
     bb1:	xor    rax,rax
     bb4:	mov    rbx,QWORD PTR [rsp+0x10]
     bb9:	mov    r12,QWORD PTR [rsp+0x18]
     bbe:	mov    r13,QWORD PTR [rsp+0x20]
     bc3:	mov    r14,QWORD PTR [rsp+0x28]
     bc8:	mov    r15,QWORD PTR [rsp+0x30]
     bcd:	add    rsp,0x40
     bd1:	mov    rsp,rbp
     bd4:	pop    rbp
     bd5:	ret
     bd6:	mov    rdi,r14
     bd9:	mov    QWORD PTR [rdi],r13
     bdc:	mov    rax,r15
     bdf:	mov    QWORD PTR [rbx],rax
     be2:	mov    QWORD PTR [rbx+0x8],0x3
     bea:	mov    rax,r12
     bed:	mov    rbx,QWORD PTR [rsp+0x10]
     bf2:	mov    r12,QWORD PTR [rsp+0x18]
     bf7:	mov    r13,QWORD PTR [rsp+0x20]
     bfc:	mov    r14,QWORD PTR [rsp+0x28]
     c01:	mov    r15,QWORD PTR [rsp+0x30]
     c06:	add    rsp,0x40
     c0a:	mov    rsp,rbp
     c0d:	pop    rbp
     c0e:	ret
     c0f:	mov    r14,rdi
     c12:	call   c17 <botlish_fn_6+0x257>
			c13: R_X86_64_PLT32	rt_stack_overflow-0x4
     c17:	xor    rax,rax
     c1a:	mov    rbx,QWORD PTR [rsp+0x10]
     c1f:	mov    r12,QWORD PTR [rsp+0x18]
     c24:	mov    r13,QWORD PTR [rsp+0x20]
     c29:	mov    r14,QWORD PTR [rsp+0x28]
     c2e:	mov    r15,QWORD PTR [rsp+0x30]
     c33:	add    rsp,0x40
     c37:	mov    rsp,rbp
     c3a:	pop    rbp
     c3b:	ret
     c3c:	add    BYTE PTR [rax],al
     c3e:	add    BYTE PTR [rax],al
     c40:	(bad)
     c41:	add    BYTE PTR [rax],al
     c43:	add    BYTE PTR [rax],al
     c45:	add    BYTE PTR [rax],al
	...

0000000000000c48 <botlish_entry_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     c48:	push   rbp
     c49:	mov    rbp,rsp
     c4c:	ud2
	...

0000000000000c50 <botlish_fn_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
     c50:	push   rbp
     c51:	mov    rbp,rsp
     c54:	sub    rsp,0x40
     c58:	mov    QWORD PTR [rsp+0x10],rbx
     c5d:	mov    QWORD PTR [rsp+0x18],r12
     c62:	mov    QWORD PTR [rsp+0x20],r13
     c67:	mov    QWORD PTR [rsp+0x28],r14
     c6c:	mov    QWORD PTR [rsp+0x30],r15
     c71:	mov    r14,QWORD PTR [rdi]
     c74:	mov    rax,QWORD PTR [rdi+0x8]
     c78:	lea    r9,[r14+0x30]
     c7c:	cmp    r9,rax
     c7f:	ja     eef <botlish_fn_7+0x29f>
     c85:	lea    rax,[r14+0x30]
     c89:	mov    QWORD PTR [rdi],rax
     c8c:	mov    r15,rdi
     c8f:	mov    QWORD PTR [r14],rsi
     c92:	mov    QWORD PTR [r14+0x8],rdx
     c96:	mov    rbx,rdx
     c99:	mov    QWORD PTR [r14+0x10],rcx
     c9d:	mov    QWORD PTR [rsp],rcx
     ca1:	mov    QWORD PTR [r14+0x18],r8
     ca5:	mov    r12,rsi
     ca8:	mov    QWORD PTR [rsp+0x8],r8
     cad:	mov    rsi,r12
     cb0:	mov    rdi,r15
     cb3:	call   cb8 <botlish_fn_7+0x68>
			cb4: R_X86_64_PLT32	rt_list_len-0x4
     cb8:	mov    r13,rbx
     cbb:	mov    rcx,r13
     cbe:	and    rcx,rax
     cc1:	mov    rdx,rax
     cc4:	test   rcx,0x1
     ccb:	jne    cf1 <botlish_fn_7+0xa1>
     cd1:	mov    rsi,r13
     cd4:	mov    rdi,r15
     cd7:	call   cdc <botlish_fn_7+0x8c>
			cd8: R_X86_64_PLT32	rt_int_cmp-0x4
     cdc:	mov    ecx,0x2
     ce1:	test   rax,rax
     ce4:	cmovge rcx,QWORD PTR [rip+0x234]        # f20 <botlish_fn_7+0x2d0>
     cec:	jmp    d01 <botlish_fn_7+0xb1>
     cf1:	mov    ecx,0x2
     cf6:	cmp    r13,rdx
     cf9:	cmovge rcx,QWORD PTR [rip+0x21f]        # f20 <botlish_fn_7+0x2d0>
     d01:	cmp    rcx,0x6
     d05:	je     ec2 <botlish_fn_7+0x272>
     d0b:	test   r13,0x1
     d12:	je     d2c <botlish_fn_7+0xdc>
     d18:	mov    r11,QWORD PTR [r12+0x8]
     d1d:	mov    r10,r13
     d20:	sar    r10,1
     d23:	cmp    r10,r11
     d26:	jb     d53 <botlish_fn_7+0x103>
     d2c:	mov    rdx,r13
     d2f:	mov    rsi,r12
     d32:	mov    rdi,r15
     d35:	call   d3a <botlish_fn_7+0xea>
			d36: R_X86_64_PLT32	rt_list_get-0x4
     d3a:	test   rax,rax
     d3d:	jne    d4b <botlish_fn_7+0xfb>
     d43:	mov    rdi,r15
     d46:	jmp    e24 <botlish_fn_7+0x1d4>
     d4b:	mov    rsi,rax
     d4e:	jmp    d5f <botlish_fn_7+0x10f>
     d53:	mov    rax,QWORD PTR [r12+0x10]
     d58:	mov    rax,QWORD PTR [rax+r10*8]
     d5c:	mov    rsi,rax
     d5f:	mov    QWORD PTR [r14+0x20],rsi
     d63:	mov    rbx,rsi
     d66:	mov    QWORD PTR [r14+0x28],0x1
     d6e:	mov    rdi,r15
     d71:	call   d76 <botlish_fn_7+0x126>
			d72: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     d76:	test   rax,rax
     d79:	mov    r9,rax
     d7c:	jne    d8a <botlish_fn_7+0x13a>
     d82:	mov    rdi,r15
     d85:	jmp    e24 <botlish_fn_7+0x1d4>
     d8a:	xor    eax,eax
     d8c:	mov    rsi,rbx
     d8f:	test   rsi,0x7
     d96:	jne    da5 <botlish_fn_7+0x155>
     d9c:	movzx  rax,BYTE PTR [rsi]
     da0:	cmp    al,0x8
     da2:	sete   al
     da5:	test   al,al
     da7:	jne    dca <botlish_fn_7+0x17a>
     dad:	mov    rdi,r15
     db0:	mov    rax,QWORD PTR [rdi+0x10]
     db4:	mov    rcx,QWORD PTR [rax+0x8]
     db8:	mov    edx,0x8
     dbd:	call   dc2 <botlish_fn_7+0x172>
			dbe: R_X86_64_PLT32	rt_type_error-0x4
     dc2:	mov    rdi,r15
     dc5:	jmp    e24 <botlish_fn_7+0x1d4>
     dca:	mov    rbx,rsi
     dcd:	mov    r8d,0x1
     dd3:	mov    rcx,rbx
     dd6:	mov    rbx,QWORD PTR [rsp]
     dda:	mov    rdx,QWORD PTR [rsp+0x8]
     ddf:	mov    rsi,rbx
     de2:	mov    rdi,r15
     de5:	call   dea <botlish_fn_7+0x19a>
			de6: R_X86_64_PLT32	rt_mutarray_copy-0x4
     dea:	test   rax,rax
     ded:	jne    dfb <botlish_fn_7+0x1ab>
     df3:	mov    rdi,r15
     df6:	jmp    e24 <botlish_fn_7+0x1d4>
     dfb:	sar    r13,1
     dfe:	add    r13,0x1
     e05:	shl    r13,1
     e08:	or     r13,0x1
     e0c:	mov    QWORD PTR [r14+0x8],r13
     e10:	mov    rdi,r15
     e13:	call   e18 <botlish_fn_7+0x1c8>
			e14: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     e18:	test   rax,rax
     e1b:	jne    e4f <botlish_fn_7+0x1ff>
     e21:	mov    rdi,r15
     e24:	mov    rdi,r15
     e27:	mov    QWORD PTR [rdi],r14
     e2a:	xor    rax,rax
     e2d:	mov    rbx,QWORD PTR [rsp+0x10]
     e32:	mov    r12,QWORD PTR [rsp+0x18]
     e37:	mov    r13,QWORD PTR [rsp+0x20]
     e3c:	mov    r14,QWORD PTR [rsp+0x28]
     e41:	mov    r15,QWORD PTR [rsp+0x30]
     e46:	add    rsp,0x40
     e4a:	mov    rsp,rbp
     e4d:	pop    rbp
     e4e:	ret
     e4f:	mov    QWORD PTR [r14+0x20],rax
     e53:	mov    rsi,QWORD PTR [rsp+0x8]
     e58:	mov    rcx,rsi
     e5b:	and    rcx,rax
     e5e:	test   rcx,0x1
     e65:	jne    e78 <botlish_fn_7+0x228>
     e6b:	mov    rdx,rax
     e6e:	mov    rsi,QWORD PTR [rsp+0x8]
     e73:	jmp    e9a <botlish_fn_7+0x24a>
     e78:	lea    rcx,[rax-0x1]
     e7c:	mov    rdx,rax
     e7f:	mov    rsi,QWORD PTR [rsp+0x8]
     e84:	mov    rax,rsi
     e87:	add    rax,rcx
     e8a:	seto   cl
     e8d:	test   cl,cl
     e8f:	je     ea2 <botlish_fn_7+0x252>
     e95:	mov    rsi,QWORD PTR [rsp+0x8]
     e9a:	mov    rdi,r15
     e9d:	call   ea2 <botlish_fn_7+0x252>
			e9e: R_X86_64_PLT32	rt_int_add-0x4
     ea2:	mov    QWORD PTR [r14],r12
     ea5:	mov    QWORD PTR [r14+0x8],r13
     ea9:	mov    QWORD PTR [r14+0x10],rbx
     ead:	mov    QWORD PTR [r14+0x18],rax
     eb1:	mov    QWORD PTR [rsp+0x8],rax
     eb6:	mov    QWORD PTR [rsp],rbx
     eba:	mov    rbx,r13
     ebd:	jmp    cad <botlish_fn_7+0x5d>
     ec2:	mov    rdi,r15
     ec5:	mov    QWORD PTR [rdi],r14
     ec8:	mov    rax,QWORD PTR [rsp+0x8]
     ecd:	mov    rbx,QWORD PTR [rsp+0x10]
     ed2:	mov    r12,QWORD PTR [rsp+0x18]
     ed7:	mov    r13,QWORD PTR [rsp+0x20]
     edc:	mov    r14,QWORD PTR [rsp+0x28]
     ee1:	mov    r15,QWORD PTR [rsp+0x30]
     ee6:	add    rsp,0x40
     eea:	mov    rsp,rbp
     eed:	pop    rbp
     eee:	ret
     eef:	mov    r15,rdi
     ef2:	call   ef7 <botlish_fn_7+0x2a7>
			ef3: R_X86_64_PLT32	rt_stack_overflow-0x4
     ef7:	xor    rax,rax
     efa:	mov    rbx,QWORD PTR [rsp+0x10]
     eff:	mov    r12,QWORD PTR [rsp+0x18]
     f04:	mov    r13,QWORD PTR [rsp+0x20]
     f09:	mov    r14,QWORD PTR [rsp+0x28]
     f0e:	mov    r15,QWORD PTR [rsp+0x30]
     f13:	add    rsp,0x40
     f17:	mov    rsp,rbp
     f1a:	pop    rbp
     f1b:	ret
     f1c:	add    BYTE PTR [rax],al
     f1e:	add    BYTE PTR [rax],al
     f20:	(bad)
     f21:	add    BYTE PTR [rax],al
     f23:	add    BYTE PTR [rax],al
     f25:	add    BYTE PTR [rax],al
	...

0000000000000f28 <botlish_entry_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
     f28:	push   rbp
     f29:	mov    rbp,rsp
     f2c:	mov    rsi,QWORD PTR [rdx]
     f2f:	mov    r9,QWORD PTR [rdx+0x8]
     f33:	mov    rcx,QWORD PTR [rdx+0x10]
     f37:	mov    r8,QWORD PTR [rdx+0x18]
     f3b:	mov    rdx,r9
     f3e:	call   f43 <botlish_entry_7+0x1b>
			f3f: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
     f43:	mov    rsp,rbp
     f46:	pop    rbp
     f47:	ret

0000000000000f48 <botlish_fn_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
     f48:	push   rbp
     f49:	mov    rbp,rsp
     f4c:	sub    rsp,0x40
     f50:	mov    QWORD PTR [rsp+0x10],rbx
     f55:	mov    QWORD PTR [rsp+0x18],r12
     f5a:	mov    QWORD PTR [rsp+0x20],r13
     f5f:	mov    QWORD PTR [rsp+0x28],r14
     f64:	mov    QWORD PTR [rsp+0x30],r15
     f69:	mov    r14,QWORD PTR [rdi]
     f6c:	mov    rax,QWORD PTR [rdi+0x8]
     f70:	lea    r9,[r14+0x30]
     f74:	cmp    r9,rax
     f77:	ja     118c <botlish_fn_8+0x244>
     f7d:	lea    rax,[r14+0x30]
     f81:	mov    QWORD PTR [rdi],rax
     f84:	mov    r15,rdi
     f87:	mov    QWORD PTR [r14],rsi
     f8a:	mov    QWORD PTR [r14+0x8],rdx
     f8e:	mov    r12,rdx
     f91:	mov    QWORD PTR [r14+0x10],rcx
     f95:	mov    r13,rcx
     f98:	mov    QWORD PTR [r14+0x18],r8
     f9c:	mov    rbx,rsi
     f9f:	mov    QWORD PTR [rsp],r8
     fa3:	mov    rsi,rbx
     fa6:	mov    rdi,r15
     fa9:	call   fae <botlish_fn_8+0x66>
			faa: R_X86_64_PLT32	rt_list_len-0x4
     fae:	mov    rcx,r12
     fb1:	and    rcx,rax
     fb4:	mov    rdx,rax
     fb7:	test   rcx,0x1
     fbe:	jne    fe4 <botlish_fn_8+0x9c>
     fc4:	mov    rsi,r12
     fc7:	mov    rdi,r15
     fca:	call   fcf <botlish_fn_8+0x87>
			fcb: R_X86_64_PLT32	rt_int_cmp-0x4
     fcf:	mov    ecx,0x2
     fd4:	test   rax,rax
     fd7:	cmovge rcx,QWORD PTR [rip+0x1e1]        # 11c0 <botlish_fn_8+0x278>
     fdf:	jmp    ff4 <botlish_fn_8+0xac>
     fe4:	mov    ecx,0x2
     fe9:	cmp    r12,rdx
     fec:	cmovge rcx,QWORD PTR [rip+0x1cc]        # 11c0 <botlish_fn_8+0x278>
     ff4:	cmp    rcx,0x6
     ff8:	je     1160 <botlish_fn_8+0x218>
     ffe:	test   r12,0x1
    1005:	je     101e <botlish_fn_8+0xd6>
    100b:	mov    rdx,QWORD PTR [rbx+0x8]
    100f:	mov    rcx,r12
    1012:	sar    rcx,1
    1015:	cmp    rcx,rdx
    1018:	jb     1045 <botlish_fn_8+0xfd>
    101e:	mov    rdx,r12
    1021:	mov    rsi,rbx
    1024:	mov    rdi,r15
    1027:	call   102c <botlish_fn_8+0xe4>
			1028: R_X86_64_PLT32	rt_list_get-0x4
    102c:	test   rax,rax
    102f:	jne    103d <botlish_fn_8+0xf5>
    1035:	mov    rdi,r15
    1038:	jmp    10ce <botlish_fn_8+0x186>
    103d:	mov    rcx,rax
    1040:	jmp    104d <botlish_fn_8+0x105>
    1045:	mov    r8,QWORD PTR [rbx+0x10]
    1049:	mov    rcx,QWORD PTR [r8+rcx*8]
    104d:	mov    QWORD PTR [r14+0x20],rcx
    1051:	mov    QWORD PTR [rsp+0x8],rcx
    1056:	mov    QWORD PTR [r14+0x28],0x1
    105e:	mov    rdi,r15
    1061:	call   1066 <botlish_fn_8+0x11e>
			1062: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    1066:	test   rax,rax
    1069:	mov    r9,rax
    106c:	jne    107a <botlish_fn_8+0x132>
    1072:	mov    rdi,r15
    1075:	jmp    10ce <botlish_fn_8+0x186>
    107a:	mov    r8d,0x1
    1080:	mov    rcx,QWORD PTR [rsp+0x8]
    1085:	mov    rdx,QWORD PTR [rsp]
    1089:	mov    rsi,r13
    108c:	mov    rdi,r15
    108f:	call   1094 <botlish_fn_8+0x14c>
			1090: R_X86_64_PLT32	rt_mutarray_copy-0x4
    1094:	test   rax,rax
    1097:	jne    10a5 <botlish_fn_8+0x15d>
    109d:	mov    rdi,r15
    10a0:	jmp    10ce <botlish_fn_8+0x186>
    10a5:	sar    r12,1
    10a8:	add    r12,0x1
    10af:	shl    r12,1
    10b2:	or     r12,0x1
    10b6:	mov    QWORD PTR [r14+0x8],r12
    10ba:	mov    rdi,r15
    10bd:	call   10c2 <botlish_fn_8+0x17a>
			10be: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    10c2:	test   rax,rax
    10c5:	jne    10f9 <botlish_fn_8+0x1b1>
    10cb:	mov    rdi,r15
    10ce:	mov    rdi,r15
    10d1:	mov    QWORD PTR [rdi],r14
    10d4:	xor    rax,rax
    10d7:	mov    rbx,QWORD PTR [rsp+0x10]
    10dc:	mov    r12,QWORD PTR [rsp+0x18]
    10e1:	mov    r13,QWORD PTR [rsp+0x20]
    10e6:	mov    r14,QWORD PTR [rsp+0x28]
    10eb:	mov    r15,QWORD PTR [rsp+0x30]
    10f0:	add    rsp,0x40
    10f4:	mov    rsp,rbp
    10f7:	pop    rbp
    10f8:	ret
    10f9:	mov    QWORD PTR [r14+0x20],rax
    10fd:	mov    rsi,QWORD PTR [rsp]
    1101:	mov    rcx,rsi
    1104:	and    rcx,rax
    1107:	test   rcx,0x1
    110e:	jne    1120 <botlish_fn_8+0x1d8>
    1114:	mov    rdx,rax
    1117:	mov    rsi,QWORD PTR [rsp]
    111b:	jmp    1140 <botlish_fn_8+0x1f8>
    1120:	lea    rcx,[rax-0x1]
    1124:	mov    rdx,rax
    1127:	mov    rsi,QWORD PTR [rsp]
    112b:	mov    rax,rsi
    112e:	add    rax,rcx
    1131:	seto   cl
    1134:	test   cl,cl
    1136:	je     1148 <botlish_fn_8+0x200>
    113c:	mov    rsi,QWORD PTR [rsp]
    1140:	mov    rdi,r15
    1143:	call   1148 <botlish_fn_8+0x200>
			1144: R_X86_64_PLT32	rt_int_add-0x4
    1148:	mov    QWORD PTR [r14],rbx
    114b:	mov    QWORD PTR [r14+0x8],r12
    114f:	mov    QWORD PTR [r14+0x10],r13
    1153:	mov    QWORD PTR [r14+0x18],rax
    1157:	mov    QWORD PTR [rsp],rax
    115b:	jmp    fa3 <botlish_fn_8+0x5b>
    1160:	mov    rdi,r15
    1163:	mov    QWORD PTR [rdi],r14
    1166:	mov    rax,QWORD PTR [rsp]
    116a:	mov    rbx,QWORD PTR [rsp+0x10]
    116f:	mov    r12,QWORD PTR [rsp+0x18]
    1174:	mov    r13,QWORD PTR [rsp+0x20]
    1179:	mov    r14,QWORD PTR [rsp+0x28]
    117e:	mov    r15,QWORD PTR [rsp+0x30]
    1183:	add    rsp,0x40
    1187:	mov    rsp,rbp
    118a:	pop    rbp
    118b:	ret
    118c:	mov    r15,rdi
    118f:	call   1194 <botlish_fn_8+0x24c>
			1190: R_X86_64_PLT32	rt_stack_overflow-0x4
    1194:	xor    rax,rax
    1197:	mov    rbx,QWORD PTR [rsp+0x10]
    119c:	mov    r12,QWORD PTR [rsp+0x18]
    11a1:	mov    r13,QWORD PTR [rsp+0x20]
    11a6:	mov    r14,QWORD PTR [rsp+0x28]
    11ab:	mov    r15,QWORD PTR [rsp+0x30]
    11b0:	add    rsp,0x40
    11b4:	mov    rsp,rbp
    11b7:	pop    rbp
    11b8:	ret
    11b9:	add    BYTE PTR [rax],al
    11bb:	add    BYTE PTR [rax],al
    11bd:	add    BYTE PTR [rax],al
    11bf:	add    BYTE PTR [rsi],al
    11c1:	add    BYTE PTR [rax],al
    11c3:	add    BYTE PTR [rax],al
    11c5:	add    BYTE PTR [rax],al
	...

00000000000011c8 <botlish_entry_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
    11c8:	push   rbp
    11c9:	mov    rbp,rsp
    11cc:	mov    rsi,QWORD PTR [rdx]
    11cf:	mov    r9,QWORD PTR [rdx+0x8]
    11d3:	mov    rcx,QWORD PTR [rdx+0x10]
    11d7:	mov    r8,QWORD PTR [rdx+0x18]
    11db:	mov    rdx,r9
    11de:	call   11e3 <botlish_entry_8+0x1b>
			11df: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    11e3:	mov    rsp,rbp
    11e6:	pop    rbp
    11e7:	ret

00000000000011e8 <botlish_fn_9: chunked_finish<list[list<never>, mutarray, int]>>:
    11e8:	push   rbp
    11e9:	mov    rbp,rsp
    11ec:	sub    rsp,0x40
    11f0:	mov    QWORD PTR [rsp+0x10],rbx
    11f5:	mov    QWORD PTR [rsp+0x18],r12
    11fa:	mov    QWORD PTR [rsp+0x20],r13
    11ff:	mov    QWORD PTR [rsp+0x28],r14
    1204:	mov    QWORD PTR [rsp+0x30],r15
    1209:	mov    r12,QWORD PTR [rdi]
    120c:	mov    rax,QWORD PTR [rdi+0x8]
    1210:	lea    r8,[r12+0x38]
    1215:	cmp    r8,rax
    1218:	ja     1438 <botlish_fn_9+0x250>
    121e:	lea    rax,[r12+0x38]
    1223:	mov    QWORD PTR [rdi],rax
    1226:	mov    r14,rdi
    1229:	mov    QWORD PTR [r12+0x20],0x0
    1232:	mov    QWORD PTR [r12+0x28],0x0
    123b:	mov    QWORD PTR [r12+0x30],0x0
    1244:	mov    QWORD PTR [r12],rsi
    1248:	mov    QWORD PTR [rsp],rsi
    124c:	mov    QWORD PTR [r12+0x8],rdx
    1251:	mov    r15,rdx
    1254:	mov    QWORD PTR [r12+0x10],rcx
    1259:	mov    rbx,rcx
    125c:	mov    rsi,QWORD PTR [rsp]
    1260:	mov    rdi,r14
    1263:	call   1268 <botlish_fn_9+0x80>
			1264: R_X86_64_PLT32	rt_list_len-0x4
    1268:	mov    QWORD PTR [r12+0x18],rax
    126d:	mov    r13,rax
    1270:	mov    rdi,r14
    1273:	call   1278 <botlish_fn_9+0x90>
			1274: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    1278:	test   rax,rax
    127b:	jne    1289 <botlish_fn_9+0xa1>
    1281:	mov    rdi,r14
    1284:	jmp    13e5 <botlish_fn_9+0x1fd>
    1289:	mov    QWORD PTR [r12+0x20],rax
    128e:	mov    rcx,r13
    1291:	mov    rdx,rcx
    1294:	and    rdx,rax
    1297:	mov    rsi,rax
    129a:	test   rdx,0x1
    12a1:	jne    12b2 <botlish_fn_9+0xca>
    12a7:	mov    rdx,rsi
    12aa:	mov    rsi,rcx
    12ad:	jmp    12e7 <botlish_fn_9+0xff>
    12b2:	mov    rax,rcx
    12b5:	sar    rax,1
    12b8:	mov    r13,rcx
    12bb:	mov    rcx,rsi
    12be:	lea    rdx,[rcx-0x1]
    12c2:	imul   rdx
    12c5:	seto   cl
    12c8:	or     rax,0x1
    12cc:	test   cl,cl
    12ce:	je     12df <botlish_fn_9+0xf7>
    12d4:	mov    rdx,rsi
    12d7:	mov    rsi,r13
    12da:	jmp    12e7 <botlish_fn_9+0xff>
    12df:	mov    rsi,rax
    12e2:	jmp    12f2 <botlish_fn_9+0x10a>
    12e7:	mov    rdi,r14
    12ea:	call   12ef <botlish_fn_9+0x107>
			12eb: R_X86_64_PLT32	rt_int_mul-0x4
    12ef:	mov    rsi,rax
    12f2:	mov    QWORD PTR [r12+0x18],rsi
    12f7:	mov    rax,rsi
    12fa:	and    rax,rbx
    12fd:	test   rax,0x1
    1303:	je     131e <botlish_fn_9+0x136>
    1309:	lea    rax,[rbx-0x1]
    130d:	mov    r13,rsi
    1310:	add    r13,rax
    1313:	seto   al
    1316:	test   al,al
    1318:	je     132c <botlish_fn_9+0x144>
    131e:	mov    rdx,rbx
    1321:	mov    rdi,r14
    1324:	call   1329 <botlish_fn_9+0x141>
			1325: R_X86_64_PLT32	rt_int_add-0x4
    1329:	mov    r13,rax
    132c:	mov    QWORD PTR [r12+0x18],r13
    1331:	mov    rsi,r13
    1334:	mov    rdi,r14
    1337:	call   133c <botlish_fn_9+0x154>
			1338: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    133c:	mov    rcx,rax
    133f:	mov    QWORD PTR [rsp+0x8],rax
    1344:	test   rax,rcx
    1347:	jne    1355 <botlish_fn_9+0x16d>
    134d:	mov    rdi,r14
    1350:	jmp    13e5 <botlish_fn_9+0x1fd>
    1355:	mov    rax,QWORD PTR [rsp+0x8]
    135a:	mov    QWORD PTR [r12+0x20],rax
    135f:	mov    r8d,0x1
    1365:	mov    QWORD PTR [r12+0x28],0x1
    136e:	mov    QWORD PTR [r12+0x30],0x1
    1377:	mov    rsi,QWORD PTR [rsp]
    137b:	mov    rcx,QWORD PTR [rsp+0x8]
    1380:	mov    rdi,r14
    1383:	mov    rdx,r8
    1386:	call   138b <botlish_fn_9+0x1a3>
			1387: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
    138b:	test   rax,rax
    138e:	mov    rdx,rax
    1391:	jne    139f <botlish_fn_9+0x1b7>
    1397:	mov    rdi,r14
    139a:	jmp    13e5 <botlish_fn_9+0x1fd>
    139f:	mov    r8d,0x1
    13a5:	mov    rcx,r15
    13a8:	mov    r9,rbx
    13ab:	mov    rsi,QWORD PTR [rsp+0x8]
    13b0:	mov    rdi,r14
    13b3:	call   13b8 <botlish_fn_9+0x1d0>
			13b4: R_X86_64_PLT32	rt_mutarray_copy-0x4
    13b8:	test   rax,rax
    13bb:	jne    13c9 <botlish_fn_9+0x1e1>
    13c1:	mov    rdi,r14
    13c4:	jmp    13e5 <botlish_fn_9+0x1fd>
    13c9:	mov    rdx,r13
    13cc:	mov    rsi,QWORD PTR [rsp+0x8]
    13d1:	mov    rdi,r14
    13d4:	call   13d9 <botlish_fn_9+0x1f1>
			13d5: R_X86_64_PLT32	rt_mutarray_freeze-0x4
    13d9:	test   rax,rax
    13dc:	jne    1410 <botlish_fn_9+0x228>
    13e2:	mov    rdi,r14
    13e5:	mov    rdi,r14
    13e8:	mov    QWORD PTR [rdi],r12
    13eb:	xor    rax,rax
    13ee:	mov    rbx,QWORD PTR [rsp+0x10]
    13f3:	mov    r12,QWORD PTR [rsp+0x18]
    13f8:	mov    r13,QWORD PTR [rsp+0x20]
    13fd:	mov    r14,QWORD PTR [rsp+0x28]
    1402:	mov    r15,QWORD PTR [rsp+0x30]
    1407:	add    rsp,0x40
    140b:	mov    rsp,rbp
    140e:	pop    rbp
    140f:	ret
    1410:	mov    rdi,r14
    1413:	mov    QWORD PTR [rdi],r12
    1416:	mov    rbx,QWORD PTR [rsp+0x10]
    141b:	mov    r12,QWORD PTR [rsp+0x18]
    1420:	mov    r13,QWORD PTR [rsp+0x20]
    1425:	mov    r14,QWORD PTR [rsp+0x28]
    142a:	mov    r15,QWORD PTR [rsp+0x30]
    142f:	add    rsp,0x40
    1433:	mov    rsp,rbp
    1436:	pop    rbp
    1437:	ret
    1438:	mov    r14,rdi
    143b:	call   1440 <botlish_fn_9+0x258>
			143c: R_X86_64_PLT32	rt_stack_overflow-0x4
    1440:	xor    rax,rax
    1443:	mov    rbx,QWORD PTR [rsp+0x10]
    1448:	mov    r12,QWORD PTR [rsp+0x18]
    144d:	mov    r13,QWORD PTR [rsp+0x20]
    1452:	mov    r14,QWORD PTR [rsp+0x28]
    1457:	mov    r15,QWORD PTR [rsp+0x30]
    145c:	add    rsp,0x40
    1460:	mov    rsp,rbp
    1463:	pop    rbp
    1464:	ret

0000000000001465 <botlish_entry_9: chunked_finish<list[list<never>, mutarray, int]>>:
    1465:	push   rbp
    1466:	mov    rbp,rsp
    1469:	mov    rsi,QWORD PTR [rdx]
    146c:	mov    r8,QWORD PTR [rdx+0x8]
    1470:	mov    rcx,QWORD PTR [rdx+0x10]
    1474:	mov    rdx,r8
    1477:	call   147c <botlish_entry_9+0x17>
			1478: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    147c:	mov    rsp,rbp
    147f:	pop    rbp
    1480:	ret

0000000000001481 <botlish_fn_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    1481:	push   rbp
    1482:	mov    rbp,rsp
    1485:	sub    rsp,0x40
    1489:	mov    QWORD PTR [rsp+0x10],rbx
    148e:	mov    QWORD PTR [rsp+0x18],r12
    1493:	mov    QWORD PTR [rsp+0x20],r13
    1498:	mov    QWORD PTR [rsp+0x28],r14
    149d:	mov    QWORD PTR [rsp+0x30],r15
    14a2:	mov    r12,QWORD PTR [rdi]
    14a5:	mov    rax,QWORD PTR [rdi+0x8]
    14a9:	lea    r8,[r12+0x38]
    14ae:	cmp    r8,rax
    14b1:	ja     16d1 <botlish_fn_10+0x250>
    14b7:	lea    rax,[r12+0x38]
    14bc:	mov    QWORD PTR [rdi],rax
    14bf:	mov    r14,rdi
    14c2:	mov    QWORD PTR [r12+0x20],0x0
    14cb:	mov    QWORD PTR [r12+0x28],0x0
    14d4:	mov    QWORD PTR [r12+0x30],0x0
    14dd:	mov    QWORD PTR [r12],rsi
    14e1:	mov    QWORD PTR [rsp],rsi
    14e5:	mov    QWORD PTR [r12+0x8],rdx
    14ea:	mov    r15,rdx
    14ed:	mov    QWORD PTR [r12+0x10],rcx
    14f2:	mov    rbx,rcx
    14f5:	mov    rsi,QWORD PTR [rsp]
    14f9:	mov    rdi,r14
    14fc:	call   1501 <botlish_fn_10+0x80>
			14fd: R_X86_64_PLT32	rt_list_len-0x4
    1501:	mov    QWORD PTR [r12+0x18],rax
    1506:	mov    r13,rax
    1509:	mov    rdi,r14
    150c:	call   1511 <botlish_fn_10+0x90>
			150d: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    1511:	test   rax,rax
    1514:	jne    1522 <botlish_fn_10+0xa1>
    151a:	mov    rdi,r14
    151d:	jmp    167e <botlish_fn_10+0x1fd>
    1522:	mov    QWORD PTR [r12+0x20],rax
    1527:	mov    rcx,r13
    152a:	mov    rdx,rcx
    152d:	and    rdx,rax
    1530:	mov    rsi,rax
    1533:	test   rdx,0x1
    153a:	jne    154b <botlish_fn_10+0xca>
    1540:	mov    rdx,rsi
    1543:	mov    rsi,rcx
    1546:	jmp    1580 <botlish_fn_10+0xff>
    154b:	mov    rax,rcx
    154e:	sar    rax,1
    1551:	mov    r13,rcx
    1554:	mov    rcx,rsi
    1557:	lea    rdx,[rcx-0x1]
    155b:	imul   rdx
    155e:	seto   cl
    1561:	or     rax,0x1
    1565:	test   cl,cl
    1567:	je     1578 <botlish_fn_10+0xf7>
    156d:	mov    rdx,rsi
    1570:	mov    rsi,r13
    1573:	jmp    1580 <botlish_fn_10+0xff>
    1578:	mov    rsi,rax
    157b:	jmp    158b <botlish_fn_10+0x10a>
    1580:	mov    rdi,r14
    1583:	call   1588 <botlish_fn_10+0x107>
			1584: R_X86_64_PLT32	rt_int_mul-0x4
    1588:	mov    rsi,rax
    158b:	mov    QWORD PTR [r12+0x18],rsi
    1590:	mov    rax,rsi
    1593:	and    rax,rbx
    1596:	test   rax,0x1
    159c:	je     15b7 <botlish_fn_10+0x136>
    15a2:	lea    rax,[rbx-0x1]
    15a6:	mov    r13,rsi
    15a9:	add    r13,rax
    15ac:	seto   al
    15af:	test   al,al
    15b1:	je     15c5 <botlish_fn_10+0x144>
    15b7:	mov    rdx,rbx
    15ba:	mov    rdi,r14
    15bd:	call   15c2 <botlish_fn_10+0x141>
			15be: R_X86_64_PLT32	rt_int_add-0x4
    15c2:	mov    r13,rax
    15c5:	mov    QWORD PTR [r12+0x18],r13
    15ca:	mov    rsi,r13
    15cd:	mov    rdi,r14
    15d0:	call   15d5 <botlish_fn_10+0x154>
			15d1: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    15d5:	mov    rcx,rax
    15d8:	mov    QWORD PTR [rsp+0x8],rax
    15dd:	test   rax,rcx
    15e0:	jne    15ee <botlish_fn_10+0x16d>
    15e6:	mov    rdi,r14
    15e9:	jmp    167e <botlish_fn_10+0x1fd>
    15ee:	mov    rax,QWORD PTR [rsp+0x8]
    15f3:	mov    QWORD PTR [r12+0x20],rax
    15f8:	mov    r8d,0x1
    15fe:	mov    QWORD PTR [r12+0x28],0x1
    1607:	mov    QWORD PTR [r12+0x30],0x1
    1610:	mov    rsi,QWORD PTR [rsp]
    1614:	mov    rcx,QWORD PTR [rsp+0x8]
    1619:	mov    rdi,r14
    161c:	mov    rdx,r8
    161f:	call   1624 <botlish_fn_10+0x1a3>
			1620: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    1624:	test   rax,rax
    1627:	mov    rdx,rax
    162a:	jne    1638 <botlish_fn_10+0x1b7>
    1630:	mov    rdi,r14
    1633:	jmp    167e <botlish_fn_10+0x1fd>
    1638:	mov    r8d,0x1
    163e:	mov    rcx,r15
    1641:	mov    r9,rbx
    1644:	mov    rsi,QWORD PTR [rsp+0x8]
    1649:	mov    rdi,r14
    164c:	call   1651 <botlish_fn_10+0x1d0>
			164d: R_X86_64_PLT32	rt_mutarray_copy-0x4
    1651:	test   rax,rax
    1654:	jne    1662 <botlish_fn_10+0x1e1>
    165a:	mov    rdi,r14
    165d:	jmp    167e <botlish_fn_10+0x1fd>
    1662:	mov    rdx,r13
    1665:	mov    rsi,QWORD PTR [rsp+0x8]
    166a:	mov    rdi,r14
    166d:	call   1672 <botlish_fn_10+0x1f1>
			166e: R_X86_64_PLT32	rt_mutarray_freeze-0x4
    1672:	test   rax,rax
    1675:	jne    16a9 <botlish_fn_10+0x228>
    167b:	mov    rdi,r14
    167e:	mov    rdi,r14
    1681:	mov    QWORD PTR [rdi],r12
    1684:	xor    rax,rax
    1687:	mov    rbx,QWORD PTR [rsp+0x10]
    168c:	mov    r12,QWORD PTR [rsp+0x18]
    1691:	mov    r13,QWORD PTR [rsp+0x20]
    1696:	mov    r14,QWORD PTR [rsp+0x28]
    169b:	mov    r15,QWORD PTR [rsp+0x30]
    16a0:	add    rsp,0x40
    16a4:	mov    rsp,rbp
    16a7:	pop    rbp
    16a8:	ret
    16a9:	mov    rdi,r14
    16ac:	mov    QWORD PTR [rdi],r12
    16af:	mov    rbx,QWORD PTR [rsp+0x10]
    16b4:	mov    r12,QWORD PTR [rsp+0x18]
    16b9:	mov    r13,QWORD PTR [rsp+0x20]
    16be:	mov    r14,QWORD PTR [rsp+0x28]
    16c3:	mov    r15,QWORD PTR [rsp+0x30]
    16c8:	add    rsp,0x40
    16cc:	mov    rsp,rbp
    16cf:	pop    rbp
    16d0:	ret
    16d1:	mov    r14,rdi
    16d4:	call   16d9 <botlish_fn_10+0x258>
			16d5: R_X86_64_PLT32	rt_stack_overflow-0x4
    16d9:	xor    rax,rax
    16dc:	mov    rbx,QWORD PTR [rsp+0x10]
    16e1:	mov    r12,QWORD PTR [rsp+0x18]
    16e6:	mov    r13,QWORD PTR [rsp+0x20]
    16eb:	mov    r14,QWORD PTR [rsp+0x28]
    16f0:	mov    r15,QWORD PTR [rsp+0x30]
    16f5:	add    rsp,0x40
    16f9:	mov    rsp,rbp
    16fc:	pop    rbp
    16fd:	ret

00000000000016fe <botlish_entry_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    16fe:	push   rbp
    16ff:	mov    rbp,rsp
    1702:	mov    rsi,QWORD PTR [rdx]
    1705:	mov    r8,QWORD PTR [rdx+0x8]
    1709:	mov    rcx,QWORD PTR [rdx+0x10]
    170d:	mov    rdx,r8
    1710:	call   1715 <botlish_entry_10+0x17>
			1711: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1715:	mov    rsp,rbp
    1718:	pop    rbp
    1719:	ret
    171a:	add    BYTE PTR [rax],al
    171c:	add    BYTE PTR [rax],al
	...

0000000000001720 <botlish_fn_11: peek<str, int>>:
    1720:	push   rbp
    1721:	mov    rbp,rsp
    1724:	sub    rsp,0x20
    1728:	mov    QWORD PTR [rsp],rbx
    172c:	mov    QWORD PTR [rsp+0x8],r12
    1731:	mov    QWORD PTR [rsp+0x10],r13
    1736:	mov    QWORD PTR [rsp+0x18],r14
    173b:	mov    r12,QWORD PTR [rdi]
    173e:	mov    rax,QWORD PTR [rdi+0x8]
    1742:	lea    rcx,[r12+0x18]
    1747:	cmp    rcx,rax
    174a:	ja     188d <botlish_fn_11+0x16d>
    1750:	lea    rax,[r12+0x18]
    1755:	mov    QWORD PTR [rdi],rax
    1758:	mov    r13,rdi
    175b:	mov    QWORD PTR [r12],rsi
    175f:	mov    r14,rsi
    1762:	mov    QWORD PTR [r12+0x8],rdx
    1767:	mov    rbx,rdx
    176a:	mov    rsi,r14
    176d:	mov    rdi,r13
    1770:	call   1775 <botlish_fn_11+0x55>
			1771: R_X86_64_PLT32	rt_str_len-0x4
    1775:	mov    rcx,rbx
    1778:	and    rcx,rax
    177b:	mov    rdx,rax
    177e:	test   rcx,0x1
    1785:	jne    17ab <botlish_fn_11+0x8b>
    178b:	mov    rsi,rbx
    178e:	mov    rdi,r13
    1791:	call   1796 <botlish_fn_11+0x76>
			1792: R_X86_64_PLT32	rt_int_cmp-0x4
    1796:	mov    ecx,0x2
    179b:	test   rax,rax
    179e:	cmovge rcx,QWORD PTR [rip+0x112]        # 18b8 <botlish_fn_11+0x198>
    17a6:	jmp    17bb <botlish_fn_11+0x9b>
    17ab:	mov    ecx,0x2
    17b0:	cmp    rbx,rdx
    17b3:	cmovge rcx,QWORD PTR [rip+0xfd]        # 18b8 <botlish_fn_11+0x198>
    17bb:	cmp    rcx,0x6
    17bf:	je     1863 <botlish_fn_11+0x143>
    17c5:	mov    QWORD PTR [r12+0x10],0x3
    17ce:	test   rbx,0x1
    17d5:	je     17ed <botlish_fn_11+0xcd>
    17db:	mov    rcx,rbx
    17de:	add    rcx,0x2
    17e2:	seto   al
    17e5:	test   al,al
    17e7:	je     1800 <botlish_fn_11+0xe0>
    17ed:	mov    edx,0x3
    17f2:	mov    rsi,rbx
    17f5:	mov    rdi,r13
    17f8:	call   17fd <botlish_fn_11+0xdd>
			17f9: R_X86_64_PLT32	rt_int_add-0x4
    17fd:	mov    rcx,rax
    1800:	mov    QWORD PTR [r12+0x10],rcx
    1805:	mov    rdx,rbx
    1808:	mov    rsi,r14
    180b:	mov    rdi,r13
    180e:	call   1813 <botlish_fn_11+0xf3>
			180f: R_X86_64_PLT32	rt_substr-0x4
    1813:	test   rax,rax
    1816:	jne    1841 <botlish_fn_11+0x121>
    181c:	mov    rdi,r13
    181f:	mov    QWORD PTR [rdi],r12
    1822:	xor    rax,rax
    1825:	mov    rbx,QWORD PTR [rsp]
    1829:	mov    r12,QWORD PTR [rsp+0x8]
    182e:	mov    r13,QWORD PTR [rsp+0x10]
    1833:	mov    r14,QWORD PTR [rsp+0x18]
    1838:	add    rsp,0x20
    183c:	mov    rsp,rbp
    183f:	pop    rbp
    1840:	ret
    1841:	mov    rdi,r13
    1844:	mov    QWORD PTR [rdi],r12
    1847:	mov    rbx,QWORD PTR [rsp]
    184b:	mov    r12,QWORD PTR [rsp+0x8]
    1850:	mov    r13,QWORD PTR [rsp+0x10]
    1855:	mov    r14,QWORD PTR [rsp+0x18]
    185a:	add    rsp,0x20
    185e:	mov    rsp,rbp
    1861:	pop    rbp
    1862:	ret
    1863:	mov    rdi,r13
    1866:	mov    rax,QWORD PTR [rdi+0x10]
    186a:	mov    rax,QWORD PTR [rax+0x10]
    186e:	mov    QWORD PTR [rdi],r12
    1871:	mov    rbx,QWORD PTR [rsp]
    1875:	mov    r12,QWORD PTR [rsp+0x8]
    187a:	mov    r13,QWORD PTR [rsp+0x10]
    187f:	mov    r14,QWORD PTR [rsp+0x18]
    1884:	add    rsp,0x20
    1888:	mov    rsp,rbp
    188b:	pop    rbp
    188c:	ret
    188d:	mov    r13,rdi
    1890:	call   1895 <botlish_fn_11+0x175>
			1891: R_X86_64_PLT32	rt_stack_overflow-0x4
    1895:	xor    rax,rax
    1898:	mov    rbx,QWORD PTR [rsp]
    189c:	mov    r12,QWORD PTR [rsp+0x8]
    18a1:	mov    r13,QWORD PTR [rsp+0x10]
    18a6:	mov    r14,QWORD PTR [rsp+0x18]
    18ab:	add    rsp,0x20
    18af:	mov    rsp,rbp
    18b2:	pop    rbp
    18b3:	ret
    18b4:	add    BYTE PTR [rax],al
    18b6:	add    BYTE PTR [rax],al
    18b8:	(bad)
    18b9:	add    BYTE PTR [rax],al
    18bb:	add    BYTE PTR [rax],al
    18bd:	add    BYTE PTR [rax],al
	...

00000000000018c0 <botlish_entry_11: peek<str, int>>:
    18c0:	push   rbp
    18c1:	mov    rbp,rsp
    18c4:	mov    rsi,QWORD PTR [rdx]
    18c7:	mov    rdx,QWORD PTR [rdx+0x8]
    18cb:	call   18d0 <botlish_entry_11+0x10>
			18cc: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    18d0:	mov    rsp,rbp
    18d3:	pop    rbp
    18d4:	ret
    18d5:	add    BYTE PTR [rax],al
	...

00000000000018d8 <botlish_fn_12: peek<str, int>>:
    18d8:	push   rbp
    18d9:	mov    rbp,rsp
    18dc:	sub    rsp,0x40
    18e0:	mov    QWORD PTR [rsp+0x10],rbx
    18e5:	mov    QWORD PTR [rsp+0x18],r12
    18ea:	mov    QWORD PTR [rsp+0x20],r13
    18ef:	mov    QWORD PTR [rsp+0x28],r14
    18f4:	mov    QWORD PTR [rsp+0x30],r15
    18f9:	mov    r13,rcx
    18fc:	mov    r12,QWORD PTR [rdi]
    18ff:	mov    rax,QWORD PTR [rdi+0x8]
    1903:	lea    rcx,[r12+0x18]
    1908:	cmp    rcx,rax
    190b:	ja     1a8c <botlish_fn_12+0x1b4>
    1911:	lea    rax,[r12+0x18]
    1916:	mov    QWORD PTR [rdi],rax
    1919:	mov    r15,rdi
    191c:	mov    QWORD PTR [r12],rsi
    1920:	mov    r14,rsi
    1923:	mov    QWORD PTR [r12+0x8],rdx
    1928:	mov    rbx,rdx
    192b:	mov    rsi,r14
    192e:	mov    rdi,r15
    1931:	call   1936 <botlish_fn_12+0x5e>
			1932: R_X86_64_PLT32	rt_str_len-0x4
    1936:	mov    rcx,rbx
    1939:	and    rcx,rax
    193c:	mov    rdx,rax
    193f:	test   rcx,0x1
    1946:	jne    196c <botlish_fn_12+0x94>
    194c:	mov    rsi,rbx
    194f:	mov    rdi,r15
    1952:	call   1957 <botlish_fn_12+0x7f>
			1953: R_X86_64_PLT32	rt_int_cmp-0x4
    1957:	mov    ecx,0x2
    195c:	test   rax,rax
    195f:	cmovge rcx,QWORD PTR [rip+0x159]        # 1ac0 <botlish_fn_12+0x1e8>
    1967:	jmp    197c <botlish_fn_12+0xa4>
    196c:	mov    ecx,0x2
    1971:	cmp    rbx,rdx
    1974:	cmovge rcx,QWORD PTR [rip+0x144]        # 1ac0 <botlish_fn_12+0x1e8>
    197c:	cmp    rcx,0x6
    1980:	je     1a4a <botlish_fn_12+0x172>
    1986:	mov    QWORD PTR [r12+0x10],0x3
    198f:	test   rbx,0x1
    1996:	je     19b7 <botlish_fn_12+0xdf>
    199c:	mov    rax,rbx
    199f:	add    rax,0x2
    19a3:	seto   cl
    19a6:	test   cl,cl
    19a8:	jne    19b7 <botlish_fn_12+0xdf>
    19ae:	mov    QWORD PTR [rsp],rax
    19b2:	jmp    19cb <botlish_fn_12+0xf3>
    19b7:	mov    edx,0x3
    19bc:	mov    rsi,rbx
    19bf:	mov    rdi,r15
    19c2:	call   19c7 <botlish_fn_12+0xef>
			19c3: R_X86_64_PLT32	rt_int_add-0x4
    19c7:	mov    QWORD PTR [rsp],rax
    19cb:	mov    rcx,QWORD PTR [rsp]
    19cf:	mov    rdx,rbx
    19d2:	mov    rsi,r14
    19d5:	mov    rdi,r15
    19d8:	call   19dd <botlish_fn_12+0x105>
			19d9: R_X86_64_PLT32	rt_str_region_check-0x4
    19dd:	test   rax,rax
    19e0:	jne    1a11 <botlish_fn_12+0x139>
    19e6:	mov    rdi,r15
    19e9:	mov    QWORD PTR [rdi],r12
    19ec:	xor    rax,rax
    19ef:	mov    rbx,QWORD PTR [rsp+0x10]
    19f4:	mov    r12,QWORD PTR [rsp+0x18]
    19f9:	mov    r13,QWORD PTR [rsp+0x20]
    19fe:	mov    r14,QWORD PTR [rsp+0x28]
    1a03:	mov    r15,QWORD PTR [rsp+0x30]
    1a08:	add    rsp,0x40
    1a0c:	mov    rsp,rbp
    1a0f:	pop    rbp
    1a10:	ret
    1a11:	mov    rdi,r15
    1a14:	mov    QWORD PTR [rdi],r12
    1a17:	mov    rcx,r13
    1a1a:	mov    QWORD PTR [rcx],rbx
    1a1d:	mov    rax,QWORD PTR [rsp]
    1a21:	mov    QWORD PTR [rcx+0x8],rax
    1a25:	mov    rax,r14
    1a28:	mov    rbx,QWORD PTR [rsp+0x10]
    1a2d:	mov    r12,QWORD PTR [rsp+0x18]
    1a32:	mov    r13,QWORD PTR [rsp+0x20]
    1a37:	mov    r14,QWORD PTR [rsp+0x28]
    1a3c:	mov    r15,QWORD PTR [rsp+0x30]
    1a41:	add    rsp,0x40
    1a45:	mov    rsp,rbp
    1a48:	pop    rbp
    1a49:	ret
    1a4a:	mov    rcx,r13
    1a4d:	mov    rdi,r15
    1a50:	mov    rax,QWORD PTR [rdi+0x10]
    1a54:	mov    rax,QWORD PTR [rax+0x10]
    1a58:	mov    QWORD PTR [rdi],r12
    1a5b:	mov    QWORD PTR [rcx],0x1
    1a62:	mov    QWORD PTR [rcx+0x8],0x1
    1a6a:	mov    rbx,QWORD PTR [rsp+0x10]
    1a6f:	mov    r12,QWORD PTR [rsp+0x18]
    1a74:	mov    r13,QWORD PTR [rsp+0x20]
    1a79:	mov    r14,QWORD PTR [rsp+0x28]
    1a7e:	mov    r15,QWORD PTR [rsp+0x30]
    1a83:	add    rsp,0x40
    1a87:	mov    rsp,rbp
    1a8a:	pop    rbp
    1a8b:	ret
    1a8c:	mov    r15,rdi
    1a8f:	call   1a94 <botlish_fn_12+0x1bc>
			1a90: R_X86_64_PLT32	rt_stack_overflow-0x4
    1a94:	xor    rax,rax
    1a97:	mov    rbx,QWORD PTR [rsp+0x10]
    1a9c:	mov    r12,QWORD PTR [rsp+0x18]
    1aa1:	mov    r13,QWORD PTR [rsp+0x20]
    1aa6:	mov    r14,QWORD PTR [rsp+0x28]
    1aab:	mov    r15,QWORD PTR [rsp+0x30]
    1ab0:	add    rsp,0x40
    1ab4:	mov    rsp,rbp
    1ab7:	pop    rbp
    1ab8:	ret
    1ab9:	add    BYTE PTR [rax],al
    1abb:	add    BYTE PTR [rax],al
    1abd:	add    BYTE PTR [rax],al
    1abf:	add    BYTE PTR [rsi],al
    1ac1:	add    BYTE PTR [rax],al
    1ac3:	add    BYTE PTR [rax],al
    1ac5:	add    BYTE PTR [rax],al
	...

0000000000001ac8 <botlish_entry_12: peek<str, int>>:
    1ac8:	push   rbp
    1ac9:	mov    rbp,rsp
    1acc:	ud2

0000000000001ace <botlish_fn_13: scan_unquoted<str, int, int>>:
    1ace:	push   rbp
    1acf:	mov    rbp,rsp
    1ad2:	sub    rsp,0x60
    1ad6:	mov    QWORD PTR [rsp+0x30],rbx
    1adb:	mov    QWORD PTR [rsp+0x38],r12
    1ae0:	mov    QWORD PTR [rsp+0x40],r13
    1ae5:	mov    QWORD PTR [rsp+0x48],r14
    1aea:	mov    QWORD PTR [rsp+0x50],r15
    1aef:	mov    r14,QWORD PTR [rdi]
    1af2:	mov    rax,QWORD PTR [rdi+0x8]
    1af6:	lea    r8,[r14+0x20]
    1afa:	cmp    r8,rax
    1afd:	ja     1d0e <botlish_fn_13+0x240>
    1b03:	lea    rax,[r14+0x20]
    1b07:	mov    QWORD PTR [rdi],rax
    1b0a:	mov    r15,rdi
    1b0d:	mov    QWORD PTR [r14+0x18],0x0
    1b15:	mov    QWORD PTR [r14],rsi
    1b18:	mov    QWORD PTR [rsp+0x10],rsi
    1b1d:	mov    QWORD PTR [r14+0x8],rdx
    1b21:	mov    QWORD PTR [rsp+0x18],rdx
    1b26:	mov    QWORD PTR [r14+0x10],rcx
    1b2a:	lea    rbx,[rsp]
    1b2e:	mov    QWORD PTR [rsp+0x20],rcx
    1b33:	mov    rcx,rbx
    1b36:	mov    rdx,QWORD PTR [rsp+0x20]
    1b3b:	mov    rsi,QWORD PTR [rsp+0x10]
    1b40:	mov    rdi,r15
    1b43:	call   1b48 <botlish_fn_13+0x7a>
			1b44: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1b48:	mov    rcx,rax
    1b4b:	mov    QWORD PTR [rsp+0x28],rax
    1b50:	test   rax,rcx
    1b53:	jne    1b61 <botlish_fn_13+0x93>
    1b59:	mov    rdi,r15
    1b5c:	jmp    1cb3 <botlish_fn_13+0x1e5>
    1b61:	mov    r12,QWORD PTR [rsp]
    1b65:	mov    r13,QWORD PTR [rsp+0x8]
    1b6a:	mov    rdi,r15
    1b6d:	mov    rcx,QWORD PTR [rdi+0x10]
    1b71:	mov    r8,QWORD PTR [rcx+0x10]
    1b75:	mov    rcx,r13
    1b78:	mov    rdx,r12
    1b7b:	mov    rsi,QWORD PTR [rsp+0x28]
    1b80:	call   1b85 <botlish_fn_13+0xb7>
			1b81: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b85:	cmp    rax,0x6
    1b89:	je     1bc8 <botlish_fn_13+0xfa>
    1b8f:	mov    rdi,r15
    1b92:	mov    rax,QWORD PTR [rdi+0x10]
    1b96:	mov    r8,QWORD PTR [rax+0x18]
    1b9a:	mov    rcx,r13
    1b9d:	mov    rdx,r12
    1ba0:	mov    rsi,QWORD PTR [rsp+0x28]
    1ba5:	call   1baa <botlish_fn_13+0xdc>
			1ba6: R_X86_64_PLT32	rt_str_region_eq-0x4
    1baa:	cmp    rax,0x6
    1bae:	je     1bbe <botlish_fn_13+0xf0>
    1bb4:	mov    eax,0x2
    1bb9:	jmp    1bcd <botlish_fn_13+0xff>
    1bbe:	mov    eax,0x6
    1bc3:	jmp    1bcd <botlish_fn_13+0xff>
    1bc8:	mov    eax,0x6
    1bcd:	cmp    rax,0x6
    1bd1:	je     1c10 <botlish_fn_13+0x142>
    1bd7:	mov    rdi,r15
    1bda:	mov    rcx,QWORD PTR [rdi+0x10]
    1bde:	mov    r8,QWORD PTR [rcx+0x20]
    1be2:	mov    rcx,r13
    1be5:	mov    rdx,r12
    1be8:	mov    rsi,QWORD PTR [rsp+0x28]
    1bed:	call   1bf2 <botlish_fn_13+0x124>
			1bee: R_X86_64_PLT32	rt_str_region_eq-0x4
    1bf2:	cmp    rax,0x6
    1bf6:	je     1c06 <botlish_fn_13+0x138>
    1bfc:	mov    eax,0x2
    1c01:	jmp    1c15 <botlish_fn_13+0x147>
    1c06:	mov    eax,0x6
    1c0b:	jmp    1c15 <botlish_fn_13+0x147>
    1c10:	mov    eax,0x6
    1c15:	cmp    rax,0x6
    1c19:	je     1c90 <botlish_fn_13+0x1c2>
    1c1f:	mov    QWORD PTR [r14+0x18],0x3
    1c27:	mov    rsi,QWORD PTR [rsp+0x20]
    1c2c:	test   rsi,0x1
    1c33:	je     1c5a <botlish_fn_13+0x18c>
    1c39:	mov    rsi,QWORD PTR [rsp+0x20]
    1c3e:	mov    rax,rsi
    1c41:	add    rax,0x2
    1c45:	seto   cl
    1c48:	test   cl,cl
    1c4a:	jne    1c5a <botlish_fn_13+0x18c>
    1c50:	mov    rsi,QWORD PTR [rsp+0x10]
    1c55:	jmp    1c71 <botlish_fn_13+0x1a3>
    1c5a:	mov    edx,0x3
    1c5f:	mov    rsi,QWORD PTR [rsp+0x20]
    1c64:	mov    rdi,r15
    1c67:	call   1c6c <botlish_fn_13+0x19e>
			1c68: R_X86_64_PLT32	rt_int_add-0x4
    1c6c:	mov    rsi,QWORD PTR [rsp+0x10]
    1c71:	mov    QWORD PTR [r14],rsi
    1c74:	mov    rdx,QWORD PTR [rsp+0x18]
    1c79:	mov    QWORD PTR [r14+0x8],rdx
    1c7d:	mov    QWORD PTR [r14+0x10],rax
    1c81:	mov    QWORD PTR [rsp+0x10],rsi
    1c86:	mov    QWORD PTR [rsp+0x20],rax
    1c8b:	jmp    1b33 <botlish_fn_13+0x65>
    1c90:	mov    rdx,QWORD PTR [rsp+0x18]
    1c95:	mov    rsi,QWORD PTR [rsp+0x10]
    1c9a:	mov    rcx,QWORD PTR [rsp+0x20]
    1c9f:	mov    rdi,r15
    1ca2:	call   1ca7 <botlish_fn_13+0x1d9>
			1ca3: R_X86_64_PLT32	rt_substr-0x4
    1ca7:	test   rax,rax
    1caa:	jne    1ce1 <botlish_fn_13+0x213>
    1cb0:	mov    rdi,r15
    1cb3:	mov    rdi,r15
    1cb6:	mov    QWORD PTR [rdi],r14
    1cb9:	xor    rdx,rdx
    1cbc:	mov    rax,rdx
    1cbf:	mov    rbx,QWORD PTR [rsp+0x30]
    1cc4:	mov    r12,QWORD PTR [rsp+0x38]
    1cc9:	mov    r13,QWORD PTR [rsp+0x40]
    1cce:	mov    r14,QWORD PTR [rsp+0x48]
    1cd3:	mov    r15,QWORD PTR [rsp+0x50]
    1cd8:	add    rsp,0x60
    1cdc:	mov    rsp,rbp
    1cdf:	pop    rbp
    1ce0:	ret
    1ce1:	mov    rdi,r15
    1ce4:	mov    QWORD PTR [rdi],r14
    1ce7:	mov    rdx,QWORD PTR [rsp+0x20]
    1cec:	mov    rbx,QWORD PTR [rsp+0x30]
    1cf1:	mov    r12,QWORD PTR [rsp+0x38]
    1cf6:	mov    r13,QWORD PTR [rsp+0x40]
    1cfb:	mov    r14,QWORD PTR [rsp+0x48]
    1d00:	mov    r15,QWORD PTR [rsp+0x50]
    1d05:	add    rsp,0x60
    1d09:	mov    rsp,rbp
    1d0c:	pop    rbp
    1d0d:	ret
    1d0e:	mov    r15,rdi
    1d11:	call   1d16 <botlish_fn_13+0x248>
			1d12: R_X86_64_PLT32	rt_stack_overflow-0x4
    1d16:	xor    rdx,rdx
    1d19:	mov    rax,rdx
    1d1c:	mov    rbx,QWORD PTR [rsp+0x30]
    1d21:	mov    r12,QWORD PTR [rsp+0x38]
    1d26:	mov    r13,QWORD PTR [rsp+0x40]
    1d2b:	mov    r14,QWORD PTR [rsp+0x48]
    1d30:	mov    r15,QWORD PTR [rsp+0x50]
    1d35:	add    rsp,0x60
    1d39:	mov    rsp,rbp
    1d3c:	pop    rbp
    1d3d:	ret

0000000000001d3e <botlish_entry_13: scan_unquoted<str, int, int>>:
    1d3e:	push   rbp
    1d3f:	mov    rbp,rsp
    1d42:	ud2

0000000000001d44 <botlish_fn_14: scan_quoted<str, int, str>>:
    1d44:	push   rbp
    1d45:	mov    rbp,rsp
    1d48:	sub    rsp,0x50
    1d4c:	mov    QWORD PTR [rsp+0x20],rbx
    1d51:	mov    QWORD PTR [rsp+0x28],r12
    1d56:	mov    QWORD PTR [rsp+0x30],r13
    1d5b:	mov    QWORD PTR [rsp+0x38],r14
    1d60:	mov    QWORD PTR [rsp+0x40],r15
    1d65:	mov    r13,QWORD PTR [rdi]
    1d68:	mov    rax,QWORD PTR [rdi+0x8]
    1d6c:	lea    r8,[r13+0x28]
    1d70:	cmp    r8,rax
    1d73:	ja     2045 <botlish_fn_14+0x301>
    1d79:	lea    rax,[r13+0x28]
    1d7d:	mov    QWORD PTR [rdi],rax
    1d80:	mov    r14,rdi
    1d83:	mov    QWORD PTR [r13+0x18],0x0
    1d8b:	mov    QWORD PTR [r13+0x20],0x0
    1d93:	mov    QWORD PTR [r13+0x0],rsi
    1d97:	mov    QWORD PTR [r13+0x8],rdx
    1d9b:	mov    QWORD PTR [r13+0x10],rcx
    1d9f:	lea    rbx,[rsp]
    1da3:	mov    r12,rsi
    1da6:	mov    r15,rdx
    1da9:	mov    QWORD PTR [rsp+0x10],rcx
    1dae:	mov    rdx,r15
    1db1:	mov    rsi,r12
    1db4:	mov    rdi,r14
    1db7:	call   1dbc <botlish_fn_14+0x78>
			1db8: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1dbc:	test   rax,rax
    1dbf:	jne    1dcd <botlish_fn_14+0x89>
    1dc5:	mov    rdi,r14
    1dc8:	jmp    1ffe <botlish_fn_14+0x2ba>
    1dcd:	mov    QWORD PTR [r13+0x18],rax
    1dd1:	mov    rdi,r14
    1dd4:	mov    QWORD PTR [rsp+0x18],rax
    1dd9:	mov    rdx,QWORD PTR [rdi+0x10]
    1ddd:	mov    rsi,QWORD PTR [rdx+0x28]
    1de1:	mov    edx,0x1
    1de6:	mov    ecx,0x3
    1deb:	mov    r8,QWORD PTR [rsp+0x18]
    1df0:	call   1df5 <botlish_fn_14+0xb1>
			1df1: R_X86_64_PLT32	rt_str_region_eq-0x4
    1df5:	cmp    rax,0x6
    1df9:	je     1e86 <botlish_fn_14+0x142>
    1dff:	mov    QWORD PTR [r13+0x20],0x3
    1e07:	mov    rsi,r15
    1e0a:	test   rsi,0x1
    1e11:	je     1e33 <botlish_fn_14+0xef>
    1e17:	mov    r8,rsi
    1e1a:	add    r8,0x2
    1e1e:	seto   r10b
    1e22:	test   r10b,r10b
    1e25:	jne    1e33 <botlish_fn_14+0xef>
    1e2b:	mov    rsi,r8
    1e2e:	jmp    1e43 <botlish_fn_14+0xff>
    1e33:	mov    edx,0x3
    1e38:	mov    rdi,r14
    1e3b:	call   1e40 <botlish_fn_14+0xfc>
			1e3c: R_X86_64_PLT32	rt_int_add-0x4
    1e40:	mov    rsi,rax
    1e43:	mov    QWORD PTR [r13+0x8],rsi
    1e47:	mov    r15,rsi
    1e4a:	mov    rsi,QWORD PTR [rsp+0x10]
    1e4f:	mov    rdx,QWORD PTR [rsp+0x18]
    1e54:	mov    rdi,r14
    1e57:	call   1e5c <botlish_fn_14+0x118>
			1e58: R_X86_64_PLT32	rt_str_cat-0x4
    1e5c:	test   rax,rax
    1e5f:	jne    1e6d <botlish_fn_14+0x129>
    1e65:	mov    rdi,r14
    1e68:	jmp    1ffe <botlish_fn_14+0x2ba>
    1e6d:	mov    QWORD PTR [r13+0x0],r12
    1e71:	mov    rsi,r15
    1e74:	mov    QWORD PTR [r13+0x8],rsi
    1e78:	mov    QWORD PTR [r13+0x10],rax
    1e7c:	mov    QWORD PTR [rsp+0x10],rax
    1e81:	jmp    1dae <botlish_fn_14+0x6a>
    1e86:	mov    QWORD PTR [r13+0x18],0x3
    1e8e:	mov    rsi,r15
    1e91:	test   rsi,0x1
    1e98:	je     1eb3 <botlish_fn_14+0x16f>
    1e9e:	mov    rsi,r15
    1ea1:	mov    rdx,rsi
    1ea4:	add    rdx,0x2
    1ea8:	seto   al
    1eab:	test   al,al
    1ead:	je     1ec6 <botlish_fn_14+0x182>
    1eb3:	mov    edx,0x3
    1eb8:	mov    rsi,r15
    1ebb:	mov    rdi,r14
    1ebe:	call   1ec3 <botlish_fn_14+0x17f>
			1ebf: R_X86_64_PLT32	rt_int_add-0x4
    1ec3:	mov    rdx,rax
    1ec6:	mov    QWORD PTR [r13+0x18],rdx
    1eca:	mov    rcx,rbx
    1ecd:	mov    rsi,r12
    1ed0:	mov    rdi,r14
    1ed3:	call   1ed8 <botlish_fn_14+0x194>
			1ed4: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1ed8:	test   rax,rax
    1edb:	mov    rsi,rax
    1ede:	jne    1eec <botlish_fn_14+0x1a8>
    1ee4:	mov    rdi,r14
    1ee7:	jmp    1ffe <botlish_fn_14+0x2ba>
    1eec:	mov    rdx,QWORD PTR [rsp]
    1ef0:	mov    rcx,QWORD PTR [rsp+0x8]
    1ef5:	mov    rdi,r14
    1ef8:	mov    rax,QWORD PTR [rdi+0x10]
    1efc:	mov    r8,QWORD PTR [rax+0x28]
    1f00:	call   1f05 <botlish_fn_14+0x1c1>
			1f01: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f05:	cmp    rax,0x6
    1f09:	je     1f87 <botlish_fn_14+0x243>
    1f0f:	mov    QWORD PTR [r13+0x0],0x3
    1f17:	mov    rsi,r15
    1f1a:	test   rsi,0x1
    1f21:	je     1f44 <botlish_fn_14+0x200>
    1f27:	mov    rsi,r15
    1f2a:	mov    rdx,rsi
    1f2d:	add    rdx,0x2
    1f31:	seto   al
    1f34:	test   al,al
    1f36:	jne    1f44 <botlish_fn_14+0x200>
    1f3c:	mov    rdi,r14
    1f3f:	jmp    1f5a <botlish_fn_14+0x216>
    1f44:	mov    edx,0x3
    1f49:	mov    rsi,r15
    1f4c:	mov    rdi,r14
    1f4f:	call   1f54 <botlish_fn_14+0x210>
			1f50: R_X86_64_PLT32	rt_int_add-0x4
    1f54:	mov    rdx,rax
    1f57:	mov    rdi,r14
    1f5a:	mov    rdi,r14
    1f5d:	mov    QWORD PTR [rdi],r13
    1f60:	mov    rax,QWORD PTR [rsp+0x10]
    1f65:	mov    rbx,QWORD PTR [rsp+0x20]
    1f6a:	mov    r12,QWORD PTR [rsp+0x28]
    1f6f:	mov    r13,QWORD PTR [rsp+0x30]
    1f74:	mov    r14,QWORD PTR [rsp+0x38]
    1f79:	mov    r15,QWORD PTR [rsp+0x40]
    1f7e:	add    rsp,0x50
    1f82:	mov    rsp,rbp
    1f85:	pop    rbp
    1f86:	ret
    1f87:	mov    QWORD PTR [r13+0x18],0x5
    1f8f:	mov    rsi,r15
    1f92:	test   rsi,0x1
    1f99:	je     1fbf <botlish_fn_14+0x27b>
    1f9f:	mov    rsi,r15
    1fa2:	mov    rax,rsi
    1fa5:	add    rax,0x4
    1fa9:	seto   cl
    1fac:	test   cl,cl
    1fae:	jne    1fbf <botlish_fn_14+0x27b>
    1fb4:	mov    rsi,rax
    1fb7:	mov    r15,rax
    1fba:	jmp    1fd5 <botlish_fn_14+0x291>
    1fbf:	mov    edx,0x5
    1fc4:	mov    rsi,r15
    1fc7:	mov    rdi,r14
    1fca:	call   1fcf <botlish_fn_14+0x28b>
			1fcb: R_X86_64_PLT32	rt_int_add-0x4
    1fcf:	mov    rsi,rax
    1fd2:	mov    r15,rax
    1fd5:	mov    QWORD PTR [r13+0x8],rsi
    1fd9:	mov    rdi,r14
    1fdc:	mov    rax,QWORD PTR [rdi+0x10]
    1fe0:	mov    rdx,QWORD PTR [rax+0x28]
    1fe4:	mov    QWORD PTR [r13+0x18],rdx
    1fe8:	mov    rsi,QWORD PTR [rsp+0x10]
    1fed:	call   1ff2 <botlish_fn_14+0x2ae>
			1fee: R_X86_64_PLT32	rt_str_cat-0x4
    1ff2:	test   rax,rax
    1ff5:	jne    202c <botlish_fn_14+0x2e8>
    1ffb:	mov    rdi,r14
    1ffe:	mov    rdi,r14
    2001:	mov    QWORD PTR [rdi],r13
    2004:	xor    rdx,rdx
    2007:	mov    rax,rdx
    200a:	mov    rbx,QWORD PTR [rsp+0x20]
    200f:	mov    r12,QWORD PTR [rsp+0x28]
    2014:	mov    r13,QWORD PTR [rsp+0x30]
    2019:	mov    r14,QWORD PTR [rsp+0x38]
    201e:	mov    r15,QWORD PTR [rsp+0x40]
    2023:	add    rsp,0x50
    2027:	mov    rsp,rbp
    202a:	pop    rbp
    202b:	ret
    202c:	mov    QWORD PTR [r13+0x0],r12
    2030:	mov    rsi,r15
    2033:	mov    QWORD PTR [r13+0x8],rsi
    2037:	mov    QWORD PTR [r13+0x10],rax
    203b:	mov    QWORD PTR [rsp+0x10],rax
    2040:	jmp    1dae <botlish_fn_14+0x6a>
    2045:	mov    r14,rdi
    2048:	call   204d <botlish_fn_14+0x309>
			2049: R_X86_64_PLT32	rt_stack_overflow-0x4
    204d:	xor    rdx,rdx
    2050:	mov    rax,rdx
    2053:	mov    rbx,QWORD PTR [rsp+0x20]
    2058:	mov    r12,QWORD PTR [rsp+0x28]
    205d:	mov    r13,QWORD PTR [rsp+0x30]
    2062:	mov    r14,QWORD PTR [rsp+0x38]
    2067:	mov    r15,QWORD PTR [rsp+0x40]
    206c:	add    rsp,0x50
    2070:	mov    rsp,rbp
    2073:	pop    rbp
    2074:	ret

0000000000002075 <botlish_entry_14: scan_quoted<str, int, str>>:
    2075:	push   rbp
    2076:	mov    rbp,rsp
    2079:	ud2

000000000000207b <botlish_fn_15: scan_field<str, int>>:
    207b:	push   rbp
    207c:	mov    rbp,rsp
    207f:	sub    rsp,0x30
    2083:	mov    QWORD PTR [rsp+0x10],rbx
    2088:	mov    QWORD PTR [rsp+0x18],r12
    208d:	mov    QWORD PTR [rsp+0x20],r13
    2092:	mov    QWORD PTR [rsp+0x28],r14
    2097:	mov    rbx,QWORD PTR [rdi]
    209a:	mov    rax,QWORD PTR [rdi+0x8]
    209e:	lea    rcx,[rbx+0x18]
    20a2:	cmp    rcx,rax
    20a5:	ja     2208 <botlish_fn_15+0x18d>
    20ab:	lea    rax,[rbx+0x18]
    20af:	mov    QWORD PTR [rdi],rax
    20b2:	mov    r12,rdi
    20b5:	mov    QWORD PTR [rbx+0x10],0x0
    20bd:	mov    QWORD PTR [rbx],rsi
    20c0:	mov    r13,rsi
    20c3:	mov    QWORD PTR [rbx+0x8],rdx
    20c7:	mov    r14,rdx
    20ca:	lea    rcx,[rsp]
    20ce:	mov    rdx,r14
    20d1:	mov    rsi,r13
    20d4:	mov    rdi,r12
    20d7:	call   20dc <botlish_fn_15+0x61>
			20d8: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    20dc:	test   rax,rax
    20df:	mov    rsi,rax
    20e2:	jne    20f0 <botlish_fn_15+0x75>
    20e8:	mov    rdi,r12
    20eb:	jmp    21bc <botlish_fn_15+0x141>
    20f0:	mov    rdx,QWORD PTR [rsp]
    20f4:	mov    rcx,QWORD PTR [rsp+0x8]
    20f9:	mov    rdi,r12
    20fc:	mov    rax,QWORD PTR [rdi+0x10]
    2100:	mov    r8,QWORD PTR [rax+0x28]
    2104:	call   2109 <botlish_fn_15+0x8e>
			2105: R_X86_64_PLT32	rt_str_region_eq-0x4
    2109:	cmp    rax,0x6
    210d:	je     2158 <botlish_fn_15+0xdd>
    2113:	mov    rcx,r14
    2116:	mov    rsi,r13
    2119:	mov    rdi,r12
    211c:	mov    rdx,rcx
    211f:	call   2124 <botlish_fn_15+0xa9>
			2120: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    2124:	test   rax,rax
    2127:	jne    2135 <botlish_fn_15+0xba>
    212d:	mov    rdi,r12
    2130:	jmp    21bc <botlish_fn_15+0x141>
    2135:	mov    rdi,r12
    2138:	mov    QWORD PTR [rdi],rbx
    213b:	mov    rbx,QWORD PTR [rsp+0x10]
    2140:	mov    r12,QWORD PTR [rsp+0x18]
    2145:	mov    r13,QWORD PTR [rsp+0x20]
    214a:	mov    r14,QWORD PTR [rsp+0x28]
    214f:	add    rsp,0x30
    2153:	mov    rsp,rbp
    2156:	pop    rbp
    2157:	ret
    2158:	mov    QWORD PTR [rbx+0x10],0x3
    2160:	mov    rdx,r14
    2163:	test   rdx,0x1
    216a:	je     2182 <botlish_fn_15+0x107>
    2170:	mov    rdx,r14
    2173:	add    rdx,0x2
    2177:	seto   al
    217a:	test   al,al
    217c:	je     2195 <botlish_fn_15+0x11a>
    2182:	mov    edx,0x3
    2187:	mov    rsi,r14
    218a:	mov    rdi,r12
    218d:	call   2192 <botlish_fn_15+0x117>
			218e: R_X86_64_PLT32	rt_int_add-0x4
    2192:	mov    rdx,rax
    2195:	mov    QWORD PTR [rbx+0x8],rdx
    2199:	mov    rdi,r12
    219c:	mov    rax,QWORD PTR [rdi+0x10]
    21a0:	mov    rcx,QWORD PTR [rax+0x10]
    21a4:	mov    QWORD PTR [rbx+0x10],rcx
    21a8:	mov    rsi,r13
    21ab:	call   21b0 <botlish_fn_15+0x135>
			21ac: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    21b0:	test   rax,rax
    21b3:	jne    21e5 <botlish_fn_15+0x16a>
    21b9:	mov    rdi,r12
    21bc:	mov    rdi,r12
    21bf:	mov    QWORD PTR [rdi],rbx
    21c2:	xor    rdx,rdx
    21c5:	mov    rax,rdx
    21c8:	mov    rbx,QWORD PTR [rsp+0x10]
    21cd:	mov    r12,QWORD PTR [rsp+0x18]
    21d2:	mov    r13,QWORD PTR [rsp+0x20]
    21d7:	mov    r14,QWORD PTR [rsp+0x28]
    21dc:	add    rsp,0x30
    21e0:	mov    rsp,rbp
    21e3:	pop    rbp
    21e4:	ret
    21e5:	mov    rdi,r12
    21e8:	mov    QWORD PTR [rdi],rbx
    21eb:	mov    rbx,QWORD PTR [rsp+0x10]
    21f0:	mov    r12,QWORD PTR [rsp+0x18]
    21f5:	mov    r13,QWORD PTR [rsp+0x20]
    21fa:	mov    r14,QWORD PTR [rsp+0x28]
    21ff:	add    rsp,0x30
    2203:	mov    rsp,rbp
    2206:	pop    rbp
    2207:	ret
    2208:	mov    r12,rdi
    220b:	call   2210 <botlish_fn_15+0x195>
			220c: R_X86_64_PLT32	rt_stack_overflow-0x4
    2210:	xor    rdx,rdx
    2213:	mov    rax,rdx
    2216:	mov    rbx,QWORD PTR [rsp+0x10]
    221b:	mov    r12,QWORD PTR [rsp+0x18]
    2220:	mov    r13,QWORD PTR [rsp+0x20]
    2225:	mov    r14,QWORD PTR [rsp+0x28]
    222a:	add    rsp,0x30
    222e:	mov    rsp,rbp
    2231:	pop    rbp
    2232:	ret

0000000000002233 <botlish_entry_15: scan_field<str, int>>:
    2233:	push   rbp
    2234:	mov    rbp,rsp
    2237:	ud2

0000000000002239 <botlish_fn_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    2239:	push   rbp
    223a:	mov    rbp,rsp
    223d:	sub    rsp,0x80
    2244:	mov    QWORD PTR [rsp+0x50],rbx
    2249:	mov    QWORD PTR [rsp+0x58],r12
    224e:	mov    QWORD PTR [rsp+0x60],r13
    2253:	mov    QWORD PTR [rsp+0x68],r14
    2258:	mov    QWORD PTR [rsp+0x70],r15
    225d:	mov    rbx,QWORD PTR [rdi]
    2260:	mov    rax,QWORD PTR [rdi+0x8]
    2264:	lea    r10,[rbx+0x30]
    2268:	cmp    r10,rax
    226b:	ja     2567 <botlish_fn_16+0x32e>
    2271:	lea    rax,[rbx+0x30]
    2275:	mov    QWORD PTR [rdi],rax
    2278:	mov    r14,rdi
    227b:	mov    QWORD PTR [rbx+0x28],0x0
    2283:	mov    QWORD PTR [rbx],rsi
    2286:	mov    QWORD PTR [rsp+0x20],rsi
    228b:	mov    QWORD PTR [rbx+0x8],rdx
    228f:	mov    QWORD PTR [rbx+0x10],rcx
    2293:	mov    QWORD PTR [rsp+0x28],rcx
    2298:	mov    QWORD PTR [rbx+0x18],r8
    229c:	mov    r13,r8
    229f:	mov    QWORD PTR [rbx+0x20],r9
    22a3:	mov    r12,r9
    22a6:	mov    rsi,QWORD PTR [rsp+0x20]
    22ab:	mov    rdi,r14
    22ae:	call   22b3 <botlish_fn_16+0x7a>
			22af: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    22b3:	test   rax,rax
    22b6:	jne    22c4 <botlish_fn_16+0x8b>
    22bc:	mov    rdi,r14
    22bf:	jmp    250b <botlish_fn_16+0x2d2>
    22c4:	mov    QWORD PTR [rbx+0x8],rax
    22c8:	mov    r8,rax
    22cb:	mov    QWORD PTR [rbx+0x28],rdx
    22cf:	mov    r15,rdx
    22d2:	lea    r9,[rsp]
    22d6:	mov    rcx,r12
    22d9:	mov    rdx,r13
    22dc:	mov    rsi,QWORD PTR [rsp+0x28]
    22e1:	mov    rdi,r14
    22e4:	call   22e9 <botlish_fn_16+0xb0>
			22e5: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[list<never>, mutarray, int], str>
    22e9:	test   rax,rax
    22ec:	jne    22fa <botlish_fn_16+0xc1>
    22f2:	mov    rdi,r14
    22f5:	jmp    250b <botlish_fn_16+0x2d2>
    22fa:	mov    QWORD PTR [rbx+0x8],rax
    22fe:	mov    QWORD PTR [rsp+0x40],rax
    2303:	mov    rdx,QWORD PTR [rsp]
    2307:	mov    QWORD PTR [rbx+0x10],rdx
    230b:	mov    QWORD PTR [rsp+0x38],rdx
    2310:	mov    rcx,QWORD PTR [rsp+0x8]
    2315:	mov    QWORD PTR [rbx+0x18],rcx
    2319:	mov    QWORD PTR [rsp+0x30],rcx
    231e:	lea    rcx,[rsp+0x10]
    2323:	mov    rdx,r15
    2326:	mov    rsi,QWORD PTR [rsp+0x20]
    232b:	mov    rdi,r14
    232e:	call   2333 <botlish_fn_16+0xfa>
			232f: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    2333:	test   rax,rax
    2336:	mov    QWORD PTR [rsp+0x28],rax
    233b:	jne    2349 <botlish_fn_16+0x110>
    2341:	mov    rdi,r14
    2344:	jmp    250b <botlish_fn_16+0x2d2>
    2349:	mov    r13,QWORD PTR [rsp+0x10]
    234e:	mov    r12,QWORD PTR [rsp+0x18]
    2353:	mov    rdi,r14
    2356:	mov    rsi,QWORD PTR [rdi+0x10]
    235a:	mov    r8,QWORD PTR [rsi+0x18]
    235e:	mov    rcx,r12
    2361:	mov    rdx,r13
    2364:	mov    rsi,QWORD PTR [rsp+0x28]
    2369:	call   236e <botlish_fn_16+0x135>
			236a: R_X86_64_PLT32	rt_str_region_eq-0x4
    236e:	cmp    rax,0x6
    2372:	je     2497 <botlish_fn_16+0x25e>
    2378:	mov    rdi,r14
    237b:	mov    r8,QWORD PTR [rdi+0x10]
    237f:	mov    r8,QWORD PTR [r8+0x20]
    2383:	mov    rcx,r12
    2386:	mov    rdx,r13
    2389:	mov    rsi,QWORD PTR [rsp+0x28]
    238e:	call   2393 <botlish_fn_16+0x15a>
			238f: R_X86_64_PLT32	rt_str_region_eq-0x4
    2393:	cmp    rax,0x6
    2397:	je     23f3 <botlish_fn_16+0x1ba>
    239d:	mov    rcx,QWORD PTR [rsp+0x30]
    23a2:	mov    rdx,QWORD PTR [rsp+0x38]
    23a7:	mov    rsi,QWORD PTR [rsp+0x40]
    23ac:	mov    rdi,r14
    23af:	call   23b4 <botlish_fn_16+0x17b>
			23b0: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    23b4:	test   rax,rax
    23b7:	jne    23c5 <botlish_fn_16+0x18c>
    23bd:	mov    rdi,r14
    23c0:	jmp    250b <botlish_fn_16+0x2d2>
    23c5:	mov    rdi,r14
    23c8:	mov    QWORD PTR [rdi],rbx
    23cb:	mov    rdx,r15
    23ce:	mov    rbx,QWORD PTR [rsp+0x50]
    23d3:	mov    r12,QWORD PTR [rsp+0x58]
    23d8:	mov    r13,QWORD PTR [rsp+0x60]
    23dd:	mov    r14,QWORD PTR [rsp+0x68]
    23e2:	mov    r15,QWORD PTR [rsp+0x70]
    23e7:	add    rsp,0x80
    23ee:	mov    rsp,rbp
    23f1:	pop    rbp
    23f2:	ret
    23f3:	mov    rcx,QWORD PTR [rsp+0x30]
    23f8:	mov    rdx,QWORD PTR [rsp+0x38]
    23fd:	mov    rsi,QWORD PTR [rsp+0x40]
    2402:	mov    rdi,r14
    2405:	call   240a <botlish_fn_16+0x1d1>
			2406: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    240a:	test   rax,rax
    240d:	jne    241b <botlish_fn_16+0x1e2>
    2413:	mov    rdi,r14
    2416:	jmp    250b <botlish_fn_16+0x2d2>
    241b:	mov    QWORD PTR [rbx],rax
    241e:	mov    r12,rax
    2421:	mov    QWORD PTR [rbx+0x8],0x3
    2429:	mov    rdx,r15
    242c:	test   rdx,0x1
    2433:	je     2453 <botlish_fn_16+0x21a>
    2439:	mov    rdx,r15
    243c:	add    rdx,0x2
    2440:	seto   al
    2443:	test   al,al
    2445:	jne    2453 <botlish_fn_16+0x21a>
    244b:	mov    rdi,r14
    244e:	jmp    2469 <botlish_fn_16+0x230>
    2453:	mov    edx,0x3
    2458:	mov    rsi,r15
    245b:	mov    rdi,r14
    245e:	call   2463 <botlish_fn_16+0x22a>
			245f: R_X86_64_PLT32	rt_int_add-0x4
    2463:	mov    rdx,rax
    2466:	mov    rdi,r14
    2469:	mov    rdi,r14
    246c:	mov    QWORD PTR [rdi],rbx
    246f:	mov    rax,r12
    2472:	mov    rbx,QWORD PTR [rsp+0x50]
    2477:	mov    r12,QWORD PTR [rsp+0x58]
    247c:	mov    r13,QWORD PTR [rsp+0x60]
    2481:	mov    r14,QWORD PTR [rsp+0x68]
    2486:	mov    r15,QWORD PTR [rsp+0x70]
    248b:	add    rsp,0x80
    2492:	mov    rsp,rbp
    2495:	pop    rbp
    2496:	ret
    2497:	mov    rsi,r15
    249a:	mov    edx,0x3
    249f:	mov    rcx,rdx
    24a2:	mov    QWORD PTR [rbx+0x20],0x3
    24aa:	test   rsi,0x1
    24b1:	jne    24bf <botlish_fn_16+0x286>
    24b7:	mov    rdx,rcx
    24ba:	jmp    24d4 <botlish_fn_16+0x29b>
    24bf:	mov    rdx,rsi
    24c2:	add    rdx,0x2
    24c6:	seto   al
    24c9:	test   al,al
    24cb:	je     24df <botlish_fn_16+0x2a6>
    24d1:	mov    rdx,rcx
    24d4:	mov    rdi,r14
    24d7:	call   24dc <botlish_fn_16+0x2a3>
			24d8: R_X86_64_PLT32	rt_int_add-0x4
    24dc:	mov    rdx,rax
    24df:	mov    QWORD PTR [rbx+0x20],rdx
    24e3:	mov    rcx,QWORD PTR [rsp+0x40]
    24e8:	mov    rsi,QWORD PTR [rsp+0x20]
    24ed:	mov    r8,QWORD PTR [rsp+0x38]
    24f2:	mov    r9,QWORD PTR [rsp+0x30]
    24f7:	mov    rdi,r14
    24fa:	call   24ff <botlish_fn_16+0x2c6>
			24fb: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int, list[list<mutarray>, mutarray, int]>
    24ff:	test   rax,rax
    2502:	jne    253c <botlish_fn_16+0x303>
    2508:	mov    rdi,r14
    250b:	mov    rdi,r14
    250e:	mov    QWORD PTR [rdi],rbx
    2511:	xor    rdx,rdx
    2514:	mov    rax,rdx
    2517:	mov    rbx,QWORD PTR [rsp+0x50]
    251c:	mov    r12,QWORD PTR [rsp+0x58]
    2521:	mov    r13,QWORD PTR [rsp+0x60]
    2526:	mov    r14,QWORD PTR [rsp+0x68]
    252b:	mov    r15,QWORD PTR [rsp+0x70]
    2530:	add    rsp,0x80
    2537:	mov    rsp,rbp
    253a:	pop    rbp
    253b:	ret
    253c:	mov    rdi,r14
    253f:	mov    QWORD PTR [rdi],rbx
    2542:	mov    rbx,QWORD PTR [rsp+0x50]
    2547:	mov    r12,QWORD PTR [rsp+0x58]
    254c:	mov    r13,QWORD PTR [rsp+0x60]
    2551:	mov    r14,QWORD PTR [rsp+0x68]
    2556:	mov    r15,QWORD PTR [rsp+0x70]
    255b:	add    rsp,0x80
    2562:	mov    rsp,rbp
    2565:	pop    rbp
    2566:	ret
    2567:	mov    r14,rdi
    256a:	call   256f <botlish_fn_16+0x336>
			256b: R_X86_64_PLT32	rt_stack_overflow-0x4
    256f:	xor    rdx,rdx
    2572:	mov    rax,rdx
    2575:	mov    rbx,QWORD PTR [rsp+0x50]
    257a:	mov    r12,QWORD PTR [rsp+0x58]
    257f:	mov    r13,QWORD PTR [rsp+0x60]
    2584:	mov    r14,QWORD PTR [rsp+0x68]
    2589:	mov    r15,QWORD PTR [rsp+0x70]
    258e:	add    rsp,0x80
    2595:	mov    rsp,rbp
    2598:	pop    rbp
    2599:	ret

000000000000259a <botlish_entry_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    259a:	push   rbp
    259b:	mov    rbp,rsp
    259e:	ud2

00000000000025a0 <botlish_fn_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    25a0:	push   rbp
    25a1:	mov    rbp,rsp
    25a4:	sub    rsp,0x90
    25ab:	mov    QWORD PTR [rsp+0x60],rbx
    25b0:	mov    QWORD PTR [rsp+0x68],r12
    25b5:	mov    QWORD PTR [rsp+0x70],r13
    25ba:	mov    QWORD PTR [rsp+0x78],r14
    25bf:	mov    QWORD PTR [rsp+0x80],r15
    25c7:	mov    r14,QWORD PTR [rdi]
    25ca:	mov    rax,QWORD PTR [rdi+0x8]
    25ce:	lea    r10,[r14+0x30]
    25d2:	cmp    r10,rax
    25d5:	ja     28f3 <botlish_fn_17+0x353>
    25db:	lea    rax,[r14+0x30]
    25df:	mov    QWORD PTR [rdi],rax
    25e2:	mov    QWORD PTR [rsp+0x20],rdi
    25e7:	mov    QWORD PTR [r14+0x28],0x0
    25ef:	mov    QWORD PTR [r14],rsi
    25f2:	mov    QWORD PTR [r14+0x8],rdx
    25f6:	mov    QWORD PTR [r14+0x10],rcx
    25fa:	mov    QWORD PTR [r14+0x18],r8
    25fe:	mov    QWORD PTR [r14+0x20],r9
    2602:	lea    r12,[rsp]
    2606:	mov    QWORD PTR [rsp+0x50],r12
    260b:	lea    r12,[rsp+0x10]
    2610:	mov    rbx,rcx
    2613:	mov    r13,rsi
    2616:	mov    QWORD PTR [rsp+0x28],r8
    261b:	mov    QWORD PTR [rsp+0x30],r9
    2620:	mov    rsi,r13
    2623:	mov    rdi,QWORD PTR [rsp+0x20]
    2628:	call   262d <botlish_fn_17+0x8d>
			2629: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    262d:	mov    QWORD PTR [rsp+0x48],rdx
    2632:	test   rax,rax
    2635:	jne    2645 <botlish_fn_17+0xa5>
    263b:	mov    rdi,QWORD PTR [rsp+0x20]
    2640:	jmp    27ba <botlish_fn_17+0x21a>
    2645:	mov    QWORD PTR [r14+0x8],rax
    2649:	mov    rdx,QWORD PTR [rsp+0x48]
    264e:	mov    r8,rax
    2651:	mov    QWORD PTR [r14+0x28],rdx
    2655:	mov    rcx,QWORD PTR [rsp+0x30]
    265a:	mov    rdx,QWORD PTR [rsp+0x28]
    265f:	mov    rsi,rbx
    2662:	mov    rdi,QWORD PTR [rsp+0x20]
    2667:	mov    r9,QWORD PTR [rsp+0x50]
    266c:	call   2671 <botlish_fn_17+0xd1>
			266d: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], str>
    2671:	test   rax,rax
    2674:	jne    2684 <botlish_fn_17+0xe4>
    267a:	mov    rdi,QWORD PTR [rsp+0x20]
    267f:	jmp    27ba <botlish_fn_17+0x21a>
    2684:	mov    QWORD PTR [r14+0x8],rax
    2688:	mov    QWORD PTR [rsp+0x40],rax
    268d:	mov    rdx,QWORD PTR [rsp]
    2691:	mov    QWORD PTR [rsp+0x28],rdx
    2696:	mov    QWORD PTR [r14+0x10],rdx
    269a:	mov    rcx,QWORD PTR [rsp+0x8]
    269f:	mov    QWORD PTR [r14+0x18],rcx
    26a3:	mov    QWORD PTR [rsp+0x30],rcx
    26a8:	mov    rcx,r12
    26ab:	mov    rdx,QWORD PTR [rsp+0x48]
    26b0:	mov    rsi,r13
    26b3:	mov    rdi,QWORD PTR [rsp+0x20]
    26b8:	call   26bd <botlish_fn_17+0x11d>
			26b9: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    26bd:	test   rax,rax
    26c0:	mov    QWORD PTR [rsp+0x38],rax
    26c5:	jne    26d5 <botlish_fn_17+0x135>
    26cb:	mov    rdi,QWORD PTR [rsp+0x20]
    26d0:	jmp    27ba <botlish_fn_17+0x21a>
    26d5:	mov    rbx,QWORD PTR [rsp+0x10]
    26da:	mov    r15,QWORD PTR [rsp+0x18]
    26df:	mov    rdi,QWORD PTR [rsp+0x20]
    26e4:	mov    rdi,QWORD PTR [rdi+0x10]
    26e8:	mov    r8,QWORD PTR [rdi+0x18]
    26ec:	mov    rcx,r15
    26ef:	mov    rdx,rbx
    26f2:	mov    rsi,QWORD PTR [rsp+0x38]
    26f7:	mov    rdi,QWORD PTR [rsp+0x20]
    26fc:	call   2701 <botlish_fn_17+0x161>
			26fd: R_X86_64_PLT32	rt_str_region_eq-0x4
    2701:	cmp    rax,0x6
    2705:	je     287d <botlish_fn_17+0x2dd>
    270b:	mov    rdi,QWORD PTR [rsp+0x20]
    2710:	mov    r10,QWORD PTR [rdi+0x10]
    2714:	mov    r8,QWORD PTR [r10+0x20]
    2718:	mov    rcx,r15
    271b:	mov    rdx,rbx
    271e:	mov    rsi,QWORD PTR [rsp+0x38]
    2723:	call   2728 <botlish_fn_17+0x188>
			2724: R_X86_64_PLT32	rt_str_region_eq-0x4
    2728:	cmp    rax,0x6
    272c:	je     2793 <botlish_fn_17+0x1f3>
    2732:	mov    rcx,QWORD PTR [rsp+0x30]
    2737:	mov    rdx,QWORD PTR [rsp+0x28]
    273c:	mov    rsi,QWORD PTR [rsp+0x40]
    2741:	mov    rdi,QWORD PTR [rsp+0x20]
    2746:	call   274b <botlish_fn_17+0x1ab>
			2747: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    274b:	test   rax,rax
    274e:	jne    275e <botlish_fn_17+0x1be>
    2754:	mov    rdi,QWORD PTR [rsp+0x20]
    2759:	jmp    27ba <botlish_fn_17+0x21a>
    275e:	mov    rdi,QWORD PTR [rsp+0x20]
    2763:	mov    QWORD PTR [rdi],r14
    2766:	mov    rdx,QWORD PTR [rsp+0x48]
    276b:	mov    rbx,QWORD PTR [rsp+0x60]
    2770:	mov    r12,QWORD PTR [rsp+0x68]
    2775:	mov    r13,QWORD PTR [rsp+0x70]
    277a:	mov    r14,QWORD PTR [rsp+0x78]
    277f:	mov    r15,QWORD PTR [rsp+0x80]
    2787:	add    rsp,0x90
    278e:	mov    rsp,rbp
    2791:	pop    rbp
    2792:	ret
    2793:	mov    rcx,QWORD PTR [rsp+0x30]
    2798:	mov    rdx,QWORD PTR [rsp+0x28]
    279d:	mov    rsi,QWORD PTR [rsp+0x40]
    27a2:	mov    rdi,QWORD PTR [rsp+0x20]
    27a7:	call   27ac <botlish_fn_17+0x20c>
			27a8: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    27ac:	test   rax,rax
    27af:	jne    27f0 <botlish_fn_17+0x250>
    27b5:	mov    rdi,QWORD PTR [rsp+0x20]
    27ba:	mov    rdi,QWORD PTR [rsp+0x20]
    27bf:	mov    QWORD PTR [rdi],r14
    27c2:	xor    rdx,rdx
    27c5:	mov    rax,rdx
    27c8:	mov    rbx,QWORD PTR [rsp+0x60]
    27cd:	mov    r12,QWORD PTR [rsp+0x68]
    27d2:	mov    r13,QWORD PTR [rsp+0x70]
    27d7:	mov    r14,QWORD PTR [rsp+0x78]
    27dc:	mov    r15,QWORD PTR [rsp+0x80]
    27e4:	add    rsp,0x90
    27eb:	mov    rsp,rbp
    27ee:	pop    rbp
    27ef:	ret
    27f0:	mov    QWORD PTR [r14],rax
    27f3:	mov    rbx,rax
    27f6:	mov    QWORD PTR [r14+0x8],0x3
    27fe:	mov    rdx,QWORD PTR [rsp+0x48]
    2803:	test   rdx,0x1
    280a:	je     282e <botlish_fn_17+0x28e>
    2810:	mov    rdx,QWORD PTR [rsp+0x48]
    2815:	add    rdx,0x2
    2819:	seto   al
    281c:	test   al,al
    281e:	jne    282e <botlish_fn_17+0x28e>
    2824:	mov    rdi,QWORD PTR [rsp+0x20]
    2829:	jmp    284a <botlish_fn_17+0x2aa>
    282e:	mov    edx,0x3
    2833:	mov    rsi,QWORD PTR [rsp+0x48]
    2838:	mov    rdi,QWORD PTR [rsp+0x20]
    283d:	call   2842 <botlish_fn_17+0x2a2>
			283e: R_X86_64_PLT32	rt_int_add-0x4
    2842:	mov    rdx,rax
    2845:	mov    rdi,QWORD PTR [rsp+0x20]
    284a:	mov    rdi,QWORD PTR [rsp+0x20]
    284f:	mov    QWORD PTR [rdi],r14
    2852:	mov    rax,rbx
    2855:	mov    rbx,QWORD PTR [rsp+0x60]
    285a:	mov    r12,QWORD PTR [rsp+0x68]
    285f:	mov    r13,QWORD PTR [rsp+0x70]
    2864:	mov    r14,QWORD PTR [rsp+0x78]
    2869:	mov    r15,QWORD PTR [rsp+0x80]
    2871:	add    rsp,0x90
    2878:	mov    rsp,rbp
    287b:	pop    rbp
    287c:	ret
    287d:	mov    rsi,QWORD PTR [rsp+0x48]
    2882:	mov    edx,0x3
    2887:	mov    rcx,rdx
    288a:	mov    QWORD PTR [r14+0x20],0x3
    2892:	test   rsi,0x1
    2899:	jne    28a7 <botlish_fn_17+0x307>
    289f:	mov    rdx,rcx
    28a2:	jmp    28bc <botlish_fn_17+0x31c>
    28a7:	mov    rdx,rsi
    28aa:	add    rdx,0x2
    28ae:	seto   al
    28b1:	test   al,al
    28b3:	je     28c9 <botlish_fn_17+0x329>
    28b9:	mov    rdx,rcx
    28bc:	mov    rdi,QWORD PTR [rsp+0x20]
    28c1:	call   28c6 <botlish_fn_17+0x326>
			28c2: R_X86_64_PLT32	rt_int_add-0x4
    28c6:	mov    rdx,rax
    28c9:	mov    QWORD PTR [r14],r13
    28cc:	mov    QWORD PTR [r14+0x8],rdx
    28d0:	mov    rsi,QWORD PTR [rsp+0x40]
    28d5:	mov    QWORD PTR [r14+0x10],rsi
    28d9:	mov    rax,QWORD PTR [rsp+0x28]
    28de:	mov    QWORD PTR [r14+0x18],rax
    28e2:	mov    rcx,QWORD PTR [rsp+0x30]
    28e7:	mov    QWORD PTR [r14+0x20],rcx
    28eb:	mov    rbx,rsi
    28ee:	jmp    2620 <botlish_fn_17+0x80>
    28f3:	mov    QWORD PTR [rsp+0x20],rdi
    28f8:	call   28fd <botlish_fn_17+0x35d>
			28f9: R_X86_64_PLT32	rt_stack_overflow-0x4
    28fd:	xor    rdx,rdx
    2900:	mov    rax,rdx
    2903:	mov    rbx,QWORD PTR [rsp+0x60]
    2908:	mov    r12,QWORD PTR [rsp+0x68]
    290d:	mov    r13,QWORD PTR [rsp+0x70]
    2912:	mov    r14,QWORD PTR [rsp+0x78]
    2917:	mov    r15,QWORD PTR [rsp+0x80]
    291f:	add    rsp,0x90
    2926:	mov    rsp,rbp
    2929:	pop    rbp
    292a:	ret

000000000000292b <botlish_entry_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    292b:	push   rbp
    292c:	mov    rbp,rsp
    292f:	ud2

0000000000002931 <botlish_fn_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    2931:	push   rbp
    2932:	mov    rbp,rsp
    2935:	sub    rsp,0x60
    2939:	mov    QWORD PTR [rsp+0x30],rbx
    293e:	mov    QWORD PTR [rsp+0x38],r12
    2943:	mov    QWORD PTR [rsp+0x40],r13
    2948:	mov    QWORD PTR [rsp+0x48],r14
    294d:	mov    QWORD PTR [rsp+0x50],r15
    2952:	mov    rbx,QWORD PTR [rdi]
    2955:	mov    rax,QWORD PTR [rdi+0x8]
    2959:	lea    r10,[rbx+0x40]
    295d:	cmp    r10,rax
    2960:	ja     2b33 <botlish_fn_18+0x202>
    2966:	lea    rax,[rbx+0x40]
    296a:	mov    QWORD PTR [rdi],rax
    296d:	mov    r12,rdi
    2970:	mov    QWORD PTR [rbx+0x28],0x0
    2978:	mov    QWORD PTR [rbx+0x30],0x0
    2980:	mov    QWORD PTR [rbx+0x38],0x0
    2988:	mov    QWORD PTR [rbx],rsi
    298b:	mov    r13,rsi
    298e:	mov    QWORD PTR [rbx+0x8],rdx
    2992:	mov    QWORD PTR [rsp+0x20],rdx
    2997:	mov    QWORD PTR [rbx+0x10],rcx
    299b:	mov    QWORD PTR [rsp+0x28],rcx
    29a0:	mov    QWORD PTR [rbx+0x18],r8
    29a4:	mov    r15,r8
    29a7:	mov    QWORD PTR [rbx+0x20],r9
    29ab:	mov    r14,r9
    29ae:	mov    rsi,r13
    29b1:	mov    rdi,r12
    29b4:	call   29b9 <botlish_fn_18+0x88>
			29b5: R_X86_64_PLT32	rt_str_len-0x4
    29b9:	mov    rdx,QWORD PTR [rsp+0x20]
    29be:	mov    rcx,rdx
    29c1:	sar    rcx,1
    29c4:	sar    rax,1
    29c7:	cmp    rcx,rax
    29ca:	jge    2ac1 <botlish_fn_18+0x190>
    29d0:	lea    rsi,[rsp]
    29d4:	mov    rdi,r12
    29d7:	call   29dc <botlish_fn_18+0xab>
			29d8: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    29dc:	test   rax,rax
    29df:	jne    29ed <botlish_fn_18+0xbc>
    29e5:	mov    rdi,r12
    29e8:	jmp    2ae0 <botlish_fn_18+0x1af>
    29ed:	mov    QWORD PTR [rbx+0x28],rax
    29f1:	mov    rcx,rax
    29f4:	mov    r8,QWORD PTR [rsp]
    29f8:	mov    QWORD PTR [rbx+0x30],r8
    29fc:	mov    r9,QWORD PTR [rsp+0x8]
    2a01:	mov    QWORD PTR [rbx+0x38],r9
    2a05:	mov    rdx,QWORD PTR [rsp+0x20]
    2a0a:	mov    rsi,r13
    2a0d:	mov    rdi,r12
    2a10:	call   2a15 <botlish_fn_18+0xe4>
			2a11: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    2a15:	test   rax,rax
    2a18:	jne    2a26 <botlish_fn_18+0xf5>
    2a1e:	mov    rdi,r12
    2a21:	jmp    2ae0 <botlish_fn_18+0x1af>
    2a26:	mov    QWORD PTR [rbx+0x8],rax
    2a2a:	mov    r8,rax
    2a2d:	mov    QWORD PTR [rbx+0x28],rdx
    2a31:	mov    QWORD PTR [rsp+0x20],rdx
    2a36:	lea    r9,[rsp+0x10]
    2a3b:	mov    rcx,r14
    2a3e:	mov    rdx,r15
    2a41:	mov    rsi,QWORD PTR [rsp+0x28]
    2a46:	mov    rdi,r12
    2a49:	call   2a4e <botlish_fn_18+0x11d>
			2a4a: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[list<never>, mutarray, int], list>
    2a4e:	test   rax,rax
    2a51:	jne    2a5f <botlish_fn_18+0x12e>
    2a57:	mov    rdi,r12
    2a5a:	jmp    2ae0 <botlish_fn_18+0x1af>
    2a5f:	mov    QWORD PTR [rbx+0x8],rax
    2a63:	mov    rcx,rax
    2a66:	mov    r8,QWORD PTR [rsp+0x10]
    2a6b:	mov    QWORD PTR [rbx+0x10],r8
    2a6f:	mov    r9,QWORD PTR [rsp+0x18]
    2a74:	mov    QWORD PTR [rbx+0x18],r9
    2a78:	mov    rdx,QWORD PTR [rsp+0x20]
    2a7d:	mov    rsi,r13
    2a80:	mov    rdi,r12
    2a83:	call   2a88 <botlish_fn_18+0x157>
			2a84: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    2a88:	test   rax,rax
    2a8b:	jne    2a99 <botlish_fn_18+0x168>
    2a91:	mov    rdi,r12
    2a94:	jmp    2ae0 <botlish_fn_18+0x1af>
    2a99:	mov    rdi,r12
    2a9c:	mov    QWORD PTR [rdi],rbx
    2a9f:	mov    rbx,QWORD PTR [rsp+0x30]
    2aa4:	mov    r12,QWORD PTR [rsp+0x38]
    2aa9:	mov    r13,QWORD PTR [rsp+0x40]
    2aae:	mov    r14,QWORD PTR [rsp+0x48]
    2ab3:	mov    r15,QWORD PTR [rsp+0x50]
    2ab8:	add    rsp,0x60
    2abc:	mov    rsp,rbp
    2abf:	pop    rbp
    2ac0:	ret
    2ac1:	mov    rcx,r14
    2ac4:	mov    rdx,r15
    2ac7:	mov    rsi,QWORD PTR [rsp+0x28]
    2acc:	mov    rdi,r12
    2acf:	call   2ad4 <botlish_fn_18+0x1a3>
			2ad0: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    2ad4:	test   rax,rax
    2ad7:	jne    2b0b <botlish_fn_18+0x1da>
    2add:	mov    rdi,r12
    2ae0:	mov    rdi,r12
    2ae3:	mov    QWORD PTR [rdi],rbx
    2ae6:	xor    rax,rax
    2ae9:	mov    rbx,QWORD PTR [rsp+0x30]
    2aee:	mov    r12,QWORD PTR [rsp+0x38]
    2af3:	mov    r13,QWORD PTR [rsp+0x40]
    2af8:	mov    r14,QWORD PTR [rsp+0x48]
    2afd:	mov    r15,QWORD PTR [rsp+0x50]
    2b02:	add    rsp,0x60
    2b06:	mov    rsp,rbp
    2b09:	pop    rbp
    2b0a:	ret
    2b0b:	mov    rdi,r12
    2b0e:	mov    QWORD PTR [rdi],rbx
    2b11:	mov    rbx,QWORD PTR [rsp+0x30]
    2b16:	mov    r12,QWORD PTR [rsp+0x38]
    2b1b:	mov    r13,QWORD PTR [rsp+0x40]
    2b20:	mov    r14,QWORD PTR [rsp+0x48]
    2b25:	mov    r15,QWORD PTR [rsp+0x50]
    2b2a:	add    rsp,0x60
    2b2e:	mov    rsp,rbp
    2b31:	pop    rbp
    2b32:	ret
    2b33:	mov    r12,rdi
    2b36:	call   2b3b <botlish_fn_18+0x20a>
			2b37: R_X86_64_PLT32	rt_stack_overflow-0x4
    2b3b:	xor    rax,rax
    2b3e:	mov    rbx,QWORD PTR [rsp+0x30]
    2b43:	mov    r12,QWORD PTR [rsp+0x38]
    2b48:	mov    r13,QWORD PTR [rsp+0x40]
    2b4d:	mov    r14,QWORD PTR [rsp+0x48]
    2b52:	mov    r15,QWORD PTR [rsp+0x50]
    2b57:	add    rsp,0x60
    2b5b:	mov    rsp,rbp
    2b5e:	pop    rbp
    2b5f:	ret

0000000000002b60 <botlish_entry_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    2b60:	push   rbp
    2b61:	mov    rbp,rsp
    2b64:	mov    rsi,QWORD PTR [rdx]
    2b67:	mov    r10,QWORD PTR [rdx+0x8]
    2b6b:	mov    rcx,QWORD PTR [rdx+0x10]
    2b6f:	mov    r8,QWORD PTR [rdx+0x18]
    2b73:	mov    r9,QWORD PTR [rdx+0x20]
    2b77:	mov    rdx,r10
    2b7a:	call   2b7f <botlish_entry_18+0x1f>
			2b7b: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    2b7f:	mov    rsp,rbp
    2b82:	pop    rbp
    2b83:	ret
    2b84:	add    BYTE PTR [rax],al
	...

0000000000002b88 <botlish_fn_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    2b88:	push   rbp
    2b89:	mov    rbp,rsp
    2b8c:	sub    rsp,0x70
    2b90:	mov    QWORD PTR [rsp+0x40],rbx
    2b95:	mov    QWORD PTR [rsp+0x48],r12
    2b9a:	mov    QWORD PTR [rsp+0x50],r13
    2b9f:	mov    QWORD PTR [rsp+0x58],r14
    2ba4:	mov    QWORD PTR [rsp+0x60],r15
    2ba9:	mov    r14,QWORD PTR [rdi]
    2bac:	mov    rax,QWORD PTR [rdi+0x8]
    2bb0:	lea    r10,[r14+0x40]
    2bb4:	cmp    r10,rax
    2bb7:	ja     2dbe <botlish_fn_19+0x236>
    2bbd:	lea    rax,[r14+0x40]
    2bc1:	mov    QWORD PTR [rdi],rax
    2bc4:	mov    QWORD PTR [rsp+0x20],rdi
    2bc9:	mov    QWORD PTR [r14+0x28],0x0
    2bd1:	mov    QWORD PTR [r14+0x30],0x0
    2bd9:	mov    QWORD PTR [r14+0x38],0x0
    2be1:	mov    QWORD PTR [r14],rsi
    2be4:	mov    QWORD PTR [r14+0x8],rdx
    2be8:	mov    r15,rdx
    2beb:	mov    QWORD PTR [r14+0x10],rcx
    2bef:	mov    QWORD PTR [r14+0x18],r8
    2bf3:	mov    QWORD PTR [r14+0x20],r9
    2bf7:	lea    rbx,[rsp]
    2bfb:	lea    r12,[rsp+0x10]
    2c00:	mov    r13,rsi
    2c03:	mov    QWORD PTR [rsp+0x28],rcx
    2c08:	mov    QWORD PTR [rsp+0x30],r8
    2c0d:	mov    QWORD PTR [rsp+0x38],r9
    2c12:	mov    rsi,r13
    2c15:	mov    rdi,QWORD PTR [rsp+0x20]
    2c1a:	call   2c1f <botlish_fn_19+0x97>
			2c1b: R_X86_64_PLT32	rt_str_len-0x4
    2c1f:	mov    rcx,r15
    2c22:	and    rcx,rax
    2c25:	mov    rdx,rax
    2c28:	test   rcx,0x1
    2c2f:	jne    2c57 <botlish_fn_19+0xcf>
    2c35:	mov    rsi,r15
    2c38:	mov    rdi,QWORD PTR [rsp+0x20]
    2c3d:	call   2c42 <botlish_fn_19+0xba>
			2c3e: R_X86_64_PLT32	rt_int_cmp-0x4
    2c42:	mov    ecx,0x2
    2c47:	test   rax,rax
    2c4a:	cmovge rcx,QWORD PTR [rip+0x19e]        # 2df0 <botlish_fn_19+0x268>
    2c52:	jmp    2c6a <botlish_fn_19+0xe2>
    2c57:	mov    ecx,0x2
    2c5c:	mov    rax,r15
    2c5f:	cmp    rax,rdx
    2c62:	cmovge rcx,QWORD PTR [rip+0x186]        # 2df0 <botlish_fn_19+0x268>
    2c6a:	cmp    rcx,0x6
    2c6e:	je     2d40 <botlish_fn_19+0x1b8>
    2c74:	mov    rsi,rbx
    2c77:	mov    rdi,QWORD PTR [rsp+0x20]
    2c7c:	call   2c81 <botlish_fn_19+0xf9>
			2c7d: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    2c81:	test   rax,rax
    2c84:	jne    2c94 <botlish_fn_19+0x10c>
    2c8a:	mov    rdi,QWORD PTR [rsp+0x20]
    2c8f:	jmp    2d67 <botlish_fn_19+0x1df>
    2c94:	mov    QWORD PTR [r14+0x28],rax
    2c98:	mov    rcx,rax
    2c9b:	mov    r8,QWORD PTR [rsp]
    2c9f:	mov    QWORD PTR [r14+0x30],r8
    2ca3:	mov    r9,QWORD PTR [rsp+0x8]
    2ca8:	mov    QWORD PTR [r14+0x38],r9
    2cac:	mov    rdx,r15
    2caf:	mov    rsi,r13
    2cb2:	mov    rdi,QWORD PTR [rsp+0x20]
    2cb7:	call   2cbc <botlish_fn_19+0x134>
			2cb8: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    2cbc:	test   rax,rax
    2cbf:	jne    2ccf <botlish_fn_19+0x147>
    2cc5:	mov    rdi,QWORD PTR [rsp+0x20]
    2cca:	jmp    2d67 <botlish_fn_19+0x1df>
    2ccf:	mov    QWORD PTR [r14+0x8],rax
    2cd3:	mov    r8,rax
    2cd6:	mov    QWORD PTR [r14+0x28],rdx
    2cda:	mov    r15,rdx
    2cdd:	mov    rsi,QWORD PTR [rsp+0x28]
    2ce2:	mov    rdx,QWORD PTR [rsp+0x30]
    2ce7:	mov    rcx,QWORD PTR [rsp+0x38]
    2cec:	mov    rdi,QWORD PTR [rsp+0x20]
    2cf1:	mov    r9,r12
    2cf4:	call   2cf9 <botlish_fn_19+0x171>
			2cf5: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], list>
    2cf9:	test   rax,rax
    2cfc:	jne    2d0c <botlish_fn_19+0x184>
    2d02:	mov    rdi,QWORD PTR [rsp+0x20]
    2d07:	jmp    2d67 <botlish_fn_19+0x1df>
    2d0c:	mov    rdx,QWORD PTR [rsp+0x10]
    2d11:	mov    rcx,QWORD PTR [rsp+0x18]
    2d16:	mov    QWORD PTR [r14],r13
    2d19:	mov    rsi,r15
    2d1c:	mov    QWORD PTR [r14+0x8],rsi
    2d20:	mov    QWORD PTR [r14+0x10],rax
    2d24:	mov    QWORD PTR [r14+0x18],rdx
    2d28:	mov    QWORD PTR [r14+0x20],rcx
    2d2c:	mov    QWORD PTR [rsp+0x28],rax
    2d31:	mov    QWORD PTR [rsp+0x30],rdx
    2d36:	mov    QWORD PTR [rsp+0x38],rcx
    2d3b:	jmp    2c12 <botlish_fn_19+0x8a>
    2d40:	mov    rcx,QWORD PTR [rsp+0x38]
    2d45:	mov    rdx,QWORD PTR [rsp+0x30]
    2d4a:	mov    rsi,QWORD PTR [rsp+0x28]
    2d4f:	mov    rdi,QWORD PTR [rsp+0x20]
    2d54:	call   2d59 <botlish_fn_19+0x1d1>
			2d55: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2d59:	test   rax,rax
    2d5c:	jne    2d94 <botlish_fn_19+0x20c>
    2d62:	mov    rdi,QWORD PTR [rsp+0x20]
    2d67:	mov    rdi,QWORD PTR [rsp+0x20]
    2d6c:	mov    QWORD PTR [rdi],r14
    2d6f:	xor    rax,rax
    2d72:	mov    rbx,QWORD PTR [rsp+0x40]
    2d77:	mov    r12,QWORD PTR [rsp+0x48]
    2d7c:	mov    r13,QWORD PTR [rsp+0x50]
    2d81:	mov    r14,QWORD PTR [rsp+0x58]
    2d86:	mov    r15,QWORD PTR [rsp+0x60]
    2d8b:	add    rsp,0x70
    2d8f:	mov    rsp,rbp
    2d92:	pop    rbp
    2d93:	ret
    2d94:	mov    rdi,QWORD PTR [rsp+0x20]
    2d99:	mov    QWORD PTR [rdi],r14
    2d9c:	mov    rbx,QWORD PTR [rsp+0x40]
    2da1:	mov    r12,QWORD PTR [rsp+0x48]
    2da6:	mov    r13,QWORD PTR [rsp+0x50]
    2dab:	mov    r14,QWORD PTR [rsp+0x58]
    2db0:	mov    r15,QWORD PTR [rsp+0x60]
    2db5:	add    rsp,0x70
    2db9:	mov    rsp,rbp
    2dbc:	pop    rbp
    2dbd:	ret
    2dbe:	mov    QWORD PTR [rsp+0x20],rdi
    2dc3:	call   2dc8 <botlish_fn_19+0x240>
			2dc4: R_X86_64_PLT32	rt_stack_overflow-0x4
    2dc8:	xor    rax,rax
    2dcb:	mov    rbx,QWORD PTR [rsp+0x40]
    2dd0:	mov    r12,QWORD PTR [rsp+0x48]
    2dd5:	mov    r13,QWORD PTR [rsp+0x50]
    2dda:	mov    r14,QWORD PTR [rsp+0x58]
    2ddf:	mov    r15,QWORD PTR [rsp+0x60]
    2de4:	add    rsp,0x70
    2de8:	mov    rsp,rbp
    2deb:	pop    rbp
    2dec:	ret
    2ded:	add    BYTE PTR [rax],al
    2def:	add    BYTE PTR [rsi],al
    2df1:	add    BYTE PTR [rax],al
    2df3:	add    BYTE PTR [rax],al
    2df5:	add    BYTE PTR [rax],al
	...

0000000000002df8 <botlish_entry_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    2df8:	push   rbp
    2df9:	mov    rbp,rsp
    2dfc:	mov    rsi,QWORD PTR [rdx]
    2dff:	mov    r10,QWORD PTR [rdx+0x8]
    2e03:	mov    rcx,QWORD PTR [rdx+0x10]
    2e07:	mov    r8,QWORD PTR [rdx+0x18]
    2e0b:	mov    r9,QWORD PTR [rdx+0x20]
    2e0f:	mov    rdx,r10
    2e12:	call   2e17 <botlish_entry_19+0x1f>
			2e13: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    2e17:	mov    rsp,rbp
    2e1a:	pop    rbp
    2e1b:	ret

0000000000002e1c <botlish_fn_20: csv_parse<str>>:
    2e1c:	push   rbp
    2e1d:	mov    rbp,rsp
    2e20:	sub    rsp,0x30
    2e24:	mov    QWORD PTR [rsp+0x10],rbx
    2e29:	mov    QWORD PTR [rsp+0x18],r12
    2e2e:	mov    QWORD PTR [rsp+0x20],r13
    2e33:	mov    rbx,QWORD PTR [rdi]
    2e36:	mov    rax,QWORD PTR [rdi+0x8]
    2e3a:	lea    rcx,[rbx+0x28]
    2e3e:	cmp    rcx,rax
    2e41:	ja     2f07 <botlish_fn_20+0xeb>
    2e47:	lea    rax,[rbx+0x28]
    2e4b:	mov    QWORD PTR [rdi],rax
    2e4e:	mov    r12,rdi
    2e51:	mov    QWORD PTR [rbx+0x10],0x0
    2e59:	mov    QWORD PTR [rbx+0x18],0x0
    2e61:	mov    QWORD PTR [rbx+0x20],0x0
    2e69:	mov    QWORD PTR [rbx],rsi
    2e6c:	mov    r13,rsi
    2e6f:	mov    QWORD PTR [rbx+0x8],0x1
    2e77:	lea    rsi,[rsp]
    2e7b:	mov    rdi,r12
    2e7e:	call   2e83 <botlish_fn_20+0x67>
			2e7f: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    2e83:	test   rax,rax
    2e86:	jne    2e94 <botlish_fn_20+0x78>
    2e8c:	mov    rdi,r12
    2e8f:	jmp    2ec8 <botlish_fn_20+0xac>
    2e94:	mov    QWORD PTR [rbx+0x10],rax
    2e98:	mov    rcx,rax
    2e9b:	mov    r8,QWORD PTR [rsp]
    2e9f:	mov    QWORD PTR [rbx+0x18],r8
    2ea3:	mov    r9,QWORD PTR [rsp+0x8]
    2ea8:	mov    QWORD PTR [rbx+0x20],r9
    2eac:	mov    edx,0x1
    2eb1:	mov    rsi,r13
    2eb4:	mov    rdi,r12
    2eb7:	call   2ebc <botlish_fn_20+0xa0>
			2eb8: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    2ebc:	test   rax,rax
    2ebf:	jne    2ee9 <botlish_fn_20+0xcd>
    2ec5:	mov    rdi,r12
    2ec8:	mov    rdi,r12
    2ecb:	mov    QWORD PTR [rdi],rbx
    2ece:	xor    rax,rax
    2ed1:	mov    rbx,QWORD PTR [rsp+0x10]
    2ed6:	mov    r12,QWORD PTR [rsp+0x18]
    2edb:	mov    r13,QWORD PTR [rsp+0x20]
    2ee0:	add    rsp,0x30
    2ee4:	mov    rsp,rbp
    2ee7:	pop    rbp
    2ee8:	ret
    2ee9:	mov    rdi,r12
    2eec:	mov    QWORD PTR [rdi],rbx
    2eef:	mov    rbx,QWORD PTR [rsp+0x10]
    2ef4:	mov    r12,QWORD PTR [rsp+0x18]
    2ef9:	mov    r13,QWORD PTR [rsp+0x20]
    2efe:	add    rsp,0x30
    2f02:	mov    rsp,rbp
    2f05:	pop    rbp
    2f06:	ret
    2f07:	mov    r12,rdi
    2f0a:	call   2f0f <botlish_fn_20+0xf3>
			2f0b: R_X86_64_PLT32	rt_stack_overflow-0x4
    2f0f:	xor    rax,rax
    2f12:	mov    rbx,QWORD PTR [rsp+0x10]
    2f17:	mov    r12,QWORD PTR [rsp+0x18]
    2f1c:	mov    r13,QWORD PTR [rsp+0x20]
    2f21:	add    rsp,0x30
    2f25:	mov    rsp,rbp
    2f28:	pop    rbp
    2f29:	ret

0000000000002f2a <botlish_entry_20: csv_parse<str>>:
    2f2a:	push   rbp
    2f2b:	mov    rbp,rsp
    2f2e:	mov    rsi,QWORD PTR [rdx]
    2f31:	call   2f36 <botlish_entry_20+0xc>
			2f32: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    2f36:	mov    rsp,rbp
    2f39:	pop    rbp
    2f3a:	ret

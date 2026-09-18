; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 13435  (per function: 176 85 318 750 750 750 750 840 776 747 747 501 558 698 913 482 938 975 648 724 309)
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
       8:	mov    QWORD PTR [rsp],r14
       c:	mov    QWORD PTR [rsp+0x8],r15
      11:	mov    r14,QWORD PTR [rdi]
      14:	mov    rax,QWORD PTR [rdi+0x8]
      18:	lea    rcx,[r14+0x8]
      1c:	cmp    rcx,rax
      1f:	ja     81 <botlish_fn_0+0x81>
      25:	lea    rax,[r14+0x8]
      29:	mov    QWORD PTR [rdi],rax
      2c:	mov    QWORD PTR [r14],0x0
      33:	mov    rax,QWORD PTR [rdi+0x10]
      37:	mov    r15,rdi
      3a:	mov    rsi,QWORD PTR [rax]
      3d:	mov    QWORD PTR [r14],rsi
      40:	call   45 <botlish_fn_0+0x45>
			41: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
      45:	test   rax,rax
      48:	jne    69 <botlish_fn_0+0x69>
      4e:	mov    rdi,r15
      51:	mov    QWORD PTR [rdi],r14
      54:	xor    rax,rax
      57:	mov    r14,QWORD PTR [rsp]
      5b:	mov    r15,QWORD PTR [rsp+0x8]
      60:	add    rsp,0x10
      64:	mov    rsp,rbp
      67:	pop    rbp
      68:	ret
      69:	mov    rdi,r15
      6c:	mov    QWORD PTR [rdi],r14
      6f:	mov    r14,QWORD PTR [rsp]
      73:	mov    r15,QWORD PTR [rsp+0x8]
      78:	add    rsp,0x10
      7c:	mov    rsp,rbp
      7f:	pop    rbp
      80:	ret
      81:	mov    rax,QWORD PTR [rip+0x0]        # 88 <botlish_fn_0+0x88>
			84: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
      88:	call   rax
      8a:	xor    rax,rax
      8d:	mov    r14,QWORD PTR [rsp]
      91:	mov    r15,QWORD PTR [rsp+0x8]
      96:	add    rsp,0x10
      9a:	mov    rsp,rbp
      9d:	pop    rbp
      9e:	ret

000000000000009f <botlish_entry_0: <program entry>>:
      9f:	push   rbp
      a0:	mov    rbp,rsp
      a3:	call   a8 <botlish_entry_0+0x9>
			a4: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      a8:	mov    rsp,rbp
      ab:	pop    rbp
      ac:	ret

00000000000000ad <botlish_fn_1: chunk_size<generic>>:
      ad:	push   rbp
      ae:	mov    rbp,rsp
      b1:	mov    r10,QWORD PTR [rdi]
      b4:	mov    r11,QWORD PTR [rdi+0x8]
      b8:	lea    rax,[r10+0x8]
      bc:	cmp    rax,r11
      bf:	ja     e0 <botlish_fn_1+0x33>
      c5:	lea    rax,[r10+0x8]
      c9:	mov    QWORD PTR [rdi],rax
      cc:	mov    QWORD PTR [r10],0x0
      d3:	mov    QWORD PTR [rdi],r10
      d6:	mov    eax,0x81
      db:	mov    rsp,rbp
      de:	pop    rbp
      df:	ret
      e0:	mov    rax,QWORD PTR [rip+0x0]        # e7 <botlish_fn_1+0x3a>
			e3: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
      e7:	call   rax
      e9:	xor    rax,rax
      ec:	mov    rsp,rbp
      ef:	pop    rbp
      f0:	ret

00000000000000f1 <botlish_entry_1: chunk_size<generic>>:
      f1:	push   rbp
      f2:	mov    rbp,rsp
      f5:	call   fa <botlish_entry_1+0x9>
			f6: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
      fa:	mov    rsp,rbp
      fd:	pop    rbp
      fe:	ret

00000000000000ff <botlish_fn_2: chunked_new<generic>>:
      ff:	push   rbp
     100:	mov    rbp,rsp
     103:	sub    rsp,0x20
     107:	mov    QWORD PTR [rsp],rbx
     10b:	mov    QWORD PTR [rsp+0x8],r12
     110:	mov    QWORD PTR [rsp+0x10],r13
     115:	mov    QWORD PTR [rsp+0x18],r14
     11a:	mov    r13,rsi
     11d:	mov    rbx,QWORD PTR [rdi]
     120:	mov    rax,QWORD PTR [rdi+0x8]
     124:	lea    rcx,[rbx+0x10]
     128:	cmp    rcx,rax
     12b:	ja     203 <botlish_fn_2+0x104>
     131:	lea    rax,[rbx+0x10]
     135:	mov    QWORD PTR [rdi],rax
     138:	mov    r12,rdi
     13b:	mov    QWORD PTR [rbx],0x0
     142:	mov    QWORD PTR [rbx+0x8],0x0
     14a:	xor    rdx,rdx
     14d:	mov    rax,QWORD PTR [rip+0x0]        # 154 <botlish_fn_2+0x55>
			150: R_X86_64_GOTPCREL	rt_list_new-0x4
     154:	mov    rdi,r12
     157:	mov    rsi,rdx
     15a:	call   rax
     15c:	test   rax,rax
     15f:	jne    16d <botlish_fn_2+0x6e>
     165:	mov    rdi,r12
     168:	jmp    1ab <botlish_fn_2+0xac>
     16d:	mov    QWORD PTR [rbx],rax
     170:	mov    r14,rax
     173:	mov    rdi,r12
     176:	call   17b <botlish_fn_2+0x7c>
			177: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     17b:	test   rax,rax
     17e:	jne    18c <botlish_fn_2+0x8d>
     184:	mov    rdi,r12
     187:	jmp    1ab <botlish_fn_2+0xac>
     18c:	mov    QWORD PTR [rbx+0x8],rax
     190:	mov    rsi,rax
     193:	mov    rax,QWORD PTR [rip+0x0]        # 19a <botlish_fn_2+0x9b>
			196: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
     19a:	mov    rdi,r12
     19d:	call   rax
     19f:	test   rax,rax
     1a2:	jne    1d0 <botlish_fn_2+0xd1>
     1a8:	mov    rdi,r12
     1ab:	mov    rdi,r12
     1ae:	mov    QWORD PTR [rdi],rbx
     1b1:	xor    rax,rax
     1b4:	mov    rbx,QWORD PTR [rsp]
     1b8:	mov    r12,QWORD PTR [rsp+0x8]
     1bd:	mov    r13,QWORD PTR [rsp+0x10]
     1c2:	mov    r14,QWORD PTR [rsp+0x18]
     1c7:	add    rsp,0x20
     1cb:	mov    rsp,rbp
     1ce:	pop    rbp
     1cf:	ret
     1d0:	mov    rdi,r12
     1d3:	mov    QWORD PTR [rdi],rbx
     1d6:	mov    rsi,r13
     1d9:	mov    QWORD PTR [rsi],rax
     1dc:	mov    QWORD PTR [rsi+0x8],0x1
     1e4:	mov    rax,r14
     1e7:	mov    rbx,QWORD PTR [rsp]
     1eb:	mov    r12,QWORD PTR [rsp+0x8]
     1f0:	mov    r13,QWORD PTR [rsp+0x10]
     1f5:	mov    r14,QWORD PTR [rsp+0x18]
     1fa:	add    rsp,0x20
     1fe:	mov    rsp,rbp
     201:	pop    rbp
     202:	ret
     203:	mov    r12,rdi
     206:	mov    rax,QWORD PTR [rip+0x0]        # 20d <botlish_fn_2+0x10e>
			209: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     20d:	call   rax
     20f:	xor    rax,rax
     212:	mov    rbx,QWORD PTR [rsp]
     216:	mov    r12,QWORD PTR [rsp+0x8]
     21b:	mov    r13,QWORD PTR [rsp+0x10]
     220:	mov    r14,QWORD PTR [rsp+0x18]
     225:	add    rsp,0x20
     229:	mov    rsp,rbp
     22c:	pop    rbp
     22d:	ret

000000000000022e <botlish_entry_2: chunked_new<generic>>:
     22e:	push   rbp
     22f:	mov    rbp,rsp
     232:	ud2
     234:	add    BYTE PTR [rax],al
	...

0000000000000238 <botlish_fn_3: chunked_append<list[list<never>, mutarray, int], str>>:
     238:	push   rbp
     239:	mov    rbp,rsp
     23c:	sub    rsp,0x40
     240:	mov    QWORD PTR [rsp+0x10],rbx
     245:	mov    QWORD PTR [rsp+0x18],r12
     24a:	mov    QWORD PTR [rsp+0x20],r13
     24f:	mov    QWORD PTR [rsp+0x28],r14
     254:	mov    QWORD PTR [rsp+0x30],r15
     259:	mov    r14,r9
     25c:	mov    r12,QWORD PTR [rdi]
     25f:	mov    rax,QWORD PTR [rdi+0x8]
     263:	lea    r9,[r12+0x20]
     268:	cmp    r9,rax
     26b:	ja     4d2 <botlish_fn_3+0x29a>
     271:	lea    rax,[r12+0x20]
     276:	mov    QWORD PTR [rdi],rax
     279:	mov    r13,rdi
     27c:	mov    QWORD PTR [r12],0x0
     284:	mov    QWORD PTR [r12+0x8],0x0
     28d:	mov    QWORD PTR [r12+0x10],0x0
     296:	mov    QWORD PTR [r12+0x18],0x0
     29f:	mov    QWORD PTR [r12],rsi
     2a3:	mov    r15,rsi
     2a6:	mov    QWORD PTR [r12+0x8],rdx
     2ab:	mov    QWORD PTR [rsp],rdx
     2af:	mov    QWORD PTR [r12+0x10],rcx
     2b4:	mov    rbx,rcx
     2b7:	mov    QWORD PTR [r12+0x18],r8
     2bc:	mov    QWORD PTR [rsp+0x8],r8
     2c1:	mov    rdi,r13
     2c4:	call   2c9 <botlish_fn_3+0x91>
			2c5: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     2c9:	test   rax,rax
     2cc:	jne    2da <botlish_fn_3+0xa2>
     2d2:	mov    rdi,r13
     2d5:	jmp    46e <botlish_fn_3+0x236>
     2da:	mov    rcx,rbx
     2dd:	and    rcx,rax
     2e0:	mov    rdx,rax
     2e3:	test   rcx,0x1
     2ea:	jne    314 <botlish_fn_3+0xdc>
     2f0:	mov    rax,QWORD PTR [rip+0x0]        # 2f7 <botlish_fn_3+0xbf>
			2f3: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     2f7:	mov    rsi,rbx
     2fa:	mov    rdi,r13
     2fd:	call   rax
     2ff:	mov    ecx,0x2
     304:	test   rax,rax
     307:	cmove  rcx,QWORD PTR [rip+0x1f9]        # 508 <botlish_fn_3+0x2d0>
     30f:	jmp    324 <botlish_fn_3+0xec>
     314:	mov    ecx,0x2
     319:	cmp    rbx,rdx
     31c:	cmove  rcx,QWORD PTR [rip+0x1e4]        # 508 <botlish_fn_3+0x2d0>
     324:	cmp    rcx,0x6
     328:	je     3da <botlish_fn_3+0x1a2>
     32e:	mov    r8,QWORD PTR [rip+0x0]        # 335 <botlish_fn_3+0xfd>
			331: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     335:	mov    rcx,QWORD PTR [rsp+0x8]
     33a:	mov    rdx,rbx
     33d:	mov    rsi,QWORD PTR [rsp]
     341:	mov    rdi,r13
     344:	call   r8
     347:	test   rax,rax
     34a:	jne    358 <botlish_fn_3+0x120>
     350:	mov    rdi,r13
     353:	jmp    46e <botlish_fn_3+0x236>
     358:	mov    QWORD PTR [r12+0x18],0x3
     361:	test   rbx,0x1
     368:	je     38a <botlish_fn_3+0x152>
     36e:	mov    rax,rbx
     371:	add    rax,0x2
     375:	seto   r10b
     379:	test   r10b,r10b
     37c:	jne    38a <botlish_fn_3+0x152>
     382:	mov    rdi,r13
     385:	jmp    3a1 <botlish_fn_3+0x169>
     38a:	mov    edx,0x3
     38f:	mov    rax,QWORD PTR [rip+0x0]        # 396 <botlish_fn_3+0x15e>
			392: R_X86_64_GOTPCREL	rt_int_add-0x4
     396:	mov    rsi,rbx
     399:	mov    rdi,r13
     39c:	call   rax
     39e:	mov    rdi,r13
     3a1:	mov    rdi,r13
     3a4:	mov    QWORD PTR [rdi],r12
     3a7:	mov    rdx,QWORD PTR [rsp]
     3ab:	mov    rbx,r14
     3ae:	mov    QWORD PTR [rbx],rdx
     3b1:	mov    QWORD PTR [rbx+0x8],rax
     3b5:	mov    rax,r15
     3b8:	mov    rbx,QWORD PTR [rsp+0x10]
     3bd:	mov    r12,QWORD PTR [rsp+0x18]
     3c2:	mov    r13,QWORD PTR [rsp+0x20]
     3c7:	mov    r14,QWORD PTR [rsp+0x28]
     3cc:	mov    r15,QWORD PTR [rsp+0x30]
     3d1:	add    rsp,0x40
     3d5:	mov    rsp,rbp
     3d8:	pop    rbp
     3d9:	ret
     3da:	mov    rdx,QWORD PTR [rsp]
     3de:	mov    rbx,r14
     3e1:	mov    rax,QWORD PTR [rip+0x0]        # 3e8 <botlish_fn_3+0x1b0>
			3e4: R_X86_64_GOTPCREL	rt_list_append-0x4
     3e8:	mov    rsi,r15
     3eb:	mov    rdi,r13
     3ee:	call   rax
     3f0:	test   rax,rax
     3f3:	jne    401 <botlish_fn_3+0x1c9>
     3f9:	mov    rdi,r13
     3fc:	jmp    46e <botlish_fn_3+0x236>
     401:	mov    QWORD PTR [r12],rax
     405:	mov    r14,rax
     408:	mov    rdi,r13
     40b:	call   410 <botlish_fn_3+0x1d8>
			40c: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     410:	test   rax,rax
     413:	jne    421 <botlish_fn_3+0x1e9>
     419:	mov    rdi,r13
     41c:	jmp    46e <botlish_fn_3+0x236>
     421:	mov    QWORD PTR [r12+0x8],rax
     426:	mov    rsi,rax
     429:	mov    rax,QWORD PTR [rip+0x0]        # 430 <botlish_fn_3+0x1f8>
			42c: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
     430:	mov    rdi,r13
     433:	call   rax
     435:	test   rax,rax
     438:	mov    r15,rax
     43b:	jne    449 <botlish_fn_3+0x211>
     441:	mov    rdi,r13
     444:	jmp    46e <botlish_fn_3+0x236>
     449:	mov    edx,0x1
     44e:	mov    rax,QWORD PTR [rip+0x0]        # 455 <botlish_fn_3+0x21d>
			451: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     455:	mov    rcx,QWORD PTR [rsp+0x8]
     45a:	mov    rsi,r15
     45d:	mov    rdi,r13
     460:	call   rax
     462:	test   rax,rax
     465:	jne    499 <botlish_fn_3+0x261>
     46b:	mov    rdi,r13
     46e:	mov    rdi,r13
     471:	mov    QWORD PTR [rdi],r12
     474:	xor    rax,rax
     477:	mov    rbx,QWORD PTR [rsp+0x10]
     47c:	mov    r12,QWORD PTR [rsp+0x18]
     481:	mov    r13,QWORD PTR [rsp+0x20]
     486:	mov    r14,QWORD PTR [rsp+0x28]
     48b:	mov    r15,QWORD PTR [rsp+0x30]
     490:	add    rsp,0x40
     494:	mov    rsp,rbp
     497:	pop    rbp
     498:	ret
     499:	mov    rdi,r13
     49c:	mov    QWORD PTR [rdi],r12
     49f:	mov    rax,r15
     4a2:	mov    QWORD PTR [rbx],rax
     4a5:	mov    QWORD PTR [rbx+0x8],0x3
     4ad:	mov    rax,r14
     4b0:	mov    rbx,QWORD PTR [rsp+0x10]
     4b5:	mov    r12,QWORD PTR [rsp+0x18]
     4ba:	mov    r13,QWORD PTR [rsp+0x20]
     4bf:	mov    r14,QWORD PTR [rsp+0x28]
     4c4:	mov    r15,QWORD PTR [rsp+0x30]
     4c9:	add    rsp,0x40
     4cd:	mov    rsp,rbp
     4d0:	pop    rbp
     4d1:	ret
     4d2:	mov    r13,rdi
     4d5:	mov    rax,QWORD PTR [rip+0x0]        # 4dc <botlish_fn_3+0x2a4>
			4d8: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     4dc:	call   rax
     4de:	xor    rax,rax
     4e1:	mov    rbx,QWORD PTR [rsp+0x10]
     4e6:	mov    r12,QWORD PTR [rsp+0x18]
     4eb:	mov    r13,QWORD PTR [rsp+0x20]
     4f0:	mov    r14,QWORD PTR [rsp+0x28]
     4f5:	mov    r15,QWORD PTR [rsp+0x30]
     4fa:	add    rsp,0x40
     4fe:	mov    rsp,rbp
     501:	pop    rbp
     502:	ret
     503:	add    BYTE PTR [rax],al
     505:	add    BYTE PTR [rax],al
     507:	add    BYTE PTR [rsi],al
     509:	add    BYTE PTR [rax],al
     50b:	add    BYTE PTR [rax],al
     50d:	add    BYTE PTR [rax],al
	...

0000000000000510 <botlish_entry_3: chunked_append<list[list<never>, mutarray, int], str>>:
     510:	push   rbp
     511:	mov    rbp,rsp
     514:	ud2
	...

0000000000000518 <botlish_fn_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     518:	push   rbp
     519:	mov    rbp,rsp
     51c:	sub    rsp,0x40
     520:	mov    QWORD PTR [rsp+0x10],rbx
     525:	mov    QWORD PTR [rsp+0x18],r12
     52a:	mov    QWORD PTR [rsp+0x20],r13
     52f:	mov    QWORD PTR [rsp+0x28],r14
     534:	mov    QWORD PTR [rsp+0x30],r15
     539:	mov    r14,r9
     53c:	mov    r12,QWORD PTR [rdi]
     53f:	mov    rax,QWORD PTR [rdi+0x8]
     543:	lea    r9,[r12+0x20]
     548:	cmp    r9,rax
     54b:	ja     7b2 <botlish_fn_4+0x29a>
     551:	lea    rax,[r12+0x20]
     556:	mov    QWORD PTR [rdi],rax
     559:	mov    r13,rdi
     55c:	mov    QWORD PTR [r12],0x0
     564:	mov    QWORD PTR [r12+0x8],0x0
     56d:	mov    QWORD PTR [r12+0x10],0x0
     576:	mov    QWORD PTR [r12+0x18],0x0
     57f:	mov    QWORD PTR [r12],rsi
     583:	mov    r15,rsi
     586:	mov    QWORD PTR [r12+0x8],rdx
     58b:	mov    QWORD PTR [rsp],rdx
     58f:	mov    QWORD PTR [r12+0x10],rcx
     594:	mov    rbx,rcx
     597:	mov    QWORD PTR [r12+0x18],r8
     59c:	mov    QWORD PTR [rsp+0x8],r8
     5a1:	mov    rdi,r13
     5a4:	call   5a9 <botlish_fn_4+0x91>
			5a5: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     5a9:	test   rax,rax
     5ac:	jne    5ba <botlish_fn_4+0xa2>
     5b2:	mov    rdi,r13
     5b5:	jmp    74e <botlish_fn_4+0x236>
     5ba:	mov    rcx,rbx
     5bd:	and    rcx,rax
     5c0:	mov    rdx,rax
     5c3:	test   rcx,0x1
     5ca:	jne    5f4 <botlish_fn_4+0xdc>
     5d0:	mov    rax,QWORD PTR [rip+0x0]        # 5d7 <botlish_fn_4+0xbf>
			5d3: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     5d7:	mov    rsi,rbx
     5da:	mov    rdi,r13
     5dd:	call   rax
     5df:	mov    ecx,0x2
     5e4:	test   rax,rax
     5e7:	cmove  rcx,QWORD PTR [rip+0x1f9]        # 7e8 <botlish_fn_4+0x2d0>
     5ef:	jmp    604 <botlish_fn_4+0xec>
     5f4:	mov    ecx,0x2
     5f9:	cmp    rbx,rdx
     5fc:	cmove  rcx,QWORD PTR [rip+0x1e4]        # 7e8 <botlish_fn_4+0x2d0>
     604:	cmp    rcx,0x6
     608:	je     6ba <botlish_fn_4+0x1a2>
     60e:	mov    r8,QWORD PTR [rip+0x0]        # 615 <botlish_fn_4+0xfd>
			611: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     615:	mov    rcx,QWORD PTR [rsp+0x8]
     61a:	mov    rdx,rbx
     61d:	mov    rsi,QWORD PTR [rsp]
     621:	mov    rdi,r13
     624:	call   r8
     627:	test   rax,rax
     62a:	jne    638 <botlish_fn_4+0x120>
     630:	mov    rdi,r13
     633:	jmp    74e <botlish_fn_4+0x236>
     638:	mov    QWORD PTR [r12+0x18],0x3
     641:	test   rbx,0x1
     648:	je     66a <botlish_fn_4+0x152>
     64e:	mov    rax,rbx
     651:	add    rax,0x2
     655:	seto   r10b
     659:	test   r10b,r10b
     65c:	jne    66a <botlish_fn_4+0x152>
     662:	mov    rdi,r13
     665:	jmp    681 <botlish_fn_4+0x169>
     66a:	mov    edx,0x3
     66f:	mov    rax,QWORD PTR [rip+0x0]        # 676 <botlish_fn_4+0x15e>
			672: R_X86_64_GOTPCREL	rt_int_add-0x4
     676:	mov    rsi,rbx
     679:	mov    rdi,r13
     67c:	call   rax
     67e:	mov    rdi,r13
     681:	mov    rdi,r13
     684:	mov    QWORD PTR [rdi],r12
     687:	mov    rdx,QWORD PTR [rsp]
     68b:	mov    rbx,r14
     68e:	mov    QWORD PTR [rbx],rdx
     691:	mov    QWORD PTR [rbx+0x8],rax
     695:	mov    rax,r15
     698:	mov    rbx,QWORD PTR [rsp+0x10]
     69d:	mov    r12,QWORD PTR [rsp+0x18]
     6a2:	mov    r13,QWORD PTR [rsp+0x20]
     6a7:	mov    r14,QWORD PTR [rsp+0x28]
     6ac:	mov    r15,QWORD PTR [rsp+0x30]
     6b1:	add    rsp,0x40
     6b5:	mov    rsp,rbp
     6b8:	pop    rbp
     6b9:	ret
     6ba:	mov    rdx,QWORD PTR [rsp]
     6be:	mov    rbx,r14
     6c1:	mov    rax,QWORD PTR [rip+0x0]        # 6c8 <botlish_fn_4+0x1b0>
			6c4: R_X86_64_GOTPCREL	rt_list_append-0x4
     6c8:	mov    rsi,r15
     6cb:	mov    rdi,r13
     6ce:	call   rax
     6d0:	test   rax,rax
     6d3:	jne    6e1 <botlish_fn_4+0x1c9>
     6d9:	mov    rdi,r13
     6dc:	jmp    74e <botlish_fn_4+0x236>
     6e1:	mov    QWORD PTR [r12],rax
     6e5:	mov    r14,rax
     6e8:	mov    rdi,r13
     6eb:	call   6f0 <botlish_fn_4+0x1d8>
			6ec: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     6f0:	test   rax,rax
     6f3:	jne    701 <botlish_fn_4+0x1e9>
     6f9:	mov    rdi,r13
     6fc:	jmp    74e <botlish_fn_4+0x236>
     701:	mov    QWORD PTR [r12+0x8],rax
     706:	mov    rsi,rax
     709:	mov    rax,QWORD PTR [rip+0x0]        # 710 <botlish_fn_4+0x1f8>
			70c: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
     710:	mov    rdi,r13
     713:	call   rax
     715:	test   rax,rax
     718:	mov    r15,rax
     71b:	jne    729 <botlish_fn_4+0x211>
     721:	mov    rdi,r13
     724:	jmp    74e <botlish_fn_4+0x236>
     729:	mov    edx,0x1
     72e:	mov    rax,QWORD PTR [rip+0x0]        # 735 <botlish_fn_4+0x21d>
			731: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     735:	mov    rcx,QWORD PTR [rsp+0x8]
     73a:	mov    rsi,r15
     73d:	mov    rdi,r13
     740:	call   rax
     742:	test   rax,rax
     745:	jne    779 <botlish_fn_4+0x261>
     74b:	mov    rdi,r13
     74e:	mov    rdi,r13
     751:	mov    QWORD PTR [rdi],r12
     754:	xor    rax,rax
     757:	mov    rbx,QWORD PTR [rsp+0x10]
     75c:	mov    r12,QWORD PTR [rsp+0x18]
     761:	mov    r13,QWORD PTR [rsp+0x20]
     766:	mov    r14,QWORD PTR [rsp+0x28]
     76b:	mov    r15,QWORD PTR [rsp+0x30]
     770:	add    rsp,0x40
     774:	mov    rsp,rbp
     777:	pop    rbp
     778:	ret
     779:	mov    rdi,r13
     77c:	mov    QWORD PTR [rdi],r12
     77f:	mov    rax,r15
     782:	mov    QWORD PTR [rbx],rax
     785:	mov    QWORD PTR [rbx+0x8],0x3
     78d:	mov    rax,r14
     790:	mov    rbx,QWORD PTR [rsp+0x10]
     795:	mov    r12,QWORD PTR [rsp+0x18]
     79a:	mov    r13,QWORD PTR [rsp+0x20]
     79f:	mov    r14,QWORD PTR [rsp+0x28]
     7a4:	mov    r15,QWORD PTR [rsp+0x30]
     7a9:	add    rsp,0x40
     7ad:	mov    rsp,rbp
     7b0:	pop    rbp
     7b1:	ret
     7b2:	mov    r13,rdi
     7b5:	mov    rax,QWORD PTR [rip+0x0]        # 7bc <botlish_fn_4+0x2a4>
			7b8: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     7bc:	call   rax
     7be:	xor    rax,rax
     7c1:	mov    rbx,QWORD PTR [rsp+0x10]
     7c6:	mov    r12,QWORD PTR [rsp+0x18]
     7cb:	mov    r13,QWORD PTR [rsp+0x20]
     7d0:	mov    r14,QWORD PTR [rsp+0x28]
     7d5:	mov    r15,QWORD PTR [rsp+0x30]
     7da:	add    rsp,0x40
     7de:	mov    rsp,rbp
     7e1:	pop    rbp
     7e2:	ret
     7e3:	add    BYTE PTR [rax],al
     7e5:	add    BYTE PTR [rax],al
     7e7:	add    BYTE PTR [rsi],al
     7e9:	add    BYTE PTR [rax],al
     7eb:	add    BYTE PTR [rax],al
     7ed:	add    BYTE PTR [rax],al
	...

00000000000007f0 <botlish_entry_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     7f0:	push   rbp
     7f1:	mov    rbp,rsp
     7f4:	ud2
	...

00000000000007f8 <botlish_fn_5: chunked_append<list[list<never>, mutarray, int], list>>:
     7f8:	push   rbp
     7f9:	mov    rbp,rsp
     7fc:	sub    rsp,0x40
     800:	mov    QWORD PTR [rsp+0x10],rbx
     805:	mov    QWORD PTR [rsp+0x18],r12
     80a:	mov    QWORD PTR [rsp+0x20],r13
     80f:	mov    QWORD PTR [rsp+0x28],r14
     814:	mov    QWORD PTR [rsp+0x30],r15
     819:	mov    r14,r9
     81c:	mov    r12,QWORD PTR [rdi]
     81f:	mov    rax,QWORD PTR [rdi+0x8]
     823:	lea    r9,[r12+0x20]
     828:	cmp    r9,rax
     82b:	ja     a92 <botlish_fn_5+0x29a>
     831:	lea    rax,[r12+0x20]
     836:	mov    QWORD PTR [rdi],rax
     839:	mov    r13,rdi
     83c:	mov    QWORD PTR [r12],0x0
     844:	mov    QWORD PTR [r12+0x8],0x0
     84d:	mov    QWORD PTR [r12+0x10],0x0
     856:	mov    QWORD PTR [r12+0x18],0x0
     85f:	mov    QWORD PTR [r12],rsi
     863:	mov    r15,rsi
     866:	mov    QWORD PTR [r12+0x8],rdx
     86b:	mov    QWORD PTR [rsp],rdx
     86f:	mov    QWORD PTR [r12+0x10],rcx
     874:	mov    rbx,rcx
     877:	mov    QWORD PTR [r12+0x18],r8
     87c:	mov    QWORD PTR [rsp+0x8],r8
     881:	mov    rdi,r13
     884:	call   889 <botlish_fn_5+0x91>
			885: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     889:	test   rax,rax
     88c:	jne    89a <botlish_fn_5+0xa2>
     892:	mov    rdi,r13
     895:	jmp    a2e <botlish_fn_5+0x236>
     89a:	mov    rcx,rbx
     89d:	and    rcx,rax
     8a0:	mov    rdx,rax
     8a3:	test   rcx,0x1
     8aa:	jne    8d4 <botlish_fn_5+0xdc>
     8b0:	mov    rax,QWORD PTR [rip+0x0]        # 8b7 <botlish_fn_5+0xbf>
			8b3: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     8b7:	mov    rsi,rbx
     8ba:	mov    rdi,r13
     8bd:	call   rax
     8bf:	mov    ecx,0x2
     8c4:	test   rax,rax
     8c7:	cmove  rcx,QWORD PTR [rip+0x1f9]        # ac8 <botlish_fn_5+0x2d0>
     8cf:	jmp    8e4 <botlish_fn_5+0xec>
     8d4:	mov    ecx,0x2
     8d9:	cmp    rbx,rdx
     8dc:	cmove  rcx,QWORD PTR [rip+0x1e4]        # ac8 <botlish_fn_5+0x2d0>
     8e4:	cmp    rcx,0x6
     8e8:	je     99a <botlish_fn_5+0x1a2>
     8ee:	mov    r8,QWORD PTR [rip+0x0]        # 8f5 <botlish_fn_5+0xfd>
			8f1: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     8f5:	mov    rcx,QWORD PTR [rsp+0x8]
     8fa:	mov    rdx,rbx
     8fd:	mov    rsi,QWORD PTR [rsp]
     901:	mov    rdi,r13
     904:	call   r8
     907:	test   rax,rax
     90a:	jne    918 <botlish_fn_5+0x120>
     910:	mov    rdi,r13
     913:	jmp    a2e <botlish_fn_5+0x236>
     918:	mov    QWORD PTR [r12+0x18],0x3
     921:	test   rbx,0x1
     928:	je     94a <botlish_fn_5+0x152>
     92e:	mov    rax,rbx
     931:	add    rax,0x2
     935:	seto   r10b
     939:	test   r10b,r10b
     93c:	jne    94a <botlish_fn_5+0x152>
     942:	mov    rdi,r13
     945:	jmp    961 <botlish_fn_5+0x169>
     94a:	mov    edx,0x3
     94f:	mov    rax,QWORD PTR [rip+0x0]        # 956 <botlish_fn_5+0x15e>
			952: R_X86_64_GOTPCREL	rt_int_add-0x4
     956:	mov    rsi,rbx
     959:	mov    rdi,r13
     95c:	call   rax
     95e:	mov    rdi,r13
     961:	mov    rdi,r13
     964:	mov    QWORD PTR [rdi],r12
     967:	mov    rdx,QWORD PTR [rsp]
     96b:	mov    rbx,r14
     96e:	mov    QWORD PTR [rbx],rdx
     971:	mov    QWORD PTR [rbx+0x8],rax
     975:	mov    rax,r15
     978:	mov    rbx,QWORD PTR [rsp+0x10]
     97d:	mov    r12,QWORD PTR [rsp+0x18]
     982:	mov    r13,QWORD PTR [rsp+0x20]
     987:	mov    r14,QWORD PTR [rsp+0x28]
     98c:	mov    r15,QWORD PTR [rsp+0x30]
     991:	add    rsp,0x40
     995:	mov    rsp,rbp
     998:	pop    rbp
     999:	ret
     99a:	mov    rdx,QWORD PTR [rsp]
     99e:	mov    rbx,r14
     9a1:	mov    rax,QWORD PTR [rip+0x0]        # 9a8 <botlish_fn_5+0x1b0>
			9a4: R_X86_64_GOTPCREL	rt_list_append-0x4
     9a8:	mov    rsi,r15
     9ab:	mov    rdi,r13
     9ae:	call   rax
     9b0:	test   rax,rax
     9b3:	jne    9c1 <botlish_fn_5+0x1c9>
     9b9:	mov    rdi,r13
     9bc:	jmp    a2e <botlish_fn_5+0x236>
     9c1:	mov    QWORD PTR [r12],rax
     9c5:	mov    r14,rax
     9c8:	mov    rdi,r13
     9cb:	call   9d0 <botlish_fn_5+0x1d8>
			9cc: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     9d0:	test   rax,rax
     9d3:	jne    9e1 <botlish_fn_5+0x1e9>
     9d9:	mov    rdi,r13
     9dc:	jmp    a2e <botlish_fn_5+0x236>
     9e1:	mov    QWORD PTR [r12+0x8],rax
     9e6:	mov    rsi,rax
     9e9:	mov    rax,QWORD PTR [rip+0x0]        # 9f0 <botlish_fn_5+0x1f8>
			9ec: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
     9f0:	mov    rdi,r13
     9f3:	call   rax
     9f5:	test   rax,rax
     9f8:	mov    r15,rax
     9fb:	jne    a09 <botlish_fn_5+0x211>
     a01:	mov    rdi,r13
     a04:	jmp    a2e <botlish_fn_5+0x236>
     a09:	mov    edx,0x1
     a0e:	mov    rax,QWORD PTR [rip+0x0]        # a15 <botlish_fn_5+0x21d>
			a11: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     a15:	mov    rcx,QWORD PTR [rsp+0x8]
     a1a:	mov    rsi,r15
     a1d:	mov    rdi,r13
     a20:	call   rax
     a22:	test   rax,rax
     a25:	jne    a59 <botlish_fn_5+0x261>
     a2b:	mov    rdi,r13
     a2e:	mov    rdi,r13
     a31:	mov    QWORD PTR [rdi],r12
     a34:	xor    rax,rax
     a37:	mov    rbx,QWORD PTR [rsp+0x10]
     a3c:	mov    r12,QWORD PTR [rsp+0x18]
     a41:	mov    r13,QWORD PTR [rsp+0x20]
     a46:	mov    r14,QWORD PTR [rsp+0x28]
     a4b:	mov    r15,QWORD PTR [rsp+0x30]
     a50:	add    rsp,0x40
     a54:	mov    rsp,rbp
     a57:	pop    rbp
     a58:	ret
     a59:	mov    rdi,r13
     a5c:	mov    QWORD PTR [rdi],r12
     a5f:	mov    rax,r15
     a62:	mov    QWORD PTR [rbx],rax
     a65:	mov    QWORD PTR [rbx+0x8],0x3
     a6d:	mov    rax,r14
     a70:	mov    rbx,QWORD PTR [rsp+0x10]
     a75:	mov    r12,QWORD PTR [rsp+0x18]
     a7a:	mov    r13,QWORD PTR [rsp+0x20]
     a7f:	mov    r14,QWORD PTR [rsp+0x28]
     a84:	mov    r15,QWORD PTR [rsp+0x30]
     a89:	add    rsp,0x40
     a8d:	mov    rsp,rbp
     a90:	pop    rbp
     a91:	ret
     a92:	mov    r13,rdi
     a95:	mov    rax,QWORD PTR [rip+0x0]        # a9c <botlish_fn_5+0x2a4>
			a98: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     a9c:	call   rax
     a9e:	xor    rax,rax
     aa1:	mov    rbx,QWORD PTR [rsp+0x10]
     aa6:	mov    r12,QWORD PTR [rsp+0x18]
     aab:	mov    r13,QWORD PTR [rsp+0x20]
     ab0:	mov    r14,QWORD PTR [rsp+0x28]
     ab5:	mov    r15,QWORD PTR [rsp+0x30]
     aba:	add    rsp,0x40
     abe:	mov    rsp,rbp
     ac1:	pop    rbp
     ac2:	ret
     ac3:	add    BYTE PTR [rax],al
     ac5:	add    BYTE PTR [rax],al
     ac7:	add    BYTE PTR [rsi],al
     ac9:	add    BYTE PTR [rax],al
     acb:	add    BYTE PTR [rax],al
     acd:	add    BYTE PTR [rax],al
	...

0000000000000ad0 <botlish_entry_5: chunked_append<list[list<never>, mutarray, int], list>>:
     ad0:	push   rbp
     ad1:	mov    rbp,rsp
     ad4:	ud2
	...

0000000000000ad8 <botlish_fn_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     ad8:	push   rbp
     ad9:	mov    rbp,rsp
     adc:	sub    rsp,0x40
     ae0:	mov    QWORD PTR [rsp+0x10],rbx
     ae5:	mov    QWORD PTR [rsp+0x18],r12
     aea:	mov    QWORD PTR [rsp+0x20],r13
     aef:	mov    QWORD PTR [rsp+0x28],r14
     af4:	mov    QWORD PTR [rsp+0x30],r15
     af9:	mov    r14,r9
     afc:	mov    r12,QWORD PTR [rdi]
     aff:	mov    rax,QWORD PTR [rdi+0x8]
     b03:	lea    r9,[r12+0x20]
     b08:	cmp    r9,rax
     b0b:	ja     d72 <botlish_fn_6+0x29a>
     b11:	lea    rax,[r12+0x20]
     b16:	mov    QWORD PTR [rdi],rax
     b19:	mov    r13,rdi
     b1c:	mov    QWORD PTR [r12],0x0
     b24:	mov    QWORD PTR [r12+0x8],0x0
     b2d:	mov    QWORD PTR [r12+0x10],0x0
     b36:	mov    QWORD PTR [r12+0x18],0x0
     b3f:	mov    QWORD PTR [r12],rsi
     b43:	mov    r15,rsi
     b46:	mov    QWORD PTR [r12+0x8],rdx
     b4b:	mov    QWORD PTR [rsp],rdx
     b4f:	mov    QWORD PTR [r12+0x10],rcx
     b54:	mov    rbx,rcx
     b57:	mov    QWORD PTR [r12+0x18],r8
     b5c:	mov    QWORD PTR [rsp+0x8],r8
     b61:	mov    rdi,r13
     b64:	call   b69 <botlish_fn_6+0x91>
			b65: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     b69:	test   rax,rax
     b6c:	jne    b7a <botlish_fn_6+0xa2>
     b72:	mov    rdi,r13
     b75:	jmp    d0e <botlish_fn_6+0x236>
     b7a:	mov    rcx,rbx
     b7d:	and    rcx,rax
     b80:	mov    rdx,rax
     b83:	test   rcx,0x1
     b8a:	jne    bb4 <botlish_fn_6+0xdc>
     b90:	mov    rax,QWORD PTR [rip+0x0]        # b97 <botlish_fn_6+0xbf>
			b93: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     b97:	mov    rsi,rbx
     b9a:	mov    rdi,r13
     b9d:	call   rax
     b9f:	mov    ecx,0x2
     ba4:	test   rax,rax
     ba7:	cmove  rcx,QWORD PTR [rip+0x1f9]        # da8 <botlish_fn_6+0x2d0>
     baf:	jmp    bc4 <botlish_fn_6+0xec>
     bb4:	mov    ecx,0x2
     bb9:	cmp    rbx,rdx
     bbc:	cmove  rcx,QWORD PTR [rip+0x1e4]        # da8 <botlish_fn_6+0x2d0>
     bc4:	cmp    rcx,0x6
     bc8:	je     c7a <botlish_fn_6+0x1a2>
     bce:	mov    r8,QWORD PTR [rip+0x0]        # bd5 <botlish_fn_6+0xfd>
			bd1: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     bd5:	mov    rcx,QWORD PTR [rsp+0x8]
     bda:	mov    rdx,rbx
     bdd:	mov    rsi,QWORD PTR [rsp]
     be1:	mov    rdi,r13
     be4:	call   r8
     be7:	test   rax,rax
     bea:	jne    bf8 <botlish_fn_6+0x120>
     bf0:	mov    rdi,r13
     bf3:	jmp    d0e <botlish_fn_6+0x236>
     bf8:	mov    QWORD PTR [r12+0x18],0x3
     c01:	test   rbx,0x1
     c08:	je     c2a <botlish_fn_6+0x152>
     c0e:	mov    rax,rbx
     c11:	add    rax,0x2
     c15:	seto   r10b
     c19:	test   r10b,r10b
     c1c:	jne    c2a <botlish_fn_6+0x152>
     c22:	mov    rdi,r13
     c25:	jmp    c41 <botlish_fn_6+0x169>
     c2a:	mov    edx,0x3
     c2f:	mov    rax,QWORD PTR [rip+0x0]        # c36 <botlish_fn_6+0x15e>
			c32: R_X86_64_GOTPCREL	rt_int_add-0x4
     c36:	mov    rsi,rbx
     c39:	mov    rdi,r13
     c3c:	call   rax
     c3e:	mov    rdi,r13
     c41:	mov    rdi,r13
     c44:	mov    QWORD PTR [rdi],r12
     c47:	mov    rdx,QWORD PTR [rsp]
     c4b:	mov    rbx,r14
     c4e:	mov    QWORD PTR [rbx],rdx
     c51:	mov    QWORD PTR [rbx+0x8],rax
     c55:	mov    rax,r15
     c58:	mov    rbx,QWORD PTR [rsp+0x10]
     c5d:	mov    r12,QWORD PTR [rsp+0x18]
     c62:	mov    r13,QWORD PTR [rsp+0x20]
     c67:	mov    r14,QWORD PTR [rsp+0x28]
     c6c:	mov    r15,QWORD PTR [rsp+0x30]
     c71:	add    rsp,0x40
     c75:	mov    rsp,rbp
     c78:	pop    rbp
     c79:	ret
     c7a:	mov    rdx,QWORD PTR [rsp]
     c7e:	mov    rbx,r14
     c81:	mov    rax,QWORD PTR [rip+0x0]        # c88 <botlish_fn_6+0x1b0>
			c84: R_X86_64_GOTPCREL	rt_list_append-0x4
     c88:	mov    rsi,r15
     c8b:	mov    rdi,r13
     c8e:	call   rax
     c90:	test   rax,rax
     c93:	jne    ca1 <botlish_fn_6+0x1c9>
     c99:	mov    rdi,r13
     c9c:	jmp    d0e <botlish_fn_6+0x236>
     ca1:	mov    QWORD PTR [r12],rax
     ca5:	mov    r14,rax
     ca8:	mov    rdi,r13
     cab:	call   cb0 <botlish_fn_6+0x1d8>
			cac: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     cb0:	test   rax,rax
     cb3:	jne    cc1 <botlish_fn_6+0x1e9>
     cb9:	mov    rdi,r13
     cbc:	jmp    d0e <botlish_fn_6+0x236>
     cc1:	mov    QWORD PTR [r12+0x8],rax
     cc6:	mov    rsi,rax
     cc9:	mov    rax,QWORD PTR [rip+0x0]        # cd0 <botlish_fn_6+0x1f8>
			ccc: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
     cd0:	mov    rdi,r13
     cd3:	call   rax
     cd5:	test   rax,rax
     cd8:	mov    r15,rax
     cdb:	jne    ce9 <botlish_fn_6+0x211>
     ce1:	mov    rdi,r13
     ce4:	jmp    d0e <botlish_fn_6+0x236>
     ce9:	mov    edx,0x1
     cee:	mov    rax,QWORD PTR [rip+0x0]        # cf5 <botlish_fn_6+0x21d>
			cf1: R_X86_64_GOTPCREL	rt_mutarray_set-0x4
     cf5:	mov    rcx,QWORD PTR [rsp+0x8]
     cfa:	mov    rsi,r15
     cfd:	mov    rdi,r13
     d00:	call   rax
     d02:	test   rax,rax
     d05:	jne    d39 <botlish_fn_6+0x261>
     d0b:	mov    rdi,r13
     d0e:	mov    rdi,r13
     d11:	mov    QWORD PTR [rdi],r12
     d14:	xor    rax,rax
     d17:	mov    rbx,QWORD PTR [rsp+0x10]
     d1c:	mov    r12,QWORD PTR [rsp+0x18]
     d21:	mov    r13,QWORD PTR [rsp+0x20]
     d26:	mov    r14,QWORD PTR [rsp+0x28]
     d2b:	mov    r15,QWORD PTR [rsp+0x30]
     d30:	add    rsp,0x40
     d34:	mov    rsp,rbp
     d37:	pop    rbp
     d38:	ret
     d39:	mov    rdi,r13
     d3c:	mov    QWORD PTR [rdi],r12
     d3f:	mov    rax,r15
     d42:	mov    QWORD PTR [rbx],rax
     d45:	mov    QWORD PTR [rbx+0x8],0x3
     d4d:	mov    rax,r14
     d50:	mov    rbx,QWORD PTR [rsp+0x10]
     d55:	mov    r12,QWORD PTR [rsp+0x18]
     d5a:	mov    r13,QWORD PTR [rsp+0x20]
     d5f:	mov    r14,QWORD PTR [rsp+0x28]
     d64:	mov    r15,QWORD PTR [rsp+0x30]
     d69:	add    rsp,0x40
     d6d:	mov    rsp,rbp
     d70:	pop    rbp
     d71:	ret
     d72:	mov    r13,rdi
     d75:	mov    rax,QWORD PTR [rip+0x0]        # d7c <botlish_fn_6+0x2a4>
			d78: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
     d7c:	call   rax
     d7e:	xor    rax,rax
     d81:	mov    rbx,QWORD PTR [rsp+0x10]
     d86:	mov    r12,QWORD PTR [rsp+0x18]
     d8b:	mov    r13,QWORD PTR [rsp+0x20]
     d90:	mov    r14,QWORD PTR [rsp+0x28]
     d95:	mov    r15,QWORD PTR [rsp+0x30]
     d9a:	add    rsp,0x40
     d9e:	mov    rsp,rbp
     da1:	pop    rbp
     da2:	ret
     da3:	add    BYTE PTR [rax],al
     da5:	add    BYTE PTR [rax],al
     da7:	add    BYTE PTR [rsi],al
     da9:	add    BYTE PTR [rax],al
     dab:	add    BYTE PTR [rax],al
     dad:	add    BYTE PTR [rax],al
	...

0000000000000db0 <botlish_entry_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     db0:	push   rbp
     db1:	mov    rbp,rsp
     db4:	ud2
	...

0000000000000db8 <botlish_fn_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
     db8:	push   rbp
     db9:	mov    rbp,rsp
     dbc:	sub    rsp,0x40
     dc0:	mov    QWORD PTR [rsp+0x10],rbx
     dc5:	mov    QWORD PTR [rsp+0x18],r12
     dca:	mov    QWORD PTR [rsp+0x20],r13
     dcf:	mov    QWORD PTR [rsp+0x28],r14
     dd4:	mov    QWORD PTR [rsp+0x30],r15
     dd9:	mov    r14,QWORD PTR [rdi]
     ddc:	mov    rax,QWORD PTR [rdi+0x8]
     de0:	lea    r9,[r14+0x30]
     de4:	cmp    r9,rax
     de7:	ja     108c <botlish_fn_7+0x2d4>
     ded:	lea    rax,[r14+0x30]
     df1:	mov    QWORD PTR [rdi],rax
     df4:	mov    r15,rdi
     df7:	mov    QWORD PTR [r14],0x0
     dfe:	mov    QWORD PTR [r14+0x8],0x0
     e06:	mov    QWORD PTR [r14+0x10],0x0
     e0e:	mov    QWORD PTR [r14+0x18],0x0
     e16:	mov    QWORD PTR [r14+0x20],0x0
     e1e:	mov    QWORD PTR [r14+0x28],0x0
     e26:	mov    QWORD PTR [r14],rsi
     e29:	mov    QWORD PTR [r14+0x8],rdx
     e2d:	mov    r12,rdx
     e30:	mov    QWORD PTR [r14+0x10],rcx
     e34:	mov    r13,rcx
     e37:	mov    QWORD PTR [r14+0x18],r8
     e3b:	mov    QWORD PTR [rsp],r8
     e3f:	mov    r11,QWORD PTR [rip+0x0]        # e46 <botlish_fn_7+0x8e>
			e42: R_X86_64_GOTPCREL	rt_list_len-0x4
     e46:	mov    rbx,rsi
     e49:	mov    rdi,r15
     e4c:	call   r11
     e4f:	mov    r11,r12
     e52:	and    r11,rax
     e55:	mov    rdx,rax
     e58:	test   r11,0x1
     e5f:	jne    e89 <botlish_fn_7+0xd1>
     e65:	mov    rax,QWORD PTR [rip+0x0]        # e6c <botlish_fn_7+0xb4>
			e68: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     e6c:	mov    rsi,r12
     e6f:	mov    rdi,r15
     e72:	call   rax
     e74:	mov    ecx,0x2
     e79:	test   rax,rax
     e7c:	cmovge rcx,QWORD PTR [rip+0x23c]        # 10c0 <botlish_fn_7+0x308>
     e84:	jmp    e99 <botlish_fn_7+0xe1>
     e89:	mov    ecx,0x2
     e8e:	cmp    r12,rdx
     e91:	cmovge rcx,QWORD PTR [rip+0x227]        # 10c0 <botlish_fn_7+0x308>
     e99:	cmp    rcx,0x6
     e9d:	je     1060 <botlish_fn_7+0x2a8>
     ea3:	test   r12,0x1
     eaa:	je     ec3 <botlish_fn_7+0x10b>
     eb0:	mov    rcx,QWORD PTR [rbx+0x8]
     eb4:	mov    rax,r12
     eb7:	sar    rax,1
     eba:	cmp    rax,rcx
     ebd:	jb     eee <botlish_fn_7+0x136>
     ec3:	mov    rax,QWORD PTR [rip+0x0]        # eca <botlish_fn_7+0x112>
			ec6: R_X86_64_GOTPCREL	rt_list_get-0x4
     eca:	mov    rdx,r12
     ecd:	mov    rsi,rbx
     ed0:	mov    rdi,r15
     ed3:	call   rax
     ed5:	test   rax,rax
     ed8:	jne    ee6 <botlish_fn_7+0x12e>
     ede:	mov    rdi,r15
     ee1:	jmp    fcb <botlish_fn_7+0x213>
     ee6:	mov    rsi,rax
     ee9:	jmp    ef9 <botlish_fn_7+0x141>
     eee:	mov    rcx,QWORD PTR [rbx+0x10]
     ef2:	mov    rax,QWORD PTR [rcx+rax*8]
     ef6:	mov    rsi,rax
     ef9:	mov    QWORD PTR [r14+0x20],rsi
     efd:	mov    QWORD PTR [rsp+0x8],rsi
     f02:	mov    QWORD PTR [r14+0x28],0x1
     f0a:	mov    rdi,r15
     f0d:	call   f12 <botlish_fn_7+0x15a>
			f0e: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     f12:	test   rax,rax
     f15:	mov    r9,rax
     f18:	jne    f26 <botlish_fn_7+0x16e>
     f1e:	mov    rdi,r15
     f21:	jmp    fcb <botlish_fn_7+0x213>
     f26:	xor    edi,edi
     f28:	mov    rsi,QWORD PTR [rsp+0x8]
     f2d:	test   rsi,0x7
     f34:	jne    f44 <botlish_fn_7+0x18c>
     f3a:	movzx  rax,BYTE PTR [rsi]
     f3e:	cmp    al,0x8
     f40:	sete   dil
     f44:	test   dil,dil
     f47:	jne    f6e <botlish_fn_7+0x1b6>
     f4d:	mov    rdi,r15
     f50:	mov    rax,QWORD PTR [rdi+0x10]
     f54:	mov    rcx,QWORD PTR [rax+0x8]
     f58:	mov    edx,0x8
     f5d:	mov    rax,QWORD PTR [rip+0x0]        # f64 <botlish_fn_7+0x1ac>
			f60: R_X86_64_GOTPCREL	rt_type_error-0x4
     f64:	call   rax
     f66:	mov    rdi,r15
     f69:	jmp    fcb <botlish_fn_7+0x213>
     f6e:	mov    QWORD PTR [rsp+0x8],rsi
     f73:	mov    r8d,0x1
     f79:	mov    rax,QWORD PTR [rip+0x0]        # f80 <botlish_fn_7+0x1c8>
			f7c: R_X86_64_GOTPCREL	rt_mutarray_copy-0x4
     f80:	mov    rcx,QWORD PTR [rsp+0x8]
     f85:	mov    rdx,QWORD PTR [rsp]
     f89:	mov    rsi,r13
     f8c:	mov    rdi,r15
     f8f:	call   rax
     f91:	test   rax,rax
     f94:	jne    fa2 <botlish_fn_7+0x1ea>
     f9a:	mov    rdi,r15
     f9d:	jmp    fcb <botlish_fn_7+0x213>
     fa2:	sar    r12,1
     fa5:	add    r12,0x1
     fac:	shl    r12,1
     faf:	or     r12,0x1
     fb3:	mov    QWORD PTR [r14+0x8],r12
     fb7:	mov    rdi,r15
     fba:	call   fbf <botlish_fn_7+0x207>
			fbb: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     fbf:	test   rax,rax
     fc2:	jne    ff6 <botlish_fn_7+0x23e>
     fc8:	mov    rdi,r15
     fcb:	mov    rdi,r15
     fce:	mov    QWORD PTR [rdi],r14
     fd1:	xor    rax,rax
     fd4:	mov    rbx,QWORD PTR [rsp+0x10]
     fd9:	mov    r12,QWORD PTR [rsp+0x18]
     fde:	mov    r13,QWORD PTR [rsp+0x20]
     fe3:	mov    r14,QWORD PTR [rsp+0x28]
     fe8:	mov    r15,QWORD PTR [rsp+0x30]
     fed:	add    rsp,0x40
     ff1:	mov    rsp,rbp
     ff4:	pop    rbp
     ff5:	ret
     ff6:	mov    QWORD PTR [r14+0x20],rax
     ffa:	mov    rsi,QWORD PTR [rsp]
     ffe:	mov    rcx,rsi
    1001:	and    rcx,rax
    1004:	test   rcx,0x1
    100b:	jne    1019 <botlish_fn_7+0x261>
    1011:	mov    rdx,rax
    1014:	jmp    1035 <botlish_fn_7+0x27d>
    1019:	lea    rcx,[rax-0x1]
    101d:	mov    rdx,rax
    1020:	mov    rsi,QWORD PTR [rsp]
    1024:	mov    rax,rsi
    1027:	add    rax,rcx
    102a:	seto   cl
    102d:	test   cl,cl
    102f:	je     1045 <botlish_fn_7+0x28d>
    1035:	mov    rax,QWORD PTR [rip+0x0]        # 103c <botlish_fn_7+0x284>
			1038: R_X86_64_GOTPCREL	rt_int_add-0x4
    103c:	mov    rsi,QWORD PTR [rsp]
    1040:	mov    rdi,r15
    1043:	call   rax
    1045:	mov    QWORD PTR [r14],rbx
    1048:	mov    QWORD PTR [r14+0x8],r12
    104c:	mov    QWORD PTR [r14+0x10],r13
    1050:	mov    QWORD PTR [r14+0x18],rax
    1054:	mov    rsi,rbx
    1057:	mov    QWORD PTR [rsp],rax
    105b:	jmp    e3f <botlish_fn_7+0x87>
    1060:	mov    rdi,r15
    1063:	mov    QWORD PTR [rdi],r14
    1066:	mov    rax,QWORD PTR [rsp]
    106a:	mov    rbx,QWORD PTR [rsp+0x10]
    106f:	mov    r12,QWORD PTR [rsp+0x18]
    1074:	mov    r13,QWORD PTR [rsp+0x20]
    1079:	mov    r14,QWORD PTR [rsp+0x28]
    107e:	mov    r15,QWORD PTR [rsp+0x30]
    1083:	add    rsp,0x40
    1087:	mov    rsp,rbp
    108a:	pop    rbp
    108b:	ret
    108c:	mov    r15,rdi
    108f:	mov    rsi,QWORD PTR [rip+0x0]        # 1096 <botlish_fn_7+0x2de>
			1092: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1096:	call   rsi
    1098:	xor    rax,rax
    109b:	mov    rbx,QWORD PTR [rsp+0x10]
    10a0:	mov    r12,QWORD PTR [rsp+0x18]
    10a5:	mov    r13,QWORD PTR [rsp+0x20]
    10aa:	mov    r14,QWORD PTR [rsp+0x28]
    10af:	mov    r15,QWORD PTR [rsp+0x30]
    10b4:	add    rsp,0x40
    10b8:	mov    rsp,rbp
    10bb:	pop    rbp
    10bc:	ret
    10bd:	add    BYTE PTR [rax],al
    10bf:	add    BYTE PTR [rsi],al
    10c1:	add    BYTE PTR [rax],al
    10c3:	add    BYTE PTR [rax],al
    10c5:	add    BYTE PTR [rax],al
	...

00000000000010c8 <botlish_entry_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
    10c8:	push   rbp
    10c9:	mov    rbp,rsp
    10cc:	mov    rsi,QWORD PTR [rdx]
    10cf:	mov    r9,QWORD PTR [rdx+0x8]
    10d3:	mov    rcx,QWORD PTR [rdx+0x10]
    10d7:	mov    r8,QWORD PTR [rdx+0x18]
    10db:	mov    rdx,r9
    10de:	call   10e3 <botlish_entry_7+0x1b>
			10df: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
    10e3:	mov    rsp,rbp
    10e6:	pop    rbp
    10e7:	ret

00000000000010e8 <botlish_fn_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
    10e8:	push   rbp
    10e9:	mov    rbp,rsp
    10ec:	sub    rsp,0x40
    10f0:	mov    QWORD PTR [rsp+0x10],rbx
    10f5:	mov    QWORD PTR [rsp+0x18],r12
    10fa:	mov    QWORD PTR [rsp+0x20],r13
    10ff:	mov    QWORD PTR [rsp+0x28],r14
    1104:	mov    QWORD PTR [rsp+0x30],r15
    1109:	mov    r14,QWORD PTR [rdi]
    110c:	mov    rax,QWORD PTR [rdi+0x8]
    1110:	lea    r9,[r14+0x30]
    1114:	cmp    r9,rax
    1117:	ja     137e <botlish_fn_8+0x296>
    111d:	lea    rax,[r14+0x30]
    1121:	mov    QWORD PTR [rdi],rax
    1124:	mov    r15,rdi
    1127:	mov    QWORD PTR [r14],0x0
    112e:	mov    QWORD PTR [r14+0x8],0x0
    1136:	mov    QWORD PTR [r14+0x10],0x0
    113e:	mov    QWORD PTR [r14+0x18],0x0
    1146:	mov    QWORD PTR [r14+0x20],0x0
    114e:	mov    QWORD PTR [r14+0x28],0x0
    1156:	mov    QWORD PTR [r14],rsi
    1159:	mov    QWORD PTR [r14+0x8],rdx
    115d:	mov    rbx,rdx
    1160:	mov    QWORD PTR [r14+0x10],rcx
    1164:	mov    QWORD PTR [rsp],rcx
    1168:	mov    QWORD PTR [r14+0x18],r8
    116c:	mov    QWORD PTR [rsp+0x8],r8
    1171:	mov    rcx,QWORD PTR [rip+0x0]        # 1178 <botlish_fn_8+0x90>
			1174: R_X86_64_GOTPCREL	rt_list_len-0x4
    1178:	mov    r13,rsi
    117b:	mov    rdi,r15
    117e:	call   rcx
    1180:	mov    r12,rbx
    1183:	mov    rcx,r12
    1186:	and    rcx,rax
    1189:	mov    rdx,rax
    118c:	test   rcx,0x1
    1193:	jne    11be <botlish_fn_8+0xd6>
    1199:	mov    r8,QWORD PTR [rip+0x0]        # 11a0 <botlish_fn_8+0xb8>
			119c: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    11a0:	mov    rsi,r12
    11a3:	mov    rdi,r15
    11a6:	call   r8
    11a9:	mov    ecx,0x2
    11ae:	test   rax,rax
    11b1:	cmovge rcx,QWORD PTR [rip+0x1f7]        # 13b0 <botlish_fn_8+0x2c8>
    11b9:	jmp    11ce <botlish_fn_8+0xe6>
    11be:	mov    ecx,0x2
    11c3:	cmp    r12,rdx
    11c6:	cmovge rcx,QWORD PTR [rip+0x1e2]        # 13b0 <botlish_fn_8+0x2c8>
    11ce:	cmp    rcx,0x6
    11d2:	je     1351 <botlish_fn_8+0x269>
    11d8:	test   r12,0x1
    11df:	je     11f8 <botlish_fn_8+0x110>
    11e5:	mov    rcx,QWORD PTR [r13+0x8]
    11e9:	mov    rax,r12
    11ec:	sar    rax,1
    11ef:	cmp    rax,rcx
    11f2:	jb     1223 <botlish_fn_8+0x13b>
    11f8:	mov    rax,QWORD PTR [rip+0x0]        # 11ff <botlish_fn_8+0x117>
			11fb: R_X86_64_GOTPCREL	rt_list_get-0x4
    11ff:	mov    rdx,r12
    1202:	mov    rsi,r13
    1205:	mov    rdi,r15
    1208:	call   rax
    120a:	test   rax,rax
    120d:	jne    121b <botlish_fn_8+0x133>
    1213:	mov    rdi,r15
    1216:	jmp    12b1 <botlish_fn_8+0x1c9>
    121b:	mov    rcx,rax
    121e:	jmp    122b <botlish_fn_8+0x143>
    1223:	mov    rcx,QWORD PTR [r13+0x10]
    1227:	mov    rcx,QWORD PTR [rcx+rax*8]
    122b:	mov    QWORD PTR [r14+0x20],rcx
    122f:	mov    rbx,rcx
    1232:	mov    QWORD PTR [r14+0x28],0x1
    123a:	mov    rdi,r15
    123d:	call   1242 <botlish_fn_8+0x15a>
			123e: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    1242:	test   rax,rax
    1245:	mov    r9,rax
    1248:	jne    1256 <botlish_fn_8+0x16e>
    124e:	mov    rdi,r15
    1251:	jmp    12b1 <botlish_fn_8+0x1c9>
    1256:	mov    r8d,0x1
    125c:	mov    rax,QWORD PTR [rip+0x0]        # 1263 <botlish_fn_8+0x17b>
			125f: R_X86_64_GOTPCREL	rt_mutarray_copy-0x4
    1263:	mov    rcx,rbx
    1266:	mov    rbx,QWORD PTR [rsp]
    126a:	mov    rdx,QWORD PTR [rsp+0x8]
    126f:	mov    rsi,rbx
    1272:	mov    rdi,r15
    1275:	call   rax
    1277:	test   rax,rax
    127a:	jne    1288 <botlish_fn_8+0x1a0>
    1280:	mov    rdi,r15
    1283:	jmp    12b1 <botlish_fn_8+0x1c9>
    1288:	sar    r12,1
    128b:	add    r12,0x1
    1292:	shl    r12,1
    1295:	or     r12,0x1
    1299:	mov    QWORD PTR [r14+0x8],r12
    129d:	mov    rdi,r15
    12a0:	call   12a5 <botlish_fn_8+0x1bd>
			12a1: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    12a5:	test   rax,rax
    12a8:	jne    12dc <botlish_fn_8+0x1f4>
    12ae:	mov    rdi,r15
    12b1:	mov    rdi,r15
    12b4:	mov    QWORD PTR [rdi],r14
    12b7:	xor    rax,rax
    12ba:	mov    rbx,QWORD PTR [rsp+0x10]
    12bf:	mov    r12,QWORD PTR [rsp+0x18]
    12c4:	mov    r13,QWORD PTR [rsp+0x20]
    12c9:	mov    r14,QWORD PTR [rsp+0x28]
    12ce:	mov    r15,QWORD PTR [rsp+0x30]
    12d3:	add    rsp,0x40
    12d7:	mov    rsp,rbp
    12da:	pop    rbp
    12db:	ret
    12dc:	mov    QWORD PTR [r14+0x20],rax
    12e0:	mov    rsi,QWORD PTR [rsp+0x8]
    12e5:	mov    rcx,rsi
    12e8:	and    rcx,rax
    12eb:	test   rcx,0x1
    12f2:	jne    1300 <botlish_fn_8+0x218>
    12f8:	mov    rdx,rax
    12fb:	jmp    131d <botlish_fn_8+0x235>
    1300:	lea    rcx,[rax-0x1]
    1304:	mov    rdx,rax
    1307:	mov    rsi,QWORD PTR [rsp+0x8]
    130c:	mov    rax,rsi
    130f:	add    rax,rcx
    1312:	seto   cl
    1315:	test   cl,cl
    1317:	je     132e <botlish_fn_8+0x246>
    131d:	mov    rax,QWORD PTR [rip+0x0]        # 1324 <botlish_fn_8+0x23c>
			1320: R_X86_64_GOTPCREL	rt_int_add-0x4
    1324:	mov    rsi,QWORD PTR [rsp+0x8]
    1329:	mov    rdi,r15
    132c:	call   rax
    132e:	mov    QWORD PTR [r14],r13
    1331:	mov    QWORD PTR [r14+0x8],r12
    1335:	mov    QWORD PTR [r14+0x10],rbx
    1339:	mov    QWORD PTR [r14+0x18],rax
    133d:	mov    QWORD PTR [rsp+0x8],rax
    1342:	mov    QWORD PTR [rsp],rbx
    1346:	mov    rsi,r13
    1349:	mov    rbx,r12
    134c:	jmp    1171 <botlish_fn_8+0x89>
    1351:	mov    rdi,r15
    1354:	mov    QWORD PTR [rdi],r14
    1357:	mov    rax,QWORD PTR [rsp+0x8]
    135c:	mov    rbx,QWORD PTR [rsp+0x10]
    1361:	mov    r12,QWORD PTR [rsp+0x18]
    1366:	mov    r13,QWORD PTR [rsp+0x20]
    136b:	mov    r14,QWORD PTR [rsp+0x28]
    1370:	mov    r15,QWORD PTR [rsp+0x30]
    1375:	add    rsp,0x40
    1379:	mov    rsp,rbp
    137c:	pop    rbp
    137d:	ret
    137e:	mov    r15,rdi
    1381:	mov    rax,QWORD PTR [rip+0x0]        # 1388 <botlish_fn_8+0x2a0>
			1384: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1388:	call   rax
    138a:	xor    rax,rax
    138d:	mov    rbx,QWORD PTR [rsp+0x10]
    1392:	mov    r12,QWORD PTR [rsp+0x18]
    1397:	mov    r13,QWORD PTR [rsp+0x20]
    139c:	mov    r14,QWORD PTR [rsp+0x28]
    13a1:	mov    r15,QWORD PTR [rsp+0x30]
    13a6:	add    rsp,0x40
    13aa:	mov    rsp,rbp
    13ad:	pop    rbp
    13ae:	ret
    13af:	add    BYTE PTR [rsi],al
    13b1:	add    BYTE PTR [rax],al
    13b3:	add    BYTE PTR [rax],al
    13b5:	add    BYTE PTR [rax],al
	...

00000000000013b8 <botlish_entry_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
    13b8:	push   rbp
    13b9:	mov    rbp,rsp
    13bc:	mov    rsi,QWORD PTR [rdx]
    13bf:	mov    r9,QWORD PTR [rdx+0x8]
    13c3:	mov    rcx,QWORD PTR [rdx+0x10]
    13c7:	mov    r8,QWORD PTR [rdx+0x18]
    13cb:	mov    rdx,r9
    13ce:	call   13d3 <botlish_entry_8+0x1b>
			13cf: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    13d3:	mov    rsp,rbp
    13d6:	pop    rbp
    13d7:	ret

00000000000013d8 <botlish_fn_9: chunked_finish<list[list<never>, mutarray, int]>>:
    13d8:	push   rbp
    13d9:	mov    rbp,rsp
    13dc:	sub    rsp,0x40
    13e0:	mov    QWORD PTR [rsp+0x10],rbx
    13e5:	mov    QWORD PTR [rsp+0x18],r12
    13ea:	mov    QWORD PTR [rsp+0x20],r13
    13ef:	mov    QWORD PTR [rsp+0x28],r14
    13f4:	mov    QWORD PTR [rsp+0x30],r15
    13f9:	mov    r12,QWORD PTR [rdi]
    13fc:	mov    rax,QWORD PTR [rdi+0x8]
    1400:	lea    r8,[r12+0x38]
    1405:	cmp    r8,rax
    1408:	ja     1661 <botlish_fn_9+0x289>
    140e:	lea    rax,[r12+0x38]
    1413:	mov    QWORD PTR [rdi],rax
    1416:	mov    r14,rdi
    1419:	mov    QWORD PTR [r12],0x0
    1421:	mov    QWORD PTR [r12+0x8],0x0
    142a:	mov    QWORD PTR [r12+0x10],0x0
    1433:	mov    QWORD PTR [r12+0x18],0x0
    143c:	mov    QWORD PTR [r12+0x20],0x0
    1445:	mov    QWORD PTR [r12+0x28],0x0
    144e:	mov    QWORD PTR [r12+0x30],0x0
    1457:	mov    QWORD PTR [r12],rsi
    145b:	mov    QWORD PTR [rsp],rsi
    145f:	mov    QWORD PTR [r12+0x8],rdx
    1464:	mov    r15,rdx
    1467:	mov    QWORD PTR [r12+0x10],rcx
    146c:	mov    rbx,rcx
    146f:	mov    rax,QWORD PTR [rip+0x0]        # 1476 <botlish_fn_9+0x9e>
			1472: R_X86_64_GOTPCREL	rt_list_len-0x4
    1476:	mov    rsi,QWORD PTR [rsp]
    147a:	mov    rdi,r14
    147d:	call   rax
    147f:	mov    QWORD PTR [r12+0x18],rax
    1484:	mov    r13,rax
    1487:	mov    rdi,r14
    148a:	call   148f <botlish_fn_9+0xb7>
			148b: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    148f:	test   rax,rax
    1492:	jne    14a0 <botlish_fn_9+0xc8>
    1498:	mov    rdi,r14
    149b:	jmp    160e <botlish_fn_9+0x236>
    14a0:	mov    QWORD PTR [r12+0x20],rax
    14a5:	mov    rcx,r13
    14a8:	mov    rdx,rcx
    14ab:	and    rdx,rax
    14ae:	mov    rdi,rax
    14b1:	test   rdx,0x1
    14b8:	jne    14c6 <botlish_fn_9+0xee>
    14be:	mov    r13,rcx
    14c1:	jmp    14f2 <botlish_fn_9+0x11a>
    14c6:	mov    rax,rcx
    14c9:	sar    rax,1
    14cc:	mov    r13,rcx
    14cf:	mov    rcx,rdi
    14d2:	lea    rdx,[rcx-0x1]
    14d6:	imul   rdx
    14d9:	seto   sil
    14dd:	or     rax,0x1
    14e1:	test   sil,sil
    14e4:	jne    14f2 <botlish_fn_9+0x11a>
    14ea:	mov    rsi,rax
    14ed:	jmp    1508 <botlish_fn_9+0x130>
    14f2:	mov    r8,QWORD PTR [rip+0x0]        # 14f9 <botlish_fn_9+0x121>
			14f5: R_X86_64_GOTPCREL	rt_int_mul-0x4
    14f9:	mov    rdx,rdi
    14fc:	mov    rsi,r13
    14ff:	mov    rdi,r14
    1502:	call   r8
    1505:	mov    rsi,rax
    1508:	mov    QWORD PTR [r12+0x18],rsi
    150d:	mov    rdi,rsi
    1510:	and    rdi,rbx
    1513:	test   rdi,0x1
    151a:	je     1537 <botlish_fn_9+0x15f>
    1520:	lea    r10,[rbx-0x1]
    1524:	mov    r13,rsi
    1527:	add    r13,r10
    152a:	seto   r11b
    152e:	test   r11b,r11b
    1531:	je     1549 <botlish_fn_9+0x171>
    1537:	mov    rax,QWORD PTR [rip+0x0]        # 153e <botlish_fn_9+0x166>
			153a: R_X86_64_GOTPCREL	rt_int_add-0x4
    153e:	mov    rdx,rbx
    1541:	mov    rdi,r14
    1544:	call   rax
    1546:	mov    r13,rax
    1549:	mov    QWORD PTR [r12+0x18],r13
    154e:	mov    rax,QWORD PTR [rip+0x0]        # 1555 <botlish_fn_9+0x17d>
			1551: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    1555:	mov    rsi,r13
    1558:	mov    rdi,r14
    155b:	call   rax
    155d:	mov    rsi,rax
    1560:	mov    QWORD PTR [rsp+0x8],rax
    1565:	test   rax,rsi
    1568:	jne    1576 <botlish_fn_9+0x19e>
    156e:	mov    rdi,r14
    1571:	jmp    160e <botlish_fn_9+0x236>
    1576:	mov    rax,QWORD PTR [rsp+0x8]
    157b:	mov    QWORD PTR [r12+0x20],rax
    1580:	mov    r8d,0x1
    1586:	mov    QWORD PTR [r12+0x28],0x1
    158f:	mov    QWORD PTR [r12+0x30],0x1
    1598:	mov    rsi,QWORD PTR [rsp]
    159c:	mov    rcx,QWORD PTR [rsp+0x8]
    15a1:	mov    rdi,r14
    15a4:	mov    rdx,r8
    15a7:	call   15ac <botlish_fn_9+0x1d4>
			15a8: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
    15ac:	test   rax,rax
    15af:	mov    rdx,rax
    15b2:	jne    15c0 <botlish_fn_9+0x1e8>
    15b8:	mov    rdi,r14
    15bb:	jmp    160e <botlish_fn_9+0x236>
    15c0:	mov    r8d,0x1
    15c6:	mov    rax,QWORD PTR [rip+0x0]        # 15cd <botlish_fn_9+0x1f5>
			15c9: R_X86_64_GOTPCREL	rt_mutarray_copy-0x4
    15cd:	mov    rcx,r15
    15d0:	mov    r9,rbx
    15d3:	mov    rsi,QWORD PTR [rsp+0x8]
    15d8:	mov    rdi,r14
    15db:	call   rax
    15dd:	test   rax,rax
    15e0:	jne    15ee <botlish_fn_9+0x216>
    15e6:	mov    rdi,r14
    15e9:	jmp    160e <botlish_fn_9+0x236>
    15ee:	mov    rax,QWORD PTR [rip+0x0]        # 15f5 <botlish_fn_9+0x21d>
			15f1: R_X86_64_GOTPCREL	rt_mutarray_freeze-0x4
    15f5:	mov    rdx,r13
    15f8:	mov    rsi,QWORD PTR [rsp+0x8]
    15fd:	mov    rdi,r14
    1600:	call   rax
    1602:	test   rax,rax
    1605:	jne    1639 <botlish_fn_9+0x261>
    160b:	mov    rdi,r14
    160e:	mov    rdi,r14
    1611:	mov    QWORD PTR [rdi],r12
    1614:	xor    rax,rax
    1617:	mov    rbx,QWORD PTR [rsp+0x10]
    161c:	mov    r12,QWORD PTR [rsp+0x18]
    1621:	mov    r13,QWORD PTR [rsp+0x20]
    1626:	mov    r14,QWORD PTR [rsp+0x28]
    162b:	mov    r15,QWORD PTR [rsp+0x30]
    1630:	add    rsp,0x40
    1634:	mov    rsp,rbp
    1637:	pop    rbp
    1638:	ret
    1639:	mov    rdi,r14
    163c:	mov    QWORD PTR [rdi],r12
    163f:	mov    rbx,QWORD PTR [rsp+0x10]
    1644:	mov    r12,QWORD PTR [rsp+0x18]
    1649:	mov    r13,QWORD PTR [rsp+0x20]
    164e:	mov    r14,QWORD PTR [rsp+0x28]
    1653:	mov    r15,QWORD PTR [rsp+0x30]
    1658:	add    rsp,0x40
    165c:	mov    rsp,rbp
    165f:	pop    rbp
    1660:	ret
    1661:	mov    r14,rdi
    1664:	mov    rax,QWORD PTR [rip+0x0]        # 166b <botlish_fn_9+0x293>
			1667: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    166b:	call   rax
    166d:	xor    rax,rax
    1670:	mov    rbx,QWORD PTR [rsp+0x10]
    1675:	mov    r12,QWORD PTR [rsp+0x18]
    167a:	mov    r13,QWORD PTR [rsp+0x20]
    167f:	mov    r14,QWORD PTR [rsp+0x28]
    1684:	mov    r15,QWORD PTR [rsp+0x30]
    1689:	add    rsp,0x40
    168d:	mov    rsp,rbp
    1690:	pop    rbp
    1691:	ret

0000000000001692 <botlish_entry_9: chunked_finish<list[list<never>, mutarray, int]>>:
    1692:	push   rbp
    1693:	mov    rbp,rsp
    1696:	mov    rsi,QWORD PTR [rdx]
    1699:	mov    r8,QWORD PTR [rdx+0x8]
    169d:	mov    rcx,QWORD PTR [rdx+0x10]
    16a1:	mov    rdx,r8
    16a4:	call   16a9 <botlish_entry_9+0x17>
			16a5: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    16a9:	mov    rsp,rbp
    16ac:	pop    rbp
    16ad:	ret

00000000000016ae <botlish_fn_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    16ae:	push   rbp
    16af:	mov    rbp,rsp
    16b2:	sub    rsp,0x40
    16b6:	mov    QWORD PTR [rsp+0x10],rbx
    16bb:	mov    QWORD PTR [rsp+0x18],r12
    16c0:	mov    QWORD PTR [rsp+0x20],r13
    16c5:	mov    QWORD PTR [rsp+0x28],r14
    16ca:	mov    QWORD PTR [rsp+0x30],r15
    16cf:	mov    r12,QWORD PTR [rdi]
    16d2:	mov    rax,QWORD PTR [rdi+0x8]
    16d6:	lea    r8,[r12+0x38]
    16db:	cmp    r8,rax
    16de:	ja     1937 <botlish_fn_10+0x289>
    16e4:	lea    rax,[r12+0x38]
    16e9:	mov    QWORD PTR [rdi],rax
    16ec:	mov    r14,rdi
    16ef:	mov    QWORD PTR [r12],0x0
    16f7:	mov    QWORD PTR [r12+0x8],0x0
    1700:	mov    QWORD PTR [r12+0x10],0x0
    1709:	mov    QWORD PTR [r12+0x18],0x0
    1712:	mov    QWORD PTR [r12+0x20],0x0
    171b:	mov    QWORD PTR [r12+0x28],0x0
    1724:	mov    QWORD PTR [r12+0x30],0x0
    172d:	mov    QWORD PTR [r12],rsi
    1731:	mov    QWORD PTR [rsp],rsi
    1735:	mov    QWORD PTR [r12+0x8],rdx
    173a:	mov    r15,rdx
    173d:	mov    QWORD PTR [r12+0x10],rcx
    1742:	mov    rbx,rcx
    1745:	mov    rax,QWORD PTR [rip+0x0]        # 174c <botlish_fn_10+0x9e>
			1748: R_X86_64_GOTPCREL	rt_list_len-0x4
    174c:	mov    rsi,QWORD PTR [rsp]
    1750:	mov    rdi,r14
    1753:	call   rax
    1755:	mov    QWORD PTR [r12+0x18],rax
    175a:	mov    r13,rax
    175d:	mov    rdi,r14
    1760:	call   1765 <botlish_fn_10+0xb7>
			1761: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    1765:	test   rax,rax
    1768:	jne    1776 <botlish_fn_10+0xc8>
    176e:	mov    rdi,r14
    1771:	jmp    18e4 <botlish_fn_10+0x236>
    1776:	mov    QWORD PTR [r12+0x20],rax
    177b:	mov    rcx,r13
    177e:	mov    rdx,rcx
    1781:	and    rdx,rax
    1784:	mov    rdi,rax
    1787:	test   rdx,0x1
    178e:	jne    179c <botlish_fn_10+0xee>
    1794:	mov    r13,rcx
    1797:	jmp    17c8 <botlish_fn_10+0x11a>
    179c:	mov    rax,rcx
    179f:	sar    rax,1
    17a2:	mov    r13,rcx
    17a5:	mov    rcx,rdi
    17a8:	lea    rdx,[rcx-0x1]
    17ac:	imul   rdx
    17af:	seto   sil
    17b3:	or     rax,0x1
    17b7:	test   sil,sil
    17ba:	jne    17c8 <botlish_fn_10+0x11a>
    17c0:	mov    rsi,rax
    17c3:	jmp    17de <botlish_fn_10+0x130>
    17c8:	mov    r8,QWORD PTR [rip+0x0]        # 17cf <botlish_fn_10+0x121>
			17cb: R_X86_64_GOTPCREL	rt_int_mul-0x4
    17cf:	mov    rdx,rdi
    17d2:	mov    rsi,r13
    17d5:	mov    rdi,r14
    17d8:	call   r8
    17db:	mov    rsi,rax
    17de:	mov    QWORD PTR [r12+0x18],rsi
    17e3:	mov    rdi,rsi
    17e6:	and    rdi,rbx
    17e9:	test   rdi,0x1
    17f0:	je     180d <botlish_fn_10+0x15f>
    17f6:	lea    r10,[rbx-0x1]
    17fa:	mov    r13,rsi
    17fd:	add    r13,r10
    1800:	seto   r11b
    1804:	test   r11b,r11b
    1807:	je     181f <botlish_fn_10+0x171>
    180d:	mov    rax,QWORD PTR [rip+0x0]        # 1814 <botlish_fn_10+0x166>
			1810: R_X86_64_GOTPCREL	rt_int_add-0x4
    1814:	mov    rdx,rbx
    1817:	mov    rdi,r14
    181a:	call   rax
    181c:	mov    r13,rax
    181f:	mov    QWORD PTR [r12+0x18],r13
    1824:	mov    rax,QWORD PTR [rip+0x0]        # 182b <botlish_fn_10+0x17d>
			1827: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    182b:	mov    rsi,r13
    182e:	mov    rdi,r14
    1831:	call   rax
    1833:	mov    rsi,rax
    1836:	mov    QWORD PTR [rsp+0x8],rax
    183b:	test   rax,rsi
    183e:	jne    184c <botlish_fn_10+0x19e>
    1844:	mov    rdi,r14
    1847:	jmp    18e4 <botlish_fn_10+0x236>
    184c:	mov    rax,QWORD PTR [rsp+0x8]
    1851:	mov    QWORD PTR [r12+0x20],rax
    1856:	mov    r8d,0x1
    185c:	mov    QWORD PTR [r12+0x28],0x1
    1865:	mov    QWORD PTR [r12+0x30],0x1
    186e:	mov    rsi,QWORD PTR [rsp]
    1872:	mov    rcx,QWORD PTR [rsp+0x8]
    1877:	mov    rdi,r14
    187a:	mov    rdx,r8
    187d:	call   1882 <botlish_fn_10+0x1d4>
			187e: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    1882:	test   rax,rax
    1885:	mov    rdx,rax
    1888:	jne    1896 <botlish_fn_10+0x1e8>
    188e:	mov    rdi,r14
    1891:	jmp    18e4 <botlish_fn_10+0x236>
    1896:	mov    r8d,0x1
    189c:	mov    rax,QWORD PTR [rip+0x0]        # 18a3 <botlish_fn_10+0x1f5>
			189f: R_X86_64_GOTPCREL	rt_mutarray_copy-0x4
    18a3:	mov    rcx,r15
    18a6:	mov    r9,rbx
    18a9:	mov    rsi,QWORD PTR [rsp+0x8]
    18ae:	mov    rdi,r14
    18b1:	call   rax
    18b3:	test   rax,rax
    18b6:	jne    18c4 <botlish_fn_10+0x216>
    18bc:	mov    rdi,r14
    18bf:	jmp    18e4 <botlish_fn_10+0x236>
    18c4:	mov    rax,QWORD PTR [rip+0x0]        # 18cb <botlish_fn_10+0x21d>
			18c7: R_X86_64_GOTPCREL	rt_mutarray_freeze-0x4
    18cb:	mov    rdx,r13
    18ce:	mov    rsi,QWORD PTR [rsp+0x8]
    18d3:	mov    rdi,r14
    18d6:	call   rax
    18d8:	test   rax,rax
    18db:	jne    190f <botlish_fn_10+0x261>
    18e1:	mov    rdi,r14
    18e4:	mov    rdi,r14
    18e7:	mov    QWORD PTR [rdi],r12
    18ea:	xor    rax,rax
    18ed:	mov    rbx,QWORD PTR [rsp+0x10]
    18f2:	mov    r12,QWORD PTR [rsp+0x18]
    18f7:	mov    r13,QWORD PTR [rsp+0x20]
    18fc:	mov    r14,QWORD PTR [rsp+0x28]
    1901:	mov    r15,QWORD PTR [rsp+0x30]
    1906:	add    rsp,0x40
    190a:	mov    rsp,rbp
    190d:	pop    rbp
    190e:	ret
    190f:	mov    rdi,r14
    1912:	mov    QWORD PTR [rdi],r12
    1915:	mov    rbx,QWORD PTR [rsp+0x10]
    191a:	mov    r12,QWORD PTR [rsp+0x18]
    191f:	mov    r13,QWORD PTR [rsp+0x20]
    1924:	mov    r14,QWORD PTR [rsp+0x28]
    1929:	mov    r15,QWORD PTR [rsp+0x30]
    192e:	add    rsp,0x40
    1932:	mov    rsp,rbp
    1935:	pop    rbp
    1936:	ret
    1937:	mov    r14,rdi
    193a:	mov    rax,QWORD PTR [rip+0x0]        # 1941 <botlish_fn_10+0x293>
			193d: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1941:	call   rax
    1943:	xor    rax,rax
    1946:	mov    rbx,QWORD PTR [rsp+0x10]
    194b:	mov    r12,QWORD PTR [rsp+0x18]
    1950:	mov    r13,QWORD PTR [rsp+0x20]
    1955:	mov    r14,QWORD PTR [rsp+0x28]
    195a:	mov    r15,QWORD PTR [rsp+0x30]
    195f:	add    rsp,0x40
    1963:	mov    rsp,rbp
    1966:	pop    rbp
    1967:	ret

0000000000001968 <botlish_entry_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    1968:	push   rbp
    1969:	mov    rbp,rsp
    196c:	mov    rsi,QWORD PTR [rdx]
    196f:	mov    r8,QWORD PTR [rdx+0x8]
    1973:	mov    rcx,QWORD PTR [rdx+0x10]
    1977:	mov    rdx,r8
    197a:	call   197f <botlish_entry_10+0x17>
			197b: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    197f:	mov    rsp,rbp
    1982:	pop    rbp
    1983:	ret
    1984:	add    BYTE PTR [rax],al
	...

0000000000001988 <botlish_fn_11: peek<str, int>>:
    1988:	push   rbp
    1989:	mov    rbp,rsp
    198c:	sub    rsp,0x20
    1990:	mov    QWORD PTR [rsp],rbx
    1994:	mov    QWORD PTR [rsp+0x8],r12
    1999:	mov    QWORD PTR [rsp+0x10],r13
    199e:	mov    QWORD PTR [rsp+0x18],r14
    19a3:	mov    r12,QWORD PTR [rdi]
    19a6:	mov    rax,QWORD PTR [rdi+0x8]
    19aa:	lea    rcx,[r12+0x18]
    19af:	cmp    rcx,rax
    19b2:	ja     1b1f <botlish_fn_11+0x197>
    19b8:	lea    rax,[r12+0x18]
    19bd:	mov    QWORD PTR [rdi],rax
    19c0:	mov    r13,rdi
    19c3:	mov    QWORD PTR [r12],0x0
    19cb:	mov    QWORD PTR [r12+0x8],0x0
    19d4:	mov    QWORD PTR [r12+0x10],0x0
    19dd:	mov    QWORD PTR [r12],rsi
    19e1:	mov    r14,rsi
    19e4:	mov    QWORD PTR [r12+0x8],rdx
    19e9:	mov    rbx,rdx
    19ec:	mov    rax,QWORD PTR [rip+0x0]        # 19f3 <botlish_fn_11+0x6b>
			19ef: R_X86_64_GOTPCREL	rt_str_len-0x4
    19f3:	mov    rsi,r14
    19f6:	mov    rdi,r13
    19f9:	call   rax
    19fb:	mov    rcx,rbx
    19fe:	and    rcx,rax
    1a01:	mov    rdx,rax
    1a04:	test   rcx,0x1
    1a0b:	jne    1a35 <botlish_fn_11+0xad>
    1a11:	mov    rax,QWORD PTR [rip+0x0]        # 1a18 <botlish_fn_11+0x90>
			1a14: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    1a18:	mov    rsi,rbx
    1a1b:	mov    rdi,r13
    1a1e:	call   rax
    1a20:	mov    ecx,0x2
    1a25:	test   rax,rax
    1a28:	cmovge rcx,QWORD PTR [rip+0x120]        # 1b50 <botlish_fn_11+0x1c8>
    1a30:	jmp    1a45 <botlish_fn_11+0xbd>
    1a35:	mov    ecx,0x2
    1a3a:	cmp    rbx,rdx
    1a3d:	cmovge rcx,QWORD PTR [rip+0x10b]        # 1b50 <botlish_fn_11+0x1c8>
    1a45:	cmp    rcx,0x6
    1a49:	je     1af5 <botlish_fn_11+0x16d>
    1a4f:	mov    QWORD PTR [r12+0x10],0x3
    1a58:	test   rbx,0x1
    1a5f:	je     1a77 <botlish_fn_11+0xef>
    1a65:	mov    rcx,rbx
    1a68:	add    rcx,0x2
    1a6c:	seto   al
    1a6f:	test   al,al
    1a71:	je     1a8e <botlish_fn_11+0x106>
    1a77:	mov    edx,0x3
    1a7c:	mov    rax,QWORD PTR [rip+0x0]        # 1a83 <botlish_fn_11+0xfb>
			1a7f: R_X86_64_GOTPCREL	rt_int_add-0x4
    1a83:	mov    rsi,rbx
    1a86:	mov    rdi,r13
    1a89:	call   rax
    1a8b:	mov    rcx,rax
    1a8e:	mov    QWORD PTR [r12+0x10],rcx
    1a93:	mov    rax,QWORD PTR [rip+0x0]        # 1a9a <botlish_fn_11+0x112>
			1a96: R_X86_64_GOTPCREL	rt_substr-0x4
    1a9a:	mov    rdx,rbx
    1a9d:	mov    rsi,r14
    1aa0:	mov    rdi,r13
    1aa3:	call   rax
    1aa5:	test   rax,rax
    1aa8:	jne    1ad3 <botlish_fn_11+0x14b>
    1aae:	mov    rdi,r13
    1ab1:	mov    QWORD PTR [rdi],r12
    1ab4:	xor    rax,rax
    1ab7:	mov    rbx,QWORD PTR [rsp]
    1abb:	mov    r12,QWORD PTR [rsp+0x8]
    1ac0:	mov    r13,QWORD PTR [rsp+0x10]
    1ac5:	mov    r14,QWORD PTR [rsp+0x18]
    1aca:	add    rsp,0x20
    1ace:	mov    rsp,rbp
    1ad1:	pop    rbp
    1ad2:	ret
    1ad3:	mov    rdi,r13
    1ad6:	mov    QWORD PTR [rdi],r12
    1ad9:	mov    rbx,QWORD PTR [rsp]
    1add:	mov    r12,QWORD PTR [rsp+0x8]
    1ae2:	mov    r13,QWORD PTR [rsp+0x10]
    1ae7:	mov    r14,QWORD PTR [rsp+0x18]
    1aec:	add    rsp,0x20
    1af0:	mov    rsp,rbp
    1af3:	pop    rbp
    1af4:	ret
    1af5:	mov    rdi,r13
    1af8:	mov    rsi,QWORD PTR [rdi+0x10]
    1afc:	mov    rax,QWORD PTR [rsi+0x10]
    1b00:	mov    QWORD PTR [rdi],r12
    1b03:	mov    rbx,QWORD PTR [rsp]
    1b07:	mov    r12,QWORD PTR [rsp+0x8]
    1b0c:	mov    r13,QWORD PTR [rsp+0x10]
    1b11:	mov    r14,QWORD PTR [rsp+0x18]
    1b16:	add    rsp,0x20
    1b1a:	mov    rsp,rbp
    1b1d:	pop    rbp
    1b1e:	ret
    1b1f:	mov    r13,rdi
    1b22:	mov    rsi,QWORD PTR [rip+0x0]        # 1b29 <botlish_fn_11+0x1a1>
			1b25: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1b29:	call   rsi
    1b2b:	xor    rax,rax
    1b2e:	mov    rbx,QWORD PTR [rsp]
    1b32:	mov    r12,QWORD PTR [rsp+0x8]
    1b37:	mov    r13,QWORD PTR [rsp+0x10]
    1b3c:	mov    r14,QWORD PTR [rsp+0x18]
    1b41:	add    rsp,0x20
    1b45:	mov    rsp,rbp
    1b48:	pop    rbp
    1b49:	ret
    1b4a:	add    BYTE PTR [rax],al
    1b4c:	add    BYTE PTR [rax],al
    1b4e:	add    BYTE PTR [rax],al
    1b50:	(bad)
    1b51:	add    BYTE PTR [rax],al
    1b53:	add    BYTE PTR [rax],al
    1b55:	add    BYTE PTR [rax],al
	...

0000000000001b58 <botlish_entry_11: peek<str, int>>:
    1b58:	push   rbp
    1b59:	mov    rbp,rsp
    1b5c:	mov    rsi,QWORD PTR [rdx]
    1b5f:	mov    rdx,QWORD PTR [rdx+0x8]
    1b63:	call   1b68 <botlish_entry_11+0x10>
			1b64: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1b68:	mov    rsp,rbp
    1b6b:	pop    rbp
    1b6c:	ret
    1b6d:	add    BYTE PTR [rax],al
	...

0000000000001b70 <botlish_fn_12: peek<str, int>>:
    1b70:	push   rbp
    1b71:	mov    rbp,rsp
    1b74:	sub    rsp,0x40
    1b78:	mov    QWORD PTR [rsp+0x10],rbx
    1b7d:	mov    QWORD PTR [rsp+0x18],r12
    1b82:	mov    QWORD PTR [rsp+0x20],r13
    1b87:	mov    QWORD PTR [rsp+0x28],r14
    1b8c:	mov    QWORD PTR [rsp+0x30],r15
    1b91:	mov    r13,rcx
    1b94:	mov    r12,QWORD PTR [rdi]
    1b97:	mov    rax,QWORD PTR [rdi+0x8]
    1b9b:	lea    rcx,[r12+0x18]
    1ba0:	cmp    rcx,rax
    1ba3:	ja     1d4f <botlish_fn_12+0x1df>
    1ba9:	lea    rax,[r12+0x18]
    1bae:	mov    QWORD PTR [rdi],rax
    1bb1:	mov    r15,rdi
    1bb4:	mov    QWORD PTR [r12],0x0
    1bbc:	mov    QWORD PTR [r12+0x8],0x0
    1bc5:	mov    QWORD PTR [r12+0x10],0x0
    1bce:	mov    QWORD PTR [r12],rsi
    1bd2:	mov    r14,rsi
    1bd5:	mov    QWORD PTR [r12+0x8],rdx
    1bda:	mov    rbx,rdx
    1bdd:	mov    rax,QWORD PTR [rip+0x0]        # 1be4 <botlish_fn_12+0x74>
			1be0: R_X86_64_GOTPCREL	rt_str_len-0x4
    1be4:	mov    rsi,r14
    1be7:	mov    rdi,r15
    1bea:	call   rax
    1bec:	mov    rcx,rbx
    1bef:	and    rcx,rax
    1bf2:	mov    rdx,rax
    1bf5:	test   rcx,0x1
    1bfc:	jne    1c26 <botlish_fn_12+0xb6>
    1c02:	mov    rax,QWORD PTR [rip+0x0]        # 1c09 <botlish_fn_12+0x99>
			1c05: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    1c09:	mov    rsi,rbx
    1c0c:	mov    rdi,r15
    1c0f:	call   rax
    1c11:	mov    ecx,0x2
    1c16:	test   rax,rax
    1c19:	cmovge rcx,QWORD PTR [rip+0x167]        # 1d88 <botlish_fn_12+0x218>
    1c21:	jmp    1c36 <botlish_fn_12+0xc6>
    1c26:	mov    ecx,0x2
    1c2b:	cmp    rbx,rdx
    1c2e:	cmovge rcx,QWORD PTR [rip+0x152]        # 1d88 <botlish_fn_12+0x218>
    1c36:	cmp    rcx,0x6
    1c3a:	je     1d0d <botlish_fn_12+0x19d>
    1c40:	mov    QWORD PTR [r12+0x10],0x3
    1c49:	test   rbx,0x1
    1c50:	je     1c71 <botlish_fn_12+0x101>
    1c56:	mov    rax,rbx
    1c59:	add    rax,0x2
    1c5d:	seto   cl
    1c60:	test   cl,cl
    1c62:	jne    1c71 <botlish_fn_12+0x101>
    1c68:	mov    QWORD PTR [rsp],rax
    1c6c:	jmp    1c89 <botlish_fn_12+0x119>
    1c71:	mov    edx,0x3
    1c76:	mov    rax,QWORD PTR [rip+0x0]        # 1c7d <botlish_fn_12+0x10d>
			1c79: R_X86_64_GOTPCREL	rt_int_add-0x4
    1c7d:	mov    rsi,rbx
    1c80:	mov    rdi,r15
    1c83:	call   rax
    1c85:	mov    QWORD PTR [rsp],rax
    1c89:	mov    r8,QWORD PTR [rip+0x0]        # 1c90 <botlish_fn_12+0x120>
			1c8c: R_X86_64_GOTPCREL	rt_str_region_check-0x4
    1c90:	mov    rcx,QWORD PTR [rsp]
    1c94:	mov    rdx,rbx
    1c97:	mov    rsi,r14
    1c9a:	mov    rdi,r15
    1c9d:	call   r8
    1ca0:	test   rax,rax
    1ca3:	jne    1cd4 <botlish_fn_12+0x164>
    1ca9:	mov    rdi,r15
    1cac:	mov    QWORD PTR [rdi],r12
    1caf:	xor    rax,rax
    1cb2:	mov    rbx,QWORD PTR [rsp+0x10]
    1cb7:	mov    r12,QWORD PTR [rsp+0x18]
    1cbc:	mov    r13,QWORD PTR [rsp+0x20]
    1cc1:	mov    r14,QWORD PTR [rsp+0x28]
    1cc6:	mov    r15,QWORD PTR [rsp+0x30]
    1ccb:	add    rsp,0x40
    1ccf:	mov    rsp,rbp
    1cd2:	pop    rbp
    1cd3:	ret
    1cd4:	mov    rdi,r15
    1cd7:	mov    QWORD PTR [rdi],r12
    1cda:	mov    rcx,r13
    1cdd:	mov    QWORD PTR [rcx],rbx
    1ce0:	mov    rax,QWORD PTR [rsp]
    1ce4:	mov    QWORD PTR [rcx+0x8],rax
    1ce8:	mov    rax,r14
    1ceb:	mov    rbx,QWORD PTR [rsp+0x10]
    1cf0:	mov    r12,QWORD PTR [rsp+0x18]
    1cf5:	mov    r13,QWORD PTR [rsp+0x20]
    1cfa:	mov    r14,QWORD PTR [rsp+0x28]
    1cff:	mov    r15,QWORD PTR [rsp+0x30]
    1d04:	add    rsp,0x40
    1d08:	mov    rsp,rbp
    1d0b:	pop    rbp
    1d0c:	ret
    1d0d:	mov    rcx,r13
    1d10:	mov    rdi,r15
    1d13:	mov    rsi,QWORD PTR [rdi+0x10]
    1d17:	mov    rax,QWORD PTR [rsi+0x10]
    1d1b:	mov    QWORD PTR [rdi],r12
    1d1e:	mov    QWORD PTR [rcx],0x1
    1d25:	mov    QWORD PTR [rcx+0x8],0x1
    1d2d:	mov    rbx,QWORD PTR [rsp+0x10]
    1d32:	mov    r12,QWORD PTR [rsp+0x18]
    1d37:	mov    r13,QWORD PTR [rsp+0x20]
    1d3c:	mov    r14,QWORD PTR [rsp+0x28]
    1d41:	mov    r15,QWORD PTR [rsp+0x30]
    1d46:	add    rsp,0x40
    1d4a:	mov    rsp,rbp
    1d4d:	pop    rbp
    1d4e:	ret
    1d4f:	mov    r15,rdi
    1d52:	mov    r10,QWORD PTR [rip+0x0]        # 1d59 <botlish_fn_12+0x1e9>
			1d55: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1d59:	call   r10
    1d5c:	xor    rax,rax
    1d5f:	mov    rbx,QWORD PTR [rsp+0x10]
    1d64:	mov    r12,QWORD PTR [rsp+0x18]
    1d69:	mov    r13,QWORD PTR [rsp+0x20]
    1d6e:	mov    r14,QWORD PTR [rsp+0x28]
    1d73:	mov    r15,QWORD PTR [rsp+0x30]
    1d78:	add    rsp,0x40
    1d7c:	mov    rsp,rbp
    1d7f:	pop    rbp
    1d80:	ret
    1d81:	add    BYTE PTR [rax],al
    1d83:	add    BYTE PTR [rax],al
    1d85:	add    BYTE PTR [rax],al
    1d87:	add    BYTE PTR [rsi],al
    1d89:	add    BYTE PTR [rax],al
    1d8b:	add    BYTE PTR [rax],al
    1d8d:	add    BYTE PTR [rax],al
	...

0000000000001d90 <botlish_entry_12: peek<str, int>>:
    1d90:	push   rbp
    1d91:	mov    rbp,rsp
    1d94:	ud2

0000000000001d96 <botlish_fn_13: scan_unquoted<str, int, int>>:
    1d96:	push   rbp
    1d97:	mov    rbp,rsp
    1d9a:	sub    rsp,0x60
    1d9e:	mov    QWORD PTR [rsp+0x30],rbx
    1da3:	mov    QWORD PTR [rsp+0x38],r12
    1da8:	mov    QWORD PTR [rsp+0x40],r13
    1dad:	mov    QWORD PTR [rsp+0x48],r14
    1db2:	mov    QWORD PTR [rsp+0x50],r15
    1db7:	mov    r14,QWORD PTR [rdi]
    1dba:	mov    rax,QWORD PTR [rdi+0x8]
    1dbe:	lea    r8,[r14+0x20]
    1dc2:	cmp    r8,rax
    1dc5:	ja     2004 <botlish_fn_13+0x26e>
    1dcb:	lea    rax,[r14+0x20]
    1dcf:	mov    QWORD PTR [rdi],rax
    1dd2:	mov    r15,rdi
    1dd5:	mov    QWORD PTR [r14],0x0
    1ddc:	mov    QWORD PTR [r14+0x8],0x0
    1de4:	mov    QWORD PTR [r14+0x10],0x0
    1dec:	mov    QWORD PTR [r14+0x18],0x0
    1df4:	mov    QWORD PTR [r14],rsi
    1df7:	mov    QWORD PTR [rsp+0x10],rsi
    1dfc:	mov    QWORD PTR [r14+0x8],rdx
    1e00:	mov    QWORD PTR [rsp+0x18],rdx
    1e05:	mov    QWORD PTR [r14+0x10],rcx
    1e09:	lea    rbx,[rsp]
    1e0d:	mov    QWORD PTR [rsp+0x20],rcx
    1e12:	mov    rcx,rbx
    1e15:	mov    rdx,QWORD PTR [rsp+0x20]
    1e1a:	mov    rsi,QWORD PTR [rsp+0x10]
    1e1f:	mov    rdi,r15
    1e22:	call   1e27 <botlish_fn_13+0x91>
			1e23: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1e27:	mov    rcx,rax
    1e2a:	mov    QWORD PTR [rsp+0x28],rax
    1e2f:	test   rax,rcx
    1e32:	jne    1e40 <botlish_fn_13+0xaa>
    1e38:	mov    rdi,r15
    1e3b:	jmp    1fa9 <botlish_fn_13+0x213>
    1e40:	mov    r12,QWORD PTR [rsp]
    1e44:	mov    r13,QWORD PTR [rsp+0x8]
    1e49:	mov    rdi,r15
    1e4c:	mov    rcx,QWORD PTR [rdi+0x10]
    1e50:	mov    r8,QWORD PTR [rcx+0x10]
    1e54:	mov    r9,QWORD PTR [rip+0x0]        # 1e5b <botlish_fn_13+0xc5>
			1e57: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1e5b:	mov    rcx,r13
    1e5e:	mov    rdx,r12
    1e61:	mov    rsi,QWORD PTR [rsp+0x28]
    1e66:	call   r9
    1e69:	cmp    rax,0x6
    1e6d:	je     1eb1 <botlish_fn_13+0x11b>
    1e73:	mov    rdi,r15
    1e76:	mov    rdx,QWORD PTR [rdi+0x10]
    1e7a:	mov    r8,QWORD PTR [rdx+0x18]
    1e7e:	mov    r9,QWORD PTR [rip+0x0]        # 1e85 <botlish_fn_13+0xef>
			1e81: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1e85:	mov    rcx,r13
    1e88:	mov    rdx,r12
    1e8b:	mov    rsi,QWORD PTR [rsp+0x28]
    1e90:	call   r9
    1e93:	cmp    rax,0x6
    1e97:	je     1ea7 <botlish_fn_13+0x111>
    1e9d:	mov    eax,0x2
    1ea2:	jmp    1eb6 <botlish_fn_13+0x120>
    1ea7:	mov    eax,0x6
    1eac:	jmp    1eb6 <botlish_fn_13+0x120>
    1eb1:	mov    eax,0x6
    1eb6:	cmp    rax,0x6
    1eba:	je     1efe <botlish_fn_13+0x168>
    1ec0:	mov    rdi,r15
    1ec3:	mov    r10,QWORD PTR [rdi+0x10]
    1ec7:	mov    r8,QWORD PTR [r10+0x20]
    1ecb:	mov    r10,QWORD PTR [rip+0x0]        # 1ed2 <botlish_fn_13+0x13c>
			1ece: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1ed2:	mov    rcx,r13
    1ed5:	mov    rdx,r12
    1ed8:	mov    rsi,QWORD PTR [rsp+0x28]
    1edd:	call   r10
    1ee0:	cmp    rax,0x6
    1ee4:	je     1ef4 <botlish_fn_13+0x15e>
    1eea:	mov    eax,0x2
    1eef:	jmp    1f03 <botlish_fn_13+0x16d>
    1ef4:	mov    eax,0x6
    1ef9:	jmp    1f03 <botlish_fn_13+0x16d>
    1efe:	mov    eax,0x6
    1f03:	cmp    rax,0x6
    1f07:	je     1f82 <botlish_fn_13+0x1ec>
    1f0d:	mov    QWORD PTR [r14+0x18],0x3
    1f15:	mov    rsi,QWORD PTR [rsp+0x20]
    1f1a:	test   rsi,0x1
    1f21:	je     1f48 <botlish_fn_13+0x1b2>
    1f27:	mov    rsi,QWORD PTR [rsp+0x20]
    1f2c:	mov    rax,rsi
    1f2f:	add    rax,0x2
    1f33:	seto   cl
    1f36:	test   cl,cl
    1f38:	jne    1f48 <botlish_fn_13+0x1b2>
    1f3e:	mov    rsi,QWORD PTR [rsp+0x10]
    1f43:	jmp    1f63 <botlish_fn_13+0x1cd>
    1f48:	mov    edx,0x3
    1f4d:	mov    rax,QWORD PTR [rip+0x0]        # 1f54 <botlish_fn_13+0x1be>
			1f50: R_X86_64_GOTPCREL	rt_int_add-0x4
    1f54:	mov    rsi,QWORD PTR [rsp+0x20]
    1f59:	mov    rdi,r15
    1f5c:	call   rax
    1f5e:	mov    rsi,QWORD PTR [rsp+0x10]
    1f63:	mov    QWORD PTR [r14],rsi
    1f66:	mov    rdx,QWORD PTR [rsp+0x18]
    1f6b:	mov    QWORD PTR [r14+0x8],rdx
    1f6f:	mov    QWORD PTR [r14+0x10],rax
    1f73:	mov    QWORD PTR [rsp+0x10],rsi
    1f78:	mov    QWORD PTR [rsp+0x20],rax
    1f7d:	jmp    1e12 <botlish_fn_13+0x7c>
    1f82:	mov    rdx,QWORD PTR [rsp+0x18]
    1f87:	mov    rsi,QWORD PTR [rsp+0x10]
    1f8c:	mov    rax,QWORD PTR [rip+0x0]        # 1f93 <botlish_fn_13+0x1fd>
			1f8f: R_X86_64_GOTPCREL	rt_substr-0x4
    1f93:	mov    rcx,QWORD PTR [rsp+0x20]
    1f98:	mov    rdi,r15
    1f9b:	call   rax
    1f9d:	test   rax,rax
    1fa0:	jne    1fd7 <botlish_fn_13+0x241>
    1fa6:	mov    rdi,r15
    1fa9:	mov    rdi,r15
    1fac:	mov    QWORD PTR [rdi],r14
    1faf:	xor    rdx,rdx
    1fb2:	mov    rax,rdx
    1fb5:	mov    rbx,QWORD PTR [rsp+0x30]
    1fba:	mov    r12,QWORD PTR [rsp+0x38]
    1fbf:	mov    r13,QWORD PTR [rsp+0x40]
    1fc4:	mov    r14,QWORD PTR [rsp+0x48]
    1fc9:	mov    r15,QWORD PTR [rsp+0x50]
    1fce:	add    rsp,0x60
    1fd2:	mov    rsp,rbp
    1fd5:	pop    rbp
    1fd6:	ret
    1fd7:	mov    rdi,r15
    1fda:	mov    QWORD PTR [rdi],r14
    1fdd:	mov    rdx,QWORD PTR [rsp+0x20]
    1fe2:	mov    rbx,QWORD PTR [rsp+0x30]
    1fe7:	mov    r12,QWORD PTR [rsp+0x38]
    1fec:	mov    r13,QWORD PTR [rsp+0x40]
    1ff1:	mov    r14,QWORD PTR [rsp+0x48]
    1ff6:	mov    r15,QWORD PTR [rsp+0x50]
    1ffb:	add    rsp,0x60
    1fff:	mov    rsp,rbp
    2002:	pop    rbp
    2003:	ret
    2004:	mov    r15,rdi
    2007:	mov    rax,QWORD PTR [rip+0x0]        # 200e <botlish_fn_13+0x278>
			200a: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    200e:	call   rax
    2010:	xor    rdx,rdx
    2013:	mov    rax,rdx
    2016:	mov    rbx,QWORD PTR [rsp+0x30]
    201b:	mov    r12,QWORD PTR [rsp+0x38]
    2020:	mov    r13,QWORD PTR [rsp+0x40]
    2025:	mov    r14,QWORD PTR [rsp+0x48]
    202a:	mov    r15,QWORD PTR [rsp+0x50]
    202f:	add    rsp,0x60
    2033:	mov    rsp,rbp
    2036:	pop    rbp
    2037:	ret

0000000000002038 <botlish_entry_13: scan_unquoted<str, int, int>>:
    2038:	push   rbp
    2039:	mov    rbp,rsp
    203c:	ud2

000000000000203e <botlish_fn_14: scan_quoted<str, int, str>>:
    203e:	push   rbp
    203f:	mov    rbp,rsp
    2042:	sub    rsp,0x50
    2046:	mov    QWORD PTR [rsp+0x20],rbx
    204b:	mov    QWORD PTR [rsp+0x28],r12
    2050:	mov    QWORD PTR [rsp+0x30],r13
    2055:	mov    QWORD PTR [rsp+0x38],r14
    205a:	mov    QWORD PTR [rsp+0x40],r15
    205f:	mov    r13,QWORD PTR [rdi]
    2062:	mov    rax,QWORD PTR [rdi+0x8]
    2066:	lea    r8,[r13+0x28]
    206a:	cmp    r8,rax
    206d:	ja     237a <botlish_fn_14+0x33c>
    2073:	lea    rax,[r13+0x28]
    2077:	mov    QWORD PTR [rdi],rax
    207a:	mov    r14,rdi
    207d:	mov    QWORD PTR [r13+0x0],0x0
    2085:	mov    QWORD PTR [r13+0x8],0x0
    208d:	mov    QWORD PTR [r13+0x10],0x0
    2095:	mov    QWORD PTR [r13+0x18],0x0
    209d:	mov    QWORD PTR [r13+0x20],0x0
    20a5:	mov    QWORD PTR [r13+0x0],rsi
    20a9:	mov    QWORD PTR [r13+0x8],rdx
    20ad:	mov    QWORD PTR [r13+0x10],rcx
    20b1:	lea    r12,[rsp]
    20b5:	mov    rbx,rsi
    20b8:	mov    r15,rdx
    20bb:	mov    QWORD PTR [rsp+0x10],rcx
    20c0:	mov    rdx,r15
    20c3:	mov    rsi,rbx
    20c6:	mov    rdi,r14
    20c9:	call   20ce <botlish_fn_14+0x90>
			20ca: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    20ce:	test   rax,rax
    20d1:	jne    20df <botlish_fn_14+0xa1>
    20d7:	mov    rdi,r14
    20da:	jmp    2333 <botlish_fn_14+0x2f5>
    20df:	mov    QWORD PTR [r13+0x18],rax
    20e3:	mov    rdi,r14
    20e6:	mov    QWORD PTR [rsp+0x18],rax
    20eb:	mov    rcx,QWORD PTR [rdi+0x10]
    20ef:	mov    rsi,QWORD PTR [rcx+0x28]
    20f3:	mov    edx,0x1
    20f8:	mov    ecx,0x3
    20fd:	mov    r9,QWORD PTR [rip+0x0]        # 2104 <botlish_fn_14+0xc6>
			2100: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    2104:	mov    r8,QWORD PTR [rsp+0x18]
    2109:	call   r9
    210c:	cmp    rax,0x6
    2110:	je     21a3 <botlish_fn_14+0x165>
    2116:	mov    QWORD PTR [r13+0x20],0x3
    211e:	mov    rsi,r15
    2121:	test   rsi,0x1
    2128:	je     2148 <botlish_fn_14+0x10a>
    212e:	mov    rax,rsi
    2131:	add    rax,0x2
    2135:	seto   cl
    2138:	test   cl,cl
    213a:	jne    2148 <botlish_fn_14+0x10a>
    2140:	mov    rsi,rax
    2143:	jmp    215c <botlish_fn_14+0x11e>
    2148:	mov    edx,0x3
    214d:	mov    rax,QWORD PTR [rip+0x0]        # 2154 <botlish_fn_14+0x116>
			2150: R_X86_64_GOTPCREL	rt_int_add-0x4
    2154:	mov    rdi,r14
    2157:	call   rax
    2159:	mov    rsi,rax
    215c:	mov    QWORD PTR [r13+0x8],rsi
    2160:	mov    r15,rsi
    2163:	mov    rax,QWORD PTR [rip+0x0]        # 216a <botlish_fn_14+0x12c>
			2166: R_X86_64_GOTPCREL	rt_str_cat-0x4
    216a:	mov    rdx,QWORD PTR [rsp+0x18]
    216f:	mov    rsi,QWORD PTR [rsp+0x10]
    2174:	mov    rdi,r14
    2177:	call   rax
    2179:	test   rax,rax
    217c:	jne    218a <botlish_fn_14+0x14c>
    2182:	mov    rdi,r14
    2185:	jmp    2333 <botlish_fn_14+0x2f5>
    218a:	mov    QWORD PTR [r13+0x0],rbx
    218e:	mov    rsi,r15
    2191:	mov    QWORD PTR [r13+0x8],rsi
    2195:	mov    QWORD PTR [r13+0x10],rax
    2199:	mov    QWORD PTR [rsp+0x10],rax
    219e:	jmp    20c0 <botlish_fn_14+0x82>
    21a3:	mov    QWORD PTR [r13+0x18],0x3
    21ab:	mov    rsi,r15
    21ae:	test   rsi,0x1
    21b5:	je     21d0 <botlish_fn_14+0x192>
    21bb:	mov    rsi,r15
    21be:	mov    rdx,rsi
    21c1:	add    rdx,0x2
    21c5:	seto   al
    21c8:	test   al,al
    21ca:	je     21e7 <botlish_fn_14+0x1a9>
    21d0:	mov    edx,0x3
    21d5:	mov    rax,QWORD PTR [rip+0x0]        # 21dc <botlish_fn_14+0x19e>
			21d8: R_X86_64_GOTPCREL	rt_int_add-0x4
    21dc:	mov    rsi,r15
    21df:	mov    rdi,r14
    21e2:	call   rax
    21e4:	mov    rdx,rax
    21e7:	mov    QWORD PTR [r13+0x18],rdx
    21eb:	mov    rcx,r12
    21ee:	mov    rsi,rbx
    21f1:	mov    rdi,r14
    21f4:	call   21f9 <botlish_fn_14+0x1bb>
			21f5: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    21f9:	test   rax,rax
    21fc:	mov    rsi,rax
    21ff:	jne    220d <botlish_fn_14+0x1cf>
    2205:	mov    rdi,r14
    2208:	jmp    2333 <botlish_fn_14+0x2f5>
    220d:	mov    rdx,QWORD PTR [rsp]
    2211:	mov    rcx,QWORD PTR [rsp+0x8]
    2216:	mov    rdi,r14
    2219:	mov    rax,QWORD PTR [rdi+0x10]
    221d:	mov    r8,QWORD PTR [rax+0x28]
    2221:	mov    rax,QWORD PTR [rip+0x0]        # 2228 <botlish_fn_14+0x1ea>
			2224: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    2228:	call   rax
    222a:	cmp    rax,0x6
    222e:	je     22b0 <botlish_fn_14+0x272>
    2234:	mov    QWORD PTR [r13+0x0],0x3
    223c:	mov    rsi,r15
    223f:	test   rsi,0x1
    2246:	je     2269 <botlish_fn_14+0x22b>
    224c:	mov    rsi,r15
    224f:	mov    rdx,rsi
    2252:	add    rdx,0x2
    2256:	seto   al
    2259:	test   al,al
    225b:	jne    2269 <botlish_fn_14+0x22b>
    2261:	mov    rdi,r14
    2264:	jmp    2283 <botlish_fn_14+0x245>
    2269:	mov    edx,0x3
    226e:	mov    rax,QWORD PTR [rip+0x0]        # 2275 <botlish_fn_14+0x237>
			2271: R_X86_64_GOTPCREL	rt_int_add-0x4
    2275:	mov    rsi,r15
    2278:	mov    rdi,r14
    227b:	call   rax
    227d:	mov    rdx,rax
    2280:	mov    rdi,r14
    2283:	mov    rdi,r14
    2286:	mov    QWORD PTR [rdi],r13
    2289:	mov    rax,QWORD PTR [rsp+0x10]
    228e:	mov    rbx,QWORD PTR [rsp+0x20]
    2293:	mov    r12,QWORD PTR [rsp+0x28]
    2298:	mov    r13,QWORD PTR [rsp+0x30]
    229d:	mov    r14,QWORD PTR [rsp+0x38]
    22a2:	mov    r15,QWORD PTR [rsp+0x40]
    22a7:	add    rsp,0x50
    22ab:	mov    rsp,rbp
    22ae:	pop    rbp
    22af:	ret
    22b0:	mov    QWORD PTR [r13+0x18],0x5
    22b8:	mov    rsi,r15
    22bb:	test   rsi,0x1
    22c2:	je     22ea <botlish_fn_14+0x2ac>
    22c8:	mov    rsi,r15
    22cb:	mov    rcx,rsi
    22ce:	add    rcx,0x4
    22d2:	seto   sil
    22d6:	test   sil,sil
    22d9:	jne    22ea <botlish_fn_14+0x2ac>
    22df:	mov    rsi,rcx
    22e2:	mov    r15,rcx
    22e5:	jmp    2305 <botlish_fn_14+0x2c7>
    22ea:	mov    edx,0x5
    22ef:	mov    r8,QWORD PTR [rip+0x0]        # 22f6 <botlish_fn_14+0x2b8>
			22f2: R_X86_64_GOTPCREL	rt_int_add-0x4
    22f6:	mov    rsi,r15
    22f9:	mov    rdi,r14
    22fc:	call   r8
    22ff:	mov    rsi,rax
    2302:	mov    r15,rax
    2305:	mov    QWORD PTR [r13+0x8],rsi
    2309:	mov    rdi,r14
    230c:	mov    r8,QWORD PTR [rdi+0x10]
    2310:	mov    rdx,QWORD PTR [r8+0x28]
    2314:	mov    QWORD PTR [r13+0x18],rdx
    2318:	mov    r9,QWORD PTR [rip+0x0]        # 231f <botlish_fn_14+0x2e1>
			231b: R_X86_64_GOTPCREL	rt_str_cat-0x4
    231f:	mov    rsi,QWORD PTR [rsp+0x10]
    2324:	call   r9
    2327:	test   rax,rax
    232a:	jne    2361 <botlish_fn_14+0x323>
    2330:	mov    rdi,r14
    2333:	mov    rdi,r14
    2336:	mov    QWORD PTR [rdi],r13
    2339:	xor    rdx,rdx
    233c:	mov    rax,rdx
    233f:	mov    rbx,QWORD PTR [rsp+0x20]
    2344:	mov    r12,QWORD PTR [rsp+0x28]
    2349:	mov    r13,QWORD PTR [rsp+0x30]
    234e:	mov    r14,QWORD PTR [rsp+0x38]
    2353:	mov    r15,QWORD PTR [rsp+0x40]
    2358:	add    rsp,0x50
    235c:	mov    rsp,rbp
    235f:	pop    rbp
    2360:	ret
    2361:	mov    QWORD PTR [r13+0x0],rbx
    2365:	mov    rsi,r15
    2368:	mov    QWORD PTR [r13+0x8],rsi
    236c:	mov    QWORD PTR [r13+0x10],rax
    2370:	mov    QWORD PTR [rsp+0x10],rax
    2375:	jmp    20c0 <botlish_fn_14+0x82>
    237a:	mov    r14,rdi
    237d:	mov    rax,QWORD PTR [rip+0x0]        # 2384 <botlish_fn_14+0x346>
			2380: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2384:	call   rax
    2386:	xor    rdx,rdx
    2389:	mov    rax,rdx
    238c:	mov    rbx,QWORD PTR [rsp+0x20]
    2391:	mov    r12,QWORD PTR [rsp+0x28]
    2396:	mov    r13,QWORD PTR [rsp+0x30]
    239b:	mov    r14,QWORD PTR [rsp+0x38]
    23a0:	mov    r15,QWORD PTR [rsp+0x40]
    23a5:	add    rsp,0x50
    23a9:	mov    rsp,rbp
    23ac:	pop    rbp
    23ad:	ret

00000000000023ae <botlish_entry_14: scan_quoted<str, int, str>>:
    23ae:	push   rbp
    23af:	mov    rbp,rsp
    23b2:	ud2

00000000000023b4 <botlish_fn_15: scan_field<str, int>>:
    23b4:	push   rbp
    23b5:	mov    rbp,rsp
    23b8:	sub    rsp,0x30
    23bc:	mov    QWORD PTR [rsp+0x10],rbx
    23c1:	mov    QWORD PTR [rsp+0x18],r12
    23c6:	mov    QWORD PTR [rsp+0x20],r13
    23cb:	mov    QWORD PTR [rsp+0x28],r14
    23d0:	mov    rbx,QWORD PTR [rdi]
    23d3:	mov    rax,QWORD PTR [rdi+0x8]
    23d7:	lea    rcx,[rbx+0x18]
    23db:	cmp    rcx,rax
    23de:	ja     2558 <botlish_fn_15+0x1a4>
    23e4:	lea    rax,[rbx+0x18]
    23e8:	mov    QWORD PTR [rdi],rax
    23eb:	mov    r12,rdi
    23ee:	mov    QWORD PTR [rbx],0x0
    23f5:	mov    QWORD PTR [rbx+0x8],0x0
    23fd:	mov    QWORD PTR [rbx+0x10],0x0
    2405:	mov    QWORD PTR [rbx],rsi
    2408:	mov    r13,rsi
    240b:	mov    QWORD PTR [rbx+0x8],rdx
    240f:	mov    r14,rdx
    2412:	lea    rcx,[rsp]
    2416:	mov    rdx,r14
    2419:	mov    rsi,r13
    241c:	mov    rdi,r12
    241f:	call   2424 <botlish_fn_15+0x70>
			2420: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    2424:	test   rax,rax
    2427:	mov    rsi,rax
    242a:	jne    2438 <botlish_fn_15+0x84>
    2430:	mov    rdi,r12
    2433:	jmp    250c <botlish_fn_15+0x158>
    2438:	mov    rdx,QWORD PTR [rsp]
    243c:	mov    rcx,QWORD PTR [rsp+0x8]
    2441:	mov    rdi,r12
    2444:	mov    rax,QWORD PTR [rdi+0x10]
    2448:	mov    r8,QWORD PTR [rax+0x28]
    244c:	mov    rax,QWORD PTR [rip+0x0]        # 2453 <botlish_fn_15+0x9f>
			244f: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    2453:	call   rax
    2455:	cmp    rax,0x6
    2459:	je     24a4 <botlish_fn_15+0xf0>
    245f:	mov    rcx,r14
    2462:	mov    rsi,r13
    2465:	mov    rdi,r12
    2468:	mov    rdx,rcx
    246b:	call   2470 <botlish_fn_15+0xbc>
			246c: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    2470:	test   rax,rax
    2473:	jne    2481 <botlish_fn_15+0xcd>
    2479:	mov    rdi,r12
    247c:	jmp    250c <botlish_fn_15+0x158>
    2481:	mov    rdi,r12
    2484:	mov    QWORD PTR [rdi],rbx
    2487:	mov    rbx,QWORD PTR [rsp+0x10]
    248c:	mov    r12,QWORD PTR [rsp+0x18]
    2491:	mov    r13,QWORD PTR [rsp+0x20]
    2496:	mov    r14,QWORD PTR [rsp+0x28]
    249b:	add    rsp,0x30
    249f:	mov    rsp,rbp
    24a2:	pop    rbp
    24a3:	ret
    24a4:	mov    QWORD PTR [rbx+0x10],0x3
    24ac:	mov    rdx,r14
    24af:	test   rdx,0x1
    24b6:	je     24ce <botlish_fn_15+0x11a>
    24bc:	mov    rdx,r14
    24bf:	add    rdx,0x2
    24c3:	seto   al
    24c6:	test   al,al
    24c8:	je     24e5 <botlish_fn_15+0x131>
    24ce:	mov    edx,0x3
    24d3:	mov    rax,QWORD PTR [rip+0x0]        # 24da <botlish_fn_15+0x126>
			24d6: R_X86_64_GOTPCREL	rt_int_add-0x4
    24da:	mov    rsi,r14
    24dd:	mov    rdi,r12
    24e0:	call   rax
    24e2:	mov    rdx,rax
    24e5:	mov    QWORD PTR [rbx+0x8],rdx
    24e9:	mov    rdi,r12
    24ec:	mov    rax,QWORD PTR [rdi+0x10]
    24f0:	mov    rcx,QWORD PTR [rax+0x10]
    24f4:	mov    QWORD PTR [rbx+0x10],rcx
    24f8:	mov    rsi,r13
    24fb:	call   2500 <botlish_fn_15+0x14c>
			24fc: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    2500:	test   rax,rax
    2503:	jne    2535 <botlish_fn_15+0x181>
    2509:	mov    rdi,r12
    250c:	mov    rdi,r12
    250f:	mov    QWORD PTR [rdi],rbx
    2512:	xor    rdx,rdx
    2515:	mov    rax,rdx
    2518:	mov    rbx,QWORD PTR [rsp+0x10]
    251d:	mov    r12,QWORD PTR [rsp+0x18]
    2522:	mov    r13,QWORD PTR [rsp+0x20]
    2527:	mov    r14,QWORD PTR [rsp+0x28]
    252c:	add    rsp,0x30
    2530:	mov    rsp,rbp
    2533:	pop    rbp
    2534:	ret
    2535:	mov    rdi,r12
    2538:	mov    QWORD PTR [rdi],rbx
    253b:	mov    rbx,QWORD PTR [rsp+0x10]
    2540:	mov    r12,QWORD PTR [rsp+0x18]
    2545:	mov    r13,QWORD PTR [rsp+0x20]
    254a:	mov    r14,QWORD PTR [rsp+0x28]
    254f:	add    rsp,0x30
    2553:	mov    rsp,rbp
    2556:	pop    rbp
    2557:	ret
    2558:	mov    r12,rdi
    255b:	mov    rsi,QWORD PTR [rip+0x0]        # 2562 <botlish_fn_15+0x1ae>
			255e: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2562:	call   rsi
    2564:	xor    rdx,rdx
    2567:	mov    rax,rdx
    256a:	mov    rbx,QWORD PTR [rsp+0x10]
    256f:	mov    r12,QWORD PTR [rsp+0x18]
    2574:	mov    r13,QWORD PTR [rsp+0x20]
    2579:	mov    r14,QWORD PTR [rsp+0x28]
    257e:	add    rsp,0x30
    2582:	mov    rsp,rbp
    2585:	pop    rbp
    2586:	ret

0000000000002587 <botlish_entry_15: scan_field<str, int>>:
    2587:	push   rbp
    2588:	mov    rbp,rsp
    258b:	ud2

000000000000258d <botlish_fn_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    258d:	push   rbp
    258e:	mov    rbp,rsp
    2591:	sub    rsp,0x80
    2598:	mov    QWORD PTR [rsp+0x50],rbx
    259d:	mov    QWORD PTR [rsp+0x58],r12
    25a2:	mov    QWORD PTR [rsp+0x60],r13
    25a7:	mov    QWORD PTR [rsp+0x68],r14
    25ac:	mov    QWORD PTR [rsp+0x70],r15
    25b1:	mov    rbx,QWORD PTR [rdi]
    25b4:	mov    rax,QWORD PTR [rdi+0x8]
    25b8:	lea    r10,[rbx+0x30]
    25bc:	cmp    r10,rax
    25bf:	ja     28eb <botlish_fn_16+0x35e>
    25c5:	lea    rax,[rbx+0x30]
    25c9:	mov    QWORD PTR [rdi],rax
    25cc:	mov    r13,rdi
    25cf:	mov    QWORD PTR [rbx],0x0
    25d6:	mov    QWORD PTR [rbx+0x8],0x0
    25de:	mov    QWORD PTR [rbx+0x10],0x0
    25e6:	mov    QWORD PTR [rbx+0x18],0x0
    25ee:	mov    QWORD PTR [rbx+0x20],0x0
    25f6:	mov    QWORD PTR [rbx+0x28],0x0
    25fe:	mov    QWORD PTR [rbx],rsi
    2601:	mov    QWORD PTR [rsp+0x20],rsi
    2606:	mov    QWORD PTR [rbx+0x8],rdx
    260a:	mov    QWORD PTR [rbx+0x10],rcx
    260e:	mov    QWORD PTR [rsp+0x28],rcx
    2613:	mov    QWORD PTR [rbx+0x18],r8
    2617:	mov    r12,r8
    261a:	mov    QWORD PTR [rbx+0x20],r9
    261e:	mov    r15,r9
    2621:	mov    rsi,QWORD PTR [rsp+0x20]
    2626:	mov    rdi,r13
    2629:	call   262e <botlish_fn_16+0xa1>
			262a: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    262e:	test   rax,rax
    2631:	jne    263f <botlish_fn_16+0xb2>
    2637:	mov    rdi,r13
    263a:	jmp    288f <botlish_fn_16+0x302>
    263f:	mov    QWORD PTR [rbx+0x8],rax
    2643:	mov    r8,rax
    2646:	mov    QWORD PTR [rbx+0x28],rdx
    264a:	mov    r14,rdx
    264d:	lea    r9,[rsp]
    2651:	mov    rcx,r15
    2654:	mov    rdx,r12
    2657:	mov    rsi,QWORD PTR [rsp+0x28]
    265c:	mov    rdi,r13
    265f:	call   2664 <botlish_fn_16+0xd7>
			2660: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[list<never>, mutarray, int], str>
    2664:	test   rax,rax
    2667:	jne    2675 <botlish_fn_16+0xe8>
    266d:	mov    rdi,r13
    2670:	jmp    288f <botlish_fn_16+0x302>
    2675:	mov    QWORD PTR [rbx+0x8],rax
    2679:	mov    QWORD PTR [rsp+0x40],rax
    267e:	mov    rdx,QWORD PTR [rsp]
    2682:	mov    QWORD PTR [rbx+0x10],rdx
    2686:	mov    QWORD PTR [rsp+0x38],rdx
    268b:	mov    rcx,QWORD PTR [rsp+0x8]
    2690:	mov    QWORD PTR [rbx+0x18],rcx
    2694:	mov    QWORD PTR [rsp+0x30],rcx
    2699:	lea    rcx,[rsp+0x10]
    269e:	mov    rdx,r14
    26a1:	mov    rsi,QWORD PTR [rsp+0x20]
    26a6:	mov    rdi,r13
    26a9:	call   26ae <botlish_fn_16+0x121>
			26aa: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    26ae:	test   rax,rax
    26b1:	mov    QWORD PTR [rsp+0x28],rax
    26b6:	jne    26c4 <botlish_fn_16+0x137>
    26bc:	mov    rdi,r13
    26bf:	jmp    288f <botlish_fn_16+0x302>
    26c4:	mov    r12,QWORD PTR [rsp+0x10]
    26c9:	mov    r15,QWORD PTR [rsp+0x18]
    26ce:	mov    rdi,r13
    26d1:	mov    rcx,QWORD PTR [rdi+0x10]
    26d5:	mov    r8,QWORD PTR [rcx+0x18]
    26d9:	mov    r9,QWORD PTR [rip+0x0]        # 26e0 <botlish_fn_16+0x153>
			26dc: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    26e0:	mov    rcx,r15
    26e3:	mov    rdx,r12
    26e6:	mov    rsi,QWORD PTR [rsp+0x28]
    26eb:	call   r9
    26ee:	cmp    rax,0x6
    26f2:	je     281f <botlish_fn_16+0x292>
    26f8:	mov    rdi,r13
    26fb:	mov    rax,QWORD PTR [rdi+0x10]
    26ff:	mov    r8,QWORD PTR [rax+0x20]
    2703:	mov    rax,QWORD PTR [rip+0x0]        # 270a <botlish_fn_16+0x17d>
			2706: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    270a:	mov    rcx,r15
    270d:	mov    rdx,r12
    2710:	mov    rsi,QWORD PTR [rsp+0x28]
    2715:	call   rax
    2717:	cmp    rax,0x6
    271b:	je     2777 <botlish_fn_16+0x1ea>
    2721:	mov    rcx,QWORD PTR [rsp+0x30]
    2726:	mov    rdx,QWORD PTR [rsp+0x38]
    272b:	mov    rsi,QWORD PTR [rsp+0x40]
    2730:	mov    rdi,r13
    2733:	call   2738 <botlish_fn_16+0x1ab>
			2734: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2738:	test   rax,rax
    273b:	jne    2749 <botlish_fn_16+0x1bc>
    2741:	mov    rdi,r13
    2744:	jmp    288f <botlish_fn_16+0x302>
    2749:	mov    rdi,r13
    274c:	mov    QWORD PTR [rdi],rbx
    274f:	mov    rdx,r14
    2752:	mov    rbx,QWORD PTR [rsp+0x50]
    2757:	mov    r12,QWORD PTR [rsp+0x58]
    275c:	mov    r13,QWORD PTR [rsp+0x60]
    2761:	mov    r14,QWORD PTR [rsp+0x68]
    2766:	mov    r15,QWORD PTR [rsp+0x70]
    276b:	add    rsp,0x80
    2772:	mov    rsp,rbp
    2775:	pop    rbp
    2776:	ret
    2777:	mov    rcx,QWORD PTR [rsp+0x30]
    277c:	mov    rdx,QWORD PTR [rsp+0x38]
    2781:	mov    rsi,QWORD PTR [rsp+0x40]
    2786:	mov    rdi,r13
    2789:	call   278e <botlish_fn_16+0x201>
			278a: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    278e:	test   rax,rax
    2791:	jne    279f <botlish_fn_16+0x212>
    2797:	mov    rdi,r13
    279a:	jmp    288f <botlish_fn_16+0x302>
    279f:	mov    QWORD PTR [rbx],rax
    27a2:	mov    r12,rax
    27a5:	mov    QWORD PTR [rbx+0x8],0x3
    27ad:	mov    rdx,r14
    27b0:	test   rdx,0x1
    27b7:	je     27d7 <botlish_fn_16+0x24a>
    27bd:	mov    rdx,r14
    27c0:	add    rdx,0x2
    27c4:	seto   al
    27c7:	test   al,al
    27c9:	jne    27d7 <botlish_fn_16+0x24a>
    27cf:	mov    rdi,r13
    27d2:	jmp    27f1 <botlish_fn_16+0x264>
    27d7:	mov    edx,0x3
    27dc:	mov    rax,QWORD PTR [rip+0x0]        # 27e3 <botlish_fn_16+0x256>
			27df: R_X86_64_GOTPCREL	rt_int_add-0x4
    27e3:	mov    rsi,r14
    27e6:	mov    rdi,r13
    27e9:	call   rax
    27eb:	mov    rdx,rax
    27ee:	mov    rdi,r13
    27f1:	mov    rdi,r13
    27f4:	mov    QWORD PTR [rdi],rbx
    27f7:	mov    rax,r12
    27fa:	mov    rbx,QWORD PTR [rsp+0x50]
    27ff:	mov    r12,QWORD PTR [rsp+0x58]
    2804:	mov    r13,QWORD PTR [rsp+0x60]
    2809:	mov    r14,QWORD PTR [rsp+0x68]
    280e:	mov    r15,QWORD PTR [rsp+0x70]
    2813:	add    rsp,0x80
    281a:	mov    rsp,rbp
    281d:	pop    rbp
    281e:	ret
    281f:	mov    rsi,r14
    2822:	mov    edx,0x3
    2827:	mov    rcx,rdx
    282a:	mov    QWORD PTR [rbx+0x20],0x3
    2832:	test   rsi,0x1
    2839:	je     2851 <botlish_fn_16+0x2c4>
    283f:	mov    rdx,rsi
    2842:	add    rdx,0x2
    2846:	seto   al
    2849:	test   al,al
    284b:	je     2863 <botlish_fn_16+0x2d6>
    2851:	mov    rax,QWORD PTR [rip+0x0]        # 2858 <botlish_fn_16+0x2cb>
			2854: R_X86_64_GOTPCREL	rt_int_add-0x4
    2858:	mov    rdx,rcx
    285b:	mov    rdi,r13
    285e:	call   rax
    2860:	mov    rdx,rax
    2863:	mov    QWORD PTR [rbx+0x20],rdx
    2867:	mov    rcx,QWORD PTR [rsp+0x40]
    286c:	mov    rsi,QWORD PTR [rsp+0x20]
    2871:	mov    r8,QWORD PTR [rsp+0x38]
    2876:	mov    r9,QWORD PTR [rsp+0x30]
    287b:	mov    rdi,r13
    287e:	call   2883 <botlish_fn_16+0x2f6>
			287f: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int, list[list<mutarray>, mutarray, int]>
    2883:	test   rax,rax
    2886:	jne    28c0 <botlish_fn_16+0x333>
    288c:	mov    rdi,r13
    288f:	mov    rdi,r13
    2892:	mov    QWORD PTR [rdi],rbx
    2895:	xor    rdx,rdx
    2898:	mov    rax,rdx
    289b:	mov    rbx,QWORD PTR [rsp+0x50]
    28a0:	mov    r12,QWORD PTR [rsp+0x58]
    28a5:	mov    r13,QWORD PTR [rsp+0x60]
    28aa:	mov    r14,QWORD PTR [rsp+0x68]
    28af:	mov    r15,QWORD PTR [rsp+0x70]
    28b4:	add    rsp,0x80
    28bb:	mov    rsp,rbp
    28be:	pop    rbp
    28bf:	ret
    28c0:	mov    rdi,r13
    28c3:	mov    QWORD PTR [rdi],rbx
    28c6:	mov    rbx,QWORD PTR [rsp+0x50]
    28cb:	mov    r12,QWORD PTR [rsp+0x58]
    28d0:	mov    r13,QWORD PTR [rsp+0x60]
    28d5:	mov    r14,QWORD PTR [rsp+0x68]
    28da:	mov    r15,QWORD PTR [rsp+0x70]
    28df:	add    rsp,0x80
    28e6:	mov    rsp,rbp
    28e9:	pop    rbp
    28ea:	ret
    28eb:	mov    r13,rdi
    28ee:	mov    rax,QWORD PTR [rip+0x0]        # 28f5 <botlish_fn_16+0x368>
			28f1: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    28f5:	call   rax
    28f7:	xor    rdx,rdx
    28fa:	mov    rax,rdx
    28fd:	mov    rbx,QWORD PTR [rsp+0x50]
    2902:	mov    r12,QWORD PTR [rsp+0x58]
    2907:	mov    r13,QWORD PTR [rsp+0x60]
    290c:	mov    r14,QWORD PTR [rsp+0x68]
    2911:	mov    r15,QWORD PTR [rsp+0x70]
    2916:	add    rsp,0x80
    291d:	mov    rsp,rbp
    2920:	pop    rbp
    2921:	ret

0000000000002922 <botlish_entry_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    2922:	push   rbp
    2923:	mov    rbp,rsp
    2926:	ud2

0000000000002928 <botlish_fn_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    2928:	push   rbp
    2929:	mov    rbp,rsp
    292c:	sub    rsp,0x90
    2933:	mov    QWORD PTR [rsp+0x60],rbx
    2938:	mov    QWORD PTR [rsp+0x68],r12
    293d:	mov    QWORD PTR [rsp+0x70],r13
    2942:	mov    QWORD PTR [rsp+0x78],r14
    2947:	mov    QWORD PTR [rsp+0x80],r15
    294f:	mov    r14,QWORD PTR [rdi]
    2952:	mov    rax,QWORD PTR [rdi+0x8]
    2956:	lea    r10,[r14+0x30]
    295a:	cmp    r10,rax
    295d:	ja     2ca6 <botlish_fn_17+0x37e>
    2963:	lea    rax,[r14+0x30]
    2967:	mov    QWORD PTR [rdi],rax
    296a:	mov    QWORD PTR [rsp+0x20],rdi
    296f:	mov    QWORD PTR [r14],0x0
    2976:	mov    QWORD PTR [r14+0x8],0x0
    297e:	mov    QWORD PTR [r14+0x10],0x0
    2986:	mov    QWORD PTR [r14+0x18],0x0
    298e:	mov    QWORD PTR [r14+0x20],0x0
    2996:	mov    QWORD PTR [r14+0x28],0x0
    299e:	mov    QWORD PTR [r14],rsi
    29a1:	mov    QWORD PTR [r14+0x8],rdx
    29a5:	mov    QWORD PTR [r14+0x10],rcx
    29a9:	mov    QWORD PTR [r14+0x18],r8
    29ad:	mov    QWORD PTR [r14+0x20],r9
    29b1:	lea    r12,[rsp]
    29b5:	mov    QWORD PTR [rsp+0x50],r12
    29ba:	lea    r12,[rsp+0x10]
    29bf:	mov    rbx,rcx
    29c2:	mov    r13,rsi
    29c5:	mov    QWORD PTR [rsp+0x28],r8
    29ca:	mov    QWORD PTR [rsp+0x30],r9
    29cf:	mov    rsi,r13
    29d2:	mov    rdi,QWORD PTR [rsp+0x20]
    29d7:	call   29dc <botlish_fn_17+0xb4>
			29d8: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    29dc:	mov    QWORD PTR [rsp+0x48],rdx
    29e1:	test   rax,rax
    29e4:	jne    29f4 <botlish_fn_17+0xcc>
    29ea:	mov    rdi,QWORD PTR [rsp+0x20]
    29ef:	jmp    2b6d <botlish_fn_17+0x245>
    29f4:	mov    QWORD PTR [r14+0x8],rax
    29f8:	mov    rdx,QWORD PTR [rsp+0x48]
    29fd:	mov    r8,rax
    2a00:	mov    QWORD PTR [r14+0x28],rdx
    2a04:	mov    rcx,QWORD PTR [rsp+0x30]
    2a09:	mov    rdx,QWORD PTR [rsp+0x28]
    2a0e:	mov    rsi,rbx
    2a11:	mov    rdi,QWORD PTR [rsp+0x20]
    2a16:	mov    r9,QWORD PTR [rsp+0x50]
    2a1b:	call   2a20 <botlish_fn_17+0xf8>
			2a1c: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], str>
    2a20:	test   rax,rax
    2a23:	jne    2a33 <botlish_fn_17+0x10b>
    2a29:	mov    rdi,QWORD PTR [rsp+0x20]
    2a2e:	jmp    2b6d <botlish_fn_17+0x245>
    2a33:	mov    QWORD PTR [r14+0x8],rax
    2a37:	mov    QWORD PTR [rsp+0x40],rax
    2a3c:	mov    rdx,QWORD PTR [rsp]
    2a40:	mov    QWORD PTR [rsp+0x28],rdx
    2a45:	mov    QWORD PTR [r14+0x10],rdx
    2a49:	mov    rcx,QWORD PTR [rsp+0x8]
    2a4e:	mov    QWORD PTR [r14+0x18],rcx
    2a52:	mov    QWORD PTR [rsp+0x30],rcx
    2a57:	mov    rcx,r12
    2a5a:	mov    rdx,QWORD PTR [rsp+0x48]
    2a5f:	mov    rsi,r13
    2a62:	mov    rdi,QWORD PTR [rsp+0x20]
    2a67:	call   2a6c <botlish_fn_17+0x144>
			2a68: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    2a6c:	test   rax,rax
    2a6f:	mov    QWORD PTR [rsp+0x38],rax
    2a74:	jne    2a84 <botlish_fn_17+0x15c>
    2a7a:	mov    rdi,QWORD PTR [rsp+0x20]
    2a7f:	jmp    2b6d <botlish_fn_17+0x245>
    2a84:	mov    rbx,QWORD PTR [rsp+0x10]
    2a89:	mov    r15,QWORD PTR [rsp+0x18]
    2a8e:	mov    rdi,QWORD PTR [rsp+0x20]
    2a93:	mov    rcx,QWORD PTR [rdi+0x10]
    2a97:	mov    r8,QWORD PTR [rcx+0x18]
    2a9b:	mov    r9,QWORD PTR [rip+0x0]        # 2aa2 <botlish_fn_17+0x17a>
			2a9e: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    2aa2:	mov    rcx,r15
    2aa5:	mov    rdx,rbx
    2aa8:	mov    rsi,QWORD PTR [rsp+0x38]
    2aad:	call   r9
    2ab0:	cmp    rax,0x6
    2ab4:	je     2c34 <botlish_fn_17+0x30c>
    2aba:	mov    rdi,QWORD PTR [rsp+0x20]
    2abf:	mov    rax,QWORD PTR [rdi+0x10]
    2ac3:	mov    r8,QWORD PTR [rax+0x20]
    2ac7:	mov    rax,QWORD PTR [rip+0x0]        # 2ace <botlish_fn_17+0x1a6>
			2aca: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    2ace:	mov    rcx,r15
    2ad1:	mov    rdx,rbx
    2ad4:	mov    rsi,QWORD PTR [rsp+0x38]
    2ad9:	call   rax
    2adb:	cmp    rax,0x6
    2adf:	je     2b46 <botlish_fn_17+0x21e>
    2ae5:	mov    rcx,QWORD PTR [rsp+0x30]
    2aea:	mov    rdx,QWORD PTR [rsp+0x28]
    2aef:	mov    rsi,QWORD PTR [rsp+0x40]
    2af4:	mov    rdi,QWORD PTR [rsp+0x20]
    2af9:	call   2afe <botlish_fn_17+0x1d6>
			2afa: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2afe:	test   rax,rax
    2b01:	jne    2b11 <botlish_fn_17+0x1e9>
    2b07:	mov    rdi,QWORD PTR [rsp+0x20]
    2b0c:	jmp    2b6d <botlish_fn_17+0x245>
    2b11:	mov    rdi,QWORD PTR [rsp+0x20]
    2b16:	mov    QWORD PTR [rdi],r14
    2b19:	mov    rdx,QWORD PTR [rsp+0x48]
    2b1e:	mov    rbx,QWORD PTR [rsp+0x60]
    2b23:	mov    r12,QWORD PTR [rsp+0x68]
    2b28:	mov    r13,QWORD PTR [rsp+0x70]
    2b2d:	mov    r14,QWORD PTR [rsp+0x78]
    2b32:	mov    r15,QWORD PTR [rsp+0x80]
    2b3a:	add    rsp,0x90
    2b41:	mov    rsp,rbp
    2b44:	pop    rbp
    2b45:	ret
    2b46:	mov    rcx,QWORD PTR [rsp+0x30]
    2b4b:	mov    rdx,QWORD PTR [rsp+0x28]
    2b50:	mov    rsi,QWORD PTR [rsp+0x40]
    2b55:	mov    rdi,QWORD PTR [rsp+0x20]
    2b5a:	call   2b5f <botlish_fn_17+0x237>
			2b5b: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2b5f:	test   rax,rax
    2b62:	jne    2ba3 <botlish_fn_17+0x27b>
    2b68:	mov    rdi,QWORD PTR [rsp+0x20]
    2b6d:	mov    rdi,QWORD PTR [rsp+0x20]
    2b72:	mov    QWORD PTR [rdi],r14
    2b75:	xor    rdx,rdx
    2b78:	mov    rax,rdx
    2b7b:	mov    rbx,QWORD PTR [rsp+0x60]
    2b80:	mov    r12,QWORD PTR [rsp+0x68]
    2b85:	mov    r13,QWORD PTR [rsp+0x70]
    2b8a:	mov    r14,QWORD PTR [rsp+0x78]
    2b8f:	mov    r15,QWORD PTR [rsp+0x80]
    2b97:	add    rsp,0x90
    2b9e:	mov    rsp,rbp
    2ba1:	pop    rbp
    2ba2:	ret
    2ba3:	mov    QWORD PTR [r14],rax
    2ba6:	mov    rbx,rax
    2ba9:	mov    QWORD PTR [r14+0x8],0x3
    2bb1:	mov    rdx,QWORD PTR [rsp+0x48]
    2bb6:	test   rdx,0x1
    2bbd:	je     2be1 <botlish_fn_17+0x2b9>
    2bc3:	mov    rdx,QWORD PTR [rsp+0x48]
    2bc8:	add    rdx,0x2
    2bcc:	seto   al
    2bcf:	test   al,al
    2bd1:	jne    2be1 <botlish_fn_17+0x2b9>
    2bd7:	mov    rdi,QWORD PTR [rsp+0x20]
    2bdc:	jmp    2c01 <botlish_fn_17+0x2d9>
    2be1:	mov    edx,0x3
    2be6:	mov    rax,QWORD PTR [rip+0x0]        # 2bed <botlish_fn_17+0x2c5>
			2be9: R_X86_64_GOTPCREL	rt_int_add-0x4
    2bed:	mov    rsi,QWORD PTR [rsp+0x48]
    2bf2:	mov    rdi,QWORD PTR [rsp+0x20]
    2bf7:	call   rax
    2bf9:	mov    rdx,rax
    2bfc:	mov    rdi,QWORD PTR [rsp+0x20]
    2c01:	mov    rdi,QWORD PTR [rsp+0x20]
    2c06:	mov    QWORD PTR [rdi],r14
    2c09:	mov    rax,rbx
    2c0c:	mov    rbx,QWORD PTR [rsp+0x60]
    2c11:	mov    r12,QWORD PTR [rsp+0x68]
    2c16:	mov    r13,QWORD PTR [rsp+0x70]
    2c1b:	mov    r14,QWORD PTR [rsp+0x78]
    2c20:	mov    r15,QWORD PTR [rsp+0x80]
    2c28:	add    rsp,0x90
    2c2f:	mov    rsp,rbp
    2c32:	pop    rbp
    2c33:	ret
    2c34:	mov    rsi,QWORD PTR [rsp+0x48]
    2c39:	mov    edx,0x3
    2c3e:	mov    rcx,rdx
    2c41:	mov    QWORD PTR [r14+0x20],0x3
    2c49:	test   rsi,0x1
    2c50:	je     2c68 <botlish_fn_17+0x340>
    2c56:	mov    rdx,rsi
    2c59:	add    rdx,0x2
    2c5d:	seto   al
    2c60:	test   al,al
    2c62:	je     2c7c <botlish_fn_17+0x354>
    2c68:	mov    rax,QWORD PTR [rip+0x0]        # 2c6f <botlish_fn_17+0x347>
			2c6b: R_X86_64_GOTPCREL	rt_int_add-0x4
    2c6f:	mov    rdx,rcx
    2c72:	mov    rdi,QWORD PTR [rsp+0x20]
    2c77:	call   rax
    2c79:	mov    rdx,rax
    2c7c:	mov    QWORD PTR [r14],r13
    2c7f:	mov    QWORD PTR [r14+0x8],rdx
    2c83:	mov    rsi,QWORD PTR [rsp+0x40]
    2c88:	mov    QWORD PTR [r14+0x10],rsi
    2c8c:	mov    rax,QWORD PTR [rsp+0x28]
    2c91:	mov    QWORD PTR [r14+0x18],rax
    2c95:	mov    rcx,QWORD PTR [rsp+0x30]
    2c9a:	mov    QWORD PTR [r14+0x20],rcx
    2c9e:	mov    rbx,rsi
    2ca1:	jmp    29cf <botlish_fn_17+0xa7>
    2ca6:	mov    QWORD PTR [rsp+0x20],rdi
    2cab:	mov    rax,QWORD PTR [rip+0x0]        # 2cb2 <botlish_fn_17+0x38a>
			2cae: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2cb2:	call   rax
    2cb4:	xor    rdx,rdx
    2cb7:	mov    rax,rdx
    2cba:	mov    rbx,QWORD PTR [rsp+0x60]
    2cbf:	mov    r12,QWORD PTR [rsp+0x68]
    2cc4:	mov    r13,QWORD PTR [rsp+0x70]
    2cc9:	mov    r14,QWORD PTR [rsp+0x78]
    2cce:	mov    r15,QWORD PTR [rsp+0x80]
    2cd6:	add    rsp,0x90
    2cdd:	mov    rsp,rbp
    2ce0:	pop    rbp
    2ce1:	ret

0000000000002ce2 <botlish_entry_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    2ce2:	push   rbp
    2ce3:	mov    rbp,rsp
    2ce6:	ud2

0000000000002ce8 <botlish_fn_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    2ce8:	push   rbp
    2ce9:	mov    rbp,rsp
    2cec:	sub    rsp,0x60
    2cf0:	mov    QWORD PTR [rsp+0x30],rbx
    2cf5:	mov    QWORD PTR [rsp+0x38],r12
    2cfa:	mov    QWORD PTR [rsp+0x40],r13
    2cff:	mov    QWORD PTR [rsp+0x48],r14
    2d04:	mov    QWORD PTR [rsp+0x50],r15
    2d09:	mov    rbx,QWORD PTR [rdi]
    2d0c:	mov    rax,QWORD PTR [rdi+0x8]
    2d10:	lea    r10,[rbx+0x40]
    2d14:	cmp    r10,rax
    2d17:	ja     2f15 <botlish_fn_18+0x22d>
    2d1d:	lea    rax,[rbx+0x40]
    2d21:	mov    QWORD PTR [rdi],rax
    2d24:	mov    r12,rdi
    2d27:	mov    QWORD PTR [rbx],0x0
    2d2e:	mov    QWORD PTR [rbx+0x8],0x0
    2d36:	mov    QWORD PTR [rbx+0x10],0x0
    2d3e:	mov    QWORD PTR [rbx+0x18],0x0
    2d46:	mov    QWORD PTR [rbx+0x20],0x0
    2d4e:	mov    QWORD PTR [rbx+0x28],0x0
    2d56:	mov    QWORD PTR [rbx+0x30],0x0
    2d5e:	mov    QWORD PTR [rbx+0x38],0x0
    2d66:	mov    QWORD PTR [rbx],rsi
    2d69:	mov    r13,rsi
    2d6c:	mov    QWORD PTR [rbx+0x8],rdx
    2d70:	mov    QWORD PTR [rsp+0x20],rdx
    2d75:	mov    QWORD PTR [rbx+0x10],rcx
    2d79:	mov    QWORD PTR [rsp+0x28],rcx
    2d7e:	mov    QWORD PTR [rbx+0x18],r8
    2d82:	mov    r15,r8
    2d85:	mov    QWORD PTR [rbx+0x20],r9
    2d89:	mov    r14,r9
    2d8c:	mov    rax,QWORD PTR [rip+0x0]        # 2d93 <botlish_fn_18+0xab>
			2d8f: R_X86_64_GOTPCREL	rt_str_len-0x4
    2d93:	mov    rsi,r13
    2d96:	mov    rdi,r12
    2d99:	call   rax
    2d9b:	mov    rdx,QWORD PTR [rsp+0x20]
    2da0:	mov    rcx,rdx
    2da3:	sar    rcx,1
    2da6:	sar    rax,1
    2da9:	cmp    rcx,rax
    2dac:	jge    2ea3 <botlish_fn_18+0x1bb>
    2db2:	lea    rsi,[rsp]
    2db6:	mov    rdi,r12
    2db9:	call   2dbe <botlish_fn_18+0xd6>
			2dba: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    2dbe:	test   rax,rax
    2dc1:	jne    2dcf <botlish_fn_18+0xe7>
    2dc7:	mov    rdi,r12
    2dca:	jmp    2ec2 <botlish_fn_18+0x1da>
    2dcf:	mov    QWORD PTR [rbx+0x28],rax
    2dd3:	mov    rcx,rax
    2dd6:	mov    r8,QWORD PTR [rsp]
    2dda:	mov    QWORD PTR [rbx+0x30],r8
    2dde:	mov    r9,QWORD PTR [rsp+0x8]
    2de3:	mov    QWORD PTR [rbx+0x38],r9
    2de7:	mov    rdx,QWORD PTR [rsp+0x20]
    2dec:	mov    rsi,r13
    2def:	mov    rdi,r12
    2df2:	call   2df7 <botlish_fn_18+0x10f>
			2df3: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    2df7:	test   rax,rax
    2dfa:	jne    2e08 <botlish_fn_18+0x120>
    2e00:	mov    rdi,r12
    2e03:	jmp    2ec2 <botlish_fn_18+0x1da>
    2e08:	mov    QWORD PTR [rbx+0x8],rax
    2e0c:	mov    r8,rax
    2e0f:	mov    QWORD PTR [rbx+0x28],rdx
    2e13:	mov    QWORD PTR [rsp+0x20],rdx
    2e18:	lea    r9,[rsp+0x10]
    2e1d:	mov    rcx,r14
    2e20:	mov    rdx,r15
    2e23:	mov    rsi,QWORD PTR [rsp+0x28]
    2e28:	mov    rdi,r12
    2e2b:	call   2e30 <botlish_fn_18+0x148>
			2e2c: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[list<never>, mutarray, int], list>
    2e30:	test   rax,rax
    2e33:	jne    2e41 <botlish_fn_18+0x159>
    2e39:	mov    rdi,r12
    2e3c:	jmp    2ec2 <botlish_fn_18+0x1da>
    2e41:	mov    QWORD PTR [rbx+0x8],rax
    2e45:	mov    rcx,rax
    2e48:	mov    r8,QWORD PTR [rsp+0x10]
    2e4d:	mov    QWORD PTR [rbx+0x10],r8
    2e51:	mov    r9,QWORD PTR [rsp+0x18]
    2e56:	mov    QWORD PTR [rbx+0x18],r9
    2e5a:	mov    rdx,QWORD PTR [rsp+0x20]
    2e5f:	mov    rsi,r13
    2e62:	mov    rdi,r12
    2e65:	call   2e6a <botlish_fn_18+0x182>
			2e66: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    2e6a:	test   rax,rax
    2e6d:	jne    2e7b <botlish_fn_18+0x193>
    2e73:	mov    rdi,r12
    2e76:	jmp    2ec2 <botlish_fn_18+0x1da>
    2e7b:	mov    rdi,r12
    2e7e:	mov    QWORD PTR [rdi],rbx
    2e81:	mov    rbx,QWORD PTR [rsp+0x30]
    2e86:	mov    r12,QWORD PTR [rsp+0x38]
    2e8b:	mov    r13,QWORD PTR [rsp+0x40]
    2e90:	mov    r14,QWORD PTR [rsp+0x48]
    2e95:	mov    r15,QWORD PTR [rsp+0x50]
    2e9a:	add    rsp,0x60
    2e9e:	mov    rsp,rbp
    2ea1:	pop    rbp
    2ea2:	ret
    2ea3:	mov    rcx,r14
    2ea6:	mov    rdx,r15
    2ea9:	mov    rsi,QWORD PTR [rsp+0x28]
    2eae:	mov    rdi,r12
    2eb1:	call   2eb6 <botlish_fn_18+0x1ce>
			2eb2: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    2eb6:	test   rax,rax
    2eb9:	jne    2eed <botlish_fn_18+0x205>
    2ebf:	mov    rdi,r12
    2ec2:	mov    rdi,r12
    2ec5:	mov    QWORD PTR [rdi],rbx
    2ec8:	xor    rax,rax
    2ecb:	mov    rbx,QWORD PTR [rsp+0x30]
    2ed0:	mov    r12,QWORD PTR [rsp+0x38]
    2ed5:	mov    r13,QWORD PTR [rsp+0x40]
    2eda:	mov    r14,QWORD PTR [rsp+0x48]
    2edf:	mov    r15,QWORD PTR [rsp+0x50]
    2ee4:	add    rsp,0x60
    2ee8:	mov    rsp,rbp
    2eeb:	pop    rbp
    2eec:	ret
    2eed:	mov    rdi,r12
    2ef0:	mov    QWORD PTR [rdi],rbx
    2ef3:	mov    rbx,QWORD PTR [rsp+0x30]
    2ef8:	mov    r12,QWORD PTR [rsp+0x38]
    2efd:	mov    r13,QWORD PTR [rsp+0x40]
    2f02:	mov    r14,QWORD PTR [rsp+0x48]
    2f07:	mov    r15,QWORD PTR [rsp+0x50]
    2f0c:	add    rsp,0x60
    2f10:	mov    rsp,rbp
    2f13:	pop    rbp
    2f14:	ret
    2f15:	mov    r12,rdi
    2f18:	mov    rax,QWORD PTR [rip+0x0]        # 2f1f <botlish_fn_18+0x237>
			2f1b: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2f1f:	call   rax
    2f21:	xor    rax,rax
    2f24:	mov    rbx,QWORD PTR [rsp+0x30]
    2f29:	mov    r12,QWORD PTR [rsp+0x38]
    2f2e:	mov    r13,QWORD PTR [rsp+0x40]
    2f33:	mov    r14,QWORD PTR [rsp+0x48]
    2f38:	mov    r15,QWORD PTR [rsp+0x50]
    2f3d:	add    rsp,0x60
    2f41:	mov    rsp,rbp
    2f44:	pop    rbp
    2f45:	ret

0000000000002f46 <botlish_entry_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    2f46:	push   rbp
    2f47:	mov    rbp,rsp
    2f4a:	mov    rsi,QWORD PTR [rdx]
    2f4d:	mov    r10,QWORD PTR [rdx+0x8]
    2f51:	mov    rcx,QWORD PTR [rdx+0x10]
    2f55:	mov    r8,QWORD PTR [rdx+0x18]
    2f59:	mov    r9,QWORD PTR [rdx+0x20]
    2f5d:	mov    rdx,r10
    2f60:	call   2f65 <botlish_entry_18+0x1f>
			2f61: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    2f65:	mov    rsp,rbp
    2f68:	pop    rbp
    2f69:	ret
    2f6a:	add    BYTE PTR [rax],al
    2f6c:	add    BYTE PTR [rax],al
	...

0000000000002f70 <botlish_fn_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    2f70:	push   rbp
    2f71:	mov    rbp,rsp
    2f74:	sub    rsp,0x70
    2f78:	mov    QWORD PTR [rsp+0x40],rbx
    2f7d:	mov    QWORD PTR [rsp+0x48],r12
    2f82:	mov    QWORD PTR [rsp+0x50],r13
    2f87:	mov    QWORD PTR [rsp+0x58],r14
    2f8c:	mov    QWORD PTR [rsp+0x60],r15
    2f91:	mov    r14,QWORD PTR [rdi]
    2f94:	mov    rax,QWORD PTR [rdi+0x8]
    2f98:	lea    r10,[r14+0x40]
    2f9c:	cmp    r10,rax
    2f9f:	ja     31d5 <botlish_fn_19+0x265>
    2fa5:	lea    rax,[r14+0x40]
    2fa9:	mov    QWORD PTR [rdi],rax
    2fac:	mov    QWORD PTR [rsp+0x20],rdi
    2fb1:	mov    QWORD PTR [r14],0x0
    2fb8:	mov    QWORD PTR [r14+0x8],0x0
    2fc0:	mov    QWORD PTR [r14+0x10],0x0
    2fc8:	mov    QWORD PTR [r14+0x18],0x0
    2fd0:	mov    QWORD PTR [r14+0x20],0x0
    2fd8:	mov    QWORD PTR [r14+0x28],0x0
    2fe0:	mov    QWORD PTR [r14+0x30],0x0
    2fe8:	mov    QWORD PTR [r14+0x38],0x0
    2ff0:	mov    QWORD PTR [r14],rsi
    2ff3:	mov    QWORD PTR [r14+0x8],rdx
    2ff7:	mov    r15,rdx
    2ffa:	mov    QWORD PTR [r14+0x10],rcx
    2ffe:	mov    QWORD PTR [r14+0x18],r8
    3002:	mov    QWORD PTR [r14+0x20],r9
    3006:	lea    rbx,[rsp]
    300a:	lea    r12,[rsp+0x10]
    300f:	mov    QWORD PTR [rsp+0x28],rcx
    3014:	mov    QWORD PTR [rsp+0x30],r8
    3019:	mov    QWORD PTR [rsp+0x38],r9
    301e:	mov    rax,QWORD PTR [rip+0x0]        # 3025 <botlish_fn_19+0xb5>
			3021: R_X86_64_GOTPCREL	rt_str_len-0x4
    3025:	mov    r13,rsi
    3028:	mov    rdi,QWORD PTR [rsp+0x20]
    302d:	call   rax
    302f:	mov    rcx,r15
    3032:	and    rcx,rax
    3035:	mov    rdx,rax
    3038:	test   rcx,0x1
    303f:	jne    306b <botlish_fn_19+0xfb>
    3045:	mov    rax,QWORD PTR [rip+0x0]        # 304c <botlish_fn_19+0xdc>
			3048: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    304c:	mov    rsi,r15
    304f:	mov    rdi,QWORD PTR [rsp+0x20]
    3054:	call   rax
    3056:	mov    ecx,0x2
    305b:	test   rax,rax
    305e:	cmovge rcx,QWORD PTR [rip+0x1a2]        # 3208 <botlish_fn_19+0x298>
    3066:	jmp    307e <botlish_fn_19+0x10e>
    306b:	mov    ecx,0x2
    3070:	mov    rax,r15
    3073:	cmp    rax,rdx
    3076:	cmovge rcx,QWORD PTR [rip+0x18a]        # 3208 <botlish_fn_19+0x298>
    307e:	cmp    rcx,0x6
    3082:	je     3157 <botlish_fn_19+0x1e7>
    3088:	mov    rsi,rbx
    308b:	mov    rdi,QWORD PTR [rsp+0x20]
    3090:	call   3095 <botlish_fn_19+0x125>
			3091: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    3095:	test   rax,rax
    3098:	jne    30a8 <botlish_fn_19+0x138>
    309e:	mov    rdi,QWORD PTR [rsp+0x20]
    30a3:	jmp    317e <botlish_fn_19+0x20e>
    30a8:	mov    QWORD PTR [r14+0x28],rax
    30ac:	mov    rcx,rax
    30af:	mov    r8,QWORD PTR [rsp]
    30b3:	mov    QWORD PTR [r14+0x30],r8
    30b7:	mov    r9,QWORD PTR [rsp+0x8]
    30bc:	mov    QWORD PTR [r14+0x38],r9
    30c0:	mov    rdx,r15
    30c3:	mov    rsi,r13
    30c6:	mov    rdi,QWORD PTR [rsp+0x20]
    30cb:	call   30d0 <botlish_fn_19+0x160>
			30cc: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    30d0:	test   rax,rax
    30d3:	jne    30e3 <botlish_fn_19+0x173>
    30d9:	mov    rdi,QWORD PTR [rsp+0x20]
    30de:	jmp    317e <botlish_fn_19+0x20e>
    30e3:	mov    QWORD PTR [r14+0x8],rax
    30e7:	mov    r8,rax
    30ea:	mov    QWORD PTR [r14+0x28],rdx
    30ee:	mov    r15,rdx
    30f1:	mov    rsi,QWORD PTR [rsp+0x28]
    30f6:	mov    rdx,QWORD PTR [rsp+0x30]
    30fb:	mov    rcx,QWORD PTR [rsp+0x38]
    3100:	mov    rdi,QWORD PTR [rsp+0x20]
    3105:	mov    r9,r12
    3108:	call   310d <botlish_fn_19+0x19d>
			3109: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], list>
    310d:	test   rax,rax
    3110:	jne    3120 <botlish_fn_19+0x1b0>
    3116:	mov    rdi,QWORD PTR [rsp+0x20]
    311b:	jmp    317e <botlish_fn_19+0x20e>
    3120:	mov    rdx,QWORD PTR [rsp+0x10]
    3125:	mov    rcx,QWORD PTR [rsp+0x18]
    312a:	mov    QWORD PTR [r14],r13
    312d:	mov    rsi,r15
    3130:	mov    QWORD PTR [r14+0x8],rsi
    3134:	mov    QWORD PTR [r14+0x10],rax
    3138:	mov    QWORD PTR [r14+0x18],rdx
    313c:	mov    QWORD PTR [r14+0x20],rcx
    3140:	mov    QWORD PTR [rsp+0x38],rcx
    3145:	mov    QWORD PTR [rsp+0x30],rdx
    314a:	mov    QWORD PTR [rsp+0x28],rax
    314f:	mov    rsi,r13
    3152:	jmp    301e <botlish_fn_19+0xae>
    3157:	mov    rcx,QWORD PTR [rsp+0x38]
    315c:	mov    rdx,QWORD PTR [rsp+0x30]
    3161:	mov    rsi,QWORD PTR [rsp+0x28]
    3166:	mov    rdi,QWORD PTR [rsp+0x20]
    316b:	call   3170 <botlish_fn_19+0x200>
			316c: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    3170:	test   rax,rax
    3173:	jne    31ab <botlish_fn_19+0x23b>
    3179:	mov    rdi,QWORD PTR [rsp+0x20]
    317e:	mov    rdi,QWORD PTR [rsp+0x20]
    3183:	mov    QWORD PTR [rdi],r14
    3186:	xor    rax,rax
    3189:	mov    rbx,QWORD PTR [rsp+0x40]
    318e:	mov    r12,QWORD PTR [rsp+0x48]
    3193:	mov    r13,QWORD PTR [rsp+0x50]
    3198:	mov    r14,QWORD PTR [rsp+0x58]
    319d:	mov    r15,QWORD PTR [rsp+0x60]
    31a2:	add    rsp,0x70
    31a6:	mov    rsp,rbp
    31a9:	pop    rbp
    31aa:	ret
    31ab:	mov    rdi,QWORD PTR [rsp+0x20]
    31b0:	mov    QWORD PTR [rdi],r14
    31b3:	mov    rbx,QWORD PTR [rsp+0x40]
    31b8:	mov    r12,QWORD PTR [rsp+0x48]
    31bd:	mov    r13,QWORD PTR [rsp+0x50]
    31c2:	mov    r14,QWORD PTR [rsp+0x58]
    31c7:	mov    r15,QWORD PTR [rsp+0x60]
    31cc:	add    rsp,0x70
    31d0:	mov    rsp,rbp
    31d3:	pop    rbp
    31d4:	ret
    31d5:	mov    QWORD PTR [rsp+0x20],rdi
    31da:	mov    rax,QWORD PTR [rip+0x0]        # 31e1 <botlish_fn_19+0x271>
			31dd: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    31e1:	call   rax
    31e3:	xor    rax,rax
    31e6:	mov    rbx,QWORD PTR [rsp+0x40]
    31eb:	mov    r12,QWORD PTR [rsp+0x48]
    31f0:	mov    r13,QWORD PTR [rsp+0x50]
    31f5:	mov    r14,QWORD PTR [rsp+0x58]
    31fa:	mov    r15,QWORD PTR [rsp+0x60]
    31ff:	add    rsp,0x70
    3203:	mov    rsp,rbp
    3206:	pop    rbp
    3207:	ret
    3208:	(bad)
    3209:	add    BYTE PTR [rax],al
    320b:	add    BYTE PTR [rax],al
    320d:	add    BYTE PTR [rax],al
	...

0000000000003210 <botlish_entry_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    3210:	push   rbp
    3211:	mov    rbp,rsp
    3214:	mov    rsi,QWORD PTR [rdx]
    3217:	mov    r10,QWORD PTR [rdx+0x8]
    321b:	mov    rcx,QWORD PTR [rdx+0x10]
    321f:	mov    r8,QWORD PTR [rdx+0x18]
    3223:	mov    r9,QWORD PTR [rdx+0x20]
    3227:	mov    rdx,r10
    322a:	call   322f <botlish_entry_19+0x1f>
			322b: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    322f:	mov    rsp,rbp
    3232:	pop    rbp
    3233:	ret

0000000000003234 <botlish_fn_20: csv_parse<str>>:
    3234:	push   rbp
    3235:	mov    rbp,rsp
    3238:	sub    rsp,0x30
    323c:	mov    QWORD PTR [rsp+0x10],rbx
    3241:	mov    QWORD PTR [rsp+0x18],r12
    3246:	mov    QWORD PTR [rsp+0x20],r13
    324b:	mov    rbx,QWORD PTR [rdi]
    324e:	mov    rax,QWORD PTR [rdi+0x8]
    3252:	lea    rcx,[rbx+0x28]
    3256:	cmp    rcx,rax
    3259:	ja     332e <botlish_fn_20+0xfa>
    325f:	lea    rax,[rbx+0x28]
    3263:	mov    QWORD PTR [rdi],rax
    3266:	mov    r12,rdi
    3269:	mov    QWORD PTR [rbx],0x0
    3270:	mov    QWORD PTR [rbx+0x8],0x0
    3278:	mov    QWORD PTR [rbx+0x10],0x0
    3280:	mov    QWORD PTR [rbx+0x18],0x0
    3288:	mov    QWORD PTR [rbx+0x20],0x0
    3290:	mov    QWORD PTR [rbx],rsi
    3293:	mov    r13,rsi
    3296:	mov    QWORD PTR [rbx+0x8],0x1
    329e:	lea    rsi,[rsp]
    32a2:	mov    rdi,r12
    32a5:	call   32aa <botlish_fn_20+0x76>
			32a6: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    32aa:	test   rax,rax
    32ad:	jne    32bb <botlish_fn_20+0x87>
    32b3:	mov    rdi,r12
    32b6:	jmp    32ef <botlish_fn_20+0xbb>
    32bb:	mov    QWORD PTR [rbx+0x10],rax
    32bf:	mov    rcx,rax
    32c2:	mov    r8,QWORD PTR [rsp]
    32c6:	mov    QWORD PTR [rbx+0x18],r8
    32ca:	mov    r9,QWORD PTR [rsp+0x8]
    32cf:	mov    QWORD PTR [rbx+0x20],r9
    32d3:	mov    edx,0x1
    32d8:	mov    rsi,r13
    32db:	mov    rdi,r12
    32de:	call   32e3 <botlish_fn_20+0xaf>
			32df: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    32e3:	test   rax,rax
    32e6:	jne    3310 <botlish_fn_20+0xdc>
    32ec:	mov    rdi,r12
    32ef:	mov    rdi,r12
    32f2:	mov    QWORD PTR [rdi],rbx
    32f5:	xor    rax,rax
    32f8:	mov    rbx,QWORD PTR [rsp+0x10]
    32fd:	mov    r12,QWORD PTR [rsp+0x18]
    3302:	mov    r13,QWORD PTR [rsp+0x20]
    3307:	add    rsp,0x30
    330b:	mov    rsp,rbp
    330e:	pop    rbp
    330f:	ret
    3310:	mov    rdi,r12
    3313:	mov    QWORD PTR [rdi],rbx
    3316:	mov    rbx,QWORD PTR [rsp+0x10]
    331b:	mov    r12,QWORD PTR [rsp+0x18]
    3320:	mov    r13,QWORD PTR [rsp+0x20]
    3325:	add    rsp,0x30
    3329:	mov    rsp,rbp
    332c:	pop    rbp
    332d:	ret
    332e:	mov    r12,rdi
    3331:	mov    rax,QWORD PTR [rip+0x0]        # 3338 <botlish_fn_20+0x104>
			3334: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    3338:	call   rax
    333a:	xor    rax,rax
    333d:	mov    rbx,QWORD PTR [rsp+0x10]
    3342:	mov    r12,QWORD PTR [rsp+0x18]
    3347:	mov    r13,QWORD PTR [rsp+0x20]
    334c:	add    rsp,0x30
    3350:	mov    rsp,rbp
    3353:	pop    rbp
    3354:	ret

0000000000003355 <botlish_entry_20: csv_parse<str>>:
    3355:	push   rbp
    3356:	mov    rbp,rsp
    3359:	mov    rsi,QWORD PTR [rdx]
    335c:	call   3361 <botlish_entry_20+0xc>
			335d: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    3361:	mov    rsp,rbp
    3364:	pop    rbp
    3365:	ret

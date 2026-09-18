; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 13355  (per function: 176 85 318 750 750 750 750 808 728 747 747 501 558 698 913 482 938 975 648 724 309)
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
     dd9:	mov    r13,QWORD PTR [rdi]
     ddc:	mov    rax,QWORD PTR [rdi+0x8]
     de0:	lea    r9,[r13+0x30]
     de4:	cmp    r9,rax
     de7:	ja     1071 <botlish_fn_7+0x2b9>
     ded:	lea    rax,[r13+0x30]
     df1:	mov    QWORD PTR [rdi],rax
     df4:	mov    r14,rdi
     df7:	mov    QWORD PTR [r13+0x0],0x0
     dff:	mov    QWORD PTR [r13+0x8],0x0
     e07:	mov    QWORD PTR [r13+0x10],0x0
     e0f:	mov    QWORD PTR [r13+0x18],0x0
     e17:	mov    QWORD PTR [r13+0x20],0x0
     e1f:	mov    QWORD PTR [r13+0x28],0x0
     e27:	mov    QWORD PTR [r13+0x0],rsi
     e2b:	mov    QWORD PTR [r13+0x8],rdx
     e2f:	mov    r12,rdx
     e32:	mov    QWORD PTR [r13+0x10],rcx
     e36:	mov    QWORD PTR [rsp],rcx
     e3a:	mov    QWORD PTR [r13+0x18],r8
     e3e:	mov    QWORD PTR [rsp+0x8],r8
     e43:	mov    r8,QWORD PTR [rip+0x0]        # e4a <botlish_fn_7+0x92>
			e46: R_X86_64_GOTPCREL	rt_list_len-0x4
     e4a:	mov    rbx,rsi
     e4d:	mov    rdi,r14
     e50:	call   r8
     e53:	mov    r15,r12
     e56:	mov    rsi,r15
     e59:	and    rsi,rax
     e5c:	mov    rdx,rax
     e5f:	test   rsi,0x1
     e66:	jne    e91 <botlish_fn_7+0xd9>
     e6c:	mov    r8,QWORD PTR [rip+0x0]        # e73 <botlish_fn_7+0xbb>
			e6f: R_X86_64_GOTPCREL	rt_int_cmp-0x4
     e73:	mov    rsi,r15
     e76:	mov    rdi,r14
     e79:	call   r8
     e7c:	mov    ecx,0x2
     e81:	test   rax,rax
     e84:	cmovge rcx,QWORD PTR [rip+0x21c]        # 10a8 <botlish_fn_7+0x2f0>
     e8c:	jmp    ea1 <botlish_fn_7+0xe9>
     e91:	mov    ecx,0x2
     e96:	cmp    r15,rdx
     e99:	cmovge rcx,QWORD PTR [rip+0x207]        # 10a8 <botlish_fn_7+0x2f0>
     ea1:	cmp    rcx,0x6
     ea5:	je     1044 <botlish_fn_7+0x28c>
     eab:	mov    rax,QWORD PTR [rip+0x0]        # eb2 <botlish_fn_7+0xfa>
			eae: R_X86_64_GOTPCREL	rt_list_get-0x4
     eb2:	mov    rdx,r15
     eb5:	mov    rsi,rbx
     eb8:	mov    rdi,r14
     ebb:	call   rax
     ebd:	mov    rcx,rax
     ec0:	mov    r12,rax
     ec3:	test   rax,rcx
     ec6:	jne    ed4 <botlish_fn_7+0x11c>
     ecc:	mov    rdi,r14
     ecf:	jmp    fa3 <botlish_fn_7+0x1eb>
     ed4:	mov    rax,r12
     ed7:	mov    QWORD PTR [r13+0x20],rax
     edb:	mov    QWORD PTR [r13+0x28],0x1
     ee3:	mov    rdi,r14
     ee6:	call   eeb <botlish_fn_7+0x133>
			ee7: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     eeb:	test   rax,rax
     eee:	mov    r9,rax
     ef1:	jne    eff <botlish_fn_7+0x147>
     ef7:	mov    rdi,r14
     efa:	jmp    fa3 <botlish_fn_7+0x1eb>
     eff:	xor    ecx,ecx
     f01:	mov    rax,r12
     f04:	test   rax,0x7
     f0a:	jne    f1c <botlish_fn_7+0x164>
     f10:	mov    rax,r12
     f13:	movzx  rax,BYTE PTR [rax]
     f17:	cmp    al,0x8
     f19:	sete   cl
     f1c:	test   cl,cl
     f1e:	jne    f48 <botlish_fn_7+0x190>
     f24:	mov    rdi,r14
     f27:	mov    rax,QWORD PTR [rdi+0x10]
     f2b:	mov    rcx,QWORD PTR [rax+0x8]
     f2f:	mov    edx,0x8
     f34:	mov    rax,QWORD PTR [rip+0x0]        # f3b <botlish_fn_7+0x183>
			f37: R_X86_64_GOTPCREL	rt_type_error-0x4
     f3b:	mov    rsi,r12
     f3e:	call   rax
     f40:	mov    rdi,r14
     f43:	jmp    fa3 <botlish_fn_7+0x1eb>
     f48:	mov    r8d,0x1
     f4e:	mov    rax,QWORD PTR [rip+0x0]        # f55 <botlish_fn_7+0x19d>
			f51: R_X86_64_GOTPCREL	rt_mutarray_copy-0x4
     f55:	mov    rcx,r12
     f58:	mov    r12,QWORD PTR [rsp]
     f5c:	mov    rdx,QWORD PTR [rsp+0x8]
     f61:	mov    rsi,r12
     f64:	mov    rdi,r14
     f67:	call   rax
     f69:	test   rax,rax
     f6c:	jne    f7a <botlish_fn_7+0x1c2>
     f72:	mov    rdi,r14
     f75:	jmp    fa3 <botlish_fn_7+0x1eb>
     f7a:	sar    r15,1
     f7d:	add    r15,0x1
     f84:	shl    r15,1
     f87:	or     r15,0x1
     f8b:	mov    QWORD PTR [r13+0x8],r15
     f8f:	mov    rdi,r14
     f92:	call   f97 <botlish_fn_7+0x1df>
			f93: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     f97:	test   rax,rax
     f9a:	jne    fce <botlish_fn_7+0x216>
     fa0:	mov    rdi,r14
     fa3:	mov    rdi,r14
     fa6:	mov    QWORD PTR [rdi],r13
     fa9:	xor    rax,rax
     fac:	mov    rbx,QWORD PTR [rsp+0x10]
     fb1:	mov    r12,QWORD PTR [rsp+0x18]
     fb6:	mov    r13,QWORD PTR [rsp+0x20]
     fbb:	mov    r14,QWORD PTR [rsp+0x28]
     fc0:	mov    r15,QWORD PTR [rsp+0x30]
     fc5:	add    rsp,0x40
     fc9:	mov    rsp,rbp
     fcc:	pop    rbp
     fcd:	ret
     fce:	mov    QWORD PTR [r13+0x20],rax
     fd2:	mov    rsi,QWORD PTR [rsp+0x8]
     fd7:	mov    rcx,rsi
     fda:	and    rcx,rax
     fdd:	test   rcx,0x1
     fe4:	jne    ff2 <botlish_fn_7+0x23a>
     fea:	mov    rdx,rax
     fed:	jmp    100f <botlish_fn_7+0x257>
     ff2:	lea    rcx,[rax-0x1]
     ff6:	mov    rdx,rax
     ff9:	mov    rsi,QWORD PTR [rsp+0x8]
     ffe:	mov    rax,rsi
    1001:	add    rax,rcx
    1004:	seto   cl
    1007:	test   cl,cl
    1009:	je     1020 <botlish_fn_7+0x268>
    100f:	mov    rax,QWORD PTR [rip+0x0]        # 1016 <botlish_fn_7+0x25e>
			1012: R_X86_64_GOTPCREL	rt_int_add-0x4
    1016:	mov    rsi,QWORD PTR [rsp+0x8]
    101b:	mov    rdi,r14
    101e:	call   rax
    1020:	mov    QWORD PTR [r13+0x0],rbx
    1024:	mov    QWORD PTR [r13+0x8],r15
    1028:	mov    QWORD PTR [r13+0x10],r12
    102c:	mov    QWORD PTR [r13+0x18],rax
    1030:	mov    QWORD PTR [rsp+0x8],rax
    1035:	mov    QWORD PTR [rsp],r12
    1039:	mov    r12,r15
    103c:	mov    rsi,rbx
    103f:	jmp    e43 <botlish_fn_7+0x8b>
    1044:	mov    rdi,r14
    1047:	mov    QWORD PTR [rdi],r13
    104a:	mov    rax,QWORD PTR [rsp+0x8]
    104f:	mov    rbx,QWORD PTR [rsp+0x10]
    1054:	mov    r12,QWORD PTR [rsp+0x18]
    1059:	mov    r13,QWORD PTR [rsp+0x20]
    105e:	mov    r14,QWORD PTR [rsp+0x28]
    1063:	mov    r15,QWORD PTR [rsp+0x30]
    1068:	add    rsp,0x40
    106c:	mov    rsp,rbp
    106f:	pop    rbp
    1070:	ret
    1071:	mov    r14,rdi
    1074:	mov    rax,QWORD PTR [rip+0x0]        # 107b <botlish_fn_7+0x2c3>
			1077: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    107b:	call   rax
    107d:	xor    rax,rax
    1080:	mov    rbx,QWORD PTR [rsp+0x10]
    1085:	mov    r12,QWORD PTR [rsp+0x18]
    108a:	mov    r13,QWORD PTR [rsp+0x20]
    108f:	mov    r14,QWORD PTR [rsp+0x28]
    1094:	mov    r15,QWORD PTR [rsp+0x30]
    1099:	add    rsp,0x40
    109d:	mov    rsp,rbp
    10a0:	pop    rbp
    10a1:	ret
    10a2:	add    BYTE PTR [rax],al
    10a4:	add    BYTE PTR [rax],al
    10a6:	add    BYTE PTR [rax],al
    10a8:	(bad)
    10a9:	add    BYTE PTR [rax],al
    10ab:	add    BYTE PTR [rax],al
    10ad:	add    BYTE PTR [rax],al
	...

00000000000010b0 <botlish_entry_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
    10b0:	push   rbp
    10b1:	mov    rbp,rsp
    10b4:	mov    rsi,QWORD PTR [rdx]
    10b7:	mov    r9,QWORD PTR [rdx+0x8]
    10bb:	mov    rcx,QWORD PTR [rdx+0x10]
    10bf:	mov    r8,QWORD PTR [rdx+0x18]
    10c3:	mov    rdx,r9
    10c6:	call   10cb <botlish_entry_7+0x1b>
			10c7: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
    10cb:	mov    rsp,rbp
    10ce:	pop    rbp
    10cf:	ret

00000000000010d0 <botlish_fn_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
    10d0:	push   rbp
    10d1:	mov    rbp,rsp
    10d4:	sub    rsp,0x40
    10d8:	mov    QWORD PTR [rsp+0x10],rbx
    10dd:	mov    QWORD PTR [rsp+0x18],r12
    10e2:	mov    QWORD PTR [rsp+0x20],r13
    10e7:	mov    QWORD PTR [rsp+0x28],r14
    10ec:	mov    QWORD PTR [rsp+0x30],r15
    10f1:	mov    r14,QWORD PTR [rdi]
    10f4:	mov    rax,QWORD PTR [rdi+0x8]
    10f8:	lea    r9,[r14+0x30]
    10fc:	cmp    r9,rax
    10ff:	ja     1336 <botlish_fn_8+0x266>
    1105:	lea    rax,[r14+0x30]
    1109:	mov    QWORD PTR [rdi],rax
    110c:	mov    r15,rdi
    110f:	mov    QWORD PTR [r14],0x0
    1116:	mov    QWORD PTR [r14+0x8],0x0
    111e:	mov    QWORD PTR [r14+0x10],0x0
    1126:	mov    QWORD PTR [r14+0x18],0x0
    112e:	mov    QWORD PTR [r14+0x20],0x0
    1136:	mov    QWORD PTR [r14+0x28],0x0
    113e:	mov    QWORD PTR [r14],rsi
    1141:	mov    QWORD PTR [r14+0x8],rdx
    1145:	mov    rbx,rdx
    1148:	mov    QWORD PTR [r14+0x10],rcx
    114c:	mov    QWORD PTR [rsp],rcx
    1150:	mov    QWORD PTR [r14+0x18],r8
    1154:	mov    QWORD PTR [rsp+0x8],r8
    1159:	mov    rax,QWORD PTR [rip+0x0]        # 1160 <botlish_fn_8+0x90>
			115c: R_X86_64_GOTPCREL	rt_list_len-0x4
    1160:	mov    r12,rsi
    1163:	mov    rdi,r15
    1166:	call   rax
    1168:	mov    r13,rbx
    116b:	mov    rcx,r13
    116e:	and    rcx,rax
    1171:	mov    rdx,rax
    1174:	test   rcx,0x1
    117b:	jne    11a5 <botlish_fn_8+0xd5>
    1181:	mov    rax,QWORD PTR [rip+0x0]        # 1188 <botlish_fn_8+0xb8>
			1184: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    1188:	mov    rsi,r13
    118b:	mov    rdi,r15
    118e:	call   rax
    1190:	mov    ecx,0x2
    1195:	test   rax,rax
    1198:	cmovge rcx,QWORD PTR [rip+0x1c8]        # 1368 <botlish_fn_8+0x298>
    11a0:	jmp    11b5 <botlish_fn_8+0xe5>
    11a5:	mov    ecx,0x2
    11aa:	cmp    r13,rdx
    11ad:	cmovge rcx,QWORD PTR [rip+0x1b3]        # 1368 <botlish_fn_8+0x298>
    11b5:	cmp    rcx,0x6
    11b9:	je     1309 <botlish_fn_8+0x239>
    11bf:	mov    r8,QWORD PTR [rip+0x0]        # 11c6 <botlish_fn_8+0xf6>
			11c2: R_X86_64_GOTPCREL	rt_list_get-0x4
    11c6:	mov    rdx,r13
    11c9:	mov    rsi,r12
    11cc:	mov    rdi,r15
    11cf:	call   r8
    11d2:	test   rax,rax
    11d5:	jne    11e3 <botlish_fn_8+0x113>
    11db:	mov    rdi,r15
    11de:	jmp    1269 <botlish_fn_8+0x199>
    11e3:	mov    QWORD PTR [r14+0x20],rax
    11e7:	mov    rbx,rax
    11ea:	mov    QWORD PTR [r14+0x28],0x1
    11f2:	mov    rdi,r15
    11f5:	call   11fa <botlish_fn_8+0x12a>
			11f6: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    11fa:	test   rax,rax
    11fd:	mov    r9,rax
    1200:	jne    120e <botlish_fn_8+0x13e>
    1206:	mov    rdi,r15
    1209:	jmp    1269 <botlish_fn_8+0x199>
    120e:	mov    r8d,0x1
    1214:	mov    rax,QWORD PTR [rip+0x0]        # 121b <botlish_fn_8+0x14b>
			1217: R_X86_64_GOTPCREL	rt_mutarray_copy-0x4
    121b:	mov    rcx,rbx
    121e:	mov    rbx,QWORD PTR [rsp]
    1222:	mov    rdx,QWORD PTR [rsp+0x8]
    1227:	mov    rsi,rbx
    122a:	mov    rdi,r15
    122d:	call   rax
    122f:	test   rax,rax
    1232:	jne    1240 <botlish_fn_8+0x170>
    1238:	mov    rdi,r15
    123b:	jmp    1269 <botlish_fn_8+0x199>
    1240:	sar    r13,1
    1243:	add    r13,0x1
    124a:	shl    r13,1
    124d:	or     r13,0x1
    1251:	mov    QWORD PTR [r14+0x8],r13
    1255:	mov    rdi,r15
    1258:	call   125d <botlish_fn_8+0x18d>
			1259: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    125d:	test   rax,rax
    1260:	jne    1294 <botlish_fn_8+0x1c4>
    1266:	mov    rdi,r15
    1269:	mov    rdi,r15
    126c:	mov    QWORD PTR [rdi],r14
    126f:	xor    rax,rax
    1272:	mov    rbx,QWORD PTR [rsp+0x10]
    1277:	mov    r12,QWORD PTR [rsp+0x18]
    127c:	mov    r13,QWORD PTR [rsp+0x20]
    1281:	mov    r14,QWORD PTR [rsp+0x28]
    1286:	mov    r15,QWORD PTR [rsp+0x30]
    128b:	add    rsp,0x40
    128f:	mov    rsp,rbp
    1292:	pop    rbp
    1293:	ret
    1294:	mov    QWORD PTR [r14+0x20],rax
    1298:	mov    rsi,QWORD PTR [rsp+0x8]
    129d:	mov    rcx,rsi
    12a0:	and    rcx,rax
    12a3:	test   rcx,0x1
    12aa:	jne    12b8 <botlish_fn_8+0x1e8>
    12b0:	mov    rdx,rax
    12b3:	jmp    12d5 <botlish_fn_8+0x205>
    12b8:	lea    rcx,[rax-0x1]
    12bc:	mov    rdx,rax
    12bf:	mov    rsi,QWORD PTR [rsp+0x8]
    12c4:	mov    rax,rsi
    12c7:	add    rax,rcx
    12ca:	seto   cl
    12cd:	test   cl,cl
    12cf:	je     12e6 <botlish_fn_8+0x216>
    12d5:	mov    rax,QWORD PTR [rip+0x0]        # 12dc <botlish_fn_8+0x20c>
			12d8: R_X86_64_GOTPCREL	rt_int_add-0x4
    12dc:	mov    rsi,QWORD PTR [rsp+0x8]
    12e1:	mov    rdi,r15
    12e4:	call   rax
    12e6:	mov    QWORD PTR [r14],r12
    12e9:	mov    QWORD PTR [r14+0x8],r13
    12ed:	mov    QWORD PTR [r14+0x10],rbx
    12f1:	mov    QWORD PTR [r14+0x18],rax
    12f5:	mov    QWORD PTR [rsp+0x8],rax
    12fa:	mov    QWORD PTR [rsp],rbx
    12fe:	mov    rsi,r12
    1301:	mov    rbx,r13
    1304:	jmp    1159 <botlish_fn_8+0x89>
    1309:	mov    rdi,r15
    130c:	mov    QWORD PTR [rdi],r14
    130f:	mov    rax,QWORD PTR [rsp+0x8]
    1314:	mov    rbx,QWORD PTR [rsp+0x10]
    1319:	mov    r12,QWORD PTR [rsp+0x18]
    131e:	mov    r13,QWORD PTR [rsp+0x20]
    1323:	mov    r14,QWORD PTR [rsp+0x28]
    1328:	mov    r15,QWORD PTR [rsp+0x30]
    132d:	add    rsp,0x40
    1331:	mov    rsp,rbp
    1334:	pop    rbp
    1335:	ret
    1336:	mov    r15,rdi
    1339:	mov    rax,QWORD PTR [rip+0x0]        # 1340 <botlish_fn_8+0x270>
			133c: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1340:	call   rax
    1342:	xor    rax,rax
    1345:	mov    rbx,QWORD PTR [rsp+0x10]
    134a:	mov    r12,QWORD PTR [rsp+0x18]
    134f:	mov    r13,QWORD PTR [rsp+0x20]
    1354:	mov    r14,QWORD PTR [rsp+0x28]
    1359:	mov    r15,QWORD PTR [rsp+0x30]
    135e:	add    rsp,0x40
    1362:	mov    rsp,rbp
    1365:	pop    rbp
    1366:	ret
    1367:	add    BYTE PTR [rsi],al
    1369:	add    BYTE PTR [rax],al
    136b:	add    BYTE PTR [rax],al
    136d:	add    BYTE PTR [rax],al
	...

0000000000001370 <botlish_entry_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
    1370:	push   rbp
    1371:	mov    rbp,rsp
    1374:	mov    rsi,QWORD PTR [rdx]
    1377:	mov    r9,QWORD PTR [rdx+0x8]
    137b:	mov    rcx,QWORD PTR [rdx+0x10]
    137f:	mov    r8,QWORD PTR [rdx+0x18]
    1383:	mov    rdx,r9
    1386:	call   138b <botlish_entry_8+0x1b>
			1387: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    138b:	mov    rsp,rbp
    138e:	pop    rbp
    138f:	ret

0000000000001390 <botlish_fn_9: chunked_finish<list[list<never>, mutarray, int]>>:
    1390:	push   rbp
    1391:	mov    rbp,rsp
    1394:	sub    rsp,0x40
    1398:	mov    QWORD PTR [rsp+0x10],rbx
    139d:	mov    QWORD PTR [rsp+0x18],r12
    13a2:	mov    QWORD PTR [rsp+0x20],r13
    13a7:	mov    QWORD PTR [rsp+0x28],r14
    13ac:	mov    QWORD PTR [rsp+0x30],r15
    13b1:	mov    r12,QWORD PTR [rdi]
    13b4:	mov    rax,QWORD PTR [rdi+0x8]
    13b8:	lea    r8,[r12+0x38]
    13bd:	cmp    r8,rax
    13c0:	ja     1619 <botlish_fn_9+0x289>
    13c6:	lea    rax,[r12+0x38]
    13cb:	mov    QWORD PTR [rdi],rax
    13ce:	mov    r14,rdi
    13d1:	mov    QWORD PTR [r12],0x0
    13d9:	mov    QWORD PTR [r12+0x8],0x0
    13e2:	mov    QWORD PTR [r12+0x10],0x0
    13eb:	mov    QWORD PTR [r12+0x18],0x0
    13f4:	mov    QWORD PTR [r12+0x20],0x0
    13fd:	mov    QWORD PTR [r12+0x28],0x0
    1406:	mov    QWORD PTR [r12+0x30],0x0
    140f:	mov    QWORD PTR [r12],rsi
    1413:	mov    QWORD PTR [rsp],rsi
    1417:	mov    QWORD PTR [r12+0x8],rdx
    141c:	mov    r15,rdx
    141f:	mov    QWORD PTR [r12+0x10],rcx
    1424:	mov    rbx,rcx
    1427:	mov    rax,QWORD PTR [rip+0x0]        # 142e <botlish_fn_9+0x9e>
			142a: R_X86_64_GOTPCREL	rt_list_len-0x4
    142e:	mov    rsi,QWORD PTR [rsp]
    1432:	mov    rdi,r14
    1435:	call   rax
    1437:	mov    QWORD PTR [r12+0x18],rax
    143c:	mov    r13,rax
    143f:	mov    rdi,r14
    1442:	call   1447 <botlish_fn_9+0xb7>
			1443: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    1447:	test   rax,rax
    144a:	jne    1458 <botlish_fn_9+0xc8>
    1450:	mov    rdi,r14
    1453:	jmp    15c6 <botlish_fn_9+0x236>
    1458:	mov    QWORD PTR [r12+0x20],rax
    145d:	mov    rcx,r13
    1460:	mov    rdx,rcx
    1463:	and    rdx,rax
    1466:	mov    rdi,rax
    1469:	test   rdx,0x1
    1470:	jne    147e <botlish_fn_9+0xee>
    1476:	mov    r13,rcx
    1479:	jmp    14aa <botlish_fn_9+0x11a>
    147e:	mov    rax,rcx
    1481:	sar    rax,1
    1484:	mov    r13,rcx
    1487:	mov    rcx,rdi
    148a:	lea    rdx,[rcx-0x1]
    148e:	imul   rdx
    1491:	seto   sil
    1495:	or     rax,0x1
    1499:	test   sil,sil
    149c:	jne    14aa <botlish_fn_9+0x11a>
    14a2:	mov    rsi,rax
    14a5:	jmp    14c0 <botlish_fn_9+0x130>
    14aa:	mov    r8,QWORD PTR [rip+0x0]        # 14b1 <botlish_fn_9+0x121>
			14ad: R_X86_64_GOTPCREL	rt_int_mul-0x4
    14b1:	mov    rdx,rdi
    14b4:	mov    rsi,r13
    14b7:	mov    rdi,r14
    14ba:	call   r8
    14bd:	mov    rsi,rax
    14c0:	mov    QWORD PTR [r12+0x18],rsi
    14c5:	mov    rdi,rsi
    14c8:	and    rdi,rbx
    14cb:	test   rdi,0x1
    14d2:	je     14ef <botlish_fn_9+0x15f>
    14d8:	lea    r10,[rbx-0x1]
    14dc:	mov    r13,rsi
    14df:	add    r13,r10
    14e2:	seto   r11b
    14e6:	test   r11b,r11b
    14e9:	je     1501 <botlish_fn_9+0x171>
    14ef:	mov    rax,QWORD PTR [rip+0x0]        # 14f6 <botlish_fn_9+0x166>
			14f2: R_X86_64_GOTPCREL	rt_int_add-0x4
    14f6:	mov    rdx,rbx
    14f9:	mov    rdi,r14
    14fc:	call   rax
    14fe:	mov    r13,rax
    1501:	mov    QWORD PTR [r12+0x18],r13
    1506:	mov    rax,QWORD PTR [rip+0x0]        # 150d <botlish_fn_9+0x17d>
			1509: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    150d:	mov    rsi,r13
    1510:	mov    rdi,r14
    1513:	call   rax
    1515:	mov    rsi,rax
    1518:	mov    QWORD PTR [rsp+0x8],rax
    151d:	test   rax,rsi
    1520:	jne    152e <botlish_fn_9+0x19e>
    1526:	mov    rdi,r14
    1529:	jmp    15c6 <botlish_fn_9+0x236>
    152e:	mov    rax,QWORD PTR [rsp+0x8]
    1533:	mov    QWORD PTR [r12+0x20],rax
    1538:	mov    r8d,0x1
    153e:	mov    QWORD PTR [r12+0x28],0x1
    1547:	mov    QWORD PTR [r12+0x30],0x1
    1550:	mov    rsi,QWORD PTR [rsp]
    1554:	mov    rcx,QWORD PTR [rsp+0x8]
    1559:	mov    rdi,r14
    155c:	mov    rdx,r8
    155f:	call   1564 <botlish_fn_9+0x1d4>
			1560: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
    1564:	test   rax,rax
    1567:	mov    rdx,rax
    156a:	jne    1578 <botlish_fn_9+0x1e8>
    1570:	mov    rdi,r14
    1573:	jmp    15c6 <botlish_fn_9+0x236>
    1578:	mov    r8d,0x1
    157e:	mov    rax,QWORD PTR [rip+0x0]        # 1585 <botlish_fn_9+0x1f5>
			1581: R_X86_64_GOTPCREL	rt_mutarray_copy-0x4
    1585:	mov    rcx,r15
    1588:	mov    r9,rbx
    158b:	mov    rsi,QWORD PTR [rsp+0x8]
    1590:	mov    rdi,r14
    1593:	call   rax
    1595:	test   rax,rax
    1598:	jne    15a6 <botlish_fn_9+0x216>
    159e:	mov    rdi,r14
    15a1:	jmp    15c6 <botlish_fn_9+0x236>
    15a6:	mov    rax,QWORD PTR [rip+0x0]        # 15ad <botlish_fn_9+0x21d>
			15a9: R_X86_64_GOTPCREL	rt_mutarray_freeze-0x4
    15ad:	mov    rdx,r13
    15b0:	mov    rsi,QWORD PTR [rsp+0x8]
    15b5:	mov    rdi,r14
    15b8:	call   rax
    15ba:	test   rax,rax
    15bd:	jne    15f1 <botlish_fn_9+0x261>
    15c3:	mov    rdi,r14
    15c6:	mov    rdi,r14
    15c9:	mov    QWORD PTR [rdi],r12
    15cc:	xor    rax,rax
    15cf:	mov    rbx,QWORD PTR [rsp+0x10]
    15d4:	mov    r12,QWORD PTR [rsp+0x18]
    15d9:	mov    r13,QWORD PTR [rsp+0x20]
    15de:	mov    r14,QWORD PTR [rsp+0x28]
    15e3:	mov    r15,QWORD PTR [rsp+0x30]
    15e8:	add    rsp,0x40
    15ec:	mov    rsp,rbp
    15ef:	pop    rbp
    15f0:	ret
    15f1:	mov    rdi,r14
    15f4:	mov    QWORD PTR [rdi],r12
    15f7:	mov    rbx,QWORD PTR [rsp+0x10]
    15fc:	mov    r12,QWORD PTR [rsp+0x18]
    1601:	mov    r13,QWORD PTR [rsp+0x20]
    1606:	mov    r14,QWORD PTR [rsp+0x28]
    160b:	mov    r15,QWORD PTR [rsp+0x30]
    1610:	add    rsp,0x40
    1614:	mov    rsp,rbp
    1617:	pop    rbp
    1618:	ret
    1619:	mov    r14,rdi
    161c:	mov    rax,QWORD PTR [rip+0x0]        # 1623 <botlish_fn_9+0x293>
			161f: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1623:	call   rax
    1625:	xor    rax,rax
    1628:	mov    rbx,QWORD PTR [rsp+0x10]
    162d:	mov    r12,QWORD PTR [rsp+0x18]
    1632:	mov    r13,QWORD PTR [rsp+0x20]
    1637:	mov    r14,QWORD PTR [rsp+0x28]
    163c:	mov    r15,QWORD PTR [rsp+0x30]
    1641:	add    rsp,0x40
    1645:	mov    rsp,rbp
    1648:	pop    rbp
    1649:	ret

000000000000164a <botlish_entry_9: chunked_finish<list[list<never>, mutarray, int]>>:
    164a:	push   rbp
    164b:	mov    rbp,rsp
    164e:	mov    rsi,QWORD PTR [rdx]
    1651:	mov    r8,QWORD PTR [rdx+0x8]
    1655:	mov    rcx,QWORD PTR [rdx+0x10]
    1659:	mov    rdx,r8
    165c:	call   1661 <botlish_entry_9+0x17>
			165d: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    1661:	mov    rsp,rbp
    1664:	pop    rbp
    1665:	ret

0000000000001666 <botlish_fn_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    1666:	push   rbp
    1667:	mov    rbp,rsp
    166a:	sub    rsp,0x40
    166e:	mov    QWORD PTR [rsp+0x10],rbx
    1673:	mov    QWORD PTR [rsp+0x18],r12
    1678:	mov    QWORD PTR [rsp+0x20],r13
    167d:	mov    QWORD PTR [rsp+0x28],r14
    1682:	mov    QWORD PTR [rsp+0x30],r15
    1687:	mov    r12,QWORD PTR [rdi]
    168a:	mov    rax,QWORD PTR [rdi+0x8]
    168e:	lea    r8,[r12+0x38]
    1693:	cmp    r8,rax
    1696:	ja     18ef <botlish_fn_10+0x289>
    169c:	lea    rax,[r12+0x38]
    16a1:	mov    QWORD PTR [rdi],rax
    16a4:	mov    r14,rdi
    16a7:	mov    QWORD PTR [r12],0x0
    16af:	mov    QWORD PTR [r12+0x8],0x0
    16b8:	mov    QWORD PTR [r12+0x10],0x0
    16c1:	mov    QWORD PTR [r12+0x18],0x0
    16ca:	mov    QWORD PTR [r12+0x20],0x0
    16d3:	mov    QWORD PTR [r12+0x28],0x0
    16dc:	mov    QWORD PTR [r12+0x30],0x0
    16e5:	mov    QWORD PTR [r12],rsi
    16e9:	mov    QWORD PTR [rsp],rsi
    16ed:	mov    QWORD PTR [r12+0x8],rdx
    16f2:	mov    r15,rdx
    16f5:	mov    QWORD PTR [r12+0x10],rcx
    16fa:	mov    rbx,rcx
    16fd:	mov    rax,QWORD PTR [rip+0x0]        # 1704 <botlish_fn_10+0x9e>
			1700: R_X86_64_GOTPCREL	rt_list_len-0x4
    1704:	mov    rsi,QWORD PTR [rsp]
    1708:	mov    rdi,r14
    170b:	call   rax
    170d:	mov    QWORD PTR [r12+0x18],rax
    1712:	mov    r13,rax
    1715:	mov    rdi,r14
    1718:	call   171d <botlish_fn_10+0xb7>
			1719: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    171d:	test   rax,rax
    1720:	jne    172e <botlish_fn_10+0xc8>
    1726:	mov    rdi,r14
    1729:	jmp    189c <botlish_fn_10+0x236>
    172e:	mov    QWORD PTR [r12+0x20],rax
    1733:	mov    rcx,r13
    1736:	mov    rdx,rcx
    1739:	and    rdx,rax
    173c:	mov    rdi,rax
    173f:	test   rdx,0x1
    1746:	jne    1754 <botlish_fn_10+0xee>
    174c:	mov    r13,rcx
    174f:	jmp    1780 <botlish_fn_10+0x11a>
    1754:	mov    rax,rcx
    1757:	sar    rax,1
    175a:	mov    r13,rcx
    175d:	mov    rcx,rdi
    1760:	lea    rdx,[rcx-0x1]
    1764:	imul   rdx
    1767:	seto   sil
    176b:	or     rax,0x1
    176f:	test   sil,sil
    1772:	jne    1780 <botlish_fn_10+0x11a>
    1778:	mov    rsi,rax
    177b:	jmp    1796 <botlish_fn_10+0x130>
    1780:	mov    r8,QWORD PTR [rip+0x0]        # 1787 <botlish_fn_10+0x121>
			1783: R_X86_64_GOTPCREL	rt_int_mul-0x4
    1787:	mov    rdx,rdi
    178a:	mov    rsi,r13
    178d:	mov    rdi,r14
    1790:	call   r8
    1793:	mov    rsi,rax
    1796:	mov    QWORD PTR [r12+0x18],rsi
    179b:	mov    rdi,rsi
    179e:	and    rdi,rbx
    17a1:	test   rdi,0x1
    17a8:	je     17c5 <botlish_fn_10+0x15f>
    17ae:	lea    r10,[rbx-0x1]
    17b2:	mov    r13,rsi
    17b5:	add    r13,r10
    17b8:	seto   r11b
    17bc:	test   r11b,r11b
    17bf:	je     17d7 <botlish_fn_10+0x171>
    17c5:	mov    rax,QWORD PTR [rip+0x0]        # 17cc <botlish_fn_10+0x166>
			17c8: R_X86_64_GOTPCREL	rt_int_add-0x4
    17cc:	mov    rdx,rbx
    17cf:	mov    rdi,r14
    17d2:	call   rax
    17d4:	mov    r13,rax
    17d7:	mov    QWORD PTR [r12+0x18],r13
    17dc:	mov    rax,QWORD PTR [rip+0x0]        # 17e3 <botlish_fn_10+0x17d>
			17df: R_X86_64_GOTPCREL	rt_mutarray_allocate-0x4
    17e3:	mov    rsi,r13
    17e6:	mov    rdi,r14
    17e9:	call   rax
    17eb:	mov    rsi,rax
    17ee:	mov    QWORD PTR [rsp+0x8],rax
    17f3:	test   rax,rsi
    17f6:	jne    1804 <botlish_fn_10+0x19e>
    17fc:	mov    rdi,r14
    17ff:	jmp    189c <botlish_fn_10+0x236>
    1804:	mov    rax,QWORD PTR [rsp+0x8]
    1809:	mov    QWORD PTR [r12+0x20],rax
    180e:	mov    r8d,0x1
    1814:	mov    QWORD PTR [r12+0x28],0x1
    181d:	mov    QWORD PTR [r12+0x30],0x1
    1826:	mov    rsi,QWORD PTR [rsp]
    182a:	mov    rcx,QWORD PTR [rsp+0x8]
    182f:	mov    rdi,r14
    1832:	mov    rdx,r8
    1835:	call   183a <botlish_fn_10+0x1d4>
			1836: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    183a:	test   rax,rax
    183d:	mov    rdx,rax
    1840:	jne    184e <botlish_fn_10+0x1e8>
    1846:	mov    rdi,r14
    1849:	jmp    189c <botlish_fn_10+0x236>
    184e:	mov    r8d,0x1
    1854:	mov    rax,QWORD PTR [rip+0x0]        # 185b <botlish_fn_10+0x1f5>
			1857: R_X86_64_GOTPCREL	rt_mutarray_copy-0x4
    185b:	mov    rcx,r15
    185e:	mov    r9,rbx
    1861:	mov    rsi,QWORD PTR [rsp+0x8]
    1866:	mov    rdi,r14
    1869:	call   rax
    186b:	test   rax,rax
    186e:	jne    187c <botlish_fn_10+0x216>
    1874:	mov    rdi,r14
    1877:	jmp    189c <botlish_fn_10+0x236>
    187c:	mov    rax,QWORD PTR [rip+0x0]        # 1883 <botlish_fn_10+0x21d>
			187f: R_X86_64_GOTPCREL	rt_mutarray_freeze-0x4
    1883:	mov    rdx,r13
    1886:	mov    rsi,QWORD PTR [rsp+0x8]
    188b:	mov    rdi,r14
    188e:	call   rax
    1890:	test   rax,rax
    1893:	jne    18c7 <botlish_fn_10+0x261>
    1899:	mov    rdi,r14
    189c:	mov    rdi,r14
    189f:	mov    QWORD PTR [rdi],r12
    18a2:	xor    rax,rax
    18a5:	mov    rbx,QWORD PTR [rsp+0x10]
    18aa:	mov    r12,QWORD PTR [rsp+0x18]
    18af:	mov    r13,QWORD PTR [rsp+0x20]
    18b4:	mov    r14,QWORD PTR [rsp+0x28]
    18b9:	mov    r15,QWORD PTR [rsp+0x30]
    18be:	add    rsp,0x40
    18c2:	mov    rsp,rbp
    18c5:	pop    rbp
    18c6:	ret
    18c7:	mov    rdi,r14
    18ca:	mov    QWORD PTR [rdi],r12
    18cd:	mov    rbx,QWORD PTR [rsp+0x10]
    18d2:	mov    r12,QWORD PTR [rsp+0x18]
    18d7:	mov    r13,QWORD PTR [rsp+0x20]
    18dc:	mov    r14,QWORD PTR [rsp+0x28]
    18e1:	mov    r15,QWORD PTR [rsp+0x30]
    18e6:	add    rsp,0x40
    18ea:	mov    rsp,rbp
    18ed:	pop    rbp
    18ee:	ret
    18ef:	mov    r14,rdi
    18f2:	mov    rax,QWORD PTR [rip+0x0]        # 18f9 <botlish_fn_10+0x293>
			18f5: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    18f9:	call   rax
    18fb:	xor    rax,rax
    18fe:	mov    rbx,QWORD PTR [rsp+0x10]
    1903:	mov    r12,QWORD PTR [rsp+0x18]
    1908:	mov    r13,QWORD PTR [rsp+0x20]
    190d:	mov    r14,QWORD PTR [rsp+0x28]
    1912:	mov    r15,QWORD PTR [rsp+0x30]
    1917:	add    rsp,0x40
    191b:	mov    rsp,rbp
    191e:	pop    rbp
    191f:	ret

0000000000001920 <botlish_entry_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    1920:	push   rbp
    1921:	mov    rbp,rsp
    1924:	mov    rsi,QWORD PTR [rdx]
    1927:	mov    r8,QWORD PTR [rdx+0x8]
    192b:	mov    rcx,QWORD PTR [rdx+0x10]
    192f:	mov    rdx,r8
    1932:	call   1937 <botlish_entry_10+0x17>
			1933: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    1937:	mov    rsp,rbp
    193a:	pop    rbp
    193b:	ret
    193c:	add    BYTE PTR [rax],al
	...

0000000000001940 <botlish_fn_11: peek<str, int>>:
    1940:	push   rbp
    1941:	mov    rbp,rsp
    1944:	sub    rsp,0x20
    1948:	mov    QWORD PTR [rsp],rbx
    194c:	mov    QWORD PTR [rsp+0x8],r12
    1951:	mov    QWORD PTR [rsp+0x10],r13
    1956:	mov    QWORD PTR [rsp+0x18],r14
    195b:	mov    r12,QWORD PTR [rdi]
    195e:	mov    rax,QWORD PTR [rdi+0x8]
    1962:	lea    rcx,[r12+0x18]
    1967:	cmp    rcx,rax
    196a:	ja     1ad7 <botlish_fn_11+0x197>
    1970:	lea    rax,[r12+0x18]
    1975:	mov    QWORD PTR [rdi],rax
    1978:	mov    r13,rdi
    197b:	mov    QWORD PTR [r12],0x0
    1983:	mov    QWORD PTR [r12+0x8],0x0
    198c:	mov    QWORD PTR [r12+0x10],0x0
    1995:	mov    QWORD PTR [r12],rsi
    1999:	mov    r14,rsi
    199c:	mov    QWORD PTR [r12+0x8],rdx
    19a1:	mov    rbx,rdx
    19a4:	mov    rax,QWORD PTR [rip+0x0]        # 19ab <botlish_fn_11+0x6b>
			19a7: R_X86_64_GOTPCREL	rt_str_len-0x4
    19ab:	mov    rsi,r14
    19ae:	mov    rdi,r13
    19b1:	call   rax
    19b3:	mov    rcx,rbx
    19b6:	and    rcx,rax
    19b9:	mov    rdx,rax
    19bc:	test   rcx,0x1
    19c3:	jne    19ed <botlish_fn_11+0xad>
    19c9:	mov    rax,QWORD PTR [rip+0x0]        # 19d0 <botlish_fn_11+0x90>
			19cc: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    19d0:	mov    rsi,rbx
    19d3:	mov    rdi,r13
    19d6:	call   rax
    19d8:	mov    ecx,0x2
    19dd:	test   rax,rax
    19e0:	cmovge rcx,QWORD PTR [rip+0x120]        # 1b08 <botlish_fn_11+0x1c8>
    19e8:	jmp    19fd <botlish_fn_11+0xbd>
    19ed:	mov    ecx,0x2
    19f2:	cmp    rbx,rdx
    19f5:	cmovge rcx,QWORD PTR [rip+0x10b]        # 1b08 <botlish_fn_11+0x1c8>
    19fd:	cmp    rcx,0x6
    1a01:	je     1aad <botlish_fn_11+0x16d>
    1a07:	mov    QWORD PTR [r12+0x10],0x3
    1a10:	test   rbx,0x1
    1a17:	je     1a2f <botlish_fn_11+0xef>
    1a1d:	mov    rcx,rbx
    1a20:	add    rcx,0x2
    1a24:	seto   al
    1a27:	test   al,al
    1a29:	je     1a46 <botlish_fn_11+0x106>
    1a2f:	mov    edx,0x3
    1a34:	mov    rax,QWORD PTR [rip+0x0]        # 1a3b <botlish_fn_11+0xfb>
			1a37: R_X86_64_GOTPCREL	rt_int_add-0x4
    1a3b:	mov    rsi,rbx
    1a3e:	mov    rdi,r13
    1a41:	call   rax
    1a43:	mov    rcx,rax
    1a46:	mov    QWORD PTR [r12+0x10],rcx
    1a4b:	mov    rax,QWORD PTR [rip+0x0]        # 1a52 <botlish_fn_11+0x112>
			1a4e: R_X86_64_GOTPCREL	rt_substr-0x4
    1a52:	mov    rdx,rbx
    1a55:	mov    rsi,r14
    1a58:	mov    rdi,r13
    1a5b:	call   rax
    1a5d:	test   rax,rax
    1a60:	jne    1a8b <botlish_fn_11+0x14b>
    1a66:	mov    rdi,r13
    1a69:	mov    QWORD PTR [rdi],r12
    1a6c:	xor    rax,rax
    1a6f:	mov    rbx,QWORD PTR [rsp]
    1a73:	mov    r12,QWORD PTR [rsp+0x8]
    1a78:	mov    r13,QWORD PTR [rsp+0x10]
    1a7d:	mov    r14,QWORD PTR [rsp+0x18]
    1a82:	add    rsp,0x20
    1a86:	mov    rsp,rbp
    1a89:	pop    rbp
    1a8a:	ret
    1a8b:	mov    rdi,r13
    1a8e:	mov    QWORD PTR [rdi],r12
    1a91:	mov    rbx,QWORD PTR [rsp]
    1a95:	mov    r12,QWORD PTR [rsp+0x8]
    1a9a:	mov    r13,QWORD PTR [rsp+0x10]
    1a9f:	mov    r14,QWORD PTR [rsp+0x18]
    1aa4:	add    rsp,0x20
    1aa8:	mov    rsp,rbp
    1aab:	pop    rbp
    1aac:	ret
    1aad:	mov    rdi,r13
    1ab0:	mov    rsi,QWORD PTR [rdi+0x10]
    1ab4:	mov    rax,QWORD PTR [rsi+0x10]
    1ab8:	mov    QWORD PTR [rdi],r12
    1abb:	mov    rbx,QWORD PTR [rsp]
    1abf:	mov    r12,QWORD PTR [rsp+0x8]
    1ac4:	mov    r13,QWORD PTR [rsp+0x10]
    1ac9:	mov    r14,QWORD PTR [rsp+0x18]
    1ace:	add    rsp,0x20
    1ad2:	mov    rsp,rbp
    1ad5:	pop    rbp
    1ad6:	ret
    1ad7:	mov    r13,rdi
    1ada:	mov    rsi,QWORD PTR [rip+0x0]        # 1ae1 <botlish_fn_11+0x1a1>
			1add: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1ae1:	call   rsi
    1ae3:	xor    rax,rax
    1ae6:	mov    rbx,QWORD PTR [rsp]
    1aea:	mov    r12,QWORD PTR [rsp+0x8]
    1aef:	mov    r13,QWORD PTR [rsp+0x10]
    1af4:	mov    r14,QWORD PTR [rsp+0x18]
    1af9:	add    rsp,0x20
    1afd:	mov    rsp,rbp
    1b00:	pop    rbp
    1b01:	ret
    1b02:	add    BYTE PTR [rax],al
    1b04:	add    BYTE PTR [rax],al
    1b06:	add    BYTE PTR [rax],al
    1b08:	(bad)
    1b09:	add    BYTE PTR [rax],al
    1b0b:	add    BYTE PTR [rax],al
    1b0d:	add    BYTE PTR [rax],al
	...

0000000000001b10 <botlish_entry_11: peek<str, int>>:
    1b10:	push   rbp
    1b11:	mov    rbp,rsp
    1b14:	mov    rsi,QWORD PTR [rdx]
    1b17:	mov    rdx,QWORD PTR [rdx+0x8]
    1b1b:	call   1b20 <botlish_entry_11+0x10>
			1b1c: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1b20:	mov    rsp,rbp
    1b23:	pop    rbp
    1b24:	ret
    1b25:	add    BYTE PTR [rax],al
	...

0000000000001b28 <botlish_fn_12: peek<str, int>>:
    1b28:	push   rbp
    1b29:	mov    rbp,rsp
    1b2c:	sub    rsp,0x40
    1b30:	mov    QWORD PTR [rsp+0x10],rbx
    1b35:	mov    QWORD PTR [rsp+0x18],r12
    1b3a:	mov    QWORD PTR [rsp+0x20],r13
    1b3f:	mov    QWORD PTR [rsp+0x28],r14
    1b44:	mov    QWORD PTR [rsp+0x30],r15
    1b49:	mov    r13,rcx
    1b4c:	mov    r12,QWORD PTR [rdi]
    1b4f:	mov    rax,QWORD PTR [rdi+0x8]
    1b53:	lea    rcx,[r12+0x18]
    1b58:	cmp    rcx,rax
    1b5b:	ja     1d07 <botlish_fn_12+0x1df>
    1b61:	lea    rax,[r12+0x18]
    1b66:	mov    QWORD PTR [rdi],rax
    1b69:	mov    r15,rdi
    1b6c:	mov    QWORD PTR [r12],0x0
    1b74:	mov    QWORD PTR [r12+0x8],0x0
    1b7d:	mov    QWORD PTR [r12+0x10],0x0
    1b86:	mov    QWORD PTR [r12],rsi
    1b8a:	mov    r14,rsi
    1b8d:	mov    QWORD PTR [r12+0x8],rdx
    1b92:	mov    rbx,rdx
    1b95:	mov    rax,QWORD PTR [rip+0x0]        # 1b9c <botlish_fn_12+0x74>
			1b98: R_X86_64_GOTPCREL	rt_str_len-0x4
    1b9c:	mov    rsi,r14
    1b9f:	mov    rdi,r15
    1ba2:	call   rax
    1ba4:	mov    rcx,rbx
    1ba7:	and    rcx,rax
    1baa:	mov    rdx,rax
    1bad:	test   rcx,0x1
    1bb4:	jne    1bde <botlish_fn_12+0xb6>
    1bba:	mov    rax,QWORD PTR [rip+0x0]        # 1bc1 <botlish_fn_12+0x99>
			1bbd: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    1bc1:	mov    rsi,rbx
    1bc4:	mov    rdi,r15
    1bc7:	call   rax
    1bc9:	mov    ecx,0x2
    1bce:	test   rax,rax
    1bd1:	cmovge rcx,QWORD PTR [rip+0x167]        # 1d40 <botlish_fn_12+0x218>
    1bd9:	jmp    1bee <botlish_fn_12+0xc6>
    1bde:	mov    ecx,0x2
    1be3:	cmp    rbx,rdx
    1be6:	cmovge rcx,QWORD PTR [rip+0x152]        # 1d40 <botlish_fn_12+0x218>
    1bee:	cmp    rcx,0x6
    1bf2:	je     1cc5 <botlish_fn_12+0x19d>
    1bf8:	mov    QWORD PTR [r12+0x10],0x3
    1c01:	test   rbx,0x1
    1c08:	je     1c29 <botlish_fn_12+0x101>
    1c0e:	mov    rax,rbx
    1c11:	add    rax,0x2
    1c15:	seto   cl
    1c18:	test   cl,cl
    1c1a:	jne    1c29 <botlish_fn_12+0x101>
    1c20:	mov    QWORD PTR [rsp],rax
    1c24:	jmp    1c41 <botlish_fn_12+0x119>
    1c29:	mov    edx,0x3
    1c2e:	mov    rax,QWORD PTR [rip+0x0]        # 1c35 <botlish_fn_12+0x10d>
			1c31: R_X86_64_GOTPCREL	rt_int_add-0x4
    1c35:	mov    rsi,rbx
    1c38:	mov    rdi,r15
    1c3b:	call   rax
    1c3d:	mov    QWORD PTR [rsp],rax
    1c41:	mov    r8,QWORD PTR [rip+0x0]        # 1c48 <botlish_fn_12+0x120>
			1c44: R_X86_64_GOTPCREL	rt_str_region_check-0x4
    1c48:	mov    rcx,QWORD PTR [rsp]
    1c4c:	mov    rdx,rbx
    1c4f:	mov    rsi,r14
    1c52:	mov    rdi,r15
    1c55:	call   r8
    1c58:	test   rax,rax
    1c5b:	jne    1c8c <botlish_fn_12+0x164>
    1c61:	mov    rdi,r15
    1c64:	mov    QWORD PTR [rdi],r12
    1c67:	xor    rax,rax
    1c6a:	mov    rbx,QWORD PTR [rsp+0x10]
    1c6f:	mov    r12,QWORD PTR [rsp+0x18]
    1c74:	mov    r13,QWORD PTR [rsp+0x20]
    1c79:	mov    r14,QWORD PTR [rsp+0x28]
    1c7e:	mov    r15,QWORD PTR [rsp+0x30]
    1c83:	add    rsp,0x40
    1c87:	mov    rsp,rbp
    1c8a:	pop    rbp
    1c8b:	ret
    1c8c:	mov    rdi,r15
    1c8f:	mov    QWORD PTR [rdi],r12
    1c92:	mov    rcx,r13
    1c95:	mov    QWORD PTR [rcx],rbx
    1c98:	mov    rax,QWORD PTR [rsp]
    1c9c:	mov    QWORD PTR [rcx+0x8],rax
    1ca0:	mov    rax,r14
    1ca3:	mov    rbx,QWORD PTR [rsp+0x10]
    1ca8:	mov    r12,QWORD PTR [rsp+0x18]
    1cad:	mov    r13,QWORD PTR [rsp+0x20]
    1cb2:	mov    r14,QWORD PTR [rsp+0x28]
    1cb7:	mov    r15,QWORD PTR [rsp+0x30]
    1cbc:	add    rsp,0x40
    1cc0:	mov    rsp,rbp
    1cc3:	pop    rbp
    1cc4:	ret
    1cc5:	mov    rcx,r13
    1cc8:	mov    rdi,r15
    1ccb:	mov    rsi,QWORD PTR [rdi+0x10]
    1ccf:	mov    rax,QWORD PTR [rsi+0x10]
    1cd3:	mov    QWORD PTR [rdi],r12
    1cd6:	mov    QWORD PTR [rcx],0x1
    1cdd:	mov    QWORD PTR [rcx+0x8],0x1
    1ce5:	mov    rbx,QWORD PTR [rsp+0x10]
    1cea:	mov    r12,QWORD PTR [rsp+0x18]
    1cef:	mov    r13,QWORD PTR [rsp+0x20]
    1cf4:	mov    r14,QWORD PTR [rsp+0x28]
    1cf9:	mov    r15,QWORD PTR [rsp+0x30]
    1cfe:	add    rsp,0x40
    1d02:	mov    rsp,rbp
    1d05:	pop    rbp
    1d06:	ret
    1d07:	mov    r15,rdi
    1d0a:	mov    r10,QWORD PTR [rip+0x0]        # 1d11 <botlish_fn_12+0x1e9>
			1d0d: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1d11:	call   r10
    1d14:	xor    rax,rax
    1d17:	mov    rbx,QWORD PTR [rsp+0x10]
    1d1c:	mov    r12,QWORD PTR [rsp+0x18]
    1d21:	mov    r13,QWORD PTR [rsp+0x20]
    1d26:	mov    r14,QWORD PTR [rsp+0x28]
    1d2b:	mov    r15,QWORD PTR [rsp+0x30]
    1d30:	add    rsp,0x40
    1d34:	mov    rsp,rbp
    1d37:	pop    rbp
    1d38:	ret
    1d39:	add    BYTE PTR [rax],al
    1d3b:	add    BYTE PTR [rax],al
    1d3d:	add    BYTE PTR [rax],al
    1d3f:	add    BYTE PTR [rsi],al
    1d41:	add    BYTE PTR [rax],al
    1d43:	add    BYTE PTR [rax],al
    1d45:	add    BYTE PTR [rax],al
	...

0000000000001d48 <botlish_entry_12: peek<str, int>>:
    1d48:	push   rbp
    1d49:	mov    rbp,rsp
    1d4c:	ud2

0000000000001d4e <botlish_fn_13: scan_unquoted<str, int, int>>:
    1d4e:	push   rbp
    1d4f:	mov    rbp,rsp
    1d52:	sub    rsp,0x60
    1d56:	mov    QWORD PTR [rsp+0x30],rbx
    1d5b:	mov    QWORD PTR [rsp+0x38],r12
    1d60:	mov    QWORD PTR [rsp+0x40],r13
    1d65:	mov    QWORD PTR [rsp+0x48],r14
    1d6a:	mov    QWORD PTR [rsp+0x50],r15
    1d6f:	mov    r14,QWORD PTR [rdi]
    1d72:	mov    rax,QWORD PTR [rdi+0x8]
    1d76:	lea    r8,[r14+0x20]
    1d7a:	cmp    r8,rax
    1d7d:	ja     1fbc <botlish_fn_13+0x26e>
    1d83:	lea    rax,[r14+0x20]
    1d87:	mov    QWORD PTR [rdi],rax
    1d8a:	mov    r15,rdi
    1d8d:	mov    QWORD PTR [r14],0x0
    1d94:	mov    QWORD PTR [r14+0x8],0x0
    1d9c:	mov    QWORD PTR [r14+0x10],0x0
    1da4:	mov    QWORD PTR [r14+0x18],0x0
    1dac:	mov    QWORD PTR [r14],rsi
    1daf:	mov    QWORD PTR [rsp+0x10],rsi
    1db4:	mov    QWORD PTR [r14+0x8],rdx
    1db8:	mov    QWORD PTR [rsp+0x18],rdx
    1dbd:	mov    QWORD PTR [r14+0x10],rcx
    1dc1:	lea    rbx,[rsp]
    1dc5:	mov    QWORD PTR [rsp+0x20],rcx
    1dca:	mov    rcx,rbx
    1dcd:	mov    rdx,QWORD PTR [rsp+0x20]
    1dd2:	mov    rsi,QWORD PTR [rsp+0x10]
    1dd7:	mov    rdi,r15
    1dda:	call   1ddf <botlish_fn_13+0x91>
			1ddb: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1ddf:	mov    rcx,rax
    1de2:	mov    QWORD PTR [rsp+0x28],rax
    1de7:	test   rax,rcx
    1dea:	jne    1df8 <botlish_fn_13+0xaa>
    1df0:	mov    rdi,r15
    1df3:	jmp    1f61 <botlish_fn_13+0x213>
    1df8:	mov    r12,QWORD PTR [rsp]
    1dfc:	mov    r13,QWORD PTR [rsp+0x8]
    1e01:	mov    rdi,r15
    1e04:	mov    rcx,QWORD PTR [rdi+0x10]
    1e08:	mov    r8,QWORD PTR [rcx+0x10]
    1e0c:	mov    r9,QWORD PTR [rip+0x0]        # 1e13 <botlish_fn_13+0xc5>
			1e0f: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1e13:	mov    rcx,r13
    1e16:	mov    rdx,r12
    1e19:	mov    rsi,QWORD PTR [rsp+0x28]
    1e1e:	call   r9
    1e21:	cmp    rax,0x6
    1e25:	je     1e69 <botlish_fn_13+0x11b>
    1e2b:	mov    rdi,r15
    1e2e:	mov    rdx,QWORD PTR [rdi+0x10]
    1e32:	mov    r8,QWORD PTR [rdx+0x18]
    1e36:	mov    r9,QWORD PTR [rip+0x0]        # 1e3d <botlish_fn_13+0xef>
			1e39: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1e3d:	mov    rcx,r13
    1e40:	mov    rdx,r12
    1e43:	mov    rsi,QWORD PTR [rsp+0x28]
    1e48:	call   r9
    1e4b:	cmp    rax,0x6
    1e4f:	je     1e5f <botlish_fn_13+0x111>
    1e55:	mov    eax,0x2
    1e5a:	jmp    1e6e <botlish_fn_13+0x120>
    1e5f:	mov    eax,0x6
    1e64:	jmp    1e6e <botlish_fn_13+0x120>
    1e69:	mov    eax,0x6
    1e6e:	cmp    rax,0x6
    1e72:	je     1eb6 <botlish_fn_13+0x168>
    1e78:	mov    rdi,r15
    1e7b:	mov    r10,QWORD PTR [rdi+0x10]
    1e7f:	mov    r8,QWORD PTR [r10+0x20]
    1e83:	mov    r10,QWORD PTR [rip+0x0]        # 1e8a <botlish_fn_13+0x13c>
			1e86: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    1e8a:	mov    rcx,r13
    1e8d:	mov    rdx,r12
    1e90:	mov    rsi,QWORD PTR [rsp+0x28]
    1e95:	call   r10
    1e98:	cmp    rax,0x6
    1e9c:	je     1eac <botlish_fn_13+0x15e>
    1ea2:	mov    eax,0x2
    1ea7:	jmp    1ebb <botlish_fn_13+0x16d>
    1eac:	mov    eax,0x6
    1eb1:	jmp    1ebb <botlish_fn_13+0x16d>
    1eb6:	mov    eax,0x6
    1ebb:	cmp    rax,0x6
    1ebf:	je     1f3a <botlish_fn_13+0x1ec>
    1ec5:	mov    QWORD PTR [r14+0x18],0x3
    1ecd:	mov    rsi,QWORD PTR [rsp+0x20]
    1ed2:	test   rsi,0x1
    1ed9:	je     1f00 <botlish_fn_13+0x1b2>
    1edf:	mov    rsi,QWORD PTR [rsp+0x20]
    1ee4:	mov    rax,rsi
    1ee7:	add    rax,0x2
    1eeb:	seto   cl
    1eee:	test   cl,cl
    1ef0:	jne    1f00 <botlish_fn_13+0x1b2>
    1ef6:	mov    rsi,QWORD PTR [rsp+0x10]
    1efb:	jmp    1f1b <botlish_fn_13+0x1cd>
    1f00:	mov    edx,0x3
    1f05:	mov    rax,QWORD PTR [rip+0x0]        # 1f0c <botlish_fn_13+0x1be>
			1f08: R_X86_64_GOTPCREL	rt_int_add-0x4
    1f0c:	mov    rsi,QWORD PTR [rsp+0x20]
    1f11:	mov    rdi,r15
    1f14:	call   rax
    1f16:	mov    rsi,QWORD PTR [rsp+0x10]
    1f1b:	mov    QWORD PTR [r14],rsi
    1f1e:	mov    rdx,QWORD PTR [rsp+0x18]
    1f23:	mov    QWORD PTR [r14+0x8],rdx
    1f27:	mov    QWORD PTR [r14+0x10],rax
    1f2b:	mov    QWORD PTR [rsp+0x10],rsi
    1f30:	mov    QWORD PTR [rsp+0x20],rax
    1f35:	jmp    1dca <botlish_fn_13+0x7c>
    1f3a:	mov    rdx,QWORD PTR [rsp+0x18]
    1f3f:	mov    rsi,QWORD PTR [rsp+0x10]
    1f44:	mov    rax,QWORD PTR [rip+0x0]        # 1f4b <botlish_fn_13+0x1fd>
			1f47: R_X86_64_GOTPCREL	rt_substr-0x4
    1f4b:	mov    rcx,QWORD PTR [rsp+0x20]
    1f50:	mov    rdi,r15
    1f53:	call   rax
    1f55:	test   rax,rax
    1f58:	jne    1f8f <botlish_fn_13+0x241>
    1f5e:	mov    rdi,r15
    1f61:	mov    rdi,r15
    1f64:	mov    QWORD PTR [rdi],r14
    1f67:	xor    rdx,rdx
    1f6a:	mov    rax,rdx
    1f6d:	mov    rbx,QWORD PTR [rsp+0x30]
    1f72:	mov    r12,QWORD PTR [rsp+0x38]
    1f77:	mov    r13,QWORD PTR [rsp+0x40]
    1f7c:	mov    r14,QWORD PTR [rsp+0x48]
    1f81:	mov    r15,QWORD PTR [rsp+0x50]
    1f86:	add    rsp,0x60
    1f8a:	mov    rsp,rbp
    1f8d:	pop    rbp
    1f8e:	ret
    1f8f:	mov    rdi,r15
    1f92:	mov    QWORD PTR [rdi],r14
    1f95:	mov    rdx,QWORD PTR [rsp+0x20]
    1f9a:	mov    rbx,QWORD PTR [rsp+0x30]
    1f9f:	mov    r12,QWORD PTR [rsp+0x38]
    1fa4:	mov    r13,QWORD PTR [rsp+0x40]
    1fa9:	mov    r14,QWORD PTR [rsp+0x48]
    1fae:	mov    r15,QWORD PTR [rsp+0x50]
    1fb3:	add    rsp,0x60
    1fb7:	mov    rsp,rbp
    1fba:	pop    rbp
    1fbb:	ret
    1fbc:	mov    r15,rdi
    1fbf:	mov    rax,QWORD PTR [rip+0x0]        # 1fc6 <botlish_fn_13+0x278>
			1fc2: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    1fc6:	call   rax
    1fc8:	xor    rdx,rdx
    1fcb:	mov    rax,rdx
    1fce:	mov    rbx,QWORD PTR [rsp+0x30]
    1fd3:	mov    r12,QWORD PTR [rsp+0x38]
    1fd8:	mov    r13,QWORD PTR [rsp+0x40]
    1fdd:	mov    r14,QWORD PTR [rsp+0x48]
    1fe2:	mov    r15,QWORD PTR [rsp+0x50]
    1fe7:	add    rsp,0x60
    1feb:	mov    rsp,rbp
    1fee:	pop    rbp
    1fef:	ret

0000000000001ff0 <botlish_entry_13: scan_unquoted<str, int, int>>:
    1ff0:	push   rbp
    1ff1:	mov    rbp,rsp
    1ff4:	ud2

0000000000001ff6 <botlish_fn_14: scan_quoted<str, int, str>>:
    1ff6:	push   rbp
    1ff7:	mov    rbp,rsp
    1ffa:	sub    rsp,0x50
    1ffe:	mov    QWORD PTR [rsp+0x20],rbx
    2003:	mov    QWORD PTR [rsp+0x28],r12
    2008:	mov    QWORD PTR [rsp+0x30],r13
    200d:	mov    QWORD PTR [rsp+0x38],r14
    2012:	mov    QWORD PTR [rsp+0x40],r15
    2017:	mov    r13,QWORD PTR [rdi]
    201a:	mov    rax,QWORD PTR [rdi+0x8]
    201e:	lea    r8,[r13+0x28]
    2022:	cmp    r8,rax
    2025:	ja     2332 <botlish_fn_14+0x33c>
    202b:	lea    rax,[r13+0x28]
    202f:	mov    QWORD PTR [rdi],rax
    2032:	mov    r14,rdi
    2035:	mov    QWORD PTR [r13+0x0],0x0
    203d:	mov    QWORD PTR [r13+0x8],0x0
    2045:	mov    QWORD PTR [r13+0x10],0x0
    204d:	mov    QWORD PTR [r13+0x18],0x0
    2055:	mov    QWORD PTR [r13+0x20],0x0
    205d:	mov    QWORD PTR [r13+0x0],rsi
    2061:	mov    QWORD PTR [r13+0x8],rdx
    2065:	mov    QWORD PTR [r13+0x10],rcx
    2069:	lea    r12,[rsp]
    206d:	mov    rbx,rsi
    2070:	mov    r15,rdx
    2073:	mov    QWORD PTR [rsp+0x10],rcx
    2078:	mov    rdx,r15
    207b:	mov    rsi,rbx
    207e:	mov    rdi,r14
    2081:	call   2086 <botlish_fn_14+0x90>
			2082: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    2086:	test   rax,rax
    2089:	jne    2097 <botlish_fn_14+0xa1>
    208f:	mov    rdi,r14
    2092:	jmp    22eb <botlish_fn_14+0x2f5>
    2097:	mov    QWORD PTR [r13+0x18],rax
    209b:	mov    rdi,r14
    209e:	mov    QWORD PTR [rsp+0x18],rax
    20a3:	mov    rcx,QWORD PTR [rdi+0x10]
    20a7:	mov    rsi,QWORD PTR [rcx+0x28]
    20ab:	mov    edx,0x1
    20b0:	mov    ecx,0x3
    20b5:	mov    r9,QWORD PTR [rip+0x0]        # 20bc <botlish_fn_14+0xc6>
			20b8: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    20bc:	mov    r8,QWORD PTR [rsp+0x18]
    20c1:	call   r9
    20c4:	cmp    rax,0x6
    20c8:	je     215b <botlish_fn_14+0x165>
    20ce:	mov    QWORD PTR [r13+0x20],0x3
    20d6:	mov    rsi,r15
    20d9:	test   rsi,0x1
    20e0:	je     2100 <botlish_fn_14+0x10a>
    20e6:	mov    rax,rsi
    20e9:	add    rax,0x2
    20ed:	seto   cl
    20f0:	test   cl,cl
    20f2:	jne    2100 <botlish_fn_14+0x10a>
    20f8:	mov    rsi,rax
    20fb:	jmp    2114 <botlish_fn_14+0x11e>
    2100:	mov    edx,0x3
    2105:	mov    rax,QWORD PTR [rip+0x0]        # 210c <botlish_fn_14+0x116>
			2108: R_X86_64_GOTPCREL	rt_int_add-0x4
    210c:	mov    rdi,r14
    210f:	call   rax
    2111:	mov    rsi,rax
    2114:	mov    QWORD PTR [r13+0x8],rsi
    2118:	mov    r15,rsi
    211b:	mov    rax,QWORD PTR [rip+0x0]        # 2122 <botlish_fn_14+0x12c>
			211e: R_X86_64_GOTPCREL	rt_str_cat-0x4
    2122:	mov    rdx,QWORD PTR [rsp+0x18]
    2127:	mov    rsi,QWORD PTR [rsp+0x10]
    212c:	mov    rdi,r14
    212f:	call   rax
    2131:	test   rax,rax
    2134:	jne    2142 <botlish_fn_14+0x14c>
    213a:	mov    rdi,r14
    213d:	jmp    22eb <botlish_fn_14+0x2f5>
    2142:	mov    QWORD PTR [r13+0x0],rbx
    2146:	mov    rsi,r15
    2149:	mov    QWORD PTR [r13+0x8],rsi
    214d:	mov    QWORD PTR [r13+0x10],rax
    2151:	mov    QWORD PTR [rsp+0x10],rax
    2156:	jmp    2078 <botlish_fn_14+0x82>
    215b:	mov    QWORD PTR [r13+0x18],0x3
    2163:	mov    rsi,r15
    2166:	test   rsi,0x1
    216d:	je     2188 <botlish_fn_14+0x192>
    2173:	mov    rsi,r15
    2176:	mov    rdx,rsi
    2179:	add    rdx,0x2
    217d:	seto   al
    2180:	test   al,al
    2182:	je     219f <botlish_fn_14+0x1a9>
    2188:	mov    edx,0x3
    218d:	mov    rax,QWORD PTR [rip+0x0]        # 2194 <botlish_fn_14+0x19e>
			2190: R_X86_64_GOTPCREL	rt_int_add-0x4
    2194:	mov    rsi,r15
    2197:	mov    rdi,r14
    219a:	call   rax
    219c:	mov    rdx,rax
    219f:	mov    QWORD PTR [r13+0x18],rdx
    21a3:	mov    rcx,r12
    21a6:	mov    rsi,rbx
    21a9:	mov    rdi,r14
    21ac:	call   21b1 <botlish_fn_14+0x1bb>
			21ad: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    21b1:	test   rax,rax
    21b4:	mov    rsi,rax
    21b7:	jne    21c5 <botlish_fn_14+0x1cf>
    21bd:	mov    rdi,r14
    21c0:	jmp    22eb <botlish_fn_14+0x2f5>
    21c5:	mov    rdx,QWORD PTR [rsp]
    21c9:	mov    rcx,QWORD PTR [rsp+0x8]
    21ce:	mov    rdi,r14
    21d1:	mov    rax,QWORD PTR [rdi+0x10]
    21d5:	mov    r8,QWORD PTR [rax+0x28]
    21d9:	mov    rax,QWORD PTR [rip+0x0]        # 21e0 <botlish_fn_14+0x1ea>
			21dc: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    21e0:	call   rax
    21e2:	cmp    rax,0x6
    21e6:	je     2268 <botlish_fn_14+0x272>
    21ec:	mov    QWORD PTR [r13+0x0],0x3
    21f4:	mov    rsi,r15
    21f7:	test   rsi,0x1
    21fe:	je     2221 <botlish_fn_14+0x22b>
    2204:	mov    rsi,r15
    2207:	mov    rdx,rsi
    220a:	add    rdx,0x2
    220e:	seto   al
    2211:	test   al,al
    2213:	jne    2221 <botlish_fn_14+0x22b>
    2219:	mov    rdi,r14
    221c:	jmp    223b <botlish_fn_14+0x245>
    2221:	mov    edx,0x3
    2226:	mov    rax,QWORD PTR [rip+0x0]        # 222d <botlish_fn_14+0x237>
			2229: R_X86_64_GOTPCREL	rt_int_add-0x4
    222d:	mov    rsi,r15
    2230:	mov    rdi,r14
    2233:	call   rax
    2235:	mov    rdx,rax
    2238:	mov    rdi,r14
    223b:	mov    rdi,r14
    223e:	mov    QWORD PTR [rdi],r13
    2241:	mov    rax,QWORD PTR [rsp+0x10]
    2246:	mov    rbx,QWORD PTR [rsp+0x20]
    224b:	mov    r12,QWORD PTR [rsp+0x28]
    2250:	mov    r13,QWORD PTR [rsp+0x30]
    2255:	mov    r14,QWORD PTR [rsp+0x38]
    225a:	mov    r15,QWORD PTR [rsp+0x40]
    225f:	add    rsp,0x50
    2263:	mov    rsp,rbp
    2266:	pop    rbp
    2267:	ret
    2268:	mov    QWORD PTR [r13+0x18],0x5
    2270:	mov    rsi,r15
    2273:	test   rsi,0x1
    227a:	je     22a2 <botlish_fn_14+0x2ac>
    2280:	mov    rsi,r15
    2283:	mov    rcx,rsi
    2286:	add    rcx,0x4
    228a:	seto   sil
    228e:	test   sil,sil
    2291:	jne    22a2 <botlish_fn_14+0x2ac>
    2297:	mov    rsi,rcx
    229a:	mov    r15,rcx
    229d:	jmp    22bd <botlish_fn_14+0x2c7>
    22a2:	mov    edx,0x5
    22a7:	mov    r8,QWORD PTR [rip+0x0]        # 22ae <botlish_fn_14+0x2b8>
			22aa: R_X86_64_GOTPCREL	rt_int_add-0x4
    22ae:	mov    rsi,r15
    22b1:	mov    rdi,r14
    22b4:	call   r8
    22b7:	mov    rsi,rax
    22ba:	mov    r15,rax
    22bd:	mov    QWORD PTR [r13+0x8],rsi
    22c1:	mov    rdi,r14
    22c4:	mov    r8,QWORD PTR [rdi+0x10]
    22c8:	mov    rdx,QWORD PTR [r8+0x28]
    22cc:	mov    QWORD PTR [r13+0x18],rdx
    22d0:	mov    r9,QWORD PTR [rip+0x0]        # 22d7 <botlish_fn_14+0x2e1>
			22d3: R_X86_64_GOTPCREL	rt_str_cat-0x4
    22d7:	mov    rsi,QWORD PTR [rsp+0x10]
    22dc:	call   r9
    22df:	test   rax,rax
    22e2:	jne    2319 <botlish_fn_14+0x323>
    22e8:	mov    rdi,r14
    22eb:	mov    rdi,r14
    22ee:	mov    QWORD PTR [rdi],r13
    22f1:	xor    rdx,rdx
    22f4:	mov    rax,rdx
    22f7:	mov    rbx,QWORD PTR [rsp+0x20]
    22fc:	mov    r12,QWORD PTR [rsp+0x28]
    2301:	mov    r13,QWORD PTR [rsp+0x30]
    2306:	mov    r14,QWORD PTR [rsp+0x38]
    230b:	mov    r15,QWORD PTR [rsp+0x40]
    2310:	add    rsp,0x50
    2314:	mov    rsp,rbp
    2317:	pop    rbp
    2318:	ret
    2319:	mov    QWORD PTR [r13+0x0],rbx
    231d:	mov    rsi,r15
    2320:	mov    QWORD PTR [r13+0x8],rsi
    2324:	mov    QWORD PTR [r13+0x10],rax
    2328:	mov    QWORD PTR [rsp+0x10],rax
    232d:	jmp    2078 <botlish_fn_14+0x82>
    2332:	mov    r14,rdi
    2335:	mov    rax,QWORD PTR [rip+0x0]        # 233c <botlish_fn_14+0x346>
			2338: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    233c:	call   rax
    233e:	xor    rdx,rdx
    2341:	mov    rax,rdx
    2344:	mov    rbx,QWORD PTR [rsp+0x20]
    2349:	mov    r12,QWORD PTR [rsp+0x28]
    234e:	mov    r13,QWORD PTR [rsp+0x30]
    2353:	mov    r14,QWORD PTR [rsp+0x38]
    2358:	mov    r15,QWORD PTR [rsp+0x40]
    235d:	add    rsp,0x50
    2361:	mov    rsp,rbp
    2364:	pop    rbp
    2365:	ret

0000000000002366 <botlish_entry_14: scan_quoted<str, int, str>>:
    2366:	push   rbp
    2367:	mov    rbp,rsp
    236a:	ud2

000000000000236c <botlish_fn_15: scan_field<str, int>>:
    236c:	push   rbp
    236d:	mov    rbp,rsp
    2370:	sub    rsp,0x30
    2374:	mov    QWORD PTR [rsp+0x10],rbx
    2379:	mov    QWORD PTR [rsp+0x18],r12
    237e:	mov    QWORD PTR [rsp+0x20],r13
    2383:	mov    QWORD PTR [rsp+0x28],r14
    2388:	mov    rbx,QWORD PTR [rdi]
    238b:	mov    rax,QWORD PTR [rdi+0x8]
    238f:	lea    rcx,[rbx+0x18]
    2393:	cmp    rcx,rax
    2396:	ja     2510 <botlish_fn_15+0x1a4>
    239c:	lea    rax,[rbx+0x18]
    23a0:	mov    QWORD PTR [rdi],rax
    23a3:	mov    r12,rdi
    23a6:	mov    QWORD PTR [rbx],0x0
    23ad:	mov    QWORD PTR [rbx+0x8],0x0
    23b5:	mov    QWORD PTR [rbx+0x10],0x0
    23bd:	mov    QWORD PTR [rbx],rsi
    23c0:	mov    r13,rsi
    23c3:	mov    QWORD PTR [rbx+0x8],rdx
    23c7:	mov    r14,rdx
    23ca:	lea    rcx,[rsp]
    23ce:	mov    rdx,r14
    23d1:	mov    rsi,r13
    23d4:	mov    rdi,r12
    23d7:	call   23dc <botlish_fn_15+0x70>
			23d8: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    23dc:	test   rax,rax
    23df:	mov    rsi,rax
    23e2:	jne    23f0 <botlish_fn_15+0x84>
    23e8:	mov    rdi,r12
    23eb:	jmp    24c4 <botlish_fn_15+0x158>
    23f0:	mov    rdx,QWORD PTR [rsp]
    23f4:	mov    rcx,QWORD PTR [rsp+0x8]
    23f9:	mov    rdi,r12
    23fc:	mov    rax,QWORD PTR [rdi+0x10]
    2400:	mov    r8,QWORD PTR [rax+0x28]
    2404:	mov    rax,QWORD PTR [rip+0x0]        # 240b <botlish_fn_15+0x9f>
			2407: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    240b:	call   rax
    240d:	cmp    rax,0x6
    2411:	je     245c <botlish_fn_15+0xf0>
    2417:	mov    rcx,r14
    241a:	mov    rsi,r13
    241d:	mov    rdi,r12
    2420:	mov    rdx,rcx
    2423:	call   2428 <botlish_fn_15+0xbc>
			2424: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    2428:	test   rax,rax
    242b:	jne    2439 <botlish_fn_15+0xcd>
    2431:	mov    rdi,r12
    2434:	jmp    24c4 <botlish_fn_15+0x158>
    2439:	mov    rdi,r12
    243c:	mov    QWORD PTR [rdi],rbx
    243f:	mov    rbx,QWORD PTR [rsp+0x10]
    2444:	mov    r12,QWORD PTR [rsp+0x18]
    2449:	mov    r13,QWORD PTR [rsp+0x20]
    244e:	mov    r14,QWORD PTR [rsp+0x28]
    2453:	add    rsp,0x30
    2457:	mov    rsp,rbp
    245a:	pop    rbp
    245b:	ret
    245c:	mov    QWORD PTR [rbx+0x10],0x3
    2464:	mov    rdx,r14
    2467:	test   rdx,0x1
    246e:	je     2486 <botlish_fn_15+0x11a>
    2474:	mov    rdx,r14
    2477:	add    rdx,0x2
    247b:	seto   al
    247e:	test   al,al
    2480:	je     249d <botlish_fn_15+0x131>
    2486:	mov    edx,0x3
    248b:	mov    rax,QWORD PTR [rip+0x0]        # 2492 <botlish_fn_15+0x126>
			248e: R_X86_64_GOTPCREL	rt_int_add-0x4
    2492:	mov    rsi,r14
    2495:	mov    rdi,r12
    2498:	call   rax
    249a:	mov    rdx,rax
    249d:	mov    QWORD PTR [rbx+0x8],rdx
    24a1:	mov    rdi,r12
    24a4:	mov    rax,QWORD PTR [rdi+0x10]
    24a8:	mov    rcx,QWORD PTR [rax+0x10]
    24ac:	mov    QWORD PTR [rbx+0x10],rcx
    24b0:	mov    rsi,r13
    24b3:	call   24b8 <botlish_fn_15+0x14c>
			24b4: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    24b8:	test   rax,rax
    24bb:	jne    24ed <botlish_fn_15+0x181>
    24c1:	mov    rdi,r12
    24c4:	mov    rdi,r12
    24c7:	mov    QWORD PTR [rdi],rbx
    24ca:	xor    rdx,rdx
    24cd:	mov    rax,rdx
    24d0:	mov    rbx,QWORD PTR [rsp+0x10]
    24d5:	mov    r12,QWORD PTR [rsp+0x18]
    24da:	mov    r13,QWORD PTR [rsp+0x20]
    24df:	mov    r14,QWORD PTR [rsp+0x28]
    24e4:	add    rsp,0x30
    24e8:	mov    rsp,rbp
    24eb:	pop    rbp
    24ec:	ret
    24ed:	mov    rdi,r12
    24f0:	mov    QWORD PTR [rdi],rbx
    24f3:	mov    rbx,QWORD PTR [rsp+0x10]
    24f8:	mov    r12,QWORD PTR [rsp+0x18]
    24fd:	mov    r13,QWORD PTR [rsp+0x20]
    2502:	mov    r14,QWORD PTR [rsp+0x28]
    2507:	add    rsp,0x30
    250b:	mov    rsp,rbp
    250e:	pop    rbp
    250f:	ret
    2510:	mov    r12,rdi
    2513:	mov    rsi,QWORD PTR [rip+0x0]        # 251a <botlish_fn_15+0x1ae>
			2516: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    251a:	call   rsi
    251c:	xor    rdx,rdx
    251f:	mov    rax,rdx
    2522:	mov    rbx,QWORD PTR [rsp+0x10]
    2527:	mov    r12,QWORD PTR [rsp+0x18]
    252c:	mov    r13,QWORD PTR [rsp+0x20]
    2531:	mov    r14,QWORD PTR [rsp+0x28]
    2536:	add    rsp,0x30
    253a:	mov    rsp,rbp
    253d:	pop    rbp
    253e:	ret

000000000000253f <botlish_entry_15: scan_field<str, int>>:
    253f:	push   rbp
    2540:	mov    rbp,rsp
    2543:	ud2

0000000000002545 <botlish_fn_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    2545:	push   rbp
    2546:	mov    rbp,rsp
    2549:	sub    rsp,0x80
    2550:	mov    QWORD PTR [rsp+0x50],rbx
    2555:	mov    QWORD PTR [rsp+0x58],r12
    255a:	mov    QWORD PTR [rsp+0x60],r13
    255f:	mov    QWORD PTR [rsp+0x68],r14
    2564:	mov    QWORD PTR [rsp+0x70],r15
    2569:	mov    rbx,QWORD PTR [rdi]
    256c:	mov    rax,QWORD PTR [rdi+0x8]
    2570:	lea    r10,[rbx+0x30]
    2574:	cmp    r10,rax
    2577:	ja     28a3 <botlish_fn_16+0x35e>
    257d:	lea    rax,[rbx+0x30]
    2581:	mov    QWORD PTR [rdi],rax
    2584:	mov    r13,rdi
    2587:	mov    QWORD PTR [rbx],0x0
    258e:	mov    QWORD PTR [rbx+0x8],0x0
    2596:	mov    QWORD PTR [rbx+0x10],0x0
    259e:	mov    QWORD PTR [rbx+0x18],0x0
    25a6:	mov    QWORD PTR [rbx+0x20],0x0
    25ae:	mov    QWORD PTR [rbx+0x28],0x0
    25b6:	mov    QWORD PTR [rbx],rsi
    25b9:	mov    QWORD PTR [rsp+0x20],rsi
    25be:	mov    QWORD PTR [rbx+0x8],rdx
    25c2:	mov    QWORD PTR [rbx+0x10],rcx
    25c6:	mov    QWORD PTR [rsp+0x28],rcx
    25cb:	mov    QWORD PTR [rbx+0x18],r8
    25cf:	mov    r12,r8
    25d2:	mov    QWORD PTR [rbx+0x20],r9
    25d6:	mov    r15,r9
    25d9:	mov    rsi,QWORD PTR [rsp+0x20]
    25de:	mov    rdi,r13
    25e1:	call   25e6 <botlish_fn_16+0xa1>
			25e2: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    25e6:	test   rax,rax
    25e9:	jne    25f7 <botlish_fn_16+0xb2>
    25ef:	mov    rdi,r13
    25f2:	jmp    2847 <botlish_fn_16+0x302>
    25f7:	mov    QWORD PTR [rbx+0x8],rax
    25fb:	mov    r8,rax
    25fe:	mov    QWORD PTR [rbx+0x28],rdx
    2602:	mov    r14,rdx
    2605:	lea    r9,[rsp]
    2609:	mov    rcx,r15
    260c:	mov    rdx,r12
    260f:	mov    rsi,QWORD PTR [rsp+0x28]
    2614:	mov    rdi,r13
    2617:	call   261c <botlish_fn_16+0xd7>
			2618: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[list<never>, mutarray, int], str>
    261c:	test   rax,rax
    261f:	jne    262d <botlish_fn_16+0xe8>
    2625:	mov    rdi,r13
    2628:	jmp    2847 <botlish_fn_16+0x302>
    262d:	mov    QWORD PTR [rbx+0x8],rax
    2631:	mov    QWORD PTR [rsp+0x40],rax
    2636:	mov    rdx,QWORD PTR [rsp]
    263a:	mov    QWORD PTR [rbx+0x10],rdx
    263e:	mov    QWORD PTR [rsp+0x38],rdx
    2643:	mov    rcx,QWORD PTR [rsp+0x8]
    2648:	mov    QWORD PTR [rbx+0x18],rcx
    264c:	mov    QWORD PTR [rsp+0x30],rcx
    2651:	lea    rcx,[rsp+0x10]
    2656:	mov    rdx,r14
    2659:	mov    rsi,QWORD PTR [rsp+0x20]
    265e:	mov    rdi,r13
    2661:	call   2666 <botlish_fn_16+0x121>
			2662: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    2666:	test   rax,rax
    2669:	mov    QWORD PTR [rsp+0x28],rax
    266e:	jne    267c <botlish_fn_16+0x137>
    2674:	mov    rdi,r13
    2677:	jmp    2847 <botlish_fn_16+0x302>
    267c:	mov    r12,QWORD PTR [rsp+0x10]
    2681:	mov    r15,QWORD PTR [rsp+0x18]
    2686:	mov    rdi,r13
    2689:	mov    rcx,QWORD PTR [rdi+0x10]
    268d:	mov    r8,QWORD PTR [rcx+0x18]
    2691:	mov    r9,QWORD PTR [rip+0x0]        # 2698 <botlish_fn_16+0x153>
			2694: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    2698:	mov    rcx,r15
    269b:	mov    rdx,r12
    269e:	mov    rsi,QWORD PTR [rsp+0x28]
    26a3:	call   r9
    26a6:	cmp    rax,0x6
    26aa:	je     27d7 <botlish_fn_16+0x292>
    26b0:	mov    rdi,r13
    26b3:	mov    rax,QWORD PTR [rdi+0x10]
    26b7:	mov    r8,QWORD PTR [rax+0x20]
    26bb:	mov    rax,QWORD PTR [rip+0x0]        # 26c2 <botlish_fn_16+0x17d>
			26be: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    26c2:	mov    rcx,r15
    26c5:	mov    rdx,r12
    26c8:	mov    rsi,QWORD PTR [rsp+0x28]
    26cd:	call   rax
    26cf:	cmp    rax,0x6
    26d3:	je     272f <botlish_fn_16+0x1ea>
    26d9:	mov    rcx,QWORD PTR [rsp+0x30]
    26de:	mov    rdx,QWORD PTR [rsp+0x38]
    26e3:	mov    rsi,QWORD PTR [rsp+0x40]
    26e8:	mov    rdi,r13
    26eb:	call   26f0 <botlish_fn_16+0x1ab>
			26ec: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    26f0:	test   rax,rax
    26f3:	jne    2701 <botlish_fn_16+0x1bc>
    26f9:	mov    rdi,r13
    26fc:	jmp    2847 <botlish_fn_16+0x302>
    2701:	mov    rdi,r13
    2704:	mov    QWORD PTR [rdi],rbx
    2707:	mov    rdx,r14
    270a:	mov    rbx,QWORD PTR [rsp+0x50]
    270f:	mov    r12,QWORD PTR [rsp+0x58]
    2714:	mov    r13,QWORD PTR [rsp+0x60]
    2719:	mov    r14,QWORD PTR [rsp+0x68]
    271e:	mov    r15,QWORD PTR [rsp+0x70]
    2723:	add    rsp,0x80
    272a:	mov    rsp,rbp
    272d:	pop    rbp
    272e:	ret
    272f:	mov    rcx,QWORD PTR [rsp+0x30]
    2734:	mov    rdx,QWORD PTR [rsp+0x38]
    2739:	mov    rsi,QWORD PTR [rsp+0x40]
    273e:	mov    rdi,r13
    2741:	call   2746 <botlish_fn_16+0x201>
			2742: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2746:	test   rax,rax
    2749:	jne    2757 <botlish_fn_16+0x212>
    274f:	mov    rdi,r13
    2752:	jmp    2847 <botlish_fn_16+0x302>
    2757:	mov    QWORD PTR [rbx],rax
    275a:	mov    r12,rax
    275d:	mov    QWORD PTR [rbx+0x8],0x3
    2765:	mov    rdx,r14
    2768:	test   rdx,0x1
    276f:	je     278f <botlish_fn_16+0x24a>
    2775:	mov    rdx,r14
    2778:	add    rdx,0x2
    277c:	seto   al
    277f:	test   al,al
    2781:	jne    278f <botlish_fn_16+0x24a>
    2787:	mov    rdi,r13
    278a:	jmp    27a9 <botlish_fn_16+0x264>
    278f:	mov    edx,0x3
    2794:	mov    rax,QWORD PTR [rip+0x0]        # 279b <botlish_fn_16+0x256>
			2797: R_X86_64_GOTPCREL	rt_int_add-0x4
    279b:	mov    rsi,r14
    279e:	mov    rdi,r13
    27a1:	call   rax
    27a3:	mov    rdx,rax
    27a6:	mov    rdi,r13
    27a9:	mov    rdi,r13
    27ac:	mov    QWORD PTR [rdi],rbx
    27af:	mov    rax,r12
    27b2:	mov    rbx,QWORD PTR [rsp+0x50]
    27b7:	mov    r12,QWORD PTR [rsp+0x58]
    27bc:	mov    r13,QWORD PTR [rsp+0x60]
    27c1:	mov    r14,QWORD PTR [rsp+0x68]
    27c6:	mov    r15,QWORD PTR [rsp+0x70]
    27cb:	add    rsp,0x80
    27d2:	mov    rsp,rbp
    27d5:	pop    rbp
    27d6:	ret
    27d7:	mov    rsi,r14
    27da:	mov    edx,0x3
    27df:	mov    rcx,rdx
    27e2:	mov    QWORD PTR [rbx+0x20],0x3
    27ea:	test   rsi,0x1
    27f1:	je     2809 <botlish_fn_16+0x2c4>
    27f7:	mov    rdx,rsi
    27fa:	add    rdx,0x2
    27fe:	seto   al
    2801:	test   al,al
    2803:	je     281b <botlish_fn_16+0x2d6>
    2809:	mov    rax,QWORD PTR [rip+0x0]        # 2810 <botlish_fn_16+0x2cb>
			280c: R_X86_64_GOTPCREL	rt_int_add-0x4
    2810:	mov    rdx,rcx
    2813:	mov    rdi,r13
    2816:	call   rax
    2818:	mov    rdx,rax
    281b:	mov    QWORD PTR [rbx+0x20],rdx
    281f:	mov    rcx,QWORD PTR [rsp+0x40]
    2824:	mov    rsi,QWORD PTR [rsp+0x20]
    2829:	mov    r8,QWORD PTR [rsp+0x38]
    282e:	mov    r9,QWORD PTR [rsp+0x30]
    2833:	mov    rdi,r13
    2836:	call   283b <botlish_fn_16+0x2f6>
			2837: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int, list[list<mutarray>, mutarray, int]>
    283b:	test   rax,rax
    283e:	jne    2878 <botlish_fn_16+0x333>
    2844:	mov    rdi,r13
    2847:	mov    rdi,r13
    284a:	mov    QWORD PTR [rdi],rbx
    284d:	xor    rdx,rdx
    2850:	mov    rax,rdx
    2853:	mov    rbx,QWORD PTR [rsp+0x50]
    2858:	mov    r12,QWORD PTR [rsp+0x58]
    285d:	mov    r13,QWORD PTR [rsp+0x60]
    2862:	mov    r14,QWORD PTR [rsp+0x68]
    2867:	mov    r15,QWORD PTR [rsp+0x70]
    286c:	add    rsp,0x80
    2873:	mov    rsp,rbp
    2876:	pop    rbp
    2877:	ret
    2878:	mov    rdi,r13
    287b:	mov    QWORD PTR [rdi],rbx
    287e:	mov    rbx,QWORD PTR [rsp+0x50]
    2883:	mov    r12,QWORD PTR [rsp+0x58]
    2888:	mov    r13,QWORD PTR [rsp+0x60]
    288d:	mov    r14,QWORD PTR [rsp+0x68]
    2892:	mov    r15,QWORD PTR [rsp+0x70]
    2897:	add    rsp,0x80
    289e:	mov    rsp,rbp
    28a1:	pop    rbp
    28a2:	ret
    28a3:	mov    r13,rdi
    28a6:	mov    rax,QWORD PTR [rip+0x0]        # 28ad <botlish_fn_16+0x368>
			28a9: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    28ad:	call   rax
    28af:	xor    rdx,rdx
    28b2:	mov    rax,rdx
    28b5:	mov    rbx,QWORD PTR [rsp+0x50]
    28ba:	mov    r12,QWORD PTR [rsp+0x58]
    28bf:	mov    r13,QWORD PTR [rsp+0x60]
    28c4:	mov    r14,QWORD PTR [rsp+0x68]
    28c9:	mov    r15,QWORD PTR [rsp+0x70]
    28ce:	add    rsp,0x80
    28d5:	mov    rsp,rbp
    28d8:	pop    rbp
    28d9:	ret

00000000000028da <botlish_entry_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    28da:	push   rbp
    28db:	mov    rbp,rsp
    28de:	ud2

00000000000028e0 <botlish_fn_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    28e0:	push   rbp
    28e1:	mov    rbp,rsp
    28e4:	sub    rsp,0x90
    28eb:	mov    QWORD PTR [rsp+0x60],rbx
    28f0:	mov    QWORD PTR [rsp+0x68],r12
    28f5:	mov    QWORD PTR [rsp+0x70],r13
    28fa:	mov    QWORD PTR [rsp+0x78],r14
    28ff:	mov    QWORD PTR [rsp+0x80],r15
    2907:	mov    r14,QWORD PTR [rdi]
    290a:	mov    rax,QWORD PTR [rdi+0x8]
    290e:	lea    r10,[r14+0x30]
    2912:	cmp    r10,rax
    2915:	ja     2c5e <botlish_fn_17+0x37e>
    291b:	lea    rax,[r14+0x30]
    291f:	mov    QWORD PTR [rdi],rax
    2922:	mov    QWORD PTR [rsp+0x20],rdi
    2927:	mov    QWORD PTR [r14],0x0
    292e:	mov    QWORD PTR [r14+0x8],0x0
    2936:	mov    QWORD PTR [r14+0x10],0x0
    293e:	mov    QWORD PTR [r14+0x18],0x0
    2946:	mov    QWORD PTR [r14+0x20],0x0
    294e:	mov    QWORD PTR [r14+0x28],0x0
    2956:	mov    QWORD PTR [r14],rsi
    2959:	mov    QWORD PTR [r14+0x8],rdx
    295d:	mov    QWORD PTR [r14+0x10],rcx
    2961:	mov    QWORD PTR [r14+0x18],r8
    2965:	mov    QWORD PTR [r14+0x20],r9
    2969:	lea    r12,[rsp]
    296d:	mov    QWORD PTR [rsp+0x50],r12
    2972:	lea    r12,[rsp+0x10]
    2977:	mov    rbx,rcx
    297a:	mov    r13,rsi
    297d:	mov    QWORD PTR [rsp+0x28],r8
    2982:	mov    QWORD PTR [rsp+0x30],r9
    2987:	mov    rsi,r13
    298a:	mov    rdi,QWORD PTR [rsp+0x20]
    298f:	call   2994 <botlish_fn_17+0xb4>
			2990: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    2994:	mov    QWORD PTR [rsp+0x48],rdx
    2999:	test   rax,rax
    299c:	jne    29ac <botlish_fn_17+0xcc>
    29a2:	mov    rdi,QWORD PTR [rsp+0x20]
    29a7:	jmp    2b25 <botlish_fn_17+0x245>
    29ac:	mov    QWORD PTR [r14+0x8],rax
    29b0:	mov    rdx,QWORD PTR [rsp+0x48]
    29b5:	mov    r8,rax
    29b8:	mov    QWORD PTR [r14+0x28],rdx
    29bc:	mov    rcx,QWORD PTR [rsp+0x30]
    29c1:	mov    rdx,QWORD PTR [rsp+0x28]
    29c6:	mov    rsi,rbx
    29c9:	mov    rdi,QWORD PTR [rsp+0x20]
    29ce:	mov    r9,QWORD PTR [rsp+0x50]
    29d3:	call   29d8 <botlish_fn_17+0xf8>
			29d4: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], str>
    29d8:	test   rax,rax
    29db:	jne    29eb <botlish_fn_17+0x10b>
    29e1:	mov    rdi,QWORD PTR [rsp+0x20]
    29e6:	jmp    2b25 <botlish_fn_17+0x245>
    29eb:	mov    QWORD PTR [r14+0x8],rax
    29ef:	mov    QWORD PTR [rsp+0x40],rax
    29f4:	mov    rdx,QWORD PTR [rsp]
    29f8:	mov    QWORD PTR [rsp+0x28],rdx
    29fd:	mov    QWORD PTR [r14+0x10],rdx
    2a01:	mov    rcx,QWORD PTR [rsp+0x8]
    2a06:	mov    QWORD PTR [r14+0x18],rcx
    2a0a:	mov    QWORD PTR [rsp+0x30],rcx
    2a0f:	mov    rcx,r12
    2a12:	mov    rdx,QWORD PTR [rsp+0x48]
    2a17:	mov    rsi,r13
    2a1a:	mov    rdi,QWORD PTR [rsp+0x20]
    2a1f:	call   2a24 <botlish_fn_17+0x144>
			2a20: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    2a24:	test   rax,rax
    2a27:	mov    QWORD PTR [rsp+0x38],rax
    2a2c:	jne    2a3c <botlish_fn_17+0x15c>
    2a32:	mov    rdi,QWORD PTR [rsp+0x20]
    2a37:	jmp    2b25 <botlish_fn_17+0x245>
    2a3c:	mov    rbx,QWORD PTR [rsp+0x10]
    2a41:	mov    r15,QWORD PTR [rsp+0x18]
    2a46:	mov    rdi,QWORD PTR [rsp+0x20]
    2a4b:	mov    rcx,QWORD PTR [rdi+0x10]
    2a4f:	mov    r8,QWORD PTR [rcx+0x18]
    2a53:	mov    r9,QWORD PTR [rip+0x0]        # 2a5a <botlish_fn_17+0x17a>
			2a56: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    2a5a:	mov    rcx,r15
    2a5d:	mov    rdx,rbx
    2a60:	mov    rsi,QWORD PTR [rsp+0x38]
    2a65:	call   r9
    2a68:	cmp    rax,0x6
    2a6c:	je     2bec <botlish_fn_17+0x30c>
    2a72:	mov    rdi,QWORD PTR [rsp+0x20]
    2a77:	mov    rax,QWORD PTR [rdi+0x10]
    2a7b:	mov    r8,QWORD PTR [rax+0x20]
    2a7f:	mov    rax,QWORD PTR [rip+0x0]        # 2a86 <botlish_fn_17+0x1a6>
			2a82: R_X86_64_GOTPCREL	rt_str_region_eq-0x4
    2a86:	mov    rcx,r15
    2a89:	mov    rdx,rbx
    2a8c:	mov    rsi,QWORD PTR [rsp+0x38]
    2a91:	call   rax
    2a93:	cmp    rax,0x6
    2a97:	je     2afe <botlish_fn_17+0x21e>
    2a9d:	mov    rcx,QWORD PTR [rsp+0x30]
    2aa2:	mov    rdx,QWORD PTR [rsp+0x28]
    2aa7:	mov    rsi,QWORD PTR [rsp+0x40]
    2aac:	mov    rdi,QWORD PTR [rsp+0x20]
    2ab1:	call   2ab6 <botlish_fn_17+0x1d6>
			2ab2: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2ab6:	test   rax,rax
    2ab9:	jne    2ac9 <botlish_fn_17+0x1e9>
    2abf:	mov    rdi,QWORD PTR [rsp+0x20]
    2ac4:	jmp    2b25 <botlish_fn_17+0x245>
    2ac9:	mov    rdi,QWORD PTR [rsp+0x20]
    2ace:	mov    QWORD PTR [rdi],r14
    2ad1:	mov    rdx,QWORD PTR [rsp+0x48]
    2ad6:	mov    rbx,QWORD PTR [rsp+0x60]
    2adb:	mov    r12,QWORD PTR [rsp+0x68]
    2ae0:	mov    r13,QWORD PTR [rsp+0x70]
    2ae5:	mov    r14,QWORD PTR [rsp+0x78]
    2aea:	mov    r15,QWORD PTR [rsp+0x80]
    2af2:	add    rsp,0x90
    2af9:	mov    rsp,rbp
    2afc:	pop    rbp
    2afd:	ret
    2afe:	mov    rcx,QWORD PTR [rsp+0x30]
    2b03:	mov    rdx,QWORD PTR [rsp+0x28]
    2b08:	mov    rsi,QWORD PTR [rsp+0x40]
    2b0d:	mov    rdi,QWORD PTR [rsp+0x20]
    2b12:	call   2b17 <botlish_fn_17+0x237>
			2b13: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2b17:	test   rax,rax
    2b1a:	jne    2b5b <botlish_fn_17+0x27b>
    2b20:	mov    rdi,QWORD PTR [rsp+0x20]
    2b25:	mov    rdi,QWORD PTR [rsp+0x20]
    2b2a:	mov    QWORD PTR [rdi],r14
    2b2d:	xor    rdx,rdx
    2b30:	mov    rax,rdx
    2b33:	mov    rbx,QWORD PTR [rsp+0x60]
    2b38:	mov    r12,QWORD PTR [rsp+0x68]
    2b3d:	mov    r13,QWORD PTR [rsp+0x70]
    2b42:	mov    r14,QWORD PTR [rsp+0x78]
    2b47:	mov    r15,QWORD PTR [rsp+0x80]
    2b4f:	add    rsp,0x90
    2b56:	mov    rsp,rbp
    2b59:	pop    rbp
    2b5a:	ret
    2b5b:	mov    QWORD PTR [r14],rax
    2b5e:	mov    rbx,rax
    2b61:	mov    QWORD PTR [r14+0x8],0x3
    2b69:	mov    rdx,QWORD PTR [rsp+0x48]
    2b6e:	test   rdx,0x1
    2b75:	je     2b99 <botlish_fn_17+0x2b9>
    2b7b:	mov    rdx,QWORD PTR [rsp+0x48]
    2b80:	add    rdx,0x2
    2b84:	seto   al
    2b87:	test   al,al
    2b89:	jne    2b99 <botlish_fn_17+0x2b9>
    2b8f:	mov    rdi,QWORD PTR [rsp+0x20]
    2b94:	jmp    2bb9 <botlish_fn_17+0x2d9>
    2b99:	mov    edx,0x3
    2b9e:	mov    rax,QWORD PTR [rip+0x0]        # 2ba5 <botlish_fn_17+0x2c5>
			2ba1: R_X86_64_GOTPCREL	rt_int_add-0x4
    2ba5:	mov    rsi,QWORD PTR [rsp+0x48]
    2baa:	mov    rdi,QWORD PTR [rsp+0x20]
    2baf:	call   rax
    2bb1:	mov    rdx,rax
    2bb4:	mov    rdi,QWORD PTR [rsp+0x20]
    2bb9:	mov    rdi,QWORD PTR [rsp+0x20]
    2bbe:	mov    QWORD PTR [rdi],r14
    2bc1:	mov    rax,rbx
    2bc4:	mov    rbx,QWORD PTR [rsp+0x60]
    2bc9:	mov    r12,QWORD PTR [rsp+0x68]
    2bce:	mov    r13,QWORD PTR [rsp+0x70]
    2bd3:	mov    r14,QWORD PTR [rsp+0x78]
    2bd8:	mov    r15,QWORD PTR [rsp+0x80]
    2be0:	add    rsp,0x90
    2be7:	mov    rsp,rbp
    2bea:	pop    rbp
    2beb:	ret
    2bec:	mov    rsi,QWORD PTR [rsp+0x48]
    2bf1:	mov    edx,0x3
    2bf6:	mov    rcx,rdx
    2bf9:	mov    QWORD PTR [r14+0x20],0x3
    2c01:	test   rsi,0x1
    2c08:	je     2c20 <botlish_fn_17+0x340>
    2c0e:	mov    rdx,rsi
    2c11:	add    rdx,0x2
    2c15:	seto   al
    2c18:	test   al,al
    2c1a:	je     2c34 <botlish_fn_17+0x354>
    2c20:	mov    rax,QWORD PTR [rip+0x0]        # 2c27 <botlish_fn_17+0x347>
			2c23: R_X86_64_GOTPCREL	rt_int_add-0x4
    2c27:	mov    rdx,rcx
    2c2a:	mov    rdi,QWORD PTR [rsp+0x20]
    2c2f:	call   rax
    2c31:	mov    rdx,rax
    2c34:	mov    QWORD PTR [r14],r13
    2c37:	mov    QWORD PTR [r14+0x8],rdx
    2c3b:	mov    rsi,QWORD PTR [rsp+0x40]
    2c40:	mov    QWORD PTR [r14+0x10],rsi
    2c44:	mov    rax,QWORD PTR [rsp+0x28]
    2c49:	mov    QWORD PTR [r14+0x18],rax
    2c4d:	mov    rcx,QWORD PTR [rsp+0x30]
    2c52:	mov    QWORD PTR [r14+0x20],rcx
    2c56:	mov    rbx,rsi
    2c59:	jmp    2987 <botlish_fn_17+0xa7>
    2c5e:	mov    QWORD PTR [rsp+0x20],rdi
    2c63:	mov    rax,QWORD PTR [rip+0x0]        # 2c6a <botlish_fn_17+0x38a>
			2c66: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2c6a:	call   rax
    2c6c:	xor    rdx,rdx
    2c6f:	mov    rax,rdx
    2c72:	mov    rbx,QWORD PTR [rsp+0x60]
    2c77:	mov    r12,QWORD PTR [rsp+0x68]
    2c7c:	mov    r13,QWORD PTR [rsp+0x70]
    2c81:	mov    r14,QWORD PTR [rsp+0x78]
    2c86:	mov    r15,QWORD PTR [rsp+0x80]
    2c8e:	add    rsp,0x90
    2c95:	mov    rsp,rbp
    2c98:	pop    rbp
    2c99:	ret

0000000000002c9a <botlish_entry_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    2c9a:	push   rbp
    2c9b:	mov    rbp,rsp
    2c9e:	ud2

0000000000002ca0 <botlish_fn_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    2ca0:	push   rbp
    2ca1:	mov    rbp,rsp
    2ca4:	sub    rsp,0x60
    2ca8:	mov    QWORD PTR [rsp+0x30],rbx
    2cad:	mov    QWORD PTR [rsp+0x38],r12
    2cb2:	mov    QWORD PTR [rsp+0x40],r13
    2cb7:	mov    QWORD PTR [rsp+0x48],r14
    2cbc:	mov    QWORD PTR [rsp+0x50],r15
    2cc1:	mov    rbx,QWORD PTR [rdi]
    2cc4:	mov    rax,QWORD PTR [rdi+0x8]
    2cc8:	lea    r10,[rbx+0x40]
    2ccc:	cmp    r10,rax
    2ccf:	ja     2ecd <botlish_fn_18+0x22d>
    2cd5:	lea    rax,[rbx+0x40]
    2cd9:	mov    QWORD PTR [rdi],rax
    2cdc:	mov    r12,rdi
    2cdf:	mov    QWORD PTR [rbx],0x0
    2ce6:	mov    QWORD PTR [rbx+0x8],0x0
    2cee:	mov    QWORD PTR [rbx+0x10],0x0
    2cf6:	mov    QWORD PTR [rbx+0x18],0x0
    2cfe:	mov    QWORD PTR [rbx+0x20],0x0
    2d06:	mov    QWORD PTR [rbx+0x28],0x0
    2d0e:	mov    QWORD PTR [rbx+0x30],0x0
    2d16:	mov    QWORD PTR [rbx+0x38],0x0
    2d1e:	mov    QWORD PTR [rbx],rsi
    2d21:	mov    r13,rsi
    2d24:	mov    QWORD PTR [rbx+0x8],rdx
    2d28:	mov    QWORD PTR [rsp+0x20],rdx
    2d2d:	mov    QWORD PTR [rbx+0x10],rcx
    2d31:	mov    QWORD PTR [rsp+0x28],rcx
    2d36:	mov    QWORD PTR [rbx+0x18],r8
    2d3a:	mov    r15,r8
    2d3d:	mov    QWORD PTR [rbx+0x20],r9
    2d41:	mov    r14,r9
    2d44:	mov    rax,QWORD PTR [rip+0x0]        # 2d4b <botlish_fn_18+0xab>
			2d47: R_X86_64_GOTPCREL	rt_str_len-0x4
    2d4b:	mov    rsi,r13
    2d4e:	mov    rdi,r12
    2d51:	call   rax
    2d53:	mov    rdx,QWORD PTR [rsp+0x20]
    2d58:	mov    rcx,rdx
    2d5b:	sar    rcx,1
    2d5e:	sar    rax,1
    2d61:	cmp    rcx,rax
    2d64:	jge    2e5b <botlish_fn_18+0x1bb>
    2d6a:	lea    rsi,[rsp]
    2d6e:	mov    rdi,r12
    2d71:	call   2d76 <botlish_fn_18+0xd6>
			2d72: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    2d76:	test   rax,rax
    2d79:	jne    2d87 <botlish_fn_18+0xe7>
    2d7f:	mov    rdi,r12
    2d82:	jmp    2e7a <botlish_fn_18+0x1da>
    2d87:	mov    QWORD PTR [rbx+0x28],rax
    2d8b:	mov    rcx,rax
    2d8e:	mov    r8,QWORD PTR [rsp]
    2d92:	mov    QWORD PTR [rbx+0x30],r8
    2d96:	mov    r9,QWORD PTR [rsp+0x8]
    2d9b:	mov    QWORD PTR [rbx+0x38],r9
    2d9f:	mov    rdx,QWORD PTR [rsp+0x20]
    2da4:	mov    rsi,r13
    2da7:	mov    rdi,r12
    2daa:	call   2daf <botlish_fn_18+0x10f>
			2dab: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    2daf:	test   rax,rax
    2db2:	jne    2dc0 <botlish_fn_18+0x120>
    2db8:	mov    rdi,r12
    2dbb:	jmp    2e7a <botlish_fn_18+0x1da>
    2dc0:	mov    QWORD PTR [rbx+0x8],rax
    2dc4:	mov    r8,rax
    2dc7:	mov    QWORD PTR [rbx+0x28],rdx
    2dcb:	mov    QWORD PTR [rsp+0x20],rdx
    2dd0:	lea    r9,[rsp+0x10]
    2dd5:	mov    rcx,r14
    2dd8:	mov    rdx,r15
    2ddb:	mov    rsi,QWORD PTR [rsp+0x28]
    2de0:	mov    rdi,r12
    2de3:	call   2de8 <botlish_fn_18+0x148>
			2de4: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[list<never>, mutarray, int], list>
    2de8:	test   rax,rax
    2deb:	jne    2df9 <botlish_fn_18+0x159>
    2df1:	mov    rdi,r12
    2df4:	jmp    2e7a <botlish_fn_18+0x1da>
    2df9:	mov    QWORD PTR [rbx+0x8],rax
    2dfd:	mov    rcx,rax
    2e00:	mov    r8,QWORD PTR [rsp+0x10]
    2e05:	mov    QWORD PTR [rbx+0x10],r8
    2e09:	mov    r9,QWORD PTR [rsp+0x18]
    2e0e:	mov    QWORD PTR [rbx+0x18],r9
    2e12:	mov    rdx,QWORD PTR [rsp+0x20]
    2e17:	mov    rsi,r13
    2e1a:	mov    rdi,r12
    2e1d:	call   2e22 <botlish_fn_18+0x182>
			2e1e: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    2e22:	test   rax,rax
    2e25:	jne    2e33 <botlish_fn_18+0x193>
    2e2b:	mov    rdi,r12
    2e2e:	jmp    2e7a <botlish_fn_18+0x1da>
    2e33:	mov    rdi,r12
    2e36:	mov    QWORD PTR [rdi],rbx
    2e39:	mov    rbx,QWORD PTR [rsp+0x30]
    2e3e:	mov    r12,QWORD PTR [rsp+0x38]
    2e43:	mov    r13,QWORD PTR [rsp+0x40]
    2e48:	mov    r14,QWORD PTR [rsp+0x48]
    2e4d:	mov    r15,QWORD PTR [rsp+0x50]
    2e52:	add    rsp,0x60
    2e56:	mov    rsp,rbp
    2e59:	pop    rbp
    2e5a:	ret
    2e5b:	mov    rcx,r14
    2e5e:	mov    rdx,r15
    2e61:	mov    rsi,QWORD PTR [rsp+0x28]
    2e66:	mov    rdi,r12
    2e69:	call   2e6e <botlish_fn_18+0x1ce>
			2e6a: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    2e6e:	test   rax,rax
    2e71:	jne    2ea5 <botlish_fn_18+0x205>
    2e77:	mov    rdi,r12
    2e7a:	mov    rdi,r12
    2e7d:	mov    QWORD PTR [rdi],rbx
    2e80:	xor    rax,rax
    2e83:	mov    rbx,QWORD PTR [rsp+0x30]
    2e88:	mov    r12,QWORD PTR [rsp+0x38]
    2e8d:	mov    r13,QWORD PTR [rsp+0x40]
    2e92:	mov    r14,QWORD PTR [rsp+0x48]
    2e97:	mov    r15,QWORD PTR [rsp+0x50]
    2e9c:	add    rsp,0x60
    2ea0:	mov    rsp,rbp
    2ea3:	pop    rbp
    2ea4:	ret
    2ea5:	mov    rdi,r12
    2ea8:	mov    QWORD PTR [rdi],rbx
    2eab:	mov    rbx,QWORD PTR [rsp+0x30]
    2eb0:	mov    r12,QWORD PTR [rsp+0x38]
    2eb5:	mov    r13,QWORD PTR [rsp+0x40]
    2eba:	mov    r14,QWORD PTR [rsp+0x48]
    2ebf:	mov    r15,QWORD PTR [rsp+0x50]
    2ec4:	add    rsp,0x60
    2ec8:	mov    rsp,rbp
    2ecb:	pop    rbp
    2ecc:	ret
    2ecd:	mov    r12,rdi
    2ed0:	mov    rax,QWORD PTR [rip+0x0]        # 2ed7 <botlish_fn_18+0x237>
			2ed3: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    2ed7:	call   rax
    2ed9:	xor    rax,rax
    2edc:	mov    rbx,QWORD PTR [rsp+0x30]
    2ee1:	mov    r12,QWORD PTR [rsp+0x38]
    2ee6:	mov    r13,QWORD PTR [rsp+0x40]
    2eeb:	mov    r14,QWORD PTR [rsp+0x48]
    2ef0:	mov    r15,QWORD PTR [rsp+0x50]
    2ef5:	add    rsp,0x60
    2ef9:	mov    rsp,rbp
    2efc:	pop    rbp
    2efd:	ret

0000000000002efe <botlish_entry_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    2efe:	push   rbp
    2eff:	mov    rbp,rsp
    2f02:	mov    rsi,QWORD PTR [rdx]
    2f05:	mov    r10,QWORD PTR [rdx+0x8]
    2f09:	mov    rcx,QWORD PTR [rdx+0x10]
    2f0d:	mov    r8,QWORD PTR [rdx+0x18]
    2f11:	mov    r9,QWORD PTR [rdx+0x20]
    2f15:	mov    rdx,r10
    2f18:	call   2f1d <botlish_entry_18+0x1f>
			2f19: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    2f1d:	mov    rsp,rbp
    2f20:	pop    rbp
    2f21:	ret
    2f22:	add    BYTE PTR [rax],al
    2f24:	add    BYTE PTR [rax],al
	...

0000000000002f28 <botlish_fn_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    2f28:	push   rbp
    2f29:	mov    rbp,rsp
    2f2c:	sub    rsp,0x70
    2f30:	mov    QWORD PTR [rsp+0x40],rbx
    2f35:	mov    QWORD PTR [rsp+0x48],r12
    2f3a:	mov    QWORD PTR [rsp+0x50],r13
    2f3f:	mov    QWORD PTR [rsp+0x58],r14
    2f44:	mov    QWORD PTR [rsp+0x60],r15
    2f49:	mov    r14,QWORD PTR [rdi]
    2f4c:	mov    rax,QWORD PTR [rdi+0x8]
    2f50:	lea    r10,[r14+0x40]
    2f54:	cmp    r10,rax
    2f57:	ja     318d <botlish_fn_19+0x265>
    2f5d:	lea    rax,[r14+0x40]
    2f61:	mov    QWORD PTR [rdi],rax
    2f64:	mov    QWORD PTR [rsp+0x20],rdi
    2f69:	mov    QWORD PTR [r14],0x0
    2f70:	mov    QWORD PTR [r14+0x8],0x0
    2f78:	mov    QWORD PTR [r14+0x10],0x0
    2f80:	mov    QWORD PTR [r14+0x18],0x0
    2f88:	mov    QWORD PTR [r14+0x20],0x0
    2f90:	mov    QWORD PTR [r14+0x28],0x0
    2f98:	mov    QWORD PTR [r14+0x30],0x0
    2fa0:	mov    QWORD PTR [r14+0x38],0x0
    2fa8:	mov    QWORD PTR [r14],rsi
    2fab:	mov    QWORD PTR [r14+0x8],rdx
    2faf:	mov    r15,rdx
    2fb2:	mov    QWORD PTR [r14+0x10],rcx
    2fb6:	mov    QWORD PTR [r14+0x18],r8
    2fba:	mov    QWORD PTR [r14+0x20],r9
    2fbe:	lea    rbx,[rsp]
    2fc2:	lea    r12,[rsp+0x10]
    2fc7:	mov    QWORD PTR [rsp+0x28],rcx
    2fcc:	mov    QWORD PTR [rsp+0x30],r8
    2fd1:	mov    QWORD PTR [rsp+0x38],r9
    2fd6:	mov    rax,QWORD PTR [rip+0x0]        # 2fdd <botlish_fn_19+0xb5>
			2fd9: R_X86_64_GOTPCREL	rt_str_len-0x4
    2fdd:	mov    r13,rsi
    2fe0:	mov    rdi,QWORD PTR [rsp+0x20]
    2fe5:	call   rax
    2fe7:	mov    rcx,r15
    2fea:	and    rcx,rax
    2fed:	mov    rdx,rax
    2ff0:	test   rcx,0x1
    2ff7:	jne    3023 <botlish_fn_19+0xfb>
    2ffd:	mov    rax,QWORD PTR [rip+0x0]        # 3004 <botlish_fn_19+0xdc>
			3000: R_X86_64_GOTPCREL	rt_int_cmp-0x4
    3004:	mov    rsi,r15
    3007:	mov    rdi,QWORD PTR [rsp+0x20]
    300c:	call   rax
    300e:	mov    ecx,0x2
    3013:	test   rax,rax
    3016:	cmovge rcx,QWORD PTR [rip+0x1a2]        # 31c0 <botlish_fn_19+0x298>
    301e:	jmp    3036 <botlish_fn_19+0x10e>
    3023:	mov    ecx,0x2
    3028:	mov    rax,r15
    302b:	cmp    rax,rdx
    302e:	cmovge rcx,QWORD PTR [rip+0x18a]        # 31c0 <botlish_fn_19+0x298>
    3036:	cmp    rcx,0x6
    303a:	je     310f <botlish_fn_19+0x1e7>
    3040:	mov    rsi,rbx
    3043:	mov    rdi,QWORD PTR [rsp+0x20]
    3048:	call   304d <botlish_fn_19+0x125>
			3049: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    304d:	test   rax,rax
    3050:	jne    3060 <botlish_fn_19+0x138>
    3056:	mov    rdi,QWORD PTR [rsp+0x20]
    305b:	jmp    3136 <botlish_fn_19+0x20e>
    3060:	mov    QWORD PTR [r14+0x28],rax
    3064:	mov    rcx,rax
    3067:	mov    r8,QWORD PTR [rsp]
    306b:	mov    QWORD PTR [r14+0x30],r8
    306f:	mov    r9,QWORD PTR [rsp+0x8]
    3074:	mov    QWORD PTR [r14+0x38],r9
    3078:	mov    rdx,r15
    307b:	mov    rsi,r13
    307e:	mov    rdi,QWORD PTR [rsp+0x20]
    3083:	call   3088 <botlish_fn_19+0x160>
			3084: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    3088:	test   rax,rax
    308b:	jne    309b <botlish_fn_19+0x173>
    3091:	mov    rdi,QWORD PTR [rsp+0x20]
    3096:	jmp    3136 <botlish_fn_19+0x20e>
    309b:	mov    QWORD PTR [r14+0x8],rax
    309f:	mov    r8,rax
    30a2:	mov    QWORD PTR [r14+0x28],rdx
    30a6:	mov    r15,rdx
    30a9:	mov    rsi,QWORD PTR [rsp+0x28]
    30ae:	mov    rdx,QWORD PTR [rsp+0x30]
    30b3:	mov    rcx,QWORD PTR [rsp+0x38]
    30b8:	mov    rdi,QWORD PTR [rsp+0x20]
    30bd:	mov    r9,r12
    30c0:	call   30c5 <botlish_fn_19+0x19d>
			30c1: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], list>
    30c5:	test   rax,rax
    30c8:	jne    30d8 <botlish_fn_19+0x1b0>
    30ce:	mov    rdi,QWORD PTR [rsp+0x20]
    30d3:	jmp    3136 <botlish_fn_19+0x20e>
    30d8:	mov    rdx,QWORD PTR [rsp+0x10]
    30dd:	mov    rcx,QWORD PTR [rsp+0x18]
    30e2:	mov    QWORD PTR [r14],r13
    30e5:	mov    rsi,r15
    30e8:	mov    QWORD PTR [r14+0x8],rsi
    30ec:	mov    QWORD PTR [r14+0x10],rax
    30f0:	mov    QWORD PTR [r14+0x18],rdx
    30f4:	mov    QWORD PTR [r14+0x20],rcx
    30f8:	mov    QWORD PTR [rsp+0x38],rcx
    30fd:	mov    QWORD PTR [rsp+0x30],rdx
    3102:	mov    QWORD PTR [rsp+0x28],rax
    3107:	mov    rsi,r13
    310a:	jmp    2fd6 <botlish_fn_19+0xae>
    310f:	mov    rcx,QWORD PTR [rsp+0x38]
    3114:	mov    rdx,QWORD PTR [rsp+0x30]
    3119:	mov    rsi,QWORD PTR [rsp+0x28]
    311e:	mov    rdi,QWORD PTR [rsp+0x20]
    3123:	call   3128 <botlish_fn_19+0x200>
			3124: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    3128:	test   rax,rax
    312b:	jne    3163 <botlish_fn_19+0x23b>
    3131:	mov    rdi,QWORD PTR [rsp+0x20]
    3136:	mov    rdi,QWORD PTR [rsp+0x20]
    313b:	mov    QWORD PTR [rdi],r14
    313e:	xor    rax,rax
    3141:	mov    rbx,QWORD PTR [rsp+0x40]
    3146:	mov    r12,QWORD PTR [rsp+0x48]
    314b:	mov    r13,QWORD PTR [rsp+0x50]
    3150:	mov    r14,QWORD PTR [rsp+0x58]
    3155:	mov    r15,QWORD PTR [rsp+0x60]
    315a:	add    rsp,0x70
    315e:	mov    rsp,rbp
    3161:	pop    rbp
    3162:	ret
    3163:	mov    rdi,QWORD PTR [rsp+0x20]
    3168:	mov    QWORD PTR [rdi],r14
    316b:	mov    rbx,QWORD PTR [rsp+0x40]
    3170:	mov    r12,QWORD PTR [rsp+0x48]
    3175:	mov    r13,QWORD PTR [rsp+0x50]
    317a:	mov    r14,QWORD PTR [rsp+0x58]
    317f:	mov    r15,QWORD PTR [rsp+0x60]
    3184:	add    rsp,0x70
    3188:	mov    rsp,rbp
    318b:	pop    rbp
    318c:	ret
    318d:	mov    QWORD PTR [rsp+0x20],rdi
    3192:	mov    rax,QWORD PTR [rip+0x0]        # 3199 <botlish_fn_19+0x271>
			3195: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    3199:	call   rax
    319b:	xor    rax,rax
    319e:	mov    rbx,QWORD PTR [rsp+0x40]
    31a3:	mov    r12,QWORD PTR [rsp+0x48]
    31a8:	mov    r13,QWORD PTR [rsp+0x50]
    31ad:	mov    r14,QWORD PTR [rsp+0x58]
    31b2:	mov    r15,QWORD PTR [rsp+0x60]
    31b7:	add    rsp,0x70
    31bb:	mov    rsp,rbp
    31be:	pop    rbp
    31bf:	ret
    31c0:	(bad)
    31c1:	add    BYTE PTR [rax],al
    31c3:	add    BYTE PTR [rax],al
    31c5:	add    BYTE PTR [rax],al
	...

00000000000031c8 <botlish_entry_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    31c8:	push   rbp
    31c9:	mov    rbp,rsp
    31cc:	mov    rsi,QWORD PTR [rdx]
    31cf:	mov    r10,QWORD PTR [rdx+0x8]
    31d3:	mov    rcx,QWORD PTR [rdx+0x10]
    31d7:	mov    r8,QWORD PTR [rdx+0x18]
    31db:	mov    r9,QWORD PTR [rdx+0x20]
    31df:	mov    rdx,r10
    31e2:	call   31e7 <botlish_entry_19+0x1f>
			31e3: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    31e7:	mov    rsp,rbp
    31ea:	pop    rbp
    31eb:	ret

00000000000031ec <botlish_fn_20: csv_parse<str>>:
    31ec:	push   rbp
    31ed:	mov    rbp,rsp
    31f0:	sub    rsp,0x30
    31f4:	mov    QWORD PTR [rsp+0x10],rbx
    31f9:	mov    QWORD PTR [rsp+0x18],r12
    31fe:	mov    QWORD PTR [rsp+0x20],r13
    3203:	mov    rbx,QWORD PTR [rdi]
    3206:	mov    rax,QWORD PTR [rdi+0x8]
    320a:	lea    rcx,[rbx+0x28]
    320e:	cmp    rcx,rax
    3211:	ja     32e6 <botlish_fn_20+0xfa>
    3217:	lea    rax,[rbx+0x28]
    321b:	mov    QWORD PTR [rdi],rax
    321e:	mov    r12,rdi
    3221:	mov    QWORD PTR [rbx],0x0
    3228:	mov    QWORD PTR [rbx+0x8],0x0
    3230:	mov    QWORD PTR [rbx+0x10],0x0
    3238:	mov    QWORD PTR [rbx+0x18],0x0
    3240:	mov    QWORD PTR [rbx+0x20],0x0
    3248:	mov    QWORD PTR [rbx],rsi
    324b:	mov    r13,rsi
    324e:	mov    QWORD PTR [rbx+0x8],0x1
    3256:	lea    rsi,[rsp]
    325a:	mov    rdi,r12
    325d:	call   3262 <botlish_fn_20+0x76>
			325e: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    3262:	test   rax,rax
    3265:	jne    3273 <botlish_fn_20+0x87>
    326b:	mov    rdi,r12
    326e:	jmp    32a7 <botlish_fn_20+0xbb>
    3273:	mov    QWORD PTR [rbx+0x10],rax
    3277:	mov    rcx,rax
    327a:	mov    r8,QWORD PTR [rsp]
    327e:	mov    QWORD PTR [rbx+0x18],r8
    3282:	mov    r9,QWORD PTR [rsp+0x8]
    3287:	mov    QWORD PTR [rbx+0x20],r9
    328b:	mov    edx,0x1
    3290:	mov    rsi,r13
    3293:	mov    rdi,r12
    3296:	call   329b <botlish_fn_20+0xaf>
			3297: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    329b:	test   rax,rax
    329e:	jne    32c8 <botlish_fn_20+0xdc>
    32a4:	mov    rdi,r12
    32a7:	mov    rdi,r12
    32aa:	mov    QWORD PTR [rdi],rbx
    32ad:	xor    rax,rax
    32b0:	mov    rbx,QWORD PTR [rsp+0x10]
    32b5:	mov    r12,QWORD PTR [rsp+0x18]
    32ba:	mov    r13,QWORD PTR [rsp+0x20]
    32bf:	add    rsp,0x30
    32c3:	mov    rsp,rbp
    32c6:	pop    rbp
    32c7:	ret
    32c8:	mov    rdi,r12
    32cb:	mov    QWORD PTR [rdi],rbx
    32ce:	mov    rbx,QWORD PTR [rsp+0x10]
    32d3:	mov    r12,QWORD PTR [rsp+0x18]
    32d8:	mov    r13,QWORD PTR [rsp+0x20]
    32dd:	add    rsp,0x30
    32e1:	mov    rsp,rbp
    32e4:	pop    rbp
    32e5:	ret
    32e6:	mov    r12,rdi
    32e9:	mov    rax,QWORD PTR [rip+0x0]        # 32f0 <botlish_fn_20+0x104>
			32ec: R_X86_64_GOTPCREL	rt_stack_overflow-0x4
    32f0:	call   rax
    32f2:	xor    rax,rax
    32f5:	mov    rbx,QWORD PTR [rsp+0x10]
    32fa:	mov    r12,QWORD PTR [rsp+0x18]
    32ff:	mov    r13,QWORD PTR [rsp+0x20]
    3304:	add    rsp,0x30
    3308:	mov    rsp,rbp
    330b:	pop    rbp
    330c:	ret

000000000000330d <botlish_entry_20: csv_parse<str>>:
    330d:	push   rbp
    330e:	mov    rbp,rsp
    3311:	mov    rsi,QWORD PTR [rdx]
    3314:	call   3319 <botlish_entry_20+0xc>
			3315: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    3319:	mov    rsp,rbp
    331c:	pop    rbp
    331d:	ret

; source:  examples/stdlib/csv_chunked.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 12690  (per function: 169 28 318 702 702 702 702 808 728 710 710 453 502 677 887 470 899 936 609 684 294)
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
      a7:	mov    eax,0x81
      ac:	mov    rsp,rbp
      af:	pop    rbp
      b0:	ret

00000000000000b1 <botlish_entry_1: chunk_size<generic>>:
      b1:	push   rbp
      b2:	mov    rbp,rsp
      b5:	call   ba <botlish_entry_1+0x9>
			b6: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
      ba:	mov    rsp,rbp
      bd:	pop    rbp
      be:	ret

00000000000000bf <botlish_fn_2: chunked_new<generic>>:
      bf:	push   rbp
      c0:	mov    rbp,rsp
      c3:	sub    rsp,0x20
      c7:	mov    QWORD PTR [rsp],rbx
      cb:	mov    QWORD PTR [rsp+0x8],r12
      d0:	mov    QWORD PTR [rsp+0x10],r13
      d5:	mov    QWORD PTR [rsp+0x18],r14
      da:	mov    r13,rsi
      dd:	mov    rbx,QWORD PTR [rdi]
      e0:	mov    rax,QWORD PTR [rdi+0x8]
      e4:	lea    rcx,[rbx+0x10]
      e8:	cmp    rcx,rax
      eb:	ja     1bb <botlish_fn_2+0xfc>
      f1:	lea    rax,[rbx+0x10]
      f5:	mov    QWORD PTR [rdi],rax
      f8:	mov    r12,rdi
      fb:	mov    QWORD PTR [rbx],0x0
     102:	mov    QWORD PTR [rbx+0x8],0x0
     10a:	xor    rdx,rdx
     10d:	mov    rdi,r12
     110:	mov    rsi,rdx
     113:	call   118 <botlish_fn_2+0x59>
			114: R_X86_64_PLT32	rt_list_new-0x4
     118:	test   rax,rax
     11b:	jne    129 <botlish_fn_2+0x6a>
     121:	mov    rdi,r12
     124:	jmp    163 <botlish_fn_2+0xa4>
     129:	mov    QWORD PTR [rbx],rax
     12c:	mov    r14,rax
     12f:	mov    rdi,r12
     132:	call   137 <botlish_fn_2+0x78>
			133: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     137:	test   rax,rax
     13a:	jne    148 <botlish_fn_2+0x89>
     140:	mov    rdi,r12
     143:	jmp    163 <botlish_fn_2+0xa4>
     148:	mov    QWORD PTR [rbx+0x8],rax
     14c:	mov    rsi,rax
     14f:	mov    rdi,r12
     152:	call   157 <botlish_fn_2+0x98>
			153: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     157:	test   rax,rax
     15a:	jne    188 <botlish_fn_2+0xc9>
     160:	mov    rdi,r12
     163:	mov    rdi,r12
     166:	mov    QWORD PTR [rdi],rbx
     169:	xor    rax,rax
     16c:	mov    rbx,QWORD PTR [rsp]
     170:	mov    r12,QWORD PTR [rsp+0x8]
     175:	mov    r13,QWORD PTR [rsp+0x10]
     17a:	mov    r14,QWORD PTR [rsp+0x18]
     17f:	add    rsp,0x20
     183:	mov    rsp,rbp
     186:	pop    rbp
     187:	ret
     188:	mov    rdi,r12
     18b:	mov    QWORD PTR [rdi],rbx
     18e:	mov    rsi,r13
     191:	mov    QWORD PTR [rsi],rax
     194:	mov    QWORD PTR [rsi+0x8],0x1
     19c:	mov    rax,r14
     19f:	mov    rbx,QWORD PTR [rsp]
     1a3:	mov    r12,QWORD PTR [rsp+0x8]
     1a8:	mov    r13,QWORD PTR [rsp+0x10]
     1ad:	mov    r14,QWORD PTR [rsp+0x18]
     1b2:	add    rsp,0x20
     1b6:	mov    rsp,rbp
     1b9:	pop    rbp
     1ba:	ret
     1bb:	mov    r12,rdi
     1be:	call   1c3 <botlish_fn_2+0x104>
			1bf: R_X86_64_PLT32	rt_stack_overflow-0x4
     1c3:	xor    rax,rax
     1c6:	mov    rbx,QWORD PTR [rsp]
     1ca:	mov    r12,QWORD PTR [rsp+0x8]
     1cf:	mov    r13,QWORD PTR [rsp+0x10]
     1d4:	mov    r14,QWORD PTR [rsp+0x18]
     1d9:	add    rsp,0x20
     1dd:	mov    rsp,rbp
     1e0:	pop    rbp
     1e1:	ret

00000000000001e2 <botlish_entry_2: chunked_new<generic>>:
     1e2:	push   rbp
     1e3:	mov    rbp,rsp
     1e6:	ud2

00000000000001e8 <botlish_fn_3: chunked_append<list[list<never>, mutarray, int], str>>:
     1e8:	push   rbp
     1e9:	mov    rbp,rsp
     1ec:	sub    rsp,0x40
     1f0:	mov    QWORD PTR [rsp+0x10],rbx
     1f5:	mov    QWORD PTR [rsp+0x18],r12
     1fa:	mov    QWORD PTR [rsp+0x20],r13
     1ff:	mov    QWORD PTR [rsp+0x28],r14
     204:	mov    QWORD PTR [rsp+0x30],r15
     209:	mov    rbx,r9
     20c:	mov    r13,QWORD PTR [rdi]
     20f:	mov    rax,QWORD PTR [rdi+0x8]
     213:	lea    r9,[r13+0x20]
     217:	cmp    r9,rax
     21a:	ja     437 <botlish_fn_3+0x24f>
     220:	lea    rax,[r13+0x20]
     224:	mov    QWORD PTR [rdi],rax
     227:	mov    r14,rdi
     22a:	mov    QWORD PTR [r13+0x0],rsi
     22e:	mov    r15,rsi
     231:	mov    QWORD PTR [r13+0x8],rdx
     235:	mov    QWORD PTR [rsp],rdx
     239:	mov    QWORD PTR [r13+0x10],rcx
     23d:	mov    r12,rcx
     240:	mov    QWORD PTR [r13+0x18],r8
     244:	mov    QWORD PTR [rsp+0x8],r8
     249:	mov    rdi,r14
     24c:	call   251 <botlish_fn_3+0x69>
			24d: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     251:	test   rax,rax
     254:	jne    262 <botlish_fn_3+0x7a>
     25a:	mov    rdi,r14
     25d:	jmp    3d3 <botlish_fn_3+0x1eb>
     262:	mov    rcx,r12
     265:	and    rcx,rax
     268:	mov    rdx,rax
     26b:	test   rcx,0x1
     272:	jne    298 <botlish_fn_3+0xb0>
     278:	mov    rsi,r12
     27b:	mov    rdi,r14
     27e:	call   283 <botlish_fn_3+0x9b>
			27f: R_X86_64_PLT32	rt_int_cmp-0x4
     283:	mov    ecx,0x2
     288:	test   rax,rax
     28b:	cmove  rcx,QWORD PTR [rip+0x1d5]        # 468 <botlish_fn_3+0x280>
     293:	jmp    2a8 <botlish_fn_3+0xc0>
     298:	mov    ecx,0x2
     29d:	cmp    r12,rdx
     2a0:	cmove  rcx,QWORD PTR [rip+0x1c0]        # 468 <botlish_fn_3+0x280>
     2a8:	cmp    rcx,0x6
     2ac:	je     34f <botlish_fn_3+0x167>
     2b2:	mov    rcx,QWORD PTR [rsp+0x8]
     2b7:	mov    rdx,r12
     2ba:	mov    rsi,QWORD PTR [rsp]
     2be:	mov    rdi,r14
     2c1:	call   2c6 <botlish_fn_3+0xde>
			2c2: R_X86_64_PLT32	rt_mutarray_set-0x4
     2c6:	test   rax,rax
     2c9:	jne    2d7 <botlish_fn_3+0xef>
     2cf:	mov    rdi,r14
     2d2:	jmp    3d3 <botlish_fn_3+0x1eb>
     2d7:	mov    QWORD PTR [r13+0x18],0x3
     2df:	test   r12,0x1
     2e6:	je     306 <botlish_fn_3+0x11e>
     2ec:	mov    rax,r12
     2ef:	add    rax,0x2
     2f3:	seto   cl
     2f6:	test   cl,cl
     2f8:	jne    306 <botlish_fn_3+0x11e>
     2fe:	mov    rdi,r14
     301:	jmp    319 <botlish_fn_3+0x131>
     306:	mov    edx,0x3
     30b:	mov    rsi,r12
     30e:	mov    rdi,r14
     311:	call   316 <botlish_fn_3+0x12e>
			312: R_X86_64_PLT32	rt_int_add-0x4
     316:	mov    rdi,r14
     319:	mov    rdi,r14
     31c:	mov    QWORD PTR [rdi],r13
     31f:	mov    rdx,QWORD PTR [rsp]
     323:	mov    QWORD PTR [rbx],rdx
     326:	mov    QWORD PTR [rbx+0x8],rax
     32a:	mov    rax,r15
     32d:	mov    rbx,QWORD PTR [rsp+0x10]
     332:	mov    r12,QWORD PTR [rsp+0x18]
     337:	mov    r13,QWORD PTR [rsp+0x20]
     33c:	mov    r14,QWORD PTR [rsp+0x28]
     341:	mov    r15,QWORD PTR [rsp+0x30]
     346:	add    rsp,0x40
     34a:	mov    rsp,rbp
     34d:	pop    rbp
     34e:	ret
     34f:	mov    rdx,QWORD PTR [rsp]
     353:	mov    rsi,r15
     356:	mov    rdi,r14
     359:	call   35e <botlish_fn_3+0x176>
			35a: R_X86_64_PLT32	rt_list_append-0x4
     35e:	test   rax,rax
     361:	jne    36f <botlish_fn_3+0x187>
     367:	mov    rdi,r14
     36a:	jmp    3d3 <botlish_fn_3+0x1eb>
     36f:	mov    QWORD PTR [r13+0x0],rax
     373:	mov    r12,rax
     376:	mov    rdi,r14
     379:	call   37e <botlish_fn_3+0x196>
			37a: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     37e:	test   rax,rax
     381:	jne    38f <botlish_fn_3+0x1a7>
     387:	mov    rdi,r14
     38a:	jmp    3d3 <botlish_fn_3+0x1eb>
     38f:	mov    QWORD PTR [r13+0x8],rax
     393:	mov    rsi,rax
     396:	mov    rdi,r14
     399:	call   39e <botlish_fn_3+0x1b6>
			39a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     39e:	test   rax,rax
     3a1:	mov    r15,rax
     3a4:	jne    3b2 <botlish_fn_3+0x1ca>
     3aa:	mov    rdi,r14
     3ad:	jmp    3d3 <botlish_fn_3+0x1eb>
     3b2:	mov    edx,0x1
     3b7:	mov    rcx,QWORD PTR [rsp+0x8]
     3bc:	mov    rsi,r15
     3bf:	mov    rdi,r14
     3c2:	call   3c7 <botlish_fn_3+0x1df>
			3c3: R_X86_64_PLT32	rt_mutarray_set-0x4
     3c7:	test   rax,rax
     3ca:	jne    3fe <botlish_fn_3+0x216>
     3d0:	mov    rdi,r14
     3d3:	mov    rdi,r14
     3d6:	mov    QWORD PTR [rdi],r13
     3d9:	xor    rax,rax
     3dc:	mov    rbx,QWORD PTR [rsp+0x10]
     3e1:	mov    r12,QWORD PTR [rsp+0x18]
     3e6:	mov    r13,QWORD PTR [rsp+0x20]
     3eb:	mov    r14,QWORD PTR [rsp+0x28]
     3f0:	mov    r15,QWORD PTR [rsp+0x30]
     3f5:	add    rsp,0x40
     3f9:	mov    rsp,rbp
     3fc:	pop    rbp
     3fd:	ret
     3fe:	mov    rdi,r14
     401:	mov    QWORD PTR [rdi],r13
     404:	mov    rax,r15
     407:	mov    QWORD PTR [rbx],rax
     40a:	mov    QWORD PTR [rbx+0x8],0x3
     412:	mov    rax,r12
     415:	mov    rbx,QWORD PTR [rsp+0x10]
     41a:	mov    r12,QWORD PTR [rsp+0x18]
     41f:	mov    r13,QWORD PTR [rsp+0x20]
     424:	mov    r14,QWORD PTR [rsp+0x28]
     429:	mov    r15,QWORD PTR [rsp+0x30]
     42e:	add    rsp,0x40
     432:	mov    rsp,rbp
     435:	pop    rbp
     436:	ret
     437:	mov    r14,rdi
     43a:	call   43f <botlish_fn_3+0x257>
			43b: R_X86_64_PLT32	rt_stack_overflow-0x4
     43f:	xor    rax,rax
     442:	mov    rbx,QWORD PTR [rsp+0x10]
     447:	mov    r12,QWORD PTR [rsp+0x18]
     44c:	mov    r13,QWORD PTR [rsp+0x20]
     451:	mov    r14,QWORD PTR [rsp+0x28]
     456:	mov    r15,QWORD PTR [rsp+0x30]
     45b:	add    rsp,0x40
     45f:	mov    rsp,rbp
     462:	pop    rbp
     463:	ret
     464:	add    BYTE PTR [rax],al
     466:	add    BYTE PTR [rax],al
     468:	(bad)
     469:	add    BYTE PTR [rax],al
     46b:	add    BYTE PTR [rax],al
     46d:	add    BYTE PTR [rax],al
	...

0000000000000470 <botlish_entry_3: chunked_append<list[list<never>, mutarray, int], str>>:
     470:	push   rbp
     471:	mov    rbp,rsp
     474:	ud2
	...

0000000000000478 <botlish_fn_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     478:	push   rbp
     479:	mov    rbp,rsp
     47c:	sub    rsp,0x40
     480:	mov    QWORD PTR [rsp+0x10],rbx
     485:	mov    QWORD PTR [rsp+0x18],r12
     48a:	mov    QWORD PTR [rsp+0x20],r13
     48f:	mov    QWORD PTR [rsp+0x28],r14
     494:	mov    QWORD PTR [rsp+0x30],r15
     499:	mov    rbx,r9
     49c:	mov    r13,QWORD PTR [rdi]
     49f:	mov    rax,QWORD PTR [rdi+0x8]
     4a3:	lea    r9,[r13+0x20]
     4a7:	cmp    r9,rax
     4aa:	ja     6c7 <botlish_fn_4+0x24f>
     4b0:	lea    rax,[r13+0x20]
     4b4:	mov    QWORD PTR [rdi],rax
     4b7:	mov    r14,rdi
     4ba:	mov    QWORD PTR [r13+0x0],rsi
     4be:	mov    r15,rsi
     4c1:	mov    QWORD PTR [r13+0x8],rdx
     4c5:	mov    QWORD PTR [rsp],rdx
     4c9:	mov    QWORD PTR [r13+0x10],rcx
     4cd:	mov    r12,rcx
     4d0:	mov    QWORD PTR [r13+0x18],r8
     4d4:	mov    QWORD PTR [rsp+0x8],r8
     4d9:	mov    rdi,r14
     4dc:	call   4e1 <botlish_fn_4+0x69>
			4dd: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     4e1:	test   rax,rax
     4e4:	jne    4f2 <botlish_fn_4+0x7a>
     4ea:	mov    rdi,r14
     4ed:	jmp    663 <botlish_fn_4+0x1eb>
     4f2:	mov    rcx,r12
     4f5:	and    rcx,rax
     4f8:	mov    rdx,rax
     4fb:	test   rcx,0x1
     502:	jne    528 <botlish_fn_4+0xb0>
     508:	mov    rsi,r12
     50b:	mov    rdi,r14
     50e:	call   513 <botlish_fn_4+0x9b>
			50f: R_X86_64_PLT32	rt_int_cmp-0x4
     513:	mov    ecx,0x2
     518:	test   rax,rax
     51b:	cmove  rcx,QWORD PTR [rip+0x1d5]        # 6f8 <botlish_fn_4+0x280>
     523:	jmp    538 <botlish_fn_4+0xc0>
     528:	mov    ecx,0x2
     52d:	cmp    r12,rdx
     530:	cmove  rcx,QWORD PTR [rip+0x1c0]        # 6f8 <botlish_fn_4+0x280>
     538:	cmp    rcx,0x6
     53c:	je     5df <botlish_fn_4+0x167>
     542:	mov    rcx,QWORD PTR [rsp+0x8]
     547:	mov    rdx,r12
     54a:	mov    rsi,QWORD PTR [rsp]
     54e:	mov    rdi,r14
     551:	call   556 <botlish_fn_4+0xde>
			552: R_X86_64_PLT32	rt_mutarray_set-0x4
     556:	test   rax,rax
     559:	jne    567 <botlish_fn_4+0xef>
     55f:	mov    rdi,r14
     562:	jmp    663 <botlish_fn_4+0x1eb>
     567:	mov    QWORD PTR [r13+0x18],0x3
     56f:	test   r12,0x1
     576:	je     596 <botlish_fn_4+0x11e>
     57c:	mov    rax,r12
     57f:	add    rax,0x2
     583:	seto   cl
     586:	test   cl,cl
     588:	jne    596 <botlish_fn_4+0x11e>
     58e:	mov    rdi,r14
     591:	jmp    5a9 <botlish_fn_4+0x131>
     596:	mov    edx,0x3
     59b:	mov    rsi,r12
     59e:	mov    rdi,r14
     5a1:	call   5a6 <botlish_fn_4+0x12e>
			5a2: R_X86_64_PLT32	rt_int_add-0x4
     5a6:	mov    rdi,r14
     5a9:	mov    rdi,r14
     5ac:	mov    QWORD PTR [rdi],r13
     5af:	mov    rdx,QWORD PTR [rsp]
     5b3:	mov    QWORD PTR [rbx],rdx
     5b6:	mov    QWORD PTR [rbx+0x8],rax
     5ba:	mov    rax,r15
     5bd:	mov    rbx,QWORD PTR [rsp+0x10]
     5c2:	mov    r12,QWORD PTR [rsp+0x18]
     5c7:	mov    r13,QWORD PTR [rsp+0x20]
     5cc:	mov    r14,QWORD PTR [rsp+0x28]
     5d1:	mov    r15,QWORD PTR [rsp+0x30]
     5d6:	add    rsp,0x40
     5da:	mov    rsp,rbp
     5dd:	pop    rbp
     5de:	ret
     5df:	mov    rdx,QWORD PTR [rsp]
     5e3:	mov    rsi,r15
     5e6:	mov    rdi,r14
     5e9:	call   5ee <botlish_fn_4+0x176>
			5ea: R_X86_64_PLT32	rt_list_append-0x4
     5ee:	test   rax,rax
     5f1:	jne    5ff <botlish_fn_4+0x187>
     5f7:	mov    rdi,r14
     5fa:	jmp    663 <botlish_fn_4+0x1eb>
     5ff:	mov    QWORD PTR [r13+0x0],rax
     603:	mov    r12,rax
     606:	mov    rdi,r14
     609:	call   60e <botlish_fn_4+0x196>
			60a: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     60e:	test   rax,rax
     611:	jne    61f <botlish_fn_4+0x1a7>
     617:	mov    rdi,r14
     61a:	jmp    663 <botlish_fn_4+0x1eb>
     61f:	mov    QWORD PTR [r13+0x8],rax
     623:	mov    rsi,rax
     626:	mov    rdi,r14
     629:	call   62e <botlish_fn_4+0x1b6>
			62a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     62e:	test   rax,rax
     631:	mov    r15,rax
     634:	jne    642 <botlish_fn_4+0x1ca>
     63a:	mov    rdi,r14
     63d:	jmp    663 <botlish_fn_4+0x1eb>
     642:	mov    edx,0x1
     647:	mov    rcx,QWORD PTR [rsp+0x8]
     64c:	mov    rsi,r15
     64f:	mov    rdi,r14
     652:	call   657 <botlish_fn_4+0x1df>
			653: R_X86_64_PLT32	rt_mutarray_set-0x4
     657:	test   rax,rax
     65a:	jne    68e <botlish_fn_4+0x216>
     660:	mov    rdi,r14
     663:	mov    rdi,r14
     666:	mov    QWORD PTR [rdi],r13
     669:	xor    rax,rax
     66c:	mov    rbx,QWORD PTR [rsp+0x10]
     671:	mov    r12,QWORD PTR [rsp+0x18]
     676:	mov    r13,QWORD PTR [rsp+0x20]
     67b:	mov    r14,QWORD PTR [rsp+0x28]
     680:	mov    r15,QWORD PTR [rsp+0x30]
     685:	add    rsp,0x40
     689:	mov    rsp,rbp
     68c:	pop    rbp
     68d:	ret
     68e:	mov    rdi,r14
     691:	mov    QWORD PTR [rdi],r13
     694:	mov    rax,r15
     697:	mov    QWORD PTR [rbx],rax
     69a:	mov    QWORD PTR [rbx+0x8],0x3
     6a2:	mov    rax,r12
     6a5:	mov    rbx,QWORD PTR [rsp+0x10]
     6aa:	mov    r12,QWORD PTR [rsp+0x18]
     6af:	mov    r13,QWORD PTR [rsp+0x20]
     6b4:	mov    r14,QWORD PTR [rsp+0x28]
     6b9:	mov    r15,QWORD PTR [rsp+0x30]
     6be:	add    rsp,0x40
     6c2:	mov    rsp,rbp
     6c5:	pop    rbp
     6c6:	ret
     6c7:	mov    r14,rdi
     6ca:	call   6cf <botlish_fn_4+0x257>
			6cb: R_X86_64_PLT32	rt_stack_overflow-0x4
     6cf:	xor    rax,rax
     6d2:	mov    rbx,QWORD PTR [rsp+0x10]
     6d7:	mov    r12,QWORD PTR [rsp+0x18]
     6dc:	mov    r13,QWORD PTR [rsp+0x20]
     6e1:	mov    r14,QWORD PTR [rsp+0x28]
     6e6:	mov    r15,QWORD PTR [rsp+0x30]
     6eb:	add    rsp,0x40
     6ef:	mov    rsp,rbp
     6f2:	pop    rbp
     6f3:	ret
     6f4:	add    BYTE PTR [rax],al
     6f6:	add    BYTE PTR [rax],al
     6f8:	(bad)
     6f9:	add    BYTE PTR [rax],al
     6fb:	add    BYTE PTR [rax],al
     6fd:	add    BYTE PTR [rax],al
	...

0000000000000700 <botlish_entry_4: chunked_append<list[list<mutarray>, mutarray, int], str>>:
     700:	push   rbp
     701:	mov    rbp,rsp
     704:	ud2
	...

0000000000000708 <botlish_fn_5: chunked_append<list[list<never>, mutarray, int], list>>:
     708:	push   rbp
     709:	mov    rbp,rsp
     70c:	sub    rsp,0x40
     710:	mov    QWORD PTR [rsp+0x10],rbx
     715:	mov    QWORD PTR [rsp+0x18],r12
     71a:	mov    QWORD PTR [rsp+0x20],r13
     71f:	mov    QWORD PTR [rsp+0x28],r14
     724:	mov    QWORD PTR [rsp+0x30],r15
     729:	mov    rbx,r9
     72c:	mov    r13,QWORD PTR [rdi]
     72f:	mov    rax,QWORD PTR [rdi+0x8]
     733:	lea    r9,[r13+0x20]
     737:	cmp    r9,rax
     73a:	ja     957 <botlish_fn_5+0x24f>
     740:	lea    rax,[r13+0x20]
     744:	mov    QWORD PTR [rdi],rax
     747:	mov    r14,rdi
     74a:	mov    QWORD PTR [r13+0x0],rsi
     74e:	mov    r15,rsi
     751:	mov    QWORD PTR [r13+0x8],rdx
     755:	mov    QWORD PTR [rsp],rdx
     759:	mov    QWORD PTR [r13+0x10],rcx
     75d:	mov    r12,rcx
     760:	mov    QWORD PTR [r13+0x18],r8
     764:	mov    QWORD PTR [rsp+0x8],r8
     769:	mov    rdi,r14
     76c:	call   771 <botlish_fn_5+0x69>
			76d: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     771:	test   rax,rax
     774:	jne    782 <botlish_fn_5+0x7a>
     77a:	mov    rdi,r14
     77d:	jmp    8f3 <botlish_fn_5+0x1eb>
     782:	mov    rcx,r12
     785:	and    rcx,rax
     788:	mov    rdx,rax
     78b:	test   rcx,0x1
     792:	jne    7b8 <botlish_fn_5+0xb0>
     798:	mov    rsi,r12
     79b:	mov    rdi,r14
     79e:	call   7a3 <botlish_fn_5+0x9b>
			79f: R_X86_64_PLT32	rt_int_cmp-0x4
     7a3:	mov    ecx,0x2
     7a8:	test   rax,rax
     7ab:	cmove  rcx,QWORD PTR [rip+0x1d5]        # 988 <botlish_fn_5+0x280>
     7b3:	jmp    7c8 <botlish_fn_5+0xc0>
     7b8:	mov    ecx,0x2
     7bd:	cmp    r12,rdx
     7c0:	cmove  rcx,QWORD PTR [rip+0x1c0]        # 988 <botlish_fn_5+0x280>
     7c8:	cmp    rcx,0x6
     7cc:	je     86f <botlish_fn_5+0x167>
     7d2:	mov    rcx,QWORD PTR [rsp+0x8]
     7d7:	mov    rdx,r12
     7da:	mov    rsi,QWORD PTR [rsp]
     7de:	mov    rdi,r14
     7e1:	call   7e6 <botlish_fn_5+0xde>
			7e2: R_X86_64_PLT32	rt_mutarray_set-0x4
     7e6:	test   rax,rax
     7e9:	jne    7f7 <botlish_fn_5+0xef>
     7ef:	mov    rdi,r14
     7f2:	jmp    8f3 <botlish_fn_5+0x1eb>
     7f7:	mov    QWORD PTR [r13+0x18],0x3
     7ff:	test   r12,0x1
     806:	je     826 <botlish_fn_5+0x11e>
     80c:	mov    rax,r12
     80f:	add    rax,0x2
     813:	seto   cl
     816:	test   cl,cl
     818:	jne    826 <botlish_fn_5+0x11e>
     81e:	mov    rdi,r14
     821:	jmp    839 <botlish_fn_5+0x131>
     826:	mov    edx,0x3
     82b:	mov    rsi,r12
     82e:	mov    rdi,r14
     831:	call   836 <botlish_fn_5+0x12e>
			832: R_X86_64_PLT32	rt_int_add-0x4
     836:	mov    rdi,r14
     839:	mov    rdi,r14
     83c:	mov    QWORD PTR [rdi],r13
     83f:	mov    rdx,QWORD PTR [rsp]
     843:	mov    QWORD PTR [rbx],rdx
     846:	mov    QWORD PTR [rbx+0x8],rax
     84a:	mov    rax,r15
     84d:	mov    rbx,QWORD PTR [rsp+0x10]
     852:	mov    r12,QWORD PTR [rsp+0x18]
     857:	mov    r13,QWORD PTR [rsp+0x20]
     85c:	mov    r14,QWORD PTR [rsp+0x28]
     861:	mov    r15,QWORD PTR [rsp+0x30]
     866:	add    rsp,0x40
     86a:	mov    rsp,rbp
     86d:	pop    rbp
     86e:	ret
     86f:	mov    rdx,QWORD PTR [rsp]
     873:	mov    rsi,r15
     876:	mov    rdi,r14
     879:	call   87e <botlish_fn_5+0x176>
			87a: R_X86_64_PLT32	rt_list_append-0x4
     87e:	test   rax,rax
     881:	jne    88f <botlish_fn_5+0x187>
     887:	mov    rdi,r14
     88a:	jmp    8f3 <botlish_fn_5+0x1eb>
     88f:	mov    QWORD PTR [r13+0x0],rax
     893:	mov    r12,rax
     896:	mov    rdi,r14
     899:	call   89e <botlish_fn_5+0x196>
			89a: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     89e:	test   rax,rax
     8a1:	jne    8af <botlish_fn_5+0x1a7>
     8a7:	mov    rdi,r14
     8aa:	jmp    8f3 <botlish_fn_5+0x1eb>
     8af:	mov    QWORD PTR [r13+0x8],rax
     8b3:	mov    rsi,rax
     8b6:	mov    rdi,r14
     8b9:	call   8be <botlish_fn_5+0x1b6>
			8ba: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     8be:	test   rax,rax
     8c1:	mov    r15,rax
     8c4:	jne    8d2 <botlish_fn_5+0x1ca>
     8ca:	mov    rdi,r14
     8cd:	jmp    8f3 <botlish_fn_5+0x1eb>
     8d2:	mov    edx,0x1
     8d7:	mov    rcx,QWORD PTR [rsp+0x8]
     8dc:	mov    rsi,r15
     8df:	mov    rdi,r14
     8e2:	call   8e7 <botlish_fn_5+0x1df>
			8e3: R_X86_64_PLT32	rt_mutarray_set-0x4
     8e7:	test   rax,rax
     8ea:	jne    91e <botlish_fn_5+0x216>
     8f0:	mov    rdi,r14
     8f3:	mov    rdi,r14
     8f6:	mov    QWORD PTR [rdi],r13
     8f9:	xor    rax,rax
     8fc:	mov    rbx,QWORD PTR [rsp+0x10]
     901:	mov    r12,QWORD PTR [rsp+0x18]
     906:	mov    r13,QWORD PTR [rsp+0x20]
     90b:	mov    r14,QWORD PTR [rsp+0x28]
     910:	mov    r15,QWORD PTR [rsp+0x30]
     915:	add    rsp,0x40
     919:	mov    rsp,rbp
     91c:	pop    rbp
     91d:	ret
     91e:	mov    rdi,r14
     921:	mov    QWORD PTR [rdi],r13
     924:	mov    rax,r15
     927:	mov    QWORD PTR [rbx],rax
     92a:	mov    QWORD PTR [rbx+0x8],0x3
     932:	mov    rax,r12
     935:	mov    rbx,QWORD PTR [rsp+0x10]
     93a:	mov    r12,QWORD PTR [rsp+0x18]
     93f:	mov    r13,QWORD PTR [rsp+0x20]
     944:	mov    r14,QWORD PTR [rsp+0x28]
     949:	mov    r15,QWORD PTR [rsp+0x30]
     94e:	add    rsp,0x40
     952:	mov    rsp,rbp
     955:	pop    rbp
     956:	ret
     957:	mov    r14,rdi
     95a:	call   95f <botlish_fn_5+0x257>
			95b: R_X86_64_PLT32	rt_stack_overflow-0x4
     95f:	xor    rax,rax
     962:	mov    rbx,QWORD PTR [rsp+0x10]
     967:	mov    r12,QWORD PTR [rsp+0x18]
     96c:	mov    r13,QWORD PTR [rsp+0x20]
     971:	mov    r14,QWORD PTR [rsp+0x28]
     976:	mov    r15,QWORD PTR [rsp+0x30]
     97b:	add    rsp,0x40
     97f:	mov    rsp,rbp
     982:	pop    rbp
     983:	ret
     984:	add    BYTE PTR [rax],al
     986:	add    BYTE PTR [rax],al
     988:	(bad)
     989:	add    BYTE PTR [rax],al
     98b:	add    BYTE PTR [rax],al
     98d:	add    BYTE PTR [rax],al
	...

0000000000000990 <botlish_entry_5: chunked_append<list[list<never>, mutarray, int], list>>:
     990:	push   rbp
     991:	mov    rbp,rsp
     994:	ud2
	...

0000000000000998 <botlish_fn_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     998:	push   rbp
     999:	mov    rbp,rsp
     99c:	sub    rsp,0x40
     9a0:	mov    QWORD PTR [rsp+0x10],rbx
     9a5:	mov    QWORD PTR [rsp+0x18],r12
     9aa:	mov    QWORD PTR [rsp+0x20],r13
     9af:	mov    QWORD PTR [rsp+0x28],r14
     9b4:	mov    QWORD PTR [rsp+0x30],r15
     9b9:	mov    rbx,r9
     9bc:	mov    r13,QWORD PTR [rdi]
     9bf:	mov    rax,QWORD PTR [rdi+0x8]
     9c3:	lea    r9,[r13+0x20]
     9c7:	cmp    r9,rax
     9ca:	ja     be7 <botlish_fn_6+0x24f>
     9d0:	lea    rax,[r13+0x20]
     9d4:	mov    QWORD PTR [rdi],rax
     9d7:	mov    r14,rdi
     9da:	mov    QWORD PTR [r13+0x0],rsi
     9de:	mov    r15,rsi
     9e1:	mov    QWORD PTR [r13+0x8],rdx
     9e5:	mov    QWORD PTR [rsp],rdx
     9e9:	mov    QWORD PTR [r13+0x10],rcx
     9ed:	mov    r12,rcx
     9f0:	mov    QWORD PTR [r13+0x18],r8
     9f4:	mov    QWORD PTR [rsp+0x8],r8
     9f9:	mov    rdi,r14
     9fc:	call   a01 <botlish_fn_6+0x69>
			9fd: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     a01:	test   rax,rax
     a04:	jne    a12 <botlish_fn_6+0x7a>
     a0a:	mov    rdi,r14
     a0d:	jmp    b83 <botlish_fn_6+0x1eb>
     a12:	mov    rcx,r12
     a15:	and    rcx,rax
     a18:	mov    rdx,rax
     a1b:	test   rcx,0x1
     a22:	jne    a48 <botlish_fn_6+0xb0>
     a28:	mov    rsi,r12
     a2b:	mov    rdi,r14
     a2e:	call   a33 <botlish_fn_6+0x9b>
			a2f: R_X86_64_PLT32	rt_int_cmp-0x4
     a33:	mov    ecx,0x2
     a38:	test   rax,rax
     a3b:	cmove  rcx,QWORD PTR [rip+0x1d5]        # c18 <botlish_fn_6+0x280>
     a43:	jmp    a58 <botlish_fn_6+0xc0>
     a48:	mov    ecx,0x2
     a4d:	cmp    r12,rdx
     a50:	cmove  rcx,QWORD PTR [rip+0x1c0]        # c18 <botlish_fn_6+0x280>
     a58:	cmp    rcx,0x6
     a5c:	je     aff <botlish_fn_6+0x167>
     a62:	mov    rcx,QWORD PTR [rsp+0x8]
     a67:	mov    rdx,r12
     a6a:	mov    rsi,QWORD PTR [rsp]
     a6e:	mov    rdi,r14
     a71:	call   a76 <botlish_fn_6+0xde>
			a72: R_X86_64_PLT32	rt_mutarray_set-0x4
     a76:	test   rax,rax
     a79:	jne    a87 <botlish_fn_6+0xef>
     a7f:	mov    rdi,r14
     a82:	jmp    b83 <botlish_fn_6+0x1eb>
     a87:	mov    QWORD PTR [r13+0x18],0x3
     a8f:	test   r12,0x1
     a96:	je     ab6 <botlish_fn_6+0x11e>
     a9c:	mov    rax,r12
     a9f:	add    rax,0x2
     aa3:	seto   cl
     aa6:	test   cl,cl
     aa8:	jne    ab6 <botlish_fn_6+0x11e>
     aae:	mov    rdi,r14
     ab1:	jmp    ac9 <botlish_fn_6+0x131>
     ab6:	mov    edx,0x3
     abb:	mov    rsi,r12
     abe:	mov    rdi,r14
     ac1:	call   ac6 <botlish_fn_6+0x12e>
			ac2: R_X86_64_PLT32	rt_int_add-0x4
     ac6:	mov    rdi,r14
     ac9:	mov    rdi,r14
     acc:	mov    QWORD PTR [rdi],r13
     acf:	mov    rdx,QWORD PTR [rsp]
     ad3:	mov    QWORD PTR [rbx],rdx
     ad6:	mov    QWORD PTR [rbx+0x8],rax
     ada:	mov    rax,r15
     add:	mov    rbx,QWORD PTR [rsp+0x10]
     ae2:	mov    r12,QWORD PTR [rsp+0x18]
     ae7:	mov    r13,QWORD PTR [rsp+0x20]
     aec:	mov    r14,QWORD PTR [rsp+0x28]
     af1:	mov    r15,QWORD PTR [rsp+0x30]
     af6:	add    rsp,0x40
     afa:	mov    rsp,rbp
     afd:	pop    rbp
     afe:	ret
     aff:	mov    rdx,QWORD PTR [rsp]
     b03:	mov    rsi,r15
     b06:	mov    rdi,r14
     b09:	call   b0e <botlish_fn_6+0x176>
			b0a: R_X86_64_PLT32	rt_list_append-0x4
     b0e:	test   rax,rax
     b11:	jne    b1f <botlish_fn_6+0x187>
     b17:	mov    rdi,r14
     b1a:	jmp    b83 <botlish_fn_6+0x1eb>
     b1f:	mov    QWORD PTR [r13+0x0],rax
     b23:	mov    r12,rax
     b26:	mov    rdi,r14
     b29:	call   b2e <botlish_fn_6+0x196>
			b2a: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     b2e:	test   rax,rax
     b31:	jne    b3f <botlish_fn_6+0x1a7>
     b37:	mov    rdi,r14
     b3a:	jmp    b83 <botlish_fn_6+0x1eb>
     b3f:	mov    QWORD PTR [r13+0x8],rax
     b43:	mov    rsi,rax
     b46:	mov    rdi,r14
     b49:	call   b4e <botlish_fn_6+0x1b6>
			b4a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     b4e:	test   rax,rax
     b51:	mov    r15,rax
     b54:	jne    b62 <botlish_fn_6+0x1ca>
     b5a:	mov    rdi,r14
     b5d:	jmp    b83 <botlish_fn_6+0x1eb>
     b62:	mov    edx,0x1
     b67:	mov    rcx,QWORD PTR [rsp+0x8]
     b6c:	mov    rsi,r15
     b6f:	mov    rdi,r14
     b72:	call   b77 <botlish_fn_6+0x1df>
			b73: R_X86_64_PLT32	rt_mutarray_set-0x4
     b77:	test   rax,rax
     b7a:	jne    bae <botlish_fn_6+0x216>
     b80:	mov    rdi,r14
     b83:	mov    rdi,r14
     b86:	mov    QWORD PTR [rdi],r13
     b89:	xor    rax,rax
     b8c:	mov    rbx,QWORD PTR [rsp+0x10]
     b91:	mov    r12,QWORD PTR [rsp+0x18]
     b96:	mov    r13,QWORD PTR [rsp+0x20]
     b9b:	mov    r14,QWORD PTR [rsp+0x28]
     ba0:	mov    r15,QWORD PTR [rsp+0x30]
     ba5:	add    rsp,0x40
     ba9:	mov    rsp,rbp
     bac:	pop    rbp
     bad:	ret
     bae:	mov    rdi,r14
     bb1:	mov    QWORD PTR [rdi],r13
     bb4:	mov    rax,r15
     bb7:	mov    QWORD PTR [rbx],rax
     bba:	mov    QWORD PTR [rbx+0x8],0x3
     bc2:	mov    rax,r12
     bc5:	mov    rbx,QWORD PTR [rsp+0x10]
     bca:	mov    r12,QWORD PTR [rsp+0x18]
     bcf:	mov    r13,QWORD PTR [rsp+0x20]
     bd4:	mov    r14,QWORD PTR [rsp+0x28]
     bd9:	mov    r15,QWORD PTR [rsp+0x30]
     bde:	add    rsp,0x40
     be2:	mov    rsp,rbp
     be5:	pop    rbp
     be6:	ret
     be7:	mov    r14,rdi
     bea:	call   bef <botlish_fn_6+0x257>
			beb: R_X86_64_PLT32	rt_stack_overflow-0x4
     bef:	xor    rax,rax
     bf2:	mov    rbx,QWORD PTR [rsp+0x10]
     bf7:	mov    r12,QWORD PTR [rsp+0x18]
     bfc:	mov    r13,QWORD PTR [rsp+0x20]
     c01:	mov    r14,QWORD PTR [rsp+0x28]
     c06:	mov    r15,QWORD PTR [rsp+0x30]
     c0b:	add    rsp,0x40
     c0f:	mov    rsp,rbp
     c12:	pop    rbp
     c13:	ret
     c14:	add    BYTE PTR [rax],al
     c16:	add    BYTE PTR [rax],al
     c18:	(bad)
     c19:	add    BYTE PTR [rax],al
     c1b:	add    BYTE PTR [rax],al
     c1d:	add    BYTE PTR [rax],al
	...

0000000000000c20 <botlish_entry_6: chunked_append<list[list<mutarray>, mutarray, int], list>>:
     c20:	push   rbp
     c21:	mov    rbp,rsp
     c24:	ud2
	...

0000000000000c28 <botlish_fn_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
     c28:	push   rbp
     c29:	mov    rbp,rsp
     c2c:	sub    rsp,0x40
     c30:	mov    QWORD PTR [rsp+0x10],rbx
     c35:	mov    QWORD PTR [rsp+0x18],r12
     c3a:	mov    QWORD PTR [rsp+0x20],r13
     c3f:	mov    QWORD PTR [rsp+0x28],r14
     c44:	mov    QWORD PTR [rsp+0x30],r15
     c49:	mov    r14,QWORD PTR [rdi]
     c4c:	mov    rax,QWORD PTR [rdi+0x8]
     c50:	lea    r9,[r14+0x30]
     c54:	cmp    r9,rax
     c57:	ja     ec7 <botlish_fn_7+0x29f>
     c5d:	lea    rax,[r14+0x30]
     c61:	mov    QWORD PTR [rdi],rax
     c64:	mov    r15,rdi
     c67:	mov    QWORD PTR [r14],rsi
     c6a:	mov    QWORD PTR [r14+0x8],rdx
     c6e:	mov    rbx,rdx
     c71:	mov    QWORD PTR [r14+0x10],rcx
     c75:	mov    QWORD PTR [rsp],rcx
     c79:	mov    QWORD PTR [r14+0x18],r8
     c7d:	mov    r12,rsi
     c80:	mov    QWORD PTR [rsp+0x8],r8
     c85:	mov    rsi,r12
     c88:	mov    rdi,r15
     c8b:	call   c90 <botlish_fn_7+0x68>
			c8c: R_X86_64_PLT32	rt_list_len-0x4
     c90:	mov    r13,rbx
     c93:	mov    rcx,r13
     c96:	and    rcx,rax
     c99:	mov    rdx,rax
     c9c:	test   rcx,0x1
     ca3:	jne    cc9 <botlish_fn_7+0xa1>
     ca9:	mov    rsi,r13
     cac:	mov    rdi,r15
     caf:	call   cb4 <botlish_fn_7+0x8c>
			cb0: R_X86_64_PLT32	rt_int_cmp-0x4
     cb4:	mov    ecx,0x2
     cb9:	test   rax,rax
     cbc:	cmovge rcx,QWORD PTR [rip+0x234]        # ef8 <botlish_fn_7+0x2d0>
     cc4:	jmp    cd9 <botlish_fn_7+0xb1>
     cc9:	mov    ecx,0x2
     cce:	cmp    r13,rdx
     cd1:	cmovge rcx,QWORD PTR [rip+0x21f]        # ef8 <botlish_fn_7+0x2d0>
     cd9:	cmp    rcx,0x6
     cdd:	je     e9a <botlish_fn_7+0x272>
     ce3:	test   r13,0x1
     cea:	je     d04 <botlish_fn_7+0xdc>
     cf0:	mov    r11,QWORD PTR [r12+0x8]
     cf5:	mov    r10,r13
     cf8:	sar    r10,1
     cfb:	cmp    r10,r11
     cfe:	jb     d2b <botlish_fn_7+0x103>
     d04:	mov    rdx,r13
     d07:	mov    rsi,r12
     d0a:	mov    rdi,r15
     d0d:	call   d12 <botlish_fn_7+0xea>
			d0e: R_X86_64_PLT32	rt_list_get-0x4
     d12:	test   rax,rax
     d15:	jne    d23 <botlish_fn_7+0xfb>
     d1b:	mov    rdi,r15
     d1e:	jmp    dfc <botlish_fn_7+0x1d4>
     d23:	mov    rsi,rax
     d26:	jmp    d37 <botlish_fn_7+0x10f>
     d2b:	mov    rax,QWORD PTR [r12+0x10]
     d30:	mov    rax,QWORD PTR [rax+r10*8]
     d34:	mov    rsi,rax
     d37:	mov    QWORD PTR [r14+0x20],rsi
     d3b:	mov    rbx,rsi
     d3e:	mov    QWORD PTR [r14+0x28],0x1
     d46:	mov    rdi,r15
     d49:	call   d4e <botlish_fn_7+0x126>
			d4a: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     d4e:	test   rax,rax
     d51:	mov    r9,rax
     d54:	jne    d62 <botlish_fn_7+0x13a>
     d5a:	mov    rdi,r15
     d5d:	jmp    dfc <botlish_fn_7+0x1d4>
     d62:	xor    eax,eax
     d64:	mov    rsi,rbx
     d67:	test   rsi,0x7
     d6e:	jne    d7d <botlish_fn_7+0x155>
     d74:	movzx  rax,BYTE PTR [rsi]
     d78:	cmp    al,0x8
     d7a:	sete   al
     d7d:	test   al,al
     d7f:	jne    da2 <botlish_fn_7+0x17a>
     d85:	mov    rdi,r15
     d88:	mov    rax,QWORD PTR [rdi+0x10]
     d8c:	mov    rcx,QWORD PTR [rax+0x8]
     d90:	mov    edx,0x8
     d95:	call   d9a <botlish_fn_7+0x172>
			d96: R_X86_64_PLT32	rt_type_error-0x4
     d9a:	mov    rdi,r15
     d9d:	jmp    dfc <botlish_fn_7+0x1d4>
     da2:	mov    rbx,rsi
     da5:	mov    r8d,0x1
     dab:	mov    rcx,rbx
     dae:	mov    rbx,QWORD PTR [rsp]
     db2:	mov    rdx,QWORD PTR [rsp+0x8]
     db7:	mov    rsi,rbx
     dba:	mov    rdi,r15
     dbd:	call   dc2 <botlish_fn_7+0x19a>
			dbe: R_X86_64_PLT32	rt_mutarray_copy-0x4
     dc2:	test   rax,rax
     dc5:	jne    dd3 <botlish_fn_7+0x1ab>
     dcb:	mov    rdi,r15
     dce:	jmp    dfc <botlish_fn_7+0x1d4>
     dd3:	sar    r13,1
     dd6:	add    r13,0x1
     ddd:	shl    r13,1
     de0:	or     r13,0x1
     de4:	mov    QWORD PTR [r14+0x8],r13
     de8:	mov    rdi,r15
     deb:	call   df0 <botlish_fn_7+0x1c8>
			dec: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
     df0:	test   rax,rax
     df3:	jne    e27 <botlish_fn_7+0x1ff>
     df9:	mov    rdi,r15
     dfc:	mov    rdi,r15
     dff:	mov    QWORD PTR [rdi],r14
     e02:	xor    rax,rax
     e05:	mov    rbx,QWORD PTR [rsp+0x10]
     e0a:	mov    r12,QWORD PTR [rsp+0x18]
     e0f:	mov    r13,QWORD PTR [rsp+0x20]
     e14:	mov    r14,QWORD PTR [rsp+0x28]
     e19:	mov    r15,QWORD PTR [rsp+0x30]
     e1e:	add    rsp,0x40
     e22:	mov    rsp,rbp
     e25:	pop    rbp
     e26:	ret
     e27:	mov    QWORD PTR [r14+0x20],rax
     e2b:	mov    rsi,QWORD PTR [rsp+0x8]
     e30:	mov    rcx,rsi
     e33:	and    rcx,rax
     e36:	test   rcx,0x1
     e3d:	jne    e50 <botlish_fn_7+0x228>
     e43:	mov    rdx,rax
     e46:	mov    rsi,QWORD PTR [rsp+0x8]
     e4b:	jmp    e72 <botlish_fn_7+0x24a>
     e50:	lea    rcx,[rax-0x1]
     e54:	mov    rdx,rax
     e57:	mov    rsi,QWORD PTR [rsp+0x8]
     e5c:	mov    rax,rsi
     e5f:	add    rax,rcx
     e62:	seto   cl
     e65:	test   cl,cl
     e67:	je     e7a <botlish_fn_7+0x252>
     e6d:	mov    rsi,QWORD PTR [rsp+0x8]
     e72:	mov    rdi,r15
     e75:	call   e7a <botlish_fn_7+0x252>
			e76: R_X86_64_PLT32	rt_int_add-0x4
     e7a:	mov    QWORD PTR [r14],r12
     e7d:	mov    QWORD PTR [r14+0x8],r13
     e81:	mov    QWORD PTR [r14+0x10],rbx
     e85:	mov    QWORD PTR [r14+0x18],rax
     e89:	mov    QWORD PTR [rsp+0x8],rax
     e8e:	mov    QWORD PTR [rsp],rbx
     e92:	mov    rbx,r13
     e95:	jmp    c85 <botlish_fn_7+0x5d>
     e9a:	mov    rdi,r15
     e9d:	mov    QWORD PTR [rdi],r14
     ea0:	mov    rax,QWORD PTR [rsp+0x8]
     ea5:	mov    rbx,QWORD PTR [rsp+0x10]
     eaa:	mov    r12,QWORD PTR [rsp+0x18]
     eaf:	mov    r13,QWORD PTR [rsp+0x20]
     eb4:	mov    r14,QWORD PTR [rsp+0x28]
     eb9:	mov    r15,QWORD PTR [rsp+0x30]
     ebe:	add    rsp,0x40
     ec2:	mov    rsp,rbp
     ec5:	pop    rbp
     ec6:	ret
     ec7:	mov    r15,rdi
     eca:	call   ecf <botlish_fn_7+0x2a7>
			ecb: R_X86_64_PLT32	rt_stack_overflow-0x4
     ecf:	xor    rax,rax
     ed2:	mov    rbx,QWORD PTR [rsp+0x10]
     ed7:	mov    r12,QWORD PTR [rsp+0x18]
     edc:	mov    r13,QWORD PTR [rsp+0x20]
     ee1:	mov    r14,QWORD PTR [rsp+0x28]
     ee6:	mov    r15,QWORD PTR [rsp+0x30]
     eeb:	add    rsp,0x40
     eef:	mov    rsp,rbp
     ef2:	pop    rbp
     ef3:	ret
     ef4:	add    BYTE PTR [rax],al
     ef6:	add    BYTE PTR [rax],al
     ef8:	(bad)
     ef9:	add    BYTE PTR [rax],al
     efb:	add    BYTE PTR [rax],al
     efd:	add    BYTE PTR [rax],al
	...

0000000000000f00 <botlish_entry_7: chunked_copy_chunks<list<never>, int, mutarray, int>>:
     f00:	push   rbp
     f01:	mov    rbp,rsp
     f04:	mov    rsi,QWORD PTR [rdx]
     f07:	mov    r9,QWORD PTR [rdx+0x8]
     f0b:	mov    rcx,QWORD PTR [rdx+0x10]
     f0f:	mov    r8,QWORD PTR [rdx+0x18]
     f13:	mov    rdx,r9
     f16:	call   f1b <botlish_entry_7+0x1b>
			f17: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
     f1b:	mov    rsp,rbp
     f1e:	pop    rbp
     f1f:	ret

0000000000000f20 <botlish_fn_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
     f20:	push   rbp
     f21:	mov    rbp,rsp
     f24:	sub    rsp,0x40
     f28:	mov    QWORD PTR [rsp+0x10],rbx
     f2d:	mov    QWORD PTR [rsp+0x18],r12
     f32:	mov    QWORD PTR [rsp+0x20],r13
     f37:	mov    QWORD PTR [rsp+0x28],r14
     f3c:	mov    QWORD PTR [rsp+0x30],r15
     f41:	mov    r14,QWORD PTR [rdi]
     f44:	mov    rax,QWORD PTR [rdi+0x8]
     f48:	lea    r9,[r14+0x30]
     f4c:	cmp    r9,rax
     f4f:	ja     1164 <botlish_fn_8+0x244>
     f55:	lea    rax,[r14+0x30]
     f59:	mov    QWORD PTR [rdi],rax
     f5c:	mov    r15,rdi
     f5f:	mov    QWORD PTR [r14],rsi
     f62:	mov    QWORD PTR [r14+0x8],rdx
     f66:	mov    r12,rdx
     f69:	mov    QWORD PTR [r14+0x10],rcx
     f6d:	mov    r13,rcx
     f70:	mov    QWORD PTR [r14+0x18],r8
     f74:	mov    rbx,rsi
     f77:	mov    QWORD PTR [rsp],r8
     f7b:	mov    rsi,rbx
     f7e:	mov    rdi,r15
     f81:	call   f86 <botlish_fn_8+0x66>
			f82: R_X86_64_PLT32	rt_list_len-0x4
     f86:	mov    rcx,r12
     f89:	and    rcx,rax
     f8c:	mov    rdx,rax
     f8f:	test   rcx,0x1
     f96:	jne    fbc <botlish_fn_8+0x9c>
     f9c:	mov    rsi,r12
     f9f:	mov    rdi,r15
     fa2:	call   fa7 <botlish_fn_8+0x87>
			fa3: R_X86_64_PLT32	rt_int_cmp-0x4
     fa7:	mov    ecx,0x2
     fac:	test   rax,rax
     faf:	cmovge rcx,QWORD PTR [rip+0x1e1]        # 1198 <botlish_fn_8+0x278>
     fb7:	jmp    fcc <botlish_fn_8+0xac>
     fbc:	mov    ecx,0x2
     fc1:	cmp    r12,rdx
     fc4:	cmovge rcx,QWORD PTR [rip+0x1cc]        # 1198 <botlish_fn_8+0x278>
     fcc:	cmp    rcx,0x6
     fd0:	je     1138 <botlish_fn_8+0x218>
     fd6:	test   r12,0x1
     fdd:	je     ff6 <botlish_fn_8+0xd6>
     fe3:	mov    rdx,QWORD PTR [rbx+0x8]
     fe7:	mov    rcx,r12
     fea:	sar    rcx,1
     fed:	cmp    rcx,rdx
     ff0:	jb     101d <botlish_fn_8+0xfd>
     ff6:	mov    rdx,r12
     ff9:	mov    rsi,rbx
     ffc:	mov    rdi,r15
     fff:	call   1004 <botlish_fn_8+0xe4>
			1000: R_X86_64_PLT32	rt_list_get-0x4
    1004:	test   rax,rax
    1007:	jne    1015 <botlish_fn_8+0xf5>
    100d:	mov    rdi,r15
    1010:	jmp    10a6 <botlish_fn_8+0x186>
    1015:	mov    rcx,rax
    1018:	jmp    1025 <botlish_fn_8+0x105>
    101d:	mov    r8,QWORD PTR [rbx+0x10]
    1021:	mov    rcx,QWORD PTR [r8+rcx*8]
    1025:	mov    QWORD PTR [r14+0x20],rcx
    1029:	mov    QWORD PTR [rsp+0x8],rcx
    102e:	mov    QWORD PTR [r14+0x28],0x1
    1036:	mov    rdi,r15
    1039:	call   103e <botlish_fn_8+0x11e>
			103a: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    103e:	test   rax,rax
    1041:	mov    r9,rax
    1044:	jne    1052 <botlish_fn_8+0x132>
    104a:	mov    rdi,r15
    104d:	jmp    10a6 <botlish_fn_8+0x186>
    1052:	mov    r8d,0x1
    1058:	mov    rcx,QWORD PTR [rsp+0x8]
    105d:	mov    rdx,QWORD PTR [rsp]
    1061:	mov    rsi,r13
    1064:	mov    rdi,r15
    1067:	call   106c <botlish_fn_8+0x14c>
			1068: R_X86_64_PLT32	rt_mutarray_copy-0x4
    106c:	test   rax,rax
    106f:	jne    107d <botlish_fn_8+0x15d>
    1075:	mov    rdi,r15
    1078:	jmp    10a6 <botlish_fn_8+0x186>
    107d:	sar    r12,1
    1080:	add    r12,0x1
    1087:	shl    r12,1
    108a:	or     r12,0x1
    108e:	mov    QWORD PTR [r14+0x8],r12
    1092:	mov    rdi,r15
    1095:	call   109a <botlish_fn_8+0x17a>
			1096: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    109a:	test   rax,rax
    109d:	jne    10d1 <botlish_fn_8+0x1b1>
    10a3:	mov    rdi,r15
    10a6:	mov    rdi,r15
    10a9:	mov    QWORD PTR [rdi],r14
    10ac:	xor    rax,rax
    10af:	mov    rbx,QWORD PTR [rsp+0x10]
    10b4:	mov    r12,QWORD PTR [rsp+0x18]
    10b9:	mov    r13,QWORD PTR [rsp+0x20]
    10be:	mov    r14,QWORD PTR [rsp+0x28]
    10c3:	mov    r15,QWORD PTR [rsp+0x30]
    10c8:	add    rsp,0x40
    10cc:	mov    rsp,rbp
    10cf:	pop    rbp
    10d0:	ret
    10d1:	mov    QWORD PTR [r14+0x20],rax
    10d5:	mov    rsi,QWORD PTR [rsp]
    10d9:	mov    rcx,rsi
    10dc:	and    rcx,rax
    10df:	test   rcx,0x1
    10e6:	jne    10f8 <botlish_fn_8+0x1d8>
    10ec:	mov    rdx,rax
    10ef:	mov    rsi,QWORD PTR [rsp]
    10f3:	jmp    1118 <botlish_fn_8+0x1f8>
    10f8:	lea    rcx,[rax-0x1]
    10fc:	mov    rdx,rax
    10ff:	mov    rsi,QWORD PTR [rsp]
    1103:	mov    rax,rsi
    1106:	add    rax,rcx
    1109:	seto   cl
    110c:	test   cl,cl
    110e:	je     1120 <botlish_fn_8+0x200>
    1114:	mov    rsi,QWORD PTR [rsp]
    1118:	mov    rdi,r15
    111b:	call   1120 <botlish_fn_8+0x200>
			111c: R_X86_64_PLT32	rt_int_add-0x4
    1120:	mov    QWORD PTR [r14],rbx
    1123:	mov    QWORD PTR [r14+0x8],r12
    1127:	mov    QWORD PTR [r14+0x10],r13
    112b:	mov    QWORD PTR [r14+0x18],rax
    112f:	mov    QWORD PTR [rsp],rax
    1133:	jmp    f7b <botlish_fn_8+0x5b>
    1138:	mov    rdi,r15
    113b:	mov    QWORD PTR [rdi],r14
    113e:	mov    rax,QWORD PTR [rsp]
    1142:	mov    rbx,QWORD PTR [rsp+0x10]
    1147:	mov    r12,QWORD PTR [rsp+0x18]
    114c:	mov    r13,QWORD PTR [rsp+0x20]
    1151:	mov    r14,QWORD PTR [rsp+0x28]
    1156:	mov    r15,QWORD PTR [rsp+0x30]
    115b:	add    rsp,0x40
    115f:	mov    rsp,rbp
    1162:	pop    rbp
    1163:	ret
    1164:	mov    r15,rdi
    1167:	call   116c <botlish_fn_8+0x24c>
			1168: R_X86_64_PLT32	rt_stack_overflow-0x4
    116c:	xor    rax,rax
    116f:	mov    rbx,QWORD PTR [rsp+0x10]
    1174:	mov    r12,QWORD PTR [rsp+0x18]
    1179:	mov    r13,QWORD PTR [rsp+0x20]
    117e:	mov    r14,QWORD PTR [rsp+0x28]
    1183:	mov    r15,QWORD PTR [rsp+0x30]
    1188:	add    rsp,0x40
    118c:	mov    rsp,rbp
    118f:	pop    rbp
    1190:	ret
    1191:	add    BYTE PTR [rax],al
    1193:	add    BYTE PTR [rax],al
    1195:	add    BYTE PTR [rax],al
    1197:	add    BYTE PTR [rsi],al
    1199:	add    BYTE PTR [rax],al
    119b:	add    BYTE PTR [rax],al
    119d:	add    BYTE PTR [rax],al
	...

00000000000011a0 <botlish_entry_8: chunked_copy_chunks<list<mutarray>, int, mutarray, int>>:
    11a0:	push   rbp
    11a1:	mov    rbp,rsp
    11a4:	mov    rsi,QWORD PTR [rdx]
    11a7:	mov    r9,QWORD PTR [rdx+0x8]
    11ab:	mov    rcx,QWORD PTR [rdx+0x10]
    11af:	mov    r8,QWORD PTR [rdx+0x18]
    11b3:	mov    rdx,r9
    11b6:	call   11bb <botlish_entry_8+0x1b>
			11b7: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    11bb:	mov    rsp,rbp
    11be:	pop    rbp
    11bf:	ret

00000000000011c0 <botlish_fn_9: chunked_finish<list[list<never>, mutarray, int]>>:
    11c0:	push   rbp
    11c1:	mov    rbp,rsp
    11c4:	sub    rsp,0x40
    11c8:	mov    QWORD PTR [rsp+0x10],rbx
    11cd:	mov    QWORD PTR [rsp+0x18],r12
    11d2:	mov    QWORD PTR [rsp+0x20],r13
    11d7:	mov    QWORD PTR [rsp+0x28],r14
    11dc:	mov    QWORD PTR [rsp+0x30],r15
    11e1:	mov    r12,QWORD PTR [rdi]
    11e4:	mov    rax,QWORD PTR [rdi+0x8]
    11e8:	lea    r8,[r12+0x38]
    11ed:	cmp    r8,rax
    11f0:	ja     1410 <botlish_fn_9+0x250>
    11f6:	lea    rax,[r12+0x38]
    11fb:	mov    QWORD PTR [rdi],rax
    11fe:	mov    r14,rdi
    1201:	mov    QWORD PTR [r12+0x20],0x0
    120a:	mov    QWORD PTR [r12+0x28],0x0
    1213:	mov    QWORD PTR [r12+0x30],0x0
    121c:	mov    QWORD PTR [r12],rsi
    1220:	mov    QWORD PTR [rsp],rsi
    1224:	mov    QWORD PTR [r12+0x8],rdx
    1229:	mov    r15,rdx
    122c:	mov    QWORD PTR [r12+0x10],rcx
    1231:	mov    rbx,rcx
    1234:	mov    rsi,QWORD PTR [rsp]
    1238:	mov    rdi,r14
    123b:	call   1240 <botlish_fn_9+0x80>
			123c: R_X86_64_PLT32	rt_list_len-0x4
    1240:	mov    QWORD PTR [r12+0x18],rax
    1245:	mov    r13,rax
    1248:	mov    rdi,r14
    124b:	call   1250 <botlish_fn_9+0x90>
			124c: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    1250:	test   rax,rax
    1253:	jne    1261 <botlish_fn_9+0xa1>
    1259:	mov    rdi,r14
    125c:	jmp    13bd <botlish_fn_9+0x1fd>
    1261:	mov    QWORD PTR [r12+0x20],rax
    1266:	mov    rcx,r13
    1269:	mov    rdx,rcx
    126c:	and    rdx,rax
    126f:	mov    rsi,rax
    1272:	test   rdx,0x1
    1279:	jne    128a <botlish_fn_9+0xca>
    127f:	mov    rdx,rsi
    1282:	mov    rsi,rcx
    1285:	jmp    12bf <botlish_fn_9+0xff>
    128a:	mov    rax,rcx
    128d:	sar    rax,1
    1290:	mov    r13,rcx
    1293:	mov    rcx,rsi
    1296:	lea    rdx,[rcx-0x1]
    129a:	imul   rdx
    129d:	seto   cl
    12a0:	or     rax,0x1
    12a4:	test   cl,cl
    12a6:	je     12b7 <botlish_fn_9+0xf7>
    12ac:	mov    rdx,rsi
    12af:	mov    rsi,r13
    12b2:	jmp    12bf <botlish_fn_9+0xff>
    12b7:	mov    rsi,rax
    12ba:	jmp    12ca <botlish_fn_9+0x10a>
    12bf:	mov    rdi,r14
    12c2:	call   12c7 <botlish_fn_9+0x107>
			12c3: R_X86_64_PLT32	rt_int_mul-0x4
    12c7:	mov    rsi,rax
    12ca:	mov    QWORD PTR [r12+0x18],rsi
    12cf:	mov    rax,rsi
    12d2:	and    rax,rbx
    12d5:	test   rax,0x1
    12db:	je     12f6 <botlish_fn_9+0x136>
    12e1:	lea    rax,[rbx-0x1]
    12e5:	mov    r13,rsi
    12e8:	add    r13,rax
    12eb:	seto   al
    12ee:	test   al,al
    12f0:	je     1304 <botlish_fn_9+0x144>
    12f6:	mov    rdx,rbx
    12f9:	mov    rdi,r14
    12fc:	call   1301 <botlish_fn_9+0x141>
			12fd: R_X86_64_PLT32	rt_int_add-0x4
    1301:	mov    r13,rax
    1304:	mov    QWORD PTR [r12+0x18],r13
    1309:	mov    rsi,r13
    130c:	mov    rdi,r14
    130f:	call   1314 <botlish_fn_9+0x154>
			1310: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    1314:	mov    rcx,rax
    1317:	mov    QWORD PTR [rsp+0x8],rax
    131c:	test   rax,rcx
    131f:	jne    132d <botlish_fn_9+0x16d>
    1325:	mov    rdi,r14
    1328:	jmp    13bd <botlish_fn_9+0x1fd>
    132d:	mov    rax,QWORD PTR [rsp+0x8]
    1332:	mov    QWORD PTR [r12+0x20],rax
    1337:	mov    r8d,0x1
    133d:	mov    QWORD PTR [r12+0x28],0x1
    1346:	mov    QWORD PTR [r12+0x30],0x1
    134f:	mov    rsi,QWORD PTR [rsp]
    1353:	mov    rcx,QWORD PTR [rsp+0x8]
    1358:	mov    rdi,r14
    135b:	mov    rdx,r8
    135e:	call   1363 <botlish_fn_9+0x1a3>
			135f: R_X86_64_PLT32	botlish_fn_7-0x4 ; chunked_copy_chunks<list<never>, int, mutarray, int>
    1363:	test   rax,rax
    1366:	mov    rdx,rax
    1369:	jne    1377 <botlish_fn_9+0x1b7>
    136f:	mov    rdi,r14
    1372:	jmp    13bd <botlish_fn_9+0x1fd>
    1377:	mov    r8d,0x1
    137d:	mov    rcx,r15
    1380:	mov    r9,rbx
    1383:	mov    rsi,QWORD PTR [rsp+0x8]
    1388:	mov    rdi,r14
    138b:	call   1390 <botlish_fn_9+0x1d0>
			138c: R_X86_64_PLT32	rt_mutarray_copy-0x4
    1390:	test   rax,rax
    1393:	jne    13a1 <botlish_fn_9+0x1e1>
    1399:	mov    rdi,r14
    139c:	jmp    13bd <botlish_fn_9+0x1fd>
    13a1:	mov    rdx,r13
    13a4:	mov    rsi,QWORD PTR [rsp+0x8]
    13a9:	mov    rdi,r14
    13ac:	call   13b1 <botlish_fn_9+0x1f1>
			13ad: R_X86_64_PLT32	rt_mutarray_freeze-0x4
    13b1:	test   rax,rax
    13b4:	jne    13e8 <botlish_fn_9+0x228>
    13ba:	mov    rdi,r14
    13bd:	mov    rdi,r14
    13c0:	mov    QWORD PTR [rdi],r12
    13c3:	xor    rax,rax
    13c6:	mov    rbx,QWORD PTR [rsp+0x10]
    13cb:	mov    r12,QWORD PTR [rsp+0x18]
    13d0:	mov    r13,QWORD PTR [rsp+0x20]
    13d5:	mov    r14,QWORD PTR [rsp+0x28]
    13da:	mov    r15,QWORD PTR [rsp+0x30]
    13df:	add    rsp,0x40
    13e3:	mov    rsp,rbp
    13e6:	pop    rbp
    13e7:	ret
    13e8:	mov    rdi,r14
    13eb:	mov    QWORD PTR [rdi],r12
    13ee:	mov    rbx,QWORD PTR [rsp+0x10]
    13f3:	mov    r12,QWORD PTR [rsp+0x18]
    13f8:	mov    r13,QWORD PTR [rsp+0x20]
    13fd:	mov    r14,QWORD PTR [rsp+0x28]
    1402:	mov    r15,QWORD PTR [rsp+0x30]
    1407:	add    rsp,0x40
    140b:	mov    rsp,rbp
    140e:	pop    rbp
    140f:	ret
    1410:	mov    r14,rdi
    1413:	call   1418 <botlish_fn_9+0x258>
			1414: R_X86_64_PLT32	rt_stack_overflow-0x4
    1418:	xor    rax,rax
    141b:	mov    rbx,QWORD PTR [rsp+0x10]
    1420:	mov    r12,QWORD PTR [rsp+0x18]
    1425:	mov    r13,QWORD PTR [rsp+0x20]
    142a:	mov    r14,QWORD PTR [rsp+0x28]
    142f:	mov    r15,QWORD PTR [rsp+0x30]
    1434:	add    rsp,0x40
    1438:	mov    rsp,rbp
    143b:	pop    rbp
    143c:	ret

000000000000143d <botlish_entry_9: chunked_finish<list[list<never>, mutarray, int]>>:
    143d:	push   rbp
    143e:	mov    rbp,rsp
    1441:	mov    rsi,QWORD PTR [rdx]
    1444:	mov    r8,QWORD PTR [rdx+0x8]
    1448:	mov    rcx,QWORD PTR [rdx+0x10]
    144c:	mov    rdx,r8
    144f:	call   1454 <botlish_entry_9+0x17>
			1450: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    1454:	mov    rsp,rbp
    1457:	pop    rbp
    1458:	ret

0000000000001459 <botlish_fn_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    1459:	push   rbp
    145a:	mov    rbp,rsp
    145d:	sub    rsp,0x40
    1461:	mov    QWORD PTR [rsp+0x10],rbx
    1466:	mov    QWORD PTR [rsp+0x18],r12
    146b:	mov    QWORD PTR [rsp+0x20],r13
    1470:	mov    QWORD PTR [rsp+0x28],r14
    1475:	mov    QWORD PTR [rsp+0x30],r15
    147a:	mov    r12,QWORD PTR [rdi]
    147d:	mov    rax,QWORD PTR [rdi+0x8]
    1481:	lea    r8,[r12+0x38]
    1486:	cmp    r8,rax
    1489:	ja     16a9 <botlish_fn_10+0x250>
    148f:	lea    rax,[r12+0x38]
    1494:	mov    QWORD PTR [rdi],rax
    1497:	mov    r14,rdi
    149a:	mov    QWORD PTR [r12+0x20],0x0
    14a3:	mov    QWORD PTR [r12+0x28],0x0
    14ac:	mov    QWORD PTR [r12+0x30],0x0
    14b5:	mov    QWORD PTR [r12],rsi
    14b9:	mov    QWORD PTR [rsp],rsi
    14bd:	mov    QWORD PTR [r12+0x8],rdx
    14c2:	mov    r15,rdx
    14c5:	mov    QWORD PTR [r12+0x10],rcx
    14ca:	mov    rbx,rcx
    14cd:	mov    rsi,QWORD PTR [rsp]
    14d1:	mov    rdi,r14
    14d4:	call   14d9 <botlish_fn_10+0x80>
			14d5: R_X86_64_PLT32	rt_list_len-0x4
    14d9:	mov    QWORD PTR [r12+0x18],rax
    14de:	mov    r13,rax
    14e1:	mov    rdi,r14
    14e4:	call   14e9 <botlish_fn_10+0x90>
			14e5: R_X86_64_PLT32	botlish_fn_1-0x4 ; chunk_size<generic>
    14e9:	test   rax,rax
    14ec:	jne    14fa <botlish_fn_10+0xa1>
    14f2:	mov    rdi,r14
    14f5:	jmp    1656 <botlish_fn_10+0x1fd>
    14fa:	mov    QWORD PTR [r12+0x20],rax
    14ff:	mov    rcx,r13
    1502:	mov    rdx,rcx
    1505:	and    rdx,rax
    1508:	mov    rsi,rax
    150b:	test   rdx,0x1
    1512:	jne    1523 <botlish_fn_10+0xca>
    1518:	mov    rdx,rsi
    151b:	mov    rsi,rcx
    151e:	jmp    1558 <botlish_fn_10+0xff>
    1523:	mov    rax,rcx
    1526:	sar    rax,1
    1529:	mov    r13,rcx
    152c:	mov    rcx,rsi
    152f:	lea    rdx,[rcx-0x1]
    1533:	imul   rdx
    1536:	seto   cl
    1539:	or     rax,0x1
    153d:	test   cl,cl
    153f:	je     1550 <botlish_fn_10+0xf7>
    1545:	mov    rdx,rsi
    1548:	mov    rsi,r13
    154b:	jmp    1558 <botlish_fn_10+0xff>
    1550:	mov    rsi,rax
    1553:	jmp    1563 <botlish_fn_10+0x10a>
    1558:	mov    rdi,r14
    155b:	call   1560 <botlish_fn_10+0x107>
			155c: R_X86_64_PLT32	rt_int_mul-0x4
    1560:	mov    rsi,rax
    1563:	mov    QWORD PTR [r12+0x18],rsi
    1568:	mov    rax,rsi
    156b:	and    rax,rbx
    156e:	test   rax,0x1
    1574:	je     158f <botlish_fn_10+0x136>
    157a:	lea    rax,[rbx-0x1]
    157e:	mov    r13,rsi
    1581:	add    r13,rax
    1584:	seto   al
    1587:	test   al,al
    1589:	je     159d <botlish_fn_10+0x144>
    158f:	mov    rdx,rbx
    1592:	mov    rdi,r14
    1595:	call   159a <botlish_fn_10+0x141>
			1596: R_X86_64_PLT32	rt_int_add-0x4
    159a:	mov    r13,rax
    159d:	mov    QWORD PTR [r12+0x18],r13
    15a2:	mov    rsi,r13
    15a5:	mov    rdi,r14
    15a8:	call   15ad <botlish_fn_10+0x154>
			15a9: R_X86_64_PLT32	rt_mutarray_allocate-0x4
    15ad:	mov    rcx,rax
    15b0:	mov    QWORD PTR [rsp+0x8],rax
    15b5:	test   rax,rcx
    15b8:	jne    15c6 <botlish_fn_10+0x16d>
    15be:	mov    rdi,r14
    15c1:	jmp    1656 <botlish_fn_10+0x1fd>
    15c6:	mov    rax,QWORD PTR [rsp+0x8]
    15cb:	mov    QWORD PTR [r12+0x20],rax
    15d0:	mov    r8d,0x1
    15d6:	mov    QWORD PTR [r12+0x28],0x1
    15df:	mov    QWORD PTR [r12+0x30],0x1
    15e8:	mov    rsi,QWORD PTR [rsp]
    15ec:	mov    rcx,QWORD PTR [rsp+0x8]
    15f1:	mov    rdi,r14
    15f4:	mov    rdx,r8
    15f7:	call   15fc <botlish_fn_10+0x1a3>
			15f8: R_X86_64_PLT32	botlish_fn_8-0x4 ; chunked_copy_chunks<list<mutarray>, int, mutarray, int>
    15fc:	test   rax,rax
    15ff:	mov    rdx,rax
    1602:	jne    1610 <botlish_fn_10+0x1b7>
    1608:	mov    rdi,r14
    160b:	jmp    1656 <botlish_fn_10+0x1fd>
    1610:	mov    r8d,0x1
    1616:	mov    rcx,r15
    1619:	mov    r9,rbx
    161c:	mov    rsi,QWORD PTR [rsp+0x8]
    1621:	mov    rdi,r14
    1624:	call   1629 <botlish_fn_10+0x1d0>
			1625: R_X86_64_PLT32	rt_mutarray_copy-0x4
    1629:	test   rax,rax
    162c:	jne    163a <botlish_fn_10+0x1e1>
    1632:	mov    rdi,r14
    1635:	jmp    1656 <botlish_fn_10+0x1fd>
    163a:	mov    rdx,r13
    163d:	mov    rsi,QWORD PTR [rsp+0x8]
    1642:	mov    rdi,r14
    1645:	call   164a <botlish_fn_10+0x1f1>
			1646: R_X86_64_PLT32	rt_mutarray_freeze-0x4
    164a:	test   rax,rax
    164d:	jne    1681 <botlish_fn_10+0x228>
    1653:	mov    rdi,r14
    1656:	mov    rdi,r14
    1659:	mov    QWORD PTR [rdi],r12
    165c:	xor    rax,rax
    165f:	mov    rbx,QWORD PTR [rsp+0x10]
    1664:	mov    r12,QWORD PTR [rsp+0x18]
    1669:	mov    r13,QWORD PTR [rsp+0x20]
    166e:	mov    r14,QWORD PTR [rsp+0x28]
    1673:	mov    r15,QWORD PTR [rsp+0x30]
    1678:	add    rsp,0x40
    167c:	mov    rsp,rbp
    167f:	pop    rbp
    1680:	ret
    1681:	mov    rdi,r14
    1684:	mov    QWORD PTR [rdi],r12
    1687:	mov    rbx,QWORD PTR [rsp+0x10]
    168c:	mov    r12,QWORD PTR [rsp+0x18]
    1691:	mov    r13,QWORD PTR [rsp+0x20]
    1696:	mov    r14,QWORD PTR [rsp+0x28]
    169b:	mov    r15,QWORD PTR [rsp+0x30]
    16a0:	add    rsp,0x40
    16a4:	mov    rsp,rbp
    16a7:	pop    rbp
    16a8:	ret
    16a9:	mov    r14,rdi
    16ac:	call   16b1 <botlish_fn_10+0x258>
			16ad: R_X86_64_PLT32	rt_stack_overflow-0x4
    16b1:	xor    rax,rax
    16b4:	mov    rbx,QWORD PTR [rsp+0x10]
    16b9:	mov    r12,QWORD PTR [rsp+0x18]
    16be:	mov    r13,QWORD PTR [rsp+0x20]
    16c3:	mov    r14,QWORD PTR [rsp+0x28]
    16c8:	mov    r15,QWORD PTR [rsp+0x30]
    16cd:	add    rsp,0x40
    16d1:	mov    rsp,rbp
    16d4:	pop    rbp
    16d5:	ret

00000000000016d6 <botlish_entry_10: chunked_finish<list[list<mutarray>, mutarray, int]>>:
    16d6:	push   rbp
    16d7:	mov    rbp,rsp
    16da:	mov    rsi,QWORD PTR [rdx]
    16dd:	mov    r8,QWORD PTR [rdx+0x8]
    16e1:	mov    rcx,QWORD PTR [rdx+0x10]
    16e5:	mov    rdx,r8
    16e8:	call   16ed <botlish_entry_10+0x17>
			16e9: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    16ed:	mov    rsp,rbp
    16f0:	pop    rbp
    16f1:	ret
    16f2:	add    BYTE PTR [rax],al
    16f4:	add    BYTE PTR [rax],al
	...

00000000000016f8 <botlish_fn_11: peek<str, int>>:
    16f8:	push   rbp
    16f9:	mov    rbp,rsp
    16fc:	sub    rsp,0x50
    1700:	mov    QWORD PTR [rsp+0x20],rbx
    1705:	mov    QWORD PTR [rsp+0x28],r12
    170a:	mov    QWORD PTR [rsp+0x30],r13
    170f:	mov    QWORD PTR [rsp+0x38],r14
    1714:	mov    QWORD PTR [rsp+0x40],r15
    1719:	mov    rbx,QWORD PTR [rdi+0x20]
    171d:	mov    r14,QWORD PTR [rdi+0x28]
    1721:	lea    rax,[rsp]
    1725:	mov    QWORD PTR [rdi+0x20],rax
    1729:	mov    QWORD PTR [rdi+0x28],0x3
    1731:	mov    QWORD PTR [rsp],rsi
    1735:	mov    r15,rsi
    1738:	mov    QWORD PTR [rsp+0x8],rdx
    173d:	mov    r13,rdx
    1740:	mov    r12,rdi
    1743:	mov    rsi,r15
    1746:	call   174b <botlish_fn_11+0x53>
			1747: R_X86_64_PLT32	rt_str_len-0x4
    174b:	mov    rcx,r13
    174e:	and    rcx,rax
    1751:	mov    rdx,rax
    1754:	test   rcx,0x1
    175b:	jne    1781 <botlish_fn_11+0x89>
    1761:	mov    rsi,r13
    1764:	mov    rdi,r12
    1767:	call   176c <botlish_fn_11+0x74>
			1768: R_X86_64_PLT32	rt_int_cmp-0x4
    176c:	mov    ecx,0x2
    1771:	test   rax,rax
    1774:	cmovge rcx,QWORD PTR [rip+0x10c]        # 1888 <botlish_fn_11+0x190>
    177c:	jmp    1791 <botlish_fn_11+0x99>
    1781:	mov    ecx,0x2
    1786:	cmp    r13,rdx
    1789:	cmovge rcx,QWORD PTR [rip+0xf7]        # 1888 <botlish_fn_11+0x190>
    1791:	cmp    rcx,0x6
    1795:	je     184d <botlish_fn_11+0x155>
    179b:	mov    QWORD PTR [rsp+0x10],0x3
    17a4:	test   r13,0x1
    17ab:	je     17c3 <botlish_fn_11+0xcb>
    17b1:	mov    rcx,r13
    17b4:	add    rcx,0x2
    17b8:	seto   al
    17bb:	test   al,al
    17bd:	je     17d6 <botlish_fn_11+0xde>
    17c3:	mov    edx,0x3
    17c8:	mov    rsi,r13
    17cb:	mov    rdi,r12
    17ce:	call   17d3 <botlish_fn_11+0xdb>
			17cf: R_X86_64_PLT32	rt_int_add-0x4
    17d3:	mov    rcx,rax
    17d6:	mov    QWORD PTR [rsp+0x10],rcx
    17db:	mov    rdx,r13
    17de:	mov    rsi,r15
    17e1:	mov    rdi,r12
    17e4:	call   17e9 <botlish_fn_11+0xf1>
			17e5: R_X86_64_PLT32	rt_substr-0x4
    17e9:	test   rax,rax
    17ec:	jne    1821 <botlish_fn_11+0x129>
    17f2:	mov    QWORD PTR [r12+0x20],rbx
    17f7:	mov    QWORD PTR [r12+0x28],r14
    17fc:	xor    rax,rax
    17ff:	mov    rbx,QWORD PTR [rsp+0x20]
    1804:	mov    r12,QWORD PTR [rsp+0x28]
    1809:	mov    r13,QWORD PTR [rsp+0x30]
    180e:	mov    r14,QWORD PTR [rsp+0x38]
    1813:	mov    r15,QWORD PTR [rsp+0x40]
    1818:	add    rsp,0x50
    181c:	mov    rsp,rbp
    181f:	pop    rbp
    1820:	ret
    1821:	mov    QWORD PTR [r12+0x20],rbx
    1826:	mov    QWORD PTR [r12+0x28],r14
    182b:	mov    rbx,QWORD PTR [rsp+0x20]
    1830:	mov    r12,QWORD PTR [rsp+0x28]
    1835:	mov    r13,QWORD PTR [rsp+0x30]
    183a:	mov    r14,QWORD PTR [rsp+0x38]
    183f:	mov    r15,QWORD PTR [rsp+0x40]
    1844:	add    rsp,0x50
    1848:	mov    rsp,rbp
    184b:	pop    rbp
    184c:	ret
    184d:	mov    rax,QWORD PTR [r12+0x10]
    1852:	mov    rax,QWORD PTR [rax+0x10]
    1856:	mov    QWORD PTR [r12+0x20],rbx
    185b:	mov    QWORD PTR [r12+0x28],r14
    1860:	mov    rbx,QWORD PTR [rsp+0x20]
    1865:	mov    r12,QWORD PTR [rsp+0x28]
    186a:	mov    r13,QWORD PTR [rsp+0x30]
    186f:	mov    r14,QWORD PTR [rsp+0x38]
    1874:	mov    r15,QWORD PTR [rsp+0x40]
    1879:	add    rsp,0x50
    187d:	mov    rsp,rbp
    1880:	pop    rbp
    1881:	ret
    1882:	add    BYTE PTR [rax],al
    1884:	add    BYTE PTR [rax],al
    1886:	add    BYTE PTR [rax],al
    1888:	(bad)
    1889:	add    BYTE PTR [rax],al
    188b:	add    BYTE PTR [rax],al
    188d:	add    BYTE PTR [rax],al
	...

0000000000001890 <botlish_entry_11: peek<str, int>>:
    1890:	push   rbp
    1891:	mov    rbp,rsp
    1894:	mov    rsi,QWORD PTR [rdx]
    1897:	mov    rdx,QWORD PTR [rdx+0x8]
    189b:	call   18a0 <botlish_entry_11+0x10>
			189c: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    18a0:	mov    rsp,rbp
    18a3:	pop    rbp
    18a4:	ret
    18a5:	add    BYTE PTR [rax],al
	...

00000000000018a8 <botlish_fn_12: peek<str, int>>:
    18a8:	push   rbp
    18a9:	mov    rbp,rsp
    18ac:	sub    rsp,0x60
    18b0:	mov    QWORD PTR [rsp+0x30],rbx
    18b5:	mov    QWORD PTR [rsp+0x38],r12
    18ba:	mov    QWORD PTR [rsp+0x40],r13
    18bf:	mov    QWORD PTR [rsp+0x48],r14
    18c4:	mov    QWORD PTR [rsp+0x50],r15
    18c9:	mov    r15,rcx
    18cc:	mov    rbx,QWORD PTR [rdi+0x20]
    18d0:	mov    r14,QWORD PTR [rdi+0x28]
    18d4:	lea    rax,[rsp]
    18d8:	mov    QWORD PTR [rdi+0x20],rax
    18dc:	mov    QWORD PTR [rdi+0x28],0x3
    18e4:	mov    QWORD PTR [rsp],rsi
    18e8:	mov    QWORD PTR [rsp+0x18],rsi
    18ed:	mov    QWORD PTR [rsp+0x8],rdx
    18f2:	mov    r13,rdx
    18f5:	mov    r12,rdi
    18f8:	mov    rsi,QWORD PTR [rsp+0x18]
    18fd:	call   1902 <botlish_fn_12+0x5a>
			18fe: R_X86_64_PLT32	rt_str_len-0x4
    1902:	mov    rcx,r13
    1905:	and    rcx,rax
    1908:	mov    rdx,rax
    190b:	test   rcx,0x1
    1912:	jne    1938 <botlish_fn_12+0x90>
    1918:	mov    rsi,r13
    191b:	mov    rdi,r12
    191e:	call   1923 <botlish_fn_12+0x7b>
			191f: R_X86_64_PLT32	rt_int_cmp-0x4
    1923:	mov    ecx,0x2
    1928:	test   rax,rax
    192b:	cmovge rcx,QWORD PTR [rip+0x13d]        # 1a70 <botlish_fn_12+0x1c8>
    1933:	jmp    1948 <botlish_fn_12+0xa0>
    1938:	mov    ecx,0x2
    193d:	cmp    r13,rdx
    1940:	cmovge rcx,QWORD PTR [rip+0x128]        # 1a70 <botlish_fn_12+0x1c8>
    1948:	cmp    rcx,0x6
    194c:	je     1a26 <botlish_fn_12+0x17e>
    1952:	mov    QWORD PTR [rsp+0x10],0x3
    195b:	test   r13,0x1
    1962:	je     1984 <botlish_fn_12+0xdc>
    1968:	mov    rax,r13
    196b:	add    rax,0x2
    196f:	seto   cl
    1972:	test   cl,cl
    1974:	jne    1984 <botlish_fn_12+0xdc>
    197a:	mov    QWORD PTR [rsp+0x20],rax
    197f:	jmp    1999 <botlish_fn_12+0xf1>
    1984:	mov    edx,0x3
    1989:	mov    rsi,r13
    198c:	mov    rdi,r12
    198f:	call   1994 <botlish_fn_12+0xec>
			1990: R_X86_64_PLT32	rt_int_add-0x4
    1994:	mov    QWORD PTR [rsp+0x20],rax
    1999:	mov    rcx,QWORD PTR [rsp+0x20]
    199e:	mov    rdx,r13
    19a1:	mov    rsi,QWORD PTR [rsp+0x18]
    19a6:	mov    rdi,r12
    19a9:	call   19ae <botlish_fn_12+0x106>
			19aa: R_X86_64_PLT32	rt_str_region_check-0x4
    19ae:	test   rax,rax
    19b1:	jne    19e6 <botlish_fn_12+0x13e>
    19b7:	mov    QWORD PTR [r12+0x20],rbx
    19bc:	mov    QWORD PTR [r12+0x28],r14
    19c1:	xor    rax,rax
    19c4:	mov    rbx,QWORD PTR [rsp+0x30]
    19c9:	mov    r12,QWORD PTR [rsp+0x38]
    19ce:	mov    r13,QWORD PTR [rsp+0x40]
    19d3:	mov    r14,QWORD PTR [rsp+0x48]
    19d8:	mov    r15,QWORD PTR [rsp+0x50]
    19dd:	add    rsp,0x60
    19e1:	mov    rsp,rbp
    19e4:	pop    rbp
    19e5:	ret
    19e6:	mov    QWORD PTR [r12+0x20],rbx
    19eb:	mov    QWORD PTR [r12+0x28],r14
    19f0:	mov    rcx,r15
    19f3:	mov    QWORD PTR [rcx],r13
    19f6:	mov    rax,QWORD PTR [rsp+0x20]
    19fb:	mov    QWORD PTR [rcx+0x8],rax
    19ff:	mov    rax,QWORD PTR [rsp+0x18]
    1a04:	mov    rbx,QWORD PTR [rsp+0x30]
    1a09:	mov    r12,QWORD PTR [rsp+0x38]
    1a0e:	mov    r13,QWORD PTR [rsp+0x40]
    1a13:	mov    r14,QWORD PTR [rsp+0x48]
    1a18:	mov    r15,QWORD PTR [rsp+0x50]
    1a1d:	add    rsp,0x60
    1a21:	mov    rsp,rbp
    1a24:	pop    rbp
    1a25:	ret
    1a26:	mov    rcx,r15
    1a29:	mov    rax,QWORD PTR [r12+0x10]
    1a2e:	mov    rax,QWORD PTR [rax+0x10]
    1a32:	mov    QWORD PTR [r12+0x20],rbx
    1a37:	mov    QWORD PTR [r12+0x28],r14
    1a3c:	mov    QWORD PTR [rcx],0x1
    1a43:	mov    QWORD PTR [rcx+0x8],0x1
    1a4b:	mov    rbx,QWORD PTR [rsp+0x30]
    1a50:	mov    r12,QWORD PTR [rsp+0x38]
    1a55:	mov    r13,QWORD PTR [rsp+0x40]
    1a5a:	mov    r14,QWORD PTR [rsp+0x48]
    1a5f:	mov    r15,QWORD PTR [rsp+0x50]
    1a64:	add    rsp,0x60
    1a68:	mov    rsp,rbp
    1a6b:	pop    rbp
    1a6c:	ret
    1a6d:	add    BYTE PTR [rax],al
    1a6f:	add    BYTE PTR [rsi],al
    1a71:	add    BYTE PTR [rax],al
    1a73:	add    BYTE PTR [rax],al
    1a75:	add    BYTE PTR [rax],al
	...

0000000000001a78 <botlish_entry_12: peek<str, int>>:
    1a78:	push   rbp
    1a79:	mov    rbp,rsp
    1a7c:	ud2

0000000000001a7e <botlish_fn_13: scan_unquoted<str, int, int>>:
    1a7e:	push   rbp
    1a7f:	mov    rbp,rsp
    1a82:	sub    rsp,0x60
    1a86:	mov    QWORD PTR [rsp+0x30],rbx
    1a8b:	mov    QWORD PTR [rsp+0x38],r12
    1a90:	mov    QWORD PTR [rsp+0x40],r13
    1a95:	mov    QWORD PTR [rsp+0x48],r14
    1a9a:	mov    QWORD PTR [rsp+0x50],r15
    1a9f:	mov    r14,QWORD PTR [rdi]
    1aa2:	mov    rax,QWORD PTR [rdi+0x8]
    1aa6:	lea    r8,[r14+0x20]
    1aaa:	cmp    r8,rax
    1aad:	ja     1cbe <botlish_fn_13+0x240>
    1ab3:	lea    rax,[r14+0x20]
    1ab7:	mov    QWORD PTR [rdi],rax
    1aba:	mov    r15,rdi
    1abd:	mov    QWORD PTR [r14+0x18],0x0
    1ac5:	mov    QWORD PTR [r14],rsi
    1ac8:	mov    QWORD PTR [rsp+0x10],rsi
    1acd:	mov    QWORD PTR [r14+0x8],rdx
    1ad1:	mov    QWORD PTR [rsp+0x18],rdx
    1ad6:	mov    QWORD PTR [r14+0x10],rcx
    1ada:	lea    rbx,[rsp]
    1ade:	mov    QWORD PTR [rsp+0x20],rcx
    1ae3:	mov    rcx,rbx
    1ae6:	mov    rdx,QWORD PTR [rsp+0x20]
    1aeb:	mov    rsi,QWORD PTR [rsp+0x10]
    1af0:	mov    rdi,r15
    1af3:	call   1af8 <botlish_fn_13+0x7a>
			1af4: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1af8:	mov    rcx,rax
    1afb:	mov    QWORD PTR [rsp+0x28],rax
    1b00:	test   rax,rcx
    1b03:	jne    1b11 <botlish_fn_13+0x93>
    1b09:	mov    rdi,r15
    1b0c:	jmp    1c63 <botlish_fn_13+0x1e5>
    1b11:	mov    r12,QWORD PTR [rsp]
    1b15:	mov    r13,QWORD PTR [rsp+0x8]
    1b1a:	mov    rdi,r15
    1b1d:	mov    rcx,QWORD PTR [rdi+0x10]
    1b21:	mov    r8,QWORD PTR [rcx+0x10]
    1b25:	mov    rcx,r13
    1b28:	mov    rdx,r12
    1b2b:	mov    rsi,QWORD PTR [rsp+0x28]
    1b30:	call   1b35 <botlish_fn_13+0xb7>
			1b31: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b35:	cmp    rax,0x6
    1b39:	je     1b78 <botlish_fn_13+0xfa>
    1b3f:	mov    rdi,r15
    1b42:	mov    rax,QWORD PTR [rdi+0x10]
    1b46:	mov    r8,QWORD PTR [rax+0x18]
    1b4a:	mov    rcx,r13
    1b4d:	mov    rdx,r12
    1b50:	mov    rsi,QWORD PTR [rsp+0x28]
    1b55:	call   1b5a <botlish_fn_13+0xdc>
			1b56: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b5a:	cmp    rax,0x6
    1b5e:	je     1b6e <botlish_fn_13+0xf0>
    1b64:	mov    eax,0x2
    1b69:	jmp    1b7d <botlish_fn_13+0xff>
    1b6e:	mov    eax,0x6
    1b73:	jmp    1b7d <botlish_fn_13+0xff>
    1b78:	mov    eax,0x6
    1b7d:	cmp    rax,0x6
    1b81:	je     1bc0 <botlish_fn_13+0x142>
    1b87:	mov    rdi,r15
    1b8a:	mov    rcx,QWORD PTR [rdi+0x10]
    1b8e:	mov    r8,QWORD PTR [rcx+0x20]
    1b92:	mov    rcx,r13
    1b95:	mov    rdx,r12
    1b98:	mov    rsi,QWORD PTR [rsp+0x28]
    1b9d:	call   1ba2 <botlish_fn_13+0x124>
			1b9e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1ba2:	cmp    rax,0x6
    1ba6:	je     1bb6 <botlish_fn_13+0x138>
    1bac:	mov    eax,0x2
    1bb1:	jmp    1bc5 <botlish_fn_13+0x147>
    1bb6:	mov    eax,0x6
    1bbb:	jmp    1bc5 <botlish_fn_13+0x147>
    1bc0:	mov    eax,0x6
    1bc5:	cmp    rax,0x6
    1bc9:	je     1c40 <botlish_fn_13+0x1c2>
    1bcf:	mov    QWORD PTR [r14+0x18],0x3
    1bd7:	mov    rsi,QWORD PTR [rsp+0x20]
    1bdc:	test   rsi,0x1
    1be3:	je     1c0a <botlish_fn_13+0x18c>
    1be9:	mov    rsi,QWORD PTR [rsp+0x20]
    1bee:	mov    rax,rsi
    1bf1:	add    rax,0x2
    1bf5:	seto   cl
    1bf8:	test   cl,cl
    1bfa:	jne    1c0a <botlish_fn_13+0x18c>
    1c00:	mov    rsi,QWORD PTR [rsp+0x10]
    1c05:	jmp    1c21 <botlish_fn_13+0x1a3>
    1c0a:	mov    edx,0x3
    1c0f:	mov    rsi,QWORD PTR [rsp+0x20]
    1c14:	mov    rdi,r15
    1c17:	call   1c1c <botlish_fn_13+0x19e>
			1c18: R_X86_64_PLT32	rt_int_add-0x4
    1c1c:	mov    rsi,QWORD PTR [rsp+0x10]
    1c21:	mov    QWORD PTR [r14],rsi
    1c24:	mov    rdx,QWORD PTR [rsp+0x18]
    1c29:	mov    QWORD PTR [r14+0x8],rdx
    1c2d:	mov    QWORD PTR [r14+0x10],rax
    1c31:	mov    QWORD PTR [rsp+0x10],rsi
    1c36:	mov    QWORD PTR [rsp+0x20],rax
    1c3b:	jmp    1ae3 <botlish_fn_13+0x65>
    1c40:	mov    rdx,QWORD PTR [rsp+0x18]
    1c45:	mov    rsi,QWORD PTR [rsp+0x10]
    1c4a:	mov    rcx,QWORD PTR [rsp+0x20]
    1c4f:	mov    rdi,r15
    1c52:	call   1c57 <botlish_fn_13+0x1d9>
			1c53: R_X86_64_PLT32	rt_substr-0x4
    1c57:	test   rax,rax
    1c5a:	jne    1c91 <botlish_fn_13+0x213>
    1c60:	mov    rdi,r15
    1c63:	mov    rdi,r15
    1c66:	mov    QWORD PTR [rdi],r14
    1c69:	xor    rdx,rdx
    1c6c:	mov    rax,rdx
    1c6f:	mov    rbx,QWORD PTR [rsp+0x30]
    1c74:	mov    r12,QWORD PTR [rsp+0x38]
    1c79:	mov    r13,QWORD PTR [rsp+0x40]
    1c7e:	mov    r14,QWORD PTR [rsp+0x48]
    1c83:	mov    r15,QWORD PTR [rsp+0x50]
    1c88:	add    rsp,0x60
    1c8c:	mov    rsp,rbp
    1c8f:	pop    rbp
    1c90:	ret
    1c91:	mov    rdi,r15
    1c94:	mov    QWORD PTR [rdi],r14
    1c97:	mov    rdx,QWORD PTR [rsp+0x20]
    1c9c:	mov    rbx,QWORD PTR [rsp+0x30]
    1ca1:	mov    r12,QWORD PTR [rsp+0x38]
    1ca6:	mov    r13,QWORD PTR [rsp+0x40]
    1cab:	mov    r14,QWORD PTR [rsp+0x48]
    1cb0:	mov    r15,QWORD PTR [rsp+0x50]
    1cb5:	add    rsp,0x60
    1cb9:	mov    rsp,rbp
    1cbc:	pop    rbp
    1cbd:	ret
    1cbe:	mov    r15,rdi
    1cc1:	call   1cc6 <botlish_fn_13+0x248>
			1cc2: R_X86_64_PLT32	rt_stack_overflow-0x4
    1cc6:	xor    rdx,rdx
    1cc9:	mov    rax,rdx
    1ccc:	mov    rbx,QWORD PTR [rsp+0x30]
    1cd1:	mov    r12,QWORD PTR [rsp+0x38]
    1cd6:	mov    r13,QWORD PTR [rsp+0x40]
    1cdb:	mov    r14,QWORD PTR [rsp+0x48]
    1ce0:	mov    r15,QWORD PTR [rsp+0x50]
    1ce5:	add    rsp,0x60
    1ce9:	mov    rsp,rbp
    1cec:	pop    rbp
    1ced:	ret

0000000000001cee <botlish_entry_13: scan_unquoted<str, int, int>>:
    1cee:	push   rbp
    1cef:	mov    rbp,rsp
    1cf2:	ud2

0000000000001cf4 <botlish_fn_14: scan_quoted<str, int, str>>:
    1cf4:	push   rbp
    1cf5:	mov    rbp,rsp
    1cf8:	sub    rsp,0x50
    1cfc:	mov    QWORD PTR [rsp+0x20],rbx
    1d01:	mov    QWORD PTR [rsp+0x28],r12
    1d06:	mov    QWORD PTR [rsp+0x30],r13
    1d0b:	mov    QWORD PTR [rsp+0x38],r14
    1d10:	mov    QWORD PTR [rsp+0x40],r15
    1d15:	mov    r13,QWORD PTR [rdi]
    1d18:	mov    rax,QWORD PTR [rdi+0x8]
    1d1c:	lea    r8,[r13+0x28]
    1d20:	cmp    r8,rax
    1d23:	ja     1ff5 <botlish_fn_14+0x301>
    1d29:	lea    rax,[r13+0x28]
    1d2d:	mov    QWORD PTR [rdi],rax
    1d30:	mov    r14,rdi
    1d33:	mov    QWORD PTR [r13+0x18],0x0
    1d3b:	mov    QWORD PTR [r13+0x20],0x0
    1d43:	mov    QWORD PTR [r13+0x0],rsi
    1d47:	mov    QWORD PTR [r13+0x8],rdx
    1d4b:	mov    QWORD PTR [r13+0x10],rcx
    1d4f:	lea    rbx,[rsp]
    1d53:	mov    r12,rsi
    1d56:	mov    r15,rdx
    1d59:	mov    QWORD PTR [rsp+0x10],rcx
    1d5e:	mov    rdx,r15
    1d61:	mov    rsi,r12
    1d64:	mov    rdi,r14
    1d67:	call   1d6c <botlish_fn_14+0x78>
			1d68: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    1d6c:	test   rax,rax
    1d6f:	jne    1d7d <botlish_fn_14+0x89>
    1d75:	mov    rdi,r14
    1d78:	jmp    1fae <botlish_fn_14+0x2ba>
    1d7d:	mov    QWORD PTR [r13+0x18],rax
    1d81:	mov    rdi,r14
    1d84:	mov    QWORD PTR [rsp+0x18],rax
    1d89:	mov    rdx,QWORD PTR [rdi+0x10]
    1d8d:	mov    rsi,QWORD PTR [rdx+0x28]
    1d91:	mov    edx,0x1
    1d96:	mov    ecx,0x3
    1d9b:	mov    r8,QWORD PTR [rsp+0x18]
    1da0:	call   1da5 <botlish_fn_14+0xb1>
			1da1: R_X86_64_PLT32	rt_str_region_eq-0x4
    1da5:	cmp    rax,0x6
    1da9:	je     1e36 <botlish_fn_14+0x142>
    1daf:	mov    QWORD PTR [r13+0x20],0x3
    1db7:	mov    rsi,r15
    1dba:	test   rsi,0x1
    1dc1:	je     1de3 <botlish_fn_14+0xef>
    1dc7:	mov    r8,rsi
    1dca:	add    r8,0x2
    1dce:	seto   r10b
    1dd2:	test   r10b,r10b
    1dd5:	jne    1de3 <botlish_fn_14+0xef>
    1ddb:	mov    rsi,r8
    1dde:	jmp    1df3 <botlish_fn_14+0xff>
    1de3:	mov    edx,0x3
    1de8:	mov    rdi,r14
    1deb:	call   1df0 <botlish_fn_14+0xfc>
			1dec: R_X86_64_PLT32	rt_int_add-0x4
    1df0:	mov    rsi,rax
    1df3:	mov    QWORD PTR [r13+0x8],rsi
    1df7:	mov    r15,rsi
    1dfa:	mov    rsi,QWORD PTR [rsp+0x10]
    1dff:	mov    rdx,QWORD PTR [rsp+0x18]
    1e04:	mov    rdi,r14
    1e07:	call   1e0c <botlish_fn_14+0x118>
			1e08: R_X86_64_PLT32	rt_str_cat-0x4
    1e0c:	test   rax,rax
    1e0f:	jne    1e1d <botlish_fn_14+0x129>
    1e15:	mov    rdi,r14
    1e18:	jmp    1fae <botlish_fn_14+0x2ba>
    1e1d:	mov    QWORD PTR [r13+0x0],r12
    1e21:	mov    rsi,r15
    1e24:	mov    QWORD PTR [r13+0x8],rsi
    1e28:	mov    QWORD PTR [r13+0x10],rax
    1e2c:	mov    QWORD PTR [rsp+0x10],rax
    1e31:	jmp    1d5e <botlish_fn_14+0x6a>
    1e36:	mov    QWORD PTR [r13+0x18],0x3
    1e3e:	mov    rsi,r15
    1e41:	test   rsi,0x1
    1e48:	je     1e63 <botlish_fn_14+0x16f>
    1e4e:	mov    rsi,r15
    1e51:	mov    rdx,rsi
    1e54:	add    rdx,0x2
    1e58:	seto   al
    1e5b:	test   al,al
    1e5d:	je     1e76 <botlish_fn_14+0x182>
    1e63:	mov    edx,0x3
    1e68:	mov    rsi,r15
    1e6b:	mov    rdi,r14
    1e6e:	call   1e73 <botlish_fn_14+0x17f>
			1e6f: R_X86_64_PLT32	rt_int_add-0x4
    1e73:	mov    rdx,rax
    1e76:	mov    QWORD PTR [r13+0x18],rdx
    1e7a:	mov    rcx,rbx
    1e7d:	mov    rsi,r12
    1e80:	mov    rdi,r14
    1e83:	call   1e88 <botlish_fn_14+0x194>
			1e84: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1e88:	test   rax,rax
    1e8b:	mov    rsi,rax
    1e8e:	jne    1e9c <botlish_fn_14+0x1a8>
    1e94:	mov    rdi,r14
    1e97:	jmp    1fae <botlish_fn_14+0x2ba>
    1e9c:	mov    rdx,QWORD PTR [rsp]
    1ea0:	mov    rcx,QWORD PTR [rsp+0x8]
    1ea5:	mov    rdi,r14
    1ea8:	mov    rax,QWORD PTR [rdi+0x10]
    1eac:	mov    r8,QWORD PTR [rax+0x28]
    1eb0:	call   1eb5 <botlish_fn_14+0x1c1>
			1eb1: R_X86_64_PLT32	rt_str_region_eq-0x4
    1eb5:	cmp    rax,0x6
    1eb9:	je     1f37 <botlish_fn_14+0x243>
    1ebf:	mov    QWORD PTR [r13+0x0],0x3
    1ec7:	mov    rsi,r15
    1eca:	test   rsi,0x1
    1ed1:	je     1ef4 <botlish_fn_14+0x200>
    1ed7:	mov    rsi,r15
    1eda:	mov    rdx,rsi
    1edd:	add    rdx,0x2
    1ee1:	seto   al
    1ee4:	test   al,al
    1ee6:	jne    1ef4 <botlish_fn_14+0x200>
    1eec:	mov    rdi,r14
    1eef:	jmp    1f0a <botlish_fn_14+0x216>
    1ef4:	mov    edx,0x3
    1ef9:	mov    rsi,r15
    1efc:	mov    rdi,r14
    1eff:	call   1f04 <botlish_fn_14+0x210>
			1f00: R_X86_64_PLT32	rt_int_add-0x4
    1f04:	mov    rdx,rax
    1f07:	mov    rdi,r14
    1f0a:	mov    rdi,r14
    1f0d:	mov    QWORD PTR [rdi],r13
    1f10:	mov    rax,QWORD PTR [rsp+0x10]
    1f15:	mov    rbx,QWORD PTR [rsp+0x20]
    1f1a:	mov    r12,QWORD PTR [rsp+0x28]
    1f1f:	mov    r13,QWORD PTR [rsp+0x30]
    1f24:	mov    r14,QWORD PTR [rsp+0x38]
    1f29:	mov    r15,QWORD PTR [rsp+0x40]
    1f2e:	add    rsp,0x50
    1f32:	mov    rsp,rbp
    1f35:	pop    rbp
    1f36:	ret
    1f37:	mov    QWORD PTR [r13+0x18],0x5
    1f3f:	mov    rsi,r15
    1f42:	test   rsi,0x1
    1f49:	je     1f6f <botlish_fn_14+0x27b>
    1f4f:	mov    rsi,r15
    1f52:	mov    rax,rsi
    1f55:	add    rax,0x4
    1f59:	seto   cl
    1f5c:	test   cl,cl
    1f5e:	jne    1f6f <botlish_fn_14+0x27b>
    1f64:	mov    rsi,rax
    1f67:	mov    r15,rax
    1f6a:	jmp    1f85 <botlish_fn_14+0x291>
    1f6f:	mov    edx,0x5
    1f74:	mov    rsi,r15
    1f77:	mov    rdi,r14
    1f7a:	call   1f7f <botlish_fn_14+0x28b>
			1f7b: R_X86_64_PLT32	rt_int_add-0x4
    1f7f:	mov    rsi,rax
    1f82:	mov    r15,rax
    1f85:	mov    QWORD PTR [r13+0x8],rsi
    1f89:	mov    rdi,r14
    1f8c:	mov    rax,QWORD PTR [rdi+0x10]
    1f90:	mov    rdx,QWORD PTR [rax+0x28]
    1f94:	mov    QWORD PTR [r13+0x18],rdx
    1f98:	mov    rsi,QWORD PTR [rsp+0x10]
    1f9d:	call   1fa2 <botlish_fn_14+0x2ae>
			1f9e: R_X86_64_PLT32	rt_str_cat-0x4
    1fa2:	test   rax,rax
    1fa5:	jne    1fdc <botlish_fn_14+0x2e8>
    1fab:	mov    rdi,r14
    1fae:	mov    rdi,r14
    1fb1:	mov    QWORD PTR [rdi],r13
    1fb4:	xor    rdx,rdx
    1fb7:	mov    rax,rdx
    1fba:	mov    rbx,QWORD PTR [rsp+0x20]
    1fbf:	mov    r12,QWORD PTR [rsp+0x28]
    1fc4:	mov    r13,QWORD PTR [rsp+0x30]
    1fc9:	mov    r14,QWORD PTR [rsp+0x38]
    1fce:	mov    r15,QWORD PTR [rsp+0x40]
    1fd3:	add    rsp,0x50
    1fd7:	mov    rsp,rbp
    1fda:	pop    rbp
    1fdb:	ret
    1fdc:	mov    QWORD PTR [r13+0x0],r12
    1fe0:	mov    rsi,r15
    1fe3:	mov    QWORD PTR [r13+0x8],rsi
    1fe7:	mov    QWORD PTR [r13+0x10],rax
    1feb:	mov    QWORD PTR [rsp+0x10],rax
    1ff0:	jmp    1d5e <botlish_fn_14+0x6a>
    1ff5:	mov    r14,rdi
    1ff8:	call   1ffd <botlish_fn_14+0x309>
			1ff9: R_X86_64_PLT32	rt_stack_overflow-0x4
    1ffd:	xor    rdx,rdx
    2000:	mov    rax,rdx
    2003:	mov    rbx,QWORD PTR [rsp+0x20]
    2008:	mov    r12,QWORD PTR [rsp+0x28]
    200d:	mov    r13,QWORD PTR [rsp+0x30]
    2012:	mov    r14,QWORD PTR [rsp+0x38]
    2017:	mov    r15,QWORD PTR [rsp+0x40]
    201c:	add    rsp,0x50
    2020:	mov    rsp,rbp
    2023:	pop    rbp
    2024:	ret

0000000000002025 <botlish_entry_14: scan_quoted<str, int, str>>:
    2025:	push   rbp
    2026:	mov    rbp,rsp
    2029:	ud2

000000000000202b <botlish_fn_15: scan_field<str, int>>:
    202b:	push   rbp
    202c:	mov    rbp,rsp
    202f:	sub    rsp,0x30
    2033:	mov    QWORD PTR [rsp+0x10],rbx
    2038:	mov    QWORD PTR [rsp+0x18],r12
    203d:	mov    QWORD PTR [rsp+0x20],r13
    2042:	mov    QWORD PTR [rsp+0x28],r14
    2047:	mov    rbx,QWORD PTR [rdi]
    204a:	mov    rax,QWORD PTR [rdi+0x8]
    204e:	lea    rcx,[rbx+0x18]
    2052:	cmp    rcx,rax
    2055:	ja     21b8 <botlish_fn_15+0x18d>
    205b:	lea    rax,[rbx+0x18]
    205f:	mov    QWORD PTR [rdi],rax
    2062:	mov    r12,rdi
    2065:	mov    QWORD PTR [rbx+0x10],0x0
    206d:	mov    QWORD PTR [rbx],rsi
    2070:	mov    r13,rsi
    2073:	mov    QWORD PTR [rbx+0x8],rdx
    2077:	mov    r14,rdx
    207a:	lea    rcx,[rsp]
    207e:	mov    rdx,r14
    2081:	mov    rsi,r13
    2084:	mov    rdi,r12
    2087:	call   208c <botlish_fn_15+0x61>
			2088: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    208c:	test   rax,rax
    208f:	mov    rsi,rax
    2092:	jne    20a0 <botlish_fn_15+0x75>
    2098:	mov    rdi,r12
    209b:	jmp    216c <botlish_fn_15+0x141>
    20a0:	mov    rdx,QWORD PTR [rsp]
    20a4:	mov    rcx,QWORD PTR [rsp+0x8]
    20a9:	mov    rdi,r12
    20ac:	mov    rax,QWORD PTR [rdi+0x10]
    20b0:	mov    r8,QWORD PTR [rax+0x28]
    20b4:	call   20b9 <botlish_fn_15+0x8e>
			20b5: R_X86_64_PLT32	rt_str_region_eq-0x4
    20b9:	cmp    rax,0x6
    20bd:	je     2108 <botlish_fn_15+0xdd>
    20c3:	mov    rcx,r14
    20c6:	mov    rsi,r13
    20c9:	mov    rdi,r12
    20cc:	mov    rdx,rcx
    20cf:	call   20d4 <botlish_fn_15+0xa9>
			20d0: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    20d4:	test   rax,rax
    20d7:	jne    20e5 <botlish_fn_15+0xba>
    20dd:	mov    rdi,r12
    20e0:	jmp    216c <botlish_fn_15+0x141>
    20e5:	mov    rdi,r12
    20e8:	mov    QWORD PTR [rdi],rbx
    20eb:	mov    rbx,QWORD PTR [rsp+0x10]
    20f0:	mov    r12,QWORD PTR [rsp+0x18]
    20f5:	mov    r13,QWORD PTR [rsp+0x20]
    20fa:	mov    r14,QWORD PTR [rsp+0x28]
    20ff:	add    rsp,0x30
    2103:	mov    rsp,rbp
    2106:	pop    rbp
    2107:	ret
    2108:	mov    QWORD PTR [rbx+0x10],0x3
    2110:	mov    rdx,r14
    2113:	test   rdx,0x1
    211a:	je     2132 <botlish_fn_15+0x107>
    2120:	mov    rdx,r14
    2123:	add    rdx,0x2
    2127:	seto   al
    212a:	test   al,al
    212c:	je     2145 <botlish_fn_15+0x11a>
    2132:	mov    edx,0x3
    2137:	mov    rsi,r14
    213a:	mov    rdi,r12
    213d:	call   2142 <botlish_fn_15+0x117>
			213e: R_X86_64_PLT32	rt_int_add-0x4
    2142:	mov    rdx,rax
    2145:	mov    QWORD PTR [rbx+0x8],rdx
    2149:	mov    rdi,r12
    214c:	mov    rax,QWORD PTR [rdi+0x10]
    2150:	mov    rcx,QWORD PTR [rax+0x10]
    2154:	mov    QWORD PTR [rbx+0x10],rcx
    2158:	mov    rsi,r13
    215b:	call   2160 <botlish_fn_15+0x135>
			215c: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    2160:	test   rax,rax
    2163:	jne    2195 <botlish_fn_15+0x16a>
    2169:	mov    rdi,r12
    216c:	mov    rdi,r12
    216f:	mov    QWORD PTR [rdi],rbx
    2172:	xor    rdx,rdx
    2175:	mov    rax,rdx
    2178:	mov    rbx,QWORD PTR [rsp+0x10]
    217d:	mov    r12,QWORD PTR [rsp+0x18]
    2182:	mov    r13,QWORD PTR [rsp+0x20]
    2187:	mov    r14,QWORD PTR [rsp+0x28]
    218c:	add    rsp,0x30
    2190:	mov    rsp,rbp
    2193:	pop    rbp
    2194:	ret
    2195:	mov    rdi,r12
    2198:	mov    QWORD PTR [rdi],rbx
    219b:	mov    rbx,QWORD PTR [rsp+0x10]
    21a0:	mov    r12,QWORD PTR [rsp+0x18]
    21a5:	mov    r13,QWORD PTR [rsp+0x20]
    21aa:	mov    r14,QWORD PTR [rsp+0x28]
    21af:	add    rsp,0x30
    21b3:	mov    rsp,rbp
    21b6:	pop    rbp
    21b7:	ret
    21b8:	mov    r12,rdi
    21bb:	call   21c0 <botlish_fn_15+0x195>
			21bc: R_X86_64_PLT32	rt_stack_overflow-0x4
    21c0:	xor    rdx,rdx
    21c3:	mov    rax,rdx
    21c6:	mov    rbx,QWORD PTR [rsp+0x10]
    21cb:	mov    r12,QWORD PTR [rsp+0x18]
    21d0:	mov    r13,QWORD PTR [rsp+0x20]
    21d5:	mov    r14,QWORD PTR [rsp+0x28]
    21da:	add    rsp,0x30
    21de:	mov    rsp,rbp
    21e1:	pop    rbp
    21e2:	ret

00000000000021e3 <botlish_entry_15: scan_field<str, int>>:
    21e3:	push   rbp
    21e4:	mov    rbp,rsp
    21e7:	ud2

00000000000021e9 <botlish_fn_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    21e9:	push   rbp
    21ea:	mov    rbp,rsp
    21ed:	sub    rsp,0x80
    21f4:	mov    QWORD PTR [rsp+0x50],rbx
    21f9:	mov    QWORD PTR [rsp+0x58],r12
    21fe:	mov    QWORD PTR [rsp+0x60],r13
    2203:	mov    QWORD PTR [rsp+0x68],r14
    2208:	mov    QWORD PTR [rsp+0x70],r15
    220d:	mov    rbx,QWORD PTR [rdi]
    2210:	mov    rax,QWORD PTR [rdi+0x8]
    2214:	lea    r10,[rbx+0x30]
    2218:	cmp    r10,rax
    221b:	ja     2517 <botlish_fn_16+0x32e>
    2221:	lea    rax,[rbx+0x30]
    2225:	mov    QWORD PTR [rdi],rax
    2228:	mov    r14,rdi
    222b:	mov    QWORD PTR [rbx+0x28],0x0
    2233:	mov    QWORD PTR [rbx],rsi
    2236:	mov    QWORD PTR [rsp+0x20],rsi
    223b:	mov    QWORD PTR [rbx+0x8],rdx
    223f:	mov    QWORD PTR [rbx+0x10],rcx
    2243:	mov    QWORD PTR [rsp+0x28],rcx
    2248:	mov    QWORD PTR [rbx+0x18],r8
    224c:	mov    r13,r8
    224f:	mov    QWORD PTR [rbx+0x20],r9
    2253:	mov    r12,r9
    2256:	mov    rsi,QWORD PTR [rsp+0x20]
    225b:	mov    rdi,r14
    225e:	call   2263 <botlish_fn_16+0x7a>
			225f: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    2263:	test   rax,rax
    2266:	jne    2274 <botlish_fn_16+0x8b>
    226c:	mov    rdi,r14
    226f:	jmp    24bb <botlish_fn_16+0x2d2>
    2274:	mov    QWORD PTR [rbx+0x8],rax
    2278:	mov    r8,rax
    227b:	mov    QWORD PTR [rbx+0x28],rdx
    227f:	mov    r15,rdx
    2282:	lea    r9,[rsp]
    2286:	mov    rcx,r12
    2289:	mov    rdx,r13
    228c:	mov    rsi,QWORD PTR [rsp+0x28]
    2291:	mov    rdi,r14
    2294:	call   2299 <botlish_fn_16+0xb0>
			2295: R_X86_64_PLT32	botlish_fn_3-0x4 ; chunked_append<list[list<never>, mutarray, int], str>
    2299:	test   rax,rax
    229c:	jne    22aa <botlish_fn_16+0xc1>
    22a2:	mov    rdi,r14
    22a5:	jmp    24bb <botlish_fn_16+0x2d2>
    22aa:	mov    QWORD PTR [rbx+0x8],rax
    22ae:	mov    QWORD PTR [rsp+0x40],rax
    22b3:	mov    rdx,QWORD PTR [rsp]
    22b7:	mov    QWORD PTR [rbx+0x10],rdx
    22bb:	mov    QWORD PTR [rsp+0x38],rdx
    22c0:	mov    rcx,QWORD PTR [rsp+0x8]
    22c5:	mov    QWORD PTR [rbx+0x18],rcx
    22c9:	mov    QWORD PTR [rsp+0x30],rcx
    22ce:	lea    rcx,[rsp+0x10]
    22d3:	mov    rdx,r15
    22d6:	mov    rsi,QWORD PTR [rsp+0x20]
    22db:	mov    rdi,r14
    22de:	call   22e3 <botlish_fn_16+0xfa>
			22df: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    22e3:	test   rax,rax
    22e6:	mov    QWORD PTR [rsp+0x28],rax
    22eb:	jne    22f9 <botlish_fn_16+0x110>
    22f1:	mov    rdi,r14
    22f4:	jmp    24bb <botlish_fn_16+0x2d2>
    22f9:	mov    r13,QWORD PTR [rsp+0x10]
    22fe:	mov    r12,QWORD PTR [rsp+0x18]
    2303:	mov    rdi,r14
    2306:	mov    rsi,QWORD PTR [rdi+0x10]
    230a:	mov    r8,QWORD PTR [rsi+0x18]
    230e:	mov    rcx,r12
    2311:	mov    rdx,r13
    2314:	mov    rsi,QWORD PTR [rsp+0x28]
    2319:	call   231e <botlish_fn_16+0x135>
			231a: R_X86_64_PLT32	rt_str_region_eq-0x4
    231e:	cmp    rax,0x6
    2322:	je     2447 <botlish_fn_16+0x25e>
    2328:	mov    rdi,r14
    232b:	mov    r8,QWORD PTR [rdi+0x10]
    232f:	mov    r8,QWORD PTR [r8+0x20]
    2333:	mov    rcx,r12
    2336:	mov    rdx,r13
    2339:	mov    rsi,QWORD PTR [rsp+0x28]
    233e:	call   2343 <botlish_fn_16+0x15a>
			233f: R_X86_64_PLT32	rt_str_region_eq-0x4
    2343:	cmp    rax,0x6
    2347:	je     23a3 <botlish_fn_16+0x1ba>
    234d:	mov    rcx,QWORD PTR [rsp+0x30]
    2352:	mov    rdx,QWORD PTR [rsp+0x38]
    2357:	mov    rsi,QWORD PTR [rsp+0x40]
    235c:	mov    rdi,r14
    235f:	call   2364 <botlish_fn_16+0x17b>
			2360: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2364:	test   rax,rax
    2367:	jne    2375 <botlish_fn_16+0x18c>
    236d:	mov    rdi,r14
    2370:	jmp    24bb <botlish_fn_16+0x2d2>
    2375:	mov    rdi,r14
    2378:	mov    QWORD PTR [rdi],rbx
    237b:	mov    rdx,r15
    237e:	mov    rbx,QWORD PTR [rsp+0x50]
    2383:	mov    r12,QWORD PTR [rsp+0x58]
    2388:	mov    r13,QWORD PTR [rsp+0x60]
    238d:	mov    r14,QWORD PTR [rsp+0x68]
    2392:	mov    r15,QWORD PTR [rsp+0x70]
    2397:	add    rsp,0x80
    239e:	mov    rsp,rbp
    23a1:	pop    rbp
    23a2:	ret
    23a3:	mov    rcx,QWORD PTR [rsp+0x30]
    23a8:	mov    rdx,QWORD PTR [rsp+0x38]
    23ad:	mov    rsi,QWORD PTR [rsp+0x40]
    23b2:	mov    rdi,r14
    23b5:	call   23ba <botlish_fn_16+0x1d1>
			23b6: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    23ba:	test   rax,rax
    23bd:	jne    23cb <botlish_fn_16+0x1e2>
    23c3:	mov    rdi,r14
    23c6:	jmp    24bb <botlish_fn_16+0x2d2>
    23cb:	mov    QWORD PTR [rbx],rax
    23ce:	mov    r12,rax
    23d1:	mov    QWORD PTR [rbx+0x8],0x3
    23d9:	mov    rdx,r15
    23dc:	test   rdx,0x1
    23e3:	je     2403 <botlish_fn_16+0x21a>
    23e9:	mov    rdx,r15
    23ec:	add    rdx,0x2
    23f0:	seto   al
    23f3:	test   al,al
    23f5:	jne    2403 <botlish_fn_16+0x21a>
    23fb:	mov    rdi,r14
    23fe:	jmp    2419 <botlish_fn_16+0x230>
    2403:	mov    edx,0x3
    2408:	mov    rsi,r15
    240b:	mov    rdi,r14
    240e:	call   2413 <botlish_fn_16+0x22a>
			240f: R_X86_64_PLT32	rt_int_add-0x4
    2413:	mov    rdx,rax
    2416:	mov    rdi,r14
    2419:	mov    rdi,r14
    241c:	mov    QWORD PTR [rdi],rbx
    241f:	mov    rax,r12
    2422:	mov    rbx,QWORD PTR [rsp+0x50]
    2427:	mov    r12,QWORD PTR [rsp+0x58]
    242c:	mov    r13,QWORD PTR [rsp+0x60]
    2431:	mov    r14,QWORD PTR [rsp+0x68]
    2436:	mov    r15,QWORD PTR [rsp+0x70]
    243b:	add    rsp,0x80
    2442:	mov    rsp,rbp
    2445:	pop    rbp
    2446:	ret
    2447:	mov    rsi,r15
    244a:	mov    edx,0x3
    244f:	mov    rcx,rdx
    2452:	mov    QWORD PTR [rbx+0x20],0x3
    245a:	test   rsi,0x1
    2461:	jne    246f <botlish_fn_16+0x286>
    2467:	mov    rdx,rcx
    246a:	jmp    2484 <botlish_fn_16+0x29b>
    246f:	mov    rdx,rsi
    2472:	add    rdx,0x2
    2476:	seto   al
    2479:	test   al,al
    247b:	je     248f <botlish_fn_16+0x2a6>
    2481:	mov    rdx,rcx
    2484:	mov    rdi,r14
    2487:	call   248c <botlish_fn_16+0x2a3>
			2488: R_X86_64_PLT32	rt_int_add-0x4
    248c:	mov    rdx,rax
    248f:	mov    QWORD PTR [rbx+0x20],rdx
    2493:	mov    rcx,QWORD PTR [rsp+0x40]
    2498:	mov    rsi,QWORD PTR [rsp+0x20]
    249d:	mov    r8,QWORD PTR [rsp+0x38]
    24a2:	mov    r9,QWORD PTR [rsp+0x30]
    24a7:	mov    rdi,r14
    24aa:	call   24af <botlish_fn_16+0x2c6>
			24ab: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int, list[list<mutarray>, mutarray, int]>
    24af:	test   rax,rax
    24b2:	jne    24ec <botlish_fn_16+0x303>
    24b8:	mov    rdi,r14
    24bb:	mov    rdi,r14
    24be:	mov    QWORD PTR [rdi],rbx
    24c1:	xor    rdx,rdx
    24c4:	mov    rax,rdx
    24c7:	mov    rbx,QWORD PTR [rsp+0x50]
    24cc:	mov    r12,QWORD PTR [rsp+0x58]
    24d1:	mov    r13,QWORD PTR [rsp+0x60]
    24d6:	mov    r14,QWORD PTR [rsp+0x68]
    24db:	mov    r15,QWORD PTR [rsp+0x70]
    24e0:	add    rsp,0x80
    24e7:	mov    rsp,rbp
    24ea:	pop    rbp
    24eb:	ret
    24ec:	mov    rdi,r14
    24ef:	mov    QWORD PTR [rdi],rbx
    24f2:	mov    rbx,QWORD PTR [rsp+0x50]
    24f7:	mov    r12,QWORD PTR [rsp+0x58]
    24fc:	mov    r13,QWORD PTR [rsp+0x60]
    2501:	mov    r14,QWORD PTR [rsp+0x68]
    2506:	mov    r15,QWORD PTR [rsp+0x70]
    250b:	add    rsp,0x80
    2512:	mov    rsp,rbp
    2515:	pop    rbp
    2516:	ret
    2517:	mov    r14,rdi
    251a:	call   251f <botlish_fn_16+0x336>
			251b: R_X86_64_PLT32	rt_stack_overflow-0x4
    251f:	xor    rdx,rdx
    2522:	mov    rax,rdx
    2525:	mov    rbx,QWORD PTR [rsp+0x50]
    252a:	mov    r12,QWORD PTR [rsp+0x58]
    252f:	mov    r13,QWORD PTR [rsp+0x60]
    2534:	mov    r14,QWORD PTR [rsp+0x68]
    2539:	mov    r15,QWORD PTR [rsp+0x70]
    253e:	add    rsp,0x80
    2545:	mov    rsp,rbp
    2548:	pop    rbp
    2549:	ret

000000000000254a <botlish_entry_16: scan_record<str, int, list[list<never>, mutarray, int]>>:
    254a:	push   rbp
    254b:	mov    rbp,rsp
    254e:	ud2

0000000000002550 <botlish_fn_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    2550:	push   rbp
    2551:	mov    rbp,rsp
    2554:	sub    rsp,0x90
    255b:	mov    QWORD PTR [rsp+0x60],rbx
    2560:	mov    QWORD PTR [rsp+0x68],r12
    2565:	mov    QWORD PTR [rsp+0x70],r13
    256a:	mov    QWORD PTR [rsp+0x78],r14
    256f:	mov    QWORD PTR [rsp+0x80],r15
    2577:	mov    r14,QWORD PTR [rdi]
    257a:	mov    rax,QWORD PTR [rdi+0x8]
    257e:	lea    r10,[r14+0x30]
    2582:	cmp    r10,rax
    2585:	ja     28a3 <botlish_fn_17+0x353>
    258b:	lea    rax,[r14+0x30]
    258f:	mov    QWORD PTR [rdi],rax
    2592:	mov    QWORD PTR [rsp+0x20],rdi
    2597:	mov    QWORD PTR [r14+0x28],0x0
    259f:	mov    QWORD PTR [r14],rsi
    25a2:	mov    QWORD PTR [r14+0x8],rdx
    25a6:	mov    QWORD PTR [r14+0x10],rcx
    25aa:	mov    QWORD PTR [r14+0x18],r8
    25ae:	mov    QWORD PTR [r14+0x20],r9
    25b2:	lea    r12,[rsp]
    25b6:	mov    QWORD PTR [rsp+0x50],r12
    25bb:	lea    r12,[rsp+0x10]
    25c0:	mov    rbx,rcx
    25c3:	mov    r13,rsi
    25c6:	mov    QWORD PTR [rsp+0x28],r8
    25cb:	mov    QWORD PTR [rsp+0x30],r9
    25d0:	mov    rsi,r13
    25d3:	mov    rdi,QWORD PTR [rsp+0x20]
    25d8:	call   25dd <botlish_fn_17+0x8d>
			25d9: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    25dd:	mov    QWORD PTR [rsp+0x48],rdx
    25e2:	test   rax,rax
    25e5:	jne    25f5 <botlish_fn_17+0xa5>
    25eb:	mov    rdi,QWORD PTR [rsp+0x20]
    25f0:	jmp    276a <botlish_fn_17+0x21a>
    25f5:	mov    QWORD PTR [r14+0x8],rax
    25f9:	mov    rdx,QWORD PTR [rsp+0x48]
    25fe:	mov    r8,rax
    2601:	mov    QWORD PTR [r14+0x28],rdx
    2605:	mov    rcx,QWORD PTR [rsp+0x30]
    260a:	mov    rdx,QWORD PTR [rsp+0x28]
    260f:	mov    rsi,rbx
    2612:	mov    rdi,QWORD PTR [rsp+0x20]
    2617:	mov    r9,QWORD PTR [rsp+0x50]
    261c:	call   2621 <botlish_fn_17+0xd1>
			261d: R_X86_64_PLT32	botlish_fn_4-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], str>
    2621:	test   rax,rax
    2624:	jne    2634 <botlish_fn_17+0xe4>
    262a:	mov    rdi,QWORD PTR [rsp+0x20]
    262f:	jmp    276a <botlish_fn_17+0x21a>
    2634:	mov    QWORD PTR [r14+0x8],rax
    2638:	mov    QWORD PTR [rsp+0x40],rax
    263d:	mov    rdx,QWORD PTR [rsp]
    2641:	mov    QWORD PTR [rsp+0x28],rdx
    2646:	mov    QWORD PTR [r14+0x10],rdx
    264a:	mov    rcx,QWORD PTR [rsp+0x8]
    264f:	mov    QWORD PTR [r14+0x18],rcx
    2653:	mov    QWORD PTR [rsp+0x30],rcx
    2658:	mov    rcx,r12
    265b:	mov    rdx,QWORD PTR [rsp+0x48]
    2660:	mov    rsi,r13
    2663:	mov    rdi,QWORD PTR [rsp+0x20]
    2668:	call   266d <botlish_fn_17+0x11d>
			2669: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    266d:	test   rax,rax
    2670:	mov    QWORD PTR [rsp+0x38],rax
    2675:	jne    2685 <botlish_fn_17+0x135>
    267b:	mov    rdi,QWORD PTR [rsp+0x20]
    2680:	jmp    276a <botlish_fn_17+0x21a>
    2685:	mov    rbx,QWORD PTR [rsp+0x10]
    268a:	mov    r15,QWORD PTR [rsp+0x18]
    268f:	mov    rdi,QWORD PTR [rsp+0x20]
    2694:	mov    rdi,QWORD PTR [rdi+0x10]
    2698:	mov    r8,QWORD PTR [rdi+0x18]
    269c:	mov    rcx,r15
    269f:	mov    rdx,rbx
    26a2:	mov    rsi,QWORD PTR [rsp+0x38]
    26a7:	mov    rdi,QWORD PTR [rsp+0x20]
    26ac:	call   26b1 <botlish_fn_17+0x161>
			26ad: R_X86_64_PLT32	rt_str_region_eq-0x4
    26b1:	cmp    rax,0x6
    26b5:	je     282d <botlish_fn_17+0x2dd>
    26bb:	mov    rdi,QWORD PTR [rsp+0x20]
    26c0:	mov    r10,QWORD PTR [rdi+0x10]
    26c4:	mov    r8,QWORD PTR [r10+0x20]
    26c8:	mov    rcx,r15
    26cb:	mov    rdx,rbx
    26ce:	mov    rsi,QWORD PTR [rsp+0x38]
    26d3:	call   26d8 <botlish_fn_17+0x188>
			26d4: R_X86_64_PLT32	rt_str_region_eq-0x4
    26d8:	cmp    rax,0x6
    26dc:	je     2743 <botlish_fn_17+0x1f3>
    26e2:	mov    rcx,QWORD PTR [rsp+0x30]
    26e7:	mov    rdx,QWORD PTR [rsp+0x28]
    26ec:	mov    rsi,QWORD PTR [rsp+0x40]
    26f1:	mov    rdi,QWORD PTR [rsp+0x20]
    26f6:	call   26fb <botlish_fn_17+0x1ab>
			26f7: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    26fb:	test   rax,rax
    26fe:	jne    270e <botlish_fn_17+0x1be>
    2704:	mov    rdi,QWORD PTR [rsp+0x20]
    2709:	jmp    276a <botlish_fn_17+0x21a>
    270e:	mov    rdi,QWORD PTR [rsp+0x20]
    2713:	mov    QWORD PTR [rdi],r14
    2716:	mov    rdx,QWORD PTR [rsp+0x48]
    271b:	mov    rbx,QWORD PTR [rsp+0x60]
    2720:	mov    r12,QWORD PTR [rsp+0x68]
    2725:	mov    r13,QWORD PTR [rsp+0x70]
    272a:	mov    r14,QWORD PTR [rsp+0x78]
    272f:	mov    r15,QWORD PTR [rsp+0x80]
    2737:	add    rsp,0x90
    273e:	mov    rsp,rbp
    2741:	pop    rbp
    2742:	ret
    2743:	mov    rcx,QWORD PTR [rsp+0x30]
    2748:	mov    rdx,QWORD PTR [rsp+0x28]
    274d:	mov    rsi,QWORD PTR [rsp+0x40]
    2752:	mov    rdi,QWORD PTR [rsp+0x20]
    2757:	call   275c <botlish_fn_17+0x20c>
			2758: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    275c:	test   rax,rax
    275f:	jne    27a0 <botlish_fn_17+0x250>
    2765:	mov    rdi,QWORD PTR [rsp+0x20]
    276a:	mov    rdi,QWORD PTR [rsp+0x20]
    276f:	mov    QWORD PTR [rdi],r14
    2772:	xor    rdx,rdx
    2775:	mov    rax,rdx
    2778:	mov    rbx,QWORD PTR [rsp+0x60]
    277d:	mov    r12,QWORD PTR [rsp+0x68]
    2782:	mov    r13,QWORD PTR [rsp+0x70]
    2787:	mov    r14,QWORD PTR [rsp+0x78]
    278c:	mov    r15,QWORD PTR [rsp+0x80]
    2794:	add    rsp,0x90
    279b:	mov    rsp,rbp
    279e:	pop    rbp
    279f:	ret
    27a0:	mov    QWORD PTR [r14],rax
    27a3:	mov    rbx,rax
    27a6:	mov    QWORD PTR [r14+0x8],0x3
    27ae:	mov    rdx,QWORD PTR [rsp+0x48]
    27b3:	test   rdx,0x1
    27ba:	je     27de <botlish_fn_17+0x28e>
    27c0:	mov    rdx,QWORD PTR [rsp+0x48]
    27c5:	add    rdx,0x2
    27c9:	seto   al
    27cc:	test   al,al
    27ce:	jne    27de <botlish_fn_17+0x28e>
    27d4:	mov    rdi,QWORD PTR [rsp+0x20]
    27d9:	jmp    27fa <botlish_fn_17+0x2aa>
    27de:	mov    edx,0x3
    27e3:	mov    rsi,QWORD PTR [rsp+0x48]
    27e8:	mov    rdi,QWORD PTR [rsp+0x20]
    27ed:	call   27f2 <botlish_fn_17+0x2a2>
			27ee: R_X86_64_PLT32	rt_int_add-0x4
    27f2:	mov    rdx,rax
    27f5:	mov    rdi,QWORD PTR [rsp+0x20]
    27fa:	mov    rdi,QWORD PTR [rsp+0x20]
    27ff:	mov    QWORD PTR [rdi],r14
    2802:	mov    rax,rbx
    2805:	mov    rbx,QWORD PTR [rsp+0x60]
    280a:	mov    r12,QWORD PTR [rsp+0x68]
    280f:	mov    r13,QWORD PTR [rsp+0x70]
    2814:	mov    r14,QWORD PTR [rsp+0x78]
    2819:	mov    r15,QWORD PTR [rsp+0x80]
    2821:	add    rsp,0x90
    2828:	mov    rsp,rbp
    282b:	pop    rbp
    282c:	ret
    282d:	mov    rsi,QWORD PTR [rsp+0x48]
    2832:	mov    edx,0x3
    2837:	mov    rcx,rdx
    283a:	mov    QWORD PTR [r14+0x20],0x3
    2842:	test   rsi,0x1
    2849:	jne    2857 <botlish_fn_17+0x307>
    284f:	mov    rdx,rcx
    2852:	jmp    286c <botlish_fn_17+0x31c>
    2857:	mov    rdx,rsi
    285a:	add    rdx,0x2
    285e:	seto   al
    2861:	test   al,al
    2863:	je     2879 <botlish_fn_17+0x329>
    2869:	mov    rdx,rcx
    286c:	mov    rdi,QWORD PTR [rsp+0x20]
    2871:	call   2876 <botlish_fn_17+0x326>
			2872: R_X86_64_PLT32	rt_int_add-0x4
    2876:	mov    rdx,rax
    2879:	mov    QWORD PTR [r14],r13
    287c:	mov    QWORD PTR [r14+0x8],rdx
    2880:	mov    rsi,QWORD PTR [rsp+0x40]
    2885:	mov    QWORD PTR [r14+0x10],rsi
    2889:	mov    rax,QWORD PTR [rsp+0x28]
    288e:	mov    QWORD PTR [r14+0x18],rax
    2892:	mov    rcx,QWORD PTR [rsp+0x30]
    2897:	mov    QWORD PTR [r14+0x20],rcx
    289b:	mov    rbx,rsi
    289e:	jmp    25d0 <botlish_fn_17+0x80>
    28a3:	mov    QWORD PTR [rsp+0x20],rdi
    28a8:	call   28ad <botlish_fn_17+0x35d>
			28a9: R_X86_64_PLT32	rt_stack_overflow-0x4
    28ad:	xor    rdx,rdx
    28b0:	mov    rax,rdx
    28b3:	mov    rbx,QWORD PTR [rsp+0x60]
    28b8:	mov    r12,QWORD PTR [rsp+0x68]
    28bd:	mov    r13,QWORD PTR [rsp+0x70]
    28c2:	mov    r14,QWORD PTR [rsp+0x78]
    28c7:	mov    r15,QWORD PTR [rsp+0x80]
    28cf:	add    rsp,0x90
    28d6:	mov    rsp,rbp
    28d9:	pop    rbp
    28da:	ret

00000000000028db <botlish_entry_17: scan_record<str, int, list[list<mutarray>, mutarray, int]>>:
    28db:	push   rbp
    28dc:	mov    rbp,rsp
    28df:	ud2

00000000000028e1 <botlish_fn_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    28e1:	push   rbp
    28e2:	mov    rbp,rsp
    28e5:	sub    rsp,0x60
    28e9:	mov    QWORD PTR [rsp+0x30],rbx
    28ee:	mov    QWORD PTR [rsp+0x38],r12
    28f3:	mov    QWORD PTR [rsp+0x40],r13
    28f8:	mov    QWORD PTR [rsp+0x48],r14
    28fd:	mov    QWORD PTR [rsp+0x50],r15
    2902:	mov    rbx,QWORD PTR [rdi]
    2905:	mov    rax,QWORD PTR [rdi+0x8]
    2909:	lea    r10,[rbx+0x40]
    290d:	cmp    r10,rax
    2910:	ja     2ae3 <botlish_fn_18+0x202>
    2916:	lea    rax,[rbx+0x40]
    291a:	mov    QWORD PTR [rdi],rax
    291d:	mov    r12,rdi
    2920:	mov    QWORD PTR [rbx+0x28],0x0
    2928:	mov    QWORD PTR [rbx+0x30],0x0
    2930:	mov    QWORD PTR [rbx+0x38],0x0
    2938:	mov    QWORD PTR [rbx],rsi
    293b:	mov    r13,rsi
    293e:	mov    QWORD PTR [rbx+0x8],rdx
    2942:	mov    QWORD PTR [rsp+0x20],rdx
    2947:	mov    QWORD PTR [rbx+0x10],rcx
    294b:	mov    QWORD PTR [rsp+0x28],rcx
    2950:	mov    QWORD PTR [rbx+0x18],r8
    2954:	mov    r15,r8
    2957:	mov    QWORD PTR [rbx+0x20],r9
    295b:	mov    r14,r9
    295e:	mov    rsi,r13
    2961:	mov    rdi,r12
    2964:	call   2969 <botlish_fn_18+0x88>
			2965: R_X86_64_PLT32	rt_str_len-0x4
    2969:	mov    rdx,QWORD PTR [rsp+0x20]
    296e:	mov    rcx,rdx
    2971:	sar    rcx,1
    2974:	sar    rax,1
    2977:	cmp    rcx,rax
    297a:	jge    2a71 <botlish_fn_18+0x190>
    2980:	lea    rsi,[rsp]
    2984:	mov    rdi,r12
    2987:	call   298c <botlish_fn_18+0xab>
			2988: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    298c:	test   rax,rax
    298f:	jne    299d <botlish_fn_18+0xbc>
    2995:	mov    rdi,r12
    2998:	jmp    2a90 <botlish_fn_18+0x1af>
    299d:	mov    QWORD PTR [rbx+0x28],rax
    29a1:	mov    rcx,rax
    29a4:	mov    r8,QWORD PTR [rsp]
    29a8:	mov    QWORD PTR [rbx+0x30],r8
    29ac:	mov    r9,QWORD PTR [rsp+0x8]
    29b1:	mov    QWORD PTR [rbx+0x38],r9
    29b5:	mov    rdx,QWORD PTR [rsp+0x20]
    29ba:	mov    rsi,r13
    29bd:	mov    rdi,r12
    29c0:	call   29c5 <botlish_fn_18+0xe4>
			29c1: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    29c5:	test   rax,rax
    29c8:	jne    29d6 <botlish_fn_18+0xf5>
    29ce:	mov    rdi,r12
    29d1:	jmp    2a90 <botlish_fn_18+0x1af>
    29d6:	mov    QWORD PTR [rbx+0x8],rax
    29da:	mov    r8,rax
    29dd:	mov    QWORD PTR [rbx+0x28],rdx
    29e1:	mov    QWORD PTR [rsp+0x20],rdx
    29e6:	lea    r9,[rsp+0x10]
    29eb:	mov    rcx,r14
    29ee:	mov    rdx,r15
    29f1:	mov    rsi,QWORD PTR [rsp+0x28]
    29f6:	mov    rdi,r12
    29f9:	call   29fe <botlish_fn_18+0x11d>
			29fa: R_X86_64_PLT32	botlish_fn_5-0x4 ; chunked_append<list[list<never>, mutarray, int], list>
    29fe:	test   rax,rax
    2a01:	jne    2a0f <botlish_fn_18+0x12e>
    2a07:	mov    rdi,r12
    2a0a:	jmp    2a90 <botlish_fn_18+0x1af>
    2a0f:	mov    QWORD PTR [rbx+0x8],rax
    2a13:	mov    rcx,rax
    2a16:	mov    r8,QWORD PTR [rsp+0x10]
    2a1b:	mov    QWORD PTR [rbx+0x10],r8
    2a1f:	mov    r9,QWORD PTR [rsp+0x18]
    2a24:	mov    QWORD PTR [rbx+0x18],r9
    2a28:	mov    rdx,QWORD PTR [rsp+0x20]
    2a2d:	mov    rsi,r13
    2a30:	mov    rdi,r12
    2a33:	call   2a38 <botlish_fn_18+0x157>
			2a34: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    2a38:	test   rax,rax
    2a3b:	jne    2a49 <botlish_fn_18+0x168>
    2a41:	mov    rdi,r12
    2a44:	jmp    2a90 <botlish_fn_18+0x1af>
    2a49:	mov    rdi,r12
    2a4c:	mov    QWORD PTR [rdi],rbx
    2a4f:	mov    rbx,QWORD PTR [rsp+0x30]
    2a54:	mov    r12,QWORD PTR [rsp+0x38]
    2a59:	mov    r13,QWORD PTR [rsp+0x40]
    2a5e:	mov    r14,QWORD PTR [rsp+0x48]
    2a63:	mov    r15,QWORD PTR [rsp+0x50]
    2a68:	add    rsp,0x60
    2a6c:	mov    rsp,rbp
    2a6f:	pop    rbp
    2a70:	ret
    2a71:	mov    rcx,r14
    2a74:	mov    rdx,r15
    2a77:	mov    rsi,QWORD PTR [rsp+0x28]
    2a7c:	mov    rdi,r12
    2a7f:	call   2a84 <botlish_fn_18+0x1a3>
			2a80: R_X86_64_PLT32	botlish_fn_9-0x4 ; chunked_finish<list[list<never>, mutarray, int]>
    2a84:	test   rax,rax
    2a87:	jne    2abb <botlish_fn_18+0x1da>
    2a8d:	mov    rdi,r12
    2a90:	mov    rdi,r12
    2a93:	mov    QWORD PTR [rdi],rbx
    2a96:	xor    rax,rax
    2a99:	mov    rbx,QWORD PTR [rsp+0x30]
    2a9e:	mov    r12,QWORD PTR [rsp+0x38]
    2aa3:	mov    r13,QWORD PTR [rsp+0x40]
    2aa8:	mov    r14,QWORD PTR [rsp+0x48]
    2aad:	mov    r15,QWORD PTR [rsp+0x50]
    2ab2:	add    rsp,0x60
    2ab6:	mov    rsp,rbp
    2ab9:	pop    rbp
    2aba:	ret
    2abb:	mov    rdi,r12
    2abe:	mov    QWORD PTR [rdi],rbx
    2ac1:	mov    rbx,QWORD PTR [rsp+0x30]
    2ac6:	mov    r12,QWORD PTR [rsp+0x38]
    2acb:	mov    r13,QWORD PTR [rsp+0x40]
    2ad0:	mov    r14,QWORD PTR [rsp+0x48]
    2ad5:	mov    r15,QWORD PTR [rsp+0x50]
    2ada:	add    rsp,0x60
    2ade:	mov    rsp,rbp
    2ae1:	pop    rbp
    2ae2:	ret
    2ae3:	mov    r12,rdi
    2ae6:	call   2aeb <botlish_fn_18+0x20a>
			2ae7: R_X86_64_PLT32	rt_stack_overflow-0x4
    2aeb:	xor    rax,rax
    2aee:	mov    rbx,QWORD PTR [rsp+0x30]
    2af3:	mov    r12,QWORD PTR [rsp+0x38]
    2af8:	mov    r13,QWORD PTR [rsp+0x40]
    2afd:	mov    r14,QWORD PTR [rsp+0x48]
    2b02:	mov    r15,QWORD PTR [rsp+0x50]
    2b07:	add    rsp,0x60
    2b0b:	mov    rsp,rbp
    2b0e:	pop    rbp
    2b0f:	ret

0000000000002b10 <botlish_entry_18: scan_records<str, int, list[list<never>, mutarray, int]>>:
    2b10:	push   rbp
    2b11:	mov    rbp,rsp
    2b14:	mov    rsi,QWORD PTR [rdx]
    2b17:	mov    r10,QWORD PTR [rdx+0x8]
    2b1b:	mov    rcx,QWORD PTR [rdx+0x10]
    2b1f:	mov    r8,QWORD PTR [rdx+0x18]
    2b23:	mov    r9,QWORD PTR [rdx+0x20]
    2b27:	mov    rdx,r10
    2b2a:	call   2b2f <botlish_entry_18+0x1f>
			2b2b: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    2b2f:	mov    rsp,rbp
    2b32:	pop    rbp
    2b33:	ret
    2b34:	add    BYTE PTR [rax],al
	...

0000000000002b38 <botlish_fn_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    2b38:	push   rbp
    2b39:	mov    rbp,rsp
    2b3c:	sub    rsp,0x70
    2b40:	mov    QWORD PTR [rsp+0x40],rbx
    2b45:	mov    QWORD PTR [rsp+0x48],r12
    2b4a:	mov    QWORD PTR [rsp+0x50],r13
    2b4f:	mov    QWORD PTR [rsp+0x58],r14
    2b54:	mov    QWORD PTR [rsp+0x60],r15
    2b59:	mov    r14,QWORD PTR [rdi]
    2b5c:	mov    rax,QWORD PTR [rdi+0x8]
    2b60:	lea    r10,[r14+0x40]
    2b64:	cmp    r10,rax
    2b67:	ja     2d6e <botlish_fn_19+0x236>
    2b6d:	lea    rax,[r14+0x40]
    2b71:	mov    QWORD PTR [rdi],rax
    2b74:	mov    QWORD PTR [rsp+0x20],rdi
    2b79:	mov    QWORD PTR [r14+0x28],0x0
    2b81:	mov    QWORD PTR [r14+0x30],0x0
    2b89:	mov    QWORD PTR [r14+0x38],0x0
    2b91:	mov    QWORD PTR [r14],rsi
    2b94:	mov    QWORD PTR [r14+0x8],rdx
    2b98:	mov    r15,rdx
    2b9b:	mov    QWORD PTR [r14+0x10],rcx
    2b9f:	mov    QWORD PTR [r14+0x18],r8
    2ba3:	mov    QWORD PTR [r14+0x20],r9
    2ba7:	lea    rbx,[rsp]
    2bab:	lea    r12,[rsp+0x10]
    2bb0:	mov    r13,rsi
    2bb3:	mov    QWORD PTR [rsp+0x28],rcx
    2bb8:	mov    QWORD PTR [rsp+0x30],r8
    2bbd:	mov    QWORD PTR [rsp+0x38],r9
    2bc2:	mov    rsi,r13
    2bc5:	mov    rdi,QWORD PTR [rsp+0x20]
    2bca:	call   2bcf <botlish_fn_19+0x97>
			2bcb: R_X86_64_PLT32	rt_str_len-0x4
    2bcf:	mov    rcx,r15
    2bd2:	and    rcx,rax
    2bd5:	mov    rdx,rax
    2bd8:	test   rcx,0x1
    2bdf:	jne    2c07 <botlish_fn_19+0xcf>
    2be5:	mov    rsi,r15
    2be8:	mov    rdi,QWORD PTR [rsp+0x20]
    2bed:	call   2bf2 <botlish_fn_19+0xba>
			2bee: R_X86_64_PLT32	rt_int_cmp-0x4
    2bf2:	mov    ecx,0x2
    2bf7:	test   rax,rax
    2bfa:	cmovge rcx,QWORD PTR [rip+0x19e]        # 2da0 <botlish_fn_19+0x268>
    2c02:	jmp    2c1a <botlish_fn_19+0xe2>
    2c07:	mov    ecx,0x2
    2c0c:	mov    rax,r15
    2c0f:	cmp    rax,rdx
    2c12:	cmovge rcx,QWORD PTR [rip+0x186]        # 2da0 <botlish_fn_19+0x268>
    2c1a:	cmp    rcx,0x6
    2c1e:	je     2cf0 <botlish_fn_19+0x1b8>
    2c24:	mov    rsi,rbx
    2c27:	mov    rdi,QWORD PTR [rsp+0x20]
    2c2c:	call   2c31 <botlish_fn_19+0xf9>
			2c2d: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    2c31:	test   rax,rax
    2c34:	jne    2c44 <botlish_fn_19+0x10c>
    2c3a:	mov    rdi,QWORD PTR [rsp+0x20]
    2c3f:	jmp    2d17 <botlish_fn_19+0x1df>
    2c44:	mov    QWORD PTR [r14+0x28],rax
    2c48:	mov    rcx,rax
    2c4b:	mov    r8,QWORD PTR [rsp]
    2c4f:	mov    QWORD PTR [r14+0x30],r8
    2c53:	mov    r9,QWORD PTR [rsp+0x8]
    2c58:	mov    QWORD PTR [r14+0x38],r9
    2c5c:	mov    rdx,r15
    2c5f:	mov    rsi,r13
    2c62:	mov    rdi,QWORD PTR [rsp+0x20]
    2c67:	call   2c6c <botlish_fn_19+0x134>
			2c68: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record<str, int, list[list<never>, mutarray, int]>
    2c6c:	test   rax,rax
    2c6f:	jne    2c7f <botlish_fn_19+0x147>
    2c75:	mov    rdi,QWORD PTR [rsp+0x20]
    2c7a:	jmp    2d17 <botlish_fn_19+0x1df>
    2c7f:	mov    QWORD PTR [r14+0x8],rax
    2c83:	mov    r8,rax
    2c86:	mov    QWORD PTR [r14+0x28],rdx
    2c8a:	mov    r15,rdx
    2c8d:	mov    rsi,QWORD PTR [rsp+0x28]
    2c92:	mov    rdx,QWORD PTR [rsp+0x30]
    2c97:	mov    rcx,QWORD PTR [rsp+0x38]
    2c9c:	mov    rdi,QWORD PTR [rsp+0x20]
    2ca1:	mov    r9,r12
    2ca4:	call   2ca9 <botlish_fn_19+0x171>
			2ca5: R_X86_64_PLT32	botlish_fn_6-0x4 ; chunked_append<list[list<mutarray>, mutarray, int], list>
    2ca9:	test   rax,rax
    2cac:	jne    2cbc <botlish_fn_19+0x184>
    2cb2:	mov    rdi,QWORD PTR [rsp+0x20]
    2cb7:	jmp    2d17 <botlish_fn_19+0x1df>
    2cbc:	mov    rdx,QWORD PTR [rsp+0x10]
    2cc1:	mov    rcx,QWORD PTR [rsp+0x18]
    2cc6:	mov    QWORD PTR [r14],r13
    2cc9:	mov    rsi,r15
    2ccc:	mov    QWORD PTR [r14+0x8],rsi
    2cd0:	mov    QWORD PTR [r14+0x10],rax
    2cd4:	mov    QWORD PTR [r14+0x18],rdx
    2cd8:	mov    QWORD PTR [r14+0x20],rcx
    2cdc:	mov    QWORD PTR [rsp+0x28],rax
    2ce1:	mov    QWORD PTR [rsp+0x30],rdx
    2ce6:	mov    QWORD PTR [rsp+0x38],rcx
    2ceb:	jmp    2bc2 <botlish_fn_19+0x8a>
    2cf0:	mov    rcx,QWORD PTR [rsp+0x38]
    2cf5:	mov    rdx,QWORD PTR [rsp+0x30]
    2cfa:	mov    rsi,QWORD PTR [rsp+0x28]
    2cff:	mov    rdi,QWORD PTR [rsp+0x20]
    2d04:	call   2d09 <botlish_fn_19+0x1d1>
			2d05: R_X86_64_PLT32	botlish_fn_10-0x4 ; chunked_finish<list[list<mutarray>, mutarray, int]>
    2d09:	test   rax,rax
    2d0c:	jne    2d44 <botlish_fn_19+0x20c>
    2d12:	mov    rdi,QWORD PTR [rsp+0x20]
    2d17:	mov    rdi,QWORD PTR [rsp+0x20]
    2d1c:	mov    QWORD PTR [rdi],r14
    2d1f:	xor    rax,rax
    2d22:	mov    rbx,QWORD PTR [rsp+0x40]
    2d27:	mov    r12,QWORD PTR [rsp+0x48]
    2d2c:	mov    r13,QWORD PTR [rsp+0x50]
    2d31:	mov    r14,QWORD PTR [rsp+0x58]
    2d36:	mov    r15,QWORD PTR [rsp+0x60]
    2d3b:	add    rsp,0x70
    2d3f:	mov    rsp,rbp
    2d42:	pop    rbp
    2d43:	ret
    2d44:	mov    rdi,QWORD PTR [rsp+0x20]
    2d49:	mov    QWORD PTR [rdi],r14
    2d4c:	mov    rbx,QWORD PTR [rsp+0x40]
    2d51:	mov    r12,QWORD PTR [rsp+0x48]
    2d56:	mov    r13,QWORD PTR [rsp+0x50]
    2d5b:	mov    r14,QWORD PTR [rsp+0x58]
    2d60:	mov    r15,QWORD PTR [rsp+0x60]
    2d65:	add    rsp,0x70
    2d69:	mov    rsp,rbp
    2d6c:	pop    rbp
    2d6d:	ret
    2d6e:	mov    QWORD PTR [rsp+0x20],rdi
    2d73:	call   2d78 <botlish_fn_19+0x240>
			2d74: R_X86_64_PLT32	rt_stack_overflow-0x4
    2d78:	xor    rax,rax
    2d7b:	mov    rbx,QWORD PTR [rsp+0x40]
    2d80:	mov    r12,QWORD PTR [rsp+0x48]
    2d85:	mov    r13,QWORD PTR [rsp+0x50]
    2d8a:	mov    r14,QWORD PTR [rsp+0x58]
    2d8f:	mov    r15,QWORD PTR [rsp+0x60]
    2d94:	add    rsp,0x70
    2d98:	mov    rsp,rbp
    2d9b:	pop    rbp
    2d9c:	ret
    2d9d:	add    BYTE PTR [rax],al
    2d9f:	add    BYTE PTR [rsi],al
    2da1:	add    BYTE PTR [rax],al
    2da3:	add    BYTE PTR [rax],al
    2da5:	add    BYTE PTR [rax],al
	...

0000000000002da8 <botlish_entry_19: scan_records<str, int, list[list<mutarray>, mutarray, int]>>:
    2da8:	push   rbp
    2da9:	mov    rbp,rsp
    2dac:	mov    rsi,QWORD PTR [rdx]
    2daf:	mov    r10,QWORD PTR [rdx+0x8]
    2db3:	mov    rcx,QWORD PTR [rdx+0x10]
    2db7:	mov    r8,QWORD PTR [rdx+0x18]
    2dbb:	mov    r9,QWORD PTR [rdx+0x20]
    2dbf:	mov    rdx,r10
    2dc2:	call   2dc7 <botlish_entry_19+0x1f>
			2dc3: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_records<str, int, list[list<mutarray>, mutarray, int]>
    2dc7:	mov    rsp,rbp
    2dca:	pop    rbp
    2dcb:	ret

0000000000002dcc <botlish_fn_20: csv_parse<str>>:
    2dcc:	push   rbp
    2dcd:	mov    rbp,rsp
    2dd0:	sub    rsp,0x30
    2dd4:	mov    QWORD PTR [rsp+0x10],rbx
    2dd9:	mov    QWORD PTR [rsp+0x18],r12
    2dde:	mov    QWORD PTR [rsp+0x20],r13
    2de3:	mov    rbx,QWORD PTR [rdi]
    2de6:	mov    rax,QWORD PTR [rdi+0x8]
    2dea:	lea    rcx,[rbx+0x28]
    2dee:	cmp    rcx,rax
    2df1:	ja     2eb7 <botlish_fn_20+0xeb>
    2df7:	lea    rax,[rbx+0x28]
    2dfb:	mov    QWORD PTR [rdi],rax
    2dfe:	mov    r12,rdi
    2e01:	mov    QWORD PTR [rbx+0x10],0x0
    2e09:	mov    QWORD PTR [rbx+0x18],0x0
    2e11:	mov    QWORD PTR [rbx+0x20],0x0
    2e19:	mov    QWORD PTR [rbx],rsi
    2e1c:	mov    r13,rsi
    2e1f:	mov    QWORD PTR [rbx+0x8],0x1
    2e27:	lea    rsi,[rsp]
    2e2b:	mov    rdi,r12
    2e2e:	call   2e33 <botlish_fn_20+0x67>
			2e2f: R_X86_64_PLT32	botlish_fn_2-0x4 ; chunked_new<generic>
    2e33:	test   rax,rax
    2e36:	jne    2e44 <botlish_fn_20+0x78>
    2e3c:	mov    rdi,r12
    2e3f:	jmp    2e78 <botlish_fn_20+0xac>
    2e44:	mov    QWORD PTR [rbx+0x10],rax
    2e48:	mov    rcx,rax
    2e4b:	mov    r8,QWORD PTR [rsp]
    2e4f:	mov    QWORD PTR [rbx+0x18],r8
    2e53:	mov    r9,QWORD PTR [rsp+0x8]
    2e58:	mov    QWORD PTR [rbx+0x20],r9
    2e5c:	mov    edx,0x1
    2e61:	mov    rsi,r13
    2e64:	mov    rdi,r12
    2e67:	call   2e6c <botlish_fn_20+0xa0>
			2e68: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, list[list<never>, mutarray, int]>
    2e6c:	test   rax,rax
    2e6f:	jne    2e99 <botlish_fn_20+0xcd>
    2e75:	mov    rdi,r12
    2e78:	mov    rdi,r12
    2e7b:	mov    QWORD PTR [rdi],rbx
    2e7e:	xor    rax,rax
    2e81:	mov    rbx,QWORD PTR [rsp+0x10]
    2e86:	mov    r12,QWORD PTR [rsp+0x18]
    2e8b:	mov    r13,QWORD PTR [rsp+0x20]
    2e90:	add    rsp,0x30
    2e94:	mov    rsp,rbp
    2e97:	pop    rbp
    2e98:	ret
    2e99:	mov    rdi,r12
    2e9c:	mov    QWORD PTR [rdi],rbx
    2e9f:	mov    rbx,QWORD PTR [rsp+0x10]
    2ea4:	mov    r12,QWORD PTR [rsp+0x18]
    2ea9:	mov    r13,QWORD PTR [rsp+0x20]
    2eae:	add    rsp,0x30
    2eb2:	mov    rsp,rbp
    2eb5:	pop    rbp
    2eb6:	ret
    2eb7:	mov    r12,rdi
    2eba:	call   2ebf <botlish_fn_20+0xf3>
			2ebb: R_X86_64_PLT32	rt_stack_overflow-0x4
    2ebf:	xor    rax,rax
    2ec2:	mov    rbx,QWORD PTR [rsp+0x10]
    2ec7:	mov    r12,QWORD PTR [rsp+0x18]
    2ecc:	mov    r13,QWORD PTR [rsp+0x20]
    2ed1:	add    rsp,0x30
    2ed5:	mov    rsp,rbp
    2ed8:	pop    rbp
    2ed9:	ret

0000000000002eda <botlish_entry_20: csv_parse<str>>:
    2eda:	push   rbp
    2edb:	mov    rbp,rsp
    2ede:	mov    rsi,QWORD PTR [rdx]
    2ee1:	call   2ee6 <botlish_entry_20+0xc>
			2ee2: R_X86_64_PLT32	botlish_fn_20-0x4 ; csv_parse<str>
    2ee6:	mov    rsp,rbp
    2ee9:	pop    rbp
    2eea:	ret

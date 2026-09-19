; source:  examples/stdlib/csv.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 6228  (per function: 176 501 558 698 913 482 783 765 515 556 281)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> peek<str, int>
;   botlish_fn_2 / botlish_entry_2 -> peek<str, int>
;   botlish_fn_3 / botlish_entry_3 -> scan_unquoted<str, int, int>
;   botlish_fn_4 / botlish_entry_4 -> scan_quoted<str, int, str>
;   botlish_fn_5 / botlish_entry_5 -> scan_field<str, int>
;   botlish_fn_6 / botlish_entry_6 -> scan_record<str, int, list<never>>
;   botlish_fn_7 / botlish_entry_7 -> scan_record<str, int, list<str>>
;   botlish_fn_8 / botlish_entry_8 -> scan_records<str, int, list<never>>
;   botlish_fn_9 / botlish_entry_9 -> scan_records<str, int, list<list<str>>>
;   botlish_fn_10 / botlish_entry_10 -> csv_parse<str>


csv.asm.o:     file format elf64-x86-64


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
      1f:	ja     83 <botlish_fn_0+0x83>
      25:	lea    rax,[r13+0x8]
      29:	mov    QWORD PTR [rdi],rax
      2c:	mov    QWORD PTR [r13+0x0],0x0
      34:	mov    rax,QWORD PTR [rdi+0x10]
      38:	mov    r14,rdi
      3b:	mov    rsi,QWORD PTR [rax]
      3e:	mov    QWORD PTR [r13+0x0],rsi
      42:	call   47 <botlish_fn_0+0x47>
			43: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
      47:	test   rax,rax
      4a:	jne    6b <botlish_fn_0+0x6b>
      50:	mov    rdi,r14
      53:	mov    QWORD PTR [rdi],r13
      56:	xor    rax,rax
      59:	mov    r13,QWORD PTR [rsp]
      5d:	mov    r14,QWORD PTR [rsp+0x8]
      62:	add    rsp,0x10
      66:	mov    rsp,rbp
      69:	pop    rbp
      6a:	ret
      6b:	mov    rdi,r14
      6e:	mov    QWORD PTR [rdi],r13
      71:	mov    r13,QWORD PTR [rsp]
      75:	mov    r14,QWORD PTR [rsp+0x8]
      7a:	add    rsp,0x10
      7e:	mov    rsp,rbp
      81:	pop    rbp
      82:	ret
      83:	call   88 <botlish_fn_0+0x88>
			84: R_X86_64_PLT32	rt_stack_overflow-0x4
      88:	xor    rax,rax
      8b:	mov    r13,QWORD PTR [rsp]
      8f:	mov    r14,QWORD PTR [rsp+0x8]
      94:	add    rsp,0x10
      98:	mov    rsp,rbp
      9b:	pop    rbp
      9c:	ret

000000000000009d <botlish_entry_0: <program entry>>:
      9d:	push   rbp
      9e:	mov    rbp,rsp
      a1:	call   a6 <botlish_entry_0+0x9>
			a2: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      a6:	mov    rsp,rbp
      a9:	pop    rbp
      aa:	ret
      ab:	add    BYTE PTR [rax],al
      ad:	add    BYTE PTR [rax],al
	...

00000000000000b0 <botlish_fn_1: peek<str, int>>:
      b0:	push   rbp
      b1:	mov    rbp,rsp
      b4:	sub    rsp,0x20
      b8:	mov    QWORD PTR [rsp],rbx
      bc:	mov    QWORD PTR [rsp+0x8],r12
      c1:	mov    QWORD PTR [rsp+0x10],r13
      c6:	mov    QWORD PTR [rsp+0x18],r14
      cb:	mov    r12,QWORD PTR [rdi]
      ce:	mov    rax,QWORD PTR [rdi+0x8]
      d2:	lea    rcx,[r12+0x18]
      d7:	cmp    rcx,rax
      da:	ja     237 <botlish_fn_1+0x187>
      e0:	lea    rax,[r12+0x18]
      e5:	mov    QWORD PTR [rdi],rax
      e8:	mov    r13,rdi
      eb:	mov    QWORD PTR [r12],0x0
      f3:	mov    QWORD PTR [r12+0x8],0x0
      fc:	mov    QWORD PTR [r12+0x10],0x0
     105:	mov    QWORD PTR [r12],rsi
     109:	mov    r14,rsi
     10c:	mov    QWORD PTR [r12+0x8],rdx
     111:	mov    rbx,rdx
     114:	mov    rsi,r14
     117:	mov    rdi,r13
     11a:	call   11f <botlish_fn_1+0x6f>
			11b: R_X86_64_PLT32	rt_str_len-0x4
     11f:	mov    rcx,rbx
     122:	and    rcx,rax
     125:	mov    rdx,rax
     128:	test   rcx,0x1
     12f:	jne    155 <botlish_fn_1+0xa5>
     135:	mov    rsi,rbx
     138:	mov    rdi,r13
     13b:	call   140 <botlish_fn_1+0x90>
			13c: R_X86_64_PLT32	rt_int_cmp-0x4
     140:	mov    ecx,0x2
     145:	test   rax,rax
     148:	cmovge rcx,QWORD PTR [rip+0x110]        # 260 <botlish_fn_1+0x1b0>
     150:	jmp    165 <botlish_fn_1+0xb5>
     155:	mov    ecx,0x2
     15a:	cmp    rbx,rdx
     15d:	cmovge rcx,QWORD PTR [rip+0xfb]        # 260 <botlish_fn_1+0x1b0>
     165:	cmp    rcx,0x6
     169:	je     20d <botlish_fn_1+0x15d>
     16f:	mov    QWORD PTR [r12+0x10],0x3
     178:	test   rbx,0x1
     17f:	je     197 <botlish_fn_1+0xe7>
     185:	mov    rcx,rbx
     188:	add    rcx,0x2
     18c:	seto   al
     18f:	test   al,al
     191:	je     1aa <botlish_fn_1+0xfa>
     197:	mov    edx,0x3
     19c:	mov    rsi,rbx
     19f:	mov    rdi,r13
     1a2:	call   1a7 <botlish_fn_1+0xf7>
			1a3: R_X86_64_PLT32	rt_int_add-0x4
     1a7:	mov    rcx,rax
     1aa:	mov    QWORD PTR [r12+0x10],rcx
     1af:	mov    rdx,rbx
     1b2:	mov    rsi,r14
     1b5:	mov    rdi,r13
     1b8:	call   1bd <botlish_fn_1+0x10d>
			1b9: R_X86_64_PLT32	rt_substr-0x4
     1bd:	test   rax,rax
     1c0:	jne    1eb <botlish_fn_1+0x13b>
     1c6:	mov    rdi,r13
     1c9:	mov    QWORD PTR [rdi],r12
     1cc:	xor    rax,rax
     1cf:	mov    rbx,QWORD PTR [rsp]
     1d3:	mov    r12,QWORD PTR [rsp+0x8]
     1d8:	mov    r13,QWORD PTR [rsp+0x10]
     1dd:	mov    r14,QWORD PTR [rsp+0x18]
     1e2:	add    rsp,0x20
     1e6:	mov    rsp,rbp
     1e9:	pop    rbp
     1ea:	ret
     1eb:	mov    rdi,r13
     1ee:	mov    QWORD PTR [rdi],r12
     1f1:	mov    rbx,QWORD PTR [rsp]
     1f5:	mov    r12,QWORD PTR [rsp+0x8]
     1fa:	mov    r13,QWORD PTR [rsp+0x10]
     1ff:	mov    r14,QWORD PTR [rsp+0x18]
     204:	add    rsp,0x20
     208:	mov    rsp,rbp
     20b:	pop    rbp
     20c:	ret
     20d:	mov    rdi,r13
     210:	mov    rax,QWORD PTR [rdi+0x10]
     214:	mov    rax,QWORD PTR [rax+0x8]
     218:	mov    QWORD PTR [rdi],r12
     21b:	mov    rbx,QWORD PTR [rsp]
     21f:	mov    r12,QWORD PTR [rsp+0x8]
     224:	mov    r13,QWORD PTR [rsp+0x10]
     229:	mov    r14,QWORD PTR [rsp+0x18]
     22e:	add    rsp,0x20
     232:	mov    rsp,rbp
     235:	pop    rbp
     236:	ret
     237:	mov    r13,rdi
     23a:	call   23f <botlish_fn_1+0x18f>
			23b: R_X86_64_PLT32	rt_stack_overflow-0x4
     23f:	xor    rax,rax
     242:	mov    rbx,QWORD PTR [rsp]
     246:	mov    r12,QWORD PTR [rsp+0x8]
     24b:	mov    r13,QWORD PTR [rsp+0x10]
     250:	mov    r14,QWORD PTR [rsp+0x18]
     255:	add    rsp,0x20
     259:	mov    rsp,rbp
     25c:	pop    rbp
     25d:	ret
     25e:	add    BYTE PTR [rax],al
     260:	(bad)
     261:	add    BYTE PTR [rax],al
     263:	add    BYTE PTR [rax],al
     265:	add    BYTE PTR [rax],al
	...

0000000000000268 <botlish_entry_1: peek<str, int>>:
     268:	push   rbp
     269:	mov    rbp,rsp
     26c:	mov    rsi,QWORD PTR [rdx]
     26f:	mov    rdx,QWORD PTR [rdx+0x8]
     273:	call   278 <botlish_entry_1+0x10>
			274: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     278:	mov    rsp,rbp
     27b:	pop    rbp
     27c:	ret
     27d:	add    BYTE PTR [rax],al
	...

0000000000000280 <botlish_fn_2: peek<str, int>>:
     280:	push   rbp
     281:	mov    rbp,rsp
     284:	sub    rsp,0x40
     288:	mov    QWORD PTR [rsp+0x10],rbx
     28d:	mov    QWORD PTR [rsp+0x18],r12
     292:	mov    QWORD PTR [rsp+0x20],r13
     297:	mov    QWORD PTR [rsp+0x28],r14
     29c:	mov    QWORD PTR [rsp+0x30],r15
     2a1:	mov    r13,rcx
     2a4:	mov    r12,QWORD PTR [rdi]
     2a7:	mov    rax,QWORD PTR [rdi+0x8]
     2ab:	lea    rcx,[r12+0x18]
     2b0:	cmp    rcx,rax
     2b3:	ja     44e <botlish_fn_2+0x1ce>
     2b9:	lea    rax,[r12+0x18]
     2be:	mov    QWORD PTR [rdi],rax
     2c1:	mov    r15,rdi
     2c4:	mov    QWORD PTR [r12],0x0
     2cc:	mov    QWORD PTR [r12+0x8],0x0
     2d5:	mov    QWORD PTR [r12+0x10],0x0
     2de:	mov    QWORD PTR [r12],rsi
     2e2:	mov    r14,rsi
     2e5:	mov    QWORD PTR [r12+0x8],rdx
     2ea:	mov    rbx,rdx
     2ed:	mov    rsi,r14
     2f0:	mov    rdi,r15
     2f3:	call   2f8 <botlish_fn_2+0x78>
			2f4: R_X86_64_PLT32	rt_str_len-0x4
     2f8:	mov    rcx,rbx
     2fb:	and    rcx,rax
     2fe:	mov    rdx,rax
     301:	test   rcx,0x1
     308:	jne    32e <botlish_fn_2+0xae>
     30e:	mov    rsi,rbx
     311:	mov    rdi,r15
     314:	call   319 <botlish_fn_2+0x99>
			315: R_X86_64_PLT32	rt_int_cmp-0x4
     319:	mov    ecx,0x2
     31e:	test   rax,rax
     321:	cmovge rcx,QWORD PTR [rip+0x157]        # 480 <botlish_fn_2+0x200>
     329:	jmp    33e <botlish_fn_2+0xbe>
     32e:	mov    ecx,0x2
     333:	cmp    rbx,rdx
     336:	cmovge rcx,QWORD PTR [rip+0x142]        # 480 <botlish_fn_2+0x200>
     33e:	cmp    rcx,0x6
     342:	je     40c <botlish_fn_2+0x18c>
     348:	mov    QWORD PTR [r12+0x10],0x3
     351:	test   rbx,0x1
     358:	je     379 <botlish_fn_2+0xf9>
     35e:	mov    rax,rbx
     361:	add    rax,0x2
     365:	seto   cl
     368:	test   cl,cl
     36a:	jne    379 <botlish_fn_2+0xf9>
     370:	mov    QWORD PTR [rsp],rax
     374:	jmp    38d <botlish_fn_2+0x10d>
     379:	mov    edx,0x3
     37e:	mov    rsi,rbx
     381:	mov    rdi,r15
     384:	call   389 <botlish_fn_2+0x109>
			385: R_X86_64_PLT32	rt_int_add-0x4
     389:	mov    QWORD PTR [rsp],rax
     38d:	mov    rcx,QWORD PTR [rsp]
     391:	mov    rdx,rbx
     394:	mov    rsi,r14
     397:	mov    rdi,r15
     39a:	call   39f <botlish_fn_2+0x11f>
			39b: R_X86_64_PLT32	rt_str_region_check-0x4
     39f:	test   rax,rax
     3a2:	jne    3d3 <botlish_fn_2+0x153>
     3a8:	mov    rdi,r15
     3ab:	mov    QWORD PTR [rdi],r12
     3ae:	xor    rax,rax
     3b1:	mov    rbx,QWORD PTR [rsp+0x10]
     3b6:	mov    r12,QWORD PTR [rsp+0x18]
     3bb:	mov    r13,QWORD PTR [rsp+0x20]
     3c0:	mov    r14,QWORD PTR [rsp+0x28]
     3c5:	mov    r15,QWORD PTR [rsp+0x30]
     3ca:	add    rsp,0x40
     3ce:	mov    rsp,rbp
     3d1:	pop    rbp
     3d2:	ret
     3d3:	mov    rdi,r15
     3d6:	mov    QWORD PTR [rdi],r12
     3d9:	mov    rcx,r13
     3dc:	mov    QWORD PTR [rcx],rbx
     3df:	mov    rax,QWORD PTR [rsp]
     3e3:	mov    QWORD PTR [rcx+0x8],rax
     3e7:	mov    rax,r14
     3ea:	mov    rbx,QWORD PTR [rsp+0x10]
     3ef:	mov    r12,QWORD PTR [rsp+0x18]
     3f4:	mov    r13,QWORD PTR [rsp+0x20]
     3f9:	mov    r14,QWORD PTR [rsp+0x28]
     3fe:	mov    r15,QWORD PTR [rsp+0x30]
     403:	add    rsp,0x40
     407:	mov    rsp,rbp
     40a:	pop    rbp
     40b:	ret
     40c:	mov    rcx,r13
     40f:	mov    rdi,r15
     412:	mov    rdx,QWORD PTR [rdi+0x10]
     416:	mov    rax,QWORD PTR [rdx+0x8]
     41a:	mov    QWORD PTR [rdi],r12
     41d:	mov    QWORD PTR [rcx],0x1
     424:	mov    QWORD PTR [rcx+0x8],0x1
     42c:	mov    rbx,QWORD PTR [rsp+0x10]
     431:	mov    r12,QWORD PTR [rsp+0x18]
     436:	mov    r13,QWORD PTR [rsp+0x20]
     43b:	mov    r14,QWORD PTR [rsp+0x28]
     440:	mov    r15,QWORD PTR [rsp+0x30]
     445:	add    rsp,0x40
     449:	mov    rsp,rbp
     44c:	pop    rbp
     44d:	ret
     44e:	mov    r15,rdi
     451:	call   456 <botlish_fn_2+0x1d6>
			452: R_X86_64_PLT32	rt_stack_overflow-0x4
     456:	xor    rax,rax
     459:	mov    rbx,QWORD PTR [rsp+0x10]
     45e:	mov    r12,QWORD PTR [rsp+0x18]
     463:	mov    r13,QWORD PTR [rsp+0x20]
     468:	mov    r14,QWORD PTR [rsp+0x28]
     46d:	mov    r15,QWORD PTR [rsp+0x30]
     472:	add    rsp,0x40
     476:	mov    rsp,rbp
     479:	pop    rbp
     47a:	ret
     47b:	add    BYTE PTR [rax],al
     47d:	add    BYTE PTR [rax],al
     47f:	add    BYTE PTR [rsi],al
     481:	add    BYTE PTR [rax],al
     483:	add    BYTE PTR [rax],al
     485:	add    BYTE PTR [rax],al
	...

0000000000000488 <botlish_entry_2: peek<str, int>>:
     488:	push   rbp
     489:	mov    rbp,rsp
     48c:	ud2

000000000000048e <botlish_fn_3: scan_unquoted<str, int, int>>:
     48e:	push   rbp
     48f:	mov    rbp,rsp
     492:	sub    rsp,0x60
     496:	mov    QWORD PTR [rsp+0x30],rbx
     49b:	mov    QWORD PTR [rsp+0x38],r12
     4a0:	mov    QWORD PTR [rsp+0x40],r13
     4a5:	mov    QWORD PTR [rsp+0x48],r14
     4aa:	mov    QWORD PTR [rsp+0x50],r15
     4af:	mov    r14,QWORD PTR [rdi]
     4b2:	mov    rax,QWORD PTR [rdi+0x8]
     4b6:	lea    r8,[r14+0x20]
     4ba:	cmp    r8,rax
     4bd:	ja     6e5 <botlish_fn_3+0x257>
     4c3:	lea    rax,[r14+0x20]
     4c7:	mov    QWORD PTR [rdi],rax
     4ca:	mov    r15,rdi
     4cd:	mov    QWORD PTR [r14],0x0
     4d4:	mov    QWORD PTR [r14+0x8],0x0
     4dc:	mov    QWORD PTR [r14+0x10],0x0
     4e4:	mov    QWORD PTR [r14+0x18],0x0
     4ec:	mov    QWORD PTR [r14],rsi
     4ef:	mov    QWORD PTR [rsp+0x10],rsi
     4f4:	mov    QWORD PTR [r14+0x8],rdx
     4f8:	mov    QWORD PTR [rsp+0x18],rdx
     4fd:	mov    QWORD PTR [r14+0x10],rcx
     501:	lea    rbx,[rsp]
     505:	mov    QWORD PTR [rsp+0x20],rcx
     50a:	mov    rcx,rbx
     50d:	mov    rdx,QWORD PTR [rsp+0x20]
     512:	mov    rsi,QWORD PTR [rsp+0x10]
     517:	mov    rdi,r15
     51a:	call   51f <botlish_fn_3+0x91>
			51b: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     51f:	mov    rcx,rax
     522:	mov    QWORD PTR [rsp+0x28],rax
     527:	test   rax,rcx
     52a:	jne    538 <botlish_fn_3+0xaa>
     530:	mov    rdi,r15
     533:	jmp    68a <botlish_fn_3+0x1fc>
     538:	mov    r12,QWORD PTR [rsp]
     53c:	mov    r13,QWORD PTR [rsp+0x8]
     541:	mov    rdi,r15
     544:	mov    rcx,QWORD PTR [rdi+0x10]
     548:	mov    r8,QWORD PTR [rcx+0x8]
     54c:	mov    rcx,r13
     54f:	mov    rdx,r12
     552:	mov    rsi,QWORD PTR [rsp+0x28]
     557:	call   55c <botlish_fn_3+0xce>
			558: R_X86_64_PLT32	rt_str_region_eq-0x4
     55c:	cmp    rax,0x6
     560:	je     59f <botlish_fn_3+0x111>
     566:	mov    rdi,r15
     569:	mov    rax,QWORD PTR [rdi+0x10]
     56d:	mov    r8,QWORD PTR [rax+0x10]
     571:	mov    rcx,r13
     574:	mov    rdx,r12
     577:	mov    rsi,QWORD PTR [rsp+0x28]
     57c:	call   581 <botlish_fn_3+0xf3>
			57d: R_X86_64_PLT32	rt_str_region_eq-0x4
     581:	cmp    rax,0x6
     585:	je     595 <botlish_fn_3+0x107>
     58b:	mov    eax,0x2
     590:	jmp    5a4 <botlish_fn_3+0x116>
     595:	mov    eax,0x6
     59a:	jmp    5a4 <botlish_fn_3+0x116>
     59f:	mov    eax,0x6
     5a4:	cmp    rax,0x6
     5a8:	je     5e7 <botlish_fn_3+0x159>
     5ae:	mov    rdi,r15
     5b1:	mov    rsi,QWORD PTR [rdi+0x10]
     5b5:	mov    r8,QWORD PTR [rsi+0x18]
     5b9:	mov    rcx,r13
     5bc:	mov    rdx,r12
     5bf:	mov    rsi,QWORD PTR [rsp+0x28]
     5c4:	call   5c9 <botlish_fn_3+0x13b>
			5c5: R_X86_64_PLT32	rt_str_region_eq-0x4
     5c9:	cmp    rax,0x6
     5cd:	je     5dd <botlish_fn_3+0x14f>
     5d3:	mov    eax,0x2
     5d8:	jmp    5ec <botlish_fn_3+0x15e>
     5dd:	mov    eax,0x6
     5e2:	jmp    5ec <botlish_fn_3+0x15e>
     5e7:	mov    eax,0x6
     5ec:	cmp    rax,0x6
     5f0:	je     667 <botlish_fn_3+0x1d9>
     5f6:	mov    QWORD PTR [r14+0x18],0x3
     5fe:	mov    rsi,QWORD PTR [rsp+0x20]
     603:	test   rsi,0x1
     60a:	je     631 <botlish_fn_3+0x1a3>
     610:	mov    rsi,QWORD PTR [rsp+0x20]
     615:	mov    rax,rsi
     618:	add    rax,0x2
     61c:	seto   cl
     61f:	test   cl,cl
     621:	jne    631 <botlish_fn_3+0x1a3>
     627:	mov    rsi,QWORD PTR [rsp+0x10]
     62c:	jmp    648 <botlish_fn_3+0x1ba>
     631:	mov    edx,0x3
     636:	mov    rsi,QWORD PTR [rsp+0x20]
     63b:	mov    rdi,r15
     63e:	call   643 <botlish_fn_3+0x1b5>
			63f: R_X86_64_PLT32	rt_int_add-0x4
     643:	mov    rsi,QWORD PTR [rsp+0x10]
     648:	mov    QWORD PTR [r14],rsi
     64b:	mov    rdx,QWORD PTR [rsp+0x18]
     650:	mov    QWORD PTR [r14+0x8],rdx
     654:	mov    QWORD PTR [r14+0x10],rax
     658:	mov    QWORD PTR [rsp+0x10],rsi
     65d:	mov    QWORD PTR [rsp+0x20],rax
     662:	jmp    50a <botlish_fn_3+0x7c>
     667:	mov    rdx,QWORD PTR [rsp+0x18]
     66c:	mov    rsi,QWORD PTR [rsp+0x10]
     671:	mov    rcx,QWORD PTR [rsp+0x20]
     676:	mov    rdi,r15
     679:	call   67e <botlish_fn_3+0x1f0>
			67a: R_X86_64_PLT32	rt_substr-0x4
     67e:	test   rax,rax
     681:	jne    6b8 <botlish_fn_3+0x22a>
     687:	mov    rdi,r15
     68a:	mov    rdi,r15
     68d:	mov    QWORD PTR [rdi],r14
     690:	xor    rdx,rdx
     693:	mov    rax,rdx
     696:	mov    rbx,QWORD PTR [rsp+0x30]
     69b:	mov    r12,QWORD PTR [rsp+0x38]
     6a0:	mov    r13,QWORD PTR [rsp+0x40]
     6a5:	mov    r14,QWORD PTR [rsp+0x48]
     6aa:	mov    r15,QWORD PTR [rsp+0x50]
     6af:	add    rsp,0x60
     6b3:	mov    rsp,rbp
     6b6:	pop    rbp
     6b7:	ret
     6b8:	mov    rdi,r15
     6bb:	mov    QWORD PTR [rdi],r14
     6be:	mov    rdx,QWORD PTR [rsp+0x20]
     6c3:	mov    rbx,QWORD PTR [rsp+0x30]
     6c8:	mov    r12,QWORD PTR [rsp+0x38]
     6cd:	mov    r13,QWORD PTR [rsp+0x40]
     6d2:	mov    r14,QWORD PTR [rsp+0x48]
     6d7:	mov    r15,QWORD PTR [rsp+0x50]
     6dc:	add    rsp,0x60
     6e0:	mov    rsp,rbp
     6e3:	pop    rbp
     6e4:	ret
     6e5:	mov    r15,rdi
     6e8:	call   6ed <botlish_fn_3+0x25f>
			6e9: R_X86_64_PLT32	rt_stack_overflow-0x4
     6ed:	xor    rdx,rdx
     6f0:	mov    rax,rdx
     6f3:	mov    rbx,QWORD PTR [rsp+0x30]
     6f8:	mov    r12,QWORD PTR [rsp+0x38]
     6fd:	mov    r13,QWORD PTR [rsp+0x40]
     702:	mov    r14,QWORD PTR [rsp+0x48]
     707:	mov    r15,QWORD PTR [rsp+0x50]
     70c:	add    rsp,0x60
     710:	mov    rsp,rbp
     713:	pop    rbp
     714:	ret

0000000000000715 <botlish_entry_3: scan_unquoted<str, int, int>>:
     715:	push   rbp
     716:	mov    rbp,rsp
     719:	ud2

000000000000071b <botlish_fn_4: scan_quoted<str, int, str>>:
     71b:	push   rbp
     71c:	mov    rbp,rsp
     71f:	sub    rsp,0x50
     723:	mov    QWORD PTR [rsp+0x20],rbx
     728:	mov    QWORD PTR [rsp+0x28],r12
     72d:	mov    QWORD PTR [rsp+0x30],r13
     732:	mov    QWORD PTR [rsp+0x38],r14
     737:	mov    QWORD PTR [rsp+0x40],r15
     73c:	mov    r13,QWORD PTR [rdi]
     73f:	mov    rax,QWORD PTR [rdi+0x8]
     743:	lea    r8,[r13+0x28]
     747:	cmp    r8,rax
     74a:	ja     a32 <botlish_fn_4+0x317>
     750:	lea    rax,[r13+0x28]
     754:	mov    QWORD PTR [rdi],rax
     757:	mov    r14,rdi
     75a:	mov    QWORD PTR [r13+0x0],0x0
     762:	mov    QWORD PTR [r13+0x8],0x0
     76a:	mov    QWORD PTR [r13+0x10],0x0
     772:	mov    QWORD PTR [r13+0x18],0x0
     77a:	mov    QWORD PTR [r13+0x20],0x0
     782:	mov    QWORD PTR [r13+0x0],rsi
     786:	mov    QWORD PTR [r13+0x8],rdx
     78a:	mov    QWORD PTR [r13+0x10],rcx
     78e:	lea    rbx,[rsp]
     792:	mov    r12,rsi
     795:	mov    r15,rdx
     798:	mov    QWORD PTR [rsp+0x10],rcx
     79d:	mov    rdx,r15
     7a0:	mov    rsi,r12
     7a3:	mov    rdi,r14
     7a6:	call   7ab <botlish_fn_4+0x90>
			7a7: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     7ab:	test   rax,rax
     7ae:	jne    7bc <botlish_fn_4+0xa1>
     7b4:	mov    rdi,r14
     7b7:	jmp    9eb <botlish_fn_4+0x2d0>
     7bc:	mov    QWORD PTR [r13+0x18],rax
     7c0:	mov    rdi,r14
     7c3:	mov    QWORD PTR [rsp+0x18],rax
     7c8:	mov    rsi,QWORD PTR [rdi+0x10]
     7cc:	mov    rsi,QWORD PTR [rsi+0x20]
     7d0:	mov    edx,0x1
     7d5:	mov    ecx,0x3
     7da:	mov    r8,QWORD PTR [rsp+0x18]
     7df:	call   7e4 <botlish_fn_4+0xc9>
			7e0: R_X86_64_PLT32	rt_str_region_eq-0x4
     7e4:	cmp    rax,0x6
     7e8:	je     873 <botlish_fn_4+0x158>
     7ee:	mov    QWORD PTR [r13+0x20],0x3
     7f6:	mov    rsi,r15
     7f9:	test   rsi,0x1
     800:	je     820 <botlish_fn_4+0x105>
     806:	mov    r11,rsi
     809:	add    r11,0x2
     80d:	seto   al
     810:	test   al,al
     812:	jne    820 <botlish_fn_4+0x105>
     818:	mov    rsi,r11
     81b:	jmp    830 <botlish_fn_4+0x115>
     820:	mov    edx,0x3
     825:	mov    rdi,r14
     828:	call   82d <botlish_fn_4+0x112>
			829: R_X86_64_PLT32	rt_int_add-0x4
     82d:	mov    rsi,rax
     830:	mov    QWORD PTR [r13+0x8],rsi
     834:	mov    r15,rsi
     837:	mov    rsi,QWORD PTR [rsp+0x10]
     83c:	mov    rdx,QWORD PTR [rsp+0x18]
     841:	mov    rdi,r14
     844:	call   849 <botlish_fn_4+0x12e>
			845: R_X86_64_PLT32	rt_str_cat-0x4
     849:	test   rax,rax
     84c:	jne    85a <botlish_fn_4+0x13f>
     852:	mov    rdi,r14
     855:	jmp    9eb <botlish_fn_4+0x2d0>
     85a:	mov    QWORD PTR [r13+0x0],r12
     85e:	mov    rsi,r15
     861:	mov    QWORD PTR [r13+0x8],rsi
     865:	mov    QWORD PTR [r13+0x10],rax
     869:	mov    QWORD PTR [rsp+0x10],rax
     86e:	jmp    79d <botlish_fn_4+0x82>
     873:	mov    QWORD PTR [r13+0x18],0x3
     87b:	mov    rsi,r15
     87e:	test   rsi,0x1
     885:	je     8a0 <botlish_fn_4+0x185>
     88b:	mov    rsi,r15
     88e:	mov    rdx,rsi
     891:	add    rdx,0x2
     895:	seto   al
     898:	test   al,al
     89a:	je     8b3 <botlish_fn_4+0x198>
     8a0:	mov    edx,0x3
     8a5:	mov    rsi,r15
     8a8:	mov    rdi,r14
     8ab:	call   8b0 <botlish_fn_4+0x195>
			8ac: R_X86_64_PLT32	rt_int_add-0x4
     8b0:	mov    rdx,rax
     8b3:	mov    QWORD PTR [r13+0x18],rdx
     8b7:	mov    rcx,rbx
     8ba:	mov    rsi,r12
     8bd:	mov    rdi,r14
     8c0:	call   8c5 <botlish_fn_4+0x1aa>
			8c1: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     8c5:	test   rax,rax
     8c8:	mov    rsi,rax
     8cb:	jne    8d9 <botlish_fn_4+0x1be>
     8d1:	mov    rdi,r14
     8d4:	jmp    9eb <botlish_fn_4+0x2d0>
     8d9:	mov    rdx,QWORD PTR [rsp]
     8dd:	mov    rcx,QWORD PTR [rsp+0x8]
     8e2:	mov    rdi,r14
     8e5:	mov    rax,QWORD PTR [rdi+0x10]
     8e9:	mov    r8,QWORD PTR [rax+0x20]
     8ed:	call   8f2 <botlish_fn_4+0x1d7>
			8ee: R_X86_64_PLT32	rt_str_region_eq-0x4
     8f2:	cmp    rax,0x6
     8f6:	je     974 <botlish_fn_4+0x259>
     8fc:	mov    QWORD PTR [r13+0x0],0x3
     904:	mov    rsi,r15
     907:	test   rsi,0x1
     90e:	je     931 <botlish_fn_4+0x216>
     914:	mov    rsi,r15
     917:	mov    rdx,rsi
     91a:	add    rdx,0x2
     91e:	seto   al
     921:	test   al,al
     923:	jne    931 <botlish_fn_4+0x216>
     929:	mov    rdi,r14
     92c:	jmp    947 <botlish_fn_4+0x22c>
     931:	mov    edx,0x3
     936:	mov    rsi,r15
     939:	mov    rdi,r14
     93c:	call   941 <botlish_fn_4+0x226>
			93d: R_X86_64_PLT32	rt_int_add-0x4
     941:	mov    rdx,rax
     944:	mov    rdi,r14
     947:	mov    rdi,r14
     94a:	mov    QWORD PTR [rdi],r13
     94d:	mov    rax,QWORD PTR [rsp+0x10]
     952:	mov    rbx,QWORD PTR [rsp+0x20]
     957:	mov    r12,QWORD PTR [rsp+0x28]
     95c:	mov    r13,QWORD PTR [rsp+0x30]
     961:	mov    r14,QWORD PTR [rsp+0x38]
     966:	mov    r15,QWORD PTR [rsp+0x40]
     96b:	add    rsp,0x50
     96f:	mov    rsp,rbp
     972:	pop    rbp
     973:	ret
     974:	mov    QWORD PTR [r13+0x18],0x5
     97c:	mov    rsi,r15
     97f:	test   rsi,0x1
     986:	je     9ac <botlish_fn_4+0x291>
     98c:	mov    rsi,r15
     98f:	mov    rax,rsi
     992:	add    rax,0x4
     996:	seto   cl
     999:	test   cl,cl
     99b:	jne    9ac <botlish_fn_4+0x291>
     9a1:	mov    rsi,rax
     9a4:	mov    r15,rax
     9a7:	jmp    9c2 <botlish_fn_4+0x2a7>
     9ac:	mov    edx,0x5
     9b1:	mov    rsi,r15
     9b4:	mov    rdi,r14
     9b7:	call   9bc <botlish_fn_4+0x2a1>
			9b8: R_X86_64_PLT32	rt_int_add-0x4
     9bc:	mov    rsi,rax
     9bf:	mov    r15,rax
     9c2:	mov    QWORD PTR [r13+0x8],rsi
     9c6:	mov    rdi,r14
     9c9:	mov    rax,QWORD PTR [rdi+0x10]
     9cd:	mov    rdx,QWORD PTR [rax+0x20]
     9d1:	mov    QWORD PTR [r13+0x18],rdx
     9d5:	mov    rsi,QWORD PTR [rsp+0x10]
     9da:	call   9df <botlish_fn_4+0x2c4>
			9db: R_X86_64_PLT32	rt_str_cat-0x4
     9df:	test   rax,rax
     9e2:	jne    a19 <botlish_fn_4+0x2fe>
     9e8:	mov    rdi,r14
     9eb:	mov    rdi,r14
     9ee:	mov    QWORD PTR [rdi],r13
     9f1:	xor    rdx,rdx
     9f4:	mov    rax,rdx
     9f7:	mov    rbx,QWORD PTR [rsp+0x20]
     9fc:	mov    r12,QWORD PTR [rsp+0x28]
     a01:	mov    r13,QWORD PTR [rsp+0x30]
     a06:	mov    r14,QWORD PTR [rsp+0x38]
     a0b:	mov    r15,QWORD PTR [rsp+0x40]
     a10:	add    rsp,0x50
     a14:	mov    rsp,rbp
     a17:	pop    rbp
     a18:	ret
     a19:	mov    QWORD PTR [r13+0x0],r12
     a1d:	mov    rsi,r15
     a20:	mov    QWORD PTR [r13+0x8],rsi
     a24:	mov    QWORD PTR [r13+0x10],rax
     a28:	mov    QWORD PTR [rsp+0x10],rax
     a2d:	jmp    79d <botlish_fn_4+0x82>
     a32:	mov    r14,rdi
     a35:	call   a3a <botlish_fn_4+0x31f>
			a36: R_X86_64_PLT32	rt_stack_overflow-0x4
     a3a:	xor    rdx,rdx
     a3d:	mov    rax,rdx
     a40:	mov    rbx,QWORD PTR [rsp+0x20]
     a45:	mov    r12,QWORD PTR [rsp+0x28]
     a4a:	mov    r13,QWORD PTR [rsp+0x30]
     a4f:	mov    r14,QWORD PTR [rsp+0x38]
     a54:	mov    r15,QWORD PTR [rsp+0x40]
     a59:	add    rsp,0x50
     a5d:	mov    rsp,rbp
     a60:	pop    rbp
     a61:	ret

0000000000000a62 <botlish_entry_4: scan_quoted<str, int, str>>:
     a62:	push   rbp
     a63:	mov    rbp,rsp
     a66:	ud2

0000000000000a68 <botlish_fn_5: scan_field<str, int>>:
     a68:	push   rbp
     a69:	mov    rbp,rsp
     a6c:	sub    rsp,0x30
     a70:	mov    QWORD PTR [rsp+0x10],rbx
     a75:	mov    QWORD PTR [rsp+0x18],r12
     a7a:	mov    QWORD PTR [rsp+0x20],r13
     a7f:	mov    QWORD PTR [rsp+0x28],r14
     a84:	mov    rbx,QWORD PTR [rdi]
     a87:	mov    rax,QWORD PTR [rdi+0x8]
     a8b:	lea    rcx,[rbx+0x18]
     a8f:	cmp    rcx,rax
     a92:	ja     c04 <botlish_fn_5+0x19c>
     a98:	lea    rax,[rbx+0x18]
     a9c:	mov    QWORD PTR [rdi],rax
     a9f:	mov    r12,rdi
     aa2:	mov    QWORD PTR [rbx],0x0
     aa9:	mov    QWORD PTR [rbx+0x8],0x0
     ab1:	mov    QWORD PTR [rbx+0x10],0x0
     ab9:	mov    QWORD PTR [rbx],rsi
     abc:	mov    r13,rsi
     abf:	mov    QWORD PTR [rbx+0x8],rdx
     ac3:	mov    r14,rdx
     ac6:	lea    rcx,[rsp]
     aca:	mov    rdx,r14
     acd:	mov    rsi,r13
     ad0:	mov    rdi,r12
     ad3:	call   ad8 <botlish_fn_5+0x70>
			ad4: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     ad8:	test   rax,rax
     adb:	mov    rsi,rax
     ade:	jne    aec <botlish_fn_5+0x84>
     ae4:	mov    rdi,r12
     ae7:	jmp    bb8 <botlish_fn_5+0x150>
     aec:	mov    rdx,QWORD PTR [rsp]
     af0:	mov    rcx,QWORD PTR [rsp+0x8]
     af5:	mov    rdi,r12
     af8:	mov    rax,QWORD PTR [rdi+0x10]
     afc:	mov    r8,QWORD PTR [rax+0x20]
     b00:	call   b05 <botlish_fn_5+0x9d>
			b01: R_X86_64_PLT32	rt_str_region_eq-0x4
     b05:	cmp    rax,0x6
     b09:	je     b54 <botlish_fn_5+0xec>
     b0f:	mov    rcx,r14
     b12:	mov    rsi,r13
     b15:	mov    rdi,r12
     b18:	mov    rdx,rcx
     b1b:	call   b20 <botlish_fn_5+0xb8>
			b1c: R_X86_64_PLT32	botlish_fn_3-0x4 ; scan_unquoted<str, int, int>
     b20:	test   rax,rax
     b23:	jne    b31 <botlish_fn_5+0xc9>
     b29:	mov    rdi,r12
     b2c:	jmp    bb8 <botlish_fn_5+0x150>
     b31:	mov    rdi,r12
     b34:	mov    QWORD PTR [rdi],rbx
     b37:	mov    rbx,QWORD PTR [rsp+0x10]
     b3c:	mov    r12,QWORD PTR [rsp+0x18]
     b41:	mov    r13,QWORD PTR [rsp+0x20]
     b46:	mov    r14,QWORD PTR [rsp+0x28]
     b4b:	add    rsp,0x30
     b4f:	mov    rsp,rbp
     b52:	pop    rbp
     b53:	ret
     b54:	mov    QWORD PTR [rbx+0x10],0x3
     b5c:	mov    rdx,r14
     b5f:	test   rdx,0x1
     b66:	je     b7e <botlish_fn_5+0x116>
     b6c:	mov    rdx,r14
     b6f:	add    rdx,0x2
     b73:	seto   al
     b76:	test   al,al
     b78:	je     b91 <botlish_fn_5+0x129>
     b7e:	mov    edx,0x3
     b83:	mov    rsi,r14
     b86:	mov    rdi,r12
     b89:	call   b8e <botlish_fn_5+0x126>
			b8a: R_X86_64_PLT32	rt_int_add-0x4
     b8e:	mov    rdx,rax
     b91:	mov    QWORD PTR [rbx+0x8],rdx
     b95:	mov    rdi,r12
     b98:	mov    rax,QWORD PTR [rdi+0x10]
     b9c:	mov    rcx,QWORD PTR [rax+0x8]
     ba0:	mov    QWORD PTR [rbx+0x10],rcx
     ba4:	mov    rsi,r13
     ba7:	call   bac <botlish_fn_5+0x144>
			ba8: R_X86_64_PLT32	botlish_fn_4-0x4 ; scan_quoted<str, int, str>
     bac:	test   rax,rax
     baf:	jne    be1 <botlish_fn_5+0x179>
     bb5:	mov    rdi,r12
     bb8:	mov    rdi,r12
     bbb:	mov    QWORD PTR [rdi],rbx
     bbe:	xor    rdx,rdx
     bc1:	mov    rax,rdx
     bc4:	mov    rbx,QWORD PTR [rsp+0x10]
     bc9:	mov    r12,QWORD PTR [rsp+0x18]
     bce:	mov    r13,QWORD PTR [rsp+0x20]
     bd3:	mov    r14,QWORD PTR [rsp+0x28]
     bd8:	add    rsp,0x30
     bdc:	mov    rsp,rbp
     bdf:	pop    rbp
     be0:	ret
     be1:	mov    rdi,r12
     be4:	mov    QWORD PTR [rdi],rbx
     be7:	mov    rbx,QWORD PTR [rsp+0x10]
     bec:	mov    r12,QWORD PTR [rsp+0x18]
     bf1:	mov    r13,QWORD PTR [rsp+0x20]
     bf6:	mov    r14,QWORD PTR [rsp+0x28]
     bfb:	add    rsp,0x30
     bff:	mov    rsp,rbp
     c02:	pop    rbp
     c03:	ret
     c04:	mov    r12,rdi
     c07:	call   c0c <botlish_fn_5+0x1a4>
			c08: R_X86_64_PLT32	rt_stack_overflow-0x4
     c0c:	xor    rdx,rdx
     c0f:	mov    rax,rdx
     c12:	mov    rbx,QWORD PTR [rsp+0x10]
     c17:	mov    r12,QWORD PTR [rsp+0x18]
     c1c:	mov    r13,QWORD PTR [rsp+0x20]
     c21:	mov    r14,QWORD PTR [rsp+0x28]
     c26:	add    rsp,0x30
     c2a:	mov    rsp,rbp
     c2d:	pop    rbp
     c2e:	ret

0000000000000c2f <botlish_entry_5: scan_field<str, int>>:
     c2f:	push   rbp
     c30:	mov    rbp,rsp
     c33:	ud2

0000000000000c35 <botlish_fn_6: scan_record<str, int, list<never>>>:
     c35:	push   rbp
     c36:	mov    rbp,rsp
     c39:	sub    rsp,0x60
     c3d:	mov    QWORD PTR [rsp+0x30],rbx
     c42:	mov    QWORD PTR [rsp+0x38],r12
     c47:	mov    QWORD PTR [rsp+0x40],r13
     c4c:	mov    QWORD PTR [rsp+0x48],r14
     c51:	mov    QWORD PTR [rsp+0x50],r15
     c56:	mov    r13,QWORD PTR [rdi]
     c59:	mov    rax,QWORD PTR [rdi+0x8]
     c5d:	lea    r8,[r13+0x20]
     c61:	cmp    r8,rax
     c64:	ja     ee9 <botlish_fn_6+0x2b4>
     c6a:	lea    rax,[r13+0x20]
     c6e:	mov    QWORD PTR [rdi],rax
     c71:	mov    r14,rdi
     c74:	mov    QWORD PTR [r13+0x0],0x0
     c7c:	mov    QWORD PTR [r13+0x8],0x0
     c84:	mov    QWORD PTR [r13+0x10],0x0
     c8c:	mov    QWORD PTR [r13+0x18],0x0
     c94:	mov    QWORD PTR [r13+0x0],rsi
     c98:	mov    QWORD PTR [rsp+0x10],rsi
     c9d:	mov    QWORD PTR [r13+0x8],rdx
     ca1:	mov    QWORD PTR [r13+0x10],rcx
     ca5:	mov    r12,rcx
     ca8:	mov    rsi,QWORD PTR [rsp+0x10]
     cad:	mov    rdi,r14
     cb0:	call   cb5 <botlish_fn_6+0x80>
			cb1: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     cb5:	test   rax,rax
     cb8:	jne    cc6 <botlish_fn_6+0x91>
     cbe:	mov    rdi,r14
     cc1:	jmp    e93 <botlish_fn_6+0x25e>
     cc6:	mov    QWORD PTR [r13+0x8],rax
     cca:	mov    QWORD PTR [r13+0x18],rdx
     cce:	mov    QWORD PTR [rsp+0x20],rdx
     cd3:	mov    rsi,r12
     cd6:	mov    rdx,rax
     cd9:	mov    rdi,r14
     cdc:	call   ce1 <botlish_fn_6+0xac>
			cdd: R_X86_64_PLT32	rt_list_append-0x4
     ce1:	mov    rcx,rax
     ce4:	mov    r15,rax
     ce7:	test   rax,rcx
     cea:	jne    cf8 <botlish_fn_6+0xc3>
     cf0:	mov    rdi,r14
     cf3:	jmp    e93 <botlish_fn_6+0x25e>
     cf8:	mov    rax,r15
     cfb:	mov    QWORD PTR [r13+0x8],rax
     cff:	lea    rcx,[rsp]
     d03:	mov    rdx,QWORD PTR [rsp+0x20]
     d08:	mov    rsi,QWORD PTR [rsp+0x10]
     d0d:	mov    rdi,r14
     d10:	call   d15 <botlish_fn_6+0xe0>
			d11: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     d15:	test   rax,rax
     d18:	mov    QWORD PTR [rsp+0x18],rax
     d1d:	jne    d2b <botlish_fn_6+0xf6>
     d23:	mov    rdi,r14
     d26:	jmp    e93 <botlish_fn_6+0x25e>
     d2b:	mov    rbx,QWORD PTR [rsp]
     d2f:	mov    r12,QWORD PTR [rsp+0x8]
     d34:	mov    rdi,r14
     d37:	mov    rcx,QWORD PTR [rdi+0x10]
     d3b:	mov    r8,QWORD PTR [rcx+0x10]
     d3f:	mov    rcx,r12
     d42:	mov    rdx,rbx
     d45:	mov    rsi,QWORD PTR [rsp+0x18]
     d4a:	call   d4f <botlish_fn_6+0x11a>
			d4b: R_X86_64_PLT32	rt_str_region_eq-0x4
     d4f:	cmp    rax,0x6
     d53:	je     e29 <botlish_fn_6+0x1f4>
     d59:	mov    rdi,r14
     d5c:	mov    rax,QWORD PTR [rdi+0x10]
     d60:	mov    r8,QWORD PTR [rax+0x18]
     d64:	mov    rcx,r12
     d67:	mov    rdx,rbx
     d6a:	mov    rsi,QWORD PTR [rsp+0x18]
     d6f:	call   d74 <botlish_fn_6+0x13f>
			d70: R_X86_64_PLT32	rt_str_region_eq-0x4
     d74:	cmp    rax,0x6
     d78:	je     dae <botlish_fn_6+0x179>
     d7e:	mov    rdi,r14
     d81:	mov    QWORD PTR [rdi],r13
     d84:	mov    rax,r15
     d87:	mov    rdx,QWORD PTR [rsp+0x20]
     d8c:	mov    rbx,QWORD PTR [rsp+0x30]
     d91:	mov    r12,QWORD PTR [rsp+0x38]
     d96:	mov    r13,QWORD PTR [rsp+0x40]
     d9b:	mov    r14,QWORD PTR [rsp+0x48]
     da0:	mov    r15,QWORD PTR [rsp+0x50]
     da5:	add    rsp,0x60
     da9:	mov    rsp,rbp
     dac:	pop    rbp
     dad:	ret
     dae:	mov    QWORD PTR [r13+0x0],0x3
     db6:	mov    rdx,QWORD PTR [rsp+0x20]
     dbb:	test   rdx,0x1
     dc2:	je     de6 <botlish_fn_6+0x1b1>
     dc8:	mov    rdx,QWORD PTR [rsp+0x20]
     dcd:	add    rdx,0x2
     dd1:	seto   r10b
     dd5:	test   r10b,r10b
     dd8:	jne    de6 <botlish_fn_6+0x1b1>
     dde:	mov    rdi,r14
     de1:	jmp    dfe <botlish_fn_6+0x1c9>
     de6:	mov    edx,0x3
     deb:	mov    rsi,QWORD PTR [rsp+0x20]
     df0:	mov    rdi,r14
     df3:	call   df8 <botlish_fn_6+0x1c3>
			df4: R_X86_64_PLT32	rt_int_add-0x4
     df8:	mov    rdx,rax
     dfb:	mov    rdi,r14
     dfe:	mov    rdi,r14
     e01:	mov    QWORD PTR [rdi],r13
     e04:	mov    rax,r15
     e07:	mov    rbx,QWORD PTR [rsp+0x30]
     e0c:	mov    r12,QWORD PTR [rsp+0x38]
     e11:	mov    r13,QWORD PTR [rsp+0x40]
     e16:	mov    r14,QWORD PTR [rsp+0x48]
     e1b:	mov    r15,QWORD PTR [rsp+0x50]
     e20:	add    rsp,0x60
     e24:	mov    rsp,rbp
     e27:	pop    rbp
     e28:	ret
     e29:	mov    rsi,QWORD PTR [rsp+0x20]
     e2e:	mov    edx,0x3
     e33:	mov    r10,rdx
     e36:	mov    QWORD PTR [r13+0x10],0x3
     e3e:	test   rsi,0x1
     e45:	jne    e53 <botlish_fn_6+0x21e>
     e4b:	mov    rdx,r10
     e4e:	jmp    e68 <botlish_fn_6+0x233>
     e53:	mov    rdx,rsi
     e56:	add    rdx,0x2
     e5a:	seto   al
     e5d:	test   al,al
     e5f:	je     e73 <botlish_fn_6+0x23e>
     e65:	mov    rdx,r10
     e68:	mov    rdi,r14
     e6b:	call   e70 <botlish_fn_6+0x23b>
			e6c: R_X86_64_PLT32	rt_int_add-0x4
     e70:	mov    rdx,rax
     e73:	mov    QWORD PTR [r13+0x10],rdx
     e77:	mov    rcx,r15
     e7a:	mov    rsi,QWORD PTR [rsp+0x10]
     e7f:	mov    rdi,r14
     e82:	call   e87 <botlish_fn_6+0x252>
			e83: R_X86_64_PLT32	botlish_fn_7-0x4 ; scan_record<str, int, list<str>>
     e87:	test   rax,rax
     e8a:	jne    ec1 <botlish_fn_6+0x28c>
     e90:	mov    rdi,r14
     e93:	mov    rdi,r14
     e96:	mov    QWORD PTR [rdi],r13
     e99:	xor    rdx,rdx
     e9c:	mov    rax,rdx
     e9f:	mov    rbx,QWORD PTR [rsp+0x30]
     ea4:	mov    r12,QWORD PTR [rsp+0x38]
     ea9:	mov    r13,QWORD PTR [rsp+0x40]
     eae:	mov    r14,QWORD PTR [rsp+0x48]
     eb3:	mov    r15,QWORD PTR [rsp+0x50]
     eb8:	add    rsp,0x60
     ebc:	mov    rsp,rbp
     ebf:	pop    rbp
     ec0:	ret
     ec1:	mov    rdi,r14
     ec4:	mov    QWORD PTR [rdi],r13
     ec7:	mov    rbx,QWORD PTR [rsp+0x30]
     ecc:	mov    r12,QWORD PTR [rsp+0x38]
     ed1:	mov    r13,QWORD PTR [rsp+0x40]
     ed6:	mov    r14,QWORD PTR [rsp+0x48]
     edb:	mov    r15,QWORD PTR [rsp+0x50]
     ee0:	add    rsp,0x60
     ee4:	mov    rsp,rbp
     ee7:	pop    rbp
     ee8:	ret
     ee9:	mov    r14,rdi
     eec:	call   ef1 <botlish_fn_6+0x2bc>
			eed: R_X86_64_PLT32	rt_stack_overflow-0x4
     ef1:	xor    rdx,rdx
     ef4:	mov    rax,rdx
     ef7:	mov    rbx,QWORD PTR [rsp+0x30]
     efc:	mov    r12,QWORD PTR [rsp+0x38]
     f01:	mov    r13,QWORD PTR [rsp+0x40]
     f06:	mov    r14,QWORD PTR [rsp+0x48]
     f0b:	mov    r15,QWORD PTR [rsp+0x50]
     f10:	add    rsp,0x60
     f14:	mov    rsp,rbp
     f17:	pop    rbp
     f18:	ret

0000000000000f19 <botlish_entry_6: scan_record<str, int, list<never>>>:
     f19:	push   rbp
     f1a:	mov    rbp,rsp
     f1d:	ud2

0000000000000f1f <botlish_fn_7: scan_record<str, int, list<str>>>:
     f1f:	push   rbp
     f20:	mov    rbp,rsp
     f23:	sub    rsp,0x60
     f27:	mov    QWORD PTR [rsp+0x30],rbx
     f2c:	mov    QWORD PTR [rsp+0x38],r12
     f31:	mov    QWORD PTR [rsp+0x40],r13
     f36:	mov    QWORD PTR [rsp+0x48],r14
     f3b:	mov    QWORD PTR [rsp+0x50],r15
     f40:	mov    r15,QWORD PTR [rdi]
     f43:	mov    rax,QWORD PTR [rdi+0x8]
     f47:	lea    r8,[r15+0x20]
     f4b:	cmp    r8,rax
     f4e:	ja     11c0 <botlish_fn_7+0x2a1>
     f54:	lea    rax,[r15+0x20]
     f58:	mov    QWORD PTR [rdi],rax
     f5b:	mov    QWORD PTR [rsp+0x10],rdi
     f60:	mov    QWORD PTR [r15],0x0
     f67:	mov    QWORD PTR [r15+0x8],0x0
     f6f:	mov    QWORD PTR [r15+0x10],0x0
     f77:	mov    QWORD PTR [r15+0x18],0x0
     f7f:	mov    QWORD PTR [r15],rsi
     f82:	mov    QWORD PTR [r15+0x8],rdx
     f86:	mov    QWORD PTR [r15+0x10],rcx
     f8a:	lea    rbx,[rsp]
     f8e:	mov    r12,rsi
     f91:	mov    r13,rcx
     f94:	mov    rsi,r12
     f97:	mov    rdi,QWORD PTR [rsp+0x10]
     f9c:	call   fa1 <botlish_fn_7+0x82>
			f9d: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     fa1:	test   rax,rax
     fa4:	jne    fb4 <botlish_fn_7+0x95>
     faa:	mov    rdi,QWORD PTR [rsp+0x10]
     faf:	jmp    101d <botlish_fn_7+0xfe>
     fb4:	mov    QWORD PTR [r15+0x8],rax
     fb8:	mov    r8,rax
     fbb:	mov    QWORD PTR [r15+0x18],rdx
     fbf:	mov    QWORD PTR [rsp+0x28],rdx
     fc4:	mov    rsi,r13
     fc7:	mov    rdx,r8
     fca:	mov    rdi,QWORD PTR [rsp+0x10]
     fcf:	call   fd4 <botlish_fn_7+0xb5>
			fd0: R_X86_64_PLT32	rt_list_append-0x4
     fd4:	test   rax,rax
     fd7:	mov    QWORD PTR [rsp+0x20],rax
     fdc:	jne    fec <botlish_fn_7+0xcd>
     fe2:	mov    rdi,QWORD PTR [rsp+0x10]
     fe7:	jmp    101d <botlish_fn_7+0xfe>
     fec:	mov    rax,QWORD PTR [rsp+0x20]
     ff1:	mov    QWORD PTR [r15+0x8],rax
     ff5:	mov    rcx,rbx
     ff8:	mov    rdx,QWORD PTR [rsp+0x28]
     ffd:	mov    rsi,r12
    1000:	mov    rdi,QWORD PTR [rsp+0x10]
    1005:	call   100a <botlish_fn_7+0xeb>
			1006: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
    100a:	test   rax,rax
    100d:	mov    QWORD PTR [rsp+0x18],rax
    1012:	jne    104d <botlish_fn_7+0x12e>
    1018:	mov    rdi,QWORD PTR [rsp+0x10]
    101d:	mov    rdi,QWORD PTR [rsp+0x10]
    1022:	mov    QWORD PTR [rdi],r15
    1025:	xor    rdx,rdx
    1028:	mov    rax,rdx
    102b:	mov    rbx,QWORD PTR [rsp+0x30]
    1030:	mov    r12,QWORD PTR [rsp+0x38]
    1035:	mov    r13,QWORD PTR [rsp+0x40]
    103a:	mov    r14,QWORD PTR [rsp+0x48]
    103f:	mov    r15,QWORD PTR [rsp+0x50]
    1044:	add    rsp,0x60
    1048:	mov    rsp,rbp
    104b:	pop    rbp
    104c:	ret
    104d:	mov    r13,QWORD PTR [rsp]
    1051:	mov    r14,QWORD PTR [rsp+0x8]
    1056:	mov    rdi,QWORD PTR [rsp+0x10]
    105b:	mov    rcx,QWORD PTR [rdi+0x10]
    105f:	mov    r8,QWORD PTR [rcx+0x10]
    1063:	mov    rcx,r14
    1066:	mov    rdx,r13
    1069:	mov    rsi,QWORD PTR [rsp+0x18]
    106e:	call   1073 <botlish_fn_7+0x154>
			106f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1073:	cmp    rax,0x6
    1077:	je     115a <botlish_fn_7+0x23b>
    107d:	mov    rdi,QWORD PTR [rsp+0x10]
    1082:	mov    rdx,QWORD PTR [rdi+0x10]
    1086:	mov    r8,QWORD PTR [rdx+0x18]
    108a:	mov    rcx,r14
    108d:	mov    rdx,r13
    1090:	mov    rsi,QWORD PTR [rsp+0x18]
    1095:	call   109a <botlish_fn_7+0x17b>
			1096: R_X86_64_PLT32	rt_str_region_eq-0x4
    109a:	cmp    rax,0x6
    109e:	je     10d8 <botlish_fn_7+0x1b9>
    10a4:	mov    rdi,QWORD PTR [rsp+0x10]
    10a9:	mov    QWORD PTR [rdi],r15
    10ac:	mov    rax,QWORD PTR [rsp+0x20]
    10b1:	mov    rdx,QWORD PTR [rsp+0x28]
    10b6:	mov    rbx,QWORD PTR [rsp+0x30]
    10bb:	mov    r12,QWORD PTR [rsp+0x38]
    10c0:	mov    r13,QWORD PTR [rsp+0x40]
    10c5:	mov    r14,QWORD PTR [rsp+0x48]
    10ca:	mov    r15,QWORD PTR [rsp+0x50]
    10cf:	add    rsp,0x60
    10d3:	mov    rsp,rbp
    10d6:	pop    rbp
    10d7:	ret
    10d8:	mov    QWORD PTR [r15],0x3
    10df:	mov    rdx,QWORD PTR [rsp+0x28]
    10e4:	test   rdx,0x1
    10eb:	je     110f <botlish_fn_7+0x1f0>
    10f1:	mov    rdx,QWORD PTR [rsp+0x28]
    10f6:	add    rdx,0x2
    10fa:	seto   al
    10fd:	test   al,al
    10ff:	jne    110f <botlish_fn_7+0x1f0>
    1105:	mov    rdi,QWORD PTR [rsp+0x10]
    110a:	jmp    112b <botlish_fn_7+0x20c>
    110f:	mov    edx,0x3
    1114:	mov    rsi,QWORD PTR [rsp+0x28]
    1119:	mov    rdi,QWORD PTR [rsp+0x10]
    111e:	call   1123 <botlish_fn_7+0x204>
			111f: R_X86_64_PLT32	rt_int_add-0x4
    1123:	mov    rdx,rax
    1126:	mov    rdi,QWORD PTR [rsp+0x10]
    112b:	mov    rdi,QWORD PTR [rsp+0x10]
    1130:	mov    QWORD PTR [rdi],r15
    1133:	mov    rax,QWORD PTR [rsp+0x20]
    1138:	mov    rbx,QWORD PTR [rsp+0x30]
    113d:	mov    r12,QWORD PTR [rsp+0x38]
    1142:	mov    r13,QWORD PTR [rsp+0x40]
    1147:	mov    r14,QWORD PTR [rsp+0x48]
    114c:	mov    r15,QWORD PTR [rsp+0x50]
    1151:	add    rsp,0x60
    1155:	mov    rsp,rbp
    1158:	pop    rbp
    1159:	ret
    115a:	mov    rsi,QWORD PTR [rsp+0x28]
    115f:	mov    edx,0x3
    1164:	mov    rdi,rdx
    1167:	mov    QWORD PTR [r15+0x10],0x3
    116f:	test   rsi,0x1
    1176:	jne    1184 <botlish_fn_7+0x265>
    117c:	mov    rdx,rdi
    117f:	jmp    1199 <botlish_fn_7+0x27a>
    1184:	mov    rdx,rsi
    1187:	add    rdx,0x2
    118b:	seto   al
    118e:	test   al,al
    1190:	je     11a6 <botlish_fn_7+0x287>
    1196:	mov    rdx,rdi
    1199:	mov    rdi,QWORD PTR [rsp+0x10]
    119e:	call   11a3 <botlish_fn_7+0x284>
			119f: R_X86_64_PLT32	rt_int_add-0x4
    11a3:	mov    rdx,rax
    11a6:	mov    QWORD PTR [r15],r12
    11a9:	mov    QWORD PTR [r15+0x8],rdx
    11ad:	mov    rax,QWORD PTR [rsp+0x20]
    11b2:	mov    QWORD PTR [r15+0x10],rax
    11b6:	mov    r13,QWORD PTR [rsp+0x20]
    11bb:	jmp    f94 <botlish_fn_7+0x75>
    11c0:	mov    QWORD PTR [rsp+0x10],rdi
    11c5:	call   11ca <botlish_fn_7+0x2ab>
			11c6: R_X86_64_PLT32	rt_stack_overflow-0x4
    11ca:	xor    rdx,rdx
    11cd:	mov    rax,rdx
    11d0:	mov    rbx,QWORD PTR [rsp+0x30]
    11d5:	mov    r12,QWORD PTR [rsp+0x38]
    11da:	mov    r13,QWORD PTR [rsp+0x40]
    11df:	mov    r14,QWORD PTR [rsp+0x48]
    11e4:	mov    r15,QWORD PTR [rsp+0x50]
    11e9:	add    rsp,0x60
    11ed:	mov    rsp,rbp
    11f0:	pop    rbp
    11f1:	ret

00000000000011f2 <botlish_entry_7: scan_record<str, int, list<str>>>:
    11f2:	push   rbp
    11f3:	mov    rbp,rsp
    11f6:	ud2

00000000000011f8 <botlish_fn_8: scan_records<str, int, list<never>>>:
    11f8:	push   rbp
    11f9:	mov    rbp,rsp
    11fc:	sub    rsp,0x30
    1200:	mov    QWORD PTR [rsp],rbx
    1204:	mov    QWORD PTR [rsp+0x8],r12
    1209:	mov    QWORD PTR [rsp+0x10],r13
    120e:	mov    QWORD PTR [rsp+0x18],r14
    1213:	mov    QWORD PTR [rsp+0x20],r15
    1218:	mov    rbx,QWORD PTR [rdi]
    121b:	mov    rax,QWORD PTR [rdi+0x8]
    121f:	lea    r8,[rbx+0x20]
    1223:	cmp    r8,rax
    1226:	ja     1394 <botlish_fn_8+0x19c>
    122c:	lea    rax,[rbx+0x20]
    1230:	mov    QWORD PTR [rdi],rax
    1233:	mov    r12,rdi
    1236:	mov    QWORD PTR [rbx],0x0
    123d:	mov    QWORD PTR [rbx+0x8],0x0
    1245:	mov    QWORD PTR [rbx+0x10],0x0
    124d:	mov    QWORD PTR [rbx+0x18],0x0
    1255:	mov    QWORD PTR [rbx],rsi
    1258:	mov    r13,rsi
    125b:	mov    QWORD PTR [rbx+0x8],rdx
    125f:	mov    r15,rdx
    1262:	mov    QWORD PTR [rbx+0x10],rcx
    1266:	mov    r14,rcx
    1269:	mov    rsi,r13
    126c:	mov    rdi,r12
    126f:	call   1274 <botlish_fn_8+0x7c>
			1270: R_X86_64_PLT32	rt_str_len-0x4
    1274:	mov    rdx,r15
    1277:	mov    rcx,rdx
    127a:	sar    rcx,1
    127d:	sar    rax,1
    1280:	cmp    rcx,rax
    1283:	jge    136a <botlish_fn_8+0x172>
    1289:	xor    rdx,rdx
    128c:	mov    rdi,r12
    128f:	mov    rsi,rdx
    1292:	call   1297 <botlish_fn_8+0x9f>
			1293: R_X86_64_PLT32	rt_list_new-0x4
    1297:	test   rax,rax
    129a:	jne    12a8 <botlish_fn_8+0xb0>
    12a0:	mov    rdi,r12
    12a3:	jmp    1319 <botlish_fn_8+0x121>
    12a8:	mov    QWORD PTR [rbx+0x18],rax
    12ac:	mov    rcx,rax
    12af:	mov    rdx,r15
    12b2:	mov    rsi,r13
    12b5:	mov    rdi,r12
    12b8:	call   12bd <botlish_fn_8+0xc5>
			12b9: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, list<never>>
    12bd:	test   rax,rax
    12c0:	jne    12ce <botlish_fn_8+0xd6>
    12c6:	mov    rdi,r12
    12c9:	jmp    1319 <botlish_fn_8+0x121>
    12ce:	mov    QWORD PTR [rbx+0x8],rax
    12d2:	mov    QWORD PTR [rbx+0x18],rdx
    12d6:	mov    rsi,r14
    12d9:	mov    r14,rdx
    12dc:	mov    rdx,rax
    12df:	mov    rdi,r12
    12e2:	call   12e7 <botlish_fn_8+0xef>
			12e3: R_X86_64_PLT32	rt_list_append-0x4
    12e7:	test   rax,rax
    12ea:	jne    12f8 <botlish_fn_8+0x100>
    12f0:	mov    rdi,r12
    12f3:	jmp    1319 <botlish_fn_8+0x121>
    12f8:	mov    QWORD PTR [rbx+0x8],rax
    12fc:	mov    rcx,rax
    12ff:	mov    rdx,r14
    1302:	mov    rsi,r13
    1305:	mov    rdi,r12
    1308:	call   130d <botlish_fn_8+0x115>
			1309: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, list<list<str>>>
    130d:	test   rax,rax
    1310:	jne    1343 <botlish_fn_8+0x14b>
    1316:	mov    rdi,r12
    1319:	mov    rdi,r12
    131c:	mov    QWORD PTR [rdi],rbx
    131f:	xor    rax,rax
    1322:	mov    rbx,QWORD PTR [rsp]
    1326:	mov    r12,QWORD PTR [rsp+0x8]
    132b:	mov    r13,QWORD PTR [rsp+0x10]
    1330:	mov    r14,QWORD PTR [rsp+0x18]
    1335:	mov    r15,QWORD PTR [rsp+0x20]
    133a:	add    rsp,0x30
    133e:	mov    rsp,rbp
    1341:	pop    rbp
    1342:	ret
    1343:	mov    rdi,r12
    1346:	mov    QWORD PTR [rdi],rbx
    1349:	mov    rbx,QWORD PTR [rsp]
    134d:	mov    r12,QWORD PTR [rsp+0x8]
    1352:	mov    r13,QWORD PTR [rsp+0x10]
    1357:	mov    r14,QWORD PTR [rsp+0x18]
    135c:	mov    r15,QWORD PTR [rsp+0x20]
    1361:	add    rsp,0x30
    1365:	mov    rsp,rbp
    1368:	pop    rbp
    1369:	ret
    136a:	mov    rdi,r12
    136d:	mov    QWORD PTR [rdi],rbx
    1370:	mov    rax,r14
    1373:	mov    rbx,QWORD PTR [rsp]
    1377:	mov    r12,QWORD PTR [rsp+0x8]
    137c:	mov    r13,QWORD PTR [rsp+0x10]
    1381:	mov    r14,QWORD PTR [rsp+0x18]
    1386:	mov    r15,QWORD PTR [rsp+0x20]
    138b:	add    rsp,0x30
    138f:	mov    rsp,rbp
    1392:	pop    rbp
    1393:	ret
    1394:	mov    r12,rdi
    1397:	call   139c <botlish_fn_8+0x1a4>
			1398: R_X86_64_PLT32	rt_stack_overflow-0x4
    139c:	xor    rax,rax
    139f:	mov    rbx,QWORD PTR [rsp]
    13a3:	mov    r12,QWORD PTR [rsp+0x8]
    13a8:	mov    r13,QWORD PTR [rsp+0x10]
    13ad:	mov    r14,QWORD PTR [rsp+0x18]
    13b2:	mov    r15,QWORD PTR [rsp+0x20]
    13b7:	add    rsp,0x30
    13bb:	mov    rsp,rbp
    13be:	pop    rbp
    13bf:	ret

00000000000013c0 <botlish_entry_8: scan_records<str, int, list<never>>>:
    13c0:	push   rbp
    13c1:	mov    rbp,rsp
    13c4:	mov    rsi,QWORD PTR [rdx]
    13c7:	mov    r8,QWORD PTR [rdx+0x8]
    13cb:	mov    rcx,QWORD PTR [rdx+0x10]
    13cf:	mov    rdx,r8
    13d2:	call   13d7 <botlish_entry_8+0x17>
			13d3: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, list<never>>
    13d7:	mov    rsp,rbp
    13da:	pop    rbp
    13db:	ret
    13dc:	add    BYTE PTR [rax],al
	...

00000000000013e0 <botlish_fn_9: scan_records<str, int, list<list<str>>>>:
    13e0:	push   rbp
    13e1:	mov    rbp,rsp
    13e4:	sub    rsp,0x30
    13e8:	mov    QWORD PTR [rsp],rbx
    13ec:	mov    QWORD PTR [rsp+0x8],r12
    13f1:	mov    QWORD PTR [rsp+0x10],r13
    13f6:	mov    QWORD PTR [rsp+0x18],r14
    13fb:	mov    QWORD PTR [rsp+0x20],r15
    1400:	mov    r12,QWORD PTR [rdi]
    1403:	mov    rax,QWORD PTR [rdi+0x8]
    1407:	lea    r8,[r12+0x20]
    140c:	cmp    r8,rax
    140f:	ja     1592 <botlish_fn_9+0x1b2>
    1415:	lea    rax,[r12+0x20]
    141a:	mov    QWORD PTR [rdi],rax
    141d:	mov    r14,rdi
    1420:	mov    QWORD PTR [r12],0x0
    1428:	mov    QWORD PTR [r12+0x8],0x0
    1431:	mov    QWORD PTR [r12+0x10],0x0
    143a:	mov    QWORD PTR [r12+0x18],0x0
    1443:	mov    QWORD PTR [r12],rsi
    1447:	mov    QWORD PTR [r12+0x8],rdx
    144c:	mov    r13,rdx
    144f:	mov    QWORD PTR [r12+0x10],rcx
    1454:	mov    rbx,rsi
    1457:	mov    r15,rcx
    145a:	mov    rsi,rbx
    145d:	mov    rdi,r14
    1460:	call   1465 <botlish_fn_9+0x85>
			1461: R_X86_64_PLT32	rt_str_len-0x4
    1465:	mov    rcx,r13
    1468:	and    rcx,rax
    146b:	mov    rdx,rax
    146e:	test   rcx,0x1
    1475:	jne    149b <botlish_fn_9+0xbb>
    147b:	mov    rsi,r13
    147e:	mov    rdi,r14
    1481:	call   1486 <botlish_fn_9+0xa6>
			1482: R_X86_64_PLT32	rt_int_cmp-0x4
    1486:	mov    ecx,0x2
    148b:	test   rax,rax
    148e:	cmovge rcx,QWORD PTR [rip+0x12a]        # 15c0 <botlish_fn_9+0x1e0>
    1496:	jmp    14ae <botlish_fn_9+0xce>
    149b:	mov    ecx,0x2
    14a0:	mov    rsi,r13
    14a3:	cmp    rsi,rdx
    14a6:	cmovge rcx,QWORD PTR [rip+0x112]        # 15c0 <botlish_fn_9+0x1e0>
    14ae:	cmp    rcx,0x6
    14b2:	je     1568 <botlish_fn_9+0x188>
    14b8:	xor    rdx,rdx
    14bb:	mov    rdi,r14
    14be:	mov    rsi,rdx
    14c1:	call   14c6 <botlish_fn_9+0xe6>
			14c2: R_X86_64_PLT32	rt_list_new-0x4
    14c6:	test   rax,rax
    14c9:	jne    14d7 <botlish_fn_9+0xf7>
    14cf:	mov    rdi,r14
    14d2:	jmp    1525 <botlish_fn_9+0x145>
    14d7:	mov    QWORD PTR [r12+0x18],rax
    14dc:	mov    rcx,rax
    14df:	mov    rdx,r13
    14e2:	mov    rsi,rbx
    14e5:	mov    rdi,r14
    14e8:	call   14ed <botlish_fn_9+0x10d>
			14e9: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, list<never>>
    14ed:	test   rax,rax
    14f0:	jne    14fe <botlish_fn_9+0x11e>
    14f6:	mov    rdi,r14
    14f9:	jmp    1525 <botlish_fn_9+0x145>
    14fe:	mov    QWORD PTR [r12+0x8],rax
    1503:	mov    QWORD PTR [r12+0x18],rdx
    1508:	mov    r13,rdx
    150b:	mov    rsi,r15
    150e:	mov    rdx,rax
    1511:	mov    rdi,r14
    1514:	call   1519 <botlish_fn_9+0x139>
			1515: R_X86_64_PLT32	rt_list_append-0x4
    1519:	test   rax,rax
    151c:	jne    154f <botlish_fn_9+0x16f>
    1522:	mov    rdi,r14
    1525:	mov    rdi,r14
    1528:	mov    QWORD PTR [rdi],r12
    152b:	xor    rax,rax
    152e:	mov    rbx,QWORD PTR [rsp]
    1532:	mov    r12,QWORD PTR [rsp+0x8]
    1537:	mov    r13,QWORD PTR [rsp+0x10]
    153c:	mov    r14,QWORD PTR [rsp+0x18]
    1541:	mov    r15,QWORD PTR [rsp+0x20]
    1546:	add    rsp,0x30
    154a:	mov    rsp,rbp
    154d:	pop    rbp
    154e:	ret
    154f:	mov    QWORD PTR [r12],rbx
    1553:	mov    rdx,r13
    1556:	mov    QWORD PTR [r12+0x8],rdx
    155b:	mov    QWORD PTR [r12+0x10],rax
    1560:	mov    r15,rax
    1563:	jmp    145a <botlish_fn_9+0x7a>
    1568:	mov    rdi,r14
    156b:	mov    QWORD PTR [rdi],r12
    156e:	mov    rax,r15
    1571:	mov    rbx,QWORD PTR [rsp]
    1575:	mov    r12,QWORD PTR [rsp+0x8]
    157a:	mov    r13,QWORD PTR [rsp+0x10]
    157f:	mov    r14,QWORD PTR [rsp+0x18]
    1584:	mov    r15,QWORD PTR [rsp+0x20]
    1589:	add    rsp,0x30
    158d:	mov    rsp,rbp
    1590:	pop    rbp
    1591:	ret
    1592:	mov    r14,rdi
    1595:	call   159a <botlish_fn_9+0x1ba>
			1596: R_X86_64_PLT32	rt_stack_overflow-0x4
    159a:	xor    rax,rax
    159d:	mov    rbx,QWORD PTR [rsp]
    15a1:	mov    r12,QWORD PTR [rsp+0x8]
    15a6:	mov    r13,QWORD PTR [rsp+0x10]
    15ab:	mov    r14,QWORD PTR [rsp+0x18]
    15b0:	mov    r15,QWORD PTR [rsp+0x20]
    15b5:	add    rsp,0x30
    15b9:	mov    rsp,rbp
    15bc:	pop    rbp
    15bd:	ret
    15be:	add    BYTE PTR [rax],al
    15c0:	(bad)
    15c1:	add    BYTE PTR [rax],al
    15c3:	add    BYTE PTR [rax],al
    15c5:	add    BYTE PTR [rax],al
	...

00000000000015c8 <botlish_entry_9: scan_records<str, int, list<list<str>>>>:
    15c8:	push   rbp
    15c9:	mov    rbp,rsp
    15cc:	mov    rsi,QWORD PTR [rdx]
    15cf:	mov    r8,QWORD PTR [rdx+0x8]
    15d3:	mov    rcx,QWORD PTR [rdx+0x10]
    15d7:	mov    rdx,r8
    15da:	call   15df <botlish_entry_9+0x17>
			15db: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, list<list<str>>>
    15df:	mov    rsp,rbp
    15e2:	pop    rbp
    15e3:	ret

00000000000015e4 <botlish_fn_10: csv_parse<str>>:
    15e4:	push   rbp
    15e5:	mov    rbp,rsp
    15e8:	sub    rsp,0x20
    15ec:	mov    QWORD PTR [rsp],rbx
    15f0:	mov    QWORD PTR [rsp+0x8],r12
    15f5:	mov    QWORD PTR [rsp+0x10],r13
    15fa:	mov    rbx,QWORD PTR [rdi]
    15fd:	mov    rax,QWORD PTR [rdi+0x8]
    1601:	lea    rcx,[rbx+0x18]
    1605:	cmp    rcx,rax
    1608:	ja     16bc <botlish_fn_10+0xd8>
    160e:	lea    rax,[rbx+0x18]
    1612:	mov    QWORD PTR [rdi],rax
    1615:	mov    r12,rdi
    1618:	mov    QWORD PTR [rbx],0x0
    161f:	mov    QWORD PTR [rbx+0x8],0x0
    1627:	mov    QWORD PTR [rbx+0x10],0x0
    162f:	mov    QWORD PTR [rbx],rsi
    1632:	mov    r13,rsi
    1635:	mov    QWORD PTR [rbx+0x8],0x1
    163d:	xor    rdx,rdx
    1640:	mov    rdi,r12
    1643:	mov    rsi,rdx
    1646:	call   164b <botlish_fn_10+0x67>
			1647: R_X86_64_PLT32	rt_list_new-0x4
    164b:	test   rax,rax
    164e:	jne    165c <botlish_fn_10+0x78>
    1654:	mov    rdi,r12
    1657:	jmp    167f <botlish_fn_10+0x9b>
    165c:	mov    QWORD PTR [rbx+0x10],rax
    1660:	mov    rcx,rax
    1663:	mov    edx,0x1
    1668:	mov    rsi,r13
    166b:	mov    rdi,r12
    166e:	call   1673 <botlish_fn_10+0x8f>
			166f: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, list<never>>
    1673:	test   rax,rax
    1676:	jne    169f <botlish_fn_10+0xbb>
    167c:	mov    rdi,r12
    167f:	mov    rdi,r12
    1682:	mov    QWORD PTR [rdi],rbx
    1685:	xor    rax,rax
    1688:	mov    rbx,QWORD PTR [rsp]
    168c:	mov    r12,QWORD PTR [rsp+0x8]
    1691:	mov    r13,QWORD PTR [rsp+0x10]
    1696:	add    rsp,0x20
    169a:	mov    rsp,rbp
    169d:	pop    rbp
    169e:	ret
    169f:	mov    rdi,r12
    16a2:	mov    QWORD PTR [rdi],rbx
    16a5:	mov    rbx,QWORD PTR [rsp]
    16a9:	mov    r12,QWORD PTR [rsp+0x8]
    16ae:	mov    r13,QWORD PTR [rsp+0x10]
    16b3:	add    rsp,0x20
    16b7:	mov    rsp,rbp
    16ba:	pop    rbp
    16bb:	ret
    16bc:	mov    r12,rdi
    16bf:	call   16c4 <botlish_fn_10+0xe0>
			16c0: R_X86_64_PLT32	rt_stack_overflow-0x4
    16c4:	xor    rax,rax
    16c7:	mov    rbx,QWORD PTR [rsp]
    16cb:	mov    r12,QWORD PTR [rsp+0x8]
    16d0:	mov    r13,QWORD PTR [rsp+0x10]
    16d5:	add    rsp,0x20
    16d9:	mov    rsp,rbp
    16dc:	pop    rbp
    16dd:	ret

00000000000016de <botlish_entry_10: csv_parse<str>>:
    16de:	push   rbp
    16df:	mov    rbp,rsp
    16e2:	mov    rsi,QWORD PTR [rdx]
    16e5:	call   16ea <botlish_entry_10+0xc>
			16e6: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
    16ea:	mov    rsp,rbp
    16ed:	pop    rbp
    16ee:	ret

; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 9490  (per function: 1172 39 289 617 74 74 74 125 125 961 262 222 272 252 552 468 660 155 125 103 453 758 486 828 344)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> char::codepoint<UnicodeChar>
;   botlish_fn_2 / botlish_entry_2 -> byte::from_int<int>
;   botlish_fn_3 / botlish_entry_3 -> byte::set<List[UnicodeChar]>
;   botlish_fn_4 / botlish_entry_4 -> ascii::is_digit<int>
;   botlish_fn_5 / botlish_entry_5 -> ascii::is_upper<int>
;   botlish_fn_6 / botlish_entry_6 -> ascii::is_lower<int>
;   botlish_fn_7 / botlish_entry_7 -> ascii::is_alphabetic<int>
;   botlish_fn_8 / botlish_entry_8 -> ascii::is_alphanumeric<int>
;   botlish_fn_9 / botlish_entry_9 -> web::is_emailish<str>
;   botlish_fn_10 / botlish_entry_10 -> char_at<generic>
;   botlish_fn_11 / botlish_entry_11 -> char_at<generic>
;   botlish_fn_12 / botlish_entry_12 -> is_local_char<generic>
;   botlish_fn_13 / botlish_entry_13 -> is_label_char<generic>
;   botlish_fn_14 / botlish_entry_14 -> scan_while<generic>
;   botlish_fn_15 / botlish_entry_15 -> tld_ok<generic>
;   botlish_fn_16 / botlish_entry_16 -> domain_loop<generic>
;   botlish_fn_17 / botlish_entry_17 -> web::is_unreserved<generic>
;   botlish_fn_18 / botlish_entry_18 -> web::uri_escape_text<generic>
;   botlish_fn_19 / botlish_entry_19 -> high_nibble<generic>
;   botlish_fn_20 / botlish_entry_20 -> hex_pair<generic>
;   botlish_fn_21 / botlish_entry_21 -> esc_bytes<generic>
;   botlish_fn_22 / botlish_entry_22 -> esc_char<generic>
;   botlish_fn_23 / botlish_entry_23 -> esc_from<generic>
;   botlish_fn_24 / botlish_entry_24 -> check<int, int, str, str>


refined-checks.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x1a0
       b:	mov    QWORD PTR [rsp+0x170],rbx
      13:	mov    QWORD PTR [rsp+0x178],r12
      1b:	mov    QWORD PTR [rsp+0x180],r13
      23:	mov    QWORD PTR [rsp+0x188],r14
      2b:	mov    QWORD PTR [rsp+0x190],r15
      33:	mov    rsi,QWORD PTR [rdi+0x10]
      37:	mov    r8,QWORD PTR [rsi]
      3a:	mov    QWORD PTR [rsp],r8
      3e:	mov    QWORD PTR [rsp+0x168],r8
      46:	mov    r8,QWORD PTR [rdi+0x10]
      4a:	mov    r9,QWORD PTR [r8+0x8]
      4e:	mov    QWORD PTR [rsp+0x8],r9
      53:	mov    QWORD PTR [rsp+0x160],r9
      5b:	mov    r8,QWORD PTR [rdi+0x10]
      5f:	mov    r10,QWORD PTR [r8+0x10]
      63:	mov    QWORD PTR [rsp+0x10],r10
      68:	mov    QWORD PTR [rsp+0x158],r10
      70:	mov    r9,QWORD PTR [rdi+0x10]
      74:	mov    r9,QWORD PTR [r9+0x18]
      78:	mov    QWORD PTR [rsp+0x18],r9
      7d:	mov    QWORD PTR [rsp+0x150],r9
      85:	mov    r11,QWORD PTR [rdi+0x10]
      89:	mov    r11,QWORD PTR [r11+0x20]
      8d:	mov    QWORD PTR [rsp+0x20],r11
      92:	mov    rax,QWORD PTR [rdi+0x10]
      96:	mov    rax,QWORD PTR [rax+0x28]
      9a:	mov    QWORD PTR [rsp+0x28],rax
      9f:	mov    rcx,QWORD PTR [rdi+0x10]
      a3:	mov    rcx,QWORD PTR [rcx+0x30]
      a7:	mov    QWORD PTR [rsp+0x30],rcx
      ac:	mov    rdx,QWORD PTR [rdi+0x10]
      b0:	mov    r9,QWORD PTR [rdx+0x38]
      b4:	mov    QWORD PTR [rsp+0x38],r9
      b9:	mov    rdx,QWORD PTR [rdi+0x10]
      bd:	mov    r14,QWORD PTR [rdx+0x40]
      c1:	mov    QWORD PTR [rsp+0x40],r14
      c6:	mov    rdx,QWORD PTR [rdi+0x10]
      ca:	mov    r15,QWORD PTR [rdx+0x48]
      ce:	mov    QWORD PTR [rsp+0x48],r15
      d3:	mov    rdx,QWORD PTR [rdi+0x10]
      d7:	mov    rbx,QWORD PTR [rdx+0x50]
      db:	mov    QWORD PTR [rsp+0x50],rbx
      e0:	mov    rdx,QWORD PTR [rdi+0x10]
      e4:	mov    r12,QWORD PTR [rdx+0x58]
      e8:	mov    QWORD PTR [rsp+0x58],r12
      ed:	mov    rdx,QWORD PTR [rdi+0x10]
      f1:	mov    r13,QWORD PTR [rdx+0x60]
      f5:	mov    QWORD PTR [rsp+0x60],r13
      fa:	mov    rdx,QWORD PTR [rdi+0x10]
      fe:	mov    rsi,QWORD PTR [rdx+0x68]
     102:	mov    QWORD PTR [rsp+0x68],rsi
     107:	mov    rdx,QWORD PTR [rdi+0x10]
     10b:	mov    r8,QWORD PTR [rdx+0x70]
     10f:	mov    QWORD PTR [rsp+0x70],r8
     114:	mov    rdx,QWORD PTR [rdi+0x10]
     118:	mov    QWORD PTR [rsp+0x148],rdi
     120:	mov    rdi,QWORD PTR [rdx+0x78]
     124:	mov    QWORD PTR [rsp+0x78],rdi
     129:	lea    rdx,[rsp+0x80]
     131:	mov    r10,QWORD PTR [rsp+0x168]
     139:	mov    QWORD PTR [rsp+0x80],r10
     141:	mov    r10,QWORD PTR [rsp+0x160]
     149:	mov    QWORD PTR [rsp+0x88],r10
     151:	mov    r10,QWORD PTR [rsp+0x158]
     159:	mov    QWORD PTR [rsp+0x90],r10
     161:	mov    r10,QWORD PTR [rsp+0x150]
     169:	mov    QWORD PTR [rsp+0x98],r10
     171:	mov    QWORD PTR [rsp+0xa0],r11
     179:	mov    QWORD PTR [rsp+0xa8],rax
     181:	mov    QWORD PTR [rsp+0xb0],rcx
     189:	mov    QWORD PTR [rsp+0xb8],r9
     191:	mov    QWORD PTR [rsp+0xc0],r14
     199:	mov    QWORD PTR [rsp+0xc8],r15
     1a1:	mov    QWORD PTR [rsp+0xd0],rbx
     1a9:	mov    QWORD PTR [rsp+0xd8],r12
     1b1:	mov    QWORD PTR [rsp+0xe0],r13
     1b9:	mov    QWORD PTR [rsp+0xe8],rsi
     1c1:	mov    QWORD PTR [rsp+0xf0],r8
     1c9:	mov    QWORD PTR [rsp+0xf8],rdi
     1d1:	mov    esi,0x10
     1d6:	mov    rdi,QWORD PTR [rsp+0x148]
     1de:	call   1e3 <botlish_fn_0+0x1e3>
			1df: R_X86_64_PLT32	rt_list_new-0x4
     1e3:	test   rax,rax
     1e6:	je     3fe <botlish_fn_0+0x3fe>
     1ec:	mov    QWORD PTR [rsp],rax
     1f0:	mov    rbx,rax
     1f3:	mov    QWORD PTR [rsp+0x8],0x16c
     1fc:	mov    QWORD PTR [rsp+0x10],0x174
     205:	mov    QWORD PTR [rsp+0x18],0x2fc
     20e:	mov    QWORD PTR [rsp+0x20],0x3f4
     217:	lea    rdx,[rsp+0x100]
     21f:	mov    QWORD PTR [rsp+0x100],0x16c
     22b:	mov    QWORD PTR [rsp+0x108],0x174
     237:	mov    QWORD PTR [rsp+0x110],0x2fc
     243:	mov    QWORD PTR [rsp+0x118],0x3f4
     24f:	mov    esi,0x4
     254:	mov    rdi,QWORD PTR [rsp+0x148]
     25c:	call   261 <botlish_fn_0+0x261>
			25d: R_X86_64_PLT32	rt_list_new-0x4
     261:	test   rax,rax
     264:	je     3fe <botlish_fn_0+0x3fe>
     26a:	mov    QWORD PTR [rsp+0x8],rax
     26f:	mov    rsi,rax
     272:	mov    rdi,QWORD PTR [rsp+0x148]
     27a:	call   27f <botlish_fn_0+0x27f>
			27b: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::set<List[UnicodeChar]>
     27f:	test   rax,rax
     282:	je     3fe <botlish_fn_0+0x3fe>
     288:	mov    QWORD PTR [rsp+0x8],rax
     28d:	lea    r8,[rsp+0x120]
     295:	mov    QWORD PTR [rsp+0x120],rax
     29d:	mov    esi,0x11
     2a2:	mov    rdx,QWORD PTR [rip+0x0]        # 2a9 <botlish_fn_0+0x2a9>
			2a5: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; web::is_unreserved<generic>
     2a9:	mov    ecx,0x1
     2ae:	mov    rdi,QWORD PTR [rsp+0x148]
     2b6:	call   2bb <botlish_fn_0+0x2bb>
			2b7: R_X86_64_PLT32	rt_closure_new-0x4
     2bb:	mov    QWORD PTR [rsp+0x8],rax
     2c0:	lea    r8,[rsp+0x128]
     2c8:	mov    rcx,rbx
     2cb:	mov    QWORD PTR [rsp+0x128],rcx
     2d3:	mov    QWORD PTR [rsp+0x130],rax
     2db:	mov    esi,0x12
     2e0:	mov    rdx,QWORD PTR [rip+0x0]        # 2e7 <botlish_fn_0+0x2e7>
			2e3: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; web::uri_escape_text<generic>
     2e7:	mov    ecx,0x2
     2ec:	mov    rdi,QWORD PTR [rsp+0x148]
     2f4:	call   2f9 <botlish_fn_0+0x2f9>
			2f5: R_X86_64_PLT32	rt_closure_new-0x4
     2f9:	mov    QWORD PTR [rsp],rax
     2fd:	mov    rdi,QWORD PTR [rsp+0x148]
     305:	mov    rcx,QWORD PTR [rdi+0x10]
     309:	mov    rdx,QWORD PTR [rcx+0x80]
     310:	mov    QWORD PTR [rsp+0x8],rdx
     315:	mov    rsi,rax
     318:	call   31d <botlish_fn_0+0x31d>
			319: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::uri_escape_text<generic>
     31d:	test   rax,rax
     320:	je     3fe <botlish_fn_0+0x3fe>
     326:	mov    QWORD PTR [rsp],rax
     32a:	mov    r15,rax
     32d:	mov    esi,0x321
     332:	mov    QWORD PTR [rsp+0x8],0x321
     33b:	mov    edx,0x1
     340:	mov    QWORD PTR [rsp+0x10],0x1
     349:	mov    rdi,QWORD PTR [rsp+0x148]
     351:	mov    rdi,QWORD PTR [rdi+0x10]
     355:	mov    rcx,QWORD PTR [rdi+0x88]
     35c:	mov    QWORD PTR [rsp+0x18],rcx
     361:	mov    rdi,QWORD PTR [rsp+0x148]
     369:	mov    r8,r15
     36c:	call   371 <botlish_fn_0+0x371>
			36d: R_X86_64_PLT32	botlish_fn_24-0x4 ; check<int, int, str, str>
     371:	mov    rbx,rax
     374:	test   rbx,rbx
     377:	je     3fe <botlish_fn_0+0x3fe>
     37d:	mov    QWORD PTR [rsp+0x8],rbx
     382:	mov    esi,0x321
     387:	mov    QWORD PTR [rsp+0x10],0x321
     390:	mov    edx,0x1
     395:	mov    QWORD PTR [rsp+0x18],0x1
     39e:	mov    rdi,QWORD PTR [rsp+0x148]
     3a6:	mov    rax,QWORD PTR [rdi+0x10]
     3aa:	mov    rcx,QWORD PTR [rax+0x90]
     3b1:	mov    QWORD PTR [rsp+0x20],rcx
     3b6:	mov    r8,r15
     3b9:	call   3be <botlish_fn_0+0x3be>
			3ba: R_X86_64_PLT32	botlish_fn_24-0x4 ; check<int, int, str, str>
     3be:	test   rax,rax
     3c1:	je     3fe <botlish_fn_0+0x3fe>
     3c7:	mov    QWORD PTR [rsp],rax
     3cb:	lea    rdx,[rsp+0x138]
     3d3:	mov    QWORD PTR [rsp+0x138],rbx
     3db:	mov    QWORD PTR [rsp+0x140],rax
     3e3:	mov    esi,0x2
     3e8:	mov    rdi,QWORD PTR [rsp+0x148]
     3f0:	call   3f5 <botlish_fn_0+0x3f5>
			3f1: R_X86_64_PLT32	rt_list_new-0x4
     3f5:	test   rax,rax
     3f8:	jne    435 <botlish_fn_0+0x435>
     3fe:	xor    rax,rax
     401:	mov    rbx,QWORD PTR [rsp+0x170]
     409:	mov    r12,QWORD PTR [rsp+0x178]
     411:	mov    r13,QWORD PTR [rsp+0x180]
     419:	mov    r14,QWORD PTR [rsp+0x188]
     421:	mov    r15,QWORD PTR [rsp+0x190]
     429:	add    rsp,0x1a0
     430:	mov    rsp,rbp
     433:	pop    rbp
     434:	ret
     435:	mov    rbx,QWORD PTR [rsp+0x170]
     43d:	mov    r12,QWORD PTR [rsp+0x178]
     445:	mov    r13,QWORD PTR [rsp+0x180]
     44d:	mov    r14,QWORD PTR [rsp+0x188]
     455:	mov    r15,QWORD PTR [rsp+0x190]
     45d:	add    rsp,0x1a0
     464:	mov    rsp,rbp
     467:	pop    rbp
     468:	ret

0000000000000469 <botlish_entry_0: <program entry>>:
     469:	push   rbp
     46a:	mov    rbp,rsp
     46d:	call   472 <botlish_entry_0+0x9>
			46e: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     472:	mov    rsp,rbp
     475:	pop    rbp
     476:	ret

0000000000000477 <botlish_fn_1: char::codepoint<UnicodeChar>>:
     477:	push   rbp
     478:	mov    rbp,rsp
     47b:	call   480 <botlish_fn_1+0x9>
			47c: R_X86_64_PLT32	rt_char_codepoint-0x4
     480:	mov    rsp,rbp
     483:	pop    rbp
     484:	ret

0000000000000485 <botlish_entry_1: char::codepoint<UnicodeChar>>:
     485:	push   rbp
     486:	mov    rbp,rsp
     489:	mov    rsi,QWORD PTR [rdx]
     48c:	call   491 <botlish_entry_1+0xc>
			48d: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     491:	mov    rsp,rbp
     494:	pop    rbp
     495:	ret
	...

0000000000000498 <botlish_fn_2: byte::from_int<int>>:
     498:	push   rbp
     499:	mov    rbp,rsp
     49c:	sub    rsp,0x10
     4a0:	mov    QWORD PTR [rsp],rbx
     4a4:	mov    QWORD PTR [rsp+0x8],r12
     4a9:	mov    r12,rdi
     4ac:	test   rsi,0x1
     4b3:	mov    rax,rsi
     4b6:	jne    4e5 <botlish_fn_2+0x4d>
     4bc:	mov    edx,0x1
     4c1:	mov    rbx,rax
     4c4:	mov    rsi,rbx
     4c7:	mov    rdi,r12
     4ca:	call   4cf <botlish_fn_2+0x37>
			4cb: R_X86_64_PLT32	rt_int_cmp-0x4
     4cf:	mov    r8d,0x2
     4d5:	test   rax,rax
     4d8:	cmovl  r8,QWORD PTR [rip+0xb0]        # 590 <botlish_fn_2+0xf8>
     4e0:	jmp    4f9 <botlish_fn_2+0x61>
     4e5:	mov    rbx,rax
     4e8:	mov    r8d,0x2
     4ee:	test   rbx,rbx
     4f1:	cmovle r8,QWORD PTR [rip+0x97]        # 590 <botlish_fn_2+0xf8>
     4f9:	test   rbx,0x1
     500:	jne    52b <botlish_fn_2+0x93>
     506:	mov    edx,0x1ff
     50b:	mov    rsi,rbx
     50e:	mov    rdi,r12
     511:	call   516 <botlish_fn_2+0x7e>
			512: R_X86_64_PLT32	rt_int_cmp-0x4
     516:	mov    ecx,0x2
     51b:	test   rax,rax
     51e:	cmovg  rcx,QWORD PTR [rip+0x6a]        # 590 <botlish_fn_2+0xf8>
     526:	jmp    53f <botlish_fn_2+0xa7>
     52b:	mov    ecx,0x2
     530:	cmp    rbx,0x1ff
     537:	cmovg  rcx,QWORD PTR [rip+0x51]        # 590 <botlish_fn_2+0xf8>
     53f:	cmp    rcx,0x6
     543:	je     55e <botlish_fn_2+0xc6>
     549:	mov    rax,rbx
     54c:	mov    rbx,QWORD PTR [rsp]
     550:	mov    r12,QWORD PTR [rsp+0x8]
     555:	add    rsp,0x10
     559:	mov    rsp,rbp
     55c:	pop    rbp
     55d:	ret
     55e:	mov    rdi,r12
     561:	mov    rax,QWORD PTR [rdi+0x10]
     565:	mov    rdx,QWORD PTR [rax+0x98]
     56c:	mov    esi,0x2
     571:	call   576 <botlish_fn_2+0xde>
			572: R_X86_64_PLT32	rt_fail_declared-0x4
     576:	xor    rax,rax
     579:	mov    rbx,QWORD PTR [rsp]
     57d:	mov    r12,QWORD PTR [rsp+0x8]
     582:	add    rsp,0x10
     586:	mov    rsp,rbp
     589:	pop    rbp
     58a:	ret
     58b:	add    BYTE PTR [rax],al
     58d:	add    BYTE PTR [rax],al
     58f:	add    BYTE PTR [rsi],al
     591:	add    BYTE PTR [rax],al
     593:	add    BYTE PTR [rax],al
     595:	add    BYTE PTR [rax],al
	...

0000000000000598 <botlish_entry_2: byte::from_int<int>>:
     598:	push   rbp
     599:	mov    rbp,rsp
     59c:	mov    rsi,QWORD PTR [rdx]
     59f:	call   5a4 <botlish_entry_2+0xc>
			5a0: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     5a4:	mov    rsp,rbp
     5a7:	pop    rbp
     5a8:	ret
     5a9:	add    BYTE PTR [rax],al
     5ab:	add    BYTE PTR [rax],al
     5ad:	add    BYTE PTR [rax],al
	...

00000000000005b0 <botlish_fn_3: byte::set<List[UnicodeChar]>>:
     5b0:	push   rbp
     5b1:	mov    rbp,rsp
     5b4:	sub    rsp,0x60
     5b8:	mov    QWORD PTR [rsp+0x30],rbx
     5bd:	mov    QWORD PTR [rsp+0x38],r12
     5c2:	mov    QWORD PTR [rsp+0x40],r13
     5c7:	mov    QWORD PTR [rsp+0x48],r14
     5cc:	mov    QWORD PTR [rsp+0x50],r15
     5d1:	mov    r13,rdi
     5d4:	mov    QWORD PTR [rsp+0x18],0x0
     5dd:	mov    QWORD PTR [rsp+0x20],0x0
     5e6:	mov    QWORD PTR [rsp],rsi
     5ea:	mov    rbx,rsi
     5ed:	mov    rdi,r13
     5f0:	call   5f5 <botlish_fn_3+0x45>
			5f1: R_X86_64_PLT32	rt_list_len-0x4
     5f5:	mov    QWORD PTR [rsp+0x8],rax
     5fa:	mov    r12,rax
     5fd:	mov    QWORD PTR [rsp+0x10],0x1
     606:	xor    rdx,rdx
     609:	mov    rdi,r13
     60c:	mov    rsi,rdx
     60f:	call   614 <botlish_fn_3+0x64>
			610: R_X86_64_PLT32	rt_list_new-0x4
     614:	test   rax,rax
     617:	je     741 <botlish_fn_3+0x191>
     61d:	mov    esi,0x1
     622:	mov    r14,rsi
     625:	mov    QWORD PTR [rsp+0x10],0x1
     62e:	mov    QWORD PTR [rsp+0x18],rax
     633:	mov    r15,rax
     636:	mov    rax,rsi
     639:	and    rax,r12
     63c:	mov    r14,rsi
     63f:	test   rax,0x1
     645:	jne    66e <botlish_fn_3+0xbe>
     64b:	mov    rdx,r12
     64e:	mov    rsi,r14
     651:	mov    rdi,r13
     654:	call   659 <botlish_fn_3+0xa9>
			655: R_X86_64_PLT32	rt_int_cmp-0x4
     659:	mov    ecx,0x2
     65e:	test   rax,rax
     661:	cmovl  rcx,QWORD PTR [rip+0x16f]        # 7d8 <botlish_fn_3+0x228>
     669:	jmp    681 <botlish_fn_3+0xd1>
     66e:	mov    ecx,0x2
     673:	mov    rsi,r14
     676:	cmp    rsi,r12
     679:	cmovl  rcx,QWORD PTR [rip+0x157]        # 7d8 <botlish_fn_3+0x228>
     681:	cmp    rcx,0x6
     685:	je     6bc <botlish_fn_3+0x10c>
     68b:	mov    rsi,r15
     68e:	mov    QWORD PTR [rsp],rsi
     692:	mov    rdi,r13
     695:	call   69a <botlish_fn_3+0xea>
			696: R_X86_64_PLT32	rt_set_from_list-0x4
     69a:	mov    rbx,QWORD PTR [rsp+0x30]
     69f:	mov    r12,QWORD PTR [rsp+0x38]
     6a4:	mov    r13,QWORD PTR [rsp+0x40]
     6a9:	mov    r14,QWORD PTR [rsp+0x48]
     6ae:	mov    r15,QWORD PTR [rsp+0x50]
     6b3:	add    rsp,0x60
     6b7:	mov    rsp,rbp
     6ba:	pop    rbp
     6bb:	ret
     6bc:	mov    rsi,r14
     6bf:	test   rsi,0x1
     6c6:	je     6e2 <botlish_fn_3+0x132>
     6cc:	mov    rcx,QWORD PTR [rbx+0x8]
     6d0:	mov    rsi,r14
     6d3:	mov    rax,rsi
     6d6:	sar    rax,1
     6d9:	cmp    rax,rcx
     6dc:	jb     701 <botlish_fn_3+0x151>
     6e2:	mov    rdx,r14
     6e5:	mov    rsi,rbx
     6e8:	mov    rdi,r13
     6eb:	call   6f0 <botlish_fn_3+0x140>
			6ec: R_X86_64_PLT32	rt_list_get-0x4
     6f0:	test   rax,rax
     6f3:	je     741 <botlish_fn_3+0x191>
     6f9:	mov    rsi,rax
     6fc:	jmp    709 <botlish_fn_3+0x159>
     701:	mov    rsi,QWORD PTR [rbx+0x10]
     705:	mov    rsi,QWORD PTR [rsi+rax*8]
     709:	mov    rdi,r13
     70c:	call   711 <botlish_fn_3+0x161>
			70d: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     711:	mov    rsi,rax
     714:	mov    rdi,r13
     717:	call   71c <botlish_fn_3+0x16c>
			718: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     71c:	test   rax,rax
     71f:	je     741 <botlish_fn_3+0x191>
     725:	mov    QWORD PTR [rsp+0x20],rax
     72a:	mov    rdx,rax
     72d:	mov    rsi,r15
     730:	mov    rdi,r13
     733:	call   738 <botlish_fn_3+0x188>
			734: R_X86_64_PLT32	rt_list_append-0x4
     738:	test   rax,rax
     73b:	jne    766 <botlish_fn_3+0x1b6>
     741:	xor    rax,rax
     744:	mov    rbx,QWORD PTR [rsp+0x30]
     749:	mov    r12,QWORD PTR [rsp+0x38]
     74e:	mov    r13,QWORD PTR [rsp+0x40]
     753:	mov    r14,QWORD PTR [rsp+0x48]
     758:	mov    r15,QWORD PTR [rsp+0x50]
     75d:	add    rsp,0x60
     761:	mov    rsp,rbp
     764:	pop    rbp
     765:	ret
     766:	mov    QWORD PTR [rsp+0x18],rax
     76b:	mov    r15,rax
     76e:	mov    edx,0x3
     773:	mov    QWORD PTR [rsp+0x20],0x3
     77c:	mov    rsi,r14
     77f:	test   rsi,0x1
     786:	jne    794 <botlish_fn_3+0x1e4>
     78c:	mov    rsi,r14
     78f:	jmp    7bc <botlish_fn_3+0x20c>
     794:	mov    rsi,r14
     797:	mov    rcx,rsi
     79a:	add    rcx,0x2
     79e:	seto   al
     7a1:	test   al,al
     7a3:	je     7b1 <botlish_fn_3+0x201>
     7a9:	mov    rsi,r14
     7ac:	jmp    7bc <botlish_fn_3+0x20c>
     7b1:	mov    rsi,rcx
     7b4:	mov    r14,rcx
     7b7:	jmp    7ca <botlish_fn_3+0x21a>
     7bc:	mov    rdi,r13
     7bf:	call   7c4 <botlish_fn_3+0x214>
			7c0: R_X86_64_PLT32	rt_int_add-0x4
     7c4:	mov    rsi,rax
     7c7:	mov    r14,rax
     7ca:	mov    QWORD PTR [rsp+0x10],rsi
     7cf:	mov    rsi,r14
     7d2:	jmp    636 <botlish_fn_3+0x86>
     7d7:	add    BYTE PTR [rsi],al
     7d9:	add    BYTE PTR [rax],al
     7db:	add    BYTE PTR [rax],al
     7dd:	add    BYTE PTR [rax],al
	...

00000000000007e0 <botlish_entry_3: byte::set<List[UnicodeChar]>>:
     7e0:	push   rbp
     7e1:	mov    rbp,rsp
     7e4:	mov    rsi,QWORD PTR [rdx]
     7e7:	call   7ec <botlish_entry_3+0xc>
			7e8: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::set<List[UnicodeChar]>
     7ec:	mov    rsp,rbp
     7ef:	pop    rbp
     7f0:	ret

00000000000007f1 <botlish_fn_4: ascii::is_digit<int>>:
     7f1:	push   rbp
     7f2:	mov    rbp,rsp
     7f5:	sar    rsi,1
     7f8:	cmp    rsi,0x30
     7fc:	jge    80c <botlish_fn_4+0x1b>
     802:	mov    eax,0x2
     807:	jmp    825 <botlish_fn_4+0x34>
     80c:	cmp    rsi,0x39
     810:	jle    820 <botlish_fn_4+0x2f>
     816:	mov    eax,0x2
     81b:	jmp    825 <botlish_fn_4+0x34>
     820:	mov    eax,0x6
     825:	mov    rsp,rbp
     828:	pop    rbp
     829:	ret

000000000000082a <botlish_entry_4: ascii::is_digit<int>>:
     82a:	push   rbp
     82b:	mov    rbp,rsp
     82e:	mov    rsi,QWORD PTR [rdx]
     831:	call   836 <botlish_entry_4+0xc>
			832: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     836:	mov    rsp,rbp
     839:	pop    rbp
     83a:	ret

000000000000083b <botlish_fn_5: ascii::is_upper<int>>:
     83b:	push   rbp
     83c:	mov    rbp,rsp
     83f:	sar    rsi,1
     842:	cmp    rsi,0x41
     846:	jge    856 <botlish_fn_5+0x1b>
     84c:	mov    eax,0x2
     851:	jmp    86f <botlish_fn_5+0x34>
     856:	cmp    rsi,0x5a
     85a:	jle    86a <botlish_fn_5+0x2f>
     860:	mov    eax,0x2
     865:	jmp    86f <botlish_fn_5+0x34>
     86a:	mov    eax,0x6
     86f:	mov    rsp,rbp
     872:	pop    rbp
     873:	ret

0000000000000874 <botlish_entry_5: ascii::is_upper<int>>:
     874:	push   rbp
     875:	mov    rbp,rsp
     878:	mov    rsi,QWORD PTR [rdx]
     87b:	call   880 <botlish_entry_5+0xc>
			87c: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     880:	mov    rsp,rbp
     883:	pop    rbp
     884:	ret

0000000000000885 <botlish_fn_6: ascii::is_lower<int>>:
     885:	push   rbp
     886:	mov    rbp,rsp
     889:	sar    rsi,1
     88c:	cmp    rsi,0x61
     890:	jge    8a0 <botlish_fn_6+0x1b>
     896:	mov    eax,0x2
     89b:	jmp    8b9 <botlish_fn_6+0x34>
     8a0:	cmp    rsi,0x7a
     8a4:	jle    8b4 <botlish_fn_6+0x2f>
     8aa:	mov    eax,0x2
     8af:	jmp    8b9 <botlish_fn_6+0x34>
     8b4:	mov    eax,0x6
     8b9:	mov    rsp,rbp
     8bc:	pop    rbp
     8bd:	ret

00000000000008be <botlish_entry_6: ascii::is_lower<int>>:
     8be:	push   rbp
     8bf:	mov    rbp,rsp
     8c2:	mov    rsi,QWORD PTR [rdx]
     8c5:	call   8ca <botlish_entry_6+0xc>
			8c6: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     8ca:	mov    rsp,rbp
     8cd:	pop    rbp
     8ce:	ret

00000000000008cf <botlish_fn_7: ascii::is_alphabetic<int>>:
     8cf:	push   rbp
     8d0:	mov    rbp,rsp
     8d3:	sub    rsp,0x10
     8d7:	mov    QWORD PTR [rsp],r12
     8db:	mov    QWORD PTR [rsp+0x8],r14
     8e0:	mov    r12,rsi
     8e3:	mov    r14,rdi
     8e6:	mov    rsi,r12
     8e9:	mov    rdi,r14
     8ec:	call   8f1 <botlish_fn_7+0x22>
			8ed: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     8f1:	cmp    rax,0x6
     8f5:	je     924 <botlish_fn_7+0x55>
     8fb:	mov    rsi,r12
     8fe:	mov    rdi,r14
     901:	call   906 <botlish_fn_7+0x37>
			902: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     906:	cmp    rax,0x6
     90a:	je     91a <botlish_fn_7+0x4b>
     910:	mov    eax,0x2
     915:	jmp    929 <botlish_fn_7+0x5a>
     91a:	mov    eax,0x6
     91f:	jmp    929 <botlish_fn_7+0x5a>
     924:	mov    eax,0x6
     929:	mov    r12,QWORD PTR [rsp]
     92d:	mov    r14,QWORD PTR [rsp+0x8]
     932:	add    rsp,0x10
     936:	mov    rsp,rbp
     939:	pop    rbp
     93a:	ret

000000000000093b <botlish_entry_7: ascii::is_alphabetic<int>>:
     93b:	push   rbp
     93c:	mov    rbp,rsp
     93f:	mov    rsi,QWORD PTR [rdx]
     942:	call   947 <botlish_entry_7+0xc>
			943: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     947:	mov    rsp,rbp
     94a:	pop    rbp
     94b:	ret

000000000000094c <botlish_fn_8: ascii::is_alphanumeric<int>>:
     94c:	push   rbp
     94d:	mov    rbp,rsp
     950:	sub    rsp,0x10
     954:	mov    QWORD PTR [rsp],r12
     958:	mov    QWORD PTR [rsp+0x8],r14
     95d:	mov    r12,rsi
     960:	mov    r14,rdi
     963:	mov    rsi,r12
     966:	mov    rdi,r14
     969:	call   96e <botlish_fn_8+0x22>
			96a: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     96e:	cmp    rax,0x6
     972:	je     9a1 <botlish_fn_8+0x55>
     978:	mov    rsi,r12
     97b:	mov    rdi,r14
     97e:	call   983 <botlish_fn_8+0x37>
			97f: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     983:	cmp    rax,0x6
     987:	je     997 <botlish_fn_8+0x4b>
     98d:	mov    eax,0x2
     992:	jmp    9a6 <botlish_fn_8+0x5a>
     997:	mov    eax,0x6
     99c:	jmp    9a6 <botlish_fn_8+0x5a>
     9a1:	mov    eax,0x6
     9a6:	mov    r12,QWORD PTR [rsp]
     9aa:	mov    r14,QWORD PTR [rsp+0x8]
     9af:	add    rsp,0x10
     9b3:	mov    rsp,rbp
     9b6:	pop    rbp
     9b7:	ret

00000000000009b8 <botlish_entry_8: ascii::is_alphanumeric<int>>:
     9b8:	push   rbp
     9b9:	mov    rbp,rsp
     9bc:	mov    rsi,QWORD PTR [rdx]
     9bf:	call   9c4 <botlish_entry_8+0xc>
			9c0: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
     9c4:	mov    rsp,rbp
     9c7:	pop    rbp
     9c8:	ret
     9c9:	add    BYTE PTR [rax],al
     9cb:	add    BYTE PTR [rax],al
     9cd:	add    BYTE PTR [rax],al
	...

00000000000009d0 <botlish_fn_9: web::is_emailish<str>>:
     9d0:	push   rbp
     9d1:	mov    rbp,rsp
     9d4:	sub    rsp,0xb0
     9db:	mov    QWORD PTR [rsp+0x80],rbx
     9e3:	mov    QWORD PTR [rsp+0x88],r12
     9eb:	mov    QWORD PTR [rsp+0x90],r13
     9f3:	mov    QWORD PTR [rsp+0x98],r14
     9fb:	mov    QWORD PTR [rsp+0xa0],r15
     a03:	mov    r13,rdi
     a06:	mov    QWORD PTR [rsp],rsi
     a0a:	mov    r15,rsi
     a0d:	mov    rsi,r15
     a10:	mov    rdi,r13
     a13:	call   a18 <botlish_fn_9+0x48>
			a14: R_X86_64_PLT32	rt_str_len-0x4
     a18:	mov    r14,rax
     a1b:	mov    QWORD PTR [rsp+0x8],rax
     a20:	mov    rdi,r13
     a23:	mov    rsi,QWORD PTR [rdi+0x10]
     a27:	mov    rsi,QWORD PTR [rsi+0xa0]
     a2e:	mov    QWORD PTR [rsp+0x10],rsi
     a33:	mov    rdi,QWORD PTR [rdi+0x10]
     a37:	mov    rdi,QWORD PTR [rdi+0xa8]
     a3e:	mov    QWORD PTR [rsp+0x18],rdi
     a43:	mov    rax,r13
     a46:	mov    r8,QWORD PTR [rax+0x10]
     a4a:	mov    r8,QWORD PTR [r8+0xb0]
     a51:	mov    QWORD PTR [rsp+0x20],r8
     a56:	mov    r9,QWORD PTR [rax+0x10]
     a5a:	mov    r9,QWORD PTR [r9+0xb8]
     a61:	mov    QWORD PTR [rsp+0x28],r9
     a66:	mov    r10,QWORD PTR [rax+0x10]
     a6a:	mov    r10,QWORD PTR [r10+0xc0]
     a71:	mov    QWORD PTR [rsp+0x30],r10
     a76:	lea    rdx,[rsp+0x38]
     a7b:	mov    QWORD PTR [rsp+0x38],rsi
     a80:	mov    QWORD PTR [rsp+0x40],rdi
     a85:	mov    QWORD PTR [rsp+0x48],r8
     a8a:	mov    QWORD PTR [rsp+0x50],r9
     a8f:	mov    QWORD PTR [rsp+0x58],r10
     a94:	mov    esi,0x5
     a99:	mov    rdi,r13
     a9c:	call   aa1 <botlish_fn_9+0xd1>
			a9d: R_X86_64_PLT32	rt_list_new-0x4
     aa1:	test   rax,rax
     aa4:	je     c66 <botlish_fn_9+0x296>
     aaa:	mov    QWORD PTR [rsp+0x10],rax
     aaf:	mov    rsi,rax
     ab2:	mov    rdi,r13
     ab5:	call   aba <botlish_fn_9+0xea>
			ab6: R_X86_64_PLT32	rt_set_from_list-0x4
     aba:	mov    QWORD PTR [rsp+0x10],rax
     abf:	lea    r8,[rsp+0x60]
     ac4:	mov    QWORD PTR [rsp+0x60],rax
     ac9:	mov    esi,0xc
     ace:	mov    rdx,QWORD PTR [rip+0x0]        # ad5 <botlish_fn_9+0x105>
			ad1: R_X86_64_GOTPCREL	botlish_entry_12-0x4 ; is_local_char<generic>
     ad5:	mov    ebx,0x1
     ada:	mov    rcx,rbx
     add:	mov    rdi,r13
     ae0:	call   ae5 <botlish_fn_9+0x115>
			ae1: R_X86_64_PLT32	rt_closure_new-0x4
     ae5:	mov    QWORD PTR [rsp+0x10],rax
     aea:	mov    QWORD PTR [rsp+0x18],0x1
     af3:	mov    rdx,rax
     af6:	mov    rsi,rbx
     af9:	mov    rcx,r14
     afc:	mov    rdi,r13
     aff:	mov    r8,r15
     b02:	call   b07 <botlish_fn_9+0x137>
			b03: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<generic>
     b07:	mov    r11,rax
     b0a:	mov    r12,rax
     b0d:	test   rax,r11
     b10:	je     c66 <botlish_fn_9+0x296>
     b16:	mov    rax,r12
     b19:	mov    QWORD PTR [rsp+0x10],rax
     b1e:	test   rax,0x1
     b24:	jne    b4f <botlish_fn_9+0x17f>
     b2a:	mov    edx,0x1
     b2f:	mov    rsi,r12
     b32:	mov    rdi,r13
     b35:	call   b3a <botlish_fn_9+0x16a>
			b36: R_X86_64_PLT32	rt_int_cmp-0x4
     b3a:	mov    ecx,0x2
     b3f:	test   rax,rax
     b42:	cmove  rcx,QWORD PTR [rip+0x1ee]        # d38 <botlish_fn_9+0x368>
     b4a:	jmp    b60 <botlish_fn_9+0x190>
     b4f:	mov    ecx,0x2
     b54:	cmp    r12,0x1
     b58:	cmove  rcx,QWORD PTR [rip+0x1d8]        # d38 <botlish_fn_9+0x368>
     b60:	cmp    rcx,0x6
     b64:	je     cfb <botlish_fn_9+0x32b>
     b6a:	mov    rbx,r14
     b6d:	mov    rax,r12
     b70:	and    rax,rbx
     b73:	test   rax,0x1
     b79:	jne    ba2 <botlish_fn_9+0x1d2>
     b7f:	mov    rdx,rbx
     b82:	mov    rsi,r12
     b85:	mov    rdi,r13
     b88:	call   b8d <botlish_fn_9+0x1bd>
			b89: R_X86_64_PLT32	rt_int_cmp-0x4
     b8d:	mov    esi,0x2
     b92:	test   rax,rax
     b95:	cmovge rsi,QWORD PTR [rip+0x19b]        # d38 <botlish_fn_9+0x368>
     b9d:	jmp    bb2 <botlish_fn_9+0x1e2>
     ba2:	mov    esi,0x2
     ba7:	cmp    r12,rbx
     baa:	cmovge rsi,QWORD PTR [rip+0x186]        # d38 <botlish_fn_9+0x368>
     bb2:	cmp    rsi,0x6
     bb6:	je     cf1 <botlish_fn_9+0x321>
     bbc:	lea    rcx,[rsp+0x68]
     bc1:	mov    rdx,r15
     bc4:	mov    rsi,r12
     bc7:	mov    rdi,r13
     bca:	call   bcf <botlish_fn_9+0x1ff>
			bcb: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
     bcf:	test   rax,rax
     bd2:	mov    rsi,rax
     bd5:	je     c66 <botlish_fn_9+0x296>
     bdb:	mov    rdx,QWORD PTR [rsp+0x68]
     be0:	mov    rcx,QWORD PTR [rsp+0x70]
     be5:	mov    rdi,r13
     be8:	mov    rax,QWORD PTR [rdi+0x10]
     bec:	mov    r8,QWORD PTR [rax+0xc8]
     bf3:	call   bf8 <botlish_fn_9+0x228>
			bf4: R_X86_64_PLT32	rt_str_region_eq-0x4
     bf8:	cmp    rax,0x6
     bfc:	je     c0f <botlish_fn_9+0x23f>
     c02:	mov    ecx,0x2
     c07:	mov    rax,rcx
     c0a:	jmp    d00 <botlish_fn_9+0x330>
     c0f:	mov    QWORD PTR [rsp+0x18],0x3
     c18:	test   r12,0x1
     c1f:	je     c37 <botlish_fn_9+0x267>
     c25:	mov    rsi,r12
     c28:	add    rsi,0x2
     c2c:	seto   al
     c2f:	test   al,al
     c31:	je     c4a <botlish_fn_9+0x27a>
     c37:	mov    edx,0x3
     c3c:	mov    rsi,r12
     c3f:	mov    rdi,r13
     c42:	call   c47 <botlish_fn_9+0x277>
			c43: R_X86_64_PLT32	rt_int_add-0x4
     c47:	mov    rsi,rax
     c4a:	mov    QWORD PTR [rsp+0x10],rsi
     c4f:	mov    rcx,r15
     c52:	mov    rdx,rbx
     c55:	mov    rdi,r13
     c58:	call   c5d <botlish_fn_9+0x28d>
			c59: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain_loop<generic>
     c5d:	test   rax,rax
     c60:	jne    c9d <botlish_fn_9+0x2cd>
     c66:	xor    rax,rax
     c69:	mov    rbx,QWORD PTR [rsp+0x80]
     c71:	mov    r12,QWORD PTR [rsp+0x88]
     c79:	mov    r13,QWORD PTR [rsp+0x90]
     c81:	mov    r14,QWORD PTR [rsp+0x98]
     c89:	mov    r15,QWORD PTR [rsp+0xa0]
     c91:	add    rsp,0xb0
     c98:	mov    rsp,rbp
     c9b:	pop    rbp
     c9c:	ret
     c9d:	mov    rcx,rax
     ca0:	and    rcx,rbx
     ca3:	mov    rsi,rax
     ca6:	mov    r14,rbx
     ca9:	test   rcx,0x1
     cb0:	jne    cd9 <botlish_fn_9+0x309>
     cb6:	mov    rdx,r14
     cb9:	mov    rdi,r13
     cbc:	call   cc1 <botlish_fn_9+0x2f1>
			cbd: R_X86_64_PLT32	rt_int_cmp-0x4
     cc1:	mov    ecx,0x2
     cc6:	test   rax,rax
     cc9:	mov    rax,rcx
     ccc:	cmove  rax,QWORD PTR [rip+0x64]        # d38 <botlish_fn_9+0x368>
     cd4:	jmp    d00 <botlish_fn_9+0x330>
     cd9:	mov    rdx,r14
     cdc:	mov    eax,0x2
     ce1:	cmp    rsi,rdx
     ce4:	cmove  rax,QWORD PTR [rip+0x4c]        # d38 <botlish_fn_9+0x368>
     cec:	jmp    d00 <botlish_fn_9+0x330>
     cf1:	mov    eax,0x2
     cf6:	jmp    d00 <botlish_fn_9+0x330>
     cfb:	mov    eax,0x2
     d00:	mov    rbx,QWORD PTR [rsp+0x80]
     d08:	mov    r12,QWORD PTR [rsp+0x88]
     d10:	mov    r13,QWORD PTR [rsp+0x90]
     d18:	mov    r14,QWORD PTR [rsp+0x98]
     d20:	mov    r15,QWORD PTR [rsp+0xa0]
     d28:	add    rsp,0xb0
     d2f:	mov    rsp,rbp
     d32:	pop    rbp
     d33:	ret
     d34:	add    BYTE PTR [rax],al
     d36:	add    BYTE PTR [rax],al
     d38:	(bad)
     d39:	add    BYTE PTR [rax],al
     d3b:	add    BYTE PTR [rax],al
     d3d:	add    BYTE PTR [rax],al
	...

0000000000000d40 <botlish_entry_9: web::is_emailish<str>>:
     d40:	push   rbp
     d41:	mov    rbp,rsp
     d44:	mov    rsi,QWORD PTR [rdx]
     d47:	call   d4c <botlish_entry_9+0xc>
			d48: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_emailish<str>
     d4c:	mov    rsp,rbp
     d4f:	pop    rbp
     d50:	ret

0000000000000d51 <botlish_fn_10: char_at<generic>>:
     d51:	push   rbp
     d52:	mov    rbp,rsp
     d55:	sub    rsp,0x50
     d59:	mov    QWORD PTR [rsp+0x20],rbx
     d5e:	mov    QWORD PTR [rsp+0x28],r12
     d63:	mov    QWORD PTR [rsp+0x30],r13
     d68:	mov    QWORD PTR [rsp+0x38],r14
     d6d:	mov    QWORD PTR [rsp+0x40],r15
     d72:	mov    r12,rdi
     d75:	mov    r15,rcx
     d78:	mov    QWORD PTR [rsp],rsi
     d7c:	mov    QWORD PTR [rsp+0x8],rdx
     d81:	mov    r13,rdx
     d84:	mov    QWORD PTR [rsp+0x10],0x3
     d8d:	test   rsi,0x1
     d94:	jne    da2 <botlish_fn_10+0x51>
     d9a:	mov    rbx,rsi
     d9d:	jmp    dc2 <botlish_fn_10+0x71>
     da2:	mov    rax,rsi
     da5:	add    rax,0x2
     da9:	mov    rbx,rsi
     dac:	seto   cl
     daf:	test   cl,cl
     db1:	jne    dc2 <botlish_fn_10+0x71>
     db7:	mov    rdi,r12
     dba:	mov    r14,rax
     dbd:	jmp    dd8 <botlish_fn_10+0x87>
     dc2:	mov    edx,0x3
     dc7:	mov    rsi,rbx
     dca:	mov    rdi,r12
     dcd:	call   dd2 <botlish_fn_10+0x81>
			dce: R_X86_64_PLT32	rt_int_add-0x4
     dd2:	mov    r14,rax
     dd5:	mov    rdi,r12
     dd8:	mov    rcx,r14
     ddb:	mov    rdx,rbx
     dde:	mov    rsi,r13
     de1:	call   de6 <botlish_fn_10+0x95>
			de2: R_X86_64_PLT32	rt_str_region_check-0x4
     de6:	test   rax,rax
     de9:	jne    e14 <botlish_fn_10+0xc3>
     def:	xor    rax,rax
     df2:	mov    rbx,QWORD PTR [rsp+0x20]
     df7:	mov    r12,QWORD PTR [rsp+0x28]
     dfc:	mov    r13,QWORD PTR [rsp+0x30]
     e01:	mov    r14,QWORD PTR [rsp+0x38]
     e06:	mov    r15,QWORD PTR [rsp+0x40]
     e0b:	add    rsp,0x50
     e0f:	mov    rsp,rbp
     e12:	pop    rbp
     e13:	ret
     e14:	mov    rcx,r15
     e17:	mov    QWORD PTR [rcx],rbx
     e1a:	mov    rax,r14
     e1d:	mov    QWORD PTR [rcx+0x8],rax
     e21:	mov    rax,r13
     e24:	mov    rbx,QWORD PTR [rsp+0x20]
     e29:	mov    r12,QWORD PTR [rsp+0x28]
     e2e:	mov    r13,QWORD PTR [rsp+0x30]
     e33:	mov    r14,QWORD PTR [rsp+0x38]
     e38:	mov    r15,QWORD PTR [rsp+0x40]
     e3d:	add    rsp,0x50
     e41:	mov    rsp,rbp
     e44:	pop    rbp
     e45:	ret

0000000000000e46 <botlish_entry_10: char_at<generic>>:
     e46:	push   rbp
     e47:	mov    rbp,rsp
     e4a:	ud2

0000000000000e4c <botlish_fn_11: char_at<generic>>:
     e4c:	push   rbp
     e4d:	mov    rbp,rsp
     e50:	sub    rsp,0x40
     e54:	mov    QWORD PTR [rsp+0x20],rbx
     e59:	mov    QWORD PTR [rsp+0x28],r12
     e5e:	mov    QWORD PTR [rsp+0x30],r13
     e63:	mov    r12,rdi
     e66:	mov    QWORD PTR [rsp],rsi
     e6a:	mov    QWORD PTR [rsp+0x8],rdx
     e6f:	mov    r13,rdx
     e72:	mov    QWORD PTR [rsp+0x10],0x3
     e7b:	test   rsi,0x1
     e82:	jne    e90 <botlish_fn_11+0x44>
     e88:	mov    rbx,rsi
     e8b:	jmp    ea5 <botlish_fn_11+0x59>
     e90:	mov    rcx,rsi
     e93:	add    rcx,0x2
     e97:	mov    rbx,rsi
     e9a:	seto   al
     e9d:	test   al,al
     e9f:	je     eb8 <botlish_fn_11+0x6c>
     ea5:	mov    edx,0x3
     eaa:	mov    rsi,rbx
     ead:	mov    rdi,r12
     eb0:	call   eb5 <botlish_fn_11+0x69>
			eb1: R_X86_64_PLT32	rt_int_add-0x4
     eb5:	mov    rcx,rax
     eb8:	mov    QWORD PTR [rsp+0x10],rcx
     ebd:	mov    rdx,rbx
     ec0:	mov    rsi,r13
     ec3:	mov    rdi,r12
     ec6:	call   ecb <botlish_fn_11+0x7f>
			ec7: R_X86_64_PLT32	rt_substr-0x4
     ecb:	test   rax,rax
     ece:	jne    eef <botlish_fn_11+0xa3>
     ed4:	xor    rax,rax
     ed7:	mov    rbx,QWORD PTR [rsp+0x20]
     edc:	mov    r12,QWORD PTR [rsp+0x28]
     ee1:	mov    r13,QWORD PTR [rsp+0x30]
     ee6:	add    rsp,0x40
     eea:	mov    rsp,rbp
     eed:	pop    rbp
     eee:	ret
     eef:	mov    rbx,QWORD PTR [rsp+0x20]
     ef4:	mov    r12,QWORD PTR [rsp+0x28]
     ef9:	mov    r13,QWORD PTR [rsp+0x30]
     efe:	add    rsp,0x40
     f02:	mov    rsp,rbp
     f05:	pop    rbp
     f06:	ret

0000000000000f07 <botlish_entry_11: char_at<generic>>:
     f07:	push   rbp
     f08:	mov    rbp,rsp
     f0b:	mov    rsi,QWORD PTR [rdx]
     f0e:	mov    rdx,QWORD PTR [rdx+0x8]
     f12:	call   f17 <botlish_entry_11+0x10>
			f13: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
     f17:	mov    rsp,rbp
     f1a:	pop    rbp
     f1b:	ret

0000000000000f1c <botlish_fn_12: is_local_char<generic>>:
     f1c:	push   rbp
     f1d:	mov    rbp,rsp
     f20:	sub    rsp,0x20
     f24:	mov    QWORD PTR [rsp],rbx
     f28:	mov    QWORD PTR [rsp+0x8],r12
     f2d:	mov    QWORD PTR [rsp+0x10],r13
     f32:	mov    r12,rsi
     f35:	xor    esi,esi
     f37:	test   rdx,0x7
     f3e:	je     f4c <botlish_fn_12+0x30>
     f44:	mov    rbx,rdx
     f47:	jmp    f59 <botlish_fn_12+0x3d>
     f4c:	movzx  rax,BYTE PTR [rdx]
     f50:	mov    rbx,rdx
     f53:	cmp    al,0x2
     f55:	sete   sil
     f59:	test   sil,sil
     f5c:	jne    f7f <botlish_fn_12+0x63>
     f62:	mov    rax,QWORD PTR [rdi+0x10]
     f66:	mov    rcx,QWORD PTR [rax+0xd0]
     f6d:	mov    edx,0x1
     f72:	mov    rsi,rbx
     f75:	call   f7a <botlish_fn_12+0x5e>
			f76: R_X86_64_PLT32	rt_type_error-0x4
     f7a:	jmp    f93 <botlish_fn_12+0x77>
     f7f:	mov    r13,rdi
     f82:	mov    rsi,rbx
     f85:	call   f8a <botlish_fn_12+0x6e>
			f86: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     f8a:	test   rax,rax
     f8d:	jne    fad <botlish_fn_12+0x91>
     f93:	xor    rax,rax
     f96:	mov    rbx,QWORD PTR [rsp]
     f9a:	mov    r12,QWORD PTR [rsp+0x8]
     f9f:	mov    r13,QWORD PTR [rsp+0x10]
     fa4:	add    rsp,0x20
     fa8:	mov    rsp,rbp
     fab:	pop    rbp
     fac:	ret
     fad:	cmp    rax,0x6
     fb1:	je     fea <botlish_fn_12+0xce>
     fb7:	mov    rsi,r12
     fba:	mov    rax,QWORD PTR [rsi+0x20]
     fbe:	mov    rsi,QWORD PTR [rax]
     fc1:	mov    rdx,rbx
     fc4:	mov    rdi,r13
     fc7:	call   fcc <botlish_fn_12+0xb0>
			fc8: R_X86_64_PLT32	rt_set_contains-0x4
     fcc:	cmp    rax,0x6
     fd0:	je     fe0 <botlish_fn_12+0xc4>
     fd6:	mov    eax,0x2
     fdb:	jmp    fef <botlish_fn_12+0xd3>
     fe0:	mov    eax,0x6
     fe5:	jmp    fef <botlish_fn_12+0xd3>
     fea:	mov    eax,0x6
     fef:	mov    rbx,QWORD PTR [rsp]
     ff3:	mov    r12,QWORD PTR [rsp+0x8]
     ff8:	mov    r13,QWORD PTR [rsp+0x10]
     ffd:	add    rsp,0x20
    1001:	mov    rsp,rbp
    1004:	pop    rbp
    1005:	ret

0000000000001006 <botlish_entry_12: is_local_char<generic>>:
    1006:	push   rbp
    1007:	mov    rbp,rsp
    100a:	mov    rdx,QWORD PTR [rdx]
    100d:	call   1012 <botlish_entry_12+0xc>
			100e: R_X86_64_PLT32	botlish_fn_12-0x4 ; is_local_char<generic>
    1012:	mov    rsp,rbp
    1015:	pop    rbp
    1016:	ret

0000000000001017 <botlish_fn_13: is_label_char<generic>>:
    1017:	push   rbp
    1018:	mov    rbp,rsp
    101b:	sub    rsp,0x10
    101f:	mov    QWORD PTR [rsp],rbx
    1023:	mov    QWORD PTR [rsp+0x8],r12
    1028:	xor    r8d,r8d
    102b:	test   rsi,0x7
    1032:	jne    1042 <botlish_fn_13+0x2b>
    1038:	movzx  rax,BYTE PTR [rsi]
    103c:	cmp    al,0x2
    103e:	sete   r8b
    1042:	test   r8b,r8b
    1045:	jne    1065 <botlish_fn_13+0x4e>
    104b:	mov    rax,QWORD PTR [rdi+0x10]
    104f:	mov    rcx,QWORD PTR [rax+0xd0]
    1056:	mov    edx,0x1
    105b:	call   1060 <botlish_fn_13+0x49>
			105c: R_X86_64_PLT32	rt_type_error-0x4
    1060:	jmp    1079 <botlish_fn_13+0x62>
    1065:	mov    rbx,rsi
    1068:	mov    r12,rdi
    106b:	call   1070 <botlish_fn_13+0x59>
			106c: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    1070:	test   rax,rax
    1073:	jne    108e <botlish_fn_13+0x77>
    1079:	xor    rax,rax
    107c:	mov    rbx,QWORD PTR [rsp]
    1080:	mov    r12,QWORD PTR [rsp+0x8]
    1085:	add    rsp,0x10
    1089:	mov    rsp,rbp
    108c:	pop    rbp
    108d:	ret
    108e:	cmp    rax,0x6
    1092:	je     10d6 <botlish_fn_13+0xbf>
    1098:	mov    rdi,r12
    109b:	mov    rax,QWORD PTR [rdi+0x10]
    109f:	mov    rsi,QWORD PTR [rax+0xc0]
    10a6:	mov    edx,0x1
    10ab:	mov    ecx,0x3
    10b0:	mov    r8,rbx
    10b3:	call   10b8 <botlish_fn_13+0xa1>
			10b4: R_X86_64_PLT32	rt_str_region_eq-0x4
    10b8:	cmp    rax,0x6
    10bc:	je     10cc <botlish_fn_13+0xb5>
    10c2:	mov    eax,0x2
    10c7:	jmp    10db <botlish_fn_13+0xc4>
    10cc:	mov    eax,0x6
    10d1:	jmp    10db <botlish_fn_13+0xc4>
    10d6:	mov    eax,0x6
    10db:	mov    rbx,QWORD PTR [rsp]
    10df:	mov    r12,QWORD PTR [rsp+0x8]
    10e4:	add    rsp,0x10
    10e8:	mov    rsp,rbp
    10eb:	pop    rbp
    10ec:	ret

00000000000010ed <botlish_entry_13: is_label_char<generic>>:
    10ed:	push   rbp
    10ee:	mov    rbp,rsp
    10f1:	mov    rsi,QWORD PTR [rdx]
    10f4:	call   10f9 <botlish_entry_13+0xc>
			10f5: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_label_char<generic>
    10f9:	mov    rsp,rbp
    10fc:	pop    rbp
    10fd:	ret
	...

0000000000001100 <botlish_fn_14: scan_while<generic>>:
    1100:	push   rbp
    1101:	mov    rbp,rsp
    1104:	sub    rsp,0x70
    1108:	mov    QWORD PTR [rsp+0x40],rbx
    110d:	mov    QWORD PTR [rsp+0x48],r12
    1112:	mov    QWORD PTR [rsp+0x50],r13
    1117:	mov    QWORD PTR [rsp+0x58],r14
    111c:	mov    QWORD PTR [rsp+0x60],r15
    1121:	mov    QWORD PTR [rsp+0x30],rdi
    1126:	mov    QWORD PTR [rsp+0x20],0x0
    112f:	mov    QWORD PTR [rsp],rsi
    1133:	mov    r15,rsi
    1136:	mov    QWORD PTR [rsp+0x8],rdx
    113b:	mov    r13,rdx
    113e:	mov    QWORD PTR [rsp+0x10],rcx
    1143:	mov    QWORD PTR [rsp+0x18],r8
    1148:	mov    r12,r8
    114b:	lea    r14,[rsp+0x28]
    1150:	mov    rbx,rcx
    1153:	mov    rax,rsi
    1156:	and    rax,rbx
    1159:	mov    r15,rsi
    115c:	test   rax,0x1
    1162:	jne    118d <botlish_fn_14+0x8d>
    1168:	mov    rdx,rbx
    116b:	mov    rsi,r15
    116e:	mov    rdi,QWORD PTR [rsp+0x30]
    1173:	call   1178 <botlish_fn_14+0x78>
			1174: R_X86_64_PLT32	rt_int_cmp-0x4
    1178:	mov    ecx,0x2
    117d:	test   rax,rax
    1180:	cmovge rcx,QWORD PTR [rip+0x150]        # 12d8 <botlish_fn_14+0x1d8>
    1188:	jmp    11a0 <botlish_fn_14+0xa0>
    118d:	mov    ecx,0x2
    1192:	mov    rsi,r15
    1195:	cmp    rsi,rbx
    1198:	cmovge rcx,QWORD PTR [rip+0x138]        # 12d8 <botlish_fn_14+0x1d8>
    11a0:	cmp    rcx,0x6
    11a4:	je     12ac <botlish_fn_14+0x1ac>
    11aa:	mov    rdx,r12
    11ad:	mov    rsi,r15
    11b0:	mov    rdi,QWORD PTR [rsp+0x30]
    11b5:	call   11ba <botlish_fn_14+0xba>
			11b6: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    11ba:	test   rax,rax
    11bd:	je     1209 <botlish_fn_14+0x109>
    11c3:	mov    QWORD PTR [rsp+0x20],rax
    11c8:	mov    QWORD PTR [rsp+0x28],rax
    11cd:	mov    edx,0x1
    11d2:	mov    rcx,r14
    11d5:	mov    rsi,r13
    11d8:	mov    rdi,QWORD PTR [rsp+0x30]
    11dd:	call   11e2 <botlish_fn_14+0xe2>
			11de: R_X86_64_PLT32	rt_call_value-0x4
    11e2:	test   rax,rax
    11e5:	je     1209 <botlish_fn_14+0x109>
    11eb:	mov    rcx,rax
    11ee:	or     rcx,0x4
    11f2:	mov    rsi,rax
    11f5:	cmp    rcx,0x6
    11f9:	je     122e <botlish_fn_14+0x12e>
    11ff:	mov    rdi,QWORD PTR [rsp+0x30]
    1204:	call   1209 <botlish_fn_14+0x109>
			1205: R_X86_64_PLT32	rt_not_boolean-0x4
    1209:	xor    rax,rax
    120c:	mov    rbx,QWORD PTR [rsp+0x40]
    1211:	mov    r12,QWORD PTR [rsp+0x48]
    1216:	mov    r13,QWORD PTR [rsp+0x50]
    121b:	mov    r14,QWORD PTR [rsp+0x58]
    1220:	mov    r15,QWORD PTR [rsp+0x60]
    1225:	add    rsp,0x70
    1229:	mov    rsp,rbp
    122c:	pop    rbp
    122d:	ret
    122e:	cmp    rsi,0x6
    1232:	je     1240 <botlish_fn_14+0x140>
    1238:	mov    rax,r15
    123b:	jmp    12af <botlish_fn_14+0x1af>
    1240:	mov    QWORD PTR [rsp+0x20],0x3
    1249:	mov    rsi,r15
    124c:	test   rsi,0x1
    1253:	je     1279 <botlish_fn_14+0x179>
    1259:	mov    rsi,r15
    125c:	mov    rcx,rsi
    125f:	add    rcx,0x2
    1263:	seto   al
    1266:	test   al,al
    1268:	jne    1279 <botlish_fn_14+0x179>
    126e:	mov    rsi,rcx
    1271:	mov    r15,rcx
    1274:	jmp    1291 <botlish_fn_14+0x191>
    1279:	mov    edx,0x3
    127e:	mov    rsi,r15
    1281:	mov    rdi,QWORD PTR [rsp+0x30]
    1286:	call   128b <botlish_fn_14+0x18b>
			1287: R_X86_64_PLT32	rt_int_add-0x4
    128b:	mov    rsi,rax
    128e:	mov    r15,rax
    1291:	mov    QWORD PTR [rsp],rsi
    1295:	mov    QWORD PTR [rsp+0x8],r13
    129a:	mov    QWORD PTR [rsp+0x10],rbx
    129f:	mov    QWORD PTR [rsp+0x18],r12
    12a4:	mov    rsi,r15
    12a7:	jmp    1153 <botlish_fn_14+0x53>
    12ac:	mov    rax,r15
    12af:	mov    rbx,QWORD PTR [rsp+0x40]
    12b4:	mov    r12,QWORD PTR [rsp+0x48]
    12b9:	mov    r13,QWORD PTR [rsp+0x50]
    12be:	mov    r14,QWORD PTR [rsp+0x58]
    12c3:	mov    r15,QWORD PTR [rsp+0x60]
    12c8:	add    rsp,0x70
    12cc:	mov    rsp,rbp
    12cf:	pop    rbp
    12d0:	ret
    12d1:	add    BYTE PTR [rax],al
    12d3:	add    BYTE PTR [rax],al
    12d5:	add    BYTE PTR [rax],al
    12d7:	add    BYTE PTR [rsi],al
    12d9:	add    BYTE PTR [rax],al
    12db:	add    BYTE PTR [rax],al
    12dd:	add    BYTE PTR [rax],al
	...

00000000000012e0 <botlish_entry_14: scan_while<generic>>:
    12e0:	push   rbp
    12e1:	mov    rbp,rsp
    12e4:	mov    rsi,QWORD PTR [rdx]
    12e7:	mov    r9,QWORD PTR [rdx+0x8]
    12eb:	mov    rcx,QWORD PTR [rdx+0x10]
    12ef:	mov    r8,QWORD PTR [rdx+0x18]
    12f3:	mov    rdx,r9
    12f6:	call   12fb <botlish_entry_14+0x1b>
			12f7: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<generic>
    12fb:	mov    rsp,rbp
    12fe:	pop    rbp
    12ff:	ret

0000000000001300 <botlish_fn_15: tld_ok<generic>>:
    1300:	push   rbp
    1301:	mov    rbp,rsp
    1304:	sub    rsp,0x40
    1308:	mov    QWORD PTR [rsp+0x20],rbx
    130d:	mov    QWORD PTR [rsp+0x28],r12
    1312:	mov    QWORD PTR [rsp+0x30],r13
    1317:	mov    QWORD PTR [rsp+0x38],r14
    131c:	mov    QWORD PTR [rsp],rsi
    1320:	mov    r8,rsi
    1323:	mov    QWORD PTR [rsp+0x8],rdx
    1328:	mov    r14,rdx
    132b:	mov    QWORD PTR [rsp+0x10],rcx
    1330:	mov    rax,QWORD PTR [rdi+0x10]
    1334:	mov    r12,rdi
    1337:	mov    rdx,QWORD PTR [rax+0xd8]
    133e:	mov    QWORD PTR [rsp+0x18],rdx
    1343:	mov    rbx,r8
    1346:	mov    r8,rcx
    1349:	mov    rcx,r14
    134c:	mov    rsi,rbx
    134f:	call   1354 <botlish_fn_15+0x54>
			1350: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<generic>
    1354:	mov    rcx,rax
    1357:	mov    r13,rax
    135a:	test   rax,rcx
    135d:	jne    1383 <botlish_fn_15+0x83>
    1363:	xor    rax,rax
    1366:	mov    rbx,QWORD PTR [rsp+0x20]
    136b:	mov    r12,QWORD PTR [rsp+0x28]
    1370:	mov    r13,QWORD PTR [rsp+0x30]
    1375:	mov    r14,QWORD PTR [rsp+0x38]
    137a:	add    rsp,0x40
    137e:	mov    rsp,rbp
    1381:	pop    rbp
    1382:	ret
    1383:	mov    rax,r13
    1386:	mov    QWORD PTR [rsp+0x8],rax
    138b:	mov    rdx,r14
    138e:	and    rax,rdx
    1391:	test   rax,0x1
    1397:	jne    13c0 <botlish_fn_15+0xc0>
    139d:	mov    rsi,r13
    13a0:	mov    rdi,r12
    13a3:	call   13a8 <botlish_fn_15+0xa8>
			13a4: R_X86_64_PLT32	rt_int_cmp-0x4
    13a8:	mov    ecx,0x2
    13ad:	test   rax,rax
    13b0:	cmove  rcx,QWORD PTR [rip+0xe0]        # 1498 <botlish_fn_15+0x198>
    13b8:	mov    rax,r13
    13bb:	jmp    13d3 <botlish_fn_15+0xd3>
    13c0:	mov    ecx,0x2
    13c5:	mov    rax,r13
    13c8:	cmp    rax,rdx
    13cb:	cmove  rcx,QWORD PTR [rip+0xc5]        # 1498 <botlish_fn_15+0x198>
    13d3:	cmp    rcx,0x6
    13d7:	je     13ea <botlish_fn_15+0xea>
    13dd:	mov    ecx,0x2
    13e2:	mov    rax,rcx
    13e5:	jmp    1477 <botlish_fn_15+0x177>
    13ea:	mov    rcx,rax
    13ed:	and    rcx,rbx
    13f0:	test   rcx,0x1
    13f7:	jne    1408 <botlish_fn_15+0x108>
    13fd:	mov    rdx,rbx
    1400:	mov    rsi,rax
    1403:	jmp    1429 <botlish_fn_15+0x129>
    1408:	mov    rcx,rax
    140b:	sub    rcx,rbx
    140e:	mov    r8,rbx
    1411:	mov    r13,rax
    1414:	seto   al
    1417:	lea    rsi,[rcx+0x1]
    141b:	test   al,al
    141d:	je     1434 <botlish_fn_15+0x134>
    1423:	mov    rdx,r8
    1426:	mov    rsi,r13
    1429:	mov    rdi,r12
    142c:	call   1431 <botlish_fn_15+0x131>
			142d: R_X86_64_PLT32	rt_int_sub-0x4
    1431:	mov    rsi,rax
    1434:	test   rsi,0x1
    143b:	jne    1466 <botlish_fn_15+0x166>
    1441:	mov    edx,0x5
    1446:	mov    rdi,r12
    1449:	call   144e <botlish_fn_15+0x14e>
			144a: R_X86_64_PLT32	rt_int_cmp-0x4
    144e:	mov    ecx,0x2
    1453:	test   rax,rax
    1456:	mov    rax,rcx
    1459:	cmovge rax,QWORD PTR [rip+0x37]        # 1498 <botlish_fn_15+0x198>
    1461:	jmp    1477 <botlish_fn_15+0x177>
    1466:	mov    eax,0x2
    146b:	cmp    rsi,0x5
    146f:	cmovge rax,QWORD PTR [rip+0x21]        # 1498 <botlish_fn_15+0x198>
    1477:	mov    rbx,QWORD PTR [rsp+0x20]
    147c:	mov    r12,QWORD PTR [rsp+0x28]
    1481:	mov    r13,QWORD PTR [rsp+0x30]
    1486:	mov    r14,QWORD PTR [rsp+0x38]
    148b:	add    rsp,0x40
    148f:	mov    rsp,rbp
    1492:	pop    rbp
    1493:	ret
    1494:	add    BYTE PTR [rax],al
    1496:	add    BYTE PTR [rax],al
    1498:	(bad)
    1499:	add    BYTE PTR [rax],al
    149b:	add    BYTE PTR [rax],al
    149d:	add    BYTE PTR [rax],al
	...

00000000000014a0 <botlish_entry_15: tld_ok<generic>>:
    14a0:	push   rbp
    14a1:	mov    rbp,rsp
    14a4:	mov    rsi,QWORD PTR [rdx]
    14a7:	mov    r8,QWORD PTR [rdx+0x8]
    14ab:	mov    rcx,QWORD PTR [rdx+0x10]
    14af:	mov    rdx,r8
    14b2:	call   14b7 <botlish_entry_15+0x17>
			14b3: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld_ok<generic>
    14b7:	mov    rsp,rbp
    14ba:	pop    rbp
    14bb:	ret
    14bc:	add    BYTE PTR [rax],al
	...

00000000000014c0 <botlish_fn_16: domain_loop<generic>>:
    14c0:	push   rbp
    14c1:	mov    rbp,rsp
    14c4:	sub    rsp,0x70
    14c8:	mov    QWORD PTR [rsp+0x40],rbx
    14cd:	mov    QWORD PTR [rsp+0x48],r12
    14d2:	mov    QWORD PTR [rsp+0x50],r13
    14d7:	mov    QWORD PTR [rsp+0x58],r14
    14dc:	mov    QWORD PTR [rsp+0x60],r15
    14e1:	mov    rax,rdi
    14e4:	mov    QWORD PTR [rsp],rsi
    14e8:	mov    QWORD PTR [rsp+0x8],rdx
    14ed:	mov    rdi,rdx
    14f0:	mov    QWORD PTR [rsp+0x10],rcx
    14f5:	lea    rbx,[rsp+0x20]
    14fa:	mov    r12,rax
    14fd:	mov    QWORD PTR [rsp+0x30],rsi
    1502:	mov    rax,QWORD PTR [r12+0x10]
    1507:	mov    rdx,QWORD PTR [rax+0xe0]
    150e:	mov    QWORD PTR [rsp+0x18],rdx
    1513:	mov    r13,rcx
    1516:	mov    r14,rdi
    1519:	mov    rcx,r14
    151c:	mov    rsi,QWORD PTR [rsp+0x30]
    1521:	mov    rdi,r12
    1524:	mov    r8,r13
    1527:	call   152c <botlish_fn_16+0x6c>
			1528: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<generic>
    152c:	mov    rsi,rax
    152f:	mov    r15,rax
    1532:	test   rax,rsi
    1535:	je     168c <botlish_fn_16+0x1cc>
    153b:	mov    rax,r15
    153e:	mov    QWORD PTR [rsp],rax
    1542:	mov    rdx,QWORD PTR [rsp+0x30]
    1547:	and    rax,rdx
    154a:	test   rax,0x1
    1550:	jne    1576 <botlish_fn_16+0xb6>
    1556:	mov    rsi,r15
    1559:	mov    rdi,r12
    155c:	call   1561 <botlish_fn_16+0xa1>
			155d: R_X86_64_PLT32	rt_int_cmp-0x4
    1561:	mov    ecx,0x2
    1566:	test   rax,rax
    1569:	cmove  rcx,QWORD PTR [rip+0x1a7]        # 1718 <botlish_fn_16+0x258>
    1571:	jmp    1586 <botlish_fn_16+0xc6>
    1576:	mov    ecx,0x2
    157b:	cmp    r15,rdx
    157e:	cmove  rcx,QWORD PTR [rip+0x192]        # 1718 <botlish_fn_16+0x258>
    1586:	cmp    rcx,0x6
    158a:	je     16e8 <botlish_fn_16+0x228>
    1590:	mov    rax,r15
    1593:	and    rax,r14
    1596:	test   rax,0x1
    159c:	jne    15c5 <botlish_fn_16+0x105>
    15a2:	mov    rdx,r14
    15a5:	mov    rsi,r15
    15a8:	mov    rdi,r12
    15ab:	call   15b0 <botlish_fn_16+0xf0>
			15ac: R_X86_64_PLT32	rt_int_cmp-0x4
    15b0:	mov    ecx,0x2
    15b5:	test   rax,rax
    15b8:	cmovge rcx,QWORD PTR [rip+0x158]        # 1718 <botlish_fn_16+0x258>
    15c0:	jmp    15d5 <botlish_fn_16+0x115>
    15c5:	mov    ecx,0x2
    15ca:	cmp    r15,r14
    15cd:	cmovge rcx,QWORD PTR [rip+0x143]        # 1718 <botlish_fn_16+0x258>
    15d5:	cmp    rcx,0x6
    15d9:	je     16d9 <botlish_fn_16+0x219>
    15df:	mov    rcx,rbx
    15e2:	mov    rdx,r13
    15e5:	mov    rsi,r15
    15e8:	mov    rdi,r12
    15eb:	call   15f0 <botlish_fn_16+0x130>
			15ec: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    15f0:	test   rax,rax
    15f3:	mov    rsi,rax
    15f6:	je     168c <botlish_fn_16+0x1cc>
    15fc:	mov    rdx,QWORD PTR [rsp+0x20]
    1601:	mov    rcx,QWORD PTR [rsp+0x28]
    1606:	mov    r8,QWORD PTR [r12+0x10]
    160b:	mov    r8,QWORD PTR [r8+0xa0]
    1612:	mov    rdi,r12
    1615:	call   161a <botlish_fn_16+0x15a>
			1616: R_X86_64_PLT32	rt_str_region_eq-0x4
    161a:	cmp    rax,0x6
    161e:	je     1630 <botlish_fn_16+0x170>
    1624:	mov    r14,0xffffffffffffffff
    162b:	jmp    16e0 <botlish_fn_16+0x220>
    1630:	mov    QWORD PTR [rsp+0x18],0x3
    1639:	test   r15,0x1
    1640:	je     1658 <botlish_fn_16+0x198>
    1646:	mov    rdx,r15
    1649:	add    rdx,0x2
    164d:	seto   al
    1650:	test   al,al
    1652:	je     166b <botlish_fn_16+0x1ab>
    1658:	mov    edx,0x3
    165d:	mov    rsi,r15
    1660:	mov    rdi,r12
    1663:	call   1668 <botlish_fn_16+0x1a8>
			1664: R_X86_64_PLT32	rt_int_add-0x4
    1668:	mov    rdx,rax
    166b:	mov    QWORD PTR [rsp],rdx
    166f:	mov    r15,rdx
    1672:	mov    rcx,r13
    1675:	mov    rdx,r14
    1678:	mov    rsi,r15
    167b:	mov    rdi,r12
    167e:	call   1683 <botlish_fn_16+0x1c3>
			167f: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld_ok<generic>
    1683:	test   rax,rax
    1686:	jne    16b1 <botlish_fn_16+0x1f1>
    168c:	xor    rax,rax
    168f:	mov    rbx,QWORD PTR [rsp+0x40]
    1694:	mov    r12,QWORD PTR [rsp+0x48]
    1699:	mov    r13,QWORD PTR [rsp+0x50]
    169e:	mov    r14,QWORD PTR [rsp+0x58]
    16a3:	mov    r15,QWORD PTR [rsp+0x60]
    16a8:	add    rsp,0x70
    16ac:	mov    rsp,rbp
    16af:	pop    rbp
    16b0:	ret
    16b1:	cmp    rax,0x6
    16b5:	je     16e0 <botlish_fn_16+0x220>
    16bb:	mov    QWORD PTR [rsp],r15
    16bf:	mov    QWORD PTR [rsp+0x8],r14
    16c4:	mov    QWORD PTR [rsp+0x10],r13
    16c9:	mov    rcx,r13
    16cc:	mov    rdi,r14
    16cf:	mov    QWORD PTR [rsp+0x30],r15
    16d4:	jmp    1502 <botlish_fn_16+0x42>
    16d9:	mov    r14,0xffffffffffffffff
    16e0:	mov    rax,r14
    16e3:	jmp    16ef <botlish_fn_16+0x22f>
    16e8:	mov    rax,0xffffffffffffffff
    16ef:	mov    rbx,QWORD PTR [rsp+0x40]
    16f4:	mov    r12,QWORD PTR [rsp+0x48]
    16f9:	mov    r13,QWORD PTR [rsp+0x50]
    16fe:	mov    r14,QWORD PTR [rsp+0x58]
    1703:	mov    r15,QWORD PTR [rsp+0x60]
    1708:	add    rsp,0x70
    170c:	mov    rsp,rbp
    170f:	pop    rbp
    1710:	ret
    1711:	add    BYTE PTR [rax],al
    1713:	add    BYTE PTR [rax],al
    1715:	add    BYTE PTR [rax],al
    1717:	add    BYTE PTR [rsi],al
    1719:	add    BYTE PTR [rax],al
    171b:	add    BYTE PTR [rax],al
    171d:	add    BYTE PTR [rax],al
	...

0000000000001720 <botlish_entry_16: domain_loop<generic>>:
    1720:	push   rbp
    1721:	mov    rbp,rsp
    1724:	mov    rsi,QWORD PTR [rdx]
    1727:	mov    r8,QWORD PTR [rdx+0x8]
    172b:	mov    rcx,QWORD PTR [rdx+0x10]
    172f:	mov    rdx,r8
    1732:	call   1737 <botlish_entry_16+0x17>
			1733: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain_loop<generic>
    1737:	mov    rsp,rbp
    173a:	pop    rbp
    173b:	ret

000000000000173c <botlish_fn_17: web::is_unreserved<generic>>:
    173c:	push   rbp
    173d:	mov    rbp,rsp
    1740:	sub    rsp,0x20
    1744:	mov    QWORD PTR [rsp],rbx
    1748:	mov    QWORD PTR [rsp+0x8],r12
    174d:	mov    QWORD PTR [rsp+0x10],r14
    1752:	mov    rbx,rdi
    1755:	mov    r12,rsi
    1758:	mov    r14,rdx
    175b:	mov    rsi,r14
    175e:	mov    rdi,rbx
    1761:	call   1766 <botlish_fn_17+0x2a>
			1762: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
    1766:	cmp    rax,0x6
    176a:	je     17a3 <botlish_fn_17+0x67>
    1770:	mov    rsi,r12
    1773:	mov    rax,QWORD PTR [rsi+0x20]
    1777:	mov    rsi,QWORD PTR [rax]
    177a:	mov    rdx,r14
    177d:	mov    rdi,rbx
    1780:	call   1785 <botlish_fn_17+0x49>
			1781: R_X86_64_PLT32	rt_set_contains-0x4
    1785:	cmp    rax,0x6
    1789:	je     1799 <botlish_fn_17+0x5d>
    178f:	mov    eax,0x2
    1794:	jmp    17a8 <botlish_fn_17+0x6c>
    1799:	mov    eax,0x6
    179e:	jmp    17a8 <botlish_fn_17+0x6c>
    17a3:	mov    eax,0x6
    17a8:	mov    rbx,QWORD PTR [rsp]
    17ac:	mov    r12,QWORD PTR [rsp+0x8]
    17b1:	mov    r14,QWORD PTR [rsp+0x10]
    17b6:	add    rsp,0x20
    17ba:	mov    rsp,rbp
    17bd:	pop    rbp
    17be:	ret

00000000000017bf <botlish_entry_17: web::is_unreserved<generic>>:
    17bf:	push   rbp
    17c0:	mov    rbp,rsp
    17c3:	mov    rdx,QWORD PTR [rdx]
    17c6:	call   17cb <botlish_entry_17+0xc>
			17c7: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<generic>
    17cb:	mov    rsp,rbp
    17ce:	pop    rbp
    17cf:	ret

00000000000017d0 <botlish_fn_18: web::uri_escape_text<generic>>:
    17d0:	push   rbp
    17d1:	mov    rbp,rsp
    17d4:	sub    rsp,0x30
    17d8:	mov    QWORD PTR [rsp],rdx
    17dc:	mov    r10,rdx
    17df:	mov    edx,0x1
    17e4:	mov    QWORD PTR [rsp+0x8],0x1
    17ed:	mov    rax,QWORD PTR [rdi+0x10]
    17f1:	mov    rcx,QWORD PTR [rax+0xe8]
    17f8:	mov    QWORD PTR [rsp+0x10],rcx
    17fd:	mov    rax,QWORD PTR [rsi+0x20]
    1801:	mov    r8,QWORD PTR [rax+0x8]
    1805:	mov    QWORD PTR [rsp+0x18],r8
    180a:	mov    rax,QWORD PTR [rsi+0x20]
    180e:	mov    r9,QWORD PTR [rax]
    1811:	mov    QWORD PTR [rsp+0x20],r9
    1816:	mov    rsi,r10
    1819:	call   181e <botlish_fn_18+0x4e>
			181a: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_from<generic>
    181e:	test   rax,rax
    1821:	jne    1833 <botlish_fn_18+0x63>
    1827:	xor    rax,rax
    182a:	add    rsp,0x30
    182e:	mov    rsp,rbp
    1831:	pop    rbp
    1832:	ret
    1833:	add    rsp,0x30
    1837:	mov    rsp,rbp
    183a:	pop    rbp
    183b:	ret

000000000000183c <botlish_entry_18: web::uri_escape_text<generic>>:
    183c:	push   rbp
    183d:	mov    rbp,rsp
    1840:	mov    rdx,QWORD PTR [rdx]
    1843:	call   1848 <botlish_entry_18+0xc>
			1844: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::uri_escape_text<generic>
    1848:	mov    rsp,rbp
    184b:	pop    rbp
    184c:	ret

000000000000184d <botlish_fn_19: high_nibble<generic>>:
    184d:	push   rbp
    184e:	mov    rbp,rsp
    1851:	sub    rsp,0x10
    1855:	mov    QWORD PTR [rsp],rsi
    1859:	mov    QWORD PTR [rsp+0x8],0x1e1
    1862:	test   rsi,0x1
    1869:	jne    187e <botlish_fn_19+0x31>
    186f:	mov    edx,0x1e1
    1874:	call   1879 <botlish_fn_19+0x2c>
			1875: R_X86_64_PLT32	rt_int_and-0x4
    1879:	jmp    1888 <botlish_fn_19+0x3b>
    187e:	and    rsi,0x1e1
    1885:	mov    rax,rsi
    1888:	sar    rax,0x5
    188c:	shl    rax,1
    188f:	or     rax,0x1
    1893:	add    rsp,0x10
    1897:	mov    rsp,rbp
    189a:	pop    rbp
    189b:	ret

000000000000189c <botlish_entry_19: high_nibble<generic>>:
    189c:	push   rbp
    189d:	mov    rbp,rsp
    18a0:	mov    rsi,QWORD PTR [rdx]
    18a3:	call   18a8 <botlish_entry_19+0xc>
			18a4: R_X86_64_PLT32	botlish_fn_19-0x4 ; high_nibble<generic>
    18a8:	mov    rsp,rbp
    18ab:	pop    rbp
    18ac:	ret

00000000000018ad <botlish_fn_20: hex_pair<generic>>:
    18ad:	push   rbp
    18ae:	mov    rbp,rsp
    18b1:	sub    rsp,0x50
    18b5:	mov    QWORD PTR [rsp+0x30],rbx
    18ba:	mov    QWORD PTR [rsp+0x38],r12
    18bf:	mov    QWORD PTR [rsp+0x40],r13
    18c4:	mov    QWORD PTR [rsp+0x48],r14
    18c9:	mov    r12,rdi
    18cc:	mov    QWORD PTR [rsp],rsi
    18d0:	mov    r13,rsi
    18d3:	mov    QWORD PTR [rsp+0x8],rdx
    18d8:	mov    rbx,rdx
    18db:	mov    rsi,r13
    18de:	mov    rdi,r12
    18e1:	call   18e6 <botlish_fn_20+0x39>
			18e2: R_X86_64_PLT32	botlish_fn_19-0x4 ; high_nibble<generic>
    18e6:	test   rax,0x1
    18ec:	jne    18fa <botlish_fn_20+0x4d>
    18f2:	mov    rdx,rax
    18f5:	jmp    1910 <botlish_fn_20+0x63>
    18fa:	mov    rdx,QWORD PTR [rbx+0x8]
    18fe:	mov    rcx,rax
    1901:	sar    rcx,1
    1904:	cmp    rcx,rdx
    1907:	jb     1929 <botlish_fn_20+0x7c>
    190d:	mov    rdx,rax
    1910:	mov    rsi,rbx
    1913:	mov    rdi,r12
    1916:	call   191b <botlish_fn_20+0x6e>
			1917: R_X86_64_PLT32	rt_list_get-0x4
    191b:	test   rax,rax
    191e:	je     19e6 <botlish_fn_20+0x139>
    1924:	jmp    1931 <botlish_fn_20+0x84>
    1929:	mov    rax,QWORD PTR [rbx+0x10]
    192d:	mov    rax,QWORD PTR [rax+rcx*8]
    1931:	mov    QWORD PTR [rsp],rax
    1935:	mov    r14,rax
    1938:	mov    edx,0x21
    193d:	mov    rsi,r13
    1940:	mov    rdi,r12
    1943:	call   1948 <botlish_fn_20+0x9b>
			1944: R_X86_64_PLT32	rt_int_mod-0x4
    1948:	test   rax,rax
    194b:	je     19e6 <botlish_fn_20+0x139>
    1951:	test   rax,0x1
    1957:	jne    1968 <botlish_fn_20+0xbb>
    195d:	mov    rdx,rax
    1960:	mov    rsi,rbx
    1963:	jmp    1981 <botlish_fn_20+0xd4>
    1968:	mov    rdx,QWORD PTR [rbx+0x8]
    196c:	mov    rcx,rax
    196f:	sar    rcx,1
    1972:	cmp    rcx,rdx
    1975:	jb     1997 <botlish_fn_20+0xea>
    197b:	mov    rdx,rax
    197e:	mov    rsi,rbx
    1981:	mov    rdi,r12
    1984:	call   1989 <botlish_fn_20+0xdc>
			1985: R_X86_64_PLT32	rt_list_get-0x4
    1989:	test   rax,rax
    198c:	je     19e6 <botlish_fn_20+0x139>
    1992:	jmp    19a2 <botlish_fn_20+0xf5>
    1997:	mov    rsi,rbx
    199a:	mov    rax,QWORD PTR [rsi+0x10]
    199e:	mov    rax,QWORD PTR [rax+rcx*8]
    19a2:	mov    QWORD PTR [rsp+0x8],rax
    19a7:	lea    rcx,[rsp+0x10]
    19ac:	mov    QWORD PTR [rsp+0x10],0x0
    19b5:	mov    rdx,r14
    19b8:	mov    QWORD PTR [rsp+0x18],rdx
    19bd:	mov    QWORD PTR [rsp+0x20],0x0
    19c6:	mov    QWORD PTR [rsp+0x28],rax
    19cb:	mov    esi,0x2
    19d0:	mov    edx,0x4
    19d5:	mov    rdi,r12
    19d8:	call   19dd <botlish_fn_20+0x130>
			19d9: R_X86_64_PLT32	rt_construct-0x4
    19dd:	test   rax,rax
    19e0:	jne    1a06 <botlish_fn_20+0x159>
    19e6:	xor    rax,rax
    19e9:	mov    rbx,QWORD PTR [rsp+0x30]
    19ee:	mov    r12,QWORD PTR [rsp+0x38]
    19f3:	mov    r13,QWORD PTR [rsp+0x40]
    19f8:	mov    r14,QWORD PTR [rsp+0x48]
    19fd:	add    rsp,0x50
    1a01:	mov    rsp,rbp
    1a04:	pop    rbp
    1a05:	ret
    1a06:	mov    rbx,QWORD PTR [rsp+0x30]
    1a0b:	mov    r12,QWORD PTR [rsp+0x38]
    1a10:	mov    r13,QWORD PTR [rsp+0x40]
    1a15:	mov    r14,QWORD PTR [rsp+0x48]
    1a1a:	add    rsp,0x50
    1a1e:	mov    rsp,rbp
    1a21:	pop    rbp
    1a22:	ret

0000000000001a23 <botlish_entry_20: hex_pair<generic>>:
    1a23:	push   rbp
    1a24:	mov    rbp,rsp
    1a27:	sub    rsp,0x10
    1a2b:	mov    QWORD PTR [rsp],r12
    1a2f:	mov    r12,rdi
    1a32:	mov    rsi,QWORD PTR [rdx]
    1a35:	mov    rdx,QWORD PTR [rdx+0x8]
    1a39:	call   1a3e <botlish_entry_20+0x1b>
			1a3a: R_X86_64_PLT32	botlish_fn_20-0x4 ; hex_pair<generic>
    1a3e:	mov    r8,QWORD PTR [rip+0x0]        # 1a45 <botlish_entry_20+0x22>
			1a41: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1a45:	mov    rsi,rax
    1a48:	mov    rdi,r12
    1a4b:	call   r8
    1a4e:	mov    r12,QWORD PTR [rsp]
    1a52:	add    rsp,0x10
    1a56:	mov    rsp,rbp
    1a59:	pop    rbp
    1a5a:	ret
    1a5b:	add    BYTE PTR [rax],al
    1a5d:	add    BYTE PTR [rax],al
	...

0000000000001a60 <botlish_fn_21: esc_bytes<generic>>:
    1a60:	push   rbp
    1a61:	mov    rbp,rsp
    1a64:	sub    rsp,0xb0
    1a6b:	mov    QWORD PTR [rsp+0x80],rbx
    1a73:	mov    QWORD PTR [rsp+0x88],r12
    1a7b:	mov    QWORD PTR [rsp+0x90],r13
    1a83:	mov    QWORD PTR [rsp+0x98],r14
    1a8b:	mov    QWORD PTR [rsp+0xa0],r15
    1a93:	mov    QWORD PTR [rsp+0x28],0x0
    1a9c:	mov    QWORD PTR [rsp],rsi
    1aa0:	mov    QWORD PTR [rsp+0x8],rdx
    1aa5:	mov    r13,rdx
    1aa8:	mov    QWORD PTR [rsp+0x10],rcx
    1aad:	mov    QWORD PTR [rsp+0x18],r8
    1ab2:	mov    QWORD PTR [rsp+0x60],r8
    1ab7:	lea    rax,[rsp+0x30]
    1abc:	mov    QWORD PTR [rsp+0x70],rax
    1ac1:	mov    rbx,rdi
    1ac4:	mov    r12,rsi
    1ac7:	mov    QWORD PTR [rsp+0x68],rcx
    1acc:	mov    rsi,r12
    1acf:	mov    rdi,rbx
    1ad2:	call   1ad7 <botlish_fn_21+0x77>
			1ad3: R_X86_64_PLT32	rt_list_len-0x4
    1ad7:	mov    r15,r13
    1ada:	mov    rcx,r15
    1add:	and    rcx,rax
    1ae0:	mov    rdx,rax
    1ae3:	test   rcx,0x1
    1aea:	jne    1b10 <botlish_fn_21+0xb0>
    1af0:	mov    rsi,r15
    1af3:	mov    rdi,rbx
    1af6:	call   1afb <botlish_fn_21+0x9b>
			1af7: R_X86_64_PLT32	rt_int_cmp-0x4
    1afb:	mov    ecx,0x2
    1b00:	test   rax,rax
    1b03:	cmovge rcx,QWORD PTR [rip+0x1dd]        # 1ce8 <botlish_fn_21+0x288>
    1b0b:	jmp    1b20 <botlish_fn_21+0xc0>
    1b10:	mov    ecx,0x2
    1b15:	cmp    r15,rdx
    1b18:	cmovge rcx,QWORD PTR [rip+0x1c8]        # 1ce8 <botlish_fn_21+0x288>
    1b20:	cmp    rcx,0x6
    1b24:	je     1cad <botlish_fn_21+0x24d>
    1b2a:	mov    QWORD PTR [rsp+0x20],0x3
    1b33:	test   r15,0x1
    1b3a:	je     1b5d <botlish_fn_21+0xfd>
    1b40:	mov    rax,r15
    1b43:	add    rax,0x2
    1b47:	mov    rcx,rax
    1b4a:	seto   al
    1b4d:	test   al,al
    1b4f:	jne    1b5d <botlish_fn_21+0xfd>
    1b55:	mov    r14,rcx
    1b58:	jmp    1b73 <botlish_fn_21+0x113>
    1b5d:	mov    edx,0x3
    1b62:	mov    rsi,r15
    1b65:	mov    rdi,rbx
    1b68:	call   1b6d <botlish_fn_21+0x10d>
			1b69: R_X86_64_PLT32	rt_int_add-0x4
    1b6d:	mov    rcx,rax
    1b70:	mov    r14,rcx
    1b73:	mov    QWORD PTR [rsp+0x8],r14
    1b78:	mov    rax,QWORD PTR [rbx+0x10]
    1b7c:	mov    r13,QWORD PTR [rax+0xb0]
    1b83:	mov    QWORD PTR [rsp+0x20],r13
    1b88:	test   r15,0x1
    1b8f:	jne    1b9d <botlish_fn_21+0x13d>
    1b95:	mov    rdx,r15
    1b98:	jmp    1bb4 <botlish_fn_21+0x154>
    1b9d:	mov    rcx,QWORD PTR [r12+0x8]
    1ba2:	mov    rax,r15
    1ba5:	sar    rax,1
    1ba8:	cmp    rax,rcx
    1bab:	jb     1bd0 <botlish_fn_21+0x170>
    1bb1:	mov    rdx,r15
    1bb4:	mov    rsi,r12
    1bb7:	mov    rdi,rbx
    1bba:	call   1bbf <botlish_fn_21+0x15f>
			1bbb: R_X86_64_PLT32	rt_list_get-0x4
    1bbf:	test   rax,rax
    1bc2:	je     1c51 <botlish_fn_21+0x1f1>
    1bc8:	mov    rsi,rax
    1bcb:	jmp    1bd9 <botlish_fn_21+0x179>
    1bd0:	mov    rdi,QWORD PTR [r12+0x10]
    1bd5:	mov    rsi,QWORD PTR [rdi+rax*8]
    1bd9:	mov    QWORD PTR [rsp+0x28],rsi
    1bde:	mov    r15,QWORD PTR [rsp+0x60]
    1be3:	mov    rdx,r15
    1be6:	mov    rdi,rbx
    1be9:	call   1bee <botlish_fn_21+0x18e>
			1bea: R_X86_64_PLT32	botlish_fn_20-0x4 ; hex_pair<generic>
    1bee:	test   rax,rax
    1bf1:	je     1c51 <botlish_fn_21+0x1f1>
    1bf7:	mov    QWORD PTR [rsp+0x28],rax
    1bfc:	mov    rcx,rax
    1bff:	mov    QWORD PTR [rsp+0x30],0x0
    1c08:	mov    rax,QWORD PTR [rsp+0x68]
    1c0d:	mov    QWORD PTR [rsp+0x38],rax
    1c12:	mov    QWORD PTR [rsp+0x40],0x0
    1c1b:	mov    QWORD PTR [rsp+0x48],r13
    1c20:	mov    QWORD PTR [rsp+0x50],0x0
    1c29:	mov    rax,rcx
    1c2c:	mov    QWORD PTR [rsp+0x58],rax
    1c31:	mov    esi,0x2
    1c36:	mov    edx,0x6
    1c3b:	mov    rcx,QWORD PTR [rsp+0x70]
    1c40:	mov    rdi,rbx
    1c43:	call   1c48 <botlish_fn_21+0x1e8>
			1c44: R_X86_64_PLT32	rt_construct-0x4
    1c48:	test   rax,rax
    1c4b:	jne    1c88 <botlish_fn_21+0x228>
    1c51:	xor    rax,rax
    1c54:	mov    rbx,QWORD PTR [rsp+0x80]
    1c5c:	mov    r12,QWORD PTR [rsp+0x88]
    1c64:	mov    r13,QWORD PTR [rsp+0x90]
    1c6c:	mov    r14,QWORD PTR [rsp+0x98]
    1c74:	mov    r15,QWORD PTR [rsp+0xa0]
    1c7c:	add    rsp,0xb0
    1c83:	mov    rsp,rbp
    1c86:	pop    rbp
    1c87:	ret
    1c88:	mov    QWORD PTR [rsp],r12
    1c8c:	mov    QWORD PTR [rsp+0x8],r14
    1c91:	mov    QWORD PTR [rsp+0x10],rax
    1c96:	mov    QWORD PTR [rsp+0x18],r15
    1c9b:	mov    r13,r14
    1c9e:	mov    QWORD PTR [rsp+0x60],r15
    1ca3:	mov    QWORD PTR [rsp+0x68],rax
    1ca8:	jmp    1acc <botlish_fn_21+0x6c>
    1cad:	mov    rax,QWORD PTR [rsp+0x68]
    1cb2:	mov    rbx,QWORD PTR [rsp+0x80]
    1cba:	mov    r12,QWORD PTR [rsp+0x88]
    1cc2:	mov    r13,QWORD PTR [rsp+0x90]
    1cca:	mov    r14,QWORD PTR [rsp+0x98]
    1cd2:	mov    r15,QWORD PTR [rsp+0xa0]
    1cda:	add    rsp,0xb0
    1ce1:	mov    rsp,rbp
    1ce4:	pop    rbp
    1ce5:	ret
    1ce6:	add    BYTE PTR [rax],al
    1ce8:	(bad)
    1ce9:	add    BYTE PTR [rax],al
    1ceb:	add    BYTE PTR [rax],al
    1ced:	add    BYTE PTR [rax],al
	...

0000000000001cf0 <botlish_entry_21: esc_bytes<generic>>:
    1cf0:	push   rbp
    1cf1:	mov    rbp,rsp
    1cf4:	sub    rsp,0x10
    1cf8:	mov    QWORD PTR [rsp],r12
    1cfc:	mov    r12,rdi
    1cff:	mov    rsi,QWORD PTR [rdx]
    1d02:	mov    r9,QWORD PTR [rdx+0x8]
    1d06:	mov    rcx,QWORD PTR [rdx+0x10]
    1d0a:	mov    r8,QWORD PTR [rdx+0x18]
    1d0e:	mov    rdx,r9
    1d11:	call   1d16 <botlish_entry_21+0x26>
			1d12: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_bytes<generic>
    1d16:	mov    r9,QWORD PTR [rip+0x0]        # 1d1d <botlish_entry_21+0x2d>
			1d19: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1d1d:	mov    rsi,rax
    1d20:	mov    rdi,r12
    1d23:	call   r9
    1d26:	mov    r12,QWORD PTR [rsp]
    1d2a:	add    rsp,0x10
    1d2e:	mov    rsp,rbp
    1d31:	pop    rbp
    1d32:	ret

0000000000001d33 <botlish_fn_22: esc_char<generic>>:
    1d33:	push   rbp
    1d34:	mov    rbp,rsp
    1d37:	sub    rsp,0x50
    1d3b:	mov    QWORD PTR [rsp+0x20],rbx
    1d40:	mov    QWORD PTR [rsp+0x28],r12
    1d45:	mov    QWORD PTR [rsp+0x30],r13
    1d4a:	mov    QWORD PTR [rsp+0x38],r14
    1d4f:	mov    QWORD PTR [rsp+0x40],r15
    1d54:	mov    r12,rdi
    1d57:	mov    QWORD PTR [rsp+0x18],0x0
    1d60:	mov    QWORD PTR [rsp],rsi
    1d64:	mov    r14,rsi
    1d67:	mov    QWORD PTR [rsp+0x8],rdx
    1d6c:	mov    r15,rdx
    1d6f:	mov    QWORD PTR [rsp+0x10],rcx
    1d74:	mov    rbx,rcx
    1d77:	mov    rsi,r14
    1d7a:	mov    rdi,r12
    1d7d:	call   1d82 <botlish_fn_22+0x4f>
			1d7e: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1d82:	mov    rcx,rax
    1d85:	mov    r13,rax
    1d88:	test   rax,rcx
    1d8b:	je     1e75 <botlish_fn_22+0x142>
    1d91:	mov    rax,r13
    1d94:	mov    QWORD PTR [rsp],rax
    1d98:	mov    rsi,r13
    1d9b:	mov    rdi,r12
    1d9e:	call   1da3 <botlish_fn_22+0x70>
			1d9f: R_X86_64_PLT32	rt_list_len-0x4
    1da3:	sar    rax,1
    1da6:	cmp    rax,0x1
    1daa:	je     1dea <botlish_fn_22+0xb7>
    1db0:	mov    edx,0x1
    1db5:	mov    QWORD PTR [rsp+0x8],0x1
    1dbe:	mov    rdi,r12
    1dc1:	mov    rax,QWORD PTR [rdi+0x10]
    1dc5:	mov    rcx,QWORD PTR [rax+0xe8]
    1dcc:	mov    QWORD PTR [rsp+0x18],rcx
    1dd1:	mov    rsi,r13
    1dd4:	mov    r8,rbx
    1dd7:	call   1ddc <botlish_fn_22+0xa9>
			1dd8: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_bytes<generic>
    1ddc:	test   rax,rax
    1ddf:	je     1e75 <botlish_fn_22+0x142>
    1de5:	jmp    1ea0 <botlish_fn_22+0x16d>
    1dea:	mov    rsi,r13
    1ded:	mov    rax,QWORD PTR [rsi+0x8]
    1df1:	mov    r13,rsi
    1df4:	test   rax,rax
    1df7:	jne    1e21 <botlish_fn_22+0xee>
    1dfd:	mov    edx,0x1
    1e02:	mov    rsi,r13
    1e05:	mov    rdi,r12
    1e08:	call   1e0d <botlish_fn_22+0xda>
			1e09: R_X86_64_PLT32	rt_list_get-0x4
    1e0d:	test   rax,rax
    1e10:	je     1e75 <botlish_fn_22+0x142>
    1e16:	mov    rdx,rax
    1e19:	mov    rsi,r15
    1e1c:	jmp    1e2e <botlish_fn_22+0xfb>
    1e21:	mov    rsi,r13
    1e24:	mov    rax,QWORD PTR [rsi+0x10]
    1e28:	mov    rdx,QWORD PTR [rax]
    1e2b:	mov    rsi,r15
    1e2e:	mov    rdi,r12
    1e31:	call   1e36 <botlish_fn_22+0x103>
			1e32: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<generic>
    1e36:	cmp    rax,0x6
    1e3a:	je     1e9d <botlish_fn_22+0x16a>
    1e40:	mov    edx,0x1
    1e45:	mov    QWORD PTR [rsp+0x8],0x1
    1e4e:	mov    rdi,r12
    1e51:	mov    rax,QWORD PTR [rdi+0x10]
    1e55:	mov    rcx,QWORD PTR [rax+0xe8]
    1e5c:	mov    QWORD PTR [rsp+0x18],rcx
    1e61:	mov    rsi,r13
    1e64:	mov    r8,rbx
    1e67:	call   1e6c <botlish_fn_22+0x139>
			1e68: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_bytes<generic>
    1e6c:	test   rax,rax
    1e6f:	jne    1e9a <botlish_fn_22+0x167>
    1e75:	xor    rax,rax
    1e78:	mov    rbx,QWORD PTR [rsp+0x20]
    1e7d:	mov    r12,QWORD PTR [rsp+0x28]
    1e82:	mov    r13,QWORD PTR [rsp+0x30]
    1e87:	mov    r14,QWORD PTR [rsp+0x38]
    1e8c:	mov    r15,QWORD PTR [rsp+0x40]
    1e91:	add    rsp,0x50
    1e95:	mov    rsp,rbp
    1e98:	pop    rbp
    1e99:	ret
    1e9a:	mov    r14,rax
    1e9d:	mov    rax,r14
    1ea0:	mov    rbx,QWORD PTR [rsp+0x20]
    1ea5:	mov    r12,QWORD PTR [rsp+0x28]
    1eaa:	mov    r13,QWORD PTR [rsp+0x30]
    1eaf:	mov    r14,QWORD PTR [rsp+0x38]
    1eb4:	mov    r15,QWORD PTR [rsp+0x40]
    1eb9:	add    rsp,0x50
    1ebd:	mov    rsp,rbp
    1ec0:	pop    rbp
    1ec1:	ret

0000000000001ec2 <botlish_entry_22: esc_char<generic>>:
    1ec2:	push   rbp
    1ec3:	mov    rbp,rsp
    1ec6:	sub    rsp,0x10
    1eca:	mov    QWORD PTR [rsp],r12
    1ece:	mov    r12,rdi
    1ed1:	mov    rsi,QWORD PTR [rdx]
    1ed4:	mov    r8,QWORD PTR [rdx+0x8]
    1ed8:	mov    rcx,QWORD PTR [rdx+0x10]
    1edc:	mov    rdx,r8
    1edf:	call   1ee4 <botlish_entry_22+0x22>
			1ee0: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_char<generic>
    1ee4:	mov    r8,QWORD PTR [rip+0x0]        # 1eeb <botlish_entry_22+0x29>
			1ee7: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1eeb:	mov    rsi,rax
    1eee:	mov    rdi,r12
    1ef1:	call   r8
    1ef4:	mov    r12,QWORD PTR [rsp]
    1ef8:	add    rsp,0x10
    1efc:	mov    rsp,rbp
    1eff:	pop    rbp
    1f00:	ret
    1f01:	add    BYTE PTR [rax],al
    1f03:	add    BYTE PTR [rax],al
    1f05:	add    BYTE PTR [rax],al
	...

0000000000001f08 <botlish_fn_23: esc_from<generic>>:
    1f08:	push   rbp
    1f09:	mov    rbp,rsp
    1f0c:	sub    rsp,0xb0
    1f13:	mov    QWORD PTR [rsp+0x80],rbx
    1f1b:	mov    QWORD PTR [rsp+0x88],r12
    1f23:	mov    QWORD PTR [rsp+0x90],r13
    1f2b:	mov    QWORD PTR [rsp+0x98],r14
    1f33:	mov    QWORD PTR [rsp+0xa0],r15
    1f3b:	mov    r14,rdi
    1f3e:	mov    QWORD PTR [rsp+0x28],0x0
    1f47:	mov    QWORD PTR [rsp+0x30],0x0
    1f50:	mov    QWORD PTR [rsp],rsi
    1f54:	mov    QWORD PTR [rsp+0x8],rdx
    1f59:	mov    r12,rdx
    1f5c:	mov    QWORD PTR [rsp+0x10],rcx
    1f61:	mov    QWORD PTR [rsp+0x68],rcx
    1f66:	mov    QWORD PTR [rsp+0x18],r8
    1f6b:	mov    r15,r8
    1f6e:	mov    QWORD PTR [rsp+0x20],r9
    1f73:	mov    r13,r9
    1f76:	xor    eax,eax
    1f78:	test   rsi,0x7
    1f7f:	jne    1f8e <botlish_fn_23+0x86>
    1f85:	movzx  rax,BYTE PTR [rsi]
    1f89:	cmp    al,0x2
    1f8b:	sete   al
    1f8e:	test   al,al
    1f90:	jne    1fb3 <botlish_fn_23+0xab>
    1f96:	mov    rdi,r14
    1f99:	mov    rax,QWORD PTR [rdi+0x10]
    1f9d:	mov    rcx,QWORD PTR [rax+0xf0]
    1fa4:	mov    edx,0x1
    1fa9:	call   1fae <botlish_fn_23+0xa6>
			1faa: R_X86_64_PLT32	rt_type_error-0x4
    1fae:	jmp    2170 <botlish_fn_23+0x268>
    1fb3:	mov    rbx,rsi
    1fb6:	mov    rdi,r14
    1fb9:	call   1fbe <botlish_fn_23+0xb6>
			1fba: R_X86_64_PLT32	rt_str_len-0x4
    1fbe:	mov    rcx,r12
    1fc1:	and    rcx,rax
    1fc4:	mov    rdx,rax
    1fc7:	test   rcx,0x1
    1fce:	jne    1ff4 <botlish_fn_23+0xec>
    1fd4:	mov    rsi,r12
    1fd7:	mov    rdi,r14
    1fda:	call   1fdf <botlish_fn_23+0xd7>
			1fdb: R_X86_64_PLT32	rt_int_cmp-0x4
    1fdf:	mov    ecx,0x2
    1fe4:	test   rax,rax
    1fe7:	cmovge rcx,QWORD PTR [rip+0x1f1]        # 21e0 <botlish_fn_23+0x2d8>
    1fef:	jmp    2004 <botlish_fn_23+0xfc>
    1ff4:	mov    ecx,0x2
    1ff9:	cmp    r12,rdx
    1ffc:	cmovge rcx,QWORD PTR [rip+0x1dc]        # 21e0 <botlish_fn_23+0x2d8>
    2004:	cmp    rcx,0x6
    2008:	je     213f <botlish_fn_23+0x237>
    200e:	mov    QWORD PTR [rsp+0x28],0x3
    2017:	test   r12,0x1
    201e:	je     2036 <botlish_fn_23+0x12e>
    2024:	mov    rax,r12
    2027:	add    rax,0x2
    202b:	seto   cl
    202e:	test   cl,cl
    2030:	je     2046 <botlish_fn_23+0x13e>
    2036:	mov    edx,0x3
    203b:	mov    rsi,r12
    203e:	mov    rdi,r14
    2041:	call   2046 <botlish_fn_23+0x13e>
			2042: R_X86_64_PLT32	rt_int_add-0x4
    2046:	mov    QWORD PTR [rsp+0x28],rax
    204b:	mov    QWORD PTR [rsp+0x70],rax
    2050:	mov    QWORD PTR [rsp+0x30],0x3
    2059:	test   r12,0x1
    2060:	je     2078 <botlish_fn_23+0x170>
    2066:	mov    rcx,r12
    2069:	add    rcx,0x2
    206d:	seto   al
    2070:	test   al,al
    2072:	je     208b <botlish_fn_23+0x183>
    2078:	mov    edx,0x3
    207d:	mov    rsi,r12
    2080:	mov    rdi,r14
    2083:	call   2088 <botlish_fn_23+0x180>
			2084: R_X86_64_PLT32	rt_int_add-0x4
    2088:	mov    rcx,rax
    208b:	mov    QWORD PTR [rsp+0x30],rcx
    2090:	mov    rdx,r12
    2093:	mov    rsi,rbx
    2096:	mov    rdi,r14
    2099:	call   209e <botlish_fn_23+0x196>
			209a: R_X86_64_PLT32	rt_substr-0x4
    209e:	test   rax,rax
    20a1:	je     2170 <botlish_fn_23+0x268>
    20a7:	mov    QWORD PTR [rsp+0x8],rax
    20ac:	mov    rsi,rax
    20af:	mov    r12,r15
    20b2:	mov    rcx,r13
    20b5:	mov    rdx,r12
    20b8:	mov    rdi,r14
    20bb:	call   20c0 <botlish_fn_23+0x1b8>
			20bc: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_char<generic>
    20c0:	test   rax,rax
    20c3:	je     2170 <botlish_fn_23+0x268>
    20c9:	mov    QWORD PTR [rsp+0x8],rax
    20ce:	lea    rcx,[rsp+0x48]
    20d3:	mov    QWORD PTR [rsp+0x48],0x0
    20dc:	mov    r11,QWORD PTR [rsp+0x68]
    20e1:	mov    QWORD PTR [rsp+0x50],r11
    20e6:	mov    QWORD PTR [rsp+0x58],0x0
    20ef:	mov    QWORD PTR [rsp+0x60],rax
    20f4:	mov    esi,0x2
    20f9:	mov    edx,0x4
    20fe:	mov    rdi,r14
    2101:	call   2106 <botlish_fn_23+0x1fe>
			2102: R_X86_64_PLT32	rt_construct-0x4
    2106:	test   rax,rax
    2109:	je     2170 <botlish_fn_23+0x268>
    210f:	mov    QWORD PTR [rsp],rbx
    2113:	mov    rcx,QWORD PTR [rsp+0x70]
    2118:	mov    QWORD PTR [rsp+0x8],rcx
    211d:	mov    QWORD PTR [rsp+0x10],rax
    2122:	mov    QWORD PTR [rsp+0x18],r12
    2127:	mov    QWORD PTR [rsp+0x20],r13
    212c:	mov    QWORD PTR [rsp+0x68],rax
    2131:	mov    r15,r12
    2134:	mov    r12,rcx
    2137:	mov    rsi,rbx
    213a:	jmp    1f76 <botlish_fn_23+0x6e>
    213f:	mov    r11,QWORD PTR [rsp+0x68]
    2144:	xor    rsi,rsi
    2147:	lea    rcx,[rsp+0x38]
    214c:	mov    QWORD PTR [rsp+0x38],0x0
    2155:	mov    QWORD PTR [rsp+0x40],r11
    215a:	mov    edx,0x2
    215f:	mov    rdi,r14
    2162:	call   2167 <botlish_fn_23+0x25f>
			2163: R_X86_64_PLT32	rt_construct-0x4
    2167:	test   rax,rax
    216a:	jne    21a7 <botlish_fn_23+0x29f>
    2170:	xor    rax,rax
    2173:	mov    rbx,QWORD PTR [rsp+0x80]
    217b:	mov    r12,QWORD PTR [rsp+0x88]
    2183:	mov    r13,QWORD PTR [rsp+0x90]
    218b:	mov    r14,QWORD PTR [rsp+0x98]
    2193:	mov    r15,QWORD PTR [rsp+0xa0]
    219b:	add    rsp,0xb0
    21a2:	mov    rsp,rbp
    21a5:	pop    rbp
    21a6:	ret
    21a7:	mov    rbx,QWORD PTR [rsp+0x80]
    21af:	mov    r12,QWORD PTR [rsp+0x88]
    21b7:	mov    r13,QWORD PTR [rsp+0x90]
    21bf:	mov    r14,QWORD PTR [rsp+0x98]
    21c7:	mov    r15,QWORD PTR [rsp+0xa0]
    21cf:	add    rsp,0xb0
    21d6:	mov    rsp,rbp
    21d9:	pop    rbp
    21da:	ret
    21db:	add    BYTE PTR [rax],al
    21dd:	add    BYTE PTR [rax],al
    21df:	add    BYTE PTR [rsi],al
    21e1:	add    BYTE PTR [rax],al
    21e3:	add    BYTE PTR [rax],al
    21e5:	add    BYTE PTR [rax],al
	...

00000000000021e8 <botlish_entry_23: esc_from<generic>>:
    21e8:	push   rbp
    21e9:	mov    rbp,rsp
    21ec:	mov    rsi,QWORD PTR [rdx]
    21ef:	mov    r10,QWORD PTR [rdx+0x8]
    21f3:	mov    rcx,QWORD PTR [rdx+0x10]
    21f7:	mov    r8,QWORD PTR [rdx+0x18]
    21fb:	mov    r9,QWORD PTR [rdx+0x20]
    21ff:	mov    rdx,r10
    2202:	call   2207 <botlish_entry_23+0x1f>
			2203: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_from<generic>
    2207:	mov    rsp,rbp
    220a:	pop    rbp
    220b:	ret

000000000000220c <botlish_fn_24: check<int, int, str, str>>:
    220c:	push   rbp
    220d:	mov    rbp,rsp
    2210:	sub    rsp,0x50
    2214:	mov    QWORD PTR [rsp+0x20],rbx
    2219:	mov    QWORD PTR [rsp+0x28],r12
    221e:	mov    QWORD PTR [rsp+0x30],r13
    2223:	mov    QWORD PTR [rsp+0x38],r14
    2228:	mov    QWORD PTR [rsp+0x40],r15
    222d:	mov    r14,rdi
    2230:	mov    QWORD PTR [rsp+0x18],0x0
    2239:	mov    QWORD PTR [rsp],rdx
    223d:	mov    QWORD PTR [rsp+0x8],rcx
    2242:	mov    QWORD PTR [rsp+0x10],r8
    2247:	mov    r13,r8
    224a:	sar    rsi,1
    224d:	mov    r12,rsi
    2250:	mov    r15,rdx
    2253:	test   r12,r12
    2256:	jle    2318 <botlish_fn_24+0x10c>
    225c:	mov    rbx,rcx
    225f:	mov    rsi,rbx
    2262:	mov    rdi,r14
    2265:	call   226a <botlish_fn_24+0x5e>
			2266: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_emailish<str>
    226a:	test   rax,rax
    226d:	jne    2298 <botlish_fn_24+0x8c>
    2273:	xor    rax,rax
    2276:	mov    rbx,QWORD PTR [rsp+0x20]
    227b:	mov    r12,QWORD PTR [rsp+0x28]
    2280:	mov    r13,QWORD PTR [rsp+0x30]
    2285:	mov    r14,QWORD PTR [rsp+0x38]
    228a:	mov    r15,QWORD PTR [rsp+0x40]
    228f:	add    rsp,0x50
    2293:	mov    rsp,rbp
    2296:	pop    rbp
    2297:	ret
    2298:	cmp    rax,0x6
    229c:	je     22b8 <botlish_fn_24+0xac>
    22a2:	mov    edx,0x1
    22a7:	mov    QWORD PTR [rsp+0x18],0x1
    22b0:	mov    rsi,r15
    22b3:	jmp    22c9 <botlish_fn_24+0xbd>
    22b8:	mov    edx,0x3
    22bd:	mov    QWORD PTR [rsp+0x18],0x3
    22c6:	mov    rsi,r15
    22c9:	mov    rax,rsi
    22cc:	and    rax,rdx
    22cf:	test   rax,0x1
    22d5:	je     22f0 <botlish_fn_24+0xe4>
    22db:	lea    rcx,[rdx-0x1]
    22df:	mov    rax,rsi
    22e2:	add    rax,rcx
    22e5:	seto   cl
    22e8:	test   cl,cl
    22ea:	je     22f8 <botlish_fn_24+0xec>
    22f0:	mov    rdi,r14
    22f3:	call   22f8 <botlish_fn_24+0xec>
			22f4: R_X86_64_PLT32	rt_int_add-0x4
    22f8:	mov    QWORD PTR [rsp],rax
    22fc:	mov    QWORD PTR [rsp+0x8],rbx
    2301:	mov    r8,r13
    2304:	mov    QWORD PTR [rsp+0x10],r8
    2309:	sub    r12,0x1
    230d:	mov    rcx,rbx
    2310:	mov    r15,rax
    2313:	jmp    2253 <botlish_fn_24+0x47>
    2318:	mov    rax,r15
    231b:	mov    rbx,QWORD PTR [rsp+0x20]
    2320:	mov    r12,QWORD PTR [rsp+0x28]
    2325:	mov    r13,QWORD PTR [rsp+0x30]
    232a:	mov    r14,QWORD PTR [rsp+0x38]
    232f:	mov    r15,QWORD PTR [rsp+0x40]
    2334:	add    rsp,0x50
    2338:	mov    rsp,rbp
    233b:	pop    rbp
    233c:	ret

000000000000233d <botlish_entry_24: check<int, int, str, str>>:
    233d:	push   rbp
    233e:	mov    rbp,rsp
    2341:	mov    rsi,QWORD PTR [rdx]
    2344:	mov    r9,QWORD PTR [rdx+0x8]
    2348:	mov    rcx,QWORD PTR [rdx+0x10]
    234c:	mov    r8,QWORD PTR [rdx+0x18]
    2350:	mov    rdx,r9
    2353:	call   2358 <botlish_entry_24+0x1b>
			2354: R_X86_64_PLT32	botlish_fn_24-0x4 ; check<int, int, str, str>
    2358:	mov    rsp,rbp
    235b:	pop    rbp
    235c:	ret

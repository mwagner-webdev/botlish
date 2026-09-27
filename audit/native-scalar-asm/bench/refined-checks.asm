; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 9868  (per function: 1172 39 289 617 74 74 74 125 125 681 262 932 588 468 452 644 155 125 103 453 758 486 828 344)
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
;   botlish_fn_11 / botlish_entry_11 -> scan_local<generic>
;   botlish_fn_12 / botlish_entry_12 -> scan_label<generic>
;   botlish_fn_13 / botlish_entry_13 -> scan_alpha<generic>
;   botlish_fn_14 / botlish_entry_14 -> tld_ok<generic>
;   botlish_fn_15 / botlish_entry_15 -> domain_loop<generic>
;   botlish_fn_16 / botlish_entry_16 -> web::is_unreserved<generic>
;   botlish_fn_17 / botlish_entry_17 -> web::uri_escape_text<generic>
;   botlish_fn_18 / botlish_entry_18 -> high_nibble<generic>
;   botlish_fn_19 / botlish_entry_19 -> hex_pair<generic>
;   botlish_fn_20 / botlish_entry_20 -> esc_bytes<generic>
;   botlish_fn_21 / botlish_entry_21 -> esc_char<generic>
;   botlish_fn_22 / botlish_entry_22 -> esc_from<generic>
;   botlish_fn_23 / botlish_entry_23 -> check<int, int, str, str>


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
     29d:	mov    esi,0x10
     2a2:	mov    rdx,QWORD PTR [rip+0x0]        # 2a9 <botlish_fn_0+0x2a9>
			2a5: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; web::is_unreserved<generic>
     2a9:	mov    ecx,0x1
     2ae:	mov    rdi,QWORD PTR [rsp+0x148]
     2b6:	call   2bb <botlish_fn_0+0x2bb>
			2b7: R_X86_64_PLT32	rt_closure_new-0x4
     2bb:	mov    QWORD PTR [rsp+0x8],rax
     2c0:	lea    r8,[rsp+0x128]
     2c8:	mov    rcx,rbx
     2cb:	mov    QWORD PTR [rsp+0x128],rcx
     2d3:	mov    QWORD PTR [rsp+0x130],rax
     2db:	mov    esi,0x11
     2e0:	mov    rdx,QWORD PTR [rip+0x0]        # 2e7 <botlish_fn_0+0x2e7>
			2e3: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; web::uri_escape_text<generic>
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
			319: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::uri_escape_text<generic>
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
			36d: R_X86_64_PLT32	botlish_fn_23-0x4 ; check<int, int, str, str>
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
			3ba: R_X86_64_PLT32	botlish_fn_23-0x4 ; check<int, int, str, str>
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
     9d4:	sub    rsp,0x50
     9d8:	mov    QWORD PTR [rsp+0x30],rbx
     9dd:	mov    QWORD PTR [rsp+0x38],r12
     9e2:	mov    QWORD PTR [rsp+0x40],r13
     9e7:	mov    QWORD PTR [rsp+0x48],r14
     9ec:	mov    r13,rdi
     9ef:	mov    QWORD PTR [rsp+0x18],0x0
     9f8:	mov    QWORD PTR [rsp],rsi
     9fc:	mov    r14,rsi
     9ff:	mov    rsi,r14
     a02:	mov    rdi,r13
     a05:	call   a0a <botlish_fn_9+0x3a>
			a06: R_X86_64_PLT32	rt_str_len-0x4
     a0a:	mov    rbx,rax
     a0d:	mov    QWORD PTR [rsp+0x8],rax
     a12:	mov    esi,0x1
     a17:	mov    QWORD PTR [rsp+0x10],0x1
     a20:	mov    rcx,r14
     a23:	mov    rdx,rbx
     a26:	mov    rdi,r13
     a29:	call   a2e <botlish_fn_9+0x5e>
			a2a: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_local<generic>
     a2e:	mov    r12,rax
     a31:	test   r12,r12
     a34:	je     b91 <botlish_fn_9+0x1c1>
     a3a:	mov    QWORD PTR [rsp+0x10],r12
     a3f:	test   r12,0x1
     a46:	jne    a71 <botlish_fn_9+0xa1>
     a4c:	mov    edx,0x1
     a51:	mov    rsi,r12
     a54:	mov    rdi,r13
     a57:	call   a5c <botlish_fn_9+0x8c>
			a58: R_X86_64_PLT32	rt_int_cmp-0x4
     a5c:	mov    ecx,0x2
     a61:	test   rax,rax
     a64:	cmove  rcx,QWORD PTR [rip+0x1c4]        # c30 <botlish_fn_9+0x260>
     a6c:	jmp    a82 <botlish_fn_9+0xb2>
     a71:	mov    ecx,0x2
     a76:	cmp    r12,0x1
     a7a:	cmove  rcx,QWORD PTR [rip+0x1ae]        # c30 <botlish_fn_9+0x260>
     a82:	cmp    rcx,0x6
     a86:	je     c0c <botlish_fn_9+0x23c>
     a8c:	mov    rcx,r12
     a8f:	and    rcx,rbx
     a92:	test   rcx,0x1
     a99:	jne    ac2 <botlish_fn_9+0xf2>
     a9f:	mov    rdx,rbx
     aa2:	mov    rsi,r12
     aa5:	mov    rdi,r13
     aa8:	call   aad <botlish_fn_9+0xdd>
			aa9: R_X86_64_PLT32	rt_int_cmp-0x4
     aad:	mov    ecx,0x2
     ab2:	test   rax,rax
     ab5:	cmovge rcx,QWORD PTR [rip+0x173]        # c30 <botlish_fn_9+0x260>
     abd:	jmp    ad2 <botlish_fn_9+0x102>
     ac2:	mov    ecx,0x2
     ac7:	cmp    r12,rbx
     aca:	cmovge rcx,QWORD PTR [rip+0x15e]        # c30 <botlish_fn_9+0x260>
     ad2:	cmp    rcx,0x6
     ad6:	je     c02 <botlish_fn_9+0x232>
     adc:	lea    rcx,[rsp+0x20]
     ae1:	mov    rdx,r14
     ae4:	mov    rsi,r12
     ae7:	mov    rdi,r13
     aea:	call   aef <botlish_fn_9+0x11f>
			aeb: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
     aef:	test   rax,rax
     af2:	mov    rsi,rax
     af5:	je     b91 <botlish_fn_9+0x1c1>
     afb:	mov    rdx,QWORD PTR [rsp+0x20]
     b00:	mov    rcx,QWORD PTR [rsp+0x28]
     b05:	mov    rdi,r13
     b08:	mov    rax,QWORD PTR [rdi+0x10]
     b0c:	mov    r8,QWORD PTR [rax+0xa0]
     b13:	call   b18 <botlish_fn_9+0x148>
			b14: R_X86_64_PLT32	rt_str_region_eq-0x4
     b18:	cmp    rax,0x6
     b1c:	je     b2f <botlish_fn_9+0x15f>
     b22:	mov    ecx,0x2
     b27:	mov    rax,rcx
     b2a:	jmp    c11 <botlish_fn_9+0x241>
     b2f:	mov    QWORD PTR [rsp+0x18],0x3
     b38:	test   r12,0x1
     b3f:	jne    b4d <botlish_fn_9+0x17d>
     b45:	mov    rcx,r12
     b48:	jmp    b62 <botlish_fn_9+0x192>
     b4d:	mov    rsi,r12
     b50:	add    rsi,0x2
     b54:	mov    rcx,r12
     b57:	seto   al
     b5a:	test   al,al
     b5c:	je     b75 <botlish_fn_9+0x1a5>
     b62:	mov    edx,0x3
     b67:	mov    rsi,rcx
     b6a:	mov    rdi,r13
     b6d:	call   b72 <botlish_fn_9+0x1a2>
			b6e: R_X86_64_PLT32	rt_int_add-0x4
     b72:	mov    rsi,rax
     b75:	mov    QWORD PTR [rsp+0x10],rsi
     b7a:	mov    rcx,r14
     b7d:	mov    rdx,rbx
     b80:	mov    rdi,r13
     b83:	call   b88 <botlish_fn_9+0x1b8>
			b84: R_X86_64_PLT32	botlish_fn_15-0x4 ; domain_loop<generic>
     b88:	test   rax,rax
     b8b:	jne    bb1 <botlish_fn_9+0x1e1>
     b91:	xor    rax,rax
     b94:	mov    rbx,QWORD PTR [rsp+0x30]
     b99:	mov    r12,QWORD PTR [rsp+0x38]
     b9e:	mov    r13,QWORD PTR [rsp+0x40]
     ba3:	mov    r14,QWORD PTR [rsp+0x48]
     ba8:	add    rsp,0x50
     bac:	mov    rsp,rbp
     baf:	pop    rbp
     bb0:	ret
     bb1:	mov    rcx,rax
     bb4:	and    rcx,rbx
     bb7:	mov    rsi,rax
     bba:	test   rcx,0x1
     bc1:	jne    bea <botlish_fn_9+0x21a>
     bc7:	mov    rdx,rbx
     bca:	mov    rdi,r13
     bcd:	call   bd2 <botlish_fn_9+0x202>
			bce: R_X86_64_PLT32	rt_int_cmp-0x4
     bd2:	mov    ecx,0x2
     bd7:	test   rax,rax
     bda:	mov    rax,rcx
     bdd:	cmove  rax,QWORD PTR [rip+0x4b]        # c30 <botlish_fn_9+0x260>
     be5:	jmp    c11 <botlish_fn_9+0x241>
     bea:	mov    rdx,rbx
     bed:	mov    eax,0x2
     bf2:	cmp    rsi,rdx
     bf5:	cmove  rax,QWORD PTR [rip+0x33]        # c30 <botlish_fn_9+0x260>
     bfd:	jmp    c11 <botlish_fn_9+0x241>
     c02:	mov    eax,0x2
     c07:	jmp    c11 <botlish_fn_9+0x241>
     c0c:	mov    eax,0x2
     c11:	mov    rbx,QWORD PTR [rsp+0x30]
     c16:	mov    r12,QWORD PTR [rsp+0x38]
     c1b:	mov    r13,QWORD PTR [rsp+0x40]
     c20:	mov    r14,QWORD PTR [rsp+0x48]
     c25:	add    rsp,0x50
     c29:	mov    rsp,rbp
     c2c:	pop    rbp
     c2d:	ret
     c2e:	add    BYTE PTR [rax],al
     c30:	(bad)
     c31:	add    BYTE PTR [rax],al
     c33:	add    BYTE PTR [rax],al
     c35:	add    BYTE PTR [rax],al
	...

0000000000000c38 <botlish_entry_9: web::is_emailish<str>>:
     c38:	push   rbp
     c39:	mov    rbp,rsp
     c3c:	mov    rsi,QWORD PTR [rdx]
     c3f:	call   c44 <botlish_entry_9+0xc>
			c40: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_emailish<str>
     c44:	mov    rsp,rbp
     c47:	pop    rbp
     c48:	ret

0000000000000c49 <botlish_fn_10: char_at<generic>>:
     c49:	push   rbp
     c4a:	mov    rbp,rsp
     c4d:	sub    rsp,0x50
     c51:	mov    QWORD PTR [rsp+0x20],rbx
     c56:	mov    QWORD PTR [rsp+0x28],r12
     c5b:	mov    QWORD PTR [rsp+0x30],r13
     c60:	mov    QWORD PTR [rsp+0x38],r14
     c65:	mov    QWORD PTR [rsp+0x40],r15
     c6a:	mov    r12,rdi
     c6d:	mov    r15,rcx
     c70:	mov    QWORD PTR [rsp],rsi
     c74:	mov    QWORD PTR [rsp+0x8],rdx
     c79:	mov    r13,rdx
     c7c:	mov    QWORD PTR [rsp+0x10],0x3
     c85:	test   rsi,0x1
     c8c:	jne    c9a <botlish_fn_10+0x51>
     c92:	mov    rbx,rsi
     c95:	jmp    cba <botlish_fn_10+0x71>
     c9a:	mov    rax,rsi
     c9d:	add    rax,0x2
     ca1:	mov    rbx,rsi
     ca4:	seto   cl
     ca7:	test   cl,cl
     ca9:	jne    cba <botlish_fn_10+0x71>
     caf:	mov    rdi,r12
     cb2:	mov    r14,rax
     cb5:	jmp    cd0 <botlish_fn_10+0x87>
     cba:	mov    edx,0x3
     cbf:	mov    rsi,rbx
     cc2:	mov    rdi,r12
     cc5:	call   cca <botlish_fn_10+0x81>
			cc6: R_X86_64_PLT32	rt_int_add-0x4
     cca:	mov    r14,rax
     ccd:	mov    rdi,r12
     cd0:	mov    rcx,r14
     cd3:	mov    rdx,rbx
     cd6:	mov    rsi,r13
     cd9:	call   cde <botlish_fn_10+0x95>
			cda: R_X86_64_PLT32	rt_str_region_check-0x4
     cde:	test   rax,rax
     ce1:	jne    d0c <botlish_fn_10+0xc3>
     ce7:	xor    rax,rax
     cea:	mov    rbx,QWORD PTR [rsp+0x20]
     cef:	mov    r12,QWORD PTR [rsp+0x28]
     cf4:	mov    r13,QWORD PTR [rsp+0x30]
     cf9:	mov    r14,QWORD PTR [rsp+0x38]
     cfe:	mov    r15,QWORD PTR [rsp+0x40]
     d03:	add    rsp,0x50
     d07:	mov    rsp,rbp
     d0a:	pop    rbp
     d0b:	ret
     d0c:	mov    rcx,r15
     d0f:	mov    QWORD PTR [rcx],rbx
     d12:	mov    rax,r14
     d15:	mov    QWORD PTR [rcx+0x8],rax
     d19:	mov    rax,r13
     d1c:	mov    rbx,QWORD PTR [rsp+0x20]
     d21:	mov    r12,QWORD PTR [rsp+0x28]
     d26:	mov    r13,QWORD PTR [rsp+0x30]
     d2b:	mov    r14,QWORD PTR [rsp+0x38]
     d30:	mov    r15,QWORD PTR [rsp+0x40]
     d35:	add    rsp,0x50
     d39:	mov    rsp,rbp
     d3c:	pop    rbp
     d3d:	ret

0000000000000d3e <botlish_entry_10: char_at<generic>>:
     d3e:	push   rbp
     d3f:	mov    rbp,rsp
     d42:	ud2
     d44:	add    BYTE PTR [rax],al
	...

0000000000000d48 <botlish_fn_11: scan_local<generic>>:
     d48:	push   rbp
     d49:	mov    rbp,rsp
     d4c:	sub    rsp,0x80
     d53:	mov    QWORD PTR [rsp+0x50],rbx
     d58:	mov    QWORD PTR [rsp+0x58],r12
     d5d:	mov    QWORD PTR [rsp+0x60],r13
     d62:	mov    QWORD PTR [rsp+0x68],r14
     d67:	mov    QWORD PTR [rsp+0x70],r15
     d6c:	mov    r9,rdi
     d6f:	mov    QWORD PTR [rsp+0x18],0x0
     d78:	mov    QWORD PTR [rsp],rsi
     d7c:	mov    r15,rsi
     d7f:	mov    QWORD PTR [rsp+0x8],rdx
     d84:	mov    QWORD PTR [rsp+0x10],rcx
     d89:	mov    r12,rcx
     d8c:	lea    r14,[rsp+0x20]
     d91:	mov    r13,rdx
     d94:	mov    rdi,rsi
     d97:	and    rdi,r13
     d9a:	mov    r15,rsi
     d9d:	test   rdi,0x1
     da4:	jne    dd0 <botlish_fn_11+0x88>
     daa:	mov    rbx,r9
     dad:	mov    rdx,r13
     db0:	mov    rsi,r15
     db3:	mov    rdi,rbx
     db6:	call   dbb <botlish_fn_11+0x73>
			db7: R_X86_64_PLT32	rt_int_cmp-0x4
     dbb:	mov    ecx,0x2
     dc0:	test   rax,rax
     dc3:	cmovge rcx,QWORD PTR [rip+0x2c5]        # 1090 <botlish_fn_11+0x348>
     dcb:	jmp    de6 <botlish_fn_11+0x9e>
     dd0:	mov    rbx,r9
     dd3:	mov    ecx,0x2
     dd8:	mov    rsi,r15
     ddb:	cmp    rsi,r13
     dde:	cmovge rcx,QWORD PTR [rip+0x2aa]        # 1090 <botlish_fn_11+0x348>
     de6:	cmp    rcx,0x6
     dea:	je     1065 <botlish_fn_11+0x31d>
     df0:	mov    rcx,r14
     df3:	mov    rdx,r12
     df6:	mov    rsi,r15
     df9:	mov    rdi,rbx
     dfc:	call   e01 <botlish_fn_11+0xb9>
			dfd: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
     e01:	mov    rcx,rax
     e04:	mov    QWORD PTR [rsp+0x40],rax
     e09:	test   rax,rcx
     e0c:	je     e3c <botlish_fn_11+0xf4>
     e12:	mov    rdx,QWORD PTR [rsp+0x20]
     e17:	mov    QWORD PTR [rsp+0x38],rdx
     e1c:	mov    rcx,QWORD PTR [rsp+0x28]
     e21:	mov    QWORD PTR [rsp+0x30],rcx
     e26:	mov    rsi,QWORD PTR [rsp+0x40]
     e2b:	mov    rdi,rbx
     e2e:	call   e33 <botlish_fn_11+0xeb>
			e2f: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
     e33:	test   rax,rax
     e36:	jne    e64 <botlish_fn_11+0x11c>
     e3c:	xor    rax,rax
     e3f:	mov    rbx,QWORD PTR [rsp+0x50]
     e44:	mov    r12,QWORD PTR [rsp+0x58]
     e49:	mov    r13,QWORD PTR [rsp+0x60]
     e4e:	mov    r14,QWORD PTR [rsp+0x68]
     e53:	mov    r15,QWORD PTR [rsp+0x70]
     e58:	add    rsp,0x80
     e5f:	mov    rsp,rbp
     e62:	pop    rbp
     e63:	ret
     e64:	cmp    rax,0x6
     e68:	je     eae <botlish_fn_11+0x166>
     e6e:	mov    rax,QWORD PTR [rbx+0x10]
     e72:	mov    r8,QWORD PTR [rax+0xa8]
     e79:	mov    rcx,QWORD PTR [rsp+0x30]
     e7e:	mov    rdx,QWORD PTR [rsp+0x38]
     e83:	mov    rsi,QWORD PTR [rsp+0x40]
     e88:	mov    rdi,rbx
     e8b:	call   e90 <botlish_fn_11+0x148>
			e8c: R_X86_64_PLT32	rt_str_region_eq-0x4
     e90:	cmp    rax,0x6
     e94:	je     ea4 <botlish_fn_11+0x15c>
     e9a:	mov    ecx,0x2
     e9f:	jmp    eb3 <botlish_fn_11+0x16b>
     ea4:	mov    ecx,0x6
     ea9:	jmp    eb3 <botlish_fn_11+0x16b>
     eae:	mov    ecx,0x6
     eb3:	cmp    rcx,0x6
     eb7:	je     efd <botlish_fn_11+0x1b5>
     ebd:	mov    rax,QWORD PTR [rbx+0x10]
     ec1:	mov    r8,QWORD PTR [rax+0xb0]
     ec8:	mov    rcx,QWORD PTR [rsp+0x30]
     ecd:	mov    rdx,QWORD PTR [rsp+0x38]
     ed2:	mov    rsi,QWORD PTR [rsp+0x40]
     ed7:	mov    rdi,rbx
     eda:	call   edf <botlish_fn_11+0x197>
			edb: R_X86_64_PLT32	rt_str_region_eq-0x4
     edf:	cmp    rax,0x6
     ee3:	je     ef3 <botlish_fn_11+0x1ab>
     ee9:	mov    ecx,0x2
     eee:	jmp    f02 <botlish_fn_11+0x1ba>
     ef3:	mov    ecx,0x6
     ef8:	jmp    f02 <botlish_fn_11+0x1ba>
     efd:	mov    ecx,0x6
     f02:	cmp    rcx,0x6
     f06:	je     f4c <botlish_fn_11+0x204>
     f0c:	mov    rax,QWORD PTR [rbx+0x10]
     f10:	mov    r8,QWORD PTR [rax+0xb8]
     f17:	mov    rcx,QWORD PTR [rsp+0x30]
     f1c:	mov    rdx,QWORD PTR [rsp+0x38]
     f21:	mov    rsi,QWORD PTR [rsp+0x40]
     f26:	mov    rdi,rbx
     f29:	call   f2e <botlish_fn_11+0x1e6>
			f2a: R_X86_64_PLT32	rt_str_region_eq-0x4
     f2e:	cmp    rax,0x6
     f32:	je     f42 <botlish_fn_11+0x1fa>
     f38:	mov    ecx,0x2
     f3d:	jmp    f51 <botlish_fn_11+0x209>
     f42:	mov    ecx,0x6
     f47:	jmp    f51 <botlish_fn_11+0x209>
     f4c:	mov    ecx,0x6
     f51:	cmp    rcx,0x6
     f55:	je     f9b <botlish_fn_11+0x253>
     f5b:	mov    rax,QWORD PTR [rbx+0x10]
     f5f:	mov    r8,QWORD PTR [rax+0xc0]
     f66:	mov    rcx,QWORD PTR [rsp+0x30]
     f6b:	mov    rdx,QWORD PTR [rsp+0x38]
     f70:	mov    rsi,QWORD PTR [rsp+0x40]
     f75:	mov    rdi,rbx
     f78:	call   f7d <botlish_fn_11+0x235>
			f79: R_X86_64_PLT32	rt_str_region_eq-0x4
     f7d:	cmp    rax,0x6
     f81:	je     f91 <botlish_fn_11+0x249>
     f87:	mov    eax,0x2
     f8c:	jmp    fa0 <botlish_fn_11+0x258>
     f91:	mov    eax,0x6
     f96:	jmp    fa0 <botlish_fn_11+0x258>
     f9b:	mov    eax,0x6
     fa0:	cmp    rax,0x6
     fa4:	je     fea <botlish_fn_11+0x2a2>
     faa:	mov    rax,QWORD PTR [rbx+0x10]
     fae:	mov    r8,QWORD PTR [rax+0xc8]
     fb5:	mov    rcx,QWORD PTR [rsp+0x30]
     fba:	mov    rdx,QWORD PTR [rsp+0x38]
     fbf:	mov    rsi,QWORD PTR [rsp+0x40]
     fc4:	mov    rdi,rbx
     fc7:	call   fcc <botlish_fn_11+0x284>
			fc8: R_X86_64_PLT32	rt_str_region_eq-0x4
     fcc:	cmp    rax,0x6
     fd0:	je     fe0 <botlish_fn_11+0x298>
     fd6:	mov    eax,0x2
     fdb:	jmp    fef <botlish_fn_11+0x2a7>
     fe0:	mov    eax,0x6
     fe5:	jmp    fef <botlish_fn_11+0x2a7>
     fea:	mov    eax,0x6
     fef:	cmp    rax,0x6
     ff3:	je     1001 <botlish_fn_11+0x2b9>
     ff9:	mov    rax,r15
     ffc:	jmp    1068 <botlish_fn_11+0x320>
    1001:	mov    QWORD PTR [rsp+0x18],0x3
    100a:	mov    rsi,r15
    100d:	test   rsi,0x1
    1014:	je     1036 <botlish_fn_11+0x2ee>
    101a:	mov    rsi,r15
    101d:	add    rsi,0x2
    1021:	seto   r8b
    1025:	test   r8b,r8b
    1028:	jne    1036 <botlish_fn_11+0x2ee>
    102e:	mov    r15,rsi
    1031:	jmp    104c <botlish_fn_11+0x304>
    1036:	mov    edx,0x3
    103b:	mov    rsi,r15
    103e:	mov    rdi,rbx
    1041:	call   1046 <botlish_fn_11+0x2fe>
			1042: R_X86_64_PLT32	rt_int_add-0x4
    1046:	mov    rsi,rax
    1049:	mov    r15,rax
    104c:	mov    QWORD PTR [rsp],rsi
    1050:	mov    QWORD PTR [rsp+0x8],r13
    1055:	mov    QWORD PTR [rsp+0x10],r12
    105a:	mov    rsi,r15
    105d:	mov    r9,rbx
    1060:	jmp    d94 <botlish_fn_11+0x4c>
    1065:	mov    rax,r15
    1068:	mov    rbx,QWORD PTR [rsp+0x50]
    106d:	mov    r12,QWORD PTR [rsp+0x58]
    1072:	mov    r13,QWORD PTR [rsp+0x60]
    1077:	mov    r14,QWORD PTR [rsp+0x68]
    107c:	mov    r15,QWORD PTR [rsp+0x70]
    1081:	add    rsp,0x80
    1088:	mov    rsp,rbp
    108b:	pop    rbp
    108c:	ret
    108d:	add    BYTE PTR [rax],al
    108f:	add    BYTE PTR [rsi],al
    1091:	add    BYTE PTR [rax],al
    1093:	add    BYTE PTR [rax],al
    1095:	add    BYTE PTR [rax],al
	...

0000000000001098 <botlish_entry_11: scan_local<generic>>:
    1098:	push   rbp
    1099:	mov    rbp,rsp
    109c:	mov    rsi,QWORD PTR [rdx]
    109f:	mov    r8,QWORD PTR [rdx+0x8]
    10a3:	mov    rcx,QWORD PTR [rdx+0x10]
    10a7:	mov    rdx,r8
    10aa:	call   10af <botlish_entry_11+0x17>
			10ab: R_X86_64_PLT32	botlish_fn_11-0x4 ; scan_local<generic>
    10af:	mov    rsp,rbp
    10b2:	pop    rbp
    10b3:	ret
    10b4:	add    BYTE PTR [rax],al
	...

00000000000010b8 <botlish_fn_12: scan_label<generic>>:
    10b8:	push   rbp
    10b9:	mov    rbp,rsp
    10bc:	sub    rsp,0x80
    10c3:	mov    QWORD PTR [rsp+0x50],rbx
    10c8:	mov    QWORD PTR [rsp+0x58],r12
    10cd:	mov    QWORD PTR [rsp+0x60],r13
    10d2:	mov    QWORD PTR [rsp+0x68],r14
    10d7:	mov    QWORD PTR [rsp+0x70],r15
    10dc:	mov    QWORD PTR [rsp+0x18],0x0
    10e5:	mov    QWORD PTR [rsp],rsi
    10e9:	mov    r15,rsi
    10ec:	mov    QWORD PTR [rsp+0x8],rdx
    10f1:	mov    QWORD PTR [rsp+0x10],rcx
    10f6:	mov    r13,rcx
    10f9:	lea    r14,[rsp+0x20]
    10fe:	mov    rbx,rdx
    1101:	mov    rax,rsi
    1104:	and    rax,rbx
    1107:	mov    r15,rsi
    110a:	test   rax,0x1
    1110:	jne    1139 <botlish_fn_12+0x81>
    1116:	mov    r12,rdi
    1119:	mov    rdx,rbx
    111c:	mov    rsi,r15
    111f:	call   1124 <botlish_fn_12+0x6c>
			1120: R_X86_64_PLT32	rt_int_cmp-0x4
    1124:	mov    ecx,0x2
    1129:	test   rax,rax
    112c:	cmovge rcx,QWORD PTR [rip+0x184]        # 12b8 <botlish_fn_12+0x200>
    1134:	jmp    114f <botlish_fn_12+0x97>
    1139:	mov    r12,rdi
    113c:	mov    ecx,0x2
    1141:	mov    rsi,r15
    1144:	cmp    rsi,rbx
    1147:	cmovge rcx,QWORD PTR [rip+0x169]        # 12b8 <botlish_fn_12+0x200>
    114f:	cmp    rcx,0x6
    1153:	je     1290 <botlish_fn_12+0x1d8>
    1159:	mov    rcx,r14
    115c:	mov    rdx,r13
    115f:	mov    rsi,r15
    1162:	mov    rdi,r12
    1165:	call   116a <botlish_fn_12+0xb2>
			1166: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    116a:	test   rax,rax
    116d:	mov    QWORD PTR [rsp+0x40],rax
    1172:	je     11a2 <botlish_fn_12+0xea>
    1178:	mov    rdx,QWORD PTR [rsp+0x20]
    117d:	mov    QWORD PTR [rsp+0x38],rdx
    1182:	mov    rcx,QWORD PTR [rsp+0x28]
    1187:	mov    QWORD PTR [rsp+0x30],rcx
    118c:	mov    rsi,QWORD PTR [rsp+0x40]
    1191:	mov    rdi,r12
    1194:	call   1199 <botlish_fn_12+0xe1>
			1195: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1199:	test   rax,rax
    119c:	jne    11ca <botlish_fn_12+0x112>
    11a2:	xor    rax,rax
    11a5:	mov    rbx,QWORD PTR [rsp+0x50]
    11aa:	mov    r12,QWORD PTR [rsp+0x58]
    11af:	mov    r13,QWORD PTR [rsp+0x60]
    11b4:	mov    r14,QWORD PTR [rsp+0x68]
    11b9:	mov    r15,QWORD PTR [rsp+0x70]
    11be:	add    rsp,0x80
    11c5:	mov    rsp,rbp
    11c8:	pop    rbp
    11c9:	ret
    11ca:	cmp    rax,0x6
    11ce:	je     1215 <botlish_fn_12+0x15d>
    11d4:	mov    rax,QWORD PTR [r12+0x10]
    11d9:	mov    r8,QWORD PTR [rax+0xc8]
    11e0:	mov    rcx,QWORD PTR [rsp+0x30]
    11e5:	mov    rdx,QWORD PTR [rsp+0x38]
    11ea:	mov    rsi,QWORD PTR [rsp+0x40]
    11ef:	mov    rdi,r12
    11f2:	call   11f7 <botlish_fn_12+0x13f>
			11f3: R_X86_64_PLT32	rt_str_region_eq-0x4
    11f7:	cmp    rax,0x6
    11fb:	je     120b <botlish_fn_12+0x153>
    1201:	mov    ecx,0x2
    1206:	jmp    121a <botlish_fn_12+0x162>
    120b:	mov    ecx,0x6
    1210:	jmp    121a <botlish_fn_12+0x162>
    1215:	mov    ecx,0x6
    121a:	cmp    rcx,0x6
    121e:	je     122c <botlish_fn_12+0x174>
    1224:	mov    rax,r15
    1227:	jmp    1293 <botlish_fn_12+0x1db>
    122c:	mov    QWORD PTR [rsp+0x18],0x3
    1235:	mov    rsi,r15
    1238:	test   rsi,0x1
    123f:	je     1261 <botlish_fn_12+0x1a9>
    1245:	mov    rsi,r15
    1248:	add    rsi,0x2
    124c:	seto   dil
    1250:	test   dil,dil
    1253:	jne    1261 <botlish_fn_12+0x1a9>
    1259:	mov    r15,rsi
    125c:	jmp    1277 <botlish_fn_12+0x1bf>
    1261:	mov    edx,0x3
    1266:	mov    rsi,r15
    1269:	mov    rdi,r12
    126c:	call   1271 <botlish_fn_12+0x1b9>
			126d: R_X86_64_PLT32	rt_int_add-0x4
    1271:	mov    rsi,rax
    1274:	mov    r15,rax
    1277:	mov    QWORD PTR [rsp],rsi
    127b:	mov    QWORD PTR [rsp+0x8],rbx
    1280:	mov    QWORD PTR [rsp+0x10],r13
    1285:	mov    rsi,r15
    1288:	mov    rdi,r12
    128b:	jmp    1101 <botlish_fn_12+0x49>
    1290:	mov    rax,r15
    1293:	mov    rbx,QWORD PTR [rsp+0x50]
    1298:	mov    r12,QWORD PTR [rsp+0x58]
    129d:	mov    r13,QWORD PTR [rsp+0x60]
    12a2:	mov    r14,QWORD PTR [rsp+0x68]
    12a7:	mov    r15,QWORD PTR [rsp+0x70]
    12ac:	add    rsp,0x80
    12b3:	mov    rsp,rbp
    12b6:	pop    rbp
    12b7:	ret
    12b8:	(bad)
    12b9:	add    BYTE PTR [rax],al
    12bb:	add    BYTE PTR [rax],al
    12bd:	add    BYTE PTR [rax],al
	...

00000000000012c0 <botlish_entry_12: scan_label<generic>>:
    12c0:	push   rbp
    12c1:	mov    rbp,rsp
    12c4:	mov    rsi,QWORD PTR [rdx]
    12c7:	mov    r8,QWORD PTR [rdx+0x8]
    12cb:	mov    rcx,QWORD PTR [rdx+0x10]
    12cf:	mov    rdx,r8
    12d2:	call   12d7 <botlish_entry_12+0x17>
			12d3: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_label<generic>
    12d7:	mov    rsp,rbp
    12da:	pop    rbp
    12db:	ret
    12dc:	add    BYTE PTR [rax],al
	...

00000000000012e0 <botlish_fn_13: scan_alpha<generic>>:
    12e0:	push   rbp
    12e1:	mov    rbp,rsp
    12e4:	sub    rsp,0x60
    12e8:	mov    QWORD PTR [rsp+0x30],rbx
    12ed:	mov    QWORD PTR [rsp+0x38],r12
    12f2:	mov    QWORD PTR [rsp+0x40],r13
    12f7:	mov    QWORD PTR [rsp+0x48],r14
    12fc:	mov    QWORD PTR [rsp+0x50],r15
    1301:	mov    r15,rdi
    1304:	mov    QWORD PTR [rsp+0x18],0x0
    130d:	mov    QWORD PTR [rsp],rsi
    1311:	mov    r14,rsi
    1314:	mov    QWORD PTR [rsp+0x8],rdx
    1319:	mov    QWORD PTR [rsp+0x10],rcx
    131e:	mov    r12,rcx
    1321:	lea    r13,[rsp+0x20]
    1326:	mov    rbx,rdx
    1329:	mov    rax,rsi
    132c:	and    rax,rbx
    132f:	mov    r14,rsi
    1332:	test   rax,0x1
    1338:	jne    1361 <botlish_fn_13+0x81>
    133e:	mov    rdx,rbx
    1341:	mov    rsi,r14
    1344:	mov    rdi,r15
    1347:	call   134c <botlish_fn_13+0x6c>
			1348: R_X86_64_PLT32	rt_int_cmp-0x4
    134c:	mov    ecx,0x2
    1351:	test   rax,rax
    1354:	cmovge rcx,QWORD PTR [rip+0x11c]        # 1478 <botlish_fn_13+0x198>
    135c:	jmp    1374 <botlish_fn_13+0x94>
    1361:	mov    ecx,0x2
    1366:	mov    rsi,r14
    1369:	cmp    rsi,rbx
    136c:	cmovge rcx,QWORD PTR [rip+0x104]        # 1478 <botlish_fn_13+0x198>
    1374:	cmp    rcx,0x6
    1378:	je     1452 <botlish_fn_13+0x172>
    137e:	mov    rcx,r13
    1381:	mov    rdx,r12
    1384:	mov    rsi,r14
    1387:	mov    rdi,r15
    138a:	call   138f <botlish_fn_13+0xaf>
			138b: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    138f:	test   rax,rax
    1392:	mov    rsi,rax
    1395:	je     13b6 <botlish_fn_13+0xd6>
    139b:	mov    rdx,QWORD PTR [rsp+0x20]
    13a0:	mov    rcx,QWORD PTR [rsp+0x28]
    13a5:	mov    rdi,r15
    13a8:	call   13ad <botlish_fn_13+0xcd>
			13a9: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    13ad:	test   rax,rax
    13b0:	jne    13db <botlish_fn_13+0xfb>
    13b6:	xor    rax,rax
    13b9:	mov    rbx,QWORD PTR [rsp+0x30]
    13be:	mov    r12,QWORD PTR [rsp+0x38]
    13c3:	mov    r13,QWORD PTR [rsp+0x40]
    13c8:	mov    r14,QWORD PTR [rsp+0x48]
    13cd:	mov    r15,QWORD PTR [rsp+0x50]
    13d2:	add    rsp,0x60
    13d6:	mov    rsp,rbp
    13d9:	pop    rbp
    13da:	ret
    13db:	cmp    rax,0x6
    13df:	je     13ed <botlish_fn_13+0x10d>
    13e5:	mov    rax,r14
    13e8:	jmp    1455 <botlish_fn_13+0x175>
    13ed:	mov    QWORD PTR [rsp+0x18],0x3
    13f6:	mov    rsi,r14
    13f9:	test   rsi,0x1
    1400:	je     1426 <botlish_fn_13+0x146>
    1406:	mov    rsi,r14
    1409:	mov    rcx,rsi
    140c:	add    rcx,0x2
    1410:	seto   al
    1413:	test   al,al
    1415:	jne    1426 <botlish_fn_13+0x146>
    141b:	mov    rsi,rcx
    141e:	mov    r14,rcx
    1421:	jmp    143c <botlish_fn_13+0x15c>
    1426:	mov    edx,0x3
    142b:	mov    rsi,r14
    142e:	mov    rdi,r15
    1431:	call   1436 <botlish_fn_13+0x156>
			1432: R_X86_64_PLT32	rt_int_add-0x4
    1436:	mov    rsi,rax
    1439:	mov    r14,rax
    143c:	mov    QWORD PTR [rsp],rsi
    1440:	mov    QWORD PTR [rsp+0x8],rbx
    1445:	mov    QWORD PTR [rsp+0x10],r12
    144a:	mov    rsi,r14
    144d:	jmp    1329 <botlish_fn_13+0x49>
    1452:	mov    rax,r14
    1455:	mov    rbx,QWORD PTR [rsp+0x30]
    145a:	mov    r12,QWORD PTR [rsp+0x38]
    145f:	mov    r13,QWORD PTR [rsp+0x40]
    1464:	mov    r14,QWORD PTR [rsp+0x48]
    1469:	mov    r15,QWORD PTR [rsp+0x50]
    146e:	add    rsp,0x60
    1472:	mov    rsp,rbp
    1475:	pop    rbp
    1476:	ret
    1477:	add    BYTE PTR [rsi],al
    1479:	add    BYTE PTR [rax],al
    147b:	add    BYTE PTR [rax],al
    147d:	add    BYTE PTR [rax],al
	...

0000000000001480 <botlish_entry_13: scan_alpha<generic>>:
    1480:	push   rbp
    1481:	mov    rbp,rsp
    1484:	mov    rsi,QWORD PTR [rdx]
    1487:	mov    r8,QWORD PTR [rdx+0x8]
    148b:	mov    rcx,QWORD PTR [rdx+0x10]
    148f:	mov    rdx,r8
    1492:	call   1497 <botlish_entry_13+0x17>
			1493: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_alpha<generic>
    1497:	mov    rsp,rbp
    149a:	pop    rbp
    149b:	ret
    149c:	add    BYTE PTR [rax],al
	...

00000000000014a0 <botlish_fn_14: tld_ok<generic>>:
    14a0:	push   rbp
    14a1:	mov    rbp,rsp
    14a4:	sub    rsp,0x40
    14a8:	mov    QWORD PTR [rsp+0x20],rbx
    14ad:	mov    QWORD PTR [rsp+0x28],r12
    14b2:	mov    QWORD PTR [rsp+0x30],r13
    14b7:	mov    QWORD PTR [rsp+0x38],r14
    14bc:	mov    r12,rdi
    14bf:	mov    QWORD PTR [rsp],rsi
    14c3:	mov    rdi,rsi
    14c6:	mov    QWORD PTR [rsp+0x8],rdx
    14cb:	mov    r14,rdx
    14ce:	mov    QWORD PTR [rsp+0x10],rcx
    14d3:	mov    rbx,rdi
    14d6:	mov    rdx,r14
    14d9:	mov    rsi,rbx
    14dc:	mov    rdi,r12
    14df:	call   14e4 <botlish_fn_14+0x44>
			14e0: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_alpha<generic>
    14e4:	mov    rcx,rax
    14e7:	mov    r13,rax
    14ea:	test   rax,rcx
    14ed:	jne    1513 <botlish_fn_14+0x73>
    14f3:	xor    rax,rax
    14f6:	mov    rbx,QWORD PTR [rsp+0x20]
    14fb:	mov    r12,QWORD PTR [rsp+0x28]
    1500:	mov    r13,QWORD PTR [rsp+0x30]
    1505:	mov    r14,QWORD PTR [rsp+0x38]
    150a:	add    rsp,0x40
    150e:	mov    rsp,rbp
    1511:	pop    rbp
    1512:	ret
    1513:	mov    rax,r13
    1516:	mov    QWORD PTR [rsp+0x8],rax
    151b:	mov    rdx,r14
    151e:	and    rax,rdx
    1521:	test   rax,0x1
    1527:	jne    1550 <botlish_fn_14+0xb0>
    152d:	mov    rsi,r13
    1530:	mov    rdi,r12
    1533:	call   1538 <botlish_fn_14+0x98>
			1534: R_X86_64_PLT32	rt_int_cmp-0x4
    1538:	mov    ecx,0x2
    153d:	test   rax,rax
    1540:	cmove  rcx,QWORD PTR [rip+0xe0]        # 1628 <botlish_fn_14+0x188>
    1548:	mov    rax,r13
    154b:	jmp    1563 <botlish_fn_14+0xc3>
    1550:	mov    ecx,0x2
    1555:	mov    rax,r13
    1558:	cmp    rax,rdx
    155b:	cmove  rcx,QWORD PTR [rip+0xc5]        # 1628 <botlish_fn_14+0x188>
    1563:	cmp    rcx,0x6
    1567:	je     157a <botlish_fn_14+0xda>
    156d:	mov    ecx,0x2
    1572:	mov    rax,rcx
    1575:	jmp    1607 <botlish_fn_14+0x167>
    157a:	mov    rcx,rax
    157d:	and    rcx,rbx
    1580:	test   rcx,0x1
    1587:	jne    1598 <botlish_fn_14+0xf8>
    158d:	mov    rdx,rbx
    1590:	mov    rsi,rax
    1593:	jmp    15b9 <botlish_fn_14+0x119>
    1598:	mov    rcx,rax
    159b:	sub    rcx,rbx
    159e:	mov    rdi,rbx
    15a1:	mov    r13,rax
    15a4:	seto   al
    15a7:	lea    rsi,[rcx+0x1]
    15ab:	test   al,al
    15ad:	je     15c4 <botlish_fn_14+0x124>
    15b3:	mov    rdx,rdi
    15b6:	mov    rsi,r13
    15b9:	mov    rdi,r12
    15bc:	call   15c1 <botlish_fn_14+0x121>
			15bd: R_X86_64_PLT32	rt_int_sub-0x4
    15c1:	mov    rsi,rax
    15c4:	test   rsi,0x1
    15cb:	jne    15f6 <botlish_fn_14+0x156>
    15d1:	mov    edx,0x5
    15d6:	mov    rdi,r12
    15d9:	call   15de <botlish_fn_14+0x13e>
			15da: R_X86_64_PLT32	rt_int_cmp-0x4
    15de:	mov    ecx,0x2
    15e3:	test   rax,rax
    15e6:	mov    rax,rcx
    15e9:	cmovge rax,QWORD PTR [rip+0x37]        # 1628 <botlish_fn_14+0x188>
    15f1:	jmp    1607 <botlish_fn_14+0x167>
    15f6:	mov    eax,0x2
    15fb:	cmp    rsi,0x5
    15ff:	cmovge rax,QWORD PTR [rip+0x21]        # 1628 <botlish_fn_14+0x188>
    1607:	mov    rbx,QWORD PTR [rsp+0x20]
    160c:	mov    r12,QWORD PTR [rsp+0x28]
    1611:	mov    r13,QWORD PTR [rsp+0x30]
    1616:	mov    r14,QWORD PTR [rsp+0x38]
    161b:	add    rsp,0x40
    161f:	mov    rsp,rbp
    1622:	pop    rbp
    1623:	ret
    1624:	add    BYTE PTR [rax],al
    1626:	add    BYTE PTR [rax],al
    1628:	(bad)
    1629:	add    BYTE PTR [rax],al
    162b:	add    BYTE PTR [rax],al
    162d:	add    BYTE PTR [rax],al
	...

0000000000001630 <botlish_entry_14: tld_ok<generic>>:
    1630:	push   rbp
    1631:	mov    rbp,rsp
    1634:	mov    rsi,QWORD PTR [rdx]
    1637:	mov    r8,QWORD PTR [rdx+0x8]
    163b:	mov    rcx,QWORD PTR [rdx+0x10]
    163f:	mov    rdx,r8
    1642:	call   1647 <botlish_entry_14+0x17>
			1643: R_X86_64_PLT32	botlish_fn_14-0x4 ; tld_ok<generic>
    1647:	mov    rsp,rbp
    164a:	pop    rbp
    164b:	ret
    164c:	add    BYTE PTR [rax],al
	...

0000000000001650 <botlish_fn_15: domain_loop<generic>>:
    1650:	push   rbp
    1651:	mov    rbp,rsp
    1654:	sub    rsp,0x70
    1658:	mov    QWORD PTR [rsp+0x40],rbx
    165d:	mov    QWORD PTR [rsp+0x48],r12
    1662:	mov    QWORD PTR [rsp+0x50],r13
    1667:	mov    QWORD PTR [rsp+0x58],r14
    166c:	mov    QWORD PTR [rsp+0x60],r15
    1671:	mov    QWORD PTR [rsp+0x18],0x0
    167a:	mov    QWORD PTR [rsp],rsi
    167e:	mov    QWORD PTR [rsp+0x8],rdx
    1683:	mov    QWORD PTR [rsp+0x10],rcx
    1688:	lea    rbx,[rsp+0x20]
    168d:	mov    r12,rdi
    1690:	mov    r13,rcx
    1693:	mov    r14,rdx
    1696:	mov    QWORD PTR [rsp+0x30],rsi
    169b:	mov    rcx,r13
    169e:	mov    rdx,r14
    16a1:	mov    rsi,QWORD PTR [rsp+0x30]
    16a6:	mov    rdi,r12
    16a9:	call   16ae <botlish_fn_15+0x5e>
			16aa: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_label<generic>
    16ae:	mov    rcx,rax
    16b1:	mov    r15,rax
    16b4:	test   rax,rcx
    16b7:	je     180e <botlish_fn_15+0x1be>
    16bd:	mov    rax,r15
    16c0:	mov    QWORD PTR [rsp],rax
    16c4:	mov    rdx,QWORD PTR [rsp+0x30]
    16c9:	and    rax,rdx
    16cc:	test   rax,0x1
    16d2:	jne    16f8 <botlish_fn_15+0xa8>
    16d8:	mov    rsi,r15
    16db:	mov    rdi,r12
    16de:	call   16e3 <botlish_fn_15+0x93>
			16df: R_X86_64_PLT32	rt_int_cmp-0x4
    16e3:	mov    ecx,0x2
    16e8:	test   rax,rax
    16eb:	cmove  rcx,QWORD PTR [rip+0x19d]        # 1890 <botlish_fn_15+0x240>
    16f3:	jmp    1708 <botlish_fn_15+0xb8>
    16f8:	mov    ecx,0x2
    16fd:	cmp    r15,rdx
    1700:	cmove  rcx,QWORD PTR [rip+0x188]        # 1890 <botlish_fn_15+0x240>
    1708:	cmp    rcx,0x6
    170c:	je     1864 <botlish_fn_15+0x214>
    1712:	mov    rax,r15
    1715:	and    rax,r14
    1718:	test   rax,0x1
    171e:	jne    1747 <botlish_fn_15+0xf7>
    1724:	mov    rdx,r14
    1727:	mov    rsi,r15
    172a:	mov    rdi,r12
    172d:	call   1732 <botlish_fn_15+0xe2>
			172e: R_X86_64_PLT32	rt_int_cmp-0x4
    1732:	mov    ecx,0x2
    1737:	test   rax,rax
    173a:	cmovge rcx,QWORD PTR [rip+0x14e]        # 1890 <botlish_fn_15+0x240>
    1742:	jmp    1757 <botlish_fn_15+0x107>
    1747:	mov    ecx,0x2
    174c:	cmp    r15,r14
    174f:	cmovge rcx,QWORD PTR [rip+0x139]        # 1890 <botlish_fn_15+0x240>
    1757:	cmp    rcx,0x6
    175b:	je     1855 <botlish_fn_15+0x205>
    1761:	mov    rcx,rbx
    1764:	mov    rdx,r13
    1767:	mov    rsi,r15
    176a:	mov    rdi,r12
    176d:	call   1772 <botlish_fn_15+0x122>
			176e: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    1772:	test   rax,rax
    1775:	je     180e <botlish_fn_15+0x1be>
    177b:	mov    rdx,QWORD PTR [rsp+0x20]
    1780:	mov    rcx,QWORD PTR [rsp+0x28]
    1785:	mov    rsi,QWORD PTR [r12+0x10]
    178a:	mov    r8,QWORD PTR [rsi+0xa8]
    1791:	mov    rsi,rax
    1794:	mov    rdi,r12
    1797:	call   179c <botlish_fn_15+0x14c>
			1798: R_X86_64_PLT32	rt_str_region_eq-0x4
    179c:	cmp    rax,0x6
    17a0:	je     17b2 <botlish_fn_15+0x162>
    17a6:	mov    r14,0xffffffffffffffff
    17ad:	jmp    185c <botlish_fn_15+0x20c>
    17b2:	mov    QWORD PTR [rsp+0x18],0x3
    17bb:	test   r15,0x1
    17c2:	je     17da <botlish_fn_15+0x18a>
    17c8:	mov    rdx,r15
    17cb:	add    rdx,0x2
    17cf:	seto   al
    17d2:	test   al,al
    17d4:	je     17ed <botlish_fn_15+0x19d>
    17da:	mov    edx,0x3
    17df:	mov    rsi,r15
    17e2:	mov    rdi,r12
    17e5:	call   17ea <botlish_fn_15+0x19a>
			17e6: R_X86_64_PLT32	rt_int_add-0x4
    17ea:	mov    rdx,rax
    17ed:	mov    QWORD PTR [rsp],rdx
    17f1:	mov    r15,rdx
    17f4:	mov    rcx,r13
    17f7:	mov    rdx,r14
    17fa:	mov    rsi,r15
    17fd:	mov    rdi,r12
    1800:	call   1805 <botlish_fn_15+0x1b5>
			1801: R_X86_64_PLT32	botlish_fn_14-0x4 ; tld_ok<generic>
    1805:	test   rax,rax
    1808:	jne    1833 <botlish_fn_15+0x1e3>
    180e:	xor    rax,rax
    1811:	mov    rbx,QWORD PTR [rsp+0x40]
    1816:	mov    r12,QWORD PTR [rsp+0x48]
    181b:	mov    r13,QWORD PTR [rsp+0x50]
    1820:	mov    r14,QWORD PTR [rsp+0x58]
    1825:	mov    r15,QWORD PTR [rsp+0x60]
    182a:	add    rsp,0x70
    182e:	mov    rsp,rbp
    1831:	pop    rbp
    1832:	ret
    1833:	cmp    rax,0x6
    1837:	je     185c <botlish_fn_15+0x20c>
    183d:	mov    QWORD PTR [rsp],r15
    1841:	mov    QWORD PTR [rsp+0x8],r14
    1846:	mov    QWORD PTR [rsp+0x10],r13
    184b:	mov    QWORD PTR [rsp+0x30],r15
    1850:	jmp    169b <botlish_fn_15+0x4b>
    1855:	mov    r14,0xffffffffffffffff
    185c:	mov    rax,r14
    185f:	jmp    186b <botlish_fn_15+0x21b>
    1864:	mov    rax,0xffffffffffffffff
    186b:	mov    rbx,QWORD PTR [rsp+0x40]
    1870:	mov    r12,QWORD PTR [rsp+0x48]
    1875:	mov    r13,QWORD PTR [rsp+0x50]
    187a:	mov    r14,QWORD PTR [rsp+0x58]
    187f:	mov    r15,QWORD PTR [rsp+0x60]
    1884:	add    rsp,0x70
    1888:	mov    rsp,rbp
    188b:	pop    rbp
    188c:	ret
    188d:	add    BYTE PTR [rax],al
    188f:	add    BYTE PTR [rsi],al
    1891:	add    BYTE PTR [rax],al
    1893:	add    BYTE PTR [rax],al
    1895:	add    BYTE PTR [rax],al
	...

0000000000001898 <botlish_entry_15: domain_loop<generic>>:
    1898:	push   rbp
    1899:	mov    rbp,rsp
    189c:	mov    rsi,QWORD PTR [rdx]
    189f:	mov    r8,QWORD PTR [rdx+0x8]
    18a3:	mov    rcx,QWORD PTR [rdx+0x10]
    18a7:	mov    rdx,r8
    18aa:	call   18af <botlish_entry_15+0x17>
			18ab: R_X86_64_PLT32	botlish_fn_15-0x4 ; domain_loop<generic>
    18af:	mov    rsp,rbp
    18b2:	pop    rbp
    18b3:	ret

00000000000018b4 <botlish_fn_16: web::is_unreserved<generic>>:
    18b4:	push   rbp
    18b5:	mov    rbp,rsp
    18b8:	sub    rsp,0x20
    18bc:	mov    QWORD PTR [rsp],rbx
    18c0:	mov    QWORD PTR [rsp+0x8],r12
    18c5:	mov    QWORD PTR [rsp+0x10],r14
    18ca:	mov    rbx,rdi
    18cd:	mov    r12,rsi
    18d0:	mov    r14,rdx
    18d3:	mov    rsi,r14
    18d6:	mov    rdi,rbx
    18d9:	call   18de <botlish_fn_16+0x2a>
			18da: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
    18de:	cmp    rax,0x6
    18e2:	je     191b <botlish_fn_16+0x67>
    18e8:	mov    rsi,r12
    18eb:	mov    rax,QWORD PTR [rsi+0x20]
    18ef:	mov    rsi,QWORD PTR [rax]
    18f2:	mov    rdx,r14
    18f5:	mov    rdi,rbx
    18f8:	call   18fd <botlish_fn_16+0x49>
			18f9: R_X86_64_PLT32	rt_set_contains-0x4
    18fd:	cmp    rax,0x6
    1901:	je     1911 <botlish_fn_16+0x5d>
    1907:	mov    eax,0x2
    190c:	jmp    1920 <botlish_fn_16+0x6c>
    1911:	mov    eax,0x6
    1916:	jmp    1920 <botlish_fn_16+0x6c>
    191b:	mov    eax,0x6
    1920:	mov    rbx,QWORD PTR [rsp]
    1924:	mov    r12,QWORD PTR [rsp+0x8]
    1929:	mov    r14,QWORD PTR [rsp+0x10]
    192e:	add    rsp,0x20
    1932:	mov    rsp,rbp
    1935:	pop    rbp
    1936:	ret

0000000000001937 <botlish_entry_16: web::is_unreserved<generic>>:
    1937:	push   rbp
    1938:	mov    rbp,rsp
    193b:	mov    rdx,QWORD PTR [rdx]
    193e:	call   1943 <botlish_entry_16+0xc>
			193f: R_X86_64_PLT32	botlish_fn_16-0x4 ; web::is_unreserved<generic>
    1943:	mov    rsp,rbp
    1946:	pop    rbp
    1947:	ret

0000000000001948 <botlish_fn_17: web::uri_escape_text<generic>>:
    1948:	push   rbp
    1949:	mov    rbp,rsp
    194c:	sub    rsp,0x30
    1950:	mov    QWORD PTR [rsp],rdx
    1954:	mov    r10,rdx
    1957:	mov    edx,0x1
    195c:	mov    QWORD PTR [rsp+0x8],0x1
    1965:	mov    rax,QWORD PTR [rdi+0x10]
    1969:	mov    rcx,QWORD PTR [rax+0xd0]
    1970:	mov    QWORD PTR [rsp+0x10],rcx
    1975:	mov    rax,QWORD PTR [rsi+0x20]
    1979:	mov    r8,QWORD PTR [rax+0x8]
    197d:	mov    QWORD PTR [rsp+0x18],r8
    1982:	mov    rax,QWORD PTR [rsi+0x20]
    1986:	mov    r9,QWORD PTR [rax]
    1989:	mov    QWORD PTR [rsp+0x20],r9
    198e:	mov    rsi,r10
    1991:	call   1996 <botlish_fn_17+0x4e>
			1992: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_from<generic>
    1996:	test   rax,rax
    1999:	jne    19ab <botlish_fn_17+0x63>
    199f:	xor    rax,rax
    19a2:	add    rsp,0x30
    19a6:	mov    rsp,rbp
    19a9:	pop    rbp
    19aa:	ret
    19ab:	add    rsp,0x30
    19af:	mov    rsp,rbp
    19b2:	pop    rbp
    19b3:	ret

00000000000019b4 <botlish_entry_17: web::uri_escape_text<generic>>:
    19b4:	push   rbp
    19b5:	mov    rbp,rsp
    19b8:	mov    rdx,QWORD PTR [rdx]
    19bb:	call   19c0 <botlish_entry_17+0xc>
			19bc: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::uri_escape_text<generic>
    19c0:	mov    rsp,rbp
    19c3:	pop    rbp
    19c4:	ret

00000000000019c5 <botlish_fn_18: high_nibble<generic>>:
    19c5:	push   rbp
    19c6:	mov    rbp,rsp
    19c9:	sub    rsp,0x10
    19cd:	mov    QWORD PTR [rsp],rsi
    19d1:	mov    QWORD PTR [rsp+0x8],0x1e1
    19da:	test   rsi,0x1
    19e1:	jne    19f6 <botlish_fn_18+0x31>
    19e7:	mov    edx,0x1e1
    19ec:	call   19f1 <botlish_fn_18+0x2c>
			19ed: R_X86_64_PLT32	rt_int_and-0x4
    19f1:	jmp    1a00 <botlish_fn_18+0x3b>
    19f6:	and    rsi,0x1e1
    19fd:	mov    rax,rsi
    1a00:	sar    rax,0x5
    1a04:	shl    rax,1
    1a07:	or     rax,0x1
    1a0b:	add    rsp,0x10
    1a0f:	mov    rsp,rbp
    1a12:	pop    rbp
    1a13:	ret

0000000000001a14 <botlish_entry_18: high_nibble<generic>>:
    1a14:	push   rbp
    1a15:	mov    rbp,rsp
    1a18:	mov    rsi,QWORD PTR [rdx]
    1a1b:	call   1a20 <botlish_entry_18+0xc>
			1a1c: R_X86_64_PLT32	botlish_fn_18-0x4 ; high_nibble<generic>
    1a20:	mov    rsp,rbp
    1a23:	pop    rbp
    1a24:	ret

0000000000001a25 <botlish_fn_19: hex_pair<generic>>:
    1a25:	push   rbp
    1a26:	mov    rbp,rsp
    1a29:	sub    rsp,0x50
    1a2d:	mov    QWORD PTR [rsp+0x30],rbx
    1a32:	mov    QWORD PTR [rsp+0x38],r12
    1a37:	mov    QWORD PTR [rsp+0x40],r13
    1a3c:	mov    QWORD PTR [rsp+0x48],r14
    1a41:	mov    r12,rdi
    1a44:	mov    QWORD PTR [rsp],rsi
    1a48:	mov    r13,rsi
    1a4b:	mov    QWORD PTR [rsp+0x8],rdx
    1a50:	mov    rbx,rdx
    1a53:	mov    rsi,r13
    1a56:	mov    rdi,r12
    1a59:	call   1a5e <botlish_fn_19+0x39>
			1a5a: R_X86_64_PLT32	botlish_fn_18-0x4 ; high_nibble<generic>
    1a5e:	test   rax,0x1
    1a64:	jne    1a72 <botlish_fn_19+0x4d>
    1a6a:	mov    rdx,rax
    1a6d:	jmp    1a88 <botlish_fn_19+0x63>
    1a72:	mov    rdx,QWORD PTR [rbx+0x8]
    1a76:	mov    rcx,rax
    1a79:	sar    rcx,1
    1a7c:	cmp    rcx,rdx
    1a7f:	jb     1aa1 <botlish_fn_19+0x7c>
    1a85:	mov    rdx,rax
    1a88:	mov    rsi,rbx
    1a8b:	mov    rdi,r12
    1a8e:	call   1a93 <botlish_fn_19+0x6e>
			1a8f: R_X86_64_PLT32	rt_list_get-0x4
    1a93:	test   rax,rax
    1a96:	je     1b5e <botlish_fn_19+0x139>
    1a9c:	jmp    1aa9 <botlish_fn_19+0x84>
    1aa1:	mov    rax,QWORD PTR [rbx+0x10]
    1aa5:	mov    rax,QWORD PTR [rax+rcx*8]
    1aa9:	mov    QWORD PTR [rsp],rax
    1aad:	mov    r14,rax
    1ab0:	mov    edx,0x21
    1ab5:	mov    rsi,r13
    1ab8:	mov    rdi,r12
    1abb:	call   1ac0 <botlish_fn_19+0x9b>
			1abc: R_X86_64_PLT32	rt_int_mod-0x4
    1ac0:	test   rax,rax
    1ac3:	je     1b5e <botlish_fn_19+0x139>
    1ac9:	test   rax,0x1
    1acf:	jne    1ae0 <botlish_fn_19+0xbb>
    1ad5:	mov    rdx,rax
    1ad8:	mov    rsi,rbx
    1adb:	jmp    1af9 <botlish_fn_19+0xd4>
    1ae0:	mov    rdx,QWORD PTR [rbx+0x8]
    1ae4:	mov    rcx,rax
    1ae7:	sar    rcx,1
    1aea:	cmp    rcx,rdx
    1aed:	jb     1b0f <botlish_fn_19+0xea>
    1af3:	mov    rdx,rax
    1af6:	mov    rsi,rbx
    1af9:	mov    rdi,r12
    1afc:	call   1b01 <botlish_fn_19+0xdc>
			1afd: R_X86_64_PLT32	rt_list_get-0x4
    1b01:	test   rax,rax
    1b04:	je     1b5e <botlish_fn_19+0x139>
    1b0a:	jmp    1b1a <botlish_fn_19+0xf5>
    1b0f:	mov    rsi,rbx
    1b12:	mov    rax,QWORD PTR [rsi+0x10]
    1b16:	mov    rax,QWORD PTR [rax+rcx*8]
    1b1a:	mov    QWORD PTR [rsp+0x8],rax
    1b1f:	lea    rcx,[rsp+0x10]
    1b24:	mov    QWORD PTR [rsp+0x10],0x0
    1b2d:	mov    rdx,r14
    1b30:	mov    QWORD PTR [rsp+0x18],rdx
    1b35:	mov    QWORD PTR [rsp+0x20],0x0
    1b3e:	mov    QWORD PTR [rsp+0x28],rax
    1b43:	mov    esi,0x2
    1b48:	mov    edx,0x4
    1b4d:	mov    rdi,r12
    1b50:	call   1b55 <botlish_fn_19+0x130>
			1b51: R_X86_64_PLT32	rt_construct-0x4
    1b55:	test   rax,rax
    1b58:	jne    1b7e <botlish_fn_19+0x159>
    1b5e:	xor    rax,rax
    1b61:	mov    rbx,QWORD PTR [rsp+0x30]
    1b66:	mov    r12,QWORD PTR [rsp+0x38]
    1b6b:	mov    r13,QWORD PTR [rsp+0x40]
    1b70:	mov    r14,QWORD PTR [rsp+0x48]
    1b75:	add    rsp,0x50
    1b79:	mov    rsp,rbp
    1b7c:	pop    rbp
    1b7d:	ret
    1b7e:	mov    rbx,QWORD PTR [rsp+0x30]
    1b83:	mov    r12,QWORD PTR [rsp+0x38]
    1b88:	mov    r13,QWORD PTR [rsp+0x40]
    1b8d:	mov    r14,QWORD PTR [rsp+0x48]
    1b92:	add    rsp,0x50
    1b96:	mov    rsp,rbp
    1b99:	pop    rbp
    1b9a:	ret

0000000000001b9b <botlish_entry_19: hex_pair<generic>>:
    1b9b:	push   rbp
    1b9c:	mov    rbp,rsp
    1b9f:	sub    rsp,0x10
    1ba3:	mov    QWORD PTR [rsp],r12
    1ba7:	mov    r12,rdi
    1baa:	mov    rsi,QWORD PTR [rdx]
    1bad:	mov    rdx,QWORD PTR [rdx+0x8]
    1bb1:	call   1bb6 <botlish_entry_19+0x1b>
			1bb2: R_X86_64_PLT32	botlish_fn_19-0x4 ; hex_pair<generic>
    1bb6:	mov    r8,QWORD PTR [rip+0x0]        # 1bbd <botlish_entry_19+0x22>
			1bb9: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1bbd:	mov    rsi,rax
    1bc0:	mov    rdi,r12
    1bc3:	call   r8
    1bc6:	mov    r12,QWORD PTR [rsp]
    1bca:	add    rsp,0x10
    1bce:	mov    rsp,rbp
    1bd1:	pop    rbp
    1bd2:	ret
    1bd3:	add    BYTE PTR [rax],al
    1bd5:	add    BYTE PTR [rax],al
	...

0000000000001bd8 <botlish_fn_20: esc_bytes<generic>>:
    1bd8:	push   rbp
    1bd9:	mov    rbp,rsp
    1bdc:	sub    rsp,0xb0
    1be3:	mov    QWORD PTR [rsp+0x80],rbx
    1beb:	mov    QWORD PTR [rsp+0x88],r12
    1bf3:	mov    QWORD PTR [rsp+0x90],r13
    1bfb:	mov    QWORD PTR [rsp+0x98],r14
    1c03:	mov    QWORD PTR [rsp+0xa0],r15
    1c0b:	mov    QWORD PTR [rsp+0x28],0x0
    1c14:	mov    QWORD PTR [rsp],rsi
    1c18:	mov    QWORD PTR [rsp+0x8],rdx
    1c1d:	mov    r13,rdx
    1c20:	mov    QWORD PTR [rsp+0x10],rcx
    1c25:	mov    QWORD PTR [rsp+0x18],r8
    1c2a:	mov    QWORD PTR [rsp+0x60],r8
    1c2f:	lea    rax,[rsp+0x30]
    1c34:	mov    QWORD PTR [rsp+0x70],rax
    1c39:	mov    rbx,rdi
    1c3c:	mov    r12,rsi
    1c3f:	mov    QWORD PTR [rsp+0x68],rcx
    1c44:	mov    rsi,r12
    1c47:	mov    rdi,rbx
    1c4a:	call   1c4f <botlish_fn_20+0x77>
			1c4b: R_X86_64_PLT32	rt_list_len-0x4
    1c4f:	mov    r15,r13
    1c52:	mov    rcx,r15
    1c55:	and    rcx,rax
    1c58:	mov    rdx,rax
    1c5b:	test   rcx,0x1
    1c62:	jne    1c88 <botlish_fn_20+0xb0>
    1c68:	mov    rsi,r15
    1c6b:	mov    rdi,rbx
    1c6e:	call   1c73 <botlish_fn_20+0x9b>
			1c6f: R_X86_64_PLT32	rt_int_cmp-0x4
    1c73:	mov    ecx,0x2
    1c78:	test   rax,rax
    1c7b:	cmovge rcx,QWORD PTR [rip+0x1dd]        # 1e60 <botlish_fn_20+0x288>
    1c83:	jmp    1c98 <botlish_fn_20+0xc0>
    1c88:	mov    ecx,0x2
    1c8d:	cmp    r15,rdx
    1c90:	cmovge rcx,QWORD PTR [rip+0x1c8]        # 1e60 <botlish_fn_20+0x288>
    1c98:	cmp    rcx,0x6
    1c9c:	je     1e25 <botlish_fn_20+0x24d>
    1ca2:	mov    QWORD PTR [rsp+0x20],0x3
    1cab:	test   r15,0x1
    1cb2:	je     1cd5 <botlish_fn_20+0xfd>
    1cb8:	mov    rax,r15
    1cbb:	add    rax,0x2
    1cbf:	mov    rcx,rax
    1cc2:	seto   al
    1cc5:	test   al,al
    1cc7:	jne    1cd5 <botlish_fn_20+0xfd>
    1ccd:	mov    r14,rcx
    1cd0:	jmp    1ceb <botlish_fn_20+0x113>
    1cd5:	mov    edx,0x3
    1cda:	mov    rsi,r15
    1cdd:	mov    rdi,rbx
    1ce0:	call   1ce5 <botlish_fn_20+0x10d>
			1ce1: R_X86_64_PLT32	rt_int_add-0x4
    1ce5:	mov    rcx,rax
    1ce8:	mov    r14,rcx
    1ceb:	mov    QWORD PTR [rsp+0x8],r14
    1cf0:	mov    rax,QWORD PTR [rbx+0x10]
    1cf4:	mov    r13,QWORD PTR [rax+0xb8]
    1cfb:	mov    QWORD PTR [rsp+0x20],r13
    1d00:	test   r15,0x1
    1d07:	jne    1d15 <botlish_fn_20+0x13d>
    1d0d:	mov    rdx,r15
    1d10:	jmp    1d2c <botlish_fn_20+0x154>
    1d15:	mov    rcx,QWORD PTR [r12+0x8]
    1d1a:	mov    rax,r15
    1d1d:	sar    rax,1
    1d20:	cmp    rax,rcx
    1d23:	jb     1d48 <botlish_fn_20+0x170>
    1d29:	mov    rdx,r15
    1d2c:	mov    rsi,r12
    1d2f:	mov    rdi,rbx
    1d32:	call   1d37 <botlish_fn_20+0x15f>
			1d33: R_X86_64_PLT32	rt_list_get-0x4
    1d37:	test   rax,rax
    1d3a:	je     1dc9 <botlish_fn_20+0x1f1>
    1d40:	mov    rsi,rax
    1d43:	jmp    1d51 <botlish_fn_20+0x179>
    1d48:	mov    rdi,QWORD PTR [r12+0x10]
    1d4d:	mov    rsi,QWORD PTR [rdi+rax*8]
    1d51:	mov    QWORD PTR [rsp+0x28],rsi
    1d56:	mov    r15,QWORD PTR [rsp+0x60]
    1d5b:	mov    rdx,r15
    1d5e:	mov    rdi,rbx
    1d61:	call   1d66 <botlish_fn_20+0x18e>
			1d62: R_X86_64_PLT32	botlish_fn_19-0x4 ; hex_pair<generic>
    1d66:	test   rax,rax
    1d69:	je     1dc9 <botlish_fn_20+0x1f1>
    1d6f:	mov    QWORD PTR [rsp+0x28],rax
    1d74:	mov    rcx,rax
    1d77:	mov    QWORD PTR [rsp+0x30],0x0
    1d80:	mov    rax,QWORD PTR [rsp+0x68]
    1d85:	mov    QWORD PTR [rsp+0x38],rax
    1d8a:	mov    QWORD PTR [rsp+0x40],0x0
    1d93:	mov    QWORD PTR [rsp+0x48],r13
    1d98:	mov    QWORD PTR [rsp+0x50],0x0
    1da1:	mov    rax,rcx
    1da4:	mov    QWORD PTR [rsp+0x58],rax
    1da9:	mov    esi,0x2
    1dae:	mov    edx,0x6
    1db3:	mov    rcx,QWORD PTR [rsp+0x70]
    1db8:	mov    rdi,rbx
    1dbb:	call   1dc0 <botlish_fn_20+0x1e8>
			1dbc: R_X86_64_PLT32	rt_construct-0x4
    1dc0:	test   rax,rax
    1dc3:	jne    1e00 <botlish_fn_20+0x228>
    1dc9:	xor    rax,rax
    1dcc:	mov    rbx,QWORD PTR [rsp+0x80]
    1dd4:	mov    r12,QWORD PTR [rsp+0x88]
    1ddc:	mov    r13,QWORD PTR [rsp+0x90]
    1de4:	mov    r14,QWORD PTR [rsp+0x98]
    1dec:	mov    r15,QWORD PTR [rsp+0xa0]
    1df4:	add    rsp,0xb0
    1dfb:	mov    rsp,rbp
    1dfe:	pop    rbp
    1dff:	ret
    1e00:	mov    QWORD PTR [rsp],r12
    1e04:	mov    QWORD PTR [rsp+0x8],r14
    1e09:	mov    QWORD PTR [rsp+0x10],rax
    1e0e:	mov    QWORD PTR [rsp+0x18],r15
    1e13:	mov    r13,r14
    1e16:	mov    QWORD PTR [rsp+0x60],r15
    1e1b:	mov    QWORD PTR [rsp+0x68],rax
    1e20:	jmp    1c44 <botlish_fn_20+0x6c>
    1e25:	mov    rax,QWORD PTR [rsp+0x68]
    1e2a:	mov    rbx,QWORD PTR [rsp+0x80]
    1e32:	mov    r12,QWORD PTR [rsp+0x88]
    1e3a:	mov    r13,QWORD PTR [rsp+0x90]
    1e42:	mov    r14,QWORD PTR [rsp+0x98]
    1e4a:	mov    r15,QWORD PTR [rsp+0xa0]
    1e52:	add    rsp,0xb0
    1e59:	mov    rsp,rbp
    1e5c:	pop    rbp
    1e5d:	ret
    1e5e:	add    BYTE PTR [rax],al
    1e60:	(bad)
    1e61:	add    BYTE PTR [rax],al
    1e63:	add    BYTE PTR [rax],al
    1e65:	add    BYTE PTR [rax],al
	...

0000000000001e68 <botlish_entry_20: esc_bytes<generic>>:
    1e68:	push   rbp
    1e69:	mov    rbp,rsp
    1e6c:	sub    rsp,0x10
    1e70:	mov    QWORD PTR [rsp],r12
    1e74:	mov    r12,rdi
    1e77:	mov    rsi,QWORD PTR [rdx]
    1e7a:	mov    r9,QWORD PTR [rdx+0x8]
    1e7e:	mov    rcx,QWORD PTR [rdx+0x10]
    1e82:	mov    r8,QWORD PTR [rdx+0x18]
    1e86:	mov    rdx,r9
    1e89:	call   1e8e <botlish_entry_20+0x26>
			1e8a: R_X86_64_PLT32	botlish_fn_20-0x4 ; esc_bytes<generic>
    1e8e:	mov    r9,QWORD PTR [rip+0x0]        # 1e95 <botlish_entry_20+0x2d>
			1e91: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1e95:	mov    rsi,rax
    1e98:	mov    rdi,r12
    1e9b:	call   r9
    1e9e:	mov    r12,QWORD PTR [rsp]
    1ea2:	add    rsp,0x10
    1ea6:	mov    rsp,rbp
    1ea9:	pop    rbp
    1eaa:	ret

0000000000001eab <botlish_fn_21: esc_char<generic>>:
    1eab:	push   rbp
    1eac:	mov    rbp,rsp
    1eaf:	sub    rsp,0x50
    1eb3:	mov    QWORD PTR [rsp+0x20],rbx
    1eb8:	mov    QWORD PTR [rsp+0x28],r12
    1ebd:	mov    QWORD PTR [rsp+0x30],r13
    1ec2:	mov    QWORD PTR [rsp+0x38],r14
    1ec7:	mov    QWORD PTR [rsp+0x40],r15
    1ecc:	mov    r12,rdi
    1ecf:	mov    QWORD PTR [rsp+0x18],0x0
    1ed8:	mov    QWORD PTR [rsp],rsi
    1edc:	mov    r14,rsi
    1edf:	mov    QWORD PTR [rsp+0x8],rdx
    1ee4:	mov    r15,rdx
    1ee7:	mov    QWORD PTR [rsp+0x10],rcx
    1eec:	mov    rbx,rcx
    1eef:	mov    rsi,r14
    1ef2:	mov    rdi,r12
    1ef5:	call   1efa <botlish_fn_21+0x4f>
			1ef6: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1efa:	mov    rcx,rax
    1efd:	mov    r13,rax
    1f00:	test   rax,rcx
    1f03:	je     1fed <botlish_fn_21+0x142>
    1f09:	mov    rax,r13
    1f0c:	mov    QWORD PTR [rsp],rax
    1f10:	mov    rsi,r13
    1f13:	mov    rdi,r12
    1f16:	call   1f1b <botlish_fn_21+0x70>
			1f17: R_X86_64_PLT32	rt_list_len-0x4
    1f1b:	sar    rax,1
    1f1e:	cmp    rax,0x1
    1f22:	je     1f62 <botlish_fn_21+0xb7>
    1f28:	mov    edx,0x1
    1f2d:	mov    QWORD PTR [rsp+0x8],0x1
    1f36:	mov    rdi,r12
    1f39:	mov    rax,QWORD PTR [rdi+0x10]
    1f3d:	mov    rcx,QWORD PTR [rax+0xd0]
    1f44:	mov    QWORD PTR [rsp+0x18],rcx
    1f49:	mov    rsi,r13
    1f4c:	mov    r8,rbx
    1f4f:	call   1f54 <botlish_fn_21+0xa9>
			1f50: R_X86_64_PLT32	botlish_fn_20-0x4 ; esc_bytes<generic>
    1f54:	test   rax,rax
    1f57:	je     1fed <botlish_fn_21+0x142>
    1f5d:	jmp    2018 <botlish_fn_21+0x16d>
    1f62:	mov    rsi,r13
    1f65:	mov    rax,QWORD PTR [rsi+0x8]
    1f69:	mov    r13,rsi
    1f6c:	test   rax,rax
    1f6f:	jne    1f99 <botlish_fn_21+0xee>
    1f75:	mov    edx,0x1
    1f7a:	mov    rsi,r13
    1f7d:	mov    rdi,r12
    1f80:	call   1f85 <botlish_fn_21+0xda>
			1f81: R_X86_64_PLT32	rt_list_get-0x4
    1f85:	test   rax,rax
    1f88:	je     1fed <botlish_fn_21+0x142>
    1f8e:	mov    rdx,rax
    1f91:	mov    rsi,r15
    1f94:	jmp    1fa6 <botlish_fn_21+0xfb>
    1f99:	mov    rsi,r13
    1f9c:	mov    rax,QWORD PTR [rsi+0x10]
    1fa0:	mov    rdx,QWORD PTR [rax]
    1fa3:	mov    rsi,r15
    1fa6:	mov    rdi,r12
    1fa9:	call   1fae <botlish_fn_21+0x103>
			1faa: R_X86_64_PLT32	botlish_fn_16-0x4 ; web::is_unreserved<generic>
    1fae:	cmp    rax,0x6
    1fb2:	je     2015 <botlish_fn_21+0x16a>
    1fb8:	mov    edx,0x1
    1fbd:	mov    QWORD PTR [rsp+0x8],0x1
    1fc6:	mov    rdi,r12
    1fc9:	mov    rax,QWORD PTR [rdi+0x10]
    1fcd:	mov    rcx,QWORD PTR [rax+0xd0]
    1fd4:	mov    QWORD PTR [rsp+0x18],rcx
    1fd9:	mov    rsi,r13
    1fdc:	mov    r8,rbx
    1fdf:	call   1fe4 <botlish_fn_21+0x139>
			1fe0: R_X86_64_PLT32	botlish_fn_20-0x4 ; esc_bytes<generic>
    1fe4:	test   rax,rax
    1fe7:	jne    2012 <botlish_fn_21+0x167>
    1fed:	xor    rax,rax
    1ff0:	mov    rbx,QWORD PTR [rsp+0x20]
    1ff5:	mov    r12,QWORD PTR [rsp+0x28]
    1ffa:	mov    r13,QWORD PTR [rsp+0x30]
    1fff:	mov    r14,QWORD PTR [rsp+0x38]
    2004:	mov    r15,QWORD PTR [rsp+0x40]
    2009:	add    rsp,0x50
    200d:	mov    rsp,rbp
    2010:	pop    rbp
    2011:	ret
    2012:	mov    r14,rax
    2015:	mov    rax,r14
    2018:	mov    rbx,QWORD PTR [rsp+0x20]
    201d:	mov    r12,QWORD PTR [rsp+0x28]
    2022:	mov    r13,QWORD PTR [rsp+0x30]
    2027:	mov    r14,QWORD PTR [rsp+0x38]
    202c:	mov    r15,QWORD PTR [rsp+0x40]
    2031:	add    rsp,0x50
    2035:	mov    rsp,rbp
    2038:	pop    rbp
    2039:	ret

000000000000203a <botlish_entry_21: esc_char<generic>>:
    203a:	push   rbp
    203b:	mov    rbp,rsp
    203e:	sub    rsp,0x10
    2042:	mov    QWORD PTR [rsp],r12
    2046:	mov    r12,rdi
    2049:	mov    rsi,QWORD PTR [rdx]
    204c:	mov    r8,QWORD PTR [rdx+0x8]
    2050:	mov    rcx,QWORD PTR [rdx+0x10]
    2054:	mov    rdx,r8
    2057:	call   205c <botlish_entry_21+0x22>
			2058: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_char<generic>
    205c:	mov    r8,QWORD PTR [rip+0x0]        # 2063 <botlish_entry_21+0x29>
			205f: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    2063:	mov    rsi,rax
    2066:	mov    rdi,r12
    2069:	call   r8
    206c:	mov    r12,QWORD PTR [rsp]
    2070:	add    rsp,0x10
    2074:	mov    rsp,rbp
    2077:	pop    rbp
    2078:	ret
    2079:	add    BYTE PTR [rax],al
    207b:	add    BYTE PTR [rax],al
    207d:	add    BYTE PTR [rax],al
	...

0000000000002080 <botlish_fn_22: esc_from<generic>>:
    2080:	push   rbp
    2081:	mov    rbp,rsp
    2084:	sub    rsp,0xb0
    208b:	mov    QWORD PTR [rsp+0x80],rbx
    2093:	mov    QWORD PTR [rsp+0x88],r12
    209b:	mov    QWORD PTR [rsp+0x90],r13
    20a3:	mov    QWORD PTR [rsp+0x98],r14
    20ab:	mov    QWORD PTR [rsp+0xa0],r15
    20b3:	mov    r14,rdi
    20b6:	mov    QWORD PTR [rsp+0x28],0x0
    20bf:	mov    QWORD PTR [rsp+0x30],0x0
    20c8:	mov    QWORD PTR [rsp],rsi
    20cc:	mov    QWORD PTR [rsp+0x8],rdx
    20d1:	mov    r12,rdx
    20d4:	mov    QWORD PTR [rsp+0x10],rcx
    20d9:	mov    QWORD PTR [rsp+0x68],rcx
    20de:	mov    QWORD PTR [rsp+0x18],r8
    20e3:	mov    r15,r8
    20e6:	mov    QWORD PTR [rsp+0x20],r9
    20eb:	mov    r13,r9
    20ee:	xor    eax,eax
    20f0:	test   rsi,0x7
    20f7:	jne    2106 <botlish_fn_22+0x86>
    20fd:	movzx  rax,BYTE PTR [rsi]
    2101:	cmp    al,0x2
    2103:	sete   al
    2106:	test   al,al
    2108:	jne    212b <botlish_fn_22+0xab>
    210e:	mov    rdi,r14
    2111:	mov    rax,QWORD PTR [rdi+0x10]
    2115:	mov    rcx,QWORD PTR [rax+0xd8]
    211c:	mov    edx,0x1
    2121:	call   2126 <botlish_fn_22+0xa6>
			2122: R_X86_64_PLT32	rt_type_error-0x4
    2126:	jmp    22e8 <botlish_fn_22+0x268>
    212b:	mov    rbx,rsi
    212e:	mov    rdi,r14
    2131:	call   2136 <botlish_fn_22+0xb6>
			2132: R_X86_64_PLT32	rt_str_len-0x4
    2136:	mov    rcx,r12
    2139:	and    rcx,rax
    213c:	mov    rdx,rax
    213f:	test   rcx,0x1
    2146:	jne    216c <botlish_fn_22+0xec>
    214c:	mov    rsi,r12
    214f:	mov    rdi,r14
    2152:	call   2157 <botlish_fn_22+0xd7>
			2153: R_X86_64_PLT32	rt_int_cmp-0x4
    2157:	mov    ecx,0x2
    215c:	test   rax,rax
    215f:	cmovge rcx,QWORD PTR [rip+0x1f1]        # 2358 <botlish_fn_22+0x2d8>
    2167:	jmp    217c <botlish_fn_22+0xfc>
    216c:	mov    ecx,0x2
    2171:	cmp    r12,rdx
    2174:	cmovge rcx,QWORD PTR [rip+0x1dc]        # 2358 <botlish_fn_22+0x2d8>
    217c:	cmp    rcx,0x6
    2180:	je     22b7 <botlish_fn_22+0x237>
    2186:	mov    QWORD PTR [rsp+0x28],0x3
    218f:	test   r12,0x1
    2196:	je     21ae <botlish_fn_22+0x12e>
    219c:	mov    rax,r12
    219f:	add    rax,0x2
    21a3:	seto   cl
    21a6:	test   cl,cl
    21a8:	je     21be <botlish_fn_22+0x13e>
    21ae:	mov    edx,0x3
    21b3:	mov    rsi,r12
    21b6:	mov    rdi,r14
    21b9:	call   21be <botlish_fn_22+0x13e>
			21ba: R_X86_64_PLT32	rt_int_add-0x4
    21be:	mov    QWORD PTR [rsp+0x28],rax
    21c3:	mov    QWORD PTR [rsp+0x70],rax
    21c8:	mov    QWORD PTR [rsp+0x30],0x3
    21d1:	test   r12,0x1
    21d8:	je     21f0 <botlish_fn_22+0x170>
    21de:	mov    rcx,r12
    21e1:	add    rcx,0x2
    21e5:	seto   al
    21e8:	test   al,al
    21ea:	je     2203 <botlish_fn_22+0x183>
    21f0:	mov    edx,0x3
    21f5:	mov    rsi,r12
    21f8:	mov    rdi,r14
    21fb:	call   2200 <botlish_fn_22+0x180>
			21fc: R_X86_64_PLT32	rt_int_add-0x4
    2200:	mov    rcx,rax
    2203:	mov    QWORD PTR [rsp+0x30],rcx
    2208:	mov    rdx,r12
    220b:	mov    rsi,rbx
    220e:	mov    rdi,r14
    2211:	call   2216 <botlish_fn_22+0x196>
			2212: R_X86_64_PLT32	rt_substr-0x4
    2216:	test   rax,rax
    2219:	je     22e8 <botlish_fn_22+0x268>
    221f:	mov    QWORD PTR [rsp+0x8],rax
    2224:	mov    rsi,rax
    2227:	mov    r12,r15
    222a:	mov    rcx,r13
    222d:	mov    rdx,r12
    2230:	mov    rdi,r14
    2233:	call   2238 <botlish_fn_22+0x1b8>
			2234: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_char<generic>
    2238:	test   rax,rax
    223b:	je     22e8 <botlish_fn_22+0x268>
    2241:	mov    QWORD PTR [rsp+0x8],rax
    2246:	lea    rcx,[rsp+0x48]
    224b:	mov    QWORD PTR [rsp+0x48],0x0
    2254:	mov    r11,QWORD PTR [rsp+0x68]
    2259:	mov    QWORD PTR [rsp+0x50],r11
    225e:	mov    QWORD PTR [rsp+0x58],0x0
    2267:	mov    QWORD PTR [rsp+0x60],rax
    226c:	mov    esi,0x2
    2271:	mov    edx,0x4
    2276:	mov    rdi,r14
    2279:	call   227e <botlish_fn_22+0x1fe>
			227a: R_X86_64_PLT32	rt_construct-0x4
    227e:	test   rax,rax
    2281:	je     22e8 <botlish_fn_22+0x268>
    2287:	mov    QWORD PTR [rsp],rbx
    228b:	mov    rcx,QWORD PTR [rsp+0x70]
    2290:	mov    QWORD PTR [rsp+0x8],rcx
    2295:	mov    QWORD PTR [rsp+0x10],rax
    229a:	mov    QWORD PTR [rsp+0x18],r12
    229f:	mov    QWORD PTR [rsp+0x20],r13
    22a4:	mov    QWORD PTR [rsp+0x68],rax
    22a9:	mov    r15,r12
    22ac:	mov    r12,rcx
    22af:	mov    rsi,rbx
    22b2:	jmp    20ee <botlish_fn_22+0x6e>
    22b7:	mov    r11,QWORD PTR [rsp+0x68]
    22bc:	xor    rsi,rsi
    22bf:	lea    rcx,[rsp+0x38]
    22c4:	mov    QWORD PTR [rsp+0x38],0x0
    22cd:	mov    QWORD PTR [rsp+0x40],r11
    22d2:	mov    edx,0x2
    22d7:	mov    rdi,r14
    22da:	call   22df <botlish_fn_22+0x25f>
			22db: R_X86_64_PLT32	rt_construct-0x4
    22df:	test   rax,rax
    22e2:	jne    231f <botlish_fn_22+0x29f>
    22e8:	xor    rax,rax
    22eb:	mov    rbx,QWORD PTR [rsp+0x80]
    22f3:	mov    r12,QWORD PTR [rsp+0x88]
    22fb:	mov    r13,QWORD PTR [rsp+0x90]
    2303:	mov    r14,QWORD PTR [rsp+0x98]
    230b:	mov    r15,QWORD PTR [rsp+0xa0]
    2313:	add    rsp,0xb0
    231a:	mov    rsp,rbp
    231d:	pop    rbp
    231e:	ret
    231f:	mov    rbx,QWORD PTR [rsp+0x80]
    2327:	mov    r12,QWORD PTR [rsp+0x88]
    232f:	mov    r13,QWORD PTR [rsp+0x90]
    2337:	mov    r14,QWORD PTR [rsp+0x98]
    233f:	mov    r15,QWORD PTR [rsp+0xa0]
    2347:	add    rsp,0xb0
    234e:	mov    rsp,rbp
    2351:	pop    rbp
    2352:	ret
    2353:	add    BYTE PTR [rax],al
    2355:	add    BYTE PTR [rax],al
    2357:	add    BYTE PTR [rsi],al
    2359:	add    BYTE PTR [rax],al
    235b:	add    BYTE PTR [rax],al
    235d:	add    BYTE PTR [rax],al
	...

0000000000002360 <botlish_entry_22: esc_from<generic>>:
    2360:	push   rbp
    2361:	mov    rbp,rsp
    2364:	mov    rsi,QWORD PTR [rdx]
    2367:	mov    r10,QWORD PTR [rdx+0x8]
    236b:	mov    rcx,QWORD PTR [rdx+0x10]
    236f:	mov    r8,QWORD PTR [rdx+0x18]
    2373:	mov    r9,QWORD PTR [rdx+0x20]
    2377:	mov    rdx,r10
    237a:	call   237f <botlish_entry_22+0x1f>
			237b: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_from<generic>
    237f:	mov    rsp,rbp
    2382:	pop    rbp
    2383:	ret

0000000000002384 <botlish_fn_23: check<int, int, str, str>>:
    2384:	push   rbp
    2385:	mov    rbp,rsp
    2388:	sub    rsp,0x50
    238c:	mov    QWORD PTR [rsp+0x20],rbx
    2391:	mov    QWORD PTR [rsp+0x28],r12
    2396:	mov    QWORD PTR [rsp+0x30],r13
    239b:	mov    QWORD PTR [rsp+0x38],r14
    23a0:	mov    QWORD PTR [rsp+0x40],r15
    23a5:	mov    r14,rdi
    23a8:	mov    QWORD PTR [rsp+0x18],0x0
    23b1:	mov    QWORD PTR [rsp],rdx
    23b5:	mov    QWORD PTR [rsp+0x8],rcx
    23ba:	mov    QWORD PTR [rsp+0x10],r8
    23bf:	mov    r13,r8
    23c2:	sar    rsi,1
    23c5:	mov    r12,rsi
    23c8:	mov    r15,rdx
    23cb:	test   r12,r12
    23ce:	jle    2490 <botlish_fn_23+0x10c>
    23d4:	mov    rbx,rcx
    23d7:	mov    rsi,rbx
    23da:	mov    rdi,r14
    23dd:	call   23e2 <botlish_fn_23+0x5e>
			23de: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_emailish<str>
    23e2:	test   rax,rax
    23e5:	jne    2410 <botlish_fn_23+0x8c>
    23eb:	xor    rax,rax
    23ee:	mov    rbx,QWORD PTR [rsp+0x20]
    23f3:	mov    r12,QWORD PTR [rsp+0x28]
    23f8:	mov    r13,QWORD PTR [rsp+0x30]
    23fd:	mov    r14,QWORD PTR [rsp+0x38]
    2402:	mov    r15,QWORD PTR [rsp+0x40]
    2407:	add    rsp,0x50
    240b:	mov    rsp,rbp
    240e:	pop    rbp
    240f:	ret
    2410:	cmp    rax,0x6
    2414:	je     2430 <botlish_fn_23+0xac>
    241a:	mov    edx,0x1
    241f:	mov    QWORD PTR [rsp+0x18],0x1
    2428:	mov    rsi,r15
    242b:	jmp    2441 <botlish_fn_23+0xbd>
    2430:	mov    edx,0x3
    2435:	mov    QWORD PTR [rsp+0x18],0x3
    243e:	mov    rsi,r15
    2441:	mov    rax,rsi
    2444:	and    rax,rdx
    2447:	test   rax,0x1
    244d:	je     2468 <botlish_fn_23+0xe4>
    2453:	lea    rcx,[rdx-0x1]
    2457:	mov    rax,rsi
    245a:	add    rax,rcx
    245d:	seto   cl
    2460:	test   cl,cl
    2462:	je     2470 <botlish_fn_23+0xec>
    2468:	mov    rdi,r14
    246b:	call   2470 <botlish_fn_23+0xec>
			246c: R_X86_64_PLT32	rt_int_add-0x4
    2470:	mov    QWORD PTR [rsp],rax
    2474:	mov    QWORD PTR [rsp+0x8],rbx
    2479:	mov    r8,r13
    247c:	mov    QWORD PTR [rsp+0x10],r8
    2481:	sub    r12,0x1
    2485:	mov    rcx,rbx
    2488:	mov    r15,rax
    248b:	jmp    23cb <botlish_fn_23+0x47>
    2490:	mov    rax,r15
    2493:	mov    rbx,QWORD PTR [rsp+0x20]
    2498:	mov    r12,QWORD PTR [rsp+0x28]
    249d:	mov    r13,QWORD PTR [rsp+0x30]
    24a2:	mov    r14,QWORD PTR [rsp+0x38]
    24a7:	mov    r15,QWORD PTR [rsp+0x40]
    24ac:	add    rsp,0x50
    24b0:	mov    rsp,rbp
    24b3:	pop    rbp
    24b4:	ret

00000000000024b5 <botlish_entry_23: check<int, int, str, str>>:
    24b5:	push   rbp
    24b6:	mov    rbp,rsp
    24b9:	mov    rsi,QWORD PTR [rdx]
    24bc:	mov    r9,QWORD PTR [rdx+0x8]
    24c0:	mov    rcx,QWORD PTR [rdx+0x10]
    24c4:	mov    r8,QWORD PTR [rdx+0x18]
    24c8:	mov    rdx,r9
    24cb:	call   24d0 <botlish_entry_23+0x1b>
			24cc: R_X86_64_PLT32	botlish_fn_23-0x4 ; check<int, int, str, str>
    24d0:	mov    rsp,rbp
    24d3:	pop    rbp
    24d4:	ret

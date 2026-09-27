; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 15187  (per function: 1172 39 289 617 74 74 74 125 125 155 125 103 453 758 486 828 402 681 769 262 804 564 468 452 644 681 769 262 804 564 468 452 644)
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
;   botlish_fn_9 / botlish_entry_9 -> web::is_unreserved<generic>
;   botlish_fn_10 / botlish_entry_10 -> web::uri_escape_text<generic>
;   botlish_fn_11 / botlish_entry_11 -> high_nibble<generic>
;   botlish_fn_12 / botlish_entry_12 -> hex_pair<generic>
;   botlish_fn_13 / botlish_entry_13 -> esc_bytes<generic>
;   botlish_fn_14 / botlish_entry_14 -> esc_char<generic>
;   botlish_fn_15 / botlish_entry_15 -> esc_from<generic>
;   botlish_fn_16 / botlish_entry_16 -> check<int, int, str, str>
;   botlish_fn_17 / botlish_entry_17 -> <str>
;   botlish_fn_18 / botlish_entry_18 -> <generic>
;   botlish_fn_19 / botlish_entry_19 -> char_at<generic>
;   botlish_fn_20 / botlish_entry_20 -> scan_local<generic>
;   botlish_fn_21 / botlish_entry_21 -> scan_label<generic>
;   botlish_fn_22 / botlish_entry_22 -> scan_alpha<generic>
;   botlish_fn_23 / botlish_entry_23 -> tld_ok<generic>
;   botlish_fn_24 / botlish_entry_24 -> domain_loop<generic>
;   botlish_fn_25 / botlish_entry_25 -> <str>
;   botlish_fn_26 / botlish_entry_26 -> <generic>
;   botlish_fn_27 / botlish_entry_27 -> char_at<generic>
;   botlish_fn_28 / botlish_entry_28 -> scan_local<generic>
;   botlish_fn_29 / botlish_entry_29 -> scan_label<generic>
;   botlish_fn_30 / botlish_entry_30 -> scan_alpha<generic>
;   botlish_fn_31 / botlish_entry_31 -> tld_ok<generic>
;   botlish_fn_32 / botlish_entry_32 -> domain_loop<generic>


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
     29d:	mov    esi,0x9
     2a2:	mov    rdx,QWORD PTR [rip+0x0]        # 2a9 <botlish_fn_0+0x2a9>
			2a5: R_X86_64_GOTPCREL	botlish_entry_9-0x4 ; web::is_unreserved<generic>
     2a9:	mov    ecx,0x1
     2ae:	mov    rdi,QWORD PTR [rsp+0x148]
     2b6:	call   2bb <botlish_fn_0+0x2bb>
			2b7: R_X86_64_PLT32	rt_closure_new-0x4
     2bb:	mov    QWORD PTR [rsp+0x8],rax
     2c0:	lea    r8,[rsp+0x128]
     2c8:	mov    rcx,rbx
     2cb:	mov    QWORD PTR [rsp+0x128],rcx
     2d3:	mov    QWORD PTR [rsp+0x130],rax
     2db:	mov    esi,0xa
     2e0:	mov    rdx,QWORD PTR [rip+0x0]        # 2e7 <botlish_fn_0+0x2e7>
			2e3: R_X86_64_GOTPCREL	botlish_entry_10-0x4 ; web::uri_escape_text<generic>
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
			319: R_X86_64_PLT32	botlish_fn_10-0x4 ; web::uri_escape_text<generic>
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
			36d: R_X86_64_PLT32	botlish_fn_16-0x4 ; check<int, int, str, str>
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
			3ba: R_X86_64_PLT32	botlish_fn_16-0x4 ; check<int, int, str, str>
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

00000000000009c9 <botlish_fn_9: web::is_unreserved<generic>>:
     9c9:	push   rbp
     9ca:	mov    rbp,rsp
     9cd:	sub    rsp,0x20
     9d1:	mov    QWORD PTR [rsp],rbx
     9d5:	mov    QWORD PTR [rsp+0x8],r12
     9da:	mov    QWORD PTR [rsp+0x10],r14
     9df:	mov    rbx,rdi
     9e2:	mov    r12,rsi
     9e5:	mov    r14,rdx
     9e8:	mov    rsi,r14
     9eb:	mov    rdi,rbx
     9ee:	call   9f3 <botlish_fn_9+0x2a>
			9ef: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
     9f3:	cmp    rax,0x6
     9f7:	je     a30 <botlish_fn_9+0x67>
     9fd:	mov    rsi,r12
     a00:	mov    rax,QWORD PTR [rsi+0x20]
     a04:	mov    rsi,QWORD PTR [rax]
     a07:	mov    rdx,r14
     a0a:	mov    rdi,rbx
     a0d:	call   a12 <botlish_fn_9+0x49>
			a0e: R_X86_64_PLT32	rt_set_contains-0x4
     a12:	cmp    rax,0x6
     a16:	je     a26 <botlish_fn_9+0x5d>
     a1c:	mov    eax,0x2
     a21:	jmp    a35 <botlish_fn_9+0x6c>
     a26:	mov    eax,0x6
     a2b:	jmp    a35 <botlish_fn_9+0x6c>
     a30:	mov    eax,0x6
     a35:	mov    rbx,QWORD PTR [rsp]
     a39:	mov    r12,QWORD PTR [rsp+0x8]
     a3e:	mov    r14,QWORD PTR [rsp+0x10]
     a43:	add    rsp,0x20
     a47:	mov    rsp,rbp
     a4a:	pop    rbp
     a4b:	ret

0000000000000a4c <botlish_entry_9: web::is_unreserved<generic>>:
     a4c:	push   rbp
     a4d:	mov    rbp,rsp
     a50:	mov    rdx,QWORD PTR [rdx]
     a53:	call   a58 <botlish_entry_9+0xc>
			a54: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_unreserved<generic>
     a58:	mov    rsp,rbp
     a5b:	pop    rbp
     a5c:	ret

0000000000000a5d <botlish_fn_10: web::uri_escape_text<generic>>:
     a5d:	push   rbp
     a5e:	mov    rbp,rsp
     a61:	sub    rsp,0x30
     a65:	mov    QWORD PTR [rsp],rdx
     a69:	mov    r10,rdx
     a6c:	mov    edx,0x1
     a71:	mov    QWORD PTR [rsp+0x8],0x1
     a7a:	mov    rax,QWORD PTR [rdi+0x10]
     a7e:	mov    rcx,QWORD PTR [rax+0xa0]
     a85:	mov    QWORD PTR [rsp+0x10],rcx
     a8a:	mov    rax,QWORD PTR [rsi+0x20]
     a8e:	mov    r8,QWORD PTR [rax+0x8]
     a92:	mov    QWORD PTR [rsp+0x18],r8
     a97:	mov    rax,QWORD PTR [rsi+0x20]
     a9b:	mov    r9,QWORD PTR [rax]
     a9e:	mov    QWORD PTR [rsp+0x20],r9
     aa3:	mov    rsi,r10
     aa6:	call   aab <botlish_fn_10+0x4e>
			aa7: R_X86_64_PLT32	botlish_fn_15-0x4 ; esc_from<generic>
     aab:	test   rax,rax
     aae:	jne    ac0 <botlish_fn_10+0x63>
     ab4:	xor    rax,rax
     ab7:	add    rsp,0x30
     abb:	mov    rsp,rbp
     abe:	pop    rbp
     abf:	ret
     ac0:	add    rsp,0x30
     ac4:	mov    rsp,rbp
     ac7:	pop    rbp
     ac8:	ret

0000000000000ac9 <botlish_entry_10: web::uri_escape_text<generic>>:
     ac9:	push   rbp
     aca:	mov    rbp,rsp
     acd:	mov    rdx,QWORD PTR [rdx]
     ad0:	call   ad5 <botlish_entry_10+0xc>
			ad1: R_X86_64_PLT32	botlish_fn_10-0x4 ; web::uri_escape_text<generic>
     ad5:	mov    rsp,rbp
     ad8:	pop    rbp
     ad9:	ret

0000000000000ada <botlish_fn_11: high_nibble<generic>>:
     ada:	push   rbp
     adb:	mov    rbp,rsp
     ade:	sub    rsp,0x10
     ae2:	mov    QWORD PTR [rsp],rsi
     ae6:	mov    QWORD PTR [rsp+0x8],0x1e1
     aef:	test   rsi,0x1
     af6:	jne    b0b <botlish_fn_11+0x31>
     afc:	mov    edx,0x1e1
     b01:	call   b06 <botlish_fn_11+0x2c>
			b02: R_X86_64_PLT32	rt_int_and-0x4
     b06:	jmp    b15 <botlish_fn_11+0x3b>
     b0b:	and    rsi,0x1e1
     b12:	mov    rax,rsi
     b15:	sar    rax,0x5
     b19:	shl    rax,1
     b1c:	or     rax,0x1
     b20:	add    rsp,0x10
     b24:	mov    rsp,rbp
     b27:	pop    rbp
     b28:	ret

0000000000000b29 <botlish_entry_11: high_nibble<generic>>:
     b29:	push   rbp
     b2a:	mov    rbp,rsp
     b2d:	mov    rsi,QWORD PTR [rdx]
     b30:	call   b35 <botlish_entry_11+0xc>
			b31: R_X86_64_PLT32	botlish_fn_11-0x4 ; high_nibble<generic>
     b35:	mov    rsp,rbp
     b38:	pop    rbp
     b39:	ret

0000000000000b3a <botlish_fn_12: hex_pair<generic>>:
     b3a:	push   rbp
     b3b:	mov    rbp,rsp
     b3e:	sub    rsp,0x50
     b42:	mov    QWORD PTR [rsp+0x30],rbx
     b47:	mov    QWORD PTR [rsp+0x38],r12
     b4c:	mov    QWORD PTR [rsp+0x40],r13
     b51:	mov    QWORD PTR [rsp+0x48],r14
     b56:	mov    r12,rdi
     b59:	mov    QWORD PTR [rsp],rsi
     b5d:	mov    r13,rsi
     b60:	mov    QWORD PTR [rsp+0x8],rdx
     b65:	mov    rbx,rdx
     b68:	mov    rsi,r13
     b6b:	mov    rdi,r12
     b6e:	call   b73 <botlish_fn_12+0x39>
			b6f: R_X86_64_PLT32	botlish_fn_11-0x4 ; high_nibble<generic>
     b73:	test   rax,0x1
     b79:	jne    b87 <botlish_fn_12+0x4d>
     b7f:	mov    rdx,rax
     b82:	jmp    b9d <botlish_fn_12+0x63>
     b87:	mov    rdx,QWORD PTR [rbx+0x8]
     b8b:	mov    rcx,rax
     b8e:	sar    rcx,1
     b91:	cmp    rcx,rdx
     b94:	jb     bb6 <botlish_fn_12+0x7c>
     b9a:	mov    rdx,rax
     b9d:	mov    rsi,rbx
     ba0:	mov    rdi,r12
     ba3:	call   ba8 <botlish_fn_12+0x6e>
			ba4: R_X86_64_PLT32	rt_list_get-0x4
     ba8:	test   rax,rax
     bab:	je     c73 <botlish_fn_12+0x139>
     bb1:	jmp    bbe <botlish_fn_12+0x84>
     bb6:	mov    rax,QWORD PTR [rbx+0x10]
     bba:	mov    rax,QWORD PTR [rax+rcx*8]
     bbe:	mov    QWORD PTR [rsp],rax
     bc2:	mov    r14,rax
     bc5:	mov    edx,0x21
     bca:	mov    rsi,r13
     bcd:	mov    rdi,r12
     bd0:	call   bd5 <botlish_fn_12+0x9b>
			bd1: R_X86_64_PLT32	rt_int_mod-0x4
     bd5:	test   rax,rax
     bd8:	je     c73 <botlish_fn_12+0x139>
     bde:	test   rax,0x1
     be4:	jne    bf5 <botlish_fn_12+0xbb>
     bea:	mov    rdx,rax
     bed:	mov    rsi,rbx
     bf0:	jmp    c0e <botlish_fn_12+0xd4>
     bf5:	mov    rdx,QWORD PTR [rbx+0x8]
     bf9:	mov    rcx,rax
     bfc:	sar    rcx,1
     bff:	cmp    rcx,rdx
     c02:	jb     c24 <botlish_fn_12+0xea>
     c08:	mov    rdx,rax
     c0b:	mov    rsi,rbx
     c0e:	mov    rdi,r12
     c11:	call   c16 <botlish_fn_12+0xdc>
			c12: R_X86_64_PLT32	rt_list_get-0x4
     c16:	test   rax,rax
     c19:	je     c73 <botlish_fn_12+0x139>
     c1f:	jmp    c2f <botlish_fn_12+0xf5>
     c24:	mov    rsi,rbx
     c27:	mov    rax,QWORD PTR [rsi+0x10]
     c2b:	mov    rax,QWORD PTR [rax+rcx*8]
     c2f:	mov    QWORD PTR [rsp+0x8],rax
     c34:	lea    rcx,[rsp+0x10]
     c39:	mov    QWORD PTR [rsp+0x10],0x0
     c42:	mov    rdx,r14
     c45:	mov    QWORD PTR [rsp+0x18],rdx
     c4a:	mov    QWORD PTR [rsp+0x20],0x0
     c53:	mov    QWORD PTR [rsp+0x28],rax
     c58:	mov    esi,0x2
     c5d:	mov    edx,0x4
     c62:	mov    rdi,r12
     c65:	call   c6a <botlish_fn_12+0x130>
			c66: R_X86_64_PLT32	rt_construct-0x4
     c6a:	test   rax,rax
     c6d:	jne    c93 <botlish_fn_12+0x159>
     c73:	xor    rax,rax
     c76:	mov    rbx,QWORD PTR [rsp+0x30]
     c7b:	mov    r12,QWORD PTR [rsp+0x38]
     c80:	mov    r13,QWORD PTR [rsp+0x40]
     c85:	mov    r14,QWORD PTR [rsp+0x48]
     c8a:	add    rsp,0x50
     c8e:	mov    rsp,rbp
     c91:	pop    rbp
     c92:	ret
     c93:	mov    rbx,QWORD PTR [rsp+0x30]
     c98:	mov    r12,QWORD PTR [rsp+0x38]
     c9d:	mov    r13,QWORD PTR [rsp+0x40]
     ca2:	mov    r14,QWORD PTR [rsp+0x48]
     ca7:	add    rsp,0x50
     cab:	mov    rsp,rbp
     cae:	pop    rbp
     caf:	ret

0000000000000cb0 <botlish_entry_12: hex_pair<generic>>:
     cb0:	push   rbp
     cb1:	mov    rbp,rsp
     cb4:	sub    rsp,0x10
     cb8:	mov    QWORD PTR [rsp],r12
     cbc:	mov    r12,rdi
     cbf:	mov    rsi,QWORD PTR [rdx]
     cc2:	mov    rdx,QWORD PTR [rdx+0x8]
     cc6:	call   ccb <botlish_entry_12+0x1b>
			cc7: R_X86_64_PLT32	botlish_fn_12-0x4 ; hex_pair<generic>
     ccb:	mov    r8,QWORD PTR [rip+0x0]        # cd2 <botlish_entry_12+0x22>
			cce: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
     cd2:	mov    rsi,rax
     cd5:	mov    rdi,r12
     cd8:	call   r8
     cdb:	mov    r12,QWORD PTR [rsp]
     cdf:	add    rsp,0x10
     ce3:	mov    rsp,rbp
     ce6:	pop    rbp
     ce7:	ret

0000000000000ce8 <botlish_fn_13: esc_bytes<generic>>:
     ce8:	push   rbp
     ce9:	mov    rbp,rsp
     cec:	sub    rsp,0xb0
     cf3:	mov    QWORD PTR [rsp+0x80],rbx
     cfb:	mov    QWORD PTR [rsp+0x88],r12
     d03:	mov    QWORD PTR [rsp+0x90],r13
     d0b:	mov    QWORD PTR [rsp+0x98],r14
     d13:	mov    QWORD PTR [rsp+0xa0],r15
     d1b:	mov    QWORD PTR [rsp+0x28],0x0
     d24:	mov    QWORD PTR [rsp],rsi
     d28:	mov    QWORD PTR [rsp+0x8],rdx
     d2d:	mov    r13,rdx
     d30:	mov    QWORD PTR [rsp+0x10],rcx
     d35:	mov    QWORD PTR [rsp+0x18],r8
     d3a:	mov    QWORD PTR [rsp+0x60],r8
     d3f:	lea    rax,[rsp+0x30]
     d44:	mov    QWORD PTR [rsp+0x70],rax
     d49:	mov    rbx,rdi
     d4c:	mov    r12,rsi
     d4f:	mov    QWORD PTR [rsp+0x68],rcx
     d54:	mov    rsi,r12
     d57:	mov    rdi,rbx
     d5a:	call   d5f <botlish_fn_13+0x77>
			d5b: R_X86_64_PLT32	rt_list_len-0x4
     d5f:	mov    r15,r13
     d62:	mov    rcx,r15
     d65:	and    rcx,rax
     d68:	mov    rdx,rax
     d6b:	test   rcx,0x1
     d72:	jne    d98 <botlish_fn_13+0xb0>
     d78:	mov    rsi,r15
     d7b:	mov    rdi,rbx
     d7e:	call   d83 <botlish_fn_13+0x9b>
			d7f: R_X86_64_PLT32	rt_int_cmp-0x4
     d83:	mov    ecx,0x2
     d88:	test   rax,rax
     d8b:	cmovge rcx,QWORD PTR [rip+0x1dd]        # f70 <botlish_fn_13+0x288>
     d93:	jmp    da8 <botlish_fn_13+0xc0>
     d98:	mov    ecx,0x2
     d9d:	cmp    r15,rdx
     da0:	cmovge rcx,QWORD PTR [rip+0x1c8]        # f70 <botlish_fn_13+0x288>
     da8:	cmp    rcx,0x6
     dac:	je     f35 <botlish_fn_13+0x24d>
     db2:	mov    QWORD PTR [rsp+0x20],0x3
     dbb:	test   r15,0x1
     dc2:	je     de5 <botlish_fn_13+0xfd>
     dc8:	mov    rax,r15
     dcb:	add    rax,0x2
     dcf:	mov    rcx,rax
     dd2:	seto   al
     dd5:	test   al,al
     dd7:	jne    de5 <botlish_fn_13+0xfd>
     ddd:	mov    r14,rcx
     de0:	jmp    dfb <botlish_fn_13+0x113>
     de5:	mov    edx,0x3
     dea:	mov    rsi,r15
     ded:	mov    rdi,rbx
     df0:	call   df5 <botlish_fn_13+0x10d>
			df1: R_X86_64_PLT32	rt_int_add-0x4
     df5:	mov    rcx,rax
     df8:	mov    r14,rcx
     dfb:	mov    QWORD PTR [rsp+0x8],r14
     e00:	mov    rax,QWORD PTR [rbx+0x10]
     e04:	mov    r13,QWORD PTR [rax+0xa8]
     e0b:	mov    QWORD PTR [rsp+0x20],r13
     e10:	test   r15,0x1
     e17:	jne    e25 <botlish_fn_13+0x13d>
     e1d:	mov    rdx,r15
     e20:	jmp    e3c <botlish_fn_13+0x154>
     e25:	mov    rcx,QWORD PTR [r12+0x8]
     e2a:	mov    rax,r15
     e2d:	sar    rax,1
     e30:	cmp    rax,rcx
     e33:	jb     e58 <botlish_fn_13+0x170>
     e39:	mov    rdx,r15
     e3c:	mov    rsi,r12
     e3f:	mov    rdi,rbx
     e42:	call   e47 <botlish_fn_13+0x15f>
			e43: R_X86_64_PLT32	rt_list_get-0x4
     e47:	test   rax,rax
     e4a:	je     ed9 <botlish_fn_13+0x1f1>
     e50:	mov    rsi,rax
     e53:	jmp    e61 <botlish_fn_13+0x179>
     e58:	mov    rdi,QWORD PTR [r12+0x10]
     e5d:	mov    rsi,QWORD PTR [rdi+rax*8]
     e61:	mov    QWORD PTR [rsp+0x28],rsi
     e66:	mov    r15,QWORD PTR [rsp+0x60]
     e6b:	mov    rdx,r15
     e6e:	mov    rdi,rbx
     e71:	call   e76 <botlish_fn_13+0x18e>
			e72: R_X86_64_PLT32	botlish_fn_12-0x4 ; hex_pair<generic>
     e76:	test   rax,rax
     e79:	je     ed9 <botlish_fn_13+0x1f1>
     e7f:	mov    QWORD PTR [rsp+0x28],rax
     e84:	mov    rcx,rax
     e87:	mov    QWORD PTR [rsp+0x30],0x0
     e90:	mov    rax,QWORD PTR [rsp+0x68]
     e95:	mov    QWORD PTR [rsp+0x38],rax
     e9a:	mov    QWORD PTR [rsp+0x40],0x0
     ea3:	mov    QWORD PTR [rsp+0x48],r13
     ea8:	mov    QWORD PTR [rsp+0x50],0x0
     eb1:	mov    rax,rcx
     eb4:	mov    QWORD PTR [rsp+0x58],rax
     eb9:	mov    esi,0x2
     ebe:	mov    edx,0x6
     ec3:	mov    rcx,QWORD PTR [rsp+0x70]
     ec8:	mov    rdi,rbx
     ecb:	call   ed0 <botlish_fn_13+0x1e8>
			ecc: R_X86_64_PLT32	rt_construct-0x4
     ed0:	test   rax,rax
     ed3:	jne    f10 <botlish_fn_13+0x228>
     ed9:	xor    rax,rax
     edc:	mov    rbx,QWORD PTR [rsp+0x80]
     ee4:	mov    r12,QWORD PTR [rsp+0x88]
     eec:	mov    r13,QWORD PTR [rsp+0x90]
     ef4:	mov    r14,QWORD PTR [rsp+0x98]
     efc:	mov    r15,QWORD PTR [rsp+0xa0]
     f04:	add    rsp,0xb0
     f0b:	mov    rsp,rbp
     f0e:	pop    rbp
     f0f:	ret
     f10:	mov    QWORD PTR [rsp],r12
     f14:	mov    QWORD PTR [rsp+0x8],r14
     f19:	mov    QWORD PTR [rsp+0x10],rax
     f1e:	mov    QWORD PTR [rsp+0x18],r15
     f23:	mov    r13,r14
     f26:	mov    QWORD PTR [rsp+0x60],r15
     f2b:	mov    QWORD PTR [rsp+0x68],rax
     f30:	jmp    d54 <botlish_fn_13+0x6c>
     f35:	mov    rax,QWORD PTR [rsp+0x68]
     f3a:	mov    rbx,QWORD PTR [rsp+0x80]
     f42:	mov    r12,QWORD PTR [rsp+0x88]
     f4a:	mov    r13,QWORD PTR [rsp+0x90]
     f52:	mov    r14,QWORD PTR [rsp+0x98]
     f5a:	mov    r15,QWORD PTR [rsp+0xa0]
     f62:	add    rsp,0xb0
     f69:	mov    rsp,rbp
     f6c:	pop    rbp
     f6d:	ret
     f6e:	add    BYTE PTR [rax],al
     f70:	(bad)
     f71:	add    BYTE PTR [rax],al
     f73:	add    BYTE PTR [rax],al
     f75:	add    BYTE PTR [rax],al
	...

0000000000000f78 <botlish_entry_13: esc_bytes<generic>>:
     f78:	push   rbp
     f79:	mov    rbp,rsp
     f7c:	sub    rsp,0x10
     f80:	mov    QWORD PTR [rsp],r12
     f84:	mov    r12,rdi
     f87:	mov    rsi,QWORD PTR [rdx]
     f8a:	mov    r9,QWORD PTR [rdx+0x8]
     f8e:	mov    rcx,QWORD PTR [rdx+0x10]
     f92:	mov    r8,QWORD PTR [rdx+0x18]
     f96:	mov    rdx,r9
     f99:	call   f9e <botlish_entry_13+0x26>
			f9a: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
     f9e:	mov    r9,QWORD PTR [rip+0x0]        # fa5 <botlish_entry_13+0x2d>
			fa1: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
     fa5:	mov    rsi,rax
     fa8:	mov    rdi,r12
     fab:	call   r9
     fae:	mov    r12,QWORD PTR [rsp]
     fb2:	add    rsp,0x10
     fb6:	mov    rsp,rbp
     fb9:	pop    rbp
     fba:	ret

0000000000000fbb <botlish_fn_14: esc_char<generic>>:
     fbb:	push   rbp
     fbc:	mov    rbp,rsp
     fbf:	sub    rsp,0x50
     fc3:	mov    QWORD PTR [rsp+0x20],rbx
     fc8:	mov    QWORD PTR [rsp+0x28],r12
     fcd:	mov    QWORD PTR [rsp+0x30],r13
     fd2:	mov    QWORD PTR [rsp+0x38],r14
     fd7:	mov    QWORD PTR [rsp+0x40],r15
     fdc:	mov    r12,rdi
     fdf:	mov    QWORD PTR [rsp+0x18],0x0
     fe8:	mov    QWORD PTR [rsp],rsi
     fec:	mov    r14,rsi
     fef:	mov    QWORD PTR [rsp+0x8],rdx
     ff4:	mov    r15,rdx
     ff7:	mov    QWORD PTR [rsp+0x10],rcx
     ffc:	mov    rbx,rcx
     fff:	mov    rsi,r14
    1002:	mov    rdi,r12
    1005:	call   100a <botlish_fn_14+0x4f>
			1006: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    100a:	mov    rcx,rax
    100d:	mov    r13,rax
    1010:	test   rax,rcx
    1013:	je     10fd <botlish_fn_14+0x142>
    1019:	mov    rax,r13
    101c:	mov    QWORD PTR [rsp],rax
    1020:	mov    rsi,r13
    1023:	mov    rdi,r12
    1026:	call   102b <botlish_fn_14+0x70>
			1027: R_X86_64_PLT32	rt_list_len-0x4
    102b:	sar    rax,1
    102e:	cmp    rax,0x1
    1032:	je     1072 <botlish_fn_14+0xb7>
    1038:	mov    edx,0x1
    103d:	mov    QWORD PTR [rsp+0x8],0x1
    1046:	mov    rdi,r12
    1049:	mov    rax,QWORD PTR [rdi+0x10]
    104d:	mov    rcx,QWORD PTR [rax+0xa0]
    1054:	mov    QWORD PTR [rsp+0x18],rcx
    1059:	mov    rsi,r13
    105c:	mov    r8,rbx
    105f:	call   1064 <botlish_fn_14+0xa9>
			1060: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    1064:	test   rax,rax
    1067:	je     10fd <botlish_fn_14+0x142>
    106d:	jmp    1128 <botlish_fn_14+0x16d>
    1072:	mov    rsi,r13
    1075:	mov    rax,QWORD PTR [rsi+0x8]
    1079:	mov    r13,rsi
    107c:	test   rax,rax
    107f:	jne    10a9 <botlish_fn_14+0xee>
    1085:	mov    edx,0x1
    108a:	mov    rsi,r13
    108d:	mov    rdi,r12
    1090:	call   1095 <botlish_fn_14+0xda>
			1091: R_X86_64_PLT32	rt_list_get-0x4
    1095:	test   rax,rax
    1098:	je     10fd <botlish_fn_14+0x142>
    109e:	mov    rdx,rax
    10a1:	mov    rsi,r15
    10a4:	jmp    10b6 <botlish_fn_14+0xfb>
    10a9:	mov    rsi,r13
    10ac:	mov    rax,QWORD PTR [rsi+0x10]
    10b0:	mov    rdx,QWORD PTR [rax]
    10b3:	mov    rsi,r15
    10b6:	mov    rdi,r12
    10b9:	call   10be <botlish_fn_14+0x103>
			10ba: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_unreserved<generic>
    10be:	cmp    rax,0x6
    10c2:	je     1125 <botlish_fn_14+0x16a>
    10c8:	mov    edx,0x1
    10cd:	mov    QWORD PTR [rsp+0x8],0x1
    10d6:	mov    rdi,r12
    10d9:	mov    rax,QWORD PTR [rdi+0x10]
    10dd:	mov    rcx,QWORD PTR [rax+0xa0]
    10e4:	mov    QWORD PTR [rsp+0x18],rcx
    10e9:	mov    rsi,r13
    10ec:	mov    r8,rbx
    10ef:	call   10f4 <botlish_fn_14+0x139>
			10f0: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    10f4:	test   rax,rax
    10f7:	jne    1122 <botlish_fn_14+0x167>
    10fd:	xor    rax,rax
    1100:	mov    rbx,QWORD PTR [rsp+0x20]
    1105:	mov    r12,QWORD PTR [rsp+0x28]
    110a:	mov    r13,QWORD PTR [rsp+0x30]
    110f:	mov    r14,QWORD PTR [rsp+0x38]
    1114:	mov    r15,QWORD PTR [rsp+0x40]
    1119:	add    rsp,0x50
    111d:	mov    rsp,rbp
    1120:	pop    rbp
    1121:	ret
    1122:	mov    r14,rax
    1125:	mov    rax,r14
    1128:	mov    rbx,QWORD PTR [rsp+0x20]
    112d:	mov    r12,QWORD PTR [rsp+0x28]
    1132:	mov    r13,QWORD PTR [rsp+0x30]
    1137:	mov    r14,QWORD PTR [rsp+0x38]
    113c:	mov    r15,QWORD PTR [rsp+0x40]
    1141:	add    rsp,0x50
    1145:	mov    rsp,rbp
    1148:	pop    rbp
    1149:	ret

000000000000114a <botlish_entry_14: esc_char<generic>>:
    114a:	push   rbp
    114b:	mov    rbp,rsp
    114e:	sub    rsp,0x10
    1152:	mov    QWORD PTR [rsp],r12
    1156:	mov    r12,rdi
    1159:	mov    rsi,QWORD PTR [rdx]
    115c:	mov    r8,QWORD PTR [rdx+0x8]
    1160:	mov    rcx,QWORD PTR [rdx+0x10]
    1164:	mov    rdx,r8
    1167:	call   116c <botlish_entry_14+0x22>
			1168: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_char<generic>
    116c:	mov    r8,QWORD PTR [rip+0x0]        # 1173 <botlish_entry_14+0x29>
			116f: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1173:	mov    rsi,rax
    1176:	mov    rdi,r12
    1179:	call   r8
    117c:	mov    r12,QWORD PTR [rsp]
    1180:	add    rsp,0x10
    1184:	mov    rsp,rbp
    1187:	pop    rbp
    1188:	ret
    1189:	add    BYTE PTR [rax],al
    118b:	add    BYTE PTR [rax],al
    118d:	add    BYTE PTR [rax],al
	...

0000000000001190 <botlish_fn_15: esc_from<generic>>:
    1190:	push   rbp
    1191:	mov    rbp,rsp
    1194:	sub    rsp,0xb0
    119b:	mov    QWORD PTR [rsp+0x80],rbx
    11a3:	mov    QWORD PTR [rsp+0x88],r12
    11ab:	mov    QWORD PTR [rsp+0x90],r13
    11b3:	mov    QWORD PTR [rsp+0x98],r14
    11bb:	mov    QWORD PTR [rsp+0xa0],r15
    11c3:	mov    r14,rdi
    11c6:	mov    QWORD PTR [rsp+0x28],0x0
    11cf:	mov    QWORD PTR [rsp+0x30],0x0
    11d8:	mov    QWORD PTR [rsp],rsi
    11dc:	mov    QWORD PTR [rsp+0x8],rdx
    11e1:	mov    r12,rdx
    11e4:	mov    QWORD PTR [rsp+0x10],rcx
    11e9:	mov    QWORD PTR [rsp+0x68],rcx
    11ee:	mov    QWORD PTR [rsp+0x18],r8
    11f3:	mov    r15,r8
    11f6:	mov    QWORD PTR [rsp+0x20],r9
    11fb:	mov    r13,r9
    11fe:	xor    eax,eax
    1200:	test   rsi,0x7
    1207:	jne    1216 <botlish_fn_15+0x86>
    120d:	movzx  rax,BYTE PTR [rsi]
    1211:	cmp    al,0x2
    1213:	sete   al
    1216:	test   al,al
    1218:	jne    123b <botlish_fn_15+0xab>
    121e:	mov    rdi,r14
    1221:	mov    rax,QWORD PTR [rdi+0x10]
    1225:	mov    rcx,QWORD PTR [rax+0xb0]
    122c:	mov    edx,0x1
    1231:	call   1236 <botlish_fn_15+0xa6>
			1232: R_X86_64_PLT32	rt_type_error-0x4
    1236:	jmp    13f8 <botlish_fn_15+0x268>
    123b:	mov    rbx,rsi
    123e:	mov    rdi,r14
    1241:	call   1246 <botlish_fn_15+0xb6>
			1242: R_X86_64_PLT32	rt_str_len-0x4
    1246:	mov    rcx,r12
    1249:	and    rcx,rax
    124c:	mov    rdx,rax
    124f:	test   rcx,0x1
    1256:	jne    127c <botlish_fn_15+0xec>
    125c:	mov    rsi,r12
    125f:	mov    rdi,r14
    1262:	call   1267 <botlish_fn_15+0xd7>
			1263: R_X86_64_PLT32	rt_int_cmp-0x4
    1267:	mov    ecx,0x2
    126c:	test   rax,rax
    126f:	cmovge rcx,QWORD PTR [rip+0x1f1]        # 1468 <botlish_fn_15+0x2d8>
    1277:	jmp    128c <botlish_fn_15+0xfc>
    127c:	mov    ecx,0x2
    1281:	cmp    r12,rdx
    1284:	cmovge rcx,QWORD PTR [rip+0x1dc]        # 1468 <botlish_fn_15+0x2d8>
    128c:	cmp    rcx,0x6
    1290:	je     13c7 <botlish_fn_15+0x237>
    1296:	mov    QWORD PTR [rsp+0x28],0x3
    129f:	test   r12,0x1
    12a6:	je     12be <botlish_fn_15+0x12e>
    12ac:	mov    rax,r12
    12af:	add    rax,0x2
    12b3:	seto   cl
    12b6:	test   cl,cl
    12b8:	je     12ce <botlish_fn_15+0x13e>
    12be:	mov    edx,0x3
    12c3:	mov    rsi,r12
    12c6:	mov    rdi,r14
    12c9:	call   12ce <botlish_fn_15+0x13e>
			12ca: R_X86_64_PLT32	rt_int_add-0x4
    12ce:	mov    QWORD PTR [rsp+0x28],rax
    12d3:	mov    QWORD PTR [rsp+0x70],rax
    12d8:	mov    QWORD PTR [rsp+0x30],0x3
    12e1:	test   r12,0x1
    12e8:	je     1300 <botlish_fn_15+0x170>
    12ee:	mov    rcx,r12
    12f1:	add    rcx,0x2
    12f5:	seto   al
    12f8:	test   al,al
    12fa:	je     1313 <botlish_fn_15+0x183>
    1300:	mov    edx,0x3
    1305:	mov    rsi,r12
    1308:	mov    rdi,r14
    130b:	call   1310 <botlish_fn_15+0x180>
			130c: R_X86_64_PLT32	rt_int_add-0x4
    1310:	mov    rcx,rax
    1313:	mov    QWORD PTR [rsp+0x30],rcx
    1318:	mov    rdx,r12
    131b:	mov    rsi,rbx
    131e:	mov    rdi,r14
    1321:	call   1326 <botlish_fn_15+0x196>
			1322: R_X86_64_PLT32	rt_substr-0x4
    1326:	test   rax,rax
    1329:	je     13f8 <botlish_fn_15+0x268>
    132f:	mov    QWORD PTR [rsp+0x8],rax
    1334:	mov    rsi,rax
    1337:	mov    r12,r15
    133a:	mov    rcx,r13
    133d:	mov    rdx,r12
    1340:	mov    rdi,r14
    1343:	call   1348 <botlish_fn_15+0x1b8>
			1344: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_char<generic>
    1348:	test   rax,rax
    134b:	je     13f8 <botlish_fn_15+0x268>
    1351:	mov    QWORD PTR [rsp+0x8],rax
    1356:	lea    rcx,[rsp+0x48]
    135b:	mov    QWORD PTR [rsp+0x48],0x0
    1364:	mov    r11,QWORD PTR [rsp+0x68]
    1369:	mov    QWORD PTR [rsp+0x50],r11
    136e:	mov    QWORD PTR [rsp+0x58],0x0
    1377:	mov    QWORD PTR [rsp+0x60],rax
    137c:	mov    esi,0x2
    1381:	mov    edx,0x4
    1386:	mov    rdi,r14
    1389:	call   138e <botlish_fn_15+0x1fe>
			138a: R_X86_64_PLT32	rt_construct-0x4
    138e:	test   rax,rax
    1391:	je     13f8 <botlish_fn_15+0x268>
    1397:	mov    QWORD PTR [rsp],rbx
    139b:	mov    rcx,QWORD PTR [rsp+0x70]
    13a0:	mov    QWORD PTR [rsp+0x8],rcx
    13a5:	mov    QWORD PTR [rsp+0x10],rax
    13aa:	mov    QWORD PTR [rsp+0x18],r12
    13af:	mov    QWORD PTR [rsp+0x20],r13
    13b4:	mov    QWORD PTR [rsp+0x68],rax
    13b9:	mov    r15,r12
    13bc:	mov    r12,rcx
    13bf:	mov    rsi,rbx
    13c2:	jmp    11fe <botlish_fn_15+0x6e>
    13c7:	mov    r11,QWORD PTR [rsp+0x68]
    13cc:	xor    rsi,rsi
    13cf:	lea    rcx,[rsp+0x38]
    13d4:	mov    QWORD PTR [rsp+0x38],0x0
    13dd:	mov    QWORD PTR [rsp+0x40],r11
    13e2:	mov    edx,0x2
    13e7:	mov    rdi,r14
    13ea:	call   13ef <botlish_fn_15+0x25f>
			13eb: R_X86_64_PLT32	rt_construct-0x4
    13ef:	test   rax,rax
    13f2:	jne    142f <botlish_fn_15+0x29f>
    13f8:	xor    rax,rax
    13fb:	mov    rbx,QWORD PTR [rsp+0x80]
    1403:	mov    r12,QWORD PTR [rsp+0x88]
    140b:	mov    r13,QWORD PTR [rsp+0x90]
    1413:	mov    r14,QWORD PTR [rsp+0x98]
    141b:	mov    r15,QWORD PTR [rsp+0xa0]
    1423:	add    rsp,0xb0
    142a:	mov    rsp,rbp
    142d:	pop    rbp
    142e:	ret
    142f:	mov    rbx,QWORD PTR [rsp+0x80]
    1437:	mov    r12,QWORD PTR [rsp+0x88]
    143f:	mov    r13,QWORD PTR [rsp+0x90]
    1447:	mov    r14,QWORD PTR [rsp+0x98]
    144f:	mov    r15,QWORD PTR [rsp+0xa0]
    1457:	add    rsp,0xb0
    145e:	mov    rsp,rbp
    1461:	pop    rbp
    1462:	ret
    1463:	add    BYTE PTR [rax],al
    1465:	add    BYTE PTR [rax],al
    1467:	add    BYTE PTR [rsi],al
    1469:	add    BYTE PTR [rax],al
    146b:	add    BYTE PTR [rax],al
    146d:	add    BYTE PTR [rax],al
	...

0000000000001470 <botlish_entry_15: esc_from<generic>>:
    1470:	push   rbp
    1471:	mov    rbp,rsp
    1474:	mov    rsi,QWORD PTR [rdx]
    1477:	mov    r10,QWORD PTR [rdx+0x8]
    147b:	mov    rcx,QWORD PTR [rdx+0x10]
    147f:	mov    r8,QWORD PTR [rdx+0x18]
    1483:	mov    r9,QWORD PTR [rdx+0x20]
    1487:	mov    rdx,r10
    148a:	call   148f <botlish_entry_15+0x1f>
			148b: R_X86_64_PLT32	botlish_fn_15-0x4 ; esc_from<generic>
    148f:	mov    rsp,rbp
    1492:	pop    rbp
    1493:	ret

0000000000001494 <botlish_fn_16: check<int, int, str, str>>:
    1494:	push   rbp
    1495:	mov    rbp,rsp
    1498:	sub    rsp,0x50
    149c:	mov    QWORD PTR [rsp+0x20],rbx
    14a1:	mov    QWORD PTR [rsp+0x28],r12
    14a6:	mov    QWORD PTR [rsp+0x30],r13
    14ab:	mov    QWORD PTR [rsp+0x38],r14
    14b0:	mov    QWORD PTR [rsp+0x40],r15
    14b5:	mov    QWORD PTR [rsp+0x18],0x0
    14be:	mov    QWORD PTR [rsp],rdx
    14c2:	mov    QWORD PTR [rsp+0x8],rcx
    14c7:	mov    QWORD PTR [rsp+0x10],r8
    14cc:	mov    r14,r8
    14cf:	sar    rsi,1
    14d2:	mov    r13,rsi
    14d5:	mov    r15,rdx
    14d8:	test   r13,r13
    14db:	jle    15da <botlish_fn_16+0x146>
    14e1:	mov    rbx,rdi
    14e4:	mov    rax,QWORD PTR [rbx+0x10]
    14e8:	mov    rax,QWORD PTR [rax+0xb8]
    14ef:	mov    r12,rcx
    14f2:	mov    rsi,r12
    14f5:	call   14fa <botlish_fn_16+0x66>
			14f6: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    14fa:	test   rax,rax
    14fd:	je     1542 <botlish_fn_16+0xae>
    1503:	cmp    rax,0x6
    1507:	je     1523 <botlish_fn_16+0x8f>
    150d:	mov    edx,0x1
    1512:	mov    QWORD PTR [rsp+0x18],0x1
    151b:	mov    rsi,r15
    151e:	jmp    1588 <botlish_fn_16+0xf4>
    1523:	mov    rax,QWORD PTR [rbx+0x10]
    1527:	mov    rax,QWORD PTR [rax+0xc0]
    152e:	mov    rsi,r12
    1531:	mov    rdi,rbx
    1534:	call   1539 <botlish_fn_16+0xa5>
			1535: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    1539:	test   rax,rax
    153c:	jne    1567 <botlish_fn_16+0xd3>
    1542:	xor    rax,rax
    1545:	mov    rbx,QWORD PTR [rsp+0x20]
    154a:	mov    r12,QWORD PTR [rsp+0x28]
    154f:	mov    r13,QWORD PTR [rsp+0x30]
    1554:	mov    r14,QWORD PTR [rsp+0x38]
    1559:	mov    r15,QWORD PTR [rsp+0x40]
    155e:	add    rsp,0x50
    1562:	mov    rsp,rbp
    1565:	pop    rbp
    1566:	ret
    1567:	cmp    rax,0x6
    156b:	je     157b <botlish_fn_16+0xe7>
    1571:	mov    edx,0x1
    1576:	jmp    1580 <botlish_fn_16+0xec>
    157b:	mov    edx,0x3
    1580:	mov    QWORD PTR [rsp+0x18],rdx
    1585:	mov    rsi,r15
    1588:	mov    rax,rsi
    158b:	and    rax,rdx
    158e:	test   rax,0x1
    1594:	je     15af <botlish_fn_16+0x11b>
    159a:	lea    rcx,[rdx-0x1]
    159e:	mov    rax,rsi
    15a1:	add    rax,rcx
    15a4:	seto   cl
    15a7:	test   cl,cl
    15a9:	je     15b7 <botlish_fn_16+0x123>
    15af:	mov    rdi,rbx
    15b2:	call   15b7 <botlish_fn_16+0x123>
			15b3: R_X86_64_PLT32	rt_int_add-0x4
    15b7:	mov    QWORD PTR [rsp],rax
    15bb:	mov    QWORD PTR [rsp+0x8],r12
    15c0:	mov    r8,r14
    15c3:	mov    QWORD PTR [rsp+0x10],r8
    15c8:	sub    r13,0x1
    15cc:	mov    rcx,r12
    15cf:	mov    rdi,rbx
    15d2:	mov    r15,rax
    15d5:	jmp    14d8 <botlish_fn_16+0x44>
    15da:	mov    rax,r15
    15dd:	mov    rbx,QWORD PTR [rsp+0x20]
    15e2:	mov    r12,QWORD PTR [rsp+0x28]
    15e7:	mov    r13,QWORD PTR [rsp+0x30]
    15ec:	mov    r14,QWORD PTR [rsp+0x38]
    15f1:	mov    r15,QWORD PTR [rsp+0x40]
    15f6:	add    rsp,0x50
    15fa:	mov    rsp,rbp
    15fd:	pop    rbp
    15fe:	ret

00000000000015ff <botlish_entry_16: check<int, int, str, str>>:
    15ff:	push   rbp
    1600:	mov    rbp,rsp
    1603:	mov    rsi,QWORD PTR [rdx]
    1606:	mov    r9,QWORD PTR [rdx+0x8]
    160a:	mov    rcx,QWORD PTR [rdx+0x10]
    160e:	mov    r8,QWORD PTR [rdx+0x18]
    1612:	mov    rdx,r9
    1615:	call   161a <botlish_entry_16+0x1b>
			1616: R_X86_64_PLT32	botlish_fn_16-0x4 ; check<int, int, str, str>
    161a:	mov    rsp,rbp
    161d:	pop    rbp
    161e:	ret
	...

0000000000001620 <botlish_fn_17: <str>>:
    1620:	push   rbp
    1621:	mov    rbp,rsp
    1624:	sub    rsp,0x50
    1628:	mov    QWORD PTR [rsp+0x30],rbx
    162d:	mov    QWORD PTR [rsp+0x38],r12
    1632:	mov    QWORD PTR [rsp+0x40],r13
    1637:	mov    QWORD PTR [rsp+0x48],r14
    163c:	mov    r13,rdi
    163f:	mov    QWORD PTR [rsp+0x18],0x0
    1648:	mov    QWORD PTR [rsp],rsi
    164c:	mov    r14,rsi
    164f:	mov    rsi,r14
    1652:	mov    rdi,r13
    1655:	call   165a <botlish_fn_17+0x3a>
			1656: R_X86_64_PLT32	rt_str_len-0x4
    165a:	mov    rbx,rax
    165d:	mov    QWORD PTR [rsp+0x8],rax
    1662:	mov    esi,0x1
    1667:	mov    QWORD PTR [rsp+0x10],0x1
    1670:	mov    rcx,r14
    1673:	mov    rdx,rbx
    1676:	mov    rdi,r13
    1679:	call   167e <botlish_fn_17+0x5e>
			167a: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    167e:	mov    r12,rax
    1681:	test   r12,r12
    1684:	je     17e1 <botlish_fn_17+0x1c1>
    168a:	mov    QWORD PTR [rsp+0x10],r12
    168f:	test   r12,0x1
    1696:	jne    16c1 <botlish_fn_17+0xa1>
    169c:	mov    edx,0x1
    16a1:	mov    rsi,r12
    16a4:	mov    rdi,r13
    16a7:	call   16ac <botlish_fn_17+0x8c>
			16a8: R_X86_64_PLT32	rt_int_cmp-0x4
    16ac:	mov    ecx,0x2
    16b1:	test   rax,rax
    16b4:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 1880 <botlish_fn_17+0x260>
    16bc:	jmp    16d2 <botlish_fn_17+0xb2>
    16c1:	mov    ecx,0x2
    16c6:	cmp    r12,0x1
    16ca:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 1880 <botlish_fn_17+0x260>
    16d2:	cmp    rcx,0x6
    16d6:	je     185c <botlish_fn_17+0x23c>
    16dc:	mov    rcx,r12
    16df:	and    rcx,rbx
    16e2:	test   rcx,0x1
    16e9:	jne    1712 <botlish_fn_17+0xf2>
    16ef:	mov    rdx,rbx
    16f2:	mov    rsi,r12
    16f5:	mov    rdi,r13
    16f8:	call   16fd <botlish_fn_17+0xdd>
			16f9: R_X86_64_PLT32	rt_int_cmp-0x4
    16fd:	mov    ecx,0x2
    1702:	test   rax,rax
    1705:	cmovge rcx,QWORD PTR [rip+0x173]        # 1880 <botlish_fn_17+0x260>
    170d:	jmp    1722 <botlish_fn_17+0x102>
    1712:	mov    ecx,0x2
    1717:	cmp    r12,rbx
    171a:	cmovge rcx,QWORD PTR [rip+0x15e]        # 1880 <botlish_fn_17+0x260>
    1722:	cmp    rcx,0x6
    1726:	je     1852 <botlish_fn_17+0x232>
    172c:	lea    rcx,[rsp+0x20]
    1731:	mov    rdx,r14
    1734:	mov    rsi,r12
    1737:	mov    rdi,r13
    173a:	call   173f <botlish_fn_17+0x11f>
			173b: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    173f:	test   rax,rax
    1742:	mov    rsi,rax
    1745:	je     17e1 <botlish_fn_17+0x1c1>
    174b:	mov    rdx,QWORD PTR [rsp+0x20]
    1750:	mov    rcx,QWORD PTR [rsp+0x28]
    1755:	mov    rdi,r13
    1758:	mov    rax,QWORD PTR [rdi+0x10]
    175c:	mov    r8,QWORD PTR [rax+0xc8]
    1763:	call   1768 <botlish_fn_17+0x148>
			1764: R_X86_64_PLT32	rt_str_region_eq-0x4
    1768:	cmp    rax,0x6
    176c:	je     177f <botlish_fn_17+0x15f>
    1772:	mov    ecx,0x2
    1777:	mov    rax,rcx
    177a:	jmp    1861 <botlish_fn_17+0x241>
    177f:	mov    QWORD PTR [rsp+0x18],0x3
    1788:	test   r12,0x1
    178f:	jne    179d <botlish_fn_17+0x17d>
    1795:	mov    rcx,r12
    1798:	jmp    17b2 <botlish_fn_17+0x192>
    179d:	mov    rsi,r12
    17a0:	add    rsi,0x2
    17a4:	mov    rcx,r12
    17a7:	seto   al
    17aa:	test   al,al
    17ac:	je     17c5 <botlish_fn_17+0x1a5>
    17b2:	mov    edx,0x3
    17b7:	mov    rsi,rcx
    17ba:	mov    rdi,r13
    17bd:	call   17c2 <botlish_fn_17+0x1a2>
			17be: R_X86_64_PLT32	rt_int_add-0x4
    17c2:	mov    rsi,rax
    17c5:	mov    QWORD PTR [rsp+0x10],rsi
    17ca:	mov    rcx,r14
    17cd:	mov    rdx,rbx
    17d0:	mov    rdi,r13
    17d3:	call   17d8 <botlish_fn_17+0x1b8>
			17d4: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    17d8:	test   rax,rax
    17db:	jne    1801 <botlish_fn_17+0x1e1>
    17e1:	xor    rax,rax
    17e4:	mov    rbx,QWORD PTR [rsp+0x30]
    17e9:	mov    r12,QWORD PTR [rsp+0x38]
    17ee:	mov    r13,QWORD PTR [rsp+0x40]
    17f3:	mov    r14,QWORD PTR [rsp+0x48]
    17f8:	add    rsp,0x50
    17fc:	mov    rsp,rbp
    17ff:	pop    rbp
    1800:	ret
    1801:	mov    rcx,rax
    1804:	and    rcx,rbx
    1807:	mov    rsi,rax
    180a:	test   rcx,0x1
    1811:	jne    183a <botlish_fn_17+0x21a>
    1817:	mov    rdx,rbx
    181a:	mov    rdi,r13
    181d:	call   1822 <botlish_fn_17+0x202>
			181e: R_X86_64_PLT32	rt_int_cmp-0x4
    1822:	mov    ecx,0x2
    1827:	test   rax,rax
    182a:	mov    rax,rcx
    182d:	cmove  rax,QWORD PTR [rip+0x4b]        # 1880 <botlish_fn_17+0x260>
    1835:	jmp    1861 <botlish_fn_17+0x241>
    183a:	mov    rdx,rbx
    183d:	mov    eax,0x2
    1842:	cmp    rsi,rdx
    1845:	cmove  rax,QWORD PTR [rip+0x33]        # 1880 <botlish_fn_17+0x260>
    184d:	jmp    1861 <botlish_fn_17+0x241>
    1852:	mov    eax,0x2
    1857:	jmp    1861 <botlish_fn_17+0x241>
    185c:	mov    eax,0x2
    1861:	mov    rbx,QWORD PTR [rsp+0x30]
    1866:	mov    r12,QWORD PTR [rsp+0x38]
    186b:	mov    r13,QWORD PTR [rsp+0x40]
    1870:	mov    r14,QWORD PTR [rsp+0x48]
    1875:	add    rsp,0x50
    1879:	mov    rsp,rbp
    187c:	pop    rbp
    187d:	ret
    187e:	add    BYTE PTR [rax],al
    1880:	(bad)
    1881:	add    BYTE PTR [rax],al
    1883:	add    BYTE PTR [rax],al
    1885:	add    BYTE PTR [rax],al
	...

0000000000001888 <botlish_entry_17: <str>>:
    1888:	push   rbp
    1889:	mov    rbp,rsp
    188c:	mov    rsi,QWORD PTR [rdx]
    188f:	call   1894 <botlish_entry_17+0xc>
			1890: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    1894:	mov    rsp,rbp
    1897:	pop    rbp
    1898:	ret
    1899:	add    BYTE PTR [rax],al
    189b:	add    BYTE PTR [rax],al
    189d:	add    BYTE PTR [rax],al
	...

00000000000018a0 <botlish_fn_18: <generic>>:
    18a0:	push   rbp
    18a1:	mov    rbp,rsp
    18a4:	sub    rsp,0x60
    18a8:	mov    QWORD PTR [rsp+0x30],rbx
    18ad:	mov    QWORD PTR [rsp+0x38],r12
    18b2:	mov    QWORD PTR [rsp+0x40],r13
    18b7:	mov    QWORD PTR [rsp+0x48],r14
    18bc:	mov    QWORD PTR [rsp+0x50],r15
    18c1:	mov    QWORD PTR [rsp+0x18],0x0
    18ca:	mov    QWORD PTR [rsp],rsi
    18ce:	xor    r8d,r8d
    18d1:	test   rsi,0x7
    18d8:	jne    18e8 <botlish_fn_18+0x48>
    18de:	movzx  rax,BYTE PTR [rsi]
    18e2:	cmp    al,0x2
    18e4:	sete   r8b
    18e8:	test   r8b,r8b
    18eb:	jne    190b <botlish_fn_18+0x6b>
    18f1:	mov    rdx,QWORD PTR [rdi+0x10]
    18f5:	mov    rcx,QWORD PTR [rdx+0xb0]
    18fc:	mov    edx,0x1
    1901:	call   1906 <botlish_fn_18+0x66>
			1902: R_X86_64_PLT32	rt_type_error-0x4
    1906:	jmp    1aa0 <botlish_fn_18+0x200>
    190b:	mov    r13,rsi
    190e:	mov    r14,rdi
    1911:	call   1916 <botlish_fn_18+0x76>
			1912: R_X86_64_PLT32	rt_str_len-0x4
    1916:	mov    rbx,rax
    1919:	mov    QWORD PTR [rsp+0x8],rax
    191e:	mov    edx,0x1
    1923:	mov    r15,rdx
    1926:	mov    QWORD PTR [rsp+0x10],0x1
    192f:	mov    rcx,r13
    1932:	mov    rdx,rbx
    1935:	mov    rsi,r15
    1938:	mov    rdi,r14
    193b:	call   1940 <botlish_fn_18+0xa0>
			193c: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    1940:	mov    r12,rax
    1943:	test   r12,r12
    1946:	je     1aa0 <botlish_fn_18+0x200>
    194c:	mov    QWORD PTR [rsp+0x10],r12
    1951:	test   r12,0x1
    1958:	jne    1981 <botlish_fn_18+0xe1>
    195e:	mov    rdx,r15
    1961:	mov    rsi,r12
    1964:	mov    rdi,r14
    1967:	call   196c <botlish_fn_18+0xcc>
			1968: R_X86_64_PLT32	rt_int_cmp-0x4
    196c:	mov    ecx,0x2
    1971:	test   rax,rax
    1974:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 1b48 <botlish_fn_18+0x2a8>
    197c:	jmp    1992 <botlish_fn_18+0xf2>
    1981:	mov    ecx,0x2
    1986:	cmp    r12,0x1
    198a:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 1b48 <botlish_fn_18+0x2a8>
    1992:	cmp    rcx,0x6
    1996:	je     1b20 <botlish_fn_18+0x280>
    199c:	mov    rax,r12
    199f:	and    rax,rbx
    19a2:	test   rax,0x1
    19a8:	jne    19d1 <botlish_fn_18+0x131>
    19ae:	mov    rdx,rbx
    19b1:	mov    rsi,r12
    19b4:	mov    rdi,r14
    19b7:	call   19bc <botlish_fn_18+0x11c>
			19b8: R_X86_64_PLT32	rt_int_cmp-0x4
    19bc:	mov    ecx,0x2
    19c1:	test   rax,rax
    19c4:	cmovge rcx,QWORD PTR [rip+0x17c]        # 1b48 <botlish_fn_18+0x2a8>
    19cc:	jmp    19e1 <botlish_fn_18+0x141>
    19d1:	mov    ecx,0x2
    19d6:	cmp    r12,rbx
    19d9:	cmovge rcx,QWORD PTR [rip+0x167]        # 1b48 <botlish_fn_18+0x2a8>
    19e1:	cmp    rcx,0x6
    19e5:	je     1b16 <botlish_fn_18+0x276>
    19eb:	lea    rcx,[rsp+0x20]
    19f0:	mov    rdx,r13
    19f3:	mov    rsi,r12
    19f6:	mov    rdi,r14
    19f9:	call   19fe <botlish_fn_18+0x15e>
			19fa: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    19fe:	test   rax,rax
    1a01:	mov    rsi,rax
    1a04:	je     1aa0 <botlish_fn_18+0x200>
    1a0a:	mov    rdx,QWORD PTR [rsp+0x20]
    1a0f:	mov    rcx,QWORD PTR [rsp+0x28]
    1a14:	mov    rdi,r14
    1a17:	mov    rax,QWORD PTR [rdi+0x10]
    1a1b:	mov    r8,QWORD PTR [rax+0xc8]
    1a22:	call   1a27 <botlish_fn_18+0x187>
			1a23: R_X86_64_PLT32	rt_str_region_eq-0x4
    1a27:	cmp    rax,0x6
    1a2b:	je     1a3e <botlish_fn_18+0x19e>
    1a31:	mov    ecx,0x2
    1a36:	mov    rax,rcx
    1a39:	jmp    1b25 <botlish_fn_18+0x285>
    1a3e:	mov    QWORD PTR [rsp+0x18],0x3
    1a47:	test   r12,0x1
    1a4e:	jne    1a5c <botlish_fn_18+0x1bc>
    1a54:	mov    rdi,r12
    1a57:	jmp    1a71 <botlish_fn_18+0x1d1>
    1a5c:	mov    rsi,r12
    1a5f:	add    rsi,0x2
    1a63:	mov    rdi,r12
    1a66:	seto   al
    1a69:	test   al,al
    1a6b:	je     1a84 <botlish_fn_18+0x1e4>
    1a71:	mov    edx,0x3
    1a76:	mov    rsi,rdi
    1a79:	mov    rdi,r14
    1a7c:	call   1a81 <botlish_fn_18+0x1e1>
			1a7d: R_X86_64_PLT32	rt_int_add-0x4
    1a81:	mov    rsi,rax
    1a84:	mov    QWORD PTR [rsp+0x10],rsi
    1a89:	mov    rcx,r13
    1a8c:	mov    rdx,rbx
    1a8f:	mov    rdi,r14
    1a92:	call   1a97 <botlish_fn_18+0x1f7>
			1a93: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    1a97:	test   rax,rax
    1a9a:	jne    1ac5 <botlish_fn_18+0x225>
    1aa0:	xor    rax,rax
    1aa3:	mov    rbx,QWORD PTR [rsp+0x30]
    1aa8:	mov    r12,QWORD PTR [rsp+0x38]
    1aad:	mov    r13,QWORD PTR [rsp+0x40]
    1ab2:	mov    r14,QWORD PTR [rsp+0x48]
    1ab7:	mov    r15,QWORD PTR [rsp+0x50]
    1abc:	add    rsp,0x60
    1ac0:	mov    rsp,rbp
    1ac3:	pop    rbp
    1ac4:	ret
    1ac5:	mov    rcx,rax
    1ac8:	and    rcx,rbx
    1acb:	mov    rsi,rax
    1ace:	test   rcx,0x1
    1ad5:	jne    1afe <botlish_fn_18+0x25e>
    1adb:	mov    rdx,rbx
    1ade:	mov    rdi,r14
    1ae1:	call   1ae6 <botlish_fn_18+0x246>
			1ae2: R_X86_64_PLT32	rt_int_cmp-0x4
    1ae6:	mov    ecx,0x2
    1aeb:	test   rax,rax
    1aee:	mov    rax,rcx
    1af1:	cmove  rax,QWORD PTR [rip+0x4f]        # 1b48 <botlish_fn_18+0x2a8>
    1af9:	jmp    1b25 <botlish_fn_18+0x285>
    1afe:	mov    rdx,rbx
    1b01:	mov    eax,0x2
    1b06:	cmp    rsi,rdx
    1b09:	cmove  rax,QWORD PTR [rip+0x37]        # 1b48 <botlish_fn_18+0x2a8>
    1b11:	jmp    1b25 <botlish_fn_18+0x285>
    1b16:	mov    eax,0x2
    1b1b:	jmp    1b25 <botlish_fn_18+0x285>
    1b20:	mov    eax,0x2
    1b25:	mov    rbx,QWORD PTR [rsp+0x30]
    1b2a:	mov    r12,QWORD PTR [rsp+0x38]
    1b2f:	mov    r13,QWORD PTR [rsp+0x40]
    1b34:	mov    r14,QWORD PTR [rsp+0x48]
    1b39:	mov    r15,QWORD PTR [rsp+0x50]
    1b3e:	add    rsp,0x60
    1b42:	mov    rsp,rbp
    1b45:	pop    rbp
    1b46:	ret
    1b47:	add    BYTE PTR [rsi],al
    1b49:	add    BYTE PTR [rax],al
    1b4b:	add    BYTE PTR [rax],al
    1b4d:	add    BYTE PTR [rax],al
	...

0000000000001b50 <botlish_entry_18: <generic>>:
    1b50:	push   rbp
    1b51:	mov    rbp,rsp
    1b54:	mov    rsi,QWORD PTR [rdx]
    1b57:	call   1b5c <botlish_entry_18+0xc>
			1b58: R_X86_64_PLT32	botlish_fn_18-0x4 ; <generic>
    1b5c:	mov    rsp,rbp
    1b5f:	pop    rbp
    1b60:	ret

0000000000001b61 <botlish_fn_19: char_at<generic>>:
    1b61:	push   rbp
    1b62:	mov    rbp,rsp
    1b65:	sub    rsp,0x50
    1b69:	mov    QWORD PTR [rsp+0x20],rbx
    1b6e:	mov    QWORD PTR [rsp+0x28],r12
    1b73:	mov    QWORD PTR [rsp+0x30],r13
    1b78:	mov    QWORD PTR [rsp+0x38],r14
    1b7d:	mov    QWORD PTR [rsp+0x40],r15
    1b82:	mov    r12,rdi
    1b85:	mov    r15,rcx
    1b88:	mov    QWORD PTR [rsp],rsi
    1b8c:	mov    QWORD PTR [rsp+0x8],rdx
    1b91:	mov    r13,rdx
    1b94:	mov    QWORD PTR [rsp+0x10],0x3
    1b9d:	test   rsi,0x1
    1ba4:	jne    1bb2 <botlish_fn_19+0x51>
    1baa:	mov    rbx,rsi
    1bad:	jmp    1bd2 <botlish_fn_19+0x71>
    1bb2:	mov    rax,rsi
    1bb5:	add    rax,0x2
    1bb9:	mov    rbx,rsi
    1bbc:	seto   cl
    1bbf:	test   cl,cl
    1bc1:	jne    1bd2 <botlish_fn_19+0x71>
    1bc7:	mov    rdi,r12
    1bca:	mov    r14,rax
    1bcd:	jmp    1be8 <botlish_fn_19+0x87>
    1bd2:	mov    edx,0x3
    1bd7:	mov    rsi,rbx
    1bda:	mov    rdi,r12
    1bdd:	call   1be2 <botlish_fn_19+0x81>
			1bde: R_X86_64_PLT32	rt_int_add-0x4
    1be2:	mov    r14,rax
    1be5:	mov    rdi,r12
    1be8:	mov    rcx,r14
    1beb:	mov    rdx,rbx
    1bee:	mov    rsi,r13
    1bf1:	call   1bf6 <botlish_fn_19+0x95>
			1bf2: R_X86_64_PLT32	rt_str_region_check-0x4
    1bf6:	test   rax,rax
    1bf9:	jne    1c24 <botlish_fn_19+0xc3>
    1bff:	xor    rax,rax
    1c02:	mov    rbx,QWORD PTR [rsp+0x20]
    1c07:	mov    r12,QWORD PTR [rsp+0x28]
    1c0c:	mov    r13,QWORD PTR [rsp+0x30]
    1c11:	mov    r14,QWORD PTR [rsp+0x38]
    1c16:	mov    r15,QWORD PTR [rsp+0x40]
    1c1b:	add    rsp,0x50
    1c1f:	mov    rsp,rbp
    1c22:	pop    rbp
    1c23:	ret
    1c24:	mov    rcx,r15
    1c27:	mov    QWORD PTR [rcx],rbx
    1c2a:	mov    rax,r14
    1c2d:	mov    QWORD PTR [rcx+0x8],rax
    1c31:	mov    rax,r13
    1c34:	mov    rbx,QWORD PTR [rsp+0x20]
    1c39:	mov    r12,QWORD PTR [rsp+0x28]
    1c3e:	mov    r13,QWORD PTR [rsp+0x30]
    1c43:	mov    r14,QWORD PTR [rsp+0x38]
    1c48:	mov    r15,QWORD PTR [rsp+0x40]
    1c4d:	add    rsp,0x50
    1c51:	mov    rsp,rbp
    1c54:	pop    rbp
    1c55:	ret

0000000000001c56 <botlish_entry_19: char_at<generic>>:
    1c56:	push   rbp
    1c57:	mov    rbp,rsp
    1c5a:	ud2
    1c5c:	add    BYTE PTR [rax],al
	...

0000000000001c60 <botlish_fn_20: scan_local<generic>>:
    1c60:	push   rbp
    1c61:	mov    rbp,rsp
    1c64:	sub    rsp,0x80
    1c6b:	mov    QWORD PTR [rsp+0x50],rbx
    1c70:	mov    QWORD PTR [rsp+0x58],r12
    1c75:	mov    QWORD PTR [rsp+0x60],r13
    1c7a:	mov    QWORD PTR [rsp+0x68],r14
    1c7f:	mov    QWORD PTR [rsp+0x70],r15
    1c84:	mov    QWORD PTR [rsp+0x18],0x0
    1c8d:	mov    QWORD PTR [rsp],rsi
    1c91:	mov    r15,rsi
    1c94:	mov    QWORD PTR [rsp+0x8],rdx
    1c99:	mov    QWORD PTR [rsp+0x10],rcx
    1c9e:	mov    r13,rcx
    1ca1:	lea    r14,[rsp+0x20]
    1ca6:	mov    rbx,rdx
    1ca9:	mov    rax,rsi
    1cac:	and    rax,rbx
    1caf:	mov    r15,rsi
    1cb2:	test   rax,0x1
    1cb8:	jne    1ce1 <botlish_fn_20+0x81>
    1cbe:	mov    r12,rdi
    1cc1:	mov    rdx,rbx
    1cc4:	mov    rsi,r15
    1cc7:	call   1ccc <botlish_fn_20+0x6c>
			1cc8: R_X86_64_PLT32	rt_int_cmp-0x4
    1ccc:	mov    ecx,0x2
    1cd1:	test   rax,rax
    1cd4:	cmovge rcx,QWORD PTR [rip+0x254]        # 1f30 <botlish_fn_20+0x2d0>
    1cdc:	jmp    1cf7 <botlish_fn_20+0x97>
    1ce1:	mov    r12,rdi
    1ce4:	mov    ecx,0x2
    1ce9:	mov    rsi,r15
    1cec:	cmp    rsi,rbx
    1cef:	cmovge rcx,QWORD PTR [rip+0x239]        # 1f30 <botlish_fn_20+0x2d0>
    1cf7:	cmp    rcx,0x6
    1cfb:	je     1f02 <botlish_fn_20+0x2a2>
    1d01:	mov    rcx,r14
    1d04:	mov    rdx,r13
    1d07:	mov    rsi,r15
    1d0a:	mov    rdi,r12
    1d0d:	call   1d12 <botlish_fn_20+0xb2>
			1d0e: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    1d12:	mov    rcx,rax
    1d15:	mov    QWORD PTR [rsp+0x40],rax
    1d1a:	test   rax,rcx
    1d1d:	je     1d4d <botlish_fn_20+0xed>
    1d23:	mov    rdx,QWORD PTR [rsp+0x20]
    1d28:	mov    QWORD PTR [rsp+0x38],rdx
    1d2d:	mov    rcx,QWORD PTR [rsp+0x28]
    1d32:	mov    QWORD PTR [rsp+0x30],rcx
    1d37:	mov    rsi,QWORD PTR [rsp+0x40]
    1d3c:	mov    rdi,r12
    1d3f:	call   1d44 <botlish_fn_20+0xe4>
			1d40: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1d44:	test   rax,rax
    1d47:	jne    1d75 <botlish_fn_20+0x115>
    1d4d:	xor    rax,rax
    1d50:	mov    rbx,QWORD PTR [rsp+0x50]
    1d55:	mov    r12,QWORD PTR [rsp+0x58]
    1d5a:	mov    r13,QWORD PTR [rsp+0x60]
    1d5f:	mov    r14,QWORD PTR [rsp+0x68]
    1d64:	mov    r15,QWORD PTR [rsp+0x70]
    1d69:	add    rsp,0x80
    1d70:	mov    rsp,rbp
    1d73:	pop    rbp
    1d74:	ret
    1d75:	cmp    rax,0x6
    1d79:	je     1e83 <botlish_fn_20+0x223>
    1d7f:	mov    r9,QWORD PTR [r12+0x10]
    1d84:	mov    r8,QWORD PTR [r9+0xd0]
    1d8b:	mov    rcx,QWORD PTR [rsp+0x30]
    1d90:	mov    rdx,QWORD PTR [rsp+0x38]
    1d95:	mov    rsi,QWORD PTR [rsp+0x40]
    1d9a:	mov    rdi,r12
    1d9d:	call   1da2 <botlish_fn_20+0x142>
			1d9e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1da2:	cmp    rax,0x6
    1da6:	je     1e79 <botlish_fn_20+0x219>
    1dac:	mov    r11,QWORD PTR [r12+0x10]
    1db1:	mov    r8,QWORD PTR [r11+0xd8]
    1db8:	mov    rcx,QWORD PTR [rsp+0x30]
    1dbd:	mov    rdx,QWORD PTR [rsp+0x38]
    1dc2:	mov    rsi,QWORD PTR [rsp+0x40]
    1dc7:	mov    rdi,r12
    1dca:	call   1dcf <botlish_fn_20+0x16f>
			1dcb: R_X86_64_PLT32	rt_str_region_eq-0x4
    1dcf:	cmp    rax,0x6
    1dd3:	je     1e6f <botlish_fn_20+0x20f>
    1dd9:	mov    rax,QWORD PTR [r12+0x10]
    1dde:	mov    r8,QWORD PTR [rax+0xa8]
    1de5:	mov    rcx,QWORD PTR [rsp+0x30]
    1dea:	mov    rdx,QWORD PTR [rsp+0x38]
    1def:	mov    rsi,QWORD PTR [rsp+0x40]
    1df4:	mov    rdi,r12
    1df7:	call   1dfc <botlish_fn_20+0x19c>
			1df8: R_X86_64_PLT32	rt_str_region_eq-0x4
    1dfc:	cmp    rax,0x6
    1e00:	je     1e65 <botlish_fn_20+0x205>
    1e06:	mov    rax,QWORD PTR [r12+0x10]
    1e0b:	mov    r8,QWORD PTR [rax+0xe0]
    1e12:	mov    rcx,QWORD PTR [rsp+0x30]
    1e17:	mov    rdx,QWORD PTR [rsp+0x38]
    1e1c:	mov    rsi,QWORD PTR [rsp+0x40]
    1e21:	mov    rdi,r12
    1e24:	call   1e29 <botlish_fn_20+0x1c9>
			1e25: R_X86_64_PLT32	rt_str_region_eq-0x4
    1e29:	cmp    rax,0x6
    1e2d:	je     1e5b <botlish_fn_20+0x1fb>
    1e33:	mov    rax,QWORD PTR [r12+0x10]
    1e38:	mov    r8,QWORD PTR [rax+0xe8]
    1e3f:	mov    rcx,QWORD PTR [rsp+0x30]
    1e44:	mov    rdx,QWORD PTR [rsp+0x38]
    1e49:	mov    rsi,QWORD PTR [rsp+0x40]
    1e4e:	mov    rdi,r12
    1e51:	call   1e56 <botlish_fn_20+0x1f6>
			1e52: R_X86_64_PLT32	rt_str_region_eq-0x4
    1e56:	jmp    1e88 <botlish_fn_20+0x228>
    1e5b:	mov    eax,0x6
    1e60:	jmp    1e88 <botlish_fn_20+0x228>
    1e65:	mov    eax,0x6
    1e6a:	jmp    1e88 <botlish_fn_20+0x228>
    1e6f:	mov    eax,0x6
    1e74:	jmp    1e88 <botlish_fn_20+0x228>
    1e79:	mov    eax,0x6
    1e7e:	jmp    1e88 <botlish_fn_20+0x228>
    1e83:	mov    eax,0x6
    1e88:	cmp    rax,0x6
    1e8c:	je     1e9a <botlish_fn_20+0x23a>
    1e92:	mov    rax,r15
    1e95:	jmp    1f05 <botlish_fn_20+0x2a5>
    1e9a:	mov    QWORD PTR [rsp+0x18],0x3
    1ea3:	mov    rsi,r15
    1ea6:	test   rsi,0x1
    1ead:	je     1ed3 <botlish_fn_20+0x273>
    1eb3:	mov    rsi,r15
    1eb6:	mov    rax,rsi
    1eb9:	add    rax,0x2
    1ebd:	seto   cl
    1ec0:	test   cl,cl
    1ec2:	jne    1ed3 <botlish_fn_20+0x273>
    1ec8:	mov    rsi,rax
    1ecb:	mov    r15,rax
    1ece:	jmp    1ee9 <botlish_fn_20+0x289>
    1ed3:	mov    edx,0x3
    1ed8:	mov    rsi,r15
    1edb:	mov    rdi,r12
    1ede:	call   1ee3 <botlish_fn_20+0x283>
			1edf: R_X86_64_PLT32	rt_int_add-0x4
    1ee3:	mov    rsi,rax
    1ee6:	mov    r15,rax
    1ee9:	mov    QWORD PTR [rsp],rsi
    1eed:	mov    QWORD PTR [rsp+0x8],rbx
    1ef2:	mov    QWORD PTR [rsp+0x10],r13
    1ef7:	mov    rsi,r15
    1efa:	mov    rdi,r12
    1efd:	jmp    1ca9 <botlish_fn_20+0x49>
    1f02:	mov    rax,r15
    1f05:	mov    rbx,QWORD PTR [rsp+0x50]
    1f0a:	mov    r12,QWORD PTR [rsp+0x58]
    1f0f:	mov    r13,QWORD PTR [rsp+0x60]
    1f14:	mov    r14,QWORD PTR [rsp+0x68]
    1f19:	mov    r15,QWORD PTR [rsp+0x70]
    1f1e:	add    rsp,0x80
    1f25:	mov    rsp,rbp
    1f28:	pop    rbp
    1f29:	ret
    1f2a:	add    BYTE PTR [rax],al
    1f2c:	add    BYTE PTR [rax],al
    1f2e:	add    BYTE PTR [rax],al
    1f30:	(bad)
    1f31:	add    BYTE PTR [rax],al
    1f33:	add    BYTE PTR [rax],al
    1f35:	add    BYTE PTR [rax],al
	...

0000000000001f38 <botlish_entry_20: scan_local<generic>>:
    1f38:	push   rbp
    1f39:	mov    rbp,rsp
    1f3c:	mov    rsi,QWORD PTR [rdx]
    1f3f:	mov    r8,QWORD PTR [rdx+0x8]
    1f43:	mov    rcx,QWORD PTR [rdx+0x10]
    1f47:	mov    rdx,r8
    1f4a:	call   1f4f <botlish_entry_20+0x17>
			1f4b: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    1f4f:	mov    rsp,rbp
    1f52:	pop    rbp
    1f53:	ret
    1f54:	add    BYTE PTR [rax],al
	...

0000000000001f58 <botlish_fn_21: scan_label<generic>>:
    1f58:	push   rbp
    1f59:	mov    rbp,rsp
    1f5c:	sub    rsp,0x80
    1f63:	mov    QWORD PTR [rsp+0x50],rbx
    1f68:	mov    QWORD PTR [rsp+0x58],r12
    1f6d:	mov    QWORD PTR [rsp+0x60],r13
    1f72:	mov    QWORD PTR [rsp+0x68],r14
    1f77:	mov    QWORD PTR [rsp+0x70],r15
    1f7c:	mov    QWORD PTR [rsp+0x18],0x0
    1f85:	mov    QWORD PTR [rsp],rsi
    1f89:	mov    r15,rsi
    1f8c:	mov    QWORD PTR [rsp+0x8],rdx
    1f91:	mov    QWORD PTR [rsp+0x10],rcx
    1f96:	mov    r13,rcx
    1f99:	lea    r14,[rsp+0x20]
    1f9e:	mov    rbx,rdx
    1fa1:	mov    rax,rsi
    1fa4:	and    rax,rbx
    1fa7:	mov    r15,rsi
    1faa:	test   rax,0x1
    1fb0:	jne    1fd9 <botlish_fn_21+0x81>
    1fb6:	mov    r12,rdi
    1fb9:	mov    rdx,rbx
    1fbc:	mov    rsi,r15
    1fbf:	call   1fc4 <botlish_fn_21+0x6c>
			1fc0: R_X86_64_PLT32	rt_int_cmp-0x4
    1fc4:	mov    ecx,0x2
    1fc9:	test   rax,rax
    1fcc:	cmovge rcx,QWORD PTR [rip+0x174]        # 2148 <botlish_fn_21+0x1f0>
    1fd4:	jmp    1fef <botlish_fn_21+0x97>
    1fd9:	mov    r12,rdi
    1fdc:	mov    ecx,0x2
    1fe1:	mov    rsi,r15
    1fe4:	cmp    rsi,rbx
    1fe7:	cmovge rcx,QWORD PTR [rip+0x159]        # 2148 <botlish_fn_21+0x1f0>
    1fef:	cmp    rcx,0x6
    1ff3:	je     211b <botlish_fn_21+0x1c3>
    1ff9:	mov    rcx,r14
    1ffc:	mov    rdx,r13
    1fff:	mov    rsi,r15
    2002:	mov    rdi,r12
    2005:	call   200a <botlish_fn_21+0xb2>
			2006: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    200a:	test   rax,rax
    200d:	mov    QWORD PTR [rsp+0x40],rax
    2012:	je     2042 <botlish_fn_21+0xea>
    2018:	mov    rdx,QWORD PTR [rsp+0x20]
    201d:	mov    QWORD PTR [rsp+0x38],rdx
    2022:	mov    rcx,QWORD PTR [rsp+0x28]
    2027:	mov    QWORD PTR [rsp+0x30],rcx
    202c:	mov    rsi,QWORD PTR [rsp+0x40]
    2031:	mov    rdi,r12
    2034:	call   2039 <botlish_fn_21+0xe1>
			2035: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    2039:	test   rax,rax
    203c:	jne    206a <botlish_fn_21+0x112>
    2042:	xor    rax,rax
    2045:	mov    rbx,QWORD PTR [rsp+0x50]
    204a:	mov    r12,QWORD PTR [rsp+0x58]
    204f:	mov    r13,QWORD PTR [rsp+0x60]
    2054:	mov    r14,QWORD PTR [rsp+0x68]
    2059:	mov    r15,QWORD PTR [rsp+0x70]
    205e:	add    rsp,0x80
    2065:	mov    rsp,rbp
    2068:	pop    rbp
    2069:	ret
    206a:	cmp    rax,0x6
    206e:	je     209c <botlish_fn_21+0x144>
    2074:	mov    rax,QWORD PTR [r12+0x10]
    2079:	mov    r8,QWORD PTR [rax+0xe8]
    2080:	mov    rcx,QWORD PTR [rsp+0x30]
    2085:	mov    rdx,QWORD PTR [rsp+0x38]
    208a:	mov    rsi,QWORD PTR [rsp+0x40]
    208f:	mov    rdi,r12
    2092:	call   2097 <botlish_fn_21+0x13f>
			2093: R_X86_64_PLT32	rt_str_region_eq-0x4
    2097:	jmp    20a1 <botlish_fn_21+0x149>
    209c:	mov    eax,0x6
    20a1:	cmp    rax,0x6
    20a5:	je     20b3 <botlish_fn_21+0x15b>
    20ab:	mov    rax,r15
    20ae:	jmp    211e <botlish_fn_21+0x1c6>
    20b3:	mov    QWORD PTR [rsp+0x18],0x3
    20bc:	mov    rsi,r15
    20bf:	test   rsi,0x1
    20c6:	je     20ec <botlish_fn_21+0x194>
    20cc:	mov    rsi,r15
    20cf:	mov    rax,rsi
    20d2:	add    rax,0x2
    20d6:	seto   cl
    20d9:	test   cl,cl
    20db:	jne    20ec <botlish_fn_21+0x194>
    20e1:	mov    rsi,rax
    20e4:	mov    r15,rax
    20e7:	jmp    2102 <botlish_fn_21+0x1aa>
    20ec:	mov    edx,0x3
    20f1:	mov    rsi,r15
    20f4:	mov    rdi,r12
    20f7:	call   20fc <botlish_fn_21+0x1a4>
			20f8: R_X86_64_PLT32	rt_int_add-0x4
    20fc:	mov    rsi,rax
    20ff:	mov    r15,rax
    2102:	mov    QWORD PTR [rsp],rsi
    2106:	mov    QWORD PTR [rsp+0x8],rbx
    210b:	mov    QWORD PTR [rsp+0x10],r13
    2110:	mov    rsi,r15
    2113:	mov    rdi,r12
    2116:	jmp    1fa1 <botlish_fn_21+0x49>
    211b:	mov    rax,r15
    211e:	mov    rbx,QWORD PTR [rsp+0x50]
    2123:	mov    r12,QWORD PTR [rsp+0x58]
    2128:	mov    r13,QWORD PTR [rsp+0x60]
    212d:	mov    r14,QWORD PTR [rsp+0x68]
    2132:	mov    r15,QWORD PTR [rsp+0x70]
    2137:	add    rsp,0x80
    213e:	mov    rsp,rbp
    2141:	pop    rbp
    2142:	ret
    2143:	add    BYTE PTR [rax],al
    2145:	add    BYTE PTR [rax],al
    2147:	add    BYTE PTR [rsi],al
    2149:	add    BYTE PTR [rax],al
    214b:	add    BYTE PTR [rax],al
    214d:	add    BYTE PTR [rax],al
	...

0000000000002150 <botlish_entry_21: scan_label<generic>>:
    2150:	push   rbp
    2151:	mov    rbp,rsp
    2154:	mov    rsi,QWORD PTR [rdx]
    2157:	mov    r8,QWORD PTR [rdx+0x8]
    215b:	mov    rcx,QWORD PTR [rdx+0x10]
    215f:	mov    rdx,r8
    2162:	call   2167 <botlish_entry_21+0x17>
			2163: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    2167:	mov    rsp,rbp
    216a:	pop    rbp
    216b:	ret
    216c:	add    BYTE PTR [rax],al
	...

0000000000002170 <botlish_fn_22: scan_alpha<generic>>:
    2170:	push   rbp
    2171:	mov    rbp,rsp
    2174:	sub    rsp,0x60
    2178:	mov    QWORD PTR [rsp+0x30],rbx
    217d:	mov    QWORD PTR [rsp+0x38],r12
    2182:	mov    QWORD PTR [rsp+0x40],r13
    2187:	mov    QWORD PTR [rsp+0x48],r14
    218c:	mov    QWORD PTR [rsp+0x50],r15
    2191:	mov    r15,rdi
    2194:	mov    QWORD PTR [rsp+0x18],0x0
    219d:	mov    QWORD PTR [rsp],rsi
    21a1:	mov    r14,rsi
    21a4:	mov    QWORD PTR [rsp+0x8],rdx
    21a9:	mov    QWORD PTR [rsp+0x10],rcx
    21ae:	mov    r12,rcx
    21b1:	lea    r13,[rsp+0x20]
    21b6:	mov    rbx,rdx
    21b9:	mov    rax,rsi
    21bc:	and    rax,rbx
    21bf:	mov    r14,rsi
    21c2:	test   rax,0x1
    21c8:	jne    21f1 <botlish_fn_22+0x81>
    21ce:	mov    rdx,rbx
    21d1:	mov    rsi,r14
    21d4:	mov    rdi,r15
    21d7:	call   21dc <botlish_fn_22+0x6c>
			21d8: R_X86_64_PLT32	rt_int_cmp-0x4
    21dc:	mov    ecx,0x2
    21e1:	test   rax,rax
    21e4:	cmovge rcx,QWORD PTR [rip+0x11c]        # 2308 <botlish_fn_22+0x198>
    21ec:	jmp    2204 <botlish_fn_22+0x94>
    21f1:	mov    ecx,0x2
    21f6:	mov    rsi,r14
    21f9:	cmp    rsi,rbx
    21fc:	cmovge rcx,QWORD PTR [rip+0x104]        # 2308 <botlish_fn_22+0x198>
    2204:	cmp    rcx,0x6
    2208:	je     22e2 <botlish_fn_22+0x172>
    220e:	mov    rcx,r13
    2211:	mov    rdx,r12
    2214:	mov    rsi,r14
    2217:	mov    rdi,r15
    221a:	call   221f <botlish_fn_22+0xaf>
			221b: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    221f:	test   rax,rax
    2222:	mov    rsi,rax
    2225:	je     2246 <botlish_fn_22+0xd6>
    222b:	mov    rdx,QWORD PTR [rsp+0x20]
    2230:	mov    rcx,QWORD PTR [rsp+0x28]
    2235:	mov    rdi,r15
    2238:	call   223d <botlish_fn_22+0xcd>
			2239: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    223d:	test   rax,rax
    2240:	jne    226b <botlish_fn_22+0xfb>
    2246:	xor    rax,rax
    2249:	mov    rbx,QWORD PTR [rsp+0x30]
    224e:	mov    r12,QWORD PTR [rsp+0x38]
    2253:	mov    r13,QWORD PTR [rsp+0x40]
    2258:	mov    r14,QWORD PTR [rsp+0x48]
    225d:	mov    r15,QWORD PTR [rsp+0x50]
    2262:	add    rsp,0x60
    2266:	mov    rsp,rbp
    2269:	pop    rbp
    226a:	ret
    226b:	cmp    rax,0x6
    226f:	je     227d <botlish_fn_22+0x10d>
    2275:	mov    rax,r14
    2278:	jmp    22e5 <botlish_fn_22+0x175>
    227d:	mov    QWORD PTR [rsp+0x18],0x3
    2286:	mov    rsi,r14
    2289:	test   rsi,0x1
    2290:	je     22b6 <botlish_fn_22+0x146>
    2296:	mov    rsi,r14
    2299:	mov    rcx,rsi
    229c:	add    rcx,0x2
    22a0:	seto   al
    22a3:	test   al,al
    22a5:	jne    22b6 <botlish_fn_22+0x146>
    22ab:	mov    rsi,rcx
    22ae:	mov    r14,rcx
    22b1:	jmp    22cc <botlish_fn_22+0x15c>
    22b6:	mov    edx,0x3
    22bb:	mov    rsi,r14
    22be:	mov    rdi,r15
    22c1:	call   22c6 <botlish_fn_22+0x156>
			22c2: R_X86_64_PLT32	rt_int_add-0x4
    22c6:	mov    rsi,rax
    22c9:	mov    r14,rax
    22cc:	mov    QWORD PTR [rsp],rsi
    22d0:	mov    QWORD PTR [rsp+0x8],rbx
    22d5:	mov    QWORD PTR [rsp+0x10],r12
    22da:	mov    rsi,r14
    22dd:	jmp    21b9 <botlish_fn_22+0x49>
    22e2:	mov    rax,r14
    22e5:	mov    rbx,QWORD PTR [rsp+0x30]
    22ea:	mov    r12,QWORD PTR [rsp+0x38]
    22ef:	mov    r13,QWORD PTR [rsp+0x40]
    22f4:	mov    r14,QWORD PTR [rsp+0x48]
    22f9:	mov    r15,QWORD PTR [rsp+0x50]
    22fe:	add    rsp,0x60
    2302:	mov    rsp,rbp
    2305:	pop    rbp
    2306:	ret
    2307:	add    BYTE PTR [rsi],al
    2309:	add    BYTE PTR [rax],al
    230b:	add    BYTE PTR [rax],al
    230d:	add    BYTE PTR [rax],al
	...

0000000000002310 <botlish_entry_22: scan_alpha<generic>>:
    2310:	push   rbp
    2311:	mov    rbp,rsp
    2314:	mov    rsi,QWORD PTR [rdx]
    2317:	mov    r8,QWORD PTR [rdx+0x8]
    231b:	mov    rcx,QWORD PTR [rdx+0x10]
    231f:	mov    rdx,r8
    2322:	call   2327 <botlish_entry_22+0x17>
			2323: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    2327:	mov    rsp,rbp
    232a:	pop    rbp
    232b:	ret
    232c:	add    BYTE PTR [rax],al
	...

0000000000002330 <botlish_fn_23: tld_ok<generic>>:
    2330:	push   rbp
    2331:	mov    rbp,rsp
    2334:	sub    rsp,0x40
    2338:	mov    QWORD PTR [rsp+0x20],rbx
    233d:	mov    QWORD PTR [rsp+0x28],r12
    2342:	mov    QWORD PTR [rsp+0x30],r13
    2347:	mov    QWORD PTR [rsp+0x38],r14
    234c:	mov    r12,rdi
    234f:	mov    QWORD PTR [rsp],rsi
    2353:	mov    rdi,rsi
    2356:	mov    QWORD PTR [rsp+0x8],rdx
    235b:	mov    r14,rdx
    235e:	mov    QWORD PTR [rsp+0x10],rcx
    2363:	mov    rbx,rdi
    2366:	mov    rdx,r14
    2369:	mov    rsi,rbx
    236c:	mov    rdi,r12
    236f:	call   2374 <botlish_fn_23+0x44>
			2370: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    2374:	mov    rcx,rax
    2377:	mov    r13,rax
    237a:	test   rax,rcx
    237d:	jne    23a3 <botlish_fn_23+0x73>
    2383:	xor    rax,rax
    2386:	mov    rbx,QWORD PTR [rsp+0x20]
    238b:	mov    r12,QWORD PTR [rsp+0x28]
    2390:	mov    r13,QWORD PTR [rsp+0x30]
    2395:	mov    r14,QWORD PTR [rsp+0x38]
    239a:	add    rsp,0x40
    239e:	mov    rsp,rbp
    23a1:	pop    rbp
    23a2:	ret
    23a3:	mov    rax,r13
    23a6:	mov    QWORD PTR [rsp+0x8],rax
    23ab:	mov    rdx,r14
    23ae:	and    rax,rdx
    23b1:	test   rax,0x1
    23b7:	jne    23e0 <botlish_fn_23+0xb0>
    23bd:	mov    rsi,r13
    23c0:	mov    rdi,r12
    23c3:	call   23c8 <botlish_fn_23+0x98>
			23c4: R_X86_64_PLT32	rt_int_cmp-0x4
    23c8:	mov    ecx,0x2
    23cd:	test   rax,rax
    23d0:	cmove  rcx,QWORD PTR [rip+0xe0]        # 24b8 <botlish_fn_23+0x188>
    23d8:	mov    rax,r13
    23db:	jmp    23f3 <botlish_fn_23+0xc3>
    23e0:	mov    ecx,0x2
    23e5:	mov    rax,r13
    23e8:	cmp    rax,rdx
    23eb:	cmove  rcx,QWORD PTR [rip+0xc5]        # 24b8 <botlish_fn_23+0x188>
    23f3:	cmp    rcx,0x6
    23f7:	je     240a <botlish_fn_23+0xda>
    23fd:	mov    ecx,0x2
    2402:	mov    rax,rcx
    2405:	jmp    2497 <botlish_fn_23+0x167>
    240a:	mov    rcx,rax
    240d:	and    rcx,rbx
    2410:	test   rcx,0x1
    2417:	jne    2428 <botlish_fn_23+0xf8>
    241d:	mov    rdx,rbx
    2420:	mov    rsi,rax
    2423:	jmp    2449 <botlish_fn_23+0x119>
    2428:	mov    rcx,rax
    242b:	sub    rcx,rbx
    242e:	mov    rdi,rbx
    2431:	mov    r13,rax
    2434:	seto   al
    2437:	lea    rsi,[rcx+0x1]
    243b:	test   al,al
    243d:	je     2454 <botlish_fn_23+0x124>
    2443:	mov    rdx,rdi
    2446:	mov    rsi,r13
    2449:	mov    rdi,r12
    244c:	call   2451 <botlish_fn_23+0x121>
			244d: R_X86_64_PLT32	rt_int_sub-0x4
    2451:	mov    rsi,rax
    2454:	test   rsi,0x1
    245b:	jne    2486 <botlish_fn_23+0x156>
    2461:	mov    edx,0x5
    2466:	mov    rdi,r12
    2469:	call   246e <botlish_fn_23+0x13e>
			246a: R_X86_64_PLT32	rt_int_cmp-0x4
    246e:	mov    ecx,0x2
    2473:	test   rax,rax
    2476:	mov    rax,rcx
    2479:	cmovge rax,QWORD PTR [rip+0x37]        # 24b8 <botlish_fn_23+0x188>
    2481:	jmp    2497 <botlish_fn_23+0x167>
    2486:	mov    eax,0x2
    248b:	cmp    rsi,0x5
    248f:	cmovge rax,QWORD PTR [rip+0x21]        # 24b8 <botlish_fn_23+0x188>
    2497:	mov    rbx,QWORD PTR [rsp+0x20]
    249c:	mov    r12,QWORD PTR [rsp+0x28]
    24a1:	mov    r13,QWORD PTR [rsp+0x30]
    24a6:	mov    r14,QWORD PTR [rsp+0x38]
    24ab:	add    rsp,0x40
    24af:	mov    rsp,rbp
    24b2:	pop    rbp
    24b3:	ret
    24b4:	add    BYTE PTR [rax],al
    24b6:	add    BYTE PTR [rax],al
    24b8:	(bad)
    24b9:	add    BYTE PTR [rax],al
    24bb:	add    BYTE PTR [rax],al
    24bd:	add    BYTE PTR [rax],al
	...

00000000000024c0 <botlish_entry_23: tld_ok<generic>>:
    24c0:	push   rbp
    24c1:	mov    rbp,rsp
    24c4:	mov    rsi,QWORD PTR [rdx]
    24c7:	mov    r8,QWORD PTR [rdx+0x8]
    24cb:	mov    rcx,QWORD PTR [rdx+0x10]
    24cf:	mov    rdx,r8
    24d2:	call   24d7 <botlish_entry_23+0x17>
			24d3: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    24d7:	mov    rsp,rbp
    24da:	pop    rbp
    24db:	ret
    24dc:	add    BYTE PTR [rax],al
	...

00000000000024e0 <botlish_fn_24: domain_loop<generic>>:
    24e0:	push   rbp
    24e1:	mov    rbp,rsp
    24e4:	sub    rsp,0x70
    24e8:	mov    QWORD PTR [rsp+0x40],rbx
    24ed:	mov    QWORD PTR [rsp+0x48],r12
    24f2:	mov    QWORD PTR [rsp+0x50],r13
    24f7:	mov    QWORD PTR [rsp+0x58],r14
    24fc:	mov    QWORD PTR [rsp+0x60],r15
    2501:	mov    QWORD PTR [rsp+0x18],0x0
    250a:	mov    QWORD PTR [rsp],rsi
    250e:	mov    QWORD PTR [rsp+0x8],rdx
    2513:	mov    QWORD PTR [rsp+0x10],rcx
    2518:	lea    rbx,[rsp+0x20]
    251d:	mov    r12,rdi
    2520:	mov    r13,rcx
    2523:	mov    r14,rdx
    2526:	mov    QWORD PTR [rsp+0x30],rsi
    252b:	mov    rcx,r13
    252e:	mov    rdx,r14
    2531:	mov    rsi,QWORD PTR [rsp+0x30]
    2536:	mov    rdi,r12
    2539:	call   253e <botlish_fn_24+0x5e>
			253a: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    253e:	mov    rcx,rax
    2541:	mov    r15,rax
    2544:	test   rax,rcx
    2547:	je     269e <botlish_fn_24+0x1be>
    254d:	mov    rax,r15
    2550:	mov    QWORD PTR [rsp],rax
    2554:	mov    rdx,QWORD PTR [rsp+0x30]
    2559:	and    rax,rdx
    255c:	test   rax,0x1
    2562:	jne    2588 <botlish_fn_24+0xa8>
    2568:	mov    rsi,r15
    256b:	mov    rdi,r12
    256e:	call   2573 <botlish_fn_24+0x93>
			256f: R_X86_64_PLT32	rt_int_cmp-0x4
    2573:	mov    ecx,0x2
    2578:	test   rax,rax
    257b:	cmove  rcx,QWORD PTR [rip+0x19d]        # 2720 <botlish_fn_24+0x240>
    2583:	jmp    2598 <botlish_fn_24+0xb8>
    2588:	mov    ecx,0x2
    258d:	cmp    r15,rdx
    2590:	cmove  rcx,QWORD PTR [rip+0x188]        # 2720 <botlish_fn_24+0x240>
    2598:	cmp    rcx,0x6
    259c:	je     26f4 <botlish_fn_24+0x214>
    25a2:	mov    rax,r15
    25a5:	and    rax,r14
    25a8:	test   rax,0x1
    25ae:	jne    25d7 <botlish_fn_24+0xf7>
    25b4:	mov    rdx,r14
    25b7:	mov    rsi,r15
    25ba:	mov    rdi,r12
    25bd:	call   25c2 <botlish_fn_24+0xe2>
			25be: R_X86_64_PLT32	rt_int_cmp-0x4
    25c2:	mov    ecx,0x2
    25c7:	test   rax,rax
    25ca:	cmovge rcx,QWORD PTR [rip+0x14e]        # 2720 <botlish_fn_24+0x240>
    25d2:	jmp    25e7 <botlish_fn_24+0x107>
    25d7:	mov    ecx,0x2
    25dc:	cmp    r15,r14
    25df:	cmovge rcx,QWORD PTR [rip+0x139]        # 2720 <botlish_fn_24+0x240>
    25e7:	cmp    rcx,0x6
    25eb:	je     26e5 <botlish_fn_24+0x205>
    25f1:	mov    rcx,rbx
    25f4:	mov    rdx,r13
    25f7:	mov    rsi,r15
    25fa:	mov    rdi,r12
    25fd:	call   2602 <botlish_fn_24+0x122>
			25fe: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    2602:	test   rax,rax
    2605:	je     269e <botlish_fn_24+0x1be>
    260b:	mov    rdx,QWORD PTR [rsp+0x20]
    2610:	mov    rcx,QWORD PTR [rsp+0x28]
    2615:	mov    rsi,QWORD PTR [r12+0x10]
    261a:	mov    r8,QWORD PTR [rsi+0xd0]
    2621:	mov    rsi,rax
    2624:	mov    rdi,r12
    2627:	call   262c <botlish_fn_24+0x14c>
			2628: R_X86_64_PLT32	rt_str_region_eq-0x4
    262c:	cmp    rax,0x6
    2630:	je     2642 <botlish_fn_24+0x162>
    2636:	mov    r14,0xffffffffffffffff
    263d:	jmp    26ec <botlish_fn_24+0x20c>
    2642:	mov    QWORD PTR [rsp+0x18],0x3
    264b:	test   r15,0x1
    2652:	je     266a <botlish_fn_24+0x18a>
    2658:	mov    rdx,r15
    265b:	add    rdx,0x2
    265f:	seto   al
    2662:	test   al,al
    2664:	je     267d <botlish_fn_24+0x19d>
    266a:	mov    edx,0x3
    266f:	mov    rsi,r15
    2672:	mov    rdi,r12
    2675:	call   267a <botlish_fn_24+0x19a>
			2676: R_X86_64_PLT32	rt_int_add-0x4
    267a:	mov    rdx,rax
    267d:	mov    QWORD PTR [rsp],rdx
    2681:	mov    r15,rdx
    2684:	mov    rcx,r13
    2687:	mov    rdx,r14
    268a:	mov    rsi,r15
    268d:	mov    rdi,r12
    2690:	call   2695 <botlish_fn_24+0x1b5>
			2691: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    2695:	test   rax,rax
    2698:	jne    26c3 <botlish_fn_24+0x1e3>
    269e:	xor    rax,rax
    26a1:	mov    rbx,QWORD PTR [rsp+0x40]
    26a6:	mov    r12,QWORD PTR [rsp+0x48]
    26ab:	mov    r13,QWORD PTR [rsp+0x50]
    26b0:	mov    r14,QWORD PTR [rsp+0x58]
    26b5:	mov    r15,QWORD PTR [rsp+0x60]
    26ba:	add    rsp,0x70
    26be:	mov    rsp,rbp
    26c1:	pop    rbp
    26c2:	ret
    26c3:	cmp    rax,0x6
    26c7:	je     26ec <botlish_fn_24+0x20c>
    26cd:	mov    QWORD PTR [rsp],r15
    26d1:	mov    QWORD PTR [rsp+0x8],r14
    26d6:	mov    QWORD PTR [rsp+0x10],r13
    26db:	mov    QWORD PTR [rsp+0x30],r15
    26e0:	jmp    252b <botlish_fn_24+0x4b>
    26e5:	mov    r14,0xffffffffffffffff
    26ec:	mov    rax,r14
    26ef:	jmp    26fb <botlish_fn_24+0x21b>
    26f4:	mov    rax,0xffffffffffffffff
    26fb:	mov    rbx,QWORD PTR [rsp+0x40]
    2700:	mov    r12,QWORD PTR [rsp+0x48]
    2705:	mov    r13,QWORD PTR [rsp+0x50]
    270a:	mov    r14,QWORD PTR [rsp+0x58]
    270f:	mov    r15,QWORD PTR [rsp+0x60]
    2714:	add    rsp,0x70
    2718:	mov    rsp,rbp
    271b:	pop    rbp
    271c:	ret
    271d:	add    BYTE PTR [rax],al
    271f:	add    BYTE PTR [rsi],al
    2721:	add    BYTE PTR [rax],al
    2723:	add    BYTE PTR [rax],al
    2725:	add    BYTE PTR [rax],al
	...

0000000000002728 <botlish_entry_24: domain_loop<generic>>:
    2728:	push   rbp
    2729:	mov    rbp,rsp
    272c:	mov    rsi,QWORD PTR [rdx]
    272f:	mov    r8,QWORD PTR [rdx+0x8]
    2733:	mov    rcx,QWORD PTR [rdx+0x10]
    2737:	mov    rdx,r8
    273a:	call   273f <botlish_entry_24+0x17>
			273b: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    273f:	mov    rsp,rbp
    2742:	pop    rbp
    2743:	ret
    2744:	add    BYTE PTR [rax],al
	...

0000000000002748 <botlish_fn_25: <str>>:
    2748:	push   rbp
    2749:	mov    rbp,rsp
    274c:	sub    rsp,0x50
    2750:	mov    QWORD PTR [rsp+0x30],rbx
    2755:	mov    QWORD PTR [rsp+0x38],r12
    275a:	mov    QWORD PTR [rsp+0x40],r13
    275f:	mov    QWORD PTR [rsp+0x48],r14
    2764:	mov    r13,rdi
    2767:	mov    QWORD PTR [rsp+0x18],0x0
    2770:	mov    QWORD PTR [rsp],rsi
    2774:	mov    r14,rsi
    2777:	mov    rsi,r14
    277a:	mov    rdi,r13
    277d:	call   2782 <botlish_fn_25+0x3a>
			277e: R_X86_64_PLT32	rt_str_len-0x4
    2782:	mov    rbx,rax
    2785:	mov    QWORD PTR [rsp+0x8],rax
    278a:	mov    esi,0x1
    278f:	mov    QWORD PTR [rsp+0x10],0x1
    2798:	mov    rcx,r14
    279b:	mov    rdx,rbx
    279e:	mov    rdi,r13
    27a1:	call   27a6 <botlish_fn_25+0x5e>
			27a2: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    27a6:	mov    r12,rax
    27a9:	test   r12,r12
    27ac:	je     2909 <botlish_fn_25+0x1c1>
    27b2:	mov    QWORD PTR [rsp+0x10],r12
    27b7:	test   r12,0x1
    27be:	jne    27e9 <botlish_fn_25+0xa1>
    27c4:	mov    edx,0x1
    27c9:	mov    rsi,r12
    27cc:	mov    rdi,r13
    27cf:	call   27d4 <botlish_fn_25+0x8c>
			27d0: R_X86_64_PLT32	rt_int_cmp-0x4
    27d4:	mov    ecx,0x2
    27d9:	test   rax,rax
    27dc:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 29a8 <botlish_fn_25+0x260>
    27e4:	jmp    27fa <botlish_fn_25+0xb2>
    27e9:	mov    ecx,0x2
    27ee:	cmp    r12,0x1
    27f2:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 29a8 <botlish_fn_25+0x260>
    27fa:	cmp    rcx,0x6
    27fe:	je     2984 <botlish_fn_25+0x23c>
    2804:	mov    rcx,r12
    2807:	and    rcx,rbx
    280a:	test   rcx,0x1
    2811:	jne    283a <botlish_fn_25+0xf2>
    2817:	mov    rdx,rbx
    281a:	mov    rsi,r12
    281d:	mov    rdi,r13
    2820:	call   2825 <botlish_fn_25+0xdd>
			2821: R_X86_64_PLT32	rt_int_cmp-0x4
    2825:	mov    ecx,0x2
    282a:	test   rax,rax
    282d:	cmovge rcx,QWORD PTR [rip+0x173]        # 29a8 <botlish_fn_25+0x260>
    2835:	jmp    284a <botlish_fn_25+0x102>
    283a:	mov    ecx,0x2
    283f:	cmp    r12,rbx
    2842:	cmovge rcx,QWORD PTR [rip+0x15e]        # 29a8 <botlish_fn_25+0x260>
    284a:	cmp    rcx,0x6
    284e:	je     297a <botlish_fn_25+0x232>
    2854:	lea    rcx,[rsp+0x20]
    2859:	mov    rdx,r14
    285c:	mov    rsi,r12
    285f:	mov    rdi,r13
    2862:	call   2867 <botlish_fn_25+0x11f>
			2863: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    2867:	test   rax,rax
    286a:	mov    rsi,rax
    286d:	je     2909 <botlish_fn_25+0x1c1>
    2873:	mov    rdx,QWORD PTR [rsp+0x20]
    2878:	mov    rcx,QWORD PTR [rsp+0x28]
    287d:	mov    rdi,r13
    2880:	mov    rax,QWORD PTR [rdi+0x10]
    2884:	mov    r8,QWORD PTR [rax+0xc8]
    288b:	call   2890 <botlish_fn_25+0x148>
			288c: R_X86_64_PLT32	rt_str_region_eq-0x4
    2890:	cmp    rax,0x6
    2894:	je     28a7 <botlish_fn_25+0x15f>
    289a:	mov    ecx,0x2
    289f:	mov    rax,rcx
    28a2:	jmp    2989 <botlish_fn_25+0x241>
    28a7:	mov    QWORD PTR [rsp+0x18],0x3
    28b0:	test   r12,0x1
    28b7:	jne    28c5 <botlish_fn_25+0x17d>
    28bd:	mov    rcx,r12
    28c0:	jmp    28da <botlish_fn_25+0x192>
    28c5:	mov    rsi,r12
    28c8:	add    rsi,0x2
    28cc:	mov    rcx,r12
    28cf:	seto   al
    28d2:	test   al,al
    28d4:	je     28ed <botlish_fn_25+0x1a5>
    28da:	mov    edx,0x3
    28df:	mov    rsi,rcx
    28e2:	mov    rdi,r13
    28e5:	call   28ea <botlish_fn_25+0x1a2>
			28e6: R_X86_64_PLT32	rt_int_add-0x4
    28ea:	mov    rsi,rax
    28ed:	mov    QWORD PTR [rsp+0x10],rsi
    28f2:	mov    rcx,r14
    28f5:	mov    rdx,rbx
    28f8:	mov    rdi,r13
    28fb:	call   2900 <botlish_fn_25+0x1b8>
			28fc: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    2900:	test   rax,rax
    2903:	jne    2929 <botlish_fn_25+0x1e1>
    2909:	xor    rax,rax
    290c:	mov    rbx,QWORD PTR [rsp+0x30]
    2911:	mov    r12,QWORD PTR [rsp+0x38]
    2916:	mov    r13,QWORD PTR [rsp+0x40]
    291b:	mov    r14,QWORD PTR [rsp+0x48]
    2920:	add    rsp,0x50
    2924:	mov    rsp,rbp
    2927:	pop    rbp
    2928:	ret
    2929:	mov    rcx,rax
    292c:	and    rcx,rbx
    292f:	mov    rsi,rax
    2932:	test   rcx,0x1
    2939:	jne    2962 <botlish_fn_25+0x21a>
    293f:	mov    rdx,rbx
    2942:	mov    rdi,r13
    2945:	call   294a <botlish_fn_25+0x202>
			2946: R_X86_64_PLT32	rt_int_cmp-0x4
    294a:	mov    ecx,0x2
    294f:	test   rax,rax
    2952:	mov    rax,rcx
    2955:	cmove  rax,QWORD PTR [rip+0x4b]        # 29a8 <botlish_fn_25+0x260>
    295d:	jmp    2989 <botlish_fn_25+0x241>
    2962:	mov    rdx,rbx
    2965:	mov    eax,0x2
    296a:	cmp    rsi,rdx
    296d:	cmove  rax,QWORD PTR [rip+0x33]        # 29a8 <botlish_fn_25+0x260>
    2975:	jmp    2989 <botlish_fn_25+0x241>
    297a:	mov    eax,0x2
    297f:	jmp    2989 <botlish_fn_25+0x241>
    2984:	mov    eax,0x2
    2989:	mov    rbx,QWORD PTR [rsp+0x30]
    298e:	mov    r12,QWORD PTR [rsp+0x38]
    2993:	mov    r13,QWORD PTR [rsp+0x40]
    2998:	mov    r14,QWORD PTR [rsp+0x48]
    299d:	add    rsp,0x50
    29a1:	mov    rsp,rbp
    29a4:	pop    rbp
    29a5:	ret
    29a6:	add    BYTE PTR [rax],al
    29a8:	(bad)
    29a9:	add    BYTE PTR [rax],al
    29ab:	add    BYTE PTR [rax],al
    29ad:	add    BYTE PTR [rax],al
	...

00000000000029b0 <botlish_entry_25: <str>>:
    29b0:	push   rbp
    29b1:	mov    rbp,rsp
    29b4:	mov    rsi,QWORD PTR [rdx]
    29b7:	call   29bc <botlish_entry_25+0xc>
			29b8: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    29bc:	mov    rsp,rbp
    29bf:	pop    rbp
    29c0:	ret
    29c1:	add    BYTE PTR [rax],al
    29c3:	add    BYTE PTR [rax],al
    29c5:	add    BYTE PTR [rax],al
	...

00000000000029c8 <botlish_fn_26: <generic>>:
    29c8:	push   rbp
    29c9:	mov    rbp,rsp
    29cc:	sub    rsp,0x60
    29d0:	mov    QWORD PTR [rsp+0x30],rbx
    29d5:	mov    QWORD PTR [rsp+0x38],r12
    29da:	mov    QWORD PTR [rsp+0x40],r13
    29df:	mov    QWORD PTR [rsp+0x48],r14
    29e4:	mov    QWORD PTR [rsp+0x50],r15
    29e9:	mov    QWORD PTR [rsp+0x18],0x0
    29f2:	mov    QWORD PTR [rsp],rsi
    29f6:	xor    r8d,r8d
    29f9:	test   rsi,0x7
    2a00:	jne    2a10 <botlish_fn_26+0x48>
    2a06:	movzx  rax,BYTE PTR [rsi]
    2a0a:	cmp    al,0x2
    2a0c:	sete   r8b
    2a10:	test   r8b,r8b
    2a13:	jne    2a33 <botlish_fn_26+0x6b>
    2a19:	mov    rdx,QWORD PTR [rdi+0x10]
    2a1d:	mov    rcx,QWORD PTR [rdx+0xb0]
    2a24:	mov    edx,0x1
    2a29:	call   2a2e <botlish_fn_26+0x66>
			2a2a: R_X86_64_PLT32	rt_type_error-0x4
    2a2e:	jmp    2bc8 <botlish_fn_26+0x200>
    2a33:	mov    r13,rsi
    2a36:	mov    r14,rdi
    2a39:	call   2a3e <botlish_fn_26+0x76>
			2a3a: R_X86_64_PLT32	rt_str_len-0x4
    2a3e:	mov    rbx,rax
    2a41:	mov    QWORD PTR [rsp+0x8],rax
    2a46:	mov    edx,0x1
    2a4b:	mov    r15,rdx
    2a4e:	mov    QWORD PTR [rsp+0x10],0x1
    2a57:	mov    rcx,r13
    2a5a:	mov    rdx,rbx
    2a5d:	mov    rsi,r15
    2a60:	mov    rdi,r14
    2a63:	call   2a68 <botlish_fn_26+0xa0>
			2a64: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    2a68:	mov    r12,rax
    2a6b:	test   r12,r12
    2a6e:	je     2bc8 <botlish_fn_26+0x200>
    2a74:	mov    QWORD PTR [rsp+0x10],r12
    2a79:	test   r12,0x1
    2a80:	jne    2aa9 <botlish_fn_26+0xe1>
    2a86:	mov    rdx,r15
    2a89:	mov    rsi,r12
    2a8c:	mov    rdi,r14
    2a8f:	call   2a94 <botlish_fn_26+0xcc>
			2a90: R_X86_64_PLT32	rt_int_cmp-0x4
    2a94:	mov    ecx,0x2
    2a99:	test   rax,rax
    2a9c:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 2c70 <botlish_fn_26+0x2a8>
    2aa4:	jmp    2aba <botlish_fn_26+0xf2>
    2aa9:	mov    ecx,0x2
    2aae:	cmp    r12,0x1
    2ab2:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 2c70 <botlish_fn_26+0x2a8>
    2aba:	cmp    rcx,0x6
    2abe:	je     2c48 <botlish_fn_26+0x280>
    2ac4:	mov    rax,r12
    2ac7:	and    rax,rbx
    2aca:	test   rax,0x1
    2ad0:	jne    2af9 <botlish_fn_26+0x131>
    2ad6:	mov    rdx,rbx
    2ad9:	mov    rsi,r12
    2adc:	mov    rdi,r14
    2adf:	call   2ae4 <botlish_fn_26+0x11c>
			2ae0: R_X86_64_PLT32	rt_int_cmp-0x4
    2ae4:	mov    ecx,0x2
    2ae9:	test   rax,rax
    2aec:	cmovge rcx,QWORD PTR [rip+0x17c]        # 2c70 <botlish_fn_26+0x2a8>
    2af4:	jmp    2b09 <botlish_fn_26+0x141>
    2af9:	mov    ecx,0x2
    2afe:	cmp    r12,rbx
    2b01:	cmovge rcx,QWORD PTR [rip+0x167]        # 2c70 <botlish_fn_26+0x2a8>
    2b09:	cmp    rcx,0x6
    2b0d:	je     2c3e <botlish_fn_26+0x276>
    2b13:	lea    rcx,[rsp+0x20]
    2b18:	mov    rdx,r13
    2b1b:	mov    rsi,r12
    2b1e:	mov    rdi,r14
    2b21:	call   2b26 <botlish_fn_26+0x15e>
			2b22: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    2b26:	test   rax,rax
    2b29:	mov    rsi,rax
    2b2c:	je     2bc8 <botlish_fn_26+0x200>
    2b32:	mov    rdx,QWORD PTR [rsp+0x20]
    2b37:	mov    rcx,QWORD PTR [rsp+0x28]
    2b3c:	mov    rdi,r14
    2b3f:	mov    rax,QWORD PTR [rdi+0x10]
    2b43:	mov    r8,QWORD PTR [rax+0xc8]
    2b4a:	call   2b4f <botlish_fn_26+0x187>
			2b4b: R_X86_64_PLT32	rt_str_region_eq-0x4
    2b4f:	cmp    rax,0x6
    2b53:	je     2b66 <botlish_fn_26+0x19e>
    2b59:	mov    ecx,0x2
    2b5e:	mov    rax,rcx
    2b61:	jmp    2c4d <botlish_fn_26+0x285>
    2b66:	mov    QWORD PTR [rsp+0x18],0x3
    2b6f:	test   r12,0x1
    2b76:	jne    2b84 <botlish_fn_26+0x1bc>
    2b7c:	mov    rdi,r12
    2b7f:	jmp    2b99 <botlish_fn_26+0x1d1>
    2b84:	mov    rsi,r12
    2b87:	add    rsi,0x2
    2b8b:	mov    rdi,r12
    2b8e:	seto   al
    2b91:	test   al,al
    2b93:	je     2bac <botlish_fn_26+0x1e4>
    2b99:	mov    edx,0x3
    2b9e:	mov    rsi,rdi
    2ba1:	mov    rdi,r14
    2ba4:	call   2ba9 <botlish_fn_26+0x1e1>
			2ba5: R_X86_64_PLT32	rt_int_add-0x4
    2ba9:	mov    rsi,rax
    2bac:	mov    QWORD PTR [rsp+0x10],rsi
    2bb1:	mov    rcx,r13
    2bb4:	mov    rdx,rbx
    2bb7:	mov    rdi,r14
    2bba:	call   2bbf <botlish_fn_26+0x1f7>
			2bbb: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    2bbf:	test   rax,rax
    2bc2:	jne    2bed <botlish_fn_26+0x225>
    2bc8:	xor    rax,rax
    2bcb:	mov    rbx,QWORD PTR [rsp+0x30]
    2bd0:	mov    r12,QWORD PTR [rsp+0x38]
    2bd5:	mov    r13,QWORD PTR [rsp+0x40]
    2bda:	mov    r14,QWORD PTR [rsp+0x48]
    2bdf:	mov    r15,QWORD PTR [rsp+0x50]
    2be4:	add    rsp,0x60
    2be8:	mov    rsp,rbp
    2beb:	pop    rbp
    2bec:	ret
    2bed:	mov    rcx,rax
    2bf0:	and    rcx,rbx
    2bf3:	mov    rsi,rax
    2bf6:	test   rcx,0x1
    2bfd:	jne    2c26 <botlish_fn_26+0x25e>
    2c03:	mov    rdx,rbx
    2c06:	mov    rdi,r14
    2c09:	call   2c0e <botlish_fn_26+0x246>
			2c0a: R_X86_64_PLT32	rt_int_cmp-0x4
    2c0e:	mov    ecx,0x2
    2c13:	test   rax,rax
    2c16:	mov    rax,rcx
    2c19:	cmove  rax,QWORD PTR [rip+0x4f]        # 2c70 <botlish_fn_26+0x2a8>
    2c21:	jmp    2c4d <botlish_fn_26+0x285>
    2c26:	mov    rdx,rbx
    2c29:	mov    eax,0x2
    2c2e:	cmp    rsi,rdx
    2c31:	cmove  rax,QWORD PTR [rip+0x37]        # 2c70 <botlish_fn_26+0x2a8>
    2c39:	jmp    2c4d <botlish_fn_26+0x285>
    2c3e:	mov    eax,0x2
    2c43:	jmp    2c4d <botlish_fn_26+0x285>
    2c48:	mov    eax,0x2
    2c4d:	mov    rbx,QWORD PTR [rsp+0x30]
    2c52:	mov    r12,QWORD PTR [rsp+0x38]
    2c57:	mov    r13,QWORD PTR [rsp+0x40]
    2c5c:	mov    r14,QWORD PTR [rsp+0x48]
    2c61:	mov    r15,QWORD PTR [rsp+0x50]
    2c66:	add    rsp,0x60
    2c6a:	mov    rsp,rbp
    2c6d:	pop    rbp
    2c6e:	ret
    2c6f:	add    BYTE PTR [rsi],al
    2c71:	add    BYTE PTR [rax],al
    2c73:	add    BYTE PTR [rax],al
    2c75:	add    BYTE PTR [rax],al
	...

0000000000002c78 <botlish_entry_26: <generic>>:
    2c78:	push   rbp
    2c79:	mov    rbp,rsp
    2c7c:	mov    rsi,QWORD PTR [rdx]
    2c7f:	call   2c84 <botlish_entry_26+0xc>
			2c80: R_X86_64_PLT32	botlish_fn_26-0x4 ; <generic>
    2c84:	mov    rsp,rbp
    2c87:	pop    rbp
    2c88:	ret

0000000000002c89 <botlish_fn_27: char_at<generic>>:
    2c89:	push   rbp
    2c8a:	mov    rbp,rsp
    2c8d:	sub    rsp,0x50
    2c91:	mov    QWORD PTR [rsp+0x20],rbx
    2c96:	mov    QWORD PTR [rsp+0x28],r12
    2c9b:	mov    QWORD PTR [rsp+0x30],r13
    2ca0:	mov    QWORD PTR [rsp+0x38],r14
    2ca5:	mov    QWORD PTR [rsp+0x40],r15
    2caa:	mov    r12,rdi
    2cad:	mov    r15,rcx
    2cb0:	mov    QWORD PTR [rsp],rsi
    2cb4:	mov    QWORD PTR [rsp+0x8],rdx
    2cb9:	mov    r13,rdx
    2cbc:	mov    QWORD PTR [rsp+0x10],0x3
    2cc5:	test   rsi,0x1
    2ccc:	jne    2cda <botlish_fn_27+0x51>
    2cd2:	mov    rbx,rsi
    2cd5:	jmp    2cfa <botlish_fn_27+0x71>
    2cda:	mov    rax,rsi
    2cdd:	add    rax,0x2
    2ce1:	mov    rbx,rsi
    2ce4:	seto   cl
    2ce7:	test   cl,cl
    2ce9:	jne    2cfa <botlish_fn_27+0x71>
    2cef:	mov    rdi,r12
    2cf2:	mov    r14,rax
    2cf5:	jmp    2d10 <botlish_fn_27+0x87>
    2cfa:	mov    edx,0x3
    2cff:	mov    rsi,rbx
    2d02:	mov    rdi,r12
    2d05:	call   2d0a <botlish_fn_27+0x81>
			2d06: R_X86_64_PLT32	rt_int_add-0x4
    2d0a:	mov    r14,rax
    2d0d:	mov    rdi,r12
    2d10:	mov    rcx,r14
    2d13:	mov    rdx,rbx
    2d16:	mov    rsi,r13
    2d19:	call   2d1e <botlish_fn_27+0x95>
			2d1a: R_X86_64_PLT32	rt_str_region_check-0x4
    2d1e:	test   rax,rax
    2d21:	jne    2d4c <botlish_fn_27+0xc3>
    2d27:	xor    rax,rax
    2d2a:	mov    rbx,QWORD PTR [rsp+0x20]
    2d2f:	mov    r12,QWORD PTR [rsp+0x28]
    2d34:	mov    r13,QWORD PTR [rsp+0x30]
    2d39:	mov    r14,QWORD PTR [rsp+0x38]
    2d3e:	mov    r15,QWORD PTR [rsp+0x40]
    2d43:	add    rsp,0x50
    2d47:	mov    rsp,rbp
    2d4a:	pop    rbp
    2d4b:	ret
    2d4c:	mov    rcx,r15
    2d4f:	mov    QWORD PTR [rcx],rbx
    2d52:	mov    rax,r14
    2d55:	mov    QWORD PTR [rcx+0x8],rax
    2d59:	mov    rax,r13
    2d5c:	mov    rbx,QWORD PTR [rsp+0x20]
    2d61:	mov    r12,QWORD PTR [rsp+0x28]
    2d66:	mov    r13,QWORD PTR [rsp+0x30]
    2d6b:	mov    r14,QWORD PTR [rsp+0x38]
    2d70:	mov    r15,QWORD PTR [rsp+0x40]
    2d75:	add    rsp,0x50
    2d79:	mov    rsp,rbp
    2d7c:	pop    rbp
    2d7d:	ret

0000000000002d7e <botlish_entry_27: char_at<generic>>:
    2d7e:	push   rbp
    2d7f:	mov    rbp,rsp
    2d82:	ud2
    2d84:	add    BYTE PTR [rax],al
	...

0000000000002d88 <botlish_fn_28: scan_local<generic>>:
    2d88:	push   rbp
    2d89:	mov    rbp,rsp
    2d8c:	sub    rsp,0x80
    2d93:	mov    QWORD PTR [rsp+0x50],rbx
    2d98:	mov    QWORD PTR [rsp+0x58],r12
    2d9d:	mov    QWORD PTR [rsp+0x60],r13
    2da2:	mov    QWORD PTR [rsp+0x68],r14
    2da7:	mov    QWORD PTR [rsp+0x70],r15
    2dac:	mov    QWORD PTR [rsp+0x18],0x0
    2db5:	mov    QWORD PTR [rsp],rsi
    2db9:	mov    r15,rsi
    2dbc:	mov    QWORD PTR [rsp+0x8],rdx
    2dc1:	mov    QWORD PTR [rsp+0x10],rcx
    2dc6:	mov    r13,rcx
    2dc9:	lea    r14,[rsp+0x20]
    2dce:	mov    rbx,rdx
    2dd1:	mov    rax,rsi
    2dd4:	and    rax,rbx
    2dd7:	mov    r15,rsi
    2dda:	test   rax,0x1
    2de0:	jne    2e09 <botlish_fn_28+0x81>
    2de6:	mov    r12,rdi
    2de9:	mov    rdx,rbx
    2dec:	mov    rsi,r15
    2def:	call   2df4 <botlish_fn_28+0x6c>
			2df0: R_X86_64_PLT32	rt_int_cmp-0x4
    2df4:	mov    ecx,0x2
    2df9:	test   rax,rax
    2dfc:	cmovge rcx,QWORD PTR [rip+0x254]        # 3058 <botlish_fn_28+0x2d0>
    2e04:	jmp    2e1f <botlish_fn_28+0x97>
    2e09:	mov    r12,rdi
    2e0c:	mov    ecx,0x2
    2e11:	mov    rsi,r15
    2e14:	cmp    rsi,rbx
    2e17:	cmovge rcx,QWORD PTR [rip+0x239]        # 3058 <botlish_fn_28+0x2d0>
    2e1f:	cmp    rcx,0x6
    2e23:	je     302a <botlish_fn_28+0x2a2>
    2e29:	mov    rcx,r14
    2e2c:	mov    rdx,r13
    2e2f:	mov    rsi,r15
    2e32:	mov    rdi,r12
    2e35:	call   2e3a <botlish_fn_28+0xb2>
			2e36: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    2e3a:	mov    rcx,rax
    2e3d:	mov    QWORD PTR [rsp+0x40],rax
    2e42:	test   rax,rcx
    2e45:	je     2e75 <botlish_fn_28+0xed>
    2e4b:	mov    rdx,QWORD PTR [rsp+0x20]
    2e50:	mov    QWORD PTR [rsp+0x38],rdx
    2e55:	mov    rcx,QWORD PTR [rsp+0x28]
    2e5a:	mov    QWORD PTR [rsp+0x30],rcx
    2e5f:	mov    rsi,QWORD PTR [rsp+0x40]
    2e64:	mov    rdi,r12
    2e67:	call   2e6c <botlish_fn_28+0xe4>
			2e68: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    2e6c:	test   rax,rax
    2e6f:	jne    2e9d <botlish_fn_28+0x115>
    2e75:	xor    rax,rax
    2e78:	mov    rbx,QWORD PTR [rsp+0x50]
    2e7d:	mov    r12,QWORD PTR [rsp+0x58]
    2e82:	mov    r13,QWORD PTR [rsp+0x60]
    2e87:	mov    r14,QWORD PTR [rsp+0x68]
    2e8c:	mov    r15,QWORD PTR [rsp+0x70]
    2e91:	add    rsp,0x80
    2e98:	mov    rsp,rbp
    2e9b:	pop    rbp
    2e9c:	ret
    2e9d:	cmp    rax,0x6
    2ea1:	je     2fab <botlish_fn_28+0x223>
    2ea7:	mov    r9,QWORD PTR [r12+0x10]
    2eac:	mov    r8,QWORD PTR [r9+0xd0]
    2eb3:	mov    rcx,QWORD PTR [rsp+0x30]
    2eb8:	mov    rdx,QWORD PTR [rsp+0x38]
    2ebd:	mov    rsi,QWORD PTR [rsp+0x40]
    2ec2:	mov    rdi,r12
    2ec5:	call   2eca <botlish_fn_28+0x142>
			2ec6: R_X86_64_PLT32	rt_str_region_eq-0x4
    2eca:	cmp    rax,0x6
    2ece:	je     2fa1 <botlish_fn_28+0x219>
    2ed4:	mov    r11,QWORD PTR [r12+0x10]
    2ed9:	mov    r8,QWORD PTR [r11+0xd8]
    2ee0:	mov    rcx,QWORD PTR [rsp+0x30]
    2ee5:	mov    rdx,QWORD PTR [rsp+0x38]
    2eea:	mov    rsi,QWORD PTR [rsp+0x40]
    2eef:	mov    rdi,r12
    2ef2:	call   2ef7 <botlish_fn_28+0x16f>
			2ef3: R_X86_64_PLT32	rt_str_region_eq-0x4
    2ef7:	cmp    rax,0x6
    2efb:	je     2f97 <botlish_fn_28+0x20f>
    2f01:	mov    rax,QWORD PTR [r12+0x10]
    2f06:	mov    r8,QWORD PTR [rax+0xa8]
    2f0d:	mov    rcx,QWORD PTR [rsp+0x30]
    2f12:	mov    rdx,QWORD PTR [rsp+0x38]
    2f17:	mov    rsi,QWORD PTR [rsp+0x40]
    2f1c:	mov    rdi,r12
    2f1f:	call   2f24 <botlish_fn_28+0x19c>
			2f20: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f24:	cmp    rax,0x6
    2f28:	je     2f8d <botlish_fn_28+0x205>
    2f2e:	mov    rax,QWORD PTR [r12+0x10]
    2f33:	mov    r8,QWORD PTR [rax+0xe0]
    2f3a:	mov    rcx,QWORD PTR [rsp+0x30]
    2f3f:	mov    rdx,QWORD PTR [rsp+0x38]
    2f44:	mov    rsi,QWORD PTR [rsp+0x40]
    2f49:	mov    rdi,r12
    2f4c:	call   2f51 <botlish_fn_28+0x1c9>
			2f4d: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f51:	cmp    rax,0x6
    2f55:	je     2f83 <botlish_fn_28+0x1fb>
    2f5b:	mov    rax,QWORD PTR [r12+0x10]
    2f60:	mov    r8,QWORD PTR [rax+0xe8]
    2f67:	mov    rcx,QWORD PTR [rsp+0x30]
    2f6c:	mov    rdx,QWORD PTR [rsp+0x38]
    2f71:	mov    rsi,QWORD PTR [rsp+0x40]
    2f76:	mov    rdi,r12
    2f79:	call   2f7e <botlish_fn_28+0x1f6>
			2f7a: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f7e:	jmp    2fb0 <botlish_fn_28+0x228>
    2f83:	mov    eax,0x6
    2f88:	jmp    2fb0 <botlish_fn_28+0x228>
    2f8d:	mov    eax,0x6
    2f92:	jmp    2fb0 <botlish_fn_28+0x228>
    2f97:	mov    eax,0x6
    2f9c:	jmp    2fb0 <botlish_fn_28+0x228>
    2fa1:	mov    eax,0x6
    2fa6:	jmp    2fb0 <botlish_fn_28+0x228>
    2fab:	mov    eax,0x6
    2fb0:	cmp    rax,0x6
    2fb4:	je     2fc2 <botlish_fn_28+0x23a>
    2fba:	mov    rax,r15
    2fbd:	jmp    302d <botlish_fn_28+0x2a5>
    2fc2:	mov    QWORD PTR [rsp+0x18],0x3
    2fcb:	mov    rsi,r15
    2fce:	test   rsi,0x1
    2fd5:	je     2ffb <botlish_fn_28+0x273>
    2fdb:	mov    rsi,r15
    2fde:	mov    rax,rsi
    2fe1:	add    rax,0x2
    2fe5:	seto   cl
    2fe8:	test   cl,cl
    2fea:	jne    2ffb <botlish_fn_28+0x273>
    2ff0:	mov    rsi,rax
    2ff3:	mov    r15,rax
    2ff6:	jmp    3011 <botlish_fn_28+0x289>
    2ffb:	mov    edx,0x3
    3000:	mov    rsi,r15
    3003:	mov    rdi,r12
    3006:	call   300b <botlish_fn_28+0x283>
			3007: R_X86_64_PLT32	rt_int_add-0x4
    300b:	mov    rsi,rax
    300e:	mov    r15,rax
    3011:	mov    QWORD PTR [rsp],rsi
    3015:	mov    QWORD PTR [rsp+0x8],rbx
    301a:	mov    QWORD PTR [rsp+0x10],r13
    301f:	mov    rsi,r15
    3022:	mov    rdi,r12
    3025:	jmp    2dd1 <botlish_fn_28+0x49>
    302a:	mov    rax,r15
    302d:	mov    rbx,QWORD PTR [rsp+0x50]
    3032:	mov    r12,QWORD PTR [rsp+0x58]
    3037:	mov    r13,QWORD PTR [rsp+0x60]
    303c:	mov    r14,QWORD PTR [rsp+0x68]
    3041:	mov    r15,QWORD PTR [rsp+0x70]
    3046:	add    rsp,0x80
    304d:	mov    rsp,rbp
    3050:	pop    rbp
    3051:	ret
    3052:	add    BYTE PTR [rax],al
    3054:	add    BYTE PTR [rax],al
    3056:	add    BYTE PTR [rax],al
    3058:	(bad)
    3059:	add    BYTE PTR [rax],al
    305b:	add    BYTE PTR [rax],al
    305d:	add    BYTE PTR [rax],al
	...

0000000000003060 <botlish_entry_28: scan_local<generic>>:
    3060:	push   rbp
    3061:	mov    rbp,rsp
    3064:	mov    rsi,QWORD PTR [rdx]
    3067:	mov    r8,QWORD PTR [rdx+0x8]
    306b:	mov    rcx,QWORD PTR [rdx+0x10]
    306f:	mov    rdx,r8
    3072:	call   3077 <botlish_entry_28+0x17>
			3073: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    3077:	mov    rsp,rbp
    307a:	pop    rbp
    307b:	ret
    307c:	add    BYTE PTR [rax],al
	...

0000000000003080 <botlish_fn_29: scan_label<generic>>:
    3080:	push   rbp
    3081:	mov    rbp,rsp
    3084:	sub    rsp,0x80
    308b:	mov    QWORD PTR [rsp+0x50],rbx
    3090:	mov    QWORD PTR [rsp+0x58],r12
    3095:	mov    QWORD PTR [rsp+0x60],r13
    309a:	mov    QWORD PTR [rsp+0x68],r14
    309f:	mov    QWORD PTR [rsp+0x70],r15
    30a4:	mov    QWORD PTR [rsp+0x18],0x0
    30ad:	mov    QWORD PTR [rsp],rsi
    30b1:	mov    r15,rsi
    30b4:	mov    QWORD PTR [rsp+0x8],rdx
    30b9:	mov    QWORD PTR [rsp+0x10],rcx
    30be:	mov    r13,rcx
    30c1:	lea    r14,[rsp+0x20]
    30c6:	mov    rbx,rdx
    30c9:	mov    rax,rsi
    30cc:	and    rax,rbx
    30cf:	mov    r15,rsi
    30d2:	test   rax,0x1
    30d8:	jne    3101 <botlish_fn_29+0x81>
    30de:	mov    r12,rdi
    30e1:	mov    rdx,rbx
    30e4:	mov    rsi,r15
    30e7:	call   30ec <botlish_fn_29+0x6c>
			30e8: R_X86_64_PLT32	rt_int_cmp-0x4
    30ec:	mov    ecx,0x2
    30f1:	test   rax,rax
    30f4:	cmovge rcx,QWORD PTR [rip+0x174]        # 3270 <botlish_fn_29+0x1f0>
    30fc:	jmp    3117 <botlish_fn_29+0x97>
    3101:	mov    r12,rdi
    3104:	mov    ecx,0x2
    3109:	mov    rsi,r15
    310c:	cmp    rsi,rbx
    310f:	cmovge rcx,QWORD PTR [rip+0x159]        # 3270 <botlish_fn_29+0x1f0>
    3117:	cmp    rcx,0x6
    311b:	je     3243 <botlish_fn_29+0x1c3>
    3121:	mov    rcx,r14
    3124:	mov    rdx,r13
    3127:	mov    rsi,r15
    312a:	mov    rdi,r12
    312d:	call   3132 <botlish_fn_29+0xb2>
			312e: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    3132:	test   rax,rax
    3135:	mov    QWORD PTR [rsp+0x40],rax
    313a:	je     316a <botlish_fn_29+0xea>
    3140:	mov    rdx,QWORD PTR [rsp+0x20]
    3145:	mov    QWORD PTR [rsp+0x38],rdx
    314a:	mov    rcx,QWORD PTR [rsp+0x28]
    314f:	mov    QWORD PTR [rsp+0x30],rcx
    3154:	mov    rsi,QWORD PTR [rsp+0x40]
    3159:	mov    rdi,r12
    315c:	call   3161 <botlish_fn_29+0xe1>
			315d: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    3161:	test   rax,rax
    3164:	jne    3192 <botlish_fn_29+0x112>
    316a:	xor    rax,rax
    316d:	mov    rbx,QWORD PTR [rsp+0x50]
    3172:	mov    r12,QWORD PTR [rsp+0x58]
    3177:	mov    r13,QWORD PTR [rsp+0x60]
    317c:	mov    r14,QWORD PTR [rsp+0x68]
    3181:	mov    r15,QWORD PTR [rsp+0x70]
    3186:	add    rsp,0x80
    318d:	mov    rsp,rbp
    3190:	pop    rbp
    3191:	ret
    3192:	cmp    rax,0x6
    3196:	je     31c4 <botlish_fn_29+0x144>
    319c:	mov    rax,QWORD PTR [r12+0x10]
    31a1:	mov    r8,QWORD PTR [rax+0xe8]
    31a8:	mov    rcx,QWORD PTR [rsp+0x30]
    31ad:	mov    rdx,QWORD PTR [rsp+0x38]
    31b2:	mov    rsi,QWORD PTR [rsp+0x40]
    31b7:	mov    rdi,r12
    31ba:	call   31bf <botlish_fn_29+0x13f>
			31bb: R_X86_64_PLT32	rt_str_region_eq-0x4
    31bf:	jmp    31c9 <botlish_fn_29+0x149>
    31c4:	mov    eax,0x6
    31c9:	cmp    rax,0x6
    31cd:	je     31db <botlish_fn_29+0x15b>
    31d3:	mov    rax,r15
    31d6:	jmp    3246 <botlish_fn_29+0x1c6>
    31db:	mov    QWORD PTR [rsp+0x18],0x3
    31e4:	mov    rsi,r15
    31e7:	test   rsi,0x1
    31ee:	je     3214 <botlish_fn_29+0x194>
    31f4:	mov    rsi,r15
    31f7:	mov    rax,rsi
    31fa:	add    rax,0x2
    31fe:	seto   cl
    3201:	test   cl,cl
    3203:	jne    3214 <botlish_fn_29+0x194>
    3209:	mov    rsi,rax
    320c:	mov    r15,rax
    320f:	jmp    322a <botlish_fn_29+0x1aa>
    3214:	mov    edx,0x3
    3219:	mov    rsi,r15
    321c:	mov    rdi,r12
    321f:	call   3224 <botlish_fn_29+0x1a4>
			3220: R_X86_64_PLT32	rt_int_add-0x4
    3224:	mov    rsi,rax
    3227:	mov    r15,rax
    322a:	mov    QWORD PTR [rsp],rsi
    322e:	mov    QWORD PTR [rsp+0x8],rbx
    3233:	mov    QWORD PTR [rsp+0x10],r13
    3238:	mov    rsi,r15
    323b:	mov    rdi,r12
    323e:	jmp    30c9 <botlish_fn_29+0x49>
    3243:	mov    rax,r15
    3246:	mov    rbx,QWORD PTR [rsp+0x50]
    324b:	mov    r12,QWORD PTR [rsp+0x58]
    3250:	mov    r13,QWORD PTR [rsp+0x60]
    3255:	mov    r14,QWORD PTR [rsp+0x68]
    325a:	mov    r15,QWORD PTR [rsp+0x70]
    325f:	add    rsp,0x80
    3266:	mov    rsp,rbp
    3269:	pop    rbp
    326a:	ret
    326b:	add    BYTE PTR [rax],al
    326d:	add    BYTE PTR [rax],al
    326f:	add    BYTE PTR [rsi],al
    3271:	add    BYTE PTR [rax],al
    3273:	add    BYTE PTR [rax],al
    3275:	add    BYTE PTR [rax],al
	...

0000000000003278 <botlish_entry_29: scan_label<generic>>:
    3278:	push   rbp
    3279:	mov    rbp,rsp
    327c:	mov    rsi,QWORD PTR [rdx]
    327f:	mov    r8,QWORD PTR [rdx+0x8]
    3283:	mov    rcx,QWORD PTR [rdx+0x10]
    3287:	mov    rdx,r8
    328a:	call   328f <botlish_entry_29+0x17>
			328b: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_label<generic>
    328f:	mov    rsp,rbp
    3292:	pop    rbp
    3293:	ret
    3294:	add    BYTE PTR [rax],al
	...

0000000000003298 <botlish_fn_30: scan_alpha<generic>>:
    3298:	push   rbp
    3299:	mov    rbp,rsp
    329c:	sub    rsp,0x60
    32a0:	mov    QWORD PTR [rsp+0x30],rbx
    32a5:	mov    QWORD PTR [rsp+0x38],r12
    32aa:	mov    QWORD PTR [rsp+0x40],r13
    32af:	mov    QWORD PTR [rsp+0x48],r14
    32b4:	mov    QWORD PTR [rsp+0x50],r15
    32b9:	mov    r15,rdi
    32bc:	mov    QWORD PTR [rsp+0x18],0x0
    32c5:	mov    QWORD PTR [rsp],rsi
    32c9:	mov    r14,rsi
    32cc:	mov    QWORD PTR [rsp+0x8],rdx
    32d1:	mov    QWORD PTR [rsp+0x10],rcx
    32d6:	mov    r12,rcx
    32d9:	lea    r13,[rsp+0x20]
    32de:	mov    rbx,rdx
    32e1:	mov    rax,rsi
    32e4:	and    rax,rbx
    32e7:	mov    r14,rsi
    32ea:	test   rax,0x1
    32f0:	jne    3319 <botlish_fn_30+0x81>
    32f6:	mov    rdx,rbx
    32f9:	mov    rsi,r14
    32fc:	mov    rdi,r15
    32ff:	call   3304 <botlish_fn_30+0x6c>
			3300: R_X86_64_PLT32	rt_int_cmp-0x4
    3304:	mov    ecx,0x2
    3309:	test   rax,rax
    330c:	cmovge rcx,QWORD PTR [rip+0x11c]        # 3430 <botlish_fn_30+0x198>
    3314:	jmp    332c <botlish_fn_30+0x94>
    3319:	mov    ecx,0x2
    331e:	mov    rsi,r14
    3321:	cmp    rsi,rbx
    3324:	cmovge rcx,QWORD PTR [rip+0x104]        # 3430 <botlish_fn_30+0x198>
    332c:	cmp    rcx,0x6
    3330:	je     340a <botlish_fn_30+0x172>
    3336:	mov    rcx,r13
    3339:	mov    rdx,r12
    333c:	mov    rsi,r14
    333f:	mov    rdi,r15
    3342:	call   3347 <botlish_fn_30+0xaf>
			3343: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    3347:	test   rax,rax
    334a:	mov    rsi,rax
    334d:	je     336e <botlish_fn_30+0xd6>
    3353:	mov    rdx,QWORD PTR [rsp+0x20]
    3358:	mov    rcx,QWORD PTR [rsp+0x28]
    335d:	mov    rdi,r15
    3360:	call   3365 <botlish_fn_30+0xcd>
			3361: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    3365:	test   rax,rax
    3368:	jne    3393 <botlish_fn_30+0xfb>
    336e:	xor    rax,rax
    3371:	mov    rbx,QWORD PTR [rsp+0x30]
    3376:	mov    r12,QWORD PTR [rsp+0x38]
    337b:	mov    r13,QWORD PTR [rsp+0x40]
    3380:	mov    r14,QWORD PTR [rsp+0x48]
    3385:	mov    r15,QWORD PTR [rsp+0x50]
    338a:	add    rsp,0x60
    338e:	mov    rsp,rbp
    3391:	pop    rbp
    3392:	ret
    3393:	cmp    rax,0x6
    3397:	je     33a5 <botlish_fn_30+0x10d>
    339d:	mov    rax,r14
    33a0:	jmp    340d <botlish_fn_30+0x175>
    33a5:	mov    QWORD PTR [rsp+0x18],0x3
    33ae:	mov    rsi,r14
    33b1:	test   rsi,0x1
    33b8:	je     33de <botlish_fn_30+0x146>
    33be:	mov    rsi,r14
    33c1:	mov    rcx,rsi
    33c4:	add    rcx,0x2
    33c8:	seto   al
    33cb:	test   al,al
    33cd:	jne    33de <botlish_fn_30+0x146>
    33d3:	mov    rsi,rcx
    33d6:	mov    r14,rcx
    33d9:	jmp    33f4 <botlish_fn_30+0x15c>
    33de:	mov    edx,0x3
    33e3:	mov    rsi,r14
    33e6:	mov    rdi,r15
    33e9:	call   33ee <botlish_fn_30+0x156>
			33ea: R_X86_64_PLT32	rt_int_add-0x4
    33ee:	mov    rsi,rax
    33f1:	mov    r14,rax
    33f4:	mov    QWORD PTR [rsp],rsi
    33f8:	mov    QWORD PTR [rsp+0x8],rbx
    33fd:	mov    QWORD PTR [rsp+0x10],r12
    3402:	mov    rsi,r14
    3405:	jmp    32e1 <botlish_fn_30+0x49>
    340a:	mov    rax,r14
    340d:	mov    rbx,QWORD PTR [rsp+0x30]
    3412:	mov    r12,QWORD PTR [rsp+0x38]
    3417:	mov    r13,QWORD PTR [rsp+0x40]
    341c:	mov    r14,QWORD PTR [rsp+0x48]
    3421:	mov    r15,QWORD PTR [rsp+0x50]
    3426:	add    rsp,0x60
    342a:	mov    rsp,rbp
    342d:	pop    rbp
    342e:	ret
    342f:	add    BYTE PTR [rsi],al
    3431:	add    BYTE PTR [rax],al
    3433:	add    BYTE PTR [rax],al
    3435:	add    BYTE PTR [rax],al
	...

0000000000003438 <botlish_entry_30: scan_alpha<generic>>:
    3438:	push   rbp
    3439:	mov    rbp,rsp
    343c:	mov    rsi,QWORD PTR [rdx]
    343f:	mov    r8,QWORD PTR [rdx+0x8]
    3443:	mov    rcx,QWORD PTR [rdx+0x10]
    3447:	mov    rdx,r8
    344a:	call   344f <botlish_entry_30+0x17>
			344b: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_alpha<generic>
    344f:	mov    rsp,rbp
    3452:	pop    rbp
    3453:	ret
    3454:	add    BYTE PTR [rax],al
	...

0000000000003458 <botlish_fn_31: tld_ok<generic>>:
    3458:	push   rbp
    3459:	mov    rbp,rsp
    345c:	sub    rsp,0x40
    3460:	mov    QWORD PTR [rsp+0x20],rbx
    3465:	mov    QWORD PTR [rsp+0x28],r12
    346a:	mov    QWORD PTR [rsp+0x30],r13
    346f:	mov    QWORD PTR [rsp+0x38],r14
    3474:	mov    r12,rdi
    3477:	mov    QWORD PTR [rsp],rsi
    347b:	mov    rdi,rsi
    347e:	mov    QWORD PTR [rsp+0x8],rdx
    3483:	mov    r14,rdx
    3486:	mov    QWORD PTR [rsp+0x10],rcx
    348b:	mov    rbx,rdi
    348e:	mov    rdx,r14
    3491:	mov    rsi,rbx
    3494:	mov    rdi,r12
    3497:	call   349c <botlish_fn_31+0x44>
			3498: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_alpha<generic>
    349c:	mov    rcx,rax
    349f:	mov    r13,rax
    34a2:	test   rax,rcx
    34a5:	jne    34cb <botlish_fn_31+0x73>
    34ab:	xor    rax,rax
    34ae:	mov    rbx,QWORD PTR [rsp+0x20]
    34b3:	mov    r12,QWORD PTR [rsp+0x28]
    34b8:	mov    r13,QWORD PTR [rsp+0x30]
    34bd:	mov    r14,QWORD PTR [rsp+0x38]
    34c2:	add    rsp,0x40
    34c6:	mov    rsp,rbp
    34c9:	pop    rbp
    34ca:	ret
    34cb:	mov    rax,r13
    34ce:	mov    QWORD PTR [rsp+0x8],rax
    34d3:	mov    rdx,r14
    34d6:	and    rax,rdx
    34d9:	test   rax,0x1
    34df:	jne    3508 <botlish_fn_31+0xb0>
    34e5:	mov    rsi,r13
    34e8:	mov    rdi,r12
    34eb:	call   34f0 <botlish_fn_31+0x98>
			34ec: R_X86_64_PLT32	rt_int_cmp-0x4
    34f0:	mov    ecx,0x2
    34f5:	test   rax,rax
    34f8:	cmove  rcx,QWORD PTR [rip+0xe0]        # 35e0 <botlish_fn_31+0x188>
    3500:	mov    rax,r13
    3503:	jmp    351b <botlish_fn_31+0xc3>
    3508:	mov    ecx,0x2
    350d:	mov    rax,r13
    3510:	cmp    rax,rdx
    3513:	cmove  rcx,QWORD PTR [rip+0xc5]        # 35e0 <botlish_fn_31+0x188>
    351b:	cmp    rcx,0x6
    351f:	je     3532 <botlish_fn_31+0xda>
    3525:	mov    ecx,0x2
    352a:	mov    rax,rcx
    352d:	jmp    35bf <botlish_fn_31+0x167>
    3532:	mov    rcx,rax
    3535:	and    rcx,rbx
    3538:	test   rcx,0x1
    353f:	jne    3550 <botlish_fn_31+0xf8>
    3545:	mov    rdx,rbx
    3548:	mov    rsi,rax
    354b:	jmp    3571 <botlish_fn_31+0x119>
    3550:	mov    rcx,rax
    3553:	sub    rcx,rbx
    3556:	mov    rdi,rbx
    3559:	mov    r13,rax
    355c:	seto   al
    355f:	lea    rsi,[rcx+0x1]
    3563:	test   al,al
    3565:	je     357c <botlish_fn_31+0x124>
    356b:	mov    rdx,rdi
    356e:	mov    rsi,r13
    3571:	mov    rdi,r12
    3574:	call   3579 <botlish_fn_31+0x121>
			3575: R_X86_64_PLT32	rt_int_sub-0x4
    3579:	mov    rsi,rax
    357c:	test   rsi,0x1
    3583:	jne    35ae <botlish_fn_31+0x156>
    3589:	mov    edx,0x5
    358e:	mov    rdi,r12
    3591:	call   3596 <botlish_fn_31+0x13e>
			3592: R_X86_64_PLT32	rt_int_cmp-0x4
    3596:	mov    ecx,0x2
    359b:	test   rax,rax
    359e:	mov    rax,rcx
    35a1:	cmovge rax,QWORD PTR [rip+0x37]        # 35e0 <botlish_fn_31+0x188>
    35a9:	jmp    35bf <botlish_fn_31+0x167>
    35ae:	mov    eax,0x2
    35b3:	cmp    rsi,0x5
    35b7:	cmovge rax,QWORD PTR [rip+0x21]        # 35e0 <botlish_fn_31+0x188>
    35bf:	mov    rbx,QWORD PTR [rsp+0x20]
    35c4:	mov    r12,QWORD PTR [rsp+0x28]
    35c9:	mov    r13,QWORD PTR [rsp+0x30]
    35ce:	mov    r14,QWORD PTR [rsp+0x38]
    35d3:	add    rsp,0x40
    35d7:	mov    rsp,rbp
    35da:	pop    rbp
    35db:	ret
    35dc:	add    BYTE PTR [rax],al
    35de:	add    BYTE PTR [rax],al
    35e0:	(bad)
    35e1:	add    BYTE PTR [rax],al
    35e3:	add    BYTE PTR [rax],al
    35e5:	add    BYTE PTR [rax],al
	...

00000000000035e8 <botlish_entry_31: tld_ok<generic>>:
    35e8:	push   rbp
    35e9:	mov    rbp,rsp
    35ec:	mov    rsi,QWORD PTR [rdx]
    35ef:	mov    r8,QWORD PTR [rdx+0x8]
    35f3:	mov    rcx,QWORD PTR [rdx+0x10]
    35f7:	mov    rdx,r8
    35fa:	call   35ff <botlish_entry_31+0x17>
			35fb: R_X86_64_PLT32	botlish_fn_31-0x4 ; tld_ok<generic>
    35ff:	mov    rsp,rbp
    3602:	pop    rbp
    3603:	ret
    3604:	add    BYTE PTR [rax],al
	...

0000000000003608 <botlish_fn_32: domain_loop<generic>>:
    3608:	push   rbp
    3609:	mov    rbp,rsp
    360c:	sub    rsp,0x70
    3610:	mov    QWORD PTR [rsp+0x40],rbx
    3615:	mov    QWORD PTR [rsp+0x48],r12
    361a:	mov    QWORD PTR [rsp+0x50],r13
    361f:	mov    QWORD PTR [rsp+0x58],r14
    3624:	mov    QWORD PTR [rsp+0x60],r15
    3629:	mov    QWORD PTR [rsp+0x18],0x0
    3632:	mov    QWORD PTR [rsp],rsi
    3636:	mov    QWORD PTR [rsp+0x8],rdx
    363b:	mov    QWORD PTR [rsp+0x10],rcx
    3640:	lea    rbx,[rsp+0x20]
    3645:	mov    r12,rdi
    3648:	mov    r13,rcx
    364b:	mov    r14,rdx
    364e:	mov    QWORD PTR [rsp+0x30],rsi
    3653:	mov    rcx,r13
    3656:	mov    rdx,r14
    3659:	mov    rsi,QWORD PTR [rsp+0x30]
    365e:	mov    rdi,r12
    3661:	call   3666 <botlish_fn_32+0x5e>
			3662: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_label<generic>
    3666:	mov    rcx,rax
    3669:	mov    r15,rax
    366c:	test   rax,rcx
    366f:	je     37c6 <botlish_fn_32+0x1be>
    3675:	mov    rax,r15
    3678:	mov    QWORD PTR [rsp],rax
    367c:	mov    rdx,QWORD PTR [rsp+0x30]
    3681:	and    rax,rdx
    3684:	test   rax,0x1
    368a:	jne    36b0 <botlish_fn_32+0xa8>
    3690:	mov    rsi,r15
    3693:	mov    rdi,r12
    3696:	call   369b <botlish_fn_32+0x93>
			3697: R_X86_64_PLT32	rt_int_cmp-0x4
    369b:	mov    ecx,0x2
    36a0:	test   rax,rax
    36a3:	cmove  rcx,QWORD PTR [rip+0x19d]        # 3848 <botlish_fn_32+0x240>
    36ab:	jmp    36c0 <botlish_fn_32+0xb8>
    36b0:	mov    ecx,0x2
    36b5:	cmp    r15,rdx
    36b8:	cmove  rcx,QWORD PTR [rip+0x188]        # 3848 <botlish_fn_32+0x240>
    36c0:	cmp    rcx,0x6
    36c4:	je     381c <botlish_fn_32+0x214>
    36ca:	mov    rax,r15
    36cd:	and    rax,r14
    36d0:	test   rax,0x1
    36d6:	jne    36ff <botlish_fn_32+0xf7>
    36dc:	mov    rdx,r14
    36df:	mov    rsi,r15
    36e2:	mov    rdi,r12
    36e5:	call   36ea <botlish_fn_32+0xe2>
			36e6: R_X86_64_PLT32	rt_int_cmp-0x4
    36ea:	mov    ecx,0x2
    36ef:	test   rax,rax
    36f2:	cmovge rcx,QWORD PTR [rip+0x14e]        # 3848 <botlish_fn_32+0x240>
    36fa:	jmp    370f <botlish_fn_32+0x107>
    36ff:	mov    ecx,0x2
    3704:	cmp    r15,r14
    3707:	cmovge rcx,QWORD PTR [rip+0x139]        # 3848 <botlish_fn_32+0x240>
    370f:	cmp    rcx,0x6
    3713:	je     380d <botlish_fn_32+0x205>
    3719:	mov    rcx,rbx
    371c:	mov    rdx,r13
    371f:	mov    rsi,r15
    3722:	mov    rdi,r12
    3725:	call   372a <botlish_fn_32+0x122>
			3726: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    372a:	test   rax,rax
    372d:	je     37c6 <botlish_fn_32+0x1be>
    3733:	mov    rdx,QWORD PTR [rsp+0x20]
    3738:	mov    rcx,QWORD PTR [rsp+0x28]
    373d:	mov    rsi,QWORD PTR [r12+0x10]
    3742:	mov    r8,QWORD PTR [rsi+0xd0]
    3749:	mov    rsi,rax
    374c:	mov    rdi,r12
    374f:	call   3754 <botlish_fn_32+0x14c>
			3750: R_X86_64_PLT32	rt_str_region_eq-0x4
    3754:	cmp    rax,0x6
    3758:	je     376a <botlish_fn_32+0x162>
    375e:	mov    r14,0xffffffffffffffff
    3765:	jmp    3814 <botlish_fn_32+0x20c>
    376a:	mov    QWORD PTR [rsp+0x18],0x3
    3773:	test   r15,0x1
    377a:	je     3792 <botlish_fn_32+0x18a>
    3780:	mov    rdx,r15
    3783:	add    rdx,0x2
    3787:	seto   al
    378a:	test   al,al
    378c:	je     37a5 <botlish_fn_32+0x19d>
    3792:	mov    edx,0x3
    3797:	mov    rsi,r15
    379a:	mov    rdi,r12
    379d:	call   37a2 <botlish_fn_32+0x19a>
			379e: R_X86_64_PLT32	rt_int_add-0x4
    37a2:	mov    rdx,rax
    37a5:	mov    QWORD PTR [rsp],rdx
    37a9:	mov    r15,rdx
    37ac:	mov    rcx,r13
    37af:	mov    rdx,r14
    37b2:	mov    rsi,r15
    37b5:	mov    rdi,r12
    37b8:	call   37bd <botlish_fn_32+0x1b5>
			37b9: R_X86_64_PLT32	botlish_fn_31-0x4 ; tld_ok<generic>
    37bd:	test   rax,rax
    37c0:	jne    37eb <botlish_fn_32+0x1e3>
    37c6:	xor    rax,rax
    37c9:	mov    rbx,QWORD PTR [rsp+0x40]
    37ce:	mov    r12,QWORD PTR [rsp+0x48]
    37d3:	mov    r13,QWORD PTR [rsp+0x50]
    37d8:	mov    r14,QWORD PTR [rsp+0x58]
    37dd:	mov    r15,QWORD PTR [rsp+0x60]
    37e2:	add    rsp,0x70
    37e6:	mov    rsp,rbp
    37e9:	pop    rbp
    37ea:	ret
    37eb:	cmp    rax,0x6
    37ef:	je     3814 <botlish_fn_32+0x20c>
    37f5:	mov    QWORD PTR [rsp],r15
    37f9:	mov    QWORD PTR [rsp+0x8],r14
    37fe:	mov    QWORD PTR [rsp+0x10],r13
    3803:	mov    QWORD PTR [rsp+0x30],r15
    3808:	jmp    3653 <botlish_fn_32+0x4b>
    380d:	mov    r14,0xffffffffffffffff
    3814:	mov    rax,r14
    3817:	jmp    3823 <botlish_fn_32+0x21b>
    381c:	mov    rax,0xffffffffffffffff
    3823:	mov    rbx,QWORD PTR [rsp+0x40]
    3828:	mov    r12,QWORD PTR [rsp+0x48]
    382d:	mov    r13,QWORD PTR [rsp+0x50]
    3832:	mov    r14,QWORD PTR [rsp+0x58]
    3837:	mov    r15,QWORD PTR [rsp+0x60]
    383c:	add    rsp,0x70
    3840:	mov    rsp,rbp
    3843:	pop    rbp
    3844:	ret
    3845:	add    BYTE PTR [rax],al
    3847:	add    BYTE PTR [rsi],al
    3849:	add    BYTE PTR [rax],al
    384b:	add    BYTE PTR [rax],al
    384d:	add    BYTE PTR [rax],al
	...

0000000000003850 <botlish_entry_32: domain_loop<generic>>:
    3850:	push   rbp
    3851:	mov    rbp,rsp
    3854:	mov    rsi,QWORD PTR [rdx]
    3857:	mov    r8,QWORD PTR [rdx+0x8]
    385b:	mov    rcx,QWORD PTR [rdx+0x10]
    385f:	mov    rdx,r8
    3862:	call   3867 <botlish_entry_32+0x17>
			3863: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    3867:	mov    rsp,rbp
    386a:	pop    rbp
    386b:	ret

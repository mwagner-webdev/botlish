; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 15289  (per function: 1172 39 289 617 74 74 74 125 125 155 125 103 453 758 486 828 504 681 769 262 804 564 468 452 644 681 769 262 804 564 468 452 644)
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
    1494:	add    BYTE PTR [rax],al
	...

0000000000001498 <botlish_fn_16: check<int, int, str, str>>:
    1498:	push   rbp
    1499:	mov    rbp,rsp
    149c:	sub    rsp,0x60
    14a0:	mov    QWORD PTR [rsp+0x30],rbx
    14a5:	mov    QWORD PTR [rsp+0x38],r12
    14aa:	mov    QWORD PTR [rsp+0x40],r13
    14af:	mov    QWORD PTR [rsp+0x48],r14
    14b4:	mov    QWORD PTR [rsp+0x50],r15
    14b9:	mov    QWORD PTR [rsp+0x20],0x0
    14c2:	mov    QWORD PTR [rsp],rsi
    14c6:	mov    QWORD PTR [rsp+0x8],rdx
    14cb:	mov    QWORD PTR [rsp+0x10],rcx
    14d0:	mov    r12,rcx
    14d3:	mov    QWORD PTR [rsp+0x18],r8
    14d8:	mov    r14,r8
    14db:	mov    r13,rsi
    14de:	mov    r15,rdx
    14e1:	test   r13,0x1
    14e8:	jne    1513 <botlish_fn_16+0x7b>
    14ee:	mov    edx,0x1
    14f3:	mov    rbx,rdi
    14f6:	mov    rsi,r13
    14f9:	call   14fe <botlish_fn_16+0x66>
			14fa: R_X86_64_PLT32	rt_int_cmp-0x4
    14fe:	mov    ecx,0x2
    1503:	test   rax,rax
    1506:	cmovle rcx,QWORD PTR [rip+0x152]        # 1660 <botlish_fn_16+0x1c8>
    150e:	jmp    1527 <botlish_fn_16+0x8f>
    1513:	mov    rbx,rdi
    1516:	mov    ecx,0x2
    151b:	cmp    r13,0x1
    151f:	cmovle rcx,QWORD PTR [rip+0x139]        # 1660 <botlish_fn_16+0x1c8>
    1527:	cmp    rcx,0x6
    152b:	je     1636 <botlish_fn_16+0x19e>
    1531:	mov    rax,QWORD PTR [rbx+0x10]
    1535:	mov    rax,QWORD PTR [rax+0xb8]
    153c:	mov    rsi,r12
    153f:	mov    rdi,rbx
    1542:	call   1547 <botlish_fn_16+0xaf>
			1543: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    1547:	test   rax,rax
    154a:	je     158b <botlish_fn_16+0xf3>
    1550:	cmp    rax,0x6
    1554:	je     156c <botlish_fn_16+0xd4>
    155a:	mov    edx,0x1
    155f:	mov    QWORD PTR [rsp],0x1
    1567:	jmp    15cd <botlish_fn_16+0x135>
    156c:	mov    rax,QWORD PTR [rbx+0x10]
    1570:	mov    rax,QWORD PTR [rax+0xc0]
    1577:	mov    rsi,r12
    157a:	mov    rdi,rbx
    157d:	call   1582 <botlish_fn_16+0xea>
			157e: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    1582:	test   rax,rax
    1585:	jne    15b0 <botlish_fn_16+0x118>
    158b:	xor    rax,rax
    158e:	mov    rbx,QWORD PTR [rsp+0x30]
    1593:	mov    r12,QWORD PTR [rsp+0x38]
    1598:	mov    r13,QWORD PTR [rsp+0x40]
    159d:	mov    r14,QWORD PTR [rsp+0x48]
    15a2:	mov    r15,QWORD PTR [rsp+0x50]
    15a7:	add    rsp,0x60
    15ab:	mov    rsp,rbp
    15ae:	pop    rbp
    15af:	ret
    15b0:	cmp    rax,0x6
    15b4:	je     15c4 <botlish_fn_16+0x12c>
    15ba:	mov    edx,0x1
    15bf:	jmp    15c9 <botlish_fn_16+0x131>
    15c4:	mov    edx,0x3
    15c9:	mov    QWORD PTR [rsp],rdx
    15cd:	sar    r13,1
    15d0:	sub    r13,0x1
    15d4:	shl    r13,1
    15d7:	or     r13,0x1
    15db:	mov    QWORD PTR [rsp+0x20],r13
    15e0:	mov    rsi,r15
    15e3:	mov    rdi,rsi
    15e6:	and    rdi,rdx
    15e9:	test   rdi,0x1
    15f0:	je     160d <botlish_fn_16+0x175>
    15f6:	lea    r9,[rdx-0x1]
    15fa:	mov    rax,rsi
    15fd:	add    rax,r9
    1600:	seto   r10b
    1604:	test   r10b,r10b
    1607:	je     1615 <botlish_fn_16+0x17d>
    160d:	mov    rdi,rbx
    1610:	call   1615 <botlish_fn_16+0x17d>
			1611: R_X86_64_PLT32	rt_int_add-0x4
    1615:	mov    QWORD PTR [rsp],r13
    1619:	mov    QWORD PTR [rsp+0x8],rax
    161e:	mov    QWORD PTR [rsp+0x10],r12
    1623:	mov    r8,r14
    1626:	mov    QWORD PTR [rsp+0x18],r8
    162b:	mov    rdi,rbx
    162e:	mov    r15,rax
    1631:	jmp    14e1 <botlish_fn_16+0x49>
    1636:	mov    rax,r15
    1639:	mov    rbx,QWORD PTR [rsp+0x30]
    163e:	mov    r12,QWORD PTR [rsp+0x38]
    1643:	mov    r13,QWORD PTR [rsp+0x40]
    1648:	mov    r14,QWORD PTR [rsp+0x48]
    164d:	mov    r15,QWORD PTR [rsp+0x50]
    1652:	add    rsp,0x60
    1656:	mov    rsp,rbp
    1659:	pop    rbp
    165a:	ret
    165b:	add    BYTE PTR [rax],al
    165d:	add    BYTE PTR [rax],al
    165f:	add    BYTE PTR [rsi],al
    1661:	add    BYTE PTR [rax],al
    1663:	add    BYTE PTR [rax],al
    1665:	add    BYTE PTR [rax],al
	...

0000000000001668 <botlish_entry_16: check<int, int, str, str>>:
    1668:	push   rbp
    1669:	mov    rbp,rsp
    166c:	mov    rsi,QWORD PTR [rdx]
    166f:	mov    r9,QWORD PTR [rdx+0x8]
    1673:	mov    rcx,QWORD PTR [rdx+0x10]
    1677:	mov    r8,QWORD PTR [rdx+0x18]
    167b:	mov    rdx,r9
    167e:	call   1683 <botlish_entry_16+0x1b>
			167f: R_X86_64_PLT32	botlish_fn_16-0x4 ; check<int, int, str, str>
    1683:	mov    rsp,rbp
    1686:	pop    rbp
    1687:	ret

0000000000001688 <botlish_fn_17: <str>>:
    1688:	push   rbp
    1689:	mov    rbp,rsp
    168c:	sub    rsp,0x50
    1690:	mov    QWORD PTR [rsp+0x30],rbx
    1695:	mov    QWORD PTR [rsp+0x38],r12
    169a:	mov    QWORD PTR [rsp+0x40],r13
    169f:	mov    QWORD PTR [rsp+0x48],r14
    16a4:	mov    r13,rdi
    16a7:	mov    QWORD PTR [rsp+0x18],0x0
    16b0:	mov    QWORD PTR [rsp],rsi
    16b4:	mov    r14,rsi
    16b7:	mov    rsi,r14
    16ba:	mov    rdi,r13
    16bd:	call   16c2 <botlish_fn_17+0x3a>
			16be: R_X86_64_PLT32	rt_str_len-0x4
    16c2:	mov    rbx,rax
    16c5:	mov    QWORD PTR [rsp+0x8],rax
    16ca:	mov    esi,0x1
    16cf:	mov    QWORD PTR [rsp+0x10],0x1
    16d8:	mov    rcx,r14
    16db:	mov    rdx,rbx
    16de:	mov    rdi,r13
    16e1:	call   16e6 <botlish_fn_17+0x5e>
			16e2: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    16e6:	mov    r12,rax
    16e9:	test   r12,r12
    16ec:	je     1849 <botlish_fn_17+0x1c1>
    16f2:	mov    QWORD PTR [rsp+0x10],r12
    16f7:	test   r12,0x1
    16fe:	jne    1729 <botlish_fn_17+0xa1>
    1704:	mov    edx,0x1
    1709:	mov    rsi,r12
    170c:	mov    rdi,r13
    170f:	call   1714 <botlish_fn_17+0x8c>
			1710: R_X86_64_PLT32	rt_int_cmp-0x4
    1714:	mov    ecx,0x2
    1719:	test   rax,rax
    171c:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 18e8 <botlish_fn_17+0x260>
    1724:	jmp    173a <botlish_fn_17+0xb2>
    1729:	mov    ecx,0x2
    172e:	cmp    r12,0x1
    1732:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 18e8 <botlish_fn_17+0x260>
    173a:	cmp    rcx,0x6
    173e:	je     18c4 <botlish_fn_17+0x23c>
    1744:	mov    rcx,r12
    1747:	and    rcx,rbx
    174a:	test   rcx,0x1
    1751:	jne    177a <botlish_fn_17+0xf2>
    1757:	mov    rdx,rbx
    175a:	mov    rsi,r12
    175d:	mov    rdi,r13
    1760:	call   1765 <botlish_fn_17+0xdd>
			1761: R_X86_64_PLT32	rt_int_cmp-0x4
    1765:	mov    ecx,0x2
    176a:	test   rax,rax
    176d:	cmovge rcx,QWORD PTR [rip+0x173]        # 18e8 <botlish_fn_17+0x260>
    1775:	jmp    178a <botlish_fn_17+0x102>
    177a:	mov    ecx,0x2
    177f:	cmp    r12,rbx
    1782:	cmovge rcx,QWORD PTR [rip+0x15e]        # 18e8 <botlish_fn_17+0x260>
    178a:	cmp    rcx,0x6
    178e:	je     18ba <botlish_fn_17+0x232>
    1794:	lea    rcx,[rsp+0x20]
    1799:	mov    rdx,r14
    179c:	mov    rsi,r12
    179f:	mov    rdi,r13
    17a2:	call   17a7 <botlish_fn_17+0x11f>
			17a3: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    17a7:	test   rax,rax
    17aa:	mov    rsi,rax
    17ad:	je     1849 <botlish_fn_17+0x1c1>
    17b3:	mov    rdx,QWORD PTR [rsp+0x20]
    17b8:	mov    rcx,QWORD PTR [rsp+0x28]
    17bd:	mov    rdi,r13
    17c0:	mov    rax,QWORD PTR [rdi+0x10]
    17c4:	mov    r8,QWORD PTR [rax+0xc8]
    17cb:	call   17d0 <botlish_fn_17+0x148>
			17cc: R_X86_64_PLT32	rt_str_region_eq-0x4
    17d0:	cmp    rax,0x6
    17d4:	je     17e7 <botlish_fn_17+0x15f>
    17da:	mov    ecx,0x2
    17df:	mov    rax,rcx
    17e2:	jmp    18c9 <botlish_fn_17+0x241>
    17e7:	mov    QWORD PTR [rsp+0x18],0x3
    17f0:	test   r12,0x1
    17f7:	jne    1805 <botlish_fn_17+0x17d>
    17fd:	mov    rcx,r12
    1800:	jmp    181a <botlish_fn_17+0x192>
    1805:	mov    rsi,r12
    1808:	add    rsi,0x2
    180c:	mov    rcx,r12
    180f:	seto   al
    1812:	test   al,al
    1814:	je     182d <botlish_fn_17+0x1a5>
    181a:	mov    edx,0x3
    181f:	mov    rsi,rcx
    1822:	mov    rdi,r13
    1825:	call   182a <botlish_fn_17+0x1a2>
			1826: R_X86_64_PLT32	rt_int_add-0x4
    182a:	mov    rsi,rax
    182d:	mov    QWORD PTR [rsp+0x10],rsi
    1832:	mov    rcx,r14
    1835:	mov    rdx,rbx
    1838:	mov    rdi,r13
    183b:	call   1840 <botlish_fn_17+0x1b8>
			183c: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    1840:	test   rax,rax
    1843:	jne    1869 <botlish_fn_17+0x1e1>
    1849:	xor    rax,rax
    184c:	mov    rbx,QWORD PTR [rsp+0x30]
    1851:	mov    r12,QWORD PTR [rsp+0x38]
    1856:	mov    r13,QWORD PTR [rsp+0x40]
    185b:	mov    r14,QWORD PTR [rsp+0x48]
    1860:	add    rsp,0x50
    1864:	mov    rsp,rbp
    1867:	pop    rbp
    1868:	ret
    1869:	mov    rcx,rax
    186c:	and    rcx,rbx
    186f:	mov    rsi,rax
    1872:	test   rcx,0x1
    1879:	jne    18a2 <botlish_fn_17+0x21a>
    187f:	mov    rdx,rbx
    1882:	mov    rdi,r13
    1885:	call   188a <botlish_fn_17+0x202>
			1886: R_X86_64_PLT32	rt_int_cmp-0x4
    188a:	mov    ecx,0x2
    188f:	test   rax,rax
    1892:	mov    rax,rcx
    1895:	cmove  rax,QWORD PTR [rip+0x4b]        # 18e8 <botlish_fn_17+0x260>
    189d:	jmp    18c9 <botlish_fn_17+0x241>
    18a2:	mov    rdx,rbx
    18a5:	mov    eax,0x2
    18aa:	cmp    rsi,rdx
    18ad:	cmove  rax,QWORD PTR [rip+0x33]        # 18e8 <botlish_fn_17+0x260>
    18b5:	jmp    18c9 <botlish_fn_17+0x241>
    18ba:	mov    eax,0x2
    18bf:	jmp    18c9 <botlish_fn_17+0x241>
    18c4:	mov    eax,0x2
    18c9:	mov    rbx,QWORD PTR [rsp+0x30]
    18ce:	mov    r12,QWORD PTR [rsp+0x38]
    18d3:	mov    r13,QWORD PTR [rsp+0x40]
    18d8:	mov    r14,QWORD PTR [rsp+0x48]
    18dd:	add    rsp,0x50
    18e1:	mov    rsp,rbp
    18e4:	pop    rbp
    18e5:	ret
    18e6:	add    BYTE PTR [rax],al
    18e8:	(bad)
    18e9:	add    BYTE PTR [rax],al
    18eb:	add    BYTE PTR [rax],al
    18ed:	add    BYTE PTR [rax],al
	...

00000000000018f0 <botlish_entry_17: <str>>:
    18f0:	push   rbp
    18f1:	mov    rbp,rsp
    18f4:	mov    rsi,QWORD PTR [rdx]
    18f7:	call   18fc <botlish_entry_17+0xc>
			18f8: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    18fc:	mov    rsp,rbp
    18ff:	pop    rbp
    1900:	ret
    1901:	add    BYTE PTR [rax],al
    1903:	add    BYTE PTR [rax],al
    1905:	add    BYTE PTR [rax],al
	...

0000000000001908 <botlish_fn_18: <generic>>:
    1908:	push   rbp
    1909:	mov    rbp,rsp
    190c:	sub    rsp,0x60
    1910:	mov    QWORD PTR [rsp+0x30],rbx
    1915:	mov    QWORD PTR [rsp+0x38],r12
    191a:	mov    QWORD PTR [rsp+0x40],r13
    191f:	mov    QWORD PTR [rsp+0x48],r14
    1924:	mov    QWORD PTR [rsp+0x50],r15
    1929:	mov    QWORD PTR [rsp+0x18],0x0
    1932:	mov    QWORD PTR [rsp],rsi
    1936:	xor    r8d,r8d
    1939:	test   rsi,0x7
    1940:	jne    1950 <botlish_fn_18+0x48>
    1946:	movzx  rax,BYTE PTR [rsi]
    194a:	cmp    al,0x2
    194c:	sete   r8b
    1950:	test   r8b,r8b
    1953:	jne    1973 <botlish_fn_18+0x6b>
    1959:	mov    rdx,QWORD PTR [rdi+0x10]
    195d:	mov    rcx,QWORD PTR [rdx+0xb0]
    1964:	mov    edx,0x1
    1969:	call   196e <botlish_fn_18+0x66>
			196a: R_X86_64_PLT32	rt_type_error-0x4
    196e:	jmp    1b08 <botlish_fn_18+0x200>
    1973:	mov    r13,rsi
    1976:	mov    r14,rdi
    1979:	call   197e <botlish_fn_18+0x76>
			197a: R_X86_64_PLT32	rt_str_len-0x4
    197e:	mov    rbx,rax
    1981:	mov    QWORD PTR [rsp+0x8],rax
    1986:	mov    edx,0x1
    198b:	mov    r15,rdx
    198e:	mov    QWORD PTR [rsp+0x10],0x1
    1997:	mov    rcx,r13
    199a:	mov    rdx,rbx
    199d:	mov    rsi,r15
    19a0:	mov    rdi,r14
    19a3:	call   19a8 <botlish_fn_18+0xa0>
			19a4: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    19a8:	mov    r12,rax
    19ab:	test   r12,r12
    19ae:	je     1b08 <botlish_fn_18+0x200>
    19b4:	mov    QWORD PTR [rsp+0x10],r12
    19b9:	test   r12,0x1
    19c0:	jne    19e9 <botlish_fn_18+0xe1>
    19c6:	mov    rdx,r15
    19c9:	mov    rsi,r12
    19cc:	mov    rdi,r14
    19cf:	call   19d4 <botlish_fn_18+0xcc>
			19d0: R_X86_64_PLT32	rt_int_cmp-0x4
    19d4:	mov    ecx,0x2
    19d9:	test   rax,rax
    19dc:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 1bb0 <botlish_fn_18+0x2a8>
    19e4:	jmp    19fa <botlish_fn_18+0xf2>
    19e9:	mov    ecx,0x2
    19ee:	cmp    r12,0x1
    19f2:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 1bb0 <botlish_fn_18+0x2a8>
    19fa:	cmp    rcx,0x6
    19fe:	je     1b88 <botlish_fn_18+0x280>
    1a04:	mov    rax,r12
    1a07:	and    rax,rbx
    1a0a:	test   rax,0x1
    1a10:	jne    1a39 <botlish_fn_18+0x131>
    1a16:	mov    rdx,rbx
    1a19:	mov    rsi,r12
    1a1c:	mov    rdi,r14
    1a1f:	call   1a24 <botlish_fn_18+0x11c>
			1a20: R_X86_64_PLT32	rt_int_cmp-0x4
    1a24:	mov    ecx,0x2
    1a29:	test   rax,rax
    1a2c:	cmovge rcx,QWORD PTR [rip+0x17c]        # 1bb0 <botlish_fn_18+0x2a8>
    1a34:	jmp    1a49 <botlish_fn_18+0x141>
    1a39:	mov    ecx,0x2
    1a3e:	cmp    r12,rbx
    1a41:	cmovge rcx,QWORD PTR [rip+0x167]        # 1bb0 <botlish_fn_18+0x2a8>
    1a49:	cmp    rcx,0x6
    1a4d:	je     1b7e <botlish_fn_18+0x276>
    1a53:	lea    rcx,[rsp+0x20]
    1a58:	mov    rdx,r13
    1a5b:	mov    rsi,r12
    1a5e:	mov    rdi,r14
    1a61:	call   1a66 <botlish_fn_18+0x15e>
			1a62: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    1a66:	test   rax,rax
    1a69:	mov    rsi,rax
    1a6c:	je     1b08 <botlish_fn_18+0x200>
    1a72:	mov    rdx,QWORD PTR [rsp+0x20]
    1a77:	mov    rcx,QWORD PTR [rsp+0x28]
    1a7c:	mov    rdi,r14
    1a7f:	mov    rax,QWORD PTR [rdi+0x10]
    1a83:	mov    r8,QWORD PTR [rax+0xc8]
    1a8a:	call   1a8f <botlish_fn_18+0x187>
			1a8b: R_X86_64_PLT32	rt_str_region_eq-0x4
    1a8f:	cmp    rax,0x6
    1a93:	je     1aa6 <botlish_fn_18+0x19e>
    1a99:	mov    ecx,0x2
    1a9e:	mov    rax,rcx
    1aa1:	jmp    1b8d <botlish_fn_18+0x285>
    1aa6:	mov    QWORD PTR [rsp+0x18],0x3
    1aaf:	test   r12,0x1
    1ab6:	jne    1ac4 <botlish_fn_18+0x1bc>
    1abc:	mov    rdi,r12
    1abf:	jmp    1ad9 <botlish_fn_18+0x1d1>
    1ac4:	mov    rsi,r12
    1ac7:	add    rsi,0x2
    1acb:	mov    rdi,r12
    1ace:	seto   al
    1ad1:	test   al,al
    1ad3:	je     1aec <botlish_fn_18+0x1e4>
    1ad9:	mov    edx,0x3
    1ade:	mov    rsi,rdi
    1ae1:	mov    rdi,r14
    1ae4:	call   1ae9 <botlish_fn_18+0x1e1>
			1ae5: R_X86_64_PLT32	rt_int_add-0x4
    1ae9:	mov    rsi,rax
    1aec:	mov    QWORD PTR [rsp+0x10],rsi
    1af1:	mov    rcx,r13
    1af4:	mov    rdx,rbx
    1af7:	mov    rdi,r14
    1afa:	call   1aff <botlish_fn_18+0x1f7>
			1afb: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    1aff:	test   rax,rax
    1b02:	jne    1b2d <botlish_fn_18+0x225>
    1b08:	xor    rax,rax
    1b0b:	mov    rbx,QWORD PTR [rsp+0x30]
    1b10:	mov    r12,QWORD PTR [rsp+0x38]
    1b15:	mov    r13,QWORD PTR [rsp+0x40]
    1b1a:	mov    r14,QWORD PTR [rsp+0x48]
    1b1f:	mov    r15,QWORD PTR [rsp+0x50]
    1b24:	add    rsp,0x60
    1b28:	mov    rsp,rbp
    1b2b:	pop    rbp
    1b2c:	ret
    1b2d:	mov    rcx,rax
    1b30:	and    rcx,rbx
    1b33:	mov    rsi,rax
    1b36:	test   rcx,0x1
    1b3d:	jne    1b66 <botlish_fn_18+0x25e>
    1b43:	mov    rdx,rbx
    1b46:	mov    rdi,r14
    1b49:	call   1b4e <botlish_fn_18+0x246>
			1b4a: R_X86_64_PLT32	rt_int_cmp-0x4
    1b4e:	mov    ecx,0x2
    1b53:	test   rax,rax
    1b56:	mov    rax,rcx
    1b59:	cmove  rax,QWORD PTR [rip+0x4f]        # 1bb0 <botlish_fn_18+0x2a8>
    1b61:	jmp    1b8d <botlish_fn_18+0x285>
    1b66:	mov    rdx,rbx
    1b69:	mov    eax,0x2
    1b6e:	cmp    rsi,rdx
    1b71:	cmove  rax,QWORD PTR [rip+0x37]        # 1bb0 <botlish_fn_18+0x2a8>
    1b79:	jmp    1b8d <botlish_fn_18+0x285>
    1b7e:	mov    eax,0x2
    1b83:	jmp    1b8d <botlish_fn_18+0x285>
    1b88:	mov    eax,0x2
    1b8d:	mov    rbx,QWORD PTR [rsp+0x30]
    1b92:	mov    r12,QWORD PTR [rsp+0x38]
    1b97:	mov    r13,QWORD PTR [rsp+0x40]
    1b9c:	mov    r14,QWORD PTR [rsp+0x48]
    1ba1:	mov    r15,QWORD PTR [rsp+0x50]
    1ba6:	add    rsp,0x60
    1baa:	mov    rsp,rbp
    1bad:	pop    rbp
    1bae:	ret
    1baf:	add    BYTE PTR [rsi],al
    1bb1:	add    BYTE PTR [rax],al
    1bb3:	add    BYTE PTR [rax],al
    1bb5:	add    BYTE PTR [rax],al
	...

0000000000001bb8 <botlish_entry_18: <generic>>:
    1bb8:	push   rbp
    1bb9:	mov    rbp,rsp
    1bbc:	mov    rsi,QWORD PTR [rdx]
    1bbf:	call   1bc4 <botlish_entry_18+0xc>
			1bc0: R_X86_64_PLT32	botlish_fn_18-0x4 ; <generic>
    1bc4:	mov    rsp,rbp
    1bc7:	pop    rbp
    1bc8:	ret

0000000000001bc9 <botlish_fn_19: char_at<generic>>:
    1bc9:	push   rbp
    1bca:	mov    rbp,rsp
    1bcd:	sub    rsp,0x50
    1bd1:	mov    QWORD PTR [rsp+0x20],rbx
    1bd6:	mov    QWORD PTR [rsp+0x28],r12
    1bdb:	mov    QWORD PTR [rsp+0x30],r13
    1be0:	mov    QWORD PTR [rsp+0x38],r14
    1be5:	mov    QWORD PTR [rsp+0x40],r15
    1bea:	mov    r12,rdi
    1bed:	mov    r15,rcx
    1bf0:	mov    QWORD PTR [rsp],rsi
    1bf4:	mov    QWORD PTR [rsp+0x8],rdx
    1bf9:	mov    r13,rdx
    1bfc:	mov    QWORD PTR [rsp+0x10],0x3
    1c05:	test   rsi,0x1
    1c0c:	jne    1c1a <botlish_fn_19+0x51>
    1c12:	mov    rbx,rsi
    1c15:	jmp    1c3a <botlish_fn_19+0x71>
    1c1a:	mov    rax,rsi
    1c1d:	add    rax,0x2
    1c21:	mov    rbx,rsi
    1c24:	seto   cl
    1c27:	test   cl,cl
    1c29:	jne    1c3a <botlish_fn_19+0x71>
    1c2f:	mov    rdi,r12
    1c32:	mov    r14,rax
    1c35:	jmp    1c50 <botlish_fn_19+0x87>
    1c3a:	mov    edx,0x3
    1c3f:	mov    rsi,rbx
    1c42:	mov    rdi,r12
    1c45:	call   1c4a <botlish_fn_19+0x81>
			1c46: R_X86_64_PLT32	rt_int_add-0x4
    1c4a:	mov    r14,rax
    1c4d:	mov    rdi,r12
    1c50:	mov    rcx,r14
    1c53:	mov    rdx,rbx
    1c56:	mov    rsi,r13
    1c59:	call   1c5e <botlish_fn_19+0x95>
			1c5a: R_X86_64_PLT32	rt_str_region_check-0x4
    1c5e:	test   rax,rax
    1c61:	jne    1c8c <botlish_fn_19+0xc3>
    1c67:	xor    rax,rax
    1c6a:	mov    rbx,QWORD PTR [rsp+0x20]
    1c6f:	mov    r12,QWORD PTR [rsp+0x28]
    1c74:	mov    r13,QWORD PTR [rsp+0x30]
    1c79:	mov    r14,QWORD PTR [rsp+0x38]
    1c7e:	mov    r15,QWORD PTR [rsp+0x40]
    1c83:	add    rsp,0x50
    1c87:	mov    rsp,rbp
    1c8a:	pop    rbp
    1c8b:	ret
    1c8c:	mov    rcx,r15
    1c8f:	mov    QWORD PTR [rcx],rbx
    1c92:	mov    rax,r14
    1c95:	mov    QWORD PTR [rcx+0x8],rax
    1c99:	mov    rax,r13
    1c9c:	mov    rbx,QWORD PTR [rsp+0x20]
    1ca1:	mov    r12,QWORD PTR [rsp+0x28]
    1ca6:	mov    r13,QWORD PTR [rsp+0x30]
    1cab:	mov    r14,QWORD PTR [rsp+0x38]
    1cb0:	mov    r15,QWORD PTR [rsp+0x40]
    1cb5:	add    rsp,0x50
    1cb9:	mov    rsp,rbp
    1cbc:	pop    rbp
    1cbd:	ret

0000000000001cbe <botlish_entry_19: char_at<generic>>:
    1cbe:	push   rbp
    1cbf:	mov    rbp,rsp
    1cc2:	ud2
    1cc4:	add    BYTE PTR [rax],al
	...

0000000000001cc8 <botlish_fn_20: scan_local<generic>>:
    1cc8:	push   rbp
    1cc9:	mov    rbp,rsp
    1ccc:	sub    rsp,0x80
    1cd3:	mov    QWORD PTR [rsp+0x50],rbx
    1cd8:	mov    QWORD PTR [rsp+0x58],r12
    1cdd:	mov    QWORD PTR [rsp+0x60],r13
    1ce2:	mov    QWORD PTR [rsp+0x68],r14
    1ce7:	mov    QWORD PTR [rsp+0x70],r15
    1cec:	mov    QWORD PTR [rsp+0x18],0x0
    1cf5:	mov    QWORD PTR [rsp],rsi
    1cf9:	mov    r15,rsi
    1cfc:	mov    QWORD PTR [rsp+0x8],rdx
    1d01:	mov    QWORD PTR [rsp+0x10],rcx
    1d06:	mov    r13,rcx
    1d09:	lea    r14,[rsp+0x20]
    1d0e:	mov    rbx,rdx
    1d11:	mov    rax,rsi
    1d14:	and    rax,rbx
    1d17:	mov    r15,rsi
    1d1a:	test   rax,0x1
    1d20:	jne    1d49 <botlish_fn_20+0x81>
    1d26:	mov    r12,rdi
    1d29:	mov    rdx,rbx
    1d2c:	mov    rsi,r15
    1d2f:	call   1d34 <botlish_fn_20+0x6c>
			1d30: R_X86_64_PLT32	rt_int_cmp-0x4
    1d34:	mov    ecx,0x2
    1d39:	test   rax,rax
    1d3c:	cmovge rcx,QWORD PTR [rip+0x254]        # 1f98 <botlish_fn_20+0x2d0>
    1d44:	jmp    1d5f <botlish_fn_20+0x97>
    1d49:	mov    r12,rdi
    1d4c:	mov    ecx,0x2
    1d51:	mov    rsi,r15
    1d54:	cmp    rsi,rbx
    1d57:	cmovge rcx,QWORD PTR [rip+0x239]        # 1f98 <botlish_fn_20+0x2d0>
    1d5f:	cmp    rcx,0x6
    1d63:	je     1f6a <botlish_fn_20+0x2a2>
    1d69:	mov    rcx,r14
    1d6c:	mov    rdx,r13
    1d6f:	mov    rsi,r15
    1d72:	mov    rdi,r12
    1d75:	call   1d7a <botlish_fn_20+0xb2>
			1d76: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    1d7a:	mov    rcx,rax
    1d7d:	mov    QWORD PTR [rsp+0x40],rax
    1d82:	test   rax,rcx
    1d85:	je     1db5 <botlish_fn_20+0xed>
    1d8b:	mov    rdx,QWORD PTR [rsp+0x20]
    1d90:	mov    QWORD PTR [rsp+0x38],rdx
    1d95:	mov    rcx,QWORD PTR [rsp+0x28]
    1d9a:	mov    QWORD PTR [rsp+0x30],rcx
    1d9f:	mov    rsi,QWORD PTR [rsp+0x40]
    1da4:	mov    rdi,r12
    1da7:	call   1dac <botlish_fn_20+0xe4>
			1da8: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1dac:	test   rax,rax
    1daf:	jne    1ddd <botlish_fn_20+0x115>
    1db5:	xor    rax,rax
    1db8:	mov    rbx,QWORD PTR [rsp+0x50]
    1dbd:	mov    r12,QWORD PTR [rsp+0x58]
    1dc2:	mov    r13,QWORD PTR [rsp+0x60]
    1dc7:	mov    r14,QWORD PTR [rsp+0x68]
    1dcc:	mov    r15,QWORD PTR [rsp+0x70]
    1dd1:	add    rsp,0x80
    1dd8:	mov    rsp,rbp
    1ddb:	pop    rbp
    1ddc:	ret
    1ddd:	cmp    rax,0x6
    1de1:	je     1eeb <botlish_fn_20+0x223>
    1de7:	mov    r9,QWORD PTR [r12+0x10]
    1dec:	mov    r8,QWORD PTR [r9+0xd0]
    1df3:	mov    rcx,QWORD PTR [rsp+0x30]
    1df8:	mov    rdx,QWORD PTR [rsp+0x38]
    1dfd:	mov    rsi,QWORD PTR [rsp+0x40]
    1e02:	mov    rdi,r12
    1e05:	call   1e0a <botlish_fn_20+0x142>
			1e06: R_X86_64_PLT32	rt_str_region_eq-0x4
    1e0a:	cmp    rax,0x6
    1e0e:	je     1ee1 <botlish_fn_20+0x219>
    1e14:	mov    r11,QWORD PTR [r12+0x10]
    1e19:	mov    r8,QWORD PTR [r11+0xd8]
    1e20:	mov    rcx,QWORD PTR [rsp+0x30]
    1e25:	mov    rdx,QWORD PTR [rsp+0x38]
    1e2a:	mov    rsi,QWORD PTR [rsp+0x40]
    1e2f:	mov    rdi,r12
    1e32:	call   1e37 <botlish_fn_20+0x16f>
			1e33: R_X86_64_PLT32	rt_str_region_eq-0x4
    1e37:	cmp    rax,0x6
    1e3b:	je     1ed7 <botlish_fn_20+0x20f>
    1e41:	mov    rax,QWORD PTR [r12+0x10]
    1e46:	mov    r8,QWORD PTR [rax+0xa8]
    1e4d:	mov    rcx,QWORD PTR [rsp+0x30]
    1e52:	mov    rdx,QWORD PTR [rsp+0x38]
    1e57:	mov    rsi,QWORD PTR [rsp+0x40]
    1e5c:	mov    rdi,r12
    1e5f:	call   1e64 <botlish_fn_20+0x19c>
			1e60: R_X86_64_PLT32	rt_str_region_eq-0x4
    1e64:	cmp    rax,0x6
    1e68:	je     1ecd <botlish_fn_20+0x205>
    1e6e:	mov    rax,QWORD PTR [r12+0x10]
    1e73:	mov    r8,QWORD PTR [rax+0xe0]
    1e7a:	mov    rcx,QWORD PTR [rsp+0x30]
    1e7f:	mov    rdx,QWORD PTR [rsp+0x38]
    1e84:	mov    rsi,QWORD PTR [rsp+0x40]
    1e89:	mov    rdi,r12
    1e8c:	call   1e91 <botlish_fn_20+0x1c9>
			1e8d: R_X86_64_PLT32	rt_str_region_eq-0x4
    1e91:	cmp    rax,0x6
    1e95:	je     1ec3 <botlish_fn_20+0x1fb>
    1e9b:	mov    rax,QWORD PTR [r12+0x10]
    1ea0:	mov    r8,QWORD PTR [rax+0xe8]
    1ea7:	mov    rcx,QWORD PTR [rsp+0x30]
    1eac:	mov    rdx,QWORD PTR [rsp+0x38]
    1eb1:	mov    rsi,QWORD PTR [rsp+0x40]
    1eb6:	mov    rdi,r12
    1eb9:	call   1ebe <botlish_fn_20+0x1f6>
			1eba: R_X86_64_PLT32	rt_str_region_eq-0x4
    1ebe:	jmp    1ef0 <botlish_fn_20+0x228>
    1ec3:	mov    eax,0x6
    1ec8:	jmp    1ef0 <botlish_fn_20+0x228>
    1ecd:	mov    eax,0x6
    1ed2:	jmp    1ef0 <botlish_fn_20+0x228>
    1ed7:	mov    eax,0x6
    1edc:	jmp    1ef0 <botlish_fn_20+0x228>
    1ee1:	mov    eax,0x6
    1ee6:	jmp    1ef0 <botlish_fn_20+0x228>
    1eeb:	mov    eax,0x6
    1ef0:	cmp    rax,0x6
    1ef4:	je     1f02 <botlish_fn_20+0x23a>
    1efa:	mov    rax,r15
    1efd:	jmp    1f6d <botlish_fn_20+0x2a5>
    1f02:	mov    QWORD PTR [rsp+0x18],0x3
    1f0b:	mov    rsi,r15
    1f0e:	test   rsi,0x1
    1f15:	je     1f3b <botlish_fn_20+0x273>
    1f1b:	mov    rsi,r15
    1f1e:	mov    rax,rsi
    1f21:	add    rax,0x2
    1f25:	seto   cl
    1f28:	test   cl,cl
    1f2a:	jne    1f3b <botlish_fn_20+0x273>
    1f30:	mov    rsi,rax
    1f33:	mov    r15,rax
    1f36:	jmp    1f51 <botlish_fn_20+0x289>
    1f3b:	mov    edx,0x3
    1f40:	mov    rsi,r15
    1f43:	mov    rdi,r12
    1f46:	call   1f4b <botlish_fn_20+0x283>
			1f47: R_X86_64_PLT32	rt_int_add-0x4
    1f4b:	mov    rsi,rax
    1f4e:	mov    r15,rax
    1f51:	mov    QWORD PTR [rsp],rsi
    1f55:	mov    QWORD PTR [rsp+0x8],rbx
    1f5a:	mov    QWORD PTR [rsp+0x10],r13
    1f5f:	mov    rsi,r15
    1f62:	mov    rdi,r12
    1f65:	jmp    1d11 <botlish_fn_20+0x49>
    1f6a:	mov    rax,r15
    1f6d:	mov    rbx,QWORD PTR [rsp+0x50]
    1f72:	mov    r12,QWORD PTR [rsp+0x58]
    1f77:	mov    r13,QWORD PTR [rsp+0x60]
    1f7c:	mov    r14,QWORD PTR [rsp+0x68]
    1f81:	mov    r15,QWORD PTR [rsp+0x70]
    1f86:	add    rsp,0x80
    1f8d:	mov    rsp,rbp
    1f90:	pop    rbp
    1f91:	ret
    1f92:	add    BYTE PTR [rax],al
    1f94:	add    BYTE PTR [rax],al
    1f96:	add    BYTE PTR [rax],al
    1f98:	(bad)
    1f99:	add    BYTE PTR [rax],al
    1f9b:	add    BYTE PTR [rax],al
    1f9d:	add    BYTE PTR [rax],al
	...

0000000000001fa0 <botlish_entry_20: scan_local<generic>>:
    1fa0:	push   rbp
    1fa1:	mov    rbp,rsp
    1fa4:	mov    rsi,QWORD PTR [rdx]
    1fa7:	mov    r8,QWORD PTR [rdx+0x8]
    1fab:	mov    rcx,QWORD PTR [rdx+0x10]
    1faf:	mov    rdx,r8
    1fb2:	call   1fb7 <botlish_entry_20+0x17>
			1fb3: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    1fb7:	mov    rsp,rbp
    1fba:	pop    rbp
    1fbb:	ret
    1fbc:	add    BYTE PTR [rax],al
	...

0000000000001fc0 <botlish_fn_21: scan_label<generic>>:
    1fc0:	push   rbp
    1fc1:	mov    rbp,rsp
    1fc4:	sub    rsp,0x80
    1fcb:	mov    QWORD PTR [rsp+0x50],rbx
    1fd0:	mov    QWORD PTR [rsp+0x58],r12
    1fd5:	mov    QWORD PTR [rsp+0x60],r13
    1fda:	mov    QWORD PTR [rsp+0x68],r14
    1fdf:	mov    QWORD PTR [rsp+0x70],r15
    1fe4:	mov    QWORD PTR [rsp+0x18],0x0
    1fed:	mov    QWORD PTR [rsp],rsi
    1ff1:	mov    r15,rsi
    1ff4:	mov    QWORD PTR [rsp+0x8],rdx
    1ff9:	mov    QWORD PTR [rsp+0x10],rcx
    1ffe:	mov    r13,rcx
    2001:	lea    r14,[rsp+0x20]
    2006:	mov    rbx,rdx
    2009:	mov    rax,rsi
    200c:	and    rax,rbx
    200f:	mov    r15,rsi
    2012:	test   rax,0x1
    2018:	jne    2041 <botlish_fn_21+0x81>
    201e:	mov    r12,rdi
    2021:	mov    rdx,rbx
    2024:	mov    rsi,r15
    2027:	call   202c <botlish_fn_21+0x6c>
			2028: R_X86_64_PLT32	rt_int_cmp-0x4
    202c:	mov    ecx,0x2
    2031:	test   rax,rax
    2034:	cmovge rcx,QWORD PTR [rip+0x174]        # 21b0 <botlish_fn_21+0x1f0>
    203c:	jmp    2057 <botlish_fn_21+0x97>
    2041:	mov    r12,rdi
    2044:	mov    ecx,0x2
    2049:	mov    rsi,r15
    204c:	cmp    rsi,rbx
    204f:	cmovge rcx,QWORD PTR [rip+0x159]        # 21b0 <botlish_fn_21+0x1f0>
    2057:	cmp    rcx,0x6
    205b:	je     2183 <botlish_fn_21+0x1c3>
    2061:	mov    rcx,r14
    2064:	mov    rdx,r13
    2067:	mov    rsi,r15
    206a:	mov    rdi,r12
    206d:	call   2072 <botlish_fn_21+0xb2>
			206e: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    2072:	test   rax,rax
    2075:	mov    QWORD PTR [rsp+0x40],rax
    207a:	je     20aa <botlish_fn_21+0xea>
    2080:	mov    rdx,QWORD PTR [rsp+0x20]
    2085:	mov    QWORD PTR [rsp+0x38],rdx
    208a:	mov    rcx,QWORD PTR [rsp+0x28]
    208f:	mov    QWORD PTR [rsp+0x30],rcx
    2094:	mov    rsi,QWORD PTR [rsp+0x40]
    2099:	mov    rdi,r12
    209c:	call   20a1 <botlish_fn_21+0xe1>
			209d: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    20a1:	test   rax,rax
    20a4:	jne    20d2 <botlish_fn_21+0x112>
    20aa:	xor    rax,rax
    20ad:	mov    rbx,QWORD PTR [rsp+0x50]
    20b2:	mov    r12,QWORD PTR [rsp+0x58]
    20b7:	mov    r13,QWORD PTR [rsp+0x60]
    20bc:	mov    r14,QWORD PTR [rsp+0x68]
    20c1:	mov    r15,QWORD PTR [rsp+0x70]
    20c6:	add    rsp,0x80
    20cd:	mov    rsp,rbp
    20d0:	pop    rbp
    20d1:	ret
    20d2:	cmp    rax,0x6
    20d6:	je     2104 <botlish_fn_21+0x144>
    20dc:	mov    rax,QWORD PTR [r12+0x10]
    20e1:	mov    r8,QWORD PTR [rax+0xe8]
    20e8:	mov    rcx,QWORD PTR [rsp+0x30]
    20ed:	mov    rdx,QWORD PTR [rsp+0x38]
    20f2:	mov    rsi,QWORD PTR [rsp+0x40]
    20f7:	mov    rdi,r12
    20fa:	call   20ff <botlish_fn_21+0x13f>
			20fb: R_X86_64_PLT32	rt_str_region_eq-0x4
    20ff:	jmp    2109 <botlish_fn_21+0x149>
    2104:	mov    eax,0x6
    2109:	cmp    rax,0x6
    210d:	je     211b <botlish_fn_21+0x15b>
    2113:	mov    rax,r15
    2116:	jmp    2186 <botlish_fn_21+0x1c6>
    211b:	mov    QWORD PTR [rsp+0x18],0x3
    2124:	mov    rsi,r15
    2127:	test   rsi,0x1
    212e:	je     2154 <botlish_fn_21+0x194>
    2134:	mov    rsi,r15
    2137:	mov    rax,rsi
    213a:	add    rax,0x2
    213e:	seto   cl
    2141:	test   cl,cl
    2143:	jne    2154 <botlish_fn_21+0x194>
    2149:	mov    rsi,rax
    214c:	mov    r15,rax
    214f:	jmp    216a <botlish_fn_21+0x1aa>
    2154:	mov    edx,0x3
    2159:	mov    rsi,r15
    215c:	mov    rdi,r12
    215f:	call   2164 <botlish_fn_21+0x1a4>
			2160: R_X86_64_PLT32	rt_int_add-0x4
    2164:	mov    rsi,rax
    2167:	mov    r15,rax
    216a:	mov    QWORD PTR [rsp],rsi
    216e:	mov    QWORD PTR [rsp+0x8],rbx
    2173:	mov    QWORD PTR [rsp+0x10],r13
    2178:	mov    rsi,r15
    217b:	mov    rdi,r12
    217e:	jmp    2009 <botlish_fn_21+0x49>
    2183:	mov    rax,r15
    2186:	mov    rbx,QWORD PTR [rsp+0x50]
    218b:	mov    r12,QWORD PTR [rsp+0x58]
    2190:	mov    r13,QWORD PTR [rsp+0x60]
    2195:	mov    r14,QWORD PTR [rsp+0x68]
    219a:	mov    r15,QWORD PTR [rsp+0x70]
    219f:	add    rsp,0x80
    21a6:	mov    rsp,rbp
    21a9:	pop    rbp
    21aa:	ret
    21ab:	add    BYTE PTR [rax],al
    21ad:	add    BYTE PTR [rax],al
    21af:	add    BYTE PTR [rsi],al
    21b1:	add    BYTE PTR [rax],al
    21b3:	add    BYTE PTR [rax],al
    21b5:	add    BYTE PTR [rax],al
	...

00000000000021b8 <botlish_entry_21: scan_label<generic>>:
    21b8:	push   rbp
    21b9:	mov    rbp,rsp
    21bc:	mov    rsi,QWORD PTR [rdx]
    21bf:	mov    r8,QWORD PTR [rdx+0x8]
    21c3:	mov    rcx,QWORD PTR [rdx+0x10]
    21c7:	mov    rdx,r8
    21ca:	call   21cf <botlish_entry_21+0x17>
			21cb: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    21cf:	mov    rsp,rbp
    21d2:	pop    rbp
    21d3:	ret
    21d4:	add    BYTE PTR [rax],al
	...

00000000000021d8 <botlish_fn_22: scan_alpha<generic>>:
    21d8:	push   rbp
    21d9:	mov    rbp,rsp
    21dc:	sub    rsp,0x60
    21e0:	mov    QWORD PTR [rsp+0x30],rbx
    21e5:	mov    QWORD PTR [rsp+0x38],r12
    21ea:	mov    QWORD PTR [rsp+0x40],r13
    21ef:	mov    QWORD PTR [rsp+0x48],r14
    21f4:	mov    QWORD PTR [rsp+0x50],r15
    21f9:	mov    r15,rdi
    21fc:	mov    QWORD PTR [rsp+0x18],0x0
    2205:	mov    QWORD PTR [rsp],rsi
    2209:	mov    r14,rsi
    220c:	mov    QWORD PTR [rsp+0x8],rdx
    2211:	mov    QWORD PTR [rsp+0x10],rcx
    2216:	mov    r12,rcx
    2219:	lea    r13,[rsp+0x20]
    221e:	mov    rbx,rdx
    2221:	mov    rax,rsi
    2224:	and    rax,rbx
    2227:	mov    r14,rsi
    222a:	test   rax,0x1
    2230:	jne    2259 <botlish_fn_22+0x81>
    2236:	mov    rdx,rbx
    2239:	mov    rsi,r14
    223c:	mov    rdi,r15
    223f:	call   2244 <botlish_fn_22+0x6c>
			2240: R_X86_64_PLT32	rt_int_cmp-0x4
    2244:	mov    ecx,0x2
    2249:	test   rax,rax
    224c:	cmovge rcx,QWORD PTR [rip+0x11c]        # 2370 <botlish_fn_22+0x198>
    2254:	jmp    226c <botlish_fn_22+0x94>
    2259:	mov    ecx,0x2
    225e:	mov    rsi,r14
    2261:	cmp    rsi,rbx
    2264:	cmovge rcx,QWORD PTR [rip+0x104]        # 2370 <botlish_fn_22+0x198>
    226c:	cmp    rcx,0x6
    2270:	je     234a <botlish_fn_22+0x172>
    2276:	mov    rcx,r13
    2279:	mov    rdx,r12
    227c:	mov    rsi,r14
    227f:	mov    rdi,r15
    2282:	call   2287 <botlish_fn_22+0xaf>
			2283: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    2287:	test   rax,rax
    228a:	mov    rsi,rax
    228d:	je     22ae <botlish_fn_22+0xd6>
    2293:	mov    rdx,QWORD PTR [rsp+0x20]
    2298:	mov    rcx,QWORD PTR [rsp+0x28]
    229d:	mov    rdi,r15
    22a0:	call   22a5 <botlish_fn_22+0xcd>
			22a1: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    22a5:	test   rax,rax
    22a8:	jne    22d3 <botlish_fn_22+0xfb>
    22ae:	xor    rax,rax
    22b1:	mov    rbx,QWORD PTR [rsp+0x30]
    22b6:	mov    r12,QWORD PTR [rsp+0x38]
    22bb:	mov    r13,QWORD PTR [rsp+0x40]
    22c0:	mov    r14,QWORD PTR [rsp+0x48]
    22c5:	mov    r15,QWORD PTR [rsp+0x50]
    22ca:	add    rsp,0x60
    22ce:	mov    rsp,rbp
    22d1:	pop    rbp
    22d2:	ret
    22d3:	cmp    rax,0x6
    22d7:	je     22e5 <botlish_fn_22+0x10d>
    22dd:	mov    rax,r14
    22e0:	jmp    234d <botlish_fn_22+0x175>
    22e5:	mov    QWORD PTR [rsp+0x18],0x3
    22ee:	mov    rsi,r14
    22f1:	test   rsi,0x1
    22f8:	je     231e <botlish_fn_22+0x146>
    22fe:	mov    rsi,r14
    2301:	mov    rcx,rsi
    2304:	add    rcx,0x2
    2308:	seto   al
    230b:	test   al,al
    230d:	jne    231e <botlish_fn_22+0x146>
    2313:	mov    rsi,rcx
    2316:	mov    r14,rcx
    2319:	jmp    2334 <botlish_fn_22+0x15c>
    231e:	mov    edx,0x3
    2323:	mov    rsi,r14
    2326:	mov    rdi,r15
    2329:	call   232e <botlish_fn_22+0x156>
			232a: R_X86_64_PLT32	rt_int_add-0x4
    232e:	mov    rsi,rax
    2331:	mov    r14,rax
    2334:	mov    QWORD PTR [rsp],rsi
    2338:	mov    QWORD PTR [rsp+0x8],rbx
    233d:	mov    QWORD PTR [rsp+0x10],r12
    2342:	mov    rsi,r14
    2345:	jmp    2221 <botlish_fn_22+0x49>
    234a:	mov    rax,r14
    234d:	mov    rbx,QWORD PTR [rsp+0x30]
    2352:	mov    r12,QWORD PTR [rsp+0x38]
    2357:	mov    r13,QWORD PTR [rsp+0x40]
    235c:	mov    r14,QWORD PTR [rsp+0x48]
    2361:	mov    r15,QWORD PTR [rsp+0x50]
    2366:	add    rsp,0x60
    236a:	mov    rsp,rbp
    236d:	pop    rbp
    236e:	ret
    236f:	add    BYTE PTR [rsi],al
    2371:	add    BYTE PTR [rax],al
    2373:	add    BYTE PTR [rax],al
    2375:	add    BYTE PTR [rax],al
	...

0000000000002378 <botlish_entry_22: scan_alpha<generic>>:
    2378:	push   rbp
    2379:	mov    rbp,rsp
    237c:	mov    rsi,QWORD PTR [rdx]
    237f:	mov    r8,QWORD PTR [rdx+0x8]
    2383:	mov    rcx,QWORD PTR [rdx+0x10]
    2387:	mov    rdx,r8
    238a:	call   238f <botlish_entry_22+0x17>
			238b: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    238f:	mov    rsp,rbp
    2392:	pop    rbp
    2393:	ret
    2394:	add    BYTE PTR [rax],al
	...

0000000000002398 <botlish_fn_23: tld_ok<generic>>:
    2398:	push   rbp
    2399:	mov    rbp,rsp
    239c:	sub    rsp,0x40
    23a0:	mov    QWORD PTR [rsp+0x20],rbx
    23a5:	mov    QWORD PTR [rsp+0x28],r12
    23aa:	mov    QWORD PTR [rsp+0x30],r13
    23af:	mov    QWORD PTR [rsp+0x38],r14
    23b4:	mov    r12,rdi
    23b7:	mov    QWORD PTR [rsp],rsi
    23bb:	mov    rdi,rsi
    23be:	mov    QWORD PTR [rsp+0x8],rdx
    23c3:	mov    r14,rdx
    23c6:	mov    QWORD PTR [rsp+0x10],rcx
    23cb:	mov    rbx,rdi
    23ce:	mov    rdx,r14
    23d1:	mov    rsi,rbx
    23d4:	mov    rdi,r12
    23d7:	call   23dc <botlish_fn_23+0x44>
			23d8: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    23dc:	mov    rcx,rax
    23df:	mov    r13,rax
    23e2:	test   rax,rcx
    23e5:	jne    240b <botlish_fn_23+0x73>
    23eb:	xor    rax,rax
    23ee:	mov    rbx,QWORD PTR [rsp+0x20]
    23f3:	mov    r12,QWORD PTR [rsp+0x28]
    23f8:	mov    r13,QWORD PTR [rsp+0x30]
    23fd:	mov    r14,QWORD PTR [rsp+0x38]
    2402:	add    rsp,0x40
    2406:	mov    rsp,rbp
    2409:	pop    rbp
    240a:	ret
    240b:	mov    rax,r13
    240e:	mov    QWORD PTR [rsp+0x8],rax
    2413:	mov    rdx,r14
    2416:	and    rax,rdx
    2419:	test   rax,0x1
    241f:	jne    2448 <botlish_fn_23+0xb0>
    2425:	mov    rsi,r13
    2428:	mov    rdi,r12
    242b:	call   2430 <botlish_fn_23+0x98>
			242c: R_X86_64_PLT32	rt_int_cmp-0x4
    2430:	mov    ecx,0x2
    2435:	test   rax,rax
    2438:	cmove  rcx,QWORD PTR [rip+0xe0]        # 2520 <botlish_fn_23+0x188>
    2440:	mov    rax,r13
    2443:	jmp    245b <botlish_fn_23+0xc3>
    2448:	mov    ecx,0x2
    244d:	mov    rax,r13
    2450:	cmp    rax,rdx
    2453:	cmove  rcx,QWORD PTR [rip+0xc5]        # 2520 <botlish_fn_23+0x188>
    245b:	cmp    rcx,0x6
    245f:	je     2472 <botlish_fn_23+0xda>
    2465:	mov    ecx,0x2
    246a:	mov    rax,rcx
    246d:	jmp    24ff <botlish_fn_23+0x167>
    2472:	mov    rcx,rax
    2475:	and    rcx,rbx
    2478:	test   rcx,0x1
    247f:	jne    2490 <botlish_fn_23+0xf8>
    2485:	mov    rdx,rbx
    2488:	mov    rsi,rax
    248b:	jmp    24b1 <botlish_fn_23+0x119>
    2490:	mov    rcx,rax
    2493:	sub    rcx,rbx
    2496:	mov    rdi,rbx
    2499:	mov    r13,rax
    249c:	seto   al
    249f:	lea    rsi,[rcx+0x1]
    24a3:	test   al,al
    24a5:	je     24bc <botlish_fn_23+0x124>
    24ab:	mov    rdx,rdi
    24ae:	mov    rsi,r13
    24b1:	mov    rdi,r12
    24b4:	call   24b9 <botlish_fn_23+0x121>
			24b5: R_X86_64_PLT32	rt_int_sub-0x4
    24b9:	mov    rsi,rax
    24bc:	test   rsi,0x1
    24c3:	jne    24ee <botlish_fn_23+0x156>
    24c9:	mov    edx,0x5
    24ce:	mov    rdi,r12
    24d1:	call   24d6 <botlish_fn_23+0x13e>
			24d2: R_X86_64_PLT32	rt_int_cmp-0x4
    24d6:	mov    ecx,0x2
    24db:	test   rax,rax
    24de:	mov    rax,rcx
    24e1:	cmovge rax,QWORD PTR [rip+0x37]        # 2520 <botlish_fn_23+0x188>
    24e9:	jmp    24ff <botlish_fn_23+0x167>
    24ee:	mov    eax,0x2
    24f3:	cmp    rsi,0x5
    24f7:	cmovge rax,QWORD PTR [rip+0x21]        # 2520 <botlish_fn_23+0x188>
    24ff:	mov    rbx,QWORD PTR [rsp+0x20]
    2504:	mov    r12,QWORD PTR [rsp+0x28]
    2509:	mov    r13,QWORD PTR [rsp+0x30]
    250e:	mov    r14,QWORD PTR [rsp+0x38]
    2513:	add    rsp,0x40
    2517:	mov    rsp,rbp
    251a:	pop    rbp
    251b:	ret
    251c:	add    BYTE PTR [rax],al
    251e:	add    BYTE PTR [rax],al
    2520:	(bad)
    2521:	add    BYTE PTR [rax],al
    2523:	add    BYTE PTR [rax],al
    2525:	add    BYTE PTR [rax],al
	...

0000000000002528 <botlish_entry_23: tld_ok<generic>>:
    2528:	push   rbp
    2529:	mov    rbp,rsp
    252c:	mov    rsi,QWORD PTR [rdx]
    252f:	mov    r8,QWORD PTR [rdx+0x8]
    2533:	mov    rcx,QWORD PTR [rdx+0x10]
    2537:	mov    rdx,r8
    253a:	call   253f <botlish_entry_23+0x17>
			253b: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    253f:	mov    rsp,rbp
    2542:	pop    rbp
    2543:	ret
    2544:	add    BYTE PTR [rax],al
	...

0000000000002548 <botlish_fn_24: domain_loop<generic>>:
    2548:	push   rbp
    2549:	mov    rbp,rsp
    254c:	sub    rsp,0x70
    2550:	mov    QWORD PTR [rsp+0x40],rbx
    2555:	mov    QWORD PTR [rsp+0x48],r12
    255a:	mov    QWORD PTR [rsp+0x50],r13
    255f:	mov    QWORD PTR [rsp+0x58],r14
    2564:	mov    QWORD PTR [rsp+0x60],r15
    2569:	mov    QWORD PTR [rsp+0x18],0x0
    2572:	mov    QWORD PTR [rsp],rsi
    2576:	mov    QWORD PTR [rsp+0x8],rdx
    257b:	mov    QWORD PTR [rsp+0x10],rcx
    2580:	lea    rbx,[rsp+0x20]
    2585:	mov    r12,rdi
    2588:	mov    r13,rcx
    258b:	mov    r14,rdx
    258e:	mov    QWORD PTR [rsp+0x30],rsi
    2593:	mov    rcx,r13
    2596:	mov    rdx,r14
    2599:	mov    rsi,QWORD PTR [rsp+0x30]
    259e:	mov    rdi,r12
    25a1:	call   25a6 <botlish_fn_24+0x5e>
			25a2: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    25a6:	mov    rcx,rax
    25a9:	mov    r15,rax
    25ac:	test   rax,rcx
    25af:	je     2706 <botlish_fn_24+0x1be>
    25b5:	mov    rax,r15
    25b8:	mov    QWORD PTR [rsp],rax
    25bc:	mov    rdx,QWORD PTR [rsp+0x30]
    25c1:	and    rax,rdx
    25c4:	test   rax,0x1
    25ca:	jne    25f0 <botlish_fn_24+0xa8>
    25d0:	mov    rsi,r15
    25d3:	mov    rdi,r12
    25d6:	call   25db <botlish_fn_24+0x93>
			25d7: R_X86_64_PLT32	rt_int_cmp-0x4
    25db:	mov    ecx,0x2
    25e0:	test   rax,rax
    25e3:	cmove  rcx,QWORD PTR [rip+0x19d]        # 2788 <botlish_fn_24+0x240>
    25eb:	jmp    2600 <botlish_fn_24+0xb8>
    25f0:	mov    ecx,0x2
    25f5:	cmp    r15,rdx
    25f8:	cmove  rcx,QWORD PTR [rip+0x188]        # 2788 <botlish_fn_24+0x240>
    2600:	cmp    rcx,0x6
    2604:	je     275c <botlish_fn_24+0x214>
    260a:	mov    rax,r15
    260d:	and    rax,r14
    2610:	test   rax,0x1
    2616:	jne    263f <botlish_fn_24+0xf7>
    261c:	mov    rdx,r14
    261f:	mov    rsi,r15
    2622:	mov    rdi,r12
    2625:	call   262a <botlish_fn_24+0xe2>
			2626: R_X86_64_PLT32	rt_int_cmp-0x4
    262a:	mov    ecx,0x2
    262f:	test   rax,rax
    2632:	cmovge rcx,QWORD PTR [rip+0x14e]        # 2788 <botlish_fn_24+0x240>
    263a:	jmp    264f <botlish_fn_24+0x107>
    263f:	mov    ecx,0x2
    2644:	cmp    r15,r14
    2647:	cmovge rcx,QWORD PTR [rip+0x139]        # 2788 <botlish_fn_24+0x240>
    264f:	cmp    rcx,0x6
    2653:	je     274d <botlish_fn_24+0x205>
    2659:	mov    rcx,rbx
    265c:	mov    rdx,r13
    265f:	mov    rsi,r15
    2662:	mov    rdi,r12
    2665:	call   266a <botlish_fn_24+0x122>
			2666: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    266a:	test   rax,rax
    266d:	je     2706 <botlish_fn_24+0x1be>
    2673:	mov    rdx,QWORD PTR [rsp+0x20]
    2678:	mov    rcx,QWORD PTR [rsp+0x28]
    267d:	mov    rsi,QWORD PTR [r12+0x10]
    2682:	mov    r8,QWORD PTR [rsi+0xd0]
    2689:	mov    rsi,rax
    268c:	mov    rdi,r12
    268f:	call   2694 <botlish_fn_24+0x14c>
			2690: R_X86_64_PLT32	rt_str_region_eq-0x4
    2694:	cmp    rax,0x6
    2698:	je     26aa <botlish_fn_24+0x162>
    269e:	mov    r14,0xffffffffffffffff
    26a5:	jmp    2754 <botlish_fn_24+0x20c>
    26aa:	mov    QWORD PTR [rsp+0x18],0x3
    26b3:	test   r15,0x1
    26ba:	je     26d2 <botlish_fn_24+0x18a>
    26c0:	mov    rdx,r15
    26c3:	add    rdx,0x2
    26c7:	seto   al
    26ca:	test   al,al
    26cc:	je     26e5 <botlish_fn_24+0x19d>
    26d2:	mov    edx,0x3
    26d7:	mov    rsi,r15
    26da:	mov    rdi,r12
    26dd:	call   26e2 <botlish_fn_24+0x19a>
			26de: R_X86_64_PLT32	rt_int_add-0x4
    26e2:	mov    rdx,rax
    26e5:	mov    QWORD PTR [rsp],rdx
    26e9:	mov    r15,rdx
    26ec:	mov    rcx,r13
    26ef:	mov    rdx,r14
    26f2:	mov    rsi,r15
    26f5:	mov    rdi,r12
    26f8:	call   26fd <botlish_fn_24+0x1b5>
			26f9: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    26fd:	test   rax,rax
    2700:	jne    272b <botlish_fn_24+0x1e3>
    2706:	xor    rax,rax
    2709:	mov    rbx,QWORD PTR [rsp+0x40]
    270e:	mov    r12,QWORD PTR [rsp+0x48]
    2713:	mov    r13,QWORD PTR [rsp+0x50]
    2718:	mov    r14,QWORD PTR [rsp+0x58]
    271d:	mov    r15,QWORD PTR [rsp+0x60]
    2722:	add    rsp,0x70
    2726:	mov    rsp,rbp
    2729:	pop    rbp
    272a:	ret
    272b:	cmp    rax,0x6
    272f:	je     2754 <botlish_fn_24+0x20c>
    2735:	mov    QWORD PTR [rsp],r15
    2739:	mov    QWORD PTR [rsp+0x8],r14
    273e:	mov    QWORD PTR [rsp+0x10],r13
    2743:	mov    QWORD PTR [rsp+0x30],r15
    2748:	jmp    2593 <botlish_fn_24+0x4b>
    274d:	mov    r14,0xffffffffffffffff
    2754:	mov    rax,r14
    2757:	jmp    2763 <botlish_fn_24+0x21b>
    275c:	mov    rax,0xffffffffffffffff
    2763:	mov    rbx,QWORD PTR [rsp+0x40]
    2768:	mov    r12,QWORD PTR [rsp+0x48]
    276d:	mov    r13,QWORD PTR [rsp+0x50]
    2772:	mov    r14,QWORD PTR [rsp+0x58]
    2777:	mov    r15,QWORD PTR [rsp+0x60]
    277c:	add    rsp,0x70
    2780:	mov    rsp,rbp
    2783:	pop    rbp
    2784:	ret
    2785:	add    BYTE PTR [rax],al
    2787:	add    BYTE PTR [rsi],al
    2789:	add    BYTE PTR [rax],al
    278b:	add    BYTE PTR [rax],al
    278d:	add    BYTE PTR [rax],al
	...

0000000000002790 <botlish_entry_24: domain_loop<generic>>:
    2790:	push   rbp
    2791:	mov    rbp,rsp
    2794:	mov    rsi,QWORD PTR [rdx]
    2797:	mov    r8,QWORD PTR [rdx+0x8]
    279b:	mov    rcx,QWORD PTR [rdx+0x10]
    279f:	mov    rdx,r8
    27a2:	call   27a7 <botlish_entry_24+0x17>
			27a3: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    27a7:	mov    rsp,rbp
    27aa:	pop    rbp
    27ab:	ret
    27ac:	add    BYTE PTR [rax],al
	...

00000000000027b0 <botlish_fn_25: <str>>:
    27b0:	push   rbp
    27b1:	mov    rbp,rsp
    27b4:	sub    rsp,0x50
    27b8:	mov    QWORD PTR [rsp+0x30],rbx
    27bd:	mov    QWORD PTR [rsp+0x38],r12
    27c2:	mov    QWORD PTR [rsp+0x40],r13
    27c7:	mov    QWORD PTR [rsp+0x48],r14
    27cc:	mov    r13,rdi
    27cf:	mov    QWORD PTR [rsp+0x18],0x0
    27d8:	mov    QWORD PTR [rsp],rsi
    27dc:	mov    r14,rsi
    27df:	mov    rsi,r14
    27e2:	mov    rdi,r13
    27e5:	call   27ea <botlish_fn_25+0x3a>
			27e6: R_X86_64_PLT32	rt_str_len-0x4
    27ea:	mov    rbx,rax
    27ed:	mov    QWORD PTR [rsp+0x8],rax
    27f2:	mov    esi,0x1
    27f7:	mov    QWORD PTR [rsp+0x10],0x1
    2800:	mov    rcx,r14
    2803:	mov    rdx,rbx
    2806:	mov    rdi,r13
    2809:	call   280e <botlish_fn_25+0x5e>
			280a: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    280e:	mov    r12,rax
    2811:	test   r12,r12
    2814:	je     2971 <botlish_fn_25+0x1c1>
    281a:	mov    QWORD PTR [rsp+0x10],r12
    281f:	test   r12,0x1
    2826:	jne    2851 <botlish_fn_25+0xa1>
    282c:	mov    edx,0x1
    2831:	mov    rsi,r12
    2834:	mov    rdi,r13
    2837:	call   283c <botlish_fn_25+0x8c>
			2838: R_X86_64_PLT32	rt_int_cmp-0x4
    283c:	mov    ecx,0x2
    2841:	test   rax,rax
    2844:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 2a10 <botlish_fn_25+0x260>
    284c:	jmp    2862 <botlish_fn_25+0xb2>
    2851:	mov    ecx,0x2
    2856:	cmp    r12,0x1
    285a:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 2a10 <botlish_fn_25+0x260>
    2862:	cmp    rcx,0x6
    2866:	je     29ec <botlish_fn_25+0x23c>
    286c:	mov    rcx,r12
    286f:	and    rcx,rbx
    2872:	test   rcx,0x1
    2879:	jne    28a2 <botlish_fn_25+0xf2>
    287f:	mov    rdx,rbx
    2882:	mov    rsi,r12
    2885:	mov    rdi,r13
    2888:	call   288d <botlish_fn_25+0xdd>
			2889: R_X86_64_PLT32	rt_int_cmp-0x4
    288d:	mov    ecx,0x2
    2892:	test   rax,rax
    2895:	cmovge rcx,QWORD PTR [rip+0x173]        # 2a10 <botlish_fn_25+0x260>
    289d:	jmp    28b2 <botlish_fn_25+0x102>
    28a2:	mov    ecx,0x2
    28a7:	cmp    r12,rbx
    28aa:	cmovge rcx,QWORD PTR [rip+0x15e]        # 2a10 <botlish_fn_25+0x260>
    28b2:	cmp    rcx,0x6
    28b6:	je     29e2 <botlish_fn_25+0x232>
    28bc:	lea    rcx,[rsp+0x20]
    28c1:	mov    rdx,r14
    28c4:	mov    rsi,r12
    28c7:	mov    rdi,r13
    28ca:	call   28cf <botlish_fn_25+0x11f>
			28cb: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    28cf:	test   rax,rax
    28d2:	mov    rsi,rax
    28d5:	je     2971 <botlish_fn_25+0x1c1>
    28db:	mov    rdx,QWORD PTR [rsp+0x20]
    28e0:	mov    rcx,QWORD PTR [rsp+0x28]
    28e5:	mov    rdi,r13
    28e8:	mov    rax,QWORD PTR [rdi+0x10]
    28ec:	mov    r8,QWORD PTR [rax+0xc8]
    28f3:	call   28f8 <botlish_fn_25+0x148>
			28f4: R_X86_64_PLT32	rt_str_region_eq-0x4
    28f8:	cmp    rax,0x6
    28fc:	je     290f <botlish_fn_25+0x15f>
    2902:	mov    ecx,0x2
    2907:	mov    rax,rcx
    290a:	jmp    29f1 <botlish_fn_25+0x241>
    290f:	mov    QWORD PTR [rsp+0x18],0x3
    2918:	test   r12,0x1
    291f:	jne    292d <botlish_fn_25+0x17d>
    2925:	mov    rcx,r12
    2928:	jmp    2942 <botlish_fn_25+0x192>
    292d:	mov    rsi,r12
    2930:	add    rsi,0x2
    2934:	mov    rcx,r12
    2937:	seto   al
    293a:	test   al,al
    293c:	je     2955 <botlish_fn_25+0x1a5>
    2942:	mov    edx,0x3
    2947:	mov    rsi,rcx
    294a:	mov    rdi,r13
    294d:	call   2952 <botlish_fn_25+0x1a2>
			294e: R_X86_64_PLT32	rt_int_add-0x4
    2952:	mov    rsi,rax
    2955:	mov    QWORD PTR [rsp+0x10],rsi
    295a:	mov    rcx,r14
    295d:	mov    rdx,rbx
    2960:	mov    rdi,r13
    2963:	call   2968 <botlish_fn_25+0x1b8>
			2964: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    2968:	test   rax,rax
    296b:	jne    2991 <botlish_fn_25+0x1e1>
    2971:	xor    rax,rax
    2974:	mov    rbx,QWORD PTR [rsp+0x30]
    2979:	mov    r12,QWORD PTR [rsp+0x38]
    297e:	mov    r13,QWORD PTR [rsp+0x40]
    2983:	mov    r14,QWORD PTR [rsp+0x48]
    2988:	add    rsp,0x50
    298c:	mov    rsp,rbp
    298f:	pop    rbp
    2990:	ret
    2991:	mov    rcx,rax
    2994:	and    rcx,rbx
    2997:	mov    rsi,rax
    299a:	test   rcx,0x1
    29a1:	jne    29ca <botlish_fn_25+0x21a>
    29a7:	mov    rdx,rbx
    29aa:	mov    rdi,r13
    29ad:	call   29b2 <botlish_fn_25+0x202>
			29ae: R_X86_64_PLT32	rt_int_cmp-0x4
    29b2:	mov    ecx,0x2
    29b7:	test   rax,rax
    29ba:	mov    rax,rcx
    29bd:	cmove  rax,QWORD PTR [rip+0x4b]        # 2a10 <botlish_fn_25+0x260>
    29c5:	jmp    29f1 <botlish_fn_25+0x241>
    29ca:	mov    rdx,rbx
    29cd:	mov    eax,0x2
    29d2:	cmp    rsi,rdx
    29d5:	cmove  rax,QWORD PTR [rip+0x33]        # 2a10 <botlish_fn_25+0x260>
    29dd:	jmp    29f1 <botlish_fn_25+0x241>
    29e2:	mov    eax,0x2
    29e7:	jmp    29f1 <botlish_fn_25+0x241>
    29ec:	mov    eax,0x2
    29f1:	mov    rbx,QWORD PTR [rsp+0x30]
    29f6:	mov    r12,QWORD PTR [rsp+0x38]
    29fb:	mov    r13,QWORD PTR [rsp+0x40]
    2a00:	mov    r14,QWORD PTR [rsp+0x48]
    2a05:	add    rsp,0x50
    2a09:	mov    rsp,rbp
    2a0c:	pop    rbp
    2a0d:	ret
    2a0e:	add    BYTE PTR [rax],al
    2a10:	(bad)
    2a11:	add    BYTE PTR [rax],al
    2a13:	add    BYTE PTR [rax],al
    2a15:	add    BYTE PTR [rax],al
	...

0000000000002a18 <botlish_entry_25: <str>>:
    2a18:	push   rbp
    2a19:	mov    rbp,rsp
    2a1c:	mov    rsi,QWORD PTR [rdx]
    2a1f:	call   2a24 <botlish_entry_25+0xc>
			2a20: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    2a24:	mov    rsp,rbp
    2a27:	pop    rbp
    2a28:	ret
    2a29:	add    BYTE PTR [rax],al
    2a2b:	add    BYTE PTR [rax],al
    2a2d:	add    BYTE PTR [rax],al
	...

0000000000002a30 <botlish_fn_26: <generic>>:
    2a30:	push   rbp
    2a31:	mov    rbp,rsp
    2a34:	sub    rsp,0x60
    2a38:	mov    QWORD PTR [rsp+0x30],rbx
    2a3d:	mov    QWORD PTR [rsp+0x38],r12
    2a42:	mov    QWORD PTR [rsp+0x40],r13
    2a47:	mov    QWORD PTR [rsp+0x48],r14
    2a4c:	mov    QWORD PTR [rsp+0x50],r15
    2a51:	mov    QWORD PTR [rsp+0x18],0x0
    2a5a:	mov    QWORD PTR [rsp],rsi
    2a5e:	xor    r8d,r8d
    2a61:	test   rsi,0x7
    2a68:	jne    2a78 <botlish_fn_26+0x48>
    2a6e:	movzx  rax,BYTE PTR [rsi]
    2a72:	cmp    al,0x2
    2a74:	sete   r8b
    2a78:	test   r8b,r8b
    2a7b:	jne    2a9b <botlish_fn_26+0x6b>
    2a81:	mov    rdx,QWORD PTR [rdi+0x10]
    2a85:	mov    rcx,QWORD PTR [rdx+0xb0]
    2a8c:	mov    edx,0x1
    2a91:	call   2a96 <botlish_fn_26+0x66>
			2a92: R_X86_64_PLT32	rt_type_error-0x4
    2a96:	jmp    2c30 <botlish_fn_26+0x200>
    2a9b:	mov    r13,rsi
    2a9e:	mov    r14,rdi
    2aa1:	call   2aa6 <botlish_fn_26+0x76>
			2aa2: R_X86_64_PLT32	rt_str_len-0x4
    2aa6:	mov    rbx,rax
    2aa9:	mov    QWORD PTR [rsp+0x8],rax
    2aae:	mov    edx,0x1
    2ab3:	mov    r15,rdx
    2ab6:	mov    QWORD PTR [rsp+0x10],0x1
    2abf:	mov    rcx,r13
    2ac2:	mov    rdx,rbx
    2ac5:	mov    rsi,r15
    2ac8:	mov    rdi,r14
    2acb:	call   2ad0 <botlish_fn_26+0xa0>
			2acc: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    2ad0:	mov    r12,rax
    2ad3:	test   r12,r12
    2ad6:	je     2c30 <botlish_fn_26+0x200>
    2adc:	mov    QWORD PTR [rsp+0x10],r12
    2ae1:	test   r12,0x1
    2ae8:	jne    2b11 <botlish_fn_26+0xe1>
    2aee:	mov    rdx,r15
    2af1:	mov    rsi,r12
    2af4:	mov    rdi,r14
    2af7:	call   2afc <botlish_fn_26+0xcc>
			2af8: R_X86_64_PLT32	rt_int_cmp-0x4
    2afc:	mov    ecx,0x2
    2b01:	test   rax,rax
    2b04:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 2cd8 <botlish_fn_26+0x2a8>
    2b0c:	jmp    2b22 <botlish_fn_26+0xf2>
    2b11:	mov    ecx,0x2
    2b16:	cmp    r12,0x1
    2b1a:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 2cd8 <botlish_fn_26+0x2a8>
    2b22:	cmp    rcx,0x6
    2b26:	je     2cb0 <botlish_fn_26+0x280>
    2b2c:	mov    rax,r12
    2b2f:	and    rax,rbx
    2b32:	test   rax,0x1
    2b38:	jne    2b61 <botlish_fn_26+0x131>
    2b3e:	mov    rdx,rbx
    2b41:	mov    rsi,r12
    2b44:	mov    rdi,r14
    2b47:	call   2b4c <botlish_fn_26+0x11c>
			2b48: R_X86_64_PLT32	rt_int_cmp-0x4
    2b4c:	mov    ecx,0x2
    2b51:	test   rax,rax
    2b54:	cmovge rcx,QWORD PTR [rip+0x17c]        # 2cd8 <botlish_fn_26+0x2a8>
    2b5c:	jmp    2b71 <botlish_fn_26+0x141>
    2b61:	mov    ecx,0x2
    2b66:	cmp    r12,rbx
    2b69:	cmovge rcx,QWORD PTR [rip+0x167]        # 2cd8 <botlish_fn_26+0x2a8>
    2b71:	cmp    rcx,0x6
    2b75:	je     2ca6 <botlish_fn_26+0x276>
    2b7b:	lea    rcx,[rsp+0x20]
    2b80:	mov    rdx,r13
    2b83:	mov    rsi,r12
    2b86:	mov    rdi,r14
    2b89:	call   2b8e <botlish_fn_26+0x15e>
			2b8a: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    2b8e:	test   rax,rax
    2b91:	mov    rsi,rax
    2b94:	je     2c30 <botlish_fn_26+0x200>
    2b9a:	mov    rdx,QWORD PTR [rsp+0x20]
    2b9f:	mov    rcx,QWORD PTR [rsp+0x28]
    2ba4:	mov    rdi,r14
    2ba7:	mov    rax,QWORD PTR [rdi+0x10]
    2bab:	mov    r8,QWORD PTR [rax+0xc8]
    2bb2:	call   2bb7 <botlish_fn_26+0x187>
			2bb3: R_X86_64_PLT32	rt_str_region_eq-0x4
    2bb7:	cmp    rax,0x6
    2bbb:	je     2bce <botlish_fn_26+0x19e>
    2bc1:	mov    ecx,0x2
    2bc6:	mov    rax,rcx
    2bc9:	jmp    2cb5 <botlish_fn_26+0x285>
    2bce:	mov    QWORD PTR [rsp+0x18],0x3
    2bd7:	test   r12,0x1
    2bde:	jne    2bec <botlish_fn_26+0x1bc>
    2be4:	mov    rdi,r12
    2be7:	jmp    2c01 <botlish_fn_26+0x1d1>
    2bec:	mov    rsi,r12
    2bef:	add    rsi,0x2
    2bf3:	mov    rdi,r12
    2bf6:	seto   al
    2bf9:	test   al,al
    2bfb:	je     2c14 <botlish_fn_26+0x1e4>
    2c01:	mov    edx,0x3
    2c06:	mov    rsi,rdi
    2c09:	mov    rdi,r14
    2c0c:	call   2c11 <botlish_fn_26+0x1e1>
			2c0d: R_X86_64_PLT32	rt_int_add-0x4
    2c11:	mov    rsi,rax
    2c14:	mov    QWORD PTR [rsp+0x10],rsi
    2c19:	mov    rcx,r13
    2c1c:	mov    rdx,rbx
    2c1f:	mov    rdi,r14
    2c22:	call   2c27 <botlish_fn_26+0x1f7>
			2c23: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    2c27:	test   rax,rax
    2c2a:	jne    2c55 <botlish_fn_26+0x225>
    2c30:	xor    rax,rax
    2c33:	mov    rbx,QWORD PTR [rsp+0x30]
    2c38:	mov    r12,QWORD PTR [rsp+0x38]
    2c3d:	mov    r13,QWORD PTR [rsp+0x40]
    2c42:	mov    r14,QWORD PTR [rsp+0x48]
    2c47:	mov    r15,QWORD PTR [rsp+0x50]
    2c4c:	add    rsp,0x60
    2c50:	mov    rsp,rbp
    2c53:	pop    rbp
    2c54:	ret
    2c55:	mov    rcx,rax
    2c58:	and    rcx,rbx
    2c5b:	mov    rsi,rax
    2c5e:	test   rcx,0x1
    2c65:	jne    2c8e <botlish_fn_26+0x25e>
    2c6b:	mov    rdx,rbx
    2c6e:	mov    rdi,r14
    2c71:	call   2c76 <botlish_fn_26+0x246>
			2c72: R_X86_64_PLT32	rt_int_cmp-0x4
    2c76:	mov    ecx,0x2
    2c7b:	test   rax,rax
    2c7e:	mov    rax,rcx
    2c81:	cmove  rax,QWORD PTR [rip+0x4f]        # 2cd8 <botlish_fn_26+0x2a8>
    2c89:	jmp    2cb5 <botlish_fn_26+0x285>
    2c8e:	mov    rdx,rbx
    2c91:	mov    eax,0x2
    2c96:	cmp    rsi,rdx
    2c99:	cmove  rax,QWORD PTR [rip+0x37]        # 2cd8 <botlish_fn_26+0x2a8>
    2ca1:	jmp    2cb5 <botlish_fn_26+0x285>
    2ca6:	mov    eax,0x2
    2cab:	jmp    2cb5 <botlish_fn_26+0x285>
    2cb0:	mov    eax,0x2
    2cb5:	mov    rbx,QWORD PTR [rsp+0x30]
    2cba:	mov    r12,QWORD PTR [rsp+0x38]
    2cbf:	mov    r13,QWORD PTR [rsp+0x40]
    2cc4:	mov    r14,QWORD PTR [rsp+0x48]
    2cc9:	mov    r15,QWORD PTR [rsp+0x50]
    2cce:	add    rsp,0x60
    2cd2:	mov    rsp,rbp
    2cd5:	pop    rbp
    2cd6:	ret
    2cd7:	add    BYTE PTR [rsi],al
    2cd9:	add    BYTE PTR [rax],al
    2cdb:	add    BYTE PTR [rax],al
    2cdd:	add    BYTE PTR [rax],al
	...

0000000000002ce0 <botlish_entry_26: <generic>>:
    2ce0:	push   rbp
    2ce1:	mov    rbp,rsp
    2ce4:	mov    rsi,QWORD PTR [rdx]
    2ce7:	call   2cec <botlish_entry_26+0xc>
			2ce8: R_X86_64_PLT32	botlish_fn_26-0x4 ; <generic>
    2cec:	mov    rsp,rbp
    2cef:	pop    rbp
    2cf0:	ret

0000000000002cf1 <botlish_fn_27: char_at<generic>>:
    2cf1:	push   rbp
    2cf2:	mov    rbp,rsp
    2cf5:	sub    rsp,0x50
    2cf9:	mov    QWORD PTR [rsp+0x20],rbx
    2cfe:	mov    QWORD PTR [rsp+0x28],r12
    2d03:	mov    QWORD PTR [rsp+0x30],r13
    2d08:	mov    QWORD PTR [rsp+0x38],r14
    2d0d:	mov    QWORD PTR [rsp+0x40],r15
    2d12:	mov    r12,rdi
    2d15:	mov    r15,rcx
    2d18:	mov    QWORD PTR [rsp],rsi
    2d1c:	mov    QWORD PTR [rsp+0x8],rdx
    2d21:	mov    r13,rdx
    2d24:	mov    QWORD PTR [rsp+0x10],0x3
    2d2d:	test   rsi,0x1
    2d34:	jne    2d42 <botlish_fn_27+0x51>
    2d3a:	mov    rbx,rsi
    2d3d:	jmp    2d62 <botlish_fn_27+0x71>
    2d42:	mov    rax,rsi
    2d45:	add    rax,0x2
    2d49:	mov    rbx,rsi
    2d4c:	seto   cl
    2d4f:	test   cl,cl
    2d51:	jne    2d62 <botlish_fn_27+0x71>
    2d57:	mov    rdi,r12
    2d5a:	mov    r14,rax
    2d5d:	jmp    2d78 <botlish_fn_27+0x87>
    2d62:	mov    edx,0x3
    2d67:	mov    rsi,rbx
    2d6a:	mov    rdi,r12
    2d6d:	call   2d72 <botlish_fn_27+0x81>
			2d6e: R_X86_64_PLT32	rt_int_add-0x4
    2d72:	mov    r14,rax
    2d75:	mov    rdi,r12
    2d78:	mov    rcx,r14
    2d7b:	mov    rdx,rbx
    2d7e:	mov    rsi,r13
    2d81:	call   2d86 <botlish_fn_27+0x95>
			2d82: R_X86_64_PLT32	rt_str_region_check-0x4
    2d86:	test   rax,rax
    2d89:	jne    2db4 <botlish_fn_27+0xc3>
    2d8f:	xor    rax,rax
    2d92:	mov    rbx,QWORD PTR [rsp+0x20]
    2d97:	mov    r12,QWORD PTR [rsp+0x28]
    2d9c:	mov    r13,QWORD PTR [rsp+0x30]
    2da1:	mov    r14,QWORD PTR [rsp+0x38]
    2da6:	mov    r15,QWORD PTR [rsp+0x40]
    2dab:	add    rsp,0x50
    2daf:	mov    rsp,rbp
    2db2:	pop    rbp
    2db3:	ret
    2db4:	mov    rcx,r15
    2db7:	mov    QWORD PTR [rcx],rbx
    2dba:	mov    rax,r14
    2dbd:	mov    QWORD PTR [rcx+0x8],rax
    2dc1:	mov    rax,r13
    2dc4:	mov    rbx,QWORD PTR [rsp+0x20]
    2dc9:	mov    r12,QWORD PTR [rsp+0x28]
    2dce:	mov    r13,QWORD PTR [rsp+0x30]
    2dd3:	mov    r14,QWORD PTR [rsp+0x38]
    2dd8:	mov    r15,QWORD PTR [rsp+0x40]
    2ddd:	add    rsp,0x50
    2de1:	mov    rsp,rbp
    2de4:	pop    rbp
    2de5:	ret

0000000000002de6 <botlish_entry_27: char_at<generic>>:
    2de6:	push   rbp
    2de7:	mov    rbp,rsp
    2dea:	ud2
    2dec:	add    BYTE PTR [rax],al
	...

0000000000002df0 <botlish_fn_28: scan_local<generic>>:
    2df0:	push   rbp
    2df1:	mov    rbp,rsp
    2df4:	sub    rsp,0x80
    2dfb:	mov    QWORD PTR [rsp+0x50],rbx
    2e00:	mov    QWORD PTR [rsp+0x58],r12
    2e05:	mov    QWORD PTR [rsp+0x60],r13
    2e0a:	mov    QWORD PTR [rsp+0x68],r14
    2e0f:	mov    QWORD PTR [rsp+0x70],r15
    2e14:	mov    QWORD PTR [rsp+0x18],0x0
    2e1d:	mov    QWORD PTR [rsp],rsi
    2e21:	mov    r15,rsi
    2e24:	mov    QWORD PTR [rsp+0x8],rdx
    2e29:	mov    QWORD PTR [rsp+0x10],rcx
    2e2e:	mov    r13,rcx
    2e31:	lea    r14,[rsp+0x20]
    2e36:	mov    rbx,rdx
    2e39:	mov    rax,rsi
    2e3c:	and    rax,rbx
    2e3f:	mov    r15,rsi
    2e42:	test   rax,0x1
    2e48:	jne    2e71 <botlish_fn_28+0x81>
    2e4e:	mov    r12,rdi
    2e51:	mov    rdx,rbx
    2e54:	mov    rsi,r15
    2e57:	call   2e5c <botlish_fn_28+0x6c>
			2e58: R_X86_64_PLT32	rt_int_cmp-0x4
    2e5c:	mov    ecx,0x2
    2e61:	test   rax,rax
    2e64:	cmovge rcx,QWORD PTR [rip+0x254]        # 30c0 <botlish_fn_28+0x2d0>
    2e6c:	jmp    2e87 <botlish_fn_28+0x97>
    2e71:	mov    r12,rdi
    2e74:	mov    ecx,0x2
    2e79:	mov    rsi,r15
    2e7c:	cmp    rsi,rbx
    2e7f:	cmovge rcx,QWORD PTR [rip+0x239]        # 30c0 <botlish_fn_28+0x2d0>
    2e87:	cmp    rcx,0x6
    2e8b:	je     3092 <botlish_fn_28+0x2a2>
    2e91:	mov    rcx,r14
    2e94:	mov    rdx,r13
    2e97:	mov    rsi,r15
    2e9a:	mov    rdi,r12
    2e9d:	call   2ea2 <botlish_fn_28+0xb2>
			2e9e: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    2ea2:	mov    rcx,rax
    2ea5:	mov    QWORD PTR [rsp+0x40],rax
    2eaa:	test   rax,rcx
    2ead:	je     2edd <botlish_fn_28+0xed>
    2eb3:	mov    rdx,QWORD PTR [rsp+0x20]
    2eb8:	mov    QWORD PTR [rsp+0x38],rdx
    2ebd:	mov    rcx,QWORD PTR [rsp+0x28]
    2ec2:	mov    QWORD PTR [rsp+0x30],rcx
    2ec7:	mov    rsi,QWORD PTR [rsp+0x40]
    2ecc:	mov    rdi,r12
    2ecf:	call   2ed4 <botlish_fn_28+0xe4>
			2ed0: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    2ed4:	test   rax,rax
    2ed7:	jne    2f05 <botlish_fn_28+0x115>
    2edd:	xor    rax,rax
    2ee0:	mov    rbx,QWORD PTR [rsp+0x50]
    2ee5:	mov    r12,QWORD PTR [rsp+0x58]
    2eea:	mov    r13,QWORD PTR [rsp+0x60]
    2eef:	mov    r14,QWORD PTR [rsp+0x68]
    2ef4:	mov    r15,QWORD PTR [rsp+0x70]
    2ef9:	add    rsp,0x80
    2f00:	mov    rsp,rbp
    2f03:	pop    rbp
    2f04:	ret
    2f05:	cmp    rax,0x6
    2f09:	je     3013 <botlish_fn_28+0x223>
    2f0f:	mov    r9,QWORD PTR [r12+0x10]
    2f14:	mov    r8,QWORD PTR [r9+0xd0]
    2f1b:	mov    rcx,QWORD PTR [rsp+0x30]
    2f20:	mov    rdx,QWORD PTR [rsp+0x38]
    2f25:	mov    rsi,QWORD PTR [rsp+0x40]
    2f2a:	mov    rdi,r12
    2f2d:	call   2f32 <botlish_fn_28+0x142>
			2f2e: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f32:	cmp    rax,0x6
    2f36:	je     3009 <botlish_fn_28+0x219>
    2f3c:	mov    r11,QWORD PTR [r12+0x10]
    2f41:	mov    r8,QWORD PTR [r11+0xd8]
    2f48:	mov    rcx,QWORD PTR [rsp+0x30]
    2f4d:	mov    rdx,QWORD PTR [rsp+0x38]
    2f52:	mov    rsi,QWORD PTR [rsp+0x40]
    2f57:	mov    rdi,r12
    2f5a:	call   2f5f <botlish_fn_28+0x16f>
			2f5b: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f5f:	cmp    rax,0x6
    2f63:	je     2fff <botlish_fn_28+0x20f>
    2f69:	mov    rax,QWORD PTR [r12+0x10]
    2f6e:	mov    r8,QWORD PTR [rax+0xa8]
    2f75:	mov    rcx,QWORD PTR [rsp+0x30]
    2f7a:	mov    rdx,QWORD PTR [rsp+0x38]
    2f7f:	mov    rsi,QWORD PTR [rsp+0x40]
    2f84:	mov    rdi,r12
    2f87:	call   2f8c <botlish_fn_28+0x19c>
			2f88: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f8c:	cmp    rax,0x6
    2f90:	je     2ff5 <botlish_fn_28+0x205>
    2f96:	mov    rax,QWORD PTR [r12+0x10]
    2f9b:	mov    r8,QWORD PTR [rax+0xe0]
    2fa2:	mov    rcx,QWORD PTR [rsp+0x30]
    2fa7:	mov    rdx,QWORD PTR [rsp+0x38]
    2fac:	mov    rsi,QWORD PTR [rsp+0x40]
    2fb1:	mov    rdi,r12
    2fb4:	call   2fb9 <botlish_fn_28+0x1c9>
			2fb5: R_X86_64_PLT32	rt_str_region_eq-0x4
    2fb9:	cmp    rax,0x6
    2fbd:	je     2feb <botlish_fn_28+0x1fb>
    2fc3:	mov    rax,QWORD PTR [r12+0x10]
    2fc8:	mov    r8,QWORD PTR [rax+0xe8]
    2fcf:	mov    rcx,QWORD PTR [rsp+0x30]
    2fd4:	mov    rdx,QWORD PTR [rsp+0x38]
    2fd9:	mov    rsi,QWORD PTR [rsp+0x40]
    2fde:	mov    rdi,r12
    2fe1:	call   2fe6 <botlish_fn_28+0x1f6>
			2fe2: R_X86_64_PLT32	rt_str_region_eq-0x4
    2fe6:	jmp    3018 <botlish_fn_28+0x228>
    2feb:	mov    eax,0x6
    2ff0:	jmp    3018 <botlish_fn_28+0x228>
    2ff5:	mov    eax,0x6
    2ffa:	jmp    3018 <botlish_fn_28+0x228>
    2fff:	mov    eax,0x6
    3004:	jmp    3018 <botlish_fn_28+0x228>
    3009:	mov    eax,0x6
    300e:	jmp    3018 <botlish_fn_28+0x228>
    3013:	mov    eax,0x6
    3018:	cmp    rax,0x6
    301c:	je     302a <botlish_fn_28+0x23a>
    3022:	mov    rax,r15
    3025:	jmp    3095 <botlish_fn_28+0x2a5>
    302a:	mov    QWORD PTR [rsp+0x18],0x3
    3033:	mov    rsi,r15
    3036:	test   rsi,0x1
    303d:	je     3063 <botlish_fn_28+0x273>
    3043:	mov    rsi,r15
    3046:	mov    rax,rsi
    3049:	add    rax,0x2
    304d:	seto   cl
    3050:	test   cl,cl
    3052:	jne    3063 <botlish_fn_28+0x273>
    3058:	mov    rsi,rax
    305b:	mov    r15,rax
    305e:	jmp    3079 <botlish_fn_28+0x289>
    3063:	mov    edx,0x3
    3068:	mov    rsi,r15
    306b:	mov    rdi,r12
    306e:	call   3073 <botlish_fn_28+0x283>
			306f: R_X86_64_PLT32	rt_int_add-0x4
    3073:	mov    rsi,rax
    3076:	mov    r15,rax
    3079:	mov    QWORD PTR [rsp],rsi
    307d:	mov    QWORD PTR [rsp+0x8],rbx
    3082:	mov    QWORD PTR [rsp+0x10],r13
    3087:	mov    rsi,r15
    308a:	mov    rdi,r12
    308d:	jmp    2e39 <botlish_fn_28+0x49>
    3092:	mov    rax,r15
    3095:	mov    rbx,QWORD PTR [rsp+0x50]
    309a:	mov    r12,QWORD PTR [rsp+0x58]
    309f:	mov    r13,QWORD PTR [rsp+0x60]
    30a4:	mov    r14,QWORD PTR [rsp+0x68]
    30a9:	mov    r15,QWORD PTR [rsp+0x70]
    30ae:	add    rsp,0x80
    30b5:	mov    rsp,rbp
    30b8:	pop    rbp
    30b9:	ret
    30ba:	add    BYTE PTR [rax],al
    30bc:	add    BYTE PTR [rax],al
    30be:	add    BYTE PTR [rax],al
    30c0:	(bad)
    30c1:	add    BYTE PTR [rax],al
    30c3:	add    BYTE PTR [rax],al
    30c5:	add    BYTE PTR [rax],al
	...

00000000000030c8 <botlish_entry_28: scan_local<generic>>:
    30c8:	push   rbp
    30c9:	mov    rbp,rsp
    30cc:	mov    rsi,QWORD PTR [rdx]
    30cf:	mov    r8,QWORD PTR [rdx+0x8]
    30d3:	mov    rcx,QWORD PTR [rdx+0x10]
    30d7:	mov    rdx,r8
    30da:	call   30df <botlish_entry_28+0x17>
			30db: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    30df:	mov    rsp,rbp
    30e2:	pop    rbp
    30e3:	ret
    30e4:	add    BYTE PTR [rax],al
	...

00000000000030e8 <botlish_fn_29: scan_label<generic>>:
    30e8:	push   rbp
    30e9:	mov    rbp,rsp
    30ec:	sub    rsp,0x80
    30f3:	mov    QWORD PTR [rsp+0x50],rbx
    30f8:	mov    QWORD PTR [rsp+0x58],r12
    30fd:	mov    QWORD PTR [rsp+0x60],r13
    3102:	mov    QWORD PTR [rsp+0x68],r14
    3107:	mov    QWORD PTR [rsp+0x70],r15
    310c:	mov    QWORD PTR [rsp+0x18],0x0
    3115:	mov    QWORD PTR [rsp],rsi
    3119:	mov    r15,rsi
    311c:	mov    QWORD PTR [rsp+0x8],rdx
    3121:	mov    QWORD PTR [rsp+0x10],rcx
    3126:	mov    r13,rcx
    3129:	lea    r14,[rsp+0x20]
    312e:	mov    rbx,rdx
    3131:	mov    rax,rsi
    3134:	and    rax,rbx
    3137:	mov    r15,rsi
    313a:	test   rax,0x1
    3140:	jne    3169 <botlish_fn_29+0x81>
    3146:	mov    r12,rdi
    3149:	mov    rdx,rbx
    314c:	mov    rsi,r15
    314f:	call   3154 <botlish_fn_29+0x6c>
			3150: R_X86_64_PLT32	rt_int_cmp-0x4
    3154:	mov    ecx,0x2
    3159:	test   rax,rax
    315c:	cmovge rcx,QWORD PTR [rip+0x174]        # 32d8 <botlish_fn_29+0x1f0>
    3164:	jmp    317f <botlish_fn_29+0x97>
    3169:	mov    r12,rdi
    316c:	mov    ecx,0x2
    3171:	mov    rsi,r15
    3174:	cmp    rsi,rbx
    3177:	cmovge rcx,QWORD PTR [rip+0x159]        # 32d8 <botlish_fn_29+0x1f0>
    317f:	cmp    rcx,0x6
    3183:	je     32ab <botlish_fn_29+0x1c3>
    3189:	mov    rcx,r14
    318c:	mov    rdx,r13
    318f:	mov    rsi,r15
    3192:	mov    rdi,r12
    3195:	call   319a <botlish_fn_29+0xb2>
			3196: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    319a:	test   rax,rax
    319d:	mov    QWORD PTR [rsp+0x40],rax
    31a2:	je     31d2 <botlish_fn_29+0xea>
    31a8:	mov    rdx,QWORD PTR [rsp+0x20]
    31ad:	mov    QWORD PTR [rsp+0x38],rdx
    31b2:	mov    rcx,QWORD PTR [rsp+0x28]
    31b7:	mov    QWORD PTR [rsp+0x30],rcx
    31bc:	mov    rsi,QWORD PTR [rsp+0x40]
    31c1:	mov    rdi,r12
    31c4:	call   31c9 <botlish_fn_29+0xe1>
			31c5: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    31c9:	test   rax,rax
    31cc:	jne    31fa <botlish_fn_29+0x112>
    31d2:	xor    rax,rax
    31d5:	mov    rbx,QWORD PTR [rsp+0x50]
    31da:	mov    r12,QWORD PTR [rsp+0x58]
    31df:	mov    r13,QWORD PTR [rsp+0x60]
    31e4:	mov    r14,QWORD PTR [rsp+0x68]
    31e9:	mov    r15,QWORD PTR [rsp+0x70]
    31ee:	add    rsp,0x80
    31f5:	mov    rsp,rbp
    31f8:	pop    rbp
    31f9:	ret
    31fa:	cmp    rax,0x6
    31fe:	je     322c <botlish_fn_29+0x144>
    3204:	mov    rax,QWORD PTR [r12+0x10]
    3209:	mov    r8,QWORD PTR [rax+0xe8]
    3210:	mov    rcx,QWORD PTR [rsp+0x30]
    3215:	mov    rdx,QWORD PTR [rsp+0x38]
    321a:	mov    rsi,QWORD PTR [rsp+0x40]
    321f:	mov    rdi,r12
    3222:	call   3227 <botlish_fn_29+0x13f>
			3223: R_X86_64_PLT32	rt_str_region_eq-0x4
    3227:	jmp    3231 <botlish_fn_29+0x149>
    322c:	mov    eax,0x6
    3231:	cmp    rax,0x6
    3235:	je     3243 <botlish_fn_29+0x15b>
    323b:	mov    rax,r15
    323e:	jmp    32ae <botlish_fn_29+0x1c6>
    3243:	mov    QWORD PTR [rsp+0x18],0x3
    324c:	mov    rsi,r15
    324f:	test   rsi,0x1
    3256:	je     327c <botlish_fn_29+0x194>
    325c:	mov    rsi,r15
    325f:	mov    rax,rsi
    3262:	add    rax,0x2
    3266:	seto   cl
    3269:	test   cl,cl
    326b:	jne    327c <botlish_fn_29+0x194>
    3271:	mov    rsi,rax
    3274:	mov    r15,rax
    3277:	jmp    3292 <botlish_fn_29+0x1aa>
    327c:	mov    edx,0x3
    3281:	mov    rsi,r15
    3284:	mov    rdi,r12
    3287:	call   328c <botlish_fn_29+0x1a4>
			3288: R_X86_64_PLT32	rt_int_add-0x4
    328c:	mov    rsi,rax
    328f:	mov    r15,rax
    3292:	mov    QWORD PTR [rsp],rsi
    3296:	mov    QWORD PTR [rsp+0x8],rbx
    329b:	mov    QWORD PTR [rsp+0x10],r13
    32a0:	mov    rsi,r15
    32a3:	mov    rdi,r12
    32a6:	jmp    3131 <botlish_fn_29+0x49>
    32ab:	mov    rax,r15
    32ae:	mov    rbx,QWORD PTR [rsp+0x50]
    32b3:	mov    r12,QWORD PTR [rsp+0x58]
    32b8:	mov    r13,QWORD PTR [rsp+0x60]
    32bd:	mov    r14,QWORD PTR [rsp+0x68]
    32c2:	mov    r15,QWORD PTR [rsp+0x70]
    32c7:	add    rsp,0x80
    32ce:	mov    rsp,rbp
    32d1:	pop    rbp
    32d2:	ret
    32d3:	add    BYTE PTR [rax],al
    32d5:	add    BYTE PTR [rax],al
    32d7:	add    BYTE PTR [rsi],al
    32d9:	add    BYTE PTR [rax],al
    32db:	add    BYTE PTR [rax],al
    32dd:	add    BYTE PTR [rax],al
	...

00000000000032e0 <botlish_entry_29: scan_label<generic>>:
    32e0:	push   rbp
    32e1:	mov    rbp,rsp
    32e4:	mov    rsi,QWORD PTR [rdx]
    32e7:	mov    r8,QWORD PTR [rdx+0x8]
    32eb:	mov    rcx,QWORD PTR [rdx+0x10]
    32ef:	mov    rdx,r8
    32f2:	call   32f7 <botlish_entry_29+0x17>
			32f3: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_label<generic>
    32f7:	mov    rsp,rbp
    32fa:	pop    rbp
    32fb:	ret
    32fc:	add    BYTE PTR [rax],al
	...

0000000000003300 <botlish_fn_30: scan_alpha<generic>>:
    3300:	push   rbp
    3301:	mov    rbp,rsp
    3304:	sub    rsp,0x60
    3308:	mov    QWORD PTR [rsp+0x30],rbx
    330d:	mov    QWORD PTR [rsp+0x38],r12
    3312:	mov    QWORD PTR [rsp+0x40],r13
    3317:	mov    QWORD PTR [rsp+0x48],r14
    331c:	mov    QWORD PTR [rsp+0x50],r15
    3321:	mov    r15,rdi
    3324:	mov    QWORD PTR [rsp+0x18],0x0
    332d:	mov    QWORD PTR [rsp],rsi
    3331:	mov    r14,rsi
    3334:	mov    QWORD PTR [rsp+0x8],rdx
    3339:	mov    QWORD PTR [rsp+0x10],rcx
    333e:	mov    r12,rcx
    3341:	lea    r13,[rsp+0x20]
    3346:	mov    rbx,rdx
    3349:	mov    rax,rsi
    334c:	and    rax,rbx
    334f:	mov    r14,rsi
    3352:	test   rax,0x1
    3358:	jne    3381 <botlish_fn_30+0x81>
    335e:	mov    rdx,rbx
    3361:	mov    rsi,r14
    3364:	mov    rdi,r15
    3367:	call   336c <botlish_fn_30+0x6c>
			3368: R_X86_64_PLT32	rt_int_cmp-0x4
    336c:	mov    ecx,0x2
    3371:	test   rax,rax
    3374:	cmovge rcx,QWORD PTR [rip+0x11c]        # 3498 <botlish_fn_30+0x198>
    337c:	jmp    3394 <botlish_fn_30+0x94>
    3381:	mov    ecx,0x2
    3386:	mov    rsi,r14
    3389:	cmp    rsi,rbx
    338c:	cmovge rcx,QWORD PTR [rip+0x104]        # 3498 <botlish_fn_30+0x198>
    3394:	cmp    rcx,0x6
    3398:	je     3472 <botlish_fn_30+0x172>
    339e:	mov    rcx,r13
    33a1:	mov    rdx,r12
    33a4:	mov    rsi,r14
    33a7:	mov    rdi,r15
    33aa:	call   33af <botlish_fn_30+0xaf>
			33ab: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    33af:	test   rax,rax
    33b2:	mov    rsi,rax
    33b5:	je     33d6 <botlish_fn_30+0xd6>
    33bb:	mov    rdx,QWORD PTR [rsp+0x20]
    33c0:	mov    rcx,QWORD PTR [rsp+0x28]
    33c5:	mov    rdi,r15
    33c8:	call   33cd <botlish_fn_30+0xcd>
			33c9: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    33cd:	test   rax,rax
    33d0:	jne    33fb <botlish_fn_30+0xfb>
    33d6:	xor    rax,rax
    33d9:	mov    rbx,QWORD PTR [rsp+0x30]
    33de:	mov    r12,QWORD PTR [rsp+0x38]
    33e3:	mov    r13,QWORD PTR [rsp+0x40]
    33e8:	mov    r14,QWORD PTR [rsp+0x48]
    33ed:	mov    r15,QWORD PTR [rsp+0x50]
    33f2:	add    rsp,0x60
    33f6:	mov    rsp,rbp
    33f9:	pop    rbp
    33fa:	ret
    33fb:	cmp    rax,0x6
    33ff:	je     340d <botlish_fn_30+0x10d>
    3405:	mov    rax,r14
    3408:	jmp    3475 <botlish_fn_30+0x175>
    340d:	mov    QWORD PTR [rsp+0x18],0x3
    3416:	mov    rsi,r14
    3419:	test   rsi,0x1
    3420:	je     3446 <botlish_fn_30+0x146>
    3426:	mov    rsi,r14
    3429:	mov    rcx,rsi
    342c:	add    rcx,0x2
    3430:	seto   al
    3433:	test   al,al
    3435:	jne    3446 <botlish_fn_30+0x146>
    343b:	mov    rsi,rcx
    343e:	mov    r14,rcx
    3441:	jmp    345c <botlish_fn_30+0x15c>
    3446:	mov    edx,0x3
    344b:	mov    rsi,r14
    344e:	mov    rdi,r15
    3451:	call   3456 <botlish_fn_30+0x156>
			3452: R_X86_64_PLT32	rt_int_add-0x4
    3456:	mov    rsi,rax
    3459:	mov    r14,rax
    345c:	mov    QWORD PTR [rsp],rsi
    3460:	mov    QWORD PTR [rsp+0x8],rbx
    3465:	mov    QWORD PTR [rsp+0x10],r12
    346a:	mov    rsi,r14
    346d:	jmp    3349 <botlish_fn_30+0x49>
    3472:	mov    rax,r14
    3475:	mov    rbx,QWORD PTR [rsp+0x30]
    347a:	mov    r12,QWORD PTR [rsp+0x38]
    347f:	mov    r13,QWORD PTR [rsp+0x40]
    3484:	mov    r14,QWORD PTR [rsp+0x48]
    3489:	mov    r15,QWORD PTR [rsp+0x50]
    348e:	add    rsp,0x60
    3492:	mov    rsp,rbp
    3495:	pop    rbp
    3496:	ret
    3497:	add    BYTE PTR [rsi],al
    3499:	add    BYTE PTR [rax],al
    349b:	add    BYTE PTR [rax],al
    349d:	add    BYTE PTR [rax],al
	...

00000000000034a0 <botlish_entry_30: scan_alpha<generic>>:
    34a0:	push   rbp
    34a1:	mov    rbp,rsp
    34a4:	mov    rsi,QWORD PTR [rdx]
    34a7:	mov    r8,QWORD PTR [rdx+0x8]
    34ab:	mov    rcx,QWORD PTR [rdx+0x10]
    34af:	mov    rdx,r8
    34b2:	call   34b7 <botlish_entry_30+0x17>
			34b3: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_alpha<generic>
    34b7:	mov    rsp,rbp
    34ba:	pop    rbp
    34bb:	ret
    34bc:	add    BYTE PTR [rax],al
	...

00000000000034c0 <botlish_fn_31: tld_ok<generic>>:
    34c0:	push   rbp
    34c1:	mov    rbp,rsp
    34c4:	sub    rsp,0x40
    34c8:	mov    QWORD PTR [rsp+0x20],rbx
    34cd:	mov    QWORD PTR [rsp+0x28],r12
    34d2:	mov    QWORD PTR [rsp+0x30],r13
    34d7:	mov    QWORD PTR [rsp+0x38],r14
    34dc:	mov    r12,rdi
    34df:	mov    QWORD PTR [rsp],rsi
    34e3:	mov    rdi,rsi
    34e6:	mov    QWORD PTR [rsp+0x8],rdx
    34eb:	mov    r14,rdx
    34ee:	mov    QWORD PTR [rsp+0x10],rcx
    34f3:	mov    rbx,rdi
    34f6:	mov    rdx,r14
    34f9:	mov    rsi,rbx
    34fc:	mov    rdi,r12
    34ff:	call   3504 <botlish_fn_31+0x44>
			3500: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_alpha<generic>
    3504:	mov    rcx,rax
    3507:	mov    r13,rax
    350a:	test   rax,rcx
    350d:	jne    3533 <botlish_fn_31+0x73>
    3513:	xor    rax,rax
    3516:	mov    rbx,QWORD PTR [rsp+0x20]
    351b:	mov    r12,QWORD PTR [rsp+0x28]
    3520:	mov    r13,QWORD PTR [rsp+0x30]
    3525:	mov    r14,QWORD PTR [rsp+0x38]
    352a:	add    rsp,0x40
    352e:	mov    rsp,rbp
    3531:	pop    rbp
    3532:	ret
    3533:	mov    rax,r13
    3536:	mov    QWORD PTR [rsp+0x8],rax
    353b:	mov    rdx,r14
    353e:	and    rax,rdx
    3541:	test   rax,0x1
    3547:	jne    3570 <botlish_fn_31+0xb0>
    354d:	mov    rsi,r13
    3550:	mov    rdi,r12
    3553:	call   3558 <botlish_fn_31+0x98>
			3554: R_X86_64_PLT32	rt_int_cmp-0x4
    3558:	mov    ecx,0x2
    355d:	test   rax,rax
    3560:	cmove  rcx,QWORD PTR [rip+0xe0]        # 3648 <botlish_fn_31+0x188>
    3568:	mov    rax,r13
    356b:	jmp    3583 <botlish_fn_31+0xc3>
    3570:	mov    ecx,0x2
    3575:	mov    rax,r13
    3578:	cmp    rax,rdx
    357b:	cmove  rcx,QWORD PTR [rip+0xc5]        # 3648 <botlish_fn_31+0x188>
    3583:	cmp    rcx,0x6
    3587:	je     359a <botlish_fn_31+0xda>
    358d:	mov    ecx,0x2
    3592:	mov    rax,rcx
    3595:	jmp    3627 <botlish_fn_31+0x167>
    359a:	mov    rcx,rax
    359d:	and    rcx,rbx
    35a0:	test   rcx,0x1
    35a7:	jne    35b8 <botlish_fn_31+0xf8>
    35ad:	mov    rdx,rbx
    35b0:	mov    rsi,rax
    35b3:	jmp    35d9 <botlish_fn_31+0x119>
    35b8:	mov    rcx,rax
    35bb:	sub    rcx,rbx
    35be:	mov    rdi,rbx
    35c1:	mov    r13,rax
    35c4:	seto   al
    35c7:	lea    rsi,[rcx+0x1]
    35cb:	test   al,al
    35cd:	je     35e4 <botlish_fn_31+0x124>
    35d3:	mov    rdx,rdi
    35d6:	mov    rsi,r13
    35d9:	mov    rdi,r12
    35dc:	call   35e1 <botlish_fn_31+0x121>
			35dd: R_X86_64_PLT32	rt_int_sub-0x4
    35e1:	mov    rsi,rax
    35e4:	test   rsi,0x1
    35eb:	jne    3616 <botlish_fn_31+0x156>
    35f1:	mov    edx,0x5
    35f6:	mov    rdi,r12
    35f9:	call   35fe <botlish_fn_31+0x13e>
			35fa: R_X86_64_PLT32	rt_int_cmp-0x4
    35fe:	mov    ecx,0x2
    3603:	test   rax,rax
    3606:	mov    rax,rcx
    3609:	cmovge rax,QWORD PTR [rip+0x37]        # 3648 <botlish_fn_31+0x188>
    3611:	jmp    3627 <botlish_fn_31+0x167>
    3616:	mov    eax,0x2
    361b:	cmp    rsi,0x5
    361f:	cmovge rax,QWORD PTR [rip+0x21]        # 3648 <botlish_fn_31+0x188>
    3627:	mov    rbx,QWORD PTR [rsp+0x20]
    362c:	mov    r12,QWORD PTR [rsp+0x28]
    3631:	mov    r13,QWORD PTR [rsp+0x30]
    3636:	mov    r14,QWORD PTR [rsp+0x38]
    363b:	add    rsp,0x40
    363f:	mov    rsp,rbp
    3642:	pop    rbp
    3643:	ret
    3644:	add    BYTE PTR [rax],al
    3646:	add    BYTE PTR [rax],al
    3648:	(bad)
    3649:	add    BYTE PTR [rax],al
    364b:	add    BYTE PTR [rax],al
    364d:	add    BYTE PTR [rax],al
	...

0000000000003650 <botlish_entry_31: tld_ok<generic>>:
    3650:	push   rbp
    3651:	mov    rbp,rsp
    3654:	mov    rsi,QWORD PTR [rdx]
    3657:	mov    r8,QWORD PTR [rdx+0x8]
    365b:	mov    rcx,QWORD PTR [rdx+0x10]
    365f:	mov    rdx,r8
    3662:	call   3667 <botlish_entry_31+0x17>
			3663: R_X86_64_PLT32	botlish_fn_31-0x4 ; tld_ok<generic>
    3667:	mov    rsp,rbp
    366a:	pop    rbp
    366b:	ret
    366c:	add    BYTE PTR [rax],al
	...

0000000000003670 <botlish_fn_32: domain_loop<generic>>:
    3670:	push   rbp
    3671:	mov    rbp,rsp
    3674:	sub    rsp,0x70
    3678:	mov    QWORD PTR [rsp+0x40],rbx
    367d:	mov    QWORD PTR [rsp+0x48],r12
    3682:	mov    QWORD PTR [rsp+0x50],r13
    3687:	mov    QWORD PTR [rsp+0x58],r14
    368c:	mov    QWORD PTR [rsp+0x60],r15
    3691:	mov    QWORD PTR [rsp+0x18],0x0
    369a:	mov    QWORD PTR [rsp],rsi
    369e:	mov    QWORD PTR [rsp+0x8],rdx
    36a3:	mov    QWORD PTR [rsp+0x10],rcx
    36a8:	lea    rbx,[rsp+0x20]
    36ad:	mov    r12,rdi
    36b0:	mov    r13,rcx
    36b3:	mov    r14,rdx
    36b6:	mov    QWORD PTR [rsp+0x30],rsi
    36bb:	mov    rcx,r13
    36be:	mov    rdx,r14
    36c1:	mov    rsi,QWORD PTR [rsp+0x30]
    36c6:	mov    rdi,r12
    36c9:	call   36ce <botlish_fn_32+0x5e>
			36ca: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_label<generic>
    36ce:	mov    rcx,rax
    36d1:	mov    r15,rax
    36d4:	test   rax,rcx
    36d7:	je     382e <botlish_fn_32+0x1be>
    36dd:	mov    rax,r15
    36e0:	mov    QWORD PTR [rsp],rax
    36e4:	mov    rdx,QWORD PTR [rsp+0x30]
    36e9:	and    rax,rdx
    36ec:	test   rax,0x1
    36f2:	jne    3718 <botlish_fn_32+0xa8>
    36f8:	mov    rsi,r15
    36fb:	mov    rdi,r12
    36fe:	call   3703 <botlish_fn_32+0x93>
			36ff: R_X86_64_PLT32	rt_int_cmp-0x4
    3703:	mov    ecx,0x2
    3708:	test   rax,rax
    370b:	cmove  rcx,QWORD PTR [rip+0x19d]        # 38b0 <botlish_fn_32+0x240>
    3713:	jmp    3728 <botlish_fn_32+0xb8>
    3718:	mov    ecx,0x2
    371d:	cmp    r15,rdx
    3720:	cmove  rcx,QWORD PTR [rip+0x188]        # 38b0 <botlish_fn_32+0x240>
    3728:	cmp    rcx,0x6
    372c:	je     3884 <botlish_fn_32+0x214>
    3732:	mov    rax,r15
    3735:	and    rax,r14
    3738:	test   rax,0x1
    373e:	jne    3767 <botlish_fn_32+0xf7>
    3744:	mov    rdx,r14
    3747:	mov    rsi,r15
    374a:	mov    rdi,r12
    374d:	call   3752 <botlish_fn_32+0xe2>
			374e: R_X86_64_PLT32	rt_int_cmp-0x4
    3752:	mov    ecx,0x2
    3757:	test   rax,rax
    375a:	cmovge rcx,QWORD PTR [rip+0x14e]        # 38b0 <botlish_fn_32+0x240>
    3762:	jmp    3777 <botlish_fn_32+0x107>
    3767:	mov    ecx,0x2
    376c:	cmp    r15,r14
    376f:	cmovge rcx,QWORD PTR [rip+0x139]        # 38b0 <botlish_fn_32+0x240>
    3777:	cmp    rcx,0x6
    377b:	je     3875 <botlish_fn_32+0x205>
    3781:	mov    rcx,rbx
    3784:	mov    rdx,r13
    3787:	mov    rsi,r15
    378a:	mov    rdi,r12
    378d:	call   3792 <botlish_fn_32+0x122>
			378e: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    3792:	test   rax,rax
    3795:	je     382e <botlish_fn_32+0x1be>
    379b:	mov    rdx,QWORD PTR [rsp+0x20]
    37a0:	mov    rcx,QWORD PTR [rsp+0x28]
    37a5:	mov    rsi,QWORD PTR [r12+0x10]
    37aa:	mov    r8,QWORD PTR [rsi+0xd0]
    37b1:	mov    rsi,rax
    37b4:	mov    rdi,r12
    37b7:	call   37bc <botlish_fn_32+0x14c>
			37b8: R_X86_64_PLT32	rt_str_region_eq-0x4
    37bc:	cmp    rax,0x6
    37c0:	je     37d2 <botlish_fn_32+0x162>
    37c6:	mov    r14,0xffffffffffffffff
    37cd:	jmp    387c <botlish_fn_32+0x20c>
    37d2:	mov    QWORD PTR [rsp+0x18],0x3
    37db:	test   r15,0x1
    37e2:	je     37fa <botlish_fn_32+0x18a>
    37e8:	mov    rdx,r15
    37eb:	add    rdx,0x2
    37ef:	seto   al
    37f2:	test   al,al
    37f4:	je     380d <botlish_fn_32+0x19d>
    37fa:	mov    edx,0x3
    37ff:	mov    rsi,r15
    3802:	mov    rdi,r12
    3805:	call   380a <botlish_fn_32+0x19a>
			3806: R_X86_64_PLT32	rt_int_add-0x4
    380a:	mov    rdx,rax
    380d:	mov    QWORD PTR [rsp],rdx
    3811:	mov    r15,rdx
    3814:	mov    rcx,r13
    3817:	mov    rdx,r14
    381a:	mov    rsi,r15
    381d:	mov    rdi,r12
    3820:	call   3825 <botlish_fn_32+0x1b5>
			3821: R_X86_64_PLT32	botlish_fn_31-0x4 ; tld_ok<generic>
    3825:	test   rax,rax
    3828:	jne    3853 <botlish_fn_32+0x1e3>
    382e:	xor    rax,rax
    3831:	mov    rbx,QWORD PTR [rsp+0x40]
    3836:	mov    r12,QWORD PTR [rsp+0x48]
    383b:	mov    r13,QWORD PTR [rsp+0x50]
    3840:	mov    r14,QWORD PTR [rsp+0x58]
    3845:	mov    r15,QWORD PTR [rsp+0x60]
    384a:	add    rsp,0x70
    384e:	mov    rsp,rbp
    3851:	pop    rbp
    3852:	ret
    3853:	cmp    rax,0x6
    3857:	je     387c <botlish_fn_32+0x20c>
    385d:	mov    QWORD PTR [rsp],r15
    3861:	mov    QWORD PTR [rsp+0x8],r14
    3866:	mov    QWORD PTR [rsp+0x10],r13
    386b:	mov    QWORD PTR [rsp+0x30],r15
    3870:	jmp    36bb <botlish_fn_32+0x4b>
    3875:	mov    r14,0xffffffffffffffff
    387c:	mov    rax,r14
    387f:	jmp    388b <botlish_fn_32+0x21b>
    3884:	mov    rax,0xffffffffffffffff
    388b:	mov    rbx,QWORD PTR [rsp+0x40]
    3890:	mov    r12,QWORD PTR [rsp+0x48]
    3895:	mov    r13,QWORD PTR [rsp+0x50]
    389a:	mov    r14,QWORD PTR [rsp+0x58]
    389f:	mov    r15,QWORD PTR [rsp+0x60]
    38a4:	add    rsp,0x70
    38a8:	mov    rsp,rbp
    38ab:	pop    rbp
    38ac:	ret
    38ad:	add    BYTE PTR [rax],al
    38af:	add    BYTE PTR [rsi],al
    38b1:	add    BYTE PTR [rax],al
    38b3:	add    BYTE PTR [rax],al
    38b5:	add    BYTE PTR [rax],al
	...

00000000000038b8 <botlish_entry_32: domain_loop<generic>>:
    38b8:	push   rbp
    38b9:	mov    rbp,rsp
    38bc:	mov    rsi,QWORD PTR [rdx]
    38bf:	mov    r8,QWORD PTR [rdx+0x8]
    38c3:	mov    rcx,QWORD PTR [rdx+0x10]
    38c7:	mov    rdx,r8
    38ca:	call   38cf <botlish_entry_32+0x17>
			38cb: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    38cf:	mov    rsp,rbp
    38d2:	pop    rbp
    38d3:	ret

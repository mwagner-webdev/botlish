; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 14898  (per function: 1172 39 289 617 74 74 74 125 125 155 125 103 378 624 448 684 504 681 769 262 804 564 468 452 644 681 769 262 804 564 468 452 644)
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
     b3e:	sub    rsp,0x30
     b42:	mov    QWORD PTR [rsp+0x10],rbx
     b47:	mov    QWORD PTR [rsp+0x18],r12
     b4c:	mov    QWORD PTR [rsp+0x20],r13
     b51:	mov    QWORD PTR [rsp+0x28],r14
     b56:	mov    r12,rdi
     b59:	mov    QWORD PTR [rsp],rsi
     b5d:	mov    r14,rsi
     b60:	mov    QWORD PTR [rsp+0x8],rdx
     b65:	mov    rbx,rdx
     b68:	mov    rsi,r14
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
     b94:	jb     bb9 <botlish_fn_12+0x7f>
     b9a:	mov    rdx,rax
     b9d:	mov    rsi,rbx
     ba0:	mov    rdi,r12
     ba3:	call   ba8 <botlish_fn_12+0x6e>
			ba4: R_X86_64_PLT32	rt_list_get-0x4
     ba8:	test   rax,rax
     bab:	je     c4e <botlish_fn_12+0x114>
     bb1:	mov    rsi,rax
     bb4:	jmp    bc1 <botlish_fn_12+0x87>
     bb9:	mov    rax,QWORD PTR [rbx+0x10]
     bbd:	mov    rsi,QWORD PTR [rax+rcx*8]
     bc1:	mov    QWORD PTR [rsp],rsi
     bc5:	mov    r13,rsi
     bc8:	mov    edx,0x21
     bcd:	mov    rsi,r14
     bd0:	mov    rdi,r12
     bd3:	call   bd8 <botlish_fn_12+0x9e>
			bd4: R_X86_64_PLT32	rt_int_mod-0x4
     bd8:	test   rax,rax
     bdb:	je     c4e <botlish_fn_12+0x114>
     be1:	test   rax,0x1
     be7:	jne    bf8 <botlish_fn_12+0xbe>
     bed:	mov    rdx,rax
     bf0:	mov    rsi,rbx
     bf3:	jmp    c11 <botlish_fn_12+0xd7>
     bf8:	mov    rdx,QWORD PTR [rbx+0x8]
     bfc:	mov    rcx,rax
     bff:	sar    rcx,1
     c02:	cmp    rcx,rdx
     c05:	jb     c2a <botlish_fn_12+0xf0>
     c0b:	mov    rdx,rax
     c0e:	mov    rsi,rbx
     c11:	mov    rdi,r12
     c14:	call   c19 <botlish_fn_12+0xdf>
			c15: R_X86_64_PLT32	rt_list_get-0x4
     c19:	test   rax,rax
     c1c:	je     c4e <botlish_fn_12+0x114>
     c22:	mov    rdx,rax
     c25:	jmp    c35 <botlish_fn_12+0xfb>
     c2a:	mov    rsi,rbx
     c2d:	mov    rax,QWORD PTR [rsi+0x10]
     c31:	mov    rdx,QWORD PTR [rax+rcx*8]
     c35:	mov    QWORD PTR [rsp+0x8],rdx
     c3a:	mov    rsi,r13
     c3d:	mov    rdi,r12
     c40:	call   c45 <botlish_fn_12+0x10b>
			c41: R_X86_64_PLT32	rt_str_cat-0x4
     c45:	test   rax,rax
     c48:	jne    c6e <botlish_fn_12+0x134>
     c4e:	xor    rax,rax
     c51:	mov    rbx,QWORD PTR [rsp+0x10]
     c56:	mov    r12,QWORD PTR [rsp+0x18]
     c5b:	mov    r13,QWORD PTR [rsp+0x20]
     c60:	mov    r14,QWORD PTR [rsp+0x28]
     c65:	add    rsp,0x30
     c69:	mov    rsp,rbp
     c6c:	pop    rbp
     c6d:	ret
     c6e:	mov    rbx,QWORD PTR [rsp+0x10]
     c73:	mov    r12,QWORD PTR [rsp+0x18]
     c78:	mov    r13,QWORD PTR [rsp+0x20]
     c7d:	mov    r14,QWORD PTR [rsp+0x28]
     c82:	add    rsp,0x30
     c86:	mov    rsp,rbp
     c89:	pop    rbp
     c8a:	ret

0000000000000c8b <botlish_entry_12: hex_pair<generic>>:
     c8b:	push   rbp
     c8c:	mov    rbp,rsp
     c8f:	mov    rsi,QWORD PTR [rdx]
     c92:	mov    rdx,QWORD PTR [rdx+0x8]
     c96:	call   c9b <botlish_entry_12+0x10>
			c97: R_X86_64_PLT32	botlish_fn_12-0x4 ; hex_pair<generic>
     c9b:	mov    rsp,rbp
     c9e:	pop    rbp
     c9f:	ret

0000000000000ca0 <botlish_fn_13: esc_bytes<generic>>:
     ca0:	push   rbp
     ca1:	mov    rbp,rsp
     ca4:	sub    rsp,0x70
     ca8:	mov    QWORD PTR [rsp+0x40],rbx
     cad:	mov    QWORD PTR [rsp+0x48],r12
     cb2:	mov    QWORD PTR [rsp+0x50],r13
     cb7:	mov    QWORD PTR [rsp+0x58],r14
     cbc:	mov    QWORD PTR [rsp+0x60],r15
     cc1:	mov    QWORD PTR [rsp+0x28],0x0
     cca:	mov    QWORD PTR [rsp],rsi
     cce:	mov    QWORD PTR [rsp+0x8],rdx
     cd3:	mov    r12,rdx
     cd6:	mov    QWORD PTR [rsp+0x10],rcx
     cdb:	mov    QWORD PTR [rsp+0x18],r8
     ce0:	mov    r15,r8
     ce3:	mov    rbx,rsi
     ce6:	mov    r14,rdi
     ce9:	mov    QWORD PTR [rsp+0x30],rcx
     cee:	mov    rsi,rbx
     cf1:	mov    rdi,r14
     cf4:	call   cf9 <botlish_fn_13+0x59>
			cf5: R_X86_64_PLT32	rt_list_len-0x4
     cf9:	mov    rcx,r12
     cfc:	and    rcx,rax
     cff:	mov    rdx,rax
     d02:	test   rcx,0x1
     d09:	jne    d2f <botlish_fn_13+0x8f>
     d0f:	mov    rsi,r12
     d12:	mov    rdi,r14
     d15:	call   d1a <botlish_fn_13+0x7a>
			d16: R_X86_64_PLT32	rt_int_cmp-0x4
     d1a:	mov    ecx,0x2
     d1f:	test   rax,rax
     d22:	cmovge rcx,QWORD PTR [rip+0x19e]        # ec8 <botlish_fn_13+0x228>
     d2a:	jmp    d3f <botlish_fn_13+0x9f>
     d2f:	mov    ecx,0x2
     d34:	cmp    r12,rdx
     d37:	cmovge rcx,QWORD PTR [rip+0x189]        # ec8 <botlish_fn_13+0x228>
     d3f:	cmp    rcx,0x6
     d43:	je     e9b <botlish_fn_13+0x1fb>
     d49:	mov    QWORD PTR [rsp+0x20],0x3
     d52:	test   r12,0x1
     d59:	je     d7c <botlish_fn_13+0xdc>
     d5f:	mov    rax,r12
     d62:	add    rax,0x2
     d66:	mov    rcx,rax
     d69:	seto   al
     d6c:	test   al,al
     d6e:	jne    d7c <botlish_fn_13+0xdc>
     d74:	mov    r13,rcx
     d77:	jmp    d92 <botlish_fn_13+0xf2>
     d7c:	mov    edx,0x3
     d81:	mov    rsi,r12
     d84:	mov    rdi,r14
     d87:	call   d8c <botlish_fn_13+0xec>
			d88: R_X86_64_PLT32	rt_int_add-0x4
     d8c:	mov    rcx,rax
     d8f:	mov    r13,rcx
     d92:	mov    QWORD PTR [rsp+0x8],r13
     d97:	mov    rax,QWORD PTR [r14+0x10]
     d9b:	mov    rsi,QWORD PTR [rax+0xa8]
     da2:	mov    QWORD PTR [rsp+0x20],rsi
     da7:	mov    QWORD PTR [rsp+0x38],rsi
     dac:	test   r12,0x1
     db3:	jne    dc1 <botlish_fn_13+0x121>
     db9:	mov    rdx,r12
     dbc:	jmp    dd7 <botlish_fn_13+0x137>
     dc1:	mov    rcx,QWORD PTR [rbx+0x8]
     dc5:	mov    rax,r12
     dc8:	sar    rax,1
     dcb:	cmp    rax,rcx
     dce:	jb     df3 <botlish_fn_13+0x153>
     dd4:	mov    rdx,r12
     dd7:	mov    rsi,rbx
     dda:	mov    rdi,r14
     ddd:	call   de2 <botlish_fn_13+0x142>
			dde: R_X86_64_PLT32	rt_list_get-0x4
     de2:	test   rax,rax
     de5:	je     e53 <botlish_fn_13+0x1b3>
     deb:	mov    rsi,rax
     dee:	jmp    dfb <botlish_fn_13+0x15b>
     df3:	mov    rsi,QWORD PTR [rbx+0x10]
     df7:	mov    rsi,QWORD PTR [rsi+rax*8]
     dfb:	mov    QWORD PTR [rsp+0x28],rsi
     e00:	mov    r12,r15
     e03:	mov    rdx,r12
     e06:	mov    rdi,r14
     e09:	call   e0e <botlish_fn_13+0x16e>
			e0a: R_X86_64_PLT32	botlish_fn_12-0x4 ; hex_pair<generic>
     e0e:	test   rax,rax
     e11:	je     e53 <botlish_fn_13+0x1b3>
     e17:	mov    QWORD PTR [rsp+0x28],rax
     e1c:	mov    rdx,rax
     e1f:	mov    rsi,QWORD PTR [rsp+0x38]
     e24:	mov    rdi,r14
     e27:	call   e2c <botlish_fn_13+0x18c>
			e28: R_X86_64_PLT32	rt_str_cat-0x4
     e2c:	test   rax,rax
     e2f:	je     e53 <botlish_fn_13+0x1b3>
     e35:	mov    QWORD PTR [rsp+0x20],rax
     e3a:	mov    rdx,rax
     e3d:	mov    rsi,QWORD PTR [rsp+0x30]
     e42:	mov    rdi,r14
     e45:	call   e4a <botlish_fn_13+0x1aa>
			e46: R_X86_64_PLT32	rt_str_cat-0x4
     e4a:	test   rax,rax
     e4d:	jne    e78 <botlish_fn_13+0x1d8>
     e53:	xor    rax,rax
     e56:	mov    rbx,QWORD PTR [rsp+0x40]
     e5b:	mov    r12,QWORD PTR [rsp+0x48]
     e60:	mov    r13,QWORD PTR [rsp+0x50]
     e65:	mov    r14,QWORD PTR [rsp+0x58]
     e6a:	mov    r15,QWORD PTR [rsp+0x60]
     e6f:	add    rsp,0x70
     e73:	mov    rsp,rbp
     e76:	pop    rbp
     e77:	ret
     e78:	mov    QWORD PTR [rsp],rbx
     e7c:	mov    QWORD PTR [rsp+0x8],r13
     e81:	mov    QWORD PTR [rsp+0x10],rax
     e86:	mov    QWORD PTR [rsp+0x18],r12
     e8b:	mov    QWORD PTR [rsp+0x30],rax
     e90:	mov    r15,r12
     e93:	mov    r12,r13
     e96:	jmp    cee <botlish_fn_13+0x4e>
     e9b:	mov    rax,QWORD PTR [rsp+0x30]
     ea0:	mov    rbx,QWORD PTR [rsp+0x40]
     ea5:	mov    r12,QWORD PTR [rsp+0x48]
     eaa:	mov    r13,QWORD PTR [rsp+0x50]
     eaf:	mov    r14,QWORD PTR [rsp+0x58]
     eb4:	mov    r15,QWORD PTR [rsp+0x60]
     eb9:	add    rsp,0x70
     ebd:	mov    rsp,rbp
     ec0:	pop    rbp
     ec1:	ret
     ec2:	add    BYTE PTR [rax],al
     ec4:	add    BYTE PTR [rax],al
     ec6:	add    BYTE PTR [rax],al
     ec8:	(bad)
     ec9:	add    BYTE PTR [rax],al
     ecb:	add    BYTE PTR [rax],al
     ecd:	add    BYTE PTR [rax],al
	...

0000000000000ed0 <botlish_entry_13: esc_bytes<generic>>:
     ed0:	push   rbp
     ed1:	mov    rbp,rsp
     ed4:	mov    rsi,QWORD PTR [rdx]
     ed7:	mov    r9,QWORD PTR [rdx+0x8]
     edb:	mov    rcx,QWORD PTR [rdx+0x10]
     edf:	mov    r8,QWORD PTR [rdx+0x18]
     ee3:	mov    rdx,r9
     ee6:	call   eeb <botlish_entry_13+0x1b>
			ee7: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
     eeb:	mov    rsp,rbp
     eee:	pop    rbp
     eef:	ret

0000000000000ef0 <botlish_fn_14: esc_char<generic>>:
     ef0:	push   rbp
     ef1:	mov    rbp,rsp
     ef4:	sub    rsp,0x50
     ef8:	mov    QWORD PTR [rsp+0x20],rbx
     efd:	mov    QWORD PTR [rsp+0x28],r12
     f02:	mov    QWORD PTR [rsp+0x30],r13
     f07:	mov    QWORD PTR [rsp+0x38],r14
     f0c:	mov    QWORD PTR [rsp+0x40],r15
     f11:	mov    r12,rdi
     f14:	mov    QWORD PTR [rsp+0x18],0x0
     f1d:	mov    QWORD PTR [rsp],rsi
     f21:	mov    r14,rsi
     f24:	mov    QWORD PTR [rsp+0x8],rdx
     f29:	mov    r15,rdx
     f2c:	mov    QWORD PTR [rsp+0x10],rcx
     f31:	mov    rbx,rcx
     f34:	mov    rsi,r14
     f37:	mov    rdi,r12
     f3a:	call   f3f <botlish_fn_14+0x4f>
			f3b: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
     f3f:	mov    rcx,rax
     f42:	mov    r13,rax
     f45:	test   rax,rcx
     f48:	je     1032 <botlish_fn_14+0x142>
     f4e:	mov    rax,r13
     f51:	mov    QWORD PTR [rsp],rax
     f55:	mov    rsi,r13
     f58:	mov    rdi,r12
     f5b:	call   f60 <botlish_fn_14+0x70>
			f5c: R_X86_64_PLT32	rt_list_len-0x4
     f60:	sar    rax,1
     f63:	cmp    rax,0x1
     f67:	je     fa7 <botlish_fn_14+0xb7>
     f6d:	mov    edx,0x1
     f72:	mov    QWORD PTR [rsp+0x8],0x1
     f7b:	mov    rdi,r12
     f7e:	mov    rax,QWORD PTR [rdi+0x10]
     f82:	mov    rcx,QWORD PTR [rax+0xa0]
     f89:	mov    QWORD PTR [rsp+0x18],rcx
     f8e:	mov    rsi,r13
     f91:	mov    r8,rbx
     f94:	call   f99 <botlish_fn_14+0xa9>
			f95: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
     f99:	test   rax,rax
     f9c:	je     1032 <botlish_fn_14+0x142>
     fa2:	jmp    105d <botlish_fn_14+0x16d>
     fa7:	mov    rsi,r13
     faa:	mov    rax,QWORD PTR [rsi+0x8]
     fae:	mov    r13,rsi
     fb1:	test   rax,rax
     fb4:	jne    fde <botlish_fn_14+0xee>
     fba:	mov    edx,0x1
     fbf:	mov    rsi,r13
     fc2:	mov    rdi,r12
     fc5:	call   fca <botlish_fn_14+0xda>
			fc6: R_X86_64_PLT32	rt_list_get-0x4
     fca:	test   rax,rax
     fcd:	je     1032 <botlish_fn_14+0x142>
     fd3:	mov    rdx,rax
     fd6:	mov    rsi,r15
     fd9:	jmp    feb <botlish_fn_14+0xfb>
     fde:	mov    rsi,r13
     fe1:	mov    rax,QWORD PTR [rsi+0x10]
     fe5:	mov    rdx,QWORD PTR [rax]
     fe8:	mov    rsi,r15
     feb:	mov    rdi,r12
     fee:	call   ff3 <botlish_fn_14+0x103>
			fef: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_unreserved<generic>
     ff3:	cmp    rax,0x6
     ff7:	je     105a <botlish_fn_14+0x16a>
     ffd:	mov    edx,0x1
    1002:	mov    QWORD PTR [rsp+0x8],0x1
    100b:	mov    rdi,r12
    100e:	mov    rax,QWORD PTR [rdi+0x10]
    1012:	mov    rcx,QWORD PTR [rax+0xa0]
    1019:	mov    QWORD PTR [rsp+0x18],rcx
    101e:	mov    rsi,r13
    1021:	mov    r8,rbx
    1024:	call   1029 <botlish_fn_14+0x139>
			1025: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    1029:	test   rax,rax
    102c:	jne    1057 <botlish_fn_14+0x167>
    1032:	xor    rax,rax
    1035:	mov    rbx,QWORD PTR [rsp+0x20]
    103a:	mov    r12,QWORD PTR [rsp+0x28]
    103f:	mov    r13,QWORD PTR [rsp+0x30]
    1044:	mov    r14,QWORD PTR [rsp+0x38]
    1049:	mov    r15,QWORD PTR [rsp+0x40]
    104e:	add    rsp,0x50
    1052:	mov    rsp,rbp
    1055:	pop    rbp
    1056:	ret
    1057:	mov    r14,rax
    105a:	mov    rax,r14
    105d:	mov    rbx,QWORD PTR [rsp+0x20]
    1062:	mov    r12,QWORD PTR [rsp+0x28]
    1067:	mov    r13,QWORD PTR [rsp+0x30]
    106c:	mov    r14,QWORD PTR [rsp+0x38]
    1071:	mov    r15,QWORD PTR [rsp+0x40]
    1076:	add    rsp,0x50
    107a:	mov    rsp,rbp
    107d:	pop    rbp
    107e:	ret

000000000000107f <botlish_entry_14: esc_char<generic>>:
    107f:	push   rbp
    1080:	mov    rbp,rsp
    1083:	mov    rsi,QWORD PTR [rdx]
    1086:	mov    r8,QWORD PTR [rdx+0x8]
    108a:	mov    rcx,QWORD PTR [rdx+0x10]
    108e:	mov    rdx,r8
    1091:	call   1096 <botlish_entry_14+0x17>
			1092: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_char<generic>
    1096:	mov    rsp,rbp
    1099:	pop    rbp
    109a:	ret
    109b:	add    BYTE PTR [rax],al
    109d:	add    BYTE PTR [rax],al
	...

00000000000010a0 <botlish_fn_15: esc_from<generic>>:
    10a0:	push   rbp
    10a1:	mov    rbp,rsp
    10a4:	sub    rsp,0x80
    10ab:	mov    QWORD PTR [rsp+0x50],rbx
    10b0:	mov    QWORD PTR [rsp+0x58],r12
    10b5:	mov    QWORD PTR [rsp+0x60],r13
    10ba:	mov    QWORD PTR [rsp+0x68],r14
    10bf:	mov    QWORD PTR [rsp+0x70],r15
    10c4:	mov    r14,rdi
    10c7:	mov    QWORD PTR [rsp+0x30],0x0
    10d0:	mov    QWORD PTR [rsp],rsi
    10d4:	mov    QWORD PTR [rsp+0x8],rdx
    10d9:	mov    r15,rdx
    10dc:	mov    QWORD PTR [rsp+0x10],rcx
    10e1:	mov    QWORD PTR [rsp+0x18],r8
    10e6:	mov    r13,r8
    10e9:	mov    QWORD PTR [rsp+0x20],r9
    10ee:	mov    rbx,r9
    10f1:	mov    QWORD PTR [rsp+0x38],rcx
    10f6:	xor    eax,eax
    10f8:	test   rsi,0x7
    10ff:	jne    110e <botlish_fn_15+0x6e>
    1105:	movzx  rax,BYTE PTR [rsi]
    1109:	cmp    al,0x2
    110b:	sete   al
    110e:	test   al,al
    1110:	jne    1133 <botlish_fn_15+0x93>
    1116:	mov    rdi,r14
    1119:	mov    rax,QWORD PTR [rdi+0x10]
    111d:	mov    rcx,QWORD PTR [rax+0xb0]
    1124:	mov    edx,0x1
    1129:	call   112e <botlish_fn_15+0x8e>
			112a: R_X86_64_PLT32	rt_type_error-0x4
    112e:	jmp    126f <botlish_fn_15+0x1cf>
    1133:	mov    r12,rsi
    1136:	mov    rdi,r14
    1139:	call   113e <botlish_fn_15+0x9e>
			113a: R_X86_64_PLT32	rt_str_len-0x4
    113e:	mov    rcx,r15
    1141:	and    rcx,rax
    1144:	mov    rdx,rax
    1147:	test   rcx,0x1
    114e:	jne    1174 <botlish_fn_15+0xd4>
    1154:	mov    rsi,r15
    1157:	mov    rdi,r14
    115a:	call   115f <botlish_fn_15+0xbf>
			115b: R_X86_64_PLT32	rt_int_cmp-0x4
    115f:	mov    ecx,0x2
    1164:	test   rax,rax
    1167:	cmovge rcx,QWORD PTR [rip+0x189]        # 12f8 <botlish_fn_15+0x258>
    116f:	jmp    1184 <botlish_fn_15+0xe4>
    1174:	mov    ecx,0x2
    1179:	cmp    r15,rdx
    117c:	cmovge rcx,QWORD PTR [rip+0x174]        # 12f8 <botlish_fn_15+0x258>
    1184:	cmp    rcx,0x6
    1188:	je     12cd <botlish_fn_15+0x22d>
    118e:	mov    QWORD PTR [rsp+0x28],0x3
    1197:	test   r15,0x1
    119e:	je     11b8 <botlish_fn_15+0x118>
    11a4:	mov    rax,r15
    11a7:	add    rax,0x2
    11ab:	seto   sil
    11af:	test   sil,sil
    11b2:	je     11c8 <botlish_fn_15+0x128>
    11b8:	mov    edx,0x3
    11bd:	mov    rsi,r15
    11c0:	mov    rdi,r14
    11c3:	call   11c8 <botlish_fn_15+0x128>
			11c4: R_X86_64_PLT32	rt_int_add-0x4
    11c8:	mov    QWORD PTR [rsp+0x28],rax
    11cd:	mov    QWORD PTR [rsp+0x40],rax
    11d2:	mov    QWORD PTR [rsp+0x30],0x3
    11db:	test   r15,0x1
    11e2:	je     11fa <botlish_fn_15+0x15a>
    11e8:	mov    rcx,r15
    11eb:	add    rcx,0x2
    11ef:	seto   al
    11f2:	test   al,al
    11f4:	je     120d <botlish_fn_15+0x16d>
    11fa:	mov    edx,0x3
    11ff:	mov    rsi,r15
    1202:	mov    rdi,r14
    1205:	call   120a <botlish_fn_15+0x16a>
			1206: R_X86_64_PLT32	rt_int_add-0x4
    120a:	mov    rcx,rax
    120d:	mov    QWORD PTR [rsp+0x30],rcx
    1212:	mov    rdx,r15
    1215:	mov    rsi,r12
    1218:	mov    rdi,r14
    121b:	call   1220 <botlish_fn_15+0x180>
			121c: R_X86_64_PLT32	rt_substr-0x4
    1220:	test   rax,rax
    1223:	je     126f <botlish_fn_15+0x1cf>
    1229:	mov    QWORD PTR [rsp+0x8],rax
    122e:	mov    rsi,rax
    1231:	mov    r8,rbx
    1234:	mov    rbx,r13
    1237:	mov    r13,r8
    123a:	mov    rcx,r13
    123d:	mov    rdx,rbx
    1240:	mov    rdi,r14
    1243:	call   1248 <botlish_fn_15+0x1a8>
			1244: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_char<generic>
    1248:	test   rax,rax
    124b:	je     126f <botlish_fn_15+0x1cf>
    1251:	mov    QWORD PTR [rsp+0x8],rax
    1256:	mov    rdx,rax
    1259:	mov    rsi,QWORD PTR [rsp+0x38]
    125e:	mov    rdi,r14
    1261:	call   1266 <botlish_fn_15+0x1c6>
			1262: R_X86_64_PLT32	rt_str_cat-0x4
    1266:	test   rax,rax
    1269:	jne    1297 <botlish_fn_15+0x1f7>
    126f:	xor    rax,rax
    1272:	mov    rbx,QWORD PTR [rsp+0x50]
    1277:	mov    r12,QWORD PTR [rsp+0x58]
    127c:	mov    r13,QWORD PTR [rsp+0x60]
    1281:	mov    r14,QWORD PTR [rsp+0x68]
    1286:	mov    r15,QWORD PTR [rsp+0x70]
    128b:	add    rsp,0x80
    1292:	mov    rsp,rbp
    1295:	pop    rbp
    1296:	ret
    1297:	mov    QWORD PTR [rsp],r12
    129b:	mov    rcx,QWORD PTR [rsp+0x40]
    12a0:	mov    QWORD PTR [rsp+0x8],rcx
    12a5:	mov    QWORD PTR [rsp+0x10],rax
    12aa:	mov    QWORD PTR [rsp+0x18],rbx
    12af:	mov    QWORD PTR [rsp+0x20],r13
    12b4:	mov    QWORD PTR [rsp+0x38],rax
    12b9:	mov    r15,rcx
    12bc:	mov    rsi,r12
    12bf:	mov    rdx,rbx
    12c2:	mov    rbx,r13
    12c5:	mov    r13,rdx
    12c8:	jmp    10f6 <botlish_fn_15+0x56>
    12cd:	mov    rax,QWORD PTR [rsp+0x38]
    12d2:	mov    rbx,QWORD PTR [rsp+0x50]
    12d7:	mov    r12,QWORD PTR [rsp+0x58]
    12dc:	mov    r13,QWORD PTR [rsp+0x60]
    12e1:	mov    r14,QWORD PTR [rsp+0x68]
    12e6:	mov    r15,QWORD PTR [rsp+0x70]
    12eb:	add    rsp,0x80
    12f2:	mov    rsp,rbp
    12f5:	pop    rbp
    12f6:	ret
    12f7:	add    BYTE PTR [rsi],al
    12f9:	add    BYTE PTR [rax],al
    12fb:	add    BYTE PTR [rax],al
    12fd:	add    BYTE PTR [rax],al
	...

0000000000001300 <botlish_entry_15: esc_from<generic>>:
    1300:	push   rbp
    1301:	mov    rbp,rsp
    1304:	mov    rsi,QWORD PTR [rdx]
    1307:	mov    r10,QWORD PTR [rdx+0x8]
    130b:	mov    rcx,QWORD PTR [rdx+0x10]
    130f:	mov    r8,QWORD PTR [rdx+0x18]
    1313:	mov    r9,QWORD PTR [rdx+0x20]
    1317:	mov    rdx,r10
    131a:	call   131f <botlish_entry_15+0x1f>
			131b: R_X86_64_PLT32	botlish_fn_15-0x4 ; esc_from<generic>
    131f:	mov    rsp,rbp
    1322:	pop    rbp
    1323:	ret
    1324:	add    BYTE PTR [rax],al
	...

0000000000001328 <botlish_fn_16: check<int, int, str, str>>:
    1328:	push   rbp
    1329:	mov    rbp,rsp
    132c:	sub    rsp,0x60
    1330:	mov    QWORD PTR [rsp+0x30],rbx
    1335:	mov    QWORD PTR [rsp+0x38],r12
    133a:	mov    QWORD PTR [rsp+0x40],r13
    133f:	mov    QWORD PTR [rsp+0x48],r14
    1344:	mov    QWORD PTR [rsp+0x50],r15
    1349:	mov    QWORD PTR [rsp+0x20],0x0
    1352:	mov    QWORD PTR [rsp],rsi
    1356:	mov    QWORD PTR [rsp+0x8],rdx
    135b:	mov    QWORD PTR [rsp+0x10],rcx
    1360:	mov    r12,rcx
    1363:	mov    QWORD PTR [rsp+0x18],r8
    1368:	mov    r14,r8
    136b:	mov    r13,rsi
    136e:	mov    r15,rdx
    1371:	test   r13,0x1
    1378:	jne    13a3 <botlish_fn_16+0x7b>
    137e:	mov    edx,0x1
    1383:	mov    rbx,rdi
    1386:	mov    rsi,r13
    1389:	call   138e <botlish_fn_16+0x66>
			138a: R_X86_64_PLT32	rt_int_cmp-0x4
    138e:	mov    ecx,0x2
    1393:	test   rax,rax
    1396:	cmovle rcx,QWORD PTR [rip+0x152]        # 14f0 <botlish_fn_16+0x1c8>
    139e:	jmp    13b7 <botlish_fn_16+0x8f>
    13a3:	mov    rbx,rdi
    13a6:	mov    ecx,0x2
    13ab:	cmp    r13,0x1
    13af:	cmovle rcx,QWORD PTR [rip+0x139]        # 14f0 <botlish_fn_16+0x1c8>
    13b7:	cmp    rcx,0x6
    13bb:	je     14c6 <botlish_fn_16+0x19e>
    13c1:	mov    rax,QWORD PTR [rbx+0x10]
    13c5:	mov    rax,QWORD PTR [rax+0xb8]
    13cc:	mov    rsi,r12
    13cf:	mov    rdi,rbx
    13d2:	call   13d7 <botlish_fn_16+0xaf>
			13d3: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    13d7:	test   rax,rax
    13da:	je     141b <botlish_fn_16+0xf3>
    13e0:	cmp    rax,0x6
    13e4:	je     13fc <botlish_fn_16+0xd4>
    13ea:	mov    edx,0x1
    13ef:	mov    QWORD PTR [rsp],0x1
    13f7:	jmp    145d <botlish_fn_16+0x135>
    13fc:	mov    rax,QWORD PTR [rbx+0x10]
    1400:	mov    rax,QWORD PTR [rax+0xc0]
    1407:	mov    rsi,r12
    140a:	mov    rdi,rbx
    140d:	call   1412 <botlish_fn_16+0xea>
			140e: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    1412:	test   rax,rax
    1415:	jne    1440 <botlish_fn_16+0x118>
    141b:	xor    rax,rax
    141e:	mov    rbx,QWORD PTR [rsp+0x30]
    1423:	mov    r12,QWORD PTR [rsp+0x38]
    1428:	mov    r13,QWORD PTR [rsp+0x40]
    142d:	mov    r14,QWORD PTR [rsp+0x48]
    1432:	mov    r15,QWORD PTR [rsp+0x50]
    1437:	add    rsp,0x60
    143b:	mov    rsp,rbp
    143e:	pop    rbp
    143f:	ret
    1440:	cmp    rax,0x6
    1444:	je     1454 <botlish_fn_16+0x12c>
    144a:	mov    edx,0x1
    144f:	jmp    1459 <botlish_fn_16+0x131>
    1454:	mov    edx,0x3
    1459:	mov    QWORD PTR [rsp],rdx
    145d:	sar    r13,1
    1460:	sub    r13,0x1
    1464:	shl    r13,1
    1467:	or     r13,0x1
    146b:	mov    QWORD PTR [rsp+0x20],r13
    1470:	mov    rsi,r15
    1473:	mov    rdi,rsi
    1476:	and    rdi,rdx
    1479:	test   rdi,0x1
    1480:	je     149d <botlish_fn_16+0x175>
    1486:	lea    r9,[rdx-0x1]
    148a:	mov    rax,rsi
    148d:	add    rax,r9
    1490:	seto   r10b
    1494:	test   r10b,r10b
    1497:	je     14a5 <botlish_fn_16+0x17d>
    149d:	mov    rdi,rbx
    14a0:	call   14a5 <botlish_fn_16+0x17d>
			14a1: R_X86_64_PLT32	rt_int_add-0x4
    14a5:	mov    QWORD PTR [rsp],r13
    14a9:	mov    QWORD PTR [rsp+0x8],rax
    14ae:	mov    QWORD PTR [rsp+0x10],r12
    14b3:	mov    r8,r14
    14b6:	mov    QWORD PTR [rsp+0x18],r8
    14bb:	mov    rdi,rbx
    14be:	mov    r15,rax
    14c1:	jmp    1371 <botlish_fn_16+0x49>
    14c6:	mov    rax,r15
    14c9:	mov    rbx,QWORD PTR [rsp+0x30]
    14ce:	mov    r12,QWORD PTR [rsp+0x38]
    14d3:	mov    r13,QWORD PTR [rsp+0x40]
    14d8:	mov    r14,QWORD PTR [rsp+0x48]
    14dd:	mov    r15,QWORD PTR [rsp+0x50]
    14e2:	add    rsp,0x60
    14e6:	mov    rsp,rbp
    14e9:	pop    rbp
    14ea:	ret
    14eb:	add    BYTE PTR [rax],al
    14ed:	add    BYTE PTR [rax],al
    14ef:	add    BYTE PTR [rsi],al
    14f1:	add    BYTE PTR [rax],al
    14f3:	add    BYTE PTR [rax],al
    14f5:	add    BYTE PTR [rax],al
	...

00000000000014f8 <botlish_entry_16: check<int, int, str, str>>:
    14f8:	push   rbp
    14f9:	mov    rbp,rsp
    14fc:	mov    rsi,QWORD PTR [rdx]
    14ff:	mov    r9,QWORD PTR [rdx+0x8]
    1503:	mov    rcx,QWORD PTR [rdx+0x10]
    1507:	mov    r8,QWORD PTR [rdx+0x18]
    150b:	mov    rdx,r9
    150e:	call   1513 <botlish_entry_16+0x1b>
			150f: R_X86_64_PLT32	botlish_fn_16-0x4 ; check<int, int, str, str>
    1513:	mov    rsp,rbp
    1516:	pop    rbp
    1517:	ret

0000000000001518 <botlish_fn_17: <str>>:
    1518:	push   rbp
    1519:	mov    rbp,rsp
    151c:	sub    rsp,0x50
    1520:	mov    QWORD PTR [rsp+0x30],rbx
    1525:	mov    QWORD PTR [rsp+0x38],r12
    152a:	mov    QWORD PTR [rsp+0x40],r13
    152f:	mov    QWORD PTR [rsp+0x48],r14
    1534:	mov    r13,rdi
    1537:	mov    QWORD PTR [rsp+0x18],0x0
    1540:	mov    QWORD PTR [rsp],rsi
    1544:	mov    r14,rsi
    1547:	mov    rsi,r14
    154a:	mov    rdi,r13
    154d:	call   1552 <botlish_fn_17+0x3a>
			154e: R_X86_64_PLT32	rt_str_len-0x4
    1552:	mov    rbx,rax
    1555:	mov    QWORD PTR [rsp+0x8],rax
    155a:	mov    esi,0x1
    155f:	mov    QWORD PTR [rsp+0x10],0x1
    1568:	mov    rcx,r14
    156b:	mov    rdx,rbx
    156e:	mov    rdi,r13
    1571:	call   1576 <botlish_fn_17+0x5e>
			1572: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    1576:	mov    r12,rax
    1579:	test   r12,r12
    157c:	je     16d9 <botlish_fn_17+0x1c1>
    1582:	mov    QWORD PTR [rsp+0x10],r12
    1587:	test   r12,0x1
    158e:	jne    15b9 <botlish_fn_17+0xa1>
    1594:	mov    edx,0x1
    1599:	mov    rsi,r12
    159c:	mov    rdi,r13
    159f:	call   15a4 <botlish_fn_17+0x8c>
			15a0: R_X86_64_PLT32	rt_int_cmp-0x4
    15a4:	mov    ecx,0x2
    15a9:	test   rax,rax
    15ac:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 1778 <botlish_fn_17+0x260>
    15b4:	jmp    15ca <botlish_fn_17+0xb2>
    15b9:	mov    ecx,0x2
    15be:	cmp    r12,0x1
    15c2:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 1778 <botlish_fn_17+0x260>
    15ca:	cmp    rcx,0x6
    15ce:	je     1754 <botlish_fn_17+0x23c>
    15d4:	mov    rcx,r12
    15d7:	and    rcx,rbx
    15da:	test   rcx,0x1
    15e1:	jne    160a <botlish_fn_17+0xf2>
    15e7:	mov    rdx,rbx
    15ea:	mov    rsi,r12
    15ed:	mov    rdi,r13
    15f0:	call   15f5 <botlish_fn_17+0xdd>
			15f1: R_X86_64_PLT32	rt_int_cmp-0x4
    15f5:	mov    ecx,0x2
    15fa:	test   rax,rax
    15fd:	cmovge rcx,QWORD PTR [rip+0x173]        # 1778 <botlish_fn_17+0x260>
    1605:	jmp    161a <botlish_fn_17+0x102>
    160a:	mov    ecx,0x2
    160f:	cmp    r12,rbx
    1612:	cmovge rcx,QWORD PTR [rip+0x15e]        # 1778 <botlish_fn_17+0x260>
    161a:	cmp    rcx,0x6
    161e:	je     174a <botlish_fn_17+0x232>
    1624:	lea    rcx,[rsp+0x20]
    1629:	mov    rdx,r14
    162c:	mov    rsi,r12
    162f:	mov    rdi,r13
    1632:	call   1637 <botlish_fn_17+0x11f>
			1633: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    1637:	test   rax,rax
    163a:	mov    rsi,rax
    163d:	je     16d9 <botlish_fn_17+0x1c1>
    1643:	mov    rdx,QWORD PTR [rsp+0x20]
    1648:	mov    rcx,QWORD PTR [rsp+0x28]
    164d:	mov    rdi,r13
    1650:	mov    rax,QWORD PTR [rdi+0x10]
    1654:	mov    r8,QWORD PTR [rax+0xc8]
    165b:	call   1660 <botlish_fn_17+0x148>
			165c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1660:	cmp    rax,0x6
    1664:	je     1677 <botlish_fn_17+0x15f>
    166a:	mov    ecx,0x2
    166f:	mov    rax,rcx
    1672:	jmp    1759 <botlish_fn_17+0x241>
    1677:	mov    QWORD PTR [rsp+0x18],0x3
    1680:	test   r12,0x1
    1687:	jne    1695 <botlish_fn_17+0x17d>
    168d:	mov    rcx,r12
    1690:	jmp    16aa <botlish_fn_17+0x192>
    1695:	mov    rsi,r12
    1698:	add    rsi,0x2
    169c:	mov    rcx,r12
    169f:	seto   al
    16a2:	test   al,al
    16a4:	je     16bd <botlish_fn_17+0x1a5>
    16aa:	mov    edx,0x3
    16af:	mov    rsi,rcx
    16b2:	mov    rdi,r13
    16b5:	call   16ba <botlish_fn_17+0x1a2>
			16b6: R_X86_64_PLT32	rt_int_add-0x4
    16ba:	mov    rsi,rax
    16bd:	mov    QWORD PTR [rsp+0x10],rsi
    16c2:	mov    rcx,r14
    16c5:	mov    rdx,rbx
    16c8:	mov    rdi,r13
    16cb:	call   16d0 <botlish_fn_17+0x1b8>
			16cc: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    16d0:	test   rax,rax
    16d3:	jne    16f9 <botlish_fn_17+0x1e1>
    16d9:	xor    rax,rax
    16dc:	mov    rbx,QWORD PTR [rsp+0x30]
    16e1:	mov    r12,QWORD PTR [rsp+0x38]
    16e6:	mov    r13,QWORD PTR [rsp+0x40]
    16eb:	mov    r14,QWORD PTR [rsp+0x48]
    16f0:	add    rsp,0x50
    16f4:	mov    rsp,rbp
    16f7:	pop    rbp
    16f8:	ret
    16f9:	mov    rcx,rax
    16fc:	and    rcx,rbx
    16ff:	mov    rsi,rax
    1702:	test   rcx,0x1
    1709:	jne    1732 <botlish_fn_17+0x21a>
    170f:	mov    rdx,rbx
    1712:	mov    rdi,r13
    1715:	call   171a <botlish_fn_17+0x202>
			1716: R_X86_64_PLT32	rt_int_cmp-0x4
    171a:	mov    ecx,0x2
    171f:	test   rax,rax
    1722:	mov    rax,rcx
    1725:	cmove  rax,QWORD PTR [rip+0x4b]        # 1778 <botlish_fn_17+0x260>
    172d:	jmp    1759 <botlish_fn_17+0x241>
    1732:	mov    rdx,rbx
    1735:	mov    eax,0x2
    173a:	cmp    rsi,rdx
    173d:	cmove  rax,QWORD PTR [rip+0x33]        # 1778 <botlish_fn_17+0x260>
    1745:	jmp    1759 <botlish_fn_17+0x241>
    174a:	mov    eax,0x2
    174f:	jmp    1759 <botlish_fn_17+0x241>
    1754:	mov    eax,0x2
    1759:	mov    rbx,QWORD PTR [rsp+0x30]
    175e:	mov    r12,QWORD PTR [rsp+0x38]
    1763:	mov    r13,QWORD PTR [rsp+0x40]
    1768:	mov    r14,QWORD PTR [rsp+0x48]
    176d:	add    rsp,0x50
    1771:	mov    rsp,rbp
    1774:	pop    rbp
    1775:	ret
    1776:	add    BYTE PTR [rax],al
    1778:	(bad)
    1779:	add    BYTE PTR [rax],al
    177b:	add    BYTE PTR [rax],al
    177d:	add    BYTE PTR [rax],al
	...

0000000000001780 <botlish_entry_17: <str>>:
    1780:	push   rbp
    1781:	mov    rbp,rsp
    1784:	mov    rsi,QWORD PTR [rdx]
    1787:	call   178c <botlish_entry_17+0xc>
			1788: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    178c:	mov    rsp,rbp
    178f:	pop    rbp
    1790:	ret
    1791:	add    BYTE PTR [rax],al
    1793:	add    BYTE PTR [rax],al
    1795:	add    BYTE PTR [rax],al
	...

0000000000001798 <botlish_fn_18: <generic>>:
    1798:	push   rbp
    1799:	mov    rbp,rsp
    179c:	sub    rsp,0x60
    17a0:	mov    QWORD PTR [rsp+0x30],rbx
    17a5:	mov    QWORD PTR [rsp+0x38],r12
    17aa:	mov    QWORD PTR [rsp+0x40],r13
    17af:	mov    QWORD PTR [rsp+0x48],r14
    17b4:	mov    QWORD PTR [rsp+0x50],r15
    17b9:	mov    QWORD PTR [rsp+0x18],0x0
    17c2:	mov    QWORD PTR [rsp],rsi
    17c6:	xor    r8d,r8d
    17c9:	test   rsi,0x7
    17d0:	jne    17e0 <botlish_fn_18+0x48>
    17d6:	movzx  rax,BYTE PTR [rsi]
    17da:	cmp    al,0x2
    17dc:	sete   r8b
    17e0:	test   r8b,r8b
    17e3:	jne    1803 <botlish_fn_18+0x6b>
    17e9:	mov    rdx,QWORD PTR [rdi+0x10]
    17ed:	mov    rcx,QWORD PTR [rdx+0xb0]
    17f4:	mov    edx,0x1
    17f9:	call   17fe <botlish_fn_18+0x66>
			17fa: R_X86_64_PLT32	rt_type_error-0x4
    17fe:	jmp    1998 <botlish_fn_18+0x200>
    1803:	mov    r13,rsi
    1806:	mov    r14,rdi
    1809:	call   180e <botlish_fn_18+0x76>
			180a: R_X86_64_PLT32	rt_str_len-0x4
    180e:	mov    rbx,rax
    1811:	mov    QWORD PTR [rsp+0x8],rax
    1816:	mov    edx,0x1
    181b:	mov    r15,rdx
    181e:	mov    QWORD PTR [rsp+0x10],0x1
    1827:	mov    rcx,r13
    182a:	mov    rdx,rbx
    182d:	mov    rsi,r15
    1830:	mov    rdi,r14
    1833:	call   1838 <botlish_fn_18+0xa0>
			1834: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    1838:	mov    r12,rax
    183b:	test   r12,r12
    183e:	je     1998 <botlish_fn_18+0x200>
    1844:	mov    QWORD PTR [rsp+0x10],r12
    1849:	test   r12,0x1
    1850:	jne    1879 <botlish_fn_18+0xe1>
    1856:	mov    rdx,r15
    1859:	mov    rsi,r12
    185c:	mov    rdi,r14
    185f:	call   1864 <botlish_fn_18+0xcc>
			1860: R_X86_64_PLT32	rt_int_cmp-0x4
    1864:	mov    ecx,0x2
    1869:	test   rax,rax
    186c:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 1a40 <botlish_fn_18+0x2a8>
    1874:	jmp    188a <botlish_fn_18+0xf2>
    1879:	mov    ecx,0x2
    187e:	cmp    r12,0x1
    1882:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 1a40 <botlish_fn_18+0x2a8>
    188a:	cmp    rcx,0x6
    188e:	je     1a18 <botlish_fn_18+0x280>
    1894:	mov    rax,r12
    1897:	and    rax,rbx
    189a:	test   rax,0x1
    18a0:	jne    18c9 <botlish_fn_18+0x131>
    18a6:	mov    rdx,rbx
    18a9:	mov    rsi,r12
    18ac:	mov    rdi,r14
    18af:	call   18b4 <botlish_fn_18+0x11c>
			18b0: R_X86_64_PLT32	rt_int_cmp-0x4
    18b4:	mov    ecx,0x2
    18b9:	test   rax,rax
    18bc:	cmovge rcx,QWORD PTR [rip+0x17c]        # 1a40 <botlish_fn_18+0x2a8>
    18c4:	jmp    18d9 <botlish_fn_18+0x141>
    18c9:	mov    ecx,0x2
    18ce:	cmp    r12,rbx
    18d1:	cmovge rcx,QWORD PTR [rip+0x167]        # 1a40 <botlish_fn_18+0x2a8>
    18d9:	cmp    rcx,0x6
    18dd:	je     1a0e <botlish_fn_18+0x276>
    18e3:	lea    rcx,[rsp+0x20]
    18e8:	mov    rdx,r13
    18eb:	mov    rsi,r12
    18ee:	mov    rdi,r14
    18f1:	call   18f6 <botlish_fn_18+0x15e>
			18f2: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    18f6:	test   rax,rax
    18f9:	mov    rsi,rax
    18fc:	je     1998 <botlish_fn_18+0x200>
    1902:	mov    rdx,QWORD PTR [rsp+0x20]
    1907:	mov    rcx,QWORD PTR [rsp+0x28]
    190c:	mov    rdi,r14
    190f:	mov    rax,QWORD PTR [rdi+0x10]
    1913:	mov    r8,QWORD PTR [rax+0xc8]
    191a:	call   191f <botlish_fn_18+0x187>
			191b: R_X86_64_PLT32	rt_str_region_eq-0x4
    191f:	cmp    rax,0x6
    1923:	je     1936 <botlish_fn_18+0x19e>
    1929:	mov    ecx,0x2
    192e:	mov    rax,rcx
    1931:	jmp    1a1d <botlish_fn_18+0x285>
    1936:	mov    QWORD PTR [rsp+0x18],0x3
    193f:	test   r12,0x1
    1946:	jne    1954 <botlish_fn_18+0x1bc>
    194c:	mov    rdi,r12
    194f:	jmp    1969 <botlish_fn_18+0x1d1>
    1954:	mov    rsi,r12
    1957:	add    rsi,0x2
    195b:	mov    rdi,r12
    195e:	seto   al
    1961:	test   al,al
    1963:	je     197c <botlish_fn_18+0x1e4>
    1969:	mov    edx,0x3
    196e:	mov    rsi,rdi
    1971:	mov    rdi,r14
    1974:	call   1979 <botlish_fn_18+0x1e1>
			1975: R_X86_64_PLT32	rt_int_add-0x4
    1979:	mov    rsi,rax
    197c:	mov    QWORD PTR [rsp+0x10],rsi
    1981:	mov    rcx,r13
    1984:	mov    rdx,rbx
    1987:	mov    rdi,r14
    198a:	call   198f <botlish_fn_18+0x1f7>
			198b: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    198f:	test   rax,rax
    1992:	jne    19bd <botlish_fn_18+0x225>
    1998:	xor    rax,rax
    199b:	mov    rbx,QWORD PTR [rsp+0x30]
    19a0:	mov    r12,QWORD PTR [rsp+0x38]
    19a5:	mov    r13,QWORD PTR [rsp+0x40]
    19aa:	mov    r14,QWORD PTR [rsp+0x48]
    19af:	mov    r15,QWORD PTR [rsp+0x50]
    19b4:	add    rsp,0x60
    19b8:	mov    rsp,rbp
    19bb:	pop    rbp
    19bc:	ret
    19bd:	mov    rcx,rax
    19c0:	and    rcx,rbx
    19c3:	mov    rsi,rax
    19c6:	test   rcx,0x1
    19cd:	jne    19f6 <botlish_fn_18+0x25e>
    19d3:	mov    rdx,rbx
    19d6:	mov    rdi,r14
    19d9:	call   19de <botlish_fn_18+0x246>
			19da: R_X86_64_PLT32	rt_int_cmp-0x4
    19de:	mov    ecx,0x2
    19e3:	test   rax,rax
    19e6:	mov    rax,rcx
    19e9:	cmove  rax,QWORD PTR [rip+0x4f]        # 1a40 <botlish_fn_18+0x2a8>
    19f1:	jmp    1a1d <botlish_fn_18+0x285>
    19f6:	mov    rdx,rbx
    19f9:	mov    eax,0x2
    19fe:	cmp    rsi,rdx
    1a01:	cmove  rax,QWORD PTR [rip+0x37]        # 1a40 <botlish_fn_18+0x2a8>
    1a09:	jmp    1a1d <botlish_fn_18+0x285>
    1a0e:	mov    eax,0x2
    1a13:	jmp    1a1d <botlish_fn_18+0x285>
    1a18:	mov    eax,0x2
    1a1d:	mov    rbx,QWORD PTR [rsp+0x30]
    1a22:	mov    r12,QWORD PTR [rsp+0x38]
    1a27:	mov    r13,QWORD PTR [rsp+0x40]
    1a2c:	mov    r14,QWORD PTR [rsp+0x48]
    1a31:	mov    r15,QWORD PTR [rsp+0x50]
    1a36:	add    rsp,0x60
    1a3a:	mov    rsp,rbp
    1a3d:	pop    rbp
    1a3e:	ret
    1a3f:	add    BYTE PTR [rsi],al
    1a41:	add    BYTE PTR [rax],al
    1a43:	add    BYTE PTR [rax],al
    1a45:	add    BYTE PTR [rax],al
	...

0000000000001a48 <botlish_entry_18: <generic>>:
    1a48:	push   rbp
    1a49:	mov    rbp,rsp
    1a4c:	mov    rsi,QWORD PTR [rdx]
    1a4f:	call   1a54 <botlish_entry_18+0xc>
			1a50: R_X86_64_PLT32	botlish_fn_18-0x4 ; <generic>
    1a54:	mov    rsp,rbp
    1a57:	pop    rbp
    1a58:	ret

0000000000001a59 <botlish_fn_19: char_at<generic>>:
    1a59:	push   rbp
    1a5a:	mov    rbp,rsp
    1a5d:	sub    rsp,0x50
    1a61:	mov    QWORD PTR [rsp+0x20],rbx
    1a66:	mov    QWORD PTR [rsp+0x28],r12
    1a6b:	mov    QWORD PTR [rsp+0x30],r13
    1a70:	mov    QWORD PTR [rsp+0x38],r14
    1a75:	mov    QWORD PTR [rsp+0x40],r15
    1a7a:	mov    r12,rdi
    1a7d:	mov    r15,rcx
    1a80:	mov    QWORD PTR [rsp],rsi
    1a84:	mov    QWORD PTR [rsp+0x8],rdx
    1a89:	mov    r13,rdx
    1a8c:	mov    QWORD PTR [rsp+0x10],0x3
    1a95:	test   rsi,0x1
    1a9c:	jne    1aaa <botlish_fn_19+0x51>
    1aa2:	mov    rbx,rsi
    1aa5:	jmp    1aca <botlish_fn_19+0x71>
    1aaa:	mov    rax,rsi
    1aad:	add    rax,0x2
    1ab1:	mov    rbx,rsi
    1ab4:	seto   cl
    1ab7:	test   cl,cl
    1ab9:	jne    1aca <botlish_fn_19+0x71>
    1abf:	mov    rdi,r12
    1ac2:	mov    r14,rax
    1ac5:	jmp    1ae0 <botlish_fn_19+0x87>
    1aca:	mov    edx,0x3
    1acf:	mov    rsi,rbx
    1ad2:	mov    rdi,r12
    1ad5:	call   1ada <botlish_fn_19+0x81>
			1ad6: R_X86_64_PLT32	rt_int_add-0x4
    1ada:	mov    r14,rax
    1add:	mov    rdi,r12
    1ae0:	mov    rcx,r14
    1ae3:	mov    rdx,rbx
    1ae6:	mov    rsi,r13
    1ae9:	call   1aee <botlish_fn_19+0x95>
			1aea: R_X86_64_PLT32	rt_str_region_check-0x4
    1aee:	test   rax,rax
    1af1:	jne    1b1c <botlish_fn_19+0xc3>
    1af7:	xor    rax,rax
    1afa:	mov    rbx,QWORD PTR [rsp+0x20]
    1aff:	mov    r12,QWORD PTR [rsp+0x28]
    1b04:	mov    r13,QWORD PTR [rsp+0x30]
    1b09:	mov    r14,QWORD PTR [rsp+0x38]
    1b0e:	mov    r15,QWORD PTR [rsp+0x40]
    1b13:	add    rsp,0x50
    1b17:	mov    rsp,rbp
    1b1a:	pop    rbp
    1b1b:	ret
    1b1c:	mov    rcx,r15
    1b1f:	mov    QWORD PTR [rcx],rbx
    1b22:	mov    rax,r14
    1b25:	mov    QWORD PTR [rcx+0x8],rax
    1b29:	mov    rax,r13
    1b2c:	mov    rbx,QWORD PTR [rsp+0x20]
    1b31:	mov    r12,QWORD PTR [rsp+0x28]
    1b36:	mov    r13,QWORD PTR [rsp+0x30]
    1b3b:	mov    r14,QWORD PTR [rsp+0x38]
    1b40:	mov    r15,QWORD PTR [rsp+0x40]
    1b45:	add    rsp,0x50
    1b49:	mov    rsp,rbp
    1b4c:	pop    rbp
    1b4d:	ret

0000000000001b4e <botlish_entry_19: char_at<generic>>:
    1b4e:	push   rbp
    1b4f:	mov    rbp,rsp
    1b52:	ud2
    1b54:	add    BYTE PTR [rax],al
	...

0000000000001b58 <botlish_fn_20: scan_local<generic>>:
    1b58:	push   rbp
    1b59:	mov    rbp,rsp
    1b5c:	sub    rsp,0x80
    1b63:	mov    QWORD PTR [rsp+0x50],rbx
    1b68:	mov    QWORD PTR [rsp+0x58],r12
    1b6d:	mov    QWORD PTR [rsp+0x60],r13
    1b72:	mov    QWORD PTR [rsp+0x68],r14
    1b77:	mov    QWORD PTR [rsp+0x70],r15
    1b7c:	mov    QWORD PTR [rsp+0x18],0x0
    1b85:	mov    QWORD PTR [rsp],rsi
    1b89:	mov    r15,rsi
    1b8c:	mov    QWORD PTR [rsp+0x8],rdx
    1b91:	mov    QWORD PTR [rsp+0x10],rcx
    1b96:	mov    r13,rcx
    1b99:	lea    r14,[rsp+0x20]
    1b9e:	mov    rbx,rdx
    1ba1:	mov    rax,rsi
    1ba4:	and    rax,rbx
    1ba7:	mov    r15,rsi
    1baa:	test   rax,0x1
    1bb0:	jne    1bd9 <botlish_fn_20+0x81>
    1bb6:	mov    r12,rdi
    1bb9:	mov    rdx,rbx
    1bbc:	mov    rsi,r15
    1bbf:	call   1bc4 <botlish_fn_20+0x6c>
			1bc0: R_X86_64_PLT32	rt_int_cmp-0x4
    1bc4:	mov    ecx,0x2
    1bc9:	test   rax,rax
    1bcc:	cmovge rcx,QWORD PTR [rip+0x254]        # 1e28 <botlish_fn_20+0x2d0>
    1bd4:	jmp    1bef <botlish_fn_20+0x97>
    1bd9:	mov    r12,rdi
    1bdc:	mov    ecx,0x2
    1be1:	mov    rsi,r15
    1be4:	cmp    rsi,rbx
    1be7:	cmovge rcx,QWORD PTR [rip+0x239]        # 1e28 <botlish_fn_20+0x2d0>
    1bef:	cmp    rcx,0x6
    1bf3:	je     1dfa <botlish_fn_20+0x2a2>
    1bf9:	mov    rcx,r14
    1bfc:	mov    rdx,r13
    1bff:	mov    rsi,r15
    1c02:	mov    rdi,r12
    1c05:	call   1c0a <botlish_fn_20+0xb2>
			1c06: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    1c0a:	mov    rcx,rax
    1c0d:	mov    QWORD PTR [rsp+0x40],rax
    1c12:	test   rax,rcx
    1c15:	je     1c45 <botlish_fn_20+0xed>
    1c1b:	mov    rdx,QWORD PTR [rsp+0x20]
    1c20:	mov    QWORD PTR [rsp+0x38],rdx
    1c25:	mov    rcx,QWORD PTR [rsp+0x28]
    1c2a:	mov    QWORD PTR [rsp+0x30],rcx
    1c2f:	mov    rsi,QWORD PTR [rsp+0x40]
    1c34:	mov    rdi,r12
    1c37:	call   1c3c <botlish_fn_20+0xe4>
			1c38: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1c3c:	test   rax,rax
    1c3f:	jne    1c6d <botlish_fn_20+0x115>
    1c45:	xor    rax,rax
    1c48:	mov    rbx,QWORD PTR [rsp+0x50]
    1c4d:	mov    r12,QWORD PTR [rsp+0x58]
    1c52:	mov    r13,QWORD PTR [rsp+0x60]
    1c57:	mov    r14,QWORD PTR [rsp+0x68]
    1c5c:	mov    r15,QWORD PTR [rsp+0x70]
    1c61:	add    rsp,0x80
    1c68:	mov    rsp,rbp
    1c6b:	pop    rbp
    1c6c:	ret
    1c6d:	cmp    rax,0x6
    1c71:	je     1d7b <botlish_fn_20+0x223>
    1c77:	mov    r9,QWORD PTR [r12+0x10]
    1c7c:	mov    r8,QWORD PTR [r9+0xd0]
    1c83:	mov    rcx,QWORD PTR [rsp+0x30]
    1c88:	mov    rdx,QWORD PTR [rsp+0x38]
    1c8d:	mov    rsi,QWORD PTR [rsp+0x40]
    1c92:	mov    rdi,r12
    1c95:	call   1c9a <botlish_fn_20+0x142>
			1c96: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c9a:	cmp    rax,0x6
    1c9e:	je     1d71 <botlish_fn_20+0x219>
    1ca4:	mov    r11,QWORD PTR [r12+0x10]
    1ca9:	mov    r8,QWORD PTR [r11+0xd8]
    1cb0:	mov    rcx,QWORD PTR [rsp+0x30]
    1cb5:	mov    rdx,QWORD PTR [rsp+0x38]
    1cba:	mov    rsi,QWORD PTR [rsp+0x40]
    1cbf:	mov    rdi,r12
    1cc2:	call   1cc7 <botlish_fn_20+0x16f>
			1cc3: R_X86_64_PLT32	rt_str_region_eq-0x4
    1cc7:	cmp    rax,0x6
    1ccb:	je     1d67 <botlish_fn_20+0x20f>
    1cd1:	mov    rax,QWORD PTR [r12+0x10]
    1cd6:	mov    r8,QWORD PTR [rax+0xa8]
    1cdd:	mov    rcx,QWORD PTR [rsp+0x30]
    1ce2:	mov    rdx,QWORD PTR [rsp+0x38]
    1ce7:	mov    rsi,QWORD PTR [rsp+0x40]
    1cec:	mov    rdi,r12
    1cef:	call   1cf4 <botlish_fn_20+0x19c>
			1cf0: R_X86_64_PLT32	rt_str_region_eq-0x4
    1cf4:	cmp    rax,0x6
    1cf8:	je     1d5d <botlish_fn_20+0x205>
    1cfe:	mov    rax,QWORD PTR [r12+0x10]
    1d03:	mov    r8,QWORD PTR [rax+0xe0]
    1d0a:	mov    rcx,QWORD PTR [rsp+0x30]
    1d0f:	mov    rdx,QWORD PTR [rsp+0x38]
    1d14:	mov    rsi,QWORD PTR [rsp+0x40]
    1d19:	mov    rdi,r12
    1d1c:	call   1d21 <botlish_fn_20+0x1c9>
			1d1d: R_X86_64_PLT32	rt_str_region_eq-0x4
    1d21:	cmp    rax,0x6
    1d25:	je     1d53 <botlish_fn_20+0x1fb>
    1d2b:	mov    rax,QWORD PTR [r12+0x10]
    1d30:	mov    r8,QWORD PTR [rax+0xe8]
    1d37:	mov    rcx,QWORD PTR [rsp+0x30]
    1d3c:	mov    rdx,QWORD PTR [rsp+0x38]
    1d41:	mov    rsi,QWORD PTR [rsp+0x40]
    1d46:	mov    rdi,r12
    1d49:	call   1d4e <botlish_fn_20+0x1f6>
			1d4a: R_X86_64_PLT32	rt_str_region_eq-0x4
    1d4e:	jmp    1d80 <botlish_fn_20+0x228>
    1d53:	mov    eax,0x6
    1d58:	jmp    1d80 <botlish_fn_20+0x228>
    1d5d:	mov    eax,0x6
    1d62:	jmp    1d80 <botlish_fn_20+0x228>
    1d67:	mov    eax,0x6
    1d6c:	jmp    1d80 <botlish_fn_20+0x228>
    1d71:	mov    eax,0x6
    1d76:	jmp    1d80 <botlish_fn_20+0x228>
    1d7b:	mov    eax,0x6
    1d80:	cmp    rax,0x6
    1d84:	je     1d92 <botlish_fn_20+0x23a>
    1d8a:	mov    rax,r15
    1d8d:	jmp    1dfd <botlish_fn_20+0x2a5>
    1d92:	mov    QWORD PTR [rsp+0x18],0x3
    1d9b:	mov    rsi,r15
    1d9e:	test   rsi,0x1
    1da5:	je     1dcb <botlish_fn_20+0x273>
    1dab:	mov    rsi,r15
    1dae:	mov    rax,rsi
    1db1:	add    rax,0x2
    1db5:	seto   cl
    1db8:	test   cl,cl
    1dba:	jne    1dcb <botlish_fn_20+0x273>
    1dc0:	mov    rsi,rax
    1dc3:	mov    r15,rax
    1dc6:	jmp    1de1 <botlish_fn_20+0x289>
    1dcb:	mov    edx,0x3
    1dd0:	mov    rsi,r15
    1dd3:	mov    rdi,r12
    1dd6:	call   1ddb <botlish_fn_20+0x283>
			1dd7: R_X86_64_PLT32	rt_int_add-0x4
    1ddb:	mov    rsi,rax
    1dde:	mov    r15,rax
    1de1:	mov    QWORD PTR [rsp],rsi
    1de5:	mov    QWORD PTR [rsp+0x8],rbx
    1dea:	mov    QWORD PTR [rsp+0x10],r13
    1def:	mov    rsi,r15
    1df2:	mov    rdi,r12
    1df5:	jmp    1ba1 <botlish_fn_20+0x49>
    1dfa:	mov    rax,r15
    1dfd:	mov    rbx,QWORD PTR [rsp+0x50]
    1e02:	mov    r12,QWORD PTR [rsp+0x58]
    1e07:	mov    r13,QWORD PTR [rsp+0x60]
    1e0c:	mov    r14,QWORD PTR [rsp+0x68]
    1e11:	mov    r15,QWORD PTR [rsp+0x70]
    1e16:	add    rsp,0x80
    1e1d:	mov    rsp,rbp
    1e20:	pop    rbp
    1e21:	ret
    1e22:	add    BYTE PTR [rax],al
    1e24:	add    BYTE PTR [rax],al
    1e26:	add    BYTE PTR [rax],al
    1e28:	(bad)
    1e29:	add    BYTE PTR [rax],al
    1e2b:	add    BYTE PTR [rax],al
    1e2d:	add    BYTE PTR [rax],al
	...

0000000000001e30 <botlish_entry_20: scan_local<generic>>:
    1e30:	push   rbp
    1e31:	mov    rbp,rsp
    1e34:	mov    rsi,QWORD PTR [rdx]
    1e37:	mov    r8,QWORD PTR [rdx+0x8]
    1e3b:	mov    rcx,QWORD PTR [rdx+0x10]
    1e3f:	mov    rdx,r8
    1e42:	call   1e47 <botlish_entry_20+0x17>
			1e43: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    1e47:	mov    rsp,rbp
    1e4a:	pop    rbp
    1e4b:	ret
    1e4c:	add    BYTE PTR [rax],al
	...

0000000000001e50 <botlish_fn_21: scan_label<generic>>:
    1e50:	push   rbp
    1e51:	mov    rbp,rsp
    1e54:	sub    rsp,0x80
    1e5b:	mov    QWORD PTR [rsp+0x50],rbx
    1e60:	mov    QWORD PTR [rsp+0x58],r12
    1e65:	mov    QWORD PTR [rsp+0x60],r13
    1e6a:	mov    QWORD PTR [rsp+0x68],r14
    1e6f:	mov    QWORD PTR [rsp+0x70],r15
    1e74:	mov    QWORD PTR [rsp+0x18],0x0
    1e7d:	mov    QWORD PTR [rsp],rsi
    1e81:	mov    r15,rsi
    1e84:	mov    QWORD PTR [rsp+0x8],rdx
    1e89:	mov    QWORD PTR [rsp+0x10],rcx
    1e8e:	mov    r13,rcx
    1e91:	lea    r14,[rsp+0x20]
    1e96:	mov    rbx,rdx
    1e99:	mov    rax,rsi
    1e9c:	and    rax,rbx
    1e9f:	mov    r15,rsi
    1ea2:	test   rax,0x1
    1ea8:	jne    1ed1 <botlish_fn_21+0x81>
    1eae:	mov    r12,rdi
    1eb1:	mov    rdx,rbx
    1eb4:	mov    rsi,r15
    1eb7:	call   1ebc <botlish_fn_21+0x6c>
			1eb8: R_X86_64_PLT32	rt_int_cmp-0x4
    1ebc:	mov    ecx,0x2
    1ec1:	test   rax,rax
    1ec4:	cmovge rcx,QWORD PTR [rip+0x174]        # 2040 <botlish_fn_21+0x1f0>
    1ecc:	jmp    1ee7 <botlish_fn_21+0x97>
    1ed1:	mov    r12,rdi
    1ed4:	mov    ecx,0x2
    1ed9:	mov    rsi,r15
    1edc:	cmp    rsi,rbx
    1edf:	cmovge rcx,QWORD PTR [rip+0x159]        # 2040 <botlish_fn_21+0x1f0>
    1ee7:	cmp    rcx,0x6
    1eeb:	je     2013 <botlish_fn_21+0x1c3>
    1ef1:	mov    rcx,r14
    1ef4:	mov    rdx,r13
    1ef7:	mov    rsi,r15
    1efa:	mov    rdi,r12
    1efd:	call   1f02 <botlish_fn_21+0xb2>
			1efe: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    1f02:	test   rax,rax
    1f05:	mov    QWORD PTR [rsp+0x40],rax
    1f0a:	je     1f3a <botlish_fn_21+0xea>
    1f10:	mov    rdx,QWORD PTR [rsp+0x20]
    1f15:	mov    QWORD PTR [rsp+0x38],rdx
    1f1a:	mov    rcx,QWORD PTR [rsp+0x28]
    1f1f:	mov    QWORD PTR [rsp+0x30],rcx
    1f24:	mov    rsi,QWORD PTR [rsp+0x40]
    1f29:	mov    rdi,r12
    1f2c:	call   1f31 <botlish_fn_21+0xe1>
			1f2d: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1f31:	test   rax,rax
    1f34:	jne    1f62 <botlish_fn_21+0x112>
    1f3a:	xor    rax,rax
    1f3d:	mov    rbx,QWORD PTR [rsp+0x50]
    1f42:	mov    r12,QWORD PTR [rsp+0x58]
    1f47:	mov    r13,QWORD PTR [rsp+0x60]
    1f4c:	mov    r14,QWORD PTR [rsp+0x68]
    1f51:	mov    r15,QWORD PTR [rsp+0x70]
    1f56:	add    rsp,0x80
    1f5d:	mov    rsp,rbp
    1f60:	pop    rbp
    1f61:	ret
    1f62:	cmp    rax,0x6
    1f66:	je     1f94 <botlish_fn_21+0x144>
    1f6c:	mov    rax,QWORD PTR [r12+0x10]
    1f71:	mov    r8,QWORD PTR [rax+0xe8]
    1f78:	mov    rcx,QWORD PTR [rsp+0x30]
    1f7d:	mov    rdx,QWORD PTR [rsp+0x38]
    1f82:	mov    rsi,QWORD PTR [rsp+0x40]
    1f87:	mov    rdi,r12
    1f8a:	call   1f8f <botlish_fn_21+0x13f>
			1f8b: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f8f:	jmp    1f99 <botlish_fn_21+0x149>
    1f94:	mov    eax,0x6
    1f99:	cmp    rax,0x6
    1f9d:	je     1fab <botlish_fn_21+0x15b>
    1fa3:	mov    rax,r15
    1fa6:	jmp    2016 <botlish_fn_21+0x1c6>
    1fab:	mov    QWORD PTR [rsp+0x18],0x3
    1fb4:	mov    rsi,r15
    1fb7:	test   rsi,0x1
    1fbe:	je     1fe4 <botlish_fn_21+0x194>
    1fc4:	mov    rsi,r15
    1fc7:	mov    rax,rsi
    1fca:	add    rax,0x2
    1fce:	seto   cl
    1fd1:	test   cl,cl
    1fd3:	jne    1fe4 <botlish_fn_21+0x194>
    1fd9:	mov    rsi,rax
    1fdc:	mov    r15,rax
    1fdf:	jmp    1ffa <botlish_fn_21+0x1aa>
    1fe4:	mov    edx,0x3
    1fe9:	mov    rsi,r15
    1fec:	mov    rdi,r12
    1fef:	call   1ff4 <botlish_fn_21+0x1a4>
			1ff0: R_X86_64_PLT32	rt_int_add-0x4
    1ff4:	mov    rsi,rax
    1ff7:	mov    r15,rax
    1ffa:	mov    QWORD PTR [rsp],rsi
    1ffe:	mov    QWORD PTR [rsp+0x8],rbx
    2003:	mov    QWORD PTR [rsp+0x10],r13
    2008:	mov    rsi,r15
    200b:	mov    rdi,r12
    200e:	jmp    1e99 <botlish_fn_21+0x49>
    2013:	mov    rax,r15
    2016:	mov    rbx,QWORD PTR [rsp+0x50]
    201b:	mov    r12,QWORD PTR [rsp+0x58]
    2020:	mov    r13,QWORD PTR [rsp+0x60]
    2025:	mov    r14,QWORD PTR [rsp+0x68]
    202a:	mov    r15,QWORD PTR [rsp+0x70]
    202f:	add    rsp,0x80
    2036:	mov    rsp,rbp
    2039:	pop    rbp
    203a:	ret
    203b:	add    BYTE PTR [rax],al
    203d:	add    BYTE PTR [rax],al
    203f:	add    BYTE PTR [rsi],al
    2041:	add    BYTE PTR [rax],al
    2043:	add    BYTE PTR [rax],al
    2045:	add    BYTE PTR [rax],al
	...

0000000000002048 <botlish_entry_21: scan_label<generic>>:
    2048:	push   rbp
    2049:	mov    rbp,rsp
    204c:	mov    rsi,QWORD PTR [rdx]
    204f:	mov    r8,QWORD PTR [rdx+0x8]
    2053:	mov    rcx,QWORD PTR [rdx+0x10]
    2057:	mov    rdx,r8
    205a:	call   205f <botlish_entry_21+0x17>
			205b: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    205f:	mov    rsp,rbp
    2062:	pop    rbp
    2063:	ret
    2064:	add    BYTE PTR [rax],al
	...

0000000000002068 <botlish_fn_22: scan_alpha<generic>>:
    2068:	push   rbp
    2069:	mov    rbp,rsp
    206c:	sub    rsp,0x60
    2070:	mov    QWORD PTR [rsp+0x30],rbx
    2075:	mov    QWORD PTR [rsp+0x38],r12
    207a:	mov    QWORD PTR [rsp+0x40],r13
    207f:	mov    QWORD PTR [rsp+0x48],r14
    2084:	mov    QWORD PTR [rsp+0x50],r15
    2089:	mov    r15,rdi
    208c:	mov    QWORD PTR [rsp+0x18],0x0
    2095:	mov    QWORD PTR [rsp],rsi
    2099:	mov    r14,rsi
    209c:	mov    QWORD PTR [rsp+0x8],rdx
    20a1:	mov    QWORD PTR [rsp+0x10],rcx
    20a6:	mov    r12,rcx
    20a9:	lea    r13,[rsp+0x20]
    20ae:	mov    rbx,rdx
    20b1:	mov    rax,rsi
    20b4:	and    rax,rbx
    20b7:	mov    r14,rsi
    20ba:	test   rax,0x1
    20c0:	jne    20e9 <botlish_fn_22+0x81>
    20c6:	mov    rdx,rbx
    20c9:	mov    rsi,r14
    20cc:	mov    rdi,r15
    20cf:	call   20d4 <botlish_fn_22+0x6c>
			20d0: R_X86_64_PLT32	rt_int_cmp-0x4
    20d4:	mov    ecx,0x2
    20d9:	test   rax,rax
    20dc:	cmovge rcx,QWORD PTR [rip+0x11c]        # 2200 <botlish_fn_22+0x198>
    20e4:	jmp    20fc <botlish_fn_22+0x94>
    20e9:	mov    ecx,0x2
    20ee:	mov    rsi,r14
    20f1:	cmp    rsi,rbx
    20f4:	cmovge rcx,QWORD PTR [rip+0x104]        # 2200 <botlish_fn_22+0x198>
    20fc:	cmp    rcx,0x6
    2100:	je     21da <botlish_fn_22+0x172>
    2106:	mov    rcx,r13
    2109:	mov    rdx,r12
    210c:	mov    rsi,r14
    210f:	mov    rdi,r15
    2112:	call   2117 <botlish_fn_22+0xaf>
			2113: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    2117:	test   rax,rax
    211a:	mov    rsi,rax
    211d:	je     213e <botlish_fn_22+0xd6>
    2123:	mov    rdx,QWORD PTR [rsp+0x20]
    2128:	mov    rcx,QWORD PTR [rsp+0x28]
    212d:	mov    rdi,r15
    2130:	call   2135 <botlish_fn_22+0xcd>
			2131: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    2135:	test   rax,rax
    2138:	jne    2163 <botlish_fn_22+0xfb>
    213e:	xor    rax,rax
    2141:	mov    rbx,QWORD PTR [rsp+0x30]
    2146:	mov    r12,QWORD PTR [rsp+0x38]
    214b:	mov    r13,QWORD PTR [rsp+0x40]
    2150:	mov    r14,QWORD PTR [rsp+0x48]
    2155:	mov    r15,QWORD PTR [rsp+0x50]
    215a:	add    rsp,0x60
    215e:	mov    rsp,rbp
    2161:	pop    rbp
    2162:	ret
    2163:	cmp    rax,0x6
    2167:	je     2175 <botlish_fn_22+0x10d>
    216d:	mov    rax,r14
    2170:	jmp    21dd <botlish_fn_22+0x175>
    2175:	mov    QWORD PTR [rsp+0x18],0x3
    217e:	mov    rsi,r14
    2181:	test   rsi,0x1
    2188:	je     21ae <botlish_fn_22+0x146>
    218e:	mov    rsi,r14
    2191:	mov    rcx,rsi
    2194:	add    rcx,0x2
    2198:	seto   al
    219b:	test   al,al
    219d:	jne    21ae <botlish_fn_22+0x146>
    21a3:	mov    rsi,rcx
    21a6:	mov    r14,rcx
    21a9:	jmp    21c4 <botlish_fn_22+0x15c>
    21ae:	mov    edx,0x3
    21b3:	mov    rsi,r14
    21b6:	mov    rdi,r15
    21b9:	call   21be <botlish_fn_22+0x156>
			21ba: R_X86_64_PLT32	rt_int_add-0x4
    21be:	mov    rsi,rax
    21c1:	mov    r14,rax
    21c4:	mov    QWORD PTR [rsp],rsi
    21c8:	mov    QWORD PTR [rsp+0x8],rbx
    21cd:	mov    QWORD PTR [rsp+0x10],r12
    21d2:	mov    rsi,r14
    21d5:	jmp    20b1 <botlish_fn_22+0x49>
    21da:	mov    rax,r14
    21dd:	mov    rbx,QWORD PTR [rsp+0x30]
    21e2:	mov    r12,QWORD PTR [rsp+0x38]
    21e7:	mov    r13,QWORD PTR [rsp+0x40]
    21ec:	mov    r14,QWORD PTR [rsp+0x48]
    21f1:	mov    r15,QWORD PTR [rsp+0x50]
    21f6:	add    rsp,0x60
    21fa:	mov    rsp,rbp
    21fd:	pop    rbp
    21fe:	ret
    21ff:	add    BYTE PTR [rsi],al
    2201:	add    BYTE PTR [rax],al
    2203:	add    BYTE PTR [rax],al
    2205:	add    BYTE PTR [rax],al
	...

0000000000002208 <botlish_entry_22: scan_alpha<generic>>:
    2208:	push   rbp
    2209:	mov    rbp,rsp
    220c:	mov    rsi,QWORD PTR [rdx]
    220f:	mov    r8,QWORD PTR [rdx+0x8]
    2213:	mov    rcx,QWORD PTR [rdx+0x10]
    2217:	mov    rdx,r8
    221a:	call   221f <botlish_entry_22+0x17>
			221b: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    221f:	mov    rsp,rbp
    2222:	pop    rbp
    2223:	ret
    2224:	add    BYTE PTR [rax],al
	...

0000000000002228 <botlish_fn_23: tld_ok<generic>>:
    2228:	push   rbp
    2229:	mov    rbp,rsp
    222c:	sub    rsp,0x40
    2230:	mov    QWORD PTR [rsp+0x20],rbx
    2235:	mov    QWORD PTR [rsp+0x28],r12
    223a:	mov    QWORD PTR [rsp+0x30],r13
    223f:	mov    QWORD PTR [rsp+0x38],r14
    2244:	mov    r12,rdi
    2247:	mov    QWORD PTR [rsp],rsi
    224b:	mov    rdi,rsi
    224e:	mov    QWORD PTR [rsp+0x8],rdx
    2253:	mov    r14,rdx
    2256:	mov    QWORD PTR [rsp+0x10],rcx
    225b:	mov    rbx,rdi
    225e:	mov    rdx,r14
    2261:	mov    rsi,rbx
    2264:	mov    rdi,r12
    2267:	call   226c <botlish_fn_23+0x44>
			2268: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    226c:	mov    rcx,rax
    226f:	mov    r13,rax
    2272:	test   rax,rcx
    2275:	jne    229b <botlish_fn_23+0x73>
    227b:	xor    rax,rax
    227e:	mov    rbx,QWORD PTR [rsp+0x20]
    2283:	mov    r12,QWORD PTR [rsp+0x28]
    2288:	mov    r13,QWORD PTR [rsp+0x30]
    228d:	mov    r14,QWORD PTR [rsp+0x38]
    2292:	add    rsp,0x40
    2296:	mov    rsp,rbp
    2299:	pop    rbp
    229a:	ret
    229b:	mov    rax,r13
    229e:	mov    QWORD PTR [rsp+0x8],rax
    22a3:	mov    rdx,r14
    22a6:	and    rax,rdx
    22a9:	test   rax,0x1
    22af:	jne    22d8 <botlish_fn_23+0xb0>
    22b5:	mov    rsi,r13
    22b8:	mov    rdi,r12
    22bb:	call   22c0 <botlish_fn_23+0x98>
			22bc: R_X86_64_PLT32	rt_int_cmp-0x4
    22c0:	mov    ecx,0x2
    22c5:	test   rax,rax
    22c8:	cmove  rcx,QWORD PTR [rip+0xe0]        # 23b0 <botlish_fn_23+0x188>
    22d0:	mov    rax,r13
    22d3:	jmp    22eb <botlish_fn_23+0xc3>
    22d8:	mov    ecx,0x2
    22dd:	mov    rax,r13
    22e0:	cmp    rax,rdx
    22e3:	cmove  rcx,QWORD PTR [rip+0xc5]        # 23b0 <botlish_fn_23+0x188>
    22eb:	cmp    rcx,0x6
    22ef:	je     2302 <botlish_fn_23+0xda>
    22f5:	mov    ecx,0x2
    22fa:	mov    rax,rcx
    22fd:	jmp    238f <botlish_fn_23+0x167>
    2302:	mov    rcx,rax
    2305:	and    rcx,rbx
    2308:	test   rcx,0x1
    230f:	jne    2320 <botlish_fn_23+0xf8>
    2315:	mov    rdx,rbx
    2318:	mov    rsi,rax
    231b:	jmp    2341 <botlish_fn_23+0x119>
    2320:	mov    rcx,rax
    2323:	sub    rcx,rbx
    2326:	mov    rdi,rbx
    2329:	mov    r13,rax
    232c:	seto   al
    232f:	lea    rsi,[rcx+0x1]
    2333:	test   al,al
    2335:	je     234c <botlish_fn_23+0x124>
    233b:	mov    rdx,rdi
    233e:	mov    rsi,r13
    2341:	mov    rdi,r12
    2344:	call   2349 <botlish_fn_23+0x121>
			2345: R_X86_64_PLT32	rt_int_sub-0x4
    2349:	mov    rsi,rax
    234c:	test   rsi,0x1
    2353:	jne    237e <botlish_fn_23+0x156>
    2359:	mov    edx,0x5
    235e:	mov    rdi,r12
    2361:	call   2366 <botlish_fn_23+0x13e>
			2362: R_X86_64_PLT32	rt_int_cmp-0x4
    2366:	mov    ecx,0x2
    236b:	test   rax,rax
    236e:	mov    rax,rcx
    2371:	cmovge rax,QWORD PTR [rip+0x37]        # 23b0 <botlish_fn_23+0x188>
    2379:	jmp    238f <botlish_fn_23+0x167>
    237e:	mov    eax,0x2
    2383:	cmp    rsi,0x5
    2387:	cmovge rax,QWORD PTR [rip+0x21]        # 23b0 <botlish_fn_23+0x188>
    238f:	mov    rbx,QWORD PTR [rsp+0x20]
    2394:	mov    r12,QWORD PTR [rsp+0x28]
    2399:	mov    r13,QWORD PTR [rsp+0x30]
    239e:	mov    r14,QWORD PTR [rsp+0x38]
    23a3:	add    rsp,0x40
    23a7:	mov    rsp,rbp
    23aa:	pop    rbp
    23ab:	ret
    23ac:	add    BYTE PTR [rax],al
    23ae:	add    BYTE PTR [rax],al
    23b0:	(bad)
    23b1:	add    BYTE PTR [rax],al
    23b3:	add    BYTE PTR [rax],al
    23b5:	add    BYTE PTR [rax],al
	...

00000000000023b8 <botlish_entry_23: tld_ok<generic>>:
    23b8:	push   rbp
    23b9:	mov    rbp,rsp
    23bc:	mov    rsi,QWORD PTR [rdx]
    23bf:	mov    r8,QWORD PTR [rdx+0x8]
    23c3:	mov    rcx,QWORD PTR [rdx+0x10]
    23c7:	mov    rdx,r8
    23ca:	call   23cf <botlish_entry_23+0x17>
			23cb: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    23cf:	mov    rsp,rbp
    23d2:	pop    rbp
    23d3:	ret
    23d4:	add    BYTE PTR [rax],al
	...

00000000000023d8 <botlish_fn_24: domain_loop<generic>>:
    23d8:	push   rbp
    23d9:	mov    rbp,rsp
    23dc:	sub    rsp,0x70
    23e0:	mov    QWORD PTR [rsp+0x40],rbx
    23e5:	mov    QWORD PTR [rsp+0x48],r12
    23ea:	mov    QWORD PTR [rsp+0x50],r13
    23ef:	mov    QWORD PTR [rsp+0x58],r14
    23f4:	mov    QWORD PTR [rsp+0x60],r15
    23f9:	mov    QWORD PTR [rsp+0x18],0x0
    2402:	mov    QWORD PTR [rsp],rsi
    2406:	mov    QWORD PTR [rsp+0x8],rdx
    240b:	mov    QWORD PTR [rsp+0x10],rcx
    2410:	lea    rbx,[rsp+0x20]
    2415:	mov    r12,rdi
    2418:	mov    r13,rcx
    241b:	mov    r14,rdx
    241e:	mov    QWORD PTR [rsp+0x30],rsi
    2423:	mov    rcx,r13
    2426:	mov    rdx,r14
    2429:	mov    rsi,QWORD PTR [rsp+0x30]
    242e:	mov    rdi,r12
    2431:	call   2436 <botlish_fn_24+0x5e>
			2432: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    2436:	mov    rcx,rax
    2439:	mov    r15,rax
    243c:	test   rax,rcx
    243f:	je     2596 <botlish_fn_24+0x1be>
    2445:	mov    rax,r15
    2448:	mov    QWORD PTR [rsp],rax
    244c:	mov    rdx,QWORD PTR [rsp+0x30]
    2451:	and    rax,rdx
    2454:	test   rax,0x1
    245a:	jne    2480 <botlish_fn_24+0xa8>
    2460:	mov    rsi,r15
    2463:	mov    rdi,r12
    2466:	call   246b <botlish_fn_24+0x93>
			2467: R_X86_64_PLT32	rt_int_cmp-0x4
    246b:	mov    ecx,0x2
    2470:	test   rax,rax
    2473:	cmove  rcx,QWORD PTR [rip+0x19d]        # 2618 <botlish_fn_24+0x240>
    247b:	jmp    2490 <botlish_fn_24+0xb8>
    2480:	mov    ecx,0x2
    2485:	cmp    r15,rdx
    2488:	cmove  rcx,QWORD PTR [rip+0x188]        # 2618 <botlish_fn_24+0x240>
    2490:	cmp    rcx,0x6
    2494:	je     25ec <botlish_fn_24+0x214>
    249a:	mov    rax,r15
    249d:	and    rax,r14
    24a0:	test   rax,0x1
    24a6:	jne    24cf <botlish_fn_24+0xf7>
    24ac:	mov    rdx,r14
    24af:	mov    rsi,r15
    24b2:	mov    rdi,r12
    24b5:	call   24ba <botlish_fn_24+0xe2>
			24b6: R_X86_64_PLT32	rt_int_cmp-0x4
    24ba:	mov    ecx,0x2
    24bf:	test   rax,rax
    24c2:	cmovge rcx,QWORD PTR [rip+0x14e]        # 2618 <botlish_fn_24+0x240>
    24ca:	jmp    24df <botlish_fn_24+0x107>
    24cf:	mov    ecx,0x2
    24d4:	cmp    r15,r14
    24d7:	cmovge rcx,QWORD PTR [rip+0x139]        # 2618 <botlish_fn_24+0x240>
    24df:	cmp    rcx,0x6
    24e3:	je     25dd <botlish_fn_24+0x205>
    24e9:	mov    rcx,rbx
    24ec:	mov    rdx,r13
    24ef:	mov    rsi,r15
    24f2:	mov    rdi,r12
    24f5:	call   24fa <botlish_fn_24+0x122>
			24f6: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    24fa:	test   rax,rax
    24fd:	je     2596 <botlish_fn_24+0x1be>
    2503:	mov    rdx,QWORD PTR [rsp+0x20]
    2508:	mov    rcx,QWORD PTR [rsp+0x28]
    250d:	mov    rsi,QWORD PTR [r12+0x10]
    2512:	mov    r8,QWORD PTR [rsi+0xd0]
    2519:	mov    rsi,rax
    251c:	mov    rdi,r12
    251f:	call   2524 <botlish_fn_24+0x14c>
			2520: R_X86_64_PLT32	rt_str_region_eq-0x4
    2524:	cmp    rax,0x6
    2528:	je     253a <botlish_fn_24+0x162>
    252e:	mov    r14,0xffffffffffffffff
    2535:	jmp    25e4 <botlish_fn_24+0x20c>
    253a:	mov    QWORD PTR [rsp+0x18],0x3
    2543:	test   r15,0x1
    254a:	je     2562 <botlish_fn_24+0x18a>
    2550:	mov    rdx,r15
    2553:	add    rdx,0x2
    2557:	seto   al
    255a:	test   al,al
    255c:	je     2575 <botlish_fn_24+0x19d>
    2562:	mov    edx,0x3
    2567:	mov    rsi,r15
    256a:	mov    rdi,r12
    256d:	call   2572 <botlish_fn_24+0x19a>
			256e: R_X86_64_PLT32	rt_int_add-0x4
    2572:	mov    rdx,rax
    2575:	mov    QWORD PTR [rsp],rdx
    2579:	mov    r15,rdx
    257c:	mov    rcx,r13
    257f:	mov    rdx,r14
    2582:	mov    rsi,r15
    2585:	mov    rdi,r12
    2588:	call   258d <botlish_fn_24+0x1b5>
			2589: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    258d:	test   rax,rax
    2590:	jne    25bb <botlish_fn_24+0x1e3>
    2596:	xor    rax,rax
    2599:	mov    rbx,QWORD PTR [rsp+0x40]
    259e:	mov    r12,QWORD PTR [rsp+0x48]
    25a3:	mov    r13,QWORD PTR [rsp+0x50]
    25a8:	mov    r14,QWORD PTR [rsp+0x58]
    25ad:	mov    r15,QWORD PTR [rsp+0x60]
    25b2:	add    rsp,0x70
    25b6:	mov    rsp,rbp
    25b9:	pop    rbp
    25ba:	ret
    25bb:	cmp    rax,0x6
    25bf:	je     25e4 <botlish_fn_24+0x20c>
    25c5:	mov    QWORD PTR [rsp],r15
    25c9:	mov    QWORD PTR [rsp+0x8],r14
    25ce:	mov    QWORD PTR [rsp+0x10],r13
    25d3:	mov    QWORD PTR [rsp+0x30],r15
    25d8:	jmp    2423 <botlish_fn_24+0x4b>
    25dd:	mov    r14,0xffffffffffffffff
    25e4:	mov    rax,r14
    25e7:	jmp    25f3 <botlish_fn_24+0x21b>
    25ec:	mov    rax,0xffffffffffffffff
    25f3:	mov    rbx,QWORD PTR [rsp+0x40]
    25f8:	mov    r12,QWORD PTR [rsp+0x48]
    25fd:	mov    r13,QWORD PTR [rsp+0x50]
    2602:	mov    r14,QWORD PTR [rsp+0x58]
    2607:	mov    r15,QWORD PTR [rsp+0x60]
    260c:	add    rsp,0x70
    2610:	mov    rsp,rbp
    2613:	pop    rbp
    2614:	ret
    2615:	add    BYTE PTR [rax],al
    2617:	add    BYTE PTR [rsi],al
    2619:	add    BYTE PTR [rax],al
    261b:	add    BYTE PTR [rax],al
    261d:	add    BYTE PTR [rax],al
	...

0000000000002620 <botlish_entry_24: domain_loop<generic>>:
    2620:	push   rbp
    2621:	mov    rbp,rsp
    2624:	mov    rsi,QWORD PTR [rdx]
    2627:	mov    r8,QWORD PTR [rdx+0x8]
    262b:	mov    rcx,QWORD PTR [rdx+0x10]
    262f:	mov    rdx,r8
    2632:	call   2637 <botlish_entry_24+0x17>
			2633: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    2637:	mov    rsp,rbp
    263a:	pop    rbp
    263b:	ret
    263c:	add    BYTE PTR [rax],al
	...

0000000000002640 <botlish_fn_25: <str>>:
    2640:	push   rbp
    2641:	mov    rbp,rsp
    2644:	sub    rsp,0x50
    2648:	mov    QWORD PTR [rsp+0x30],rbx
    264d:	mov    QWORD PTR [rsp+0x38],r12
    2652:	mov    QWORD PTR [rsp+0x40],r13
    2657:	mov    QWORD PTR [rsp+0x48],r14
    265c:	mov    r13,rdi
    265f:	mov    QWORD PTR [rsp+0x18],0x0
    2668:	mov    QWORD PTR [rsp],rsi
    266c:	mov    r14,rsi
    266f:	mov    rsi,r14
    2672:	mov    rdi,r13
    2675:	call   267a <botlish_fn_25+0x3a>
			2676: R_X86_64_PLT32	rt_str_len-0x4
    267a:	mov    rbx,rax
    267d:	mov    QWORD PTR [rsp+0x8],rax
    2682:	mov    esi,0x1
    2687:	mov    QWORD PTR [rsp+0x10],0x1
    2690:	mov    rcx,r14
    2693:	mov    rdx,rbx
    2696:	mov    rdi,r13
    2699:	call   269e <botlish_fn_25+0x5e>
			269a: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    269e:	mov    r12,rax
    26a1:	test   r12,r12
    26a4:	je     2801 <botlish_fn_25+0x1c1>
    26aa:	mov    QWORD PTR [rsp+0x10],r12
    26af:	test   r12,0x1
    26b6:	jne    26e1 <botlish_fn_25+0xa1>
    26bc:	mov    edx,0x1
    26c1:	mov    rsi,r12
    26c4:	mov    rdi,r13
    26c7:	call   26cc <botlish_fn_25+0x8c>
			26c8: R_X86_64_PLT32	rt_int_cmp-0x4
    26cc:	mov    ecx,0x2
    26d1:	test   rax,rax
    26d4:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 28a0 <botlish_fn_25+0x260>
    26dc:	jmp    26f2 <botlish_fn_25+0xb2>
    26e1:	mov    ecx,0x2
    26e6:	cmp    r12,0x1
    26ea:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 28a0 <botlish_fn_25+0x260>
    26f2:	cmp    rcx,0x6
    26f6:	je     287c <botlish_fn_25+0x23c>
    26fc:	mov    rcx,r12
    26ff:	and    rcx,rbx
    2702:	test   rcx,0x1
    2709:	jne    2732 <botlish_fn_25+0xf2>
    270f:	mov    rdx,rbx
    2712:	mov    rsi,r12
    2715:	mov    rdi,r13
    2718:	call   271d <botlish_fn_25+0xdd>
			2719: R_X86_64_PLT32	rt_int_cmp-0x4
    271d:	mov    ecx,0x2
    2722:	test   rax,rax
    2725:	cmovge rcx,QWORD PTR [rip+0x173]        # 28a0 <botlish_fn_25+0x260>
    272d:	jmp    2742 <botlish_fn_25+0x102>
    2732:	mov    ecx,0x2
    2737:	cmp    r12,rbx
    273a:	cmovge rcx,QWORD PTR [rip+0x15e]        # 28a0 <botlish_fn_25+0x260>
    2742:	cmp    rcx,0x6
    2746:	je     2872 <botlish_fn_25+0x232>
    274c:	lea    rcx,[rsp+0x20]
    2751:	mov    rdx,r14
    2754:	mov    rsi,r12
    2757:	mov    rdi,r13
    275a:	call   275f <botlish_fn_25+0x11f>
			275b: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    275f:	test   rax,rax
    2762:	mov    rsi,rax
    2765:	je     2801 <botlish_fn_25+0x1c1>
    276b:	mov    rdx,QWORD PTR [rsp+0x20]
    2770:	mov    rcx,QWORD PTR [rsp+0x28]
    2775:	mov    rdi,r13
    2778:	mov    rax,QWORD PTR [rdi+0x10]
    277c:	mov    r8,QWORD PTR [rax+0xc8]
    2783:	call   2788 <botlish_fn_25+0x148>
			2784: R_X86_64_PLT32	rt_str_region_eq-0x4
    2788:	cmp    rax,0x6
    278c:	je     279f <botlish_fn_25+0x15f>
    2792:	mov    ecx,0x2
    2797:	mov    rax,rcx
    279a:	jmp    2881 <botlish_fn_25+0x241>
    279f:	mov    QWORD PTR [rsp+0x18],0x3
    27a8:	test   r12,0x1
    27af:	jne    27bd <botlish_fn_25+0x17d>
    27b5:	mov    rcx,r12
    27b8:	jmp    27d2 <botlish_fn_25+0x192>
    27bd:	mov    rsi,r12
    27c0:	add    rsi,0x2
    27c4:	mov    rcx,r12
    27c7:	seto   al
    27ca:	test   al,al
    27cc:	je     27e5 <botlish_fn_25+0x1a5>
    27d2:	mov    edx,0x3
    27d7:	mov    rsi,rcx
    27da:	mov    rdi,r13
    27dd:	call   27e2 <botlish_fn_25+0x1a2>
			27de: R_X86_64_PLT32	rt_int_add-0x4
    27e2:	mov    rsi,rax
    27e5:	mov    QWORD PTR [rsp+0x10],rsi
    27ea:	mov    rcx,r14
    27ed:	mov    rdx,rbx
    27f0:	mov    rdi,r13
    27f3:	call   27f8 <botlish_fn_25+0x1b8>
			27f4: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    27f8:	test   rax,rax
    27fb:	jne    2821 <botlish_fn_25+0x1e1>
    2801:	xor    rax,rax
    2804:	mov    rbx,QWORD PTR [rsp+0x30]
    2809:	mov    r12,QWORD PTR [rsp+0x38]
    280e:	mov    r13,QWORD PTR [rsp+0x40]
    2813:	mov    r14,QWORD PTR [rsp+0x48]
    2818:	add    rsp,0x50
    281c:	mov    rsp,rbp
    281f:	pop    rbp
    2820:	ret
    2821:	mov    rcx,rax
    2824:	and    rcx,rbx
    2827:	mov    rsi,rax
    282a:	test   rcx,0x1
    2831:	jne    285a <botlish_fn_25+0x21a>
    2837:	mov    rdx,rbx
    283a:	mov    rdi,r13
    283d:	call   2842 <botlish_fn_25+0x202>
			283e: R_X86_64_PLT32	rt_int_cmp-0x4
    2842:	mov    ecx,0x2
    2847:	test   rax,rax
    284a:	mov    rax,rcx
    284d:	cmove  rax,QWORD PTR [rip+0x4b]        # 28a0 <botlish_fn_25+0x260>
    2855:	jmp    2881 <botlish_fn_25+0x241>
    285a:	mov    rdx,rbx
    285d:	mov    eax,0x2
    2862:	cmp    rsi,rdx
    2865:	cmove  rax,QWORD PTR [rip+0x33]        # 28a0 <botlish_fn_25+0x260>
    286d:	jmp    2881 <botlish_fn_25+0x241>
    2872:	mov    eax,0x2
    2877:	jmp    2881 <botlish_fn_25+0x241>
    287c:	mov    eax,0x2
    2881:	mov    rbx,QWORD PTR [rsp+0x30]
    2886:	mov    r12,QWORD PTR [rsp+0x38]
    288b:	mov    r13,QWORD PTR [rsp+0x40]
    2890:	mov    r14,QWORD PTR [rsp+0x48]
    2895:	add    rsp,0x50
    2899:	mov    rsp,rbp
    289c:	pop    rbp
    289d:	ret
    289e:	add    BYTE PTR [rax],al
    28a0:	(bad)
    28a1:	add    BYTE PTR [rax],al
    28a3:	add    BYTE PTR [rax],al
    28a5:	add    BYTE PTR [rax],al
	...

00000000000028a8 <botlish_entry_25: <str>>:
    28a8:	push   rbp
    28a9:	mov    rbp,rsp
    28ac:	mov    rsi,QWORD PTR [rdx]
    28af:	call   28b4 <botlish_entry_25+0xc>
			28b0: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    28b4:	mov    rsp,rbp
    28b7:	pop    rbp
    28b8:	ret
    28b9:	add    BYTE PTR [rax],al
    28bb:	add    BYTE PTR [rax],al
    28bd:	add    BYTE PTR [rax],al
	...

00000000000028c0 <botlish_fn_26: <generic>>:
    28c0:	push   rbp
    28c1:	mov    rbp,rsp
    28c4:	sub    rsp,0x60
    28c8:	mov    QWORD PTR [rsp+0x30],rbx
    28cd:	mov    QWORD PTR [rsp+0x38],r12
    28d2:	mov    QWORD PTR [rsp+0x40],r13
    28d7:	mov    QWORD PTR [rsp+0x48],r14
    28dc:	mov    QWORD PTR [rsp+0x50],r15
    28e1:	mov    QWORD PTR [rsp+0x18],0x0
    28ea:	mov    QWORD PTR [rsp],rsi
    28ee:	xor    r8d,r8d
    28f1:	test   rsi,0x7
    28f8:	jne    2908 <botlish_fn_26+0x48>
    28fe:	movzx  rax,BYTE PTR [rsi]
    2902:	cmp    al,0x2
    2904:	sete   r8b
    2908:	test   r8b,r8b
    290b:	jne    292b <botlish_fn_26+0x6b>
    2911:	mov    rdx,QWORD PTR [rdi+0x10]
    2915:	mov    rcx,QWORD PTR [rdx+0xb0]
    291c:	mov    edx,0x1
    2921:	call   2926 <botlish_fn_26+0x66>
			2922: R_X86_64_PLT32	rt_type_error-0x4
    2926:	jmp    2ac0 <botlish_fn_26+0x200>
    292b:	mov    r13,rsi
    292e:	mov    r14,rdi
    2931:	call   2936 <botlish_fn_26+0x76>
			2932: R_X86_64_PLT32	rt_str_len-0x4
    2936:	mov    rbx,rax
    2939:	mov    QWORD PTR [rsp+0x8],rax
    293e:	mov    edx,0x1
    2943:	mov    r15,rdx
    2946:	mov    QWORD PTR [rsp+0x10],0x1
    294f:	mov    rcx,r13
    2952:	mov    rdx,rbx
    2955:	mov    rsi,r15
    2958:	mov    rdi,r14
    295b:	call   2960 <botlish_fn_26+0xa0>
			295c: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    2960:	mov    r12,rax
    2963:	test   r12,r12
    2966:	je     2ac0 <botlish_fn_26+0x200>
    296c:	mov    QWORD PTR [rsp+0x10],r12
    2971:	test   r12,0x1
    2978:	jne    29a1 <botlish_fn_26+0xe1>
    297e:	mov    rdx,r15
    2981:	mov    rsi,r12
    2984:	mov    rdi,r14
    2987:	call   298c <botlish_fn_26+0xcc>
			2988: R_X86_64_PLT32	rt_int_cmp-0x4
    298c:	mov    ecx,0x2
    2991:	test   rax,rax
    2994:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 2b68 <botlish_fn_26+0x2a8>
    299c:	jmp    29b2 <botlish_fn_26+0xf2>
    29a1:	mov    ecx,0x2
    29a6:	cmp    r12,0x1
    29aa:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 2b68 <botlish_fn_26+0x2a8>
    29b2:	cmp    rcx,0x6
    29b6:	je     2b40 <botlish_fn_26+0x280>
    29bc:	mov    rax,r12
    29bf:	and    rax,rbx
    29c2:	test   rax,0x1
    29c8:	jne    29f1 <botlish_fn_26+0x131>
    29ce:	mov    rdx,rbx
    29d1:	mov    rsi,r12
    29d4:	mov    rdi,r14
    29d7:	call   29dc <botlish_fn_26+0x11c>
			29d8: R_X86_64_PLT32	rt_int_cmp-0x4
    29dc:	mov    ecx,0x2
    29e1:	test   rax,rax
    29e4:	cmovge rcx,QWORD PTR [rip+0x17c]        # 2b68 <botlish_fn_26+0x2a8>
    29ec:	jmp    2a01 <botlish_fn_26+0x141>
    29f1:	mov    ecx,0x2
    29f6:	cmp    r12,rbx
    29f9:	cmovge rcx,QWORD PTR [rip+0x167]        # 2b68 <botlish_fn_26+0x2a8>
    2a01:	cmp    rcx,0x6
    2a05:	je     2b36 <botlish_fn_26+0x276>
    2a0b:	lea    rcx,[rsp+0x20]
    2a10:	mov    rdx,r13
    2a13:	mov    rsi,r12
    2a16:	mov    rdi,r14
    2a19:	call   2a1e <botlish_fn_26+0x15e>
			2a1a: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    2a1e:	test   rax,rax
    2a21:	mov    rsi,rax
    2a24:	je     2ac0 <botlish_fn_26+0x200>
    2a2a:	mov    rdx,QWORD PTR [rsp+0x20]
    2a2f:	mov    rcx,QWORD PTR [rsp+0x28]
    2a34:	mov    rdi,r14
    2a37:	mov    rax,QWORD PTR [rdi+0x10]
    2a3b:	mov    r8,QWORD PTR [rax+0xc8]
    2a42:	call   2a47 <botlish_fn_26+0x187>
			2a43: R_X86_64_PLT32	rt_str_region_eq-0x4
    2a47:	cmp    rax,0x6
    2a4b:	je     2a5e <botlish_fn_26+0x19e>
    2a51:	mov    ecx,0x2
    2a56:	mov    rax,rcx
    2a59:	jmp    2b45 <botlish_fn_26+0x285>
    2a5e:	mov    QWORD PTR [rsp+0x18],0x3
    2a67:	test   r12,0x1
    2a6e:	jne    2a7c <botlish_fn_26+0x1bc>
    2a74:	mov    rdi,r12
    2a77:	jmp    2a91 <botlish_fn_26+0x1d1>
    2a7c:	mov    rsi,r12
    2a7f:	add    rsi,0x2
    2a83:	mov    rdi,r12
    2a86:	seto   al
    2a89:	test   al,al
    2a8b:	je     2aa4 <botlish_fn_26+0x1e4>
    2a91:	mov    edx,0x3
    2a96:	mov    rsi,rdi
    2a99:	mov    rdi,r14
    2a9c:	call   2aa1 <botlish_fn_26+0x1e1>
			2a9d: R_X86_64_PLT32	rt_int_add-0x4
    2aa1:	mov    rsi,rax
    2aa4:	mov    QWORD PTR [rsp+0x10],rsi
    2aa9:	mov    rcx,r13
    2aac:	mov    rdx,rbx
    2aaf:	mov    rdi,r14
    2ab2:	call   2ab7 <botlish_fn_26+0x1f7>
			2ab3: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    2ab7:	test   rax,rax
    2aba:	jne    2ae5 <botlish_fn_26+0x225>
    2ac0:	xor    rax,rax
    2ac3:	mov    rbx,QWORD PTR [rsp+0x30]
    2ac8:	mov    r12,QWORD PTR [rsp+0x38]
    2acd:	mov    r13,QWORD PTR [rsp+0x40]
    2ad2:	mov    r14,QWORD PTR [rsp+0x48]
    2ad7:	mov    r15,QWORD PTR [rsp+0x50]
    2adc:	add    rsp,0x60
    2ae0:	mov    rsp,rbp
    2ae3:	pop    rbp
    2ae4:	ret
    2ae5:	mov    rcx,rax
    2ae8:	and    rcx,rbx
    2aeb:	mov    rsi,rax
    2aee:	test   rcx,0x1
    2af5:	jne    2b1e <botlish_fn_26+0x25e>
    2afb:	mov    rdx,rbx
    2afe:	mov    rdi,r14
    2b01:	call   2b06 <botlish_fn_26+0x246>
			2b02: R_X86_64_PLT32	rt_int_cmp-0x4
    2b06:	mov    ecx,0x2
    2b0b:	test   rax,rax
    2b0e:	mov    rax,rcx
    2b11:	cmove  rax,QWORD PTR [rip+0x4f]        # 2b68 <botlish_fn_26+0x2a8>
    2b19:	jmp    2b45 <botlish_fn_26+0x285>
    2b1e:	mov    rdx,rbx
    2b21:	mov    eax,0x2
    2b26:	cmp    rsi,rdx
    2b29:	cmove  rax,QWORD PTR [rip+0x37]        # 2b68 <botlish_fn_26+0x2a8>
    2b31:	jmp    2b45 <botlish_fn_26+0x285>
    2b36:	mov    eax,0x2
    2b3b:	jmp    2b45 <botlish_fn_26+0x285>
    2b40:	mov    eax,0x2
    2b45:	mov    rbx,QWORD PTR [rsp+0x30]
    2b4a:	mov    r12,QWORD PTR [rsp+0x38]
    2b4f:	mov    r13,QWORD PTR [rsp+0x40]
    2b54:	mov    r14,QWORD PTR [rsp+0x48]
    2b59:	mov    r15,QWORD PTR [rsp+0x50]
    2b5e:	add    rsp,0x60
    2b62:	mov    rsp,rbp
    2b65:	pop    rbp
    2b66:	ret
    2b67:	add    BYTE PTR [rsi],al
    2b69:	add    BYTE PTR [rax],al
    2b6b:	add    BYTE PTR [rax],al
    2b6d:	add    BYTE PTR [rax],al
	...

0000000000002b70 <botlish_entry_26: <generic>>:
    2b70:	push   rbp
    2b71:	mov    rbp,rsp
    2b74:	mov    rsi,QWORD PTR [rdx]
    2b77:	call   2b7c <botlish_entry_26+0xc>
			2b78: R_X86_64_PLT32	botlish_fn_26-0x4 ; <generic>
    2b7c:	mov    rsp,rbp
    2b7f:	pop    rbp
    2b80:	ret

0000000000002b81 <botlish_fn_27: char_at<generic>>:
    2b81:	push   rbp
    2b82:	mov    rbp,rsp
    2b85:	sub    rsp,0x50
    2b89:	mov    QWORD PTR [rsp+0x20],rbx
    2b8e:	mov    QWORD PTR [rsp+0x28],r12
    2b93:	mov    QWORD PTR [rsp+0x30],r13
    2b98:	mov    QWORD PTR [rsp+0x38],r14
    2b9d:	mov    QWORD PTR [rsp+0x40],r15
    2ba2:	mov    r12,rdi
    2ba5:	mov    r15,rcx
    2ba8:	mov    QWORD PTR [rsp],rsi
    2bac:	mov    QWORD PTR [rsp+0x8],rdx
    2bb1:	mov    r13,rdx
    2bb4:	mov    QWORD PTR [rsp+0x10],0x3
    2bbd:	test   rsi,0x1
    2bc4:	jne    2bd2 <botlish_fn_27+0x51>
    2bca:	mov    rbx,rsi
    2bcd:	jmp    2bf2 <botlish_fn_27+0x71>
    2bd2:	mov    rax,rsi
    2bd5:	add    rax,0x2
    2bd9:	mov    rbx,rsi
    2bdc:	seto   cl
    2bdf:	test   cl,cl
    2be1:	jne    2bf2 <botlish_fn_27+0x71>
    2be7:	mov    rdi,r12
    2bea:	mov    r14,rax
    2bed:	jmp    2c08 <botlish_fn_27+0x87>
    2bf2:	mov    edx,0x3
    2bf7:	mov    rsi,rbx
    2bfa:	mov    rdi,r12
    2bfd:	call   2c02 <botlish_fn_27+0x81>
			2bfe: R_X86_64_PLT32	rt_int_add-0x4
    2c02:	mov    r14,rax
    2c05:	mov    rdi,r12
    2c08:	mov    rcx,r14
    2c0b:	mov    rdx,rbx
    2c0e:	mov    rsi,r13
    2c11:	call   2c16 <botlish_fn_27+0x95>
			2c12: R_X86_64_PLT32	rt_str_region_check-0x4
    2c16:	test   rax,rax
    2c19:	jne    2c44 <botlish_fn_27+0xc3>
    2c1f:	xor    rax,rax
    2c22:	mov    rbx,QWORD PTR [rsp+0x20]
    2c27:	mov    r12,QWORD PTR [rsp+0x28]
    2c2c:	mov    r13,QWORD PTR [rsp+0x30]
    2c31:	mov    r14,QWORD PTR [rsp+0x38]
    2c36:	mov    r15,QWORD PTR [rsp+0x40]
    2c3b:	add    rsp,0x50
    2c3f:	mov    rsp,rbp
    2c42:	pop    rbp
    2c43:	ret
    2c44:	mov    rcx,r15
    2c47:	mov    QWORD PTR [rcx],rbx
    2c4a:	mov    rax,r14
    2c4d:	mov    QWORD PTR [rcx+0x8],rax
    2c51:	mov    rax,r13
    2c54:	mov    rbx,QWORD PTR [rsp+0x20]
    2c59:	mov    r12,QWORD PTR [rsp+0x28]
    2c5e:	mov    r13,QWORD PTR [rsp+0x30]
    2c63:	mov    r14,QWORD PTR [rsp+0x38]
    2c68:	mov    r15,QWORD PTR [rsp+0x40]
    2c6d:	add    rsp,0x50
    2c71:	mov    rsp,rbp
    2c74:	pop    rbp
    2c75:	ret

0000000000002c76 <botlish_entry_27: char_at<generic>>:
    2c76:	push   rbp
    2c77:	mov    rbp,rsp
    2c7a:	ud2
    2c7c:	add    BYTE PTR [rax],al
	...

0000000000002c80 <botlish_fn_28: scan_local<generic>>:
    2c80:	push   rbp
    2c81:	mov    rbp,rsp
    2c84:	sub    rsp,0x80
    2c8b:	mov    QWORD PTR [rsp+0x50],rbx
    2c90:	mov    QWORD PTR [rsp+0x58],r12
    2c95:	mov    QWORD PTR [rsp+0x60],r13
    2c9a:	mov    QWORD PTR [rsp+0x68],r14
    2c9f:	mov    QWORD PTR [rsp+0x70],r15
    2ca4:	mov    QWORD PTR [rsp+0x18],0x0
    2cad:	mov    QWORD PTR [rsp],rsi
    2cb1:	mov    r15,rsi
    2cb4:	mov    QWORD PTR [rsp+0x8],rdx
    2cb9:	mov    QWORD PTR [rsp+0x10],rcx
    2cbe:	mov    r13,rcx
    2cc1:	lea    r14,[rsp+0x20]
    2cc6:	mov    rbx,rdx
    2cc9:	mov    rax,rsi
    2ccc:	and    rax,rbx
    2ccf:	mov    r15,rsi
    2cd2:	test   rax,0x1
    2cd8:	jne    2d01 <botlish_fn_28+0x81>
    2cde:	mov    r12,rdi
    2ce1:	mov    rdx,rbx
    2ce4:	mov    rsi,r15
    2ce7:	call   2cec <botlish_fn_28+0x6c>
			2ce8: R_X86_64_PLT32	rt_int_cmp-0x4
    2cec:	mov    ecx,0x2
    2cf1:	test   rax,rax
    2cf4:	cmovge rcx,QWORD PTR [rip+0x254]        # 2f50 <botlish_fn_28+0x2d0>
    2cfc:	jmp    2d17 <botlish_fn_28+0x97>
    2d01:	mov    r12,rdi
    2d04:	mov    ecx,0x2
    2d09:	mov    rsi,r15
    2d0c:	cmp    rsi,rbx
    2d0f:	cmovge rcx,QWORD PTR [rip+0x239]        # 2f50 <botlish_fn_28+0x2d0>
    2d17:	cmp    rcx,0x6
    2d1b:	je     2f22 <botlish_fn_28+0x2a2>
    2d21:	mov    rcx,r14
    2d24:	mov    rdx,r13
    2d27:	mov    rsi,r15
    2d2a:	mov    rdi,r12
    2d2d:	call   2d32 <botlish_fn_28+0xb2>
			2d2e: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    2d32:	mov    rcx,rax
    2d35:	mov    QWORD PTR [rsp+0x40],rax
    2d3a:	test   rax,rcx
    2d3d:	je     2d6d <botlish_fn_28+0xed>
    2d43:	mov    rdx,QWORD PTR [rsp+0x20]
    2d48:	mov    QWORD PTR [rsp+0x38],rdx
    2d4d:	mov    rcx,QWORD PTR [rsp+0x28]
    2d52:	mov    QWORD PTR [rsp+0x30],rcx
    2d57:	mov    rsi,QWORD PTR [rsp+0x40]
    2d5c:	mov    rdi,r12
    2d5f:	call   2d64 <botlish_fn_28+0xe4>
			2d60: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    2d64:	test   rax,rax
    2d67:	jne    2d95 <botlish_fn_28+0x115>
    2d6d:	xor    rax,rax
    2d70:	mov    rbx,QWORD PTR [rsp+0x50]
    2d75:	mov    r12,QWORD PTR [rsp+0x58]
    2d7a:	mov    r13,QWORD PTR [rsp+0x60]
    2d7f:	mov    r14,QWORD PTR [rsp+0x68]
    2d84:	mov    r15,QWORD PTR [rsp+0x70]
    2d89:	add    rsp,0x80
    2d90:	mov    rsp,rbp
    2d93:	pop    rbp
    2d94:	ret
    2d95:	cmp    rax,0x6
    2d99:	je     2ea3 <botlish_fn_28+0x223>
    2d9f:	mov    r9,QWORD PTR [r12+0x10]
    2da4:	mov    r8,QWORD PTR [r9+0xd0]
    2dab:	mov    rcx,QWORD PTR [rsp+0x30]
    2db0:	mov    rdx,QWORD PTR [rsp+0x38]
    2db5:	mov    rsi,QWORD PTR [rsp+0x40]
    2dba:	mov    rdi,r12
    2dbd:	call   2dc2 <botlish_fn_28+0x142>
			2dbe: R_X86_64_PLT32	rt_str_region_eq-0x4
    2dc2:	cmp    rax,0x6
    2dc6:	je     2e99 <botlish_fn_28+0x219>
    2dcc:	mov    r11,QWORD PTR [r12+0x10]
    2dd1:	mov    r8,QWORD PTR [r11+0xd8]
    2dd8:	mov    rcx,QWORD PTR [rsp+0x30]
    2ddd:	mov    rdx,QWORD PTR [rsp+0x38]
    2de2:	mov    rsi,QWORD PTR [rsp+0x40]
    2de7:	mov    rdi,r12
    2dea:	call   2def <botlish_fn_28+0x16f>
			2deb: R_X86_64_PLT32	rt_str_region_eq-0x4
    2def:	cmp    rax,0x6
    2df3:	je     2e8f <botlish_fn_28+0x20f>
    2df9:	mov    rax,QWORD PTR [r12+0x10]
    2dfe:	mov    r8,QWORD PTR [rax+0xa8]
    2e05:	mov    rcx,QWORD PTR [rsp+0x30]
    2e0a:	mov    rdx,QWORD PTR [rsp+0x38]
    2e0f:	mov    rsi,QWORD PTR [rsp+0x40]
    2e14:	mov    rdi,r12
    2e17:	call   2e1c <botlish_fn_28+0x19c>
			2e18: R_X86_64_PLT32	rt_str_region_eq-0x4
    2e1c:	cmp    rax,0x6
    2e20:	je     2e85 <botlish_fn_28+0x205>
    2e26:	mov    rax,QWORD PTR [r12+0x10]
    2e2b:	mov    r8,QWORD PTR [rax+0xe0]
    2e32:	mov    rcx,QWORD PTR [rsp+0x30]
    2e37:	mov    rdx,QWORD PTR [rsp+0x38]
    2e3c:	mov    rsi,QWORD PTR [rsp+0x40]
    2e41:	mov    rdi,r12
    2e44:	call   2e49 <botlish_fn_28+0x1c9>
			2e45: R_X86_64_PLT32	rt_str_region_eq-0x4
    2e49:	cmp    rax,0x6
    2e4d:	je     2e7b <botlish_fn_28+0x1fb>
    2e53:	mov    rax,QWORD PTR [r12+0x10]
    2e58:	mov    r8,QWORD PTR [rax+0xe8]
    2e5f:	mov    rcx,QWORD PTR [rsp+0x30]
    2e64:	mov    rdx,QWORD PTR [rsp+0x38]
    2e69:	mov    rsi,QWORD PTR [rsp+0x40]
    2e6e:	mov    rdi,r12
    2e71:	call   2e76 <botlish_fn_28+0x1f6>
			2e72: R_X86_64_PLT32	rt_str_region_eq-0x4
    2e76:	jmp    2ea8 <botlish_fn_28+0x228>
    2e7b:	mov    eax,0x6
    2e80:	jmp    2ea8 <botlish_fn_28+0x228>
    2e85:	mov    eax,0x6
    2e8a:	jmp    2ea8 <botlish_fn_28+0x228>
    2e8f:	mov    eax,0x6
    2e94:	jmp    2ea8 <botlish_fn_28+0x228>
    2e99:	mov    eax,0x6
    2e9e:	jmp    2ea8 <botlish_fn_28+0x228>
    2ea3:	mov    eax,0x6
    2ea8:	cmp    rax,0x6
    2eac:	je     2eba <botlish_fn_28+0x23a>
    2eb2:	mov    rax,r15
    2eb5:	jmp    2f25 <botlish_fn_28+0x2a5>
    2eba:	mov    QWORD PTR [rsp+0x18],0x3
    2ec3:	mov    rsi,r15
    2ec6:	test   rsi,0x1
    2ecd:	je     2ef3 <botlish_fn_28+0x273>
    2ed3:	mov    rsi,r15
    2ed6:	mov    rax,rsi
    2ed9:	add    rax,0x2
    2edd:	seto   cl
    2ee0:	test   cl,cl
    2ee2:	jne    2ef3 <botlish_fn_28+0x273>
    2ee8:	mov    rsi,rax
    2eeb:	mov    r15,rax
    2eee:	jmp    2f09 <botlish_fn_28+0x289>
    2ef3:	mov    edx,0x3
    2ef8:	mov    rsi,r15
    2efb:	mov    rdi,r12
    2efe:	call   2f03 <botlish_fn_28+0x283>
			2eff: R_X86_64_PLT32	rt_int_add-0x4
    2f03:	mov    rsi,rax
    2f06:	mov    r15,rax
    2f09:	mov    QWORD PTR [rsp],rsi
    2f0d:	mov    QWORD PTR [rsp+0x8],rbx
    2f12:	mov    QWORD PTR [rsp+0x10],r13
    2f17:	mov    rsi,r15
    2f1a:	mov    rdi,r12
    2f1d:	jmp    2cc9 <botlish_fn_28+0x49>
    2f22:	mov    rax,r15
    2f25:	mov    rbx,QWORD PTR [rsp+0x50]
    2f2a:	mov    r12,QWORD PTR [rsp+0x58]
    2f2f:	mov    r13,QWORD PTR [rsp+0x60]
    2f34:	mov    r14,QWORD PTR [rsp+0x68]
    2f39:	mov    r15,QWORD PTR [rsp+0x70]
    2f3e:	add    rsp,0x80
    2f45:	mov    rsp,rbp
    2f48:	pop    rbp
    2f49:	ret
    2f4a:	add    BYTE PTR [rax],al
    2f4c:	add    BYTE PTR [rax],al
    2f4e:	add    BYTE PTR [rax],al
    2f50:	(bad)
    2f51:	add    BYTE PTR [rax],al
    2f53:	add    BYTE PTR [rax],al
    2f55:	add    BYTE PTR [rax],al
	...

0000000000002f58 <botlish_entry_28: scan_local<generic>>:
    2f58:	push   rbp
    2f59:	mov    rbp,rsp
    2f5c:	mov    rsi,QWORD PTR [rdx]
    2f5f:	mov    r8,QWORD PTR [rdx+0x8]
    2f63:	mov    rcx,QWORD PTR [rdx+0x10]
    2f67:	mov    rdx,r8
    2f6a:	call   2f6f <botlish_entry_28+0x17>
			2f6b: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    2f6f:	mov    rsp,rbp
    2f72:	pop    rbp
    2f73:	ret
    2f74:	add    BYTE PTR [rax],al
	...

0000000000002f78 <botlish_fn_29: scan_label<generic>>:
    2f78:	push   rbp
    2f79:	mov    rbp,rsp
    2f7c:	sub    rsp,0x80
    2f83:	mov    QWORD PTR [rsp+0x50],rbx
    2f88:	mov    QWORD PTR [rsp+0x58],r12
    2f8d:	mov    QWORD PTR [rsp+0x60],r13
    2f92:	mov    QWORD PTR [rsp+0x68],r14
    2f97:	mov    QWORD PTR [rsp+0x70],r15
    2f9c:	mov    QWORD PTR [rsp+0x18],0x0
    2fa5:	mov    QWORD PTR [rsp],rsi
    2fa9:	mov    r15,rsi
    2fac:	mov    QWORD PTR [rsp+0x8],rdx
    2fb1:	mov    QWORD PTR [rsp+0x10],rcx
    2fb6:	mov    r13,rcx
    2fb9:	lea    r14,[rsp+0x20]
    2fbe:	mov    rbx,rdx
    2fc1:	mov    rax,rsi
    2fc4:	and    rax,rbx
    2fc7:	mov    r15,rsi
    2fca:	test   rax,0x1
    2fd0:	jne    2ff9 <botlish_fn_29+0x81>
    2fd6:	mov    r12,rdi
    2fd9:	mov    rdx,rbx
    2fdc:	mov    rsi,r15
    2fdf:	call   2fe4 <botlish_fn_29+0x6c>
			2fe0: R_X86_64_PLT32	rt_int_cmp-0x4
    2fe4:	mov    ecx,0x2
    2fe9:	test   rax,rax
    2fec:	cmovge rcx,QWORD PTR [rip+0x174]        # 3168 <botlish_fn_29+0x1f0>
    2ff4:	jmp    300f <botlish_fn_29+0x97>
    2ff9:	mov    r12,rdi
    2ffc:	mov    ecx,0x2
    3001:	mov    rsi,r15
    3004:	cmp    rsi,rbx
    3007:	cmovge rcx,QWORD PTR [rip+0x159]        # 3168 <botlish_fn_29+0x1f0>
    300f:	cmp    rcx,0x6
    3013:	je     313b <botlish_fn_29+0x1c3>
    3019:	mov    rcx,r14
    301c:	mov    rdx,r13
    301f:	mov    rsi,r15
    3022:	mov    rdi,r12
    3025:	call   302a <botlish_fn_29+0xb2>
			3026: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    302a:	test   rax,rax
    302d:	mov    QWORD PTR [rsp+0x40],rax
    3032:	je     3062 <botlish_fn_29+0xea>
    3038:	mov    rdx,QWORD PTR [rsp+0x20]
    303d:	mov    QWORD PTR [rsp+0x38],rdx
    3042:	mov    rcx,QWORD PTR [rsp+0x28]
    3047:	mov    QWORD PTR [rsp+0x30],rcx
    304c:	mov    rsi,QWORD PTR [rsp+0x40]
    3051:	mov    rdi,r12
    3054:	call   3059 <botlish_fn_29+0xe1>
			3055: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    3059:	test   rax,rax
    305c:	jne    308a <botlish_fn_29+0x112>
    3062:	xor    rax,rax
    3065:	mov    rbx,QWORD PTR [rsp+0x50]
    306a:	mov    r12,QWORD PTR [rsp+0x58]
    306f:	mov    r13,QWORD PTR [rsp+0x60]
    3074:	mov    r14,QWORD PTR [rsp+0x68]
    3079:	mov    r15,QWORD PTR [rsp+0x70]
    307e:	add    rsp,0x80
    3085:	mov    rsp,rbp
    3088:	pop    rbp
    3089:	ret
    308a:	cmp    rax,0x6
    308e:	je     30bc <botlish_fn_29+0x144>
    3094:	mov    rax,QWORD PTR [r12+0x10]
    3099:	mov    r8,QWORD PTR [rax+0xe8]
    30a0:	mov    rcx,QWORD PTR [rsp+0x30]
    30a5:	mov    rdx,QWORD PTR [rsp+0x38]
    30aa:	mov    rsi,QWORD PTR [rsp+0x40]
    30af:	mov    rdi,r12
    30b2:	call   30b7 <botlish_fn_29+0x13f>
			30b3: R_X86_64_PLT32	rt_str_region_eq-0x4
    30b7:	jmp    30c1 <botlish_fn_29+0x149>
    30bc:	mov    eax,0x6
    30c1:	cmp    rax,0x6
    30c5:	je     30d3 <botlish_fn_29+0x15b>
    30cb:	mov    rax,r15
    30ce:	jmp    313e <botlish_fn_29+0x1c6>
    30d3:	mov    QWORD PTR [rsp+0x18],0x3
    30dc:	mov    rsi,r15
    30df:	test   rsi,0x1
    30e6:	je     310c <botlish_fn_29+0x194>
    30ec:	mov    rsi,r15
    30ef:	mov    rax,rsi
    30f2:	add    rax,0x2
    30f6:	seto   cl
    30f9:	test   cl,cl
    30fb:	jne    310c <botlish_fn_29+0x194>
    3101:	mov    rsi,rax
    3104:	mov    r15,rax
    3107:	jmp    3122 <botlish_fn_29+0x1aa>
    310c:	mov    edx,0x3
    3111:	mov    rsi,r15
    3114:	mov    rdi,r12
    3117:	call   311c <botlish_fn_29+0x1a4>
			3118: R_X86_64_PLT32	rt_int_add-0x4
    311c:	mov    rsi,rax
    311f:	mov    r15,rax
    3122:	mov    QWORD PTR [rsp],rsi
    3126:	mov    QWORD PTR [rsp+0x8],rbx
    312b:	mov    QWORD PTR [rsp+0x10],r13
    3130:	mov    rsi,r15
    3133:	mov    rdi,r12
    3136:	jmp    2fc1 <botlish_fn_29+0x49>
    313b:	mov    rax,r15
    313e:	mov    rbx,QWORD PTR [rsp+0x50]
    3143:	mov    r12,QWORD PTR [rsp+0x58]
    3148:	mov    r13,QWORD PTR [rsp+0x60]
    314d:	mov    r14,QWORD PTR [rsp+0x68]
    3152:	mov    r15,QWORD PTR [rsp+0x70]
    3157:	add    rsp,0x80
    315e:	mov    rsp,rbp
    3161:	pop    rbp
    3162:	ret
    3163:	add    BYTE PTR [rax],al
    3165:	add    BYTE PTR [rax],al
    3167:	add    BYTE PTR [rsi],al
    3169:	add    BYTE PTR [rax],al
    316b:	add    BYTE PTR [rax],al
    316d:	add    BYTE PTR [rax],al
	...

0000000000003170 <botlish_entry_29: scan_label<generic>>:
    3170:	push   rbp
    3171:	mov    rbp,rsp
    3174:	mov    rsi,QWORD PTR [rdx]
    3177:	mov    r8,QWORD PTR [rdx+0x8]
    317b:	mov    rcx,QWORD PTR [rdx+0x10]
    317f:	mov    rdx,r8
    3182:	call   3187 <botlish_entry_29+0x17>
			3183: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_label<generic>
    3187:	mov    rsp,rbp
    318a:	pop    rbp
    318b:	ret
    318c:	add    BYTE PTR [rax],al
	...

0000000000003190 <botlish_fn_30: scan_alpha<generic>>:
    3190:	push   rbp
    3191:	mov    rbp,rsp
    3194:	sub    rsp,0x60
    3198:	mov    QWORD PTR [rsp+0x30],rbx
    319d:	mov    QWORD PTR [rsp+0x38],r12
    31a2:	mov    QWORD PTR [rsp+0x40],r13
    31a7:	mov    QWORD PTR [rsp+0x48],r14
    31ac:	mov    QWORD PTR [rsp+0x50],r15
    31b1:	mov    r15,rdi
    31b4:	mov    QWORD PTR [rsp+0x18],0x0
    31bd:	mov    QWORD PTR [rsp],rsi
    31c1:	mov    r14,rsi
    31c4:	mov    QWORD PTR [rsp+0x8],rdx
    31c9:	mov    QWORD PTR [rsp+0x10],rcx
    31ce:	mov    r12,rcx
    31d1:	lea    r13,[rsp+0x20]
    31d6:	mov    rbx,rdx
    31d9:	mov    rax,rsi
    31dc:	and    rax,rbx
    31df:	mov    r14,rsi
    31e2:	test   rax,0x1
    31e8:	jne    3211 <botlish_fn_30+0x81>
    31ee:	mov    rdx,rbx
    31f1:	mov    rsi,r14
    31f4:	mov    rdi,r15
    31f7:	call   31fc <botlish_fn_30+0x6c>
			31f8: R_X86_64_PLT32	rt_int_cmp-0x4
    31fc:	mov    ecx,0x2
    3201:	test   rax,rax
    3204:	cmovge rcx,QWORD PTR [rip+0x11c]        # 3328 <botlish_fn_30+0x198>
    320c:	jmp    3224 <botlish_fn_30+0x94>
    3211:	mov    ecx,0x2
    3216:	mov    rsi,r14
    3219:	cmp    rsi,rbx
    321c:	cmovge rcx,QWORD PTR [rip+0x104]        # 3328 <botlish_fn_30+0x198>
    3224:	cmp    rcx,0x6
    3228:	je     3302 <botlish_fn_30+0x172>
    322e:	mov    rcx,r13
    3231:	mov    rdx,r12
    3234:	mov    rsi,r14
    3237:	mov    rdi,r15
    323a:	call   323f <botlish_fn_30+0xaf>
			323b: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    323f:	test   rax,rax
    3242:	mov    rsi,rax
    3245:	je     3266 <botlish_fn_30+0xd6>
    324b:	mov    rdx,QWORD PTR [rsp+0x20]
    3250:	mov    rcx,QWORD PTR [rsp+0x28]
    3255:	mov    rdi,r15
    3258:	call   325d <botlish_fn_30+0xcd>
			3259: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    325d:	test   rax,rax
    3260:	jne    328b <botlish_fn_30+0xfb>
    3266:	xor    rax,rax
    3269:	mov    rbx,QWORD PTR [rsp+0x30]
    326e:	mov    r12,QWORD PTR [rsp+0x38]
    3273:	mov    r13,QWORD PTR [rsp+0x40]
    3278:	mov    r14,QWORD PTR [rsp+0x48]
    327d:	mov    r15,QWORD PTR [rsp+0x50]
    3282:	add    rsp,0x60
    3286:	mov    rsp,rbp
    3289:	pop    rbp
    328a:	ret
    328b:	cmp    rax,0x6
    328f:	je     329d <botlish_fn_30+0x10d>
    3295:	mov    rax,r14
    3298:	jmp    3305 <botlish_fn_30+0x175>
    329d:	mov    QWORD PTR [rsp+0x18],0x3
    32a6:	mov    rsi,r14
    32a9:	test   rsi,0x1
    32b0:	je     32d6 <botlish_fn_30+0x146>
    32b6:	mov    rsi,r14
    32b9:	mov    rcx,rsi
    32bc:	add    rcx,0x2
    32c0:	seto   al
    32c3:	test   al,al
    32c5:	jne    32d6 <botlish_fn_30+0x146>
    32cb:	mov    rsi,rcx
    32ce:	mov    r14,rcx
    32d1:	jmp    32ec <botlish_fn_30+0x15c>
    32d6:	mov    edx,0x3
    32db:	mov    rsi,r14
    32de:	mov    rdi,r15
    32e1:	call   32e6 <botlish_fn_30+0x156>
			32e2: R_X86_64_PLT32	rt_int_add-0x4
    32e6:	mov    rsi,rax
    32e9:	mov    r14,rax
    32ec:	mov    QWORD PTR [rsp],rsi
    32f0:	mov    QWORD PTR [rsp+0x8],rbx
    32f5:	mov    QWORD PTR [rsp+0x10],r12
    32fa:	mov    rsi,r14
    32fd:	jmp    31d9 <botlish_fn_30+0x49>
    3302:	mov    rax,r14
    3305:	mov    rbx,QWORD PTR [rsp+0x30]
    330a:	mov    r12,QWORD PTR [rsp+0x38]
    330f:	mov    r13,QWORD PTR [rsp+0x40]
    3314:	mov    r14,QWORD PTR [rsp+0x48]
    3319:	mov    r15,QWORD PTR [rsp+0x50]
    331e:	add    rsp,0x60
    3322:	mov    rsp,rbp
    3325:	pop    rbp
    3326:	ret
    3327:	add    BYTE PTR [rsi],al
    3329:	add    BYTE PTR [rax],al
    332b:	add    BYTE PTR [rax],al
    332d:	add    BYTE PTR [rax],al
	...

0000000000003330 <botlish_entry_30: scan_alpha<generic>>:
    3330:	push   rbp
    3331:	mov    rbp,rsp
    3334:	mov    rsi,QWORD PTR [rdx]
    3337:	mov    r8,QWORD PTR [rdx+0x8]
    333b:	mov    rcx,QWORD PTR [rdx+0x10]
    333f:	mov    rdx,r8
    3342:	call   3347 <botlish_entry_30+0x17>
			3343: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_alpha<generic>
    3347:	mov    rsp,rbp
    334a:	pop    rbp
    334b:	ret
    334c:	add    BYTE PTR [rax],al
	...

0000000000003350 <botlish_fn_31: tld_ok<generic>>:
    3350:	push   rbp
    3351:	mov    rbp,rsp
    3354:	sub    rsp,0x40
    3358:	mov    QWORD PTR [rsp+0x20],rbx
    335d:	mov    QWORD PTR [rsp+0x28],r12
    3362:	mov    QWORD PTR [rsp+0x30],r13
    3367:	mov    QWORD PTR [rsp+0x38],r14
    336c:	mov    r12,rdi
    336f:	mov    QWORD PTR [rsp],rsi
    3373:	mov    rdi,rsi
    3376:	mov    QWORD PTR [rsp+0x8],rdx
    337b:	mov    r14,rdx
    337e:	mov    QWORD PTR [rsp+0x10],rcx
    3383:	mov    rbx,rdi
    3386:	mov    rdx,r14
    3389:	mov    rsi,rbx
    338c:	mov    rdi,r12
    338f:	call   3394 <botlish_fn_31+0x44>
			3390: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_alpha<generic>
    3394:	mov    rcx,rax
    3397:	mov    r13,rax
    339a:	test   rax,rcx
    339d:	jne    33c3 <botlish_fn_31+0x73>
    33a3:	xor    rax,rax
    33a6:	mov    rbx,QWORD PTR [rsp+0x20]
    33ab:	mov    r12,QWORD PTR [rsp+0x28]
    33b0:	mov    r13,QWORD PTR [rsp+0x30]
    33b5:	mov    r14,QWORD PTR [rsp+0x38]
    33ba:	add    rsp,0x40
    33be:	mov    rsp,rbp
    33c1:	pop    rbp
    33c2:	ret
    33c3:	mov    rax,r13
    33c6:	mov    QWORD PTR [rsp+0x8],rax
    33cb:	mov    rdx,r14
    33ce:	and    rax,rdx
    33d1:	test   rax,0x1
    33d7:	jne    3400 <botlish_fn_31+0xb0>
    33dd:	mov    rsi,r13
    33e0:	mov    rdi,r12
    33e3:	call   33e8 <botlish_fn_31+0x98>
			33e4: R_X86_64_PLT32	rt_int_cmp-0x4
    33e8:	mov    ecx,0x2
    33ed:	test   rax,rax
    33f0:	cmove  rcx,QWORD PTR [rip+0xe0]        # 34d8 <botlish_fn_31+0x188>
    33f8:	mov    rax,r13
    33fb:	jmp    3413 <botlish_fn_31+0xc3>
    3400:	mov    ecx,0x2
    3405:	mov    rax,r13
    3408:	cmp    rax,rdx
    340b:	cmove  rcx,QWORD PTR [rip+0xc5]        # 34d8 <botlish_fn_31+0x188>
    3413:	cmp    rcx,0x6
    3417:	je     342a <botlish_fn_31+0xda>
    341d:	mov    ecx,0x2
    3422:	mov    rax,rcx
    3425:	jmp    34b7 <botlish_fn_31+0x167>
    342a:	mov    rcx,rax
    342d:	and    rcx,rbx
    3430:	test   rcx,0x1
    3437:	jne    3448 <botlish_fn_31+0xf8>
    343d:	mov    rdx,rbx
    3440:	mov    rsi,rax
    3443:	jmp    3469 <botlish_fn_31+0x119>
    3448:	mov    rcx,rax
    344b:	sub    rcx,rbx
    344e:	mov    rdi,rbx
    3451:	mov    r13,rax
    3454:	seto   al
    3457:	lea    rsi,[rcx+0x1]
    345b:	test   al,al
    345d:	je     3474 <botlish_fn_31+0x124>
    3463:	mov    rdx,rdi
    3466:	mov    rsi,r13
    3469:	mov    rdi,r12
    346c:	call   3471 <botlish_fn_31+0x121>
			346d: R_X86_64_PLT32	rt_int_sub-0x4
    3471:	mov    rsi,rax
    3474:	test   rsi,0x1
    347b:	jne    34a6 <botlish_fn_31+0x156>
    3481:	mov    edx,0x5
    3486:	mov    rdi,r12
    3489:	call   348e <botlish_fn_31+0x13e>
			348a: R_X86_64_PLT32	rt_int_cmp-0x4
    348e:	mov    ecx,0x2
    3493:	test   rax,rax
    3496:	mov    rax,rcx
    3499:	cmovge rax,QWORD PTR [rip+0x37]        # 34d8 <botlish_fn_31+0x188>
    34a1:	jmp    34b7 <botlish_fn_31+0x167>
    34a6:	mov    eax,0x2
    34ab:	cmp    rsi,0x5
    34af:	cmovge rax,QWORD PTR [rip+0x21]        # 34d8 <botlish_fn_31+0x188>
    34b7:	mov    rbx,QWORD PTR [rsp+0x20]
    34bc:	mov    r12,QWORD PTR [rsp+0x28]
    34c1:	mov    r13,QWORD PTR [rsp+0x30]
    34c6:	mov    r14,QWORD PTR [rsp+0x38]
    34cb:	add    rsp,0x40
    34cf:	mov    rsp,rbp
    34d2:	pop    rbp
    34d3:	ret
    34d4:	add    BYTE PTR [rax],al
    34d6:	add    BYTE PTR [rax],al
    34d8:	(bad)
    34d9:	add    BYTE PTR [rax],al
    34db:	add    BYTE PTR [rax],al
    34dd:	add    BYTE PTR [rax],al
	...

00000000000034e0 <botlish_entry_31: tld_ok<generic>>:
    34e0:	push   rbp
    34e1:	mov    rbp,rsp
    34e4:	mov    rsi,QWORD PTR [rdx]
    34e7:	mov    r8,QWORD PTR [rdx+0x8]
    34eb:	mov    rcx,QWORD PTR [rdx+0x10]
    34ef:	mov    rdx,r8
    34f2:	call   34f7 <botlish_entry_31+0x17>
			34f3: R_X86_64_PLT32	botlish_fn_31-0x4 ; tld_ok<generic>
    34f7:	mov    rsp,rbp
    34fa:	pop    rbp
    34fb:	ret
    34fc:	add    BYTE PTR [rax],al
	...

0000000000003500 <botlish_fn_32: domain_loop<generic>>:
    3500:	push   rbp
    3501:	mov    rbp,rsp
    3504:	sub    rsp,0x70
    3508:	mov    QWORD PTR [rsp+0x40],rbx
    350d:	mov    QWORD PTR [rsp+0x48],r12
    3512:	mov    QWORD PTR [rsp+0x50],r13
    3517:	mov    QWORD PTR [rsp+0x58],r14
    351c:	mov    QWORD PTR [rsp+0x60],r15
    3521:	mov    QWORD PTR [rsp+0x18],0x0
    352a:	mov    QWORD PTR [rsp],rsi
    352e:	mov    QWORD PTR [rsp+0x8],rdx
    3533:	mov    QWORD PTR [rsp+0x10],rcx
    3538:	lea    rbx,[rsp+0x20]
    353d:	mov    r12,rdi
    3540:	mov    r13,rcx
    3543:	mov    r14,rdx
    3546:	mov    QWORD PTR [rsp+0x30],rsi
    354b:	mov    rcx,r13
    354e:	mov    rdx,r14
    3551:	mov    rsi,QWORD PTR [rsp+0x30]
    3556:	mov    rdi,r12
    3559:	call   355e <botlish_fn_32+0x5e>
			355a: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_label<generic>
    355e:	mov    rcx,rax
    3561:	mov    r15,rax
    3564:	test   rax,rcx
    3567:	je     36be <botlish_fn_32+0x1be>
    356d:	mov    rax,r15
    3570:	mov    QWORD PTR [rsp],rax
    3574:	mov    rdx,QWORD PTR [rsp+0x30]
    3579:	and    rax,rdx
    357c:	test   rax,0x1
    3582:	jne    35a8 <botlish_fn_32+0xa8>
    3588:	mov    rsi,r15
    358b:	mov    rdi,r12
    358e:	call   3593 <botlish_fn_32+0x93>
			358f: R_X86_64_PLT32	rt_int_cmp-0x4
    3593:	mov    ecx,0x2
    3598:	test   rax,rax
    359b:	cmove  rcx,QWORD PTR [rip+0x19d]        # 3740 <botlish_fn_32+0x240>
    35a3:	jmp    35b8 <botlish_fn_32+0xb8>
    35a8:	mov    ecx,0x2
    35ad:	cmp    r15,rdx
    35b0:	cmove  rcx,QWORD PTR [rip+0x188]        # 3740 <botlish_fn_32+0x240>
    35b8:	cmp    rcx,0x6
    35bc:	je     3714 <botlish_fn_32+0x214>
    35c2:	mov    rax,r15
    35c5:	and    rax,r14
    35c8:	test   rax,0x1
    35ce:	jne    35f7 <botlish_fn_32+0xf7>
    35d4:	mov    rdx,r14
    35d7:	mov    rsi,r15
    35da:	mov    rdi,r12
    35dd:	call   35e2 <botlish_fn_32+0xe2>
			35de: R_X86_64_PLT32	rt_int_cmp-0x4
    35e2:	mov    ecx,0x2
    35e7:	test   rax,rax
    35ea:	cmovge rcx,QWORD PTR [rip+0x14e]        # 3740 <botlish_fn_32+0x240>
    35f2:	jmp    3607 <botlish_fn_32+0x107>
    35f7:	mov    ecx,0x2
    35fc:	cmp    r15,r14
    35ff:	cmovge rcx,QWORD PTR [rip+0x139]        # 3740 <botlish_fn_32+0x240>
    3607:	cmp    rcx,0x6
    360b:	je     3705 <botlish_fn_32+0x205>
    3611:	mov    rcx,rbx
    3614:	mov    rdx,r13
    3617:	mov    rsi,r15
    361a:	mov    rdi,r12
    361d:	call   3622 <botlish_fn_32+0x122>
			361e: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    3622:	test   rax,rax
    3625:	je     36be <botlish_fn_32+0x1be>
    362b:	mov    rdx,QWORD PTR [rsp+0x20]
    3630:	mov    rcx,QWORD PTR [rsp+0x28]
    3635:	mov    rsi,QWORD PTR [r12+0x10]
    363a:	mov    r8,QWORD PTR [rsi+0xd0]
    3641:	mov    rsi,rax
    3644:	mov    rdi,r12
    3647:	call   364c <botlish_fn_32+0x14c>
			3648: R_X86_64_PLT32	rt_str_region_eq-0x4
    364c:	cmp    rax,0x6
    3650:	je     3662 <botlish_fn_32+0x162>
    3656:	mov    r14,0xffffffffffffffff
    365d:	jmp    370c <botlish_fn_32+0x20c>
    3662:	mov    QWORD PTR [rsp+0x18],0x3
    366b:	test   r15,0x1
    3672:	je     368a <botlish_fn_32+0x18a>
    3678:	mov    rdx,r15
    367b:	add    rdx,0x2
    367f:	seto   al
    3682:	test   al,al
    3684:	je     369d <botlish_fn_32+0x19d>
    368a:	mov    edx,0x3
    368f:	mov    rsi,r15
    3692:	mov    rdi,r12
    3695:	call   369a <botlish_fn_32+0x19a>
			3696: R_X86_64_PLT32	rt_int_add-0x4
    369a:	mov    rdx,rax
    369d:	mov    QWORD PTR [rsp],rdx
    36a1:	mov    r15,rdx
    36a4:	mov    rcx,r13
    36a7:	mov    rdx,r14
    36aa:	mov    rsi,r15
    36ad:	mov    rdi,r12
    36b0:	call   36b5 <botlish_fn_32+0x1b5>
			36b1: R_X86_64_PLT32	botlish_fn_31-0x4 ; tld_ok<generic>
    36b5:	test   rax,rax
    36b8:	jne    36e3 <botlish_fn_32+0x1e3>
    36be:	xor    rax,rax
    36c1:	mov    rbx,QWORD PTR [rsp+0x40]
    36c6:	mov    r12,QWORD PTR [rsp+0x48]
    36cb:	mov    r13,QWORD PTR [rsp+0x50]
    36d0:	mov    r14,QWORD PTR [rsp+0x58]
    36d5:	mov    r15,QWORD PTR [rsp+0x60]
    36da:	add    rsp,0x70
    36de:	mov    rsp,rbp
    36e1:	pop    rbp
    36e2:	ret
    36e3:	cmp    rax,0x6
    36e7:	je     370c <botlish_fn_32+0x20c>
    36ed:	mov    QWORD PTR [rsp],r15
    36f1:	mov    QWORD PTR [rsp+0x8],r14
    36f6:	mov    QWORD PTR [rsp+0x10],r13
    36fb:	mov    QWORD PTR [rsp+0x30],r15
    3700:	jmp    354b <botlish_fn_32+0x4b>
    3705:	mov    r14,0xffffffffffffffff
    370c:	mov    rax,r14
    370f:	jmp    371b <botlish_fn_32+0x21b>
    3714:	mov    rax,0xffffffffffffffff
    371b:	mov    rbx,QWORD PTR [rsp+0x40]
    3720:	mov    r12,QWORD PTR [rsp+0x48]
    3725:	mov    r13,QWORD PTR [rsp+0x50]
    372a:	mov    r14,QWORD PTR [rsp+0x58]
    372f:	mov    r15,QWORD PTR [rsp+0x60]
    3734:	add    rsp,0x70
    3738:	mov    rsp,rbp
    373b:	pop    rbp
    373c:	ret
    373d:	add    BYTE PTR [rax],al
    373f:	add    BYTE PTR [rsi],al
    3741:	add    BYTE PTR [rax],al
    3743:	add    BYTE PTR [rax],al
    3745:	add    BYTE PTR [rax],al
	...

0000000000003748 <botlish_entry_32: domain_loop<generic>>:
    3748:	push   rbp
    3749:	mov    rbp,rsp
    374c:	mov    rsi,QWORD PTR [rdx]
    374f:	mov    r8,QWORD PTR [rdx+0x8]
    3753:	mov    rcx,QWORD PTR [rdx+0x10]
    3757:	mov    rdx,r8
    375a:	call   375f <botlish_entry_32+0x17>
			375b: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    375f:	mov    rsp,rbp
    3762:	pop    rbp
    3763:	ret

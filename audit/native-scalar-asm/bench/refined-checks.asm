; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 16743  (per function: 1172 39 289 617 74 74 74 125 125 155 125 214 484 864 516 1004 504 681 769 450 884 644 540 540 636 681 769 450 884 644 540 540 636)
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
     ade:	sub    rsp,0x20
     ae2:	mov    QWORD PTR [rsp+0x10],rbx
     ae7:	mov    QWORD PTR [rsp],rsi
     aeb:	mov    QWORD PTR [rsp+0x8],0x1e1
     af4:	mov    r8d,0x1
     afa:	test   rsi,0x1
     b01:	jne    b21 <botlish_fn_11+0x47>
     b07:	xor    r8d,r8d
     b0a:	test   rsi,0x7
     b11:	jne    b21 <botlish_fn_11+0x47>
     b17:	movzx  rax,BYTE PTR [rsi]
     b1b:	cmp    al,0x1
     b1d:	sete   r8b
     b21:	test   r8b,r8b
     b24:	jne    b51 <botlish_fn_11+0x77>
     b2a:	mov    rax,QWORD PTR [rdi+0x10]
     b2e:	mov    rcx,QWORD PTR [rax+0xa8]
     b35:	xor    rbx,rbx
     b38:	mov    rdx,rbx
     b3b:	call   b40 <botlish_fn_11+0x66>
			b3c: R_X86_64_PLT32	rt_type_error-0x4
     b40:	mov    rax,rbx
     b43:	mov    rbx,QWORD PTR [rsp+0x10]
     b48:	add    rsp,0x20
     b4c:	mov    rsp,rbp
     b4f:	pop    rbp
     b50:	ret
     b51:	test   rsi,0x1
     b58:	jne    b6d <botlish_fn_11+0x93>
     b5e:	mov    edx,0x1e1
     b63:	call   b68 <botlish_fn_11+0x8e>
			b64: R_X86_64_PLT32	rt_int_and-0x4
     b68:	jmp    b77 <botlish_fn_11+0x9d>
     b6d:	and    rsi,0x1e1
     b74:	mov    rax,rsi
     b77:	sar    rax,0x5
     b7b:	shl    rax,1
     b7e:	or     rax,0x1
     b82:	mov    rbx,QWORD PTR [rsp+0x10]
     b87:	add    rsp,0x20
     b8b:	mov    rsp,rbp
     b8e:	pop    rbp
     b8f:	ret

0000000000000b90 <botlish_entry_11: high_nibble<generic>>:
     b90:	push   rbp
     b91:	mov    rbp,rsp
     b94:	mov    rsi,QWORD PTR [rdx]
     b97:	call   b9c <botlish_entry_11+0xc>
			b98: R_X86_64_PLT32	botlish_fn_11-0x4 ; high_nibble<generic>
     b9c:	mov    rsp,rbp
     b9f:	pop    rbp
     ba0:	ret

0000000000000ba1 <botlish_fn_12: hex_pair<generic>>:
     ba1:	push   rbp
     ba2:	mov    rbp,rsp
     ba5:	sub    rsp,0x30
     ba9:	mov    QWORD PTR [rsp+0x10],rbx
     bae:	mov    QWORD PTR [rsp+0x18],r12
     bb3:	mov    QWORD PTR [rsp+0x20],r13
     bb8:	mov    QWORD PTR [rsp+0x28],r14
     bbd:	mov    r12,rdi
     bc0:	mov    QWORD PTR [rsp],rsi
     bc4:	mov    r13,rsi
     bc7:	mov    QWORD PTR [rsp+0x8],rdx
     bcc:	mov    rbx,rdx
     bcf:	mov    rsi,r13
     bd2:	mov    rdi,r12
     bd5:	call   bda <botlish_fn_12+0x39>
			bd6: R_X86_64_PLT32	botlish_fn_11-0x4 ; high_nibble<generic>
     bda:	test   rax,rax
     bdd:	je     d0b <botlish_fn_12+0x16a>
     be3:	test   rax,0x1
     be9:	jne    bf7 <botlish_fn_12+0x56>
     bef:	mov    rdx,rax
     bf2:	jmp    c0d <botlish_fn_12+0x6c>
     bf7:	mov    rdx,QWORD PTR [rbx+0x8]
     bfb:	mov    rcx,rax
     bfe:	sar    rcx,1
     c01:	cmp    rcx,rdx
     c04:	jb     c29 <botlish_fn_12+0x88>
     c0a:	mov    rdx,rax
     c0d:	mov    rsi,rbx
     c10:	mov    rdi,r12
     c13:	call   c18 <botlish_fn_12+0x77>
			c14: R_X86_64_PLT32	rt_list_get-0x4
     c18:	test   rax,rax
     c1b:	je     d0b <botlish_fn_12+0x16a>
     c21:	mov    rsi,rax
     c24:	jmp    c31 <botlish_fn_12+0x90>
     c29:	mov    rax,QWORD PTR [rbx+0x10]
     c2d:	mov    rsi,QWORD PTR [rax+rcx*8]
     c31:	mov    QWORD PTR [rsp],rsi
     c35:	mov    r14,rsi
     c38:	mov    ecx,0x1
     c3d:	mov    rsi,r13
     c40:	test   rsi,0x1
     c47:	jne    c65 <botlish_fn_12+0xc4>
     c4d:	xor    ecx,ecx
     c4f:	test   rsi,0x7
     c56:	jne    c65 <botlish_fn_12+0xc4>
     c5c:	movzx  rax,BYTE PTR [rsi]
     c60:	cmp    al,0x1
     c62:	sete   cl
     c65:	test   cl,cl
     c67:	jne    c88 <botlish_fn_12+0xe7>
     c6d:	mov    rdi,r12
     c70:	mov    rax,QWORD PTR [rdi+0x10]
     c74:	mov    rcx,QWORD PTR [rax+0xb0]
     c7b:	xor    rdx,rdx
     c7e:	call   c83 <botlish_fn_12+0xe2>
			c7f: R_X86_64_PLT32	rt_type_error-0x4
     c83:	jmp    d0b <botlish_fn_12+0x16a>
     c88:	mov    edx,0x21
     c8d:	mov    rdi,r12
     c90:	call   c95 <botlish_fn_12+0xf4>
			c91: R_X86_64_PLT32	rt_int_mod-0x4
     c95:	test   rax,rax
     c98:	je     d0b <botlish_fn_12+0x16a>
     c9e:	test   rax,0x1
     ca4:	jne    cb5 <botlish_fn_12+0x114>
     caa:	mov    rdx,rax
     cad:	mov    rsi,rbx
     cb0:	jmp    cce <botlish_fn_12+0x12d>
     cb5:	mov    rdi,QWORD PTR [rbx+0x8]
     cb9:	mov    rsi,rax
     cbc:	sar    rsi,1
     cbf:	mov    rdx,rax
     cc2:	cmp    rsi,rdi
     cc5:	jb     ce7 <botlish_fn_12+0x146>
     ccb:	mov    rsi,rbx
     cce:	mov    rdi,r12
     cd1:	call   cd6 <botlish_fn_12+0x135>
			cd2: R_X86_64_PLT32	rt_list_get-0x4
     cd6:	test   rax,rax
     cd9:	je     d0b <botlish_fn_12+0x16a>
     cdf:	mov    rdx,rax
     ce2:	jmp    cf2 <botlish_fn_12+0x151>
     ce7:	mov    rax,rbx
     cea:	mov    rax,QWORD PTR [rax+0x10]
     cee:	mov    rdx,QWORD PTR [rax+rsi*8]
     cf2:	mov    QWORD PTR [rsp+0x8],rdx
     cf7:	mov    rsi,r14
     cfa:	mov    rdi,r12
     cfd:	call   d02 <botlish_fn_12+0x161>
			cfe: R_X86_64_PLT32	rt_str_cat-0x4
     d02:	test   rax,rax
     d05:	jne    d2b <botlish_fn_12+0x18a>
     d0b:	xor    rax,rax
     d0e:	mov    rbx,QWORD PTR [rsp+0x10]
     d13:	mov    r12,QWORD PTR [rsp+0x18]
     d18:	mov    r13,QWORD PTR [rsp+0x20]
     d1d:	mov    r14,QWORD PTR [rsp+0x28]
     d22:	add    rsp,0x30
     d26:	mov    rsp,rbp
     d29:	pop    rbp
     d2a:	ret
     d2b:	mov    rbx,QWORD PTR [rsp+0x10]
     d30:	mov    r12,QWORD PTR [rsp+0x18]
     d35:	mov    r13,QWORD PTR [rsp+0x20]
     d3a:	mov    r14,QWORD PTR [rsp+0x28]
     d3f:	add    rsp,0x30
     d43:	mov    rsp,rbp
     d46:	pop    rbp
     d47:	ret

0000000000000d48 <botlish_entry_12: hex_pair<generic>>:
     d48:	push   rbp
     d49:	mov    rbp,rsp
     d4c:	mov    rsi,QWORD PTR [rdx]
     d4f:	mov    rdx,QWORD PTR [rdx+0x8]
     d53:	call   d58 <botlish_entry_12+0x10>
			d54: R_X86_64_PLT32	botlish_fn_12-0x4 ; hex_pair<generic>
     d58:	mov    rsp,rbp
     d5b:	pop    rbp
     d5c:	ret
     d5d:	add    BYTE PTR [rax],al
	...

0000000000000d60 <botlish_fn_13: esc_bytes<generic>>:
     d60:	push   rbp
     d61:	mov    rbp,rsp
     d64:	sub    rsp,0x70
     d68:	mov    QWORD PTR [rsp+0x40],rbx
     d6d:	mov    QWORD PTR [rsp+0x48],r12
     d72:	mov    QWORD PTR [rsp+0x50],r13
     d77:	mov    QWORD PTR [rsp+0x58],r14
     d7c:	mov    QWORD PTR [rsp+0x60],r15
     d81:	mov    r13,rdi
     d84:	mov    QWORD PTR [rsp+0x28],0x0
     d8d:	mov    QWORD PTR [rsp],rsi
     d91:	mov    QWORD PTR [rsp+0x8],rdx
     d96:	mov    QWORD PTR [rsp+0x10],rcx
     d9b:	mov    QWORD PTR [rsp+0x18],r8
     da0:	mov    r12,r8
     da3:	mov    r14,rcx
     da6:	mov    r15,rdx
     da9:	xor    eax,eax
     dab:	test   rsi,0x7
     db2:	jne    dc3 <botlish_fn_13+0x63>
     db8:	movzx  r8,BYTE PTR [rsi]
     dbc:	cmp    r8b,0x3
     dc0:	sete   al
     dc3:	test   al,al
     dc5:	jne    de8 <botlish_fn_13+0x88>
     dcb:	mov    rdi,r13
     dce:	mov    rax,QWORD PTR [rdi+0x10]
     dd2:	mov    rcx,QWORD PTR [rax+0xb8]
     dd9:	mov    edx,0x4
     dde:	call   de3 <botlish_fn_13+0x83>
			ddf: R_X86_64_PLT32	rt_type_error-0x4
     de3:	jmp    fee <botlish_fn_13+0x28e>
     de8:	mov    rbx,rsi
     deb:	mov    rdi,r13
     dee:	call   df3 <botlish_fn_13+0x93>
			def: R_X86_64_PLT32	rt_list_len-0x4
     df3:	mov    ecx,0x1
     df8:	mov    rsi,r15
     dfb:	test   rsi,0x1
     e02:	jne    e28 <botlish_fn_13+0xc8>
     e08:	xor    ecx,ecx
     e0a:	mov    rsi,r15
     e0d:	test   rsi,0x7
     e14:	jne    e28 <botlish_fn_13+0xc8>
     e1a:	mov    rsi,r15
     e1d:	movzx  rcx,BYTE PTR [rsi]
     e21:	rex cmp cl,0x1
     e25:	sete   cl
     e28:	test   cl,cl
     e2a:	jne    e4e <botlish_fn_13+0xee>
     e30:	mov    rdi,r13
     e33:	mov    rax,QWORD PTR [rdi+0x10]
     e37:	mov    rcx,QWORD PTR [rax+0xc0]
     e3e:	xor    rdx,rdx
     e41:	mov    rsi,r15
     e44:	call   e49 <botlish_fn_13+0xe9>
			e45: R_X86_64_PLT32	rt_type_error-0x4
     e49:	jmp    fee <botlish_fn_13+0x28e>
     e4e:	mov    rsi,r15
     e51:	mov    rcx,rsi
     e54:	and    rcx,rax
     e57:	mov    rdx,rax
     e5a:	test   rcx,0x1
     e61:	jne    e87 <botlish_fn_13+0x127>
     e67:	mov    rsi,r15
     e6a:	mov    rdi,r13
     e6d:	call   e72 <botlish_fn_13+0x112>
			e6e: R_X86_64_PLT32	rt_int_cmp-0x4
     e72:	mov    ecx,0x2
     e77:	test   rax,rax
     e7a:	cmovge rcx,QWORD PTR [rip+0x1de]        # 1060 <botlish_fn_13+0x300>
     e82:	jmp    e9a <botlish_fn_13+0x13a>
     e87:	mov    ecx,0x2
     e8c:	mov    rsi,r15
     e8f:	cmp    rsi,rdx
     e92:	cmovge rcx,QWORD PTR [rip+0x1c6]        # 1060 <botlish_fn_13+0x300>
     e9a:	cmp    rcx,0x6
     e9e:	je     1039 <botlish_fn_13+0x2d9>
     ea4:	mov    QWORD PTR [rsp+0x20],0x3
     ead:	mov    rsi,r15
     eb0:	test   rsi,0x1
     eb7:	je     ed2 <botlish_fn_13+0x172>
     ebd:	mov    rsi,r15
     ec0:	mov    rax,rsi
     ec3:	add    rax,0x2
     ec7:	seto   cl
     eca:	test   cl,cl
     ecc:	je     ee2 <botlish_fn_13+0x182>
     ed2:	mov    edx,0x3
     ed7:	mov    rsi,r15
     eda:	mov    rdi,r13
     edd:	call   ee2 <botlish_fn_13+0x182>
			ede: R_X86_64_PLT32	rt_int_add-0x4
     ee2:	mov    QWORD PTR [rsp+0x8],rax
     ee7:	mov    rdi,r13
     eea:	mov    QWORD PTR [rsp+0x30],rax
     eef:	mov    rax,QWORD PTR [rdi+0x10]
     ef3:	mov    rsi,QWORD PTR [rax+0xc8]
     efa:	mov    QWORD PTR [rsp+0x20],rsi
     eff:	mov    QWORD PTR [rsp+0x38],rsi
     f04:	mov    rsi,r15
     f07:	test   rsi,0x1
     f0e:	jne    f1c <botlish_fn_13+0x1bc>
     f14:	mov    rdx,r15
     f17:	jmp    f35 <botlish_fn_13+0x1d5>
     f1c:	mov    rcx,QWORD PTR [rbx+0x8]
     f20:	mov    rsi,r15
     f23:	mov    rax,rsi
     f26:	sar    rax,1
     f29:	cmp    rax,rcx
     f2c:	jb     f51 <botlish_fn_13+0x1f1>
     f32:	mov    rdx,r15
     f35:	mov    rsi,rbx
     f38:	mov    rdi,r13
     f3b:	call   f40 <botlish_fn_13+0x1e0>
			f3c: R_X86_64_PLT32	rt_list_get-0x4
     f40:	test   rax,rax
     f43:	je     fee <botlish_fn_13+0x28e>
     f49:	mov    rsi,rax
     f4c:	jmp    f59 <botlish_fn_13+0x1f9>
     f51:	mov    rcx,QWORD PTR [rbx+0x10]
     f55:	mov    rsi,QWORD PTR [rcx+rax*8]
     f59:	mov    QWORD PTR [rsp+0x28],rsi
     f5e:	mov    rdx,r12
     f61:	mov    rdi,r13
     f64:	call   f69 <botlish_fn_13+0x209>
			f65: R_X86_64_PLT32	botlish_fn_12-0x4 ; hex_pair<generic>
     f69:	test   rax,rax
     f6c:	je     fee <botlish_fn_13+0x28e>
     f72:	mov    QWORD PTR [rsp+0x28],rax
     f77:	mov    rdx,rax
     f7a:	mov    rsi,QWORD PTR [rsp+0x38]
     f7f:	mov    rdi,r13
     f82:	call   f87 <botlish_fn_13+0x227>
			f83: R_X86_64_PLT32	rt_str_cat-0x4
     f87:	test   rax,rax
     f8a:	je     fee <botlish_fn_13+0x28e>
     f90:	mov    QWORD PTR [rsp+0x20],rax
     f95:	mov    rdx,rax
     f98:	xor    eax,eax
     f9a:	mov    rsi,r14
     f9d:	test   rsi,0x7
     fa4:	jne    fb5 <botlish_fn_13+0x255>
     faa:	movzx  rdi,BYTE PTR [rsi]
     fae:	cmp    dil,0x2
     fb2:	sete   al
     fb5:	test   al,al
     fb7:	jne    fdd <botlish_fn_13+0x27d>
     fbd:	mov    rdi,r13
     fc0:	mov    rdi,QWORD PTR [rdi+0x10]
     fc4:	mov    rcx,QWORD PTR [rdi+0xd0]
     fcb:	mov    edx,0x1
     fd0:	mov    rdi,r13
     fd3:	call   fd8 <botlish_fn_13+0x278>
			fd4: R_X86_64_PLT32	rt_type_error-0x4
     fd8:	jmp    fee <botlish_fn_13+0x28e>
     fdd:	mov    rdi,r13
     fe0:	call   fe5 <botlish_fn_13+0x285>
			fe1: R_X86_64_PLT32	rt_str_cat-0x4
     fe5:	test   rax,rax
     fe8:	jne    1013 <botlish_fn_13+0x2b3>
     fee:	xor    rax,rax
     ff1:	mov    rbx,QWORD PTR [rsp+0x40]
     ff6:	mov    r12,QWORD PTR [rsp+0x48]
     ffb:	mov    r13,QWORD PTR [rsp+0x50]
    1000:	mov    r14,QWORD PTR [rsp+0x58]
    1005:	mov    r15,QWORD PTR [rsp+0x60]
    100a:	add    rsp,0x70
    100e:	mov    rsp,rbp
    1011:	pop    rbp
    1012:	ret
    1013:	mov    QWORD PTR [rsp],rbx
    1017:	mov    rcx,QWORD PTR [rsp+0x30]
    101c:	mov    QWORD PTR [rsp+0x8],rcx
    1021:	mov    QWORD PTR [rsp+0x10],rax
    1026:	mov    QWORD PTR [rsp+0x18],r12
    102b:	mov    rsi,rbx
    102e:	mov    r14,rax
    1031:	mov    r15,rcx
    1034:	jmp    da9 <botlish_fn_13+0x49>
    1039:	mov    rax,r14
    103c:	mov    rbx,QWORD PTR [rsp+0x40]
    1041:	mov    r12,QWORD PTR [rsp+0x48]
    1046:	mov    r13,QWORD PTR [rsp+0x50]
    104b:	mov    r14,QWORD PTR [rsp+0x58]
    1050:	mov    r15,QWORD PTR [rsp+0x60]
    1055:	add    rsp,0x70
    1059:	mov    rsp,rbp
    105c:	pop    rbp
    105d:	ret
    105e:	add    BYTE PTR [rax],al
    1060:	(bad)
    1061:	add    BYTE PTR [rax],al
    1063:	add    BYTE PTR [rax],al
    1065:	add    BYTE PTR [rax],al
	...

0000000000001068 <botlish_entry_13: esc_bytes<generic>>:
    1068:	push   rbp
    1069:	mov    rbp,rsp
    106c:	mov    rsi,QWORD PTR [rdx]
    106f:	mov    r9,QWORD PTR [rdx+0x8]
    1073:	mov    rcx,QWORD PTR [rdx+0x10]
    1077:	mov    r8,QWORD PTR [rdx+0x18]
    107b:	mov    rdx,r9
    107e:	call   1083 <botlish_entry_13+0x1b>
			107f: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    1083:	mov    rsp,rbp
    1086:	pop    rbp
    1087:	ret

0000000000001088 <botlish_fn_14: esc_char<generic>>:
    1088:	push   rbp
    1089:	mov    rbp,rsp
    108c:	sub    rsp,0x60
    1090:	mov    QWORD PTR [rsp+0x30],rbx
    1095:	mov    QWORD PTR [rsp+0x38],r12
    109a:	mov    QWORD PTR [rsp+0x40],r13
    109f:	mov    QWORD PTR [rsp+0x48],r14
    10a4:	mov    QWORD PTR [rsp+0x50],r15
    10a9:	mov    QWORD PTR [rsp+0x18],0x0
    10b2:	mov    QWORD PTR [rsp],rsi
    10b6:	mov    QWORD PTR [rsp+0x8],rdx
    10bb:	mov    r12,rdx
    10be:	mov    QWORD PTR [rsp+0x10],rcx
    10c3:	mov    rbx,rcx
    10c6:	xor    r10d,r10d
    10c9:	test   rsi,0x7
    10d0:	jne    10e0 <botlish_fn_14+0x58>
    10d6:	movzx  rax,BYTE PTR [rsi]
    10da:	cmp    al,0x2
    10dc:	sete   r10b
    10e0:	test   r10b,r10b
    10e3:	jne    1103 <botlish_fn_14+0x7b>
    10e9:	mov    rax,QWORD PTR [rdi+0x10]
    10ed:	mov    rcx,QWORD PTR [rax+0xd8]
    10f4:	mov    edx,0x1
    10f9:	call   10fe <botlish_fn_14+0x76>
			10fa: R_X86_64_PLT32	rt_type_error-0x4
    10fe:	jmp    1202 <botlish_fn_14+0x17a>
    1103:	mov    r13,rdi
    1106:	mov    QWORD PTR [rsp+0x20],rsi
    110b:	call   1110 <botlish_fn_14+0x88>
			110c: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1110:	mov    rcx,rax
    1113:	mov    r14,rax
    1116:	test   rax,rcx
    1119:	je     1202 <botlish_fn_14+0x17a>
    111f:	mov    rax,r14
    1122:	mov    QWORD PTR [rsp],rax
    1126:	mov    rsi,r14
    1129:	mov    rdi,r13
    112c:	call   1131 <botlish_fn_14+0xa9>
			112d: R_X86_64_PLT32	rt_list_len-0x4
    1131:	mov    edx,0x1
    1136:	sar    rax,1
    1139:	cmp    rax,0x1
    113d:	je     1178 <botlish_fn_14+0xf0>
    1143:	mov    QWORD PTR [rsp+0x8],0x1
    114c:	mov    rdi,r13
    114f:	mov    rax,QWORD PTR [rdi+0x10]
    1153:	mov    rcx,QWORD PTR [rax+0xa0]
    115a:	mov    QWORD PTR [rsp+0x18],rcx
    115f:	mov    rsi,r14
    1162:	mov    r8,rbx
    1165:	call   116a <botlish_fn_14+0xe2>
			1166: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    116a:	test   rax,rax
    116d:	je     1202 <botlish_fn_14+0x17a>
    1173:	jmp    1231 <botlish_fn_14+0x1a9>
    1178:	mov    rsi,r14
    117b:	mov    r15,rdx
    117e:	mov    rax,QWORD PTR [rsi+0x8]
    1182:	mov    r14,rsi
    1185:	test   rax,rax
    1188:	jne    11b0 <botlish_fn_14+0x128>
    118e:	mov    rdx,r15
    1191:	mov    rsi,r14
    1194:	mov    rdi,r13
    1197:	call   119c <botlish_fn_14+0x114>
			1198: R_X86_64_PLT32	rt_list_get-0x4
    119c:	test   rax,rax
    119f:	je     1202 <botlish_fn_14+0x17a>
    11a5:	mov    rdx,rax
    11a8:	mov    rsi,r12
    11ab:	jmp    11bd <botlish_fn_14+0x135>
    11b0:	mov    rsi,r14
    11b3:	mov    rdx,QWORD PTR [rsi+0x10]
    11b7:	mov    rdx,QWORD PTR [rdx]
    11ba:	mov    rsi,r12
    11bd:	mov    rdi,r13
    11c0:	call   11c5 <botlish_fn_14+0x13d>
			11c1: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_unreserved<generic>
    11c5:	cmp    rax,0x6
    11c9:	je     122c <botlish_fn_14+0x1a4>
    11cf:	mov    QWORD PTR [rsp+0x8],0x1
    11d8:	mov    rdi,r13
    11db:	mov    rsi,QWORD PTR [rdi+0x10]
    11df:	mov    rcx,QWORD PTR [rsi+0xa0]
    11e6:	mov    QWORD PTR [rsp+0x18],rcx
    11eb:	mov    rdx,r15
    11ee:	mov    rsi,r14
    11f1:	mov    r8,rbx
    11f4:	call   11f9 <botlish_fn_14+0x171>
			11f5: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    11f9:	test   rax,rax
    11fc:	jne    1227 <botlish_fn_14+0x19f>
    1202:	xor    rax,rax
    1205:	mov    rbx,QWORD PTR [rsp+0x30]
    120a:	mov    r12,QWORD PTR [rsp+0x38]
    120f:	mov    r13,QWORD PTR [rsp+0x40]
    1214:	mov    r14,QWORD PTR [rsp+0x48]
    1219:	mov    r15,QWORD PTR [rsp+0x50]
    121e:	add    rsp,0x60
    1222:	mov    rsp,rbp
    1225:	pop    rbp
    1226:	ret
    1227:	mov    QWORD PTR [rsp+0x20],rax
    122c:	mov    rax,QWORD PTR [rsp+0x20]
    1231:	mov    rbx,QWORD PTR [rsp+0x30]
    1236:	mov    r12,QWORD PTR [rsp+0x38]
    123b:	mov    r13,QWORD PTR [rsp+0x40]
    1240:	mov    r14,QWORD PTR [rsp+0x48]
    1245:	mov    r15,QWORD PTR [rsp+0x50]
    124a:	add    rsp,0x60
    124e:	mov    rsp,rbp
    1251:	pop    rbp
    1252:	ret

0000000000001253 <botlish_entry_14: esc_char<generic>>:
    1253:	push   rbp
    1254:	mov    rbp,rsp
    1257:	mov    rsi,QWORD PTR [rdx]
    125a:	mov    r8,QWORD PTR [rdx+0x8]
    125e:	mov    rcx,QWORD PTR [rdx+0x10]
    1262:	mov    rdx,r8
    1265:	call   126a <botlish_entry_14+0x17>
			1266: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_char<generic>
    126a:	mov    rsp,rbp
    126d:	pop    rbp
    126e:	ret
	...

0000000000001270 <botlish_fn_15: esc_from<generic>>:
    1270:	push   rbp
    1271:	mov    rbp,rsp
    1274:	sub    rsp,0x80
    127b:	mov    QWORD PTR [rsp+0x50],rbx
    1280:	mov    QWORD PTR [rsp+0x58],r12
    1285:	mov    QWORD PTR [rsp+0x60],r13
    128a:	mov    QWORD PTR [rsp+0x68],r14
    128f:	mov    QWORD PTR [rsp+0x70],r15
    1294:	mov    r14,rdi
    1297:	mov    QWORD PTR [rsp+0x30],0x0
    12a0:	mov    QWORD PTR [rsp],rsi
    12a4:	mov    QWORD PTR [rsp+0x8],rdx
    12a9:	mov    QWORD PTR [rsp+0x10],rcx
    12ae:	mov    QWORD PTR [rsp+0x18],r8
    12b3:	mov    r13,r8
    12b6:	mov    QWORD PTR [rsp+0x20],r9
    12bb:	mov    r12,r9
    12be:	mov    r15,rcx
    12c1:	mov    QWORD PTR [rsp+0x38],rdx
    12c6:	xor    eax,eax
    12c8:	test   rsi,0x7
    12cf:	jne    12de <botlish_fn_15+0x6e>
    12d5:	movzx  rax,BYTE PTR [rsi]
    12d9:	cmp    al,0x2
    12db:	sete   al
    12de:	test   al,al
    12e0:	jne    1303 <botlish_fn_15+0x93>
    12e6:	mov    rdi,r14
    12e9:	mov    rax,QWORD PTR [rdi+0x10]
    12ed:	mov    rcx,QWORD PTR [rax+0xe0]
    12f4:	mov    edx,0x1
    12f9:	call   12fe <botlish_fn_15+0x8e>
			12fa: R_X86_64_PLT32	rt_type_error-0x4
    12fe:	jmp    155b <botlish_fn_15+0x2eb>
    1303:	mov    rbx,rsi
    1306:	mov    rdi,r14
    1309:	call   130e <botlish_fn_15+0x9e>
			130a: R_X86_64_PLT32	rt_str_len-0x4
    130e:	mov    edx,0x1
    1313:	mov    QWORD PTR [rsp+0x48],rdx
    1318:	mov    ecx,0x1
    131d:	mov    rsi,QWORD PTR [rsp+0x38]
    1322:	test   rsi,0x1
    1329:	jne    1353 <botlish_fn_15+0xe3>
    132f:	xor    ecx,ecx
    1331:	mov    rsi,QWORD PTR [rsp+0x38]
    1336:	test   rsi,0x7
    133d:	jne    1353 <botlish_fn_15+0xe3>
    1343:	mov    rsi,QWORD PTR [rsp+0x38]
    1348:	movzx  rcx,BYTE PTR [rsi]
    134c:	rex cmp cl,0x1
    1350:	sete   cl
    1353:	test   cl,cl
    1355:	jne    137b <botlish_fn_15+0x10b>
    135b:	mov    rdi,r14
    135e:	mov    rax,QWORD PTR [rdi+0x10]
    1362:	mov    rcx,QWORD PTR [rax+0xc0]
    1369:	xor    rdx,rdx
    136c:	mov    rsi,QWORD PTR [rsp+0x38]
    1371:	call   1376 <botlish_fn_15+0x106>
			1372: R_X86_64_PLT32	rt_type_error-0x4
    1376:	jmp    155b <botlish_fn_15+0x2eb>
    137b:	mov    rsi,QWORD PTR [rsp+0x38]
    1380:	mov    rcx,rsi
    1383:	and    rcx,rax
    1386:	mov    rdx,rax
    1389:	test   rcx,0x1
    1390:	jne    13b8 <botlish_fn_15+0x148>
    1396:	mov    rsi,QWORD PTR [rsp+0x38]
    139b:	mov    rdi,r14
    139e:	call   13a3 <botlish_fn_15+0x133>
			139f: R_X86_64_PLT32	rt_int_cmp-0x4
    13a3:	mov    ecx,0x2
    13a8:	test   rax,rax
    13ab:	cmovge rcx,QWORD PTR [rip+0x235]        # 15e8 <botlish_fn_15+0x378>
    13b3:	jmp    13cd <botlish_fn_15+0x15d>
    13b8:	mov    ecx,0x2
    13bd:	mov    rsi,QWORD PTR [rsp+0x38]
    13c2:	cmp    rsi,rdx
    13c5:	cmovge rcx,QWORD PTR [rip+0x21b]        # 15e8 <botlish_fn_15+0x378>
    13cd:	cmp    rcx,0x6
    13d1:	je     15b9 <botlish_fn_15+0x349>
    13d7:	mov    QWORD PTR [rsp+0x28],0x3
    13e0:	mov    rsi,QWORD PTR [rsp+0x38]
    13e5:	test   rsi,0x1
    13ec:	je     1409 <botlish_fn_15+0x199>
    13f2:	mov    rsi,QWORD PTR [rsp+0x38]
    13f7:	mov    rax,rsi
    13fa:	add    rax,0x2
    13fe:	seto   cl
    1401:	test   cl,cl
    1403:	je     141b <botlish_fn_15+0x1ab>
    1409:	mov    edx,0x3
    140e:	mov    rsi,QWORD PTR [rsp+0x38]
    1413:	mov    rdi,r14
    1416:	call   141b <botlish_fn_15+0x1ab>
			1417: R_X86_64_PLT32	rt_int_add-0x4
    141b:	mov    QWORD PTR [rsp+0x28],rax
    1420:	mov    QWORD PTR [rsp+0x40],rax
    1425:	mov    QWORD PTR [rsp+0x30],0x3
    142e:	mov    rsi,QWORD PTR [rsp+0x38]
    1433:	test   rsi,0x1
    143a:	je     1457 <botlish_fn_15+0x1e7>
    1440:	mov    rsi,QWORD PTR [rsp+0x38]
    1445:	mov    rcx,rsi
    1448:	add    rcx,0x2
    144c:	seto   al
    144f:	test   al,al
    1451:	je     146c <botlish_fn_15+0x1fc>
    1457:	mov    edx,0x3
    145c:	mov    rsi,QWORD PTR [rsp+0x38]
    1461:	mov    rdi,r14
    1464:	call   1469 <botlish_fn_15+0x1f9>
			1465: R_X86_64_PLT32	rt_int_add-0x4
    1469:	mov    rcx,rax
    146c:	mov    QWORD PTR [rsp+0x30],rcx
    1471:	mov    rdx,QWORD PTR [rsp+0x38]
    1476:	mov    rsi,rbx
    1479:	mov    rdi,r14
    147c:	call   1481 <botlish_fn_15+0x211>
			147d: R_X86_64_PLT32	rt_substr-0x4
    1481:	test   rax,rax
    1484:	je     155b <botlish_fn_15+0x2eb>
    148a:	mov    QWORD PTR [rsp+0x8],rax
    148f:	mov    r8,r12
    1492:	mov    r12,r13
    1495:	mov    r13,r8
    1498:	mov    rsi,rax
    149b:	mov    rcx,r13
    149e:	mov    rdx,r12
    14a1:	mov    rdi,r14
    14a4:	call   14a9 <botlish_fn_15+0x239>
			14a5: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_char<generic>
    14a9:	test   rax,rax
    14ac:	je     155b <botlish_fn_15+0x2eb>
    14b2:	mov    QWORD PTR [rsp+0x8],rax
    14b7:	xor    ecx,ecx
    14b9:	mov    rsi,r15
    14bc:	test   rsi,0x7
    14c3:	jne    14d4 <botlish_fn_15+0x264>
    14c9:	movzx  rdi,BYTE PTR [rsi]
    14cd:	cmp    dil,0x2
    14d1:	sete   cl
    14d4:	test   cl,cl
    14d6:	jne    14f9 <botlish_fn_15+0x289>
    14dc:	mov    rdi,r14
    14df:	mov    r11,QWORD PTR [rdi+0x10]
    14e3:	mov    rcx,QWORD PTR [r11+0xd0]
    14ea:	mov    rdx,QWORD PTR [rsp+0x48]
    14ef:	call   14f4 <botlish_fn_15+0x284>
			14f0: R_X86_64_PLT32	rt_type_error-0x4
    14f4:	jmp    155b <botlish_fn_15+0x2eb>
    14f9:	mov    rdx,QWORD PTR [rsp+0x48]
    14fe:	xor    edi,edi
    1500:	test   rax,0x7
    1506:	je     1514 <botlish_fn_15+0x2a4>
    150c:	mov    r8,rax
    150f:	jmp    1523 <botlish_fn_15+0x2b3>
    1514:	movzx  rcx,BYTE PTR [rax]
    1518:	mov    r8,rax
    151b:	rex cmp cl,0x2
    151f:	sete   dil
    1523:	test   dil,dil
    1526:	jne    1547 <botlish_fn_15+0x2d7>
    152c:	mov    rdi,r14
    152f:	mov    rax,QWORD PTR [rdi+0x10]
    1533:	mov    rcx,QWORD PTR [rax+0xd0]
    153a:	mov    rsi,r8
    153d:	call   1542 <botlish_fn_15+0x2d2>
			153e: R_X86_64_PLT32	rt_type_error-0x4
    1542:	jmp    155b <botlish_fn_15+0x2eb>
    1547:	mov    rdx,r8
    154a:	mov    rdi,r14
    154d:	call   1552 <botlish_fn_15+0x2e2>
			154e: R_X86_64_PLT32	rt_str_cat-0x4
    1552:	test   rax,rax
    1555:	jne    1583 <botlish_fn_15+0x313>
    155b:	xor    rax,rax
    155e:	mov    rbx,QWORD PTR [rsp+0x50]
    1563:	mov    r12,QWORD PTR [rsp+0x58]
    1568:	mov    r13,QWORD PTR [rsp+0x60]
    156d:	mov    r14,QWORD PTR [rsp+0x68]
    1572:	mov    r15,QWORD PTR [rsp+0x70]
    1577:	add    rsp,0x80
    157e:	mov    rsp,rbp
    1581:	pop    rbp
    1582:	ret
    1583:	mov    QWORD PTR [rsp],rbx
    1587:	mov    rcx,QWORD PTR [rsp+0x40]
    158c:	mov    QWORD PTR [rsp+0x8],rcx
    1591:	mov    QWORD PTR [rsp+0x10],rax
    1596:	mov    QWORD PTR [rsp+0x18],r12
    159b:	mov    QWORD PTR [rsp+0x20],r13
    15a0:	mov    QWORD PTR [rsp+0x38],rcx
    15a5:	mov    r15,rax
    15a8:	mov    rdx,r12
    15ab:	mov    r12,r13
    15ae:	mov    r13,rdx
    15b1:	mov    rsi,rbx
    15b4:	jmp    12c6 <botlish_fn_15+0x56>
    15b9:	mov    rax,r15
    15bc:	mov    rbx,QWORD PTR [rsp+0x50]
    15c1:	mov    r12,QWORD PTR [rsp+0x58]
    15c6:	mov    r13,QWORD PTR [rsp+0x60]
    15cb:	mov    r14,QWORD PTR [rsp+0x68]
    15d0:	mov    r15,QWORD PTR [rsp+0x70]
    15d5:	add    rsp,0x80
    15dc:	mov    rsp,rbp
    15df:	pop    rbp
    15e0:	ret
    15e1:	add    BYTE PTR [rax],al
    15e3:	add    BYTE PTR [rax],al
    15e5:	add    BYTE PTR [rax],al
    15e7:	add    BYTE PTR [rsi],al
    15e9:	add    BYTE PTR [rax],al
    15eb:	add    BYTE PTR [rax],al
    15ed:	add    BYTE PTR [rax],al
	...

00000000000015f0 <botlish_entry_15: esc_from<generic>>:
    15f0:	push   rbp
    15f1:	mov    rbp,rsp
    15f4:	mov    rsi,QWORD PTR [rdx]
    15f7:	mov    r10,QWORD PTR [rdx+0x8]
    15fb:	mov    rcx,QWORD PTR [rdx+0x10]
    15ff:	mov    r8,QWORD PTR [rdx+0x18]
    1603:	mov    r9,QWORD PTR [rdx+0x20]
    1607:	mov    rdx,r10
    160a:	call   160f <botlish_entry_15+0x1f>
			160b: R_X86_64_PLT32	botlish_fn_15-0x4 ; esc_from<generic>
    160f:	mov    rsp,rbp
    1612:	pop    rbp
    1613:	ret
    1614:	add    BYTE PTR [rax],al
	...

0000000000001618 <botlish_fn_16: check<int, int, str, str>>:
    1618:	push   rbp
    1619:	mov    rbp,rsp
    161c:	sub    rsp,0x60
    1620:	mov    QWORD PTR [rsp+0x30],rbx
    1625:	mov    QWORD PTR [rsp+0x38],r12
    162a:	mov    QWORD PTR [rsp+0x40],r13
    162f:	mov    QWORD PTR [rsp+0x48],r14
    1634:	mov    QWORD PTR [rsp+0x50],r15
    1639:	mov    QWORD PTR [rsp+0x20],0x0
    1642:	mov    QWORD PTR [rsp],rsi
    1646:	mov    QWORD PTR [rsp+0x8],rdx
    164b:	mov    QWORD PTR [rsp+0x10],rcx
    1650:	mov    r12,rcx
    1653:	mov    QWORD PTR [rsp+0x18],r8
    1658:	mov    r14,r8
    165b:	mov    r13,rsi
    165e:	mov    r15,rdx
    1661:	test   r13,0x1
    1668:	jne    1693 <botlish_fn_16+0x7b>
    166e:	mov    edx,0x1
    1673:	mov    rbx,rdi
    1676:	mov    rsi,r13
    1679:	call   167e <botlish_fn_16+0x66>
			167a: R_X86_64_PLT32	rt_int_cmp-0x4
    167e:	mov    ecx,0x2
    1683:	test   rax,rax
    1686:	cmovle rcx,QWORD PTR [rip+0x152]        # 17e0 <botlish_fn_16+0x1c8>
    168e:	jmp    16a7 <botlish_fn_16+0x8f>
    1693:	mov    rbx,rdi
    1696:	mov    ecx,0x2
    169b:	cmp    r13,0x1
    169f:	cmovle rcx,QWORD PTR [rip+0x139]        # 17e0 <botlish_fn_16+0x1c8>
    16a7:	cmp    rcx,0x6
    16ab:	je     17b6 <botlish_fn_16+0x19e>
    16b1:	mov    rax,QWORD PTR [rbx+0x10]
    16b5:	mov    rax,QWORD PTR [rax+0xe8]
    16bc:	mov    rsi,r12
    16bf:	mov    rdi,rbx
    16c2:	call   16c7 <botlish_fn_16+0xaf>
			16c3: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    16c7:	test   rax,rax
    16ca:	je     170b <botlish_fn_16+0xf3>
    16d0:	cmp    rax,0x6
    16d4:	je     16ec <botlish_fn_16+0xd4>
    16da:	mov    edx,0x1
    16df:	mov    QWORD PTR [rsp],0x1
    16e7:	jmp    174d <botlish_fn_16+0x135>
    16ec:	mov    rax,QWORD PTR [rbx+0x10]
    16f0:	mov    rax,QWORD PTR [rax+0xf0]
    16f7:	mov    rsi,r12
    16fa:	mov    rdi,rbx
    16fd:	call   1702 <botlish_fn_16+0xea>
			16fe: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    1702:	test   rax,rax
    1705:	jne    1730 <botlish_fn_16+0x118>
    170b:	xor    rax,rax
    170e:	mov    rbx,QWORD PTR [rsp+0x30]
    1713:	mov    r12,QWORD PTR [rsp+0x38]
    1718:	mov    r13,QWORD PTR [rsp+0x40]
    171d:	mov    r14,QWORD PTR [rsp+0x48]
    1722:	mov    r15,QWORD PTR [rsp+0x50]
    1727:	add    rsp,0x60
    172b:	mov    rsp,rbp
    172e:	pop    rbp
    172f:	ret
    1730:	cmp    rax,0x6
    1734:	je     1744 <botlish_fn_16+0x12c>
    173a:	mov    edx,0x1
    173f:	jmp    1749 <botlish_fn_16+0x131>
    1744:	mov    edx,0x3
    1749:	mov    QWORD PTR [rsp],rdx
    174d:	sar    r13,1
    1750:	sub    r13,0x1
    1754:	shl    r13,1
    1757:	or     r13,0x1
    175b:	mov    QWORD PTR [rsp+0x20],r13
    1760:	mov    rsi,r15
    1763:	mov    rdi,rsi
    1766:	and    rdi,rdx
    1769:	test   rdi,0x1
    1770:	je     178d <botlish_fn_16+0x175>
    1776:	lea    r9,[rdx-0x1]
    177a:	mov    rax,rsi
    177d:	add    rax,r9
    1780:	seto   r10b
    1784:	test   r10b,r10b
    1787:	je     1795 <botlish_fn_16+0x17d>
    178d:	mov    rdi,rbx
    1790:	call   1795 <botlish_fn_16+0x17d>
			1791: R_X86_64_PLT32	rt_int_add-0x4
    1795:	mov    QWORD PTR [rsp],r13
    1799:	mov    QWORD PTR [rsp+0x8],rax
    179e:	mov    QWORD PTR [rsp+0x10],r12
    17a3:	mov    r8,r14
    17a6:	mov    QWORD PTR [rsp+0x18],r8
    17ab:	mov    rdi,rbx
    17ae:	mov    r15,rax
    17b1:	jmp    1661 <botlish_fn_16+0x49>
    17b6:	mov    rax,r15
    17b9:	mov    rbx,QWORD PTR [rsp+0x30]
    17be:	mov    r12,QWORD PTR [rsp+0x38]
    17c3:	mov    r13,QWORD PTR [rsp+0x40]
    17c8:	mov    r14,QWORD PTR [rsp+0x48]
    17cd:	mov    r15,QWORD PTR [rsp+0x50]
    17d2:	add    rsp,0x60
    17d6:	mov    rsp,rbp
    17d9:	pop    rbp
    17da:	ret
    17db:	add    BYTE PTR [rax],al
    17dd:	add    BYTE PTR [rax],al
    17df:	add    BYTE PTR [rsi],al
    17e1:	add    BYTE PTR [rax],al
    17e3:	add    BYTE PTR [rax],al
    17e5:	add    BYTE PTR [rax],al
	...

00000000000017e8 <botlish_entry_16: check<int, int, str, str>>:
    17e8:	push   rbp
    17e9:	mov    rbp,rsp
    17ec:	mov    rsi,QWORD PTR [rdx]
    17ef:	mov    r9,QWORD PTR [rdx+0x8]
    17f3:	mov    rcx,QWORD PTR [rdx+0x10]
    17f7:	mov    r8,QWORD PTR [rdx+0x18]
    17fb:	mov    rdx,r9
    17fe:	call   1803 <botlish_entry_16+0x1b>
			17ff: R_X86_64_PLT32	botlish_fn_16-0x4 ; check<int, int, str, str>
    1803:	mov    rsp,rbp
    1806:	pop    rbp
    1807:	ret

0000000000001808 <botlish_fn_17: <str>>:
    1808:	push   rbp
    1809:	mov    rbp,rsp
    180c:	sub    rsp,0x50
    1810:	mov    QWORD PTR [rsp+0x30],rbx
    1815:	mov    QWORD PTR [rsp+0x38],r12
    181a:	mov    QWORD PTR [rsp+0x40],r13
    181f:	mov    QWORD PTR [rsp+0x48],r14
    1824:	mov    r13,rdi
    1827:	mov    QWORD PTR [rsp+0x18],0x0
    1830:	mov    QWORD PTR [rsp],rsi
    1834:	mov    r14,rsi
    1837:	mov    rsi,r14
    183a:	mov    rdi,r13
    183d:	call   1842 <botlish_fn_17+0x3a>
			183e: R_X86_64_PLT32	rt_str_len-0x4
    1842:	mov    rbx,rax
    1845:	mov    QWORD PTR [rsp+0x8],rax
    184a:	mov    esi,0x1
    184f:	mov    QWORD PTR [rsp+0x10],0x1
    1858:	mov    rcx,r14
    185b:	mov    rdx,rbx
    185e:	mov    rdi,r13
    1861:	call   1866 <botlish_fn_17+0x5e>
			1862: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    1866:	mov    r12,rax
    1869:	test   r12,r12
    186c:	je     19c9 <botlish_fn_17+0x1c1>
    1872:	mov    QWORD PTR [rsp+0x10],r12
    1877:	test   r12,0x1
    187e:	jne    18a9 <botlish_fn_17+0xa1>
    1884:	mov    edx,0x1
    1889:	mov    rsi,r12
    188c:	mov    rdi,r13
    188f:	call   1894 <botlish_fn_17+0x8c>
			1890: R_X86_64_PLT32	rt_int_cmp-0x4
    1894:	mov    ecx,0x2
    1899:	test   rax,rax
    189c:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 1a68 <botlish_fn_17+0x260>
    18a4:	jmp    18ba <botlish_fn_17+0xb2>
    18a9:	mov    ecx,0x2
    18ae:	cmp    r12,0x1
    18b2:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 1a68 <botlish_fn_17+0x260>
    18ba:	cmp    rcx,0x6
    18be:	je     1a44 <botlish_fn_17+0x23c>
    18c4:	mov    rcx,r12
    18c7:	and    rcx,rbx
    18ca:	test   rcx,0x1
    18d1:	jne    18fa <botlish_fn_17+0xf2>
    18d7:	mov    rdx,rbx
    18da:	mov    rsi,r12
    18dd:	mov    rdi,r13
    18e0:	call   18e5 <botlish_fn_17+0xdd>
			18e1: R_X86_64_PLT32	rt_int_cmp-0x4
    18e5:	mov    ecx,0x2
    18ea:	test   rax,rax
    18ed:	cmovge rcx,QWORD PTR [rip+0x173]        # 1a68 <botlish_fn_17+0x260>
    18f5:	jmp    190a <botlish_fn_17+0x102>
    18fa:	mov    ecx,0x2
    18ff:	cmp    r12,rbx
    1902:	cmovge rcx,QWORD PTR [rip+0x15e]        # 1a68 <botlish_fn_17+0x260>
    190a:	cmp    rcx,0x6
    190e:	je     1a3a <botlish_fn_17+0x232>
    1914:	lea    rcx,[rsp+0x20]
    1919:	mov    rdx,r14
    191c:	mov    rsi,r12
    191f:	mov    rdi,r13
    1922:	call   1927 <botlish_fn_17+0x11f>
			1923: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    1927:	test   rax,rax
    192a:	mov    rsi,rax
    192d:	je     19c9 <botlish_fn_17+0x1c1>
    1933:	mov    rdx,QWORD PTR [rsp+0x20]
    1938:	mov    rcx,QWORD PTR [rsp+0x28]
    193d:	mov    rdi,r13
    1940:	mov    rax,QWORD PTR [rdi+0x10]
    1944:	mov    r8,QWORD PTR [rax+0xf8]
    194b:	call   1950 <botlish_fn_17+0x148>
			194c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1950:	cmp    rax,0x6
    1954:	je     1967 <botlish_fn_17+0x15f>
    195a:	mov    ecx,0x2
    195f:	mov    rax,rcx
    1962:	jmp    1a49 <botlish_fn_17+0x241>
    1967:	mov    QWORD PTR [rsp+0x18],0x3
    1970:	test   r12,0x1
    1977:	jne    1985 <botlish_fn_17+0x17d>
    197d:	mov    rcx,r12
    1980:	jmp    199a <botlish_fn_17+0x192>
    1985:	mov    rsi,r12
    1988:	add    rsi,0x2
    198c:	mov    rcx,r12
    198f:	seto   al
    1992:	test   al,al
    1994:	je     19ad <botlish_fn_17+0x1a5>
    199a:	mov    edx,0x3
    199f:	mov    rsi,rcx
    19a2:	mov    rdi,r13
    19a5:	call   19aa <botlish_fn_17+0x1a2>
			19a6: R_X86_64_PLT32	rt_int_add-0x4
    19aa:	mov    rsi,rax
    19ad:	mov    QWORD PTR [rsp+0x10],rsi
    19b2:	mov    rcx,r14
    19b5:	mov    rdx,rbx
    19b8:	mov    rdi,r13
    19bb:	call   19c0 <botlish_fn_17+0x1b8>
			19bc: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    19c0:	test   rax,rax
    19c3:	jne    19e9 <botlish_fn_17+0x1e1>
    19c9:	xor    rax,rax
    19cc:	mov    rbx,QWORD PTR [rsp+0x30]
    19d1:	mov    r12,QWORD PTR [rsp+0x38]
    19d6:	mov    r13,QWORD PTR [rsp+0x40]
    19db:	mov    r14,QWORD PTR [rsp+0x48]
    19e0:	add    rsp,0x50
    19e4:	mov    rsp,rbp
    19e7:	pop    rbp
    19e8:	ret
    19e9:	mov    rcx,rax
    19ec:	and    rcx,rbx
    19ef:	mov    rsi,rax
    19f2:	test   rcx,0x1
    19f9:	jne    1a22 <botlish_fn_17+0x21a>
    19ff:	mov    rdx,rbx
    1a02:	mov    rdi,r13
    1a05:	call   1a0a <botlish_fn_17+0x202>
			1a06: R_X86_64_PLT32	rt_int_cmp-0x4
    1a0a:	mov    ecx,0x2
    1a0f:	test   rax,rax
    1a12:	mov    rax,rcx
    1a15:	cmove  rax,QWORD PTR [rip+0x4b]        # 1a68 <botlish_fn_17+0x260>
    1a1d:	jmp    1a49 <botlish_fn_17+0x241>
    1a22:	mov    rdx,rbx
    1a25:	mov    eax,0x2
    1a2a:	cmp    rsi,rdx
    1a2d:	cmove  rax,QWORD PTR [rip+0x33]        # 1a68 <botlish_fn_17+0x260>
    1a35:	jmp    1a49 <botlish_fn_17+0x241>
    1a3a:	mov    eax,0x2
    1a3f:	jmp    1a49 <botlish_fn_17+0x241>
    1a44:	mov    eax,0x2
    1a49:	mov    rbx,QWORD PTR [rsp+0x30]
    1a4e:	mov    r12,QWORD PTR [rsp+0x38]
    1a53:	mov    r13,QWORD PTR [rsp+0x40]
    1a58:	mov    r14,QWORD PTR [rsp+0x48]
    1a5d:	add    rsp,0x50
    1a61:	mov    rsp,rbp
    1a64:	pop    rbp
    1a65:	ret
    1a66:	add    BYTE PTR [rax],al
    1a68:	(bad)
    1a69:	add    BYTE PTR [rax],al
    1a6b:	add    BYTE PTR [rax],al
    1a6d:	add    BYTE PTR [rax],al
	...

0000000000001a70 <botlish_entry_17: <str>>:
    1a70:	push   rbp
    1a71:	mov    rbp,rsp
    1a74:	mov    rsi,QWORD PTR [rdx]
    1a77:	call   1a7c <botlish_entry_17+0xc>
			1a78: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    1a7c:	mov    rsp,rbp
    1a7f:	pop    rbp
    1a80:	ret
    1a81:	add    BYTE PTR [rax],al
    1a83:	add    BYTE PTR [rax],al
    1a85:	add    BYTE PTR [rax],al
	...

0000000000001a88 <botlish_fn_18: <generic>>:
    1a88:	push   rbp
    1a89:	mov    rbp,rsp
    1a8c:	sub    rsp,0x60
    1a90:	mov    QWORD PTR [rsp+0x30],rbx
    1a95:	mov    QWORD PTR [rsp+0x38],r12
    1a9a:	mov    QWORD PTR [rsp+0x40],r13
    1a9f:	mov    QWORD PTR [rsp+0x48],r14
    1aa4:	mov    QWORD PTR [rsp+0x50],r15
    1aa9:	mov    QWORD PTR [rsp+0x18],0x0
    1ab2:	mov    QWORD PTR [rsp],rsi
    1ab6:	xor    r8d,r8d
    1ab9:	test   rsi,0x7
    1ac0:	jne    1ad0 <botlish_fn_18+0x48>
    1ac6:	movzx  rax,BYTE PTR [rsi]
    1aca:	cmp    al,0x2
    1acc:	sete   r8b
    1ad0:	test   r8b,r8b
    1ad3:	jne    1af3 <botlish_fn_18+0x6b>
    1ad9:	mov    rdx,QWORD PTR [rdi+0x10]
    1add:	mov    rcx,QWORD PTR [rdx+0xe0]
    1ae4:	mov    edx,0x1
    1ae9:	call   1aee <botlish_fn_18+0x66>
			1aea: R_X86_64_PLT32	rt_type_error-0x4
    1aee:	jmp    1c88 <botlish_fn_18+0x200>
    1af3:	mov    r13,rsi
    1af6:	mov    r14,rdi
    1af9:	call   1afe <botlish_fn_18+0x76>
			1afa: R_X86_64_PLT32	rt_str_len-0x4
    1afe:	mov    rbx,rax
    1b01:	mov    QWORD PTR [rsp+0x8],rax
    1b06:	mov    edx,0x1
    1b0b:	mov    r15,rdx
    1b0e:	mov    QWORD PTR [rsp+0x10],0x1
    1b17:	mov    rcx,r13
    1b1a:	mov    rdx,rbx
    1b1d:	mov    rsi,r15
    1b20:	mov    rdi,r14
    1b23:	call   1b28 <botlish_fn_18+0xa0>
			1b24: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    1b28:	mov    r12,rax
    1b2b:	test   r12,r12
    1b2e:	je     1c88 <botlish_fn_18+0x200>
    1b34:	mov    QWORD PTR [rsp+0x10],r12
    1b39:	test   r12,0x1
    1b40:	jne    1b69 <botlish_fn_18+0xe1>
    1b46:	mov    rdx,r15
    1b49:	mov    rsi,r12
    1b4c:	mov    rdi,r14
    1b4f:	call   1b54 <botlish_fn_18+0xcc>
			1b50: R_X86_64_PLT32	rt_int_cmp-0x4
    1b54:	mov    ecx,0x2
    1b59:	test   rax,rax
    1b5c:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 1d30 <botlish_fn_18+0x2a8>
    1b64:	jmp    1b7a <botlish_fn_18+0xf2>
    1b69:	mov    ecx,0x2
    1b6e:	cmp    r12,0x1
    1b72:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 1d30 <botlish_fn_18+0x2a8>
    1b7a:	cmp    rcx,0x6
    1b7e:	je     1d08 <botlish_fn_18+0x280>
    1b84:	mov    rax,r12
    1b87:	and    rax,rbx
    1b8a:	test   rax,0x1
    1b90:	jne    1bb9 <botlish_fn_18+0x131>
    1b96:	mov    rdx,rbx
    1b99:	mov    rsi,r12
    1b9c:	mov    rdi,r14
    1b9f:	call   1ba4 <botlish_fn_18+0x11c>
			1ba0: R_X86_64_PLT32	rt_int_cmp-0x4
    1ba4:	mov    ecx,0x2
    1ba9:	test   rax,rax
    1bac:	cmovge rcx,QWORD PTR [rip+0x17c]        # 1d30 <botlish_fn_18+0x2a8>
    1bb4:	jmp    1bc9 <botlish_fn_18+0x141>
    1bb9:	mov    ecx,0x2
    1bbe:	cmp    r12,rbx
    1bc1:	cmovge rcx,QWORD PTR [rip+0x167]        # 1d30 <botlish_fn_18+0x2a8>
    1bc9:	cmp    rcx,0x6
    1bcd:	je     1cfe <botlish_fn_18+0x276>
    1bd3:	lea    rcx,[rsp+0x20]
    1bd8:	mov    rdx,r13
    1bdb:	mov    rsi,r12
    1bde:	mov    rdi,r14
    1be1:	call   1be6 <botlish_fn_18+0x15e>
			1be2: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    1be6:	test   rax,rax
    1be9:	mov    rsi,rax
    1bec:	je     1c88 <botlish_fn_18+0x200>
    1bf2:	mov    rdx,QWORD PTR [rsp+0x20]
    1bf7:	mov    rcx,QWORD PTR [rsp+0x28]
    1bfc:	mov    rdi,r14
    1bff:	mov    rax,QWORD PTR [rdi+0x10]
    1c03:	mov    r8,QWORD PTR [rax+0xf8]
    1c0a:	call   1c0f <botlish_fn_18+0x187>
			1c0b: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c0f:	cmp    rax,0x6
    1c13:	je     1c26 <botlish_fn_18+0x19e>
    1c19:	mov    ecx,0x2
    1c1e:	mov    rax,rcx
    1c21:	jmp    1d0d <botlish_fn_18+0x285>
    1c26:	mov    QWORD PTR [rsp+0x18],0x3
    1c2f:	test   r12,0x1
    1c36:	jne    1c44 <botlish_fn_18+0x1bc>
    1c3c:	mov    rdi,r12
    1c3f:	jmp    1c59 <botlish_fn_18+0x1d1>
    1c44:	mov    rsi,r12
    1c47:	add    rsi,0x2
    1c4b:	mov    rdi,r12
    1c4e:	seto   al
    1c51:	test   al,al
    1c53:	je     1c6c <botlish_fn_18+0x1e4>
    1c59:	mov    edx,0x3
    1c5e:	mov    rsi,rdi
    1c61:	mov    rdi,r14
    1c64:	call   1c69 <botlish_fn_18+0x1e1>
			1c65: R_X86_64_PLT32	rt_int_add-0x4
    1c69:	mov    rsi,rax
    1c6c:	mov    QWORD PTR [rsp+0x10],rsi
    1c71:	mov    rcx,r13
    1c74:	mov    rdx,rbx
    1c77:	mov    rdi,r14
    1c7a:	call   1c7f <botlish_fn_18+0x1f7>
			1c7b: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    1c7f:	test   rax,rax
    1c82:	jne    1cad <botlish_fn_18+0x225>
    1c88:	xor    rax,rax
    1c8b:	mov    rbx,QWORD PTR [rsp+0x30]
    1c90:	mov    r12,QWORD PTR [rsp+0x38]
    1c95:	mov    r13,QWORD PTR [rsp+0x40]
    1c9a:	mov    r14,QWORD PTR [rsp+0x48]
    1c9f:	mov    r15,QWORD PTR [rsp+0x50]
    1ca4:	add    rsp,0x60
    1ca8:	mov    rsp,rbp
    1cab:	pop    rbp
    1cac:	ret
    1cad:	mov    rcx,rax
    1cb0:	and    rcx,rbx
    1cb3:	mov    rsi,rax
    1cb6:	test   rcx,0x1
    1cbd:	jne    1ce6 <botlish_fn_18+0x25e>
    1cc3:	mov    rdx,rbx
    1cc6:	mov    rdi,r14
    1cc9:	call   1cce <botlish_fn_18+0x246>
			1cca: R_X86_64_PLT32	rt_int_cmp-0x4
    1cce:	mov    ecx,0x2
    1cd3:	test   rax,rax
    1cd6:	mov    rax,rcx
    1cd9:	cmove  rax,QWORD PTR [rip+0x4f]        # 1d30 <botlish_fn_18+0x2a8>
    1ce1:	jmp    1d0d <botlish_fn_18+0x285>
    1ce6:	mov    rdx,rbx
    1ce9:	mov    eax,0x2
    1cee:	cmp    rsi,rdx
    1cf1:	cmove  rax,QWORD PTR [rip+0x37]        # 1d30 <botlish_fn_18+0x2a8>
    1cf9:	jmp    1d0d <botlish_fn_18+0x285>
    1cfe:	mov    eax,0x2
    1d03:	jmp    1d0d <botlish_fn_18+0x285>
    1d08:	mov    eax,0x2
    1d0d:	mov    rbx,QWORD PTR [rsp+0x30]
    1d12:	mov    r12,QWORD PTR [rsp+0x38]
    1d17:	mov    r13,QWORD PTR [rsp+0x40]
    1d1c:	mov    r14,QWORD PTR [rsp+0x48]
    1d21:	mov    r15,QWORD PTR [rsp+0x50]
    1d26:	add    rsp,0x60
    1d2a:	mov    rsp,rbp
    1d2d:	pop    rbp
    1d2e:	ret
    1d2f:	add    BYTE PTR [rsi],al
    1d31:	add    BYTE PTR [rax],al
    1d33:	add    BYTE PTR [rax],al
    1d35:	add    BYTE PTR [rax],al
	...

0000000000001d38 <botlish_entry_18: <generic>>:
    1d38:	push   rbp
    1d39:	mov    rbp,rsp
    1d3c:	mov    rsi,QWORD PTR [rdx]
    1d3f:	call   1d44 <botlish_entry_18+0xc>
			1d40: R_X86_64_PLT32	botlish_fn_18-0x4 ; <generic>
    1d44:	mov    rsp,rbp
    1d47:	pop    rbp
    1d48:	ret

0000000000001d49 <botlish_fn_19: char_at<generic>>:
    1d49:	push   rbp
    1d4a:	mov    rbp,rsp
    1d4d:	sub    rsp,0x50
    1d51:	mov    QWORD PTR [rsp+0x20],rbx
    1d56:	mov    QWORD PTR [rsp+0x28],r12
    1d5b:	mov    QWORD PTR [rsp+0x30],r13
    1d60:	mov    QWORD PTR [rsp+0x38],r14
    1d65:	mov    QWORD PTR [rsp+0x40],r15
    1d6a:	mov    r14,rcx
    1d6d:	mov    QWORD PTR [rsp],rsi
    1d71:	mov    QWORD PTR [rsp+0x8],rdx
    1d76:	mov    r13,rdx
    1d79:	mov    QWORD PTR [rsp+0x10],0x3
    1d82:	mov    r9d,0x1
    1d88:	test   rsi,0x1
    1d8f:	jne    1daf <botlish_fn_19+0x66>
    1d95:	xor    r9d,r9d
    1d98:	test   rsi,0x7
    1d9f:	jne    1daf <botlish_fn_19+0x66>
    1da5:	movzx  rax,BYTE PTR [rsi]
    1da9:	cmp    al,0x1
    1dab:	sete   r9b
    1daf:	test   r9b,r9b
    1db2:	jne    1dd0 <botlish_fn_19+0x87>
    1db8:	mov    rax,QWORD PTR [rdi+0x10]
    1dbc:	mov    rcx,QWORD PTR [rax+0x100]
    1dc3:	xor    rdx,rdx
    1dc6:	call   1dcb <botlish_fn_19+0x82>
			1dc7: R_X86_64_PLT32	rt_type_error-0x4
    1dcb:	jmp    1e8d <botlish_fn_19+0x144>
    1dd0:	mov    r12,rdi
    1dd3:	test   rsi,0x1
    1dda:	jne    1de8 <botlish_fn_19+0x9f>
    1de0:	mov    rbx,rsi
    1de3:	jmp    1e05 <botlish_fn_19+0xbc>
    1de8:	mov    rax,rsi
    1deb:	add    rax,0x2
    1def:	mov    rbx,rsi
    1df2:	seto   cl
    1df5:	test   cl,cl
    1df7:	jne    1e05 <botlish_fn_19+0xbc>
    1dfd:	mov    r15,rax
    1e00:	jmp    1e18 <botlish_fn_19+0xcf>
    1e05:	mov    edx,0x3
    1e0a:	mov    rsi,rbx
    1e0d:	mov    rdi,r12
    1e10:	call   1e15 <botlish_fn_19+0xcc>
			1e11: R_X86_64_PLT32	rt_int_add-0x4
    1e15:	mov    r15,rax
    1e18:	mov    ecx,0x1
    1e1d:	mov    rsi,rbx
    1e20:	test   rsi,0x1
    1e27:	jne    1e4d <botlish_fn_19+0x104>
    1e2d:	xor    ecx,ecx
    1e2f:	mov    rsi,rbx
    1e32:	test   rsi,0x7
    1e39:	jne    1e4d <botlish_fn_19+0x104>
    1e3f:	mov    rsi,rbx
    1e42:	movzx  rcx,BYTE PTR [rsi]
    1e46:	rex cmp cl,0x1
    1e4a:	sete   cl
    1e4d:	test   cl,cl
    1e4f:	jne    1e73 <botlish_fn_19+0x12a>
    1e55:	mov    rdi,r12
    1e58:	mov    rsi,QWORD PTR [rdi+0x10]
    1e5c:	mov    rcx,QWORD PTR [rsi+0x108]
    1e63:	xor    rdx,rdx
    1e66:	mov    rsi,rbx
    1e69:	call   1e6e <botlish_fn_19+0x125>
			1e6a: R_X86_64_PLT32	rt_type_error-0x4
    1e6e:	jmp    1e8d <botlish_fn_19+0x144>
    1e73:	mov    rdi,r12
    1e76:	mov    rcx,r15
    1e79:	mov    rdx,rbx
    1e7c:	mov    rsi,r13
    1e7f:	call   1e84 <botlish_fn_19+0x13b>
			1e80: R_X86_64_PLT32	rt_str_region_check-0x4
    1e84:	test   rax,rax
    1e87:	jne    1eb2 <botlish_fn_19+0x169>
    1e8d:	xor    rax,rax
    1e90:	mov    rbx,QWORD PTR [rsp+0x20]
    1e95:	mov    r12,QWORD PTR [rsp+0x28]
    1e9a:	mov    r13,QWORD PTR [rsp+0x30]
    1e9f:	mov    r14,QWORD PTR [rsp+0x38]
    1ea4:	mov    r15,QWORD PTR [rsp+0x40]
    1ea9:	add    rsp,0x50
    1ead:	mov    rsp,rbp
    1eb0:	pop    rbp
    1eb1:	ret
    1eb2:	mov    rcx,r14
    1eb5:	mov    rsi,rbx
    1eb8:	mov    QWORD PTR [rcx],rsi
    1ebb:	mov    rax,r15
    1ebe:	mov    QWORD PTR [rcx+0x8],rax
    1ec2:	mov    rax,r13
    1ec5:	mov    rbx,QWORD PTR [rsp+0x20]
    1eca:	mov    r12,QWORD PTR [rsp+0x28]
    1ecf:	mov    r13,QWORD PTR [rsp+0x30]
    1ed4:	mov    r14,QWORD PTR [rsp+0x38]
    1ed9:	mov    r15,QWORD PTR [rsp+0x40]
    1ede:	add    rsp,0x50
    1ee2:	mov    rsp,rbp
    1ee5:	pop    rbp
    1ee6:	ret

0000000000001ee7 <botlish_entry_19: char_at<generic>>:
    1ee7:	push   rbp
    1ee8:	mov    rbp,rsp
    1eeb:	ud2
    1eed:	add    BYTE PTR [rax],al
	...

0000000000001ef0 <botlish_fn_20: scan_local<generic>>:
    1ef0:	push   rbp
    1ef1:	mov    rbp,rsp
    1ef4:	sub    rsp,0x80
    1efb:	mov    QWORD PTR [rsp+0x50],rbx
    1f00:	mov    QWORD PTR [rsp+0x58],r12
    1f05:	mov    QWORD PTR [rsp+0x60],r13
    1f0a:	mov    QWORD PTR [rsp+0x68],r14
    1f0f:	mov    QWORD PTR [rsp+0x70],r15
    1f14:	mov    rax,rdi
    1f17:	mov    QWORD PTR [rsp+0x18],0x0
    1f20:	mov    QWORD PTR [rsp],rsi
    1f24:	mov    r14,rsi
    1f27:	mov    QWORD PTR [rsp+0x8],rdx
    1f2c:	mov    QWORD PTR [rsp+0x10],rcx
    1f31:	mov    r12,rcx
    1f34:	mov    r11d,0x1
    1f3a:	mov    rsi,r14
    1f3d:	test   rsi,0x1
    1f44:	jne    1f66 <botlish_fn_20+0x76>
    1f4a:	xor    r11d,r11d
    1f4d:	test   rsi,0x7
    1f54:	jne    1f66 <botlish_fn_20+0x76>
    1f5a:	movzx  rdi,BYTE PTR [rsi]
    1f5e:	cmp    dil,0x1
    1f62:	sete   r11b
    1f66:	test   r11b,r11b
    1f69:	jne    1f8a <botlish_fn_20+0x9a>
    1f6f:	mov    rdi,rax
    1f72:	mov    r9,QWORD PTR [rdi+0x10]
    1f76:	mov    rcx,QWORD PTR [r9+0xc0]
    1f7d:	xor    rdx,rdx
    1f80:	call   1f85 <botlish_fn_20+0x95>
			1f81: R_X86_64_PLT32	rt_type_error-0x4
    1f85:	jmp    203d <botlish_fn_20+0x14d>
    1f8a:	mov    r13,rdx
    1f8d:	mov    r10,rsi
    1f90:	and    r10,r13
    1f93:	mov    r14,rsi
    1f96:	test   r10,0x1
    1f9d:	jne    1fc9 <botlish_fn_20+0xd9>
    1fa3:	mov    rbx,rax
    1fa6:	mov    rdx,r13
    1fa9:	mov    rsi,r14
    1fac:	mov    rdi,rbx
    1faf:	call   1fb4 <botlish_fn_20+0xc4>
			1fb0: R_X86_64_PLT32	rt_int_cmp-0x4
    1fb4:	mov    ecx,0x2
    1fb9:	test   rax,rax
    1fbc:	cmovge rcx,QWORD PTR [rip+0x24c]        # 2210 <botlish_fn_20+0x320>
    1fc4:	jmp    1fdf <botlish_fn_20+0xef>
    1fc9:	mov    rbx,rax
    1fcc:	mov    ecx,0x2
    1fd1:	mov    rsi,r14
    1fd4:	cmp    rsi,r13
    1fd7:	cmovge rcx,QWORD PTR [rip+0x231]        # 2210 <botlish_fn_20+0x320>
    1fdf:	mov    eax,0x6
    1fe4:	mov    QWORD PTR [rsp+0x30],rax
    1fe9:	cmp    rcx,0x6
    1fed:	je     21e3 <botlish_fn_20+0x2f3>
    1ff3:	lea    rcx,[rsp+0x20]
    1ff8:	mov    rdx,r12
    1ffb:	mov    rsi,r14
    1ffe:	mov    rdi,rbx
    2001:	call   2006 <botlish_fn_20+0x116>
			2002: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    2006:	mov    rsi,rax
    2009:	mov    r15,rax
    200c:	test   rax,rsi
    200f:	je     203d <botlish_fn_20+0x14d>
    2015:	mov    rdx,QWORD PTR [rsp+0x20]
    201a:	mov    QWORD PTR [rsp+0x40],rdx
    201f:	mov    rcx,QWORD PTR [rsp+0x28]
    2024:	mov    QWORD PTR [rsp+0x38],rcx
    2029:	mov    rsi,r15
    202c:	mov    rdi,rbx
    202f:	call   2034 <botlish_fn_20+0x144>
			2030: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    2034:	test   rax,rax
    2037:	jne    2065 <botlish_fn_20+0x175>
    203d:	xor    rax,rax
    2040:	mov    rbx,QWORD PTR [rsp+0x50]
    2045:	mov    r12,QWORD PTR [rsp+0x58]
    204a:	mov    r13,QWORD PTR [rsp+0x60]
    204f:	mov    r14,QWORD PTR [rsp+0x68]
    2054:	mov    r15,QWORD PTR [rsp+0x70]
    2059:	add    rsp,0x80
    2060:	mov    rsp,rbp
    2063:	pop    rbp
    2064:	ret
    2065:	cmp    rax,0x6
    2069:	je     2164 <botlish_fn_20+0x274>
    206f:	mov    rax,QWORD PTR [rbx+0x10]
    2073:	mov    r8,QWORD PTR [rax+0x110]
    207a:	mov    rcx,QWORD PTR [rsp+0x38]
    207f:	mov    rdx,QWORD PTR [rsp+0x40]
    2084:	mov    rsi,r15
    2087:	mov    rdi,rbx
    208a:	call   208f <botlish_fn_20+0x19f>
			208b: R_X86_64_PLT32	rt_str_region_eq-0x4
    208f:	cmp    rax,0x6
    2093:	je     215a <botlish_fn_20+0x26a>
    2099:	mov    rax,QWORD PTR [rbx+0x10]
    209d:	mov    r8,QWORD PTR [rax+0x118]
    20a4:	mov    rcx,QWORD PTR [rsp+0x38]
    20a9:	mov    rdx,QWORD PTR [rsp+0x40]
    20ae:	mov    rsi,r15
    20b1:	mov    rdi,rbx
    20b4:	call   20b9 <botlish_fn_20+0x1c9>
			20b5: R_X86_64_PLT32	rt_str_region_eq-0x4
    20b9:	cmp    rax,0x6
    20bd:	je     2150 <botlish_fn_20+0x260>
    20c3:	mov    rax,QWORD PTR [rbx+0x10]
    20c7:	mov    r8,QWORD PTR [rax+0xc8]
    20ce:	mov    rcx,QWORD PTR [rsp+0x38]
    20d3:	mov    rdx,QWORD PTR [rsp+0x40]
    20d8:	mov    rsi,r15
    20db:	mov    rdi,rbx
    20de:	call   20e3 <botlish_fn_20+0x1f3>
			20df: R_X86_64_PLT32	rt_str_region_eq-0x4
    20e3:	cmp    rax,0x6
    20e7:	je     2146 <botlish_fn_20+0x256>
    20ed:	mov    rax,QWORD PTR [rbx+0x10]
    20f1:	mov    r8,QWORD PTR [rax+0x100]
    20f8:	mov    rcx,QWORD PTR [rsp+0x38]
    20fd:	mov    rdx,QWORD PTR [rsp+0x40]
    2102:	mov    rsi,r15
    2105:	mov    rdi,rbx
    2108:	call   210d <botlish_fn_20+0x21d>
			2109: R_X86_64_PLT32	rt_str_region_eq-0x4
    210d:	cmp    rax,0x6
    2111:	je     213c <botlish_fn_20+0x24c>
    2117:	mov    rax,QWORD PTR [rbx+0x10]
    211b:	mov    r8,QWORD PTR [rax+0x120]
    2122:	mov    rcx,QWORD PTR [rsp+0x38]
    2127:	mov    rdx,QWORD PTR [rsp+0x40]
    212c:	mov    rsi,r15
    212f:	mov    rdi,rbx
    2132:	call   2137 <botlish_fn_20+0x247>
			2133: R_X86_64_PLT32	rt_str_region_eq-0x4
    2137:	jmp    2169 <botlish_fn_20+0x279>
    213c:	mov    rax,QWORD PTR [rsp+0x30]
    2141:	jmp    2169 <botlish_fn_20+0x279>
    2146:	mov    rax,QWORD PTR [rsp+0x30]
    214b:	jmp    2169 <botlish_fn_20+0x279>
    2150:	mov    rax,QWORD PTR [rsp+0x30]
    2155:	jmp    2169 <botlish_fn_20+0x279>
    215a:	mov    rax,QWORD PTR [rsp+0x30]
    215f:	jmp    2169 <botlish_fn_20+0x279>
    2164:	mov    rax,QWORD PTR [rsp+0x30]
    2169:	cmp    rax,0x6
    216d:	je     217b <botlish_fn_20+0x28b>
    2173:	mov    rax,r14
    2176:	jmp    21e6 <botlish_fn_20+0x2f6>
    217b:	mov    QWORD PTR [rsp+0x18],0x3
    2184:	mov    rsi,r14
    2187:	test   rsi,0x1
    218e:	je     21b4 <botlish_fn_20+0x2c4>
    2194:	mov    rsi,r14
    2197:	mov    rax,rsi
    219a:	add    rax,0x2
    219e:	seto   cl
    21a1:	test   cl,cl
    21a3:	jne    21b4 <botlish_fn_20+0x2c4>
    21a9:	mov    rsi,rax
    21ac:	mov    r14,rax
    21af:	jmp    21ca <botlish_fn_20+0x2da>
    21b4:	mov    edx,0x3
    21b9:	mov    rsi,r14
    21bc:	mov    rdi,rbx
    21bf:	call   21c4 <botlish_fn_20+0x2d4>
			21c0: R_X86_64_PLT32	rt_int_add-0x4
    21c4:	mov    rsi,rax
    21c7:	mov    r14,rax
    21ca:	mov    QWORD PTR [rsp],rsi
    21ce:	mov    QWORD PTR [rsp+0x8],r13
    21d3:	mov    QWORD PTR [rsp+0x10],r12
    21d8:	mov    rax,rbx
    21db:	mov    rdx,r13
    21de:	jmp    1f34 <botlish_fn_20+0x44>
    21e3:	mov    rax,r14
    21e6:	mov    rbx,QWORD PTR [rsp+0x50]
    21eb:	mov    r12,QWORD PTR [rsp+0x58]
    21f0:	mov    r13,QWORD PTR [rsp+0x60]
    21f5:	mov    r14,QWORD PTR [rsp+0x68]
    21fa:	mov    r15,QWORD PTR [rsp+0x70]
    21ff:	add    rsp,0x80
    2206:	mov    rsp,rbp
    2209:	pop    rbp
    220a:	ret
    220b:	add    BYTE PTR [rax],al
    220d:	add    BYTE PTR [rax],al
    220f:	add    BYTE PTR [rsi],al
    2211:	add    BYTE PTR [rax],al
    2213:	add    BYTE PTR [rax],al
    2215:	add    BYTE PTR [rax],al
	...

0000000000002218 <botlish_entry_20: scan_local<generic>>:
    2218:	push   rbp
    2219:	mov    rbp,rsp
    221c:	mov    rsi,QWORD PTR [rdx]
    221f:	mov    r8,QWORD PTR [rdx+0x8]
    2223:	mov    rcx,QWORD PTR [rdx+0x10]
    2227:	mov    rdx,r8
    222a:	call   222f <botlish_entry_20+0x17>
			222b: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    222f:	mov    rsp,rbp
    2232:	pop    rbp
    2233:	ret
    2234:	add    BYTE PTR [rax],al
	...

0000000000002238 <botlish_fn_21: scan_label<generic>>:
    2238:	push   rbp
    2239:	mov    rbp,rsp
    223c:	sub    rsp,0x80
    2243:	mov    QWORD PTR [rsp+0x50],rbx
    2248:	mov    QWORD PTR [rsp+0x58],r12
    224d:	mov    QWORD PTR [rsp+0x60],r13
    2252:	mov    QWORD PTR [rsp+0x68],r14
    2257:	mov    QWORD PTR [rsp+0x70],r15
    225c:	mov    QWORD PTR [rsp+0x18],0x0
    2265:	mov    QWORD PTR [rsp],rsi
    2269:	mov    r14,rsi
    226c:	mov    QWORD PTR [rsp+0x8],rdx
    2271:	mov    QWORD PTR [rsp+0x10],rcx
    2276:	mov    r12,rcx
    2279:	mov    r11d,0x1
    227f:	mov    rsi,r14
    2282:	test   rsi,0x1
    2289:	jne    22a9 <botlish_fn_21+0x71>
    228f:	xor    r11d,r11d
    2292:	test   rsi,0x7
    2299:	jne    22a9 <botlish_fn_21+0x71>
    229f:	movzx  rax,BYTE PTR [rsi]
    22a3:	cmp    al,0x1
    22a5:	sete   r11b
    22a9:	test   r11b,r11b
    22ac:	jne    22ca <botlish_fn_21+0x92>
    22b2:	mov    rax,QWORD PTR [rdi+0x10]
    22b6:	mov    rcx,QWORD PTR [rax+0xc0]
    22bd:	xor    rdx,rdx
    22c0:	call   22c5 <botlish_fn_21+0x8d>
			22c1: R_X86_64_PLT32	rt_type_error-0x4
    22c5:	jmp    2376 <botlish_fn_21+0x13e>
    22ca:	mov    r13,rdx
    22cd:	mov    rax,rsi
    22d0:	and    rax,r13
    22d3:	mov    r14,rsi
    22d6:	test   rax,0x1
    22dc:	jne    2305 <botlish_fn_21+0xcd>
    22e2:	mov    rbx,rdi
    22e5:	mov    rdx,r13
    22e8:	mov    rsi,r14
    22eb:	call   22f0 <botlish_fn_21+0xb8>
			22ec: R_X86_64_PLT32	rt_int_cmp-0x4
    22f0:	mov    ecx,0x2
    22f5:	test   rax,rax
    22f8:	cmovge rcx,QWORD PTR [rip+0x178]        # 2478 <botlish_fn_21+0x240>
    2300:	jmp    231b <botlish_fn_21+0xe3>
    2305:	mov    rbx,rdi
    2308:	mov    ecx,0x2
    230d:	mov    rsi,r14
    2310:	cmp    rsi,r13
    2313:	cmovge rcx,QWORD PTR [rip+0x15d]        # 2478 <botlish_fn_21+0x240>
    231b:	mov    eax,0x6
    2320:	mov    QWORD PTR [rsp+0x30],rax
    2325:	cmp    rcx,0x6
    2329:	je     244c <botlish_fn_21+0x214>
    232f:	lea    rcx,[rsp+0x20]
    2334:	mov    rdx,r12
    2337:	mov    rsi,r14
    233a:	mov    rdi,rbx
    233d:	call   2342 <botlish_fn_21+0x10a>
			233e: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    2342:	test   rax,rax
    2345:	mov    r15,rax
    2348:	je     2376 <botlish_fn_21+0x13e>
    234e:	mov    rdx,QWORD PTR [rsp+0x20]
    2353:	mov    QWORD PTR [rsp+0x40],rdx
    2358:	mov    rcx,QWORD PTR [rsp+0x28]
    235d:	mov    QWORD PTR [rsp+0x38],rcx
    2362:	mov    rsi,r15
    2365:	mov    rdi,rbx
    2368:	call   236d <botlish_fn_21+0x135>
			2369: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    236d:	test   rax,rax
    2370:	jne    239e <botlish_fn_21+0x166>
    2376:	xor    rax,rax
    2379:	mov    rbx,QWORD PTR [rsp+0x50]
    237e:	mov    r12,QWORD PTR [rsp+0x58]
    2383:	mov    r13,QWORD PTR [rsp+0x60]
    2388:	mov    r14,QWORD PTR [rsp+0x68]
    238d:	mov    r15,QWORD PTR [rsp+0x70]
    2392:	add    rsp,0x80
    2399:	mov    rsp,rbp
    239c:	pop    rbp
    239d:	ret
    239e:	cmp    rax,0x6
    23a2:	je     23cd <botlish_fn_21+0x195>
    23a8:	mov    r11,QWORD PTR [rbx+0x10]
    23ac:	mov    r8,QWORD PTR [r11+0x120]
    23b3:	mov    rcx,QWORD PTR [rsp+0x38]
    23b8:	mov    rdx,QWORD PTR [rsp+0x40]
    23bd:	mov    rsi,r15
    23c0:	mov    rdi,rbx
    23c3:	call   23c8 <botlish_fn_21+0x190>
			23c4: R_X86_64_PLT32	rt_str_region_eq-0x4
    23c8:	jmp    23d2 <botlish_fn_21+0x19a>
    23cd:	mov    rax,QWORD PTR [rsp+0x30]
    23d2:	cmp    rax,0x6
    23d6:	je     23e4 <botlish_fn_21+0x1ac>
    23dc:	mov    rax,r14
    23df:	jmp    244f <botlish_fn_21+0x217>
    23e4:	mov    QWORD PTR [rsp+0x18],0x3
    23ed:	mov    rsi,r14
    23f0:	test   rsi,0x1
    23f7:	je     241d <botlish_fn_21+0x1e5>
    23fd:	mov    rsi,r14
    2400:	mov    rax,rsi
    2403:	add    rax,0x2
    2407:	seto   cl
    240a:	test   cl,cl
    240c:	jne    241d <botlish_fn_21+0x1e5>
    2412:	mov    rsi,rax
    2415:	mov    r14,rax
    2418:	jmp    2433 <botlish_fn_21+0x1fb>
    241d:	mov    edx,0x3
    2422:	mov    rsi,r14
    2425:	mov    rdi,rbx
    2428:	call   242d <botlish_fn_21+0x1f5>
			2429: R_X86_64_PLT32	rt_int_add-0x4
    242d:	mov    rsi,rax
    2430:	mov    r14,rax
    2433:	mov    QWORD PTR [rsp],rsi
    2437:	mov    QWORD PTR [rsp+0x8],r13
    243c:	mov    QWORD PTR [rsp+0x10],r12
    2441:	mov    rdx,r13
    2444:	mov    rdi,rbx
    2447:	jmp    2279 <botlish_fn_21+0x41>
    244c:	mov    rax,r14
    244f:	mov    rbx,QWORD PTR [rsp+0x50]
    2454:	mov    r12,QWORD PTR [rsp+0x58]
    2459:	mov    r13,QWORD PTR [rsp+0x60]
    245e:	mov    r14,QWORD PTR [rsp+0x68]
    2463:	mov    r15,QWORD PTR [rsp+0x70]
    2468:	add    rsp,0x80
    246f:	mov    rsp,rbp
    2472:	pop    rbp
    2473:	ret
    2474:	add    BYTE PTR [rax],al
    2476:	add    BYTE PTR [rax],al
    2478:	(bad)
    2479:	add    BYTE PTR [rax],al
    247b:	add    BYTE PTR [rax],al
    247d:	add    BYTE PTR [rax],al
	...

0000000000002480 <botlish_entry_21: scan_label<generic>>:
    2480:	push   rbp
    2481:	mov    rbp,rsp
    2484:	mov    rsi,QWORD PTR [rdx]
    2487:	mov    r8,QWORD PTR [rdx+0x8]
    248b:	mov    rcx,QWORD PTR [rdx+0x10]
    248f:	mov    rdx,r8
    2492:	call   2497 <botlish_entry_21+0x17>
			2493: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    2497:	mov    rsp,rbp
    249a:	pop    rbp
    249b:	ret
    249c:	add    BYTE PTR [rax],al
	...

00000000000024a0 <botlish_fn_22: scan_alpha<generic>>:
    24a0:	push   rbp
    24a1:	mov    rbp,rsp
    24a4:	sub    rsp,0x50
    24a8:	mov    QWORD PTR [rsp+0x30],rbx
    24ad:	mov    QWORD PTR [rsp+0x38],r12
    24b2:	mov    QWORD PTR [rsp+0x40],r13
    24b7:	mov    QWORD PTR [rsp+0x48],r14
    24bc:	mov    r14,rdi
    24bf:	mov    QWORD PTR [rsp+0x18],0x0
    24c8:	mov    QWORD PTR [rsp],rsi
    24cc:	mov    r13,rsi
    24cf:	mov    QWORD PTR [rsp+0x8],rdx
    24d4:	mov    r12,rdx
    24d7:	mov    QWORD PTR [rsp+0x10],rcx
    24dc:	mov    rbx,rcx
    24df:	mov    r11d,0x1
    24e5:	mov    rsi,r13
    24e8:	test   rsi,0x1
    24ef:	jne    250f <botlish_fn_22+0x6f>
    24f5:	xor    r11d,r11d
    24f8:	test   rsi,0x7
    24ff:	jne    250f <botlish_fn_22+0x6f>
    2505:	movzx  rax,BYTE PTR [rsi]
    2509:	cmp    al,0x1
    250b:	sete   r11b
    250f:	test   r11b,r11b
    2512:	jne    2533 <botlish_fn_22+0x93>
    2518:	mov    rdi,r14
    251b:	mov    rax,QWORD PTR [rdi+0x10]
    251f:	mov    rcx,QWORD PTR [rax+0xc0]
    2526:	xor    rdx,rdx
    2529:	call   252e <botlish_fn_22+0x8e>
			252a: R_X86_64_PLT32	rt_type_error-0x4
    252e:	jmp    25c2 <botlish_fn_22+0x122>
    2533:	mov    rax,rsi
    2536:	and    rax,r12
    2539:	mov    r13,rsi
    253c:	test   rax,0x1
    2542:	jne    256b <botlish_fn_22+0xcb>
    2548:	mov    rdx,r12
    254b:	mov    rsi,r13
    254e:	mov    rdi,r14
    2551:	call   2556 <botlish_fn_22+0xb6>
			2552: R_X86_64_PLT32	rt_int_cmp-0x4
    2556:	mov    ecx,0x2
    255b:	test   rax,rax
    255e:	cmovge rcx,QWORD PTR [rip+0x112]        # 2678 <botlish_fn_22+0x1d8>
    2566:	jmp    257e <botlish_fn_22+0xde>
    256b:	mov    ecx,0x2
    2570:	mov    rsi,r13
    2573:	cmp    rsi,r12
    2576:	cmovge rcx,QWORD PTR [rip+0xfa]        # 2678 <botlish_fn_22+0x1d8>
    257e:	cmp    rcx,0x6
    2582:	je     2656 <botlish_fn_22+0x1b6>
    2588:	lea    rcx,[rsp+0x20]
    258d:	mov    rdx,rbx
    2590:	mov    rsi,r13
    2593:	mov    rdi,r14
    2596:	call   259b <botlish_fn_22+0xfb>
			2597: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    259b:	test   rax,rax
    259e:	mov    rsi,rax
    25a1:	je     25c2 <botlish_fn_22+0x122>
    25a7:	mov    rdx,QWORD PTR [rsp+0x20]
    25ac:	mov    rcx,QWORD PTR [rsp+0x28]
    25b1:	mov    rdi,r14
    25b4:	call   25b9 <botlish_fn_22+0x119>
			25b5: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    25b9:	test   rax,rax
    25bc:	jne    25e2 <botlish_fn_22+0x142>
    25c2:	xor    rax,rax
    25c5:	mov    rbx,QWORD PTR [rsp+0x30]
    25ca:	mov    r12,QWORD PTR [rsp+0x38]
    25cf:	mov    r13,QWORD PTR [rsp+0x40]
    25d4:	mov    r14,QWORD PTR [rsp+0x48]
    25d9:	add    rsp,0x50
    25dd:	mov    rsp,rbp
    25e0:	pop    rbp
    25e1:	ret
    25e2:	cmp    rax,0x6
    25e6:	je     25f4 <botlish_fn_22+0x154>
    25ec:	mov    rax,r13
    25ef:	jmp    2659 <botlish_fn_22+0x1b9>
    25f4:	mov    QWORD PTR [rsp+0x18],0x3
    25fd:	mov    rsi,r13
    2600:	test   rsi,0x1
    2607:	je     262d <botlish_fn_22+0x18d>
    260d:	mov    rsi,r13
    2610:	mov    r11,rsi
    2613:	add    r11,0x2
    2617:	seto   al
    261a:	test   al,al
    261c:	jne    262d <botlish_fn_22+0x18d>
    2622:	mov    rsi,r11
    2625:	mov    r13,r11
    2628:	jmp    2643 <botlish_fn_22+0x1a3>
    262d:	mov    edx,0x3
    2632:	mov    rsi,r13
    2635:	mov    rdi,r14
    2638:	call   263d <botlish_fn_22+0x19d>
			2639: R_X86_64_PLT32	rt_int_add-0x4
    263d:	mov    rsi,rax
    2640:	mov    r13,rax
    2643:	mov    QWORD PTR [rsp],rsi
    2647:	mov    QWORD PTR [rsp+0x8],r12
    264c:	mov    QWORD PTR [rsp+0x10],rbx
    2651:	jmp    24df <botlish_fn_22+0x3f>
    2656:	mov    rax,r13
    2659:	mov    rbx,QWORD PTR [rsp+0x30]
    265e:	mov    r12,QWORD PTR [rsp+0x38]
    2663:	mov    r13,QWORD PTR [rsp+0x40]
    2668:	mov    r14,QWORD PTR [rsp+0x48]
    266d:	add    rsp,0x50
    2671:	mov    rsp,rbp
    2674:	pop    rbp
    2675:	ret
    2676:	add    BYTE PTR [rax],al
    2678:	(bad)
    2679:	add    BYTE PTR [rax],al
    267b:	add    BYTE PTR [rax],al
    267d:	add    BYTE PTR [rax],al
	...

0000000000002680 <botlish_entry_22: scan_alpha<generic>>:
    2680:	push   rbp
    2681:	mov    rbp,rsp
    2684:	mov    rsi,QWORD PTR [rdx]
    2687:	mov    r8,QWORD PTR [rdx+0x8]
    268b:	mov    rcx,QWORD PTR [rdx+0x10]
    268f:	mov    rdx,r8
    2692:	call   2697 <botlish_entry_22+0x17>
			2693: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    2697:	mov    rsp,rbp
    269a:	pop    rbp
    269b:	ret
    269c:	add    BYTE PTR [rax],al
	...

00000000000026a0 <botlish_fn_23: tld_ok<generic>>:
    26a0:	push   rbp
    26a1:	mov    rbp,rsp
    26a4:	sub    rsp,0x40
    26a8:	mov    QWORD PTR [rsp+0x20],rbx
    26ad:	mov    QWORD PTR [rsp+0x28],r12
    26b2:	mov    QWORD PTR [rsp+0x30],r13
    26b7:	mov    QWORD PTR [rsp+0x38],r14
    26bc:	mov    rbx,rdi
    26bf:	mov    QWORD PTR [rsp],rsi
    26c3:	mov    r12,rsi
    26c6:	mov    QWORD PTR [rsp+0x8],rdx
    26cb:	mov    r14,rdx
    26ce:	mov    QWORD PTR [rsp+0x10],rcx
    26d3:	mov    rdx,r14
    26d6:	mov    rsi,r12
    26d9:	mov    rdi,rbx
    26dc:	call   26e1 <botlish_fn_23+0x41>
			26dd: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    26e1:	mov    rsi,rax
    26e4:	mov    r13,rax
    26e7:	test   rax,rsi
    26ea:	je     27ad <botlish_fn_23+0x10d>
    26f0:	mov    rax,r13
    26f3:	mov    QWORD PTR [rsp+0x8],rax
    26f8:	mov    rdx,r14
    26fb:	and    rax,rdx
    26fe:	test   rax,0x1
    2704:	jne    272d <botlish_fn_23+0x8d>
    270a:	mov    rsi,r13
    270d:	mov    rdi,rbx
    2710:	call   2715 <botlish_fn_23+0x75>
			2711: R_X86_64_PLT32	rt_int_cmp-0x4
    2715:	mov    ecx,0x2
    271a:	test   rax,rax
    271d:	cmove  rcx,QWORD PTR [rip+0x15b]        # 2880 <botlish_fn_23+0x1e0>
    2725:	mov    rax,r13
    2728:	jmp    2740 <botlish_fn_23+0xa0>
    272d:	mov    ecx,0x2
    2732:	mov    rax,r13
    2735:	cmp    rax,rdx
    2738:	cmove  rcx,QWORD PTR [rip+0x140]        # 2880 <botlish_fn_23+0x1e0>
    2740:	cmp    rcx,0x6
    2744:	je     2757 <botlish_fn_23+0xb7>
    274a:	mov    ecx,0x2
    274f:	mov    rax,rcx
    2752:	jmp    285f <botlish_fn_23+0x1bf>
    2757:	mov    ecx,0x1
    275c:	mov    rsi,r12
    275f:	test   rsi,0x1
    2766:	jne    278c <botlish_fn_23+0xec>
    276c:	xor    ecx,ecx
    276e:	mov    rsi,r12
    2771:	test   rsi,0x7
    2778:	jne    278c <botlish_fn_23+0xec>
    277e:	mov    rsi,r12
    2781:	movzx  rcx,BYTE PTR [rsi]
    2785:	rex cmp cl,0x1
    2789:	sete   cl
    278c:	test   cl,cl
    278e:	jne    27cd <botlish_fn_23+0x12d>
    2794:	mov    rdi,rbx
    2797:	mov    rsi,QWORD PTR [rdi+0x10]
    279b:	mov    rcx,QWORD PTR [rsi+0x120]
    27a2:	xor    rdx,rdx
    27a5:	mov    rsi,r12
    27a8:	call   27ad <botlish_fn_23+0x10d>
			27a9: R_X86_64_PLT32	rt_type_error-0x4
    27ad:	xor    rax,rax
    27b0:	mov    rbx,QWORD PTR [rsp+0x20]
    27b5:	mov    r12,QWORD PTR [rsp+0x28]
    27ba:	mov    r13,QWORD PTR [rsp+0x30]
    27bf:	mov    r14,QWORD PTR [rsp+0x38]
    27c4:	add    rsp,0x40
    27c8:	mov    rsp,rbp
    27cb:	pop    rbp
    27cc:	ret
    27cd:	mov    rsi,r12
    27d0:	mov    rdi,rax
    27d3:	and    rdi,rsi
    27d6:	test   rdi,0x1
    27dd:	jne    27ee <botlish_fn_23+0x14e>
    27e3:	mov    rdx,r12
    27e6:	mov    rsi,rax
    27e9:	jmp    2811 <botlish_fn_23+0x171>
    27ee:	mov    rsi,r12
    27f1:	mov    r8,rax
    27f4:	sub    r8,rsi
    27f7:	mov    r13,rax
    27fa:	seto   r10b
    27fe:	lea    rsi,[r8+0x1]
    2802:	test   r10b,r10b
    2805:	je     281c <botlish_fn_23+0x17c>
    280b:	mov    rdx,r12
    280e:	mov    rsi,r13
    2811:	mov    rdi,rbx
    2814:	call   2819 <botlish_fn_23+0x179>
			2815: R_X86_64_PLT32	rt_int_sub-0x4
    2819:	mov    rsi,rax
    281c:	test   rsi,0x1
    2823:	jne    284e <botlish_fn_23+0x1ae>
    2829:	mov    edx,0x5
    282e:	mov    rdi,rbx
    2831:	call   2836 <botlish_fn_23+0x196>
			2832: R_X86_64_PLT32	rt_int_cmp-0x4
    2836:	mov    ecx,0x2
    283b:	test   rax,rax
    283e:	mov    rax,rcx
    2841:	cmovge rax,QWORD PTR [rip+0x37]        # 2880 <botlish_fn_23+0x1e0>
    2849:	jmp    285f <botlish_fn_23+0x1bf>
    284e:	mov    eax,0x2
    2853:	cmp    rsi,0x5
    2857:	cmovge rax,QWORD PTR [rip+0x21]        # 2880 <botlish_fn_23+0x1e0>
    285f:	mov    rbx,QWORD PTR [rsp+0x20]
    2864:	mov    r12,QWORD PTR [rsp+0x28]
    2869:	mov    r13,QWORD PTR [rsp+0x30]
    286e:	mov    r14,QWORD PTR [rsp+0x38]
    2873:	add    rsp,0x40
    2877:	mov    rsp,rbp
    287a:	pop    rbp
    287b:	ret
    287c:	add    BYTE PTR [rax],al
    287e:	add    BYTE PTR [rax],al
    2880:	(bad)
    2881:	add    BYTE PTR [rax],al
    2883:	add    BYTE PTR [rax],al
    2885:	add    BYTE PTR [rax],al
	...

0000000000002888 <botlish_entry_23: tld_ok<generic>>:
    2888:	push   rbp
    2889:	mov    rbp,rsp
    288c:	mov    rsi,QWORD PTR [rdx]
    288f:	mov    r8,QWORD PTR [rdx+0x8]
    2893:	mov    rcx,QWORD PTR [rdx+0x10]
    2897:	mov    rdx,r8
    289a:	call   289f <botlish_entry_23+0x17>
			289b: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    289f:	mov    rsp,rbp
    28a2:	pop    rbp
    28a3:	ret
    28a4:	add    BYTE PTR [rax],al
	...

00000000000028a8 <botlish_fn_24: domain_loop<generic>>:
    28a8:	push   rbp
    28a9:	mov    rbp,rsp
    28ac:	sub    rsp,0x70
    28b0:	mov    QWORD PTR [rsp+0x40],rbx
    28b5:	mov    QWORD PTR [rsp+0x48],r12
    28ba:	mov    QWORD PTR [rsp+0x50],r13
    28bf:	mov    QWORD PTR [rsp+0x58],r14
    28c4:	mov    QWORD PTR [rsp+0x60],r15
    28c9:	mov    QWORD PTR [rsp+0x18],0x0
    28d2:	mov    QWORD PTR [rsp],rsi
    28d6:	mov    QWORD PTR [rsp+0x8],rdx
    28db:	mov    QWORD PTR [rsp+0x10],rcx
    28e0:	lea    rbx,[rsp+0x20]
    28e5:	mov    r12,rdi
    28e8:	mov    r13,rcx
    28eb:	mov    r14,rdx
    28ee:	mov    QWORD PTR [rsp+0x30],rsi
    28f3:	mov    rcx,r13
    28f6:	mov    rdx,r14
    28f9:	mov    rsi,QWORD PTR [rsp+0x30]
    28fe:	mov    rdi,r12
    2901:	call   2906 <botlish_fn_24+0x5e>
			2902: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    2906:	mov    rcx,rax
    2909:	mov    r15,rax
    290c:	test   rax,rcx
    290f:	je     2a5f <botlish_fn_24+0x1b7>
    2915:	mov    rax,r15
    2918:	mov    QWORD PTR [rsp],rax
    291c:	mov    rdx,QWORD PTR [rsp+0x30]
    2921:	and    rax,rdx
    2924:	test   rax,0x1
    292a:	jne    2949 <botlish_fn_24+0xa1>
    2930:	mov    rsi,r15
    2933:	mov    rdi,r12
    2936:	call   293b <botlish_fn_24+0x93>
			2937: R_X86_64_PLT32	rt_value_eq-0x4
    293b:	test   rax,rax
    293e:	je     2a5f <botlish_fn_24+0x1b7>
    2944:	jmp    2959 <botlish_fn_24+0xb1>
    2949:	mov    eax,0x2
    294e:	cmp    r15,rdx
    2951:	cmove  rax,QWORD PTR [rip+0x187]        # 2ae0 <botlish_fn_24+0x238>
    2959:	cmp    rax,0x6
    295d:	je     2ab5 <botlish_fn_24+0x20d>
    2963:	mov    rax,r15
    2966:	and    rax,r14
    2969:	test   rax,0x1
    296f:	jne    2998 <botlish_fn_24+0xf0>
    2975:	mov    rdx,r14
    2978:	mov    rsi,r15
    297b:	mov    rdi,r12
    297e:	call   2983 <botlish_fn_24+0xdb>
			297f: R_X86_64_PLT32	rt_int_cmp-0x4
    2983:	mov    ecx,0x2
    2988:	test   rax,rax
    298b:	cmovge rcx,QWORD PTR [rip+0x14d]        # 2ae0 <botlish_fn_24+0x238>
    2993:	jmp    29a8 <botlish_fn_24+0x100>
    2998:	mov    ecx,0x2
    299d:	cmp    r15,r14
    29a0:	cmovge rcx,QWORD PTR [rip+0x138]        # 2ae0 <botlish_fn_24+0x238>
    29a8:	cmp    rcx,0x6
    29ac:	je     2aa6 <botlish_fn_24+0x1fe>
    29b2:	mov    rcx,rbx
    29b5:	mov    rdx,r13
    29b8:	mov    rsi,r15
    29bb:	mov    rdi,r12
    29be:	call   29c3 <botlish_fn_24+0x11b>
			29bf: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    29c3:	test   rax,rax
    29c6:	je     2a5f <botlish_fn_24+0x1b7>
    29cc:	mov    rdx,QWORD PTR [rsp+0x20]
    29d1:	mov    rcx,QWORD PTR [rsp+0x28]
    29d6:	mov    rsi,QWORD PTR [r12+0x10]
    29db:	mov    r8,QWORD PTR [rsi+0x110]
    29e2:	mov    rsi,rax
    29e5:	mov    rdi,r12
    29e8:	call   29ed <botlish_fn_24+0x145>
			29e9: R_X86_64_PLT32	rt_str_region_eq-0x4
    29ed:	cmp    rax,0x6
    29f1:	je     2a03 <botlish_fn_24+0x15b>
    29f7:	mov    r14,0xffffffffffffffff
    29fe:	jmp    2aad <botlish_fn_24+0x205>
    2a03:	mov    QWORD PTR [rsp+0x18],0x3
    2a0c:	test   r15,0x1
    2a13:	je     2a2b <botlish_fn_24+0x183>
    2a19:	mov    rdx,r15
    2a1c:	add    rdx,0x2
    2a20:	seto   al
    2a23:	test   al,al
    2a25:	je     2a3e <botlish_fn_24+0x196>
    2a2b:	mov    edx,0x3
    2a30:	mov    rsi,r15
    2a33:	mov    rdi,r12
    2a36:	call   2a3b <botlish_fn_24+0x193>
			2a37: R_X86_64_PLT32	rt_int_add-0x4
    2a3b:	mov    rdx,rax
    2a3e:	mov    QWORD PTR [rsp],rdx
    2a42:	mov    r15,rdx
    2a45:	mov    rcx,r13
    2a48:	mov    rdx,r14
    2a4b:	mov    rsi,r15
    2a4e:	mov    rdi,r12
    2a51:	call   2a56 <botlish_fn_24+0x1ae>
			2a52: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    2a56:	test   rax,rax
    2a59:	jne    2a84 <botlish_fn_24+0x1dc>
    2a5f:	xor    rax,rax
    2a62:	mov    rbx,QWORD PTR [rsp+0x40]
    2a67:	mov    r12,QWORD PTR [rsp+0x48]
    2a6c:	mov    r13,QWORD PTR [rsp+0x50]
    2a71:	mov    r14,QWORD PTR [rsp+0x58]
    2a76:	mov    r15,QWORD PTR [rsp+0x60]
    2a7b:	add    rsp,0x70
    2a7f:	mov    rsp,rbp
    2a82:	pop    rbp
    2a83:	ret
    2a84:	cmp    rax,0x6
    2a88:	je     2aad <botlish_fn_24+0x205>
    2a8e:	mov    QWORD PTR [rsp],r15
    2a92:	mov    QWORD PTR [rsp+0x8],r14
    2a97:	mov    QWORD PTR [rsp+0x10],r13
    2a9c:	mov    QWORD PTR [rsp+0x30],r15
    2aa1:	jmp    28f3 <botlish_fn_24+0x4b>
    2aa6:	mov    r14,0xffffffffffffffff
    2aad:	mov    rax,r14
    2ab0:	jmp    2abc <botlish_fn_24+0x214>
    2ab5:	mov    rax,0xffffffffffffffff
    2abc:	mov    rbx,QWORD PTR [rsp+0x40]
    2ac1:	mov    r12,QWORD PTR [rsp+0x48]
    2ac6:	mov    r13,QWORD PTR [rsp+0x50]
    2acb:	mov    r14,QWORD PTR [rsp+0x58]
    2ad0:	mov    r15,QWORD PTR [rsp+0x60]
    2ad5:	add    rsp,0x70
    2ad9:	mov    rsp,rbp
    2adc:	pop    rbp
    2add:	ret
    2ade:	add    BYTE PTR [rax],al
    2ae0:	(bad)
    2ae1:	add    BYTE PTR [rax],al
    2ae3:	add    BYTE PTR [rax],al
    2ae5:	add    BYTE PTR [rax],al
	...

0000000000002ae8 <botlish_entry_24: domain_loop<generic>>:
    2ae8:	push   rbp
    2ae9:	mov    rbp,rsp
    2aec:	mov    rsi,QWORD PTR [rdx]
    2aef:	mov    r8,QWORD PTR [rdx+0x8]
    2af3:	mov    rcx,QWORD PTR [rdx+0x10]
    2af7:	mov    rdx,r8
    2afa:	call   2aff <botlish_entry_24+0x17>
			2afb: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    2aff:	mov    rsp,rbp
    2b02:	pop    rbp
    2b03:	ret
    2b04:	add    BYTE PTR [rax],al
	...

0000000000002b08 <botlish_fn_25: <str>>:
    2b08:	push   rbp
    2b09:	mov    rbp,rsp
    2b0c:	sub    rsp,0x50
    2b10:	mov    QWORD PTR [rsp+0x30],rbx
    2b15:	mov    QWORD PTR [rsp+0x38],r12
    2b1a:	mov    QWORD PTR [rsp+0x40],r13
    2b1f:	mov    QWORD PTR [rsp+0x48],r14
    2b24:	mov    r13,rdi
    2b27:	mov    QWORD PTR [rsp+0x18],0x0
    2b30:	mov    QWORD PTR [rsp],rsi
    2b34:	mov    r14,rsi
    2b37:	mov    rsi,r14
    2b3a:	mov    rdi,r13
    2b3d:	call   2b42 <botlish_fn_25+0x3a>
			2b3e: R_X86_64_PLT32	rt_str_len-0x4
    2b42:	mov    rbx,rax
    2b45:	mov    QWORD PTR [rsp+0x8],rax
    2b4a:	mov    esi,0x1
    2b4f:	mov    QWORD PTR [rsp+0x10],0x1
    2b58:	mov    rcx,r14
    2b5b:	mov    rdx,rbx
    2b5e:	mov    rdi,r13
    2b61:	call   2b66 <botlish_fn_25+0x5e>
			2b62: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    2b66:	mov    r12,rax
    2b69:	test   r12,r12
    2b6c:	je     2cc9 <botlish_fn_25+0x1c1>
    2b72:	mov    QWORD PTR [rsp+0x10],r12
    2b77:	test   r12,0x1
    2b7e:	jne    2ba9 <botlish_fn_25+0xa1>
    2b84:	mov    edx,0x1
    2b89:	mov    rsi,r12
    2b8c:	mov    rdi,r13
    2b8f:	call   2b94 <botlish_fn_25+0x8c>
			2b90: R_X86_64_PLT32	rt_int_cmp-0x4
    2b94:	mov    ecx,0x2
    2b99:	test   rax,rax
    2b9c:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 2d68 <botlish_fn_25+0x260>
    2ba4:	jmp    2bba <botlish_fn_25+0xb2>
    2ba9:	mov    ecx,0x2
    2bae:	cmp    r12,0x1
    2bb2:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 2d68 <botlish_fn_25+0x260>
    2bba:	cmp    rcx,0x6
    2bbe:	je     2d44 <botlish_fn_25+0x23c>
    2bc4:	mov    rcx,r12
    2bc7:	and    rcx,rbx
    2bca:	test   rcx,0x1
    2bd1:	jne    2bfa <botlish_fn_25+0xf2>
    2bd7:	mov    rdx,rbx
    2bda:	mov    rsi,r12
    2bdd:	mov    rdi,r13
    2be0:	call   2be5 <botlish_fn_25+0xdd>
			2be1: R_X86_64_PLT32	rt_int_cmp-0x4
    2be5:	mov    ecx,0x2
    2bea:	test   rax,rax
    2bed:	cmovge rcx,QWORD PTR [rip+0x173]        # 2d68 <botlish_fn_25+0x260>
    2bf5:	jmp    2c0a <botlish_fn_25+0x102>
    2bfa:	mov    ecx,0x2
    2bff:	cmp    r12,rbx
    2c02:	cmovge rcx,QWORD PTR [rip+0x15e]        # 2d68 <botlish_fn_25+0x260>
    2c0a:	cmp    rcx,0x6
    2c0e:	je     2d3a <botlish_fn_25+0x232>
    2c14:	lea    rcx,[rsp+0x20]
    2c19:	mov    rdx,r14
    2c1c:	mov    rsi,r12
    2c1f:	mov    rdi,r13
    2c22:	call   2c27 <botlish_fn_25+0x11f>
			2c23: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    2c27:	test   rax,rax
    2c2a:	mov    rsi,rax
    2c2d:	je     2cc9 <botlish_fn_25+0x1c1>
    2c33:	mov    rdx,QWORD PTR [rsp+0x20]
    2c38:	mov    rcx,QWORD PTR [rsp+0x28]
    2c3d:	mov    rdi,r13
    2c40:	mov    rax,QWORD PTR [rdi+0x10]
    2c44:	mov    r8,QWORD PTR [rax+0xf8]
    2c4b:	call   2c50 <botlish_fn_25+0x148>
			2c4c: R_X86_64_PLT32	rt_str_region_eq-0x4
    2c50:	cmp    rax,0x6
    2c54:	je     2c67 <botlish_fn_25+0x15f>
    2c5a:	mov    ecx,0x2
    2c5f:	mov    rax,rcx
    2c62:	jmp    2d49 <botlish_fn_25+0x241>
    2c67:	mov    QWORD PTR [rsp+0x18],0x3
    2c70:	test   r12,0x1
    2c77:	jne    2c85 <botlish_fn_25+0x17d>
    2c7d:	mov    rcx,r12
    2c80:	jmp    2c9a <botlish_fn_25+0x192>
    2c85:	mov    rsi,r12
    2c88:	add    rsi,0x2
    2c8c:	mov    rcx,r12
    2c8f:	seto   al
    2c92:	test   al,al
    2c94:	je     2cad <botlish_fn_25+0x1a5>
    2c9a:	mov    edx,0x3
    2c9f:	mov    rsi,rcx
    2ca2:	mov    rdi,r13
    2ca5:	call   2caa <botlish_fn_25+0x1a2>
			2ca6: R_X86_64_PLT32	rt_int_add-0x4
    2caa:	mov    rsi,rax
    2cad:	mov    QWORD PTR [rsp+0x10],rsi
    2cb2:	mov    rcx,r14
    2cb5:	mov    rdx,rbx
    2cb8:	mov    rdi,r13
    2cbb:	call   2cc0 <botlish_fn_25+0x1b8>
			2cbc: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    2cc0:	test   rax,rax
    2cc3:	jne    2ce9 <botlish_fn_25+0x1e1>
    2cc9:	xor    rax,rax
    2ccc:	mov    rbx,QWORD PTR [rsp+0x30]
    2cd1:	mov    r12,QWORD PTR [rsp+0x38]
    2cd6:	mov    r13,QWORD PTR [rsp+0x40]
    2cdb:	mov    r14,QWORD PTR [rsp+0x48]
    2ce0:	add    rsp,0x50
    2ce4:	mov    rsp,rbp
    2ce7:	pop    rbp
    2ce8:	ret
    2ce9:	mov    rcx,rax
    2cec:	and    rcx,rbx
    2cef:	mov    rsi,rax
    2cf2:	test   rcx,0x1
    2cf9:	jne    2d22 <botlish_fn_25+0x21a>
    2cff:	mov    rdx,rbx
    2d02:	mov    rdi,r13
    2d05:	call   2d0a <botlish_fn_25+0x202>
			2d06: R_X86_64_PLT32	rt_int_cmp-0x4
    2d0a:	mov    ecx,0x2
    2d0f:	test   rax,rax
    2d12:	mov    rax,rcx
    2d15:	cmove  rax,QWORD PTR [rip+0x4b]        # 2d68 <botlish_fn_25+0x260>
    2d1d:	jmp    2d49 <botlish_fn_25+0x241>
    2d22:	mov    rdx,rbx
    2d25:	mov    eax,0x2
    2d2a:	cmp    rsi,rdx
    2d2d:	cmove  rax,QWORD PTR [rip+0x33]        # 2d68 <botlish_fn_25+0x260>
    2d35:	jmp    2d49 <botlish_fn_25+0x241>
    2d3a:	mov    eax,0x2
    2d3f:	jmp    2d49 <botlish_fn_25+0x241>
    2d44:	mov    eax,0x2
    2d49:	mov    rbx,QWORD PTR [rsp+0x30]
    2d4e:	mov    r12,QWORD PTR [rsp+0x38]
    2d53:	mov    r13,QWORD PTR [rsp+0x40]
    2d58:	mov    r14,QWORD PTR [rsp+0x48]
    2d5d:	add    rsp,0x50
    2d61:	mov    rsp,rbp
    2d64:	pop    rbp
    2d65:	ret
    2d66:	add    BYTE PTR [rax],al
    2d68:	(bad)
    2d69:	add    BYTE PTR [rax],al
    2d6b:	add    BYTE PTR [rax],al
    2d6d:	add    BYTE PTR [rax],al
	...

0000000000002d70 <botlish_entry_25: <str>>:
    2d70:	push   rbp
    2d71:	mov    rbp,rsp
    2d74:	mov    rsi,QWORD PTR [rdx]
    2d77:	call   2d7c <botlish_entry_25+0xc>
			2d78: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    2d7c:	mov    rsp,rbp
    2d7f:	pop    rbp
    2d80:	ret
    2d81:	add    BYTE PTR [rax],al
    2d83:	add    BYTE PTR [rax],al
    2d85:	add    BYTE PTR [rax],al
	...

0000000000002d88 <botlish_fn_26: <generic>>:
    2d88:	push   rbp
    2d89:	mov    rbp,rsp
    2d8c:	sub    rsp,0x60
    2d90:	mov    QWORD PTR [rsp+0x30],rbx
    2d95:	mov    QWORD PTR [rsp+0x38],r12
    2d9a:	mov    QWORD PTR [rsp+0x40],r13
    2d9f:	mov    QWORD PTR [rsp+0x48],r14
    2da4:	mov    QWORD PTR [rsp+0x50],r15
    2da9:	mov    QWORD PTR [rsp+0x18],0x0
    2db2:	mov    QWORD PTR [rsp],rsi
    2db6:	xor    r8d,r8d
    2db9:	test   rsi,0x7
    2dc0:	jne    2dd0 <botlish_fn_26+0x48>
    2dc6:	movzx  rax,BYTE PTR [rsi]
    2dca:	cmp    al,0x2
    2dcc:	sete   r8b
    2dd0:	test   r8b,r8b
    2dd3:	jne    2df3 <botlish_fn_26+0x6b>
    2dd9:	mov    rdx,QWORD PTR [rdi+0x10]
    2ddd:	mov    rcx,QWORD PTR [rdx+0xe0]
    2de4:	mov    edx,0x1
    2de9:	call   2dee <botlish_fn_26+0x66>
			2dea: R_X86_64_PLT32	rt_type_error-0x4
    2dee:	jmp    2f88 <botlish_fn_26+0x200>
    2df3:	mov    r13,rsi
    2df6:	mov    r14,rdi
    2df9:	call   2dfe <botlish_fn_26+0x76>
			2dfa: R_X86_64_PLT32	rt_str_len-0x4
    2dfe:	mov    rbx,rax
    2e01:	mov    QWORD PTR [rsp+0x8],rax
    2e06:	mov    edx,0x1
    2e0b:	mov    r15,rdx
    2e0e:	mov    QWORD PTR [rsp+0x10],0x1
    2e17:	mov    rcx,r13
    2e1a:	mov    rdx,rbx
    2e1d:	mov    rsi,r15
    2e20:	mov    rdi,r14
    2e23:	call   2e28 <botlish_fn_26+0xa0>
			2e24: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    2e28:	mov    r12,rax
    2e2b:	test   r12,r12
    2e2e:	je     2f88 <botlish_fn_26+0x200>
    2e34:	mov    QWORD PTR [rsp+0x10],r12
    2e39:	test   r12,0x1
    2e40:	jne    2e69 <botlish_fn_26+0xe1>
    2e46:	mov    rdx,r15
    2e49:	mov    rsi,r12
    2e4c:	mov    rdi,r14
    2e4f:	call   2e54 <botlish_fn_26+0xcc>
			2e50: R_X86_64_PLT32	rt_int_cmp-0x4
    2e54:	mov    ecx,0x2
    2e59:	test   rax,rax
    2e5c:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 3030 <botlish_fn_26+0x2a8>
    2e64:	jmp    2e7a <botlish_fn_26+0xf2>
    2e69:	mov    ecx,0x2
    2e6e:	cmp    r12,0x1
    2e72:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 3030 <botlish_fn_26+0x2a8>
    2e7a:	cmp    rcx,0x6
    2e7e:	je     3008 <botlish_fn_26+0x280>
    2e84:	mov    rax,r12
    2e87:	and    rax,rbx
    2e8a:	test   rax,0x1
    2e90:	jne    2eb9 <botlish_fn_26+0x131>
    2e96:	mov    rdx,rbx
    2e99:	mov    rsi,r12
    2e9c:	mov    rdi,r14
    2e9f:	call   2ea4 <botlish_fn_26+0x11c>
			2ea0: R_X86_64_PLT32	rt_int_cmp-0x4
    2ea4:	mov    ecx,0x2
    2ea9:	test   rax,rax
    2eac:	cmovge rcx,QWORD PTR [rip+0x17c]        # 3030 <botlish_fn_26+0x2a8>
    2eb4:	jmp    2ec9 <botlish_fn_26+0x141>
    2eb9:	mov    ecx,0x2
    2ebe:	cmp    r12,rbx
    2ec1:	cmovge rcx,QWORD PTR [rip+0x167]        # 3030 <botlish_fn_26+0x2a8>
    2ec9:	cmp    rcx,0x6
    2ecd:	je     2ffe <botlish_fn_26+0x276>
    2ed3:	lea    rcx,[rsp+0x20]
    2ed8:	mov    rdx,r13
    2edb:	mov    rsi,r12
    2ede:	mov    rdi,r14
    2ee1:	call   2ee6 <botlish_fn_26+0x15e>
			2ee2: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    2ee6:	test   rax,rax
    2ee9:	mov    rsi,rax
    2eec:	je     2f88 <botlish_fn_26+0x200>
    2ef2:	mov    rdx,QWORD PTR [rsp+0x20]
    2ef7:	mov    rcx,QWORD PTR [rsp+0x28]
    2efc:	mov    rdi,r14
    2eff:	mov    rax,QWORD PTR [rdi+0x10]
    2f03:	mov    r8,QWORD PTR [rax+0xf8]
    2f0a:	call   2f0f <botlish_fn_26+0x187>
			2f0b: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f0f:	cmp    rax,0x6
    2f13:	je     2f26 <botlish_fn_26+0x19e>
    2f19:	mov    ecx,0x2
    2f1e:	mov    rax,rcx
    2f21:	jmp    300d <botlish_fn_26+0x285>
    2f26:	mov    QWORD PTR [rsp+0x18],0x3
    2f2f:	test   r12,0x1
    2f36:	jne    2f44 <botlish_fn_26+0x1bc>
    2f3c:	mov    rdi,r12
    2f3f:	jmp    2f59 <botlish_fn_26+0x1d1>
    2f44:	mov    rsi,r12
    2f47:	add    rsi,0x2
    2f4b:	mov    rdi,r12
    2f4e:	seto   al
    2f51:	test   al,al
    2f53:	je     2f6c <botlish_fn_26+0x1e4>
    2f59:	mov    edx,0x3
    2f5e:	mov    rsi,rdi
    2f61:	mov    rdi,r14
    2f64:	call   2f69 <botlish_fn_26+0x1e1>
			2f65: R_X86_64_PLT32	rt_int_add-0x4
    2f69:	mov    rsi,rax
    2f6c:	mov    QWORD PTR [rsp+0x10],rsi
    2f71:	mov    rcx,r13
    2f74:	mov    rdx,rbx
    2f77:	mov    rdi,r14
    2f7a:	call   2f7f <botlish_fn_26+0x1f7>
			2f7b: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    2f7f:	test   rax,rax
    2f82:	jne    2fad <botlish_fn_26+0x225>
    2f88:	xor    rax,rax
    2f8b:	mov    rbx,QWORD PTR [rsp+0x30]
    2f90:	mov    r12,QWORD PTR [rsp+0x38]
    2f95:	mov    r13,QWORD PTR [rsp+0x40]
    2f9a:	mov    r14,QWORD PTR [rsp+0x48]
    2f9f:	mov    r15,QWORD PTR [rsp+0x50]
    2fa4:	add    rsp,0x60
    2fa8:	mov    rsp,rbp
    2fab:	pop    rbp
    2fac:	ret
    2fad:	mov    rcx,rax
    2fb0:	and    rcx,rbx
    2fb3:	mov    rsi,rax
    2fb6:	test   rcx,0x1
    2fbd:	jne    2fe6 <botlish_fn_26+0x25e>
    2fc3:	mov    rdx,rbx
    2fc6:	mov    rdi,r14
    2fc9:	call   2fce <botlish_fn_26+0x246>
			2fca: R_X86_64_PLT32	rt_int_cmp-0x4
    2fce:	mov    ecx,0x2
    2fd3:	test   rax,rax
    2fd6:	mov    rax,rcx
    2fd9:	cmove  rax,QWORD PTR [rip+0x4f]        # 3030 <botlish_fn_26+0x2a8>
    2fe1:	jmp    300d <botlish_fn_26+0x285>
    2fe6:	mov    rdx,rbx
    2fe9:	mov    eax,0x2
    2fee:	cmp    rsi,rdx
    2ff1:	cmove  rax,QWORD PTR [rip+0x37]        # 3030 <botlish_fn_26+0x2a8>
    2ff9:	jmp    300d <botlish_fn_26+0x285>
    2ffe:	mov    eax,0x2
    3003:	jmp    300d <botlish_fn_26+0x285>
    3008:	mov    eax,0x2
    300d:	mov    rbx,QWORD PTR [rsp+0x30]
    3012:	mov    r12,QWORD PTR [rsp+0x38]
    3017:	mov    r13,QWORD PTR [rsp+0x40]
    301c:	mov    r14,QWORD PTR [rsp+0x48]
    3021:	mov    r15,QWORD PTR [rsp+0x50]
    3026:	add    rsp,0x60
    302a:	mov    rsp,rbp
    302d:	pop    rbp
    302e:	ret
    302f:	add    BYTE PTR [rsi],al
    3031:	add    BYTE PTR [rax],al
    3033:	add    BYTE PTR [rax],al
    3035:	add    BYTE PTR [rax],al
	...

0000000000003038 <botlish_entry_26: <generic>>:
    3038:	push   rbp
    3039:	mov    rbp,rsp
    303c:	mov    rsi,QWORD PTR [rdx]
    303f:	call   3044 <botlish_entry_26+0xc>
			3040: R_X86_64_PLT32	botlish_fn_26-0x4 ; <generic>
    3044:	mov    rsp,rbp
    3047:	pop    rbp
    3048:	ret

0000000000003049 <botlish_fn_27: char_at<generic>>:
    3049:	push   rbp
    304a:	mov    rbp,rsp
    304d:	sub    rsp,0x50
    3051:	mov    QWORD PTR [rsp+0x20],rbx
    3056:	mov    QWORD PTR [rsp+0x28],r12
    305b:	mov    QWORD PTR [rsp+0x30],r13
    3060:	mov    QWORD PTR [rsp+0x38],r14
    3065:	mov    QWORD PTR [rsp+0x40],r15
    306a:	mov    r14,rcx
    306d:	mov    QWORD PTR [rsp],rsi
    3071:	mov    QWORD PTR [rsp+0x8],rdx
    3076:	mov    r13,rdx
    3079:	mov    QWORD PTR [rsp+0x10],0x3
    3082:	mov    r9d,0x1
    3088:	test   rsi,0x1
    308f:	jne    30af <botlish_fn_27+0x66>
    3095:	xor    r9d,r9d
    3098:	test   rsi,0x7
    309f:	jne    30af <botlish_fn_27+0x66>
    30a5:	movzx  rax,BYTE PTR [rsi]
    30a9:	cmp    al,0x1
    30ab:	sete   r9b
    30af:	test   r9b,r9b
    30b2:	jne    30d0 <botlish_fn_27+0x87>
    30b8:	mov    rax,QWORD PTR [rdi+0x10]
    30bc:	mov    rcx,QWORD PTR [rax+0x100]
    30c3:	xor    rdx,rdx
    30c6:	call   30cb <botlish_fn_27+0x82>
			30c7: R_X86_64_PLT32	rt_type_error-0x4
    30cb:	jmp    318d <botlish_fn_27+0x144>
    30d0:	mov    r12,rdi
    30d3:	test   rsi,0x1
    30da:	jne    30e8 <botlish_fn_27+0x9f>
    30e0:	mov    rbx,rsi
    30e3:	jmp    3105 <botlish_fn_27+0xbc>
    30e8:	mov    rax,rsi
    30eb:	add    rax,0x2
    30ef:	mov    rbx,rsi
    30f2:	seto   cl
    30f5:	test   cl,cl
    30f7:	jne    3105 <botlish_fn_27+0xbc>
    30fd:	mov    r15,rax
    3100:	jmp    3118 <botlish_fn_27+0xcf>
    3105:	mov    edx,0x3
    310a:	mov    rsi,rbx
    310d:	mov    rdi,r12
    3110:	call   3115 <botlish_fn_27+0xcc>
			3111: R_X86_64_PLT32	rt_int_add-0x4
    3115:	mov    r15,rax
    3118:	mov    ecx,0x1
    311d:	mov    rsi,rbx
    3120:	test   rsi,0x1
    3127:	jne    314d <botlish_fn_27+0x104>
    312d:	xor    ecx,ecx
    312f:	mov    rsi,rbx
    3132:	test   rsi,0x7
    3139:	jne    314d <botlish_fn_27+0x104>
    313f:	mov    rsi,rbx
    3142:	movzx  rcx,BYTE PTR [rsi]
    3146:	rex cmp cl,0x1
    314a:	sete   cl
    314d:	test   cl,cl
    314f:	jne    3173 <botlish_fn_27+0x12a>
    3155:	mov    rdi,r12
    3158:	mov    rsi,QWORD PTR [rdi+0x10]
    315c:	mov    rcx,QWORD PTR [rsi+0x108]
    3163:	xor    rdx,rdx
    3166:	mov    rsi,rbx
    3169:	call   316e <botlish_fn_27+0x125>
			316a: R_X86_64_PLT32	rt_type_error-0x4
    316e:	jmp    318d <botlish_fn_27+0x144>
    3173:	mov    rdi,r12
    3176:	mov    rcx,r15
    3179:	mov    rdx,rbx
    317c:	mov    rsi,r13
    317f:	call   3184 <botlish_fn_27+0x13b>
			3180: R_X86_64_PLT32	rt_str_region_check-0x4
    3184:	test   rax,rax
    3187:	jne    31b2 <botlish_fn_27+0x169>
    318d:	xor    rax,rax
    3190:	mov    rbx,QWORD PTR [rsp+0x20]
    3195:	mov    r12,QWORD PTR [rsp+0x28]
    319a:	mov    r13,QWORD PTR [rsp+0x30]
    319f:	mov    r14,QWORD PTR [rsp+0x38]
    31a4:	mov    r15,QWORD PTR [rsp+0x40]
    31a9:	add    rsp,0x50
    31ad:	mov    rsp,rbp
    31b0:	pop    rbp
    31b1:	ret
    31b2:	mov    rcx,r14
    31b5:	mov    rsi,rbx
    31b8:	mov    QWORD PTR [rcx],rsi
    31bb:	mov    rax,r15
    31be:	mov    QWORD PTR [rcx+0x8],rax
    31c2:	mov    rax,r13
    31c5:	mov    rbx,QWORD PTR [rsp+0x20]
    31ca:	mov    r12,QWORD PTR [rsp+0x28]
    31cf:	mov    r13,QWORD PTR [rsp+0x30]
    31d4:	mov    r14,QWORD PTR [rsp+0x38]
    31d9:	mov    r15,QWORD PTR [rsp+0x40]
    31de:	add    rsp,0x50
    31e2:	mov    rsp,rbp
    31e5:	pop    rbp
    31e6:	ret

00000000000031e7 <botlish_entry_27: char_at<generic>>:
    31e7:	push   rbp
    31e8:	mov    rbp,rsp
    31eb:	ud2
    31ed:	add    BYTE PTR [rax],al
	...

00000000000031f0 <botlish_fn_28: scan_local<generic>>:
    31f0:	push   rbp
    31f1:	mov    rbp,rsp
    31f4:	sub    rsp,0x80
    31fb:	mov    QWORD PTR [rsp+0x50],rbx
    3200:	mov    QWORD PTR [rsp+0x58],r12
    3205:	mov    QWORD PTR [rsp+0x60],r13
    320a:	mov    QWORD PTR [rsp+0x68],r14
    320f:	mov    QWORD PTR [rsp+0x70],r15
    3214:	mov    rax,rdi
    3217:	mov    QWORD PTR [rsp+0x18],0x0
    3220:	mov    QWORD PTR [rsp],rsi
    3224:	mov    r14,rsi
    3227:	mov    QWORD PTR [rsp+0x8],rdx
    322c:	mov    QWORD PTR [rsp+0x10],rcx
    3231:	mov    r12,rcx
    3234:	mov    r11d,0x1
    323a:	mov    rsi,r14
    323d:	test   rsi,0x1
    3244:	jne    3266 <botlish_fn_28+0x76>
    324a:	xor    r11d,r11d
    324d:	test   rsi,0x7
    3254:	jne    3266 <botlish_fn_28+0x76>
    325a:	movzx  rdi,BYTE PTR [rsi]
    325e:	cmp    dil,0x1
    3262:	sete   r11b
    3266:	test   r11b,r11b
    3269:	jne    328a <botlish_fn_28+0x9a>
    326f:	mov    rdi,rax
    3272:	mov    r9,QWORD PTR [rdi+0x10]
    3276:	mov    rcx,QWORD PTR [r9+0xc0]
    327d:	xor    rdx,rdx
    3280:	call   3285 <botlish_fn_28+0x95>
			3281: R_X86_64_PLT32	rt_type_error-0x4
    3285:	jmp    333d <botlish_fn_28+0x14d>
    328a:	mov    r13,rdx
    328d:	mov    r10,rsi
    3290:	and    r10,r13
    3293:	mov    r14,rsi
    3296:	test   r10,0x1
    329d:	jne    32c9 <botlish_fn_28+0xd9>
    32a3:	mov    rbx,rax
    32a6:	mov    rdx,r13
    32a9:	mov    rsi,r14
    32ac:	mov    rdi,rbx
    32af:	call   32b4 <botlish_fn_28+0xc4>
			32b0: R_X86_64_PLT32	rt_int_cmp-0x4
    32b4:	mov    ecx,0x2
    32b9:	test   rax,rax
    32bc:	cmovge rcx,QWORD PTR [rip+0x24c]        # 3510 <botlish_fn_28+0x320>
    32c4:	jmp    32df <botlish_fn_28+0xef>
    32c9:	mov    rbx,rax
    32cc:	mov    ecx,0x2
    32d1:	mov    rsi,r14
    32d4:	cmp    rsi,r13
    32d7:	cmovge rcx,QWORD PTR [rip+0x231]        # 3510 <botlish_fn_28+0x320>
    32df:	mov    eax,0x6
    32e4:	mov    QWORD PTR [rsp+0x30],rax
    32e9:	cmp    rcx,0x6
    32ed:	je     34e3 <botlish_fn_28+0x2f3>
    32f3:	lea    rcx,[rsp+0x20]
    32f8:	mov    rdx,r12
    32fb:	mov    rsi,r14
    32fe:	mov    rdi,rbx
    3301:	call   3306 <botlish_fn_28+0x116>
			3302: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    3306:	mov    rsi,rax
    3309:	mov    r15,rax
    330c:	test   rax,rsi
    330f:	je     333d <botlish_fn_28+0x14d>
    3315:	mov    rdx,QWORD PTR [rsp+0x20]
    331a:	mov    QWORD PTR [rsp+0x40],rdx
    331f:	mov    rcx,QWORD PTR [rsp+0x28]
    3324:	mov    QWORD PTR [rsp+0x38],rcx
    3329:	mov    rsi,r15
    332c:	mov    rdi,rbx
    332f:	call   3334 <botlish_fn_28+0x144>
			3330: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    3334:	test   rax,rax
    3337:	jne    3365 <botlish_fn_28+0x175>
    333d:	xor    rax,rax
    3340:	mov    rbx,QWORD PTR [rsp+0x50]
    3345:	mov    r12,QWORD PTR [rsp+0x58]
    334a:	mov    r13,QWORD PTR [rsp+0x60]
    334f:	mov    r14,QWORD PTR [rsp+0x68]
    3354:	mov    r15,QWORD PTR [rsp+0x70]
    3359:	add    rsp,0x80
    3360:	mov    rsp,rbp
    3363:	pop    rbp
    3364:	ret
    3365:	cmp    rax,0x6
    3369:	je     3464 <botlish_fn_28+0x274>
    336f:	mov    rax,QWORD PTR [rbx+0x10]
    3373:	mov    r8,QWORD PTR [rax+0x110]
    337a:	mov    rcx,QWORD PTR [rsp+0x38]
    337f:	mov    rdx,QWORD PTR [rsp+0x40]
    3384:	mov    rsi,r15
    3387:	mov    rdi,rbx
    338a:	call   338f <botlish_fn_28+0x19f>
			338b: R_X86_64_PLT32	rt_str_region_eq-0x4
    338f:	cmp    rax,0x6
    3393:	je     345a <botlish_fn_28+0x26a>
    3399:	mov    rax,QWORD PTR [rbx+0x10]
    339d:	mov    r8,QWORD PTR [rax+0x118]
    33a4:	mov    rcx,QWORD PTR [rsp+0x38]
    33a9:	mov    rdx,QWORD PTR [rsp+0x40]
    33ae:	mov    rsi,r15
    33b1:	mov    rdi,rbx
    33b4:	call   33b9 <botlish_fn_28+0x1c9>
			33b5: R_X86_64_PLT32	rt_str_region_eq-0x4
    33b9:	cmp    rax,0x6
    33bd:	je     3450 <botlish_fn_28+0x260>
    33c3:	mov    rax,QWORD PTR [rbx+0x10]
    33c7:	mov    r8,QWORD PTR [rax+0xc8]
    33ce:	mov    rcx,QWORD PTR [rsp+0x38]
    33d3:	mov    rdx,QWORD PTR [rsp+0x40]
    33d8:	mov    rsi,r15
    33db:	mov    rdi,rbx
    33de:	call   33e3 <botlish_fn_28+0x1f3>
			33df: R_X86_64_PLT32	rt_str_region_eq-0x4
    33e3:	cmp    rax,0x6
    33e7:	je     3446 <botlish_fn_28+0x256>
    33ed:	mov    rax,QWORD PTR [rbx+0x10]
    33f1:	mov    r8,QWORD PTR [rax+0x100]
    33f8:	mov    rcx,QWORD PTR [rsp+0x38]
    33fd:	mov    rdx,QWORD PTR [rsp+0x40]
    3402:	mov    rsi,r15
    3405:	mov    rdi,rbx
    3408:	call   340d <botlish_fn_28+0x21d>
			3409: R_X86_64_PLT32	rt_str_region_eq-0x4
    340d:	cmp    rax,0x6
    3411:	je     343c <botlish_fn_28+0x24c>
    3417:	mov    rax,QWORD PTR [rbx+0x10]
    341b:	mov    r8,QWORD PTR [rax+0x120]
    3422:	mov    rcx,QWORD PTR [rsp+0x38]
    3427:	mov    rdx,QWORD PTR [rsp+0x40]
    342c:	mov    rsi,r15
    342f:	mov    rdi,rbx
    3432:	call   3437 <botlish_fn_28+0x247>
			3433: R_X86_64_PLT32	rt_str_region_eq-0x4
    3437:	jmp    3469 <botlish_fn_28+0x279>
    343c:	mov    rax,QWORD PTR [rsp+0x30]
    3441:	jmp    3469 <botlish_fn_28+0x279>
    3446:	mov    rax,QWORD PTR [rsp+0x30]
    344b:	jmp    3469 <botlish_fn_28+0x279>
    3450:	mov    rax,QWORD PTR [rsp+0x30]
    3455:	jmp    3469 <botlish_fn_28+0x279>
    345a:	mov    rax,QWORD PTR [rsp+0x30]
    345f:	jmp    3469 <botlish_fn_28+0x279>
    3464:	mov    rax,QWORD PTR [rsp+0x30]
    3469:	cmp    rax,0x6
    346d:	je     347b <botlish_fn_28+0x28b>
    3473:	mov    rax,r14
    3476:	jmp    34e6 <botlish_fn_28+0x2f6>
    347b:	mov    QWORD PTR [rsp+0x18],0x3
    3484:	mov    rsi,r14
    3487:	test   rsi,0x1
    348e:	je     34b4 <botlish_fn_28+0x2c4>
    3494:	mov    rsi,r14
    3497:	mov    rax,rsi
    349a:	add    rax,0x2
    349e:	seto   cl
    34a1:	test   cl,cl
    34a3:	jne    34b4 <botlish_fn_28+0x2c4>
    34a9:	mov    rsi,rax
    34ac:	mov    r14,rax
    34af:	jmp    34ca <botlish_fn_28+0x2da>
    34b4:	mov    edx,0x3
    34b9:	mov    rsi,r14
    34bc:	mov    rdi,rbx
    34bf:	call   34c4 <botlish_fn_28+0x2d4>
			34c0: R_X86_64_PLT32	rt_int_add-0x4
    34c4:	mov    rsi,rax
    34c7:	mov    r14,rax
    34ca:	mov    QWORD PTR [rsp],rsi
    34ce:	mov    QWORD PTR [rsp+0x8],r13
    34d3:	mov    QWORD PTR [rsp+0x10],r12
    34d8:	mov    rax,rbx
    34db:	mov    rdx,r13
    34de:	jmp    3234 <botlish_fn_28+0x44>
    34e3:	mov    rax,r14
    34e6:	mov    rbx,QWORD PTR [rsp+0x50]
    34eb:	mov    r12,QWORD PTR [rsp+0x58]
    34f0:	mov    r13,QWORD PTR [rsp+0x60]
    34f5:	mov    r14,QWORD PTR [rsp+0x68]
    34fa:	mov    r15,QWORD PTR [rsp+0x70]
    34ff:	add    rsp,0x80
    3506:	mov    rsp,rbp
    3509:	pop    rbp
    350a:	ret
    350b:	add    BYTE PTR [rax],al
    350d:	add    BYTE PTR [rax],al
    350f:	add    BYTE PTR [rsi],al
    3511:	add    BYTE PTR [rax],al
    3513:	add    BYTE PTR [rax],al
    3515:	add    BYTE PTR [rax],al
	...

0000000000003518 <botlish_entry_28: scan_local<generic>>:
    3518:	push   rbp
    3519:	mov    rbp,rsp
    351c:	mov    rsi,QWORD PTR [rdx]
    351f:	mov    r8,QWORD PTR [rdx+0x8]
    3523:	mov    rcx,QWORD PTR [rdx+0x10]
    3527:	mov    rdx,r8
    352a:	call   352f <botlish_entry_28+0x17>
			352b: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    352f:	mov    rsp,rbp
    3532:	pop    rbp
    3533:	ret
    3534:	add    BYTE PTR [rax],al
	...

0000000000003538 <botlish_fn_29: scan_label<generic>>:
    3538:	push   rbp
    3539:	mov    rbp,rsp
    353c:	sub    rsp,0x80
    3543:	mov    QWORD PTR [rsp+0x50],rbx
    3548:	mov    QWORD PTR [rsp+0x58],r12
    354d:	mov    QWORD PTR [rsp+0x60],r13
    3552:	mov    QWORD PTR [rsp+0x68],r14
    3557:	mov    QWORD PTR [rsp+0x70],r15
    355c:	mov    QWORD PTR [rsp+0x18],0x0
    3565:	mov    QWORD PTR [rsp],rsi
    3569:	mov    r14,rsi
    356c:	mov    QWORD PTR [rsp+0x8],rdx
    3571:	mov    QWORD PTR [rsp+0x10],rcx
    3576:	mov    r12,rcx
    3579:	mov    r11d,0x1
    357f:	mov    rsi,r14
    3582:	test   rsi,0x1
    3589:	jne    35a9 <botlish_fn_29+0x71>
    358f:	xor    r11d,r11d
    3592:	test   rsi,0x7
    3599:	jne    35a9 <botlish_fn_29+0x71>
    359f:	movzx  rax,BYTE PTR [rsi]
    35a3:	cmp    al,0x1
    35a5:	sete   r11b
    35a9:	test   r11b,r11b
    35ac:	jne    35ca <botlish_fn_29+0x92>
    35b2:	mov    rax,QWORD PTR [rdi+0x10]
    35b6:	mov    rcx,QWORD PTR [rax+0xc0]
    35bd:	xor    rdx,rdx
    35c0:	call   35c5 <botlish_fn_29+0x8d>
			35c1: R_X86_64_PLT32	rt_type_error-0x4
    35c5:	jmp    3676 <botlish_fn_29+0x13e>
    35ca:	mov    r13,rdx
    35cd:	mov    rax,rsi
    35d0:	and    rax,r13
    35d3:	mov    r14,rsi
    35d6:	test   rax,0x1
    35dc:	jne    3605 <botlish_fn_29+0xcd>
    35e2:	mov    rbx,rdi
    35e5:	mov    rdx,r13
    35e8:	mov    rsi,r14
    35eb:	call   35f0 <botlish_fn_29+0xb8>
			35ec: R_X86_64_PLT32	rt_int_cmp-0x4
    35f0:	mov    ecx,0x2
    35f5:	test   rax,rax
    35f8:	cmovge rcx,QWORD PTR [rip+0x178]        # 3778 <botlish_fn_29+0x240>
    3600:	jmp    361b <botlish_fn_29+0xe3>
    3605:	mov    rbx,rdi
    3608:	mov    ecx,0x2
    360d:	mov    rsi,r14
    3610:	cmp    rsi,r13
    3613:	cmovge rcx,QWORD PTR [rip+0x15d]        # 3778 <botlish_fn_29+0x240>
    361b:	mov    eax,0x6
    3620:	mov    QWORD PTR [rsp+0x30],rax
    3625:	cmp    rcx,0x6
    3629:	je     374c <botlish_fn_29+0x214>
    362f:	lea    rcx,[rsp+0x20]
    3634:	mov    rdx,r12
    3637:	mov    rsi,r14
    363a:	mov    rdi,rbx
    363d:	call   3642 <botlish_fn_29+0x10a>
			363e: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    3642:	test   rax,rax
    3645:	mov    r15,rax
    3648:	je     3676 <botlish_fn_29+0x13e>
    364e:	mov    rdx,QWORD PTR [rsp+0x20]
    3653:	mov    QWORD PTR [rsp+0x40],rdx
    3658:	mov    rcx,QWORD PTR [rsp+0x28]
    365d:	mov    QWORD PTR [rsp+0x38],rcx
    3662:	mov    rsi,r15
    3665:	mov    rdi,rbx
    3668:	call   366d <botlish_fn_29+0x135>
			3669: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    366d:	test   rax,rax
    3670:	jne    369e <botlish_fn_29+0x166>
    3676:	xor    rax,rax
    3679:	mov    rbx,QWORD PTR [rsp+0x50]
    367e:	mov    r12,QWORD PTR [rsp+0x58]
    3683:	mov    r13,QWORD PTR [rsp+0x60]
    3688:	mov    r14,QWORD PTR [rsp+0x68]
    368d:	mov    r15,QWORD PTR [rsp+0x70]
    3692:	add    rsp,0x80
    3699:	mov    rsp,rbp
    369c:	pop    rbp
    369d:	ret
    369e:	cmp    rax,0x6
    36a2:	je     36cd <botlish_fn_29+0x195>
    36a8:	mov    r11,QWORD PTR [rbx+0x10]
    36ac:	mov    r8,QWORD PTR [r11+0x120]
    36b3:	mov    rcx,QWORD PTR [rsp+0x38]
    36b8:	mov    rdx,QWORD PTR [rsp+0x40]
    36bd:	mov    rsi,r15
    36c0:	mov    rdi,rbx
    36c3:	call   36c8 <botlish_fn_29+0x190>
			36c4: R_X86_64_PLT32	rt_str_region_eq-0x4
    36c8:	jmp    36d2 <botlish_fn_29+0x19a>
    36cd:	mov    rax,QWORD PTR [rsp+0x30]
    36d2:	cmp    rax,0x6
    36d6:	je     36e4 <botlish_fn_29+0x1ac>
    36dc:	mov    rax,r14
    36df:	jmp    374f <botlish_fn_29+0x217>
    36e4:	mov    QWORD PTR [rsp+0x18],0x3
    36ed:	mov    rsi,r14
    36f0:	test   rsi,0x1
    36f7:	je     371d <botlish_fn_29+0x1e5>
    36fd:	mov    rsi,r14
    3700:	mov    rax,rsi
    3703:	add    rax,0x2
    3707:	seto   cl
    370a:	test   cl,cl
    370c:	jne    371d <botlish_fn_29+0x1e5>
    3712:	mov    rsi,rax
    3715:	mov    r14,rax
    3718:	jmp    3733 <botlish_fn_29+0x1fb>
    371d:	mov    edx,0x3
    3722:	mov    rsi,r14
    3725:	mov    rdi,rbx
    3728:	call   372d <botlish_fn_29+0x1f5>
			3729: R_X86_64_PLT32	rt_int_add-0x4
    372d:	mov    rsi,rax
    3730:	mov    r14,rax
    3733:	mov    QWORD PTR [rsp],rsi
    3737:	mov    QWORD PTR [rsp+0x8],r13
    373c:	mov    QWORD PTR [rsp+0x10],r12
    3741:	mov    rdx,r13
    3744:	mov    rdi,rbx
    3747:	jmp    3579 <botlish_fn_29+0x41>
    374c:	mov    rax,r14
    374f:	mov    rbx,QWORD PTR [rsp+0x50]
    3754:	mov    r12,QWORD PTR [rsp+0x58]
    3759:	mov    r13,QWORD PTR [rsp+0x60]
    375e:	mov    r14,QWORD PTR [rsp+0x68]
    3763:	mov    r15,QWORD PTR [rsp+0x70]
    3768:	add    rsp,0x80
    376f:	mov    rsp,rbp
    3772:	pop    rbp
    3773:	ret
    3774:	add    BYTE PTR [rax],al
    3776:	add    BYTE PTR [rax],al
    3778:	(bad)
    3779:	add    BYTE PTR [rax],al
    377b:	add    BYTE PTR [rax],al
    377d:	add    BYTE PTR [rax],al
	...

0000000000003780 <botlish_entry_29: scan_label<generic>>:
    3780:	push   rbp
    3781:	mov    rbp,rsp
    3784:	mov    rsi,QWORD PTR [rdx]
    3787:	mov    r8,QWORD PTR [rdx+0x8]
    378b:	mov    rcx,QWORD PTR [rdx+0x10]
    378f:	mov    rdx,r8
    3792:	call   3797 <botlish_entry_29+0x17>
			3793: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_label<generic>
    3797:	mov    rsp,rbp
    379a:	pop    rbp
    379b:	ret
    379c:	add    BYTE PTR [rax],al
	...

00000000000037a0 <botlish_fn_30: scan_alpha<generic>>:
    37a0:	push   rbp
    37a1:	mov    rbp,rsp
    37a4:	sub    rsp,0x50
    37a8:	mov    QWORD PTR [rsp+0x30],rbx
    37ad:	mov    QWORD PTR [rsp+0x38],r12
    37b2:	mov    QWORD PTR [rsp+0x40],r13
    37b7:	mov    QWORD PTR [rsp+0x48],r14
    37bc:	mov    r14,rdi
    37bf:	mov    QWORD PTR [rsp+0x18],0x0
    37c8:	mov    QWORD PTR [rsp],rsi
    37cc:	mov    r13,rsi
    37cf:	mov    QWORD PTR [rsp+0x8],rdx
    37d4:	mov    r12,rdx
    37d7:	mov    QWORD PTR [rsp+0x10],rcx
    37dc:	mov    rbx,rcx
    37df:	mov    r11d,0x1
    37e5:	mov    rsi,r13
    37e8:	test   rsi,0x1
    37ef:	jne    380f <botlish_fn_30+0x6f>
    37f5:	xor    r11d,r11d
    37f8:	test   rsi,0x7
    37ff:	jne    380f <botlish_fn_30+0x6f>
    3805:	movzx  rax,BYTE PTR [rsi]
    3809:	cmp    al,0x1
    380b:	sete   r11b
    380f:	test   r11b,r11b
    3812:	jne    3833 <botlish_fn_30+0x93>
    3818:	mov    rdi,r14
    381b:	mov    rax,QWORD PTR [rdi+0x10]
    381f:	mov    rcx,QWORD PTR [rax+0xc0]
    3826:	xor    rdx,rdx
    3829:	call   382e <botlish_fn_30+0x8e>
			382a: R_X86_64_PLT32	rt_type_error-0x4
    382e:	jmp    38c2 <botlish_fn_30+0x122>
    3833:	mov    rax,rsi
    3836:	and    rax,r12
    3839:	mov    r13,rsi
    383c:	test   rax,0x1
    3842:	jne    386b <botlish_fn_30+0xcb>
    3848:	mov    rdx,r12
    384b:	mov    rsi,r13
    384e:	mov    rdi,r14
    3851:	call   3856 <botlish_fn_30+0xb6>
			3852: R_X86_64_PLT32	rt_int_cmp-0x4
    3856:	mov    ecx,0x2
    385b:	test   rax,rax
    385e:	cmovge rcx,QWORD PTR [rip+0x112]        # 3978 <botlish_fn_30+0x1d8>
    3866:	jmp    387e <botlish_fn_30+0xde>
    386b:	mov    ecx,0x2
    3870:	mov    rsi,r13
    3873:	cmp    rsi,r12
    3876:	cmovge rcx,QWORD PTR [rip+0xfa]        # 3978 <botlish_fn_30+0x1d8>
    387e:	cmp    rcx,0x6
    3882:	je     3956 <botlish_fn_30+0x1b6>
    3888:	lea    rcx,[rsp+0x20]
    388d:	mov    rdx,rbx
    3890:	mov    rsi,r13
    3893:	mov    rdi,r14
    3896:	call   389b <botlish_fn_30+0xfb>
			3897: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    389b:	test   rax,rax
    389e:	mov    rsi,rax
    38a1:	je     38c2 <botlish_fn_30+0x122>
    38a7:	mov    rdx,QWORD PTR [rsp+0x20]
    38ac:	mov    rcx,QWORD PTR [rsp+0x28]
    38b1:	mov    rdi,r14
    38b4:	call   38b9 <botlish_fn_30+0x119>
			38b5: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    38b9:	test   rax,rax
    38bc:	jne    38e2 <botlish_fn_30+0x142>
    38c2:	xor    rax,rax
    38c5:	mov    rbx,QWORD PTR [rsp+0x30]
    38ca:	mov    r12,QWORD PTR [rsp+0x38]
    38cf:	mov    r13,QWORD PTR [rsp+0x40]
    38d4:	mov    r14,QWORD PTR [rsp+0x48]
    38d9:	add    rsp,0x50
    38dd:	mov    rsp,rbp
    38e0:	pop    rbp
    38e1:	ret
    38e2:	cmp    rax,0x6
    38e6:	je     38f4 <botlish_fn_30+0x154>
    38ec:	mov    rax,r13
    38ef:	jmp    3959 <botlish_fn_30+0x1b9>
    38f4:	mov    QWORD PTR [rsp+0x18],0x3
    38fd:	mov    rsi,r13
    3900:	test   rsi,0x1
    3907:	je     392d <botlish_fn_30+0x18d>
    390d:	mov    rsi,r13
    3910:	mov    r11,rsi
    3913:	add    r11,0x2
    3917:	seto   al
    391a:	test   al,al
    391c:	jne    392d <botlish_fn_30+0x18d>
    3922:	mov    rsi,r11
    3925:	mov    r13,r11
    3928:	jmp    3943 <botlish_fn_30+0x1a3>
    392d:	mov    edx,0x3
    3932:	mov    rsi,r13
    3935:	mov    rdi,r14
    3938:	call   393d <botlish_fn_30+0x19d>
			3939: R_X86_64_PLT32	rt_int_add-0x4
    393d:	mov    rsi,rax
    3940:	mov    r13,rax
    3943:	mov    QWORD PTR [rsp],rsi
    3947:	mov    QWORD PTR [rsp+0x8],r12
    394c:	mov    QWORD PTR [rsp+0x10],rbx
    3951:	jmp    37df <botlish_fn_30+0x3f>
    3956:	mov    rax,r13
    3959:	mov    rbx,QWORD PTR [rsp+0x30]
    395e:	mov    r12,QWORD PTR [rsp+0x38]
    3963:	mov    r13,QWORD PTR [rsp+0x40]
    3968:	mov    r14,QWORD PTR [rsp+0x48]
    396d:	add    rsp,0x50
    3971:	mov    rsp,rbp
    3974:	pop    rbp
    3975:	ret
    3976:	add    BYTE PTR [rax],al
    3978:	(bad)
    3979:	add    BYTE PTR [rax],al
    397b:	add    BYTE PTR [rax],al
    397d:	add    BYTE PTR [rax],al
	...

0000000000003980 <botlish_entry_30: scan_alpha<generic>>:
    3980:	push   rbp
    3981:	mov    rbp,rsp
    3984:	mov    rsi,QWORD PTR [rdx]
    3987:	mov    r8,QWORD PTR [rdx+0x8]
    398b:	mov    rcx,QWORD PTR [rdx+0x10]
    398f:	mov    rdx,r8
    3992:	call   3997 <botlish_entry_30+0x17>
			3993: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_alpha<generic>
    3997:	mov    rsp,rbp
    399a:	pop    rbp
    399b:	ret
    399c:	add    BYTE PTR [rax],al
	...

00000000000039a0 <botlish_fn_31: tld_ok<generic>>:
    39a0:	push   rbp
    39a1:	mov    rbp,rsp
    39a4:	sub    rsp,0x40
    39a8:	mov    QWORD PTR [rsp+0x20],rbx
    39ad:	mov    QWORD PTR [rsp+0x28],r12
    39b2:	mov    QWORD PTR [rsp+0x30],r13
    39b7:	mov    QWORD PTR [rsp+0x38],r14
    39bc:	mov    rbx,rdi
    39bf:	mov    QWORD PTR [rsp],rsi
    39c3:	mov    r12,rsi
    39c6:	mov    QWORD PTR [rsp+0x8],rdx
    39cb:	mov    r14,rdx
    39ce:	mov    QWORD PTR [rsp+0x10],rcx
    39d3:	mov    rdx,r14
    39d6:	mov    rsi,r12
    39d9:	mov    rdi,rbx
    39dc:	call   39e1 <botlish_fn_31+0x41>
			39dd: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_alpha<generic>
    39e1:	mov    rsi,rax
    39e4:	mov    r13,rax
    39e7:	test   rax,rsi
    39ea:	je     3aad <botlish_fn_31+0x10d>
    39f0:	mov    rax,r13
    39f3:	mov    QWORD PTR [rsp+0x8],rax
    39f8:	mov    rdx,r14
    39fb:	and    rax,rdx
    39fe:	test   rax,0x1
    3a04:	jne    3a2d <botlish_fn_31+0x8d>
    3a0a:	mov    rsi,r13
    3a0d:	mov    rdi,rbx
    3a10:	call   3a15 <botlish_fn_31+0x75>
			3a11: R_X86_64_PLT32	rt_int_cmp-0x4
    3a15:	mov    ecx,0x2
    3a1a:	test   rax,rax
    3a1d:	cmove  rcx,QWORD PTR [rip+0x15b]        # 3b80 <botlish_fn_31+0x1e0>
    3a25:	mov    rax,r13
    3a28:	jmp    3a40 <botlish_fn_31+0xa0>
    3a2d:	mov    ecx,0x2
    3a32:	mov    rax,r13
    3a35:	cmp    rax,rdx
    3a38:	cmove  rcx,QWORD PTR [rip+0x140]        # 3b80 <botlish_fn_31+0x1e0>
    3a40:	cmp    rcx,0x6
    3a44:	je     3a57 <botlish_fn_31+0xb7>
    3a4a:	mov    ecx,0x2
    3a4f:	mov    rax,rcx
    3a52:	jmp    3b5f <botlish_fn_31+0x1bf>
    3a57:	mov    ecx,0x1
    3a5c:	mov    rsi,r12
    3a5f:	test   rsi,0x1
    3a66:	jne    3a8c <botlish_fn_31+0xec>
    3a6c:	xor    ecx,ecx
    3a6e:	mov    rsi,r12
    3a71:	test   rsi,0x7
    3a78:	jne    3a8c <botlish_fn_31+0xec>
    3a7e:	mov    rsi,r12
    3a81:	movzx  rcx,BYTE PTR [rsi]
    3a85:	rex cmp cl,0x1
    3a89:	sete   cl
    3a8c:	test   cl,cl
    3a8e:	jne    3acd <botlish_fn_31+0x12d>
    3a94:	mov    rdi,rbx
    3a97:	mov    rsi,QWORD PTR [rdi+0x10]
    3a9b:	mov    rcx,QWORD PTR [rsi+0x120]
    3aa2:	xor    rdx,rdx
    3aa5:	mov    rsi,r12
    3aa8:	call   3aad <botlish_fn_31+0x10d>
			3aa9: R_X86_64_PLT32	rt_type_error-0x4
    3aad:	xor    rax,rax
    3ab0:	mov    rbx,QWORD PTR [rsp+0x20]
    3ab5:	mov    r12,QWORD PTR [rsp+0x28]
    3aba:	mov    r13,QWORD PTR [rsp+0x30]
    3abf:	mov    r14,QWORD PTR [rsp+0x38]
    3ac4:	add    rsp,0x40
    3ac8:	mov    rsp,rbp
    3acb:	pop    rbp
    3acc:	ret
    3acd:	mov    rsi,r12
    3ad0:	mov    rdi,rax
    3ad3:	and    rdi,rsi
    3ad6:	test   rdi,0x1
    3add:	jne    3aee <botlish_fn_31+0x14e>
    3ae3:	mov    rdx,r12
    3ae6:	mov    rsi,rax
    3ae9:	jmp    3b11 <botlish_fn_31+0x171>
    3aee:	mov    rsi,r12
    3af1:	mov    r8,rax
    3af4:	sub    r8,rsi
    3af7:	mov    r13,rax
    3afa:	seto   r10b
    3afe:	lea    rsi,[r8+0x1]
    3b02:	test   r10b,r10b
    3b05:	je     3b1c <botlish_fn_31+0x17c>
    3b0b:	mov    rdx,r12
    3b0e:	mov    rsi,r13
    3b11:	mov    rdi,rbx
    3b14:	call   3b19 <botlish_fn_31+0x179>
			3b15: R_X86_64_PLT32	rt_int_sub-0x4
    3b19:	mov    rsi,rax
    3b1c:	test   rsi,0x1
    3b23:	jne    3b4e <botlish_fn_31+0x1ae>
    3b29:	mov    edx,0x5
    3b2e:	mov    rdi,rbx
    3b31:	call   3b36 <botlish_fn_31+0x196>
			3b32: R_X86_64_PLT32	rt_int_cmp-0x4
    3b36:	mov    ecx,0x2
    3b3b:	test   rax,rax
    3b3e:	mov    rax,rcx
    3b41:	cmovge rax,QWORD PTR [rip+0x37]        # 3b80 <botlish_fn_31+0x1e0>
    3b49:	jmp    3b5f <botlish_fn_31+0x1bf>
    3b4e:	mov    eax,0x2
    3b53:	cmp    rsi,0x5
    3b57:	cmovge rax,QWORD PTR [rip+0x21]        # 3b80 <botlish_fn_31+0x1e0>
    3b5f:	mov    rbx,QWORD PTR [rsp+0x20]
    3b64:	mov    r12,QWORD PTR [rsp+0x28]
    3b69:	mov    r13,QWORD PTR [rsp+0x30]
    3b6e:	mov    r14,QWORD PTR [rsp+0x38]
    3b73:	add    rsp,0x40
    3b77:	mov    rsp,rbp
    3b7a:	pop    rbp
    3b7b:	ret
    3b7c:	add    BYTE PTR [rax],al
    3b7e:	add    BYTE PTR [rax],al
    3b80:	(bad)
    3b81:	add    BYTE PTR [rax],al
    3b83:	add    BYTE PTR [rax],al
    3b85:	add    BYTE PTR [rax],al
	...

0000000000003b88 <botlish_entry_31: tld_ok<generic>>:
    3b88:	push   rbp
    3b89:	mov    rbp,rsp
    3b8c:	mov    rsi,QWORD PTR [rdx]
    3b8f:	mov    r8,QWORD PTR [rdx+0x8]
    3b93:	mov    rcx,QWORD PTR [rdx+0x10]
    3b97:	mov    rdx,r8
    3b9a:	call   3b9f <botlish_entry_31+0x17>
			3b9b: R_X86_64_PLT32	botlish_fn_31-0x4 ; tld_ok<generic>
    3b9f:	mov    rsp,rbp
    3ba2:	pop    rbp
    3ba3:	ret
    3ba4:	add    BYTE PTR [rax],al
	...

0000000000003ba8 <botlish_fn_32: domain_loop<generic>>:
    3ba8:	push   rbp
    3ba9:	mov    rbp,rsp
    3bac:	sub    rsp,0x70
    3bb0:	mov    QWORD PTR [rsp+0x40],rbx
    3bb5:	mov    QWORD PTR [rsp+0x48],r12
    3bba:	mov    QWORD PTR [rsp+0x50],r13
    3bbf:	mov    QWORD PTR [rsp+0x58],r14
    3bc4:	mov    QWORD PTR [rsp+0x60],r15
    3bc9:	mov    QWORD PTR [rsp+0x18],0x0
    3bd2:	mov    QWORD PTR [rsp],rsi
    3bd6:	mov    QWORD PTR [rsp+0x8],rdx
    3bdb:	mov    QWORD PTR [rsp+0x10],rcx
    3be0:	lea    rbx,[rsp+0x20]
    3be5:	mov    r12,rdi
    3be8:	mov    r13,rcx
    3beb:	mov    r14,rdx
    3bee:	mov    QWORD PTR [rsp+0x30],rsi
    3bf3:	mov    rcx,r13
    3bf6:	mov    rdx,r14
    3bf9:	mov    rsi,QWORD PTR [rsp+0x30]
    3bfe:	mov    rdi,r12
    3c01:	call   3c06 <botlish_fn_32+0x5e>
			3c02: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_label<generic>
    3c06:	mov    rcx,rax
    3c09:	mov    r15,rax
    3c0c:	test   rax,rcx
    3c0f:	je     3d5f <botlish_fn_32+0x1b7>
    3c15:	mov    rax,r15
    3c18:	mov    QWORD PTR [rsp],rax
    3c1c:	mov    rdx,QWORD PTR [rsp+0x30]
    3c21:	and    rax,rdx
    3c24:	test   rax,0x1
    3c2a:	jne    3c49 <botlish_fn_32+0xa1>
    3c30:	mov    rsi,r15
    3c33:	mov    rdi,r12
    3c36:	call   3c3b <botlish_fn_32+0x93>
			3c37: R_X86_64_PLT32	rt_value_eq-0x4
    3c3b:	test   rax,rax
    3c3e:	je     3d5f <botlish_fn_32+0x1b7>
    3c44:	jmp    3c59 <botlish_fn_32+0xb1>
    3c49:	mov    eax,0x2
    3c4e:	cmp    r15,rdx
    3c51:	cmove  rax,QWORD PTR [rip+0x187]        # 3de0 <botlish_fn_32+0x238>
    3c59:	cmp    rax,0x6
    3c5d:	je     3db5 <botlish_fn_32+0x20d>
    3c63:	mov    rax,r15
    3c66:	and    rax,r14
    3c69:	test   rax,0x1
    3c6f:	jne    3c98 <botlish_fn_32+0xf0>
    3c75:	mov    rdx,r14
    3c78:	mov    rsi,r15
    3c7b:	mov    rdi,r12
    3c7e:	call   3c83 <botlish_fn_32+0xdb>
			3c7f: R_X86_64_PLT32	rt_int_cmp-0x4
    3c83:	mov    ecx,0x2
    3c88:	test   rax,rax
    3c8b:	cmovge rcx,QWORD PTR [rip+0x14d]        # 3de0 <botlish_fn_32+0x238>
    3c93:	jmp    3ca8 <botlish_fn_32+0x100>
    3c98:	mov    ecx,0x2
    3c9d:	cmp    r15,r14
    3ca0:	cmovge rcx,QWORD PTR [rip+0x138]        # 3de0 <botlish_fn_32+0x238>
    3ca8:	cmp    rcx,0x6
    3cac:	je     3da6 <botlish_fn_32+0x1fe>
    3cb2:	mov    rcx,rbx
    3cb5:	mov    rdx,r13
    3cb8:	mov    rsi,r15
    3cbb:	mov    rdi,r12
    3cbe:	call   3cc3 <botlish_fn_32+0x11b>
			3cbf: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    3cc3:	test   rax,rax
    3cc6:	je     3d5f <botlish_fn_32+0x1b7>
    3ccc:	mov    rdx,QWORD PTR [rsp+0x20]
    3cd1:	mov    rcx,QWORD PTR [rsp+0x28]
    3cd6:	mov    rsi,QWORD PTR [r12+0x10]
    3cdb:	mov    r8,QWORD PTR [rsi+0x110]
    3ce2:	mov    rsi,rax
    3ce5:	mov    rdi,r12
    3ce8:	call   3ced <botlish_fn_32+0x145>
			3ce9: R_X86_64_PLT32	rt_str_region_eq-0x4
    3ced:	cmp    rax,0x6
    3cf1:	je     3d03 <botlish_fn_32+0x15b>
    3cf7:	mov    r14,0xffffffffffffffff
    3cfe:	jmp    3dad <botlish_fn_32+0x205>
    3d03:	mov    QWORD PTR [rsp+0x18],0x3
    3d0c:	test   r15,0x1
    3d13:	je     3d2b <botlish_fn_32+0x183>
    3d19:	mov    rdx,r15
    3d1c:	add    rdx,0x2
    3d20:	seto   al
    3d23:	test   al,al
    3d25:	je     3d3e <botlish_fn_32+0x196>
    3d2b:	mov    edx,0x3
    3d30:	mov    rsi,r15
    3d33:	mov    rdi,r12
    3d36:	call   3d3b <botlish_fn_32+0x193>
			3d37: R_X86_64_PLT32	rt_int_add-0x4
    3d3b:	mov    rdx,rax
    3d3e:	mov    QWORD PTR [rsp],rdx
    3d42:	mov    r15,rdx
    3d45:	mov    rcx,r13
    3d48:	mov    rdx,r14
    3d4b:	mov    rsi,r15
    3d4e:	mov    rdi,r12
    3d51:	call   3d56 <botlish_fn_32+0x1ae>
			3d52: R_X86_64_PLT32	botlish_fn_31-0x4 ; tld_ok<generic>
    3d56:	test   rax,rax
    3d59:	jne    3d84 <botlish_fn_32+0x1dc>
    3d5f:	xor    rax,rax
    3d62:	mov    rbx,QWORD PTR [rsp+0x40]
    3d67:	mov    r12,QWORD PTR [rsp+0x48]
    3d6c:	mov    r13,QWORD PTR [rsp+0x50]
    3d71:	mov    r14,QWORD PTR [rsp+0x58]
    3d76:	mov    r15,QWORD PTR [rsp+0x60]
    3d7b:	add    rsp,0x70
    3d7f:	mov    rsp,rbp
    3d82:	pop    rbp
    3d83:	ret
    3d84:	cmp    rax,0x6
    3d88:	je     3dad <botlish_fn_32+0x205>
    3d8e:	mov    QWORD PTR [rsp],r15
    3d92:	mov    QWORD PTR [rsp+0x8],r14
    3d97:	mov    QWORD PTR [rsp+0x10],r13
    3d9c:	mov    QWORD PTR [rsp+0x30],r15
    3da1:	jmp    3bf3 <botlish_fn_32+0x4b>
    3da6:	mov    r14,0xffffffffffffffff
    3dad:	mov    rax,r14
    3db0:	jmp    3dbc <botlish_fn_32+0x214>
    3db5:	mov    rax,0xffffffffffffffff
    3dbc:	mov    rbx,QWORD PTR [rsp+0x40]
    3dc1:	mov    r12,QWORD PTR [rsp+0x48]
    3dc6:	mov    r13,QWORD PTR [rsp+0x50]
    3dcb:	mov    r14,QWORD PTR [rsp+0x58]
    3dd0:	mov    r15,QWORD PTR [rsp+0x60]
    3dd5:	add    rsp,0x70
    3dd9:	mov    rsp,rbp
    3ddc:	pop    rbp
    3ddd:	ret
    3dde:	add    BYTE PTR [rax],al
    3de0:	(bad)
    3de1:	add    BYTE PTR [rax],al
    3de3:	add    BYTE PTR [rax],al
    3de5:	add    BYTE PTR [rax],al
	...

0000000000003de8 <botlish_entry_32: domain_loop<generic>>:
    3de8:	push   rbp
    3de9:	mov    rbp,rsp
    3dec:	mov    rsi,QWORD PTR [rdx]
    3def:	mov    r8,QWORD PTR [rdx+0x8]
    3df3:	mov    rcx,QWORD PTR [rdx+0x10]
    3df7:	mov    rdx,r8
    3dfa:	call   3dff <botlish_entry_32+0x17>
			3dfb: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    3dff:	mov    rsp,rbp
    3e02:	pop    rbp
    3e03:	ret

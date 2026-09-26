; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 16791  (per function: 1172 39 337 617 74 74 74 125 125 155 125 214 484 864 516 1004 504 681 769 450 884 644 540 540 636 681 769 450 884 644 540 540 636)
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
     4d8:	cmovl  r8,QWORD PTR [rip+0xd8]        # 5b8 <botlish_fn_2+0x120>
     4e0:	jmp    4f9 <botlish_fn_2+0x61>
     4e5:	mov    rbx,rax
     4e8:	mov    r8d,0x2
     4ee:	test   rbx,rbx
     4f1:	cmovle r8,QWORD PTR [rip+0xbf]        # 5b8 <botlish_fn_2+0x120>
     4f9:	cmp    r8,0x6
     4fd:	je     585 <botlish_fn_2+0xed>
     503:	test   rbx,0x1
     50a:	jne    535 <botlish_fn_2+0x9d>
     510:	mov    edx,0x1ff
     515:	mov    rsi,rbx
     518:	mov    rdi,r12
     51b:	call   520 <botlish_fn_2+0x88>
			51c: R_X86_64_PLT32	rt_int_cmp-0x4
     520:	mov    ecx,0x2
     525:	test   rax,rax
     528:	cmovg  rcx,QWORD PTR [rip+0x88]        # 5b8 <botlish_fn_2+0x120>
     530:	jmp    549 <botlish_fn_2+0xb1>
     535:	mov    ecx,0x2
     53a:	cmp    rbx,0x1ff
     541:	cmovg  rcx,QWORD PTR [rip+0x6f]        # 5b8 <botlish_fn_2+0x120>
     549:	cmp    rcx,0x6
     54d:	je     568 <botlish_fn_2+0xd0>
     553:	mov    rax,rbx
     556:	mov    rbx,QWORD PTR [rsp]
     55a:	mov    r12,QWORD PTR [rsp+0x8]
     55f:	add    rsp,0x10
     563:	mov    rsp,rbp
     566:	pop    rbp
     567:	ret
     568:	mov    rdi,r12
     56b:	mov    rax,QWORD PTR [rdi+0x10]
     56f:	mov    rdx,QWORD PTR [rax+0xa0]
     576:	mov    esi,0x2
     57b:	call   580 <botlish_fn_2+0xe8>
			57c: R_X86_64_PLT32	rt_fail_declared-0x4
     580:	jmp    59d <botlish_fn_2+0x105>
     585:	mov    rdi,r12
     588:	mov    rax,QWORD PTR [rdi+0x10]
     58c:	mov    rdx,QWORD PTR [rax+0x98]
     593:	mov    esi,0x1
     598:	call   59d <botlish_fn_2+0x105>
			599: R_X86_64_PLT32	rt_fail_declared-0x4
     59d:	xor    rax,rax
     5a0:	mov    rbx,QWORD PTR [rsp]
     5a4:	mov    r12,QWORD PTR [rsp+0x8]
     5a9:	add    rsp,0x10
     5ad:	mov    rsp,rbp
     5b0:	pop    rbp
     5b1:	ret
     5b2:	add    BYTE PTR [rax],al
     5b4:	add    BYTE PTR [rax],al
     5b6:	add    BYTE PTR [rax],al
     5b8:	(bad)
     5b9:	add    BYTE PTR [rax],al
     5bb:	add    BYTE PTR [rax],al
     5bd:	add    BYTE PTR [rax],al
	...

00000000000005c0 <botlish_entry_2: byte::from_int<int>>:
     5c0:	push   rbp
     5c1:	mov    rbp,rsp
     5c4:	mov    rsi,QWORD PTR [rdx]
     5c7:	call   5cc <botlish_entry_2+0xc>
			5c8: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     5cc:	mov    rsp,rbp
     5cf:	pop    rbp
     5d0:	ret
     5d1:	add    BYTE PTR [rax],al
     5d3:	add    BYTE PTR [rax],al
     5d5:	add    BYTE PTR [rax],al
	...

00000000000005d8 <botlish_fn_3: byte::set<List[UnicodeChar]>>:
     5d8:	push   rbp
     5d9:	mov    rbp,rsp
     5dc:	sub    rsp,0x60
     5e0:	mov    QWORD PTR [rsp+0x30],rbx
     5e5:	mov    QWORD PTR [rsp+0x38],r12
     5ea:	mov    QWORD PTR [rsp+0x40],r13
     5ef:	mov    QWORD PTR [rsp+0x48],r14
     5f4:	mov    QWORD PTR [rsp+0x50],r15
     5f9:	mov    r13,rdi
     5fc:	mov    QWORD PTR [rsp+0x18],0x0
     605:	mov    QWORD PTR [rsp+0x20],0x0
     60e:	mov    QWORD PTR [rsp],rsi
     612:	mov    rbx,rsi
     615:	mov    rdi,r13
     618:	call   61d <botlish_fn_3+0x45>
			619: R_X86_64_PLT32	rt_list_len-0x4
     61d:	mov    QWORD PTR [rsp+0x8],rax
     622:	mov    r12,rax
     625:	mov    QWORD PTR [rsp+0x10],0x1
     62e:	xor    rdx,rdx
     631:	mov    rdi,r13
     634:	mov    rsi,rdx
     637:	call   63c <botlish_fn_3+0x64>
			638: R_X86_64_PLT32	rt_list_new-0x4
     63c:	test   rax,rax
     63f:	je     769 <botlish_fn_3+0x191>
     645:	mov    esi,0x1
     64a:	mov    r14,rsi
     64d:	mov    QWORD PTR [rsp+0x10],0x1
     656:	mov    QWORD PTR [rsp+0x18],rax
     65b:	mov    r15,rax
     65e:	mov    rax,rsi
     661:	and    rax,r12
     664:	mov    r14,rsi
     667:	test   rax,0x1
     66d:	jne    696 <botlish_fn_3+0xbe>
     673:	mov    rdx,r12
     676:	mov    rsi,r14
     679:	mov    rdi,r13
     67c:	call   681 <botlish_fn_3+0xa9>
			67d: R_X86_64_PLT32	rt_int_cmp-0x4
     681:	mov    ecx,0x2
     686:	test   rax,rax
     689:	cmovl  rcx,QWORD PTR [rip+0x16f]        # 800 <botlish_fn_3+0x228>
     691:	jmp    6a9 <botlish_fn_3+0xd1>
     696:	mov    ecx,0x2
     69b:	mov    rsi,r14
     69e:	cmp    rsi,r12
     6a1:	cmovl  rcx,QWORD PTR [rip+0x157]        # 800 <botlish_fn_3+0x228>
     6a9:	cmp    rcx,0x6
     6ad:	je     6e4 <botlish_fn_3+0x10c>
     6b3:	mov    rsi,r15
     6b6:	mov    QWORD PTR [rsp],rsi
     6ba:	mov    rdi,r13
     6bd:	call   6c2 <botlish_fn_3+0xea>
			6be: R_X86_64_PLT32	rt_set_from_list-0x4
     6c2:	mov    rbx,QWORD PTR [rsp+0x30]
     6c7:	mov    r12,QWORD PTR [rsp+0x38]
     6cc:	mov    r13,QWORD PTR [rsp+0x40]
     6d1:	mov    r14,QWORD PTR [rsp+0x48]
     6d6:	mov    r15,QWORD PTR [rsp+0x50]
     6db:	add    rsp,0x60
     6df:	mov    rsp,rbp
     6e2:	pop    rbp
     6e3:	ret
     6e4:	mov    rsi,r14
     6e7:	test   rsi,0x1
     6ee:	je     70a <botlish_fn_3+0x132>
     6f4:	mov    rcx,QWORD PTR [rbx+0x8]
     6f8:	mov    rsi,r14
     6fb:	mov    rax,rsi
     6fe:	sar    rax,1
     701:	cmp    rax,rcx
     704:	jb     729 <botlish_fn_3+0x151>
     70a:	mov    rdx,r14
     70d:	mov    rsi,rbx
     710:	mov    rdi,r13
     713:	call   718 <botlish_fn_3+0x140>
			714: R_X86_64_PLT32	rt_list_get-0x4
     718:	test   rax,rax
     71b:	je     769 <botlish_fn_3+0x191>
     721:	mov    rsi,rax
     724:	jmp    731 <botlish_fn_3+0x159>
     729:	mov    rsi,QWORD PTR [rbx+0x10]
     72d:	mov    rsi,QWORD PTR [rsi+rax*8]
     731:	mov    rdi,r13
     734:	call   739 <botlish_fn_3+0x161>
			735: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     739:	mov    rsi,rax
     73c:	mov    rdi,r13
     73f:	call   744 <botlish_fn_3+0x16c>
			740: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     744:	test   rax,rax
     747:	je     769 <botlish_fn_3+0x191>
     74d:	mov    QWORD PTR [rsp+0x20],rax
     752:	mov    rdx,rax
     755:	mov    rsi,r15
     758:	mov    rdi,r13
     75b:	call   760 <botlish_fn_3+0x188>
			75c: R_X86_64_PLT32	rt_list_append-0x4
     760:	test   rax,rax
     763:	jne    78e <botlish_fn_3+0x1b6>
     769:	xor    rax,rax
     76c:	mov    rbx,QWORD PTR [rsp+0x30]
     771:	mov    r12,QWORD PTR [rsp+0x38]
     776:	mov    r13,QWORD PTR [rsp+0x40]
     77b:	mov    r14,QWORD PTR [rsp+0x48]
     780:	mov    r15,QWORD PTR [rsp+0x50]
     785:	add    rsp,0x60
     789:	mov    rsp,rbp
     78c:	pop    rbp
     78d:	ret
     78e:	mov    QWORD PTR [rsp+0x18],rax
     793:	mov    r15,rax
     796:	mov    edx,0x3
     79b:	mov    QWORD PTR [rsp+0x20],0x3
     7a4:	mov    rsi,r14
     7a7:	test   rsi,0x1
     7ae:	jne    7bc <botlish_fn_3+0x1e4>
     7b4:	mov    rsi,r14
     7b7:	jmp    7e4 <botlish_fn_3+0x20c>
     7bc:	mov    rsi,r14
     7bf:	mov    rcx,rsi
     7c2:	add    rcx,0x2
     7c6:	seto   al
     7c9:	test   al,al
     7cb:	je     7d9 <botlish_fn_3+0x201>
     7d1:	mov    rsi,r14
     7d4:	jmp    7e4 <botlish_fn_3+0x20c>
     7d9:	mov    rsi,rcx
     7dc:	mov    r14,rcx
     7df:	jmp    7f2 <botlish_fn_3+0x21a>
     7e4:	mov    rdi,r13
     7e7:	call   7ec <botlish_fn_3+0x214>
			7e8: R_X86_64_PLT32	rt_int_add-0x4
     7ec:	mov    rsi,rax
     7ef:	mov    r14,rax
     7f2:	mov    QWORD PTR [rsp+0x10],rsi
     7f7:	mov    rsi,r14
     7fa:	jmp    65e <botlish_fn_3+0x86>
     7ff:	add    BYTE PTR [rsi],al
     801:	add    BYTE PTR [rax],al
     803:	add    BYTE PTR [rax],al
     805:	add    BYTE PTR [rax],al
	...

0000000000000808 <botlish_entry_3: byte::set<List[UnicodeChar]>>:
     808:	push   rbp
     809:	mov    rbp,rsp
     80c:	mov    rsi,QWORD PTR [rdx]
     80f:	call   814 <botlish_entry_3+0xc>
			810: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::set<List[UnicodeChar]>
     814:	mov    rsp,rbp
     817:	pop    rbp
     818:	ret

0000000000000819 <botlish_fn_4: ascii::is_digit<int>>:
     819:	push   rbp
     81a:	mov    rbp,rsp
     81d:	sar    rsi,1
     820:	cmp    rsi,0x30
     824:	jge    834 <botlish_fn_4+0x1b>
     82a:	mov    eax,0x2
     82f:	jmp    84d <botlish_fn_4+0x34>
     834:	cmp    rsi,0x39
     838:	jle    848 <botlish_fn_4+0x2f>
     83e:	mov    eax,0x2
     843:	jmp    84d <botlish_fn_4+0x34>
     848:	mov    eax,0x6
     84d:	mov    rsp,rbp
     850:	pop    rbp
     851:	ret

0000000000000852 <botlish_entry_4: ascii::is_digit<int>>:
     852:	push   rbp
     853:	mov    rbp,rsp
     856:	mov    rsi,QWORD PTR [rdx]
     859:	call   85e <botlish_entry_4+0xc>
			85a: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     85e:	mov    rsp,rbp
     861:	pop    rbp
     862:	ret

0000000000000863 <botlish_fn_5: ascii::is_upper<int>>:
     863:	push   rbp
     864:	mov    rbp,rsp
     867:	sar    rsi,1
     86a:	cmp    rsi,0x41
     86e:	jge    87e <botlish_fn_5+0x1b>
     874:	mov    eax,0x2
     879:	jmp    897 <botlish_fn_5+0x34>
     87e:	cmp    rsi,0x5a
     882:	jle    892 <botlish_fn_5+0x2f>
     888:	mov    eax,0x2
     88d:	jmp    897 <botlish_fn_5+0x34>
     892:	mov    eax,0x6
     897:	mov    rsp,rbp
     89a:	pop    rbp
     89b:	ret

000000000000089c <botlish_entry_5: ascii::is_upper<int>>:
     89c:	push   rbp
     89d:	mov    rbp,rsp
     8a0:	mov    rsi,QWORD PTR [rdx]
     8a3:	call   8a8 <botlish_entry_5+0xc>
			8a4: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     8a8:	mov    rsp,rbp
     8ab:	pop    rbp
     8ac:	ret

00000000000008ad <botlish_fn_6: ascii::is_lower<int>>:
     8ad:	push   rbp
     8ae:	mov    rbp,rsp
     8b1:	sar    rsi,1
     8b4:	cmp    rsi,0x61
     8b8:	jge    8c8 <botlish_fn_6+0x1b>
     8be:	mov    eax,0x2
     8c3:	jmp    8e1 <botlish_fn_6+0x34>
     8c8:	cmp    rsi,0x7a
     8cc:	jle    8dc <botlish_fn_6+0x2f>
     8d2:	mov    eax,0x2
     8d7:	jmp    8e1 <botlish_fn_6+0x34>
     8dc:	mov    eax,0x6
     8e1:	mov    rsp,rbp
     8e4:	pop    rbp
     8e5:	ret

00000000000008e6 <botlish_entry_6: ascii::is_lower<int>>:
     8e6:	push   rbp
     8e7:	mov    rbp,rsp
     8ea:	mov    rsi,QWORD PTR [rdx]
     8ed:	call   8f2 <botlish_entry_6+0xc>
			8ee: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     8f2:	mov    rsp,rbp
     8f5:	pop    rbp
     8f6:	ret

00000000000008f7 <botlish_fn_7: ascii::is_alphabetic<int>>:
     8f7:	push   rbp
     8f8:	mov    rbp,rsp
     8fb:	sub    rsp,0x10
     8ff:	mov    QWORD PTR [rsp],r12
     903:	mov    QWORD PTR [rsp+0x8],r14
     908:	mov    r12,rsi
     90b:	mov    r14,rdi
     90e:	mov    rsi,r12
     911:	mov    rdi,r14
     914:	call   919 <botlish_fn_7+0x22>
			915: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     919:	cmp    rax,0x6
     91d:	je     94c <botlish_fn_7+0x55>
     923:	mov    rsi,r12
     926:	mov    rdi,r14
     929:	call   92e <botlish_fn_7+0x37>
			92a: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     92e:	cmp    rax,0x6
     932:	je     942 <botlish_fn_7+0x4b>
     938:	mov    eax,0x2
     93d:	jmp    951 <botlish_fn_7+0x5a>
     942:	mov    eax,0x6
     947:	jmp    951 <botlish_fn_7+0x5a>
     94c:	mov    eax,0x6
     951:	mov    r12,QWORD PTR [rsp]
     955:	mov    r14,QWORD PTR [rsp+0x8]
     95a:	add    rsp,0x10
     95e:	mov    rsp,rbp
     961:	pop    rbp
     962:	ret

0000000000000963 <botlish_entry_7: ascii::is_alphabetic<int>>:
     963:	push   rbp
     964:	mov    rbp,rsp
     967:	mov    rsi,QWORD PTR [rdx]
     96a:	call   96f <botlish_entry_7+0xc>
			96b: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     96f:	mov    rsp,rbp
     972:	pop    rbp
     973:	ret

0000000000000974 <botlish_fn_8: ascii::is_alphanumeric<int>>:
     974:	push   rbp
     975:	mov    rbp,rsp
     978:	sub    rsp,0x10
     97c:	mov    QWORD PTR [rsp],r12
     980:	mov    QWORD PTR [rsp+0x8],r14
     985:	mov    r12,rsi
     988:	mov    r14,rdi
     98b:	mov    rsi,r12
     98e:	mov    rdi,r14
     991:	call   996 <botlish_fn_8+0x22>
			992: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     996:	cmp    rax,0x6
     99a:	je     9c9 <botlish_fn_8+0x55>
     9a0:	mov    rsi,r12
     9a3:	mov    rdi,r14
     9a6:	call   9ab <botlish_fn_8+0x37>
			9a7: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     9ab:	cmp    rax,0x6
     9af:	je     9bf <botlish_fn_8+0x4b>
     9b5:	mov    eax,0x2
     9ba:	jmp    9ce <botlish_fn_8+0x5a>
     9bf:	mov    eax,0x6
     9c4:	jmp    9ce <botlish_fn_8+0x5a>
     9c9:	mov    eax,0x6
     9ce:	mov    r12,QWORD PTR [rsp]
     9d2:	mov    r14,QWORD PTR [rsp+0x8]
     9d7:	add    rsp,0x10
     9db:	mov    rsp,rbp
     9de:	pop    rbp
     9df:	ret

00000000000009e0 <botlish_entry_8: ascii::is_alphanumeric<int>>:
     9e0:	push   rbp
     9e1:	mov    rbp,rsp
     9e4:	mov    rsi,QWORD PTR [rdx]
     9e7:	call   9ec <botlish_entry_8+0xc>
			9e8: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
     9ec:	mov    rsp,rbp
     9ef:	pop    rbp
     9f0:	ret

00000000000009f1 <botlish_fn_9: web::is_unreserved<generic>>:
     9f1:	push   rbp
     9f2:	mov    rbp,rsp
     9f5:	sub    rsp,0x20
     9f9:	mov    QWORD PTR [rsp],rbx
     9fd:	mov    QWORD PTR [rsp+0x8],r12
     a02:	mov    QWORD PTR [rsp+0x10],r14
     a07:	mov    rbx,rdi
     a0a:	mov    r12,rsi
     a0d:	mov    r14,rdx
     a10:	mov    rsi,r14
     a13:	mov    rdi,rbx
     a16:	call   a1b <botlish_fn_9+0x2a>
			a17: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
     a1b:	cmp    rax,0x6
     a1f:	je     a58 <botlish_fn_9+0x67>
     a25:	mov    rsi,r12
     a28:	mov    rax,QWORD PTR [rsi+0x20]
     a2c:	mov    rsi,QWORD PTR [rax]
     a2f:	mov    rdx,r14
     a32:	mov    rdi,rbx
     a35:	call   a3a <botlish_fn_9+0x49>
			a36: R_X86_64_PLT32	rt_set_contains-0x4
     a3a:	cmp    rax,0x6
     a3e:	je     a4e <botlish_fn_9+0x5d>
     a44:	mov    eax,0x2
     a49:	jmp    a5d <botlish_fn_9+0x6c>
     a4e:	mov    eax,0x6
     a53:	jmp    a5d <botlish_fn_9+0x6c>
     a58:	mov    eax,0x6
     a5d:	mov    rbx,QWORD PTR [rsp]
     a61:	mov    r12,QWORD PTR [rsp+0x8]
     a66:	mov    r14,QWORD PTR [rsp+0x10]
     a6b:	add    rsp,0x20
     a6f:	mov    rsp,rbp
     a72:	pop    rbp
     a73:	ret

0000000000000a74 <botlish_entry_9: web::is_unreserved<generic>>:
     a74:	push   rbp
     a75:	mov    rbp,rsp
     a78:	mov    rdx,QWORD PTR [rdx]
     a7b:	call   a80 <botlish_entry_9+0xc>
			a7c: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_unreserved<generic>
     a80:	mov    rsp,rbp
     a83:	pop    rbp
     a84:	ret

0000000000000a85 <botlish_fn_10: web::uri_escape_text<generic>>:
     a85:	push   rbp
     a86:	mov    rbp,rsp
     a89:	sub    rsp,0x30
     a8d:	mov    QWORD PTR [rsp],rdx
     a91:	mov    r10,rdx
     a94:	mov    edx,0x1
     a99:	mov    QWORD PTR [rsp+0x8],0x1
     aa2:	mov    rax,QWORD PTR [rdi+0x10]
     aa6:	mov    rcx,QWORD PTR [rax+0xa8]
     aad:	mov    QWORD PTR [rsp+0x10],rcx
     ab2:	mov    rax,QWORD PTR [rsi+0x20]
     ab6:	mov    r8,QWORD PTR [rax+0x8]
     aba:	mov    QWORD PTR [rsp+0x18],r8
     abf:	mov    rax,QWORD PTR [rsi+0x20]
     ac3:	mov    r9,QWORD PTR [rax]
     ac6:	mov    QWORD PTR [rsp+0x20],r9
     acb:	mov    rsi,r10
     ace:	call   ad3 <botlish_fn_10+0x4e>
			acf: R_X86_64_PLT32	botlish_fn_15-0x4 ; esc_from<generic>
     ad3:	test   rax,rax
     ad6:	jne    ae8 <botlish_fn_10+0x63>
     adc:	xor    rax,rax
     adf:	add    rsp,0x30
     ae3:	mov    rsp,rbp
     ae6:	pop    rbp
     ae7:	ret
     ae8:	add    rsp,0x30
     aec:	mov    rsp,rbp
     aef:	pop    rbp
     af0:	ret

0000000000000af1 <botlish_entry_10: web::uri_escape_text<generic>>:
     af1:	push   rbp
     af2:	mov    rbp,rsp
     af5:	mov    rdx,QWORD PTR [rdx]
     af8:	call   afd <botlish_entry_10+0xc>
			af9: R_X86_64_PLT32	botlish_fn_10-0x4 ; web::uri_escape_text<generic>
     afd:	mov    rsp,rbp
     b00:	pop    rbp
     b01:	ret

0000000000000b02 <botlish_fn_11: high_nibble<generic>>:
     b02:	push   rbp
     b03:	mov    rbp,rsp
     b06:	sub    rsp,0x20
     b0a:	mov    QWORD PTR [rsp+0x10],rbx
     b0f:	mov    QWORD PTR [rsp],rsi
     b13:	mov    QWORD PTR [rsp+0x8],0x1e1
     b1c:	mov    r8d,0x1
     b22:	test   rsi,0x1
     b29:	jne    b49 <botlish_fn_11+0x47>
     b2f:	xor    r8d,r8d
     b32:	test   rsi,0x7
     b39:	jne    b49 <botlish_fn_11+0x47>
     b3f:	movzx  rax,BYTE PTR [rsi]
     b43:	cmp    al,0x1
     b45:	sete   r8b
     b49:	test   r8b,r8b
     b4c:	jne    b79 <botlish_fn_11+0x77>
     b52:	mov    rax,QWORD PTR [rdi+0x10]
     b56:	mov    rcx,QWORD PTR [rax+0xb0]
     b5d:	xor    rbx,rbx
     b60:	mov    rdx,rbx
     b63:	call   b68 <botlish_fn_11+0x66>
			b64: R_X86_64_PLT32	rt_type_error-0x4
     b68:	mov    rax,rbx
     b6b:	mov    rbx,QWORD PTR [rsp+0x10]
     b70:	add    rsp,0x20
     b74:	mov    rsp,rbp
     b77:	pop    rbp
     b78:	ret
     b79:	test   rsi,0x1
     b80:	jne    b95 <botlish_fn_11+0x93>
     b86:	mov    edx,0x1e1
     b8b:	call   b90 <botlish_fn_11+0x8e>
			b8c: R_X86_64_PLT32	rt_int_and-0x4
     b90:	jmp    b9f <botlish_fn_11+0x9d>
     b95:	and    rsi,0x1e1
     b9c:	mov    rax,rsi
     b9f:	sar    rax,0x5
     ba3:	shl    rax,1
     ba6:	or     rax,0x1
     baa:	mov    rbx,QWORD PTR [rsp+0x10]
     baf:	add    rsp,0x20
     bb3:	mov    rsp,rbp
     bb6:	pop    rbp
     bb7:	ret

0000000000000bb8 <botlish_entry_11: high_nibble<generic>>:
     bb8:	push   rbp
     bb9:	mov    rbp,rsp
     bbc:	mov    rsi,QWORD PTR [rdx]
     bbf:	call   bc4 <botlish_entry_11+0xc>
			bc0: R_X86_64_PLT32	botlish_fn_11-0x4 ; high_nibble<generic>
     bc4:	mov    rsp,rbp
     bc7:	pop    rbp
     bc8:	ret

0000000000000bc9 <botlish_fn_12: hex_pair<generic>>:
     bc9:	push   rbp
     bca:	mov    rbp,rsp
     bcd:	sub    rsp,0x30
     bd1:	mov    QWORD PTR [rsp+0x10],rbx
     bd6:	mov    QWORD PTR [rsp+0x18],r12
     bdb:	mov    QWORD PTR [rsp+0x20],r13
     be0:	mov    QWORD PTR [rsp+0x28],r14
     be5:	mov    r12,rdi
     be8:	mov    QWORD PTR [rsp],rsi
     bec:	mov    r13,rsi
     bef:	mov    QWORD PTR [rsp+0x8],rdx
     bf4:	mov    rbx,rdx
     bf7:	mov    rsi,r13
     bfa:	mov    rdi,r12
     bfd:	call   c02 <botlish_fn_12+0x39>
			bfe: R_X86_64_PLT32	botlish_fn_11-0x4 ; high_nibble<generic>
     c02:	test   rax,rax
     c05:	je     d33 <botlish_fn_12+0x16a>
     c0b:	test   rax,0x1
     c11:	jne    c1f <botlish_fn_12+0x56>
     c17:	mov    rdx,rax
     c1a:	jmp    c35 <botlish_fn_12+0x6c>
     c1f:	mov    rdx,QWORD PTR [rbx+0x8]
     c23:	mov    rcx,rax
     c26:	sar    rcx,1
     c29:	cmp    rcx,rdx
     c2c:	jb     c51 <botlish_fn_12+0x88>
     c32:	mov    rdx,rax
     c35:	mov    rsi,rbx
     c38:	mov    rdi,r12
     c3b:	call   c40 <botlish_fn_12+0x77>
			c3c: R_X86_64_PLT32	rt_list_get-0x4
     c40:	test   rax,rax
     c43:	je     d33 <botlish_fn_12+0x16a>
     c49:	mov    rsi,rax
     c4c:	jmp    c59 <botlish_fn_12+0x90>
     c51:	mov    rax,QWORD PTR [rbx+0x10]
     c55:	mov    rsi,QWORD PTR [rax+rcx*8]
     c59:	mov    QWORD PTR [rsp],rsi
     c5d:	mov    r14,rsi
     c60:	mov    ecx,0x1
     c65:	mov    rsi,r13
     c68:	test   rsi,0x1
     c6f:	jne    c8d <botlish_fn_12+0xc4>
     c75:	xor    ecx,ecx
     c77:	test   rsi,0x7
     c7e:	jne    c8d <botlish_fn_12+0xc4>
     c84:	movzx  rax,BYTE PTR [rsi]
     c88:	cmp    al,0x1
     c8a:	sete   cl
     c8d:	test   cl,cl
     c8f:	jne    cb0 <botlish_fn_12+0xe7>
     c95:	mov    rdi,r12
     c98:	mov    rax,QWORD PTR [rdi+0x10]
     c9c:	mov    rcx,QWORD PTR [rax+0xb8]
     ca3:	xor    rdx,rdx
     ca6:	call   cab <botlish_fn_12+0xe2>
			ca7: R_X86_64_PLT32	rt_type_error-0x4
     cab:	jmp    d33 <botlish_fn_12+0x16a>
     cb0:	mov    edx,0x21
     cb5:	mov    rdi,r12
     cb8:	call   cbd <botlish_fn_12+0xf4>
			cb9: R_X86_64_PLT32	rt_int_mod-0x4
     cbd:	test   rax,rax
     cc0:	je     d33 <botlish_fn_12+0x16a>
     cc6:	test   rax,0x1
     ccc:	jne    cdd <botlish_fn_12+0x114>
     cd2:	mov    rdx,rax
     cd5:	mov    rsi,rbx
     cd8:	jmp    cf6 <botlish_fn_12+0x12d>
     cdd:	mov    rdi,QWORD PTR [rbx+0x8]
     ce1:	mov    rsi,rax
     ce4:	sar    rsi,1
     ce7:	mov    rdx,rax
     cea:	cmp    rsi,rdi
     ced:	jb     d0f <botlish_fn_12+0x146>
     cf3:	mov    rsi,rbx
     cf6:	mov    rdi,r12
     cf9:	call   cfe <botlish_fn_12+0x135>
			cfa: R_X86_64_PLT32	rt_list_get-0x4
     cfe:	test   rax,rax
     d01:	je     d33 <botlish_fn_12+0x16a>
     d07:	mov    rdx,rax
     d0a:	jmp    d1a <botlish_fn_12+0x151>
     d0f:	mov    rax,rbx
     d12:	mov    rax,QWORD PTR [rax+0x10]
     d16:	mov    rdx,QWORD PTR [rax+rsi*8]
     d1a:	mov    QWORD PTR [rsp+0x8],rdx
     d1f:	mov    rsi,r14
     d22:	mov    rdi,r12
     d25:	call   d2a <botlish_fn_12+0x161>
			d26: R_X86_64_PLT32	rt_str_cat-0x4
     d2a:	test   rax,rax
     d2d:	jne    d53 <botlish_fn_12+0x18a>
     d33:	xor    rax,rax
     d36:	mov    rbx,QWORD PTR [rsp+0x10]
     d3b:	mov    r12,QWORD PTR [rsp+0x18]
     d40:	mov    r13,QWORD PTR [rsp+0x20]
     d45:	mov    r14,QWORD PTR [rsp+0x28]
     d4a:	add    rsp,0x30
     d4e:	mov    rsp,rbp
     d51:	pop    rbp
     d52:	ret
     d53:	mov    rbx,QWORD PTR [rsp+0x10]
     d58:	mov    r12,QWORD PTR [rsp+0x18]
     d5d:	mov    r13,QWORD PTR [rsp+0x20]
     d62:	mov    r14,QWORD PTR [rsp+0x28]
     d67:	add    rsp,0x30
     d6b:	mov    rsp,rbp
     d6e:	pop    rbp
     d6f:	ret

0000000000000d70 <botlish_entry_12: hex_pair<generic>>:
     d70:	push   rbp
     d71:	mov    rbp,rsp
     d74:	mov    rsi,QWORD PTR [rdx]
     d77:	mov    rdx,QWORD PTR [rdx+0x8]
     d7b:	call   d80 <botlish_entry_12+0x10>
			d7c: R_X86_64_PLT32	botlish_fn_12-0x4 ; hex_pair<generic>
     d80:	mov    rsp,rbp
     d83:	pop    rbp
     d84:	ret
     d85:	add    BYTE PTR [rax],al
	...

0000000000000d88 <botlish_fn_13: esc_bytes<generic>>:
     d88:	push   rbp
     d89:	mov    rbp,rsp
     d8c:	sub    rsp,0x70
     d90:	mov    QWORD PTR [rsp+0x40],rbx
     d95:	mov    QWORD PTR [rsp+0x48],r12
     d9a:	mov    QWORD PTR [rsp+0x50],r13
     d9f:	mov    QWORD PTR [rsp+0x58],r14
     da4:	mov    QWORD PTR [rsp+0x60],r15
     da9:	mov    r13,rdi
     dac:	mov    QWORD PTR [rsp+0x28],0x0
     db5:	mov    QWORD PTR [rsp],rsi
     db9:	mov    QWORD PTR [rsp+0x8],rdx
     dbe:	mov    QWORD PTR [rsp+0x10],rcx
     dc3:	mov    QWORD PTR [rsp+0x18],r8
     dc8:	mov    r12,r8
     dcb:	mov    r14,rcx
     dce:	mov    r15,rdx
     dd1:	xor    eax,eax
     dd3:	test   rsi,0x7
     dda:	jne    deb <botlish_fn_13+0x63>
     de0:	movzx  r8,BYTE PTR [rsi]
     de4:	cmp    r8b,0x3
     de8:	sete   al
     deb:	test   al,al
     ded:	jne    e10 <botlish_fn_13+0x88>
     df3:	mov    rdi,r13
     df6:	mov    rax,QWORD PTR [rdi+0x10]
     dfa:	mov    rcx,QWORD PTR [rax+0xc0]
     e01:	mov    edx,0x4
     e06:	call   e0b <botlish_fn_13+0x83>
			e07: R_X86_64_PLT32	rt_type_error-0x4
     e0b:	jmp    1016 <botlish_fn_13+0x28e>
     e10:	mov    rbx,rsi
     e13:	mov    rdi,r13
     e16:	call   e1b <botlish_fn_13+0x93>
			e17: R_X86_64_PLT32	rt_list_len-0x4
     e1b:	mov    ecx,0x1
     e20:	mov    rsi,r15
     e23:	test   rsi,0x1
     e2a:	jne    e50 <botlish_fn_13+0xc8>
     e30:	xor    ecx,ecx
     e32:	mov    rsi,r15
     e35:	test   rsi,0x7
     e3c:	jne    e50 <botlish_fn_13+0xc8>
     e42:	mov    rsi,r15
     e45:	movzx  rcx,BYTE PTR [rsi]
     e49:	rex cmp cl,0x1
     e4d:	sete   cl
     e50:	test   cl,cl
     e52:	jne    e76 <botlish_fn_13+0xee>
     e58:	mov    rdi,r13
     e5b:	mov    rax,QWORD PTR [rdi+0x10]
     e5f:	mov    rcx,QWORD PTR [rax+0xc8]
     e66:	xor    rdx,rdx
     e69:	mov    rsi,r15
     e6c:	call   e71 <botlish_fn_13+0xe9>
			e6d: R_X86_64_PLT32	rt_type_error-0x4
     e71:	jmp    1016 <botlish_fn_13+0x28e>
     e76:	mov    rsi,r15
     e79:	mov    rcx,rsi
     e7c:	and    rcx,rax
     e7f:	mov    rdx,rax
     e82:	test   rcx,0x1
     e89:	jne    eaf <botlish_fn_13+0x127>
     e8f:	mov    rsi,r15
     e92:	mov    rdi,r13
     e95:	call   e9a <botlish_fn_13+0x112>
			e96: R_X86_64_PLT32	rt_int_cmp-0x4
     e9a:	mov    ecx,0x2
     e9f:	test   rax,rax
     ea2:	cmovge rcx,QWORD PTR [rip+0x1de]        # 1088 <botlish_fn_13+0x300>
     eaa:	jmp    ec2 <botlish_fn_13+0x13a>
     eaf:	mov    ecx,0x2
     eb4:	mov    rsi,r15
     eb7:	cmp    rsi,rdx
     eba:	cmovge rcx,QWORD PTR [rip+0x1c6]        # 1088 <botlish_fn_13+0x300>
     ec2:	cmp    rcx,0x6
     ec6:	je     1061 <botlish_fn_13+0x2d9>
     ecc:	mov    QWORD PTR [rsp+0x20],0x3
     ed5:	mov    rsi,r15
     ed8:	test   rsi,0x1
     edf:	je     efa <botlish_fn_13+0x172>
     ee5:	mov    rsi,r15
     ee8:	mov    rax,rsi
     eeb:	add    rax,0x2
     eef:	seto   cl
     ef2:	test   cl,cl
     ef4:	je     f0a <botlish_fn_13+0x182>
     efa:	mov    edx,0x3
     eff:	mov    rsi,r15
     f02:	mov    rdi,r13
     f05:	call   f0a <botlish_fn_13+0x182>
			f06: R_X86_64_PLT32	rt_int_add-0x4
     f0a:	mov    QWORD PTR [rsp+0x8],rax
     f0f:	mov    rdi,r13
     f12:	mov    QWORD PTR [rsp+0x30],rax
     f17:	mov    rax,QWORD PTR [rdi+0x10]
     f1b:	mov    rsi,QWORD PTR [rax+0xd0]
     f22:	mov    QWORD PTR [rsp+0x20],rsi
     f27:	mov    QWORD PTR [rsp+0x38],rsi
     f2c:	mov    rsi,r15
     f2f:	test   rsi,0x1
     f36:	jne    f44 <botlish_fn_13+0x1bc>
     f3c:	mov    rdx,r15
     f3f:	jmp    f5d <botlish_fn_13+0x1d5>
     f44:	mov    rcx,QWORD PTR [rbx+0x8]
     f48:	mov    rsi,r15
     f4b:	mov    rax,rsi
     f4e:	sar    rax,1
     f51:	cmp    rax,rcx
     f54:	jb     f79 <botlish_fn_13+0x1f1>
     f5a:	mov    rdx,r15
     f5d:	mov    rsi,rbx
     f60:	mov    rdi,r13
     f63:	call   f68 <botlish_fn_13+0x1e0>
			f64: R_X86_64_PLT32	rt_list_get-0x4
     f68:	test   rax,rax
     f6b:	je     1016 <botlish_fn_13+0x28e>
     f71:	mov    rsi,rax
     f74:	jmp    f81 <botlish_fn_13+0x1f9>
     f79:	mov    rcx,QWORD PTR [rbx+0x10]
     f7d:	mov    rsi,QWORD PTR [rcx+rax*8]
     f81:	mov    QWORD PTR [rsp+0x28],rsi
     f86:	mov    rdx,r12
     f89:	mov    rdi,r13
     f8c:	call   f91 <botlish_fn_13+0x209>
			f8d: R_X86_64_PLT32	botlish_fn_12-0x4 ; hex_pair<generic>
     f91:	test   rax,rax
     f94:	je     1016 <botlish_fn_13+0x28e>
     f9a:	mov    QWORD PTR [rsp+0x28],rax
     f9f:	mov    rdx,rax
     fa2:	mov    rsi,QWORD PTR [rsp+0x38]
     fa7:	mov    rdi,r13
     faa:	call   faf <botlish_fn_13+0x227>
			fab: R_X86_64_PLT32	rt_str_cat-0x4
     faf:	test   rax,rax
     fb2:	je     1016 <botlish_fn_13+0x28e>
     fb8:	mov    QWORD PTR [rsp+0x20],rax
     fbd:	mov    rdx,rax
     fc0:	xor    eax,eax
     fc2:	mov    rsi,r14
     fc5:	test   rsi,0x7
     fcc:	jne    fdd <botlish_fn_13+0x255>
     fd2:	movzx  rdi,BYTE PTR [rsi]
     fd6:	cmp    dil,0x2
     fda:	sete   al
     fdd:	test   al,al
     fdf:	jne    1005 <botlish_fn_13+0x27d>
     fe5:	mov    rdi,r13
     fe8:	mov    rdi,QWORD PTR [rdi+0x10]
     fec:	mov    rcx,QWORD PTR [rdi+0xd8]
     ff3:	mov    edx,0x1
     ff8:	mov    rdi,r13
     ffb:	call   1000 <botlish_fn_13+0x278>
			ffc: R_X86_64_PLT32	rt_type_error-0x4
    1000:	jmp    1016 <botlish_fn_13+0x28e>
    1005:	mov    rdi,r13
    1008:	call   100d <botlish_fn_13+0x285>
			1009: R_X86_64_PLT32	rt_str_cat-0x4
    100d:	test   rax,rax
    1010:	jne    103b <botlish_fn_13+0x2b3>
    1016:	xor    rax,rax
    1019:	mov    rbx,QWORD PTR [rsp+0x40]
    101e:	mov    r12,QWORD PTR [rsp+0x48]
    1023:	mov    r13,QWORD PTR [rsp+0x50]
    1028:	mov    r14,QWORD PTR [rsp+0x58]
    102d:	mov    r15,QWORD PTR [rsp+0x60]
    1032:	add    rsp,0x70
    1036:	mov    rsp,rbp
    1039:	pop    rbp
    103a:	ret
    103b:	mov    QWORD PTR [rsp],rbx
    103f:	mov    rcx,QWORD PTR [rsp+0x30]
    1044:	mov    QWORD PTR [rsp+0x8],rcx
    1049:	mov    QWORD PTR [rsp+0x10],rax
    104e:	mov    QWORD PTR [rsp+0x18],r12
    1053:	mov    rsi,rbx
    1056:	mov    r14,rax
    1059:	mov    r15,rcx
    105c:	jmp    dd1 <botlish_fn_13+0x49>
    1061:	mov    rax,r14
    1064:	mov    rbx,QWORD PTR [rsp+0x40]
    1069:	mov    r12,QWORD PTR [rsp+0x48]
    106e:	mov    r13,QWORD PTR [rsp+0x50]
    1073:	mov    r14,QWORD PTR [rsp+0x58]
    1078:	mov    r15,QWORD PTR [rsp+0x60]
    107d:	add    rsp,0x70
    1081:	mov    rsp,rbp
    1084:	pop    rbp
    1085:	ret
    1086:	add    BYTE PTR [rax],al
    1088:	(bad)
    1089:	add    BYTE PTR [rax],al
    108b:	add    BYTE PTR [rax],al
    108d:	add    BYTE PTR [rax],al
	...

0000000000001090 <botlish_entry_13: esc_bytes<generic>>:
    1090:	push   rbp
    1091:	mov    rbp,rsp
    1094:	mov    rsi,QWORD PTR [rdx]
    1097:	mov    r9,QWORD PTR [rdx+0x8]
    109b:	mov    rcx,QWORD PTR [rdx+0x10]
    109f:	mov    r8,QWORD PTR [rdx+0x18]
    10a3:	mov    rdx,r9
    10a6:	call   10ab <botlish_entry_13+0x1b>
			10a7: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    10ab:	mov    rsp,rbp
    10ae:	pop    rbp
    10af:	ret

00000000000010b0 <botlish_fn_14: esc_char<generic>>:
    10b0:	push   rbp
    10b1:	mov    rbp,rsp
    10b4:	sub    rsp,0x60
    10b8:	mov    QWORD PTR [rsp+0x30],rbx
    10bd:	mov    QWORD PTR [rsp+0x38],r12
    10c2:	mov    QWORD PTR [rsp+0x40],r13
    10c7:	mov    QWORD PTR [rsp+0x48],r14
    10cc:	mov    QWORD PTR [rsp+0x50],r15
    10d1:	mov    QWORD PTR [rsp+0x18],0x0
    10da:	mov    QWORD PTR [rsp],rsi
    10de:	mov    QWORD PTR [rsp+0x8],rdx
    10e3:	mov    r12,rdx
    10e6:	mov    QWORD PTR [rsp+0x10],rcx
    10eb:	mov    rbx,rcx
    10ee:	xor    r10d,r10d
    10f1:	test   rsi,0x7
    10f8:	jne    1108 <botlish_fn_14+0x58>
    10fe:	movzx  rax,BYTE PTR [rsi]
    1102:	cmp    al,0x2
    1104:	sete   r10b
    1108:	test   r10b,r10b
    110b:	jne    112b <botlish_fn_14+0x7b>
    1111:	mov    rax,QWORD PTR [rdi+0x10]
    1115:	mov    rcx,QWORD PTR [rax+0xe0]
    111c:	mov    edx,0x1
    1121:	call   1126 <botlish_fn_14+0x76>
			1122: R_X86_64_PLT32	rt_type_error-0x4
    1126:	jmp    122a <botlish_fn_14+0x17a>
    112b:	mov    r13,rdi
    112e:	mov    QWORD PTR [rsp+0x20],rsi
    1133:	call   1138 <botlish_fn_14+0x88>
			1134: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1138:	mov    rcx,rax
    113b:	mov    r14,rax
    113e:	test   rax,rcx
    1141:	je     122a <botlish_fn_14+0x17a>
    1147:	mov    rax,r14
    114a:	mov    QWORD PTR [rsp],rax
    114e:	mov    rsi,r14
    1151:	mov    rdi,r13
    1154:	call   1159 <botlish_fn_14+0xa9>
			1155: R_X86_64_PLT32	rt_list_len-0x4
    1159:	mov    edx,0x1
    115e:	sar    rax,1
    1161:	cmp    rax,0x1
    1165:	je     11a0 <botlish_fn_14+0xf0>
    116b:	mov    QWORD PTR [rsp+0x8],0x1
    1174:	mov    rdi,r13
    1177:	mov    rax,QWORD PTR [rdi+0x10]
    117b:	mov    rcx,QWORD PTR [rax+0xa8]
    1182:	mov    QWORD PTR [rsp+0x18],rcx
    1187:	mov    rsi,r14
    118a:	mov    r8,rbx
    118d:	call   1192 <botlish_fn_14+0xe2>
			118e: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    1192:	test   rax,rax
    1195:	je     122a <botlish_fn_14+0x17a>
    119b:	jmp    1259 <botlish_fn_14+0x1a9>
    11a0:	mov    rsi,r14
    11a3:	mov    r15,rdx
    11a6:	mov    rax,QWORD PTR [rsi+0x8]
    11aa:	mov    r14,rsi
    11ad:	test   rax,rax
    11b0:	jne    11d8 <botlish_fn_14+0x128>
    11b6:	mov    rdx,r15
    11b9:	mov    rsi,r14
    11bc:	mov    rdi,r13
    11bf:	call   11c4 <botlish_fn_14+0x114>
			11c0: R_X86_64_PLT32	rt_list_get-0x4
    11c4:	test   rax,rax
    11c7:	je     122a <botlish_fn_14+0x17a>
    11cd:	mov    rdx,rax
    11d0:	mov    rsi,r12
    11d3:	jmp    11e5 <botlish_fn_14+0x135>
    11d8:	mov    rsi,r14
    11db:	mov    rdx,QWORD PTR [rsi+0x10]
    11df:	mov    rdx,QWORD PTR [rdx]
    11e2:	mov    rsi,r12
    11e5:	mov    rdi,r13
    11e8:	call   11ed <botlish_fn_14+0x13d>
			11e9: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_unreserved<generic>
    11ed:	cmp    rax,0x6
    11f1:	je     1254 <botlish_fn_14+0x1a4>
    11f7:	mov    QWORD PTR [rsp+0x8],0x1
    1200:	mov    rdi,r13
    1203:	mov    rsi,QWORD PTR [rdi+0x10]
    1207:	mov    rcx,QWORD PTR [rsi+0xa8]
    120e:	mov    QWORD PTR [rsp+0x18],rcx
    1213:	mov    rdx,r15
    1216:	mov    rsi,r14
    1219:	mov    r8,rbx
    121c:	call   1221 <botlish_fn_14+0x171>
			121d: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    1221:	test   rax,rax
    1224:	jne    124f <botlish_fn_14+0x19f>
    122a:	xor    rax,rax
    122d:	mov    rbx,QWORD PTR [rsp+0x30]
    1232:	mov    r12,QWORD PTR [rsp+0x38]
    1237:	mov    r13,QWORD PTR [rsp+0x40]
    123c:	mov    r14,QWORD PTR [rsp+0x48]
    1241:	mov    r15,QWORD PTR [rsp+0x50]
    1246:	add    rsp,0x60
    124a:	mov    rsp,rbp
    124d:	pop    rbp
    124e:	ret
    124f:	mov    QWORD PTR [rsp+0x20],rax
    1254:	mov    rax,QWORD PTR [rsp+0x20]
    1259:	mov    rbx,QWORD PTR [rsp+0x30]
    125e:	mov    r12,QWORD PTR [rsp+0x38]
    1263:	mov    r13,QWORD PTR [rsp+0x40]
    1268:	mov    r14,QWORD PTR [rsp+0x48]
    126d:	mov    r15,QWORD PTR [rsp+0x50]
    1272:	add    rsp,0x60
    1276:	mov    rsp,rbp
    1279:	pop    rbp
    127a:	ret

000000000000127b <botlish_entry_14: esc_char<generic>>:
    127b:	push   rbp
    127c:	mov    rbp,rsp
    127f:	mov    rsi,QWORD PTR [rdx]
    1282:	mov    r8,QWORD PTR [rdx+0x8]
    1286:	mov    rcx,QWORD PTR [rdx+0x10]
    128a:	mov    rdx,r8
    128d:	call   1292 <botlish_entry_14+0x17>
			128e: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_char<generic>
    1292:	mov    rsp,rbp
    1295:	pop    rbp
    1296:	ret
	...

0000000000001298 <botlish_fn_15: esc_from<generic>>:
    1298:	push   rbp
    1299:	mov    rbp,rsp
    129c:	sub    rsp,0x80
    12a3:	mov    QWORD PTR [rsp+0x50],rbx
    12a8:	mov    QWORD PTR [rsp+0x58],r12
    12ad:	mov    QWORD PTR [rsp+0x60],r13
    12b2:	mov    QWORD PTR [rsp+0x68],r14
    12b7:	mov    QWORD PTR [rsp+0x70],r15
    12bc:	mov    r14,rdi
    12bf:	mov    QWORD PTR [rsp+0x30],0x0
    12c8:	mov    QWORD PTR [rsp],rsi
    12cc:	mov    QWORD PTR [rsp+0x8],rdx
    12d1:	mov    QWORD PTR [rsp+0x10],rcx
    12d6:	mov    QWORD PTR [rsp+0x18],r8
    12db:	mov    r13,r8
    12de:	mov    QWORD PTR [rsp+0x20],r9
    12e3:	mov    r12,r9
    12e6:	mov    r15,rcx
    12e9:	mov    QWORD PTR [rsp+0x38],rdx
    12ee:	xor    eax,eax
    12f0:	test   rsi,0x7
    12f7:	jne    1306 <botlish_fn_15+0x6e>
    12fd:	movzx  rax,BYTE PTR [rsi]
    1301:	cmp    al,0x2
    1303:	sete   al
    1306:	test   al,al
    1308:	jne    132b <botlish_fn_15+0x93>
    130e:	mov    rdi,r14
    1311:	mov    rax,QWORD PTR [rdi+0x10]
    1315:	mov    rcx,QWORD PTR [rax+0xe8]
    131c:	mov    edx,0x1
    1321:	call   1326 <botlish_fn_15+0x8e>
			1322: R_X86_64_PLT32	rt_type_error-0x4
    1326:	jmp    1583 <botlish_fn_15+0x2eb>
    132b:	mov    rbx,rsi
    132e:	mov    rdi,r14
    1331:	call   1336 <botlish_fn_15+0x9e>
			1332: R_X86_64_PLT32	rt_str_len-0x4
    1336:	mov    edx,0x1
    133b:	mov    QWORD PTR [rsp+0x48],rdx
    1340:	mov    ecx,0x1
    1345:	mov    rsi,QWORD PTR [rsp+0x38]
    134a:	test   rsi,0x1
    1351:	jne    137b <botlish_fn_15+0xe3>
    1357:	xor    ecx,ecx
    1359:	mov    rsi,QWORD PTR [rsp+0x38]
    135e:	test   rsi,0x7
    1365:	jne    137b <botlish_fn_15+0xe3>
    136b:	mov    rsi,QWORD PTR [rsp+0x38]
    1370:	movzx  rcx,BYTE PTR [rsi]
    1374:	rex cmp cl,0x1
    1378:	sete   cl
    137b:	test   cl,cl
    137d:	jne    13a3 <botlish_fn_15+0x10b>
    1383:	mov    rdi,r14
    1386:	mov    rax,QWORD PTR [rdi+0x10]
    138a:	mov    rcx,QWORD PTR [rax+0xc8]
    1391:	xor    rdx,rdx
    1394:	mov    rsi,QWORD PTR [rsp+0x38]
    1399:	call   139e <botlish_fn_15+0x106>
			139a: R_X86_64_PLT32	rt_type_error-0x4
    139e:	jmp    1583 <botlish_fn_15+0x2eb>
    13a3:	mov    rsi,QWORD PTR [rsp+0x38]
    13a8:	mov    rcx,rsi
    13ab:	and    rcx,rax
    13ae:	mov    rdx,rax
    13b1:	test   rcx,0x1
    13b8:	jne    13e0 <botlish_fn_15+0x148>
    13be:	mov    rsi,QWORD PTR [rsp+0x38]
    13c3:	mov    rdi,r14
    13c6:	call   13cb <botlish_fn_15+0x133>
			13c7: R_X86_64_PLT32	rt_int_cmp-0x4
    13cb:	mov    ecx,0x2
    13d0:	test   rax,rax
    13d3:	cmovge rcx,QWORD PTR [rip+0x235]        # 1610 <botlish_fn_15+0x378>
    13db:	jmp    13f5 <botlish_fn_15+0x15d>
    13e0:	mov    ecx,0x2
    13e5:	mov    rsi,QWORD PTR [rsp+0x38]
    13ea:	cmp    rsi,rdx
    13ed:	cmovge rcx,QWORD PTR [rip+0x21b]        # 1610 <botlish_fn_15+0x378>
    13f5:	cmp    rcx,0x6
    13f9:	je     15e1 <botlish_fn_15+0x349>
    13ff:	mov    QWORD PTR [rsp+0x28],0x3
    1408:	mov    rsi,QWORD PTR [rsp+0x38]
    140d:	test   rsi,0x1
    1414:	je     1431 <botlish_fn_15+0x199>
    141a:	mov    rsi,QWORD PTR [rsp+0x38]
    141f:	mov    rax,rsi
    1422:	add    rax,0x2
    1426:	seto   cl
    1429:	test   cl,cl
    142b:	je     1443 <botlish_fn_15+0x1ab>
    1431:	mov    edx,0x3
    1436:	mov    rsi,QWORD PTR [rsp+0x38]
    143b:	mov    rdi,r14
    143e:	call   1443 <botlish_fn_15+0x1ab>
			143f: R_X86_64_PLT32	rt_int_add-0x4
    1443:	mov    QWORD PTR [rsp+0x28],rax
    1448:	mov    QWORD PTR [rsp+0x40],rax
    144d:	mov    QWORD PTR [rsp+0x30],0x3
    1456:	mov    rsi,QWORD PTR [rsp+0x38]
    145b:	test   rsi,0x1
    1462:	je     147f <botlish_fn_15+0x1e7>
    1468:	mov    rsi,QWORD PTR [rsp+0x38]
    146d:	mov    rcx,rsi
    1470:	add    rcx,0x2
    1474:	seto   al
    1477:	test   al,al
    1479:	je     1494 <botlish_fn_15+0x1fc>
    147f:	mov    edx,0x3
    1484:	mov    rsi,QWORD PTR [rsp+0x38]
    1489:	mov    rdi,r14
    148c:	call   1491 <botlish_fn_15+0x1f9>
			148d: R_X86_64_PLT32	rt_int_add-0x4
    1491:	mov    rcx,rax
    1494:	mov    QWORD PTR [rsp+0x30],rcx
    1499:	mov    rdx,QWORD PTR [rsp+0x38]
    149e:	mov    rsi,rbx
    14a1:	mov    rdi,r14
    14a4:	call   14a9 <botlish_fn_15+0x211>
			14a5: R_X86_64_PLT32	rt_substr-0x4
    14a9:	test   rax,rax
    14ac:	je     1583 <botlish_fn_15+0x2eb>
    14b2:	mov    QWORD PTR [rsp+0x8],rax
    14b7:	mov    r8,r12
    14ba:	mov    r12,r13
    14bd:	mov    r13,r8
    14c0:	mov    rsi,rax
    14c3:	mov    rcx,r13
    14c6:	mov    rdx,r12
    14c9:	mov    rdi,r14
    14cc:	call   14d1 <botlish_fn_15+0x239>
			14cd: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_char<generic>
    14d1:	test   rax,rax
    14d4:	je     1583 <botlish_fn_15+0x2eb>
    14da:	mov    QWORD PTR [rsp+0x8],rax
    14df:	xor    ecx,ecx
    14e1:	mov    rsi,r15
    14e4:	test   rsi,0x7
    14eb:	jne    14fc <botlish_fn_15+0x264>
    14f1:	movzx  rdi,BYTE PTR [rsi]
    14f5:	cmp    dil,0x2
    14f9:	sete   cl
    14fc:	test   cl,cl
    14fe:	jne    1521 <botlish_fn_15+0x289>
    1504:	mov    rdi,r14
    1507:	mov    r11,QWORD PTR [rdi+0x10]
    150b:	mov    rcx,QWORD PTR [r11+0xd8]
    1512:	mov    rdx,QWORD PTR [rsp+0x48]
    1517:	call   151c <botlish_fn_15+0x284>
			1518: R_X86_64_PLT32	rt_type_error-0x4
    151c:	jmp    1583 <botlish_fn_15+0x2eb>
    1521:	mov    rdx,QWORD PTR [rsp+0x48]
    1526:	xor    edi,edi
    1528:	test   rax,0x7
    152e:	je     153c <botlish_fn_15+0x2a4>
    1534:	mov    r8,rax
    1537:	jmp    154b <botlish_fn_15+0x2b3>
    153c:	movzx  rcx,BYTE PTR [rax]
    1540:	mov    r8,rax
    1543:	rex cmp cl,0x2
    1547:	sete   dil
    154b:	test   dil,dil
    154e:	jne    156f <botlish_fn_15+0x2d7>
    1554:	mov    rdi,r14
    1557:	mov    rax,QWORD PTR [rdi+0x10]
    155b:	mov    rcx,QWORD PTR [rax+0xd8]
    1562:	mov    rsi,r8
    1565:	call   156a <botlish_fn_15+0x2d2>
			1566: R_X86_64_PLT32	rt_type_error-0x4
    156a:	jmp    1583 <botlish_fn_15+0x2eb>
    156f:	mov    rdx,r8
    1572:	mov    rdi,r14
    1575:	call   157a <botlish_fn_15+0x2e2>
			1576: R_X86_64_PLT32	rt_str_cat-0x4
    157a:	test   rax,rax
    157d:	jne    15ab <botlish_fn_15+0x313>
    1583:	xor    rax,rax
    1586:	mov    rbx,QWORD PTR [rsp+0x50]
    158b:	mov    r12,QWORD PTR [rsp+0x58]
    1590:	mov    r13,QWORD PTR [rsp+0x60]
    1595:	mov    r14,QWORD PTR [rsp+0x68]
    159a:	mov    r15,QWORD PTR [rsp+0x70]
    159f:	add    rsp,0x80
    15a6:	mov    rsp,rbp
    15a9:	pop    rbp
    15aa:	ret
    15ab:	mov    QWORD PTR [rsp],rbx
    15af:	mov    rcx,QWORD PTR [rsp+0x40]
    15b4:	mov    QWORD PTR [rsp+0x8],rcx
    15b9:	mov    QWORD PTR [rsp+0x10],rax
    15be:	mov    QWORD PTR [rsp+0x18],r12
    15c3:	mov    QWORD PTR [rsp+0x20],r13
    15c8:	mov    QWORD PTR [rsp+0x38],rcx
    15cd:	mov    r15,rax
    15d0:	mov    rdx,r12
    15d3:	mov    r12,r13
    15d6:	mov    r13,rdx
    15d9:	mov    rsi,rbx
    15dc:	jmp    12ee <botlish_fn_15+0x56>
    15e1:	mov    rax,r15
    15e4:	mov    rbx,QWORD PTR [rsp+0x50]
    15e9:	mov    r12,QWORD PTR [rsp+0x58]
    15ee:	mov    r13,QWORD PTR [rsp+0x60]
    15f3:	mov    r14,QWORD PTR [rsp+0x68]
    15f8:	mov    r15,QWORD PTR [rsp+0x70]
    15fd:	add    rsp,0x80
    1604:	mov    rsp,rbp
    1607:	pop    rbp
    1608:	ret
    1609:	add    BYTE PTR [rax],al
    160b:	add    BYTE PTR [rax],al
    160d:	add    BYTE PTR [rax],al
    160f:	add    BYTE PTR [rsi],al
    1611:	add    BYTE PTR [rax],al
    1613:	add    BYTE PTR [rax],al
    1615:	add    BYTE PTR [rax],al
	...

0000000000001618 <botlish_entry_15: esc_from<generic>>:
    1618:	push   rbp
    1619:	mov    rbp,rsp
    161c:	mov    rsi,QWORD PTR [rdx]
    161f:	mov    r10,QWORD PTR [rdx+0x8]
    1623:	mov    rcx,QWORD PTR [rdx+0x10]
    1627:	mov    r8,QWORD PTR [rdx+0x18]
    162b:	mov    r9,QWORD PTR [rdx+0x20]
    162f:	mov    rdx,r10
    1632:	call   1637 <botlish_entry_15+0x1f>
			1633: R_X86_64_PLT32	botlish_fn_15-0x4 ; esc_from<generic>
    1637:	mov    rsp,rbp
    163a:	pop    rbp
    163b:	ret
    163c:	add    BYTE PTR [rax],al
	...

0000000000001640 <botlish_fn_16: check<int, int, str, str>>:
    1640:	push   rbp
    1641:	mov    rbp,rsp
    1644:	sub    rsp,0x60
    1648:	mov    QWORD PTR [rsp+0x30],rbx
    164d:	mov    QWORD PTR [rsp+0x38],r12
    1652:	mov    QWORD PTR [rsp+0x40],r13
    1657:	mov    QWORD PTR [rsp+0x48],r14
    165c:	mov    QWORD PTR [rsp+0x50],r15
    1661:	mov    QWORD PTR [rsp+0x20],0x0
    166a:	mov    QWORD PTR [rsp],rsi
    166e:	mov    QWORD PTR [rsp+0x8],rdx
    1673:	mov    QWORD PTR [rsp+0x10],rcx
    1678:	mov    r12,rcx
    167b:	mov    QWORD PTR [rsp+0x18],r8
    1680:	mov    r14,r8
    1683:	mov    r13,rsi
    1686:	mov    r15,rdx
    1689:	test   r13,0x1
    1690:	jne    16bb <botlish_fn_16+0x7b>
    1696:	mov    edx,0x1
    169b:	mov    rbx,rdi
    169e:	mov    rsi,r13
    16a1:	call   16a6 <botlish_fn_16+0x66>
			16a2: R_X86_64_PLT32	rt_int_cmp-0x4
    16a6:	mov    ecx,0x2
    16ab:	test   rax,rax
    16ae:	cmovle rcx,QWORD PTR [rip+0x152]        # 1808 <botlish_fn_16+0x1c8>
    16b6:	jmp    16cf <botlish_fn_16+0x8f>
    16bb:	mov    rbx,rdi
    16be:	mov    ecx,0x2
    16c3:	cmp    r13,0x1
    16c7:	cmovle rcx,QWORD PTR [rip+0x139]        # 1808 <botlish_fn_16+0x1c8>
    16cf:	cmp    rcx,0x6
    16d3:	je     17dc <botlish_fn_16+0x19c>
    16d9:	mov    rax,QWORD PTR [rbx+0x10]
    16dd:	mov    rax,QWORD PTR [rax+0xf0]
    16e4:	mov    rsi,r12
    16e7:	mov    rdi,rbx
    16ea:	call   16ef <botlish_fn_16+0xaf>
			16eb: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    16ef:	test   rax,rax
    16f2:	je     1733 <botlish_fn_16+0xf3>
    16f8:	cmp    rax,0x6
    16fc:	je     1714 <botlish_fn_16+0xd4>
    1702:	mov    edx,0x1
    1707:	mov    QWORD PTR [rsp],0x1
    170f:	jmp    1775 <botlish_fn_16+0x135>
    1714:	mov    rax,QWORD PTR [rbx+0x10]
    1718:	mov    rax,QWORD PTR [rax+0xf8]
    171f:	mov    rsi,r12
    1722:	mov    rdi,rbx
    1725:	call   172a <botlish_fn_16+0xea>
			1726: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    172a:	test   rax,rax
    172d:	jne    1758 <botlish_fn_16+0x118>
    1733:	xor    rax,rax
    1736:	mov    rbx,QWORD PTR [rsp+0x30]
    173b:	mov    r12,QWORD PTR [rsp+0x38]
    1740:	mov    r13,QWORD PTR [rsp+0x40]
    1745:	mov    r14,QWORD PTR [rsp+0x48]
    174a:	mov    r15,QWORD PTR [rsp+0x50]
    174f:	add    rsp,0x60
    1753:	mov    rsp,rbp
    1756:	pop    rbp
    1757:	ret
    1758:	cmp    rax,0x6
    175c:	je     176c <botlish_fn_16+0x12c>
    1762:	mov    edx,0x1
    1767:	jmp    1771 <botlish_fn_16+0x131>
    176c:	mov    edx,0x3
    1771:	mov    QWORD PTR [rsp],rdx
    1775:	sar    r13,1
    1778:	sub    r13,0x1
    177c:	shl    r13,1
    177f:	or     r13,0x1
    1783:	mov    QWORD PTR [rsp+0x20],r13
    1788:	mov    rsi,r15
    178b:	mov    r8,rsi
    178e:	and    r8,rdx
    1791:	test   r8,0x1
    1798:	je     17b3 <botlish_fn_16+0x173>
    179e:	lea    r11,[rdx-0x1]
    17a2:	mov    rax,rsi
    17a5:	add    rax,r11
    17a8:	seto   cl
    17ab:	test   cl,cl
    17ad:	je     17bb <botlish_fn_16+0x17b>
    17b3:	mov    rdi,rbx
    17b6:	call   17bb <botlish_fn_16+0x17b>
			17b7: R_X86_64_PLT32	rt_int_add-0x4
    17bb:	mov    QWORD PTR [rsp],r13
    17bf:	mov    QWORD PTR [rsp+0x8],rax
    17c4:	mov    QWORD PTR [rsp+0x10],r12
    17c9:	mov    r8,r14
    17cc:	mov    QWORD PTR [rsp+0x18],r8
    17d1:	mov    rdi,rbx
    17d4:	mov    r15,rax
    17d7:	jmp    1689 <botlish_fn_16+0x49>
    17dc:	mov    rax,r15
    17df:	mov    rbx,QWORD PTR [rsp+0x30]
    17e4:	mov    r12,QWORD PTR [rsp+0x38]
    17e9:	mov    r13,QWORD PTR [rsp+0x40]
    17ee:	mov    r14,QWORD PTR [rsp+0x48]
    17f3:	mov    r15,QWORD PTR [rsp+0x50]
    17f8:	add    rsp,0x60
    17fc:	mov    rsp,rbp
    17ff:	pop    rbp
    1800:	ret
    1801:	add    BYTE PTR [rax],al
    1803:	add    BYTE PTR [rax],al
    1805:	add    BYTE PTR [rax],al
    1807:	add    BYTE PTR [rsi],al
    1809:	add    BYTE PTR [rax],al
    180b:	add    BYTE PTR [rax],al
    180d:	add    BYTE PTR [rax],al
	...

0000000000001810 <botlish_entry_16: check<int, int, str, str>>:
    1810:	push   rbp
    1811:	mov    rbp,rsp
    1814:	mov    rsi,QWORD PTR [rdx]
    1817:	mov    r9,QWORD PTR [rdx+0x8]
    181b:	mov    rcx,QWORD PTR [rdx+0x10]
    181f:	mov    r8,QWORD PTR [rdx+0x18]
    1823:	mov    rdx,r9
    1826:	call   182b <botlish_entry_16+0x1b>
			1827: R_X86_64_PLT32	botlish_fn_16-0x4 ; check<int, int, str, str>
    182b:	mov    rsp,rbp
    182e:	pop    rbp
    182f:	ret

0000000000001830 <botlish_fn_17: <str>>:
    1830:	push   rbp
    1831:	mov    rbp,rsp
    1834:	sub    rsp,0x50
    1838:	mov    QWORD PTR [rsp+0x30],rbx
    183d:	mov    QWORD PTR [rsp+0x38],r12
    1842:	mov    QWORD PTR [rsp+0x40],r13
    1847:	mov    QWORD PTR [rsp+0x48],r14
    184c:	mov    r13,rdi
    184f:	mov    QWORD PTR [rsp+0x18],0x0
    1858:	mov    QWORD PTR [rsp],rsi
    185c:	mov    r14,rsi
    185f:	mov    rsi,r14
    1862:	mov    rdi,r13
    1865:	call   186a <botlish_fn_17+0x3a>
			1866: R_X86_64_PLT32	rt_str_len-0x4
    186a:	mov    rbx,rax
    186d:	mov    QWORD PTR [rsp+0x8],rax
    1872:	mov    esi,0x1
    1877:	mov    QWORD PTR [rsp+0x10],0x1
    1880:	mov    rcx,r14
    1883:	mov    rdx,rbx
    1886:	mov    rdi,r13
    1889:	call   188e <botlish_fn_17+0x5e>
			188a: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    188e:	mov    r12,rax
    1891:	test   r12,r12
    1894:	je     19f1 <botlish_fn_17+0x1c1>
    189a:	mov    QWORD PTR [rsp+0x10],r12
    189f:	test   r12,0x1
    18a6:	jne    18d1 <botlish_fn_17+0xa1>
    18ac:	mov    edx,0x1
    18b1:	mov    rsi,r12
    18b4:	mov    rdi,r13
    18b7:	call   18bc <botlish_fn_17+0x8c>
			18b8: R_X86_64_PLT32	rt_int_cmp-0x4
    18bc:	mov    ecx,0x2
    18c1:	test   rax,rax
    18c4:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 1a90 <botlish_fn_17+0x260>
    18cc:	jmp    18e2 <botlish_fn_17+0xb2>
    18d1:	mov    ecx,0x2
    18d6:	cmp    r12,0x1
    18da:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 1a90 <botlish_fn_17+0x260>
    18e2:	cmp    rcx,0x6
    18e6:	je     1a6c <botlish_fn_17+0x23c>
    18ec:	mov    rcx,r12
    18ef:	and    rcx,rbx
    18f2:	test   rcx,0x1
    18f9:	jne    1922 <botlish_fn_17+0xf2>
    18ff:	mov    rdx,rbx
    1902:	mov    rsi,r12
    1905:	mov    rdi,r13
    1908:	call   190d <botlish_fn_17+0xdd>
			1909: R_X86_64_PLT32	rt_int_cmp-0x4
    190d:	mov    ecx,0x2
    1912:	test   rax,rax
    1915:	cmovge rcx,QWORD PTR [rip+0x173]        # 1a90 <botlish_fn_17+0x260>
    191d:	jmp    1932 <botlish_fn_17+0x102>
    1922:	mov    ecx,0x2
    1927:	cmp    r12,rbx
    192a:	cmovge rcx,QWORD PTR [rip+0x15e]        # 1a90 <botlish_fn_17+0x260>
    1932:	cmp    rcx,0x6
    1936:	je     1a62 <botlish_fn_17+0x232>
    193c:	lea    rcx,[rsp+0x20]
    1941:	mov    rdx,r14
    1944:	mov    rsi,r12
    1947:	mov    rdi,r13
    194a:	call   194f <botlish_fn_17+0x11f>
			194b: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    194f:	test   rax,rax
    1952:	mov    rsi,rax
    1955:	je     19f1 <botlish_fn_17+0x1c1>
    195b:	mov    rdx,QWORD PTR [rsp+0x20]
    1960:	mov    rcx,QWORD PTR [rsp+0x28]
    1965:	mov    rdi,r13
    1968:	mov    rax,QWORD PTR [rdi+0x10]
    196c:	mov    r8,QWORD PTR [rax+0x110]
    1973:	call   1978 <botlish_fn_17+0x148>
			1974: R_X86_64_PLT32	rt_str_region_eq-0x4
    1978:	cmp    rax,0x6
    197c:	je     198f <botlish_fn_17+0x15f>
    1982:	mov    ecx,0x2
    1987:	mov    rax,rcx
    198a:	jmp    1a71 <botlish_fn_17+0x241>
    198f:	mov    QWORD PTR [rsp+0x18],0x3
    1998:	test   r12,0x1
    199f:	jne    19ad <botlish_fn_17+0x17d>
    19a5:	mov    rcx,r12
    19a8:	jmp    19c2 <botlish_fn_17+0x192>
    19ad:	mov    rsi,r12
    19b0:	add    rsi,0x2
    19b4:	mov    rcx,r12
    19b7:	seto   al
    19ba:	test   al,al
    19bc:	je     19d5 <botlish_fn_17+0x1a5>
    19c2:	mov    edx,0x3
    19c7:	mov    rsi,rcx
    19ca:	mov    rdi,r13
    19cd:	call   19d2 <botlish_fn_17+0x1a2>
			19ce: R_X86_64_PLT32	rt_int_add-0x4
    19d2:	mov    rsi,rax
    19d5:	mov    QWORD PTR [rsp+0x10],rsi
    19da:	mov    rcx,r14
    19dd:	mov    rdx,rbx
    19e0:	mov    rdi,r13
    19e3:	call   19e8 <botlish_fn_17+0x1b8>
			19e4: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    19e8:	test   rax,rax
    19eb:	jne    1a11 <botlish_fn_17+0x1e1>
    19f1:	xor    rax,rax
    19f4:	mov    rbx,QWORD PTR [rsp+0x30]
    19f9:	mov    r12,QWORD PTR [rsp+0x38]
    19fe:	mov    r13,QWORD PTR [rsp+0x40]
    1a03:	mov    r14,QWORD PTR [rsp+0x48]
    1a08:	add    rsp,0x50
    1a0c:	mov    rsp,rbp
    1a0f:	pop    rbp
    1a10:	ret
    1a11:	mov    rcx,rax
    1a14:	and    rcx,rbx
    1a17:	mov    rsi,rax
    1a1a:	test   rcx,0x1
    1a21:	jne    1a4a <botlish_fn_17+0x21a>
    1a27:	mov    rdx,rbx
    1a2a:	mov    rdi,r13
    1a2d:	call   1a32 <botlish_fn_17+0x202>
			1a2e: R_X86_64_PLT32	rt_int_cmp-0x4
    1a32:	mov    ecx,0x2
    1a37:	test   rax,rax
    1a3a:	mov    rax,rcx
    1a3d:	cmove  rax,QWORD PTR [rip+0x4b]        # 1a90 <botlish_fn_17+0x260>
    1a45:	jmp    1a71 <botlish_fn_17+0x241>
    1a4a:	mov    rdx,rbx
    1a4d:	mov    eax,0x2
    1a52:	cmp    rsi,rdx
    1a55:	cmove  rax,QWORD PTR [rip+0x33]        # 1a90 <botlish_fn_17+0x260>
    1a5d:	jmp    1a71 <botlish_fn_17+0x241>
    1a62:	mov    eax,0x2
    1a67:	jmp    1a71 <botlish_fn_17+0x241>
    1a6c:	mov    eax,0x2
    1a71:	mov    rbx,QWORD PTR [rsp+0x30]
    1a76:	mov    r12,QWORD PTR [rsp+0x38]
    1a7b:	mov    r13,QWORD PTR [rsp+0x40]
    1a80:	mov    r14,QWORD PTR [rsp+0x48]
    1a85:	add    rsp,0x50
    1a89:	mov    rsp,rbp
    1a8c:	pop    rbp
    1a8d:	ret
    1a8e:	add    BYTE PTR [rax],al
    1a90:	(bad)
    1a91:	add    BYTE PTR [rax],al
    1a93:	add    BYTE PTR [rax],al
    1a95:	add    BYTE PTR [rax],al
	...

0000000000001a98 <botlish_entry_17: <str>>:
    1a98:	push   rbp
    1a99:	mov    rbp,rsp
    1a9c:	mov    rsi,QWORD PTR [rdx]
    1a9f:	call   1aa4 <botlish_entry_17+0xc>
			1aa0: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    1aa4:	mov    rsp,rbp
    1aa7:	pop    rbp
    1aa8:	ret
    1aa9:	add    BYTE PTR [rax],al
    1aab:	add    BYTE PTR [rax],al
    1aad:	add    BYTE PTR [rax],al
	...

0000000000001ab0 <botlish_fn_18: <generic>>:
    1ab0:	push   rbp
    1ab1:	mov    rbp,rsp
    1ab4:	sub    rsp,0x60
    1ab8:	mov    QWORD PTR [rsp+0x30],rbx
    1abd:	mov    QWORD PTR [rsp+0x38],r12
    1ac2:	mov    QWORD PTR [rsp+0x40],r13
    1ac7:	mov    QWORD PTR [rsp+0x48],r14
    1acc:	mov    QWORD PTR [rsp+0x50],r15
    1ad1:	mov    QWORD PTR [rsp+0x18],0x0
    1ada:	mov    QWORD PTR [rsp],rsi
    1ade:	xor    r8d,r8d
    1ae1:	test   rsi,0x7
    1ae8:	jne    1af8 <botlish_fn_18+0x48>
    1aee:	movzx  rax,BYTE PTR [rsi]
    1af2:	cmp    al,0x2
    1af4:	sete   r8b
    1af8:	test   r8b,r8b
    1afb:	jne    1b1b <botlish_fn_18+0x6b>
    1b01:	mov    rdx,QWORD PTR [rdi+0x10]
    1b05:	mov    rcx,QWORD PTR [rdx+0xe8]
    1b0c:	mov    edx,0x1
    1b11:	call   1b16 <botlish_fn_18+0x66>
			1b12: R_X86_64_PLT32	rt_type_error-0x4
    1b16:	jmp    1cb0 <botlish_fn_18+0x200>
    1b1b:	mov    r13,rsi
    1b1e:	mov    r14,rdi
    1b21:	call   1b26 <botlish_fn_18+0x76>
			1b22: R_X86_64_PLT32	rt_str_len-0x4
    1b26:	mov    rbx,rax
    1b29:	mov    QWORD PTR [rsp+0x8],rax
    1b2e:	mov    edx,0x1
    1b33:	mov    r15,rdx
    1b36:	mov    QWORD PTR [rsp+0x10],0x1
    1b3f:	mov    rcx,r13
    1b42:	mov    rdx,rbx
    1b45:	mov    rsi,r15
    1b48:	mov    rdi,r14
    1b4b:	call   1b50 <botlish_fn_18+0xa0>
			1b4c: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    1b50:	mov    r12,rax
    1b53:	test   r12,r12
    1b56:	je     1cb0 <botlish_fn_18+0x200>
    1b5c:	mov    QWORD PTR [rsp+0x10],r12
    1b61:	test   r12,0x1
    1b68:	jne    1b91 <botlish_fn_18+0xe1>
    1b6e:	mov    rdx,r15
    1b71:	mov    rsi,r12
    1b74:	mov    rdi,r14
    1b77:	call   1b7c <botlish_fn_18+0xcc>
			1b78: R_X86_64_PLT32	rt_int_cmp-0x4
    1b7c:	mov    ecx,0x2
    1b81:	test   rax,rax
    1b84:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 1d58 <botlish_fn_18+0x2a8>
    1b8c:	jmp    1ba2 <botlish_fn_18+0xf2>
    1b91:	mov    ecx,0x2
    1b96:	cmp    r12,0x1
    1b9a:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 1d58 <botlish_fn_18+0x2a8>
    1ba2:	cmp    rcx,0x6
    1ba6:	je     1d30 <botlish_fn_18+0x280>
    1bac:	mov    rax,r12
    1baf:	and    rax,rbx
    1bb2:	test   rax,0x1
    1bb8:	jne    1be1 <botlish_fn_18+0x131>
    1bbe:	mov    rdx,rbx
    1bc1:	mov    rsi,r12
    1bc4:	mov    rdi,r14
    1bc7:	call   1bcc <botlish_fn_18+0x11c>
			1bc8: R_X86_64_PLT32	rt_int_cmp-0x4
    1bcc:	mov    ecx,0x2
    1bd1:	test   rax,rax
    1bd4:	cmovge rcx,QWORD PTR [rip+0x17c]        # 1d58 <botlish_fn_18+0x2a8>
    1bdc:	jmp    1bf1 <botlish_fn_18+0x141>
    1be1:	mov    ecx,0x2
    1be6:	cmp    r12,rbx
    1be9:	cmovge rcx,QWORD PTR [rip+0x167]        # 1d58 <botlish_fn_18+0x2a8>
    1bf1:	cmp    rcx,0x6
    1bf5:	je     1d26 <botlish_fn_18+0x276>
    1bfb:	lea    rcx,[rsp+0x20]
    1c00:	mov    rdx,r13
    1c03:	mov    rsi,r12
    1c06:	mov    rdi,r14
    1c09:	call   1c0e <botlish_fn_18+0x15e>
			1c0a: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    1c0e:	test   rax,rax
    1c11:	mov    rsi,rax
    1c14:	je     1cb0 <botlish_fn_18+0x200>
    1c1a:	mov    rdx,QWORD PTR [rsp+0x20]
    1c1f:	mov    rcx,QWORD PTR [rsp+0x28]
    1c24:	mov    rdi,r14
    1c27:	mov    rax,QWORD PTR [rdi+0x10]
    1c2b:	mov    r8,QWORD PTR [rax+0x110]
    1c32:	call   1c37 <botlish_fn_18+0x187>
			1c33: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c37:	cmp    rax,0x6
    1c3b:	je     1c4e <botlish_fn_18+0x19e>
    1c41:	mov    ecx,0x2
    1c46:	mov    rax,rcx
    1c49:	jmp    1d35 <botlish_fn_18+0x285>
    1c4e:	mov    QWORD PTR [rsp+0x18],0x3
    1c57:	test   r12,0x1
    1c5e:	jne    1c6c <botlish_fn_18+0x1bc>
    1c64:	mov    rdi,r12
    1c67:	jmp    1c81 <botlish_fn_18+0x1d1>
    1c6c:	mov    rsi,r12
    1c6f:	add    rsi,0x2
    1c73:	mov    rdi,r12
    1c76:	seto   al
    1c79:	test   al,al
    1c7b:	je     1c94 <botlish_fn_18+0x1e4>
    1c81:	mov    edx,0x3
    1c86:	mov    rsi,rdi
    1c89:	mov    rdi,r14
    1c8c:	call   1c91 <botlish_fn_18+0x1e1>
			1c8d: R_X86_64_PLT32	rt_int_add-0x4
    1c91:	mov    rsi,rax
    1c94:	mov    QWORD PTR [rsp+0x10],rsi
    1c99:	mov    rcx,r13
    1c9c:	mov    rdx,rbx
    1c9f:	mov    rdi,r14
    1ca2:	call   1ca7 <botlish_fn_18+0x1f7>
			1ca3: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    1ca7:	test   rax,rax
    1caa:	jne    1cd5 <botlish_fn_18+0x225>
    1cb0:	xor    rax,rax
    1cb3:	mov    rbx,QWORD PTR [rsp+0x30]
    1cb8:	mov    r12,QWORD PTR [rsp+0x38]
    1cbd:	mov    r13,QWORD PTR [rsp+0x40]
    1cc2:	mov    r14,QWORD PTR [rsp+0x48]
    1cc7:	mov    r15,QWORD PTR [rsp+0x50]
    1ccc:	add    rsp,0x60
    1cd0:	mov    rsp,rbp
    1cd3:	pop    rbp
    1cd4:	ret
    1cd5:	mov    rcx,rax
    1cd8:	and    rcx,rbx
    1cdb:	mov    rsi,rax
    1cde:	test   rcx,0x1
    1ce5:	jne    1d0e <botlish_fn_18+0x25e>
    1ceb:	mov    rdx,rbx
    1cee:	mov    rdi,r14
    1cf1:	call   1cf6 <botlish_fn_18+0x246>
			1cf2: R_X86_64_PLT32	rt_int_cmp-0x4
    1cf6:	mov    ecx,0x2
    1cfb:	test   rax,rax
    1cfe:	mov    rax,rcx
    1d01:	cmove  rax,QWORD PTR [rip+0x4f]        # 1d58 <botlish_fn_18+0x2a8>
    1d09:	jmp    1d35 <botlish_fn_18+0x285>
    1d0e:	mov    rdx,rbx
    1d11:	mov    eax,0x2
    1d16:	cmp    rsi,rdx
    1d19:	cmove  rax,QWORD PTR [rip+0x37]        # 1d58 <botlish_fn_18+0x2a8>
    1d21:	jmp    1d35 <botlish_fn_18+0x285>
    1d26:	mov    eax,0x2
    1d2b:	jmp    1d35 <botlish_fn_18+0x285>
    1d30:	mov    eax,0x2
    1d35:	mov    rbx,QWORD PTR [rsp+0x30]
    1d3a:	mov    r12,QWORD PTR [rsp+0x38]
    1d3f:	mov    r13,QWORD PTR [rsp+0x40]
    1d44:	mov    r14,QWORD PTR [rsp+0x48]
    1d49:	mov    r15,QWORD PTR [rsp+0x50]
    1d4e:	add    rsp,0x60
    1d52:	mov    rsp,rbp
    1d55:	pop    rbp
    1d56:	ret
    1d57:	add    BYTE PTR [rsi],al
    1d59:	add    BYTE PTR [rax],al
    1d5b:	add    BYTE PTR [rax],al
    1d5d:	add    BYTE PTR [rax],al
	...

0000000000001d60 <botlish_entry_18: <generic>>:
    1d60:	push   rbp
    1d61:	mov    rbp,rsp
    1d64:	mov    rsi,QWORD PTR [rdx]
    1d67:	call   1d6c <botlish_entry_18+0xc>
			1d68: R_X86_64_PLT32	botlish_fn_18-0x4 ; <generic>
    1d6c:	mov    rsp,rbp
    1d6f:	pop    rbp
    1d70:	ret

0000000000001d71 <botlish_fn_19: char_at<generic>>:
    1d71:	push   rbp
    1d72:	mov    rbp,rsp
    1d75:	sub    rsp,0x50
    1d79:	mov    QWORD PTR [rsp+0x20],rbx
    1d7e:	mov    QWORD PTR [rsp+0x28],r12
    1d83:	mov    QWORD PTR [rsp+0x30],r13
    1d88:	mov    QWORD PTR [rsp+0x38],r14
    1d8d:	mov    QWORD PTR [rsp+0x40],r15
    1d92:	mov    r14,rcx
    1d95:	mov    QWORD PTR [rsp],rsi
    1d99:	mov    QWORD PTR [rsp+0x8],rdx
    1d9e:	mov    r13,rdx
    1da1:	mov    QWORD PTR [rsp+0x10],0x3
    1daa:	mov    r9d,0x1
    1db0:	test   rsi,0x1
    1db7:	jne    1dd7 <botlish_fn_19+0x66>
    1dbd:	xor    r9d,r9d
    1dc0:	test   rsi,0x7
    1dc7:	jne    1dd7 <botlish_fn_19+0x66>
    1dcd:	movzx  rax,BYTE PTR [rsi]
    1dd1:	cmp    al,0x1
    1dd3:	sete   r9b
    1dd7:	test   r9b,r9b
    1dda:	jne    1df8 <botlish_fn_19+0x87>
    1de0:	mov    rax,QWORD PTR [rdi+0x10]
    1de4:	mov    rcx,QWORD PTR [rax+0x118]
    1deb:	xor    rdx,rdx
    1dee:	call   1df3 <botlish_fn_19+0x82>
			1def: R_X86_64_PLT32	rt_type_error-0x4
    1df3:	jmp    1eb5 <botlish_fn_19+0x144>
    1df8:	mov    r12,rdi
    1dfb:	test   rsi,0x1
    1e02:	jne    1e10 <botlish_fn_19+0x9f>
    1e08:	mov    rbx,rsi
    1e0b:	jmp    1e2d <botlish_fn_19+0xbc>
    1e10:	mov    rax,rsi
    1e13:	add    rax,0x2
    1e17:	mov    rbx,rsi
    1e1a:	seto   cl
    1e1d:	test   cl,cl
    1e1f:	jne    1e2d <botlish_fn_19+0xbc>
    1e25:	mov    r15,rax
    1e28:	jmp    1e40 <botlish_fn_19+0xcf>
    1e2d:	mov    edx,0x3
    1e32:	mov    rsi,rbx
    1e35:	mov    rdi,r12
    1e38:	call   1e3d <botlish_fn_19+0xcc>
			1e39: R_X86_64_PLT32	rt_int_add-0x4
    1e3d:	mov    r15,rax
    1e40:	mov    ecx,0x1
    1e45:	mov    rsi,rbx
    1e48:	test   rsi,0x1
    1e4f:	jne    1e75 <botlish_fn_19+0x104>
    1e55:	xor    ecx,ecx
    1e57:	mov    rsi,rbx
    1e5a:	test   rsi,0x7
    1e61:	jne    1e75 <botlish_fn_19+0x104>
    1e67:	mov    rsi,rbx
    1e6a:	movzx  rcx,BYTE PTR [rsi]
    1e6e:	rex cmp cl,0x1
    1e72:	sete   cl
    1e75:	test   cl,cl
    1e77:	jne    1e9b <botlish_fn_19+0x12a>
    1e7d:	mov    rdi,r12
    1e80:	mov    rsi,QWORD PTR [rdi+0x10]
    1e84:	mov    rcx,QWORD PTR [rsi+0x120]
    1e8b:	xor    rdx,rdx
    1e8e:	mov    rsi,rbx
    1e91:	call   1e96 <botlish_fn_19+0x125>
			1e92: R_X86_64_PLT32	rt_type_error-0x4
    1e96:	jmp    1eb5 <botlish_fn_19+0x144>
    1e9b:	mov    rdi,r12
    1e9e:	mov    rcx,r15
    1ea1:	mov    rdx,rbx
    1ea4:	mov    rsi,r13
    1ea7:	call   1eac <botlish_fn_19+0x13b>
			1ea8: R_X86_64_PLT32	rt_str_region_check-0x4
    1eac:	test   rax,rax
    1eaf:	jne    1eda <botlish_fn_19+0x169>
    1eb5:	xor    rax,rax
    1eb8:	mov    rbx,QWORD PTR [rsp+0x20]
    1ebd:	mov    r12,QWORD PTR [rsp+0x28]
    1ec2:	mov    r13,QWORD PTR [rsp+0x30]
    1ec7:	mov    r14,QWORD PTR [rsp+0x38]
    1ecc:	mov    r15,QWORD PTR [rsp+0x40]
    1ed1:	add    rsp,0x50
    1ed5:	mov    rsp,rbp
    1ed8:	pop    rbp
    1ed9:	ret
    1eda:	mov    rcx,r14
    1edd:	mov    rsi,rbx
    1ee0:	mov    QWORD PTR [rcx],rsi
    1ee3:	mov    rax,r15
    1ee6:	mov    QWORD PTR [rcx+0x8],rax
    1eea:	mov    rax,r13
    1eed:	mov    rbx,QWORD PTR [rsp+0x20]
    1ef2:	mov    r12,QWORD PTR [rsp+0x28]
    1ef7:	mov    r13,QWORD PTR [rsp+0x30]
    1efc:	mov    r14,QWORD PTR [rsp+0x38]
    1f01:	mov    r15,QWORD PTR [rsp+0x40]
    1f06:	add    rsp,0x50
    1f0a:	mov    rsp,rbp
    1f0d:	pop    rbp
    1f0e:	ret

0000000000001f0f <botlish_entry_19: char_at<generic>>:
    1f0f:	push   rbp
    1f10:	mov    rbp,rsp
    1f13:	ud2
    1f15:	add    BYTE PTR [rax],al
	...

0000000000001f18 <botlish_fn_20: scan_local<generic>>:
    1f18:	push   rbp
    1f19:	mov    rbp,rsp
    1f1c:	sub    rsp,0x80
    1f23:	mov    QWORD PTR [rsp+0x50],rbx
    1f28:	mov    QWORD PTR [rsp+0x58],r12
    1f2d:	mov    QWORD PTR [rsp+0x60],r13
    1f32:	mov    QWORD PTR [rsp+0x68],r14
    1f37:	mov    QWORD PTR [rsp+0x70],r15
    1f3c:	mov    rax,rdi
    1f3f:	mov    QWORD PTR [rsp+0x18],0x0
    1f48:	mov    QWORD PTR [rsp],rsi
    1f4c:	mov    r14,rsi
    1f4f:	mov    QWORD PTR [rsp+0x8],rdx
    1f54:	mov    QWORD PTR [rsp+0x10],rcx
    1f59:	mov    r12,rcx
    1f5c:	mov    r11d,0x1
    1f62:	mov    rsi,r14
    1f65:	test   rsi,0x1
    1f6c:	jne    1f8e <botlish_fn_20+0x76>
    1f72:	xor    r11d,r11d
    1f75:	test   rsi,0x7
    1f7c:	jne    1f8e <botlish_fn_20+0x76>
    1f82:	movzx  rdi,BYTE PTR [rsi]
    1f86:	cmp    dil,0x1
    1f8a:	sete   r11b
    1f8e:	test   r11b,r11b
    1f91:	jne    1fb2 <botlish_fn_20+0x9a>
    1f97:	mov    rdi,rax
    1f9a:	mov    r9,QWORD PTR [rdi+0x10]
    1f9e:	mov    rcx,QWORD PTR [r9+0xc8]
    1fa5:	xor    rdx,rdx
    1fa8:	call   1fad <botlish_fn_20+0x95>
			1fa9: R_X86_64_PLT32	rt_type_error-0x4
    1fad:	jmp    2065 <botlish_fn_20+0x14d>
    1fb2:	mov    r13,rdx
    1fb5:	mov    r10,rsi
    1fb8:	and    r10,r13
    1fbb:	mov    r14,rsi
    1fbe:	test   r10,0x1
    1fc5:	jne    1ff1 <botlish_fn_20+0xd9>
    1fcb:	mov    rbx,rax
    1fce:	mov    rdx,r13
    1fd1:	mov    rsi,r14
    1fd4:	mov    rdi,rbx
    1fd7:	call   1fdc <botlish_fn_20+0xc4>
			1fd8: R_X86_64_PLT32	rt_int_cmp-0x4
    1fdc:	mov    ecx,0x2
    1fe1:	test   rax,rax
    1fe4:	cmovge rcx,QWORD PTR [rip+0x24c]        # 2238 <botlish_fn_20+0x320>
    1fec:	jmp    2007 <botlish_fn_20+0xef>
    1ff1:	mov    rbx,rax
    1ff4:	mov    ecx,0x2
    1ff9:	mov    rsi,r14
    1ffc:	cmp    rsi,r13
    1fff:	cmovge rcx,QWORD PTR [rip+0x231]        # 2238 <botlish_fn_20+0x320>
    2007:	mov    eax,0x6
    200c:	mov    QWORD PTR [rsp+0x30],rax
    2011:	cmp    rcx,0x6
    2015:	je     220b <botlish_fn_20+0x2f3>
    201b:	lea    rcx,[rsp+0x20]
    2020:	mov    rdx,r12
    2023:	mov    rsi,r14
    2026:	mov    rdi,rbx
    2029:	call   202e <botlish_fn_20+0x116>
			202a: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    202e:	mov    rsi,rax
    2031:	mov    r15,rax
    2034:	test   rax,rsi
    2037:	je     2065 <botlish_fn_20+0x14d>
    203d:	mov    rdx,QWORD PTR [rsp+0x20]
    2042:	mov    QWORD PTR [rsp+0x40],rdx
    2047:	mov    rcx,QWORD PTR [rsp+0x28]
    204c:	mov    QWORD PTR [rsp+0x38],rcx
    2051:	mov    rsi,r15
    2054:	mov    rdi,rbx
    2057:	call   205c <botlish_fn_20+0x144>
			2058: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    205c:	test   rax,rax
    205f:	jne    208d <botlish_fn_20+0x175>
    2065:	xor    rax,rax
    2068:	mov    rbx,QWORD PTR [rsp+0x50]
    206d:	mov    r12,QWORD PTR [rsp+0x58]
    2072:	mov    r13,QWORD PTR [rsp+0x60]
    2077:	mov    r14,QWORD PTR [rsp+0x68]
    207c:	mov    r15,QWORD PTR [rsp+0x70]
    2081:	add    rsp,0x80
    2088:	mov    rsp,rbp
    208b:	pop    rbp
    208c:	ret
    208d:	cmp    rax,0x6
    2091:	je     218c <botlish_fn_20+0x274>
    2097:	mov    rax,QWORD PTR [rbx+0x10]
    209b:	mov    r8,QWORD PTR [rax+0x128]
    20a2:	mov    rcx,QWORD PTR [rsp+0x38]
    20a7:	mov    rdx,QWORD PTR [rsp+0x40]
    20ac:	mov    rsi,r15
    20af:	mov    rdi,rbx
    20b2:	call   20b7 <botlish_fn_20+0x19f>
			20b3: R_X86_64_PLT32	rt_str_region_eq-0x4
    20b7:	cmp    rax,0x6
    20bb:	je     2182 <botlish_fn_20+0x26a>
    20c1:	mov    rax,QWORD PTR [rbx+0x10]
    20c5:	mov    r8,QWORD PTR [rax+0x130]
    20cc:	mov    rcx,QWORD PTR [rsp+0x38]
    20d1:	mov    rdx,QWORD PTR [rsp+0x40]
    20d6:	mov    rsi,r15
    20d9:	mov    rdi,rbx
    20dc:	call   20e1 <botlish_fn_20+0x1c9>
			20dd: R_X86_64_PLT32	rt_str_region_eq-0x4
    20e1:	cmp    rax,0x6
    20e5:	je     2178 <botlish_fn_20+0x260>
    20eb:	mov    rax,QWORD PTR [rbx+0x10]
    20ef:	mov    r8,QWORD PTR [rax+0xd0]
    20f6:	mov    rcx,QWORD PTR [rsp+0x38]
    20fb:	mov    rdx,QWORD PTR [rsp+0x40]
    2100:	mov    rsi,r15
    2103:	mov    rdi,rbx
    2106:	call   210b <botlish_fn_20+0x1f3>
			2107: R_X86_64_PLT32	rt_str_region_eq-0x4
    210b:	cmp    rax,0x6
    210f:	je     216e <botlish_fn_20+0x256>
    2115:	mov    rax,QWORD PTR [rbx+0x10]
    2119:	mov    r8,QWORD PTR [rax+0x118]
    2120:	mov    rcx,QWORD PTR [rsp+0x38]
    2125:	mov    rdx,QWORD PTR [rsp+0x40]
    212a:	mov    rsi,r15
    212d:	mov    rdi,rbx
    2130:	call   2135 <botlish_fn_20+0x21d>
			2131: R_X86_64_PLT32	rt_str_region_eq-0x4
    2135:	cmp    rax,0x6
    2139:	je     2164 <botlish_fn_20+0x24c>
    213f:	mov    rax,QWORD PTR [rbx+0x10]
    2143:	mov    r8,QWORD PTR [rax+0x138]
    214a:	mov    rcx,QWORD PTR [rsp+0x38]
    214f:	mov    rdx,QWORD PTR [rsp+0x40]
    2154:	mov    rsi,r15
    2157:	mov    rdi,rbx
    215a:	call   215f <botlish_fn_20+0x247>
			215b: R_X86_64_PLT32	rt_str_region_eq-0x4
    215f:	jmp    2191 <botlish_fn_20+0x279>
    2164:	mov    rax,QWORD PTR [rsp+0x30]
    2169:	jmp    2191 <botlish_fn_20+0x279>
    216e:	mov    rax,QWORD PTR [rsp+0x30]
    2173:	jmp    2191 <botlish_fn_20+0x279>
    2178:	mov    rax,QWORD PTR [rsp+0x30]
    217d:	jmp    2191 <botlish_fn_20+0x279>
    2182:	mov    rax,QWORD PTR [rsp+0x30]
    2187:	jmp    2191 <botlish_fn_20+0x279>
    218c:	mov    rax,QWORD PTR [rsp+0x30]
    2191:	cmp    rax,0x6
    2195:	je     21a3 <botlish_fn_20+0x28b>
    219b:	mov    rax,r14
    219e:	jmp    220e <botlish_fn_20+0x2f6>
    21a3:	mov    QWORD PTR [rsp+0x18],0x3
    21ac:	mov    rsi,r14
    21af:	test   rsi,0x1
    21b6:	je     21dc <botlish_fn_20+0x2c4>
    21bc:	mov    rsi,r14
    21bf:	mov    rax,rsi
    21c2:	add    rax,0x2
    21c6:	seto   cl
    21c9:	test   cl,cl
    21cb:	jne    21dc <botlish_fn_20+0x2c4>
    21d1:	mov    rsi,rax
    21d4:	mov    r14,rax
    21d7:	jmp    21f2 <botlish_fn_20+0x2da>
    21dc:	mov    edx,0x3
    21e1:	mov    rsi,r14
    21e4:	mov    rdi,rbx
    21e7:	call   21ec <botlish_fn_20+0x2d4>
			21e8: R_X86_64_PLT32	rt_int_add-0x4
    21ec:	mov    rsi,rax
    21ef:	mov    r14,rax
    21f2:	mov    QWORD PTR [rsp],rsi
    21f6:	mov    QWORD PTR [rsp+0x8],r13
    21fb:	mov    QWORD PTR [rsp+0x10],r12
    2200:	mov    rax,rbx
    2203:	mov    rdx,r13
    2206:	jmp    1f5c <botlish_fn_20+0x44>
    220b:	mov    rax,r14
    220e:	mov    rbx,QWORD PTR [rsp+0x50]
    2213:	mov    r12,QWORD PTR [rsp+0x58]
    2218:	mov    r13,QWORD PTR [rsp+0x60]
    221d:	mov    r14,QWORD PTR [rsp+0x68]
    2222:	mov    r15,QWORD PTR [rsp+0x70]
    2227:	add    rsp,0x80
    222e:	mov    rsp,rbp
    2231:	pop    rbp
    2232:	ret
    2233:	add    BYTE PTR [rax],al
    2235:	add    BYTE PTR [rax],al
    2237:	add    BYTE PTR [rsi],al
    2239:	add    BYTE PTR [rax],al
    223b:	add    BYTE PTR [rax],al
    223d:	add    BYTE PTR [rax],al
	...

0000000000002240 <botlish_entry_20: scan_local<generic>>:
    2240:	push   rbp
    2241:	mov    rbp,rsp
    2244:	mov    rsi,QWORD PTR [rdx]
    2247:	mov    r8,QWORD PTR [rdx+0x8]
    224b:	mov    rcx,QWORD PTR [rdx+0x10]
    224f:	mov    rdx,r8
    2252:	call   2257 <botlish_entry_20+0x17>
			2253: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    2257:	mov    rsp,rbp
    225a:	pop    rbp
    225b:	ret
    225c:	add    BYTE PTR [rax],al
	...

0000000000002260 <botlish_fn_21: scan_label<generic>>:
    2260:	push   rbp
    2261:	mov    rbp,rsp
    2264:	sub    rsp,0x80
    226b:	mov    QWORD PTR [rsp+0x50],rbx
    2270:	mov    QWORD PTR [rsp+0x58],r12
    2275:	mov    QWORD PTR [rsp+0x60],r13
    227a:	mov    QWORD PTR [rsp+0x68],r14
    227f:	mov    QWORD PTR [rsp+0x70],r15
    2284:	mov    QWORD PTR [rsp+0x18],0x0
    228d:	mov    QWORD PTR [rsp],rsi
    2291:	mov    r14,rsi
    2294:	mov    QWORD PTR [rsp+0x8],rdx
    2299:	mov    QWORD PTR [rsp+0x10],rcx
    229e:	mov    r12,rcx
    22a1:	mov    r11d,0x1
    22a7:	mov    rsi,r14
    22aa:	test   rsi,0x1
    22b1:	jne    22d1 <botlish_fn_21+0x71>
    22b7:	xor    r11d,r11d
    22ba:	test   rsi,0x7
    22c1:	jne    22d1 <botlish_fn_21+0x71>
    22c7:	movzx  rax,BYTE PTR [rsi]
    22cb:	cmp    al,0x1
    22cd:	sete   r11b
    22d1:	test   r11b,r11b
    22d4:	jne    22f2 <botlish_fn_21+0x92>
    22da:	mov    rax,QWORD PTR [rdi+0x10]
    22de:	mov    rcx,QWORD PTR [rax+0xc8]
    22e5:	xor    rdx,rdx
    22e8:	call   22ed <botlish_fn_21+0x8d>
			22e9: R_X86_64_PLT32	rt_type_error-0x4
    22ed:	jmp    239e <botlish_fn_21+0x13e>
    22f2:	mov    r13,rdx
    22f5:	mov    rax,rsi
    22f8:	and    rax,r13
    22fb:	mov    r14,rsi
    22fe:	test   rax,0x1
    2304:	jne    232d <botlish_fn_21+0xcd>
    230a:	mov    rbx,rdi
    230d:	mov    rdx,r13
    2310:	mov    rsi,r14
    2313:	call   2318 <botlish_fn_21+0xb8>
			2314: R_X86_64_PLT32	rt_int_cmp-0x4
    2318:	mov    ecx,0x2
    231d:	test   rax,rax
    2320:	cmovge rcx,QWORD PTR [rip+0x178]        # 24a0 <botlish_fn_21+0x240>
    2328:	jmp    2343 <botlish_fn_21+0xe3>
    232d:	mov    rbx,rdi
    2330:	mov    ecx,0x2
    2335:	mov    rsi,r14
    2338:	cmp    rsi,r13
    233b:	cmovge rcx,QWORD PTR [rip+0x15d]        # 24a0 <botlish_fn_21+0x240>
    2343:	mov    eax,0x6
    2348:	mov    QWORD PTR [rsp+0x30],rax
    234d:	cmp    rcx,0x6
    2351:	je     2474 <botlish_fn_21+0x214>
    2357:	lea    rcx,[rsp+0x20]
    235c:	mov    rdx,r12
    235f:	mov    rsi,r14
    2362:	mov    rdi,rbx
    2365:	call   236a <botlish_fn_21+0x10a>
			2366: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    236a:	test   rax,rax
    236d:	mov    r15,rax
    2370:	je     239e <botlish_fn_21+0x13e>
    2376:	mov    rdx,QWORD PTR [rsp+0x20]
    237b:	mov    QWORD PTR [rsp+0x40],rdx
    2380:	mov    rcx,QWORD PTR [rsp+0x28]
    2385:	mov    QWORD PTR [rsp+0x38],rcx
    238a:	mov    rsi,r15
    238d:	mov    rdi,rbx
    2390:	call   2395 <botlish_fn_21+0x135>
			2391: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    2395:	test   rax,rax
    2398:	jne    23c6 <botlish_fn_21+0x166>
    239e:	xor    rax,rax
    23a1:	mov    rbx,QWORD PTR [rsp+0x50]
    23a6:	mov    r12,QWORD PTR [rsp+0x58]
    23ab:	mov    r13,QWORD PTR [rsp+0x60]
    23b0:	mov    r14,QWORD PTR [rsp+0x68]
    23b5:	mov    r15,QWORD PTR [rsp+0x70]
    23ba:	add    rsp,0x80
    23c1:	mov    rsp,rbp
    23c4:	pop    rbp
    23c5:	ret
    23c6:	cmp    rax,0x6
    23ca:	je     23f5 <botlish_fn_21+0x195>
    23d0:	mov    r11,QWORD PTR [rbx+0x10]
    23d4:	mov    r8,QWORD PTR [r11+0x138]
    23db:	mov    rcx,QWORD PTR [rsp+0x38]
    23e0:	mov    rdx,QWORD PTR [rsp+0x40]
    23e5:	mov    rsi,r15
    23e8:	mov    rdi,rbx
    23eb:	call   23f0 <botlish_fn_21+0x190>
			23ec: R_X86_64_PLT32	rt_str_region_eq-0x4
    23f0:	jmp    23fa <botlish_fn_21+0x19a>
    23f5:	mov    rax,QWORD PTR [rsp+0x30]
    23fa:	cmp    rax,0x6
    23fe:	je     240c <botlish_fn_21+0x1ac>
    2404:	mov    rax,r14
    2407:	jmp    2477 <botlish_fn_21+0x217>
    240c:	mov    QWORD PTR [rsp+0x18],0x3
    2415:	mov    rsi,r14
    2418:	test   rsi,0x1
    241f:	je     2445 <botlish_fn_21+0x1e5>
    2425:	mov    rsi,r14
    2428:	mov    rax,rsi
    242b:	add    rax,0x2
    242f:	seto   cl
    2432:	test   cl,cl
    2434:	jne    2445 <botlish_fn_21+0x1e5>
    243a:	mov    rsi,rax
    243d:	mov    r14,rax
    2440:	jmp    245b <botlish_fn_21+0x1fb>
    2445:	mov    edx,0x3
    244a:	mov    rsi,r14
    244d:	mov    rdi,rbx
    2450:	call   2455 <botlish_fn_21+0x1f5>
			2451: R_X86_64_PLT32	rt_int_add-0x4
    2455:	mov    rsi,rax
    2458:	mov    r14,rax
    245b:	mov    QWORD PTR [rsp],rsi
    245f:	mov    QWORD PTR [rsp+0x8],r13
    2464:	mov    QWORD PTR [rsp+0x10],r12
    2469:	mov    rdx,r13
    246c:	mov    rdi,rbx
    246f:	jmp    22a1 <botlish_fn_21+0x41>
    2474:	mov    rax,r14
    2477:	mov    rbx,QWORD PTR [rsp+0x50]
    247c:	mov    r12,QWORD PTR [rsp+0x58]
    2481:	mov    r13,QWORD PTR [rsp+0x60]
    2486:	mov    r14,QWORD PTR [rsp+0x68]
    248b:	mov    r15,QWORD PTR [rsp+0x70]
    2490:	add    rsp,0x80
    2497:	mov    rsp,rbp
    249a:	pop    rbp
    249b:	ret
    249c:	add    BYTE PTR [rax],al
    249e:	add    BYTE PTR [rax],al
    24a0:	(bad)
    24a1:	add    BYTE PTR [rax],al
    24a3:	add    BYTE PTR [rax],al
    24a5:	add    BYTE PTR [rax],al
	...

00000000000024a8 <botlish_entry_21: scan_label<generic>>:
    24a8:	push   rbp
    24a9:	mov    rbp,rsp
    24ac:	mov    rsi,QWORD PTR [rdx]
    24af:	mov    r8,QWORD PTR [rdx+0x8]
    24b3:	mov    rcx,QWORD PTR [rdx+0x10]
    24b7:	mov    rdx,r8
    24ba:	call   24bf <botlish_entry_21+0x17>
			24bb: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    24bf:	mov    rsp,rbp
    24c2:	pop    rbp
    24c3:	ret
    24c4:	add    BYTE PTR [rax],al
	...

00000000000024c8 <botlish_fn_22: scan_alpha<generic>>:
    24c8:	push   rbp
    24c9:	mov    rbp,rsp
    24cc:	sub    rsp,0x50
    24d0:	mov    QWORD PTR [rsp+0x30],rbx
    24d5:	mov    QWORD PTR [rsp+0x38],r12
    24da:	mov    QWORD PTR [rsp+0x40],r13
    24df:	mov    QWORD PTR [rsp+0x48],r14
    24e4:	mov    r14,rdi
    24e7:	mov    QWORD PTR [rsp+0x18],0x0
    24f0:	mov    QWORD PTR [rsp],rsi
    24f4:	mov    r13,rsi
    24f7:	mov    QWORD PTR [rsp+0x8],rdx
    24fc:	mov    r12,rdx
    24ff:	mov    QWORD PTR [rsp+0x10],rcx
    2504:	mov    rbx,rcx
    2507:	mov    r11d,0x1
    250d:	mov    rsi,r13
    2510:	test   rsi,0x1
    2517:	jne    2537 <botlish_fn_22+0x6f>
    251d:	xor    r11d,r11d
    2520:	test   rsi,0x7
    2527:	jne    2537 <botlish_fn_22+0x6f>
    252d:	movzx  rax,BYTE PTR [rsi]
    2531:	cmp    al,0x1
    2533:	sete   r11b
    2537:	test   r11b,r11b
    253a:	jne    255b <botlish_fn_22+0x93>
    2540:	mov    rdi,r14
    2543:	mov    rax,QWORD PTR [rdi+0x10]
    2547:	mov    rcx,QWORD PTR [rax+0xc8]
    254e:	xor    rdx,rdx
    2551:	call   2556 <botlish_fn_22+0x8e>
			2552: R_X86_64_PLT32	rt_type_error-0x4
    2556:	jmp    25ea <botlish_fn_22+0x122>
    255b:	mov    rax,rsi
    255e:	and    rax,r12
    2561:	mov    r13,rsi
    2564:	test   rax,0x1
    256a:	jne    2593 <botlish_fn_22+0xcb>
    2570:	mov    rdx,r12
    2573:	mov    rsi,r13
    2576:	mov    rdi,r14
    2579:	call   257e <botlish_fn_22+0xb6>
			257a: R_X86_64_PLT32	rt_int_cmp-0x4
    257e:	mov    ecx,0x2
    2583:	test   rax,rax
    2586:	cmovge rcx,QWORD PTR [rip+0x112]        # 26a0 <botlish_fn_22+0x1d8>
    258e:	jmp    25a6 <botlish_fn_22+0xde>
    2593:	mov    ecx,0x2
    2598:	mov    rsi,r13
    259b:	cmp    rsi,r12
    259e:	cmovge rcx,QWORD PTR [rip+0xfa]        # 26a0 <botlish_fn_22+0x1d8>
    25a6:	cmp    rcx,0x6
    25aa:	je     267e <botlish_fn_22+0x1b6>
    25b0:	lea    rcx,[rsp+0x20]
    25b5:	mov    rdx,rbx
    25b8:	mov    rsi,r13
    25bb:	mov    rdi,r14
    25be:	call   25c3 <botlish_fn_22+0xfb>
			25bf: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    25c3:	test   rax,rax
    25c6:	mov    rsi,rax
    25c9:	je     25ea <botlish_fn_22+0x122>
    25cf:	mov    rdx,QWORD PTR [rsp+0x20]
    25d4:	mov    rcx,QWORD PTR [rsp+0x28]
    25d9:	mov    rdi,r14
    25dc:	call   25e1 <botlish_fn_22+0x119>
			25dd: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    25e1:	test   rax,rax
    25e4:	jne    260a <botlish_fn_22+0x142>
    25ea:	xor    rax,rax
    25ed:	mov    rbx,QWORD PTR [rsp+0x30]
    25f2:	mov    r12,QWORD PTR [rsp+0x38]
    25f7:	mov    r13,QWORD PTR [rsp+0x40]
    25fc:	mov    r14,QWORD PTR [rsp+0x48]
    2601:	add    rsp,0x50
    2605:	mov    rsp,rbp
    2608:	pop    rbp
    2609:	ret
    260a:	cmp    rax,0x6
    260e:	je     261c <botlish_fn_22+0x154>
    2614:	mov    rax,r13
    2617:	jmp    2681 <botlish_fn_22+0x1b9>
    261c:	mov    QWORD PTR [rsp+0x18],0x3
    2625:	mov    rsi,r13
    2628:	test   rsi,0x1
    262f:	je     2655 <botlish_fn_22+0x18d>
    2635:	mov    rsi,r13
    2638:	mov    r11,rsi
    263b:	add    r11,0x2
    263f:	seto   al
    2642:	test   al,al
    2644:	jne    2655 <botlish_fn_22+0x18d>
    264a:	mov    rsi,r11
    264d:	mov    r13,r11
    2650:	jmp    266b <botlish_fn_22+0x1a3>
    2655:	mov    edx,0x3
    265a:	mov    rsi,r13
    265d:	mov    rdi,r14
    2660:	call   2665 <botlish_fn_22+0x19d>
			2661: R_X86_64_PLT32	rt_int_add-0x4
    2665:	mov    rsi,rax
    2668:	mov    r13,rax
    266b:	mov    QWORD PTR [rsp],rsi
    266f:	mov    QWORD PTR [rsp+0x8],r12
    2674:	mov    QWORD PTR [rsp+0x10],rbx
    2679:	jmp    2507 <botlish_fn_22+0x3f>
    267e:	mov    rax,r13
    2681:	mov    rbx,QWORD PTR [rsp+0x30]
    2686:	mov    r12,QWORD PTR [rsp+0x38]
    268b:	mov    r13,QWORD PTR [rsp+0x40]
    2690:	mov    r14,QWORD PTR [rsp+0x48]
    2695:	add    rsp,0x50
    2699:	mov    rsp,rbp
    269c:	pop    rbp
    269d:	ret
    269e:	add    BYTE PTR [rax],al
    26a0:	(bad)
    26a1:	add    BYTE PTR [rax],al
    26a3:	add    BYTE PTR [rax],al
    26a5:	add    BYTE PTR [rax],al
	...

00000000000026a8 <botlish_entry_22: scan_alpha<generic>>:
    26a8:	push   rbp
    26a9:	mov    rbp,rsp
    26ac:	mov    rsi,QWORD PTR [rdx]
    26af:	mov    r8,QWORD PTR [rdx+0x8]
    26b3:	mov    rcx,QWORD PTR [rdx+0x10]
    26b7:	mov    rdx,r8
    26ba:	call   26bf <botlish_entry_22+0x17>
			26bb: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    26bf:	mov    rsp,rbp
    26c2:	pop    rbp
    26c3:	ret
    26c4:	add    BYTE PTR [rax],al
	...

00000000000026c8 <botlish_fn_23: tld_ok<generic>>:
    26c8:	push   rbp
    26c9:	mov    rbp,rsp
    26cc:	sub    rsp,0x40
    26d0:	mov    QWORD PTR [rsp+0x20],rbx
    26d5:	mov    QWORD PTR [rsp+0x28],r12
    26da:	mov    QWORD PTR [rsp+0x30],r13
    26df:	mov    QWORD PTR [rsp+0x38],r14
    26e4:	mov    rbx,rdi
    26e7:	mov    QWORD PTR [rsp],rsi
    26eb:	mov    r12,rsi
    26ee:	mov    QWORD PTR [rsp+0x8],rdx
    26f3:	mov    r14,rdx
    26f6:	mov    QWORD PTR [rsp+0x10],rcx
    26fb:	mov    rdx,r14
    26fe:	mov    rsi,r12
    2701:	mov    rdi,rbx
    2704:	call   2709 <botlish_fn_23+0x41>
			2705: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    2709:	mov    rsi,rax
    270c:	mov    r13,rax
    270f:	test   rax,rsi
    2712:	je     27d5 <botlish_fn_23+0x10d>
    2718:	mov    rax,r13
    271b:	mov    QWORD PTR [rsp+0x8],rax
    2720:	mov    rdx,r14
    2723:	and    rax,rdx
    2726:	test   rax,0x1
    272c:	jne    2755 <botlish_fn_23+0x8d>
    2732:	mov    rsi,r13
    2735:	mov    rdi,rbx
    2738:	call   273d <botlish_fn_23+0x75>
			2739: R_X86_64_PLT32	rt_int_cmp-0x4
    273d:	mov    ecx,0x2
    2742:	test   rax,rax
    2745:	cmove  rcx,QWORD PTR [rip+0x15b]        # 28a8 <botlish_fn_23+0x1e0>
    274d:	mov    rax,r13
    2750:	jmp    2768 <botlish_fn_23+0xa0>
    2755:	mov    ecx,0x2
    275a:	mov    rax,r13
    275d:	cmp    rax,rdx
    2760:	cmove  rcx,QWORD PTR [rip+0x140]        # 28a8 <botlish_fn_23+0x1e0>
    2768:	cmp    rcx,0x6
    276c:	je     277f <botlish_fn_23+0xb7>
    2772:	mov    ecx,0x2
    2777:	mov    rax,rcx
    277a:	jmp    2887 <botlish_fn_23+0x1bf>
    277f:	mov    ecx,0x1
    2784:	mov    rsi,r12
    2787:	test   rsi,0x1
    278e:	jne    27b4 <botlish_fn_23+0xec>
    2794:	xor    ecx,ecx
    2796:	mov    rsi,r12
    2799:	test   rsi,0x7
    27a0:	jne    27b4 <botlish_fn_23+0xec>
    27a6:	mov    rsi,r12
    27a9:	movzx  rcx,BYTE PTR [rsi]
    27ad:	rex cmp cl,0x1
    27b1:	sete   cl
    27b4:	test   cl,cl
    27b6:	jne    27f5 <botlish_fn_23+0x12d>
    27bc:	mov    rdi,rbx
    27bf:	mov    rsi,QWORD PTR [rdi+0x10]
    27c3:	mov    rcx,QWORD PTR [rsi+0x138]
    27ca:	xor    rdx,rdx
    27cd:	mov    rsi,r12
    27d0:	call   27d5 <botlish_fn_23+0x10d>
			27d1: R_X86_64_PLT32	rt_type_error-0x4
    27d5:	xor    rax,rax
    27d8:	mov    rbx,QWORD PTR [rsp+0x20]
    27dd:	mov    r12,QWORD PTR [rsp+0x28]
    27e2:	mov    r13,QWORD PTR [rsp+0x30]
    27e7:	mov    r14,QWORD PTR [rsp+0x38]
    27ec:	add    rsp,0x40
    27f0:	mov    rsp,rbp
    27f3:	pop    rbp
    27f4:	ret
    27f5:	mov    rsi,r12
    27f8:	mov    rdi,rax
    27fb:	and    rdi,rsi
    27fe:	test   rdi,0x1
    2805:	jne    2816 <botlish_fn_23+0x14e>
    280b:	mov    rdx,r12
    280e:	mov    rsi,rax
    2811:	jmp    2839 <botlish_fn_23+0x171>
    2816:	mov    rsi,r12
    2819:	mov    r8,rax
    281c:	sub    r8,rsi
    281f:	mov    r13,rax
    2822:	seto   r10b
    2826:	lea    rsi,[r8+0x1]
    282a:	test   r10b,r10b
    282d:	je     2844 <botlish_fn_23+0x17c>
    2833:	mov    rdx,r12
    2836:	mov    rsi,r13
    2839:	mov    rdi,rbx
    283c:	call   2841 <botlish_fn_23+0x179>
			283d: R_X86_64_PLT32	rt_int_sub-0x4
    2841:	mov    rsi,rax
    2844:	test   rsi,0x1
    284b:	jne    2876 <botlish_fn_23+0x1ae>
    2851:	mov    edx,0x5
    2856:	mov    rdi,rbx
    2859:	call   285e <botlish_fn_23+0x196>
			285a: R_X86_64_PLT32	rt_int_cmp-0x4
    285e:	mov    ecx,0x2
    2863:	test   rax,rax
    2866:	mov    rax,rcx
    2869:	cmovge rax,QWORD PTR [rip+0x37]        # 28a8 <botlish_fn_23+0x1e0>
    2871:	jmp    2887 <botlish_fn_23+0x1bf>
    2876:	mov    eax,0x2
    287b:	cmp    rsi,0x5
    287f:	cmovge rax,QWORD PTR [rip+0x21]        # 28a8 <botlish_fn_23+0x1e0>
    2887:	mov    rbx,QWORD PTR [rsp+0x20]
    288c:	mov    r12,QWORD PTR [rsp+0x28]
    2891:	mov    r13,QWORD PTR [rsp+0x30]
    2896:	mov    r14,QWORD PTR [rsp+0x38]
    289b:	add    rsp,0x40
    289f:	mov    rsp,rbp
    28a2:	pop    rbp
    28a3:	ret
    28a4:	add    BYTE PTR [rax],al
    28a6:	add    BYTE PTR [rax],al
    28a8:	(bad)
    28a9:	add    BYTE PTR [rax],al
    28ab:	add    BYTE PTR [rax],al
    28ad:	add    BYTE PTR [rax],al
	...

00000000000028b0 <botlish_entry_23: tld_ok<generic>>:
    28b0:	push   rbp
    28b1:	mov    rbp,rsp
    28b4:	mov    rsi,QWORD PTR [rdx]
    28b7:	mov    r8,QWORD PTR [rdx+0x8]
    28bb:	mov    rcx,QWORD PTR [rdx+0x10]
    28bf:	mov    rdx,r8
    28c2:	call   28c7 <botlish_entry_23+0x17>
			28c3: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    28c7:	mov    rsp,rbp
    28ca:	pop    rbp
    28cb:	ret
    28cc:	add    BYTE PTR [rax],al
	...

00000000000028d0 <botlish_fn_24: domain_loop<generic>>:
    28d0:	push   rbp
    28d1:	mov    rbp,rsp
    28d4:	sub    rsp,0x70
    28d8:	mov    QWORD PTR [rsp+0x40],rbx
    28dd:	mov    QWORD PTR [rsp+0x48],r12
    28e2:	mov    QWORD PTR [rsp+0x50],r13
    28e7:	mov    QWORD PTR [rsp+0x58],r14
    28ec:	mov    QWORD PTR [rsp+0x60],r15
    28f1:	mov    QWORD PTR [rsp+0x18],0x0
    28fa:	mov    QWORD PTR [rsp],rsi
    28fe:	mov    QWORD PTR [rsp+0x8],rdx
    2903:	mov    QWORD PTR [rsp+0x10],rcx
    2908:	lea    rbx,[rsp+0x20]
    290d:	mov    r12,rdi
    2910:	mov    r13,rcx
    2913:	mov    r14,rdx
    2916:	mov    QWORD PTR [rsp+0x30],rsi
    291b:	mov    rcx,r13
    291e:	mov    rdx,r14
    2921:	mov    rsi,QWORD PTR [rsp+0x30]
    2926:	mov    rdi,r12
    2929:	call   292e <botlish_fn_24+0x5e>
			292a: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    292e:	mov    rcx,rax
    2931:	mov    r15,rax
    2934:	test   rax,rcx
    2937:	je     2a87 <botlish_fn_24+0x1b7>
    293d:	mov    rax,r15
    2940:	mov    QWORD PTR [rsp],rax
    2944:	mov    rdx,QWORD PTR [rsp+0x30]
    2949:	and    rax,rdx
    294c:	test   rax,0x1
    2952:	jne    2971 <botlish_fn_24+0xa1>
    2958:	mov    rsi,r15
    295b:	mov    rdi,r12
    295e:	call   2963 <botlish_fn_24+0x93>
			295f: R_X86_64_PLT32	rt_value_eq-0x4
    2963:	test   rax,rax
    2966:	je     2a87 <botlish_fn_24+0x1b7>
    296c:	jmp    2981 <botlish_fn_24+0xb1>
    2971:	mov    eax,0x2
    2976:	cmp    r15,rdx
    2979:	cmove  rax,QWORD PTR [rip+0x187]        # 2b08 <botlish_fn_24+0x238>
    2981:	cmp    rax,0x6
    2985:	je     2add <botlish_fn_24+0x20d>
    298b:	mov    rax,r15
    298e:	and    rax,r14
    2991:	test   rax,0x1
    2997:	jne    29c0 <botlish_fn_24+0xf0>
    299d:	mov    rdx,r14
    29a0:	mov    rsi,r15
    29a3:	mov    rdi,r12
    29a6:	call   29ab <botlish_fn_24+0xdb>
			29a7: R_X86_64_PLT32	rt_int_cmp-0x4
    29ab:	mov    ecx,0x2
    29b0:	test   rax,rax
    29b3:	cmovge rcx,QWORD PTR [rip+0x14d]        # 2b08 <botlish_fn_24+0x238>
    29bb:	jmp    29d0 <botlish_fn_24+0x100>
    29c0:	mov    ecx,0x2
    29c5:	cmp    r15,r14
    29c8:	cmovge rcx,QWORD PTR [rip+0x138]        # 2b08 <botlish_fn_24+0x238>
    29d0:	cmp    rcx,0x6
    29d4:	je     2ace <botlish_fn_24+0x1fe>
    29da:	mov    rcx,rbx
    29dd:	mov    rdx,r13
    29e0:	mov    rsi,r15
    29e3:	mov    rdi,r12
    29e6:	call   29eb <botlish_fn_24+0x11b>
			29e7: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    29eb:	test   rax,rax
    29ee:	je     2a87 <botlish_fn_24+0x1b7>
    29f4:	mov    rdx,QWORD PTR [rsp+0x20]
    29f9:	mov    rcx,QWORD PTR [rsp+0x28]
    29fe:	mov    rsi,QWORD PTR [r12+0x10]
    2a03:	mov    r8,QWORD PTR [rsi+0x128]
    2a0a:	mov    rsi,rax
    2a0d:	mov    rdi,r12
    2a10:	call   2a15 <botlish_fn_24+0x145>
			2a11: R_X86_64_PLT32	rt_str_region_eq-0x4
    2a15:	cmp    rax,0x6
    2a19:	je     2a2b <botlish_fn_24+0x15b>
    2a1f:	mov    r14,0xffffffffffffffff
    2a26:	jmp    2ad5 <botlish_fn_24+0x205>
    2a2b:	mov    QWORD PTR [rsp+0x18],0x3
    2a34:	test   r15,0x1
    2a3b:	je     2a53 <botlish_fn_24+0x183>
    2a41:	mov    rdx,r15
    2a44:	add    rdx,0x2
    2a48:	seto   al
    2a4b:	test   al,al
    2a4d:	je     2a66 <botlish_fn_24+0x196>
    2a53:	mov    edx,0x3
    2a58:	mov    rsi,r15
    2a5b:	mov    rdi,r12
    2a5e:	call   2a63 <botlish_fn_24+0x193>
			2a5f: R_X86_64_PLT32	rt_int_add-0x4
    2a63:	mov    rdx,rax
    2a66:	mov    QWORD PTR [rsp],rdx
    2a6a:	mov    r15,rdx
    2a6d:	mov    rcx,r13
    2a70:	mov    rdx,r14
    2a73:	mov    rsi,r15
    2a76:	mov    rdi,r12
    2a79:	call   2a7e <botlish_fn_24+0x1ae>
			2a7a: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    2a7e:	test   rax,rax
    2a81:	jne    2aac <botlish_fn_24+0x1dc>
    2a87:	xor    rax,rax
    2a8a:	mov    rbx,QWORD PTR [rsp+0x40]
    2a8f:	mov    r12,QWORD PTR [rsp+0x48]
    2a94:	mov    r13,QWORD PTR [rsp+0x50]
    2a99:	mov    r14,QWORD PTR [rsp+0x58]
    2a9e:	mov    r15,QWORD PTR [rsp+0x60]
    2aa3:	add    rsp,0x70
    2aa7:	mov    rsp,rbp
    2aaa:	pop    rbp
    2aab:	ret
    2aac:	cmp    rax,0x6
    2ab0:	je     2ad5 <botlish_fn_24+0x205>
    2ab6:	mov    QWORD PTR [rsp],r15
    2aba:	mov    QWORD PTR [rsp+0x8],r14
    2abf:	mov    QWORD PTR [rsp+0x10],r13
    2ac4:	mov    QWORD PTR [rsp+0x30],r15
    2ac9:	jmp    291b <botlish_fn_24+0x4b>
    2ace:	mov    r14,0xffffffffffffffff
    2ad5:	mov    rax,r14
    2ad8:	jmp    2ae4 <botlish_fn_24+0x214>
    2add:	mov    rax,0xffffffffffffffff
    2ae4:	mov    rbx,QWORD PTR [rsp+0x40]
    2ae9:	mov    r12,QWORD PTR [rsp+0x48]
    2aee:	mov    r13,QWORD PTR [rsp+0x50]
    2af3:	mov    r14,QWORD PTR [rsp+0x58]
    2af8:	mov    r15,QWORD PTR [rsp+0x60]
    2afd:	add    rsp,0x70
    2b01:	mov    rsp,rbp
    2b04:	pop    rbp
    2b05:	ret
    2b06:	add    BYTE PTR [rax],al
    2b08:	(bad)
    2b09:	add    BYTE PTR [rax],al
    2b0b:	add    BYTE PTR [rax],al
    2b0d:	add    BYTE PTR [rax],al
	...

0000000000002b10 <botlish_entry_24: domain_loop<generic>>:
    2b10:	push   rbp
    2b11:	mov    rbp,rsp
    2b14:	mov    rsi,QWORD PTR [rdx]
    2b17:	mov    r8,QWORD PTR [rdx+0x8]
    2b1b:	mov    rcx,QWORD PTR [rdx+0x10]
    2b1f:	mov    rdx,r8
    2b22:	call   2b27 <botlish_entry_24+0x17>
			2b23: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    2b27:	mov    rsp,rbp
    2b2a:	pop    rbp
    2b2b:	ret
    2b2c:	add    BYTE PTR [rax],al
	...

0000000000002b30 <botlish_fn_25: <str>>:
    2b30:	push   rbp
    2b31:	mov    rbp,rsp
    2b34:	sub    rsp,0x50
    2b38:	mov    QWORD PTR [rsp+0x30],rbx
    2b3d:	mov    QWORD PTR [rsp+0x38],r12
    2b42:	mov    QWORD PTR [rsp+0x40],r13
    2b47:	mov    QWORD PTR [rsp+0x48],r14
    2b4c:	mov    r13,rdi
    2b4f:	mov    QWORD PTR [rsp+0x18],0x0
    2b58:	mov    QWORD PTR [rsp],rsi
    2b5c:	mov    r14,rsi
    2b5f:	mov    rsi,r14
    2b62:	mov    rdi,r13
    2b65:	call   2b6a <botlish_fn_25+0x3a>
			2b66: R_X86_64_PLT32	rt_str_len-0x4
    2b6a:	mov    rbx,rax
    2b6d:	mov    QWORD PTR [rsp+0x8],rax
    2b72:	mov    esi,0x1
    2b77:	mov    QWORD PTR [rsp+0x10],0x1
    2b80:	mov    rcx,r14
    2b83:	mov    rdx,rbx
    2b86:	mov    rdi,r13
    2b89:	call   2b8e <botlish_fn_25+0x5e>
			2b8a: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    2b8e:	mov    r12,rax
    2b91:	test   r12,r12
    2b94:	je     2cf1 <botlish_fn_25+0x1c1>
    2b9a:	mov    QWORD PTR [rsp+0x10],r12
    2b9f:	test   r12,0x1
    2ba6:	jne    2bd1 <botlish_fn_25+0xa1>
    2bac:	mov    edx,0x1
    2bb1:	mov    rsi,r12
    2bb4:	mov    rdi,r13
    2bb7:	call   2bbc <botlish_fn_25+0x8c>
			2bb8: R_X86_64_PLT32	rt_int_cmp-0x4
    2bbc:	mov    ecx,0x2
    2bc1:	test   rax,rax
    2bc4:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 2d90 <botlish_fn_25+0x260>
    2bcc:	jmp    2be2 <botlish_fn_25+0xb2>
    2bd1:	mov    ecx,0x2
    2bd6:	cmp    r12,0x1
    2bda:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 2d90 <botlish_fn_25+0x260>
    2be2:	cmp    rcx,0x6
    2be6:	je     2d6c <botlish_fn_25+0x23c>
    2bec:	mov    rcx,r12
    2bef:	and    rcx,rbx
    2bf2:	test   rcx,0x1
    2bf9:	jne    2c22 <botlish_fn_25+0xf2>
    2bff:	mov    rdx,rbx
    2c02:	mov    rsi,r12
    2c05:	mov    rdi,r13
    2c08:	call   2c0d <botlish_fn_25+0xdd>
			2c09: R_X86_64_PLT32	rt_int_cmp-0x4
    2c0d:	mov    ecx,0x2
    2c12:	test   rax,rax
    2c15:	cmovge rcx,QWORD PTR [rip+0x173]        # 2d90 <botlish_fn_25+0x260>
    2c1d:	jmp    2c32 <botlish_fn_25+0x102>
    2c22:	mov    ecx,0x2
    2c27:	cmp    r12,rbx
    2c2a:	cmovge rcx,QWORD PTR [rip+0x15e]        # 2d90 <botlish_fn_25+0x260>
    2c32:	cmp    rcx,0x6
    2c36:	je     2d62 <botlish_fn_25+0x232>
    2c3c:	lea    rcx,[rsp+0x20]
    2c41:	mov    rdx,r14
    2c44:	mov    rsi,r12
    2c47:	mov    rdi,r13
    2c4a:	call   2c4f <botlish_fn_25+0x11f>
			2c4b: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    2c4f:	test   rax,rax
    2c52:	mov    rsi,rax
    2c55:	je     2cf1 <botlish_fn_25+0x1c1>
    2c5b:	mov    rdx,QWORD PTR [rsp+0x20]
    2c60:	mov    rcx,QWORD PTR [rsp+0x28]
    2c65:	mov    rdi,r13
    2c68:	mov    rax,QWORD PTR [rdi+0x10]
    2c6c:	mov    r8,QWORD PTR [rax+0x110]
    2c73:	call   2c78 <botlish_fn_25+0x148>
			2c74: R_X86_64_PLT32	rt_str_region_eq-0x4
    2c78:	cmp    rax,0x6
    2c7c:	je     2c8f <botlish_fn_25+0x15f>
    2c82:	mov    ecx,0x2
    2c87:	mov    rax,rcx
    2c8a:	jmp    2d71 <botlish_fn_25+0x241>
    2c8f:	mov    QWORD PTR [rsp+0x18],0x3
    2c98:	test   r12,0x1
    2c9f:	jne    2cad <botlish_fn_25+0x17d>
    2ca5:	mov    rcx,r12
    2ca8:	jmp    2cc2 <botlish_fn_25+0x192>
    2cad:	mov    rsi,r12
    2cb0:	add    rsi,0x2
    2cb4:	mov    rcx,r12
    2cb7:	seto   al
    2cba:	test   al,al
    2cbc:	je     2cd5 <botlish_fn_25+0x1a5>
    2cc2:	mov    edx,0x3
    2cc7:	mov    rsi,rcx
    2cca:	mov    rdi,r13
    2ccd:	call   2cd2 <botlish_fn_25+0x1a2>
			2cce: R_X86_64_PLT32	rt_int_add-0x4
    2cd2:	mov    rsi,rax
    2cd5:	mov    QWORD PTR [rsp+0x10],rsi
    2cda:	mov    rcx,r14
    2cdd:	mov    rdx,rbx
    2ce0:	mov    rdi,r13
    2ce3:	call   2ce8 <botlish_fn_25+0x1b8>
			2ce4: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    2ce8:	test   rax,rax
    2ceb:	jne    2d11 <botlish_fn_25+0x1e1>
    2cf1:	xor    rax,rax
    2cf4:	mov    rbx,QWORD PTR [rsp+0x30]
    2cf9:	mov    r12,QWORD PTR [rsp+0x38]
    2cfe:	mov    r13,QWORD PTR [rsp+0x40]
    2d03:	mov    r14,QWORD PTR [rsp+0x48]
    2d08:	add    rsp,0x50
    2d0c:	mov    rsp,rbp
    2d0f:	pop    rbp
    2d10:	ret
    2d11:	mov    rcx,rax
    2d14:	and    rcx,rbx
    2d17:	mov    rsi,rax
    2d1a:	test   rcx,0x1
    2d21:	jne    2d4a <botlish_fn_25+0x21a>
    2d27:	mov    rdx,rbx
    2d2a:	mov    rdi,r13
    2d2d:	call   2d32 <botlish_fn_25+0x202>
			2d2e: R_X86_64_PLT32	rt_int_cmp-0x4
    2d32:	mov    ecx,0x2
    2d37:	test   rax,rax
    2d3a:	mov    rax,rcx
    2d3d:	cmove  rax,QWORD PTR [rip+0x4b]        # 2d90 <botlish_fn_25+0x260>
    2d45:	jmp    2d71 <botlish_fn_25+0x241>
    2d4a:	mov    rdx,rbx
    2d4d:	mov    eax,0x2
    2d52:	cmp    rsi,rdx
    2d55:	cmove  rax,QWORD PTR [rip+0x33]        # 2d90 <botlish_fn_25+0x260>
    2d5d:	jmp    2d71 <botlish_fn_25+0x241>
    2d62:	mov    eax,0x2
    2d67:	jmp    2d71 <botlish_fn_25+0x241>
    2d6c:	mov    eax,0x2
    2d71:	mov    rbx,QWORD PTR [rsp+0x30]
    2d76:	mov    r12,QWORD PTR [rsp+0x38]
    2d7b:	mov    r13,QWORD PTR [rsp+0x40]
    2d80:	mov    r14,QWORD PTR [rsp+0x48]
    2d85:	add    rsp,0x50
    2d89:	mov    rsp,rbp
    2d8c:	pop    rbp
    2d8d:	ret
    2d8e:	add    BYTE PTR [rax],al
    2d90:	(bad)
    2d91:	add    BYTE PTR [rax],al
    2d93:	add    BYTE PTR [rax],al
    2d95:	add    BYTE PTR [rax],al
	...

0000000000002d98 <botlish_entry_25: <str>>:
    2d98:	push   rbp
    2d99:	mov    rbp,rsp
    2d9c:	mov    rsi,QWORD PTR [rdx]
    2d9f:	call   2da4 <botlish_entry_25+0xc>
			2da0: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    2da4:	mov    rsp,rbp
    2da7:	pop    rbp
    2da8:	ret
    2da9:	add    BYTE PTR [rax],al
    2dab:	add    BYTE PTR [rax],al
    2dad:	add    BYTE PTR [rax],al
	...

0000000000002db0 <botlish_fn_26: <generic>>:
    2db0:	push   rbp
    2db1:	mov    rbp,rsp
    2db4:	sub    rsp,0x60
    2db8:	mov    QWORD PTR [rsp+0x30],rbx
    2dbd:	mov    QWORD PTR [rsp+0x38],r12
    2dc2:	mov    QWORD PTR [rsp+0x40],r13
    2dc7:	mov    QWORD PTR [rsp+0x48],r14
    2dcc:	mov    QWORD PTR [rsp+0x50],r15
    2dd1:	mov    QWORD PTR [rsp+0x18],0x0
    2dda:	mov    QWORD PTR [rsp],rsi
    2dde:	xor    r8d,r8d
    2de1:	test   rsi,0x7
    2de8:	jne    2df8 <botlish_fn_26+0x48>
    2dee:	movzx  rax,BYTE PTR [rsi]
    2df2:	cmp    al,0x2
    2df4:	sete   r8b
    2df8:	test   r8b,r8b
    2dfb:	jne    2e1b <botlish_fn_26+0x6b>
    2e01:	mov    rdx,QWORD PTR [rdi+0x10]
    2e05:	mov    rcx,QWORD PTR [rdx+0xe8]
    2e0c:	mov    edx,0x1
    2e11:	call   2e16 <botlish_fn_26+0x66>
			2e12: R_X86_64_PLT32	rt_type_error-0x4
    2e16:	jmp    2fb0 <botlish_fn_26+0x200>
    2e1b:	mov    r13,rsi
    2e1e:	mov    r14,rdi
    2e21:	call   2e26 <botlish_fn_26+0x76>
			2e22: R_X86_64_PLT32	rt_str_len-0x4
    2e26:	mov    rbx,rax
    2e29:	mov    QWORD PTR [rsp+0x8],rax
    2e2e:	mov    edx,0x1
    2e33:	mov    r15,rdx
    2e36:	mov    QWORD PTR [rsp+0x10],0x1
    2e3f:	mov    rcx,r13
    2e42:	mov    rdx,rbx
    2e45:	mov    rsi,r15
    2e48:	mov    rdi,r14
    2e4b:	call   2e50 <botlish_fn_26+0xa0>
			2e4c: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    2e50:	mov    r12,rax
    2e53:	test   r12,r12
    2e56:	je     2fb0 <botlish_fn_26+0x200>
    2e5c:	mov    QWORD PTR [rsp+0x10],r12
    2e61:	test   r12,0x1
    2e68:	jne    2e91 <botlish_fn_26+0xe1>
    2e6e:	mov    rdx,r15
    2e71:	mov    rsi,r12
    2e74:	mov    rdi,r14
    2e77:	call   2e7c <botlish_fn_26+0xcc>
			2e78: R_X86_64_PLT32	rt_int_cmp-0x4
    2e7c:	mov    ecx,0x2
    2e81:	test   rax,rax
    2e84:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 3058 <botlish_fn_26+0x2a8>
    2e8c:	jmp    2ea2 <botlish_fn_26+0xf2>
    2e91:	mov    ecx,0x2
    2e96:	cmp    r12,0x1
    2e9a:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 3058 <botlish_fn_26+0x2a8>
    2ea2:	cmp    rcx,0x6
    2ea6:	je     3030 <botlish_fn_26+0x280>
    2eac:	mov    rax,r12
    2eaf:	and    rax,rbx
    2eb2:	test   rax,0x1
    2eb8:	jne    2ee1 <botlish_fn_26+0x131>
    2ebe:	mov    rdx,rbx
    2ec1:	mov    rsi,r12
    2ec4:	mov    rdi,r14
    2ec7:	call   2ecc <botlish_fn_26+0x11c>
			2ec8: R_X86_64_PLT32	rt_int_cmp-0x4
    2ecc:	mov    ecx,0x2
    2ed1:	test   rax,rax
    2ed4:	cmovge rcx,QWORD PTR [rip+0x17c]        # 3058 <botlish_fn_26+0x2a8>
    2edc:	jmp    2ef1 <botlish_fn_26+0x141>
    2ee1:	mov    ecx,0x2
    2ee6:	cmp    r12,rbx
    2ee9:	cmovge rcx,QWORD PTR [rip+0x167]        # 3058 <botlish_fn_26+0x2a8>
    2ef1:	cmp    rcx,0x6
    2ef5:	je     3026 <botlish_fn_26+0x276>
    2efb:	lea    rcx,[rsp+0x20]
    2f00:	mov    rdx,r13
    2f03:	mov    rsi,r12
    2f06:	mov    rdi,r14
    2f09:	call   2f0e <botlish_fn_26+0x15e>
			2f0a: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    2f0e:	test   rax,rax
    2f11:	mov    rsi,rax
    2f14:	je     2fb0 <botlish_fn_26+0x200>
    2f1a:	mov    rdx,QWORD PTR [rsp+0x20]
    2f1f:	mov    rcx,QWORD PTR [rsp+0x28]
    2f24:	mov    rdi,r14
    2f27:	mov    rax,QWORD PTR [rdi+0x10]
    2f2b:	mov    r8,QWORD PTR [rax+0x110]
    2f32:	call   2f37 <botlish_fn_26+0x187>
			2f33: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f37:	cmp    rax,0x6
    2f3b:	je     2f4e <botlish_fn_26+0x19e>
    2f41:	mov    ecx,0x2
    2f46:	mov    rax,rcx
    2f49:	jmp    3035 <botlish_fn_26+0x285>
    2f4e:	mov    QWORD PTR [rsp+0x18],0x3
    2f57:	test   r12,0x1
    2f5e:	jne    2f6c <botlish_fn_26+0x1bc>
    2f64:	mov    rdi,r12
    2f67:	jmp    2f81 <botlish_fn_26+0x1d1>
    2f6c:	mov    rsi,r12
    2f6f:	add    rsi,0x2
    2f73:	mov    rdi,r12
    2f76:	seto   al
    2f79:	test   al,al
    2f7b:	je     2f94 <botlish_fn_26+0x1e4>
    2f81:	mov    edx,0x3
    2f86:	mov    rsi,rdi
    2f89:	mov    rdi,r14
    2f8c:	call   2f91 <botlish_fn_26+0x1e1>
			2f8d: R_X86_64_PLT32	rt_int_add-0x4
    2f91:	mov    rsi,rax
    2f94:	mov    QWORD PTR [rsp+0x10],rsi
    2f99:	mov    rcx,r13
    2f9c:	mov    rdx,rbx
    2f9f:	mov    rdi,r14
    2fa2:	call   2fa7 <botlish_fn_26+0x1f7>
			2fa3: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    2fa7:	test   rax,rax
    2faa:	jne    2fd5 <botlish_fn_26+0x225>
    2fb0:	xor    rax,rax
    2fb3:	mov    rbx,QWORD PTR [rsp+0x30]
    2fb8:	mov    r12,QWORD PTR [rsp+0x38]
    2fbd:	mov    r13,QWORD PTR [rsp+0x40]
    2fc2:	mov    r14,QWORD PTR [rsp+0x48]
    2fc7:	mov    r15,QWORD PTR [rsp+0x50]
    2fcc:	add    rsp,0x60
    2fd0:	mov    rsp,rbp
    2fd3:	pop    rbp
    2fd4:	ret
    2fd5:	mov    rcx,rax
    2fd8:	and    rcx,rbx
    2fdb:	mov    rsi,rax
    2fde:	test   rcx,0x1
    2fe5:	jne    300e <botlish_fn_26+0x25e>
    2feb:	mov    rdx,rbx
    2fee:	mov    rdi,r14
    2ff1:	call   2ff6 <botlish_fn_26+0x246>
			2ff2: R_X86_64_PLT32	rt_int_cmp-0x4
    2ff6:	mov    ecx,0x2
    2ffb:	test   rax,rax
    2ffe:	mov    rax,rcx
    3001:	cmove  rax,QWORD PTR [rip+0x4f]        # 3058 <botlish_fn_26+0x2a8>
    3009:	jmp    3035 <botlish_fn_26+0x285>
    300e:	mov    rdx,rbx
    3011:	mov    eax,0x2
    3016:	cmp    rsi,rdx
    3019:	cmove  rax,QWORD PTR [rip+0x37]        # 3058 <botlish_fn_26+0x2a8>
    3021:	jmp    3035 <botlish_fn_26+0x285>
    3026:	mov    eax,0x2
    302b:	jmp    3035 <botlish_fn_26+0x285>
    3030:	mov    eax,0x2
    3035:	mov    rbx,QWORD PTR [rsp+0x30]
    303a:	mov    r12,QWORD PTR [rsp+0x38]
    303f:	mov    r13,QWORD PTR [rsp+0x40]
    3044:	mov    r14,QWORD PTR [rsp+0x48]
    3049:	mov    r15,QWORD PTR [rsp+0x50]
    304e:	add    rsp,0x60
    3052:	mov    rsp,rbp
    3055:	pop    rbp
    3056:	ret
    3057:	add    BYTE PTR [rsi],al
    3059:	add    BYTE PTR [rax],al
    305b:	add    BYTE PTR [rax],al
    305d:	add    BYTE PTR [rax],al
	...

0000000000003060 <botlish_entry_26: <generic>>:
    3060:	push   rbp
    3061:	mov    rbp,rsp
    3064:	mov    rsi,QWORD PTR [rdx]
    3067:	call   306c <botlish_entry_26+0xc>
			3068: R_X86_64_PLT32	botlish_fn_26-0x4 ; <generic>
    306c:	mov    rsp,rbp
    306f:	pop    rbp
    3070:	ret

0000000000003071 <botlish_fn_27: char_at<generic>>:
    3071:	push   rbp
    3072:	mov    rbp,rsp
    3075:	sub    rsp,0x50
    3079:	mov    QWORD PTR [rsp+0x20],rbx
    307e:	mov    QWORD PTR [rsp+0x28],r12
    3083:	mov    QWORD PTR [rsp+0x30],r13
    3088:	mov    QWORD PTR [rsp+0x38],r14
    308d:	mov    QWORD PTR [rsp+0x40],r15
    3092:	mov    r14,rcx
    3095:	mov    QWORD PTR [rsp],rsi
    3099:	mov    QWORD PTR [rsp+0x8],rdx
    309e:	mov    r13,rdx
    30a1:	mov    QWORD PTR [rsp+0x10],0x3
    30aa:	mov    r9d,0x1
    30b0:	test   rsi,0x1
    30b7:	jne    30d7 <botlish_fn_27+0x66>
    30bd:	xor    r9d,r9d
    30c0:	test   rsi,0x7
    30c7:	jne    30d7 <botlish_fn_27+0x66>
    30cd:	movzx  rax,BYTE PTR [rsi]
    30d1:	cmp    al,0x1
    30d3:	sete   r9b
    30d7:	test   r9b,r9b
    30da:	jne    30f8 <botlish_fn_27+0x87>
    30e0:	mov    rax,QWORD PTR [rdi+0x10]
    30e4:	mov    rcx,QWORD PTR [rax+0x118]
    30eb:	xor    rdx,rdx
    30ee:	call   30f3 <botlish_fn_27+0x82>
			30ef: R_X86_64_PLT32	rt_type_error-0x4
    30f3:	jmp    31b5 <botlish_fn_27+0x144>
    30f8:	mov    r12,rdi
    30fb:	test   rsi,0x1
    3102:	jne    3110 <botlish_fn_27+0x9f>
    3108:	mov    rbx,rsi
    310b:	jmp    312d <botlish_fn_27+0xbc>
    3110:	mov    rax,rsi
    3113:	add    rax,0x2
    3117:	mov    rbx,rsi
    311a:	seto   cl
    311d:	test   cl,cl
    311f:	jne    312d <botlish_fn_27+0xbc>
    3125:	mov    r15,rax
    3128:	jmp    3140 <botlish_fn_27+0xcf>
    312d:	mov    edx,0x3
    3132:	mov    rsi,rbx
    3135:	mov    rdi,r12
    3138:	call   313d <botlish_fn_27+0xcc>
			3139: R_X86_64_PLT32	rt_int_add-0x4
    313d:	mov    r15,rax
    3140:	mov    ecx,0x1
    3145:	mov    rsi,rbx
    3148:	test   rsi,0x1
    314f:	jne    3175 <botlish_fn_27+0x104>
    3155:	xor    ecx,ecx
    3157:	mov    rsi,rbx
    315a:	test   rsi,0x7
    3161:	jne    3175 <botlish_fn_27+0x104>
    3167:	mov    rsi,rbx
    316a:	movzx  rcx,BYTE PTR [rsi]
    316e:	rex cmp cl,0x1
    3172:	sete   cl
    3175:	test   cl,cl
    3177:	jne    319b <botlish_fn_27+0x12a>
    317d:	mov    rdi,r12
    3180:	mov    rsi,QWORD PTR [rdi+0x10]
    3184:	mov    rcx,QWORD PTR [rsi+0x120]
    318b:	xor    rdx,rdx
    318e:	mov    rsi,rbx
    3191:	call   3196 <botlish_fn_27+0x125>
			3192: R_X86_64_PLT32	rt_type_error-0x4
    3196:	jmp    31b5 <botlish_fn_27+0x144>
    319b:	mov    rdi,r12
    319e:	mov    rcx,r15
    31a1:	mov    rdx,rbx
    31a4:	mov    rsi,r13
    31a7:	call   31ac <botlish_fn_27+0x13b>
			31a8: R_X86_64_PLT32	rt_str_region_check-0x4
    31ac:	test   rax,rax
    31af:	jne    31da <botlish_fn_27+0x169>
    31b5:	xor    rax,rax
    31b8:	mov    rbx,QWORD PTR [rsp+0x20]
    31bd:	mov    r12,QWORD PTR [rsp+0x28]
    31c2:	mov    r13,QWORD PTR [rsp+0x30]
    31c7:	mov    r14,QWORD PTR [rsp+0x38]
    31cc:	mov    r15,QWORD PTR [rsp+0x40]
    31d1:	add    rsp,0x50
    31d5:	mov    rsp,rbp
    31d8:	pop    rbp
    31d9:	ret
    31da:	mov    rcx,r14
    31dd:	mov    rsi,rbx
    31e0:	mov    QWORD PTR [rcx],rsi
    31e3:	mov    rax,r15
    31e6:	mov    QWORD PTR [rcx+0x8],rax
    31ea:	mov    rax,r13
    31ed:	mov    rbx,QWORD PTR [rsp+0x20]
    31f2:	mov    r12,QWORD PTR [rsp+0x28]
    31f7:	mov    r13,QWORD PTR [rsp+0x30]
    31fc:	mov    r14,QWORD PTR [rsp+0x38]
    3201:	mov    r15,QWORD PTR [rsp+0x40]
    3206:	add    rsp,0x50
    320a:	mov    rsp,rbp
    320d:	pop    rbp
    320e:	ret

000000000000320f <botlish_entry_27: char_at<generic>>:
    320f:	push   rbp
    3210:	mov    rbp,rsp
    3213:	ud2
    3215:	add    BYTE PTR [rax],al
	...

0000000000003218 <botlish_fn_28: scan_local<generic>>:
    3218:	push   rbp
    3219:	mov    rbp,rsp
    321c:	sub    rsp,0x80
    3223:	mov    QWORD PTR [rsp+0x50],rbx
    3228:	mov    QWORD PTR [rsp+0x58],r12
    322d:	mov    QWORD PTR [rsp+0x60],r13
    3232:	mov    QWORD PTR [rsp+0x68],r14
    3237:	mov    QWORD PTR [rsp+0x70],r15
    323c:	mov    rax,rdi
    323f:	mov    QWORD PTR [rsp+0x18],0x0
    3248:	mov    QWORD PTR [rsp],rsi
    324c:	mov    r14,rsi
    324f:	mov    QWORD PTR [rsp+0x8],rdx
    3254:	mov    QWORD PTR [rsp+0x10],rcx
    3259:	mov    r12,rcx
    325c:	mov    r11d,0x1
    3262:	mov    rsi,r14
    3265:	test   rsi,0x1
    326c:	jne    328e <botlish_fn_28+0x76>
    3272:	xor    r11d,r11d
    3275:	test   rsi,0x7
    327c:	jne    328e <botlish_fn_28+0x76>
    3282:	movzx  rdi,BYTE PTR [rsi]
    3286:	cmp    dil,0x1
    328a:	sete   r11b
    328e:	test   r11b,r11b
    3291:	jne    32b2 <botlish_fn_28+0x9a>
    3297:	mov    rdi,rax
    329a:	mov    r9,QWORD PTR [rdi+0x10]
    329e:	mov    rcx,QWORD PTR [r9+0xc8]
    32a5:	xor    rdx,rdx
    32a8:	call   32ad <botlish_fn_28+0x95>
			32a9: R_X86_64_PLT32	rt_type_error-0x4
    32ad:	jmp    3365 <botlish_fn_28+0x14d>
    32b2:	mov    r13,rdx
    32b5:	mov    r10,rsi
    32b8:	and    r10,r13
    32bb:	mov    r14,rsi
    32be:	test   r10,0x1
    32c5:	jne    32f1 <botlish_fn_28+0xd9>
    32cb:	mov    rbx,rax
    32ce:	mov    rdx,r13
    32d1:	mov    rsi,r14
    32d4:	mov    rdi,rbx
    32d7:	call   32dc <botlish_fn_28+0xc4>
			32d8: R_X86_64_PLT32	rt_int_cmp-0x4
    32dc:	mov    ecx,0x2
    32e1:	test   rax,rax
    32e4:	cmovge rcx,QWORD PTR [rip+0x24c]        # 3538 <botlish_fn_28+0x320>
    32ec:	jmp    3307 <botlish_fn_28+0xef>
    32f1:	mov    rbx,rax
    32f4:	mov    ecx,0x2
    32f9:	mov    rsi,r14
    32fc:	cmp    rsi,r13
    32ff:	cmovge rcx,QWORD PTR [rip+0x231]        # 3538 <botlish_fn_28+0x320>
    3307:	mov    eax,0x6
    330c:	mov    QWORD PTR [rsp+0x30],rax
    3311:	cmp    rcx,0x6
    3315:	je     350b <botlish_fn_28+0x2f3>
    331b:	lea    rcx,[rsp+0x20]
    3320:	mov    rdx,r12
    3323:	mov    rsi,r14
    3326:	mov    rdi,rbx
    3329:	call   332e <botlish_fn_28+0x116>
			332a: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    332e:	mov    rsi,rax
    3331:	mov    r15,rax
    3334:	test   rax,rsi
    3337:	je     3365 <botlish_fn_28+0x14d>
    333d:	mov    rdx,QWORD PTR [rsp+0x20]
    3342:	mov    QWORD PTR [rsp+0x40],rdx
    3347:	mov    rcx,QWORD PTR [rsp+0x28]
    334c:	mov    QWORD PTR [rsp+0x38],rcx
    3351:	mov    rsi,r15
    3354:	mov    rdi,rbx
    3357:	call   335c <botlish_fn_28+0x144>
			3358: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    335c:	test   rax,rax
    335f:	jne    338d <botlish_fn_28+0x175>
    3365:	xor    rax,rax
    3368:	mov    rbx,QWORD PTR [rsp+0x50]
    336d:	mov    r12,QWORD PTR [rsp+0x58]
    3372:	mov    r13,QWORD PTR [rsp+0x60]
    3377:	mov    r14,QWORD PTR [rsp+0x68]
    337c:	mov    r15,QWORD PTR [rsp+0x70]
    3381:	add    rsp,0x80
    3388:	mov    rsp,rbp
    338b:	pop    rbp
    338c:	ret
    338d:	cmp    rax,0x6
    3391:	je     348c <botlish_fn_28+0x274>
    3397:	mov    rax,QWORD PTR [rbx+0x10]
    339b:	mov    r8,QWORD PTR [rax+0x128]
    33a2:	mov    rcx,QWORD PTR [rsp+0x38]
    33a7:	mov    rdx,QWORD PTR [rsp+0x40]
    33ac:	mov    rsi,r15
    33af:	mov    rdi,rbx
    33b2:	call   33b7 <botlish_fn_28+0x19f>
			33b3: R_X86_64_PLT32	rt_str_region_eq-0x4
    33b7:	cmp    rax,0x6
    33bb:	je     3482 <botlish_fn_28+0x26a>
    33c1:	mov    rax,QWORD PTR [rbx+0x10]
    33c5:	mov    r8,QWORD PTR [rax+0x130]
    33cc:	mov    rcx,QWORD PTR [rsp+0x38]
    33d1:	mov    rdx,QWORD PTR [rsp+0x40]
    33d6:	mov    rsi,r15
    33d9:	mov    rdi,rbx
    33dc:	call   33e1 <botlish_fn_28+0x1c9>
			33dd: R_X86_64_PLT32	rt_str_region_eq-0x4
    33e1:	cmp    rax,0x6
    33e5:	je     3478 <botlish_fn_28+0x260>
    33eb:	mov    rax,QWORD PTR [rbx+0x10]
    33ef:	mov    r8,QWORD PTR [rax+0xd0]
    33f6:	mov    rcx,QWORD PTR [rsp+0x38]
    33fb:	mov    rdx,QWORD PTR [rsp+0x40]
    3400:	mov    rsi,r15
    3403:	mov    rdi,rbx
    3406:	call   340b <botlish_fn_28+0x1f3>
			3407: R_X86_64_PLT32	rt_str_region_eq-0x4
    340b:	cmp    rax,0x6
    340f:	je     346e <botlish_fn_28+0x256>
    3415:	mov    rax,QWORD PTR [rbx+0x10]
    3419:	mov    r8,QWORD PTR [rax+0x118]
    3420:	mov    rcx,QWORD PTR [rsp+0x38]
    3425:	mov    rdx,QWORD PTR [rsp+0x40]
    342a:	mov    rsi,r15
    342d:	mov    rdi,rbx
    3430:	call   3435 <botlish_fn_28+0x21d>
			3431: R_X86_64_PLT32	rt_str_region_eq-0x4
    3435:	cmp    rax,0x6
    3439:	je     3464 <botlish_fn_28+0x24c>
    343f:	mov    rax,QWORD PTR [rbx+0x10]
    3443:	mov    r8,QWORD PTR [rax+0x138]
    344a:	mov    rcx,QWORD PTR [rsp+0x38]
    344f:	mov    rdx,QWORD PTR [rsp+0x40]
    3454:	mov    rsi,r15
    3457:	mov    rdi,rbx
    345a:	call   345f <botlish_fn_28+0x247>
			345b: R_X86_64_PLT32	rt_str_region_eq-0x4
    345f:	jmp    3491 <botlish_fn_28+0x279>
    3464:	mov    rax,QWORD PTR [rsp+0x30]
    3469:	jmp    3491 <botlish_fn_28+0x279>
    346e:	mov    rax,QWORD PTR [rsp+0x30]
    3473:	jmp    3491 <botlish_fn_28+0x279>
    3478:	mov    rax,QWORD PTR [rsp+0x30]
    347d:	jmp    3491 <botlish_fn_28+0x279>
    3482:	mov    rax,QWORD PTR [rsp+0x30]
    3487:	jmp    3491 <botlish_fn_28+0x279>
    348c:	mov    rax,QWORD PTR [rsp+0x30]
    3491:	cmp    rax,0x6
    3495:	je     34a3 <botlish_fn_28+0x28b>
    349b:	mov    rax,r14
    349e:	jmp    350e <botlish_fn_28+0x2f6>
    34a3:	mov    QWORD PTR [rsp+0x18],0x3
    34ac:	mov    rsi,r14
    34af:	test   rsi,0x1
    34b6:	je     34dc <botlish_fn_28+0x2c4>
    34bc:	mov    rsi,r14
    34bf:	mov    rax,rsi
    34c2:	add    rax,0x2
    34c6:	seto   cl
    34c9:	test   cl,cl
    34cb:	jne    34dc <botlish_fn_28+0x2c4>
    34d1:	mov    rsi,rax
    34d4:	mov    r14,rax
    34d7:	jmp    34f2 <botlish_fn_28+0x2da>
    34dc:	mov    edx,0x3
    34e1:	mov    rsi,r14
    34e4:	mov    rdi,rbx
    34e7:	call   34ec <botlish_fn_28+0x2d4>
			34e8: R_X86_64_PLT32	rt_int_add-0x4
    34ec:	mov    rsi,rax
    34ef:	mov    r14,rax
    34f2:	mov    QWORD PTR [rsp],rsi
    34f6:	mov    QWORD PTR [rsp+0x8],r13
    34fb:	mov    QWORD PTR [rsp+0x10],r12
    3500:	mov    rax,rbx
    3503:	mov    rdx,r13
    3506:	jmp    325c <botlish_fn_28+0x44>
    350b:	mov    rax,r14
    350e:	mov    rbx,QWORD PTR [rsp+0x50]
    3513:	mov    r12,QWORD PTR [rsp+0x58]
    3518:	mov    r13,QWORD PTR [rsp+0x60]
    351d:	mov    r14,QWORD PTR [rsp+0x68]
    3522:	mov    r15,QWORD PTR [rsp+0x70]
    3527:	add    rsp,0x80
    352e:	mov    rsp,rbp
    3531:	pop    rbp
    3532:	ret
    3533:	add    BYTE PTR [rax],al
    3535:	add    BYTE PTR [rax],al
    3537:	add    BYTE PTR [rsi],al
    3539:	add    BYTE PTR [rax],al
    353b:	add    BYTE PTR [rax],al
    353d:	add    BYTE PTR [rax],al
	...

0000000000003540 <botlish_entry_28: scan_local<generic>>:
    3540:	push   rbp
    3541:	mov    rbp,rsp
    3544:	mov    rsi,QWORD PTR [rdx]
    3547:	mov    r8,QWORD PTR [rdx+0x8]
    354b:	mov    rcx,QWORD PTR [rdx+0x10]
    354f:	mov    rdx,r8
    3552:	call   3557 <botlish_entry_28+0x17>
			3553: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    3557:	mov    rsp,rbp
    355a:	pop    rbp
    355b:	ret
    355c:	add    BYTE PTR [rax],al
	...

0000000000003560 <botlish_fn_29: scan_label<generic>>:
    3560:	push   rbp
    3561:	mov    rbp,rsp
    3564:	sub    rsp,0x80
    356b:	mov    QWORD PTR [rsp+0x50],rbx
    3570:	mov    QWORD PTR [rsp+0x58],r12
    3575:	mov    QWORD PTR [rsp+0x60],r13
    357a:	mov    QWORD PTR [rsp+0x68],r14
    357f:	mov    QWORD PTR [rsp+0x70],r15
    3584:	mov    QWORD PTR [rsp+0x18],0x0
    358d:	mov    QWORD PTR [rsp],rsi
    3591:	mov    r14,rsi
    3594:	mov    QWORD PTR [rsp+0x8],rdx
    3599:	mov    QWORD PTR [rsp+0x10],rcx
    359e:	mov    r12,rcx
    35a1:	mov    r11d,0x1
    35a7:	mov    rsi,r14
    35aa:	test   rsi,0x1
    35b1:	jne    35d1 <botlish_fn_29+0x71>
    35b7:	xor    r11d,r11d
    35ba:	test   rsi,0x7
    35c1:	jne    35d1 <botlish_fn_29+0x71>
    35c7:	movzx  rax,BYTE PTR [rsi]
    35cb:	cmp    al,0x1
    35cd:	sete   r11b
    35d1:	test   r11b,r11b
    35d4:	jne    35f2 <botlish_fn_29+0x92>
    35da:	mov    rax,QWORD PTR [rdi+0x10]
    35de:	mov    rcx,QWORD PTR [rax+0xc8]
    35e5:	xor    rdx,rdx
    35e8:	call   35ed <botlish_fn_29+0x8d>
			35e9: R_X86_64_PLT32	rt_type_error-0x4
    35ed:	jmp    369e <botlish_fn_29+0x13e>
    35f2:	mov    r13,rdx
    35f5:	mov    rax,rsi
    35f8:	and    rax,r13
    35fb:	mov    r14,rsi
    35fe:	test   rax,0x1
    3604:	jne    362d <botlish_fn_29+0xcd>
    360a:	mov    rbx,rdi
    360d:	mov    rdx,r13
    3610:	mov    rsi,r14
    3613:	call   3618 <botlish_fn_29+0xb8>
			3614: R_X86_64_PLT32	rt_int_cmp-0x4
    3618:	mov    ecx,0x2
    361d:	test   rax,rax
    3620:	cmovge rcx,QWORD PTR [rip+0x178]        # 37a0 <botlish_fn_29+0x240>
    3628:	jmp    3643 <botlish_fn_29+0xe3>
    362d:	mov    rbx,rdi
    3630:	mov    ecx,0x2
    3635:	mov    rsi,r14
    3638:	cmp    rsi,r13
    363b:	cmovge rcx,QWORD PTR [rip+0x15d]        # 37a0 <botlish_fn_29+0x240>
    3643:	mov    eax,0x6
    3648:	mov    QWORD PTR [rsp+0x30],rax
    364d:	cmp    rcx,0x6
    3651:	je     3774 <botlish_fn_29+0x214>
    3657:	lea    rcx,[rsp+0x20]
    365c:	mov    rdx,r12
    365f:	mov    rsi,r14
    3662:	mov    rdi,rbx
    3665:	call   366a <botlish_fn_29+0x10a>
			3666: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    366a:	test   rax,rax
    366d:	mov    r15,rax
    3670:	je     369e <botlish_fn_29+0x13e>
    3676:	mov    rdx,QWORD PTR [rsp+0x20]
    367b:	mov    QWORD PTR [rsp+0x40],rdx
    3680:	mov    rcx,QWORD PTR [rsp+0x28]
    3685:	mov    QWORD PTR [rsp+0x38],rcx
    368a:	mov    rsi,r15
    368d:	mov    rdi,rbx
    3690:	call   3695 <botlish_fn_29+0x135>
			3691: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    3695:	test   rax,rax
    3698:	jne    36c6 <botlish_fn_29+0x166>
    369e:	xor    rax,rax
    36a1:	mov    rbx,QWORD PTR [rsp+0x50]
    36a6:	mov    r12,QWORD PTR [rsp+0x58]
    36ab:	mov    r13,QWORD PTR [rsp+0x60]
    36b0:	mov    r14,QWORD PTR [rsp+0x68]
    36b5:	mov    r15,QWORD PTR [rsp+0x70]
    36ba:	add    rsp,0x80
    36c1:	mov    rsp,rbp
    36c4:	pop    rbp
    36c5:	ret
    36c6:	cmp    rax,0x6
    36ca:	je     36f5 <botlish_fn_29+0x195>
    36d0:	mov    r11,QWORD PTR [rbx+0x10]
    36d4:	mov    r8,QWORD PTR [r11+0x138]
    36db:	mov    rcx,QWORD PTR [rsp+0x38]
    36e0:	mov    rdx,QWORD PTR [rsp+0x40]
    36e5:	mov    rsi,r15
    36e8:	mov    rdi,rbx
    36eb:	call   36f0 <botlish_fn_29+0x190>
			36ec: R_X86_64_PLT32	rt_str_region_eq-0x4
    36f0:	jmp    36fa <botlish_fn_29+0x19a>
    36f5:	mov    rax,QWORD PTR [rsp+0x30]
    36fa:	cmp    rax,0x6
    36fe:	je     370c <botlish_fn_29+0x1ac>
    3704:	mov    rax,r14
    3707:	jmp    3777 <botlish_fn_29+0x217>
    370c:	mov    QWORD PTR [rsp+0x18],0x3
    3715:	mov    rsi,r14
    3718:	test   rsi,0x1
    371f:	je     3745 <botlish_fn_29+0x1e5>
    3725:	mov    rsi,r14
    3728:	mov    rax,rsi
    372b:	add    rax,0x2
    372f:	seto   cl
    3732:	test   cl,cl
    3734:	jne    3745 <botlish_fn_29+0x1e5>
    373a:	mov    rsi,rax
    373d:	mov    r14,rax
    3740:	jmp    375b <botlish_fn_29+0x1fb>
    3745:	mov    edx,0x3
    374a:	mov    rsi,r14
    374d:	mov    rdi,rbx
    3750:	call   3755 <botlish_fn_29+0x1f5>
			3751: R_X86_64_PLT32	rt_int_add-0x4
    3755:	mov    rsi,rax
    3758:	mov    r14,rax
    375b:	mov    QWORD PTR [rsp],rsi
    375f:	mov    QWORD PTR [rsp+0x8],r13
    3764:	mov    QWORD PTR [rsp+0x10],r12
    3769:	mov    rdx,r13
    376c:	mov    rdi,rbx
    376f:	jmp    35a1 <botlish_fn_29+0x41>
    3774:	mov    rax,r14
    3777:	mov    rbx,QWORD PTR [rsp+0x50]
    377c:	mov    r12,QWORD PTR [rsp+0x58]
    3781:	mov    r13,QWORD PTR [rsp+0x60]
    3786:	mov    r14,QWORD PTR [rsp+0x68]
    378b:	mov    r15,QWORD PTR [rsp+0x70]
    3790:	add    rsp,0x80
    3797:	mov    rsp,rbp
    379a:	pop    rbp
    379b:	ret
    379c:	add    BYTE PTR [rax],al
    379e:	add    BYTE PTR [rax],al
    37a0:	(bad)
    37a1:	add    BYTE PTR [rax],al
    37a3:	add    BYTE PTR [rax],al
    37a5:	add    BYTE PTR [rax],al
	...

00000000000037a8 <botlish_entry_29: scan_label<generic>>:
    37a8:	push   rbp
    37a9:	mov    rbp,rsp
    37ac:	mov    rsi,QWORD PTR [rdx]
    37af:	mov    r8,QWORD PTR [rdx+0x8]
    37b3:	mov    rcx,QWORD PTR [rdx+0x10]
    37b7:	mov    rdx,r8
    37ba:	call   37bf <botlish_entry_29+0x17>
			37bb: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_label<generic>
    37bf:	mov    rsp,rbp
    37c2:	pop    rbp
    37c3:	ret
    37c4:	add    BYTE PTR [rax],al
	...

00000000000037c8 <botlish_fn_30: scan_alpha<generic>>:
    37c8:	push   rbp
    37c9:	mov    rbp,rsp
    37cc:	sub    rsp,0x50
    37d0:	mov    QWORD PTR [rsp+0x30],rbx
    37d5:	mov    QWORD PTR [rsp+0x38],r12
    37da:	mov    QWORD PTR [rsp+0x40],r13
    37df:	mov    QWORD PTR [rsp+0x48],r14
    37e4:	mov    r14,rdi
    37e7:	mov    QWORD PTR [rsp+0x18],0x0
    37f0:	mov    QWORD PTR [rsp],rsi
    37f4:	mov    r13,rsi
    37f7:	mov    QWORD PTR [rsp+0x8],rdx
    37fc:	mov    r12,rdx
    37ff:	mov    QWORD PTR [rsp+0x10],rcx
    3804:	mov    rbx,rcx
    3807:	mov    r11d,0x1
    380d:	mov    rsi,r13
    3810:	test   rsi,0x1
    3817:	jne    3837 <botlish_fn_30+0x6f>
    381d:	xor    r11d,r11d
    3820:	test   rsi,0x7
    3827:	jne    3837 <botlish_fn_30+0x6f>
    382d:	movzx  rax,BYTE PTR [rsi]
    3831:	cmp    al,0x1
    3833:	sete   r11b
    3837:	test   r11b,r11b
    383a:	jne    385b <botlish_fn_30+0x93>
    3840:	mov    rdi,r14
    3843:	mov    rax,QWORD PTR [rdi+0x10]
    3847:	mov    rcx,QWORD PTR [rax+0xc8]
    384e:	xor    rdx,rdx
    3851:	call   3856 <botlish_fn_30+0x8e>
			3852: R_X86_64_PLT32	rt_type_error-0x4
    3856:	jmp    38ea <botlish_fn_30+0x122>
    385b:	mov    rax,rsi
    385e:	and    rax,r12
    3861:	mov    r13,rsi
    3864:	test   rax,0x1
    386a:	jne    3893 <botlish_fn_30+0xcb>
    3870:	mov    rdx,r12
    3873:	mov    rsi,r13
    3876:	mov    rdi,r14
    3879:	call   387e <botlish_fn_30+0xb6>
			387a: R_X86_64_PLT32	rt_int_cmp-0x4
    387e:	mov    ecx,0x2
    3883:	test   rax,rax
    3886:	cmovge rcx,QWORD PTR [rip+0x112]        # 39a0 <botlish_fn_30+0x1d8>
    388e:	jmp    38a6 <botlish_fn_30+0xde>
    3893:	mov    ecx,0x2
    3898:	mov    rsi,r13
    389b:	cmp    rsi,r12
    389e:	cmovge rcx,QWORD PTR [rip+0xfa]        # 39a0 <botlish_fn_30+0x1d8>
    38a6:	cmp    rcx,0x6
    38aa:	je     397e <botlish_fn_30+0x1b6>
    38b0:	lea    rcx,[rsp+0x20]
    38b5:	mov    rdx,rbx
    38b8:	mov    rsi,r13
    38bb:	mov    rdi,r14
    38be:	call   38c3 <botlish_fn_30+0xfb>
			38bf: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    38c3:	test   rax,rax
    38c6:	mov    rsi,rax
    38c9:	je     38ea <botlish_fn_30+0x122>
    38cf:	mov    rdx,QWORD PTR [rsp+0x20]
    38d4:	mov    rcx,QWORD PTR [rsp+0x28]
    38d9:	mov    rdi,r14
    38dc:	call   38e1 <botlish_fn_30+0x119>
			38dd: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    38e1:	test   rax,rax
    38e4:	jne    390a <botlish_fn_30+0x142>
    38ea:	xor    rax,rax
    38ed:	mov    rbx,QWORD PTR [rsp+0x30]
    38f2:	mov    r12,QWORD PTR [rsp+0x38]
    38f7:	mov    r13,QWORD PTR [rsp+0x40]
    38fc:	mov    r14,QWORD PTR [rsp+0x48]
    3901:	add    rsp,0x50
    3905:	mov    rsp,rbp
    3908:	pop    rbp
    3909:	ret
    390a:	cmp    rax,0x6
    390e:	je     391c <botlish_fn_30+0x154>
    3914:	mov    rax,r13
    3917:	jmp    3981 <botlish_fn_30+0x1b9>
    391c:	mov    QWORD PTR [rsp+0x18],0x3
    3925:	mov    rsi,r13
    3928:	test   rsi,0x1
    392f:	je     3955 <botlish_fn_30+0x18d>
    3935:	mov    rsi,r13
    3938:	mov    r11,rsi
    393b:	add    r11,0x2
    393f:	seto   al
    3942:	test   al,al
    3944:	jne    3955 <botlish_fn_30+0x18d>
    394a:	mov    rsi,r11
    394d:	mov    r13,r11
    3950:	jmp    396b <botlish_fn_30+0x1a3>
    3955:	mov    edx,0x3
    395a:	mov    rsi,r13
    395d:	mov    rdi,r14
    3960:	call   3965 <botlish_fn_30+0x19d>
			3961: R_X86_64_PLT32	rt_int_add-0x4
    3965:	mov    rsi,rax
    3968:	mov    r13,rax
    396b:	mov    QWORD PTR [rsp],rsi
    396f:	mov    QWORD PTR [rsp+0x8],r12
    3974:	mov    QWORD PTR [rsp+0x10],rbx
    3979:	jmp    3807 <botlish_fn_30+0x3f>
    397e:	mov    rax,r13
    3981:	mov    rbx,QWORD PTR [rsp+0x30]
    3986:	mov    r12,QWORD PTR [rsp+0x38]
    398b:	mov    r13,QWORD PTR [rsp+0x40]
    3990:	mov    r14,QWORD PTR [rsp+0x48]
    3995:	add    rsp,0x50
    3999:	mov    rsp,rbp
    399c:	pop    rbp
    399d:	ret
    399e:	add    BYTE PTR [rax],al
    39a0:	(bad)
    39a1:	add    BYTE PTR [rax],al
    39a3:	add    BYTE PTR [rax],al
    39a5:	add    BYTE PTR [rax],al
	...

00000000000039a8 <botlish_entry_30: scan_alpha<generic>>:
    39a8:	push   rbp
    39a9:	mov    rbp,rsp
    39ac:	mov    rsi,QWORD PTR [rdx]
    39af:	mov    r8,QWORD PTR [rdx+0x8]
    39b3:	mov    rcx,QWORD PTR [rdx+0x10]
    39b7:	mov    rdx,r8
    39ba:	call   39bf <botlish_entry_30+0x17>
			39bb: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_alpha<generic>
    39bf:	mov    rsp,rbp
    39c2:	pop    rbp
    39c3:	ret
    39c4:	add    BYTE PTR [rax],al
	...

00000000000039c8 <botlish_fn_31: tld_ok<generic>>:
    39c8:	push   rbp
    39c9:	mov    rbp,rsp
    39cc:	sub    rsp,0x40
    39d0:	mov    QWORD PTR [rsp+0x20],rbx
    39d5:	mov    QWORD PTR [rsp+0x28],r12
    39da:	mov    QWORD PTR [rsp+0x30],r13
    39df:	mov    QWORD PTR [rsp+0x38],r14
    39e4:	mov    rbx,rdi
    39e7:	mov    QWORD PTR [rsp],rsi
    39eb:	mov    r12,rsi
    39ee:	mov    QWORD PTR [rsp+0x8],rdx
    39f3:	mov    r14,rdx
    39f6:	mov    QWORD PTR [rsp+0x10],rcx
    39fb:	mov    rdx,r14
    39fe:	mov    rsi,r12
    3a01:	mov    rdi,rbx
    3a04:	call   3a09 <botlish_fn_31+0x41>
			3a05: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_alpha<generic>
    3a09:	mov    rsi,rax
    3a0c:	mov    r13,rax
    3a0f:	test   rax,rsi
    3a12:	je     3ad5 <botlish_fn_31+0x10d>
    3a18:	mov    rax,r13
    3a1b:	mov    QWORD PTR [rsp+0x8],rax
    3a20:	mov    rdx,r14
    3a23:	and    rax,rdx
    3a26:	test   rax,0x1
    3a2c:	jne    3a55 <botlish_fn_31+0x8d>
    3a32:	mov    rsi,r13
    3a35:	mov    rdi,rbx
    3a38:	call   3a3d <botlish_fn_31+0x75>
			3a39: R_X86_64_PLT32	rt_int_cmp-0x4
    3a3d:	mov    ecx,0x2
    3a42:	test   rax,rax
    3a45:	cmove  rcx,QWORD PTR [rip+0x15b]        # 3ba8 <botlish_fn_31+0x1e0>
    3a4d:	mov    rax,r13
    3a50:	jmp    3a68 <botlish_fn_31+0xa0>
    3a55:	mov    ecx,0x2
    3a5a:	mov    rax,r13
    3a5d:	cmp    rax,rdx
    3a60:	cmove  rcx,QWORD PTR [rip+0x140]        # 3ba8 <botlish_fn_31+0x1e0>
    3a68:	cmp    rcx,0x6
    3a6c:	je     3a7f <botlish_fn_31+0xb7>
    3a72:	mov    ecx,0x2
    3a77:	mov    rax,rcx
    3a7a:	jmp    3b87 <botlish_fn_31+0x1bf>
    3a7f:	mov    ecx,0x1
    3a84:	mov    rsi,r12
    3a87:	test   rsi,0x1
    3a8e:	jne    3ab4 <botlish_fn_31+0xec>
    3a94:	xor    ecx,ecx
    3a96:	mov    rsi,r12
    3a99:	test   rsi,0x7
    3aa0:	jne    3ab4 <botlish_fn_31+0xec>
    3aa6:	mov    rsi,r12
    3aa9:	movzx  rcx,BYTE PTR [rsi]
    3aad:	rex cmp cl,0x1
    3ab1:	sete   cl
    3ab4:	test   cl,cl
    3ab6:	jne    3af5 <botlish_fn_31+0x12d>
    3abc:	mov    rdi,rbx
    3abf:	mov    rsi,QWORD PTR [rdi+0x10]
    3ac3:	mov    rcx,QWORD PTR [rsi+0x138]
    3aca:	xor    rdx,rdx
    3acd:	mov    rsi,r12
    3ad0:	call   3ad5 <botlish_fn_31+0x10d>
			3ad1: R_X86_64_PLT32	rt_type_error-0x4
    3ad5:	xor    rax,rax
    3ad8:	mov    rbx,QWORD PTR [rsp+0x20]
    3add:	mov    r12,QWORD PTR [rsp+0x28]
    3ae2:	mov    r13,QWORD PTR [rsp+0x30]
    3ae7:	mov    r14,QWORD PTR [rsp+0x38]
    3aec:	add    rsp,0x40
    3af0:	mov    rsp,rbp
    3af3:	pop    rbp
    3af4:	ret
    3af5:	mov    rsi,r12
    3af8:	mov    rdi,rax
    3afb:	and    rdi,rsi
    3afe:	test   rdi,0x1
    3b05:	jne    3b16 <botlish_fn_31+0x14e>
    3b0b:	mov    rdx,r12
    3b0e:	mov    rsi,rax
    3b11:	jmp    3b39 <botlish_fn_31+0x171>
    3b16:	mov    rsi,r12
    3b19:	mov    r8,rax
    3b1c:	sub    r8,rsi
    3b1f:	mov    r13,rax
    3b22:	seto   r10b
    3b26:	lea    rsi,[r8+0x1]
    3b2a:	test   r10b,r10b
    3b2d:	je     3b44 <botlish_fn_31+0x17c>
    3b33:	mov    rdx,r12
    3b36:	mov    rsi,r13
    3b39:	mov    rdi,rbx
    3b3c:	call   3b41 <botlish_fn_31+0x179>
			3b3d: R_X86_64_PLT32	rt_int_sub-0x4
    3b41:	mov    rsi,rax
    3b44:	test   rsi,0x1
    3b4b:	jne    3b76 <botlish_fn_31+0x1ae>
    3b51:	mov    edx,0x5
    3b56:	mov    rdi,rbx
    3b59:	call   3b5e <botlish_fn_31+0x196>
			3b5a: R_X86_64_PLT32	rt_int_cmp-0x4
    3b5e:	mov    ecx,0x2
    3b63:	test   rax,rax
    3b66:	mov    rax,rcx
    3b69:	cmovge rax,QWORD PTR [rip+0x37]        # 3ba8 <botlish_fn_31+0x1e0>
    3b71:	jmp    3b87 <botlish_fn_31+0x1bf>
    3b76:	mov    eax,0x2
    3b7b:	cmp    rsi,0x5
    3b7f:	cmovge rax,QWORD PTR [rip+0x21]        # 3ba8 <botlish_fn_31+0x1e0>
    3b87:	mov    rbx,QWORD PTR [rsp+0x20]
    3b8c:	mov    r12,QWORD PTR [rsp+0x28]
    3b91:	mov    r13,QWORD PTR [rsp+0x30]
    3b96:	mov    r14,QWORD PTR [rsp+0x38]
    3b9b:	add    rsp,0x40
    3b9f:	mov    rsp,rbp
    3ba2:	pop    rbp
    3ba3:	ret
    3ba4:	add    BYTE PTR [rax],al
    3ba6:	add    BYTE PTR [rax],al
    3ba8:	(bad)
    3ba9:	add    BYTE PTR [rax],al
    3bab:	add    BYTE PTR [rax],al
    3bad:	add    BYTE PTR [rax],al
	...

0000000000003bb0 <botlish_entry_31: tld_ok<generic>>:
    3bb0:	push   rbp
    3bb1:	mov    rbp,rsp
    3bb4:	mov    rsi,QWORD PTR [rdx]
    3bb7:	mov    r8,QWORD PTR [rdx+0x8]
    3bbb:	mov    rcx,QWORD PTR [rdx+0x10]
    3bbf:	mov    rdx,r8
    3bc2:	call   3bc7 <botlish_entry_31+0x17>
			3bc3: R_X86_64_PLT32	botlish_fn_31-0x4 ; tld_ok<generic>
    3bc7:	mov    rsp,rbp
    3bca:	pop    rbp
    3bcb:	ret
    3bcc:	add    BYTE PTR [rax],al
	...

0000000000003bd0 <botlish_fn_32: domain_loop<generic>>:
    3bd0:	push   rbp
    3bd1:	mov    rbp,rsp
    3bd4:	sub    rsp,0x70
    3bd8:	mov    QWORD PTR [rsp+0x40],rbx
    3bdd:	mov    QWORD PTR [rsp+0x48],r12
    3be2:	mov    QWORD PTR [rsp+0x50],r13
    3be7:	mov    QWORD PTR [rsp+0x58],r14
    3bec:	mov    QWORD PTR [rsp+0x60],r15
    3bf1:	mov    QWORD PTR [rsp+0x18],0x0
    3bfa:	mov    QWORD PTR [rsp],rsi
    3bfe:	mov    QWORD PTR [rsp+0x8],rdx
    3c03:	mov    QWORD PTR [rsp+0x10],rcx
    3c08:	lea    rbx,[rsp+0x20]
    3c0d:	mov    r12,rdi
    3c10:	mov    r13,rcx
    3c13:	mov    r14,rdx
    3c16:	mov    QWORD PTR [rsp+0x30],rsi
    3c1b:	mov    rcx,r13
    3c1e:	mov    rdx,r14
    3c21:	mov    rsi,QWORD PTR [rsp+0x30]
    3c26:	mov    rdi,r12
    3c29:	call   3c2e <botlish_fn_32+0x5e>
			3c2a: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_label<generic>
    3c2e:	mov    rcx,rax
    3c31:	mov    r15,rax
    3c34:	test   rax,rcx
    3c37:	je     3d87 <botlish_fn_32+0x1b7>
    3c3d:	mov    rax,r15
    3c40:	mov    QWORD PTR [rsp],rax
    3c44:	mov    rdx,QWORD PTR [rsp+0x30]
    3c49:	and    rax,rdx
    3c4c:	test   rax,0x1
    3c52:	jne    3c71 <botlish_fn_32+0xa1>
    3c58:	mov    rsi,r15
    3c5b:	mov    rdi,r12
    3c5e:	call   3c63 <botlish_fn_32+0x93>
			3c5f: R_X86_64_PLT32	rt_value_eq-0x4
    3c63:	test   rax,rax
    3c66:	je     3d87 <botlish_fn_32+0x1b7>
    3c6c:	jmp    3c81 <botlish_fn_32+0xb1>
    3c71:	mov    eax,0x2
    3c76:	cmp    r15,rdx
    3c79:	cmove  rax,QWORD PTR [rip+0x187]        # 3e08 <botlish_fn_32+0x238>
    3c81:	cmp    rax,0x6
    3c85:	je     3ddd <botlish_fn_32+0x20d>
    3c8b:	mov    rax,r15
    3c8e:	and    rax,r14
    3c91:	test   rax,0x1
    3c97:	jne    3cc0 <botlish_fn_32+0xf0>
    3c9d:	mov    rdx,r14
    3ca0:	mov    rsi,r15
    3ca3:	mov    rdi,r12
    3ca6:	call   3cab <botlish_fn_32+0xdb>
			3ca7: R_X86_64_PLT32	rt_int_cmp-0x4
    3cab:	mov    ecx,0x2
    3cb0:	test   rax,rax
    3cb3:	cmovge rcx,QWORD PTR [rip+0x14d]        # 3e08 <botlish_fn_32+0x238>
    3cbb:	jmp    3cd0 <botlish_fn_32+0x100>
    3cc0:	mov    ecx,0x2
    3cc5:	cmp    r15,r14
    3cc8:	cmovge rcx,QWORD PTR [rip+0x138]        # 3e08 <botlish_fn_32+0x238>
    3cd0:	cmp    rcx,0x6
    3cd4:	je     3dce <botlish_fn_32+0x1fe>
    3cda:	mov    rcx,rbx
    3cdd:	mov    rdx,r13
    3ce0:	mov    rsi,r15
    3ce3:	mov    rdi,r12
    3ce6:	call   3ceb <botlish_fn_32+0x11b>
			3ce7: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    3ceb:	test   rax,rax
    3cee:	je     3d87 <botlish_fn_32+0x1b7>
    3cf4:	mov    rdx,QWORD PTR [rsp+0x20]
    3cf9:	mov    rcx,QWORD PTR [rsp+0x28]
    3cfe:	mov    rsi,QWORD PTR [r12+0x10]
    3d03:	mov    r8,QWORD PTR [rsi+0x128]
    3d0a:	mov    rsi,rax
    3d0d:	mov    rdi,r12
    3d10:	call   3d15 <botlish_fn_32+0x145>
			3d11: R_X86_64_PLT32	rt_str_region_eq-0x4
    3d15:	cmp    rax,0x6
    3d19:	je     3d2b <botlish_fn_32+0x15b>
    3d1f:	mov    r14,0xffffffffffffffff
    3d26:	jmp    3dd5 <botlish_fn_32+0x205>
    3d2b:	mov    QWORD PTR [rsp+0x18],0x3
    3d34:	test   r15,0x1
    3d3b:	je     3d53 <botlish_fn_32+0x183>
    3d41:	mov    rdx,r15
    3d44:	add    rdx,0x2
    3d48:	seto   al
    3d4b:	test   al,al
    3d4d:	je     3d66 <botlish_fn_32+0x196>
    3d53:	mov    edx,0x3
    3d58:	mov    rsi,r15
    3d5b:	mov    rdi,r12
    3d5e:	call   3d63 <botlish_fn_32+0x193>
			3d5f: R_X86_64_PLT32	rt_int_add-0x4
    3d63:	mov    rdx,rax
    3d66:	mov    QWORD PTR [rsp],rdx
    3d6a:	mov    r15,rdx
    3d6d:	mov    rcx,r13
    3d70:	mov    rdx,r14
    3d73:	mov    rsi,r15
    3d76:	mov    rdi,r12
    3d79:	call   3d7e <botlish_fn_32+0x1ae>
			3d7a: R_X86_64_PLT32	botlish_fn_31-0x4 ; tld_ok<generic>
    3d7e:	test   rax,rax
    3d81:	jne    3dac <botlish_fn_32+0x1dc>
    3d87:	xor    rax,rax
    3d8a:	mov    rbx,QWORD PTR [rsp+0x40]
    3d8f:	mov    r12,QWORD PTR [rsp+0x48]
    3d94:	mov    r13,QWORD PTR [rsp+0x50]
    3d99:	mov    r14,QWORD PTR [rsp+0x58]
    3d9e:	mov    r15,QWORD PTR [rsp+0x60]
    3da3:	add    rsp,0x70
    3da7:	mov    rsp,rbp
    3daa:	pop    rbp
    3dab:	ret
    3dac:	cmp    rax,0x6
    3db0:	je     3dd5 <botlish_fn_32+0x205>
    3db6:	mov    QWORD PTR [rsp],r15
    3dba:	mov    QWORD PTR [rsp+0x8],r14
    3dbf:	mov    QWORD PTR [rsp+0x10],r13
    3dc4:	mov    QWORD PTR [rsp+0x30],r15
    3dc9:	jmp    3c1b <botlish_fn_32+0x4b>
    3dce:	mov    r14,0xffffffffffffffff
    3dd5:	mov    rax,r14
    3dd8:	jmp    3de4 <botlish_fn_32+0x214>
    3ddd:	mov    rax,0xffffffffffffffff
    3de4:	mov    rbx,QWORD PTR [rsp+0x40]
    3de9:	mov    r12,QWORD PTR [rsp+0x48]
    3dee:	mov    r13,QWORD PTR [rsp+0x50]
    3df3:	mov    r14,QWORD PTR [rsp+0x58]
    3df8:	mov    r15,QWORD PTR [rsp+0x60]
    3dfd:	add    rsp,0x70
    3e01:	mov    rsp,rbp
    3e04:	pop    rbp
    3e05:	ret
    3e06:	add    BYTE PTR [rax],al
    3e08:	(bad)
    3e09:	add    BYTE PTR [rax],al
    3e0b:	add    BYTE PTR [rax],al
    3e0d:	add    BYTE PTR [rax],al
	...

0000000000003e10 <botlish_entry_32: domain_loop<generic>>:
    3e10:	push   rbp
    3e11:	mov    rbp,rsp
    3e14:	mov    rsi,QWORD PTR [rdx]
    3e17:	mov    r8,QWORD PTR [rdx+0x8]
    3e1b:	mov    rcx,QWORD PTR [rdx+0x10]
    3e1f:	mov    rdx,r8
    3e22:	call   3e27 <botlish_entry_32+0x17>
			3e23: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    3e27:	mov    rsp,rbp
    3e2a:	pop    rbp
    3e2b:	ret

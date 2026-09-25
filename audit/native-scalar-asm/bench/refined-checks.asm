; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 16799  (per function: 1172 39 337 625 74 74 74 125 125 155 125 214 484 864 516 1004 504 681 769 450 884 644 540 540 636 681 769 450 884 644 540 540 636)
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
     63f:	je     772 <botlish_fn_3+0x19a>
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
     689:	cmovl  rcx,QWORD PTR [rip+0x177]        # 808 <botlish_fn_3+0x230>
     691:	jmp    6a9 <botlish_fn_3+0xd1>
     696:	mov    ecx,0x2
     69b:	mov    rsi,r14
     69e:	cmp    rsi,r12
     6a1:	cmovl  rcx,QWORD PTR [rip+0x15f]        # 808 <botlish_fn_3+0x230>
     6a9:	cmp    rcx,0x6
     6ad:	je     6ed <botlish_fn_3+0x115>
     6b3:	mov    rsi,r15
     6b6:	mov    QWORD PTR [rsp],rsi
     6ba:	mov    rdi,r13
     6bd:	call   6c2 <botlish_fn_3+0xea>
			6be: R_X86_64_PLT32	rt_set_from_list-0x4
     6c2:	test   rax,rax
     6c5:	je     772 <botlish_fn_3+0x19a>
     6cb:	mov    rbx,QWORD PTR [rsp+0x30]
     6d0:	mov    r12,QWORD PTR [rsp+0x38]
     6d5:	mov    r13,QWORD PTR [rsp+0x40]
     6da:	mov    r14,QWORD PTR [rsp+0x48]
     6df:	mov    r15,QWORD PTR [rsp+0x50]
     6e4:	add    rsp,0x60
     6e8:	mov    rsp,rbp
     6eb:	pop    rbp
     6ec:	ret
     6ed:	mov    rsi,r14
     6f0:	test   rsi,0x1
     6f7:	je     713 <botlish_fn_3+0x13b>
     6fd:	mov    rcx,QWORD PTR [rbx+0x8]
     701:	mov    rsi,r14
     704:	mov    rax,rsi
     707:	sar    rax,1
     70a:	cmp    rax,rcx
     70d:	jb     732 <botlish_fn_3+0x15a>
     713:	mov    rdx,r14
     716:	mov    rsi,rbx
     719:	mov    rdi,r13
     71c:	call   721 <botlish_fn_3+0x149>
			71d: R_X86_64_PLT32	rt_list_get-0x4
     721:	test   rax,rax
     724:	je     772 <botlish_fn_3+0x19a>
     72a:	mov    rsi,rax
     72d:	jmp    73a <botlish_fn_3+0x162>
     732:	mov    rsi,QWORD PTR [rbx+0x10]
     736:	mov    rsi,QWORD PTR [rsi+rax*8]
     73a:	mov    rdi,r13
     73d:	call   742 <botlish_fn_3+0x16a>
			73e: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     742:	mov    rsi,rax
     745:	mov    rdi,r13
     748:	call   74d <botlish_fn_3+0x175>
			749: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     74d:	test   rax,rax
     750:	je     772 <botlish_fn_3+0x19a>
     756:	mov    QWORD PTR [rsp+0x20],rax
     75b:	mov    rdx,rax
     75e:	mov    rsi,r15
     761:	mov    rdi,r13
     764:	call   769 <botlish_fn_3+0x191>
			765: R_X86_64_PLT32	rt_list_append-0x4
     769:	test   rax,rax
     76c:	jne    797 <botlish_fn_3+0x1bf>
     772:	xor    rax,rax
     775:	mov    rbx,QWORD PTR [rsp+0x30]
     77a:	mov    r12,QWORD PTR [rsp+0x38]
     77f:	mov    r13,QWORD PTR [rsp+0x40]
     784:	mov    r14,QWORD PTR [rsp+0x48]
     789:	mov    r15,QWORD PTR [rsp+0x50]
     78e:	add    rsp,0x60
     792:	mov    rsp,rbp
     795:	pop    rbp
     796:	ret
     797:	mov    QWORD PTR [rsp+0x18],rax
     79c:	mov    r15,rax
     79f:	mov    edx,0x3
     7a4:	mov    QWORD PTR [rsp+0x20],0x3
     7ad:	mov    rsi,r14
     7b0:	test   rsi,0x1
     7b7:	jne    7c5 <botlish_fn_3+0x1ed>
     7bd:	mov    rsi,r14
     7c0:	jmp    7ed <botlish_fn_3+0x215>
     7c5:	mov    rsi,r14
     7c8:	mov    rcx,rsi
     7cb:	add    rcx,0x2
     7cf:	seto   al
     7d2:	test   al,al
     7d4:	je     7e2 <botlish_fn_3+0x20a>
     7da:	mov    rsi,r14
     7dd:	jmp    7ed <botlish_fn_3+0x215>
     7e2:	mov    rsi,rcx
     7e5:	mov    r14,rcx
     7e8:	jmp    7fb <botlish_fn_3+0x223>
     7ed:	mov    rdi,r13
     7f0:	call   7f5 <botlish_fn_3+0x21d>
			7f1: R_X86_64_PLT32	rt_int_add-0x4
     7f5:	mov    rsi,rax
     7f8:	mov    r14,rax
     7fb:	mov    QWORD PTR [rsp+0x10],rsi
     800:	mov    rsi,r14
     803:	jmp    65e <botlish_fn_3+0x86>
     808:	(bad)
     809:	add    BYTE PTR [rax],al
     80b:	add    BYTE PTR [rax],al
     80d:	add    BYTE PTR [rax],al
	...

0000000000000810 <botlish_entry_3: byte::set<List[UnicodeChar]>>:
     810:	push   rbp
     811:	mov    rbp,rsp
     814:	mov    rsi,QWORD PTR [rdx]
     817:	call   81c <botlish_entry_3+0xc>
			818: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::set<List[UnicodeChar]>
     81c:	mov    rsp,rbp
     81f:	pop    rbp
     820:	ret

0000000000000821 <botlish_fn_4: ascii::is_digit<int>>:
     821:	push   rbp
     822:	mov    rbp,rsp
     825:	sar    rsi,1
     828:	cmp    rsi,0x30
     82c:	jge    83c <botlish_fn_4+0x1b>
     832:	mov    eax,0x2
     837:	jmp    855 <botlish_fn_4+0x34>
     83c:	cmp    rsi,0x39
     840:	jle    850 <botlish_fn_4+0x2f>
     846:	mov    eax,0x2
     84b:	jmp    855 <botlish_fn_4+0x34>
     850:	mov    eax,0x6
     855:	mov    rsp,rbp
     858:	pop    rbp
     859:	ret

000000000000085a <botlish_entry_4: ascii::is_digit<int>>:
     85a:	push   rbp
     85b:	mov    rbp,rsp
     85e:	mov    rsi,QWORD PTR [rdx]
     861:	call   866 <botlish_entry_4+0xc>
			862: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     866:	mov    rsp,rbp
     869:	pop    rbp
     86a:	ret

000000000000086b <botlish_fn_5: ascii::is_upper<int>>:
     86b:	push   rbp
     86c:	mov    rbp,rsp
     86f:	sar    rsi,1
     872:	cmp    rsi,0x41
     876:	jge    886 <botlish_fn_5+0x1b>
     87c:	mov    eax,0x2
     881:	jmp    89f <botlish_fn_5+0x34>
     886:	cmp    rsi,0x5a
     88a:	jle    89a <botlish_fn_5+0x2f>
     890:	mov    eax,0x2
     895:	jmp    89f <botlish_fn_5+0x34>
     89a:	mov    eax,0x6
     89f:	mov    rsp,rbp
     8a2:	pop    rbp
     8a3:	ret

00000000000008a4 <botlish_entry_5: ascii::is_upper<int>>:
     8a4:	push   rbp
     8a5:	mov    rbp,rsp
     8a8:	mov    rsi,QWORD PTR [rdx]
     8ab:	call   8b0 <botlish_entry_5+0xc>
			8ac: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     8b0:	mov    rsp,rbp
     8b3:	pop    rbp
     8b4:	ret

00000000000008b5 <botlish_fn_6: ascii::is_lower<int>>:
     8b5:	push   rbp
     8b6:	mov    rbp,rsp
     8b9:	sar    rsi,1
     8bc:	cmp    rsi,0x61
     8c0:	jge    8d0 <botlish_fn_6+0x1b>
     8c6:	mov    eax,0x2
     8cb:	jmp    8e9 <botlish_fn_6+0x34>
     8d0:	cmp    rsi,0x7a
     8d4:	jle    8e4 <botlish_fn_6+0x2f>
     8da:	mov    eax,0x2
     8df:	jmp    8e9 <botlish_fn_6+0x34>
     8e4:	mov    eax,0x6
     8e9:	mov    rsp,rbp
     8ec:	pop    rbp
     8ed:	ret

00000000000008ee <botlish_entry_6: ascii::is_lower<int>>:
     8ee:	push   rbp
     8ef:	mov    rbp,rsp
     8f2:	mov    rsi,QWORD PTR [rdx]
     8f5:	call   8fa <botlish_entry_6+0xc>
			8f6: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     8fa:	mov    rsp,rbp
     8fd:	pop    rbp
     8fe:	ret

00000000000008ff <botlish_fn_7: ascii::is_alphabetic<int>>:
     8ff:	push   rbp
     900:	mov    rbp,rsp
     903:	sub    rsp,0x10
     907:	mov    QWORD PTR [rsp],r12
     90b:	mov    QWORD PTR [rsp+0x8],r14
     910:	mov    r12,rsi
     913:	mov    r14,rdi
     916:	mov    rsi,r12
     919:	mov    rdi,r14
     91c:	call   921 <botlish_fn_7+0x22>
			91d: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     921:	cmp    rax,0x6
     925:	je     954 <botlish_fn_7+0x55>
     92b:	mov    rsi,r12
     92e:	mov    rdi,r14
     931:	call   936 <botlish_fn_7+0x37>
			932: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     936:	cmp    rax,0x6
     93a:	je     94a <botlish_fn_7+0x4b>
     940:	mov    eax,0x2
     945:	jmp    959 <botlish_fn_7+0x5a>
     94a:	mov    eax,0x6
     94f:	jmp    959 <botlish_fn_7+0x5a>
     954:	mov    eax,0x6
     959:	mov    r12,QWORD PTR [rsp]
     95d:	mov    r14,QWORD PTR [rsp+0x8]
     962:	add    rsp,0x10
     966:	mov    rsp,rbp
     969:	pop    rbp
     96a:	ret

000000000000096b <botlish_entry_7: ascii::is_alphabetic<int>>:
     96b:	push   rbp
     96c:	mov    rbp,rsp
     96f:	mov    rsi,QWORD PTR [rdx]
     972:	call   977 <botlish_entry_7+0xc>
			973: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     977:	mov    rsp,rbp
     97a:	pop    rbp
     97b:	ret

000000000000097c <botlish_fn_8: ascii::is_alphanumeric<int>>:
     97c:	push   rbp
     97d:	mov    rbp,rsp
     980:	sub    rsp,0x10
     984:	mov    QWORD PTR [rsp],r12
     988:	mov    QWORD PTR [rsp+0x8],r14
     98d:	mov    r12,rsi
     990:	mov    r14,rdi
     993:	mov    rsi,r12
     996:	mov    rdi,r14
     999:	call   99e <botlish_fn_8+0x22>
			99a: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     99e:	cmp    rax,0x6
     9a2:	je     9d1 <botlish_fn_8+0x55>
     9a8:	mov    rsi,r12
     9ab:	mov    rdi,r14
     9ae:	call   9b3 <botlish_fn_8+0x37>
			9af: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     9b3:	cmp    rax,0x6
     9b7:	je     9c7 <botlish_fn_8+0x4b>
     9bd:	mov    eax,0x2
     9c2:	jmp    9d6 <botlish_fn_8+0x5a>
     9c7:	mov    eax,0x6
     9cc:	jmp    9d6 <botlish_fn_8+0x5a>
     9d1:	mov    eax,0x6
     9d6:	mov    r12,QWORD PTR [rsp]
     9da:	mov    r14,QWORD PTR [rsp+0x8]
     9df:	add    rsp,0x10
     9e3:	mov    rsp,rbp
     9e6:	pop    rbp
     9e7:	ret

00000000000009e8 <botlish_entry_8: ascii::is_alphanumeric<int>>:
     9e8:	push   rbp
     9e9:	mov    rbp,rsp
     9ec:	mov    rsi,QWORD PTR [rdx]
     9ef:	call   9f4 <botlish_entry_8+0xc>
			9f0: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
     9f4:	mov    rsp,rbp
     9f7:	pop    rbp
     9f8:	ret

00000000000009f9 <botlish_fn_9: web::is_unreserved<generic>>:
     9f9:	push   rbp
     9fa:	mov    rbp,rsp
     9fd:	sub    rsp,0x20
     a01:	mov    QWORD PTR [rsp],rbx
     a05:	mov    QWORD PTR [rsp+0x8],r12
     a0a:	mov    QWORD PTR [rsp+0x10],r14
     a0f:	mov    rbx,rdi
     a12:	mov    r12,rsi
     a15:	mov    r14,rdx
     a18:	mov    rsi,r14
     a1b:	mov    rdi,rbx
     a1e:	call   a23 <botlish_fn_9+0x2a>
			a1f: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
     a23:	cmp    rax,0x6
     a27:	je     a60 <botlish_fn_9+0x67>
     a2d:	mov    rsi,r12
     a30:	mov    rax,QWORD PTR [rsi+0x20]
     a34:	mov    rsi,QWORD PTR [rax]
     a37:	mov    rdx,r14
     a3a:	mov    rdi,rbx
     a3d:	call   a42 <botlish_fn_9+0x49>
			a3e: R_X86_64_PLT32	rt_set_contains-0x4
     a42:	cmp    rax,0x6
     a46:	je     a56 <botlish_fn_9+0x5d>
     a4c:	mov    eax,0x2
     a51:	jmp    a65 <botlish_fn_9+0x6c>
     a56:	mov    eax,0x6
     a5b:	jmp    a65 <botlish_fn_9+0x6c>
     a60:	mov    eax,0x6
     a65:	mov    rbx,QWORD PTR [rsp]
     a69:	mov    r12,QWORD PTR [rsp+0x8]
     a6e:	mov    r14,QWORD PTR [rsp+0x10]
     a73:	add    rsp,0x20
     a77:	mov    rsp,rbp
     a7a:	pop    rbp
     a7b:	ret

0000000000000a7c <botlish_entry_9: web::is_unreserved<generic>>:
     a7c:	push   rbp
     a7d:	mov    rbp,rsp
     a80:	mov    rdx,QWORD PTR [rdx]
     a83:	call   a88 <botlish_entry_9+0xc>
			a84: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_unreserved<generic>
     a88:	mov    rsp,rbp
     a8b:	pop    rbp
     a8c:	ret

0000000000000a8d <botlish_fn_10: web::uri_escape_text<generic>>:
     a8d:	push   rbp
     a8e:	mov    rbp,rsp
     a91:	sub    rsp,0x30
     a95:	mov    QWORD PTR [rsp],rdx
     a99:	mov    r10,rdx
     a9c:	mov    edx,0x1
     aa1:	mov    QWORD PTR [rsp+0x8],0x1
     aaa:	mov    rax,QWORD PTR [rdi+0x10]
     aae:	mov    rcx,QWORD PTR [rax+0xa8]
     ab5:	mov    QWORD PTR [rsp+0x10],rcx
     aba:	mov    rax,QWORD PTR [rsi+0x20]
     abe:	mov    r8,QWORD PTR [rax+0x8]
     ac2:	mov    QWORD PTR [rsp+0x18],r8
     ac7:	mov    rax,QWORD PTR [rsi+0x20]
     acb:	mov    r9,QWORD PTR [rax]
     ace:	mov    QWORD PTR [rsp+0x20],r9
     ad3:	mov    rsi,r10
     ad6:	call   adb <botlish_fn_10+0x4e>
			ad7: R_X86_64_PLT32	botlish_fn_15-0x4 ; esc_from<generic>
     adb:	test   rax,rax
     ade:	jne    af0 <botlish_fn_10+0x63>
     ae4:	xor    rax,rax
     ae7:	add    rsp,0x30
     aeb:	mov    rsp,rbp
     aee:	pop    rbp
     aef:	ret
     af0:	add    rsp,0x30
     af4:	mov    rsp,rbp
     af7:	pop    rbp
     af8:	ret

0000000000000af9 <botlish_entry_10: web::uri_escape_text<generic>>:
     af9:	push   rbp
     afa:	mov    rbp,rsp
     afd:	mov    rdx,QWORD PTR [rdx]
     b00:	call   b05 <botlish_entry_10+0xc>
			b01: R_X86_64_PLT32	botlish_fn_10-0x4 ; web::uri_escape_text<generic>
     b05:	mov    rsp,rbp
     b08:	pop    rbp
     b09:	ret

0000000000000b0a <botlish_fn_11: high_nibble<generic>>:
     b0a:	push   rbp
     b0b:	mov    rbp,rsp
     b0e:	sub    rsp,0x20
     b12:	mov    QWORD PTR [rsp+0x10],rbx
     b17:	mov    QWORD PTR [rsp],rsi
     b1b:	mov    QWORD PTR [rsp+0x8],0x1e1
     b24:	mov    r8d,0x1
     b2a:	test   rsi,0x1
     b31:	jne    b51 <botlish_fn_11+0x47>
     b37:	xor    r8d,r8d
     b3a:	test   rsi,0x7
     b41:	jne    b51 <botlish_fn_11+0x47>
     b47:	movzx  rax,BYTE PTR [rsi]
     b4b:	cmp    al,0x1
     b4d:	sete   r8b
     b51:	test   r8b,r8b
     b54:	jne    b81 <botlish_fn_11+0x77>
     b5a:	mov    rax,QWORD PTR [rdi+0x10]
     b5e:	mov    rcx,QWORD PTR [rax+0xb0]
     b65:	xor    rbx,rbx
     b68:	mov    rdx,rbx
     b6b:	call   b70 <botlish_fn_11+0x66>
			b6c: R_X86_64_PLT32	rt_type_error-0x4
     b70:	mov    rax,rbx
     b73:	mov    rbx,QWORD PTR [rsp+0x10]
     b78:	add    rsp,0x20
     b7c:	mov    rsp,rbp
     b7f:	pop    rbp
     b80:	ret
     b81:	test   rsi,0x1
     b88:	jne    b9d <botlish_fn_11+0x93>
     b8e:	mov    edx,0x1e1
     b93:	call   b98 <botlish_fn_11+0x8e>
			b94: R_X86_64_PLT32	rt_int_and-0x4
     b98:	jmp    ba7 <botlish_fn_11+0x9d>
     b9d:	and    rsi,0x1e1
     ba4:	mov    rax,rsi
     ba7:	sar    rax,0x5
     bab:	shl    rax,1
     bae:	or     rax,0x1
     bb2:	mov    rbx,QWORD PTR [rsp+0x10]
     bb7:	add    rsp,0x20
     bbb:	mov    rsp,rbp
     bbe:	pop    rbp
     bbf:	ret

0000000000000bc0 <botlish_entry_11: high_nibble<generic>>:
     bc0:	push   rbp
     bc1:	mov    rbp,rsp
     bc4:	mov    rsi,QWORD PTR [rdx]
     bc7:	call   bcc <botlish_entry_11+0xc>
			bc8: R_X86_64_PLT32	botlish_fn_11-0x4 ; high_nibble<generic>
     bcc:	mov    rsp,rbp
     bcf:	pop    rbp
     bd0:	ret

0000000000000bd1 <botlish_fn_12: hex_pair<generic>>:
     bd1:	push   rbp
     bd2:	mov    rbp,rsp
     bd5:	sub    rsp,0x30
     bd9:	mov    QWORD PTR [rsp+0x10],rbx
     bde:	mov    QWORD PTR [rsp+0x18],r12
     be3:	mov    QWORD PTR [rsp+0x20],r13
     be8:	mov    QWORD PTR [rsp+0x28],r14
     bed:	mov    r12,rdi
     bf0:	mov    QWORD PTR [rsp],rsi
     bf4:	mov    r13,rsi
     bf7:	mov    QWORD PTR [rsp+0x8],rdx
     bfc:	mov    rbx,rdx
     bff:	mov    rsi,r13
     c02:	mov    rdi,r12
     c05:	call   c0a <botlish_fn_12+0x39>
			c06: R_X86_64_PLT32	botlish_fn_11-0x4 ; high_nibble<generic>
     c0a:	test   rax,rax
     c0d:	je     d3b <botlish_fn_12+0x16a>
     c13:	test   rax,0x1
     c19:	jne    c27 <botlish_fn_12+0x56>
     c1f:	mov    rdx,rax
     c22:	jmp    c3d <botlish_fn_12+0x6c>
     c27:	mov    rdx,QWORD PTR [rbx+0x8]
     c2b:	mov    rcx,rax
     c2e:	sar    rcx,1
     c31:	cmp    rcx,rdx
     c34:	jb     c59 <botlish_fn_12+0x88>
     c3a:	mov    rdx,rax
     c3d:	mov    rsi,rbx
     c40:	mov    rdi,r12
     c43:	call   c48 <botlish_fn_12+0x77>
			c44: R_X86_64_PLT32	rt_list_get-0x4
     c48:	test   rax,rax
     c4b:	je     d3b <botlish_fn_12+0x16a>
     c51:	mov    rsi,rax
     c54:	jmp    c61 <botlish_fn_12+0x90>
     c59:	mov    rax,QWORD PTR [rbx+0x10]
     c5d:	mov    rsi,QWORD PTR [rax+rcx*8]
     c61:	mov    QWORD PTR [rsp],rsi
     c65:	mov    r14,rsi
     c68:	mov    ecx,0x1
     c6d:	mov    rsi,r13
     c70:	test   rsi,0x1
     c77:	jne    c95 <botlish_fn_12+0xc4>
     c7d:	xor    ecx,ecx
     c7f:	test   rsi,0x7
     c86:	jne    c95 <botlish_fn_12+0xc4>
     c8c:	movzx  rax,BYTE PTR [rsi]
     c90:	cmp    al,0x1
     c92:	sete   cl
     c95:	test   cl,cl
     c97:	jne    cb8 <botlish_fn_12+0xe7>
     c9d:	mov    rdi,r12
     ca0:	mov    rax,QWORD PTR [rdi+0x10]
     ca4:	mov    rcx,QWORD PTR [rax+0xb8]
     cab:	xor    rdx,rdx
     cae:	call   cb3 <botlish_fn_12+0xe2>
			caf: R_X86_64_PLT32	rt_type_error-0x4
     cb3:	jmp    d3b <botlish_fn_12+0x16a>
     cb8:	mov    edx,0x21
     cbd:	mov    rdi,r12
     cc0:	call   cc5 <botlish_fn_12+0xf4>
			cc1: R_X86_64_PLT32	rt_int_mod-0x4
     cc5:	test   rax,rax
     cc8:	je     d3b <botlish_fn_12+0x16a>
     cce:	test   rax,0x1
     cd4:	jne    ce5 <botlish_fn_12+0x114>
     cda:	mov    rdx,rax
     cdd:	mov    rsi,rbx
     ce0:	jmp    cfe <botlish_fn_12+0x12d>
     ce5:	mov    rdi,QWORD PTR [rbx+0x8]
     ce9:	mov    rsi,rax
     cec:	sar    rsi,1
     cef:	mov    rdx,rax
     cf2:	cmp    rsi,rdi
     cf5:	jb     d17 <botlish_fn_12+0x146>
     cfb:	mov    rsi,rbx
     cfe:	mov    rdi,r12
     d01:	call   d06 <botlish_fn_12+0x135>
			d02: R_X86_64_PLT32	rt_list_get-0x4
     d06:	test   rax,rax
     d09:	je     d3b <botlish_fn_12+0x16a>
     d0f:	mov    rdx,rax
     d12:	jmp    d22 <botlish_fn_12+0x151>
     d17:	mov    rax,rbx
     d1a:	mov    rax,QWORD PTR [rax+0x10]
     d1e:	mov    rdx,QWORD PTR [rax+rsi*8]
     d22:	mov    QWORD PTR [rsp+0x8],rdx
     d27:	mov    rsi,r14
     d2a:	mov    rdi,r12
     d2d:	call   d32 <botlish_fn_12+0x161>
			d2e: R_X86_64_PLT32	rt_str_cat-0x4
     d32:	test   rax,rax
     d35:	jne    d5b <botlish_fn_12+0x18a>
     d3b:	xor    rax,rax
     d3e:	mov    rbx,QWORD PTR [rsp+0x10]
     d43:	mov    r12,QWORD PTR [rsp+0x18]
     d48:	mov    r13,QWORD PTR [rsp+0x20]
     d4d:	mov    r14,QWORD PTR [rsp+0x28]
     d52:	add    rsp,0x30
     d56:	mov    rsp,rbp
     d59:	pop    rbp
     d5a:	ret
     d5b:	mov    rbx,QWORD PTR [rsp+0x10]
     d60:	mov    r12,QWORD PTR [rsp+0x18]
     d65:	mov    r13,QWORD PTR [rsp+0x20]
     d6a:	mov    r14,QWORD PTR [rsp+0x28]
     d6f:	add    rsp,0x30
     d73:	mov    rsp,rbp
     d76:	pop    rbp
     d77:	ret

0000000000000d78 <botlish_entry_12: hex_pair<generic>>:
     d78:	push   rbp
     d79:	mov    rbp,rsp
     d7c:	mov    rsi,QWORD PTR [rdx]
     d7f:	mov    rdx,QWORD PTR [rdx+0x8]
     d83:	call   d88 <botlish_entry_12+0x10>
			d84: R_X86_64_PLT32	botlish_fn_12-0x4 ; hex_pair<generic>
     d88:	mov    rsp,rbp
     d8b:	pop    rbp
     d8c:	ret
     d8d:	add    BYTE PTR [rax],al
	...

0000000000000d90 <botlish_fn_13: esc_bytes<generic>>:
     d90:	push   rbp
     d91:	mov    rbp,rsp
     d94:	sub    rsp,0x70
     d98:	mov    QWORD PTR [rsp+0x40],rbx
     d9d:	mov    QWORD PTR [rsp+0x48],r12
     da2:	mov    QWORD PTR [rsp+0x50],r13
     da7:	mov    QWORD PTR [rsp+0x58],r14
     dac:	mov    QWORD PTR [rsp+0x60],r15
     db1:	mov    r13,rdi
     db4:	mov    QWORD PTR [rsp+0x28],0x0
     dbd:	mov    QWORD PTR [rsp],rsi
     dc1:	mov    QWORD PTR [rsp+0x8],rdx
     dc6:	mov    QWORD PTR [rsp+0x10],rcx
     dcb:	mov    QWORD PTR [rsp+0x18],r8
     dd0:	mov    r12,r8
     dd3:	mov    r14,rcx
     dd6:	mov    r15,rdx
     dd9:	xor    eax,eax
     ddb:	test   rsi,0x7
     de2:	jne    df3 <botlish_fn_13+0x63>
     de8:	movzx  r8,BYTE PTR [rsi]
     dec:	cmp    r8b,0x3
     df0:	sete   al
     df3:	test   al,al
     df5:	jne    e18 <botlish_fn_13+0x88>
     dfb:	mov    rdi,r13
     dfe:	mov    rax,QWORD PTR [rdi+0x10]
     e02:	mov    rcx,QWORD PTR [rax+0xc0]
     e09:	mov    edx,0x4
     e0e:	call   e13 <botlish_fn_13+0x83>
			e0f: R_X86_64_PLT32	rt_type_error-0x4
     e13:	jmp    101e <botlish_fn_13+0x28e>
     e18:	mov    rbx,rsi
     e1b:	mov    rdi,r13
     e1e:	call   e23 <botlish_fn_13+0x93>
			e1f: R_X86_64_PLT32	rt_list_len-0x4
     e23:	mov    ecx,0x1
     e28:	mov    rsi,r15
     e2b:	test   rsi,0x1
     e32:	jne    e58 <botlish_fn_13+0xc8>
     e38:	xor    ecx,ecx
     e3a:	mov    rsi,r15
     e3d:	test   rsi,0x7
     e44:	jne    e58 <botlish_fn_13+0xc8>
     e4a:	mov    rsi,r15
     e4d:	movzx  rcx,BYTE PTR [rsi]
     e51:	rex cmp cl,0x1
     e55:	sete   cl
     e58:	test   cl,cl
     e5a:	jne    e7e <botlish_fn_13+0xee>
     e60:	mov    rdi,r13
     e63:	mov    rax,QWORD PTR [rdi+0x10]
     e67:	mov    rcx,QWORD PTR [rax+0xc8]
     e6e:	xor    rdx,rdx
     e71:	mov    rsi,r15
     e74:	call   e79 <botlish_fn_13+0xe9>
			e75: R_X86_64_PLT32	rt_type_error-0x4
     e79:	jmp    101e <botlish_fn_13+0x28e>
     e7e:	mov    rsi,r15
     e81:	mov    rcx,rsi
     e84:	and    rcx,rax
     e87:	mov    rdx,rax
     e8a:	test   rcx,0x1
     e91:	jne    eb7 <botlish_fn_13+0x127>
     e97:	mov    rsi,r15
     e9a:	mov    rdi,r13
     e9d:	call   ea2 <botlish_fn_13+0x112>
			e9e: R_X86_64_PLT32	rt_int_cmp-0x4
     ea2:	mov    ecx,0x2
     ea7:	test   rax,rax
     eaa:	cmovge rcx,QWORD PTR [rip+0x1de]        # 1090 <botlish_fn_13+0x300>
     eb2:	jmp    eca <botlish_fn_13+0x13a>
     eb7:	mov    ecx,0x2
     ebc:	mov    rsi,r15
     ebf:	cmp    rsi,rdx
     ec2:	cmovge rcx,QWORD PTR [rip+0x1c6]        # 1090 <botlish_fn_13+0x300>
     eca:	cmp    rcx,0x6
     ece:	je     1069 <botlish_fn_13+0x2d9>
     ed4:	mov    QWORD PTR [rsp+0x20],0x3
     edd:	mov    rsi,r15
     ee0:	test   rsi,0x1
     ee7:	je     f02 <botlish_fn_13+0x172>
     eed:	mov    rsi,r15
     ef0:	mov    rax,rsi
     ef3:	add    rax,0x2
     ef7:	seto   cl
     efa:	test   cl,cl
     efc:	je     f12 <botlish_fn_13+0x182>
     f02:	mov    edx,0x3
     f07:	mov    rsi,r15
     f0a:	mov    rdi,r13
     f0d:	call   f12 <botlish_fn_13+0x182>
			f0e: R_X86_64_PLT32	rt_int_add-0x4
     f12:	mov    QWORD PTR [rsp+0x8],rax
     f17:	mov    rdi,r13
     f1a:	mov    QWORD PTR [rsp+0x30],rax
     f1f:	mov    rax,QWORD PTR [rdi+0x10]
     f23:	mov    rsi,QWORD PTR [rax+0xd0]
     f2a:	mov    QWORD PTR [rsp+0x20],rsi
     f2f:	mov    QWORD PTR [rsp+0x38],rsi
     f34:	mov    rsi,r15
     f37:	test   rsi,0x1
     f3e:	jne    f4c <botlish_fn_13+0x1bc>
     f44:	mov    rdx,r15
     f47:	jmp    f65 <botlish_fn_13+0x1d5>
     f4c:	mov    rcx,QWORD PTR [rbx+0x8]
     f50:	mov    rsi,r15
     f53:	mov    rax,rsi
     f56:	sar    rax,1
     f59:	cmp    rax,rcx
     f5c:	jb     f81 <botlish_fn_13+0x1f1>
     f62:	mov    rdx,r15
     f65:	mov    rsi,rbx
     f68:	mov    rdi,r13
     f6b:	call   f70 <botlish_fn_13+0x1e0>
			f6c: R_X86_64_PLT32	rt_list_get-0x4
     f70:	test   rax,rax
     f73:	je     101e <botlish_fn_13+0x28e>
     f79:	mov    rsi,rax
     f7c:	jmp    f89 <botlish_fn_13+0x1f9>
     f81:	mov    rcx,QWORD PTR [rbx+0x10]
     f85:	mov    rsi,QWORD PTR [rcx+rax*8]
     f89:	mov    QWORD PTR [rsp+0x28],rsi
     f8e:	mov    rdx,r12
     f91:	mov    rdi,r13
     f94:	call   f99 <botlish_fn_13+0x209>
			f95: R_X86_64_PLT32	botlish_fn_12-0x4 ; hex_pair<generic>
     f99:	test   rax,rax
     f9c:	je     101e <botlish_fn_13+0x28e>
     fa2:	mov    QWORD PTR [rsp+0x28],rax
     fa7:	mov    rdx,rax
     faa:	mov    rsi,QWORD PTR [rsp+0x38]
     faf:	mov    rdi,r13
     fb2:	call   fb7 <botlish_fn_13+0x227>
			fb3: R_X86_64_PLT32	rt_str_cat-0x4
     fb7:	test   rax,rax
     fba:	je     101e <botlish_fn_13+0x28e>
     fc0:	mov    QWORD PTR [rsp+0x20],rax
     fc5:	mov    rdx,rax
     fc8:	xor    eax,eax
     fca:	mov    rsi,r14
     fcd:	test   rsi,0x7
     fd4:	jne    fe5 <botlish_fn_13+0x255>
     fda:	movzx  rdi,BYTE PTR [rsi]
     fde:	cmp    dil,0x2
     fe2:	sete   al
     fe5:	test   al,al
     fe7:	jne    100d <botlish_fn_13+0x27d>
     fed:	mov    rdi,r13
     ff0:	mov    rdi,QWORD PTR [rdi+0x10]
     ff4:	mov    rcx,QWORD PTR [rdi+0xd8]
     ffb:	mov    edx,0x1
    1000:	mov    rdi,r13
    1003:	call   1008 <botlish_fn_13+0x278>
			1004: R_X86_64_PLT32	rt_type_error-0x4
    1008:	jmp    101e <botlish_fn_13+0x28e>
    100d:	mov    rdi,r13
    1010:	call   1015 <botlish_fn_13+0x285>
			1011: R_X86_64_PLT32	rt_str_cat-0x4
    1015:	test   rax,rax
    1018:	jne    1043 <botlish_fn_13+0x2b3>
    101e:	xor    rax,rax
    1021:	mov    rbx,QWORD PTR [rsp+0x40]
    1026:	mov    r12,QWORD PTR [rsp+0x48]
    102b:	mov    r13,QWORD PTR [rsp+0x50]
    1030:	mov    r14,QWORD PTR [rsp+0x58]
    1035:	mov    r15,QWORD PTR [rsp+0x60]
    103a:	add    rsp,0x70
    103e:	mov    rsp,rbp
    1041:	pop    rbp
    1042:	ret
    1043:	mov    QWORD PTR [rsp],rbx
    1047:	mov    rcx,QWORD PTR [rsp+0x30]
    104c:	mov    QWORD PTR [rsp+0x8],rcx
    1051:	mov    QWORD PTR [rsp+0x10],rax
    1056:	mov    QWORD PTR [rsp+0x18],r12
    105b:	mov    rsi,rbx
    105e:	mov    r14,rax
    1061:	mov    r15,rcx
    1064:	jmp    dd9 <botlish_fn_13+0x49>
    1069:	mov    rax,r14
    106c:	mov    rbx,QWORD PTR [rsp+0x40]
    1071:	mov    r12,QWORD PTR [rsp+0x48]
    1076:	mov    r13,QWORD PTR [rsp+0x50]
    107b:	mov    r14,QWORD PTR [rsp+0x58]
    1080:	mov    r15,QWORD PTR [rsp+0x60]
    1085:	add    rsp,0x70
    1089:	mov    rsp,rbp
    108c:	pop    rbp
    108d:	ret
    108e:	add    BYTE PTR [rax],al
    1090:	(bad)
    1091:	add    BYTE PTR [rax],al
    1093:	add    BYTE PTR [rax],al
    1095:	add    BYTE PTR [rax],al
	...

0000000000001098 <botlish_entry_13: esc_bytes<generic>>:
    1098:	push   rbp
    1099:	mov    rbp,rsp
    109c:	mov    rsi,QWORD PTR [rdx]
    109f:	mov    r9,QWORD PTR [rdx+0x8]
    10a3:	mov    rcx,QWORD PTR [rdx+0x10]
    10a7:	mov    r8,QWORD PTR [rdx+0x18]
    10ab:	mov    rdx,r9
    10ae:	call   10b3 <botlish_entry_13+0x1b>
			10af: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    10b3:	mov    rsp,rbp
    10b6:	pop    rbp
    10b7:	ret

00000000000010b8 <botlish_fn_14: esc_char<generic>>:
    10b8:	push   rbp
    10b9:	mov    rbp,rsp
    10bc:	sub    rsp,0x60
    10c0:	mov    QWORD PTR [rsp+0x30],rbx
    10c5:	mov    QWORD PTR [rsp+0x38],r12
    10ca:	mov    QWORD PTR [rsp+0x40],r13
    10cf:	mov    QWORD PTR [rsp+0x48],r14
    10d4:	mov    QWORD PTR [rsp+0x50],r15
    10d9:	mov    QWORD PTR [rsp+0x18],0x0
    10e2:	mov    QWORD PTR [rsp],rsi
    10e6:	mov    QWORD PTR [rsp+0x8],rdx
    10eb:	mov    r12,rdx
    10ee:	mov    QWORD PTR [rsp+0x10],rcx
    10f3:	mov    rbx,rcx
    10f6:	xor    r10d,r10d
    10f9:	test   rsi,0x7
    1100:	jne    1110 <botlish_fn_14+0x58>
    1106:	movzx  rax,BYTE PTR [rsi]
    110a:	cmp    al,0x2
    110c:	sete   r10b
    1110:	test   r10b,r10b
    1113:	jne    1133 <botlish_fn_14+0x7b>
    1119:	mov    rax,QWORD PTR [rdi+0x10]
    111d:	mov    rcx,QWORD PTR [rax+0xe0]
    1124:	mov    edx,0x1
    1129:	call   112e <botlish_fn_14+0x76>
			112a: R_X86_64_PLT32	rt_type_error-0x4
    112e:	jmp    1232 <botlish_fn_14+0x17a>
    1133:	mov    r13,rdi
    1136:	mov    QWORD PTR [rsp+0x20],rsi
    113b:	call   1140 <botlish_fn_14+0x88>
			113c: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1140:	mov    rcx,rax
    1143:	mov    r14,rax
    1146:	test   rax,rcx
    1149:	je     1232 <botlish_fn_14+0x17a>
    114f:	mov    rax,r14
    1152:	mov    QWORD PTR [rsp],rax
    1156:	mov    rsi,r14
    1159:	mov    rdi,r13
    115c:	call   1161 <botlish_fn_14+0xa9>
			115d: R_X86_64_PLT32	rt_list_len-0x4
    1161:	mov    edx,0x1
    1166:	sar    rax,1
    1169:	cmp    rax,0x1
    116d:	je     11a8 <botlish_fn_14+0xf0>
    1173:	mov    QWORD PTR [rsp+0x8],0x1
    117c:	mov    rdi,r13
    117f:	mov    rax,QWORD PTR [rdi+0x10]
    1183:	mov    rcx,QWORD PTR [rax+0xa8]
    118a:	mov    QWORD PTR [rsp+0x18],rcx
    118f:	mov    rsi,r14
    1192:	mov    r8,rbx
    1195:	call   119a <botlish_fn_14+0xe2>
			1196: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    119a:	test   rax,rax
    119d:	je     1232 <botlish_fn_14+0x17a>
    11a3:	jmp    1261 <botlish_fn_14+0x1a9>
    11a8:	mov    rsi,r14
    11ab:	mov    r15,rdx
    11ae:	mov    rax,QWORD PTR [rsi+0x8]
    11b2:	mov    r14,rsi
    11b5:	test   rax,rax
    11b8:	jne    11e0 <botlish_fn_14+0x128>
    11be:	mov    rdx,r15
    11c1:	mov    rsi,r14
    11c4:	mov    rdi,r13
    11c7:	call   11cc <botlish_fn_14+0x114>
			11c8: R_X86_64_PLT32	rt_list_get-0x4
    11cc:	test   rax,rax
    11cf:	je     1232 <botlish_fn_14+0x17a>
    11d5:	mov    rdx,rax
    11d8:	mov    rsi,r12
    11db:	jmp    11ed <botlish_fn_14+0x135>
    11e0:	mov    rsi,r14
    11e3:	mov    rdx,QWORD PTR [rsi+0x10]
    11e7:	mov    rdx,QWORD PTR [rdx]
    11ea:	mov    rsi,r12
    11ed:	mov    rdi,r13
    11f0:	call   11f5 <botlish_fn_14+0x13d>
			11f1: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_unreserved<generic>
    11f5:	cmp    rax,0x6
    11f9:	je     125c <botlish_fn_14+0x1a4>
    11ff:	mov    QWORD PTR [rsp+0x8],0x1
    1208:	mov    rdi,r13
    120b:	mov    rsi,QWORD PTR [rdi+0x10]
    120f:	mov    rcx,QWORD PTR [rsi+0xa8]
    1216:	mov    QWORD PTR [rsp+0x18],rcx
    121b:	mov    rdx,r15
    121e:	mov    rsi,r14
    1221:	mov    r8,rbx
    1224:	call   1229 <botlish_fn_14+0x171>
			1225: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    1229:	test   rax,rax
    122c:	jne    1257 <botlish_fn_14+0x19f>
    1232:	xor    rax,rax
    1235:	mov    rbx,QWORD PTR [rsp+0x30]
    123a:	mov    r12,QWORD PTR [rsp+0x38]
    123f:	mov    r13,QWORD PTR [rsp+0x40]
    1244:	mov    r14,QWORD PTR [rsp+0x48]
    1249:	mov    r15,QWORD PTR [rsp+0x50]
    124e:	add    rsp,0x60
    1252:	mov    rsp,rbp
    1255:	pop    rbp
    1256:	ret
    1257:	mov    QWORD PTR [rsp+0x20],rax
    125c:	mov    rax,QWORD PTR [rsp+0x20]
    1261:	mov    rbx,QWORD PTR [rsp+0x30]
    1266:	mov    r12,QWORD PTR [rsp+0x38]
    126b:	mov    r13,QWORD PTR [rsp+0x40]
    1270:	mov    r14,QWORD PTR [rsp+0x48]
    1275:	mov    r15,QWORD PTR [rsp+0x50]
    127a:	add    rsp,0x60
    127e:	mov    rsp,rbp
    1281:	pop    rbp
    1282:	ret

0000000000001283 <botlish_entry_14: esc_char<generic>>:
    1283:	push   rbp
    1284:	mov    rbp,rsp
    1287:	mov    rsi,QWORD PTR [rdx]
    128a:	mov    r8,QWORD PTR [rdx+0x8]
    128e:	mov    rcx,QWORD PTR [rdx+0x10]
    1292:	mov    rdx,r8
    1295:	call   129a <botlish_entry_14+0x17>
			1296: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_char<generic>
    129a:	mov    rsp,rbp
    129d:	pop    rbp
    129e:	ret
	...

00000000000012a0 <botlish_fn_15: esc_from<generic>>:
    12a0:	push   rbp
    12a1:	mov    rbp,rsp
    12a4:	sub    rsp,0x80
    12ab:	mov    QWORD PTR [rsp+0x50],rbx
    12b0:	mov    QWORD PTR [rsp+0x58],r12
    12b5:	mov    QWORD PTR [rsp+0x60],r13
    12ba:	mov    QWORD PTR [rsp+0x68],r14
    12bf:	mov    QWORD PTR [rsp+0x70],r15
    12c4:	mov    r14,rdi
    12c7:	mov    QWORD PTR [rsp+0x30],0x0
    12d0:	mov    QWORD PTR [rsp],rsi
    12d4:	mov    QWORD PTR [rsp+0x8],rdx
    12d9:	mov    QWORD PTR [rsp+0x10],rcx
    12de:	mov    QWORD PTR [rsp+0x18],r8
    12e3:	mov    r13,r8
    12e6:	mov    QWORD PTR [rsp+0x20],r9
    12eb:	mov    r12,r9
    12ee:	mov    r15,rcx
    12f1:	mov    QWORD PTR [rsp+0x38],rdx
    12f6:	xor    eax,eax
    12f8:	test   rsi,0x7
    12ff:	jne    130e <botlish_fn_15+0x6e>
    1305:	movzx  rax,BYTE PTR [rsi]
    1309:	cmp    al,0x2
    130b:	sete   al
    130e:	test   al,al
    1310:	jne    1333 <botlish_fn_15+0x93>
    1316:	mov    rdi,r14
    1319:	mov    rax,QWORD PTR [rdi+0x10]
    131d:	mov    rcx,QWORD PTR [rax+0xe8]
    1324:	mov    edx,0x1
    1329:	call   132e <botlish_fn_15+0x8e>
			132a: R_X86_64_PLT32	rt_type_error-0x4
    132e:	jmp    158b <botlish_fn_15+0x2eb>
    1333:	mov    rbx,rsi
    1336:	mov    rdi,r14
    1339:	call   133e <botlish_fn_15+0x9e>
			133a: R_X86_64_PLT32	rt_str_len-0x4
    133e:	mov    edx,0x1
    1343:	mov    QWORD PTR [rsp+0x48],rdx
    1348:	mov    ecx,0x1
    134d:	mov    rsi,QWORD PTR [rsp+0x38]
    1352:	test   rsi,0x1
    1359:	jne    1383 <botlish_fn_15+0xe3>
    135f:	xor    ecx,ecx
    1361:	mov    rsi,QWORD PTR [rsp+0x38]
    1366:	test   rsi,0x7
    136d:	jne    1383 <botlish_fn_15+0xe3>
    1373:	mov    rsi,QWORD PTR [rsp+0x38]
    1378:	movzx  rcx,BYTE PTR [rsi]
    137c:	rex cmp cl,0x1
    1380:	sete   cl
    1383:	test   cl,cl
    1385:	jne    13ab <botlish_fn_15+0x10b>
    138b:	mov    rdi,r14
    138e:	mov    rax,QWORD PTR [rdi+0x10]
    1392:	mov    rcx,QWORD PTR [rax+0xc8]
    1399:	xor    rdx,rdx
    139c:	mov    rsi,QWORD PTR [rsp+0x38]
    13a1:	call   13a6 <botlish_fn_15+0x106>
			13a2: R_X86_64_PLT32	rt_type_error-0x4
    13a6:	jmp    158b <botlish_fn_15+0x2eb>
    13ab:	mov    rsi,QWORD PTR [rsp+0x38]
    13b0:	mov    rcx,rsi
    13b3:	and    rcx,rax
    13b6:	mov    rdx,rax
    13b9:	test   rcx,0x1
    13c0:	jne    13e8 <botlish_fn_15+0x148>
    13c6:	mov    rsi,QWORD PTR [rsp+0x38]
    13cb:	mov    rdi,r14
    13ce:	call   13d3 <botlish_fn_15+0x133>
			13cf: R_X86_64_PLT32	rt_int_cmp-0x4
    13d3:	mov    ecx,0x2
    13d8:	test   rax,rax
    13db:	cmovge rcx,QWORD PTR [rip+0x235]        # 1618 <botlish_fn_15+0x378>
    13e3:	jmp    13fd <botlish_fn_15+0x15d>
    13e8:	mov    ecx,0x2
    13ed:	mov    rsi,QWORD PTR [rsp+0x38]
    13f2:	cmp    rsi,rdx
    13f5:	cmovge rcx,QWORD PTR [rip+0x21b]        # 1618 <botlish_fn_15+0x378>
    13fd:	cmp    rcx,0x6
    1401:	je     15e9 <botlish_fn_15+0x349>
    1407:	mov    QWORD PTR [rsp+0x28],0x3
    1410:	mov    rsi,QWORD PTR [rsp+0x38]
    1415:	test   rsi,0x1
    141c:	je     1439 <botlish_fn_15+0x199>
    1422:	mov    rsi,QWORD PTR [rsp+0x38]
    1427:	mov    rax,rsi
    142a:	add    rax,0x2
    142e:	seto   cl
    1431:	test   cl,cl
    1433:	je     144b <botlish_fn_15+0x1ab>
    1439:	mov    edx,0x3
    143e:	mov    rsi,QWORD PTR [rsp+0x38]
    1443:	mov    rdi,r14
    1446:	call   144b <botlish_fn_15+0x1ab>
			1447: R_X86_64_PLT32	rt_int_add-0x4
    144b:	mov    QWORD PTR [rsp+0x28],rax
    1450:	mov    QWORD PTR [rsp+0x40],rax
    1455:	mov    QWORD PTR [rsp+0x30],0x3
    145e:	mov    rsi,QWORD PTR [rsp+0x38]
    1463:	test   rsi,0x1
    146a:	je     1487 <botlish_fn_15+0x1e7>
    1470:	mov    rsi,QWORD PTR [rsp+0x38]
    1475:	mov    rcx,rsi
    1478:	add    rcx,0x2
    147c:	seto   al
    147f:	test   al,al
    1481:	je     149c <botlish_fn_15+0x1fc>
    1487:	mov    edx,0x3
    148c:	mov    rsi,QWORD PTR [rsp+0x38]
    1491:	mov    rdi,r14
    1494:	call   1499 <botlish_fn_15+0x1f9>
			1495: R_X86_64_PLT32	rt_int_add-0x4
    1499:	mov    rcx,rax
    149c:	mov    QWORD PTR [rsp+0x30],rcx
    14a1:	mov    rdx,QWORD PTR [rsp+0x38]
    14a6:	mov    rsi,rbx
    14a9:	mov    rdi,r14
    14ac:	call   14b1 <botlish_fn_15+0x211>
			14ad: R_X86_64_PLT32	rt_substr-0x4
    14b1:	test   rax,rax
    14b4:	je     158b <botlish_fn_15+0x2eb>
    14ba:	mov    QWORD PTR [rsp+0x8],rax
    14bf:	mov    r8,r12
    14c2:	mov    r12,r13
    14c5:	mov    r13,r8
    14c8:	mov    rsi,rax
    14cb:	mov    rcx,r13
    14ce:	mov    rdx,r12
    14d1:	mov    rdi,r14
    14d4:	call   14d9 <botlish_fn_15+0x239>
			14d5: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_char<generic>
    14d9:	test   rax,rax
    14dc:	je     158b <botlish_fn_15+0x2eb>
    14e2:	mov    QWORD PTR [rsp+0x8],rax
    14e7:	xor    ecx,ecx
    14e9:	mov    rsi,r15
    14ec:	test   rsi,0x7
    14f3:	jne    1504 <botlish_fn_15+0x264>
    14f9:	movzx  rdi,BYTE PTR [rsi]
    14fd:	cmp    dil,0x2
    1501:	sete   cl
    1504:	test   cl,cl
    1506:	jne    1529 <botlish_fn_15+0x289>
    150c:	mov    rdi,r14
    150f:	mov    r11,QWORD PTR [rdi+0x10]
    1513:	mov    rcx,QWORD PTR [r11+0xd8]
    151a:	mov    rdx,QWORD PTR [rsp+0x48]
    151f:	call   1524 <botlish_fn_15+0x284>
			1520: R_X86_64_PLT32	rt_type_error-0x4
    1524:	jmp    158b <botlish_fn_15+0x2eb>
    1529:	mov    rdx,QWORD PTR [rsp+0x48]
    152e:	xor    edi,edi
    1530:	test   rax,0x7
    1536:	je     1544 <botlish_fn_15+0x2a4>
    153c:	mov    r8,rax
    153f:	jmp    1553 <botlish_fn_15+0x2b3>
    1544:	movzx  rcx,BYTE PTR [rax]
    1548:	mov    r8,rax
    154b:	rex cmp cl,0x2
    154f:	sete   dil
    1553:	test   dil,dil
    1556:	jne    1577 <botlish_fn_15+0x2d7>
    155c:	mov    rdi,r14
    155f:	mov    rax,QWORD PTR [rdi+0x10]
    1563:	mov    rcx,QWORD PTR [rax+0xd8]
    156a:	mov    rsi,r8
    156d:	call   1572 <botlish_fn_15+0x2d2>
			156e: R_X86_64_PLT32	rt_type_error-0x4
    1572:	jmp    158b <botlish_fn_15+0x2eb>
    1577:	mov    rdx,r8
    157a:	mov    rdi,r14
    157d:	call   1582 <botlish_fn_15+0x2e2>
			157e: R_X86_64_PLT32	rt_str_cat-0x4
    1582:	test   rax,rax
    1585:	jne    15b3 <botlish_fn_15+0x313>
    158b:	xor    rax,rax
    158e:	mov    rbx,QWORD PTR [rsp+0x50]
    1593:	mov    r12,QWORD PTR [rsp+0x58]
    1598:	mov    r13,QWORD PTR [rsp+0x60]
    159d:	mov    r14,QWORD PTR [rsp+0x68]
    15a2:	mov    r15,QWORD PTR [rsp+0x70]
    15a7:	add    rsp,0x80
    15ae:	mov    rsp,rbp
    15b1:	pop    rbp
    15b2:	ret
    15b3:	mov    QWORD PTR [rsp],rbx
    15b7:	mov    rcx,QWORD PTR [rsp+0x40]
    15bc:	mov    QWORD PTR [rsp+0x8],rcx
    15c1:	mov    QWORD PTR [rsp+0x10],rax
    15c6:	mov    QWORD PTR [rsp+0x18],r12
    15cb:	mov    QWORD PTR [rsp+0x20],r13
    15d0:	mov    QWORD PTR [rsp+0x38],rcx
    15d5:	mov    r15,rax
    15d8:	mov    rdx,r12
    15db:	mov    r12,r13
    15de:	mov    r13,rdx
    15e1:	mov    rsi,rbx
    15e4:	jmp    12f6 <botlish_fn_15+0x56>
    15e9:	mov    rax,r15
    15ec:	mov    rbx,QWORD PTR [rsp+0x50]
    15f1:	mov    r12,QWORD PTR [rsp+0x58]
    15f6:	mov    r13,QWORD PTR [rsp+0x60]
    15fb:	mov    r14,QWORD PTR [rsp+0x68]
    1600:	mov    r15,QWORD PTR [rsp+0x70]
    1605:	add    rsp,0x80
    160c:	mov    rsp,rbp
    160f:	pop    rbp
    1610:	ret
    1611:	add    BYTE PTR [rax],al
    1613:	add    BYTE PTR [rax],al
    1615:	add    BYTE PTR [rax],al
    1617:	add    BYTE PTR [rsi],al
    1619:	add    BYTE PTR [rax],al
    161b:	add    BYTE PTR [rax],al
    161d:	add    BYTE PTR [rax],al
	...

0000000000001620 <botlish_entry_15: esc_from<generic>>:
    1620:	push   rbp
    1621:	mov    rbp,rsp
    1624:	mov    rsi,QWORD PTR [rdx]
    1627:	mov    r10,QWORD PTR [rdx+0x8]
    162b:	mov    rcx,QWORD PTR [rdx+0x10]
    162f:	mov    r8,QWORD PTR [rdx+0x18]
    1633:	mov    r9,QWORD PTR [rdx+0x20]
    1637:	mov    rdx,r10
    163a:	call   163f <botlish_entry_15+0x1f>
			163b: R_X86_64_PLT32	botlish_fn_15-0x4 ; esc_from<generic>
    163f:	mov    rsp,rbp
    1642:	pop    rbp
    1643:	ret
    1644:	add    BYTE PTR [rax],al
	...

0000000000001648 <botlish_fn_16: check<int, int, str, str>>:
    1648:	push   rbp
    1649:	mov    rbp,rsp
    164c:	sub    rsp,0x60
    1650:	mov    QWORD PTR [rsp+0x30],rbx
    1655:	mov    QWORD PTR [rsp+0x38],r12
    165a:	mov    QWORD PTR [rsp+0x40],r13
    165f:	mov    QWORD PTR [rsp+0x48],r14
    1664:	mov    QWORD PTR [rsp+0x50],r15
    1669:	mov    QWORD PTR [rsp+0x20],0x0
    1672:	mov    QWORD PTR [rsp],rsi
    1676:	mov    QWORD PTR [rsp+0x8],rdx
    167b:	mov    QWORD PTR [rsp+0x10],rcx
    1680:	mov    r12,rcx
    1683:	mov    QWORD PTR [rsp+0x18],r8
    1688:	mov    r14,r8
    168b:	mov    r13,rsi
    168e:	mov    r15,rdx
    1691:	test   r13,0x1
    1698:	jne    16c3 <botlish_fn_16+0x7b>
    169e:	mov    edx,0x1
    16a3:	mov    rbx,rdi
    16a6:	mov    rsi,r13
    16a9:	call   16ae <botlish_fn_16+0x66>
			16aa: R_X86_64_PLT32	rt_int_cmp-0x4
    16ae:	mov    ecx,0x2
    16b3:	test   rax,rax
    16b6:	cmovle rcx,QWORD PTR [rip+0x152]        # 1810 <botlish_fn_16+0x1c8>
    16be:	jmp    16d7 <botlish_fn_16+0x8f>
    16c3:	mov    rbx,rdi
    16c6:	mov    ecx,0x2
    16cb:	cmp    r13,0x1
    16cf:	cmovle rcx,QWORD PTR [rip+0x139]        # 1810 <botlish_fn_16+0x1c8>
    16d7:	cmp    rcx,0x6
    16db:	je     17e4 <botlish_fn_16+0x19c>
    16e1:	mov    rax,QWORD PTR [rbx+0x10]
    16e5:	mov    rax,QWORD PTR [rax+0xf0]
    16ec:	mov    rsi,r12
    16ef:	mov    rdi,rbx
    16f2:	call   16f7 <botlish_fn_16+0xaf>
			16f3: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    16f7:	test   rax,rax
    16fa:	je     173b <botlish_fn_16+0xf3>
    1700:	cmp    rax,0x6
    1704:	je     171c <botlish_fn_16+0xd4>
    170a:	mov    edx,0x1
    170f:	mov    QWORD PTR [rsp],0x1
    1717:	jmp    177d <botlish_fn_16+0x135>
    171c:	mov    rax,QWORD PTR [rbx+0x10]
    1720:	mov    rax,QWORD PTR [rax+0xf8]
    1727:	mov    rsi,r12
    172a:	mov    rdi,rbx
    172d:	call   1732 <botlish_fn_16+0xea>
			172e: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    1732:	test   rax,rax
    1735:	jne    1760 <botlish_fn_16+0x118>
    173b:	xor    rax,rax
    173e:	mov    rbx,QWORD PTR [rsp+0x30]
    1743:	mov    r12,QWORD PTR [rsp+0x38]
    1748:	mov    r13,QWORD PTR [rsp+0x40]
    174d:	mov    r14,QWORD PTR [rsp+0x48]
    1752:	mov    r15,QWORD PTR [rsp+0x50]
    1757:	add    rsp,0x60
    175b:	mov    rsp,rbp
    175e:	pop    rbp
    175f:	ret
    1760:	cmp    rax,0x6
    1764:	je     1774 <botlish_fn_16+0x12c>
    176a:	mov    edx,0x1
    176f:	jmp    1779 <botlish_fn_16+0x131>
    1774:	mov    edx,0x3
    1779:	mov    QWORD PTR [rsp],rdx
    177d:	sar    r13,1
    1780:	sub    r13,0x1
    1784:	shl    r13,1
    1787:	or     r13,0x1
    178b:	mov    QWORD PTR [rsp+0x20],r13
    1790:	mov    rsi,r15
    1793:	mov    r8,rsi
    1796:	and    r8,rdx
    1799:	test   r8,0x1
    17a0:	je     17bb <botlish_fn_16+0x173>
    17a6:	lea    r11,[rdx-0x1]
    17aa:	mov    rax,rsi
    17ad:	add    rax,r11
    17b0:	seto   cl
    17b3:	test   cl,cl
    17b5:	je     17c3 <botlish_fn_16+0x17b>
    17bb:	mov    rdi,rbx
    17be:	call   17c3 <botlish_fn_16+0x17b>
			17bf: R_X86_64_PLT32	rt_int_add-0x4
    17c3:	mov    QWORD PTR [rsp],r13
    17c7:	mov    QWORD PTR [rsp+0x8],rax
    17cc:	mov    QWORD PTR [rsp+0x10],r12
    17d1:	mov    r8,r14
    17d4:	mov    QWORD PTR [rsp+0x18],r8
    17d9:	mov    rdi,rbx
    17dc:	mov    r15,rax
    17df:	jmp    1691 <botlish_fn_16+0x49>
    17e4:	mov    rax,r15
    17e7:	mov    rbx,QWORD PTR [rsp+0x30]
    17ec:	mov    r12,QWORD PTR [rsp+0x38]
    17f1:	mov    r13,QWORD PTR [rsp+0x40]
    17f6:	mov    r14,QWORD PTR [rsp+0x48]
    17fb:	mov    r15,QWORD PTR [rsp+0x50]
    1800:	add    rsp,0x60
    1804:	mov    rsp,rbp
    1807:	pop    rbp
    1808:	ret
    1809:	add    BYTE PTR [rax],al
    180b:	add    BYTE PTR [rax],al
    180d:	add    BYTE PTR [rax],al
    180f:	add    BYTE PTR [rsi],al
    1811:	add    BYTE PTR [rax],al
    1813:	add    BYTE PTR [rax],al
    1815:	add    BYTE PTR [rax],al
	...

0000000000001818 <botlish_entry_16: check<int, int, str, str>>:
    1818:	push   rbp
    1819:	mov    rbp,rsp
    181c:	mov    rsi,QWORD PTR [rdx]
    181f:	mov    r9,QWORD PTR [rdx+0x8]
    1823:	mov    rcx,QWORD PTR [rdx+0x10]
    1827:	mov    r8,QWORD PTR [rdx+0x18]
    182b:	mov    rdx,r9
    182e:	call   1833 <botlish_entry_16+0x1b>
			182f: R_X86_64_PLT32	botlish_fn_16-0x4 ; check<int, int, str, str>
    1833:	mov    rsp,rbp
    1836:	pop    rbp
    1837:	ret

0000000000001838 <botlish_fn_17: <str>>:
    1838:	push   rbp
    1839:	mov    rbp,rsp
    183c:	sub    rsp,0x50
    1840:	mov    QWORD PTR [rsp+0x30],rbx
    1845:	mov    QWORD PTR [rsp+0x38],r12
    184a:	mov    QWORD PTR [rsp+0x40],r13
    184f:	mov    QWORD PTR [rsp+0x48],r14
    1854:	mov    r13,rdi
    1857:	mov    QWORD PTR [rsp+0x18],0x0
    1860:	mov    QWORD PTR [rsp],rsi
    1864:	mov    r14,rsi
    1867:	mov    rsi,r14
    186a:	mov    rdi,r13
    186d:	call   1872 <botlish_fn_17+0x3a>
			186e: R_X86_64_PLT32	rt_str_len-0x4
    1872:	mov    rbx,rax
    1875:	mov    QWORD PTR [rsp+0x8],rax
    187a:	mov    esi,0x1
    187f:	mov    QWORD PTR [rsp+0x10],0x1
    1888:	mov    rcx,r14
    188b:	mov    rdx,rbx
    188e:	mov    rdi,r13
    1891:	call   1896 <botlish_fn_17+0x5e>
			1892: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    1896:	mov    r12,rax
    1899:	test   r12,r12
    189c:	je     19f9 <botlish_fn_17+0x1c1>
    18a2:	mov    QWORD PTR [rsp+0x10],r12
    18a7:	test   r12,0x1
    18ae:	jne    18d9 <botlish_fn_17+0xa1>
    18b4:	mov    edx,0x1
    18b9:	mov    rsi,r12
    18bc:	mov    rdi,r13
    18bf:	call   18c4 <botlish_fn_17+0x8c>
			18c0: R_X86_64_PLT32	rt_int_cmp-0x4
    18c4:	mov    ecx,0x2
    18c9:	test   rax,rax
    18cc:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 1a98 <botlish_fn_17+0x260>
    18d4:	jmp    18ea <botlish_fn_17+0xb2>
    18d9:	mov    ecx,0x2
    18de:	cmp    r12,0x1
    18e2:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 1a98 <botlish_fn_17+0x260>
    18ea:	cmp    rcx,0x6
    18ee:	je     1a74 <botlish_fn_17+0x23c>
    18f4:	mov    rcx,r12
    18f7:	and    rcx,rbx
    18fa:	test   rcx,0x1
    1901:	jne    192a <botlish_fn_17+0xf2>
    1907:	mov    rdx,rbx
    190a:	mov    rsi,r12
    190d:	mov    rdi,r13
    1910:	call   1915 <botlish_fn_17+0xdd>
			1911: R_X86_64_PLT32	rt_int_cmp-0x4
    1915:	mov    ecx,0x2
    191a:	test   rax,rax
    191d:	cmovge rcx,QWORD PTR [rip+0x173]        # 1a98 <botlish_fn_17+0x260>
    1925:	jmp    193a <botlish_fn_17+0x102>
    192a:	mov    ecx,0x2
    192f:	cmp    r12,rbx
    1932:	cmovge rcx,QWORD PTR [rip+0x15e]        # 1a98 <botlish_fn_17+0x260>
    193a:	cmp    rcx,0x6
    193e:	je     1a6a <botlish_fn_17+0x232>
    1944:	lea    rcx,[rsp+0x20]
    1949:	mov    rdx,r14
    194c:	mov    rsi,r12
    194f:	mov    rdi,r13
    1952:	call   1957 <botlish_fn_17+0x11f>
			1953: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    1957:	test   rax,rax
    195a:	mov    rsi,rax
    195d:	je     19f9 <botlish_fn_17+0x1c1>
    1963:	mov    rdx,QWORD PTR [rsp+0x20]
    1968:	mov    rcx,QWORD PTR [rsp+0x28]
    196d:	mov    rdi,r13
    1970:	mov    rax,QWORD PTR [rdi+0x10]
    1974:	mov    r8,QWORD PTR [rax+0x110]
    197b:	call   1980 <botlish_fn_17+0x148>
			197c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1980:	cmp    rax,0x6
    1984:	je     1997 <botlish_fn_17+0x15f>
    198a:	mov    ecx,0x2
    198f:	mov    rax,rcx
    1992:	jmp    1a79 <botlish_fn_17+0x241>
    1997:	mov    QWORD PTR [rsp+0x18],0x3
    19a0:	test   r12,0x1
    19a7:	jne    19b5 <botlish_fn_17+0x17d>
    19ad:	mov    rcx,r12
    19b0:	jmp    19ca <botlish_fn_17+0x192>
    19b5:	mov    rsi,r12
    19b8:	add    rsi,0x2
    19bc:	mov    rcx,r12
    19bf:	seto   al
    19c2:	test   al,al
    19c4:	je     19dd <botlish_fn_17+0x1a5>
    19ca:	mov    edx,0x3
    19cf:	mov    rsi,rcx
    19d2:	mov    rdi,r13
    19d5:	call   19da <botlish_fn_17+0x1a2>
			19d6: R_X86_64_PLT32	rt_int_add-0x4
    19da:	mov    rsi,rax
    19dd:	mov    QWORD PTR [rsp+0x10],rsi
    19e2:	mov    rcx,r14
    19e5:	mov    rdx,rbx
    19e8:	mov    rdi,r13
    19eb:	call   19f0 <botlish_fn_17+0x1b8>
			19ec: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    19f0:	test   rax,rax
    19f3:	jne    1a19 <botlish_fn_17+0x1e1>
    19f9:	xor    rax,rax
    19fc:	mov    rbx,QWORD PTR [rsp+0x30]
    1a01:	mov    r12,QWORD PTR [rsp+0x38]
    1a06:	mov    r13,QWORD PTR [rsp+0x40]
    1a0b:	mov    r14,QWORD PTR [rsp+0x48]
    1a10:	add    rsp,0x50
    1a14:	mov    rsp,rbp
    1a17:	pop    rbp
    1a18:	ret
    1a19:	mov    rcx,rax
    1a1c:	and    rcx,rbx
    1a1f:	mov    rsi,rax
    1a22:	test   rcx,0x1
    1a29:	jne    1a52 <botlish_fn_17+0x21a>
    1a2f:	mov    rdx,rbx
    1a32:	mov    rdi,r13
    1a35:	call   1a3a <botlish_fn_17+0x202>
			1a36: R_X86_64_PLT32	rt_int_cmp-0x4
    1a3a:	mov    ecx,0x2
    1a3f:	test   rax,rax
    1a42:	mov    rax,rcx
    1a45:	cmove  rax,QWORD PTR [rip+0x4b]        # 1a98 <botlish_fn_17+0x260>
    1a4d:	jmp    1a79 <botlish_fn_17+0x241>
    1a52:	mov    rdx,rbx
    1a55:	mov    eax,0x2
    1a5a:	cmp    rsi,rdx
    1a5d:	cmove  rax,QWORD PTR [rip+0x33]        # 1a98 <botlish_fn_17+0x260>
    1a65:	jmp    1a79 <botlish_fn_17+0x241>
    1a6a:	mov    eax,0x2
    1a6f:	jmp    1a79 <botlish_fn_17+0x241>
    1a74:	mov    eax,0x2
    1a79:	mov    rbx,QWORD PTR [rsp+0x30]
    1a7e:	mov    r12,QWORD PTR [rsp+0x38]
    1a83:	mov    r13,QWORD PTR [rsp+0x40]
    1a88:	mov    r14,QWORD PTR [rsp+0x48]
    1a8d:	add    rsp,0x50
    1a91:	mov    rsp,rbp
    1a94:	pop    rbp
    1a95:	ret
    1a96:	add    BYTE PTR [rax],al
    1a98:	(bad)
    1a99:	add    BYTE PTR [rax],al
    1a9b:	add    BYTE PTR [rax],al
    1a9d:	add    BYTE PTR [rax],al
	...

0000000000001aa0 <botlish_entry_17: <str>>:
    1aa0:	push   rbp
    1aa1:	mov    rbp,rsp
    1aa4:	mov    rsi,QWORD PTR [rdx]
    1aa7:	call   1aac <botlish_entry_17+0xc>
			1aa8: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    1aac:	mov    rsp,rbp
    1aaf:	pop    rbp
    1ab0:	ret
    1ab1:	add    BYTE PTR [rax],al
    1ab3:	add    BYTE PTR [rax],al
    1ab5:	add    BYTE PTR [rax],al
	...

0000000000001ab8 <botlish_fn_18: <generic>>:
    1ab8:	push   rbp
    1ab9:	mov    rbp,rsp
    1abc:	sub    rsp,0x60
    1ac0:	mov    QWORD PTR [rsp+0x30],rbx
    1ac5:	mov    QWORD PTR [rsp+0x38],r12
    1aca:	mov    QWORD PTR [rsp+0x40],r13
    1acf:	mov    QWORD PTR [rsp+0x48],r14
    1ad4:	mov    QWORD PTR [rsp+0x50],r15
    1ad9:	mov    QWORD PTR [rsp+0x18],0x0
    1ae2:	mov    QWORD PTR [rsp],rsi
    1ae6:	xor    r8d,r8d
    1ae9:	test   rsi,0x7
    1af0:	jne    1b00 <botlish_fn_18+0x48>
    1af6:	movzx  rax,BYTE PTR [rsi]
    1afa:	cmp    al,0x2
    1afc:	sete   r8b
    1b00:	test   r8b,r8b
    1b03:	jne    1b23 <botlish_fn_18+0x6b>
    1b09:	mov    rdx,QWORD PTR [rdi+0x10]
    1b0d:	mov    rcx,QWORD PTR [rdx+0xe8]
    1b14:	mov    edx,0x1
    1b19:	call   1b1e <botlish_fn_18+0x66>
			1b1a: R_X86_64_PLT32	rt_type_error-0x4
    1b1e:	jmp    1cb8 <botlish_fn_18+0x200>
    1b23:	mov    r13,rsi
    1b26:	mov    r14,rdi
    1b29:	call   1b2e <botlish_fn_18+0x76>
			1b2a: R_X86_64_PLT32	rt_str_len-0x4
    1b2e:	mov    rbx,rax
    1b31:	mov    QWORD PTR [rsp+0x8],rax
    1b36:	mov    edx,0x1
    1b3b:	mov    r15,rdx
    1b3e:	mov    QWORD PTR [rsp+0x10],0x1
    1b47:	mov    rcx,r13
    1b4a:	mov    rdx,rbx
    1b4d:	mov    rsi,r15
    1b50:	mov    rdi,r14
    1b53:	call   1b58 <botlish_fn_18+0xa0>
			1b54: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    1b58:	mov    r12,rax
    1b5b:	test   r12,r12
    1b5e:	je     1cb8 <botlish_fn_18+0x200>
    1b64:	mov    QWORD PTR [rsp+0x10],r12
    1b69:	test   r12,0x1
    1b70:	jne    1b99 <botlish_fn_18+0xe1>
    1b76:	mov    rdx,r15
    1b79:	mov    rsi,r12
    1b7c:	mov    rdi,r14
    1b7f:	call   1b84 <botlish_fn_18+0xcc>
			1b80: R_X86_64_PLT32	rt_int_cmp-0x4
    1b84:	mov    ecx,0x2
    1b89:	test   rax,rax
    1b8c:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 1d60 <botlish_fn_18+0x2a8>
    1b94:	jmp    1baa <botlish_fn_18+0xf2>
    1b99:	mov    ecx,0x2
    1b9e:	cmp    r12,0x1
    1ba2:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 1d60 <botlish_fn_18+0x2a8>
    1baa:	cmp    rcx,0x6
    1bae:	je     1d38 <botlish_fn_18+0x280>
    1bb4:	mov    rax,r12
    1bb7:	and    rax,rbx
    1bba:	test   rax,0x1
    1bc0:	jne    1be9 <botlish_fn_18+0x131>
    1bc6:	mov    rdx,rbx
    1bc9:	mov    rsi,r12
    1bcc:	mov    rdi,r14
    1bcf:	call   1bd4 <botlish_fn_18+0x11c>
			1bd0: R_X86_64_PLT32	rt_int_cmp-0x4
    1bd4:	mov    ecx,0x2
    1bd9:	test   rax,rax
    1bdc:	cmovge rcx,QWORD PTR [rip+0x17c]        # 1d60 <botlish_fn_18+0x2a8>
    1be4:	jmp    1bf9 <botlish_fn_18+0x141>
    1be9:	mov    ecx,0x2
    1bee:	cmp    r12,rbx
    1bf1:	cmovge rcx,QWORD PTR [rip+0x167]        # 1d60 <botlish_fn_18+0x2a8>
    1bf9:	cmp    rcx,0x6
    1bfd:	je     1d2e <botlish_fn_18+0x276>
    1c03:	lea    rcx,[rsp+0x20]
    1c08:	mov    rdx,r13
    1c0b:	mov    rsi,r12
    1c0e:	mov    rdi,r14
    1c11:	call   1c16 <botlish_fn_18+0x15e>
			1c12: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    1c16:	test   rax,rax
    1c19:	mov    rsi,rax
    1c1c:	je     1cb8 <botlish_fn_18+0x200>
    1c22:	mov    rdx,QWORD PTR [rsp+0x20]
    1c27:	mov    rcx,QWORD PTR [rsp+0x28]
    1c2c:	mov    rdi,r14
    1c2f:	mov    rax,QWORD PTR [rdi+0x10]
    1c33:	mov    r8,QWORD PTR [rax+0x110]
    1c3a:	call   1c3f <botlish_fn_18+0x187>
			1c3b: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c3f:	cmp    rax,0x6
    1c43:	je     1c56 <botlish_fn_18+0x19e>
    1c49:	mov    ecx,0x2
    1c4e:	mov    rax,rcx
    1c51:	jmp    1d3d <botlish_fn_18+0x285>
    1c56:	mov    QWORD PTR [rsp+0x18],0x3
    1c5f:	test   r12,0x1
    1c66:	jne    1c74 <botlish_fn_18+0x1bc>
    1c6c:	mov    rdi,r12
    1c6f:	jmp    1c89 <botlish_fn_18+0x1d1>
    1c74:	mov    rsi,r12
    1c77:	add    rsi,0x2
    1c7b:	mov    rdi,r12
    1c7e:	seto   al
    1c81:	test   al,al
    1c83:	je     1c9c <botlish_fn_18+0x1e4>
    1c89:	mov    edx,0x3
    1c8e:	mov    rsi,rdi
    1c91:	mov    rdi,r14
    1c94:	call   1c99 <botlish_fn_18+0x1e1>
			1c95: R_X86_64_PLT32	rt_int_add-0x4
    1c99:	mov    rsi,rax
    1c9c:	mov    QWORD PTR [rsp+0x10],rsi
    1ca1:	mov    rcx,r13
    1ca4:	mov    rdx,rbx
    1ca7:	mov    rdi,r14
    1caa:	call   1caf <botlish_fn_18+0x1f7>
			1cab: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    1caf:	test   rax,rax
    1cb2:	jne    1cdd <botlish_fn_18+0x225>
    1cb8:	xor    rax,rax
    1cbb:	mov    rbx,QWORD PTR [rsp+0x30]
    1cc0:	mov    r12,QWORD PTR [rsp+0x38]
    1cc5:	mov    r13,QWORD PTR [rsp+0x40]
    1cca:	mov    r14,QWORD PTR [rsp+0x48]
    1ccf:	mov    r15,QWORD PTR [rsp+0x50]
    1cd4:	add    rsp,0x60
    1cd8:	mov    rsp,rbp
    1cdb:	pop    rbp
    1cdc:	ret
    1cdd:	mov    rcx,rax
    1ce0:	and    rcx,rbx
    1ce3:	mov    rsi,rax
    1ce6:	test   rcx,0x1
    1ced:	jne    1d16 <botlish_fn_18+0x25e>
    1cf3:	mov    rdx,rbx
    1cf6:	mov    rdi,r14
    1cf9:	call   1cfe <botlish_fn_18+0x246>
			1cfa: R_X86_64_PLT32	rt_int_cmp-0x4
    1cfe:	mov    ecx,0x2
    1d03:	test   rax,rax
    1d06:	mov    rax,rcx
    1d09:	cmove  rax,QWORD PTR [rip+0x4f]        # 1d60 <botlish_fn_18+0x2a8>
    1d11:	jmp    1d3d <botlish_fn_18+0x285>
    1d16:	mov    rdx,rbx
    1d19:	mov    eax,0x2
    1d1e:	cmp    rsi,rdx
    1d21:	cmove  rax,QWORD PTR [rip+0x37]        # 1d60 <botlish_fn_18+0x2a8>
    1d29:	jmp    1d3d <botlish_fn_18+0x285>
    1d2e:	mov    eax,0x2
    1d33:	jmp    1d3d <botlish_fn_18+0x285>
    1d38:	mov    eax,0x2
    1d3d:	mov    rbx,QWORD PTR [rsp+0x30]
    1d42:	mov    r12,QWORD PTR [rsp+0x38]
    1d47:	mov    r13,QWORD PTR [rsp+0x40]
    1d4c:	mov    r14,QWORD PTR [rsp+0x48]
    1d51:	mov    r15,QWORD PTR [rsp+0x50]
    1d56:	add    rsp,0x60
    1d5a:	mov    rsp,rbp
    1d5d:	pop    rbp
    1d5e:	ret
    1d5f:	add    BYTE PTR [rsi],al
    1d61:	add    BYTE PTR [rax],al
    1d63:	add    BYTE PTR [rax],al
    1d65:	add    BYTE PTR [rax],al
	...

0000000000001d68 <botlish_entry_18: <generic>>:
    1d68:	push   rbp
    1d69:	mov    rbp,rsp
    1d6c:	mov    rsi,QWORD PTR [rdx]
    1d6f:	call   1d74 <botlish_entry_18+0xc>
			1d70: R_X86_64_PLT32	botlish_fn_18-0x4 ; <generic>
    1d74:	mov    rsp,rbp
    1d77:	pop    rbp
    1d78:	ret

0000000000001d79 <botlish_fn_19: char_at<generic>>:
    1d79:	push   rbp
    1d7a:	mov    rbp,rsp
    1d7d:	sub    rsp,0x50
    1d81:	mov    QWORD PTR [rsp+0x20],rbx
    1d86:	mov    QWORD PTR [rsp+0x28],r12
    1d8b:	mov    QWORD PTR [rsp+0x30],r13
    1d90:	mov    QWORD PTR [rsp+0x38],r14
    1d95:	mov    QWORD PTR [rsp+0x40],r15
    1d9a:	mov    r14,rcx
    1d9d:	mov    QWORD PTR [rsp],rsi
    1da1:	mov    QWORD PTR [rsp+0x8],rdx
    1da6:	mov    r13,rdx
    1da9:	mov    QWORD PTR [rsp+0x10],0x3
    1db2:	mov    r9d,0x1
    1db8:	test   rsi,0x1
    1dbf:	jne    1ddf <botlish_fn_19+0x66>
    1dc5:	xor    r9d,r9d
    1dc8:	test   rsi,0x7
    1dcf:	jne    1ddf <botlish_fn_19+0x66>
    1dd5:	movzx  rax,BYTE PTR [rsi]
    1dd9:	cmp    al,0x1
    1ddb:	sete   r9b
    1ddf:	test   r9b,r9b
    1de2:	jne    1e00 <botlish_fn_19+0x87>
    1de8:	mov    rax,QWORD PTR [rdi+0x10]
    1dec:	mov    rcx,QWORD PTR [rax+0x118]
    1df3:	xor    rdx,rdx
    1df6:	call   1dfb <botlish_fn_19+0x82>
			1df7: R_X86_64_PLT32	rt_type_error-0x4
    1dfb:	jmp    1ebd <botlish_fn_19+0x144>
    1e00:	mov    r12,rdi
    1e03:	test   rsi,0x1
    1e0a:	jne    1e18 <botlish_fn_19+0x9f>
    1e10:	mov    rbx,rsi
    1e13:	jmp    1e35 <botlish_fn_19+0xbc>
    1e18:	mov    rax,rsi
    1e1b:	add    rax,0x2
    1e1f:	mov    rbx,rsi
    1e22:	seto   cl
    1e25:	test   cl,cl
    1e27:	jne    1e35 <botlish_fn_19+0xbc>
    1e2d:	mov    r15,rax
    1e30:	jmp    1e48 <botlish_fn_19+0xcf>
    1e35:	mov    edx,0x3
    1e3a:	mov    rsi,rbx
    1e3d:	mov    rdi,r12
    1e40:	call   1e45 <botlish_fn_19+0xcc>
			1e41: R_X86_64_PLT32	rt_int_add-0x4
    1e45:	mov    r15,rax
    1e48:	mov    ecx,0x1
    1e4d:	mov    rsi,rbx
    1e50:	test   rsi,0x1
    1e57:	jne    1e7d <botlish_fn_19+0x104>
    1e5d:	xor    ecx,ecx
    1e5f:	mov    rsi,rbx
    1e62:	test   rsi,0x7
    1e69:	jne    1e7d <botlish_fn_19+0x104>
    1e6f:	mov    rsi,rbx
    1e72:	movzx  rcx,BYTE PTR [rsi]
    1e76:	rex cmp cl,0x1
    1e7a:	sete   cl
    1e7d:	test   cl,cl
    1e7f:	jne    1ea3 <botlish_fn_19+0x12a>
    1e85:	mov    rdi,r12
    1e88:	mov    rsi,QWORD PTR [rdi+0x10]
    1e8c:	mov    rcx,QWORD PTR [rsi+0x120]
    1e93:	xor    rdx,rdx
    1e96:	mov    rsi,rbx
    1e99:	call   1e9e <botlish_fn_19+0x125>
			1e9a: R_X86_64_PLT32	rt_type_error-0x4
    1e9e:	jmp    1ebd <botlish_fn_19+0x144>
    1ea3:	mov    rdi,r12
    1ea6:	mov    rcx,r15
    1ea9:	mov    rdx,rbx
    1eac:	mov    rsi,r13
    1eaf:	call   1eb4 <botlish_fn_19+0x13b>
			1eb0: R_X86_64_PLT32	rt_str_region_check-0x4
    1eb4:	test   rax,rax
    1eb7:	jne    1ee2 <botlish_fn_19+0x169>
    1ebd:	xor    rax,rax
    1ec0:	mov    rbx,QWORD PTR [rsp+0x20]
    1ec5:	mov    r12,QWORD PTR [rsp+0x28]
    1eca:	mov    r13,QWORD PTR [rsp+0x30]
    1ecf:	mov    r14,QWORD PTR [rsp+0x38]
    1ed4:	mov    r15,QWORD PTR [rsp+0x40]
    1ed9:	add    rsp,0x50
    1edd:	mov    rsp,rbp
    1ee0:	pop    rbp
    1ee1:	ret
    1ee2:	mov    rcx,r14
    1ee5:	mov    rsi,rbx
    1ee8:	mov    QWORD PTR [rcx],rsi
    1eeb:	mov    rax,r15
    1eee:	mov    QWORD PTR [rcx+0x8],rax
    1ef2:	mov    rax,r13
    1ef5:	mov    rbx,QWORD PTR [rsp+0x20]
    1efa:	mov    r12,QWORD PTR [rsp+0x28]
    1eff:	mov    r13,QWORD PTR [rsp+0x30]
    1f04:	mov    r14,QWORD PTR [rsp+0x38]
    1f09:	mov    r15,QWORD PTR [rsp+0x40]
    1f0e:	add    rsp,0x50
    1f12:	mov    rsp,rbp
    1f15:	pop    rbp
    1f16:	ret

0000000000001f17 <botlish_entry_19: char_at<generic>>:
    1f17:	push   rbp
    1f18:	mov    rbp,rsp
    1f1b:	ud2
    1f1d:	add    BYTE PTR [rax],al
	...

0000000000001f20 <botlish_fn_20: scan_local<generic>>:
    1f20:	push   rbp
    1f21:	mov    rbp,rsp
    1f24:	sub    rsp,0x80
    1f2b:	mov    QWORD PTR [rsp+0x50],rbx
    1f30:	mov    QWORD PTR [rsp+0x58],r12
    1f35:	mov    QWORD PTR [rsp+0x60],r13
    1f3a:	mov    QWORD PTR [rsp+0x68],r14
    1f3f:	mov    QWORD PTR [rsp+0x70],r15
    1f44:	mov    rax,rdi
    1f47:	mov    QWORD PTR [rsp+0x18],0x0
    1f50:	mov    QWORD PTR [rsp],rsi
    1f54:	mov    r14,rsi
    1f57:	mov    QWORD PTR [rsp+0x8],rdx
    1f5c:	mov    QWORD PTR [rsp+0x10],rcx
    1f61:	mov    r12,rcx
    1f64:	mov    r11d,0x1
    1f6a:	mov    rsi,r14
    1f6d:	test   rsi,0x1
    1f74:	jne    1f96 <botlish_fn_20+0x76>
    1f7a:	xor    r11d,r11d
    1f7d:	test   rsi,0x7
    1f84:	jne    1f96 <botlish_fn_20+0x76>
    1f8a:	movzx  rdi,BYTE PTR [rsi]
    1f8e:	cmp    dil,0x1
    1f92:	sete   r11b
    1f96:	test   r11b,r11b
    1f99:	jne    1fba <botlish_fn_20+0x9a>
    1f9f:	mov    rdi,rax
    1fa2:	mov    r9,QWORD PTR [rdi+0x10]
    1fa6:	mov    rcx,QWORD PTR [r9+0xc8]
    1fad:	xor    rdx,rdx
    1fb0:	call   1fb5 <botlish_fn_20+0x95>
			1fb1: R_X86_64_PLT32	rt_type_error-0x4
    1fb5:	jmp    206d <botlish_fn_20+0x14d>
    1fba:	mov    r13,rdx
    1fbd:	mov    r10,rsi
    1fc0:	and    r10,r13
    1fc3:	mov    r14,rsi
    1fc6:	test   r10,0x1
    1fcd:	jne    1ff9 <botlish_fn_20+0xd9>
    1fd3:	mov    rbx,rax
    1fd6:	mov    rdx,r13
    1fd9:	mov    rsi,r14
    1fdc:	mov    rdi,rbx
    1fdf:	call   1fe4 <botlish_fn_20+0xc4>
			1fe0: R_X86_64_PLT32	rt_int_cmp-0x4
    1fe4:	mov    ecx,0x2
    1fe9:	test   rax,rax
    1fec:	cmovge rcx,QWORD PTR [rip+0x24c]        # 2240 <botlish_fn_20+0x320>
    1ff4:	jmp    200f <botlish_fn_20+0xef>
    1ff9:	mov    rbx,rax
    1ffc:	mov    ecx,0x2
    2001:	mov    rsi,r14
    2004:	cmp    rsi,r13
    2007:	cmovge rcx,QWORD PTR [rip+0x231]        # 2240 <botlish_fn_20+0x320>
    200f:	mov    eax,0x6
    2014:	mov    QWORD PTR [rsp+0x30],rax
    2019:	cmp    rcx,0x6
    201d:	je     2213 <botlish_fn_20+0x2f3>
    2023:	lea    rcx,[rsp+0x20]
    2028:	mov    rdx,r12
    202b:	mov    rsi,r14
    202e:	mov    rdi,rbx
    2031:	call   2036 <botlish_fn_20+0x116>
			2032: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    2036:	mov    rsi,rax
    2039:	mov    r15,rax
    203c:	test   rax,rsi
    203f:	je     206d <botlish_fn_20+0x14d>
    2045:	mov    rdx,QWORD PTR [rsp+0x20]
    204a:	mov    QWORD PTR [rsp+0x40],rdx
    204f:	mov    rcx,QWORD PTR [rsp+0x28]
    2054:	mov    QWORD PTR [rsp+0x38],rcx
    2059:	mov    rsi,r15
    205c:	mov    rdi,rbx
    205f:	call   2064 <botlish_fn_20+0x144>
			2060: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    2064:	test   rax,rax
    2067:	jne    2095 <botlish_fn_20+0x175>
    206d:	xor    rax,rax
    2070:	mov    rbx,QWORD PTR [rsp+0x50]
    2075:	mov    r12,QWORD PTR [rsp+0x58]
    207a:	mov    r13,QWORD PTR [rsp+0x60]
    207f:	mov    r14,QWORD PTR [rsp+0x68]
    2084:	mov    r15,QWORD PTR [rsp+0x70]
    2089:	add    rsp,0x80
    2090:	mov    rsp,rbp
    2093:	pop    rbp
    2094:	ret
    2095:	cmp    rax,0x6
    2099:	je     2194 <botlish_fn_20+0x274>
    209f:	mov    rax,QWORD PTR [rbx+0x10]
    20a3:	mov    r8,QWORD PTR [rax+0x128]
    20aa:	mov    rcx,QWORD PTR [rsp+0x38]
    20af:	mov    rdx,QWORD PTR [rsp+0x40]
    20b4:	mov    rsi,r15
    20b7:	mov    rdi,rbx
    20ba:	call   20bf <botlish_fn_20+0x19f>
			20bb: R_X86_64_PLT32	rt_str_region_eq-0x4
    20bf:	cmp    rax,0x6
    20c3:	je     218a <botlish_fn_20+0x26a>
    20c9:	mov    rax,QWORD PTR [rbx+0x10]
    20cd:	mov    r8,QWORD PTR [rax+0x130]
    20d4:	mov    rcx,QWORD PTR [rsp+0x38]
    20d9:	mov    rdx,QWORD PTR [rsp+0x40]
    20de:	mov    rsi,r15
    20e1:	mov    rdi,rbx
    20e4:	call   20e9 <botlish_fn_20+0x1c9>
			20e5: R_X86_64_PLT32	rt_str_region_eq-0x4
    20e9:	cmp    rax,0x6
    20ed:	je     2180 <botlish_fn_20+0x260>
    20f3:	mov    rax,QWORD PTR [rbx+0x10]
    20f7:	mov    r8,QWORD PTR [rax+0xd0]
    20fe:	mov    rcx,QWORD PTR [rsp+0x38]
    2103:	mov    rdx,QWORD PTR [rsp+0x40]
    2108:	mov    rsi,r15
    210b:	mov    rdi,rbx
    210e:	call   2113 <botlish_fn_20+0x1f3>
			210f: R_X86_64_PLT32	rt_str_region_eq-0x4
    2113:	cmp    rax,0x6
    2117:	je     2176 <botlish_fn_20+0x256>
    211d:	mov    rax,QWORD PTR [rbx+0x10]
    2121:	mov    r8,QWORD PTR [rax+0x118]
    2128:	mov    rcx,QWORD PTR [rsp+0x38]
    212d:	mov    rdx,QWORD PTR [rsp+0x40]
    2132:	mov    rsi,r15
    2135:	mov    rdi,rbx
    2138:	call   213d <botlish_fn_20+0x21d>
			2139: R_X86_64_PLT32	rt_str_region_eq-0x4
    213d:	cmp    rax,0x6
    2141:	je     216c <botlish_fn_20+0x24c>
    2147:	mov    rax,QWORD PTR [rbx+0x10]
    214b:	mov    r8,QWORD PTR [rax+0x138]
    2152:	mov    rcx,QWORD PTR [rsp+0x38]
    2157:	mov    rdx,QWORD PTR [rsp+0x40]
    215c:	mov    rsi,r15
    215f:	mov    rdi,rbx
    2162:	call   2167 <botlish_fn_20+0x247>
			2163: R_X86_64_PLT32	rt_str_region_eq-0x4
    2167:	jmp    2199 <botlish_fn_20+0x279>
    216c:	mov    rax,QWORD PTR [rsp+0x30]
    2171:	jmp    2199 <botlish_fn_20+0x279>
    2176:	mov    rax,QWORD PTR [rsp+0x30]
    217b:	jmp    2199 <botlish_fn_20+0x279>
    2180:	mov    rax,QWORD PTR [rsp+0x30]
    2185:	jmp    2199 <botlish_fn_20+0x279>
    218a:	mov    rax,QWORD PTR [rsp+0x30]
    218f:	jmp    2199 <botlish_fn_20+0x279>
    2194:	mov    rax,QWORD PTR [rsp+0x30]
    2199:	cmp    rax,0x6
    219d:	je     21ab <botlish_fn_20+0x28b>
    21a3:	mov    rax,r14
    21a6:	jmp    2216 <botlish_fn_20+0x2f6>
    21ab:	mov    QWORD PTR [rsp+0x18],0x3
    21b4:	mov    rsi,r14
    21b7:	test   rsi,0x1
    21be:	je     21e4 <botlish_fn_20+0x2c4>
    21c4:	mov    rsi,r14
    21c7:	mov    rax,rsi
    21ca:	add    rax,0x2
    21ce:	seto   cl
    21d1:	test   cl,cl
    21d3:	jne    21e4 <botlish_fn_20+0x2c4>
    21d9:	mov    rsi,rax
    21dc:	mov    r14,rax
    21df:	jmp    21fa <botlish_fn_20+0x2da>
    21e4:	mov    edx,0x3
    21e9:	mov    rsi,r14
    21ec:	mov    rdi,rbx
    21ef:	call   21f4 <botlish_fn_20+0x2d4>
			21f0: R_X86_64_PLT32	rt_int_add-0x4
    21f4:	mov    rsi,rax
    21f7:	mov    r14,rax
    21fa:	mov    QWORD PTR [rsp],rsi
    21fe:	mov    QWORD PTR [rsp+0x8],r13
    2203:	mov    QWORD PTR [rsp+0x10],r12
    2208:	mov    rax,rbx
    220b:	mov    rdx,r13
    220e:	jmp    1f64 <botlish_fn_20+0x44>
    2213:	mov    rax,r14
    2216:	mov    rbx,QWORD PTR [rsp+0x50]
    221b:	mov    r12,QWORD PTR [rsp+0x58]
    2220:	mov    r13,QWORD PTR [rsp+0x60]
    2225:	mov    r14,QWORD PTR [rsp+0x68]
    222a:	mov    r15,QWORD PTR [rsp+0x70]
    222f:	add    rsp,0x80
    2236:	mov    rsp,rbp
    2239:	pop    rbp
    223a:	ret
    223b:	add    BYTE PTR [rax],al
    223d:	add    BYTE PTR [rax],al
    223f:	add    BYTE PTR [rsi],al
    2241:	add    BYTE PTR [rax],al
    2243:	add    BYTE PTR [rax],al
    2245:	add    BYTE PTR [rax],al
	...

0000000000002248 <botlish_entry_20: scan_local<generic>>:
    2248:	push   rbp
    2249:	mov    rbp,rsp
    224c:	mov    rsi,QWORD PTR [rdx]
    224f:	mov    r8,QWORD PTR [rdx+0x8]
    2253:	mov    rcx,QWORD PTR [rdx+0x10]
    2257:	mov    rdx,r8
    225a:	call   225f <botlish_entry_20+0x17>
			225b: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    225f:	mov    rsp,rbp
    2262:	pop    rbp
    2263:	ret
    2264:	add    BYTE PTR [rax],al
	...

0000000000002268 <botlish_fn_21: scan_label<generic>>:
    2268:	push   rbp
    2269:	mov    rbp,rsp
    226c:	sub    rsp,0x80
    2273:	mov    QWORD PTR [rsp+0x50],rbx
    2278:	mov    QWORD PTR [rsp+0x58],r12
    227d:	mov    QWORD PTR [rsp+0x60],r13
    2282:	mov    QWORD PTR [rsp+0x68],r14
    2287:	mov    QWORD PTR [rsp+0x70],r15
    228c:	mov    QWORD PTR [rsp+0x18],0x0
    2295:	mov    QWORD PTR [rsp],rsi
    2299:	mov    r14,rsi
    229c:	mov    QWORD PTR [rsp+0x8],rdx
    22a1:	mov    QWORD PTR [rsp+0x10],rcx
    22a6:	mov    r12,rcx
    22a9:	mov    r11d,0x1
    22af:	mov    rsi,r14
    22b2:	test   rsi,0x1
    22b9:	jne    22d9 <botlish_fn_21+0x71>
    22bf:	xor    r11d,r11d
    22c2:	test   rsi,0x7
    22c9:	jne    22d9 <botlish_fn_21+0x71>
    22cf:	movzx  rax,BYTE PTR [rsi]
    22d3:	cmp    al,0x1
    22d5:	sete   r11b
    22d9:	test   r11b,r11b
    22dc:	jne    22fa <botlish_fn_21+0x92>
    22e2:	mov    rax,QWORD PTR [rdi+0x10]
    22e6:	mov    rcx,QWORD PTR [rax+0xc8]
    22ed:	xor    rdx,rdx
    22f0:	call   22f5 <botlish_fn_21+0x8d>
			22f1: R_X86_64_PLT32	rt_type_error-0x4
    22f5:	jmp    23a6 <botlish_fn_21+0x13e>
    22fa:	mov    r13,rdx
    22fd:	mov    rax,rsi
    2300:	and    rax,r13
    2303:	mov    r14,rsi
    2306:	test   rax,0x1
    230c:	jne    2335 <botlish_fn_21+0xcd>
    2312:	mov    rbx,rdi
    2315:	mov    rdx,r13
    2318:	mov    rsi,r14
    231b:	call   2320 <botlish_fn_21+0xb8>
			231c: R_X86_64_PLT32	rt_int_cmp-0x4
    2320:	mov    ecx,0x2
    2325:	test   rax,rax
    2328:	cmovge rcx,QWORD PTR [rip+0x178]        # 24a8 <botlish_fn_21+0x240>
    2330:	jmp    234b <botlish_fn_21+0xe3>
    2335:	mov    rbx,rdi
    2338:	mov    ecx,0x2
    233d:	mov    rsi,r14
    2340:	cmp    rsi,r13
    2343:	cmovge rcx,QWORD PTR [rip+0x15d]        # 24a8 <botlish_fn_21+0x240>
    234b:	mov    eax,0x6
    2350:	mov    QWORD PTR [rsp+0x30],rax
    2355:	cmp    rcx,0x6
    2359:	je     247c <botlish_fn_21+0x214>
    235f:	lea    rcx,[rsp+0x20]
    2364:	mov    rdx,r12
    2367:	mov    rsi,r14
    236a:	mov    rdi,rbx
    236d:	call   2372 <botlish_fn_21+0x10a>
			236e: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    2372:	test   rax,rax
    2375:	mov    r15,rax
    2378:	je     23a6 <botlish_fn_21+0x13e>
    237e:	mov    rdx,QWORD PTR [rsp+0x20]
    2383:	mov    QWORD PTR [rsp+0x40],rdx
    2388:	mov    rcx,QWORD PTR [rsp+0x28]
    238d:	mov    QWORD PTR [rsp+0x38],rcx
    2392:	mov    rsi,r15
    2395:	mov    rdi,rbx
    2398:	call   239d <botlish_fn_21+0x135>
			2399: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    239d:	test   rax,rax
    23a0:	jne    23ce <botlish_fn_21+0x166>
    23a6:	xor    rax,rax
    23a9:	mov    rbx,QWORD PTR [rsp+0x50]
    23ae:	mov    r12,QWORD PTR [rsp+0x58]
    23b3:	mov    r13,QWORD PTR [rsp+0x60]
    23b8:	mov    r14,QWORD PTR [rsp+0x68]
    23bd:	mov    r15,QWORD PTR [rsp+0x70]
    23c2:	add    rsp,0x80
    23c9:	mov    rsp,rbp
    23cc:	pop    rbp
    23cd:	ret
    23ce:	cmp    rax,0x6
    23d2:	je     23fd <botlish_fn_21+0x195>
    23d8:	mov    r11,QWORD PTR [rbx+0x10]
    23dc:	mov    r8,QWORD PTR [r11+0x138]
    23e3:	mov    rcx,QWORD PTR [rsp+0x38]
    23e8:	mov    rdx,QWORD PTR [rsp+0x40]
    23ed:	mov    rsi,r15
    23f0:	mov    rdi,rbx
    23f3:	call   23f8 <botlish_fn_21+0x190>
			23f4: R_X86_64_PLT32	rt_str_region_eq-0x4
    23f8:	jmp    2402 <botlish_fn_21+0x19a>
    23fd:	mov    rax,QWORD PTR [rsp+0x30]
    2402:	cmp    rax,0x6
    2406:	je     2414 <botlish_fn_21+0x1ac>
    240c:	mov    rax,r14
    240f:	jmp    247f <botlish_fn_21+0x217>
    2414:	mov    QWORD PTR [rsp+0x18],0x3
    241d:	mov    rsi,r14
    2420:	test   rsi,0x1
    2427:	je     244d <botlish_fn_21+0x1e5>
    242d:	mov    rsi,r14
    2430:	mov    rax,rsi
    2433:	add    rax,0x2
    2437:	seto   cl
    243a:	test   cl,cl
    243c:	jne    244d <botlish_fn_21+0x1e5>
    2442:	mov    rsi,rax
    2445:	mov    r14,rax
    2448:	jmp    2463 <botlish_fn_21+0x1fb>
    244d:	mov    edx,0x3
    2452:	mov    rsi,r14
    2455:	mov    rdi,rbx
    2458:	call   245d <botlish_fn_21+0x1f5>
			2459: R_X86_64_PLT32	rt_int_add-0x4
    245d:	mov    rsi,rax
    2460:	mov    r14,rax
    2463:	mov    QWORD PTR [rsp],rsi
    2467:	mov    QWORD PTR [rsp+0x8],r13
    246c:	mov    QWORD PTR [rsp+0x10],r12
    2471:	mov    rdx,r13
    2474:	mov    rdi,rbx
    2477:	jmp    22a9 <botlish_fn_21+0x41>
    247c:	mov    rax,r14
    247f:	mov    rbx,QWORD PTR [rsp+0x50]
    2484:	mov    r12,QWORD PTR [rsp+0x58]
    2489:	mov    r13,QWORD PTR [rsp+0x60]
    248e:	mov    r14,QWORD PTR [rsp+0x68]
    2493:	mov    r15,QWORD PTR [rsp+0x70]
    2498:	add    rsp,0x80
    249f:	mov    rsp,rbp
    24a2:	pop    rbp
    24a3:	ret
    24a4:	add    BYTE PTR [rax],al
    24a6:	add    BYTE PTR [rax],al
    24a8:	(bad)
    24a9:	add    BYTE PTR [rax],al
    24ab:	add    BYTE PTR [rax],al
    24ad:	add    BYTE PTR [rax],al
	...

00000000000024b0 <botlish_entry_21: scan_label<generic>>:
    24b0:	push   rbp
    24b1:	mov    rbp,rsp
    24b4:	mov    rsi,QWORD PTR [rdx]
    24b7:	mov    r8,QWORD PTR [rdx+0x8]
    24bb:	mov    rcx,QWORD PTR [rdx+0x10]
    24bf:	mov    rdx,r8
    24c2:	call   24c7 <botlish_entry_21+0x17>
			24c3: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    24c7:	mov    rsp,rbp
    24ca:	pop    rbp
    24cb:	ret
    24cc:	add    BYTE PTR [rax],al
	...

00000000000024d0 <botlish_fn_22: scan_alpha<generic>>:
    24d0:	push   rbp
    24d1:	mov    rbp,rsp
    24d4:	sub    rsp,0x50
    24d8:	mov    QWORD PTR [rsp+0x30],rbx
    24dd:	mov    QWORD PTR [rsp+0x38],r12
    24e2:	mov    QWORD PTR [rsp+0x40],r13
    24e7:	mov    QWORD PTR [rsp+0x48],r14
    24ec:	mov    r14,rdi
    24ef:	mov    QWORD PTR [rsp+0x18],0x0
    24f8:	mov    QWORD PTR [rsp],rsi
    24fc:	mov    r13,rsi
    24ff:	mov    QWORD PTR [rsp+0x8],rdx
    2504:	mov    r12,rdx
    2507:	mov    QWORD PTR [rsp+0x10],rcx
    250c:	mov    rbx,rcx
    250f:	mov    r11d,0x1
    2515:	mov    rsi,r13
    2518:	test   rsi,0x1
    251f:	jne    253f <botlish_fn_22+0x6f>
    2525:	xor    r11d,r11d
    2528:	test   rsi,0x7
    252f:	jne    253f <botlish_fn_22+0x6f>
    2535:	movzx  rax,BYTE PTR [rsi]
    2539:	cmp    al,0x1
    253b:	sete   r11b
    253f:	test   r11b,r11b
    2542:	jne    2563 <botlish_fn_22+0x93>
    2548:	mov    rdi,r14
    254b:	mov    rax,QWORD PTR [rdi+0x10]
    254f:	mov    rcx,QWORD PTR [rax+0xc8]
    2556:	xor    rdx,rdx
    2559:	call   255e <botlish_fn_22+0x8e>
			255a: R_X86_64_PLT32	rt_type_error-0x4
    255e:	jmp    25f2 <botlish_fn_22+0x122>
    2563:	mov    rax,rsi
    2566:	and    rax,r12
    2569:	mov    r13,rsi
    256c:	test   rax,0x1
    2572:	jne    259b <botlish_fn_22+0xcb>
    2578:	mov    rdx,r12
    257b:	mov    rsi,r13
    257e:	mov    rdi,r14
    2581:	call   2586 <botlish_fn_22+0xb6>
			2582: R_X86_64_PLT32	rt_int_cmp-0x4
    2586:	mov    ecx,0x2
    258b:	test   rax,rax
    258e:	cmovge rcx,QWORD PTR [rip+0x112]        # 26a8 <botlish_fn_22+0x1d8>
    2596:	jmp    25ae <botlish_fn_22+0xde>
    259b:	mov    ecx,0x2
    25a0:	mov    rsi,r13
    25a3:	cmp    rsi,r12
    25a6:	cmovge rcx,QWORD PTR [rip+0xfa]        # 26a8 <botlish_fn_22+0x1d8>
    25ae:	cmp    rcx,0x6
    25b2:	je     2686 <botlish_fn_22+0x1b6>
    25b8:	lea    rcx,[rsp+0x20]
    25bd:	mov    rdx,rbx
    25c0:	mov    rsi,r13
    25c3:	mov    rdi,r14
    25c6:	call   25cb <botlish_fn_22+0xfb>
			25c7: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    25cb:	test   rax,rax
    25ce:	mov    rsi,rax
    25d1:	je     25f2 <botlish_fn_22+0x122>
    25d7:	mov    rdx,QWORD PTR [rsp+0x20]
    25dc:	mov    rcx,QWORD PTR [rsp+0x28]
    25e1:	mov    rdi,r14
    25e4:	call   25e9 <botlish_fn_22+0x119>
			25e5: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    25e9:	test   rax,rax
    25ec:	jne    2612 <botlish_fn_22+0x142>
    25f2:	xor    rax,rax
    25f5:	mov    rbx,QWORD PTR [rsp+0x30]
    25fa:	mov    r12,QWORD PTR [rsp+0x38]
    25ff:	mov    r13,QWORD PTR [rsp+0x40]
    2604:	mov    r14,QWORD PTR [rsp+0x48]
    2609:	add    rsp,0x50
    260d:	mov    rsp,rbp
    2610:	pop    rbp
    2611:	ret
    2612:	cmp    rax,0x6
    2616:	je     2624 <botlish_fn_22+0x154>
    261c:	mov    rax,r13
    261f:	jmp    2689 <botlish_fn_22+0x1b9>
    2624:	mov    QWORD PTR [rsp+0x18],0x3
    262d:	mov    rsi,r13
    2630:	test   rsi,0x1
    2637:	je     265d <botlish_fn_22+0x18d>
    263d:	mov    rsi,r13
    2640:	mov    r11,rsi
    2643:	add    r11,0x2
    2647:	seto   al
    264a:	test   al,al
    264c:	jne    265d <botlish_fn_22+0x18d>
    2652:	mov    rsi,r11
    2655:	mov    r13,r11
    2658:	jmp    2673 <botlish_fn_22+0x1a3>
    265d:	mov    edx,0x3
    2662:	mov    rsi,r13
    2665:	mov    rdi,r14
    2668:	call   266d <botlish_fn_22+0x19d>
			2669: R_X86_64_PLT32	rt_int_add-0x4
    266d:	mov    rsi,rax
    2670:	mov    r13,rax
    2673:	mov    QWORD PTR [rsp],rsi
    2677:	mov    QWORD PTR [rsp+0x8],r12
    267c:	mov    QWORD PTR [rsp+0x10],rbx
    2681:	jmp    250f <botlish_fn_22+0x3f>
    2686:	mov    rax,r13
    2689:	mov    rbx,QWORD PTR [rsp+0x30]
    268e:	mov    r12,QWORD PTR [rsp+0x38]
    2693:	mov    r13,QWORD PTR [rsp+0x40]
    2698:	mov    r14,QWORD PTR [rsp+0x48]
    269d:	add    rsp,0x50
    26a1:	mov    rsp,rbp
    26a4:	pop    rbp
    26a5:	ret
    26a6:	add    BYTE PTR [rax],al
    26a8:	(bad)
    26a9:	add    BYTE PTR [rax],al
    26ab:	add    BYTE PTR [rax],al
    26ad:	add    BYTE PTR [rax],al
	...

00000000000026b0 <botlish_entry_22: scan_alpha<generic>>:
    26b0:	push   rbp
    26b1:	mov    rbp,rsp
    26b4:	mov    rsi,QWORD PTR [rdx]
    26b7:	mov    r8,QWORD PTR [rdx+0x8]
    26bb:	mov    rcx,QWORD PTR [rdx+0x10]
    26bf:	mov    rdx,r8
    26c2:	call   26c7 <botlish_entry_22+0x17>
			26c3: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    26c7:	mov    rsp,rbp
    26ca:	pop    rbp
    26cb:	ret
    26cc:	add    BYTE PTR [rax],al
	...

00000000000026d0 <botlish_fn_23: tld_ok<generic>>:
    26d0:	push   rbp
    26d1:	mov    rbp,rsp
    26d4:	sub    rsp,0x40
    26d8:	mov    QWORD PTR [rsp+0x20],rbx
    26dd:	mov    QWORD PTR [rsp+0x28],r12
    26e2:	mov    QWORD PTR [rsp+0x30],r13
    26e7:	mov    QWORD PTR [rsp+0x38],r14
    26ec:	mov    rbx,rdi
    26ef:	mov    QWORD PTR [rsp],rsi
    26f3:	mov    r12,rsi
    26f6:	mov    QWORD PTR [rsp+0x8],rdx
    26fb:	mov    r14,rdx
    26fe:	mov    QWORD PTR [rsp+0x10],rcx
    2703:	mov    rdx,r14
    2706:	mov    rsi,r12
    2709:	mov    rdi,rbx
    270c:	call   2711 <botlish_fn_23+0x41>
			270d: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    2711:	mov    rsi,rax
    2714:	mov    r13,rax
    2717:	test   rax,rsi
    271a:	je     27dd <botlish_fn_23+0x10d>
    2720:	mov    rax,r13
    2723:	mov    QWORD PTR [rsp+0x8],rax
    2728:	mov    rdx,r14
    272b:	and    rax,rdx
    272e:	test   rax,0x1
    2734:	jne    275d <botlish_fn_23+0x8d>
    273a:	mov    rsi,r13
    273d:	mov    rdi,rbx
    2740:	call   2745 <botlish_fn_23+0x75>
			2741: R_X86_64_PLT32	rt_int_cmp-0x4
    2745:	mov    ecx,0x2
    274a:	test   rax,rax
    274d:	cmove  rcx,QWORD PTR [rip+0x15b]        # 28b0 <botlish_fn_23+0x1e0>
    2755:	mov    rax,r13
    2758:	jmp    2770 <botlish_fn_23+0xa0>
    275d:	mov    ecx,0x2
    2762:	mov    rax,r13
    2765:	cmp    rax,rdx
    2768:	cmove  rcx,QWORD PTR [rip+0x140]        # 28b0 <botlish_fn_23+0x1e0>
    2770:	cmp    rcx,0x6
    2774:	je     2787 <botlish_fn_23+0xb7>
    277a:	mov    ecx,0x2
    277f:	mov    rax,rcx
    2782:	jmp    288f <botlish_fn_23+0x1bf>
    2787:	mov    ecx,0x1
    278c:	mov    rsi,r12
    278f:	test   rsi,0x1
    2796:	jne    27bc <botlish_fn_23+0xec>
    279c:	xor    ecx,ecx
    279e:	mov    rsi,r12
    27a1:	test   rsi,0x7
    27a8:	jne    27bc <botlish_fn_23+0xec>
    27ae:	mov    rsi,r12
    27b1:	movzx  rcx,BYTE PTR [rsi]
    27b5:	rex cmp cl,0x1
    27b9:	sete   cl
    27bc:	test   cl,cl
    27be:	jne    27fd <botlish_fn_23+0x12d>
    27c4:	mov    rdi,rbx
    27c7:	mov    rsi,QWORD PTR [rdi+0x10]
    27cb:	mov    rcx,QWORD PTR [rsi+0x138]
    27d2:	xor    rdx,rdx
    27d5:	mov    rsi,r12
    27d8:	call   27dd <botlish_fn_23+0x10d>
			27d9: R_X86_64_PLT32	rt_type_error-0x4
    27dd:	xor    rax,rax
    27e0:	mov    rbx,QWORD PTR [rsp+0x20]
    27e5:	mov    r12,QWORD PTR [rsp+0x28]
    27ea:	mov    r13,QWORD PTR [rsp+0x30]
    27ef:	mov    r14,QWORD PTR [rsp+0x38]
    27f4:	add    rsp,0x40
    27f8:	mov    rsp,rbp
    27fb:	pop    rbp
    27fc:	ret
    27fd:	mov    rsi,r12
    2800:	mov    rdi,rax
    2803:	and    rdi,rsi
    2806:	test   rdi,0x1
    280d:	jne    281e <botlish_fn_23+0x14e>
    2813:	mov    rdx,r12
    2816:	mov    rsi,rax
    2819:	jmp    2841 <botlish_fn_23+0x171>
    281e:	mov    rsi,r12
    2821:	mov    r8,rax
    2824:	sub    r8,rsi
    2827:	mov    r13,rax
    282a:	seto   r10b
    282e:	lea    rsi,[r8+0x1]
    2832:	test   r10b,r10b
    2835:	je     284c <botlish_fn_23+0x17c>
    283b:	mov    rdx,r12
    283e:	mov    rsi,r13
    2841:	mov    rdi,rbx
    2844:	call   2849 <botlish_fn_23+0x179>
			2845: R_X86_64_PLT32	rt_int_sub-0x4
    2849:	mov    rsi,rax
    284c:	test   rsi,0x1
    2853:	jne    287e <botlish_fn_23+0x1ae>
    2859:	mov    edx,0x5
    285e:	mov    rdi,rbx
    2861:	call   2866 <botlish_fn_23+0x196>
			2862: R_X86_64_PLT32	rt_int_cmp-0x4
    2866:	mov    ecx,0x2
    286b:	test   rax,rax
    286e:	mov    rax,rcx
    2871:	cmovge rax,QWORD PTR [rip+0x37]        # 28b0 <botlish_fn_23+0x1e0>
    2879:	jmp    288f <botlish_fn_23+0x1bf>
    287e:	mov    eax,0x2
    2883:	cmp    rsi,0x5
    2887:	cmovge rax,QWORD PTR [rip+0x21]        # 28b0 <botlish_fn_23+0x1e0>
    288f:	mov    rbx,QWORD PTR [rsp+0x20]
    2894:	mov    r12,QWORD PTR [rsp+0x28]
    2899:	mov    r13,QWORD PTR [rsp+0x30]
    289e:	mov    r14,QWORD PTR [rsp+0x38]
    28a3:	add    rsp,0x40
    28a7:	mov    rsp,rbp
    28aa:	pop    rbp
    28ab:	ret
    28ac:	add    BYTE PTR [rax],al
    28ae:	add    BYTE PTR [rax],al
    28b0:	(bad)
    28b1:	add    BYTE PTR [rax],al
    28b3:	add    BYTE PTR [rax],al
    28b5:	add    BYTE PTR [rax],al
	...

00000000000028b8 <botlish_entry_23: tld_ok<generic>>:
    28b8:	push   rbp
    28b9:	mov    rbp,rsp
    28bc:	mov    rsi,QWORD PTR [rdx]
    28bf:	mov    r8,QWORD PTR [rdx+0x8]
    28c3:	mov    rcx,QWORD PTR [rdx+0x10]
    28c7:	mov    rdx,r8
    28ca:	call   28cf <botlish_entry_23+0x17>
			28cb: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    28cf:	mov    rsp,rbp
    28d2:	pop    rbp
    28d3:	ret
    28d4:	add    BYTE PTR [rax],al
	...

00000000000028d8 <botlish_fn_24: domain_loop<generic>>:
    28d8:	push   rbp
    28d9:	mov    rbp,rsp
    28dc:	sub    rsp,0x70
    28e0:	mov    QWORD PTR [rsp+0x40],rbx
    28e5:	mov    QWORD PTR [rsp+0x48],r12
    28ea:	mov    QWORD PTR [rsp+0x50],r13
    28ef:	mov    QWORD PTR [rsp+0x58],r14
    28f4:	mov    QWORD PTR [rsp+0x60],r15
    28f9:	mov    QWORD PTR [rsp+0x18],0x0
    2902:	mov    QWORD PTR [rsp],rsi
    2906:	mov    QWORD PTR [rsp+0x8],rdx
    290b:	mov    QWORD PTR [rsp+0x10],rcx
    2910:	lea    rbx,[rsp+0x20]
    2915:	mov    r12,rdi
    2918:	mov    r13,rcx
    291b:	mov    r14,rdx
    291e:	mov    QWORD PTR [rsp+0x30],rsi
    2923:	mov    rcx,r13
    2926:	mov    rdx,r14
    2929:	mov    rsi,QWORD PTR [rsp+0x30]
    292e:	mov    rdi,r12
    2931:	call   2936 <botlish_fn_24+0x5e>
			2932: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    2936:	mov    rcx,rax
    2939:	mov    r15,rax
    293c:	test   rax,rcx
    293f:	je     2a8f <botlish_fn_24+0x1b7>
    2945:	mov    rax,r15
    2948:	mov    QWORD PTR [rsp],rax
    294c:	mov    rdx,QWORD PTR [rsp+0x30]
    2951:	and    rax,rdx
    2954:	test   rax,0x1
    295a:	jne    2979 <botlish_fn_24+0xa1>
    2960:	mov    rsi,r15
    2963:	mov    rdi,r12
    2966:	call   296b <botlish_fn_24+0x93>
			2967: R_X86_64_PLT32	rt_value_eq-0x4
    296b:	test   rax,rax
    296e:	je     2a8f <botlish_fn_24+0x1b7>
    2974:	jmp    2989 <botlish_fn_24+0xb1>
    2979:	mov    eax,0x2
    297e:	cmp    r15,rdx
    2981:	cmove  rax,QWORD PTR [rip+0x187]        # 2b10 <botlish_fn_24+0x238>
    2989:	cmp    rax,0x6
    298d:	je     2ae5 <botlish_fn_24+0x20d>
    2993:	mov    rax,r15
    2996:	and    rax,r14
    2999:	test   rax,0x1
    299f:	jne    29c8 <botlish_fn_24+0xf0>
    29a5:	mov    rdx,r14
    29a8:	mov    rsi,r15
    29ab:	mov    rdi,r12
    29ae:	call   29b3 <botlish_fn_24+0xdb>
			29af: R_X86_64_PLT32	rt_int_cmp-0x4
    29b3:	mov    ecx,0x2
    29b8:	test   rax,rax
    29bb:	cmovge rcx,QWORD PTR [rip+0x14d]        # 2b10 <botlish_fn_24+0x238>
    29c3:	jmp    29d8 <botlish_fn_24+0x100>
    29c8:	mov    ecx,0x2
    29cd:	cmp    r15,r14
    29d0:	cmovge rcx,QWORD PTR [rip+0x138]        # 2b10 <botlish_fn_24+0x238>
    29d8:	cmp    rcx,0x6
    29dc:	je     2ad6 <botlish_fn_24+0x1fe>
    29e2:	mov    rcx,rbx
    29e5:	mov    rdx,r13
    29e8:	mov    rsi,r15
    29eb:	mov    rdi,r12
    29ee:	call   29f3 <botlish_fn_24+0x11b>
			29ef: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    29f3:	test   rax,rax
    29f6:	je     2a8f <botlish_fn_24+0x1b7>
    29fc:	mov    rdx,QWORD PTR [rsp+0x20]
    2a01:	mov    rcx,QWORD PTR [rsp+0x28]
    2a06:	mov    rsi,QWORD PTR [r12+0x10]
    2a0b:	mov    r8,QWORD PTR [rsi+0x128]
    2a12:	mov    rsi,rax
    2a15:	mov    rdi,r12
    2a18:	call   2a1d <botlish_fn_24+0x145>
			2a19: R_X86_64_PLT32	rt_str_region_eq-0x4
    2a1d:	cmp    rax,0x6
    2a21:	je     2a33 <botlish_fn_24+0x15b>
    2a27:	mov    r14,0xffffffffffffffff
    2a2e:	jmp    2add <botlish_fn_24+0x205>
    2a33:	mov    QWORD PTR [rsp+0x18],0x3
    2a3c:	test   r15,0x1
    2a43:	je     2a5b <botlish_fn_24+0x183>
    2a49:	mov    rdx,r15
    2a4c:	add    rdx,0x2
    2a50:	seto   al
    2a53:	test   al,al
    2a55:	je     2a6e <botlish_fn_24+0x196>
    2a5b:	mov    edx,0x3
    2a60:	mov    rsi,r15
    2a63:	mov    rdi,r12
    2a66:	call   2a6b <botlish_fn_24+0x193>
			2a67: R_X86_64_PLT32	rt_int_add-0x4
    2a6b:	mov    rdx,rax
    2a6e:	mov    QWORD PTR [rsp],rdx
    2a72:	mov    r15,rdx
    2a75:	mov    rcx,r13
    2a78:	mov    rdx,r14
    2a7b:	mov    rsi,r15
    2a7e:	mov    rdi,r12
    2a81:	call   2a86 <botlish_fn_24+0x1ae>
			2a82: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    2a86:	test   rax,rax
    2a89:	jne    2ab4 <botlish_fn_24+0x1dc>
    2a8f:	xor    rax,rax
    2a92:	mov    rbx,QWORD PTR [rsp+0x40]
    2a97:	mov    r12,QWORD PTR [rsp+0x48]
    2a9c:	mov    r13,QWORD PTR [rsp+0x50]
    2aa1:	mov    r14,QWORD PTR [rsp+0x58]
    2aa6:	mov    r15,QWORD PTR [rsp+0x60]
    2aab:	add    rsp,0x70
    2aaf:	mov    rsp,rbp
    2ab2:	pop    rbp
    2ab3:	ret
    2ab4:	cmp    rax,0x6
    2ab8:	je     2add <botlish_fn_24+0x205>
    2abe:	mov    QWORD PTR [rsp],r15
    2ac2:	mov    QWORD PTR [rsp+0x8],r14
    2ac7:	mov    QWORD PTR [rsp+0x10],r13
    2acc:	mov    QWORD PTR [rsp+0x30],r15
    2ad1:	jmp    2923 <botlish_fn_24+0x4b>
    2ad6:	mov    r14,0xffffffffffffffff
    2add:	mov    rax,r14
    2ae0:	jmp    2aec <botlish_fn_24+0x214>
    2ae5:	mov    rax,0xffffffffffffffff
    2aec:	mov    rbx,QWORD PTR [rsp+0x40]
    2af1:	mov    r12,QWORD PTR [rsp+0x48]
    2af6:	mov    r13,QWORD PTR [rsp+0x50]
    2afb:	mov    r14,QWORD PTR [rsp+0x58]
    2b00:	mov    r15,QWORD PTR [rsp+0x60]
    2b05:	add    rsp,0x70
    2b09:	mov    rsp,rbp
    2b0c:	pop    rbp
    2b0d:	ret
    2b0e:	add    BYTE PTR [rax],al
    2b10:	(bad)
    2b11:	add    BYTE PTR [rax],al
    2b13:	add    BYTE PTR [rax],al
    2b15:	add    BYTE PTR [rax],al
	...

0000000000002b18 <botlish_entry_24: domain_loop<generic>>:
    2b18:	push   rbp
    2b19:	mov    rbp,rsp
    2b1c:	mov    rsi,QWORD PTR [rdx]
    2b1f:	mov    r8,QWORD PTR [rdx+0x8]
    2b23:	mov    rcx,QWORD PTR [rdx+0x10]
    2b27:	mov    rdx,r8
    2b2a:	call   2b2f <botlish_entry_24+0x17>
			2b2b: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    2b2f:	mov    rsp,rbp
    2b32:	pop    rbp
    2b33:	ret
    2b34:	add    BYTE PTR [rax],al
	...

0000000000002b38 <botlish_fn_25: <str>>:
    2b38:	push   rbp
    2b39:	mov    rbp,rsp
    2b3c:	sub    rsp,0x50
    2b40:	mov    QWORD PTR [rsp+0x30],rbx
    2b45:	mov    QWORD PTR [rsp+0x38],r12
    2b4a:	mov    QWORD PTR [rsp+0x40],r13
    2b4f:	mov    QWORD PTR [rsp+0x48],r14
    2b54:	mov    r13,rdi
    2b57:	mov    QWORD PTR [rsp+0x18],0x0
    2b60:	mov    QWORD PTR [rsp],rsi
    2b64:	mov    r14,rsi
    2b67:	mov    rsi,r14
    2b6a:	mov    rdi,r13
    2b6d:	call   2b72 <botlish_fn_25+0x3a>
			2b6e: R_X86_64_PLT32	rt_str_len-0x4
    2b72:	mov    rbx,rax
    2b75:	mov    QWORD PTR [rsp+0x8],rax
    2b7a:	mov    esi,0x1
    2b7f:	mov    QWORD PTR [rsp+0x10],0x1
    2b88:	mov    rcx,r14
    2b8b:	mov    rdx,rbx
    2b8e:	mov    rdi,r13
    2b91:	call   2b96 <botlish_fn_25+0x5e>
			2b92: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    2b96:	mov    r12,rax
    2b99:	test   r12,r12
    2b9c:	je     2cf9 <botlish_fn_25+0x1c1>
    2ba2:	mov    QWORD PTR [rsp+0x10],r12
    2ba7:	test   r12,0x1
    2bae:	jne    2bd9 <botlish_fn_25+0xa1>
    2bb4:	mov    edx,0x1
    2bb9:	mov    rsi,r12
    2bbc:	mov    rdi,r13
    2bbf:	call   2bc4 <botlish_fn_25+0x8c>
			2bc0: R_X86_64_PLT32	rt_int_cmp-0x4
    2bc4:	mov    ecx,0x2
    2bc9:	test   rax,rax
    2bcc:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 2d98 <botlish_fn_25+0x260>
    2bd4:	jmp    2bea <botlish_fn_25+0xb2>
    2bd9:	mov    ecx,0x2
    2bde:	cmp    r12,0x1
    2be2:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 2d98 <botlish_fn_25+0x260>
    2bea:	cmp    rcx,0x6
    2bee:	je     2d74 <botlish_fn_25+0x23c>
    2bf4:	mov    rcx,r12
    2bf7:	and    rcx,rbx
    2bfa:	test   rcx,0x1
    2c01:	jne    2c2a <botlish_fn_25+0xf2>
    2c07:	mov    rdx,rbx
    2c0a:	mov    rsi,r12
    2c0d:	mov    rdi,r13
    2c10:	call   2c15 <botlish_fn_25+0xdd>
			2c11: R_X86_64_PLT32	rt_int_cmp-0x4
    2c15:	mov    ecx,0x2
    2c1a:	test   rax,rax
    2c1d:	cmovge rcx,QWORD PTR [rip+0x173]        # 2d98 <botlish_fn_25+0x260>
    2c25:	jmp    2c3a <botlish_fn_25+0x102>
    2c2a:	mov    ecx,0x2
    2c2f:	cmp    r12,rbx
    2c32:	cmovge rcx,QWORD PTR [rip+0x15e]        # 2d98 <botlish_fn_25+0x260>
    2c3a:	cmp    rcx,0x6
    2c3e:	je     2d6a <botlish_fn_25+0x232>
    2c44:	lea    rcx,[rsp+0x20]
    2c49:	mov    rdx,r14
    2c4c:	mov    rsi,r12
    2c4f:	mov    rdi,r13
    2c52:	call   2c57 <botlish_fn_25+0x11f>
			2c53: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    2c57:	test   rax,rax
    2c5a:	mov    rsi,rax
    2c5d:	je     2cf9 <botlish_fn_25+0x1c1>
    2c63:	mov    rdx,QWORD PTR [rsp+0x20]
    2c68:	mov    rcx,QWORD PTR [rsp+0x28]
    2c6d:	mov    rdi,r13
    2c70:	mov    rax,QWORD PTR [rdi+0x10]
    2c74:	mov    r8,QWORD PTR [rax+0x110]
    2c7b:	call   2c80 <botlish_fn_25+0x148>
			2c7c: R_X86_64_PLT32	rt_str_region_eq-0x4
    2c80:	cmp    rax,0x6
    2c84:	je     2c97 <botlish_fn_25+0x15f>
    2c8a:	mov    ecx,0x2
    2c8f:	mov    rax,rcx
    2c92:	jmp    2d79 <botlish_fn_25+0x241>
    2c97:	mov    QWORD PTR [rsp+0x18],0x3
    2ca0:	test   r12,0x1
    2ca7:	jne    2cb5 <botlish_fn_25+0x17d>
    2cad:	mov    rcx,r12
    2cb0:	jmp    2cca <botlish_fn_25+0x192>
    2cb5:	mov    rsi,r12
    2cb8:	add    rsi,0x2
    2cbc:	mov    rcx,r12
    2cbf:	seto   al
    2cc2:	test   al,al
    2cc4:	je     2cdd <botlish_fn_25+0x1a5>
    2cca:	mov    edx,0x3
    2ccf:	mov    rsi,rcx
    2cd2:	mov    rdi,r13
    2cd5:	call   2cda <botlish_fn_25+0x1a2>
			2cd6: R_X86_64_PLT32	rt_int_add-0x4
    2cda:	mov    rsi,rax
    2cdd:	mov    QWORD PTR [rsp+0x10],rsi
    2ce2:	mov    rcx,r14
    2ce5:	mov    rdx,rbx
    2ce8:	mov    rdi,r13
    2ceb:	call   2cf0 <botlish_fn_25+0x1b8>
			2cec: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    2cf0:	test   rax,rax
    2cf3:	jne    2d19 <botlish_fn_25+0x1e1>
    2cf9:	xor    rax,rax
    2cfc:	mov    rbx,QWORD PTR [rsp+0x30]
    2d01:	mov    r12,QWORD PTR [rsp+0x38]
    2d06:	mov    r13,QWORD PTR [rsp+0x40]
    2d0b:	mov    r14,QWORD PTR [rsp+0x48]
    2d10:	add    rsp,0x50
    2d14:	mov    rsp,rbp
    2d17:	pop    rbp
    2d18:	ret
    2d19:	mov    rcx,rax
    2d1c:	and    rcx,rbx
    2d1f:	mov    rsi,rax
    2d22:	test   rcx,0x1
    2d29:	jne    2d52 <botlish_fn_25+0x21a>
    2d2f:	mov    rdx,rbx
    2d32:	mov    rdi,r13
    2d35:	call   2d3a <botlish_fn_25+0x202>
			2d36: R_X86_64_PLT32	rt_int_cmp-0x4
    2d3a:	mov    ecx,0x2
    2d3f:	test   rax,rax
    2d42:	mov    rax,rcx
    2d45:	cmove  rax,QWORD PTR [rip+0x4b]        # 2d98 <botlish_fn_25+0x260>
    2d4d:	jmp    2d79 <botlish_fn_25+0x241>
    2d52:	mov    rdx,rbx
    2d55:	mov    eax,0x2
    2d5a:	cmp    rsi,rdx
    2d5d:	cmove  rax,QWORD PTR [rip+0x33]        # 2d98 <botlish_fn_25+0x260>
    2d65:	jmp    2d79 <botlish_fn_25+0x241>
    2d6a:	mov    eax,0x2
    2d6f:	jmp    2d79 <botlish_fn_25+0x241>
    2d74:	mov    eax,0x2
    2d79:	mov    rbx,QWORD PTR [rsp+0x30]
    2d7e:	mov    r12,QWORD PTR [rsp+0x38]
    2d83:	mov    r13,QWORD PTR [rsp+0x40]
    2d88:	mov    r14,QWORD PTR [rsp+0x48]
    2d8d:	add    rsp,0x50
    2d91:	mov    rsp,rbp
    2d94:	pop    rbp
    2d95:	ret
    2d96:	add    BYTE PTR [rax],al
    2d98:	(bad)
    2d99:	add    BYTE PTR [rax],al
    2d9b:	add    BYTE PTR [rax],al
    2d9d:	add    BYTE PTR [rax],al
	...

0000000000002da0 <botlish_entry_25: <str>>:
    2da0:	push   rbp
    2da1:	mov    rbp,rsp
    2da4:	mov    rsi,QWORD PTR [rdx]
    2da7:	call   2dac <botlish_entry_25+0xc>
			2da8: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    2dac:	mov    rsp,rbp
    2daf:	pop    rbp
    2db0:	ret
    2db1:	add    BYTE PTR [rax],al
    2db3:	add    BYTE PTR [rax],al
    2db5:	add    BYTE PTR [rax],al
	...

0000000000002db8 <botlish_fn_26: <generic>>:
    2db8:	push   rbp
    2db9:	mov    rbp,rsp
    2dbc:	sub    rsp,0x60
    2dc0:	mov    QWORD PTR [rsp+0x30],rbx
    2dc5:	mov    QWORD PTR [rsp+0x38],r12
    2dca:	mov    QWORD PTR [rsp+0x40],r13
    2dcf:	mov    QWORD PTR [rsp+0x48],r14
    2dd4:	mov    QWORD PTR [rsp+0x50],r15
    2dd9:	mov    QWORD PTR [rsp+0x18],0x0
    2de2:	mov    QWORD PTR [rsp],rsi
    2de6:	xor    r8d,r8d
    2de9:	test   rsi,0x7
    2df0:	jne    2e00 <botlish_fn_26+0x48>
    2df6:	movzx  rax,BYTE PTR [rsi]
    2dfa:	cmp    al,0x2
    2dfc:	sete   r8b
    2e00:	test   r8b,r8b
    2e03:	jne    2e23 <botlish_fn_26+0x6b>
    2e09:	mov    rdx,QWORD PTR [rdi+0x10]
    2e0d:	mov    rcx,QWORD PTR [rdx+0xe8]
    2e14:	mov    edx,0x1
    2e19:	call   2e1e <botlish_fn_26+0x66>
			2e1a: R_X86_64_PLT32	rt_type_error-0x4
    2e1e:	jmp    2fb8 <botlish_fn_26+0x200>
    2e23:	mov    r13,rsi
    2e26:	mov    r14,rdi
    2e29:	call   2e2e <botlish_fn_26+0x76>
			2e2a: R_X86_64_PLT32	rt_str_len-0x4
    2e2e:	mov    rbx,rax
    2e31:	mov    QWORD PTR [rsp+0x8],rax
    2e36:	mov    edx,0x1
    2e3b:	mov    r15,rdx
    2e3e:	mov    QWORD PTR [rsp+0x10],0x1
    2e47:	mov    rcx,r13
    2e4a:	mov    rdx,rbx
    2e4d:	mov    rsi,r15
    2e50:	mov    rdi,r14
    2e53:	call   2e58 <botlish_fn_26+0xa0>
			2e54: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    2e58:	mov    r12,rax
    2e5b:	test   r12,r12
    2e5e:	je     2fb8 <botlish_fn_26+0x200>
    2e64:	mov    QWORD PTR [rsp+0x10],r12
    2e69:	test   r12,0x1
    2e70:	jne    2e99 <botlish_fn_26+0xe1>
    2e76:	mov    rdx,r15
    2e79:	mov    rsi,r12
    2e7c:	mov    rdi,r14
    2e7f:	call   2e84 <botlish_fn_26+0xcc>
			2e80: R_X86_64_PLT32	rt_int_cmp-0x4
    2e84:	mov    ecx,0x2
    2e89:	test   rax,rax
    2e8c:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 3060 <botlish_fn_26+0x2a8>
    2e94:	jmp    2eaa <botlish_fn_26+0xf2>
    2e99:	mov    ecx,0x2
    2e9e:	cmp    r12,0x1
    2ea2:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 3060 <botlish_fn_26+0x2a8>
    2eaa:	cmp    rcx,0x6
    2eae:	je     3038 <botlish_fn_26+0x280>
    2eb4:	mov    rax,r12
    2eb7:	and    rax,rbx
    2eba:	test   rax,0x1
    2ec0:	jne    2ee9 <botlish_fn_26+0x131>
    2ec6:	mov    rdx,rbx
    2ec9:	mov    rsi,r12
    2ecc:	mov    rdi,r14
    2ecf:	call   2ed4 <botlish_fn_26+0x11c>
			2ed0: R_X86_64_PLT32	rt_int_cmp-0x4
    2ed4:	mov    ecx,0x2
    2ed9:	test   rax,rax
    2edc:	cmovge rcx,QWORD PTR [rip+0x17c]        # 3060 <botlish_fn_26+0x2a8>
    2ee4:	jmp    2ef9 <botlish_fn_26+0x141>
    2ee9:	mov    ecx,0x2
    2eee:	cmp    r12,rbx
    2ef1:	cmovge rcx,QWORD PTR [rip+0x167]        # 3060 <botlish_fn_26+0x2a8>
    2ef9:	cmp    rcx,0x6
    2efd:	je     302e <botlish_fn_26+0x276>
    2f03:	lea    rcx,[rsp+0x20]
    2f08:	mov    rdx,r13
    2f0b:	mov    rsi,r12
    2f0e:	mov    rdi,r14
    2f11:	call   2f16 <botlish_fn_26+0x15e>
			2f12: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    2f16:	test   rax,rax
    2f19:	mov    rsi,rax
    2f1c:	je     2fb8 <botlish_fn_26+0x200>
    2f22:	mov    rdx,QWORD PTR [rsp+0x20]
    2f27:	mov    rcx,QWORD PTR [rsp+0x28]
    2f2c:	mov    rdi,r14
    2f2f:	mov    rax,QWORD PTR [rdi+0x10]
    2f33:	mov    r8,QWORD PTR [rax+0x110]
    2f3a:	call   2f3f <botlish_fn_26+0x187>
			2f3b: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f3f:	cmp    rax,0x6
    2f43:	je     2f56 <botlish_fn_26+0x19e>
    2f49:	mov    ecx,0x2
    2f4e:	mov    rax,rcx
    2f51:	jmp    303d <botlish_fn_26+0x285>
    2f56:	mov    QWORD PTR [rsp+0x18],0x3
    2f5f:	test   r12,0x1
    2f66:	jne    2f74 <botlish_fn_26+0x1bc>
    2f6c:	mov    rdi,r12
    2f6f:	jmp    2f89 <botlish_fn_26+0x1d1>
    2f74:	mov    rsi,r12
    2f77:	add    rsi,0x2
    2f7b:	mov    rdi,r12
    2f7e:	seto   al
    2f81:	test   al,al
    2f83:	je     2f9c <botlish_fn_26+0x1e4>
    2f89:	mov    edx,0x3
    2f8e:	mov    rsi,rdi
    2f91:	mov    rdi,r14
    2f94:	call   2f99 <botlish_fn_26+0x1e1>
			2f95: R_X86_64_PLT32	rt_int_add-0x4
    2f99:	mov    rsi,rax
    2f9c:	mov    QWORD PTR [rsp+0x10],rsi
    2fa1:	mov    rcx,r13
    2fa4:	mov    rdx,rbx
    2fa7:	mov    rdi,r14
    2faa:	call   2faf <botlish_fn_26+0x1f7>
			2fab: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    2faf:	test   rax,rax
    2fb2:	jne    2fdd <botlish_fn_26+0x225>
    2fb8:	xor    rax,rax
    2fbb:	mov    rbx,QWORD PTR [rsp+0x30]
    2fc0:	mov    r12,QWORD PTR [rsp+0x38]
    2fc5:	mov    r13,QWORD PTR [rsp+0x40]
    2fca:	mov    r14,QWORD PTR [rsp+0x48]
    2fcf:	mov    r15,QWORD PTR [rsp+0x50]
    2fd4:	add    rsp,0x60
    2fd8:	mov    rsp,rbp
    2fdb:	pop    rbp
    2fdc:	ret
    2fdd:	mov    rcx,rax
    2fe0:	and    rcx,rbx
    2fe3:	mov    rsi,rax
    2fe6:	test   rcx,0x1
    2fed:	jne    3016 <botlish_fn_26+0x25e>
    2ff3:	mov    rdx,rbx
    2ff6:	mov    rdi,r14
    2ff9:	call   2ffe <botlish_fn_26+0x246>
			2ffa: R_X86_64_PLT32	rt_int_cmp-0x4
    2ffe:	mov    ecx,0x2
    3003:	test   rax,rax
    3006:	mov    rax,rcx
    3009:	cmove  rax,QWORD PTR [rip+0x4f]        # 3060 <botlish_fn_26+0x2a8>
    3011:	jmp    303d <botlish_fn_26+0x285>
    3016:	mov    rdx,rbx
    3019:	mov    eax,0x2
    301e:	cmp    rsi,rdx
    3021:	cmove  rax,QWORD PTR [rip+0x37]        # 3060 <botlish_fn_26+0x2a8>
    3029:	jmp    303d <botlish_fn_26+0x285>
    302e:	mov    eax,0x2
    3033:	jmp    303d <botlish_fn_26+0x285>
    3038:	mov    eax,0x2
    303d:	mov    rbx,QWORD PTR [rsp+0x30]
    3042:	mov    r12,QWORD PTR [rsp+0x38]
    3047:	mov    r13,QWORD PTR [rsp+0x40]
    304c:	mov    r14,QWORD PTR [rsp+0x48]
    3051:	mov    r15,QWORD PTR [rsp+0x50]
    3056:	add    rsp,0x60
    305a:	mov    rsp,rbp
    305d:	pop    rbp
    305e:	ret
    305f:	add    BYTE PTR [rsi],al
    3061:	add    BYTE PTR [rax],al
    3063:	add    BYTE PTR [rax],al
    3065:	add    BYTE PTR [rax],al
	...

0000000000003068 <botlish_entry_26: <generic>>:
    3068:	push   rbp
    3069:	mov    rbp,rsp
    306c:	mov    rsi,QWORD PTR [rdx]
    306f:	call   3074 <botlish_entry_26+0xc>
			3070: R_X86_64_PLT32	botlish_fn_26-0x4 ; <generic>
    3074:	mov    rsp,rbp
    3077:	pop    rbp
    3078:	ret

0000000000003079 <botlish_fn_27: char_at<generic>>:
    3079:	push   rbp
    307a:	mov    rbp,rsp
    307d:	sub    rsp,0x50
    3081:	mov    QWORD PTR [rsp+0x20],rbx
    3086:	mov    QWORD PTR [rsp+0x28],r12
    308b:	mov    QWORD PTR [rsp+0x30],r13
    3090:	mov    QWORD PTR [rsp+0x38],r14
    3095:	mov    QWORD PTR [rsp+0x40],r15
    309a:	mov    r14,rcx
    309d:	mov    QWORD PTR [rsp],rsi
    30a1:	mov    QWORD PTR [rsp+0x8],rdx
    30a6:	mov    r13,rdx
    30a9:	mov    QWORD PTR [rsp+0x10],0x3
    30b2:	mov    r9d,0x1
    30b8:	test   rsi,0x1
    30bf:	jne    30df <botlish_fn_27+0x66>
    30c5:	xor    r9d,r9d
    30c8:	test   rsi,0x7
    30cf:	jne    30df <botlish_fn_27+0x66>
    30d5:	movzx  rax,BYTE PTR [rsi]
    30d9:	cmp    al,0x1
    30db:	sete   r9b
    30df:	test   r9b,r9b
    30e2:	jne    3100 <botlish_fn_27+0x87>
    30e8:	mov    rax,QWORD PTR [rdi+0x10]
    30ec:	mov    rcx,QWORD PTR [rax+0x118]
    30f3:	xor    rdx,rdx
    30f6:	call   30fb <botlish_fn_27+0x82>
			30f7: R_X86_64_PLT32	rt_type_error-0x4
    30fb:	jmp    31bd <botlish_fn_27+0x144>
    3100:	mov    r12,rdi
    3103:	test   rsi,0x1
    310a:	jne    3118 <botlish_fn_27+0x9f>
    3110:	mov    rbx,rsi
    3113:	jmp    3135 <botlish_fn_27+0xbc>
    3118:	mov    rax,rsi
    311b:	add    rax,0x2
    311f:	mov    rbx,rsi
    3122:	seto   cl
    3125:	test   cl,cl
    3127:	jne    3135 <botlish_fn_27+0xbc>
    312d:	mov    r15,rax
    3130:	jmp    3148 <botlish_fn_27+0xcf>
    3135:	mov    edx,0x3
    313a:	mov    rsi,rbx
    313d:	mov    rdi,r12
    3140:	call   3145 <botlish_fn_27+0xcc>
			3141: R_X86_64_PLT32	rt_int_add-0x4
    3145:	mov    r15,rax
    3148:	mov    ecx,0x1
    314d:	mov    rsi,rbx
    3150:	test   rsi,0x1
    3157:	jne    317d <botlish_fn_27+0x104>
    315d:	xor    ecx,ecx
    315f:	mov    rsi,rbx
    3162:	test   rsi,0x7
    3169:	jne    317d <botlish_fn_27+0x104>
    316f:	mov    rsi,rbx
    3172:	movzx  rcx,BYTE PTR [rsi]
    3176:	rex cmp cl,0x1
    317a:	sete   cl
    317d:	test   cl,cl
    317f:	jne    31a3 <botlish_fn_27+0x12a>
    3185:	mov    rdi,r12
    3188:	mov    rsi,QWORD PTR [rdi+0x10]
    318c:	mov    rcx,QWORD PTR [rsi+0x120]
    3193:	xor    rdx,rdx
    3196:	mov    rsi,rbx
    3199:	call   319e <botlish_fn_27+0x125>
			319a: R_X86_64_PLT32	rt_type_error-0x4
    319e:	jmp    31bd <botlish_fn_27+0x144>
    31a3:	mov    rdi,r12
    31a6:	mov    rcx,r15
    31a9:	mov    rdx,rbx
    31ac:	mov    rsi,r13
    31af:	call   31b4 <botlish_fn_27+0x13b>
			31b0: R_X86_64_PLT32	rt_str_region_check-0x4
    31b4:	test   rax,rax
    31b7:	jne    31e2 <botlish_fn_27+0x169>
    31bd:	xor    rax,rax
    31c0:	mov    rbx,QWORD PTR [rsp+0x20]
    31c5:	mov    r12,QWORD PTR [rsp+0x28]
    31ca:	mov    r13,QWORD PTR [rsp+0x30]
    31cf:	mov    r14,QWORD PTR [rsp+0x38]
    31d4:	mov    r15,QWORD PTR [rsp+0x40]
    31d9:	add    rsp,0x50
    31dd:	mov    rsp,rbp
    31e0:	pop    rbp
    31e1:	ret
    31e2:	mov    rcx,r14
    31e5:	mov    rsi,rbx
    31e8:	mov    QWORD PTR [rcx],rsi
    31eb:	mov    rax,r15
    31ee:	mov    QWORD PTR [rcx+0x8],rax
    31f2:	mov    rax,r13
    31f5:	mov    rbx,QWORD PTR [rsp+0x20]
    31fa:	mov    r12,QWORD PTR [rsp+0x28]
    31ff:	mov    r13,QWORD PTR [rsp+0x30]
    3204:	mov    r14,QWORD PTR [rsp+0x38]
    3209:	mov    r15,QWORD PTR [rsp+0x40]
    320e:	add    rsp,0x50
    3212:	mov    rsp,rbp
    3215:	pop    rbp
    3216:	ret

0000000000003217 <botlish_entry_27: char_at<generic>>:
    3217:	push   rbp
    3218:	mov    rbp,rsp
    321b:	ud2
    321d:	add    BYTE PTR [rax],al
	...

0000000000003220 <botlish_fn_28: scan_local<generic>>:
    3220:	push   rbp
    3221:	mov    rbp,rsp
    3224:	sub    rsp,0x80
    322b:	mov    QWORD PTR [rsp+0x50],rbx
    3230:	mov    QWORD PTR [rsp+0x58],r12
    3235:	mov    QWORD PTR [rsp+0x60],r13
    323a:	mov    QWORD PTR [rsp+0x68],r14
    323f:	mov    QWORD PTR [rsp+0x70],r15
    3244:	mov    rax,rdi
    3247:	mov    QWORD PTR [rsp+0x18],0x0
    3250:	mov    QWORD PTR [rsp],rsi
    3254:	mov    r14,rsi
    3257:	mov    QWORD PTR [rsp+0x8],rdx
    325c:	mov    QWORD PTR [rsp+0x10],rcx
    3261:	mov    r12,rcx
    3264:	mov    r11d,0x1
    326a:	mov    rsi,r14
    326d:	test   rsi,0x1
    3274:	jne    3296 <botlish_fn_28+0x76>
    327a:	xor    r11d,r11d
    327d:	test   rsi,0x7
    3284:	jne    3296 <botlish_fn_28+0x76>
    328a:	movzx  rdi,BYTE PTR [rsi]
    328e:	cmp    dil,0x1
    3292:	sete   r11b
    3296:	test   r11b,r11b
    3299:	jne    32ba <botlish_fn_28+0x9a>
    329f:	mov    rdi,rax
    32a2:	mov    r9,QWORD PTR [rdi+0x10]
    32a6:	mov    rcx,QWORD PTR [r9+0xc8]
    32ad:	xor    rdx,rdx
    32b0:	call   32b5 <botlish_fn_28+0x95>
			32b1: R_X86_64_PLT32	rt_type_error-0x4
    32b5:	jmp    336d <botlish_fn_28+0x14d>
    32ba:	mov    r13,rdx
    32bd:	mov    r10,rsi
    32c0:	and    r10,r13
    32c3:	mov    r14,rsi
    32c6:	test   r10,0x1
    32cd:	jne    32f9 <botlish_fn_28+0xd9>
    32d3:	mov    rbx,rax
    32d6:	mov    rdx,r13
    32d9:	mov    rsi,r14
    32dc:	mov    rdi,rbx
    32df:	call   32e4 <botlish_fn_28+0xc4>
			32e0: R_X86_64_PLT32	rt_int_cmp-0x4
    32e4:	mov    ecx,0x2
    32e9:	test   rax,rax
    32ec:	cmovge rcx,QWORD PTR [rip+0x24c]        # 3540 <botlish_fn_28+0x320>
    32f4:	jmp    330f <botlish_fn_28+0xef>
    32f9:	mov    rbx,rax
    32fc:	mov    ecx,0x2
    3301:	mov    rsi,r14
    3304:	cmp    rsi,r13
    3307:	cmovge rcx,QWORD PTR [rip+0x231]        # 3540 <botlish_fn_28+0x320>
    330f:	mov    eax,0x6
    3314:	mov    QWORD PTR [rsp+0x30],rax
    3319:	cmp    rcx,0x6
    331d:	je     3513 <botlish_fn_28+0x2f3>
    3323:	lea    rcx,[rsp+0x20]
    3328:	mov    rdx,r12
    332b:	mov    rsi,r14
    332e:	mov    rdi,rbx
    3331:	call   3336 <botlish_fn_28+0x116>
			3332: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    3336:	mov    rsi,rax
    3339:	mov    r15,rax
    333c:	test   rax,rsi
    333f:	je     336d <botlish_fn_28+0x14d>
    3345:	mov    rdx,QWORD PTR [rsp+0x20]
    334a:	mov    QWORD PTR [rsp+0x40],rdx
    334f:	mov    rcx,QWORD PTR [rsp+0x28]
    3354:	mov    QWORD PTR [rsp+0x38],rcx
    3359:	mov    rsi,r15
    335c:	mov    rdi,rbx
    335f:	call   3364 <botlish_fn_28+0x144>
			3360: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    3364:	test   rax,rax
    3367:	jne    3395 <botlish_fn_28+0x175>
    336d:	xor    rax,rax
    3370:	mov    rbx,QWORD PTR [rsp+0x50]
    3375:	mov    r12,QWORD PTR [rsp+0x58]
    337a:	mov    r13,QWORD PTR [rsp+0x60]
    337f:	mov    r14,QWORD PTR [rsp+0x68]
    3384:	mov    r15,QWORD PTR [rsp+0x70]
    3389:	add    rsp,0x80
    3390:	mov    rsp,rbp
    3393:	pop    rbp
    3394:	ret
    3395:	cmp    rax,0x6
    3399:	je     3494 <botlish_fn_28+0x274>
    339f:	mov    rax,QWORD PTR [rbx+0x10]
    33a3:	mov    r8,QWORD PTR [rax+0x128]
    33aa:	mov    rcx,QWORD PTR [rsp+0x38]
    33af:	mov    rdx,QWORD PTR [rsp+0x40]
    33b4:	mov    rsi,r15
    33b7:	mov    rdi,rbx
    33ba:	call   33bf <botlish_fn_28+0x19f>
			33bb: R_X86_64_PLT32	rt_str_region_eq-0x4
    33bf:	cmp    rax,0x6
    33c3:	je     348a <botlish_fn_28+0x26a>
    33c9:	mov    rax,QWORD PTR [rbx+0x10]
    33cd:	mov    r8,QWORD PTR [rax+0x130]
    33d4:	mov    rcx,QWORD PTR [rsp+0x38]
    33d9:	mov    rdx,QWORD PTR [rsp+0x40]
    33de:	mov    rsi,r15
    33e1:	mov    rdi,rbx
    33e4:	call   33e9 <botlish_fn_28+0x1c9>
			33e5: R_X86_64_PLT32	rt_str_region_eq-0x4
    33e9:	cmp    rax,0x6
    33ed:	je     3480 <botlish_fn_28+0x260>
    33f3:	mov    rax,QWORD PTR [rbx+0x10]
    33f7:	mov    r8,QWORD PTR [rax+0xd0]
    33fe:	mov    rcx,QWORD PTR [rsp+0x38]
    3403:	mov    rdx,QWORD PTR [rsp+0x40]
    3408:	mov    rsi,r15
    340b:	mov    rdi,rbx
    340e:	call   3413 <botlish_fn_28+0x1f3>
			340f: R_X86_64_PLT32	rt_str_region_eq-0x4
    3413:	cmp    rax,0x6
    3417:	je     3476 <botlish_fn_28+0x256>
    341d:	mov    rax,QWORD PTR [rbx+0x10]
    3421:	mov    r8,QWORD PTR [rax+0x118]
    3428:	mov    rcx,QWORD PTR [rsp+0x38]
    342d:	mov    rdx,QWORD PTR [rsp+0x40]
    3432:	mov    rsi,r15
    3435:	mov    rdi,rbx
    3438:	call   343d <botlish_fn_28+0x21d>
			3439: R_X86_64_PLT32	rt_str_region_eq-0x4
    343d:	cmp    rax,0x6
    3441:	je     346c <botlish_fn_28+0x24c>
    3447:	mov    rax,QWORD PTR [rbx+0x10]
    344b:	mov    r8,QWORD PTR [rax+0x138]
    3452:	mov    rcx,QWORD PTR [rsp+0x38]
    3457:	mov    rdx,QWORD PTR [rsp+0x40]
    345c:	mov    rsi,r15
    345f:	mov    rdi,rbx
    3462:	call   3467 <botlish_fn_28+0x247>
			3463: R_X86_64_PLT32	rt_str_region_eq-0x4
    3467:	jmp    3499 <botlish_fn_28+0x279>
    346c:	mov    rax,QWORD PTR [rsp+0x30]
    3471:	jmp    3499 <botlish_fn_28+0x279>
    3476:	mov    rax,QWORD PTR [rsp+0x30]
    347b:	jmp    3499 <botlish_fn_28+0x279>
    3480:	mov    rax,QWORD PTR [rsp+0x30]
    3485:	jmp    3499 <botlish_fn_28+0x279>
    348a:	mov    rax,QWORD PTR [rsp+0x30]
    348f:	jmp    3499 <botlish_fn_28+0x279>
    3494:	mov    rax,QWORD PTR [rsp+0x30]
    3499:	cmp    rax,0x6
    349d:	je     34ab <botlish_fn_28+0x28b>
    34a3:	mov    rax,r14
    34a6:	jmp    3516 <botlish_fn_28+0x2f6>
    34ab:	mov    QWORD PTR [rsp+0x18],0x3
    34b4:	mov    rsi,r14
    34b7:	test   rsi,0x1
    34be:	je     34e4 <botlish_fn_28+0x2c4>
    34c4:	mov    rsi,r14
    34c7:	mov    rax,rsi
    34ca:	add    rax,0x2
    34ce:	seto   cl
    34d1:	test   cl,cl
    34d3:	jne    34e4 <botlish_fn_28+0x2c4>
    34d9:	mov    rsi,rax
    34dc:	mov    r14,rax
    34df:	jmp    34fa <botlish_fn_28+0x2da>
    34e4:	mov    edx,0x3
    34e9:	mov    rsi,r14
    34ec:	mov    rdi,rbx
    34ef:	call   34f4 <botlish_fn_28+0x2d4>
			34f0: R_X86_64_PLT32	rt_int_add-0x4
    34f4:	mov    rsi,rax
    34f7:	mov    r14,rax
    34fa:	mov    QWORD PTR [rsp],rsi
    34fe:	mov    QWORD PTR [rsp+0x8],r13
    3503:	mov    QWORD PTR [rsp+0x10],r12
    3508:	mov    rax,rbx
    350b:	mov    rdx,r13
    350e:	jmp    3264 <botlish_fn_28+0x44>
    3513:	mov    rax,r14
    3516:	mov    rbx,QWORD PTR [rsp+0x50]
    351b:	mov    r12,QWORD PTR [rsp+0x58]
    3520:	mov    r13,QWORD PTR [rsp+0x60]
    3525:	mov    r14,QWORD PTR [rsp+0x68]
    352a:	mov    r15,QWORD PTR [rsp+0x70]
    352f:	add    rsp,0x80
    3536:	mov    rsp,rbp
    3539:	pop    rbp
    353a:	ret
    353b:	add    BYTE PTR [rax],al
    353d:	add    BYTE PTR [rax],al
    353f:	add    BYTE PTR [rsi],al
    3541:	add    BYTE PTR [rax],al
    3543:	add    BYTE PTR [rax],al
    3545:	add    BYTE PTR [rax],al
	...

0000000000003548 <botlish_entry_28: scan_local<generic>>:
    3548:	push   rbp
    3549:	mov    rbp,rsp
    354c:	mov    rsi,QWORD PTR [rdx]
    354f:	mov    r8,QWORD PTR [rdx+0x8]
    3553:	mov    rcx,QWORD PTR [rdx+0x10]
    3557:	mov    rdx,r8
    355a:	call   355f <botlish_entry_28+0x17>
			355b: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    355f:	mov    rsp,rbp
    3562:	pop    rbp
    3563:	ret
    3564:	add    BYTE PTR [rax],al
	...

0000000000003568 <botlish_fn_29: scan_label<generic>>:
    3568:	push   rbp
    3569:	mov    rbp,rsp
    356c:	sub    rsp,0x80
    3573:	mov    QWORD PTR [rsp+0x50],rbx
    3578:	mov    QWORD PTR [rsp+0x58],r12
    357d:	mov    QWORD PTR [rsp+0x60],r13
    3582:	mov    QWORD PTR [rsp+0x68],r14
    3587:	mov    QWORD PTR [rsp+0x70],r15
    358c:	mov    QWORD PTR [rsp+0x18],0x0
    3595:	mov    QWORD PTR [rsp],rsi
    3599:	mov    r14,rsi
    359c:	mov    QWORD PTR [rsp+0x8],rdx
    35a1:	mov    QWORD PTR [rsp+0x10],rcx
    35a6:	mov    r12,rcx
    35a9:	mov    r11d,0x1
    35af:	mov    rsi,r14
    35b2:	test   rsi,0x1
    35b9:	jne    35d9 <botlish_fn_29+0x71>
    35bf:	xor    r11d,r11d
    35c2:	test   rsi,0x7
    35c9:	jne    35d9 <botlish_fn_29+0x71>
    35cf:	movzx  rax,BYTE PTR [rsi]
    35d3:	cmp    al,0x1
    35d5:	sete   r11b
    35d9:	test   r11b,r11b
    35dc:	jne    35fa <botlish_fn_29+0x92>
    35e2:	mov    rax,QWORD PTR [rdi+0x10]
    35e6:	mov    rcx,QWORD PTR [rax+0xc8]
    35ed:	xor    rdx,rdx
    35f0:	call   35f5 <botlish_fn_29+0x8d>
			35f1: R_X86_64_PLT32	rt_type_error-0x4
    35f5:	jmp    36a6 <botlish_fn_29+0x13e>
    35fa:	mov    r13,rdx
    35fd:	mov    rax,rsi
    3600:	and    rax,r13
    3603:	mov    r14,rsi
    3606:	test   rax,0x1
    360c:	jne    3635 <botlish_fn_29+0xcd>
    3612:	mov    rbx,rdi
    3615:	mov    rdx,r13
    3618:	mov    rsi,r14
    361b:	call   3620 <botlish_fn_29+0xb8>
			361c: R_X86_64_PLT32	rt_int_cmp-0x4
    3620:	mov    ecx,0x2
    3625:	test   rax,rax
    3628:	cmovge rcx,QWORD PTR [rip+0x178]        # 37a8 <botlish_fn_29+0x240>
    3630:	jmp    364b <botlish_fn_29+0xe3>
    3635:	mov    rbx,rdi
    3638:	mov    ecx,0x2
    363d:	mov    rsi,r14
    3640:	cmp    rsi,r13
    3643:	cmovge rcx,QWORD PTR [rip+0x15d]        # 37a8 <botlish_fn_29+0x240>
    364b:	mov    eax,0x6
    3650:	mov    QWORD PTR [rsp+0x30],rax
    3655:	cmp    rcx,0x6
    3659:	je     377c <botlish_fn_29+0x214>
    365f:	lea    rcx,[rsp+0x20]
    3664:	mov    rdx,r12
    3667:	mov    rsi,r14
    366a:	mov    rdi,rbx
    366d:	call   3672 <botlish_fn_29+0x10a>
			366e: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    3672:	test   rax,rax
    3675:	mov    r15,rax
    3678:	je     36a6 <botlish_fn_29+0x13e>
    367e:	mov    rdx,QWORD PTR [rsp+0x20]
    3683:	mov    QWORD PTR [rsp+0x40],rdx
    3688:	mov    rcx,QWORD PTR [rsp+0x28]
    368d:	mov    QWORD PTR [rsp+0x38],rcx
    3692:	mov    rsi,r15
    3695:	mov    rdi,rbx
    3698:	call   369d <botlish_fn_29+0x135>
			3699: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    369d:	test   rax,rax
    36a0:	jne    36ce <botlish_fn_29+0x166>
    36a6:	xor    rax,rax
    36a9:	mov    rbx,QWORD PTR [rsp+0x50]
    36ae:	mov    r12,QWORD PTR [rsp+0x58]
    36b3:	mov    r13,QWORD PTR [rsp+0x60]
    36b8:	mov    r14,QWORD PTR [rsp+0x68]
    36bd:	mov    r15,QWORD PTR [rsp+0x70]
    36c2:	add    rsp,0x80
    36c9:	mov    rsp,rbp
    36cc:	pop    rbp
    36cd:	ret
    36ce:	cmp    rax,0x6
    36d2:	je     36fd <botlish_fn_29+0x195>
    36d8:	mov    r11,QWORD PTR [rbx+0x10]
    36dc:	mov    r8,QWORD PTR [r11+0x138]
    36e3:	mov    rcx,QWORD PTR [rsp+0x38]
    36e8:	mov    rdx,QWORD PTR [rsp+0x40]
    36ed:	mov    rsi,r15
    36f0:	mov    rdi,rbx
    36f3:	call   36f8 <botlish_fn_29+0x190>
			36f4: R_X86_64_PLT32	rt_str_region_eq-0x4
    36f8:	jmp    3702 <botlish_fn_29+0x19a>
    36fd:	mov    rax,QWORD PTR [rsp+0x30]
    3702:	cmp    rax,0x6
    3706:	je     3714 <botlish_fn_29+0x1ac>
    370c:	mov    rax,r14
    370f:	jmp    377f <botlish_fn_29+0x217>
    3714:	mov    QWORD PTR [rsp+0x18],0x3
    371d:	mov    rsi,r14
    3720:	test   rsi,0x1
    3727:	je     374d <botlish_fn_29+0x1e5>
    372d:	mov    rsi,r14
    3730:	mov    rax,rsi
    3733:	add    rax,0x2
    3737:	seto   cl
    373a:	test   cl,cl
    373c:	jne    374d <botlish_fn_29+0x1e5>
    3742:	mov    rsi,rax
    3745:	mov    r14,rax
    3748:	jmp    3763 <botlish_fn_29+0x1fb>
    374d:	mov    edx,0x3
    3752:	mov    rsi,r14
    3755:	mov    rdi,rbx
    3758:	call   375d <botlish_fn_29+0x1f5>
			3759: R_X86_64_PLT32	rt_int_add-0x4
    375d:	mov    rsi,rax
    3760:	mov    r14,rax
    3763:	mov    QWORD PTR [rsp],rsi
    3767:	mov    QWORD PTR [rsp+0x8],r13
    376c:	mov    QWORD PTR [rsp+0x10],r12
    3771:	mov    rdx,r13
    3774:	mov    rdi,rbx
    3777:	jmp    35a9 <botlish_fn_29+0x41>
    377c:	mov    rax,r14
    377f:	mov    rbx,QWORD PTR [rsp+0x50]
    3784:	mov    r12,QWORD PTR [rsp+0x58]
    3789:	mov    r13,QWORD PTR [rsp+0x60]
    378e:	mov    r14,QWORD PTR [rsp+0x68]
    3793:	mov    r15,QWORD PTR [rsp+0x70]
    3798:	add    rsp,0x80
    379f:	mov    rsp,rbp
    37a2:	pop    rbp
    37a3:	ret
    37a4:	add    BYTE PTR [rax],al
    37a6:	add    BYTE PTR [rax],al
    37a8:	(bad)
    37a9:	add    BYTE PTR [rax],al
    37ab:	add    BYTE PTR [rax],al
    37ad:	add    BYTE PTR [rax],al
	...

00000000000037b0 <botlish_entry_29: scan_label<generic>>:
    37b0:	push   rbp
    37b1:	mov    rbp,rsp
    37b4:	mov    rsi,QWORD PTR [rdx]
    37b7:	mov    r8,QWORD PTR [rdx+0x8]
    37bb:	mov    rcx,QWORD PTR [rdx+0x10]
    37bf:	mov    rdx,r8
    37c2:	call   37c7 <botlish_entry_29+0x17>
			37c3: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_label<generic>
    37c7:	mov    rsp,rbp
    37ca:	pop    rbp
    37cb:	ret
    37cc:	add    BYTE PTR [rax],al
	...

00000000000037d0 <botlish_fn_30: scan_alpha<generic>>:
    37d0:	push   rbp
    37d1:	mov    rbp,rsp
    37d4:	sub    rsp,0x50
    37d8:	mov    QWORD PTR [rsp+0x30],rbx
    37dd:	mov    QWORD PTR [rsp+0x38],r12
    37e2:	mov    QWORD PTR [rsp+0x40],r13
    37e7:	mov    QWORD PTR [rsp+0x48],r14
    37ec:	mov    r14,rdi
    37ef:	mov    QWORD PTR [rsp+0x18],0x0
    37f8:	mov    QWORD PTR [rsp],rsi
    37fc:	mov    r13,rsi
    37ff:	mov    QWORD PTR [rsp+0x8],rdx
    3804:	mov    r12,rdx
    3807:	mov    QWORD PTR [rsp+0x10],rcx
    380c:	mov    rbx,rcx
    380f:	mov    r11d,0x1
    3815:	mov    rsi,r13
    3818:	test   rsi,0x1
    381f:	jne    383f <botlish_fn_30+0x6f>
    3825:	xor    r11d,r11d
    3828:	test   rsi,0x7
    382f:	jne    383f <botlish_fn_30+0x6f>
    3835:	movzx  rax,BYTE PTR [rsi]
    3839:	cmp    al,0x1
    383b:	sete   r11b
    383f:	test   r11b,r11b
    3842:	jne    3863 <botlish_fn_30+0x93>
    3848:	mov    rdi,r14
    384b:	mov    rax,QWORD PTR [rdi+0x10]
    384f:	mov    rcx,QWORD PTR [rax+0xc8]
    3856:	xor    rdx,rdx
    3859:	call   385e <botlish_fn_30+0x8e>
			385a: R_X86_64_PLT32	rt_type_error-0x4
    385e:	jmp    38f2 <botlish_fn_30+0x122>
    3863:	mov    rax,rsi
    3866:	and    rax,r12
    3869:	mov    r13,rsi
    386c:	test   rax,0x1
    3872:	jne    389b <botlish_fn_30+0xcb>
    3878:	mov    rdx,r12
    387b:	mov    rsi,r13
    387e:	mov    rdi,r14
    3881:	call   3886 <botlish_fn_30+0xb6>
			3882: R_X86_64_PLT32	rt_int_cmp-0x4
    3886:	mov    ecx,0x2
    388b:	test   rax,rax
    388e:	cmovge rcx,QWORD PTR [rip+0x112]        # 39a8 <botlish_fn_30+0x1d8>
    3896:	jmp    38ae <botlish_fn_30+0xde>
    389b:	mov    ecx,0x2
    38a0:	mov    rsi,r13
    38a3:	cmp    rsi,r12
    38a6:	cmovge rcx,QWORD PTR [rip+0xfa]        # 39a8 <botlish_fn_30+0x1d8>
    38ae:	cmp    rcx,0x6
    38b2:	je     3986 <botlish_fn_30+0x1b6>
    38b8:	lea    rcx,[rsp+0x20]
    38bd:	mov    rdx,rbx
    38c0:	mov    rsi,r13
    38c3:	mov    rdi,r14
    38c6:	call   38cb <botlish_fn_30+0xfb>
			38c7: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    38cb:	test   rax,rax
    38ce:	mov    rsi,rax
    38d1:	je     38f2 <botlish_fn_30+0x122>
    38d7:	mov    rdx,QWORD PTR [rsp+0x20]
    38dc:	mov    rcx,QWORD PTR [rsp+0x28]
    38e1:	mov    rdi,r14
    38e4:	call   38e9 <botlish_fn_30+0x119>
			38e5: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    38e9:	test   rax,rax
    38ec:	jne    3912 <botlish_fn_30+0x142>
    38f2:	xor    rax,rax
    38f5:	mov    rbx,QWORD PTR [rsp+0x30]
    38fa:	mov    r12,QWORD PTR [rsp+0x38]
    38ff:	mov    r13,QWORD PTR [rsp+0x40]
    3904:	mov    r14,QWORD PTR [rsp+0x48]
    3909:	add    rsp,0x50
    390d:	mov    rsp,rbp
    3910:	pop    rbp
    3911:	ret
    3912:	cmp    rax,0x6
    3916:	je     3924 <botlish_fn_30+0x154>
    391c:	mov    rax,r13
    391f:	jmp    3989 <botlish_fn_30+0x1b9>
    3924:	mov    QWORD PTR [rsp+0x18],0x3
    392d:	mov    rsi,r13
    3930:	test   rsi,0x1
    3937:	je     395d <botlish_fn_30+0x18d>
    393d:	mov    rsi,r13
    3940:	mov    r11,rsi
    3943:	add    r11,0x2
    3947:	seto   al
    394a:	test   al,al
    394c:	jne    395d <botlish_fn_30+0x18d>
    3952:	mov    rsi,r11
    3955:	mov    r13,r11
    3958:	jmp    3973 <botlish_fn_30+0x1a3>
    395d:	mov    edx,0x3
    3962:	mov    rsi,r13
    3965:	mov    rdi,r14
    3968:	call   396d <botlish_fn_30+0x19d>
			3969: R_X86_64_PLT32	rt_int_add-0x4
    396d:	mov    rsi,rax
    3970:	mov    r13,rax
    3973:	mov    QWORD PTR [rsp],rsi
    3977:	mov    QWORD PTR [rsp+0x8],r12
    397c:	mov    QWORD PTR [rsp+0x10],rbx
    3981:	jmp    380f <botlish_fn_30+0x3f>
    3986:	mov    rax,r13
    3989:	mov    rbx,QWORD PTR [rsp+0x30]
    398e:	mov    r12,QWORD PTR [rsp+0x38]
    3993:	mov    r13,QWORD PTR [rsp+0x40]
    3998:	mov    r14,QWORD PTR [rsp+0x48]
    399d:	add    rsp,0x50
    39a1:	mov    rsp,rbp
    39a4:	pop    rbp
    39a5:	ret
    39a6:	add    BYTE PTR [rax],al
    39a8:	(bad)
    39a9:	add    BYTE PTR [rax],al
    39ab:	add    BYTE PTR [rax],al
    39ad:	add    BYTE PTR [rax],al
	...

00000000000039b0 <botlish_entry_30: scan_alpha<generic>>:
    39b0:	push   rbp
    39b1:	mov    rbp,rsp
    39b4:	mov    rsi,QWORD PTR [rdx]
    39b7:	mov    r8,QWORD PTR [rdx+0x8]
    39bb:	mov    rcx,QWORD PTR [rdx+0x10]
    39bf:	mov    rdx,r8
    39c2:	call   39c7 <botlish_entry_30+0x17>
			39c3: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_alpha<generic>
    39c7:	mov    rsp,rbp
    39ca:	pop    rbp
    39cb:	ret
    39cc:	add    BYTE PTR [rax],al
	...

00000000000039d0 <botlish_fn_31: tld_ok<generic>>:
    39d0:	push   rbp
    39d1:	mov    rbp,rsp
    39d4:	sub    rsp,0x40
    39d8:	mov    QWORD PTR [rsp+0x20],rbx
    39dd:	mov    QWORD PTR [rsp+0x28],r12
    39e2:	mov    QWORD PTR [rsp+0x30],r13
    39e7:	mov    QWORD PTR [rsp+0x38],r14
    39ec:	mov    rbx,rdi
    39ef:	mov    QWORD PTR [rsp],rsi
    39f3:	mov    r12,rsi
    39f6:	mov    QWORD PTR [rsp+0x8],rdx
    39fb:	mov    r14,rdx
    39fe:	mov    QWORD PTR [rsp+0x10],rcx
    3a03:	mov    rdx,r14
    3a06:	mov    rsi,r12
    3a09:	mov    rdi,rbx
    3a0c:	call   3a11 <botlish_fn_31+0x41>
			3a0d: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_alpha<generic>
    3a11:	mov    rsi,rax
    3a14:	mov    r13,rax
    3a17:	test   rax,rsi
    3a1a:	je     3add <botlish_fn_31+0x10d>
    3a20:	mov    rax,r13
    3a23:	mov    QWORD PTR [rsp+0x8],rax
    3a28:	mov    rdx,r14
    3a2b:	and    rax,rdx
    3a2e:	test   rax,0x1
    3a34:	jne    3a5d <botlish_fn_31+0x8d>
    3a3a:	mov    rsi,r13
    3a3d:	mov    rdi,rbx
    3a40:	call   3a45 <botlish_fn_31+0x75>
			3a41: R_X86_64_PLT32	rt_int_cmp-0x4
    3a45:	mov    ecx,0x2
    3a4a:	test   rax,rax
    3a4d:	cmove  rcx,QWORD PTR [rip+0x15b]        # 3bb0 <botlish_fn_31+0x1e0>
    3a55:	mov    rax,r13
    3a58:	jmp    3a70 <botlish_fn_31+0xa0>
    3a5d:	mov    ecx,0x2
    3a62:	mov    rax,r13
    3a65:	cmp    rax,rdx
    3a68:	cmove  rcx,QWORD PTR [rip+0x140]        # 3bb0 <botlish_fn_31+0x1e0>
    3a70:	cmp    rcx,0x6
    3a74:	je     3a87 <botlish_fn_31+0xb7>
    3a7a:	mov    ecx,0x2
    3a7f:	mov    rax,rcx
    3a82:	jmp    3b8f <botlish_fn_31+0x1bf>
    3a87:	mov    ecx,0x1
    3a8c:	mov    rsi,r12
    3a8f:	test   rsi,0x1
    3a96:	jne    3abc <botlish_fn_31+0xec>
    3a9c:	xor    ecx,ecx
    3a9e:	mov    rsi,r12
    3aa1:	test   rsi,0x7
    3aa8:	jne    3abc <botlish_fn_31+0xec>
    3aae:	mov    rsi,r12
    3ab1:	movzx  rcx,BYTE PTR [rsi]
    3ab5:	rex cmp cl,0x1
    3ab9:	sete   cl
    3abc:	test   cl,cl
    3abe:	jne    3afd <botlish_fn_31+0x12d>
    3ac4:	mov    rdi,rbx
    3ac7:	mov    rsi,QWORD PTR [rdi+0x10]
    3acb:	mov    rcx,QWORD PTR [rsi+0x138]
    3ad2:	xor    rdx,rdx
    3ad5:	mov    rsi,r12
    3ad8:	call   3add <botlish_fn_31+0x10d>
			3ad9: R_X86_64_PLT32	rt_type_error-0x4
    3add:	xor    rax,rax
    3ae0:	mov    rbx,QWORD PTR [rsp+0x20]
    3ae5:	mov    r12,QWORD PTR [rsp+0x28]
    3aea:	mov    r13,QWORD PTR [rsp+0x30]
    3aef:	mov    r14,QWORD PTR [rsp+0x38]
    3af4:	add    rsp,0x40
    3af8:	mov    rsp,rbp
    3afb:	pop    rbp
    3afc:	ret
    3afd:	mov    rsi,r12
    3b00:	mov    rdi,rax
    3b03:	and    rdi,rsi
    3b06:	test   rdi,0x1
    3b0d:	jne    3b1e <botlish_fn_31+0x14e>
    3b13:	mov    rdx,r12
    3b16:	mov    rsi,rax
    3b19:	jmp    3b41 <botlish_fn_31+0x171>
    3b1e:	mov    rsi,r12
    3b21:	mov    r8,rax
    3b24:	sub    r8,rsi
    3b27:	mov    r13,rax
    3b2a:	seto   r10b
    3b2e:	lea    rsi,[r8+0x1]
    3b32:	test   r10b,r10b
    3b35:	je     3b4c <botlish_fn_31+0x17c>
    3b3b:	mov    rdx,r12
    3b3e:	mov    rsi,r13
    3b41:	mov    rdi,rbx
    3b44:	call   3b49 <botlish_fn_31+0x179>
			3b45: R_X86_64_PLT32	rt_int_sub-0x4
    3b49:	mov    rsi,rax
    3b4c:	test   rsi,0x1
    3b53:	jne    3b7e <botlish_fn_31+0x1ae>
    3b59:	mov    edx,0x5
    3b5e:	mov    rdi,rbx
    3b61:	call   3b66 <botlish_fn_31+0x196>
			3b62: R_X86_64_PLT32	rt_int_cmp-0x4
    3b66:	mov    ecx,0x2
    3b6b:	test   rax,rax
    3b6e:	mov    rax,rcx
    3b71:	cmovge rax,QWORD PTR [rip+0x37]        # 3bb0 <botlish_fn_31+0x1e0>
    3b79:	jmp    3b8f <botlish_fn_31+0x1bf>
    3b7e:	mov    eax,0x2
    3b83:	cmp    rsi,0x5
    3b87:	cmovge rax,QWORD PTR [rip+0x21]        # 3bb0 <botlish_fn_31+0x1e0>
    3b8f:	mov    rbx,QWORD PTR [rsp+0x20]
    3b94:	mov    r12,QWORD PTR [rsp+0x28]
    3b99:	mov    r13,QWORD PTR [rsp+0x30]
    3b9e:	mov    r14,QWORD PTR [rsp+0x38]
    3ba3:	add    rsp,0x40
    3ba7:	mov    rsp,rbp
    3baa:	pop    rbp
    3bab:	ret
    3bac:	add    BYTE PTR [rax],al
    3bae:	add    BYTE PTR [rax],al
    3bb0:	(bad)
    3bb1:	add    BYTE PTR [rax],al
    3bb3:	add    BYTE PTR [rax],al
    3bb5:	add    BYTE PTR [rax],al
	...

0000000000003bb8 <botlish_entry_31: tld_ok<generic>>:
    3bb8:	push   rbp
    3bb9:	mov    rbp,rsp
    3bbc:	mov    rsi,QWORD PTR [rdx]
    3bbf:	mov    r8,QWORD PTR [rdx+0x8]
    3bc3:	mov    rcx,QWORD PTR [rdx+0x10]
    3bc7:	mov    rdx,r8
    3bca:	call   3bcf <botlish_entry_31+0x17>
			3bcb: R_X86_64_PLT32	botlish_fn_31-0x4 ; tld_ok<generic>
    3bcf:	mov    rsp,rbp
    3bd2:	pop    rbp
    3bd3:	ret
    3bd4:	add    BYTE PTR [rax],al
	...

0000000000003bd8 <botlish_fn_32: domain_loop<generic>>:
    3bd8:	push   rbp
    3bd9:	mov    rbp,rsp
    3bdc:	sub    rsp,0x70
    3be0:	mov    QWORD PTR [rsp+0x40],rbx
    3be5:	mov    QWORD PTR [rsp+0x48],r12
    3bea:	mov    QWORD PTR [rsp+0x50],r13
    3bef:	mov    QWORD PTR [rsp+0x58],r14
    3bf4:	mov    QWORD PTR [rsp+0x60],r15
    3bf9:	mov    QWORD PTR [rsp+0x18],0x0
    3c02:	mov    QWORD PTR [rsp],rsi
    3c06:	mov    QWORD PTR [rsp+0x8],rdx
    3c0b:	mov    QWORD PTR [rsp+0x10],rcx
    3c10:	lea    rbx,[rsp+0x20]
    3c15:	mov    r12,rdi
    3c18:	mov    r13,rcx
    3c1b:	mov    r14,rdx
    3c1e:	mov    QWORD PTR [rsp+0x30],rsi
    3c23:	mov    rcx,r13
    3c26:	mov    rdx,r14
    3c29:	mov    rsi,QWORD PTR [rsp+0x30]
    3c2e:	mov    rdi,r12
    3c31:	call   3c36 <botlish_fn_32+0x5e>
			3c32: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_label<generic>
    3c36:	mov    rcx,rax
    3c39:	mov    r15,rax
    3c3c:	test   rax,rcx
    3c3f:	je     3d8f <botlish_fn_32+0x1b7>
    3c45:	mov    rax,r15
    3c48:	mov    QWORD PTR [rsp],rax
    3c4c:	mov    rdx,QWORD PTR [rsp+0x30]
    3c51:	and    rax,rdx
    3c54:	test   rax,0x1
    3c5a:	jne    3c79 <botlish_fn_32+0xa1>
    3c60:	mov    rsi,r15
    3c63:	mov    rdi,r12
    3c66:	call   3c6b <botlish_fn_32+0x93>
			3c67: R_X86_64_PLT32	rt_value_eq-0x4
    3c6b:	test   rax,rax
    3c6e:	je     3d8f <botlish_fn_32+0x1b7>
    3c74:	jmp    3c89 <botlish_fn_32+0xb1>
    3c79:	mov    eax,0x2
    3c7e:	cmp    r15,rdx
    3c81:	cmove  rax,QWORD PTR [rip+0x187]        # 3e10 <botlish_fn_32+0x238>
    3c89:	cmp    rax,0x6
    3c8d:	je     3de5 <botlish_fn_32+0x20d>
    3c93:	mov    rax,r15
    3c96:	and    rax,r14
    3c99:	test   rax,0x1
    3c9f:	jne    3cc8 <botlish_fn_32+0xf0>
    3ca5:	mov    rdx,r14
    3ca8:	mov    rsi,r15
    3cab:	mov    rdi,r12
    3cae:	call   3cb3 <botlish_fn_32+0xdb>
			3caf: R_X86_64_PLT32	rt_int_cmp-0x4
    3cb3:	mov    ecx,0x2
    3cb8:	test   rax,rax
    3cbb:	cmovge rcx,QWORD PTR [rip+0x14d]        # 3e10 <botlish_fn_32+0x238>
    3cc3:	jmp    3cd8 <botlish_fn_32+0x100>
    3cc8:	mov    ecx,0x2
    3ccd:	cmp    r15,r14
    3cd0:	cmovge rcx,QWORD PTR [rip+0x138]        # 3e10 <botlish_fn_32+0x238>
    3cd8:	cmp    rcx,0x6
    3cdc:	je     3dd6 <botlish_fn_32+0x1fe>
    3ce2:	mov    rcx,rbx
    3ce5:	mov    rdx,r13
    3ce8:	mov    rsi,r15
    3ceb:	mov    rdi,r12
    3cee:	call   3cf3 <botlish_fn_32+0x11b>
			3cef: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    3cf3:	test   rax,rax
    3cf6:	je     3d8f <botlish_fn_32+0x1b7>
    3cfc:	mov    rdx,QWORD PTR [rsp+0x20]
    3d01:	mov    rcx,QWORD PTR [rsp+0x28]
    3d06:	mov    rsi,QWORD PTR [r12+0x10]
    3d0b:	mov    r8,QWORD PTR [rsi+0x128]
    3d12:	mov    rsi,rax
    3d15:	mov    rdi,r12
    3d18:	call   3d1d <botlish_fn_32+0x145>
			3d19: R_X86_64_PLT32	rt_str_region_eq-0x4
    3d1d:	cmp    rax,0x6
    3d21:	je     3d33 <botlish_fn_32+0x15b>
    3d27:	mov    r14,0xffffffffffffffff
    3d2e:	jmp    3ddd <botlish_fn_32+0x205>
    3d33:	mov    QWORD PTR [rsp+0x18],0x3
    3d3c:	test   r15,0x1
    3d43:	je     3d5b <botlish_fn_32+0x183>
    3d49:	mov    rdx,r15
    3d4c:	add    rdx,0x2
    3d50:	seto   al
    3d53:	test   al,al
    3d55:	je     3d6e <botlish_fn_32+0x196>
    3d5b:	mov    edx,0x3
    3d60:	mov    rsi,r15
    3d63:	mov    rdi,r12
    3d66:	call   3d6b <botlish_fn_32+0x193>
			3d67: R_X86_64_PLT32	rt_int_add-0x4
    3d6b:	mov    rdx,rax
    3d6e:	mov    QWORD PTR [rsp],rdx
    3d72:	mov    r15,rdx
    3d75:	mov    rcx,r13
    3d78:	mov    rdx,r14
    3d7b:	mov    rsi,r15
    3d7e:	mov    rdi,r12
    3d81:	call   3d86 <botlish_fn_32+0x1ae>
			3d82: R_X86_64_PLT32	botlish_fn_31-0x4 ; tld_ok<generic>
    3d86:	test   rax,rax
    3d89:	jne    3db4 <botlish_fn_32+0x1dc>
    3d8f:	xor    rax,rax
    3d92:	mov    rbx,QWORD PTR [rsp+0x40]
    3d97:	mov    r12,QWORD PTR [rsp+0x48]
    3d9c:	mov    r13,QWORD PTR [rsp+0x50]
    3da1:	mov    r14,QWORD PTR [rsp+0x58]
    3da6:	mov    r15,QWORD PTR [rsp+0x60]
    3dab:	add    rsp,0x70
    3daf:	mov    rsp,rbp
    3db2:	pop    rbp
    3db3:	ret
    3db4:	cmp    rax,0x6
    3db8:	je     3ddd <botlish_fn_32+0x205>
    3dbe:	mov    QWORD PTR [rsp],r15
    3dc2:	mov    QWORD PTR [rsp+0x8],r14
    3dc7:	mov    QWORD PTR [rsp+0x10],r13
    3dcc:	mov    QWORD PTR [rsp+0x30],r15
    3dd1:	jmp    3c23 <botlish_fn_32+0x4b>
    3dd6:	mov    r14,0xffffffffffffffff
    3ddd:	mov    rax,r14
    3de0:	jmp    3dec <botlish_fn_32+0x214>
    3de5:	mov    rax,0xffffffffffffffff
    3dec:	mov    rbx,QWORD PTR [rsp+0x40]
    3df1:	mov    r12,QWORD PTR [rsp+0x48]
    3df6:	mov    r13,QWORD PTR [rsp+0x50]
    3dfb:	mov    r14,QWORD PTR [rsp+0x58]
    3e00:	mov    r15,QWORD PTR [rsp+0x60]
    3e05:	add    rsp,0x70
    3e09:	mov    rsp,rbp
    3e0c:	pop    rbp
    3e0d:	ret
    3e0e:	add    BYTE PTR [rax],al
    3e10:	(bad)
    3e11:	add    BYTE PTR [rax],al
    3e13:	add    BYTE PTR [rax],al
    3e15:	add    BYTE PTR [rax],al
	...

0000000000003e18 <botlish_entry_32: domain_loop<generic>>:
    3e18:	push   rbp
    3e19:	mov    rbp,rsp
    3e1c:	mov    rsi,QWORD PTR [rdx]
    3e1f:	mov    r8,QWORD PTR [rdx+0x8]
    3e23:	mov    rcx,QWORD PTR [rdx+0x10]
    3e27:	mov    rdx,r8
    3e2a:	call   3e2f <botlish_entry_32+0x17>
			3e2b: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    3e2f:	mov    rsp,rbp
    3e32:	pop    rbp
    3e33:	ret

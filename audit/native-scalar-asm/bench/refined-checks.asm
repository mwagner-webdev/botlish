; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 16843  (per function: 1172 39 337 625 74 74 74 125 125 190 125 214 484 864 525 1004 504 681 769 450 884 644 540 540 636 681 769 450 884 644 540 540 636)
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
     a0a:	mov    QWORD PTR [rsp+0x10],r13
     a0f:	mov    rbx,rdx
     a12:	mov    r12,rdi
     a15:	mov    r13,rsi
     a18:	mov    rsi,rbx
     a1b:	mov    rdi,r12
     a1e:	call   a23 <botlish_fn_9+0x2a>
			a1f: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
     a23:	cmp    rax,0x6
     a27:	je     a83 <botlish_fn_9+0x8a>
     a2d:	mov    rsi,r13
     a30:	mov    rax,QWORD PTR [rsi+0x20]
     a34:	mov    rsi,QWORD PTR [rax]
     a37:	mov    rdx,rbx
     a3a:	mov    rdi,r12
     a3d:	call   a42 <botlish_fn_9+0x49>
			a3e: R_X86_64_PLT32	rt_set_contains-0x4
     a42:	test   rax,rax
     a45:	jne    a65 <botlish_fn_9+0x6c>
     a4b:	xor    rax,rax
     a4e:	mov    rbx,QWORD PTR [rsp]
     a52:	mov    r12,QWORD PTR [rsp+0x8]
     a57:	mov    r13,QWORD PTR [rsp+0x10]
     a5c:	add    rsp,0x20
     a60:	mov    rsp,rbp
     a63:	pop    rbp
     a64:	ret
     a65:	cmp    rax,0x6
     a69:	je     a79 <botlish_fn_9+0x80>
     a6f:	mov    eax,0x2
     a74:	jmp    a88 <botlish_fn_9+0x8f>
     a79:	mov    eax,0x6
     a7e:	jmp    a88 <botlish_fn_9+0x8f>
     a83:	mov    eax,0x6
     a88:	mov    rbx,QWORD PTR [rsp]
     a8c:	mov    r12,QWORD PTR [rsp+0x8]
     a91:	mov    r13,QWORD PTR [rsp+0x10]
     a96:	add    rsp,0x20
     a9a:	mov    rsp,rbp
     a9d:	pop    rbp
     a9e:	ret

0000000000000a9f <botlish_entry_9: web::is_unreserved<generic>>:
     a9f:	push   rbp
     aa0:	mov    rbp,rsp
     aa3:	mov    rdx,QWORD PTR [rdx]
     aa6:	call   aab <botlish_entry_9+0xc>
			aa7: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_unreserved<generic>
     aab:	mov    rsp,rbp
     aae:	pop    rbp
     aaf:	ret

0000000000000ab0 <botlish_fn_10: web::uri_escape_text<generic>>:
     ab0:	push   rbp
     ab1:	mov    rbp,rsp
     ab4:	sub    rsp,0x30
     ab8:	mov    QWORD PTR [rsp],rdx
     abc:	mov    r10,rdx
     abf:	mov    edx,0x1
     ac4:	mov    QWORD PTR [rsp+0x8],0x1
     acd:	mov    rax,QWORD PTR [rdi+0x10]
     ad1:	mov    rcx,QWORD PTR [rax+0xa8]
     ad8:	mov    QWORD PTR [rsp+0x10],rcx
     add:	mov    rax,QWORD PTR [rsi+0x20]
     ae1:	mov    r8,QWORD PTR [rax+0x8]
     ae5:	mov    QWORD PTR [rsp+0x18],r8
     aea:	mov    rax,QWORD PTR [rsi+0x20]
     aee:	mov    r9,QWORD PTR [rax]
     af1:	mov    QWORD PTR [rsp+0x20],r9
     af6:	mov    rsi,r10
     af9:	call   afe <botlish_fn_10+0x4e>
			afa: R_X86_64_PLT32	botlish_fn_15-0x4 ; esc_from<generic>
     afe:	test   rax,rax
     b01:	jne    b13 <botlish_fn_10+0x63>
     b07:	xor    rax,rax
     b0a:	add    rsp,0x30
     b0e:	mov    rsp,rbp
     b11:	pop    rbp
     b12:	ret
     b13:	add    rsp,0x30
     b17:	mov    rsp,rbp
     b1a:	pop    rbp
     b1b:	ret

0000000000000b1c <botlish_entry_10: web::uri_escape_text<generic>>:
     b1c:	push   rbp
     b1d:	mov    rbp,rsp
     b20:	mov    rdx,QWORD PTR [rdx]
     b23:	call   b28 <botlish_entry_10+0xc>
			b24: R_X86_64_PLT32	botlish_fn_10-0x4 ; web::uri_escape_text<generic>
     b28:	mov    rsp,rbp
     b2b:	pop    rbp
     b2c:	ret

0000000000000b2d <botlish_fn_11: high_nibble<generic>>:
     b2d:	push   rbp
     b2e:	mov    rbp,rsp
     b31:	sub    rsp,0x20
     b35:	mov    QWORD PTR [rsp+0x10],rbx
     b3a:	mov    QWORD PTR [rsp],rsi
     b3e:	mov    QWORD PTR [rsp+0x8],0x1e1
     b47:	mov    r8d,0x1
     b4d:	test   rsi,0x1
     b54:	jne    b74 <botlish_fn_11+0x47>
     b5a:	xor    r8d,r8d
     b5d:	test   rsi,0x7
     b64:	jne    b74 <botlish_fn_11+0x47>
     b6a:	movzx  rax,BYTE PTR [rsi]
     b6e:	cmp    al,0x1
     b70:	sete   r8b
     b74:	test   r8b,r8b
     b77:	jne    ba4 <botlish_fn_11+0x77>
     b7d:	mov    rax,QWORD PTR [rdi+0x10]
     b81:	mov    rcx,QWORD PTR [rax+0xb0]
     b88:	xor    rbx,rbx
     b8b:	mov    rdx,rbx
     b8e:	call   b93 <botlish_fn_11+0x66>
			b8f: R_X86_64_PLT32	rt_type_error-0x4
     b93:	mov    rax,rbx
     b96:	mov    rbx,QWORD PTR [rsp+0x10]
     b9b:	add    rsp,0x20
     b9f:	mov    rsp,rbp
     ba2:	pop    rbp
     ba3:	ret
     ba4:	test   rsi,0x1
     bab:	jne    bc0 <botlish_fn_11+0x93>
     bb1:	mov    edx,0x1e1
     bb6:	call   bbb <botlish_fn_11+0x8e>
			bb7: R_X86_64_PLT32	rt_int_and-0x4
     bbb:	jmp    bca <botlish_fn_11+0x9d>
     bc0:	and    rsi,0x1e1
     bc7:	mov    rax,rsi
     bca:	sar    rax,0x5
     bce:	shl    rax,1
     bd1:	or     rax,0x1
     bd5:	mov    rbx,QWORD PTR [rsp+0x10]
     bda:	add    rsp,0x20
     bde:	mov    rsp,rbp
     be1:	pop    rbp
     be2:	ret

0000000000000be3 <botlish_entry_11: high_nibble<generic>>:
     be3:	push   rbp
     be4:	mov    rbp,rsp
     be7:	mov    rsi,QWORD PTR [rdx]
     bea:	call   bef <botlish_entry_11+0xc>
			beb: R_X86_64_PLT32	botlish_fn_11-0x4 ; high_nibble<generic>
     bef:	mov    rsp,rbp
     bf2:	pop    rbp
     bf3:	ret

0000000000000bf4 <botlish_fn_12: hex_pair<generic>>:
     bf4:	push   rbp
     bf5:	mov    rbp,rsp
     bf8:	sub    rsp,0x30
     bfc:	mov    QWORD PTR [rsp+0x10],rbx
     c01:	mov    QWORD PTR [rsp+0x18],r12
     c06:	mov    QWORD PTR [rsp+0x20],r13
     c0b:	mov    QWORD PTR [rsp+0x28],r14
     c10:	mov    r12,rdi
     c13:	mov    QWORD PTR [rsp],rsi
     c17:	mov    r13,rsi
     c1a:	mov    QWORD PTR [rsp+0x8],rdx
     c1f:	mov    rbx,rdx
     c22:	mov    rsi,r13
     c25:	mov    rdi,r12
     c28:	call   c2d <botlish_fn_12+0x39>
			c29: R_X86_64_PLT32	botlish_fn_11-0x4 ; high_nibble<generic>
     c2d:	test   rax,rax
     c30:	je     d5e <botlish_fn_12+0x16a>
     c36:	test   rax,0x1
     c3c:	jne    c4a <botlish_fn_12+0x56>
     c42:	mov    rdx,rax
     c45:	jmp    c60 <botlish_fn_12+0x6c>
     c4a:	mov    rdx,QWORD PTR [rbx+0x8]
     c4e:	mov    rcx,rax
     c51:	sar    rcx,1
     c54:	cmp    rcx,rdx
     c57:	jb     c7c <botlish_fn_12+0x88>
     c5d:	mov    rdx,rax
     c60:	mov    rsi,rbx
     c63:	mov    rdi,r12
     c66:	call   c6b <botlish_fn_12+0x77>
			c67: R_X86_64_PLT32	rt_list_get-0x4
     c6b:	test   rax,rax
     c6e:	je     d5e <botlish_fn_12+0x16a>
     c74:	mov    rsi,rax
     c77:	jmp    c84 <botlish_fn_12+0x90>
     c7c:	mov    rax,QWORD PTR [rbx+0x10]
     c80:	mov    rsi,QWORD PTR [rax+rcx*8]
     c84:	mov    QWORD PTR [rsp],rsi
     c88:	mov    r14,rsi
     c8b:	mov    ecx,0x1
     c90:	mov    rsi,r13
     c93:	test   rsi,0x1
     c9a:	jne    cb8 <botlish_fn_12+0xc4>
     ca0:	xor    ecx,ecx
     ca2:	test   rsi,0x7
     ca9:	jne    cb8 <botlish_fn_12+0xc4>
     caf:	movzx  rax,BYTE PTR [rsi]
     cb3:	cmp    al,0x1
     cb5:	sete   cl
     cb8:	test   cl,cl
     cba:	jne    cdb <botlish_fn_12+0xe7>
     cc0:	mov    rdi,r12
     cc3:	mov    rax,QWORD PTR [rdi+0x10]
     cc7:	mov    rcx,QWORD PTR [rax+0xb8]
     cce:	xor    rdx,rdx
     cd1:	call   cd6 <botlish_fn_12+0xe2>
			cd2: R_X86_64_PLT32	rt_type_error-0x4
     cd6:	jmp    d5e <botlish_fn_12+0x16a>
     cdb:	mov    edx,0x21
     ce0:	mov    rdi,r12
     ce3:	call   ce8 <botlish_fn_12+0xf4>
			ce4: R_X86_64_PLT32	rt_int_mod-0x4
     ce8:	test   rax,rax
     ceb:	je     d5e <botlish_fn_12+0x16a>
     cf1:	test   rax,0x1
     cf7:	jne    d08 <botlish_fn_12+0x114>
     cfd:	mov    rdx,rax
     d00:	mov    rsi,rbx
     d03:	jmp    d21 <botlish_fn_12+0x12d>
     d08:	mov    rdi,QWORD PTR [rbx+0x8]
     d0c:	mov    rsi,rax
     d0f:	sar    rsi,1
     d12:	mov    rdx,rax
     d15:	cmp    rsi,rdi
     d18:	jb     d3a <botlish_fn_12+0x146>
     d1e:	mov    rsi,rbx
     d21:	mov    rdi,r12
     d24:	call   d29 <botlish_fn_12+0x135>
			d25: R_X86_64_PLT32	rt_list_get-0x4
     d29:	test   rax,rax
     d2c:	je     d5e <botlish_fn_12+0x16a>
     d32:	mov    rdx,rax
     d35:	jmp    d45 <botlish_fn_12+0x151>
     d3a:	mov    rax,rbx
     d3d:	mov    rax,QWORD PTR [rax+0x10]
     d41:	mov    rdx,QWORD PTR [rax+rsi*8]
     d45:	mov    QWORD PTR [rsp+0x8],rdx
     d4a:	mov    rsi,r14
     d4d:	mov    rdi,r12
     d50:	call   d55 <botlish_fn_12+0x161>
			d51: R_X86_64_PLT32	rt_str_cat-0x4
     d55:	test   rax,rax
     d58:	jne    d7e <botlish_fn_12+0x18a>
     d5e:	xor    rax,rax
     d61:	mov    rbx,QWORD PTR [rsp+0x10]
     d66:	mov    r12,QWORD PTR [rsp+0x18]
     d6b:	mov    r13,QWORD PTR [rsp+0x20]
     d70:	mov    r14,QWORD PTR [rsp+0x28]
     d75:	add    rsp,0x30
     d79:	mov    rsp,rbp
     d7c:	pop    rbp
     d7d:	ret
     d7e:	mov    rbx,QWORD PTR [rsp+0x10]
     d83:	mov    r12,QWORD PTR [rsp+0x18]
     d88:	mov    r13,QWORD PTR [rsp+0x20]
     d8d:	mov    r14,QWORD PTR [rsp+0x28]
     d92:	add    rsp,0x30
     d96:	mov    rsp,rbp
     d99:	pop    rbp
     d9a:	ret

0000000000000d9b <botlish_entry_12: hex_pair<generic>>:
     d9b:	push   rbp
     d9c:	mov    rbp,rsp
     d9f:	mov    rsi,QWORD PTR [rdx]
     da2:	mov    rdx,QWORD PTR [rdx+0x8]
     da6:	call   dab <botlish_entry_12+0x10>
			da7: R_X86_64_PLT32	botlish_fn_12-0x4 ; hex_pair<generic>
     dab:	mov    rsp,rbp
     dae:	pop    rbp
     daf:	ret

0000000000000db0 <botlish_fn_13: esc_bytes<generic>>:
     db0:	push   rbp
     db1:	mov    rbp,rsp
     db4:	sub    rsp,0x70
     db8:	mov    QWORD PTR [rsp+0x40],rbx
     dbd:	mov    QWORD PTR [rsp+0x48],r12
     dc2:	mov    QWORD PTR [rsp+0x50],r13
     dc7:	mov    QWORD PTR [rsp+0x58],r14
     dcc:	mov    QWORD PTR [rsp+0x60],r15
     dd1:	mov    r13,rdi
     dd4:	mov    QWORD PTR [rsp+0x28],0x0
     ddd:	mov    QWORD PTR [rsp],rsi
     de1:	mov    QWORD PTR [rsp+0x8],rdx
     de6:	mov    QWORD PTR [rsp+0x10],rcx
     deb:	mov    QWORD PTR [rsp+0x18],r8
     df0:	mov    r12,r8
     df3:	mov    r14,rcx
     df6:	mov    r15,rdx
     df9:	xor    eax,eax
     dfb:	test   rsi,0x7
     e02:	jne    e13 <botlish_fn_13+0x63>
     e08:	movzx  r8,BYTE PTR [rsi]
     e0c:	cmp    r8b,0x3
     e10:	sete   al
     e13:	test   al,al
     e15:	jne    e38 <botlish_fn_13+0x88>
     e1b:	mov    rdi,r13
     e1e:	mov    rax,QWORD PTR [rdi+0x10]
     e22:	mov    rcx,QWORD PTR [rax+0xc0]
     e29:	mov    edx,0x4
     e2e:	call   e33 <botlish_fn_13+0x83>
			e2f: R_X86_64_PLT32	rt_type_error-0x4
     e33:	jmp    103e <botlish_fn_13+0x28e>
     e38:	mov    rbx,rsi
     e3b:	mov    rdi,r13
     e3e:	call   e43 <botlish_fn_13+0x93>
			e3f: R_X86_64_PLT32	rt_list_len-0x4
     e43:	mov    ecx,0x1
     e48:	mov    rsi,r15
     e4b:	test   rsi,0x1
     e52:	jne    e78 <botlish_fn_13+0xc8>
     e58:	xor    ecx,ecx
     e5a:	mov    rsi,r15
     e5d:	test   rsi,0x7
     e64:	jne    e78 <botlish_fn_13+0xc8>
     e6a:	mov    rsi,r15
     e6d:	movzx  rcx,BYTE PTR [rsi]
     e71:	rex cmp cl,0x1
     e75:	sete   cl
     e78:	test   cl,cl
     e7a:	jne    e9e <botlish_fn_13+0xee>
     e80:	mov    rdi,r13
     e83:	mov    rax,QWORD PTR [rdi+0x10]
     e87:	mov    rcx,QWORD PTR [rax+0xc8]
     e8e:	xor    rdx,rdx
     e91:	mov    rsi,r15
     e94:	call   e99 <botlish_fn_13+0xe9>
			e95: R_X86_64_PLT32	rt_type_error-0x4
     e99:	jmp    103e <botlish_fn_13+0x28e>
     e9e:	mov    rsi,r15
     ea1:	mov    rcx,rsi
     ea4:	and    rcx,rax
     ea7:	mov    rdx,rax
     eaa:	test   rcx,0x1
     eb1:	jne    ed7 <botlish_fn_13+0x127>
     eb7:	mov    rsi,r15
     eba:	mov    rdi,r13
     ebd:	call   ec2 <botlish_fn_13+0x112>
			ebe: R_X86_64_PLT32	rt_int_cmp-0x4
     ec2:	mov    ecx,0x2
     ec7:	test   rax,rax
     eca:	cmovge rcx,QWORD PTR [rip+0x1de]        # 10b0 <botlish_fn_13+0x300>
     ed2:	jmp    eea <botlish_fn_13+0x13a>
     ed7:	mov    ecx,0x2
     edc:	mov    rsi,r15
     edf:	cmp    rsi,rdx
     ee2:	cmovge rcx,QWORD PTR [rip+0x1c6]        # 10b0 <botlish_fn_13+0x300>
     eea:	cmp    rcx,0x6
     eee:	je     1089 <botlish_fn_13+0x2d9>
     ef4:	mov    QWORD PTR [rsp+0x20],0x3
     efd:	mov    rsi,r15
     f00:	test   rsi,0x1
     f07:	je     f22 <botlish_fn_13+0x172>
     f0d:	mov    rsi,r15
     f10:	mov    rax,rsi
     f13:	add    rax,0x2
     f17:	seto   cl
     f1a:	test   cl,cl
     f1c:	je     f32 <botlish_fn_13+0x182>
     f22:	mov    edx,0x3
     f27:	mov    rsi,r15
     f2a:	mov    rdi,r13
     f2d:	call   f32 <botlish_fn_13+0x182>
			f2e: R_X86_64_PLT32	rt_int_add-0x4
     f32:	mov    QWORD PTR [rsp+0x8],rax
     f37:	mov    rdi,r13
     f3a:	mov    QWORD PTR [rsp+0x30],rax
     f3f:	mov    rax,QWORD PTR [rdi+0x10]
     f43:	mov    rsi,QWORD PTR [rax+0xd0]
     f4a:	mov    QWORD PTR [rsp+0x20],rsi
     f4f:	mov    QWORD PTR [rsp+0x38],rsi
     f54:	mov    rsi,r15
     f57:	test   rsi,0x1
     f5e:	jne    f6c <botlish_fn_13+0x1bc>
     f64:	mov    rdx,r15
     f67:	jmp    f85 <botlish_fn_13+0x1d5>
     f6c:	mov    rcx,QWORD PTR [rbx+0x8]
     f70:	mov    rsi,r15
     f73:	mov    rax,rsi
     f76:	sar    rax,1
     f79:	cmp    rax,rcx
     f7c:	jb     fa1 <botlish_fn_13+0x1f1>
     f82:	mov    rdx,r15
     f85:	mov    rsi,rbx
     f88:	mov    rdi,r13
     f8b:	call   f90 <botlish_fn_13+0x1e0>
			f8c: R_X86_64_PLT32	rt_list_get-0x4
     f90:	test   rax,rax
     f93:	je     103e <botlish_fn_13+0x28e>
     f99:	mov    rsi,rax
     f9c:	jmp    fa9 <botlish_fn_13+0x1f9>
     fa1:	mov    rcx,QWORD PTR [rbx+0x10]
     fa5:	mov    rsi,QWORD PTR [rcx+rax*8]
     fa9:	mov    QWORD PTR [rsp+0x28],rsi
     fae:	mov    rdx,r12
     fb1:	mov    rdi,r13
     fb4:	call   fb9 <botlish_fn_13+0x209>
			fb5: R_X86_64_PLT32	botlish_fn_12-0x4 ; hex_pair<generic>
     fb9:	test   rax,rax
     fbc:	je     103e <botlish_fn_13+0x28e>
     fc2:	mov    QWORD PTR [rsp+0x28],rax
     fc7:	mov    rdx,rax
     fca:	mov    rsi,QWORD PTR [rsp+0x38]
     fcf:	mov    rdi,r13
     fd2:	call   fd7 <botlish_fn_13+0x227>
			fd3: R_X86_64_PLT32	rt_str_cat-0x4
     fd7:	test   rax,rax
     fda:	je     103e <botlish_fn_13+0x28e>
     fe0:	mov    QWORD PTR [rsp+0x20],rax
     fe5:	mov    rdx,rax
     fe8:	xor    eax,eax
     fea:	mov    rsi,r14
     fed:	test   rsi,0x7
     ff4:	jne    1005 <botlish_fn_13+0x255>
     ffa:	movzx  rdi,BYTE PTR [rsi]
     ffe:	cmp    dil,0x2
    1002:	sete   al
    1005:	test   al,al
    1007:	jne    102d <botlish_fn_13+0x27d>
    100d:	mov    rdi,r13
    1010:	mov    rdi,QWORD PTR [rdi+0x10]
    1014:	mov    rcx,QWORD PTR [rdi+0xd8]
    101b:	mov    edx,0x1
    1020:	mov    rdi,r13
    1023:	call   1028 <botlish_fn_13+0x278>
			1024: R_X86_64_PLT32	rt_type_error-0x4
    1028:	jmp    103e <botlish_fn_13+0x28e>
    102d:	mov    rdi,r13
    1030:	call   1035 <botlish_fn_13+0x285>
			1031: R_X86_64_PLT32	rt_str_cat-0x4
    1035:	test   rax,rax
    1038:	jne    1063 <botlish_fn_13+0x2b3>
    103e:	xor    rax,rax
    1041:	mov    rbx,QWORD PTR [rsp+0x40]
    1046:	mov    r12,QWORD PTR [rsp+0x48]
    104b:	mov    r13,QWORD PTR [rsp+0x50]
    1050:	mov    r14,QWORD PTR [rsp+0x58]
    1055:	mov    r15,QWORD PTR [rsp+0x60]
    105a:	add    rsp,0x70
    105e:	mov    rsp,rbp
    1061:	pop    rbp
    1062:	ret
    1063:	mov    QWORD PTR [rsp],rbx
    1067:	mov    rcx,QWORD PTR [rsp+0x30]
    106c:	mov    QWORD PTR [rsp+0x8],rcx
    1071:	mov    QWORD PTR [rsp+0x10],rax
    1076:	mov    QWORD PTR [rsp+0x18],r12
    107b:	mov    rsi,rbx
    107e:	mov    r14,rax
    1081:	mov    r15,rcx
    1084:	jmp    df9 <botlish_fn_13+0x49>
    1089:	mov    rax,r14
    108c:	mov    rbx,QWORD PTR [rsp+0x40]
    1091:	mov    r12,QWORD PTR [rsp+0x48]
    1096:	mov    r13,QWORD PTR [rsp+0x50]
    109b:	mov    r14,QWORD PTR [rsp+0x58]
    10a0:	mov    r15,QWORD PTR [rsp+0x60]
    10a5:	add    rsp,0x70
    10a9:	mov    rsp,rbp
    10ac:	pop    rbp
    10ad:	ret
    10ae:	add    BYTE PTR [rax],al
    10b0:	(bad)
    10b1:	add    BYTE PTR [rax],al
    10b3:	add    BYTE PTR [rax],al
    10b5:	add    BYTE PTR [rax],al
	...

00000000000010b8 <botlish_entry_13: esc_bytes<generic>>:
    10b8:	push   rbp
    10b9:	mov    rbp,rsp
    10bc:	mov    rsi,QWORD PTR [rdx]
    10bf:	mov    r9,QWORD PTR [rdx+0x8]
    10c3:	mov    rcx,QWORD PTR [rdx+0x10]
    10c7:	mov    r8,QWORD PTR [rdx+0x18]
    10cb:	mov    rdx,r9
    10ce:	call   10d3 <botlish_entry_13+0x1b>
			10cf: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    10d3:	mov    rsp,rbp
    10d6:	pop    rbp
    10d7:	ret

00000000000010d8 <botlish_fn_14: esc_char<generic>>:
    10d8:	push   rbp
    10d9:	mov    rbp,rsp
    10dc:	sub    rsp,0x60
    10e0:	mov    QWORD PTR [rsp+0x30],rbx
    10e5:	mov    QWORD PTR [rsp+0x38],r12
    10ea:	mov    QWORD PTR [rsp+0x40],r13
    10ef:	mov    QWORD PTR [rsp+0x48],r14
    10f4:	mov    QWORD PTR [rsp+0x50],r15
    10f9:	mov    QWORD PTR [rsp+0x18],0x0
    1102:	mov    QWORD PTR [rsp],rsi
    1106:	mov    QWORD PTR [rsp+0x8],rdx
    110b:	mov    r12,rdx
    110e:	mov    QWORD PTR [rsp+0x10],rcx
    1113:	mov    rbx,rcx
    1116:	xor    r10d,r10d
    1119:	test   rsi,0x7
    1120:	jne    1130 <botlish_fn_14+0x58>
    1126:	movzx  rax,BYTE PTR [rsi]
    112a:	cmp    al,0x2
    112c:	sete   r10b
    1130:	test   r10b,r10b
    1133:	jne    1153 <botlish_fn_14+0x7b>
    1139:	mov    rax,QWORD PTR [rdi+0x10]
    113d:	mov    rcx,QWORD PTR [rax+0xe0]
    1144:	mov    edx,0x1
    1149:	call   114e <botlish_fn_14+0x76>
			114a: R_X86_64_PLT32	rt_type_error-0x4
    114e:	jmp    125b <botlish_fn_14+0x183>
    1153:	mov    r13,rdi
    1156:	mov    QWORD PTR [rsp+0x20],rsi
    115b:	call   1160 <botlish_fn_14+0x88>
			115c: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1160:	mov    rcx,rax
    1163:	mov    r14,rax
    1166:	test   rax,rcx
    1169:	je     125b <botlish_fn_14+0x183>
    116f:	mov    rax,r14
    1172:	mov    QWORD PTR [rsp],rax
    1176:	mov    rsi,r14
    1179:	mov    rdi,r13
    117c:	call   1181 <botlish_fn_14+0xa9>
			117d: R_X86_64_PLT32	rt_list_len-0x4
    1181:	mov    edx,0x1
    1186:	sar    rax,1
    1189:	cmp    rax,0x1
    118d:	je     11c8 <botlish_fn_14+0xf0>
    1193:	mov    QWORD PTR [rsp+0x8],0x1
    119c:	mov    rdi,r13
    119f:	mov    rax,QWORD PTR [rdi+0x10]
    11a3:	mov    rcx,QWORD PTR [rax+0xa8]
    11aa:	mov    QWORD PTR [rsp+0x18],rcx
    11af:	mov    rsi,r14
    11b2:	mov    r8,rbx
    11b5:	call   11ba <botlish_fn_14+0xe2>
			11b6: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    11ba:	test   rax,rax
    11bd:	je     125b <botlish_fn_14+0x183>
    11c3:	jmp    128a <botlish_fn_14+0x1b2>
    11c8:	mov    rsi,r14
    11cb:	mov    r15,rdx
    11ce:	mov    rax,QWORD PTR [rsi+0x8]
    11d2:	mov    r14,rsi
    11d5:	test   rax,rax
    11d8:	jne    1200 <botlish_fn_14+0x128>
    11de:	mov    rdx,r15
    11e1:	mov    rsi,r14
    11e4:	mov    rdi,r13
    11e7:	call   11ec <botlish_fn_14+0x114>
			11e8: R_X86_64_PLT32	rt_list_get-0x4
    11ec:	test   rax,rax
    11ef:	je     125b <botlish_fn_14+0x183>
    11f5:	mov    rdx,rax
    11f8:	mov    rsi,r12
    11fb:	jmp    120d <botlish_fn_14+0x135>
    1200:	mov    rsi,r14
    1203:	mov    rdx,QWORD PTR [rsi+0x10]
    1207:	mov    rdx,QWORD PTR [rdx]
    120a:	mov    rsi,r12
    120d:	mov    rdi,r13
    1210:	call   1215 <botlish_fn_14+0x13d>
			1211: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_unreserved<generic>
    1215:	test   rax,rax
    1218:	je     125b <botlish_fn_14+0x183>
    121e:	cmp    rax,0x6
    1222:	je     1285 <botlish_fn_14+0x1ad>
    1228:	mov    QWORD PTR [rsp+0x8],0x1
    1231:	mov    rdi,r13
    1234:	mov    r9,QWORD PTR [rdi+0x10]
    1238:	mov    rcx,QWORD PTR [r9+0xa8]
    123f:	mov    QWORD PTR [rsp+0x18],rcx
    1244:	mov    rdx,r15
    1247:	mov    rsi,r14
    124a:	mov    r8,rbx
    124d:	call   1252 <botlish_fn_14+0x17a>
			124e: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    1252:	test   rax,rax
    1255:	jne    1280 <botlish_fn_14+0x1a8>
    125b:	xor    rax,rax
    125e:	mov    rbx,QWORD PTR [rsp+0x30]
    1263:	mov    r12,QWORD PTR [rsp+0x38]
    1268:	mov    r13,QWORD PTR [rsp+0x40]
    126d:	mov    r14,QWORD PTR [rsp+0x48]
    1272:	mov    r15,QWORD PTR [rsp+0x50]
    1277:	add    rsp,0x60
    127b:	mov    rsp,rbp
    127e:	pop    rbp
    127f:	ret
    1280:	mov    QWORD PTR [rsp+0x20],rax
    1285:	mov    rax,QWORD PTR [rsp+0x20]
    128a:	mov    rbx,QWORD PTR [rsp+0x30]
    128f:	mov    r12,QWORD PTR [rsp+0x38]
    1294:	mov    r13,QWORD PTR [rsp+0x40]
    1299:	mov    r14,QWORD PTR [rsp+0x48]
    129e:	mov    r15,QWORD PTR [rsp+0x50]
    12a3:	add    rsp,0x60
    12a7:	mov    rsp,rbp
    12aa:	pop    rbp
    12ab:	ret

00000000000012ac <botlish_entry_14: esc_char<generic>>:
    12ac:	push   rbp
    12ad:	mov    rbp,rsp
    12b0:	mov    rsi,QWORD PTR [rdx]
    12b3:	mov    r8,QWORD PTR [rdx+0x8]
    12b7:	mov    rcx,QWORD PTR [rdx+0x10]
    12bb:	mov    rdx,r8
    12be:	call   12c3 <botlish_entry_14+0x17>
			12bf: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_char<generic>
    12c3:	mov    rsp,rbp
    12c6:	pop    rbp
    12c7:	ret

00000000000012c8 <botlish_fn_15: esc_from<generic>>:
    12c8:	push   rbp
    12c9:	mov    rbp,rsp
    12cc:	sub    rsp,0x80
    12d3:	mov    QWORD PTR [rsp+0x50],rbx
    12d8:	mov    QWORD PTR [rsp+0x58],r12
    12dd:	mov    QWORD PTR [rsp+0x60],r13
    12e2:	mov    QWORD PTR [rsp+0x68],r14
    12e7:	mov    QWORD PTR [rsp+0x70],r15
    12ec:	mov    r14,rdi
    12ef:	mov    QWORD PTR [rsp+0x30],0x0
    12f8:	mov    QWORD PTR [rsp],rsi
    12fc:	mov    QWORD PTR [rsp+0x8],rdx
    1301:	mov    QWORD PTR [rsp+0x10],rcx
    1306:	mov    QWORD PTR [rsp+0x18],r8
    130b:	mov    r13,r8
    130e:	mov    QWORD PTR [rsp+0x20],r9
    1313:	mov    r12,r9
    1316:	mov    r15,rcx
    1319:	mov    QWORD PTR [rsp+0x38],rdx
    131e:	xor    eax,eax
    1320:	test   rsi,0x7
    1327:	jne    1336 <botlish_fn_15+0x6e>
    132d:	movzx  rax,BYTE PTR [rsi]
    1331:	cmp    al,0x2
    1333:	sete   al
    1336:	test   al,al
    1338:	jne    135b <botlish_fn_15+0x93>
    133e:	mov    rdi,r14
    1341:	mov    rax,QWORD PTR [rdi+0x10]
    1345:	mov    rcx,QWORD PTR [rax+0xe8]
    134c:	mov    edx,0x1
    1351:	call   1356 <botlish_fn_15+0x8e>
			1352: R_X86_64_PLT32	rt_type_error-0x4
    1356:	jmp    15b3 <botlish_fn_15+0x2eb>
    135b:	mov    rbx,rsi
    135e:	mov    rdi,r14
    1361:	call   1366 <botlish_fn_15+0x9e>
			1362: R_X86_64_PLT32	rt_str_len-0x4
    1366:	mov    edx,0x1
    136b:	mov    QWORD PTR [rsp+0x48],rdx
    1370:	mov    ecx,0x1
    1375:	mov    rsi,QWORD PTR [rsp+0x38]
    137a:	test   rsi,0x1
    1381:	jne    13ab <botlish_fn_15+0xe3>
    1387:	xor    ecx,ecx
    1389:	mov    rsi,QWORD PTR [rsp+0x38]
    138e:	test   rsi,0x7
    1395:	jne    13ab <botlish_fn_15+0xe3>
    139b:	mov    rsi,QWORD PTR [rsp+0x38]
    13a0:	movzx  rcx,BYTE PTR [rsi]
    13a4:	rex cmp cl,0x1
    13a8:	sete   cl
    13ab:	test   cl,cl
    13ad:	jne    13d3 <botlish_fn_15+0x10b>
    13b3:	mov    rdi,r14
    13b6:	mov    rax,QWORD PTR [rdi+0x10]
    13ba:	mov    rcx,QWORD PTR [rax+0xc8]
    13c1:	xor    rdx,rdx
    13c4:	mov    rsi,QWORD PTR [rsp+0x38]
    13c9:	call   13ce <botlish_fn_15+0x106>
			13ca: R_X86_64_PLT32	rt_type_error-0x4
    13ce:	jmp    15b3 <botlish_fn_15+0x2eb>
    13d3:	mov    rsi,QWORD PTR [rsp+0x38]
    13d8:	mov    rcx,rsi
    13db:	and    rcx,rax
    13de:	mov    rdx,rax
    13e1:	test   rcx,0x1
    13e8:	jne    1410 <botlish_fn_15+0x148>
    13ee:	mov    rsi,QWORD PTR [rsp+0x38]
    13f3:	mov    rdi,r14
    13f6:	call   13fb <botlish_fn_15+0x133>
			13f7: R_X86_64_PLT32	rt_int_cmp-0x4
    13fb:	mov    ecx,0x2
    1400:	test   rax,rax
    1403:	cmovge rcx,QWORD PTR [rip+0x235]        # 1640 <botlish_fn_15+0x378>
    140b:	jmp    1425 <botlish_fn_15+0x15d>
    1410:	mov    ecx,0x2
    1415:	mov    rsi,QWORD PTR [rsp+0x38]
    141a:	cmp    rsi,rdx
    141d:	cmovge rcx,QWORD PTR [rip+0x21b]        # 1640 <botlish_fn_15+0x378>
    1425:	cmp    rcx,0x6
    1429:	je     1611 <botlish_fn_15+0x349>
    142f:	mov    QWORD PTR [rsp+0x28],0x3
    1438:	mov    rsi,QWORD PTR [rsp+0x38]
    143d:	test   rsi,0x1
    1444:	je     1461 <botlish_fn_15+0x199>
    144a:	mov    rsi,QWORD PTR [rsp+0x38]
    144f:	mov    rax,rsi
    1452:	add    rax,0x2
    1456:	seto   cl
    1459:	test   cl,cl
    145b:	je     1473 <botlish_fn_15+0x1ab>
    1461:	mov    edx,0x3
    1466:	mov    rsi,QWORD PTR [rsp+0x38]
    146b:	mov    rdi,r14
    146e:	call   1473 <botlish_fn_15+0x1ab>
			146f: R_X86_64_PLT32	rt_int_add-0x4
    1473:	mov    QWORD PTR [rsp+0x28],rax
    1478:	mov    QWORD PTR [rsp+0x40],rax
    147d:	mov    QWORD PTR [rsp+0x30],0x3
    1486:	mov    rsi,QWORD PTR [rsp+0x38]
    148b:	test   rsi,0x1
    1492:	je     14af <botlish_fn_15+0x1e7>
    1498:	mov    rsi,QWORD PTR [rsp+0x38]
    149d:	mov    rcx,rsi
    14a0:	add    rcx,0x2
    14a4:	seto   al
    14a7:	test   al,al
    14a9:	je     14c4 <botlish_fn_15+0x1fc>
    14af:	mov    edx,0x3
    14b4:	mov    rsi,QWORD PTR [rsp+0x38]
    14b9:	mov    rdi,r14
    14bc:	call   14c1 <botlish_fn_15+0x1f9>
			14bd: R_X86_64_PLT32	rt_int_add-0x4
    14c1:	mov    rcx,rax
    14c4:	mov    QWORD PTR [rsp+0x30],rcx
    14c9:	mov    rdx,QWORD PTR [rsp+0x38]
    14ce:	mov    rsi,rbx
    14d1:	mov    rdi,r14
    14d4:	call   14d9 <botlish_fn_15+0x211>
			14d5: R_X86_64_PLT32	rt_substr-0x4
    14d9:	test   rax,rax
    14dc:	je     15b3 <botlish_fn_15+0x2eb>
    14e2:	mov    QWORD PTR [rsp+0x8],rax
    14e7:	mov    r8,r12
    14ea:	mov    r12,r13
    14ed:	mov    r13,r8
    14f0:	mov    rsi,rax
    14f3:	mov    rcx,r13
    14f6:	mov    rdx,r12
    14f9:	mov    rdi,r14
    14fc:	call   1501 <botlish_fn_15+0x239>
			14fd: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_char<generic>
    1501:	test   rax,rax
    1504:	je     15b3 <botlish_fn_15+0x2eb>
    150a:	mov    QWORD PTR [rsp+0x8],rax
    150f:	xor    ecx,ecx
    1511:	mov    rsi,r15
    1514:	test   rsi,0x7
    151b:	jne    152c <botlish_fn_15+0x264>
    1521:	movzx  rdi,BYTE PTR [rsi]
    1525:	cmp    dil,0x2
    1529:	sete   cl
    152c:	test   cl,cl
    152e:	jne    1551 <botlish_fn_15+0x289>
    1534:	mov    rdi,r14
    1537:	mov    r11,QWORD PTR [rdi+0x10]
    153b:	mov    rcx,QWORD PTR [r11+0xd8]
    1542:	mov    rdx,QWORD PTR [rsp+0x48]
    1547:	call   154c <botlish_fn_15+0x284>
			1548: R_X86_64_PLT32	rt_type_error-0x4
    154c:	jmp    15b3 <botlish_fn_15+0x2eb>
    1551:	mov    rdx,QWORD PTR [rsp+0x48]
    1556:	xor    edi,edi
    1558:	test   rax,0x7
    155e:	je     156c <botlish_fn_15+0x2a4>
    1564:	mov    r8,rax
    1567:	jmp    157b <botlish_fn_15+0x2b3>
    156c:	movzx  rcx,BYTE PTR [rax]
    1570:	mov    r8,rax
    1573:	rex cmp cl,0x2
    1577:	sete   dil
    157b:	test   dil,dil
    157e:	jne    159f <botlish_fn_15+0x2d7>
    1584:	mov    rdi,r14
    1587:	mov    rax,QWORD PTR [rdi+0x10]
    158b:	mov    rcx,QWORD PTR [rax+0xd8]
    1592:	mov    rsi,r8
    1595:	call   159a <botlish_fn_15+0x2d2>
			1596: R_X86_64_PLT32	rt_type_error-0x4
    159a:	jmp    15b3 <botlish_fn_15+0x2eb>
    159f:	mov    rdx,r8
    15a2:	mov    rdi,r14
    15a5:	call   15aa <botlish_fn_15+0x2e2>
			15a6: R_X86_64_PLT32	rt_str_cat-0x4
    15aa:	test   rax,rax
    15ad:	jne    15db <botlish_fn_15+0x313>
    15b3:	xor    rax,rax
    15b6:	mov    rbx,QWORD PTR [rsp+0x50]
    15bb:	mov    r12,QWORD PTR [rsp+0x58]
    15c0:	mov    r13,QWORD PTR [rsp+0x60]
    15c5:	mov    r14,QWORD PTR [rsp+0x68]
    15ca:	mov    r15,QWORD PTR [rsp+0x70]
    15cf:	add    rsp,0x80
    15d6:	mov    rsp,rbp
    15d9:	pop    rbp
    15da:	ret
    15db:	mov    QWORD PTR [rsp],rbx
    15df:	mov    rcx,QWORD PTR [rsp+0x40]
    15e4:	mov    QWORD PTR [rsp+0x8],rcx
    15e9:	mov    QWORD PTR [rsp+0x10],rax
    15ee:	mov    QWORD PTR [rsp+0x18],r12
    15f3:	mov    QWORD PTR [rsp+0x20],r13
    15f8:	mov    QWORD PTR [rsp+0x38],rcx
    15fd:	mov    r15,rax
    1600:	mov    rdx,r12
    1603:	mov    r12,r13
    1606:	mov    r13,rdx
    1609:	mov    rsi,rbx
    160c:	jmp    131e <botlish_fn_15+0x56>
    1611:	mov    rax,r15
    1614:	mov    rbx,QWORD PTR [rsp+0x50]
    1619:	mov    r12,QWORD PTR [rsp+0x58]
    161e:	mov    r13,QWORD PTR [rsp+0x60]
    1623:	mov    r14,QWORD PTR [rsp+0x68]
    1628:	mov    r15,QWORD PTR [rsp+0x70]
    162d:	add    rsp,0x80
    1634:	mov    rsp,rbp
    1637:	pop    rbp
    1638:	ret
    1639:	add    BYTE PTR [rax],al
    163b:	add    BYTE PTR [rax],al
    163d:	add    BYTE PTR [rax],al
    163f:	add    BYTE PTR [rsi],al
    1641:	add    BYTE PTR [rax],al
    1643:	add    BYTE PTR [rax],al
    1645:	add    BYTE PTR [rax],al
	...

0000000000001648 <botlish_entry_15: esc_from<generic>>:
    1648:	push   rbp
    1649:	mov    rbp,rsp
    164c:	mov    rsi,QWORD PTR [rdx]
    164f:	mov    r10,QWORD PTR [rdx+0x8]
    1653:	mov    rcx,QWORD PTR [rdx+0x10]
    1657:	mov    r8,QWORD PTR [rdx+0x18]
    165b:	mov    r9,QWORD PTR [rdx+0x20]
    165f:	mov    rdx,r10
    1662:	call   1667 <botlish_entry_15+0x1f>
			1663: R_X86_64_PLT32	botlish_fn_15-0x4 ; esc_from<generic>
    1667:	mov    rsp,rbp
    166a:	pop    rbp
    166b:	ret
    166c:	add    BYTE PTR [rax],al
	...

0000000000001670 <botlish_fn_16: check<int, int, str, str>>:
    1670:	push   rbp
    1671:	mov    rbp,rsp
    1674:	sub    rsp,0x60
    1678:	mov    QWORD PTR [rsp+0x30],rbx
    167d:	mov    QWORD PTR [rsp+0x38],r12
    1682:	mov    QWORD PTR [rsp+0x40],r13
    1687:	mov    QWORD PTR [rsp+0x48],r14
    168c:	mov    QWORD PTR [rsp+0x50],r15
    1691:	mov    QWORD PTR [rsp+0x20],0x0
    169a:	mov    QWORD PTR [rsp],rsi
    169e:	mov    QWORD PTR [rsp+0x8],rdx
    16a3:	mov    QWORD PTR [rsp+0x10],rcx
    16a8:	mov    r12,rcx
    16ab:	mov    QWORD PTR [rsp+0x18],r8
    16b0:	mov    r14,r8
    16b3:	mov    r13,rsi
    16b6:	mov    r15,rdx
    16b9:	test   r13,0x1
    16c0:	jne    16eb <botlish_fn_16+0x7b>
    16c6:	mov    edx,0x1
    16cb:	mov    rbx,rdi
    16ce:	mov    rsi,r13
    16d1:	call   16d6 <botlish_fn_16+0x66>
			16d2: R_X86_64_PLT32	rt_int_cmp-0x4
    16d6:	mov    ecx,0x2
    16db:	test   rax,rax
    16de:	cmovle rcx,QWORD PTR [rip+0x152]        # 1838 <botlish_fn_16+0x1c8>
    16e6:	jmp    16ff <botlish_fn_16+0x8f>
    16eb:	mov    rbx,rdi
    16ee:	mov    ecx,0x2
    16f3:	cmp    r13,0x1
    16f7:	cmovle rcx,QWORD PTR [rip+0x139]        # 1838 <botlish_fn_16+0x1c8>
    16ff:	cmp    rcx,0x6
    1703:	je     180c <botlish_fn_16+0x19c>
    1709:	mov    rax,QWORD PTR [rbx+0x10]
    170d:	mov    rax,QWORD PTR [rax+0xf0]
    1714:	mov    rsi,r12
    1717:	mov    rdi,rbx
    171a:	call   171f <botlish_fn_16+0xaf>
			171b: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    171f:	test   rax,rax
    1722:	je     1763 <botlish_fn_16+0xf3>
    1728:	cmp    rax,0x6
    172c:	je     1744 <botlish_fn_16+0xd4>
    1732:	mov    edx,0x1
    1737:	mov    QWORD PTR [rsp],0x1
    173f:	jmp    17a5 <botlish_fn_16+0x135>
    1744:	mov    rax,QWORD PTR [rbx+0x10]
    1748:	mov    rax,QWORD PTR [rax+0xf8]
    174f:	mov    rsi,r12
    1752:	mov    rdi,rbx
    1755:	call   175a <botlish_fn_16+0xea>
			1756: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    175a:	test   rax,rax
    175d:	jne    1788 <botlish_fn_16+0x118>
    1763:	xor    rax,rax
    1766:	mov    rbx,QWORD PTR [rsp+0x30]
    176b:	mov    r12,QWORD PTR [rsp+0x38]
    1770:	mov    r13,QWORD PTR [rsp+0x40]
    1775:	mov    r14,QWORD PTR [rsp+0x48]
    177a:	mov    r15,QWORD PTR [rsp+0x50]
    177f:	add    rsp,0x60
    1783:	mov    rsp,rbp
    1786:	pop    rbp
    1787:	ret
    1788:	cmp    rax,0x6
    178c:	je     179c <botlish_fn_16+0x12c>
    1792:	mov    edx,0x1
    1797:	jmp    17a1 <botlish_fn_16+0x131>
    179c:	mov    edx,0x3
    17a1:	mov    QWORD PTR [rsp],rdx
    17a5:	sar    r13,1
    17a8:	sub    r13,0x1
    17ac:	shl    r13,1
    17af:	or     r13,0x1
    17b3:	mov    QWORD PTR [rsp+0x20],r13
    17b8:	mov    rsi,r15
    17bb:	mov    r8,rsi
    17be:	and    r8,rdx
    17c1:	test   r8,0x1
    17c8:	je     17e3 <botlish_fn_16+0x173>
    17ce:	lea    r11,[rdx-0x1]
    17d2:	mov    rax,rsi
    17d5:	add    rax,r11
    17d8:	seto   cl
    17db:	test   cl,cl
    17dd:	je     17eb <botlish_fn_16+0x17b>
    17e3:	mov    rdi,rbx
    17e6:	call   17eb <botlish_fn_16+0x17b>
			17e7: R_X86_64_PLT32	rt_int_add-0x4
    17eb:	mov    QWORD PTR [rsp],r13
    17ef:	mov    QWORD PTR [rsp+0x8],rax
    17f4:	mov    QWORD PTR [rsp+0x10],r12
    17f9:	mov    r8,r14
    17fc:	mov    QWORD PTR [rsp+0x18],r8
    1801:	mov    rdi,rbx
    1804:	mov    r15,rax
    1807:	jmp    16b9 <botlish_fn_16+0x49>
    180c:	mov    rax,r15
    180f:	mov    rbx,QWORD PTR [rsp+0x30]
    1814:	mov    r12,QWORD PTR [rsp+0x38]
    1819:	mov    r13,QWORD PTR [rsp+0x40]
    181e:	mov    r14,QWORD PTR [rsp+0x48]
    1823:	mov    r15,QWORD PTR [rsp+0x50]
    1828:	add    rsp,0x60
    182c:	mov    rsp,rbp
    182f:	pop    rbp
    1830:	ret
    1831:	add    BYTE PTR [rax],al
    1833:	add    BYTE PTR [rax],al
    1835:	add    BYTE PTR [rax],al
    1837:	add    BYTE PTR [rsi],al
    1839:	add    BYTE PTR [rax],al
    183b:	add    BYTE PTR [rax],al
    183d:	add    BYTE PTR [rax],al
	...

0000000000001840 <botlish_entry_16: check<int, int, str, str>>:
    1840:	push   rbp
    1841:	mov    rbp,rsp
    1844:	mov    rsi,QWORD PTR [rdx]
    1847:	mov    r9,QWORD PTR [rdx+0x8]
    184b:	mov    rcx,QWORD PTR [rdx+0x10]
    184f:	mov    r8,QWORD PTR [rdx+0x18]
    1853:	mov    rdx,r9
    1856:	call   185b <botlish_entry_16+0x1b>
			1857: R_X86_64_PLT32	botlish_fn_16-0x4 ; check<int, int, str, str>
    185b:	mov    rsp,rbp
    185e:	pop    rbp
    185f:	ret

0000000000001860 <botlish_fn_17: <str>>:
    1860:	push   rbp
    1861:	mov    rbp,rsp
    1864:	sub    rsp,0x50
    1868:	mov    QWORD PTR [rsp+0x30],rbx
    186d:	mov    QWORD PTR [rsp+0x38],r12
    1872:	mov    QWORD PTR [rsp+0x40],r13
    1877:	mov    QWORD PTR [rsp+0x48],r14
    187c:	mov    r13,rdi
    187f:	mov    QWORD PTR [rsp+0x18],0x0
    1888:	mov    QWORD PTR [rsp],rsi
    188c:	mov    r14,rsi
    188f:	mov    rsi,r14
    1892:	mov    rdi,r13
    1895:	call   189a <botlish_fn_17+0x3a>
			1896: R_X86_64_PLT32	rt_str_len-0x4
    189a:	mov    rbx,rax
    189d:	mov    QWORD PTR [rsp+0x8],rax
    18a2:	mov    esi,0x1
    18a7:	mov    QWORD PTR [rsp+0x10],0x1
    18b0:	mov    rcx,r14
    18b3:	mov    rdx,rbx
    18b6:	mov    rdi,r13
    18b9:	call   18be <botlish_fn_17+0x5e>
			18ba: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    18be:	mov    r12,rax
    18c1:	test   r12,r12
    18c4:	je     1a21 <botlish_fn_17+0x1c1>
    18ca:	mov    QWORD PTR [rsp+0x10],r12
    18cf:	test   r12,0x1
    18d6:	jne    1901 <botlish_fn_17+0xa1>
    18dc:	mov    edx,0x1
    18e1:	mov    rsi,r12
    18e4:	mov    rdi,r13
    18e7:	call   18ec <botlish_fn_17+0x8c>
			18e8: R_X86_64_PLT32	rt_int_cmp-0x4
    18ec:	mov    ecx,0x2
    18f1:	test   rax,rax
    18f4:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 1ac0 <botlish_fn_17+0x260>
    18fc:	jmp    1912 <botlish_fn_17+0xb2>
    1901:	mov    ecx,0x2
    1906:	cmp    r12,0x1
    190a:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 1ac0 <botlish_fn_17+0x260>
    1912:	cmp    rcx,0x6
    1916:	je     1a9c <botlish_fn_17+0x23c>
    191c:	mov    rcx,r12
    191f:	and    rcx,rbx
    1922:	test   rcx,0x1
    1929:	jne    1952 <botlish_fn_17+0xf2>
    192f:	mov    rdx,rbx
    1932:	mov    rsi,r12
    1935:	mov    rdi,r13
    1938:	call   193d <botlish_fn_17+0xdd>
			1939: R_X86_64_PLT32	rt_int_cmp-0x4
    193d:	mov    ecx,0x2
    1942:	test   rax,rax
    1945:	cmovge rcx,QWORD PTR [rip+0x173]        # 1ac0 <botlish_fn_17+0x260>
    194d:	jmp    1962 <botlish_fn_17+0x102>
    1952:	mov    ecx,0x2
    1957:	cmp    r12,rbx
    195a:	cmovge rcx,QWORD PTR [rip+0x15e]        # 1ac0 <botlish_fn_17+0x260>
    1962:	cmp    rcx,0x6
    1966:	je     1a92 <botlish_fn_17+0x232>
    196c:	lea    rcx,[rsp+0x20]
    1971:	mov    rdx,r14
    1974:	mov    rsi,r12
    1977:	mov    rdi,r13
    197a:	call   197f <botlish_fn_17+0x11f>
			197b: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    197f:	test   rax,rax
    1982:	mov    rsi,rax
    1985:	je     1a21 <botlish_fn_17+0x1c1>
    198b:	mov    rdx,QWORD PTR [rsp+0x20]
    1990:	mov    rcx,QWORD PTR [rsp+0x28]
    1995:	mov    rdi,r13
    1998:	mov    rax,QWORD PTR [rdi+0x10]
    199c:	mov    r8,QWORD PTR [rax+0x110]
    19a3:	call   19a8 <botlish_fn_17+0x148>
			19a4: R_X86_64_PLT32	rt_str_region_eq-0x4
    19a8:	cmp    rax,0x6
    19ac:	je     19bf <botlish_fn_17+0x15f>
    19b2:	mov    ecx,0x2
    19b7:	mov    rax,rcx
    19ba:	jmp    1aa1 <botlish_fn_17+0x241>
    19bf:	mov    QWORD PTR [rsp+0x18],0x3
    19c8:	test   r12,0x1
    19cf:	jne    19dd <botlish_fn_17+0x17d>
    19d5:	mov    rcx,r12
    19d8:	jmp    19f2 <botlish_fn_17+0x192>
    19dd:	mov    rsi,r12
    19e0:	add    rsi,0x2
    19e4:	mov    rcx,r12
    19e7:	seto   al
    19ea:	test   al,al
    19ec:	je     1a05 <botlish_fn_17+0x1a5>
    19f2:	mov    edx,0x3
    19f7:	mov    rsi,rcx
    19fa:	mov    rdi,r13
    19fd:	call   1a02 <botlish_fn_17+0x1a2>
			19fe: R_X86_64_PLT32	rt_int_add-0x4
    1a02:	mov    rsi,rax
    1a05:	mov    QWORD PTR [rsp+0x10],rsi
    1a0a:	mov    rcx,r14
    1a0d:	mov    rdx,rbx
    1a10:	mov    rdi,r13
    1a13:	call   1a18 <botlish_fn_17+0x1b8>
			1a14: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    1a18:	test   rax,rax
    1a1b:	jne    1a41 <botlish_fn_17+0x1e1>
    1a21:	xor    rax,rax
    1a24:	mov    rbx,QWORD PTR [rsp+0x30]
    1a29:	mov    r12,QWORD PTR [rsp+0x38]
    1a2e:	mov    r13,QWORD PTR [rsp+0x40]
    1a33:	mov    r14,QWORD PTR [rsp+0x48]
    1a38:	add    rsp,0x50
    1a3c:	mov    rsp,rbp
    1a3f:	pop    rbp
    1a40:	ret
    1a41:	mov    rcx,rax
    1a44:	and    rcx,rbx
    1a47:	mov    rsi,rax
    1a4a:	test   rcx,0x1
    1a51:	jne    1a7a <botlish_fn_17+0x21a>
    1a57:	mov    rdx,rbx
    1a5a:	mov    rdi,r13
    1a5d:	call   1a62 <botlish_fn_17+0x202>
			1a5e: R_X86_64_PLT32	rt_int_cmp-0x4
    1a62:	mov    ecx,0x2
    1a67:	test   rax,rax
    1a6a:	mov    rax,rcx
    1a6d:	cmove  rax,QWORD PTR [rip+0x4b]        # 1ac0 <botlish_fn_17+0x260>
    1a75:	jmp    1aa1 <botlish_fn_17+0x241>
    1a7a:	mov    rdx,rbx
    1a7d:	mov    eax,0x2
    1a82:	cmp    rsi,rdx
    1a85:	cmove  rax,QWORD PTR [rip+0x33]        # 1ac0 <botlish_fn_17+0x260>
    1a8d:	jmp    1aa1 <botlish_fn_17+0x241>
    1a92:	mov    eax,0x2
    1a97:	jmp    1aa1 <botlish_fn_17+0x241>
    1a9c:	mov    eax,0x2
    1aa1:	mov    rbx,QWORD PTR [rsp+0x30]
    1aa6:	mov    r12,QWORD PTR [rsp+0x38]
    1aab:	mov    r13,QWORD PTR [rsp+0x40]
    1ab0:	mov    r14,QWORD PTR [rsp+0x48]
    1ab5:	add    rsp,0x50
    1ab9:	mov    rsp,rbp
    1abc:	pop    rbp
    1abd:	ret
    1abe:	add    BYTE PTR [rax],al
    1ac0:	(bad)
    1ac1:	add    BYTE PTR [rax],al
    1ac3:	add    BYTE PTR [rax],al
    1ac5:	add    BYTE PTR [rax],al
	...

0000000000001ac8 <botlish_entry_17: <str>>:
    1ac8:	push   rbp
    1ac9:	mov    rbp,rsp
    1acc:	mov    rsi,QWORD PTR [rdx]
    1acf:	call   1ad4 <botlish_entry_17+0xc>
			1ad0: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    1ad4:	mov    rsp,rbp
    1ad7:	pop    rbp
    1ad8:	ret
    1ad9:	add    BYTE PTR [rax],al
    1adb:	add    BYTE PTR [rax],al
    1add:	add    BYTE PTR [rax],al
	...

0000000000001ae0 <botlish_fn_18: <generic>>:
    1ae0:	push   rbp
    1ae1:	mov    rbp,rsp
    1ae4:	sub    rsp,0x60
    1ae8:	mov    QWORD PTR [rsp+0x30],rbx
    1aed:	mov    QWORD PTR [rsp+0x38],r12
    1af2:	mov    QWORD PTR [rsp+0x40],r13
    1af7:	mov    QWORD PTR [rsp+0x48],r14
    1afc:	mov    QWORD PTR [rsp+0x50],r15
    1b01:	mov    QWORD PTR [rsp+0x18],0x0
    1b0a:	mov    QWORD PTR [rsp],rsi
    1b0e:	xor    r8d,r8d
    1b11:	test   rsi,0x7
    1b18:	jne    1b28 <botlish_fn_18+0x48>
    1b1e:	movzx  rax,BYTE PTR [rsi]
    1b22:	cmp    al,0x2
    1b24:	sete   r8b
    1b28:	test   r8b,r8b
    1b2b:	jne    1b4b <botlish_fn_18+0x6b>
    1b31:	mov    rdx,QWORD PTR [rdi+0x10]
    1b35:	mov    rcx,QWORD PTR [rdx+0xe8]
    1b3c:	mov    edx,0x1
    1b41:	call   1b46 <botlish_fn_18+0x66>
			1b42: R_X86_64_PLT32	rt_type_error-0x4
    1b46:	jmp    1ce0 <botlish_fn_18+0x200>
    1b4b:	mov    r13,rsi
    1b4e:	mov    r14,rdi
    1b51:	call   1b56 <botlish_fn_18+0x76>
			1b52: R_X86_64_PLT32	rt_str_len-0x4
    1b56:	mov    rbx,rax
    1b59:	mov    QWORD PTR [rsp+0x8],rax
    1b5e:	mov    edx,0x1
    1b63:	mov    r15,rdx
    1b66:	mov    QWORD PTR [rsp+0x10],0x1
    1b6f:	mov    rcx,r13
    1b72:	mov    rdx,rbx
    1b75:	mov    rsi,r15
    1b78:	mov    rdi,r14
    1b7b:	call   1b80 <botlish_fn_18+0xa0>
			1b7c: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    1b80:	mov    r12,rax
    1b83:	test   r12,r12
    1b86:	je     1ce0 <botlish_fn_18+0x200>
    1b8c:	mov    QWORD PTR [rsp+0x10],r12
    1b91:	test   r12,0x1
    1b98:	jne    1bc1 <botlish_fn_18+0xe1>
    1b9e:	mov    rdx,r15
    1ba1:	mov    rsi,r12
    1ba4:	mov    rdi,r14
    1ba7:	call   1bac <botlish_fn_18+0xcc>
			1ba8: R_X86_64_PLT32	rt_int_cmp-0x4
    1bac:	mov    ecx,0x2
    1bb1:	test   rax,rax
    1bb4:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 1d88 <botlish_fn_18+0x2a8>
    1bbc:	jmp    1bd2 <botlish_fn_18+0xf2>
    1bc1:	mov    ecx,0x2
    1bc6:	cmp    r12,0x1
    1bca:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 1d88 <botlish_fn_18+0x2a8>
    1bd2:	cmp    rcx,0x6
    1bd6:	je     1d60 <botlish_fn_18+0x280>
    1bdc:	mov    rax,r12
    1bdf:	and    rax,rbx
    1be2:	test   rax,0x1
    1be8:	jne    1c11 <botlish_fn_18+0x131>
    1bee:	mov    rdx,rbx
    1bf1:	mov    rsi,r12
    1bf4:	mov    rdi,r14
    1bf7:	call   1bfc <botlish_fn_18+0x11c>
			1bf8: R_X86_64_PLT32	rt_int_cmp-0x4
    1bfc:	mov    ecx,0x2
    1c01:	test   rax,rax
    1c04:	cmovge rcx,QWORD PTR [rip+0x17c]        # 1d88 <botlish_fn_18+0x2a8>
    1c0c:	jmp    1c21 <botlish_fn_18+0x141>
    1c11:	mov    ecx,0x2
    1c16:	cmp    r12,rbx
    1c19:	cmovge rcx,QWORD PTR [rip+0x167]        # 1d88 <botlish_fn_18+0x2a8>
    1c21:	cmp    rcx,0x6
    1c25:	je     1d56 <botlish_fn_18+0x276>
    1c2b:	lea    rcx,[rsp+0x20]
    1c30:	mov    rdx,r13
    1c33:	mov    rsi,r12
    1c36:	mov    rdi,r14
    1c39:	call   1c3e <botlish_fn_18+0x15e>
			1c3a: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    1c3e:	test   rax,rax
    1c41:	mov    rsi,rax
    1c44:	je     1ce0 <botlish_fn_18+0x200>
    1c4a:	mov    rdx,QWORD PTR [rsp+0x20]
    1c4f:	mov    rcx,QWORD PTR [rsp+0x28]
    1c54:	mov    rdi,r14
    1c57:	mov    rax,QWORD PTR [rdi+0x10]
    1c5b:	mov    r8,QWORD PTR [rax+0x110]
    1c62:	call   1c67 <botlish_fn_18+0x187>
			1c63: R_X86_64_PLT32	rt_str_region_eq-0x4
    1c67:	cmp    rax,0x6
    1c6b:	je     1c7e <botlish_fn_18+0x19e>
    1c71:	mov    ecx,0x2
    1c76:	mov    rax,rcx
    1c79:	jmp    1d65 <botlish_fn_18+0x285>
    1c7e:	mov    QWORD PTR [rsp+0x18],0x3
    1c87:	test   r12,0x1
    1c8e:	jne    1c9c <botlish_fn_18+0x1bc>
    1c94:	mov    rdi,r12
    1c97:	jmp    1cb1 <botlish_fn_18+0x1d1>
    1c9c:	mov    rsi,r12
    1c9f:	add    rsi,0x2
    1ca3:	mov    rdi,r12
    1ca6:	seto   al
    1ca9:	test   al,al
    1cab:	je     1cc4 <botlish_fn_18+0x1e4>
    1cb1:	mov    edx,0x3
    1cb6:	mov    rsi,rdi
    1cb9:	mov    rdi,r14
    1cbc:	call   1cc1 <botlish_fn_18+0x1e1>
			1cbd: R_X86_64_PLT32	rt_int_add-0x4
    1cc1:	mov    rsi,rax
    1cc4:	mov    QWORD PTR [rsp+0x10],rsi
    1cc9:	mov    rcx,r13
    1ccc:	mov    rdx,rbx
    1ccf:	mov    rdi,r14
    1cd2:	call   1cd7 <botlish_fn_18+0x1f7>
			1cd3: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    1cd7:	test   rax,rax
    1cda:	jne    1d05 <botlish_fn_18+0x225>
    1ce0:	xor    rax,rax
    1ce3:	mov    rbx,QWORD PTR [rsp+0x30]
    1ce8:	mov    r12,QWORD PTR [rsp+0x38]
    1ced:	mov    r13,QWORD PTR [rsp+0x40]
    1cf2:	mov    r14,QWORD PTR [rsp+0x48]
    1cf7:	mov    r15,QWORD PTR [rsp+0x50]
    1cfc:	add    rsp,0x60
    1d00:	mov    rsp,rbp
    1d03:	pop    rbp
    1d04:	ret
    1d05:	mov    rcx,rax
    1d08:	and    rcx,rbx
    1d0b:	mov    rsi,rax
    1d0e:	test   rcx,0x1
    1d15:	jne    1d3e <botlish_fn_18+0x25e>
    1d1b:	mov    rdx,rbx
    1d1e:	mov    rdi,r14
    1d21:	call   1d26 <botlish_fn_18+0x246>
			1d22: R_X86_64_PLT32	rt_int_cmp-0x4
    1d26:	mov    ecx,0x2
    1d2b:	test   rax,rax
    1d2e:	mov    rax,rcx
    1d31:	cmove  rax,QWORD PTR [rip+0x4f]        # 1d88 <botlish_fn_18+0x2a8>
    1d39:	jmp    1d65 <botlish_fn_18+0x285>
    1d3e:	mov    rdx,rbx
    1d41:	mov    eax,0x2
    1d46:	cmp    rsi,rdx
    1d49:	cmove  rax,QWORD PTR [rip+0x37]        # 1d88 <botlish_fn_18+0x2a8>
    1d51:	jmp    1d65 <botlish_fn_18+0x285>
    1d56:	mov    eax,0x2
    1d5b:	jmp    1d65 <botlish_fn_18+0x285>
    1d60:	mov    eax,0x2
    1d65:	mov    rbx,QWORD PTR [rsp+0x30]
    1d6a:	mov    r12,QWORD PTR [rsp+0x38]
    1d6f:	mov    r13,QWORD PTR [rsp+0x40]
    1d74:	mov    r14,QWORD PTR [rsp+0x48]
    1d79:	mov    r15,QWORD PTR [rsp+0x50]
    1d7e:	add    rsp,0x60
    1d82:	mov    rsp,rbp
    1d85:	pop    rbp
    1d86:	ret
    1d87:	add    BYTE PTR [rsi],al
    1d89:	add    BYTE PTR [rax],al
    1d8b:	add    BYTE PTR [rax],al
    1d8d:	add    BYTE PTR [rax],al
	...

0000000000001d90 <botlish_entry_18: <generic>>:
    1d90:	push   rbp
    1d91:	mov    rbp,rsp
    1d94:	mov    rsi,QWORD PTR [rdx]
    1d97:	call   1d9c <botlish_entry_18+0xc>
			1d98: R_X86_64_PLT32	botlish_fn_18-0x4 ; <generic>
    1d9c:	mov    rsp,rbp
    1d9f:	pop    rbp
    1da0:	ret

0000000000001da1 <botlish_fn_19: char_at<generic>>:
    1da1:	push   rbp
    1da2:	mov    rbp,rsp
    1da5:	sub    rsp,0x50
    1da9:	mov    QWORD PTR [rsp+0x20],rbx
    1dae:	mov    QWORD PTR [rsp+0x28],r12
    1db3:	mov    QWORD PTR [rsp+0x30],r13
    1db8:	mov    QWORD PTR [rsp+0x38],r14
    1dbd:	mov    QWORD PTR [rsp+0x40],r15
    1dc2:	mov    r14,rcx
    1dc5:	mov    QWORD PTR [rsp],rsi
    1dc9:	mov    QWORD PTR [rsp+0x8],rdx
    1dce:	mov    r13,rdx
    1dd1:	mov    QWORD PTR [rsp+0x10],0x3
    1dda:	mov    r9d,0x1
    1de0:	test   rsi,0x1
    1de7:	jne    1e07 <botlish_fn_19+0x66>
    1ded:	xor    r9d,r9d
    1df0:	test   rsi,0x7
    1df7:	jne    1e07 <botlish_fn_19+0x66>
    1dfd:	movzx  rax,BYTE PTR [rsi]
    1e01:	cmp    al,0x1
    1e03:	sete   r9b
    1e07:	test   r9b,r9b
    1e0a:	jne    1e28 <botlish_fn_19+0x87>
    1e10:	mov    rax,QWORD PTR [rdi+0x10]
    1e14:	mov    rcx,QWORD PTR [rax+0x118]
    1e1b:	xor    rdx,rdx
    1e1e:	call   1e23 <botlish_fn_19+0x82>
			1e1f: R_X86_64_PLT32	rt_type_error-0x4
    1e23:	jmp    1ee5 <botlish_fn_19+0x144>
    1e28:	mov    r12,rdi
    1e2b:	test   rsi,0x1
    1e32:	jne    1e40 <botlish_fn_19+0x9f>
    1e38:	mov    rbx,rsi
    1e3b:	jmp    1e5d <botlish_fn_19+0xbc>
    1e40:	mov    rax,rsi
    1e43:	add    rax,0x2
    1e47:	mov    rbx,rsi
    1e4a:	seto   cl
    1e4d:	test   cl,cl
    1e4f:	jne    1e5d <botlish_fn_19+0xbc>
    1e55:	mov    r15,rax
    1e58:	jmp    1e70 <botlish_fn_19+0xcf>
    1e5d:	mov    edx,0x3
    1e62:	mov    rsi,rbx
    1e65:	mov    rdi,r12
    1e68:	call   1e6d <botlish_fn_19+0xcc>
			1e69: R_X86_64_PLT32	rt_int_add-0x4
    1e6d:	mov    r15,rax
    1e70:	mov    ecx,0x1
    1e75:	mov    rsi,rbx
    1e78:	test   rsi,0x1
    1e7f:	jne    1ea5 <botlish_fn_19+0x104>
    1e85:	xor    ecx,ecx
    1e87:	mov    rsi,rbx
    1e8a:	test   rsi,0x7
    1e91:	jne    1ea5 <botlish_fn_19+0x104>
    1e97:	mov    rsi,rbx
    1e9a:	movzx  rcx,BYTE PTR [rsi]
    1e9e:	rex cmp cl,0x1
    1ea2:	sete   cl
    1ea5:	test   cl,cl
    1ea7:	jne    1ecb <botlish_fn_19+0x12a>
    1ead:	mov    rdi,r12
    1eb0:	mov    rsi,QWORD PTR [rdi+0x10]
    1eb4:	mov    rcx,QWORD PTR [rsi+0x120]
    1ebb:	xor    rdx,rdx
    1ebe:	mov    rsi,rbx
    1ec1:	call   1ec6 <botlish_fn_19+0x125>
			1ec2: R_X86_64_PLT32	rt_type_error-0x4
    1ec6:	jmp    1ee5 <botlish_fn_19+0x144>
    1ecb:	mov    rdi,r12
    1ece:	mov    rcx,r15
    1ed1:	mov    rdx,rbx
    1ed4:	mov    rsi,r13
    1ed7:	call   1edc <botlish_fn_19+0x13b>
			1ed8: R_X86_64_PLT32	rt_str_region_check-0x4
    1edc:	test   rax,rax
    1edf:	jne    1f0a <botlish_fn_19+0x169>
    1ee5:	xor    rax,rax
    1ee8:	mov    rbx,QWORD PTR [rsp+0x20]
    1eed:	mov    r12,QWORD PTR [rsp+0x28]
    1ef2:	mov    r13,QWORD PTR [rsp+0x30]
    1ef7:	mov    r14,QWORD PTR [rsp+0x38]
    1efc:	mov    r15,QWORD PTR [rsp+0x40]
    1f01:	add    rsp,0x50
    1f05:	mov    rsp,rbp
    1f08:	pop    rbp
    1f09:	ret
    1f0a:	mov    rcx,r14
    1f0d:	mov    rsi,rbx
    1f10:	mov    QWORD PTR [rcx],rsi
    1f13:	mov    rax,r15
    1f16:	mov    QWORD PTR [rcx+0x8],rax
    1f1a:	mov    rax,r13
    1f1d:	mov    rbx,QWORD PTR [rsp+0x20]
    1f22:	mov    r12,QWORD PTR [rsp+0x28]
    1f27:	mov    r13,QWORD PTR [rsp+0x30]
    1f2c:	mov    r14,QWORD PTR [rsp+0x38]
    1f31:	mov    r15,QWORD PTR [rsp+0x40]
    1f36:	add    rsp,0x50
    1f3a:	mov    rsp,rbp
    1f3d:	pop    rbp
    1f3e:	ret

0000000000001f3f <botlish_entry_19: char_at<generic>>:
    1f3f:	push   rbp
    1f40:	mov    rbp,rsp
    1f43:	ud2
    1f45:	add    BYTE PTR [rax],al
	...

0000000000001f48 <botlish_fn_20: scan_local<generic>>:
    1f48:	push   rbp
    1f49:	mov    rbp,rsp
    1f4c:	sub    rsp,0x80
    1f53:	mov    QWORD PTR [rsp+0x50],rbx
    1f58:	mov    QWORD PTR [rsp+0x58],r12
    1f5d:	mov    QWORD PTR [rsp+0x60],r13
    1f62:	mov    QWORD PTR [rsp+0x68],r14
    1f67:	mov    QWORD PTR [rsp+0x70],r15
    1f6c:	mov    rax,rdi
    1f6f:	mov    QWORD PTR [rsp+0x18],0x0
    1f78:	mov    QWORD PTR [rsp],rsi
    1f7c:	mov    r14,rsi
    1f7f:	mov    QWORD PTR [rsp+0x8],rdx
    1f84:	mov    QWORD PTR [rsp+0x10],rcx
    1f89:	mov    r12,rcx
    1f8c:	mov    r11d,0x1
    1f92:	mov    rsi,r14
    1f95:	test   rsi,0x1
    1f9c:	jne    1fbe <botlish_fn_20+0x76>
    1fa2:	xor    r11d,r11d
    1fa5:	test   rsi,0x7
    1fac:	jne    1fbe <botlish_fn_20+0x76>
    1fb2:	movzx  rdi,BYTE PTR [rsi]
    1fb6:	cmp    dil,0x1
    1fba:	sete   r11b
    1fbe:	test   r11b,r11b
    1fc1:	jne    1fe2 <botlish_fn_20+0x9a>
    1fc7:	mov    rdi,rax
    1fca:	mov    r9,QWORD PTR [rdi+0x10]
    1fce:	mov    rcx,QWORD PTR [r9+0xc8]
    1fd5:	xor    rdx,rdx
    1fd8:	call   1fdd <botlish_fn_20+0x95>
			1fd9: R_X86_64_PLT32	rt_type_error-0x4
    1fdd:	jmp    2095 <botlish_fn_20+0x14d>
    1fe2:	mov    r13,rdx
    1fe5:	mov    r10,rsi
    1fe8:	and    r10,r13
    1feb:	mov    r14,rsi
    1fee:	test   r10,0x1
    1ff5:	jne    2021 <botlish_fn_20+0xd9>
    1ffb:	mov    rbx,rax
    1ffe:	mov    rdx,r13
    2001:	mov    rsi,r14
    2004:	mov    rdi,rbx
    2007:	call   200c <botlish_fn_20+0xc4>
			2008: R_X86_64_PLT32	rt_int_cmp-0x4
    200c:	mov    ecx,0x2
    2011:	test   rax,rax
    2014:	cmovge rcx,QWORD PTR [rip+0x24c]        # 2268 <botlish_fn_20+0x320>
    201c:	jmp    2037 <botlish_fn_20+0xef>
    2021:	mov    rbx,rax
    2024:	mov    ecx,0x2
    2029:	mov    rsi,r14
    202c:	cmp    rsi,r13
    202f:	cmovge rcx,QWORD PTR [rip+0x231]        # 2268 <botlish_fn_20+0x320>
    2037:	mov    eax,0x6
    203c:	mov    QWORD PTR [rsp+0x30],rax
    2041:	cmp    rcx,0x6
    2045:	je     223b <botlish_fn_20+0x2f3>
    204b:	lea    rcx,[rsp+0x20]
    2050:	mov    rdx,r12
    2053:	mov    rsi,r14
    2056:	mov    rdi,rbx
    2059:	call   205e <botlish_fn_20+0x116>
			205a: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    205e:	mov    rsi,rax
    2061:	mov    r15,rax
    2064:	test   rax,rsi
    2067:	je     2095 <botlish_fn_20+0x14d>
    206d:	mov    rdx,QWORD PTR [rsp+0x20]
    2072:	mov    QWORD PTR [rsp+0x40],rdx
    2077:	mov    rcx,QWORD PTR [rsp+0x28]
    207c:	mov    QWORD PTR [rsp+0x38],rcx
    2081:	mov    rsi,r15
    2084:	mov    rdi,rbx
    2087:	call   208c <botlish_fn_20+0x144>
			2088: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    208c:	test   rax,rax
    208f:	jne    20bd <botlish_fn_20+0x175>
    2095:	xor    rax,rax
    2098:	mov    rbx,QWORD PTR [rsp+0x50]
    209d:	mov    r12,QWORD PTR [rsp+0x58]
    20a2:	mov    r13,QWORD PTR [rsp+0x60]
    20a7:	mov    r14,QWORD PTR [rsp+0x68]
    20ac:	mov    r15,QWORD PTR [rsp+0x70]
    20b1:	add    rsp,0x80
    20b8:	mov    rsp,rbp
    20bb:	pop    rbp
    20bc:	ret
    20bd:	cmp    rax,0x6
    20c1:	je     21bc <botlish_fn_20+0x274>
    20c7:	mov    rax,QWORD PTR [rbx+0x10]
    20cb:	mov    r8,QWORD PTR [rax+0x128]
    20d2:	mov    rcx,QWORD PTR [rsp+0x38]
    20d7:	mov    rdx,QWORD PTR [rsp+0x40]
    20dc:	mov    rsi,r15
    20df:	mov    rdi,rbx
    20e2:	call   20e7 <botlish_fn_20+0x19f>
			20e3: R_X86_64_PLT32	rt_str_region_eq-0x4
    20e7:	cmp    rax,0x6
    20eb:	je     21b2 <botlish_fn_20+0x26a>
    20f1:	mov    rax,QWORD PTR [rbx+0x10]
    20f5:	mov    r8,QWORD PTR [rax+0x130]
    20fc:	mov    rcx,QWORD PTR [rsp+0x38]
    2101:	mov    rdx,QWORD PTR [rsp+0x40]
    2106:	mov    rsi,r15
    2109:	mov    rdi,rbx
    210c:	call   2111 <botlish_fn_20+0x1c9>
			210d: R_X86_64_PLT32	rt_str_region_eq-0x4
    2111:	cmp    rax,0x6
    2115:	je     21a8 <botlish_fn_20+0x260>
    211b:	mov    rax,QWORD PTR [rbx+0x10]
    211f:	mov    r8,QWORD PTR [rax+0xd0]
    2126:	mov    rcx,QWORD PTR [rsp+0x38]
    212b:	mov    rdx,QWORD PTR [rsp+0x40]
    2130:	mov    rsi,r15
    2133:	mov    rdi,rbx
    2136:	call   213b <botlish_fn_20+0x1f3>
			2137: R_X86_64_PLT32	rt_str_region_eq-0x4
    213b:	cmp    rax,0x6
    213f:	je     219e <botlish_fn_20+0x256>
    2145:	mov    rax,QWORD PTR [rbx+0x10]
    2149:	mov    r8,QWORD PTR [rax+0x118]
    2150:	mov    rcx,QWORD PTR [rsp+0x38]
    2155:	mov    rdx,QWORD PTR [rsp+0x40]
    215a:	mov    rsi,r15
    215d:	mov    rdi,rbx
    2160:	call   2165 <botlish_fn_20+0x21d>
			2161: R_X86_64_PLT32	rt_str_region_eq-0x4
    2165:	cmp    rax,0x6
    2169:	je     2194 <botlish_fn_20+0x24c>
    216f:	mov    rax,QWORD PTR [rbx+0x10]
    2173:	mov    r8,QWORD PTR [rax+0x138]
    217a:	mov    rcx,QWORD PTR [rsp+0x38]
    217f:	mov    rdx,QWORD PTR [rsp+0x40]
    2184:	mov    rsi,r15
    2187:	mov    rdi,rbx
    218a:	call   218f <botlish_fn_20+0x247>
			218b: R_X86_64_PLT32	rt_str_region_eq-0x4
    218f:	jmp    21c1 <botlish_fn_20+0x279>
    2194:	mov    rax,QWORD PTR [rsp+0x30]
    2199:	jmp    21c1 <botlish_fn_20+0x279>
    219e:	mov    rax,QWORD PTR [rsp+0x30]
    21a3:	jmp    21c1 <botlish_fn_20+0x279>
    21a8:	mov    rax,QWORD PTR [rsp+0x30]
    21ad:	jmp    21c1 <botlish_fn_20+0x279>
    21b2:	mov    rax,QWORD PTR [rsp+0x30]
    21b7:	jmp    21c1 <botlish_fn_20+0x279>
    21bc:	mov    rax,QWORD PTR [rsp+0x30]
    21c1:	cmp    rax,0x6
    21c5:	je     21d3 <botlish_fn_20+0x28b>
    21cb:	mov    rax,r14
    21ce:	jmp    223e <botlish_fn_20+0x2f6>
    21d3:	mov    QWORD PTR [rsp+0x18],0x3
    21dc:	mov    rsi,r14
    21df:	test   rsi,0x1
    21e6:	je     220c <botlish_fn_20+0x2c4>
    21ec:	mov    rsi,r14
    21ef:	mov    rax,rsi
    21f2:	add    rax,0x2
    21f6:	seto   cl
    21f9:	test   cl,cl
    21fb:	jne    220c <botlish_fn_20+0x2c4>
    2201:	mov    rsi,rax
    2204:	mov    r14,rax
    2207:	jmp    2222 <botlish_fn_20+0x2da>
    220c:	mov    edx,0x3
    2211:	mov    rsi,r14
    2214:	mov    rdi,rbx
    2217:	call   221c <botlish_fn_20+0x2d4>
			2218: R_X86_64_PLT32	rt_int_add-0x4
    221c:	mov    rsi,rax
    221f:	mov    r14,rax
    2222:	mov    QWORD PTR [rsp],rsi
    2226:	mov    QWORD PTR [rsp+0x8],r13
    222b:	mov    QWORD PTR [rsp+0x10],r12
    2230:	mov    rax,rbx
    2233:	mov    rdx,r13
    2236:	jmp    1f8c <botlish_fn_20+0x44>
    223b:	mov    rax,r14
    223e:	mov    rbx,QWORD PTR [rsp+0x50]
    2243:	mov    r12,QWORD PTR [rsp+0x58]
    2248:	mov    r13,QWORD PTR [rsp+0x60]
    224d:	mov    r14,QWORD PTR [rsp+0x68]
    2252:	mov    r15,QWORD PTR [rsp+0x70]
    2257:	add    rsp,0x80
    225e:	mov    rsp,rbp
    2261:	pop    rbp
    2262:	ret
    2263:	add    BYTE PTR [rax],al
    2265:	add    BYTE PTR [rax],al
    2267:	add    BYTE PTR [rsi],al
    2269:	add    BYTE PTR [rax],al
    226b:	add    BYTE PTR [rax],al
    226d:	add    BYTE PTR [rax],al
	...

0000000000002270 <botlish_entry_20: scan_local<generic>>:
    2270:	push   rbp
    2271:	mov    rbp,rsp
    2274:	mov    rsi,QWORD PTR [rdx]
    2277:	mov    r8,QWORD PTR [rdx+0x8]
    227b:	mov    rcx,QWORD PTR [rdx+0x10]
    227f:	mov    rdx,r8
    2282:	call   2287 <botlish_entry_20+0x17>
			2283: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    2287:	mov    rsp,rbp
    228a:	pop    rbp
    228b:	ret
    228c:	add    BYTE PTR [rax],al
	...

0000000000002290 <botlish_fn_21: scan_label<generic>>:
    2290:	push   rbp
    2291:	mov    rbp,rsp
    2294:	sub    rsp,0x80
    229b:	mov    QWORD PTR [rsp+0x50],rbx
    22a0:	mov    QWORD PTR [rsp+0x58],r12
    22a5:	mov    QWORD PTR [rsp+0x60],r13
    22aa:	mov    QWORD PTR [rsp+0x68],r14
    22af:	mov    QWORD PTR [rsp+0x70],r15
    22b4:	mov    QWORD PTR [rsp+0x18],0x0
    22bd:	mov    QWORD PTR [rsp],rsi
    22c1:	mov    r14,rsi
    22c4:	mov    QWORD PTR [rsp+0x8],rdx
    22c9:	mov    QWORD PTR [rsp+0x10],rcx
    22ce:	mov    r12,rcx
    22d1:	mov    r11d,0x1
    22d7:	mov    rsi,r14
    22da:	test   rsi,0x1
    22e1:	jne    2301 <botlish_fn_21+0x71>
    22e7:	xor    r11d,r11d
    22ea:	test   rsi,0x7
    22f1:	jne    2301 <botlish_fn_21+0x71>
    22f7:	movzx  rax,BYTE PTR [rsi]
    22fb:	cmp    al,0x1
    22fd:	sete   r11b
    2301:	test   r11b,r11b
    2304:	jne    2322 <botlish_fn_21+0x92>
    230a:	mov    rax,QWORD PTR [rdi+0x10]
    230e:	mov    rcx,QWORD PTR [rax+0xc8]
    2315:	xor    rdx,rdx
    2318:	call   231d <botlish_fn_21+0x8d>
			2319: R_X86_64_PLT32	rt_type_error-0x4
    231d:	jmp    23ce <botlish_fn_21+0x13e>
    2322:	mov    r13,rdx
    2325:	mov    rax,rsi
    2328:	and    rax,r13
    232b:	mov    r14,rsi
    232e:	test   rax,0x1
    2334:	jne    235d <botlish_fn_21+0xcd>
    233a:	mov    rbx,rdi
    233d:	mov    rdx,r13
    2340:	mov    rsi,r14
    2343:	call   2348 <botlish_fn_21+0xb8>
			2344: R_X86_64_PLT32	rt_int_cmp-0x4
    2348:	mov    ecx,0x2
    234d:	test   rax,rax
    2350:	cmovge rcx,QWORD PTR [rip+0x178]        # 24d0 <botlish_fn_21+0x240>
    2358:	jmp    2373 <botlish_fn_21+0xe3>
    235d:	mov    rbx,rdi
    2360:	mov    ecx,0x2
    2365:	mov    rsi,r14
    2368:	cmp    rsi,r13
    236b:	cmovge rcx,QWORD PTR [rip+0x15d]        # 24d0 <botlish_fn_21+0x240>
    2373:	mov    eax,0x6
    2378:	mov    QWORD PTR [rsp+0x30],rax
    237d:	cmp    rcx,0x6
    2381:	je     24a4 <botlish_fn_21+0x214>
    2387:	lea    rcx,[rsp+0x20]
    238c:	mov    rdx,r12
    238f:	mov    rsi,r14
    2392:	mov    rdi,rbx
    2395:	call   239a <botlish_fn_21+0x10a>
			2396: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    239a:	test   rax,rax
    239d:	mov    r15,rax
    23a0:	je     23ce <botlish_fn_21+0x13e>
    23a6:	mov    rdx,QWORD PTR [rsp+0x20]
    23ab:	mov    QWORD PTR [rsp+0x40],rdx
    23b0:	mov    rcx,QWORD PTR [rsp+0x28]
    23b5:	mov    QWORD PTR [rsp+0x38],rcx
    23ba:	mov    rsi,r15
    23bd:	mov    rdi,rbx
    23c0:	call   23c5 <botlish_fn_21+0x135>
			23c1: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    23c5:	test   rax,rax
    23c8:	jne    23f6 <botlish_fn_21+0x166>
    23ce:	xor    rax,rax
    23d1:	mov    rbx,QWORD PTR [rsp+0x50]
    23d6:	mov    r12,QWORD PTR [rsp+0x58]
    23db:	mov    r13,QWORD PTR [rsp+0x60]
    23e0:	mov    r14,QWORD PTR [rsp+0x68]
    23e5:	mov    r15,QWORD PTR [rsp+0x70]
    23ea:	add    rsp,0x80
    23f1:	mov    rsp,rbp
    23f4:	pop    rbp
    23f5:	ret
    23f6:	cmp    rax,0x6
    23fa:	je     2425 <botlish_fn_21+0x195>
    2400:	mov    r11,QWORD PTR [rbx+0x10]
    2404:	mov    r8,QWORD PTR [r11+0x138]
    240b:	mov    rcx,QWORD PTR [rsp+0x38]
    2410:	mov    rdx,QWORD PTR [rsp+0x40]
    2415:	mov    rsi,r15
    2418:	mov    rdi,rbx
    241b:	call   2420 <botlish_fn_21+0x190>
			241c: R_X86_64_PLT32	rt_str_region_eq-0x4
    2420:	jmp    242a <botlish_fn_21+0x19a>
    2425:	mov    rax,QWORD PTR [rsp+0x30]
    242a:	cmp    rax,0x6
    242e:	je     243c <botlish_fn_21+0x1ac>
    2434:	mov    rax,r14
    2437:	jmp    24a7 <botlish_fn_21+0x217>
    243c:	mov    QWORD PTR [rsp+0x18],0x3
    2445:	mov    rsi,r14
    2448:	test   rsi,0x1
    244f:	je     2475 <botlish_fn_21+0x1e5>
    2455:	mov    rsi,r14
    2458:	mov    rax,rsi
    245b:	add    rax,0x2
    245f:	seto   cl
    2462:	test   cl,cl
    2464:	jne    2475 <botlish_fn_21+0x1e5>
    246a:	mov    rsi,rax
    246d:	mov    r14,rax
    2470:	jmp    248b <botlish_fn_21+0x1fb>
    2475:	mov    edx,0x3
    247a:	mov    rsi,r14
    247d:	mov    rdi,rbx
    2480:	call   2485 <botlish_fn_21+0x1f5>
			2481: R_X86_64_PLT32	rt_int_add-0x4
    2485:	mov    rsi,rax
    2488:	mov    r14,rax
    248b:	mov    QWORD PTR [rsp],rsi
    248f:	mov    QWORD PTR [rsp+0x8],r13
    2494:	mov    QWORD PTR [rsp+0x10],r12
    2499:	mov    rdx,r13
    249c:	mov    rdi,rbx
    249f:	jmp    22d1 <botlish_fn_21+0x41>
    24a4:	mov    rax,r14
    24a7:	mov    rbx,QWORD PTR [rsp+0x50]
    24ac:	mov    r12,QWORD PTR [rsp+0x58]
    24b1:	mov    r13,QWORD PTR [rsp+0x60]
    24b6:	mov    r14,QWORD PTR [rsp+0x68]
    24bb:	mov    r15,QWORD PTR [rsp+0x70]
    24c0:	add    rsp,0x80
    24c7:	mov    rsp,rbp
    24ca:	pop    rbp
    24cb:	ret
    24cc:	add    BYTE PTR [rax],al
    24ce:	add    BYTE PTR [rax],al
    24d0:	(bad)
    24d1:	add    BYTE PTR [rax],al
    24d3:	add    BYTE PTR [rax],al
    24d5:	add    BYTE PTR [rax],al
	...

00000000000024d8 <botlish_entry_21: scan_label<generic>>:
    24d8:	push   rbp
    24d9:	mov    rbp,rsp
    24dc:	mov    rsi,QWORD PTR [rdx]
    24df:	mov    r8,QWORD PTR [rdx+0x8]
    24e3:	mov    rcx,QWORD PTR [rdx+0x10]
    24e7:	mov    rdx,r8
    24ea:	call   24ef <botlish_entry_21+0x17>
			24eb: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    24ef:	mov    rsp,rbp
    24f2:	pop    rbp
    24f3:	ret
    24f4:	add    BYTE PTR [rax],al
	...

00000000000024f8 <botlish_fn_22: scan_alpha<generic>>:
    24f8:	push   rbp
    24f9:	mov    rbp,rsp
    24fc:	sub    rsp,0x50
    2500:	mov    QWORD PTR [rsp+0x30],rbx
    2505:	mov    QWORD PTR [rsp+0x38],r12
    250a:	mov    QWORD PTR [rsp+0x40],r13
    250f:	mov    QWORD PTR [rsp+0x48],r14
    2514:	mov    r14,rdi
    2517:	mov    QWORD PTR [rsp+0x18],0x0
    2520:	mov    QWORD PTR [rsp],rsi
    2524:	mov    r13,rsi
    2527:	mov    QWORD PTR [rsp+0x8],rdx
    252c:	mov    r12,rdx
    252f:	mov    QWORD PTR [rsp+0x10],rcx
    2534:	mov    rbx,rcx
    2537:	mov    r11d,0x1
    253d:	mov    rsi,r13
    2540:	test   rsi,0x1
    2547:	jne    2567 <botlish_fn_22+0x6f>
    254d:	xor    r11d,r11d
    2550:	test   rsi,0x7
    2557:	jne    2567 <botlish_fn_22+0x6f>
    255d:	movzx  rax,BYTE PTR [rsi]
    2561:	cmp    al,0x1
    2563:	sete   r11b
    2567:	test   r11b,r11b
    256a:	jne    258b <botlish_fn_22+0x93>
    2570:	mov    rdi,r14
    2573:	mov    rax,QWORD PTR [rdi+0x10]
    2577:	mov    rcx,QWORD PTR [rax+0xc8]
    257e:	xor    rdx,rdx
    2581:	call   2586 <botlish_fn_22+0x8e>
			2582: R_X86_64_PLT32	rt_type_error-0x4
    2586:	jmp    261a <botlish_fn_22+0x122>
    258b:	mov    rax,rsi
    258e:	and    rax,r12
    2591:	mov    r13,rsi
    2594:	test   rax,0x1
    259a:	jne    25c3 <botlish_fn_22+0xcb>
    25a0:	mov    rdx,r12
    25a3:	mov    rsi,r13
    25a6:	mov    rdi,r14
    25a9:	call   25ae <botlish_fn_22+0xb6>
			25aa: R_X86_64_PLT32	rt_int_cmp-0x4
    25ae:	mov    ecx,0x2
    25b3:	test   rax,rax
    25b6:	cmovge rcx,QWORD PTR [rip+0x112]        # 26d0 <botlish_fn_22+0x1d8>
    25be:	jmp    25d6 <botlish_fn_22+0xde>
    25c3:	mov    ecx,0x2
    25c8:	mov    rsi,r13
    25cb:	cmp    rsi,r12
    25ce:	cmovge rcx,QWORD PTR [rip+0xfa]        # 26d0 <botlish_fn_22+0x1d8>
    25d6:	cmp    rcx,0x6
    25da:	je     26ae <botlish_fn_22+0x1b6>
    25e0:	lea    rcx,[rsp+0x20]
    25e5:	mov    rdx,rbx
    25e8:	mov    rsi,r13
    25eb:	mov    rdi,r14
    25ee:	call   25f3 <botlish_fn_22+0xfb>
			25ef: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    25f3:	test   rax,rax
    25f6:	mov    rsi,rax
    25f9:	je     261a <botlish_fn_22+0x122>
    25ff:	mov    rdx,QWORD PTR [rsp+0x20]
    2604:	mov    rcx,QWORD PTR [rsp+0x28]
    2609:	mov    rdi,r14
    260c:	call   2611 <botlish_fn_22+0x119>
			260d: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    2611:	test   rax,rax
    2614:	jne    263a <botlish_fn_22+0x142>
    261a:	xor    rax,rax
    261d:	mov    rbx,QWORD PTR [rsp+0x30]
    2622:	mov    r12,QWORD PTR [rsp+0x38]
    2627:	mov    r13,QWORD PTR [rsp+0x40]
    262c:	mov    r14,QWORD PTR [rsp+0x48]
    2631:	add    rsp,0x50
    2635:	mov    rsp,rbp
    2638:	pop    rbp
    2639:	ret
    263a:	cmp    rax,0x6
    263e:	je     264c <botlish_fn_22+0x154>
    2644:	mov    rax,r13
    2647:	jmp    26b1 <botlish_fn_22+0x1b9>
    264c:	mov    QWORD PTR [rsp+0x18],0x3
    2655:	mov    rsi,r13
    2658:	test   rsi,0x1
    265f:	je     2685 <botlish_fn_22+0x18d>
    2665:	mov    rsi,r13
    2668:	mov    r11,rsi
    266b:	add    r11,0x2
    266f:	seto   al
    2672:	test   al,al
    2674:	jne    2685 <botlish_fn_22+0x18d>
    267a:	mov    rsi,r11
    267d:	mov    r13,r11
    2680:	jmp    269b <botlish_fn_22+0x1a3>
    2685:	mov    edx,0x3
    268a:	mov    rsi,r13
    268d:	mov    rdi,r14
    2690:	call   2695 <botlish_fn_22+0x19d>
			2691: R_X86_64_PLT32	rt_int_add-0x4
    2695:	mov    rsi,rax
    2698:	mov    r13,rax
    269b:	mov    QWORD PTR [rsp],rsi
    269f:	mov    QWORD PTR [rsp+0x8],r12
    26a4:	mov    QWORD PTR [rsp+0x10],rbx
    26a9:	jmp    2537 <botlish_fn_22+0x3f>
    26ae:	mov    rax,r13
    26b1:	mov    rbx,QWORD PTR [rsp+0x30]
    26b6:	mov    r12,QWORD PTR [rsp+0x38]
    26bb:	mov    r13,QWORD PTR [rsp+0x40]
    26c0:	mov    r14,QWORD PTR [rsp+0x48]
    26c5:	add    rsp,0x50
    26c9:	mov    rsp,rbp
    26cc:	pop    rbp
    26cd:	ret
    26ce:	add    BYTE PTR [rax],al
    26d0:	(bad)
    26d1:	add    BYTE PTR [rax],al
    26d3:	add    BYTE PTR [rax],al
    26d5:	add    BYTE PTR [rax],al
	...

00000000000026d8 <botlish_entry_22: scan_alpha<generic>>:
    26d8:	push   rbp
    26d9:	mov    rbp,rsp
    26dc:	mov    rsi,QWORD PTR [rdx]
    26df:	mov    r8,QWORD PTR [rdx+0x8]
    26e3:	mov    rcx,QWORD PTR [rdx+0x10]
    26e7:	mov    rdx,r8
    26ea:	call   26ef <botlish_entry_22+0x17>
			26eb: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    26ef:	mov    rsp,rbp
    26f2:	pop    rbp
    26f3:	ret
    26f4:	add    BYTE PTR [rax],al
	...

00000000000026f8 <botlish_fn_23: tld_ok<generic>>:
    26f8:	push   rbp
    26f9:	mov    rbp,rsp
    26fc:	sub    rsp,0x40
    2700:	mov    QWORD PTR [rsp+0x20],rbx
    2705:	mov    QWORD PTR [rsp+0x28],r12
    270a:	mov    QWORD PTR [rsp+0x30],r13
    270f:	mov    QWORD PTR [rsp+0x38],r14
    2714:	mov    rbx,rdi
    2717:	mov    QWORD PTR [rsp],rsi
    271b:	mov    r12,rsi
    271e:	mov    QWORD PTR [rsp+0x8],rdx
    2723:	mov    r14,rdx
    2726:	mov    QWORD PTR [rsp+0x10],rcx
    272b:	mov    rdx,r14
    272e:	mov    rsi,r12
    2731:	mov    rdi,rbx
    2734:	call   2739 <botlish_fn_23+0x41>
			2735: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    2739:	mov    rsi,rax
    273c:	mov    r13,rax
    273f:	test   rax,rsi
    2742:	je     2805 <botlish_fn_23+0x10d>
    2748:	mov    rax,r13
    274b:	mov    QWORD PTR [rsp+0x8],rax
    2750:	mov    rdx,r14
    2753:	and    rax,rdx
    2756:	test   rax,0x1
    275c:	jne    2785 <botlish_fn_23+0x8d>
    2762:	mov    rsi,r13
    2765:	mov    rdi,rbx
    2768:	call   276d <botlish_fn_23+0x75>
			2769: R_X86_64_PLT32	rt_int_cmp-0x4
    276d:	mov    ecx,0x2
    2772:	test   rax,rax
    2775:	cmove  rcx,QWORD PTR [rip+0x15b]        # 28d8 <botlish_fn_23+0x1e0>
    277d:	mov    rax,r13
    2780:	jmp    2798 <botlish_fn_23+0xa0>
    2785:	mov    ecx,0x2
    278a:	mov    rax,r13
    278d:	cmp    rax,rdx
    2790:	cmove  rcx,QWORD PTR [rip+0x140]        # 28d8 <botlish_fn_23+0x1e0>
    2798:	cmp    rcx,0x6
    279c:	je     27af <botlish_fn_23+0xb7>
    27a2:	mov    ecx,0x2
    27a7:	mov    rax,rcx
    27aa:	jmp    28b7 <botlish_fn_23+0x1bf>
    27af:	mov    ecx,0x1
    27b4:	mov    rsi,r12
    27b7:	test   rsi,0x1
    27be:	jne    27e4 <botlish_fn_23+0xec>
    27c4:	xor    ecx,ecx
    27c6:	mov    rsi,r12
    27c9:	test   rsi,0x7
    27d0:	jne    27e4 <botlish_fn_23+0xec>
    27d6:	mov    rsi,r12
    27d9:	movzx  rcx,BYTE PTR [rsi]
    27dd:	rex cmp cl,0x1
    27e1:	sete   cl
    27e4:	test   cl,cl
    27e6:	jne    2825 <botlish_fn_23+0x12d>
    27ec:	mov    rdi,rbx
    27ef:	mov    rsi,QWORD PTR [rdi+0x10]
    27f3:	mov    rcx,QWORD PTR [rsi+0x138]
    27fa:	xor    rdx,rdx
    27fd:	mov    rsi,r12
    2800:	call   2805 <botlish_fn_23+0x10d>
			2801: R_X86_64_PLT32	rt_type_error-0x4
    2805:	xor    rax,rax
    2808:	mov    rbx,QWORD PTR [rsp+0x20]
    280d:	mov    r12,QWORD PTR [rsp+0x28]
    2812:	mov    r13,QWORD PTR [rsp+0x30]
    2817:	mov    r14,QWORD PTR [rsp+0x38]
    281c:	add    rsp,0x40
    2820:	mov    rsp,rbp
    2823:	pop    rbp
    2824:	ret
    2825:	mov    rsi,r12
    2828:	mov    rdi,rax
    282b:	and    rdi,rsi
    282e:	test   rdi,0x1
    2835:	jne    2846 <botlish_fn_23+0x14e>
    283b:	mov    rdx,r12
    283e:	mov    rsi,rax
    2841:	jmp    2869 <botlish_fn_23+0x171>
    2846:	mov    rsi,r12
    2849:	mov    r8,rax
    284c:	sub    r8,rsi
    284f:	mov    r13,rax
    2852:	seto   r10b
    2856:	lea    rsi,[r8+0x1]
    285a:	test   r10b,r10b
    285d:	je     2874 <botlish_fn_23+0x17c>
    2863:	mov    rdx,r12
    2866:	mov    rsi,r13
    2869:	mov    rdi,rbx
    286c:	call   2871 <botlish_fn_23+0x179>
			286d: R_X86_64_PLT32	rt_int_sub-0x4
    2871:	mov    rsi,rax
    2874:	test   rsi,0x1
    287b:	jne    28a6 <botlish_fn_23+0x1ae>
    2881:	mov    edx,0x5
    2886:	mov    rdi,rbx
    2889:	call   288e <botlish_fn_23+0x196>
			288a: R_X86_64_PLT32	rt_int_cmp-0x4
    288e:	mov    ecx,0x2
    2893:	test   rax,rax
    2896:	mov    rax,rcx
    2899:	cmovge rax,QWORD PTR [rip+0x37]        # 28d8 <botlish_fn_23+0x1e0>
    28a1:	jmp    28b7 <botlish_fn_23+0x1bf>
    28a6:	mov    eax,0x2
    28ab:	cmp    rsi,0x5
    28af:	cmovge rax,QWORD PTR [rip+0x21]        # 28d8 <botlish_fn_23+0x1e0>
    28b7:	mov    rbx,QWORD PTR [rsp+0x20]
    28bc:	mov    r12,QWORD PTR [rsp+0x28]
    28c1:	mov    r13,QWORD PTR [rsp+0x30]
    28c6:	mov    r14,QWORD PTR [rsp+0x38]
    28cb:	add    rsp,0x40
    28cf:	mov    rsp,rbp
    28d2:	pop    rbp
    28d3:	ret
    28d4:	add    BYTE PTR [rax],al
    28d6:	add    BYTE PTR [rax],al
    28d8:	(bad)
    28d9:	add    BYTE PTR [rax],al
    28db:	add    BYTE PTR [rax],al
    28dd:	add    BYTE PTR [rax],al
	...

00000000000028e0 <botlish_entry_23: tld_ok<generic>>:
    28e0:	push   rbp
    28e1:	mov    rbp,rsp
    28e4:	mov    rsi,QWORD PTR [rdx]
    28e7:	mov    r8,QWORD PTR [rdx+0x8]
    28eb:	mov    rcx,QWORD PTR [rdx+0x10]
    28ef:	mov    rdx,r8
    28f2:	call   28f7 <botlish_entry_23+0x17>
			28f3: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    28f7:	mov    rsp,rbp
    28fa:	pop    rbp
    28fb:	ret
    28fc:	add    BYTE PTR [rax],al
	...

0000000000002900 <botlish_fn_24: domain_loop<generic>>:
    2900:	push   rbp
    2901:	mov    rbp,rsp
    2904:	sub    rsp,0x70
    2908:	mov    QWORD PTR [rsp+0x40],rbx
    290d:	mov    QWORD PTR [rsp+0x48],r12
    2912:	mov    QWORD PTR [rsp+0x50],r13
    2917:	mov    QWORD PTR [rsp+0x58],r14
    291c:	mov    QWORD PTR [rsp+0x60],r15
    2921:	mov    QWORD PTR [rsp+0x18],0x0
    292a:	mov    QWORD PTR [rsp],rsi
    292e:	mov    QWORD PTR [rsp+0x8],rdx
    2933:	mov    QWORD PTR [rsp+0x10],rcx
    2938:	lea    rbx,[rsp+0x20]
    293d:	mov    r12,rdi
    2940:	mov    r13,rcx
    2943:	mov    r14,rdx
    2946:	mov    QWORD PTR [rsp+0x30],rsi
    294b:	mov    rcx,r13
    294e:	mov    rdx,r14
    2951:	mov    rsi,QWORD PTR [rsp+0x30]
    2956:	mov    rdi,r12
    2959:	call   295e <botlish_fn_24+0x5e>
			295a: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    295e:	mov    rcx,rax
    2961:	mov    r15,rax
    2964:	test   rax,rcx
    2967:	je     2ab7 <botlish_fn_24+0x1b7>
    296d:	mov    rax,r15
    2970:	mov    QWORD PTR [rsp],rax
    2974:	mov    rdx,QWORD PTR [rsp+0x30]
    2979:	and    rax,rdx
    297c:	test   rax,0x1
    2982:	jne    29a1 <botlish_fn_24+0xa1>
    2988:	mov    rsi,r15
    298b:	mov    rdi,r12
    298e:	call   2993 <botlish_fn_24+0x93>
			298f: R_X86_64_PLT32	rt_value_eq-0x4
    2993:	test   rax,rax
    2996:	je     2ab7 <botlish_fn_24+0x1b7>
    299c:	jmp    29b1 <botlish_fn_24+0xb1>
    29a1:	mov    eax,0x2
    29a6:	cmp    r15,rdx
    29a9:	cmove  rax,QWORD PTR [rip+0x187]        # 2b38 <botlish_fn_24+0x238>
    29b1:	cmp    rax,0x6
    29b5:	je     2b0d <botlish_fn_24+0x20d>
    29bb:	mov    rax,r15
    29be:	and    rax,r14
    29c1:	test   rax,0x1
    29c7:	jne    29f0 <botlish_fn_24+0xf0>
    29cd:	mov    rdx,r14
    29d0:	mov    rsi,r15
    29d3:	mov    rdi,r12
    29d6:	call   29db <botlish_fn_24+0xdb>
			29d7: R_X86_64_PLT32	rt_int_cmp-0x4
    29db:	mov    ecx,0x2
    29e0:	test   rax,rax
    29e3:	cmovge rcx,QWORD PTR [rip+0x14d]        # 2b38 <botlish_fn_24+0x238>
    29eb:	jmp    2a00 <botlish_fn_24+0x100>
    29f0:	mov    ecx,0x2
    29f5:	cmp    r15,r14
    29f8:	cmovge rcx,QWORD PTR [rip+0x138]        # 2b38 <botlish_fn_24+0x238>
    2a00:	cmp    rcx,0x6
    2a04:	je     2afe <botlish_fn_24+0x1fe>
    2a0a:	mov    rcx,rbx
    2a0d:	mov    rdx,r13
    2a10:	mov    rsi,r15
    2a13:	mov    rdi,r12
    2a16:	call   2a1b <botlish_fn_24+0x11b>
			2a17: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    2a1b:	test   rax,rax
    2a1e:	je     2ab7 <botlish_fn_24+0x1b7>
    2a24:	mov    rdx,QWORD PTR [rsp+0x20]
    2a29:	mov    rcx,QWORD PTR [rsp+0x28]
    2a2e:	mov    rsi,QWORD PTR [r12+0x10]
    2a33:	mov    r8,QWORD PTR [rsi+0x128]
    2a3a:	mov    rsi,rax
    2a3d:	mov    rdi,r12
    2a40:	call   2a45 <botlish_fn_24+0x145>
			2a41: R_X86_64_PLT32	rt_str_region_eq-0x4
    2a45:	cmp    rax,0x6
    2a49:	je     2a5b <botlish_fn_24+0x15b>
    2a4f:	mov    r14,0xffffffffffffffff
    2a56:	jmp    2b05 <botlish_fn_24+0x205>
    2a5b:	mov    QWORD PTR [rsp+0x18],0x3
    2a64:	test   r15,0x1
    2a6b:	je     2a83 <botlish_fn_24+0x183>
    2a71:	mov    rdx,r15
    2a74:	add    rdx,0x2
    2a78:	seto   al
    2a7b:	test   al,al
    2a7d:	je     2a96 <botlish_fn_24+0x196>
    2a83:	mov    edx,0x3
    2a88:	mov    rsi,r15
    2a8b:	mov    rdi,r12
    2a8e:	call   2a93 <botlish_fn_24+0x193>
			2a8f: R_X86_64_PLT32	rt_int_add-0x4
    2a93:	mov    rdx,rax
    2a96:	mov    QWORD PTR [rsp],rdx
    2a9a:	mov    r15,rdx
    2a9d:	mov    rcx,r13
    2aa0:	mov    rdx,r14
    2aa3:	mov    rsi,r15
    2aa6:	mov    rdi,r12
    2aa9:	call   2aae <botlish_fn_24+0x1ae>
			2aaa: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    2aae:	test   rax,rax
    2ab1:	jne    2adc <botlish_fn_24+0x1dc>
    2ab7:	xor    rax,rax
    2aba:	mov    rbx,QWORD PTR [rsp+0x40]
    2abf:	mov    r12,QWORD PTR [rsp+0x48]
    2ac4:	mov    r13,QWORD PTR [rsp+0x50]
    2ac9:	mov    r14,QWORD PTR [rsp+0x58]
    2ace:	mov    r15,QWORD PTR [rsp+0x60]
    2ad3:	add    rsp,0x70
    2ad7:	mov    rsp,rbp
    2ada:	pop    rbp
    2adb:	ret
    2adc:	cmp    rax,0x6
    2ae0:	je     2b05 <botlish_fn_24+0x205>
    2ae6:	mov    QWORD PTR [rsp],r15
    2aea:	mov    QWORD PTR [rsp+0x8],r14
    2aef:	mov    QWORD PTR [rsp+0x10],r13
    2af4:	mov    QWORD PTR [rsp+0x30],r15
    2af9:	jmp    294b <botlish_fn_24+0x4b>
    2afe:	mov    r14,0xffffffffffffffff
    2b05:	mov    rax,r14
    2b08:	jmp    2b14 <botlish_fn_24+0x214>
    2b0d:	mov    rax,0xffffffffffffffff
    2b14:	mov    rbx,QWORD PTR [rsp+0x40]
    2b19:	mov    r12,QWORD PTR [rsp+0x48]
    2b1e:	mov    r13,QWORD PTR [rsp+0x50]
    2b23:	mov    r14,QWORD PTR [rsp+0x58]
    2b28:	mov    r15,QWORD PTR [rsp+0x60]
    2b2d:	add    rsp,0x70
    2b31:	mov    rsp,rbp
    2b34:	pop    rbp
    2b35:	ret
    2b36:	add    BYTE PTR [rax],al
    2b38:	(bad)
    2b39:	add    BYTE PTR [rax],al
    2b3b:	add    BYTE PTR [rax],al
    2b3d:	add    BYTE PTR [rax],al
	...

0000000000002b40 <botlish_entry_24: domain_loop<generic>>:
    2b40:	push   rbp
    2b41:	mov    rbp,rsp
    2b44:	mov    rsi,QWORD PTR [rdx]
    2b47:	mov    r8,QWORD PTR [rdx+0x8]
    2b4b:	mov    rcx,QWORD PTR [rdx+0x10]
    2b4f:	mov    rdx,r8
    2b52:	call   2b57 <botlish_entry_24+0x17>
			2b53: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    2b57:	mov    rsp,rbp
    2b5a:	pop    rbp
    2b5b:	ret
    2b5c:	add    BYTE PTR [rax],al
	...

0000000000002b60 <botlish_fn_25: <str>>:
    2b60:	push   rbp
    2b61:	mov    rbp,rsp
    2b64:	sub    rsp,0x50
    2b68:	mov    QWORD PTR [rsp+0x30],rbx
    2b6d:	mov    QWORD PTR [rsp+0x38],r12
    2b72:	mov    QWORD PTR [rsp+0x40],r13
    2b77:	mov    QWORD PTR [rsp+0x48],r14
    2b7c:	mov    r13,rdi
    2b7f:	mov    QWORD PTR [rsp+0x18],0x0
    2b88:	mov    QWORD PTR [rsp],rsi
    2b8c:	mov    r14,rsi
    2b8f:	mov    rsi,r14
    2b92:	mov    rdi,r13
    2b95:	call   2b9a <botlish_fn_25+0x3a>
			2b96: R_X86_64_PLT32	rt_str_len-0x4
    2b9a:	mov    rbx,rax
    2b9d:	mov    QWORD PTR [rsp+0x8],rax
    2ba2:	mov    esi,0x1
    2ba7:	mov    QWORD PTR [rsp+0x10],0x1
    2bb0:	mov    rcx,r14
    2bb3:	mov    rdx,rbx
    2bb6:	mov    rdi,r13
    2bb9:	call   2bbe <botlish_fn_25+0x5e>
			2bba: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    2bbe:	mov    r12,rax
    2bc1:	test   r12,r12
    2bc4:	je     2d21 <botlish_fn_25+0x1c1>
    2bca:	mov    QWORD PTR [rsp+0x10],r12
    2bcf:	test   r12,0x1
    2bd6:	jne    2c01 <botlish_fn_25+0xa1>
    2bdc:	mov    edx,0x1
    2be1:	mov    rsi,r12
    2be4:	mov    rdi,r13
    2be7:	call   2bec <botlish_fn_25+0x8c>
			2be8: R_X86_64_PLT32	rt_int_cmp-0x4
    2bec:	mov    ecx,0x2
    2bf1:	test   rax,rax
    2bf4:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 2dc0 <botlish_fn_25+0x260>
    2bfc:	jmp    2c12 <botlish_fn_25+0xb2>
    2c01:	mov    ecx,0x2
    2c06:	cmp    r12,0x1
    2c0a:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 2dc0 <botlish_fn_25+0x260>
    2c12:	cmp    rcx,0x6
    2c16:	je     2d9c <botlish_fn_25+0x23c>
    2c1c:	mov    rcx,r12
    2c1f:	and    rcx,rbx
    2c22:	test   rcx,0x1
    2c29:	jne    2c52 <botlish_fn_25+0xf2>
    2c2f:	mov    rdx,rbx
    2c32:	mov    rsi,r12
    2c35:	mov    rdi,r13
    2c38:	call   2c3d <botlish_fn_25+0xdd>
			2c39: R_X86_64_PLT32	rt_int_cmp-0x4
    2c3d:	mov    ecx,0x2
    2c42:	test   rax,rax
    2c45:	cmovge rcx,QWORD PTR [rip+0x173]        # 2dc0 <botlish_fn_25+0x260>
    2c4d:	jmp    2c62 <botlish_fn_25+0x102>
    2c52:	mov    ecx,0x2
    2c57:	cmp    r12,rbx
    2c5a:	cmovge rcx,QWORD PTR [rip+0x15e]        # 2dc0 <botlish_fn_25+0x260>
    2c62:	cmp    rcx,0x6
    2c66:	je     2d92 <botlish_fn_25+0x232>
    2c6c:	lea    rcx,[rsp+0x20]
    2c71:	mov    rdx,r14
    2c74:	mov    rsi,r12
    2c77:	mov    rdi,r13
    2c7a:	call   2c7f <botlish_fn_25+0x11f>
			2c7b: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    2c7f:	test   rax,rax
    2c82:	mov    rsi,rax
    2c85:	je     2d21 <botlish_fn_25+0x1c1>
    2c8b:	mov    rdx,QWORD PTR [rsp+0x20]
    2c90:	mov    rcx,QWORD PTR [rsp+0x28]
    2c95:	mov    rdi,r13
    2c98:	mov    rax,QWORD PTR [rdi+0x10]
    2c9c:	mov    r8,QWORD PTR [rax+0x110]
    2ca3:	call   2ca8 <botlish_fn_25+0x148>
			2ca4: R_X86_64_PLT32	rt_str_region_eq-0x4
    2ca8:	cmp    rax,0x6
    2cac:	je     2cbf <botlish_fn_25+0x15f>
    2cb2:	mov    ecx,0x2
    2cb7:	mov    rax,rcx
    2cba:	jmp    2da1 <botlish_fn_25+0x241>
    2cbf:	mov    QWORD PTR [rsp+0x18],0x3
    2cc8:	test   r12,0x1
    2ccf:	jne    2cdd <botlish_fn_25+0x17d>
    2cd5:	mov    rcx,r12
    2cd8:	jmp    2cf2 <botlish_fn_25+0x192>
    2cdd:	mov    rsi,r12
    2ce0:	add    rsi,0x2
    2ce4:	mov    rcx,r12
    2ce7:	seto   al
    2cea:	test   al,al
    2cec:	je     2d05 <botlish_fn_25+0x1a5>
    2cf2:	mov    edx,0x3
    2cf7:	mov    rsi,rcx
    2cfa:	mov    rdi,r13
    2cfd:	call   2d02 <botlish_fn_25+0x1a2>
			2cfe: R_X86_64_PLT32	rt_int_add-0x4
    2d02:	mov    rsi,rax
    2d05:	mov    QWORD PTR [rsp+0x10],rsi
    2d0a:	mov    rcx,r14
    2d0d:	mov    rdx,rbx
    2d10:	mov    rdi,r13
    2d13:	call   2d18 <botlish_fn_25+0x1b8>
			2d14: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    2d18:	test   rax,rax
    2d1b:	jne    2d41 <botlish_fn_25+0x1e1>
    2d21:	xor    rax,rax
    2d24:	mov    rbx,QWORD PTR [rsp+0x30]
    2d29:	mov    r12,QWORD PTR [rsp+0x38]
    2d2e:	mov    r13,QWORD PTR [rsp+0x40]
    2d33:	mov    r14,QWORD PTR [rsp+0x48]
    2d38:	add    rsp,0x50
    2d3c:	mov    rsp,rbp
    2d3f:	pop    rbp
    2d40:	ret
    2d41:	mov    rcx,rax
    2d44:	and    rcx,rbx
    2d47:	mov    rsi,rax
    2d4a:	test   rcx,0x1
    2d51:	jne    2d7a <botlish_fn_25+0x21a>
    2d57:	mov    rdx,rbx
    2d5a:	mov    rdi,r13
    2d5d:	call   2d62 <botlish_fn_25+0x202>
			2d5e: R_X86_64_PLT32	rt_int_cmp-0x4
    2d62:	mov    ecx,0x2
    2d67:	test   rax,rax
    2d6a:	mov    rax,rcx
    2d6d:	cmove  rax,QWORD PTR [rip+0x4b]        # 2dc0 <botlish_fn_25+0x260>
    2d75:	jmp    2da1 <botlish_fn_25+0x241>
    2d7a:	mov    rdx,rbx
    2d7d:	mov    eax,0x2
    2d82:	cmp    rsi,rdx
    2d85:	cmove  rax,QWORD PTR [rip+0x33]        # 2dc0 <botlish_fn_25+0x260>
    2d8d:	jmp    2da1 <botlish_fn_25+0x241>
    2d92:	mov    eax,0x2
    2d97:	jmp    2da1 <botlish_fn_25+0x241>
    2d9c:	mov    eax,0x2
    2da1:	mov    rbx,QWORD PTR [rsp+0x30]
    2da6:	mov    r12,QWORD PTR [rsp+0x38]
    2dab:	mov    r13,QWORD PTR [rsp+0x40]
    2db0:	mov    r14,QWORD PTR [rsp+0x48]
    2db5:	add    rsp,0x50
    2db9:	mov    rsp,rbp
    2dbc:	pop    rbp
    2dbd:	ret
    2dbe:	add    BYTE PTR [rax],al
    2dc0:	(bad)
    2dc1:	add    BYTE PTR [rax],al
    2dc3:	add    BYTE PTR [rax],al
    2dc5:	add    BYTE PTR [rax],al
	...

0000000000002dc8 <botlish_entry_25: <str>>:
    2dc8:	push   rbp
    2dc9:	mov    rbp,rsp
    2dcc:	mov    rsi,QWORD PTR [rdx]
    2dcf:	call   2dd4 <botlish_entry_25+0xc>
			2dd0: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    2dd4:	mov    rsp,rbp
    2dd7:	pop    rbp
    2dd8:	ret
    2dd9:	add    BYTE PTR [rax],al
    2ddb:	add    BYTE PTR [rax],al
    2ddd:	add    BYTE PTR [rax],al
	...

0000000000002de0 <botlish_fn_26: <generic>>:
    2de0:	push   rbp
    2de1:	mov    rbp,rsp
    2de4:	sub    rsp,0x60
    2de8:	mov    QWORD PTR [rsp+0x30],rbx
    2ded:	mov    QWORD PTR [rsp+0x38],r12
    2df2:	mov    QWORD PTR [rsp+0x40],r13
    2df7:	mov    QWORD PTR [rsp+0x48],r14
    2dfc:	mov    QWORD PTR [rsp+0x50],r15
    2e01:	mov    QWORD PTR [rsp+0x18],0x0
    2e0a:	mov    QWORD PTR [rsp],rsi
    2e0e:	xor    r8d,r8d
    2e11:	test   rsi,0x7
    2e18:	jne    2e28 <botlish_fn_26+0x48>
    2e1e:	movzx  rax,BYTE PTR [rsi]
    2e22:	cmp    al,0x2
    2e24:	sete   r8b
    2e28:	test   r8b,r8b
    2e2b:	jne    2e4b <botlish_fn_26+0x6b>
    2e31:	mov    rdx,QWORD PTR [rdi+0x10]
    2e35:	mov    rcx,QWORD PTR [rdx+0xe8]
    2e3c:	mov    edx,0x1
    2e41:	call   2e46 <botlish_fn_26+0x66>
			2e42: R_X86_64_PLT32	rt_type_error-0x4
    2e46:	jmp    2fe0 <botlish_fn_26+0x200>
    2e4b:	mov    r13,rsi
    2e4e:	mov    r14,rdi
    2e51:	call   2e56 <botlish_fn_26+0x76>
			2e52: R_X86_64_PLT32	rt_str_len-0x4
    2e56:	mov    rbx,rax
    2e59:	mov    QWORD PTR [rsp+0x8],rax
    2e5e:	mov    edx,0x1
    2e63:	mov    r15,rdx
    2e66:	mov    QWORD PTR [rsp+0x10],0x1
    2e6f:	mov    rcx,r13
    2e72:	mov    rdx,rbx
    2e75:	mov    rsi,r15
    2e78:	mov    rdi,r14
    2e7b:	call   2e80 <botlish_fn_26+0xa0>
			2e7c: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    2e80:	mov    r12,rax
    2e83:	test   r12,r12
    2e86:	je     2fe0 <botlish_fn_26+0x200>
    2e8c:	mov    QWORD PTR [rsp+0x10],r12
    2e91:	test   r12,0x1
    2e98:	jne    2ec1 <botlish_fn_26+0xe1>
    2e9e:	mov    rdx,r15
    2ea1:	mov    rsi,r12
    2ea4:	mov    rdi,r14
    2ea7:	call   2eac <botlish_fn_26+0xcc>
			2ea8: R_X86_64_PLT32	rt_int_cmp-0x4
    2eac:	mov    ecx,0x2
    2eb1:	test   rax,rax
    2eb4:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 3088 <botlish_fn_26+0x2a8>
    2ebc:	jmp    2ed2 <botlish_fn_26+0xf2>
    2ec1:	mov    ecx,0x2
    2ec6:	cmp    r12,0x1
    2eca:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 3088 <botlish_fn_26+0x2a8>
    2ed2:	cmp    rcx,0x6
    2ed6:	je     3060 <botlish_fn_26+0x280>
    2edc:	mov    rax,r12
    2edf:	and    rax,rbx
    2ee2:	test   rax,0x1
    2ee8:	jne    2f11 <botlish_fn_26+0x131>
    2eee:	mov    rdx,rbx
    2ef1:	mov    rsi,r12
    2ef4:	mov    rdi,r14
    2ef7:	call   2efc <botlish_fn_26+0x11c>
			2ef8: R_X86_64_PLT32	rt_int_cmp-0x4
    2efc:	mov    ecx,0x2
    2f01:	test   rax,rax
    2f04:	cmovge rcx,QWORD PTR [rip+0x17c]        # 3088 <botlish_fn_26+0x2a8>
    2f0c:	jmp    2f21 <botlish_fn_26+0x141>
    2f11:	mov    ecx,0x2
    2f16:	cmp    r12,rbx
    2f19:	cmovge rcx,QWORD PTR [rip+0x167]        # 3088 <botlish_fn_26+0x2a8>
    2f21:	cmp    rcx,0x6
    2f25:	je     3056 <botlish_fn_26+0x276>
    2f2b:	lea    rcx,[rsp+0x20]
    2f30:	mov    rdx,r13
    2f33:	mov    rsi,r12
    2f36:	mov    rdi,r14
    2f39:	call   2f3e <botlish_fn_26+0x15e>
			2f3a: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    2f3e:	test   rax,rax
    2f41:	mov    rsi,rax
    2f44:	je     2fe0 <botlish_fn_26+0x200>
    2f4a:	mov    rdx,QWORD PTR [rsp+0x20]
    2f4f:	mov    rcx,QWORD PTR [rsp+0x28]
    2f54:	mov    rdi,r14
    2f57:	mov    rax,QWORD PTR [rdi+0x10]
    2f5b:	mov    r8,QWORD PTR [rax+0x110]
    2f62:	call   2f67 <botlish_fn_26+0x187>
			2f63: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f67:	cmp    rax,0x6
    2f6b:	je     2f7e <botlish_fn_26+0x19e>
    2f71:	mov    ecx,0x2
    2f76:	mov    rax,rcx
    2f79:	jmp    3065 <botlish_fn_26+0x285>
    2f7e:	mov    QWORD PTR [rsp+0x18],0x3
    2f87:	test   r12,0x1
    2f8e:	jne    2f9c <botlish_fn_26+0x1bc>
    2f94:	mov    rdi,r12
    2f97:	jmp    2fb1 <botlish_fn_26+0x1d1>
    2f9c:	mov    rsi,r12
    2f9f:	add    rsi,0x2
    2fa3:	mov    rdi,r12
    2fa6:	seto   al
    2fa9:	test   al,al
    2fab:	je     2fc4 <botlish_fn_26+0x1e4>
    2fb1:	mov    edx,0x3
    2fb6:	mov    rsi,rdi
    2fb9:	mov    rdi,r14
    2fbc:	call   2fc1 <botlish_fn_26+0x1e1>
			2fbd: R_X86_64_PLT32	rt_int_add-0x4
    2fc1:	mov    rsi,rax
    2fc4:	mov    QWORD PTR [rsp+0x10],rsi
    2fc9:	mov    rcx,r13
    2fcc:	mov    rdx,rbx
    2fcf:	mov    rdi,r14
    2fd2:	call   2fd7 <botlish_fn_26+0x1f7>
			2fd3: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    2fd7:	test   rax,rax
    2fda:	jne    3005 <botlish_fn_26+0x225>
    2fe0:	xor    rax,rax
    2fe3:	mov    rbx,QWORD PTR [rsp+0x30]
    2fe8:	mov    r12,QWORD PTR [rsp+0x38]
    2fed:	mov    r13,QWORD PTR [rsp+0x40]
    2ff2:	mov    r14,QWORD PTR [rsp+0x48]
    2ff7:	mov    r15,QWORD PTR [rsp+0x50]
    2ffc:	add    rsp,0x60
    3000:	mov    rsp,rbp
    3003:	pop    rbp
    3004:	ret
    3005:	mov    rcx,rax
    3008:	and    rcx,rbx
    300b:	mov    rsi,rax
    300e:	test   rcx,0x1
    3015:	jne    303e <botlish_fn_26+0x25e>
    301b:	mov    rdx,rbx
    301e:	mov    rdi,r14
    3021:	call   3026 <botlish_fn_26+0x246>
			3022: R_X86_64_PLT32	rt_int_cmp-0x4
    3026:	mov    ecx,0x2
    302b:	test   rax,rax
    302e:	mov    rax,rcx
    3031:	cmove  rax,QWORD PTR [rip+0x4f]        # 3088 <botlish_fn_26+0x2a8>
    3039:	jmp    3065 <botlish_fn_26+0x285>
    303e:	mov    rdx,rbx
    3041:	mov    eax,0x2
    3046:	cmp    rsi,rdx
    3049:	cmove  rax,QWORD PTR [rip+0x37]        # 3088 <botlish_fn_26+0x2a8>
    3051:	jmp    3065 <botlish_fn_26+0x285>
    3056:	mov    eax,0x2
    305b:	jmp    3065 <botlish_fn_26+0x285>
    3060:	mov    eax,0x2
    3065:	mov    rbx,QWORD PTR [rsp+0x30]
    306a:	mov    r12,QWORD PTR [rsp+0x38]
    306f:	mov    r13,QWORD PTR [rsp+0x40]
    3074:	mov    r14,QWORD PTR [rsp+0x48]
    3079:	mov    r15,QWORD PTR [rsp+0x50]
    307e:	add    rsp,0x60
    3082:	mov    rsp,rbp
    3085:	pop    rbp
    3086:	ret
    3087:	add    BYTE PTR [rsi],al
    3089:	add    BYTE PTR [rax],al
    308b:	add    BYTE PTR [rax],al
    308d:	add    BYTE PTR [rax],al
	...

0000000000003090 <botlish_entry_26: <generic>>:
    3090:	push   rbp
    3091:	mov    rbp,rsp
    3094:	mov    rsi,QWORD PTR [rdx]
    3097:	call   309c <botlish_entry_26+0xc>
			3098: R_X86_64_PLT32	botlish_fn_26-0x4 ; <generic>
    309c:	mov    rsp,rbp
    309f:	pop    rbp
    30a0:	ret

00000000000030a1 <botlish_fn_27: char_at<generic>>:
    30a1:	push   rbp
    30a2:	mov    rbp,rsp
    30a5:	sub    rsp,0x50
    30a9:	mov    QWORD PTR [rsp+0x20],rbx
    30ae:	mov    QWORD PTR [rsp+0x28],r12
    30b3:	mov    QWORD PTR [rsp+0x30],r13
    30b8:	mov    QWORD PTR [rsp+0x38],r14
    30bd:	mov    QWORD PTR [rsp+0x40],r15
    30c2:	mov    r14,rcx
    30c5:	mov    QWORD PTR [rsp],rsi
    30c9:	mov    QWORD PTR [rsp+0x8],rdx
    30ce:	mov    r13,rdx
    30d1:	mov    QWORD PTR [rsp+0x10],0x3
    30da:	mov    r9d,0x1
    30e0:	test   rsi,0x1
    30e7:	jne    3107 <botlish_fn_27+0x66>
    30ed:	xor    r9d,r9d
    30f0:	test   rsi,0x7
    30f7:	jne    3107 <botlish_fn_27+0x66>
    30fd:	movzx  rax,BYTE PTR [rsi]
    3101:	cmp    al,0x1
    3103:	sete   r9b
    3107:	test   r9b,r9b
    310a:	jne    3128 <botlish_fn_27+0x87>
    3110:	mov    rax,QWORD PTR [rdi+0x10]
    3114:	mov    rcx,QWORD PTR [rax+0x118]
    311b:	xor    rdx,rdx
    311e:	call   3123 <botlish_fn_27+0x82>
			311f: R_X86_64_PLT32	rt_type_error-0x4
    3123:	jmp    31e5 <botlish_fn_27+0x144>
    3128:	mov    r12,rdi
    312b:	test   rsi,0x1
    3132:	jne    3140 <botlish_fn_27+0x9f>
    3138:	mov    rbx,rsi
    313b:	jmp    315d <botlish_fn_27+0xbc>
    3140:	mov    rax,rsi
    3143:	add    rax,0x2
    3147:	mov    rbx,rsi
    314a:	seto   cl
    314d:	test   cl,cl
    314f:	jne    315d <botlish_fn_27+0xbc>
    3155:	mov    r15,rax
    3158:	jmp    3170 <botlish_fn_27+0xcf>
    315d:	mov    edx,0x3
    3162:	mov    rsi,rbx
    3165:	mov    rdi,r12
    3168:	call   316d <botlish_fn_27+0xcc>
			3169: R_X86_64_PLT32	rt_int_add-0x4
    316d:	mov    r15,rax
    3170:	mov    ecx,0x1
    3175:	mov    rsi,rbx
    3178:	test   rsi,0x1
    317f:	jne    31a5 <botlish_fn_27+0x104>
    3185:	xor    ecx,ecx
    3187:	mov    rsi,rbx
    318a:	test   rsi,0x7
    3191:	jne    31a5 <botlish_fn_27+0x104>
    3197:	mov    rsi,rbx
    319a:	movzx  rcx,BYTE PTR [rsi]
    319e:	rex cmp cl,0x1
    31a2:	sete   cl
    31a5:	test   cl,cl
    31a7:	jne    31cb <botlish_fn_27+0x12a>
    31ad:	mov    rdi,r12
    31b0:	mov    rsi,QWORD PTR [rdi+0x10]
    31b4:	mov    rcx,QWORD PTR [rsi+0x120]
    31bb:	xor    rdx,rdx
    31be:	mov    rsi,rbx
    31c1:	call   31c6 <botlish_fn_27+0x125>
			31c2: R_X86_64_PLT32	rt_type_error-0x4
    31c6:	jmp    31e5 <botlish_fn_27+0x144>
    31cb:	mov    rdi,r12
    31ce:	mov    rcx,r15
    31d1:	mov    rdx,rbx
    31d4:	mov    rsi,r13
    31d7:	call   31dc <botlish_fn_27+0x13b>
			31d8: R_X86_64_PLT32	rt_str_region_check-0x4
    31dc:	test   rax,rax
    31df:	jne    320a <botlish_fn_27+0x169>
    31e5:	xor    rax,rax
    31e8:	mov    rbx,QWORD PTR [rsp+0x20]
    31ed:	mov    r12,QWORD PTR [rsp+0x28]
    31f2:	mov    r13,QWORD PTR [rsp+0x30]
    31f7:	mov    r14,QWORD PTR [rsp+0x38]
    31fc:	mov    r15,QWORD PTR [rsp+0x40]
    3201:	add    rsp,0x50
    3205:	mov    rsp,rbp
    3208:	pop    rbp
    3209:	ret
    320a:	mov    rcx,r14
    320d:	mov    rsi,rbx
    3210:	mov    QWORD PTR [rcx],rsi
    3213:	mov    rax,r15
    3216:	mov    QWORD PTR [rcx+0x8],rax
    321a:	mov    rax,r13
    321d:	mov    rbx,QWORD PTR [rsp+0x20]
    3222:	mov    r12,QWORD PTR [rsp+0x28]
    3227:	mov    r13,QWORD PTR [rsp+0x30]
    322c:	mov    r14,QWORD PTR [rsp+0x38]
    3231:	mov    r15,QWORD PTR [rsp+0x40]
    3236:	add    rsp,0x50
    323a:	mov    rsp,rbp
    323d:	pop    rbp
    323e:	ret

000000000000323f <botlish_entry_27: char_at<generic>>:
    323f:	push   rbp
    3240:	mov    rbp,rsp
    3243:	ud2
    3245:	add    BYTE PTR [rax],al
	...

0000000000003248 <botlish_fn_28: scan_local<generic>>:
    3248:	push   rbp
    3249:	mov    rbp,rsp
    324c:	sub    rsp,0x80
    3253:	mov    QWORD PTR [rsp+0x50],rbx
    3258:	mov    QWORD PTR [rsp+0x58],r12
    325d:	mov    QWORD PTR [rsp+0x60],r13
    3262:	mov    QWORD PTR [rsp+0x68],r14
    3267:	mov    QWORD PTR [rsp+0x70],r15
    326c:	mov    rax,rdi
    326f:	mov    QWORD PTR [rsp+0x18],0x0
    3278:	mov    QWORD PTR [rsp],rsi
    327c:	mov    r14,rsi
    327f:	mov    QWORD PTR [rsp+0x8],rdx
    3284:	mov    QWORD PTR [rsp+0x10],rcx
    3289:	mov    r12,rcx
    328c:	mov    r11d,0x1
    3292:	mov    rsi,r14
    3295:	test   rsi,0x1
    329c:	jne    32be <botlish_fn_28+0x76>
    32a2:	xor    r11d,r11d
    32a5:	test   rsi,0x7
    32ac:	jne    32be <botlish_fn_28+0x76>
    32b2:	movzx  rdi,BYTE PTR [rsi]
    32b6:	cmp    dil,0x1
    32ba:	sete   r11b
    32be:	test   r11b,r11b
    32c1:	jne    32e2 <botlish_fn_28+0x9a>
    32c7:	mov    rdi,rax
    32ca:	mov    r9,QWORD PTR [rdi+0x10]
    32ce:	mov    rcx,QWORD PTR [r9+0xc8]
    32d5:	xor    rdx,rdx
    32d8:	call   32dd <botlish_fn_28+0x95>
			32d9: R_X86_64_PLT32	rt_type_error-0x4
    32dd:	jmp    3395 <botlish_fn_28+0x14d>
    32e2:	mov    r13,rdx
    32e5:	mov    r10,rsi
    32e8:	and    r10,r13
    32eb:	mov    r14,rsi
    32ee:	test   r10,0x1
    32f5:	jne    3321 <botlish_fn_28+0xd9>
    32fb:	mov    rbx,rax
    32fe:	mov    rdx,r13
    3301:	mov    rsi,r14
    3304:	mov    rdi,rbx
    3307:	call   330c <botlish_fn_28+0xc4>
			3308: R_X86_64_PLT32	rt_int_cmp-0x4
    330c:	mov    ecx,0x2
    3311:	test   rax,rax
    3314:	cmovge rcx,QWORD PTR [rip+0x24c]        # 3568 <botlish_fn_28+0x320>
    331c:	jmp    3337 <botlish_fn_28+0xef>
    3321:	mov    rbx,rax
    3324:	mov    ecx,0x2
    3329:	mov    rsi,r14
    332c:	cmp    rsi,r13
    332f:	cmovge rcx,QWORD PTR [rip+0x231]        # 3568 <botlish_fn_28+0x320>
    3337:	mov    eax,0x6
    333c:	mov    QWORD PTR [rsp+0x30],rax
    3341:	cmp    rcx,0x6
    3345:	je     353b <botlish_fn_28+0x2f3>
    334b:	lea    rcx,[rsp+0x20]
    3350:	mov    rdx,r12
    3353:	mov    rsi,r14
    3356:	mov    rdi,rbx
    3359:	call   335e <botlish_fn_28+0x116>
			335a: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    335e:	mov    rsi,rax
    3361:	mov    r15,rax
    3364:	test   rax,rsi
    3367:	je     3395 <botlish_fn_28+0x14d>
    336d:	mov    rdx,QWORD PTR [rsp+0x20]
    3372:	mov    QWORD PTR [rsp+0x40],rdx
    3377:	mov    rcx,QWORD PTR [rsp+0x28]
    337c:	mov    QWORD PTR [rsp+0x38],rcx
    3381:	mov    rsi,r15
    3384:	mov    rdi,rbx
    3387:	call   338c <botlish_fn_28+0x144>
			3388: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    338c:	test   rax,rax
    338f:	jne    33bd <botlish_fn_28+0x175>
    3395:	xor    rax,rax
    3398:	mov    rbx,QWORD PTR [rsp+0x50]
    339d:	mov    r12,QWORD PTR [rsp+0x58]
    33a2:	mov    r13,QWORD PTR [rsp+0x60]
    33a7:	mov    r14,QWORD PTR [rsp+0x68]
    33ac:	mov    r15,QWORD PTR [rsp+0x70]
    33b1:	add    rsp,0x80
    33b8:	mov    rsp,rbp
    33bb:	pop    rbp
    33bc:	ret
    33bd:	cmp    rax,0x6
    33c1:	je     34bc <botlish_fn_28+0x274>
    33c7:	mov    rax,QWORD PTR [rbx+0x10]
    33cb:	mov    r8,QWORD PTR [rax+0x128]
    33d2:	mov    rcx,QWORD PTR [rsp+0x38]
    33d7:	mov    rdx,QWORD PTR [rsp+0x40]
    33dc:	mov    rsi,r15
    33df:	mov    rdi,rbx
    33e2:	call   33e7 <botlish_fn_28+0x19f>
			33e3: R_X86_64_PLT32	rt_str_region_eq-0x4
    33e7:	cmp    rax,0x6
    33eb:	je     34b2 <botlish_fn_28+0x26a>
    33f1:	mov    rax,QWORD PTR [rbx+0x10]
    33f5:	mov    r8,QWORD PTR [rax+0x130]
    33fc:	mov    rcx,QWORD PTR [rsp+0x38]
    3401:	mov    rdx,QWORD PTR [rsp+0x40]
    3406:	mov    rsi,r15
    3409:	mov    rdi,rbx
    340c:	call   3411 <botlish_fn_28+0x1c9>
			340d: R_X86_64_PLT32	rt_str_region_eq-0x4
    3411:	cmp    rax,0x6
    3415:	je     34a8 <botlish_fn_28+0x260>
    341b:	mov    rax,QWORD PTR [rbx+0x10]
    341f:	mov    r8,QWORD PTR [rax+0xd0]
    3426:	mov    rcx,QWORD PTR [rsp+0x38]
    342b:	mov    rdx,QWORD PTR [rsp+0x40]
    3430:	mov    rsi,r15
    3433:	mov    rdi,rbx
    3436:	call   343b <botlish_fn_28+0x1f3>
			3437: R_X86_64_PLT32	rt_str_region_eq-0x4
    343b:	cmp    rax,0x6
    343f:	je     349e <botlish_fn_28+0x256>
    3445:	mov    rax,QWORD PTR [rbx+0x10]
    3449:	mov    r8,QWORD PTR [rax+0x118]
    3450:	mov    rcx,QWORD PTR [rsp+0x38]
    3455:	mov    rdx,QWORD PTR [rsp+0x40]
    345a:	mov    rsi,r15
    345d:	mov    rdi,rbx
    3460:	call   3465 <botlish_fn_28+0x21d>
			3461: R_X86_64_PLT32	rt_str_region_eq-0x4
    3465:	cmp    rax,0x6
    3469:	je     3494 <botlish_fn_28+0x24c>
    346f:	mov    rax,QWORD PTR [rbx+0x10]
    3473:	mov    r8,QWORD PTR [rax+0x138]
    347a:	mov    rcx,QWORD PTR [rsp+0x38]
    347f:	mov    rdx,QWORD PTR [rsp+0x40]
    3484:	mov    rsi,r15
    3487:	mov    rdi,rbx
    348a:	call   348f <botlish_fn_28+0x247>
			348b: R_X86_64_PLT32	rt_str_region_eq-0x4
    348f:	jmp    34c1 <botlish_fn_28+0x279>
    3494:	mov    rax,QWORD PTR [rsp+0x30]
    3499:	jmp    34c1 <botlish_fn_28+0x279>
    349e:	mov    rax,QWORD PTR [rsp+0x30]
    34a3:	jmp    34c1 <botlish_fn_28+0x279>
    34a8:	mov    rax,QWORD PTR [rsp+0x30]
    34ad:	jmp    34c1 <botlish_fn_28+0x279>
    34b2:	mov    rax,QWORD PTR [rsp+0x30]
    34b7:	jmp    34c1 <botlish_fn_28+0x279>
    34bc:	mov    rax,QWORD PTR [rsp+0x30]
    34c1:	cmp    rax,0x6
    34c5:	je     34d3 <botlish_fn_28+0x28b>
    34cb:	mov    rax,r14
    34ce:	jmp    353e <botlish_fn_28+0x2f6>
    34d3:	mov    QWORD PTR [rsp+0x18],0x3
    34dc:	mov    rsi,r14
    34df:	test   rsi,0x1
    34e6:	je     350c <botlish_fn_28+0x2c4>
    34ec:	mov    rsi,r14
    34ef:	mov    rax,rsi
    34f2:	add    rax,0x2
    34f6:	seto   cl
    34f9:	test   cl,cl
    34fb:	jne    350c <botlish_fn_28+0x2c4>
    3501:	mov    rsi,rax
    3504:	mov    r14,rax
    3507:	jmp    3522 <botlish_fn_28+0x2da>
    350c:	mov    edx,0x3
    3511:	mov    rsi,r14
    3514:	mov    rdi,rbx
    3517:	call   351c <botlish_fn_28+0x2d4>
			3518: R_X86_64_PLT32	rt_int_add-0x4
    351c:	mov    rsi,rax
    351f:	mov    r14,rax
    3522:	mov    QWORD PTR [rsp],rsi
    3526:	mov    QWORD PTR [rsp+0x8],r13
    352b:	mov    QWORD PTR [rsp+0x10],r12
    3530:	mov    rax,rbx
    3533:	mov    rdx,r13
    3536:	jmp    328c <botlish_fn_28+0x44>
    353b:	mov    rax,r14
    353e:	mov    rbx,QWORD PTR [rsp+0x50]
    3543:	mov    r12,QWORD PTR [rsp+0x58]
    3548:	mov    r13,QWORD PTR [rsp+0x60]
    354d:	mov    r14,QWORD PTR [rsp+0x68]
    3552:	mov    r15,QWORD PTR [rsp+0x70]
    3557:	add    rsp,0x80
    355e:	mov    rsp,rbp
    3561:	pop    rbp
    3562:	ret
    3563:	add    BYTE PTR [rax],al
    3565:	add    BYTE PTR [rax],al
    3567:	add    BYTE PTR [rsi],al
    3569:	add    BYTE PTR [rax],al
    356b:	add    BYTE PTR [rax],al
    356d:	add    BYTE PTR [rax],al
	...

0000000000003570 <botlish_entry_28: scan_local<generic>>:
    3570:	push   rbp
    3571:	mov    rbp,rsp
    3574:	mov    rsi,QWORD PTR [rdx]
    3577:	mov    r8,QWORD PTR [rdx+0x8]
    357b:	mov    rcx,QWORD PTR [rdx+0x10]
    357f:	mov    rdx,r8
    3582:	call   3587 <botlish_entry_28+0x17>
			3583: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    3587:	mov    rsp,rbp
    358a:	pop    rbp
    358b:	ret
    358c:	add    BYTE PTR [rax],al
	...

0000000000003590 <botlish_fn_29: scan_label<generic>>:
    3590:	push   rbp
    3591:	mov    rbp,rsp
    3594:	sub    rsp,0x80
    359b:	mov    QWORD PTR [rsp+0x50],rbx
    35a0:	mov    QWORD PTR [rsp+0x58],r12
    35a5:	mov    QWORD PTR [rsp+0x60],r13
    35aa:	mov    QWORD PTR [rsp+0x68],r14
    35af:	mov    QWORD PTR [rsp+0x70],r15
    35b4:	mov    QWORD PTR [rsp+0x18],0x0
    35bd:	mov    QWORD PTR [rsp],rsi
    35c1:	mov    r14,rsi
    35c4:	mov    QWORD PTR [rsp+0x8],rdx
    35c9:	mov    QWORD PTR [rsp+0x10],rcx
    35ce:	mov    r12,rcx
    35d1:	mov    r11d,0x1
    35d7:	mov    rsi,r14
    35da:	test   rsi,0x1
    35e1:	jne    3601 <botlish_fn_29+0x71>
    35e7:	xor    r11d,r11d
    35ea:	test   rsi,0x7
    35f1:	jne    3601 <botlish_fn_29+0x71>
    35f7:	movzx  rax,BYTE PTR [rsi]
    35fb:	cmp    al,0x1
    35fd:	sete   r11b
    3601:	test   r11b,r11b
    3604:	jne    3622 <botlish_fn_29+0x92>
    360a:	mov    rax,QWORD PTR [rdi+0x10]
    360e:	mov    rcx,QWORD PTR [rax+0xc8]
    3615:	xor    rdx,rdx
    3618:	call   361d <botlish_fn_29+0x8d>
			3619: R_X86_64_PLT32	rt_type_error-0x4
    361d:	jmp    36ce <botlish_fn_29+0x13e>
    3622:	mov    r13,rdx
    3625:	mov    rax,rsi
    3628:	and    rax,r13
    362b:	mov    r14,rsi
    362e:	test   rax,0x1
    3634:	jne    365d <botlish_fn_29+0xcd>
    363a:	mov    rbx,rdi
    363d:	mov    rdx,r13
    3640:	mov    rsi,r14
    3643:	call   3648 <botlish_fn_29+0xb8>
			3644: R_X86_64_PLT32	rt_int_cmp-0x4
    3648:	mov    ecx,0x2
    364d:	test   rax,rax
    3650:	cmovge rcx,QWORD PTR [rip+0x178]        # 37d0 <botlish_fn_29+0x240>
    3658:	jmp    3673 <botlish_fn_29+0xe3>
    365d:	mov    rbx,rdi
    3660:	mov    ecx,0x2
    3665:	mov    rsi,r14
    3668:	cmp    rsi,r13
    366b:	cmovge rcx,QWORD PTR [rip+0x15d]        # 37d0 <botlish_fn_29+0x240>
    3673:	mov    eax,0x6
    3678:	mov    QWORD PTR [rsp+0x30],rax
    367d:	cmp    rcx,0x6
    3681:	je     37a4 <botlish_fn_29+0x214>
    3687:	lea    rcx,[rsp+0x20]
    368c:	mov    rdx,r12
    368f:	mov    rsi,r14
    3692:	mov    rdi,rbx
    3695:	call   369a <botlish_fn_29+0x10a>
			3696: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    369a:	test   rax,rax
    369d:	mov    r15,rax
    36a0:	je     36ce <botlish_fn_29+0x13e>
    36a6:	mov    rdx,QWORD PTR [rsp+0x20]
    36ab:	mov    QWORD PTR [rsp+0x40],rdx
    36b0:	mov    rcx,QWORD PTR [rsp+0x28]
    36b5:	mov    QWORD PTR [rsp+0x38],rcx
    36ba:	mov    rsi,r15
    36bd:	mov    rdi,rbx
    36c0:	call   36c5 <botlish_fn_29+0x135>
			36c1: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    36c5:	test   rax,rax
    36c8:	jne    36f6 <botlish_fn_29+0x166>
    36ce:	xor    rax,rax
    36d1:	mov    rbx,QWORD PTR [rsp+0x50]
    36d6:	mov    r12,QWORD PTR [rsp+0x58]
    36db:	mov    r13,QWORD PTR [rsp+0x60]
    36e0:	mov    r14,QWORD PTR [rsp+0x68]
    36e5:	mov    r15,QWORD PTR [rsp+0x70]
    36ea:	add    rsp,0x80
    36f1:	mov    rsp,rbp
    36f4:	pop    rbp
    36f5:	ret
    36f6:	cmp    rax,0x6
    36fa:	je     3725 <botlish_fn_29+0x195>
    3700:	mov    r11,QWORD PTR [rbx+0x10]
    3704:	mov    r8,QWORD PTR [r11+0x138]
    370b:	mov    rcx,QWORD PTR [rsp+0x38]
    3710:	mov    rdx,QWORD PTR [rsp+0x40]
    3715:	mov    rsi,r15
    3718:	mov    rdi,rbx
    371b:	call   3720 <botlish_fn_29+0x190>
			371c: R_X86_64_PLT32	rt_str_region_eq-0x4
    3720:	jmp    372a <botlish_fn_29+0x19a>
    3725:	mov    rax,QWORD PTR [rsp+0x30]
    372a:	cmp    rax,0x6
    372e:	je     373c <botlish_fn_29+0x1ac>
    3734:	mov    rax,r14
    3737:	jmp    37a7 <botlish_fn_29+0x217>
    373c:	mov    QWORD PTR [rsp+0x18],0x3
    3745:	mov    rsi,r14
    3748:	test   rsi,0x1
    374f:	je     3775 <botlish_fn_29+0x1e5>
    3755:	mov    rsi,r14
    3758:	mov    rax,rsi
    375b:	add    rax,0x2
    375f:	seto   cl
    3762:	test   cl,cl
    3764:	jne    3775 <botlish_fn_29+0x1e5>
    376a:	mov    rsi,rax
    376d:	mov    r14,rax
    3770:	jmp    378b <botlish_fn_29+0x1fb>
    3775:	mov    edx,0x3
    377a:	mov    rsi,r14
    377d:	mov    rdi,rbx
    3780:	call   3785 <botlish_fn_29+0x1f5>
			3781: R_X86_64_PLT32	rt_int_add-0x4
    3785:	mov    rsi,rax
    3788:	mov    r14,rax
    378b:	mov    QWORD PTR [rsp],rsi
    378f:	mov    QWORD PTR [rsp+0x8],r13
    3794:	mov    QWORD PTR [rsp+0x10],r12
    3799:	mov    rdx,r13
    379c:	mov    rdi,rbx
    379f:	jmp    35d1 <botlish_fn_29+0x41>
    37a4:	mov    rax,r14
    37a7:	mov    rbx,QWORD PTR [rsp+0x50]
    37ac:	mov    r12,QWORD PTR [rsp+0x58]
    37b1:	mov    r13,QWORD PTR [rsp+0x60]
    37b6:	mov    r14,QWORD PTR [rsp+0x68]
    37bb:	mov    r15,QWORD PTR [rsp+0x70]
    37c0:	add    rsp,0x80
    37c7:	mov    rsp,rbp
    37ca:	pop    rbp
    37cb:	ret
    37cc:	add    BYTE PTR [rax],al
    37ce:	add    BYTE PTR [rax],al
    37d0:	(bad)
    37d1:	add    BYTE PTR [rax],al
    37d3:	add    BYTE PTR [rax],al
    37d5:	add    BYTE PTR [rax],al
	...

00000000000037d8 <botlish_entry_29: scan_label<generic>>:
    37d8:	push   rbp
    37d9:	mov    rbp,rsp
    37dc:	mov    rsi,QWORD PTR [rdx]
    37df:	mov    r8,QWORD PTR [rdx+0x8]
    37e3:	mov    rcx,QWORD PTR [rdx+0x10]
    37e7:	mov    rdx,r8
    37ea:	call   37ef <botlish_entry_29+0x17>
			37eb: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_label<generic>
    37ef:	mov    rsp,rbp
    37f2:	pop    rbp
    37f3:	ret
    37f4:	add    BYTE PTR [rax],al
	...

00000000000037f8 <botlish_fn_30: scan_alpha<generic>>:
    37f8:	push   rbp
    37f9:	mov    rbp,rsp
    37fc:	sub    rsp,0x50
    3800:	mov    QWORD PTR [rsp+0x30],rbx
    3805:	mov    QWORD PTR [rsp+0x38],r12
    380a:	mov    QWORD PTR [rsp+0x40],r13
    380f:	mov    QWORD PTR [rsp+0x48],r14
    3814:	mov    r14,rdi
    3817:	mov    QWORD PTR [rsp+0x18],0x0
    3820:	mov    QWORD PTR [rsp],rsi
    3824:	mov    r13,rsi
    3827:	mov    QWORD PTR [rsp+0x8],rdx
    382c:	mov    r12,rdx
    382f:	mov    QWORD PTR [rsp+0x10],rcx
    3834:	mov    rbx,rcx
    3837:	mov    r11d,0x1
    383d:	mov    rsi,r13
    3840:	test   rsi,0x1
    3847:	jne    3867 <botlish_fn_30+0x6f>
    384d:	xor    r11d,r11d
    3850:	test   rsi,0x7
    3857:	jne    3867 <botlish_fn_30+0x6f>
    385d:	movzx  rax,BYTE PTR [rsi]
    3861:	cmp    al,0x1
    3863:	sete   r11b
    3867:	test   r11b,r11b
    386a:	jne    388b <botlish_fn_30+0x93>
    3870:	mov    rdi,r14
    3873:	mov    rax,QWORD PTR [rdi+0x10]
    3877:	mov    rcx,QWORD PTR [rax+0xc8]
    387e:	xor    rdx,rdx
    3881:	call   3886 <botlish_fn_30+0x8e>
			3882: R_X86_64_PLT32	rt_type_error-0x4
    3886:	jmp    391a <botlish_fn_30+0x122>
    388b:	mov    rax,rsi
    388e:	and    rax,r12
    3891:	mov    r13,rsi
    3894:	test   rax,0x1
    389a:	jne    38c3 <botlish_fn_30+0xcb>
    38a0:	mov    rdx,r12
    38a3:	mov    rsi,r13
    38a6:	mov    rdi,r14
    38a9:	call   38ae <botlish_fn_30+0xb6>
			38aa: R_X86_64_PLT32	rt_int_cmp-0x4
    38ae:	mov    ecx,0x2
    38b3:	test   rax,rax
    38b6:	cmovge rcx,QWORD PTR [rip+0x112]        # 39d0 <botlish_fn_30+0x1d8>
    38be:	jmp    38d6 <botlish_fn_30+0xde>
    38c3:	mov    ecx,0x2
    38c8:	mov    rsi,r13
    38cb:	cmp    rsi,r12
    38ce:	cmovge rcx,QWORD PTR [rip+0xfa]        # 39d0 <botlish_fn_30+0x1d8>
    38d6:	cmp    rcx,0x6
    38da:	je     39ae <botlish_fn_30+0x1b6>
    38e0:	lea    rcx,[rsp+0x20]
    38e5:	mov    rdx,rbx
    38e8:	mov    rsi,r13
    38eb:	mov    rdi,r14
    38ee:	call   38f3 <botlish_fn_30+0xfb>
			38ef: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    38f3:	test   rax,rax
    38f6:	mov    rsi,rax
    38f9:	je     391a <botlish_fn_30+0x122>
    38ff:	mov    rdx,QWORD PTR [rsp+0x20]
    3904:	mov    rcx,QWORD PTR [rsp+0x28]
    3909:	mov    rdi,r14
    390c:	call   3911 <botlish_fn_30+0x119>
			390d: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    3911:	test   rax,rax
    3914:	jne    393a <botlish_fn_30+0x142>
    391a:	xor    rax,rax
    391d:	mov    rbx,QWORD PTR [rsp+0x30]
    3922:	mov    r12,QWORD PTR [rsp+0x38]
    3927:	mov    r13,QWORD PTR [rsp+0x40]
    392c:	mov    r14,QWORD PTR [rsp+0x48]
    3931:	add    rsp,0x50
    3935:	mov    rsp,rbp
    3938:	pop    rbp
    3939:	ret
    393a:	cmp    rax,0x6
    393e:	je     394c <botlish_fn_30+0x154>
    3944:	mov    rax,r13
    3947:	jmp    39b1 <botlish_fn_30+0x1b9>
    394c:	mov    QWORD PTR [rsp+0x18],0x3
    3955:	mov    rsi,r13
    3958:	test   rsi,0x1
    395f:	je     3985 <botlish_fn_30+0x18d>
    3965:	mov    rsi,r13
    3968:	mov    r11,rsi
    396b:	add    r11,0x2
    396f:	seto   al
    3972:	test   al,al
    3974:	jne    3985 <botlish_fn_30+0x18d>
    397a:	mov    rsi,r11
    397d:	mov    r13,r11
    3980:	jmp    399b <botlish_fn_30+0x1a3>
    3985:	mov    edx,0x3
    398a:	mov    rsi,r13
    398d:	mov    rdi,r14
    3990:	call   3995 <botlish_fn_30+0x19d>
			3991: R_X86_64_PLT32	rt_int_add-0x4
    3995:	mov    rsi,rax
    3998:	mov    r13,rax
    399b:	mov    QWORD PTR [rsp],rsi
    399f:	mov    QWORD PTR [rsp+0x8],r12
    39a4:	mov    QWORD PTR [rsp+0x10],rbx
    39a9:	jmp    3837 <botlish_fn_30+0x3f>
    39ae:	mov    rax,r13
    39b1:	mov    rbx,QWORD PTR [rsp+0x30]
    39b6:	mov    r12,QWORD PTR [rsp+0x38]
    39bb:	mov    r13,QWORD PTR [rsp+0x40]
    39c0:	mov    r14,QWORD PTR [rsp+0x48]
    39c5:	add    rsp,0x50
    39c9:	mov    rsp,rbp
    39cc:	pop    rbp
    39cd:	ret
    39ce:	add    BYTE PTR [rax],al
    39d0:	(bad)
    39d1:	add    BYTE PTR [rax],al
    39d3:	add    BYTE PTR [rax],al
    39d5:	add    BYTE PTR [rax],al
	...

00000000000039d8 <botlish_entry_30: scan_alpha<generic>>:
    39d8:	push   rbp
    39d9:	mov    rbp,rsp
    39dc:	mov    rsi,QWORD PTR [rdx]
    39df:	mov    r8,QWORD PTR [rdx+0x8]
    39e3:	mov    rcx,QWORD PTR [rdx+0x10]
    39e7:	mov    rdx,r8
    39ea:	call   39ef <botlish_entry_30+0x17>
			39eb: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_alpha<generic>
    39ef:	mov    rsp,rbp
    39f2:	pop    rbp
    39f3:	ret
    39f4:	add    BYTE PTR [rax],al
	...

00000000000039f8 <botlish_fn_31: tld_ok<generic>>:
    39f8:	push   rbp
    39f9:	mov    rbp,rsp
    39fc:	sub    rsp,0x40
    3a00:	mov    QWORD PTR [rsp+0x20],rbx
    3a05:	mov    QWORD PTR [rsp+0x28],r12
    3a0a:	mov    QWORD PTR [rsp+0x30],r13
    3a0f:	mov    QWORD PTR [rsp+0x38],r14
    3a14:	mov    rbx,rdi
    3a17:	mov    QWORD PTR [rsp],rsi
    3a1b:	mov    r12,rsi
    3a1e:	mov    QWORD PTR [rsp+0x8],rdx
    3a23:	mov    r14,rdx
    3a26:	mov    QWORD PTR [rsp+0x10],rcx
    3a2b:	mov    rdx,r14
    3a2e:	mov    rsi,r12
    3a31:	mov    rdi,rbx
    3a34:	call   3a39 <botlish_fn_31+0x41>
			3a35: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_alpha<generic>
    3a39:	mov    rsi,rax
    3a3c:	mov    r13,rax
    3a3f:	test   rax,rsi
    3a42:	je     3b05 <botlish_fn_31+0x10d>
    3a48:	mov    rax,r13
    3a4b:	mov    QWORD PTR [rsp+0x8],rax
    3a50:	mov    rdx,r14
    3a53:	and    rax,rdx
    3a56:	test   rax,0x1
    3a5c:	jne    3a85 <botlish_fn_31+0x8d>
    3a62:	mov    rsi,r13
    3a65:	mov    rdi,rbx
    3a68:	call   3a6d <botlish_fn_31+0x75>
			3a69: R_X86_64_PLT32	rt_int_cmp-0x4
    3a6d:	mov    ecx,0x2
    3a72:	test   rax,rax
    3a75:	cmove  rcx,QWORD PTR [rip+0x15b]        # 3bd8 <botlish_fn_31+0x1e0>
    3a7d:	mov    rax,r13
    3a80:	jmp    3a98 <botlish_fn_31+0xa0>
    3a85:	mov    ecx,0x2
    3a8a:	mov    rax,r13
    3a8d:	cmp    rax,rdx
    3a90:	cmove  rcx,QWORD PTR [rip+0x140]        # 3bd8 <botlish_fn_31+0x1e0>
    3a98:	cmp    rcx,0x6
    3a9c:	je     3aaf <botlish_fn_31+0xb7>
    3aa2:	mov    ecx,0x2
    3aa7:	mov    rax,rcx
    3aaa:	jmp    3bb7 <botlish_fn_31+0x1bf>
    3aaf:	mov    ecx,0x1
    3ab4:	mov    rsi,r12
    3ab7:	test   rsi,0x1
    3abe:	jne    3ae4 <botlish_fn_31+0xec>
    3ac4:	xor    ecx,ecx
    3ac6:	mov    rsi,r12
    3ac9:	test   rsi,0x7
    3ad0:	jne    3ae4 <botlish_fn_31+0xec>
    3ad6:	mov    rsi,r12
    3ad9:	movzx  rcx,BYTE PTR [rsi]
    3add:	rex cmp cl,0x1
    3ae1:	sete   cl
    3ae4:	test   cl,cl
    3ae6:	jne    3b25 <botlish_fn_31+0x12d>
    3aec:	mov    rdi,rbx
    3aef:	mov    rsi,QWORD PTR [rdi+0x10]
    3af3:	mov    rcx,QWORD PTR [rsi+0x138]
    3afa:	xor    rdx,rdx
    3afd:	mov    rsi,r12
    3b00:	call   3b05 <botlish_fn_31+0x10d>
			3b01: R_X86_64_PLT32	rt_type_error-0x4
    3b05:	xor    rax,rax
    3b08:	mov    rbx,QWORD PTR [rsp+0x20]
    3b0d:	mov    r12,QWORD PTR [rsp+0x28]
    3b12:	mov    r13,QWORD PTR [rsp+0x30]
    3b17:	mov    r14,QWORD PTR [rsp+0x38]
    3b1c:	add    rsp,0x40
    3b20:	mov    rsp,rbp
    3b23:	pop    rbp
    3b24:	ret
    3b25:	mov    rsi,r12
    3b28:	mov    rdi,rax
    3b2b:	and    rdi,rsi
    3b2e:	test   rdi,0x1
    3b35:	jne    3b46 <botlish_fn_31+0x14e>
    3b3b:	mov    rdx,r12
    3b3e:	mov    rsi,rax
    3b41:	jmp    3b69 <botlish_fn_31+0x171>
    3b46:	mov    rsi,r12
    3b49:	mov    r8,rax
    3b4c:	sub    r8,rsi
    3b4f:	mov    r13,rax
    3b52:	seto   r10b
    3b56:	lea    rsi,[r8+0x1]
    3b5a:	test   r10b,r10b
    3b5d:	je     3b74 <botlish_fn_31+0x17c>
    3b63:	mov    rdx,r12
    3b66:	mov    rsi,r13
    3b69:	mov    rdi,rbx
    3b6c:	call   3b71 <botlish_fn_31+0x179>
			3b6d: R_X86_64_PLT32	rt_int_sub-0x4
    3b71:	mov    rsi,rax
    3b74:	test   rsi,0x1
    3b7b:	jne    3ba6 <botlish_fn_31+0x1ae>
    3b81:	mov    edx,0x5
    3b86:	mov    rdi,rbx
    3b89:	call   3b8e <botlish_fn_31+0x196>
			3b8a: R_X86_64_PLT32	rt_int_cmp-0x4
    3b8e:	mov    ecx,0x2
    3b93:	test   rax,rax
    3b96:	mov    rax,rcx
    3b99:	cmovge rax,QWORD PTR [rip+0x37]        # 3bd8 <botlish_fn_31+0x1e0>
    3ba1:	jmp    3bb7 <botlish_fn_31+0x1bf>
    3ba6:	mov    eax,0x2
    3bab:	cmp    rsi,0x5
    3baf:	cmovge rax,QWORD PTR [rip+0x21]        # 3bd8 <botlish_fn_31+0x1e0>
    3bb7:	mov    rbx,QWORD PTR [rsp+0x20]
    3bbc:	mov    r12,QWORD PTR [rsp+0x28]
    3bc1:	mov    r13,QWORD PTR [rsp+0x30]
    3bc6:	mov    r14,QWORD PTR [rsp+0x38]
    3bcb:	add    rsp,0x40
    3bcf:	mov    rsp,rbp
    3bd2:	pop    rbp
    3bd3:	ret
    3bd4:	add    BYTE PTR [rax],al
    3bd6:	add    BYTE PTR [rax],al
    3bd8:	(bad)
    3bd9:	add    BYTE PTR [rax],al
    3bdb:	add    BYTE PTR [rax],al
    3bdd:	add    BYTE PTR [rax],al
	...

0000000000003be0 <botlish_entry_31: tld_ok<generic>>:
    3be0:	push   rbp
    3be1:	mov    rbp,rsp
    3be4:	mov    rsi,QWORD PTR [rdx]
    3be7:	mov    r8,QWORD PTR [rdx+0x8]
    3beb:	mov    rcx,QWORD PTR [rdx+0x10]
    3bef:	mov    rdx,r8
    3bf2:	call   3bf7 <botlish_entry_31+0x17>
			3bf3: R_X86_64_PLT32	botlish_fn_31-0x4 ; tld_ok<generic>
    3bf7:	mov    rsp,rbp
    3bfa:	pop    rbp
    3bfb:	ret
    3bfc:	add    BYTE PTR [rax],al
	...

0000000000003c00 <botlish_fn_32: domain_loop<generic>>:
    3c00:	push   rbp
    3c01:	mov    rbp,rsp
    3c04:	sub    rsp,0x70
    3c08:	mov    QWORD PTR [rsp+0x40],rbx
    3c0d:	mov    QWORD PTR [rsp+0x48],r12
    3c12:	mov    QWORD PTR [rsp+0x50],r13
    3c17:	mov    QWORD PTR [rsp+0x58],r14
    3c1c:	mov    QWORD PTR [rsp+0x60],r15
    3c21:	mov    QWORD PTR [rsp+0x18],0x0
    3c2a:	mov    QWORD PTR [rsp],rsi
    3c2e:	mov    QWORD PTR [rsp+0x8],rdx
    3c33:	mov    QWORD PTR [rsp+0x10],rcx
    3c38:	lea    rbx,[rsp+0x20]
    3c3d:	mov    r12,rdi
    3c40:	mov    r13,rcx
    3c43:	mov    r14,rdx
    3c46:	mov    QWORD PTR [rsp+0x30],rsi
    3c4b:	mov    rcx,r13
    3c4e:	mov    rdx,r14
    3c51:	mov    rsi,QWORD PTR [rsp+0x30]
    3c56:	mov    rdi,r12
    3c59:	call   3c5e <botlish_fn_32+0x5e>
			3c5a: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_label<generic>
    3c5e:	mov    rcx,rax
    3c61:	mov    r15,rax
    3c64:	test   rax,rcx
    3c67:	je     3db7 <botlish_fn_32+0x1b7>
    3c6d:	mov    rax,r15
    3c70:	mov    QWORD PTR [rsp],rax
    3c74:	mov    rdx,QWORD PTR [rsp+0x30]
    3c79:	and    rax,rdx
    3c7c:	test   rax,0x1
    3c82:	jne    3ca1 <botlish_fn_32+0xa1>
    3c88:	mov    rsi,r15
    3c8b:	mov    rdi,r12
    3c8e:	call   3c93 <botlish_fn_32+0x93>
			3c8f: R_X86_64_PLT32	rt_value_eq-0x4
    3c93:	test   rax,rax
    3c96:	je     3db7 <botlish_fn_32+0x1b7>
    3c9c:	jmp    3cb1 <botlish_fn_32+0xb1>
    3ca1:	mov    eax,0x2
    3ca6:	cmp    r15,rdx
    3ca9:	cmove  rax,QWORD PTR [rip+0x187]        # 3e38 <botlish_fn_32+0x238>
    3cb1:	cmp    rax,0x6
    3cb5:	je     3e0d <botlish_fn_32+0x20d>
    3cbb:	mov    rax,r15
    3cbe:	and    rax,r14
    3cc1:	test   rax,0x1
    3cc7:	jne    3cf0 <botlish_fn_32+0xf0>
    3ccd:	mov    rdx,r14
    3cd0:	mov    rsi,r15
    3cd3:	mov    rdi,r12
    3cd6:	call   3cdb <botlish_fn_32+0xdb>
			3cd7: R_X86_64_PLT32	rt_int_cmp-0x4
    3cdb:	mov    ecx,0x2
    3ce0:	test   rax,rax
    3ce3:	cmovge rcx,QWORD PTR [rip+0x14d]        # 3e38 <botlish_fn_32+0x238>
    3ceb:	jmp    3d00 <botlish_fn_32+0x100>
    3cf0:	mov    ecx,0x2
    3cf5:	cmp    r15,r14
    3cf8:	cmovge rcx,QWORD PTR [rip+0x138]        # 3e38 <botlish_fn_32+0x238>
    3d00:	cmp    rcx,0x6
    3d04:	je     3dfe <botlish_fn_32+0x1fe>
    3d0a:	mov    rcx,rbx
    3d0d:	mov    rdx,r13
    3d10:	mov    rsi,r15
    3d13:	mov    rdi,r12
    3d16:	call   3d1b <botlish_fn_32+0x11b>
			3d17: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    3d1b:	test   rax,rax
    3d1e:	je     3db7 <botlish_fn_32+0x1b7>
    3d24:	mov    rdx,QWORD PTR [rsp+0x20]
    3d29:	mov    rcx,QWORD PTR [rsp+0x28]
    3d2e:	mov    rsi,QWORD PTR [r12+0x10]
    3d33:	mov    r8,QWORD PTR [rsi+0x128]
    3d3a:	mov    rsi,rax
    3d3d:	mov    rdi,r12
    3d40:	call   3d45 <botlish_fn_32+0x145>
			3d41: R_X86_64_PLT32	rt_str_region_eq-0x4
    3d45:	cmp    rax,0x6
    3d49:	je     3d5b <botlish_fn_32+0x15b>
    3d4f:	mov    r14,0xffffffffffffffff
    3d56:	jmp    3e05 <botlish_fn_32+0x205>
    3d5b:	mov    QWORD PTR [rsp+0x18],0x3
    3d64:	test   r15,0x1
    3d6b:	je     3d83 <botlish_fn_32+0x183>
    3d71:	mov    rdx,r15
    3d74:	add    rdx,0x2
    3d78:	seto   al
    3d7b:	test   al,al
    3d7d:	je     3d96 <botlish_fn_32+0x196>
    3d83:	mov    edx,0x3
    3d88:	mov    rsi,r15
    3d8b:	mov    rdi,r12
    3d8e:	call   3d93 <botlish_fn_32+0x193>
			3d8f: R_X86_64_PLT32	rt_int_add-0x4
    3d93:	mov    rdx,rax
    3d96:	mov    QWORD PTR [rsp],rdx
    3d9a:	mov    r15,rdx
    3d9d:	mov    rcx,r13
    3da0:	mov    rdx,r14
    3da3:	mov    rsi,r15
    3da6:	mov    rdi,r12
    3da9:	call   3dae <botlish_fn_32+0x1ae>
			3daa: R_X86_64_PLT32	botlish_fn_31-0x4 ; tld_ok<generic>
    3dae:	test   rax,rax
    3db1:	jne    3ddc <botlish_fn_32+0x1dc>
    3db7:	xor    rax,rax
    3dba:	mov    rbx,QWORD PTR [rsp+0x40]
    3dbf:	mov    r12,QWORD PTR [rsp+0x48]
    3dc4:	mov    r13,QWORD PTR [rsp+0x50]
    3dc9:	mov    r14,QWORD PTR [rsp+0x58]
    3dce:	mov    r15,QWORD PTR [rsp+0x60]
    3dd3:	add    rsp,0x70
    3dd7:	mov    rsp,rbp
    3dda:	pop    rbp
    3ddb:	ret
    3ddc:	cmp    rax,0x6
    3de0:	je     3e05 <botlish_fn_32+0x205>
    3de6:	mov    QWORD PTR [rsp],r15
    3dea:	mov    QWORD PTR [rsp+0x8],r14
    3def:	mov    QWORD PTR [rsp+0x10],r13
    3df4:	mov    QWORD PTR [rsp+0x30],r15
    3df9:	jmp    3c4b <botlish_fn_32+0x4b>
    3dfe:	mov    r14,0xffffffffffffffff
    3e05:	mov    rax,r14
    3e08:	jmp    3e14 <botlish_fn_32+0x214>
    3e0d:	mov    rax,0xffffffffffffffff
    3e14:	mov    rbx,QWORD PTR [rsp+0x40]
    3e19:	mov    r12,QWORD PTR [rsp+0x48]
    3e1e:	mov    r13,QWORD PTR [rsp+0x50]
    3e23:	mov    r14,QWORD PTR [rsp+0x58]
    3e28:	mov    r15,QWORD PTR [rsp+0x60]
    3e2d:	add    rsp,0x70
    3e31:	mov    rsp,rbp
    3e34:	pop    rbp
    3e35:	ret
    3e36:	add    BYTE PTR [rax],al
    3e38:	(bad)
    3e39:	add    BYTE PTR [rax],al
    3e3b:	add    BYTE PTR [rax],al
    3e3d:	add    BYTE PTR [rax],al
	...

0000000000003e40 <botlish_entry_32: domain_loop<generic>>:
    3e40:	push   rbp
    3e41:	mov    rbp,rsp
    3e44:	mov    rsi,QWORD PTR [rdx]
    3e47:	mov    r8,QWORD PTR [rdx+0x8]
    3e4b:	mov    rcx,QWORD PTR [rdx+0x10]
    3e4f:	mov    rdx,r8
    3e52:	call   3e57 <botlish_entry_32+0x17>
			3e53: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    3e57:	mov    rsp,rbp
    3e5a:	pop    rbp
    3e5b:	ret

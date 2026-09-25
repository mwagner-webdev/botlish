; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 17855  (per function: 1172 39 337 625 377 385 385 164 164 199 125 214 484 864 525 1004 504 681 769 450 884 644 540 540 636 681 769 450 884 644 540 540 636)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> char::codepoint<UnicodeChar>
;   botlish_fn_2 / botlish_entry_2 -> byte::from_int<int>
;   botlish_fn_3 / botlish_entry_3 -> byte::set<List[UnicodeChar]>
;   botlish_fn_4 / botlish_entry_4 -> ascii::is_digit<generic>
;   botlish_fn_5 / botlish_entry_5 -> ascii::is_upper<generic>
;   botlish_fn_6 / botlish_entry_6 -> ascii::is_lower<generic>
;   botlish_fn_7 / botlish_entry_7 -> ascii::is_alphabetic<generic>
;   botlish_fn_8 / botlish_entry_8 -> ascii::is_alphanumeric<generic>
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
     821:	add    BYTE PTR [rax],al
     823:	add    BYTE PTR [rax],al
     825:	add    BYTE PTR [rax],al
	...

0000000000000828 <botlish_fn_4: ascii::is_digit<generic>>:
     828:	push   rbp
     829:	mov    rbp,rsp
     82c:	sub    rsp,0x10
     830:	mov    QWORD PTR [rsp],rbx
     834:	mov    QWORD PTR [rsp+0x8],r12
     839:	mov    r8d,0x1
     83f:	test   rsi,0x1
     846:	jne    866 <botlish_fn_4+0x3e>
     84c:	xor    r8d,r8d
     84f:	test   rsi,0x7
     856:	jne    866 <botlish_fn_4+0x3e>
     85c:	movzx  rax,BYTE PTR [rsi]
     860:	cmp    al,0x1
     862:	sete   r8b
     866:	test   r8b,r8b
     869:	jne    89a <botlish_fn_4+0x72>
     86f:	mov    rax,QWORD PTR [rdi+0x10]
     873:	mov    rcx,QWORD PTR [rax+0xa8]
     87a:	xor    rbx,rbx
     87d:	mov    rdx,rbx
     880:	call   885 <botlish_fn_4+0x5d>
			881: R_X86_64_PLT32	rt_type_error-0x4
     885:	mov    rax,rbx
     888:	mov    rbx,QWORD PTR [rsp]
     88c:	mov    r12,QWORD PTR [rsp+0x8]
     891:	add    rsp,0x10
     895:	mov    rsp,rbp
     898:	pop    rbp
     899:	ret
     89a:	mov    r12,rdi
     89d:	test   rsi,0x1
     8a4:	mov    rbx,rsi
     8a7:	jne    8d5 <botlish_fn_4+0xad>
     8ad:	mov    edx,0x61
     8b2:	mov    rsi,rbx
     8b5:	mov    rdi,r12
     8b8:	call   8bd <botlish_fn_4+0x95>
			8b9: R_X86_64_PLT32	rt_int_cmp-0x4
     8bd:	mov    ecx,0x2
     8c2:	test   rax,rax
     8c5:	cmovge rcx,QWORD PTR [rip+0xab]        # 978 <botlish_fn_4+0x150>
     8cd:	mov    rsi,rbx
     8d0:	jmp    8e9 <botlish_fn_4+0xc1>
     8d5:	mov    ecx,0x2
     8da:	mov    rsi,rbx
     8dd:	cmp    rsi,0x61
     8e1:	cmovge rcx,QWORD PTR [rip+0x8f]        # 978 <botlish_fn_4+0x150>
     8e9:	mov    eax,0x6
     8ee:	cmp    rcx,0x6
     8f2:	je     905 <botlish_fn_4+0xdd>
     8f8:	mov    eax,0x2
     8fd:	mov    rbx,rax
     900:	jmp    95f <botlish_fn_4+0x137>
     905:	mov    rbx,rax
     908:	test   rsi,0x1
     90f:	jne    937 <botlish_fn_4+0x10f>
     915:	mov    edx,0x73
     91a:	mov    rdi,r12
     91d:	call   922 <botlish_fn_4+0xfa>
			91e: R_X86_64_PLT32	rt_int_cmp-0x4
     922:	mov    ecx,0x2
     927:	test   rax,rax
     92a:	cmovle rcx,QWORD PTR [rip+0x46]        # 978 <botlish_fn_4+0x150>
     932:	jmp    948 <botlish_fn_4+0x120>
     937:	mov    ecx,0x2
     93c:	cmp    rsi,0x73
     940:	cmovle rcx,QWORD PTR [rip+0x30]        # 978 <botlish_fn_4+0x150>
     948:	cmp    rcx,0x6
     94c:	je     95c <botlish_fn_4+0x134>
     952:	mov    eax,0x2
     957:	jmp    95f <botlish_fn_4+0x137>
     95c:	mov    rax,rbx
     95f:	mov    rbx,QWORD PTR [rsp]
     963:	mov    r12,QWORD PTR [rsp+0x8]
     968:	add    rsp,0x10
     96c:	mov    rsp,rbp
     96f:	pop    rbp
     970:	ret
     971:	add    BYTE PTR [rax],al
     973:	add    BYTE PTR [rax],al
     975:	add    BYTE PTR [rax],al
     977:	add    BYTE PTR [rsi],al
     979:	add    BYTE PTR [rax],al
     97b:	add    BYTE PTR [rax],al
     97d:	add    BYTE PTR [rax],al
	...

0000000000000980 <botlish_entry_4: ascii::is_digit<generic>>:
     980:	push   rbp
     981:	mov    rbp,rsp
     984:	mov    rsi,QWORD PTR [rdx]
     987:	call   98c <botlish_entry_4+0xc>
			988: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<generic>
     98c:	mov    rsp,rbp
     98f:	pop    rbp
     990:	ret
     991:	add    BYTE PTR [rax],al
     993:	add    BYTE PTR [rax],al
     995:	add    BYTE PTR [rax],al
	...

0000000000000998 <botlish_fn_5: ascii::is_upper<generic>>:
     998:	push   rbp
     999:	mov    rbp,rsp
     99c:	sub    rsp,0x10
     9a0:	mov    QWORD PTR [rsp],rbx
     9a4:	mov    QWORD PTR [rsp+0x8],r12
     9a9:	mov    r8d,0x1
     9af:	test   rsi,0x1
     9b6:	jne    9d6 <botlish_fn_5+0x3e>
     9bc:	xor    r8d,r8d
     9bf:	test   rsi,0x7
     9c6:	jne    9d6 <botlish_fn_5+0x3e>
     9cc:	movzx  rax,BYTE PTR [rsi]
     9d0:	cmp    al,0x1
     9d2:	sete   r8b
     9d6:	test   r8b,r8b
     9d9:	jne    a0a <botlish_fn_5+0x72>
     9df:	mov    rax,QWORD PTR [rdi+0x10]
     9e3:	mov    rcx,QWORD PTR [rax+0xa8]
     9ea:	xor    rbx,rbx
     9ed:	mov    rdx,rbx
     9f0:	call   9f5 <botlish_fn_5+0x5d>
			9f1: R_X86_64_PLT32	rt_type_error-0x4
     9f5:	mov    rax,rbx
     9f8:	mov    rbx,QWORD PTR [rsp]
     9fc:	mov    r12,QWORD PTR [rsp+0x8]
     a01:	add    rsp,0x10
     a05:	mov    rsp,rbp
     a08:	pop    rbp
     a09:	ret
     a0a:	mov    r12,rdi
     a0d:	test   rsi,0x1
     a14:	mov    rbx,rsi
     a17:	jne    a45 <botlish_fn_5+0xad>
     a1d:	mov    edx,0x83
     a22:	mov    rsi,rbx
     a25:	mov    rdi,r12
     a28:	call   a2d <botlish_fn_5+0x95>
			a29: R_X86_64_PLT32	rt_int_cmp-0x4
     a2d:	mov    ecx,0x2
     a32:	test   rax,rax
     a35:	cmovge rcx,QWORD PTR [rip+0xab]        # ae8 <botlish_fn_5+0x150>
     a3d:	mov    rsi,rbx
     a40:	jmp    a5c <botlish_fn_5+0xc4>
     a45:	mov    ecx,0x2
     a4a:	mov    rsi,rbx
     a4d:	cmp    rsi,0x83
     a54:	cmovge rcx,QWORD PTR [rip+0x8c]        # ae8 <botlish_fn_5+0x150>
     a5c:	mov    eax,0x6
     a61:	cmp    rcx,0x6
     a65:	je     a78 <botlish_fn_5+0xe0>
     a6b:	mov    eax,0x2
     a70:	mov    rbx,rax
     a73:	jmp    ad5 <botlish_fn_5+0x13d>
     a78:	mov    rbx,rax
     a7b:	test   rsi,0x1
     a82:	jne    aaa <botlish_fn_5+0x112>
     a88:	mov    edx,0xb5
     a8d:	mov    rdi,r12
     a90:	call   a95 <botlish_fn_5+0xfd>
			a91: R_X86_64_PLT32	rt_int_cmp-0x4
     a95:	mov    ecx,0x2
     a9a:	test   rax,rax
     a9d:	cmovle rcx,QWORD PTR [rip+0x43]        # ae8 <botlish_fn_5+0x150>
     aa5:	jmp    abe <botlish_fn_5+0x126>
     aaa:	mov    ecx,0x2
     aaf:	cmp    rsi,0xb5
     ab6:	cmovle rcx,QWORD PTR [rip+0x2a]        # ae8 <botlish_fn_5+0x150>
     abe:	cmp    rcx,0x6
     ac2:	je     ad2 <botlish_fn_5+0x13a>
     ac8:	mov    eax,0x2
     acd:	jmp    ad5 <botlish_fn_5+0x13d>
     ad2:	mov    rax,rbx
     ad5:	mov    rbx,QWORD PTR [rsp]
     ad9:	mov    r12,QWORD PTR [rsp+0x8]
     ade:	add    rsp,0x10
     ae2:	mov    rsp,rbp
     ae5:	pop    rbp
     ae6:	ret
     ae7:	add    BYTE PTR [rsi],al
     ae9:	add    BYTE PTR [rax],al
     aeb:	add    BYTE PTR [rax],al
     aed:	add    BYTE PTR [rax],al
	...

0000000000000af0 <botlish_entry_5: ascii::is_upper<generic>>:
     af0:	push   rbp
     af1:	mov    rbp,rsp
     af4:	mov    rsi,QWORD PTR [rdx]
     af7:	call   afc <botlish_entry_5+0xc>
			af8: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<generic>
     afc:	mov    rsp,rbp
     aff:	pop    rbp
     b00:	ret
     b01:	add    BYTE PTR [rax],al
     b03:	add    BYTE PTR [rax],al
     b05:	add    BYTE PTR [rax],al
	...

0000000000000b08 <botlish_fn_6: ascii::is_lower<generic>>:
     b08:	push   rbp
     b09:	mov    rbp,rsp
     b0c:	sub    rsp,0x10
     b10:	mov    QWORD PTR [rsp],rbx
     b14:	mov    QWORD PTR [rsp+0x8],r12
     b19:	mov    r8d,0x1
     b1f:	test   rsi,0x1
     b26:	jne    b46 <botlish_fn_6+0x3e>
     b2c:	xor    r8d,r8d
     b2f:	test   rsi,0x7
     b36:	jne    b46 <botlish_fn_6+0x3e>
     b3c:	movzx  rax,BYTE PTR [rsi]
     b40:	cmp    al,0x1
     b42:	sete   r8b
     b46:	test   r8b,r8b
     b49:	jne    b7a <botlish_fn_6+0x72>
     b4f:	mov    rax,QWORD PTR [rdi+0x10]
     b53:	mov    rcx,QWORD PTR [rax+0xa8]
     b5a:	xor    rbx,rbx
     b5d:	mov    rdx,rbx
     b60:	call   b65 <botlish_fn_6+0x5d>
			b61: R_X86_64_PLT32	rt_type_error-0x4
     b65:	mov    rax,rbx
     b68:	mov    rbx,QWORD PTR [rsp]
     b6c:	mov    r12,QWORD PTR [rsp+0x8]
     b71:	add    rsp,0x10
     b75:	mov    rsp,rbp
     b78:	pop    rbp
     b79:	ret
     b7a:	mov    r12,rdi
     b7d:	test   rsi,0x1
     b84:	mov    rbx,rsi
     b87:	jne    bb5 <botlish_fn_6+0xad>
     b8d:	mov    edx,0xc3
     b92:	mov    rsi,rbx
     b95:	mov    rdi,r12
     b98:	call   b9d <botlish_fn_6+0x95>
			b99: R_X86_64_PLT32	rt_int_cmp-0x4
     b9d:	mov    ecx,0x2
     ba2:	test   rax,rax
     ba5:	cmovge rcx,QWORD PTR [rip+0xab]        # c58 <botlish_fn_6+0x150>
     bad:	mov    rsi,rbx
     bb0:	jmp    bcc <botlish_fn_6+0xc4>
     bb5:	mov    ecx,0x2
     bba:	mov    rsi,rbx
     bbd:	cmp    rsi,0xc3
     bc4:	cmovge rcx,QWORD PTR [rip+0x8c]        # c58 <botlish_fn_6+0x150>
     bcc:	mov    eax,0x6
     bd1:	cmp    rcx,0x6
     bd5:	je     be8 <botlish_fn_6+0xe0>
     bdb:	mov    eax,0x2
     be0:	mov    rbx,rax
     be3:	jmp    c45 <botlish_fn_6+0x13d>
     be8:	mov    rbx,rax
     beb:	test   rsi,0x1
     bf2:	jne    c1a <botlish_fn_6+0x112>
     bf8:	mov    edx,0xf5
     bfd:	mov    rdi,r12
     c00:	call   c05 <botlish_fn_6+0xfd>
			c01: R_X86_64_PLT32	rt_int_cmp-0x4
     c05:	mov    ecx,0x2
     c0a:	test   rax,rax
     c0d:	cmovle rcx,QWORD PTR [rip+0x43]        # c58 <botlish_fn_6+0x150>
     c15:	jmp    c2e <botlish_fn_6+0x126>
     c1a:	mov    ecx,0x2
     c1f:	cmp    rsi,0xf5
     c26:	cmovle rcx,QWORD PTR [rip+0x2a]        # c58 <botlish_fn_6+0x150>
     c2e:	cmp    rcx,0x6
     c32:	je     c42 <botlish_fn_6+0x13a>
     c38:	mov    eax,0x2
     c3d:	jmp    c45 <botlish_fn_6+0x13d>
     c42:	mov    rax,rbx
     c45:	mov    rbx,QWORD PTR [rsp]
     c49:	mov    r12,QWORD PTR [rsp+0x8]
     c4e:	add    rsp,0x10
     c52:	mov    rsp,rbp
     c55:	pop    rbp
     c56:	ret
     c57:	add    BYTE PTR [rsi],al
     c59:	add    BYTE PTR [rax],al
     c5b:	add    BYTE PTR [rax],al
     c5d:	add    BYTE PTR [rax],al
	...

0000000000000c60 <botlish_entry_6: ascii::is_lower<generic>>:
     c60:	push   rbp
     c61:	mov    rbp,rsp
     c64:	mov    rsi,QWORD PTR [rdx]
     c67:	call   c6c <botlish_entry_6+0xc>
			c68: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<generic>
     c6c:	mov    rsp,rbp
     c6f:	pop    rbp
     c70:	ret

0000000000000c71 <botlish_fn_7: ascii::is_alphabetic<generic>>:
     c71:	push   rbp
     c72:	mov    rbp,rsp
     c75:	sub    rsp,0x10
     c79:	mov    QWORD PTR [rsp],r12
     c7d:	mov    QWORD PTR [rsp+0x8],r14
     c82:	mov    r12,rsi
     c85:	mov    r14,rdi
     c88:	mov    rsi,r12
     c8b:	mov    rdi,r14
     c8e:	call   c93 <botlish_fn_7+0x22>
			c8f: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<generic>
     c93:	test   rax,rax
     c96:	je     cba <botlish_fn_7+0x49>
     c9c:	cmp    rax,0x6
     ca0:	je     ced <botlish_fn_7+0x7c>
     ca6:	mov    rsi,r12
     ca9:	mov    rdi,r14
     cac:	call   cb1 <botlish_fn_7+0x40>
			cad: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<generic>
     cb1:	test   rax,rax
     cb4:	jne    ccf <botlish_fn_7+0x5e>
     cba:	xor    rax,rax
     cbd:	mov    r12,QWORD PTR [rsp]
     cc1:	mov    r14,QWORD PTR [rsp+0x8]
     cc6:	add    rsp,0x10
     cca:	mov    rsp,rbp
     ccd:	pop    rbp
     cce:	ret
     ccf:	cmp    rax,0x6
     cd3:	je     ce3 <botlish_fn_7+0x72>
     cd9:	mov    eax,0x2
     cde:	jmp    cf2 <botlish_fn_7+0x81>
     ce3:	mov    eax,0x6
     ce8:	jmp    cf2 <botlish_fn_7+0x81>
     ced:	mov    eax,0x6
     cf2:	mov    r12,QWORD PTR [rsp]
     cf6:	mov    r14,QWORD PTR [rsp+0x8]
     cfb:	add    rsp,0x10
     cff:	mov    rsp,rbp
     d02:	pop    rbp
     d03:	ret

0000000000000d04 <botlish_entry_7: ascii::is_alphabetic<generic>>:
     d04:	push   rbp
     d05:	mov    rbp,rsp
     d08:	mov    rsi,QWORD PTR [rdx]
     d0b:	call   d10 <botlish_entry_7+0xc>
			d0c: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<generic>
     d10:	mov    rsp,rbp
     d13:	pop    rbp
     d14:	ret

0000000000000d15 <botlish_fn_8: ascii::is_alphanumeric<generic>>:
     d15:	push   rbp
     d16:	mov    rbp,rsp
     d19:	sub    rsp,0x10
     d1d:	mov    QWORD PTR [rsp],r12
     d21:	mov    QWORD PTR [rsp+0x8],r14
     d26:	mov    r12,rsi
     d29:	mov    r14,rdi
     d2c:	mov    rsi,r12
     d2f:	mov    rdi,r14
     d32:	call   d37 <botlish_fn_8+0x22>
			d33: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<generic>
     d37:	test   rax,rax
     d3a:	je     d5e <botlish_fn_8+0x49>
     d40:	cmp    rax,0x6
     d44:	je     d91 <botlish_fn_8+0x7c>
     d4a:	mov    rsi,r12
     d4d:	mov    rdi,r14
     d50:	call   d55 <botlish_fn_8+0x40>
			d51: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<generic>
     d55:	test   rax,rax
     d58:	jne    d73 <botlish_fn_8+0x5e>
     d5e:	xor    rax,rax
     d61:	mov    r12,QWORD PTR [rsp]
     d65:	mov    r14,QWORD PTR [rsp+0x8]
     d6a:	add    rsp,0x10
     d6e:	mov    rsp,rbp
     d71:	pop    rbp
     d72:	ret
     d73:	cmp    rax,0x6
     d77:	je     d87 <botlish_fn_8+0x72>
     d7d:	mov    eax,0x2
     d82:	jmp    d96 <botlish_fn_8+0x81>
     d87:	mov    eax,0x6
     d8c:	jmp    d96 <botlish_fn_8+0x81>
     d91:	mov    eax,0x6
     d96:	mov    r12,QWORD PTR [rsp]
     d9a:	mov    r14,QWORD PTR [rsp+0x8]
     d9f:	add    rsp,0x10
     da3:	mov    rsp,rbp
     da6:	pop    rbp
     da7:	ret

0000000000000da8 <botlish_entry_8: ascii::is_alphanumeric<generic>>:
     da8:	push   rbp
     da9:	mov    rbp,rsp
     dac:	mov    rsi,QWORD PTR [rdx]
     daf:	call   db4 <botlish_entry_8+0xc>
			db0: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<generic>
     db4:	mov    rsp,rbp
     db7:	pop    rbp
     db8:	ret

0000000000000db9 <botlish_fn_9: web::is_unreserved<generic>>:
     db9:	push   rbp
     dba:	mov    rbp,rsp
     dbd:	sub    rsp,0x20
     dc1:	mov    QWORD PTR [rsp],rbx
     dc5:	mov    QWORD PTR [rsp+0x8],r12
     dca:	mov    QWORD PTR [rsp+0x10],r15
     dcf:	mov    rbx,rdi
     dd2:	mov    r12,rsi
     dd5:	mov    r15,rdx
     dd8:	mov    rsi,r15
     ddb:	mov    rdi,rbx
     dde:	call   de3 <botlish_fn_9+0x2a>
			ddf: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<generic>
     de3:	test   rax,rax
     de6:	je     e14 <botlish_fn_9+0x5b>
     dec:	cmp    rax,0x6
     df0:	je     e4c <botlish_fn_9+0x93>
     df6:	mov    rsi,r12
     df9:	mov    rax,QWORD PTR [rsi+0x20]
     dfd:	mov    rsi,QWORD PTR [rax]
     e00:	mov    rdx,r15
     e03:	mov    rdi,rbx
     e06:	call   e0b <botlish_fn_9+0x52>
			e07: R_X86_64_PLT32	rt_set_contains-0x4
     e0b:	test   rax,rax
     e0e:	jne    e2e <botlish_fn_9+0x75>
     e14:	xor    rax,rax
     e17:	mov    rbx,QWORD PTR [rsp]
     e1b:	mov    r12,QWORD PTR [rsp+0x8]
     e20:	mov    r15,QWORD PTR [rsp+0x10]
     e25:	add    rsp,0x20
     e29:	mov    rsp,rbp
     e2c:	pop    rbp
     e2d:	ret
     e2e:	cmp    rax,0x6
     e32:	je     e42 <botlish_fn_9+0x89>
     e38:	mov    eax,0x2
     e3d:	jmp    e51 <botlish_fn_9+0x98>
     e42:	mov    eax,0x6
     e47:	jmp    e51 <botlish_fn_9+0x98>
     e4c:	mov    eax,0x6
     e51:	mov    rbx,QWORD PTR [rsp]
     e55:	mov    r12,QWORD PTR [rsp+0x8]
     e5a:	mov    r15,QWORD PTR [rsp+0x10]
     e5f:	add    rsp,0x20
     e63:	mov    rsp,rbp
     e66:	pop    rbp
     e67:	ret

0000000000000e68 <botlish_entry_9: web::is_unreserved<generic>>:
     e68:	push   rbp
     e69:	mov    rbp,rsp
     e6c:	mov    rdx,QWORD PTR [rdx]
     e6f:	call   e74 <botlish_entry_9+0xc>
			e70: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_unreserved<generic>
     e74:	mov    rsp,rbp
     e77:	pop    rbp
     e78:	ret

0000000000000e79 <botlish_fn_10: web::uri_escape_text<generic>>:
     e79:	push   rbp
     e7a:	mov    rbp,rsp
     e7d:	sub    rsp,0x30
     e81:	mov    QWORD PTR [rsp],rdx
     e85:	mov    r10,rdx
     e88:	mov    edx,0x1
     e8d:	mov    QWORD PTR [rsp+0x8],0x1
     e96:	mov    rax,QWORD PTR [rdi+0x10]
     e9a:	mov    rcx,QWORD PTR [rax+0xb0]
     ea1:	mov    QWORD PTR [rsp+0x10],rcx
     ea6:	mov    rax,QWORD PTR [rsi+0x20]
     eaa:	mov    r8,QWORD PTR [rax+0x8]
     eae:	mov    QWORD PTR [rsp+0x18],r8
     eb3:	mov    rax,QWORD PTR [rsi+0x20]
     eb7:	mov    r9,QWORD PTR [rax]
     eba:	mov    QWORD PTR [rsp+0x20],r9
     ebf:	mov    rsi,r10
     ec2:	call   ec7 <botlish_fn_10+0x4e>
			ec3: R_X86_64_PLT32	botlish_fn_15-0x4 ; esc_from<generic>
     ec7:	test   rax,rax
     eca:	jne    edc <botlish_fn_10+0x63>
     ed0:	xor    rax,rax
     ed3:	add    rsp,0x30
     ed7:	mov    rsp,rbp
     eda:	pop    rbp
     edb:	ret
     edc:	add    rsp,0x30
     ee0:	mov    rsp,rbp
     ee3:	pop    rbp
     ee4:	ret

0000000000000ee5 <botlish_entry_10: web::uri_escape_text<generic>>:
     ee5:	push   rbp
     ee6:	mov    rbp,rsp
     ee9:	mov    rdx,QWORD PTR [rdx]
     eec:	call   ef1 <botlish_entry_10+0xc>
			eed: R_X86_64_PLT32	botlish_fn_10-0x4 ; web::uri_escape_text<generic>
     ef1:	mov    rsp,rbp
     ef4:	pop    rbp
     ef5:	ret

0000000000000ef6 <botlish_fn_11: high_nibble<generic>>:
     ef6:	push   rbp
     ef7:	mov    rbp,rsp
     efa:	sub    rsp,0x20
     efe:	mov    QWORD PTR [rsp+0x10],rbx
     f03:	mov    QWORD PTR [rsp],rsi
     f07:	mov    QWORD PTR [rsp+0x8],0x1e1
     f10:	mov    r8d,0x1
     f16:	test   rsi,0x1
     f1d:	jne    f3d <botlish_fn_11+0x47>
     f23:	xor    r8d,r8d
     f26:	test   rsi,0x7
     f2d:	jne    f3d <botlish_fn_11+0x47>
     f33:	movzx  rax,BYTE PTR [rsi]
     f37:	cmp    al,0x1
     f39:	sete   r8b
     f3d:	test   r8b,r8b
     f40:	jne    f6d <botlish_fn_11+0x77>
     f46:	mov    rax,QWORD PTR [rdi+0x10]
     f4a:	mov    rcx,QWORD PTR [rax+0xb8]
     f51:	xor    rbx,rbx
     f54:	mov    rdx,rbx
     f57:	call   f5c <botlish_fn_11+0x66>
			f58: R_X86_64_PLT32	rt_type_error-0x4
     f5c:	mov    rax,rbx
     f5f:	mov    rbx,QWORD PTR [rsp+0x10]
     f64:	add    rsp,0x20
     f68:	mov    rsp,rbp
     f6b:	pop    rbp
     f6c:	ret
     f6d:	test   rsi,0x1
     f74:	jne    f89 <botlish_fn_11+0x93>
     f7a:	mov    edx,0x1e1
     f7f:	call   f84 <botlish_fn_11+0x8e>
			f80: R_X86_64_PLT32	rt_int_and-0x4
     f84:	jmp    f93 <botlish_fn_11+0x9d>
     f89:	and    rsi,0x1e1
     f90:	mov    rax,rsi
     f93:	sar    rax,0x5
     f97:	shl    rax,1
     f9a:	or     rax,0x1
     f9e:	mov    rbx,QWORD PTR [rsp+0x10]
     fa3:	add    rsp,0x20
     fa7:	mov    rsp,rbp
     faa:	pop    rbp
     fab:	ret

0000000000000fac <botlish_entry_11: high_nibble<generic>>:
     fac:	push   rbp
     fad:	mov    rbp,rsp
     fb0:	mov    rsi,QWORD PTR [rdx]
     fb3:	call   fb8 <botlish_entry_11+0xc>
			fb4: R_X86_64_PLT32	botlish_fn_11-0x4 ; high_nibble<generic>
     fb8:	mov    rsp,rbp
     fbb:	pop    rbp
     fbc:	ret

0000000000000fbd <botlish_fn_12: hex_pair<generic>>:
     fbd:	push   rbp
     fbe:	mov    rbp,rsp
     fc1:	sub    rsp,0x30
     fc5:	mov    QWORD PTR [rsp+0x10],rbx
     fca:	mov    QWORD PTR [rsp+0x18],r12
     fcf:	mov    QWORD PTR [rsp+0x20],r13
     fd4:	mov    QWORD PTR [rsp+0x28],r14
     fd9:	mov    r12,rdi
     fdc:	mov    QWORD PTR [rsp],rsi
     fe0:	mov    r13,rsi
     fe3:	mov    QWORD PTR [rsp+0x8],rdx
     fe8:	mov    rbx,rdx
     feb:	mov    rsi,r13
     fee:	mov    rdi,r12
     ff1:	call   ff6 <botlish_fn_12+0x39>
			ff2: R_X86_64_PLT32	botlish_fn_11-0x4 ; high_nibble<generic>
     ff6:	test   rax,rax
     ff9:	je     1127 <botlish_fn_12+0x16a>
     fff:	test   rax,0x1
    1005:	jne    1013 <botlish_fn_12+0x56>
    100b:	mov    rdx,rax
    100e:	jmp    1029 <botlish_fn_12+0x6c>
    1013:	mov    rdx,QWORD PTR [rbx+0x8]
    1017:	mov    rcx,rax
    101a:	sar    rcx,1
    101d:	cmp    rcx,rdx
    1020:	jb     1045 <botlish_fn_12+0x88>
    1026:	mov    rdx,rax
    1029:	mov    rsi,rbx
    102c:	mov    rdi,r12
    102f:	call   1034 <botlish_fn_12+0x77>
			1030: R_X86_64_PLT32	rt_list_get-0x4
    1034:	test   rax,rax
    1037:	je     1127 <botlish_fn_12+0x16a>
    103d:	mov    rsi,rax
    1040:	jmp    104d <botlish_fn_12+0x90>
    1045:	mov    rax,QWORD PTR [rbx+0x10]
    1049:	mov    rsi,QWORD PTR [rax+rcx*8]
    104d:	mov    QWORD PTR [rsp],rsi
    1051:	mov    r14,rsi
    1054:	mov    ecx,0x1
    1059:	mov    rsi,r13
    105c:	test   rsi,0x1
    1063:	jne    1081 <botlish_fn_12+0xc4>
    1069:	xor    ecx,ecx
    106b:	test   rsi,0x7
    1072:	jne    1081 <botlish_fn_12+0xc4>
    1078:	movzx  rax,BYTE PTR [rsi]
    107c:	cmp    al,0x1
    107e:	sete   cl
    1081:	test   cl,cl
    1083:	jne    10a4 <botlish_fn_12+0xe7>
    1089:	mov    rdi,r12
    108c:	mov    rax,QWORD PTR [rdi+0x10]
    1090:	mov    rcx,QWORD PTR [rax+0xc0]
    1097:	xor    rdx,rdx
    109a:	call   109f <botlish_fn_12+0xe2>
			109b: R_X86_64_PLT32	rt_type_error-0x4
    109f:	jmp    1127 <botlish_fn_12+0x16a>
    10a4:	mov    edx,0x21
    10a9:	mov    rdi,r12
    10ac:	call   10b1 <botlish_fn_12+0xf4>
			10ad: R_X86_64_PLT32	rt_int_mod-0x4
    10b1:	test   rax,rax
    10b4:	je     1127 <botlish_fn_12+0x16a>
    10ba:	test   rax,0x1
    10c0:	jne    10d1 <botlish_fn_12+0x114>
    10c6:	mov    rdx,rax
    10c9:	mov    rsi,rbx
    10cc:	jmp    10ea <botlish_fn_12+0x12d>
    10d1:	mov    rdi,QWORD PTR [rbx+0x8]
    10d5:	mov    rsi,rax
    10d8:	sar    rsi,1
    10db:	mov    rdx,rax
    10de:	cmp    rsi,rdi
    10e1:	jb     1103 <botlish_fn_12+0x146>
    10e7:	mov    rsi,rbx
    10ea:	mov    rdi,r12
    10ed:	call   10f2 <botlish_fn_12+0x135>
			10ee: R_X86_64_PLT32	rt_list_get-0x4
    10f2:	test   rax,rax
    10f5:	je     1127 <botlish_fn_12+0x16a>
    10fb:	mov    rdx,rax
    10fe:	jmp    110e <botlish_fn_12+0x151>
    1103:	mov    rax,rbx
    1106:	mov    rax,QWORD PTR [rax+0x10]
    110a:	mov    rdx,QWORD PTR [rax+rsi*8]
    110e:	mov    QWORD PTR [rsp+0x8],rdx
    1113:	mov    rsi,r14
    1116:	mov    rdi,r12
    1119:	call   111e <botlish_fn_12+0x161>
			111a: R_X86_64_PLT32	rt_str_cat-0x4
    111e:	test   rax,rax
    1121:	jne    1147 <botlish_fn_12+0x18a>
    1127:	xor    rax,rax
    112a:	mov    rbx,QWORD PTR [rsp+0x10]
    112f:	mov    r12,QWORD PTR [rsp+0x18]
    1134:	mov    r13,QWORD PTR [rsp+0x20]
    1139:	mov    r14,QWORD PTR [rsp+0x28]
    113e:	add    rsp,0x30
    1142:	mov    rsp,rbp
    1145:	pop    rbp
    1146:	ret
    1147:	mov    rbx,QWORD PTR [rsp+0x10]
    114c:	mov    r12,QWORD PTR [rsp+0x18]
    1151:	mov    r13,QWORD PTR [rsp+0x20]
    1156:	mov    r14,QWORD PTR [rsp+0x28]
    115b:	add    rsp,0x30
    115f:	mov    rsp,rbp
    1162:	pop    rbp
    1163:	ret

0000000000001164 <botlish_entry_12: hex_pair<generic>>:
    1164:	push   rbp
    1165:	mov    rbp,rsp
    1168:	mov    rsi,QWORD PTR [rdx]
    116b:	mov    rdx,QWORD PTR [rdx+0x8]
    116f:	call   1174 <botlish_entry_12+0x10>
			1170: R_X86_64_PLT32	botlish_fn_12-0x4 ; hex_pair<generic>
    1174:	mov    rsp,rbp
    1177:	pop    rbp
    1178:	ret
    1179:	add    BYTE PTR [rax],al
    117b:	add    BYTE PTR [rax],al
    117d:	add    BYTE PTR [rax],al
	...

0000000000001180 <botlish_fn_13: esc_bytes<generic>>:
    1180:	push   rbp
    1181:	mov    rbp,rsp
    1184:	sub    rsp,0x70
    1188:	mov    QWORD PTR [rsp+0x40],rbx
    118d:	mov    QWORD PTR [rsp+0x48],r12
    1192:	mov    QWORD PTR [rsp+0x50],r13
    1197:	mov    QWORD PTR [rsp+0x58],r14
    119c:	mov    QWORD PTR [rsp+0x60],r15
    11a1:	mov    r13,rdi
    11a4:	mov    QWORD PTR [rsp+0x28],0x0
    11ad:	mov    QWORD PTR [rsp],rsi
    11b1:	mov    QWORD PTR [rsp+0x8],rdx
    11b6:	mov    QWORD PTR [rsp+0x10],rcx
    11bb:	mov    QWORD PTR [rsp+0x18],r8
    11c0:	mov    r12,r8
    11c3:	mov    r14,rcx
    11c6:	mov    r15,rdx
    11c9:	xor    eax,eax
    11cb:	test   rsi,0x7
    11d2:	jne    11e3 <botlish_fn_13+0x63>
    11d8:	movzx  r8,BYTE PTR [rsi]
    11dc:	cmp    r8b,0x3
    11e0:	sete   al
    11e3:	test   al,al
    11e5:	jne    1208 <botlish_fn_13+0x88>
    11eb:	mov    rdi,r13
    11ee:	mov    rax,QWORD PTR [rdi+0x10]
    11f2:	mov    rcx,QWORD PTR [rax+0xc8]
    11f9:	mov    edx,0x4
    11fe:	call   1203 <botlish_fn_13+0x83>
			11ff: R_X86_64_PLT32	rt_type_error-0x4
    1203:	jmp    140e <botlish_fn_13+0x28e>
    1208:	mov    rbx,rsi
    120b:	mov    rdi,r13
    120e:	call   1213 <botlish_fn_13+0x93>
			120f: R_X86_64_PLT32	rt_list_len-0x4
    1213:	mov    ecx,0x1
    1218:	mov    rsi,r15
    121b:	test   rsi,0x1
    1222:	jne    1248 <botlish_fn_13+0xc8>
    1228:	xor    ecx,ecx
    122a:	mov    rsi,r15
    122d:	test   rsi,0x7
    1234:	jne    1248 <botlish_fn_13+0xc8>
    123a:	mov    rsi,r15
    123d:	movzx  rcx,BYTE PTR [rsi]
    1241:	rex cmp cl,0x1
    1245:	sete   cl
    1248:	test   cl,cl
    124a:	jne    126e <botlish_fn_13+0xee>
    1250:	mov    rdi,r13
    1253:	mov    rax,QWORD PTR [rdi+0x10]
    1257:	mov    rcx,QWORD PTR [rax+0xa8]
    125e:	xor    rdx,rdx
    1261:	mov    rsi,r15
    1264:	call   1269 <botlish_fn_13+0xe9>
			1265: R_X86_64_PLT32	rt_type_error-0x4
    1269:	jmp    140e <botlish_fn_13+0x28e>
    126e:	mov    rsi,r15
    1271:	mov    rcx,rsi
    1274:	and    rcx,rax
    1277:	mov    rdx,rax
    127a:	test   rcx,0x1
    1281:	jne    12a7 <botlish_fn_13+0x127>
    1287:	mov    rsi,r15
    128a:	mov    rdi,r13
    128d:	call   1292 <botlish_fn_13+0x112>
			128e: R_X86_64_PLT32	rt_int_cmp-0x4
    1292:	mov    ecx,0x2
    1297:	test   rax,rax
    129a:	cmovge rcx,QWORD PTR [rip+0x1de]        # 1480 <botlish_fn_13+0x300>
    12a2:	jmp    12ba <botlish_fn_13+0x13a>
    12a7:	mov    ecx,0x2
    12ac:	mov    rsi,r15
    12af:	cmp    rsi,rdx
    12b2:	cmovge rcx,QWORD PTR [rip+0x1c6]        # 1480 <botlish_fn_13+0x300>
    12ba:	cmp    rcx,0x6
    12be:	je     1459 <botlish_fn_13+0x2d9>
    12c4:	mov    QWORD PTR [rsp+0x20],0x3
    12cd:	mov    rsi,r15
    12d0:	test   rsi,0x1
    12d7:	je     12f2 <botlish_fn_13+0x172>
    12dd:	mov    rsi,r15
    12e0:	mov    rax,rsi
    12e3:	add    rax,0x2
    12e7:	seto   cl
    12ea:	test   cl,cl
    12ec:	je     1302 <botlish_fn_13+0x182>
    12f2:	mov    edx,0x3
    12f7:	mov    rsi,r15
    12fa:	mov    rdi,r13
    12fd:	call   1302 <botlish_fn_13+0x182>
			12fe: R_X86_64_PLT32	rt_int_add-0x4
    1302:	mov    QWORD PTR [rsp+0x8],rax
    1307:	mov    rdi,r13
    130a:	mov    QWORD PTR [rsp+0x30],rax
    130f:	mov    rax,QWORD PTR [rdi+0x10]
    1313:	mov    rsi,QWORD PTR [rax+0xd0]
    131a:	mov    QWORD PTR [rsp+0x20],rsi
    131f:	mov    QWORD PTR [rsp+0x38],rsi
    1324:	mov    rsi,r15
    1327:	test   rsi,0x1
    132e:	jne    133c <botlish_fn_13+0x1bc>
    1334:	mov    rdx,r15
    1337:	jmp    1355 <botlish_fn_13+0x1d5>
    133c:	mov    rcx,QWORD PTR [rbx+0x8]
    1340:	mov    rsi,r15
    1343:	mov    rax,rsi
    1346:	sar    rax,1
    1349:	cmp    rax,rcx
    134c:	jb     1371 <botlish_fn_13+0x1f1>
    1352:	mov    rdx,r15
    1355:	mov    rsi,rbx
    1358:	mov    rdi,r13
    135b:	call   1360 <botlish_fn_13+0x1e0>
			135c: R_X86_64_PLT32	rt_list_get-0x4
    1360:	test   rax,rax
    1363:	je     140e <botlish_fn_13+0x28e>
    1369:	mov    rsi,rax
    136c:	jmp    1379 <botlish_fn_13+0x1f9>
    1371:	mov    rcx,QWORD PTR [rbx+0x10]
    1375:	mov    rsi,QWORD PTR [rcx+rax*8]
    1379:	mov    QWORD PTR [rsp+0x28],rsi
    137e:	mov    rdx,r12
    1381:	mov    rdi,r13
    1384:	call   1389 <botlish_fn_13+0x209>
			1385: R_X86_64_PLT32	botlish_fn_12-0x4 ; hex_pair<generic>
    1389:	test   rax,rax
    138c:	je     140e <botlish_fn_13+0x28e>
    1392:	mov    QWORD PTR [rsp+0x28],rax
    1397:	mov    rdx,rax
    139a:	mov    rsi,QWORD PTR [rsp+0x38]
    139f:	mov    rdi,r13
    13a2:	call   13a7 <botlish_fn_13+0x227>
			13a3: R_X86_64_PLT32	rt_str_cat-0x4
    13a7:	test   rax,rax
    13aa:	je     140e <botlish_fn_13+0x28e>
    13b0:	mov    QWORD PTR [rsp+0x20],rax
    13b5:	mov    rdx,rax
    13b8:	xor    eax,eax
    13ba:	mov    rsi,r14
    13bd:	test   rsi,0x7
    13c4:	jne    13d5 <botlish_fn_13+0x255>
    13ca:	movzx  rdi,BYTE PTR [rsi]
    13ce:	cmp    dil,0x2
    13d2:	sete   al
    13d5:	test   al,al
    13d7:	jne    13fd <botlish_fn_13+0x27d>
    13dd:	mov    rdi,r13
    13e0:	mov    rdi,QWORD PTR [rdi+0x10]
    13e4:	mov    rcx,QWORD PTR [rdi+0xd8]
    13eb:	mov    edx,0x1
    13f0:	mov    rdi,r13
    13f3:	call   13f8 <botlish_fn_13+0x278>
			13f4: R_X86_64_PLT32	rt_type_error-0x4
    13f8:	jmp    140e <botlish_fn_13+0x28e>
    13fd:	mov    rdi,r13
    1400:	call   1405 <botlish_fn_13+0x285>
			1401: R_X86_64_PLT32	rt_str_cat-0x4
    1405:	test   rax,rax
    1408:	jne    1433 <botlish_fn_13+0x2b3>
    140e:	xor    rax,rax
    1411:	mov    rbx,QWORD PTR [rsp+0x40]
    1416:	mov    r12,QWORD PTR [rsp+0x48]
    141b:	mov    r13,QWORD PTR [rsp+0x50]
    1420:	mov    r14,QWORD PTR [rsp+0x58]
    1425:	mov    r15,QWORD PTR [rsp+0x60]
    142a:	add    rsp,0x70
    142e:	mov    rsp,rbp
    1431:	pop    rbp
    1432:	ret
    1433:	mov    QWORD PTR [rsp],rbx
    1437:	mov    rcx,QWORD PTR [rsp+0x30]
    143c:	mov    QWORD PTR [rsp+0x8],rcx
    1441:	mov    QWORD PTR [rsp+0x10],rax
    1446:	mov    QWORD PTR [rsp+0x18],r12
    144b:	mov    rsi,rbx
    144e:	mov    r14,rax
    1451:	mov    r15,rcx
    1454:	jmp    11c9 <botlish_fn_13+0x49>
    1459:	mov    rax,r14
    145c:	mov    rbx,QWORD PTR [rsp+0x40]
    1461:	mov    r12,QWORD PTR [rsp+0x48]
    1466:	mov    r13,QWORD PTR [rsp+0x50]
    146b:	mov    r14,QWORD PTR [rsp+0x58]
    1470:	mov    r15,QWORD PTR [rsp+0x60]
    1475:	add    rsp,0x70
    1479:	mov    rsp,rbp
    147c:	pop    rbp
    147d:	ret
    147e:	add    BYTE PTR [rax],al
    1480:	(bad)
    1481:	add    BYTE PTR [rax],al
    1483:	add    BYTE PTR [rax],al
    1485:	add    BYTE PTR [rax],al
	...

0000000000001488 <botlish_entry_13: esc_bytes<generic>>:
    1488:	push   rbp
    1489:	mov    rbp,rsp
    148c:	mov    rsi,QWORD PTR [rdx]
    148f:	mov    r9,QWORD PTR [rdx+0x8]
    1493:	mov    rcx,QWORD PTR [rdx+0x10]
    1497:	mov    r8,QWORD PTR [rdx+0x18]
    149b:	mov    rdx,r9
    149e:	call   14a3 <botlish_entry_13+0x1b>
			149f: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    14a3:	mov    rsp,rbp
    14a6:	pop    rbp
    14a7:	ret

00000000000014a8 <botlish_fn_14: esc_char<generic>>:
    14a8:	push   rbp
    14a9:	mov    rbp,rsp
    14ac:	sub    rsp,0x60
    14b0:	mov    QWORD PTR [rsp+0x30],rbx
    14b5:	mov    QWORD PTR [rsp+0x38],r12
    14ba:	mov    QWORD PTR [rsp+0x40],r13
    14bf:	mov    QWORD PTR [rsp+0x48],r14
    14c4:	mov    QWORD PTR [rsp+0x50],r15
    14c9:	mov    QWORD PTR [rsp+0x18],0x0
    14d2:	mov    QWORD PTR [rsp],rsi
    14d6:	mov    QWORD PTR [rsp+0x8],rdx
    14db:	mov    r12,rdx
    14de:	mov    QWORD PTR [rsp+0x10],rcx
    14e3:	mov    rbx,rcx
    14e6:	xor    r10d,r10d
    14e9:	test   rsi,0x7
    14f0:	jne    1500 <botlish_fn_14+0x58>
    14f6:	movzx  rax,BYTE PTR [rsi]
    14fa:	cmp    al,0x2
    14fc:	sete   r10b
    1500:	test   r10b,r10b
    1503:	jne    1523 <botlish_fn_14+0x7b>
    1509:	mov    rax,QWORD PTR [rdi+0x10]
    150d:	mov    rcx,QWORD PTR [rax+0xe0]
    1514:	mov    edx,0x1
    1519:	call   151e <botlish_fn_14+0x76>
			151a: R_X86_64_PLT32	rt_type_error-0x4
    151e:	jmp    162b <botlish_fn_14+0x183>
    1523:	mov    r13,rdi
    1526:	mov    QWORD PTR [rsp+0x20],rsi
    152b:	call   1530 <botlish_fn_14+0x88>
			152c: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1530:	mov    rcx,rax
    1533:	mov    r14,rax
    1536:	test   rax,rcx
    1539:	je     162b <botlish_fn_14+0x183>
    153f:	mov    rax,r14
    1542:	mov    QWORD PTR [rsp],rax
    1546:	mov    rsi,r14
    1549:	mov    rdi,r13
    154c:	call   1551 <botlish_fn_14+0xa9>
			154d: R_X86_64_PLT32	rt_list_len-0x4
    1551:	mov    edx,0x1
    1556:	sar    rax,1
    1559:	cmp    rax,0x1
    155d:	je     1598 <botlish_fn_14+0xf0>
    1563:	mov    QWORD PTR [rsp+0x8],0x1
    156c:	mov    rdi,r13
    156f:	mov    rax,QWORD PTR [rdi+0x10]
    1573:	mov    rcx,QWORD PTR [rax+0xb0]
    157a:	mov    QWORD PTR [rsp+0x18],rcx
    157f:	mov    rsi,r14
    1582:	mov    r8,rbx
    1585:	call   158a <botlish_fn_14+0xe2>
			1586: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    158a:	test   rax,rax
    158d:	je     162b <botlish_fn_14+0x183>
    1593:	jmp    165a <botlish_fn_14+0x1b2>
    1598:	mov    rsi,r14
    159b:	mov    r15,rdx
    159e:	mov    rax,QWORD PTR [rsi+0x8]
    15a2:	mov    r14,rsi
    15a5:	test   rax,rax
    15a8:	jne    15d0 <botlish_fn_14+0x128>
    15ae:	mov    rdx,r15
    15b1:	mov    rsi,r14
    15b4:	mov    rdi,r13
    15b7:	call   15bc <botlish_fn_14+0x114>
			15b8: R_X86_64_PLT32	rt_list_get-0x4
    15bc:	test   rax,rax
    15bf:	je     162b <botlish_fn_14+0x183>
    15c5:	mov    rdx,rax
    15c8:	mov    rsi,r12
    15cb:	jmp    15dd <botlish_fn_14+0x135>
    15d0:	mov    rsi,r14
    15d3:	mov    rdx,QWORD PTR [rsi+0x10]
    15d7:	mov    rdx,QWORD PTR [rdx]
    15da:	mov    rsi,r12
    15dd:	mov    rdi,r13
    15e0:	call   15e5 <botlish_fn_14+0x13d>
			15e1: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_unreserved<generic>
    15e5:	test   rax,rax
    15e8:	je     162b <botlish_fn_14+0x183>
    15ee:	cmp    rax,0x6
    15f2:	je     1655 <botlish_fn_14+0x1ad>
    15f8:	mov    QWORD PTR [rsp+0x8],0x1
    1601:	mov    rdi,r13
    1604:	mov    r9,QWORD PTR [rdi+0x10]
    1608:	mov    rcx,QWORD PTR [r9+0xb0]
    160f:	mov    QWORD PTR [rsp+0x18],rcx
    1614:	mov    rdx,r15
    1617:	mov    rsi,r14
    161a:	mov    r8,rbx
    161d:	call   1622 <botlish_fn_14+0x17a>
			161e: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_bytes<generic>
    1622:	test   rax,rax
    1625:	jne    1650 <botlish_fn_14+0x1a8>
    162b:	xor    rax,rax
    162e:	mov    rbx,QWORD PTR [rsp+0x30]
    1633:	mov    r12,QWORD PTR [rsp+0x38]
    1638:	mov    r13,QWORD PTR [rsp+0x40]
    163d:	mov    r14,QWORD PTR [rsp+0x48]
    1642:	mov    r15,QWORD PTR [rsp+0x50]
    1647:	add    rsp,0x60
    164b:	mov    rsp,rbp
    164e:	pop    rbp
    164f:	ret
    1650:	mov    QWORD PTR [rsp+0x20],rax
    1655:	mov    rax,QWORD PTR [rsp+0x20]
    165a:	mov    rbx,QWORD PTR [rsp+0x30]
    165f:	mov    r12,QWORD PTR [rsp+0x38]
    1664:	mov    r13,QWORD PTR [rsp+0x40]
    1669:	mov    r14,QWORD PTR [rsp+0x48]
    166e:	mov    r15,QWORD PTR [rsp+0x50]
    1673:	add    rsp,0x60
    1677:	mov    rsp,rbp
    167a:	pop    rbp
    167b:	ret

000000000000167c <botlish_entry_14: esc_char<generic>>:
    167c:	push   rbp
    167d:	mov    rbp,rsp
    1680:	mov    rsi,QWORD PTR [rdx]
    1683:	mov    r8,QWORD PTR [rdx+0x8]
    1687:	mov    rcx,QWORD PTR [rdx+0x10]
    168b:	mov    rdx,r8
    168e:	call   1693 <botlish_entry_14+0x17>
			168f: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_char<generic>
    1693:	mov    rsp,rbp
    1696:	pop    rbp
    1697:	ret

0000000000001698 <botlish_fn_15: esc_from<generic>>:
    1698:	push   rbp
    1699:	mov    rbp,rsp
    169c:	sub    rsp,0x80
    16a3:	mov    QWORD PTR [rsp+0x50],rbx
    16a8:	mov    QWORD PTR [rsp+0x58],r12
    16ad:	mov    QWORD PTR [rsp+0x60],r13
    16b2:	mov    QWORD PTR [rsp+0x68],r14
    16b7:	mov    QWORD PTR [rsp+0x70],r15
    16bc:	mov    r14,rdi
    16bf:	mov    QWORD PTR [rsp+0x30],0x0
    16c8:	mov    QWORD PTR [rsp],rsi
    16cc:	mov    QWORD PTR [rsp+0x8],rdx
    16d1:	mov    QWORD PTR [rsp+0x10],rcx
    16d6:	mov    QWORD PTR [rsp+0x18],r8
    16db:	mov    r13,r8
    16de:	mov    QWORD PTR [rsp+0x20],r9
    16e3:	mov    r12,r9
    16e6:	mov    r15,rcx
    16e9:	mov    QWORD PTR [rsp+0x38],rdx
    16ee:	xor    eax,eax
    16f0:	test   rsi,0x7
    16f7:	jne    1706 <botlish_fn_15+0x6e>
    16fd:	movzx  rax,BYTE PTR [rsi]
    1701:	cmp    al,0x2
    1703:	sete   al
    1706:	test   al,al
    1708:	jne    172b <botlish_fn_15+0x93>
    170e:	mov    rdi,r14
    1711:	mov    rax,QWORD PTR [rdi+0x10]
    1715:	mov    rcx,QWORD PTR [rax+0xe8]
    171c:	mov    edx,0x1
    1721:	call   1726 <botlish_fn_15+0x8e>
			1722: R_X86_64_PLT32	rt_type_error-0x4
    1726:	jmp    1983 <botlish_fn_15+0x2eb>
    172b:	mov    rbx,rsi
    172e:	mov    rdi,r14
    1731:	call   1736 <botlish_fn_15+0x9e>
			1732: R_X86_64_PLT32	rt_str_len-0x4
    1736:	mov    edx,0x1
    173b:	mov    QWORD PTR [rsp+0x48],rdx
    1740:	mov    ecx,0x1
    1745:	mov    rsi,QWORD PTR [rsp+0x38]
    174a:	test   rsi,0x1
    1751:	jne    177b <botlish_fn_15+0xe3>
    1757:	xor    ecx,ecx
    1759:	mov    rsi,QWORD PTR [rsp+0x38]
    175e:	test   rsi,0x7
    1765:	jne    177b <botlish_fn_15+0xe3>
    176b:	mov    rsi,QWORD PTR [rsp+0x38]
    1770:	movzx  rcx,BYTE PTR [rsi]
    1774:	rex cmp cl,0x1
    1778:	sete   cl
    177b:	test   cl,cl
    177d:	jne    17a3 <botlish_fn_15+0x10b>
    1783:	mov    rdi,r14
    1786:	mov    rax,QWORD PTR [rdi+0x10]
    178a:	mov    rcx,QWORD PTR [rax+0xa8]
    1791:	xor    rdx,rdx
    1794:	mov    rsi,QWORD PTR [rsp+0x38]
    1799:	call   179e <botlish_fn_15+0x106>
			179a: R_X86_64_PLT32	rt_type_error-0x4
    179e:	jmp    1983 <botlish_fn_15+0x2eb>
    17a3:	mov    rsi,QWORD PTR [rsp+0x38]
    17a8:	mov    rcx,rsi
    17ab:	and    rcx,rax
    17ae:	mov    rdx,rax
    17b1:	test   rcx,0x1
    17b8:	jne    17e0 <botlish_fn_15+0x148>
    17be:	mov    rsi,QWORD PTR [rsp+0x38]
    17c3:	mov    rdi,r14
    17c6:	call   17cb <botlish_fn_15+0x133>
			17c7: R_X86_64_PLT32	rt_int_cmp-0x4
    17cb:	mov    ecx,0x2
    17d0:	test   rax,rax
    17d3:	cmovge rcx,QWORD PTR [rip+0x235]        # 1a10 <botlish_fn_15+0x378>
    17db:	jmp    17f5 <botlish_fn_15+0x15d>
    17e0:	mov    ecx,0x2
    17e5:	mov    rsi,QWORD PTR [rsp+0x38]
    17ea:	cmp    rsi,rdx
    17ed:	cmovge rcx,QWORD PTR [rip+0x21b]        # 1a10 <botlish_fn_15+0x378>
    17f5:	cmp    rcx,0x6
    17f9:	je     19e1 <botlish_fn_15+0x349>
    17ff:	mov    QWORD PTR [rsp+0x28],0x3
    1808:	mov    rsi,QWORD PTR [rsp+0x38]
    180d:	test   rsi,0x1
    1814:	je     1831 <botlish_fn_15+0x199>
    181a:	mov    rsi,QWORD PTR [rsp+0x38]
    181f:	mov    rax,rsi
    1822:	add    rax,0x2
    1826:	seto   cl
    1829:	test   cl,cl
    182b:	je     1843 <botlish_fn_15+0x1ab>
    1831:	mov    edx,0x3
    1836:	mov    rsi,QWORD PTR [rsp+0x38]
    183b:	mov    rdi,r14
    183e:	call   1843 <botlish_fn_15+0x1ab>
			183f: R_X86_64_PLT32	rt_int_add-0x4
    1843:	mov    QWORD PTR [rsp+0x28],rax
    1848:	mov    QWORD PTR [rsp+0x40],rax
    184d:	mov    QWORD PTR [rsp+0x30],0x3
    1856:	mov    rsi,QWORD PTR [rsp+0x38]
    185b:	test   rsi,0x1
    1862:	je     187f <botlish_fn_15+0x1e7>
    1868:	mov    rsi,QWORD PTR [rsp+0x38]
    186d:	mov    rcx,rsi
    1870:	add    rcx,0x2
    1874:	seto   al
    1877:	test   al,al
    1879:	je     1894 <botlish_fn_15+0x1fc>
    187f:	mov    edx,0x3
    1884:	mov    rsi,QWORD PTR [rsp+0x38]
    1889:	mov    rdi,r14
    188c:	call   1891 <botlish_fn_15+0x1f9>
			188d: R_X86_64_PLT32	rt_int_add-0x4
    1891:	mov    rcx,rax
    1894:	mov    QWORD PTR [rsp+0x30],rcx
    1899:	mov    rdx,QWORD PTR [rsp+0x38]
    189e:	mov    rsi,rbx
    18a1:	mov    rdi,r14
    18a4:	call   18a9 <botlish_fn_15+0x211>
			18a5: R_X86_64_PLT32	rt_substr-0x4
    18a9:	test   rax,rax
    18ac:	je     1983 <botlish_fn_15+0x2eb>
    18b2:	mov    QWORD PTR [rsp+0x8],rax
    18b7:	mov    r8,r12
    18ba:	mov    r12,r13
    18bd:	mov    r13,r8
    18c0:	mov    rsi,rax
    18c3:	mov    rcx,r13
    18c6:	mov    rdx,r12
    18c9:	mov    rdi,r14
    18cc:	call   18d1 <botlish_fn_15+0x239>
			18cd: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_char<generic>
    18d1:	test   rax,rax
    18d4:	je     1983 <botlish_fn_15+0x2eb>
    18da:	mov    QWORD PTR [rsp+0x8],rax
    18df:	xor    ecx,ecx
    18e1:	mov    rsi,r15
    18e4:	test   rsi,0x7
    18eb:	jne    18fc <botlish_fn_15+0x264>
    18f1:	movzx  rdi,BYTE PTR [rsi]
    18f5:	cmp    dil,0x2
    18f9:	sete   cl
    18fc:	test   cl,cl
    18fe:	jne    1921 <botlish_fn_15+0x289>
    1904:	mov    rdi,r14
    1907:	mov    r11,QWORD PTR [rdi+0x10]
    190b:	mov    rcx,QWORD PTR [r11+0xd8]
    1912:	mov    rdx,QWORD PTR [rsp+0x48]
    1917:	call   191c <botlish_fn_15+0x284>
			1918: R_X86_64_PLT32	rt_type_error-0x4
    191c:	jmp    1983 <botlish_fn_15+0x2eb>
    1921:	mov    rdx,QWORD PTR [rsp+0x48]
    1926:	xor    edi,edi
    1928:	test   rax,0x7
    192e:	je     193c <botlish_fn_15+0x2a4>
    1934:	mov    r8,rax
    1937:	jmp    194b <botlish_fn_15+0x2b3>
    193c:	movzx  rcx,BYTE PTR [rax]
    1940:	mov    r8,rax
    1943:	rex cmp cl,0x2
    1947:	sete   dil
    194b:	test   dil,dil
    194e:	jne    196f <botlish_fn_15+0x2d7>
    1954:	mov    rdi,r14
    1957:	mov    rax,QWORD PTR [rdi+0x10]
    195b:	mov    rcx,QWORD PTR [rax+0xd8]
    1962:	mov    rsi,r8
    1965:	call   196a <botlish_fn_15+0x2d2>
			1966: R_X86_64_PLT32	rt_type_error-0x4
    196a:	jmp    1983 <botlish_fn_15+0x2eb>
    196f:	mov    rdx,r8
    1972:	mov    rdi,r14
    1975:	call   197a <botlish_fn_15+0x2e2>
			1976: R_X86_64_PLT32	rt_str_cat-0x4
    197a:	test   rax,rax
    197d:	jne    19ab <botlish_fn_15+0x313>
    1983:	xor    rax,rax
    1986:	mov    rbx,QWORD PTR [rsp+0x50]
    198b:	mov    r12,QWORD PTR [rsp+0x58]
    1990:	mov    r13,QWORD PTR [rsp+0x60]
    1995:	mov    r14,QWORD PTR [rsp+0x68]
    199a:	mov    r15,QWORD PTR [rsp+0x70]
    199f:	add    rsp,0x80
    19a6:	mov    rsp,rbp
    19a9:	pop    rbp
    19aa:	ret
    19ab:	mov    QWORD PTR [rsp],rbx
    19af:	mov    rcx,QWORD PTR [rsp+0x40]
    19b4:	mov    QWORD PTR [rsp+0x8],rcx
    19b9:	mov    QWORD PTR [rsp+0x10],rax
    19be:	mov    QWORD PTR [rsp+0x18],r12
    19c3:	mov    QWORD PTR [rsp+0x20],r13
    19c8:	mov    QWORD PTR [rsp+0x38],rcx
    19cd:	mov    r15,rax
    19d0:	mov    rdx,r12
    19d3:	mov    r12,r13
    19d6:	mov    r13,rdx
    19d9:	mov    rsi,rbx
    19dc:	jmp    16ee <botlish_fn_15+0x56>
    19e1:	mov    rax,r15
    19e4:	mov    rbx,QWORD PTR [rsp+0x50]
    19e9:	mov    r12,QWORD PTR [rsp+0x58]
    19ee:	mov    r13,QWORD PTR [rsp+0x60]
    19f3:	mov    r14,QWORD PTR [rsp+0x68]
    19f8:	mov    r15,QWORD PTR [rsp+0x70]
    19fd:	add    rsp,0x80
    1a04:	mov    rsp,rbp
    1a07:	pop    rbp
    1a08:	ret
    1a09:	add    BYTE PTR [rax],al
    1a0b:	add    BYTE PTR [rax],al
    1a0d:	add    BYTE PTR [rax],al
    1a0f:	add    BYTE PTR [rsi],al
    1a11:	add    BYTE PTR [rax],al
    1a13:	add    BYTE PTR [rax],al
    1a15:	add    BYTE PTR [rax],al
	...

0000000000001a18 <botlish_entry_15: esc_from<generic>>:
    1a18:	push   rbp
    1a19:	mov    rbp,rsp
    1a1c:	mov    rsi,QWORD PTR [rdx]
    1a1f:	mov    r10,QWORD PTR [rdx+0x8]
    1a23:	mov    rcx,QWORD PTR [rdx+0x10]
    1a27:	mov    r8,QWORD PTR [rdx+0x18]
    1a2b:	mov    r9,QWORD PTR [rdx+0x20]
    1a2f:	mov    rdx,r10
    1a32:	call   1a37 <botlish_entry_15+0x1f>
			1a33: R_X86_64_PLT32	botlish_fn_15-0x4 ; esc_from<generic>
    1a37:	mov    rsp,rbp
    1a3a:	pop    rbp
    1a3b:	ret
    1a3c:	add    BYTE PTR [rax],al
	...

0000000000001a40 <botlish_fn_16: check<int, int, str, str>>:
    1a40:	push   rbp
    1a41:	mov    rbp,rsp
    1a44:	sub    rsp,0x60
    1a48:	mov    QWORD PTR [rsp+0x30],rbx
    1a4d:	mov    QWORD PTR [rsp+0x38],r12
    1a52:	mov    QWORD PTR [rsp+0x40],r13
    1a57:	mov    QWORD PTR [rsp+0x48],r14
    1a5c:	mov    QWORD PTR [rsp+0x50],r15
    1a61:	mov    QWORD PTR [rsp+0x20],0x0
    1a6a:	mov    QWORD PTR [rsp],rsi
    1a6e:	mov    QWORD PTR [rsp+0x8],rdx
    1a73:	mov    QWORD PTR [rsp+0x10],rcx
    1a78:	mov    r12,rcx
    1a7b:	mov    QWORD PTR [rsp+0x18],r8
    1a80:	mov    r14,r8
    1a83:	mov    r13,rsi
    1a86:	mov    r15,rdx
    1a89:	test   r13,0x1
    1a90:	jne    1abb <botlish_fn_16+0x7b>
    1a96:	mov    edx,0x1
    1a9b:	mov    rbx,rdi
    1a9e:	mov    rsi,r13
    1aa1:	call   1aa6 <botlish_fn_16+0x66>
			1aa2: R_X86_64_PLT32	rt_int_cmp-0x4
    1aa6:	mov    ecx,0x2
    1aab:	test   rax,rax
    1aae:	cmovle rcx,QWORD PTR [rip+0x152]        # 1c08 <botlish_fn_16+0x1c8>
    1ab6:	jmp    1acf <botlish_fn_16+0x8f>
    1abb:	mov    rbx,rdi
    1abe:	mov    ecx,0x2
    1ac3:	cmp    r13,0x1
    1ac7:	cmovle rcx,QWORD PTR [rip+0x139]        # 1c08 <botlish_fn_16+0x1c8>
    1acf:	cmp    rcx,0x6
    1ad3:	je     1bdc <botlish_fn_16+0x19c>
    1ad9:	mov    rax,QWORD PTR [rbx+0x10]
    1add:	mov    rax,QWORD PTR [rax+0xf0]
    1ae4:	mov    rsi,r12
    1ae7:	mov    rdi,rbx
    1aea:	call   1aef <botlish_fn_16+0xaf>
			1aeb: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    1aef:	test   rax,rax
    1af2:	je     1b33 <botlish_fn_16+0xf3>
    1af8:	cmp    rax,0x6
    1afc:	je     1b14 <botlish_fn_16+0xd4>
    1b02:	mov    edx,0x1
    1b07:	mov    QWORD PTR [rsp],0x1
    1b0f:	jmp    1b75 <botlish_fn_16+0x135>
    1b14:	mov    rax,QWORD PTR [rbx+0x10]
    1b18:	mov    rax,QWORD PTR [rax+0xf8]
    1b1f:	mov    rsi,r12
    1b22:	mov    rdi,rbx
    1b25:	call   1b2a <botlish_fn_16+0xea>
			1b26: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    1b2a:	test   rax,rax
    1b2d:	jne    1b58 <botlish_fn_16+0x118>
    1b33:	xor    rax,rax
    1b36:	mov    rbx,QWORD PTR [rsp+0x30]
    1b3b:	mov    r12,QWORD PTR [rsp+0x38]
    1b40:	mov    r13,QWORD PTR [rsp+0x40]
    1b45:	mov    r14,QWORD PTR [rsp+0x48]
    1b4a:	mov    r15,QWORD PTR [rsp+0x50]
    1b4f:	add    rsp,0x60
    1b53:	mov    rsp,rbp
    1b56:	pop    rbp
    1b57:	ret
    1b58:	cmp    rax,0x6
    1b5c:	je     1b6c <botlish_fn_16+0x12c>
    1b62:	mov    edx,0x1
    1b67:	jmp    1b71 <botlish_fn_16+0x131>
    1b6c:	mov    edx,0x3
    1b71:	mov    QWORD PTR [rsp],rdx
    1b75:	sar    r13,1
    1b78:	sub    r13,0x1
    1b7c:	shl    r13,1
    1b7f:	or     r13,0x1
    1b83:	mov    QWORD PTR [rsp+0x20],r13
    1b88:	mov    rsi,r15
    1b8b:	mov    r8,rsi
    1b8e:	and    r8,rdx
    1b91:	test   r8,0x1
    1b98:	je     1bb3 <botlish_fn_16+0x173>
    1b9e:	lea    r11,[rdx-0x1]
    1ba2:	mov    rax,rsi
    1ba5:	add    rax,r11
    1ba8:	seto   cl
    1bab:	test   cl,cl
    1bad:	je     1bbb <botlish_fn_16+0x17b>
    1bb3:	mov    rdi,rbx
    1bb6:	call   1bbb <botlish_fn_16+0x17b>
			1bb7: R_X86_64_PLT32	rt_int_add-0x4
    1bbb:	mov    QWORD PTR [rsp],r13
    1bbf:	mov    QWORD PTR [rsp+0x8],rax
    1bc4:	mov    QWORD PTR [rsp+0x10],r12
    1bc9:	mov    r8,r14
    1bcc:	mov    QWORD PTR [rsp+0x18],r8
    1bd1:	mov    rdi,rbx
    1bd4:	mov    r15,rax
    1bd7:	jmp    1a89 <botlish_fn_16+0x49>
    1bdc:	mov    rax,r15
    1bdf:	mov    rbx,QWORD PTR [rsp+0x30]
    1be4:	mov    r12,QWORD PTR [rsp+0x38]
    1be9:	mov    r13,QWORD PTR [rsp+0x40]
    1bee:	mov    r14,QWORD PTR [rsp+0x48]
    1bf3:	mov    r15,QWORD PTR [rsp+0x50]
    1bf8:	add    rsp,0x60
    1bfc:	mov    rsp,rbp
    1bff:	pop    rbp
    1c00:	ret
    1c01:	add    BYTE PTR [rax],al
    1c03:	add    BYTE PTR [rax],al
    1c05:	add    BYTE PTR [rax],al
    1c07:	add    BYTE PTR [rsi],al
    1c09:	add    BYTE PTR [rax],al
    1c0b:	add    BYTE PTR [rax],al
    1c0d:	add    BYTE PTR [rax],al
	...

0000000000001c10 <botlish_entry_16: check<int, int, str, str>>:
    1c10:	push   rbp
    1c11:	mov    rbp,rsp
    1c14:	mov    rsi,QWORD PTR [rdx]
    1c17:	mov    r9,QWORD PTR [rdx+0x8]
    1c1b:	mov    rcx,QWORD PTR [rdx+0x10]
    1c1f:	mov    r8,QWORD PTR [rdx+0x18]
    1c23:	mov    rdx,r9
    1c26:	call   1c2b <botlish_entry_16+0x1b>
			1c27: R_X86_64_PLT32	botlish_fn_16-0x4 ; check<int, int, str, str>
    1c2b:	mov    rsp,rbp
    1c2e:	pop    rbp
    1c2f:	ret

0000000000001c30 <botlish_fn_17: <str>>:
    1c30:	push   rbp
    1c31:	mov    rbp,rsp
    1c34:	sub    rsp,0x50
    1c38:	mov    QWORD PTR [rsp+0x30],rbx
    1c3d:	mov    QWORD PTR [rsp+0x38],r12
    1c42:	mov    QWORD PTR [rsp+0x40],r13
    1c47:	mov    QWORD PTR [rsp+0x48],r14
    1c4c:	mov    r13,rdi
    1c4f:	mov    QWORD PTR [rsp+0x18],0x0
    1c58:	mov    QWORD PTR [rsp],rsi
    1c5c:	mov    r14,rsi
    1c5f:	mov    rsi,r14
    1c62:	mov    rdi,r13
    1c65:	call   1c6a <botlish_fn_17+0x3a>
			1c66: R_X86_64_PLT32	rt_str_len-0x4
    1c6a:	mov    rbx,rax
    1c6d:	mov    QWORD PTR [rsp+0x8],rax
    1c72:	mov    esi,0x1
    1c77:	mov    QWORD PTR [rsp+0x10],0x1
    1c80:	mov    rcx,r14
    1c83:	mov    rdx,rbx
    1c86:	mov    rdi,r13
    1c89:	call   1c8e <botlish_fn_17+0x5e>
			1c8a: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    1c8e:	mov    r12,rax
    1c91:	test   r12,r12
    1c94:	je     1df1 <botlish_fn_17+0x1c1>
    1c9a:	mov    QWORD PTR [rsp+0x10],r12
    1c9f:	test   r12,0x1
    1ca6:	jne    1cd1 <botlish_fn_17+0xa1>
    1cac:	mov    edx,0x1
    1cb1:	mov    rsi,r12
    1cb4:	mov    rdi,r13
    1cb7:	call   1cbc <botlish_fn_17+0x8c>
			1cb8: R_X86_64_PLT32	rt_int_cmp-0x4
    1cbc:	mov    ecx,0x2
    1cc1:	test   rax,rax
    1cc4:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 1e90 <botlish_fn_17+0x260>
    1ccc:	jmp    1ce2 <botlish_fn_17+0xb2>
    1cd1:	mov    ecx,0x2
    1cd6:	cmp    r12,0x1
    1cda:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 1e90 <botlish_fn_17+0x260>
    1ce2:	cmp    rcx,0x6
    1ce6:	je     1e6c <botlish_fn_17+0x23c>
    1cec:	mov    rcx,r12
    1cef:	and    rcx,rbx
    1cf2:	test   rcx,0x1
    1cf9:	jne    1d22 <botlish_fn_17+0xf2>
    1cff:	mov    rdx,rbx
    1d02:	mov    rsi,r12
    1d05:	mov    rdi,r13
    1d08:	call   1d0d <botlish_fn_17+0xdd>
			1d09: R_X86_64_PLT32	rt_int_cmp-0x4
    1d0d:	mov    ecx,0x2
    1d12:	test   rax,rax
    1d15:	cmovge rcx,QWORD PTR [rip+0x173]        # 1e90 <botlish_fn_17+0x260>
    1d1d:	jmp    1d32 <botlish_fn_17+0x102>
    1d22:	mov    ecx,0x2
    1d27:	cmp    r12,rbx
    1d2a:	cmovge rcx,QWORD PTR [rip+0x15e]        # 1e90 <botlish_fn_17+0x260>
    1d32:	cmp    rcx,0x6
    1d36:	je     1e62 <botlish_fn_17+0x232>
    1d3c:	lea    rcx,[rsp+0x20]
    1d41:	mov    rdx,r14
    1d44:	mov    rsi,r12
    1d47:	mov    rdi,r13
    1d4a:	call   1d4f <botlish_fn_17+0x11f>
			1d4b: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    1d4f:	test   rax,rax
    1d52:	mov    rsi,rax
    1d55:	je     1df1 <botlish_fn_17+0x1c1>
    1d5b:	mov    rdx,QWORD PTR [rsp+0x20]
    1d60:	mov    rcx,QWORD PTR [rsp+0x28]
    1d65:	mov    rdi,r13
    1d68:	mov    rax,QWORD PTR [rdi+0x10]
    1d6c:	mov    r8,QWORD PTR [rax+0x110]
    1d73:	call   1d78 <botlish_fn_17+0x148>
			1d74: R_X86_64_PLT32	rt_str_region_eq-0x4
    1d78:	cmp    rax,0x6
    1d7c:	je     1d8f <botlish_fn_17+0x15f>
    1d82:	mov    ecx,0x2
    1d87:	mov    rax,rcx
    1d8a:	jmp    1e71 <botlish_fn_17+0x241>
    1d8f:	mov    QWORD PTR [rsp+0x18],0x3
    1d98:	test   r12,0x1
    1d9f:	jne    1dad <botlish_fn_17+0x17d>
    1da5:	mov    rcx,r12
    1da8:	jmp    1dc2 <botlish_fn_17+0x192>
    1dad:	mov    rsi,r12
    1db0:	add    rsi,0x2
    1db4:	mov    rcx,r12
    1db7:	seto   al
    1dba:	test   al,al
    1dbc:	je     1dd5 <botlish_fn_17+0x1a5>
    1dc2:	mov    edx,0x3
    1dc7:	mov    rsi,rcx
    1dca:	mov    rdi,r13
    1dcd:	call   1dd2 <botlish_fn_17+0x1a2>
			1dce: R_X86_64_PLT32	rt_int_add-0x4
    1dd2:	mov    rsi,rax
    1dd5:	mov    QWORD PTR [rsp+0x10],rsi
    1dda:	mov    rcx,r14
    1ddd:	mov    rdx,rbx
    1de0:	mov    rdi,r13
    1de3:	call   1de8 <botlish_fn_17+0x1b8>
			1de4: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    1de8:	test   rax,rax
    1deb:	jne    1e11 <botlish_fn_17+0x1e1>
    1df1:	xor    rax,rax
    1df4:	mov    rbx,QWORD PTR [rsp+0x30]
    1df9:	mov    r12,QWORD PTR [rsp+0x38]
    1dfe:	mov    r13,QWORD PTR [rsp+0x40]
    1e03:	mov    r14,QWORD PTR [rsp+0x48]
    1e08:	add    rsp,0x50
    1e0c:	mov    rsp,rbp
    1e0f:	pop    rbp
    1e10:	ret
    1e11:	mov    rcx,rax
    1e14:	and    rcx,rbx
    1e17:	mov    rsi,rax
    1e1a:	test   rcx,0x1
    1e21:	jne    1e4a <botlish_fn_17+0x21a>
    1e27:	mov    rdx,rbx
    1e2a:	mov    rdi,r13
    1e2d:	call   1e32 <botlish_fn_17+0x202>
			1e2e: R_X86_64_PLT32	rt_int_cmp-0x4
    1e32:	mov    ecx,0x2
    1e37:	test   rax,rax
    1e3a:	mov    rax,rcx
    1e3d:	cmove  rax,QWORD PTR [rip+0x4b]        # 1e90 <botlish_fn_17+0x260>
    1e45:	jmp    1e71 <botlish_fn_17+0x241>
    1e4a:	mov    rdx,rbx
    1e4d:	mov    eax,0x2
    1e52:	cmp    rsi,rdx
    1e55:	cmove  rax,QWORD PTR [rip+0x33]        # 1e90 <botlish_fn_17+0x260>
    1e5d:	jmp    1e71 <botlish_fn_17+0x241>
    1e62:	mov    eax,0x2
    1e67:	jmp    1e71 <botlish_fn_17+0x241>
    1e6c:	mov    eax,0x2
    1e71:	mov    rbx,QWORD PTR [rsp+0x30]
    1e76:	mov    r12,QWORD PTR [rsp+0x38]
    1e7b:	mov    r13,QWORD PTR [rsp+0x40]
    1e80:	mov    r14,QWORD PTR [rsp+0x48]
    1e85:	add    rsp,0x50
    1e89:	mov    rsp,rbp
    1e8c:	pop    rbp
    1e8d:	ret
    1e8e:	add    BYTE PTR [rax],al
    1e90:	(bad)
    1e91:	add    BYTE PTR [rax],al
    1e93:	add    BYTE PTR [rax],al
    1e95:	add    BYTE PTR [rax],al
	...

0000000000001e98 <botlish_entry_17: <str>>:
    1e98:	push   rbp
    1e99:	mov    rbp,rsp
    1e9c:	mov    rsi,QWORD PTR [rdx]
    1e9f:	call   1ea4 <botlish_entry_17+0xc>
			1ea0: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    1ea4:	mov    rsp,rbp
    1ea7:	pop    rbp
    1ea8:	ret
    1ea9:	add    BYTE PTR [rax],al
    1eab:	add    BYTE PTR [rax],al
    1ead:	add    BYTE PTR [rax],al
	...

0000000000001eb0 <botlish_fn_18: <generic>>:
    1eb0:	push   rbp
    1eb1:	mov    rbp,rsp
    1eb4:	sub    rsp,0x60
    1eb8:	mov    QWORD PTR [rsp+0x30],rbx
    1ebd:	mov    QWORD PTR [rsp+0x38],r12
    1ec2:	mov    QWORD PTR [rsp+0x40],r13
    1ec7:	mov    QWORD PTR [rsp+0x48],r14
    1ecc:	mov    QWORD PTR [rsp+0x50],r15
    1ed1:	mov    QWORD PTR [rsp+0x18],0x0
    1eda:	mov    QWORD PTR [rsp],rsi
    1ede:	xor    r8d,r8d
    1ee1:	test   rsi,0x7
    1ee8:	jne    1ef8 <botlish_fn_18+0x48>
    1eee:	movzx  rax,BYTE PTR [rsi]
    1ef2:	cmp    al,0x2
    1ef4:	sete   r8b
    1ef8:	test   r8b,r8b
    1efb:	jne    1f1b <botlish_fn_18+0x6b>
    1f01:	mov    rdx,QWORD PTR [rdi+0x10]
    1f05:	mov    rcx,QWORD PTR [rdx+0xe8]
    1f0c:	mov    edx,0x1
    1f11:	call   1f16 <botlish_fn_18+0x66>
			1f12: R_X86_64_PLT32	rt_type_error-0x4
    1f16:	jmp    20b0 <botlish_fn_18+0x200>
    1f1b:	mov    r13,rsi
    1f1e:	mov    r14,rdi
    1f21:	call   1f26 <botlish_fn_18+0x76>
			1f22: R_X86_64_PLT32	rt_str_len-0x4
    1f26:	mov    rbx,rax
    1f29:	mov    QWORD PTR [rsp+0x8],rax
    1f2e:	mov    edx,0x1
    1f33:	mov    r15,rdx
    1f36:	mov    QWORD PTR [rsp+0x10],0x1
    1f3f:	mov    rcx,r13
    1f42:	mov    rdx,rbx
    1f45:	mov    rsi,r15
    1f48:	mov    rdi,r14
    1f4b:	call   1f50 <botlish_fn_18+0xa0>
			1f4c: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    1f50:	mov    r12,rax
    1f53:	test   r12,r12
    1f56:	je     20b0 <botlish_fn_18+0x200>
    1f5c:	mov    QWORD PTR [rsp+0x10],r12
    1f61:	test   r12,0x1
    1f68:	jne    1f91 <botlish_fn_18+0xe1>
    1f6e:	mov    rdx,r15
    1f71:	mov    rsi,r12
    1f74:	mov    rdi,r14
    1f77:	call   1f7c <botlish_fn_18+0xcc>
			1f78: R_X86_64_PLT32	rt_int_cmp-0x4
    1f7c:	mov    ecx,0x2
    1f81:	test   rax,rax
    1f84:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 2158 <botlish_fn_18+0x2a8>
    1f8c:	jmp    1fa2 <botlish_fn_18+0xf2>
    1f91:	mov    ecx,0x2
    1f96:	cmp    r12,0x1
    1f9a:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 2158 <botlish_fn_18+0x2a8>
    1fa2:	cmp    rcx,0x6
    1fa6:	je     2130 <botlish_fn_18+0x280>
    1fac:	mov    rax,r12
    1faf:	and    rax,rbx
    1fb2:	test   rax,0x1
    1fb8:	jne    1fe1 <botlish_fn_18+0x131>
    1fbe:	mov    rdx,rbx
    1fc1:	mov    rsi,r12
    1fc4:	mov    rdi,r14
    1fc7:	call   1fcc <botlish_fn_18+0x11c>
			1fc8: R_X86_64_PLT32	rt_int_cmp-0x4
    1fcc:	mov    ecx,0x2
    1fd1:	test   rax,rax
    1fd4:	cmovge rcx,QWORD PTR [rip+0x17c]        # 2158 <botlish_fn_18+0x2a8>
    1fdc:	jmp    1ff1 <botlish_fn_18+0x141>
    1fe1:	mov    ecx,0x2
    1fe6:	cmp    r12,rbx
    1fe9:	cmovge rcx,QWORD PTR [rip+0x167]        # 2158 <botlish_fn_18+0x2a8>
    1ff1:	cmp    rcx,0x6
    1ff5:	je     2126 <botlish_fn_18+0x276>
    1ffb:	lea    rcx,[rsp+0x20]
    2000:	mov    rdx,r13
    2003:	mov    rsi,r12
    2006:	mov    rdi,r14
    2009:	call   200e <botlish_fn_18+0x15e>
			200a: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    200e:	test   rax,rax
    2011:	mov    rsi,rax
    2014:	je     20b0 <botlish_fn_18+0x200>
    201a:	mov    rdx,QWORD PTR [rsp+0x20]
    201f:	mov    rcx,QWORD PTR [rsp+0x28]
    2024:	mov    rdi,r14
    2027:	mov    rax,QWORD PTR [rdi+0x10]
    202b:	mov    r8,QWORD PTR [rax+0x110]
    2032:	call   2037 <botlish_fn_18+0x187>
			2033: R_X86_64_PLT32	rt_str_region_eq-0x4
    2037:	cmp    rax,0x6
    203b:	je     204e <botlish_fn_18+0x19e>
    2041:	mov    ecx,0x2
    2046:	mov    rax,rcx
    2049:	jmp    2135 <botlish_fn_18+0x285>
    204e:	mov    QWORD PTR [rsp+0x18],0x3
    2057:	test   r12,0x1
    205e:	jne    206c <botlish_fn_18+0x1bc>
    2064:	mov    rdi,r12
    2067:	jmp    2081 <botlish_fn_18+0x1d1>
    206c:	mov    rsi,r12
    206f:	add    rsi,0x2
    2073:	mov    rdi,r12
    2076:	seto   al
    2079:	test   al,al
    207b:	je     2094 <botlish_fn_18+0x1e4>
    2081:	mov    edx,0x3
    2086:	mov    rsi,rdi
    2089:	mov    rdi,r14
    208c:	call   2091 <botlish_fn_18+0x1e1>
			208d: R_X86_64_PLT32	rt_int_add-0x4
    2091:	mov    rsi,rax
    2094:	mov    QWORD PTR [rsp+0x10],rsi
    2099:	mov    rcx,r13
    209c:	mov    rdx,rbx
    209f:	mov    rdi,r14
    20a2:	call   20a7 <botlish_fn_18+0x1f7>
			20a3: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    20a7:	test   rax,rax
    20aa:	jne    20d5 <botlish_fn_18+0x225>
    20b0:	xor    rax,rax
    20b3:	mov    rbx,QWORD PTR [rsp+0x30]
    20b8:	mov    r12,QWORD PTR [rsp+0x38]
    20bd:	mov    r13,QWORD PTR [rsp+0x40]
    20c2:	mov    r14,QWORD PTR [rsp+0x48]
    20c7:	mov    r15,QWORD PTR [rsp+0x50]
    20cc:	add    rsp,0x60
    20d0:	mov    rsp,rbp
    20d3:	pop    rbp
    20d4:	ret
    20d5:	mov    rcx,rax
    20d8:	and    rcx,rbx
    20db:	mov    rsi,rax
    20de:	test   rcx,0x1
    20e5:	jne    210e <botlish_fn_18+0x25e>
    20eb:	mov    rdx,rbx
    20ee:	mov    rdi,r14
    20f1:	call   20f6 <botlish_fn_18+0x246>
			20f2: R_X86_64_PLT32	rt_int_cmp-0x4
    20f6:	mov    ecx,0x2
    20fb:	test   rax,rax
    20fe:	mov    rax,rcx
    2101:	cmove  rax,QWORD PTR [rip+0x4f]        # 2158 <botlish_fn_18+0x2a8>
    2109:	jmp    2135 <botlish_fn_18+0x285>
    210e:	mov    rdx,rbx
    2111:	mov    eax,0x2
    2116:	cmp    rsi,rdx
    2119:	cmove  rax,QWORD PTR [rip+0x37]        # 2158 <botlish_fn_18+0x2a8>
    2121:	jmp    2135 <botlish_fn_18+0x285>
    2126:	mov    eax,0x2
    212b:	jmp    2135 <botlish_fn_18+0x285>
    2130:	mov    eax,0x2
    2135:	mov    rbx,QWORD PTR [rsp+0x30]
    213a:	mov    r12,QWORD PTR [rsp+0x38]
    213f:	mov    r13,QWORD PTR [rsp+0x40]
    2144:	mov    r14,QWORD PTR [rsp+0x48]
    2149:	mov    r15,QWORD PTR [rsp+0x50]
    214e:	add    rsp,0x60
    2152:	mov    rsp,rbp
    2155:	pop    rbp
    2156:	ret
    2157:	add    BYTE PTR [rsi],al
    2159:	add    BYTE PTR [rax],al
    215b:	add    BYTE PTR [rax],al
    215d:	add    BYTE PTR [rax],al
	...

0000000000002160 <botlish_entry_18: <generic>>:
    2160:	push   rbp
    2161:	mov    rbp,rsp
    2164:	mov    rsi,QWORD PTR [rdx]
    2167:	call   216c <botlish_entry_18+0xc>
			2168: R_X86_64_PLT32	botlish_fn_18-0x4 ; <generic>
    216c:	mov    rsp,rbp
    216f:	pop    rbp
    2170:	ret

0000000000002171 <botlish_fn_19: char_at<generic>>:
    2171:	push   rbp
    2172:	mov    rbp,rsp
    2175:	sub    rsp,0x50
    2179:	mov    QWORD PTR [rsp+0x20],rbx
    217e:	mov    QWORD PTR [rsp+0x28],r12
    2183:	mov    QWORD PTR [rsp+0x30],r13
    2188:	mov    QWORD PTR [rsp+0x38],r14
    218d:	mov    QWORD PTR [rsp+0x40],r15
    2192:	mov    r14,rcx
    2195:	mov    QWORD PTR [rsp],rsi
    2199:	mov    QWORD PTR [rsp+0x8],rdx
    219e:	mov    r13,rdx
    21a1:	mov    QWORD PTR [rsp+0x10],0x3
    21aa:	mov    r9d,0x1
    21b0:	test   rsi,0x1
    21b7:	jne    21d7 <botlish_fn_19+0x66>
    21bd:	xor    r9d,r9d
    21c0:	test   rsi,0x7
    21c7:	jne    21d7 <botlish_fn_19+0x66>
    21cd:	movzx  rax,BYTE PTR [rsi]
    21d1:	cmp    al,0x1
    21d3:	sete   r9b
    21d7:	test   r9b,r9b
    21da:	jne    21f8 <botlish_fn_19+0x87>
    21e0:	mov    rax,QWORD PTR [rdi+0x10]
    21e4:	mov    rcx,QWORD PTR [rax+0x118]
    21eb:	xor    rdx,rdx
    21ee:	call   21f3 <botlish_fn_19+0x82>
			21ef: R_X86_64_PLT32	rt_type_error-0x4
    21f3:	jmp    22b5 <botlish_fn_19+0x144>
    21f8:	mov    r12,rdi
    21fb:	test   rsi,0x1
    2202:	jne    2210 <botlish_fn_19+0x9f>
    2208:	mov    rbx,rsi
    220b:	jmp    222d <botlish_fn_19+0xbc>
    2210:	mov    rax,rsi
    2213:	add    rax,0x2
    2217:	mov    rbx,rsi
    221a:	seto   cl
    221d:	test   cl,cl
    221f:	jne    222d <botlish_fn_19+0xbc>
    2225:	mov    r15,rax
    2228:	jmp    2240 <botlish_fn_19+0xcf>
    222d:	mov    edx,0x3
    2232:	mov    rsi,rbx
    2235:	mov    rdi,r12
    2238:	call   223d <botlish_fn_19+0xcc>
			2239: R_X86_64_PLT32	rt_int_add-0x4
    223d:	mov    r15,rax
    2240:	mov    ecx,0x1
    2245:	mov    rsi,rbx
    2248:	test   rsi,0x1
    224f:	jne    2275 <botlish_fn_19+0x104>
    2255:	xor    ecx,ecx
    2257:	mov    rsi,rbx
    225a:	test   rsi,0x7
    2261:	jne    2275 <botlish_fn_19+0x104>
    2267:	mov    rsi,rbx
    226a:	movzx  rcx,BYTE PTR [rsi]
    226e:	rex cmp cl,0x1
    2272:	sete   cl
    2275:	test   cl,cl
    2277:	jne    229b <botlish_fn_19+0x12a>
    227d:	mov    rdi,r12
    2280:	mov    rsi,QWORD PTR [rdi+0x10]
    2284:	mov    rcx,QWORD PTR [rsi+0x120]
    228b:	xor    rdx,rdx
    228e:	mov    rsi,rbx
    2291:	call   2296 <botlish_fn_19+0x125>
			2292: R_X86_64_PLT32	rt_type_error-0x4
    2296:	jmp    22b5 <botlish_fn_19+0x144>
    229b:	mov    rdi,r12
    229e:	mov    rcx,r15
    22a1:	mov    rdx,rbx
    22a4:	mov    rsi,r13
    22a7:	call   22ac <botlish_fn_19+0x13b>
			22a8: R_X86_64_PLT32	rt_str_region_check-0x4
    22ac:	test   rax,rax
    22af:	jne    22da <botlish_fn_19+0x169>
    22b5:	xor    rax,rax
    22b8:	mov    rbx,QWORD PTR [rsp+0x20]
    22bd:	mov    r12,QWORD PTR [rsp+0x28]
    22c2:	mov    r13,QWORD PTR [rsp+0x30]
    22c7:	mov    r14,QWORD PTR [rsp+0x38]
    22cc:	mov    r15,QWORD PTR [rsp+0x40]
    22d1:	add    rsp,0x50
    22d5:	mov    rsp,rbp
    22d8:	pop    rbp
    22d9:	ret
    22da:	mov    rcx,r14
    22dd:	mov    rsi,rbx
    22e0:	mov    QWORD PTR [rcx],rsi
    22e3:	mov    rax,r15
    22e6:	mov    QWORD PTR [rcx+0x8],rax
    22ea:	mov    rax,r13
    22ed:	mov    rbx,QWORD PTR [rsp+0x20]
    22f2:	mov    r12,QWORD PTR [rsp+0x28]
    22f7:	mov    r13,QWORD PTR [rsp+0x30]
    22fc:	mov    r14,QWORD PTR [rsp+0x38]
    2301:	mov    r15,QWORD PTR [rsp+0x40]
    2306:	add    rsp,0x50
    230a:	mov    rsp,rbp
    230d:	pop    rbp
    230e:	ret

000000000000230f <botlish_entry_19: char_at<generic>>:
    230f:	push   rbp
    2310:	mov    rbp,rsp
    2313:	ud2
    2315:	add    BYTE PTR [rax],al
	...

0000000000002318 <botlish_fn_20: scan_local<generic>>:
    2318:	push   rbp
    2319:	mov    rbp,rsp
    231c:	sub    rsp,0x80
    2323:	mov    QWORD PTR [rsp+0x50],rbx
    2328:	mov    QWORD PTR [rsp+0x58],r12
    232d:	mov    QWORD PTR [rsp+0x60],r13
    2332:	mov    QWORD PTR [rsp+0x68],r14
    2337:	mov    QWORD PTR [rsp+0x70],r15
    233c:	mov    rax,rdi
    233f:	mov    QWORD PTR [rsp+0x18],0x0
    2348:	mov    QWORD PTR [rsp],rsi
    234c:	mov    r14,rsi
    234f:	mov    QWORD PTR [rsp+0x8],rdx
    2354:	mov    QWORD PTR [rsp+0x10],rcx
    2359:	mov    r12,rcx
    235c:	mov    r11d,0x1
    2362:	mov    rsi,r14
    2365:	test   rsi,0x1
    236c:	jne    238e <botlish_fn_20+0x76>
    2372:	xor    r11d,r11d
    2375:	test   rsi,0x7
    237c:	jne    238e <botlish_fn_20+0x76>
    2382:	movzx  rdi,BYTE PTR [rsi]
    2386:	cmp    dil,0x1
    238a:	sete   r11b
    238e:	test   r11b,r11b
    2391:	jne    23b2 <botlish_fn_20+0x9a>
    2397:	mov    rdi,rax
    239a:	mov    r9,QWORD PTR [rdi+0x10]
    239e:	mov    rcx,QWORD PTR [r9+0xa8]
    23a5:	xor    rdx,rdx
    23a8:	call   23ad <botlish_fn_20+0x95>
			23a9: R_X86_64_PLT32	rt_type_error-0x4
    23ad:	jmp    2465 <botlish_fn_20+0x14d>
    23b2:	mov    r13,rdx
    23b5:	mov    r10,rsi
    23b8:	and    r10,r13
    23bb:	mov    r14,rsi
    23be:	test   r10,0x1
    23c5:	jne    23f1 <botlish_fn_20+0xd9>
    23cb:	mov    rbx,rax
    23ce:	mov    rdx,r13
    23d1:	mov    rsi,r14
    23d4:	mov    rdi,rbx
    23d7:	call   23dc <botlish_fn_20+0xc4>
			23d8: R_X86_64_PLT32	rt_int_cmp-0x4
    23dc:	mov    ecx,0x2
    23e1:	test   rax,rax
    23e4:	cmovge rcx,QWORD PTR [rip+0x24c]        # 2638 <botlish_fn_20+0x320>
    23ec:	jmp    2407 <botlish_fn_20+0xef>
    23f1:	mov    rbx,rax
    23f4:	mov    ecx,0x2
    23f9:	mov    rsi,r14
    23fc:	cmp    rsi,r13
    23ff:	cmovge rcx,QWORD PTR [rip+0x231]        # 2638 <botlish_fn_20+0x320>
    2407:	mov    eax,0x6
    240c:	mov    QWORD PTR [rsp+0x30],rax
    2411:	cmp    rcx,0x6
    2415:	je     260b <botlish_fn_20+0x2f3>
    241b:	lea    rcx,[rsp+0x20]
    2420:	mov    rdx,r12
    2423:	mov    rsi,r14
    2426:	mov    rdi,rbx
    2429:	call   242e <botlish_fn_20+0x116>
			242a: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    242e:	mov    rsi,rax
    2431:	mov    r15,rax
    2434:	test   rax,rsi
    2437:	je     2465 <botlish_fn_20+0x14d>
    243d:	mov    rdx,QWORD PTR [rsp+0x20]
    2442:	mov    QWORD PTR [rsp+0x40],rdx
    2447:	mov    rcx,QWORD PTR [rsp+0x28]
    244c:	mov    QWORD PTR [rsp+0x38],rcx
    2451:	mov    rsi,r15
    2454:	mov    rdi,rbx
    2457:	call   245c <botlish_fn_20+0x144>
			2458: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    245c:	test   rax,rax
    245f:	jne    248d <botlish_fn_20+0x175>
    2465:	xor    rax,rax
    2468:	mov    rbx,QWORD PTR [rsp+0x50]
    246d:	mov    r12,QWORD PTR [rsp+0x58]
    2472:	mov    r13,QWORD PTR [rsp+0x60]
    2477:	mov    r14,QWORD PTR [rsp+0x68]
    247c:	mov    r15,QWORD PTR [rsp+0x70]
    2481:	add    rsp,0x80
    2488:	mov    rsp,rbp
    248b:	pop    rbp
    248c:	ret
    248d:	cmp    rax,0x6
    2491:	je     258c <botlish_fn_20+0x274>
    2497:	mov    rax,QWORD PTR [rbx+0x10]
    249b:	mov    r8,QWORD PTR [rax+0x128]
    24a2:	mov    rcx,QWORD PTR [rsp+0x38]
    24a7:	mov    rdx,QWORD PTR [rsp+0x40]
    24ac:	mov    rsi,r15
    24af:	mov    rdi,rbx
    24b2:	call   24b7 <botlish_fn_20+0x19f>
			24b3: R_X86_64_PLT32	rt_str_region_eq-0x4
    24b7:	cmp    rax,0x6
    24bb:	je     2582 <botlish_fn_20+0x26a>
    24c1:	mov    rax,QWORD PTR [rbx+0x10]
    24c5:	mov    r8,QWORD PTR [rax+0x130]
    24cc:	mov    rcx,QWORD PTR [rsp+0x38]
    24d1:	mov    rdx,QWORD PTR [rsp+0x40]
    24d6:	mov    rsi,r15
    24d9:	mov    rdi,rbx
    24dc:	call   24e1 <botlish_fn_20+0x1c9>
			24dd: R_X86_64_PLT32	rt_str_region_eq-0x4
    24e1:	cmp    rax,0x6
    24e5:	je     2578 <botlish_fn_20+0x260>
    24eb:	mov    rax,QWORD PTR [rbx+0x10]
    24ef:	mov    r8,QWORD PTR [rax+0xd0]
    24f6:	mov    rcx,QWORD PTR [rsp+0x38]
    24fb:	mov    rdx,QWORD PTR [rsp+0x40]
    2500:	mov    rsi,r15
    2503:	mov    rdi,rbx
    2506:	call   250b <botlish_fn_20+0x1f3>
			2507: R_X86_64_PLT32	rt_str_region_eq-0x4
    250b:	cmp    rax,0x6
    250f:	je     256e <botlish_fn_20+0x256>
    2515:	mov    rax,QWORD PTR [rbx+0x10]
    2519:	mov    r8,QWORD PTR [rax+0x118]
    2520:	mov    rcx,QWORD PTR [rsp+0x38]
    2525:	mov    rdx,QWORD PTR [rsp+0x40]
    252a:	mov    rsi,r15
    252d:	mov    rdi,rbx
    2530:	call   2535 <botlish_fn_20+0x21d>
			2531: R_X86_64_PLT32	rt_str_region_eq-0x4
    2535:	cmp    rax,0x6
    2539:	je     2564 <botlish_fn_20+0x24c>
    253f:	mov    rax,QWORD PTR [rbx+0x10]
    2543:	mov    r8,QWORD PTR [rax+0x138]
    254a:	mov    rcx,QWORD PTR [rsp+0x38]
    254f:	mov    rdx,QWORD PTR [rsp+0x40]
    2554:	mov    rsi,r15
    2557:	mov    rdi,rbx
    255a:	call   255f <botlish_fn_20+0x247>
			255b: R_X86_64_PLT32	rt_str_region_eq-0x4
    255f:	jmp    2591 <botlish_fn_20+0x279>
    2564:	mov    rax,QWORD PTR [rsp+0x30]
    2569:	jmp    2591 <botlish_fn_20+0x279>
    256e:	mov    rax,QWORD PTR [rsp+0x30]
    2573:	jmp    2591 <botlish_fn_20+0x279>
    2578:	mov    rax,QWORD PTR [rsp+0x30]
    257d:	jmp    2591 <botlish_fn_20+0x279>
    2582:	mov    rax,QWORD PTR [rsp+0x30]
    2587:	jmp    2591 <botlish_fn_20+0x279>
    258c:	mov    rax,QWORD PTR [rsp+0x30]
    2591:	cmp    rax,0x6
    2595:	je     25a3 <botlish_fn_20+0x28b>
    259b:	mov    rax,r14
    259e:	jmp    260e <botlish_fn_20+0x2f6>
    25a3:	mov    QWORD PTR [rsp+0x18],0x3
    25ac:	mov    rsi,r14
    25af:	test   rsi,0x1
    25b6:	je     25dc <botlish_fn_20+0x2c4>
    25bc:	mov    rsi,r14
    25bf:	mov    rax,rsi
    25c2:	add    rax,0x2
    25c6:	seto   cl
    25c9:	test   cl,cl
    25cb:	jne    25dc <botlish_fn_20+0x2c4>
    25d1:	mov    rsi,rax
    25d4:	mov    r14,rax
    25d7:	jmp    25f2 <botlish_fn_20+0x2da>
    25dc:	mov    edx,0x3
    25e1:	mov    rsi,r14
    25e4:	mov    rdi,rbx
    25e7:	call   25ec <botlish_fn_20+0x2d4>
			25e8: R_X86_64_PLT32	rt_int_add-0x4
    25ec:	mov    rsi,rax
    25ef:	mov    r14,rax
    25f2:	mov    QWORD PTR [rsp],rsi
    25f6:	mov    QWORD PTR [rsp+0x8],r13
    25fb:	mov    QWORD PTR [rsp+0x10],r12
    2600:	mov    rax,rbx
    2603:	mov    rdx,r13
    2606:	jmp    235c <botlish_fn_20+0x44>
    260b:	mov    rax,r14
    260e:	mov    rbx,QWORD PTR [rsp+0x50]
    2613:	mov    r12,QWORD PTR [rsp+0x58]
    2618:	mov    r13,QWORD PTR [rsp+0x60]
    261d:	mov    r14,QWORD PTR [rsp+0x68]
    2622:	mov    r15,QWORD PTR [rsp+0x70]
    2627:	add    rsp,0x80
    262e:	mov    rsp,rbp
    2631:	pop    rbp
    2632:	ret
    2633:	add    BYTE PTR [rax],al
    2635:	add    BYTE PTR [rax],al
    2637:	add    BYTE PTR [rsi],al
    2639:	add    BYTE PTR [rax],al
    263b:	add    BYTE PTR [rax],al
    263d:	add    BYTE PTR [rax],al
	...

0000000000002640 <botlish_entry_20: scan_local<generic>>:
    2640:	push   rbp
    2641:	mov    rbp,rsp
    2644:	mov    rsi,QWORD PTR [rdx]
    2647:	mov    r8,QWORD PTR [rdx+0x8]
    264b:	mov    rcx,QWORD PTR [rdx+0x10]
    264f:	mov    rdx,r8
    2652:	call   2657 <botlish_entry_20+0x17>
			2653: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    2657:	mov    rsp,rbp
    265a:	pop    rbp
    265b:	ret
    265c:	add    BYTE PTR [rax],al
	...

0000000000002660 <botlish_fn_21: scan_label<generic>>:
    2660:	push   rbp
    2661:	mov    rbp,rsp
    2664:	sub    rsp,0x80
    266b:	mov    QWORD PTR [rsp+0x50],rbx
    2670:	mov    QWORD PTR [rsp+0x58],r12
    2675:	mov    QWORD PTR [rsp+0x60],r13
    267a:	mov    QWORD PTR [rsp+0x68],r14
    267f:	mov    QWORD PTR [rsp+0x70],r15
    2684:	mov    QWORD PTR [rsp+0x18],0x0
    268d:	mov    QWORD PTR [rsp],rsi
    2691:	mov    r14,rsi
    2694:	mov    QWORD PTR [rsp+0x8],rdx
    2699:	mov    QWORD PTR [rsp+0x10],rcx
    269e:	mov    r12,rcx
    26a1:	mov    r11d,0x1
    26a7:	mov    rsi,r14
    26aa:	test   rsi,0x1
    26b1:	jne    26d1 <botlish_fn_21+0x71>
    26b7:	xor    r11d,r11d
    26ba:	test   rsi,0x7
    26c1:	jne    26d1 <botlish_fn_21+0x71>
    26c7:	movzx  rax,BYTE PTR [rsi]
    26cb:	cmp    al,0x1
    26cd:	sete   r11b
    26d1:	test   r11b,r11b
    26d4:	jne    26f2 <botlish_fn_21+0x92>
    26da:	mov    rax,QWORD PTR [rdi+0x10]
    26de:	mov    rcx,QWORD PTR [rax+0xa8]
    26e5:	xor    rdx,rdx
    26e8:	call   26ed <botlish_fn_21+0x8d>
			26e9: R_X86_64_PLT32	rt_type_error-0x4
    26ed:	jmp    279e <botlish_fn_21+0x13e>
    26f2:	mov    r13,rdx
    26f5:	mov    rax,rsi
    26f8:	and    rax,r13
    26fb:	mov    r14,rsi
    26fe:	test   rax,0x1
    2704:	jne    272d <botlish_fn_21+0xcd>
    270a:	mov    rbx,rdi
    270d:	mov    rdx,r13
    2710:	mov    rsi,r14
    2713:	call   2718 <botlish_fn_21+0xb8>
			2714: R_X86_64_PLT32	rt_int_cmp-0x4
    2718:	mov    ecx,0x2
    271d:	test   rax,rax
    2720:	cmovge rcx,QWORD PTR [rip+0x178]        # 28a0 <botlish_fn_21+0x240>
    2728:	jmp    2743 <botlish_fn_21+0xe3>
    272d:	mov    rbx,rdi
    2730:	mov    ecx,0x2
    2735:	mov    rsi,r14
    2738:	cmp    rsi,r13
    273b:	cmovge rcx,QWORD PTR [rip+0x15d]        # 28a0 <botlish_fn_21+0x240>
    2743:	mov    eax,0x6
    2748:	mov    QWORD PTR [rsp+0x30],rax
    274d:	cmp    rcx,0x6
    2751:	je     2874 <botlish_fn_21+0x214>
    2757:	lea    rcx,[rsp+0x20]
    275c:	mov    rdx,r12
    275f:	mov    rsi,r14
    2762:	mov    rdi,rbx
    2765:	call   276a <botlish_fn_21+0x10a>
			2766: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    276a:	test   rax,rax
    276d:	mov    r15,rax
    2770:	je     279e <botlish_fn_21+0x13e>
    2776:	mov    rdx,QWORD PTR [rsp+0x20]
    277b:	mov    QWORD PTR [rsp+0x40],rdx
    2780:	mov    rcx,QWORD PTR [rsp+0x28]
    2785:	mov    QWORD PTR [rsp+0x38],rcx
    278a:	mov    rsi,r15
    278d:	mov    rdi,rbx
    2790:	call   2795 <botlish_fn_21+0x135>
			2791: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    2795:	test   rax,rax
    2798:	jne    27c6 <botlish_fn_21+0x166>
    279e:	xor    rax,rax
    27a1:	mov    rbx,QWORD PTR [rsp+0x50]
    27a6:	mov    r12,QWORD PTR [rsp+0x58]
    27ab:	mov    r13,QWORD PTR [rsp+0x60]
    27b0:	mov    r14,QWORD PTR [rsp+0x68]
    27b5:	mov    r15,QWORD PTR [rsp+0x70]
    27ba:	add    rsp,0x80
    27c1:	mov    rsp,rbp
    27c4:	pop    rbp
    27c5:	ret
    27c6:	cmp    rax,0x6
    27ca:	je     27f5 <botlish_fn_21+0x195>
    27d0:	mov    r11,QWORD PTR [rbx+0x10]
    27d4:	mov    r8,QWORD PTR [r11+0x138]
    27db:	mov    rcx,QWORD PTR [rsp+0x38]
    27e0:	mov    rdx,QWORD PTR [rsp+0x40]
    27e5:	mov    rsi,r15
    27e8:	mov    rdi,rbx
    27eb:	call   27f0 <botlish_fn_21+0x190>
			27ec: R_X86_64_PLT32	rt_str_region_eq-0x4
    27f0:	jmp    27fa <botlish_fn_21+0x19a>
    27f5:	mov    rax,QWORD PTR [rsp+0x30]
    27fa:	cmp    rax,0x6
    27fe:	je     280c <botlish_fn_21+0x1ac>
    2804:	mov    rax,r14
    2807:	jmp    2877 <botlish_fn_21+0x217>
    280c:	mov    QWORD PTR [rsp+0x18],0x3
    2815:	mov    rsi,r14
    2818:	test   rsi,0x1
    281f:	je     2845 <botlish_fn_21+0x1e5>
    2825:	mov    rsi,r14
    2828:	mov    rax,rsi
    282b:	add    rax,0x2
    282f:	seto   cl
    2832:	test   cl,cl
    2834:	jne    2845 <botlish_fn_21+0x1e5>
    283a:	mov    rsi,rax
    283d:	mov    r14,rax
    2840:	jmp    285b <botlish_fn_21+0x1fb>
    2845:	mov    edx,0x3
    284a:	mov    rsi,r14
    284d:	mov    rdi,rbx
    2850:	call   2855 <botlish_fn_21+0x1f5>
			2851: R_X86_64_PLT32	rt_int_add-0x4
    2855:	mov    rsi,rax
    2858:	mov    r14,rax
    285b:	mov    QWORD PTR [rsp],rsi
    285f:	mov    QWORD PTR [rsp+0x8],r13
    2864:	mov    QWORD PTR [rsp+0x10],r12
    2869:	mov    rdx,r13
    286c:	mov    rdi,rbx
    286f:	jmp    26a1 <botlish_fn_21+0x41>
    2874:	mov    rax,r14
    2877:	mov    rbx,QWORD PTR [rsp+0x50]
    287c:	mov    r12,QWORD PTR [rsp+0x58]
    2881:	mov    r13,QWORD PTR [rsp+0x60]
    2886:	mov    r14,QWORD PTR [rsp+0x68]
    288b:	mov    r15,QWORD PTR [rsp+0x70]
    2890:	add    rsp,0x80
    2897:	mov    rsp,rbp
    289a:	pop    rbp
    289b:	ret
    289c:	add    BYTE PTR [rax],al
    289e:	add    BYTE PTR [rax],al
    28a0:	(bad)
    28a1:	add    BYTE PTR [rax],al
    28a3:	add    BYTE PTR [rax],al
    28a5:	add    BYTE PTR [rax],al
	...

00000000000028a8 <botlish_entry_21: scan_label<generic>>:
    28a8:	push   rbp
    28a9:	mov    rbp,rsp
    28ac:	mov    rsi,QWORD PTR [rdx]
    28af:	mov    r8,QWORD PTR [rdx+0x8]
    28b3:	mov    rcx,QWORD PTR [rdx+0x10]
    28b7:	mov    rdx,r8
    28ba:	call   28bf <botlish_entry_21+0x17>
			28bb: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    28bf:	mov    rsp,rbp
    28c2:	pop    rbp
    28c3:	ret
    28c4:	add    BYTE PTR [rax],al
	...

00000000000028c8 <botlish_fn_22: scan_alpha<generic>>:
    28c8:	push   rbp
    28c9:	mov    rbp,rsp
    28cc:	sub    rsp,0x50
    28d0:	mov    QWORD PTR [rsp+0x30],rbx
    28d5:	mov    QWORD PTR [rsp+0x38],r12
    28da:	mov    QWORD PTR [rsp+0x40],r13
    28df:	mov    QWORD PTR [rsp+0x48],r14
    28e4:	mov    r14,rdi
    28e7:	mov    QWORD PTR [rsp+0x18],0x0
    28f0:	mov    QWORD PTR [rsp],rsi
    28f4:	mov    r13,rsi
    28f7:	mov    QWORD PTR [rsp+0x8],rdx
    28fc:	mov    r12,rdx
    28ff:	mov    QWORD PTR [rsp+0x10],rcx
    2904:	mov    rbx,rcx
    2907:	mov    r11d,0x1
    290d:	mov    rsi,r13
    2910:	test   rsi,0x1
    2917:	jne    2937 <botlish_fn_22+0x6f>
    291d:	xor    r11d,r11d
    2920:	test   rsi,0x7
    2927:	jne    2937 <botlish_fn_22+0x6f>
    292d:	movzx  rax,BYTE PTR [rsi]
    2931:	cmp    al,0x1
    2933:	sete   r11b
    2937:	test   r11b,r11b
    293a:	jne    295b <botlish_fn_22+0x93>
    2940:	mov    rdi,r14
    2943:	mov    rax,QWORD PTR [rdi+0x10]
    2947:	mov    rcx,QWORD PTR [rax+0xa8]
    294e:	xor    rdx,rdx
    2951:	call   2956 <botlish_fn_22+0x8e>
			2952: R_X86_64_PLT32	rt_type_error-0x4
    2956:	jmp    29ea <botlish_fn_22+0x122>
    295b:	mov    rax,rsi
    295e:	and    rax,r12
    2961:	mov    r13,rsi
    2964:	test   rax,0x1
    296a:	jne    2993 <botlish_fn_22+0xcb>
    2970:	mov    rdx,r12
    2973:	mov    rsi,r13
    2976:	mov    rdi,r14
    2979:	call   297e <botlish_fn_22+0xb6>
			297a: R_X86_64_PLT32	rt_int_cmp-0x4
    297e:	mov    ecx,0x2
    2983:	test   rax,rax
    2986:	cmovge rcx,QWORD PTR [rip+0x112]        # 2aa0 <botlish_fn_22+0x1d8>
    298e:	jmp    29a6 <botlish_fn_22+0xde>
    2993:	mov    ecx,0x2
    2998:	mov    rsi,r13
    299b:	cmp    rsi,r12
    299e:	cmovge rcx,QWORD PTR [rip+0xfa]        # 2aa0 <botlish_fn_22+0x1d8>
    29a6:	cmp    rcx,0x6
    29aa:	je     2a7e <botlish_fn_22+0x1b6>
    29b0:	lea    rcx,[rsp+0x20]
    29b5:	mov    rdx,rbx
    29b8:	mov    rsi,r13
    29bb:	mov    rdi,r14
    29be:	call   29c3 <botlish_fn_22+0xfb>
			29bf: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    29c3:	test   rax,rax
    29c6:	mov    rsi,rax
    29c9:	je     29ea <botlish_fn_22+0x122>
    29cf:	mov    rdx,QWORD PTR [rsp+0x20]
    29d4:	mov    rcx,QWORD PTR [rsp+0x28]
    29d9:	mov    rdi,r14
    29dc:	call   29e1 <botlish_fn_22+0x119>
			29dd: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    29e1:	test   rax,rax
    29e4:	jne    2a0a <botlish_fn_22+0x142>
    29ea:	xor    rax,rax
    29ed:	mov    rbx,QWORD PTR [rsp+0x30]
    29f2:	mov    r12,QWORD PTR [rsp+0x38]
    29f7:	mov    r13,QWORD PTR [rsp+0x40]
    29fc:	mov    r14,QWORD PTR [rsp+0x48]
    2a01:	add    rsp,0x50
    2a05:	mov    rsp,rbp
    2a08:	pop    rbp
    2a09:	ret
    2a0a:	cmp    rax,0x6
    2a0e:	je     2a1c <botlish_fn_22+0x154>
    2a14:	mov    rax,r13
    2a17:	jmp    2a81 <botlish_fn_22+0x1b9>
    2a1c:	mov    QWORD PTR [rsp+0x18],0x3
    2a25:	mov    rsi,r13
    2a28:	test   rsi,0x1
    2a2f:	je     2a55 <botlish_fn_22+0x18d>
    2a35:	mov    rsi,r13
    2a38:	mov    r11,rsi
    2a3b:	add    r11,0x2
    2a3f:	seto   al
    2a42:	test   al,al
    2a44:	jne    2a55 <botlish_fn_22+0x18d>
    2a4a:	mov    rsi,r11
    2a4d:	mov    r13,r11
    2a50:	jmp    2a6b <botlish_fn_22+0x1a3>
    2a55:	mov    edx,0x3
    2a5a:	mov    rsi,r13
    2a5d:	mov    rdi,r14
    2a60:	call   2a65 <botlish_fn_22+0x19d>
			2a61: R_X86_64_PLT32	rt_int_add-0x4
    2a65:	mov    rsi,rax
    2a68:	mov    r13,rax
    2a6b:	mov    QWORD PTR [rsp],rsi
    2a6f:	mov    QWORD PTR [rsp+0x8],r12
    2a74:	mov    QWORD PTR [rsp+0x10],rbx
    2a79:	jmp    2907 <botlish_fn_22+0x3f>
    2a7e:	mov    rax,r13
    2a81:	mov    rbx,QWORD PTR [rsp+0x30]
    2a86:	mov    r12,QWORD PTR [rsp+0x38]
    2a8b:	mov    r13,QWORD PTR [rsp+0x40]
    2a90:	mov    r14,QWORD PTR [rsp+0x48]
    2a95:	add    rsp,0x50
    2a99:	mov    rsp,rbp
    2a9c:	pop    rbp
    2a9d:	ret
    2a9e:	add    BYTE PTR [rax],al
    2aa0:	(bad)
    2aa1:	add    BYTE PTR [rax],al
    2aa3:	add    BYTE PTR [rax],al
    2aa5:	add    BYTE PTR [rax],al
	...

0000000000002aa8 <botlish_entry_22: scan_alpha<generic>>:
    2aa8:	push   rbp
    2aa9:	mov    rbp,rsp
    2aac:	mov    rsi,QWORD PTR [rdx]
    2aaf:	mov    r8,QWORD PTR [rdx+0x8]
    2ab3:	mov    rcx,QWORD PTR [rdx+0x10]
    2ab7:	mov    rdx,r8
    2aba:	call   2abf <botlish_entry_22+0x17>
			2abb: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    2abf:	mov    rsp,rbp
    2ac2:	pop    rbp
    2ac3:	ret
    2ac4:	add    BYTE PTR [rax],al
	...

0000000000002ac8 <botlish_fn_23: tld_ok<generic>>:
    2ac8:	push   rbp
    2ac9:	mov    rbp,rsp
    2acc:	sub    rsp,0x40
    2ad0:	mov    QWORD PTR [rsp+0x20],rbx
    2ad5:	mov    QWORD PTR [rsp+0x28],r12
    2ada:	mov    QWORD PTR [rsp+0x30],r13
    2adf:	mov    QWORD PTR [rsp+0x38],r14
    2ae4:	mov    rbx,rdi
    2ae7:	mov    QWORD PTR [rsp],rsi
    2aeb:	mov    r12,rsi
    2aee:	mov    QWORD PTR [rsp+0x8],rdx
    2af3:	mov    r14,rdx
    2af6:	mov    QWORD PTR [rsp+0x10],rcx
    2afb:	mov    rdx,r14
    2afe:	mov    rsi,r12
    2b01:	mov    rdi,rbx
    2b04:	call   2b09 <botlish_fn_23+0x41>
			2b05: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    2b09:	mov    rsi,rax
    2b0c:	mov    r13,rax
    2b0f:	test   rax,rsi
    2b12:	je     2bd5 <botlish_fn_23+0x10d>
    2b18:	mov    rax,r13
    2b1b:	mov    QWORD PTR [rsp+0x8],rax
    2b20:	mov    rdx,r14
    2b23:	and    rax,rdx
    2b26:	test   rax,0x1
    2b2c:	jne    2b55 <botlish_fn_23+0x8d>
    2b32:	mov    rsi,r13
    2b35:	mov    rdi,rbx
    2b38:	call   2b3d <botlish_fn_23+0x75>
			2b39: R_X86_64_PLT32	rt_int_cmp-0x4
    2b3d:	mov    ecx,0x2
    2b42:	test   rax,rax
    2b45:	cmove  rcx,QWORD PTR [rip+0x15b]        # 2ca8 <botlish_fn_23+0x1e0>
    2b4d:	mov    rax,r13
    2b50:	jmp    2b68 <botlish_fn_23+0xa0>
    2b55:	mov    ecx,0x2
    2b5a:	mov    rax,r13
    2b5d:	cmp    rax,rdx
    2b60:	cmove  rcx,QWORD PTR [rip+0x140]        # 2ca8 <botlish_fn_23+0x1e0>
    2b68:	cmp    rcx,0x6
    2b6c:	je     2b7f <botlish_fn_23+0xb7>
    2b72:	mov    ecx,0x2
    2b77:	mov    rax,rcx
    2b7a:	jmp    2c87 <botlish_fn_23+0x1bf>
    2b7f:	mov    ecx,0x1
    2b84:	mov    rsi,r12
    2b87:	test   rsi,0x1
    2b8e:	jne    2bb4 <botlish_fn_23+0xec>
    2b94:	xor    ecx,ecx
    2b96:	mov    rsi,r12
    2b99:	test   rsi,0x7
    2ba0:	jne    2bb4 <botlish_fn_23+0xec>
    2ba6:	mov    rsi,r12
    2ba9:	movzx  rcx,BYTE PTR [rsi]
    2bad:	rex cmp cl,0x1
    2bb1:	sete   cl
    2bb4:	test   cl,cl
    2bb6:	jne    2bf5 <botlish_fn_23+0x12d>
    2bbc:	mov    rdi,rbx
    2bbf:	mov    rsi,QWORD PTR [rdi+0x10]
    2bc3:	mov    rcx,QWORD PTR [rsi+0x138]
    2bca:	xor    rdx,rdx
    2bcd:	mov    rsi,r12
    2bd0:	call   2bd5 <botlish_fn_23+0x10d>
			2bd1: R_X86_64_PLT32	rt_type_error-0x4
    2bd5:	xor    rax,rax
    2bd8:	mov    rbx,QWORD PTR [rsp+0x20]
    2bdd:	mov    r12,QWORD PTR [rsp+0x28]
    2be2:	mov    r13,QWORD PTR [rsp+0x30]
    2be7:	mov    r14,QWORD PTR [rsp+0x38]
    2bec:	add    rsp,0x40
    2bf0:	mov    rsp,rbp
    2bf3:	pop    rbp
    2bf4:	ret
    2bf5:	mov    rsi,r12
    2bf8:	mov    rdi,rax
    2bfb:	and    rdi,rsi
    2bfe:	test   rdi,0x1
    2c05:	jne    2c16 <botlish_fn_23+0x14e>
    2c0b:	mov    rdx,r12
    2c0e:	mov    rsi,rax
    2c11:	jmp    2c39 <botlish_fn_23+0x171>
    2c16:	mov    rsi,r12
    2c19:	mov    r8,rax
    2c1c:	sub    r8,rsi
    2c1f:	mov    r13,rax
    2c22:	seto   r10b
    2c26:	lea    rsi,[r8+0x1]
    2c2a:	test   r10b,r10b
    2c2d:	je     2c44 <botlish_fn_23+0x17c>
    2c33:	mov    rdx,r12
    2c36:	mov    rsi,r13
    2c39:	mov    rdi,rbx
    2c3c:	call   2c41 <botlish_fn_23+0x179>
			2c3d: R_X86_64_PLT32	rt_int_sub-0x4
    2c41:	mov    rsi,rax
    2c44:	test   rsi,0x1
    2c4b:	jne    2c76 <botlish_fn_23+0x1ae>
    2c51:	mov    edx,0x5
    2c56:	mov    rdi,rbx
    2c59:	call   2c5e <botlish_fn_23+0x196>
			2c5a: R_X86_64_PLT32	rt_int_cmp-0x4
    2c5e:	mov    ecx,0x2
    2c63:	test   rax,rax
    2c66:	mov    rax,rcx
    2c69:	cmovge rax,QWORD PTR [rip+0x37]        # 2ca8 <botlish_fn_23+0x1e0>
    2c71:	jmp    2c87 <botlish_fn_23+0x1bf>
    2c76:	mov    eax,0x2
    2c7b:	cmp    rsi,0x5
    2c7f:	cmovge rax,QWORD PTR [rip+0x21]        # 2ca8 <botlish_fn_23+0x1e0>
    2c87:	mov    rbx,QWORD PTR [rsp+0x20]
    2c8c:	mov    r12,QWORD PTR [rsp+0x28]
    2c91:	mov    r13,QWORD PTR [rsp+0x30]
    2c96:	mov    r14,QWORD PTR [rsp+0x38]
    2c9b:	add    rsp,0x40
    2c9f:	mov    rsp,rbp
    2ca2:	pop    rbp
    2ca3:	ret
    2ca4:	add    BYTE PTR [rax],al
    2ca6:	add    BYTE PTR [rax],al
    2ca8:	(bad)
    2ca9:	add    BYTE PTR [rax],al
    2cab:	add    BYTE PTR [rax],al
    2cad:	add    BYTE PTR [rax],al
	...

0000000000002cb0 <botlish_entry_23: tld_ok<generic>>:
    2cb0:	push   rbp
    2cb1:	mov    rbp,rsp
    2cb4:	mov    rsi,QWORD PTR [rdx]
    2cb7:	mov    r8,QWORD PTR [rdx+0x8]
    2cbb:	mov    rcx,QWORD PTR [rdx+0x10]
    2cbf:	mov    rdx,r8
    2cc2:	call   2cc7 <botlish_entry_23+0x17>
			2cc3: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    2cc7:	mov    rsp,rbp
    2cca:	pop    rbp
    2ccb:	ret
    2ccc:	add    BYTE PTR [rax],al
	...

0000000000002cd0 <botlish_fn_24: domain_loop<generic>>:
    2cd0:	push   rbp
    2cd1:	mov    rbp,rsp
    2cd4:	sub    rsp,0x70
    2cd8:	mov    QWORD PTR [rsp+0x40],rbx
    2cdd:	mov    QWORD PTR [rsp+0x48],r12
    2ce2:	mov    QWORD PTR [rsp+0x50],r13
    2ce7:	mov    QWORD PTR [rsp+0x58],r14
    2cec:	mov    QWORD PTR [rsp+0x60],r15
    2cf1:	mov    QWORD PTR [rsp+0x18],0x0
    2cfa:	mov    QWORD PTR [rsp],rsi
    2cfe:	mov    QWORD PTR [rsp+0x8],rdx
    2d03:	mov    QWORD PTR [rsp+0x10],rcx
    2d08:	lea    rbx,[rsp+0x20]
    2d0d:	mov    r12,rdi
    2d10:	mov    r13,rcx
    2d13:	mov    r14,rdx
    2d16:	mov    QWORD PTR [rsp+0x30],rsi
    2d1b:	mov    rcx,r13
    2d1e:	mov    rdx,r14
    2d21:	mov    rsi,QWORD PTR [rsp+0x30]
    2d26:	mov    rdi,r12
    2d29:	call   2d2e <botlish_fn_24+0x5e>
			2d2a: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    2d2e:	mov    rcx,rax
    2d31:	mov    r15,rax
    2d34:	test   rax,rcx
    2d37:	je     2e87 <botlish_fn_24+0x1b7>
    2d3d:	mov    rax,r15
    2d40:	mov    QWORD PTR [rsp],rax
    2d44:	mov    rdx,QWORD PTR [rsp+0x30]
    2d49:	and    rax,rdx
    2d4c:	test   rax,0x1
    2d52:	jne    2d71 <botlish_fn_24+0xa1>
    2d58:	mov    rsi,r15
    2d5b:	mov    rdi,r12
    2d5e:	call   2d63 <botlish_fn_24+0x93>
			2d5f: R_X86_64_PLT32	rt_value_eq-0x4
    2d63:	test   rax,rax
    2d66:	je     2e87 <botlish_fn_24+0x1b7>
    2d6c:	jmp    2d81 <botlish_fn_24+0xb1>
    2d71:	mov    eax,0x2
    2d76:	cmp    r15,rdx
    2d79:	cmove  rax,QWORD PTR [rip+0x187]        # 2f08 <botlish_fn_24+0x238>
    2d81:	cmp    rax,0x6
    2d85:	je     2edd <botlish_fn_24+0x20d>
    2d8b:	mov    rax,r15
    2d8e:	and    rax,r14
    2d91:	test   rax,0x1
    2d97:	jne    2dc0 <botlish_fn_24+0xf0>
    2d9d:	mov    rdx,r14
    2da0:	mov    rsi,r15
    2da3:	mov    rdi,r12
    2da6:	call   2dab <botlish_fn_24+0xdb>
			2da7: R_X86_64_PLT32	rt_int_cmp-0x4
    2dab:	mov    ecx,0x2
    2db0:	test   rax,rax
    2db3:	cmovge rcx,QWORD PTR [rip+0x14d]        # 2f08 <botlish_fn_24+0x238>
    2dbb:	jmp    2dd0 <botlish_fn_24+0x100>
    2dc0:	mov    ecx,0x2
    2dc5:	cmp    r15,r14
    2dc8:	cmovge rcx,QWORD PTR [rip+0x138]        # 2f08 <botlish_fn_24+0x238>
    2dd0:	cmp    rcx,0x6
    2dd4:	je     2ece <botlish_fn_24+0x1fe>
    2dda:	mov    rcx,rbx
    2ddd:	mov    rdx,r13
    2de0:	mov    rsi,r15
    2de3:	mov    rdi,r12
    2de6:	call   2deb <botlish_fn_24+0x11b>
			2de7: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    2deb:	test   rax,rax
    2dee:	je     2e87 <botlish_fn_24+0x1b7>
    2df4:	mov    rdx,QWORD PTR [rsp+0x20]
    2df9:	mov    rcx,QWORD PTR [rsp+0x28]
    2dfe:	mov    rsi,QWORD PTR [r12+0x10]
    2e03:	mov    r8,QWORD PTR [rsi+0x128]
    2e0a:	mov    rsi,rax
    2e0d:	mov    rdi,r12
    2e10:	call   2e15 <botlish_fn_24+0x145>
			2e11: R_X86_64_PLT32	rt_str_region_eq-0x4
    2e15:	cmp    rax,0x6
    2e19:	je     2e2b <botlish_fn_24+0x15b>
    2e1f:	mov    r14,0xffffffffffffffff
    2e26:	jmp    2ed5 <botlish_fn_24+0x205>
    2e2b:	mov    QWORD PTR [rsp+0x18],0x3
    2e34:	test   r15,0x1
    2e3b:	je     2e53 <botlish_fn_24+0x183>
    2e41:	mov    rdx,r15
    2e44:	add    rdx,0x2
    2e48:	seto   al
    2e4b:	test   al,al
    2e4d:	je     2e66 <botlish_fn_24+0x196>
    2e53:	mov    edx,0x3
    2e58:	mov    rsi,r15
    2e5b:	mov    rdi,r12
    2e5e:	call   2e63 <botlish_fn_24+0x193>
			2e5f: R_X86_64_PLT32	rt_int_add-0x4
    2e63:	mov    rdx,rax
    2e66:	mov    QWORD PTR [rsp],rdx
    2e6a:	mov    r15,rdx
    2e6d:	mov    rcx,r13
    2e70:	mov    rdx,r14
    2e73:	mov    rsi,r15
    2e76:	mov    rdi,r12
    2e79:	call   2e7e <botlish_fn_24+0x1ae>
			2e7a: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    2e7e:	test   rax,rax
    2e81:	jne    2eac <botlish_fn_24+0x1dc>
    2e87:	xor    rax,rax
    2e8a:	mov    rbx,QWORD PTR [rsp+0x40]
    2e8f:	mov    r12,QWORD PTR [rsp+0x48]
    2e94:	mov    r13,QWORD PTR [rsp+0x50]
    2e99:	mov    r14,QWORD PTR [rsp+0x58]
    2e9e:	mov    r15,QWORD PTR [rsp+0x60]
    2ea3:	add    rsp,0x70
    2ea7:	mov    rsp,rbp
    2eaa:	pop    rbp
    2eab:	ret
    2eac:	cmp    rax,0x6
    2eb0:	je     2ed5 <botlish_fn_24+0x205>
    2eb6:	mov    QWORD PTR [rsp],r15
    2eba:	mov    QWORD PTR [rsp+0x8],r14
    2ebf:	mov    QWORD PTR [rsp+0x10],r13
    2ec4:	mov    QWORD PTR [rsp+0x30],r15
    2ec9:	jmp    2d1b <botlish_fn_24+0x4b>
    2ece:	mov    r14,0xffffffffffffffff
    2ed5:	mov    rax,r14
    2ed8:	jmp    2ee4 <botlish_fn_24+0x214>
    2edd:	mov    rax,0xffffffffffffffff
    2ee4:	mov    rbx,QWORD PTR [rsp+0x40]
    2ee9:	mov    r12,QWORD PTR [rsp+0x48]
    2eee:	mov    r13,QWORD PTR [rsp+0x50]
    2ef3:	mov    r14,QWORD PTR [rsp+0x58]
    2ef8:	mov    r15,QWORD PTR [rsp+0x60]
    2efd:	add    rsp,0x70
    2f01:	mov    rsp,rbp
    2f04:	pop    rbp
    2f05:	ret
    2f06:	add    BYTE PTR [rax],al
    2f08:	(bad)
    2f09:	add    BYTE PTR [rax],al
    2f0b:	add    BYTE PTR [rax],al
    2f0d:	add    BYTE PTR [rax],al
	...

0000000000002f10 <botlish_entry_24: domain_loop<generic>>:
    2f10:	push   rbp
    2f11:	mov    rbp,rsp
    2f14:	mov    rsi,QWORD PTR [rdx]
    2f17:	mov    r8,QWORD PTR [rdx+0x8]
    2f1b:	mov    rcx,QWORD PTR [rdx+0x10]
    2f1f:	mov    rdx,r8
    2f22:	call   2f27 <botlish_entry_24+0x17>
			2f23: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    2f27:	mov    rsp,rbp
    2f2a:	pop    rbp
    2f2b:	ret
    2f2c:	add    BYTE PTR [rax],al
	...

0000000000002f30 <botlish_fn_25: <str>>:
    2f30:	push   rbp
    2f31:	mov    rbp,rsp
    2f34:	sub    rsp,0x50
    2f38:	mov    QWORD PTR [rsp+0x30],rbx
    2f3d:	mov    QWORD PTR [rsp+0x38],r12
    2f42:	mov    QWORD PTR [rsp+0x40],r13
    2f47:	mov    QWORD PTR [rsp+0x48],r14
    2f4c:	mov    r13,rdi
    2f4f:	mov    QWORD PTR [rsp+0x18],0x0
    2f58:	mov    QWORD PTR [rsp],rsi
    2f5c:	mov    r14,rsi
    2f5f:	mov    rsi,r14
    2f62:	mov    rdi,r13
    2f65:	call   2f6a <botlish_fn_25+0x3a>
			2f66: R_X86_64_PLT32	rt_str_len-0x4
    2f6a:	mov    rbx,rax
    2f6d:	mov    QWORD PTR [rsp+0x8],rax
    2f72:	mov    esi,0x1
    2f77:	mov    QWORD PTR [rsp+0x10],0x1
    2f80:	mov    rcx,r14
    2f83:	mov    rdx,rbx
    2f86:	mov    rdi,r13
    2f89:	call   2f8e <botlish_fn_25+0x5e>
			2f8a: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    2f8e:	mov    r12,rax
    2f91:	test   r12,r12
    2f94:	je     30f1 <botlish_fn_25+0x1c1>
    2f9a:	mov    QWORD PTR [rsp+0x10],r12
    2f9f:	test   r12,0x1
    2fa6:	jne    2fd1 <botlish_fn_25+0xa1>
    2fac:	mov    edx,0x1
    2fb1:	mov    rsi,r12
    2fb4:	mov    rdi,r13
    2fb7:	call   2fbc <botlish_fn_25+0x8c>
			2fb8: R_X86_64_PLT32	rt_int_cmp-0x4
    2fbc:	mov    ecx,0x2
    2fc1:	test   rax,rax
    2fc4:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 3190 <botlish_fn_25+0x260>
    2fcc:	jmp    2fe2 <botlish_fn_25+0xb2>
    2fd1:	mov    ecx,0x2
    2fd6:	cmp    r12,0x1
    2fda:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 3190 <botlish_fn_25+0x260>
    2fe2:	cmp    rcx,0x6
    2fe6:	je     316c <botlish_fn_25+0x23c>
    2fec:	mov    rcx,r12
    2fef:	and    rcx,rbx
    2ff2:	test   rcx,0x1
    2ff9:	jne    3022 <botlish_fn_25+0xf2>
    2fff:	mov    rdx,rbx
    3002:	mov    rsi,r12
    3005:	mov    rdi,r13
    3008:	call   300d <botlish_fn_25+0xdd>
			3009: R_X86_64_PLT32	rt_int_cmp-0x4
    300d:	mov    ecx,0x2
    3012:	test   rax,rax
    3015:	cmovge rcx,QWORD PTR [rip+0x173]        # 3190 <botlish_fn_25+0x260>
    301d:	jmp    3032 <botlish_fn_25+0x102>
    3022:	mov    ecx,0x2
    3027:	cmp    r12,rbx
    302a:	cmovge rcx,QWORD PTR [rip+0x15e]        # 3190 <botlish_fn_25+0x260>
    3032:	cmp    rcx,0x6
    3036:	je     3162 <botlish_fn_25+0x232>
    303c:	lea    rcx,[rsp+0x20]
    3041:	mov    rdx,r14
    3044:	mov    rsi,r12
    3047:	mov    rdi,r13
    304a:	call   304f <botlish_fn_25+0x11f>
			304b: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    304f:	test   rax,rax
    3052:	mov    rsi,rax
    3055:	je     30f1 <botlish_fn_25+0x1c1>
    305b:	mov    rdx,QWORD PTR [rsp+0x20]
    3060:	mov    rcx,QWORD PTR [rsp+0x28]
    3065:	mov    rdi,r13
    3068:	mov    rax,QWORD PTR [rdi+0x10]
    306c:	mov    r8,QWORD PTR [rax+0x110]
    3073:	call   3078 <botlish_fn_25+0x148>
			3074: R_X86_64_PLT32	rt_str_region_eq-0x4
    3078:	cmp    rax,0x6
    307c:	je     308f <botlish_fn_25+0x15f>
    3082:	mov    ecx,0x2
    3087:	mov    rax,rcx
    308a:	jmp    3171 <botlish_fn_25+0x241>
    308f:	mov    QWORD PTR [rsp+0x18],0x3
    3098:	test   r12,0x1
    309f:	jne    30ad <botlish_fn_25+0x17d>
    30a5:	mov    rcx,r12
    30a8:	jmp    30c2 <botlish_fn_25+0x192>
    30ad:	mov    rsi,r12
    30b0:	add    rsi,0x2
    30b4:	mov    rcx,r12
    30b7:	seto   al
    30ba:	test   al,al
    30bc:	je     30d5 <botlish_fn_25+0x1a5>
    30c2:	mov    edx,0x3
    30c7:	mov    rsi,rcx
    30ca:	mov    rdi,r13
    30cd:	call   30d2 <botlish_fn_25+0x1a2>
			30ce: R_X86_64_PLT32	rt_int_add-0x4
    30d2:	mov    rsi,rax
    30d5:	mov    QWORD PTR [rsp+0x10],rsi
    30da:	mov    rcx,r14
    30dd:	mov    rdx,rbx
    30e0:	mov    rdi,r13
    30e3:	call   30e8 <botlish_fn_25+0x1b8>
			30e4: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    30e8:	test   rax,rax
    30eb:	jne    3111 <botlish_fn_25+0x1e1>
    30f1:	xor    rax,rax
    30f4:	mov    rbx,QWORD PTR [rsp+0x30]
    30f9:	mov    r12,QWORD PTR [rsp+0x38]
    30fe:	mov    r13,QWORD PTR [rsp+0x40]
    3103:	mov    r14,QWORD PTR [rsp+0x48]
    3108:	add    rsp,0x50
    310c:	mov    rsp,rbp
    310f:	pop    rbp
    3110:	ret
    3111:	mov    rcx,rax
    3114:	and    rcx,rbx
    3117:	mov    rsi,rax
    311a:	test   rcx,0x1
    3121:	jne    314a <botlish_fn_25+0x21a>
    3127:	mov    rdx,rbx
    312a:	mov    rdi,r13
    312d:	call   3132 <botlish_fn_25+0x202>
			312e: R_X86_64_PLT32	rt_int_cmp-0x4
    3132:	mov    ecx,0x2
    3137:	test   rax,rax
    313a:	mov    rax,rcx
    313d:	cmove  rax,QWORD PTR [rip+0x4b]        # 3190 <botlish_fn_25+0x260>
    3145:	jmp    3171 <botlish_fn_25+0x241>
    314a:	mov    rdx,rbx
    314d:	mov    eax,0x2
    3152:	cmp    rsi,rdx
    3155:	cmove  rax,QWORD PTR [rip+0x33]        # 3190 <botlish_fn_25+0x260>
    315d:	jmp    3171 <botlish_fn_25+0x241>
    3162:	mov    eax,0x2
    3167:	jmp    3171 <botlish_fn_25+0x241>
    316c:	mov    eax,0x2
    3171:	mov    rbx,QWORD PTR [rsp+0x30]
    3176:	mov    r12,QWORD PTR [rsp+0x38]
    317b:	mov    r13,QWORD PTR [rsp+0x40]
    3180:	mov    r14,QWORD PTR [rsp+0x48]
    3185:	add    rsp,0x50
    3189:	mov    rsp,rbp
    318c:	pop    rbp
    318d:	ret
    318e:	add    BYTE PTR [rax],al
    3190:	(bad)
    3191:	add    BYTE PTR [rax],al
    3193:	add    BYTE PTR [rax],al
    3195:	add    BYTE PTR [rax],al
	...

0000000000003198 <botlish_entry_25: <str>>:
    3198:	push   rbp
    3199:	mov    rbp,rsp
    319c:	mov    rsi,QWORD PTR [rdx]
    319f:	call   31a4 <botlish_entry_25+0xc>
			31a0: R_X86_64_PLT32	botlish_fn_25-0x4 ; <str>
    31a4:	mov    rsp,rbp
    31a7:	pop    rbp
    31a8:	ret
    31a9:	add    BYTE PTR [rax],al
    31ab:	add    BYTE PTR [rax],al
    31ad:	add    BYTE PTR [rax],al
	...

00000000000031b0 <botlish_fn_26: <generic>>:
    31b0:	push   rbp
    31b1:	mov    rbp,rsp
    31b4:	sub    rsp,0x60
    31b8:	mov    QWORD PTR [rsp+0x30],rbx
    31bd:	mov    QWORD PTR [rsp+0x38],r12
    31c2:	mov    QWORD PTR [rsp+0x40],r13
    31c7:	mov    QWORD PTR [rsp+0x48],r14
    31cc:	mov    QWORD PTR [rsp+0x50],r15
    31d1:	mov    QWORD PTR [rsp+0x18],0x0
    31da:	mov    QWORD PTR [rsp],rsi
    31de:	xor    r8d,r8d
    31e1:	test   rsi,0x7
    31e8:	jne    31f8 <botlish_fn_26+0x48>
    31ee:	movzx  rax,BYTE PTR [rsi]
    31f2:	cmp    al,0x2
    31f4:	sete   r8b
    31f8:	test   r8b,r8b
    31fb:	jne    321b <botlish_fn_26+0x6b>
    3201:	mov    rdx,QWORD PTR [rdi+0x10]
    3205:	mov    rcx,QWORD PTR [rdx+0xe8]
    320c:	mov    edx,0x1
    3211:	call   3216 <botlish_fn_26+0x66>
			3212: R_X86_64_PLT32	rt_type_error-0x4
    3216:	jmp    33b0 <botlish_fn_26+0x200>
    321b:	mov    r13,rsi
    321e:	mov    r14,rdi
    3221:	call   3226 <botlish_fn_26+0x76>
			3222: R_X86_64_PLT32	rt_str_len-0x4
    3226:	mov    rbx,rax
    3229:	mov    QWORD PTR [rsp+0x8],rax
    322e:	mov    edx,0x1
    3233:	mov    r15,rdx
    3236:	mov    QWORD PTR [rsp+0x10],0x1
    323f:	mov    rcx,r13
    3242:	mov    rdx,rbx
    3245:	mov    rsi,r15
    3248:	mov    rdi,r14
    324b:	call   3250 <botlish_fn_26+0xa0>
			324c: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    3250:	mov    r12,rax
    3253:	test   r12,r12
    3256:	je     33b0 <botlish_fn_26+0x200>
    325c:	mov    QWORD PTR [rsp+0x10],r12
    3261:	test   r12,0x1
    3268:	jne    3291 <botlish_fn_26+0xe1>
    326e:	mov    rdx,r15
    3271:	mov    rsi,r12
    3274:	mov    rdi,r14
    3277:	call   327c <botlish_fn_26+0xcc>
			3278: R_X86_64_PLT32	rt_int_cmp-0x4
    327c:	mov    ecx,0x2
    3281:	test   rax,rax
    3284:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 3458 <botlish_fn_26+0x2a8>
    328c:	jmp    32a2 <botlish_fn_26+0xf2>
    3291:	mov    ecx,0x2
    3296:	cmp    r12,0x1
    329a:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 3458 <botlish_fn_26+0x2a8>
    32a2:	cmp    rcx,0x6
    32a6:	je     3430 <botlish_fn_26+0x280>
    32ac:	mov    rax,r12
    32af:	and    rax,rbx
    32b2:	test   rax,0x1
    32b8:	jne    32e1 <botlish_fn_26+0x131>
    32be:	mov    rdx,rbx
    32c1:	mov    rsi,r12
    32c4:	mov    rdi,r14
    32c7:	call   32cc <botlish_fn_26+0x11c>
			32c8: R_X86_64_PLT32	rt_int_cmp-0x4
    32cc:	mov    ecx,0x2
    32d1:	test   rax,rax
    32d4:	cmovge rcx,QWORD PTR [rip+0x17c]        # 3458 <botlish_fn_26+0x2a8>
    32dc:	jmp    32f1 <botlish_fn_26+0x141>
    32e1:	mov    ecx,0x2
    32e6:	cmp    r12,rbx
    32e9:	cmovge rcx,QWORD PTR [rip+0x167]        # 3458 <botlish_fn_26+0x2a8>
    32f1:	cmp    rcx,0x6
    32f5:	je     3426 <botlish_fn_26+0x276>
    32fb:	lea    rcx,[rsp+0x20]
    3300:	mov    rdx,r13
    3303:	mov    rsi,r12
    3306:	mov    rdi,r14
    3309:	call   330e <botlish_fn_26+0x15e>
			330a: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    330e:	test   rax,rax
    3311:	mov    rsi,rax
    3314:	je     33b0 <botlish_fn_26+0x200>
    331a:	mov    rdx,QWORD PTR [rsp+0x20]
    331f:	mov    rcx,QWORD PTR [rsp+0x28]
    3324:	mov    rdi,r14
    3327:	mov    rax,QWORD PTR [rdi+0x10]
    332b:	mov    r8,QWORD PTR [rax+0x110]
    3332:	call   3337 <botlish_fn_26+0x187>
			3333: R_X86_64_PLT32	rt_str_region_eq-0x4
    3337:	cmp    rax,0x6
    333b:	je     334e <botlish_fn_26+0x19e>
    3341:	mov    ecx,0x2
    3346:	mov    rax,rcx
    3349:	jmp    3435 <botlish_fn_26+0x285>
    334e:	mov    QWORD PTR [rsp+0x18],0x3
    3357:	test   r12,0x1
    335e:	jne    336c <botlish_fn_26+0x1bc>
    3364:	mov    rdi,r12
    3367:	jmp    3381 <botlish_fn_26+0x1d1>
    336c:	mov    rsi,r12
    336f:	add    rsi,0x2
    3373:	mov    rdi,r12
    3376:	seto   al
    3379:	test   al,al
    337b:	je     3394 <botlish_fn_26+0x1e4>
    3381:	mov    edx,0x3
    3386:	mov    rsi,rdi
    3389:	mov    rdi,r14
    338c:	call   3391 <botlish_fn_26+0x1e1>
			338d: R_X86_64_PLT32	rt_int_add-0x4
    3391:	mov    rsi,rax
    3394:	mov    QWORD PTR [rsp+0x10],rsi
    3399:	mov    rcx,r13
    339c:	mov    rdx,rbx
    339f:	mov    rdi,r14
    33a2:	call   33a7 <botlish_fn_26+0x1f7>
			33a3: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    33a7:	test   rax,rax
    33aa:	jne    33d5 <botlish_fn_26+0x225>
    33b0:	xor    rax,rax
    33b3:	mov    rbx,QWORD PTR [rsp+0x30]
    33b8:	mov    r12,QWORD PTR [rsp+0x38]
    33bd:	mov    r13,QWORD PTR [rsp+0x40]
    33c2:	mov    r14,QWORD PTR [rsp+0x48]
    33c7:	mov    r15,QWORD PTR [rsp+0x50]
    33cc:	add    rsp,0x60
    33d0:	mov    rsp,rbp
    33d3:	pop    rbp
    33d4:	ret
    33d5:	mov    rcx,rax
    33d8:	and    rcx,rbx
    33db:	mov    rsi,rax
    33de:	test   rcx,0x1
    33e5:	jne    340e <botlish_fn_26+0x25e>
    33eb:	mov    rdx,rbx
    33ee:	mov    rdi,r14
    33f1:	call   33f6 <botlish_fn_26+0x246>
			33f2: R_X86_64_PLT32	rt_int_cmp-0x4
    33f6:	mov    ecx,0x2
    33fb:	test   rax,rax
    33fe:	mov    rax,rcx
    3401:	cmove  rax,QWORD PTR [rip+0x4f]        # 3458 <botlish_fn_26+0x2a8>
    3409:	jmp    3435 <botlish_fn_26+0x285>
    340e:	mov    rdx,rbx
    3411:	mov    eax,0x2
    3416:	cmp    rsi,rdx
    3419:	cmove  rax,QWORD PTR [rip+0x37]        # 3458 <botlish_fn_26+0x2a8>
    3421:	jmp    3435 <botlish_fn_26+0x285>
    3426:	mov    eax,0x2
    342b:	jmp    3435 <botlish_fn_26+0x285>
    3430:	mov    eax,0x2
    3435:	mov    rbx,QWORD PTR [rsp+0x30]
    343a:	mov    r12,QWORD PTR [rsp+0x38]
    343f:	mov    r13,QWORD PTR [rsp+0x40]
    3444:	mov    r14,QWORD PTR [rsp+0x48]
    3449:	mov    r15,QWORD PTR [rsp+0x50]
    344e:	add    rsp,0x60
    3452:	mov    rsp,rbp
    3455:	pop    rbp
    3456:	ret
    3457:	add    BYTE PTR [rsi],al
    3459:	add    BYTE PTR [rax],al
    345b:	add    BYTE PTR [rax],al
    345d:	add    BYTE PTR [rax],al
	...

0000000000003460 <botlish_entry_26: <generic>>:
    3460:	push   rbp
    3461:	mov    rbp,rsp
    3464:	mov    rsi,QWORD PTR [rdx]
    3467:	call   346c <botlish_entry_26+0xc>
			3468: R_X86_64_PLT32	botlish_fn_26-0x4 ; <generic>
    346c:	mov    rsp,rbp
    346f:	pop    rbp
    3470:	ret

0000000000003471 <botlish_fn_27: char_at<generic>>:
    3471:	push   rbp
    3472:	mov    rbp,rsp
    3475:	sub    rsp,0x50
    3479:	mov    QWORD PTR [rsp+0x20],rbx
    347e:	mov    QWORD PTR [rsp+0x28],r12
    3483:	mov    QWORD PTR [rsp+0x30],r13
    3488:	mov    QWORD PTR [rsp+0x38],r14
    348d:	mov    QWORD PTR [rsp+0x40],r15
    3492:	mov    r14,rcx
    3495:	mov    QWORD PTR [rsp],rsi
    3499:	mov    QWORD PTR [rsp+0x8],rdx
    349e:	mov    r13,rdx
    34a1:	mov    QWORD PTR [rsp+0x10],0x3
    34aa:	mov    r9d,0x1
    34b0:	test   rsi,0x1
    34b7:	jne    34d7 <botlish_fn_27+0x66>
    34bd:	xor    r9d,r9d
    34c0:	test   rsi,0x7
    34c7:	jne    34d7 <botlish_fn_27+0x66>
    34cd:	movzx  rax,BYTE PTR [rsi]
    34d1:	cmp    al,0x1
    34d3:	sete   r9b
    34d7:	test   r9b,r9b
    34da:	jne    34f8 <botlish_fn_27+0x87>
    34e0:	mov    rax,QWORD PTR [rdi+0x10]
    34e4:	mov    rcx,QWORD PTR [rax+0x118]
    34eb:	xor    rdx,rdx
    34ee:	call   34f3 <botlish_fn_27+0x82>
			34ef: R_X86_64_PLT32	rt_type_error-0x4
    34f3:	jmp    35b5 <botlish_fn_27+0x144>
    34f8:	mov    r12,rdi
    34fb:	test   rsi,0x1
    3502:	jne    3510 <botlish_fn_27+0x9f>
    3508:	mov    rbx,rsi
    350b:	jmp    352d <botlish_fn_27+0xbc>
    3510:	mov    rax,rsi
    3513:	add    rax,0x2
    3517:	mov    rbx,rsi
    351a:	seto   cl
    351d:	test   cl,cl
    351f:	jne    352d <botlish_fn_27+0xbc>
    3525:	mov    r15,rax
    3528:	jmp    3540 <botlish_fn_27+0xcf>
    352d:	mov    edx,0x3
    3532:	mov    rsi,rbx
    3535:	mov    rdi,r12
    3538:	call   353d <botlish_fn_27+0xcc>
			3539: R_X86_64_PLT32	rt_int_add-0x4
    353d:	mov    r15,rax
    3540:	mov    ecx,0x1
    3545:	mov    rsi,rbx
    3548:	test   rsi,0x1
    354f:	jne    3575 <botlish_fn_27+0x104>
    3555:	xor    ecx,ecx
    3557:	mov    rsi,rbx
    355a:	test   rsi,0x7
    3561:	jne    3575 <botlish_fn_27+0x104>
    3567:	mov    rsi,rbx
    356a:	movzx  rcx,BYTE PTR [rsi]
    356e:	rex cmp cl,0x1
    3572:	sete   cl
    3575:	test   cl,cl
    3577:	jne    359b <botlish_fn_27+0x12a>
    357d:	mov    rdi,r12
    3580:	mov    rsi,QWORD PTR [rdi+0x10]
    3584:	mov    rcx,QWORD PTR [rsi+0x120]
    358b:	xor    rdx,rdx
    358e:	mov    rsi,rbx
    3591:	call   3596 <botlish_fn_27+0x125>
			3592: R_X86_64_PLT32	rt_type_error-0x4
    3596:	jmp    35b5 <botlish_fn_27+0x144>
    359b:	mov    rdi,r12
    359e:	mov    rcx,r15
    35a1:	mov    rdx,rbx
    35a4:	mov    rsi,r13
    35a7:	call   35ac <botlish_fn_27+0x13b>
			35a8: R_X86_64_PLT32	rt_str_region_check-0x4
    35ac:	test   rax,rax
    35af:	jne    35da <botlish_fn_27+0x169>
    35b5:	xor    rax,rax
    35b8:	mov    rbx,QWORD PTR [rsp+0x20]
    35bd:	mov    r12,QWORD PTR [rsp+0x28]
    35c2:	mov    r13,QWORD PTR [rsp+0x30]
    35c7:	mov    r14,QWORD PTR [rsp+0x38]
    35cc:	mov    r15,QWORD PTR [rsp+0x40]
    35d1:	add    rsp,0x50
    35d5:	mov    rsp,rbp
    35d8:	pop    rbp
    35d9:	ret
    35da:	mov    rcx,r14
    35dd:	mov    rsi,rbx
    35e0:	mov    QWORD PTR [rcx],rsi
    35e3:	mov    rax,r15
    35e6:	mov    QWORD PTR [rcx+0x8],rax
    35ea:	mov    rax,r13
    35ed:	mov    rbx,QWORD PTR [rsp+0x20]
    35f2:	mov    r12,QWORD PTR [rsp+0x28]
    35f7:	mov    r13,QWORD PTR [rsp+0x30]
    35fc:	mov    r14,QWORD PTR [rsp+0x38]
    3601:	mov    r15,QWORD PTR [rsp+0x40]
    3606:	add    rsp,0x50
    360a:	mov    rsp,rbp
    360d:	pop    rbp
    360e:	ret

000000000000360f <botlish_entry_27: char_at<generic>>:
    360f:	push   rbp
    3610:	mov    rbp,rsp
    3613:	ud2
    3615:	add    BYTE PTR [rax],al
	...

0000000000003618 <botlish_fn_28: scan_local<generic>>:
    3618:	push   rbp
    3619:	mov    rbp,rsp
    361c:	sub    rsp,0x80
    3623:	mov    QWORD PTR [rsp+0x50],rbx
    3628:	mov    QWORD PTR [rsp+0x58],r12
    362d:	mov    QWORD PTR [rsp+0x60],r13
    3632:	mov    QWORD PTR [rsp+0x68],r14
    3637:	mov    QWORD PTR [rsp+0x70],r15
    363c:	mov    rax,rdi
    363f:	mov    QWORD PTR [rsp+0x18],0x0
    3648:	mov    QWORD PTR [rsp],rsi
    364c:	mov    r14,rsi
    364f:	mov    QWORD PTR [rsp+0x8],rdx
    3654:	mov    QWORD PTR [rsp+0x10],rcx
    3659:	mov    r12,rcx
    365c:	mov    r11d,0x1
    3662:	mov    rsi,r14
    3665:	test   rsi,0x1
    366c:	jne    368e <botlish_fn_28+0x76>
    3672:	xor    r11d,r11d
    3675:	test   rsi,0x7
    367c:	jne    368e <botlish_fn_28+0x76>
    3682:	movzx  rdi,BYTE PTR [rsi]
    3686:	cmp    dil,0x1
    368a:	sete   r11b
    368e:	test   r11b,r11b
    3691:	jne    36b2 <botlish_fn_28+0x9a>
    3697:	mov    rdi,rax
    369a:	mov    r9,QWORD PTR [rdi+0x10]
    369e:	mov    rcx,QWORD PTR [r9+0xa8]
    36a5:	xor    rdx,rdx
    36a8:	call   36ad <botlish_fn_28+0x95>
			36a9: R_X86_64_PLT32	rt_type_error-0x4
    36ad:	jmp    3765 <botlish_fn_28+0x14d>
    36b2:	mov    r13,rdx
    36b5:	mov    r10,rsi
    36b8:	and    r10,r13
    36bb:	mov    r14,rsi
    36be:	test   r10,0x1
    36c5:	jne    36f1 <botlish_fn_28+0xd9>
    36cb:	mov    rbx,rax
    36ce:	mov    rdx,r13
    36d1:	mov    rsi,r14
    36d4:	mov    rdi,rbx
    36d7:	call   36dc <botlish_fn_28+0xc4>
			36d8: R_X86_64_PLT32	rt_int_cmp-0x4
    36dc:	mov    ecx,0x2
    36e1:	test   rax,rax
    36e4:	cmovge rcx,QWORD PTR [rip+0x24c]        # 3938 <botlish_fn_28+0x320>
    36ec:	jmp    3707 <botlish_fn_28+0xef>
    36f1:	mov    rbx,rax
    36f4:	mov    ecx,0x2
    36f9:	mov    rsi,r14
    36fc:	cmp    rsi,r13
    36ff:	cmovge rcx,QWORD PTR [rip+0x231]        # 3938 <botlish_fn_28+0x320>
    3707:	mov    eax,0x6
    370c:	mov    QWORD PTR [rsp+0x30],rax
    3711:	cmp    rcx,0x6
    3715:	je     390b <botlish_fn_28+0x2f3>
    371b:	lea    rcx,[rsp+0x20]
    3720:	mov    rdx,r12
    3723:	mov    rsi,r14
    3726:	mov    rdi,rbx
    3729:	call   372e <botlish_fn_28+0x116>
			372a: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    372e:	mov    rsi,rax
    3731:	mov    r15,rax
    3734:	test   rax,rsi
    3737:	je     3765 <botlish_fn_28+0x14d>
    373d:	mov    rdx,QWORD PTR [rsp+0x20]
    3742:	mov    QWORD PTR [rsp+0x40],rdx
    3747:	mov    rcx,QWORD PTR [rsp+0x28]
    374c:	mov    QWORD PTR [rsp+0x38],rcx
    3751:	mov    rsi,r15
    3754:	mov    rdi,rbx
    3757:	call   375c <botlish_fn_28+0x144>
			3758: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    375c:	test   rax,rax
    375f:	jne    378d <botlish_fn_28+0x175>
    3765:	xor    rax,rax
    3768:	mov    rbx,QWORD PTR [rsp+0x50]
    376d:	mov    r12,QWORD PTR [rsp+0x58]
    3772:	mov    r13,QWORD PTR [rsp+0x60]
    3777:	mov    r14,QWORD PTR [rsp+0x68]
    377c:	mov    r15,QWORD PTR [rsp+0x70]
    3781:	add    rsp,0x80
    3788:	mov    rsp,rbp
    378b:	pop    rbp
    378c:	ret
    378d:	cmp    rax,0x6
    3791:	je     388c <botlish_fn_28+0x274>
    3797:	mov    rax,QWORD PTR [rbx+0x10]
    379b:	mov    r8,QWORD PTR [rax+0x128]
    37a2:	mov    rcx,QWORD PTR [rsp+0x38]
    37a7:	mov    rdx,QWORD PTR [rsp+0x40]
    37ac:	mov    rsi,r15
    37af:	mov    rdi,rbx
    37b2:	call   37b7 <botlish_fn_28+0x19f>
			37b3: R_X86_64_PLT32	rt_str_region_eq-0x4
    37b7:	cmp    rax,0x6
    37bb:	je     3882 <botlish_fn_28+0x26a>
    37c1:	mov    rax,QWORD PTR [rbx+0x10]
    37c5:	mov    r8,QWORD PTR [rax+0x130]
    37cc:	mov    rcx,QWORD PTR [rsp+0x38]
    37d1:	mov    rdx,QWORD PTR [rsp+0x40]
    37d6:	mov    rsi,r15
    37d9:	mov    rdi,rbx
    37dc:	call   37e1 <botlish_fn_28+0x1c9>
			37dd: R_X86_64_PLT32	rt_str_region_eq-0x4
    37e1:	cmp    rax,0x6
    37e5:	je     3878 <botlish_fn_28+0x260>
    37eb:	mov    rax,QWORD PTR [rbx+0x10]
    37ef:	mov    r8,QWORD PTR [rax+0xd0]
    37f6:	mov    rcx,QWORD PTR [rsp+0x38]
    37fb:	mov    rdx,QWORD PTR [rsp+0x40]
    3800:	mov    rsi,r15
    3803:	mov    rdi,rbx
    3806:	call   380b <botlish_fn_28+0x1f3>
			3807: R_X86_64_PLT32	rt_str_region_eq-0x4
    380b:	cmp    rax,0x6
    380f:	je     386e <botlish_fn_28+0x256>
    3815:	mov    rax,QWORD PTR [rbx+0x10]
    3819:	mov    r8,QWORD PTR [rax+0x118]
    3820:	mov    rcx,QWORD PTR [rsp+0x38]
    3825:	mov    rdx,QWORD PTR [rsp+0x40]
    382a:	mov    rsi,r15
    382d:	mov    rdi,rbx
    3830:	call   3835 <botlish_fn_28+0x21d>
			3831: R_X86_64_PLT32	rt_str_region_eq-0x4
    3835:	cmp    rax,0x6
    3839:	je     3864 <botlish_fn_28+0x24c>
    383f:	mov    rax,QWORD PTR [rbx+0x10]
    3843:	mov    r8,QWORD PTR [rax+0x138]
    384a:	mov    rcx,QWORD PTR [rsp+0x38]
    384f:	mov    rdx,QWORD PTR [rsp+0x40]
    3854:	mov    rsi,r15
    3857:	mov    rdi,rbx
    385a:	call   385f <botlish_fn_28+0x247>
			385b: R_X86_64_PLT32	rt_str_region_eq-0x4
    385f:	jmp    3891 <botlish_fn_28+0x279>
    3864:	mov    rax,QWORD PTR [rsp+0x30]
    3869:	jmp    3891 <botlish_fn_28+0x279>
    386e:	mov    rax,QWORD PTR [rsp+0x30]
    3873:	jmp    3891 <botlish_fn_28+0x279>
    3878:	mov    rax,QWORD PTR [rsp+0x30]
    387d:	jmp    3891 <botlish_fn_28+0x279>
    3882:	mov    rax,QWORD PTR [rsp+0x30]
    3887:	jmp    3891 <botlish_fn_28+0x279>
    388c:	mov    rax,QWORD PTR [rsp+0x30]
    3891:	cmp    rax,0x6
    3895:	je     38a3 <botlish_fn_28+0x28b>
    389b:	mov    rax,r14
    389e:	jmp    390e <botlish_fn_28+0x2f6>
    38a3:	mov    QWORD PTR [rsp+0x18],0x3
    38ac:	mov    rsi,r14
    38af:	test   rsi,0x1
    38b6:	je     38dc <botlish_fn_28+0x2c4>
    38bc:	mov    rsi,r14
    38bf:	mov    rax,rsi
    38c2:	add    rax,0x2
    38c6:	seto   cl
    38c9:	test   cl,cl
    38cb:	jne    38dc <botlish_fn_28+0x2c4>
    38d1:	mov    rsi,rax
    38d4:	mov    r14,rax
    38d7:	jmp    38f2 <botlish_fn_28+0x2da>
    38dc:	mov    edx,0x3
    38e1:	mov    rsi,r14
    38e4:	mov    rdi,rbx
    38e7:	call   38ec <botlish_fn_28+0x2d4>
			38e8: R_X86_64_PLT32	rt_int_add-0x4
    38ec:	mov    rsi,rax
    38ef:	mov    r14,rax
    38f2:	mov    QWORD PTR [rsp],rsi
    38f6:	mov    QWORD PTR [rsp+0x8],r13
    38fb:	mov    QWORD PTR [rsp+0x10],r12
    3900:	mov    rax,rbx
    3903:	mov    rdx,r13
    3906:	jmp    365c <botlish_fn_28+0x44>
    390b:	mov    rax,r14
    390e:	mov    rbx,QWORD PTR [rsp+0x50]
    3913:	mov    r12,QWORD PTR [rsp+0x58]
    3918:	mov    r13,QWORD PTR [rsp+0x60]
    391d:	mov    r14,QWORD PTR [rsp+0x68]
    3922:	mov    r15,QWORD PTR [rsp+0x70]
    3927:	add    rsp,0x80
    392e:	mov    rsp,rbp
    3931:	pop    rbp
    3932:	ret
    3933:	add    BYTE PTR [rax],al
    3935:	add    BYTE PTR [rax],al
    3937:	add    BYTE PTR [rsi],al
    3939:	add    BYTE PTR [rax],al
    393b:	add    BYTE PTR [rax],al
    393d:	add    BYTE PTR [rax],al
	...

0000000000003940 <botlish_entry_28: scan_local<generic>>:
    3940:	push   rbp
    3941:	mov    rbp,rsp
    3944:	mov    rsi,QWORD PTR [rdx]
    3947:	mov    r8,QWORD PTR [rdx+0x8]
    394b:	mov    rcx,QWORD PTR [rdx+0x10]
    394f:	mov    rdx,r8
    3952:	call   3957 <botlish_entry_28+0x17>
			3953: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_local<generic>
    3957:	mov    rsp,rbp
    395a:	pop    rbp
    395b:	ret
    395c:	add    BYTE PTR [rax],al
	...

0000000000003960 <botlish_fn_29: scan_label<generic>>:
    3960:	push   rbp
    3961:	mov    rbp,rsp
    3964:	sub    rsp,0x80
    396b:	mov    QWORD PTR [rsp+0x50],rbx
    3970:	mov    QWORD PTR [rsp+0x58],r12
    3975:	mov    QWORD PTR [rsp+0x60],r13
    397a:	mov    QWORD PTR [rsp+0x68],r14
    397f:	mov    QWORD PTR [rsp+0x70],r15
    3984:	mov    QWORD PTR [rsp+0x18],0x0
    398d:	mov    QWORD PTR [rsp],rsi
    3991:	mov    r14,rsi
    3994:	mov    QWORD PTR [rsp+0x8],rdx
    3999:	mov    QWORD PTR [rsp+0x10],rcx
    399e:	mov    r12,rcx
    39a1:	mov    r11d,0x1
    39a7:	mov    rsi,r14
    39aa:	test   rsi,0x1
    39b1:	jne    39d1 <botlish_fn_29+0x71>
    39b7:	xor    r11d,r11d
    39ba:	test   rsi,0x7
    39c1:	jne    39d1 <botlish_fn_29+0x71>
    39c7:	movzx  rax,BYTE PTR [rsi]
    39cb:	cmp    al,0x1
    39cd:	sete   r11b
    39d1:	test   r11b,r11b
    39d4:	jne    39f2 <botlish_fn_29+0x92>
    39da:	mov    rax,QWORD PTR [rdi+0x10]
    39de:	mov    rcx,QWORD PTR [rax+0xa8]
    39e5:	xor    rdx,rdx
    39e8:	call   39ed <botlish_fn_29+0x8d>
			39e9: R_X86_64_PLT32	rt_type_error-0x4
    39ed:	jmp    3a9e <botlish_fn_29+0x13e>
    39f2:	mov    r13,rdx
    39f5:	mov    rax,rsi
    39f8:	and    rax,r13
    39fb:	mov    r14,rsi
    39fe:	test   rax,0x1
    3a04:	jne    3a2d <botlish_fn_29+0xcd>
    3a0a:	mov    rbx,rdi
    3a0d:	mov    rdx,r13
    3a10:	mov    rsi,r14
    3a13:	call   3a18 <botlish_fn_29+0xb8>
			3a14: R_X86_64_PLT32	rt_int_cmp-0x4
    3a18:	mov    ecx,0x2
    3a1d:	test   rax,rax
    3a20:	cmovge rcx,QWORD PTR [rip+0x178]        # 3ba0 <botlish_fn_29+0x240>
    3a28:	jmp    3a43 <botlish_fn_29+0xe3>
    3a2d:	mov    rbx,rdi
    3a30:	mov    ecx,0x2
    3a35:	mov    rsi,r14
    3a38:	cmp    rsi,r13
    3a3b:	cmovge rcx,QWORD PTR [rip+0x15d]        # 3ba0 <botlish_fn_29+0x240>
    3a43:	mov    eax,0x6
    3a48:	mov    QWORD PTR [rsp+0x30],rax
    3a4d:	cmp    rcx,0x6
    3a51:	je     3b74 <botlish_fn_29+0x214>
    3a57:	lea    rcx,[rsp+0x20]
    3a5c:	mov    rdx,r12
    3a5f:	mov    rsi,r14
    3a62:	mov    rdi,rbx
    3a65:	call   3a6a <botlish_fn_29+0x10a>
			3a66: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    3a6a:	test   rax,rax
    3a6d:	mov    r15,rax
    3a70:	je     3a9e <botlish_fn_29+0x13e>
    3a76:	mov    rdx,QWORD PTR [rsp+0x20]
    3a7b:	mov    QWORD PTR [rsp+0x40],rdx
    3a80:	mov    rcx,QWORD PTR [rsp+0x28]
    3a85:	mov    QWORD PTR [rsp+0x38],rcx
    3a8a:	mov    rsi,r15
    3a8d:	mov    rdi,rbx
    3a90:	call   3a95 <botlish_fn_29+0x135>
			3a91: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    3a95:	test   rax,rax
    3a98:	jne    3ac6 <botlish_fn_29+0x166>
    3a9e:	xor    rax,rax
    3aa1:	mov    rbx,QWORD PTR [rsp+0x50]
    3aa6:	mov    r12,QWORD PTR [rsp+0x58]
    3aab:	mov    r13,QWORD PTR [rsp+0x60]
    3ab0:	mov    r14,QWORD PTR [rsp+0x68]
    3ab5:	mov    r15,QWORD PTR [rsp+0x70]
    3aba:	add    rsp,0x80
    3ac1:	mov    rsp,rbp
    3ac4:	pop    rbp
    3ac5:	ret
    3ac6:	cmp    rax,0x6
    3aca:	je     3af5 <botlish_fn_29+0x195>
    3ad0:	mov    r11,QWORD PTR [rbx+0x10]
    3ad4:	mov    r8,QWORD PTR [r11+0x138]
    3adb:	mov    rcx,QWORD PTR [rsp+0x38]
    3ae0:	mov    rdx,QWORD PTR [rsp+0x40]
    3ae5:	mov    rsi,r15
    3ae8:	mov    rdi,rbx
    3aeb:	call   3af0 <botlish_fn_29+0x190>
			3aec: R_X86_64_PLT32	rt_str_region_eq-0x4
    3af0:	jmp    3afa <botlish_fn_29+0x19a>
    3af5:	mov    rax,QWORD PTR [rsp+0x30]
    3afa:	cmp    rax,0x6
    3afe:	je     3b0c <botlish_fn_29+0x1ac>
    3b04:	mov    rax,r14
    3b07:	jmp    3b77 <botlish_fn_29+0x217>
    3b0c:	mov    QWORD PTR [rsp+0x18],0x3
    3b15:	mov    rsi,r14
    3b18:	test   rsi,0x1
    3b1f:	je     3b45 <botlish_fn_29+0x1e5>
    3b25:	mov    rsi,r14
    3b28:	mov    rax,rsi
    3b2b:	add    rax,0x2
    3b2f:	seto   cl
    3b32:	test   cl,cl
    3b34:	jne    3b45 <botlish_fn_29+0x1e5>
    3b3a:	mov    rsi,rax
    3b3d:	mov    r14,rax
    3b40:	jmp    3b5b <botlish_fn_29+0x1fb>
    3b45:	mov    edx,0x3
    3b4a:	mov    rsi,r14
    3b4d:	mov    rdi,rbx
    3b50:	call   3b55 <botlish_fn_29+0x1f5>
			3b51: R_X86_64_PLT32	rt_int_add-0x4
    3b55:	mov    rsi,rax
    3b58:	mov    r14,rax
    3b5b:	mov    QWORD PTR [rsp],rsi
    3b5f:	mov    QWORD PTR [rsp+0x8],r13
    3b64:	mov    QWORD PTR [rsp+0x10],r12
    3b69:	mov    rdx,r13
    3b6c:	mov    rdi,rbx
    3b6f:	jmp    39a1 <botlish_fn_29+0x41>
    3b74:	mov    rax,r14
    3b77:	mov    rbx,QWORD PTR [rsp+0x50]
    3b7c:	mov    r12,QWORD PTR [rsp+0x58]
    3b81:	mov    r13,QWORD PTR [rsp+0x60]
    3b86:	mov    r14,QWORD PTR [rsp+0x68]
    3b8b:	mov    r15,QWORD PTR [rsp+0x70]
    3b90:	add    rsp,0x80
    3b97:	mov    rsp,rbp
    3b9a:	pop    rbp
    3b9b:	ret
    3b9c:	add    BYTE PTR [rax],al
    3b9e:	add    BYTE PTR [rax],al
    3ba0:	(bad)
    3ba1:	add    BYTE PTR [rax],al
    3ba3:	add    BYTE PTR [rax],al
    3ba5:	add    BYTE PTR [rax],al
	...

0000000000003ba8 <botlish_entry_29: scan_label<generic>>:
    3ba8:	push   rbp
    3ba9:	mov    rbp,rsp
    3bac:	mov    rsi,QWORD PTR [rdx]
    3baf:	mov    r8,QWORD PTR [rdx+0x8]
    3bb3:	mov    rcx,QWORD PTR [rdx+0x10]
    3bb7:	mov    rdx,r8
    3bba:	call   3bbf <botlish_entry_29+0x17>
			3bbb: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_label<generic>
    3bbf:	mov    rsp,rbp
    3bc2:	pop    rbp
    3bc3:	ret
    3bc4:	add    BYTE PTR [rax],al
	...

0000000000003bc8 <botlish_fn_30: scan_alpha<generic>>:
    3bc8:	push   rbp
    3bc9:	mov    rbp,rsp
    3bcc:	sub    rsp,0x50
    3bd0:	mov    QWORD PTR [rsp+0x30],rbx
    3bd5:	mov    QWORD PTR [rsp+0x38],r12
    3bda:	mov    QWORD PTR [rsp+0x40],r13
    3bdf:	mov    QWORD PTR [rsp+0x48],r14
    3be4:	mov    r14,rdi
    3be7:	mov    QWORD PTR [rsp+0x18],0x0
    3bf0:	mov    QWORD PTR [rsp],rsi
    3bf4:	mov    r13,rsi
    3bf7:	mov    QWORD PTR [rsp+0x8],rdx
    3bfc:	mov    r12,rdx
    3bff:	mov    QWORD PTR [rsp+0x10],rcx
    3c04:	mov    rbx,rcx
    3c07:	mov    r11d,0x1
    3c0d:	mov    rsi,r13
    3c10:	test   rsi,0x1
    3c17:	jne    3c37 <botlish_fn_30+0x6f>
    3c1d:	xor    r11d,r11d
    3c20:	test   rsi,0x7
    3c27:	jne    3c37 <botlish_fn_30+0x6f>
    3c2d:	movzx  rax,BYTE PTR [rsi]
    3c31:	cmp    al,0x1
    3c33:	sete   r11b
    3c37:	test   r11b,r11b
    3c3a:	jne    3c5b <botlish_fn_30+0x93>
    3c40:	mov    rdi,r14
    3c43:	mov    rax,QWORD PTR [rdi+0x10]
    3c47:	mov    rcx,QWORD PTR [rax+0xa8]
    3c4e:	xor    rdx,rdx
    3c51:	call   3c56 <botlish_fn_30+0x8e>
			3c52: R_X86_64_PLT32	rt_type_error-0x4
    3c56:	jmp    3cea <botlish_fn_30+0x122>
    3c5b:	mov    rax,rsi
    3c5e:	and    rax,r12
    3c61:	mov    r13,rsi
    3c64:	test   rax,0x1
    3c6a:	jne    3c93 <botlish_fn_30+0xcb>
    3c70:	mov    rdx,r12
    3c73:	mov    rsi,r13
    3c76:	mov    rdi,r14
    3c79:	call   3c7e <botlish_fn_30+0xb6>
			3c7a: R_X86_64_PLT32	rt_int_cmp-0x4
    3c7e:	mov    ecx,0x2
    3c83:	test   rax,rax
    3c86:	cmovge rcx,QWORD PTR [rip+0x112]        # 3da0 <botlish_fn_30+0x1d8>
    3c8e:	jmp    3ca6 <botlish_fn_30+0xde>
    3c93:	mov    ecx,0x2
    3c98:	mov    rsi,r13
    3c9b:	cmp    rsi,r12
    3c9e:	cmovge rcx,QWORD PTR [rip+0xfa]        # 3da0 <botlish_fn_30+0x1d8>
    3ca6:	cmp    rcx,0x6
    3caa:	je     3d7e <botlish_fn_30+0x1b6>
    3cb0:	lea    rcx,[rsp+0x20]
    3cb5:	mov    rdx,rbx
    3cb8:	mov    rsi,r13
    3cbb:	mov    rdi,r14
    3cbe:	call   3cc3 <botlish_fn_30+0xfb>
			3cbf: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    3cc3:	test   rax,rax
    3cc6:	mov    rsi,rax
    3cc9:	je     3cea <botlish_fn_30+0x122>
    3ccf:	mov    rdx,QWORD PTR [rsp+0x20]
    3cd4:	mov    rcx,QWORD PTR [rsp+0x28]
    3cd9:	mov    rdi,r14
    3cdc:	call   3ce1 <botlish_fn_30+0x119>
			3cdd: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    3ce1:	test   rax,rax
    3ce4:	jne    3d0a <botlish_fn_30+0x142>
    3cea:	xor    rax,rax
    3ced:	mov    rbx,QWORD PTR [rsp+0x30]
    3cf2:	mov    r12,QWORD PTR [rsp+0x38]
    3cf7:	mov    r13,QWORD PTR [rsp+0x40]
    3cfc:	mov    r14,QWORD PTR [rsp+0x48]
    3d01:	add    rsp,0x50
    3d05:	mov    rsp,rbp
    3d08:	pop    rbp
    3d09:	ret
    3d0a:	cmp    rax,0x6
    3d0e:	je     3d1c <botlish_fn_30+0x154>
    3d14:	mov    rax,r13
    3d17:	jmp    3d81 <botlish_fn_30+0x1b9>
    3d1c:	mov    QWORD PTR [rsp+0x18],0x3
    3d25:	mov    rsi,r13
    3d28:	test   rsi,0x1
    3d2f:	je     3d55 <botlish_fn_30+0x18d>
    3d35:	mov    rsi,r13
    3d38:	mov    r11,rsi
    3d3b:	add    r11,0x2
    3d3f:	seto   al
    3d42:	test   al,al
    3d44:	jne    3d55 <botlish_fn_30+0x18d>
    3d4a:	mov    rsi,r11
    3d4d:	mov    r13,r11
    3d50:	jmp    3d6b <botlish_fn_30+0x1a3>
    3d55:	mov    edx,0x3
    3d5a:	mov    rsi,r13
    3d5d:	mov    rdi,r14
    3d60:	call   3d65 <botlish_fn_30+0x19d>
			3d61: R_X86_64_PLT32	rt_int_add-0x4
    3d65:	mov    rsi,rax
    3d68:	mov    r13,rax
    3d6b:	mov    QWORD PTR [rsp],rsi
    3d6f:	mov    QWORD PTR [rsp+0x8],r12
    3d74:	mov    QWORD PTR [rsp+0x10],rbx
    3d79:	jmp    3c07 <botlish_fn_30+0x3f>
    3d7e:	mov    rax,r13
    3d81:	mov    rbx,QWORD PTR [rsp+0x30]
    3d86:	mov    r12,QWORD PTR [rsp+0x38]
    3d8b:	mov    r13,QWORD PTR [rsp+0x40]
    3d90:	mov    r14,QWORD PTR [rsp+0x48]
    3d95:	add    rsp,0x50
    3d99:	mov    rsp,rbp
    3d9c:	pop    rbp
    3d9d:	ret
    3d9e:	add    BYTE PTR [rax],al
    3da0:	(bad)
    3da1:	add    BYTE PTR [rax],al
    3da3:	add    BYTE PTR [rax],al
    3da5:	add    BYTE PTR [rax],al
	...

0000000000003da8 <botlish_entry_30: scan_alpha<generic>>:
    3da8:	push   rbp
    3da9:	mov    rbp,rsp
    3dac:	mov    rsi,QWORD PTR [rdx]
    3daf:	mov    r8,QWORD PTR [rdx+0x8]
    3db3:	mov    rcx,QWORD PTR [rdx+0x10]
    3db7:	mov    rdx,r8
    3dba:	call   3dbf <botlish_entry_30+0x17>
			3dbb: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_alpha<generic>
    3dbf:	mov    rsp,rbp
    3dc2:	pop    rbp
    3dc3:	ret
    3dc4:	add    BYTE PTR [rax],al
	...

0000000000003dc8 <botlish_fn_31: tld_ok<generic>>:
    3dc8:	push   rbp
    3dc9:	mov    rbp,rsp
    3dcc:	sub    rsp,0x40
    3dd0:	mov    QWORD PTR [rsp+0x20],rbx
    3dd5:	mov    QWORD PTR [rsp+0x28],r12
    3dda:	mov    QWORD PTR [rsp+0x30],r13
    3ddf:	mov    QWORD PTR [rsp+0x38],r14
    3de4:	mov    rbx,rdi
    3de7:	mov    QWORD PTR [rsp],rsi
    3deb:	mov    r12,rsi
    3dee:	mov    QWORD PTR [rsp+0x8],rdx
    3df3:	mov    r14,rdx
    3df6:	mov    QWORD PTR [rsp+0x10],rcx
    3dfb:	mov    rdx,r14
    3dfe:	mov    rsi,r12
    3e01:	mov    rdi,rbx
    3e04:	call   3e09 <botlish_fn_31+0x41>
			3e05: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_alpha<generic>
    3e09:	mov    rsi,rax
    3e0c:	mov    r13,rax
    3e0f:	test   rax,rsi
    3e12:	je     3ed5 <botlish_fn_31+0x10d>
    3e18:	mov    rax,r13
    3e1b:	mov    QWORD PTR [rsp+0x8],rax
    3e20:	mov    rdx,r14
    3e23:	and    rax,rdx
    3e26:	test   rax,0x1
    3e2c:	jne    3e55 <botlish_fn_31+0x8d>
    3e32:	mov    rsi,r13
    3e35:	mov    rdi,rbx
    3e38:	call   3e3d <botlish_fn_31+0x75>
			3e39: R_X86_64_PLT32	rt_int_cmp-0x4
    3e3d:	mov    ecx,0x2
    3e42:	test   rax,rax
    3e45:	cmove  rcx,QWORD PTR [rip+0x15b]        # 3fa8 <botlish_fn_31+0x1e0>
    3e4d:	mov    rax,r13
    3e50:	jmp    3e68 <botlish_fn_31+0xa0>
    3e55:	mov    ecx,0x2
    3e5a:	mov    rax,r13
    3e5d:	cmp    rax,rdx
    3e60:	cmove  rcx,QWORD PTR [rip+0x140]        # 3fa8 <botlish_fn_31+0x1e0>
    3e68:	cmp    rcx,0x6
    3e6c:	je     3e7f <botlish_fn_31+0xb7>
    3e72:	mov    ecx,0x2
    3e77:	mov    rax,rcx
    3e7a:	jmp    3f87 <botlish_fn_31+0x1bf>
    3e7f:	mov    ecx,0x1
    3e84:	mov    rsi,r12
    3e87:	test   rsi,0x1
    3e8e:	jne    3eb4 <botlish_fn_31+0xec>
    3e94:	xor    ecx,ecx
    3e96:	mov    rsi,r12
    3e99:	test   rsi,0x7
    3ea0:	jne    3eb4 <botlish_fn_31+0xec>
    3ea6:	mov    rsi,r12
    3ea9:	movzx  rcx,BYTE PTR [rsi]
    3ead:	rex cmp cl,0x1
    3eb1:	sete   cl
    3eb4:	test   cl,cl
    3eb6:	jne    3ef5 <botlish_fn_31+0x12d>
    3ebc:	mov    rdi,rbx
    3ebf:	mov    rsi,QWORD PTR [rdi+0x10]
    3ec3:	mov    rcx,QWORD PTR [rsi+0x138]
    3eca:	xor    rdx,rdx
    3ecd:	mov    rsi,r12
    3ed0:	call   3ed5 <botlish_fn_31+0x10d>
			3ed1: R_X86_64_PLT32	rt_type_error-0x4
    3ed5:	xor    rax,rax
    3ed8:	mov    rbx,QWORD PTR [rsp+0x20]
    3edd:	mov    r12,QWORD PTR [rsp+0x28]
    3ee2:	mov    r13,QWORD PTR [rsp+0x30]
    3ee7:	mov    r14,QWORD PTR [rsp+0x38]
    3eec:	add    rsp,0x40
    3ef0:	mov    rsp,rbp
    3ef3:	pop    rbp
    3ef4:	ret
    3ef5:	mov    rsi,r12
    3ef8:	mov    rdi,rax
    3efb:	and    rdi,rsi
    3efe:	test   rdi,0x1
    3f05:	jne    3f16 <botlish_fn_31+0x14e>
    3f0b:	mov    rdx,r12
    3f0e:	mov    rsi,rax
    3f11:	jmp    3f39 <botlish_fn_31+0x171>
    3f16:	mov    rsi,r12
    3f19:	mov    r8,rax
    3f1c:	sub    r8,rsi
    3f1f:	mov    r13,rax
    3f22:	seto   r10b
    3f26:	lea    rsi,[r8+0x1]
    3f2a:	test   r10b,r10b
    3f2d:	je     3f44 <botlish_fn_31+0x17c>
    3f33:	mov    rdx,r12
    3f36:	mov    rsi,r13
    3f39:	mov    rdi,rbx
    3f3c:	call   3f41 <botlish_fn_31+0x179>
			3f3d: R_X86_64_PLT32	rt_int_sub-0x4
    3f41:	mov    rsi,rax
    3f44:	test   rsi,0x1
    3f4b:	jne    3f76 <botlish_fn_31+0x1ae>
    3f51:	mov    edx,0x5
    3f56:	mov    rdi,rbx
    3f59:	call   3f5e <botlish_fn_31+0x196>
			3f5a: R_X86_64_PLT32	rt_int_cmp-0x4
    3f5e:	mov    ecx,0x2
    3f63:	test   rax,rax
    3f66:	mov    rax,rcx
    3f69:	cmovge rax,QWORD PTR [rip+0x37]        # 3fa8 <botlish_fn_31+0x1e0>
    3f71:	jmp    3f87 <botlish_fn_31+0x1bf>
    3f76:	mov    eax,0x2
    3f7b:	cmp    rsi,0x5
    3f7f:	cmovge rax,QWORD PTR [rip+0x21]        # 3fa8 <botlish_fn_31+0x1e0>
    3f87:	mov    rbx,QWORD PTR [rsp+0x20]
    3f8c:	mov    r12,QWORD PTR [rsp+0x28]
    3f91:	mov    r13,QWORD PTR [rsp+0x30]
    3f96:	mov    r14,QWORD PTR [rsp+0x38]
    3f9b:	add    rsp,0x40
    3f9f:	mov    rsp,rbp
    3fa2:	pop    rbp
    3fa3:	ret
    3fa4:	add    BYTE PTR [rax],al
    3fa6:	add    BYTE PTR [rax],al
    3fa8:	(bad)
    3fa9:	add    BYTE PTR [rax],al
    3fab:	add    BYTE PTR [rax],al
    3fad:	add    BYTE PTR [rax],al
	...

0000000000003fb0 <botlish_entry_31: tld_ok<generic>>:
    3fb0:	push   rbp
    3fb1:	mov    rbp,rsp
    3fb4:	mov    rsi,QWORD PTR [rdx]
    3fb7:	mov    r8,QWORD PTR [rdx+0x8]
    3fbb:	mov    rcx,QWORD PTR [rdx+0x10]
    3fbf:	mov    rdx,r8
    3fc2:	call   3fc7 <botlish_entry_31+0x17>
			3fc3: R_X86_64_PLT32	botlish_fn_31-0x4 ; tld_ok<generic>
    3fc7:	mov    rsp,rbp
    3fca:	pop    rbp
    3fcb:	ret
    3fcc:	add    BYTE PTR [rax],al
	...

0000000000003fd0 <botlish_fn_32: domain_loop<generic>>:
    3fd0:	push   rbp
    3fd1:	mov    rbp,rsp
    3fd4:	sub    rsp,0x70
    3fd8:	mov    QWORD PTR [rsp+0x40],rbx
    3fdd:	mov    QWORD PTR [rsp+0x48],r12
    3fe2:	mov    QWORD PTR [rsp+0x50],r13
    3fe7:	mov    QWORD PTR [rsp+0x58],r14
    3fec:	mov    QWORD PTR [rsp+0x60],r15
    3ff1:	mov    QWORD PTR [rsp+0x18],0x0
    3ffa:	mov    QWORD PTR [rsp],rsi
    3ffe:	mov    QWORD PTR [rsp+0x8],rdx
    4003:	mov    QWORD PTR [rsp+0x10],rcx
    4008:	lea    rbx,[rsp+0x20]
    400d:	mov    r12,rdi
    4010:	mov    r13,rcx
    4013:	mov    r14,rdx
    4016:	mov    QWORD PTR [rsp+0x30],rsi
    401b:	mov    rcx,r13
    401e:	mov    rdx,r14
    4021:	mov    rsi,QWORD PTR [rsp+0x30]
    4026:	mov    rdi,r12
    4029:	call   402e <botlish_fn_32+0x5e>
			402a: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_label<generic>
    402e:	mov    rcx,rax
    4031:	mov    r15,rax
    4034:	test   rax,rcx
    4037:	je     4187 <botlish_fn_32+0x1b7>
    403d:	mov    rax,r15
    4040:	mov    QWORD PTR [rsp],rax
    4044:	mov    rdx,QWORD PTR [rsp+0x30]
    4049:	and    rax,rdx
    404c:	test   rax,0x1
    4052:	jne    4071 <botlish_fn_32+0xa1>
    4058:	mov    rsi,r15
    405b:	mov    rdi,r12
    405e:	call   4063 <botlish_fn_32+0x93>
			405f: R_X86_64_PLT32	rt_value_eq-0x4
    4063:	test   rax,rax
    4066:	je     4187 <botlish_fn_32+0x1b7>
    406c:	jmp    4081 <botlish_fn_32+0xb1>
    4071:	mov    eax,0x2
    4076:	cmp    r15,rdx
    4079:	cmove  rax,QWORD PTR [rip+0x187]        # 4208 <botlish_fn_32+0x238>
    4081:	cmp    rax,0x6
    4085:	je     41dd <botlish_fn_32+0x20d>
    408b:	mov    rax,r15
    408e:	and    rax,r14
    4091:	test   rax,0x1
    4097:	jne    40c0 <botlish_fn_32+0xf0>
    409d:	mov    rdx,r14
    40a0:	mov    rsi,r15
    40a3:	mov    rdi,r12
    40a6:	call   40ab <botlish_fn_32+0xdb>
			40a7: R_X86_64_PLT32	rt_int_cmp-0x4
    40ab:	mov    ecx,0x2
    40b0:	test   rax,rax
    40b3:	cmovge rcx,QWORD PTR [rip+0x14d]        # 4208 <botlish_fn_32+0x238>
    40bb:	jmp    40d0 <botlish_fn_32+0x100>
    40c0:	mov    ecx,0x2
    40c5:	cmp    r15,r14
    40c8:	cmovge rcx,QWORD PTR [rip+0x138]        # 4208 <botlish_fn_32+0x238>
    40d0:	cmp    rcx,0x6
    40d4:	je     41ce <botlish_fn_32+0x1fe>
    40da:	mov    rcx,rbx
    40dd:	mov    rdx,r13
    40e0:	mov    rsi,r15
    40e3:	mov    rdi,r12
    40e6:	call   40eb <botlish_fn_32+0x11b>
			40e7: R_X86_64_PLT32	botlish_fn_27-0x4 ; char_at<generic>
    40eb:	test   rax,rax
    40ee:	je     4187 <botlish_fn_32+0x1b7>
    40f4:	mov    rdx,QWORD PTR [rsp+0x20]
    40f9:	mov    rcx,QWORD PTR [rsp+0x28]
    40fe:	mov    rsi,QWORD PTR [r12+0x10]
    4103:	mov    r8,QWORD PTR [rsi+0x128]
    410a:	mov    rsi,rax
    410d:	mov    rdi,r12
    4110:	call   4115 <botlish_fn_32+0x145>
			4111: R_X86_64_PLT32	rt_str_region_eq-0x4
    4115:	cmp    rax,0x6
    4119:	je     412b <botlish_fn_32+0x15b>
    411f:	mov    r14,0xffffffffffffffff
    4126:	jmp    41d5 <botlish_fn_32+0x205>
    412b:	mov    QWORD PTR [rsp+0x18],0x3
    4134:	test   r15,0x1
    413b:	je     4153 <botlish_fn_32+0x183>
    4141:	mov    rdx,r15
    4144:	add    rdx,0x2
    4148:	seto   al
    414b:	test   al,al
    414d:	je     4166 <botlish_fn_32+0x196>
    4153:	mov    edx,0x3
    4158:	mov    rsi,r15
    415b:	mov    rdi,r12
    415e:	call   4163 <botlish_fn_32+0x193>
			415f: R_X86_64_PLT32	rt_int_add-0x4
    4163:	mov    rdx,rax
    4166:	mov    QWORD PTR [rsp],rdx
    416a:	mov    r15,rdx
    416d:	mov    rcx,r13
    4170:	mov    rdx,r14
    4173:	mov    rsi,r15
    4176:	mov    rdi,r12
    4179:	call   417e <botlish_fn_32+0x1ae>
			417a: R_X86_64_PLT32	botlish_fn_31-0x4 ; tld_ok<generic>
    417e:	test   rax,rax
    4181:	jne    41ac <botlish_fn_32+0x1dc>
    4187:	xor    rax,rax
    418a:	mov    rbx,QWORD PTR [rsp+0x40]
    418f:	mov    r12,QWORD PTR [rsp+0x48]
    4194:	mov    r13,QWORD PTR [rsp+0x50]
    4199:	mov    r14,QWORD PTR [rsp+0x58]
    419e:	mov    r15,QWORD PTR [rsp+0x60]
    41a3:	add    rsp,0x70
    41a7:	mov    rsp,rbp
    41aa:	pop    rbp
    41ab:	ret
    41ac:	cmp    rax,0x6
    41b0:	je     41d5 <botlish_fn_32+0x205>
    41b6:	mov    QWORD PTR [rsp],r15
    41ba:	mov    QWORD PTR [rsp+0x8],r14
    41bf:	mov    QWORD PTR [rsp+0x10],r13
    41c4:	mov    QWORD PTR [rsp+0x30],r15
    41c9:	jmp    401b <botlish_fn_32+0x4b>
    41ce:	mov    r14,0xffffffffffffffff
    41d5:	mov    rax,r14
    41d8:	jmp    41e4 <botlish_fn_32+0x214>
    41dd:	mov    rax,0xffffffffffffffff
    41e4:	mov    rbx,QWORD PTR [rsp+0x40]
    41e9:	mov    r12,QWORD PTR [rsp+0x48]
    41ee:	mov    r13,QWORD PTR [rsp+0x50]
    41f3:	mov    r14,QWORD PTR [rsp+0x58]
    41f8:	mov    r15,QWORD PTR [rsp+0x60]
    41fd:	add    rsp,0x70
    4201:	mov    rsp,rbp
    4204:	pop    rbp
    4205:	ret
    4206:	add    BYTE PTR [rax],al
    4208:	(bad)
    4209:	add    BYTE PTR [rax],al
    420b:	add    BYTE PTR [rax],al
    420d:	add    BYTE PTR [rax],al
	...

0000000000004210 <botlish_entry_32: domain_loop<generic>>:
    4210:	push   rbp
    4211:	mov    rbp,rsp
    4214:	mov    rsi,QWORD PTR [rdx]
    4217:	mov    r8,QWORD PTR [rdx+0x8]
    421b:	mov    rcx,QWORD PTR [rdx+0x10]
    421f:	mov    rdx,r8
    4222:	call   4227 <botlish_entry_32+0x17>
			4223: R_X86_64_PLT32	botlish_fn_32-0x4 ; domain_loop<generic>
    4227:	mov    rsp,rbp
    422a:	pop    rbp
    422b:	ret

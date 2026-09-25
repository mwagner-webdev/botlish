; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 18093  (per function: 1172 39 849 377 385 385 164 164 199 125 214 484 864 876 1004 504 681 769 450 884 644 540 540 636 681 769 450 884 644 540 540 636)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> char::codepoint<UnicodeChar>
;   botlish_fn_2 / botlish_entry_2 -> byte::set<List[UnicodeChar]>
;   botlish_fn_3 / botlish_entry_3 -> ascii::is_digit<generic>
;   botlish_fn_4 / botlish_entry_4 -> ascii::is_upper<generic>
;   botlish_fn_5 / botlish_entry_5 -> ascii::is_lower<generic>
;   botlish_fn_6 / botlish_entry_6 -> ascii::is_alphabetic<generic>
;   botlish_fn_7 / botlish_entry_7 -> ascii::is_alphanumeric<generic>
;   botlish_fn_8 / botlish_entry_8 -> web::is_unreserved<generic>
;   botlish_fn_9 / botlish_entry_9 -> web::uri_escape_text<generic>
;   botlish_fn_10 / botlish_entry_10 -> high_nibble<generic>
;   botlish_fn_11 / botlish_entry_11 -> hex_pair<generic>
;   botlish_fn_12 / botlish_entry_12 -> esc_bytes<generic>
;   botlish_fn_13 / botlish_entry_13 -> esc_char<generic>
;   botlish_fn_14 / botlish_entry_14 -> esc_from<generic>
;   botlish_fn_15 / botlish_entry_15 -> check<int, int, str, str>
;   botlish_fn_16 / botlish_entry_16 -> <str>
;   botlish_fn_17 / botlish_entry_17 -> <generic>
;   botlish_fn_18 / botlish_entry_18 -> char_at<generic>
;   botlish_fn_19 / botlish_entry_19 -> scan_local<generic>
;   botlish_fn_20 / botlish_entry_20 -> scan_label<generic>
;   botlish_fn_21 / botlish_entry_21 -> scan_alpha<generic>
;   botlish_fn_22 / botlish_entry_22 -> tld_ok<generic>
;   botlish_fn_23 / botlish_entry_23 -> domain_loop<generic>
;   botlish_fn_24 / botlish_entry_24 -> <str>
;   botlish_fn_25 / botlish_entry_25 -> <generic>
;   botlish_fn_26 / botlish_entry_26 -> char_at<generic>
;   botlish_fn_27 / botlish_entry_27 -> scan_local<generic>
;   botlish_fn_28 / botlish_entry_28 -> scan_label<generic>
;   botlish_fn_29 / botlish_entry_29 -> scan_alpha<generic>
;   botlish_fn_30 / botlish_entry_30 -> tld_ok<generic>
;   botlish_fn_31 / botlish_entry_31 -> domain_loop<generic>


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
			27b: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::set<List[UnicodeChar]>
     27f:	test   rax,rax
     282:	je     3fe <botlish_fn_0+0x3fe>
     288:	mov    QWORD PTR [rsp+0x8],rax
     28d:	lea    r8,[rsp+0x120]
     295:	mov    QWORD PTR [rsp+0x120],rax
     29d:	mov    esi,0x8
     2a2:	mov    rdx,QWORD PTR [rip+0x0]        # 2a9 <botlish_fn_0+0x2a9>
			2a5: R_X86_64_GOTPCREL	botlish_entry_8-0x4 ; web::is_unreserved<generic>
     2a9:	mov    ecx,0x1
     2ae:	mov    rdi,QWORD PTR [rsp+0x148]
     2b6:	call   2bb <botlish_fn_0+0x2bb>
			2b7: R_X86_64_PLT32	rt_closure_new-0x4
     2bb:	mov    QWORD PTR [rsp+0x8],rax
     2c0:	lea    r8,[rsp+0x128]
     2c8:	mov    rcx,rbx
     2cb:	mov    QWORD PTR [rsp+0x128],rcx
     2d3:	mov    QWORD PTR [rsp+0x130],rax
     2db:	mov    esi,0x9
     2e0:	mov    rdx,QWORD PTR [rip+0x0]        # 2e7 <botlish_fn_0+0x2e7>
			2e3: R_X86_64_GOTPCREL	botlish_entry_9-0x4 ; web::uri_escape_text<generic>
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
			319: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::uri_escape_text<generic>
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
			36d: R_X86_64_PLT32	botlish_fn_15-0x4 ; check<int, int, str, str>
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
			3ba: R_X86_64_PLT32	botlish_fn_15-0x4 ; check<int, int, str, str>
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

0000000000000498 <botlish_fn_2: byte::set<List[UnicodeChar]>>:
     498:	push   rbp
     499:	mov    rbp,rsp
     49c:	sub    rsp,0x60
     4a0:	mov    QWORD PTR [rsp+0x30],rbx
     4a5:	mov    QWORD PTR [rsp+0x38],r12
     4aa:	mov    QWORD PTR [rsp+0x40],r13
     4af:	mov    QWORD PTR [rsp+0x48],r14
     4b4:	mov    QWORD PTR [rsp+0x50],r15
     4b9:	mov    r13,rdi
     4bc:	mov    QWORD PTR [rsp+0x18],0x0
     4c5:	mov    QWORD PTR [rsp+0x20],0x0
     4ce:	mov    QWORD PTR [rsp],rsi
     4d2:	mov    rbx,rsi
     4d5:	mov    rdi,r13
     4d8:	call   4dd <botlish_fn_2+0x45>
			4d9: R_X86_64_PLT32	rt_list_len-0x4
     4dd:	mov    QWORD PTR [rsp+0x8],rax
     4e2:	mov    r12,rax
     4e5:	mov    QWORD PTR [rsp+0x10],0x1
     4ee:	xor    rdx,rdx
     4f1:	mov    rdi,r13
     4f4:	mov    rsi,rdx
     4f7:	call   4fc <botlish_fn_2+0x64>
			4f8: R_X86_64_PLT32	rt_list_new-0x4
     4fc:	test   rax,rax
     4ff:	je     6ec <botlish_fn_2+0x254>
     505:	mov    esi,0x1
     50a:	mov    r14,rsi
     50d:	mov    QWORD PTR [rsp+0x10],0x1
     516:	mov    QWORD PTR [rsp+0x18],rax
     51b:	mov    QWORD PTR [rsp+0x28],rax
     520:	mov    rax,rsi
     523:	and    rax,r12
     526:	mov    r14,rsi
     529:	test   rax,0x1
     52f:	jne    558 <botlish_fn_2+0xc0>
     535:	mov    rdx,r12
     538:	mov    rsi,r14
     53b:	mov    rdi,r13
     53e:	call   543 <botlish_fn_2+0xab>
			53f: R_X86_64_PLT32	rt_int_cmp-0x4
     543:	mov    ecx,0x2
     548:	test   rax,rax
     54b:	cmovl  rcx,QWORD PTR [rip+0x235]        # 788 <botlish_fn_2+0x2f0>
     553:	jmp    56b <botlish_fn_2+0xd3>
     558:	mov    ecx,0x2
     55d:	mov    rsi,r14
     560:	cmp    rsi,r12
     563:	cmovl  rcx,QWORD PTR [rip+0x21d]        # 788 <botlish_fn_2+0x2f0>
     56b:	cmp    rcx,0x6
     56f:	je     5b1 <botlish_fn_2+0x119>
     575:	mov    rsi,QWORD PTR [rsp+0x28]
     57a:	mov    QWORD PTR [rsp],rsi
     57e:	mov    rdi,r13
     581:	call   586 <botlish_fn_2+0xee>
			582: R_X86_64_PLT32	rt_set_from_list-0x4
     586:	test   rax,rax
     589:	je     6ec <botlish_fn_2+0x254>
     58f:	mov    rbx,QWORD PTR [rsp+0x30]
     594:	mov    r12,QWORD PTR [rsp+0x38]
     599:	mov    r13,QWORD PTR [rsp+0x40]
     59e:	mov    r14,QWORD PTR [rsp+0x48]
     5a3:	mov    r15,QWORD PTR [rsp+0x50]
     5a8:	add    rsp,0x60
     5ac:	mov    rsp,rbp
     5af:	pop    rbp
     5b0:	ret
     5b1:	mov    rsi,r14
     5b4:	test   rsi,0x1
     5bb:	je     5d7 <botlish_fn_2+0x13f>
     5c1:	mov    rcx,QWORD PTR [rbx+0x8]
     5c5:	mov    rsi,r14
     5c8:	mov    rax,rsi
     5cb:	sar    rax,1
     5ce:	cmp    rax,rcx
     5d1:	jb     5f6 <botlish_fn_2+0x15e>
     5d7:	mov    rdx,r14
     5da:	mov    rsi,rbx
     5dd:	mov    rdi,r13
     5e0:	call   5e5 <botlish_fn_2+0x14d>
			5e1: R_X86_64_PLT32	rt_list_get-0x4
     5e5:	test   rax,rax
     5e8:	je     6ec <botlish_fn_2+0x254>
     5ee:	mov    rsi,rax
     5f1:	jmp    5fe <botlish_fn_2+0x166>
     5f6:	mov    rcx,QWORD PTR [rbx+0x10]
     5fa:	mov    rsi,QWORD PTR [rcx+rax*8]
     5fe:	mov    rdi,r13
     601:	call   606 <botlish_fn_2+0x16e>
			602: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     606:	mov    r15,rax
     609:	mov    QWORD PTR [rsp+0x20],rax
     60e:	test   rax,0x1
     614:	jne    63f <botlish_fn_2+0x1a7>
     61a:	mov    edx,0x1
     61f:	mov    rsi,r15
     622:	mov    rdi,r13
     625:	call   62a <botlish_fn_2+0x192>
			626: R_X86_64_PLT32	rt_int_cmp-0x4
     62a:	mov    esi,0x2
     62f:	test   rax,rax
     632:	cmovge rsi,QWORD PTR [rip+0x14e]        # 788 <botlish_fn_2+0x2f0>
     63a:	jmp    64f <botlish_fn_2+0x1b7>
     63f:	mov    esi,0x2
     644:	test   r15,r15
     647:	cmovg  rsi,QWORD PTR [rip+0x139]        # 788 <botlish_fn_2+0x2f0>
     64f:	cmp    rsi,0x6
     653:	je     661 <botlish_fn_2+0x1c9>
     659:	mov    rdi,r13
     65c:	jmp    6b4 <botlish_fn_2+0x21c>
     661:	test   r15,0x1
     668:	jne    693 <botlish_fn_2+0x1fb>
     66e:	mov    edx,0x1ff
     673:	mov    rsi,r15
     676:	mov    rdi,r13
     679:	call   67e <botlish_fn_2+0x1e6>
			67a: R_X86_64_PLT32	rt_int_cmp-0x4
     67e:	mov    ecx,0x2
     683:	test   rax,rax
     686:	cmovle rcx,QWORD PTR [rip+0xfa]        # 788 <botlish_fn_2+0x2f0>
     68e:	jmp    6a7 <botlish_fn_2+0x20f>
     693:	mov    ecx,0x2
     698:	cmp    r15,0x1ff
     69f:	cmovle rcx,QWORD PTR [rip+0xe1]        # 788 <botlish_fn_2+0x2f0>
     6a7:	cmp    rcx,0x6
     6ab:	je     6d3 <botlish_fn_2+0x23b>
     6b1:	mov    rdi,r13
     6b4:	mov    rdi,r13
     6b7:	mov    rax,QWORD PTR [rdi+0x10]
     6bb:	mov    rsi,QWORD PTR [rax+0x98]
     6c2:	mov    rdx,QWORD PTR [rax+0xa0]
     6c9:	call   6ce <botlish_fn_2+0x236>
			6ca: R_X86_64_PLT32	rt_raise-0x4
     6ce:	jmp    6ec <botlish_fn_2+0x254>
     6d3:	mov    rdx,r15
     6d6:	mov    rsi,QWORD PTR [rsp+0x28]
     6db:	mov    rdi,r13
     6de:	call   6e3 <botlish_fn_2+0x24b>
			6df: R_X86_64_PLT32	rt_list_append-0x4
     6e3:	test   rax,rax
     6e6:	jne    711 <botlish_fn_2+0x279>
     6ec:	xor    rax,rax
     6ef:	mov    rbx,QWORD PTR [rsp+0x30]
     6f4:	mov    r12,QWORD PTR [rsp+0x38]
     6f9:	mov    r13,QWORD PTR [rsp+0x40]
     6fe:	mov    r14,QWORD PTR [rsp+0x48]
     703:	mov    r15,QWORD PTR [rsp+0x50]
     708:	add    rsp,0x60
     70c:	mov    rsp,rbp
     70f:	pop    rbp
     710:	ret
     711:	mov    QWORD PTR [rsp+0x18],rax
     716:	mov    r15,rax
     719:	mov    edx,0x3
     71e:	mov    QWORD PTR [rsp+0x20],0x3
     727:	mov    rsi,r14
     72a:	test   rsi,0x1
     731:	jne    73f <botlish_fn_2+0x2a7>
     737:	mov    rsi,r14
     73a:	jmp    767 <botlish_fn_2+0x2cf>
     73f:	mov    rsi,r14
     742:	mov    rcx,rsi
     745:	add    rcx,0x2
     749:	seto   al
     74c:	test   al,al
     74e:	je     75c <botlish_fn_2+0x2c4>
     754:	mov    rsi,r14
     757:	jmp    767 <botlish_fn_2+0x2cf>
     75c:	mov    rsi,rcx
     75f:	mov    r14,rcx
     762:	jmp    775 <botlish_fn_2+0x2dd>
     767:	mov    rdi,r13
     76a:	call   76f <botlish_fn_2+0x2d7>
			76b: R_X86_64_PLT32	rt_int_add-0x4
     76f:	mov    rsi,rax
     772:	mov    r14,rax
     775:	mov    QWORD PTR [rsp+0x10],rsi
     77a:	mov    rsi,r14
     77d:	mov    QWORD PTR [rsp+0x28],r15
     782:	jmp    520 <botlish_fn_2+0x88>
     787:	add    BYTE PTR [rsi],al
     789:	add    BYTE PTR [rax],al
     78b:	add    BYTE PTR [rax],al
     78d:	add    BYTE PTR [rax],al
	...

0000000000000790 <botlish_entry_2: byte::set<List[UnicodeChar]>>:
     790:	push   rbp
     791:	mov    rbp,rsp
     794:	mov    rsi,QWORD PTR [rdx]
     797:	call   79c <botlish_entry_2+0xc>
			798: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::set<List[UnicodeChar]>
     79c:	mov    rsp,rbp
     79f:	pop    rbp
     7a0:	ret
     7a1:	add    BYTE PTR [rax],al
     7a3:	add    BYTE PTR [rax],al
     7a5:	add    BYTE PTR [rax],al
	...

00000000000007a8 <botlish_fn_3: ascii::is_digit<generic>>:
     7a8:	push   rbp
     7a9:	mov    rbp,rsp
     7ac:	sub    rsp,0x10
     7b0:	mov    QWORD PTR [rsp],rbx
     7b4:	mov    QWORD PTR [rsp+0x8],r12
     7b9:	mov    r8d,0x1
     7bf:	test   rsi,0x1
     7c6:	jne    7e6 <botlish_fn_3+0x3e>
     7cc:	xor    r8d,r8d
     7cf:	test   rsi,0x7
     7d6:	jne    7e6 <botlish_fn_3+0x3e>
     7dc:	movzx  rax,BYTE PTR [rsi]
     7e0:	cmp    al,0x1
     7e2:	sete   r8b
     7e6:	test   r8b,r8b
     7e9:	jne    81a <botlish_fn_3+0x72>
     7ef:	mov    rax,QWORD PTR [rdi+0x10]
     7f3:	mov    rcx,QWORD PTR [rax+0xa8]
     7fa:	xor    rbx,rbx
     7fd:	mov    rdx,rbx
     800:	call   805 <botlish_fn_3+0x5d>
			801: R_X86_64_PLT32	rt_type_error-0x4
     805:	mov    rax,rbx
     808:	mov    rbx,QWORD PTR [rsp]
     80c:	mov    r12,QWORD PTR [rsp+0x8]
     811:	add    rsp,0x10
     815:	mov    rsp,rbp
     818:	pop    rbp
     819:	ret
     81a:	mov    r12,rdi
     81d:	test   rsi,0x1
     824:	mov    rbx,rsi
     827:	jne    855 <botlish_fn_3+0xad>
     82d:	mov    edx,0x61
     832:	mov    rsi,rbx
     835:	mov    rdi,r12
     838:	call   83d <botlish_fn_3+0x95>
			839: R_X86_64_PLT32	rt_int_cmp-0x4
     83d:	mov    ecx,0x2
     842:	test   rax,rax
     845:	cmovge rcx,QWORD PTR [rip+0xab]        # 8f8 <botlish_fn_3+0x150>
     84d:	mov    rsi,rbx
     850:	jmp    869 <botlish_fn_3+0xc1>
     855:	mov    ecx,0x2
     85a:	mov    rsi,rbx
     85d:	cmp    rsi,0x61
     861:	cmovge rcx,QWORD PTR [rip+0x8f]        # 8f8 <botlish_fn_3+0x150>
     869:	mov    eax,0x6
     86e:	cmp    rcx,0x6
     872:	je     885 <botlish_fn_3+0xdd>
     878:	mov    eax,0x2
     87d:	mov    rbx,rax
     880:	jmp    8df <botlish_fn_3+0x137>
     885:	mov    rbx,rax
     888:	test   rsi,0x1
     88f:	jne    8b7 <botlish_fn_3+0x10f>
     895:	mov    edx,0x73
     89a:	mov    rdi,r12
     89d:	call   8a2 <botlish_fn_3+0xfa>
			89e: R_X86_64_PLT32	rt_int_cmp-0x4
     8a2:	mov    ecx,0x2
     8a7:	test   rax,rax
     8aa:	cmovle rcx,QWORD PTR [rip+0x46]        # 8f8 <botlish_fn_3+0x150>
     8b2:	jmp    8c8 <botlish_fn_3+0x120>
     8b7:	mov    ecx,0x2
     8bc:	cmp    rsi,0x73
     8c0:	cmovle rcx,QWORD PTR [rip+0x30]        # 8f8 <botlish_fn_3+0x150>
     8c8:	cmp    rcx,0x6
     8cc:	je     8dc <botlish_fn_3+0x134>
     8d2:	mov    eax,0x2
     8d7:	jmp    8df <botlish_fn_3+0x137>
     8dc:	mov    rax,rbx
     8df:	mov    rbx,QWORD PTR [rsp]
     8e3:	mov    r12,QWORD PTR [rsp+0x8]
     8e8:	add    rsp,0x10
     8ec:	mov    rsp,rbp
     8ef:	pop    rbp
     8f0:	ret
     8f1:	add    BYTE PTR [rax],al
     8f3:	add    BYTE PTR [rax],al
     8f5:	add    BYTE PTR [rax],al
     8f7:	add    BYTE PTR [rsi],al
     8f9:	add    BYTE PTR [rax],al
     8fb:	add    BYTE PTR [rax],al
     8fd:	add    BYTE PTR [rax],al
	...

0000000000000900 <botlish_entry_3: ascii::is_digit<generic>>:
     900:	push   rbp
     901:	mov    rbp,rsp
     904:	mov    rsi,QWORD PTR [rdx]
     907:	call   90c <botlish_entry_3+0xc>
			908: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<generic>
     90c:	mov    rsp,rbp
     90f:	pop    rbp
     910:	ret
     911:	add    BYTE PTR [rax],al
     913:	add    BYTE PTR [rax],al
     915:	add    BYTE PTR [rax],al
	...

0000000000000918 <botlish_fn_4: ascii::is_upper<generic>>:
     918:	push   rbp
     919:	mov    rbp,rsp
     91c:	sub    rsp,0x10
     920:	mov    QWORD PTR [rsp],rbx
     924:	mov    QWORD PTR [rsp+0x8],r12
     929:	mov    r8d,0x1
     92f:	test   rsi,0x1
     936:	jne    956 <botlish_fn_4+0x3e>
     93c:	xor    r8d,r8d
     93f:	test   rsi,0x7
     946:	jne    956 <botlish_fn_4+0x3e>
     94c:	movzx  rax,BYTE PTR [rsi]
     950:	cmp    al,0x1
     952:	sete   r8b
     956:	test   r8b,r8b
     959:	jne    98a <botlish_fn_4+0x72>
     95f:	mov    rax,QWORD PTR [rdi+0x10]
     963:	mov    rcx,QWORD PTR [rax+0xa8]
     96a:	xor    rbx,rbx
     96d:	mov    rdx,rbx
     970:	call   975 <botlish_fn_4+0x5d>
			971: R_X86_64_PLT32	rt_type_error-0x4
     975:	mov    rax,rbx
     978:	mov    rbx,QWORD PTR [rsp]
     97c:	mov    r12,QWORD PTR [rsp+0x8]
     981:	add    rsp,0x10
     985:	mov    rsp,rbp
     988:	pop    rbp
     989:	ret
     98a:	mov    r12,rdi
     98d:	test   rsi,0x1
     994:	mov    rbx,rsi
     997:	jne    9c5 <botlish_fn_4+0xad>
     99d:	mov    edx,0x83
     9a2:	mov    rsi,rbx
     9a5:	mov    rdi,r12
     9a8:	call   9ad <botlish_fn_4+0x95>
			9a9: R_X86_64_PLT32	rt_int_cmp-0x4
     9ad:	mov    ecx,0x2
     9b2:	test   rax,rax
     9b5:	cmovge rcx,QWORD PTR [rip+0xab]        # a68 <botlish_fn_4+0x150>
     9bd:	mov    rsi,rbx
     9c0:	jmp    9dc <botlish_fn_4+0xc4>
     9c5:	mov    ecx,0x2
     9ca:	mov    rsi,rbx
     9cd:	cmp    rsi,0x83
     9d4:	cmovge rcx,QWORD PTR [rip+0x8c]        # a68 <botlish_fn_4+0x150>
     9dc:	mov    eax,0x6
     9e1:	cmp    rcx,0x6
     9e5:	je     9f8 <botlish_fn_4+0xe0>
     9eb:	mov    eax,0x2
     9f0:	mov    rbx,rax
     9f3:	jmp    a55 <botlish_fn_4+0x13d>
     9f8:	mov    rbx,rax
     9fb:	test   rsi,0x1
     a02:	jne    a2a <botlish_fn_4+0x112>
     a08:	mov    edx,0xb5
     a0d:	mov    rdi,r12
     a10:	call   a15 <botlish_fn_4+0xfd>
			a11: R_X86_64_PLT32	rt_int_cmp-0x4
     a15:	mov    ecx,0x2
     a1a:	test   rax,rax
     a1d:	cmovle rcx,QWORD PTR [rip+0x43]        # a68 <botlish_fn_4+0x150>
     a25:	jmp    a3e <botlish_fn_4+0x126>
     a2a:	mov    ecx,0x2
     a2f:	cmp    rsi,0xb5
     a36:	cmovle rcx,QWORD PTR [rip+0x2a]        # a68 <botlish_fn_4+0x150>
     a3e:	cmp    rcx,0x6
     a42:	je     a52 <botlish_fn_4+0x13a>
     a48:	mov    eax,0x2
     a4d:	jmp    a55 <botlish_fn_4+0x13d>
     a52:	mov    rax,rbx
     a55:	mov    rbx,QWORD PTR [rsp]
     a59:	mov    r12,QWORD PTR [rsp+0x8]
     a5e:	add    rsp,0x10
     a62:	mov    rsp,rbp
     a65:	pop    rbp
     a66:	ret
     a67:	add    BYTE PTR [rsi],al
     a69:	add    BYTE PTR [rax],al
     a6b:	add    BYTE PTR [rax],al
     a6d:	add    BYTE PTR [rax],al
	...

0000000000000a70 <botlish_entry_4: ascii::is_upper<generic>>:
     a70:	push   rbp
     a71:	mov    rbp,rsp
     a74:	mov    rsi,QWORD PTR [rdx]
     a77:	call   a7c <botlish_entry_4+0xc>
			a78: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_upper<generic>
     a7c:	mov    rsp,rbp
     a7f:	pop    rbp
     a80:	ret
     a81:	add    BYTE PTR [rax],al
     a83:	add    BYTE PTR [rax],al
     a85:	add    BYTE PTR [rax],al
	...

0000000000000a88 <botlish_fn_5: ascii::is_lower<generic>>:
     a88:	push   rbp
     a89:	mov    rbp,rsp
     a8c:	sub    rsp,0x10
     a90:	mov    QWORD PTR [rsp],rbx
     a94:	mov    QWORD PTR [rsp+0x8],r12
     a99:	mov    r8d,0x1
     a9f:	test   rsi,0x1
     aa6:	jne    ac6 <botlish_fn_5+0x3e>
     aac:	xor    r8d,r8d
     aaf:	test   rsi,0x7
     ab6:	jne    ac6 <botlish_fn_5+0x3e>
     abc:	movzx  rax,BYTE PTR [rsi]
     ac0:	cmp    al,0x1
     ac2:	sete   r8b
     ac6:	test   r8b,r8b
     ac9:	jne    afa <botlish_fn_5+0x72>
     acf:	mov    rax,QWORD PTR [rdi+0x10]
     ad3:	mov    rcx,QWORD PTR [rax+0xa8]
     ada:	xor    rbx,rbx
     add:	mov    rdx,rbx
     ae0:	call   ae5 <botlish_fn_5+0x5d>
			ae1: R_X86_64_PLT32	rt_type_error-0x4
     ae5:	mov    rax,rbx
     ae8:	mov    rbx,QWORD PTR [rsp]
     aec:	mov    r12,QWORD PTR [rsp+0x8]
     af1:	add    rsp,0x10
     af5:	mov    rsp,rbp
     af8:	pop    rbp
     af9:	ret
     afa:	mov    r12,rdi
     afd:	test   rsi,0x1
     b04:	mov    rbx,rsi
     b07:	jne    b35 <botlish_fn_5+0xad>
     b0d:	mov    edx,0xc3
     b12:	mov    rsi,rbx
     b15:	mov    rdi,r12
     b18:	call   b1d <botlish_fn_5+0x95>
			b19: R_X86_64_PLT32	rt_int_cmp-0x4
     b1d:	mov    ecx,0x2
     b22:	test   rax,rax
     b25:	cmovge rcx,QWORD PTR [rip+0xab]        # bd8 <botlish_fn_5+0x150>
     b2d:	mov    rsi,rbx
     b30:	jmp    b4c <botlish_fn_5+0xc4>
     b35:	mov    ecx,0x2
     b3a:	mov    rsi,rbx
     b3d:	cmp    rsi,0xc3
     b44:	cmovge rcx,QWORD PTR [rip+0x8c]        # bd8 <botlish_fn_5+0x150>
     b4c:	mov    eax,0x6
     b51:	cmp    rcx,0x6
     b55:	je     b68 <botlish_fn_5+0xe0>
     b5b:	mov    eax,0x2
     b60:	mov    rbx,rax
     b63:	jmp    bc5 <botlish_fn_5+0x13d>
     b68:	mov    rbx,rax
     b6b:	test   rsi,0x1
     b72:	jne    b9a <botlish_fn_5+0x112>
     b78:	mov    edx,0xf5
     b7d:	mov    rdi,r12
     b80:	call   b85 <botlish_fn_5+0xfd>
			b81: R_X86_64_PLT32	rt_int_cmp-0x4
     b85:	mov    ecx,0x2
     b8a:	test   rax,rax
     b8d:	cmovle rcx,QWORD PTR [rip+0x43]        # bd8 <botlish_fn_5+0x150>
     b95:	jmp    bae <botlish_fn_5+0x126>
     b9a:	mov    ecx,0x2
     b9f:	cmp    rsi,0xf5
     ba6:	cmovle rcx,QWORD PTR [rip+0x2a]        # bd8 <botlish_fn_5+0x150>
     bae:	cmp    rcx,0x6
     bb2:	je     bc2 <botlish_fn_5+0x13a>
     bb8:	mov    eax,0x2
     bbd:	jmp    bc5 <botlish_fn_5+0x13d>
     bc2:	mov    rax,rbx
     bc5:	mov    rbx,QWORD PTR [rsp]
     bc9:	mov    r12,QWORD PTR [rsp+0x8]
     bce:	add    rsp,0x10
     bd2:	mov    rsp,rbp
     bd5:	pop    rbp
     bd6:	ret
     bd7:	add    BYTE PTR [rsi],al
     bd9:	add    BYTE PTR [rax],al
     bdb:	add    BYTE PTR [rax],al
     bdd:	add    BYTE PTR [rax],al
	...

0000000000000be0 <botlish_entry_5: ascii::is_lower<generic>>:
     be0:	push   rbp
     be1:	mov    rbp,rsp
     be4:	mov    rsi,QWORD PTR [rdx]
     be7:	call   bec <botlish_entry_5+0xc>
			be8: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_lower<generic>
     bec:	mov    rsp,rbp
     bef:	pop    rbp
     bf0:	ret

0000000000000bf1 <botlish_fn_6: ascii::is_alphabetic<generic>>:
     bf1:	push   rbp
     bf2:	mov    rbp,rsp
     bf5:	sub    rsp,0x10
     bf9:	mov    QWORD PTR [rsp],r12
     bfd:	mov    QWORD PTR [rsp+0x8],r14
     c02:	mov    r12,rsi
     c05:	mov    r14,rdi
     c08:	mov    rsi,r12
     c0b:	mov    rdi,r14
     c0e:	call   c13 <botlish_fn_6+0x22>
			c0f: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_upper<generic>
     c13:	test   rax,rax
     c16:	je     c3a <botlish_fn_6+0x49>
     c1c:	cmp    rax,0x6
     c20:	je     c6d <botlish_fn_6+0x7c>
     c26:	mov    rsi,r12
     c29:	mov    rdi,r14
     c2c:	call   c31 <botlish_fn_6+0x40>
			c2d: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_lower<generic>
     c31:	test   rax,rax
     c34:	jne    c4f <botlish_fn_6+0x5e>
     c3a:	xor    rax,rax
     c3d:	mov    r12,QWORD PTR [rsp]
     c41:	mov    r14,QWORD PTR [rsp+0x8]
     c46:	add    rsp,0x10
     c4a:	mov    rsp,rbp
     c4d:	pop    rbp
     c4e:	ret
     c4f:	cmp    rax,0x6
     c53:	je     c63 <botlish_fn_6+0x72>
     c59:	mov    eax,0x2
     c5e:	jmp    c72 <botlish_fn_6+0x81>
     c63:	mov    eax,0x6
     c68:	jmp    c72 <botlish_fn_6+0x81>
     c6d:	mov    eax,0x6
     c72:	mov    r12,QWORD PTR [rsp]
     c76:	mov    r14,QWORD PTR [rsp+0x8]
     c7b:	add    rsp,0x10
     c7f:	mov    rsp,rbp
     c82:	pop    rbp
     c83:	ret

0000000000000c84 <botlish_entry_6: ascii::is_alphabetic<generic>>:
     c84:	push   rbp
     c85:	mov    rbp,rsp
     c88:	mov    rsi,QWORD PTR [rdx]
     c8b:	call   c90 <botlish_entry_6+0xc>
			c8c: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_alphabetic<generic>
     c90:	mov    rsp,rbp
     c93:	pop    rbp
     c94:	ret

0000000000000c95 <botlish_fn_7: ascii::is_alphanumeric<generic>>:
     c95:	push   rbp
     c96:	mov    rbp,rsp
     c99:	sub    rsp,0x10
     c9d:	mov    QWORD PTR [rsp],r12
     ca1:	mov    QWORD PTR [rsp+0x8],r14
     ca6:	mov    r12,rsi
     ca9:	mov    r14,rdi
     cac:	mov    rsi,r12
     caf:	mov    rdi,r14
     cb2:	call   cb7 <botlish_fn_7+0x22>
			cb3: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_alphabetic<generic>
     cb7:	test   rax,rax
     cba:	je     cde <botlish_fn_7+0x49>
     cc0:	cmp    rax,0x6
     cc4:	je     d11 <botlish_fn_7+0x7c>
     cca:	mov    rsi,r12
     ccd:	mov    rdi,r14
     cd0:	call   cd5 <botlish_fn_7+0x40>
			cd1: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<generic>
     cd5:	test   rax,rax
     cd8:	jne    cf3 <botlish_fn_7+0x5e>
     cde:	xor    rax,rax
     ce1:	mov    r12,QWORD PTR [rsp]
     ce5:	mov    r14,QWORD PTR [rsp+0x8]
     cea:	add    rsp,0x10
     cee:	mov    rsp,rbp
     cf1:	pop    rbp
     cf2:	ret
     cf3:	cmp    rax,0x6
     cf7:	je     d07 <botlish_fn_7+0x72>
     cfd:	mov    eax,0x2
     d02:	jmp    d16 <botlish_fn_7+0x81>
     d07:	mov    eax,0x6
     d0c:	jmp    d16 <botlish_fn_7+0x81>
     d11:	mov    eax,0x6
     d16:	mov    r12,QWORD PTR [rsp]
     d1a:	mov    r14,QWORD PTR [rsp+0x8]
     d1f:	add    rsp,0x10
     d23:	mov    rsp,rbp
     d26:	pop    rbp
     d27:	ret

0000000000000d28 <botlish_entry_7: ascii::is_alphanumeric<generic>>:
     d28:	push   rbp
     d29:	mov    rbp,rsp
     d2c:	mov    rsi,QWORD PTR [rdx]
     d2f:	call   d34 <botlish_entry_7+0xc>
			d30: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphanumeric<generic>
     d34:	mov    rsp,rbp
     d37:	pop    rbp
     d38:	ret

0000000000000d39 <botlish_fn_8: web::is_unreserved<generic>>:
     d39:	push   rbp
     d3a:	mov    rbp,rsp
     d3d:	sub    rsp,0x20
     d41:	mov    QWORD PTR [rsp],rbx
     d45:	mov    QWORD PTR [rsp+0x8],r12
     d4a:	mov    QWORD PTR [rsp+0x10],r15
     d4f:	mov    rbx,rdi
     d52:	mov    r12,rsi
     d55:	mov    r15,rdx
     d58:	mov    rsi,r15
     d5b:	mov    rdi,rbx
     d5e:	call   d63 <botlish_fn_8+0x2a>
			d5f: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphanumeric<generic>
     d63:	test   rax,rax
     d66:	je     d94 <botlish_fn_8+0x5b>
     d6c:	cmp    rax,0x6
     d70:	je     dcc <botlish_fn_8+0x93>
     d76:	mov    rsi,r12
     d79:	mov    rax,QWORD PTR [rsi+0x20]
     d7d:	mov    rsi,QWORD PTR [rax]
     d80:	mov    rdx,r15
     d83:	mov    rdi,rbx
     d86:	call   d8b <botlish_fn_8+0x52>
			d87: R_X86_64_PLT32	rt_set_contains-0x4
     d8b:	test   rax,rax
     d8e:	jne    dae <botlish_fn_8+0x75>
     d94:	xor    rax,rax
     d97:	mov    rbx,QWORD PTR [rsp]
     d9b:	mov    r12,QWORD PTR [rsp+0x8]
     da0:	mov    r15,QWORD PTR [rsp+0x10]
     da5:	add    rsp,0x20
     da9:	mov    rsp,rbp
     dac:	pop    rbp
     dad:	ret
     dae:	cmp    rax,0x6
     db2:	je     dc2 <botlish_fn_8+0x89>
     db8:	mov    eax,0x2
     dbd:	jmp    dd1 <botlish_fn_8+0x98>
     dc2:	mov    eax,0x6
     dc7:	jmp    dd1 <botlish_fn_8+0x98>
     dcc:	mov    eax,0x6
     dd1:	mov    rbx,QWORD PTR [rsp]
     dd5:	mov    r12,QWORD PTR [rsp+0x8]
     dda:	mov    r15,QWORD PTR [rsp+0x10]
     ddf:	add    rsp,0x20
     de3:	mov    rsp,rbp
     de6:	pop    rbp
     de7:	ret

0000000000000de8 <botlish_entry_8: web::is_unreserved<generic>>:
     de8:	push   rbp
     de9:	mov    rbp,rsp
     dec:	mov    rdx,QWORD PTR [rdx]
     def:	call   df4 <botlish_entry_8+0xc>
			df0: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::is_unreserved<generic>
     df4:	mov    rsp,rbp
     df7:	pop    rbp
     df8:	ret

0000000000000df9 <botlish_fn_9: web::uri_escape_text<generic>>:
     df9:	push   rbp
     dfa:	mov    rbp,rsp
     dfd:	sub    rsp,0x30
     e01:	mov    QWORD PTR [rsp],rdx
     e05:	mov    r10,rdx
     e08:	mov    edx,0x1
     e0d:	mov    QWORD PTR [rsp+0x8],0x1
     e16:	mov    rax,QWORD PTR [rdi+0x10]
     e1a:	mov    rcx,QWORD PTR [rax+0xb0]
     e21:	mov    QWORD PTR [rsp+0x10],rcx
     e26:	mov    rax,QWORD PTR [rsi+0x20]
     e2a:	mov    r8,QWORD PTR [rax+0x8]
     e2e:	mov    QWORD PTR [rsp+0x18],r8
     e33:	mov    rax,QWORD PTR [rsi+0x20]
     e37:	mov    r9,QWORD PTR [rax]
     e3a:	mov    QWORD PTR [rsp+0x20],r9
     e3f:	mov    rsi,r10
     e42:	call   e47 <botlish_fn_9+0x4e>
			e43: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_from<generic>
     e47:	test   rax,rax
     e4a:	jne    e5c <botlish_fn_9+0x63>
     e50:	xor    rax,rax
     e53:	add    rsp,0x30
     e57:	mov    rsp,rbp
     e5a:	pop    rbp
     e5b:	ret
     e5c:	add    rsp,0x30
     e60:	mov    rsp,rbp
     e63:	pop    rbp
     e64:	ret

0000000000000e65 <botlish_entry_9: web::uri_escape_text<generic>>:
     e65:	push   rbp
     e66:	mov    rbp,rsp
     e69:	mov    rdx,QWORD PTR [rdx]
     e6c:	call   e71 <botlish_entry_9+0xc>
			e6d: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::uri_escape_text<generic>
     e71:	mov    rsp,rbp
     e74:	pop    rbp
     e75:	ret

0000000000000e76 <botlish_fn_10: high_nibble<generic>>:
     e76:	push   rbp
     e77:	mov    rbp,rsp
     e7a:	sub    rsp,0x20
     e7e:	mov    QWORD PTR [rsp+0x10],rbx
     e83:	mov    QWORD PTR [rsp],rsi
     e87:	mov    QWORD PTR [rsp+0x8],0x1e1
     e90:	mov    r8d,0x1
     e96:	test   rsi,0x1
     e9d:	jne    ebd <botlish_fn_10+0x47>
     ea3:	xor    r8d,r8d
     ea6:	test   rsi,0x7
     ead:	jne    ebd <botlish_fn_10+0x47>
     eb3:	movzx  rax,BYTE PTR [rsi]
     eb7:	cmp    al,0x1
     eb9:	sete   r8b
     ebd:	test   r8b,r8b
     ec0:	jne    eed <botlish_fn_10+0x77>
     ec6:	mov    rax,QWORD PTR [rdi+0x10]
     eca:	mov    rcx,QWORD PTR [rax+0xb8]
     ed1:	xor    rbx,rbx
     ed4:	mov    rdx,rbx
     ed7:	call   edc <botlish_fn_10+0x66>
			ed8: R_X86_64_PLT32	rt_type_error-0x4
     edc:	mov    rax,rbx
     edf:	mov    rbx,QWORD PTR [rsp+0x10]
     ee4:	add    rsp,0x20
     ee8:	mov    rsp,rbp
     eeb:	pop    rbp
     eec:	ret
     eed:	test   rsi,0x1
     ef4:	jne    f09 <botlish_fn_10+0x93>
     efa:	mov    edx,0x1e1
     eff:	call   f04 <botlish_fn_10+0x8e>
			f00: R_X86_64_PLT32	rt_int_and-0x4
     f04:	jmp    f13 <botlish_fn_10+0x9d>
     f09:	and    rsi,0x1e1
     f10:	mov    rax,rsi
     f13:	sar    rax,0x5
     f17:	shl    rax,1
     f1a:	or     rax,0x1
     f1e:	mov    rbx,QWORD PTR [rsp+0x10]
     f23:	add    rsp,0x20
     f27:	mov    rsp,rbp
     f2a:	pop    rbp
     f2b:	ret

0000000000000f2c <botlish_entry_10: high_nibble<generic>>:
     f2c:	push   rbp
     f2d:	mov    rbp,rsp
     f30:	mov    rsi,QWORD PTR [rdx]
     f33:	call   f38 <botlish_entry_10+0xc>
			f34: R_X86_64_PLT32	botlish_fn_10-0x4 ; high_nibble<generic>
     f38:	mov    rsp,rbp
     f3b:	pop    rbp
     f3c:	ret

0000000000000f3d <botlish_fn_11: hex_pair<generic>>:
     f3d:	push   rbp
     f3e:	mov    rbp,rsp
     f41:	sub    rsp,0x30
     f45:	mov    QWORD PTR [rsp+0x10],rbx
     f4a:	mov    QWORD PTR [rsp+0x18],r12
     f4f:	mov    QWORD PTR [rsp+0x20],r13
     f54:	mov    QWORD PTR [rsp+0x28],r14
     f59:	mov    r12,rdi
     f5c:	mov    QWORD PTR [rsp],rsi
     f60:	mov    r13,rsi
     f63:	mov    QWORD PTR [rsp+0x8],rdx
     f68:	mov    rbx,rdx
     f6b:	mov    rsi,r13
     f6e:	mov    rdi,r12
     f71:	call   f76 <botlish_fn_11+0x39>
			f72: R_X86_64_PLT32	botlish_fn_10-0x4 ; high_nibble<generic>
     f76:	test   rax,rax
     f79:	je     10a7 <botlish_fn_11+0x16a>
     f7f:	test   rax,0x1
     f85:	jne    f93 <botlish_fn_11+0x56>
     f8b:	mov    rdx,rax
     f8e:	jmp    fa9 <botlish_fn_11+0x6c>
     f93:	mov    rdx,QWORD PTR [rbx+0x8]
     f97:	mov    rcx,rax
     f9a:	sar    rcx,1
     f9d:	cmp    rcx,rdx
     fa0:	jb     fc5 <botlish_fn_11+0x88>
     fa6:	mov    rdx,rax
     fa9:	mov    rsi,rbx
     fac:	mov    rdi,r12
     faf:	call   fb4 <botlish_fn_11+0x77>
			fb0: R_X86_64_PLT32	rt_list_get-0x4
     fb4:	test   rax,rax
     fb7:	je     10a7 <botlish_fn_11+0x16a>
     fbd:	mov    rsi,rax
     fc0:	jmp    fcd <botlish_fn_11+0x90>
     fc5:	mov    rax,QWORD PTR [rbx+0x10]
     fc9:	mov    rsi,QWORD PTR [rax+rcx*8]
     fcd:	mov    QWORD PTR [rsp],rsi
     fd1:	mov    r14,rsi
     fd4:	mov    ecx,0x1
     fd9:	mov    rsi,r13
     fdc:	test   rsi,0x1
     fe3:	jne    1001 <botlish_fn_11+0xc4>
     fe9:	xor    ecx,ecx
     feb:	test   rsi,0x7
     ff2:	jne    1001 <botlish_fn_11+0xc4>
     ff8:	movzx  rax,BYTE PTR [rsi]
     ffc:	cmp    al,0x1
     ffe:	sete   cl
    1001:	test   cl,cl
    1003:	jne    1024 <botlish_fn_11+0xe7>
    1009:	mov    rdi,r12
    100c:	mov    rax,QWORD PTR [rdi+0x10]
    1010:	mov    rcx,QWORD PTR [rax+0xc0]
    1017:	xor    rdx,rdx
    101a:	call   101f <botlish_fn_11+0xe2>
			101b: R_X86_64_PLT32	rt_type_error-0x4
    101f:	jmp    10a7 <botlish_fn_11+0x16a>
    1024:	mov    edx,0x21
    1029:	mov    rdi,r12
    102c:	call   1031 <botlish_fn_11+0xf4>
			102d: R_X86_64_PLT32	rt_int_mod-0x4
    1031:	test   rax,rax
    1034:	je     10a7 <botlish_fn_11+0x16a>
    103a:	test   rax,0x1
    1040:	jne    1051 <botlish_fn_11+0x114>
    1046:	mov    rdx,rax
    1049:	mov    rsi,rbx
    104c:	jmp    106a <botlish_fn_11+0x12d>
    1051:	mov    rdi,QWORD PTR [rbx+0x8]
    1055:	mov    rsi,rax
    1058:	sar    rsi,1
    105b:	mov    rdx,rax
    105e:	cmp    rsi,rdi
    1061:	jb     1083 <botlish_fn_11+0x146>
    1067:	mov    rsi,rbx
    106a:	mov    rdi,r12
    106d:	call   1072 <botlish_fn_11+0x135>
			106e: R_X86_64_PLT32	rt_list_get-0x4
    1072:	test   rax,rax
    1075:	je     10a7 <botlish_fn_11+0x16a>
    107b:	mov    rdx,rax
    107e:	jmp    108e <botlish_fn_11+0x151>
    1083:	mov    rax,rbx
    1086:	mov    rax,QWORD PTR [rax+0x10]
    108a:	mov    rdx,QWORD PTR [rax+rsi*8]
    108e:	mov    QWORD PTR [rsp+0x8],rdx
    1093:	mov    rsi,r14
    1096:	mov    rdi,r12
    1099:	call   109e <botlish_fn_11+0x161>
			109a: R_X86_64_PLT32	rt_str_cat-0x4
    109e:	test   rax,rax
    10a1:	jne    10c7 <botlish_fn_11+0x18a>
    10a7:	xor    rax,rax
    10aa:	mov    rbx,QWORD PTR [rsp+0x10]
    10af:	mov    r12,QWORD PTR [rsp+0x18]
    10b4:	mov    r13,QWORD PTR [rsp+0x20]
    10b9:	mov    r14,QWORD PTR [rsp+0x28]
    10be:	add    rsp,0x30
    10c2:	mov    rsp,rbp
    10c5:	pop    rbp
    10c6:	ret
    10c7:	mov    rbx,QWORD PTR [rsp+0x10]
    10cc:	mov    r12,QWORD PTR [rsp+0x18]
    10d1:	mov    r13,QWORD PTR [rsp+0x20]
    10d6:	mov    r14,QWORD PTR [rsp+0x28]
    10db:	add    rsp,0x30
    10df:	mov    rsp,rbp
    10e2:	pop    rbp
    10e3:	ret

00000000000010e4 <botlish_entry_11: hex_pair<generic>>:
    10e4:	push   rbp
    10e5:	mov    rbp,rsp
    10e8:	mov    rsi,QWORD PTR [rdx]
    10eb:	mov    rdx,QWORD PTR [rdx+0x8]
    10ef:	call   10f4 <botlish_entry_11+0x10>
			10f0: R_X86_64_PLT32	botlish_fn_11-0x4 ; hex_pair<generic>
    10f4:	mov    rsp,rbp
    10f7:	pop    rbp
    10f8:	ret
    10f9:	add    BYTE PTR [rax],al
    10fb:	add    BYTE PTR [rax],al
    10fd:	add    BYTE PTR [rax],al
	...

0000000000001100 <botlish_fn_12: esc_bytes<generic>>:
    1100:	push   rbp
    1101:	mov    rbp,rsp
    1104:	sub    rsp,0x70
    1108:	mov    QWORD PTR [rsp+0x40],rbx
    110d:	mov    QWORD PTR [rsp+0x48],r12
    1112:	mov    QWORD PTR [rsp+0x50],r13
    1117:	mov    QWORD PTR [rsp+0x58],r14
    111c:	mov    QWORD PTR [rsp+0x60],r15
    1121:	mov    r13,rdi
    1124:	mov    QWORD PTR [rsp+0x28],0x0
    112d:	mov    QWORD PTR [rsp],rsi
    1131:	mov    QWORD PTR [rsp+0x8],rdx
    1136:	mov    QWORD PTR [rsp+0x10],rcx
    113b:	mov    QWORD PTR [rsp+0x18],r8
    1140:	mov    r12,r8
    1143:	mov    r14,rcx
    1146:	mov    r15,rdx
    1149:	xor    eax,eax
    114b:	test   rsi,0x7
    1152:	jne    1163 <botlish_fn_12+0x63>
    1158:	movzx  r8,BYTE PTR [rsi]
    115c:	cmp    r8b,0x3
    1160:	sete   al
    1163:	test   al,al
    1165:	jne    1188 <botlish_fn_12+0x88>
    116b:	mov    rdi,r13
    116e:	mov    rax,QWORD PTR [rdi+0x10]
    1172:	mov    rcx,QWORD PTR [rax+0xc8]
    1179:	mov    edx,0x4
    117e:	call   1183 <botlish_fn_12+0x83>
			117f: R_X86_64_PLT32	rt_type_error-0x4
    1183:	jmp    138e <botlish_fn_12+0x28e>
    1188:	mov    rbx,rsi
    118b:	mov    rdi,r13
    118e:	call   1193 <botlish_fn_12+0x93>
			118f: R_X86_64_PLT32	rt_list_len-0x4
    1193:	mov    ecx,0x1
    1198:	mov    rsi,r15
    119b:	test   rsi,0x1
    11a2:	jne    11c8 <botlish_fn_12+0xc8>
    11a8:	xor    ecx,ecx
    11aa:	mov    rsi,r15
    11ad:	test   rsi,0x7
    11b4:	jne    11c8 <botlish_fn_12+0xc8>
    11ba:	mov    rsi,r15
    11bd:	movzx  rcx,BYTE PTR [rsi]
    11c1:	rex cmp cl,0x1
    11c5:	sete   cl
    11c8:	test   cl,cl
    11ca:	jne    11ee <botlish_fn_12+0xee>
    11d0:	mov    rdi,r13
    11d3:	mov    rax,QWORD PTR [rdi+0x10]
    11d7:	mov    rcx,QWORD PTR [rax+0xa8]
    11de:	xor    rdx,rdx
    11e1:	mov    rsi,r15
    11e4:	call   11e9 <botlish_fn_12+0xe9>
			11e5: R_X86_64_PLT32	rt_type_error-0x4
    11e9:	jmp    138e <botlish_fn_12+0x28e>
    11ee:	mov    rsi,r15
    11f1:	mov    rcx,rsi
    11f4:	and    rcx,rax
    11f7:	mov    rdx,rax
    11fa:	test   rcx,0x1
    1201:	jne    1227 <botlish_fn_12+0x127>
    1207:	mov    rsi,r15
    120a:	mov    rdi,r13
    120d:	call   1212 <botlish_fn_12+0x112>
			120e: R_X86_64_PLT32	rt_int_cmp-0x4
    1212:	mov    ecx,0x2
    1217:	test   rax,rax
    121a:	cmovge rcx,QWORD PTR [rip+0x1de]        # 1400 <botlish_fn_12+0x300>
    1222:	jmp    123a <botlish_fn_12+0x13a>
    1227:	mov    ecx,0x2
    122c:	mov    rsi,r15
    122f:	cmp    rsi,rdx
    1232:	cmovge rcx,QWORD PTR [rip+0x1c6]        # 1400 <botlish_fn_12+0x300>
    123a:	cmp    rcx,0x6
    123e:	je     13d9 <botlish_fn_12+0x2d9>
    1244:	mov    QWORD PTR [rsp+0x20],0x3
    124d:	mov    rsi,r15
    1250:	test   rsi,0x1
    1257:	je     1272 <botlish_fn_12+0x172>
    125d:	mov    rsi,r15
    1260:	mov    rax,rsi
    1263:	add    rax,0x2
    1267:	seto   cl
    126a:	test   cl,cl
    126c:	je     1282 <botlish_fn_12+0x182>
    1272:	mov    edx,0x3
    1277:	mov    rsi,r15
    127a:	mov    rdi,r13
    127d:	call   1282 <botlish_fn_12+0x182>
			127e: R_X86_64_PLT32	rt_int_add-0x4
    1282:	mov    QWORD PTR [rsp+0x8],rax
    1287:	mov    rdi,r13
    128a:	mov    QWORD PTR [rsp+0x30],rax
    128f:	mov    rax,QWORD PTR [rdi+0x10]
    1293:	mov    rsi,QWORD PTR [rax+0xd0]
    129a:	mov    QWORD PTR [rsp+0x20],rsi
    129f:	mov    QWORD PTR [rsp+0x38],rsi
    12a4:	mov    rsi,r15
    12a7:	test   rsi,0x1
    12ae:	jne    12bc <botlish_fn_12+0x1bc>
    12b4:	mov    rdx,r15
    12b7:	jmp    12d5 <botlish_fn_12+0x1d5>
    12bc:	mov    rcx,QWORD PTR [rbx+0x8]
    12c0:	mov    rsi,r15
    12c3:	mov    rax,rsi
    12c6:	sar    rax,1
    12c9:	cmp    rax,rcx
    12cc:	jb     12f1 <botlish_fn_12+0x1f1>
    12d2:	mov    rdx,r15
    12d5:	mov    rsi,rbx
    12d8:	mov    rdi,r13
    12db:	call   12e0 <botlish_fn_12+0x1e0>
			12dc: R_X86_64_PLT32	rt_list_get-0x4
    12e0:	test   rax,rax
    12e3:	je     138e <botlish_fn_12+0x28e>
    12e9:	mov    rsi,rax
    12ec:	jmp    12f9 <botlish_fn_12+0x1f9>
    12f1:	mov    rcx,QWORD PTR [rbx+0x10]
    12f5:	mov    rsi,QWORD PTR [rcx+rax*8]
    12f9:	mov    QWORD PTR [rsp+0x28],rsi
    12fe:	mov    rdx,r12
    1301:	mov    rdi,r13
    1304:	call   1309 <botlish_fn_12+0x209>
			1305: R_X86_64_PLT32	botlish_fn_11-0x4 ; hex_pair<generic>
    1309:	test   rax,rax
    130c:	je     138e <botlish_fn_12+0x28e>
    1312:	mov    QWORD PTR [rsp+0x28],rax
    1317:	mov    rdx,rax
    131a:	mov    rsi,QWORD PTR [rsp+0x38]
    131f:	mov    rdi,r13
    1322:	call   1327 <botlish_fn_12+0x227>
			1323: R_X86_64_PLT32	rt_str_cat-0x4
    1327:	test   rax,rax
    132a:	je     138e <botlish_fn_12+0x28e>
    1330:	mov    QWORD PTR [rsp+0x20],rax
    1335:	mov    rdx,rax
    1338:	xor    eax,eax
    133a:	mov    rsi,r14
    133d:	test   rsi,0x7
    1344:	jne    1355 <botlish_fn_12+0x255>
    134a:	movzx  rdi,BYTE PTR [rsi]
    134e:	cmp    dil,0x2
    1352:	sete   al
    1355:	test   al,al
    1357:	jne    137d <botlish_fn_12+0x27d>
    135d:	mov    rdi,r13
    1360:	mov    rdi,QWORD PTR [rdi+0x10]
    1364:	mov    rcx,QWORD PTR [rdi+0xd8]
    136b:	mov    edx,0x1
    1370:	mov    rdi,r13
    1373:	call   1378 <botlish_fn_12+0x278>
			1374: R_X86_64_PLT32	rt_type_error-0x4
    1378:	jmp    138e <botlish_fn_12+0x28e>
    137d:	mov    rdi,r13
    1380:	call   1385 <botlish_fn_12+0x285>
			1381: R_X86_64_PLT32	rt_str_cat-0x4
    1385:	test   rax,rax
    1388:	jne    13b3 <botlish_fn_12+0x2b3>
    138e:	xor    rax,rax
    1391:	mov    rbx,QWORD PTR [rsp+0x40]
    1396:	mov    r12,QWORD PTR [rsp+0x48]
    139b:	mov    r13,QWORD PTR [rsp+0x50]
    13a0:	mov    r14,QWORD PTR [rsp+0x58]
    13a5:	mov    r15,QWORD PTR [rsp+0x60]
    13aa:	add    rsp,0x70
    13ae:	mov    rsp,rbp
    13b1:	pop    rbp
    13b2:	ret
    13b3:	mov    QWORD PTR [rsp],rbx
    13b7:	mov    rcx,QWORD PTR [rsp+0x30]
    13bc:	mov    QWORD PTR [rsp+0x8],rcx
    13c1:	mov    QWORD PTR [rsp+0x10],rax
    13c6:	mov    QWORD PTR [rsp+0x18],r12
    13cb:	mov    rsi,rbx
    13ce:	mov    r14,rax
    13d1:	mov    r15,rcx
    13d4:	jmp    1149 <botlish_fn_12+0x49>
    13d9:	mov    rax,r14
    13dc:	mov    rbx,QWORD PTR [rsp+0x40]
    13e1:	mov    r12,QWORD PTR [rsp+0x48]
    13e6:	mov    r13,QWORD PTR [rsp+0x50]
    13eb:	mov    r14,QWORD PTR [rsp+0x58]
    13f0:	mov    r15,QWORD PTR [rsp+0x60]
    13f5:	add    rsp,0x70
    13f9:	mov    rsp,rbp
    13fc:	pop    rbp
    13fd:	ret
    13fe:	add    BYTE PTR [rax],al
    1400:	(bad)
    1401:	add    BYTE PTR [rax],al
    1403:	add    BYTE PTR [rax],al
    1405:	add    BYTE PTR [rax],al
	...

0000000000001408 <botlish_entry_12: esc_bytes<generic>>:
    1408:	push   rbp
    1409:	mov    rbp,rsp
    140c:	mov    rsi,QWORD PTR [rdx]
    140f:	mov    r9,QWORD PTR [rdx+0x8]
    1413:	mov    rcx,QWORD PTR [rdx+0x10]
    1417:	mov    r8,QWORD PTR [rdx+0x18]
    141b:	mov    rdx,r9
    141e:	call   1423 <botlish_entry_12+0x1b>
			141f: R_X86_64_PLT32	botlish_fn_12-0x4 ; esc_bytes<generic>
    1423:	mov    rsp,rbp
    1426:	pop    rbp
    1427:	ret

0000000000001428 <botlish_fn_13: esc_char<generic>>:
    1428:	push   rbp
    1429:	mov    rbp,rsp
    142c:	sub    rsp,0x60
    1430:	mov    QWORD PTR [rsp+0x30],rbx
    1435:	mov    QWORD PTR [rsp+0x38],r12
    143a:	mov    QWORD PTR [rsp+0x40],r13
    143f:	mov    QWORD PTR [rsp+0x48],r14
    1444:	mov    QWORD PTR [rsp+0x50],r15
    1449:	mov    QWORD PTR [rsp+0x18],0x0
    1452:	mov    QWORD PTR [rsp],rsi
    1456:	mov    QWORD PTR [rsp+0x8],rdx
    145b:	mov    r14,rdx
    145e:	mov    QWORD PTR [rsp+0x10],rcx
    1463:	mov    r12,rcx
    1466:	xor    r10d,r10d
    1469:	test   rsi,0x7
    1470:	jne    1482 <botlish_fn_13+0x5a>
    1476:	movzx  r8,BYTE PTR [rsi]
    147a:	cmp    r8b,0x2
    147e:	sete   r10b
    1482:	test   r10b,r10b
    1485:	jne    14a5 <botlish_fn_13+0x7d>
    148b:	mov    r10,QWORD PTR [rdi+0x10]
    148f:	mov    rcx,QWORD PTR [r10+0xe0]
    1496:	mov    edx,0x1
    149b:	call   14a0 <botlish_fn_13+0x78>
			149c: R_X86_64_PLT32	rt_type_error-0x4
    14a0:	jmp    16d5 <botlish_fn_13+0x2ad>
    14a5:	mov    r13,rdi
    14a8:	mov    QWORD PTR [rsp+0x20],rsi
    14ad:	call   14b2 <botlish_fn_13+0x8a>
			14ae: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    14b2:	mov    rcx,rax
    14b5:	mov    r15,rax
    14b8:	test   rax,rcx
    14bb:	je     16d5 <botlish_fn_13+0x2ad>
    14c1:	mov    rax,r15
    14c4:	mov    QWORD PTR [rsp],rax
    14c8:	mov    rsi,r15
    14cb:	mov    rdi,r13
    14ce:	call   14d3 <botlish_fn_13+0xab>
			14cf: R_X86_64_PLT32	rt_list_len-0x4
    14d3:	mov    edx,0x1
    14d8:	sar    rax,1
    14db:	cmp    rax,0x1
    14df:	je     151a <botlish_fn_13+0xf2>
    14e5:	mov    QWORD PTR [rsp+0x8],0x1
    14ee:	mov    rdi,r13
    14f1:	mov    rax,QWORD PTR [rdi+0x10]
    14f5:	mov    rcx,QWORD PTR [rax+0xb0]
    14fc:	mov    QWORD PTR [rsp+0x18],rcx
    1501:	mov    rsi,r15
    1504:	mov    r8,r12
    1507:	call   150c <botlish_fn_13+0xe4>
			1508: R_X86_64_PLT32	botlish_fn_12-0x4 ; esc_bytes<generic>
    150c:	test   rax,rax
    150f:	je     16d5 <botlish_fn_13+0x2ad>
    1515:	jmp    1704 <botlish_fn_13+0x2dc>
    151a:	mov    rsi,r15
    151d:	mov    QWORD PTR [rsp+0x28],rdx
    1522:	mov    rax,QWORD PTR [rsi+0x8]
    1526:	mov    r15,rsi
    1529:	test   rax,rax
    152c:	jne    1553 <botlish_fn_13+0x12b>
    1532:	mov    rdx,QWORD PTR [rsp+0x28]
    1537:	mov    rsi,r15
    153a:	mov    rdi,r13
    153d:	call   1542 <botlish_fn_13+0x11a>
			153e: R_X86_64_PLT32	rt_list_get-0x4
    1542:	test   rax,rax
    1545:	je     16d5 <botlish_fn_13+0x2ad>
    154b:	mov    rsi,rax
    154e:	jmp    1560 <botlish_fn_13+0x138>
    1553:	mov    rsi,r15
    1556:	mov    rax,QWORD PTR [rsi+0x10]
    155a:	mov    rax,QWORD PTR [rax]
    155d:	mov    rsi,rax
    1560:	mov    eax,0x1
    1565:	test   rsi,0x1
    156c:	jne    158a <botlish_fn_13+0x162>
    1572:	xor    eax,eax
    1574:	test   rsi,0x7
    157b:	jne    158a <botlish_fn_13+0x162>
    1581:	movzx  rax,BYTE PTR [rsi]
    1585:	cmp    al,0x1
    1587:	sete   al
    158a:	test   al,al
    158c:	jne    15ad <botlish_fn_13+0x185>
    1592:	mov    rdi,r13
    1595:	mov    rax,QWORD PTR [rdi+0x10]
    1599:	mov    rcx,QWORD PTR [rax+0xe8]
    15a0:	xor    rdx,rdx
    15a3:	call   15a8 <botlish_fn_13+0x180>
			15a4: R_X86_64_PLT32	rt_type_error-0x4
    15a8:	jmp    16d5 <botlish_fn_13+0x2ad>
    15ad:	test   rsi,0x1
    15b4:	mov    rdx,rsi
    15b7:	jne    15e5 <botlish_fn_13+0x1bd>
    15bd:	mov    rbx,rdx
    15c0:	mov    rdx,QWORD PTR [rsp+0x28]
    15c5:	mov    rsi,rbx
    15c8:	mov    rdi,r13
    15cb:	call   15d0 <botlish_fn_13+0x1a8>
			15cc: R_X86_64_PLT32	rt_int_cmp-0x4
    15d0:	mov    ecx,0x2
    15d5:	test   rax,rax
    15d8:	cmovge rcx,QWORD PTR [rip+0x148]        # 1728 <botlish_fn_13+0x300>
    15e0:	jmp    15f8 <botlish_fn_13+0x1d0>
    15e5:	mov    rbx,rdx
    15e8:	mov    ecx,0x2
    15ed:	test   rbx,rbx
    15f0:	cmovg  rcx,QWORD PTR [rip+0x130]        # 1728 <botlish_fn_13+0x300>
    15f8:	cmp    rcx,0x6
    15fc:	je     160a <botlish_fn_13+0x1e2>
    1602:	mov    rdi,r13
    1605:	jmp    1663 <botlish_fn_13+0x23b>
    160a:	test   rbx,0x1
    1611:	jne    163f <botlish_fn_13+0x217>
    1617:	mov    edx,0x1ff
    161c:	mov    rsi,rbx
    161f:	mov    rdi,r13
    1622:	call   1627 <botlish_fn_13+0x1ff>
			1623: R_X86_64_PLT32	rt_int_cmp-0x4
    1627:	mov    ecx,0x2
    162c:	test   rax,rax
    162f:	cmovle rcx,QWORD PTR [rip+0xf1]        # 1728 <botlish_fn_13+0x300>
    1637:	mov    rdx,rbx
    163a:	jmp    1656 <botlish_fn_13+0x22e>
    163f:	mov    ecx,0x2
    1644:	cmp    rbx,0x1ff
    164b:	mov    rdx,rbx
    164e:	cmovle rcx,QWORD PTR [rip+0xd2]        # 1728 <botlish_fn_13+0x300>
    1656:	cmp    rcx,0x6
    165a:	je     1682 <botlish_fn_13+0x25a>
    1660:	mov    rdi,r13
    1663:	mov    rdi,r13
    1666:	mov    rax,QWORD PTR [rdi+0x10]
    166a:	mov    rsi,QWORD PTR [rax+0x98]
    1671:	mov    rdx,QWORD PTR [rax+0xa0]
    1678:	call   167d <botlish_fn_13+0x255>
			1679: R_X86_64_PLT32	rt_raise-0x4
    167d:	jmp    16d5 <botlish_fn_13+0x2ad>
    1682:	mov    rsi,r14
    1685:	mov    rdi,r13
    1688:	call   168d <botlish_fn_13+0x265>
			1689: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::is_unreserved<generic>
    168d:	test   rax,rax
    1690:	je     16d5 <botlish_fn_13+0x2ad>
    1696:	cmp    rax,0x6
    169a:	je     16ff <botlish_fn_13+0x2d7>
    16a0:	mov    QWORD PTR [rsp+0x8],0x1
    16a9:	mov    rdi,r13
    16ac:	mov    rsi,QWORD PTR [rdi+0x10]
    16b0:	mov    rcx,QWORD PTR [rsi+0xb0]
    16b7:	mov    QWORD PTR [rsp+0x18],rcx
    16bc:	mov    rdx,QWORD PTR [rsp+0x28]
    16c1:	mov    rsi,r15
    16c4:	mov    r8,r12
    16c7:	call   16cc <botlish_fn_13+0x2a4>
			16c8: R_X86_64_PLT32	botlish_fn_12-0x4 ; esc_bytes<generic>
    16cc:	test   rax,rax
    16cf:	jne    16fa <botlish_fn_13+0x2d2>
    16d5:	xor    rax,rax
    16d8:	mov    rbx,QWORD PTR [rsp+0x30]
    16dd:	mov    r12,QWORD PTR [rsp+0x38]
    16e2:	mov    r13,QWORD PTR [rsp+0x40]
    16e7:	mov    r14,QWORD PTR [rsp+0x48]
    16ec:	mov    r15,QWORD PTR [rsp+0x50]
    16f1:	add    rsp,0x60
    16f5:	mov    rsp,rbp
    16f8:	pop    rbp
    16f9:	ret
    16fa:	mov    QWORD PTR [rsp+0x20],rax
    16ff:	mov    rax,QWORD PTR [rsp+0x20]
    1704:	mov    rbx,QWORD PTR [rsp+0x30]
    1709:	mov    r12,QWORD PTR [rsp+0x38]
    170e:	mov    r13,QWORD PTR [rsp+0x40]
    1713:	mov    r14,QWORD PTR [rsp+0x48]
    1718:	mov    r15,QWORD PTR [rsp+0x50]
    171d:	add    rsp,0x60
    1721:	mov    rsp,rbp
    1724:	pop    rbp
    1725:	ret
    1726:	add    BYTE PTR [rax],al
    1728:	(bad)
    1729:	add    BYTE PTR [rax],al
    172b:	add    BYTE PTR [rax],al
    172d:	add    BYTE PTR [rax],al
	...

0000000000001730 <botlish_entry_13: esc_char<generic>>:
    1730:	push   rbp
    1731:	mov    rbp,rsp
    1734:	mov    rsi,QWORD PTR [rdx]
    1737:	mov    r8,QWORD PTR [rdx+0x8]
    173b:	mov    rcx,QWORD PTR [rdx+0x10]
    173f:	mov    rdx,r8
    1742:	call   1747 <botlish_entry_13+0x17>
			1743: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_char<generic>
    1747:	mov    rsp,rbp
    174a:	pop    rbp
    174b:	ret
    174c:	add    BYTE PTR [rax],al
	...

0000000000001750 <botlish_fn_14: esc_from<generic>>:
    1750:	push   rbp
    1751:	mov    rbp,rsp
    1754:	sub    rsp,0x80
    175b:	mov    QWORD PTR [rsp+0x50],rbx
    1760:	mov    QWORD PTR [rsp+0x58],r12
    1765:	mov    QWORD PTR [rsp+0x60],r13
    176a:	mov    QWORD PTR [rsp+0x68],r14
    176f:	mov    QWORD PTR [rsp+0x70],r15
    1774:	mov    r14,rdi
    1777:	mov    QWORD PTR [rsp+0x30],0x0
    1780:	mov    QWORD PTR [rsp],rsi
    1784:	mov    QWORD PTR [rsp+0x8],rdx
    1789:	mov    QWORD PTR [rsp+0x10],rcx
    178e:	mov    QWORD PTR [rsp+0x18],r8
    1793:	mov    r13,r8
    1796:	mov    QWORD PTR [rsp+0x20],r9
    179b:	mov    r12,r9
    179e:	mov    r15,rcx
    17a1:	mov    QWORD PTR [rsp+0x38],rdx
    17a6:	xor    eax,eax
    17a8:	test   rsi,0x7
    17af:	jne    17be <botlish_fn_14+0x6e>
    17b5:	movzx  rax,BYTE PTR [rsi]
    17b9:	cmp    al,0x2
    17bb:	sete   al
    17be:	test   al,al
    17c0:	jne    17e3 <botlish_fn_14+0x93>
    17c6:	mov    rdi,r14
    17c9:	mov    rax,QWORD PTR [rdi+0x10]
    17cd:	mov    rcx,QWORD PTR [rax+0xf0]
    17d4:	mov    edx,0x1
    17d9:	call   17de <botlish_fn_14+0x8e>
			17da: R_X86_64_PLT32	rt_type_error-0x4
    17de:	jmp    1a3b <botlish_fn_14+0x2eb>
    17e3:	mov    rbx,rsi
    17e6:	mov    rdi,r14
    17e9:	call   17ee <botlish_fn_14+0x9e>
			17ea: R_X86_64_PLT32	rt_str_len-0x4
    17ee:	mov    edx,0x1
    17f3:	mov    QWORD PTR [rsp+0x48],rdx
    17f8:	mov    ecx,0x1
    17fd:	mov    rsi,QWORD PTR [rsp+0x38]
    1802:	test   rsi,0x1
    1809:	jne    1833 <botlish_fn_14+0xe3>
    180f:	xor    ecx,ecx
    1811:	mov    rsi,QWORD PTR [rsp+0x38]
    1816:	test   rsi,0x7
    181d:	jne    1833 <botlish_fn_14+0xe3>
    1823:	mov    rsi,QWORD PTR [rsp+0x38]
    1828:	movzx  rcx,BYTE PTR [rsi]
    182c:	rex cmp cl,0x1
    1830:	sete   cl
    1833:	test   cl,cl
    1835:	jne    185b <botlish_fn_14+0x10b>
    183b:	mov    rdi,r14
    183e:	mov    rax,QWORD PTR [rdi+0x10]
    1842:	mov    rcx,QWORD PTR [rax+0xa8]
    1849:	xor    rdx,rdx
    184c:	mov    rsi,QWORD PTR [rsp+0x38]
    1851:	call   1856 <botlish_fn_14+0x106>
			1852: R_X86_64_PLT32	rt_type_error-0x4
    1856:	jmp    1a3b <botlish_fn_14+0x2eb>
    185b:	mov    rsi,QWORD PTR [rsp+0x38]
    1860:	mov    rcx,rsi
    1863:	and    rcx,rax
    1866:	mov    rdx,rax
    1869:	test   rcx,0x1
    1870:	jne    1898 <botlish_fn_14+0x148>
    1876:	mov    rsi,QWORD PTR [rsp+0x38]
    187b:	mov    rdi,r14
    187e:	call   1883 <botlish_fn_14+0x133>
			187f: R_X86_64_PLT32	rt_int_cmp-0x4
    1883:	mov    ecx,0x2
    1888:	test   rax,rax
    188b:	cmovge rcx,QWORD PTR [rip+0x235]        # 1ac8 <botlish_fn_14+0x378>
    1893:	jmp    18ad <botlish_fn_14+0x15d>
    1898:	mov    ecx,0x2
    189d:	mov    rsi,QWORD PTR [rsp+0x38]
    18a2:	cmp    rsi,rdx
    18a5:	cmovge rcx,QWORD PTR [rip+0x21b]        # 1ac8 <botlish_fn_14+0x378>
    18ad:	cmp    rcx,0x6
    18b1:	je     1a99 <botlish_fn_14+0x349>
    18b7:	mov    QWORD PTR [rsp+0x28],0x3
    18c0:	mov    rsi,QWORD PTR [rsp+0x38]
    18c5:	test   rsi,0x1
    18cc:	je     18e9 <botlish_fn_14+0x199>
    18d2:	mov    rsi,QWORD PTR [rsp+0x38]
    18d7:	mov    rax,rsi
    18da:	add    rax,0x2
    18de:	seto   cl
    18e1:	test   cl,cl
    18e3:	je     18fb <botlish_fn_14+0x1ab>
    18e9:	mov    edx,0x3
    18ee:	mov    rsi,QWORD PTR [rsp+0x38]
    18f3:	mov    rdi,r14
    18f6:	call   18fb <botlish_fn_14+0x1ab>
			18f7: R_X86_64_PLT32	rt_int_add-0x4
    18fb:	mov    QWORD PTR [rsp+0x28],rax
    1900:	mov    QWORD PTR [rsp+0x40],rax
    1905:	mov    QWORD PTR [rsp+0x30],0x3
    190e:	mov    rsi,QWORD PTR [rsp+0x38]
    1913:	test   rsi,0x1
    191a:	je     1937 <botlish_fn_14+0x1e7>
    1920:	mov    rsi,QWORD PTR [rsp+0x38]
    1925:	mov    rcx,rsi
    1928:	add    rcx,0x2
    192c:	seto   al
    192f:	test   al,al
    1931:	je     194c <botlish_fn_14+0x1fc>
    1937:	mov    edx,0x3
    193c:	mov    rsi,QWORD PTR [rsp+0x38]
    1941:	mov    rdi,r14
    1944:	call   1949 <botlish_fn_14+0x1f9>
			1945: R_X86_64_PLT32	rt_int_add-0x4
    1949:	mov    rcx,rax
    194c:	mov    QWORD PTR [rsp+0x30],rcx
    1951:	mov    rdx,QWORD PTR [rsp+0x38]
    1956:	mov    rsi,rbx
    1959:	mov    rdi,r14
    195c:	call   1961 <botlish_fn_14+0x211>
			195d: R_X86_64_PLT32	rt_substr-0x4
    1961:	test   rax,rax
    1964:	je     1a3b <botlish_fn_14+0x2eb>
    196a:	mov    QWORD PTR [rsp+0x8],rax
    196f:	mov    r8,r12
    1972:	mov    r12,r13
    1975:	mov    r13,r8
    1978:	mov    rsi,rax
    197b:	mov    rcx,r13
    197e:	mov    rdx,r12
    1981:	mov    rdi,r14
    1984:	call   1989 <botlish_fn_14+0x239>
			1985: R_X86_64_PLT32	botlish_fn_13-0x4 ; esc_char<generic>
    1989:	test   rax,rax
    198c:	je     1a3b <botlish_fn_14+0x2eb>
    1992:	mov    QWORD PTR [rsp+0x8],rax
    1997:	xor    ecx,ecx
    1999:	mov    rsi,r15
    199c:	test   rsi,0x7
    19a3:	jne    19b4 <botlish_fn_14+0x264>
    19a9:	movzx  rdi,BYTE PTR [rsi]
    19ad:	cmp    dil,0x2
    19b1:	sete   cl
    19b4:	test   cl,cl
    19b6:	jne    19d9 <botlish_fn_14+0x289>
    19bc:	mov    rdi,r14
    19bf:	mov    r11,QWORD PTR [rdi+0x10]
    19c3:	mov    rcx,QWORD PTR [r11+0xd8]
    19ca:	mov    rdx,QWORD PTR [rsp+0x48]
    19cf:	call   19d4 <botlish_fn_14+0x284>
			19d0: R_X86_64_PLT32	rt_type_error-0x4
    19d4:	jmp    1a3b <botlish_fn_14+0x2eb>
    19d9:	mov    rdx,QWORD PTR [rsp+0x48]
    19de:	xor    edi,edi
    19e0:	test   rax,0x7
    19e6:	je     19f4 <botlish_fn_14+0x2a4>
    19ec:	mov    r8,rax
    19ef:	jmp    1a03 <botlish_fn_14+0x2b3>
    19f4:	movzx  rcx,BYTE PTR [rax]
    19f8:	mov    r8,rax
    19fb:	rex cmp cl,0x2
    19ff:	sete   dil
    1a03:	test   dil,dil
    1a06:	jne    1a27 <botlish_fn_14+0x2d7>
    1a0c:	mov    rdi,r14
    1a0f:	mov    rax,QWORD PTR [rdi+0x10]
    1a13:	mov    rcx,QWORD PTR [rax+0xd8]
    1a1a:	mov    rsi,r8
    1a1d:	call   1a22 <botlish_fn_14+0x2d2>
			1a1e: R_X86_64_PLT32	rt_type_error-0x4
    1a22:	jmp    1a3b <botlish_fn_14+0x2eb>
    1a27:	mov    rdx,r8
    1a2a:	mov    rdi,r14
    1a2d:	call   1a32 <botlish_fn_14+0x2e2>
			1a2e: R_X86_64_PLT32	rt_str_cat-0x4
    1a32:	test   rax,rax
    1a35:	jne    1a63 <botlish_fn_14+0x313>
    1a3b:	xor    rax,rax
    1a3e:	mov    rbx,QWORD PTR [rsp+0x50]
    1a43:	mov    r12,QWORD PTR [rsp+0x58]
    1a48:	mov    r13,QWORD PTR [rsp+0x60]
    1a4d:	mov    r14,QWORD PTR [rsp+0x68]
    1a52:	mov    r15,QWORD PTR [rsp+0x70]
    1a57:	add    rsp,0x80
    1a5e:	mov    rsp,rbp
    1a61:	pop    rbp
    1a62:	ret
    1a63:	mov    QWORD PTR [rsp],rbx
    1a67:	mov    rcx,QWORD PTR [rsp+0x40]
    1a6c:	mov    QWORD PTR [rsp+0x8],rcx
    1a71:	mov    QWORD PTR [rsp+0x10],rax
    1a76:	mov    QWORD PTR [rsp+0x18],r12
    1a7b:	mov    QWORD PTR [rsp+0x20],r13
    1a80:	mov    QWORD PTR [rsp+0x38],rcx
    1a85:	mov    r15,rax
    1a88:	mov    rdx,r12
    1a8b:	mov    r12,r13
    1a8e:	mov    r13,rdx
    1a91:	mov    rsi,rbx
    1a94:	jmp    17a6 <botlish_fn_14+0x56>
    1a99:	mov    rax,r15
    1a9c:	mov    rbx,QWORD PTR [rsp+0x50]
    1aa1:	mov    r12,QWORD PTR [rsp+0x58]
    1aa6:	mov    r13,QWORD PTR [rsp+0x60]
    1aab:	mov    r14,QWORD PTR [rsp+0x68]
    1ab0:	mov    r15,QWORD PTR [rsp+0x70]
    1ab5:	add    rsp,0x80
    1abc:	mov    rsp,rbp
    1abf:	pop    rbp
    1ac0:	ret
    1ac1:	add    BYTE PTR [rax],al
    1ac3:	add    BYTE PTR [rax],al
    1ac5:	add    BYTE PTR [rax],al
    1ac7:	add    BYTE PTR [rsi],al
    1ac9:	add    BYTE PTR [rax],al
    1acb:	add    BYTE PTR [rax],al
    1acd:	add    BYTE PTR [rax],al
	...

0000000000001ad0 <botlish_entry_14: esc_from<generic>>:
    1ad0:	push   rbp
    1ad1:	mov    rbp,rsp
    1ad4:	mov    rsi,QWORD PTR [rdx]
    1ad7:	mov    r10,QWORD PTR [rdx+0x8]
    1adb:	mov    rcx,QWORD PTR [rdx+0x10]
    1adf:	mov    r8,QWORD PTR [rdx+0x18]
    1ae3:	mov    r9,QWORD PTR [rdx+0x20]
    1ae7:	mov    rdx,r10
    1aea:	call   1aef <botlish_entry_14+0x1f>
			1aeb: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_from<generic>
    1aef:	mov    rsp,rbp
    1af2:	pop    rbp
    1af3:	ret
    1af4:	add    BYTE PTR [rax],al
	...

0000000000001af8 <botlish_fn_15: check<int, int, str, str>>:
    1af8:	push   rbp
    1af9:	mov    rbp,rsp
    1afc:	sub    rsp,0x60
    1b00:	mov    QWORD PTR [rsp+0x30],rbx
    1b05:	mov    QWORD PTR [rsp+0x38],r12
    1b0a:	mov    QWORD PTR [rsp+0x40],r13
    1b0f:	mov    QWORD PTR [rsp+0x48],r14
    1b14:	mov    QWORD PTR [rsp+0x50],r15
    1b19:	mov    QWORD PTR [rsp+0x20],0x0
    1b22:	mov    QWORD PTR [rsp],rsi
    1b26:	mov    QWORD PTR [rsp+0x8],rdx
    1b2b:	mov    QWORD PTR [rsp+0x10],rcx
    1b30:	mov    r12,rcx
    1b33:	mov    QWORD PTR [rsp+0x18],r8
    1b38:	mov    r14,r8
    1b3b:	mov    r13,rsi
    1b3e:	mov    r15,rdx
    1b41:	test   r13,0x1
    1b48:	jne    1b73 <botlish_fn_15+0x7b>
    1b4e:	mov    edx,0x1
    1b53:	mov    rbx,rdi
    1b56:	mov    rsi,r13
    1b59:	call   1b5e <botlish_fn_15+0x66>
			1b5a: R_X86_64_PLT32	rt_int_cmp-0x4
    1b5e:	mov    ecx,0x2
    1b63:	test   rax,rax
    1b66:	cmovle rcx,QWORD PTR [rip+0x152]        # 1cc0 <botlish_fn_15+0x1c8>
    1b6e:	jmp    1b87 <botlish_fn_15+0x8f>
    1b73:	mov    rbx,rdi
    1b76:	mov    ecx,0x2
    1b7b:	cmp    r13,0x1
    1b7f:	cmovle rcx,QWORD PTR [rip+0x139]        # 1cc0 <botlish_fn_15+0x1c8>
    1b87:	cmp    rcx,0x6
    1b8b:	je     1c94 <botlish_fn_15+0x19c>
    1b91:	mov    rax,QWORD PTR [rbx+0x10]
    1b95:	mov    rax,QWORD PTR [rax+0xf8]
    1b9c:	mov    rsi,r12
    1b9f:	mov    rdi,rbx
    1ba2:	call   1ba7 <botlish_fn_15+0xaf>
			1ba3: R_X86_64_PLT32	botlish_fn_16-0x4 ; <str>
    1ba7:	test   rax,rax
    1baa:	je     1beb <botlish_fn_15+0xf3>
    1bb0:	cmp    rax,0x6
    1bb4:	je     1bcc <botlish_fn_15+0xd4>
    1bba:	mov    edx,0x1
    1bbf:	mov    QWORD PTR [rsp],0x1
    1bc7:	jmp    1c2d <botlish_fn_15+0x135>
    1bcc:	mov    rax,QWORD PTR [rbx+0x10]
    1bd0:	mov    rax,QWORD PTR [rax+0x100]
    1bd7:	mov    rsi,r12
    1bda:	mov    rdi,rbx
    1bdd:	call   1be2 <botlish_fn_15+0xea>
			1bde: R_X86_64_PLT32	botlish_fn_24-0x4 ; <str>
    1be2:	test   rax,rax
    1be5:	jne    1c10 <botlish_fn_15+0x118>
    1beb:	xor    rax,rax
    1bee:	mov    rbx,QWORD PTR [rsp+0x30]
    1bf3:	mov    r12,QWORD PTR [rsp+0x38]
    1bf8:	mov    r13,QWORD PTR [rsp+0x40]
    1bfd:	mov    r14,QWORD PTR [rsp+0x48]
    1c02:	mov    r15,QWORD PTR [rsp+0x50]
    1c07:	add    rsp,0x60
    1c0b:	mov    rsp,rbp
    1c0e:	pop    rbp
    1c0f:	ret
    1c10:	cmp    rax,0x6
    1c14:	je     1c24 <botlish_fn_15+0x12c>
    1c1a:	mov    edx,0x1
    1c1f:	jmp    1c29 <botlish_fn_15+0x131>
    1c24:	mov    edx,0x3
    1c29:	mov    QWORD PTR [rsp],rdx
    1c2d:	sar    r13,1
    1c30:	sub    r13,0x1
    1c34:	shl    r13,1
    1c37:	or     r13,0x1
    1c3b:	mov    QWORD PTR [rsp+0x20],r13
    1c40:	mov    rsi,r15
    1c43:	mov    r8,rsi
    1c46:	and    r8,rdx
    1c49:	test   r8,0x1
    1c50:	je     1c6b <botlish_fn_15+0x173>
    1c56:	lea    r11,[rdx-0x1]
    1c5a:	mov    rax,rsi
    1c5d:	add    rax,r11
    1c60:	seto   cl
    1c63:	test   cl,cl
    1c65:	je     1c73 <botlish_fn_15+0x17b>
    1c6b:	mov    rdi,rbx
    1c6e:	call   1c73 <botlish_fn_15+0x17b>
			1c6f: R_X86_64_PLT32	rt_int_add-0x4
    1c73:	mov    QWORD PTR [rsp],r13
    1c77:	mov    QWORD PTR [rsp+0x8],rax
    1c7c:	mov    QWORD PTR [rsp+0x10],r12
    1c81:	mov    r8,r14
    1c84:	mov    QWORD PTR [rsp+0x18],r8
    1c89:	mov    rdi,rbx
    1c8c:	mov    r15,rax
    1c8f:	jmp    1b41 <botlish_fn_15+0x49>
    1c94:	mov    rax,r15
    1c97:	mov    rbx,QWORD PTR [rsp+0x30]
    1c9c:	mov    r12,QWORD PTR [rsp+0x38]
    1ca1:	mov    r13,QWORD PTR [rsp+0x40]
    1ca6:	mov    r14,QWORD PTR [rsp+0x48]
    1cab:	mov    r15,QWORD PTR [rsp+0x50]
    1cb0:	add    rsp,0x60
    1cb4:	mov    rsp,rbp
    1cb7:	pop    rbp
    1cb8:	ret
    1cb9:	add    BYTE PTR [rax],al
    1cbb:	add    BYTE PTR [rax],al
    1cbd:	add    BYTE PTR [rax],al
    1cbf:	add    BYTE PTR [rsi],al
    1cc1:	add    BYTE PTR [rax],al
    1cc3:	add    BYTE PTR [rax],al
    1cc5:	add    BYTE PTR [rax],al
	...

0000000000001cc8 <botlish_entry_15: check<int, int, str, str>>:
    1cc8:	push   rbp
    1cc9:	mov    rbp,rsp
    1ccc:	mov    rsi,QWORD PTR [rdx]
    1ccf:	mov    r9,QWORD PTR [rdx+0x8]
    1cd3:	mov    rcx,QWORD PTR [rdx+0x10]
    1cd7:	mov    r8,QWORD PTR [rdx+0x18]
    1cdb:	mov    rdx,r9
    1cde:	call   1ce3 <botlish_entry_15+0x1b>
			1cdf: R_X86_64_PLT32	botlish_fn_15-0x4 ; check<int, int, str, str>
    1ce3:	mov    rsp,rbp
    1ce6:	pop    rbp
    1ce7:	ret

0000000000001ce8 <botlish_fn_16: <str>>:
    1ce8:	push   rbp
    1ce9:	mov    rbp,rsp
    1cec:	sub    rsp,0x50
    1cf0:	mov    QWORD PTR [rsp+0x30],rbx
    1cf5:	mov    QWORD PTR [rsp+0x38],r12
    1cfa:	mov    QWORD PTR [rsp+0x40],r13
    1cff:	mov    QWORD PTR [rsp+0x48],r14
    1d04:	mov    r13,rdi
    1d07:	mov    QWORD PTR [rsp+0x18],0x0
    1d10:	mov    QWORD PTR [rsp],rsi
    1d14:	mov    r14,rsi
    1d17:	mov    rsi,r14
    1d1a:	mov    rdi,r13
    1d1d:	call   1d22 <botlish_fn_16+0x3a>
			1d1e: R_X86_64_PLT32	rt_str_len-0x4
    1d22:	mov    rbx,rax
    1d25:	mov    QWORD PTR [rsp+0x8],rax
    1d2a:	mov    esi,0x1
    1d2f:	mov    QWORD PTR [rsp+0x10],0x1
    1d38:	mov    rcx,r14
    1d3b:	mov    rdx,rbx
    1d3e:	mov    rdi,r13
    1d41:	call   1d46 <botlish_fn_16+0x5e>
			1d42: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_local<generic>
    1d46:	mov    r12,rax
    1d49:	test   r12,r12
    1d4c:	je     1ea9 <botlish_fn_16+0x1c1>
    1d52:	mov    QWORD PTR [rsp+0x10],r12
    1d57:	test   r12,0x1
    1d5e:	jne    1d89 <botlish_fn_16+0xa1>
    1d64:	mov    edx,0x1
    1d69:	mov    rsi,r12
    1d6c:	mov    rdi,r13
    1d6f:	call   1d74 <botlish_fn_16+0x8c>
			1d70: R_X86_64_PLT32	rt_int_cmp-0x4
    1d74:	mov    ecx,0x2
    1d79:	test   rax,rax
    1d7c:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 1f48 <botlish_fn_16+0x260>
    1d84:	jmp    1d9a <botlish_fn_16+0xb2>
    1d89:	mov    ecx,0x2
    1d8e:	cmp    r12,0x1
    1d92:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 1f48 <botlish_fn_16+0x260>
    1d9a:	cmp    rcx,0x6
    1d9e:	je     1f24 <botlish_fn_16+0x23c>
    1da4:	mov    rcx,r12
    1da7:	and    rcx,rbx
    1daa:	test   rcx,0x1
    1db1:	jne    1dda <botlish_fn_16+0xf2>
    1db7:	mov    rdx,rbx
    1dba:	mov    rsi,r12
    1dbd:	mov    rdi,r13
    1dc0:	call   1dc5 <botlish_fn_16+0xdd>
			1dc1: R_X86_64_PLT32	rt_int_cmp-0x4
    1dc5:	mov    ecx,0x2
    1dca:	test   rax,rax
    1dcd:	cmovge rcx,QWORD PTR [rip+0x173]        # 1f48 <botlish_fn_16+0x260>
    1dd5:	jmp    1dea <botlish_fn_16+0x102>
    1dda:	mov    ecx,0x2
    1ddf:	cmp    r12,rbx
    1de2:	cmovge rcx,QWORD PTR [rip+0x15e]        # 1f48 <botlish_fn_16+0x260>
    1dea:	cmp    rcx,0x6
    1dee:	je     1f1a <botlish_fn_16+0x232>
    1df4:	lea    rcx,[rsp+0x20]
    1df9:	mov    rdx,r14
    1dfc:	mov    rsi,r12
    1dff:	mov    rdi,r13
    1e02:	call   1e07 <botlish_fn_16+0x11f>
			1e03: R_X86_64_PLT32	botlish_fn_18-0x4 ; char_at<generic>
    1e07:	test   rax,rax
    1e0a:	mov    rsi,rax
    1e0d:	je     1ea9 <botlish_fn_16+0x1c1>
    1e13:	mov    rdx,QWORD PTR [rsp+0x20]
    1e18:	mov    rcx,QWORD PTR [rsp+0x28]
    1e1d:	mov    rdi,r13
    1e20:	mov    rax,QWORD PTR [rdi+0x10]
    1e24:	mov    r8,QWORD PTR [rax+0x118]
    1e2b:	call   1e30 <botlish_fn_16+0x148>
			1e2c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1e30:	cmp    rax,0x6
    1e34:	je     1e47 <botlish_fn_16+0x15f>
    1e3a:	mov    ecx,0x2
    1e3f:	mov    rax,rcx
    1e42:	jmp    1f29 <botlish_fn_16+0x241>
    1e47:	mov    QWORD PTR [rsp+0x18],0x3
    1e50:	test   r12,0x1
    1e57:	jne    1e65 <botlish_fn_16+0x17d>
    1e5d:	mov    rcx,r12
    1e60:	jmp    1e7a <botlish_fn_16+0x192>
    1e65:	mov    rsi,r12
    1e68:	add    rsi,0x2
    1e6c:	mov    rcx,r12
    1e6f:	seto   al
    1e72:	test   al,al
    1e74:	je     1e8d <botlish_fn_16+0x1a5>
    1e7a:	mov    edx,0x3
    1e7f:	mov    rsi,rcx
    1e82:	mov    rdi,r13
    1e85:	call   1e8a <botlish_fn_16+0x1a2>
			1e86: R_X86_64_PLT32	rt_int_add-0x4
    1e8a:	mov    rsi,rax
    1e8d:	mov    QWORD PTR [rsp+0x10],rsi
    1e92:	mov    rcx,r14
    1e95:	mov    rdx,rbx
    1e98:	mov    rdi,r13
    1e9b:	call   1ea0 <botlish_fn_16+0x1b8>
			1e9c: R_X86_64_PLT32	botlish_fn_23-0x4 ; domain_loop<generic>
    1ea0:	test   rax,rax
    1ea3:	jne    1ec9 <botlish_fn_16+0x1e1>
    1ea9:	xor    rax,rax
    1eac:	mov    rbx,QWORD PTR [rsp+0x30]
    1eb1:	mov    r12,QWORD PTR [rsp+0x38]
    1eb6:	mov    r13,QWORD PTR [rsp+0x40]
    1ebb:	mov    r14,QWORD PTR [rsp+0x48]
    1ec0:	add    rsp,0x50
    1ec4:	mov    rsp,rbp
    1ec7:	pop    rbp
    1ec8:	ret
    1ec9:	mov    rcx,rax
    1ecc:	and    rcx,rbx
    1ecf:	mov    rsi,rax
    1ed2:	test   rcx,0x1
    1ed9:	jne    1f02 <botlish_fn_16+0x21a>
    1edf:	mov    rdx,rbx
    1ee2:	mov    rdi,r13
    1ee5:	call   1eea <botlish_fn_16+0x202>
			1ee6: R_X86_64_PLT32	rt_int_cmp-0x4
    1eea:	mov    ecx,0x2
    1eef:	test   rax,rax
    1ef2:	mov    rax,rcx
    1ef5:	cmove  rax,QWORD PTR [rip+0x4b]        # 1f48 <botlish_fn_16+0x260>
    1efd:	jmp    1f29 <botlish_fn_16+0x241>
    1f02:	mov    rdx,rbx
    1f05:	mov    eax,0x2
    1f0a:	cmp    rsi,rdx
    1f0d:	cmove  rax,QWORD PTR [rip+0x33]        # 1f48 <botlish_fn_16+0x260>
    1f15:	jmp    1f29 <botlish_fn_16+0x241>
    1f1a:	mov    eax,0x2
    1f1f:	jmp    1f29 <botlish_fn_16+0x241>
    1f24:	mov    eax,0x2
    1f29:	mov    rbx,QWORD PTR [rsp+0x30]
    1f2e:	mov    r12,QWORD PTR [rsp+0x38]
    1f33:	mov    r13,QWORD PTR [rsp+0x40]
    1f38:	mov    r14,QWORD PTR [rsp+0x48]
    1f3d:	add    rsp,0x50
    1f41:	mov    rsp,rbp
    1f44:	pop    rbp
    1f45:	ret
    1f46:	add    BYTE PTR [rax],al
    1f48:	(bad)
    1f49:	add    BYTE PTR [rax],al
    1f4b:	add    BYTE PTR [rax],al
    1f4d:	add    BYTE PTR [rax],al
	...

0000000000001f50 <botlish_entry_16: <str>>:
    1f50:	push   rbp
    1f51:	mov    rbp,rsp
    1f54:	mov    rsi,QWORD PTR [rdx]
    1f57:	call   1f5c <botlish_entry_16+0xc>
			1f58: R_X86_64_PLT32	botlish_fn_16-0x4 ; <str>
    1f5c:	mov    rsp,rbp
    1f5f:	pop    rbp
    1f60:	ret
    1f61:	add    BYTE PTR [rax],al
    1f63:	add    BYTE PTR [rax],al
    1f65:	add    BYTE PTR [rax],al
	...

0000000000001f68 <botlish_fn_17: <generic>>:
    1f68:	push   rbp
    1f69:	mov    rbp,rsp
    1f6c:	sub    rsp,0x60
    1f70:	mov    QWORD PTR [rsp+0x30],rbx
    1f75:	mov    QWORD PTR [rsp+0x38],r12
    1f7a:	mov    QWORD PTR [rsp+0x40],r13
    1f7f:	mov    QWORD PTR [rsp+0x48],r14
    1f84:	mov    QWORD PTR [rsp+0x50],r15
    1f89:	mov    QWORD PTR [rsp+0x18],0x0
    1f92:	mov    QWORD PTR [rsp],rsi
    1f96:	xor    r8d,r8d
    1f99:	test   rsi,0x7
    1fa0:	jne    1fb0 <botlish_fn_17+0x48>
    1fa6:	movzx  rax,BYTE PTR [rsi]
    1faa:	cmp    al,0x2
    1fac:	sete   r8b
    1fb0:	test   r8b,r8b
    1fb3:	jne    1fd3 <botlish_fn_17+0x6b>
    1fb9:	mov    rdx,QWORD PTR [rdi+0x10]
    1fbd:	mov    rcx,QWORD PTR [rdx+0xf0]
    1fc4:	mov    edx,0x1
    1fc9:	call   1fce <botlish_fn_17+0x66>
			1fca: R_X86_64_PLT32	rt_type_error-0x4
    1fce:	jmp    2168 <botlish_fn_17+0x200>
    1fd3:	mov    r13,rsi
    1fd6:	mov    r14,rdi
    1fd9:	call   1fde <botlish_fn_17+0x76>
			1fda: R_X86_64_PLT32	rt_str_len-0x4
    1fde:	mov    rbx,rax
    1fe1:	mov    QWORD PTR [rsp+0x8],rax
    1fe6:	mov    edx,0x1
    1feb:	mov    r15,rdx
    1fee:	mov    QWORD PTR [rsp+0x10],0x1
    1ff7:	mov    rcx,r13
    1ffa:	mov    rdx,rbx
    1ffd:	mov    rsi,r15
    2000:	mov    rdi,r14
    2003:	call   2008 <botlish_fn_17+0xa0>
			2004: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_local<generic>
    2008:	mov    r12,rax
    200b:	test   r12,r12
    200e:	je     2168 <botlish_fn_17+0x200>
    2014:	mov    QWORD PTR [rsp+0x10],r12
    2019:	test   r12,0x1
    2020:	jne    2049 <botlish_fn_17+0xe1>
    2026:	mov    rdx,r15
    2029:	mov    rsi,r12
    202c:	mov    rdi,r14
    202f:	call   2034 <botlish_fn_17+0xcc>
			2030: R_X86_64_PLT32	rt_int_cmp-0x4
    2034:	mov    ecx,0x2
    2039:	test   rax,rax
    203c:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 2210 <botlish_fn_17+0x2a8>
    2044:	jmp    205a <botlish_fn_17+0xf2>
    2049:	mov    ecx,0x2
    204e:	cmp    r12,0x1
    2052:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 2210 <botlish_fn_17+0x2a8>
    205a:	cmp    rcx,0x6
    205e:	je     21e8 <botlish_fn_17+0x280>
    2064:	mov    rax,r12
    2067:	and    rax,rbx
    206a:	test   rax,0x1
    2070:	jne    2099 <botlish_fn_17+0x131>
    2076:	mov    rdx,rbx
    2079:	mov    rsi,r12
    207c:	mov    rdi,r14
    207f:	call   2084 <botlish_fn_17+0x11c>
			2080: R_X86_64_PLT32	rt_int_cmp-0x4
    2084:	mov    ecx,0x2
    2089:	test   rax,rax
    208c:	cmovge rcx,QWORD PTR [rip+0x17c]        # 2210 <botlish_fn_17+0x2a8>
    2094:	jmp    20a9 <botlish_fn_17+0x141>
    2099:	mov    ecx,0x2
    209e:	cmp    r12,rbx
    20a1:	cmovge rcx,QWORD PTR [rip+0x167]        # 2210 <botlish_fn_17+0x2a8>
    20a9:	cmp    rcx,0x6
    20ad:	je     21de <botlish_fn_17+0x276>
    20b3:	lea    rcx,[rsp+0x20]
    20b8:	mov    rdx,r13
    20bb:	mov    rsi,r12
    20be:	mov    rdi,r14
    20c1:	call   20c6 <botlish_fn_17+0x15e>
			20c2: R_X86_64_PLT32	botlish_fn_18-0x4 ; char_at<generic>
    20c6:	test   rax,rax
    20c9:	mov    rsi,rax
    20cc:	je     2168 <botlish_fn_17+0x200>
    20d2:	mov    rdx,QWORD PTR [rsp+0x20]
    20d7:	mov    rcx,QWORD PTR [rsp+0x28]
    20dc:	mov    rdi,r14
    20df:	mov    rax,QWORD PTR [rdi+0x10]
    20e3:	mov    r8,QWORD PTR [rax+0x118]
    20ea:	call   20ef <botlish_fn_17+0x187>
			20eb: R_X86_64_PLT32	rt_str_region_eq-0x4
    20ef:	cmp    rax,0x6
    20f3:	je     2106 <botlish_fn_17+0x19e>
    20f9:	mov    ecx,0x2
    20fe:	mov    rax,rcx
    2101:	jmp    21ed <botlish_fn_17+0x285>
    2106:	mov    QWORD PTR [rsp+0x18],0x3
    210f:	test   r12,0x1
    2116:	jne    2124 <botlish_fn_17+0x1bc>
    211c:	mov    rdi,r12
    211f:	jmp    2139 <botlish_fn_17+0x1d1>
    2124:	mov    rsi,r12
    2127:	add    rsi,0x2
    212b:	mov    rdi,r12
    212e:	seto   al
    2131:	test   al,al
    2133:	je     214c <botlish_fn_17+0x1e4>
    2139:	mov    edx,0x3
    213e:	mov    rsi,rdi
    2141:	mov    rdi,r14
    2144:	call   2149 <botlish_fn_17+0x1e1>
			2145: R_X86_64_PLT32	rt_int_add-0x4
    2149:	mov    rsi,rax
    214c:	mov    QWORD PTR [rsp+0x10],rsi
    2151:	mov    rcx,r13
    2154:	mov    rdx,rbx
    2157:	mov    rdi,r14
    215a:	call   215f <botlish_fn_17+0x1f7>
			215b: R_X86_64_PLT32	botlish_fn_23-0x4 ; domain_loop<generic>
    215f:	test   rax,rax
    2162:	jne    218d <botlish_fn_17+0x225>
    2168:	xor    rax,rax
    216b:	mov    rbx,QWORD PTR [rsp+0x30]
    2170:	mov    r12,QWORD PTR [rsp+0x38]
    2175:	mov    r13,QWORD PTR [rsp+0x40]
    217a:	mov    r14,QWORD PTR [rsp+0x48]
    217f:	mov    r15,QWORD PTR [rsp+0x50]
    2184:	add    rsp,0x60
    2188:	mov    rsp,rbp
    218b:	pop    rbp
    218c:	ret
    218d:	mov    rcx,rax
    2190:	and    rcx,rbx
    2193:	mov    rsi,rax
    2196:	test   rcx,0x1
    219d:	jne    21c6 <botlish_fn_17+0x25e>
    21a3:	mov    rdx,rbx
    21a6:	mov    rdi,r14
    21a9:	call   21ae <botlish_fn_17+0x246>
			21aa: R_X86_64_PLT32	rt_int_cmp-0x4
    21ae:	mov    ecx,0x2
    21b3:	test   rax,rax
    21b6:	mov    rax,rcx
    21b9:	cmove  rax,QWORD PTR [rip+0x4f]        # 2210 <botlish_fn_17+0x2a8>
    21c1:	jmp    21ed <botlish_fn_17+0x285>
    21c6:	mov    rdx,rbx
    21c9:	mov    eax,0x2
    21ce:	cmp    rsi,rdx
    21d1:	cmove  rax,QWORD PTR [rip+0x37]        # 2210 <botlish_fn_17+0x2a8>
    21d9:	jmp    21ed <botlish_fn_17+0x285>
    21de:	mov    eax,0x2
    21e3:	jmp    21ed <botlish_fn_17+0x285>
    21e8:	mov    eax,0x2
    21ed:	mov    rbx,QWORD PTR [rsp+0x30]
    21f2:	mov    r12,QWORD PTR [rsp+0x38]
    21f7:	mov    r13,QWORD PTR [rsp+0x40]
    21fc:	mov    r14,QWORD PTR [rsp+0x48]
    2201:	mov    r15,QWORD PTR [rsp+0x50]
    2206:	add    rsp,0x60
    220a:	mov    rsp,rbp
    220d:	pop    rbp
    220e:	ret
    220f:	add    BYTE PTR [rsi],al
    2211:	add    BYTE PTR [rax],al
    2213:	add    BYTE PTR [rax],al
    2215:	add    BYTE PTR [rax],al
	...

0000000000002218 <botlish_entry_17: <generic>>:
    2218:	push   rbp
    2219:	mov    rbp,rsp
    221c:	mov    rsi,QWORD PTR [rdx]
    221f:	call   2224 <botlish_entry_17+0xc>
			2220: R_X86_64_PLT32	botlish_fn_17-0x4 ; <generic>
    2224:	mov    rsp,rbp
    2227:	pop    rbp
    2228:	ret

0000000000002229 <botlish_fn_18: char_at<generic>>:
    2229:	push   rbp
    222a:	mov    rbp,rsp
    222d:	sub    rsp,0x50
    2231:	mov    QWORD PTR [rsp+0x20],rbx
    2236:	mov    QWORD PTR [rsp+0x28],r12
    223b:	mov    QWORD PTR [rsp+0x30],r13
    2240:	mov    QWORD PTR [rsp+0x38],r14
    2245:	mov    QWORD PTR [rsp+0x40],r15
    224a:	mov    r14,rcx
    224d:	mov    QWORD PTR [rsp],rsi
    2251:	mov    QWORD PTR [rsp+0x8],rdx
    2256:	mov    r13,rdx
    2259:	mov    QWORD PTR [rsp+0x10],0x3
    2262:	mov    r9d,0x1
    2268:	test   rsi,0x1
    226f:	jne    228f <botlish_fn_18+0x66>
    2275:	xor    r9d,r9d
    2278:	test   rsi,0x7
    227f:	jne    228f <botlish_fn_18+0x66>
    2285:	movzx  rax,BYTE PTR [rsi]
    2289:	cmp    al,0x1
    228b:	sete   r9b
    228f:	test   r9b,r9b
    2292:	jne    22b0 <botlish_fn_18+0x87>
    2298:	mov    rax,QWORD PTR [rdi+0x10]
    229c:	mov    rcx,QWORD PTR [rax+0x120]
    22a3:	xor    rdx,rdx
    22a6:	call   22ab <botlish_fn_18+0x82>
			22a7: R_X86_64_PLT32	rt_type_error-0x4
    22ab:	jmp    236d <botlish_fn_18+0x144>
    22b0:	mov    r12,rdi
    22b3:	test   rsi,0x1
    22ba:	jne    22c8 <botlish_fn_18+0x9f>
    22c0:	mov    rbx,rsi
    22c3:	jmp    22e5 <botlish_fn_18+0xbc>
    22c8:	mov    rax,rsi
    22cb:	add    rax,0x2
    22cf:	mov    rbx,rsi
    22d2:	seto   cl
    22d5:	test   cl,cl
    22d7:	jne    22e5 <botlish_fn_18+0xbc>
    22dd:	mov    r15,rax
    22e0:	jmp    22f8 <botlish_fn_18+0xcf>
    22e5:	mov    edx,0x3
    22ea:	mov    rsi,rbx
    22ed:	mov    rdi,r12
    22f0:	call   22f5 <botlish_fn_18+0xcc>
			22f1: R_X86_64_PLT32	rt_int_add-0x4
    22f5:	mov    r15,rax
    22f8:	mov    ecx,0x1
    22fd:	mov    rsi,rbx
    2300:	test   rsi,0x1
    2307:	jne    232d <botlish_fn_18+0x104>
    230d:	xor    ecx,ecx
    230f:	mov    rsi,rbx
    2312:	test   rsi,0x7
    2319:	jne    232d <botlish_fn_18+0x104>
    231f:	mov    rsi,rbx
    2322:	movzx  rcx,BYTE PTR [rsi]
    2326:	rex cmp cl,0x1
    232a:	sete   cl
    232d:	test   cl,cl
    232f:	jne    2353 <botlish_fn_18+0x12a>
    2335:	mov    rdi,r12
    2338:	mov    rsi,QWORD PTR [rdi+0x10]
    233c:	mov    rcx,QWORD PTR [rsi+0x128]
    2343:	xor    rdx,rdx
    2346:	mov    rsi,rbx
    2349:	call   234e <botlish_fn_18+0x125>
			234a: R_X86_64_PLT32	rt_type_error-0x4
    234e:	jmp    236d <botlish_fn_18+0x144>
    2353:	mov    rdi,r12
    2356:	mov    rcx,r15
    2359:	mov    rdx,rbx
    235c:	mov    rsi,r13
    235f:	call   2364 <botlish_fn_18+0x13b>
			2360: R_X86_64_PLT32	rt_str_region_check-0x4
    2364:	test   rax,rax
    2367:	jne    2392 <botlish_fn_18+0x169>
    236d:	xor    rax,rax
    2370:	mov    rbx,QWORD PTR [rsp+0x20]
    2375:	mov    r12,QWORD PTR [rsp+0x28]
    237a:	mov    r13,QWORD PTR [rsp+0x30]
    237f:	mov    r14,QWORD PTR [rsp+0x38]
    2384:	mov    r15,QWORD PTR [rsp+0x40]
    2389:	add    rsp,0x50
    238d:	mov    rsp,rbp
    2390:	pop    rbp
    2391:	ret
    2392:	mov    rcx,r14
    2395:	mov    rsi,rbx
    2398:	mov    QWORD PTR [rcx],rsi
    239b:	mov    rax,r15
    239e:	mov    QWORD PTR [rcx+0x8],rax
    23a2:	mov    rax,r13
    23a5:	mov    rbx,QWORD PTR [rsp+0x20]
    23aa:	mov    r12,QWORD PTR [rsp+0x28]
    23af:	mov    r13,QWORD PTR [rsp+0x30]
    23b4:	mov    r14,QWORD PTR [rsp+0x38]
    23b9:	mov    r15,QWORD PTR [rsp+0x40]
    23be:	add    rsp,0x50
    23c2:	mov    rsp,rbp
    23c5:	pop    rbp
    23c6:	ret

00000000000023c7 <botlish_entry_18: char_at<generic>>:
    23c7:	push   rbp
    23c8:	mov    rbp,rsp
    23cb:	ud2
    23cd:	add    BYTE PTR [rax],al
	...

00000000000023d0 <botlish_fn_19: scan_local<generic>>:
    23d0:	push   rbp
    23d1:	mov    rbp,rsp
    23d4:	sub    rsp,0x80
    23db:	mov    QWORD PTR [rsp+0x50],rbx
    23e0:	mov    QWORD PTR [rsp+0x58],r12
    23e5:	mov    QWORD PTR [rsp+0x60],r13
    23ea:	mov    QWORD PTR [rsp+0x68],r14
    23ef:	mov    QWORD PTR [rsp+0x70],r15
    23f4:	mov    rax,rdi
    23f7:	mov    QWORD PTR [rsp+0x18],0x0
    2400:	mov    QWORD PTR [rsp],rsi
    2404:	mov    r14,rsi
    2407:	mov    QWORD PTR [rsp+0x8],rdx
    240c:	mov    QWORD PTR [rsp+0x10],rcx
    2411:	mov    r12,rcx
    2414:	mov    r11d,0x1
    241a:	mov    rsi,r14
    241d:	test   rsi,0x1
    2424:	jne    2446 <botlish_fn_19+0x76>
    242a:	xor    r11d,r11d
    242d:	test   rsi,0x7
    2434:	jne    2446 <botlish_fn_19+0x76>
    243a:	movzx  rdi,BYTE PTR [rsi]
    243e:	cmp    dil,0x1
    2442:	sete   r11b
    2446:	test   r11b,r11b
    2449:	jne    246a <botlish_fn_19+0x9a>
    244f:	mov    rdi,rax
    2452:	mov    r9,QWORD PTR [rdi+0x10]
    2456:	mov    rcx,QWORD PTR [r9+0xa8]
    245d:	xor    rdx,rdx
    2460:	call   2465 <botlish_fn_19+0x95>
			2461: R_X86_64_PLT32	rt_type_error-0x4
    2465:	jmp    251d <botlish_fn_19+0x14d>
    246a:	mov    r13,rdx
    246d:	mov    r10,rsi
    2470:	and    r10,r13
    2473:	mov    r14,rsi
    2476:	test   r10,0x1
    247d:	jne    24a9 <botlish_fn_19+0xd9>
    2483:	mov    rbx,rax
    2486:	mov    rdx,r13
    2489:	mov    rsi,r14
    248c:	mov    rdi,rbx
    248f:	call   2494 <botlish_fn_19+0xc4>
			2490: R_X86_64_PLT32	rt_int_cmp-0x4
    2494:	mov    ecx,0x2
    2499:	test   rax,rax
    249c:	cmovge rcx,QWORD PTR [rip+0x24c]        # 26f0 <botlish_fn_19+0x320>
    24a4:	jmp    24bf <botlish_fn_19+0xef>
    24a9:	mov    rbx,rax
    24ac:	mov    ecx,0x2
    24b1:	mov    rsi,r14
    24b4:	cmp    rsi,r13
    24b7:	cmovge rcx,QWORD PTR [rip+0x231]        # 26f0 <botlish_fn_19+0x320>
    24bf:	mov    eax,0x6
    24c4:	mov    QWORD PTR [rsp+0x30],rax
    24c9:	cmp    rcx,0x6
    24cd:	je     26c3 <botlish_fn_19+0x2f3>
    24d3:	lea    rcx,[rsp+0x20]
    24d8:	mov    rdx,r12
    24db:	mov    rsi,r14
    24de:	mov    rdi,rbx
    24e1:	call   24e6 <botlish_fn_19+0x116>
			24e2: R_X86_64_PLT32	botlish_fn_18-0x4 ; char_at<generic>
    24e6:	mov    rsi,rax
    24e9:	mov    r15,rax
    24ec:	test   rax,rsi
    24ef:	je     251d <botlish_fn_19+0x14d>
    24f5:	mov    rdx,QWORD PTR [rsp+0x20]
    24fa:	mov    QWORD PTR [rsp+0x40],rdx
    24ff:	mov    rcx,QWORD PTR [rsp+0x28]
    2504:	mov    QWORD PTR [rsp+0x38],rcx
    2509:	mov    rsi,r15
    250c:	mov    rdi,rbx
    250f:	call   2514 <botlish_fn_19+0x144>
			2510: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    2514:	test   rax,rax
    2517:	jne    2545 <botlish_fn_19+0x175>
    251d:	xor    rax,rax
    2520:	mov    rbx,QWORD PTR [rsp+0x50]
    2525:	mov    r12,QWORD PTR [rsp+0x58]
    252a:	mov    r13,QWORD PTR [rsp+0x60]
    252f:	mov    r14,QWORD PTR [rsp+0x68]
    2534:	mov    r15,QWORD PTR [rsp+0x70]
    2539:	add    rsp,0x80
    2540:	mov    rsp,rbp
    2543:	pop    rbp
    2544:	ret
    2545:	cmp    rax,0x6
    2549:	je     2644 <botlish_fn_19+0x274>
    254f:	mov    rax,QWORD PTR [rbx+0x10]
    2553:	mov    r8,QWORD PTR [rax+0x130]
    255a:	mov    rcx,QWORD PTR [rsp+0x38]
    255f:	mov    rdx,QWORD PTR [rsp+0x40]
    2564:	mov    rsi,r15
    2567:	mov    rdi,rbx
    256a:	call   256f <botlish_fn_19+0x19f>
			256b: R_X86_64_PLT32	rt_str_region_eq-0x4
    256f:	cmp    rax,0x6
    2573:	je     263a <botlish_fn_19+0x26a>
    2579:	mov    rax,QWORD PTR [rbx+0x10]
    257d:	mov    r8,QWORD PTR [rax+0x138]
    2584:	mov    rcx,QWORD PTR [rsp+0x38]
    2589:	mov    rdx,QWORD PTR [rsp+0x40]
    258e:	mov    rsi,r15
    2591:	mov    rdi,rbx
    2594:	call   2599 <botlish_fn_19+0x1c9>
			2595: R_X86_64_PLT32	rt_str_region_eq-0x4
    2599:	cmp    rax,0x6
    259d:	je     2630 <botlish_fn_19+0x260>
    25a3:	mov    rax,QWORD PTR [rbx+0x10]
    25a7:	mov    r8,QWORD PTR [rax+0xd0]
    25ae:	mov    rcx,QWORD PTR [rsp+0x38]
    25b3:	mov    rdx,QWORD PTR [rsp+0x40]
    25b8:	mov    rsi,r15
    25bb:	mov    rdi,rbx
    25be:	call   25c3 <botlish_fn_19+0x1f3>
			25bf: R_X86_64_PLT32	rt_str_region_eq-0x4
    25c3:	cmp    rax,0x6
    25c7:	je     2626 <botlish_fn_19+0x256>
    25cd:	mov    rax,QWORD PTR [rbx+0x10]
    25d1:	mov    r8,QWORD PTR [rax+0x120]
    25d8:	mov    rcx,QWORD PTR [rsp+0x38]
    25dd:	mov    rdx,QWORD PTR [rsp+0x40]
    25e2:	mov    rsi,r15
    25e5:	mov    rdi,rbx
    25e8:	call   25ed <botlish_fn_19+0x21d>
			25e9: R_X86_64_PLT32	rt_str_region_eq-0x4
    25ed:	cmp    rax,0x6
    25f1:	je     261c <botlish_fn_19+0x24c>
    25f7:	mov    rax,QWORD PTR [rbx+0x10]
    25fb:	mov    r8,QWORD PTR [rax+0x140]
    2602:	mov    rcx,QWORD PTR [rsp+0x38]
    2607:	mov    rdx,QWORD PTR [rsp+0x40]
    260c:	mov    rsi,r15
    260f:	mov    rdi,rbx
    2612:	call   2617 <botlish_fn_19+0x247>
			2613: R_X86_64_PLT32	rt_str_region_eq-0x4
    2617:	jmp    2649 <botlish_fn_19+0x279>
    261c:	mov    rax,QWORD PTR [rsp+0x30]
    2621:	jmp    2649 <botlish_fn_19+0x279>
    2626:	mov    rax,QWORD PTR [rsp+0x30]
    262b:	jmp    2649 <botlish_fn_19+0x279>
    2630:	mov    rax,QWORD PTR [rsp+0x30]
    2635:	jmp    2649 <botlish_fn_19+0x279>
    263a:	mov    rax,QWORD PTR [rsp+0x30]
    263f:	jmp    2649 <botlish_fn_19+0x279>
    2644:	mov    rax,QWORD PTR [rsp+0x30]
    2649:	cmp    rax,0x6
    264d:	je     265b <botlish_fn_19+0x28b>
    2653:	mov    rax,r14
    2656:	jmp    26c6 <botlish_fn_19+0x2f6>
    265b:	mov    QWORD PTR [rsp+0x18],0x3
    2664:	mov    rsi,r14
    2667:	test   rsi,0x1
    266e:	je     2694 <botlish_fn_19+0x2c4>
    2674:	mov    rsi,r14
    2677:	mov    rax,rsi
    267a:	add    rax,0x2
    267e:	seto   cl
    2681:	test   cl,cl
    2683:	jne    2694 <botlish_fn_19+0x2c4>
    2689:	mov    rsi,rax
    268c:	mov    r14,rax
    268f:	jmp    26aa <botlish_fn_19+0x2da>
    2694:	mov    edx,0x3
    2699:	mov    rsi,r14
    269c:	mov    rdi,rbx
    269f:	call   26a4 <botlish_fn_19+0x2d4>
			26a0: R_X86_64_PLT32	rt_int_add-0x4
    26a4:	mov    rsi,rax
    26a7:	mov    r14,rax
    26aa:	mov    QWORD PTR [rsp],rsi
    26ae:	mov    QWORD PTR [rsp+0x8],r13
    26b3:	mov    QWORD PTR [rsp+0x10],r12
    26b8:	mov    rax,rbx
    26bb:	mov    rdx,r13
    26be:	jmp    2414 <botlish_fn_19+0x44>
    26c3:	mov    rax,r14
    26c6:	mov    rbx,QWORD PTR [rsp+0x50]
    26cb:	mov    r12,QWORD PTR [rsp+0x58]
    26d0:	mov    r13,QWORD PTR [rsp+0x60]
    26d5:	mov    r14,QWORD PTR [rsp+0x68]
    26da:	mov    r15,QWORD PTR [rsp+0x70]
    26df:	add    rsp,0x80
    26e6:	mov    rsp,rbp
    26e9:	pop    rbp
    26ea:	ret
    26eb:	add    BYTE PTR [rax],al
    26ed:	add    BYTE PTR [rax],al
    26ef:	add    BYTE PTR [rsi],al
    26f1:	add    BYTE PTR [rax],al
    26f3:	add    BYTE PTR [rax],al
    26f5:	add    BYTE PTR [rax],al
	...

00000000000026f8 <botlish_entry_19: scan_local<generic>>:
    26f8:	push   rbp
    26f9:	mov    rbp,rsp
    26fc:	mov    rsi,QWORD PTR [rdx]
    26ff:	mov    r8,QWORD PTR [rdx+0x8]
    2703:	mov    rcx,QWORD PTR [rdx+0x10]
    2707:	mov    rdx,r8
    270a:	call   270f <botlish_entry_19+0x17>
			270b: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_local<generic>
    270f:	mov    rsp,rbp
    2712:	pop    rbp
    2713:	ret
    2714:	add    BYTE PTR [rax],al
	...

0000000000002718 <botlish_fn_20: scan_label<generic>>:
    2718:	push   rbp
    2719:	mov    rbp,rsp
    271c:	sub    rsp,0x80
    2723:	mov    QWORD PTR [rsp+0x50],rbx
    2728:	mov    QWORD PTR [rsp+0x58],r12
    272d:	mov    QWORD PTR [rsp+0x60],r13
    2732:	mov    QWORD PTR [rsp+0x68],r14
    2737:	mov    QWORD PTR [rsp+0x70],r15
    273c:	mov    QWORD PTR [rsp+0x18],0x0
    2745:	mov    QWORD PTR [rsp],rsi
    2749:	mov    r14,rsi
    274c:	mov    QWORD PTR [rsp+0x8],rdx
    2751:	mov    QWORD PTR [rsp+0x10],rcx
    2756:	mov    r12,rcx
    2759:	mov    r11d,0x1
    275f:	mov    rsi,r14
    2762:	test   rsi,0x1
    2769:	jne    2789 <botlish_fn_20+0x71>
    276f:	xor    r11d,r11d
    2772:	test   rsi,0x7
    2779:	jne    2789 <botlish_fn_20+0x71>
    277f:	movzx  rax,BYTE PTR [rsi]
    2783:	cmp    al,0x1
    2785:	sete   r11b
    2789:	test   r11b,r11b
    278c:	jne    27aa <botlish_fn_20+0x92>
    2792:	mov    rax,QWORD PTR [rdi+0x10]
    2796:	mov    rcx,QWORD PTR [rax+0xa8]
    279d:	xor    rdx,rdx
    27a0:	call   27a5 <botlish_fn_20+0x8d>
			27a1: R_X86_64_PLT32	rt_type_error-0x4
    27a5:	jmp    2856 <botlish_fn_20+0x13e>
    27aa:	mov    r13,rdx
    27ad:	mov    rax,rsi
    27b0:	and    rax,r13
    27b3:	mov    r14,rsi
    27b6:	test   rax,0x1
    27bc:	jne    27e5 <botlish_fn_20+0xcd>
    27c2:	mov    rbx,rdi
    27c5:	mov    rdx,r13
    27c8:	mov    rsi,r14
    27cb:	call   27d0 <botlish_fn_20+0xb8>
			27cc: R_X86_64_PLT32	rt_int_cmp-0x4
    27d0:	mov    ecx,0x2
    27d5:	test   rax,rax
    27d8:	cmovge rcx,QWORD PTR [rip+0x178]        # 2958 <botlish_fn_20+0x240>
    27e0:	jmp    27fb <botlish_fn_20+0xe3>
    27e5:	mov    rbx,rdi
    27e8:	mov    ecx,0x2
    27ed:	mov    rsi,r14
    27f0:	cmp    rsi,r13
    27f3:	cmovge rcx,QWORD PTR [rip+0x15d]        # 2958 <botlish_fn_20+0x240>
    27fb:	mov    eax,0x6
    2800:	mov    QWORD PTR [rsp+0x30],rax
    2805:	cmp    rcx,0x6
    2809:	je     292c <botlish_fn_20+0x214>
    280f:	lea    rcx,[rsp+0x20]
    2814:	mov    rdx,r12
    2817:	mov    rsi,r14
    281a:	mov    rdi,rbx
    281d:	call   2822 <botlish_fn_20+0x10a>
			281e: R_X86_64_PLT32	botlish_fn_18-0x4 ; char_at<generic>
    2822:	test   rax,rax
    2825:	mov    r15,rax
    2828:	je     2856 <botlish_fn_20+0x13e>
    282e:	mov    rdx,QWORD PTR [rsp+0x20]
    2833:	mov    QWORD PTR [rsp+0x40],rdx
    2838:	mov    rcx,QWORD PTR [rsp+0x28]
    283d:	mov    QWORD PTR [rsp+0x38],rcx
    2842:	mov    rsi,r15
    2845:	mov    rdi,rbx
    2848:	call   284d <botlish_fn_20+0x135>
			2849: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    284d:	test   rax,rax
    2850:	jne    287e <botlish_fn_20+0x166>
    2856:	xor    rax,rax
    2859:	mov    rbx,QWORD PTR [rsp+0x50]
    285e:	mov    r12,QWORD PTR [rsp+0x58]
    2863:	mov    r13,QWORD PTR [rsp+0x60]
    2868:	mov    r14,QWORD PTR [rsp+0x68]
    286d:	mov    r15,QWORD PTR [rsp+0x70]
    2872:	add    rsp,0x80
    2879:	mov    rsp,rbp
    287c:	pop    rbp
    287d:	ret
    287e:	cmp    rax,0x6
    2882:	je     28ad <botlish_fn_20+0x195>
    2888:	mov    r11,QWORD PTR [rbx+0x10]
    288c:	mov    r8,QWORD PTR [r11+0x140]
    2893:	mov    rcx,QWORD PTR [rsp+0x38]
    2898:	mov    rdx,QWORD PTR [rsp+0x40]
    289d:	mov    rsi,r15
    28a0:	mov    rdi,rbx
    28a3:	call   28a8 <botlish_fn_20+0x190>
			28a4: R_X86_64_PLT32	rt_str_region_eq-0x4
    28a8:	jmp    28b2 <botlish_fn_20+0x19a>
    28ad:	mov    rax,QWORD PTR [rsp+0x30]
    28b2:	cmp    rax,0x6
    28b6:	je     28c4 <botlish_fn_20+0x1ac>
    28bc:	mov    rax,r14
    28bf:	jmp    292f <botlish_fn_20+0x217>
    28c4:	mov    QWORD PTR [rsp+0x18],0x3
    28cd:	mov    rsi,r14
    28d0:	test   rsi,0x1
    28d7:	je     28fd <botlish_fn_20+0x1e5>
    28dd:	mov    rsi,r14
    28e0:	mov    rax,rsi
    28e3:	add    rax,0x2
    28e7:	seto   cl
    28ea:	test   cl,cl
    28ec:	jne    28fd <botlish_fn_20+0x1e5>
    28f2:	mov    rsi,rax
    28f5:	mov    r14,rax
    28f8:	jmp    2913 <botlish_fn_20+0x1fb>
    28fd:	mov    edx,0x3
    2902:	mov    rsi,r14
    2905:	mov    rdi,rbx
    2908:	call   290d <botlish_fn_20+0x1f5>
			2909: R_X86_64_PLT32	rt_int_add-0x4
    290d:	mov    rsi,rax
    2910:	mov    r14,rax
    2913:	mov    QWORD PTR [rsp],rsi
    2917:	mov    QWORD PTR [rsp+0x8],r13
    291c:	mov    QWORD PTR [rsp+0x10],r12
    2921:	mov    rdx,r13
    2924:	mov    rdi,rbx
    2927:	jmp    2759 <botlish_fn_20+0x41>
    292c:	mov    rax,r14
    292f:	mov    rbx,QWORD PTR [rsp+0x50]
    2934:	mov    r12,QWORD PTR [rsp+0x58]
    2939:	mov    r13,QWORD PTR [rsp+0x60]
    293e:	mov    r14,QWORD PTR [rsp+0x68]
    2943:	mov    r15,QWORD PTR [rsp+0x70]
    2948:	add    rsp,0x80
    294f:	mov    rsp,rbp
    2952:	pop    rbp
    2953:	ret
    2954:	add    BYTE PTR [rax],al
    2956:	add    BYTE PTR [rax],al
    2958:	(bad)
    2959:	add    BYTE PTR [rax],al
    295b:	add    BYTE PTR [rax],al
    295d:	add    BYTE PTR [rax],al
	...

0000000000002960 <botlish_entry_20: scan_label<generic>>:
    2960:	push   rbp
    2961:	mov    rbp,rsp
    2964:	mov    rsi,QWORD PTR [rdx]
    2967:	mov    r8,QWORD PTR [rdx+0x8]
    296b:	mov    rcx,QWORD PTR [rdx+0x10]
    296f:	mov    rdx,r8
    2972:	call   2977 <botlish_entry_20+0x17>
			2973: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_label<generic>
    2977:	mov    rsp,rbp
    297a:	pop    rbp
    297b:	ret
    297c:	add    BYTE PTR [rax],al
	...

0000000000002980 <botlish_fn_21: scan_alpha<generic>>:
    2980:	push   rbp
    2981:	mov    rbp,rsp
    2984:	sub    rsp,0x50
    2988:	mov    QWORD PTR [rsp+0x30],rbx
    298d:	mov    QWORD PTR [rsp+0x38],r12
    2992:	mov    QWORD PTR [rsp+0x40],r13
    2997:	mov    QWORD PTR [rsp+0x48],r14
    299c:	mov    r14,rdi
    299f:	mov    QWORD PTR [rsp+0x18],0x0
    29a8:	mov    QWORD PTR [rsp],rsi
    29ac:	mov    r13,rsi
    29af:	mov    QWORD PTR [rsp+0x8],rdx
    29b4:	mov    r12,rdx
    29b7:	mov    QWORD PTR [rsp+0x10],rcx
    29bc:	mov    rbx,rcx
    29bf:	mov    r11d,0x1
    29c5:	mov    rsi,r13
    29c8:	test   rsi,0x1
    29cf:	jne    29ef <botlish_fn_21+0x6f>
    29d5:	xor    r11d,r11d
    29d8:	test   rsi,0x7
    29df:	jne    29ef <botlish_fn_21+0x6f>
    29e5:	movzx  rax,BYTE PTR [rsi]
    29e9:	cmp    al,0x1
    29eb:	sete   r11b
    29ef:	test   r11b,r11b
    29f2:	jne    2a13 <botlish_fn_21+0x93>
    29f8:	mov    rdi,r14
    29fb:	mov    rax,QWORD PTR [rdi+0x10]
    29ff:	mov    rcx,QWORD PTR [rax+0xa8]
    2a06:	xor    rdx,rdx
    2a09:	call   2a0e <botlish_fn_21+0x8e>
			2a0a: R_X86_64_PLT32	rt_type_error-0x4
    2a0e:	jmp    2aa2 <botlish_fn_21+0x122>
    2a13:	mov    rax,rsi
    2a16:	and    rax,r12
    2a19:	mov    r13,rsi
    2a1c:	test   rax,0x1
    2a22:	jne    2a4b <botlish_fn_21+0xcb>
    2a28:	mov    rdx,r12
    2a2b:	mov    rsi,r13
    2a2e:	mov    rdi,r14
    2a31:	call   2a36 <botlish_fn_21+0xb6>
			2a32: R_X86_64_PLT32	rt_int_cmp-0x4
    2a36:	mov    ecx,0x2
    2a3b:	test   rax,rax
    2a3e:	cmovge rcx,QWORD PTR [rip+0x112]        # 2b58 <botlish_fn_21+0x1d8>
    2a46:	jmp    2a5e <botlish_fn_21+0xde>
    2a4b:	mov    ecx,0x2
    2a50:	mov    rsi,r13
    2a53:	cmp    rsi,r12
    2a56:	cmovge rcx,QWORD PTR [rip+0xfa]        # 2b58 <botlish_fn_21+0x1d8>
    2a5e:	cmp    rcx,0x6
    2a62:	je     2b36 <botlish_fn_21+0x1b6>
    2a68:	lea    rcx,[rsp+0x20]
    2a6d:	mov    rdx,rbx
    2a70:	mov    rsi,r13
    2a73:	mov    rdi,r14
    2a76:	call   2a7b <botlish_fn_21+0xfb>
			2a77: R_X86_64_PLT32	botlish_fn_18-0x4 ; char_at<generic>
    2a7b:	test   rax,rax
    2a7e:	mov    rsi,rax
    2a81:	je     2aa2 <botlish_fn_21+0x122>
    2a87:	mov    rdx,QWORD PTR [rsp+0x20]
    2a8c:	mov    rcx,QWORD PTR [rsp+0x28]
    2a91:	mov    rdi,r14
    2a94:	call   2a99 <botlish_fn_21+0x119>
			2a95: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    2a99:	test   rax,rax
    2a9c:	jne    2ac2 <botlish_fn_21+0x142>
    2aa2:	xor    rax,rax
    2aa5:	mov    rbx,QWORD PTR [rsp+0x30]
    2aaa:	mov    r12,QWORD PTR [rsp+0x38]
    2aaf:	mov    r13,QWORD PTR [rsp+0x40]
    2ab4:	mov    r14,QWORD PTR [rsp+0x48]
    2ab9:	add    rsp,0x50
    2abd:	mov    rsp,rbp
    2ac0:	pop    rbp
    2ac1:	ret
    2ac2:	cmp    rax,0x6
    2ac6:	je     2ad4 <botlish_fn_21+0x154>
    2acc:	mov    rax,r13
    2acf:	jmp    2b39 <botlish_fn_21+0x1b9>
    2ad4:	mov    QWORD PTR [rsp+0x18],0x3
    2add:	mov    rsi,r13
    2ae0:	test   rsi,0x1
    2ae7:	je     2b0d <botlish_fn_21+0x18d>
    2aed:	mov    rsi,r13
    2af0:	mov    r11,rsi
    2af3:	add    r11,0x2
    2af7:	seto   al
    2afa:	test   al,al
    2afc:	jne    2b0d <botlish_fn_21+0x18d>
    2b02:	mov    rsi,r11
    2b05:	mov    r13,r11
    2b08:	jmp    2b23 <botlish_fn_21+0x1a3>
    2b0d:	mov    edx,0x3
    2b12:	mov    rsi,r13
    2b15:	mov    rdi,r14
    2b18:	call   2b1d <botlish_fn_21+0x19d>
			2b19: R_X86_64_PLT32	rt_int_add-0x4
    2b1d:	mov    rsi,rax
    2b20:	mov    r13,rax
    2b23:	mov    QWORD PTR [rsp],rsi
    2b27:	mov    QWORD PTR [rsp+0x8],r12
    2b2c:	mov    QWORD PTR [rsp+0x10],rbx
    2b31:	jmp    29bf <botlish_fn_21+0x3f>
    2b36:	mov    rax,r13
    2b39:	mov    rbx,QWORD PTR [rsp+0x30]
    2b3e:	mov    r12,QWORD PTR [rsp+0x38]
    2b43:	mov    r13,QWORD PTR [rsp+0x40]
    2b48:	mov    r14,QWORD PTR [rsp+0x48]
    2b4d:	add    rsp,0x50
    2b51:	mov    rsp,rbp
    2b54:	pop    rbp
    2b55:	ret
    2b56:	add    BYTE PTR [rax],al
    2b58:	(bad)
    2b59:	add    BYTE PTR [rax],al
    2b5b:	add    BYTE PTR [rax],al
    2b5d:	add    BYTE PTR [rax],al
	...

0000000000002b60 <botlish_entry_21: scan_alpha<generic>>:
    2b60:	push   rbp
    2b61:	mov    rbp,rsp
    2b64:	mov    rsi,QWORD PTR [rdx]
    2b67:	mov    r8,QWORD PTR [rdx+0x8]
    2b6b:	mov    rcx,QWORD PTR [rdx+0x10]
    2b6f:	mov    rdx,r8
    2b72:	call   2b77 <botlish_entry_21+0x17>
			2b73: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_alpha<generic>
    2b77:	mov    rsp,rbp
    2b7a:	pop    rbp
    2b7b:	ret
    2b7c:	add    BYTE PTR [rax],al
	...

0000000000002b80 <botlish_fn_22: tld_ok<generic>>:
    2b80:	push   rbp
    2b81:	mov    rbp,rsp
    2b84:	sub    rsp,0x40
    2b88:	mov    QWORD PTR [rsp+0x20],rbx
    2b8d:	mov    QWORD PTR [rsp+0x28],r12
    2b92:	mov    QWORD PTR [rsp+0x30],r13
    2b97:	mov    QWORD PTR [rsp+0x38],r14
    2b9c:	mov    rbx,rdi
    2b9f:	mov    QWORD PTR [rsp],rsi
    2ba3:	mov    r12,rsi
    2ba6:	mov    QWORD PTR [rsp+0x8],rdx
    2bab:	mov    r14,rdx
    2bae:	mov    QWORD PTR [rsp+0x10],rcx
    2bb3:	mov    rdx,r14
    2bb6:	mov    rsi,r12
    2bb9:	mov    rdi,rbx
    2bbc:	call   2bc1 <botlish_fn_22+0x41>
			2bbd: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_alpha<generic>
    2bc1:	mov    rsi,rax
    2bc4:	mov    r13,rax
    2bc7:	test   rax,rsi
    2bca:	je     2c8d <botlish_fn_22+0x10d>
    2bd0:	mov    rax,r13
    2bd3:	mov    QWORD PTR [rsp+0x8],rax
    2bd8:	mov    rdx,r14
    2bdb:	and    rax,rdx
    2bde:	test   rax,0x1
    2be4:	jne    2c0d <botlish_fn_22+0x8d>
    2bea:	mov    rsi,r13
    2bed:	mov    rdi,rbx
    2bf0:	call   2bf5 <botlish_fn_22+0x75>
			2bf1: R_X86_64_PLT32	rt_int_cmp-0x4
    2bf5:	mov    ecx,0x2
    2bfa:	test   rax,rax
    2bfd:	cmove  rcx,QWORD PTR [rip+0x15b]        # 2d60 <botlish_fn_22+0x1e0>
    2c05:	mov    rax,r13
    2c08:	jmp    2c20 <botlish_fn_22+0xa0>
    2c0d:	mov    ecx,0x2
    2c12:	mov    rax,r13
    2c15:	cmp    rax,rdx
    2c18:	cmove  rcx,QWORD PTR [rip+0x140]        # 2d60 <botlish_fn_22+0x1e0>
    2c20:	cmp    rcx,0x6
    2c24:	je     2c37 <botlish_fn_22+0xb7>
    2c2a:	mov    ecx,0x2
    2c2f:	mov    rax,rcx
    2c32:	jmp    2d3f <botlish_fn_22+0x1bf>
    2c37:	mov    ecx,0x1
    2c3c:	mov    rsi,r12
    2c3f:	test   rsi,0x1
    2c46:	jne    2c6c <botlish_fn_22+0xec>
    2c4c:	xor    ecx,ecx
    2c4e:	mov    rsi,r12
    2c51:	test   rsi,0x7
    2c58:	jne    2c6c <botlish_fn_22+0xec>
    2c5e:	mov    rsi,r12
    2c61:	movzx  rcx,BYTE PTR [rsi]
    2c65:	rex cmp cl,0x1
    2c69:	sete   cl
    2c6c:	test   cl,cl
    2c6e:	jne    2cad <botlish_fn_22+0x12d>
    2c74:	mov    rdi,rbx
    2c77:	mov    rsi,QWORD PTR [rdi+0x10]
    2c7b:	mov    rcx,QWORD PTR [rsi+0x140]
    2c82:	xor    rdx,rdx
    2c85:	mov    rsi,r12
    2c88:	call   2c8d <botlish_fn_22+0x10d>
			2c89: R_X86_64_PLT32	rt_type_error-0x4
    2c8d:	xor    rax,rax
    2c90:	mov    rbx,QWORD PTR [rsp+0x20]
    2c95:	mov    r12,QWORD PTR [rsp+0x28]
    2c9a:	mov    r13,QWORD PTR [rsp+0x30]
    2c9f:	mov    r14,QWORD PTR [rsp+0x38]
    2ca4:	add    rsp,0x40
    2ca8:	mov    rsp,rbp
    2cab:	pop    rbp
    2cac:	ret
    2cad:	mov    rsi,r12
    2cb0:	mov    rdi,rax
    2cb3:	and    rdi,rsi
    2cb6:	test   rdi,0x1
    2cbd:	jne    2cce <botlish_fn_22+0x14e>
    2cc3:	mov    rdx,r12
    2cc6:	mov    rsi,rax
    2cc9:	jmp    2cf1 <botlish_fn_22+0x171>
    2cce:	mov    rsi,r12
    2cd1:	mov    r8,rax
    2cd4:	sub    r8,rsi
    2cd7:	mov    r13,rax
    2cda:	seto   r10b
    2cde:	lea    rsi,[r8+0x1]
    2ce2:	test   r10b,r10b
    2ce5:	je     2cfc <botlish_fn_22+0x17c>
    2ceb:	mov    rdx,r12
    2cee:	mov    rsi,r13
    2cf1:	mov    rdi,rbx
    2cf4:	call   2cf9 <botlish_fn_22+0x179>
			2cf5: R_X86_64_PLT32	rt_int_sub-0x4
    2cf9:	mov    rsi,rax
    2cfc:	test   rsi,0x1
    2d03:	jne    2d2e <botlish_fn_22+0x1ae>
    2d09:	mov    edx,0x5
    2d0e:	mov    rdi,rbx
    2d11:	call   2d16 <botlish_fn_22+0x196>
			2d12: R_X86_64_PLT32	rt_int_cmp-0x4
    2d16:	mov    ecx,0x2
    2d1b:	test   rax,rax
    2d1e:	mov    rax,rcx
    2d21:	cmovge rax,QWORD PTR [rip+0x37]        # 2d60 <botlish_fn_22+0x1e0>
    2d29:	jmp    2d3f <botlish_fn_22+0x1bf>
    2d2e:	mov    eax,0x2
    2d33:	cmp    rsi,0x5
    2d37:	cmovge rax,QWORD PTR [rip+0x21]        # 2d60 <botlish_fn_22+0x1e0>
    2d3f:	mov    rbx,QWORD PTR [rsp+0x20]
    2d44:	mov    r12,QWORD PTR [rsp+0x28]
    2d49:	mov    r13,QWORD PTR [rsp+0x30]
    2d4e:	mov    r14,QWORD PTR [rsp+0x38]
    2d53:	add    rsp,0x40
    2d57:	mov    rsp,rbp
    2d5a:	pop    rbp
    2d5b:	ret
    2d5c:	add    BYTE PTR [rax],al
    2d5e:	add    BYTE PTR [rax],al
    2d60:	(bad)
    2d61:	add    BYTE PTR [rax],al
    2d63:	add    BYTE PTR [rax],al
    2d65:	add    BYTE PTR [rax],al
	...

0000000000002d68 <botlish_entry_22: tld_ok<generic>>:
    2d68:	push   rbp
    2d69:	mov    rbp,rsp
    2d6c:	mov    rsi,QWORD PTR [rdx]
    2d6f:	mov    r8,QWORD PTR [rdx+0x8]
    2d73:	mov    rcx,QWORD PTR [rdx+0x10]
    2d77:	mov    rdx,r8
    2d7a:	call   2d7f <botlish_entry_22+0x17>
			2d7b: R_X86_64_PLT32	botlish_fn_22-0x4 ; tld_ok<generic>
    2d7f:	mov    rsp,rbp
    2d82:	pop    rbp
    2d83:	ret
    2d84:	add    BYTE PTR [rax],al
	...

0000000000002d88 <botlish_fn_23: domain_loop<generic>>:
    2d88:	push   rbp
    2d89:	mov    rbp,rsp
    2d8c:	sub    rsp,0x70
    2d90:	mov    QWORD PTR [rsp+0x40],rbx
    2d95:	mov    QWORD PTR [rsp+0x48],r12
    2d9a:	mov    QWORD PTR [rsp+0x50],r13
    2d9f:	mov    QWORD PTR [rsp+0x58],r14
    2da4:	mov    QWORD PTR [rsp+0x60],r15
    2da9:	mov    QWORD PTR [rsp+0x18],0x0
    2db2:	mov    QWORD PTR [rsp],rsi
    2db6:	mov    QWORD PTR [rsp+0x8],rdx
    2dbb:	mov    QWORD PTR [rsp+0x10],rcx
    2dc0:	lea    rbx,[rsp+0x20]
    2dc5:	mov    r12,rdi
    2dc8:	mov    r13,rcx
    2dcb:	mov    r14,rdx
    2dce:	mov    QWORD PTR [rsp+0x30],rsi
    2dd3:	mov    rcx,r13
    2dd6:	mov    rdx,r14
    2dd9:	mov    rsi,QWORD PTR [rsp+0x30]
    2dde:	mov    rdi,r12
    2de1:	call   2de6 <botlish_fn_23+0x5e>
			2de2: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_label<generic>
    2de6:	mov    rcx,rax
    2de9:	mov    r15,rax
    2dec:	test   rax,rcx
    2def:	je     2f3f <botlish_fn_23+0x1b7>
    2df5:	mov    rax,r15
    2df8:	mov    QWORD PTR [rsp],rax
    2dfc:	mov    rdx,QWORD PTR [rsp+0x30]
    2e01:	and    rax,rdx
    2e04:	test   rax,0x1
    2e0a:	jne    2e29 <botlish_fn_23+0xa1>
    2e10:	mov    rsi,r15
    2e13:	mov    rdi,r12
    2e16:	call   2e1b <botlish_fn_23+0x93>
			2e17: R_X86_64_PLT32	rt_value_eq-0x4
    2e1b:	test   rax,rax
    2e1e:	je     2f3f <botlish_fn_23+0x1b7>
    2e24:	jmp    2e39 <botlish_fn_23+0xb1>
    2e29:	mov    eax,0x2
    2e2e:	cmp    r15,rdx
    2e31:	cmove  rax,QWORD PTR [rip+0x187]        # 2fc0 <botlish_fn_23+0x238>
    2e39:	cmp    rax,0x6
    2e3d:	je     2f95 <botlish_fn_23+0x20d>
    2e43:	mov    rax,r15
    2e46:	and    rax,r14
    2e49:	test   rax,0x1
    2e4f:	jne    2e78 <botlish_fn_23+0xf0>
    2e55:	mov    rdx,r14
    2e58:	mov    rsi,r15
    2e5b:	mov    rdi,r12
    2e5e:	call   2e63 <botlish_fn_23+0xdb>
			2e5f: R_X86_64_PLT32	rt_int_cmp-0x4
    2e63:	mov    ecx,0x2
    2e68:	test   rax,rax
    2e6b:	cmovge rcx,QWORD PTR [rip+0x14d]        # 2fc0 <botlish_fn_23+0x238>
    2e73:	jmp    2e88 <botlish_fn_23+0x100>
    2e78:	mov    ecx,0x2
    2e7d:	cmp    r15,r14
    2e80:	cmovge rcx,QWORD PTR [rip+0x138]        # 2fc0 <botlish_fn_23+0x238>
    2e88:	cmp    rcx,0x6
    2e8c:	je     2f86 <botlish_fn_23+0x1fe>
    2e92:	mov    rcx,rbx
    2e95:	mov    rdx,r13
    2e98:	mov    rsi,r15
    2e9b:	mov    rdi,r12
    2e9e:	call   2ea3 <botlish_fn_23+0x11b>
			2e9f: R_X86_64_PLT32	botlish_fn_18-0x4 ; char_at<generic>
    2ea3:	test   rax,rax
    2ea6:	je     2f3f <botlish_fn_23+0x1b7>
    2eac:	mov    rdx,QWORD PTR [rsp+0x20]
    2eb1:	mov    rcx,QWORD PTR [rsp+0x28]
    2eb6:	mov    rsi,QWORD PTR [r12+0x10]
    2ebb:	mov    r8,QWORD PTR [rsi+0x130]
    2ec2:	mov    rsi,rax
    2ec5:	mov    rdi,r12
    2ec8:	call   2ecd <botlish_fn_23+0x145>
			2ec9: R_X86_64_PLT32	rt_str_region_eq-0x4
    2ecd:	cmp    rax,0x6
    2ed1:	je     2ee3 <botlish_fn_23+0x15b>
    2ed7:	mov    r14,0xffffffffffffffff
    2ede:	jmp    2f8d <botlish_fn_23+0x205>
    2ee3:	mov    QWORD PTR [rsp+0x18],0x3
    2eec:	test   r15,0x1
    2ef3:	je     2f0b <botlish_fn_23+0x183>
    2ef9:	mov    rdx,r15
    2efc:	add    rdx,0x2
    2f00:	seto   al
    2f03:	test   al,al
    2f05:	je     2f1e <botlish_fn_23+0x196>
    2f0b:	mov    edx,0x3
    2f10:	mov    rsi,r15
    2f13:	mov    rdi,r12
    2f16:	call   2f1b <botlish_fn_23+0x193>
			2f17: R_X86_64_PLT32	rt_int_add-0x4
    2f1b:	mov    rdx,rax
    2f1e:	mov    QWORD PTR [rsp],rdx
    2f22:	mov    r15,rdx
    2f25:	mov    rcx,r13
    2f28:	mov    rdx,r14
    2f2b:	mov    rsi,r15
    2f2e:	mov    rdi,r12
    2f31:	call   2f36 <botlish_fn_23+0x1ae>
			2f32: R_X86_64_PLT32	botlish_fn_22-0x4 ; tld_ok<generic>
    2f36:	test   rax,rax
    2f39:	jne    2f64 <botlish_fn_23+0x1dc>
    2f3f:	xor    rax,rax
    2f42:	mov    rbx,QWORD PTR [rsp+0x40]
    2f47:	mov    r12,QWORD PTR [rsp+0x48]
    2f4c:	mov    r13,QWORD PTR [rsp+0x50]
    2f51:	mov    r14,QWORD PTR [rsp+0x58]
    2f56:	mov    r15,QWORD PTR [rsp+0x60]
    2f5b:	add    rsp,0x70
    2f5f:	mov    rsp,rbp
    2f62:	pop    rbp
    2f63:	ret
    2f64:	cmp    rax,0x6
    2f68:	je     2f8d <botlish_fn_23+0x205>
    2f6e:	mov    QWORD PTR [rsp],r15
    2f72:	mov    QWORD PTR [rsp+0x8],r14
    2f77:	mov    QWORD PTR [rsp+0x10],r13
    2f7c:	mov    QWORD PTR [rsp+0x30],r15
    2f81:	jmp    2dd3 <botlish_fn_23+0x4b>
    2f86:	mov    r14,0xffffffffffffffff
    2f8d:	mov    rax,r14
    2f90:	jmp    2f9c <botlish_fn_23+0x214>
    2f95:	mov    rax,0xffffffffffffffff
    2f9c:	mov    rbx,QWORD PTR [rsp+0x40]
    2fa1:	mov    r12,QWORD PTR [rsp+0x48]
    2fa6:	mov    r13,QWORD PTR [rsp+0x50]
    2fab:	mov    r14,QWORD PTR [rsp+0x58]
    2fb0:	mov    r15,QWORD PTR [rsp+0x60]
    2fb5:	add    rsp,0x70
    2fb9:	mov    rsp,rbp
    2fbc:	pop    rbp
    2fbd:	ret
    2fbe:	add    BYTE PTR [rax],al
    2fc0:	(bad)
    2fc1:	add    BYTE PTR [rax],al
    2fc3:	add    BYTE PTR [rax],al
    2fc5:	add    BYTE PTR [rax],al
	...

0000000000002fc8 <botlish_entry_23: domain_loop<generic>>:
    2fc8:	push   rbp
    2fc9:	mov    rbp,rsp
    2fcc:	mov    rsi,QWORD PTR [rdx]
    2fcf:	mov    r8,QWORD PTR [rdx+0x8]
    2fd3:	mov    rcx,QWORD PTR [rdx+0x10]
    2fd7:	mov    rdx,r8
    2fda:	call   2fdf <botlish_entry_23+0x17>
			2fdb: R_X86_64_PLT32	botlish_fn_23-0x4 ; domain_loop<generic>
    2fdf:	mov    rsp,rbp
    2fe2:	pop    rbp
    2fe3:	ret
    2fe4:	add    BYTE PTR [rax],al
	...

0000000000002fe8 <botlish_fn_24: <str>>:
    2fe8:	push   rbp
    2fe9:	mov    rbp,rsp
    2fec:	sub    rsp,0x50
    2ff0:	mov    QWORD PTR [rsp+0x30],rbx
    2ff5:	mov    QWORD PTR [rsp+0x38],r12
    2ffa:	mov    QWORD PTR [rsp+0x40],r13
    2fff:	mov    QWORD PTR [rsp+0x48],r14
    3004:	mov    r13,rdi
    3007:	mov    QWORD PTR [rsp+0x18],0x0
    3010:	mov    QWORD PTR [rsp],rsi
    3014:	mov    r14,rsi
    3017:	mov    rsi,r14
    301a:	mov    rdi,r13
    301d:	call   3022 <botlish_fn_24+0x3a>
			301e: R_X86_64_PLT32	rt_str_len-0x4
    3022:	mov    rbx,rax
    3025:	mov    QWORD PTR [rsp+0x8],rax
    302a:	mov    esi,0x1
    302f:	mov    QWORD PTR [rsp+0x10],0x1
    3038:	mov    rcx,r14
    303b:	mov    rdx,rbx
    303e:	mov    rdi,r13
    3041:	call   3046 <botlish_fn_24+0x5e>
			3042: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_local<generic>
    3046:	mov    r12,rax
    3049:	test   r12,r12
    304c:	je     31a9 <botlish_fn_24+0x1c1>
    3052:	mov    QWORD PTR [rsp+0x10],r12
    3057:	test   r12,0x1
    305e:	jne    3089 <botlish_fn_24+0xa1>
    3064:	mov    edx,0x1
    3069:	mov    rsi,r12
    306c:	mov    rdi,r13
    306f:	call   3074 <botlish_fn_24+0x8c>
			3070: R_X86_64_PLT32	rt_int_cmp-0x4
    3074:	mov    ecx,0x2
    3079:	test   rax,rax
    307c:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 3248 <botlish_fn_24+0x260>
    3084:	jmp    309a <botlish_fn_24+0xb2>
    3089:	mov    ecx,0x2
    308e:	cmp    r12,0x1
    3092:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 3248 <botlish_fn_24+0x260>
    309a:	cmp    rcx,0x6
    309e:	je     3224 <botlish_fn_24+0x23c>
    30a4:	mov    rcx,r12
    30a7:	and    rcx,rbx
    30aa:	test   rcx,0x1
    30b1:	jne    30da <botlish_fn_24+0xf2>
    30b7:	mov    rdx,rbx
    30ba:	mov    rsi,r12
    30bd:	mov    rdi,r13
    30c0:	call   30c5 <botlish_fn_24+0xdd>
			30c1: R_X86_64_PLT32	rt_int_cmp-0x4
    30c5:	mov    ecx,0x2
    30ca:	test   rax,rax
    30cd:	cmovge rcx,QWORD PTR [rip+0x173]        # 3248 <botlish_fn_24+0x260>
    30d5:	jmp    30ea <botlish_fn_24+0x102>
    30da:	mov    ecx,0x2
    30df:	cmp    r12,rbx
    30e2:	cmovge rcx,QWORD PTR [rip+0x15e]        # 3248 <botlish_fn_24+0x260>
    30ea:	cmp    rcx,0x6
    30ee:	je     321a <botlish_fn_24+0x232>
    30f4:	lea    rcx,[rsp+0x20]
    30f9:	mov    rdx,r14
    30fc:	mov    rsi,r12
    30ff:	mov    rdi,r13
    3102:	call   3107 <botlish_fn_24+0x11f>
			3103: R_X86_64_PLT32	botlish_fn_26-0x4 ; char_at<generic>
    3107:	test   rax,rax
    310a:	mov    rsi,rax
    310d:	je     31a9 <botlish_fn_24+0x1c1>
    3113:	mov    rdx,QWORD PTR [rsp+0x20]
    3118:	mov    rcx,QWORD PTR [rsp+0x28]
    311d:	mov    rdi,r13
    3120:	mov    rax,QWORD PTR [rdi+0x10]
    3124:	mov    r8,QWORD PTR [rax+0x118]
    312b:	call   3130 <botlish_fn_24+0x148>
			312c: R_X86_64_PLT32	rt_str_region_eq-0x4
    3130:	cmp    rax,0x6
    3134:	je     3147 <botlish_fn_24+0x15f>
    313a:	mov    ecx,0x2
    313f:	mov    rax,rcx
    3142:	jmp    3229 <botlish_fn_24+0x241>
    3147:	mov    QWORD PTR [rsp+0x18],0x3
    3150:	test   r12,0x1
    3157:	jne    3165 <botlish_fn_24+0x17d>
    315d:	mov    rcx,r12
    3160:	jmp    317a <botlish_fn_24+0x192>
    3165:	mov    rsi,r12
    3168:	add    rsi,0x2
    316c:	mov    rcx,r12
    316f:	seto   al
    3172:	test   al,al
    3174:	je     318d <botlish_fn_24+0x1a5>
    317a:	mov    edx,0x3
    317f:	mov    rsi,rcx
    3182:	mov    rdi,r13
    3185:	call   318a <botlish_fn_24+0x1a2>
			3186: R_X86_64_PLT32	rt_int_add-0x4
    318a:	mov    rsi,rax
    318d:	mov    QWORD PTR [rsp+0x10],rsi
    3192:	mov    rcx,r14
    3195:	mov    rdx,rbx
    3198:	mov    rdi,r13
    319b:	call   31a0 <botlish_fn_24+0x1b8>
			319c: R_X86_64_PLT32	botlish_fn_31-0x4 ; domain_loop<generic>
    31a0:	test   rax,rax
    31a3:	jne    31c9 <botlish_fn_24+0x1e1>
    31a9:	xor    rax,rax
    31ac:	mov    rbx,QWORD PTR [rsp+0x30]
    31b1:	mov    r12,QWORD PTR [rsp+0x38]
    31b6:	mov    r13,QWORD PTR [rsp+0x40]
    31bb:	mov    r14,QWORD PTR [rsp+0x48]
    31c0:	add    rsp,0x50
    31c4:	mov    rsp,rbp
    31c7:	pop    rbp
    31c8:	ret
    31c9:	mov    rcx,rax
    31cc:	and    rcx,rbx
    31cf:	mov    rsi,rax
    31d2:	test   rcx,0x1
    31d9:	jne    3202 <botlish_fn_24+0x21a>
    31df:	mov    rdx,rbx
    31e2:	mov    rdi,r13
    31e5:	call   31ea <botlish_fn_24+0x202>
			31e6: R_X86_64_PLT32	rt_int_cmp-0x4
    31ea:	mov    ecx,0x2
    31ef:	test   rax,rax
    31f2:	mov    rax,rcx
    31f5:	cmove  rax,QWORD PTR [rip+0x4b]        # 3248 <botlish_fn_24+0x260>
    31fd:	jmp    3229 <botlish_fn_24+0x241>
    3202:	mov    rdx,rbx
    3205:	mov    eax,0x2
    320a:	cmp    rsi,rdx
    320d:	cmove  rax,QWORD PTR [rip+0x33]        # 3248 <botlish_fn_24+0x260>
    3215:	jmp    3229 <botlish_fn_24+0x241>
    321a:	mov    eax,0x2
    321f:	jmp    3229 <botlish_fn_24+0x241>
    3224:	mov    eax,0x2
    3229:	mov    rbx,QWORD PTR [rsp+0x30]
    322e:	mov    r12,QWORD PTR [rsp+0x38]
    3233:	mov    r13,QWORD PTR [rsp+0x40]
    3238:	mov    r14,QWORD PTR [rsp+0x48]
    323d:	add    rsp,0x50
    3241:	mov    rsp,rbp
    3244:	pop    rbp
    3245:	ret
    3246:	add    BYTE PTR [rax],al
    3248:	(bad)
    3249:	add    BYTE PTR [rax],al
    324b:	add    BYTE PTR [rax],al
    324d:	add    BYTE PTR [rax],al
	...

0000000000003250 <botlish_entry_24: <str>>:
    3250:	push   rbp
    3251:	mov    rbp,rsp
    3254:	mov    rsi,QWORD PTR [rdx]
    3257:	call   325c <botlish_entry_24+0xc>
			3258: R_X86_64_PLT32	botlish_fn_24-0x4 ; <str>
    325c:	mov    rsp,rbp
    325f:	pop    rbp
    3260:	ret
    3261:	add    BYTE PTR [rax],al
    3263:	add    BYTE PTR [rax],al
    3265:	add    BYTE PTR [rax],al
	...

0000000000003268 <botlish_fn_25: <generic>>:
    3268:	push   rbp
    3269:	mov    rbp,rsp
    326c:	sub    rsp,0x60
    3270:	mov    QWORD PTR [rsp+0x30],rbx
    3275:	mov    QWORD PTR [rsp+0x38],r12
    327a:	mov    QWORD PTR [rsp+0x40],r13
    327f:	mov    QWORD PTR [rsp+0x48],r14
    3284:	mov    QWORD PTR [rsp+0x50],r15
    3289:	mov    QWORD PTR [rsp+0x18],0x0
    3292:	mov    QWORD PTR [rsp],rsi
    3296:	xor    r8d,r8d
    3299:	test   rsi,0x7
    32a0:	jne    32b0 <botlish_fn_25+0x48>
    32a6:	movzx  rax,BYTE PTR [rsi]
    32aa:	cmp    al,0x2
    32ac:	sete   r8b
    32b0:	test   r8b,r8b
    32b3:	jne    32d3 <botlish_fn_25+0x6b>
    32b9:	mov    rdx,QWORD PTR [rdi+0x10]
    32bd:	mov    rcx,QWORD PTR [rdx+0xf0]
    32c4:	mov    edx,0x1
    32c9:	call   32ce <botlish_fn_25+0x66>
			32ca: R_X86_64_PLT32	rt_type_error-0x4
    32ce:	jmp    3468 <botlish_fn_25+0x200>
    32d3:	mov    r13,rsi
    32d6:	mov    r14,rdi
    32d9:	call   32de <botlish_fn_25+0x76>
			32da: R_X86_64_PLT32	rt_str_len-0x4
    32de:	mov    rbx,rax
    32e1:	mov    QWORD PTR [rsp+0x8],rax
    32e6:	mov    edx,0x1
    32eb:	mov    r15,rdx
    32ee:	mov    QWORD PTR [rsp+0x10],0x1
    32f7:	mov    rcx,r13
    32fa:	mov    rdx,rbx
    32fd:	mov    rsi,r15
    3300:	mov    rdi,r14
    3303:	call   3308 <botlish_fn_25+0xa0>
			3304: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_local<generic>
    3308:	mov    r12,rax
    330b:	test   r12,r12
    330e:	je     3468 <botlish_fn_25+0x200>
    3314:	mov    QWORD PTR [rsp+0x10],r12
    3319:	test   r12,0x1
    3320:	jne    3349 <botlish_fn_25+0xe1>
    3326:	mov    rdx,r15
    3329:	mov    rsi,r12
    332c:	mov    rdi,r14
    332f:	call   3334 <botlish_fn_25+0xcc>
			3330: R_X86_64_PLT32	rt_int_cmp-0x4
    3334:	mov    ecx,0x2
    3339:	test   rax,rax
    333c:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 3510 <botlish_fn_25+0x2a8>
    3344:	jmp    335a <botlish_fn_25+0xf2>
    3349:	mov    ecx,0x2
    334e:	cmp    r12,0x1
    3352:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 3510 <botlish_fn_25+0x2a8>
    335a:	cmp    rcx,0x6
    335e:	je     34e8 <botlish_fn_25+0x280>
    3364:	mov    rax,r12
    3367:	and    rax,rbx
    336a:	test   rax,0x1
    3370:	jne    3399 <botlish_fn_25+0x131>
    3376:	mov    rdx,rbx
    3379:	mov    rsi,r12
    337c:	mov    rdi,r14
    337f:	call   3384 <botlish_fn_25+0x11c>
			3380: R_X86_64_PLT32	rt_int_cmp-0x4
    3384:	mov    ecx,0x2
    3389:	test   rax,rax
    338c:	cmovge rcx,QWORD PTR [rip+0x17c]        # 3510 <botlish_fn_25+0x2a8>
    3394:	jmp    33a9 <botlish_fn_25+0x141>
    3399:	mov    ecx,0x2
    339e:	cmp    r12,rbx
    33a1:	cmovge rcx,QWORD PTR [rip+0x167]        # 3510 <botlish_fn_25+0x2a8>
    33a9:	cmp    rcx,0x6
    33ad:	je     34de <botlish_fn_25+0x276>
    33b3:	lea    rcx,[rsp+0x20]
    33b8:	mov    rdx,r13
    33bb:	mov    rsi,r12
    33be:	mov    rdi,r14
    33c1:	call   33c6 <botlish_fn_25+0x15e>
			33c2: R_X86_64_PLT32	botlish_fn_26-0x4 ; char_at<generic>
    33c6:	test   rax,rax
    33c9:	mov    rsi,rax
    33cc:	je     3468 <botlish_fn_25+0x200>
    33d2:	mov    rdx,QWORD PTR [rsp+0x20]
    33d7:	mov    rcx,QWORD PTR [rsp+0x28]
    33dc:	mov    rdi,r14
    33df:	mov    rax,QWORD PTR [rdi+0x10]
    33e3:	mov    r8,QWORD PTR [rax+0x118]
    33ea:	call   33ef <botlish_fn_25+0x187>
			33eb: R_X86_64_PLT32	rt_str_region_eq-0x4
    33ef:	cmp    rax,0x6
    33f3:	je     3406 <botlish_fn_25+0x19e>
    33f9:	mov    ecx,0x2
    33fe:	mov    rax,rcx
    3401:	jmp    34ed <botlish_fn_25+0x285>
    3406:	mov    QWORD PTR [rsp+0x18],0x3
    340f:	test   r12,0x1
    3416:	jne    3424 <botlish_fn_25+0x1bc>
    341c:	mov    rdi,r12
    341f:	jmp    3439 <botlish_fn_25+0x1d1>
    3424:	mov    rsi,r12
    3427:	add    rsi,0x2
    342b:	mov    rdi,r12
    342e:	seto   al
    3431:	test   al,al
    3433:	je     344c <botlish_fn_25+0x1e4>
    3439:	mov    edx,0x3
    343e:	mov    rsi,rdi
    3441:	mov    rdi,r14
    3444:	call   3449 <botlish_fn_25+0x1e1>
			3445: R_X86_64_PLT32	rt_int_add-0x4
    3449:	mov    rsi,rax
    344c:	mov    QWORD PTR [rsp+0x10],rsi
    3451:	mov    rcx,r13
    3454:	mov    rdx,rbx
    3457:	mov    rdi,r14
    345a:	call   345f <botlish_fn_25+0x1f7>
			345b: R_X86_64_PLT32	botlish_fn_31-0x4 ; domain_loop<generic>
    345f:	test   rax,rax
    3462:	jne    348d <botlish_fn_25+0x225>
    3468:	xor    rax,rax
    346b:	mov    rbx,QWORD PTR [rsp+0x30]
    3470:	mov    r12,QWORD PTR [rsp+0x38]
    3475:	mov    r13,QWORD PTR [rsp+0x40]
    347a:	mov    r14,QWORD PTR [rsp+0x48]
    347f:	mov    r15,QWORD PTR [rsp+0x50]
    3484:	add    rsp,0x60
    3488:	mov    rsp,rbp
    348b:	pop    rbp
    348c:	ret
    348d:	mov    rcx,rax
    3490:	and    rcx,rbx
    3493:	mov    rsi,rax
    3496:	test   rcx,0x1
    349d:	jne    34c6 <botlish_fn_25+0x25e>
    34a3:	mov    rdx,rbx
    34a6:	mov    rdi,r14
    34a9:	call   34ae <botlish_fn_25+0x246>
			34aa: R_X86_64_PLT32	rt_int_cmp-0x4
    34ae:	mov    ecx,0x2
    34b3:	test   rax,rax
    34b6:	mov    rax,rcx
    34b9:	cmove  rax,QWORD PTR [rip+0x4f]        # 3510 <botlish_fn_25+0x2a8>
    34c1:	jmp    34ed <botlish_fn_25+0x285>
    34c6:	mov    rdx,rbx
    34c9:	mov    eax,0x2
    34ce:	cmp    rsi,rdx
    34d1:	cmove  rax,QWORD PTR [rip+0x37]        # 3510 <botlish_fn_25+0x2a8>
    34d9:	jmp    34ed <botlish_fn_25+0x285>
    34de:	mov    eax,0x2
    34e3:	jmp    34ed <botlish_fn_25+0x285>
    34e8:	mov    eax,0x2
    34ed:	mov    rbx,QWORD PTR [rsp+0x30]
    34f2:	mov    r12,QWORD PTR [rsp+0x38]
    34f7:	mov    r13,QWORD PTR [rsp+0x40]
    34fc:	mov    r14,QWORD PTR [rsp+0x48]
    3501:	mov    r15,QWORD PTR [rsp+0x50]
    3506:	add    rsp,0x60
    350a:	mov    rsp,rbp
    350d:	pop    rbp
    350e:	ret
    350f:	add    BYTE PTR [rsi],al
    3511:	add    BYTE PTR [rax],al
    3513:	add    BYTE PTR [rax],al
    3515:	add    BYTE PTR [rax],al
	...

0000000000003518 <botlish_entry_25: <generic>>:
    3518:	push   rbp
    3519:	mov    rbp,rsp
    351c:	mov    rsi,QWORD PTR [rdx]
    351f:	call   3524 <botlish_entry_25+0xc>
			3520: R_X86_64_PLT32	botlish_fn_25-0x4 ; <generic>
    3524:	mov    rsp,rbp
    3527:	pop    rbp
    3528:	ret

0000000000003529 <botlish_fn_26: char_at<generic>>:
    3529:	push   rbp
    352a:	mov    rbp,rsp
    352d:	sub    rsp,0x50
    3531:	mov    QWORD PTR [rsp+0x20],rbx
    3536:	mov    QWORD PTR [rsp+0x28],r12
    353b:	mov    QWORD PTR [rsp+0x30],r13
    3540:	mov    QWORD PTR [rsp+0x38],r14
    3545:	mov    QWORD PTR [rsp+0x40],r15
    354a:	mov    r14,rcx
    354d:	mov    QWORD PTR [rsp],rsi
    3551:	mov    QWORD PTR [rsp+0x8],rdx
    3556:	mov    r13,rdx
    3559:	mov    QWORD PTR [rsp+0x10],0x3
    3562:	mov    r9d,0x1
    3568:	test   rsi,0x1
    356f:	jne    358f <botlish_fn_26+0x66>
    3575:	xor    r9d,r9d
    3578:	test   rsi,0x7
    357f:	jne    358f <botlish_fn_26+0x66>
    3585:	movzx  rax,BYTE PTR [rsi]
    3589:	cmp    al,0x1
    358b:	sete   r9b
    358f:	test   r9b,r9b
    3592:	jne    35b0 <botlish_fn_26+0x87>
    3598:	mov    rax,QWORD PTR [rdi+0x10]
    359c:	mov    rcx,QWORD PTR [rax+0x120]
    35a3:	xor    rdx,rdx
    35a6:	call   35ab <botlish_fn_26+0x82>
			35a7: R_X86_64_PLT32	rt_type_error-0x4
    35ab:	jmp    366d <botlish_fn_26+0x144>
    35b0:	mov    r12,rdi
    35b3:	test   rsi,0x1
    35ba:	jne    35c8 <botlish_fn_26+0x9f>
    35c0:	mov    rbx,rsi
    35c3:	jmp    35e5 <botlish_fn_26+0xbc>
    35c8:	mov    rax,rsi
    35cb:	add    rax,0x2
    35cf:	mov    rbx,rsi
    35d2:	seto   cl
    35d5:	test   cl,cl
    35d7:	jne    35e5 <botlish_fn_26+0xbc>
    35dd:	mov    r15,rax
    35e0:	jmp    35f8 <botlish_fn_26+0xcf>
    35e5:	mov    edx,0x3
    35ea:	mov    rsi,rbx
    35ed:	mov    rdi,r12
    35f0:	call   35f5 <botlish_fn_26+0xcc>
			35f1: R_X86_64_PLT32	rt_int_add-0x4
    35f5:	mov    r15,rax
    35f8:	mov    ecx,0x1
    35fd:	mov    rsi,rbx
    3600:	test   rsi,0x1
    3607:	jne    362d <botlish_fn_26+0x104>
    360d:	xor    ecx,ecx
    360f:	mov    rsi,rbx
    3612:	test   rsi,0x7
    3619:	jne    362d <botlish_fn_26+0x104>
    361f:	mov    rsi,rbx
    3622:	movzx  rcx,BYTE PTR [rsi]
    3626:	rex cmp cl,0x1
    362a:	sete   cl
    362d:	test   cl,cl
    362f:	jne    3653 <botlish_fn_26+0x12a>
    3635:	mov    rdi,r12
    3638:	mov    rsi,QWORD PTR [rdi+0x10]
    363c:	mov    rcx,QWORD PTR [rsi+0x128]
    3643:	xor    rdx,rdx
    3646:	mov    rsi,rbx
    3649:	call   364e <botlish_fn_26+0x125>
			364a: R_X86_64_PLT32	rt_type_error-0x4
    364e:	jmp    366d <botlish_fn_26+0x144>
    3653:	mov    rdi,r12
    3656:	mov    rcx,r15
    3659:	mov    rdx,rbx
    365c:	mov    rsi,r13
    365f:	call   3664 <botlish_fn_26+0x13b>
			3660: R_X86_64_PLT32	rt_str_region_check-0x4
    3664:	test   rax,rax
    3667:	jne    3692 <botlish_fn_26+0x169>
    366d:	xor    rax,rax
    3670:	mov    rbx,QWORD PTR [rsp+0x20]
    3675:	mov    r12,QWORD PTR [rsp+0x28]
    367a:	mov    r13,QWORD PTR [rsp+0x30]
    367f:	mov    r14,QWORD PTR [rsp+0x38]
    3684:	mov    r15,QWORD PTR [rsp+0x40]
    3689:	add    rsp,0x50
    368d:	mov    rsp,rbp
    3690:	pop    rbp
    3691:	ret
    3692:	mov    rcx,r14
    3695:	mov    rsi,rbx
    3698:	mov    QWORD PTR [rcx],rsi
    369b:	mov    rax,r15
    369e:	mov    QWORD PTR [rcx+0x8],rax
    36a2:	mov    rax,r13
    36a5:	mov    rbx,QWORD PTR [rsp+0x20]
    36aa:	mov    r12,QWORD PTR [rsp+0x28]
    36af:	mov    r13,QWORD PTR [rsp+0x30]
    36b4:	mov    r14,QWORD PTR [rsp+0x38]
    36b9:	mov    r15,QWORD PTR [rsp+0x40]
    36be:	add    rsp,0x50
    36c2:	mov    rsp,rbp
    36c5:	pop    rbp
    36c6:	ret

00000000000036c7 <botlish_entry_26: char_at<generic>>:
    36c7:	push   rbp
    36c8:	mov    rbp,rsp
    36cb:	ud2
    36cd:	add    BYTE PTR [rax],al
	...

00000000000036d0 <botlish_fn_27: scan_local<generic>>:
    36d0:	push   rbp
    36d1:	mov    rbp,rsp
    36d4:	sub    rsp,0x80
    36db:	mov    QWORD PTR [rsp+0x50],rbx
    36e0:	mov    QWORD PTR [rsp+0x58],r12
    36e5:	mov    QWORD PTR [rsp+0x60],r13
    36ea:	mov    QWORD PTR [rsp+0x68],r14
    36ef:	mov    QWORD PTR [rsp+0x70],r15
    36f4:	mov    rax,rdi
    36f7:	mov    QWORD PTR [rsp+0x18],0x0
    3700:	mov    QWORD PTR [rsp],rsi
    3704:	mov    r14,rsi
    3707:	mov    QWORD PTR [rsp+0x8],rdx
    370c:	mov    QWORD PTR [rsp+0x10],rcx
    3711:	mov    r12,rcx
    3714:	mov    r11d,0x1
    371a:	mov    rsi,r14
    371d:	test   rsi,0x1
    3724:	jne    3746 <botlish_fn_27+0x76>
    372a:	xor    r11d,r11d
    372d:	test   rsi,0x7
    3734:	jne    3746 <botlish_fn_27+0x76>
    373a:	movzx  rdi,BYTE PTR [rsi]
    373e:	cmp    dil,0x1
    3742:	sete   r11b
    3746:	test   r11b,r11b
    3749:	jne    376a <botlish_fn_27+0x9a>
    374f:	mov    rdi,rax
    3752:	mov    r9,QWORD PTR [rdi+0x10]
    3756:	mov    rcx,QWORD PTR [r9+0xa8]
    375d:	xor    rdx,rdx
    3760:	call   3765 <botlish_fn_27+0x95>
			3761: R_X86_64_PLT32	rt_type_error-0x4
    3765:	jmp    381d <botlish_fn_27+0x14d>
    376a:	mov    r13,rdx
    376d:	mov    r10,rsi
    3770:	and    r10,r13
    3773:	mov    r14,rsi
    3776:	test   r10,0x1
    377d:	jne    37a9 <botlish_fn_27+0xd9>
    3783:	mov    rbx,rax
    3786:	mov    rdx,r13
    3789:	mov    rsi,r14
    378c:	mov    rdi,rbx
    378f:	call   3794 <botlish_fn_27+0xc4>
			3790: R_X86_64_PLT32	rt_int_cmp-0x4
    3794:	mov    ecx,0x2
    3799:	test   rax,rax
    379c:	cmovge rcx,QWORD PTR [rip+0x24c]        # 39f0 <botlish_fn_27+0x320>
    37a4:	jmp    37bf <botlish_fn_27+0xef>
    37a9:	mov    rbx,rax
    37ac:	mov    ecx,0x2
    37b1:	mov    rsi,r14
    37b4:	cmp    rsi,r13
    37b7:	cmovge rcx,QWORD PTR [rip+0x231]        # 39f0 <botlish_fn_27+0x320>
    37bf:	mov    eax,0x6
    37c4:	mov    QWORD PTR [rsp+0x30],rax
    37c9:	cmp    rcx,0x6
    37cd:	je     39c3 <botlish_fn_27+0x2f3>
    37d3:	lea    rcx,[rsp+0x20]
    37d8:	mov    rdx,r12
    37db:	mov    rsi,r14
    37de:	mov    rdi,rbx
    37e1:	call   37e6 <botlish_fn_27+0x116>
			37e2: R_X86_64_PLT32	botlish_fn_26-0x4 ; char_at<generic>
    37e6:	mov    rsi,rax
    37e9:	mov    r15,rax
    37ec:	test   rax,rsi
    37ef:	je     381d <botlish_fn_27+0x14d>
    37f5:	mov    rdx,QWORD PTR [rsp+0x20]
    37fa:	mov    QWORD PTR [rsp+0x40],rdx
    37ff:	mov    rcx,QWORD PTR [rsp+0x28]
    3804:	mov    QWORD PTR [rsp+0x38],rcx
    3809:	mov    rsi,r15
    380c:	mov    rdi,rbx
    380f:	call   3814 <botlish_fn_27+0x144>
			3810: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    3814:	test   rax,rax
    3817:	jne    3845 <botlish_fn_27+0x175>
    381d:	xor    rax,rax
    3820:	mov    rbx,QWORD PTR [rsp+0x50]
    3825:	mov    r12,QWORD PTR [rsp+0x58]
    382a:	mov    r13,QWORD PTR [rsp+0x60]
    382f:	mov    r14,QWORD PTR [rsp+0x68]
    3834:	mov    r15,QWORD PTR [rsp+0x70]
    3839:	add    rsp,0x80
    3840:	mov    rsp,rbp
    3843:	pop    rbp
    3844:	ret
    3845:	cmp    rax,0x6
    3849:	je     3944 <botlish_fn_27+0x274>
    384f:	mov    rax,QWORD PTR [rbx+0x10]
    3853:	mov    r8,QWORD PTR [rax+0x130]
    385a:	mov    rcx,QWORD PTR [rsp+0x38]
    385f:	mov    rdx,QWORD PTR [rsp+0x40]
    3864:	mov    rsi,r15
    3867:	mov    rdi,rbx
    386a:	call   386f <botlish_fn_27+0x19f>
			386b: R_X86_64_PLT32	rt_str_region_eq-0x4
    386f:	cmp    rax,0x6
    3873:	je     393a <botlish_fn_27+0x26a>
    3879:	mov    rax,QWORD PTR [rbx+0x10]
    387d:	mov    r8,QWORD PTR [rax+0x138]
    3884:	mov    rcx,QWORD PTR [rsp+0x38]
    3889:	mov    rdx,QWORD PTR [rsp+0x40]
    388e:	mov    rsi,r15
    3891:	mov    rdi,rbx
    3894:	call   3899 <botlish_fn_27+0x1c9>
			3895: R_X86_64_PLT32	rt_str_region_eq-0x4
    3899:	cmp    rax,0x6
    389d:	je     3930 <botlish_fn_27+0x260>
    38a3:	mov    rax,QWORD PTR [rbx+0x10]
    38a7:	mov    r8,QWORD PTR [rax+0xd0]
    38ae:	mov    rcx,QWORD PTR [rsp+0x38]
    38b3:	mov    rdx,QWORD PTR [rsp+0x40]
    38b8:	mov    rsi,r15
    38bb:	mov    rdi,rbx
    38be:	call   38c3 <botlish_fn_27+0x1f3>
			38bf: R_X86_64_PLT32	rt_str_region_eq-0x4
    38c3:	cmp    rax,0x6
    38c7:	je     3926 <botlish_fn_27+0x256>
    38cd:	mov    rax,QWORD PTR [rbx+0x10]
    38d1:	mov    r8,QWORD PTR [rax+0x120]
    38d8:	mov    rcx,QWORD PTR [rsp+0x38]
    38dd:	mov    rdx,QWORD PTR [rsp+0x40]
    38e2:	mov    rsi,r15
    38e5:	mov    rdi,rbx
    38e8:	call   38ed <botlish_fn_27+0x21d>
			38e9: R_X86_64_PLT32	rt_str_region_eq-0x4
    38ed:	cmp    rax,0x6
    38f1:	je     391c <botlish_fn_27+0x24c>
    38f7:	mov    rax,QWORD PTR [rbx+0x10]
    38fb:	mov    r8,QWORD PTR [rax+0x140]
    3902:	mov    rcx,QWORD PTR [rsp+0x38]
    3907:	mov    rdx,QWORD PTR [rsp+0x40]
    390c:	mov    rsi,r15
    390f:	mov    rdi,rbx
    3912:	call   3917 <botlish_fn_27+0x247>
			3913: R_X86_64_PLT32	rt_str_region_eq-0x4
    3917:	jmp    3949 <botlish_fn_27+0x279>
    391c:	mov    rax,QWORD PTR [rsp+0x30]
    3921:	jmp    3949 <botlish_fn_27+0x279>
    3926:	mov    rax,QWORD PTR [rsp+0x30]
    392b:	jmp    3949 <botlish_fn_27+0x279>
    3930:	mov    rax,QWORD PTR [rsp+0x30]
    3935:	jmp    3949 <botlish_fn_27+0x279>
    393a:	mov    rax,QWORD PTR [rsp+0x30]
    393f:	jmp    3949 <botlish_fn_27+0x279>
    3944:	mov    rax,QWORD PTR [rsp+0x30]
    3949:	cmp    rax,0x6
    394d:	je     395b <botlish_fn_27+0x28b>
    3953:	mov    rax,r14
    3956:	jmp    39c6 <botlish_fn_27+0x2f6>
    395b:	mov    QWORD PTR [rsp+0x18],0x3
    3964:	mov    rsi,r14
    3967:	test   rsi,0x1
    396e:	je     3994 <botlish_fn_27+0x2c4>
    3974:	mov    rsi,r14
    3977:	mov    rax,rsi
    397a:	add    rax,0x2
    397e:	seto   cl
    3981:	test   cl,cl
    3983:	jne    3994 <botlish_fn_27+0x2c4>
    3989:	mov    rsi,rax
    398c:	mov    r14,rax
    398f:	jmp    39aa <botlish_fn_27+0x2da>
    3994:	mov    edx,0x3
    3999:	mov    rsi,r14
    399c:	mov    rdi,rbx
    399f:	call   39a4 <botlish_fn_27+0x2d4>
			39a0: R_X86_64_PLT32	rt_int_add-0x4
    39a4:	mov    rsi,rax
    39a7:	mov    r14,rax
    39aa:	mov    QWORD PTR [rsp],rsi
    39ae:	mov    QWORD PTR [rsp+0x8],r13
    39b3:	mov    QWORD PTR [rsp+0x10],r12
    39b8:	mov    rax,rbx
    39bb:	mov    rdx,r13
    39be:	jmp    3714 <botlish_fn_27+0x44>
    39c3:	mov    rax,r14
    39c6:	mov    rbx,QWORD PTR [rsp+0x50]
    39cb:	mov    r12,QWORD PTR [rsp+0x58]
    39d0:	mov    r13,QWORD PTR [rsp+0x60]
    39d5:	mov    r14,QWORD PTR [rsp+0x68]
    39da:	mov    r15,QWORD PTR [rsp+0x70]
    39df:	add    rsp,0x80
    39e6:	mov    rsp,rbp
    39e9:	pop    rbp
    39ea:	ret
    39eb:	add    BYTE PTR [rax],al
    39ed:	add    BYTE PTR [rax],al
    39ef:	add    BYTE PTR [rsi],al
    39f1:	add    BYTE PTR [rax],al
    39f3:	add    BYTE PTR [rax],al
    39f5:	add    BYTE PTR [rax],al
	...

00000000000039f8 <botlish_entry_27: scan_local<generic>>:
    39f8:	push   rbp
    39f9:	mov    rbp,rsp
    39fc:	mov    rsi,QWORD PTR [rdx]
    39ff:	mov    r8,QWORD PTR [rdx+0x8]
    3a03:	mov    rcx,QWORD PTR [rdx+0x10]
    3a07:	mov    rdx,r8
    3a0a:	call   3a0f <botlish_entry_27+0x17>
			3a0b: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_local<generic>
    3a0f:	mov    rsp,rbp
    3a12:	pop    rbp
    3a13:	ret
    3a14:	add    BYTE PTR [rax],al
	...

0000000000003a18 <botlish_fn_28: scan_label<generic>>:
    3a18:	push   rbp
    3a19:	mov    rbp,rsp
    3a1c:	sub    rsp,0x80
    3a23:	mov    QWORD PTR [rsp+0x50],rbx
    3a28:	mov    QWORD PTR [rsp+0x58],r12
    3a2d:	mov    QWORD PTR [rsp+0x60],r13
    3a32:	mov    QWORD PTR [rsp+0x68],r14
    3a37:	mov    QWORD PTR [rsp+0x70],r15
    3a3c:	mov    QWORD PTR [rsp+0x18],0x0
    3a45:	mov    QWORD PTR [rsp],rsi
    3a49:	mov    r14,rsi
    3a4c:	mov    QWORD PTR [rsp+0x8],rdx
    3a51:	mov    QWORD PTR [rsp+0x10],rcx
    3a56:	mov    r12,rcx
    3a59:	mov    r11d,0x1
    3a5f:	mov    rsi,r14
    3a62:	test   rsi,0x1
    3a69:	jne    3a89 <botlish_fn_28+0x71>
    3a6f:	xor    r11d,r11d
    3a72:	test   rsi,0x7
    3a79:	jne    3a89 <botlish_fn_28+0x71>
    3a7f:	movzx  rax,BYTE PTR [rsi]
    3a83:	cmp    al,0x1
    3a85:	sete   r11b
    3a89:	test   r11b,r11b
    3a8c:	jne    3aaa <botlish_fn_28+0x92>
    3a92:	mov    rax,QWORD PTR [rdi+0x10]
    3a96:	mov    rcx,QWORD PTR [rax+0xa8]
    3a9d:	xor    rdx,rdx
    3aa0:	call   3aa5 <botlish_fn_28+0x8d>
			3aa1: R_X86_64_PLT32	rt_type_error-0x4
    3aa5:	jmp    3b56 <botlish_fn_28+0x13e>
    3aaa:	mov    r13,rdx
    3aad:	mov    rax,rsi
    3ab0:	and    rax,r13
    3ab3:	mov    r14,rsi
    3ab6:	test   rax,0x1
    3abc:	jne    3ae5 <botlish_fn_28+0xcd>
    3ac2:	mov    rbx,rdi
    3ac5:	mov    rdx,r13
    3ac8:	mov    rsi,r14
    3acb:	call   3ad0 <botlish_fn_28+0xb8>
			3acc: R_X86_64_PLT32	rt_int_cmp-0x4
    3ad0:	mov    ecx,0x2
    3ad5:	test   rax,rax
    3ad8:	cmovge rcx,QWORD PTR [rip+0x178]        # 3c58 <botlish_fn_28+0x240>
    3ae0:	jmp    3afb <botlish_fn_28+0xe3>
    3ae5:	mov    rbx,rdi
    3ae8:	mov    ecx,0x2
    3aed:	mov    rsi,r14
    3af0:	cmp    rsi,r13
    3af3:	cmovge rcx,QWORD PTR [rip+0x15d]        # 3c58 <botlish_fn_28+0x240>
    3afb:	mov    eax,0x6
    3b00:	mov    QWORD PTR [rsp+0x30],rax
    3b05:	cmp    rcx,0x6
    3b09:	je     3c2c <botlish_fn_28+0x214>
    3b0f:	lea    rcx,[rsp+0x20]
    3b14:	mov    rdx,r12
    3b17:	mov    rsi,r14
    3b1a:	mov    rdi,rbx
    3b1d:	call   3b22 <botlish_fn_28+0x10a>
			3b1e: R_X86_64_PLT32	botlish_fn_26-0x4 ; char_at<generic>
    3b22:	test   rax,rax
    3b25:	mov    r15,rax
    3b28:	je     3b56 <botlish_fn_28+0x13e>
    3b2e:	mov    rdx,QWORD PTR [rsp+0x20]
    3b33:	mov    QWORD PTR [rsp+0x40],rdx
    3b38:	mov    rcx,QWORD PTR [rsp+0x28]
    3b3d:	mov    QWORD PTR [rsp+0x38],rcx
    3b42:	mov    rsi,r15
    3b45:	mov    rdi,rbx
    3b48:	call   3b4d <botlish_fn_28+0x135>
			3b49: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    3b4d:	test   rax,rax
    3b50:	jne    3b7e <botlish_fn_28+0x166>
    3b56:	xor    rax,rax
    3b59:	mov    rbx,QWORD PTR [rsp+0x50]
    3b5e:	mov    r12,QWORD PTR [rsp+0x58]
    3b63:	mov    r13,QWORD PTR [rsp+0x60]
    3b68:	mov    r14,QWORD PTR [rsp+0x68]
    3b6d:	mov    r15,QWORD PTR [rsp+0x70]
    3b72:	add    rsp,0x80
    3b79:	mov    rsp,rbp
    3b7c:	pop    rbp
    3b7d:	ret
    3b7e:	cmp    rax,0x6
    3b82:	je     3bad <botlish_fn_28+0x195>
    3b88:	mov    r11,QWORD PTR [rbx+0x10]
    3b8c:	mov    r8,QWORD PTR [r11+0x140]
    3b93:	mov    rcx,QWORD PTR [rsp+0x38]
    3b98:	mov    rdx,QWORD PTR [rsp+0x40]
    3b9d:	mov    rsi,r15
    3ba0:	mov    rdi,rbx
    3ba3:	call   3ba8 <botlish_fn_28+0x190>
			3ba4: R_X86_64_PLT32	rt_str_region_eq-0x4
    3ba8:	jmp    3bb2 <botlish_fn_28+0x19a>
    3bad:	mov    rax,QWORD PTR [rsp+0x30]
    3bb2:	cmp    rax,0x6
    3bb6:	je     3bc4 <botlish_fn_28+0x1ac>
    3bbc:	mov    rax,r14
    3bbf:	jmp    3c2f <botlish_fn_28+0x217>
    3bc4:	mov    QWORD PTR [rsp+0x18],0x3
    3bcd:	mov    rsi,r14
    3bd0:	test   rsi,0x1
    3bd7:	je     3bfd <botlish_fn_28+0x1e5>
    3bdd:	mov    rsi,r14
    3be0:	mov    rax,rsi
    3be3:	add    rax,0x2
    3be7:	seto   cl
    3bea:	test   cl,cl
    3bec:	jne    3bfd <botlish_fn_28+0x1e5>
    3bf2:	mov    rsi,rax
    3bf5:	mov    r14,rax
    3bf8:	jmp    3c13 <botlish_fn_28+0x1fb>
    3bfd:	mov    edx,0x3
    3c02:	mov    rsi,r14
    3c05:	mov    rdi,rbx
    3c08:	call   3c0d <botlish_fn_28+0x1f5>
			3c09: R_X86_64_PLT32	rt_int_add-0x4
    3c0d:	mov    rsi,rax
    3c10:	mov    r14,rax
    3c13:	mov    QWORD PTR [rsp],rsi
    3c17:	mov    QWORD PTR [rsp+0x8],r13
    3c1c:	mov    QWORD PTR [rsp+0x10],r12
    3c21:	mov    rdx,r13
    3c24:	mov    rdi,rbx
    3c27:	jmp    3a59 <botlish_fn_28+0x41>
    3c2c:	mov    rax,r14
    3c2f:	mov    rbx,QWORD PTR [rsp+0x50]
    3c34:	mov    r12,QWORD PTR [rsp+0x58]
    3c39:	mov    r13,QWORD PTR [rsp+0x60]
    3c3e:	mov    r14,QWORD PTR [rsp+0x68]
    3c43:	mov    r15,QWORD PTR [rsp+0x70]
    3c48:	add    rsp,0x80
    3c4f:	mov    rsp,rbp
    3c52:	pop    rbp
    3c53:	ret
    3c54:	add    BYTE PTR [rax],al
    3c56:	add    BYTE PTR [rax],al
    3c58:	(bad)
    3c59:	add    BYTE PTR [rax],al
    3c5b:	add    BYTE PTR [rax],al
    3c5d:	add    BYTE PTR [rax],al
	...

0000000000003c60 <botlish_entry_28: scan_label<generic>>:
    3c60:	push   rbp
    3c61:	mov    rbp,rsp
    3c64:	mov    rsi,QWORD PTR [rdx]
    3c67:	mov    r8,QWORD PTR [rdx+0x8]
    3c6b:	mov    rcx,QWORD PTR [rdx+0x10]
    3c6f:	mov    rdx,r8
    3c72:	call   3c77 <botlish_entry_28+0x17>
			3c73: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_label<generic>
    3c77:	mov    rsp,rbp
    3c7a:	pop    rbp
    3c7b:	ret
    3c7c:	add    BYTE PTR [rax],al
	...

0000000000003c80 <botlish_fn_29: scan_alpha<generic>>:
    3c80:	push   rbp
    3c81:	mov    rbp,rsp
    3c84:	sub    rsp,0x50
    3c88:	mov    QWORD PTR [rsp+0x30],rbx
    3c8d:	mov    QWORD PTR [rsp+0x38],r12
    3c92:	mov    QWORD PTR [rsp+0x40],r13
    3c97:	mov    QWORD PTR [rsp+0x48],r14
    3c9c:	mov    r14,rdi
    3c9f:	mov    QWORD PTR [rsp+0x18],0x0
    3ca8:	mov    QWORD PTR [rsp],rsi
    3cac:	mov    r13,rsi
    3caf:	mov    QWORD PTR [rsp+0x8],rdx
    3cb4:	mov    r12,rdx
    3cb7:	mov    QWORD PTR [rsp+0x10],rcx
    3cbc:	mov    rbx,rcx
    3cbf:	mov    r11d,0x1
    3cc5:	mov    rsi,r13
    3cc8:	test   rsi,0x1
    3ccf:	jne    3cef <botlish_fn_29+0x6f>
    3cd5:	xor    r11d,r11d
    3cd8:	test   rsi,0x7
    3cdf:	jne    3cef <botlish_fn_29+0x6f>
    3ce5:	movzx  rax,BYTE PTR [rsi]
    3ce9:	cmp    al,0x1
    3ceb:	sete   r11b
    3cef:	test   r11b,r11b
    3cf2:	jne    3d13 <botlish_fn_29+0x93>
    3cf8:	mov    rdi,r14
    3cfb:	mov    rax,QWORD PTR [rdi+0x10]
    3cff:	mov    rcx,QWORD PTR [rax+0xa8]
    3d06:	xor    rdx,rdx
    3d09:	call   3d0e <botlish_fn_29+0x8e>
			3d0a: R_X86_64_PLT32	rt_type_error-0x4
    3d0e:	jmp    3da2 <botlish_fn_29+0x122>
    3d13:	mov    rax,rsi
    3d16:	and    rax,r12
    3d19:	mov    r13,rsi
    3d1c:	test   rax,0x1
    3d22:	jne    3d4b <botlish_fn_29+0xcb>
    3d28:	mov    rdx,r12
    3d2b:	mov    rsi,r13
    3d2e:	mov    rdi,r14
    3d31:	call   3d36 <botlish_fn_29+0xb6>
			3d32: R_X86_64_PLT32	rt_int_cmp-0x4
    3d36:	mov    ecx,0x2
    3d3b:	test   rax,rax
    3d3e:	cmovge rcx,QWORD PTR [rip+0x112]        # 3e58 <botlish_fn_29+0x1d8>
    3d46:	jmp    3d5e <botlish_fn_29+0xde>
    3d4b:	mov    ecx,0x2
    3d50:	mov    rsi,r13
    3d53:	cmp    rsi,r12
    3d56:	cmovge rcx,QWORD PTR [rip+0xfa]        # 3e58 <botlish_fn_29+0x1d8>
    3d5e:	cmp    rcx,0x6
    3d62:	je     3e36 <botlish_fn_29+0x1b6>
    3d68:	lea    rcx,[rsp+0x20]
    3d6d:	mov    rdx,rbx
    3d70:	mov    rsi,r13
    3d73:	mov    rdi,r14
    3d76:	call   3d7b <botlish_fn_29+0xfb>
			3d77: R_X86_64_PLT32	botlish_fn_26-0x4 ; char_at<generic>
    3d7b:	test   rax,rax
    3d7e:	mov    rsi,rax
    3d81:	je     3da2 <botlish_fn_29+0x122>
    3d87:	mov    rdx,QWORD PTR [rsp+0x20]
    3d8c:	mov    rcx,QWORD PTR [rsp+0x28]
    3d91:	mov    rdi,r14
    3d94:	call   3d99 <botlish_fn_29+0x119>
			3d95: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    3d99:	test   rax,rax
    3d9c:	jne    3dc2 <botlish_fn_29+0x142>
    3da2:	xor    rax,rax
    3da5:	mov    rbx,QWORD PTR [rsp+0x30]
    3daa:	mov    r12,QWORD PTR [rsp+0x38]
    3daf:	mov    r13,QWORD PTR [rsp+0x40]
    3db4:	mov    r14,QWORD PTR [rsp+0x48]
    3db9:	add    rsp,0x50
    3dbd:	mov    rsp,rbp
    3dc0:	pop    rbp
    3dc1:	ret
    3dc2:	cmp    rax,0x6
    3dc6:	je     3dd4 <botlish_fn_29+0x154>
    3dcc:	mov    rax,r13
    3dcf:	jmp    3e39 <botlish_fn_29+0x1b9>
    3dd4:	mov    QWORD PTR [rsp+0x18],0x3
    3ddd:	mov    rsi,r13
    3de0:	test   rsi,0x1
    3de7:	je     3e0d <botlish_fn_29+0x18d>
    3ded:	mov    rsi,r13
    3df0:	mov    r11,rsi
    3df3:	add    r11,0x2
    3df7:	seto   al
    3dfa:	test   al,al
    3dfc:	jne    3e0d <botlish_fn_29+0x18d>
    3e02:	mov    rsi,r11
    3e05:	mov    r13,r11
    3e08:	jmp    3e23 <botlish_fn_29+0x1a3>
    3e0d:	mov    edx,0x3
    3e12:	mov    rsi,r13
    3e15:	mov    rdi,r14
    3e18:	call   3e1d <botlish_fn_29+0x19d>
			3e19: R_X86_64_PLT32	rt_int_add-0x4
    3e1d:	mov    rsi,rax
    3e20:	mov    r13,rax
    3e23:	mov    QWORD PTR [rsp],rsi
    3e27:	mov    QWORD PTR [rsp+0x8],r12
    3e2c:	mov    QWORD PTR [rsp+0x10],rbx
    3e31:	jmp    3cbf <botlish_fn_29+0x3f>
    3e36:	mov    rax,r13
    3e39:	mov    rbx,QWORD PTR [rsp+0x30]
    3e3e:	mov    r12,QWORD PTR [rsp+0x38]
    3e43:	mov    r13,QWORD PTR [rsp+0x40]
    3e48:	mov    r14,QWORD PTR [rsp+0x48]
    3e4d:	add    rsp,0x50
    3e51:	mov    rsp,rbp
    3e54:	pop    rbp
    3e55:	ret
    3e56:	add    BYTE PTR [rax],al
    3e58:	(bad)
    3e59:	add    BYTE PTR [rax],al
    3e5b:	add    BYTE PTR [rax],al
    3e5d:	add    BYTE PTR [rax],al
	...

0000000000003e60 <botlish_entry_29: scan_alpha<generic>>:
    3e60:	push   rbp
    3e61:	mov    rbp,rsp
    3e64:	mov    rsi,QWORD PTR [rdx]
    3e67:	mov    r8,QWORD PTR [rdx+0x8]
    3e6b:	mov    rcx,QWORD PTR [rdx+0x10]
    3e6f:	mov    rdx,r8
    3e72:	call   3e77 <botlish_entry_29+0x17>
			3e73: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_alpha<generic>
    3e77:	mov    rsp,rbp
    3e7a:	pop    rbp
    3e7b:	ret
    3e7c:	add    BYTE PTR [rax],al
	...

0000000000003e80 <botlish_fn_30: tld_ok<generic>>:
    3e80:	push   rbp
    3e81:	mov    rbp,rsp
    3e84:	sub    rsp,0x40
    3e88:	mov    QWORD PTR [rsp+0x20],rbx
    3e8d:	mov    QWORD PTR [rsp+0x28],r12
    3e92:	mov    QWORD PTR [rsp+0x30],r13
    3e97:	mov    QWORD PTR [rsp+0x38],r14
    3e9c:	mov    rbx,rdi
    3e9f:	mov    QWORD PTR [rsp],rsi
    3ea3:	mov    r12,rsi
    3ea6:	mov    QWORD PTR [rsp+0x8],rdx
    3eab:	mov    r14,rdx
    3eae:	mov    QWORD PTR [rsp+0x10],rcx
    3eb3:	mov    rdx,r14
    3eb6:	mov    rsi,r12
    3eb9:	mov    rdi,rbx
    3ebc:	call   3ec1 <botlish_fn_30+0x41>
			3ebd: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_alpha<generic>
    3ec1:	mov    rsi,rax
    3ec4:	mov    r13,rax
    3ec7:	test   rax,rsi
    3eca:	je     3f8d <botlish_fn_30+0x10d>
    3ed0:	mov    rax,r13
    3ed3:	mov    QWORD PTR [rsp+0x8],rax
    3ed8:	mov    rdx,r14
    3edb:	and    rax,rdx
    3ede:	test   rax,0x1
    3ee4:	jne    3f0d <botlish_fn_30+0x8d>
    3eea:	mov    rsi,r13
    3eed:	mov    rdi,rbx
    3ef0:	call   3ef5 <botlish_fn_30+0x75>
			3ef1: R_X86_64_PLT32	rt_int_cmp-0x4
    3ef5:	mov    ecx,0x2
    3efa:	test   rax,rax
    3efd:	cmove  rcx,QWORD PTR [rip+0x15b]        # 4060 <botlish_fn_30+0x1e0>
    3f05:	mov    rax,r13
    3f08:	jmp    3f20 <botlish_fn_30+0xa0>
    3f0d:	mov    ecx,0x2
    3f12:	mov    rax,r13
    3f15:	cmp    rax,rdx
    3f18:	cmove  rcx,QWORD PTR [rip+0x140]        # 4060 <botlish_fn_30+0x1e0>
    3f20:	cmp    rcx,0x6
    3f24:	je     3f37 <botlish_fn_30+0xb7>
    3f2a:	mov    ecx,0x2
    3f2f:	mov    rax,rcx
    3f32:	jmp    403f <botlish_fn_30+0x1bf>
    3f37:	mov    ecx,0x1
    3f3c:	mov    rsi,r12
    3f3f:	test   rsi,0x1
    3f46:	jne    3f6c <botlish_fn_30+0xec>
    3f4c:	xor    ecx,ecx
    3f4e:	mov    rsi,r12
    3f51:	test   rsi,0x7
    3f58:	jne    3f6c <botlish_fn_30+0xec>
    3f5e:	mov    rsi,r12
    3f61:	movzx  rcx,BYTE PTR [rsi]
    3f65:	rex cmp cl,0x1
    3f69:	sete   cl
    3f6c:	test   cl,cl
    3f6e:	jne    3fad <botlish_fn_30+0x12d>
    3f74:	mov    rdi,rbx
    3f77:	mov    rsi,QWORD PTR [rdi+0x10]
    3f7b:	mov    rcx,QWORD PTR [rsi+0x140]
    3f82:	xor    rdx,rdx
    3f85:	mov    rsi,r12
    3f88:	call   3f8d <botlish_fn_30+0x10d>
			3f89: R_X86_64_PLT32	rt_type_error-0x4
    3f8d:	xor    rax,rax
    3f90:	mov    rbx,QWORD PTR [rsp+0x20]
    3f95:	mov    r12,QWORD PTR [rsp+0x28]
    3f9a:	mov    r13,QWORD PTR [rsp+0x30]
    3f9f:	mov    r14,QWORD PTR [rsp+0x38]
    3fa4:	add    rsp,0x40
    3fa8:	mov    rsp,rbp
    3fab:	pop    rbp
    3fac:	ret
    3fad:	mov    rsi,r12
    3fb0:	mov    rdi,rax
    3fb3:	and    rdi,rsi
    3fb6:	test   rdi,0x1
    3fbd:	jne    3fce <botlish_fn_30+0x14e>
    3fc3:	mov    rdx,r12
    3fc6:	mov    rsi,rax
    3fc9:	jmp    3ff1 <botlish_fn_30+0x171>
    3fce:	mov    rsi,r12
    3fd1:	mov    r8,rax
    3fd4:	sub    r8,rsi
    3fd7:	mov    r13,rax
    3fda:	seto   r10b
    3fde:	lea    rsi,[r8+0x1]
    3fe2:	test   r10b,r10b
    3fe5:	je     3ffc <botlish_fn_30+0x17c>
    3feb:	mov    rdx,r12
    3fee:	mov    rsi,r13
    3ff1:	mov    rdi,rbx
    3ff4:	call   3ff9 <botlish_fn_30+0x179>
			3ff5: R_X86_64_PLT32	rt_int_sub-0x4
    3ff9:	mov    rsi,rax
    3ffc:	test   rsi,0x1
    4003:	jne    402e <botlish_fn_30+0x1ae>
    4009:	mov    edx,0x5
    400e:	mov    rdi,rbx
    4011:	call   4016 <botlish_fn_30+0x196>
			4012: R_X86_64_PLT32	rt_int_cmp-0x4
    4016:	mov    ecx,0x2
    401b:	test   rax,rax
    401e:	mov    rax,rcx
    4021:	cmovge rax,QWORD PTR [rip+0x37]        # 4060 <botlish_fn_30+0x1e0>
    4029:	jmp    403f <botlish_fn_30+0x1bf>
    402e:	mov    eax,0x2
    4033:	cmp    rsi,0x5
    4037:	cmovge rax,QWORD PTR [rip+0x21]        # 4060 <botlish_fn_30+0x1e0>
    403f:	mov    rbx,QWORD PTR [rsp+0x20]
    4044:	mov    r12,QWORD PTR [rsp+0x28]
    4049:	mov    r13,QWORD PTR [rsp+0x30]
    404e:	mov    r14,QWORD PTR [rsp+0x38]
    4053:	add    rsp,0x40
    4057:	mov    rsp,rbp
    405a:	pop    rbp
    405b:	ret
    405c:	add    BYTE PTR [rax],al
    405e:	add    BYTE PTR [rax],al
    4060:	(bad)
    4061:	add    BYTE PTR [rax],al
    4063:	add    BYTE PTR [rax],al
    4065:	add    BYTE PTR [rax],al
	...

0000000000004068 <botlish_entry_30: tld_ok<generic>>:
    4068:	push   rbp
    4069:	mov    rbp,rsp
    406c:	mov    rsi,QWORD PTR [rdx]
    406f:	mov    r8,QWORD PTR [rdx+0x8]
    4073:	mov    rcx,QWORD PTR [rdx+0x10]
    4077:	mov    rdx,r8
    407a:	call   407f <botlish_entry_30+0x17>
			407b: R_X86_64_PLT32	botlish_fn_30-0x4 ; tld_ok<generic>
    407f:	mov    rsp,rbp
    4082:	pop    rbp
    4083:	ret
    4084:	add    BYTE PTR [rax],al
	...

0000000000004088 <botlish_fn_31: domain_loop<generic>>:
    4088:	push   rbp
    4089:	mov    rbp,rsp
    408c:	sub    rsp,0x70
    4090:	mov    QWORD PTR [rsp+0x40],rbx
    4095:	mov    QWORD PTR [rsp+0x48],r12
    409a:	mov    QWORD PTR [rsp+0x50],r13
    409f:	mov    QWORD PTR [rsp+0x58],r14
    40a4:	mov    QWORD PTR [rsp+0x60],r15
    40a9:	mov    QWORD PTR [rsp+0x18],0x0
    40b2:	mov    QWORD PTR [rsp],rsi
    40b6:	mov    QWORD PTR [rsp+0x8],rdx
    40bb:	mov    QWORD PTR [rsp+0x10],rcx
    40c0:	lea    rbx,[rsp+0x20]
    40c5:	mov    r12,rdi
    40c8:	mov    r13,rcx
    40cb:	mov    r14,rdx
    40ce:	mov    QWORD PTR [rsp+0x30],rsi
    40d3:	mov    rcx,r13
    40d6:	mov    rdx,r14
    40d9:	mov    rsi,QWORD PTR [rsp+0x30]
    40de:	mov    rdi,r12
    40e1:	call   40e6 <botlish_fn_31+0x5e>
			40e2: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_label<generic>
    40e6:	mov    rcx,rax
    40e9:	mov    r15,rax
    40ec:	test   rax,rcx
    40ef:	je     423f <botlish_fn_31+0x1b7>
    40f5:	mov    rax,r15
    40f8:	mov    QWORD PTR [rsp],rax
    40fc:	mov    rdx,QWORD PTR [rsp+0x30]
    4101:	and    rax,rdx
    4104:	test   rax,0x1
    410a:	jne    4129 <botlish_fn_31+0xa1>
    4110:	mov    rsi,r15
    4113:	mov    rdi,r12
    4116:	call   411b <botlish_fn_31+0x93>
			4117: R_X86_64_PLT32	rt_value_eq-0x4
    411b:	test   rax,rax
    411e:	je     423f <botlish_fn_31+0x1b7>
    4124:	jmp    4139 <botlish_fn_31+0xb1>
    4129:	mov    eax,0x2
    412e:	cmp    r15,rdx
    4131:	cmove  rax,QWORD PTR [rip+0x187]        # 42c0 <botlish_fn_31+0x238>
    4139:	cmp    rax,0x6
    413d:	je     4295 <botlish_fn_31+0x20d>
    4143:	mov    rax,r15
    4146:	and    rax,r14
    4149:	test   rax,0x1
    414f:	jne    4178 <botlish_fn_31+0xf0>
    4155:	mov    rdx,r14
    4158:	mov    rsi,r15
    415b:	mov    rdi,r12
    415e:	call   4163 <botlish_fn_31+0xdb>
			415f: R_X86_64_PLT32	rt_int_cmp-0x4
    4163:	mov    ecx,0x2
    4168:	test   rax,rax
    416b:	cmovge rcx,QWORD PTR [rip+0x14d]        # 42c0 <botlish_fn_31+0x238>
    4173:	jmp    4188 <botlish_fn_31+0x100>
    4178:	mov    ecx,0x2
    417d:	cmp    r15,r14
    4180:	cmovge rcx,QWORD PTR [rip+0x138]        # 42c0 <botlish_fn_31+0x238>
    4188:	cmp    rcx,0x6
    418c:	je     4286 <botlish_fn_31+0x1fe>
    4192:	mov    rcx,rbx
    4195:	mov    rdx,r13
    4198:	mov    rsi,r15
    419b:	mov    rdi,r12
    419e:	call   41a3 <botlish_fn_31+0x11b>
			419f: R_X86_64_PLT32	botlish_fn_26-0x4 ; char_at<generic>
    41a3:	test   rax,rax
    41a6:	je     423f <botlish_fn_31+0x1b7>
    41ac:	mov    rdx,QWORD PTR [rsp+0x20]
    41b1:	mov    rcx,QWORD PTR [rsp+0x28]
    41b6:	mov    rsi,QWORD PTR [r12+0x10]
    41bb:	mov    r8,QWORD PTR [rsi+0x130]
    41c2:	mov    rsi,rax
    41c5:	mov    rdi,r12
    41c8:	call   41cd <botlish_fn_31+0x145>
			41c9: R_X86_64_PLT32	rt_str_region_eq-0x4
    41cd:	cmp    rax,0x6
    41d1:	je     41e3 <botlish_fn_31+0x15b>
    41d7:	mov    r14,0xffffffffffffffff
    41de:	jmp    428d <botlish_fn_31+0x205>
    41e3:	mov    QWORD PTR [rsp+0x18],0x3
    41ec:	test   r15,0x1
    41f3:	je     420b <botlish_fn_31+0x183>
    41f9:	mov    rdx,r15
    41fc:	add    rdx,0x2
    4200:	seto   al
    4203:	test   al,al
    4205:	je     421e <botlish_fn_31+0x196>
    420b:	mov    edx,0x3
    4210:	mov    rsi,r15
    4213:	mov    rdi,r12
    4216:	call   421b <botlish_fn_31+0x193>
			4217: R_X86_64_PLT32	rt_int_add-0x4
    421b:	mov    rdx,rax
    421e:	mov    QWORD PTR [rsp],rdx
    4222:	mov    r15,rdx
    4225:	mov    rcx,r13
    4228:	mov    rdx,r14
    422b:	mov    rsi,r15
    422e:	mov    rdi,r12
    4231:	call   4236 <botlish_fn_31+0x1ae>
			4232: R_X86_64_PLT32	botlish_fn_30-0x4 ; tld_ok<generic>
    4236:	test   rax,rax
    4239:	jne    4264 <botlish_fn_31+0x1dc>
    423f:	xor    rax,rax
    4242:	mov    rbx,QWORD PTR [rsp+0x40]
    4247:	mov    r12,QWORD PTR [rsp+0x48]
    424c:	mov    r13,QWORD PTR [rsp+0x50]
    4251:	mov    r14,QWORD PTR [rsp+0x58]
    4256:	mov    r15,QWORD PTR [rsp+0x60]
    425b:	add    rsp,0x70
    425f:	mov    rsp,rbp
    4262:	pop    rbp
    4263:	ret
    4264:	cmp    rax,0x6
    4268:	je     428d <botlish_fn_31+0x205>
    426e:	mov    QWORD PTR [rsp],r15
    4272:	mov    QWORD PTR [rsp+0x8],r14
    4277:	mov    QWORD PTR [rsp+0x10],r13
    427c:	mov    QWORD PTR [rsp+0x30],r15
    4281:	jmp    40d3 <botlish_fn_31+0x4b>
    4286:	mov    r14,0xffffffffffffffff
    428d:	mov    rax,r14
    4290:	jmp    429c <botlish_fn_31+0x214>
    4295:	mov    rax,0xffffffffffffffff
    429c:	mov    rbx,QWORD PTR [rsp+0x40]
    42a1:	mov    r12,QWORD PTR [rsp+0x48]
    42a6:	mov    r13,QWORD PTR [rsp+0x50]
    42ab:	mov    r14,QWORD PTR [rsp+0x58]
    42b0:	mov    r15,QWORD PTR [rsp+0x60]
    42b5:	add    rsp,0x70
    42b9:	mov    rsp,rbp
    42bc:	pop    rbp
    42bd:	ret
    42be:	add    BYTE PTR [rax],al
    42c0:	(bad)
    42c1:	add    BYTE PTR [rax],al
    42c3:	add    BYTE PTR [rax],al
    42c5:	add    BYTE PTR [rax],al
	...

00000000000042c8 <botlish_entry_31: domain_loop<generic>>:
    42c8:	push   rbp
    42c9:	mov    rbp,rsp
    42cc:	mov    rsi,QWORD PTR [rdx]
    42cf:	mov    r8,QWORD PTR [rdx+0x8]
    42d3:	mov    rcx,QWORD PTR [rdx+0x10]
    42d7:	mov    rdx,r8
    42da:	call   42df <botlish_entry_31+0x17>
			42db: R_X86_64_PLT32	botlish_fn_31-0x4 ; domain_loop<generic>
    42df:	mov    rsp,rbp
    42e2:	pop    rbp
    42e3:	ret

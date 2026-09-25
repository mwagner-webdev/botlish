; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 19043  (per function: 1813 39 337 425 625 377 385 385 164 164 199 125 214 484 864 647 1004 504 681 769 450 884 644 540 540 636 681 769 450 884 644 540 540 636)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> char::codepoint<UnicodeChar>
;   botlish_fn_2 / botlish_entry_2 -> byte::from_int<int>
;   botlish_fn_3 / botlish_entry_3 -> byte::from_int<generic>
;   botlish_fn_4 / botlish_entry_4 -> byte::set<List[UnicodeChar]>
;   botlish_fn_5 / botlish_entry_5 -> ascii::is_digit<generic>
;   botlish_fn_6 / botlish_entry_6 -> ascii::is_upper<generic>
;   botlish_fn_7 / botlish_entry_7 -> ascii::is_lower<generic>
;   botlish_fn_8 / botlish_entry_8 -> ascii::is_alphabetic<generic>
;   botlish_fn_9 / botlish_entry_9 -> ascii::is_alphanumeric<generic>
;   botlish_fn_10 / botlish_entry_10 -> web::is_unreserved<generic>
;   botlish_fn_11 / botlish_entry_11 -> web::uri_escape_text<generic>
;   botlish_fn_12 / botlish_entry_12 -> high_nibble<generic>
;   botlish_fn_13 / botlish_entry_13 -> hex_pair<generic>
;   botlish_fn_14 / botlish_entry_14 -> esc_bytes<generic>
;   botlish_fn_15 / botlish_entry_15 -> esc_char<generic>
;   botlish_fn_16 / botlish_entry_16 -> esc_from<generic>
;   botlish_fn_17 / botlish_entry_17 -> check<int, int, str, str>
;   botlish_fn_18 / botlish_entry_18 -> <str>
;   botlish_fn_19 / botlish_entry_19 -> <generic>
;   botlish_fn_20 / botlish_entry_20 -> char_at<generic>
;   botlish_fn_21 / botlish_entry_21 -> scan_local<generic>
;   botlish_fn_22 / botlish_entry_22 -> scan_label<generic>
;   botlish_fn_23 / botlish_entry_23 -> scan_alpha<generic>
;   botlish_fn_24 / botlish_entry_24 -> tld_ok<generic>
;   botlish_fn_25 / botlish_entry_25 -> domain_loop<generic>
;   botlish_fn_26 / botlish_entry_26 -> <str>
;   botlish_fn_27 / botlish_entry_27 -> <generic>
;   botlish_fn_28 / botlish_entry_28 -> char_at<generic>
;   botlish_fn_29 / botlish_entry_29 -> scan_local<generic>
;   botlish_fn_30 / botlish_entry_30 -> scan_label<generic>
;   botlish_fn_31 / botlish_entry_31 -> scan_alpha<generic>
;   botlish_fn_32 / botlish_entry_32 -> tld_ok<generic>
;   botlish_fn_33 / botlish_entry_33 -> domain_loop<generic>


refined-checks.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x1b0
       b:	mov    QWORD PTR [rsp+0x180],rbx
      13:	mov    QWORD PTR [rsp+0x188],r12
      1b:	mov    QWORD PTR [rsp+0x190],r13
      23:	mov    QWORD PTR [rsp+0x198],r14
      2b:	mov    QWORD PTR [rsp+0x1a0],r15
      33:	mov    rax,QWORD PTR [rdi+0x10]
      37:	mov    rcx,QWORD PTR [rax]
      3a:	mov    QWORD PTR [rsp],rcx
      3e:	mov    QWORD PTR [rsp+0x178],rcx
      46:	mov    rax,QWORD PTR [rdi+0x10]
      4a:	mov    rdx,QWORD PTR [rax+0x8]
      4e:	mov    QWORD PTR [rsp+0x8],rdx
      53:	mov    QWORD PTR [rsp+0x170],rdx
      5b:	mov    rax,QWORD PTR [rdi+0x10]
      5f:	mov    rsi,QWORD PTR [rax+0x10]
      63:	mov    QWORD PTR [rsp+0x10],rsi
      68:	mov    QWORD PTR [rsp+0x168],rsi
      70:	mov    rax,QWORD PTR [rdi+0x10]
      74:	mov    r8,QWORD PTR [rax+0x18]
      78:	mov    QWORD PTR [rsp+0x18],r8
      7d:	mov    QWORD PTR [rsp+0x160],r8
      85:	mov    rax,QWORD PTR [rdi+0x10]
      89:	mov    r8,QWORD PTR [rax+0x20]
      8d:	mov    QWORD PTR [rsp+0x20],r8
      92:	mov    rax,QWORD PTR [rdi+0x10]
      96:	mov    r9,QWORD PTR [rax+0x28]
      9a:	mov    QWORD PTR [rsp+0x28],r9
      9f:	mov    rax,QWORD PTR [rdi+0x10]
      a3:	mov    r10,QWORD PTR [rax+0x30]
      a7:	mov    QWORD PTR [rsp+0x30],r10
      ac:	mov    rax,QWORD PTR [rdi+0x10]
      b0:	mov    r11,QWORD PTR [rax+0x38]
      b4:	mov    QWORD PTR [rsp+0x38],r11
      b9:	mov    rax,QWORD PTR [rdi+0x10]
      bd:	mov    rbx,QWORD PTR [rax+0x40]
      c1:	mov    QWORD PTR [rsp+0x40],rbx
      c6:	mov    rax,QWORD PTR [rdi+0x10]
      ca:	mov    r12,QWORD PTR [rax+0x48]
      ce:	mov    QWORD PTR [rsp+0x48],r12
      d3:	mov    rax,QWORD PTR [rdi+0x10]
      d7:	mov    r13,QWORD PTR [rax+0x50]
      db:	mov    QWORD PTR [rsp+0x50],r13
      e0:	mov    rax,QWORD PTR [rdi+0x10]
      e4:	mov    r14,QWORD PTR [rax+0x58]
      e8:	mov    QWORD PTR [rsp+0x58],r14
      ed:	mov    rax,QWORD PTR [rdi+0x10]
      f1:	mov    r15,QWORD PTR [rax+0x60]
      f5:	mov    QWORD PTR [rsp+0x60],r15
      fa:	mov    rax,QWORD PTR [rdi+0x10]
      fe:	mov    rax,QWORD PTR [rax+0x68]
     102:	mov    QWORD PTR [rsp+0x68],rax
     107:	mov    rcx,QWORD PTR [rdi+0x10]
     10b:	mov    rcx,QWORD PTR [rcx+0x70]
     10f:	mov    QWORD PTR [rsp+0x70],rcx
     114:	mov    rdx,QWORD PTR [rdi+0x10]
     118:	mov    QWORD PTR [rsp+0x158],rdi
     120:	mov    rdi,QWORD PTR [rdx+0x78]
     124:	mov    QWORD PTR [rsp+0x78],rdi
     129:	lea    rdx,[rsp+0x80]
     131:	mov    rsi,QWORD PTR [rsp+0x178]
     139:	mov    QWORD PTR [rsp+0x80],rsi
     141:	mov    rsi,QWORD PTR [rsp+0x170]
     149:	mov    QWORD PTR [rsp+0x88],rsi
     151:	mov    rsi,QWORD PTR [rsp+0x168]
     159:	mov    QWORD PTR [rsp+0x90],rsi
     161:	mov    rsi,QWORD PTR [rsp+0x160]
     169:	mov    QWORD PTR [rsp+0x98],rsi
     171:	mov    QWORD PTR [rsp+0xa0],r8
     179:	mov    QWORD PTR [rsp+0xa8],r9
     181:	mov    QWORD PTR [rsp+0xb0],r10
     189:	mov    QWORD PTR [rsp+0xb8],r11
     191:	mov    QWORD PTR [rsp+0xc0],rbx
     199:	mov    QWORD PTR [rsp+0xc8],r12
     1a1:	mov    QWORD PTR [rsp+0xd0],r13
     1a9:	mov    QWORD PTR [rsp+0xd8],r14
     1b1:	mov    QWORD PTR [rsp+0xe0],r15
     1b9:	mov    QWORD PTR [rsp+0xe8],rax
     1c1:	mov    QWORD PTR [rsp+0xf0],rcx
     1c9:	mov    QWORD PTR [rsp+0xf8],rdi
     1d1:	mov    esi,0x10
     1d6:	mov    rdi,QWORD PTR [rsp+0x158]
     1de:	call   1e3 <botlish_fn_0+0x1e3>
			1df: R_X86_64_PLT32	rt_list_new-0x4
     1e3:	test   rax,rax
     1e6:	je     601 <botlish_fn_0+0x601>
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
     254:	mov    rdi,QWORD PTR [rsp+0x158]
     25c:	call   261 <botlish_fn_0+0x261>
			25d: R_X86_64_PLT32	rt_list_new-0x4
     261:	test   rax,rax
     264:	je     288 <botlish_fn_0+0x288>
     26a:	mov    QWORD PTR [rsp+0x8],rax
     26f:	mov    rsi,rax
     272:	mov    rdi,QWORD PTR [rsp+0x158]
     27a:	call   27f <botlish_fn_0+0x27f>
			27b: R_X86_64_PLT32	botlish_fn_4-0x4 ; byte::set<List[UnicodeChar]>
     27f:	test   rax,rax
     282:	jne    492 <botlish_fn_0+0x492>
     288:	mov    rdi,QWORD PTR [rsp+0x158]
     290:	call   295 <botlish_fn_0+0x295>
			291: R_X86_64_PLT32	rt_declared_error-0x4
     295:	cmp    rax,0x1
     299:	je     3a4 <botlish_fn_0+0x3a4>
     29f:	mov    rdi,QWORD PTR [rsp+0x158]
     2a7:	call   2ac <botlish_fn_0+0x2ac>
			2a8: R_X86_64_PLT32	rt_declared_error-0x4
     2ac:	cmp    rax,0x2
     2b0:	jne    601 <botlish_fn_0+0x601>
     2b6:	mov    rdi,QWORD PTR [rsp+0x158]
     2be:	call   2c3 <botlish_fn_0+0x2c3>
			2bf: R_X86_64_PLT32	rt_clear_declared_error-0x4
     2c3:	mov    esi,0x1
     2c8:	mov    rdi,QWORD PTR [rsp+0x158]
     2d0:	call   2d5 <botlish_fn_0+0x2d5>
			2d1: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     2d5:	test   rax,rax
     2d8:	jne    34c <botlish_fn_0+0x34c>
     2de:	mov    rdi,QWORD PTR [rsp+0x158]
     2e6:	call   2eb <botlish_fn_0+0x2eb>
			2e7: R_X86_64_PLT32	rt_declared_error-0x4
     2eb:	cmp    rax,0x1
     2ef:	je     32c <botlish_fn_0+0x32c>
     2f5:	mov    rdi,QWORD PTR [rsp+0x158]
     2fd:	call   302 <botlish_fn_0+0x302>
			2fe: R_X86_64_PLT32	rt_declared_error-0x4
     302:	cmp    rax,0x2
     306:	jne    601 <botlish_fn_0+0x601>
     30c:	mov    rdi,QWORD PTR [rsp+0x158]
     314:	call   319 <botlish_fn_0+0x319>
			315: R_X86_64_PLT32	rt_clear_declared_error-0x4
     319:	mov    eax,0x1
     31e:	mov    QWORD PTR [rsp+0x8],0x1
     327:	jmp    351 <botlish_fn_0+0x351>
     32c:	mov    rdi,QWORD PTR [rsp+0x158]
     334:	call   339 <botlish_fn_0+0x339>
			335: R_X86_64_PLT32	rt_clear_declared_error-0x4
     339:	mov    eax,0x1
     33e:	mov    QWORD PTR [rsp+0x8],0x1
     347:	jmp    351 <botlish_fn_0+0x351>
     34c:	mov    QWORD PTR [rsp+0x8],rax
     351:	lea    rdx,[rsp+0x128]
     359:	mov    QWORD PTR [rsp+0x128],rax
     361:	mov    esi,0x1
     366:	mov    rdi,QWORD PTR [rsp+0x158]
     36e:	call   373 <botlish_fn_0+0x373>
			36f: R_X86_64_PLT32	rt_list_new-0x4
     373:	test   rax,rax
     376:	je     601 <botlish_fn_0+0x601>
     37c:	mov    QWORD PTR [rsp+0x8],rax
     381:	mov    rsi,rax
     384:	mov    rdi,QWORD PTR [rsp+0x158]
     38c:	call   391 <botlish_fn_0+0x391>
			38d: R_X86_64_PLT32	rt_set_from_list-0x4
     391:	test   rax,rax
     394:	je     601 <botlish_fn_0+0x601>
     39a:	mov    QWORD PTR [rsp+0x8],rax
     39f:	jmp    497 <botlish_fn_0+0x497>
     3a4:	mov    rdi,QWORD PTR [rsp+0x158]
     3ac:	call   3b1 <botlish_fn_0+0x3b1>
			3ad: R_X86_64_PLT32	rt_clear_declared_error-0x4
     3b1:	mov    esi,0x1
     3b6:	mov    rdi,QWORD PTR [rsp+0x158]
     3be:	call   3c3 <botlish_fn_0+0x3c3>
			3bf: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     3c3:	test   rax,rax
     3c6:	jne    43a <botlish_fn_0+0x43a>
     3cc:	mov    rdi,QWORD PTR [rsp+0x158]
     3d4:	call   3d9 <botlish_fn_0+0x3d9>
			3d5: R_X86_64_PLT32	rt_declared_error-0x4
     3d9:	cmp    rax,0x1
     3dd:	je     41a <botlish_fn_0+0x41a>
     3e3:	mov    rdi,QWORD PTR [rsp+0x158]
     3eb:	call   3f0 <botlish_fn_0+0x3f0>
			3ec: R_X86_64_PLT32	rt_declared_error-0x4
     3f0:	cmp    rax,0x2
     3f4:	jne    601 <botlish_fn_0+0x601>
     3fa:	mov    rdi,QWORD PTR [rsp+0x158]
     402:	call   407 <botlish_fn_0+0x407>
			403: R_X86_64_PLT32	rt_clear_declared_error-0x4
     407:	mov    eax,0x1
     40c:	mov    QWORD PTR [rsp+0x8],0x1
     415:	jmp    43f <botlish_fn_0+0x43f>
     41a:	mov    rdi,QWORD PTR [rsp+0x158]
     422:	call   427 <botlish_fn_0+0x427>
			423: R_X86_64_PLT32	rt_clear_declared_error-0x4
     427:	mov    eax,0x1
     42c:	mov    QWORD PTR [rsp+0x8],0x1
     435:	jmp    43f <botlish_fn_0+0x43f>
     43a:	mov    QWORD PTR [rsp+0x8],rax
     43f:	lea    rdx,[rsp+0x120]
     447:	mov    QWORD PTR [rsp+0x120],rax
     44f:	mov    esi,0x1
     454:	mov    rdi,QWORD PTR [rsp+0x158]
     45c:	call   461 <botlish_fn_0+0x461>
			45d: R_X86_64_PLT32	rt_list_new-0x4
     461:	test   rax,rax
     464:	je     601 <botlish_fn_0+0x601>
     46a:	mov    QWORD PTR [rsp+0x8],rax
     46f:	mov    rsi,rax
     472:	mov    rdi,QWORD PTR [rsp+0x158]
     47a:	call   47f <botlish_fn_0+0x47f>
			47b: R_X86_64_PLT32	rt_set_from_list-0x4
     47f:	test   rax,rax
     482:	je     601 <botlish_fn_0+0x601>
     488:	mov    QWORD PTR [rsp+0x8],rax
     48d:	jmp    497 <botlish_fn_0+0x497>
     492:	mov    QWORD PTR [rsp+0x8],rax
     497:	lea    r8,[rsp+0x130]
     49f:	mov    QWORD PTR [rsp+0x130],rax
     4a7:	mov    esi,0xa
     4ac:	mov    rdx,QWORD PTR [rip+0x0]        # 4b3 <botlish_fn_0+0x4b3>
			4af: R_X86_64_GOTPCREL	botlish_entry_10-0x4 ; web::is_unreserved<generic>
     4b3:	mov    r13d,0x1
     4b9:	mov    rcx,r13
     4bc:	mov    rdi,QWORD PTR [rsp+0x158]
     4c4:	call   4c9 <botlish_fn_0+0x4c9>
			4c5: R_X86_64_PLT32	rt_closure_new-0x4
     4c9:	mov    QWORD PTR [rsp+0x8],rax
     4ce:	lea    r8,[rsp+0x138]
     4d6:	mov    rcx,rbx
     4d9:	mov    QWORD PTR [rsp+0x138],rcx
     4e1:	mov    QWORD PTR [rsp+0x140],rax
     4e9:	mov    esi,0xb
     4ee:	mov    rdx,QWORD PTR [rip+0x0]        # 4f5 <botlish_fn_0+0x4f5>
			4f1: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; web::uri_escape_text<generic>
     4f5:	mov    ebx,0x2
     4fa:	mov    rcx,rbx
     4fd:	mov    rdi,QWORD PTR [rsp+0x158]
     505:	call   50a <botlish_fn_0+0x50a>
			506: R_X86_64_PLT32	rt_closure_new-0x4
     50a:	mov    QWORD PTR [rsp],rax
     50e:	mov    rdi,QWORD PTR [rsp+0x158]
     516:	mov    rcx,QWORD PTR [rdi+0x10]
     51a:	mov    rdx,QWORD PTR [rcx+0x80]
     521:	mov    QWORD PTR [rsp+0x8],rdx
     526:	mov    rsi,rax
     529:	call   52e <botlish_fn_0+0x52e>
			52a: R_X86_64_PLT32	botlish_fn_11-0x4 ; web::uri_escape_text<generic>
     52e:	test   rax,rax
     531:	je     601 <botlish_fn_0+0x601>
     537:	mov    QWORD PTR [rsp],rax
     53b:	mov    r14,rax
     53e:	mov    esi,0x321
     543:	mov    QWORD PTR [rsp+0x8],0x321
     54c:	mov    QWORD PTR [rsp+0x10],0x1
     555:	mov    rdi,QWORD PTR [rsp+0x158]
     55d:	mov    rcx,QWORD PTR [rdi+0x10]
     561:	mov    rcx,QWORD PTR [rcx+0x88]
     568:	mov    QWORD PTR [rsp+0x18],rcx
     56d:	mov    rdx,r13
     570:	mov    r8,r14
     573:	call   578 <botlish_fn_0+0x578>
			574: R_X86_64_PLT32	botlish_fn_17-0x4 ; check<int, int, str, str>
     578:	mov    r12,rax
     57b:	test   r12,r12
     57e:	je     601 <botlish_fn_0+0x601>
     584:	mov    QWORD PTR [rsp+0x8],r12
     589:	mov    esi,0x321
     58e:	mov    QWORD PTR [rsp+0x10],0x321
     597:	mov    QWORD PTR [rsp+0x18],0x1
     5a0:	mov    rdi,QWORD PTR [rsp+0x158]
     5a8:	mov    rax,QWORD PTR [rdi+0x10]
     5ac:	mov    rcx,QWORD PTR [rax+0x90]
     5b3:	mov    QWORD PTR [rsp+0x20],rcx
     5b8:	mov    rdx,r13
     5bb:	mov    r8,r14
     5be:	call   5c3 <botlish_fn_0+0x5c3>
			5bf: R_X86_64_PLT32	botlish_fn_17-0x4 ; check<int, int, str, str>
     5c3:	test   rax,rax
     5c6:	je     601 <botlish_fn_0+0x601>
     5cc:	mov    QWORD PTR [rsp],rax
     5d0:	lea    rdx,[rsp+0x148]
     5d8:	mov    QWORD PTR [rsp+0x148],r12
     5e0:	mov    QWORD PTR [rsp+0x150],rax
     5e8:	mov    rsi,rbx
     5eb:	mov    rdi,QWORD PTR [rsp+0x158]
     5f3:	call   5f8 <botlish_fn_0+0x5f8>
			5f4: R_X86_64_PLT32	rt_list_new-0x4
     5f8:	test   rax,rax
     5fb:	jne    638 <botlish_fn_0+0x638>
     601:	xor    rax,rax
     604:	mov    rbx,QWORD PTR [rsp+0x180]
     60c:	mov    r12,QWORD PTR [rsp+0x188]
     614:	mov    r13,QWORD PTR [rsp+0x190]
     61c:	mov    r14,QWORD PTR [rsp+0x198]
     624:	mov    r15,QWORD PTR [rsp+0x1a0]
     62c:	add    rsp,0x1b0
     633:	mov    rsp,rbp
     636:	pop    rbp
     637:	ret
     638:	mov    rbx,QWORD PTR [rsp+0x180]
     640:	mov    r12,QWORD PTR [rsp+0x188]
     648:	mov    r13,QWORD PTR [rsp+0x190]
     650:	mov    r14,QWORD PTR [rsp+0x198]
     658:	mov    r15,QWORD PTR [rsp+0x1a0]
     660:	add    rsp,0x1b0
     667:	mov    rsp,rbp
     66a:	pop    rbp
     66b:	ret

000000000000066c <botlish_entry_0: <program entry>>:
     66c:	push   rbp
     66d:	mov    rbp,rsp
     670:	call   675 <botlish_entry_0+0x9>
			671: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     675:	mov    rsp,rbp
     678:	pop    rbp
     679:	ret

000000000000067a <botlish_fn_1: char::codepoint<UnicodeChar>>:
     67a:	push   rbp
     67b:	mov    rbp,rsp
     67e:	call   683 <botlish_fn_1+0x9>
			67f: R_X86_64_PLT32	rt_char_codepoint-0x4
     683:	mov    rsp,rbp
     686:	pop    rbp
     687:	ret

0000000000000688 <botlish_entry_1: char::codepoint<UnicodeChar>>:
     688:	push   rbp
     689:	mov    rbp,rsp
     68c:	mov    rsi,QWORD PTR [rdx]
     68f:	call   694 <botlish_entry_1+0xc>
			690: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     694:	mov    rsp,rbp
     697:	pop    rbp
     698:	ret
     699:	add    BYTE PTR [rax],al
     69b:	add    BYTE PTR [rax],al
     69d:	add    BYTE PTR [rax],al
	...

00000000000006a0 <botlish_fn_2: byte::from_int<int>>:
     6a0:	push   rbp
     6a1:	mov    rbp,rsp
     6a4:	sub    rsp,0x10
     6a8:	mov    QWORD PTR [rsp],rbx
     6ac:	mov    QWORD PTR [rsp+0x8],r12
     6b1:	mov    r12,rdi
     6b4:	test   rsi,0x1
     6bb:	mov    rax,rsi
     6be:	jne    6ed <botlish_fn_2+0x4d>
     6c4:	mov    edx,0x1
     6c9:	mov    rbx,rax
     6cc:	mov    rsi,rbx
     6cf:	mov    rdi,r12
     6d2:	call   6d7 <botlish_fn_2+0x37>
			6d3: R_X86_64_PLT32	rt_int_cmp-0x4
     6d7:	mov    r8d,0x2
     6dd:	test   rax,rax
     6e0:	cmovl  r8,QWORD PTR [rip+0xd8]        # 7c0 <botlish_fn_2+0x120>
     6e8:	jmp    701 <botlish_fn_2+0x61>
     6ed:	mov    rbx,rax
     6f0:	mov    r8d,0x2
     6f6:	test   rbx,rbx
     6f9:	cmovle r8,QWORD PTR [rip+0xbf]        # 7c0 <botlish_fn_2+0x120>
     701:	cmp    r8,0x6
     705:	je     78d <botlish_fn_2+0xed>
     70b:	test   rbx,0x1
     712:	jne    73d <botlish_fn_2+0x9d>
     718:	mov    edx,0x1ff
     71d:	mov    rsi,rbx
     720:	mov    rdi,r12
     723:	call   728 <botlish_fn_2+0x88>
			724: R_X86_64_PLT32	rt_int_cmp-0x4
     728:	mov    ecx,0x2
     72d:	test   rax,rax
     730:	cmovg  rcx,QWORD PTR [rip+0x88]        # 7c0 <botlish_fn_2+0x120>
     738:	jmp    751 <botlish_fn_2+0xb1>
     73d:	mov    ecx,0x2
     742:	cmp    rbx,0x1ff
     749:	cmovg  rcx,QWORD PTR [rip+0x6f]        # 7c0 <botlish_fn_2+0x120>
     751:	cmp    rcx,0x6
     755:	je     770 <botlish_fn_2+0xd0>
     75b:	mov    rax,rbx
     75e:	mov    rbx,QWORD PTR [rsp]
     762:	mov    r12,QWORD PTR [rsp+0x8]
     767:	add    rsp,0x10
     76b:	mov    rsp,rbp
     76e:	pop    rbp
     76f:	ret
     770:	mov    rdi,r12
     773:	mov    rax,QWORD PTR [rdi+0x10]
     777:	mov    rdx,QWORD PTR [rax+0xa0]
     77e:	mov    esi,0x2
     783:	call   788 <botlish_fn_2+0xe8>
			784: R_X86_64_PLT32	rt_fail_declared-0x4
     788:	jmp    7a5 <botlish_fn_2+0x105>
     78d:	mov    rdi,r12
     790:	mov    rax,QWORD PTR [rdi+0x10]
     794:	mov    rdx,QWORD PTR [rax+0x98]
     79b:	mov    esi,0x1
     7a0:	call   7a5 <botlish_fn_2+0x105>
			7a1: R_X86_64_PLT32	rt_fail_declared-0x4
     7a5:	xor    rax,rax
     7a8:	mov    rbx,QWORD PTR [rsp]
     7ac:	mov    r12,QWORD PTR [rsp+0x8]
     7b1:	add    rsp,0x10
     7b5:	mov    rsp,rbp
     7b8:	pop    rbp
     7b9:	ret
     7ba:	add    BYTE PTR [rax],al
     7bc:	add    BYTE PTR [rax],al
     7be:	add    BYTE PTR [rax],al
     7c0:	(bad)
     7c1:	add    BYTE PTR [rax],al
     7c3:	add    BYTE PTR [rax],al
     7c5:	add    BYTE PTR [rax],al
	...

00000000000007c8 <botlish_entry_2: byte::from_int<int>>:
     7c8:	push   rbp
     7c9:	mov    rbp,rsp
     7cc:	mov    rsi,QWORD PTR [rdx]
     7cf:	call   7d4 <botlish_entry_2+0xc>
			7d0: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     7d4:	mov    rsp,rbp
     7d7:	pop    rbp
     7d8:	ret
     7d9:	add    BYTE PTR [rax],al
     7db:	add    BYTE PTR [rax],al
     7dd:	add    BYTE PTR [rax],al
	...

00000000000007e0 <botlish_fn_3: byte::from_int<generic>>:
     7e0:	push   rbp
     7e1:	mov    rbp,rsp
     7e4:	sub    rsp,0x10
     7e8:	mov    QWORD PTR [rsp],rbx
     7ec:	mov    QWORD PTR [rsp+0x8],r12
     7f1:	mov    r8d,0x1
     7f7:	test   rsi,0x1
     7fe:	jne    81e <botlish_fn_3+0x3e>
     804:	xor    r8d,r8d
     807:	test   rsi,0x7
     80e:	jne    81e <botlish_fn_3+0x3e>
     814:	movzx  rax,BYTE PTR [rsi]
     818:	cmp    al,0x1
     81a:	sete   r8b
     81e:	test   r8b,r8b
     821:	jne    83f <botlish_fn_3+0x5f>
     827:	mov    rax,QWORD PTR [rdi+0x10]
     82b:	mov    rcx,QWORD PTR [rax+0xa8]
     832:	xor    rdx,rdx
     835:	call   83a <botlish_fn_3+0x5a>
			836: R_X86_64_PLT32	rt_type_error-0x4
     83a:	jmp    934 <botlish_fn_3+0x154>
     83f:	mov    rbx,rdi
     842:	test   rsi,0x1
     849:	mov    rax,rsi
     84c:	jne    87a <botlish_fn_3+0x9a>
     852:	mov    edx,0x1
     857:	mov    r12,rax
     85a:	mov    rsi,r12
     85d:	mov    rdi,rbx
     860:	call   865 <botlish_fn_3+0x85>
			861: R_X86_64_PLT32	rt_int_cmp-0x4
     865:	mov    ecx,0x2
     86a:	test   rax,rax
     86d:	cmovl  rcx,QWORD PTR [rip+0xdb]        # 950 <botlish_fn_3+0x170>
     875:	jmp    88d <botlish_fn_3+0xad>
     87a:	mov    r12,rax
     87d:	mov    ecx,0x2
     882:	test   r12,r12
     885:	cmovle rcx,QWORD PTR [rip+0xc3]        # 950 <botlish_fn_3+0x170>
     88d:	cmp    rcx,0x6
     891:	je     91c <botlish_fn_3+0x13c>
     897:	test   r12,0x1
     89e:	jne    8cc <botlish_fn_3+0xec>
     8a4:	mov    edx,0x1ff
     8a9:	mov    rsi,r12
     8ac:	mov    rdi,rbx
     8af:	call   8b4 <botlish_fn_3+0xd4>
			8b0: R_X86_64_PLT32	rt_int_cmp-0x4
     8b4:	mov    ecx,0x2
     8b9:	test   rax,rax
     8bc:	cmovg  rcx,QWORD PTR [rip+0x8c]        # 950 <botlish_fn_3+0x170>
     8c4:	mov    rax,r12
     8c7:	jmp    8e3 <botlish_fn_3+0x103>
     8cc:	mov    ecx,0x2
     8d1:	cmp    r12,0x1ff
     8d8:	mov    rax,r12
     8db:	cmovg  rcx,QWORD PTR [rip+0x6d]        # 950 <botlish_fn_3+0x170>
     8e3:	cmp    rcx,0x6
     8e7:	je     8ff <botlish_fn_3+0x11f>
     8ed:	mov    rbx,QWORD PTR [rsp]
     8f1:	mov    r12,QWORD PTR [rsp+0x8]
     8f6:	add    rsp,0x10
     8fa:	mov    rsp,rbp
     8fd:	pop    rbp
     8fe:	ret
     8ff:	mov    rdi,rbx
     902:	mov    rsi,QWORD PTR [rdi+0x10]
     906:	mov    rdx,QWORD PTR [rsi+0xa0]
     90d:	mov    esi,0x2
     912:	call   917 <botlish_fn_3+0x137>
			913: R_X86_64_PLT32	rt_fail_declared-0x4
     917:	jmp    934 <botlish_fn_3+0x154>
     91c:	mov    rdi,rbx
     91f:	mov    rsi,QWORD PTR [rdi+0x10]
     923:	mov    rdx,QWORD PTR [rsi+0x98]
     92a:	mov    esi,0x1
     92f:	call   934 <botlish_fn_3+0x154>
			930: R_X86_64_PLT32	rt_fail_declared-0x4
     934:	xor    rax,rax
     937:	mov    rbx,QWORD PTR [rsp]
     93b:	mov    r12,QWORD PTR [rsp+0x8]
     940:	add    rsp,0x10
     944:	mov    rsp,rbp
     947:	pop    rbp
     948:	ret
     949:	add    BYTE PTR [rax],al
     94b:	add    BYTE PTR [rax],al
     94d:	add    BYTE PTR [rax],al
     94f:	add    BYTE PTR [rsi],al
     951:	add    BYTE PTR [rax],al
     953:	add    BYTE PTR [rax],al
     955:	add    BYTE PTR [rax],al
	...

0000000000000958 <botlish_entry_3: byte::from_int<generic>>:
     958:	push   rbp
     959:	mov    rbp,rsp
     95c:	mov    rsi,QWORD PTR [rdx]
     95f:	call   964 <botlish_entry_3+0xc>
			960: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::from_int<generic>
     964:	mov    rsp,rbp
     967:	pop    rbp
     968:	ret
     969:	add    BYTE PTR [rax],al
     96b:	add    BYTE PTR [rax],al
     96d:	add    BYTE PTR [rax],al
	...

0000000000000970 <botlish_fn_4: byte::set<List[UnicodeChar]>>:
     970:	push   rbp
     971:	mov    rbp,rsp
     974:	sub    rsp,0x60
     978:	mov    QWORD PTR [rsp+0x30],rbx
     97d:	mov    QWORD PTR [rsp+0x38],r12
     982:	mov    QWORD PTR [rsp+0x40],r13
     987:	mov    QWORD PTR [rsp+0x48],r14
     98c:	mov    QWORD PTR [rsp+0x50],r15
     991:	mov    r13,rdi
     994:	mov    QWORD PTR [rsp+0x18],0x0
     99d:	mov    QWORD PTR [rsp+0x20],0x0
     9a6:	mov    QWORD PTR [rsp],rsi
     9aa:	mov    rbx,rsi
     9ad:	mov    rdi,r13
     9b0:	call   9b5 <botlish_fn_4+0x45>
			9b1: R_X86_64_PLT32	rt_list_len-0x4
     9b5:	mov    QWORD PTR [rsp+0x8],rax
     9ba:	mov    r12,rax
     9bd:	mov    QWORD PTR [rsp+0x10],0x1
     9c6:	xor    rdx,rdx
     9c9:	mov    rdi,r13
     9cc:	mov    rsi,rdx
     9cf:	call   9d4 <botlish_fn_4+0x64>
			9d0: R_X86_64_PLT32	rt_list_new-0x4
     9d4:	test   rax,rax
     9d7:	je     b0a <botlish_fn_4+0x19a>
     9dd:	mov    esi,0x1
     9e2:	mov    r14,rsi
     9e5:	mov    QWORD PTR [rsp+0x10],0x1
     9ee:	mov    QWORD PTR [rsp+0x18],rax
     9f3:	mov    r15,rax
     9f6:	mov    rax,rsi
     9f9:	and    rax,r12
     9fc:	mov    r14,rsi
     9ff:	test   rax,0x1
     a05:	jne    a2e <botlish_fn_4+0xbe>
     a0b:	mov    rdx,r12
     a0e:	mov    rsi,r14
     a11:	mov    rdi,r13
     a14:	call   a19 <botlish_fn_4+0xa9>
			a15: R_X86_64_PLT32	rt_int_cmp-0x4
     a19:	mov    ecx,0x2
     a1e:	test   rax,rax
     a21:	cmovl  rcx,QWORD PTR [rip+0x177]        # ba0 <botlish_fn_4+0x230>
     a29:	jmp    a41 <botlish_fn_4+0xd1>
     a2e:	mov    ecx,0x2
     a33:	mov    rsi,r14
     a36:	cmp    rsi,r12
     a39:	cmovl  rcx,QWORD PTR [rip+0x15f]        # ba0 <botlish_fn_4+0x230>
     a41:	cmp    rcx,0x6
     a45:	je     a85 <botlish_fn_4+0x115>
     a4b:	mov    rsi,r15
     a4e:	mov    QWORD PTR [rsp],rsi
     a52:	mov    rdi,r13
     a55:	call   a5a <botlish_fn_4+0xea>
			a56: R_X86_64_PLT32	rt_set_from_list-0x4
     a5a:	test   rax,rax
     a5d:	je     b0a <botlish_fn_4+0x19a>
     a63:	mov    rbx,QWORD PTR [rsp+0x30]
     a68:	mov    r12,QWORD PTR [rsp+0x38]
     a6d:	mov    r13,QWORD PTR [rsp+0x40]
     a72:	mov    r14,QWORD PTR [rsp+0x48]
     a77:	mov    r15,QWORD PTR [rsp+0x50]
     a7c:	add    rsp,0x60
     a80:	mov    rsp,rbp
     a83:	pop    rbp
     a84:	ret
     a85:	mov    rsi,r14
     a88:	test   rsi,0x1
     a8f:	je     aab <botlish_fn_4+0x13b>
     a95:	mov    rcx,QWORD PTR [rbx+0x8]
     a99:	mov    rsi,r14
     a9c:	mov    rax,rsi
     a9f:	sar    rax,1
     aa2:	cmp    rax,rcx
     aa5:	jb     aca <botlish_fn_4+0x15a>
     aab:	mov    rdx,r14
     aae:	mov    rsi,rbx
     ab1:	mov    rdi,r13
     ab4:	call   ab9 <botlish_fn_4+0x149>
			ab5: R_X86_64_PLT32	rt_list_get-0x4
     ab9:	test   rax,rax
     abc:	je     b0a <botlish_fn_4+0x19a>
     ac2:	mov    rsi,rax
     ac5:	jmp    ad2 <botlish_fn_4+0x162>
     aca:	mov    rsi,QWORD PTR [rbx+0x10]
     ace:	mov    rsi,QWORD PTR [rsi+rax*8]
     ad2:	mov    rdi,r13
     ad5:	call   ada <botlish_fn_4+0x16a>
			ad6: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     ada:	mov    rsi,rax
     add:	mov    rdi,r13
     ae0:	call   ae5 <botlish_fn_4+0x175>
			ae1: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     ae5:	test   rax,rax
     ae8:	je     b0a <botlish_fn_4+0x19a>
     aee:	mov    QWORD PTR [rsp+0x20],rax
     af3:	mov    rdx,rax
     af6:	mov    rsi,r15
     af9:	mov    rdi,r13
     afc:	call   b01 <botlish_fn_4+0x191>
			afd: R_X86_64_PLT32	rt_list_append-0x4
     b01:	test   rax,rax
     b04:	jne    b2f <botlish_fn_4+0x1bf>
     b0a:	xor    rax,rax
     b0d:	mov    rbx,QWORD PTR [rsp+0x30]
     b12:	mov    r12,QWORD PTR [rsp+0x38]
     b17:	mov    r13,QWORD PTR [rsp+0x40]
     b1c:	mov    r14,QWORD PTR [rsp+0x48]
     b21:	mov    r15,QWORD PTR [rsp+0x50]
     b26:	add    rsp,0x60
     b2a:	mov    rsp,rbp
     b2d:	pop    rbp
     b2e:	ret
     b2f:	mov    QWORD PTR [rsp+0x18],rax
     b34:	mov    r15,rax
     b37:	mov    edx,0x3
     b3c:	mov    QWORD PTR [rsp+0x20],0x3
     b45:	mov    rsi,r14
     b48:	test   rsi,0x1
     b4f:	jne    b5d <botlish_fn_4+0x1ed>
     b55:	mov    rsi,r14
     b58:	jmp    b85 <botlish_fn_4+0x215>
     b5d:	mov    rsi,r14
     b60:	mov    rcx,rsi
     b63:	add    rcx,0x2
     b67:	seto   al
     b6a:	test   al,al
     b6c:	je     b7a <botlish_fn_4+0x20a>
     b72:	mov    rsi,r14
     b75:	jmp    b85 <botlish_fn_4+0x215>
     b7a:	mov    rsi,rcx
     b7d:	mov    r14,rcx
     b80:	jmp    b93 <botlish_fn_4+0x223>
     b85:	mov    rdi,r13
     b88:	call   b8d <botlish_fn_4+0x21d>
			b89: R_X86_64_PLT32	rt_int_add-0x4
     b8d:	mov    rsi,rax
     b90:	mov    r14,rax
     b93:	mov    QWORD PTR [rsp+0x10],rsi
     b98:	mov    rsi,r14
     b9b:	jmp    9f6 <botlish_fn_4+0x86>
     ba0:	(bad)
     ba1:	add    BYTE PTR [rax],al
     ba3:	add    BYTE PTR [rax],al
     ba5:	add    BYTE PTR [rax],al
	...

0000000000000ba8 <botlish_entry_4: byte::set<List[UnicodeChar]>>:
     ba8:	push   rbp
     ba9:	mov    rbp,rsp
     bac:	mov    rsi,QWORD PTR [rdx]
     baf:	call   bb4 <botlish_entry_4+0xc>
			bb0: R_X86_64_PLT32	botlish_fn_4-0x4 ; byte::set<List[UnicodeChar]>
     bb4:	mov    rsp,rbp
     bb7:	pop    rbp
     bb8:	ret
     bb9:	add    BYTE PTR [rax],al
     bbb:	add    BYTE PTR [rax],al
     bbd:	add    BYTE PTR [rax],al
	...

0000000000000bc0 <botlish_fn_5: ascii::is_digit<generic>>:
     bc0:	push   rbp
     bc1:	mov    rbp,rsp
     bc4:	sub    rsp,0x10
     bc8:	mov    QWORD PTR [rsp],rbx
     bcc:	mov    QWORD PTR [rsp+0x8],r12
     bd1:	mov    r8d,0x1
     bd7:	test   rsi,0x1
     bde:	jne    bfe <botlish_fn_5+0x3e>
     be4:	xor    r8d,r8d
     be7:	test   rsi,0x7
     bee:	jne    bfe <botlish_fn_5+0x3e>
     bf4:	movzx  rax,BYTE PTR [rsi]
     bf8:	cmp    al,0x1
     bfa:	sete   r8b
     bfe:	test   r8b,r8b
     c01:	jne    c32 <botlish_fn_5+0x72>
     c07:	mov    rax,QWORD PTR [rdi+0x10]
     c0b:	mov    rcx,QWORD PTR [rax+0xb0]
     c12:	xor    rbx,rbx
     c15:	mov    rdx,rbx
     c18:	call   c1d <botlish_fn_5+0x5d>
			c19: R_X86_64_PLT32	rt_type_error-0x4
     c1d:	mov    rax,rbx
     c20:	mov    rbx,QWORD PTR [rsp]
     c24:	mov    r12,QWORD PTR [rsp+0x8]
     c29:	add    rsp,0x10
     c2d:	mov    rsp,rbp
     c30:	pop    rbp
     c31:	ret
     c32:	mov    r12,rdi
     c35:	test   rsi,0x1
     c3c:	mov    rbx,rsi
     c3f:	jne    c6d <botlish_fn_5+0xad>
     c45:	mov    edx,0x61
     c4a:	mov    rsi,rbx
     c4d:	mov    rdi,r12
     c50:	call   c55 <botlish_fn_5+0x95>
			c51: R_X86_64_PLT32	rt_int_cmp-0x4
     c55:	mov    ecx,0x2
     c5a:	test   rax,rax
     c5d:	cmovge rcx,QWORD PTR [rip+0xab]        # d10 <botlish_fn_5+0x150>
     c65:	mov    rsi,rbx
     c68:	jmp    c81 <botlish_fn_5+0xc1>
     c6d:	mov    ecx,0x2
     c72:	mov    rsi,rbx
     c75:	cmp    rsi,0x61
     c79:	cmovge rcx,QWORD PTR [rip+0x8f]        # d10 <botlish_fn_5+0x150>
     c81:	mov    eax,0x6
     c86:	cmp    rcx,0x6
     c8a:	je     c9d <botlish_fn_5+0xdd>
     c90:	mov    eax,0x2
     c95:	mov    rbx,rax
     c98:	jmp    cf7 <botlish_fn_5+0x137>
     c9d:	mov    rbx,rax
     ca0:	test   rsi,0x1
     ca7:	jne    ccf <botlish_fn_5+0x10f>
     cad:	mov    edx,0x73
     cb2:	mov    rdi,r12
     cb5:	call   cba <botlish_fn_5+0xfa>
			cb6: R_X86_64_PLT32	rt_int_cmp-0x4
     cba:	mov    ecx,0x2
     cbf:	test   rax,rax
     cc2:	cmovle rcx,QWORD PTR [rip+0x46]        # d10 <botlish_fn_5+0x150>
     cca:	jmp    ce0 <botlish_fn_5+0x120>
     ccf:	mov    ecx,0x2
     cd4:	cmp    rsi,0x73
     cd8:	cmovle rcx,QWORD PTR [rip+0x30]        # d10 <botlish_fn_5+0x150>
     ce0:	cmp    rcx,0x6
     ce4:	je     cf4 <botlish_fn_5+0x134>
     cea:	mov    eax,0x2
     cef:	jmp    cf7 <botlish_fn_5+0x137>
     cf4:	mov    rax,rbx
     cf7:	mov    rbx,QWORD PTR [rsp]
     cfb:	mov    r12,QWORD PTR [rsp+0x8]
     d00:	add    rsp,0x10
     d04:	mov    rsp,rbp
     d07:	pop    rbp
     d08:	ret
     d09:	add    BYTE PTR [rax],al
     d0b:	add    BYTE PTR [rax],al
     d0d:	add    BYTE PTR [rax],al
     d0f:	add    BYTE PTR [rsi],al
     d11:	add    BYTE PTR [rax],al
     d13:	add    BYTE PTR [rax],al
     d15:	add    BYTE PTR [rax],al
	...

0000000000000d18 <botlish_entry_5: ascii::is_digit<generic>>:
     d18:	push   rbp
     d19:	mov    rbp,rsp
     d1c:	mov    rsi,QWORD PTR [rdx]
     d1f:	call   d24 <botlish_entry_5+0xc>
			d20: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_digit<generic>
     d24:	mov    rsp,rbp
     d27:	pop    rbp
     d28:	ret
     d29:	add    BYTE PTR [rax],al
     d2b:	add    BYTE PTR [rax],al
     d2d:	add    BYTE PTR [rax],al
	...

0000000000000d30 <botlish_fn_6: ascii::is_upper<generic>>:
     d30:	push   rbp
     d31:	mov    rbp,rsp
     d34:	sub    rsp,0x10
     d38:	mov    QWORD PTR [rsp],rbx
     d3c:	mov    QWORD PTR [rsp+0x8],r12
     d41:	mov    r8d,0x1
     d47:	test   rsi,0x1
     d4e:	jne    d6e <botlish_fn_6+0x3e>
     d54:	xor    r8d,r8d
     d57:	test   rsi,0x7
     d5e:	jne    d6e <botlish_fn_6+0x3e>
     d64:	movzx  rax,BYTE PTR [rsi]
     d68:	cmp    al,0x1
     d6a:	sete   r8b
     d6e:	test   r8b,r8b
     d71:	jne    da2 <botlish_fn_6+0x72>
     d77:	mov    rax,QWORD PTR [rdi+0x10]
     d7b:	mov    rcx,QWORD PTR [rax+0xb0]
     d82:	xor    rbx,rbx
     d85:	mov    rdx,rbx
     d88:	call   d8d <botlish_fn_6+0x5d>
			d89: R_X86_64_PLT32	rt_type_error-0x4
     d8d:	mov    rax,rbx
     d90:	mov    rbx,QWORD PTR [rsp]
     d94:	mov    r12,QWORD PTR [rsp+0x8]
     d99:	add    rsp,0x10
     d9d:	mov    rsp,rbp
     da0:	pop    rbp
     da1:	ret
     da2:	mov    r12,rdi
     da5:	test   rsi,0x1
     dac:	mov    rbx,rsi
     daf:	jne    ddd <botlish_fn_6+0xad>
     db5:	mov    edx,0x83
     dba:	mov    rsi,rbx
     dbd:	mov    rdi,r12
     dc0:	call   dc5 <botlish_fn_6+0x95>
			dc1: R_X86_64_PLT32	rt_int_cmp-0x4
     dc5:	mov    ecx,0x2
     dca:	test   rax,rax
     dcd:	cmovge rcx,QWORD PTR [rip+0xab]        # e80 <botlish_fn_6+0x150>
     dd5:	mov    rsi,rbx
     dd8:	jmp    df4 <botlish_fn_6+0xc4>
     ddd:	mov    ecx,0x2
     de2:	mov    rsi,rbx
     de5:	cmp    rsi,0x83
     dec:	cmovge rcx,QWORD PTR [rip+0x8c]        # e80 <botlish_fn_6+0x150>
     df4:	mov    eax,0x6
     df9:	cmp    rcx,0x6
     dfd:	je     e10 <botlish_fn_6+0xe0>
     e03:	mov    eax,0x2
     e08:	mov    rbx,rax
     e0b:	jmp    e6d <botlish_fn_6+0x13d>
     e10:	mov    rbx,rax
     e13:	test   rsi,0x1
     e1a:	jne    e42 <botlish_fn_6+0x112>
     e20:	mov    edx,0xb5
     e25:	mov    rdi,r12
     e28:	call   e2d <botlish_fn_6+0xfd>
			e29: R_X86_64_PLT32	rt_int_cmp-0x4
     e2d:	mov    ecx,0x2
     e32:	test   rax,rax
     e35:	cmovle rcx,QWORD PTR [rip+0x43]        # e80 <botlish_fn_6+0x150>
     e3d:	jmp    e56 <botlish_fn_6+0x126>
     e42:	mov    ecx,0x2
     e47:	cmp    rsi,0xb5
     e4e:	cmovle rcx,QWORD PTR [rip+0x2a]        # e80 <botlish_fn_6+0x150>
     e56:	cmp    rcx,0x6
     e5a:	je     e6a <botlish_fn_6+0x13a>
     e60:	mov    eax,0x2
     e65:	jmp    e6d <botlish_fn_6+0x13d>
     e6a:	mov    rax,rbx
     e6d:	mov    rbx,QWORD PTR [rsp]
     e71:	mov    r12,QWORD PTR [rsp+0x8]
     e76:	add    rsp,0x10
     e7a:	mov    rsp,rbp
     e7d:	pop    rbp
     e7e:	ret
     e7f:	add    BYTE PTR [rsi],al
     e81:	add    BYTE PTR [rax],al
     e83:	add    BYTE PTR [rax],al
     e85:	add    BYTE PTR [rax],al
	...

0000000000000e88 <botlish_entry_6: ascii::is_upper<generic>>:
     e88:	push   rbp
     e89:	mov    rbp,rsp
     e8c:	mov    rsi,QWORD PTR [rdx]
     e8f:	call   e94 <botlish_entry_6+0xc>
			e90: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_upper<generic>
     e94:	mov    rsp,rbp
     e97:	pop    rbp
     e98:	ret
     e99:	add    BYTE PTR [rax],al
     e9b:	add    BYTE PTR [rax],al
     e9d:	add    BYTE PTR [rax],al
	...

0000000000000ea0 <botlish_fn_7: ascii::is_lower<generic>>:
     ea0:	push   rbp
     ea1:	mov    rbp,rsp
     ea4:	sub    rsp,0x10
     ea8:	mov    QWORD PTR [rsp],rbx
     eac:	mov    QWORD PTR [rsp+0x8],r12
     eb1:	mov    r8d,0x1
     eb7:	test   rsi,0x1
     ebe:	jne    ede <botlish_fn_7+0x3e>
     ec4:	xor    r8d,r8d
     ec7:	test   rsi,0x7
     ece:	jne    ede <botlish_fn_7+0x3e>
     ed4:	movzx  rax,BYTE PTR [rsi]
     ed8:	cmp    al,0x1
     eda:	sete   r8b
     ede:	test   r8b,r8b
     ee1:	jne    f12 <botlish_fn_7+0x72>
     ee7:	mov    rax,QWORD PTR [rdi+0x10]
     eeb:	mov    rcx,QWORD PTR [rax+0xb0]
     ef2:	xor    rbx,rbx
     ef5:	mov    rdx,rbx
     ef8:	call   efd <botlish_fn_7+0x5d>
			ef9: R_X86_64_PLT32	rt_type_error-0x4
     efd:	mov    rax,rbx
     f00:	mov    rbx,QWORD PTR [rsp]
     f04:	mov    r12,QWORD PTR [rsp+0x8]
     f09:	add    rsp,0x10
     f0d:	mov    rsp,rbp
     f10:	pop    rbp
     f11:	ret
     f12:	mov    r12,rdi
     f15:	test   rsi,0x1
     f1c:	mov    rbx,rsi
     f1f:	jne    f4d <botlish_fn_7+0xad>
     f25:	mov    edx,0xc3
     f2a:	mov    rsi,rbx
     f2d:	mov    rdi,r12
     f30:	call   f35 <botlish_fn_7+0x95>
			f31: R_X86_64_PLT32	rt_int_cmp-0x4
     f35:	mov    ecx,0x2
     f3a:	test   rax,rax
     f3d:	cmovge rcx,QWORD PTR [rip+0xab]        # ff0 <botlish_fn_7+0x150>
     f45:	mov    rsi,rbx
     f48:	jmp    f64 <botlish_fn_7+0xc4>
     f4d:	mov    ecx,0x2
     f52:	mov    rsi,rbx
     f55:	cmp    rsi,0xc3
     f5c:	cmovge rcx,QWORD PTR [rip+0x8c]        # ff0 <botlish_fn_7+0x150>
     f64:	mov    eax,0x6
     f69:	cmp    rcx,0x6
     f6d:	je     f80 <botlish_fn_7+0xe0>
     f73:	mov    eax,0x2
     f78:	mov    rbx,rax
     f7b:	jmp    fdd <botlish_fn_7+0x13d>
     f80:	mov    rbx,rax
     f83:	test   rsi,0x1
     f8a:	jne    fb2 <botlish_fn_7+0x112>
     f90:	mov    edx,0xf5
     f95:	mov    rdi,r12
     f98:	call   f9d <botlish_fn_7+0xfd>
			f99: R_X86_64_PLT32	rt_int_cmp-0x4
     f9d:	mov    ecx,0x2
     fa2:	test   rax,rax
     fa5:	cmovle rcx,QWORD PTR [rip+0x43]        # ff0 <botlish_fn_7+0x150>
     fad:	jmp    fc6 <botlish_fn_7+0x126>
     fb2:	mov    ecx,0x2
     fb7:	cmp    rsi,0xf5
     fbe:	cmovle rcx,QWORD PTR [rip+0x2a]        # ff0 <botlish_fn_7+0x150>
     fc6:	cmp    rcx,0x6
     fca:	je     fda <botlish_fn_7+0x13a>
     fd0:	mov    eax,0x2
     fd5:	jmp    fdd <botlish_fn_7+0x13d>
     fda:	mov    rax,rbx
     fdd:	mov    rbx,QWORD PTR [rsp]
     fe1:	mov    r12,QWORD PTR [rsp+0x8]
     fe6:	add    rsp,0x10
     fea:	mov    rsp,rbp
     fed:	pop    rbp
     fee:	ret
     fef:	add    BYTE PTR [rsi],al
     ff1:	add    BYTE PTR [rax],al
     ff3:	add    BYTE PTR [rax],al
     ff5:	add    BYTE PTR [rax],al
	...

0000000000000ff8 <botlish_entry_7: ascii::is_lower<generic>>:
     ff8:	push   rbp
     ff9:	mov    rbp,rsp
     ffc:	mov    rsi,QWORD PTR [rdx]
     fff:	call   1004 <botlish_entry_7+0xc>
			1000: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_lower<generic>
    1004:	mov    rsp,rbp
    1007:	pop    rbp
    1008:	ret

0000000000001009 <botlish_fn_8: ascii::is_alphabetic<generic>>:
    1009:	push   rbp
    100a:	mov    rbp,rsp
    100d:	sub    rsp,0x10
    1011:	mov    QWORD PTR [rsp],r12
    1015:	mov    QWORD PTR [rsp+0x8],r14
    101a:	mov    r12,rsi
    101d:	mov    r14,rdi
    1020:	mov    rsi,r12
    1023:	mov    rdi,r14
    1026:	call   102b <botlish_fn_8+0x22>
			1027: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_upper<generic>
    102b:	test   rax,rax
    102e:	je     1052 <botlish_fn_8+0x49>
    1034:	cmp    rax,0x6
    1038:	je     1085 <botlish_fn_8+0x7c>
    103e:	mov    rsi,r12
    1041:	mov    rdi,r14
    1044:	call   1049 <botlish_fn_8+0x40>
			1045: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_lower<generic>
    1049:	test   rax,rax
    104c:	jne    1067 <botlish_fn_8+0x5e>
    1052:	xor    rax,rax
    1055:	mov    r12,QWORD PTR [rsp]
    1059:	mov    r14,QWORD PTR [rsp+0x8]
    105e:	add    rsp,0x10
    1062:	mov    rsp,rbp
    1065:	pop    rbp
    1066:	ret
    1067:	cmp    rax,0x6
    106b:	je     107b <botlish_fn_8+0x72>
    1071:	mov    eax,0x2
    1076:	jmp    108a <botlish_fn_8+0x81>
    107b:	mov    eax,0x6
    1080:	jmp    108a <botlish_fn_8+0x81>
    1085:	mov    eax,0x6
    108a:	mov    r12,QWORD PTR [rsp]
    108e:	mov    r14,QWORD PTR [rsp+0x8]
    1093:	add    rsp,0x10
    1097:	mov    rsp,rbp
    109a:	pop    rbp
    109b:	ret

000000000000109c <botlish_entry_8: ascii::is_alphabetic<generic>>:
    109c:	push   rbp
    109d:	mov    rbp,rsp
    10a0:	mov    rsi,QWORD PTR [rdx]
    10a3:	call   10a8 <botlish_entry_8+0xc>
			10a4: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphabetic<generic>
    10a8:	mov    rsp,rbp
    10ab:	pop    rbp
    10ac:	ret

00000000000010ad <botlish_fn_9: ascii::is_alphanumeric<generic>>:
    10ad:	push   rbp
    10ae:	mov    rbp,rsp
    10b1:	sub    rsp,0x10
    10b5:	mov    QWORD PTR [rsp],r12
    10b9:	mov    QWORD PTR [rsp+0x8],r14
    10be:	mov    r12,rsi
    10c1:	mov    r14,rdi
    10c4:	mov    rsi,r12
    10c7:	mov    rdi,r14
    10ca:	call   10cf <botlish_fn_9+0x22>
			10cb: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphabetic<generic>
    10cf:	test   rax,rax
    10d2:	je     10f6 <botlish_fn_9+0x49>
    10d8:	cmp    rax,0x6
    10dc:	je     1129 <botlish_fn_9+0x7c>
    10e2:	mov    rsi,r12
    10e5:	mov    rdi,r14
    10e8:	call   10ed <botlish_fn_9+0x40>
			10e9: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_digit<generic>
    10ed:	test   rax,rax
    10f0:	jne    110b <botlish_fn_9+0x5e>
    10f6:	xor    rax,rax
    10f9:	mov    r12,QWORD PTR [rsp]
    10fd:	mov    r14,QWORD PTR [rsp+0x8]
    1102:	add    rsp,0x10
    1106:	mov    rsp,rbp
    1109:	pop    rbp
    110a:	ret
    110b:	cmp    rax,0x6
    110f:	je     111f <botlish_fn_9+0x72>
    1115:	mov    eax,0x2
    111a:	jmp    112e <botlish_fn_9+0x81>
    111f:	mov    eax,0x6
    1124:	jmp    112e <botlish_fn_9+0x81>
    1129:	mov    eax,0x6
    112e:	mov    r12,QWORD PTR [rsp]
    1132:	mov    r14,QWORD PTR [rsp+0x8]
    1137:	add    rsp,0x10
    113b:	mov    rsp,rbp
    113e:	pop    rbp
    113f:	ret

0000000000001140 <botlish_entry_9: ascii::is_alphanumeric<generic>>:
    1140:	push   rbp
    1141:	mov    rbp,rsp
    1144:	mov    rsi,QWORD PTR [rdx]
    1147:	call   114c <botlish_entry_9+0xc>
			1148: R_X86_64_PLT32	botlish_fn_9-0x4 ; ascii::is_alphanumeric<generic>
    114c:	mov    rsp,rbp
    114f:	pop    rbp
    1150:	ret

0000000000001151 <botlish_fn_10: web::is_unreserved<generic>>:
    1151:	push   rbp
    1152:	mov    rbp,rsp
    1155:	sub    rsp,0x20
    1159:	mov    QWORD PTR [rsp],rbx
    115d:	mov    QWORD PTR [rsp+0x8],r12
    1162:	mov    QWORD PTR [rsp+0x10],r15
    1167:	mov    rbx,rdi
    116a:	mov    r12,rsi
    116d:	mov    r15,rdx
    1170:	mov    rsi,r15
    1173:	mov    rdi,rbx
    1176:	call   117b <botlish_fn_10+0x2a>
			1177: R_X86_64_PLT32	botlish_fn_9-0x4 ; ascii::is_alphanumeric<generic>
    117b:	test   rax,rax
    117e:	je     11ac <botlish_fn_10+0x5b>
    1184:	cmp    rax,0x6
    1188:	je     11e4 <botlish_fn_10+0x93>
    118e:	mov    rsi,r12
    1191:	mov    rax,QWORD PTR [rsi+0x20]
    1195:	mov    rsi,QWORD PTR [rax]
    1198:	mov    rdx,r15
    119b:	mov    rdi,rbx
    119e:	call   11a3 <botlish_fn_10+0x52>
			119f: R_X86_64_PLT32	rt_set_contains-0x4
    11a3:	test   rax,rax
    11a6:	jne    11c6 <botlish_fn_10+0x75>
    11ac:	xor    rax,rax
    11af:	mov    rbx,QWORD PTR [rsp]
    11b3:	mov    r12,QWORD PTR [rsp+0x8]
    11b8:	mov    r15,QWORD PTR [rsp+0x10]
    11bd:	add    rsp,0x20
    11c1:	mov    rsp,rbp
    11c4:	pop    rbp
    11c5:	ret
    11c6:	cmp    rax,0x6
    11ca:	je     11da <botlish_fn_10+0x89>
    11d0:	mov    eax,0x2
    11d5:	jmp    11e9 <botlish_fn_10+0x98>
    11da:	mov    eax,0x6
    11df:	jmp    11e9 <botlish_fn_10+0x98>
    11e4:	mov    eax,0x6
    11e9:	mov    rbx,QWORD PTR [rsp]
    11ed:	mov    r12,QWORD PTR [rsp+0x8]
    11f2:	mov    r15,QWORD PTR [rsp+0x10]
    11f7:	add    rsp,0x20
    11fb:	mov    rsp,rbp
    11fe:	pop    rbp
    11ff:	ret

0000000000001200 <botlish_entry_10: web::is_unreserved<generic>>:
    1200:	push   rbp
    1201:	mov    rbp,rsp
    1204:	mov    rdx,QWORD PTR [rdx]
    1207:	call   120c <botlish_entry_10+0xc>
			1208: R_X86_64_PLT32	botlish_fn_10-0x4 ; web::is_unreserved<generic>
    120c:	mov    rsp,rbp
    120f:	pop    rbp
    1210:	ret

0000000000001211 <botlish_fn_11: web::uri_escape_text<generic>>:
    1211:	push   rbp
    1212:	mov    rbp,rsp
    1215:	sub    rsp,0x30
    1219:	mov    QWORD PTR [rsp],rdx
    121d:	mov    r10,rdx
    1220:	mov    edx,0x1
    1225:	mov    QWORD PTR [rsp+0x8],0x1
    122e:	mov    rax,QWORD PTR [rdi+0x10]
    1232:	mov    rcx,QWORD PTR [rax+0xb8]
    1239:	mov    QWORD PTR [rsp+0x10],rcx
    123e:	mov    rax,QWORD PTR [rsi+0x20]
    1242:	mov    r8,QWORD PTR [rax+0x8]
    1246:	mov    QWORD PTR [rsp+0x18],r8
    124b:	mov    rax,QWORD PTR [rsi+0x20]
    124f:	mov    r9,QWORD PTR [rax]
    1252:	mov    QWORD PTR [rsp+0x20],r9
    1257:	mov    rsi,r10
    125a:	call   125f <botlish_fn_11+0x4e>
			125b: R_X86_64_PLT32	botlish_fn_16-0x4 ; esc_from<generic>
    125f:	test   rax,rax
    1262:	jne    1274 <botlish_fn_11+0x63>
    1268:	xor    rax,rax
    126b:	add    rsp,0x30
    126f:	mov    rsp,rbp
    1272:	pop    rbp
    1273:	ret
    1274:	add    rsp,0x30
    1278:	mov    rsp,rbp
    127b:	pop    rbp
    127c:	ret

000000000000127d <botlish_entry_11: web::uri_escape_text<generic>>:
    127d:	push   rbp
    127e:	mov    rbp,rsp
    1281:	mov    rdx,QWORD PTR [rdx]
    1284:	call   1289 <botlish_entry_11+0xc>
			1285: R_X86_64_PLT32	botlish_fn_11-0x4 ; web::uri_escape_text<generic>
    1289:	mov    rsp,rbp
    128c:	pop    rbp
    128d:	ret

000000000000128e <botlish_fn_12: high_nibble<generic>>:
    128e:	push   rbp
    128f:	mov    rbp,rsp
    1292:	sub    rsp,0x20
    1296:	mov    QWORD PTR [rsp+0x10],rbx
    129b:	mov    QWORD PTR [rsp],rsi
    129f:	mov    QWORD PTR [rsp+0x8],0x1e1
    12a8:	mov    r8d,0x1
    12ae:	test   rsi,0x1
    12b5:	jne    12d5 <botlish_fn_12+0x47>
    12bb:	xor    r8d,r8d
    12be:	test   rsi,0x7
    12c5:	jne    12d5 <botlish_fn_12+0x47>
    12cb:	movzx  rax,BYTE PTR [rsi]
    12cf:	cmp    al,0x1
    12d1:	sete   r8b
    12d5:	test   r8b,r8b
    12d8:	jne    1305 <botlish_fn_12+0x77>
    12de:	mov    rax,QWORD PTR [rdi+0x10]
    12e2:	mov    rcx,QWORD PTR [rax+0xc0]
    12e9:	xor    rbx,rbx
    12ec:	mov    rdx,rbx
    12ef:	call   12f4 <botlish_fn_12+0x66>
			12f0: R_X86_64_PLT32	rt_type_error-0x4
    12f4:	mov    rax,rbx
    12f7:	mov    rbx,QWORD PTR [rsp+0x10]
    12fc:	add    rsp,0x20
    1300:	mov    rsp,rbp
    1303:	pop    rbp
    1304:	ret
    1305:	test   rsi,0x1
    130c:	jne    1321 <botlish_fn_12+0x93>
    1312:	mov    edx,0x1e1
    1317:	call   131c <botlish_fn_12+0x8e>
			1318: R_X86_64_PLT32	rt_int_and-0x4
    131c:	jmp    132b <botlish_fn_12+0x9d>
    1321:	and    rsi,0x1e1
    1328:	mov    rax,rsi
    132b:	sar    rax,0x5
    132f:	shl    rax,1
    1332:	or     rax,0x1
    1336:	mov    rbx,QWORD PTR [rsp+0x10]
    133b:	add    rsp,0x20
    133f:	mov    rsp,rbp
    1342:	pop    rbp
    1343:	ret

0000000000001344 <botlish_entry_12: high_nibble<generic>>:
    1344:	push   rbp
    1345:	mov    rbp,rsp
    1348:	mov    rsi,QWORD PTR [rdx]
    134b:	call   1350 <botlish_entry_12+0xc>
			134c: R_X86_64_PLT32	botlish_fn_12-0x4 ; high_nibble<generic>
    1350:	mov    rsp,rbp
    1353:	pop    rbp
    1354:	ret

0000000000001355 <botlish_fn_13: hex_pair<generic>>:
    1355:	push   rbp
    1356:	mov    rbp,rsp
    1359:	sub    rsp,0x30
    135d:	mov    QWORD PTR [rsp+0x10],rbx
    1362:	mov    QWORD PTR [rsp+0x18],r12
    1367:	mov    QWORD PTR [rsp+0x20],r13
    136c:	mov    QWORD PTR [rsp+0x28],r14
    1371:	mov    r12,rdi
    1374:	mov    QWORD PTR [rsp],rsi
    1378:	mov    r13,rsi
    137b:	mov    QWORD PTR [rsp+0x8],rdx
    1380:	mov    rbx,rdx
    1383:	mov    rsi,r13
    1386:	mov    rdi,r12
    1389:	call   138e <botlish_fn_13+0x39>
			138a: R_X86_64_PLT32	botlish_fn_12-0x4 ; high_nibble<generic>
    138e:	test   rax,rax
    1391:	je     14bf <botlish_fn_13+0x16a>
    1397:	test   rax,0x1
    139d:	jne    13ab <botlish_fn_13+0x56>
    13a3:	mov    rdx,rax
    13a6:	jmp    13c1 <botlish_fn_13+0x6c>
    13ab:	mov    rdx,QWORD PTR [rbx+0x8]
    13af:	mov    rcx,rax
    13b2:	sar    rcx,1
    13b5:	cmp    rcx,rdx
    13b8:	jb     13dd <botlish_fn_13+0x88>
    13be:	mov    rdx,rax
    13c1:	mov    rsi,rbx
    13c4:	mov    rdi,r12
    13c7:	call   13cc <botlish_fn_13+0x77>
			13c8: R_X86_64_PLT32	rt_list_get-0x4
    13cc:	test   rax,rax
    13cf:	je     14bf <botlish_fn_13+0x16a>
    13d5:	mov    rsi,rax
    13d8:	jmp    13e5 <botlish_fn_13+0x90>
    13dd:	mov    rax,QWORD PTR [rbx+0x10]
    13e1:	mov    rsi,QWORD PTR [rax+rcx*8]
    13e5:	mov    QWORD PTR [rsp],rsi
    13e9:	mov    r14,rsi
    13ec:	mov    ecx,0x1
    13f1:	mov    rsi,r13
    13f4:	test   rsi,0x1
    13fb:	jne    1419 <botlish_fn_13+0xc4>
    1401:	xor    ecx,ecx
    1403:	test   rsi,0x7
    140a:	jne    1419 <botlish_fn_13+0xc4>
    1410:	movzx  rax,BYTE PTR [rsi]
    1414:	cmp    al,0x1
    1416:	sete   cl
    1419:	test   cl,cl
    141b:	jne    143c <botlish_fn_13+0xe7>
    1421:	mov    rdi,r12
    1424:	mov    rax,QWORD PTR [rdi+0x10]
    1428:	mov    rcx,QWORD PTR [rax+0xc8]
    142f:	xor    rdx,rdx
    1432:	call   1437 <botlish_fn_13+0xe2>
			1433: R_X86_64_PLT32	rt_type_error-0x4
    1437:	jmp    14bf <botlish_fn_13+0x16a>
    143c:	mov    edx,0x21
    1441:	mov    rdi,r12
    1444:	call   1449 <botlish_fn_13+0xf4>
			1445: R_X86_64_PLT32	rt_int_mod-0x4
    1449:	test   rax,rax
    144c:	je     14bf <botlish_fn_13+0x16a>
    1452:	test   rax,0x1
    1458:	jne    1469 <botlish_fn_13+0x114>
    145e:	mov    rdx,rax
    1461:	mov    rsi,rbx
    1464:	jmp    1482 <botlish_fn_13+0x12d>
    1469:	mov    rdi,QWORD PTR [rbx+0x8]
    146d:	mov    rsi,rax
    1470:	sar    rsi,1
    1473:	mov    rdx,rax
    1476:	cmp    rsi,rdi
    1479:	jb     149b <botlish_fn_13+0x146>
    147f:	mov    rsi,rbx
    1482:	mov    rdi,r12
    1485:	call   148a <botlish_fn_13+0x135>
			1486: R_X86_64_PLT32	rt_list_get-0x4
    148a:	test   rax,rax
    148d:	je     14bf <botlish_fn_13+0x16a>
    1493:	mov    rdx,rax
    1496:	jmp    14a6 <botlish_fn_13+0x151>
    149b:	mov    rax,rbx
    149e:	mov    rax,QWORD PTR [rax+0x10]
    14a2:	mov    rdx,QWORD PTR [rax+rsi*8]
    14a6:	mov    QWORD PTR [rsp+0x8],rdx
    14ab:	mov    rsi,r14
    14ae:	mov    rdi,r12
    14b1:	call   14b6 <botlish_fn_13+0x161>
			14b2: R_X86_64_PLT32	rt_str_cat-0x4
    14b6:	test   rax,rax
    14b9:	jne    14df <botlish_fn_13+0x18a>
    14bf:	xor    rax,rax
    14c2:	mov    rbx,QWORD PTR [rsp+0x10]
    14c7:	mov    r12,QWORD PTR [rsp+0x18]
    14cc:	mov    r13,QWORD PTR [rsp+0x20]
    14d1:	mov    r14,QWORD PTR [rsp+0x28]
    14d6:	add    rsp,0x30
    14da:	mov    rsp,rbp
    14dd:	pop    rbp
    14de:	ret
    14df:	mov    rbx,QWORD PTR [rsp+0x10]
    14e4:	mov    r12,QWORD PTR [rsp+0x18]
    14e9:	mov    r13,QWORD PTR [rsp+0x20]
    14ee:	mov    r14,QWORD PTR [rsp+0x28]
    14f3:	add    rsp,0x30
    14f7:	mov    rsp,rbp
    14fa:	pop    rbp
    14fb:	ret

00000000000014fc <botlish_entry_13: hex_pair<generic>>:
    14fc:	push   rbp
    14fd:	mov    rbp,rsp
    1500:	mov    rsi,QWORD PTR [rdx]
    1503:	mov    rdx,QWORD PTR [rdx+0x8]
    1507:	call   150c <botlish_entry_13+0x10>
			1508: R_X86_64_PLT32	botlish_fn_13-0x4 ; hex_pair<generic>
    150c:	mov    rsp,rbp
    150f:	pop    rbp
    1510:	ret
    1511:	add    BYTE PTR [rax],al
    1513:	add    BYTE PTR [rax],al
    1515:	add    BYTE PTR [rax],al
	...

0000000000001518 <botlish_fn_14: esc_bytes<generic>>:
    1518:	push   rbp
    1519:	mov    rbp,rsp
    151c:	sub    rsp,0x70
    1520:	mov    QWORD PTR [rsp+0x40],rbx
    1525:	mov    QWORD PTR [rsp+0x48],r12
    152a:	mov    QWORD PTR [rsp+0x50],r13
    152f:	mov    QWORD PTR [rsp+0x58],r14
    1534:	mov    QWORD PTR [rsp+0x60],r15
    1539:	mov    r13,rdi
    153c:	mov    QWORD PTR [rsp+0x28],0x0
    1545:	mov    QWORD PTR [rsp],rsi
    1549:	mov    QWORD PTR [rsp+0x8],rdx
    154e:	mov    QWORD PTR [rsp+0x10],rcx
    1553:	mov    QWORD PTR [rsp+0x18],r8
    1558:	mov    r12,r8
    155b:	mov    r14,rcx
    155e:	mov    r15,rdx
    1561:	xor    eax,eax
    1563:	test   rsi,0x7
    156a:	jne    157b <botlish_fn_14+0x63>
    1570:	movzx  r8,BYTE PTR [rsi]
    1574:	cmp    r8b,0x3
    1578:	sete   al
    157b:	test   al,al
    157d:	jne    15a0 <botlish_fn_14+0x88>
    1583:	mov    rdi,r13
    1586:	mov    rax,QWORD PTR [rdi+0x10]
    158a:	mov    rcx,QWORD PTR [rax+0xd0]
    1591:	mov    edx,0x4
    1596:	call   159b <botlish_fn_14+0x83>
			1597: R_X86_64_PLT32	rt_type_error-0x4
    159b:	jmp    17a6 <botlish_fn_14+0x28e>
    15a0:	mov    rbx,rsi
    15a3:	mov    rdi,r13
    15a6:	call   15ab <botlish_fn_14+0x93>
			15a7: R_X86_64_PLT32	rt_list_len-0x4
    15ab:	mov    ecx,0x1
    15b0:	mov    rsi,r15
    15b3:	test   rsi,0x1
    15ba:	jne    15e0 <botlish_fn_14+0xc8>
    15c0:	xor    ecx,ecx
    15c2:	mov    rsi,r15
    15c5:	test   rsi,0x7
    15cc:	jne    15e0 <botlish_fn_14+0xc8>
    15d2:	mov    rsi,r15
    15d5:	movzx  rcx,BYTE PTR [rsi]
    15d9:	rex cmp cl,0x1
    15dd:	sete   cl
    15e0:	test   cl,cl
    15e2:	jne    1606 <botlish_fn_14+0xee>
    15e8:	mov    rdi,r13
    15eb:	mov    rax,QWORD PTR [rdi+0x10]
    15ef:	mov    rcx,QWORD PTR [rax+0xb0]
    15f6:	xor    rdx,rdx
    15f9:	mov    rsi,r15
    15fc:	call   1601 <botlish_fn_14+0xe9>
			15fd: R_X86_64_PLT32	rt_type_error-0x4
    1601:	jmp    17a6 <botlish_fn_14+0x28e>
    1606:	mov    rsi,r15
    1609:	mov    rcx,rsi
    160c:	and    rcx,rax
    160f:	mov    rdx,rax
    1612:	test   rcx,0x1
    1619:	jne    163f <botlish_fn_14+0x127>
    161f:	mov    rsi,r15
    1622:	mov    rdi,r13
    1625:	call   162a <botlish_fn_14+0x112>
			1626: R_X86_64_PLT32	rt_int_cmp-0x4
    162a:	mov    ecx,0x2
    162f:	test   rax,rax
    1632:	cmovge rcx,QWORD PTR [rip+0x1de]        # 1818 <botlish_fn_14+0x300>
    163a:	jmp    1652 <botlish_fn_14+0x13a>
    163f:	mov    ecx,0x2
    1644:	mov    rsi,r15
    1647:	cmp    rsi,rdx
    164a:	cmovge rcx,QWORD PTR [rip+0x1c6]        # 1818 <botlish_fn_14+0x300>
    1652:	cmp    rcx,0x6
    1656:	je     17f1 <botlish_fn_14+0x2d9>
    165c:	mov    QWORD PTR [rsp+0x20],0x3
    1665:	mov    rsi,r15
    1668:	test   rsi,0x1
    166f:	je     168a <botlish_fn_14+0x172>
    1675:	mov    rsi,r15
    1678:	mov    rax,rsi
    167b:	add    rax,0x2
    167f:	seto   cl
    1682:	test   cl,cl
    1684:	je     169a <botlish_fn_14+0x182>
    168a:	mov    edx,0x3
    168f:	mov    rsi,r15
    1692:	mov    rdi,r13
    1695:	call   169a <botlish_fn_14+0x182>
			1696: R_X86_64_PLT32	rt_int_add-0x4
    169a:	mov    QWORD PTR [rsp+0x8],rax
    169f:	mov    rdi,r13
    16a2:	mov    QWORD PTR [rsp+0x30],rax
    16a7:	mov    rax,QWORD PTR [rdi+0x10]
    16ab:	mov    rsi,QWORD PTR [rax+0xd8]
    16b2:	mov    QWORD PTR [rsp+0x20],rsi
    16b7:	mov    QWORD PTR [rsp+0x38],rsi
    16bc:	mov    rsi,r15
    16bf:	test   rsi,0x1
    16c6:	jne    16d4 <botlish_fn_14+0x1bc>
    16cc:	mov    rdx,r15
    16cf:	jmp    16ed <botlish_fn_14+0x1d5>
    16d4:	mov    rcx,QWORD PTR [rbx+0x8]
    16d8:	mov    rsi,r15
    16db:	mov    rax,rsi
    16de:	sar    rax,1
    16e1:	cmp    rax,rcx
    16e4:	jb     1709 <botlish_fn_14+0x1f1>
    16ea:	mov    rdx,r15
    16ed:	mov    rsi,rbx
    16f0:	mov    rdi,r13
    16f3:	call   16f8 <botlish_fn_14+0x1e0>
			16f4: R_X86_64_PLT32	rt_list_get-0x4
    16f8:	test   rax,rax
    16fb:	je     17a6 <botlish_fn_14+0x28e>
    1701:	mov    rsi,rax
    1704:	jmp    1711 <botlish_fn_14+0x1f9>
    1709:	mov    rcx,QWORD PTR [rbx+0x10]
    170d:	mov    rsi,QWORD PTR [rcx+rax*8]
    1711:	mov    QWORD PTR [rsp+0x28],rsi
    1716:	mov    rdx,r12
    1719:	mov    rdi,r13
    171c:	call   1721 <botlish_fn_14+0x209>
			171d: R_X86_64_PLT32	botlish_fn_13-0x4 ; hex_pair<generic>
    1721:	test   rax,rax
    1724:	je     17a6 <botlish_fn_14+0x28e>
    172a:	mov    QWORD PTR [rsp+0x28],rax
    172f:	mov    rdx,rax
    1732:	mov    rsi,QWORD PTR [rsp+0x38]
    1737:	mov    rdi,r13
    173a:	call   173f <botlish_fn_14+0x227>
			173b: R_X86_64_PLT32	rt_str_cat-0x4
    173f:	test   rax,rax
    1742:	je     17a6 <botlish_fn_14+0x28e>
    1748:	mov    QWORD PTR [rsp+0x20],rax
    174d:	mov    rdx,rax
    1750:	xor    eax,eax
    1752:	mov    rsi,r14
    1755:	test   rsi,0x7
    175c:	jne    176d <botlish_fn_14+0x255>
    1762:	movzx  rdi,BYTE PTR [rsi]
    1766:	cmp    dil,0x2
    176a:	sete   al
    176d:	test   al,al
    176f:	jne    1795 <botlish_fn_14+0x27d>
    1775:	mov    rdi,r13
    1778:	mov    rdi,QWORD PTR [rdi+0x10]
    177c:	mov    rcx,QWORD PTR [rdi+0xe0]
    1783:	mov    edx,0x1
    1788:	mov    rdi,r13
    178b:	call   1790 <botlish_fn_14+0x278>
			178c: R_X86_64_PLT32	rt_type_error-0x4
    1790:	jmp    17a6 <botlish_fn_14+0x28e>
    1795:	mov    rdi,r13
    1798:	call   179d <botlish_fn_14+0x285>
			1799: R_X86_64_PLT32	rt_str_cat-0x4
    179d:	test   rax,rax
    17a0:	jne    17cb <botlish_fn_14+0x2b3>
    17a6:	xor    rax,rax
    17a9:	mov    rbx,QWORD PTR [rsp+0x40]
    17ae:	mov    r12,QWORD PTR [rsp+0x48]
    17b3:	mov    r13,QWORD PTR [rsp+0x50]
    17b8:	mov    r14,QWORD PTR [rsp+0x58]
    17bd:	mov    r15,QWORD PTR [rsp+0x60]
    17c2:	add    rsp,0x70
    17c6:	mov    rsp,rbp
    17c9:	pop    rbp
    17ca:	ret
    17cb:	mov    QWORD PTR [rsp],rbx
    17cf:	mov    rcx,QWORD PTR [rsp+0x30]
    17d4:	mov    QWORD PTR [rsp+0x8],rcx
    17d9:	mov    QWORD PTR [rsp+0x10],rax
    17de:	mov    QWORD PTR [rsp+0x18],r12
    17e3:	mov    rsi,rbx
    17e6:	mov    r14,rax
    17e9:	mov    r15,rcx
    17ec:	jmp    1561 <botlish_fn_14+0x49>
    17f1:	mov    rax,r14
    17f4:	mov    rbx,QWORD PTR [rsp+0x40]
    17f9:	mov    r12,QWORD PTR [rsp+0x48]
    17fe:	mov    r13,QWORD PTR [rsp+0x50]
    1803:	mov    r14,QWORD PTR [rsp+0x58]
    1808:	mov    r15,QWORD PTR [rsp+0x60]
    180d:	add    rsp,0x70
    1811:	mov    rsp,rbp
    1814:	pop    rbp
    1815:	ret
    1816:	add    BYTE PTR [rax],al
    1818:	(bad)
    1819:	add    BYTE PTR [rax],al
    181b:	add    BYTE PTR [rax],al
    181d:	add    BYTE PTR [rax],al
	...

0000000000001820 <botlish_entry_14: esc_bytes<generic>>:
    1820:	push   rbp
    1821:	mov    rbp,rsp
    1824:	mov    rsi,QWORD PTR [rdx]
    1827:	mov    r9,QWORD PTR [rdx+0x8]
    182b:	mov    rcx,QWORD PTR [rdx+0x10]
    182f:	mov    r8,QWORD PTR [rdx+0x18]
    1833:	mov    rdx,r9
    1836:	call   183b <botlish_entry_14+0x1b>
			1837: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_bytes<generic>
    183b:	mov    rsp,rbp
    183e:	pop    rbp
    183f:	ret

0000000000001840 <botlish_fn_15: esc_char<generic>>:
    1840:	push   rbp
    1841:	mov    rbp,rsp
    1844:	sub    rsp,0x60
    1848:	mov    QWORD PTR [rsp+0x30],rbx
    184d:	mov    QWORD PTR [rsp+0x38],r12
    1852:	mov    QWORD PTR [rsp+0x40],r13
    1857:	mov    QWORD PTR [rsp+0x48],r14
    185c:	mov    QWORD PTR [rsp+0x50],r15
    1861:	mov    QWORD PTR [rsp+0x18],0x0
    186a:	mov    QWORD PTR [rsp],rsi
    186e:	mov    QWORD PTR [rsp+0x8],rdx
    1873:	mov    r12,rdx
    1876:	mov    QWORD PTR [rsp+0x10],rcx
    187b:	mov    rbx,rcx
    187e:	xor    r10d,r10d
    1881:	test   rsi,0x7
    1888:	jne    1898 <botlish_fn_15+0x58>
    188e:	movzx  rax,BYTE PTR [rsi]
    1892:	cmp    al,0x2
    1894:	sete   r10b
    1898:	test   r10b,r10b
    189b:	jne    18bb <botlish_fn_15+0x7b>
    18a1:	mov    rax,QWORD PTR [rdi+0x10]
    18a5:	mov    rcx,QWORD PTR [rax+0xe8]
    18ac:	mov    edx,0x1
    18b1:	call   18b6 <botlish_fn_15+0x76>
			18b2: R_X86_64_PLT32	rt_type_error-0x4
    18b6:	jmp    1a1e <botlish_fn_15+0x1de>
    18bb:	mov    r13,rdi
    18be:	mov    QWORD PTR [rsp+0x20],rsi
    18c3:	call   18c8 <botlish_fn_15+0x88>
			18c4: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    18c8:	mov    rcx,rax
    18cb:	mov    r14,rax
    18ce:	test   rax,rcx
    18d1:	je     1a1e <botlish_fn_15+0x1de>
    18d7:	mov    rax,r14
    18da:	mov    QWORD PTR [rsp],rax
    18de:	mov    rsi,r14
    18e1:	mov    rdi,r13
    18e4:	call   18e9 <botlish_fn_15+0xa9>
			18e5: R_X86_64_PLT32	rt_list_len-0x4
    18e9:	mov    edx,0x1
    18ee:	sar    rax,1
    18f1:	cmp    rax,0x1
    18f5:	je     1930 <botlish_fn_15+0xf0>
    18fb:	mov    QWORD PTR [rsp+0x8],0x1
    1904:	mov    rdi,r13
    1907:	mov    rax,QWORD PTR [rdi+0x10]
    190b:	mov    rcx,QWORD PTR [rax+0xb8]
    1912:	mov    QWORD PTR [rsp+0x18],rcx
    1917:	mov    rsi,r14
    191a:	mov    r8,rbx
    191d:	call   1922 <botlish_fn_15+0xe2>
			191e: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_bytes<generic>
    1922:	test   rax,rax
    1925:	je     1a1e <botlish_fn_15+0x1de>
    192b:	jmp    1a4d <botlish_fn_15+0x20d>
    1930:	mov    rsi,r14
    1933:	mov    r15,rdx
    1936:	mov    rdx,QWORD PTR [rsi+0x8]
    193a:	mov    r14,rsi
    193d:	test   rdx,rdx
    1940:	jne    1965 <botlish_fn_15+0x125>
    1946:	mov    rdx,r15
    1949:	mov    rsi,r14
    194c:	mov    rdi,r13
    194f:	call   1954 <botlish_fn_15+0x114>
			1950: R_X86_64_PLT32	rt_list_get-0x4
    1954:	test   rax,rax
    1957:	je     1980 <botlish_fn_15+0x140>
    195d:	mov    rsi,rax
    1960:	jmp    196f <botlish_fn_15+0x12f>
    1965:	mov    rsi,r14
    1968:	mov    r8,QWORD PTR [rsi+0x10]
    196c:	mov    rsi,QWORD PTR [r8]
    196f:	mov    rdi,r13
    1972:	call   1977 <botlish_fn_15+0x137>
			1973: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::from_int<generic>
    1977:	test   rax,rax
    197a:	jne    19ca <botlish_fn_15+0x18a>
    1980:	mov    rdi,r13
    1983:	call   1988 <botlish_fn_15+0x148>
			1984: R_X86_64_PLT32	rt_declared_error-0x4
    1988:	cmp    rax,0x1
    198c:	je     19b7 <botlish_fn_15+0x177>
    1992:	mov    rdi,r13
    1995:	call   199a <botlish_fn_15+0x15a>
			1996: R_X86_64_PLT32	rt_declared_error-0x4
    199a:	cmp    rax,0x2
    199e:	jne    1a1e <botlish_fn_15+0x1de>
    19a4:	mov    rdi,r13
    19a7:	call   19ac <botlish_fn_15+0x16c>
			19a8: R_X86_64_PLT32	rt_clear_declared_error-0x4
    19ac:	mov    rdx,r15
    19af:	mov    rsi,r12
    19b2:	jmp    19d0 <botlish_fn_15+0x190>
    19b7:	mov    rdi,r13
    19ba:	call   19bf <botlish_fn_15+0x17f>
			19bb: R_X86_64_PLT32	rt_clear_declared_error-0x4
    19bf:	mov    rdx,r15
    19c2:	mov    rsi,r12
    19c5:	jmp    19d0 <botlish_fn_15+0x190>
    19ca:	mov    rdx,rax
    19cd:	mov    rsi,r12
    19d0:	mov    rdi,r13
    19d3:	call   19d8 <botlish_fn_15+0x198>
			19d4: R_X86_64_PLT32	botlish_fn_10-0x4 ; web::is_unreserved<generic>
    19d8:	test   rax,rax
    19db:	je     1a1e <botlish_fn_15+0x1de>
    19e1:	cmp    rax,0x6
    19e5:	je     1a48 <botlish_fn_15+0x208>
    19eb:	mov    QWORD PTR [rsp+0x8],0x1
    19f4:	mov    rdi,r13
    19f7:	mov    rax,QWORD PTR [rdi+0x10]
    19fb:	mov    rcx,QWORD PTR [rax+0xb8]
    1a02:	mov    QWORD PTR [rsp+0x18],rcx
    1a07:	mov    rdx,r15
    1a0a:	mov    rsi,r14
    1a0d:	mov    r8,rbx
    1a10:	call   1a15 <botlish_fn_15+0x1d5>
			1a11: R_X86_64_PLT32	botlish_fn_14-0x4 ; esc_bytes<generic>
    1a15:	test   rax,rax
    1a18:	jne    1a43 <botlish_fn_15+0x203>
    1a1e:	xor    rax,rax
    1a21:	mov    rbx,QWORD PTR [rsp+0x30]
    1a26:	mov    r12,QWORD PTR [rsp+0x38]
    1a2b:	mov    r13,QWORD PTR [rsp+0x40]
    1a30:	mov    r14,QWORD PTR [rsp+0x48]
    1a35:	mov    r15,QWORD PTR [rsp+0x50]
    1a3a:	add    rsp,0x60
    1a3e:	mov    rsp,rbp
    1a41:	pop    rbp
    1a42:	ret
    1a43:	mov    QWORD PTR [rsp+0x20],rax
    1a48:	mov    rax,QWORD PTR [rsp+0x20]
    1a4d:	mov    rbx,QWORD PTR [rsp+0x30]
    1a52:	mov    r12,QWORD PTR [rsp+0x38]
    1a57:	mov    r13,QWORD PTR [rsp+0x40]
    1a5c:	mov    r14,QWORD PTR [rsp+0x48]
    1a61:	mov    r15,QWORD PTR [rsp+0x50]
    1a66:	add    rsp,0x60
    1a6a:	mov    rsp,rbp
    1a6d:	pop    rbp
    1a6e:	ret

0000000000001a6f <botlish_entry_15: esc_char<generic>>:
    1a6f:	push   rbp
    1a70:	mov    rbp,rsp
    1a73:	mov    rsi,QWORD PTR [rdx]
    1a76:	mov    r8,QWORD PTR [rdx+0x8]
    1a7a:	mov    rcx,QWORD PTR [rdx+0x10]
    1a7e:	mov    rdx,r8
    1a81:	call   1a86 <botlish_entry_15+0x17>
			1a82: R_X86_64_PLT32	botlish_fn_15-0x4 ; esc_char<generic>
    1a86:	mov    rsp,rbp
    1a89:	pop    rbp
    1a8a:	ret
    1a8b:	add    BYTE PTR [rax],al
    1a8d:	add    BYTE PTR [rax],al
	...

0000000000001a90 <botlish_fn_16: esc_from<generic>>:
    1a90:	push   rbp
    1a91:	mov    rbp,rsp
    1a94:	sub    rsp,0x80
    1a9b:	mov    QWORD PTR [rsp+0x50],rbx
    1aa0:	mov    QWORD PTR [rsp+0x58],r12
    1aa5:	mov    QWORD PTR [rsp+0x60],r13
    1aaa:	mov    QWORD PTR [rsp+0x68],r14
    1aaf:	mov    QWORD PTR [rsp+0x70],r15
    1ab4:	mov    r14,rdi
    1ab7:	mov    QWORD PTR [rsp+0x30],0x0
    1ac0:	mov    QWORD PTR [rsp],rsi
    1ac4:	mov    QWORD PTR [rsp+0x8],rdx
    1ac9:	mov    QWORD PTR [rsp+0x10],rcx
    1ace:	mov    QWORD PTR [rsp+0x18],r8
    1ad3:	mov    r13,r8
    1ad6:	mov    QWORD PTR [rsp+0x20],r9
    1adb:	mov    r12,r9
    1ade:	mov    r15,rcx
    1ae1:	mov    QWORD PTR [rsp+0x38],rdx
    1ae6:	xor    eax,eax
    1ae8:	test   rsi,0x7
    1aef:	jne    1afe <botlish_fn_16+0x6e>
    1af5:	movzx  rax,BYTE PTR [rsi]
    1af9:	cmp    al,0x2
    1afb:	sete   al
    1afe:	test   al,al
    1b00:	jne    1b23 <botlish_fn_16+0x93>
    1b06:	mov    rdi,r14
    1b09:	mov    rax,QWORD PTR [rdi+0x10]
    1b0d:	mov    rcx,QWORD PTR [rax+0xf0]
    1b14:	mov    edx,0x1
    1b19:	call   1b1e <botlish_fn_16+0x8e>
			1b1a: R_X86_64_PLT32	rt_type_error-0x4
    1b1e:	jmp    1d7b <botlish_fn_16+0x2eb>
    1b23:	mov    rbx,rsi
    1b26:	mov    rdi,r14
    1b29:	call   1b2e <botlish_fn_16+0x9e>
			1b2a: R_X86_64_PLT32	rt_str_len-0x4
    1b2e:	mov    edx,0x1
    1b33:	mov    QWORD PTR [rsp+0x48],rdx
    1b38:	mov    ecx,0x1
    1b3d:	mov    rsi,QWORD PTR [rsp+0x38]
    1b42:	test   rsi,0x1
    1b49:	jne    1b73 <botlish_fn_16+0xe3>
    1b4f:	xor    ecx,ecx
    1b51:	mov    rsi,QWORD PTR [rsp+0x38]
    1b56:	test   rsi,0x7
    1b5d:	jne    1b73 <botlish_fn_16+0xe3>
    1b63:	mov    rsi,QWORD PTR [rsp+0x38]
    1b68:	movzx  rcx,BYTE PTR [rsi]
    1b6c:	rex cmp cl,0x1
    1b70:	sete   cl
    1b73:	test   cl,cl
    1b75:	jne    1b9b <botlish_fn_16+0x10b>
    1b7b:	mov    rdi,r14
    1b7e:	mov    rax,QWORD PTR [rdi+0x10]
    1b82:	mov    rcx,QWORD PTR [rax+0xb0]
    1b89:	xor    rdx,rdx
    1b8c:	mov    rsi,QWORD PTR [rsp+0x38]
    1b91:	call   1b96 <botlish_fn_16+0x106>
			1b92: R_X86_64_PLT32	rt_type_error-0x4
    1b96:	jmp    1d7b <botlish_fn_16+0x2eb>
    1b9b:	mov    rsi,QWORD PTR [rsp+0x38]
    1ba0:	mov    rcx,rsi
    1ba3:	and    rcx,rax
    1ba6:	mov    rdx,rax
    1ba9:	test   rcx,0x1
    1bb0:	jne    1bd8 <botlish_fn_16+0x148>
    1bb6:	mov    rsi,QWORD PTR [rsp+0x38]
    1bbb:	mov    rdi,r14
    1bbe:	call   1bc3 <botlish_fn_16+0x133>
			1bbf: R_X86_64_PLT32	rt_int_cmp-0x4
    1bc3:	mov    ecx,0x2
    1bc8:	test   rax,rax
    1bcb:	cmovge rcx,QWORD PTR [rip+0x235]        # 1e08 <botlish_fn_16+0x378>
    1bd3:	jmp    1bed <botlish_fn_16+0x15d>
    1bd8:	mov    ecx,0x2
    1bdd:	mov    rsi,QWORD PTR [rsp+0x38]
    1be2:	cmp    rsi,rdx
    1be5:	cmovge rcx,QWORD PTR [rip+0x21b]        # 1e08 <botlish_fn_16+0x378>
    1bed:	cmp    rcx,0x6
    1bf1:	je     1dd9 <botlish_fn_16+0x349>
    1bf7:	mov    QWORD PTR [rsp+0x28],0x3
    1c00:	mov    rsi,QWORD PTR [rsp+0x38]
    1c05:	test   rsi,0x1
    1c0c:	je     1c29 <botlish_fn_16+0x199>
    1c12:	mov    rsi,QWORD PTR [rsp+0x38]
    1c17:	mov    rax,rsi
    1c1a:	add    rax,0x2
    1c1e:	seto   cl
    1c21:	test   cl,cl
    1c23:	je     1c3b <botlish_fn_16+0x1ab>
    1c29:	mov    edx,0x3
    1c2e:	mov    rsi,QWORD PTR [rsp+0x38]
    1c33:	mov    rdi,r14
    1c36:	call   1c3b <botlish_fn_16+0x1ab>
			1c37: R_X86_64_PLT32	rt_int_add-0x4
    1c3b:	mov    QWORD PTR [rsp+0x28],rax
    1c40:	mov    QWORD PTR [rsp+0x40],rax
    1c45:	mov    QWORD PTR [rsp+0x30],0x3
    1c4e:	mov    rsi,QWORD PTR [rsp+0x38]
    1c53:	test   rsi,0x1
    1c5a:	je     1c77 <botlish_fn_16+0x1e7>
    1c60:	mov    rsi,QWORD PTR [rsp+0x38]
    1c65:	mov    rcx,rsi
    1c68:	add    rcx,0x2
    1c6c:	seto   al
    1c6f:	test   al,al
    1c71:	je     1c8c <botlish_fn_16+0x1fc>
    1c77:	mov    edx,0x3
    1c7c:	mov    rsi,QWORD PTR [rsp+0x38]
    1c81:	mov    rdi,r14
    1c84:	call   1c89 <botlish_fn_16+0x1f9>
			1c85: R_X86_64_PLT32	rt_int_add-0x4
    1c89:	mov    rcx,rax
    1c8c:	mov    QWORD PTR [rsp+0x30],rcx
    1c91:	mov    rdx,QWORD PTR [rsp+0x38]
    1c96:	mov    rsi,rbx
    1c99:	mov    rdi,r14
    1c9c:	call   1ca1 <botlish_fn_16+0x211>
			1c9d: R_X86_64_PLT32	rt_substr-0x4
    1ca1:	test   rax,rax
    1ca4:	je     1d7b <botlish_fn_16+0x2eb>
    1caa:	mov    QWORD PTR [rsp+0x8],rax
    1caf:	mov    r8,r12
    1cb2:	mov    r12,r13
    1cb5:	mov    r13,r8
    1cb8:	mov    rsi,rax
    1cbb:	mov    rcx,r13
    1cbe:	mov    rdx,r12
    1cc1:	mov    rdi,r14
    1cc4:	call   1cc9 <botlish_fn_16+0x239>
			1cc5: R_X86_64_PLT32	botlish_fn_15-0x4 ; esc_char<generic>
    1cc9:	test   rax,rax
    1ccc:	je     1d7b <botlish_fn_16+0x2eb>
    1cd2:	mov    QWORD PTR [rsp+0x8],rax
    1cd7:	xor    ecx,ecx
    1cd9:	mov    rsi,r15
    1cdc:	test   rsi,0x7
    1ce3:	jne    1cf4 <botlish_fn_16+0x264>
    1ce9:	movzx  rdi,BYTE PTR [rsi]
    1ced:	cmp    dil,0x2
    1cf1:	sete   cl
    1cf4:	test   cl,cl
    1cf6:	jne    1d19 <botlish_fn_16+0x289>
    1cfc:	mov    rdi,r14
    1cff:	mov    r11,QWORD PTR [rdi+0x10]
    1d03:	mov    rcx,QWORD PTR [r11+0xe0]
    1d0a:	mov    rdx,QWORD PTR [rsp+0x48]
    1d0f:	call   1d14 <botlish_fn_16+0x284>
			1d10: R_X86_64_PLT32	rt_type_error-0x4
    1d14:	jmp    1d7b <botlish_fn_16+0x2eb>
    1d19:	mov    rdx,QWORD PTR [rsp+0x48]
    1d1e:	xor    edi,edi
    1d20:	test   rax,0x7
    1d26:	je     1d34 <botlish_fn_16+0x2a4>
    1d2c:	mov    r8,rax
    1d2f:	jmp    1d43 <botlish_fn_16+0x2b3>
    1d34:	movzx  rcx,BYTE PTR [rax]
    1d38:	mov    r8,rax
    1d3b:	rex cmp cl,0x2
    1d3f:	sete   dil
    1d43:	test   dil,dil
    1d46:	jne    1d67 <botlish_fn_16+0x2d7>
    1d4c:	mov    rdi,r14
    1d4f:	mov    rax,QWORD PTR [rdi+0x10]
    1d53:	mov    rcx,QWORD PTR [rax+0xe0]
    1d5a:	mov    rsi,r8
    1d5d:	call   1d62 <botlish_fn_16+0x2d2>
			1d5e: R_X86_64_PLT32	rt_type_error-0x4
    1d62:	jmp    1d7b <botlish_fn_16+0x2eb>
    1d67:	mov    rdx,r8
    1d6a:	mov    rdi,r14
    1d6d:	call   1d72 <botlish_fn_16+0x2e2>
			1d6e: R_X86_64_PLT32	rt_str_cat-0x4
    1d72:	test   rax,rax
    1d75:	jne    1da3 <botlish_fn_16+0x313>
    1d7b:	xor    rax,rax
    1d7e:	mov    rbx,QWORD PTR [rsp+0x50]
    1d83:	mov    r12,QWORD PTR [rsp+0x58]
    1d88:	mov    r13,QWORD PTR [rsp+0x60]
    1d8d:	mov    r14,QWORD PTR [rsp+0x68]
    1d92:	mov    r15,QWORD PTR [rsp+0x70]
    1d97:	add    rsp,0x80
    1d9e:	mov    rsp,rbp
    1da1:	pop    rbp
    1da2:	ret
    1da3:	mov    QWORD PTR [rsp],rbx
    1da7:	mov    rcx,QWORD PTR [rsp+0x40]
    1dac:	mov    QWORD PTR [rsp+0x8],rcx
    1db1:	mov    QWORD PTR [rsp+0x10],rax
    1db6:	mov    QWORD PTR [rsp+0x18],r12
    1dbb:	mov    QWORD PTR [rsp+0x20],r13
    1dc0:	mov    QWORD PTR [rsp+0x38],rcx
    1dc5:	mov    r15,rax
    1dc8:	mov    rdx,r12
    1dcb:	mov    r12,r13
    1dce:	mov    r13,rdx
    1dd1:	mov    rsi,rbx
    1dd4:	jmp    1ae6 <botlish_fn_16+0x56>
    1dd9:	mov    rax,r15
    1ddc:	mov    rbx,QWORD PTR [rsp+0x50]
    1de1:	mov    r12,QWORD PTR [rsp+0x58]
    1de6:	mov    r13,QWORD PTR [rsp+0x60]
    1deb:	mov    r14,QWORD PTR [rsp+0x68]
    1df0:	mov    r15,QWORD PTR [rsp+0x70]
    1df5:	add    rsp,0x80
    1dfc:	mov    rsp,rbp
    1dff:	pop    rbp
    1e00:	ret
    1e01:	add    BYTE PTR [rax],al
    1e03:	add    BYTE PTR [rax],al
    1e05:	add    BYTE PTR [rax],al
    1e07:	add    BYTE PTR [rsi],al
    1e09:	add    BYTE PTR [rax],al
    1e0b:	add    BYTE PTR [rax],al
    1e0d:	add    BYTE PTR [rax],al
	...

0000000000001e10 <botlish_entry_16: esc_from<generic>>:
    1e10:	push   rbp
    1e11:	mov    rbp,rsp
    1e14:	mov    rsi,QWORD PTR [rdx]
    1e17:	mov    r10,QWORD PTR [rdx+0x8]
    1e1b:	mov    rcx,QWORD PTR [rdx+0x10]
    1e1f:	mov    r8,QWORD PTR [rdx+0x18]
    1e23:	mov    r9,QWORD PTR [rdx+0x20]
    1e27:	mov    rdx,r10
    1e2a:	call   1e2f <botlish_entry_16+0x1f>
			1e2b: R_X86_64_PLT32	botlish_fn_16-0x4 ; esc_from<generic>
    1e2f:	mov    rsp,rbp
    1e32:	pop    rbp
    1e33:	ret
    1e34:	add    BYTE PTR [rax],al
	...

0000000000001e38 <botlish_fn_17: check<int, int, str, str>>:
    1e38:	push   rbp
    1e39:	mov    rbp,rsp
    1e3c:	sub    rsp,0x60
    1e40:	mov    QWORD PTR [rsp+0x30],rbx
    1e45:	mov    QWORD PTR [rsp+0x38],r12
    1e4a:	mov    QWORD PTR [rsp+0x40],r13
    1e4f:	mov    QWORD PTR [rsp+0x48],r14
    1e54:	mov    QWORD PTR [rsp+0x50],r15
    1e59:	mov    QWORD PTR [rsp+0x20],0x0
    1e62:	mov    QWORD PTR [rsp],rsi
    1e66:	mov    QWORD PTR [rsp+0x8],rdx
    1e6b:	mov    QWORD PTR [rsp+0x10],rcx
    1e70:	mov    r12,rcx
    1e73:	mov    QWORD PTR [rsp+0x18],r8
    1e78:	mov    r14,r8
    1e7b:	mov    r13,rsi
    1e7e:	mov    r15,rdx
    1e81:	test   r13,0x1
    1e88:	jne    1eb3 <botlish_fn_17+0x7b>
    1e8e:	mov    edx,0x1
    1e93:	mov    rbx,rdi
    1e96:	mov    rsi,r13
    1e99:	call   1e9e <botlish_fn_17+0x66>
			1e9a: R_X86_64_PLT32	rt_int_cmp-0x4
    1e9e:	mov    ecx,0x2
    1ea3:	test   rax,rax
    1ea6:	cmovle rcx,QWORD PTR [rip+0x152]        # 2000 <botlish_fn_17+0x1c8>
    1eae:	jmp    1ec7 <botlish_fn_17+0x8f>
    1eb3:	mov    rbx,rdi
    1eb6:	mov    ecx,0x2
    1ebb:	cmp    r13,0x1
    1ebf:	cmovle rcx,QWORD PTR [rip+0x139]        # 2000 <botlish_fn_17+0x1c8>
    1ec7:	cmp    rcx,0x6
    1ecb:	je     1fd4 <botlish_fn_17+0x19c>
    1ed1:	mov    rax,QWORD PTR [rbx+0x10]
    1ed5:	mov    rax,QWORD PTR [rax+0xf8]
    1edc:	mov    rsi,r12
    1edf:	mov    rdi,rbx
    1ee2:	call   1ee7 <botlish_fn_17+0xaf>
			1ee3: R_X86_64_PLT32	botlish_fn_18-0x4 ; <str>
    1ee7:	test   rax,rax
    1eea:	je     1f2b <botlish_fn_17+0xf3>
    1ef0:	cmp    rax,0x6
    1ef4:	je     1f0c <botlish_fn_17+0xd4>
    1efa:	mov    edx,0x1
    1eff:	mov    QWORD PTR [rsp],0x1
    1f07:	jmp    1f6d <botlish_fn_17+0x135>
    1f0c:	mov    rax,QWORD PTR [rbx+0x10]
    1f10:	mov    rax,QWORD PTR [rax+0x100]
    1f17:	mov    rsi,r12
    1f1a:	mov    rdi,rbx
    1f1d:	call   1f22 <botlish_fn_17+0xea>
			1f1e: R_X86_64_PLT32	botlish_fn_26-0x4 ; <str>
    1f22:	test   rax,rax
    1f25:	jne    1f50 <botlish_fn_17+0x118>
    1f2b:	xor    rax,rax
    1f2e:	mov    rbx,QWORD PTR [rsp+0x30]
    1f33:	mov    r12,QWORD PTR [rsp+0x38]
    1f38:	mov    r13,QWORD PTR [rsp+0x40]
    1f3d:	mov    r14,QWORD PTR [rsp+0x48]
    1f42:	mov    r15,QWORD PTR [rsp+0x50]
    1f47:	add    rsp,0x60
    1f4b:	mov    rsp,rbp
    1f4e:	pop    rbp
    1f4f:	ret
    1f50:	cmp    rax,0x6
    1f54:	je     1f64 <botlish_fn_17+0x12c>
    1f5a:	mov    edx,0x1
    1f5f:	jmp    1f69 <botlish_fn_17+0x131>
    1f64:	mov    edx,0x3
    1f69:	mov    QWORD PTR [rsp],rdx
    1f6d:	sar    r13,1
    1f70:	sub    r13,0x1
    1f74:	shl    r13,1
    1f77:	or     r13,0x1
    1f7b:	mov    QWORD PTR [rsp+0x20],r13
    1f80:	mov    rsi,r15
    1f83:	mov    r8,rsi
    1f86:	and    r8,rdx
    1f89:	test   r8,0x1
    1f90:	je     1fab <botlish_fn_17+0x173>
    1f96:	lea    r11,[rdx-0x1]
    1f9a:	mov    rax,rsi
    1f9d:	add    rax,r11
    1fa0:	seto   cl
    1fa3:	test   cl,cl
    1fa5:	je     1fb3 <botlish_fn_17+0x17b>
    1fab:	mov    rdi,rbx
    1fae:	call   1fb3 <botlish_fn_17+0x17b>
			1faf: R_X86_64_PLT32	rt_int_add-0x4
    1fb3:	mov    QWORD PTR [rsp],r13
    1fb7:	mov    QWORD PTR [rsp+0x8],rax
    1fbc:	mov    QWORD PTR [rsp+0x10],r12
    1fc1:	mov    r8,r14
    1fc4:	mov    QWORD PTR [rsp+0x18],r8
    1fc9:	mov    rdi,rbx
    1fcc:	mov    r15,rax
    1fcf:	jmp    1e81 <botlish_fn_17+0x49>
    1fd4:	mov    rax,r15
    1fd7:	mov    rbx,QWORD PTR [rsp+0x30]
    1fdc:	mov    r12,QWORD PTR [rsp+0x38]
    1fe1:	mov    r13,QWORD PTR [rsp+0x40]
    1fe6:	mov    r14,QWORD PTR [rsp+0x48]
    1feb:	mov    r15,QWORD PTR [rsp+0x50]
    1ff0:	add    rsp,0x60
    1ff4:	mov    rsp,rbp
    1ff7:	pop    rbp
    1ff8:	ret
    1ff9:	add    BYTE PTR [rax],al
    1ffb:	add    BYTE PTR [rax],al
    1ffd:	add    BYTE PTR [rax],al
    1fff:	add    BYTE PTR [rsi],al
    2001:	add    BYTE PTR [rax],al
    2003:	add    BYTE PTR [rax],al
    2005:	add    BYTE PTR [rax],al
	...

0000000000002008 <botlish_entry_17: check<int, int, str, str>>:
    2008:	push   rbp
    2009:	mov    rbp,rsp
    200c:	mov    rsi,QWORD PTR [rdx]
    200f:	mov    r9,QWORD PTR [rdx+0x8]
    2013:	mov    rcx,QWORD PTR [rdx+0x10]
    2017:	mov    r8,QWORD PTR [rdx+0x18]
    201b:	mov    rdx,r9
    201e:	call   2023 <botlish_entry_17+0x1b>
			201f: R_X86_64_PLT32	botlish_fn_17-0x4 ; check<int, int, str, str>
    2023:	mov    rsp,rbp
    2026:	pop    rbp
    2027:	ret

0000000000002028 <botlish_fn_18: <str>>:
    2028:	push   rbp
    2029:	mov    rbp,rsp
    202c:	sub    rsp,0x50
    2030:	mov    QWORD PTR [rsp+0x30],rbx
    2035:	mov    QWORD PTR [rsp+0x38],r12
    203a:	mov    QWORD PTR [rsp+0x40],r13
    203f:	mov    QWORD PTR [rsp+0x48],r14
    2044:	mov    r13,rdi
    2047:	mov    QWORD PTR [rsp+0x18],0x0
    2050:	mov    QWORD PTR [rsp],rsi
    2054:	mov    r14,rsi
    2057:	mov    rsi,r14
    205a:	mov    rdi,r13
    205d:	call   2062 <botlish_fn_18+0x3a>
			205e: R_X86_64_PLT32	rt_str_len-0x4
    2062:	mov    rbx,rax
    2065:	mov    QWORD PTR [rsp+0x8],rax
    206a:	mov    esi,0x1
    206f:	mov    QWORD PTR [rsp+0x10],0x1
    2078:	mov    rcx,r14
    207b:	mov    rdx,rbx
    207e:	mov    rdi,r13
    2081:	call   2086 <botlish_fn_18+0x5e>
			2082: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_local<generic>
    2086:	mov    r12,rax
    2089:	test   r12,r12
    208c:	je     21e9 <botlish_fn_18+0x1c1>
    2092:	mov    QWORD PTR [rsp+0x10],r12
    2097:	test   r12,0x1
    209e:	jne    20c9 <botlish_fn_18+0xa1>
    20a4:	mov    edx,0x1
    20a9:	mov    rsi,r12
    20ac:	mov    rdi,r13
    20af:	call   20b4 <botlish_fn_18+0x8c>
			20b0: R_X86_64_PLT32	rt_int_cmp-0x4
    20b4:	mov    ecx,0x2
    20b9:	test   rax,rax
    20bc:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 2288 <botlish_fn_18+0x260>
    20c4:	jmp    20da <botlish_fn_18+0xb2>
    20c9:	mov    ecx,0x2
    20ce:	cmp    r12,0x1
    20d2:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 2288 <botlish_fn_18+0x260>
    20da:	cmp    rcx,0x6
    20de:	je     2264 <botlish_fn_18+0x23c>
    20e4:	mov    rcx,r12
    20e7:	and    rcx,rbx
    20ea:	test   rcx,0x1
    20f1:	jne    211a <botlish_fn_18+0xf2>
    20f7:	mov    rdx,rbx
    20fa:	mov    rsi,r12
    20fd:	mov    rdi,r13
    2100:	call   2105 <botlish_fn_18+0xdd>
			2101: R_X86_64_PLT32	rt_int_cmp-0x4
    2105:	mov    ecx,0x2
    210a:	test   rax,rax
    210d:	cmovge rcx,QWORD PTR [rip+0x173]        # 2288 <botlish_fn_18+0x260>
    2115:	jmp    212a <botlish_fn_18+0x102>
    211a:	mov    ecx,0x2
    211f:	cmp    r12,rbx
    2122:	cmovge rcx,QWORD PTR [rip+0x15e]        # 2288 <botlish_fn_18+0x260>
    212a:	cmp    rcx,0x6
    212e:	je     225a <botlish_fn_18+0x232>
    2134:	lea    rcx,[rsp+0x20]
    2139:	mov    rdx,r14
    213c:	mov    rsi,r12
    213f:	mov    rdi,r13
    2142:	call   2147 <botlish_fn_18+0x11f>
			2143: R_X86_64_PLT32	botlish_fn_20-0x4 ; char_at<generic>
    2147:	test   rax,rax
    214a:	mov    rsi,rax
    214d:	je     21e9 <botlish_fn_18+0x1c1>
    2153:	mov    rdx,QWORD PTR [rsp+0x20]
    2158:	mov    rcx,QWORD PTR [rsp+0x28]
    215d:	mov    rdi,r13
    2160:	mov    rax,QWORD PTR [rdi+0x10]
    2164:	mov    r8,QWORD PTR [rax+0x118]
    216b:	call   2170 <botlish_fn_18+0x148>
			216c: R_X86_64_PLT32	rt_str_region_eq-0x4
    2170:	cmp    rax,0x6
    2174:	je     2187 <botlish_fn_18+0x15f>
    217a:	mov    ecx,0x2
    217f:	mov    rax,rcx
    2182:	jmp    2269 <botlish_fn_18+0x241>
    2187:	mov    QWORD PTR [rsp+0x18],0x3
    2190:	test   r12,0x1
    2197:	jne    21a5 <botlish_fn_18+0x17d>
    219d:	mov    rcx,r12
    21a0:	jmp    21ba <botlish_fn_18+0x192>
    21a5:	mov    rsi,r12
    21a8:	add    rsi,0x2
    21ac:	mov    rcx,r12
    21af:	seto   al
    21b2:	test   al,al
    21b4:	je     21cd <botlish_fn_18+0x1a5>
    21ba:	mov    edx,0x3
    21bf:	mov    rsi,rcx
    21c2:	mov    rdi,r13
    21c5:	call   21ca <botlish_fn_18+0x1a2>
			21c6: R_X86_64_PLT32	rt_int_add-0x4
    21ca:	mov    rsi,rax
    21cd:	mov    QWORD PTR [rsp+0x10],rsi
    21d2:	mov    rcx,r14
    21d5:	mov    rdx,rbx
    21d8:	mov    rdi,r13
    21db:	call   21e0 <botlish_fn_18+0x1b8>
			21dc: R_X86_64_PLT32	botlish_fn_25-0x4 ; domain_loop<generic>
    21e0:	test   rax,rax
    21e3:	jne    2209 <botlish_fn_18+0x1e1>
    21e9:	xor    rax,rax
    21ec:	mov    rbx,QWORD PTR [rsp+0x30]
    21f1:	mov    r12,QWORD PTR [rsp+0x38]
    21f6:	mov    r13,QWORD PTR [rsp+0x40]
    21fb:	mov    r14,QWORD PTR [rsp+0x48]
    2200:	add    rsp,0x50
    2204:	mov    rsp,rbp
    2207:	pop    rbp
    2208:	ret
    2209:	mov    rcx,rax
    220c:	and    rcx,rbx
    220f:	mov    rsi,rax
    2212:	test   rcx,0x1
    2219:	jne    2242 <botlish_fn_18+0x21a>
    221f:	mov    rdx,rbx
    2222:	mov    rdi,r13
    2225:	call   222a <botlish_fn_18+0x202>
			2226: R_X86_64_PLT32	rt_int_cmp-0x4
    222a:	mov    ecx,0x2
    222f:	test   rax,rax
    2232:	mov    rax,rcx
    2235:	cmove  rax,QWORD PTR [rip+0x4b]        # 2288 <botlish_fn_18+0x260>
    223d:	jmp    2269 <botlish_fn_18+0x241>
    2242:	mov    rdx,rbx
    2245:	mov    eax,0x2
    224a:	cmp    rsi,rdx
    224d:	cmove  rax,QWORD PTR [rip+0x33]        # 2288 <botlish_fn_18+0x260>
    2255:	jmp    2269 <botlish_fn_18+0x241>
    225a:	mov    eax,0x2
    225f:	jmp    2269 <botlish_fn_18+0x241>
    2264:	mov    eax,0x2
    2269:	mov    rbx,QWORD PTR [rsp+0x30]
    226e:	mov    r12,QWORD PTR [rsp+0x38]
    2273:	mov    r13,QWORD PTR [rsp+0x40]
    2278:	mov    r14,QWORD PTR [rsp+0x48]
    227d:	add    rsp,0x50
    2281:	mov    rsp,rbp
    2284:	pop    rbp
    2285:	ret
    2286:	add    BYTE PTR [rax],al
    2288:	(bad)
    2289:	add    BYTE PTR [rax],al
    228b:	add    BYTE PTR [rax],al
    228d:	add    BYTE PTR [rax],al
	...

0000000000002290 <botlish_entry_18: <str>>:
    2290:	push   rbp
    2291:	mov    rbp,rsp
    2294:	mov    rsi,QWORD PTR [rdx]
    2297:	call   229c <botlish_entry_18+0xc>
			2298: R_X86_64_PLT32	botlish_fn_18-0x4 ; <str>
    229c:	mov    rsp,rbp
    229f:	pop    rbp
    22a0:	ret
    22a1:	add    BYTE PTR [rax],al
    22a3:	add    BYTE PTR [rax],al
    22a5:	add    BYTE PTR [rax],al
	...

00000000000022a8 <botlish_fn_19: <generic>>:
    22a8:	push   rbp
    22a9:	mov    rbp,rsp
    22ac:	sub    rsp,0x60
    22b0:	mov    QWORD PTR [rsp+0x30],rbx
    22b5:	mov    QWORD PTR [rsp+0x38],r12
    22ba:	mov    QWORD PTR [rsp+0x40],r13
    22bf:	mov    QWORD PTR [rsp+0x48],r14
    22c4:	mov    QWORD PTR [rsp+0x50],r15
    22c9:	mov    QWORD PTR [rsp+0x18],0x0
    22d2:	mov    QWORD PTR [rsp],rsi
    22d6:	xor    r8d,r8d
    22d9:	test   rsi,0x7
    22e0:	jne    22f0 <botlish_fn_19+0x48>
    22e6:	movzx  rax,BYTE PTR [rsi]
    22ea:	cmp    al,0x2
    22ec:	sete   r8b
    22f0:	test   r8b,r8b
    22f3:	jne    2313 <botlish_fn_19+0x6b>
    22f9:	mov    rdx,QWORD PTR [rdi+0x10]
    22fd:	mov    rcx,QWORD PTR [rdx+0xf0]
    2304:	mov    edx,0x1
    2309:	call   230e <botlish_fn_19+0x66>
			230a: R_X86_64_PLT32	rt_type_error-0x4
    230e:	jmp    24a8 <botlish_fn_19+0x200>
    2313:	mov    r13,rsi
    2316:	mov    r14,rdi
    2319:	call   231e <botlish_fn_19+0x76>
			231a: R_X86_64_PLT32	rt_str_len-0x4
    231e:	mov    rbx,rax
    2321:	mov    QWORD PTR [rsp+0x8],rax
    2326:	mov    edx,0x1
    232b:	mov    r15,rdx
    232e:	mov    QWORD PTR [rsp+0x10],0x1
    2337:	mov    rcx,r13
    233a:	mov    rdx,rbx
    233d:	mov    rsi,r15
    2340:	mov    rdi,r14
    2343:	call   2348 <botlish_fn_19+0xa0>
			2344: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_local<generic>
    2348:	mov    r12,rax
    234b:	test   r12,r12
    234e:	je     24a8 <botlish_fn_19+0x200>
    2354:	mov    QWORD PTR [rsp+0x10],r12
    2359:	test   r12,0x1
    2360:	jne    2389 <botlish_fn_19+0xe1>
    2366:	mov    rdx,r15
    2369:	mov    rsi,r12
    236c:	mov    rdi,r14
    236f:	call   2374 <botlish_fn_19+0xcc>
			2370: R_X86_64_PLT32	rt_int_cmp-0x4
    2374:	mov    ecx,0x2
    2379:	test   rax,rax
    237c:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 2550 <botlish_fn_19+0x2a8>
    2384:	jmp    239a <botlish_fn_19+0xf2>
    2389:	mov    ecx,0x2
    238e:	cmp    r12,0x1
    2392:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 2550 <botlish_fn_19+0x2a8>
    239a:	cmp    rcx,0x6
    239e:	je     2528 <botlish_fn_19+0x280>
    23a4:	mov    rax,r12
    23a7:	and    rax,rbx
    23aa:	test   rax,0x1
    23b0:	jne    23d9 <botlish_fn_19+0x131>
    23b6:	mov    rdx,rbx
    23b9:	mov    rsi,r12
    23bc:	mov    rdi,r14
    23bf:	call   23c4 <botlish_fn_19+0x11c>
			23c0: R_X86_64_PLT32	rt_int_cmp-0x4
    23c4:	mov    ecx,0x2
    23c9:	test   rax,rax
    23cc:	cmovge rcx,QWORD PTR [rip+0x17c]        # 2550 <botlish_fn_19+0x2a8>
    23d4:	jmp    23e9 <botlish_fn_19+0x141>
    23d9:	mov    ecx,0x2
    23de:	cmp    r12,rbx
    23e1:	cmovge rcx,QWORD PTR [rip+0x167]        # 2550 <botlish_fn_19+0x2a8>
    23e9:	cmp    rcx,0x6
    23ed:	je     251e <botlish_fn_19+0x276>
    23f3:	lea    rcx,[rsp+0x20]
    23f8:	mov    rdx,r13
    23fb:	mov    rsi,r12
    23fe:	mov    rdi,r14
    2401:	call   2406 <botlish_fn_19+0x15e>
			2402: R_X86_64_PLT32	botlish_fn_20-0x4 ; char_at<generic>
    2406:	test   rax,rax
    2409:	mov    rsi,rax
    240c:	je     24a8 <botlish_fn_19+0x200>
    2412:	mov    rdx,QWORD PTR [rsp+0x20]
    2417:	mov    rcx,QWORD PTR [rsp+0x28]
    241c:	mov    rdi,r14
    241f:	mov    rax,QWORD PTR [rdi+0x10]
    2423:	mov    r8,QWORD PTR [rax+0x118]
    242a:	call   242f <botlish_fn_19+0x187>
			242b: R_X86_64_PLT32	rt_str_region_eq-0x4
    242f:	cmp    rax,0x6
    2433:	je     2446 <botlish_fn_19+0x19e>
    2439:	mov    ecx,0x2
    243e:	mov    rax,rcx
    2441:	jmp    252d <botlish_fn_19+0x285>
    2446:	mov    QWORD PTR [rsp+0x18],0x3
    244f:	test   r12,0x1
    2456:	jne    2464 <botlish_fn_19+0x1bc>
    245c:	mov    rdi,r12
    245f:	jmp    2479 <botlish_fn_19+0x1d1>
    2464:	mov    rsi,r12
    2467:	add    rsi,0x2
    246b:	mov    rdi,r12
    246e:	seto   al
    2471:	test   al,al
    2473:	je     248c <botlish_fn_19+0x1e4>
    2479:	mov    edx,0x3
    247e:	mov    rsi,rdi
    2481:	mov    rdi,r14
    2484:	call   2489 <botlish_fn_19+0x1e1>
			2485: R_X86_64_PLT32	rt_int_add-0x4
    2489:	mov    rsi,rax
    248c:	mov    QWORD PTR [rsp+0x10],rsi
    2491:	mov    rcx,r13
    2494:	mov    rdx,rbx
    2497:	mov    rdi,r14
    249a:	call   249f <botlish_fn_19+0x1f7>
			249b: R_X86_64_PLT32	botlish_fn_25-0x4 ; domain_loop<generic>
    249f:	test   rax,rax
    24a2:	jne    24cd <botlish_fn_19+0x225>
    24a8:	xor    rax,rax
    24ab:	mov    rbx,QWORD PTR [rsp+0x30]
    24b0:	mov    r12,QWORD PTR [rsp+0x38]
    24b5:	mov    r13,QWORD PTR [rsp+0x40]
    24ba:	mov    r14,QWORD PTR [rsp+0x48]
    24bf:	mov    r15,QWORD PTR [rsp+0x50]
    24c4:	add    rsp,0x60
    24c8:	mov    rsp,rbp
    24cb:	pop    rbp
    24cc:	ret
    24cd:	mov    rcx,rax
    24d0:	and    rcx,rbx
    24d3:	mov    rsi,rax
    24d6:	test   rcx,0x1
    24dd:	jne    2506 <botlish_fn_19+0x25e>
    24e3:	mov    rdx,rbx
    24e6:	mov    rdi,r14
    24e9:	call   24ee <botlish_fn_19+0x246>
			24ea: R_X86_64_PLT32	rt_int_cmp-0x4
    24ee:	mov    ecx,0x2
    24f3:	test   rax,rax
    24f6:	mov    rax,rcx
    24f9:	cmove  rax,QWORD PTR [rip+0x4f]        # 2550 <botlish_fn_19+0x2a8>
    2501:	jmp    252d <botlish_fn_19+0x285>
    2506:	mov    rdx,rbx
    2509:	mov    eax,0x2
    250e:	cmp    rsi,rdx
    2511:	cmove  rax,QWORD PTR [rip+0x37]        # 2550 <botlish_fn_19+0x2a8>
    2519:	jmp    252d <botlish_fn_19+0x285>
    251e:	mov    eax,0x2
    2523:	jmp    252d <botlish_fn_19+0x285>
    2528:	mov    eax,0x2
    252d:	mov    rbx,QWORD PTR [rsp+0x30]
    2532:	mov    r12,QWORD PTR [rsp+0x38]
    2537:	mov    r13,QWORD PTR [rsp+0x40]
    253c:	mov    r14,QWORD PTR [rsp+0x48]
    2541:	mov    r15,QWORD PTR [rsp+0x50]
    2546:	add    rsp,0x60
    254a:	mov    rsp,rbp
    254d:	pop    rbp
    254e:	ret
    254f:	add    BYTE PTR [rsi],al
    2551:	add    BYTE PTR [rax],al
    2553:	add    BYTE PTR [rax],al
    2555:	add    BYTE PTR [rax],al
	...

0000000000002558 <botlish_entry_19: <generic>>:
    2558:	push   rbp
    2559:	mov    rbp,rsp
    255c:	mov    rsi,QWORD PTR [rdx]
    255f:	call   2564 <botlish_entry_19+0xc>
			2560: R_X86_64_PLT32	botlish_fn_19-0x4 ; <generic>
    2564:	mov    rsp,rbp
    2567:	pop    rbp
    2568:	ret

0000000000002569 <botlish_fn_20: char_at<generic>>:
    2569:	push   rbp
    256a:	mov    rbp,rsp
    256d:	sub    rsp,0x50
    2571:	mov    QWORD PTR [rsp+0x20],rbx
    2576:	mov    QWORD PTR [rsp+0x28],r12
    257b:	mov    QWORD PTR [rsp+0x30],r13
    2580:	mov    QWORD PTR [rsp+0x38],r14
    2585:	mov    QWORD PTR [rsp+0x40],r15
    258a:	mov    r14,rcx
    258d:	mov    QWORD PTR [rsp],rsi
    2591:	mov    QWORD PTR [rsp+0x8],rdx
    2596:	mov    r13,rdx
    2599:	mov    QWORD PTR [rsp+0x10],0x3
    25a2:	mov    r9d,0x1
    25a8:	test   rsi,0x1
    25af:	jne    25cf <botlish_fn_20+0x66>
    25b5:	xor    r9d,r9d
    25b8:	test   rsi,0x7
    25bf:	jne    25cf <botlish_fn_20+0x66>
    25c5:	movzx  rax,BYTE PTR [rsi]
    25c9:	cmp    al,0x1
    25cb:	sete   r9b
    25cf:	test   r9b,r9b
    25d2:	jne    25f0 <botlish_fn_20+0x87>
    25d8:	mov    rax,QWORD PTR [rdi+0x10]
    25dc:	mov    rcx,QWORD PTR [rax+0x120]
    25e3:	xor    rdx,rdx
    25e6:	call   25eb <botlish_fn_20+0x82>
			25e7: R_X86_64_PLT32	rt_type_error-0x4
    25eb:	jmp    26ad <botlish_fn_20+0x144>
    25f0:	mov    r12,rdi
    25f3:	test   rsi,0x1
    25fa:	jne    2608 <botlish_fn_20+0x9f>
    2600:	mov    rbx,rsi
    2603:	jmp    2625 <botlish_fn_20+0xbc>
    2608:	mov    rax,rsi
    260b:	add    rax,0x2
    260f:	mov    rbx,rsi
    2612:	seto   cl
    2615:	test   cl,cl
    2617:	jne    2625 <botlish_fn_20+0xbc>
    261d:	mov    r15,rax
    2620:	jmp    2638 <botlish_fn_20+0xcf>
    2625:	mov    edx,0x3
    262a:	mov    rsi,rbx
    262d:	mov    rdi,r12
    2630:	call   2635 <botlish_fn_20+0xcc>
			2631: R_X86_64_PLT32	rt_int_add-0x4
    2635:	mov    r15,rax
    2638:	mov    ecx,0x1
    263d:	mov    rsi,rbx
    2640:	test   rsi,0x1
    2647:	jne    266d <botlish_fn_20+0x104>
    264d:	xor    ecx,ecx
    264f:	mov    rsi,rbx
    2652:	test   rsi,0x7
    2659:	jne    266d <botlish_fn_20+0x104>
    265f:	mov    rsi,rbx
    2662:	movzx  rcx,BYTE PTR [rsi]
    2666:	rex cmp cl,0x1
    266a:	sete   cl
    266d:	test   cl,cl
    266f:	jne    2693 <botlish_fn_20+0x12a>
    2675:	mov    rdi,r12
    2678:	mov    rsi,QWORD PTR [rdi+0x10]
    267c:	mov    rcx,QWORD PTR [rsi+0x128]
    2683:	xor    rdx,rdx
    2686:	mov    rsi,rbx
    2689:	call   268e <botlish_fn_20+0x125>
			268a: R_X86_64_PLT32	rt_type_error-0x4
    268e:	jmp    26ad <botlish_fn_20+0x144>
    2693:	mov    rdi,r12
    2696:	mov    rcx,r15
    2699:	mov    rdx,rbx
    269c:	mov    rsi,r13
    269f:	call   26a4 <botlish_fn_20+0x13b>
			26a0: R_X86_64_PLT32	rt_str_region_check-0x4
    26a4:	test   rax,rax
    26a7:	jne    26d2 <botlish_fn_20+0x169>
    26ad:	xor    rax,rax
    26b0:	mov    rbx,QWORD PTR [rsp+0x20]
    26b5:	mov    r12,QWORD PTR [rsp+0x28]
    26ba:	mov    r13,QWORD PTR [rsp+0x30]
    26bf:	mov    r14,QWORD PTR [rsp+0x38]
    26c4:	mov    r15,QWORD PTR [rsp+0x40]
    26c9:	add    rsp,0x50
    26cd:	mov    rsp,rbp
    26d0:	pop    rbp
    26d1:	ret
    26d2:	mov    rcx,r14
    26d5:	mov    rsi,rbx
    26d8:	mov    QWORD PTR [rcx],rsi
    26db:	mov    rax,r15
    26de:	mov    QWORD PTR [rcx+0x8],rax
    26e2:	mov    rax,r13
    26e5:	mov    rbx,QWORD PTR [rsp+0x20]
    26ea:	mov    r12,QWORD PTR [rsp+0x28]
    26ef:	mov    r13,QWORD PTR [rsp+0x30]
    26f4:	mov    r14,QWORD PTR [rsp+0x38]
    26f9:	mov    r15,QWORD PTR [rsp+0x40]
    26fe:	add    rsp,0x50
    2702:	mov    rsp,rbp
    2705:	pop    rbp
    2706:	ret

0000000000002707 <botlish_entry_20: char_at<generic>>:
    2707:	push   rbp
    2708:	mov    rbp,rsp
    270b:	ud2
    270d:	add    BYTE PTR [rax],al
	...

0000000000002710 <botlish_fn_21: scan_local<generic>>:
    2710:	push   rbp
    2711:	mov    rbp,rsp
    2714:	sub    rsp,0x80
    271b:	mov    QWORD PTR [rsp+0x50],rbx
    2720:	mov    QWORD PTR [rsp+0x58],r12
    2725:	mov    QWORD PTR [rsp+0x60],r13
    272a:	mov    QWORD PTR [rsp+0x68],r14
    272f:	mov    QWORD PTR [rsp+0x70],r15
    2734:	mov    rax,rdi
    2737:	mov    QWORD PTR [rsp+0x18],0x0
    2740:	mov    QWORD PTR [rsp],rsi
    2744:	mov    r14,rsi
    2747:	mov    QWORD PTR [rsp+0x8],rdx
    274c:	mov    QWORD PTR [rsp+0x10],rcx
    2751:	mov    r12,rcx
    2754:	mov    r11d,0x1
    275a:	mov    rsi,r14
    275d:	test   rsi,0x1
    2764:	jne    2786 <botlish_fn_21+0x76>
    276a:	xor    r11d,r11d
    276d:	test   rsi,0x7
    2774:	jne    2786 <botlish_fn_21+0x76>
    277a:	movzx  rdi,BYTE PTR [rsi]
    277e:	cmp    dil,0x1
    2782:	sete   r11b
    2786:	test   r11b,r11b
    2789:	jne    27aa <botlish_fn_21+0x9a>
    278f:	mov    rdi,rax
    2792:	mov    r9,QWORD PTR [rdi+0x10]
    2796:	mov    rcx,QWORD PTR [r9+0xb0]
    279d:	xor    rdx,rdx
    27a0:	call   27a5 <botlish_fn_21+0x95>
			27a1: R_X86_64_PLT32	rt_type_error-0x4
    27a5:	jmp    285d <botlish_fn_21+0x14d>
    27aa:	mov    r13,rdx
    27ad:	mov    r10,rsi
    27b0:	and    r10,r13
    27b3:	mov    r14,rsi
    27b6:	test   r10,0x1
    27bd:	jne    27e9 <botlish_fn_21+0xd9>
    27c3:	mov    rbx,rax
    27c6:	mov    rdx,r13
    27c9:	mov    rsi,r14
    27cc:	mov    rdi,rbx
    27cf:	call   27d4 <botlish_fn_21+0xc4>
			27d0: R_X86_64_PLT32	rt_int_cmp-0x4
    27d4:	mov    ecx,0x2
    27d9:	test   rax,rax
    27dc:	cmovge rcx,QWORD PTR [rip+0x24c]        # 2a30 <botlish_fn_21+0x320>
    27e4:	jmp    27ff <botlish_fn_21+0xef>
    27e9:	mov    rbx,rax
    27ec:	mov    ecx,0x2
    27f1:	mov    rsi,r14
    27f4:	cmp    rsi,r13
    27f7:	cmovge rcx,QWORD PTR [rip+0x231]        # 2a30 <botlish_fn_21+0x320>
    27ff:	mov    eax,0x6
    2804:	mov    QWORD PTR [rsp+0x30],rax
    2809:	cmp    rcx,0x6
    280d:	je     2a03 <botlish_fn_21+0x2f3>
    2813:	lea    rcx,[rsp+0x20]
    2818:	mov    rdx,r12
    281b:	mov    rsi,r14
    281e:	mov    rdi,rbx
    2821:	call   2826 <botlish_fn_21+0x116>
			2822: R_X86_64_PLT32	botlish_fn_20-0x4 ; char_at<generic>
    2826:	mov    rsi,rax
    2829:	mov    r15,rax
    282c:	test   rax,rsi
    282f:	je     285d <botlish_fn_21+0x14d>
    2835:	mov    rdx,QWORD PTR [rsp+0x20]
    283a:	mov    QWORD PTR [rsp+0x40],rdx
    283f:	mov    rcx,QWORD PTR [rsp+0x28]
    2844:	mov    QWORD PTR [rsp+0x38],rcx
    2849:	mov    rsi,r15
    284c:	mov    rdi,rbx
    284f:	call   2854 <botlish_fn_21+0x144>
			2850: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    2854:	test   rax,rax
    2857:	jne    2885 <botlish_fn_21+0x175>
    285d:	xor    rax,rax
    2860:	mov    rbx,QWORD PTR [rsp+0x50]
    2865:	mov    r12,QWORD PTR [rsp+0x58]
    286a:	mov    r13,QWORD PTR [rsp+0x60]
    286f:	mov    r14,QWORD PTR [rsp+0x68]
    2874:	mov    r15,QWORD PTR [rsp+0x70]
    2879:	add    rsp,0x80
    2880:	mov    rsp,rbp
    2883:	pop    rbp
    2884:	ret
    2885:	cmp    rax,0x6
    2889:	je     2984 <botlish_fn_21+0x274>
    288f:	mov    rax,QWORD PTR [rbx+0x10]
    2893:	mov    r8,QWORD PTR [rax+0x130]
    289a:	mov    rcx,QWORD PTR [rsp+0x38]
    289f:	mov    rdx,QWORD PTR [rsp+0x40]
    28a4:	mov    rsi,r15
    28a7:	mov    rdi,rbx
    28aa:	call   28af <botlish_fn_21+0x19f>
			28ab: R_X86_64_PLT32	rt_str_region_eq-0x4
    28af:	cmp    rax,0x6
    28b3:	je     297a <botlish_fn_21+0x26a>
    28b9:	mov    rax,QWORD PTR [rbx+0x10]
    28bd:	mov    r8,QWORD PTR [rax+0x138]
    28c4:	mov    rcx,QWORD PTR [rsp+0x38]
    28c9:	mov    rdx,QWORD PTR [rsp+0x40]
    28ce:	mov    rsi,r15
    28d1:	mov    rdi,rbx
    28d4:	call   28d9 <botlish_fn_21+0x1c9>
			28d5: R_X86_64_PLT32	rt_str_region_eq-0x4
    28d9:	cmp    rax,0x6
    28dd:	je     2970 <botlish_fn_21+0x260>
    28e3:	mov    rax,QWORD PTR [rbx+0x10]
    28e7:	mov    r8,QWORD PTR [rax+0xd8]
    28ee:	mov    rcx,QWORD PTR [rsp+0x38]
    28f3:	mov    rdx,QWORD PTR [rsp+0x40]
    28f8:	mov    rsi,r15
    28fb:	mov    rdi,rbx
    28fe:	call   2903 <botlish_fn_21+0x1f3>
			28ff: R_X86_64_PLT32	rt_str_region_eq-0x4
    2903:	cmp    rax,0x6
    2907:	je     2966 <botlish_fn_21+0x256>
    290d:	mov    rax,QWORD PTR [rbx+0x10]
    2911:	mov    r8,QWORD PTR [rax+0x120]
    2918:	mov    rcx,QWORD PTR [rsp+0x38]
    291d:	mov    rdx,QWORD PTR [rsp+0x40]
    2922:	mov    rsi,r15
    2925:	mov    rdi,rbx
    2928:	call   292d <botlish_fn_21+0x21d>
			2929: R_X86_64_PLT32	rt_str_region_eq-0x4
    292d:	cmp    rax,0x6
    2931:	je     295c <botlish_fn_21+0x24c>
    2937:	mov    rax,QWORD PTR [rbx+0x10]
    293b:	mov    r8,QWORD PTR [rax+0x140]
    2942:	mov    rcx,QWORD PTR [rsp+0x38]
    2947:	mov    rdx,QWORD PTR [rsp+0x40]
    294c:	mov    rsi,r15
    294f:	mov    rdi,rbx
    2952:	call   2957 <botlish_fn_21+0x247>
			2953: R_X86_64_PLT32	rt_str_region_eq-0x4
    2957:	jmp    2989 <botlish_fn_21+0x279>
    295c:	mov    rax,QWORD PTR [rsp+0x30]
    2961:	jmp    2989 <botlish_fn_21+0x279>
    2966:	mov    rax,QWORD PTR [rsp+0x30]
    296b:	jmp    2989 <botlish_fn_21+0x279>
    2970:	mov    rax,QWORD PTR [rsp+0x30]
    2975:	jmp    2989 <botlish_fn_21+0x279>
    297a:	mov    rax,QWORD PTR [rsp+0x30]
    297f:	jmp    2989 <botlish_fn_21+0x279>
    2984:	mov    rax,QWORD PTR [rsp+0x30]
    2989:	cmp    rax,0x6
    298d:	je     299b <botlish_fn_21+0x28b>
    2993:	mov    rax,r14
    2996:	jmp    2a06 <botlish_fn_21+0x2f6>
    299b:	mov    QWORD PTR [rsp+0x18],0x3
    29a4:	mov    rsi,r14
    29a7:	test   rsi,0x1
    29ae:	je     29d4 <botlish_fn_21+0x2c4>
    29b4:	mov    rsi,r14
    29b7:	mov    rax,rsi
    29ba:	add    rax,0x2
    29be:	seto   cl
    29c1:	test   cl,cl
    29c3:	jne    29d4 <botlish_fn_21+0x2c4>
    29c9:	mov    rsi,rax
    29cc:	mov    r14,rax
    29cf:	jmp    29ea <botlish_fn_21+0x2da>
    29d4:	mov    edx,0x3
    29d9:	mov    rsi,r14
    29dc:	mov    rdi,rbx
    29df:	call   29e4 <botlish_fn_21+0x2d4>
			29e0: R_X86_64_PLT32	rt_int_add-0x4
    29e4:	mov    rsi,rax
    29e7:	mov    r14,rax
    29ea:	mov    QWORD PTR [rsp],rsi
    29ee:	mov    QWORD PTR [rsp+0x8],r13
    29f3:	mov    QWORD PTR [rsp+0x10],r12
    29f8:	mov    rax,rbx
    29fb:	mov    rdx,r13
    29fe:	jmp    2754 <botlish_fn_21+0x44>
    2a03:	mov    rax,r14
    2a06:	mov    rbx,QWORD PTR [rsp+0x50]
    2a0b:	mov    r12,QWORD PTR [rsp+0x58]
    2a10:	mov    r13,QWORD PTR [rsp+0x60]
    2a15:	mov    r14,QWORD PTR [rsp+0x68]
    2a1a:	mov    r15,QWORD PTR [rsp+0x70]
    2a1f:	add    rsp,0x80
    2a26:	mov    rsp,rbp
    2a29:	pop    rbp
    2a2a:	ret
    2a2b:	add    BYTE PTR [rax],al
    2a2d:	add    BYTE PTR [rax],al
    2a2f:	add    BYTE PTR [rsi],al
    2a31:	add    BYTE PTR [rax],al
    2a33:	add    BYTE PTR [rax],al
    2a35:	add    BYTE PTR [rax],al
	...

0000000000002a38 <botlish_entry_21: scan_local<generic>>:
    2a38:	push   rbp
    2a39:	mov    rbp,rsp
    2a3c:	mov    rsi,QWORD PTR [rdx]
    2a3f:	mov    r8,QWORD PTR [rdx+0x8]
    2a43:	mov    rcx,QWORD PTR [rdx+0x10]
    2a47:	mov    rdx,r8
    2a4a:	call   2a4f <botlish_entry_21+0x17>
			2a4b: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_local<generic>
    2a4f:	mov    rsp,rbp
    2a52:	pop    rbp
    2a53:	ret
    2a54:	add    BYTE PTR [rax],al
	...

0000000000002a58 <botlish_fn_22: scan_label<generic>>:
    2a58:	push   rbp
    2a59:	mov    rbp,rsp
    2a5c:	sub    rsp,0x80
    2a63:	mov    QWORD PTR [rsp+0x50],rbx
    2a68:	mov    QWORD PTR [rsp+0x58],r12
    2a6d:	mov    QWORD PTR [rsp+0x60],r13
    2a72:	mov    QWORD PTR [rsp+0x68],r14
    2a77:	mov    QWORD PTR [rsp+0x70],r15
    2a7c:	mov    QWORD PTR [rsp+0x18],0x0
    2a85:	mov    QWORD PTR [rsp],rsi
    2a89:	mov    r14,rsi
    2a8c:	mov    QWORD PTR [rsp+0x8],rdx
    2a91:	mov    QWORD PTR [rsp+0x10],rcx
    2a96:	mov    r12,rcx
    2a99:	mov    r11d,0x1
    2a9f:	mov    rsi,r14
    2aa2:	test   rsi,0x1
    2aa9:	jne    2ac9 <botlish_fn_22+0x71>
    2aaf:	xor    r11d,r11d
    2ab2:	test   rsi,0x7
    2ab9:	jne    2ac9 <botlish_fn_22+0x71>
    2abf:	movzx  rax,BYTE PTR [rsi]
    2ac3:	cmp    al,0x1
    2ac5:	sete   r11b
    2ac9:	test   r11b,r11b
    2acc:	jne    2aea <botlish_fn_22+0x92>
    2ad2:	mov    rax,QWORD PTR [rdi+0x10]
    2ad6:	mov    rcx,QWORD PTR [rax+0xb0]
    2add:	xor    rdx,rdx
    2ae0:	call   2ae5 <botlish_fn_22+0x8d>
			2ae1: R_X86_64_PLT32	rt_type_error-0x4
    2ae5:	jmp    2b96 <botlish_fn_22+0x13e>
    2aea:	mov    r13,rdx
    2aed:	mov    rax,rsi
    2af0:	and    rax,r13
    2af3:	mov    r14,rsi
    2af6:	test   rax,0x1
    2afc:	jne    2b25 <botlish_fn_22+0xcd>
    2b02:	mov    rbx,rdi
    2b05:	mov    rdx,r13
    2b08:	mov    rsi,r14
    2b0b:	call   2b10 <botlish_fn_22+0xb8>
			2b0c: R_X86_64_PLT32	rt_int_cmp-0x4
    2b10:	mov    ecx,0x2
    2b15:	test   rax,rax
    2b18:	cmovge rcx,QWORD PTR [rip+0x178]        # 2c98 <botlish_fn_22+0x240>
    2b20:	jmp    2b3b <botlish_fn_22+0xe3>
    2b25:	mov    rbx,rdi
    2b28:	mov    ecx,0x2
    2b2d:	mov    rsi,r14
    2b30:	cmp    rsi,r13
    2b33:	cmovge rcx,QWORD PTR [rip+0x15d]        # 2c98 <botlish_fn_22+0x240>
    2b3b:	mov    eax,0x6
    2b40:	mov    QWORD PTR [rsp+0x30],rax
    2b45:	cmp    rcx,0x6
    2b49:	je     2c6c <botlish_fn_22+0x214>
    2b4f:	lea    rcx,[rsp+0x20]
    2b54:	mov    rdx,r12
    2b57:	mov    rsi,r14
    2b5a:	mov    rdi,rbx
    2b5d:	call   2b62 <botlish_fn_22+0x10a>
			2b5e: R_X86_64_PLT32	botlish_fn_20-0x4 ; char_at<generic>
    2b62:	test   rax,rax
    2b65:	mov    r15,rax
    2b68:	je     2b96 <botlish_fn_22+0x13e>
    2b6e:	mov    rdx,QWORD PTR [rsp+0x20]
    2b73:	mov    QWORD PTR [rsp+0x40],rdx
    2b78:	mov    rcx,QWORD PTR [rsp+0x28]
    2b7d:	mov    QWORD PTR [rsp+0x38],rcx
    2b82:	mov    rsi,r15
    2b85:	mov    rdi,rbx
    2b88:	call   2b8d <botlish_fn_22+0x135>
			2b89: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    2b8d:	test   rax,rax
    2b90:	jne    2bbe <botlish_fn_22+0x166>
    2b96:	xor    rax,rax
    2b99:	mov    rbx,QWORD PTR [rsp+0x50]
    2b9e:	mov    r12,QWORD PTR [rsp+0x58]
    2ba3:	mov    r13,QWORD PTR [rsp+0x60]
    2ba8:	mov    r14,QWORD PTR [rsp+0x68]
    2bad:	mov    r15,QWORD PTR [rsp+0x70]
    2bb2:	add    rsp,0x80
    2bb9:	mov    rsp,rbp
    2bbc:	pop    rbp
    2bbd:	ret
    2bbe:	cmp    rax,0x6
    2bc2:	je     2bed <botlish_fn_22+0x195>
    2bc8:	mov    r11,QWORD PTR [rbx+0x10]
    2bcc:	mov    r8,QWORD PTR [r11+0x140]
    2bd3:	mov    rcx,QWORD PTR [rsp+0x38]
    2bd8:	mov    rdx,QWORD PTR [rsp+0x40]
    2bdd:	mov    rsi,r15
    2be0:	mov    rdi,rbx
    2be3:	call   2be8 <botlish_fn_22+0x190>
			2be4: R_X86_64_PLT32	rt_str_region_eq-0x4
    2be8:	jmp    2bf2 <botlish_fn_22+0x19a>
    2bed:	mov    rax,QWORD PTR [rsp+0x30]
    2bf2:	cmp    rax,0x6
    2bf6:	je     2c04 <botlish_fn_22+0x1ac>
    2bfc:	mov    rax,r14
    2bff:	jmp    2c6f <botlish_fn_22+0x217>
    2c04:	mov    QWORD PTR [rsp+0x18],0x3
    2c0d:	mov    rsi,r14
    2c10:	test   rsi,0x1
    2c17:	je     2c3d <botlish_fn_22+0x1e5>
    2c1d:	mov    rsi,r14
    2c20:	mov    rax,rsi
    2c23:	add    rax,0x2
    2c27:	seto   cl
    2c2a:	test   cl,cl
    2c2c:	jne    2c3d <botlish_fn_22+0x1e5>
    2c32:	mov    rsi,rax
    2c35:	mov    r14,rax
    2c38:	jmp    2c53 <botlish_fn_22+0x1fb>
    2c3d:	mov    edx,0x3
    2c42:	mov    rsi,r14
    2c45:	mov    rdi,rbx
    2c48:	call   2c4d <botlish_fn_22+0x1f5>
			2c49: R_X86_64_PLT32	rt_int_add-0x4
    2c4d:	mov    rsi,rax
    2c50:	mov    r14,rax
    2c53:	mov    QWORD PTR [rsp],rsi
    2c57:	mov    QWORD PTR [rsp+0x8],r13
    2c5c:	mov    QWORD PTR [rsp+0x10],r12
    2c61:	mov    rdx,r13
    2c64:	mov    rdi,rbx
    2c67:	jmp    2a99 <botlish_fn_22+0x41>
    2c6c:	mov    rax,r14
    2c6f:	mov    rbx,QWORD PTR [rsp+0x50]
    2c74:	mov    r12,QWORD PTR [rsp+0x58]
    2c79:	mov    r13,QWORD PTR [rsp+0x60]
    2c7e:	mov    r14,QWORD PTR [rsp+0x68]
    2c83:	mov    r15,QWORD PTR [rsp+0x70]
    2c88:	add    rsp,0x80
    2c8f:	mov    rsp,rbp
    2c92:	pop    rbp
    2c93:	ret
    2c94:	add    BYTE PTR [rax],al
    2c96:	add    BYTE PTR [rax],al
    2c98:	(bad)
    2c99:	add    BYTE PTR [rax],al
    2c9b:	add    BYTE PTR [rax],al
    2c9d:	add    BYTE PTR [rax],al
	...

0000000000002ca0 <botlish_entry_22: scan_label<generic>>:
    2ca0:	push   rbp
    2ca1:	mov    rbp,rsp
    2ca4:	mov    rsi,QWORD PTR [rdx]
    2ca7:	mov    r8,QWORD PTR [rdx+0x8]
    2cab:	mov    rcx,QWORD PTR [rdx+0x10]
    2caf:	mov    rdx,r8
    2cb2:	call   2cb7 <botlish_entry_22+0x17>
			2cb3: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_label<generic>
    2cb7:	mov    rsp,rbp
    2cba:	pop    rbp
    2cbb:	ret
    2cbc:	add    BYTE PTR [rax],al
	...

0000000000002cc0 <botlish_fn_23: scan_alpha<generic>>:
    2cc0:	push   rbp
    2cc1:	mov    rbp,rsp
    2cc4:	sub    rsp,0x50
    2cc8:	mov    QWORD PTR [rsp+0x30],rbx
    2ccd:	mov    QWORD PTR [rsp+0x38],r12
    2cd2:	mov    QWORD PTR [rsp+0x40],r13
    2cd7:	mov    QWORD PTR [rsp+0x48],r14
    2cdc:	mov    r14,rdi
    2cdf:	mov    QWORD PTR [rsp+0x18],0x0
    2ce8:	mov    QWORD PTR [rsp],rsi
    2cec:	mov    r13,rsi
    2cef:	mov    QWORD PTR [rsp+0x8],rdx
    2cf4:	mov    r12,rdx
    2cf7:	mov    QWORD PTR [rsp+0x10],rcx
    2cfc:	mov    rbx,rcx
    2cff:	mov    r11d,0x1
    2d05:	mov    rsi,r13
    2d08:	test   rsi,0x1
    2d0f:	jne    2d2f <botlish_fn_23+0x6f>
    2d15:	xor    r11d,r11d
    2d18:	test   rsi,0x7
    2d1f:	jne    2d2f <botlish_fn_23+0x6f>
    2d25:	movzx  rax,BYTE PTR [rsi]
    2d29:	cmp    al,0x1
    2d2b:	sete   r11b
    2d2f:	test   r11b,r11b
    2d32:	jne    2d53 <botlish_fn_23+0x93>
    2d38:	mov    rdi,r14
    2d3b:	mov    rax,QWORD PTR [rdi+0x10]
    2d3f:	mov    rcx,QWORD PTR [rax+0xb0]
    2d46:	xor    rdx,rdx
    2d49:	call   2d4e <botlish_fn_23+0x8e>
			2d4a: R_X86_64_PLT32	rt_type_error-0x4
    2d4e:	jmp    2de2 <botlish_fn_23+0x122>
    2d53:	mov    rax,rsi
    2d56:	and    rax,r12
    2d59:	mov    r13,rsi
    2d5c:	test   rax,0x1
    2d62:	jne    2d8b <botlish_fn_23+0xcb>
    2d68:	mov    rdx,r12
    2d6b:	mov    rsi,r13
    2d6e:	mov    rdi,r14
    2d71:	call   2d76 <botlish_fn_23+0xb6>
			2d72: R_X86_64_PLT32	rt_int_cmp-0x4
    2d76:	mov    ecx,0x2
    2d7b:	test   rax,rax
    2d7e:	cmovge rcx,QWORD PTR [rip+0x112]        # 2e98 <botlish_fn_23+0x1d8>
    2d86:	jmp    2d9e <botlish_fn_23+0xde>
    2d8b:	mov    ecx,0x2
    2d90:	mov    rsi,r13
    2d93:	cmp    rsi,r12
    2d96:	cmovge rcx,QWORD PTR [rip+0xfa]        # 2e98 <botlish_fn_23+0x1d8>
    2d9e:	cmp    rcx,0x6
    2da2:	je     2e76 <botlish_fn_23+0x1b6>
    2da8:	lea    rcx,[rsp+0x20]
    2dad:	mov    rdx,rbx
    2db0:	mov    rsi,r13
    2db3:	mov    rdi,r14
    2db6:	call   2dbb <botlish_fn_23+0xfb>
			2db7: R_X86_64_PLT32	botlish_fn_20-0x4 ; char_at<generic>
    2dbb:	test   rax,rax
    2dbe:	mov    rsi,rax
    2dc1:	je     2de2 <botlish_fn_23+0x122>
    2dc7:	mov    rdx,QWORD PTR [rsp+0x20]
    2dcc:	mov    rcx,QWORD PTR [rsp+0x28]
    2dd1:	mov    rdi,r14
    2dd4:	call   2dd9 <botlish_fn_23+0x119>
			2dd5: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    2dd9:	test   rax,rax
    2ddc:	jne    2e02 <botlish_fn_23+0x142>
    2de2:	xor    rax,rax
    2de5:	mov    rbx,QWORD PTR [rsp+0x30]
    2dea:	mov    r12,QWORD PTR [rsp+0x38]
    2def:	mov    r13,QWORD PTR [rsp+0x40]
    2df4:	mov    r14,QWORD PTR [rsp+0x48]
    2df9:	add    rsp,0x50
    2dfd:	mov    rsp,rbp
    2e00:	pop    rbp
    2e01:	ret
    2e02:	cmp    rax,0x6
    2e06:	je     2e14 <botlish_fn_23+0x154>
    2e0c:	mov    rax,r13
    2e0f:	jmp    2e79 <botlish_fn_23+0x1b9>
    2e14:	mov    QWORD PTR [rsp+0x18],0x3
    2e1d:	mov    rsi,r13
    2e20:	test   rsi,0x1
    2e27:	je     2e4d <botlish_fn_23+0x18d>
    2e2d:	mov    rsi,r13
    2e30:	mov    r11,rsi
    2e33:	add    r11,0x2
    2e37:	seto   al
    2e3a:	test   al,al
    2e3c:	jne    2e4d <botlish_fn_23+0x18d>
    2e42:	mov    rsi,r11
    2e45:	mov    r13,r11
    2e48:	jmp    2e63 <botlish_fn_23+0x1a3>
    2e4d:	mov    edx,0x3
    2e52:	mov    rsi,r13
    2e55:	mov    rdi,r14
    2e58:	call   2e5d <botlish_fn_23+0x19d>
			2e59: R_X86_64_PLT32	rt_int_add-0x4
    2e5d:	mov    rsi,rax
    2e60:	mov    r13,rax
    2e63:	mov    QWORD PTR [rsp],rsi
    2e67:	mov    QWORD PTR [rsp+0x8],r12
    2e6c:	mov    QWORD PTR [rsp+0x10],rbx
    2e71:	jmp    2cff <botlish_fn_23+0x3f>
    2e76:	mov    rax,r13
    2e79:	mov    rbx,QWORD PTR [rsp+0x30]
    2e7e:	mov    r12,QWORD PTR [rsp+0x38]
    2e83:	mov    r13,QWORD PTR [rsp+0x40]
    2e88:	mov    r14,QWORD PTR [rsp+0x48]
    2e8d:	add    rsp,0x50
    2e91:	mov    rsp,rbp
    2e94:	pop    rbp
    2e95:	ret
    2e96:	add    BYTE PTR [rax],al
    2e98:	(bad)
    2e99:	add    BYTE PTR [rax],al
    2e9b:	add    BYTE PTR [rax],al
    2e9d:	add    BYTE PTR [rax],al
	...

0000000000002ea0 <botlish_entry_23: scan_alpha<generic>>:
    2ea0:	push   rbp
    2ea1:	mov    rbp,rsp
    2ea4:	mov    rsi,QWORD PTR [rdx]
    2ea7:	mov    r8,QWORD PTR [rdx+0x8]
    2eab:	mov    rcx,QWORD PTR [rdx+0x10]
    2eaf:	mov    rdx,r8
    2eb2:	call   2eb7 <botlish_entry_23+0x17>
			2eb3: R_X86_64_PLT32	botlish_fn_23-0x4 ; scan_alpha<generic>
    2eb7:	mov    rsp,rbp
    2eba:	pop    rbp
    2ebb:	ret
    2ebc:	add    BYTE PTR [rax],al
	...

0000000000002ec0 <botlish_fn_24: tld_ok<generic>>:
    2ec0:	push   rbp
    2ec1:	mov    rbp,rsp
    2ec4:	sub    rsp,0x40
    2ec8:	mov    QWORD PTR [rsp+0x20],rbx
    2ecd:	mov    QWORD PTR [rsp+0x28],r12
    2ed2:	mov    QWORD PTR [rsp+0x30],r13
    2ed7:	mov    QWORD PTR [rsp+0x38],r14
    2edc:	mov    rbx,rdi
    2edf:	mov    QWORD PTR [rsp],rsi
    2ee3:	mov    r12,rsi
    2ee6:	mov    QWORD PTR [rsp+0x8],rdx
    2eeb:	mov    r14,rdx
    2eee:	mov    QWORD PTR [rsp+0x10],rcx
    2ef3:	mov    rdx,r14
    2ef6:	mov    rsi,r12
    2ef9:	mov    rdi,rbx
    2efc:	call   2f01 <botlish_fn_24+0x41>
			2efd: R_X86_64_PLT32	botlish_fn_23-0x4 ; scan_alpha<generic>
    2f01:	mov    rsi,rax
    2f04:	mov    r13,rax
    2f07:	test   rax,rsi
    2f0a:	je     2fcd <botlish_fn_24+0x10d>
    2f10:	mov    rax,r13
    2f13:	mov    QWORD PTR [rsp+0x8],rax
    2f18:	mov    rdx,r14
    2f1b:	and    rax,rdx
    2f1e:	test   rax,0x1
    2f24:	jne    2f4d <botlish_fn_24+0x8d>
    2f2a:	mov    rsi,r13
    2f2d:	mov    rdi,rbx
    2f30:	call   2f35 <botlish_fn_24+0x75>
			2f31: R_X86_64_PLT32	rt_int_cmp-0x4
    2f35:	mov    ecx,0x2
    2f3a:	test   rax,rax
    2f3d:	cmove  rcx,QWORD PTR [rip+0x15b]        # 30a0 <botlish_fn_24+0x1e0>
    2f45:	mov    rax,r13
    2f48:	jmp    2f60 <botlish_fn_24+0xa0>
    2f4d:	mov    ecx,0x2
    2f52:	mov    rax,r13
    2f55:	cmp    rax,rdx
    2f58:	cmove  rcx,QWORD PTR [rip+0x140]        # 30a0 <botlish_fn_24+0x1e0>
    2f60:	cmp    rcx,0x6
    2f64:	je     2f77 <botlish_fn_24+0xb7>
    2f6a:	mov    ecx,0x2
    2f6f:	mov    rax,rcx
    2f72:	jmp    307f <botlish_fn_24+0x1bf>
    2f77:	mov    ecx,0x1
    2f7c:	mov    rsi,r12
    2f7f:	test   rsi,0x1
    2f86:	jne    2fac <botlish_fn_24+0xec>
    2f8c:	xor    ecx,ecx
    2f8e:	mov    rsi,r12
    2f91:	test   rsi,0x7
    2f98:	jne    2fac <botlish_fn_24+0xec>
    2f9e:	mov    rsi,r12
    2fa1:	movzx  rcx,BYTE PTR [rsi]
    2fa5:	rex cmp cl,0x1
    2fa9:	sete   cl
    2fac:	test   cl,cl
    2fae:	jne    2fed <botlish_fn_24+0x12d>
    2fb4:	mov    rdi,rbx
    2fb7:	mov    rsi,QWORD PTR [rdi+0x10]
    2fbb:	mov    rcx,QWORD PTR [rsi+0x140]
    2fc2:	xor    rdx,rdx
    2fc5:	mov    rsi,r12
    2fc8:	call   2fcd <botlish_fn_24+0x10d>
			2fc9: R_X86_64_PLT32	rt_type_error-0x4
    2fcd:	xor    rax,rax
    2fd0:	mov    rbx,QWORD PTR [rsp+0x20]
    2fd5:	mov    r12,QWORD PTR [rsp+0x28]
    2fda:	mov    r13,QWORD PTR [rsp+0x30]
    2fdf:	mov    r14,QWORD PTR [rsp+0x38]
    2fe4:	add    rsp,0x40
    2fe8:	mov    rsp,rbp
    2feb:	pop    rbp
    2fec:	ret
    2fed:	mov    rsi,r12
    2ff0:	mov    rdi,rax
    2ff3:	and    rdi,rsi
    2ff6:	test   rdi,0x1
    2ffd:	jne    300e <botlish_fn_24+0x14e>
    3003:	mov    rdx,r12
    3006:	mov    rsi,rax
    3009:	jmp    3031 <botlish_fn_24+0x171>
    300e:	mov    rsi,r12
    3011:	mov    r8,rax
    3014:	sub    r8,rsi
    3017:	mov    r13,rax
    301a:	seto   r10b
    301e:	lea    rsi,[r8+0x1]
    3022:	test   r10b,r10b
    3025:	je     303c <botlish_fn_24+0x17c>
    302b:	mov    rdx,r12
    302e:	mov    rsi,r13
    3031:	mov    rdi,rbx
    3034:	call   3039 <botlish_fn_24+0x179>
			3035: R_X86_64_PLT32	rt_int_sub-0x4
    3039:	mov    rsi,rax
    303c:	test   rsi,0x1
    3043:	jne    306e <botlish_fn_24+0x1ae>
    3049:	mov    edx,0x5
    304e:	mov    rdi,rbx
    3051:	call   3056 <botlish_fn_24+0x196>
			3052: R_X86_64_PLT32	rt_int_cmp-0x4
    3056:	mov    ecx,0x2
    305b:	test   rax,rax
    305e:	mov    rax,rcx
    3061:	cmovge rax,QWORD PTR [rip+0x37]        # 30a0 <botlish_fn_24+0x1e0>
    3069:	jmp    307f <botlish_fn_24+0x1bf>
    306e:	mov    eax,0x2
    3073:	cmp    rsi,0x5
    3077:	cmovge rax,QWORD PTR [rip+0x21]        # 30a0 <botlish_fn_24+0x1e0>
    307f:	mov    rbx,QWORD PTR [rsp+0x20]
    3084:	mov    r12,QWORD PTR [rsp+0x28]
    3089:	mov    r13,QWORD PTR [rsp+0x30]
    308e:	mov    r14,QWORD PTR [rsp+0x38]
    3093:	add    rsp,0x40
    3097:	mov    rsp,rbp
    309a:	pop    rbp
    309b:	ret
    309c:	add    BYTE PTR [rax],al
    309e:	add    BYTE PTR [rax],al
    30a0:	(bad)
    30a1:	add    BYTE PTR [rax],al
    30a3:	add    BYTE PTR [rax],al
    30a5:	add    BYTE PTR [rax],al
	...

00000000000030a8 <botlish_entry_24: tld_ok<generic>>:
    30a8:	push   rbp
    30a9:	mov    rbp,rsp
    30ac:	mov    rsi,QWORD PTR [rdx]
    30af:	mov    r8,QWORD PTR [rdx+0x8]
    30b3:	mov    rcx,QWORD PTR [rdx+0x10]
    30b7:	mov    rdx,r8
    30ba:	call   30bf <botlish_entry_24+0x17>
			30bb: R_X86_64_PLT32	botlish_fn_24-0x4 ; tld_ok<generic>
    30bf:	mov    rsp,rbp
    30c2:	pop    rbp
    30c3:	ret
    30c4:	add    BYTE PTR [rax],al
	...

00000000000030c8 <botlish_fn_25: domain_loop<generic>>:
    30c8:	push   rbp
    30c9:	mov    rbp,rsp
    30cc:	sub    rsp,0x70
    30d0:	mov    QWORD PTR [rsp+0x40],rbx
    30d5:	mov    QWORD PTR [rsp+0x48],r12
    30da:	mov    QWORD PTR [rsp+0x50],r13
    30df:	mov    QWORD PTR [rsp+0x58],r14
    30e4:	mov    QWORD PTR [rsp+0x60],r15
    30e9:	mov    QWORD PTR [rsp+0x18],0x0
    30f2:	mov    QWORD PTR [rsp],rsi
    30f6:	mov    QWORD PTR [rsp+0x8],rdx
    30fb:	mov    QWORD PTR [rsp+0x10],rcx
    3100:	lea    rbx,[rsp+0x20]
    3105:	mov    r12,rdi
    3108:	mov    r13,rcx
    310b:	mov    r14,rdx
    310e:	mov    QWORD PTR [rsp+0x30],rsi
    3113:	mov    rcx,r13
    3116:	mov    rdx,r14
    3119:	mov    rsi,QWORD PTR [rsp+0x30]
    311e:	mov    rdi,r12
    3121:	call   3126 <botlish_fn_25+0x5e>
			3122: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_label<generic>
    3126:	mov    rcx,rax
    3129:	mov    r15,rax
    312c:	test   rax,rcx
    312f:	je     327f <botlish_fn_25+0x1b7>
    3135:	mov    rax,r15
    3138:	mov    QWORD PTR [rsp],rax
    313c:	mov    rdx,QWORD PTR [rsp+0x30]
    3141:	and    rax,rdx
    3144:	test   rax,0x1
    314a:	jne    3169 <botlish_fn_25+0xa1>
    3150:	mov    rsi,r15
    3153:	mov    rdi,r12
    3156:	call   315b <botlish_fn_25+0x93>
			3157: R_X86_64_PLT32	rt_value_eq-0x4
    315b:	test   rax,rax
    315e:	je     327f <botlish_fn_25+0x1b7>
    3164:	jmp    3179 <botlish_fn_25+0xb1>
    3169:	mov    eax,0x2
    316e:	cmp    r15,rdx
    3171:	cmove  rax,QWORD PTR [rip+0x187]        # 3300 <botlish_fn_25+0x238>
    3179:	cmp    rax,0x6
    317d:	je     32d5 <botlish_fn_25+0x20d>
    3183:	mov    rax,r15
    3186:	and    rax,r14
    3189:	test   rax,0x1
    318f:	jne    31b8 <botlish_fn_25+0xf0>
    3195:	mov    rdx,r14
    3198:	mov    rsi,r15
    319b:	mov    rdi,r12
    319e:	call   31a3 <botlish_fn_25+0xdb>
			319f: R_X86_64_PLT32	rt_int_cmp-0x4
    31a3:	mov    ecx,0x2
    31a8:	test   rax,rax
    31ab:	cmovge rcx,QWORD PTR [rip+0x14d]        # 3300 <botlish_fn_25+0x238>
    31b3:	jmp    31c8 <botlish_fn_25+0x100>
    31b8:	mov    ecx,0x2
    31bd:	cmp    r15,r14
    31c0:	cmovge rcx,QWORD PTR [rip+0x138]        # 3300 <botlish_fn_25+0x238>
    31c8:	cmp    rcx,0x6
    31cc:	je     32c6 <botlish_fn_25+0x1fe>
    31d2:	mov    rcx,rbx
    31d5:	mov    rdx,r13
    31d8:	mov    rsi,r15
    31db:	mov    rdi,r12
    31de:	call   31e3 <botlish_fn_25+0x11b>
			31df: R_X86_64_PLT32	botlish_fn_20-0x4 ; char_at<generic>
    31e3:	test   rax,rax
    31e6:	je     327f <botlish_fn_25+0x1b7>
    31ec:	mov    rdx,QWORD PTR [rsp+0x20]
    31f1:	mov    rcx,QWORD PTR [rsp+0x28]
    31f6:	mov    rsi,QWORD PTR [r12+0x10]
    31fb:	mov    r8,QWORD PTR [rsi+0x130]
    3202:	mov    rsi,rax
    3205:	mov    rdi,r12
    3208:	call   320d <botlish_fn_25+0x145>
			3209: R_X86_64_PLT32	rt_str_region_eq-0x4
    320d:	cmp    rax,0x6
    3211:	je     3223 <botlish_fn_25+0x15b>
    3217:	mov    r14,0xffffffffffffffff
    321e:	jmp    32cd <botlish_fn_25+0x205>
    3223:	mov    QWORD PTR [rsp+0x18],0x3
    322c:	test   r15,0x1
    3233:	je     324b <botlish_fn_25+0x183>
    3239:	mov    rdx,r15
    323c:	add    rdx,0x2
    3240:	seto   al
    3243:	test   al,al
    3245:	je     325e <botlish_fn_25+0x196>
    324b:	mov    edx,0x3
    3250:	mov    rsi,r15
    3253:	mov    rdi,r12
    3256:	call   325b <botlish_fn_25+0x193>
			3257: R_X86_64_PLT32	rt_int_add-0x4
    325b:	mov    rdx,rax
    325e:	mov    QWORD PTR [rsp],rdx
    3262:	mov    r15,rdx
    3265:	mov    rcx,r13
    3268:	mov    rdx,r14
    326b:	mov    rsi,r15
    326e:	mov    rdi,r12
    3271:	call   3276 <botlish_fn_25+0x1ae>
			3272: R_X86_64_PLT32	botlish_fn_24-0x4 ; tld_ok<generic>
    3276:	test   rax,rax
    3279:	jne    32a4 <botlish_fn_25+0x1dc>
    327f:	xor    rax,rax
    3282:	mov    rbx,QWORD PTR [rsp+0x40]
    3287:	mov    r12,QWORD PTR [rsp+0x48]
    328c:	mov    r13,QWORD PTR [rsp+0x50]
    3291:	mov    r14,QWORD PTR [rsp+0x58]
    3296:	mov    r15,QWORD PTR [rsp+0x60]
    329b:	add    rsp,0x70
    329f:	mov    rsp,rbp
    32a2:	pop    rbp
    32a3:	ret
    32a4:	cmp    rax,0x6
    32a8:	je     32cd <botlish_fn_25+0x205>
    32ae:	mov    QWORD PTR [rsp],r15
    32b2:	mov    QWORD PTR [rsp+0x8],r14
    32b7:	mov    QWORD PTR [rsp+0x10],r13
    32bc:	mov    QWORD PTR [rsp+0x30],r15
    32c1:	jmp    3113 <botlish_fn_25+0x4b>
    32c6:	mov    r14,0xffffffffffffffff
    32cd:	mov    rax,r14
    32d0:	jmp    32dc <botlish_fn_25+0x214>
    32d5:	mov    rax,0xffffffffffffffff
    32dc:	mov    rbx,QWORD PTR [rsp+0x40]
    32e1:	mov    r12,QWORD PTR [rsp+0x48]
    32e6:	mov    r13,QWORD PTR [rsp+0x50]
    32eb:	mov    r14,QWORD PTR [rsp+0x58]
    32f0:	mov    r15,QWORD PTR [rsp+0x60]
    32f5:	add    rsp,0x70
    32f9:	mov    rsp,rbp
    32fc:	pop    rbp
    32fd:	ret
    32fe:	add    BYTE PTR [rax],al
    3300:	(bad)
    3301:	add    BYTE PTR [rax],al
    3303:	add    BYTE PTR [rax],al
    3305:	add    BYTE PTR [rax],al
	...

0000000000003308 <botlish_entry_25: domain_loop<generic>>:
    3308:	push   rbp
    3309:	mov    rbp,rsp
    330c:	mov    rsi,QWORD PTR [rdx]
    330f:	mov    r8,QWORD PTR [rdx+0x8]
    3313:	mov    rcx,QWORD PTR [rdx+0x10]
    3317:	mov    rdx,r8
    331a:	call   331f <botlish_entry_25+0x17>
			331b: R_X86_64_PLT32	botlish_fn_25-0x4 ; domain_loop<generic>
    331f:	mov    rsp,rbp
    3322:	pop    rbp
    3323:	ret
    3324:	add    BYTE PTR [rax],al
	...

0000000000003328 <botlish_fn_26: <str>>:
    3328:	push   rbp
    3329:	mov    rbp,rsp
    332c:	sub    rsp,0x50
    3330:	mov    QWORD PTR [rsp+0x30],rbx
    3335:	mov    QWORD PTR [rsp+0x38],r12
    333a:	mov    QWORD PTR [rsp+0x40],r13
    333f:	mov    QWORD PTR [rsp+0x48],r14
    3344:	mov    r13,rdi
    3347:	mov    QWORD PTR [rsp+0x18],0x0
    3350:	mov    QWORD PTR [rsp],rsi
    3354:	mov    r14,rsi
    3357:	mov    rsi,r14
    335a:	mov    rdi,r13
    335d:	call   3362 <botlish_fn_26+0x3a>
			335e: R_X86_64_PLT32	rt_str_len-0x4
    3362:	mov    rbx,rax
    3365:	mov    QWORD PTR [rsp+0x8],rax
    336a:	mov    esi,0x1
    336f:	mov    QWORD PTR [rsp+0x10],0x1
    3378:	mov    rcx,r14
    337b:	mov    rdx,rbx
    337e:	mov    rdi,r13
    3381:	call   3386 <botlish_fn_26+0x5e>
			3382: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_local<generic>
    3386:	mov    r12,rax
    3389:	test   r12,r12
    338c:	je     34e9 <botlish_fn_26+0x1c1>
    3392:	mov    QWORD PTR [rsp+0x10],r12
    3397:	test   r12,0x1
    339e:	jne    33c9 <botlish_fn_26+0xa1>
    33a4:	mov    edx,0x1
    33a9:	mov    rsi,r12
    33ac:	mov    rdi,r13
    33af:	call   33b4 <botlish_fn_26+0x8c>
			33b0: R_X86_64_PLT32	rt_int_cmp-0x4
    33b4:	mov    ecx,0x2
    33b9:	test   rax,rax
    33bc:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 3588 <botlish_fn_26+0x260>
    33c4:	jmp    33da <botlish_fn_26+0xb2>
    33c9:	mov    ecx,0x2
    33ce:	cmp    r12,0x1
    33d2:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 3588 <botlish_fn_26+0x260>
    33da:	cmp    rcx,0x6
    33de:	je     3564 <botlish_fn_26+0x23c>
    33e4:	mov    rcx,r12
    33e7:	and    rcx,rbx
    33ea:	test   rcx,0x1
    33f1:	jne    341a <botlish_fn_26+0xf2>
    33f7:	mov    rdx,rbx
    33fa:	mov    rsi,r12
    33fd:	mov    rdi,r13
    3400:	call   3405 <botlish_fn_26+0xdd>
			3401: R_X86_64_PLT32	rt_int_cmp-0x4
    3405:	mov    ecx,0x2
    340a:	test   rax,rax
    340d:	cmovge rcx,QWORD PTR [rip+0x173]        # 3588 <botlish_fn_26+0x260>
    3415:	jmp    342a <botlish_fn_26+0x102>
    341a:	mov    ecx,0x2
    341f:	cmp    r12,rbx
    3422:	cmovge rcx,QWORD PTR [rip+0x15e]        # 3588 <botlish_fn_26+0x260>
    342a:	cmp    rcx,0x6
    342e:	je     355a <botlish_fn_26+0x232>
    3434:	lea    rcx,[rsp+0x20]
    3439:	mov    rdx,r14
    343c:	mov    rsi,r12
    343f:	mov    rdi,r13
    3442:	call   3447 <botlish_fn_26+0x11f>
			3443: R_X86_64_PLT32	botlish_fn_28-0x4 ; char_at<generic>
    3447:	test   rax,rax
    344a:	mov    rsi,rax
    344d:	je     34e9 <botlish_fn_26+0x1c1>
    3453:	mov    rdx,QWORD PTR [rsp+0x20]
    3458:	mov    rcx,QWORD PTR [rsp+0x28]
    345d:	mov    rdi,r13
    3460:	mov    rax,QWORD PTR [rdi+0x10]
    3464:	mov    r8,QWORD PTR [rax+0x118]
    346b:	call   3470 <botlish_fn_26+0x148>
			346c: R_X86_64_PLT32	rt_str_region_eq-0x4
    3470:	cmp    rax,0x6
    3474:	je     3487 <botlish_fn_26+0x15f>
    347a:	mov    ecx,0x2
    347f:	mov    rax,rcx
    3482:	jmp    3569 <botlish_fn_26+0x241>
    3487:	mov    QWORD PTR [rsp+0x18],0x3
    3490:	test   r12,0x1
    3497:	jne    34a5 <botlish_fn_26+0x17d>
    349d:	mov    rcx,r12
    34a0:	jmp    34ba <botlish_fn_26+0x192>
    34a5:	mov    rsi,r12
    34a8:	add    rsi,0x2
    34ac:	mov    rcx,r12
    34af:	seto   al
    34b2:	test   al,al
    34b4:	je     34cd <botlish_fn_26+0x1a5>
    34ba:	mov    edx,0x3
    34bf:	mov    rsi,rcx
    34c2:	mov    rdi,r13
    34c5:	call   34ca <botlish_fn_26+0x1a2>
			34c6: R_X86_64_PLT32	rt_int_add-0x4
    34ca:	mov    rsi,rax
    34cd:	mov    QWORD PTR [rsp+0x10],rsi
    34d2:	mov    rcx,r14
    34d5:	mov    rdx,rbx
    34d8:	mov    rdi,r13
    34db:	call   34e0 <botlish_fn_26+0x1b8>
			34dc: R_X86_64_PLT32	botlish_fn_33-0x4 ; domain_loop<generic>
    34e0:	test   rax,rax
    34e3:	jne    3509 <botlish_fn_26+0x1e1>
    34e9:	xor    rax,rax
    34ec:	mov    rbx,QWORD PTR [rsp+0x30]
    34f1:	mov    r12,QWORD PTR [rsp+0x38]
    34f6:	mov    r13,QWORD PTR [rsp+0x40]
    34fb:	mov    r14,QWORD PTR [rsp+0x48]
    3500:	add    rsp,0x50
    3504:	mov    rsp,rbp
    3507:	pop    rbp
    3508:	ret
    3509:	mov    rcx,rax
    350c:	and    rcx,rbx
    350f:	mov    rsi,rax
    3512:	test   rcx,0x1
    3519:	jne    3542 <botlish_fn_26+0x21a>
    351f:	mov    rdx,rbx
    3522:	mov    rdi,r13
    3525:	call   352a <botlish_fn_26+0x202>
			3526: R_X86_64_PLT32	rt_int_cmp-0x4
    352a:	mov    ecx,0x2
    352f:	test   rax,rax
    3532:	mov    rax,rcx
    3535:	cmove  rax,QWORD PTR [rip+0x4b]        # 3588 <botlish_fn_26+0x260>
    353d:	jmp    3569 <botlish_fn_26+0x241>
    3542:	mov    rdx,rbx
    3545:	mov    eax,0x2
    354a:	cmp    rsi,rdx
    354d:	cmove  rax,QWORD PTR [rip+0x33]        # 3588 <botlish_fn_26+0x260>
    3555:	jmp    3569 <botlish_fn_26+0x241>
    355a:	mov    eax,0x2
    355f:	jmp    3569 <botlish_fn_26+0x241>
    3564:	mov    eax,0x2
    3569:	mov    rbx,QWORD PTR [rsp+0x30]
    356e:	mov    r12,QWORD PTR [rsp+0x38]
    3573:	mov    r13,QWORD PTR [rsp+0x40]
    3578:	mov    r14,QWORD PTR [rsp+0x48]
    357d:	add    rsp,0x50
    3581:	mov    rsp,rbp
    3584:	pop    rbp
    3585:	ret
    3586:	add    BYTE PTR [rax],al
    3588:	(bad)
    3589:	add    BYTE PTR [rax],al
    358b:	add    BYTE PTR [rax],al
    358d:	add    BYTE PTR [rax],al
	...

0000000000003590 <botlish_entry_26: <str>>:
    3590:	push   rbp
    3591:	mov    rbp,rsp
    3594:	mov    rsi,QWORD PTR [rdx]
    3597:	call   359c <botlish_entry_26+0xc>
			3598: R_X86_64_PLT32	botlish_fn_26-0x4 ; <str>
    359c:	mov    rsp,rbp
    359f:	pop    rbp
    35a0:	ret
    35a1:	add    BYTE PTR [rax],al
    35a3:	add    BYTE PTR [rax],al
    35a5:	add    BYTE PTR [rax],al
	...

00000000000035a8 <botlish_fn_27: <generic>>:
    35a8:	push   rbp
    35a9:	mov    rbp,rsp
    35ac:	sub    rsp,0x60
    35b0:	mov    QWORD PTR [rsp+0x30],rbx
    35b5:	mov    QWORD PTR [rsp+0x38],r12
    35ba:	mov    QWORD PTR [rsp+0x40],r13
    35bf:	mov    QWORD PTR [rsp+0x48],r14
    35c4:	mov    QWORD PTR [rsp+0x50],r15
    35c9:	mov    QWORD PTR [rsp+0x18],0x0
    35d2:	mov    QWORD PTR [rsp],rsi
    35d6:	xor    r8d,r8d
    35d9:	test   rsi,0x7
    35e0:	jne    35f0 <botlish_fn_27+0x48>
    35e6:	movzx  rax,BYTE PTR [rsi]
    35ea:	cmp    al,0x2
    35ec:	sete   r8b
    35f0:	test   r8b,r8b
    35f3:	jne    3613 <botlish_fn_27+0x6b>
    35f9:	mov    rdx,QWORD PTR [rdi+0x10]
    35fd:	mov    rcx,QWORD PTR [rdx+0xf0]
    3604:	mov    edx,0x1
    3609:	call   360e <botlish_fn_27+0x66>
			360a: R_X86_64_PLT32	rt_type_error-0x4
    360e:	jmp    37a8 <botlish_fn_27+0x200>
    3613:	mov    r13,rsi
    3616:	mov    r14,rdi
    3619:	call   361e <botlish_fn_27+0x76>
			361a: R_X86_64_PLT32	rt_str_len-0x4
    361e:	mov    rbx,rax
    3621:	mov    QWORD PTR [rsp+0x8],rax
    3626:	mov    edx,0x1
    362b:	mov    r15,rdx
    362e:	mov    QWORD PTR [rsp+0x10],0x1
    3637:	mov    rcx,r13
    363a:	mov    rdx,rbx
    363d:	mov    rsi,r15
    3640:	mov    rdi,r14
    3643:	call   3648 <botlish_fn_27+0xa0>
			3644: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_local<generic>
    3648:	mov    r12,rax
    364b:	test   r12,r12
    364e:	je     37a8 <botlish_fn_27+0x200>
    3654:	mov    QWORD PTR [rsp+0x10],r12
    3659:	test   r12,0x1
    3660:	jne    3689 <botlish_fn_27+0xe1>
    3666:	mov    rdx,r15
    3669:	mov    rsi,r12
    366c:	mov    rdi,r14
    366f:	call   3674 <botlish_fn_27+0xcc>
			3670: R_X86_64_PLT32	rt_int_cmp-0x4
    3674:	mov    ecx,0x2
    3679:	test   rax,rax
    367c:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 3850 <botlish_fn_27+0x2a8>
    3684:	jmp    369a <botlish_fn_27+0xf2>
    3689:	mov    ecx,0x2
    368e:	cmp    r12,0x1
    3692:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 3850 <botlish_fn_27+0x2a8>
    369a:	cmp    rcx,0x6
    369e:	je     3828 <botlish_fn_27+0x280>
    36a4:	mov    rax,r12
    36a7:	and    rax,rbx
    36aa:	test   rax,0x1
    36b0:	jne    36d9 <botlish_fn_27+0x131>
    36b6:	mov    rdx,rbx
    36b9:	mov    rsi,r12
    36bc:	mov    rdi,r14
    36bf:	call   36c4 <botlish_fn_27+0x11c>
			36c0: R_X86_64_PLT32	rt_int_cmp-0x4
    36c4:	mov    ecx,0x2
    36c9:	test   rax,rax
    36cc:	cmovge rcx,QWORD PTR [rip+0x17c]        # 3850 <botlish_fn_27+0x2a8>
    36d4:	jmp    36e9 <botlish_fn_27+0x141>
    36d9:	mov    ecx,0x2
    36de:	cmp    r12,rbx
    36e1:	cmovge rcx,QWORD PTR [rip+0x167]        # 3850 <botlish_fn_27+0x2a8>
    36e9:	cmp    rcx,0x6
    36ed:	je     381e <botlish_fn_27+0x276>
    36f3:	lea    rcx,[rsp+0x20]
    36f8:	mov    rdx,r13
    36fb:	mov    rsi,r12
    36fe:	mov    rdi,r14
    3701:	call   3706 <botlish_fn_27+0x15e>
			3702: R_X86_64_PLT32	botlish_fn_28-0x4 ; char_at<generic>
    3706:	test   rax,rax
    3709:	mov    rsi,rax
    370c:	je     37a8 <botlish_fn_27+0x200>
    3712:	mov    rdx,QWORD PTR [rsp+0x20]
    3717:	mov    rcx,QWORD PTR [rsp+0x28]
    371c:	mov    rdi,r14
    371f:	mov    rax,QWORD PTR [rdi+0x10]
    3723:	mov    r8,QWORD PTR [rax+0x118]
    372a:	call   372f <botlish_fn_27+0x187>
			372b: R_X86_64_PLT32	rt_str_region_eq-0x4
    372f:	cmp    rax,0x6
    3733:	je     3746 <botlish_fn_27+0x19e>
    3739:	mov    ecx,0x2
    373e:	mov    rax,rcx
    3741:	jmp    382d <botlish_fn_27+0x285>
    3746:	mov    QWORD PTR [rsp+0x18],0x3
    374f:	test   r12,0x1
    3756:	jne    3764 <botlish_fn_27+0x1bc>
    375c:	mov    rdi,r12
    375f:	jmp    3779 <botlish_fn_27+0x1d1>
    3764:	mov    rsi,r12
    3767:	add    rsi,0x2
    376b:	mov    rdi,r12
    376e:	seto   al
    3771:	test   al,al
    3773:	je     378c <botlish_fn_27+0x1e4>
    3779:	mov    edx,0x3
    377e:	mov    rsi,rdi
    3781:	mov    rdi,r14
    3784:	call   3789 <botlish_fn_27+0x1e1>
			3785: R_X86_64_PLT32	rt_int_add-0x4
    3789:	mov    rsi,rax
    378c:	mov    QWORD PTR [rsp+0x10],rsi
    3791:	mov    rcx,r13
    3794:	mov    rdx,rbx
    3797:	mov    rdi,r14
    379a:	call   379f <botlish_fn_27+0x1f7>
			379b: R_X86_64_PLT32	botlish_fn_33-0x4 ; domain_loop<generic>
    379f:	test   rax,rax
    37a2:	jne    37cd <botlish_fn_27+0x225>
    37a8:	xor    rax,rax
    37ab:	mov    rbx,QWORD PTR [rsp+0x30]
    37b0:	mov    r12,QWORD PTR [rsp+0x38]
    37b5:	mov    r13,QWORD PTR [rsp+0x40]
    37ba:	mov    r14,QWORD PTR [rsp+0x48]
    37bf:	mov    r15,QWORD PTR [rsp+0x50]
    37c4:	add    rsp,0x60
    37c8:	mov    rsp,rbp
    37cb:	pop    rbp
    37cc:	ret
    37cd:	mov    rcx,rax
    37d0:	and    rcx,rbx
    37d3:	mov    rsi,rax
    37d6:	test   rcx,0x1
    37dd:	jne    3806 <botlish_fn_27+0x25e>
    37e3:	mov    rdx,rbx
    37e6:	mov    rdi,r14
    37e9:	call   37ee <botlish_fn_27+0x246>
			37ea: R_X86_64_PLT32	rt_int_cmp-0x4
    37ee:	mov    ecx,0x2
    37f3:	test   rax,rax
    37f6:	mov    rax,rcx
    37f9:	cmove  rax,QWORD PTR [rip+0x4f]        # 3850 <botlish_fn_27+0x2a8>
    3801:	jmp    382d <botlish_fn_27+0x285>
    3806:	mov    rdx,rbx
    3809:	mov    eax,0x2
    380e:	cmp    rsi,rdx
    3811:	cmove  rax,QWORD PTR [rip+0x37]        # 3850 <botlish_fn_27+0x2a8>
    3819:	jmp    382d <botlish_fn_27+0x285>
    381e:	mov    eax,0x2
    3823:	jmp    382d <botlish_fn_27+0x285>
    3828:	mov    eax,0x2
    382d:	mov    rbx,QWORD PTR [rsp+0x30]
    3832:	mov    r12,QWORD PTR [rsp+0x38]
    3837:	mov    r13,QWORD PTR [rsp+0x40]
    383c:	mov    r14,QWORD PTR [rsp+0x48]
    3841:	mov    r15,QWORD PTR [rsp+0x50]
    3846:	add    rsp,0x60
    384a:	mov    rsp,rbp
    384d:	pop    rbp
    384e:	ret
    384f:	add    BYTE PTR [rsi],al
    3851:	add    BYTE PTR [rax],al
    3853:	add    BYTE PTR [rax],al
    3855:	add    BYTE PTR [rax],al
	...

0000000000003858 <botlish_entry_27: <generic>>:
    3858:	push   rbp
    3859:	mov    rbp,rsp
    385c:	mov    rsi,QWORD PTR [rdx]
    385f:	call   3864 <botlish_entry_27+0xc>
			3860: R_X86_64_PLT32	botlish_fn_27-0x4 ; <generic>
    3864:	mov    rsp,rbp
    3867:	pop    rbp
    3868:	ret

0000000000003869 <botlish_fn_28: char_at<generic>>:
    3869:	push   rbp
    386a:	mov    rbp,rsp
    386d:	sub    rsp,0x50
    3871:	mov    QWORD PTR [rsp+0x20],rbx
    3876:	mov    QWORD PTR [rsp+0x28],r12
    387b:	mov    QWORD PTR [rsp+0x30],r13
    3880:	mov    QWORD PTR [rsp+0x38],r14
    3885:	mov    QWORD PTR [rsp+0x40],r15
    388a:	mov    r14,rcx
    388d:	mov    QWORD PTR [rsp],rsi
    3891:	mov    QWORD PTR [rsp+0x8],rdx
    3896:	mov    r13,rdx
    3899:	mov    QWORD PTR [rsp+0x10],0x3
    38a2:	mov    r9d,0x1
    38a8:	test   rsi,0x1
    38af:	jne    38cf <botlish_fn_28+0x66>
    38b5:	xor    r9d,r9d
    38b8:	test   rsi,0x7
    38bf:	jne    38cf <botlish_fn_28+0x66>
    38c5:	movzx  rax,BYTE PTR [rsi]
    38c9:	cmp    al,0x1
    38cb:	sete   r9b
    38cf:	test   r9b,r9b
    38d2:	jne    38f0 <botlish_fn_28+0x87>
    38d8:	mov    rax,QWORD PTR [rdi+0x10]
    38dc:	mov    rcx,QWORD PTR [rax+0x120]
    38e3:	xor    rdx,rdx
    38e6:	call   38eb <botlish_fn_28+0x82>
			38e7: R_X86_64_PLT32	rt_type_error-0x4
    38eb:	jmp    39ad <botlish_fn_28+0x144>
    38f0:	mov    r12,rdi
    38f3:	test   rsi,0x1
    38fa:	jne    3908 <botlish_fn_28+0x9f>
    3900:	mov    rbx,rsi
    3903:	jmp    3925 <botlish_fn_28+0xbc>
    3908:	mov    rax,rsi
    390b:	add    rax,0x2
    390f:	mov    rbx,rsi
    3912:	seto   cl
    3915:	test   cl,cl
    3917:	jne    3925 <botlish_fn_28+0xbc>
    391d:	mov    r15,rax
    3920:	jmp    3938 <botlish_fn_28+0xcf>
    3925:	mov    edx,0x3
    392a:	mov    rsi,rbx
    392d:	mov    rdi,r12
    3930:	call   3935 <botlish_fn_28+0xcc>
			3931: R_X86_64_PLT32	rt_int_add-0x4
    3935:	mov    r15,rax
    3938:	mov    ecx,0x1
    393d:	mov    rsi,rbx
    3940:	test   rsi,0x1
    3947:	jne    396d <botlish_fn_28+0x104>
    394d:	xor    ecx,ecx
    394f:	mov    rsi,rbx
    3952:	test   rsi,0x7
    3959:	jne    396d <botlish_fn_28+0x104>
    395f:	mov    rsi,rbx
    3962:	movzx  rcx,BYTE PTR [rsi]
    3966:	rex cmp cl,0x1
    396a:	sete   cl
    396d:	test   cl,cl
    396f:	jne    3993 <botlish_fn_28+0x12a>
    3975:	mov    rdi,r12
    3978:	mov    rsi,QWORD PTR [rdi+0x10]
    397c:	mov    rcx,QWORD PTR [rsi+0x128]
    3983:	xor    rdx,rdx
    3986:	mov    rsi,rbx
    3989:	call   398e <botlish_fn_28+0x125>
			398a: R_X86_64_PLT32	rt_type_error-0x4
    398e:	jmp    39ad <botlish_fn_28+0x144>
    3993:	mov    rdi,r12
    3996:	mov    rcx,r15
    3999:	mov    rdx,rbx
    399c:	mov    rsi,r13
    399f:	call   39a4 <botlish_fn_28+0x13b>
			39a0: R_X86_64_PLT32	rt_str_region_check-0x4
    39a4:	test   rax,rax
    39a7:	jne    39d2 <botlish_fn_28+0x169>
    39ad:	xor    rax,rax
    39b0:	mov    rbx,QWORD PTR [rsp+0x20]
    39b5:	mov    r12,QWORD PTR [rsp+0x28]
    39ba:	mov    r13,QWORD PTR [rsp+0x30]
    39bf:	mov    r14,QWORD PTR [rsp+0x38]
    39c4:	mov    r15,QWORD PTR [rsp+0x40]
    39c9:	add    rsp,0x50
    39cd:	mov    rsp,rbp
    39d0:	pop    rbp
    39d1:	ret
    39d2:	mov    rcx,r14
    39d5:	mov    rsi,rbx
    39d8:	mov    QWORD PTR [rcx],rsi
    39db:	mov    rax,r15
    39de:	mov    QWORD PTR [rcx+0x8],rax
    39e2:	mov    rax,r13
    39e5:	mov    rbx,QWORD PTR [rsp+0x20]
    39ea:	mov    r12,QWORD PTR [rsp+0x28]
    39ef:	mov    r13,QWORD PTR [rsp+0x30]
    39f4:	mov    r14,QWORD PTR [rsp+0x38]
    39f9:	mov    r15,QWORD PTR [rsp+0x40]
    39fe:	add    rsp,0x50
    3a02:	mov    rsp,rbp
    3a05:	pop    rbp
    3a06:	ret

0000000000003a07 <botlish_entry_28: char_at<generic>>:
    3a07:	push   rbp
    3a08:	mov    rbp,rsp
    3a0b:	ud2
    3a0d:	add    BYTE PTR [rax],al
	...

0000000000003a10 <botlish_fn_29: scan_local<generic>>:
    3a10:	push   rbp
    3a11:	mov    rbp,rsp
    3a14:	sub    rsp,0x80
    3a1b:	mov    QWORD PTR [rsp+0x50],rbx
    3a20:	mov    QWORD PTR [rsp+0x58],r12
    3a25:	mov    QWORD PTR [rsp+0x60],r13
    3a2a:	mov    QWORD PTR [rsp+0x68],r14
    3a2f:	mov    QWORD PTR [rsp+0x70],r15
    3a34:	mov    rax,rdi
    3a37:	mov    QWORD PTR [rsp+0x18],0x0
    3a40:	mov    QWORD PTR [rsp],rsi
    3a44:	mov    r14,rsi
    3a47:	mov    QWORD PTR [rsp+0x8],rdx
    3a4c:	mov    QWORD PTR [rsp+0x10],rcx
    3a51:	mov    r12,rcx
    3a54:	mov    r11d,0x1
    3a5a:	mov    rsi,r14
    3a5d:	test   rsi,0x1
    3a64:	jne    3a86 <botlish_fn_29+0x76>
    3a6a:	xor    r11d,r11d
    3a6d:	test   rsi,0x7
    3a74:	jne    3a86 <botlish_fn_29+0x76>
    3a7a:	movzx  rdi,BYTE PTR [rsi]
    3a7e:	cmp    dil,0x1
    3a82:	sete   r11b
    3a86:	test   r11b,r11b
    3a89:	jne    3aaa <botlish_fn_29+0x9a>
    3a8f:	mov    rdi,rax
    3a92:	mov    r9,QWORD PTR [rdi+0x10]
    3a96:	mov    rcx,QWORD PTR [r9+0xb0]
    3a9d:	xor    rdx,rdx
    3aa0:	call   3aa5 <botlish_fn_29+0x95>
			3aa1: R_X86_64_PLT32	rt_type_error-0x4
    3aa5:	jmp    3b5d <botlish_fn_29+0x14d>
    3aaa:	mov    r13,rdx
    3aad:	mov    r10,rsi
    3ab0:	and    r10,r13
    3ab3:	mov    r14,rsi
    3ab6:	test   r10,0x1
    3abd:	jne    3ae9 <botlish_fn_29+0xd9>
    3ac3:	mov    rbx,rax
    3ac6:	mov    rdx,r13
    3ac9:	mov    rsi,r14
    3acc:	mov    rdi,rbx
    3acf:	call   3ad4 <botlish_fn_29+0xc4>
			3ad0: R_X86_64_PLT32	rt_int_cmp-0x4
    3ad4:	mov    ecx,0x2
    3ad9:	test   rax,rax
    3adc:	cmovge rcx,QWORD PTR [rip+0x24c]        # 3d30 <botlish_fn_29+0x320>
    3ae4:	jmp    3aff <botlish_fn_29+0xef>
    3ae9:	mov    rbx,rax
    3aec:	mov    ecx,0x2
    3af1:	mov    rsi,r14
    3af4:	cmp    rsi,r13
    3af7:	cmovge rcx,QWORD PTR [rip+0x231]        # 3d30 <botlish_fn_29+0x320>
    3aff:	mov    eax,0x6
    3b04:	mov    QWORD PTR [rsp+0x30],rax
    3b09:	cmp    rcx,0x6
    3b0d:	je     3d03 <botlish_fn_29+0x2f3>
    3b13:	lea    rcx,[rsp+0x20]
    3b18:	mov    rdx,r12
    3b1b:	mov    rsi,r14
    3b1e:	mov    rdi,rbx
    3b21:	call   3b26 <botlish_fn_29+0x116>
			3b22: R_X86_64_PLT32	botlish_fn_28-0x4 ; char_at<generic>
    3b26:	mov    rsi,rax
    3b29:	mov    r15,rax
    3b2c:	test   rax,rsi
    3b2f:	je     3b5d <botlish_fn_29+0x14d>
    3b35:	mov    rdx,QWORD PTR [rsp+0x20]
    3b3a:	mov    QWORD PTR [rsp+0x40],rdx
    3b3f:	mov    rcx,QWORD PTR [rsp+0x28]
    3b44:	mov    QWORD PTR [rsp+0x38],rcx
    3b49:	mov    rsi,r15
    3b4c:	mov    rdi,rbx
    3b4f:	call   3b54 <botlish_fn_29+0x144>
			3b50: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    3b54:	test   rax,rax
    3b57:	jne    3b85 <botlish_fn_29+0x175>
    3b5d:	xor    rax,rax
    3b60:	mov    rbx,QWORD PTR [rsp+0x50]
    3b65:	mov    r12,QWORD PTR [rsp+0x58]
    3b6a:	mov    r13,QWORD PTR [rsp+0x60]
    3b6f:	mov    r14,QWORD PTR [rsp+0x68]
    3b74:	mov    r15,QWORD PTR [rsp+0x70]
    3b79:	add    rsp,0x80
    3b80:	mov    rsp,rbp
    3b83:	pop    rbp
    3b84:	ret
    3b85:	cmp    rax,0x6
    3b89:	je     3c84 <botlish_fn_29+0x274>
    3b8f:	mov    rax,QWORD PTR [rbx+0x10]
    3b93:	mov    r8,QWORD PTR [rax+0x130]
    3b9a:	mov    rcx,QWORD PTR [rsp+0x38]
    3b9f:	mov    rdx,QWORD PTR [rsp+0x40]
    3ba4:	mov    rsi,r15
    3ba7:	mov    rdi,rbx
    3baa:	call   3baf <botlish_fn_29+0x19f>
			3bab: R_X86_64_PLT32	rt_str_region_eq-0x4
    3baf:	cmp    rax,0x6
    3bb3:	je     3c7a <botlish_fn_29+0x26a>
    3bb9:	mov    rax,QWORD PTR [rbx+0x10]
    3bbd:	mov    r8,QWORD PTR [rax+0x138]
    3bc4:	mov    rcx,QWORD PTR [rsp+0x38]
    3bc9:	mov    rdx,QWORD PTR [rsp+0x40]
    3bce:	mov    rsi,r15
    3bd1:	mov    rdi,rbx
    3bd4:	call   3bd9 <botlish_fn_29+0x1c9>
			3bd5: R_X86_64_PLT32	rt_str_region_eq-0x4
    3bd9:	cmp    rax,0x6
    3bdd:	je     3c70 <botlish_fn_29+0x260>
    3be3:	mov    rax,QWORD PTR [rbx+0x10]
    3be7:	mov    r8,QWORD PTR [rax+0xd8]
    3bee:	mov    rcx,QWORD PTR [rsp+0x38]
    3bf3:	mov    rdx,QWORD PTR [rsp+0x40]
    3bf8:	mov    rsi,r15
    3bfb:	mov    rdi,rbx
    3bfe:	call   3c03 <botlish_fn_29+0x1f3>
			3bff: R_X86_64_PLT32	rt_str_region_eq-0x4
    3c03:	cmp    rax,0x6
    3c07:	je     3c66 <botlish_fn_29+0x256>
    3c0d:	mov    rax,QWORD PTR [rbx+0x10]
    3c11:	mov    r8,QWORD PTR [rax+0x120]
    3c18:	mov    rcx,QWORD PTR [rsp+0x38]
    3c1d:	mov    rdx,QWORD PTR [rsp+0x40]
    3c22:	mov    rsi,r15
    3c25:	mov    rdi,rbx
    3c28:	call   3c2d <botlish_fn_29+0x21d>
			3c29: R_X86_64_PLT32	rt_str_region_eq-0x4
    3c2d:	cmp    rax,0x6
    3c31:	je     3c5c <botlish_fn_29+0x24c>
    3c37:	mov    rax,QWORD PTR [rbx+0x10]
    3c3b:	mov    r8,QWORD PTR [rax+0x140]
    3c42:	mov    rcx,QWORD PTR [rsp+0x38]
    3c47:	mov    rdx,QWORD PTR [rsp+0x40]
    3c4c:	mov    rsi,r15
    3c4f:	mov    rdi,rbx
    3c52:	call   3c57 <botlish_fn_29+0x247>
			3c53: R_X86_64_PLT32	rt_str_region_eq-0x4
    3c57:	jmp    3c89 <botlish_fn_29+0x279>
    3c5c:	mov    rax,QWORD PTR [rsp+0x30]
    3c61:	jmp    3c89 <botlish_fn_29+0x279>
    3c66:	mov    rax,QWORD PTR [rsp+0x30]
    3c6b:	jmp    3c89 <botlish_fn_29+0x279>
    3c70:	mov    rax,QWORD PTR [rsp+0x30]
    3c75:	jmp    3c89 <botlish_fn_29+0x279>
    3c7a:	mov    rax,QWORD PTR [rsp+0x30]
    3c7f:	jmp    3c89 <botlish_fn_29+0x279>
    3c84:	mov    rax,QWORD PTR [rsp+0x30]
    3c89:	cmp    rax,0x6
    3c8d:	je     3c9b <botlish_fn_29+0x28b>
    3c93:	mov    rax,r14
    3c96:	jmp    3d06 <botlish_fn_29+0x2f6>
    3c9b:	mov    QWORD PTR [rsp+0x18],0x3
    3ca4:	mov    rsi,r14
    3ca7:	test   rsi,0x1
    3cae:	je     3cd4 <botlish_fn_29+0x2c4>
    3cb4:	mov    rsi,r14
    3cb7:	mov    rax,rsi
    3cba:	add    rax,0x2
    3cbe:	seto   cl
    3cc1:	test   cl,cl
    3cc3:	jne    3cd4 <botlish_fn_29+0x2c4>
    3cc9:	mov    rsi,rax
    3ccc:	mov    r14,rax
    3ccf:	jmp    3cea <botlish_fn_29+0x2da>
    3cd4:	mov    edx,0x3
    3cd9:	mov    rsi,r14
    3cdc:	mov    rdi,rbx
    3cdf:	call   3ce4 <botlish_fn_29+0x2d4>
			3ce0: R_X86_64_PLT32	rt_int_add-0x4
    3ce4:	mov    rsi,rax
    3ce7:	mov    r14,rax
    3cea:	mov    QWORD PTR [rsp],rsi
    3cee:	mov    QWORD PTR [rsp+0x8],r13
    3cf3:	mov    QWORD PTR [rsp+0x10],r12
    3cf8:	mov    rax,rbx
    3cfb:	mov    rdx,r13
    3cfe:	jmp    3a54 <botlish_fn_29+0x44>
    3d03:	mov    rax,r14
    3d06:	mov    rbx,QWORD PTR [rsp+0x50]
    3d0b:	mov    r12,QWORD PTR [rsp+0x58]
    3d10:	mov    r13,QWORD PTR [rsp+0x60]
    3d15:	mov    r14,QWORD PTR [rsp+0x68]
    3d1a:	mov    r15,QWORD PTR [rsp+0x70]
    3d1f:	add    rsp,0x80
    3d26:	mov    rsp,rbp
    3d29:	pop    rbp
    3d2a:	ret
    3d2b:	add    BYTE PTR [rax],al
    3d2d:	add    BYTE PTR [rax],al
    3d2f:	add    BYTE PTR [rsi],al
    3d31:	add    BYTE PTR [rax],al
    3d33:	add    BYTE PTR [rax],al
    3d35:	add    BYTE PTR [rax],al
	...

0000000000003d38 <botlish_entry_29: scan_local<generic>>:
    3d38:	push   rbp
    3d39:	mov    rbp,rsp
    3d3c:	mov    rsi,QWORD PTR [rdx]
    3d3f:	mov    r8,QWORD PTR [rdx+0x8]
    3d43:	mov    rcx,QWORD PTR [rdx+0x10]
    3d47:	mov    rdx,r8
    3d4a:	call   3d4f <botlish_entry_29+0x17>
			3d4b: R_X86_64_PLT32	botlish_fn_29-0x4 ; scan_local<generic>
    3d4f:	mov    rsp,rbp
    3d52:	pop    rbp
    3d53:	ret
    3d54:	add    BYTE PTR [rax],al
	...

0000000000003d58 <botlish_fn_30: scan_label<generic>>:
    3d58:	push   rbp
    3d59:	mov    rbp,rsp
    3d5c:	sub    rsp,0x80
    3d63:	mov    QWORD PTR [rsp+0x50],rbx
    3d68:	mov    QWORD PTR [rsp+0x58],r12
    3d6d:	mov    QWORD PTR [rsp+0x60],r13
    3d72:	mov    QWORD PTR [rsp+0x68],r14
    3d77:	mov    QWORD PTR [rsp+0x70],r15
    3d7c:	mov    QWORD PTR [rsp+0x18],0x0
    3d85:	mov    QWORD PTR [rsp],rsi
    3d89:	mov    r14,rsi
    3d8c:	mov    QWORD PTR [rsp+0x8],rdx
    3d91:	mov    QWORD PTR [rsp+0x10],rcx
    3d96:	mov    r12,rcx
    3d99:	mov    r11d,0x1
    3d9f:	mov    rsi,r14
    3da2:	test   rsi,0x1
    3da9:	jne    3dc9 <botlish_fn_30+0x71>
    3daf:	xor    r11d,r11d
    3db2:	test   rsi,0x7
    3db9:	jne    3dc9 <botlish_fn_30+0x71>
    3dbf:	movzx  rax,BYTE PTR [rsi]
    3dc3:	cmp    al,0x1
    3dc5:	sete   r11b
    3dc9:	test   r11b,r11b
    3dcc:	jne    3dea <botlish_fn_30+0x92>
    3dd2:	mov    rax,QWORD PTR [rdi+0x10]
    3dd6:	mov    rcx,QWORD PTR [rax+0xb0]
    3ddd:	xor    rdx,rdx
    3de0:	call   3de5 <botlish_fn_30+0x8d>
			3de1: R_X86_64_PLT32	rt_type_error-0x4
    3de5:	jmp    3e96 <botlish_fn_30+0x13e>
    3dea:	mov    r13,rdx
    3ded:	mov    rax,rsi
    3df0:	and    rax,r13
    3df3:	mov    r14,rsi
    3df6:	test   rax,0x1
    3dfc:	jne    3e25 <botlish_fn_30+0xcd>
    3e02:	mov    rbx,rdi
    3e05:	mov    rdx,r13
    3e08:	mov    rsi,r14
    3e0b:	call   3e10 <botlish_fn_30+0xb8>
			3e0c: R_X86_64_PLT32	rt_int_cmp-0x4
    3e10:	mov    ecx,0x2
    3e15:	test   rax,rax
    3e18:	cmovge rcx,QWORD PTR [rip+0x178]        # 3f98 <botlish_fn_30+0x240>
    3e20:	jmp    3e3b <botlish_fn_30+0xe3>
    3e25:	mov    rbx,rdi
    3e28:	mov    ecx,0x2
    3e2d:	mov    rsi,r14
    3e30:	cmp    rsi,r13
    3e33:	cmovge rcx,QWORD PTR [rip+0x15d]        # 3f98 <botlish_fn_30+0x240>
    3e3b:	mov    eax,0x6
    3e40:	mov    QWORD PTR [rsp+0x30],rax
    3e45:	cmp    rcx,0x6
    3e49:	je     3f6c <botlish_fn_30+0x214>
    3e4f:	lea    rcx,[rsp+0x20]
    3e54:	mov    rdx,r12
    3e57:	mov    rsi,r14
    3e5a:	mov    rdi,rbx
    3e5d:	call   3e62 <botlish_fn_30+0x10a>
			3e5e: R_X86_64_PLT32	botlish_fn_28-0x4 ; char_at<generic>
    3e62:	test   rax,rax
    3e65:	mov    r15,rax
    3e68:	je     3e96 <botlish_fn_30+0x13e>
    3e6e:	mov    rdx,QWORD PTR [rsp+0x20]
    3e73:	mov    QWORD PTR [rsp+0x40],rdx
    3e78:	mov    rcx,QWORD PTR [rsp+0x28]
    3e7d:	mov    QWORD PTR [rsp+0x38],rcx
    3e82:	mov    rsi,r15
    3e85:	mov    rdi,rbx
    3e88:	call   3e8d <botlish_fn_30+0x135>
			3e89: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    3e8d:	test   rax,rax
    3e90:	jne    3ebe <botlish_fn_30+0x166>
    3e96:	xor    rax,rax
    3e99:	mov    rbx,QWORD PTR [rsp+0x50]
    3e9e:	mov    r12,QWORD PTR [rsp+0x58]
    3ea3:	mov    r13,QWORD PTR [rsp+0x60]
    3ea8:	mov    r14,QWORD PTR [rsp+0x68]
    3ead:	mov    r15,QWORD PTR [rsp+0x70]
    3eb2:	add    rsp,0x80
    3eb9:	mov    rsp,rbp
    3ebc:	pop    rbp
    3ebd:	ret
    3ebe:	cmp    rax,0x6
    3ec2:	je     3eed <botlish_fn_30+0x195>
    3ec8:	mov    r11,QWORD PTR [rbx+0x10]
    3ecc:	mov    r8,QWORD PTR [r11+0x140]
    3ed3:	mov    rcx,QWORD PTR [rsp+0x38]
    3ed8:	mov    rdx,QWORD PTR [rsp+0x40]
    3edd:	mov    rsi,r15
    3ee0:	mov    rdi,rbx
    3ee3:	call   3ee8 <botlish_fn_30+0x190>
			3ee4: R_X86_64_PLT32	rt_str_region_eq-0x4
    3ee8:	jmp    3ef2 <botlish_fn_30+0x19a>
    3eed:	mov    rax,QWORD PTR [rsp+0x30]
    3ef2:	cmp    rax,0x6
    3ef6:	je     3f04 <botlish_fn_30+0x1ac>
    3efc:	mov    rax,r14
    3eff:	jmp    3f6f <botlish_fn_30+0x217>
    3f04:	mov    QWORD PTR [rsp+0x18],0x3
    3f0d:	mov    rsi,r14
    3f10:	test   rsi,0x1
    3f17:	je     3f3d <botlish_fn_30+0x1e5>
    3f1d:	mov    rsi,r14
    3f20:	mov    rax,rsi
    3f23:	add    rax,0x2
    3f27:	seto   cl
    3f2a:	test   cl,cl
    3f2c:	jne    3f3d <botlish_fn_30+0x1e5>
    3f32:	mov    rsi,rax
    3f35:	mov    r14,rax
    3f38:	jmp    3f53 <botlish_fn_30+0x1fb>
    3f3d:	mov    edx,0x3
    3f42:	mov    rsi,r14
    3f45:	mov    rdi,rbx
    3f48:	call   3f4d <botlish_fn_30+0x1f5>
			3f49: R_X86_64_PLT32	rt_int_add-0x4
    3f4d:	mov    rsi,rax
    3f50:	mov    r14,rax
    3f53:	mov    QWORD PTR [rsp],rsi
    3f57:	mov    QWORD PTR [rsp+0x8],r13
    3f5c:	mov    QWORD PTR [rsp+0x10],r12
    3f61:	mov    rdx,r13
    3f64:	mov    rdi,rbx
    3f67:	jmp    3d99 <botlish_fn_30+0x41>
    3f6c:	mov    rax,r14
    3f6f:	mov    rbx,QWORD PTR [rsp+0x50]
    3f74:	mov    r12,QWORD PTR [rsp+0x58]
    3f79:	mov    r13,QWORD PTR [rsp+0x60]
    3f7e:	mov    r14,QWORD PTR [rsp+0x68]
    3f83:	mov    r15,QWORD PTR [rsp+0x70]
    3f88:	add    rsp,0x80
    3f8f:	mov    rsp,rbp
    3f92:	pop    rbp
    3f93:	ret
    3f94:	add    BYTE PTR [rax],al
    3f96:	add    BYTE PTR [rax],al
    3f98:	(bad)
    3f99:	add    BYTE PTR [rax],al
    3f9b:	add    BYTE PTR [rax],al
    3f9d:	add    BYTE PTR [rax],al
	...

0000000000003fa0 <botlish_entry_30: scan_label<generic>>:
    3fa0:	push   rbp
    3fa1:	mov    rbp,rsp
    3fa4:	mov    rsi,QWORD PTR [rdx]
    3fa7:	mov    r8,QWORD PTR [rdx+0x8]
    3fab:	mov    rcx,QWORD PTR [rdx+0x10]
    3faf:	mov    rdx,r8
    3fb2:	call   3fb7 <botlish_entry_30+0x17>
			3fb3: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_label<generic>
    3fb7:	mov    rsp,rbp
    3fba:	pop    rbp
    3fbb:	ret
    3fbc:	add    BYTE PTR [rax],al
	...

0000000000003fc0 <botlish_fn_31: scan_alpha<generic>>:
    3fc0:	push   rbp
    3fc1:	mov    rbp,rsp
    3fc4:	sub    rsp,0x50
    3fc8:	mov    QWORD PTR [rsp+0x30],rbx
    3fcd:	mov    QWORD PTR [rsp+0x38],r12
    3fd2:	mov    QWORD PTR [rsp+0x40],r13
    3fd7:	mov    QWORD PTR [rsp+0x48],r14
    3fdc:	mov    r14,rdi
    3fdf:	mov    QWORD PTR [rsp+0x18],0x0
    3fe8:	mov    QWORD PTR [rsp],rsi
    3fec:	mov    r13,rsi
    3fef:	mov    QWORD PTR [rsp+0x8],rdx
    3ff4:	mov    r12,rdx
    3ff7:	mov    QWORD PTR [rsp+0x10],rcx
    3ffc:	mov    rbx,rcx
    3fff:	mov    r11d,0x1
    4005:	mov    rsi,r13
    4008:	test   rsi,0x1
    400f:	jne    402f <botlish_fn_31+0x6f>
    4015:	xor    r11d,r11d
    4018:	test   rsi,0x7
    401f:	jne    402f <botlish_fn_31+0x6f>
    4025:	movzx  rax,BYTE PTR [rsi]
    4029:	cmp    al,0x1
    402b:	sete   r11b
    402f:	test   r11b,r11b
    4032:	jne    4053 <botlish_fn_31+0x93>
    4038:	mov    rdi,r14
    403b:	mov    rax,QWORD PTR [rdi+0x10]
    403f:	mov    rcx,QWORD PTR [rax+0xb0]
    4046:	xor    rdx,rdx
    4049:	call   404e <botlish_fn_31+0x8e>
			404a: R_X86_64_PLT32	rt_type_error-0x4
    404e:	jmp    40e2 <botlish_fn_31+0x122>
    4053:	mov    rax,rsi
    4056:	and    rax,r12
    4059:	mov    r13,rsi
    405c:	test   rax,0x1
    4062:	jne    408b <botlish_fn_31+0xcb>
    4068:	mov    rdx,r12
    406b:	mov    rsi,r13
    406e:	mov    rdi,r14
    4071:	call   4076 <botlish_fn_31+0xb6>
			4072: R_X86_64_PLT32	rt_int_cmp-0x4
    4076:	mov    ecx,0x2
    407b:	test   rax,rax
    407e:	cmovge rcx,QWORD PTR [rip+0x112]        # 4198 <botlish_fn_31+0x1d8>
    4086:	jmp    409e <botlish_fn_31+0xde>
    408b:	mov    ecx,0x2
    4090:	mov    rsi,r13
    4093:	cmp    rsi,r12
    4096:	cmovge rcx,QWORD PTR [rip+0xfa]        # 4198 <botlish_fn_31+0x1d8>
    409e:	cmp    rcx,0x6
    40a2:	je     4176 <botlish_fn_31+0x1b6>
    40a8:	lea    rcx,[rsp+0x20]
    40ad:	mov    rdx,rbx
    40b0:	mov    rsi,r13
    40b3:	mov    rdi,r14
    40b6:	call   40bb <botlish_fn_31+0xfb>
			40b7: R_X86_64_PLT32	botlish_fn_28-0x4 ; char_at<generic>
    40bb:	test   rax,rax
    40be:	mov    rsi,rax
    40c1:	je     40e2 <botlish_fn_31+0x122>
    40c7:	mov    rdx,QWORD PTR [rsp+0x20]
    40cc:	mov    rcx,QWORD PTR [rsp+0x28]
    40d1:	mov    rdi,r14
    40d4:	call   40d9 <botlish_fn_31+0x119>
			40d5: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    40d9:	test   rax,rax
    40dc:	jne    4102 <botlish_fn_31+0x142>
    40e2:	xor    rax,rax
    40e5:	mov    rbx,QWORD PTR [rsp+0x30]
    40ea:	mov    r12,QWORD PTR [rsp+0x38]
    40ef:	mov    r13,QWORD PTR [rsp+0x40]
    40f4:	mov    r14,QWORD PTR [rsp+0x48]
    40f9:	add    rsp,0x50
    40fd:	mov    rsp,rbp
    4100:	pop    rbp
    4101:	ret
    4102:	cmp    rax,0x6
    4106:	je     4114 <botlish_fn_31+0x154>
    410c:	mov    rax,r13
    410f:	jmp    4179 <botlish_fn_31+0x1b9>
    4114:	mov    QWORD PTR [rsp+0x18],0x3
    411d:	mov    rsi,r13
    4120:	test   rsi,0x1
    4127:	je     414d <botlish_fn_31+0x18d>
    412d:	mov    rsi,r13
    4130:	mov    r11,rsi
    4133:	add    r11,0x2
    4137:	seto   al
    413a:	test   al,al
    413c:	jne    414d <botlish_fn_31+0x18d>
    4142:	mov    rsi,r11
    4145:	mov    r13,r11
    4148:	jmp    4163 <botlish_fn_31+0x1a3>
    414d:	mov    edx,0x3
    4152:	mov    rsi,r13
    4155:	mov    rdi,r14
    4158:	call   415d <botlish_fn_31+0x19d>
			4159: R_X86_64_PLT32	rt_int_add-0x4
    415d:	mov    rsi,rax
    4160:	mov    r13,rax
    4163:	mov    QWORD PTR [rsp],rsi
    4167:	mov    QWORD PTR [rsp+0x8],r12
    416c:	mov    QWORD PTR [rsp+0x10],rbx
    4171:	jmp    3fff <botlish_fn_31+0x3f>
    4176:	mov    rax,r13
    4179:	mov    rbx,QWORD PTR [rsp+0x30]
    417e:	mov    r12,QWORD PTR [rsp+0x38]
    4183:	mov    r13,QWORD PTR [rsp+0x40]
    4188:	mov    r14,QWORD PTR [rsp+0x48]
    418d:	add    rsp,0x50
    4191:	mov    rsp,rbp
    4194:	pop    rbp
    4195:	ret
    4196:	add    BYTE PTR [rax],al
    4198:	(bad)
    4199:	add    BYTE PTR [rax],al
    419b:	add    BYTE PTR [rax],al
    419d:	add    BYTE PTR [rax],al
	...

00000000000041a0 <botlish_entry_31: scan_alpha<generic>>:
    41a0:	push   rbp
    41a1:	mov    rbp,rsp
    41a4:	mov    rsi,QWORD PTR [rdx]
    41a7:	mov    r8,QWORD PTR [rdx+0x8]
    41ab:	mov    rcx,QWORD PTR [rdx+0x10]
    41af:	mov    rdx,r8
    41b2:	call   41b7 <botlish_entry_31+0x17>
			41b3: R_X86_64_PLT32	botlish_fn_31-0x4 ; scan_alpha<generic>
    41b7:	mov    rsp,rbp
    41ba:	pop    rbp
    41bb:	ret
    41bc:	add    BYTE PTR [rax],al
	...

00000000000041c0 <botlish_fn_32: tld_ok<generic>>:
    41c0:	push   rbp
    41c1:	mov    rbp,rsp
    41c4:	sub    rsp,0x40
    41c8:	mov    QWORD PTR [rsp+0x20],rbx
    41cd:	mov    QWORD PTR [rsp+0x28],r12
    41d2:	mov    QWORD PTR [rsp+0x30],r13
    41d7:	mov    QWORD PTR [rsp+0x38],r14
    41dc:	mov    rbx,rdi
    41df:	mov    QWORD PTR [rsp],rsi
    41e3:	mov    r12,rsi
    41e6:	mov    QWORD PTR [rsp+0x8],rdx
    41eb:	mov    r14,rdx
    41ee:	mov    QWORD PTR [rsp+0x10],rcx
    41f3:	mov    rdx,r14
    41f6:	mov    rsi,r12
    41f9:	mov    rdi,rbx
    41fc:	call   4201 <botlish_fn_32+0x41>
			41fd: R_X86_64_PLT32	botlish_fn_31-0x4 ; scan_alpha<generic>
    4201:	mov    rsi,rax
    4204:	mov    r13,rax
    4207:	test   rax,rsi
    420a:	je     42cd <botlish_fn_32+0x10d>
    4210:	mov    rax,r13
    4213:	mov    QWORD PTR [rsp+0x8],rax
    4218:	mov    rdx,r14
    421b:	and    rax,rdx
    421e:	test   rax,0x1
    4224:	jne    424d <botlish_fn_32+0x8d>
    422a:	mov    rsi,r13
    422d:	mov    rdi,rbx
    4230:	call   4235 <botlish_fn_32+0x75>
			4231: R_X86_64_PLT32	rt_int_cmp-0x4
    4235:	mov    ecx,0x2
    423a:	test   rax,rax
    423d:	cmove  rcx,QWORD PTR [rip+0x15b]        # 43a0 <botlish_fn_32+0x1e0>
    4245:	mov    rax,r13
    4248:	jmp    4260 <botlish_fn_32+0xa0>
    424d:	mov    ecx,0x2
    4252:	mov    rax,r13
    4255:	cmp    rax,rdx
    4258:	cmove  rcx,QWORD PTR [rip+0x140]        # 43a0 <botlish_fn_32+0x1e0>
    4260:	cmp    rcx,0x6
    4264:	je     4277 <botlish_fn_32+0xb7>
    426a:	mov    ecx,0x2
    426f:	mov    rax,rcx
    4272:	jmp    437f <botlish_fn_32+0x1bf>
    4277:	mov    ecx,0x1
    427c:	mov    rsi,r12
    427f:	test   rsi,0x1
    4286:	jne    42ac <botlish_fn_32+0xec>
    428c:	xor    ecx,ecx
    428e:	mov    rsi,r12
    4291:	test   rsi,0x7
    4298:	jne    42ac <botlish_fn_32+0xec>
    429e:	mov    rsi,r12
    42a1:	movzx  rcx,BYTE PTR [rsi]
    42a5:	rex cmp cl,0x1
    42a9:	sete   cl
    42ac:	test   cl,cl
    42ae:	jne    42ed <botlish_fn_32+0x12d>
    42b4:	mov    rdi,rbx
    42b7:	mov    rsi,QWORD PTR [rdi+0x10]
    42bb:	mov    rcx,QWORD PTR [rsi+0x140]
    42c2:	xor    rdx,rdx
    42c5:	mov    rsi,r12
    42c8:	call   42cd <botlish_fn_32+0x10d>
			42c9: R_X86_64_PLT32	rt_type_error-0x4
    42cd:	xor    rax,rax
    42d0:	mov    rbx,QWORD PTR [rsp+0x20]
    42d5:	mov    r12,QWORD PTR [rsp+0x28]
    42da:	mov    r13,QWORD PTR [rsp+0x30]
    42df:	mov    r14,QWORD PTR [rsp+0x38]
    42e4:	add    rsp,0x40
    42e8:	mov    rsp,rbp
    42eb:	pop    rbp
    42ec:	ret
    42ed:	mov    rsi,r12
    42f0:	mov    rdi,rax
    42f3:	and    rdi,rsi
    42f6:	test   rdi,0x1
    42fd:	jne    430e <botlish_fn_32+0x14e>
    4303:	mov    rdx,r12
    4306:	mov    rsi,rax
    4309:	jmp    4331 <botlish_fn_32+0x171>
    430e:	mov    rsi,r12
    4311:	mov    r8,rax
    4314:	sub    r8,rsi
    4317:	mov    r13,rax
    431a:	seto   r10b
    431e:	lea    rsi,[r8+0x1]
    4322:	test   r10b,r10b
    4325:	je     433c <botlish_fn_32+0x17c>
    432b:	mov    rdx,r12
    432e:	mov    rsi,r13
    4331:	mov    rdi,rbx
    4334:	call   4339 <botlish_fn_32+0x179>
			4335: R_X86_64_PLT32	rt_int_sub-0x4
    4339:	mov    rsi,rax
    433c:	test   rsi,0x1
    4343:	jne    436e <botlish_fn_32+0x1ae>
    4349:	mov    edx,0x5
    434e:	mov    rdi,rbx
    4351:	call   4356 <botlish_fn_32+0x196>
			4352: R_X86_64_PLT32	rt_int_cmp-0x4
    4356:	mov    ecx,0x2
    435b:	test   rax,rax
    435e:	mov    rax,rcx
    4361:	cmovge rax,QWORD PTR [rip+0x37]        # 43a0 <botlish_fn_32+0x1e0>
    4369:	jmp    437f <botlish_fn_32+0x1bf>
    436e:	mov    eax,0x2
    4373:	cmp    rsi,0x5
    4377:	cmovge rax,QWORD PTR [rip+0x21]        # 43a0 <botlish_fn_32+0x1e0>
    437f:	mov    rbx,QWORD PTR [rsp+0x20]
    4384:	mov    r12,QWORD PTR [rsp+0x28]
    4389:	mov    r13,QWORD PTR [rsp+0x30]
    438e:	mov    r14,QWORD PTR [rsp+0x38]
    4393:	add    rsp,0x40
    4397:	mov    rsp,rbp
    439a:	pop    rbp
    439b:	ret
    439c:	add    BYTE PTR [rax],al
    439e:	add    BYTE PTR [rax],al
    43a0:	(bad)
    43a1:	add    BYTE PTR [rax],al
    43a3:	add    BYTE PTR [rax],al
    43a5:	add    BYTE PTR [rax],al
	...

00000000000043a8 <botlish_entry_32: tld_ok<generic>>:
    43a8:	push   rbp
    43a9:	mov    rbp,rsp
    43ac:	mov    rsi,QWORD PTR [rdx]
    43af:	mov    r8,QWORD PTR [rdx+0x8]
    43b3:	mov    rcx,QWORD PTR [rdx+0x10]
    43b7:	mov    rdx,r8
    43ba:	call   43bf <botlish_entry_32+0x17>
			43bb: R_X86_64_PLT32	botlish_fn_32-0x4 ; tld_ok<generic>
    43bf:	mov    rsp,rbp
    43c2:	pop    rbp
    43c3:	ret
    43c4:	add    BYTE PTR [rax],al
	...

00000000000043c8 <botlish_fn_33: domain_loop<generic>>:
    43c8:	push   rbp
    43c9:	mov    rbp,rsp
    43cc:	sub    rsp,0x70
    43d0:	mov    QWORD PTR [rsp+0x40],rbx
    43d5:	mov    QWORD PTR [rsp+0x48],r12
    43da:	mov    QWORD PTR [rsp+0x50],r13
    43df:	mov    QWORD PTR [rsp+0x58],r14
    43e4:	mov    QWORD PTR [rsp+0x60],r15
    43e9:	mov    QWORD PTR [rsp+0x18],0x0
    43f2:	mov    QWORD PTR [rsp],rsi
    43f6:	mov    QWORD PTR [rsp+0x8],rdx
    43fb:	mov    QWORD PTR [rsp+0x10],rcx
    4400:	lea    rbx,[rsp+0x20]
    4405:	mov    r12,rdi
    4408:	mov    r13,rcx
    440b:	mov    r14,rdx
    440e:	mov    QWORD PTR [rsp+0x30],rsi
    4413:	mov    rcx,r13
    4416:	mov    rdx,r14
    4419:	mov    rsi,QWORD PTR [rsp+0x30]
    441e:	mov    rdi,r12
    4421:	call   4426 <botlish_fn_33+0x5e>
			4422: R_X86_64_PLT32	botlish_fn_30-0x4 ; scan_label<generic>
    4426:	mov    rcx,rax
    4429:	mov    r15,rax
    442c:	test   rax,rcx
    442f:	je     457f <botlish_fn_33+0x1b7>
    4435:	mov    rax,r15
    4438:	mov    QWORD PTR [rsp],rax
    443c:	mov    rdx,QWORD PTR [rsp+0x30]
    4441:	and    rax,rdx
    4444:	test   rax,0x1
    444a:	jne    4469 <botlish_fn_33+0xa1>
    4450:	mov    rsi,r15
    4453:	mov    rdi,r12
    4456:	call   445b <botlish_fn_33+0x93>
			4457: R_X86_64_PLT32	rt_value_eq-0x4
    445b:	test   rax,rax
    445e:	je     457f <botlish_fn_33+0x1b7>
    4464:	jmp    4479 <botlish_fn_33+0xb1>
    4469:	mov    eax,0x2
    446e:	cmp    r15,rdx
    4471:	cmove  rax,QWORD PTR [rip+0x187]        # 4600 <botlish_fn_33+0x238>
    4479:	cmp    rax,0x6
    447d:	je     45d5 <botlish_fn_33+0x20d>
    4483:	mov    rax,r15
    4486:	and    rax,r14
    4489:	test   rax,0x1
    448f:	jne    44b8 <botlish_fn_33+0xf0>
    4495:	mov    rdx,r14
    4498:	mov    rsi,r15
    449b:	mov    rdi,r12
    449e:	call   44a3 <botlish_fn_33+0xdb>
			449f: R_X86_64_PLT32	rt_int_cmp-0x4
    44a3:	mov    ecx,0x2
    44a8:	test   rax,rax
    44ab:	cmovge rcx,QWORD PTR [rip+0x14d]        # 4600 <botlish_fn_33+0x238>
    44b3:	jmp    44c8 <botlish_fn_33+0x100>
    44b8:	mov    ecx,0x2
    44bd:	cmp    r15,r14
    44c0:	cmovge rcx,QWORD PTR [rip+0x138]        # 4600 <botlish_fn_33+0x238>
    44c8:	cmp    rcx,0x6
    44cc:	je     45c6 <botlish_fn_33+0x1fe>
    44d2:	mov    rcx,rbx
    44d5:	mov    rdx,r13
    44d8:	mov    rsi,r15
    44db:	mov    rdi,r12
    44de:	call   44e3 <botlish_fn_33+0x11b>
			44df: R_X86_64_PLT32	botlish_fn_28-0x4 ; char_at<generic>
    44e3:	test   rax,rax
    44e6:	je     457f <botlish_fn_33+0x1b7>
    44ec:	mov    rdx,QWORD PTR [rsp+0x20]
    44f1:	mov    rcx,QWORD PTR [rsp+0x28]
    44f6:	mov    rsi,QWORD PTR [r12+0x10]
    44fb:	mov    r8,QWORD PTR [rsi+0x130]
    4502:	mov    rsi,rax
    4505:	mov    rdi,r12
    4508:	call   450d <botlish_fn_33+0x145>
			4509: R_X86_64_PLT32	rt_str_region_eq-0x4
    450d:	cmp    rax,0x6
    4511:	je     4523 <botlish_fn_33+0x15b>
    4517:	mov    r14,0xffffffffffffffff
    451e:	jmp    45cd <botlish_fn_33+0x205>
    4523:	mov    QWORD PTR [rsp+0x18],0x3
    452c:	test   r15,0x1
    4533:	je     454b <botlish_fn_33+0x183>
    4539:	mov    rdx,r15
    453c:	add    rdx,0x2
    4540:	seto   al
    4543:	test   al,al
    4545:	je     455e <botlish_fn_33+0x196>
    454b:	mov    edx,0x3
    4550:	mov    rsi,r15
    4553:	mov    rdi,r12
    4556:	call   455b <botlish_fn_33+0x193>
			4557: R_X86_64_PLT32	rt_int_add-0x4
    455b:	mov    rdx,rax
    455e:	mov    QWORD PTR [rsp],rdx
    4562:	mov    r15,rdx
    4565:	mov    rcx,r13
    4568:	mov    rdx,r14
    456b:	mov    rsi,r15
    456e:	mov    rdi,r12
    4571:	call   4576 <botlish_fn_33+0x1ae>
			4572: R_X86_64_PLT32	botlish_fn_32-0x4 ; tld_ok<generic>
    4576:	test   rax,rax
    4579:	jne    45a4 <botlish_fn_33+0x1dc>
    457f:	xor    rax,rax
    4582:	mov    rbx,QWORD PTR [rsp+0x40]
    4587:	mov    r12,QWORD PTR [rsp+0x48]
    458c:	mov    r13,QWORD PTR [rsp+0x50]
    4591:	mov    r14,QWORD PTR [rsp+0x58]
    4596:	mov    r15,QWORD PTR [rsp+0x60]
    459b:	add    rsp,0x70
    459f:	mov    rsp,rbp
    45a2:	pop    rbp
    45a3:	ret
    45a4:	cmp    rax,0x6
    45a8:	je     45cd <botlish_fn_33+0x205>
    45ae:	mov    QWORD PTR [rsp],r15
    45b2:	mov    QWORD PTR [rsp+0x8],r14
    45b7:	mov    QWORD PTR [rsp+0x10],r13
    45bc:	mov    QWORD PTR [rsp+0x30],r15
    45c1:	jmp    4413 <botlish_fn_33+0x4b>
    45c6:	mov    r14,0xffffffffffffffff
    45cd:	mov    rax,r14
    45d0:	jmp    45dc <botlish_fn_33+0x214>
    45d5:	mov    rax,0xffffffffffffffff
    45dc:	mov    rbx,QWORD PTR [rsp+0x40]
    45e1:	mov    r12,QWORD PTR [rsp+0x48]
    45e6:	mov    r13,QWORD PTR [rsp+0x50]
    45eb:	mov    r14,QWORD PTR [rsp+0x58]
    45f0:	mov    r15,QWORD PTR [rsp+0x60]
    45f5:	add    rsp,0x70
    45f9:	mov    rsp,rbp
    45fc:	pop    rbp
    45fd:	ret
    45fe:	add    BYTE PTR [rax],al
    4600:	(bad)
    4601:	add    BYTE PTR [rax],al
    4603:	add    BYTE PTR [rax],al
    4605:	add    BYTE PTR [rax],al
	...

0000000000004608 <botlish_entry_33: domain_loop<generic>>:
    4608:	push   rbp
    4609:	mov    rbp,rsp
    460c:	mov    rsi,QWORD PTR [rdx]
    460f:	mov    r8,QWORD PTR [rdx+0x8]
    4613:	mov    rcx,QWORD PTR [rdx+0x10]
    4617:	mov    rdx,r8
    461a:	call   461f <botlish_entry_33+0x17>
			461b: R_X86_64_PLT32	botlish_fn_33-0x4 ; domain_loop<generic>
    461f:	mov    rsp,rbp
    4622:	pop    rbp
    4623:	ret

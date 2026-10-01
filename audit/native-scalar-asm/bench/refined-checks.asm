; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 9068  (per function: 1425 39 317 609 74 74 74 128 128 379 262 222 176 238 440 456 468 1076 145 83 103 468 491 398 451 344)
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
;   botlish_fn_9 / botlish_entry_9 -> web::emailish?<str>
;   botlish_fn_10 / botlish_entry_10 -> char_at<generic>
;   botlish_fn_11 / botlish_entry_11 -> char_at<generic>
;   botlish_fn_12 / botlish_entry_12 -> local_char?<str>
;   botlish_fn_13 / botlish_entry_13 -> local_char?<generic>
;   botlish_fn_14 / botlish_entry_14 -> scan_while<any, block(e239)>
;   botlish_fn_15 / botlish_entry_15 -> scan_while<any, native(is_tcl_alpha)>
;   botlish_fn_16 / botlish_entry_16 -> tld?<generic>
;   botlish_fn_17 / botlish_entry_17 -> domain?<generic>
;   botlish_fn_18 / botlish_entry_18 -> web::is_unreserved<int>
;   botlish_fn_19 / botlish_entry_19 -> web::uri_escape_text<str>
;   botlish_fn_20 / botlish_entry_20 -> high_nibble<int>
;   botlish_fn_21 / botlish_entry_21 -> hex_pair<int>
;   botlish_fn_22 / botlish_entry_22 -> esc_bytes<List[int], int, str>
;   botlish_fn_23 / botlish_entry_23 -> esc_char<str>
;   botlish_fn_24 / botlish_entry_24 -> esc_from<str, int, str>
;   botlish_fn_25 / botlish_entry_25 -> check<int, int, str, str>


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
      33:	mov    QWORD PTR [rsp+0x28],0x0
      3c:	mov    QWORD PTR [rsp+0x30],0x0
      45:	mov    QWORD PTR [rsp+0x38],0x0
      4e:	mov    QWORD PTR [rsp+0x40],0x0
      57:	mov    QWORD PTR [rsp+0x48],0x0
      60:	mov    QWORD PTR [rsp+0x50],0x0
      69:	mov    QWORD PTR [rsp+0x58],0x0
      72:	mov    QWORD PTR [rsp+0x60],0x0
      7b:	mov    QWORD PTR [rsp+0x68],0x0
      84:	mov    QWORD PTR [rsp+0x70],0x0
      8d:	mov    QWORD PTR [rsp+0x78],0x0
      96:	mov    rax,QWORD PTR [rdi+0x10]
      9a:	mov    rax,QWORD PTR [rax]
      9d:	mov    QWORD PTR [rsp],rax
      a1:	mov    rcx,QWORD PTR [rdi+0x10]
      a5:	mov    rcx,QWORD PTR [rcx+0x8]
      a9:	mov    QWORD PTR [rsp+0x8],rcx
      ae:	mov    rdx,QWORD PTR [rdi+0x10]
      b2:	mov    r8,QWORD PTR [rdx+0x10]
      b6:	mov    QWORD PTR [rsp+0x10],r8
      bb:	mov    rdx,QWORD PTR [rdi+0x10]
      bf:	mov    rsi,QWORD PTR [rdx+0x18]
      c3:	mov    QWORD PTR [rsp+0x18],rsi
      c8:	mov    rdx,QWORD PTR [rdi+0x10]
      cc:	mov    QWORD PTR [rsp+0x158],rdi
      d4:	mov    rdi,QWORD PTR [rdx+0x20]
      d8:	mov    QWORD PTR [rsp+0x20],rdi
      dd:	lea    rdx,[rsp+0x80]
      e5:	mov    QWORD PTR [rsp+0x80],rax
      ed:	mov    QWORD PTR [rsp+0x88],rcx
      f5:	mov    QWORD PTR [rsp+0x90],r8
      fd:	mov    QWORD PTR [rsp+0x98],rsi
     105:	mov    QWORD PTR [rsp+0xa0],rdi
     10d:	mov    esi,0x5
     112:	mov    rdi,QWORD PTR [rsp+0x158]
     11a:	call   11f <botlish_fn_0+0x11f>
			11b: R_X86_64_PLT32	rt_list_new-0x4
     11f:	test   rax,rax
     122:	je     4f2 <botlish_fn_0+0x4f2>
     128:	mov    QWORD PTR [rsp],rax
     12c:	mov    rsi,rax
     12f:	mov    rdi,QWORD PTR [rsp+0x158]
     137:	call   13c <botlish_fn_0+0x13c>
			138: R_X86_64_PLT32	rt_set_from_list-0x4
     13c:	mov    rdi,QWORD PTR [rsp+0x158]
     144:	mov    rcx,QWORD PTR [rdi+0x30]
     148:	mov    QWORD PTR [rcx],rax
     14b:	mov    rax,QWORD PTR [rdi+0x10]
     14f:	mov    rcx,QWORD PTR [rax+0x28]
     153:	mov    QWORD PTR [rsp],rcx
     157:	mov    QWORD PTR [rsp+0x178],rcx
     15f:	mov    rax,QWORD PTR [rdi+0x10]
     163:	mov    rdx,QWORD PTR [rax+0x30]
     167:	mov    QWORD PTR [rsp+0x8],rdx
     16c:	mov    QWORD PTR [rsp+0x170],rdx
     174:	mov    rax,QWORD PTR [rdi+0x10]
     178:	mov    rsi,QWORD PTR [rax+0x38]
     17c:	mov    QWORD PTR [rsp+0x10],rsi
     181:	mov    QWORD PTR [rsp+0x168],rsi
     189:	mov    rax,QWORD PTR [rdi+0x10]
     18d:	mov    rdi,QWORD PTR [rax+0x40]
     191:	mov    QWORD PTR [rsp+0x18],rdi
     196:	mov    QWORD PTR [rsp+0x160],rdi
     19e:	mov    rdi,QWORD PTR [rsp+0x158]
     1a6:	mov    rax,QWORD PTR [rdi+0x10]
     1aa:	mov    rdi,QWORD PTR [rax+0x48]
     1ae:	mov    QWORD PTR [rsp+0x20],rdi
     1b3:	mov    rax,QWORD PTR [rsp+0x158]
     1bb:	mov    rax,QWORD PTR [rax+0x10]
     1bf:	mov    r8,QWORD PTR [rax+0x50]
     1c3:	mov    QWORD PTR [rsp+0x28],r8
     1c8:	mov    rax,QWORD PTR [rsp+0x158]
     1d0:	mov    rax,QWORD PTR [rax+0x10]
     1d4:	mov    r9,QWORD PTR [rax+0x58]
     1d8:	mov    QWORD PTR [rsp+0x30],r9
     1dd:	mov    rax,QWORD PTR [rsp+0x158]
     1e5:	mov    rax,QWORD PTR [rax+0x10]
     1e9:	mov    r10,QWORD PTR [rax+0x60]
     1ed:	mov    QWORD PTR [rsp+0x38],r10
     1f2:	mov    rax,QWORD PTR [rsp+0x158]
     1fa:	mov    rax,QWORD PTR [rax+0x10]
     1fe:	mov    r11,QWORD PTR [rax+0x68]
     202:	mov    QWORD PTR [rsp+0x40],r11
     207:	mov    rax,QWORD PTR [rsp+0x158]
     20f:	mov    rax,QWORD PTR [rax+0x10]
     213:	mov    rbx,QWORD PTR [rax+0x70]
     217:	mov    QWORD PTR [rsp+0x48],rbx
     21c:	mov    rax,QWORD PTR [rsp+0x158]
     224:	mov    rax,QWORD PTR [rax+0x10]
     228:	mov    r12,QWORD PTR [rax+0x78]
     22c:	mov    QWORD PTR [rsp+0x50],r12
     231:	mov    rax,QWORD PTR [rsp+0x158]
     239:	mov    rax,QWORD PTR [rax+0x10]
     23d:	mov    r13,QWORD PTR [rax+0x80]
     244:	mov    QWORD PTR [rsp+0x58],r13
     249:	mov    rax,QWORD PTR [rsp+0x158]
     251:	mov    rax,QWORD PTR [rax+0x10]
     255:	mov    r14,QWORD PTR [rax+0x88]
     25c:	mov    QWORD PTR [rsp+0x60],r14
     261:	mov    rax,QWORD PTR [rsp+0x158]
     269:	mov    rax,QWORD PTR [rax+0x10]
     26d:	mov    r15,QWORD PTR [rax+0x90]
     274:	mov    QWORD PTR [rsp+0x68],r15
     279:	mov    rax,QWORD PTR [rsp+0x158]
     281:	mov    rax,QWORD PTR [rax+0x10]
     285:	mov    rax,QWORD PTR [rax+0x98]
     28c:	mov    QWORD PTR [rsp+0x70],rax
     291:	mov    rcx,QWORD PTR [rsp+0x158]
     299:	mov    rcx,QWORD PTR [rcx+0x10]
     29d:	mov    rcx,QWORD PTR [rcx+0xa0]
     2a4:	mov    QWORD PTR [rsp+0x78],rcx
     2a9:	lea    rdx,[rsp+0xa8]
     2b1:	mov    rsi,QWORD PTR [rsp+0x178]
     2b9:	mov    QWORD PTR [rsp+0xa8],rsi
     2c1:	mov    rsi,QWORD PTR [rsp+0x170]
     2c9:	mov    QWORD PTR [rsp+0xb0],rsi
     2d1:	mov    rsi,QWORD PTR [rsp+0x168]
     2d9:	mov    QWORD PTR [rsp+0xb8],rsi
     2e1:	mov    rsi,QWORD PTR [rsp+0x160]
     2e9:	mov    QWORD PTR [rsp+0xc0],rsi
     2f1:	mov    QWORD PTR [rsp+0xc8],rdi
     2f9:	mov    QWORD PTR [rsp+0xd0],r8
     301:	mov    QWORD PTR [rsp+0xd8],r9
     309:	mov    QWORD PTR [rsp+0xe0],r10
     311:	mov    QWORD PTR [rsp+0xe8],r11
     319:	mov    QWORD PTR [rsp+0xf0],rbx
     321:	mov    QWORD PTR [rsp+0xf8],r12
     329:	mov    QWORD PTR [rsp+0x100],r13
     331:	mov    QWORD PTR [rsp+0x108],r14
     339:	mov    QWORD PTR [rsp+0x110],r15
     341:	mov    QWORD PTR [rsp+0x118],rax
     349:	mov    QWORD PTR [rsp+0x120],rcx
     351:	mov    esi,0x10
     356:	mov    rdi,QWORD PTR [rsp+0x158]
     35e:	call   363 <botlish_fn_0+0x363>
			35f: R_X86_64_PLT32	rt_list_new-0x4
     363:	test   rax,rax
     366:	je     4f2 <botlish_fn_0+0x4f2>
     36c:	mov    rdi,QWORD PTR [rsp+0x158]
     374:	mov    r11,QWORD PTR [rdi+0x30]
     378:	mov    QWORD PTR [r11+0x8],rax
     37c:	mov    QWORD PTR [rsp],0x16c
     384:	mov    QWORD PTR [rsp+0x8],0x174
     38d:	mov    QWORD PTR [rsp+0x10],0x2fc
     396:	mov    QWORD PTR [rsp+0x18],0x3f4
     39f:	lea    rdx,[rsp+0x128]
     3a7:	mov    QWORD PTR [rsp+0x128],0x16c
     3b3:	mov    QWORD PTR [rsp+0x130],0x174
     3bf:	mov    QWORD PTR [rsp+0x138],0x2fc
     3cb:	mov    QWORD PTR [rsp+0x140],0x3f4
     3d7:	mov    esi,0x4
     3dc:	call   3e1 <botlish_fn_0+0x3e1>
			3dd: R_X86_64_PLT32	rt_list_new-0x4
     3e1:	test   rax,rax
     3e4:	je     4f2 <botlish_fn_0+0x4f2>
     3ea:	mov    QWORD PTR [rsp],rax
     3ee:	mov    rsi,rax
     3f1:	mov    rdi,QWORD PTR [rsp+0x158]
     3f9:	call   3fe <botlish_fn_0+0x3fe>
			3fa: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::set<List[UnicodeChar]>
     3fe:	test   rax,rax
     401:	je     4f2 <botlish_fn_0+0x4f2>
     407:	mov    rdi,QWORD PTR [rsp+0x158]
     40f:	mov    rcx,QWORD PTR [rdi+0x30]
     413:	mov    QWORD PTR [rcx+0x10],rax
     417:	mov    rax,QWORD PTR [rdi+0x10]
     41b:	mov    rsi,QWORD PTR [rax+0xa8]
     422:	mov    QWORD PTR [rsp],rsi
     426:	call   42b <botlish_fn_0+0x42b>
			427: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_escape_text<str>
     42b:	test   rax,rax
     42e:	je     4f2 <botlish_fn_0+0x4f2>
     434:	mov    QWORD PTR [rsp],rax
     438:	mov    rbx,rax
     43b:	mov    edx,0x1
     440:	mov    QWORD PTR [rsp+0x8],0x1
     449:	mov    rdi,QWORD PTR [rsp+0x158]
     451:	mov    rcx,QWORD PTR [rdi+0x10]
     455:	mov    rcx,QWORD PTR [rcx+0xb0]
     45c:	mov    QWORD PTR [rsp+0x10],rcx
     461:	mov    esi,0x190
     466:	mov    r8,rbx
     469:	call   46e <botlish_fn_0+0x46e>
			46a: R_X86_64_PLT32	botlish_fn_25-0x4 ; check<int, int, str, str>
     46e:	mov    r12,rax
     471:	test   r12,r12
     474:	je     4f2 <botlish_fn_0+0x4f2>
     47a:	mov    QWORD PTR [rsp+0x8],r12
     47f:	mov    edx,0x1
     484:	mov    QWORD PTR [rsp+0x10],0x1
     48d:	mov    rdi,QWORD PTR [rsp+0x158]
     495:	mov    rax,QWORD PTR [rdi+0x10]
     499:	mov    rcx,QWORD PTR [rax+0xb8]
     4a0:	mov    QWORD PTR [rsp+0x18],rcx
     4a5:	mov    esi,0x190
     4aa:	mov    r8,rbx
     4ad:	call   4b2 <botlish_fn_0+0x4b2>
			4ae: R_X86_64_PLT32	botlish_fn_25-0x4 ; check<int, int, str, str>
     4b2:	test   rax,rax
     4b5:	je     4f2 <botlish_fn_0+0x4f2>
     4bb:	mov    QWORD PTR [rsp],rax
     4bf:	lea    rdx,[rsp+0x148]
     4c7:	mov    QWORD PTR [rsp+0x148],r12
     4cf:	mov    QWORD PTR [rsp+0x150],rax
     4d7:	mov    esi,0x2
     4dc:	mov    rdi,QWORD PTR [rsp+0x158]
     4e4:	call   4e9 <botlish_fn_0+0x4e9>
			4e5: R_X86_64_PLT32	rt_list_new-0x4
     4e9:	test   rax,rax
     4ec:	jne    529 <botlish_fn_0+0x529>
     4f2:	xor    rax,rax
     4f5:	mov    rbx,QWORD PTR [rsp+0x180]
     4fd:	mov    r12,QWORD PTR [rsp+0x188]
     505:	mov    r13,QWORD PTR [rsp+0x190]
     50d:	mov    r14,QWORD PTR [rsp+0x198]
     515:	mov    r15,QWORD PTR [rsp+0x1a0]
     51d:	add    rsp,0x1b0
     524:	mov    rsp,rbp
     527:	pop    rbp
     528:	ret
     529:	mov    rbx,QWORD PTR [rsp+0x180]
     531:	mov    r12,QWORD PTR [rsp+0x188]
     539:	mov    r13,QWORD PTR [rsp+0x190]
     541:	mov    r14,QWORD PTR [rsp+0x198]
     549:	mov    r15,QWORD PTR [rsp+0x1a0]
     551:	add    rsp,0x1b0
     558:	mov    rsp,rbp
     55b:	pop    rbp
     55c:	ret

000000000000055d <botlish_entry_0: <program entry>>:
     55d:	push   rbp
     55e:	mov    rbp,rsp
     561:	call   566 <botlish_entry_0+0x9>
			562: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     566:	mov    rsp,rbp
     569:	pop    rbp
     56a:	ret

000000000000056b <botlish_fn_1: char::codepoint<UnicodeChar>>:
     56b:	push   rbp
     56c:	mov    rbp,rsp
     56f:	call   574 <botlish_fn_1+0x9>
			570: R_X86_64_PLT32	rt_char_codepoint-0x4
     574:	mov    rsp,rbp
     577:	pop    rbp
     578:	ret

0000000000000579 <botlish_entry_1: char::codepoint<UnicodeChar>>:
     579:	push   rbp
     57a:	mov    rbp,rsp
     57d:	mov    rsi,QWORD PTR [rdx]
     580:	call   585 <botlish_entry_1+0xc>
			581: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     585:	mov    rsp,rbp
     588:	pop    rbp
     589:	ret
     58a:	add    BYTE PTR [rax],al
     58c:	add    BYTE PTR [rax],al
	...

0000000000000590 <botlish_fn_2: byte::from_int<int>>:
     590:	push   rbp
     591:	mov    rbp,rsp
     594:	sub    rsp,0x10
     598:	mov    QWORD PTR [rsp],rbx
     59c:	mov    QWORD PTR [rsp+0x8],r12
     5a1:	mov    r12,rdi
     5a4:	test   rsi,0x1
     5ab:	mov    rbx,rsi
     5ae:	jne    5da <botlish_fn_2+0x4a>
     5b4:	mov    edx,0x1
     5b9:	mov    rsi,rbx
     5bc:	mov    rdi,r12
     5bf:	call   5c4 <botlish_fn_2+0x34>
			5c0: R_X86_64_PLT32	rt_int_cmp-0x4
     5c4:	mov    r8d,0x2
     5ca:	test   rax,rax
     5cd:	cmovl  r8,QWORD PTR [rip+0xb3]        # 688 <botlish_fn_2+0xf8>
     5d5:	jmp    5eb <botlish_fn_2+0x5b>
     5da:	mov    r8d,0x2
     5e0:	test   rbx,rbx
     5e3:	cmovle r8,QWORD PTR [rip+0x9d]        # 688 <botlish_fn_2+0xf8>
     5eb:	test   rbx,0x1
     5f2:	jne    61d <botlish_fn_2+0x8d>
     5f8:	mov    edx,0x1ff
     5fd:	mov    rsi,rbx
     600:	mov    rdi,r12
     603:	call   608 <botlish_fn_2+0x78>
			604: R_X86_64_PLT32	rt_int_cmp-0x4
     608:	mov    ecx,0x2
     60d:	test   rax,rax
     610:	cmovg  rcx,QWORD PTR [rip+0x70]        # 688 <botlish_fn_2+0xf8>
     618:	jmp    631 <botlish_fn_2+0xa1>
     61d:	mov    ecx,0x2
     622:	cmp    rbx,0x1ff
     629:	cmovg  rcx,QWORD PTR [rip+0x57]        # 688 <botlish_fn_2+0xf8>
     631:	cmp    rcx,0x6
     635:	je     658 <botlish_fn_2+0xc8>
     63b:	mov    edx,0x1
     640:	mov    rax,rbx
     643:	sar    rax,1
     646:	mov    rbx,QWORD PTR [rsp]
     64a:	mov    r12,QWORD PTR [rsp+0x8]
     64f:	add    rsp,0x10
     653:	mov    rsp,rbp
     656:	pop    rbp
     657:	ret
     658:	mov    rdi,r12
     65b:	mov    rax,QWORD PTR [rdi+0x10]
     65f:	mov    rdx,QWORD PTR [rax+0xc0]
     666:	mov    esi,0x1
     66b:	call   670 <botlish_fn_2+0xe0>
			66c: R_X86_64_PLT32	rt_fail_declared-0x4
     670:	xor    rdx,rdx
     673:	mov    rax,rdx
     676:	mov    rbx,QWORD PTR [rsp]
     67a:	mov    r12,QWORD PTR [rsp+0x8]
     67f:	add    rsp,0x10
     683:	mov    rsp,rbp
     686:	pop    rbp
     687:	ret
     688:	(bad)
     689:	add    BYTE PTR [rax],al
     68b:	add    BYTE PTR [rax],al
     68d:	add    BYTE PTR [rax],al
	...

0000000000000690 <botlish_entry_2: byte::from_int<int>>:
     690:	push   rbp
     691:	mov    rbp,rsp
     694:	mov    rsi,QWORD PTR [rdx]
     697:	call   69c <botlish_entry_2+0xc>
			698: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     69c:	shl    rax,1
     69f:	or     rax,0x1
     6a3:	mov    rcx,rax
     6a6:	xor    rax,rax
     6a9:	test   rdx,rdx
     6ac:	cmovne rax,rcx
     6b0:	mov    rsp,rbp
     6b3:	pop    rbp
     6b4:	ret
     6b5:	add    BYTE PTR [rax],al
	...

00000000000006b8 <botlish_fn_3: byte::set<List[UnicodeChar]>>:
     6b8:	push   rbp
     6b9:	mov    rbp,rsp
     6bc:	sub    rsp,0x60
     6c0:	mov    QWORD PTR [rsp+0x30],rbx
     6c5:	mov    QWORD PTR [rsp+0x38],r12
     6ca:	mov    QWORD PTR [rsp+0x40],r13
     6cf:	mov    QWORD PTR [rsp+0x48],r14
     6d4:	mov    QWORD PTR [rsp+0x50],r15
     6d9:	mov    r13,rdi
     6dc:	mov    QWORD PTR [rsp+0x18],0x0
     6e5:	mov    QWORD PTR [rsp+0x20],0x0
     6ee:	mov    QWORD PTR [rsp],rsi
     6f2:	mov    rbx,rsi
     6f5:	mov    rdi,r13
     6f8:	call   6fd <botlish_fn_3+0x45>
			6f9: R_X86_64_PLT32	rt_list_len-0x4
     6fd:	mov    QWORD PTR [rsp+0x8],rax
     702:	mov    r12,rax
     705:	mov    QWORD PTR [rsp+0x10],0x1
     70e:	xor    rdx,rdx
     711:	mov    rdi,r13
     714:	mov    rsi,rdx
     717:	call   71c <botlish_fn_3+0x64>
			718: R_X86_64_PLT32	rt_list_new-0x4
     71c:	test   rax,rax
     71f:	je     847 <botlish_fn_3+0x18f>
     725:	mov    QWORD PTR [rsp+0x18],rax
     72a:	mov    esi,0x1
     72f:	mov    r14,rsi
     732:	mov    r15,rax
     735:	mov    rax,rsi
     738:	and    rax,r12
     73b:	mov    r14,rsi
     73e:	test   rax,0x1
     744:	jne    76d <botlish_fn_3+0xb5>
     74a:	mov    rdx,r12
     74d:	mov    rsi,r14
     750:	mov    rdi,r13
     753:	call   758 <botlish_fn_3+0xa0>
			754: R_X86_64_PLT32	rt_int_cmp-0x4
     758:	mov    ecx,0x2
     75d:	test   rax,rax
     760:	cmovl  rcx,QWORD PTR [rip+0x178]        # 8e0 <botlish_fn_3+0x228>
     768:	jmp    780 <botlish_fn_3+0xc8>
     76d:	mov    ecx,0x2
     772:	mov    rsi,r14
     775:	cmp    rsi,r12
     778:	cmovl  rcx,QWORD PTR [rip+0x160]        # 8e0 <botlish_fn_3+0x228>
     780:	cmp    rcx,0x6
     784:	je     7bb <botlish_fn_3+0x103>
     78a:	mov    rsi,r15
     78d:	mov    QWORD PTR [rsp],rsi
     791:	mov    rdi,r13
     794:	call   799 <botlish_fn_3+0xe1>
			795: R_X86_64_PLT32	rt_set_from_list-0x4
     799:	mov    rbx,QWORD PTR [rsp+0x30]
     79e:	mov    r12,QWORD PTR [rsp+0x38]
     7a3:	mov    r13,QWORD PTR [rsp+0x40]
     7a8:	mov    r14,QWORD PTR [rsp+0x48]
     7ad:	mov    r15,QWORD PTR [rsp+0x50]
     7b2:	add    rsp,0x60
     7b6:	mov    rsp,rbp
     7b9:	pop    rbp
     7ba:	ret
     7bb:	mov    rsi,r14
     7be:	test   rsi,0x1
     7c5:	je     7e1 <botlish_fn_3+0x129>
     7cb:	mov    rcx,QWORD PTR [rbx+0x8]
     7cf:	mov    rsi,r14
     7d2:	mov    rax,rsi
     7d5:	sar    rax,1
     7d8:	cmp    rax,rcx
     7db:	jb     800 <botlish_fn_3+0x148>
     7e1:	mov    rdx,r14
     7e4:	mov    rsi,rbx
     7e7:	mov    rdi,r13
     7ea:	call   7ef <botlish_fn_3+0x137>
			7eb: R_X86_64_PLT32	rt_list_get-0x4
     7ef:	test   rax,rax
     7f2:	je     847 <botlish_fn_3+0x18f>
     7f8:	mov    rsi,rax
     7fb:	jmp    808 <botlish_fn_3+0x150>
     800:	mov    rsi,QWORD PTR [rbx+0x10]
     804:	mov    rsi,QWORD PTR [rsi+rax*8]
     808:	mov    rdi,r13
     80b:	call   810 <botlish_fn_3+0x158>
			80c: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     810:	mov    rsi,rax
     813:	mov    rdi,r13
     816:	call   81b <botlish_fn_3+0x163>
			817: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     81b:	test   rdx,rdx
     81e:	je     847 <botlish_fn_3+0x18f>
     824:	shl    rax,1
     827:	mov    rdx,rax
     82a:	or     rdx,0x1
     82e:	mov    QWORD PTR [rsp+0x20],rdx
     833:	mov    rsi,r15
     836:	mov    rdi,r13
     839:	call   83e <botlish_fn_3+0x186>
			83a: R_X86_64_PLT32	rt_list_append-0x4
     83e:	test   rax,rax
     841:	jne    86c <botlish_fn_3+0x1b4>
     847:	xor    rax,rax
     84a:	mov    rbx,QWORD PTR [rsp+0x30]
     84f:	mov    r12,QWORD PTR [rsp+0x38]
     854:	mov    r13,QWORD PTR [rsp+0x40]
     859:	mov    r14,QWORD PTR [rsp+0x48]
     85e:	mov    r15,QWORD PTR [rsp+0x50]
     863:	add    rsp,0x60
     867:	mov    rsp,rbp
     86a:	pop    rbp
     86b:	ret
     86c:	mov    QWORD PTR [rsp+0x18],rax
     871:	mov    r15,rax
     874:	mov    edx,0x3
     879:	mov    QWORD PTR [rsp+0x20],0x3
     882:	mov    rsi,r14
     885:	test   rsi,0x1
     88c:	jne    89a <botlish_fn_3+0x1e2>
     892:	mov    rsi,r14
     895:	jmp    8c2 <botlish_fn_3+0x20a>
     89a:	mov    rsi,r14
     89d:	mov    rcx,rsi
     8a0:	add    rcx,0x2
     8a4:	seto   al
     8a7:	test   al,al
     8a9:	je     8b7 <botlish_fn_3+0x1ff>
     8af:	mov    rsi,r14
     8b2:	jmp    8c2 <botlish_fn_3+0x20a>
     8b7:	mov    rsi,rcx
     8ba:	mov    r14,rcx
     8bd:	jmp    8d0 <botlish_fn_3+0x218>
     8c2:	mov    rdi,r13
     8c5:	call   8ca <botlish_fn_3+0x212>
			8c6: R_X86_64_PLT32	rt_int_add-0x4
     8ca:	mov    rsi,rax
     8cd:	mov    r14,rax
     8d0:	mov    QWORD PTR [rsp+0x10],rsi
     8d5:	mov    rsi,r14
     8d8:	jmp    735 <botlish_fn_3+0x7d>
     8dd:	add    BYTE PTR [rax],al
     8df:	add    BYTE PTR [rsi],al
     8e1:	add    BYTE PTR [rax],al
     8e3:	add    BYTE PTR [rax],al
     8e5:	add    BYTE PTR [rax],al
	...

00000000000008e8 <botlish_entry_3: byte::set<List[UnicodeChar]>>:
     8e8:	push   rbp
     8e9:	mov    rbp,rsp
     8ec:	mov    rsi,QWORD PTR [rdx]
     8ef:	call   8f4 <botlish_entry_3+0xc>
			8f0: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::set<List[UnicodeChar]>
     8f4:	mov    rsp,rbp
     8f7:	pop    rbp
     8f8:	ret

00000000000008f9 <botlish_fn_4: ascii::is_digit<int>>:
     8f9:	push   rbp
     8fa:	mov    rbp,rsp
     8fd:	cmp    rsi,0x30
     901:	jge    911 <botlish_fn_4+0x18>
     907:	mov    eax,0x2
     90c:	jmp    92a <botlish_fn_4+0x31>
     911:	cmp    rsi,0x39
     915:	jle    925 <botlish_fn_4+0x2c>
     91b:	mov    eax,0x2
     920:	jmp    92a <botlish_fn_4+0x31>
     925:	mov    eax,0x6
     92a:	mov    rsp,rbp
     92d:	pop    rbp
     92e:	ret

000000000000092f <botlish_entry_4: ascii::is_digit<int>>:
     92f:	push   rbp
     930:	mov    rbp,rsp
     933:	mov    rsi,QWORD PTR [rdx]
     936:	sar    rsi,1
     939:	call   93e <botlish_entry_4+0xf>
			93a: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     93e:	mov    rsp,rbp
     941:	pop    rbp
     942:	ret

0000000000000943 <botlish_fn_5: ascii::is_upper<int>>:
     943:	push   rbp
     944:	mov    rbp,rsp
     947:	cmp    rsi,0x41
     94b:	jge    95b <botlish_fn_5+0x18>
     951:	mov    eax,0x2
     956:	jmp    974 <botlish_fn_5+0x31>
     95b:	cmp    rsi,0x5a
     95f:	jle    96f <botlish_fn_5+0x2c>
     965:	mov    eax,0x2
     96a:	jmp    974 <botlish_fn_5+0x31>
     96f:	mov    eax,0x6
     974:	mov    rsp,rbp
     977:	pop    rbp
     978:	ret

0000000000000979 <botlish_entry_5: ascii::is_upper<int>>:
     979:	push   rbp
     97a:	mov    rbp,rsp
     97d:	mov    rsi,QWORD PTR [rdx]
     980:	sar    rsi,1
     983:	call   988 <botlish_entry_5+0xf>
			984: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     988:	mov    rsp,rbp
     98b:	pop    rbp
     98c:	ret

000000000000098d <botlish_fn_6: ascii::is_lower<int>>:
     98d:	push   rbp
     98e:	mov    rbp,rsp
     991:	cmp    rsi,0x61
     995:	jge    9a5 <botlish_fn_6+0x18>
     99b:	mov    eax,0x2
     9a0:	jmp    9be <botlish_fn_6+0x31>
     9a5:	cmp    rsi,0x7a
     9a9:	jle    9b9 <botlish_fn_6+0x2c>
     9af:	mov    eax,0x2
     9b4:	jmp    9be <botlish_fn_6+0x31>
     9b9:	mov    eax,0x6
     9be:	mov    rsp,rbp
     9c1:	pop    rbp
     9c2:	ret

00000000000009c3 <botlish_entry_6: ascii::is_lower<int>>:
     9c3:	push   rbp
     9c4:	mov    rbp,rsp
     9c7:	mov    rsi,QWORD PTR [rdx]
     9ca:	sar    rsi,1
     9cd:	call   9d2 <botlish_entry_6+0xf>
			9ce: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     9d2:	mov    rsp,rbp
     9d5:	pop    rbp
     9d6:	ret

00000000000009d7 <botlish_fn_7: ascii::is_alphabetic<int>>:
     9d7:	push   rbp
     9d8:	mov    rbp,rsp
     9db:	sub    rsp,0x10
     9df:	mov    QWORD PTR [rsp],r12
     9e3:	mov    QWORD PTR [rsp+0x8],r14
     9e8:	mov    r12,rsi
     9eb:	mov    r14,rdi
     9ee:	mov    rsi,r12
     9f1:	mov    rdi,r14
     9f4:	call   9f9 <botlish_fn_7+0x22>
			9f5: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     9f9:	cmp    rax,0x6
     9fd:	je     a2c <botlish_fn_7+0x55>
     a03:	mov    rsi,r12
     a06:	mov    rdi,r14
     a09:	call   a0e <botlish_fn_7+0x37>
			a0a: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     a0e:	cmp    rax,0x6
     a12:	je     a22 <botlish_fn_7+0x4b>
     a18:	mov    eax,0x2
     a1d:	jmp    a31 <botlish_fn_7+0x5a>
     a22:	mov    eax,0x6
     a27:	jmp    a31 <botlish_fn_7+0x5a>
     a2c:	mov    eax,0x6
     a31:	mov    r12,QWORD PTR [rsp]
     a35:	mov    r14,QWORD PTR [rsp+0x8]
     a3a:	add    rsp,0x10
     a3e:	mov    rsp,rbp
     a41:	pop    rbp
     a42:	ret

0000000000000a43 <botlish_entry_7: ascii::is_alphabetic<int>>:
     a43:	push   rbp
     a44:	mov    rbp,rsp
     a47:	mov    rsi,QWORD PTR [rdx]
     a4a:	sar    rsi,1
     a4d:	call   a52 <botlish_entry_7+0xf>
			a4e: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     a52:	mov    rsp,rbp
     a55:	pop    rbp
     a56:	ret

0000000000000a57 <botlish_fn_8: ascii::is_alphanumeric<int>>:
     a57:	push   rbp
     a58:	mov    rbp,rsp
     a5b:	sub    rsp,0x10
     a5f:	mov    QWORD PTR [rsp],r12
     a63:	mov    QWORD PTR [rsp+0x8],r14
     a68:	mov    r12,rsi
     a6b:	mov    r14,rdi
     a6e:	mov    rsi,r12
     a71:	mov    rdi,r14
     a74:	call   a79 <botlish_fn_8+0x22>
			a75: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     a79:	cmp    rax,0x6
     a7d:	je     aac <botlish_fn_8+0x55>
     a83:	mov    rsi,r12
     a86:	mov    rdi,r14
     a89:	call   a8e <botlish_fn_8+0x37>
			a8a: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     a8e:	cmp    rax,0x6
     a92:	je     aa2 <botlish_fn_8+0x4b>
     a98:	mov    eax,0x2
     a9d:	jmp    ab1 <botlish_fn_8+0x5a>
     aa2:	mov    eax,0x6
     aa7:	jmp    ab1 <botlish_fn_8+0x5a>
     aac:	mov    eax,0x6
     ab1:	mov    r12,QWORD PTR [rsp]
     ab5:	mov    r14,QWORD PTR [rsp+0x8]
     aba:	add    rsp,0x10
     abe:	mov    rsp,rbp
     ac1:	pop    rbp
     ac2:	ret

0000000000000ac3 <botlish_entry_8: ascii::is_alphanumeric<int>>:
     ac3:	push   rbp
     ac4:	mov    rbp,rsp
     ac7:	mov    rsi,QWORD PTR [rdx]
     aca:	sar    rsi,1
     acd:	call   ad2 <botlish_entry_8+0xf>
			ace: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
     ad2:	mov    rsp,rbp
     ad5:	pop    rbp
     ad6:	ret

0000000000000ad7 <botlish_fn_9: web::emailish?<str>>:
     ad7:	push   rbp
     ad8:	mov    rbp,rsp
     adb:	sub    rsp,0x50
     adf:	mov    QWORD PTR [rsp+0x30],rbx
     ae4:	mov    QWORD PTR [rsp+0x38],r12
     ae9:	mov    QWORD PTR [rsp+0x40],r13
     aee:	mov    QWORD PTR [rsp+0x48],r14
     af3:	mov    r13,rdi
     af6:	mov    QWORD PTR [rsp],rsi
     afa:	mov    r12,rsi
     afd:	mov    rsi,r12
     b00:	mov    rdi,r13
     b03:	call   b08 <botlish_fn_9+0x31>
			b04: R_X86_64_PLT32	rt_str_len-0x4
     b08:	mov    r14,rax
     b0b:	mov    QWORD PTR [rsp+0x8],rax
     b10:	mov    esi,0x1
     b15:	mov    QWORD PTR [rsp+0x10],0x1
     b1e:	mov    rdi,r13
     b21:	mov    rax,QWORD PTR [rdi+0x10]
     b25:	mov    rdx,QWORD PTR [rax+0xc8]
     b2c:	mov    QWORD PTR [rsp+0x18],rdx
     b31:	mov    rcx,r14
     b34:	mov    r8,r12
     b37:	call   b3c <botlish_fn_9+0x65>
			b38: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<any, block(e239)>
     b3c:	test   rax,rax
     b3f:	je     be2 <botlish_fn_9+0x10b>
     b45:	mov    QWORD PTR [rsp+0x10],rax
     b4a:	mov    rbx,rax
     b4d:	sar    rbx,1
     b50:	mov    rsi,rax
     b53:	test   rbx,rbx
     b56:	je     c11 <botlish_fn_9+0x13a>
     b5c:	mov    rax,r14
     b5f:	mov    rcx,rax
     b62:	sar    rcx,1
     b65:	cmp    rbx,rcx
     b68:	jge    c07 <botlish_fn_9+0x130>
     b6e:	lea    rcx,[rsp+0x20]
     b73:	mov    rdx,r12
     b76:	mov    rdi,r13
     b79:	call   b7e <botlish_fn_9+0xa7>
			b7a: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
     b7e:	test   rax,rax
     b81:	mov    rsi,rax
     b84:	je     be2 <botlish_fn_9+0x10b>
     b8a:	mov    rdx,QWORD PTR [rsp+0x20]
     b8f:	mov    rcx,QWORD PTR [rsp+0x28]
     b94:	mov    rdi,r13
     b97:	mov    rax,QWORD PTR [rdi+0x10]
     b9b:	mov    r8,QWORD PTR [rax+0xd0]
     ba2:	call   ba7 <botlish_fn_9+0xd0>
			ba3: R_X86_64_PLT32	rt_str_region_eq-0x4
     ba7:	cmp    rax,0x6
     bab:	je     bbb <botlish_fn_9+0xe4>
     bb1:	mov    eax,0x2
     bb6:	jmp    c16 <botlish_fn_9+0x13f>
     bbb:	lea    rsi,[rbx+0x1]
     bbf:	shl    rsi,1
     bc2:	or     rsi,0x1
     bc6:	mov    QWORD PTR [rsp+0x10],rsi
     bcb:	mov    rcx,r12
     bce:	mov    rdx,r14
     bd1:	mov    rdi,r13
     bd4:	call   bd9 <botlish_fn_9+0x102>
			bd5: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<generic>
     bd9:	test   rax,rax
     bdc:	jne    c16 <botlish_fn_9+0x13f>
     be2:	xor    rax,rax
     be5:	mov    rbx,QWORD PTR [rsp+0x30]
     bea:	mov    r12,QWORD PTR [rsp+0x38]
     bef:	mov    r13,QWORD PTR [rsp+0x40]
     bf4:	mov    r14,QWORD PTR [rsp+0x48]
     bf9:	add    rsp,0x50
     bfd:	mov    rsp,rbp
     c00:	pop    rbp
     c01:	ret
     c02:	jmp    c16 <botlish_fn_9+0x13f>
     c07:	mov    eax,0x2
     c0c:	jmp    c16 <botlish_fn_9+0x13f>
     c11:	mov    eax,0x2
     c16:	mov    rbx,QWORD PTR [rsp+0x30]
     c1b:	mov    r12,QWORD PTR [rsp+0x38]
     c20:	mov    r13,QWORD PTR [rsp+0x40]
     c25:	mov    r14,QWORD PTR [rsp+0x48]
     c2a:	add    rsp,0x50
     c2e:	mov    rsp,rbp
     c31:	pop    rbp
     c32:	ret

0000000000000c33 <botlish_entry_9: web::emailish?<str>>:
     c33:	push   rbp
     c34:	mov    rbp,rsp
     c37:	mov    rsi,QWORD PTR [rdx]
     c3a:	call   c3f <botlish_entry_9+0xc>
			c3b: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
     c3f:	mov    rsp,rbp
     c42:	pop    rbp
     c43:	ret

0000000000000c44 <botlish_fn_10: char_at<generic>>:
     c44:	push   rbp
     c45:	mov    rbp,rsp
     c48:	sub    rsp,0x50
     c4c:	mov    QWORD PTR [rsp+0x20],rbx
     c51:	mov    QWORD PTR [rsp+0x28],r12
     c56:	mov    QWORD PTR [rsp+0x30],r13
     c5b:	mov    QWORD PTR [rsp+0x38],r14
     c60:	mov    QWORD PTR [rsp+0x40],r15
     c65:	mov    r12,rdi
     c68:	mov    r15,rcx
     c6b:	mov    QWORD PTR [rsp],rsi
     c6f:	mov    QWORD PTR [rsp+0x8],rdx
     c74:	mov    r13,rdx
     c77:	mov    QWORD PTR [rsp+0x10],0x3
     c80:	test   rsi,0x1
     c87:	jne    c95 <botlish_fn_10+0x51>
     c8d:	mov    rbx,rsi
     c90:	jmp    cb5 <botlish_fn_10+0x71>
     c95:	mov    rax,rsi
     c98:	add    rax,0x2
     c9c:	mov    rbx,rsi
     c9f:	seto   cl
     ca2:	test   cl,cl
     ca4:	jne    cb5 <botlish_fn_10+0x71>
     caa:	mov    rdi,r12
     cad:	mov    r14,rax
     cb0:	jmp    ccb <botlish_fn_10+0x87>
     cb5:	mov    edx,0x3
     cba:	mov    rsi,rbx
     cbd:	mov    rdi,r12
     cc0:	call   cc5 <botlish_fn_10+0x81>
			cc1: R_X86_64_PLT32	rt_int_add-0x4
     cc5:	mov    r14,rax
     cc8:	mov    rdi,r12
     ccb:	mov    rcx,r14
     cce:	mov    rdx,rbx
     cd1:	mov    rsi,r13
     cd4:	call   cd9 <botlish_fn_10+0x95>
			cd5: R_X86_64_PLT32	rt_str_region_check-0x4
     cd9:	test   rax,rax
     cdc:	jne    d07 <botlish_fn_10+0xc3>
     ce2:	xor    rax,rax
     ce5:	mov    rbx,QWORD PTR [rsp+0x20]
     cea:	mov    r12,QWORD PTR [rsp+0x28]
     cef:	mov    r13,QWORD PTR [rsp+0x30]
     cf4:	mov    r14,QWORD PTR [rsp+0x38]
     cf9:	mov    r15,QWORD PTR [rsp+0x40]
     cfe:	add    rsp,0x50
     d02:	mov    rsp,rbp
     d05:	pop    rbp
     d06:	ret
     d07:	mov    rcx,r15
     d0a:	mov    QWORD PTR [rcx],rbx
     d0d:	mov    rax,r14
     d10:	mov    QWORD PTR [rcx+0x8],rax
     d14:	mov    rax,r13
     d17:	mov    rbx,QWORD PTR [rsp+0x20]
     d1c:	mov    r12,QWORD PTR [rsp+0x28]
     d21:	mov    r13,QWORD PTR [rsp+0x30]
     d26:	mov    r14,QWORD PTR [rsp+0x38]
     d2b:	mov    r15,QWORD PTR [rsp+0x40]
     d30:	add    rsp,0x50
     d34:	mov    rsp,rbp
     d37:	pop    rbp
     d38:	ret

0000000000000d39 <botlish_entry_10: char_at<generic>>:
     d39:	push   rbp
     d3a:	mov    rbp,rsp
     d3d:	ud2

0000000000000d3f <botlish_fn_11: char_at<generic>>:
     d3f:	push   rbp
     d40:	mov    rbp,rsp
     d43:	sub    rsp,0x40
     d47:	mov    QWORD PTR [rsp+0x20],rbx
     d4c:	mov    QWORD PTR [rsp+0x28],r12
     d51:	mov    QWORD PTR [rsp+0x30],r13
     d56:	mov    r12,rdi
     d59:	mov    QWORD PTR [rsp],rsi
     d5d:	mov    QWORD PTR [rsp+0x8],rdx
     d62:	mov    r13,rdx
     d65:	mov    QWORD PTR [rsp+0x10],0x3
     d6e:	test   rsi,0x1
     d75:	jne    d83 <botlish_fn_11+0x44>
     d7b:	mov    rbx,rsi
     d7e:	jmp    d98 <botlish_fn_11+0x59>
     d83:	mov    rcx,rsi
     d86:	add    rcx,0x2
     d8a:	mov    rbx,rsi
     d8d:	seto   al
     d90:	test   al,al
     d92:	je     dab <botlish_fn_11+0x6c>
     d98:	mov    edx,0x3
     d9d:	mov    rsi,rbx
     da0:	mov    rdi,r12
     da3:	call   da8 <botlish_fn_11+0x69>
			da4: R_X86_64_PLT32	rt_int_add-0x4
     da8:	mov    rcx,rax
     dab:	mov    QWORD PTR [rsp+0x10],rcx
     db0:	mov    rdx,rbx
     db3:	mov    rsi,r13
     db6:	mov    rdi,r12
     db9:	call   dbe <botlish_fn_11+0x7f>
			dba: R_X86_64_PLT32	rt_substr-0x4
     dbe:	test   rax,rax
     dc1:	jne    de2 <botlish_fn_11+0xa3>
     dc7:	xor    rax,rax
     dca:	mov    rbx,QWORD PTR [rsp+0x20]
     dcf:	mov    r12,QWORD PTR [rsp+0x28]
     dd4:	mov    r13,QWORD PTR [rsp+0x30]
     dd9:	add    rsp,0x40
     ddd:	mov    rsp,rbp
     de0:	pop    rbp
     de1:	ret
     de2:	mov    rbx,QWORD PTR [rsp+0x20]
     de7:	mov    r12,QWORD PTR [rsp+0x28]
     dec:	mov    r13,QWORD PTR [rsp+0x30]
     df1:	add    rsp,0x40
     df5:	mov    rsp,rbp
     df8:	pop    rbp
     df9:	ret

0000000000000dfa <botlish_entry_11: char_at<generic>>:
     dfa:	push   rbp
     dfb:	mov    rbp,rsp
     dfe:	mov    rsi,QWORD PTR [rdx]
     e01:	mov    rdx,QWORD PTR [rdx+0x8]
     e05:	call   e0a <botlish_entry_11+0x10>
			e06: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
     e0a:	mov    rsp,rbp
     e0d:	pop    rbp
     e0e:	ret

0000000000000e0f <botlish_fn_12: local_char?<str>>:
     e0f:	push   rbp
     e10:	mov    rbp,rsp
     e13:	sub    rsp,0x10
     e17:	mov    QWORD PTR [rsp],rbx
     e1b:	mov    QWORD PTR [rsp+0x8],r14
     e20:	mov    rbx,rdi
     e23:	mov    r14,rsi
     e26:	mov    rsi,r14
     e29:	mov    rdi,rbx
     e2c:	call   e31 <botlish_fn_12+0x22>
			e2d: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     e31:	test   rax,rax
     e34:	jne    e4f <botlish_fn_12+0x40>
     e3a:	xor    rax,rax
     e3d:	mov    rbx,QWORD PTR [rsp]
     e41:	mov    r14,QWORD PTR [rsp+0x8]
     e46:	add    rsp,0x10
     e4a:	mov    rsp,rbp
     e4d:	pop    rbp
     e4e:	ret
     e4f:	cmp    rax,0x6
     e53:	je     e89 <botlish_fn_12+0x7a>
     e59:	mov    rdi,rbx
     e5c:	mov    rax,QWORD PTR [rdi+0x30]
     e60:	mov    rsi,QWORD PTR [rax]
     e63:	mov    rdx,r14
     e66:	call   e6b <botlish_fn_12+0x5c>
			e67: R_X86_64_PLT32	rt_set_contains-0x4
     e6b:	cmp    rax,0x6
     e6f:	je     e7f <botlish_fn_12+0x70>
     e75:	mov    eax,0x2
     e7a:	jmp    e8e <botlish_fn_12+0x7f>
     e7f:	mov    eax,0x6
     e84:	jmp    e8e <botlish_fn_12+0x7f>
     e89:	mov    eax,0x6
     e8e:	mov    rbx,QWORD PTR [rsp]
     e92:	mov    r14,QWORD PTR [rsp+0x8]
     e97:	add    rsp,0x10
     e9b:	mov    rsp,rbp
     e9e:	pop    rbp
     e9f:	ret

0000000000000ea0 <botlish_entry_12: local_char?<str>>:
     ea0:	push   rbp
     ea1:	mov    rbp,rsp
     ea4:	mov    rsi,QWORD PTR [rdx]
     ea7:	call   eac <botlish_entry_12+0xc>
			ea8: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     eac:	mov    rsp,rbp
     eaf:	pop    rbp
     eb0:	ret

0000000000000eb1 <botlish_fn_13: local_char?<generic>>:
     eb1:	push   rbp
     eb2:	mov    rbp,rsp
     eb5:	sub    rsp,0x10
     eb9:	mov    QWORD PTR [rsp],rbx
     ebd:	mov    QWORD PTR [rsp+0x8],r12
     ec2:	xor    r8d,r8d
     ec5:	test   rsi,0x7
     ecc:	jne    edc <botlish_fn_13+0x2b>
     ed2:	movzx  rax,BYTE PTR [rsi]
     ed6:	cmp    al,0x2
     ed8:	sete   r8b
     edc:	test   r8b,r8b
     edf:	jne    eff <botlish_fn_13+0x4e>
     ee5:	mov    rax,QWORD PTR [rdi+0x10]
     ee9:	mov    rcx,QWORD PTR [rax+0xd8]
     ef0:	mov    edx,0x1
     ef5:	call   efa <botlish_fn_13+0x49>
			ef6: R_X86_64_PLT32	rt_type_error-0x4
     efa:	jmp    f13 <botlish_fn_13+0x62>
     eff:	mov    rbx,rsi
     f02:	mov    r12,rdi
     f05:	call   f0a <botlish_fn_13+0x59>
			f06: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     f0a:	test   rax,rax
     f0d:	jne    f28 <botlish_fn_13+0x77>
     f13:	xor    rax,rax
     f16:	mov    rbx,QWORD PTR [rsp]
     f1a:	mov    r12,QWORD PTR [rsp+0x8]
     f1f:	add    rsp,0x10
     f23:	mov    rsp,rbp
     f26:	pop    rbp
     f27:	ret
     f28:	cmp    rax,0x6
     f2c:	je     f62 <botlish_fn_13+0xb1>
     f32:	mov    rdi,r12
     f35:	mov    rax,QWORD PTR [rdi+0x30]
     f39:	mov    rsi,QWORD PTR [rax]
     f3c:	mov    rdx,rbx
     f3f:	call   f44 <botlish_fn_13+0x93>
			f40: R_X86_64_PLT32	rt_set_contains-0x4
     f44:	cmp    rax,0x6
     f48:	je     f58 <botlish_fn_13+0xa7>
     f4e:	mov    eax,0x2
     f53:	jmp    f67 <botlish_fn_13+0xb6>
     f58:	mov    eax,0x6
     f5d:	jmp    f67 <botlish_fn_13+0xb6>
     f62:	mov    eax,0x6
     f67:	mov    rbx,QWORD PTR [rsp]
     f6b:	mov    r12,QWORD PTR [rsp+0x8]
     f70:	add    rsp,0x10
     f74:	mov    rsp,rbp
     f77:	pop    rbp
     f78:	ret

0000000000000f79 <botlish_entry_13: local_char?<generic>>:
     f79:	push   rbp
     f7a:	mov    rbp,rsp
     f7d:	mov    rsi,QWORD PTR [rdx]
     f80:	call   f85 <botlish_entry_13+0xc>
			f81: R_X86_64_PLT32	botlish_fn_13-0x4 ; local_char?<generic>
     f85:	mov    rsp,rbp
     f88:	pop    rbp
     f89:	ret
     f8a:	add    BYTE PTR [rax],al
     f8c:	add    BYTE PTR [rax],al
	...

0000000000000f90 <botlish_fn_14: scan_while<any, block(e239)>>:
     f90:	push   rbp
     f91:	mov    rbp,rsp
     f94:	sub    rsp,0x40
     f98:	mov    QWORD PTR [rsp+0x20],rbx
     f9d:	mov    QWORD PTR [rsp+0x28],r12
     fa2:	mov    QWORD PTR [rsp+0x30],r13
     fa7:	mov    QWORD PTR [rsp+0x38],r14
     fac:	mov    rbx,rcx
     faf:	mov    r13,rdi
     fb2:	mov    QWORD PTR [rsp+0x18],0x0
     fbb:	mov    QWORD PTR [rsp],rcx
     fbf:	mov    QWORD PTR [rsp+0x8],r8
     fc4:	mov    r12,r8
     fc7:	mov    QWORD PTR [rsp+0x10],rsi
     fcc:	mov    rax,rsi
     fcf:	mov    rcx,rbx
     fd2:	mov    r14,rsi
     fd5:	mov    rcx,rbx
     fd8:	and    rax,rcx
     fdb:	test   rax,0x1
     fe1:	jne    100a <botlish_fn_14+0x7a>
     fe7:	mov    rdx,rbx
     fea:	mov    rsi,r14
     fed:	mov    rdi,r13
     ff0:	call   ff5 <botlish_fn_14+0x65>
			ff1: R_X86_64_PLT32	rt_int_cmp-0x4
     ff5:	mov    ecx,0x2
     ffa:	test   rax,rax
     ffd:	cmovl  rcx,QWORD PTR [rip+0x10b]        # 1110 <botlish_fn_14+0x180>
    1005:	jmp    1020 <botlish_fn_14+0x90>
    100a:	mov    ecx,0x2
    100f:	mov    rax,r14
    1012:	mov    rdx,rbx
    1015:	cmp    rax,rdx
    1018:	cmovl  rcx,QWORD PTR [rip+0xf0]        # 1110 <botlish_fn_14+0x180>
    1020:	cmp    rcx,0x6
    1024:	je     104a <botlish_fn_14+0xba>
    102a:	mov    rax,rbx
    102d:	mov    rbx,QWORD PTR [rsp+0x20]
    1032:	mov    r12,QWORD PTR [rsp+0x28]
    1037:	mov    r13,QWORD PTR [rsp+0x30]
    103c:	mov    r14,QWORD PTR [rsp+0x38]
    1041:	add    rsp,0x40
    1045:	mov    rsp,rbp
    1048:	pop    rbp
    1049:	ret
    104a:	mov    rdx,r12
    104d:	mov    rsi,r14
    1050:	mov    rdi,r13
    1053:	call   1058 <botlish_fn_14+0xc8>
			1054: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    1058:	test   rax,rax
    105b:	mov    rsi,rax
    105e:	je     1075 <botlish_fn_14+0xe5>
    1064:	mov    rdi,r13
    1067:	call   106c <botlish_fn_14+0xdc>
			1068: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
    106c:	test   rax,rax
    106f:	jne    1095 <botlish_fn_14+0x105>
    1075:	xor    rax,rax
    1078:	mov    rbx,QWORD PTR [rsp+0x20]
    107d:	mov    r12,QWORD PTR [rsp+0x28]
    1082:	mov    r13,QWORD PTR [rsp+0x30]
    1087:	mov    r14,QWORD PTR [rsp+0x38]
    108c:	add    rsp,0x40
    1090:	mov    rsp,rbp
    1093:	pop    rbp
    1094:	ret
    1095:	cmp    rax,0x6
    1099:	je     10bf <botlish_fn_14+0x12f>
    109f:	mov    rax,r14
    10a2:	mov    rbx,QWORD PTR [rsp+0x20]
    10a7:	mov    r12,QWORD PTR [rsp+0x28]
    10ac:	mov    r13,QWORD PTR [rsp+0x30]
    10b1:	mov    r14,QWORD PTR [rsp+0x38]
    10b6:	add    rsp,0x40
    10ba:	mov    rsp,rbp
    10bd:	pop    rbp
    10be:	ret
    10bf:	mov    QWORD PTR [rsp+0x18],0x3
    10c8:	mov    rax,r14
    10cb:	test   rax,0x1
    10d1:	je     10ec <botlish_fn_14+0x15c>
    10d7:	mov    rcx,r14
    10da:	mov    rax,rcx
    10dd:	add    rax,0x2
    10e1:	seto   cl
    10e4:	test   cl,cl
    10e6:	je     10fc <botlish_fn_14+0x16c>
    10ec:	mov    edx,0x3
    10f1:	mov    rsi,r14
    10f4:	mov    rdi,r13
    10f7:	call   10fc <botlish_fn_14+0x16c>
			10f8: R_X86_64_PLT32	rt_int_add-0x4
    10fc:	mov    QWORD PTR [rsp+0x10],rax
    1101:	mov    rcx,rbx
    1104:	mov    r14,rax
    1107:	jmp    fd5 <botlish_fn_14+0x45>
    110c:	add    BYTE PTR [rax],al
    110e:	add    BYTE PTR [rax],al
    1110:	(bad)
    1111:	add    BYTE PTR [rax],al
    1113:	add    BYTE PTR [rax],al
    1115:	add    BYTE PTR [rax],al
	...

0000000000001118 <botlish_entry_14: scan_while<any, block(e239)>>:
    1118:	push   rbp
    1119:	mov    rbp,rsp
    111c:	mov    rsi,QWORD PTR [rdx]
    111f:	mov    r9,QWORD PTR [rdx+0x8]
    1123:	mov    rcx,QWORD PTR [rdx+0x10]
    1127:	mov    r8,QWORD PTR [rdx+0x18]
    112b:	mov    rdx,r9
    112e:	call   1133 <botlish_entry_14+0x1b>
			112f: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<any, block(e239)>
    1133:	mov    rsp,rbp
    1136:	pop    rbp
    1137:	ret

0000000000001138 <botlish_fn_15: scan_while<any, native(is_tcl_alpha)>>:
    1138:	push   rbp
    1139:	mov    rbp,rsp
    113c:	sub    rsp,0x50
    1140:	mov    QWORD PTR [rsp+0x30],rbx
    1145:	mov    QWORD PTR [rsp+0x38],r12
    114a:	mov    QWORD PTR [rsp+0x40],r13
    114f:	mov    QWORD PTR [rsp+0x48],r14
    1154:	mov    rbx,rcx
    1157:	mov    r13,rdi
    115a:	mov    QWORD PTR [rsp+0x18],0x0
    1163:	mov    QWORD PTR [rsp],rcx
    1167:	mov    QWORD PTR [rsp+0x8],r8
    116c:	mov    r12,r8
    116f:	mov    QWORD PTR [rsp+0x10],rsi
    1174:	mov    rax,rsi
    1177:	mov    rcx,rbx
    117a:	mov    r14,rsi
    117d:	mov    rcx,rbx
    1180:	and    rax,rcx
    1183:	test   rax,0x1
    1189:	jne    11b2 <botlish_fn_15+0x7a>
    118f:	mov    rdx,rbx
    1192:	mov    rsi,r14
    1195:	mov    rdi,r13
    1198:	call   119d <botlish_fn_15+0x65>
			1199: R_X86_64_PLT32	rt_int_cmp-0x4
    119d:	mov    ecx,0x2
    11a2:	test   rax,rax
    11a5:	cmovl  rcx,QWORD PTR [rip+0x11b]        # 12c8 <botlish_fn_15+0x190>
    11ad:	jmp    11c8 <botlish_fn_15+0x90>
    11b2:	mov    ecx,0x2
    11b7:	mov    rax,r14
    11ba:	mov    rdx,rbx
    11bd:	cmp    rax,rdx
    11c0:	cmovl  rcx,QWORD PTR [rip+0x100]        # 12c8 <botlish_fn_15+0x190>
    11c8:	cmp    rcx,0x6
    11cc:	je     11f2 <botlish_fn_15+0xba>
    11d2:	mov    rax,rbx
    11d5:	mov    rbx,QWORD PTR [rsp+0x30]
    11da:	mov    r12,QWORD PTR [rsp+0x38]
    11df:	mov    r13,QWORD PTR [rsp+0x40]
    11e4:	mov    r14,QWORD PTR [rsp+0x48]
    11e9:	add    rsp,0x50
    11ed:	mov    rsp,rbp
    11f0:	pop    rbp
    11f1:	ret
    11f2:	lea    rcx,[rsp+0x20]
    11f7:	mov    rdx,r12
    11fa:	mov    rsi,r14
    11fd:	mov    rdi,r13
    1200:	call   1205 <botlish_fn_15+0xcd>
			1201: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    1205:	test   rax,rax
    1208:	mov    rsi,rax
    120b:	je     122c <botlish_fn_15+0xf4>
    1211:	mov    rdx,QWORD PTR [rsp+0x20]
    1216:	mov    rcx,QWORD PTR [rsp+0x28]
    121b:	mov    rdi,r13
    121e:	call   1223 <botlish_fn_15+0xeb>
			121f: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    1223:	test   rax,rax
    1226:	jne    124c <botlish_fn_15+0x114>
    122c:	xor    rax,rax
    122f:	mov    rbx,QWORD PTR [rsp+0x30]
    1234:	mov    r12,QWORD PTR [rsp+0x38]
    1239:	mov    r13,QWORD PTR [rsp+0x40]
    123e:	mov    r14,QWORD PTR [rsp+0x48]
    1243:	add    rsp,0x50
    1247:	mov    rsp,rbp
    124a:	pop    rbp
    124b:	ret
    124c:	cmp    rax,0x6
    1250:	je     1276 <botlish_fn_15+0x13e>
    1256:	mov    rax,r14
    1259:	mov    rbx,QWORD PTR [rsp+0x30]
    125e:	mov    r12,QWORD PTR [rsp+0x38]
    1263:	mov    r13,QWORD PTR [rsp+0x40]
    1268:	mov    r14,QWORD PTR [rsp+0x48]
    126d:	add    rsp,0x50
    1271:	mov    rsp,rbp
    1274:	pop    rbp
    1275:	ret
    1276:	mov    QWORD PTR [rsp+0x18],0x3
    127f:	mov    rax,r14
    1282:	test   rax,0x1
    1288:	je     12a3 <botlish_fn_15+0x16b>
    128e:	mov    rcx,r14
    1291:	mov    rax,rcx
    1294:	add    rax,0x2
    1298:	seto   cl
    129b:	test   cl,cl
    129d:	je     12b3 <botlish_fn_15+0x17b>
    12a3:	mov    edx,0x3
    12a8:	mov    rsi,r14
    12ab:	mov    rdi,r13
    12ae:	call   12b3 <botlish_fn_15+0x17b>
			12af: R_X86_64_PLT32	rt_int_add-0x4
    12b3:	mov    QWORD PTR [rsp+0x10],rax
    12b8:	mov    rcx,rbx
    12bb:	mov    r14,rax
    12be:	jmp    117d <botlish_fn_15+0x45>
    12c3:	add    BYTE PTR [rax],al
    12c5:	add    BYTE PTR [rax],al
    12c7:	add    BYTE PTR [rsi],al
    12c9:	add    BYTE PTR [rax],al
    12cb:	add    BYTE PTR [rax],al
    12cd:	add    BYTE PTR [rax],al
	...

00000000000012d0 <botlish_entry_15: scan_while<any, native(is_tcl_alpha)>>:
    12d0:	push   rbp
    12d1:	mov    rbp,rsp
    12d4:	mov    rsi,QWORD PTR [rdx]
    12d7:	mov    r9,QWORD PTR [rdx+0x8]
    12db:	mov    rcx,QWORD PTR [rdx+0x10]
    12df:	mov    r8,QWORD PTR [rdx+0x18]
    12e3:	mov    rdx,r9
    12e6:	call   12eb <botlish_entry_15+0x1b>
			12e7: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<any, native(is_tcl_alpha)>
    12eb:	mov    rsp,rbp
    12ee:	pop    rbp
    12ef:	ret

00000000000012f0 <botlish_fn_16: tld?<generic>>:
    12f0:	push   rbp
    12f1:	mov    rbp,rsp
    12f4:	sub    rsp,0x40
    12f8:	mov    QWORD PTR [rsp+0x20],rbx
    12fd:	mov    QWORD PTR [rsp+0x28],r12
    1302:	mov    QWORD PTR [rsp+0x30],r13
    1307:	mov    QWORD PTR [rsp+0x38],r14
    130c:	mov    QWORD PTR [rsp],rsi
    1310:	mov    r8,rsi
    1313:	mov    QWORD PTR [rsp+0x8],rdx
    1318:	mov    r14,rdx
    131b:	mov    QWORD PTR [rsp+0x10],rcx
    1320:	mov    rax,QWORD PTR [rdi+0x10]
    1324:	mov    r12,rdi
    1327:	mov    rdx,QWORD PTR [rax+0xe0]
    132e:	mov    QWORD PTR [rsp+0x18],rdx
    1333:	mov    rbx,r8
    1336:	mov    r8,rcx
    1339:	mov    rcx,r14
    133c:	mov    rsi,rbx
    133f:	call   1344 <botlish_fn_16+0x54>
			1340: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<any, native(is_tcl_alpha)>
    1344:	mov    rcx,rax
    1347:	mov    r13,rax
    134a:	test   rax,rcx
    134d:	jne    1373 <botlish_fn_16+0x83>
    1353:	xor    rax,rax
    1356:	mov    rbx,QWORD PTR [rsp+0x20]
    135b:	mov    r12,QWORD PTR [rsp+0x28]
    1360:	mov    r13,QWORD PTR [rsp+0x30]
    1365:	mov    r14,QWORD PTR [rsp+0x38]
    136a:	add    rsp,0x40
    136e:	mov    rsp,rbp
    1371:	pop    rbp
    1372:	ret
    1373:	mov    rax,r13
    1376:	mov    QWORD PTR [rsp+0x8],rax
    137b:	mov    rdx,r14
    137e:	and    rax,rdx
    1381:	test   rax,0x1
    1387:	jne    13b0 <botlish_fn_16+0xc0>
    138d:	mov    rsi,r13
    1390:	mov    rdi,r12
    1393:	call   1398 <botlish_fn_16+0xa8>
			1394: R_X86_64_PLT32	rt_int_cmp-0x4
    1398:	mov    ecx,0x2
    139d:	test   rax,rax
    13a0:	cmove  rcx,QWORD PTR [rip+0xe0]        # 1488 <botlish_fn_16+0x198>
    13a8:	mov    rax,r13
    13ab:	jmp    13c3 <botlish_fn_16+0xd3>
    13b0:	mov    ecx,0x2
    13b5:	mov    rax,r13
    13b8:	cmp    rax,rdx
    13bb:	cmove  rcx,QWORD PTR [rip+0xc5]        # 1488 <botlish_fn_16+0x198>
    13c3:	cmp    rcx,0x6
    13c7:	je     13da <botlish_fn_16+0xea>
    13cd:	mov    ecx,0x2
    13d2:	mov    rax,rcx
    13d5:	jmp    1467 <botlish_fn_16+0x177>
    13da:	mov    rcx,rax
    13dd:	and    rcx,rbx
    13e0:	test   rcx,0x1
    13e7:	jne    13f8 <botlish_fn_16+0x108>
    13ed:	mov    rdx,rbx
    13f0:	mov    rsi,rax
    13f3:	jmp    1419 <botlish_fn_16+0x129>
    13f8:	mov    rcx,rax
    13fb:	sub    rcx,rbx
    13fe:	mov    r8,rbx
    1401:	mov    r13,rax
    1404:	seto   al
    1407:	lea    rsi,[rcx+0x1]
    140b:	test   al,al
    140d:	je     1424 <botlish_fn_16+0x134>
    1413:	mov    rdx,r8
    1416:	mov    rsi,r13
    1419:	mov    rdi,r12
    141c:	call   1421 <botlish_fn_16+0x131>
			141d: R_X86_64_PLT32	rt_int_sub-0x4
    1421:	mov    rsi,rax
    1424:	test   rsi,0x1
    142b:	jne    1456 <botlish_fn_16+0x166>
    1431:	mov    edx,0x5
    1436:	mov    rdi,r12
    1439:	call   143e <botlish_fn_16+0x14e>
			143a: R_X86_64_PLT32	rt_int_cmp-0x4
    143e:	mov    ecx,0x2
    1443:	test   rax,rax
    1446:	mov    rax,rcx
    1449:	cmovge rax,QWORD PTR [rip+0x37]        # 1488 <botlish_fn_16+0x198>
    1451:	jmp    1467 <botlish_fn_16+0x177>
    1456:	mov    eax,0x2
    145b:	cmp    rsi,0x5
    145f:	cmovge rax,QWORD PTR [rip+0x21]        # 1488 <botlish_fn_16+0x198>
    1467:	mov    rbx,QWORD PTR [rsp+0x20]
    146c:	mov    r12,QWORD PTR [rsp+0x28]
    1471:	mov    r13,QWORD PTR [rsp+0x30]
    1476:	mov    r14,QWORD PTR [rsp+0x38]
    147b:	add    rsp,0x40
    147f:	mov    rsp,rbp
    1482:	pop    rbp
    1483:	ret
    1484:	add    BYTE PTR [rax],al
    1486:	add    BYTE PTR [rax],al
    1488:	(bad)
    1489:	add    BYTE PTR [rax],al
    148b:	add    BYTE PTR [rax],al
    148d:	add    BYTE PTR [rax],al
	...

0000000000001490 <botlish_entry_16: tld?<generic>>:
    1490:	push   rbp
    1491:	mov    rbp,rsp
    1494:	mov    rsi,QWORD PTR [rdx]
    1497:	mov    r8,QWORD PTR [rdx+0x8]
    149b:	mov    rcx,QWORD PTR [rdx+0x10]
    149f:	mov    rdx,r8
    14a2:	call   14a7 <botlish_entry_16+0x17>
			14a3: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<generic>
    14a7:	mov    rsp,rbp
    14aa:	pop    rbp
    14ab:	ret
    14ac:	add    BYTE PTR [rax],al
	...

00000000000014b0 <botlish_fn_17: domain?<generic>>:
    14b0:	push   rbp
    14b1:	mov    rbp,rsp
    14b4:	sub    rsp,0xa0
    14bb:	mov    QWORD PTR [rsp+0x70],rbx
    14c0:	mov    QWORD PTR [rsp+0x78],r12
    14c5:	mov    QWORD PTR [rsp+0x80],r13
    14cd:	mov    QWORD PTR [rsp+0x88],r14
    14d5:	mov    QWORD PTR [rsp+0x90],r15
    14dd:	mov    r8,rdi
    14e0:	mov    QWORD PTR [rsp+0x20],0x0
    14e9:	mov    QWORD PTR [rsp],rsi
    14ed:	mov    QWORD PTR [rsp+0x8],rdx
    14f2:	mov    QWORD PTR [rsp+0x10],rcx
    14f7:	mov    r15,rcx
    14fa:	mov    QWORD PTR [rsp+0x18],rsi
    14ff:	mov    r12,rsi
    1502:	mov    r14,rdx
    1505:	mov    rdi,rsi
    1508:	and    rdi,r14
    150b:	mov    QWORD PTR [rsp+0x58],rsi
    1510:	test   rdi,0x1
    1517:	jne    1545 <botlish_fn_17+0x95>
    151d:	mov    rbx,r8
    1520:	mov    rdx,r14
    1523:	mov    rsi,QWORD PTR [rsp+0x58]
    1528:	mov    rdi,rbx
    152b:	call   1530 <botlish_fn_17+0x80>
			152c: R_X86_64_PLT32	rt_int_cmp-0x4
    1530:	mov    ecx,0x2
    1535:	test   rax,rax
    1538:	cmovl  rcx,QWORD PTR [rip+0x358]        # 1898 <botlish_fn_17+0x3e8>
    1540:	jmp    155d <botlish_fn_17+0xad>
    1545:	mov    rbx,r8
    1548:	mov    ecx,0x2
    154d:	mov    rsi,QWORD PTR [rsp+0x58]
    1552:	cmp    rsi,r14
    1555:	cmovl  rcx,QWORD PTR [rip+0x33b]        # 1898 <botlish_fn_17+0x3e8>
    155d:	cmp    rcx,0x6
    1561:	je     159a <botlish_fn_17+0xea>
    1567:	mov    eax,0x2
    156c:	mov    rbx,QWORD PTR [rsp+0x70]
    1571:	mov    r12,QWORD PTR [rsp+0x78]
    1576:	mov    r13,QWORD PTR [rsp+0x80]
    157e:	mov    r14,QWORD PTR [rsp+0x88]
    1586:	mov    r15,QWORD PTR [rsp+0x90]
    158e:	add    rsp,0xa0
    1595:	mov    rsp,rbp
    1598:	pop    rbp
    1599:	ret
    159a:	lea    rcx,[rsp+0x28]
    159f:	mov    rdx,r15
    15a2:	mov    rsi,QWORD PTR [rsp+0x58]
    15a7:	mov    rdi,rbx
    15aa:	call   15af <botlish_fn_17+0xff>
			15ab: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    15af:	test   rax,rax
    15b2:	mov    rsi,rax
    15b5:	je     175c <botlish_fn_17+0x2ac>
    15bb:	mov    rdx,QWORD PTR [rsp+0x28]
    15c0:	mov    rcx,QWORD PTR [rsp+0x30]
    15c5:	mov    rax,QWORD PTR [rbx+0x10]
    15c9:	mov    r8,QWORD PTR [rax]
    15cc:	mov    rdi,rbx
    15cf:	call   15d4 <botlish_fn_17+0x124>
			15d0: R_X86_64_PLT32	rt_str_region_eq-0x4
    15d4:	cmp    rax,0x6
    15d8:	je     16c9 <botlish_fn_17+0x219>
    15de:	lea    rcx,[rsp+0x48]
    15e3:	mov    rdx,r15
    15e6:	mov    rsi,QWORD PTR [rsp+0x58]
    15eb:	mov    rdi,rbx
    15ee:	call   15f3 <botlish_fn_17+0x143>
			15ef: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    15f3:	test   rax,rax
    15f6:	mov    r13,rax
    15f9:	je     175c <botlish_fn_17+0x2ac>
    15ff:	mov    rdx,QWORD PTR [rsp+0x48]
    1604:	mov    QWORD PTR [rsp+0x68],rdx
    1609:	mov    rcx,QWORD PTR [rsp+0x50]
    160e:	mov    QWORD PTR [rsp+0x60],rcx
    1613:	mov    rsi,r13
    1616:	mov    rdi,rbx
    1619:	call   161e <botlish_fn_17+0x16e>
			161a: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    161e:	test   rax,rax
    1621:	je     175c <botlish_fn_17+0x2ac>
    1627:	cmp    rax,0x6
    162b:	je     166c <botlish_fn_17+0x1bc>
    1631:	mov    rax,QWORD PTR [rbx+0x10]
    1635:	mov    r8,QWORD PTR [rax+0x20]
    1639:	mov    rcx,QWORD PTR [rsp+0x60]
    163e:	mov    rdx,QWORD PTR [rsp+0x68]
    1643:	mov    rsi,r13
    1646:	mov    rdi,rbx
    1649:	call   164e <botlish_fn_17+0x19e>
			164a: R_X86_64_PLT32	rt_str_region_eq-0x4
    164e:	cmp    rax,0x6
    1652:	je     1662 <botlish_fn_17+0x1b2>
    1658:	mov    ecx,0x2
    165d:	jmp    1671 <botlish_fn_17+0x1c1>
    1662:	mov    ecx,0x6
    1667:	jmp    1671 <botlish_fn_17+0x1c1>
    166c:	mov    ecx,0x6
    1671:	cmp    rcx,0x6
    1675:	je     1686 <botlish_fn_17+0x1d6>
    167b:	mov    r9d,0x6
    1681:	jmp    168c <botlish_fn_17+0x1dc>
    1686:	mov    r9d,0x2
    168c:	cmp    r9,0x6
    1690:	jne    1797 <botlish_fn_17+0x2e7>
    1696:	mov    eax,0x2
    169b:	mov    rbx,QWORD PTR [rsp+0x70]
    16a0:	mov    r12,QWORD PTR [rsp+0x78]
    16a5:	mov    r13,QWORD PTR [rsp+0x80]
    16ad:	mov    r14,QWORD PTR [rsp+0x88]
    16b5:	mov    r15,QWORD PTR [rsp+0x90]
    16bd:	add    rsp,0xa0
    16c4:	mov    rsp,rbp
    16c7:	pop    rbp
    16c8:	ret
    16c9:	mov    rsi,QWORD PTR [rsp+0x58]
    16ce:	mov    r13,rsi
    16d1:	sar    r13,1
    16d4:	mov    rax,r12
    16d7:	sar    rax,1
    16da:	cmp    r13,rax
    16dd:	je     1864 <botlish_fn_17+0x3b4>
    16e3:	mov    rsi,r13
    16e6:	sub    rsi,0x1
    16ea:	shl    rsi,1
    16ed:	or     rsi,0x1
    16f1:	mov    QWORD PTR [rsp+0x20],rsi
    16f6:	lea    rcx,[rsp+0x38]
    16fb:	mov    rdx,r15
    16fe:	mov    rdi,rbx
    1701:	call   1706 <botlish_fn_17+0x256>
			1702: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    1706:	test   rax,rax
    1709:	mov    rsi,rax
    170c:	je     175c <botlish_fn_17+0x2ac>
    1712:	mov    rdx,QWORD PTR [rsp+0x38]
    1717:	mov    rcx,QWORD PTR [rsp+0x40]
    171c:	mov    rax,QWORD PTR [rbx+0x10]
    1720:	mov    r8,QWORD PTR [rax]
    1723:	mov    rdi,rbx
    1726:	call   172b <botlish_fn_17+0x27b>
			1727: R_X86_64_PLT32	rt_str_region_eq-0x4
    172b:	cmp    rax,0x6
    172f:	je     1831 <botlish_fn_17+0x381>
    1735:	lea    rsi,[r13+0x1]
    1739:	shl    rsi,1
    173c:	or     rsi,0x1
    1740:	mov    QWORD PTR [rsp+0x20],rsi
    1745:	mov    rcx,r15
    1748:	mov    rdx,r14
    174b:	mov    rdi,rbx
    174e:	call   1753 <botlish_fn_17+0x2a3>
			174f: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<generic>
    1753:	test   rax,rax
    1756:	jne    178d <botlish_fn_17+0x2dd>
    175c:	xor    rax,rax
    175f:	mov    rbx,QWORD PTR [rsp+0x70]
    1764:	mov    r12,QWORD PTR [rsp+0x78]
    1769:	mov    r13,QWORD PTR [rsp+0x80]
    1771:	mov    r14,QWORD PTR [rsp+0x88]
    1779:	mov    r15,QWORD PTR [rsp+0x90]
    1781:	add    rsp,0xa0
    1788:	mov    rsp,rbp
    178b:	pop    rbp
    178c:	ret
    178d:	cmp    rax,0x6
    1791:	je     17fe <botlish_fn_17+0x34e>
    1797:	mov    QWORD PTR [rsp+0x20],0x3
    17a0:	mov    rsi,QWORD PTR [rsp+0x58]
    17a5:	test   rsi,0x1
    17ac:	je     17d2 <botlish_fn_17+0x322>
    17b2:	mov    rsi,QWORD PTR [rsp+0x58]
    17b7:	add    rsi,0x2
    17bb:	seto   dil
    17bf:	test   dil,dil
    17c2:	jne    17d2 <botlish_fn_17+0x322>
    17c8:	mov    QWORD PTR [rsp+0x58],rsi
    17cd:	jmp    17ec <botlish_fn_17+0x33c>
    17d2:	mov    edx,0x3
    17d7:	mov    rsi,QWORD PTR [rsp+0x58]
    17dc:	mov    rdi,rbx
    17df:	call   17e4 <botlish_fn_17+0x334>
			17e0: R_X86_64_PLT32	rt_int_add-0x4
    17e4:	mov    rsi,rax
    17e7:	mov    QWORD PTR [rsp+0x58],rax
    17ec:	mov    QWORD PTR [rsp+0x18],rsi
    17f1:	mov    rsi,QWORD PTR [rsp+0x58]
    17f6:	mov    r8,rbx
    17f9:	jmp    1505 <botlish_fn_17+0x55>
    17fe:	mov    eax,0x6
    1803:	mov    rbx,QWORD PTR [rsp+0x70]
    1808:	mov    r12,QWORD PTR [rsp+0x78]
    180d:	mov    r13,QWORD PTR [rsp+0x80]
    1815:	mov    r14,QWORD PTR [rsp+0x88]
    181d:	mov    r15,QWORD PTR [rsp+0x90]
    1825:	add    rsp,0xa0
    182c:	mov    rsp,rbp
    182f:	pop    rbp
    1830:	ret
    1831:	mov    eax,0x2
    1836:	mov    rbx,QWORD PTR [rsp+0x70]
    183b:	mov    r12,QWORD PTR [rsp+0x78]
    1840:	mov    r13,QWORD PTR [rsp+0x80]
    1848:	mov    r14,QWORD PTR [rsp+0x88]
    1850:	mov    r15,QWORD PTR [rsp+0x90]
    1858:	add    rsp,0xa0
    185f:	mov    rsp,rbp
    1862:	pop    rbp
    1863:	ret
    1864:	mov    eax,0x2
    1869:	mov    rbx,QWORD PTR [rsp+0x70]
    186e:	mov    r12,QWORD PTR [rsp+0x78]
    1873:	mov    r13,QWORD PTR [rsp+0x80]
    187b:	mov    r14,QWORD PTR [rsp+0x88]
    1883:	mov    r15,QWORD PTR [rsp+0x90]
    188b:	add    rsp,0xa0
    1892:	mov    rsp,rbp
    1895:	pop    rbp
    1896:	ret
    1897:	add    BYTE PTR [rsi],al
    1899:	add    BYTE PTR [rax],al
    189b:	add    BYTE PTR [rax],al
    189d:	add    BYTE PTR [rax],al
	...

00000000000018a0 <botlish_entry_17: domain?<generic>>:
    18a0:	push   rbp
    18a1:	mov    rbp,rsp
    18a4:	mov    rsi,QWORD PTR [rdx]
    18a7:	mov    r8,QWORD PTR [rdx+0x8]
    18ab:	mov    rcx,QWORD PTR [rdx+0x10]
    18af:	mov    rdx,r8
    18b2:	call   18b7 <botlish_entry_17+0x17>
			18b3: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<generic>
    18b7:	mov    rsp,rbp
    18ba:	pop    rbp
    18bb:	ret

00000000000018bc <botlish_fn_18: web::is_unreserved<int>>:
    18bc:	push   rbp
    18bd:	mov    rbp,rsp
    18c0:	sub    rsp,0x10
    18c4:	mov    QWORD PTR [rsp],rbx
    18c8:	mov    QWORD PTR [rsp+0x8],r12
    18cd:	mov    rbx,rsi
    18d0:	mov    r12,rdi
    18d3:	call   18d8 <botlish_fn_18+0x1c>
			18d4: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
    18d8:	cmp    rax,0x6
    18dc:	je     191b <botlish_fn_18+0x5f>
    18e2:	mov    rax,QWORD PTR [r12+0x30]
    18e7:	mov    rsi,QWORD PTR [rax+0x10]
    18eb:	shl    rbx,1
    18ee:	mov    rdx,rbx
    18f1:	or     rdx,0x1
    18f5:	mov    rdi,r12
    18f8:	call   18fd <botlish_fn_18+0x41>
			18f9: R_X86_64_PLT32	rt_set_contains-0x4
    18fd:	cmp    rax,0x6
    1901:	je     1911 <botlish_fn_18+0x55>
    1907:	mov    eax,0x2
    190c:	jmp    1920 <botlish_fn_18+0x64>
    1911:	mov    eax,0x6
    1916:	jmp    1920 <botlish_fn_18+0x64>
    191b:	mov    eax,0x6
    1920:	mov    rbx,QWORD PTR [rsp]
    1924:	mov    r12,QWORD PTR [rsp+0x8]
    1929:	add    rsp,0x10
    192d:	mov    rsp,rbp
    1930:	pop    rbp
    1931:	ret

0000000000001932 <botlish_entry_18: web::is_unreserved<int>>:
    1932:	push   rbp
    1933:	mov    rbp,rsp
    1936:	mov    rsi,QWORD PTR [rdx]
    1939:	sar    rsi,1
    193c:	call   1941 <botlish_entry_18+0xf>
			193d: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1941:	mov    rsp,rbp
    1944:	pop    rbp
    1945:	ret

0000000000001946 <botlish_fn_19: web::uri_escape_text<str>>:
    1946:	push   rbp
    1947:	mov    rbp,rsp
    194a:	sub    rsp,0x10
    194e:	mov    QWORD PTR [rsp],rsi
    1952:	mov    r11,QWORD PTR [rdi+0x10]
    1956:	mov    rcx,QWORD PTR [r11+0xe8]
    195d:	mov    QWORD PTR [rsp+0x8],rcx
    1962:	xor    rdx,rdx
    1965:	call   196a <botlish_fn_19+0x24>
			1966: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    196a:	test   rax,rax
    196d:	jne    197f <botlish_fn_19+0x39>
    1973:	xor    rax,rax
    1976:	add    rsp,0x10
    197a:	mov    rsp,rbp
    197d:	pop    rbp
    197e:	ret
    197f:	add    rsp,0x10
    1983:	mov    rsp,rbp
    1986:	pop    rbp
    1987:	ret

0000000000001988 <botlish_entry_19: web::uri_escape_text<str>>:
    1988:	push   rbp
    1989:	mov    rbp,rsp
    198c:	mov    rsi,QWORD PTR [rdx]
    198f:	call   1994 <botlish_entry_19+0xc>
			1990: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_escape_text<str>
    1994:	mov    rsp,rbp
    1997:	pop    rbp
    1998:	ret

0000000000001999 <botlish_fn_20: high_nibble<int>>:
    1999:	push   rbp
    199a:	mov    rbp,rsp
    199d:	sub    rsp,0x10
    19a1:	mov    QWORD PTR [rsp],rsi
    19a5:	mov    QWORD PTR [rsp+0x8],0x1e1
    19ae:	test   rsi,0x1
    19b5:	jne    19ca <botlish_fn_20+0x31>
    19bb:	mov    edx,0x1e1
    19c0:	call   19c5 <botlish_fn_20+0x2c>
			19c1: R_X86_64_PLT32	rt_int_and-0x4
    19c5:	jmp    19d4 <botlish_fn_20+0x3b>
    19ca:	and    rsi,0x1e1
    19d1:	mov    rax,rsi
    19d4:	sar    rax,0x5
    19d8:	add    rsp,0x10
    19dc:	mov    rsp,rbp
    19df:	pop    rbp
    19e0:	ret

00000000000019e1 <botlish_entry_20: high_nibble<int>>:
    19e1:	push   rbp
    19e2:	mov    rbp,rsp
    19e5:	mov    rsi,QWORD PTR [rdx]
    19e8:	call   19ed <botlish_entry_20+0xc>
			19e9: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    19ed:	shl    rax,1
    19f0:	or     rax,0x1
    19f4:	mov    rsp,rbp
    19f7:	pop    rbp
    19f8:	ret

00000000000019f9 <botlish_fn_21: hex_pair<int>>:
    19f9:	push   rbp
    19fa:	mov    rbp,rsp
    19fd:	sub    rsp,0x50
    1a01:	mov    QWORD PTR [rsp+0x30],rbx
    1a06:	mov    QWORD PTR [rsp+0x38],r12
    1a0b:	mov    QWORD PTR [rsp+0x40],r13
    1a10:	mov    QWORD PTR [rsp+0x48],r14
    1a15:	mov    QWORD PTR [rsp],rsi
    1a19:	mov    r12,rsi
    1a1c:	mov    rax,QWORD PTR [rdi+0x30]
    1a20:	mov    rbx,rdi
    1a23:	mov    rsi,QWORD PTR [rax+0x8]
    1a27:	mov    QWORD PTR [rsp+0x8],rsi
    1a2c:	mov    r13,rsi
    1a2f:	mov    rsi,r12
    1a32:	call   1a37 <botlish_fn_21+0x3e>
			1a33: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    1a37:	mov    rsi,r13
    1a3a:	mov    rdx,QWORD PTR [rsi+0x8]
    1a3e:	mov    rcx,rax
    1a41:	shl    rcx,1
    1a44:	or     rcx,0x1
    1a48:	sar    rcx,1
    1a4b:	cmp    rcx,rdx
    1a4e:	jb     1a74 <botlish_fn_21+0x7b>
    1a54:	shl    rax,1
    1a57:	mov    rdx,rax
    1a5a:	or     rdx,0x1
    1a5e:	mov    rdi,rbx
    1a61:	call   1a66 <botlish_fn_21+0x6d>
			1a62: R_X86_64_PLT32	rt_list_get-0x4
    1a66:	test   rax,rax
    1a69:	je     1b39 <botlish_fn_21+0x140>
    1a6f:	jmp    1a7c <botlish_fn_21+0x83>
    1a74:	mov    rax,QWORD PTR [rsi+0x10]
    1a78:	mov    rax,QWORD PTR [rax+rcx*8]
    1a7c:	mov    QWORD PTR [rsp],rax
    1a80:	mov    rdi,rbx
    1a83:	mov    r14,rax
    1a86:	mov    rax,QWORD PTR [rdi+0x30]
    1a8a:	mov    rsi,QWORD PTR [rax+0x8]
    1a8e:	mov    r13,rsi
    1a91:	mov    edx,0x21
    1a96:	mov    rsi,r12
    1a99:	call   1a9e <botlish_fn_21+0xa5>
			1a9a: R_X86_64_PLT32	rt_int_mod-0x4
    1a9e:	test   rax,rax
    1aa1:	je     1b39 <botlish_fn_21+0x140>
    1aa7:	test   rax,0x1
    1aad:	jne    1abe <botlish_fn_21+0xc5>
    1ab3:	mov    rdx,rax
    1ab6:	mov    rsi,r13
    1ab9:	jmp    1ad7 <botlish_fn_21+0xde>
    1abe:	mov    rsi,r13
    1ac1:	mov    rdx,QWORD PTR [rsi+0x8]
    1ac5:	mov    rcx,rax
    1ac8:	sar    rcx,1
    1acb:	cmp    rcx,rdx
    1ace:	jb     1aed <botlish_fn_21+0xf4>
    1ad4:	mov    rdx,rax
    1ad7:	mov    rdi,rbx
    1ada:	call   1adf <botlish_fn_21+0xe6>
			1adb: R_X86_64_PLT32	rt_list_get-0x4
    1adf:	test   rax,rax
    1ae2:	je     1b39 <botlish_fn_21+0x140>
    1ae8:	jmp    1af5 <botlish_fn_21+0xfc>
    1aed:	mov    rax,QWORD PTR [rsi+0x10]
    1af1:	mov    rax,QWORD PTR [rax+rcx*8]
    1af5:	mov    QWORD PTR [rsp+0x8],rax
    1afa:	lea    rcx,[rsp+0x10]
    1aff:	mov    QWORD PTR [rsp+0x10],0x0
    1b08:	mov    rdx,r14
    1b0b:	mov    QWORD PTR [rsp+0x18],rdx
    1b10:	mov    QWORD PTR [rsp+0x20],0x0
    1b19:	mov    QWORD PTR [rsp+0x28],rax
    1b1e:	mov    esi,0x2
    1b23:	mov    edx,0x4
    1b28:	mov    rdi,rbx
    1b2b:	call   1b30 <botlish_fn_21+0x137>
			1b2c: R_X86_64_PLT32	rt_construct-0x4
    1b30:	test   rax,rax
    1b33:	jne    1b59 <botlish_fn_21+0x160>
    1b39:	xor    rax,rax
    1b3c:	mov    rbx,QWORD PTR [rsp+0x30]
    1b41:	mov    r12,QWORD PTR [rsp+0x38]
    1b46:	mov    r13,QWORD PTR [rsp+0x40]
    1b4b:	mov    r14,QWORD PTR [rsp+0x48]
    1b50:	add    rsp,0x50
    1b54:	mov    rsp,rbp
    1b57:	pop    rbp
    1b58:	ret
    1b59:	mov    rbx,QWORD PTR [rsp+0x30]
    1b5e:	mov    r12,QWORD PTR [rsp+0x38]
    1b63:	mov    r13,QWORD PTR [rsp+0x40]
    1b68:	mov    r14,QWORD PTR [rsp+0x48]
    1b6d:	add    rsp,0x50
    1b71:	mov    rsp,rbp
    1b74:	pop    rbp
    1b75:	ret

0000000000001b76 <botlish_entry_21: hex_pair<int>>:
    1b76:	push   rbp
    1b77:	mov    rbp,rsp
    1b7a:	sub    rsp,0x10
    1b7e:	mov    QWORD PTR [rsp],r12
    1b82:	mov    r12,rdi
    1b85:	mov    rsi,QWORD PTR [rdx]
    1b88:	call   1b8d <botlish_entry_21+0x17>
			1b89: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1b8d:	mov    r8,QWORD PTR [rip+0x0]        # 1b94 <botlish_entry_21+0x1e>
			1b90: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1b94:	mov    rsi,rax
    1b97:	mov    rdi,r12
    1b9a:	call   r8
    1b9d:	mov    r12,QWORD PTR [rsp]
    1ba1:	add    rsp,0x10
    1ba5:	mov    rsp,rbp
    1ba8:	pop    rbp
    1ba9:	ret

0000000000001baa <botlish_fn_22: esc_bytes<List[int], int, str>>:
    1baa:	push   rbp
    1bab:	mov    rbp,rsp
    1bae:	sub    rsp,0x90
    1bb5:	mov    QWORD PTR [rsp+0x60],rbx
    1bba:	mov    QWORD PTR [rsp+0x68],r12
    1bbf:	mov    QWORD PTR [rsp+0x70],r13
    1bc4:	mov    QWORD PTR [rsp+0x78],r14
    1bc9:	mov    QWORD PTR [rsp+0x80],r15
    1bd1:	mov    r13,rdx
    1bd4:	mov    QWORD PTR [rsp],rsi
    1bd8:	mov    QWORD PTR [rsp+0x8],rcx
    1bdd:	lea    r14,[rsp+0x20]
    1be2:	mov    rbx,rdi
    1be5:	mov    r12,rsi
    1be8:	mov    QWORD PTR [rsp+0x50],rcx
    1bed:	mov    rsi,r12
    1bf0:	mov    rdi,rbx
    1bf3:	call   1bf8 <botlish_fn_22+0x4e>
			1bf4: R_X86_64_PLT32	rt_list_len-0x4
    1bf8:	sar    rax,1
    1bfb:	cmp    r13,rax
    1bfe:	jge    1d0e <botlish_fn_22+0x164>
    1c04:	mov    rax,QWORD PTR [rbx+0x10]
    1c08:	mov    r15,QWORD PTR [rax+0x10]
    1c0c:	mov    QWORD PTR [rsp+0x10],r15
    1c11:	mov    rcx,QWORD PTR [r12+0x8]
    1c16:	mov    rax,r13
    1c19:	shl    rax,1
    1c1c:	or     rax,0x1
    1c20:	sar    rax,1
    1c23:	cmp    rax,rcx
    1c26:	jb     1c52 <botlish_fn_22+0xa8>
    1c2c:	mov    rdx,r13
    1c2f:	shl    rdx,1
    1c32:	or     rdx,0x1
    1c36:	mov    rsi,r12
    1c39:	mov    rdi,rbx
    1c3c:	call   1c41 <botlish_fn_22+0x97>
			1c3d: R_X86_64_PLT32	rt_list_get-0x4
    1c41:	test   rax,rax
    1c44:	je     1cc9 <botlish_fn_22+0x11f>
    1c4a:	mov    rsi,rax
    1c4d:	jmp    1c5b <botlish_fn_22+0xb1>
    1c52:	mov    rcx,QWORD PTR [r12+0x10]
    1c57:	mov    rsi,QWORD PTR [rcx+rax*8]
    1c5b:	mov    QWORD PTR [rsp+0x18],rsi
    1c60:	mov    rdi,rbx
    1c63:	call   1c68 <botlish_fn_22+0xbe>
			1c64: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1c68:	test   rax,rax
    1c6b:	je     1cc9 <botlish_fn_22+0x11f>
    1c71:	mov    QWORD PTR [rsp+0x18],rax
    1c76:	mov    rcx,rax
    1c79:	mov    QWORD PTR [rsp+0x20],0x0
    1c82:	mov    rax,QWORD PTR [rsp+0x50]
    1c87:	mov    QWORD PTR [rsp+0x28],rax
    1c8c:	mov    QWORD PTR [rsp+0x30],0x0
    1c95:	mov    QWORD PTR [rsp+0x38],r15
    1c9a:	mov    QWORD PTR [rsp+0x40],0x0
    1ca3:	mov    rax,rcx
    1ca6:	mov    QWORD PTR [rsp+0x48],rax
    1cab:	mov    esi,0x2
    1cb0:	mov    edx,0x6
    1cb5:	mov    rcx,r14
    1cb8:	mov    rdi,rbx
    1cbb:	call   1cc0 <botlish_fn_22+0x116>
			1cbc: R_X86_64_PLT32	rt_construct-0x4
    1cc0:	test   rax,rax
    1cc3:	jne    1cf4 <botlish_fn_22+0x14a>
    1cc9:	xor    rax,rax
    1ccc:	mov    rbx,QWORD PTR [rsp+0x60]
    1cd1:	mov    r12,QWORD PTR [rsp+0x68]
    1cd6:	mov    r13,QWORD PTR [rsp+0x70]
    1cdb:	mov    r14,QWORD PTR [rsp+0x78]
    1ce0:	mov    r15,QWORD PTR [rsp+0x80]
    1ce8:	add    rsp,0x90
    1cef:	mov    rsp,rbp
    1cf2:	pop    rbp
    1cf3:	ret
    1cf4:	mov    QWORD PTR [rsp],r12
    1cf8:	mov    QWORD PTR [rsp+0x8],rax
    1cfd:	add    r13,0x1
    1d04:	mov    QWORD PTR [rsp+0x50],rax
    1d09:	jmp    1bed <botlish_fn_22+0x43>
    1d0e:	mov    rax,QWORD PTR [rsp+0x50]
    1d13:	mov    rbx,QWORD PTR [rsp+0x60]
    1d18:	mov    r12,QWORD PTR [rsp+0x68]
    1d1d:	mov    r13,QWORD PTR [rsp+0x70]
    1d22:	mov    r14,QWORD PTR [rsp+0x78]
    1d27:	mov    r15,QWORD PTR [rsp+0x80]
    1d2f:	add    rsp,0x90
    1d36:	mov    rsp,rbp
    1d39:	pop    rbp
    1d3a:	ret

0000000000001d3b <botlish_entry_22: esc_bytes<List[int], int, str>>:
    1d3b:	push   rbp
    1d3c:	mov    rbp,rsp
    1d3f:	sub    rsp,0x10
    1d43:	mov    QWORD PTR [rsp],r12
    1d47:	mov    r12,rdi
    1d4a:	mov    rsi,QWORD PTR [rdx]
    1d4d:	mov    rax,rdx
    1d50:	mov    rdx,QWORD PTR [rax+0x8]
    1d54:	mov    rcx,QWORD PTR [rax+0x10]
    1d58:	sar    rdx,1
    1d5b:	call   1d60 <botlish_entry_22+0x25>
			1d5c: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1d60:	mov    r9,QWORD PTR [rip+0x0]        # 1d67 <botlish_entry_22+0x2c>
			1d63: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1d67:	mov    rsi,rax
    1d6a:	mov    rdi,r12
    1d6d:	call   r9
    1d70:	mov    r12,QWORD PTR [rsp]
    1d74:	add    rsp,0x10
    1d78:	mov    rsp,rbp
    1d7b:	pop    rbp
    1d7c:	ret

0000000000001d7d <botlish_fn_23: esc_char<str>>:
    1d7d:	push   rbp
    1d7e:	mov    rbp,rsp
    1d81:	sub    rsp,0x30
    1d85:	mov    QWORD PTR [rsp+0x10],rbx
    1d8a:	mov    QWORD PTR [rsp+0x18],r12
    1d8f:	mov    QWORD PTR [rsp+0x20],r13
    1d94:	mov    rbx,rdi
    1d97:	mov    QWORD PTR [rsp+0x8],0x0
    1da0:	mov    QWORD PTR [rsp],rsi
    1da4:	mov    r13,rsi
    1da7:	mov    rsi,r13
    1daa:	mov    rdi,rbx
    1dad:	call   1db2 <botlish_fn_23+0x35>
			1dae: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1db2:	mov    rcx,rax
    1db5:	mov    r12,rax
    1db8:	test   rax,rcx
    1dbb:	je     1e86 <botlish_fn_23+0x109>
    1dc1:	mov    rax,r12
    1dc4:	mov    QWORD PTR [rsp],rax
    1dc8:	mov    rsi,r12
    1dcb:	mov    rdi,rbx
    1dce:	call   1dd3 <botlish_fn_23+0x56>
			1dcf: R_X86_64_PLT32	rt_list_len-0x4
    1dd3:	sar    rax,1
    1dd6:	cmp    rax,0x1
    1dda:	je     1e0c <botlish_fn_23+0x8f>
    1de0:	mov    rdi,rbx
    1de3:	mov    rax,QWORD PTR [rdi+0x10]
    1de7:	mov    rcx,QWORD PTR [rax+0xe8]
    1dee:	mov    QWORD PTR [rsp+0x8],rcx
    1df3:	xor    rdx,rdx
    1df6:	mov    rsi,r12
    1df9:	call   1dfe <botlish_fn_23+0x81>
			1dfa: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1dfe:	test   rax,rax
    1e01:	je     1e86 <botlish_fn_23+0x109>
    1e07:	jmp    1ea7 <botlish_fn_23+0x12a>
    1e0c:	mov    rsi,r12
    1e0f:	mov    rax,QWORD PTR [rsi+0x8]
    1e13:	mov    r12,rsi
    1e16:	test   rax,rax
    1e19:	jne    1e40 <botlish_fn_23+0xc3>
    1e1f:	mov    edx,0x1
    1e24:	mov    rsi,r12
    1e27:	mov    rdi,rbx
    1e2a:	call   1e2f <botlish_fn_23+0xb2>
			1e2b: R_X86_64_PLT32	rt_list_get-0x4
    1e2f:	test   rax,rax
    1e32:	je     1e86 <botlish_fn_23+0x109>
    1e38:	mov    rsi,rax
    1e3b:	jmp    1e4a <botlish_fn_23+0xcd>
    1e40:	mov    rsi,r12
    1e43:	mov    rax,QWORD PTR [rsi+0x10]
    1e47:	mov    rsi,QWORD PTR [rax]
    1e4a:	sar    rsi,1
    1e4d:	mov    rdi,rbx
    1e50:	call   1e55 <botlish_fn_23+0xd8>
			1e51: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1e55:	cmp    rax,0x6
    1e59:	je     1ea4 <botlish_fn_23+0x127>
    1e5f:	mov    rdi,rbx
    1e62:	mov    rax,QWORD PTR [rdi+0x10]
    1e66:	mov    rcx,QWORD PTR [rax+0xe8]
    1e6d:	mov    QWORD PTR [rsp+0x8],rcx
    1e72:	xor    rdx,rdx
    1e75:	mov    rsi,r12
    1e78:	call   1e7d <botlish_fn_23+0x100>
			1e79: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1e7d:	test   rax,rax
    1e80:	jne    1ea1 <botlish_fn_23+0x124>
    1e86:	xor    rax,rax
    1e89:	mov    rbx,QWORD PTR [rsp+0x10]
    1e8e:	mov    r12,QWORD PTR [rsp+0x18]
    1e93:	mov    r13,QWORD PTR [rsp+0x20]
    1e98:	add    rsp,0x30
    1e9c:	mov    rsp,rbp
    1e9f:	pop    rbp
    1ea0:	ret
    1ea1:	mov    r13,rax
    1ea4:	mov    rax,r13
    1ea7:	mov    rbx,QWORD PTR [rsp+0x10]
    1eac:	mov    r12,QWORD PTR [rsp+0x18]
    1eb1:	mov    r13,QWORD PTR [rsp+0x20]
    1eb6:	add    rsp,0x30
    1eba:	mov    rsp,rbp
    1ebd:	pop    rbp
    1ebe:	ret

0000000000001ebf <botlish_entry_23: esc_char<str>>:
    1ebf:	push   rbp
    1ec0:	mov    rbp,rsp
    1ec3:	sub    rsp,0x10
    1ec7:	mov    QWORD PTR [rsp],r12
    1ecb:	mov    r12,rdi
    1ece:	mov    rsi,QWORD PTR [rdx]
    1ed1:	call   1ed6 <botlish_entry_23+0x17>
			1ed2: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1ed6:	mov    r8,QWORD PTR [rip+0x0]        # 1edd <botlish_entry_23+0x1e>
			1ed9: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1edd:	mov    rsi,rax
    1ee0:	mov    rdi,r12
    1ee3:	call   r8
    1ee6:	mov    r12,QWORD PTR [rsp]
    1eea:	add    rsp,0x10
    1eee:	mov    rsp,rbp
    1ef1:	pop    rbp
    1ef2:	ret

0000000000001ef3 <botlish_fn_24: esc_from<str, int, str>>:
    1ef3:	push   rbp
    1ef4:	mov    rbp,rsp
    1ef7:	sub    rsp,0x80
    1efe:	mov    QWORD PTR [rsp+0x50],rbx
    1f03:	mov    QWORD PTR [rsp+0x58],r12
    1f08:	mov    QWORD PTR [rsp+0x60],r13
    1f0d:	mov    QWORD PTR [rsp+0x68],r14
    1f12:	mov    QWORD PTR [rsp+0x70],r15
    1f17:	mov    r12,rdx
    1f1a:	mov    r14,rdi
    1f1d:	mov    QWORD PTR [rsp+0x10],0x0
    1f26:	mov    QWORD PTR [rsp+0x18],0x0
    1f2f:	mov    QWORD PTR [rsp],rsi
    1f33:	mov    QWORD PTR [rsp+0x8],rcx
    1f38:	mov    r15,rcx
    1f3b:	lea    r13,[rsp+0x30]
    1f40:	mov    rbx,rsi
    1f43:	mov    rsi,rbx
    1f46:	mov    rdi,r14
    1f49:	call   1f4e <botlish_fn_24+0x5b>
			1f4a: R_X86_64_PLT32	rt_str_len-0x4
    1f4e:	sar    rax,1
    1f51:	cmp    r12,rax
    1f54:	jge    1fff <botlish_fn_24+0x10c>
    1f5a:	mov    rdx,r12
    1f5d:	shl    rdx,1
    1f60:	or     rdx,0x1
    1f64:	mov    QWORD PTR [rsp+0x10],rdx
    1f69:	add    r12,0x1
    1f70:	mov    rcx,r12
    1f73:	shl    rcx,1
    1f76:	or     rcx,0x1
    1f7a:	mov    QWORD PTR [rsp+0x18],rcx
    1f7f:	mov    rsi,rbx
    1f82:	mov    rdi,r14
    1f85:	call   1f8a <botlish_fn_24+0x97>
			1f86: R_X86_64_PLT32	rt_substr-0x4
    1f8a:	test   rax,rax
    1f8d:	je     2031 <botlish_fn_24+0x13e>
    1f93:	mov    QWORD PTR [rsp+0x10],rax
    1f98:	mov    rsi,rax
    1f9b:	mov    rdi,r14
    1f9e:	call   1fa3 <botlish_fn_24+0xb0>
			1f9f: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1fa3:	test   rax,rax
    1fa6:	je     2031 <botlish_fn_24+0x13e>
    1fac:	mov    QWORD PTR [rsp+0x10],rax
    1fb1:	mov    QWORD PTR [rsp+0x30],0x0
    1fba:	mov    rcx,r15
    1fbd:	mov    QWORD PTR [rsp+0x38],rcx
    1fc2:	mov    QWORD PTR [rsp+0x40],0x0
    1fcb:	mov    QWORD PTR [rsp+0x48],rax
    1fd0:	mov    esi,0x2
    1fd5:	mov    edx,0x4
    1fda:	mov    rcx,r13
    1fdd:	mov    rdi,r14
    1fe0:	call   1fe5 <botlish_fn_24+0xf2>
			1fe1: R_X86_64_PLT32	rt_construct-0x4
    1fe5:	test   rax,rax
    1fe8:	je     2031 <botlish_fn_24+0x13e>
    1fee:	mov    QWORD PTR [rsp],rbx
    1ff2:	mov    QWORD PTR [rsp+0x8],rax
    1ff7:	mov    r15,rax
    1ffa:	jmp    1f43 <botlish_fn_24+0x50>
    1fff:	mov    rcx,r15
    2002:	xor    rsi,rsi
    2005:	lea    rax,[rsp+0x20]
    200a:	mov    QWORD PTR [rsp+0x20],0x0
    2013:	mov    QWORD PTR [rsp+0x28],rcx
    2018:	mov    edx,0x2
    201d:	mov    rcx,rax
    2020:	mov    rdi,r14
    2023:	call   2028 <botlish_fn_24+0x135>
			2024: R_X86_64_PLT32	rt_construct-0x4
    2028:	test   rax,rax
    202b:	jne    2059 <botlish_fn_24+0x166>
    2031:	xor    rax,rax
    2034:	mov    rbx,QWORD PTR [rsp+0x50]
    2039:	mov    r12,QWORD PTR [rsp+0x58]
    203e:	mov    r13,QWORD PTR [rsp+0x60]
    2043:	mov    r14,QWORD PTR [rsp+0x68]
    2048:	mov    r15,QWORD PTR [rsp+0x70]
    204d:	add    rsp,0x80
    2054:	mov    rsp,rbp
    2057:	pop    rbp
    2058:	ret
    2059:	mov    rbx,QWORD PTR [rsp+0x50]
    205e:	mov    r12,QWORD PTR [rsp+0x58]
    2063:	mov    r13,QWORD PTR [rsp+0x60]
    2068:	mov    r14,QWORD PTR [rsp+0x68]
    206d:	mov    r15,QWORD PTR [rsp+0x70]
    2072:	add    rsp,0x80
    2079:	mov    rsp,rbp
    207c:	pop    rbp
    207d:	ret

000000000000207e <botlish_entry_24: esc_from<str, int, str>>:
    207e:	push   rbp
    207f:	mov    rbp,rsp
    2082:	mov    rsi,QWORD PTR [rdx]
    2085:	mov    r10,rdx
    2088:	mov    rdx,QWORD PTR [r10+0x8]
    208c:	mov    rcx,QWORD PTR [r10+0x10]
    2090:	sar    rdx,1
    2093:	call   2098 <botlish_entry_24+0x1a>
			2094: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    2098:	mov    rsp,rbp
    209b:	pop    rbp
    209c:	ret

000000000000209d <botlish_fn_25: check<int, int, str, str>>:
    209d:	push   rbp
    209e:	mov    rbp,rsp
    20a1:	sub    rsp,0x50
    20a5:	mov    QWORD PTR [rsp+0x20],rbx
    20aa:	mov    QWORD PTR [rsp+0x28],r12
    20af:	mov    QWORD PTR [rsp+0x30],r13
    20b4:	mov    QWORD PTR [rsp+0x38],r14
    20b9:	mov    QWORD PTR [rsp+0x40],r15
    20be:	mov    r14,rdi
    20c1:	mov    QWORD PTR [rsp+0x18],0x0
    20ca:	mov    QWORD PTR [rsp],rdx
    20ce:	mov    QWORD PTR [rsp+0x8],rcx
    20d3:	mov    QWORD PTR [rsp+0x10],r8
    20d8:	mov    r13,r8
    20db:	mov    r12,rsi
    20de:	mov    r15,rdx
    20e1:	test   r12,r12
    20e4:	jle    21a6 <botlish_fn_25+0x109>
    20ea:	mov    rbx,rcx
    20ed:	mov    rsi,rbx
    20f0:	mov    rdi,r14
    20f3:	call   20f8 <botlish_fn_25+0x5b>
			20f4: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
    20f8:	test   rax,rax
    20fb:	jne    2126 <botlish_fn_25+0x89>
    2101:	xor    rax,rax
    2104:	mov    rbx,QWORD PTR [rsp+0x20]
    2109:	mov    r12,QWORD PTR [rsp+0x28]
    210e:	mov    r13,QWORD PTR [rsp+0x30]
    2113:	mov    r14,QWORD PTR [rsp+0x38]
    2118:	mov    r15,QWORD PTR [rsp+0x40]
    211d:	add    rsp,0x50
    2121:	mov    rsp,rbp
    2124:	pop    rbp
    2125:	ret
    2126:	cmp    rax,0x6
    212a:	je     2146 <botlish_fn_25+0xa9>
    2130:	mov    edx,0x1
    2135:	mov    QWORD PTR [rsp+0x18],0x1
    213e:	mov    rsi,r15
    2141:	jmp    2157 <botlish_fn_25+0xba>
    2146:	mov    edx,0x3
    214b:	mov    QWORD PTR [rsp+0x18],0x3
    2154:	mov    rsi,r15
    2157:	mov    rax,rsi
    215a:	and    rax,rdx
    215d:	test   rax,0x1
    2163:	je     217e <botlish_fn_25+0xe1>
    2169:	lea    rcx,[rdx-0x1]
    216d:	mov    rax,rsi
    2170:	add    rax,rcx
    2173:	seto   cl
    2176:	test   cl,cl
    2178:	je     2186 <botlish_fn_25+0xe9>
    217e:	mov    rdi,r14
    2181:	call   2186 <botlish_fn_25+0xe9>
			2182: R_X86_64_PLT32	rt_int_add-0x4
    2186:	mov    QWORD PTR [rsp],rax
    218a:	mov    QWORD PTR [rsp+0x8],rbx
    218f:	mov    r8,r13
    2192:	mov    QWORD PTR [rsp+0x10],r8
    2197:	sub    r12,0x1
    219b:	mov    rcx,rbx
    219e:	mov    r15,rax
    21a1:	jmp    20e1 <botlish_fn_25+0x44>
    21a6:	mov    rax,r15
    21a9:	mov    rbx,QWORD PTR [rsp+0x20]
    21ae:	mov    r12,QWORD PTR [rsp+0x28]
    21b3:	mov    r13,QWORD PTR [rsp+0x30]
    21b8:	mov    r14,QWORD PTR [rsp+0x38]
    21bd:	mov    r15,QWORD PTR [rsp+0x40]
    21c2:	add    rsp,0x50
    21c6:	mov    rsp,rbp
    21c9:	pop    rbp
    21ca:	ret

00000000000021cb <botlish_entry_25: check<int, int, str, str>>:
    21cb:	push   rbp
    21cc:	mov    rbp,rsp
    21cf:	mov    rsi,QWORD PTR [rdx]
    21d2:	mov    r9,QWORD PTR [rdx+0x8]
    21d6:	mov    rcx,QWORD PTR [rdx+0x10]
    21da:	mov    r8,QWORD PTR [rdx+0x18]
    21de:	sar    rsi,1
    21e1:	mov    rdx,r9
    21e4:	call   21e9 <botlish_entry_25+0x1e>
			21e5: R_X86_64_PLT32	botlish_fn_25-0x4 ; check<int, int, str, str>
    21e9:	mov    rsp,rbp
    21ec:	pop    rbp
    21ed:	ret

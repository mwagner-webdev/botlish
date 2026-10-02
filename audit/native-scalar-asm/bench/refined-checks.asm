; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 9324  (per function: 1425 39 289 609 74 74 74 128 128 379 262 222 274 238 464 456 468 1076 140 94 103 474 491 525 474 344)
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
     5ab:	mov    rax,rsi
     5ae:	jne    5dd <botlish_fn_2+0x4d>
     5b4:	mov    edx,0x1
     5b9:	mov    rbx,rax
     5bc:	mov    rsi,rbx
     5bf:	mov    rdi,r12
     5c2:	call   5c7 <botlish_fn_2+0x37>
			5c3: R_X86_64_PLT32	rt_int_cmp-0x4
     5c7:	mov    r8d,0x2
     5cd:	test   rax,rax
     5d0:	cmovl  r8,QWORD PTR [rip+0xb0]        # 688 <botlish_fn_2+0xf8>
     5d8:	jmp    5f1 <botlish_fn_2+0x61>
     5dd:	mov    rbx,rax
     5e0:	mov    r8d,0x2
     5e6:	test   rbx,rbx
     5e9:	cmovle r8,QWORD PTR [rip+0x97]        # 688 <botlish_fn_2+0xf8>
     5f1:	test   rbx,0x1
     5f8:	jne    623 <botlish_fn_2+0x93>
     5fe:	mov    edx,0x1ff
     603:	mov    rsi,rbx
     606:	mov    rdi,r12
     609:	call   60e <botlish_fn_2+0x7e>
			60a: R_X86_64_PLT32	rt_int_cmp-0x4
     60e:	mov    ecx,0x2
     613:	test   rax,rax
     616:	cmovg  rcx,QWORD PTR [rip+0x6a]        # 688 <botlish_fn_2+0xf8>
     61e:	jmp    637 <botlish_fn_2+0xa7>
     623:	mov    ecx,0x2
     628:	cmp    rbx,0x1ff
     62f:	cmovg  rcx,QWORD PTR [rip+0x51]        # 688 <botlish_fn_2+0xf8>
     637:	cmp    rcx,0x6
     63b:	je     656 <botlish_fn_2+0xc6>
     641:	mov    rax,rbx
     644:	mov    rbx,QWORD PTR [rsp]
     648:	mov    r12,QWORD PTR [rsp+0x8]
     64d:	add    rsp,0x10
     651:	mov    rsp,rbp
     654:	pop    rbp
     655:	ret
     656:	mov    rdi,r12
     659:	mov    rax,QWORD PTR [rdi+0x10]
     65d:	mov    rdx,QWORD PTR [rax+0xc0]
     664:	mov    esi,0x1
     669:	call   66e <botlish_fn_2+0xde>
			66a: R_X86_64_PLT32	rt_fail_declared-0x4
     66e:	xor    rax,rax
     671:	mov    rbx,QWORD PTR [rsp]
     675:	mov    r12,QWORD PTR [rsp+0x8]
     67a:	add    rsp,0x10
     67e:	mov    rsp,rbp
     681:	pop    rbp
     682:	ret
     683:	add    BYTE PTR [rax],al
     685:	add    BYTE PTR [rax],al
     687:	add    BYTE PTR [rsi],al
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
     69c:	mov    rsp,rbp
     69f:	pop    rbp
     6a0:	ret
     6a1:	add    BYTE PTR [rax],al
     6a3:	add    BYTE PTR [rax],al
     6a5:	add    BYTE PTR [rax],al
	...

00000000000006a8 <botlish_fn_3: byte::set<List[UnicodeChar]>>:
     6a8:	push   rbp
     6a9:	mov    rbp,rsp
     6ac:	sub    rsp,0x60
     6b0:	mov    QWORD PTR [rsp+0x30],rbx
     6b5:	mov    QWORD PTR [rsp+0x38],r12
     6ba:	mov    QWORD PTR [rsp+0x40],r13
     6bf:	mov    QWORD PTR [rsp+0x48],r14
     6c4:	mov    QWORD PTR [rsp+0x50],r15
     6c9:	mov    r13,rdi
     6cc:	mov    QWORD PTR [rsp+0x18],0x0
     6d5:	mov    QWORD PTR [rsp+0x20],0x0
     6de:	mov    QWORD PTR [rsp],rsi
     6e2:	mov    rbx,rsi
     6e5:	mov    rdi,r13
     6e8:	call   6ed <botlish_fn_3+0x45>
			6e9: R_X86_64_PLT32	rt_list_len-0x4
     6ed:	mov    QWORD PTR [rsp+0x8],rax
     6f2:	mov    r12,rax
     6f5:	mov    QWORD PTR [rsp+0x10],0x1
     6fe:	xor    rdx,rdx
     701:	mov    rdi,r13
     704:	mov    rsi,rdx
     707:	call   70c <botlish_fn_3+0x64>
			708: R_X86_64_PLT32	rt_list_new-0x4
     70c:	test   rax,rax
     70f:	je     830 <botlish_fn_3+0x188>
     715:	mov    QWORD PTR [rsp+0x18],rax
     71a:	mov    esi,0x1
     71f:	mov    r14,rsi
     722:	mov    r15,rax
     725:	mov    rax,rsi
     728:	and    rax,r12
     72b:	mov    r14,rsi
     72e:	test   rax,0x1
     734:	jne    75d <botlish_fn_3+0xb5>
     73a:	mov    rdx,r12
     73d:	mov    rsi,r14
     740:	mov    rdi,r13
     743:	call   748 <botlish_fn_3+0xa0>
			744: R_X86_64_PLT32	rt_int_cmp-0x4
     748:	mov    ecx,0x2
     74d:	test   rax,rax
     750:	cmovl  rcx,QWORD PTR [rip+0x170]        # 8c8 <botlish_fn_3+0x220>
     758:	jmp    770 <botlish_fn_3+0xc8>
     75d:	mov    ecx,0x2
     762:	mov    rsi,r14
     765:	cmp    rsi,r12
     768:	cmovl  rcx,QWORD PTR [rip+0x158]        # 8c8 <botlish_fn_3+0x220>
     770:	cmp    rcx,0x6
     774:	je     7ab <botlish_fn_3+0x103>
     77a:	mov    rsi,r15
     77d:	mov    QWORD PTR [rsp],rsi
     781:	mov    rdi,r13
     784:	call   789 <botlish_fn_3+0xe1>
			785: R_X86_64_PLT32	rt_set_from_list-0x4
     789:	mov    rbx,QWORD PTR [rsp+0x30]
     78e:	mov    r12,QWORD PTR [rsp+0x38]
     793:	mov    r13,QWORD PTR [rsp+0x40]
     798:	mov    r14,QWORD PTR [rsp+0x48]
     79d:	mov    r15,QWORD PTR [rsp+0x50]
     7a2:	add    rsp,0x60
     7a6:	mov    rsp,rbp
     7a9:	pop    rbp
     7aa:	ret
     7ab:	mov    rsi,r14
     7ae:	test   rsi,0x1
     7b5:	je     7d1 <botlish_fn_3+0x129>
     7bb:	mov    rcx,QWORD PTR [rbx+0x8]
     7bf:	mov    rsi,r14
     7c2:	mov    rax,rsi
     7c5:	sar    rax,1
     7c8:	cmp    rax,rcx
     7cb:	jb     7f0 <botlish_fn_3+0x148>
     7d1:	mov    rdx,r14
     7d4:	mov    rsi,rbx
     7d7:	mov    rdi,r13
     7da:	call   7df <botlish_fn_3+0x137>
			7db: R_X86_64_PLT32	rt_list_get-0x4
     7df:	test   rax,rax
     7e2:	je     830 <botlish_fn_3+0x188>
     7e8:	mov    rsi,rax
     7eb:	jmp    7f8 <botlish_fn_3+0x150>
     7f0:	mov    rdx,QWORD PTR [rbx+0x10]
     7f4:	mov    rsi,QWORD PTR [rdx+rax*8]
     7f8:	mov    rdi,r13
     7fb:	call   800 <botlish_fn_3+0x158>
			7fc: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     800:	mov    rsi,rax
     803:	mov    rdi,r13
     806:	call   80b <botlish_fn_3+0x163>
			807: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     80b:	test   rax,rax
     80e:	je     830 <botlish_fn_3+0x188>
     814:	mov    QWORD PTR [rsp+0x20],rax
     819:	mov    rdx,rax
     81c:	mov    rsi,r15
     81f:	mov    rdi,r13
     822:	call   827 <botlish_fn_3+0x17f>
			823: R_X86_64_PLT32	rt_list_append-0x4
     827:	test   rax,rax
     82a:	jne    855 <botlish_fn_3+0x1ad>
     830:	xor    rax,rax
     833:	mov    rbx,QWORD PTR [rsp+0x30]
     838:	mov    r12,QWORD PTR [rsp+0x38]
     83d:	mov    r13,QWORD PTR [rsp+0x40]
     842:	mov    r14,QWORD PTR [rsp+0x48]
     847:	mov    r15,QWORD PTR [rsp+0x50]
     84c:	add    rsp,0x60
     850:	mov    rsp,rbp
     853:	pop    rbp
     854:	ret
     855:	mov    QWORD PTR [rsp+0x18],rax
     85a:	mov    r15,rax
     85d:	mov    edx,0x3
     862:	mov    QWORD PTR [rsp+0x20],0x3
     86b:	mov    rsi,r14
     86e:	test   rsi,0x1
     875:	jne    883 <botlish_fn_3+0x1db>
     87b:	mov    rsi,r14
     87e:	jmp    8ab <botlish_fn_3+0x203>
     883:	mov    rsi,r14
     886:	mov    rcx,rsi
     889:	add    rcx,0x2
     88d:	seto   al
     890:	test   al,al
     892:	je     8a0 <botlish_fn_3+0x1f8>
     898:	mov    rsi,r14
     89b:	jmp    8ab <botlish_fn_3+0x203>
     8a0:	mov    rsi,rcx
     8a3:	mov    r14,rcx
     8a6:	jmp    8b9 <botlish_fn_3+0x211>
     8ab:	mov    rdi,r13
     8ae:	call   8b3 <botlish_fn_3+0x20b>
			8af: R_X86_64_PLT32	rt_int_add-0x4
     8b3:	mov    rsi,rax
     8b6:	mov    r14,rax
     8b9:	mov    QWORD PTR [rsp+0x10],rsi
     8be:	mov    rsi,r14
     8c1:	jmp    725 <botlish_fn_3+0x7d>
     8c6:	add    BYTE PTR [rax],al
     8c8:	(bad)
     8c9:	add    BYTE PTR [rax],al
     8cb:	add    BYTE PTR [rax],al
     8cd:	add    BYTE PTR [rax],al
	...

00000000000008d0 <botlish_entry_3: byte::set<List[UnicodeChar]>>:
     8d0:	push   rbp
     8d1:	mov    rbp,rsp
     8d4:	mov    rsi,QWORD PTR [rdx]
     8d7:	call   8dc <botlish_entry_3+0xc>
			8d8: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::set<List[UnicodeChar]>
     8dc:	mov    rsp,rbp
     8df:	pop    rbp
     8e0:	ret

00000000000008e1 <botlish_fn_4: ascii::is_digit<int>>:
     8e1:	push   rbp
     8e2:	mov    rbp,rsp
     8e5:	cmp    rsi,0x30
     8e9:	jge    8f9 <botlish_fn_4+0x18>
     8ef:	mov    eax,0x2
     8f4:	jmp    912 <botlish_fn_4+0x31>
     8f9:	cmp    rsi,0x39
     8fd:	jle    90d <botlish_fn_4+0x2c>
     903:	mov    eax,0x2
     908:	jmp    912 <botlish_fn_4+0x31>
     90d:	mov    eax,0x6
     912:	mov    rsp,rbp
     915:	pop    rbp
     916:	ret

0000000000000917 <botlish_entry_4: ascii::is_digit<int>>:
     917:	push   rbp
     918:	mov    rbp,rsp
     91b:	mov    rsi,QWORD PTR [rdx]
     91e:	sar    rsi,1
     921:	call   926 <botlish_entry_4+0xf>
			922: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     926:	mov    rsp,rbp
     929:	pop    rbp
     92a:	ret

000000000000092b <botlish_fn_5: ascii::is_upper<int>>:
     92b:	push   rbp
     92c:	mov    rbp,rsp
     92f:	cmp    rsi,0x41
     933:	jge    943 <botlish_fn_5+0x18>
     939:	mov    eax,0x2
     93e:	jmp    95c <botlish_fn_5+0x31>
     943:	cmp    rsi,0x5a
     947:	jle    957 <botlish_fn_5+0x2c>
     94d:	mov    eax,0x2
     952:	jmp    95c <botlish_fn_5+0x31>
     957:	mov    eax,0x6
     95c:	mov    rsp,rbp
     95f:	pop    rbp
     960:	ret

0000000000000961 <botlish_entry_5: ascii::is_upper<int>>:
     961:	push   rbp
     962:	mov    rbp,rsp
     965:	mov    rsi,QWORD PTR [rdx]
     968:	sar    rsi,1
     96b:	call   970 <botlish_entry_5+0xf>
			96c: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     970:	mov    rsp,rbp
     973:	pop    rbp
     974:	ret

0000000000000975 <botlish_fn_6: ascii::is_lower<int>>:
     975:	push   rbp
     976:	mov    rbp,rsp
     979:	cmp    rsi,0x61
     97d:	jge    98d <botlish_fn_6+0x18>
     983:	mov    eax,0x2
     988:	jmp    9a6 <botlish_fn_6+0x31>
     98d:	cmp    rsi,0x7a
     991:	jle    9a1 <botlish_fn_6+0x2c>
     997:	mov    eax,0x2
     99c:	jmp    9a6 <botlish_fn_6+0x31>
     9a1:	mov    eax,0x6
     9a6:	mov    rsp,rbp
     9a9:	pop    rbp
     9aa:	ret

00000000000009ab <botlish_entry_6: ascii::is_lower<int>>:
     9ab:	push   rbp
     9ac:	mov    rbp,rsp
     9af:	mov    rsi,QWORD PTR [rdx]
     9b2:	sar    rsi,1
     9b5:	call   9ba <botlish_entry_6+0xf>
			9b6: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     9ba:	mov    rsp,rbp
     9bd:	pop    rbp
     9be:	ret

00000000000009bf <botlish_fn_7: ascii::is_alphabetic<int>>:
     9bf:	push   rbp
     9c0:	mov    rbp,rsp
     9c3:	sub    rsp,0x10
     9c7:	mov    QWORD PTR [rsp],r12
     9cb:	mov    QWORD PTR [rsp+0x8],r14
     9d0:	mov    r12,rsi
     9d3:	mov    r14,rdi
     9d6:	mov    rsi,r12
     9d9:	mov    rdi,r14
     9dc:	call   9e1 <botlish_fn_7+0x22>
			9dd: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     9e1:	cmp    rax,0x6
     9e5:	je     a14 <botlish_fn_7+0x55>
     9eb:	mov    rsi,r12
     9ee:	mov    rdi,r14
     9f1:	call   9f6 <botlish_fn_7+0x37>
			9f2: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     9f6:	cmp    rax,0x6
     9fa:	je     a0a <botlish_fn_7+0x4b>
     a00:	mov    eax,0x2
     a05:	jmp    a19 <botlish_fn_7+0x5a>
     a0a:	mov    eax,0x6
     a0f:	jmp    a19 <botlish_fn_7+0x5a>
     a14:	mov    eax,0x6
     a19:	mov    r12,QWORD PTR [rsp]
     a1d:	mov    r14,QWORD PTR [rsp+0x8]
     a22:	add    rsp,0x10
     a26:	mov    rsp,rbp
     a29:	pop    rbp
     a2a:	ret

0000000000000a2b <botlish_entry_7: ascii::is_alphabetic<int>>:
     a2b:	push   rbp
     a2c:	mov    rbp,rsp
     a2f:	mov    rsi,QWORD PTR [rdx]
     a32:	sar    rsi,1
     a35:	call   a3a <botlish_entry_7+0xf>
			a36: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     a3a:	mov    rsp,rbp
     a3d:	pop    rbp
     a3e:	ret

0000000000000a3f <botlish_fn_8: ascii::is_alphanumeric<int>>:
     a3f:	push   rbp
     a40:	mov    rbp,rsp
     a43:	sub    rsp,0x10
     a47:	mov    QWORD PTR [rsp],r12
     a4b:	mov    QWORD PTR [rsp+0x8],r14
     a50:	mov    r12,rsi
     a53:	mov    r14,rdi
     a56:	mov    rsi,r12
     a59:	mov    rdi,r14
     a5c:	call   a61 <botlish_fn_8+0x22>
			a5d: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     a61:	cmp    rax,0x6
     a65:	je     a94 <botlish_fn_8+0x55>
     a6b:	mov    rsi,r12
     a6e:	mov    rdi,r14
     a71:	call   a76 <botlish_fn_8+0x37>
			a72: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     a76:	cmp    rax,0x6
     a7a:	je     a8a <botlish_fn_8+0x4b>
     a80:	mov    eax,0x2
     a85:	jmp    a99 <botlish_fn_8+0x5a>
     a8a:	mov    eax,0x6
     a8f:	jmp    a99 <botlish_fn_8+0x5a>
     a94:	mov    eax,0x6
     a99:	mov    r12,QWORD PTR [rsp]
     a9d:	mov    r14,QWORD PTR [rsp+0x8]
     aa2:	add    rsp,0x10
     aa6:	mov    rsp,rbp
     aa9:	pop    rbp
     aaa:	ret

0000000000000aab <botlish_entry_8: ascii::is_alphanumeric<int>>:
     aab:	push   rbp
     aac:	mov    rbp,rsp
     aaf:	mov    rsi,QWORD PTR [rdx]
     ab2:	sar    rsi,1
     ab5:	call   aba <botlish_entry_8+0xf>
			ab6: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
     aba:	mov    rsp,rbp
     abd:	pop    rbp
     abe:	ret

0000000000000abf <botlish_fn_9: web::emailish?<str>>:
     abf:	push   rbp
     ac0:	mov    rbp,rsp
     ac3:	sub    rsp,0x50
     ac7:	mov    QWORD PTR [rsp+0x30],rbx
     acc:	mov    QWORD PTR [rsp+0x38],r12
     ad1:	mov    QWORD PTR [rsp+0x40],r13
     ad6:	mov    QWORD PTR [rsp+0x48],r14
     adb:	mov    r13,rdi
     ade:	mov    QWORD PTR [rsp],rsi
     ae2:	mov    r12,rsi
     ae5:	mov    rsi,r12
     ae8:	mov    rdi,r13
     aeb:	call   af0 <botlish_fn_9+0x31>
			aec: R_X86_64_PLT32	rt_str_len-0x4
     af0:	mov    r14,rax
     af3:	mov    QWORD PTR [rsp+0x8],rax
     af8:	mov    esi,0x1
     afd:	mov    QWORD PTR [rsp+0x10],0x1
     b06:	mov    rdi,r13
     b09:	mov    rax,QWORD PTR [rdi+0x10]
     b0d:	mov    rdx,QWORD PTR [rax+0xc8]
     b14:	mov    QWORD PTR [rsp+0x18],rdx
     b19:	mov    rcx,r14
     b1c:	mov    r8,r12
     b1f:	call   b24 <botlish_fn_9+0x65>
			b20: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<any, block(e239)>
     b24:	test   rax,rax
     b27:	je     bca <botlish_fn_9+0x10b>
     b2d:	mov    QWORD PTR [rsp+0x10],rax
     b32:	mov    rbx,rax
     b35:	sar    rbx,1
     b38:	mov    rsi,rax
     b3b:	test   rbx,rbx
     b3e:	je     bf9 <botlish_fn_9+0x13a>
     b44:	mov    rax,r14
     b47:	mov    rcx,rax
     b4a:	sar    rcx,1
     b4d:	cmp    rbx,rcx
     b50:	jge    bef <botlish_fn_9+0x130>
     b56:	lea    rcx,[rsp+0x20]
     b5b:	mov    rdx,r12
     b5e:	mov    rdi,r13
     b61:	call   b66 <botlish_fn_9+0xa7>
			b62: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
     b66:	test   rax,rax
     b69:	mov    rsi,rax
     b6c:	je     bca <botlish_fn_9+0x10b>
     b72:	mov    rdx,QWORD PTR [rsp+0x20]
     b77:	mov    rcx,QWORD PTR [rsp+0x28]
     b7c:	mov    rdi,r13
     b7f:	mov    rax,QWORD PTR [rdi+0x10]
     b83:	mov    r8,QWORD PTR [rax+0xd0]
     b8a:	call   b8f <botlish_fn_9+0xd0>
			b8b: R_X86_64_PLT32	rt_str_region_eq-0x4
     b8f:	cmp    rax,0x6
     b93:	je     ba3 <botlish_fn_9+0xe4>
     b99:	mov    eax,0x2
     b9e:	jmp    bfe <botlish_fn_9+0x13f>
     ba3:	lea    rsi,[rbx+0x1]
     ba7:	shl    rsi,1
     baa:	or     rsi,0x1
     bae:	mov    QWORD PTR [rsp+0x10],rsi
     bb3:	mov    rcx,r12
     bb6:	mov    rdx,r14
     bb9:	mov    rdi,r13
     bbc:	call   bc1 <botlish_fn_9+0x102>
			bbd: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<generic>
     bc1:	test   rax,rax
     bc4:	jne    bfe <botlish_fn_9+0x13f>
     bca:	xor    rax,rax
     bcd:	mov    rbx,QWORD PTR [rsp+0x30]
     bd2:	mov    r12,QWORD PTR [rsp+0x38]
     bd7:	mov    r13,QWORD PTR [rsp+0x40]
     bdc:	mov    r14,QWORD PTR [rsp+0x48]
     be1:	add    rsp,0x50
     be5:	mov    rsp,rbp
     be8:	pop    rbp
     be9:	ret
     bea:	jmp    bfe <botlish_fn_9+0x13f>
     bef:	mov    eax,0x2
     bf4:	jmp    bfe <botlish_fn_9+0x13f>
     bf9:	mov    eax,0x2
     bfe:	mov    rbx,QWORD PTR [rsp+0x30]
     c03:	mov    r12,QWORD PTR [rsp+0x38]
     c08:	mov    r13,QWORD PTR [rsp+0x40]
     c0d:	mov    r14,QWORD PTR [rsp+0x48]
     c12:	add    rsp,0x50
     c16:	mov    rsp,rbp
     c19:	pop    rbp
     c1a:	ret

0000000000000c1b <botlish_entry_9: web::emailish?<str>>:
     c1b:	push   rbp
     c1c:	mov    rbp,rsp
     c1f:	mov    rsi,QWORD PTR [rdx]
     c22:	call   c27 <botlish_entry_9+0xc>
			c23: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
     c27:	mov    rsp,rbp
     c2a:	pop    rbp
     c2b:	ret

0000000000000c2c <botlish_fn_10: char_at<generic>>:
     c2c:	push   rbp
     c2d:	mov    rbp,rsp
     c30:	sub    rsp,0x50
     c34:	mov    QWORD PTR [rsp+0x20],rbx
     c39:	mov    QWORD PTR [rsp+0x28],r12
     c3e:	mov    QWORD PTR [rsp+0x30],r13
     c43:	mov    QWORD PTR [rsp+0x38],r14
     c48:	mov    QWORD PTR [rsp+0x40],r15
     c4d:	mov    r12,rdi
     c50:	mov    r15,rcx
     c53:	mov    QWORD PTR [rsp],rsi
     c57:	mov    QWORD PTR [rsp+0x8],rdx
     c5c:	mov    r13,rdx
     c5f:	mov    QWORD PTR [rsp+0x10],0x3
     c68:	test   rsi,0x1
     c6f:	jne    c7d <botlish_fn_10+0x51>
     c75:	mov    rbx,rsi
     c78:	jmp    c9d <botlish_fn_10+0x71>
     c7d:	mov    rax,rsi
     c80:	add    rax,0x2
     c84:	mov    rbx,rsi
     c87:	seto   cl
     c8a:	test   cl,cl
     c8c:	jne    c9d <botlish_fn_10+0x71>
     c92:	mov    rdi,r12
     c95:	mov    r14,rax
     c98:	jmp    cb3 <botlish_fn_10+0x87>
     c9d:	mov    edx,0x3
     ca2:	mov    rsi,rbx
     ca5:	mov    rdi,r12
     ca8:	call   cad <botlish_fn_10+0x81>
			ca9: R_X86_64_PLT32	rt_int_add-0x4
     cad:	mov    r14,rax
     cb0:	mov    rdi,r12
     cb3:	mov    rcx,r14
     cb6:	mov    rdx,rbx
     cb9:	mov    rsi,r13
     cbc:	call   cc1 <botlish_fn_10+0x95>
			cbd: R_X86_64_PLT32	rt_str_region_check-0x4
     cc1:	test   rax,rax
     cc4:	jne    cef <botlish_fn_10+0xc3>
     cca:	xor    rax,rax
     ccd:	mov    rbx,QWORD PTR [rsp+0x20]
     cd2:	mov    r12,QWORD PTR [rsp+0x28]
     cd7:	mov    r13,QWORD PTR [rsp+0x30]
     cdc:	mov    r14,QWORD PTR [rsp+0x38]
     ce1:	mov    r15,QWORD PTR [rsp+0x40]
     ce6:	add    rsp,0x50
     cea:	mov    rsp,rbp
     ced:	pop    rbp
     cee:	ret
     cef:	mov    rcx,r15
     cf2:	mov    QWORD PTR [rcx],rbx
     cf5:	mov    rax,r14
     cf8:	mov    QWORD PTR [rcx+0x8],rax
     cfc:	mov    rax,r13
     cff:	mov    rbx,QWORD PTR [rsp+0x20]
     d04:	mov    r12,QWORD PTR [rsp+0x28]
     d09:	mov    r13,QWORD PTR [rsp+0x30]
     d0e:	mov    r14,QWORD PTR [rsp+0x38]
     d13:	mov    r15,QWORD PTR [rsp+0x40]
     d18:	add    rsp,0x50
     d1c:	mov    rsp,rbp
     d1f:	pop    rbp
     d20:	ret

0000000000000d21 <botlish_entry_10: char_at<generic>>:
     d21:	push   rbp
     d22:	mov    rbp,rsp
     d25:	ud2

0000000000000d27 <botlish_fn_11: char_at<generic>>:
     d27:	push   rbp
     d28:	mov    rbp,rsp
     d2b:	sub    rsp,0x40
     d2f:	mov    QWORD PTR [rsp+0x20],rbx
     d34:	mov    QWORD PTR [rsp+0x28],r12
     d39:	mov    QWORD PTR [rsp+0x30],r13
     d3e:	mov    r12,rdi
     d41:	mov    QWORD PTR [rsp],rsi
     d45:	mov    QWORD PTR [rsp+0x8],rdx
     d4a:	mov    r13,rdx
     d4d:	mov    QWORD PTR [rsp+0x10],0x3
     d56:	test   rsi,0x1
     d5d:	jne    d6b <botlish_fn_11+0x44>
     d63:	mov    rbx,rsi
     d66:	jmp    d80 <botlish_fn_11+0x59>
     d6b:	mov    rcx,rsi
     d6e:	add    rcx,0x2
     d72:	mov    rbx,rsi
     d75:	seto   al
     d78:	test   al,al
     d7a:	je     d93 <botlish_fn_11+0x6c>
     d80:	mov    edx,0x3
     d85:	mov    rsi,rbx
     d88:	mov    rdi,r12
     d8b:	call   d90 <botlish_fn_11+0x69>
			d8c: R_X86_64_PLT32	rt_int_add-0x4
     d90:	mov    rcx,rax
     d93:	mov    QWORD PTR [rsp+0x10],rcx
     d98:	mov    rdx,rbx
     d9b:	mov    rsi,r13
     d9e:	mov    rdi,r12
     da1:	call   da6 <botlish_fn_11+0x7f>
			da2: R_X86_64_PLT32	rt_substr-0x4
     da6:	test   rax,rax
     da9:	jne    dca <botlish_fn_11+0xa3>
     daf:	xor    rax,rax
     db2:	mov    rbx,QWORD PTR [rsp+0x20]
     db7:	mov    r12,QWORD PTR [rsp+0x28]
     dbc:	mov    r13,QWORD PTR [rsp+0x30]
     dc1:	add    rsp,0x40
     dc5:	mov    rsp,rbp
     dc8:	pop    rbp
     dc9:	ret
     dca:	mov    rbx,QWORD PTR [rsp+0x20]
     dcf:	mov    r12,QWORD PTR [rsp+0x28]
     dd4:	mov    r13,QWORD PTR [rsp+0x30]
     dd9:	add    rsp,0x40
     ddd:	mov    rsp,rbp
     de0:	pop    rbp
     de1:	ret

0000000000000de2 <botlish_entry_11: char_at<generic>>:
     de2:	push   rbp
     de3:	mov    rbp,rsp
     de6:	mov    rsi,QWORD PTR [rdx]
     de9:	mov    rdx,QWORD PTR [rdx+0x8]
     ded:	call   df2 <botlish_entry_11+0x10>
			dee: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
     df2:	mov    rsp,rbp
     df5:	pop    rbp
     df6:	ret

0000000000000df7 <botlish_fn_12: local_char?<str>>:
     df7:	push   rbp
     df8:	mov    rbp,rsp
     dfb:	sub    rsp,0x10
     dff:	mov    QWORD PTR [rsp],rbx
     e03:	mov    QWORD PTR [rsp+0x8],r12
     e08:	lea    rax,[rsi+0x1]
     e0c:	cmp    rax,0x101
     e12:	jb     e20 <botlish_fn_12+0x29>
     e18:	mov    rbx,rdi
     e1b:	jmp    e38 <botlish_fn_12+0x41>
     e20:	lea    rax,[rsi+0x1]
     e24:	mov    r12,QWORD PTR [rdi+rax*8+0x648]
     e2c:	mov    rbx,rdi
     e2f:	test   r12,r12
     e32:	jne    e43 <botlish_fn_12+0x4c>
     e38:	mov    rdi,rbx
     e3b:	call   e40 <botlish_fn_12+0x49>
			e3c: R_X86_64_PLT32	rt_short_to_str-0x4
     e40:	mov    r12,rax
     e43:	mov    rsi,r12
     e46:	mov    rdi,rbx
     e49:	call   e4e <botlish_fn_12+0x57>
			e4a: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     e4e:	mov    rdx,r12
     e51:	test   rax,rax
     e54:	jne    e6f <botlish_fn_12+0x78>
     e5a:	xor    rax,rax
     e5d:	mov    rbx,QWORD PTR [rsp]
     e61:	mov    r12,QWORD PTR [rsp+0x8]
     e66:	add    rsp,0x10
     e6a:	mov    rsp,rbp
     e6d:	pop    rbp
     e6e:	ret
     e6f:	cmp    rax,0x6
     e73:	je     ea6 <botlish_fn_12+0xaf>
     e79:	mov    rdi,rbx
     e7c:	mov    rax,QWORD PTR [rdi+0x30]
     e80:	mov    rsi,QWORD PTR [rax]
     e83:	call   e88 <botlish_fn_12+0x91>
			e84: R_X86_64_PLT32	rt_set_contains-0x4
     e88:	cmp    rax,0x6
     e8c:	je     e9c <botlish_fn_12+0xa5>
     e92:	mov    eax,0x2
     e97:	jmp    eab <botlish_fn_12+0xb4>
     e9c:	mov    eax,0x6
     ea1:	jmp    eab <botlish_fn_12+0xb4>
     ea6:	mov    eax,0x6
     eab:	mov    rbx,QWORD PTR [rsp]
     eaf:	mov    r12,QWORD PTR [rsp+0x8]
     eb4:	add    rsp,0x10
     eb8:	mov    rsp,rbp
     ebb:	pop    rbp
     ebc:	ret

0000000000000ebd <botlish_entry_12: local_char?<str>>:
     ebd:	push   rbp
     ebe:	mov    rbp,rsp
     ec1:	sub    rsp,0x10
     ec5:	mov    QWORD PTR [rsp],r12
     ec9:	mov    r12,rdi
     ecc:	mov    rsi,QWORD PTR [rdx]
     ecf:	mov    r8,QWORD PTR [rip+0x0]        # ed6 <botlish_entry_12+0x19>
			ed2: R_X86_64_GOTPCREL	rt_str_to_short-0x4
     ed6:	call   r8
     ed9:	mov    rsi,rax
     edc:	mov    rdi,r12
     edf:	call   ee4 <botlish_entry_12+0x27>
			ee0: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     ee4:	mov    r12,QWORD PTR [rsp]
     ee8:	add    rsp,0x10
     eec:	mov    rsp,rbp
     eef:	pop    rbp
     ef0:	ret

0000000000000ef1 <botlish_fn_13: local_char?<generic>>:
     ef1:	push   rbp
     ef2:	mov    rbp,rsp
     ef5:	sub    rsp,0x10
     ef9:	mov    QWORD PTR [rsp],rbx
     efd:	mov    QWORD PTR [rsp+0x8],r12
     f02:	xor    r8d,r8d
     f05:	test   rsi,0x7
     f0c:	jne    f1c <botlish_fn_13+0x2b>
     f12:	movzx  rax,BYTE PTR [rsi]
     f16:	cmp    al,0x2
     f18:	sete   r8b
     f1c:	test   r8b,r8b
     f1f:	jne    f3f <botlish_fn_13+0x4e>
     f25:	mov    rax,QWORD PTR [rdi+0x10]
     f29:	mov    rcx,QWORD PTR [rax+0xd8]
     f30:	mov    edx,0x1
     f35:	call   f3a <botlish_fn_13+0x49>
			f36: R_X86_64_PLT32	rt_type_error-0x4
     f3a:	jmp    f53 <botlish_fn_13+0x62>
     f3f:	mov    rbx,rsi
     f42:	mov    r12,rdi
     f45:	call   f4a <botlish_fn_13+0x59>
			f46: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     f4a:	test   rax,rax
     f4d:	jne    f68 <botlish_fn_13+0x77>
     f53:	xor    rax,rax
     f56:	mov    rbx,QWORD PTR [rsp]
     f5a:	mov    r12,QWORD PTR [rsp+0x8]
     f5f:	add    rsp,0x10
     f63:	mov    rsp,rbp
     f66:	pop    rbp
     f67:	ret
     f68:	cmp    rax,0x6
     f6c:	je     fa2 <botlish_fn_13+0xb1>
     f72:	mov    rdi,r12
     f75:	mov    rax,QWORD PTR [rdi+0x30]
     f79:	mov    rsi,QWORD PTR [rax]
     f7c:	mov    rdx,rbx
     f7f:	call   f84 <botlish_fn_13+0x93>
			f80: R_X86_64_PLT32	rt_set_contains-0x4
     f84:	cmp    rax,0x6
     f88:	je     f98 <botlish_fn_13+0xa7>
     f8e:	mov    eax,0x2
     f93:	jmp    fa7 <botlish_fn_13+0xb6>
     f98:	mov    eax,0x6
     f9d:	jmp    fa7 <botlish_fn_13+0xb6>
     fa2:	mov    eax,0x6
     fa7:	mov    rbx,QWORD PTR [rsp]
     fab:	mov    r12,QWORD PTR [rsp+0x8]
     fb0:	add    rsp,0x10
     fb4:	mov    rsp,rbp
     fb7:	pop    rbp
     fb8:	ret

0000000000000fb9 <botlish_entry_13: local_char?<generic>>:
     fb9:	push   rbp
     fba:	mov    rbp,rsp
     fbd:	mov    rsi,QWORD PTR [rdx]
     fc0:	call   fc5 <botlish_entry_13+0xc>
			fc1: R_X86_64_PLT32	botlish_fn_13-0x4 ; local_char?<generic>
     fc5:	mov    rsp,rbp
     fc8:	pop    rbp
     fc9:	ret
     fca:	add    BYTE PTR [rax],al
     fcc:	add    BYTE PTR [rax],al
	...

0000000000000fd0 <botlish_fn_14: scan_while<any, block(e239)>>:
     fd0:	push   rbp
     fd1:	mov    rbp,rsp
     fd4:	sub    rsp,0x40
     fd8:	mov    QWORD PTR [rsp+0x20],rbx
     fdd:	mov    QWORD PTR [rsp+0x28],r12
     fe2:	mov    QWORD PTR [rsp+0x30],r13
     fe7:	mov    QWORD PTR [rsp+0x38],r14
     fec:	mov    rbx,rcx
     fef:	mov    r13,rdi
     ff2:	mov    QWORD PTR [rsp+0x18],0x0
     ffb:	mov    QWORD PTR [rsp],rcx
     fff:	mov    QWORD PTR [rsp+0x8],r8
    1004:	mov    r12,r8
    1007:	mov    QWORD PTR [rsp+0x10],rsi
    100c:	mov    rax,rsi
    100f:	mov    rcx,rbx
    1012:	mov    r14,rsi
    1015:	mov    rcx,rbx
    1018:	and    rax,rcx
    101b:	test   rax,0x1
    1021:	jne    104a <botlish_fn_14+0x7a>
    1027:	mov    rdx,rbx
    102a:	mov    rsi,r14
    102d:	mov    rdi,r13
    1030:	call   1035 <botlish_fn_14+0x65>
			1031: R_X86_64_PLT32	rt_int_cmp-0x4
    1035:	mov    ecx,0x2
    103a:	test   rax,rax
    103d:	cmovl  rcx,QWORD PTR [rip+0x11b]        # 1160 <botlish_fn_14+0x190>
    1045:	jmp    1060 <botlish_fn_14+0x90>
    104a:	mov    ecx,0x2
    104f:	mov    rax,r14
    1052:	mov    rdx,rbx
    1055:	cmp    rax,rdx
    1058:	cmovl  rcx,QWORD PTR [rip+0x100]        # 1160 <botlish_fn_14+0x190>
    1060:	cmp    rcx,0x6
    1064:	je     108a <botlish_fn_14+0xba>
    106a:	mov    rax,rbx
    106d:	mov    rbx,QWORD PTR [rsp+0x20]
    1072:	mov    r12,QWORD PTR [rsp+0x28]
    1077:	mov    r13,QWORD PTR [rsp+0x30]
    107c:	mov    r14,QWORD PTR [rsp+0x38]
    1081:	add    rsp,0x40
    1085:	mov    rsp,rbp
    1088:	pop    rbp
    1089:	ret
    108a:	mov    rdx,r12
    108d:	mov    rsi,r14
    1090:	mov    rdi,r13
    1093:	call   1098 <botlish_fn_14+0xc8>
			1094: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    1098:	test   rax,rax
    109b:	je     10c4 <botlish_fn_14+0xf4>
    10a1:	mov    rcx,QWORD PTR [rax+0x8]
    10a5:	mov    esi,DWORD PTR [rax+0x14]
    10a8:	test   rcx,rcx
    10ab:	cmove  rsi,QWORD PTR [rip+0xb5]        # 1168 <botlish_fn_14+0x198>
    10b3:	mov    rdi,r13
    10b6:	call   10bb <botlish_fn_14+0xeb>
			10b7: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
    10bb:	test   rax,rax
    10be:	jne    10e4 <botlish_fn_14+0x114>
    10c4:	xor    rax,rax
    10c7:	mov    rbx,QWORD PTR [rsp+0x20]
    10cc:	mov    r12,QWORD PTR [rsp+0x28]
    10d1:	mov    r13,QWORD PTR [rsp+0x30]
    10d6:	mov    r14,QWORD PTR [rsp+0x38]
    10db:	add    rsp,0x40
    10df:	mov    rsp,rbp
    10e2:	pop    rbp
    10e3:	ret
    10e4:	cmp    rax,0x6
    10e8:	je     110e <botlish_fn_14+0x13e>
    10ee:	mov    rax,r14
    10f1:	mov    rbx,QWORD PTR [rsp+0x20]
    10f6:	mov    r12,QWORD PTR [rsp+0x28]
    10fb:	mov    r13,QWORD PTR [rsp+0x30]
    1100:	mov    r14,QWORD PTR [rsp+0x38]
    1105:	add    rsp,0x40
    1109:	mov    rsp,rbp
    110c:	pop    rbp
    110d:	ret
    110e:	mov    QWORD PTR [rsp+0x18],0x3
    1117:	mov    rax,r14
    111a:	test   rax,0x1
    1120:	je     113b <botlish_fn_14+0x16b>
    1126:	mov    rcx,r14
    1129:	mov    rax,rcx
    112c:	add    rax,0x2
    1130:	seto   cl
    1133:	test   cl,cl
    1135:	je     114b <botlish_fn_14+0x17b>
    113b:	mov    edx,0x3
    1140:	mov    rsi,r14
    1143:	mov    rdi,r13
    1146:	call   114b <botlish_fn_14+0x17b>
			1147: R_X86_64_PLT32	rt_int_add-0x4
    114b:	mov    QWORD PTR [rsp+0x10],rax
    1150:	mov    rcx,rbx
    1153:	mov    r14,rax
    1156:	jmp    1015 <botlish_fn_14+0x45>
    115b:	add    BYTE PTR [rax],al
    115d:	add    BYTE PTR [rax],al
    115f:	add    BYTE PTR [rsi],al
    1161:	add    BYTE PTR [rax],al
    1163:	add    BYTE PTR [rax],al
    1165:	add    BYTE PTR [rax],al
    1167:	add    bh,bh
    1169:	(bad)
    116a:	(bad)
    116b:	(bad)
    116c:	(bad)
    116d:	(bad)
    116e:	(bad)
    116f:	.byte 0xff

0000000000001170 <botlish_entry_14: scan_while<any, block(e239)>>:
    1170:	push   rbp
    1171:	mov    rbp,rsp
    1174:	mov    rsi,QWORD PTR [rdx]
    1177:	mov    r9,QWORD PTR [rdx+0x8]
    117b:	mov    rcx,QWORD PTR [rdx+0x10]
    117f:	mov    r8,QWORD PTR [rdx+0x18]
    1183:	mov    rdx,r9
    1186:	call   118b <botlish_entry_14+0x1b>
			1187: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<any, block(e239)>
    118b:	mov    rsp,rbp
    118e:	pop    rbp
    118f:	ret

0000000000001190 <botlish_fn_15: scan_while<any, native(is_tcl_alpha)>>:
    1190:	push   rbp
    1191:	mov    rbp,rsp
    1194:	sub    rsp,0x50
    1198:	mov    QWORD PTR [rsp+0x30],rbx
    119d:	mov    QWORD PTR [rsp+0x38],r12
    11a2:	mov    QWORD PTR [rsp+0x40],r13
    11a7:	mov    QWORD PTR [rsp+0x48],r14
    11ac:	mov    rbx,rcx
    11af:	mov    r13,rdi
    11b2:	mov    QWORD PTR [rsp+0x18],0x0
    11bb:	mov    QWORD PTR [rsp],rcx
    11bf:	mov    QWORD PTR [rsp+0x8],r8
    11c4:	mov    r12,r8
    11c7:	mov    QWORD PTR [rsp+0x10],rsi
    11cc:	mov    rax,rsi
    11cf:	mov    rcx,rbx
    11d2:	mov    r14,rsi
    11d5:	mov    rcx,rbx
    11d8:	and    rax,rcx
    11db:	test   rax,0x1
    11e1:	jne    120a <botlish_fn_15+0x7a>
    11e7:	mov    rdx,rbx
    11ea:	mov    rsi,r14
    11ed:	mov    rdi,r13
    11f0:	call   11f5 <botlish_fn_15+0x65>
			11f1: R_X86_64_PLT32	rt_int_cmp-0x4
    11f5:	mov    ecx,0x2
    11fa:	test   rax,rax
    11fd:	cmovl  rcx,QWORD PTR [rip+0x11b]        # 1320 <botlish_fn_15+0x190>
    1205:	jmp    1220 <botlish_fn_15+0x90>
    120a:	mov    ecx,0x2
    120f:	mov    rax,r14
    1212:	mov    rdx,rbx
    1215:	cmp    rax,rdx
    1218:	cmovl  rcx,QWORD PTR [rip+0x100]        # 1320 <botlish_fn_15+0x190>
    1220:	cmp    rcx,0x6
    1224:	je     124a <botlish_fn_15+0xba>
    122a:	mov    rax,rbx
    122d:	mov    rbx,QWORD PTR [rsp+0x30]
    1232:	mov    r12,QWORD PTR [rsp+0x38]
    1237:	mov    r13,QWORD PTR [rsp+0x40]
    123c:	mov    r14,QWORD PTR [rsp+0x48]
    1241:	add    rsp,0x50
    1245:	mov    rsp,rbp
    1248:	pop    rbp
    1249:	ret
    124a:	lea    rcx,[rsp+0x20]
    124f:	mov    rdx,r12
    1252:	mov    rsi,r14
    1255:	mov    rdi,r13
    1258:	call   125d <botlish_fn_15+0xcd>
			1259: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    125d:	test   rax,rax
    1260:	mov    rsi,rax
    1263:	je     1284 <botlish_fn_15+0xf4>
    1269:	mov    rdx,QWORD PTR [rsp+0x20]
    126e:	mov    rcx,QWORD PTR [rsp+0x28]
    1273:	mov    rdi,r13
    1276:	call   127b <botlish_fn_15+0xeb>
			1277: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    127b:	test   rax,rax
    127e:	jne    12a4 <botlish_fn_15+0x114>
    1284:	xor    rax,rax
    1287:	mov    rbx,QWORD PTR [rsp+0x30]
    128c:	mov    r12,QWORD PTR [rsp+0x38]
    1291:	mov    r13,QWORD PTR [rsp+0x40]
    1296:	mov    r14,QWORD PTR [rsp+0x48]
    129b:	add    rsp,0x50
    129f:	mov    rsp,rbp
    12a2:	pop    rbp
    12a3:	ret
    12a4:	cmp    rax,0x6
    12a8:	je     12ce <botlish_fn_15+0x13e>
    12ae:	mov    rax,r14
    12b1:	mov    rbx,QWORD PTR [rsp+0x30]
    12b6:	mov    r12,QWORD PTR [rsp+0x38]
    12bb:	mov    r13,QWORD PTR [rsp+0x40]
    12c0:	mov    r14,QWORD PTR [rsp+0x48]
    12c5:	add    rsp,0x50
    12c9:	mov    rsp,rbp
    12cc:	pop    rbp
    12cd:	ret
    12ce:	mov    QWORD PTR [rsp+0x18],0x3
    12d7:	mov    rax,r14
    12da:	test   rax,0x1
    12e0:	je     12fb <botlish_fn_15+0x16b>
    12e6:	mov    rcx,r14
    12e9:	mov    rax,rcx
    12ec:	add    rax,0x2
    12f0:	seto   cl
    12f3:	test   cl,cl
    12f5:	je     130b <botlish_fn_15+0x17b>
    12fb:	mov    edx,0x3
    1300:	mov    rsi,r14
    1303:	mov    rdi,r13
    1306:	call   130b <botlish_fn_15+0x17b>
			1307: R_X86_64_PLT32	rt_int_add-0x4
    130b:	mov    QWORD PTR [rsp+0x10],rax
    1310:	mov    rcx,rbx
    1313:	mov    r14,rax
    1316:	jmp    11d5 <botlish_fn_15+0x45>
    131b:	add    BYTE PTR [rax],al
    131d:	add    BYTE PTR [rax],al
    131f:	add    BYTE PTR [rsi],al
    1321:	add    BYTE PTR [rax],al
    1323:	add    BYTE PTR [rax],al
    1325:	add    BYTE PTR [rax],al
	...

0000000000001328 <botlish_entry_15: scan_while<any, native(is_tcl_alpha)>>:
    1328:	push   rbp
    1329:	mov    rbp,rsp
    132c:	mov    rsi,QWORD PTR [rdx]
    132f:	mov    r9,QWORD PTR [rdx+0x8]
    1333:	mov    rcx,QWORD PTR [rdx+0x10]
    1337:	mov    r8,QWORD PTR [rdx+0x18]
    133b:	mov    rdx,r9
    133e:	call   1343 <botlish_entry_15+0x1b>
			133f: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<any, native(is_tcl_alpha)>
    1343:	mov    rsp,rbp
    1346:	pop    rbp
    1347:	ret

0000000000001348 <botlish_fn_16: tld?<generic>>:
    1348:	push   rbp
    1349:	mov    rbp,rsp
    134c:	sub    rsp,0x40
    1350:	mov    QWORD PTR [rsp+0x20],rbx
    1355:	mov    QWORD PTR [rsp+0x28],r12
    135a:	mov    QWORD PTR [rsp+0x30],r13
    135f:	mov    QWORD PTR [rsp+0x38],r14
    1364:	mov    QWORD PTR [rsp],rsi
    1368:	mov    r8,rsi
    136b:	mov    QWORD PTR [rsp+0x8],rdx
    1370:	mov    r14,rdx
    1373:	mov    QWORD PTR [rsp+0x10],rcx
    1378:	mov    rax,QWORD PTR [rdi+0x10]
    137c:	mov    r12,rdi
    137f:	mov    rdx,QWORD PTR [rax+0xe0]
    1386:	mov    QWORD PTR [rsp+0x18],rdx
    138b:	mov    rbx,r8
    138e:	mov    r8,rcx
    1391:	mov    rcx,r14
    1394:	mov    rsi,rbx
    1397:	call   139c <botlish_fn_16+0x54>
			1398: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<any, native(is_tcl_alpha)>
    139c:	mov    rcx,rax
    139f:	mov    r13,rax
    13a2:	test   rax,rcx
    13a5:	jne    13cb <botlish_fn_16+0x83>
    13ab:	xor    rax,rax
    13ae:	mov    rbx,QWORD PTR [rsp+0x20]
    13b3:	mov    r12,QWORD PTR [rsp+0x28]
    13b8:	mov    r13,QWORD PTR [rsp+0x30]
    13bd:	mov    r14,QWORD PTR [rsp+0x38]
    13c2:	add    rsp,0x40
    13c6:	mov    rsp,rbp
    13c9:	pop    rbp
    13ca:	ret
    13cb:	mov    rax,r13
    13ce:	mov    QWORD PTR [rsp+0x8],rax
    13d3:	mov    rdx,r14
    13d6:	and    rax,rdx
    13d9:	test   rax,0x1
    13df:	jne    1408 <botlish_fn_16+0xc0>
    13e5:	mov    rsi,r13
    13e8:	mov    rdi,r12
    13eb:	call   13f0 <botlish_fn_16+0xa8>
			13ec: R_X86_64_PLT32	rt_int_cmp-0x4
    13f0:	mov    ecx,0x2
    13f5:	test   rax,rax
    13f8:	cmove  rcx,QWORD PTR [rip+0xe0]        # 14e0 <botlish_fn_16+0x198>
    1400:	mov    rax,r13
    1403:	jmp    141b <botlish_fn_16+0xd3>
    1408:	mov    ecx,0x2
    140d:	mov    rax,r13
    1410:	cmp    rax,rdx
    1413:	cmove  rcx,QWORD PTR [rip+0xc5]        # 14e0 <botlish_fn_16+0x198>
    141b:	cmp    rcx,0x6
    141f:	je     1432 <botlish_fn_16+0xea>
    1425:	mov    ecx,0x2
    142a:	mov    rax,rcx
    142d:	jmp    14bf <botlish_fn_16+0x177>
    1432:	mov    rcx,rax
    1435:	and    rcx,rbx
    1438:	test   rcx,0x1
    143f:	jne    1450 <botlish_fn_16+0x108>
    1445:	mov    rdx,rbx
    1448:	mov    rsi,rax
    144b:	jmp    1471 <botlish_fn_16+0x129>
    1450:	mov    rcx,rax
    1453:	sub    rcx,rbx
    1456:	mov    r8,rbx
    1459:	mov    r13,rax
    145c:	seto   al
    145f:	lea    rsi,[rcx+0x1]
    1463:	test   al,al
    1465:	je     147c <botlish_fn_16+0x134>
    146b:	mov    rdx,r8
    146e:	mov    rsi,r13
    1471:	mov    rdi,r12
    1474:	call   1479 <botlish_fn_16+0x131>
			1475: R_X86_64_PLT32	rt_int_sub-0x4
    1479:	mov    rsi,rax
    147c:	test   rsi,0x1
    1483:	jne    14ae <botlish_fn_16+0x166>
    1489:	mov    edx,0x5
    148e:	mov    rdi,r12
    1491:	call   1496 <botlish_fn_16+0x14e>
			1492: R_X86_64_PLT32	rt_int_cmp-0x4
    1496:	mov    ecx,0x2
    149b:	test   rax,rax
    149e:	mov    rax,rcx
    14a1:	cmovge rax,QWORD PTR [rip+0x37]        # 14e0 <botlish_fn_16+0x198>
    14a9:	jmp    14bf <botlish_fn_16+0x177>
    14ae:	mov    eax,0x2
    14b3:	cmp    rsi,0x5
    14b7:	cmovge rax,QWORD PTR [rip+0x21]        # 14e0 <botlish_fn_16+0x198>
    14bf:	mov    rbx,QWORD PTR [rsp+0x20]
    14c4:	mov    r12,QWORD PTR [rsp+0x28]
    14c9:	mov    r13,QWORD PTR [rsp+0x30]
    14ce:	mov    r14,QWORD PTR [rsp+0x38]
    14d3:	add    rsp,0x40
    14d7:	mov    rsp,rbp
    14da:	pop    rbp
    14db:	ret
    14dc:	add    BYTE PTR [rax],al
    14de:	add    BYTE PTR [rax],al
    14e0:	(bad)
    14e1:	add    BYTE PTR [rax],al
    14e3:	add    BYTE PTR [rax],al
    14e5:	add    BYTE PTR [rax],al
	...

00000000000014e8 <botlish_entry_16: tld?<generic>>:
    14e8:	push   rbp
    14e9:	mov    rbp,rsp
    14ec:	mov    rsi,QWORD PTR [rdx]
    14ef:	mov    r8,QWORD PTR [rdx+0x8]
    14f3:	mov    rcx,QWORD PTR [rdx+0x10]
    14f7:	mov    rdx,r8
    14fa:	call   14ff <botlish_entry_16+0x17>
			14fb: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<generic>
    14ff:	mov    rsp,rbp
    1502:	pop    rbp
    1503:	ret
    1504:	add    BYTE PTR [rax],al
	...

0000000000001508 <botlish_fn_17: domain?<generic>>:
    1508:	push   rbp
    1509:	mov    rbp,rsp
    150c:	sub    rsp,0xa0
    1513:	mov    QWORD PTR [rsp+0x70],rbx
    1518:	mov    QWORD PTR [rsp+0x78],r12
    151d:	mov    QWORD PTR [rsp+0x80],r13
    1525:	mov    QWORD PTR [rsp+0x88],r14
    152d:	mov    QWORD PTR [rsp+0x90],r15
    1535:	mov    r8,rdi
    1538:	mov    QWORD PTR [rsp+0x20],0x0
    1541:	mov    QWORD PTR [rsp],rsi
    1545:	mov    QWORD PTR [rsp+0x8],rdx
    154a:	mov    QWORD PTR [rsp+0x10],rcx
    154f:	mov    r15,rcx
    1552:	mov    QWORD PTR [rsp+0x18],rsi
    1557:	mov    r12,rsi
    155a:	mov    r14,rdx
    155d:	mov    rdi,rsi
    1560:	and    rdi,r14
    1563:	mov    QWORD PTR [rsp+0x58],rsi
    1568:	test   rdi,0x1
    156f:	jne    159d <botlish_fn_17+0x95>
    1575:	mov    rbx,r8
    1578:	mov    rdx,r14
    157b:	mov    rsi,QWORD PTR [rsp+0x58]
    1580:	mov    rdi,rbx
    1583:	call   1588 <botlish_fn_17+0x80>
			1584: R_X86_64_PLT32	rt_int_cmp-0x4
    1588:	mov    ecx,0x2
    158d:	test   rax,rax
    1590:	cmovl  rcx,QWORD PTR [rip+0x358]        # 18f0 <botlish_fn_17+0x3e8>
    1598:	jmp    15b5 <botlish_fn_17+0xad>
    159d:	mov    rbx,r8
    15a0:	mov    ecx,0x2
    15a5:	mov    rsi,QWORD PTR [rsp+0x58]
    15aa:	cmp    rsi,r14
    15ad:	cmovl  rcx,QWORD PTR [rip+0x33b]        # 18f0 <botlish_fn_17+0x3e8>
    15b5:	cmp    rcx,0x6
    15b9:	je     15f2 <botlish_fn_17+0xea>
    15bf:	mov    eax,0x2
    15c4:	mov    rbx,QWORD PTR [rsp+0x70]
    15c9:	mov    r12,QWORD PTR [rsp+0x78]
    15ce:	mov    r13,QWORD PTR [rsp+0x80]
    15d6:	mov    r14,QWORD PTR [rsp+0x88]
    15de:	mov    r15,QWORD PTR [rsp+0x90]
    15e6:	add    rsp,0xa0
    15ed:	mov    rsp,rbp
    15f0:	pop    rbp
    15f1:	ret
    15f2:	lea    rcx,[rsp+0x28]
    15f7:	mov    rdx,r15
    15fa:	mov    rsi,QWORD PTR [rsp+0x58]
    15ff:	mov    rdi,rbx
    1602:	call   1607 <botlish_fn_17+0xff>
			1603: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    1607:	test   rax,rax
    160a:	mov    rsi,rax
    160d:	je     17b4 <botlish_fn_17+0x2ac>
    1613:	mov    rdx,QWORD PTR [rsp+0x28]
    1618:	mov    rcx,QWORD PTR [rsp+0x30]
    161d:	mov    rax,QWORD PTR [rbx+0x10]
    1621:	mov    r8,QWORD PTR [rax]
    1624:	mov    rdi,rbx
    1627:	call   162c <botlish_fn_17+0x124>
			1628: R_X86_64_PLT32	rt_str_region_eq-0x4
    162c:	cmp    rax,0x6
    1630:	je     1721 <botlish_fn_17+0x219>
    1636:	lea    rcx,[rsp+0x48]
    163b:	mov    rdx,r15
    163e:	mov    rsi,QWORD PTR [rsp+0x58]
    1643:	mov    rdi,rbx
    1646:	call   164b <botlish_fn_17+0x143>
			1647: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    164b:	test   rax,rax
    164e:	mov    r13,rax
    1651:	je     17b4 <botlish_fn_17+0x2ac>
    1657:	mov    rdx,QWORD PTR [rsp+0x48]
    165c:	mov    QWORD PTR [rsp+0x68],rdx
    1661:	mov    rcx,QWORD PTR [rsp+0x50]
    1666:	mov    QWORD PTR [rsp+0x60],rcx
    166b:	mov    rsi,r13
    166e:	mov    rdi,rbx
    1671:	call   1676 <botlish_fn_17+0x16e>
			1672: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1676:	test   rax,rax
    1679:	je     17b4 <botlish_fn_17+0x2ac>
    167f:	cmp    rax,0x6
    1683:	je     16c4 <botlish_fn_17+0x1bc>
    1689:	mov    rax,QWORD PTR [rbx+0x10]
    168d:	mov    r8,QWORD PTR [rax+0x20]
    1691:	mov    rcx,QWORD PTR [rsp+0x60]
    1696:	mov    rdx,QWORD PTR [rsp+0x68]
    169b:	mov    rsi,r13
    169e:	mov    rdi,rbx
    16a1:	call   16a6 <botlish_fn_17+0x19e>
			16a2: R_X86_64_PLT32	rt_str_region_eq-0x4
    16a6:	cmp    rax,0x6
    16aa:	je     16ba <botlish_fn_17+0x1b2>
    16b0:	mov    ecx,0x2
    16b5:	jmp    16c9 <botlish_fn_17+0x1c1>
    16ba:	mov    ecx,0x6
    16bf:	jmp    16c9 <botlish_fn_17+0x1c1>
    16c4:	mov    ecx,0x6
    16c9:	cmp    rcx,0x6
    16cd:	je     16de <botlish_fn_17+0x1d6>
    16d3:	mov    r9d,0x6
    16d9:	jmp    16e4 <botlish_fn_17+0x1dc>
    16de:	mov    r9d,0x2
    16e4:	cmp    r9,0x6
    16e8:	jne    17ef <botlish_fn_17+0x2e7>
    16ee:	mov    eax,0x2
    16f3:	mov    rbx,QWORD PTR [rsp+0x70]
    16f8:	mov    r12,QWORD PTR [rsp+0x78]
    16fd:	mov    r13,QWORD PTR [rsp+0x80]
    1705:	mov    r14,QWORD PTR [rsp+0x88]
    170d:	mov    r15,QWORD PTR [rsp+0x90]
    1715:	add    rsp,0xa0
    171c:	mov    rsp,rbp
    171f:	pop    rbp
    1720:	ret
    1721:	mov    rsi,QWORD PTR [rsp+0x58]
    1726:	mov    r13,rsi
    1729:	sar    r13,1
    172c:	mov    rax,r12
    172f:	sar    rax,1
    1732:	cmp    r13,rax
    1735:	je     18bc <botlish_fn_17+0x3b4>
    173b:	mov    rsi,r13
    173e:	sub    rsi,0x1
    1742:	shl    rsi,1
    1745:	or     rsi,0x1
    1749:	mov    QWORD PTR [rsp+0x20],rsi
    174e:	lea    rcx,[rsp+0x38]
    1753:	mov    rdx,r15
    1756:	mov    rdi,rbx
    1759:	call   175e <botlish_fn_17+0x256>
			175a: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    175e:	test   rax,rax
    1761:	mov    rsi,rax
    1764:	je     17b4 <botlish_fn_17+0x2ac>
    176a:	mov    rdx,QWORD PTR [rsp+0x38]
    176f:	mov    rcx,QWORD PTR [rsp+0x40]
    1774:	mov    rax,QWORD PTR [rbx+0x10]
    1778:	mov    r8,QWORD PTR [rax]
    177b:	mov    rdi,rbx
    177e:	call   1783 <botlish_fn_17+0x27b>
			177f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1783:	cmp    rax,0x6
    1787:	je     1889 <botlish_fn_17+0x381>
    178d:	lea    rsi,[r13+0x1]
    1791:	shl    rsi,1
    1794:	or     rsi,0x1
    1798:	mov    QWORD PTR [rsp+0x20],rsi
    179d:	mov    rcx,r15
    17a0:	mov    rdx,r14
    17a3:	mov    rdi,rbx
    17a6:	call   17ab <botlish_fn_17+0x2a3>
			17a7: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<generic>
    17ab:	test   rax,rax
    17ae:	jne    17e5 <botlish_fn_17+0x2dd>
    17b4:	xor    rax,rax
    17b7:	mov    rbx,QWORD PTR [rsp+0x70]
    17bc:	mov    r12,QWORD PTR [rsp+0x78]
    17c1:	mov    r13,QWORD PTR [rsp+0x80]
    17c9:	mov    r14,QWORD PTR [rsp+0x88]
    17d1:	mov    r15,QWORD PTR [rsp+0x90]
    17d9:	add    rsp,0xa0
    17e0:	mov    rsp,rbp
    17e3:	pop    rbp
    17e4:	ret
    17e5:	cmp    rax,0x6
    17e9:	je     1856 <botlish_fn_17+0x34e>
    17ef:	mov    QWORD PTR [rsp+0x20],0x3
    17f8:	mov    rsi,QWORD PTR [rsp+0x58]
    17fd:	test   rsi,0x1
    1804:	je     182a <botlish_fn_17+0x322>
    180a:	mov    rsi,QWORD PTR [rsp+0x58]
    180f:	add    rsi,0x2
    1813:	seto   dil
    1817:	test   dil,dil
    181a:	jne    182a <botlish_fn_17+0x322>
    1820:	mov    QWORD PTR [rsp+0x58],rsi
    1825:	jmp    1844 <botlish_fn_17+0x33c>
    182a:	mov    edx,0x3
    182f:	mov    rsi,QWORD PTR [rsp+0x58]
    1834:	mov    rdi,rbx
    1837:	call   183c <botlish_fn_17+0x334>
			1838: R_X86_64_PLT32	rt_int_add-0x4
    183c:	mov    rsi,rax
    183f:	mov    QWORD PTR [rsp+0x58],rax
    1844:	mov    QWORD PTR [rsp+0x18],rsi
    1849:	mov    rsi,QWORD PTR [rsp+0x58]
    184e:	mov    r8,rbx
    1851:	jmp    155d <botlish_fn_17+0x55>
    1856:	mov    eax,0x6
    185b:	mov    rbx,QWORD PTR [rsp+0x70]
    1860:	mov    r12,QWORD PTR [rsp+0x78]
    1865:	mov    r13,QWORD PTR [rsp+0x80]
    186d:	mov    r14,QWORD PTR [rsp+0x88]
    1875:	mov    r15,QWORD PTR [rsp+0x90]
    187d:	add    rsp,0xa0
    1884:	mov    rsp,rbp
    1887:	pop    rbp
    1888:	ret
    1889:	mov    eax,0x2
    188e:	mov    rbx,QWORD PTR [rsp+0x70]
    1893:	mov    r12,QWORD PTR [rsp+0x78]
    1898:	mov    r13,QWORD PTR [rsp+0x80]
    18a0:	mov    r14,QWORD PTR [rsp+0x88]
    18a8:	mov    r15,QWORD PTR [rsp+0x90]
    18b0:	add    rsp,0xa0
    18b7:	mov    rsp,rbp
    18ba:	pop    rbp
    18bb:	ret
    18bc:	mov    eax,0x2
    18c1:	mov    rbx,QWORD PTR [rsp+0x70]
    18c6:	mov    r12,QWORD PTR [rsp+0x78]
    18cb:	mov    r13,QWORD PTR [rsp+0x80]
    18d3:	mov    r14,QWORD PTR [rsp+0x88]
    18db:	mov    r15,QWORD PTR [rsp+0x90]
    18e3:	add    rsp,0xa0
    18ea:	mov    rsp,rbp
    18ed:	pop    rbp
    18ee:	ret
    18ef:	add    BYTE PTR [rsi],al
    18f1:	add    BYTE PTR [rax],al
    18f3:	add    BYTE PTR [rax],al
    18f5:	add    BYTE PTR [rax],al
	...

00000000000018f8 <botlish_entry_17: domain?<generic>>:
    18f8:	push   rbp
    18f9:	mov    rbp,rsp
    18fc:	mov    rsi,QWORD PTR [rdx]
    18ff:	mov    r8,QWORD PTR [rdx+0x8]
    1903:	mov    rcx,QWORD PTR [rdx+0x10]
    1907:	mov    rdx,r8
    190a:	call   190f <botlish_entry_17+0x17>
			190b: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<generic>
    190f:	mov    rsp,rbp
    1912:	pop    rbp
    1913:	ret

0000000000001914 <botlish_fn_18: web::is_unreserved<int>>:
    1914:	push   rbp
    1915:	mov    rbp,rsp
    1918:	sub    rsp,0x10
    191c:	mov    QWORD PTR [rsp],rbx
    1920:	mov    QWORD PTR [rsp+0x8],r14
    1925:	mov    r14,rsi
    1928:	mov    rsi,r14
    192b:	sar    rsi,1
    192e:	mov    rbx,rdi
    1931:	call   1936 <botlish_fn_18+0x22>
			1932: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
    1936:	cmp    rax,0x6
    193a:	je     1971 <botlish_fn_18+0x5d>
    1940:	mov    rax,QWORD PTR [rbx+0x30]
    1944:	mov    rsi,QWORD PTR [rax+0x10]
    1948:	mov    rdx,r14
    194b:	mov    rdi,rbx
    194e:	call   1953 <botlish_fn_18+0x3f>
			194f: R_X86_64_PLT32	rt_set_contains-0x4
    1953:	cmp    rax,0x6
    1957:	je     1967 <botlish_fn_18+0x53>
    195d:	mov    eax,0x2
    1962:	jmp    1976 <botlish_fn_18+0x62>
    1967:	mov    eax,0x6
    196c:	jmp    1976 <botlish_fn_18+0x62>
    1971:	mov    eax,0x6
    1976:	mov    rbx,QWORD PTR [rsp]
    197a:	mov    r14,QWORD PTR [rsp+0x8]
    197f:	add    rsp,0x10
    1983:	mov    rsp,rbp
    1986:	pop    rbp
    1987:	ret

0000000000001988 <botlish_entry_18: web::is_unreserved<int>>:
    1988:	push   rbp
    1989:	mov    rbp,rsp
    198c:	mov    rsi,QWORD PTR [rdx]
    198f:	call   1994 <botlish_entry_18+0xc>
			1990: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1994:	mov    rsp,rbp
    1997:	pop    rbp
    1998:	ret

0000000000001999 <botlish_fn_19: web::uri_escape_text<str>>:
    1999:	push   rbp
    199a:	mov    rbp,rsp
    199d:	sub    rsp,0x20
    19a1:	mov    QWORD PTR [rsp],rsi
    19a5:	mov    edx,0x1
    19aa:	mov    QWORD PTR [rsp+0x8],0x1
    19b3:	mov    r11,QWORD PTR [rdi+0x10]
    19b7:	mov    rcx,QWORD PTR [r11+0xe8]
    19be:	mov    QWORD PTR [rsp+0x10],rcx
    19c3:	call   19c8 <botlish_fn_19+0x2f>
			19c4: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    19c8:	test   rax,rax
    19cb:	jne    19dd <botlish_fn_19+0x44>
    19d1:	xor    rax,rax
    19d4:	add    rsp,0x20
    19d8:	mov    rsp,rbp
    19db:	pop    rbp
    19dc:	ret
    19dd:	add    rsp,0x20
    19e1:	mov    rsp,rbp
    19e4:	pop    rbp
    19e5:	ret

00000000000019e6 <botlish_entry_19: web::uri_escape_text<str>>:
    19e6:	push   rbp
    19e7:	mov    rbp,rsp
    19ea:	mov    rsi,QWORD PTR [rdx]
    19ed:	call   19f2 <botlish_entry_19+0xc>
			19ee: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_escape_text<str>
    19f2:	mov    rsp,rbp
    19f5:	pop    rbp
    19f6:	ret

00000000000019f7 <botlish_fn_20: high_nibble<int>>:
    19f7:	push   rbp
    19f8:	mov    rbp,rsp
    19fb:	sub    rsp,0x10
    19ff:	mov    QWORD PTR [rsp],rsi
    1a03:	mov    QWORD PTR [rsp+0x8],0x1e1
    1a0c:	test   rsi,0x1
    1a13:	jne    1a28 <botlish_fn_20+0x31>
    1a19:	mov    edx,0x1e1
    1a1e:	call   1a23 <botlish_fn_20+0x2c>
			1a1f: R_X86_64_PLT32	rt_int_and-0x4
    1a23:	jmp    1a32 <botlish_fn_20+0x3b>
    1a28:	and    rsi,0x1e1
    1a2f:	mov    rax,rsi
    1a32:	sar    rax,0x5
    1a36:	shl    rax,1
    1a39:	or     rax,0x1
    1a3d:	add    rsp,0x10
    1a41:	mov    rsp,rbp
    1a44:	pop    rbp
    1a45:	ret

0000000000001a46 <botlish_entry_20: high_nibble<int>>:
    1a46:	push   rbp
    1a47:	mov    rbp,rsp
    1a4a:	mov    rsi,QWORD PTR [rdx]
    1a4d:	call   1a52 <botlish_entry_20+0xc>
			1a4e: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    1a52:	mov    rsp,rbp
    1a55:	pop    rbp
    1a56:	ret

0000000000001a57 <botlish_fn_21: hex_pair<int>>:
    1a57:	push   rbp
    1a58:	mov    rbp,rsp
    1a5b:	sub    rsp,0x50
    1a5f:	mov    QWORD PTR [rsp+0x30],rbx
    1a64:	mov    QWORD PTR [rsp+0x38],r12
    1a69:	mov    QWORD PTR [rsp+0x40],r13
    1a6e:	mov    QWORD PTR [rsp+0x48],r14
    1a73:	mov    QWORD PTR [rsp],rsi
    1a77:	mov    r12,rsi
    1a7a:	mov    rax,QWORD PTR [rdi+0x30]
    1a7e:	mov    rbx,rdi
    1a81:	mov    rsi,QWORD PTR [rax+0x8]
    1a85:	mov    QWORD PTR [rsp+0x8],rsi
    1a8a:	mov    r13,rsi
    1a8d:	mov    rsi,r12
    1a90:	call   1a95 <botlish_fn_21+0x3e>
			1a91: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    1a95:	test   rax,0x1
    1a9b:	jne    1aac <botlish_fn_21+0x55>
    1aa1:	mov    rdx,rax
    1aa4:	mov    rsi,r13
    1aa7:	jmp    1ac5 <botlish_fn_21+0x6e>
    1aac:	mov    rsi,r13
    1aaf:	mov    rdx,QWORD PTR [rsi+0x8]
    1ab3:	mov    rcx,rax
    1ab6:	sar    rcx,1
    1ab9:	cmp    rcx,rdx
    1abc:	jb     1adb <botlish_fn_21+0x84>
    1ac2:	mov    rdx,rax
    1ac5:	mov    rdi,rbx
    1ac8:	call   1acd <botlish_fn_21+0x76>
			1ac9: R_X86_64_PLT32	rt_list_get-0x4
    1acd:	test   rax,rax
    1ad0:	je     1ba0 <botlish_fn_21+0x149>
    1ad6:	jmp    1ae3 <botlish_fn_21+0x8c>
    1adb:	mov    rax,QWORD PTR [rsi+0x10]
    1adf:	mov    rax,QWORD PTR [rax+rcx*8]
    1ae3:	mov    QWORD PTR [rsp],rax
    1ae7:	mov    rdi,rbx
    1aea:	mov    r14,rax
    1aed:	mov    rax,QWORD PTR [rdi+0x30]
    1af1:	mov    rsi,QWORD PTR [rax+0x8]
    1af5:	mov    r13,rsi
    1af8:	mov    edx,0x21
    1afd:	mov    rsi,r12
    1b00:	call   1b05 <botlish_fn_21+0xae>
			1b01: R_X86_64_PLT32	rt_int_mod-0x4
    1b05:	test   rax,rax
    1b08:	je     1ba0 <botlish_fn_21+0x149>
    1b0e:	test   rax,0x1
    1b14:	jne    1b25 <botlish_fn_21+0xce>
    1b1a:	mov    rdx,rax
    1b1d:	mov    rsi,r13
    1b20:	jmp    1b3e <botlish_fn_21+0xe7>
    1b25:	mov    rsi,r13
    1b28:	mov    rdx,QWORD PTR [rsi+0x8]
    1b2c:	mov    rcx,rax
    1b2f:	sar    rcx,1
    1b32:	cmp    rcx,rdx
    1b35:	jb     1b54 <botlish_fn_21+0xfd>
    1b3b:	mov    rdx,rax
    1b3e:	mov    rdi,rbx
    1b41:	call   1b46 <botlish_fn_21+0xef>
			1b42: R_X86_64_PLT32	rt_list_get-0x4
    1b46:	test   rax,rax
    1b49:	je     1ba0 <botlish_fn_21+0x149>
    1b4f:	jmp    1b5c <botlish_fn_21+0x105>
    1b54:	mov    rax,QWORD PTR [rsi+0x10]
    1b58:	mov    rax,QWORD PTR [rax+rcx*8]
    1b5c:	mov    QWORD PTR [rsp+0x8],rax
    1b61:	lea    rcx,[rsp+0x10]
    1b66:	mov    QWORD PTR [rsp+0x10],0x0
    1b6f:	mov    rdx,r14
    1b72:	mov    QWORD PTR [rsp+0x18],rdx
    1b77:	mov    QWORD PTR [rsp+0x20],0x0
    1b80:	mov    QWORD PTR [rsp+0x28],rax
    1b85:	mov    esi,0x2
    1b8a:	mov    edx,0x4
    1b8f:	mov    rdi,rbx
    1b92:	call   1b97 <botlish_fn_21+0x140>
			1b93: R_X86_64_PLT32	rt_construct-0x4
    1b97:	test   rax,rax
    1b9a:	jne    1bc0 <botlish_fn_21+0x169>
    1ba0:	xor    rax,rax
    1ba3:	mov    rbx,QWORD PTR [rsp+0x30]
    1ba8:	mov    r12,QWORD PTR [rsp+0x38]
    1bad:	mov    r13,QWORD PTR [rsp+0x40]
    1bb2:	mov    r14,QWORD PTR [rsp+0x48]
    1bb7:	add    rsp,0x50
    1bbb:	mov    rsp,rbp
    1bbe:	pop    rbp
    1bbf:	ret
    1bc0:	mov    rbx,QWORD PTR [rsp+0x30]
    1bc5:	mov    r12,QWORD PTR [rsp+0x38]
    1bca:	mov    r13,QWORD PTR [rsp+0x40]
    1bcf:	mov    r14,QWORD PTR [rsp+0x48]
    1bd4:	add    rsp,0x50
    1bd8:	mov    rsp,rbp
    1bdb:	pop    rbp
    1bdc:	ret

0000000000001bdd <botlish_entry_21: hex_pair<int>>:
    1bdd:	push   rbp
    1bde:	mov    rbp,rsp
    1be1:	sub    rsp,0x10
    1be5:	mov    QWORD PTR [rsp],r12
    1be9:	mov    r12,rdi
    1bec:	mov    rsi,QWORD PTR [rdx]
    1bef:	call   1bf4 <botlish_entry_21+0x17>
			1bf0: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1bf4:	mov    r8,QWORD PTR [rip+0x0]        # 1bfb <botlish_entry_21+0x1e>
			1bf7: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1bfb:	mov    rsi,rax
    1bfe:	mov    rdi,r12
    1c01:	call   r8
    1c04:	mov    r12,QWORD PTR [rsp]
    1c08:	add    rsp,0x10
    1c0c:	mov    rsp,rbp
    1c0f:	pop    rbp
    1c10:	ret

0000000000001c11 <botlish_fn_22: esc_bytes<List[int], int, str>>:
    1c11:	push   rbp
    1c12:	mov    rbp,rsp
    1c15:	sub    rsp,0x90
    1c1c:	mov    QWORD PTR [rsp+0x60],rbx
    1c21:	mov    QWORD PTR [rsp+0x68],r12
    1c26:	mov    QWORD PTR [rsp+0x70],r13
    1c2b:	mov    QWORD PTR [rsp+0x78],r14
    1c30:	mov    QWORD PTR [rsp+0x80],r15
    1c38:	mov    QWORD PTR [rsp],rsi
    1c3c:	mov    QWORD PTR [rsp+0x8],rcx
    1c41:	sar    rdx,1
    1c44:	mov    r13,rdx
    1c47:	lea    r14,[rsp+0x20]
    1c4c:	mov    rbx,rdi
    1c4f:	mov    r12,rsi
    1c52:	mov    QWORD PTR [rsp+0x50],rcx
    1c57:	mov    rsi,r12
    1c5a:	mov    rdi,rbx
    1c5d:	call   1c62 <botlish_fn_22+0x51>
			1c5e: R_X86_64_PLT32	rt_list_len-0x4
    1c62:	sar    rax,1
    1c65:	cmp    r13,rax
    1c68:	jge    1d78 <botlish_fn_22+0x167>
    1c6e:	mov    rax,QWORD PTR [rbx+0x10]
    1c72:	mov    r15,QWORD PTR [rax+0x10]
    1c76:	mov    QWORD PTR [rsp+0x10],r15
    1c7b:	mov    rcx,QWORD PTR [r12+0x8]
    1c80:	mov    rax,r13
    1c83:	shl    rax,1
    1c86:	or     rax,0x1
    1c8a:	sar    rax,1
    1c8d:	cmp    rax,rcx
    1c90:	jb     1cbc <botlish_fn_22+0xab>
    1c96:	mov    rdx,r13
    1c99:	shl    rdx,1
    1c9c:	or     rdx,0x1
    1ca0:	mov    rsi,r12
    1ca3:	mov    rdi,rbx
    1ca6:	call   1cab <botlish_fn_22+0x9a>
			1ca7: R_X86_64_PLT32	rt_list_get-0x4
    1cab:	test   rax,rax
    1cae:	je     1d33 <botlish_fn_22+0x122>
    1cb4:	mov    rsi,rax
    1cb7:	jmp    1cc5 <botlish_fn_22+0xb4>
    1cbc:	mov    rcx,QWORD PTR [r12+0x10]
    1cc1:	mov    rsi,QWORD PTR [rcx+rax*8]
    1cc5:	mov    QWORD PTR [rsp+0x18],rsi
    1cca:	mov    rdi,rbx
    1ccd:	call   1cd2 <botlish_fn_22+0xc1>
			1cce: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1cd2:	test   rax,rax
    1cd5:	je     1d33 <botlish_fn_22+0x122>
    1cdb:	mov    QWORD PTR [rsp+0x18],rax
    1ce0:	mov    rcx,rax
    1ce3:	mov    QWORD PTR [rsp+0x20],0x0
    1cec:	mov    rax,QWORD PTR [rsp+0x50]
    1cf1:	mov    QWORD PTR [rsp+0x28],rax
    1cf6:	mov    QWORD PTR [rsp+0x30],0x0
    1cff:	mov    QWORD PTR [rsp+0x38],r15
    1d04:	mov    QWORD PTR [rsp+0x40],0x0
    1d0d:	mov    rax,rcx
    1d10:	mov    QWORD PTR [rsp+0x48],rax
    1d15:	mov    esi,0x2
    1d1a:	mov    edx,0x6
    1d1f:	mov    rcx,r14
    1d22:	mov    rdi,rbx
    1d25:	call   1d2a <botlish_fn_22+0x119>
			1d26: R_X86_64_PLT32	rt_construct-0x4
    1d2a:	test   rax,rax
    1d2d:	jne    1d5e <botlish_fn_22+0x14d>
    1d33:	xor    rax,rax
    1d36:	mov    rbx,QWORD PTR [rsp+0x60]
    1d3b:	mov    r12,QWORD PTR [rsp+0x68]
    1d40:	mov    r13,QWORD PTR [rsp+0x70]
    1d45:	mov    r14,QWORD PTR [rsp+0x78]
    1d4a:	mov    r15,QWORD PTR [rsp+0x80]
    1d52:	add    rsp,0x90
    1d59:	mov    rsp,rbp
    1d5c:	pop    rbp
    1d5d:	ret
    1d5e:	mov    QWORD PTR [rsp],r12
    1d62:	mov    QWORD PTR [rsp+0x8],rax
    1d67:	add    r13,0x1
    1d6e:	mov    QWORD PTR [rsp+0x50],rax
    1d73:	jmp    1c57 <botlish_fn_22+0x46>
    1d78:	mov    rax,QWORD PTR [rsp+0x50]
    1d7d:	mov    rbx,QWORD PTR [rsp+0x60]
    1d82:	mov    r12,QWORD PTR [rsp+0x68]
    1d87:	mov    r13,QWORD PTR [rsp+0x70]
    1d8c:	mov    r14,QWORD PTR [rsp+0x78]
    1d91:	mov    r15,QWORD PTR [rsp+0x80]
    1d99:	add    rsp,0x90
    1da0:	mov    rsp,rbp
    1da3:	pop    rbp
    1da4:	ret

0000000000001da5 <botlish_entry_22: esc_bytes<List[int], int, str>>:
    1da5:	push   rbp
    1da6:	mov    rbp,rsp
    1da9:	sub    rsp,0x10
    1dad:	mov    QWORD PTR [rsp],r12
    1db1:	mov    r12,rdi
    1db4:	mov    rsi,QWORD PTR [rdx]
    1db7:	mov    r8,QWORD PTR [rdx+0x8]
    1dbb:	mov    rcx,QWORD PTR [rdx+0x10]
    1dbf:	mov    rdx,r8
    1dc2:	call   1dc7 <botlish_entry_22+0x22>
			1dc3: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1dc7:	mov    r8,QWORD PTR [rip+0x0]        # 1dce <botlish_entry_22+0x29>
			1dca: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1dce:	mov    rsi,rax
    1dd1:	mov    rdi,r12
    1dd4:	call   r8
    1dd7:	mov    r12,QWORD PTR [rsp]
    1ddb:	add    rsp,0x10
    1ddf:	mov    rsp,rbp
    1de2:	pop    rbp
    1de3:	ret

0000000000001de4 <botlish_fn_23: esc_char<str>>:
    1de4:	push   rbp
    1de5:	mov    rbp,rsp
    1de8:	sub    rsp,0x40
    1dec:	mov    QWORD PTR [rsp+0x20],rbx
    1df1:	mov    QWORD PTR [rsp+0x28],r12
    1df6:	mov    QWORD PTR [rsp+0x30],r13
    1dfb:	mov    QWORD PTR [rsp],0x0
    1e03:	mov    QWORD PTR [rsp+0x8],0x0
    1e0c:	mov    QWORD PTR [rsp+0x10],0x0
    1e15:	lea    rax,[rsi+0x1]
    1e19:	cmp    rax,0x101
    1e1f:	jb     1e2d <botlish_fn_23+0x49>
    1e25:	mov    rbx,rdi
    1e28:	jmp    1e45 <botlish_fn_23+0x61>
    1e2d:	lea    rax,[rsi+0x1]
    1e31:	mov    rax,QWORD PTR [rdi+rax*8+0x648]
    1e39:	mov    rbx,rdi
    1e3c:	test   rax,rax
    1e3f:	jne    1e4d <botlish_fn_23+0x69>
    1e45:	mov    rdi,rbx
    1e48:	call   1e4d <botlish_fn_23+0x69>
			1e49: R_X86_64_PLT32	rt_short_to_str-0x4
    1e4d:	mov    QWORD PTR [rsp],rax
    1e51:	mov    r13,rax
    1e54:	mov    rsi,r13
    1e57:	mov    rdi,rbx
    1e5a:	call   1e5f <botlish_fn_23+0x7b>
			1e5b: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1e5f:	mov    r8,rax
    1e62:	mov    r12,rax
    1e65:	test   rax,r8
    1e68:	je     1f55 <botlish_fn_23+0x171>
    1e6e:	mov    rax,r12
    1e71:	mov    QWORD PTR [rsp],rax
    1e75:	mov    rsi,r12
    1e78:	mov    rdi,rbx
    1e7b:	call   1e80 <botlish_fn_23+0x9c>
			1e7c: R_X86_64_PLT32	rt_list_len-0x4
    1e80:	sar    rax,1
    1e83:	cmp    rax,0x1
    1e87:	je     1ecd <botlish_fn_23+0xe9>
    1e8d:	mov    edx,0x1
    1e92:	mov    QWORD PTR [rsp+0x8],0x1
    1e9b:	mov    rdi,rbx
    1e9e:	mov    rax,QWORD PTR [rdi+0x10]
    1ea2:	mov    rcx,QWORD PTR [rax+0xe8]
    1ea9:	mov    QWORD PTR [rsp+0x10],rcx
    1eae:	mov    rsi,r12
    1eb1:	call   1eb6 <botlish_fn_23+0xd2>
			1eb2: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1eb6:	mov    rcx,rax
    1eb9:	mov    r13,rax
    1ebc:	test   rax,rcx
    1ebf:	je     1f55 <botlish_fn_23+0x171>
    1ec5:	mov    rax,r13
    1ec8:	jmp    1f73 <botlish_fn_23+0x18f>
    1ecd:	mov    rsi,r12
    1ed0:	mov    rax,QWORD PTR [rsi+0x8]
    1ed4:	mov    r12,rsi
    1ed7:	test   rax,rax
    1eda:	jne    1f01 <botlish_fn_23+0x11d>
    1ee0:	mov    edx,0x1
    1ee5:	mov    rsi,r12
    1ee8:	mov    rdi,rbx
    1eeb:	call   1ef0 <botlish_fn_23+0x10c>
			1eec: R_X86_64_PLT32	rt_list_get-0x4
    1ef0:	test   rax,rax
    1ef3:	je     1f55 <botlish_fn_23+0x171>
    1ef9:	mov    rsi,rax
    1efc:	jmp    1f0b <botlish_fn_23+0x127>
    1f01:	mov    rsi,r12
    1f04:	mov    rax,QWORD PTR [rsi+0x10]
    1f08:	mov    rsi,QWORD PTR [rax]
    1f0b:	mov    rdi,rbx
    1f0e:	call   1f13 <botlish_fn_23+0x12f>
			1f0f: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1f13:	cmp    rax,0x6
    1f17:	je     1f70 <botlish_fn_23+0x18c>
    1f1d:	mov    edx,0x1
    1f22:	mov    QWORD PTR [rsp+0x8],0x1
    1f2b:	mov    rdi,rbx
    1f2e:	mov    rsi,QWORD PTR [rdi+0x10]
    1f32:	mov    rcx,QWORD PTR [rsi+0xe8]
    1f39:	mov    QWORD PTR [rsp+0x10],rcx
    1f3e:	mov    rsi,r12
    1f41:	call   1f46 <botlish_fn_23+0x162>
			1f42: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1f46:	mov    rcx,rax
    1f49:	mov    r13,rax
    1f4c:	test   rax,rcx
    1f4f:	jne    1f70 <botlish_fn_23+0x18c>
    1f55:	xor    rax,rax
    1f58:	mov    rbx,QWORD PTR [rsp+0x20]
    1f5d:	mov    r12,QWORD PTR [rsp+0x28]
    1f62:	mov    r13,QWORD PTR [rsp+0x30]
    1f67:	add    rsp,0x40
    1f6b:	mov    rsp,rbp
    1f6e:	pop    rbp
    1f6f:	ret
    1f70:	mov    rax,r13
    1f73:	mov    rbx,QWORD PTR [rsp+0x20]
    1f78:	mov    r12,QWORD PTR [rsp+0x28]
    1f7d:	mov    r13,QWORD PTR [rsp+0x30]
    1f82:	add    rsp,0x40
    1f86:	mov    rsp,rbp
    1f89:	pop    rbp
    1f8a:	ret

0000000000001f8b <botlish_entry_23: esc_char<str>>:
    1f8b:	push   rbp
    1f8c:	mov    rbp,rsp
    1f8f:	sub    rsp,0x10
    1f93:	mov    QWORD PTR [rsp],r12
    1f97:	mov    r12,rdi
    1f9a:	mov    rsi,QWORD PTR [rdx]
    1f9d:	mov    r8,QWORD PTR [rip+0x0]        # 1fa4 <botlish_entry_23+0x19>
			1fa0: R_X86_64_GOTPCREL	rt_str_to_short-0x4
    1fa4:	call   r8
    1fa7:	mov    rsi,rax
    1faa:	mov    rdi,r12
    1fad:	call   1fb2 <botlish_entry_23+0x27>
			1fae: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1fb2:	mov    r8,QWORD PTR [rip+0x0]        # 1fb9 <botlish_entry_23+0x2e>
			1fb5: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1fb9:	mov    rsi,rax
    1fbc:	mov    rdi,r12
    1fbf:	call   r8
    1fc2:	mov    r12,QWORD PTR [rsp]
    1fc6:	add    rsp,0x10
    1fca:	mov    rsp,rbp
    1fcd:	pop    rbp
    1fce:	ret

0000000000001fcf <botlish_fn_24: esc_from<str, int, str>>:
    1fcf:	push   rbp
    1fd0:	mov    rbp,rsp
    1fd3:	sub    rsp,0x90
    1fda:	mov    QWORD PTR [rsp+0x60],rbx
    1fdf:	mov    QWORD PTR [rsp+0x68],r12
    1fe4:	mov    QWORD PTR [rsp+0x70],r13
    1fe9:	mov    QWORD PTR [rsp+0x78],r14
    1fee:	mov    QWORD PTR [rsp+0x80],r15
    1ff6:	mov    r14,rdi
    1ff9:	mov    QWORD PTR [rsp+0x10],0x0
    2002:	mov    QWORD PTR [rsp],rsi
    2006:	mov    QWORD PTR [rsp+0x8],rcx
    200b:	mov    r15,rcx
    200e:	sar    rdx,1
    2011:	mov    r12,rdx
    2014:	lea    r13,[rsp+0x28]
    2019:	mov    rbx,rsi
    201c:	mov    rsi,rbx
    201f:	mov    rdi,r14
    2022:	call   2027 <botlish_fn_24+0x58>
			2023: R_X86_64_PLT32	rt_str_len-0x4
    2027:	sar    rax,1
    202a:	cmp    r12,rax
    202d:	jge    20e8 <botlish_fn_24+0x119>
    2033:	mov    rdx,r12
    2036:	shl    rdx,1
    2039:	or     rdx,0x1
    203d:	mov    QWORD PTR [rsp+0x50],rdx
    2042:	add    r12,0x1
    2049:	mov    rcx,r12
    204c:	shl    rcx,1
    204f:	or     rcx,0x1
    2053:	mov    QWORD PTR [rsp+0x48],rcx
    2058:	mov    rsi,rbx
    205b:	mov    rdi,r14
    205e:	call   2063 <botlish_fn_24+0x94>
			205f: R_X86_64_PLT32	rt_str_region_check-0x4
    2063:	test   rax,rax
    2066:	je     211a <botlish_fn_24+0x14b>
    206c:	mov    rcx,QWORD PTR [rsp+0x48]
    2071:	mov    rdx,QWORD PTR [rsp+0x50]
    2076:	mov    rsi,rbx
    2079:	mov    rdi,r14
    207c:	call   2081 <botlish_fn_24+0xb2>
			207d: R_X86_64_PLT32	rt_str_slice_short-0x4
    2081:	mov    rsi,rax
    2084:	mov    rdi,r14
    2087:	call   208c <botlish_fn_24+0xbd>
			2088: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    208c:	test   rax,rax
    208f:	je     211a <botlish_fn_24+0x14b>
    2095:	mov    QWORD PTR [rsp+0x10],rax
    209a:	mov    QWORD PTR [rsp+0x28],0x0
    20a3:	mov    rcx,r15
    20a6:	mov    QWORD PTR [rsp+0x30],rcx
    20ab:	mov    QWORD PTR [rsp+0x38],0x0
    20b4:	mov    QWORD PTR [rsp+0x40],rax
    20b9:	mov    esi,0x2
    20be:	mov    edx,0x4
    20c3:	mov    rcx,r13
    20c6:	mov    rdi,r14
    20c9:	call   20ce <botlish_fn_24+0xff>
			20ca: R_X86_64_PLT32	rt_construct-0x4
    20ce:	test   rax,rax
    20d1:	je     211a <botlish_fn_24+0x14b>
    20d7:	mov    QWORD PTR [rsp],rbx
    20db:	mov    QWORD PTR [rsp+0x8],rax
    20e0:	mov    r15,rax
    20e3:	jmp    201c <botlish_fn_24+0x4d>
    20e8:	mov    rcx,r15
    20eb:	xor    rsi,rsi
    20ee:	lea    rax,[rsp+0x18]
    20f3:	mov    QWORD PTR [rsp+0x18],0x0
    20fc:	mov    QWORD PTR [rsp+0x20],rcx
    2101:	mov    edx,0x2
    2106:	mov    rcx,rax
    2109:	mov    rdi,r14
    210c:	call   2111 <botlish_fn_24+0x142>
			210d: R_X86_64_PLT32	rt_construct-0x4
    2111:	test   rax,rax
    2114:	jne    2145 <botlish_fn_24+0x176>
    211a:	xor    rax,rax
    211d:	mov    rbx,QWORD PTR [rsp+0x60]
    2122:	mov    r12,QWORD PTR [rsp+0x68]
    2127:	mov    r13,QWORD PTR [rsp+0x70]
    212c:	mov    r14,QWORD PTR [rsp+0x78]
    2131:	mov    r15,QWORD PTR [rsp+0x80]
    2139:	add    rsp,0x90
    2140:	mov    rsp,rbp
    2143:	pop    rbp
    2144:	ret
    2145:	mov    rbx,QWORD PTR [rsp+0x60]
    214a:	mov    r12,QWORD PTR [rsp+0x68]
    214f:	mov    r13,QWORD PTR [rsp+0x70]
    2154:	mov    r14,QWORD PTR [rsp+0x78]
    2159:	mov    r15,QWORD PTR [rsp+0x80]
    2161:	add    rsp,0x90
    2168:	mov    rsp,rbp
    216b:	pop    rbp
    216c:	ret

000000000000216d <botlish_entry_24: esc_from<str, int, str>>:
    216d:	push   rbp
    216e:	mov    rbp,rsp
    2171:	mov    rsi,QWORD PTR [rdx]
    2174:	mov    r8,QWORD PTR [rdx+0x8]
    2178:	mov    rcx,QWORD PTR [rdx+0x10]
    217c:	mov    rdx,r8
    217f:	call   2184 <botlish_entry_24+0x17>
			2180: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    2184:	mov    rsp,rbp
    2187:	pop    rbp
    2188:	ret

0000000000002189 <botlish_fn_25: check<int, int, str, str>>:
    2189:	push   rbp
    218a:	mov    rbp,rsp
    218d:	sub    rsp,0x50
    2191:	mov    QWORD PTR [rsp+0x20],rbx
    2196:	mov    QWORD PTR [rsp+0x28],r12
    219b:	mov    QWORD PTR [rsp+0x30],r13
    21a0:	mov    QWORD PTR [rsp+0x38],r14
    21a5:	mov    QWORD PTR [rsp+0x40],r15
    21aa:	mov    r14,rdi
    21ad:	mov    QWORD PTR [rsp+0x18],0x0
    21b6:	mov    QWORD PTR [rsp],rdx
    21ba:	mov    QWORD PTR [rsp+0x8],rcx
    21bf:	mov    QWORD PTR [rsp+0x10],r8
    21c4:	mov    r13,r8
    21c7:	mov    r12,rsi
    21ca:	mov    r15,rdx
    21cd:	test   r12,r12
    21d0:	jle    2292 <botlish_fn_25+0x109>
    21d6:	mov    rbx,rcx
    21d9:	mov    rsi,rbx
    21dc:	mov    rdi,r14
    21df:	call   21e4 <botlish_fn_25+0x5b>
			21e0: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
    21e4:	test   rax,rax
    21e7:	jne    2212 <botlish_fn_25+0x89>
    21ed:	xor    rax,rax
    21f0:	mov    rbx,QWORD PTR [rsp+0x20]
    21f5:	mov    r12,QWORD PTR [rsp+0x28]
    21fa:	mov    r13,QWORD PTR [rsp+0x30]
    21ff:	mov    r14,QWORD PTR [rsp+0x38]
    2204:	mov    r15,QWORD PTR [rsp+0x40]
    2209:	add    rsp,0x50
    220d:	mov    rsp,rbp
    2210:	pop    rbp
    2211:	ret
    2212:	cmp    rax,0x6
    2216:	je     2232 <botlish_fn_25+0xa9>
    221c:	mov    edx,0x1
    2221:	mov    QWORD PTR [rsp+0x18],0x1
    222a:	mov    rsi,r15
    222d:	jmp    2243 <botlish_fn_25+0xba>
    2232:	mov    edx,0x3
    2237:	mov    QWORD PTR [rsp+0x18],0x3
    2240:	mov    rsi,r15
    2243:	mov    rax,rsi
    2246:	and    rax,rdx
    2249:	test   rax,0x1
    224f:	je     226a <botlish_fn_25+0xe1>
    2255:	lea    rcx,[rdx-0x1]
    2259:	mov    rax,rsi
    225c:	add    rax,rcx
    225f:	seto   cl
    2262:	test   cl,cl
    2264:	je     2272 <botlish_fn_25+0xe9>
    226a:	mov    rdi,r14
    226d:	call   2272 <botlish_fn_25+0xe9>
			226e: R_X86_64_PLT32	rt_int_add-0x4
    2272:	mov    QWORD PTR [rsp],rax
    2276:	mov    QWORD PTR [rsp+0x8],rbx
    227b:	mov    r8,r13
    227e:	mov    QWORD PTR [rsp+0x10],r8
    2283:	sub    r12,0x1
    2287:	mov    rcx,rbx
    228a:	mov    r15,rax
    228d:	jmp    21cd <botlish_fn_25+0x44>
    2292:	mov    rax,r15
    2295:	mov    rbx,QWORD PTR [rsp+0x20]
    229a:	mov    r12,QWORD PTR [rsp+0x28]
    229f:	mov    r13,QWORD PTR [rsp+0x30]
    22a4:	mov    r14,QWORD PTR [rsp+0x38]
    22a9:	mov    r15,QWORD PTR [rsp+0x40]
    22ae:	add    rsp,0x50
    22b2:	mov    rsp,rbp
    22b5:	pop    rbp
    22b6:	ret

00000000000022b7 <botlish_entry_25: check<int, int, str, str>>:
    22b7:	push   rbp
    22b8:	mov    rbp,rsp
    22bb:	mov    rsi,QWORD PTR [rdx]
    22be:	mov    r9,QWORD PTR [rdx+0x8]
    22c2:	mov    rcx,QWORD PTR [rdx+0x10]
    22c6:	mov    r8,QWORD PTR [rdx+0x18]
    22ca:	sar    rsi,1
    22cd:	mov    rdx,r9
    22d0:	call   22d5 <botlish_entry_25+0x1e>
			22d1: R_X86_64_PLT32	botlish_fn_25-0x4 ; check<int, int, str, str>
    22d5:	mov    rsp,rbp
    22d8:	pop    rbp
    22d9:	ret

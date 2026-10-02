; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 9080  (per function: 1425 39 289 609 74 74 74 128 128 379 262 222 176 238 440 456 468 1076 140 94 103 474 491 426 451 344)
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
     e03:	mov    QWORD PTR [rsp+0x8],r14
     e08:	mov    rbx,rdi
     e0b:	mov    r14,rsi
     e0e:	mov    rsi,r14
     e11:	mov    rdi,rbx
     e14:	call   e19 <botlish_fn_12+0x22>
			e15: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     e19:	test   rax,rax
     e1c:	jne    e37 <botlish_fn_12+0x40>
     e22:	xor    rax,rax
     e25:	mov    rbx,QWORD PTR [rsp]
     e29:	mov    r14,QWORD PTR [rsp+0x8]
     e2e:	add    rsp,0x10
     e32:	mov    rsp,rbp
     e35:	pop    rbp
     e36:	ret
     e37:	cmp    rax,0x6
     e3b:	je     e71 <botlish_fn_12+0x7a>
     e41:	mov    rdi,rbx
     e44:	mov    rax,QWORD PTR [rdi+0x30]
     e48:	mov    rsi,QWORD PTR [rax]
     e4b:	mov    rdx,r14
     e4e:	call   e53 <botlish_fn_12+0x5c>
			e4f: R_X86_64_PLT32	rt_set_contains-0x4
     e53:	cmp    rax,0x6
     e57:	je     e67 <botlish_fn_12+0x70>
     e5d:	mov    eax,0x2
     e62:	jmp    e76 <botlish_fn_12+0x7f>
     e67:	mov    eax,0x6
     e6c:	jmp    e76 <botlish_fn_12+0x7f>
     e71:	mov    eax,0x6
     e76:	mov    rbx,QWORD PTR [rsp]
     e7a:	mov    r14,QWORD PTR [rsp+0x8]
     e7f:	add    rsp,0x10
     e83:	mov    rsp,rbp
     e86:	pop    rbp
     e87:	ret

0000000000000e88 <botlish_entry_12: local_char?<str>>:
     e88:	push   rbp
     e89:	mov    rbp,rsp
     e8c:	mov    rsi,QWORD PTR [rdx]
     e8f:	call   e94 <botlish_entry_12+0xc>
			e90: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     e94:	mov    rsp,rbp
     e97:	pop    rbp
     e98:	ret

0000000000000e99 <botlish_fn_13: local_char?<generic>>:
     e99:	push   rbp
     e9a:	mov    rbp,rsp
     e9d:	sub    rsp,0x10
     ea1:	mov    QWORD PTR [rsp],rbx
     ea5:	mov    QWORD PTR [rsp+0x8],r12
     eaa:	xor    r8d,r8d
     ead:	test   rsi,0x7
     eb4:	jne    ec4 <botlish_fn_13+0x2b>
     eba:	movzx  rax,BYTE PTR [rsi]
     ebe:	cmp    al,0x2
     ec0:	sete   r8b
     ec4:	test   r8b,r8b
     ec7:	jne    ee7 <botlish_fn_13+0x4e>
     ecd:	mov    rax,QWORD PTR [rdi+0x10]
     ed1:	mov    rcx,QWORD PTR [rax+0xd8]
     ed8:	mov    edx,0x1
     edd:	call   ee2 <botlish_fn_13+0x49>
			ede: R_X86_64_PLT32	rt_type_error-0x4
     ee2:	jmp    efb <botlish_fn_13+0x62>
     ee7:	mov    rbx,rsi
     eea:	mov    r12,rdi
     eed:	call   ef2 <botlish_fn_13+0x59>
			eee: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     ef2:	test   rax,rax
     ef5:	jne    f10 <botlish_fn_13+0x77>
     efb:	xor    rax,rax
     efe:	mov    rbx,QWORD PTR [rsp]
     f02:	mov    r12,QWORD PTR [rsp+0x8]
     f07:	add    rsp,0x10
     f0b:	mov    rsp,rbp
     f0e:	pop    rbp
     f0f:	ret
     f10:	cmp    rax,0x6
     f14:	je     f4a <botlish_fn_13+0xb1>
     f1a:	mov    rdi,r12
     f1d:	mov    rax,QWORD PTR [rdi+0x30]
     f21:	mov    rsi,QWORD PTR [rax]
     f24:	mov    rdx,rbx
     f27:	call   f2c <botlish_fn_13+0x93>
			f28: R_X86_64_PLT32	rt_set_contains-0x4
     f2c:	cmp    rax,0x6
     f30:	je     f40 <botlish_fn_13+0xa7>
     f36:	mov    eax,0x2
     f3b:	jmp    f4f <botlish_fn_13+0xb6>
     f40:	mov    eax,0x6
     f45:	jmp    f4f <botlish_fn_13+0xb6>
     f4a:	mov    eax,0x6
     f4f:	mov    rbx,QWORD PTR [rsp]
     f53:	mov    r12,QWORD PTR [rsp+0x8]
     f58:	add    rsp,0x10
     f5c:	mov    rsp,rbp
     f5f:	pop    rbp
     f60:	ret

0000000000000f61 <botlish_entry_13: local_char?<generic>>:
     f61:	push   rbp
     f62:	mov    rbp,rsp
     f65:	mov    rsi,QWORD PTR [rdx]
     f68:	call   f6d <botlish_entry_13+0xc>
			f69: R_X86_64_PLT32	botlish_fn_13-0x4 ; local_char?<generic>
     f6d:	mov    rsp,rbp
     f70:	pop    rbp
     f71:	ret
     f72:	add    BYTE PTR [rax],al
     f74:	add    BYTE PTR [rax],al
	...

0000000000000f78 <botlish_fn_14: scan_while<any, block(e239)>>:
     f78:	push   rbp
     f79:	mov    rbp,rsp
     f7c:	sub    rsp,0x40
     f80:	mov    QWORD PTR [rsp+0x20],rbx
     f85:	mov    QWORD PTR [rsp+0x28],r12
     f8a:	mov    QWORD PTR [rsp+0x30],r13
     f8f:	mov    QWORD PTR [rsp+0x38],r14
     f94:	mov    rbx,rcx
     f97:	mov    r13,rdi
     f9a:	mov    QWORD PTR [rsp+0x18],0x0
     fa3:	mov    QWORD PTR [rsp],rcx
     fa7:	mov    QWORD PTR [rsp+0x8],r8
     fac:	mov    r12,r8
     faf:	mov    QWORD PTR [rsp+0x10],rsi
     fb4:	mov    rax,rsi
     fb7:	mov    rcx,rbx
     fba:	mov    r14,rsi
     fbd:	mov    rcx,rbx
     fc0:	and    rax,rcx
     fc3:	test   rax,0x1
     fc9:	jne    ff2 <botlish_fn_14+0x7a>
     fcf:	mov    rdx,rbx
     fd2:	mov    rsi,r14
     fd5:	mov    rdi,r13
     fd8:	call   fdd <botlish_fn_14+0x65>
			fd9: R_X86_64_PLT32	rt_int_cmp-0x4
     fdd:	mov    ecx,0x2
     fe2:	test   rax,rax
     fe5:	cmovl  rcx,QWORD PTR [rip+0x10b]        # 10f8 <botlish_fn_14+0x180>
     fed:	jmp    1008 <botlish_fn_14+0x90>
     ff2:	mov    ecx,0x2
     ff7:	mov    rax,r14
     ffa:	mov    rdx,rbx
     ffd:	cmp    rax,rdx
    1000:	cmovl  rcx,QWORD PTR [rip+0xf0]        # 10f8 <botlish_fn_14+0x180>
    1008:	cmp    rcx,0x6
    100c:	je     1032 <botlish_fn_14+0xba>
    1012:	mov    rax,rbx
    1015:	mov    rbx,QWORD PTR [rsp+0x20]
    101a:	mov    r12,QWORD PTR [rsp+0x28]
    101f:	mov    r13,QWORD PTR [rsp+0x30]
    1024:	mov    r14,QWORD PTR [rsp+0x38]
    1029:	add    rsp,0x40
    102d:	mov    rsp,rbp
    1030:	pop    rbp
    1031:	ret
    1032:	mov    rdx,r12
    1035:	mov    rsi,r14
    1038:	mov    rdi,r13
    103b:	call   1040 <botlish_fn_14+0xc8>
			103c: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    1040:	test   rax,rax
    1043:	mov    rsi,rax
    1046:	je     105d <botlish_fn_14+0xe5>
    104c:	mov    rdi,r13
    104f:	call   1054 <botlish_fn_14+0xdc>
			1050: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
    1054:	test   rax,rax
    1057:	jne    107d <botlish_fn_14+0x105>
    105d:	xor    rax,rax
    1060:	mov    rbx,QWORD PTR [rsp+0x20]
    1065:	mov    r12,QWORD PTR [rsp+0x28]
    106a:	mov    r13,QWORD PTR [rsp+0x30]
    106f:	mov    r14,QWORD PTR [rsp+0x38]
    1074:	add    rsp,0x40
    1078:	mov    rsp,rbp
    107b:	pop    rbp
    107c:	ret
    107d:	cmp    rax,0x6
    1081:	je     10a7 <botlish_fn_14+0x12f>
    1087:	mov    rax,r14
    108a:	mov    rbx,QWORD PTR [rsp+0x20]
    108f:	mov    r12,QWORD PTR [rsp+0x28]
    1094:	mov    r13,QWORD PTR [rsp+0x30]
    1099:	mov    r14,QWORD PTR [rsp+0x38]
    109e:	add    rsp,0x40
    10a2:	mov    rsp,rbp
    10a5:	pop    rbp
    10a6:	ret
    10a7:	mov    QWORD PTR [rsp+0x18],0x3
    10b0:	mov    rax,r14
    10b3:	test   rax,0x1
    10b9:	je     10d4 <botlish_fn_14+0x15c>
    10bf:	mov    rcx,r14
    10c2:	mov    rax,rcx
    10c5:	add    rax,0x2
    10c9:	seto   cl
    10cc:	test   cl,cl
    10ce:	je     10e4 <botlish_fn_14+0x16c>
    10d4:	mov    edx,0x3
    10d9:	mov    rsi,r14
    10dc:	mov    rdi,r13
    10df:	call   10e4 <botlish_fn_14+0x16c>
			10e0: R_X86_64_PLT32	rt_int_add-0x4
    10e4:	mov    QWORD PTR [rsp+0x10],rax
    10e9:	mov    rcx,rbx
    10ec:	mov    r14,rax
    10ef:	jmp    fbd <botlish_fn_14+0x45>
    10f4:	add    BYTE PTR [rax],al
    10f6:	add    BYTE PTR [rax],al
    10f8:	(bad)
    10f9:	add    BYTE PTR [rax],al
    10fb:	add    BYTE PTR [rax],al
    10fd:	add    BYTE PTR [rax],al
	...

0000000000001100 <botlish_entry_14: scan_while<any, block(e239)>>:
    1100:	push   rbp
    1101:	mov    rbp,rsp
    1104:	mov    rsi,QWORD PTR [rdx]
    1107:	mov    r9,QWORD PTR [rdx+0x8]
    110b:	mov    rcx,QWORD PTR [rdx+0x10]
    110f:	mov    r8,QWORD PTR [rdx+0x18]
    1113:	mov    rdx,r9
    1116:	call   111b <botlish_entry_14+0x1b>
			1117: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<any, block(e239)>
    111b:	mov    rsp,rbp
    111e:	pop    rbp
    111f:	ret

0000000000001120 <botlish_fn_15: scan_while<any, native(is_tcl_alpha)>>:
    1120:	push   rbp
    1121:	mov    rbp,rsp
    1124:	sub    rsp,0x50
    1128:	mov    QWORD PTR [rsp+0x30],rbx
    112d:	mov    QWORD PTR [rsp+0x38],r12
    1132:	mov    QWORD PTR [rsp+0x40],r13
    1137:	mov    QWORD PTR [rsp+0x48],r14
    113c:	mov    rbx,rcx
    113f:	mov    r13,rdi
    1142:	mov    QWORD PTR [rsp+0x18],0x0
    114b:	mov    QWORD PTR [rsp],rcx
    114f:	mov    QWORD PTR [rsp+0x8],r8
    1154:	mov    r12,r8
    1157:	mov    QWORD PTR [rsp+0x10],rsi
    115c:	mov    rax,rsi
    115f:	mov    rcx,rbx
    1162:	mov    r14,rsi
    1165:	mov    rcx,rbx
    1168:	and    rax,rcx
    116b:	test   rax,0x1
    1171:	jne    119a <botlish_fn_15+0x7a>
    1177:	mov    rdx,rbx
    117a:	mov    rsi,r14
    117d:	mov    rdi,r13
    1180:	call   1185 <botlish_fn_15+0x65>
			1181: R_X86_64_PLT32	rt_int_cmp-0x4
    1185:	mov    ecx,0x2
    118a:	test   rax,rax
    118d:	cmovl  rcx,QWORD PTR [rip+0x11b]        # 12b0 <botlish_fn_15+0x190>
    1195:	jmp    11b0 <botlish_fn_15+0x90>
    119a:	mov    ecx,0x2
    119f:	mov    rax,r14
    11a2:	mov    rdx,rbx
    11a5:	cmp    rax,rdx
    11a8:	cmovl  rcx,QWORD PTR [rip+0x100]        # 12b0 <botlish_fn_15+0x190>
    11b0:	cmp    rcx,0x6
    11b4:	je     11da <botlish_fn_15+0xba>
    11ba:	mov    rax,rbx
    11bd:	mov    rbx,QWORD PTR [rsp+0x30]
    11c2:	mov    r12,QWORD PTR [rsp+0x38]
    11c7:	mov    r13,QWORD PTR [rsp+0x40]
    11cc:	mov    r14,QWORD PTR [rsp+0x48]
    11d1:	add    rsp,0x50
    11d5:	mov    rsp,rbp
    11d8:	pop    rbp
    11d9:	ret
    11da:	lea    rcx,[rsp+0x20]
    11df:	mov    rdx,r12
    11e2:	mov    rsi,r14
    11e5:	mov    rdi,r13
    11e8:	call   11ed <botlish_fn_15+0xcd>
			11e9: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    11ed:	test   rax,rax
    11f0:	mov    rsi,rax
    11f3:	je     1214 <botlish_fn_15+0xf4>
    11f9:	mov    rdx,QWORD PTR [rsp+0x20]
    11fe:	mov    rcx,QWORD PTR [rsp+0x28]
    1203:	mov    rdi,r13
    1206:	call   120b <botlish_fn_15+0xeb>
			1207: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    120b:	test   rax,rax
    120e:	jne    1234 <botlish_fn_15+0x114>
    1214:	xor    rax,rax
    1217:	mov    rbx,QWORD PTR [rsp+0x30]
    121c:	mov    r12,QWORD PTR [rsp+0x38]
    1221:	mov    r13,QWORD PTR [rsp+0x40]
    1226:	mov    r14,QWORD PTR [rsp+0x48]
    122b:	add    rsp,0x50
    122f:	mov    rsp,rbp
    1232:	pop    rbp
    1233:	ret
    1234:	cmp    rax,0x6
    1238:	je     125e <botlish_fn_15+0x13e>
    123e:	mov    rax,r14
    1241:	mov    rbx,QWORD PTR [rsp+0x30]
    1246:	mov    r12,QWORD PTR [rsp+0x38]
    124b:	mov    r13,QWORD PTR [rsp+0x40]
    1250:	mov    r14,QWORD PTR [rsp+0x48]
    1255:	add    rsp,0x50
    1259:	mov    rsp,rbp
    125c:	pop    rbp
    125d:	ret
    125e:	mov    QWORD PTR [rsp+0x18],0x3
    1267:	mov    rax,r14
    126a:	test   rax,0x1
    1270:	je     128b <botlish_fn_15+0x16b>
    1276:	mov    rcx,r14
    1279:	mov    rax,rcx
    127c:	add    rax,0x2
    1280:	seto   cl
    1283:	test   cl,cl
    1285:	je     129b <botlish_fn_15+0x17b>
    128b:	mov    edx,0x3
    1290:	mov    rsi,r14
    1293:	mov    rdi,r13
    1296:	call   129b <botlish_fn_15+0x17b>
			1297: R_X86_64_PLT32	rt_int_add-0x4
    129b:	mov    QWORD PTR [rsp+0x10],rax
    12a0:	mov    rcx,rbx
    12a3:	mov    r14,rax
    12a6:	jmp    1165 <botlish_fn_15+0x45>
    12ab:	add    BYTE PTR [rax],al
    12ad:	add    BYTE PTR [rax],al
    12af:	add    BYTE PTR [rsi],al
    12b1:	add    BYTE PTR [rax],al
    12b3:	add    BYTE PTR [rax],al
    12b5:	add    BYTE PTR [rax],al
	...

00000000000012b8 <botlish_entry_15: scan_while<any, native(is_tcl_alpha)>>:
    12b8:	push   rbp
    12b9:	mov    rbp,rsp
    12bc:	mov    rsi,QWORD PTR [rdx]
    12bf:	mov    r9,QWORD PTR [rdx+0x8]
    12c3:	mov    rcx,QWORD PTR [rdx+0x10]
    12c7:	mov    r8,QWORD PTR [rdx+0x18]
    12cb:	mov    rdx,r9
    12ce:	call   12d3 <botlish_entry_15+0x1b>
			12cf: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<any, native(is_tcl_alpha)>
    12d3:	mov    rsp,rbp
    12d6:	pop    rbp
    12d7:	ret

00000000000012d8 <botlish_fn_16: tld?<generic>>:
    12d8:	push   rbp
    12d9:	mov    rbp,rsp
    12dc:	sub    rsp,0x40
    12e0:	mov    QWORD PTR [rsp+0x20],rbx
    12e5:	mov    QWORD PTR [rsp+0x28],r12
    12ea:	mov    QWORD PTR [rsp+0x30],r13
    12ef:	mov    QWORD PTR [rsp+0x38],r14
    12f4:	mov    QWORD PTR [rsp],rsi
    12f8:	mov    r8,rsi
    12fb:	mov    QWORD PTR [rsp+0x8],rdx
    1300:	mov    r14,rdx
    1303:	mov    QWORD PTR [rsp+0x10],rcx
    1308:	mov    rax,QWORD PTR [rdi+0x10]
    130c:	mov    r12,rdi
    130f:	mov    rdx,QWORD PTR [rax+0xe0]
    1316:	mov    QWORD PTR [rsp+0x18],rdx
    131b:	mov    rbx,r8
    131e:	mov    r8,rcx
    1321:	mov    rcx,r14
    1324:	mov    rsi,rbx
    1327:	call   132c <botlish_fn_16+0x54>
			1328: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<any, native(is_tcl_alpha)>
    132c:	mov    rcx,rax
    132f:	mov    r13,rax
    1332:	test   rax,rcx
    1335:	jne    135b <botlish_fn_16+0x83>
    133b:	xor    rax,rax
    133e:	mov    rbx,QWORD PTR [rsp+0x20]
    1343:	mov    r12,QWORD PTR [rsp+0x28]
    1348:	mov    r13,QWORD PTR [rsp+0x30]
    134d:	mov    r14,QWORD PTR [rsp+0x38]
    1352:	add    rsp,0x40
    1356:	mov    rsp,rbp
    1359:	pop    rbp
    135a:	ret
    135b:	mov    rax,r13
    135e:	mov    QWORD PTR [rsp+0x8],rax
    1363:	mov    rdx,r14
    1366:	and    rax,rdx
    1369:	test   rax,0x1
    136f:	jne    1398 <botlish_fn_16+0xc0>
    1375:	mov    rsi,r13
    1378:	mov    rdi,r12
    137b:	call   1380 <botlish_fn_16+0xa8>
			137c: R_X86_64_PLT32	rt_int_cmp-0x4
    1380:	mov    ecx,0x2
    1385:	test   rax,rax
    1388:	cmove  rcx,QWORD PTR [rip+0xe0]        # 1470 <botlish_fn_16+0x198>
    1390:	mov    rax,r13
    1393:	jmp    13ab <botlish_fn_16+0xd3>
    1398:	mov    ecx,0x2
    139d:	mov    rax,r13
    13a0:	cmp    rax,rdx
    13a3:	cmove  rcx,QWORD PTR [rip+0xc5]        # 1470 <botlish_fn_16+0x198>
    13ab:	cmp    rcx,0x6
    13af:	je     13c2 <botlish_fn_16+0xea>
    13b5:	mov    ecx,0x2
    13ba:	mov    rax,rcx
    13bd:	jmp    144f <botlish_fn_16+0x177>
    13c2:	mov    rcx,rax
    13c5:	and    rcx,rbx
    13c8:	test   rcx,0x1
    13cf:	jne    13e0 <botlish_fn_16+0x108>
    13d5:	mov    rdx,rbx
    13d8:	mov    rsi,rax
    13db:	jmp    1401 <botlish_fn_16+0x129>
    13e0:	mov    rcx,rax
    13e3:	sub    rcx,rbx
    13e6:	mov    r8,rbx
    13e9:	mov    r13,rax
    13ec:	seto   al
    13ef:	lea    rsi,[rcx+0x1]
    13f3:	test   al,al
    13f5:	je     140c <botlish_fn_16+0x134>
    13fb:	mov    rdx,r8
    13fe:	mov    rsi,r13
    1401:	mov    rdi,r12
    1404:	call   1409 <botlish_fn_16+0x131>
			1405: R_X86_64_PLT32	rt_int_sub-0x4
    1409:	mov    rsi,rax
    140c:	test   rsi,0x1
    1413:	jne    143e <botlish_fn_16+0x166>
    1419:	mov    edx,0x5
    141e:	mov    rdi,r12
    1421:	call   1426 <botlish_fn_16+0x14e>
			1422: R_X86_64_PLT32	rt_int_cmp-0x4
    1426:	mov    ecx,0x2
    142b:	test   rax,rax
    142e:	mov    rax,rcx
    1431:	cmovge rax,QWORD PTR [rip+0x37]        # 1470 <botlish_fn_16+0x198>
    1439:	jmp    144f <botlish_fn_16+0x177>
    143e:	mov    eax,0x2
    1443:	cmp    rsi,0x5
    1447:	cmovge rax,QWORD PTR [rip+0x21]        # 1470 <botlish_fn_16+0x198>
    144f:	mov    rbx,QWORD PTR [rsp+0x20]
    1454:	mov    r12,QWORD PTR [rsp+0x28]
    1459:	mov    r13,QWORD PTR [rsp+0x30]
    145e:	mov    r14,QWORD PTR [rsp+0x38]
    1463:	add    rsp,0x40
    1467:	mov    rsp,rbp
    146a:	pop    rbp
    146b:	ret
    146c:	add    BYTE PTR [rax],al
    146e:	add    BYTE PTR [rax],al
    1470:	(bad)
    1471:	add    BYTE PTR [rax],al
    1473:	add    BYTE PTR [rax],al
    1475:	add    BYTE PTR [rax],al
	...

0000000000001478 <botlish_entry_16: tld?<generic>>:
    1478:	push   rbp
    1479:	mov    rbp,rsp
    147c:	mov    rsi,QWORD PTR [rdx]
    147f:	mov    r8,QWORD PTR [rdx+0x8]
    1483:	mov    rcx,QWORD PTR [rdx+0x10]
    1487:	mov    rdx,r8
    148a:	call   148f <botlish_entry_16+0x17>
			148b: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<generic>
    148f:	mov    rsp,rbp
    1492:	pop    rbp
    1493:	ret
    1494:	add    BYTE PTR [rax],al
	...

0000000000001498 <botlish_fn_17: domain?<generic>>:
    1498:	push   rbp
    1499:	mov    rbp,rsp
    149c:	sub    rsp,0xa0
    14a3:	mov    QWORD PTR [rsp+0x70],rbx
    14a8:	mov    QWORD PTR [rsp+0x78],r12
    14ad:	mov    QWORD PTR [rsp+0x80],r13
    14b5:	mov    QWORD PTR [rsp+0x88],r14
    14bd:	mov    QWORD PTR [rsp+0x90],r15
    14c5:	mov    r8,rdi
    14c8:	mov    QWORD PTR [rsp+0x20],0x0
    14d1:	mov    QWORD PTR [rsp],rsi
    14d5:	mov    QWORD PTR [rsp+0x8],rdx
    14da:	mov    QWORD PTR [rsp+0x10],rcx
    14df:	mov    r15,rcx
    14e2:	mov    QWORD PTR [rsp+0x18],rsi
    14e7:	mov    r12,rsi
    14ea:	mov    r14,rdx
    14ed:	mov    rdi,rsi
    14f0:	and    rdi,r14
    14f3:	mov    QWORD PTR [rsp+0x58],rsi
    14f8:	test   rdi,0x1
    14ff:	jne    152d <botlish_fn_17+0x95>
    1505:	mov    rbx,r8
    1508:	mov    rdx,r14
    150b:	mov    rsi,QWORD PTR [rsp+0x58]
    1510:	mov    rdi,rbx
    1513:	call   1518 <botlish_fn_17+0x80>
			1514: R_X86_64_PLT32	rt_int_cmp-0x4
    1518:	mov    ecx,0x2
    151d:	test   rax,rax
    1520:	cmovl  rcx,QWORD PTR [rip+0x358]        # 1880 <botlish_fn_17+0x3e8>
    1528:	jmp    1545 <botlish_fn_17+0xad>
    152d:	mov    rbx,r8
    1530:	mov    ecx,0x2
    1535:	mov    rsi,QWORD PTR [rsp+0x58]
    153a:	cmp    rsi,r14
    153d:	cmovl  rcx,QWORD PTR [rip+0x33b]        # 1880 <botlish_fn_17+0x3e8>
    1545:	cmp    rcx,0x6
    1549:	je     1582 <botlish_fn_17+0xea>
    154f:	mov    eax,0x2
    1554:	mov    rbx,QWORD PTR [rsp+0x70]
    1559:	mov    r12,QWORD PTR [rsp+0x78]
    155e:	mov    r13,QWORD PTR [rsp+0x80]
    1566:	mov    r14,QWORD PTR [rsp+0x88]
    156e:	mov    r15,QWORD PTR [rsp+0x90]
    1576:	add    rsp,0xa0
    157d:	mov    rsp,rbp
    1580:	pop    rbp
    1581:	ret
    1582:	lea    rcx,[rsp+0x28]
    1587:	mov    rdx,r15
    158a:	mov    rsi,QWORD PTR [rsp+0x58]
    158f:	mov    rdi,rbx
    1592:	call   1597 <botlish_fn_17+0xff>
			1593: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    1597:	test   rax,rax
    159a:	mov    rsi,rax
    159d:	je     1744 <botlish_fn_17+0x2ac>
    15a3:	mov    rdx,QWORD PTR [rsp+0x28]
    15a8:	mov    rcx,QWORD PTR [rsp+0x30]
    15ad:	mov    rax,QWORD PTR [rbx+0x10]
    15b1:	mov    r8,QWORD PTR [rax]
    15b4:	mov    rdi,rbx
    15b7:	call   15bc <botlish_fn_17+0x124>
			15b8: R_X86_64_PLT32	rt_str_region_eq-0x4
    15bc:	cmp    rax,0x6
    15c0:	je     16b1 <botlish_fn_17+0x219>
    15c6:	lea    rcx,[rsp+0x48]
    15cb:	mov    rdx,r15
    15ce:	mov    rsi,QWORD PTR [rsp+0x58]
    15d3:	mov    rdi,rbx
    15d6:	call   15db <botlish_fn_17+0x143>
			15d7: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    15db:	test   rax,rax
    15de:	mov    r13,rax
    15e1:	je     1744 <botlish_fn_17+0x2ac>
    15e7:	mov    rdx,QWORD PTR [rsp+0x48]
    15ec:	mov    QWORD PTR [rsp+0x68],rdx
    15f1:	mov    rcx,QWORD PTR [rsp+0x50]
    15f6:	mov    QWORD PTR [rsp+0x60],rcx
    15fb:	mov    rsi,r13
    15fe:	mov    rdi,rbx
    1601:	call   1606 <botlish_fn_17+0x16e>
			1602: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1606:	test   rax,rax
    1609:	je     1744 <botlish_fn_17+0x2ac>
    160f:	cmp    rax,0x6
    1613:	je     1654 <botlish_fn_17+0x1bc>
    1619:	mov    rax,QWORD PTR [rbx+0x10]
    161d:	mov    r8,QWORD PTR [rax+0x20]
    1621:	mov    rcx,QWORD PTR [rsp+0x60]
    1626:	mov    rdx,QWORD PTR [rsp+0x68]
    162b:	mov    rsi,r13
    162e:	mov    rdi,rbx
    1631:	call   1636 <botlish_fn_17+0x19e>
			1632: R_X86_64_PLT32	rt_str_region_eq-0x4
    1636:	cmp    rax,0x6
    163a:	je     164a <botlish_fn_17+0x1b2>
    1640:	mov    ecx,0x2
    1645:	jmp    1659 <botlish_fn_17+0x1c1>
    164a:	mov    ecx,0x6
    164f:	jmp    1659 <botlish_fn_17+0x1c1>
    1654:	mov    ecx,0x6
    1659:	cmp    rcx,0x6
    165d:	je     166e <botlish_fn_17+0x1d6>
    1663:	mov    r9d,0x6
    1669:	jmp    1674 <botlish_fn_17+0x1dc>
    166e:	mov    r9d,0x2
    1674:	cmp    r9,0x6
    1678:	jne    177f <botlish_fn_17+0x2e7>
    167e:	mov    eax,0x2
    1683:	mov    rbx,QWORD PTR [rsp+0x70]
    1688:	mov    r12,QWORD PTR [rsp+0x78]
    168d:	mov    r13,QWORD PTR [rsp+0x80]
    1695:	mov    r14,QWORD PTR [rsp+0x88]
    169d:	mov    r15,QWORD PTR [rsp+0x90]
    16a5:	add    rsp,0xa0
    16ac:	mov    rsp,rbp
    16af:	pop    rbp
    16b0:	ret
    16b1:	mov    rsi,QWORD PTR [rsp+0x58]
    16b6:	mov    r13,rsi
    16b9:	sar    r13,1
    16bc:	mov    rax,r12
    16bf:	sar    rax,1
    16c2:	cmp    r13,rax
    16c5:	je     184c <botlish_fn_17+0x3b4>
    16cb:	mov    rsi,r13
    16ce:	sub    rsi,0x1
    16d2:	shl    rsi,1
    16d5:	or     rsi,0x1
    16d9:	mov    QWORD PTR [rsp+0x20],rsi
    16de:	lea    rcx,[rsp+0x38]
    16e3:	mov    rdx,r15
    16e6:	mov    rdi,rbx
    16e9:	call   16ee <botlish_fn_17+0x256>
			16ea: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    16ee:	test   rax,rax
    16f1:	mov    rsi,rax
    16f4:	je     1744 <botlish_fn_17+0x2ac>
    16fa:	mov    rdx,QWORD PTR [rsp+0x38]
    16ff:	mov    rcx,QWORD PTR [rsp+0x40]
    1704:	mov    rax,QWORD PTR [rbx+0x10]
    1708:	mov    r8,QWORD PTR [rax]
    170b:	mov    rdi,rbx
    170e:	call   1713 <botlish_fn_17+0x27b>
			170f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1713:	cmp    rax,0x6
    1717:	je     1819 <botlish_fn_17+0x381>
    171d:	lea    rsi,[r13+0x1]
    1721:	shl    rsi,1
    1724:	or     rsi,0x1
    1728:	mov    QWORD PTR [rsp+0x20],rsi
    172d:	mov    rcx,r15
    1730:	mov    rdx,r14
    1733:	mov    rdi,rbx
    1736:	call   173b <botlish_fn_17+0x2a3>
			1737: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<generic>
    173b:	test   rax,rax
    173e:	jne    1775 <botlish_fn_17+0x2dd>
    1744:	xor    rax,rax
    1747:	mov    rbx,QWORD PTR [rsp+0x70]
    174c:	mov    r12,QWORD PTR [rsp+0x78]
    1751:	mov    r13,QWORD PTR [rsp+0x80]
    1759:	mov    r14,QWORD PTR [rsp+0x88]
    1761:	mov    r15,QWORD PTR [rsp+0x90]
    1769:	add    rsp,0xa0
    1770:	mov    rsp,rbp
    1773:	pop    rbp
    1774:	ret
    1775:	cmp    rax,0x6
    1779:	je     17e6 <botlish_fn_17+0x34e>
    177f:	mov    QWORD PTR [rsp+0x20],0x3
    1788:	mov    rsi,QWORD PTR [rsp+0x58]
    178d:	test   rsi,0x1
    1794:	je     17ba <botlish_fn_17+0x322>
    179a:	mov    rsi,QWORD PTR [rsp+0x58]
    179f:	add    rsi,0x2
    17a3:	seto   dil
    17a7:	test   dil,dil
    17aa:	jne    17ba <botlish_fn_17+0x322>
    17b0:	mov    QWORD PTR [rsp+0x58],rsi
    17b5:	jmp    17d4 <botlish_fn_17+0x33c>
    17ba:	mov    edx,0x3
    17bf:	mov    rsi,QWORD PTR [rsp+0x58]
    17c4:	mov    rdi,rbx
    17c7:	call   17cc <botlish_fn_17+0x334>
			17c8: R_X86_64_PLT32	rt_int_add-0x4
    17cc:	mov    rsi,rax
    17cf:	mov    QWORD PTR [rsp+0x58],rax
    17d4:	mov    QWORD PTR [rsp+0x18],rsi
    17d9:	mov    rsi,QWORD PTR [rsp+0x58]
    17de:	mov    r8,rbx
    17e1:	jmp    14ed <botlish_fn_17+0x55>
    17e6:	mov    eax,0x6
    17eb:	mov    rbx,QWORD PTR [rsp+0x70]
    17f0:	mov    r12,QWORD PTR [rsp+0x78]
    17f5:	mov    r13,QWORD PTR [rsp+0x80]
    17fd:	mov    r14,QWORD PTR [rsp+0x88]
    1805:	mov    r15,QWORD PTR [rsp+0x90]
    180d:	add    rsp,0xa0
    1814:	mov    rsp,rbp
    1817:	pop    rbp
    1818:	ret
    1819:	mov    eax,0x2
    181e:	mov    rbx,QWORD PTR [rsp+0x70]
    1823:	mov    r12,QWORD PTR [rsp+0x78]
    1828:	mov    r13,QWORD PTR [rsp+0x80]
    1830:	mov    r14,QWORD PTR [rsp+0x88]
    1838:	mov    r15,QWORD PTR [rsp+0x90]
    1840:	add    rsp,0xa0
    1847:	mov    rsp,rbp
    184a:	pop    rbp
    184b:	ret
    184c:	mov    eax,0x2
    1851:	mov    rbx,QWORD PTR [rsp+0x70]
    1856:	mov    r12,QWORD PTR [rsp+0x78]
    185b:	mov    r13,QWORD PTR [rsp+0x80]
    1863:	mov    r14,QWORD PTR [rsp+0x88]
    186b:	mov    r15,QWORD PTR [rsp+0x90]
    1873:	add    rsp,0xa0
    187a:	mov    rsp,rbp
    187d:	pop    rbp
    187e:	ret
    187f:	add    BYTE PTR [rsi],al
    1881:	add    BYTE PTR [rax],al
    1883:	add    BYTE PTR [rax],al
    1885:	add    BYTE PTR [rax],al
	...

0000000000001888 <botlish_entry_17: domain?<generic>>:
    1888:	push   rbp
    1889:	mov    rbp,rsp
    188c:	mov    rsi,QWORD PTR [rdx]
    188f:	mov    r8,QWORD PTR [rdx+0x8]
    1893:	mov    rcx,QWORD PTR [rdx+0x10]
    1897:	mov    rdx,r8
    189a:	call   189f <botlish_entry_17+0x17>
			189b: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<generic>
    189f:	mov    rsp,rbp
    18a2:	pop    rbp
    18a3:	ret

00000000000018a4 <botlish_fn_18: web::is_unreserved<int>>:
    18a4:	push   rbp
    18a5:	mov    rbp,rsp
    18a8:	sub    rsp,0x10
    18ac:	mov    QWORD PTR [rsp],rbx
    18b0:	mov    QWORD PTR [rsp+0x8],r14
    18b5:	mov    r14,rsi
    18b8:	mov    rsi,r14
    18bb:	sar    rsi,1
    18be:	mov    rbx,rdi
    18c1:	call   18c6 <botlish_fn_18+0x22>
			18c2: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
    18c6:	cmp    rax,0x6
    18ca:	je     1901 <botlish_fn_18+0x5d>
    18d0:	mov    rax,QWORD PTR [rbx+0x30]
    18d4:	mov    rsi,QWORD PTR [rax+0x10]
    18d8:	mov    rdx,r14
    18db:	mov    rdi,rbx
    18de:	call   18e3 <botlish_fn_18+0x3f>
			18df: R_X86_64_PLT32	rt_set_contains-0x4
    18e3:	cmp    rax,0x6
    18e7:	je     18f7 <botlish_fn_18+0x53>
    18ed:	mov    eax,0x2
    18f2:	jmp    1906 <botlish_fn_18+0x62>
    18f7:	mov    eax,0x6
    18fc:	jmp    1906 <botlish_fn_18+0x62>
    1901:	mov    eax,0x6
    1906:	mov    rbx,QWORD PTR [rsp]
    190a:	mov    r14,QWORD PTR [rsp+0x8]
    190f:	add    rsp,0x10
    1913:	mov    rsp,rbp
    1916:	pop    rbp
    1917:	ret

0000000000001918 <botlish_entry_18: web::is_unreserved<int>>:
    1918:	push   rbp
    1919:	mov    rbp,rsp
    191c:	mov    rsi,QWORD PTR [rdx]
    191f:	call   1924 <botlish_entry_18+0xc>
			1920: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1924:	mov    rsp,rbp
    1927:	pop    rbp
    1928:	ret

0000000000001929 <botlish_fn_19: web::uri_escape_text<str>>:
    1929:	push   rbp
    192a:	mov    rbp,rsp
    192d:	sub    rsp,0x20
    1931:	mov    QWORD PTR [rsp],rsi
    1935:	mov    edx,0x1
    193a:	mov    QWORD PTR [rsp+0x8],0x1
    1943:	mov    r11,QWORD PTR [rdi+0x10]
    1947:	mov    rcx,QWORD PTR [r11+0xe8]
    194e:	mov    QWORD PTR [rsp+0x10],rcx
    1953:	call   1958 <botlish_fn_19+0x2f>
			1954: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    1958:	test   rax,rax
    195b:	jne    196d <botlish_fn_19+0x44>
    1961:	xor    rax,rax
    1964:	add    rsp,0x20
    1968:	mov    rsp,rbp
    196b:	pop    rbp
    196c:	ret
    196d:	add    rsp,0x20
    1971:	mov    rsp,rbp
    1974:	pop    rbp
    1975:	ret

0000000000001976 <botlish_entry_19: web::uri_escape_text<str>>:
    1976:	push   rbp
    1977:	mov    rbp,rsp
    197a:	mov    rsi,QWORD PTR [rdx]
    197d:	call   1982 <botlish_entry_19+0xc>
			197e: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_escape_text<str>
    1982:	mov    rsp,rbp
    1985:	pop    rbp
    1986:	ret

0000000000001987 <botlish_fn_20: high_nibble<int>>:
    1987:	push   rbp
    1988:	mov    rbp,rsp
    198b:	sub    rsp,0x10
    198f:	mov    QWORD PTR [rsp],rsi
    1993:	mov    QWORD PTR [rsp+0x8],0x1e1
    199c:	test   rsi,0x1
    19a3:	jne    19b8 <botlish_fn_20+0x31>
    19a9:	mov    edx,0x1e1
    19ae:	call   19b3 <botlish_fn_20+0x2c>
			19af: R_X86_64_PLT32	rt_int_and-0x4
    19b3:	jmp    19c2 <botlish_fn_20+0x3b>
    19b8:	and    rsi,0x1e1
    19bf:	mov    rax,rsi
    19c2:	sar    rax,0x5
    19c6:	shl    rax,1
    19c9:	or     rax,0x1
    19cd:	add    rsp,0x10
    19d1:	mov    rsp,rbp
    19d4:	pop    rbp
    19d5:	ret

00000000000019d6 <botlish_entry_20: high_nibble<int>>:
    19d6:	push   rbp
    19d7:	mov    rbp,rsp
    19da:	mov    rsi,QWORD PTR [rdx]
    19dd:	call   19e2 <botlish_entry_20+0xc>
			19de: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    19e2:	mov    rsp,rbp
    19e5:	pop    rbp
    19e6:	ret

00000000000019e7 <botlish_fn_21: hex_pair<int>>:
    19e7:	push   rbp
    19e8:	mov    rbp,rsp
    19eb:	sub    rsp,0x50
    19ef:	mov    QWORD PTR [rsp+0x30],rbx
    19f4:	mov    QWORD PTR [rsp+0x38],r12
    19f9:	mov    QWORD PTR [rsp+0x40],r13
    19fe:	mov    QWORD PTR [rsp+0x48],r14
    1a03:	mov    QWORD PTR [rsp],rsi
    1a07:	mov    r12,rsi
    1a0a:	mov    rax,QWORD PTR [rdi+0x30]
    1a0e:	mov    rbx,rdi
    1a11:	mov    rsi,QWORD PTR [rax+0x8]
    1a15:	mov    QWORD PTR [rsp+0x8],rsi
    1a1a:	mov    r13,rsi
    1a1d:	mov    rsi,r12
    1a20:	call   1a25 <botlish_fn_21+0x3e>
			1a21: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    1a25:	test   rax,0x1
    1a2b:	jne    1a3c <botlish_fn_21+0x55>
    1a31:	mov    rdx,rax
    1a34:	mov    rsi,r13
    1a37:	jmp    1a55 <botlish_fn_21+0x6e>
    1a3c:	mov    rsi,r13
    1a3f:	mov    rdx,QWORD PTR [rsi+0x8]
    1a43:	mov    rcx,rax
    1a46:	sar    rcx,1
    1a49:	cmp    rcx,rdx
    1a4c:	jb     1a6b <botlish_fn_21+0x84>
    1a52:	mov    rdx,rax
    1a55:	mov    rdi,rbx
    1a58:	call   1a5d <botlish_fn_21+0x76>
			1a59: R_X86_64_PLT32	rt_list_get-0x4
    1a5d:	test   rax,rax
    1a60:	je     1b30 <botlish_fn_21+0x149>
    1a66:	jmp    1a73 <botlish_fn_21+0x8c>
    1a6b:	mov    rax,QWORD PTR [rsi+0x10]
    1a6f:	mov    rax,QWORD PTR [rax+rcx*8]
    1a73:	mov    QWORD PTR [rsp],rax
    1a77:	mov    rdi,rbx
    1a7a:	mov    r14,rax
    1a7d:	mov    rax,QWORD PTR [rdi+0x30]
    1a81:	mov    rsi,QWORD PTR [rax+0x8]
    1a85:	mov    r13,rsi
    1a88:	mov    edx,0x21
    1a8d:	mov    rsi,r12
    1a90:	call   1a95 <botlish_fn_21+0xae>
			1a91: R_X86_64_PLT32	rt_int_mod-0x4
    1a95:	test   rax,rax
    1a98:	je     1b30 <botlish_fn_21+0x149>
    1a9e:	test   rax,0x1
    1aa4:	jne    1ab5 <botlish_fn_21+0xce>
    1aaa:	mov    rdx,rax
    1aad:	mov    rsi,r13
    1ab0:	jmp    1ace <botlish_fn_21+0xe7>
    1ab5:	mov    rsi,r13
    1ab8:	mov    rdx,QWORD PTR [rsi+0x8]
    1abc:	mov    rcx,rax
    1abf:	sar    rcx,1
    1ac2:	cmp    rcx,rdx
    1ac5:	jb     1ae4 <botlish_fn_21+0xfd>
    1acb:	mov    rdx,rax
    1ace:	mov    rdi,rbx
    1ad1:	call   1ad6 <botlish_fn_21+0xef>
			1ad2: R_X86_64_PLT32	rt_list_get-0x4
    1ad6:	test   rax,rax
    1ad9:	je     1b30 <botlish_fn_21+0x149>
    1adf:	jmp    1aec <botlish_fn_21+0x105>
    1ae4:	mov    rax,QWORD PTR [rsi+0x10]
    1ae8:	mov    rax,QWORD PTR [rax+rcx*8]
    1aec:	mov    QWORD PTR [rsp+0x8],rax
    1af1:	lea    rcx,[rsp+0x10]
    1af6:	mov    QWORD PTR [rsp+0x10],0x0
    1aff:	mov    rdx,r14
    1b02:	mov    QWORD PTR [rsp+0x18],rdx
    1b07:	mov    QWORD PTR [rsp+0x20],0x0
    1b10:	mov    QWORD PTR [rsp+0x28],rax
    1b15:	mov    esi,0x2
    1b1a:	mov    edx,0x4
    1b1f:	mov    rdi,rbx
    1b22:	call   1b27 <botlish_fn_21+0x140>
			1b23: R_X86_64_PLT32	rt_construct-0x4
    1b27:	test   rax,rax
    1b2a:	jne    1b50 <botlish_fn_21+0x169>
    1b30:	xor    rax,rax
    1b33:	mov    rbx,QWORD PTR [rsp+0x30]
    1b38:	mov    r12,QWORD PTR [rsp+0x38]
    1b3d:	mov    r13,QWORD PTR [rsp+0x40]
    1b42:	mov    r14,QWORD PTR [rsp+0x48]
    1b47:	add    rsp,0x50
    1b4b:	mov    rsp,rbp
    1b4e:	pop    rbp
    1b4f:	ret
    1b50:	mov    rbx,QWORD PTR [rsp+0x30]
    1b55:	mov    r12,QWORD PTR [rsp+0x38]
    1b5a:	mov    r13,QWORD PTR [rsp+0x40]
    1b5f:	mov    r14,QWORD PTR [rsp+0x48]
    1b64:	add    rsp,0x50
    1b68:	mov    rsp,rbp
    1b6b:	pop    rbp
    1b6c:	ret

0000000000001b6d <botlish_entry_21: hex_pair<int>>:
    1b6d:	push   rbp
    1b6e:	mov    rbp,rsp
    1b71:	sub    rsp,0x10
    1b75:	mov    QWORD PTR [rsp],r12
    1b79:	mov    r12,rdi
    1b7c:	mov    rsi,QWORD PTR [rdx]
    1b7f:	call   1b84 <botlish_entry_21+0x17>
			1b80: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1b84:	mov    r8,QWORD PTR [rip+0x0]        # 1b8b <botlish_entry_21+0x1e>
			1b87: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1b8b:	mov    rsi,rax
    1b8e:	mov    rdi,r12
    1b91:	call   r8
    1b94:	mov    r12,QWORD PTR [rsp]
    1b98:	add    rsp,0x10
    1b9c:	mov    rsp,rbp
    1b9f:	pop    rbp
    1ba0:	ret

0000000000001ba1 <botlish_fn_22: esc_bytes<List[int], int, str>>:
    1ba1:	push   rbp
    1ba2:	mov    rbp,rsp
    1ba5:	sub    rsp,0x90
    1bac:	mov    QWORD PTR [rsp+0x60],rbx
    1bb1:	mov    QWORD PTR [rsp+0x68],r12
    1bb6:	mov    QWORD PTR [rsp+0x70],r13
    1bbb:	mov    QWORD PTR [rsp+0x78],r14
    1bc0:	mov    QWORD PTR [rsp+0x80],r15
    1bc8:	mov    QWORD PTR [rsp],rsi
    1bcc:	mov    QWORD PTR [rsp+0x8],rcx
    1bd1:	sar    rdx,1
    1bd4:	mov    r13,rdx
    1bd7:	lea    r14,[rsp+0x20]
    1bdc:	mov    rbx,rdi
    1bdf:	mov    r12,rsi
    1be2:	mov    QWORD PTR [rsp+0x50],rcx
    1be7:	mov    rsi,r12
    1bea:	mov    rdi,rbx
    1bed:	call   1bf2 <botlish_fn_22+0x51>
			1bee: R_X86_64_PLT32	rt_list_len-0x4
    1bf2:	sar    rax,1
    1bf5:	cmp    r13,rax
    1bf8:	jge    1d08 <botlish_fn_22+0x167>
    1bfe:	mov    rax,QWORD PTR [rbx+0x10]
    1c02:	mov    r15,QWORD PTR [rax+0x10]
    1c06:	mov    QWORD PTR [rsp+0x10],r15
    1c0b:	mov    rcx,QWORD PTR [r12+0x8]
    1c10:	mov    rax,r13
    1c13:	shl    rax,1
    1c16:	or     rax,0x1
    1c1a:	sar    rax,1
    1c1d:	cmp    rax,rcx
    1c20:	jb     1c4c <botlish_fn_22+0xab>
    1c26:	mov    rdx,r13
    1c29:	shl    rdx,1
    1c2c:	or     rdx,0x1
    1c30:	mov    rsi,r12
    1c33:	mov    rdi,rbx
    1c36:	call   1c3b <botlish_fn_22+0x9a>
			1c37: R_X86_64_PLT32	rt_list_get-0x4
    1c3b:	test   rax,rax
    1c3e:	je     1cc3 <botlish_fn_22+0x122>
    1c44:	mov    rsi,rax
    1c47:	jmp    1c55 <botlish_fn_22+0xb4>
    1c4c:	mov    rcx,QWORD PTR [r12+0x10]
    1c51:	mov    rsi,QWORD PTR [rcx+rax*8]
    1c55:	mov    QWORD PTR [rsp+0x18],rsi
    1c5a:	mov    rdi,rbx
    1c5d:	call   1c62 <botlish_fn_22+0xc1>
			1c5e: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1c62:	test   rax,rax
    1c65:	je     1cc3 <botlish_fn_22+0x122>
    1c6b:	mov    QWORD PTR [rsp+0x18],rax
    1c70:	mov    rcx,rax
    1c73:	mov    QWORD PTR [rsp+0x20],0x0
    1c7c:	mov    rax,QWORD PTR [rsp+0x50]
    1c81:	mov    QWORD PTR [rsp+0x28],rax
    1c86:	mov    QWORD PTR [rsp+0x30],0x0
    1c8f:	mov    QWORD PTR [rsp+0x38],r15
    1c94:	mov    QWORD PTR [rsp+0x40],0x0
    1c9d:	mov    rax,rcx
    1ca0:	mov    QWORD PTR [rsp+0x48],rax
    1ca5:	mov    esi,0x2
    1caa:	mov    edx,0x6
    1caf:	mov    rcx,r14
    1cb2:	mov    rdi,rbx
    1cb5:	call   1cba <botlish_fn_22+0x119>
			1cb6: R_X86_64_PLT32	rt_construct-0x4
    1cba:	test   rax,rax
    1cbd:	jne    1cee <botlish_fn_22+0x14d>
    1cc3:	xor    rax,rax
    1cc6:	mov    rbx,QWORD PTR [rsp+0x60]
    1ccb:	mov    r12,QWORD PTR [rsp+0x68]
    1cd0:	mov    r13,QWORD PTR [rsp+0x70]
    1cd5:	mov    r14,QWORD PTR [rsp+0x78]
    1cda:	mov    r15,QWORD PTR [rsp+0x80]
    1ce2:	add    rsp,0x90
    1ce9:	mov    rsp,rbp
    1cec:	pop    rbp
    1ced:	ret
    1cee:	mov    QWORD PTR [rsp],r12
    1cf2:	mov    QWORD PTR [rsp+0x8],rax
    1cf7:	add    r13,0x1
    1cfe:	mov    QWORD PTR [rsp+0x50],rax
    1d03:	jmp    1be7 <botlish_fn_22+0x46>
    1d08:	mov    rax,QWORD PTR [rsp+0x50]
    1d0d:	mov    rbx,QWORD PTR [rsp+0x60]
    1d12:	mov    r12,QWORD PTR [rsp+0x68]
    1d17:	mov    r13,QWORD PTR [rsp+0x70]
    1d1c:	mov    r14,QWORD PTR [rsp+0x78]
    1d21:	mov    r15,QWORD PTR [rsp+0x80]
    1d29:	add    rsp,0x90
    1d30:	mov    rsp,rbp
    1d33:	pop    rbp
    1d34:	ret

0000000000001d35 <botlish_entry_22: esc_bytes<List[int], int, str>>:
    1d35:	push   rbp
    1d36:	mov    rbp,rsp
    1d39:	sub    rsp,0x10
    1d3d:	mov    QWORD PTR [rsp],r12
    1d41:	mov    r12,rdi
    1d44:	mov    rsi,QWORD PTR [rdx]
    1d47:	mov    r8,QWORD PTR [rdx+0x8]
    1d4b:	mov    rcx,QWORD PTR [rdx+0x10]
    1d4f:	mov    rdx,r8
    1d52:	call   1d57 <botlish_entry_22+0x22>
			1d53: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1d57:	mov    r8,QWORD PTR [rip+0x0]        # 1d5e <botlish_entry_22+0x29>
			1d5a: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1d5e:	mov    rsi,rax
    1d61:	mov    rdi,r12
    1d64:	call   r8
    1d67:	mov    r12,QWORD PTR [rsp]
    1d6b:	add    rsp,0x10
    1d6f:	mov    rsp,rbp
    1d72:	pop    rbp
    1d73:	ret

0000000000001d74 <botlish_fn_23: esc_char<str>>:
    1d74:	push   rbp
    1d75:	mov    rbp,rsp
    1d78:	sub    rsp,0x40
    1d7c:	mov    QWORD PTR [rsp+0x20],rbx
    1d81:	mov    QWORD PTR [rsp+0x28],r12
    1d86:	mov    QWORD PTR [rsp+0x30],r13
    1d8b:	mov    rbx,rdi
    1d8e:	mov    QWORD PTR [rsp+0x8],0x0
    1d97:	mov    QWORD PTR [rsp+0x10],0x0
    1da0:	mov    QWORD PTR [rsp],rsi
    1da4:	mov    r13,rsi
    1da7:	mov    rsi,r13
    1daa:	mov    rdi,rbx
    1dad:	call   1db2 <botlish_fn_23+0x3e>
			1dae: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1db2:	mov    rcx,rax
    1db5:	mov    r12,rax
    1db8:	test   rax,rcx
    1dbb:	je     1e99 <botlish_fn_23+0x125>
    1dc1:	mov    rax,r12
    1dc4:	mov    QWORD PTR [rsp],rax
    1dc8:	mov    rsi,r12
    1dcb:	mov    rdi,rbx
    1dce:	call   1dd3 <botlish_fn_23+0x5f>
			1dcf: R_X86_64_PLT32	rt_list_len-0x4
    1dd3:	sar    rax,1
    1dd6:	cmp    rax,0x1
    1dda:	je     1e17 <botlish_fn_23+0xa3>
    1de0:	mov    edx,0x1
    1de5:	mov    QWORD PTR [rsp+0x8],0x1
    1dee:	mov    rdi,rbx
    1df1:	mov    rax,QWORD PTR [rdi+0x10]
    1df5:	mov    rcx,QWORD PTR [rax+0xe8]
    1dfc:	mov    QWORD PTR [rsp+0x10],rcx
    1e01:	mov    rsi,r12
    1e04:	call   1e09 <botlish_fn_23+0x95>
			1e05: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1e09:	test   rax,rax
    1e0c:	je     1e99 <botlish_fn_23+0x125>
    1e12:	jmp    1eba <botlish_fn_23+0x146>
    1e17:	mov    rsi,r12
    1e1a:	mov    rax,QWORD PTR [rsi+0x8]
    1e1e:	mov    r12,rsi
    1e21:	test   rax,rax
    1e24:	jne    1e4b <botlish_fn_23+0xd7>
    1e2a:	mov    edx,0x1
    1e2f:	mov    rsi,r12
    1e32:	mov    rdi,rbx
    1e35:	call   1e3a <botlish_fn_23+0xc6>
			1e36: R_X86_64_PLT32	rt_list_get-0x4
    1e3a:	test   rax,rax
    1e3d:	je     1e99 <botlish_fn_23+0x125>
    1e43:	mov    rsi,rax
    1e46:	jmp    1e55 <botlish_fn_23+0xe1>
    1e4b:	mov    rsi,r12
    1e4e:	mov    rax,QWORD PTR [rsi+0x10]
    1e52:	mov    rsi,QWORD PTR [rax]
    1e55:	mov    rdi,rbx
    1e58:	call   1e5d <botlish_fn_23+0xe9>
			1e59: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1e5d:	cmp    rax,0x6
    1e61:	je     1eb7 <botlish_fn_23+0x143>
    1e67:	mov    edx,0x1
    1e6c:	mov    QWORD PTR [rsp+0x8],0x1
    1e75:	mov    rdi,rbx
    1e78:	mov    rax,QWORD PTR [rdi+0x10]
    1e7c:	mov    rcx,QWORD PTR [rax+0xe8]
    1e83:	mov    QWORD PTR [rsp+0x10],rcx
    1e88:	mov    rsi,r12
    1e8b:	call   1e90 <botlish_fn_23+0x11c>
			1e8c: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1e90:	test   rax,rax
    1e93:	jne    1eb4 <botlish_fn_23+0x140>
    1e99:	xor    rax,rax
    1e9c:	mov    rbx,QWORD PTR [rsp+0x20]
    1ea1:	mov    r12,QWORD PTR [rsp+0x28]
    1ea6:	mov    r13,QWORD PTR [rsp+0x30]
    1eab:	add    rsp,0x40
    1eaf:	mov    rsp,rbp
    1eb2:	pop    rbp
    1eb3:	ret
    1eb4:	mov    r13,rax
    1eb7:	mov    rax,r13
    1eba:	mov    rbx,QWORD PTR [rsp+0x20]
    1ebf:	mov    r12,QWORD PTR [rsp+0x28]
    1ec4:	mov    r13,QWORD PTR [rsp+0x30]
    1ec9:	add    rsp,0x40
    1ecd:	mov    rsp,rbp
    1ed0:	pop    rbp
    1ed1:	ret

0000000000001ed2 <botlish_entry_23: esc_char<str>>:
    1ed2:	push   rbp
    1ed3:	mov    rbp,rsp
    1ed6:	sub    rsp,0x10
    1eda:	mov    QWORD PTR [rsp],r12
    1ede:	mov    r12,rdi
    1ee1:	mov    rsi,QWORD PTR [rdx]
    1ee4:	call   1ee9 <botlish_entry_23+0x17>
			1ee5: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1ee9:	mov    r8,QWORD PTR [rip+0x0]        # 1ef0 <botlish_entry_23+0x1e>
			1eec: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1ef0:	mov    rsi,rax
    1ef3:	mov    rdi,r12
    1ef6:	call   r8
    1ef9:	mov    r12,QWORD PTR [rsp]
    1efd:	add    rsp,0x10
    1f01:	mov    rsp,rbp
    1f04:	pop    rbp
    1f05:	ret

0000000000001f06 <botlish_fn_24: esc_from<str, int, str>>:
    1f06:	push   rbp
    1f07:	mov    rbp,rsp
    1f0a:	sub    rsp,0x80
    1f11:	mov    QWORD PTR [rsp+0x50],rbx
    1f16:	mov    QWORD PTR [rsp+0x58],r12
    1f1b:	mov    QWORD PTR [rsp+0x60],r13
    1f20:	mov    QWORD PTR [rsp+0x68],r14
    1f25:	mov    QWORD PTR [rsp+0x70],r15
    1f2a:	mov    r14,rdi
    1f2d:	mov    QWORD PTR [rsp+0x10],0x0
    1f36:	mov    QWORD PTR [rsp+0x18],0x0
    1f3f:	mov    QWORD PTR [rsp],rsi
    1f43:	mov    QWORD PTR [rsp+0x8],rcx
    1f48:	mov    r15,rcx
    1f4b:	sar    rdx,1
    1f4e:	mov    r12,rdx
    1f51:	lea    r13,[rsp+0x30]
    1f56:	mov    rbx,rsi
    1f59:	mov    rsi,rbx
    1f5c:	mov    rdi,r14
    1f5f:	call   1f64 <botlish_fn_24+0x5e>
			1f60: R_X86_64_PLT32	rt_str_len-0x4
    1f64:	sar    rax,1
    1f67:	cmp    r12,rax
    1f6a:	jge    2015 <botlish_fn_24+0x10f>
    1f70:	mov    rdx,r12
    1f73:	shl    rdx,1
    1f76:	or     rdx,0x1
    1f7a:	mov    QWORD PTR [rsp+0x10],rdx
    1f7f:	add    r12,0x1
    1f86:	mov    rcx,r12
    1f89:	shl    rcx,1
    1f8c:	or     rcx,0x1
    1f90:	mov    QWORD PTR [rsp+0x18],rcx
    1f95:	mov    rsi,rbx
    1f98:	mov    rdi,r14
    1f9b:	call   1fa0 <botlish_fn_24+0x9a>
			1f9c: R_X86_64_PLT32	rt_substr-0x4
    1fa0:	test   rax,rax
    1fa3:	je     2047 <botlish_fn_24+0x141>
    1fa9:	mov    QWORD PTR [rsp+0x10],rax
    1fae:	mov    rsi,rax
    1fb1:	mov    rdi,r14
    1fb4:	call   1fb9 <botlish_fn_24+0xb3>
			1fb5: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1fb9:	test   rax,rax
    1fbc:	je     2047 <botlish_fn_24+0x141>
    1fc2:	mov    QWORD PTR [rsp+0x10],rax
    1fc7:	mov    QWORD PTR [rsp+0x30],0x0
    1fd0:	mov    rcx,r15
    1fd3:	mov    QWORD PTR [rsp+0x38],rcx
    1fd8:	mov    QWORD PTR [rsp+0x40],0x0
    1fe1:	mov    QWORD PTR [rsp+0x48],rax
    1fe6:	mov    esi,0x2
    1feb:	mov    edx,0x4
    1ff0:	mov    rcx,r13
    1ff3:	mov    rdi,r14
    1ff6:	call   1ffb <botlish_fn_24+0xf5>
			1ff7: R_X86_64_PLT32	rt_construct-0x4
    1ffb:	test   rax,rax
    1ffe:	je     2047 <botlish_fn_24+0x141>
    2004:	mov    QWORD PTR [rsp],rbx
    2008:	mov    QWORD PTR [rsp+0x8],rax
    200d:	mov    r15,rax
    2010:	jmp    1f59 <botlish_fn_24+0x53>
    2015:	mov    rcx,r15
    2018:	xor    rsi,rsi
    201b:	lea    rax,[rsp+0x20]
    2020:	mov    QWORD PTR [rsp+0x20],0x0
    2029:	mov    QWORD PTR [rsp+0x28],rcx
    202e:	mov    edx,0x2
    2033:	mov    rcx,rax
    2036:	mov    rdi,r14
    2039:	call   203e <botlish_fn_24+0x138>
			203a: R_X86_64_PLT32	rt_construct-0x4
    203e:	test   rax,rax
    2041:	jne    206f <botlish_fn_24+0x169>
    2047:	xor    rax,rax
    204a:	mov    rbx,QWORD PTR [rsp+0x50]
    204f:	mov    r12,QWORD PTR [rsp+0x58]
    2054:	mov    r13,QWORD PTR [rsp+0x60]
    2059:	mov    r14,QWORD PTR [rsp+0x68]
    205e:	mov    r15,QWORD PTR [rsp+0x70]
    2063:	add    rsp,0x80
    206a:	mov    rsp,rbp
    206d:	pop    rbp
    206e:	ret
    206f:	mov    rbx,QWORD PTR [rsp+0x50]
    2074:	mov    r12,QWORD PTR [rsp+0x58]
    2079:	mov    r13,QWORD PTR [rsp+0x60]
    207e:	mov    r14,QWORD PTR [rsp+0x68]
    2083:	mov    r15,QWORD PTR [rsp+0x70]
    2088:	add    rsp,0x80
    208f:	mov    rsp,rbp
    2092:	pop    rbp
    2093:	ret

0000000000002094 <botlish_entry_24: esc_from<str, int, str>>:
    2094:	push   rbp
    2095:	mov    rbp,rsp
    2098:	mov    rsi,QWORD PTR [rdx]
    209b:	mov    r8,QWORD PTR [rdx+0x8]
    209f:	mov    rcx,QWORD PTR [rdx+0x10]
    20a3:	mov    rdx,r8
    20a6:	call   20ab <botlish_entry_24+0x17>
			20a7: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    20ab:	mov    rsp,rbp
    20ae:	pop    rbp
    20af:	ret

00000000000020b0 <botlish_fn_25: check<int, int, str, str>>:
    20b0:	push   rbp
    20b1:	mov    rbp,rsp
    20b4:	sub    rsp,0x50
    20b8:	mov    QWORD PTR [rsp+0x20],rbx
    20bd:	mov    QWORD PTR [rsp+0x28],r12
    20c2:	mov    QWORD PTR [rsp+0x30],r13
    20c7:	mov    QWORD PTR [rsp+0x38],r14
    20cc:	mov    QWORD PTR [rsp+0x40],r15
    20d1:	mov    r14,rdi
    20d4:	mov    QWORD PTR [rsp+0x18],0x0
    20dd:	mov    QWORD PTR [rsp],rdx
    20e1:	mov    QWORD PTR [rsp+0x8],rcx
    20e6:	mov    QWORD PTR [rsp+0x10],r8
    20eb:	mov    r13,r8
    20ee:	mov    r12,rsi
    20f1:	mov    r15,rdx
    20f4:	test   r12,r12
    20f7:	jle    21b9 <botlish_fn_25+0x109>
    20fd:	mov    rbx,rcx
    2100:	mov    rsi,rbx
    2103:	mov    rdi,r14
    2106:	call   210b <botlish_fn_25+0x5b>
			2107: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
    210b:	test   rax,rax
    210e:	jne    2139 <botlish_fn_25+0x89>
    2114:	xor    rax,rax
    2117:	mov    rbx,QWORD PTR [rsp+0x20]
    211c:	mov    r12,QWORD PTR [rsp+0x28]
    2121:	mov    r13,QWORD PTR [rsp+0x30]
    2126:	mov    r14,QWORD PTR [rsp+0x38]
    212b:	mov    r15,QWORD PTR [rsp+0x40]
    2130:	add    rsp,0x50
    2134:	mov    rsp,rbp
    2137:	pop    rbp
    2138:	ret
    2139:	cmp    rax,0x6
    213d:	je     2159 <botlish_fn_25+0xa9>
    2143:	mov    edx,0x1
    2148:	mov    QWORD PTR [rsp+0x18],0x1
    2151:	mov    rsi,r15
    2154:	jmp    216a <botlish_fn_25+0xba>
    2159:	mov    edx,0x3
    215e:	mov    QWORD PTR [rsp+0x18],0x3
    2167:	mov    rsi,r15
    216a:	mov    rax,rsi
    216d:	and    rax,rdx
    2170:	test   rax,0x1
    2176:	je     2191 <botlish_fn_25+0xe1>
    217c:	lea    rcx,[rdx-0x1]
    2180:	mov    rax,rsi
    2183:	add    rax,rcx
    2186:	seto   cl
    2189:	test   cl,cl
    218b:	je     2199 <botlish_fn_25+0xe9>
    2191:	mov    rdi,r14
    2194:	call   2199 <botlish_fn_25+0xe9>
			2195: R_X86_64_PLT32	rt_int_add-0x4
    2199:	mov    QWORD PTR [rsp],rax
    219d:	mov    QWORD PTR [rsp+0x8],rbx
    21a2:	mov    r8,r13
    21a5:	mov    QWORD PTR [rsp+0x10],r8
    21aa:	sub    r12,0x1
    21ae:	mov    rcx,rbx
    21b1:	mov    r15,rax
    21b4:	jmp    20f4 <botlish_fn_25+0x44>
    21b9:	mov    rax,r15
    21bc:	mov    rbx,QWORD PTR [rsp+0x20]
    21c1:	mov    r12,QWORD PTR [rsp+0x28]
    21c6:	mov    r13,QWORD PTR [rsp+0x30]
    21cb:	mov    r14,QWORD PTR [rsp+0x38]
    21d0:	mov    r15,QWORD PTR [rsp+0x40]
    21d5:	add    rsp,0x50
    21d9:	mov    rsp,rbp
    21dc:	pop    rbp
    21dd:	ret

00000000000021de <botlish_entry_25: check<int, int, str, str>>:
    21de:	push   rbp
    21df:	mov    rbp,rsp
    21e2:	mov    rsi,QWORD PTR [rdx]
    21e5:	mov    r9,QWORD PTR [rdx+0x8]
    21e9:	mov    rcx,QWORD PTR [rdx+0x10]
    21ed:	mov    r8,QWORD PTR [rdx+0x18]
    21f1:	sar    rsi,1
    21f4:	mov    rdx,r9
    21f7:	call   21fc <botlish_entry_25+0x1e>
			21f8: R_X86_64_PLT32	botlish_fn_25-0x4 ; check<int, int, str, str>
    21fc:	mov    rsp,rbp
    21ff:	pop    rbp
    2200:	ret

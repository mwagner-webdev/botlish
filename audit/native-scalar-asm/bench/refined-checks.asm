; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 9191  (per function: 1415 39 289 609 74 74 74 128 128 379 262 222 176 238 440 456 468 1076 140 127 103 474 491 426 539 344)
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
     122:	je     4e8 <botlish_fn_0+0x4e8>
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
     366:	je     4e8 <botlish_fn_0+0x4e8>
     36c:	mov    rdi,QWORD PTR [rsp+0x158]
     374:	mov    r10,QWORD PTR [rdi+0x30]
     378:	mov    QWORD PTR [r10+0x8],rax
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
     3e4:	je     4e8 <botlish_fn_0+0x4e8>
     3ea:	mov    QWORD PTR [rsp],rax
     3ee:	mov    rsi,rax
     3f1:	mov    rdi,QWORD PTR [rsp+0x158]
     3f9:	call   3fe <botlish_fn_0+0x3fe>
			3fa: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::set<List[UnicodeChar]>
     3fe:	test   rax,rax
     401:	je     4e8 <botlish_fn_0+0x4e8>
     407:	mov    rdi,QWORD PTR [rsp+0x158]
     40f:	mov    rcx,QWORD PTR [rdi+0x30]
     413:	mov    QWORD PTR [rcx+0x10],rax
     417:	mov    esi,0xe2a0e1
     41c:	call   421 <botlish_fn_0+0x421>
			41d: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_escape_text<str>
     421:	test   rax,rax
     424:	je     4e8 <botlish_fn_0+0x4e8>
     42a:	mov    QWORD PTR [rsp],rax
     42e:	mov    rbx,rax
     431:	mov    edx,0x1
     436:	mov    QWORD PTR [rsp+0x8],0x1
     43f:	mov    rdi,QWORD PTR [rsp+0x158]
     447:	mov    rcx,QWORD PTR [rdi+0x10]
     44b:	mov    rcx,QWORD PTR [rcx+0xa8]
     452:	mov    QWORD PTR [rsp+0x10],rcx
     457:	mov    esi,0x190
     45c:	mov    r8,rbx
     45f:	call   464 <botlish_fn_0+0x464>
			460: R_X86_64_PLT32	botlish_fn_25-0x4 ; check<int, int, str, str>
     464:	mov    r12,rax
     467:	test   r12,r12
     46a:	je     4e8 <botlish_fn_0+0x4e8>
     470:	mov    QWORD PTR [rsp+0x8],r12
     475:	mov    edx,0x1
     47a:	mov    QWORD PTR [rsp+0x10],0x1
     483:	mov    rdi,QWORD PTR [rsp+0x158]
     48b:	mov    rax,QWORD PTR [rdi+0x10]
     48f:	mov    rcx,QWORD PTR [rax+0xb0]
     496:	mov    QWORD PTR [rsp+0x18],rcx
     49b:	mov    esi,0x190
     4a0:	mov    r8,rbx
     4a3:	call   4a8 <botlish_fn_0+0x4a8>
			4a4: R_X86_64_PLT32	botlish_fn_25-0x4 ; check<int, int, str, str>
     4a8:	test   rax,rax
     4ab:	je     4e8 <botlish_fn_0+0x4e8>
     4b1:	mov    QWORD PTR [rsp],rax
     4b5:	lea    rdx,[rsp+0x148]
     4bd:	mov    QWORD PTR [rsp+0x148],r12
     4c5:	mov    QWORD PTR [rsp+0x150],rax
     4cd:	mov    esi,0x2
     4d2:	mov    rdi,QWORD PTR [rsp+0x158]
     4da:	call   4df <botlish_fn_0+0x4df>
			4db: R_X86_64_PLT32	rt_list_new-0x4
     4df:	test   rax,rax
     4e2:	jne    51f <botlish_fn_0+0x51f>
     4e8:	xor    rax,rax
     4eb:	mov    rbx,QWORD PTR [rsp+0x180]
     4f3:	mov    r12,QWORD PTR [rsp+0x188]
     4fb:	mov    r13,QWORD PTR [rsp+0x190]
     503:	mov    r14,QWORD PTR [rsp+0x198]
     50b:	mov    r15,QWORD PTR [rsp+0x1a0]
     513:	add    rsp,0x1b0
     51a:	mov    rsp,rbp
     51d:	pop    rbp
     51e:	ret
     51f:	mov    rbx,QWORD PTR [rsp+0x180]
     527:	mov    r12,QWORD PTR [rsp+0x188]
     52f:	mov    r13,QWORD PTR [rsp+0x190]
     537:	mov    r14,QWORD PTR [rsp+0x198]
     53f:	mov    r15,QWORD PTR [rsp+0x1a0]
     547:	add    rsp,0x1b0
     54e:	mov    rsp,rbp
     551:	pop    rbp
     552:	ret

0000000000000553 <botlish_entry_0: <program entry>>:
     553:	push   rbp
     554:	mov    rbp,rsp
     557:	call   55c <botlish_entry_0+0x9>
			558: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     55c:	mov    rsp,rbp
     55f:	pop    rbp
     560:	ret

0000000000000561 <botlish_fn_1: char::codepoint<UnicodeChar>>:
     561:	push   rbp
     562:	mov    rbp,rsp
     565:	call   56a <botlish_fn_1+0x9>
			566: R_X86_64_PLT32	rt_char_codepoint-0x4
     56a:	mov    rsp,rbp
     56d:	pop    rbp
     56e:	ret

000000000000056f <botlish_entry_1: char::codepoint<UnicodeChar>>:
     56f:	push   rbp
     570:	mov    rbp,rsp
     573:	mov    rsi,QWORD PTR [rdx]
     576:	call   57b <botlish_entry_1+0xc>
			577: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     57b:	mov    rsp,rbp
     57e:	pop    rbp
     57f:	ret

0000000000000580 <botlish_fn_2: byte::from_int<int>>:
     580:	push   rbp
     581:	mov    rbp,rsp
     584:	sub    rsp,0x10
     588:	mov    QWORD PTR [rsp],rbx
     58c:	mov    QWORD PTR [rsp+0x8],r12
     591:	mov    r12,rdi
     594:	test   rsi,0x1
     59b:	mov    rax,rsi
     59e:	jne    5cd <botlish_fn_2+0x4d>
     5a4:	mov    edx,0x1
     5a9:	mov    rbx,rax
     5ac:	mov    rsi,rbx
     5af:	mov    rdi,r12
     5b2:	call   5b7 <botlish_fn_2+0x37>
			5b3: R_X86_64_PLT32	rt_int_cmp-0x4
     5b7:	mov    r8d,0x2
     5bd:	test   rax,rax
     5c0:	cmovl  r8,QWORD PTR [rip+0xb0]        # 678 <botlish_fn_2+0xf8>
     5c8:	jmp    5e1 <botlish_fn_2+0x61>
     5cd:	mov    rbx,rax
     5d0:	mov    r8d,0x2
     5d6:	test   rbx,rbx
     5d9:	cmovle r8,QWORD PTR [rip+0x97]        # 678 <botlish_fn_2+0xf8>
     5e1:	test   rbx,0x1
     5e8:	jne    613 <botlish_fn_2+0x93>
     5ee:	mov    edx,0x1ff
     5f3:	mov    rsi,rbx
     5f6:	mov    rdi,r12
     5f9:	call   5fe <botlish_fn_2+0x7e>
			5fa: R_X86_64_PLT32	rt_int_cmp-0x4
     5fe:	mov    ecx,0x2
     603:	test   rax,rax
     606:	cmovg  rcx,QWORD PTR [rip+0x6a]        # 678 <botlish_fn_2+0xf8>
     60e:	jmp    627 <botlish_fn_2+0xa7>
     613:	mov    ecx,0x2
     618:	cmp    rbx,0x1ff
     61f:	cmovg  rcx,QWORD PTR [rip+0x51]        # 678 <botlish_fn_2+0xf8>
     627:	cmp    rcx,0x6
     62b:	je     646 <botlish_fn_2+0xc6>
     631:	mov    rax,rbx
     634:	mov    rbx,QWORD PTR [rsp]
     638:	mov    r12,QWORD PTR [rsp+0x8]
     63d:	add    rsp,0x10
     641:	mov    rsp,rbp
     644:	pop    rbp
     645:	ret
     646:	mov    rdi,r12
     649:	mov    rax,QWORD PTR [rdi+0x10]
     64d:	mov    rdx,QWORD PTR [rax+0xb8]
     654:	mov    esi,0x1
     659:	call   65e <botlish_fn_2+0xde>
			65a: R_X86_64_PLT32	rt_fail_declared-0x4
     65e:	xor    rax,rax
     661:	mov    rbx,QWORD PTR [rsp]
     665:	mov    r12,QWORD PTR [rsp+0x8]
     66a:	add    rsp,0x10
     66e:	mov    rsp,rbp
     671:	pop    rbp
     672:	ret
     673:	add    BYTE PTR [rax],al
     675:	add    BYTE PTR [rax],al
     677:	add    BYTE PTR [rsi],al
     679:	add    BYTE PTR [rax],al
     67b:	add    BYTE PTR [rax],al
     67d:	add    BYTE PTR [rax],al
	...

0000000000000680 <botlish_entry_2: byte::from_int<int>>:
     680:	push   rbp
     681:	mov    rbp,rsp
     684:	mov    rsi,QWORD PTR [rdx]
     687:	call   68c <botlish_entry_2+0xc>
			688: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     68c:	mov    rsp,rbp
     68f:	pop    rbp
     690:	ret
     691:	add    BYTE PTR [rax],al
     693:	add    BYTE PTR [rax],al
     695:	add    BYTE PTR [rax],al
	...

0000000000000698 <botlish_fn_3: byte::set<List[UnicodeChar]>>:
     698:	push   rbp
     699:	mov    rbp,rsp
     69c:	sub    rsp,0x60
     6a0:	mov    QWORD PTR [rsp+0x30],rbx
     6a5:	mov    QWORD PTR [rsp+0x38],r12
     6aa:	mov    QWORD PTR [rsp+0x40],r13
     6af:	mov    QWORD PTR [rsp+0x48],r14
     6b4:	mov    QWORD PTR [rsp+0x50],r15
     6b9:	mov    r13,rdi
     6bc:	mov    QWORD PTR [rsp+0x18],0x0
     6c5:	mov    QWORD PTR [rsp+0x20],0x0
     6ce:	mov    QWORD PTR [rsp],rsi
     6d2:	mov    rbx,rsi
     6d5:	mov    rdi,r13
     6d8:	call   6dd <botlish_fn_3+0x45>
			6d9: R_X86_64_PLT32	rt_list_len-0x4
     6dd:	mov    QWORD PTR [rsp+0x8],rax
     6e2:	mov    r12,rax
     6e5:	mov    QWORD PTR [rsp+0x10],0x1
     6ee:	xor    rdx,rdx
     6f1:	mov    rdi,r13
     6f4:	mov    rsi,rdx
     6f7:	call   6fc <botlish_fn_3+0x64>
			6f8: R_X86_64_PLT32	rt_list_new-0x4
     6fc:	test   rax,rax
     6ff:	je     820 <botlish_fn_3+0x188>
     705:	mov    QWORD PTR [rsp+0x18],rax
     70a:	mov    esi,0x1
     70f:	mov    r14,rsi
     712:	mov    r15,rax
     715:	mov    rax,rsi
     718:	and    rax,r12
     71b:	mov    r14,rsi
     71e:	test   rax,0x1
     724:	jne    74d <botlish_fn_3+0xb5>
     72a:	mov    rdx,r12
     72d:	mov    rsi,r14
     730:	mov    rdi,r13
     733:	call   738 <botlish_fn_3+0xa0>
			734: R_X86_64_PLT32	rt_int_cmp-0x4
     738:	mov    ecx,0x2
     73d:	test   rax,rax
     740:	cmovl  rcx,QWORD PTR [rip+0x170]        # 8b8 <botlish_fn_3+0x220>
     748:	jmp    760 <botlish_fn_3+0xc8>
     74d:	mov    ecx,0x2
     752:	mov    rsi,r14
     755:	cmp    rsi,r12
     758:	cmovl  rcx,QWORD PTR [rip+0x158]        # 8b8 <botlish_fn_3+0x220>
     760:	cmp    rcx,0x6
     764:	je     79b <botlish_fn_3+0x103>
     76a:	mov    rsi,r15
     76d:	mov    QWORD PTR [rsp],rsi
     771:	mov    rdi,r13
     774:	call   779 <botlish_fn_3+0xe1>
			775: R_X86_64_PLT32	rt_set_from_list-0x4
     779:	mov    rbx,QWORD PTR [rsp+0x30]
     77e:	mov    r12,QWORD PTR [rsp+0x38]
     783:	mov    r13,QWORD PTR [rsp+0x40]
     788:	mov    r14,QWORD PTR [rsp+0x48]
     78d:	mov    r15,QWORD PTR [rsp+0x50]
     792:	add    rsp,0x60
     796:	mov    rsp,rbp
     799:	pop    rbp
     79a:	ret
     79b:	mov    rsi,r14
     79e:	test   rsi,0x1
     7a5:	je     7c1 <botlish_fn_3+0x129>
     7ab:	mov    rcx,QWORD PTR [rbx+0x8]
     7af:	mov    rsi,r14
     7b2:	mov    rax,rsi
     7b5:	sar    rax,1
     7b8:	cmp    rax,rcx
     7bb:	jb     7e0 <botlish_fn_3+0x148>
     7c1:	mov    rdx,r14
     7c4:	mov    rsi,rbx
     7c7:	mov    rdi,r13
     7ca:	call   7cf <botlish_fn_3+0x137>
			7cb: R_X86_64_PLT32	rt_list_get-0x4
     7cf:	test   rax,rax
     7d2:	je     820 <botlish_fn_3+0x188>
     7d8:	mov    rsi,rax
     7db:	jmp    7e8 <botlish_fn_3+0x150>
     7e0:	mov    rdx,QWORD PTR [rbx+0x10]
     7e4:	mov    rsi,QWORD PTR [rdx+rax*8]
     7e8:	mov    rdi,r13
     7eb:	call   7f0 <botlish_fn_3+0x158>
			7ec: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     7f0:	mov    rsi,rax
     7f3:	mov    rdi,r13
     7f6:	call   7fb <botlish_fn_3+0x163>
			7f7: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     7fb:	test   rax,rax
     7fe:	je     820 <botlish_fn_3+0x188>
     804:	mov    QWORD PTR [rsp+0x20],rax
     809:	mov    rdx,rax
     80c:	mov    rsi,r15
     80f:	mov    rdi,r13
     812:	call   817 <botlish_fn_3+0x17f>
			813: R_X86_64_PLT32	rt_list_append-0x4
     817:	test   rax,rax
     81a:	jne    845 <botlish_fn_3+0x1ad>
     820:	xor    rax,rax
     823:	mov    rbx,QWORD PTR [rsp+0x30]
     828:	mov    r12,QWORD PTR [rsp+0x38]
     82d:	mov    r13,QWORD PTR [rsp+0x40]
     832:	mov    r14,QWORD PTR [rsp+0x48]
     837:	mov    r15,QWORD PTR [rsp+0x50]
     83c:	add    rsp,0x60
     840:	mov    rsp,rbp
     843:	pop    rbp
     844:	ret
     845:	mov    QWORD PTR [rsp+0x18],rax
     84a:	mov    r15,rax
     84d:	mov    edx,0x3
     852:	mov    QWORD PTR [rsp+0x20],0x3
     85b:	mov    rsi,r14
     85e:	test   rsi,0x1
     865:	jne    873 <botlish_fn_3+0x1db>
     86b:	mov    rsi,r14
     86e:	jmp    89b <botlish_fn_3+0x203>
     873:	mov    rsi,r14
     876:	mov    rcx,rsi
     879:	add    rcx,0x2
     87d:	seto   al
     880:	test   al,al
     882:	je     890 <botlish_fn_3+0x1f8>
     888:	mov    rsi,r14
     88b:	jmp    89b <botlish_fn_3+0x203>
     890:	mov    rsi,rcx
     893:	mov    r14,rcx
     896:	jmp    8a9 <botlish_fn_3+0x211>
     89b:	mov    rdi,r13
     89e:	call   8a3 <botlish_fn_3+0x20b>
			89f: R_X86_64_PLT32	rt_int_add-0x4
     8a3:	mov    rsi,rax
     8a6:	mov    r14,rax
     8a9:	mov    QWORD PTR [rsp+0x10],rsi
     8ae:	mov    rsi,r14
     8b1:	jmp    715 <botlish_fn_3+0x7d>
     8b6:	add    BYTE PTR [rax],al
     8b8:	(bad)
     8b9:	add    BYTE PTR [rax],al
     8bb:	add    BYTE PTR [rax],al
     8bd:	add    BYTE PTR [rax],al
	...

00000000000008c0 <botlish_entry_3: byte::set<List[UnicodeChar]>>:
     8c0:	push   rbp
     8c1:	mov    rbp,rsp
     8c4:	mov    rsi,QWORD PTR [rdx]
     8c7:	call   8cc <botlish_entry_3+0xc>
			8c8: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::set<List[UnicodeChar]>
     8cc:	mov    rsp,rbp
     8cf:	pop    rbp
     8d0:	ret

00000000000008d1 <botlish_fn_4: ascii::is_digit<int>>:
     8d1:	push   rbp
     8d2:	mov    rbp,rsp
     8d5:	cmp    rsi,0x30
     8d9:	jge    8e9 <botlish_fn_4+0x18>
     8df:	mov    eax,0x2
     8e4:	jmp    902 <botlish_fn_4+0x31>
     8e9:	cmp    rsi,0x39
     8ed:	jle    8fd <botlish_fn_4+0x2c>
     8f3:	mov    eax,0x2
     8f8:	jmp    902 <botlish_fn_4+0x31>
     8fd:	mov    eax,0x6
     902:	mov    rsp,rbp
     905:	pop    rbp
     906:	ret

0000000000000907 <botlish_entry_4: ascii::is_digit<int>>:
     907:	push   rbp
     908:	mov    rbp,rsp
     90b:	mov    rsi,QWORD PTR [rdx]
     90e:	sar    rsi,1
     911:	call   916 <botlish_entry_4+0xf>
			912: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     916:	mov    rsp,rbp
     919:	pop    rbp
     91a:	ret

000000000000091b <botlish_fn_5: ascii::is_upper<int>>:
     91b:	push   rbp
     91c:	mov    rbp,rsp
     91f:	cmp    rsi,0x41
     923:	jge    933 <botlish_fn_5+0x18>
     929:	mov    eax,0x2
     92e:	jmp    94c <botlish_fn_5+0x31>
     933:	cmp    rsi,0x5a
     937:	jle    947 <botlish_fn_5+0x2c>
     93d:	mov    eax,0x2
     942:	jmp    94c <botlish_fn_5+0x31>
     947:	mov    eax,0x6
     94c:	mov    rsp,rbp
     94f:	pop    rbp
     950:	ret

0000000000000951 <botlish_entry_5: ascii::is_upper<int>>:
     951:	push   rbp
     952:	mov    rbp,rsp
     955:	mov    rsi,QWORD PTR [rdx]
     958:	sar    rsi,1
     95b:	call   960 <botlish_entry_5+0xf>
			95c: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     960:	mov    rsp,rbp
     963:	pop    rbp
     964:	ret

0000000000000965 <botlish_fn_6: ascii::is_lower<int>>:
     965:	push   rbp
     966:	mov    rbp,rsp
     969:	cmp    rsi,0x61
     96d:	jge    97d <botlish_fn_6+0x18>
     973:	mov    eax,0x2
     978:	jmp    996 <botlish_fn_6+0x31>
     97d:	cmp    rsi,0x7a
     981:	jle    991 <botlish_fn_6+0x2c>
     987:	mov    eax,0x2
     98c:	jmp    996 <botlish_fn_6+0x31>
     991:	mov    eax,0x6
     996:	mov    rsp,rbp
     999:	pop    rbp
     99a:	ret

000000000000099b <botlish_entry_6: ascii::is_lower<int>>:
     99b:	push   rbp
     99c:	mov    rbp,rsp
     99f:	mov    rsi,QWORD PTR [rdx]
     9a2:	sar    rsi,1
     9a5:	call   9aa <botlish_entry_6+0xf>
			9a6: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     9aa:	mov    rsp,rbp
     9ad:	pop    rbp
     9ae:	ret

00000000000009af <botlish_fn_7: ascii::is_alphabetic<int>>:
     9af:	push   rbp
     9b0:	mov    rbp,rsp
     9b3:	sub    rsp,0x10
     9b7:	mov    QWORD PTR [rsp],r12
     9bb:	mov    QWORD PTR [rsp+0x8],r14
     9c0:	mov    r12,rsi
     9c3:	mov    r14,rdi
     9c6:	mov    rsi,r12
     9c9:	mov    rdi,r14
     9cc:	call   9d1 <botlish_fn_7+0x22>
			9cd: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     9d1:	cmp    rax,0x6
     9d5:	je     a04 <botlish_fn_7+0x55>
     9db:	mov    rsi,r12
     9de:	mov    rdi,r14
     9e1:	call   9e6 <botlish_fn_7+0x37>
			9e2: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     9e6:	cmp    rax,0x6
     9ea:	je     9fa <botlish_fn_7+0x4b>
     9f0:	mov    eax,0x2
     9f5:	jmp    a09 <botlish_fn_7+0x5a>
     9fa:	mov    eax,0x6
     9ff:	jmp    a09 <botlish_fn_7+0x5a>
     a04:	mov    eax,0x6
     a09:	mov    r12,QWORD PTR [rsp]
     a0d:	mov    r14,QWORD PTR [rsp+0x8]
     a12:	add    rsp,0x10
     a16:	mov    rsp,rbp
     a19:	pop    rbp
     a1a:	ret

0000000000000a1b <botlish_entry_7: ascii::is_alphabetic<int>>:
     a1b:	push   rbp
     a1c:	mov    rbp,rsp
     a1f:	mov    rsi,QWORD PTR [rdx]
     a22:	sar    rsi,1
     a25:	call   a2a <botlish_entry_7+0xf>
			a26: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     a2a:	mov    rsp,rbp
     a2d:	pop    rbp
     a2e:	ret

0000000000000a2f <botlish_fn_8: ascii::is_alphanumeric<int>>:
     a2f:	push   rbp
     a30:	mov    rbp,rsp
     a33:	sub    rsp,0x10
     a37:	mov    QWORD PTR [rsp],r12
     a3b:	mov    QWORD PTR [rsp+0x8],r14
     a40:	mov    r12,rsi
     a43:	mov    r14,rdi
     a46:	mov    rsi,r12
     a49:	mov    rdi,r14
     a4c:	call   a51 <botlish_fn_8+0x22>
			a4d: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     a51:	cmp    rax,0x6
     a55:	je     a84 <botlish_fn_8+0x55>
     a5b:	mov    rsi,r12
     a5e:	mov    rdi,r14
     a61:	call   a66 <botlish_fn_8+0x37>
			a62: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     a66:	cmp    rax,0x6
     a6a:	je     a7a <botlish_fn_8+0x4b>
     a70:	mov    eax,0x2
     a75:	jmp    a89 <botlish_fn_8+0x5a>
     a7a:	mov    eax,0x6
     a7f:	jmp    a89 <botlish_fn_8+0x5a>
     a84:	mov    eax,0x6
     a89:	mov    r12,QWORD PTR [rsp]
     a8d:	mov    r14,QWORD PTR [rsp+0x8]
     a92:	add    rsp,0x10
     a96:	mov    rsp,rbp
     a99:	pop    rbp
     a9a:	ret

0000000000000a9b <botlish_entry_8: ascii::is_alphanumeric<int>>:
     a9b:	push   rbp
     a9c:	mov    rbp,rsp
     a9f:	mov    rsi,QWORD PTR [rdx]
     aa2:	sar    rsi,1
     aa5:	call   aaa <botlish_entry_8+0xf>
			aa6: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
     aaa:	mov    rsp,rbp
     aad:	pop    rbp
     aae:	ret

0000000000000aaf <botlish_fn_9: web::emailish?<str>>:
     aaf:	push   rbp
     ab0:	mov    rbp,rsp
     ab3:	sub    rsp,0x50
     ab7:	mov    QWORD PTR [rsp+0x30],rbx
     abc:	mov    QWORD PTR [rsp+0x38],r12
     ac1:	mov    QWORD PTR [rsp+0x40],r13
     ac6:	mov    QWORD PTR [rsp+0x48],r14
     acb:	mov    r13,rdi
     ace:	mov    QWORD PTR [rsp],rsi
     ad2:	mov    r12,rsi
     ad5:	mov    rsi,r12
     ad8:	mov    rdi,r13
     adb:	call   ae0 <botlish_fn_9+0x31>
			adc: R_X86_64_PLT32	rt_str_len-0x4
     ae0:	mov    r14,rax
     ae3:	mov    QWORD PTR [rsp+0x8],rax
     ae8:	mov    esi,0x1
     aed:	mov    QWORD PTR [rsp+0x10],0x1
     af6:	mov    rdi,r13
     af9:	mov    rax,QWORD PTR [rdi+0x10]
     afd:	mov    rdx,QWORD PTR [rax+0xc0]
     b04:	mov    QWORD PTR [rsp+0x18],rdx
     b09:	mov    rcx,r14
     b0c:	mov    r8,r12
     b0f:	call   b14 <botlish_fn_9+0x65>
			b10: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<any, block(e239)>
     b14:	test   rax,rax
     b17:	je     bba <botlish_fn_9+0x10b>
     b1d:	mov    QWORD PTR [rsp+0x10],rax
     b22:	mov    rbx,rax
     b25:	sar    rbx,1
     b28:	mov    rsi,rax
     b2b:	test   rbx,rbx
     b2e:	je     be9 <botlish_fn_9+0x13a>
     b34:	mov    rax,r14
     b37:	mov    rcx,rax
     b3a:	sar    rcx,1
     b3d:	cmp    rbx,rcx
     b40:	jge    bdf <botlish_fn_9+0x130>
     b46:	lea    rcx,[rsp+0x20]
     b4b:	mov    rdx,r12
     b4e:	mov    rdi,r13
     b51:	call   b56 <botlish_fn_9+0xa7>
			b52: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
     b56:	test   rax,rax
     b59:	mov    rsi,rax
     b5c:	je     bba <botlish_fn_9+0x10b>
     b62:	mov    rdx,QWORD PTR [rsp+0x20]
     b67:	mov    rcx,QWORD PTR [rsp+0x28]
     b6c:	mov    rdi,r13
     b6f:	mov    rax,QWORD PTR [rdi+0x10]
     b73:	mov    r8,QWORD PTR [rax+0xc8]
     b7a:	call   b7f <botlish_fn_9+0xd0>
			b7b: R_X86_64_PLT32	rt_str_region_eq-0x4
     b7f:	cmp    rax,0x6
     b83:	je     b93 <botlish_fn_9+0xe4>
     b89:	mov    eax,0x2
     b8e:	jmp    bee <botlish_fn_9+0x13f>
     b93:	lea    rsi,[rbx+0x1]
     b97:	shl    rsi,1
     b9a:	or     rsi,0x1
     b9e:	mov    QWORD PTR [rsp+0x10],rsi
     ba3:	mov    rcx,r12
     ba6:	mov    rdx,r14
     ba9:	mov    rdi,r13
     bac:	call   bb1 <botlish_fn_9+0x102>
			bad: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<generic>
     bb1:	test   rax,rax
     bb4:	jne    bee <botlish_fn_9+0x13f>
     bba:	xor    rax,rax
     bbd:	mov    rbx,QWORD PTR [rsp+0x30]
     bc2:	mov    r12,QWORD PTR [rsp+0x38]
     bc7:	mov    r13,QWORD PTR [rsp+0x40]
     bcc:	mov    r14,QWORD PTR [rsp+0x48]
     bd1:	add    rsp,0x50
     bd5:	mov    rsp,rbp
     bd8:	pop    rbp
     bd9:	ret
     bda:	jmp    bee <botlish_fn_9+0x13f>
     bdf:	mov    eax,0x2
     be4:	jmp    bee <botlish_fn_9+0x13f>
     be9:	mov    eax,0x2
     bee:	mov    rbx,QWORD PTR [rsp+0x30]
     bf3:	mov    r12,QWORD PTR [rsp+0x38]
     bf8:	mov    r13,QWORD PTR [rsp+0x40]
     bfd:	mov    r14,QWORD PTR [rsp+0x48]
     c02:	add    rsp,0x50
     c06:	mov    rsp,rbp
     c09:	pop    rbp
     c0a:	ret

0000000000000c0b <botlish_entry_9: web::emailish?<str>>:
     c0b:	push   rbp
     c0c:	mov    rbp,rsp
     c0f:	mov    rsi,QWORD PTR [rdx]
     c12:	call   c17 <botlish_entry_9+0xc>
			c13: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
     c17:	mov    rsp,rbp
     c1a:	pop    rbp
     c1b:	ret

0000000000000c1c <botlish_fn_10: char_at<generic>>:
     c1c:	push   rbp
     c1d:	mov    rbp,rsp
     c20:	sub    rsp,0x50
     c24:	mov    QWORD PTR [rsp+0x20],rbx
     c29:	mov    QWORD PTR [rsp+0x28],r12
     c2e:	mov    QWORD PTR [rsp+0x30],r13
     c33:	mov    QWORD PTR [rsp+0x38],r14
     c38:	mov    QWORD PTR [rsp+0x40],r15
     c3d:	mov    r12,rdi
     c40:	mov    r15,rcx
     c43:	mov    QWORD PTR [rsp],rsi
     c47:	mov    QWORD PTR [rsp+0x8],rdx
     c4c:	mov    r13,rdx
     c4f:	mov    QWORD PTR [rsp+0x10],0x3
     c58:	test   rsi,0x1
     c5f:	jne    c6d <botlish_fn_10+0x51>
     c65:	mov    rbx,rsi
     c68:	jmp    c8d <botlish_fn_10+0x71>
     c6d:	mov    rax,rsi
     c70:	add    rax,0x2
     c74:	mov    rbx,rsi
     c77:	seto   cl
     c7a:	test   cl,cl
     c7c:	jne    c8d <botlish_fn_10+0x71>
     c82:	mov    rdi,r12
     c85:	mov    r14,rax
     c88:	jmp    ca3 <botlish_fn_10+0x87>
     c8d:	mov    edx,0x3
     c92:	mov    rsi,rbx
     c95:	mov    rdi,r12
     c98:	call   c9d <botlish_fn_10+0x81>
			c99: R_X86_64_PLT32	rt_int_add-0x4
     c9d:	mov    r14,rax
     ca0:	mov    rdi,r12
     ca3:	mov    rcx,r14
     ca6:	mov    rdx,rbx
     ca9:	mov    rsi,r13
     cac:	call   cb1 <botlish_fn_10+0x95>
			cad: R_X86_64_PLT32	rt_str_region_check-0x4
     cb1:	test   rax,rax
     cb4:	jne    cdf <botlish_fn_10+0xc3>
     cba:	xor    rax,rax
     cbd:	mov    rbx,QWORD PTR [rsp+0x20]
     cc2:	mov    r12,QWORD PTR [rsp+0x28]
     cc7:	mov    r13,QWORD PTR [rsp+0x30]
     ccc:	mov    r14,QWORD PTR [rsp+0x38]
     cd1:	mov    r15,QWORD PTR [rsp+0x40]
     cd6:	add    rsp,0x50
     cda:	mov    rsp,rbp
     cdd:	pop    rbp
     cde:	ret
     cdf:	mov    rcx,r15
     ce2:	mov    QWORD PTR [rcx],rbx
     ce5:	mov    rax,r14
     ce8:	mov    QWORD PTR [rcx+0x8],rax
     cec:	mov    rax,r13
     cef:	mov    rbx,QWORD PTR [rsp+0x20]
     cf4:	mov    r12,QWORD PTR [rsp+0x28]
     cf9:	mov    r13,QWORD PTR [rsp+0x30]
     cfe:	mov    r14,QWORD PTR [rsp+0x38]
     d03:	mov    r15,QWORD PTR [rsp+0x40]
     d08:	add    rsp,0x50
     d0c:	mov    rsp,rbp
     d0f:	pop    rbp
     d10:	ret

0000000000000d11 <botlish_entry_10: char_at<generic>>:
     d11:	push   rbp
     d12:	mov    rbp,rsp
     d15:	ud2

0000000000000d17 <botlish_fn_11: char_at<generic>>:
     d17:	push   rbp
     d18:	mov    rbp,rsp
     d1b:	sub    rsp,0x40
     d1f:	mov    QWORD PTR [rsp+0x20],rbx
     d24:	mov    QWORD PTR [rsp+0x28],r12
     d29:	mov    QWORD PTR [rsp+0x30],r13
     d2e:	mov    r12,rdi
     d31:	mov    QWORD PTR [rsp],rsi
     d35:	mov    QWORD PTR [rsp+0x8],rdx
     d3a:	mov    r13,rdx
     d3d:	mov    QWORD PTR [rsp+0x10],0x3
     d46:	test   rsi,0x1
     d4d:	jne    d5b <botlish_fn_11+0x44>
     d53:	mov    rbx,rsi
     d56:	jmp    d70 <botlish_fn_11+0x59>
     d5b:	mov    rcx,rsi
     d5e:	add    rcx,0x2
     d62:	mov    rbx,rsi
     d65:	seto   al
     d68:	test   al,al
     d6a:	je     d83 <botlish_fn_11+0x6c>
     d70:	mov    edx,0x3
     d75:	mov    rsi,rbx
     d78:	mov    rdi,r12
     d7b:	call   d80 <botlish_fn_11+0x69>
			d7c: R_X86_64_PLT32	rt_int_add-0x4
     d80:	mov    rcx,rax
     d83:	mov    QWORD PTR [rsp+0x10],rcx
     d88:	mov    rdx,rbx
     d8b:	mov    rsi,r13
     d8e:	mov    rdi,r12
     d91:	call   d96 <botlish_fn_11+0x7f>
			d92: R_X86_64_PLT32	rt_substr-0x4
     d96:	test   rax,rax
     d99:	jne    dba <botlish_fn_11+0xa3>
     d9f:	xor    rax,rax
     da2:	mov    rbx,QWORD PTR [rsp+0x20]
     da7:	mov    r12,QWORD PTR [rsp+0x28]
     dac:	mov    r13,QWORD PTR [rsp+0x30]
     db1:	add    rsp,0x40
     db5:	mov    rsp,rbp
     db8:	pop    rbp
     db9:	ret
     dba:	mov    rbx,QWORD PTR [rsp+0x20]
     dbf:	mov    r12,QWORD PTR [rsp+0x28]
     dc4:	mov    r13,QWORD PTR [rsp+0x30]
     dc9:	add    rsp,0x40
     dcd:	mov    rsp,rbp
     dd0:	pop    rbp
     dd1:	ret

0000000000000dd2 <botlish_entry_11: char_at<generic>>:
     dd2:	push   rbp
     dd3:	mov    rbp,rsp
     dd6:	mov    rsi,QWORD PTR [rdx]
     dd9:	mov    rdx,QWORD PTR [rdx+0x8]
     ddd:	call   de2 <botlish_entry_11+0x10>
			dde: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
     de2:	mov    rsp,rbp
     de5:	pop    rbp
     de6:	ret

0000000000000de7 <botlish_fn_12: local_char?<str>>:
     de7:	push   rbp
     de8:	mov    rbp,rsp
     deb:	sub    rsp,0x10
     def:	mov    QWORD PTR [rsp],rbx
     df3:	mov    QWORD PTR [rsp+0x8],r14
     df8:	mov    rbx,rdi
     dfb:	mov    r14,rsi
     dfe:	mov    rsi,r14
     e01:	mov    rdi,rbx
     e04:	call   e09 <botlish_fn_12+0x22>
			e05: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     e09:	test   rax,rax
     e0c:	jne    e27 <botlish_fn_12+0x40>
     e12:	xor    rax,rax
     e15:	mov    rbx,QWORD PTR [rsp]
     e19:	mov    r14,QWORD PTR [rsp+0x8]
     e1e:	add    rsp,0x10
     e22:	mov    rsp,rbp
     e25:	pop    rbp
     e26:	ret
     e27:	cmp    rax,0x6
     e2b:	je     e61 <botlish_fn_12+0x7a>
     e31:	mov    rdi,rbx
     e34:	mov    rax,QWORD PTR [rdi+0x30]
     e38:	mov    rsi,QWORD PTR [rax]
     e3b:	mov    rdx,r14
     e3e:	call   e43 <botlish_fn_12+0x5c>
			e3f: R_X86_64_PLT32	rt_set_contains-0x4
     e43:	cmp    rax,0x6
     e47:	je     e57 <botlish_fn_12+0x70>
     e4d:	mov    eax,0x2
     e52:	jmp    e66 <botlish_fn_12+0x7f>
     e57:	mov    eax,0x6
     e5c:	jmp    e66 <botlish_fn_12+0x7f>
     e61:	mov    eax,0x6
     e66:	mov    rbx,QWORD PTR [rsp]
     e6a:	mov    r14,QWORD PTR [rsp+0x8]
     e6f:	add    rsp,0x10
     e73:	mov    rsp,rbp
     e76:	pop    rbp
     e77:	ret

0000000000000e78 <botlish_entry_12: local_char?<str>>:
     e78:	push   rbp
     e79:	mov    rbp,rsp
     e7c:	mov    rsi,QWORD PTR [rdx]
     e7f:	call   e84 <botlish_entry_12+0xc>
			e80: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     e84:	mov    rsp,rbp
     e87:	pop    rbp
     e88:	ret

0000000000000e89 <botlish_fn_13: local_char?<generic>>:
     e89:	push   rbp
     e8a:	mov    rbp,rsp
     e8d:	sub    rsp,0x10
     e91:	mov    QWORD PTR [rsp],rbx
     e95:	mov    QWORD PTR [rsp+0x8],r12
     e9a:	xor    r8d,r8d
     e9d:	test   rsi,0x7
     ea4:	jne    eb4 <botlish_fn_13+0x2b>
     eaa:	movzx  rax,BYTE PTR [rsi]
     eae:	cmp    al,0x2
     eb0:	sete   r8b
     eb4:	test   r8b,r8b
     eb7:	jne    ed7 <botlish_fn_13+0x4e>
     ebd:	mov    rax,QWORD PTR [rdi+0x10]
     ec1:	mov    rcx,QWORD PTR [rax+0xd0]
     ec8:	mov    edx,0x1
     ecd:	call   ed2 <botlish_fn_13+0x49>
			ece: R_X86_64_PLT32	rt_type_error-0x4
     ed2:	jmp    eeb <botlish_fn_13+0x62>
     ed7:	mov    rbx,rsi
     eda:	mov    r12,rdi
     edd:	call   ee2 <botlish_fn_13+0x59>
			ede: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     ee2:	test   rax,rax
     ee5:	jne    f00 <botlish_fn_13+0x77>
     eeb:	xor    rax,rax
     eee:	mov    rbx,QWORD PTR [rsp]
     ef2:	mov    r12,QWORD PTR [rsp+0x8]
     ef7:	add    rsp,0x10
     efb:	mov    rsp,rbp
     efe:	pop    rbp
     eff:	ret
     f00:	cmp    rax,0x6
     f04:	je     f3a <botlish_fn_13+0xb1>
     f0a:	mov    rdi,r12
     f0d:	mov    rax,QWORD PTR [rdi+0x30]
     f11:	mov    rsi,QWORD PTR [rax]
     f14:	mov    rdx,rbx
     f17:	call   f1c <botlish_fn_13+0x93>
			f18: R_X86_64_PLT32	rt_set_contains-0x4
     f1c:	cmp    rax,0x6
     f20:	je     f30 <botlish_fn_13+0xa7>
     f26:	mov    eax,0x2
     f2b:	jmp    f3f <botlish_fn_13+0xb6>
     f30:	mov    eax,0x6
     f35:	jmp    f3f <botlish_fn_13+0xb6>
     f3a:	mov    eax,0x6
     f3f:	mov    rbx,QWORD PTR [rsp]
     f43:	mov    r12,QWORD PTR [rsp+0x8]
     f48:	add    rsp,0x10
     f4c:	mov    rsp,rbp
     f4f:	pop    rbp
     f50:	ret

0000000000000f51 <botlish_entry_13: local_char?<generic>>:
     f51:	push   rbp
     f52:	mov    rbp,rsp
     f55:	mov    rsi,QWORD PTR [rdx]
     f58:	call   f5d <botlish_entry_13+0xc>
			f59: R_X86_64_PLT32	botlish_fn_13-0x4 ; local_char?<generic>
     f5d:	mov    rsp,rbp
     f60:	pop    rbp
     f61:	ret
     f62:	add    BYTE PTR [rax],al
     f64:	add    BYTE PTR [rax],al
	...

0000000000000f68 <botlish_fn_14: scan_while<any, block(e239)>>:
     f68:	push   rbp
     f69:	mov    rbp,rsp
     f6c:	sub    rsp,0x40
     f70:	mov    QWORD PTR [rsp+0x20],rbx
     f75:	mov    QWORD PTR [rsp+0x28],r12
     f7a:	mov    QWORD PTR [rsp+0x30],r13
     f7f:	mov    QWORD PTR [rsp+0x38],r14
     f84:	mov    rbx,rcx
     f87:	mov    r13,rdi
     f8a:	mov    QWORD PTR [rsp+0x18],0x0
     f93:	mov    QWORD PTR [rsp],rcx
     f97:	mov    QWORD PTR [rsp+0x8],r8
     f9c:	mov    r12,r8
     f9f:	mov    QWORD PTR [rsp+0x10],rsi
     fa4:	mov    rax,rsi
     fa7:	mov    rcx,rbx
     faa:	mov    r14,rsi
     fad:	mov    rcx,rbx
     fb0:	and    rax,rcx
     fb3:	test   rax,0x1
     fb9:	jne    fe2 <botlish_fn_14+0x7a>
     fbf:	mov    rdx,rbx
     fc2:	mov    rsi,r14
     fc5:	mov    rdi,r13
     fc8:	call   fcd <botlish_fn_14+0x65>
			fc9: R_X86_64_PLT32	rt_int_cmp-0x4
     fcd:	mov    ecx,0x2
     fd2:	test   rax,rax
     fd5:	cmovl  rcx,QWORD PTR [rip+0x10b]        # 10e8 <botlish_fn_14+0x180>
     fdd:	jmp    ff8 <botlish_fn_14+0x90>
     fe2:	mov    ecx,0x2
     fe7:	mov    rax,r14
     fea:	mov    rdx,rbx
     fed:	cmp    rax,rdx
     ff0:	cmovl  rcx,QWORD PTR [rip+0xf0]        # 10e8 <botlish_fn_14+0x180>
     ff8:	cmp    rcx,0x6
     ffc:	je     1022 <botlish_fn_14+0xba>
    1002:	mov    rax,rbx
    1005:	mov    rbx,QWORD PTR [rsp+0x20]
    100a:	mov    r12,QWORD PTR [rsp+0x28]
    100f:	mov    r13,QWORD PTR [rsp+0x30]
    1014:	mov    r14,QWORD PTR [rsp+0x38]
    1019:	add    rsp,0x40
    101d:	mov    rsp,rbp
    1020:	pop    rbp
    1021:	ret
    1022:	mov    rdx,r12
    1025:	mov    rsi,r14
    1028:	mov    rdi,r13
    102b:	call   1030 <botlish_fn_14+0xc8>
			102c: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    1030:	test   rax,rax
    1033:	mov    rsi,rax
    1036:	je     104d <botlish_fn_14+0xe5>
    103c:	mov    rdi,r13
    103f:	call   1044 <botlish_fn_14+0xdc>
			1040: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
    1044:	test   rax,rax
    1047:	jne    106d <botlish_fn_14+0x105>
    104d:	xor    rax,rax
    1050:	mov    rbx,QWORD PTR [rsp+0x20]
    1055:	mov    r12,QWORD PTR [rsp+0x28]
    105a:	mov    r13,QWORD PTR [rsp+0x30]
    105f:	mov    r14,QWORD PTR [rsp+0x38]
    1064:	add    rsp,0x40
    1068:	mov    rsp,rbp
    106b:	pop    rbp
    106c:	ret
    106d:	cmp    rax,0x6
    1071:	je     1097 <botlish_fn_14+0x12f>
    1077:	mov    rax,r14
    107a:	mov    rbx,QWORD PTR [rsp+0x20]
    107f:	mov    r12,QWORD PTR [rsp+0x28]
    1084:	mov    r13,QWORD PTR [rsp+0x30]
    1089:	mov    r14,QWORD PTR [rsp+0x38]
    108e:	add    rsp,0x40
    1092:	mov    rsp,rbp
    1095:	pop    rbp
    1096:	ret
    1097:	mov    QWORD PTR [rsp+0x18],0x3
    10a0:	mov    rax,r14
    10a3:	test   rax,0x1
    10a9:	je     10c4 <botlish_fn_14+0x15c>
    10af:	mov    rcx,r14
    10b2:	mov    rax,rcx
    10b5:	add    rax,0x2
    10b9:	seto   cl
    10bc:	test   cl,cl
    10be:	je     10d4 <botlish_fn_14+0x16c>
    10c4:	mov    edx,0x3
    10c9:	mov    rsi,r14
    10cc:	mov    rdi,r13
    10cf:	call   10d4 <botlish_fn_14+0x16c>
			10d0: R_X86_64_PLT32	rt_int_add-0x4
    10d4:	mov    QWORD PTR [rsp+0x10],rax
    10d9:	mov    rcx,rbx
    10dc:	mov    r14,rax
    10df:	jmp    fad <botlish_fn_14+0x45>
    10e4:	add    BYTE PTR [rax],al
    10e6:	add    BYTE PTR [rax],al
    10e8:	(bad)
    10e9:	add    BYTE PTR [rax],al
    10eb:	add    BYTE PTR [rax],al
    10ed:	add    BYTE PTR [rax],al
	...

00000000000010f0 <botlish_entry_14: scan_while<any, block(e239)>>:
    10f0:	push   rbp
    10f1:	mov    rbp,rsp
    10f4:	mov    rsi,QWORD PTR [rdx]
    10f7:	mov    r9,QWORD PTR [rdx+0x8]
    10fb:	mov    rcx,QWORD PTR [rdx+0x10]
    10ff:	mov    r8,QWORD PTR [rdx+0x18]
    1103:	mov    rdx,r9
    1106:	call   110b <botlish_entry_14+0x1b>
			1107: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<any, block(e239)>
    110b:	mov    rsp,rbp
    110e:	pop    rbp
    110f:	ret

0000000000001110 <botlish_fn_15: scan_while<any, native(is_tcl_alpha)>>:
    1110:	push   rbp
    1111:	mov    rbp,rsp
    1114:	sub    rsp,0x50
    1118:	mov    QWORD PTR [rsp+0x30],rbx
    111d:	mov    QWORD PTR [rsp+0x38],r12
    1122:	mov    QWORD PTR [rsp+0x40],r13
    1127:	mov    QWORD PTR [rsp+0x48],r14
    112c:	mov    rbx,rcx
    112f:	mov    r13,rdi
    1132:	mov    QWORD PTR [rsp+0x18],0x0
    113b:	mov    QWORD PTR [rsp],rcx
    113f:	mov    QWORD PTR [rsp+0x8],r8
    1144:	mov    r12,r8
    1147:	mov    QWORD PTR [rsp+0x10],rsi
    114c:	mov    rax,rsi
    114f:	mov    rcx,rbx
    1152:	mov    r14,rsi
    1155:	mov    rcx,rbx
    1158:	and    rax,rcx
    115b:	test   rax,0x1
    1161:	jne    118a <botlish_fn_15+0x7a>
    1167:	mov    rdx,rbx
    116a:	mov    rsi,r14
    116d:	mov    rdi,r13
    1170:	call   1175 <botlish_fn_15+0x65>
			1171: R_X86_64_PLT32	rt_int_cmp-0x4
    1175:	mov    ecx,0x2
    117a:	test   rax,rax
    117d:	cmovl  rcx,QWORD PTR [rip+0x11b]        # 12a0 <botlish_fn_15+0x190>
    1185:	jmp    11a0 <botlish_fn_15+0x90>
    118a:	mov    ecx,0x2
    118f:	mov    rax,r14
    1192:	mov    rdx,rbx
    1195:	cmp    rax,rdx
    1198:	cmovl  rcx,QWORD PTR [rip+0x100]        # 12a0 <botlish_fn_15+0x190>
    11a0:	cmp    rcx,0x6
    11a4:	je     11ca <botlish_fn_15+0xba>
    11aa:	mov    rax,rbx
    11ad:	mov    rbx,QWORD PTR [rsp+0x30]
    11b2:	mov    r12,QWORD PTR [rsp+0x38]
    11b7:	mov    r13,QWORD PTR [rsp+0x40]
    11bc:	mov    r14,QWORD PTR [rsp+0x48]
    11c1:	add    rsp,0x50
    11c5:	mov    rsp,rbp
    11c8:	pop    rbp
    11c9:	ret
    11ca:	lea    rcx,[rsp+0x20]
    11cf:	mov    rdx,r12
    11d2:	mov    rsi,r14
    11d5:	mov    rdi,r13
    11d8:	call   11dd <botlish_fn_15+0xcd>
			11d9: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    11dd:	test   rax,rax
    11e0:	mov    rsi,rax
    11e3:	je     1204 <botlish_fn_15+0xf4>
    11e9:	mov    rdx,QWORD PTR [rsp+0x20]
    11ee:	mov    rcx,QWORD PTR [rsp+0x28]
    11f3:	mov    rdi,r13
    11f6:	call   11fb <botlish_fn_15+0xeb>
			11f7: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    11fb:	test   rax,rax
    11fe:	jne    1224 <botlish_fn_15+0x114>
    1204:	xor    rax,rax
    1207:	mov    rbx,QWORD PTR [rsp+0x30]
    120c:	mov    r12,QWORD PTR [rsp+0x38]
    1211:	mov    r13,QWORD PTR [rsp+0x40]
    1216:	mov    r14,QWORD PTR [rsp+0x48]
    121b:	add    rsp,0x50
    121f:	mov    rsp,rbp
    1222:	pop    rbp
    1223:	ret
    1224:	cmp    rax,0x6
    1228:	je     124e <botlish_fn_15+0x13e>
    122e:	mov    rax,r14
    1231:	mov    rbx,QWORD PTR [rsp+0x30]
    1236:	mov    r12,QWORD PTR [rsp+0x38]
    123b:	mov    r13,QWORD PTR [rsp+0x40]
    1240:	mov    r14,QWORD PTR [rsp+0x48]
    1245:	add    rsp,0x50
    1249:	mov    rsp,rbp
    124c:	pop    rbp
    124d:	ret
    124e:	mov    QWORD PTR [rsp+0x18],0x3
    1257:	mov    rax,r14
    125a:	test   rax,0x1
    1260:	je     127b <botlish_fn_15+0x16b>
    1266:	mov    rcx,r14
    1269:	mov    rax,rcx
    126c:	add    rax,0x2
    1270:	seto   cl
    1273:	test   cl,cl
    1275:	je     128b <botlish_fn_15+0x17b>
    127b:	mov    edx,0x3
    1280:	mov    rsi,r14
    1283:	mov    rdi,r13
    1286:	call   128b <botlish_fn_15+0x17b>
			1287: R_X86_64_PLT32	rt_int_add-0x4
    128b:	mov    QWORD PTR [rsp+0x10],rax
    1290:	mov    rcx,rbx
    1293:	mov    r14,rax
    1296:	jmp    1155 <botlish_fn_15+0x45>
    129b:	add    BYTE PTR [rax],al
    129d:	add    BYTE PTR [rax],al
    129f:	add    BYTE PTR [rsi],al
    12a1:	add    BYTE PTR [rax],al
    12a3:	add    BYTE PTR [rax],al
    12a5:	add    BYTE PTR [rax],al
	...

00000000000012a8 <botlish_entry_15: scan_while<any, native(is_tcl_alpha)>>:
    12a8:	push   rbp
    12a9:	mov    rbp,rsp
    12ac:	mov    rsi,QWORD PTR [rdx]
    12af:	mov    r9,QWORD PTR [rdx+0x8]
    12b3:	mov    rcx,QWORD PTR [rdx+0x10]
    12b7:	mov    r8,QWORD PTR [rdx+0x18]
    12bb:	mov    rdx,r9
    12be:	call   12c3 <botlish_entry_15+0x1b>
			12bf: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<any, native(is_tcl_alpha)>
    12c3:	mov    rsp,rbp
    12c6:	pop    rbp
    12c7:	ret

00000000000012c8 <botlish_fn_16: tld?<generic>>:
    12c8:	push   rbp
    12c9:	mov    rbp,rsp
    12cc:	sub    rsp,0x40
    12d0:	mov    QWORD PTR [rsp+0x20],rbx
    12d5:	mov    QWORD PTR [rsp+0x28],r12
    12da:	mov    QWORD PTR [rsp+0x30],r13
    12df:	mov    QWORD PTR [rsp+0x38],r14
    12e4:	mov    QWORD PTR [rsp],rsi
    12e8:	mov    r8,rsi
    12eb:	mov    QWORD PTR [rsp+0x8],rdx
    12f0:	mov    r14,rdx
    12f3:	mov    QWORD PTR [rsp+0x10],rcx
    12f8:	mov    rax,QWORD PTR [rdi+0x10]
    12fc:	mov    r12,rdi
    12ff:	mov    rdx,QWORD PTR [rax+0xd8]
    1306:	mov    QWORD PTR [rsp+0x18],rdx
    130b:	mov    rbx,r8
    130e:	mov    r8,rcx
    1311:	mov    rcx,r14
    1314:	mov    rsi,rbx
    1317:	call   131c <botlish_fn_16+0x54>
			1318: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<any, native(is_tcl_alpha)>
    131c:	mov    rcx,rax
    131f:	mov    r13,rax
    1322:	test   rax,rcx
    1325:	jne    134b <botlish_fn_16+0x83>
    132b:	xor    rax,rax
    132e:	mov    rbx,QWORD PTR [rsp+0x20]
    1333:	mov    r12,QWORD PTR [rsp+0x28]
    1338:	mov    r13,QWORD PTR [rsp+0x30]
    133d:	mov    r14,QWORD PTR [rsp+0x38]
    1342:	add    rsp,0x40
    1346:	mov    rsp,rbp
    1349:	pop    rbp
    134a:	ret
    134b:	mov    rax,r13
    134e:	mov    QWORD PTR [rsp+0x8],rax
    1353:	mov    rdx,r14
    1356:	and    rax,rdx
    1359:	test   rax,0x1
    135f:	jne    1388 <botlish_fn_16+0xc0>
    1365:	mov    rsi,r13
    1368:	mov    rdi,r12
    136b:	call   1370 <botlish_fn_16+0xa8>
			136c: R_X86_64_PLT32	rt_int_cmp-0x4
    1370:	mov    ecx,0x2
    1375:	test   rax,rax
    1378:	cmove  rcx,QWORD PTR [rip+0xe0]        # 1460 <botlish_fn_16+0x198>
    1380:	mov    rax,r13
    1383:	jmp    139b <botlish_fn_16+0xd3>
    1388:	mov    ecx,0x2
    138d:	mov    rax,r13
    1390:	cmp    rax,rdx
    1393:	cmove  rcx,QWORD PTR [rip+0xc5]        # 1460 <botlish_fn_16+0x198>
    139b:	cmp    rcx,0x6
    139f:	je     13b2 <botlish_fn_16+0xea>
    13a5:	mov    ecx,0x2
    13aa:	mov    rax,rcx
    13ad:	jmp    143f <botlish_fn_16+0x177>
    13b2:	mov    rcx,rax
    13b5:	and    rcx,rbx
    13b8:	test   rcx,0x1
    13bf:	jne    13d0 <botlish_fn_16+0x108>
    13c5:	mov    rdx,rbx
    13c8:	mov    rsi,rax
    13cb:	jmp    13f1 <botlish_fn_16+0x129>
    13d0:	mov    rcx,rax
    13d3:	sub    rcx,rbx
    13d6:	mov    r8,rbx
    13d9:	mov    r13,rax
    13dc:	seto   al
    13df:	lea    rsi,[rcx+0x1]
    13e3:	test   al,al
    13e5:	je     13fc <botlish_fn_16+0x134>
    13eb:	mov    rdx,r8
    13ee:	mov    rsi,r13
    13f1:	mov    rdi,r12
    13f4:	call   13f9 <botlish_fn_16+0x131>
			13f5: R_X86_64_PLT32	rt_int_sub-0x4
    13f9:	mov    rsi,rax
    13fc:	test   rsi,0x1
    1403:	jne    142e <botlish_fn_16+0x166>
    1409:	mov    edx,0x5
    140e:	mov    rdi,r12
    1411:	call   1416 <botlish_fn_16+0x14e>
			1412: R_X86_64_PLT32	rt_int_cmp-0x4
    1416:	mov    ecx,0x2
    141b:	test   rax,rax
    141e:	mov    rax,rcx
    1421:	cmovge rax,QWORD PTR [rip+0x37]        # 1460 <botlish_fn_16+0x198>
    1429:	jmp    143f <botlish_fn_16+0x177>
    142e:	mov    eax,0x2
    1433:	cmp    rsi,0x5
    1437:	cmovge rax,QWORD PTR [rip+0x21]        # 1460 <botlish_fn_16+0x198>
    143f:	mov    rbx,QWORD PTR [rsp+0x20]
    1444:	mov    r12,QWORD PTR [rsp+0x28]
    1449:	mov    r13,QWORD PTR [rsp+0x30]
    144e:	mov    r14,QWORD PTR [rsp+0x38]
    1453:	add    rsp,0x40
    1457:	mov    rsp,rbp
    145a:	pop    rbp
    145b:	ret
    145c:	add    BYTE PTR [rax],al
    145e:	add    BYTE PTR [rax],al
    1460:	(bad)
    1461:	add    BYTE PTR [rax],al
    1463:	add    BYTE PTR [rax],al
    1465:	add    BYTE PTR [rax],al
	...

0000000000001468 <botlish_entry_16: tld?<generic>>:
    1468:	push   rbp
    1469:	mov    rbp,rsp
    146c:	mov    rsi,QWORD PTR [rdx]
    146f:	mov    r8,QWORD PTR [rdx+0x8]
    1473:	mov    rcx,QWORD PTR [rdx+0x10]
    1477:	mov    rdx,r8
    147a:	call   147f <botlish_entry_16+0x17>
			147b: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<generic>
    147f:	mov    rsp,rbp
    1482:	pop    rbp
    1483:	ret
    1484:	add    BYTE PTR [rax],al
	...

0000000000001488 <botlish_fn_17: domain?<generic>>:
    1488:	push   rbp
    1489:	mov    rbp,rsp
    148c:	sub    rsp,0xa0
    1493:	mov    QWORD PTR [rsp+0x70],rbx
    1498:	mov    QWORD PTR [rsp+0x78],r12
    149d:	mov    QWORD PTR [rsp+0x80],r13
    14a5:	mov    QWORD PTR [rsp+0x88],r14
    14ad:	mov    QWORD PTR [rsp+0x90],r15
    14b5:	mov    r8,rdi
    14b8:	mov    QWORD PTR [rsp+0x20],0x0
    14c1:	mov    QWORD PTR [rsp],rsi
    14c5:	mov    QWORD PTR [rsp+0x8],rdx
    14ca:	mov    QWORD PTR [rsp+0x10],rcx
    14cf:	mov    r15,rcx
    14d2:	mov    QWORD PTR [rsp+0x18],rsi
    14d7:	mov    r12,rsi
    14da:	mov    r14,rdx
    14dd:	mov    rdi,rsi
    14e0:	and    rdi,r14
    14e3:	mov    QWORD PTR [rsp+0x58],rsi
    14e8:	test   rdi,0x1
    14ef:	jne    151d <botlish_fn_17+0x95>
    14f5:	mov    rbx,r8
    14f8:	mov    rdx,r14
    14fb:	mov    rsi,QWORD PTR [rsp+0x58]
    1500:	mov    rdi,rbx
    1503:	call   1508 <botlish_fn_17+0x80>
			1504: R_X86_64_PLT32	rt_int_cmp-0x4
    1508:	mov    ecx,0x2
    150d:	test   rax,rax
    1510:	cmovl  rcx,QWORD PTR [rip+0x358]        # 1870 <botlish_fn_17+0x3e8>
    1518:	jmp    1535 <botlish_fn_17+0xad>
    151d:	mov    rbx,r8
    1520:	mov    ecx,0x2
    1525:	mov    rsi,QWORD PTR [rsp+0x58]
    152a:	cmp    rsi,r14
    152d:	cmovl  rcx,QWORD PTR [rip+0x33b]        # 1870 <botlish_fn_17+0x3e8>
    1535:	cmp    rcx,0x6
    1539:	je     1572 <botlish_fn_17+0xea>
    153f:	mov    eax,0x2
    1544:	mov    rbx,QWORD PTR [rsp+0x70]
    1549:	mov    r12,QWORD PTR [rsp+0x78]
    154e:	mov    r13,QWORD PTR [rsp+0x80]
    1556:	mov    r14,QWORD PTR [rsp+0x88]
    155e:	mov    r15,QWORD PTR [rsp+0x90]
    1566:	add    rsp,0xa0
    156d:	mov    rsp,rbp
    1570:	pop    rbp
    1571:	ret
    1572:	lea    rcx,[rsp+0x28]
    1577:	mov    rdx,r15
    157a:	mov    rsi,QWORD PTR [rsp+0x58]
    157f:	mov    rdi,rbx
    1582:	call   1587 <botlish_fn_17+0xff>
			1583: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    1587:	test   rax,rax
    158a:	mov    rsi,rax
    158d:	je     1734 <botlish_fn_17+0x2ac>
    1593:	mov    rdx,QWORD PTR [rsp+0x28]
    1598:	mov    rcx,QWORD PTR [rsp+0x30]
    159d:	mov    rax,QWORD PTR [rbx+0x10]
    15a1:	mov    r8,QWORD PTR [rax]
    15a4:	mov    rdi,rbx
    15a7:	call   15ac <botlish_fn_17+0x124>
			15a8: R_X86_64_PLT32	rt_str_region_eq-0x4
    15ac:	cmp    rax,0x6
    15b0:	je     16a1 <botlish_fn_17+0x219>
    15b6:	lea    rcx,[rsp+0x48]
    15bb:	mov    rdx,r15
    15be:	mov    rsi,QWORD PTR [rsp+0x58]
    15c3:	mov    rdi,rbx
    15c6:	call   15cb <botlish_fn_17+0x143>
			15c7: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    15cb:	test   rax,rax
    15ce:	mov    r13,rax
    15d1:	je     1734 <botlish_fn_17+0x2ac>
    15d7:	mov    rdx,QWORD PTR [rsp+0x48]
    15dc:	mov    QWORD PTR [rsp+0x68],rdx
    15e1:	mov    rcx,QWORD PTR [rsp+0x50]
    15e6:	mov    QWORD PTR [rsp+0x60],rcx
    15eb:	mov    rsi,r13
    15ee:	mov    rdi,rbx
    15f1:	call   15f6 <botlish_fn_17+0x16e>
			15f2: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    15f6:	test   rax,rax
    15f9:	je     1734 <botlish_fn_17+0x2ac>
    15ff:	cmp    rax,0x6
    1603:	je     1644 <botlish_fn_17+0x1bc>
    1609:	mov    rax,QWORD PTR [rbx+0x10]
    160d:	mov    r8,QWORD PTR [rax+0x20]
    1611:	mov    rcx,QWORD PTR [rsp+0x60]
    1616:	mov    rdx,QWORD PTR [rsp+0x68]
    161b:	mov    rsi,r13
    161e:	mov    rdi,rbx
    1621:	call   1626 <botlish_fn_17+0x19e>
			1622: R_X86_64_PLT32	rt_str_region_eq-0x4
    1626:	cmp    rax,0x6
    162a:	je     163a <botlish_fn_17+0x1b2>
    1630:	mov    ecx,0x2
    1635:	jmp    1649 <botlish_fn_17+0x1c1>
    163a:	mov    ecx,0x6
    163f:	jmp    1649 <botlish_fn_17+0x1c1>
    1644:	mov    ecx,0x6
    1649:	cmp    rcx,0x6
    164d:	je     165e <botlish_fn_17+0x1d6>
    1653:	mov    r9d,0x6
    1659:	jmp    1664 <botlish_fn_17+0x1dc>
    165e:	mov    r9d,0x2
    1664:	cmp    r9,0x6
    1668:	jne    176f <botlish_fn_17+0x2e7>
    166e:	mov    eax,0x2
    1673:	mov    rbx,QWORD PTR [rsp+0x70]
    1678:	mov    r12,QWORD PTR [rsp+0x78]
    167d:	mov    r13,QWORD PTR [rsp+0x80]
    1685:	mov    r14,QWORD PTR [rsp+0x88]
    168d:	mov    r15,QWORD PTR [rsp+0x90]
    1695:	add    rsp,0xa0
    169c:	mov    rsp,rbp
    169f:	pop    rbp
    16a0:	ret
    16a1:	mov    rsi,QWORD PTR [rsp+0x58]
    16a6:	mov    r13,rsi
    16a9:	sar    r13,1
    16ac:	mov    rax,r12
    16af:	sar    rax,1
    16b2:	cmp    r13,rax
    16b5:	je     183c <botlish_fn_17+0x3b4>
    16bb:	mov    rsi,r13
    16be:	sub    rsi,0x1
    16c2:	shl    rsi,1
    16c5:	or     rsi,0x1
    16c9:	mov    QWORD PTR [rsp+0x20],rsi
    16ce:	lea    rcx,[rsp+0x38]
    16d3:	mov    rdx,r15
    16d6:	mov    rdi,rbx
    16d9:	call   16de <botlish_fn_17+0x256>
			16da: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    16de:	test   rax,rax
    16e1:	mov    rsi,rax
    16e4:	je     1734 <botlish_fn_17+0x2ac>
    16ea:	mov    rdx,QWORD PTR [rsp+0x38]
    16ef:	mov    rcx,QWORD PTR [rsp+0x40]
    16f4:	mov    rax,QWORD PTR [rbx+0x10]
    16f8:	mov    r8,QWORD PTR [rax]
    16fb:	mov    rdi,rbx
    16fe:	call   1703 <botlish_fn_17+0x27b>
			16ff: R_X86_64_PLT32	rt_str_region_eq-0x4
    1703:	cmp    rax,0x6
    1707:	je     1809 <botlish_fn_17+0x381>
    170d:	lea    rsi,[r13+0x1]
    1711:	shl    rsi,1
    1714:	or     rsi,0x1
    1718:	mov    QWORD PTR [rsp+0x20],rsi
    171d:	mov    rcx,r15
    1720:	mov    rdx,r14
    1723:	mov    rdi,rbx
    1726:	call   172b <botlish_fn_17+0x2a3>
			1727: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<generic>
    172b:	test   rax,rax
    172e:	jne    1765 <botlish_fn_17+0x2dd>
    1734:	xor    rax,rax
    1737:	mov    rbx,QWORD PTR [rsp+0x70]
    173c:	mov    r12,QWORD PTR [rsp+0x78]
    1741:	mov    r13,QWORD PTR [rsp+0x80]
    1749:	mov    r14,QWORD PTR [rsp+0x88]
    1751:	mov    r15,QWORD PTR [rsp+0x90]
    1759:	add    rsp,0xa0
    1760:	mov    rsp,rbp
    1763:	pop    rbp
    1764:	ret
    1765:	cmp    rax,0x6
    1769:	je     17d6 <botlish_fn_17+0x34e>
    176f:	mov    QWORD PTR [rsp+0x20],0x3
    1778:	mov    rsi,QWORD PTR [rsp+0x58]
    177d:	test   rsi,0x1
    1784:	je     17aa <botlish_fn_17+0x322>
    178a:	mov    rsi,QWORD PTR [rsp+0x58]
    178f:	add    rsi,0x2
    1793:	seto   dil
    1797:	test   dil,dil
    179a:	jne    17aa <botlish_fn_17+0x322>
    17a0:	mov    QWORD PTR [rsp+0x58],rsi
    17a5:	jmp    17c4 <botlish_fn_17+0x33c>
    17aa:	mov    edx,0x3
    17af:	mov    rsi,QWORD PTR [rsp+0x58]
    17b4:	mov    rdi,rbx
    17b7:	call   17bc <botlish_fn_17+0x334>
			17b8: R_X86_64_PLT32	rt_int_add-0x4
    17bc:	mov    rsi,rax
    17bf:	mov    QWORD PTR [rsp+0x58],rax
    17c4:	mov    QWORD PTR [rsp+0x18],rsi
    17c9:	mov    rsi,QWORD PTR [rsp+0x58]
    17ce:	mov    r8,rbx
    17d1:	jmp    14dd <botlish_fn_17+0x55>
    17d6:	mov    eax,0x6
    17db:	mov    rbx,QWORD PTR [rsp+0x70]
    17e0:	mov    r12,QWORD PTR [rsp+0x78]
    17e5:	mov    r13,QWORD PTR [rsp+0x80]
    17ed:	mov    r14,QWORD PTR [rsp+0x88]
    17f5:	mov    r15,QWORD PTR [rsp+0x90]
    17fd:	add    rsp,0xa0
    1804:	mov    rsp,rbp
    1807:	pop    rbp
    1808:	ret
    1809:	mov    eax,0x2
    180e:	mov    rbx,QWORD PTR [rsp+0x70]
    1813:	mov    r12,QWORD PTR [rsp+0x78]
    1818:	mov    r13,QWORD PTR [rsp+0x80]
    1820:	mov    r14,QWORD PTR [rsp+0x88]
    1828:	mov    r15,QWORD PTR [rsp+0x90]
    1830:	add    rsp,0xa0
    1837:	mov    rsp,rbp
    183a:	pop    rbp
    183b:	ret
    183c:	mov    eax,0x2
    1841:	mov    rbx,QWORD PTR [rsp+0x70]
    1846:	mov    r12,QWORD PTR [rsp+0x78]
    184b:	mov    r13,QWORD PTR [rsp+0x80]
    1853:	mov    r14,QWORD PTR [rsp+0x88]
    185b:	mov    r15,QWORD PTR [rsp+0x90]
    1863:	add    rsp,0xa0
    186a:	mov    rsp,rbp
    186d:	pop    rbp
    186e:	ret
    186f:	add    BYTE PTR [rsi],al
    1871:	add    BYTE PTR [rax],al
    1873:	add    BYTE PTR [rax],al
    1875:	add    BYTE PTR [rax],al
	...

0000000000001878 <botlish_entry_17: domain?<generic>>:
    1878:	push   rbp
    1879:	mov    rbp,rsp
    187c:	mov    rsi,QWORD PTR [rdx]
    187f:	mov    r8,QWORD PTR [rdx+0x8]
    1883:	mov    rcx,QWORD PTR [rdx+0x10]
    1887:	mov    rdx,r8
    188a:	call   188f <botlish_entry_17+0x17>
			188b: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<generic>
    188f:	mov    rsp,rbp
    1892:	pop    rbp
    1893:	ret

0000000000001894 <botlish_fn_18: web::is_unreserved<int>>:
    1894:	push   rbp
    1895:	mov    rbp,rsp
    1898:	sub    rsp,0x10
    189c:	mov    QWORD PTR [rsp],rbx
    18a0:	mov    QWORD PTR [rsp+0x8],r14
    18a5:	mov    r14,rsi
    18a8:	mov    rsi,r14
    18ab:	sar    rsi,1
    18ae:	mov    rbx,rdi
    18b1:	call   18b6 <botlish_fn_18+0x22>
			18b2: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
    18b6:	cmp    rax,0x6
    18ba:	je     18f1 <botlish_fn_18+0x5d>
    18c0:	mov    rax,QWORD PTR [rbx+0x30]
    18c4:	mov    rsi,QWORD PTR [rax+0x10]
    18c8:	mov    rdx,r14
    18cb:	mov    rdi,rbx
    18ce:	call   18d3 <botlish_fn_18+0x3f>
			18cf: R_X86_64_PLT32	rt_set_contains-0x4
    18d3:	cmp    rax,0x6
    18d7:	je     18e7 <botlish_fn_18+0x53>
    18dd:	mov    eax,0x2
    18e2:	jmp    18f6 <botlish_fn_18+0x62>
    18e7:	mov    eax,0x6
    18ec:	jmp    18f6 <botlish_fn_18+0x62>
    18f1:	mov    eax,0x6
    18f6:	mov    rbx,QWORD PTR [rsp]
    18fa:	mov    r14,QWORD PTR [rsp+0x8]
    18ff:	add    rsp,0x10
    1903:	mov    rsp,rbp
    1906:	pop    rbp
    1907:	ret

0000000000001908 <botlish_entry_18: web::is_unreserved<int>>:
    1908:	push   rbp
    1909:	mov    rbp,rsp
    190c:	mov    rsi,QWORD PTR [rdx]
    190f:	call   1914 <botlish_entry_18+0xc>
			1910: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1914:	mov    rsp,rbp
    1917:	pop    rbp
    1918:	ret

0000000000001919 <botlish_fn_19: web::uri_escape_text<str>>:
    1919:	push   rbp
    191a:	mov    rbp,rsp
    191d:	sub    rsp,0x10
    1921:	mov    edx,0x1
    1926:	mov    QWORD PTR [rsp],0x1
    192e:	mov    r10,QWORD PTR [rdi+0x10]
    1932:	mov    rcx,QWORD PTR [r10+0xe0]
    1939:	mov    QWORD PTR [rsp+0x8],rcx
    193e:	call   1943 <botlish_fn_19+0x2a>
			193f: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    1943:	test   rax,rax
    1946:	jne    1958 <botlish_fn_19+0x3f>
    194c:	xor    rax,rax
    194f:	add    rsp,0x10
    1953:	mov    rsp,rbp
    1956:	pop    rbp
    1957:	ret
    1958:	add    rsp,0x10
    195c:	mov    rsp,rbp
    195f:	pop    rbp
    1960:	ret

0000000000001961 <botlish_entry_19: web::uri_escape_text<str>>:
    1961:	push   rbp
    1962:	mov    rbp,rsp
    1965:	sub    rsp,0x10
    1969:	mov    QWORD PTR [rsp],r12
    196d:	mov    r12,rdi
    1970:	mov    rsi,QWORD PTR [rdx]
    1973:	mov    r8,QWORD PTR [rip+0x0]        # 197a <botlish_entry_19+0x19>
			1976: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    197a:	call   r8
    197d:	mov    rsi,rax
    1980:	mov    rdi,r12
    1983:	call   1988 <botlish_entry_19+0x27>
			1984: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_escape_text<str>
    1988:	mov    r12,QWORD PTR [rsp]
    198c:	add    rsp,0x10
    1990:	mov    rsp,rbp
    1993:	pop    rbp
    1994:	ret

0000000000001995 <botlish_fn_20: high_nibble<int>>:
    1995:	push   rbp
    1996:	mov    rbp,rsp
    1999:	sub    rsp,0x10
    199d:	mov    QWORD PTR [rsp],rsi
    19a1:	mov    QWORD PTR [rsp+0x8],0x1e1
    19aa:	test   rsi,0x1
    19b1:	jne    19c6 <botlish_fn_20+0x31>
    19b7:	mov    edx,0x1e1
    19bc:	call   19c1 <botlish_fn_20+0x2c>
			19bd: R_X86_64_PLT32	rt_int_and-0x4
    19c1:	jmp    19d0 <botlish_fn_20+0x3b>
    19c6:	and    rsi,0x1e1
    19cd:	mov    rax,rsi
    19d0:	sar    rax,0x5
    19d4:	shl    rax,1
    19d7:	or     rax,0x1
    19db:	add    rsp,0x10
    19df:	mov    rsp,rbp
    19e2:	pop    rbp
    19e3:	ret

00000000000019e4 <botlish_entry_20: high_nibble<int>>:
    19e4:	push   rbp
    19e5:	mov    rbp,rsp
    19e8:	mov    rsi,QWORD PTR [rdx]
    19eb:	call   19f0 <botlish_entry_20+0xc>
			19ec: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    19f0:	mov    rsp,rbp
    19f3:	pop    rbp
    19f4:	ret

00000000000019f5 <botlish_fn_21: hex_pair<int>>:
    19f5:	push   rbp
    19f6:	mov    rbp,rsp
    19f9:	sub    rsp,0x50
    19fd:	mov    QWORD PTR [rsp+0x30],rbx
    1a02:	mov    QWORD PTR [rsp+0x38],r12
    1a07:	mov    QWORD PTR [rsp+0x40],r13
    1a0c:	mov    QWORD PTR [rsp+0x48],r14
    1a11:	mov    QWORD PTR [rsp],rsi
    1a15:	mov    r12,rsi
    1a18:	mov    rax,QWORD PTR [rdi+0x30]
    1a1c:	mov    rbx,rdi
    1a1f:	mov    rsi,QWORD PTR [rax+0x8]
    1a23:	mov    QWORD PTR [rsp+0x8],rsi
    1a28:	mov    r13,rsi
    1a2b:	mov    rsi,r12
    1a2e:	call   1a33 <botlish_fn_21+0x3e>
			1a2f: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    1a33:	test   rax,0x1
    1a39:	jne    1a4a <botlish_fn_21+0x55>
    1a3f:	mov    rdx,rax
    1a42:	mov    rsi,r13
    1a45:	jmp    1a63 <botlish_fn_21+0x6e>
    1a4a:	mov    rsi,r13
    1a4d:	mov    rdx,QWORD PTR [rsi+0x8]
    1a51:	mov    rcx,rax
    1a54:	sar    rcx,1
    1a57:	cmp    rcx,rdx
    1a5a:	jb     1a79 <botlish_fn_21+0x84>
    1a60:	mov    rdx,rax
    1a63:	mov    rdi,rbx
    1a66:	call   1a6b <botlish_fn_21+0x76>
			1a67: R_X86_64_PLT32	rt_list_get-0x4
    1a6b:	test   rax,rax
    1a6e:	je     1b3e <botlish_fn_21+0x149>
    1a74:	jmp    1a81 <botlish_fn_21+0x8c>
    1a79:	mov    rax,QWORD PTR [rsi+0x10]
    1a7d:	mov    rax,QWORD PTR [rax+rcx*8]
    1a81:	mov    QWORD PTR [rsp],rax
    1a85:	mov    rdi,rbx
    1a88:	mov    r14,rax
    1a8b:	mov    rax,QWORD PTR [rdi+0x30]
    1a8f:	mov    rsi,QWORD PTR [rax+0x8]
    1a93:	mov    r13,rsi
    1a96:	mov    edx,0x21
    1a9b:	mov    rsi,r12
    1a9e:	call   1aa3 <botlish_fn_21+0xae>
			1a9f: R_X86_64_PLT32	rt_int_mod-0x4
    1aa3:	test   rax,rax
    1aa6:	je     1b3e <botlish_fn_21+0x149>
    1aac:	test   rax,0x1
    1ab2:	jne    1ac3 <botlish_fn_21+0xce>
    1ab8:	mov    rdx,rax
    1abb:	mov    rsi,r13
    1abe:	jmp    1adc <botlish_fn_21+0xe7>
    1ac3:	mov    rsi,r13
    1ac6:	mov    rdx,QWORD PTR [rsi+0x8]
    1aca:	mov    rcx,rax
    1acd:	sar    rcx,1
    1ad0:	cmp    rcx,rdx
    1ad3:	jb     1af2 <botlish_fn_21+0xfd>
    1ad9:	mov    rdx,rax
    1adc:	mov    rdi,rbx
    1adf:	call   1ae4 <botlish_fn_21+0xef>
			1ae0: R_X86_64_PLT32	rt_list_get-0x4
    1ae4:	test   rax,rax
    1ae7:	je     1b3e <botlish_fn_21+0x149>
    1aed:	jmp    1afa <botlish_fn_21+0x105>
    1af2:	mov    rax,QWORD PTR [rsi+0x10]
    1af6:	mov    rax,QWORD PTR [rax+rcx*8]
    1afa:	mov    QWORD PTR [rsp+0x8],rax
    1aff:	lea    rcx,[rsp+0x10]
    1b04:	mov    QWORD PTR [rsp+0x10],0x0
    1b0d:	mov    rdx,r14
    1b10:	mov    QWORD PTR [rsp+0x18],rdx
    1b15:	mov    QWORD PTR [rsp+0x20],0x0
    1b1e:	mov    QWORD PTR [rsp+0x28],rax
    1b23:	mov    esi,0x2
    1b28:	mov    edx,0x4
    1b2d:	mov    rdi,rbx
    1b30:	call   1b35 <botlish_fn_21+0x140>
			1b31: R_X86_64_PLT32	rt_construct-0x4
    1b35:	test   rax,rax
    1b38:	jne    1b5e <botlish_fn_21+0x169>
    1b3e:	xor    rax,rax
    1b41:	mov    rbx,QWORD PTR [rsp+0x30]
    1b46:	mov    r12,QWORD PTR [rsp+0x38]
    1b4b:	mov    r13,QWORD PTR [rsp+0x40]
    1b50:	mov    r14,QWORD PTR [rsp+0x48]
    1b55:	add    rsp,0x50
    1b59:	mov    rsp,rbp
    1b5c:	pop    rbp
    1b5d:	ret
    1b5e:	mov    rbx,QWORD PTR [rsp+0x30]
    1b63:	mov    r12,QWORD PTR [rsp+0x38]
    1b68:	mov    r13,QWORD PTR [rsp+0x40]
    1b6d:	mov    r14,QWORD PTR [rsp+0x48]
    1b72:	add    rsp,0x50
    1b76:	mov    rsp,rbp
    1b79:	pop    rbp
    1b7a:	ret

0000000000001b7b <botlish_entry_21: hex_pair<int>>:
    1b7b:	push   rbp
    1b7c:	mov    rbp,rsp
    1b7f:	sub    rsp,0x10
    1b83:	mov    QWORD PTR [rsp],r12
    1b87:	mov    r12,rdi
    1b8a:	mov    rsi,QWORD PTR [rdx]
    1b8d:	call   1b92 <botlish_entry_21+0x17>
			1b8e: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1b92:	mov    r8,QWORD PTR [rip+0x0]        # 1b99 <botlish_entry_21+0x1e>
			1b95: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1b99:	mov    rsi,rax
    1b9c:	mov    rdi,r12
    1b9f:	call   r8
    1ba2:	mov    r12,QWORD PTR [rsp]
    1ba6:	add    rsp,0x10
    1baa:	mov    rsp,rbp
    1bad:	pop    rbp
    1bae:	ret

0000000000001baf <botlish_fn_22: esc_bytes<List[int], int, str>>:
    1baf:	push   rbp
    1bb0:	mov    rbp,rsp
    1bb3:	sub    rsp,0x90
    1bba:	mov    QWORD PTR [rsp+0x60],rbx
    1bbf:	mov    QWORD PTR [rsp+0x68],r12
    1bc4:	mov    QWORD PTR [rsp+0x70],r13
    1bc9:	mov    QWORD PTR [rsp+0x78],r14
    1bce:	mov    QWORD PTR [rsp+0x80],r15
    1bd6:	mov    QWORD PTR [rsp],rsi
    1bda:	mov    QWORD PTR [rsp+0x8],rcx
    1bdf:	sar    rdx,1
    1be2:	mov    r13,rdx
    1be5:	lea    r14,[rsp+0x20]
    1bea:	mov    rbx,rdi
    1bed:	mov    r12,rsi
    1bf0:	mov    QWORD PTR [rsp+0x50],rcx
    1bf5:	mov    rsi,r12
    1bf8:	mov    rdi,rbx
    1bfb:	call   1c00 <botlish_fn_22+0x51>
			1bfc: R_X86_64_PLT32	rt_list_len-0x4
    1c00:	sar    rax,1
    1c03:	cmp    r13,rax
    1c06:	jge    1d16 <botlish_fn_22+0x167>
    1c0c:	mov    rax,QWORD PTR [rbx+0x10]
    1c10:	mov    r15,QWORD PTR [rax+0x10]
    1c14:	mov    QWORD PTR [rsp+0x10],r15
    1c19:	mov    rcx,QWORD PTR [r12+0x8]
    1c1e:	mov    rax,r13
    1c21:	shl    rax,1
    1c24:	or     rax,0x1
    1c28:	sar    rax,1
    1c2b:	cmp    rax,rcx
    1c2e:	jb     1c5a <botlish_fn_22+0xab>
    1c34:	mov    rdx,r13
    1c37:	shl    rdx,1
    1c3a:	or     rdx,0x1
    1c3e:	mov    rsi,r12
    1c41:	mov    rdi,rbx
    1c44:	call   1c49 <botlish_fn_22+0x9a>
			1c45: R_X86_64_PLT32	rt_list_get-0x4
    1c49:	test   rax,rax
    1c4c:	je     1cd1 <botlish_fn_22+0x122>
    1c52:	mov    rsi,rax
    1c55:	jmp    1c63 <botlish_fn_22+0xb4>
    1c5a:	mov    rcx,QWORD PTR [r12+0x10]
    1c5f:	mov    rsi,QWORD PTR [rcx+rax*8]
    1c63:	mov    QWORD PTR [rsp+0x18],rsi
    1c68:	mov    rdi,rbx
    1c6b:	call   1c70 <botlish_fn_22+0xc1>
			1c6c: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1c70:	test   rax,rax
    1c73:	je     1cd1 <botlish_fn_22+0x122>
    1c79:	mov    QWORD PTR [rsp+0x18],rax
    1c7e:	mov    rcx,rax
    1c81:	mov    QWORD PTR [rsp+0x20],0x0
    1c8a:	mov    rax,QWORD PTR [rsp+0x50]
    1c8f:	mov    QWORD PTR [rsp+0x28],rax
    1c94:	mov    QWORD PTR [rsp+0x30],0x0
    1c9d:	mov    QWORD PTR [rsp+0x38],r15
    1ca2:	mov    QWORD PTR [rsp+0x40],0x0
    1cab:	mov    rax,rcx
    1cae:	mov    QWORD PTR [rsp+0x48],rax
    1cb3:	mov    esi,0x2
    1cb8:	mov    edx,0x6
    1cbd:	mov    rcx,r14
    1cc0:	mov    rdi,rbx
    1cc3:	call   1cc8 <botlish_fn_22+0x119>
			1cc4: R_X86_64_PLT32	rt_construct-0x4
    1cc8:	test   rax,rax
    1ccb:	jne    1cfc <botlish_fn_22+0x14d>
    1cd1:	xor    rax,rax
    1cd4:	mov    rbx,QWORD PTR [rsp+0x60]
    1cd9:	mov    r12,QWORD PTR [rsp+0x68]
    1cde:	mov    r13,QWORD PTR [rsp+0x70]
    1ce3:	mov    r14,QWORD PTR [rsp+0x78]
    1ce8:	mov    r15,QWORD PTR [rsp+0x80]
    1cf0:	add    rsp,0x90
    1cf7:	mov    rsp,rbp
    1cfa:	pop    rbp
    1cfb:	ret
    1cfc:	mov    QWORD PTR [rsp],r12
    1d00:	mov    QWORD PTR [rsp+0x8],rax
    1d05:	add    r13,0x1
    1d0c:	mov    QWORD PTR [rsp+0x50],rax
    1d11:	jmp    1bf5 <botlish_fn_22+0x46>
    1d16:	mov    rax,QWORD PTR [rsp+0x50]
    1d1b:	mov    rbx,QWORD PTR [rsp+0x60]
    1d20:	mov    r12,QWORD PTR [rsp+0x68]
    1d25:	mov    r13,QWORD PTR [rsp+0x70]
    1d2a:	mov    r14,QWORD PTR [rsp+0x78]
    1d2f:	mov    r15,QWORD PTR [rsp+0x80]
    1d37:	add    rsp,0x90
    1d3e:	mov    rsp,rbp
    1d41:	pop    rbp
    1d42:	ret

0000000000001d43 <botlish_entry_22: esc_bytes<List[int], int, str>>:
    1d43:	push   rbp
    1d44:	mov    rbp,rsp
    1d47:	sub    rsp,0x10
    1d4b:	mov    QWORD PTR [rsp],r12
    1d4f:	mov    r12,rdi
    1d52:	mov    rsi,QWORD PTR [rdx]
    1d55:	mov    r8,QWORD PTR [rdx+0x8]
    1d59:	mov    rcx,QWORD PTR [rdx+0x10]
    1d5d:	mov    rdx,r8
    1d60:	call   1d65 <botlish_entry_22+0x22>
			1d61: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1d65:	mov    r8,QWORD PTR [rip+0x0]        # 1d6c <botlish_entry_22+0x29>
			1d68: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1d6c:	mov    rsi,rax
    1d6f:	mov    rdi,r12
    1d72:	call   r8
    1d75:	mov    r12,QWORD PTR [rsp]
    1d79:	add    rsp,0x10
    1d7d:	mov    rsp,rbp
    1d80:	pop    rbp
    1d81:	ret

0000000000001d82 <botlish_fn_23: esc_char<str>>:
    1d82:	push   rbp
    1d83:	mov    rbp,rsp
    1d86:	sub    rsp,0x40
    1d8a:	mov    QWORD PTR [rsp+0x20],rbx
    1d8f:	mov    QWORD PTR [rsp+0x28],r12
    1d94:	mov    QWORD PTR [rsp+0x30],r13
    1d99:	mov    rbx,rdi
    1d9c:	mov    QWORD PTR [rsp+0x8],0x0
    1da5:	mov    QWORD PTR [rsp+0x10],0x0
    1dae:	mov    QWORD PTR [rsp],rsi
    1db2:	mov    r13,rsi
    1db5:	mov    rsi,r13
    1db8:	mov    rdi,rbx
    1dbb:	call   1dc0 <botlish_fn_23+0x3e>
			1dbc: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1dc0:	mov    rcx,rax
    1dc3:	mov    r12,rax
    1dc6:	test   rax,rcx
    1dc9:	je     1ea7 <botlish_fn_23+0x125>
    1dcf:	mov    rax,r12
    1dd2:	mov    QWORD PTR [rsp],rax
    1dd6:	mov    rsi,r12
    1dd9:	mov    rdi,rbx
    1ddc:	call   1de1 <botlish_fn_23+0x5f>
			1ddd: R_X86_64_PLT32	rt_list_len-0x4
    1de1:	sar    rax,1
    1de4:	cmp    rax,0x1
    1de8:	je     1e25 <botlish_fn_23+0xa3>
    1dee:	mov    edx,0x1
    1df3:	mov    QWORD PTR [rsp+0x8],0x1
    1dfc:	mov    rdi,rbx
    1dff:	mov    rax,QWORD PTR [rdi+0x10]
    1e03:	mov    rcx,QWORD PTR [rax+0xe0]
    1e0a:	mov    QWORD PTR [rsp+0x10],rcx
    1e0f:	mov    rsi,r12
    1e12:	call   1e17 <botlish_fn_23+0x95>
			1e13: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1e17:	test   rax,rax
    1e1a:	je     1ea7 <botlish_fn_23+0x125>
    1e20:	jmp    1ec8 <botlish_fn_23+0x146>
    1e25:	mov    rsi,r12
    1e28:	mov    rax,QWORD PTR [rsi+0x8]
    1e2c:	mov    r12,rsi
    1e2f:	test   rax,rax
    1e32:	jne    1e59 <botlish_fn_23+0xd7>
    1e38:	mov    edx,0x1
    1e3d:	mov    rsi,r12
    1e40:	mov    rdi,rbx
    1e43:	call   1e48 <botlish_fn_23+0xc6>
			1e44: R_X86_64_PLT32	rt_list_get-0x4
    1e48:	test   rax,rax
    1e4b:	je     1ea7 <botlish_fn_23+0x125>
    1e51:	mov    rsi,rax
    1e54:	jmp    1e63 <botlish_fn_23+0xe1>
    1e59:	mov    rsi,r12
    1e5c:	mov    rax,QWORD PTR [rsi+0x10]
    1e60:	mov    rsi,QWORD PTR [rax]
    1e63:	mov    rdi,rbx
    1e66:	call   1e6b <botlish_fn_23+0xe9>
			1e67: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1e6b:	cmp    rax,0x6
    1e6f:	je     1ec5 <botlish_fn_23+0x143>
    1e75:	mov    edx,0x1
    1e7a:	mov    QWORD PTR [rsp+0x8],0x1
    1e83:	mov    rdi,rbx
    1e86:	mov    rax,QWORD PTR [rdi+0x10]
    1e8a:	mov    rcx,QWORD PTR [rax+0xe0]
    1e91:	mov    QWORD PTR [rsp+0x10],rcx
    1e96:	mov    rsi,r12
    1e99:	call   1e9e <botlish_fn_23+0x11c>
			1e9a: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1e9e:	test   rax,rax
    1ea1:	jne    1ec2 <botlish_fn_23+0x140>
    1ea7:	xor    rax,rax
    1eaa:	mov    rbx,QWORD PTR [rsp+0x20]
    1eaf:	mov    r12,QWORD PTR [rsp+0x28]
    1eb4:	mov    r13,QWORD PTR [rsp+0x30]
    1eb9:	add    rsp,0x40
    1ebd:	mov    rsp,rbp
    1ec0:	pop    rbp
    1ec1:	ret
    1ec2:	mov    r13,rax
    1ec5:	mov    rax,r13
    1ec8:	mov    rbx,QWORD PTR [rsp+0x20]
    1ecd:	mov    r12,QWORD PTR [rsp+0x28]
    1ed2:	mov    r13,QWORD PTR [rsp+0x30]
    1ed7:	add    rsp,0x40
    1edb:	mov    rsp,rbp
    1ede:	pop    rbp
    1edf:	ret

0000000000001ee0 <botlish_entry_23: esc_char<str>>:
    1ee0:	push   rbp
    1ee1:	mov    rbp,rsp
    1ee4:	sub    rsp,0x10
    1ee8:	mov    QWORD PTR [rsp],r12
    1eec:	mov    r12,rdi
    1eef:	mov    rsi,QWORD PTR [rdx]
    1ef2:	call   1ef7 <botlish_entry_23+0x17>
			1ef3: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1ef7:	mov    r8,QWORD PTR [rip+0x0]        # 1efe <botlish_entry_23+0x1e>
			1efa: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1efe:	mov    rsi,rax
    1f01:	mov    rdi,r12
    1f04:	call   r8
    1f07:	mov    r12,QWORD PTR [rsp]
    1f0b:	add    rsp,0x10
    1f0f:	mov    rsp,rbp
    1f12:	pop    rbp
    1f13:	ret

0000000000001f14 <botlish_fn_24: esc_from<str, int, str>>:
    1f14:	push   rbp
    1f15:	mov    rbp,rsp
    1f18:	sub    rsp,0x90
    1f1f:	mov    QWORD PTR [rsp+0x60],rbx
    1f24:	mov    QWORD PTR [rsp+0x68],r12
    1f29:	mov    QWORD PTR [rsp+0x70],r13
    1f2e:	mov    QWORD PTR [rsp+0x78],r14
    1f33:	mov    QWORD PTR [rsp+0x80],r15
    1f3b:	mov    r14,rdi
    1f3e:	mov    QWORD PTR [rsp+0x8],0x0
    1f47:	mov    QWORD PTR [rsp+0x10],0x0
    1f50:	mov    QWORD PTR [rsp+0x18],0x0
    1f59:	mov    QWORD PTR [rsp],rcx
    1f5d:	mov    QWORD PTR [rsp+0x50],rcx
    1f62:	sar    rdx,1
    1f65:	mov    r13d,0x47
    1f6b:	mov    rcx,0xffffffffffffffff
    1f72:	bsr    rax,rsi
    1f76:	mov    r15,rsi
    1f79:	cmove  rax,rcx
    1f7d:	mov    ecx,0x3f
    1f82:	sub    rcx,rax
    1f85:	sub    r13,rcx
    1f88:	shr    r13,0x3
    1f8c:	lea    rbx,[rsp+0x30]
    1f91:	mov    r12,rdx
    1f94:	cmp    r12,r13
    1f97:	jge    2051 <botlish_fn_24+0x13d>
    1f9d:	mov    rsi,r15
    1fa0:	mov    rdi,r14
    1fa3:	call   1fa8 <botlish_fn_24+0x94>
			1fa4: R_X86_64_PLT32	rt_ascii_to_str-0x4
    1fa8:	mov    QWORD PTR [rsp+0x8],rax
    1fad:	mov    rdx,r12
    1fb0:	shl    rdx,1
    1fb3:	or     rdx,0x1
    1fb7:	mov    QWORD PTR [rsp+0x10],rdx
    1fbc:	add    r12,0x1
    1fc3:	mov    rcx,r12
    1fc6:	shl    rcx,1
    1fc9:	or     rcx,0x1
    1fcd:	mov    QWORD PTR [rsp+0x18],rcx
    1fd2:	mov    rsi,rax
    1fd5:	mov    rdi,r14
    1fd8:	call   1fdd <botlish_fn_24+0xc9>
			1fd9: R_X86_64_PLT32	rt_substr-0x4
    1fdd:	test   rax,rax
    1fe0:	je     2085 <botlish_fn_24+0x171>
    1fe6:	mov    QWORD PTR [rsp+0x8],rax
    1feb:	mov    rsi,rax
    1fee:	mov    rdi,r14
    1ff1:	call   1ff6 <botlish_fn_24+0xe2>
			1ff2: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1ff6:	test   rax,rax
    1ff9:	je     2085 <botlish_fn_24+0x171>
    1fff:	mov    QWORD PTR [rsp+0x8],rax
    2004:	mov    QWORD PTR [rsp+0x30],0x0
    200d:	mov    rcx,QWORD PTR [rsp+0x50]
    2012:	mov    QWORD PTR [rsp+0x38],rcx
    2017:	mov    QWORD PTR [rsp+0x40],0x0
    2020:	mov    QWORD PTR [rsp+0x48],rax
    2025:	mov    esi,0x2
    202a:	mov    edx,0x4
    202f:	mov    rcx,rbx
    2032:	mov    rdi,r14
    2035:	call   203a <botlish_fn_24+0x126>
			2036: R_X86_64_PLT32	rt_construct-0x4
    203a:	test   rax,rax
    203d:	je     2085 <botlish_fn_24+0x171>
    2043:	mov    QWORD PTR [rsp],rax
    2047:	mov    QWORD PTR [rsp+0x50],rax
    204c:	jmp    1f94 <botlish_fn_24+0x80>
    2051:	mov    rcx,QWORD PTR [rsp+0x50]
    2056:	xor    rsi,rsi
    2059:	lea    rax,[rsp+0x20]
    205e:	mov    QWORD PTR [rsp+0x20],0x0
    2067:	mov    QWORD PTR [rsp+0x28],rcx
    206c:	mov    edx,0x2
    2071:	mov    rcx,rax
    2074:	mov    rdi,r14
    2077:	call   207c <botlish_fn_24+0x168>
			2078: R_X86_64_PLT32	rt_construct-0x4
    207c:	test   rax,rax
    207f:	jne    20b0 <botlish_fn_24+0x19c>
    2085:	xor    rax,rax
    2088:	mov    rbx,QWORD PTR [rsp+0x60]
    208d:	mov    r12,QWORD PTR [rsp+0x68]
    2092:	mov    r13,QWORD PTR [rsp+0x70]
    2097:	mov    r14,QWORD PTR [rsp+0x78]
    209c:	mov    r15,QWORD PTR [rsp+0x80]
    20a4:	add    rsp,0x90
    20ab:	mov    rsp,rbp
    20ae:	pop    rbp
    20af:	ret
    20b0:	mov    rbx,QWORD PTR [rsp+0x60]
    20b5:	mov    r12,QWORD PTR [rsp+0x68]
    20ba:	mov    r13,QWORD PTR [rsp+0x70]
    20bf:	mov    r14,QWORD PTR [rsp+0x78]
    20c4:	mov    r15,QWORD PTR [rsp+0x80]
    20cc:	add    rsp,0x90
    20d3:	mov    rsp,rbp
    20d6:	pop    rbp
    20d7:	ret

00000000000020d8 <botlish_entry_24: esc_from<str, int, str>>:
    20d8:	push   rbp
    20d9:	mov    rbp,rsp
    20dc:	sub    rsp,0x10
    20e0:	mov    QWORD PTR [rsp],r12
    20e4:	mov    QWORD PTR [rsp+0x8],r13
    20e9:	mov    r12,rdi
    20ec:	mov    rsi,QWORD PTR [rdx]
    20ef:	mov    r13,rdx
    20f2:	mov    r8,QWORD PTR [rip+0x0]        # 20f9 <botlish_entry_24+0x21>
			20f5: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    20f9:	call   r8
    20fc:	mov    rcx,r13
    20ff:	mov    rdx,QWORD PTR [rcx+0x8]
    2103:	mov    rcx,QWORD PTR [rcx+0x10]
    2107:	mov    rsi,rax
    210a:	mov    rdi,r12
    210d:	call   2112 <botlish_entry_24+0x3a>
			210e: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    2112:	mov    r12,QWORD PTR [rsp]
    2116:	mov    r13,QWORD PTR [rsp+0x8]
    211b:	add    rsp,0x10
    211f:	mov    rsp,rbp
    2122:	pop    rbp
    2123:	ret

0000000000002124 <botlish_fn_25: check<int, int, str, str>>:
    2124:	push   rbp
    2125:	mov    rbp,rsp
    2128:	sub    rsp,0x50
    212c:	mov    QWORD PTR [rsp+0x20],rbx
    2131:	mov    QWORD PTR [rsp+0x28],r12
    2136:	mov    QWORD PTR [rsp+0x30],r13
    213b:	mov    QWORD PTR [rsp+0x38],r14
    2140:	mov    QWORD PTR [rsp+0x40],r15
    2145:	mov    r14,rdi
    2148:	mov    QWORD PTR [rsp+0x18],0x0
    2151:	mov    QWORD PTR [rsp],rdx
    2155:	mov    QWORD PTR [rsp+0x8],rcx
    215a:	mov    QWORD PTR [rsp+0x10],r8
    215f:	mov    r13,r8
    2162:	mov    r12,rsi
    2165:	mov    r15,rdx
    2168:	test   r12,r12
    216b:	jle    222d <botlish_fn_25+0x109>
    2171:	mov    rbx,rcx
    2174:	mov    rsi,rbx
    2177:	mov    rdi,r14
    217a:	call   217f <botlish_fn_25+0x5b>
			217b: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
    217f:	test   rax,rax
    2182:	jne    21ad <botlish_fn_25+0x89>
    2188:	xor    rax,rax
    218b:	mov    rbx,QWORD PTR [rsp+0x20]
    2190:	mov    r12,QWORD PTR [rsp+0x28]
    2195:	mov    r13,QWORD PTR [rsp+0x30]
    219a:	mov    r14,QWORD PTR [rsp+0x38]
    219f:	mov    r15,QWORD PTR [rsp+0x40]
    21a4:	add    rsp,0x50
    21a8:	mov    rsp,rbp
    21ab:	pop    rbp
    21ac:	ret
    21ad:	cmp    rax,0x6
    21b1:	je     21cd <botlish_fn_25+0xa9>
    21b7:	mov    edx,0x1
    21bc:	mov    QWORD PTR [rsp+0x18],0x1
    21c5:	mov    rsi,r15
    21c8:	jmp    21de <botlish_fn_25+0xba>
    21cd:	mov    edx,0x3
    21d2:	mov    QWORD PTR [rsp+0x18],0x3
    21db:	mov    rsi,r15
    21de:	mov    rax,rsi
    21e1:	and    rax,rdx
    21e4:	test   rax,0x1
    21ea:	je     2205 <botlish_fn_25+0xe1>
    21f0:	lea    rcx,[rdx-0x1]
    21f4:	mov    rax,rsi
    21f7:	add    rax,rcx
    21fa:	seto   cl
    21fd:	test   cl,cl
    21ff:	je     220d <botlish_fn_25+0xe9>
    2205:	mov    rdi,r14
    2208:	call   220d <botlish_fn_25+0xe9>
			2209: R_X86_64_PLT32	rt_int_add-0x4
    220d:	mov    QWORD PTR [rsp],rax
    2211:	mov    QWORD PTR [rsp+0x8],rbx
    2216:	mov    r8,r13
    2219:	mov    QWORD PTR [rsp+0x10],r8
    221e:	sub    r12,0x1
    2222:	mov    rcx,rbx
    2225:	mov    r15,rax
    2228:	jmp    2168 <botlish_fn_25+0x44>
    222d:	mov    rax,r15
    2230:	mov    rbx,QWORD PTR [rsp+0x20]
    2235:	mov    r12,QWORD PTR [rsp+0x28]
    223a:	mov    r13,QWORD PTR [rsp+0x30]
    223f:	mov    r14,QWORD PTR [rsp+0x38]
    2244:	mov    r15,QWORD PTR [rsp+0x40]
    2249:	add    rsp,0x50
    224d:	mov    rsp,rbp
    2250:	pop    rbp
    2251:	ret

0000000000002252 <botlish_entry_25: check<int, int, str, str>>:
    2252:	push   rbp
    2253:	mov    rbp,rsp
    2256:	mov    rsi,QWORD PTR [rdx]
    2259:	mov    r9,QWORD PTR [rdx+0x8]
    225d:	mov    rcx,QWORD PTR [rdx+0x10]
    2261:	mov    r8,QWORD PTR [rdx+0x18]
    2265:	sar    rsi,1
    2268:	mov    rdx,r9
    226b:	call   2270 <botlish_entry_25+0x1e>
			226c: R_X86_64_PLT32	botlish_fn_25-0x4 ; check<int, int, str, str>
    2270:	mov    rsp,rbp
    2273:	pop    rbp
    2274:	ret

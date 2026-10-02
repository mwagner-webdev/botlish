; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 8699  (per function: 1415 39 289 609 74 74 74 128 128 374 166 111 176 238 440 448 212 1060 140 127 103 474 491 426 539 344)
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
;   botlish_fn_10 / botlish_entry_10 -> char_at<int>
;   botlish_fn_11 / botlish_entry_11 -> char_at<int>
;   botlish_fn_12 / botlish_entry_12 -> local_char?<str>
;   botlish_fn_13 / botlish_entry_13 -> local_char?<generic>
;   botlish_fn_14 / botlish_entry_14 -> scan_while<int, block(e239)>
;   botlish_fn_15 / botlish_entry_15 -> scan_while<int, native(is_tcl_alpha)>
;   botlish_fn_16 / botlish_entry_16 -> tld?<int>
;   botlish_fn_17 / botlish_entry_17 -> domain?<int>
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
			b10: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, block(e239)>
     b14:	test   rax,rax
     b17:	je     bb5 <botlish_fn_9+0x106>
     b1d:	mov    rbx,rax
     b20:	sar    rbx,1
     b23:	mov    rsi,rax
     b26:	test   rbx,rbx
     b29:	je     be4 <botlish_fn_9+0x135>
     b2f:	mov    rax,r14
     b32:	mov    rcx,rax
     b35:	sar    rcx,1
     b38:	cmp    rbx,rcx
     b3b:	jge    bda <botlish_fn_9+0x12b>
     b41:	lea    rcx,[rsp+0x20]
     b46:	mov    rdx,r12
     b49:	mov    rdi,r13
     b4c:	call   b51 <botlish_fn_9+0xa2>
			b4d: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
     b51:	test   rax,rax
     b54:	mov    rsi,rax
     b57:	je     bb5 <botlish_fn_9+0x106>
     b5d:	mov    rdx,QWORD PTR [rsp+0x20]
     b62:	mov    rcx,QWORD PTR [rsp+0x28]
     b67:	mov    rdi,r13
     b6a:	mov    rax,QWORD PTR [rdi+0x10]
     b6e:	mov    r8,QWORD PTR [rax+0xc8]
     b75:	call   b7a <botlish_fn_9+0xcb>
			b76: R_X86_64_PLT32	rt_str_region_eq-0x4
     b7a:	cmp    rax,0x6
     b7e:	je     b8e <botlish_fn_9+0xdf>
     b84:	mov    eax,0x2
     b89:	jmp    be9 <botlish_fn_9+0x13a>
     b8e:	lea    rsi,[rbx+0x1]
     b92:	shl    rsi,1
     b95:	or     rsi,0x1
     b99:	mov    QWORD PTR [rsp+0x10],rsi
     b9e:	mov    rcx,r12
     ba1:	mov    rdx,r14
     ba4:	mov    rdi,r13
     ba7:	call   bac <botlish_fn_9+0xfd>
			ba8: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<int>
     bac:	test   rax,rax
     baf:	jne    be9 <botlish_fn_9+0x13a>
     bb5:	xor    rax,rax
     bb8:	mov    rbx,QWORD PTR [rsp+0x30]
     bbd:	mov    r12,QWORD PTR [rsp+0x38]
     bc2:	mov    r13,QWORD PTR [rsp+0x40]
     bc7:	mov    r14,QWORD PTR [rsp+0x48]
     bcc:	add    rsp,0x50
     bd0:	mov    rsp,rbp
     bd3:	pop    rbp
     bd4:	ret
     bd5:	jmp    be9 <botlish_fn_9+0x13a>
     bda:	mov    eax,0x2
     bdf:	jmp    be9 <botlish_fn_9+0x13a>
     be4:	mov    eax,0x2
     be9:	mov    rbx,QWORD PTR [rsp+0x30]
     bee:	mov    r12,QWORD PTR [rsp+0x38]
     bf3:	mov    r13,QWORD PTR [rsp+0x40]
     bf8:	mov    r14,QWORD PTR [rsp+0x48]
     bfd:	add    rsp,0x50
     c01:	mov    rsp,rbp
     c04:	pop    rbp
     c05:	ret

0000000000000c06 <botlish_entry_9: web::emailish?<str>>:
     c06:	push   rbp
     c07:	mov    rbp,rsp
     c0a:	mov    rsi,QWORD PTR [rdx]
     c0d:	call   c12 <botlish_entry_9+0xc>
			c0e: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
     c12:	mov    rsp,rbp
     c15:	pop    rbp
     c16:	ret

0000000000000c17 <botlish_fn_10: char_at<int>>:
     c17:	push   rbp
     c18:	mov    rbp,rsp
     c1b:	sub    rsp,0x20
     c1f:	mov    QWORD PTR [rsp],rbx
     c23:	mov    QWORD PTR [rsp+0x8],r12
     c28:	mov    QWORD PTR [rsp+0x10],r13
     c2d:	mov    QWORD PTR [rsp+0x18],r15
     c32:	mov    r13,rdx
     c35:	mov    r15,rcx
     c38:	mov    rax,rsi
     c3b:	sar    rax,1
     c3e:	lea    r12,[rax+0x1]
     c42:	shl    r12,1
     c45:	mov    rcx,r12
     c48:	or     rcx,0x1
     c4c:	mov    rbx,rsi
     c4f:	mov    rdx,rbx
     c52:	mov    rsi,r13
     c55:	call   c5a <botlish_fn_10+0x43>
			c56: R_X86_64_PLT32	rt_str_region_check-0x4
     c5a:	test   rax,rax
     c5d:	jne    c82 <botlish_fn_10+0x6b>
     c63:	xor    rax,rax
     c66:	mov    rbx,QWORD PTR [rsp]
     c6a:	mov    r12,QWORD PTR [rsp+0x8]
     c6f:	mov    r13,QWORD PTR [rsp+0x10]
     c74:	mov    r15,QWORD PTR [rsp+0x18]
     c79:	add    rsp,0x20
     c7d:	mov    rsp,rbp
     c80:	pop    rbp
     c81:	ret
     c82:	mov    rcx,r15
     c85:	mov    QWORD PTR [rcx],rbx
     c88:	or     r12,0x1
     c8c:	mov    QWORD PTR [rcx+0x8],r12
     c90:	mov    rax,r13
     c93:	mov    rbx,QWORD PTR [rsp]
     c97:	mov    r12,QWORD PTR [rsp+0x8]
     c9c:	mov    r13,QWORD PTR [rsp+0x10]
     ca1:	mov    r15,QWORD PTR [rsp+0x18]
     ca6:	add    rsp,0x20
     caa:	mov    rsp,rbp
     cad:	pop    rbp
     cae:	ret

0000000000000caf <botlish_entry_10: char_at<int>>:
     caf:	push   rbp
     cb0:	mov    rbp,rsp
     cb3:	ud2

0000000000000cb5 <botlish_fn_11: char_at<int>>:
     cb5:	push   rbp
     cb6:	mov    rbp,rsp
     cb9:	sub    rsp,0x20
     cbd:	mov    QWORD PTR [rsp],rsi
     cc1:	mov    QWORD PTR [rsp+0x8],rdx
     cc6:	mov    rax,rsi
     cc9:	sar    rax,1
     ccc:	lea    rcx,[rax+0x1]
     cd0:	shl    rcx,1
     cd3:	or     rcx,0x1
     cd7:	mov    QWORD PTR [rsp+0x10],rcx
     cdc:	mov    rax,rdx
     cdf:	mov    rdx,rsi
     ce2:	mov    rsi,rax
     ce5:	call   cea <botlish_fn_11+0x35>
			ce6: R_X86_64_PLT32	rt_substr-0x4
     cea:	test   rax,rax
     ced:	jne    cff <botlish_fn_11+0x4a>
     cf3:	xor    rax,rax
     cf6:	add    rsp,0x20
     cfa:	mov    rsp,rbp
     cfd:	pop    rbp
     cfe:	ret
     cff:	add    rsp,0x20
     d03:	mov    rsp,rbp
     d06:	pop    rbp
     d07:	ret

0000000000000d08 <botlish_entry_11: char_at<int>>:
     d08:	push   rbp
     d09:	mov    rbp,rsp
     d0c:	mov    rsi,QWORD PTR [rdx]
     d0f:	mov    rdx,QWORD PTR [rdx+0x8]
     d13:	call   d18 <botlish_entry_11+0x10>
			d14: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<int>
     d18:	mov    rsp,rbp
     d1b:	pop    rbp
     d1c:	ret

0000000000000d1d <botlish_fn_12: local_char?<str>>:
     d1d:	push   rbp
     d1e:	mov    rbp,rsp
     d21:	sub    rsp,0x10
     d25:	mov    QWORD PTR [rsp],rbx
     d29:	mov    QWORD PTR [rsp+0x8],r14
     d2e:	mov    rbx,rdi
     d31:	mov    r14,rsi
     d34:	mov    rsi,r14
     d37:	mov    rdi,rbx
     d3a:	call   d3f <botlish_fn_12+0x22>
			d3b: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     d3f:	test   rax,rax
     d42:	jne    d5d <botlish_fn_12+0x40>
     d48:	xor    rax,rax
     d4b:	mov    rbx,QWORD PTR [rsp]
     d4f:	mov    r14,QWORD PTR [rsp+0x8]
     d54:	add    rsp,0x10
     d58:	mov    rsp,rbp
     d5b:	pop    rbp
     d5c:	ret
     d5d:	cmp    rax,0x6
     d61:	je     d97 <botlish_fn_12+0x7a>
     d67:	mov    rdi,rbx
     d6a:	mov    rax,QWORD PTR [rdi+0x30]
     d6e:	mov    rsi,QWORD PTR [rax]
     d71:	mov    rdx,r14
     d74:	call   d79 <botlish_fn_12+0x5c>
			d75: R_X86_64_PLT32	rt_set_contains-0x4
     d79:	cmp    rax,0x6
     d7d:	je     d8d <botlish_fn_12+0x70>
     d83:	mov    eax,0x2
     d88:	jmp    d9c <botlish_fn_12+0x7f>
     d8d:	mov    eax,0x6
     d92:	jmp    d9c <botlish_fn_12+0x7f>
     d97:	mov    eax,0x6
     d9c:	mov    rbx,QWORD PTR [rsp]
     da0:	mov    r14,QWORD PTR [rsp+0x8]
     da5:	add    rsp,0x10
     da9:	mov    rsp,rbp
     dac:	pop    rbp
     dad:	ret

0000000000000dae <botlish_entry_12: local_char?<str>>:
     dae:	push   rbp
     daf:	mov    rbp,rsp
     db2:	mov    rsi,QWORD PTR [rdx]
     db5:	call   dba <botlish_entry_12+0xc>
			db6: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     dba:	mov    rsp,rbp
     dbd:	pop    rbp
     dbe:	ret

0000000000000dbf <botlish_fn_13: local_char?<generic>>:
     dbf:	push   rbp
     dc0:	mov    rbp,rsp
     dc3:	sub    rsp,0x10
     dc7:	mov    QWORD PTR [rsp],rbx
     dcb:	mov    QWORD PTR [rsp+0x8],r12
     dd0:	xor    r8d,r8d
     dd3:	test   rsi,0x7
     dda:	jne    dea <botlish_fn_13+0x2b>
     de0:	movzx  rax,BYTE PTR [rsi]
     de4:	cmp    al,0x2
     de6:	sete   r8b
     dea:	test   r8b,r8b
     ded:	jne    e0d <botlish_fn_13+0x4e>
     df3:	mov    rax,QWORD PTR [rdi+0x10]
     df7:	mov    rcx,QWORD PTR [rax+0xd0]
     dfe:	mov    edx,0x1
     e03:	call   e08 <botlish_fn_13+0x49>
			e04: R_X86_64_PLT32	rt_type_error-0x4
     e08:	jmp    e21 <botlish_fn_13+0x62>
     e0d:	mov    rbx,rsi
     e10:	mov    r12,rdi
     e13:	call   e18 <botlish_fn_13+0x59>
			e14: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     e18:	test   rax,rax
     e1b:	jne    e36 <botlish_fn_13+0x77>
     e21:	xor    rax,rax
     e24:	mov    rbx,QWORD PTR [rsp]
     e28:	mov    r12,QWORD PTR [rsp+0x8]
     e2d:	add    rsp,0x10
     e31:	mov    rsp,rbp
     e34:	pop    rbp
     e35:	ret
     e36:	cmp    rax,0x6
     e3a:	je     e70 <botlish_fn_13+0xb1>
     e40:	mov    rdi,r12
     e43:	mov    rax,QWORD PTR [rdi+0x30]
     e47:	mov    rsi,QWORD PTR [rax]
     e4a:	mov    rdx,rbx
     e4d:	call   e52 <botlish_fn_13+0x93>
			e4e: R_X86_64_PLT32	rt_set_contains-0x4
     e52:	cmp    rax,0x6
     e56:	je     e66 <botlish_fn_13+0xa7>
     e5c:	mov    eax,0x2
     e61:	jmp    e75 <botlish_fn_13+0xb6>
     e66:	mov    eax,0x6
     e6b:	jmp    e75 <botlish_fn_13+0xb6>
     e70:	mov    eax,0x6
     e75:	mov    rbx,QWORD PTR [rsp]
     e79:	mov    r12,QWORD PTR [rsp+0x8]
     e7e:	add    rsp,0x10
     e82:	mov    rsp,rbp
     e85:	pop    rbp
     e86:	ret

0000000000000e87 <botlish_entry_13: local_char?<generic>>:
     e87:	push   rbp
     e88:	mov    rbp,rsp
     e8b:	mov    rsi,QWORD PTR [rdx]
     e8e:	call   e93 <botlish_entry_13+0xc>
			e8f: R_X86_64_PLT32	botlish_fn_13-0x4 ; local_char?<generic>
     e93:	mov    rsp,rbp
     e96:	pop    rbp
     e97:	ret

0000000000000e98 <botlish_fn_14: scan_while<int, block(e239)>>:
     e98:	push   rbp
     e99:	mov    rbp,rsp
     e9c:	sub    rsp,0x40
     ea0:	mov    QWORD PTR [rsp+0x20],rbx
     ea5:	mov    QWORD PTR [rsp+0x28],r12
     eaa:	mov    QWORD PTR [rsp+0x30],r13
     eaf:	mov    QWORD PTR [rsp+0x38],r14
     eb4:	mov    rbx,rcx
     eb7:	mov    r13,rdi
     eba:	mov    QWORD PTR [rsp+0x18],0x0
     ec3:	mov    QWORD PTR [rsp],rcx
     ec7:	mov    QWORD PTR [rsp+0x8],r8
     ecc:	mov    r12,r8
     ecf:	mov    QWORD PTR [rsp+0x10],rsi
     ed4:	mov    rax,rsi
     ed7:	mov    rcx,rbx
     eda:	mov    r14,rsi
     edd:	mov    rcx,rbx
     ee0:	and    rax,rcx
     ee3:	test   rax,0x1
     ee9:	jne    f12 <botlish_fn_14+0x7a>
     eef:	mov    rdx,rbx
     ef2:	mov    rsi,r14
     ef5:	mov    rdi,r13
     ef8:	call   efd <botlish_fn_14+0x65>
			ef9: R_X86_64_PLT32	rt_int_cmp-0x4
     efd:	mov    ecx,0x2
     f02:	test   rax,rax
     f05:	cmovl  rcx,QWORD PTR [rip+0x10b]        # 1018 <botlish_fn_14+0x180>
     f0d:	jmp    f28 <botlish_fn_14+0x90>
     f12:	mov    ecx,0x2
     f17:	mov    rax,r14
     f1a:	mov    rdx,rbx
     f1d:	cmp    rax,rdx
     f20:	cmovl  rcx,QWORD PTR [rip+0xf0]        # 1018 <botlish_fn_14+0x180>
     f28:	cmp    rcx,0x6
     f2c:	je     f52 <botlish_fn_14+0xba>
     f32:	mov    rax,rbx
     f35:	mov    rbx,QWORD PTR [rsp+0x20]
     f3a:	mov    r12,QWORD PTR [rsp+0x28]
     f3f:	mov    r13,QWORD PTR [rsp+0x30]
     f44:	mov    r14,QWORD PTR [rsp+0x38]
     f49:	add    rsp,0x40
     f4d:	mov    rsp,rbp
     f50:	pop    rbp
     f51:	ret
     f52:	mov    rdx,r12
     f55:	mov    rsi,r14
     f58:	mov    rdi,r13
     f5b:	call   f60 <botlish_fn_14+0xc8>
			f5c: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<int>
     f60:	test   rax,rax
     f63:	mov    rsi,rax
     f66:	je     f7d <botlish_fn_14+0xe5>
     f6c:	mov    rdi,r13
     f6f:	call   f74 <botlish_fn_14+0xdc>
			f70: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     f74:	test   rax,rax
     f77:	jne    f9d <botlish_fn_14+0x105>
     f7d:	xor    rax,rax
     f80:	mov    rbx,QWORD PTR [rsp+0x20]
     f85:	mov    r12,QWORD PTR [rsp+0x28]
     f8a:	mov    r13,QWORD PTR [rsp+0x30]
     f8f:	mov    r14,QWORD PTR [rsp+0x38]
     f94:	add    rsp,0x40
     f98:	mov    rsp,rbp
     f9b:	pop    rbp
     f9c:	ret
     f9d:	cmp    rax,0x6
     fa1:	je     fc7 <botlish_fn_14+0x12f>
     fa7:	mov    rax,r14
     faa:	mov    rbx,QWORD PTR [rsp+0x20]
     faf:	mov    r12,QWORD PTR [rsp+0x28]
     fb4:	mov    r13,QWORD PTR [rsp+0x30]
     fb9:	mov    r14,QWORD PTR [rsp+0x38]
     fbe:	add    rsp,0x40
     fc2:	mov    rsp,rbp
     fc5:	pop    rbp
     fc6:	ret
     fc7:	mov    QWORD PTR [rsp+0x18],0x3
     fd0:	mov    rax,r14
     fd3:	test   rax,0x1
     fd9:	je     ff4 <botlish_fn_14+0x15c>
     fdf:	mov    rcx,r14
     fe2:	mov    rax,rcx
     fe5:	add    rax,0x2
     fe9:	seto   cl
     fec:	test   cl,cl
     fee:	je     1004 <botlish_fn_14+0x16c>
     ff4:	mov    edx,0x3
     ff9:	mov    rsi,r14
     ffc:	mov    rdi,r13
     fff:	call   1004 <botlish_fn_14+0x16c>
			1000: R_X86_64_PLT32	rt_int_add-0x4
    1004:	mov    QWORD PTR [rsp+0x10],rax
    1009:	mov    rcx,rbx
    100c:	mov    r14,rax
    100f:	jmp    edd <botlish_fn_14+0x45>
    1014:	add    BYTE PTR [rax],al
    1016:	add    BYTE PTR [rax],al
    1018:	(bad)
    1019:	add    BYTE PTR [rax],al
    101b:	add    BYTE PTR [rax],al
    101d:	add    BYTE PTR [rax],al
	...

0000000000001020 <botlish_entry_14: scan_while<int, block(e239)>>:
    1020:	push   rbp
    1021:	mov    rbp,rsp
    1024:	mov    rsi,QWORD PTR [rdx]
    1027:	mov    r9,QWORD PTR [rdx+0x8]
    102b:	mov    rcx,QWORD PTR [rdx+0x10]
    102f:	mov    r8,QWORD PTR [rdx+0x18]
    1033:	mov    rdx,r9
    1036:	call   103b <botlish_entry_14+0x1b>
			1037: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, block(e239)>
    103b:	mov    rsp,rbp
    103e:	pop    rbp
    103f:	ret

0000000000001040 <botlish_fn_15: scan_while<int, native(is_tcl_alpha)>>:
    1040:	push   rbp
    1041:	mov    rbp,rsp
    1044:	sub    rsp,0x50
    1048:	mov    QWORD PTR [rsp+0x30],rbx
    104d:	mov    QWORD PTR [rsp+0x38],r12
    1052:	mov    QWORD PTR [rsp+0x40],r13
    1057:	mov    QWORD PTR [rsp+0x48],r14
    105c:	mov    rbx,rcx
    105f:	mov    r13,rdi
    1062:	mov    QWORD PTR [rsp],rcx
    1066:	mov    QWORD PTR [rsp+0x8],r8
    106b:	mov    r12,r8
    106e:	mov    QWORD PTR [rsp+0x10],rsi
    1073:	mov    rax,rsi
    1076:	mov    rcx,rbx
    1079:	mov    r14,rsi
    107c:	mov    rcx,rbx
    107f:	and    rax,rcx
    1082:	test   rax,0x1
    1088:	jne    10b1 <botlish_fn_15+0x71>
    108e:	mov    rdx,rbx
    1091:	mov    rsi,r14
    1094:	mov    rdi,r13
    1097:	call   109c <botlish_fn_15+0x5c>
			1098: R_X86_64_PLT32	rt_int_cmp-0x4
    109c:	mov    ecx,0x2
    10a1:	test   rax,rax
    10a4:	cmovl  rcx,QWORD PTR [rip+0x11c]        # 11c8 <botlish_fn_15+0x188>
    10ac:	jmp    10c7 <botlish_fn_15+0x87>
    10b1:	mov    ecx,0x2
    10b6:	mov    rax,r14
    10b9:	mov    rdx,rbx
    10bc:	cmp    rax,rdx
    10bf:	cmovl  rcx,QWORD PTR [rip+0x101]        # 11c8 <botlish_fn_15+0x188>
    10c7:	cmp    rcx,0x6
    10cb:	je     10f1 <botlish_fn_15+0xb1>
    10d1:	mov    rax,rbx
    10d4:	mov    rbx,QWORD PTR [rsp+0x30]
    10d9:	mov    r12,QWORD PTR [rsp+0x38]
    10de:	mov    r13,QWORD PTR [rsp+0x40]
    10e3:	mov    r14,QWORD PTR [rsp+0x48]
    10e8:	add    rsp,0x50
    10ec:	mov    rsp,rbp
    10ef:	pop    rbp
    10f0:	ret
    10f1:	lea    rcx,[rsp+0x20]
    10f6:	mov    rdx,r12
    10f9:	mov    rsi,r14
    10fc:	mov    rdi,r13
    10ff:	call   1104 <botlish_fn_15+0xc4>
			1100: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    1104:	test   rax,rax
    1107:	mov    rsi,rax
    110a:	je     112b <botlish_fn_15+0xeb>
    1110:	mov    rdx,QWORD PTR [rsp+0x20]
    1115:	mov    rcx,QWORD PTR [rsp+0x28]
    111a:	mov    rdi,r13
    111d:	call   1122 <botlish_fn_15+0xe2>
			111e: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    1122:	test   rax,rax
    1125:	jne    114b <botlish_fn_15+0x10b>
    112b:	xor    rax,rax
    112e:	mov    rbx,QWORD PTR [rsp+0x30]
    1133:	mov    r12,QWORD PTR [rsp+0x38]
    1138:	mov    r13,QWORD PTR [rsp+0x40]
    113d:	mov    r14,QWORD PTR [rsp+0x48]
    1142:	add    rsp,0x50
    1146:	mov    rsp,rbp
    1149:	pop    rbp
    114a:	ret
    114b:	cmp    rax,0x6
    114f:	je     1175 <botlish_fn_15+0x135>
    1155:	mov    rax,r14
    1158:	mov    rbx,QWORD PTR [rsp+0x30]
    115d:	mov    r12,QWORD PTR [rsp+0x38]
    1162:	mov    r13,QWORD PTR [rsp+0x40]
    1167:	mov    r14,QWORD PTR [rsp+0x48]
    116c:	add    rsp,0x50
    1170:	mov    rsp,rbp
    1173:	pop    rbp
    1174:	ret
    1175:	mov    QWORD PTR [rsp+0x18],0x3
    117e:	mov    rax,r14
    1181:	test   rax,0x1
    1187:	je     11a2 <botlish_fn_15+0x162>
    118d:	mov    rcx,r14
    1190:	mov    rax,rcx
    1193:	add    rax,0x2
    1197:	seto   cl
    119a:	test   cl,cl
    119c:	je     11b2 <botlish_fn_15+0x172>
    11a2:	mov    edx,0x3
    11a7:	mov    rsi,r14
    11aa:	mov    rdi,r13
    11ad:	call   11b2 <botlish_fn_15+0x172>
			11ae: R_X86_64_PLT32	rt_int_add-0x4
    11b2:	mov    QWORD PTR [rsp+0x10],rax
    11b7:	mov    rcx,rbx
    11ba:	mov    r14,rax
    11bd:	jmp    107c <botlish_fn_15+0x3c>
    11c2:	add    BYTE PTR [rax],al
    11c4:	add    BYTE PTR [rax],al
    11c6:	add    BYTE PTR [rax],al
    11c8:	(bad)
    11c9:	add    BYTE PTR [rax],al
    11cb:	add    BYTE PTR [rax],al
    11cd:	add    BYTE PTR [rax],al
	...

00000000000011d0 <botlish_entry_15: scan_while<int, native(is_tcl_alpha)>>:
    11d0:	push   rbp
    11d1:	mov    rbp,rsp
    11d4:	mov    rsi,QWORD PTR [rdx]
    11d7:	mov    r9,QWORD PTR [rdx+0x8]
    11db:	mov    rcx,QWORD PTR [rdx+0x10]
    11df:	mov    r8,QWORD PTR [rdx+0x18]
    11e3:	mov    rdx,r9
    11e6:	call   11eb <botlish_entry_15+0x1b>
			11e7: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<int, native(is_tcl_alpha)>
    11eb:	mov    rsp,rbp
    11ee:	pop    rbp
    11ef:	ret

00000000000011f0 <botlish_fn_16: tld?<int>>:
    11f0:	push   rbp
    11f1:	mov    rbp,rsp
    11f4:	sub    rsp,0x30
    11f8:	mov    QWORD PTR [rsp+0x20],rbx
    11fd:	mov    QWORD PTR [rsp+0x28],r12
    1202:	mov    QWORD PTR [rsp],rsi
    1206:	mov    QWORD PTR [rsp+0x8],rdx
    120b:	mov    r12,rdx
    120e:	mov    QWORD PTR [rsp+0x10],rcx
    1213:	mov    rax,QWORD PTR [rdi+0x10]
    1217:	mov    rdx,QWORD PTR [rax+0xd8]
    121e:	mov    QWORD PTR [rsp+0x18],rdx
    1223:	mov    rbx,rsi
    1226:	mov    r8,rcx
    1229:	mov    rcx,r12
    122c:	call   1231 <botlish_fn_16+0x41>
			122d: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<int, native(is_tcl_alpha)>
    1231:	test   rax,rax
    1234:	jne    1250 <botlish_fn_16+0x60>
    123a:	xor    rax,rax
    123d:	mov    rbx,QWORD PTR [rsp+0x20]
    1242:	mov    r12,QWORD PTR [rsp+0x28]
    1247:	add    rsp,0x30
    124b:	mov    rsp,rbp
    124e:	pop    rbp
    124f:	ret
    1250:	sar    rax,1
    1253:	mov    rdx,r12
    1256:	sar    rdx,1
    1259:	cmp    rax,rdx
    125c:	je     126c <botlish_fn_16+0x7c>
    1262:	mov    eax,0x2
    1267:	jmp    1286 <botlish_fn_16+0x96>
    126c:	sar    rbx,1
    126f:	sub    rax,rbx
    1272:	mov    rcx,rax
    1275:	mov    eax,0x2
    127a:	cmp    rcx,0x2
    127e:	cmovge rax,QWORD PTR [rip+0x1a]        # 12a0 <botlish_fn_16+0xb0>
    1286:	mov    rbx,QWORD PTR [rsp+0x20]
    128b:	mov    r12,QWORD PTR [rsp+0x28]
    1290:	add    rsp,0x30
    1294:	mov    rsp,rbp
    1297:	pop    rbp
    1298:	ret
    1299:	add    BYTE PTR [rax],al
    129b:	add    BYTE PTR [rax],al
    129d:	add    BYTE PTR [rax],al
    129f:	add    BYTE PTR [rsi],al
    12a1:	add    BYTE PTR [rax],al
    12a3:	add    BYTE PTR [rax],al
    12a5:	add    BYTE PTR [rax],al
	...

00000000000012a8 <botlish_entry_16: tld?<int>>:
    12a8:	push   rbp
    12a9:	mov    rbp,rsp
    12ac:	mov    rsi,QWORD PTR [rdx]
    12af:	mov    r8,QWORD PTR [rdx+0x8]
    12b3:	mov    rcx,QWORD PTR [rdx+0x10]
    12b7:	mov    rdx,r8
    12ba:	call   12bf <botlish_entry_16+0x17>
			12bb: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<int>
    12bf:	mov    rsp,rbp
    12c2:	pop    rbp
    12c3:	ret
    12c4:	add    BYTE PTR [rax],al
	...

00000000000012c8 <botlish_fn_17: domain?<int>>:
    12c8:	push   rbp
    12c9:	mov    rbp,rsp
    12cc:	sub    rsp,0xa0
    12d3:	mov    QWORD PTR [rsp+0x70],rbx
    12d8:	mov    QWORD PTR [rsp+0x78],r12
    12dd:	mov    QWORD PTR [rsp+0x80],r13
    12e5:	mov    QWORD PTR [rsp+0x88],r14
    12ed:	mov    QWORD PTR [rsp+0x90],r15
    12f5:	mov    QWORD PTR [rsp],rsi
    12f9:	mov    QWORD PTR [rsp+0x8],rdx
    12fe:	mov    QWORD PTR [rsp+0x10],rcx
    1303:	mov    r14,rcx
    1306:	mov    QWORD PTR [rsp+0x18],rsi
    130b:	mov    r15,rsi
    130e:	mov    r11,r15
    1311:	mov    r13,rdx
    1314:	mov    rsi,r11
    1317:	and    rsi,r13
    131a:	mov    QWORD PTR [rsp+0x58],r11
    131f:	test   rsi,0x1
    1326:	jne    1351 <botlish_fn_17+0x89>
    132c:	mov    rbx,rdi
    132f:	mov    rdx,r13
    1332:	mov    rsi,QWORD PTR [rsp+0x58]
    1337:	call   133c <botlish_fn_17+0x74>
			1338: R_X86_64_PLT32	rt_int_cmp-0x4
    133c:	mov    ecx,0x2
    1341:	test   rax,rax
    1344:	cmovl  rcx,QWORD PTR [rip+0x354]        # 16a0 <botlish_fn_17+0x3d8>
    134c:	jmp    1369 <botlish_fn_17+0xa1>
    1351:	mov    rbx,rdi
    1354:	mov    ecx,0x2
    1359:	mov    rsi,QWORD PTR [rsp+0x58]
    135e:	cmp    rsi,r13
    1361:	cmovl  rcx,QWORD PTR [rip+0x337]        # 16a0 <botlish_fn_17+0x3d8>
    1369:	cmp    rcx,0x6
    136d:	je     13a6 <botlish_fn_17+0xde>
    1373:	mov    eax,0x2
    1378:	mov    rbx,QWORD PTR [rsp+0x70]
    137d:	mov    r12,QWORD PTR [rsp+0x78]
    1382:	mov    r13,QWORD PTR [rsp+0x80]
    138a:	mov    r14,QWORD PTR [rsp+0x88]
    1392:	mov    r15,QWORD PTR [rsp+0x90]
    139a:	add    rsp,0xa0
    13a1:	mov    rsp,rbp
    13a4:	pop    rbp
    13a5:	ret
    13a6:	lea    rcx,[rsp+0x28]
    13ab:	mov    rdx,r14
    13ae:	mov    rsi,QWORD PTR [rsp+0x58]
    13b3:	mov    rdi,rbx
    13b6:	call   13bb <botlish_fn_17+0xf3>
			13b7: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    13bb:	test   rax,rax
    13be:	mov    rsi,rax
    13c1:	je     1564 <botlish_fn_17+0x29c>
    13c7:	mov    rdx,QWORD PTR [rsp+0x28]
    13cc:	mov    rcx,QWORD PTR [rsp+0x30]
    13d1:	mov    rax,QWORD PTR [rbx+0x10]
    13d5:	mov    r8,QWORD PTR [rax]
    13d8:	mov    rdi,rbx
    13db:	call   13e0 <botlish_fn_17+0x118>
			13dc: R_X86_64_PLT32	rt_str_region_eq-0x4
    13e0:	cmp    rax,0x6
    13e4:	je     14d5 <botlish_fn_17+0x20d>
    13ea:	lea    rcx,[rsp+0x48]
    13ef:	mov    rdx,r14
    13f2:	mov    rsi,QWORD PTR [rsp+0x58]
    13f7:	mov    rdi,rbx
    13fa:	call   13ff <botlish_fn_17+0x137>
			13fb: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    13ff:	test   rax,rax
    1402:	mov    r12,rax
    1405:	je     1564 <botlish_fn_17+0x29c>
    140b:	mov    rdx,QWORD PTR [rsp+0x48]
    1410:	mov    QWORD PTR [rsp+0x68],rdx
    1415:	mov    rcx,QWORD PTR [rsp+0x50]
    141a:	mov    QWORD PTR [rsp+0x60],rcx
    141f:	mov    rsi,r12
    1422:	mov    rdi,rbx
    1425:	call   142a <botlish_fn_17+0x162>
			1426: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    142a:	test   rax,rax
    142d:	je     1564 <botlish_fn_17+0x29c>
    1433:	cmp    rax,0x6
    1437:	je     1478 <botlish_fn_17+0x1b0>
    143d:	mov    rax,QWORD PTR [rbx+0x10]
    1441:	mov    r8,QWORD PTR [rax+0x20]
    1445:	mov    rcx,QWORD PTR [rsp+0x60]
    144a:	mov    rdx,QWORD PTR [rsp+0x68]
    144f:	mov    rsi,r12
    1452:	mov    rdi,rbx
    1455:	call   145a <botlish_fn_17+0x192>
			1456: R_X86_64_PLT32	rt_str_region_eq-0x4
    145a:	cmp    rax,0x6
    145e:	je     146e <botlish_fn_17+0x1a6>
    1464:	mov    ecx,0x2
    1469:	jmp    147d <botlish_fn_17+0x1b5>
    146e:	mov    ecx,0x6
    1473:	jmp    147d <botlish_fn_17+0x1b5>
    1478:	mov    ecx,0x6
    147d:	cmp    rcx,0x6
    1481:	je     1492 <botlish_fn_17+0x1ca>
    1487:	mov    r8d,0x6
    148d:	jmp    1498 <botlish_fn_17+0x1d0>
    1492:	mov    r8d,0x2
    1498:	cmp    r8,0x6
    149c:	jne    159f <botlish_fn_17+0x2d7>
    14a2:	mov    eax,0x2
    14a7:	mov    rbx,QWORD PTR [rsp+0x70]
    14ac:	mov    r12,QWORD PTR [rsp+0x78]
    14b1:	mov    r13,QWORD PTR [rsp+0x80]
    14b9:	mov    r14,QWORD PTR [rsp+0x88]
    14c1:	mov    r15,QWORD PTR [rsp+0x90]
    14c9:	add    rsp,0xa0
    14d0:	mov    rsp,rbp
    14d3:	pop    rbp
    14d4:	ret
    14d5:	mov    rsi,QWORD PTR [rsp+0x58]
    14da:	mov    r12,rsi
    14dd:	sar    r12,1
    14e0:	mov    rax,r15
    14e3:	sar    rax,1
    14e6:	cmp    r12,rax
    14e9:	je     166c <botlish_fn_17+0x3a4>
    14ef:	mov    rsi,r12
    14f2:	sub    rsi,0x1
    14f6:	shl    rsi,1
    14f9:	or     rsi,0x1
    14fd:	lea    rcx,[rsp+0x38]
    1502:	mov    rdx,r14
    1505:	mov    rdi,rbx
    1508:	call   150d <botlish_fn_17+0x245>
			1509: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    150d:	test   rax,rax
    1510:	mov    rsi,rax
    1513:	je     1564 <botlish_fn_17+0x29c>
    1519:	mov    rdx,QWORD PTR [rsp+0x38]
    151e:	mov    rcx,QWORD PTR [rsp+0x40]
    1523:	mov    rax,QWORD PTR [rbx+0x10]
    1527:	mov    r8,QWORD PTR [rax]
    152a:	mov    rdi,rbx
    152d:	call   1532 <botlish_fn_17+0x26a>
			152e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1532:	cmp    rax,0x6
    1536:	je     1639 <botlish_fn_17+0x371>
    153c:	lea    rsi,[r12+0x1]
    1541:	shl    rsi,1
    1544:	or     rsi,0x1
    1548:	mov    QWORD PTR [rsp+0x20],rsi
    154d:	mov    rcx,r14
    1550:	mov    rdx,r13
    1553:	mov    rdi,rbx
    1556:	call   155b <botlish_fn_17+0x293>
			1557: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<int>
    155b:	test   rax,rax
    155e:	jne    1595 <botlish_fn_17+0x2cd>
    1564:	xor    rax,rax
    1567:	mov    rbx,QWORD PTR [rsp+0x70]
    156c:	mov    r12,QWORD PTR [rsp+0x78]
    1571:	mov    r13,QWORD PTR [rsp+0x80]
    1579:	mov    r14,QWORD PTR [rsp+0x88]
    1581:	mov    r15,QWORD PTR [rsp+0x90]
    1589:	add    rsp,0xa0
    1590:	mov    rsp,rbp
    1593:	pop    rbp
    1594:	ret
    1595:	cmp    rax,0x6
    1599:	je     1606 <botlish_fn_17+0x33e>
    159f:	mov    QWORD PTR [rsp+0x20],0x3
    15a8:	mov    rsi,QWORD PTR [rsp+0x58]
    15ad:	test   rsi,0x1
    15b4:	je     15da <botlish_fn_17+0x312>
    15ba:	mov    rsi,QWORD PTR [rsp+0x58]
    15bf:	add    rsi,0x2
    15c3:	seto   dil
    15c7:	test   dil,dil
    15ca:	jne    15da <botlish_fn_17+0x312>
    15d0:	mov    QWORD PTR [rsp+0x58],rsi
    15d5:	jmp    15f4 <botlish_fn_17+0x32c>
    15da:	mov    edx,0x3
    15df:	mov    rsi,QWORD PTR [rsp+0x58]
    15e4:	mov    rdi,rbx
    15e7:	call   15ec <botlish_fn_17+0x324>
			15e8: R_X86_64_PLT32	rt_int_add-0x4
    15ec:	mov    rsi,rax
    15ef:	mov    QWORD PTR [rsp+0x58],rax
    15f4:	mov    QWORD PTR [rsp+0x18],rsi
    15f9:	mov    rdi,rbx
    15fc:	mov    r11,QWORD PTR [rsp+0x58]
    1601:	jmp    1314 <botlish_fn_17+0x4c>
    1606:	mov    eax,0x6
    160b:	mov    rbx,QWORD PTR [rsp+0x70]
    1610:	mov    r12,QWORD PTR [rsp+0x78]
    1615:	mov    r13,QWORD PTR [rsp+0x80]
    161d:	mov    r14,QWORD PTR [rsp+0x88]
    1625:	mov    r15,QWORD PTR [rsp+0x90]
    162d:	add    rsp,0xa0
    1634:	mov    rsp,rbp
    1637:	pop    rbp
    1638:	ret
    1639:	mov    eax,0x2
    163e:	mov    rbx,QWORD PTR [rsp+0x70]
    1643:	mov    r12,QWORD PTR [rsp+0x78]
    1648:	mov    r13,QWORD PTR [rsp+0x80]
    1650:	mov    r14,QWORD PTR [rsp+0x88]
    1658:	mov    r15,QWORD PTR [rsp+0x90]
    1660:	add    rsp,0xa0
    1667:	mov    rsp,rbp
    166a:	pop    rbp
    166b:	ret
    166c:	mov    eax,0x2
    1671:	mov    rbx,QWORD PTR [rsp+0x70]
    1676:	mov    r12,QWORD PTR [rsp+0x78]
    167b:	mov    r13,QWORD PTR [rsp+0x80]
    1683:	mov    r14,QWORD PTR [rsp+0x88]
    168b:	mov    r15,QWORD PTR [rsp+0x90]
    1693:	add    rsp,0xa0
    169a:	mov    rsp,rbp
    169d:	pop    rbp
    169e:	ret
    169f:	add    BYTE PTR [rsi],al
    16a1:	add    BYTE PTR [rax],al
    16a3:	add    BYTE PTR [rax],al
    16a5:	add    BYTE PTR [rax],al
	...

00000000000016a8 <botlish_entry_17: domain?<int>>:
    16a8:	push   rbp
    16a9:	mov    rbp,rsp
    16ac:	mov    rsi,QWORD PTR [rdx]
    16af:	mov    r8,QWORD PTR [rdx+0x8]
    16b3:	mov    rcx,QWORD PTR [rdx+0x10]
    16b7:	mov    rdx,r8
    16ba:	call   16bf <botlish_entry_17+0x17>
			16bb: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<int>
    16bf:	mov    rsp,rbp
    16c2:	pop    rbp
    16c3:	ret

00000000000016c4 <botlish_fn_18: web::is_unreserved<int>>:
    16c4:	push   rbp
    16c5:	mov    rbp,rsp
    16c8:	sub    rsp,0x10
    16cc:	mov    QWORD PTR [rsp],rbx
    16d0:	mov    QWORD PTR [rsp+0x8],r14
    16d5:	mov    r14,rsi
    16d8:	mov    rsi,r14
    16db:	sar    rsi,1
    16de:	mov    rbx,rdi
    16e1:	call   16e6 <botlish_fn_18+0x22>
			16e2: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
    16e6:	cmp    rax,0x6
    16ea:	je     1721 <botlish_fn_18+0x5d>
    16f0:	mov    rax,QWORD PTR [rbx+0x30]
    16f4:	mov    rsi,QWORD PTR [rax+0x10]
    16f8:	mov    rdx,r14
    16fb:	mov    rdi,rbx
    16fe:	call   1703 <botlish_fn_18+0x3f>
			16ff: R_X86_64_PLT32	rt_set_contains-0x4
    1703:	cmp    rax,0x6
    1707:	je     1717 <botlish_fn_18+0x53>
    170d:	mov    eax,0x2
    1712:	jmp    1726 <botlish_fn_18+0x62>
    1717:	mov    eax,0x6
    171c:	jmp    1726 <botlish_fn_18+0x62>
    1721:	mov    eax,0x6
    1726:	mov    rbx,QWORD PTR [rsp]
    172a:	mov    r14,QWORD PTR [rsp+0x8]
    172f:	add    rsp,0x10
    1733:	mov    rsp,rbp
    1736:	pop    rbp
    1737:	ret

0000000000001738 <botlish_entry_18: web::is_unreserved<int>>:
    1738:	push   rbp
    1739:	mov    rbp,rsp
    173c:	mov    rsi,QWORD PTR [rdx]
    173f:	call   1744 <botlish_entry_18+0xc>
			1740: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1744:	mov    rsp,rbp
    1747:	pop    rbp
    1748:	ret

0000000000001749 <botlish_fn_19: web::uri_escape_text<str>>:
    1749:	push   rbp
    174a:	mov    rbp,rsp
    174d:	sub    rsp,0x10
    1751:	mov    edx,0x1
    1756:	mov    QWORD PTR [rsp],0x1
    175e:	mov    r10,QWORD PTR [rdi+0x10]
    1762:	mov    rcx,QWORD PTR [r10+0xe0]
    1769:	mov    QWORD PTR [rsp+0x8],rcx
    176e:	call   1773 <botlish_fn_19+0x2a>
			176f: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    1773:	test   rax,rax
    1776:	jne    1788 <botlish_fn_19+0x3f>
    177c:	xor    rax,rax
    177f:	add    rsp,0x10
    1783:	mov    rsp,rbp
    1786:	pop    rbp
    1787:	ret
    1788:	add    rsp,0x10
    178c:	mov    rsp,rbp
    178f:	pop    rbp
    1790:	ret

0000000000001791 <botlish_entry_19: web::uri_escape_text<str>>:
    1791:	push   rbp
    1792:	mov    rbp,rsp
    1795:	sub    rsp,0x10
    1799:	mov    QWORD PTR [rsp],r12
    179d:	mov    r12,rdi
    17a0:	mov    rsi,QWORD PTR [rdx]
    17a3:	mov    r8,QWORD PTR [rip+0x0]        # 17aa <botlish_entry_19+0x19>
			17a6: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    17aa:	call   r8
    17ad:	mov    rsi,rax
    17b0:	mov    rdi,r12
    17b3:	call   17b8 <botlish_entry_19+0x27>
			17b4: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_escape_text<str>
    17b8:	mov    r12,QWORD PTR [rsp]
    17bc:	add    rsp,0x10
    17c0:	mov    rsp,rbp
    17c3:	pop    rbp
    17c4:	ret

00000000000017c5 <botlish_fn_20: high_nibble<int>>:
    17c5:	push   rbp
    17c6:	mov    rbp,rsp
    17c9:	sub    rsp,0x10
    17cd:	mov    QWORD PTR [rsp],rsi
    17d1:	mov    QWORD PTR [rsp+0x8],0x1e1
    17da:	test   rsi,0x1
    17e1:	jne    17f6 <botlish_fn_20+0x31>
    17e7:	mov    edx,0x1e1
    17ec:	call   17f1 <botlish_fn_20+0x2c>
			17ed: R_X86_64_PLT32	rt_int_and-0x4
    17f1:	jmp    1800 <botlish_fn_20+0x3b>
    17f6:	and    rsi,0x1e1
    17fd:	mov    rax,rsi
    1800:	sar    rax,0x5
    1804:	shl    rax,1
    1807:	or     rax,0x1
    180b:	add    rsp,0x10
    180f:	mov    rsp,rbp
    1812:	pop    rbp
    1813:	ret

0000000000001814 <botlish_entry_20: high_nibble<int>>:
    1814:	push   rbp
    1815:	mov    rbp,rsp
    1818:	mov    rsi,QWORD PTR [rdx]
    181b:	call   1820 <botlish_entry_20+0xc>
			181c: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    1820:	mov    rsp,rbp
    1823:	pop    rbp
    1824:	ret

0000000000001825 <botlish_fn_21: hex_pair<int>>:
    1825:	push   rbp
    1826:	mov    rbp,rsp
    1829:	sub    rsp,0x50
    182d:	mov    QWORD PTR [rsp+0x30],rbx
    1832:	mov    QWORD PTR [rsp+0x38],r12
    1837:	mov    QWORD PTR [rsp+0x40],r13
    183c:	mov    QWORD PTR [rsp+0x48],r14
    1841:	mov    QWORD PTR [rsp],rsi
    1845:	mov    r12,rsi
    1848:	mov    rax,QWORD PTR [rdi+0x30]
    184c:	mov    rbx,rdi
    184f:	mov    rsi,QWORD PTR [rax+0x8]
    1853:	mov    QWORD PTR [rsp+0x8],rsi
    1858:	mov    r13,rsi
    185b:	mov    rsi,r12
    185e:	call   1863 <botlish_fn_21+0x3e>
			185f: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    1863:	test   rax,0x1
    1869:	jne    187a <botlish_fn_21+0x55>
    186f:	mov    rdx,rax
    1872:	mov    rsi,r13
    1875:	jmp    1893 <botlish_fn_21+0x6e>
    187a:	mov    rsi,r13
    187d:	mov    rdx,QWORD PTR [rsi+0x8]
    1881:	mov    rcx,rax
    1884:	sar    rcx,1
    1887:	cmp    rcx,rdx
    188a:	jb     18a9 <botlish_fn_21+0x84>
    1890:	mov    rdx,rax
    1893:	mov    rdi,rbx
    1896:	call   189b <botlish_fn_21+0x76>
			1897: R_X86_64_PLT32	rt_list_get-0x4
    189b:	test   rax,rax
    189e:	je     196e <botlish_fn_21+0x149>
    18a4:	jmp    18b1 <botlish_fn_21+0x8c>
    18a9:	mov    rax,QWORD PTR [rsi+0x10]
    18ad:	mov    rax,QWORD PTR [rax+rcx*8]
    18b1:	mov    QWORD PTR [rsp],rax
    18b5:	mov    rdi,rbx
    18b8:	mov    r14,rax
    18bb:	mov    rax,QWORD PTR [rdi+0x30]
    18bf:	mov    rsi,QWORD PTR [rax+0x8]
    18c3:	mov    r13,rsi
    18c6:	mov    edx,0x21
    18cb:	mov    rsi,r12
    18ce:	call   18d3 <botlish_fn_21+0xae>
			18cf: R_X86_64_PLT32	rt_int_mod-0x4
    18d3:	test   rax,rax
    18d6:	je     196e <botlish_fn_21+0x149>
    18dc:	test   rax,0x1
    18e2:	jne    18f3 <botlish_fn_21+0xce>
    18e8:	mov    rdx,rax
    18eb:	mov    rsi,r13
    18ee:	jmp    190c <botlish_fn_21+0xe7>
    18f3:	mov    rsi,r13
    18f6:	mov    rdx,QWORD PTR [rsi+0x8]
    18fa:	mov    rcx,rax
    18fd:	sar    rcx,1
    1900:	cmp    rcx,rdx
    1903:	jb     1922 <botlish_fn_21+0xfd>
    1909:	mov    rdx,rax
    190c:	mov    rdi,rbx
    190f:	call   1914 <botlish_fn_21+0xef>
			1910: R_X86_64_PLT32	rt_list_get-0x4
    1914:	test   rax,rax
    1917:	je     196e <botlish_fn_21+0x149>
    191d:	jmp    192a <botlish_fn_21+0x105>
    1922:	mov    rax,QWORD PTR [rsi+0x10]
    1926:	mov    rax,QWORD PTR [rax+rcx*8]
    192a:	mov    QWORD PTR [rsp+0x8],rax
    192f:	lea    rcx,[rsp+0x10]
    1934:	mov    QWORD PTR [rsp+0x10],0x0
    193d:	mov    rdx,r14
    1940:	mov    QWORD PTR [rsp+0x18],rdx
    1945:	mov    QWORD PTR [rsp+0x20],0x0
    194e:	mov    QWORD PTR [rsp+0x28],rax
    1953:	mov    esi,0x2
    1958:	mov    edx,0x4
    195d:	mov    rdi,rbx
    1960:	call   1965 <botlish_fn_21+0x140>
			1961: R_X86_64_PLT32	rt_construct-0x4
    1965:	test   rax,rax
    1968:	jne    198e <botlish_fn_21+0x169>
    196e:	xor    rax,rax
    1971:	mov    rbx,QWORD PTR [rsp+0x30]
    1976:	mov    r12,QWORD PTR [rsp+0x38]
    197b:	mov    r13,QWORD PTR [rsp+0x40]
    1980:	mov    r14,QWORD PTR [rsp+0x48]
    1985:	add    rsp,0x50
    1989:	mov    rsp,rbp
    198c:	pop    rbp
    198d:	ret
    198e:	mov    rbx,QWORD PTR [rsp+0x30]
    1993:	mov    r12,QWORD PTR [rsp+0x38]
    1998:	mov    r13,QWORD PTR [rsp+0x40]
    199d:	mov    r14,QWORD PTR [rsp+0x48]
    19a2:	add    rsp,0x50
    19a6:	mov    rsp,rbp
    19a9:	pop    rbp
    19aa:	ret

00000000000019ab <botlish_entry_21: hex_pair<int>>:
    19ab:	push   rbp
    19ac:	mov    rbp,rsp
    19af:	sub    rsp,0x10
    19b3:	mov    QWORD PTR [rsp],r12
    19b7:	mov    r12,rdi
    19ba:	mov    rsi,QWORD PTR [rdx]
    19bd:	call   19c2 <botlish_entry_21+0x17>
			19be: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    19c2:	mov    r8,QWORD PTR [rip+0x0]        # 19c9 <botlish_entry_21+0x1e>
			19c5: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    19c9:	mov    rsi,rax
    19cc:	mov    rdi,r12
    19cf:	call   r8
    19d2:	mov    r12,QWORD PTR [rsp]
    19d6:	add    rsp,0x10
    19da:	mov    rsp,rbp
    19dd:	pop    rbp
    19de:	ret

00000000000019df <botlish_fn_22: esc_bytes<List[int], int, str>>:
    19df:	push   rbp
    19e0:	mov    rbp,rsp
    19e3:	sub    rsp,0x90
    19ea:	mov    QWORD PTR [rsp+0x60],rbx
    19ef:	mov    QWORD PTR [rsp+0x68],r12
    19f4:	mov    QWORD PTR [rsp+0x70],r13
    19f9:	mov    QWORD PTR [rsp+0x78],r14
    19fe:	mov    QWORD PTR [rsp+0x80],r15
    1a06:	mov    QWORD PTR [rsp],rsi
    1a0a:	mov    QWORD PTR [rsp+0x8],rcx
    1a0f:	sar    rdx,1
    1a12:	mov    r13,rdx
    1a15:	lea    r14,[rsp+0x20]
    1a1a:	mov    rbx,rdi
    1a1d:	mov    r12,rsi
    1a20:	mov    QWORD PTR [rsp+0x50],rcx
    1a25:	mov    rsi,r12
    1a28:	mov    rdi,rbx
    1a2b:	call   1a30 <botlish_fn_22+0x51>
			1a2c: R_X86_64_PLT32	rt_list_len-0x4
    1a30:	sar    rax,1
    1a33:	cmp    r13,rax
    1a36:	jge    1b46 <botlish_fn_22+0x167>
    1a3c:	mov    rax,QWORD PTR [rbx+0x10]
    1a40:	mov    r15,QWORD PTR [rax+0x10]
    1a44:	mov    QWORD PTR [rsp+0x10],r15
    1a49:	mov    rcx,QWORD PTR [r12+0x8]
    1a4e:	mov    rax,r13
    1a51:	shl    rax,1
    1a54:	or     rax,0x1
    1a58:	sar    rax,1
    1a5b:	cmp    rax,rcx
    1a5e:	jb     1a8a <botlish_fn_22+0xab>
    1a64:	mov    rdx,r13
    1a67:	shl    rdx,1
    1a6a:	or     rdx,0x1
    1a6e:	mov    rsi,r12
    1a71:	mov    rdi,rbx
    1a74:	call   1a79 <botlish_fn_22+0x9a>
			1a75: R_X86_64_PLT32	rt_list_get-0x4
    1a79:	test   rax,rax
    1a7c:	je     1b01 <botlish_fn_22+0x122>
    1a82:	mov    rsi,rax
    1a85:	jmp    1a93 <botlish_fn_22+0xb4>
    1a8a:	mov    rcx,QWORD PTR [r12+0x10]
    1a8f:	mov    rsi,QWORD PTR [rcx+rax*8]
    1a93:	mov    QWORD PTR [rsp+0x18],rsi
    1a98:	mov    rdi,rbx
    1a9b:	call   1aa0 <botlish_fn_22+0xc1>
			1a9c: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1aa0:	test   rax,rax
    1aa3:	je     1b01 <botlish_fn_22+0x122>
    1aa9:	mov    QWORD PTR [rsp+0x18],rax
    1aae:	mov    rcx,rax
    1ab1:	mov    QWORD PTR [rsp+0x20],0x0
    1aba:	mov    rax,QWORD PTR [rsp+0x50]
    1abf:	mov    QWORD PTR [rsp+0x28],rax
    1ac4:	mov    QWORD PTR [rsp+0x30],0x0
    1acd:	mov    QWORD PTR [rsp+0x38],r15
    1ad2:	mov    QWORD PTR [rsp+0x40],0x0
    1adb:	mov    rax,rcx
    1ade:	mov    QWORD PTR [rsp+0x48],rax
    1ae3:	mov    esi,0x2
    1ae8:	mov    edx,0x6
    1aed:	mov    rcx,r14
    1af0:	mov    rdi,rbx
    1af3:	call   1af8 <botlish_fn_22+0x119>
			1af4: R_X86_64_PLT32	rt_construct-0x4
    1af8:	test   rax,rax
    1afb:	jne    1b2c <botlish_fn_22+0x14d>
    1b01:	xor    rax,rax
    1b04:	mov    rbx,QWORD PTR [rsp+0x60]
    1b09:	mov    r12,QWORD PTR [rsp+0x68]
    1b0e:	mov    r13,QWORD PTR [rsp+0x70]
    1b13:	mov    r14,QWORD PTR [rsp+0x78]
    1b18:	mov    r15,QWORD PTR [rsp+0x80]
    1b20:	add    rsp,0x90
    1b27:	mov    rsp,rbp
    1b2a:	pop    rbp
    1b2b:	ret
    1b2c:	mov    QWORD PTR [rsp],r12
    1b30:	mov    QWORD PTR [rsp+0x8],rax
    1b35:	add    r13,0x1
    1b3c:	mov    QWORD PTR [rsp+0x50],rax
    1b41:	jmp    1a25 <botlish_fn_22+0x46>
    1b46:	mov    rax,QWORD PTR [rsp+0x50]
    1b4b:	mov    rbx,QWORD PTR [rsp+0x60]
    1b50:	mov    r12,QWORD PTR [rsp+0x68]
    1b55:	mov    r13,QWORD PTR [rsp+0x70]
    1b5a:	mov    r14,QWORD PTR [rsp+0x78]
    1b5f:	mov    r15,QWORD PTR [rsp+0x80]
    1b67:	add    rsp,0x90
    1b6e:	mov    rsp,rbp
    1b71:	pop    rbp
    1b72:	ret

0000000000001b73 <botlish_entry_22: esc_bytes<List[int], int, str>>:
    1b73:	push   rbp
    1b74:	mov    rbp,rsp
    1b77:	sub    rsp,0x10
    1b7b:	mov    QWORD PTR [rsp],r12
    1b7f:	mov    r12,rdi
    1b82:	mov    rsi,QWORD PTR [rdx]
    1b85:	mov    r8,QWORD PTR [rdx+0x8]
    1b89:	mov    rcx,QWORD PTR [rdx+0x10]
    1b8d:	mov    rdx,r8
    1b90:	call   1b95 <botlish_entry_22+0x22>
			1b91: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1b95:	mov    r8,QWORD PTR [rip+0x0]        # 1b9c <botlish_entry_22+0x29>
			1b98: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1b9c:	mov    rsi,rax
    1b9f:	mov    rdi,r12
    1ba2:	call   r8
    1ba5:	mov    r12,QWORD PTR [rsp]
    1ba9:	add    rsp,0x10
    1bad:	mov    rsp,rbp
    1bb0:	pop    rbp
    1bb1:	ret

0000000000001bb2 <botlish_fn_23: esc_char<str>>:
    1bb2:	push   rbp
    1bb3:	mov    rbp,rsp
    1bb6:	sub    rsp,0x40
    1bba:	mov    QWORD PTR [rsp+0x20],rbx
    1bbf:	mov    QWORD PTR [rsp+0x28],r12
    1bc4:	mov    QWORD PTR [rsp+0x30],r13
    1bc9:	mov    rbx,rdi
    1bcc:	mov    QWORD PTR [rsp+0x8],0x0
    1bd5:	mov    QWORD PTR [rsp+0x10],0x0
    1bde:	mov    QWORD PTR [rsp],rsi
    1be2:	mov    r13,rsi
    1be5:	mov    rsi,r13
    1be8:	mov    rdi,rbx
    1beb:	call   1bf0 <botlish_fn_23+0x3e>
			1bec: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1bf0:	mov    rcx,rax
    1bf3:	mov    r12,rax
    1bf6:	test   rax,rcx
    1bf9:	je     1cd7 <botlish_fn_23+0x125>
    1bff:	mov    rax,r12
    1c02:	mov    QWORD PTR [rsp],rax
    1c06:	mov    rsi,r12
    1c09:	mov    rdi,rbx
    1c0c:	call   1c11 <botlish_fn_23+0x5f>
			1c0d: R_X86_64_PLT32	rt_list_len-0x4
    1c11:	sar    rax,1
    1c14:	cmp    rax,0x1
    1c18:	je     1c55 <botlish_fn_23+0xa3>
    1c1e:	mov    edx,0x1
    1c23:	mov    QWORD PTR [rsp+0x8],0x1
    1c2c:	mov    rdi,rbx
    1c2f:	mov    rax,QWORD PTR [rdi+0x10]
    1c33:	mov    rcx,QWORD PTR [rax+0xe0]
    1c3a:	mov    QWORD PTR [rsp+0x10],rcx
    1c3f:	mov    rsi,r12
    1c42:	call   1c47 <botlish_fn_23+0x95>
			1c43: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1c47:	test   rax,rax
    1c4a:	je     1cd7 <botlish_fn_23+0x125>
    1c50:	jmp    1cf8 <botlish_fn_23+0x146>
    1c55:	mov    rsi,r12
    1c58:	mov    rax,QWORD PTR [rsi+0x8]
    1c5c:	mov    r12,rsi
    1c5f:	test   rax,rax
    1c62:	jne    1c89 <botlish_fn_23+0xd7>
    1c68:	mov    edx,0x1
    1c6d:	mov    rsi,r12
    1c70:	mov    rdi,rbx
    1c73:	call   1c78 <botlish_fn_23+0xc6>
			1c74: R_X86_64_PLT32	rt_list_get-0x4
    1c78:	test   rax,rax
    1c7b:	je     1cd7 <botlish_fn_23+0x125>
    1c81:	mov    rsi,rax
    1c84:	jmp    1c93 <botlish_fn_23+0xe1>
    1c89:	mov    rsi,r12
    1c8c:	mov    rax,QWORD PTR [rsi+0x10]
    1c90:	mov    rsi,QWORD PTR [rax]
    1c93:	mov    rdi,rbx
    1c96:	call   1c9b <botlish_fn_23+0xe9>
			1c97: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1c9b:	cmp    rax,0x6
    1c9f:	je     1cf5 <botlish_fn_23+0x143>
    1ca5:	mov    edx,0x1
    1caa:	mov    QWORD PTR [rsp+0x8],0x1
    1cb3:	mov    rdi,rbx
    1cb6:	mov    rax,QWORD PTR [rdi+0x10]
    1cba:	mov    rcx,QWORD PTR [rax+0xe0]
    1cc1:	mov    QWORD PTR [rsp+0x10],rcx
    1cc6:	mov    rsi,r12
    1cc9:	call   1cce <botlish_fn_23+0x11c>
			1cca: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1cce:	test   rax,rax
    1cd1:	jne    1cf2 <botlish_fn_23+0x140>
    1cd7:	xor    rax,rax
    1cda:	mov    rbx,QWORD PTR [rsp+0x20]
    1cdf:	mov    r12,QWORD PTR [rsp+0x28]
    1ce4:	mov    r13,QWORD PTR [rsp+0x30]
    1ce9:	add    rsp,0x40
    1ced:	mov    rsp,rbp
    1cf0:	pop    rbp
    1cf1:	ret
    1cf2:	mov    r13,rax
    1cf5:	mov    rax,r13
    1cf8:	mov    rbx,QWORD PTR [rsp+0x20]
    1cfd:	mov    r12,QWORD PTR [rsp+0x28]
    1d02:	mov    r13,QWORD PTR [rsp+0x30]
    1d07:	add    rsp,0x40
    1d0b:	mov    rsp,rbp
    1d0e:	pop    rbp
    1d0f:	ret

0000000000001d10 <botlish_entry_23: esc_char<str>>:
    1d10:	push   rbp
    1d11:	mov    rbp,rsp
    1d14:	sub    rsp,0x10
    1d18:	mov    QWORD PTR [rsp],r12
    1d1c:	mov    r12,rdi
    1d1f:	mov    rsi,QWORD PTR [rdx]
    1d22:	call   1d27 <botlish_entry_23+0x17>
			1d23: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1d27:	mov    r8,QWORD PTR [rip+0x0]        # 1d2e <botlish_entry_23+0x1e>
			1d2a: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1d2e:	mov    rsi,rax
    1d31:	mov    rdi,r12
    1d34:	call   r8
    1d37:	mov    r12,QWORD PTR [rsp]
    1d3b:	add    rsp,0x10
    1d3f:	mov    rsp,rbp
    1d42:	pop    rbp
    1d43:	ret

0000000000001d44 <botlish_fn_24: esc_from<str, int, str>>:
    1d44:	push   rbp
    1d45:	mov    rbp,rsp
    1d48:	sub    rsp,0x90
    1d4f:	mov    QWORD PTR [rsp+0x60],rbx
    1d54:	mov    QWORD PTR [rsp+0x68],r12
    1d59:	mov    QWORD PTR [rsp+0x70],r13
    1d5e:	mov    QWORD PTR [rsp+0x78],r14
    1d63:	mov    QWORD PTR [rsp+0x80],r15
    1d6b:	mov    r14,rdi
    1d6e:	mov    QWORD PTR [rsp+0x8],0x0
    1d77:	mov    QWORD PTR [rsp+0x10],0x0
    1d80:	mov    QWORD PTR [rsp+0x18],0x0
    1d89:	mov    QWORD PTR [rsp],rcx
    1d8d:	mov    QWORD PTR [rsp+0x50],rcx
    1d92:	sar    rdx,1
    1d95:	mov    r13d,0x47
    1d9b:	mov    rcx,0xffffffffffffffff
    1da2:	bsr    rax,rsi
    1da6:	mov    r15,rsi
    1da9:	cmove  rax,rcx
    1dad:	mov    ecx,0x3f
    1db2:	sub    rcx,rax
    1db5:	sub    r13,rcx
    1db8:	shr    r13,0x3
    1dbc:	lea    rbx,[rsp+0x30]
    1dc1:	mov    r12,rdx
    1dc4:	cmp    r12,r13
    1dc7:	jge    1e81 <botlish_fn_24+0x13d>
    1dcd:	mov    rsi,r15
    1dd0:	mov    rdi,r14
    1dd3:	call   1dd8 <botlish_fn_24+0x94>
			1dd4: R_X86_64_PLT32	rt_ascii_to_str-0x4
    1dd8:	mov    QWORD PTR [rsp+0x8],rax
    1ddd:	mov    rdx,r12
    1de0:	shl    rdx,1
    1de3:	or     rdx,0x1
    1de7:	mov    QWORD PTR [rsp+0x10],rdx
    1dec:	add    r12,0x1
    1df3:	mov    rcx,r12
    1df6:	shl    rcx,1
    1df9:	or     rcx,0x1
    1dfd:	mov    QWORD PTR [rsp+0x18],rcx
    1e02:	mov    rsi,rax
    1e05:	mov    rdi,r14
    1e08:	call   1e0d <botlish_fn_24+0xc9>
			1e09: R_X86_64_PLT32	rt_substr-0x4
    1e0d:	test   rax,rax
    1e10:	je     1eb5 <botlish_fn_24+0x171>
    1e16:	mov    QWORD PTR [rsp+0x8],rax
    1e1b:	mov    rsi,rax
    1e1e:	mov    rdi,r14
    1e21:	call   1e26 <botlish_fn_24+0xe2>
			1e22: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1e26:	test   rax,rax
    1e29:	je     1eb5 <botlish_fn_24+0x171>
    1e2f:	mov    QWORD PTR [rsp+0x8],rax
    1e34:	mov    QWORD PTR [rsp+0x30],0x0
    1e3d:	mov    rcx,QWORD PTR [rsp+0x50]
    1e42:	mov    QWORD PTR [rsp+0x38],rcx
    1e47:	mov    QWORD PTR [rsp+0x40],0x0
    1e50:	mov    QWORD PTR [rsp+0x48],rax
    1e55:	mov    esi,0x2
    1e5a:	mov    edx,0x4
    1e5f:	mov    rcx,rbx
    1e62:	mov    rdi,r14
    1e65:	call   1e6a <botlish_fn_24+0x126>
			1e66: R_X86_64_PLT32	rt_construct-0x4
    1e6a:	test   rax,rax
    1e6d:	je     1eb5 <botlish_fn_24+0x171>
    1e73:	mov    QWORD PTR [rsp],rax
    1e77:	mov    QWORD PTR [rsp+0x50],rax
    1e7c:	jmp    1dc4 <botlish_fn_24+0x80>
    1e81:	mov    rcx,QWORD PTR [rsp+0x50]
    1e86:	xor    rsi,rsi
    1e89:	lea    rax,[rsp+0x20]
    1e8e:	mov    QWORD PTR [rsp+0x20],0x0
    1e97:	mov    QWORD PTR [rsp+0x28],rcx
    1e9c:	mov    edx,0x2
    1ea1:	mov    rcx,rax
    1ea4:	mov    rdi,r14
    1ea7:	call   1eac <botlish_fn_24+0x168>
			1ea8: R_X86_64_PLT32	rt_construct-0x4
    1eac:	test   rax,rax
    1eaf:	jne    1ee0 <botlish_fn_24+0x19c>
    1eb5:	xor    rax,rax
    1eb8:	mov    rbx,QWORD PTR [rsp+0x60]
    1ebd:	mov    r12,QWORD PTR [rsp+0x68]
    1ec2:	mov    r13,QWORD PTR [rsp+0x70]
    1ec7:	mov    r14,QWORD PTR [rsp+0x78]
    1ecc:	mov    r15,QWORD PTR [rsp+0x80]
    1ed4:	add    rsp,0x90
    1edb:	mov    rsp,rbp
    1ede:	pop    rbp
    1edf:	ret
    1ee0:	mov    rbx,QWORD PTR [rsp+0x60]
    1ee5:	mov    r12,QWORD PTR [rsp+0x68]
    1eea:	mov    r13,QWORD PTR [rsp+0x70]
    1eef:	mov    r14,QWORD PTR [rsp+0x78]
    1ef4:	mov    r15,QWORD PTR [rsp+0x80]
    1efc:	add    rsp,0x90
    1f03:	mov    rsp,rbp
    1f06:	pop    rbp
    1f07:	ret

0000000000001f08 <botlish_entry_24: esc_from<str, int, str>>:
    1f08:	push   rbp
    1f09:	mov    rbp,rsp
    1f0c:	sub    rsp,0x10
    1f10:	mov    QWORD PTR [rsp],r12
    1f14:	mov    QWORD PTR [rsp+0x8],r13
    1f19:	mov    r12,rdi
    1f1c:	mov    rsi,QWORD PTR [rdx]
    1f1f:	mov    r13,rdx
    1f22:	mov    r8,QWORD PTR [rip+0x0]        # 1f29 <botlish_entry_24+0x21>
			1f25: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    1f29:	call   r8
    1f2c:	mov    rcx,r13
    1f2f:	mov    rdx,QWORD PTR [rcx+0x8]
    1f33:	mov    rcx,QWORD PTR [rcx+0x10]
    1f37:	mov    rsi,rax
    1f3a:	mov    rdi,r12
    1f3d:	call   1f42 <botlish_entry_24+0x3a>
			1f3e: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    1f42:	mov    r12,QWORD PTR [rsp]
    1f46:	mov    r13,QWORD PTR [rsp+0x8]
    1f4b:	add    rsp,0x10
    1f4f:	mov    rsp,rbp
    1f52:	pop    rbp
    1f53:	ret

0000000000001f54 <botlish_fn_25: check<int, int, str, str>>:
    1f54:	push   rbp
    1f55:	mov    rbp,rsp
    1f58:	sub    rsp,0x50
    1f5c:	mov    QWORD PTR [rsp+0x20],rbx
    1f61:	mov    QWORD PTR [rsp+0x28],r12
    1f66:	mov    QWORD PTR [rsp+0x30],r13
    1f6b:	mov    QWORD PTR [rsp+0x38],r14
    1f70:	mov    QWORD PTR [rsp+0x40],r15
    1f75:	mov    r14,rdi
    1f78:	mov    QWORD PTR [rsp+0x18],0x0
    1f81:	mov    QWORD PTR [rsp],rdx
    1f85:	mov    QWORD PTR [rsp+0x8],rcx
    1f8a:	mov    QWORD PTR [rsp+0x10],r8
    1f8f:	mov    r13,r8
    1f92:	mov    r12,rsi
    1f95:	mov    r15,rdx
    1f98:	test   r12,r12
    1f9b:	jle    205d <botlish_fn_25+0x109>
    1fa1:	mov    rbx,rcx
    1fa4:	mov    rsi,rbx
    1fa7:	mov    rdi,r14
    1faa:	call   1faf <botlish_fn_25+0x5b>
			1fab: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
    1faf:	test   rax,rax
    1fb2:	jne    1fdd <botlish_fn_25+0x89>
    1fb8:	xor    rax,rax
    1fbb:	mov    rbx,QWORD PTR [rsp+0x20]
    1fc0:	mov    r12,QWORD PTR [rsp+0x28]
    1fc5:	mov    r13,QWORD PTR [rsp+0x30]
    1fca:	mov    r14,QWORD PTR [rsp+0x38]
    1fcf:	mov    r15,QWORD PTR [rsp+0x40]
    1fd4:	add    rsp,0x50
    1fd8:	mov    rsp,rbp
    1fdb:	pop    rbp
    1fdc:	ret
    1fdd:	cmp    rax,0x6
    1fe1:	je     1ffd <botlish_fn_25+0xa9>
    1fe7:	mov    edx,0x1
    1fec:	mov    QWORD PTR [rsp+0x18],0x1
    1ff5:	mov    rsi,r15
    1ff8:	jmp    200e <botlish_fn_25+0xba>
    1ffd:	mov    edx,0x3
    2002:	mov    QWORD PTR [rsp+0x18],0x3
    200b:	mov    rsi,r15
    200e:	mov    rax,rsi
    2011:	and    rax,rdx
    2014:	test   rax,0x1
    201a:	je     2035 <botlish_fn_25+0xe1>
    2020:	lea    rcx,[rdx-0x1]
    2024:	mov    rax,rsi
    2027:	add    rax,rcx
    202a:	seto   cl
    202d:	test   cl,cl
    202f:	je     203d <botlish_fn_25+0xe9>
    2035:	mov    rdi,r14
    2038:	call   203d <botlish_fn_25+0xe9>
			2039: R_X86_64_PLT32	rt_int_add-0x4
    203d:	mov    QWORD PTR [rsp],rax
    2041:	mov    QWORD PTR [rsp+0x8],rbx
    2046:	mov    r8,r13
    2049:	mov    QWORD PTR [rsp+0x10],r8
    204e:	sub    r12,0x1
    2052:	mov    rcx,rbx
    2055:	mov    r15,rax
    2058:	jmp    1f98 <botlish_fn_25+0x44>
    205d:	mov    rax,r15
    2060:	mov    rbx,QWORD PTR [rsp+0x20]
    2065:	mov    r12,QWORD PTR [rsp+0x28]
    206a:	mov    r13,QWORD PTR [rsp+0x30]
    206f:	mov    r14,QWORD PTR [rsp+0x38]
    2074:	mov    r15,QWORD PTR [rsp+0x40]
    2079:	add    rsp,0x50
    207d:	mov    rsp,rbp
    2080:	pop    rbp
    2081:	ret

0000000000002082 <botlish_entry_25: check<int, int, str, str>>:
    2082:	push   rbp
    2083:	mov    rbp,rsp
    2086:	mov    rsi,QWORD PTR [rdx]
    2089:	mov    r9,QWORD PTR [rdx+0x8]
    208d:	mov    rcx,QWORD PTR [rdx+0x10]
    2091:	mov    r8,QWORD PTR [rdx+0x18]
    2095:	sar    rsi,1
    2098:	mov    rdx,r9
    209b:	call   20a0 <botlish_entry_25+0x1e>
			209c: R_X86_64_PLT32	botlish_fn_25-0x4 ; check<int, int, str, str>
    20a0:	mov    rsp,rbp
    20a3:	pop    rbp
    20a4:	ret

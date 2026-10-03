; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 8108  (per function: 1415 39 289 609 74 74 74 128 128 351 166 111 176 238 301 326 183 782 140 127 103 474 491 426 539 344)
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
     ae8:	mov    rdi,r13
     aeb:	mov    rax,QWORD PTR [rdi+0x10]
     aef:	mov    rdx,QWORD PTR [rax+0xc0]
     af6:	mov    QWORD PTR [rsp+0x10],rdx
     afb:	xor    rsi,rsi
     afe:	mov    rcx,r14
     b01:	mov    r8,r12
     b04:	call   b09 <botlish_fn_9+0x5a>
			b05: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, block(e239)>
     b09:	test   rax,rax
     b0c:	je     b9e <botlish_fn_9+0xef>
     b12:	mov    rbx,rax
     b15:	sar    rbx,1
     b18:	mov    rsi,rax
     b1b:	test   rbx,rbx
     b1e:	je     bcd <botlish_fn_9+0x11e>
     b24:	mov    rax,r14
     b27:	mov    rcx,rax
     b2a:	sar    rcx,1
     b2d:	cmp    rbx,rcx
     b30:	jge    bc3 <botlish_fn_9+0x114>
     b36:	lea    rcx,[rsp+0x18]
     b3b:	mov    rdx,r12
     b3e:	mov    rdi,r13
     b41:	call   b46 <botlish_fn_9+0x97>
			b42: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
     b46:	test   rax,rax
     b49:	mov    rsi,rax
     b4c:	je     b9e <botlish_fn_9+0xef>
     b52:	mov    rdx,QWORD PTR [rsp+0x18]
     b57:	mov    rcx,QWORD PTR [rsp+0x20]
     b5c:	mov    rdi,r13
     b5f:	mov    rax,QWORD PTR [rdi+0x10]
     b63:	mov    r8,QWORD PTR [rax+0xc8]
     b6a:	call   b6f <botlish_fn_9+0xc0>
			b6b: R_X86_64_PLT32	rt_str_region_eq-0x4
     b6f:	cmp    rax,0x6
     b73:	je     b83 <botlish_fn_9+0xd4>
     b79:	mov    eax,0x2
     b7e:	jmp    bd2 <botlish_fn_9+0x123>
     b83:	lea    rsi,[rbx+0x1]
     b87:	mov    rcx,r12
     b8a:	mov    rdx,r14
     b8d:	mov    rdi,r13
     b90:	call   b95 <botlish_fn_9+0xe6>
			b91: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<int>
     b95:	test   rax,rax
     b98:	jne    bd2 <botlish_fn_9+0x123>
     b9e:	xor    rax,rax
     ba1:	mov    rbx,QWORD PTR [rsp+0x30]
     ba6:	mov    r12,QWORD PTR [rsp+0x38]
     bab:	mov    r13,QWORD PTR [rsp+0x40]
     bb0:	mov    r14,QWORD PTR [rsp+0x48]
     bb5:	add    rsp,0x50
     bb9:	mov    rsp,rbp
     bbc:	pop    rbp
     bbd:	ret
     bbe:	jmp    bd2 <botlish_fn_9+0x123>
     bc3:	mov    eax,0x2
     bc8:	jmp    bd2 <botlish_fn_9+0x123>
     bcd:	mov    eax,0x2
     bd2:	mov    rbx,QWORD PTR [rsp+0x30]
     bd7:	mov    r12,QWORD PTR [rsp+0x38]
     bdc:	mov    r13,QWORD PTR [rsp+0x40]
     be1:	mov    r14,QWORD PTR [rsp+0x48]
     be6:	add    rsp,0x50
     bea:	mov    rsp,rbp
     bed:	pop    rbp
     bee:	ret

0000000000000bef <botlish_entry_9: web::emailish?<str>>:
     bef:	push   rbp
     bf0:	mov    rbp,rsp
     bf3:	mov    rsi,QWORD PTR [rdx]
     bf6:	call   bfb <botlish_entry_9+0xc>
			bf7: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
     bfb:	mov    rsp,rbp
     bfe:	pop    rbp
     bff:	ret

0000000000000c00 <botlish_fn_10: char_at<int>>:
     c00:	push   rbp
     c01:	mov    rbp,rsp
     c04:	sub    rsp,0x20
     c08:	mov    QWORD PTR [rsp],rbx
     c0c:	mov    QWORD PTR [rsp+0x8],r12
     c11:	mov    QWORD PTR [rsp+0x10],r13
     c16:	mov    QWORD PTR [rsp+0x18],r15
     c1b:	mov    r13,rdx
     c1e:	mov    r15,rcx
     c21:	mov    rax,rsi
     c24:	sar    rax,1
     c27:	lea    r12,[rax+0x1]
     c2b:	shl    r12,1
     c2e:	mov    rcx,r12
     c31:	or     rcx,0x1
     c35:	mov    rbx,rsi
     c38:	mov    rdx,rbx
     c3b:	mov    rsi,r13
     c3e:	call   c43 <botlish_fn_10+0x43>
			c3f: R_X86_64_PLT32	rt_str_region_check-0x4
     c43:	test   rax,rax
     c46:	jne    c6b <botlish_fn_10+0x6b>
     c4c:	xor    rax,rax
     c4f:	mov    rbx,QWORD PTR [rsp]
     c53:	mov    r12,QWORD PTR [rsp+0x8]
     c58:	mov    r13,QWORD PTR [rsp+0x10]
     c5d:	mov    r15,QWORD PTR [rsp+0x18]
     c62:	add    rsp,0x20
     c66:	mov    rsp,rbp
     c69:	pop    rbp
     c6a:	ret
     c6b:	mov    rcx,r15
     c6e:	mov    QWORD PTR [rcx],rbx
     c71:	or     r12,0x1
     c75:	mov    QWORD PTR [rcx+0x8],r12
     c79:	mov    rax,r13
     c7c:	mov    rbx,QWORD PTR [rsp]
     c80:	mov    r12,QWORD PTR [rsp+0x8]
     c85:	mov    r13,QWORD PTR [rsp+0x10]
     c8a:	mov    r15,QWORD PTR [rsp+0x18]
     c8f:	add    rsp,0x20
     c93:	mov    rsp,rbp
     c96:	pop    rbp
     c97:	ret

0000000000000c98 <botlish_entry_10: char_at<int>>:
     c98:	push   rbp
     c99:	mov    rbp,rsp
     c9c:	ud2

0000000000000c9e <botlish_fn_11: char_at<int>>:
     c9e:	push   rbp
     c9f:	mov    rbp,rsp
     ca2:	sub    rsp,0x20
     ca6:	mov    QWORD PTR [rsp],rsi
     caa:	mov    QWORD PTR [rsp+0x8],rdx
     caf:	mov    rax,rsi
     cb2:	sar    rax,1
     cb5:	lea    rcx,[rax+0x1]
     cb9:	shl    rcx,1
     cbc:	or     rcx,0x1
     cc0:	mov    QWORD PTR [rsp+0x10],rcx
     cc5:	mov    rax,rdx
     cc8:	mov    rdx,rsi
     ccb:	mov    rsi,rax
     cce:	call   cd3 <botlish_fn_11+0x35>
			ccf: R_X86_64_PLT32	rt_substr-0x4
     cd3:	test   rax,rax
     cd6:	jne    ce8 <botlish_fn_11+0x4a>
     cdc:	xor    rax,rax
     cdf:	add    rsp,0x20
     ce3:	mov    rsp,rbp
     ce6:	pop    rbp
     ce7:	ret
     ce8:	add    rsp,0x20
     cec:	mov    rsp,rbp
     cef:	pop    rbp
     cf0:	ret

0000000000000cf1 <botlish_entry_11: char_at<int>>:
     cf1:	push   rbp
     cf2:	mov    rbp,rsp
     cf5:	mov    rsi,QWORD PTR [rdx]
     cf8:	mov    rdx,QWORD PTR [rdx+0x8]
     cfc:	call   d01 <botlish_entry_11+0x10>
			cfd: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<int>
     d01:	mov    rsp,rbp
     d04:	pop    rbp
     d05:	ret

0000000000000d06 <botlish_fn_12: local_char?<str>>:
     d06:	push   rbp
     d07:	mov    rbp,rsp
     d0a:	sub    rsp,0x10
     d0e:	mov    QWORD PTR [rsp],rbx
     d12:	mov    QWORD PTR [rsp+0x8],r14
     d17:	mov    rbx,rdi
     d1a:	mov    r14,rsi
     d1d:	mov    rsi,r14
     d20:	mov    rdi,rbx
     d23:	call   d28 <botlish_fn_12+0x22>
			d24: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     d28:	test   rax,rax
     d2b:	jne    d46 <botlish_fn_12+0x40>
     d31:	xor    rax,rax
     d34:	mov    rbx,QWORD PTR [rsp]
     d38:	mov    r14,QWORD PTR [rsp+0x8]
     d3d:	add    rsp,0x10
     d41:	mov    rsp,rbp
     d44:	pop    rbp
     d45:	ret
     d46:	cmp    rax,0x6
     d4a:	je     d80 <botlish_fn_12+0x7a>
     d50:	mov    rdi,rbx
     d53:	mov    rax,QWORD PTR [rdi+0x30]
     d57:	mov    rsi,QWORD PTR [rax]
     d5a:	mov    rdx,r14
     d5d:	call   d62 <botlish_fn_12+0x5c>
			d5e: R_X86_64_PLT32	rt_set_contains-0x4
     d62:	cmp    rax,0x6
     d66:	je     d76 <botlish_fn_12+0x70>
     d6c:	mov    eax,0x2
     d71:	jmp    d85 <botlish_fn_12+0x7f>
     d76:	mov    eax,0x6
     d7b:	jmp    d85 <botlish_fn_12+0x7f>
     d80:	mov    eax,0x6
     d85:	mov    rbx,QWORD PTR [rsp]
     d89:	mov    r14,QWORD PTR [rsp+0x8]
     d8e:	add    rsp,0x10
     d92:	mov    rsp,rbp
     d95:	pop    rbp
     d96:	ret

0000000000000d97 <botlish_entry_12: local_char?<str>>:
     d97:	push   rbp
     d98:	mov    rbp,rsp
     d9b:	mov    rsi,QWORD PTR [rdx]
     d9e:	call   da3 <botlish_entry_12+0xc>
			d9f: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     da3:	mov    rsp,rbp
     da6:	pop    rbp
     da7:	ret

0000000000000da8 <botlish_fn_13: local_char?<generic>>:
     da8:	push   rbp
     da9:	mov    rbp,rsp
     dac:	sub    rsp,0x10
     db0:	mov    QWORD PTR [rsp],rbx
     db4:	mov    QWORD PTR [rsp+0x8],r12
     db9:	xor    r8d,r8d
     dbc:	test   rsi,0x7
     dc3:	jne    dd3 <botlish_fn_13+0x2b>
     dc9:	movzx  rax,BYTE PTR [rsi]
     dcd:	cmp    al,0x2
     dcf:	sete   r8b
     dd3:	test   r8b,r8b
     dd6:	jne    df6 <botlish_fn_13+0x4e>
     ddc:	mov    rax,QWORD PTR [rdi+0x10]
     de0:	mov    rcx,QWORD PTR [rax+0xd0]
     de7:	mov    edx,0x1
     dec:	call   df1 <botlish_fn_13+0x49>
			ded: R_X86_64_PLT32	rt_type_error-0x4
     df1:	jmp    e0a <botlish_fn_13+0x62>
     df6:	mov    rbx,rsi
     df9:	mov    r12,rdi
     dfc:	call   e01 <botlish_fn_13+0x59>
			dfd: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     e01:	test   rax,rax
     e04:	jne    e1f <botlish_fn_13+0x77>
     e0a:	xor    rax,rax
     e0d:	mov    rbx,QWORD PTR [rsp]
     e11:	mov    r12,QWORD PTR [rsp+0x8]
     e16:	add    rsp,0x10
     e1a:	mov    rsp,rbp
     e1d:	pop    rbp
     e1e:	ret
     e1f:	cmp    rax,0x6
     e23:	je     e59 <botlish_fn_13+0xb1>
     e29:	mov    rdi,r12
     e2c:	mov    rax,QWORD PTR [rdi+0x30]
     e30:	mov    rsi,QWORD PTR [rax]
     e33:	mov    rdx,rbx
     e36:	call   e3b <botlish_fn_13+0x93>
			e37: R_X86_64_PLT32	rt_set_contains-0x4
     e3b:	cmp    rax,0x6
     e3f:	je     e4f <botlish_fn_13+0xa7>
     e45:	mov    eax,0x2
     e4a:	jmp    e5e <botlish_fn_13+0xb6>
     e4f:	mov    eax,0x6
     e54:	jmp    e5e <botlish_fn_13+0xb6>
     e59:	mov    eax,0x6
     e5e:	mov    rbx,QWORD PTR [rsp]
     e62:	mov    r12,QWORD PTR [rsp+0x8]
     e67:	add    rsp,0x10
     e6b:	mov    rsp,rbp
     e6e:	pop    rbp
     e6f:	ret

0000000000000e70 <botlish_entry_13: local_char?<generic>>:
     e70:	push   rbp
     e71:	mov    rbp,rsp
     e74:	mov    rsi,QWORD PTR [rdx]
     e77:	call   e7c <botlish_entry_13+0xc>
			e78: R_X86_64_PLT32	botlish_fn_13-0x4 ; local_char?<generic>
     e7c:	mov    rsp,rbp
     e7f:	pop    rbp
     e80:	ret

0000000000000e81 <botlish_fn_14: scan_while<int, block(e239)>>:
     e81:	push   rbp
     e82:	mov    rbp,rsp
     e85:	sub    rsp,0x50
     e89:	mov    QWORD PTR [rsp+0x20],rbx
     e8e:	mov    QWORD PTR [rsp+0x28],r12
     e93:	mov    QWORD PTR [rsp+0x30],r13
     e98:	mov    QWORD PTR [rsp+0x38],r14
     e9d:	mov    QWORD PTR [rsp+0x40],r15
     ea2:	mov    QWORD PTR [rsp+0x18],rdi
     ea7:	mov    QWORD PTR [rsp],rcx
     eab:	mov    QWORD PTR [rsp+0x8],r8
     eb0:	mov    r15,r8
     eb3:	mov    r12,rcx
     eb6:	sar    r12,1
     eb9:	mov    r14,rcx
     ebc:	mov    rbx,rsi
     ebf:	cmp    rbx,r12
     ec2:	jl     eed <botlish_fn_14+0x6c>
     ec8:	mov    rax,r14
     ecb:	mov    rbx,QWORD PTR [rsp+0x20]
     ed0:	mov    r12,QWORD PTR [rsp+0x28]
     ed5:	mov    r13,QWORD PTR [rsp+0x30]
     eda:	mov    r14,QWORD PTR [rsp+0x38]
     edf:	mov    r15,QWORD PTR [rsp+0x40]
     ee4:	add    rsp,0x50
     ee8:	mov    rsp,rbp
     eeb:	pop    rbp
     eec:	ret
     eed:	mov    r13,rbx
     ef0:	shl    r13,1
     ef3:	or     r13,0x1
     ef7:	mov    QWORD PTR [rsp+0x10],r13
     efc:	mov    rdx,r15
     eff:	mov    rsi,r13
     f02:	mov    rdi,QWORD PTR [rsp+0x18]
     f07:	call   f0c <botlish_fn_14+0x8b>
			f08: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<int>
     f0c:	test   rax,rax
     f0f:	mov    rsi,rax
     f12:	je     f2b <botlish_fn_14+0xaa>
     f18:	mov    rdi,QWORD PTR [rsp+0x18]
     f1d:	call   f22 <botlish_fn_14+0xa1>
			f1e: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     f22:	test   rax,rax
     f25:	jne    f50 <botlish_fn_14+0xcf>
     f2b:	xor    rax,rax
     f2e:	mov    rbx,QWORD PTR [rsp+0x20]
     f33:	mov    r12,QWORD PTR [rsp+0x28]
     f38:	mov    r13,QWORD PTR [rsp+0x30]
     f3d:	mov    r14,QWORD PTR [rsp+0x38]
     f42:	mov    r15,QWORD PTR [rsp+0x40]
     f47:	add    rsp,0x50
     f4b:	mov    rsp,rbp
     f4e:	pop    rbp
     f4f:	ret
     f50:	cmp    rax,0x6
     f54:	je     f7f <botlish_fn_14+0xfe>
     f5a:	mov    rax,r13
     f5d:	mov    rbx,QWORD PTR [rsp+0x20]
     f62:	mov    r12,QWORD PTR [rsp+0x28]
     f67:	mov    r13,QWORD PTR [rsp+0x30]
     f6c:	mov    r14,QWORD PTR [rsp+0x38]
     f71:	mov    r15,QWORD PTR [rsp+0x40]
     f76:	add    rsp,0x50
     f7a:	mov    rsp,rbp
     f7d:	pop    rbp
     f7e:	ret
     f7f:	add    rbx,0x1
     f86:	jmp    ebf <botlish_fn_14+0x3e>

0000000000000f8b <botlish_entry_14: scan_while<int, block(e239)>>:
     f8b:	push   rbp
     f8c:	mov    rbp,rsp
     f8f:	mov    rsi,QWORD PTR [rdx]
     f92:	mov    r9,QWORD PTR [rdx+0x8]
     f96:	mov    rcx,QWORD PTR [rdx+0x10]
     f9a:	mov    r8,QWORD PTR [rdx+0x18]
     f9e:	sar    rsi,1
     fa1:	mov    rdx,r9
     fa4:	call   fa9 <botlish_entry_14+0x1e>
			fa5: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, block(e239)>
     fa9:	mov    rsp,rbp
     fac:	pop    rbp
     fad:	ret

0000000000000fae <botlish_fn_15: scan_while<int, native(is_tcl_alpha)>>:
     fae:	push   rbp
     faf:	mov    rbp,rsp
     fb2:	sub    rsp,0x30
     fb6:	mov    QWORD PTR [rsp+0x10],rbx
     fbb:	mov    QWORD PTR [rsp+0x18],r12
     fc0:	mov    QWORD PTR [rsp+0x20],r13
     fc5:	mov    QWORD PTR [rsp+0x28],r14
     fca:	mov    rbx,r8
     fcd:	mov    r12,rdi
     fd0:	mov    rax,rcx
     fd3:	sar    rax,1
     fd6:	mov    r13,rax
     fd9:	mov    rax,rsi
     fdc:	mov    rcx,r13
     fdf:	cmp    rax,rcx
     fe2:	mov    r13,rcx
     fe5:	jl     1010 <botlish_fn_15+0x62>
     feb:	mov    edx,0x1
     ff0:	mov    rax,r13
     ff3:	mov    rbx,QWORD PTR [rsp+0x10]
     ff8:	mov    r12,QWORD PTR [rsp+0x18]
     ffd:	mov    r13,QWORD PTR [rsp+0x20]
    1002:	mov    r14,QWORD PTR [rsp+0x28]
    1007:	add    rsp,0x30
    100b:	mov    rsp,rbp
    100e:	pop    rbp
    100f:	ret
    1010:	mov    rsi,rax
    1013:	shl    rsi,1
    1016:	mov    r14,rax
    1019:	or     rsi,0x1
    101d:	lea    rcx,[rsp]
    1021:	mov    rdx,rbx
    1024:	mov    rdi,r12
    1027:	call   102c <botlish_fn_15+0x7e>
			1028: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    102c:	test   rax,rax
    102f:	mov    rsi,rax
    1032:	je     1052 <botlish_fn_15+0xa4>
    1038:	mov    rdx,QWORD PTR [rsp]
    103c:	mov    rcx,QWORD PTR [rsp+0x8]
    1041:	mov    rdi,r12
    1044:	call   1049 <botlish_fn_15+0x9b>
			1045: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    1049:	test   rax,rax
    104c:	jne    1075 <botlish_fn_15+0xc7>
    1052:	xor    rdx,rdx
    1055:	mov    rax,rdx
    1058:	mov    rbx,QWORD PTR [rsp+0x10]
    105d:	mov    r12,QWORD PTR [rsp+0x18]
    1062:	mov    r13,QWORD PTR [rsp+0x20]
    1067:	mov    r14,QWORD PTR [rsp+0x28]
    106c:	add    rsp,0x30
    1070:	mov    rsp,rbp
    1073:	pop    rbp
    1074:	ret
    1075:	cmp    rax,0x6
    1079:	je     10a4 <botlish_fn_15+0xf6>
    107f:	mov    edx,0x1
    1084:	mov    rax,r14
    1087:	mov    rbx,QWORD PTR [rsp+0x10]
    108c:	mov    r12,QWORD PTR [rsp+0x18]
    1091:	mov    r13,QWORD PTR [rsp+0x20]
    1096:	mov    r14,QWORD PTR [rsp+0x28]
    109b:	add    rsp,0x30
    109f:	mov    rsp,rbp
    10a2:	pop    rbp
    10a3:	ret
    10a4:	mov    rax,r14
    10a7:	add    rax,0x1
    10ae:	mov    rcx,r13
    10b1:	jmp    fdf <botlish_fn_15+0x31>

00000000000010b6 <botlish_entry_15: scan_while<int, native(is_tcl_alpha)>>:
    10b6:	push   rbp
    10b7:	mov    rbp,rsp
    10ba:	mov    rsi,QWORD PTR [rdx]
    10bd:	mov    rax,QWORD PTR [rdx+0x8]
    10c1:	mov    rcx,QWORD PTR [rdx+0x10]
    10c5:	mov    r8,QWORD PTR [rdx+0x18]
    10c9:	sar    rsi,1
    10cc:	mov    rdx,rax
    10cf:	call   10d4 <botlish_entry_15+0x1e>
			10d0: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<int, native(is_tcl_alpha)>
    10d4:	shl    rax,1
    10d7:	or     rax,0x1
    10db:	mov    rcx,rax
    10de:	xor    rax,rax
    10e1:	test   rdx,rdx
    10e4:	cmovne rax,rcx
    10e8:	mov    rsp,rbp
    10eb:	pop    rbp
    10ec:	ret
    10ed:	add    BYTE PTR [rax],al
	...

00000000000010f0 <botlish_fn_16: tld?<int>>:
    10f0:	push   rbp
    10f1:	mov    rbp,rsp
    10f4:	sub    rsp,0x10
    10f8:	mov    QWORD PTR [rsp],rbx
    10fc:	mov    QWORD PTR [rsp+0x8],r12
    1101:	mov    r8,rdx
    1104:	mov    rax,QWORD PTR [rdi+0x10]
    1108:	mov    rdx,QWORD PTR [rax+0xd8]
    110f:	mov    r12,r8
    1112:	mov    r8,rcx
    1115:	mov    rbx,rsi
    1118:	mov    rcx,r12
    111b:	call   1120 <botlish_fn_16+0x30>
			111c: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<int, native(is_tcl_alpha)>
    1120:	test   rdx,rdx
    1123:	jne    113e <botlish_fn_16+0x4e>
    1129:	xor    rax,rax
    112c:	mov    rbx,QWORD PTR [rsp]
    1130:	mov    r12,QWORD PTR [rsp+0x8]
    1135:	add    rsp,0x10
    1139:	mov    rsp,rbp
    113c:	pop    rbp
    113d:	ret
    113e:	sar    r12,1
    1141:	cmp    rax,r12
    1144:	je     1154 <botlish_fn_16+0x64>
    114a:	mov    eax,0x2
    114f:	jmp    116b <botlish_fn_16+0x7b>
    1154:	sub    rax,rbx
    1157:	mov    rcx,rax
    115a:	mov    eax,0x2
    115f:	cmp    rcx,0x2
    1163:	cmovge rax,QWORD PTR [rip+0x15]        # 1180 <botlish_fn_16+0x90>
    116b:	mov    rbx,QWORD PTR [rsp]
    116f:	mov    r12,QWORD PTR [rsp+0x8]
    1174:	add    rsp,0x10
    1178:	mov    rsp,rbp
    117b:	pop    rbp
    117c:	ret
    117d:	add    BYTE PTR [rax],al
    117f:	add    BYTE PTR [rsi],al
    1181:	add    BYTE PTR [rax],al
    1183:	add    BYTE PTR [rax],al
    1185:	add    BYTE PTR [rax],al
	...

0000000000001188 <botlish_entry_16: tld?<int>>:
    1188:	push   rbp
    1189:	mov    rbp,rsp
    118c:	mov    rsi,QWORD PTR [rdx]
    118f:	mov    r8,QWORD PTR [rdx+0x8]
    1193:	mov    rcx,QWORD PTR [rdx+0x10]
    1197:	sar    rsi,1
    119a:	mov    rdx,r8
    119d:	call   11a2 <botlish_entry_16+0x1a>
			119e: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<int>
    11a2:	mov    rsp,rbp
    11a5:	pop    rbp
    11a6:	ret

00000000000011a7 <botlish_fn_17: domain?<int>>:
    11a7:	push   rbp
    11a8:	mov    rbp,rsp
    11ab:	sub    rsp,0x80
    11b2:	mov    QWORD PTR [rsp+0x50],rbx
    11b7:	mov    QWORD PTR [rsp+0x58],r12
    11bc:	mov    QWORD PTR [rsp+0x60],r13
    11c1:	mov    QWORD PTR [rsp+0x68],r14
    11c6:	mov    QWORD PTR [rsp+0x70],r15
    11cb:	mov    rbx,rsi
    11ce:	mov    r15,rcx
    11d1:	mov    r14,rdx
    11d4:	sar    r14,1
    11d7:	mov    QWORD PTR [rsp+0x30],rdx
    11dc:	mov    r12,rbx
    11df:	cmp    r12,r14
    11e2:	jl     1212 <botlish_fn_17+0x6b>
    11e8:	mov    eax,0x2
    11ed:	mov    rbx,QWORD PTR [rsp+0x50]
    11f2:	mov    r12,QWORD PTR [rsp+0x58]
    11f7:	mov    r13,QWORD PTR [rsp+0x60]
    11fc:	mov    r14,QWORD PTR [rsp+0x68]
    1201:	mov    r15,QWORD PTR [rsp+0x70]
    1206:	add    rsp,0x80
    120d:	mov    rsp,rbp
    1210:	pop    rbp
    1211:	ret
    1212:	mov    rsi,r12
    1215:	shl    rsi,1
    1218:	or     rsi,0x1
    121c:	mov    QWORD PTR [rsp+0x48],rsi
    1221:	lea    rcx,[rsp]
    1225:	mov    r13,rdi
    1228:	mov    rdx,r15
    122b:	call   1230 <botlish_fn_17+0x89>
			122c: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    1230:	test   rax,rax
    1233:	mov    rsi,rax
    1236:	je     13b8 <botlish_fn_17+0x211>
    123c:	mov    rdx,QWORD PTR [rsp]
    1240:	mov    rcx,QWORD PTR [rsp+0x8]
    1245:	mov    rax,QWORD PTR [r13+0x10]
    1249:	mov    r8,QWORD PTR [rax]
    124c:	mov    rdi,r13
    124f:	call   1254 <botlish_fn_17+0xad>
			1250: R_X86_64_PLT32	rt_str_region_eq-0x4
    1254:	cmp    rax,0x6
    1258:	je     1344 <botlish_fn_17+0x19d>
    125e:	lea    rcx,[rsp+0x20]
    1263:	mov    rsi,QWORD PTR [rsp+0x48]
    1268:	mov    rdx,r15
    126b:	mov    rdi,r13
    126e:	call   1273 <botlish_fn_17+0xcc>
			126f: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    1273:	test   rax,rax
    1276:	mov    QWORD PTR [rsp+0x48],rax
    127b:	je     13b8 <botlish_fn_17+0x211>
    1281:	mov    rdx,QWORD PTR [rsp+0x20]
    1286:	mov    QWORD PTR [rsp+0x40],rdx
    128b:	mov    rcx,QWORD PTR [rsp+0x28]
    1290:	mov    QWORD PTR [rsp+0x38],rcx
    1295:	mov    rsi,QWORD PTR [rsp+0x48]
    129a:	mov    rdi,r13
    129d:	call   12a2 <botlish_fn_17+0xfb>
			129e: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    12a2:	test   rax,rax
    12a5:	je     13b8 <botlish_fn_17+0x211>
    12ab:	cmp    rax,0x6
    12af:	je     12f2 <botlish_fn_17+0x14b>
    12b5:	mov    rdi,QWORD PTR [r13+0x10]
    12b9:	mov    r8,QWORD PTR [rdi+0x20]
    12bd:	mov    rcx,QWORD PTR [rsp+0x38]
    12c2:	mov    rdx,QWORD PTR [rsp+0x40]
    12c7:	mov    rsi,QWORD PTR [rsp+0x48]
    12cc:	mov    rdi,r13
    12cf:	call   12d4 <botlish_fn_17+0x12d>
			12d0: R_X86_64_PLT32	rt_str_region_eq-0x4
    12d4:	cmp    rax,0x6
    12d8:	je     12e8 <botlish_fn_17+0x141>
    12de:	mov    ecx,0x2
    12e3:	jmp    12f7 <botlish_fn_17+0x150>
    12e8:	mov    ecx,0x6
    12ed:	jmp    12f7 <botlish_fn_17+0x150>
    12f2:	mov    ecx,0x6
    12f7:	cmp    rcx,0x6
    12fb:	je     130b <botlish_fn_17+0x164>
    1301:	mov    eax,0x6
    1306:	jmp    1310 <botlish_fn_17+0x169>
    130b:	mov    eax,0x2
    1310:	cmp    rax,0x6
    1314:	jne    13ea <botlish_fn_17+0x243>
    131a:	mov    eax,0x2
    131f:	mov    rbx,QWORD PTR [rsp+0x50]
    1324:	mov    r12,QWORD PTR [rsp+0x58]
    1329:	mov    r13,QWORD PTR [rsp+0x60]
    132e:	mov    r14,QWORD PTR [rsp+0x68]
    1333:	mov    r15,QWORD PTR [rsp+0x70]
    1338:	add    rsp,0x80
    133f:	mov    rsp,rbp
    1342:	pop    rbp
    1343:	ret
    1344:	cmp    r12,rbx
    1347:	je     144d <botlish_fn_17+0x2a6>
    134d:	mov    rsi,r12
    1350:	sub    rsi,0x1
    1354:	shl    rsi,1
    1357:	or     rsi,0x1
    135b:	lea    rcx,[rsp+0x10]
    1360:	mov    rdx,r15
    1363:	mov    rdi,r13
    1366:	call   136b <botlish_fn_17+0x1c4>
			1367: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    136b:	test   rax,rax
    136e:	mov    rsi,rax
    1371:	je     13b8 <botlish_fn_17+0x211>
    1377:	mov    rdx,QWORD PTR [rsp+0x10]
    137c:	mov    rcx,QWORD PTR [rsp+0x18]
    1381:	mov    rax,QWORD PTR [r13+0x10]
    1385:	mov    r8,QWORD PTR [rax]
    1388:	mov    rdi,r13
    138b:	call   1390 <botlish_fn_17+0x1e9>
			138c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1390:	cmp    rax,0x6
    1394:	je     1423 <botlish_fn_17+0x27c>
    139a:	lea    rsi,[r12+0x1]
    139f:	mov    rcx,r15
    13a2:	mov    rdx,QWORD PTR [rsp+0x30]
    13a7:	mov    rdi,r13
    13aa:	call   13af <botlish_fn_17+0x208>
			13ab: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<int>
    13af:	test   rax,rax
    13b2:	jne    13e0 <botlish_fn_17+0x239>
    13b8:	xor    rax,rax
    13bb:	mov    rbx,QWORD PTR [rsp+0x50]
    13c0:	mov    r12,QWORD PTR [rsp+0x58]
    13c5:	mov    r13,QWORD PTR [rsp+0x60]
    13ca:	mov    r14,QWORD PTR [rsp+0x68]
    13cf:	mov    r15,QWORD PTR [rsp+0x70]
    13d4:	add    rsp,0x80
    13db:	mov    rsp,rbp
    13de:	pop    rbp
    13df:	ret
    13e0:	cmp    rax,0x6
    13e4:	je     13f9 <botlish_fn_17+0x252>
    13ea:	add    r12,0x1
    13f1:	mov    rdi,r13
    13f4:	jmp    11df <botlish_fn_17+0x38>
    13f9:	mov    eax,0x6
    13fe:	mov    rbx,QWORD PTR [rsp+0x50]
    1403:	mov    r12,QWORD PTR [rsp+0x58]
    1408:	mov    r13,QWORD PTR [rsp+0x60]
    140d:	mov    r14,QWORD PTR [rsp+0x68]
    1412:	mov    r15,QWORD PTR [rsp+0x70]
    1417:	add    rsp,0x80
    141e:	mov    rsp,rbp
    1421:	pop    rbp
    1422:	ret
    1423:	mov    eax,0x2
    1428:	mov    rbx,QWORD PTR [rsp+0x50]
    142d:	mov    r12,QWORD PTR [rsp+0x58]
    1432:	mov    r13,QWORD PTR [rsp+0x60]
    1437:	mov    r14,QWORD PTR [rsp+0x68]
    143c:	mov    r15,QWORD PTR [rsp+0x70]
    1441:	add    rsp,0x80
    1448:	mov    rsp,rbp
    144b:	pop    rbp
    144c:	ret
    144d:	mov    eax,0x2
    1452:	mov    rbx,QWORD PTR [rsp+0x50]
    1457:	mov    r12,QWORD PTR [rsp+0x58]
    145c:	mov    r13,QWORD PTR [rsp+0x60]
    1461:	mov    r14,QWORD PTR [rsp+0x68]
    1466:	mov    r15,QWORD PTR [rsp+0x70]
    146b:	add    rsp,0x80
    1472:	mov    rsp,rbp
    1475:	pop    rbp
    1476:	ret

0000000000001477 <botlish_entry_17: domain?<int>>:
    1477:	push   rbp
    1478:	mov    rbp,rsp
    147b:	mov    rsi,QWORD PTR [rdx]
    147e:	mov    r8,QWORD PTR [rdx+0x8]
    1482:	mov    rcx,QWORD PTR [rdx+0x10]
    1486:	sar    rsi,1
    1489:	mov    rdx,r8
    148c:	call   1491 <botlish_entry_17+0x1a>
			148d: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<int>
    1491:	mov    rsp,rbp
    1494:	pop    rbp
    1495:	ret

0000000000001496 <botlish_fn_18: web::is_unreserved<int>>:
    1496:	push   rbp
    1497:	mov    rbp,rsp
    149a:	sub    rsp,0x10
    149e:	mov    QWORD PTR [rsp],rbx
    14a2:	mov    QWORD PTR [rsp+0x8],r14
    14a7:	mov    r14,rsi
    14aa:	mov    rsi,r14
    14ad:	sar    rsi,1
    14b0:	mov    rbx,rdi
    14b3:	call   14b8 <botlish_fn_18+0x22>
			14b4: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
    14b8:	cmp    rax,0x6
    14bc:	je     14f3 <botlish_fn_18+0x5d>
    14c2:	mov    rax,QWORD PTR [rbx+0x30]
    14c6:	mov    rsi,QWORD PTR [rax+0x10]
    14ca:	mov    rdx,r14
    14cd:	mov    rdi,rbx
    14d0:	call   14d5 <botlish_fn_18+0x3f>
			14d1: R_X86_64_PLT32	rt_set_contains-0x4
    14d5:	cmp    rax,0x6
    14d9:	je     14e9 <botlish_fn_18+0x53>
    14df:	mov    eax,0x2
    14e4:	jmp    14f8 <botlish_fn_18+0x62>
    14e9:	mov    eax,0x6
    14ee:	jmp    14f8 <botlish_fn_18+0x62>
    14f3:	mov    eax,0x6
    14f8:	mov    rbx,QWORD PTR [rsp]
    14fc:	mov    r14,QWORD PTR [rsp+0x8]
    1501:	add    rsp,0x10
    1505:	mov    rsp,rbp
    1508:	pop    rbp
    1509:	ret

000000000000150a <botlish_entry_18: web::is_unreserved<int>>:
    150a:	push   rbp
    150b:	mov    rbp,rsp
    150e:	mov    rsi,QWORD PTR [rdx]
    1511:	call   1516 <botlish_entry_18+0xc>
			1512: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1516:	mov    rsp,rbp
    1519:	pop    rbp
    151a:	ret

000000000000151b <botlish_fn_19: web::uri_escape_text<str>>:
    151b:	push   rbp
    151c:	mov    rbp,rsp
    151f:	sub    rsp,0x10
    1523:	mov    edx,0x1
    1528:	mov    QWORD PTR [rsp],0x1
    1530:	mov    r10,QWORD PTR [rdi+0x10]
    1534:	mov    rcx,QWORD PTR [r10+0xe0]
    153b:	mov    QWORD PTR [rsp+0x8],rcx
    1540:	call   1545 <botlish_fn_19+0x2a>
			1541: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    1545:	test   rax,rax
    1548:	jne    155a <botlish_fn_19+0x3f>
    154e:	xor    rax,rax
    1551:	add    rsp,0x10
    1555:	mov    rsp,rbp
    1558:	pop    rbp
    1559:	ret
    155a:	add    rsp,0x10
    155e:	mov    rsp,rbp
    1561:	pop    rbp
    1562:	ret

0000000000001563 <botlish_entry_19: web::uri_escape_text<str>>:
    1563:	push   rbp
    1564:	mov    rbp,rsp
    1567:	sub    rsp,0x10
    156b:	mov    QWORD PTR [rsp],r12
    156f:	mov    r12,rdi
    1572:	mov    rsi,QWORD PTR [rdx]
    1575:	mov    r8,QWORD PTR [rip+0x0]        # 157c <botlish_entry_19+0x19>
			1578: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    157c:	call   r8
    157f:	mov    rsi,rax
    1582:	mov    rdi,r12
    1585:	call   158a <botlish_entry_19+0x27>
			1586: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_escape_text<str>
    158a:	mov    r12,QWORD PTR [rsp]
    158e:	add    rsp,0x10
    1592:	mov    rsp,rbp
    1595:	pop    rbp
    1596:	ret

0000000000001597 <botlish_fn_20: high_nibble<int>>:
    1597:	push   rbp
    1598:	mov    rbp,rsp
    159b:	sub    rsp,0x10
    159f:	mov    QWORD PTR [rsp],rsi
    15a3:	mov    QWORD PTR [rsp+0x8],0x1e1
    15ac:	test   rsi,0x1
    15b3:	jne    15c8 <botlish_fn_20+0x31>
    15b9:	mov    edx,0x1e1
    15be:	call   15c3 <botlish_fn_20+0x2c>
			15bf: R_X86_64_PLT32	rt_int_and-0x4
    15c3:	jmp    15d2 <botlish_fn_20+0x3b>
    15c8:	and    rsi,0x1e1
    15cf:	mov    rax,rsi
    15d2:	sar    rax,0x5
    15d6:	shl    rax,1
    15d9:	or     rax,0x1
    15dd:	add    rsp,0x10
    15e1:	mov    rsp,rbp
    15e4:	pop    rbp
    15e5:	ret

00000000000015e6 <botlish_entry_20: high_nibble<int>>:
    15e6:	push   rbp
    15e7:	mov    rbp,rsp
    15ea:	mov    rsi,QWORD PTR [rdx]
    15ed:	call   15f2 <botlish_entry_20+0xc>
			15ee: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    15f2:	mov    rsp,rbp
    15f5:	pop    rbp
    15f6:	ret

00000000000015f7 <botlish_fn_21: hex_pair<int>>:
    15f7:	push   rbp
    15f8:	mov    rbp,rsp
    15fb:	sub    rsp,0x50
    15ff:	mov    QWORD PTR [rsp+0x30],rbx
    1604:	mov    QWORD PTR [rsp+0x38],r12
    1609:	mov    QWORD PTR [rsp+0x40],r13
    160e:	mov    QWORD PTR [rsp+0x48],r14
    1613:	mov    QWORD PTR [rsp],rsi
    1617:	mov    r12,rsi
    161a:	mov    rax,QWORD PTR [rdi+0x30]
    161e:	mov    rbx,rdi
    1621:	mov    rsi,QWORD PTR [rax+0x8]
    1625:	mov    QWORD PTR [rsp+0x8],rsi
    162a:	mov    r13,rsi
    162d:	mov    rsi,r12
    1630:	call   1635 <botlish_fn_21+0x3e>
			1631: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    1635:	test   rax,0x1
    163b:	jne    164c <botlish_fn_21+0x55>
    1641:	mov    rdx,rax
    1644:	mov    rsi,r13
    1647:	jmp    1665 <botlish_fn_21+0x6e>
    164c:	mov    rsi,r13
    164f:	mov    rdx,QWORD PTR [rsi+0x8]
    1653:	mov    rcx,rax
    1656:	sar    rcx,1
    1659:	cmp    rcx,rdx
    165c:	jb     167b <botlish_fn_21+0x84>
    1662:	mov    rdx,rax
    1665:	mov    rdi,rbx
    1668:	call   166d <botlish_fn_21+0x76>
			1669: R_X86_64_PLT32	rt_list_get-0x4
    166d:	test   rax,rax
    1670:	je     1740 <botlish_fn_21+0x149>
    1676:	jmp    1683 <botlish_fn_21+0x8c>
    167b:	mov    rax,QWORD PTR [rsi+0x10]
    167f:	mov    rax,QWORD PTR [rax+rcx*8]
    1683:	mov    QWORD PTR [rsp],rax
    1687:	mov    rdi,rbx
    168a:	mov    r14,rax
    168d:	mov    rax,QWORD PTR [rdi+0x30]
    1691:	mov    rsi,QWORD PTR [rax+0x8]
    1695:	mov    r13,rsi
    1698:	mov    edx,0x21
    169d:	mov    rsi,r12
    16a0:	call   16a5 <botlish_fn_21+0xae>
			16a1: R_X86_64_PLT32	rt_int_mod-0x4
    16a5:	test   rax,rax
    16a8:	je     1740 <botlish_fn_21+0x149>
    16ae:	test   rax,0x1
    16b4:	jne    16c5 <botlish_fn_21+0xce>
    16ba:	mov    rdx,rax
    16bd:	mov    rsi,r13
    16c0:	jmp    16de <botlish_fn_21+0xe7>
    16c5:	mov    rsi,r13
    16c8:	mov    rdx,QWORD PTR [rsi+0x8]
    16cc:	mov    rcx,rax
    16cf:	sar    rcx,1
    16d2:	cmp    rcx,rdx
    16d5:	jb     16f4 <botlish_fn_21+0xfd>
    16db:	mov    rdx,rax
    16de:	mov    rdi,rbx
    16e1:	call   16e6 <botlish_fn_21+0xef>
			16e2: R_X86_64_PLT32	rt_list_get-0x4
    16e6:	test   rax,rax
    16e9:	je     1740 <botlish_fn_21+0x149>
    16ef:	jmp    16fc <botlish_fn_21+0x105>
    16f4:	mov    rax,QWORD PTR [rsi+0x10]
    16f8:	mov    rax,QWORD PTR [rax+rcx*8]
    16fc:	mov    QWORD PTR [rsp+0x8],rax
    1701:	lea    rcx,[rsp+0x10]
    1706:	mov    QWORD PTR [rsp+0x10],0x0
    170f:	mov    rdx,r14
    1712:	mov    QWORD PTR [rsp+0x18],rdx
    1717:	mov    QWORD PTR [rsp+0x20],0x0
    1720:	mov    QWORD PTR [rsp+0x28],rax
    1725:	mov    esi,0x2
    172a:	mov    edx,0x4
    172f:	mov    rdi,rbx
    1732:	call   1737 <botlish_fn_21+0x140>
			1733: R_X86_64_PLT32	rt_construct-0x4
    1737:	test   rax,rax
    173a:	jne    1760 <botlish_fn_21+0x169>
    1740:	xor    rax,rax
    1743:	mov    rbx,QWORD PTR [rsp+0x30]
    1748:	mov    r12,QWORD PTR [rsp+0x38]
    174d:	mov    r13,QWORD PTR [rsp+0x40]
    1752:	mov    r14,QWORD PTR [rsp+0x48]
    1757:	add    rsp,0x50
    175b:	mov    rsp,rbp
    175e:	pop    rbp
    175f:	ret
    1760:	mov    rbx,QWORD PTR [rsp+0x30]
    1765:	mov    r12,QWORD PTR [rsp+0x38]
    176a:	mov    r13,QWORD PTR [rsp+0x40]
    176f:	mov    r14,QWORD PTR [rsp+0x48]
    1774:	add    rsp,0x50
    1778:	mov    rsp,rbp
    177b:	pop    rbp
    177c:	ret

000000000000177d <botlish_entry_21: hex_pair<int>>:
    177d:	push   rbp
    177e:	mov    rbp,rsp
    1781:	sub    rsp,0x10
    1785:	mov    QWORD PTR [rsp],r12
    1789:	mov    r12,rdi
    178c:	mov    rsi,QWORD PTR [rdx]
    178f:	call   1794 <botlish_entry_21+0x17>
			1790: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1794:	mov    r8,QWORD PTR [rip+0x0]        # 179b <botlish_entry_21+0x1e>
			1797: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    179b:	mov    rsi,rax
    179e:	mov    rdi,r12
    17a1:	call   r8
    17a4:	mov    r12,QWORD PTR [rsp]
    17a8:	add    rsp,0x10
    17ac:	mov    rsp,rbp
    17af:	pop    rbp
    17b0:	ret

00000000000017b1 <botlish_fn_22: esc_bytes<List[int], int, str>>:
    17b1:	push   rbp
    17b2:	mov    rbp,rsp
    17b5:	sub    rsp,0x90
    17bc:	mov    QWORD PTR [rsp+0x60],rbx
    17c1:	mov    QWORD PTR [rsp+0x68],r12
    17c6:	mov    QWORD PTR [rsp+0x70],r13
    17cb:	mov    QWORD PTR [rsp+0x78],r14
    17d0:	mov    QWORD PTR [rsp+0x80],r15
    17d8:	mov    QWORD PTR [rsp],rsi
    17dc:	mov    QWORD PTR [rsp+0x8],rcx
    17e1:	sar    rdx,1
    17e4:	mov    r13,rdx
    17e7:	lea    r14,[rsp+0x20]
    17ec:	mov    rbx,rdi
    17ef:	mov    r12,rsi
    17f2:	mov    QWORD PTR [rsp+0x50],rcx
    17f7:	mov    rsi,r12
    17fa:	mov    rdi,rbx
    17fd:	call   1802 <botlish_fn_22+0x51>
			17fe: R_X86_64_PLT32	rt_list_len-0x4
    1802:	sar    rax,1
    1805:	cmp    r13,rax
    1808:	jge    1918 <botlish_fn_22+0x167>
    180e:	mov    rax,QWORD PTR [rbx+0x10]
    1812:	mov    r15,QWORD PTR [rax+0x10]
    1816:	mov    QWORD PTR [rsp+0x10],r15
    181b:	mov    rcx,QWORD PTR [r12+0x8]
    1820:	mov    rax,r13
    1823:	shl    rax,1
    1826:	or     rax,0x1
    182a:	sar    rax,1
    182d:	cmp    rax,rcx
    1830:	jb     185c <botlish_fn_22+0xab>
    1836:	mov    rdx,r13
    1839:	shl    rdx,1
    183c:	or     rdx,0x1
    1840:	mov    rsi,r12
    1843:	mov    rdi,rbx
    1846:	call   184b <botlish_fn_22+0x9a>
			1847: R_X86_64_PLT32	rt_list_get-0x4
    184b:	test   rax,rax
    184e:	je     18d3 <botlish_fn_22+0x122>
    1854:	mov    rsi,rax
    1857:	jmp    1865 <botlish_fn_22+0xb4>
    185c:	mov    rcx,QWORD PTR [r12+0x10]
    1861:	mov    rsi,QWORD PTR [rcx+rax*8]
    1865:	mov    QWORD PTR [rsp+0x18],rsi
    186a:	mov    rdi,rbx
    186d:	call   1872 <botlish_fn_22+0xc1>
			186e: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1872:	test   rax,rax
    1875:	je     18d3 <botlish_fn_22+0x122>
    187b:	mov    QWORD PTR [rsp+0x18],rax
    1880:	mov    rcx,rax
    1883:	mov    QWORD PTR [rsp+0x20],0x0
    188c:	mov    rax,QWORD PTR [rsp+0x50]
    1891:	mov    QWORD PTR [rsp+0x28],rax
    1896:	mov    QWORD PTR [rsp+0x30],0x0
    189f:	mov    QWORD PTR [rsp+0x38],r15
    18a4:	mov    QWORD PTR [rsp+0x40],0x0
    18ad:	mov    rax,rcx
    18b0:	mov    QWORD PTR [rsp+0x48],rax
    18b5:	mov    esi,0x2
    18ba:	mov    edx,0x6
    18bf:	mov    rcx,r14
    18c2:	mov    rdi,rbx
    18c5:	call   18ca <botlish_fn_22+0x119>
			18c6: R_X86_64_PLT32	rt_construct-0x4
    18ca:	test   rax,rax
    18cd:	jne    18fe <botlish_fn_22+0x14d>
    18d3:	xor    rax,rax
    18d6:	mov    rbx,QWORD PTR [rsp+0x60]
    18db:	mov    r12,QWORD PTR [rsp+0x68]
    18e0:	mov    r13,QWORD PTR [rsp+0x70]
    18e5:	mov    r14,QWORD PTR [rsp+0x78]
    18ea:	mov    r15,QWORD PTR [rsp+0x80]
    18f2:	add    rsp,0x90
    18f9:	mov    rsp,rbp
    18fc:	pop    rbp
    18fd:	ret
    18fe:	mov    QWORD PTR [rsp],r12
    1902:	mov    QWORD PTR [rsp+0x8],rax
    1907:	add    r13,0x1
    190e:	mov    QWORD PTR [rsp+0x50],rax
    1913:	jmp    17f7 <botlish_fn_22+0x46>
    1918:	mov    rax,QWORD PTR [rsp+0x50]
    191d:	mov    rbx,QWORD PTR [rsp+0x60]
    1922:	mov    r12,QWORD PTR [rsp+0x68]
    1927:	mov    r13,QWORD PTR [rsp+0x70]
    192c:	mov    r14,QWORD PTR [rsp+0x78]
    1931:	mov    r15,QWORD PTR [rsp+0x80]
    1939:	add    rsp,0x90
    1940:	mov    rsp,rbp
    1943:	pop    rbp
    1944:	ret

0000000000001945 <botlish_entry_22: esc_bytes<List[int], int, str>>:
    1945:	push   rbp
    1946:	mov    rbp,rsp
    1949:	sub    rsp,0x10
    194d:	mov    QWORD PTR [rsp],r12
    1951:	mov    r12,rdi
    1954:	mov    rsi,QWORD PTR [rdx]
    1957:	mov    r8,QWORD PTR [rdx+0x8]
    195b:	mov    rcx,QWORD PTR [rdx+0x10]
    195f:	mov    rdx,r8
    1962:	call   1967 <botlish_entry_22+0x22>
			1963: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1967:	mov    r8,QWORD PTR [rip+0x0]        # 196e <botlish_entry_22+0x29>
			196a: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    196e:	mov    rsi,rax
    1971:	mov    rdi,r12
    1974:	call   r8
    1977:	mov    r12,QWORD PTR [rsp]
    197b:	add    rsp,0x10
    197f:	mov    rsp,rbp
    1982:	pop    rbp
    1983:	ret

0000000000001984 <botlish_fn_23: esc_char<str>>:
    1984:	push   rbp
    1985:	mov    rbp,rsp
    1988:	sub    rsp,0x40
    198c:	mov    QWORD PTR [rsp+0x20],rbx
    1991:	mov    QWORD PTR [rsp+0x28],r12
    1996:	mov    QWORD PTR [rsp+0x30],r13
    199b:	mov    rbx,rdi
    199e:	mov    QWORD PTR [rsp+0x8],0x0
    19a7:	mov    QWORD PTR [rsp+0x10],0x0
    19b0:	mov    QWORD PTR [rsp],rsi
    19b4:	mov    r13,rsi
    19b7:	mov    rsi,r13
    19ba:	mov    rdi,rbx
    19bd:	call   19c2 <botlish_fn_23+0x3e>
			19be: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    19c2:	mov    rcx,rax
    19c5:	mov    r12,rax
    19c8:	test   rax,rcx
    19cb:	je     1aa9 <botlish_fn_23+0x125>
    19d1:	mov    rax,r12
    19d4:	mov    QWORD PTR [rsp],rax
    19d8:	mov    rsi,r12
    19db:	mov    rdi,rbx
    19de:	call   19e3 <botlish_fn_23+0x5f>
			19df: R_X86_64_PLT32	rt_list_len-0x4
    19e3:	sar    rax,1
    19e6:	cmp    rax,0x1
    19ea:	je     1a27 <botlish_fn_23+0xa3>
    19f0:	mov    edx,0x1
    19f5:	mov    QWORD PTR [rsp+0x8],0x1
    19fe:	mov    rdi,rbx
    1a01:	mov    rax,QWORD PTR [rdi+0x10]
    1a05:	mov    rcx,QWORD PTR [rax+0xe0]
    1a0c:	mov    QWORD PTR [rsp+0x10],rcx
    1a11:	mov    rsi,r12
    1a14:	call   1a19 <botlish_fn_23+0x95>
			1a15: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1a19:	test   rax,rax
    1a1c:	je     1aa9 <botlish_fn_23+0x125>
    1a22:	jmp    1aca <botlish_fn_23+0x146>
    1a27:	mov    rsi,r12
    1a2a:	mov    rax,QWORD PTR [rsi+0x8]
    1a2e:	mov    r12,rsi
    1a31:	test   rax,rax
    1a34:	jne    1a5b <botlish_fn_23+0xd7>
    1a3a:	mov    edx,0x1
    1a3f:	mov    rsi,r12
    1a42:	mov    rdi,rbx
    1a45:	call   1a4a <botlish_fn_23+0xc6>
			1a46: R_X86_64_PLT32	rt_list_get-0x4
    1a4a:	test   rax,rax
    1a4d:	je     1aa9 <botlish_fn_23+0x125>
    1a53:	mov    rsi,rax
    1a56:	jmp    1a65 <botlish_fn_23+0xe1>
    1a5b:	mov    rsi,r12
    1a5e:	mov    rax,QWORD PTR [rsi+0x10]
    1a62:	mov    rsi,QWORD PTR [rax]
    1a65:	mov    rdi,rbx
    1a68:	call   1a6d <botlish_fn_23+0xe9>
			1a69: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1a6d:	cmp    rax,0x6
    1a71:	je     1ac7 <botlish_fn_23+0x143>
    1a77:	mov    edx,0x1
    1a7c:	mov    QWORD PTR [rsp+0x8],0x1
    1a85:	mov    rdi,rbx
    1a88:	mov    rax,QWORD PTR [rdi+0x10]
    1a8c:	mov    rcx,QWORD PTR [rax+0xe0]
    1a93:	mov    QWORD PTR [rsp+0x10],rcx
    1a98:	mov    rsi,r12
    1a9b:	call   1aa0 <botlish_fn_23+0x11c>
			1a9c: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1aa0:	test   rax,rax
    1aa3:	jne    1ac4 <botlish_fn_23+0x140>
    1aa9:	xor    rax,rax
    1aac:	mov    rbx,QWORD PTR [rsp+0x20]
    1ab1:	mov    r12,QWORD PTR [rsp+0x28]
    1ab6:	mov    r13,QWORD PTR [rsp+0x30]
    1abb:	add    rsp,0x40
    1abf:	mov    rsp,rbp
    1ac2:	pop    rbp
    1ac3:	ret
    1ac4:	mov    r13,rax
    1ac7:	mov    rax,r13
    1aca:	mov    rbx,QWORD PTR [rsp+0x20]
    1acf:	mov    r12,QWORD PTR [rsp+0x28]
    1ad4:	mov    r13,QWORD PTR [rsp+0x30]
    1ad9:	add    rsp,0x40
    1add:	mov    rsp,rbp
    1ae0:	pop    rbp
    1ae1:	ret

0000000000001ae2 <botlish_entry_23: esc_char<str>>:
    1ae2:	push   rbp
    1ae3:	mov    rbp,rsp
    1ae6:	sub    rsp,0x10
    1aea:	mov    QWORD PTR [rsp],r12
    1aee:	mov    r12,rdi
    1af1:	mov    rsi,QWORD PTR [rdx]
    1af4:	call   1af9 <botlish_entry_23+0x17>
			1af5: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1af9:	mov    r8,QWORD PTR [rip+0x0]        # 1b00 <botlish_entry_23+0x1e>
			1afc: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1b00:	mov    rsi,rax
    1b03:	mov    rdi,r12
    1b06:	call   r8
    1b09:	mov    r12,QWORD PTR [rsp]
    1b0d:	add    rsp,0x10
    1b11:	mov    rsp,rbp
    1b14:	pop    rbp
    1b15:	ret

0000000000001b16 <botlish_fn_24: esc_from<str, int, str>>:
    1b16:	push   rbp
    1b17:	mov    rbp,rsp
    1b1a:	sub    rsp,0x90
    1b21:	mov    QWORD PTR [rsp+0x60],rbx
    1b26:	mov    QWORD PTR [rsp+0x68],r12
    1b2b:	mov    QWORD PTR [rsp+0x70],r13
    1b30:	mov    QWORD PTR [rsp+0x78],r14
    1b35:	mov    QWORD PTR [rsp+0x80],r15
    1b3d:	mov    r14,rdi
    1b40:	mov    QWORD PTR [rsp+0x8],0x0
    1b49:	mov    QWORD PTR [rsp+0x10],0x0
    1b52:	mov    QWORD PTR [rsp+0x18],0x0
    1b5b:	mov    QWORD PTR [rsp],rcx
    1b5f:	mov    QWORD PTR [rsp+0x50],rcx
    1b64:	sar    rdx,1
    1b67:	mov    r13d,0x47
    1b6d:	mov    rcx,0xffffffffffffffff
    1b74:	bsr    rax,rsi
    1b78:	mov    r15,rsi
    1b7b:	cmove  rax,rcx
    1b7f:	mov    ecx,0x3f
    1b84:	sub    rcx,rax
    1b87:	sub    r13,rcx
    1b8a:	shr    r13,0x3
    1b8e:	lea    rbx,[rsp+0x30]
    1b93:	mov    r12,rdx
    1b96:	cmp    r12,r13
    1b99:	jge    1c53 <botlish_fn_24+0x13d>
    1b9f:	mov    rsi,r15
    1ba2:	mov    rdi,r14
    1ba5:	call   1baa <botlish_fn_24+0x94>
			1ba6: R_X86_64_PLT32	rt_ascii_to_str-0x4
    1baa:	mov    QWORD PTR [rsp+0x8],rax
    1baf:	mov    rdx,r12
    1bb2:	shl    rdx,1
    1bb5:	or     rdx,0x1
    1bb9:	mov    QWORD PTR [rsp+0x10],rdx
    1bbe:	add    r12,0x1
    1bc5:	mov    rcx,r12
    1bc8:	shl    rcx,1
    1bcb:	or     rcx,0x1
    1bcf:	mov    QWORD PTR [rsp+0x18],rcx
    1bd4:	mov    rsi,rax
    1bd7:	mov    rdi,r14
    1bda:	call   1bdf <botlish_fn_24+0xc9>
			1bdb: R_X86_64_PLT32	rt_substr-0x4
    1bdf:	test   rax,rax
    1be2:	je     1c87 <botlish_fn_24+0x171>
    1be8:	mov    QWORD PTR [rsp+0x8],rax
    1bed:	mov    rsi,rax
    1bf0:	mov    rdi,r14
    1bf3:	call   1bf8 <botlish_fn_24+0xe2>
			1bf4: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1bf8:	test   rax,rax
    1bfb:	je     1c87 <botlish_fn_24+0x171>
    1c01:	mov    QWORD PTR [rsp+0x8],rax
    1c06:	mov    QWORD PTR [rsp+0x30],0x0
    1c0f:	mov    rcx,QWORD PTR [rsp+0x50]
    1c14:	mov    QWORD PTR [rsp+0x38],rcx
    1c19:	mov    QWORD PTR [rsp+0x40],0x0
    1c22:	mov    QWORD PTR [rsp+0x48],rax
    1c27:	mov    esi,0x2
    1c2c:	mov    edx,0x4
    1c31:	mov    rcx,rbx
    1c34:	mov    rdi,r14
    1c37:	call   1c3c <botlish_fn_24+0x126>
			1c38: R_X86_64_PLT32	rt_construct-0x4
    1c3c:	test   rax,rax
    1c3f:	je     1c87 <botlish_fn_24+0x171>
    1c45:	mov    QWORD PTR [rsp],rax
    1c49:	mov    QWORD PTR [rsp+0x50],rax
    1c4e:	jmp    1b96 <botlish_fn_24+0x80>
    1c53:	mov    rcx,QWORD PTR [rsp+0x50]
    1c58:	xor    rsi,rsi
    1c5b:	lea    rax,[rsp+0x20]
    1c60:	mov    QWORD PTR [rsp+0x20],0x0
    1c69:	mov    QWORD PTR [rsp+0x28],rcx
    1c6e:	mov    edx,0x2
    1c73:	mov    rcx,rax
    1c76:	mov    rdi,r14
    1c79:	call   1c7e <botlish_fn_24+0x168>
			1c7a: R_X86_64_PLT32	rt_construct-0x4
    1c7e:	test   rax,rax
    1c81:	jne    1cb2 <botlish_fn_24+0x19c>
    1c87:	xor    rax,rax
    1c8a:	mov    rbx,QWORD PTR [rsp+0x60]
    1c8f:	mov    r12,QWORD PTR [rsp+0x68]
    1c94:	mov    r13,QWORD PTR [rsp+0x70]
    1c99:	mov    r14,QWORD PTR [rsp+0x78]
    1c9e:	mov    r15,QWORD PTR [rsp+0x80]
    1ca6:	add    rsp,0x90
    1cad:	mov    rsp,rbp
    1cb0:	pop    rbp
    1cb1:	ret
    1cb2:	mov    rbx,QWORD PTR [rsp+0x60]
    1cb7:	mov    r12,QWORD PTR [rsp+0x68]
    1cbc:	mov    r13,QWORD PTR [rsp+0x70]
    1cc1:	mov    r14,QWORD PTR [rsp+0x78]
    1cc6:	mov    r15,QWORD PTR [rsp+0x80]
    1cce:	add    rsp,0x90
    1cd5:	mov    rsp,rbp
    1cd8:	pop    rbp
    1cd9:	ret

0000000000001cda <botlish_entry_24: esc_from<str, int, str>>:
    1cda:	push   rbp
    1cdb:	mov    rbp,rsp
    1cde:	sub    rsp,0x10
    1ce2:	mov    QWORD PTR [rsp],r12
    1ce6:	mov    QWORD PTR [rsp+0x8],r13
    1ceb:	mov    r12,rdi
    1cee:	mov    rsi,QWORD PTR [rdx]
    1cf1:	mov    r13,rdx
    1cf4:	mov    r8,QWORD PTR [rip+0x0]        # 1cfb <botlish_entry_24+0x21>
			1cf7: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    1cfb:	call   r8
    1cfe:	mov    rcx,r13
    1d01:	mov    rdx,QWORD PTR [rcx+0x8]
    1d05:	mov    rcx,QWORD PTR [rcx+0x10]
    1d09:	mov    rsi,rax
    1d0c:	mov    rdi,r12
    1d0f:	call   1d14 <botlish_entry_24+0x3a>
			1d10: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    1d14:	mov    r12,QWORD PTR [rsp]
    1d18:	mov    r13,QWORD PTR [rsp+0x8]
    1d1d:	add    rsp,0x10
    1d21:	mov    rsp,rbp
    1d24:	pop    rbp
    1d25:	ret

0000000000001d26 <botlish_fn_25: check<int, int, str, str>>:
    1d26:	push   rbp
    1d27:	mov    rbp,rsp
    1d2a:	sub    rsp,0x50
    1d2e:	mov    QWORD PTR [rsp+0x20],rbx
    1d33:	mov    QWORD PTR [rsp+0x28],r12
    1d38:	mov    QWORD PTR [rsp+0x30],r13
    1d3d:	mov    QWORD PTR [rsp+0x38],r14
    1d42:	mov    QWORD PTR [rsp+0x40],r15
    1d47:	mov    r14,rdi
    1d4a:	mov    QWORD PTR [rsp+0x18],0x0
    1d53:	mov    QWORD PTR [rsp],rdx
    1d57:	mov    QWORD PTR [rsp+0x8],rcx
    1d5c:	mov    QWORD PTR [rsp+0x10],r8
    1d61:	mov    r13,r8
    1d64:	mov    r12,rsi
    1d67:	mov    r15,rdx
    1d6a:	test   r12,r12
    1d6d:	jle    1e2f <botlish_fn_25+0x109>
    1d73:	mov    rbx,rcx
    1d76:	mov    rsi,rbx
    1d79:	mov    rdi,r14
    1d7c:	call   1d81 <botlish_fn_25+0x5b>
			1d7d: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
    1d81:	test   rax,rax
    1d84:	jne    1daf <botlish_fn_25+0x89>
    1d8a:	xor    rax,rax
    1d8d:	mov    rbx,QWORD PTR [rsp+0x20]
    1d92:	mov    r12,QWORD PTR [rsp+0x28]
    1d97:	mov    r13,QWORD PTR [rsp+0x30]
    1d9c:	mov    r14,QWORD PTR [rsp+0x38]
    1da1:	mov    r15,QWORD PTR [rsp+0x40]
    1da6:	add    rsp,0x50
    1daa:	mov    rsp,rbp
    1dad:	pop    rbp
    1dae:	ret
    1daf:	cmp    rax,0x6
    1db3:	je     1dcf <botlish_fn_25+0xa9>
    1db9:	mov    edx,0x1
    1dbe:	mov    QWORD PTR [rsp+0x18],0x1
    1dc7:	mov    rsi,r15
    1dca:	jmp    1de0 <botlish_fn_25+0xba>
    1dcf:	mov    edx,0x3
    1dd4:	mov    QWORD PTR [rsp+0x18],0x3
    1ddd:	mov    rsi,r15
    1de0:	mov    rax,rsi
    1de3:	and    rax,rdx
    1de6:	test   rax,0x1
    1dec:	je     1e07 <botlish_fn_25+0xe1>
    1df2:	lea    rcx,[rdx-0x1]
    1df6:	mov    rax,rsi
    1df9:	add    rax,rcx
    1dfc:	seto   cl
    1dff:	test   cl,cl
    1e01:	je     1e0f <botlish_fn_25+0xe9>
    1e07:	mov    rdi,r14
    1e0a:	call   1e0f <botlish_fn_25+0xe9>
			1e0b: R_X86_64_PLT32	rt_int_add-0x4
    1e0f:	mov    QWORD PTR [rsp],rax
    1e13:	mov    QWORD PTR [rsp+0x8],rbx
    1e18:	mov    r8,r13
    1e1b:	mov    QWORD PTR [rsp+0x10],r8
    1e20:	sub    r12,0x1
    1e24:	mov    rcx,rbx
    1e27:	mov    r15,rax
    1e2a:	jmp    1d6a <botlish_fn_25+0x44>
    1e2f:	mov    rax,r15
    1e32:	mov    rbx,QWORD PTR [rsp+0x20]
    1e37:	mov    r12,QWORD PTR [rsp+0x28]
    1e3c:	mov    r13,QWORD PTR [rsp+0x30]
    1e41:	mov    r14,QWORD PTR [rsp+0x38]
    1e46:	mov    r15,QWORD PTR [rsp+0x40]
    1e4b:	add    rsp,0x50
    1e4f:	mov    rsp,rbp
    1e52:	pop    rbp
    1e53:	ret

0000000000001e54 <botlish_entry_25: check<int, int, str, str>>:
    1e54:	push   rbp
    1e55:	mov    rbp,rsp
    1e58:	mov    rsi,QWORD PTR [rdx]
    1e5b:	mov    r9,QWORD PTR [rdx+0x8]
    1e5f:	mov    rcx,QWORD PTR [rdx+0x10]
    1e63:	mov    r8,QWORD PTR [rdx+0x18]
    1e67:	sar    rsi,1
    1e6a:	mov    rdx,r9
    1e6d:	call   1e72 <botlish_entry_25+0x1e>
			1e6e: R_X86_64_PLT32	botlish_fn_25-0x4 ; check<int, int, str, str>
    1e72:	mov    rsp,rbp
    1e75:	pop    rbp
    1e76:	ret

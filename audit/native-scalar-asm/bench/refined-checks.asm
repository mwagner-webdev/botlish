; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 8935  (per function: 1415 39 289 609 74 74 74 128 128 379 262 222 176 238 440 456 212 1076 140 127 103 474 491 426 539 344)
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
    12cc:	sub    rsp,0x30
    12d0:	mov    QWORD PTR [rsp+0x20],rbx
    12d5:	mov    QWORD PTR [rsp+0x28],r12
    12da:	mov    QWORD PTR [rsp],rsi
    12de:	mov    QWORD PTR [rsp+0x8],rdx
    12e3:	mov    r12,rdx
    12e6:	mov    QWORD PTR [rsp+0x10],rcx
    12eb:	mov    rax,QWORD PTR [rdi+0x10]
    12ef:	mov    rdx,QWORD PTR [rax+0xd8]
    12f6:	mov    QWORD PTR [rsp+0x18],rdx
    12fb:	mov    rbx,rsi
    12fe:	mov    r8,rcx
    1301:	mov    rcx,r12
    1304:	call   1309 <botlish_fn_16+0x41>
			1305: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<any, native(is_tcl_alpha)>
    1309:	test   rax,rax
    130c:	jne    1328 <botlish_fn_16+0x60>
    1312:	xor    rax,rax
    1315:	mov    rbx,QWORD PTR [rsp+0x20]
    131a:	mov    r12,QWORD PTR [rsp+0x28]
    131f:	add    rsp,0x30
    1323:	mov    rsp,rbp
    1326:	pop    rbp
    1327:	ret
    1328:	sar    rax,1
    132b:	mov    rdx,r12
    132e:	sar    rdx,1
    1331:	cmp    rax,rdx
    1334:	je     1344 <botlish_fn_16+0x7c>
    133a:	mov    eax,0x2
    133f:	jmp    135e <botlish_fn_16+0x96>
    1344:	sar    rbx,1
    1347:	sub    rax,rbx
    134a:	mov    rcx,rax
    134d:	mov    eax,0x2
    1352:	cmp    rcx,0x2
    1356:	cmovge rax,QWORD PTR [rip+0x1a]        # 1378 <botlish_fn_16+0xb0>
    135e:	mov    rbx,QWORD PTR [rsp+0x20]
    1363:	mov    r12,QWORD PTR [rsp+0x28]
    1368:	add    rsp,0x30
    136c:	mov    rsp,rbp
    136f:	pop    rbp
    1370:	ret
    1371:	add    BYTE PTR [rax],al
    1373:	add    BYTE PTR [rax],al
    1375:	add    BYTE PTR [rax],al
    1377:	add    BYTE PTR [rsi],al
    1379:	add    BYTE PTR [rax],al
    137b:	add    BYTE PTR [rax],al
    137d:	add    BYTE PTR [rax],al
	...

0000000000001380 <botlish_entry_16: tld?<generic>>:
    1380:	push   rbp
    1381:	mov    rbp,rsp
    1384:	mov    rsi,QWORD PTR [rdx]
    1387:	mov    r8,QWORD PTR [rdx+0x8]
    138b:	mov    rcx,QWORD PTR [rdx+0x10]
    138f:	mov    rdx,r8
    1392:	call   1397 <botlish_entry_16+0x17>
			1393: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<generic>
    1397:	mov    rsp,rbp
    139a:	pop    rbp
    139b:	ret
    139c:	add    BYTE PTR [rax],al
	...

00000000000013a0 <botlish_fn_17: domain?<generic>>:
    13a0:	push   rbp
    13a1:	mov    rbp,rsp
    13a4:	sub    rsp,0xa0
    13ab:	mov    QWORD PTR [rsp+0x70],rbx
    13b0:	mov    QWORD PTR [rsp+0x78],r12
    13b5:	mov    QWORD PTR [rsp+0x80],r13
    13bd:	mov    QWORD PTR [rsp+0x88],r14
    13c5:	mov    QWORD PTR [rsp+0x90],r15
    13cd:	mov    r8,rdi
    13d0:	mov    QWORD PTR [rsp+0x20],0x0
    13d9:	mov    QWORD PTR [rsp],rsi
    13dd:	mov    QWORD PTR [rsp+0x8],rdx
    13e2:	mov    QWORD PTR [rsp+0x10],rcx
    13e7:	mov    r15,rcx
    13ea:	mov    QWORD PTR [rsp+0x18],rsi
    13ef:	mov    r12,rsi
    13f2:	mov    r14,rdx
    13f5:	mov    rdi,rsi
    13f8:	and    rdi,r14
    13fb:	mov    QWORD PTR [rsp+0x58],rsi
    1400:	test   rdi,0x1
    1407:	jne    1435 <botlish_fn_17+0x95>
    140d:	mov    rbx,r8
    1410:	mov    rdx,r14
    1413:	mov    rsi,QWORD PTR [rsp+0x58]
    1418:	mov    rdi,rbx
    141b:	call   1420 <botlish_fn_17+0x80>
			141c: R_X86_64_PLT32	rt_int_cmp-0x4
    1420:	mov    ecx,0x2
    1425:	test   rax,rax
    1428:	cmovl  rcx,QWORD PTR [rip+0x358]        # 1788 <botlish_fn_17+0x3e8>
    1430:	jmp    144d <botlish_fn_17+0xad>
    1435:	mov    rbx,r8
    1438:	mov    ecx,0x2
    143d:	mov    rsi,QWORD PTR [rsp+0x58]
    1442:	cmp    rsi,r14
    1445:	cmovl  rcx,QWORD PTR [rip+0x33b]        # 1788 <botlish_fn_17+0x3e8>
    144d:	cmp    rcx,0x6
    1451:	je     148a <botlish_fn_17+0xea>
    1457:	mov    eax,0x2
    145c:	mov    rbx,QWORD PTR [rsp+0x70]
    1461:	mov    r12,QWORD PTR [rsp+0x78]
    1466:	mov    r13,QWORD PTR [rsp+0x80]
    146e:	mov    r14,QWORD PTR [rsp+0x88]
    1476:	mov    r15,QWORD PTR [rsp+0x90]
    147e:	add    rsp,0xa0
    1485:	mov    rsp,rbp
    1488:	pop    rbp
    1489:	ret
    148a:	lea    rcx,[rsp+0x28]
    148f:	mov    rdx,r15
    1492:	mov    rsi,QWORD PTR [rsp+0x58]
    1497:	mov    rdi,rbx
    149a:	call   149f <botlish_fn_17+0xff>
			149b: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    149f:	test   rax,rax
    14a2:	mov    rsi,rax
    14a5:	je     164c <botlish_fn_17+0x2ac>
    14ab:	mov    rdx,QWORD PTR [rsp+0x28]
    14b0:	mov    rcx,QWORD PTR [rsp+0x30]
    14b5:	mov    rax,QWORD PTR [rbx+0x10]
    14b9:	mov    r8,QWORD PTR [rax]
    14bc:	mov    rdi,rbx
    14bf:	call   14c4 <botlish_fn_17+0x124>
			14c0: R_X86_64_PLT32	rt_str_region_eq-0x4
    14c4:	cmp    rax,0x6
    14c8:	je     15b9 <botlish_fn_17+0x219>
    14ce:	lea    rcx,[rsp+0x48]
    14d3:	mov    rdx,r15
    14d6:	mov    rsi,QWORD PTR [rsp+0x58]
    14db:	mov    rdi,rbx
    14de:	call   14e3 <botlish_fn_17+0x143>
			14df: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    14e3:	test   rax,rax
    14e6:	mov    r13,rax
    14e9:	je     164c <botlish_fn_17+0x2ac>
    14ef:	mov    rdx,QWORD PTR [rsp+0x48]
    14f4:	mov    QWORD PTR [rsp+0x68],rdx
    14f9:	mov    rcx,QWORD PTR [rsp+0x50]
    14fe:	mov    QWORD PTR [rsp+0x60],rcx
    1503:	mov    rsi,r13
    1506:	mov    rdi,rbx
    1509:	call   150e <botlish_fn_17+0x16e>
			150a: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    150e:	test   rax,rax
    1511:	je     164c <botlish_fn_17+0x2ac>
    1517:	cmp    rax,0x6
    151b:	je     155c <botlish_fn_17+0x1bc>
    1521:	mov    rax,QWORD PTR [rbx+0x10]
    1525:	mov    r8,QWORD PTR [rax+0x20]
    1529:	mov    rcx,QWORD PTR [rsp+0x60]
    152e:	mov    rdx,QWORD PTR [rsp+0x68]
    1533:	mov    rsi,r13
    1536:	mov    rdi,rbx
    1539:	call   153e <botlish_fn_17+0x19e>
			153a: R_X86_64_PLT32	rt_str_region_eq-0x4
    153e:	cmp    rax,0x6
    1542:	je     1552 <botlish_fn_17+0x1b2>
    1548:	mov    ecx,0x2
    154d:	jmp    1561 <botlish_fn_17+0x1c1>
    1552:	mov    ecx,0x6
    1557:	jmp    1561 <botlish_fn_17+0x1c1>
    155c:	mov    ecx,0x6
    1561:	cmp    rcx,0x6
    1565:	je     1576 <botlish_fn_17+0x1d6>
    156b:	mov    r9d,0x6
    1571:	jmp    157c <botlish_fn_17+0x1dc>
    1576:	mov    r9d,0x2
    157c:	cmp    r9,0x6
    1580:	jne    1687 <botlish_fn_17+0x2e7>
    1586:	mov    eax,0x2
    158b:	mov    rbx,QWORD PTR [rsp+0x70]
    1590:	mov    r12,QWORD PTR [rsp+0x78]
    1595:	mov    r13,QWORD PTR [rsp+0x80]
    159d:	mov    r14,QWORD PTR [rsp+0x88]
    15a5:	mov    r15,QWORD PTR [rsp+0x90]
    15ad:	add    rsp,0xa0
    15b4:	mov    rsp,rbp
    15b7:	pop    rbp
    15b8:	ret
    15b9:	mov    rsi,QWORD PTR [rsp+0x58]
    15be:	mov    r13,rsi
    15c1:	sar    r13,1
    15c4:	mov    rax,r12
    15c7:	sar    rax,1
    15ca:	cmp    r13,rax
    15cd:	je     1754 <botlish_fn_17+0x3b4>
    15d3:	mov    rsi,r13
    15d6:	sub    rsi,0x1
    15da:	shl    rsi,1
    15dd:	or     rsi,0x1
    15e1:	mov    QWORD PTR [rsp+0x20],rsi
    15e6:	lea    rcx,[rsp+0x38]
    15eb:	mov    rdx,r15
    15ee:	mov    rdi,rbx
    15f1:	call   15f6 <botlish_fn_17+0x256>
			15f2: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    15f6:	test   rax,rax
    15f9:	mov    rsi,rax
    15fc:	je     164c <botlish_fn_17+0x2ac>
    1602:	mov    rdx,QWORD PTR [rsp+0x38]
    1607:	mov    rcx,QWORD PTR [rsp+0x40]
    160c:	mov    rax,QWORD PTR [rbx+0x10]
    1610:	mov    r8,QWORD PTR [rax]
    1613:	mov    rdi,rbx
    1616:	call   161b <botlish_fn_17+0x27b>
			1617: R_X86_64_PLT32	rt_str_region_eq-0x4
    161b:	cmp    rax,0x6
    161f:	je     1721 <botlish_fn_17+0x381>
    1625:	lea    rsi,[r13+0x1]
    1629:	shl    rsi,1
    162c:	or     rsi,0x1
    1630:	mov    QWORD PTR [rsp+0x20],rsi
    1635:	mov    rcx,r15
    1638:	mov    rdx,r14
    163b:	mov    rdi,rbx
    163e:	call   1643 <botlish_fn_17+0x2a3>
			163f: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<generic>
    1643:	test   rax,rax
    1646:	jne    167d <botlish_fn_17+0x2dd>
    164c:	xor    rax,rax
    164f:	mov    rbx,QWORD PTR [rsp+0x70]
    1654:	mov    r12,QWORD PTR [rsp+0x78]
    1659:	mov    r13,QWORD PTR [rsp+0x80]
    1661:	mov    r14,QWORD PTR [rsp+0x88]
    1669:	mov    r15,QWORD PTR [rsp+0x90]
    1671:	add    rsp,0xa0
    1678:	mov    rsp,rbp
    167b:	pop    rbp
    167c:	ret
    167d:	cmp    rax,0x6
    1681:	je     16ee <botlish_fn_17+0x34e>
    1687:	mov    QWORD PTR [rsp+0x20],0x3
    1690:	mov    rsi,QWORD PTR [rsp+0x58]
    1695:	test   rsi,0x1
    169c:	je     16c2 <botlish_fn_17+0x322>
    16a2:	mov    rsi,QWORD PTR [rsp+0x58]
    16a7:	add    rsi,0x2
    16ab:	seto   dil
    16af:	test   dil,dil
    16b2:	jne    16c2 <botlish_fn_17+0x322>
    16b8:	mov    QWORD PTR [rsp+0x58],rsi
    16bd:	jmp    16dc <botlish_fn_17+0x33c>
    16c2:	mov    edx,0x3
    16c7:	mov    rsi,QWORD PTR [rsp+0x58]
    16cc:	mov    rdi,rbx
    16cf:	call   16d4 <botlish_fn_17+0x334>
			16d0: R_X86_64_PLT32	rt_int_add-0x4
    16d4:	mov    rsi,rax
    16d7:	mov    QWORD PTR [rsp+0x58],rax
    16dc:	mov    QWORD PTR [rsp+0x18],rsi
    16e1:	mov    rsi,QWORD PTR [rsp+0x58]
    16e6:	mov    r8,rbx
    16e9:	jmp    13f5 <botlish_fn_17+0x55>
    16ee:	mov    eax,0x6
    16f3:	mov    rbx,QWORD PTR [rsp+0x70]
    16f8:	mov    r12,QWORD PTR [rsp+0x78]
    16fd:	mov    r13,QWORD PTR [rsp+0x80]
    1705:	mov    r14,QWORD PTR [rsp+0x88]
    170d:	mov    r15,QWORD PTR [rsp+0x90]
    1715:	add    rsp,0xa0
    171c:	mov    rsp,rbp
    171f:	pop    rbp
    1720:	ret
    1721:	mov    eax,0x2
    1726:	mov    rbx,QWORD PTR [rsp+0x70]
    172b:	mov    r12,QWORD PTR [rsp+0x78]
    1730:	mov    r13,QWORD PTR [rsp+0x80]
    1738:	mov    r14,QWORD PTR [rsp+0x88]
    1740:	mov    r15,QWORD PTR [rsp+0x90]
    1748:	add    rsp,0xa0
    174f:	mov    rsp,rbp
    1752:	pop    rbp
    1753:	ret
    1754:	mov    eax,0x2
    1759:	mov    rbx,QWORD PTR [rsp+0x70]
    175e:	mov    r12,QWORD PTR [rsp+0x78]
    1763:	mov    r13,QWORD PTR [rsp+0x80]
    176b:	mov    r14,QWORD PTR [rsp+0x88]
    1773:	mov    r15,QWORD PTR [rsp+0x90]
    177b:	add    rsp,0xa0
    1782:	mov    rsp,rbp
    1785:	pop    rbp
    1786:	ret
    1787:	add    BYTE PTR [rsi],al
    1789:	add    BYTE PTR [rax],al
    178b:	add    BYTE PTR [rax],al
    178d:	add    BYTE PTR [rax],al
	...

0000000000001790 <botlish_entry_17: domain?<generic>>:
    1790:	push   rbp
    1791:	mov    rbp,rsp
    1794:	mov    rsi,QWORD PTR [rdx]
    1797:	mov    r8,QWORD PTR [rdx+0x8]
    179b:	mov    rcx,QWORD PTR [rdx+0x10]
    179f:	mov    rdx,r8
    17a2:	call   17a7 <botlish_entry_17+0x17>
			17a3: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<generic>
    17a7:	mov    rsp,rbp
    17aa:	pop    rbp
    17ab:	ret

00000000000017ac <botlish_fn_18: web::is_unreserved<int>>:
    17ac:	push   rbp
    17ad:	mov    rbp,rsp
    17b0:	sub    rsp,0x10
    17b4:	mov    QWORD PTR [rsp],rbx
    17b8:	mov    QWORD PTR [rsp+0x8],r14
    17bd:	mov    r14,rsi
    17c0:	mov    rsi,r14
    17c3:	sar    rsi,1
    17c6:	mov    rbx,rdi
    17c9:	call   17ce <botlish_fn_18+0x22>
			17ca: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
    17ce:	cmp    rax,0x6
    17d2:	je     1809 <botlish_fn_18+0x5d>
    17d8:	mov    rax,QWORD PTR [rbx+0x30]
    17dc:	mov    rsi,QWORD PTR [rax+0x10]
    17e0:	mov    rdx,r14
    17e3:	mov    rdi,rbx
    17e6:	call   17eb <botlish_fn_18+0x3f>
			17e7: R_X86_64_PLT32	rt_set_contains-0x4
    17eb:	cmp    rax,0x6
    17ef:	je     17ff <botlish_fn_18+0x53>
    17f5:	mov    eax,0x2
    17fa:	jmp    180e <botlish_fn_18+0x62>
    17ff:	mov    eax,0x6
    1804:	jmp    180e <botlish_fn_18+0x62>
    1809:	mov    eax,0x6
    180e:	mov    rbx,QWORD PTR [rsp]
    1812:	mov    r14,QWORD PTR [rsp+0x8]
    1817:	add    rsp,0x10
    181b:	mov    rsp,rbp
    181e:	pop    rbp
    181f:	ret

0000000000001820 <botlish_entry_18: web::is_unreserved<int>>:
    1820:	push   rbp
    1821:	mov    rbp,rsp
    1824:	mov    rsi,QWORD PTR [rdx]
    1827:	call   182c <botlish_entry_18+0xc>
			1828: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    182c:	mov    rsp,rbp
    182f:	pop    rbp
    1830:	ret

0000000000001831 <botlish_fn_19: web::uri_escape_text<str>>:
    1831:	push   rbp
    1832:	mov    rbp,rsp
    1835:	sub    rsp,0x10
    1839:	mov    edx,0x1
    183e:	mov    QWORD PTR [rsp],0x1
    1846:	mov    r10,QWORD PTR [rdi+0x10]
    184a:	mov    rcx,QWORD PTR [r10+0xe0]
    1851:	mov    QWORD PTR [rsp+0x8],rcx
    1856:	call   185b <botlish_fn_19+0x2a>
			1857: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    185b:	test   rax,rax
    185e:	jne    1870 <botlish_fn_19+0x3f>
    1864:	xor    rax,rax
    1867:	add    rsp,0x10
    186b:	mov    rsp,rbp
    186e:	pop    rbp
    186f:	ret
    1870:	add    rsp,0x10
    1874:	mov    rsp,rbp
    1877:	pop    rbp
    1878:	ret

0000000000001879 <botlish_entry_19: web::uri_escape_text<str>>:
    1879:	push   rbp
    187a:	mov    rbp,rsp
    187d:	sub    rsp,0x10
    1881:	mov    QWORD PTR [rsp],r12
    1885:	mov    r12,rdi
    1888:	mov    rsi,QWORD PTR [rdx]
    188b:	mov    r8,QWORD PTR [rip+0x0]        # 1892 <botlish_entry_19+0x19>
			188e: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    1892:	call   r8
    1895:	mov    rsi,rax
    1898:	mov    rdi,r12
    189b:	call   18a0 <botlish_entry_19+0x27>
			189c: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_escape_text<str>
    18a0:	mov    r12,QWORD PTR [rsp]
    18a4:	add    rsp,0x10
    18a8:	mov    rsp,rbp
    18ab:	pop    rbp
    18ac:	ret

00000000000018ad <botlish_fn_20: high_nibble<int>>:
    18ad:	push   rbp
    18ae:	mov    rbp,rsp
    18b1:	sub    rsp,0x10
    18b5:	mov    QWORD PTR [rsp],rsi
    18b9:	mov    QWORD PTR [rsp+0x8],0x1e1
    18c2:	test   rsi,0x1
    18c9:	jne    18de <botlish_fn_20+0x31>
    18cf:	mov    edx,0x1e1
    18d4:	call   18d9 <botlish_fn_20+0x2c>
			18d5: R_X86_64_PLT32	rt_int_and-0x4
    18d9:	jmp    18e8 <botlish_fn_20+0x3b>
    18de:	and    rsi,0x1e1
    18e5:	mov    rax,rsi
    18e8:	sar    rax,0x5
    18ec:	shl    rax,1
    18ef:	or     rax,0x1
    18f3:	add    rsp,0x10
    18f7:	mov    rsp,rbp
    18fa:	pop    rbp
    18fb:	ret

00000000000018fc <botlish_entry_20: high_nibble<int>>:
    18fc:	push   rbp
    18fd:	mov    rbp,rsp
    1900:	mov    rsi,QWORD PTR [rdx]
    1903:	call   1908 <botlish_entry_20+0xc>
			1904: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    1908:	mov    rsp,rbp
    190b:	pop    rbp
    190c:	ret

000000000000190d <botlish_fn_21: hex_pair<int>>:
    190d:	push   rbp
    190e:	mov    rbp,rsp
    1911:	sub    rsp,0x50
    1915:	mov    QWORD PTR [rsp+0x30],rbx
    191a:	mov    QWORD PTR [rsp+0x38],r12
    191f:	mov    QWORD PTR [rsp+0x40],r13
    1924:	mov    QWORD PTR [rsp+0x48],r14
    1929:	mov    QWORD PTR [rsp],rsi
    192d:	mov    r12,rsi
    1930:	mov    rax,QWORD PTR [rdi+0x30]
    1934:	mov    rbx,rdi
    1937:	mov    rsi,QWORD PTR [rax+0x8]
    193b:	mov    QWORD PTR [rsp+0x8],rsi
    1940:	mov    r13,rsi
    1943:	mov    rsi,r12
    1946:	call   194b <botlish_fn_21+0x3e>
			1947: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    194b:	test   rax,0x1
    1951:	jne    1962 <botlish_fn_21+0x55>
    1957:	mov    rdx,rax
    195a:	mov    rsi,r13
    195d:	jmp    197b <botlish_fn_21+0x6e>
    1962:	mov    rsi,r13
    1965:	mov    rdx,QWORD PTR [rsi+0x8]
    1969:	mov    rcx,rax
    196c:	sar    rcx,1
    196f:	cmp    rcx,rdx
    1972:	jb     1991 <botlish_fn_21+0x84>
    1978:	mov    rdx,rax
    197b:	mov    rdi,rbx
    197e:	call   1983 <botlish_fn_21+0x76>
			197f: R_X86_64_PLT32	rt_list_get-0x4
    1983:	test   rax,rax
    1986:	je     1a56 <botlish_fn_21+0x149>
    198c:	jmp    1999 <botlish_fn_21+0x8c>
    1991:	mov    rax,QWORD PTR [rsi+0x10]
    1995:	mov    rax,QWORD PTR [rax+rcx*8]
    1999:	mov    QWORD PTR [rsp],rax
    199d:	mov    rdi,rbx
    19a0:	mov    r14,rax
    19a3:	mov    rax,QWORD PTR [rdi+0x30]
    19a7:	mov    rsi,QWORD PTR [rax+0x8]
    19ab:	mov    r13,rsi
    19ae:	mov    edx,0x21
    19b3:	mov    rsi,r12
    19b6:	call   19bb <botlish_fn_21+0xae>
			19b7: R_X86_64_PLT32	rt_int_mod-0x4
    19bb:	test   rax,rax
    19be:	je     1a56 <botlish_fn_21+0x149>
    19c4:	test   rax,0x1
    19ca:	jne    19db <botlish_fn_21+0xce>
    19d0:	mov    rdx,rax
    19d3:	mov    rsi,r13
    19d6:	jmp    19f4 <botlish_fn_21+0xe7>
    19db:	mov    rsi,r13
    19de:	mov    rdx,QWORD PTR [rsi+0x8]
    19e2:	mov    rcx,rax
    19e5:	sar    rcx,1
    19e8:	cmp    rcx,rdx
    19eb:	jb     1a0a <botlish_fn_21+0xfd>
    19f1:	mov    rdx,rax
    19f4:	mov    rdi,rbx
    19f7:	call   19fc <botlish_fn_21+0xef>
			19f8: R_X86_64_PLT32	rt_list_get-0x4
    19fc:	test   rax,rax
    19ff:	je     1a56 <botlish_fn_21+0x149>
    1a05:	jmp    1a12 <botlish_fn_21+0x105>
    1a0a:	mov    rax,QWORD PTR [rsi+0x10]
    1a0e:	mov    rax,QWORD PTR [rax+rcx*8]
    1a12:	mov    QWORD PTR [rsp+0x8],rax
    1a17:	lea    rcx,[rsp+0x10]
    1a1c:	mov    QWORD PTR [rsp+0x10],0x0
    1a25:	mov    rdx,r14
    1a28:	mov    QWORD PTR [rsp+0x18],rdx
    1a2d:	mov    QWORD PTR [rsp+0x20],0x0
    1a36:	mov    QWORD PTR [rsp+0x28],rax
    1a3b:	mov    esi,0x2
    1a40:	mov    edx,0x4
    1a45:	mov    rdi,rbx
    1a48:	call   1a4d <botlish_fn_21+0x140>
			1a49: R_X86_64_PLT32	rt_construct-0x4
    1a4d:	test   rax,rax
    1a50:	jne    1a76 <botlish_fn_21+0x169>
    1a56:	xor    rax,rax
    1a59:	mov    rbx,QWORD PTR [rsp+0x30]
    1a5e:	mov    r12,QWORD PTR [rsp+0x38]
    1a63:	mov    r13,QWORD PTR [rsp+0x40]
    1a68:	mov    r14,QWORD PTR [rsp+0x48]
    1a6d:	add    rsp,0x50
    1a71:	mov    rsp,rbp
    1a74:	pop    rbp
    1a75:	ret
    1a76:	mov    rbx,QWORD PTR [rsp+0x30]
    1a7b:	mov    r12,QWORD PTR [rsp+0x38]
    1a80:	mov    r13,QWORD PTR [rsp+0x40]
    1a85:	mov    r14,QWORD PTR [rsp+0x48]
    1a8a:	add    rsp,0x50
    1a8e:	mov    rsp,rbp
    1a91:	pop    rbp
    1a92:	ret

0000000000001a93 <botlish_entry_21: hex_pair<int>>:
    1a93:	push   rbp
    1a94:	mov    rbp,rsp
    1a97:	sub    rsp,0x10
    1a9b:	mov    QWORD PTR [rsp],r12
    1a9f:	mov    r12,rdi
    1aa2:	mov    rsi,QWORD PTR [rdx]
    1aa5:	call   1aaa <botlish_entry_21+0x17>
			1aa6: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1aaa:	mov    r8,QWORD PTR [rip+0x0]        # 1ab1 <botlish_entry_21+0x1e>
			1aad: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1ab1:	mov    rsi,rax
    1ab4:	mov    rdi,r12
    1ab7:	call   r8
    1aba:	mov    r12,QWORD PTR [rsp]
    1abe:	add    rsp,0x10
    1ac2:	mov    rsp,rbp
    1ac5:	pop    rbp
    1ac6:	ret

0000000000001ac7 <botlish_fn_22: esc_bytes<List[int], int, str>>:
    1ac7:	push   rbp
    1ac8:	mov    rbp,rsp
    1acb:	sub    rsp,0x90
    1ad2:	mov    QWORD PTR [rsp+0x60],rbx
    1ad7:	mov    QWORD PTR [rsp+0x68],r12
    1adc:	mov    QWORD PTR [rsp+0x70],r13
    1ae1:	mov    QWORD PTR [rsp+0x78],r14
    1ae6:	mov    QWORD PTR [rsp+0x80],r15
    1aee:	mov    QWORD PTR [rsp],rsi
    1af2:	mov    QWORD PTR [rsp+0x8],rcx
    1af7:	sar    rdx,1
    1afa:	mov    r13,rdx
    1afd:	lea    r14,[rsp+0x20]
    1b02:	mov    rbx,rdi
    1b05:	mov    r12,rsi
    1b08:	mov    QWORD PTR [rsp+0x50],rcx
    1b0d:	mov    rsi,r12
    1b10:	mov    rdi,rbx
    1b13:	call   1b18 <botlish_fn_22+0x51>
			1b14: R_X86_64_PLT32	rt_list_len-0x4
    1b18:	sar    rax,1
    1b1b:	cmp    r13,rax
    1b1e:	jge    1c2e <botlish_fn_22+0x167>
    1b24:	mov    rax,QWORD PTR [rbx+0x10]
    1b28:	mov    r15,QWORD PTR [rax+0x10]
    1b2c:	mov    QWORD PTR [rsp+0x10],r15
    1b31:	mov    rcx,QWORD PTR [r12+0x8]
    1b36:	mov    rax,r13
    1b39:	shl    rax,1
    1b3c:	or     rax,0x1
    1b40:	sar    rax,1
    1b43:	cmp    rax,rcx
    1b46:	jb     1b72 <botlish_fn_22+0xab>
    1b4c:	mov    rdx,r13
    1b4f:	shl    rdx,1
    1b52:	or     rdx,0x1
    1b56:	mov    rsi,r12
    1b59:	mov    rdi,rbx
    1b5c:	call   1b61 <botlish_fn_22+0x9a>
			1b5d: R_X86_64_PLT32	rt_list_get-0x4
    1b61:	test   rax,rax
    1b64:	je     1be9 <botlish_fn_22+0x122>
    1b6a:	mov    rsi,rax
    1b6d:	jmp    1b7b <botlish_fn_22+0xb4>
    1b72:	mov    rcx,QWORD PTR [r12+0x10]
    1b77:	mov    rsi,QWORD PTR [rcx+rax*8]
    1b7b:	mov    QWORD PTR [rsp+0x18],rsi
    1b80:	mov    rdi,rbx
    1b83:	call   1b88 <botlish_fn_22+0xc1>
			1b84: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1b88:	test   rax,rax
    1b8b:	je     1be9 <botlish_fn_22+0x122>
    1b91:	mov    QWORD PTR [rsp+0x18],rax
    1b96:	mov    rcx,rax
    1b99:	mov    QWORD PTR [rsp+0x20],0x0
    1ba2:	mov    rax,QWORD PTR [rsp+0x50]
    1ba7:	mov    QWORD PTR [rsp+0x28],rax
    1bac:	mov    QWORD PTR [rsp+0x30],0x0
    1bb5:	mov    QWORD PTR [rsp+0x38],r15
    1bba:	mov    QWORD PTR [rsp+0x40],0x0
    1bc3:	mov    rax,rcx
    1bc6:	mov    QWORD PTR [rsp+0x48],rax
    1bcb:	mov    esi,0x2
    1bd0:	mov    edx,0x6
    1bd5:	mov    rcx,r14
    1bd8:	mov    rdi,rbx
    1bdb:	call   1be0 <botlish_fn_22+0x119>
			1bdc: R_X86_64_PLT32	rt_construct-0x4
    1be0:	test   rax,rax
    1be3:	jne    1c14 <botlish_fn_22+0x14d>
    1be9:	xor    rax,rax
    1bec:	mov    rbx,QWORD PTR [rsp+0x60]
    1bf1:	mov    r12,QWORD PTR [rsp+0x68]
    1bf6:	mov    r13,QWORD PTR [rsp+0x70]
    1bfb:	mov    r14,QWORD PTR [rsp+0x78]
    1c00:	mov    r15,QWORD PTR [rsp+0x80]
    1c08:	add    rsp,0x90
    1c0f:	mov    rsp,rbp
    1c12:	pop    rbp
    1c13:	ret
    1c14:	mov    QWORD PTR [rsp],r12
    1c18:	mov    QWORD PTR [rsp+0x8],rax
    1c1d:	add    r13,0x1
    1c24:	mov    QWORD PTR [rsp+0x50],rax
    1c29:	jmp    1b0d <botlish_fn_22+0x46>
    1c2e:	mov    rax,QWORD PTR [rsp+0x50]
    1c33:	mov    rbx,QWORD PTR [rsp+0x60]
    1c38:	mov    r12,QWORD PTR [rsp+0x68]
    1c3d:	mov    r13,QWORD PTR [rsp+0x70]
    1c42:	mov    r14,QWORD PTR [rsp+0x78]
    1c47:	mov    r15,QWORD PTR [rsp+0x80]
    1c4f:	add    rsp,0x90
    1c56:	mov    rsp,rbp
    1c59:	pop    rbp
    1c5a:	ret

0000000000001c5b <botlish_entry_22: esc_bytes<List[int], int, str>>:
    1c5b:	push   rbp
    1c5c:	mov    rbp,rsp
    1c5f:	sub    rsp,0x10
    1c63:	mov    QWORD PTR [rsp],r12
    1c67:	mov    r12,rdi
    1c6a:	mov    rsi,QWORD PTR [rdx]
    1c6d:	mov    r8,QWORD PTR [rdx+0x8]
    1c71:	mov    rcx,QWORD PTR [rdx+0x10]
    1c75:	mov    rdx,r8
    1c78:	call   1c7d <botlish_entry_22+0x22>
			1c79: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1c7d:	mov    r8,QWORD PTR [rip+0x0]        # 1c84 <botlish_entry_22+0x29>
			1c80: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1c84:	mov    rsi,rax
    1c87:	mov    rdi,r12
    1c8a:	call   r8
    1c8d:	mov    r12,QWORD PTR [rsp]
    1c91:	add    rsp,0x10
    1c95:	mov    rsp,rbp
    1c98:	pop    rbp
    1c99:	ret

0000000000001c9a <botlish_fn_23: esc_char<str>>:
    1c9a:	push   rbp
    1c9b:	mov    rbp,rsp
    1c9e:	sub    rsp,0x40
    1ca2:	mov    QWORD PTR [rsp+0x20],rbx
    1ca7:	mov    QWORD PTR [rsp+0x28],r12
    1cac:	mov    QWORD PTR [rsp+0x30],r13
    1cb1:	mov    rbx,rdi
    1cb4:	mov    QWORD PTR [rsp+0x8],0x0
    1cbd:	mov    QWORD PTR [rsp+0x10],0x0
    1cc6:	mov    QWORD PTR [rsp],rsi
    1cca:	mov    r13,rsi
    1ccd:	mov    rsi,r13
    1cd0:	mov    rdi,rbx
    1cd3:	call   1cd8 <botlish_fn_23+0x3e>
			1cd4: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1cd8:	mov    rcx,rax
    1cdb:	mov    r12,rax
    1cde:	test   rax,rcx
    1ce1:	je     1dbf <botlish_fn_23+0x125>
    1ce7:	mov    rax,r12
    1cea:	mov    QWORD PTR [rsp],rax
    1cee:	mov    rsi,r12
    1cf1:	mov    rdi,rbx
    1cf4:	call   1cf9 <botlish_fn_23+0x5f>
			1cf5: R_X86_64_PLT32	rt_list_len-0x4
    1cf9:	sar    rax,1
    1cfc:	cmp    rax,0x1
    1d00:	je     1d3d <botlish_fn_23+0xa3>
    1d06:	mov    edx,0x1
    1d0b:	mov    QWORD PTR [rsp+0x8],0x1
    1d14:	mov    rdi,rbx
    1d17:	mov    rax,QWORD PTR [rdi+0x10]
    1d1b:	mov    rcx,QWORD PTR [rax+0xe0]
    1d22:	mov    QWORD PTR [rsp+0x10],rcx
    1d27:	mov    rsi,r12
    1d2a:	call   1d2f <botlish_fn_23+0x95>
			1d2b: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1d2f:	test   rax,rax
    1d32:	je     1dbf <botlish_fn_23+0x125>
    1d38:	jmp    1de0 <botlish_fn_23+0x146>
    1d3d:	mov    rsi,r12
    1d40:	mov    rax,QWORD PTR [rsi+0x8]
    1d44:	mov    r12,rsi
    1d47:	test   rax,rax
    1d4a:	jne    1d71 <botlish_fn_23+0xd7>
    1d50:	mov    edx,0x1
    1d55:	mov    rsi,r12
    1d58:	mov    rdi,rbx
    1d5b:	call   1d60 <botlish_fn_23+0xc6>
			1d5c: R_X86_64_PLT32	rt_list_get-0x4
    1d60:	test   rax,rax
    1d63:	je     1dbf <botlish_fn_23+0x125>
    1d69:	mov    rsi,rax
    1d6c:	jmp    1d7b <botlish_fn_23+0xe1>
    1d71:	mov    rsi,r12
    1d74:	mov    rax,QWORD PTR [rsi+0x10]
    1d78:	mov    rsi,QWORD PTR [rax]
    1d7b:	mov    rdi,rbx
    1d7e:	call   1d83 <botlish_fn_23+0xe9>
			1d7f: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1d83:	cmp    rax,0x6
    1d87:	je     1ddd <botlish_fn_23+0x143>
    1d8d:	mov    edx,0x1
    1d92:	mov    QWORD PTR [rsp+0x8],0x1
    1d9b:	mov    rdi,rbx
    1d9e:	mov    rax,QWORD PTR [rdi+0x10]
    1da2:	mov    rcx,QWORD PTR [rax+0xe0]
    1da9:	mov    QWORD PTR [rsp+0x10],rcx
    1dae:	mov    rsi,r12
    1db1:	call   1db6 <botlish_fn_23+0x11c>
			1db2: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1db6:	test   rax,rax
    1db9:	jne    1dda <botlish_fn_23+0x140>
    1dbf:	xor    rax,rax
    1dc2:	mov    rbx,QWORD PTR [rsp+0x20]
    1dc7:	mov    r12,QWORD PTR [rsp+0x28]
    1dcc:	mov    r13,QWORD PTR [rsp+0x30]
    1dd1:	add    rsp,0x40
    1dd5:	mov    rsp,rbp
    1dd8:	pop    rbp
    1dd9:	ret
    1dda:	mov    r13,rax
    1ddd:	mov    rax,r13
    1de0:	mov    rbx,QWORD PTR [rsp+0x20]
    1de5:	mov    r12,QWORD PTR [rsp+0x28]
    1dea:	mov    r13,QWORD PTR [rsp+0x30]
    1def:	add    rsp,0x40
    1df3:	mov    rsp,rbp
    1df6:	pop    rbp
    1df7:	ret

0000000000001df8 <botlish_entry_23: esc_char<str>>:
    1df8:	push   rbp
    1df9:	mov    rbp,rsp
    1dfc:	sub    rsp,0x10
    1e00:	mov    QWORD PTR [rsp],r12
    1e04:	mov    r12,rdi
    1e07:	mov    rsi,QWORD PTR [rdx]
    1e0a:	call   1e0f <botlish_entry_23+0x17>
			1e0b: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1e0f:	mov    r8,QWORD PTR [rip+0x0]        # 1e16 <botlish_entry_23+0x1e>
			1e12: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1e16:	mov    rsi,rax
    1e19:	mov    rdi,r12
    1e1c:	call   r8
    1e1f:	mov    r12,QWORD PTR [rsp]
    1e23:	add    rsp,0x10
    1e27:	mov    rsp,rbp
    1e2a:	pop    rbp
    1e2b:	ret

0000000000001e2c <botlish_fn_24: esc_from<str, int, str>>:
    1e2c:	push   rbp
    1e2d:	mov    rbp,rsp
    1e30:	sub    rsp,0x90
    1e37:	mov    QWORD PTR [rsp+0x60],rbx
    1e3c:	mov    QWORD PTR [rsp+0x68],r12
    1e41:	mov    QWORD PTR [rsp+0x70],r13
    1e46:	mov    QWORD PTR [rsp+0x78],r14
    1e4b:	mov    QWORD PTR [rsp+0x80],r15
    1e53:	mov    r14,rdi
    1e56:	mov    QWORD PTR [rsp+0x8],0x0
    1e5f:	mov    QWORD PTR [rsp+0x10],0x0
    1e68:	mov    QWORD PTR [rsp+0x18],0x0
    1e71:	mov    QWORD PTR [rsp],rcx
    1e75:	mov    QWORD PTR [rsp+0x50],rcx
    1e7a:	sar    rdx,1
    1e7d:	mov    r13d,0x47
    1e83:	mov    rcx,0xffffffffffffffff
    1e8a:	bsr    rax,rsi
    1e8e:	mov    r15,rsi
    1e91:	cmove  rax,rcx
    1e95:	mov    ecx,0x3f
    1e9a:	sub    rcx,rax
    1e9d:	sub    r13,rcx
    1ea0:	shr    r13,0x3
    1ea4:	lea    rbx,[rsp+0x30]
    1ea9:	mov    r12,rdx
    1eac:	cmp    r12,r13
    1eaf:	jge    1f69 <botlish_fn_24+0x13d>
    1eb5:	mov    rsi,r15
    1eb8:	mov    rdi,r14
    1ebb:	call   1ec0 <botlish_fn_24+0x94>
			1ebc: R_X86_64_PLT32	rt_ascii_to_str-0x4
    1ec0:	mov    QWORD PTR [rsp+0x8],rax
    1ec5:	mov    rdx,r12
    1ec8:	shl    rdx,1
    1ecb:	or     rdx,0x1
    1ecf:	mov    QWORD PTR [rsp+0x10],rdx
    1ed4:	add    r12,0x1
    1edb:	mov    rcx,r12
    1ede:	shl    rcx,1
    1ee1:	or     rcx,0x1
    1ee5:	mov    QWORD PTR [rsp+0x18],rcx
    1eea:	mov    rsi,rax
    1eed:	mov    rdi,r14
    1ef0:	call   1ef5 <botlish_fn_24+0xc9>
			1ef1: R_X86_64_PLT32	rt_substr-0x4
    1ef5:	test   rax,rax
    1ef8:	je     1f9d <botlish_fn_24+0x171>
    1efe:	mov    QWORD PTR [rsp+0x8],rax
    1f03:	mov    rsi,rax
    1f06:	mov    rdi,r14
    1f09:	call   1f0e <botlish_fn_24+0xe2>
			1f0a: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1f0e:	test   rax,rax
    1f11:	je     1f9d <botlish_fn_24+0x171>
    1f17:	mov    QWORD PTR [rsp+0x8],rax
    1f1c:	mov    QWORD PTR [rsp+0x30],0x0
    1f25:	mov    rcx,QWORD PTR [rsp+0x50]
    1f2a:	mov    QWORD PTR [rsp+0x38],rcx
    1f2f:	mov    QWORD PTR [rsp+0x40],0x0
    1f38:	mov    QWORD PTR [rsp+0x48],rax
    1f3d:	mov    esi,0x2
    1f42:	mov    edx,0x4
    1f47:	mov    rcx,rbx
    1f4a:	mov    rdi,r14
    1f4d:	call   1f52 <botlish_fn_24+0x126>
			1f4e: R_X86_64_PLT32	rt_construct-0x4
    1f52:	test   rax,rax
    1f55:	je     1f9d <botlish_fn_24+0x171>
    1f5b:	mov    QWORD PTR [rsp],rax
    1f5f:	mov    QWORD PTR [rsp+0x50],rax
    1f64:	jmp    1eac <botlish_fn_24+0x80>
    1f69:	mov    rcx,QWORD PTR [rsp+0x50]
    1f6e:	xor    rsi,rsi
    1f71:	lea    rax,[rsp+0x20]
    1f76:	mov    QWORD PTR [rsp+0x20],0x0
    1f7f:	mov    QWORD PTR [rsp+0x28],rcx
    1f84:	mov    edx,0x2
    1f89:	mov    rcx,rax
    1f8c:	mov    rdi,r14
    1f8f:	call   1f94 <botlish_fn_24+0x168>
			1f90: R_X86_64_PLT32	rt_construct-0x4
    1f94:	test   rax,rax
    1f97:	jne    1fc8 <botlish_fn_24+0x19c>
    1f9d:	xor    rax,rax
    1fa0:	mov    rbx,QWORD PTR [rsp+0x60]
    1fa5:	mov    r12,QWORD PTR [rsp+0x68]
    1faa:	mov    r13,QWORD PTR [rsp+0x70]
    1faf:	mov    r14,QWORD PTR [rsp+0x78]
    1fb4:	mov    r15,QWORD PTR [rsp+0x80]
    1fbc:	add    rsp,0x90
    1fc3:	mov    rsp,rbp
    1fc6:	pop    rbp
    1fc7:	ret
    1fc8:	mov    rbx,QWORD PTR [rsp+0x60]
    1fcd:	mov    r12,QWORD PTR [rsp+0x68]
    1fd2:	mov    r13,QWORD PTR [rsp+0x70]
    1fd7:	mov    r14,QWORD PTR [rsp+0x78]
    1fdc:	mov    r15,QWORD PTR [rsp+0x80]
    1fe4:	add    rsp,0x90
    1feb:	mov    rsp,rbp
    1fee:	pop    rbp
    1fef:	ret

0000000000001ff0 <botlish_entry_24: esc_from<str, int, str>>:
    1ff0:	push   rbp
    1ff1:	mov    rbp,rsp
    1ff4:	sub    rsp,0x10
    1ff8:	mov    QWORD PTR [rsp],r12
    1ffc:	mov    QWORD PTR [rsp+0x8],r13
    2001:	mov    r12,rdi
    2004:	mov    rsi,QWORD PTR [rdx]
    2007:	mov    r13,rdx
    200a:	mov    r8,QWORD PTR [rip+0x0]        # 2011 <botlish_entry_24+0x21>
			200d: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    2011:	call   r8
    2014:	mov    rcx,r13
    2017:	mov    rdx,QWORD PTR [rcx+0x8]
    201b:	mov    rcx,QWORD PTR [rcx+0x10]
    201f:	mov    rsi,rax
    2022:	mov    rdi,r12
    2025:	call   202a <botlish_entry_24+0x3a>
			2026: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    202a:	mov    r12,QWORD PTR [rsp]
    202e:	mov    r13,QWORD PTR [rsp+0x8]
    2033:	add    rsp,0x10
    2037:	mov    rsp,rbp
    203a:	pop    rbp
    203b:	ret

000000000000203c <botlish_fn_25: check<int, int, str, str>>:
    203c:	push   rbp
    203d:	mov    rbp,rsp
    2040:	sub    rsp,0x50
    2044:	mov    QWORD PTR [rsp+0x20],rbx
    2049:	mov    QWORD PTR [rsp+0x28],r12
    204e:	mov    QWORD PTR [rsp+0x30],r13
    2053:	mov    QWORD PTR [rsp+0x38],r14
    2058:	mov    QWORD PTR [rsp+0x40],r15
    205d:	mov    r14,rdi
    2060:	mov    QWORD PTR [rsp+0x18],0x0
    2069:	mov    QWORD PTR [rsp],rdx
    206d:	mov    QWORD PTR [rsp+0x8],rcx
    2072:	mov    QWORD PTR [rsp+0x10],r8
    2077:	mov    r13,r8
    207a:	mov    r12,rsi
    207d:	mov    r15,rdx
    2080:	test   r12,r12
    2083:	jle    2145 <botlish_fn_25+0x109>
    2089:	mov    rbx,rcx
    208c:	mov    rsi,rbx
    208f:	mov    rdi,r14
    2092:	call   2097 <botlish_fn_25+0x5b>
			2093: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
    2097:	test   rax,rax
    209a:	jne    20c5 <botlish_fn_25+0x89>
    20a0:	xor    rax,rax
    20a3:	mov    rbx,QWORD PTR [rsp+0x20]
    20a8:	mov    r12,QWORD PTR [rsp+0x28]
    20ad:	mov    r13,QWORD PTR [rsp+0x30]
    20b2:	mov    r14,QWORD PTR [rsp+0x38]
    20b7:	mov    r15,QWORD PTR [rsp+0x40]
    20bc:	add    rsp,0x50
    20c0:	mov    rsp,rbp
    20c3:	pop    rbp
    20c4:	ret
    20c5:	cmp    rax,0x6
    20c9:	je     20e5 <botlish_fn_25+0xa9>
    20cf:	mov    edx,0x1
    20d4:	mov    QWORD PTR [rsp+0x18],0x1
    20dd:	mov    rsi,r15
    20e0:	jmp    20f6 <botlish_fn_25+0xba>
    20e5:	mov    edx,0x3
    20ea:	mov    QWORD PTR [rsp+0x18],0x3
    20f3:	mov    rsi,r15
    20f6:	mov    rax,rsi
    20f9:	and    rax,rdx
    20fc:	test   rax,0x1
    2102:	je     211d <botlish_fn_25+0xe1>
    2108:	lea    rcx,[rdx-0x1]
    210c:	mov    rax,rsi
    210f:	add    rax,rcx
    2112:	seto   cl
    2115:	test   cl,cl
    2117:	je     2125 <botlish_fn_25+0xe9>
    211d:	mov    rdi,r14
    2120:	call   2125 <botlish_fn_25+0xe9>
			2121: R_X86_64_PLT32	rt_int_add-0x4
    2125:	mov    QWORD PTR [rsp],rax
    2129:	mov    QWORD PTR [rsp+0x8],rbx
    212e:	mov    r8,r13
    2131:	mov    QWORD PTR [rsp+0x10],r8
    2136:	sub    r12,0x1
    213a:	mov    rcx,rbx
    213d:	mov    r15,rax
    2140:	jmp    2080 <botlish_fn_25+0x44>
    2145:	mov    rax,r15
    2148:	mov    rbx,QWORD PTR [rsp+0x20]
    214d:	mov    r12,QWORD PTR [rsp+0x28]
    2152:	mov    r13,QWORD PTR [rsp+0x30]
    2157:	mov    r14,QWORD PTR [rsp+0x38]
    215c:	mov    r15,QWORD PTR [rsp+0x40]
    2161:	add    rsp,0x50
    2165:	mov    rsp,rbp
    2168:	pop    rbp
    2169:	ret

000000000000216a <botlish_entry_25: check<int, int, str, str>>:
    216a:	push   rbp
    216b:	mov    rbp,rsp
    216e:	mov    rsi,QWORD PTR [rdx]
    2171:	mov    r9,QWORD PTR [rdx+0x8]
    2175:	mov    rcx,QWORD PTR [rdx+0x10]
    2179:	mov    r8,QWORD PTR [rdx+0x18]
    217d:	sar    rsi,1
    2180:	mov    rdx,r9
    2183:	call   2188 <botlish_entry_25+0x1e>
			2184: R_X86_64_PLT32	botlish_fn_25-0x4 ; check<int, int, str, str>
    2188:	mov    rsp,rbp
    218b:	pop    rbp
    218c:	ret

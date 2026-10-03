; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 8036  (per function: 1415 39 217 609 74 74 74 128 128 351 166 111 176 238 301 326 183 782 140 127 103 474 491 426 539 344)
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
     5a4:	mov    edx,0x1ff
     5a9:	mov    rbx,rax
     5ac:	mov    rsi,rbx
     5af:	mov    rdi,r12
     5b2:	call   5b7 <botlish_fn_2+0x37>
			5b3: R_X86_64_PLT32	rt_int_cmp-0x4
     5b7:	mov    r8d,0x2
     5bd:	test   rax,rax
     5c0:	cmovg  r8,QWORD PTR [rip+0x70]        # 638 <botlish_fn_2+0xb8>
     5c8:	jmp    5e5 <botlish_fn_2+0x65>
     5cd:	mov    rbx,rax
     5d0:	mov    r8d,0x2
     5d6:	cmp    rbx,0x1ff
     5dd:	cmovg  r8,QWORD PTR [rip+0x53]        # 638 <botlish_fn_2+0xb8>
     5e5:	cmp    r8,0x6
     5e9:	je     604 <botlish_fn_2+0x84>
     5ef:	mov    rax,rbx
     5f2:	mov    rbx,QWORD PTR [rsp]
     5f6:	mov    r12,QWORD PTR [rsp+0x8]
     5fb:	add    rsp,0x10
     5ff:	mov    rsp,rbp
     602:	pop    rbp
     603:	ret
     604:	mov    rdi,r12
     607:	mov    rax,QWORD PTR [rdi+0x10]
     60b:	mov    rdx,QWORD PTR [rax+0xb8]
     612:	mov    esi,0x1
     617:	call   61c <botlish_fn_2+0x9c>
			618: R_X86_64_PLT32	rt_fail_declared-0x4
     61c:	xor    rax,rax
     61f:	mov    rbx,QWORD PTR [rsp]
     623:	mov    r12,QWORD PTR [rsp+0x8]
     628:	add    rsp,0x10
     62c:	mov    rsp,rbp
     62f:	pop    rbp
     630:	ret
     631:	add    BYTE PTR [rax],al
     633:	add    BYTE PTR [rax],al
     635:	add    BYTE PTR [rax],al
     637:	add    BYTE PTR [rsi],al
     639:	add    BYTE PTR [rax],al
     63b:	add    BYTE PTR [rax],al
     63d:	add    BYTE PTR [rax],al
	...

0000000000000640 <botlish_entry_2: byte::from_int<int>>:
     640:	push   rbp
     641:	mov    rbp,rsp
     644:	mov    rsi,QWORD PTR [rdx]
     647:	call   64c <botlish_entry_2+0xc>
			648: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     64c:	mov    rsp,rbp
     64f:	pop    rbp
     650:	ret
     651:	add    BYTE PTR [rax],al
     653:	add    BYTE PTR [rax],al
     655:	add    BYTE PTR [rax],al
	...

0000000000000658 <botlish_fn_3: byte::set<List[UnicodeChar]>>:
     658:	push   rbp
     659:	mov    rbp,rsp
     65c:	sub    rsp,0x60
     660:	mov    QWORD PTR [rsp+0x30],rbx
     665:	mov    QWORD PTR [rsp+0x38],r12
     66a:	mov    QWORD PTR [rsp+0x40],r13
     66f:	mov    QWORD PTR [rsp+0x48],r14
     674:	mov    QWORD PTR [rsp+0x50],r15
     679:	mov    r13,rdi
     67c:	mov    QWORD PTR [rsp+0x18],0x0
     685:	mov    QWORD PTR [rsp+0x20],0x0
     68e:	mov    QWORD PTR [rsp],rsi
     692:	mov    rbx,rsi
     695:	mov    rdi,r13
     698:	call   69d <botlish_fn_3+0x45>
			699: R_X86_64_PLT32	rt_list_len-0x4
     69d:	mov    QWORD PTR [rsp+0x8],rax
     6a2:	mov    r12,rax
     6a5:	mov    QWORD PTR [rsp+0x10],0x1
     6ae:	xor    rdx,rdx
     6b1:	mov    rdi,r13
     6b4:	mov    rsi,rdx
     6b7:	call   6bc <botlish_fn_3+0x64>
			6b8: R_X86_64_PLT32	rt_list_new-0x4
     6bc:	test   rax,rax
     6bf:	je     7e0 <botlish_fn_3+0x188>
     6c5:	mov    QWORD PTR [rsp+0x18],rax
     6ca:	mov    esi,0x1
     6cf:	mov    r14,rsi
     6d2:	mov    r15,rax
     6d5:	mov    rax,rsi
     6d8:	and    rax,r12
     6db:	mov    r14,rsi
     6de:	test   rax,0x1
     6e4:	jne    70d <botlish_fn_3+0xb5>
     6ea:	mov    rdx,r12
     6ed:	mov    rsi,r14
     6f0:	mov    rdi,r13
     6f3:	call   6f8 <botlish_fn_3+0xa0>
			6f4: R_X86_64_PLT32	rt_int_cmp-0x4
     6f8:	mov    ecx,0x2
     6fd:	test   rax,rax
     700:	cmovl  rcx,QWORD PTR [rip+0x170]        # 878 <botlish_fn_3+0x220>
     708:	jmp    720 <botlish_fn_3+0xc8>
     70d:	mov    ecx,0x2
     712:	mov    rsi,r14
     715:	cmp    rsi,r12
     718:	cmovl  rcx,QWORD PTR [rip+0x158]        # 878 <botlish_fn_3+0x220>
     720:	cmp    rcx,0x6
     724:	je     75b <botlish_fn_3+0x103>
     72a:	mov    rsi,r15
     72d:	mov    QWORD PTR [rsp],rsi
     731:	mov    rdi,r13
     734:	call   739 <botlish_fn_3+0xe1>
			735: R_X86_64_PLT32	rt_set_from_list-0x4
     739:	mov    rbx,QWORD PTR [rsp+0x30]
     73e:	mov    r12,QWORD PTR [rsp+0x38]
     743:	mov    r13,QWORD PTR [rsp+0x40]
     748:	mov    r14,QWORD PTR [rsp+0x48]
     74d:	mov    r15,QWORD PTR [rsp+0x50]
     752:	add    rsp,0x60
     756:	mov    rsp,rbp
     759:	pop    rbp
     75a:	ret
     75b:	mov    rsi,r14
     75e:	test   rsi,0x1
     765:	je     781 <botlish_fn_3+0x129>
     76b:	mov    rcx,QWORD PTR [rbx+0x8]
     76f:	mov    rsi,r14
     772:	mov    rax,rsi
     775:	sar    rax,1
     778:	cmp    rax,rcx
     77b:	jb     7a0 <botlish_fn_3+0x148>
     781:	mov    rdx,r14
     784:	mov    rsi,rbx
     787:	mov    rdi,r13
     78a:	call   78f <botlish_fn_3+0x137>
			78b: R_X86_64_PLT32	rt_list_get-0x4
     78f:	test   rax,rax
     792:	je     7e0 <botlish_fn_3+0x188>
     798:	mov    rsi,rax
     79b:	jmp    7a8 <botlish_fn_3+0x150>
     7a0:	mov    rdx,QWORD PTR [rbx+0x10]
     7a4:	mov    rsi,QWORD PTR [rdx+rax*8]
     7a8:	mov    rdi,r13
     7ab:	call   7b0 <botlish_fn_3+0x158>
			7ac: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     7b0:	mov    rsi,rax
     7b3:	mov    rdi,r13
     7b6:	call   7bb <botlish_fn_3+0x163>
			7b7: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     7bb:	test   rax,rax
     7be:	je     7e0 <botlish_fn_3+0x188>
     7c4:	mov    QWORD PTR [rsp+0x20],rax
     7c9:	mov    rdx,rax
     7cc:	mov    rsi,r15
     7cf:	mov    rdi,r13
     7d2:	call   7d7 <botlish_fn_3+0x17f>
			7d3: R_X86_64_PLT32	rt_list_append-0x4
     7d7:	test   rax,rax
     7da:	jne    805 <botlish_fn_3+0x1ad>
     7e0:	xor    rax,rax
     7e3:	mov    rbx,QWORD PTR [rsp+0x30]
     7e8:	mov    r12,QWORD PTR [rsp+0x38]
     7ed:	mov    r13,QWORD PTR [rsp+0x40]
     7f2:	mov    r14,QWORD PTR [rsp+0x48]
     7f7:	mov    r15,QWORD PTR [rsp+0x50]
     7fc:	add    rsp,0x60
     800:	mov    rsp,rbp
     803:	pop    rbp
     804:	ret
     805:	mov    QWORD PTR [rsp+0x18],rax
     80a:	mov    r15,rax
     80d:	mov    edx,0x3
     812:	mov    QWORD PTR [rsp+0x20],0x3
     81b:	mov    rsi,r14
     81e:	test   rsi,0x1
     825:	jne    833 <botlish_fn_3+0x1db>
     82b:	mov    rsi,r14
     82e:	jmp    85b <botlish_fn_3+0x203>
     833:	mov    rsi,r14
     836:	mov    rcx,rsi
     839:	add    rcx,0x2
     83d:	seto   al
     840:	test   al,al
     842:	je     850 <botlish_fn_3+0x1f8>
     848:	mov    rsi,r14
     84b:	jmp    85b <botlish_fn_3+0x203>
     850:	mov    rsi,rcx
     853:	mov    r14,rcx
     856:	jmp    869 <botlish_fn_3+0x211>
     85b:	mov    rdi,r13
     85e:	call   863 <botlish_fn_3+0x20b>
			85f: R_X86_64_PLT32	rt_int_add-0x4
     863:	mov    rsi,rax
     866:	mov    r14,rax
     869:	mov    QWORD PTR [rsp+0x10],rsi
     86e:	mov    rsi,r14
     871:	jmp    6d5 <botlish_fn_3+0x7d>
     876:	add    BYTE PTR [rax],al
     878:	(bad)
     879:	add    BYTE PTR [rax],al
     87b:	add    BYTE PTR [rax],al
     87d:	add    BYTE PTR [rax],al
	...

0000000000000880 <botlish_entry_3: byte::set<List[UnicodeChar]>>:
     880:	push   rbp
     881:	mov    rbp,rsp
     884:	mov    rsi,QWORD PTR [rdx]
     887:	call   88c <botlish_entry_3+0xc>
			888: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::set<List[UnicodeChar]>
     88c:	mov    rsp,rbp
     88f:	pop    rbp
     890:	ret

0000000000000891 <botlish_fn_4: ascii::is_digit<int>>:
     891:	push   rbp
     892:	mov    rbp,rsp
     895:	cmp    rsi,0x30
     899:	jge    8a9 <botlish_fn_4+0x18>
     89f:	mov    eax,0x2
     8a4:	jmp    8c2 <botlish_fn_4+0x31>
     8a9:	cmp    rsi,0x39
     8ad:	jle    8bd <botlish_fn_4+0x2c>
     8b3:	mov    eax,0x2
     8b8:	jmp    8c2 <botlish_fn_4+0x31>
     8bd:	mov    eax,0x6
     8c2:	mov    rsp,rbp
     8c5:	pop    rbp
     8c6:	ret

00000000000008c7 <botlish_entry_4: ascii::is_digit<int>>:
     8c7:	push   rbp
     8c8:	mov    rbp,rsp
     8cb:	mov    rsi,QWORD PTR [rdx]
     8ce:	sar    rsi,1
     8d1:	call   8d6 <botlish_entry_4+0xf>
			8d2: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     8d6:	mov    rsp,rbp
     8d9:	pop    rbp
     8da:	ret

00000000000008db <botlish_fn_5: ascii::is_upper<int>>:
     8db:	push   rbp
     8dc:	mov    rbp,rsp
     8df:	cmp    rsi,0x41
     8e3:	jge    8f3 <botlish_fn_5+0x18>
     8e9:	mov    eax,0x2
     8ee:	jmp    90c <botlish_fn_5+0x31>
     8f3:	cmp    rsi,0x5a
     8f7:	jle    907 <botlish_fn_5+0x2c>
     8fd:	mov    eax,0x2
     902:	jmp    90c <botlish_fn_5+0x31>
     907:	mov    eax,0x6
     90c:	mov    rsp,rbp
     90f:	pop    rbp
     910:	ret

0000000000000911 <botlish_entry_5: ascii::is_upper<int>>:
     911:	push   rbp
     912:	mov    rbp,rsp
     915:	mov    rsi,QWORD PTR [rdx]
     918:	sar    rsi,1
     91b:	call   920 <botlish_entry_5+0xf>
			91c: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     920:	mov    rsp,rbp
     923:	pop    rbp
     924:	ret

0000000000000925 <botlish_fn_6: ascii::is_lower<int>>:
     925:	push   rbp
     926:	mov    rbp,rsp
     929:	cmp    rsi,0x61
     92d:	jge    93d <botlish_fn_6+0x18>
     933:	mov    eax,0x2
     938:	jmp    956 <botlish_fn_6+0x31>
     93d:	cmp    rsi,0x7a
     941:	jle    951 <botlish_fn_6+0x2c>
     947:	mov    eax,0x2
     94c:	jmp    956 <botlish_fn_6+0x31>
     951:	mov    eax,0x6
     956:	mov    rsp,rbp
     959:	pop    rbp
     95a:	ret

000000000000095b <botlish_entry_6: ascii::is_lower<int>>:
     95b:	push   rbp
     95c:	mov    rbp,rsp
     95f:	mov    rsi,QWORD PTR [rdx]
     962:	sar    rsi,1
     965:	call   96a <botlish_entry_6+0xf>
			966: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     96a:	mov    rsp,rbp
     96d:	pop    rbp
     96e:	ret

000000000000096f <botlish_fn_7: ascii::is_alphabetic<int>>:
     96f:	push   rbp
     970:	mov    rbp,rsp
     973:	sub    rsp,0x10
     977:	mov    QWORD PTR [rsp],r12
     97b:	mov    QWORD PTR [rsp+0x8],r14
     980:	mov    r12,rsi
     983:	mov    r14,rdi
     986:	mov    rsi,r12
     989:	mov    rdi,r14
     98c:	call   991 <botlish_fn_7+0x22>
			98d: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     991:	cmp    rax,0x6
     995:	je     9c4 <botlish_fn_7+0x55>
     99b:	mov    rsi,r12
     99e:	mov    rdi,r14
     9a1:	call   9a6 <botlish_fn_7+0x37>
			9a2: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     9a6:	cmp    rax,0x6
     9aa:	je     9ba <botlish_fn_7+0x4b>
     9b0:	mov    eax,0x2
     9b5:	jmp    9c9 <botlish_fn_7+0x5a>
     9ba:	mov    eax,0x6
     9bf:	jmp    9c9 <botlish_fn_7+0x5a>
     9c4:	mov    eax,0x6
     9c9:	mov    r12,QWORD PTR [rsp]
     9cd:	mov    r14,QWORD PTR [rsp+0x8]
     9d2:	add    rsp,0x10
     9d6:	mov    rsp,rbp
     9d9:	pop    rbp
     9da:	ret

00000000000009db <botlish_entry_7: ascii::is_alphabetic<int>>:
     9db:	push   rbp
     9dc:	mov    rbp,rsp
     9df:	mov    rsi,QWORD PTR [rdx]
     9e2:	sar    rsi,1
     9e5:	call   9ea <botlish_entry_7+0xf>
			9e6: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     9ea:	mov    rsp,rbp
     9ed:	pop    rbp
     9ee:	ret

00000000000009ef <botlish_fn_8: ascii::is_alphanumeric<int>>:
     9ef:	push   rbp
     9f0:	mov    rbp,rsp
     9f3:	sub    rsp,0x10
     9f7:	mov    QWORD PTR [rsp],r12
     9fb:	mov    QWORD PTR [rsp+0x8],r14
     a00:	mov    r12,rsi
     a03:	mov    r14,rdi
     a06:	mov    rsi,r12
     a09:	mov    rdi,r14
     a0c:	call   a11 <botlish_fn_8+0x22>
			a0d: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     a11:	cmp    rax,0x6
     a15:	je     a44 <botlish_fn_8+0x55>
     a1b:	mov    rsi,r12
     a1e:	mov    rdi,r14
     a21:	call   a26 <botlish_fn_8+0x37>
			a22: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     a26:	cmp    rax,0x6
     a2a:	je     a3a <botlish_fn_8+0x4b>
     a30:	mov    eax,0x2
     a35:	jmp    a49 <botlish_fn_8+0x5a>
     a3a:	mov    eax,0x6
     a3f:	jmp    a49 <botlish_fn_8+0x5a>
     a44:	mov    eax,0x6
     a49:	mov    r12,QWORD PTR [rsp]
     a4d:	mov    r14,QWORD PTR [rsp+0x8]
     a52:	add    rsp,0x10
     a56:	mov    rsp,rbp
     a59:	pop    rbp
     a5a:	ret

0000000000000a5b <botlish_entry_8: ascii::is_alphanumeric<int>>:
     a5b:	push   rbp
     a5c:	mov    rbp,rsp
     a5f:	mov    rsi,QWORD PTR [rdx]
     a62:	sar    rsi,1
     a65:	call   a6a <botlish_entry_8+0xf>
			a66: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
     a6a:	mov    rsp,rbp
     a6d:	pop    rbp
     a6e:	ret

0000000000000a6f <botlish_fn_9: web::emailish?<str>>:
     a6f:	push   rbp
     a70:	mov    rbp,rsp
     a73:	sub    rsp,0x50
     a77:	mov    QWORD PTR [rsp+0x30],rbx
     a7c:	mov    QWORD PTR [rsp+0x38],r12
     a81:	mov    QWORD PTR [rsp+0x40],r13
     a86:	mov    QWORD PTR [rsp+0x48],r14
     a8b:	mov    r13,rdi
     a8e:	mov    QWORD PTR [rsp],rsi
     a92:	mov    r12,rsi
     a95:	mov    rsi,r12
     a98:	mov    rdi,r13
     a9b:	call   aa0 <botlish_fn_9+0x31>
			a9c: R_X86_64_PLT32	rt_str_len-0x4
     aa0:	mov    r14,rax
     aa3:	mov    QWORD PTR [rsp+0x8],rax
     aa8:	mov    rdi,r13
     aab:	mov    rax,QWORD PTR [rdi+0x10]
     aaf:	mov    rdx,QWORD PTR [rax+0xc0]
     ab6:	mov    QWORD PTR [rsp+0x10],rdx
     abb:	xor    rsi,rsi
     abe:	mov    rcx,r14
     ac1:	mov    r8,r12
     ac4:	call   ac9 <botlish_fn_9+0x5a>
			ac5: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, block(e239)>
     ac9:	test   rax,rax
     acc:	je     b5e <botlish_fn_9+0xef>
     ad2:	mov    rbx,rax
     ad5:	sar    rbx,1
     ad8:	mov    rsi,rax
     adb:	test   rbx,rbx
     ade:	je     b8d <botlish_fn_9+0x11e>
     ae4:	mov    rax,r14
     ae7:	mov    rcx,rax
     aea:	sar    rcx,1
     aed:	cmp    rbx,rcx
     af0:	jge    b83 <botlish_fn_9+0x114>
     af6:	lea    rcx,[rsp+0x18]
     afb:	mov    rdx,r12
     afe:	mov    rdi,r13
     b01:	call   b06 <botlish_fn_9+0x97>
			b02: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
     b06:	test   rax,rax
     b09:	mov    rsi,rax
     b0c:	je     b5e <botlish_fn_9+0xef>
     b12:	mov    rdx,QWORD PTR [rsp+0x18]
     b17:	mov    rcx,QWORD PTR [rsp+0x20]
     b1c:	mov    rdi,r13
     b1f:	mov    rax,QWORD PTR [rdi+0x10]
     b23:	mov    r8,QWORD PTR [rax+0xc8]
     b2a:	call   b2f <botlish_fn_9+0xc0>
			b2b: R_X86_64_PLT32	rt_str_region_eq-0x4
     b2f:	cmp    rax,0x6
     b33:	je     b43 <botlish_fn_9+0xd4>
     b39:	mov    eax,0x2
     b3e:	jmp    b92 <botlish_fn_9+0x123>
     b43:	lea    rsi,[rbx+0x1]
     b47:	mov    rcx,r12
     b4a:	mov    rdx,r14
     b4d:	mov    rdi,r13
     b50:	call   b55 <botlish_fn_9+0xe6>
			b51: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<int>
     b55:	test   rax,rax
     b58:	jne    b92 <botlish_fn_9+0x123>
     b5e:	xor    rax,rax
     b61:	mov    rbx,QWORD PTR [rsp+0x30]
     b66:	mov    r12,QWORD PTR [rsp+0x38]
     b6b:	mov    r13,QWORD PTR [rsp+0x40]
     b70:	mov    r14,QWORD PTR [rsp+0x48]
     b75:	add    rsp,0x50
     b79:	mov    rsp,rbp
     b7c:	pop    rbp
     b7d:	ret
     b7e:	jmp    b92 <botlish_fn_9+0x123>
     b83:	mov    eax,0x2
     b88:	jmp    b92 <botlish_fn_9+0x123>
     b8d:	mov    eax,0x2
     b92:	mov    rbx,QWORD PTR [rsp+0x30]
     b97:	mov    r12,QWORD PTR [rsp+0x38]
     b9c:	mov    r13,QWORD PTR [rsp+0x40]
     ba1:	mov    r14,QWORD PTR [rsp+0x48]
     ba6:	add    rsp,0x50
     baa:	mov    rsp,rbp
     bad:	pop    rbp
     bae:	ret

0000000000000baf <botlish_entry_9: web::emailish?<str>>:
     baf:	push   rbp
     bb0:	mov    rbp,rsp
     bb3:	mov    rsi,QWORD PTR [rdx]
     bb6:	call   bbb <botlish_entry_9+0xc>
			bb7: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
     bbb:	mov    rsp,rbp
     bbe:	pop    rbp
     bbf:	ret

0000000000000bc0 <botlish_fn_10: char_at<int>>:
     bc0:	push   rbp
     bc1:	mov    rbp,rsp
     bc4:	sub    rsp,0x20
     bc8:	mov    QWORD PTR [rsp],rbx
     bcc:	mov    QWORD PTR [rsp+0x8],r12
     bd1:	mov    QWORD PTR [rsp+0x10],r13
     bd6:	mov    QWORD PTR [rsp+0x18],r15
     bdb:	mov    r13,rdx
     bde:	mov    r15,rcx
     be1:	mov    rax,rsi
     be4:	sar    rax,1
     be7:	lea    r12,[rax+0x1]
     beb:	shl    r12,1
     bee:	mov    rcx,r12
     bf1:	or     rcx,0x1
     bf5:	mov    rbx,rsi
     bf8:	mov    rdx,rbx
     bfb:	mov    rsi,r13
     bfe:	call   c03 <botlish_fn_10+0x43>
			bff: R_X86_64_PLT32	rt_str_region_check-0x4
     c03:	test   rax,rax
     c06:	jne    c2b <botlish_fn_10+0x6b>
     c0c:	xor    rax,rax
     c0f:	mov    rbx,QWORD PTR [rsp]
     c13:	mov    r12,QWORD PTR [rsp+0x8]
     c18:	mov    r13,QWORD PTR [rsp+0x10]
     c1d:	mov    r15,QWORD PTR [rsp+0x18]
     c22:	add    rsp,0x20
     c26:	mov    rsp,rbp
     c29:	pop    rbp
     c2a:	ret
     c2b:	mov    rcx,r15
     c2e:	mov    QWORD PTR [rcx],rbx
     c31:	or     r12,0x1
     c35:	mov    QWORD PTR [rcx+0x8],r12
     c39:	mov    rax,r13
     c3c:	mov    rbx,QWORD PTR [rsp]
     c40:	mov    r12,QWORD PTR [rsp+0x8]
     c45:	mov    r13,QWORD PTR [rsp+0x10]
     c4a:	mov    r15,QWORD PTR [rsp+0x18]
     c4f:	add    rsp,0x20
     c53:	mov    rsp,rbp
     c56:	pop    rbp
     c57:	ret

0000000000000c58 <botlish_entry_10: char_at<int>>:
     c58:	push   rbp
     c59:	mov    rbp,rsp
     c5c:	ud2

0000000000000c5e <botlish_fn_11: char_at<int>>:
     c5e:	push   rbp
     c5f:	mov    rbp,rsp
     c62:	sub    rsp,0x20
     c66:	mov    QWORD PTR [rsp],rsi
     c6a:	mov    QWORD PTR [rsp+0x8],rdx
     c6f:	mov    rax,rsi
     c72:	sar    rax,1
     c75:	lea    rcx,[rax+0x1]
     c79:	shl    rcx,1
     c7c:	or     rcx,0x1
     c80:	mov    QWORD PTR [rsp+0x10],rcx
     c85:	mov    rax,rdx
     c88:	mov    rdx,rsi
     c8b:	mov    rsi,rax
     c8e:	call   c93 <botlish_fn_11+0x35>
			c8f: R_X86_64_PLT32	rt_substr-0x4
     c93:	test   rax,rax
     c96:	jne    ca8 <botlish_fn_11+0x4a>
     c9c:	xor    rax,rax
     c9f:	add    rsp,0x20
     ca3:	mov    rsp,rbp
     ca6:	pop    rbp
     ca7:	ret
     ca8:	add    rsp,0x20
     cac:	mov    rsp,rbp
     caf:	pop    rbp
     cb0:	ret

0000000000000cb1 <botlish_entry_11: char_at<int>>:
     cb1:	push   rbp
     cb2:	mov    rbp,rsp
     cb5:	mov    rsi,QWORD PTR [rdx]
     cb8:	mov    rdx,QWORD PTR [rdx+0x8]
     cbc:	call   cc1 <botlish_entry_11+0x10>
			cbd: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<int>
     cc1:	mov    rsp,rbp
     cc4:	pop    rbp
     cc5:	ret

0000000000000cc6 <botlish_fn_12: local_char?<str>>:
     cc6:	push   rbp
     cc7:	mov    rbp,rsp
     cca:	sub    rsp,0x10
     cce:	mov    QWORD PTR [rsp],rbx
     cd2:	mov    QWORD PTR [rsp+0x8],r14
     cd7:	mov    rbx,rdi
     cda:	mov    r14,rsi
     cdd:	mov    rsi,r14
     ce0:	mov    rdi,rbx
     ce3:	call   ce8 <botlish_fn_12+0x22>
			ce4: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     ce8:	test   rax,rax
     ceb:	jne    d06 <botlish_fn_12+0x40>
     cf1:	xor    rax,rax
     cf4:	mov    rbx,QWORD PTR [rsp]
     cf8:	mov    r14,QWORD PTR [rsp+0x8]
     cfd:	add    rsp,0x10
     d01:	mov    rsp,rbp
     d04:	pop    rbp
     d05:	ret
     d06:	cmp    rax,0x6
     d0a:	je     d40 <botlish_fn_12+0x7a>
     d10:	mov    rdi,rbx
     d13:	mov    rax,QWORD PTR [rdi+0x30]
     d17:	mov    rsi,QWORD PTR [rax]
     d1a:	mov    rdx,r14
     d1d:	call   d22 <botlish_fn_12+0x5c>
			d1e: R_X86_64_PLT32	rt_set_contains-0x4
     d22:	cmp    rax,0x6
     d26:	je     d36 <botlish_fn_12+0x70>
     d2c:	mov    eax,0x2
     d31:	jmp    d45 <botlish_fn_12+0x7f>
     d36:	mov    eax,0x6
     d3b:	jmp    d45 <botlish_fn_12+0x7f>
     d40:	mov    eax,0x6
     d45:	mov    rbx,QWORD PTR [rsp]
     d49:	mov    r14,QWORD PTR [rsp+0x8]
     d4e:	add    rsp,0x10
     d52:	mov    rsp,rbp
     d55:	pop    rbp
     d56:	ret

0000000000000d57 <botlish_entry_12: local_char?<str>>:
     d57:	push   rbp
     d58:	mov    rbp,rsp
     d5b:	mov    rsi,QWORD PTR [rdx]
     d5e:	call   d63 <botlish_entry_12+0xc>
			d5f: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     d63:	mov    rsp,rbp
     d66:	pop    rbp
     d67:	ret

0000000000000d68 <botlish_fn_13: local_char?<generic>>:
     d68:	push   rbp
     d69:	mov    rbp,rsp
     d6c:	sub    rsp,0x10
     d70:	mov    QWORD PTR [rsp],rbx
     d74:	mov    QWORD PTR [rsp+0x8],r12
     d79:	xor    r8d,r8d
     d7c:	test   rsi,0x7
     d83:	jne    d93 <botlish_fn_13+0x2b>
     d89:	movzx  rax,BYTE PTR [rsi]
     d8d:	cmp    al,0x2
     d8f:	sete   r8b
     d93:	test   r8b,r8b
     d96:	jne    db6 <botlish_fn_13+0x4e>
     d9c:	mov    rax,QWORD PTR [rdi+0x10]
     da0:	mov    rcx,QWORD PTR [rax+0xd0]
     da7:	mov    edx,0x1
     dac:	call   db1 <botlish_fn_13+0x49>
			dad: R_X86_64_PLT32	rt_type_error-0x4
     db1:	jmp    dca <botlish_fn_13+0x62>
     db6:	mov    rbx,rsi
     db9:	mov    r12,rdi
     dbc:	call   dc1 <botlish_fn_13+0x59>
			dbd: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     dc1:	test   rax,rax
     dc4:	jne    ddf <botlish_fn_13+0x77>
     dca:	xor    rax,rax
     dcd:	mov    rbx,QWORD PTR [rsp]
     dd1:	mov    r12,QWORD PTR [rsp+0x8]
     dd6:	add    rsp,0x10
     dda:	mov    rsp,rbp
     ddd:	pop    rbp
     dde:	ret
     ddf:	cmp    rax,0x6
     de3:	je     e19 <botlish_fn_13+0xb1>
     de9:	mov    rdi,r12
     dec:	mov    rax,QWORD PTR [rdi+0x30]
     df0:	mov    rsi,QWORD PTR [rax]
     df3:	mov    rdx,rbx
     df6:	call   dfb <botlish_fn_13+0x93>
			df7: R_X86_64_PLT32	rt_set_contains-0x4
     dfb:	cmp    rax,0x6
     dff:	je     e0f <botlish_fn_13+0xa7>
     e05:	mov    eax,0x2
     e0a:	jmp    e1e <botlish_fn_13+0xb6>
     e0f:	mov    eax,0x6
     e14:	jmp    e1e <botlish_fn_13+0xb6>
     e19:	mov    eax,0x6
     e1e:	mov    rbx,QWORD PTR [rsp]
     e22:	mov    r12,QWORD PTR [rsp+0x8]
     e27:	add    rsp,0x10
     e2b:	mov    rsp,rbp
     e2e:	pop    rbp
     e2f:	ret

0000000000000e30 <botlish_entry_13: local_char?<generic>>:
     e30:	push   rbp
     e31:	mov    rbp,rsp
     e34:	mov    rsi,QWORD PTR [rdx]
     e37:	call   e3c <botlish_entry_13+0xc>
			e38: R_X86_64_PLT32	botlish_fn_13-0x4 ; local_char?<generic>
     e3c:	mov    rsp,rbp
     e3f:	pop    rbp
     e40:	ret

0000000000000e41 <botlish_fn_14: scan_while<int, block(e239)>>:
     e41:	push   rbp
     e42:	mov    rbp,rsp
     e45:	sub    rsp,0x50
     e49:	mov    QWORD PTR [rsp+0x20],rbx
     e4e:	mov    QWORD PTR [rsp+0x28],r12
     e53:	mov    QWORD PTR [rsp+0x30],r13
     e58:	mov    QWORD PTR [rsp+0x38],r14
     e5d:	mov    QWORD PTR [rsp+0x40],r15
     e62:	mov    QWORD PTR [rsp+0x18],rdi
     e67:	mov    QWORD PTR [rsp],rcx
     e6b:	mov    QWORD PTR [rsp+0x8],r8
     e70:	mov    r15,r8
     e73:	mov    r12,rcx
     e76:	sar    r12,1
     e79:	mov    r14,rcx
     e7c:	mov    rbx,rsi
     e7f:	cmp    rbx,r12
     e82:	jl     ead <botlish_fn_14+0x6c>
     e88:	mov    rax,r14
     e8b:	mov    rbx,QWORD PTR [rsp+0x20]
     e90:	mov    r12,QWORD PTR [rsp+0x28]
     e95:	mov    r13,QWORD PTR [rsp+0x30]
     e9a:	mov    r14,QWORD PTR [rsp+0x38]
     e9f:	mov    r15,QWORD PTR [rsp+0x40]
     ea4:	add    rsp,0x50
     ea8:	mov    rsp,rbp
     eab:	pop    rbp
     eac:	ret
     ead:	mov    r13,rbx
     eb0:	shl    r13,1
     eb3:	or     r13,0x1
     eb7:	mov    QWORD PTR [rsp+0x10],r13
     ebc:	mov    rdx,r15
     ebf:	mov    rsi,r13
     ec2:	mov    rdi,QWORD PTR [rsp+0x18]
     ec7:	call   ecc <botlish_fn_14+0x8b>
			ec8: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<int>
     ecc:	test   rax,rax
     ecf:	mov    rsi,rax
     ed2:	je     eeb <botlish_fn_14+0xaa>
     ed8:	mov    rdi,QWORD PTR [rsp+0x18]
     edd:	call   ee2 <botlish_fn_14+0xa1>
			ede: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     ee2:	test   rax,rax
     ee5:	jne    f10 <botlish_fn_14+0xcf>
     eeb:	xor    rax,rax
     eee:	mov    rbx,QWORD PTR [rsp+0x20]
     ef3:	mov    r12,QWORD PTR [rsp+0x28]
     ef8:	mov    r13,QWORD PTR [rsp+0x30]
     efd:	mov    r14,QWORD PTR [rsp+0x38]
     f02:	mov    r15,QWORD PTR [rsp+0x40]
     f07:	add    rsp,0x50
     f0b:	mov    rsp,rbp
     f0e:	pop    rbp
     f0f:	ret
     f10:	cmp    rax,0x6
     f14:	je     f3f <botlish_fn_14+0xfe>
     f1a:	mov    rax,r13
     f1d:	mov    rbx,QWORD PTR [rsp+0x20]
     f22:	mov    r12,QWORD PTR [rsp+0x28]
     f27:	mov    r13,QWORD PTR [rsp+0x30]
     f2c:	mov    r14,QWORD PTR [rsp+0x38]
     f31:	mov    r15,QWORD PTR [rsp+0x40]
     f36:	add    rsp,0x50
     f3a:	mov    rsp,rbp
     f3d:	pop    rbp
     f3e:	ret
     f3f:	add    rbx,0x1
     f46:	jmp    e7f <botlish_fn_14+0x3e>

0000000000000f4b <botlish_entry_14: scan_while<int, block(e239)>>:
     f4b:	push   rbp
     f4c:	mov    rbp,rsp
     f4f:	mov    rsi,QWORD PTR [rdx]
     f52:	mov    r9,QWORD PTR [rdx+0x8]
     f56:	mov    rcx,QWORD PTR [rdx+0x10]
     f5a:	mov    r8,QWORD PTR [rdx+0x18]
     f5e:	sar    rsi,1
     f61:	mov    rdx,r9
     f64:	call   f69 <botlish_entry_14+0x1e>
			f65: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, block(e239)>
     f69:	mov    rsp,rbp
     f6c:	pop    rbp
     f6d:	ret

0000000000000f6e <botlish_fn_15: scan_while<int, native(is_tcl_alpha)>>:
     f6e:	push   rbp
     f6f:	mov    rbp,rsp
     f72:	sub    rsp,0x30
     f76:	mov    QWORD PTR [rsp+0x10],rbx
     f7b:	mov    QWORD PTR [rsp+0x18],r12
     f80:	mov    QWORD PTR [rsp+0x20],r13
     f85:	mov    QWORD PTR [rsp+0x28],r14
     f8a:	mov    rbx,r8
     f8d:	mov    r12,rdi
     f90:	mov    rax,rcx
     f93:	sar    rax,1
     f96:	mov    r13,rax
     f99:	mov    rax,rsi
     f9c:	mov    rcx,r13
     f9f:	cmp    rax,rcx
     fa2:	mov    r13,rcx
     fa5:	jl     fd0 <botlish_fn_15+0x62>
     fab:	mov    edx,0x1
     fb0:	mov    rax,r13
     fb3:	mov    rbx,QWORD PTR [rsp+0x10]
     fb8:	mov    r12,QWORD PTR [rsp+0x18]
     fbd:	mov    r13,QWORD PTR [rsp+0x20]
     fc2:	mov    r14,QWORD PTR [rsp+0x28]
     fc7:	add    rsp,0x30
     fcb:	mov    rsp,rbp
     fce:	pop    rbp
     fcf:	ret
     fd0:	mov    rsi,rax
     fd3:	shl    rsi,1
     fd6:	mov    r14,rax
     fd9:	or     rsi,0x1
     fdd:	lea    rcx,[rsp]
     fe1:	mov    rdx,rbx
     fe4:	mov    rdi,r12
     fe7:	call   fec <botlish_fn_15+0x7e>
			fe8: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
     fec:	test   rax,rax
     fef:	mov    rsi,rax
     ff2:	je     1012 <botlish_fn_15+0xa4>
     ff8:	mov    rdx,QWORD PTR [rsp]
     ffc:	mov    rcx,QWORD PTR [rsp+0x8]
    1001:	mov    rdi,r12
    1004:	call   1009 <botlish_fn_15+0x9b>
			1005: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    1009:	test   rax,rax
    100c:	jne    1035 <botlish_fn_15+0xc7>
    1012:	xor    rdx,rdx
    1015:	mov    rax,rdx
    1018:	mov    rbx,QWORD PTR [rsp+0x10]
    101d:	mov    r12,QWORD PTR [rsp+0x18]
    1022:	mov    r13,QWORD PTR [rsp+0x20]
    1027:	mov    r14,QWORD PTR [rsp+0x28]
    102c:	add    rsp,0x30
    1030:	mov    rsp,rbp
    1033:	pop    rbp
    1034:	ret
    1035:	cmp    rax,0x6
    1039:	je     1064 <botlish_fn_15+0xf6>
    103f:	mov    edx,0x1
    1044:	mov    rax,r14
    1047:	mov    rbx,QWORD PTR [rsp+0x10]
    104c:	mov    r12,QWORD PTR [rsp+0x18]
    1051:	mov    r13,QWORD PTR [rsp+0x20]
    1056:	mov    r14,QWORD PTR [rsp+0x28]
    105b:	add    rsp,0x30
    105f:	mov    rsp,rbp
    1062:	pop    rbp
    1063:	ret
    1064:	mov    rax,r14
    1067:	add    rax,0x1
    106e:	mov    rcx,r13
    1071:	jmp    f9f <botlish_fn_15+0x31>

0000000000001076 <botlish_entry_15: scan_while<int, native(is_tcl_alpha)>>:
    1076:	push   rbp
    1077:	mov    rbp,rsp
    107a:	mov    rsi,QWORD PTR [rdx]
    107d:	mov    rax,QWORD PTR [rdx+0x8]
    1081:	mov    rcx,QWORD PTR [rdx+0x10]
    1085:	mov    r8,QWORD PTR [rdx+0x18]
    1089:	sar    rsi,1
    108c:	mov    rdx,rax
    108f:	call   1094 <botlish_entry_15+0x1e>
			1090: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<int, native(is_tcl_alpha)>
    1094:	shl    rax,1
    1097:	or     rax,0x1
    109b:	mov    rcx,rax
    109e:	xor    rax,rax
    10a1:	test   rdx,rdx
    10a4:	cmovne rax,rcx
    10a8:	mov    rsp,rbp
    10ab:	pop    rbp
    10ac:	ret
    10ad:	add    BYTE PTR [rax],al
	...

00000000000010b0 <botlish_fn_16: tld?<int>>:
    10b0:	push   rbp
    10b1:	mov    rbp,rsp
    10b4:	sub    rsp,0x10
    10b8:	mov    QWORD PTR [rsp],rbx
    10bc:	mov    QWORD PTR [rsp+0x8],r12
    10c1:	mov    r8,rdx
    10c4:	mov    rax,QWORD PTR [rdi+0x10]
    10c8:	mov    rdx,QWORD PTR [rax+0xd8]
    10cf:	mov    r12,r8
    10d2:	mov    r8,rcx
    10d5:	mov    rbx,rsi
    10d8:	mov    rcx,r12
    10db:	call   10e0 <botlish_fn_16+0x30>
			10dc: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<int, native(is_tcl_alpha)>
    10e0:	test   rdx,rdx
    10e3:	jne    10fe <botlish_fn_16+0x4e>
    10e9:	xor    rax,rax
    10ec:	mov    rbx,QWORD PTR [rsp]
    10f0:	mov    r12,QWORD PTR [rsp+0x8]
    10f5:	add    rsp,0x10
    10f9:	mov    rsp,rbp
    10fc:	pop    rbp
    10fd:	ret
    10fe:	sar    r12,1
    1101:	cmp    rax,r12
    1104:	je     1114 <botlish_fn_16+0x64>
    110a:	mov    eax,0x2
    110f:	jmp    112b <botlish_fn_16+0x7b>
    1114:	sub    rax,rbx
    1117:	mov    rcx,rax
    111a:	mov    eax,0x2
    111f:	cmp    rcx,0x2
    1123:	cmovge rax,QWORD PTR [rip+0x15]        # 1140 <botlish_fn_16+0x90>
    112b:	mov    rbx,QWORD PTR [rsp]
    112f:	mov    r12,QWORD PTR [rsp+0x8]
    1134:	add    rsp,0x10
    1138:	mov    rsp,rbp
    113b:	pop    rbp
    113c:	ret
    113d:	add    BYTE PTR [rax],al
    113f:	add    BYTE PTR [rsi],al
    1141:	add    BYTE PTR [rax],al
    1143:	add    BYTE PTR [rax],al
    1145:	add    BYTE PTR [rax],al
	...

0000000000001148 <botlish_entry_16: tld?<int>>:
    1148:	push   rbp
    1149:	mov    rbp,rsp
    114c:	mov    rsi,QWORD PTR [rdx]
    114f:	mov    r8,QWORD PTR [rdx+0x8]
    1153:	mov    rcx,QWORD PTR [rdx+0x10]
    1157:	sar    rsi,1
    115a:	mov    rdx,r8
    115d:	call   1162 <botlish_entry_16+0x1a>
			115e: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<int>
    1162:	mov    rsp,rbp
    1165:	pop    rbp
    1166:	ret

0000000000001167 <botlish_fn_17: domain?<int>>:
    1167:	push   rbp
    1168:	mov    rbp,rsp
    116b:	sub    rsp,0x80
    1172:	mov    QWORD PTR [rsp+0x50],rbx
    1177:	mov    QWORD PTR [rsp+0x58],r12
    117c:	mov    QWORD PTR [rsp+0x60],r13
    1181:	mov    QWORD PTR [rsp+0x68],r14
    1186:	mov    QWORD PTR [rsp+0x70],r15
    118b:	mov    rbx,rsi
    118e:	mov    r15,rcx
    1191:	mov    r14,rdx
    1194:	sar    r14,1
    1197:	mov    QWORD PTR [rsp+0x30],rdx
    119c:	mov    r12,rbx
    119f:	cmp    r12,r14
    11a2:	jl     11d2 <botlish_fn_17+0x6b>
    11a8:	mov    eax,0x2
    11ad:	mov    rbx,QWORD PTR [rsp+0x50]
    11b2:	mov    r12,QWORD PTR [rsp+0x58]
    11b7:	mov    r13,QWORD PTR [rsp+0x60]
    11bc:	mov    r14,QWORD PTR [rsp+0x68]
    11c1:	mov    r15,QWORD PTR [rsp+0x70]
    11c6:	add    rsp,0x80
    11cd:	mov    rsp,rbp
    11d0:	pop    rbp
    11d1:	ret
    11d2:	mov    rsi,r12
    11d5:	shl    rsi,1
    11d8:	or     rsi,0x1
    11dc:	mov    QWORD PTR [rsp+0x48],rsi
    11e1:	lea    rcx,[rsp]
    11e5:	mov    r13,rdi
    11e8:	mov    rdx,r15
    11eb:	call   11f0 <botlish_fn_17+0x89>
			11ec: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    11f0:	test   rax,rax
    11f3:	mov    rsi,rax
    11f6:	je     1378 <botlish_fn_17+0x211>
    11fc:	mov    rdx,QWORD PTR [rsp]
    1200:	mov    rcx,QWORD PTR [rsp+0x8]
    1205:	mov    rax,QWORD PTR [r13+0x10]
    1209:	mov    r8,QWORD PTR [rax]
    120c:	mov    rdi,r13
    120f:	call   1214 <botlish_fn_17+0xad>
			1210: R_X86_64_PLT32	rt_str_region_eq-0x4
    1214:	cmp    rax,0x6
    1218:	je     1304 <botlish_fn_17+0x19d>
    121e:	lea    rcx,[rsp+0x20]
    1223:	mov    rsi,QWORD PTR [rsp+0x48]
    1228:	mov    rdx,r15
    122b:	mov    rdi,r13
    122e:	call   1233 <botlish_fn_17+0xcc>
			122f: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    1233:	test   rax,rax
    1236:	mov    QWORD PTR [rsp+0x48],rax
    123b:	je     1378 <botlish_fn_17+0x211>
    1241:	mov    rdx,QWORD PTR [rsp+0x20]
    1246:	mov    QWORD PTR [rsp+0x40],rdx
    124b:	mov    rcx,QWORD PTR [rsp+0x28]
    1250:	mov    QWORD PTR [rsp+0x38],rcx
    1255:	mov    rsi,QWORD PTR [rsp+0x48]
    125a:	mov    rdi,r13
    125d:	call   1262 <botlish_fn_17+0xfb>
			125e: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1262:	test   rax,rax
    1265:	je     1378 <botlish_fn_17+0x211>
    126b:	cmp    rax,0x6
    126f:	je     12b2 <botlish_fn_17+0x14b>
    1275:	mov    rdi,QWORD PTR [r13+0x10]
    1279:	mov    r8,QWORD PTR [rdi+0x20]
    127d:	mov    rcx,QWORD PTR [rsp+0x38]
    1282:	mov    rdx,QWORD PTR [rsp+0x40]
    1287:	mov    rsi,QWORD PTR [rsp+0x48]
    128c:	mov    rdi,r13
    128f:	call   1294 <botlish_fn_17+0x12d>
			1290: R_X86_64_PLT32	rt_str_region_eq-0x4
    1294:	cmp    rax,0x6
    1298:	je     12a8 <botlish_fn_17+0x141>
    129e:	mov    ecx,0x2
    12a3:	jmp    12b7 <botlish_fn_17+0x150>
    12a8:	mov    ecx,0x6
    12ad:	jmp    12b7 <botlish_fn_17+0x150>
    12b2:	mov    ecx,0x6
    12b7:	cmp    rcx,0x6
    12bb:	je     12cb <botlish_fn_17+0x164>
    12c1:	mov    eax,0x6
    12c6:	jmp    12d0 <botlish_fn_17+0x169>
    12cb:	mov    eax,0x2
    12d0:	cmp    rax,0x6
    12d4:	jne    13aa <botlish_fn_17+0x243>
    12da:	mov    eax,0x2
    12df:	mov    rbx,QWORD PTR [rsp+0x50]
    12e4:	mov    r12,QWORD PTR [rsp+0x58]
    12e9:	mov    r13,QWORD PTR [rsp+0x60]
    12ee:	mov    r14,QWORD PTR [rsp+0x68]
    12f3:	mov    r15,QWORD PTR [rsp+0x70]
    12f8:	add    rsp,0x80
    12ff:	mov    rsp,rbp
    1302:	pop    rbp
    1303:	ret
    1304:	cmp    r12,rbx
    1307:	je     140d <botlish_fn_17+0x2a6>
    130d:	mov    rsi,r12
    1310:	sub    rsi,0x1
    1314:	shl    rsi,1
    1317:	or     rsi,0x1
    131b:	lea    rcx,[rsp+0x10]
    1320:	mov    rdx,r15
    1323:	mov    rdi,r13
    1326:	call   132b <botlish_fn_17+0x1c4>
			1327: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    132b:	test   rax,rax
    132e:	mov    rsi,rax
    1331:	je     1378 <botlish_fn_17+0x211>
    1337:	mov    rdx,QWORD PTR [rsp+0x10]
    133c:	mov    rcx,QWORD PTR [rsp+0x18]
    1341:	mov    rax,QWORD PTR [r13+0x10]
    1345:	mov    r8,QWORD PTR [rax]
    1348:	mov    rdi,r13
    134b:	call   1350 <botlish_fn_17+0x1e9>
			134c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1350:	cmp    rax,0x6
    1354:	je     13e3 <botlish_fn_17+0x27c>
    135a:	lea    rsi,[r12+0x1]
    135f:	mov    rcx,r15
    1362:	mov    rdx,QWORD PTR [rsp+0x30]
    1367:	mov    rdi,r13
    136a:	call   136f <botlish_fn_17+0x208>
			136b: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<int>
    136f:	test   rax,rax
    1372:	jne    13a0 <botlish_fn_17+0x239>
    1378:	xor    rax,rax
    137b:	mov    rbx,QWORD PTR [rsp+0x50]
    1380:	mov    r12,QWORD PTR [rsp+0x58]
    1385:	mov    r13,QWORD PTR [rsp+0x60]
    138a:	mov    r14,QWORD PTR [rsp+0x68]
    138f:	mov    r15,QWORD PTR [rsp+0x70]
    1394:	add    rsp,0x80
    139b:	mov    rsp,rbp
    139e:	pop    rbp
    139f:	ret
    13a0:	cmp    rax,0x6
    13a4:	je     13b9 <botlish_fn_17+0x252>
    13aa:	add    r12,0x1
    13b1:	mov    rdi,r13
    13b4:	jmp    119f <botlish_fn_17+0x38>
    13b9:	mov    eax,0x6
    13be:	mov    rbx,QWORD PTR [rsp+0x50]
    13c3:	mov    r12,QWORD PTR [rsp+0x58]
    13c8:	mov    r13,QWORD PTR [rsp+0x60]
    13cd:	mov    r14,QWORD PTR [rsp+0x68]
    13d2:	mov    r15,QWORD PTR [rsp+0x70]
    13d7:	add    rsp,0x80
    13de:	mov    rsp,rbp
    13e1:	pop    rbp
    13e2:	ret
    13e3:	mov    eax,0x2
    13e8:	mov    rbx,QWORD PTR [rsp+0x50]
    13ed:	mov    r12,QWORD PTR [rsp+0x58]
    13f2:	mov    r13,QWORD PTR [rsp+0x60]
    13f7:	mov    r14,QWORD PTR [rsp+0x68]
    13fc:	mov    r15,QWORD PTR [rsp+0x70]
    1401:	add    rsp,0x80
    1408:	mov    rsp,rbp
    140b:	pop    rbp
    140c:	ret
    140d:	mov    eax,0x2
    1412:	mov    rbx,QWORD PTR [rsp+0x50]
    1417:	mov    r12,QWORD PTR [rsp+0x58]
    141c:	mov    r13,QWORD PTR [rsp+0x60]
    1421:	mov    r14,QWORD PTR [rsp+0x68]
    1426:	mov    r15,QWORD PTR [rsp+0x70]
    142b:	add    rsp,0x80
    1432:	mov    rsp,rbp
    1435:	pop    rbp
    1436:	ret

0000000000001437 <botlish_entry_17: domain?<int>>:
    1437:	push   rbp
    1438:	mov    rbp,rsp
    143b:	mov    rsi,QWORD PTR [rdx]
    143e:	mov    r8,QWORD PTR [rdx+0x8]
    1442:	mov    rcx,QWORD PTR [rdx+0x10]
    1446:	sar    rsi,1
    1449:	mov    rdx,r8
    144c:	call   1451 <botlish_entry_17+0x1a>
			144d: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<int>
    1451:	mov    rsp,rbp
    1454:	pop    rbp
    1455:	ret

0000000000001456 <botlish_fn_18: web::is_unreserved<int>>:
    1456:	push   rbp
    1457:	mov    rbp,rsp
    145a:	sub    rsp,0x10
    145e:	mov    QWORD PTR [rsp],rbx
    1462:	mov    QWORD PTR [rsp+0x8],r14
    1467:	mov    r14,rsi
    146a:	mov    rsi,r14
    146d:	sar    rsi,1
    1470:	mov    rbx,rdi
    1473:	call   1478 <botlish_fn_18+0x22>
			1474: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
    1478:	cmp    rax,0x6
    147c:	je     14b3 <botlish_fn_18+0x5d>
    1482:	mov    rax,QWORD PTR [rbx+0x30]
    1486:	mov    rsi,QWORD PTR [rax+0x10]
    148a:	mov    rdx,r14
    148d:	mov    rdi,rbx
    1490:	call   1495 <botlish_fn_18+0x3f>
			1491: R_X86_64_PLT32	rt_set_contains-0x4
    1495:	cmp    rax,0x6
    1499:	je     14a9 <botlish_fn_18+0x53>
    149f:	mov    eax,0x2
    14a4:	jmp    14b8 <botlish_fn_18+0x62>
    14a9:	mov    eax,0x6
    14ae:	jmp    14b8 <botlish_fn_18+0x62>
    14b3:	mov    eax,0x6
    14b8:	mov    rbx,QWORD PTR [rsp]
    14bc:	mov    r14,QWORD PTR [rsp+0x8]
    14c1:	add    rsp,0x10
    14c5:	mov    rsp,rbp
    14c8:	pop    rbp
    14c9:	ret

00000000000014ca <botlish_entry_18: web::is_unreserved<int>>:
    14ca:	push   rbp
    14cb:	mov    rbp,rsp
    14ce:	mov    rsi,QWORD PTR [rdx]
    14d1:	call   14d6 <botlish_entry_18+0xc>
			14d2: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    14d6:	mov    rsp,rbp
    14d9:	pop    rbp
    14da:	ret

00000000000014db <botlish_fn_19: web::uri_escape_text<str>>:
    14db:	push   rbp
    14dc:	mov    rbp,rsp
    14df:	sub    rsp,0x10
    14e3:	mov    edx,0x1
    14e8:	mov    QWORD PTR [rsp],0x1
    14f0:	mov    r10,QWORD PTR [rdi+0x10]
    14f4:	mov    rcx,QWORD PTR [r10+0xe0]
    14fb:	mov    QWORD PTR [rsp+0x8],rcx
    1500:	call   1505 <botlish_fn_19+0x2a>
			1501: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    1505:	test   rax,rax
    1508:	jne    151a <botlish_fn_19+0x3f>
    150e:	xor    rax,rax
    1511:	add    rsp,0x10
    1515:	mov    rsp,rbp
    1518:	pop    rbp
    1519:	ret
    151a:	add    rsp,0x10
    151e:	mov    rsp,rbp
    1521:	pop    rbp
    1522:	ret

0000000000001523 <botlish_entry_19: web::uri_escape_text<str>>:
    1523:	push   rbp
    1524:	mov    rbp,rsp
    1527:	sub    rsp,0x10
    152b:	mov    QWORD PTR [rsp],r12
    152f:	mov    r12,rdi
    1532:	mov    rsi,QWORD PTR [rdx]
    1535:	mov    r8,QWORD PTR [rip+0x0]        # 153c <botlish_entry_19+0x19>
			1538: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    153c:	call   r8
    153f:	mov    rsi,rax
    1542:	mov    rdi,r12
    1545:	call   154a <botlish_entry_19+0x27>
			1546: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_escape_text<str>
    154a:	mov    r12,QWORD PTR [rsp]
    154e:	add    rsp,0x10
    1552:	mov    rsp,rbp
    1555:	pop    rbp
    1556:	ret

0000000000001557 <botlish_fn_20: high_nibble<int>>:
    1557:	push   rbp
    1558:	mov    rbp,rsp
    155b:	sub    rsp,0x10
    155f:	mov    QWORD PTR [rsp],rsi
    1563:	mov    QWORD PTR [rsp+0x8],0x1e1
    156c:	test   rsi,0x1
    1573:	jne    1588 <botlish_fn_20+0x31>
    1579:	mov    edx,0x1e1
    157e:	call   1583 <botlish_fn_20+0x2c>
			157f: R_X86_64_PLT32	rt_int_and-0x4
    1583:	jmp    1592 <botlish_fn_20+0x3b>
    1588:	and    rsi,0x1e1
    158f:	mov    rax,rsi
    1592:	sar    rax,0x5
    1596:	shl    rax,1
    1599:	or     rax,0x1
    159d:	add    rsp,0x10
    15a1:	mov    rsp,rbp
    15a4:	pop    rbp
    15a5:	ret

00000000000015a6 <botlish_entry_20: high_nibble<int>>:
    15a6:	push   rbp
    15a7:	mov    rbp,rsp
    15aa:	mov    rsi,QWORD PTR [rdx]
    15ad:	call   15b2 <botlish_entry_20+0xc>
			15ae: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    15b2:	mov    rsp,rbp
    15b5:	pop    rbp
    15b6:	ret

00000000000015b7 <botlish_fn_21: hex_pair<int>>:
    15b7:	push   rbp
    15b8:	mov    rbp,rsp
    15bb:	sub    rsp,0x50
    15bf:	mov    QWORD PTR [rsp+0x30],rbx
    15c4:	mov    QWORD PTR [rsp+0x38],r12
    15c9:	mov    QWORD PTR [rsp+0x40],r13
    15ce:	mov    QWORD PTR [rsp+0x48],r14
    15d3:	mov    QWORD PTR [rsp],rsi
    15d7:	mov    r12,rsi
    15da:	mov    rax,QWORD PTR [rdi+0x30]
    15de:	mov    rbx,rdi
    15e1:	mov    rsi,QWORD PTR [rax+0x8]
    15e5:	mov    QWORD PTR [rsp+0x8],rsi
    15ea:	mov    r13,rsi
    15ed:	mov    rsi,r12
    15f0:	call   15f5 <botlish_fn_21+0x3e>
			15f1: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    15f5:	test   rax,0x1
    15fb:	jne    160c <botlish_fn_21+0x55>
    1601:	mov    rdx,rax
    1604:	mov    rsi,r13
    1607:	jmp    1625 <botlish_fn_21+0x6e>
    160c:	mov    rsi,r13
    160f:	mov    rdx,QWORD PTR [rsi+0x8]
    1613:	mov    rcx,rax
    1616:	sar    rcx,1
    1619:	cmp    rcx,rdx
    161c:	jb     163b <botlish_fn_21+0x84>
    1622:	mov    rdx,rax
    1625:	mov    rdi,rbx
    1628:	call   162d <botlish_fn_21+0x76>
			1629: R_X86_64_PLT32	rt_list_get-0x4
    162d:	test   rax,rax
    1630:	je     1700 <botlish_fn_21+0x149>
    1636:	jmp    1643 <botlish_fn_21+0x8c>
    163b:	mov    rax,QWORD PTR [rsi+0x10]
    163f:	mov    rax,QWORD PTR [rax+rcx*8]
    1643:	mov    QWORD PTR [rsp],rax
    1647:	mov    rdi,rbx
    164a:	mov    r14,rax
    164d:	mov    rax,QWORD PTR [rdi+0x30]
    1651:	mov    rsi,QWORD PTR [rax+0x8]
    1655:	mov    r13,rsi
    1658:	mov    edx,0x21
    165d:	mov    rsi,r12
    1660:	call   1665 <botlish_fn_21+0xae>
			1661: R_X86_64_PLT32	rt_int_mod-0x4
    1665:	test   rax,rax
    1668:	je     1700 <botlish_fn_21+0x149>
    166e:	test   rax,0x1
    1674:	jne    1685 <botlish_fn_21+0xce>
    167a:	mov    rdx,rax
    167d:	mov    rsi,r13
    1680:	jmp    169e <botlish_fn_21+0xe7>
    1685:	mov    rsi,r13
    1688:	mov    rdx,QWORD PTR [rsi+0x8]
    168c:	mov    rcx,rax
    168f:	sar    rcx,1
    1692:	cmp    rcx,rdx
    1695:	jb     16b4 <botlish_fn_21+0xfd>
    169b:	mov    rdx,rax
    169e:	mov    rdi,rbx
    16a1:	call   16a6 <botlish_fn_21+0xef>
			16a2: R_X86_64_PLT32	rt_list_get-0x4
    16a6:	test   rax,rax
    16a9:	je     1700 <botlish_fn_21+0x149>
    16af:	jmp    16bc <botlish_fn_21+0x105>
    16b4:	mov    rax,QWORD PTR [rsi+0x10]
    16b8:	mov    rax,QWORD PTR [rax+rcx*8]
    16bc:	mov    QWORD PTR [rsp+0x8],rax
    16c1:	lea    rcx,[rsp+0x10]
    16c6:	mov    QWORD PTR [rsp+0x10],0x0
    16cf:	mov    rdx,r14
    16d2:	mov    QWORD PTR [rsp+0x18],rdx
    16d7:	mov    QWORD PTR [rsp+0x20],0x0
    16e0:	mov    QWORD PTR [rsp+0x28],rax
    16e5:	mov    esi,0x2
    16ea:	mov    edx,0x4
    16ef:	mov    rdi,rbx
    16f2:	call   16f7 <botlish_fn_21+0x140>
			16f3: R_X86_64_PLT32	rt_construct-0x4
    16f7:	test   rax,rax
    16fa:	jne    1720 <botlish_fn_21+0x169>
    1700:	xor    rax,rax
    1703:	mov    rbx,QWORD PTR [rsp+0x30]
    1708:	mov    r12,QWORD PTR [rsp+0x38]
    170d:	mov    r13,QWORD PTR [rsp+0x40]
    1712:	mov    r14,QWORD PTR [rsp+0x48]
    1717:	add    rsp,0x50
    171b:	mov    rsp,rbp
    171e:	pop    rbp
    171f:	ret
    1720:	mov    rbx,QWORD PTR [rsp+0x30]
    1725:	mov    r12,QWORD PTR [rsp+0x38]
    172a:	mov    r13,QWORD PTR [rsp+0x40]
    172f:	mov    r14,QWORD PTR [rsp+0x48]
    1734:	add    rsp,0x50
    1738:	mov    rsp,rbp
    173b:	pop    rbp
    173c:	ret

000000000000173d <botlish_entry_21: hex_pair<int>>:
    173d:	push   rbp
    173e:	mov    rbp,rsp
    1741:	sub    rsp,0x10
    1745:	mov    QWORD PTR [rsp],r12
    1749:	mov    r12,rdi
    174c:	mov    rsi,QWORD PTR [rdx]
    174f:	call   1754 <botlish_entry_21+0x17>
			1750: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1754:	mov    r8,QWORD PTR [rip+0x0]        # 175b <botlish_entry_21+0x1e>
			1757: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    175b:	mov    rsi,rax
    175e:	mov    rdi,r12
    1761:	call   r8
    1764:	mov    r12,QWORD PTR [rsp]
    1768:	add    rsp,0x10
    176c:	mov    rsp,rbp
    176f:	pop    rbp
    1770:	ret

0000000000001771 <botlish_fn_22: esc_bytes<List[int], int, str>>:
    1771:	push   rbp
    1772:	mov    rbp,rsp
    1775:	sub    rsp,0x90
    177c:	mov    QWORD PTR [rsp+0x60],rbx
    1781:	mov    QWORD PTR [rsp+0x68],r12
    1786:	mov    QWORD PTR [rsp+0x70],r13
    178b:	mov    QWORD PTR [rsp+0x78],r14
    1790:	mov    QWORD PTR [rsp+0x80],r15
    1798:	mov    QWORD PTR [rsp],rsi
    179c:	mov    QWORD PTR [rsp+0x8],rcx
    17a1:	sar    rdx,1
    17a4:	mov    r13,rdx
    17a7:	lea    r14,[rsp+0x20]
    17ac:	mov    rbx,rdi
    17af:	mov    r12,rsi
    17b2:	mov    QWORD PTR [rsp+0x50],rcx
    17b7:	mov    rsi,r12
    17ba:	mov    rdi,rbx
    17bd:	call   17c2 <botlish_fn_22+0x51>
			17be: R_X86_64_PLT32	rt_list_len-0x4
    17c2:	sar    rax,1
    17c5:	cmp    r13,rax
    17c8:	jge    18d8 <botlish_fn_22+0x167>
    17ce:	mov    rax,QWORD PTR [rbx+0x10]
    17d2:	mov    r15,QWORD PTR [rax+0x10]
    17d6:	mov    QWORD PTR [rsp+0x10],r15
    17db:	mov    rcx,QWORD PTR [r12+0x8]
    17e0:	mov    rax,r13
    17e3:	shl    rax,1
    17e6:	or     rax,0x1
    17ea:	sar    rax,1
    17ed:	cmp    rax,rcx
    17f0:	jb     181c <botlish_fn_22+0xab>
    17f6:	mov    rdx,r13
    17f9:	shl    rdx,1
    17fc:	or     rdx,0x1
    1800:	mov    rsi,r12
    1803:	mov    rdi,rbx
    1806:	call   180b <botlish_fn_22+0x9a>
			1807: R_X86_64_PLT32	rt_list_get-0x4
    180b:	test   rax,rax
    180e:	je     1893 <botlish_fn_22+0x122>
    1814:	mov    rsi,rax
    1817:	jmp    1825 <botlish_fn_22+0xb4>
    181c:	mov    rcx,QWORD PTR [r12+0x10]
    1821:	mov    rsi,QWORD PTR [rcx+rax*8]
    1825:	mov    QWORD PTR [rsp+0x18],rsi
    182a:	mov    rdi,rbx
    182d:	call   1832 <botlish_fn_22+0xc1>
			182e: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1832:	test   rax,rax
    1835:	je     1893 <botlish_fn_22+0x122>
    183b:	mov    QWORD PTR [rsp+0x18],rax
    1840:	mov    rcx,rax
    1843:	mov    QWORD PTR [rsp+0x20],0x0
    184c:	mov    rax,QWORD PTR [rsp+0x50]
    1851:	mov    QWORD PTR [rsp+0x28],rax
    1856:	mov    QWORD PTR [rsp+0x30],0x0
    185f:	mov    QWORD PTR [rsp+0x38],r15
    1864:	mov    QWORD PTR [rsp+0x40],0x0
    186d:	mov    rax,rcx
    1870:	mov    QWORD PTR [rsp+0x48],rax
    1875:	mov    esi,0x2
    187a:	mov    edx,0x6
    187f:	mov    rcx,r14
    1882:	mov    rdi,rbx
    1885:	call   188a <botlish_fn_22+0x119>
			1886: R_X86_64_PLT32	rt_construct-0x4
    188a:	test   rax,rax
    188d:	jne    18be <botlish_fn_22+0x14d>
    1893:	xor    rax,rax
    1896:	mov    rbx,QWORD PTR [rsp+0x60]
    189b:	mov    r12,QWORD PTR [rsp+0x68]
    18a0:	mov    r13,QWORD PTR [rsp+0x70]
    18a5:	mov    r14,QWORD PTR [rsp+0x78]
    18aa:	mov    r15,QWORD PTR [rsp+0x80]
    18b2:	add    rsp,0x90
    18b9:	mov    rsp,rbp
    18bc:	pop    rbp
    18bd:	ret
    18be:	mov    QWORD PTR [rsp],r12
    18c2:	mov    QWORD PTR [rsp+0x8],rax
    18c7:	add    r13,0x1
    18ce:	mov    QWORD PTR [rsp+0x50],rax
    18d3:	jmp    17b7 <botlish_fn_22+0x46>
    18d8:	mov    rax,QWORD PTR [rsp+0x50]
    18dd:	mov    rbx,QWORD PTR [rsp+0x60]
    18e2:	mov    r12,QWORD PTR [rsp+0x68]
    18e7:	mov    r13,QWORD PTR [rsp+0x70]
    18ec:	mov    r14,QWORD PTR [rsp+0x78]
    18f1:	mov    r15,QWORD PTR [rsp+0x80]
    18f9:	add    rsp,0x90
    1900:	mov    rsp,rbp
    1903:	pop    rbp
    1904:	ret

0000000000001905 <botlish_entry_22: esc_bytes<List[int], int, str>>:
    1905:	push   rbp
    1906:	mov    rbp,rsp
    1909:	sub    rsp,0x10
    190d:	mov    QWORD PTR [rsp],r12
    1911:	mov    r12,rdi
    1914:	mov    rsi,QWORD PTR [rdx]
    1917:	mov    r8,QWORD PTR [rdx+0x8]
    191b:	mov    rcx,QWORD PTR [rdx+0x10]
    191f:	mov    rdx,r8
    1922:	call   1927 <botlish_entry_22+0x22>
			1923: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1927:	mov    r8,QWORD PTR [rip+0x0]        # 192e <botlish_entry_22+0x29>
			192a: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    192e:	mov    rsi,rax
    1931:	mov    rdi,r12
    1934:	call   r8
    1937:	mov    r12,QWORD PTR [rsp]
    193b:	add    rsp,0x10
    193f:	mov    rsp,rbp
    1942:	pop    rbp
    1943:	ret

0000000000001944 <botlish_fn_23: esc_char<str>>:
    1944:	push   rbp
    1945:	mov    rbp,rsp
    1948:	sub    rsp,0x40
    194c:	mov    QWORD PTR [rsp+0x20],rbx
    1951:	mov    QWORD PTR [rsp+0x28],r12
    1956:	mov    QWORD PTR [rsp+0x30],r13
    195b:	mov    rbx,rdi
    195e:	mov    QWORD PTR [rsp+0x8],0x0
    1967:	mov    QWORD PTR [rsp+0x10],0x0
    1970:	mov    QWORD PTR [rsp],rsi
    1974:	mov    r13,rsi
    1977:	mov    rsi,r13
    197a:	mov    rdi,rbx
    197d:	call   1982 <botlish_fn_23+0x3e>
			197e: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1982:	mov    rcx,rax
    1985:	mov    r12,rax
    1988:	test   rax,rcx
    198b:	je     1a69 <botlish_fn_23+0x125>
    1991:	mov    rax,r12
    1994:	mov    QWORD PTR [rsp],rax
    1998:	mov    rsi,r12
    199b:	mov    rdi,rbx
    199e:	call   19a3 <botlish_fn_23+0x5f>
			199f: R_X86_64_PLT32	rt_list_len-0x4
    19a3:	sar    rax,1
    19a6:	cmp    rax,0x1
    19aa:	je     19e7 <botlish_fn_23+0xa3>
    19b0:	mov    edx,0x1
    19b5:	mov    QWORD PTR [rsp+0x8],0x1
    19be:	mov    rdi,rbx
    19c1:	mov    rax,QWORD PTR [rdi+0x10]
    19c5:	mov    rcx,QWORD PTR [rax+0xe0]
    19cc:	mov    QWORD PTR [rsp+0x10],rcx
    19d1:	mov    rsi,r12
    19d4:	call   19d9 <botlish_fn_23+0x95>
			19d5: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    19d9:	test   rax,rax
    19dc:	je     1a69 <botlish_fn_23+0x125>
    19e2:	jmp    1a8a <botlish_fn_23+0x146>
    19e7:	mov    rsi,r12
    19ea:	mov    rax,QWORD PTR [rsi+0x8]
    19ee:	mov    r12,rsi
    19f1:	test   rax,rax
    19f4:	jne    1a1b <botlish_fn_23+0xd7>
    19fa:	mov    edx,0x1
    19ff:	mov    rsi,r12
    1a02:	mov    rdi,rbx
    1a05:	call   1a0a <botlish_fn_23+0xc6>
			1a06: R_X86_64_PLT32	rt_list_get-0x4
    1a0a:	test   rax,rax
    1a0d:	je     1a69 <botlish_fn_23+0x125>
    1a13:	mov    rsi,rax
    1a16:	jmp    1a25 <botlish_fn_23+0xe1>
    1a1b:	mov    rsi,r12
    1a1e:	mov    rax,QWORD PTR [rsi+0x10]
    1a22:	mov    rsi,QWORD PTR [rax]
    1a25:	mov    rdi,rbx
    1a28:	call   1a2d <botlish_fn_23+0xe9>
			1a29: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1a2d:	cmp    rax,0x6
    1a31:	je     1a87 <botlish_fn_23+0x143>
    1a37:	mov    edx,0x1
    1a3c:	mov    QWORD PTR [rsp+0x8],0x1
    1a45:	mov    rdi,rbx
    1a48:	mov    rax,QWORD PTR [rdi+0x10]
    1a4c:	mov    rcx,QWORD PTR [rax+0xe0]
    1a53:	mov    QWORD PTR [rsp+0x10],rcx
    1a58:	mov    rsi,r12
    1a5b:	call   1a60 <botlish_fn_23+0x11c>
			1a5c: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1a60:	test   rax,rax
    1a63:	jne    1a84 <botlish_fn_23+0x140>
    1a69:	xor    rax,rax
    1a6c:	mov    rbx,QWORD PTR [rsp+0x20]
    1a71:	mov    r12,QWORD PTR [rsp+0x28]
    1a76:	mov    r13,QWORD PTR [rsp+0x30]
    1a7b:	add    rsp,0x40
    1a7f:	mov    rsp,rbp
    1a82:	pop    rbp
    1a83:	ret
    1a84:	mov    r13,rax
    1a87:	mov    rax,r13
    1a8a:	mov    rbx,QWORD PTR [rsp+0x20]
    1a8f:	mov    r12,QWORD PTR [rsp+0x28]
    1a94:	mov    r13,QWORD PTR [rsp+0x30]
    1a99:	add    rsp,0x40
    1a9d:	mov    rsp,rbp
    1aa0:	pop    rbp
    1aa1:	ret

0000000000001aa2 <botlish_entry_23: esc_char<str>>:
    1aa2:	push   rbp
    1aa3:	mov    rbp,rsp
    1aa6:	sub    rsp,0x10
    1aaa:	mov    QWORD PTR [rsp],r12
    1aae:	mov    r12,rdi
    1ab1:	mov    rsi,QWORD PTR [rdx]
    1ab4:	call   1ab9 <botlish_entry_23+0x17>
			1ab5: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1ab9:	mov    r8,QWORD PTR [rip+0x0]        # 1ac0 <botlish_entry_23+0x1e>
			1abc: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1ac0:	mov    rsi,rax
    1ac3:	mov    rdi,r12
    1ac6:	call   r8
    1ac9:	mov    r12,QWORD PTR [rsp]
    1acd:	add    rsp,0x10
    1ad1:	mov    rsp,rbp
    1ad4:	pop    rbp
    1ad5:	ret

0000000000001ad6 <botlish_fn_24: esc_from<str, int, str>>:
    1ad6:	push   rbp
    1ad7:	mov    rbp,rsp
    1ada:	sub    rsp,0x90
    1ae1:	mov    QWORD PTR [rsp+0x60],rbx
    1ae6:	mov    QWORD PTR [rsp+0x68],r12
    1aeb:	mov    QWORD PTR [rsp+0x70],r13
    1af0:	mov    QWORD PTR [rsp+0x78],r14
    1af5:	mov    QWORD PTR [rsp+0x80],r15
    1afd:	mov    r14,rdi
    1b00:	mov    QWORD PTR [rsp+0x8],0x0
    1b09:	mov    QWORD PTR [rsp+0x10],0x0
    1b12:	mov    QWORD PTR [rsp+0x18],0x0
    1b1b:	mov    QWORD PTR [rsp],rcx
    1b1f:	mov    QWORD PTR [rsp+0x50],rcx
    1b24:	sar    rdx,1
    1b27:	mov    r13d,0x47
    1b2d:	mov    rcx,0xffffffffffffffff
    1b34:	bsr    rax,rsi
    1b38:	mov    r15,rsi
    1b3b:	cmove  rax,rcx
    1b3f:	mov    ecx,0x3f
    1b44:	sub    rcx,rax
    1b47:	sub    r13,rcx
    1b4a:	shr    r13,0x3
    1b4e:	lea    rbx,[rsp+0x30]
    1b53:	mov    r12,rdx
    1b56:	cmp    r12,r13
    1b59:	jge    1c13 <botlish_fn_24+0x13d>
    1b5f:	mov    rsi,r15
    1b62:	mov    rdi,r14
    1b65:	call   1b6a <botlish_fn_24+0x94>
			1b66: R_X86_64_PLT32	rt_ascii_to_str-0x4
    1b6a:	mov    QWORD PTR [rsp+0x8],rax
    1b6f:	mov    rdx,r12
    1b72:	shl    rdx,1
    1b75:	or     rdx,0x1
    1b79:	mov    QWORD PTR [rsp+0x10],rdx
    1b7e:	add    r12,0x1
    1b85:	mov    rcx,r12
    1b88:	shl    rcx,1
    1b8b:	or     rcx,0x1
    1b8f:	mov    QWORD PTR [rsp+0x18],rcx
    1b94:	mov    rsi,rax
    1b97:	mov    rdi,r14
    1b9a:	call   1b9f <botlish_fn_24+0xc9>
			1b9b: R_X86_64_PLT32	rt_substr-0x4
    1b9f:	test   rax,rax
    1ba2:	je     1c47 <botlish_fn_24+0x171>
    1ba8:	mov    QWORD PTR [rsp+0x8],rax
    1bad:	mov    rsi,rax
    1bb0:	mov    rdi,r14
    1bb3:	call   1bb8 <botlish_fn_24+0xe2>
			1bb4: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1bb8:	test   rax,rax
    1bbb:	je     1c47 <botlish_fn_24+0x171>
    1bc1:	mov    QWORD PTR [rsp+0x8],rax
    1bc6:	mov    QWORD PTR [rsp+0x30],0x0
    1bcf:	mov    rcx,QWORD PTR [rsp+0x50]
    1bd4:	mov    QWORD PTR [rsp+0x38],rcx
    1bd9:	mov    QWORD PTR [rsp+0x40],0x0
    1be2:	mov    QWORD PTR [rsp+0x48],rax
    1be7:	mov    esi,0x2
    1bec:	mov    edx,0x4
    1bf1:	mov    rcx,rbx
    1bf4:	mov    rdi,r14
    1bf7:	call   1bfc <botlish_fn_24+0x126>
			1bf8: R_X86_64_PLT32	rt_construct-0x4
    1bfc:	test   rax,rax
    1bff:	je     1c47 <botlish_fn_24+0x171>
    1c05:	mov    QWORD PTR [rsp],rax
    1c09:	mov    QWORD PTR [rsp+0x50],rax
    1c0e:	jmp    1b56 <botlish_fn_24+0x80>
    1c13:	mov    rcx,QWORD PTR [rsp+0x50]
    1c18:	xor    rsi,rsi
    1c1b:	lea    rax,[rsp+0x20]
    1c20:	mov    QWORD PTR [rsp+0x20],0x0
    1c29:	mov    QWORD PTR [rsp+0x28],rcx
    1c2e:	mov    edx,0x2
    1c33:	mov    rcx,rax
    1c36:	mov    rdi,r14
    1c39:	call   1c3e <botlish_fn_24+0x168>
			1c3a: R_X86_64_PLT32	rt_construct-0x4
    1c3e:	test   rax,rax
    1c41:	jne    1c72 <botlish_fn_24+0x19c>
    1c47:	xor    rax,rax
    1c4a:	mov    rbx,QWORD PTR [rsp+0x60]
    1c4f:	mov    r12,QWORD PTR [rsp+0x68]
    1c54:	mov    r13,QWORD PTR [rsp+0x70]
    1c59:	mov    r14,QWORD PTR [rsp+0x78]
    1c5e:	mov    r15,QWORD PTR [rsp+0x80]
    1c66:	add    rsp,0x90
    1c6d:	mov    rsp,rbp
    1c70:	pop    rbp
    1c71:	ret
    1c72:	mov    rbx,QWORD PTR [rsp+0x60]
    1c77:	mov    r12,QWORD PTR [rsp+0x68]
    1c7c:	mov    r13,QWORD PTR [rsp+0x70]
    1c81:	mov    r14,QWORD PTR [rsp+0x78]
    1c86:	mov    r15,QWORD PTR [rsp+0x80]
    1c8e:	add    rsp,0x90
    1c95:	mov    rsp,rbp
    1c98:	pop    rbp
    1c99:	ret

0000000000001c9a <botlish_entry_24: esc_from<str, int, str>>:
    1c9a:	push   rbp
    1c9b:	mov    rbp,rsp
    1c9e:	sub    rsp,0x10
    1ca2:	mov    QWORD PTR [rsp],r12
    1ca6:	mov    QWORD PTR [rsp+0x8],r13
    1cab:	mov    r12,rdi
    1cae:	mov    rsi,QWORD PTR [rdx]
    1cb1:	mov    r13,rdx
    1cb4:	mov    r8,QWORD PTR [rip+0x0]        # 1cbb <botlish_entry_24+0x21>
			1cb7: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    1cbb:	call   r8
    1cbe:	mov    rcx,r13
    1cc1:	mov    rdx,QWORD PTR [rcx+0x8]
    1cc5:	mov    rcx,QWORD PTR [rcx+0x10]
    1cc9:	mov    rsi,rax
    1ccc:	mov    rdi,r12
    1ccf:	call   1cd4 <botlish_entry_24+0x3a>
			1cd0: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    1cd4:	mov    r12,QWORD PTR [rsp]
    1cd8:	mov    r13,QWORD PTR [rsp+0x8]
    1cdd:	add    rsp,0x10
    1ce1:	mov    rsp,rbp
    1ce4:	pop    rbp
    1ce5:	ret

0000000000001ce6 <botlish_fn_25: check<int, int, str, str>>:
    1ce6:	push   rbp
    1ce7:	mov    rbp,rsp
    1cea:	sub    rsp,0x50
    1cee:	mov    QWORD PTR [rsp+0x20],rbx
    1cf3:	mov    QWORD PTR [rsp+0x28],r12
    1cf8:	mov    QWORD PTR [rsp+0x30],r13
    1cfd:	mov    QWORD PTR [rsp+0x38],r14
    1d02:	mov    QWORD PTR [rsp+0x40],r15
    1d07:	mov    r14,rdi
    1d0a:	mov    QWORD PTR [rsp+0x18],0x0
    1d13:	mov    QWORD PTR [rsp],rdx
    1d17:	mov    QWORD PTR [rsp+0x8],rcx
    1d1c:	mov    QWORD PTR [rsp+0x10],r8
    1d21:	mov    r13,r8
    1d24:	mov    r12,rsi
    1d27:	mov    r15,rdx
    1d2a:	test   r12,r12
    1d2d:	jle    1def <botlish_fn_25+0x109>
    1d33:	mov    rbx,rcx
    1d36:	mov    rsi,rbx
    1d39:	mov    rdi,r14
    1d3c:	call   1d41 <botlish_fn_25+0x5b>
			1d3d: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
    1d41:	test   rax,rax
    1d44:	jne    1d6f <botlish_fn_25+0x89>
    1d4a:	xor    rax,rax
    1d4d:	mov    rbx,QWORD PTR [rsp+0x20]
    1d52:	mov    r12,QWORD PTR [rsp+0x28]
    1d57:	mov    r13,QWORD PTR [rsp+0x30]
    1d5c:	mov    r14,QWORD PTR [rsp+0x38]
    1d61:	mov    r15,QWORD PTR [rsp+0x40]
    1d66:	add    rsp,0x50
    1d6a:	mov    rsp,rbp
    1d6d:	pop    rbp
    1d6e:	ret
    1d6f:	cmp    rax,0x6
    1d73:	je     1d8f <botlish_fn_25+0xa9>
    1d79:	mov    edx,0x1
    1d7e:	mov    QWORD PTR [rsp+0x18],0x1
    1d87:	mov    rsi,r15
    1d8a:	jmp    1da0 <botlish_fn_25+0xba>
    1d8f:	mov    edx,0x3
    1d94:	mov    QWORD PTR [rsp+0x18],0x3
    1d9d:	mov    rsi,r15
    1da0:	mov    rax,rsi
    1da3:	and    rax,rdx
    1da6:	test   rax,0x1
    1dac:	je     1dc7 <botlish_fn_25+0xe1>
    1db2:	lea    rcx,[rdx-0x1]
    1db6:	mov    rax,rsi
    1db9:	add    rax,rcx
    1dbc:	seto   cl
    1dbf:	test   cl,cl
    1dc1:	je     1dcf <botlish_fn_25+0xe9>
    1dc7:	mov    rdi,r14
    1dca:	call   1dcf <botlish_fn_25+0xe9>
			1dcb: R_X86_64_PLT32	rt_int_add-0x4
    1dcf:	mov    QWORD PTR [rsp],rax
    1dd3:	mov    QWORD PTR [rsp+0x8],rbx
    1dd8:	mov    r8,r13
    1ddb:	mov    QWORD PTR [rsp+0x10],r8
    1de0:	sub    r12,0x1
    1de4:	mov    rcx,rbx
    1de7:	mov    r15,rax
    1dea:	jmp    1d2a <botlish_fn_25+0x44>
    1def:	mov    rax,r15
    1df2:	mov    rbx,QWORD PTR [rsp+0x20]
    1df7:	mov    r12,QWORD PTR [rsp+0x28]
    1dfc:	mov    r13,QWORD PTR [rsp+0x30]
    1e01:	mov    r14,QWORD PTR [rsp+0x38]
    1e06:	mov    r15,QWORD PTR [rsp+0x40]
    1e0b:	add    rsp,0x50
    1e0f:	mov    rsp,rbp
    1e12:	pop    rbp
    1e13:	ret

0000000000001e14 <botlish_entry_25: check<int, int, str, str>>:
    1e14:	push   rbp
    1e15:	mov    rbp,rsp
    1e18:	mov    rsi,QWORD PTR [rdx]
    1e1b:	mov    r9,QWORD PTR [rdx+0x8]
    1e1f:	mov    rcx,QWORD PTR [rdx+0x10]
    1e23:	mov    r8,QWORD PTR [rdx+0x18]
    1e27:	sar    rsi,1
    1e2a:	mov    rdx,r9
    1e2d:	call   1e32 <botlish_entry_25+0x1e>
			1e2e: R_X86_64_PLT32	botlish_fn_25-0x4 ; check<int, int, str, str>
    1e32:	mov    rsp,rbp
    1e35:	pop    rbp
    1e36:	ret

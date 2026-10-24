; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 9545  (per function: 1415 84 745 74 74 74 128 128 336 129 88 192 176 176 295 344 183 504 140 60 389 629 127 50 269 227 173 947 1021 368)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> std::byte::from_int<int>
;   botlish_fn_2 / botlish_entry_2 -> std::byte::set<List[UnicodeChar]>
;   botlish_fn_3 / botlish_entry_3 -> std::ascii::is_digit<int>
;   botlish_fn_4 / botlish_entry_4 -> std::ascii::is_upper<int>
;   botlish_fn_5 / botlish_entry_5 -> std::ascii::is_lower<int>
;   botlish_fn_6 / botlish_entry_6 -> std::ascii::is_alphabetic<int>
;   botlish_fn_7 / botlish_entry_7 -> std::ascii::is_alphanumeric<int>
;   botlish_fn_8 / botlish_entry_8 -> std::web::emailish?<str>
;   botlish_fn_9 / botlish_entry_9 -> char_at<int>
;   botlish_fn_10 / botlish_entry_10 -> char_at<int>
;   botlish_fn_11 / botlish_entry_11 -> char_is?<int, any>
;   botlish_fn_12 / botlish_entry_12 -> local_char?<str>
;   botlish_fn_13 / botlish_entry_13 -> local_char?<generic>
;   botlish_fn_14 / botlish_entry_14 -> scan_while<int, block(e276)>
;   botlish_fn_15 / botlish_entry_15 -> scan_while<int, native(std::str::is_tcl_alpha)>
;   botlish_fn_16 / botlish_entry_16 -> tld?<int>
;   botlish_fn_17 / botlish_entry_17 -> domain?<int>
;   botlish_fn_18 / botlish_entry_18 -> std::web::is_unreserved<int>
;   botlish_fn_19 / botlish_entry_19 -> std::web::uri_query_value?<str>
;   botlish_fn_20 / botlish_entry_20 -> upper_hex?<int>
;   botlish_fn_21 / botlish_entry_21 -> valid_from?<int>
;   botlish_fn_22 / botlish_entry_22 -> std::web::uri_escape_text<str>
;   botlish_fn_23 / botlish_entry_23 -> high_nibble<int>
;   botlish_fn_24 / botlish_entry_24 -> hex_pair<int>
;   botlish_fn_25 / botlish_entry_25 -> pct<int>
;   botlish_fn_26 / botlish_entry_26 -> cont<int, int>
;   botlish_fn_27 / botlish_entry_27 -> esc_scalar<int>
;   botlish_fn_28 / botlish_entry_28 -> esc_from<str, int, str>
;   botlish_fn_29 / botlish_entry_29 -> check<int, int, str, str>


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
			3fa: R_X86_64_PLT32	botlish_fn_2-0x4 ; std::byte::set<List[UnicodeChar]>
     3fe:	test   rax,rax
     401:	je     4e8 <botlish_fn_0+0x4e8>
     407:	mov    rdi,QWORD PTR [rsp+0x158]
     40f:	mov    rcx,QWORD PTR [rdi+0x30]
     413:	mov    QWORD PTR [rcx+0x10],rax
     417:	mov    esi,0xe2a0e1
     41c:	call   421 <botlish_fn_0+0x421>
			41d: R_X86_64_PLT32	botlish_fn_22-0x4 ; std::web::uri_escape_text<str>
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
			460: R_X86_64_PLT32	botlish_fn_29-0x4 ; check<int, int, str, str>
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
			4a4: R_X86_64_PLT32	botlish_fn_29-0x4 ; check<int, int, str, str>
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

0000000000000561 <botlish_fn_1: std::byte::from_int<int>>:
     561:	push   rbp
     562:	mov    rbp,rsp
     565:	mov    r10,rsi
     568:	sar    r10,1
     56b:	cmp    r10,0xff
     572:	jg     580 <botlish_fn_1+0x1f>
     578:	mov    rax,rsi
     57b:	mov    rsp,rbp
     57e:	pop    rbp
     57f:	ret
     580:	mov    rax,QWORD PTR [rdi+0x10]
     584:	mov    rdx,QWORD PTR [rax+0xb8]
     58b:	mov    esi,0x2
     590:	call   595 <botlish_fn_1+0x34>
			591: R_X86_64_PLT32	rt_fail_declared-0x4
     595:	xor    rax,rax
     598:	mov    rsp,rbp
     59b:	pop    rbp
     59c:	ret

000000000000059d <botlish_entry_1: std::byte::from_int<int>>:
     59d:	push   rbp
     59e:	mov    rbp,rsp
     5a1:	mov    rsi,QWORD PTR [rdx]
     5a4:	call   5a9 <botlish_entry_1+0xc>
			5a5: R_X86_64_PLT32	botlish_fn_1-0x4 ; std::byte::from_int<int>
     5a9:	mov    rsp,rbp
     5ac:	pop    rbp
     5ad:	ret
	...

00000000000005b0 <botlish_fn_2: std::byte::set<List[UnicodeChar]>>:
     5b0:	push   rbp
     5b1:	mov    rbp,rsp
     5b4:	sub    rsp,0x90
     5bb:	mov    QWORD PTR [rsp+0x60],rbx
     5c0:	mov    QWORD PTR [rsp+0x68],r12
     5c5:	mov    QWORD PTR [rsp+0x70],r13
     5ca:	mov    QWORD PTR [rsp+0x78],r14
     5cf:	mov    QWORD PTR [rsp+0x80],r15
     5d7:	mov    r13,rdi
     5da:	mov    QWORD PTR [rsp+0x18],0x0
     5e3:	mov    QWORD PTR [rsp+0x20],0x0
     5ec:	mov    QWORD PTR [rsp],rsi
     5f0:	mov    rbx,rsi
     5f3:	mov    rdi,r13
     5f6:	call   5fb <botlish_fn_2+0x4b>
			5f7: R_X86_64_PLT32	rt_list_len-0x4
     5fb:	mov    QWORD PTR [rsp+0x8],rax
     600:	mov    r12,rax
     603:	mov    QWORD PTR [rsp+0x10],0x1
     60c:	xor    rdx,rdx
     60f:	mov    rdi,r13
     612:	mov    rsi,rdx
     615:	call   61a <botlish_fn_2+0x6a>
			616: R_X86_64_PLT32	rt_list_new-0x4
     61a:	test   rax,rax
     61d:	je     7b1 <botlish_fn_2+0x201>
     623:	mov    QWORD PTR [rsp+0x18],rax
     628:	mov    QWORD PTR [rsp+0x58],rax
     62d:	mov    esi,0x1
     632:	mov    r14,rsi
     635:	mov    rax,rsi
     638:	and    rax,r12
     63b:	mov    r14,rsi
     63e:	test   rax,0x1
     644:	jne    66d <botlish_fn_2+0xbd>
     64a:	mov    rdx,r12
     64d:	mov    rsi,r14
     650:	mov    rdi,r13
     653:	call   658 <botlish_fn_2+0xa8>
			654: R_X86_64_PLT32	rt_int_cmp-0x4
     658:	mov    ecx,0x2
     65d:	test   rax,rax
     660:	cmovl  rcx,QWORD PTR [rip+0x1e8]        # 850 <botlish_fn_2+0x2a0>
     668:	jmp    680 <botlish_fn_2+0xd0>
     66d:	mov    ecx,0x2
     672:	mov    rsi,r14
     675:	cmp    rsi,r12
     678:	cmovl  rcx,QWORD PTR [rip+0x1d0]        # 850 <botlish_fn_2+0x2a0>
     680:	cmp    rcx,0x6
     684:	je     6f4 <botlish_fn_2+0x144>
     68a:	lea    rcx,[rsp+0x48]
     68f:	mov    QWORD PTR [rsp+0x48],0x0
     698:	mov    rax,QWORD PTR [rsp+0x58]
     69d:	mov    QWORD PTR [rsp+0x50],rax
     6a2:	mov    esi,0x1
     6a7:	mov    edx,0x2
     6ac:	mov    rdi,r13
     6af:	call   6b4 <botlish_fn_2+0x104>
			6b0: R_X86_64_PLT32	rt_construct-0x4
     6b4:	test   rax,rax
     6b7:	je     7b1 <botlish_fn_2+0x201>
     6bd:	mov    QWORD PTR [rsp],rax
     6c1:	mov    rsi,rax
     6c4:	mov    rdi,r13
     6c7:	call   6cc <botlish_fn_2+0x11c>
			6c8: R_X86_64_PLT32	rt_set_from_list-0x4
     6cc:	mov    rbx,QWORD PTR [rsp+0x60]
     6d1:	mov    r12,QWORD PTR [rsp+0x68]
     6d6:	mov    r13,QWORD PTR [rsp+0x70]
     6db:	mov    r14,QWORD PTR [rsp+0x78]
     6e0:	mov    r15,QWORD PTR [rsp+0x80]
     6e8:	add    rsp,0x90
     6ef:	mov    rsp,rbp
     6f2:	pop    rbp
     6f3:	ret
     6f4:	mov    rsi,r14
     6f7:	test   rsi,0x1
     6fe:	je     71a <botlish_fn_2+0x16a>
     704:	mov    r9,QWORD PTR [rbx+0x8]
     708:	mov    rsi,r14
     70b:	mov    r8,rsi
     70e:	sar    r8,1
     711:	cmp    r8,r9
     714:	jb     739 <botlish_fn_2+0x189>
     71a:	mov    rdx,r14
     71d:	mov    rsi,rbx
     720:	mov    rdi,r13
     723:	call   728 <botlish_fn_2+0x178>
			724: R_X86_64_PLT32	rt_list_get-0x4
     728:	test   rax,rax
     72b:	je     7b1 <botlish_fn_2+0x201>
     731:	mov    rsi,rax
     734:	jmp    741 <botlish_fn_2+0x191>
     739:	mov    rax,QWORD PTR [rbx+0x10]
     73d:	mov    rsi,QWORD PTR [rax+r8*8]
     741:	mov    edx,0x3
     746:	mov    r15,rdx
     749:	shr    rsi,0x3
     74d:	shl    rsi,1
     750:	or     rsi,0x1
     754:	mov    rdi,r13
     757:	call   75c <botlish_fn_2+0x1ac>
			758: R_X86_64_PLT32	botlish_fn_1-0x4 ; std::byte::from_int<int>
     75c:	test   rax,rax
     75f:	je     7b1 <botlish_fn_2+0x201>
     765:	mov    QWORD PTR [rsp+0x20],rax
     76a:	lea    rcx,[rsp+0x28]
     76f:	mov    QWORD PTR [rsp+0x28],0x0
     778:	mov    r10,QWORD PTR [rsp+0x58]
     77d:	mov    QWORD PTR [rsp+0x30],r10
     782:	mov    QWORD PTR [rsp+0x38],0x2
     78b:	mov    QWORD PTR [rsp+0x40],rax
     790:	mov    edx,0x4
     795:	mov    rsi,r15
     798:	mov    rdi,r13
     79b:	call   7a0 <botlish_fn_2+0x1f0>
			79c: R_X86_64_PLT32	rt_construct-0x4
     7a0:	mov    rcx,rax
     7a3:	mov    QWORD PTR [rsp+0x58],rax
     7a8:	test   rax,rcx
     7ab:	jne    7dc <botlish_fn_2+0x22c>
     7b1:	xor    rax,rax
     7b4:	mov    rbx,QWORD PTR [rsp+0x60]
     7b9:	mov    r12,QWORD PTR [rsp+0x68]
     7be:	mov    r13,QWORD PTR [rsp+0x70]
     7c3:	mov    r14,QWORD PTR [rsp+0x78]
     7c8:	mov    r15,QWORD PTR [rsp+0x80]
     7d0:	add    rsp,0x90
     7d7:	mov    rsp,rbp
     7da:	pop    rbp
     7db:	ret
     7dc:	mov    rax,QWORD PTR [rsp+0x58]
     7e1:	mov    QWORD PTR [rsp+0x18],rax
     7e6:	mov    QWORD PTR [rsp+0x20],0x3
     7ef:	mov    rsi,r14
     7f2:	test   rsi,0x1
     7f9:	jne    80a <botlish_fn_2+0x25a>
     7ff:	mov    rdx,r15
     802:	mov    rsi,r14
     805:	jmp    835 <botlish_fn_2+0x285>
     80a:	mov    rsi,r14
     80d:	mov    rax,rsi
     810:	add    rax,0x2
     814:	seto   cl
     817:	test   cl,cl
     819:	je     82a <botlish_fn_2+0x27a>
     81f:	mov    rdx,r15
     822:	mov    rsi,r14
     825:	jmp    835 <botlish_fn_2+0x285>
     82a:	mov    rsi,rax
     82d:	mov    r14,rax
     830:	jmp    843 <botlish_fn_2+0x293>
     835:	mov    rdi,r13
     838:	call   83d <botlish_fn_2+0x28d>
			839: R_X86_64_PLT32	rt_int_add-0x4
     83d:	mov    rsi,rax
     840:	mov    r14,rax
     843:	mov    QWORD PTR [rsp+0x10],rsi
     848:	mov    rsi,r14
     84b:	jmp    635 <botlish_fn_2+0x85>
     850:	(bad)
     851:	add    BYTE PTR [rax],al
     853:	add    BYTE PTR [rax],al
     855:	add    BYTE PTR [rax],al
	...

0000000000000858 <botlish_entry_2: std::byte::set<List[UnicodeChar]>>:
     858:	push   rbp
     859:	mov    rbp,rsp
     85c:	mov    rsi,QWORD PTR [rdx]
     85f:	call   864 <botlish_entry_2+0xc>
			860: R_X86_64_PLT32	botlish_fn_2-0x4 ; std::byte::set<List[UnicodeChar]>
     864:	mov    rsp,rbp
     867:	pop    rbp
     868:	ret

0000000000000869 <botlish_fn_3: std::ascii::is_digit<int>>:
     869:	push   rbp
     86a:	mov    rbp,rsp
     86d:	cmp    rsi,0x30
     871:	jge    881 <botlish_fn_3+0x18>
     877:	mov    eax,0x2
     87c:	jmp    89a <botlish_fn_3+0x31>
     881:	cmp    rsi,0x39
     885:	jle    895 <botlish_fn_3+0x2c>
     88b:	mov    eax,0x2
     890:	jmp    89a <botlish_fn_3+0x31>
     895:	mov    eax,0x6
     89a:	mov    rsp,rbp
     89d:	pop    rbp
     89e:	ret

000000000000089f <botlish_entry_3: std::ascii::is_digit<int>>:
     89f:	push   rbp
     8a0:	mov    rbp,rsp
     8a3:	mov    rsi,QWORD PTR [rdx]
     8a6:	sar    rsi,1
     8a9:	call   8ae <botlish_entry_3+0xf>
			8aa: R_X86_64_PLT32	botlish_fn_3-0x4 ; std::ascii::is_digit<int>
     8ae:	mov    rsp,rbp
     8b1:	pop    rbp
     8b2:	ret

00000000000008b3 <botlish_fn_4: std::ascii::is_upper<int>>:
     8b3:	push   rbp
     8b4:	mov    rbp,rsp
     8b7:	cmp    rsi,0x41
     8bb:	jge    8cb <botlish_fn_4+0x18>
     8c1:	mov    eax,0x2
     8c6:	jmp    8e4 <botlish_fn_4+0x31>
     8cb:	cmp    rsi,0x5a
     8cf:	jle    8df <botlish_fn_4+0x2c>
     8d5:	mov    eax,0x2
     8da:	jmp    8e4 <botlish_fn_4+0x31>
     8df:	mov    eax,0x6
     8e4:	mov    rsp,rbp
     8e7:	pop    rbp
     8e8:	ret

00000000000008e9 <botlish_entry_4: std::ascii::is_upper<int>>:
     8e9:	push   rbp
     8ea:	mov    rbp,rsp
     8ed:	mov    rsi,QWORD PTR [rdx]
     8f0:	sar    rsi,1
     8f3:	call   8f8 <botlish_entry_4+0xf>
			8f4: R_X86_64_PLT32	botlish_fn_4-0x4 ; std::ascii::is_upper<int>
     8f8:	mov    rsp,rbp
     8fb:	pop    rbp
     8fc:	ret

00000000000008fd <botlish_fn_5: std::ascii::is_lower<int>>:
     8fd:	push   rbp
     8fe:	mov    rbp,rsp
     901:	cmp    rsi,0x61
     905:	jge    915 <botlish_fn_5+0x18>
     90b:	mov    eax,0x2
     910:	jmp    92e <botlish_fn_5+0x31>
     915:	cmp    rsi,0x7a
     919:	jle    929 <botlish_fn_5+0x2c>
     91f:	mov    eax,0x2
     924:	jmp    92e <botlish_fn_5+0x31>
     929:	mov    eax,0x6
     92e:	mov    rsp,rbp
     931:	pop    rbp
     932:	ret

0000000000000933 <botlish_entry_5: std::ascii::is_lower<int>>:
     933:	push   rbp
     934:	mov    rbp,rsp
     937:	mov    rsi,QWORD PTR [rdx]
     93a:	sar    rsi,1
     93d:	call   942 <botlish_entry_5+0xf>
			93e: R_X86_64_PLT32	botlish_fn_5-0x4 ; std::ascii::is_lower<int>
     942:	mov    rsp,rbp
     945:	pop    rbp
     946:	ret

0000000000000947 <botlish_fn_6: std::ascii::is_alphabetic<int>>:
     947:	push   rbp
     948:	mov    rbp,rsp
     94b:	sub    rsp,0x10
     94f:	mov    QWORD PTR [rsp],r12
     953:	mov    QWORD PTR [rsp+0x8],r14
     958:	mov    r12,rsi
     95b:	mov    r14,rdi
     95e:	mov    rsi,r12
     961:	mov    rdi,r14
     964:	call   969 <botlish_fn_6+0x22>
			965: R_X86_64_PLT32	botlish_fn_4-0x4 ; std::ascii::is_upper<int>
     969:	cmp    rax,0x6
     96d:	je     99c <botlish_fn_6+0x55>
     973:	mov    rsi,r12
     976:	mov    rdi,r14
     979:	call   97e <botlish_fn_6+0x37>
			97a: R_X86_64_PLT32	botlish_fn_5-0x4 ; std::ascii::is_lower<int>
     97e:	cmp    rax,0x6
     982:	je     992 <botlish_fn_6+0x4b>
     988:	mov    eax,0x2
     98d:	jmp    9a1 <botlish_fn_6+0x5a>
     992:	mov    eax,0x6
     997:	jmp    9a1 <botlish_fn_6+0x5a>
     99c:	mov    eax,0x6
     9a1:	mov    r12,QWORD PTR [rsp]
     9a5:	mov    r14,QWORD PTR [rsp+0x8]
     9aa:	add    rsp,0x10
     9ae:	mov    rsp,rbp
     9b1:	pop    rbp
     9b2:	ret

00000000000009b3 <botlish_entry_6: std::ascii::is_alphabetic<int>>:
     9b3:	push   rbp
     9b4:	mov    rbp,rsp
     9b7:	mov    rsi,QWORD PTR [rdx]
     9ba:	sar    rsi,1
     9bd:	call   9c2 <botlish_entry_6+0xf>
			9be: R_X86_64_PLT32	botlish_fn_6-0x4 ; std::ascii::is_alphabetic<int>
     9c2:	mov    rsp,rbp
     9c5:	pop    rbp
     9c6:	ret

00000000000009c7 <botlish_fn_7: std::ascii::is_alphanumeric<int>>:
     9c7:	push   rbp
     9c8:	mov    rbp,rsp
     9cb:	sub    rsp,0x10
     9cf:	mov    QWORD PTR [rsp],r12
     9d3:	mov    QWORD PTR [rsp+0x8],r14
     9d8:	mov    r12,rsi
     9db:	mov    r14,rdi
     9de:	mov    rsi,r12
     9e1:	mov    rdi,r14
     9e4:	call   9e9 <botlish_fn_7+0x22>
			9e5: R_X86_64_PLT32	botlish_fn_6-0x4 ; std::ascii::is_alphabetic<int>
     9e9:	cmp    rax,0x6
     9ed:	je     a1c <botlish_fn_7+0x55>
     9f3:	mov    rsi,r12
     9f6:	mov    rdi,r14
     9f9:	call   9fe <botlish_fn_7+0x37>
			9fa: R_X86_64_PLT32	botlish_fn_3-0x4 ; std::ascii::is_digit<int>
     9fe:	cmp    rax,0x6
     a02:	je     a12 <botlish_fn_7+0x4b>
     a08:	mov    eax,0x2
     a0d:	jmp    a21 <botlish_fn_7+0x5a>
     a12:	mov    eax,0x6
     a17:	jmp    a21 <botlish_fn_7+0x5a>
     a1c:	mov    eax,0x6
     a21:	mov    r12,QWORD PTR [rsp]
     a25:	mov    r14,QWORD PTR [rsp+0x8]
     a2a:	add    rsp,0x10
     a2e:	mov    rsp,rbp
     a31:	pop    rbp
     a32:	ret

0000000000000a33 <botlish_entry_7: std::ascii::is_alphanumeric<int>>:
     a33:	push   rbp
     a34:	mov    rbp,rsp
     a37:	mov    rsi,QWORD PTR [rdx]
     a3a:	sar    rsi,1
     a3d:	call   a42 <botlish_entry_7+0xf>
			a3e: R_X86_64_PLT32	botlish_fn_7-0x4 ; std::ascii::is_alphanumeric<int>
     a42:	mov    rsp,rbp
     a45:	pop    rbp
     a46:	ret

0000000000000a47 <botlish_fn_8: std::web::emailish?<str>>:
     a47:	push   rbp
     a48:	mov    rbp,rsp
     a4b:	sub    rsp,0x40
     a4f:	mov    QWORD PTR [rsp+0x20],rbx
     a54:	mov    QWORD PTR [rsp+0x28],r12
     a59:	mov    QWORD PTR [rsp+0x30],r13
     a5e:	mov    QWORD PTR [rsp+0x38],r14
     a63:	mov    r12,rsi
     a66:	mov    QWORD PTR [rsp],rsi
     a6a:	mov    rsi,r12
     a6d:	mov    rdx,QWORD PTR [rsi+0x8]
     a71:	shl    rdx,1
     a74:	mov    rcx,rdx
     a77:	or     rcx,0x1
     a7b:	mov    r14,rdx
     a7e:	mov    QWORD PTR [rsp+0x8],rcx
     a83:	mov    rax,QWORD PTR [rdi+0x10]
     a87:	mov    r13,rdi
     a8a:	mov    rdx,QWORD PTR [rax+0xc0]
     a91:	mov    QWORD PTR [rsp+0x10],rdx
     a96:	xor    rsi,rsi
     a99:	mov    r8,r12
     a9c:	call   aa1 <botlish_fn_8+0x5a>
			a9d: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, block(e276)>
     aa1:	test   rax,rax
     aa4:	je     b49 <botlish_fn_8+0x102>
     aaa:	mov    rbx,rax
     aad:	sar    rbx,1
     ab0:	mov    rdi,rax
     ab3:	test   rbx,rbx
     ab6:	jle    b08 <botlish_fn_8+0xc1>
     abc:	mov    rsi,r14
     abf:	mov    rax,rsi
     ac2:	or     rax,0x1
     ac6:	sar    rax,1
     ac9:	cmp    rbx,rax
     acc:	jl     adc <botlish_fn_8+0x95>
     ad2:	mov    eax,0xa
     ad7:	jmp    b08 <botlish_fn_8+0xc1>
     adc:	mov    edx,0x204
     ae1:	mov    rcx,rsi
     ae4:	or     rcx,0x1
     ae8:	mov    r14,rsi
     aeb:	mov    rsi,rdi
     aee:	mov    rdi,r13
     af1:	mov    r8,r12
     af4:	call   af9 <botlish_fn_8+0xb2>
			af5: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_is?<int, any>
     af9:	cmp    rax,0x6
     afd:	je     b2a <botlish_fn_8+0xe3>
     b03:	mov    eax,0xa
     b08:	mov    eax,0x2
     b0d:	mov    rbx,QWORD PTR [rsp+0x20]
     b12:	mov    r12,QWORD PTR [rsp+0x28]
     b17:	mov    r13,QWORD PTR [rsp+0x30]
     b1c:	mov    r14,QWORD PTR [rsp+0x38]
     b21:	add    rsp,0x40
     b25:	mov    rsp,rbp
     b28:	pop    rbp
     b29:	ret
     b2a:	lea    rsi,[rbx+0x1]
     b2e:	mov    rdx,r14
     b31:	or     rdx,0x1
     b35:	mov    rcx,r12
     b38:	mov    rdi,r13
     b3b:	call   b40 <botlish_fn_8+0xf9>
			b3c: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<int>
     b40:	test   rax,rax
     b43:	jne    b69 <botlish_fn_8+0x122>
     b49:	xor    rax,rax
     b4c:	mov    rbx,QWORD PTR [rsp+0x20]
     b51:	mov    r12,QWORD PTR [rsp+0x28]
     b56:	mov    r13,QWORD PTR [rsp+0x30]
     b5b:	mov    r14,QWORD PTR [rsp+0x38]
     b60:	add    rsp,0x40
     b64:	mov    rsp,rbp
     b67:	pop    rbp
     b68:	ret
     b69:	mov    rbx,QWORD PTR [rsp+0x20]
     b6e:	mov    r12,QWORD PTR [rsp+0x28]
     b73:	mov    r13,QWORD PTR [rsp+0x30]
     b78:	mov    r14,QWORD PTR [rsp+0x38]
     b7d:	add    rsp,0x40
     b81:	mov    rsp,rbp
     b84:	pop    rbp
     b85:	ret

0000000000000b86 <botlish_entry_8: std::web::emailish?<str>>:
     b86:	push   rbp
     b87:	mov    rbp,rsp
     b8a:	mov    rsi,QWORD PTR [rdx]
     b8d:	call   b92 <botlish_entry_8+0xc>
			b8e: R_X86_64_PLT32	botlish_fn_8-0x4 ; std::web::emailish?<str>
     b92:	mov    rsp,rbp
     b95:	pop    rbp
     b96:	ret

0000000000000b97 <botlish_fn_9: char_at<int>>:
     b97:	push   rbp
     b98:	mov    rbp,rsp
     b9b:	sub    rsp,0x20
     b9f:	mov    QWORD PTR [rsp],rsi
     ba3:	mov    QWORD PTR [rsp+0x8],rcx
     ba8:	mov    r8,rcx
     bab:	mov    rax,rsi
     bae:	sar    rax,1
     bb1:	sar    rdx,1
     bb4:	cmp    rax,rdx
     bb7:	jge    be1 <botlish_fn_9+0x4a>
     bbd:	lea    rcx,[rax+0x1]
     bc1:	shl    rcx,1
     bc4:	or     rcx,0x1
     bc8:	mov    QWORD PTR [rsp+0x10],rcx
     bcd:	mov    rdx,rsi
     bd0:	mov    rsi,r8
     bd3:	call   bd8 <botlish_fn_9+0x41>
			bd4: R_X86_64_PLT32	rt_substr_proven-0x4
     bd8:	add    rsp,0x20
     bdc:	mov    rsp,rbp
     bdf:	pop    rbp
     be0:	ret
     be1:	mov    rax,QWORD PTR [rdi+0x10]
     be5:	mov    rax,QWORD PTR [rax+0xc8]
     bec:	add    rsp,0x20
     bf0:	mov    rsp,rbp
     bf3:	pop    rbp
     bf4:	ret

0000000000000bf5 <botlish_entry_9: char_at<int>>:
     bf5:	push   rbp
     bf6:	mov    rbp,rsp
     bf9:	mov    rsi,QWORD PTR [rdx]
     bfc:	mov    r8,QWORD PTR [rdx+0x8]
     c00:	mov    rcx,QWORD PTR [rdx+0x10]
     c04:	mov    rdx,r8
     c07:	call   c0c <botlish_entry_9+0x17>
			c08: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     c0c:	mov    rsp,rbp
     c0f:	pop    rbp
     c10:	ret

0000000000000c11 <botlish_fn_10: char_at<int>>:
     c11:	push   rbp
     c12:	mov    rbp,rsp
     c15:	mov    rax,rsi
     c18:	sar    rax,1
     c1b:	sar    rdx,1
     c1e:	cmp    rax,rdx
     c21:	jge    c44 <botlish_fn_10+0x33>
     c27:	mov    QWORD PTR [r8],rsi
     c2a:	add    rax,0x1
     c31:	shl    rax,1
     c34:	or     rax,0x1
     c38:	mov    QWORD PTR [r8+0x8],rax
     c3c:	mov    rax,rcx
     c3f:	mov    rsp,rbp
     c42:	pop    rbp
     c43:	ret
     c44:	mov    rax,QWORD PTR [rdi+0x10]
     c48:	mov    rax,QWORD PTR [rax+0xc8]
     c4f:	mov    QWORD PTR [r8],0x1
     c56:	mov    QWORD PTR [r8+0x8],0x1
     c5e:	mov    rsp,rbp
     c61:	pop    rbp
     c62:	ret

0000000000000c63 <botlish_entry_10: char_at<int>>:
     c63:	push   rbp
     c64:	mov    rbp,rsp
     c67:	ud2
     c69:	add    BYTE PTR [rax],al
     c6b:	add    BYTE PTR [rax],al
     c6d:	add    BYTE PTR [rax],al
	...

0000000000000c70 <botlish_fn_11: char_is?<int, any>>:
     c70:	push   rbp
     c71:	mov    rbp,rsp
     c74:	sub    rsp,0x10
     c78:	mov    QWORD PTR [rsp],rbx
     c7c:	mov    rbx,rdx
     c7f:	mov    rax,rsi
     c82:	sar    rax,1
     c85:	sar    rcx,1
     c88:	cmp    rax,rcx
     c8b:	jge    cec <botlish_fn_11+0x7c>
     c91:	movzx  rcx,BYTE PTR [r8+0x18]
     c96:	mov    rdx,r8
     c99:	test   rcx,rcx
     c9c:	jne    cb8 <botlish_fn_11+0x48>
     ca2:	mov    rax,rdx
     ca5:	mov    rdx,rsi
     ca8:	mov    rsi,rax
     cab:	call   cb0 <botlish_fn_11+0x40>
			cac: R_X86_64_PLT32	rt_str_char_at_proven-0x4
     cb0:	mov    rcx,rax
     cb3:	jmp    ccc <botlish_fn_11+0x5c>
     cb8:	mov    rsi,rdx
     cbb:	movzx  rax,BYTE PTR [rsi+rax*1+0x19]
     cc1:	shl    rax,0x3
     cc5:	or     rax,0x4
     cc9:	mov    rcx,rax
     ccc:	mov    eax,0x2
     cd1:	mov    rdx,rbx
     cd4:	cmp    rcx,rdx
     cd7:	cmove  rax,QWORD PTR [rip+0x21]        # d00 <botlish_fn_11+0x90>
     cdf:	mov    rbx,QWORD PTR [rsp]
     ce3:	add    rsp,0x10
     ce7:	mov    rsp,rbp
     cea:	pop    rbp
     ceb:	ret
     cec:	mov    eax,0x2
     cf1:	mov    rbx,QWORD PTR [rsp]
     cf5:	add    rsp,0x10
     cf9:	mov    rsp,rbp
     cfc:	pop    rbp
     cfd:	ret
     cfe:	add    BYTE PTR [rax],al
     d00:	(bad)
     d01:	add    BYTE PTR [rax],al
     d03:	add    BYTE PTR [rax],al
     d05:	add    BYTE PTR [rax],al
	...

0000000000000d08 <botlish_entry_11: char_is?<int, any>>:
     d08:	push   rbp
     d09:	mov    rbp,rsp
     d0c:	mov    rsi,QWORD PTR [rdx]
     d0f:	mov    r9,QWORD PTR [rdx+0x8]
     d13:	mov    rcx,QWORD PTR [rdx+0x10]
     d17:	mov    r8,QWORD PTR [rdx+0x18]
     d1b:	mov    rdx,r9
     d1e:	call   d23 <botlish_entry_11+0x1b>
			d1f: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_is?<int, any>
     d23:	mov    rsp,rbp
     d26:	pop    rbp
     d27:	ret

0000000000000d28 <botlish_fn_12: local_char?<str>>:
     d28:	push   rbp
     d29:	mov    rbp,rsp
     d2c:	sub    rsp,0x10
     d30:	mov    QWORD PTR [rsp],rbx
     d34:	mov    QWORD PTR [rsp+0x8],r14
     d39:	mov    rbx,rdi
     d3c:	mov    r14,rsi
     d3f:	mov    rsi,r14
     d42:	mov    rdi,rbx
     d45:	call   d4a <botlish_fn_12+0x22>
			d46: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     d4a:	test   rax,rax
     d4d:	jne    d68 <botlish_fn_12+0x40>
     d53:	xor    rax,rax
     d56:	mov    rbx,QWORD PTR [rsp]
     d5a:	mov    r14,QWORD PTR [rsp+0x8]
     d5f:	add    rsp,0x10
     d63:	mov    rsp,rbp
     d66:	pop    rbp
     d67:	ret
     d68:	cmp    rax,0x6
     d6c:	je     da2 <botlish_fn_12+0x7a>
     d72:	mov    rdi,rbx
     d75:	mov    rax,QWORD PTR [rdi+0x30]
     d79:	mov    rsi,QWORD PTR [rax]
     d7c:	mov    rdx,r14
     d7f:	call   d84 <botlish_fn_12+0x5c>
			d80: R_X86_64_PLT32	rt_set_contains-0x4
     d84:	cmp    rax,0x6
     d88:	je     d98 <botlish_fn_12+0x70>
     d8e:	mov    eax,0x2
     d93:	jmp    da7 <botlish_fn_12+0x7f>
     d98:	mov    eax,0x6
     d9d:	jmp    da7 <botlish_fn_12+0x7f>
     da2:	mov    eax,0x6
     da7:	mov    rbx,QWORD PTR [rsp]
     dab:	mov    r14,QWORD PTR [rsp+0x8]
     db0:	add    rsp,0x10
     db4:	mov    rsp,rbp
     db7:	pop    rbp
     db8:	ret

0000000000000db9 <botlish_entry_12: local_char?<str>>:
     db9:	push   rbp
     dba:	mov    rbp,rsp
     dbd:	mov    rsi,QWORD PTR [rdx]
     dc0:	call   dc5 <botlish_entry_12+0xc>
			dc1: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     dc5:	mov    rsp,rbp
     dc8:	pop    rbp
     dc9:	ret

0000000000000dca <botlish_fn_13: local_char?<generic>>:
     dca:	push   rbp
     dcb:	mov    rbp,rsp
     dce:	sub    rsp,0x10
     dd2:	mov    QWORD PTR [rsp],rbx
     dd6:	mov    QWORD PTR [rsp+0x8],r14
     ddb:	mov    rbx,rdi
     dde:	mov    r14,rsi
     de1:	mov    rsi,r14
     de4:	mov    rdi,rbx
     de7:	call   dec <botlish_fn_13+0x22>
			de8: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     dec:	test   rax,rax
     def:	jne    e0a <botlish_fn_13+0x40>
     df5:	xor    rax,rax
     df8:	mov    rbx,QWORD PTR [rsp]
     dfc:	mov    r14,QWORD PTR [rsp+0x8]
     e01:	add    rsp,0x10
     e05:	mov    rsp,rbp
     e08:	pop    rbp
     e09:	ret
     e0a:	cmp    rax,0x6
     e0e:	je     e44 <botlish_fn_13+0x7a>
     e14:	mov    rdi,rbx
     e17:	mov    rax,QWORD PTR [rdi+0x30]
     e1b:	mov    rsi,QWORD PTR [rax]
     e1e:	mov    rdx,r14
     e21:	call   e26 <botlish_fn_13+0x5c>
			e22: R_X86_64_PLT32	rt_set_contains-0x4
     e26:	cmp    rax,0x6
     e2a:	je     e3a <botlish_fn_13+0x70>
     e30:	mov    eax,0x2
     e35:	jmp    e49 <botlish_fn_13+0x7f>
     e3a:	mov    eax,0x6
     e3f:	jmp    e49 <botlish_fn_13+0x7f>
     e44:	mov    eax,0x6
     e49:	mov    rbx,QWORD PTR [rsp]
     e4d:	mov    r14,QWORD PTR [rsp+0x8]
     e52:	add    rsp,0x10
     e56:	mov    rsp,rbp
     e59:	pop    rbp
     e5a:	ret

0000000000000e5b <botlish_entry_13: local_char?<generic>>:
     e5b:	push   rbp
     e5c:	mov    rbp,rsp
     e5f:	mov    rsi,QWORD PTR [rdx]
     e62:	call   e67 <botlish_entry_13+0xc>
			e63: R_X86_64_PLT32	botlish_fn_13-0x4 ; local_char?<generic>
     e67:	mov    rsp,rbp
     e6a:	pop    rbp
     e6b:	ret

0000000000000e6c <botlish_fn_14: scan_while<int, block(e276)>>:
     e6c:	push   rbp
     e6d:	mov    rbp,rsp
     e70:	sub    rsp,0x50
     e74:	mov    QWORD PTR [rsp+0x20],rbx
     e79:	mov    QWORD PTR [rsp+0x28],r12
     e7e:	mov    QWORD PTR [rsp+0x30],r13
     e83:	mov    QWORD PTR [rsp+0x38],r14
     e88:	mov    QWORD PTR [rsp+0x40],r15
     e8d:	mov    QWORD PTR [rsp+0x18],rdi
     e92:	mov    QWORD PTR [rsp],rcx
     e96:	mov    QWORD PTR [rsp+0x8],r8
     e9b:	mov    r15,r8
     e9e:	mov    r12,rcx
     ea1:	sar    r12,1
     ea4:	mov    r14,rcx
     ea7:	mov    rbx,rsi
     eaa:	cmp    rbx,r12
     ead:	jl     ed8 <botlish_fn_14+0x6c>
     eb3:	mov    rax,r14
     eb6:	mov    rbx,QWORD PTR [rsp+0x20]
     ebb:	mov    r12,QWORD PTR [rsp+0x28]
     ec0:	mov    r13,QWORD PTR [rsp+0x30]
     ec5:	mov    r14,QWORD PTR [rsp+0x38]
     eca:	mov    r15,QWORD PTR [rsp+0x40]
     ecf:	add    rsp,0x50
     ed3:	mov    rsp,rbp
     ed6:	pop    rbp
     ed7:	ret
     ed8:	mov    r13,rbx
     edb:	shl    r13,1
     ede:	or     r13,0x1
     ee2:	mov    QWORD PTR [rsp+0x10],r13
     ee7:	mov    rcx,r15
     eea:	mov    rdx,r14
     eed:	mov    rsi,r13
     ef0:	mov    rdi,QWORD PTR [rsp+0x18]
     ef5:	call   efa <botlish_fn_14+0x8e>
			ef6: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     efa:	mov    rsi,rax
     efd:	mov    rdi,QWORD PTR [rsp+0x18]
     f02:	call   f07 <botlish_fn_14+0x9b>
			f03: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     f07:	test   rax,rax
     f0a:	jne    f35 <botlish_fn_14+0xc9>
     f10:	xor    rax,rax
     f13:	mov    rbx,QWORD PTR [rsp+0x20]
     f18:	mov    r12,QWORD PTR [rsp+0x28]
     f1d:	mov    r13,QWORD PTR [rsp+0x30]
     f22:	mov    r14,QWORD PTR [rsp+0x38]
     f27:	mov    r15,QWORD PTR [rsp+0x40]
     f2c:	add    rsp,0x50
     f30:	mov    rsp,rbp
     f33:	pop    rbp
     f34:	ret
     f35:	cmp    rax,0x6
     f39:	je     f64 <botlish_fn_14+0xf8>
     f3f:	mov    rax,r13
     f42:	mov    rbx,QWORD PTR [rsp+0x20]
     f47:	mov    r12,QWORD PTR [rsp+0x28]
     f4c:	mov    r13,QWORD PTR [rsp+0x30]
     f51:	mov    r14,QWORD PTR [rsp+0x38]
     f56:	mov    r15,QWORD PTR [rsp+0x40]
     f5b:	add    rsp,0x50
     f5f:	mov    rsp,rbp
     f62:	pop    rbp
     f63:	ret
     f64:	add    rbx,0x1
     f6b:	jmp    eaa <botlish_fn_14+0x3e>

0000000000000f70 <botlish_entry_14: scan_while<int, block(e276)>>:
     f70:	push   rbp
     f71:	mov    rbp,rsp
     f74:	mov    rsi,QWORD PTR [rdx]
     f77:	mov    r9,QWORD PTR [rdx+0x8]
     f7b:	mov    rcx,QWORD PTR [rdx+0x10]
     f7f:	mov    r8,QWORD PTR [rdx+0x18]
     f83:	sar    rsi,1
     f86:	mov    rdx,r9
     f89:	call   f8e <botlish_entry_14+0x1e>
			f8a: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, block(e276)>
     f8e:	mov    rsp,rbp
     f91:	pop    rbp
     f92:	ret

0000000000000f93 <botlish_fn_15: scan_while<int, native(std::str::is_tcl_alpha)>>:
     f93:	push   rbp
     f94:	mov    rbp,rsp
     f97:	sub    rsp,0x40
     f9b:	mov    QWORD PTR [rsp+0x10],rbx
     fa0:	mov    QWORD PTR [rsp+0x18],r12
     fa5:	mov    QWORD PTR [rsp+0x20],r13
     faa:	mov    QWORD PTR [rsp+0x28],r14
     faf:	mov    QWORD PTR [rsp+0x30],r15
     fb4:	mov    rbx,r8
     fb7:	mov    r13,rdi
     fba:	mov    rax,rcx
     fbd:	sar    rax,1
     fc0:	mov    r12,rcx
     fc3:	mov    r14,rax
     fc6:	mov    rax,rsi
     fc9:	mov    rcx,r14
     fcc:	cmp    rax,rcx
     fcf:	mov    r14,rcx
     fd2:	jl     1002 <botlish_fn_15+0x6f>
     fd8:	mov    edx,0x1
     fdd:	mov    rax,r14
     fe0:	mov    rbx,QWORD PTR [rsp+0x10]
     fe5:	mov    r12,QWORD PTR [rsp+0x18]
     fea:	mov    r13,QWORD PTR [rsp+0x20]
     fef:	mov    r14,QWORD PTR [rsp+0x28]
     ff4:	mov    r15,QWORD PTR [rsp+0x30]
     ff9:	add    rsp,0x40
     ffd:	mov    rsp,rbp
    1000:	pop    rbp
    1001:	ret
    1002:	mov    rsi,rax
    1005:	shl    rsi,1
    1008:	mov    r15,rax
    100b:	or     rsi,0x1
    100f:	lea    r8,[rsp]
    1013:	mov    rcx,rbx
    1016:	mov    rdx,r12
    1019:	mov    rdi,r13
    101c:	call   1021 <botlish_fn_15+0x8e>
			101d: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    1021:	mov    rdx,QWORD PTR [rsp]
    1025:	mov    rcx,QWORD PTR [rsp+0x8]
    102a:	mov    rsi,rax
    102d:	mov    rdi,r13
    1030:	call   1035 <botlish_fn_15+0xa2>
			1031: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    1035:	test   rax,rax
    1038:	jne    1066 <botlish_fn_15+0xd3>
    103e:	xor    rdx,rdx
    1041:	mov    rax,rdx
    1044:	mov    rbx,QWORD PTR [rsp+0x10]
    1049:	mov    r12,QWORD PTR [rsp+0x18]
    104e:	mov    r13,QWORD PTR [rsp+0x20]
    1053:	mov    r14,QWORD PTR [rsp+0x28]
    1058:	mov    r15,QWORD PTR [rsp+0x30]
    105d:	add    rsp,0x40
    1061:	mov    rsp,rbp
    1064:	pop    rbp
    1065:	ret
    1066:	cmp    rax,0x6
    106a:	je     109a <botlish_fn_15+0x107>
    1070:	mov    edx,0x1
    1075:	mov    rax,r15
    1078:	mov    rbx,QWORD PTR [rsp+0x10]
    107d:	mov    r12,QWORD PTR [rsp+0x18]
    1082:	mov    r13,QWORD PTR [rsp+0x20]
    1087:	mov    r14,QWORD PTR [rsp+0x28]
    108c:	mov    r15,QWORD PTR [rsp+0x30]
    1091:	add    rsp,0x40
    1095:	mov    rsp,rbp
    1098:	pop    rbp
    1099:	ret
    109a:	mov    rax,r15
    109d:	add    rax,0x1
    10a4:	mov    rcx,r14
    10a7:	jmp    fcc <botlish_fn_15+0x39>

00000000000010ac <botlish_entry_15: scan_while<int, native(std::str::is_tcl_alpha)>>:
    10ac:	push   rbp
    10ad:	mov    rbp,rsp
    10b0:	mov    rsi,QWORD PTR [rdx]
    10b3:	mov    rax,QWORD PTR [rdx+0x8]
    10b7:	mov    rcx,QWORD PTR [rdx+0x10]
    10bb:	mov    r8,QWORD PTR [rdx+0x18]
    10bf:	sar    rsi,1
    10c2:	mov    rdx,rax
    10c5:	call   10ca <botlish_entry_15+0x1e>
			10c6: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<int, native(std::str::is_tcl_alpha)>
    10ca:	shl    rax,1
    10cd:	or     rax,0x1
    10d1:	mov    rcx,rax
    10d4:	xor    rax,rax
    10d7:	test   rdx,rdx
    10da:	cmovne rax,rcx
    10de:	mov    rsp,rbp
    10e1:	pop    rbp
    10e2:	ret
    10e3:	add    BYTE PTR [rax],al
    10e5:	add    BYTE PTR [rax],al
	...

00000000000010e8 <botlish_fn_16: tld?<int>>:
    10e8:	push   rbp
    10e9:	mov    rbp,rsp
    10ec:	sub    rsp,0x10
    10f0:	mov    QWORD PTR [rsp],rbx
    10f4:	mov    QWORD PTR [rsp+0x8],r12
    10f9:	mov    r8,rdx
    10fc:	mov    rax,QWORD PTR [rdi+0x10]
    1100:	mov    rdx,QWORD PTR [rax+0xd0]
    1107:	mov    r12,r8
    110a:	mov    r8,rcx
    110d:	mov    rbx,rsi
    1110:	mov    rcx,r12
    1113:	call   1118 <botlish_fn_16+0x30>
			1114: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<int, native(std::str::is_tcl_alpha)>
    1118:	test   rdx,rdx
    111b:	jne    1136 <botlish_fn_16+0x4e>
    1121:	xor    rax,rax
    1124:	mov    rbx,QWORD PTR [rsp]
    1128:	mov    r12,QWORD PTR [rsp+0x8]
    112d:	add    rsp,0x10
    1131:	mov    rsp,rbp
    1134:	pop    rbp
    1135:	ret
    1136:	sar    r12,1
    1139:	cmp    rax,r12
    113c:	je     114c <botlish_fn_16+0x64>
    1142:	mov    eax,0x2
    1147:	jmp    1163 <botlish_fn_16+0x7b>
    114c:	sub    rax,rbx
    114f:	mov    rcx,rax
    1152:	mov    eax,0x2
    1157:	cmp    rcx,0x2
    115b:	cmovge rax,QWORD PTR [rip+0x15]        # 1178 <botlish_fn_16+0x90>
    1163:	mov    rbx,QWORD PTR [rsp]
    1167:	mov    r12,QWORD PTR [rsp+0x8]
    116c:	add    rsp,0x10
    1170:	mov    rsp,rbp
    1173:	pop    rbp
    1174:	ret
    1175:	add    BYTE PTR [rax],al
    1177:	add    BYTE PTR [rsi],al
    1179:	add    BYTE PTR [rax],al
    117b:	add    BYTE PTR [rax],al
    117d:	add    BYTE PTR [rax],al
	...

0000000000001180 <botlish_entry_16: tld?<int>>:
    1180:	push   rbp
    1181:	mov    rbp,rsp
    1184:	mov    rsi,QWORD PTR [rdx]
    1187:	mov    r8,QWORD PTR [rdx+0x8]
    118b:	mov    rcx,QWORD PTR [rdx+0x10]
    118f:	sar    rsi,1
    1192:	mov    rdx,r8
    1195:	call   119a <botlish_entry_16+0x1a>
			1196: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<int>
    119a:	mov    rsp,rbp
    119d:	pop    rbp
    119e:	ret

000000000000119f <botlish_fn_17: domain?<int>>:
    119f:	push   rbp
    11a0:	mov    rbp,rsp
    11a3:	sub    rsp,0x60
    11a7:	mov    QWORD PTR [rsp+0x30],rbx
    11ac:	mov    QWORD PTR [rsp+0x38],r12
    11b1:	mov    QWORD PTR [rsp+0x40],r13
    11b6:	mov    QWORD PTR [rsp+0x48],r14
    11bb:	mov    QWORD PTR [rsp+0x50],r15
    11c0:	mov    r13,rsi
    11c3:	mov    r15,rcx
    11c6:	mov    r14,rdx
    11c9:	sar    r14,1
    11cc:	mov    QWORD PTR [rsp+0x10],rdx
    11d1:	mov    r12,r13
    11d4:	cmp    r12,r14
    11d7:	jge    1343 <botlish_fn_17+0x1a4>
    11dd:	mov    rsi,r12
    11e0:	shl    rsi,1
    11e3:	or     rsi,0x1
    11e7:	mov    QWORD PTR [rsp+0x28],rsi
    11ec:	mov    edx,0x174
    11f1:	mov    rbx,rdi
    11f4:	mov    rcx,QWORD PTR [rsp+0x10]
    11f9:	mov    r8,r15
    11fc:	call   1201 <botlish_fn_17+0x62>
			11fd: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_is?<int, any>
    1201:	cmp    rax,0x6
    1205:	je     128a <botlish_fn_17+0xeb>
    120b:	lea    r8,[rsp]
    120f:	mov    rsi,QWORD PTR [rsp+0x28]
    1214:	mov    rcx,r15
    1217:	mov    rdx,QWORD PTR [rsp+0x10]
    121c:	mov    rdi,rbx
    121f:	call   1224 <botlish_fn_17+0x85>
			1220: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    1224:	mov    QWORD PTR [rsp+0x28],rax
    1229:	mov    rdx,QWORD PTR [rsp]
    122d:	mov    QWORD PTR [rsp+0x20],rdx
    1232:	mov    rcx,QWORD PTR [rsp+0x8]
    1237:	mov    QWORD PTR [rsp+0x18],rcx
    123c:	mov    rsi,QWORD PTR [rsp+0x28]
    1241:	mov    rdi,rbx
    1244:	call   1249 <botlish_fn_17+0xaa>
			1245: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1249:	test   rax,rax
    124c:	je     12de <botlish_fn_17+0x13f>
    1252:	cmp    rax,0x6
    1256:	je     130d <botlish_fn_17+0x16e>
    125c:	mov    rax,QWORD PTR [rbx+0x10]
    1260:	mov    r8,QWORD PTR [rax+0x20]
    1264:	mov    rcx,QWORD PTR [rsp+0x18]
    1269:	mov    rdx,QWORD PTR [rsp+0x20]
    126e:	mov    rsi,QWORD PTR [rsp+0x28]
    1273:	mov    rdi,rbx
    1276:	call   127b <botlish_fn_17+0xdc>
			1277: R_X86_64_PLT32	rt_str_region_eq-0x4
    127b:	cmp    rax,0x6
    127f:	jne    1343 <botlish_fn_17+0x1a4>
    1285:	jmp    130d <botlish_fn_17+0x16e>
    128a:	cmp    r12,r13
    128d:	je     1343 <botlish_fn_17+0x1a4>
    1293:	mov    rsi,r12
    1296:	sub    rsi,0x1
    129a:	shl    rsi,1
    129d:	or     rsi,0x1
    12a1:	mov    edx,0x174
    12a6:	mov    rcx,QWORD PTR [rsp+0x10]
    12ab:	mov    rdi,rbx
    12ae:	mov    r8,r15
    12b1:	call   12b6 <botlish_fn_17+0x117>
			12b2: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_is?<int, any>
    12b6:	cmp    rax,0x6
    12ba:	je     1343 <botlish_fn_17+0x1a4>
    12c0:	lea    rsi,[r12+0x1]
    12c5:	mov    rcx,r15
    12c8:	mov    rdx,QWORD PTR [rsp+0x10]
    12cd:	mov    rdi,rbx
    12d0:	call   12d5 <botlish_fn_17+0x136>
			12d1: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<int>
    12d5:	test   rax,rax
    12d8:	jne    1303 <botlish_fn_17+0x164>
    12de:	xor    rax,rax
    12e1:	mov    rbx,QWORD PTR [rsp+0x30]
    12e6:	mov    r12,QWORD PTR [rsp+0x38]
    12eb:	mov    r13,QWORD PTR [rsp+0x40]
    12f0:	mov    r14,QWORD PTR [rsp+0x48]
    12f5:	mov    r15,QWORD PTR [rsp+0x50]
    12fa:	add    rsp,0x60
    12fe:	mov    rsp,rbp
    1301:	pop    rbp
    1302:	ret
    1303:	cmp    rax,0x6
    1307:	je     131c <botlish_fn_17+0x17d>
    130d:	add    r12,0x1
    1314:	mov    rdi,rbx
    1317:	jmp    11d4 <botlish_fn_17+0x35>
    131c:	mov    eax,0x6
    1321:	mov    rbx,QWORD PTR [rsp+0x30]
    1326:	mov    r12,QWORD PTR [rsp+0x38]
    132b:	mov    r13,QWORD PTR [rsp+0x40]
    1330:	mov    r14,QWORD PTR [rsp+0x48]
    1335:	mov    r15,QWORD PTR [rsp+0x50]
    133a:	add    rsp,0x60
    133e:	mov    rsp,rbp
    1341:	pop    rbp
    1342:	ret
    1343:	mov    eax,0x2
    1348:	mov    rbx,QWORD PTR [rsp+0x30]
    134d:	mov    r12,QWORD PTR [rsp+0x38]
    1352:	mov    r13,QWORD PTR [rsp+0x40]
    1357:	mov    r14,QWORD PTR [rsp+0x48]
    135c:	mov    r15,QWORD PTR [rsp+0x50]
    1361:	add    rsp,0x60
    1365:	mov    rsp,rbp
    1368:	pop    rbp
    1369:	ret

000000000000136a <botlish_entry_17: domain?<int>>:
    136a:	push   rbp
    136b:	mov    rbp,rsp
    136e:	mov    rsi,QWORD PTR [rdx]
    1371:	mov    r8,QWORD PTR [rdx+0x8]
    1375:	mov    rcx,QWORD PTR [rdx+0x10]
    1379:	sar    rsi,1
    137c:	mov    rdx,r8
    137f:	call   1384 <botlish_entry_17+0x1a>
			1380: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<int>
    1384:	mov    rsp,rbp
    1387:	pop    rbp
    1388:	ret

0000000000001389 <botlish_fn_18: std::web::is_unreserved<int>>:
    1389:	push   rbp
    138a:	mov    rbp,rsp
    138d:	sub    rsp,0x10
    1391:	mov    QWORD PTR [rsp],rbx
    1395:	mov    QWORD PTR [rsp+0x8],r14
    139a:	mov    r14,rsi
    139d:	mov    rsi,r14
    13a0:	sar    rsi,1
    13a3:	mov    rbx,rdi
    13a6:	call   13ab <botlish_fn_18+0x22>
			13a7: R_X86_64_PLT32	botlish_fn_7-0x4 ; std::ascii::is_alphanumeric<int>
    13ab:	cmp    rax,0x6
    13af:	je     13e6 <botlish_fn_18+0x5d>
    13b5:	mov    rax,QWORD PTR [rbx+0x30]
    13b9:	mov    rsi,QWORD PTR [rax+0x10]
    13bd:	mov    rdx,r14
    13c0:	mov    rdi,rbx
    13c3:	call   13c8 <botlish_fn_18+0x3f>
			13c4: R_X86_64_PLT32	rt_set_contains-0x4
    13c8:	cmp    rax,0x6
    13cc:	je     13dc <botlish_fn_18+0x53>
    13d2:	mov    eax,0x2
    13d7:	jmp    13eb <botlish_fn_18+0x62>
    13dc:	mov    eax,0x6
    13e1:	jmp    13eb <botlish_fn_18+0x62>
    13e6:	mov    eax,0x6
    13eb:	mov    rbx,QWORD PTR [rsp]
    13ef:	mov    r14,QWORD PTR [rsp+0x8]
    13f4:	add    rsp,0x10
    13f8:	mov    rsp,rbp
    13fb:	pop    rbp
    13fc:	ret

00000000000013fd <botlish_entry_18: std::web::is_unreserved<int>>:
    13fd:	push   rbp
    13fe:	mov    rbp,rsp
    1401:	mov    rsi,QWORD PTR [rdx]
    1404:	call   1409 <botlish_entry_18+0xc>
			1405: R_X86_64_PLT32	botlish_fn_18-0x4 ; std::web::is_unreserved<int>
    1409:	mov    rsp,rbp
    140c:	pop    rbp
    140d:	ret

000000000000140e <botlish_fn_19: std::web::uri_query_value?<str>>:
    140e:	push   rbp
    140f:	mov    rbp,rsp
    1412:	sub    rsp,0x10
    1416:	mov    QWORD PTR [rsp],rsi
    141a:	mov    rdx,rsi
    141d:	mov    esi,0x1
    1422:	mov    QWORD PTR [rsp+0x8],0x1
    142b:	call   1430 <botlish_fn_19+0x22>
			142c: R_X86_64_PLT32	botlish_fn_21-0x4 ; valid_from?<int>
    1430:	add    rsp,0x10
    1434:	mov    rsp,rbp
    1437:	pop    rbp
    1438:	ret

0000000000001439 <botlish_entry_19: std::web::uri_query_value?<str>>:
    1439:	push   rbp
    143a:	mov    rbp,rsp
    143d:	mov    rsi,QWORD PTR [rdx]
    1440:	call   1445 <botlish_entry_19+0xc>
			1441: R_X86_64_PLT32	botlish_fn_19-0x4 ; std::web::uri_query_value?<str>
    1445:	mov    rsp,rbp
    1448:	pop    rbp
    1449:	ret
    144a:	add    BYTE PTR [rax],al
    144c:	add    BYTE PTR [rax],al
	...

0000000000001450 <botlish_fn_20: upper_hex?<int>>:
    1450:	push   rbp
    1451:	mov    rbp,rsp
    1454:	sub    rsp,0x20
    1458:	mov    QWORD PTR [rsp],rbx
    145c:	mov    QWORD PTR [rsp+0x8],r12
    1461:	mov    QWORD PTR [rsp+0x10],r13
    1466:	mov    r12,rdi
    1469:	mov    r13,rdx
    146c:	mov    rdx,r13
    146f:	mov    rdx,QWORD PTR [rdx+0x8]
    1473:	shl    rdx,1
    1476:	mov    rax,rdx
    1479:	or     rax,0x1
    147d:	mov    rcx,rsi
    1480:	and    rcx,rax
    1483:	test   rcx,0x1
    148a:	jne    14b7 <botlish_fn_20+0x67>
    1490:	or     rdx,0x1
    1494:	mov    rbx,rsi
    1497:	mov    rdi,r12
    149a:	call   149f <botlish_fn_20+0x4f>
			149b: R_X86_64_PLT32	rt_int_cmp-0x4
    149f:	mov    ecx,0x2
    14a4:	test   rax,rax
    14a7:	cmovge rcx,QWORD PTR [rip+0xf9]        # 15a8 <botlish_fn_20+0x158>
    14af:	mov    rsi,rbx
    14b2:	jmp    14ce <botlish_fn_20+0x7e>
    14b7:	mov    rbx,rsi
    14ba:	or     rdx,0x1
    14be:	mov    ecx,0x2
    14c3:	cmp    rbx,rdx
    14c6:	cmovge rcx,QWORD PTR [rip+0xda]        # 15a8 <botlish_fn_20+0x158>
    14ce:	mov    eax,0x6
    14d3:	mov    rbx,rax
    14d6:	cmp    rcx,0x6
    14da:	je     158c <botlish_fn_20+0x13c>
    14e0:	mov    rdx,r13
    14e3:	movzx  rax,BYTE PTR [rdx+0x18]
    14e8:	test   rax,rax
    14eb:	jne    1504 <botlish_fn_20+0xb4>
    14f1:	mov    rdx,rsi
    14f4:	mov    rsi,r13
    14f7:	mov    rdi,r12
    14fa:	call   14ff <botlish_fn_20+0xaf>
			14fb: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    14ff:	jmp    151e <botlish_fn_20+0xce>
    1504:	mov    rdx,rsi
    1507:	mov    rsi,r13
    150a:	mov    rax,rdx
    150d:	sar    rax,1
    1510:	movzx  rax,BYTE PTR [rsi+rax*1+0x19]
    1516:	shl    rax,0x3
    151a:	or     rax,0x4
    151e:	shr    rax,0x3
    1522:	shl    rax,1
    1525:	or     rax,0x1
    1529:	sar    rax,1
    152c:	cmp    rax,0x7f
    1530:	mov    r13,rax
    1533:	jle    1546 <botlish_fn_20+0xf6>
    1539:	mov    eax,0x2
    153e:	mov    rbx,rax
    1541:	jmp    1591 <botlish_fn_20+0x141>
    1546:	mov    rdi,r12
    1549:	mov    rsi,r13
    154c:	call   1551 <botlish_fn_20+0x101>
			154d: R_X86_64_PLT32	botlish_fn_3-0x4 ; std::ascii::is_digit<int>
    1551:	cmp    rax,0x6
    1555:	jne    1563 <botlish_fn_20+0x113>
    155b:	mov    rax,rbx
    155e:	jmp    1591 <botlish_fn_20+0x141>
    1563:	mov    rax,r13
    1566:	cmp    rax,0x41
    156a:	jl     1582 <botlish_fn_20+0x132>
    1570:	cmp    rax,0x46
    1574:	jg     1582 <botlish_fn_20+0x132>
    157a:	mov    rax,rbx
    157d:	jmp    1591 <botlish_fn_20+0x141>
    1582:	mov    eax,0x2
    1587:	jmp    1591 <botlish_fn_20+0x141>
    158c:	mov    eax,0x2
    1591:	mov    rbx,QWORD PTR [rsp]
    1595:	mov    r12,QWORD PTR [rsp+0x8]
    159a:	mov    r13,QWORD PTR [rsp+0x10]
    159f:	add    rsp,0x20
    15a3:	mov    rsp,rbp
    15a6:	pop    rbp
    15a7:	ret
    15a8:	(bad)
    15a9:	add    BYTE PTR [rax],al
    15ab:	add    BYTE PTR [rax],al
    15ad:	add    BYTE PTR [rax],al
	...

00000000000015b0 <botlish_entry_20: upper_hex?<int>>:
    15b0:	push   rbp
    15b1:	mov    rbp,rsp
    15b4:	mov    rsi,QWORD PTR [rdx]
    15b7:	mov    rdx,QWORD PTR [rdx+0x8]
    15bb:	call   15c0 <botlish_entry_20+0x10>
			15bc: R_X86_64_PLT32	botlish_fn_20-0x4 ; upper_hex?<int>
    15c0:	mov    rsp,rbp
    15c3:	pop    rbp
    15c4:	ret
    15c5:	add    BYTE PTR [rax],al
	...

00000000000015c8 <botlish_fn_21: valid_from?<int>>:
    15c8:	push   rbp
    15c9:	mov    rbp,rsp
    15cc:	sub    rsp,0x40
    15d0:	mov    QWORD PTR [rsp+0x20],rbx
    15d5:	mov    QWORD PTR [rsp+0x28],r12
    15da:	mov    QWORD PTR [rsp+0x30],r13
    15df:	mov    r12,rdi
    15e2:	mov    QWORD PTR [rsp],rsi
    15e6:	mov    r13,rsi
    15e9:	mov    QWORD PTR [rsp+0x8],rdx
    15ee:	mov    rbx,rdx
    15f1:	mov    rdx,QWORD PTR [rbx+0x8]
    15f5:	shl    rdx,1
    15f8:	or     rdx,0x1
    15fc:	mov    rsi,r13
    15ff:	mov    rax,rsi
    1602:	and    rax,rdx
    1605:	test   rax,0x1
    160b:	jne    1631 <botlish_fn_21+0x69>
    1611:	mov    rsi,r13
    1614:	mov    rdi,r12
    1617:	call   161c <botlish_fn_21+0x54>
			1618: R_X86_64_PLT32	rt_int_cmp-0x4
    161c:	mov    ecx,0x2
    1621:	test   rax,rax
    1624:	cmovge rcx,QWORD PTR [rip+0x1dc]        # 1808 <botlish_fn_21+0x240>
    162c:	jmp    1644 <botlish_fn_21+0x7c>
    1631:	mov    ecx,0x2
    1636:	mov    rsi,r13
    1639:	cmp    rsi,rdx
    163c:	cmovge rcx,QWORD PTR [rip+0x1c4]        # 1808 <botlish_fn_21+0x240>
    1644:	cmp    rcx,0x6
    1648:	je     17e7 <botlish_fn_21+0x21f>
    164e:	movzx  rax,BYTE PTR [rbx+0x18]
    1653:	test   rax,rax
    1656:	jne    1672 <botlish_fn_21+0xaa>
    165c:	mov    rdx,r13
    165f:	mov    rsi,rbx
    1662:	mov    rdi,r12
    1665:	call   166a <botlish_fn_21+0xa2>
			1666: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    166a:	mov    rsi,rax
    166d:	jmp    1689 <botlish_fn_21+0xc1>
    1672:	mov    rsi,r13
    1675:	mov    rax,rsi
    1678:	sar    rax,1
    167b:	movzx  rsi,BYTE PTR [rbx+rax*1+0x19]
    1681:	shl    rsi,0x3
    1685:	or     rsi,0x4
    1689:	cmp    rsi,0x12c
    1690:	je     16f1 <botlish_fn_21+0x129>
    1696:	shr    rsi,0x3
    169a:	shl    rsi,1
    169d:	or     rsi,0x1
    16a1:	mov    rdi,rsi
    16a4:	sar    rdi,1
    16a7:	cmp    rdi,0x7f
    16ab:	jg     176d <botlish_fn_21+0x1a5>
    16b1:	mov    rdi,r12
    16b4:	call   16b9 <botlish_fn_21+0xf1>
			16b5: R_X86_64_PLT32	botlish_fn_18-0x4 ; std::web::is_unreserved<int>
    16b9:	cmp    rax,0x6
    16bd:	jne    176d <botlish_fn_21+0x1a5>
    16c3:	mov    rsi,r13
    16c6:	sar    rsi,1
    16c9:	mov    r13,rsi
    16cc:	add    rsi,0x1
    16d3:	mov    r13,rsi
    16d6:	shl    rsi,1
    16d9:	mov    r13,rsi
    16dc:	or     rsi,0x1
    16e0:	mov    r13,rsi
    16e3:	mov    QWORD PTR [rsp],rsi
    16e7:	mov    QWORD PTR [rsp+0x8],rbx
    16ec:	jmp    15f1 <botlish_fn_21+0x29>
    16f1:	mov    rsi,r13
    16f4:	mov    rax,rsi
    16f7:	sar    rax,1
    16fa:	lea    rsi,[rax+0x1]
    16fe:	shl    rsi,1
    1701:	or     rsi,0x1
    1705:	mov    rdx,rbx
    1708:	mov    rdi,r12
    170b:	call   1710 <botlish_fn_21+0x148>
			170c: R_X86_64_PLT32	botlish_fn_20-0x4 ; upper_hex?<int>
    1710:	cmp    rax,0x6
    1714:	jne    176d <botlish_fn_21+0x1a5>
    171a:	mov    QWORD PTR [rsp+0x10],0x5
    1723:	mov    rsi,r13
    1726:	test   rsi,0x1
    172d:	je     1745 <botlish_fn_21+0x17d>
    1733:	mov    rsi,r13
    1736:	add    rsi,0x4
    173a:	seto   al
    173d:	test   al,al
    173f:	je     1758 <botlish_fn_21+0x190>
    1745:	mov    edx,0x5
    174a:	mov    rsi,r13
    174d:	mov    rdi,r12
    1750:	call   1755 <botlish_fn_21+0x18d>
			1751: R_X86_64_PLT32	rt_int_add-0x4
    1755:	mov    rsi,rax
    1758:	mov    rdx,rbx
    175b:	mov    rdi,r12
    175e:	call   1763 <botlish_fn_21+0x19b>
			175f: R_X86_64_PLT32	botlish_fn_20-0x4 ; upper_hex?<int>
    1763:	cmp    rax,0x6
    1767:	je     178a <botlish_fn_21+0x1c2>
    176d:	mov    eax,0x2
    1772:	mov    rbx,QWORD PTR [rsp+0x20]
    1777:	mov    r12,QWORD PTR [rsp+0x28]
    177c:	mov    r13,QWORD PTR [rsp+0x30]
    1781:	add    rsp,0x40
    1785:	mov    rsp,rbp
    1788:	pop    rbp
    1789:	ret
    178a:	mov    QWORD PTR [rsp+0x10],0x7
    1793:	mov    rsi,r13
    1796:	test   rsi,0x1
    179d:	je     17c3 <botlish_fn_21+0x1fb>
    17a3:	mov    rsi,r13
    17a6:	mov    rcx,rsi
    17a9:	add    rcx,0x6
    17ad:	seto   al
    17b0:	test   al,al
    17b2:	jne    17c3 <botlish_fn_21+0x1fb>
    17b8:	mov    rsi,rcx
    17bb:	mov    r13,rcx
    17be:	jmp    17d9 <botlish_fn_21+0x211>
    17c3:	mov    edx,0x7
    17c8:	mov    rsi,r13
    17cb:	mov    rdi,r12
    17ce:	call   17d3 <botlish_fn_21+0x20b>
			17cf: R_X86_64_PLT32	rt_int_add-0x4
    17d3:	mov    rsi,rax
    17d6:	mov    r13,rax
    17d9:	mov    QWORD PTR [rsp],rsi
    17dd:	mov    QWORD PTR [rsp+0x8],rbx
    17e2:	jmp    15f1 <botlish_fn_21+0x29>
    17e7:	mov    eax,0x6
    17ec:	mov    rbx,QWORD PTR [rsp+0x20]
    17f1:	mov    r12,QWORD PTR [rsp+0x28]
    17f6:	mov    r13,QWORD PTR [rsp+0x30]
    17fb:	add    rsp,0x40
    17ff:	mov    rsp,rbp
    1802:	pop    rbp
    1803:	ret
    1804:	add    BYTE PTR [rax],al
    1806:	add    BYTE PTR [rax],al
    1808:	(bad)
    1809:	add    BYTE PTR [rax],al
    180b:	add    BYTE PTR [rax],al
    180d:	add    BYTE PTR [rax],al
	...

0000000000001810 <botlish_entry_21: valid_from?<int>>:
    1810:	push   rbp
    1811:	mov    rbp,rsp
    1814:	mov    rsi,QWORD PTR [rdx]
    1817:	mov    rdx,QWORD PTR [rdx+0x8]
    181b:	call   1820 <botlish_entry_21+0x10>
			181c: R_X86_64_PLT32	botlish_fn_21-0x4 ; valid_from?<int>
    1820:	mov    rsp,rbp
    1823:	pop    rbp
    1824:	ret

0000000000001825 <botlish_fn_22: std::web::uri_escape_text<str>>:
    1825:	push   rbp
    1826:	mov    rbp,rsp
    1829:	sub    rsp,0x10
    182d:	mov    edx,0x1
    1832:	mov    QWORD PTR [rsp],0x1
    183a:	mov    r10,QWORD PTR [rdi+0x10]
    183e:	mov    rcx,QWORD PTR [r10+0xc8]
    1845:	mov    QWORD PTR [rsp+0x8],rcx
    184a:	call   184f <botlish_fn_22+0x2a>
			184b: R_X86_64_PLT32	botlish_fn_28-0x4 ; esc_from<str, int, str>
    184f:	test   rax,rax
    1852:	jne    1864 <botlish_fn_22+0x3f>
    1858:	xor    rax,rax
    185b:	add    rsp,0x10
    185f:	mov    rsp,rbp
    1862:	pop    rbp
    1863:	ret
    1864:	add    rsp,0x10
    1868:	mov    rsp,rbp
    186b:	pop    rbp
    186c:	ret

000000000000186d <botlish_entry_22: std::web::uri_escape_text<str>>:
    186d:	push   rbp
    186e:	mov    rbp,rsp
    1871:	sub    rsp,0x10
    1875:	mov    QWORD PTR [rsp],r12
    1879:	mov    r12,rdi
    187c:	mov    rsi,QWORD PTR [rdx]
    187f:	mov    r8,QWORD PTR [rip+0x0]        # 1886 <botlish_entry_22+0x19>
			1882: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    1886:	call   r8
    1889:	mov    rsi,rax
    188c:	mov    rdi,r12
    188f:	call   1894 <botlish_entry_22+0x27>
			1890: R_X86_64_PLT32	botlish_fn_22-0x4 ; std::web::uri_escape_text<str>
    1894:	mov    r12,QWORD PTR [rsp]
    1898:	add    rsp,0x10
    189c:	mov    rsp,rbp
    189f:	pop    rbp
    18a0:	ret

00000000000018a1 <botlish_fn_23: high_nibble<int>>:
    18a1:	push   rbp
    18a2:	mov    rbp,rsp
    18a5:	and    rsi,0xf0
    18ac:	sar    rsi,0x4
    18b0:	shl    rsi,1
    18b3:	mov    rax,rsi
    18b6:	or     rax,0x1
    18ba:	mov    rsp,rbp
    18bd:	pop    rbp
    18be:	ret

00000000000018bf <botlish_entry_23: high_nibble<int>>:
    18bf:	push   rbp
    18c0:	mov    rbp,rsp
    18c3:	mov    rsi,QWORD PTR [rdx]
    18c6:	sar    rsi,1
    18c9:	call   18ce <botlish_entry_23+0xf>
			18ca: R_X86_64_PLT32	botlish_fn_23-0x4 ; high_nibble<int>
    18ce:	mov    rsp,rbp
    18d1:	pop    rbp
    18d2:	ret

00000000000018d3 <botlish_fn_24: hex_pair<int>>:
    18d3:	push   rbp
    18d4:	mov    rbp,rsp
    18d7:	sub    rsp,0x50
    18db:	mov    QWORD PTR [rsp+0x30],rbx
    18e0:	mov    QWORD PTR [rsp+0x38],r12
    18e5:	mov    QWORD PTR [rsp+0x40],r13
    18ea:	mov    rax,QWORD PTR [rdi+0x30]
    18ee:	mov    r13,QWORD PTR [rax+0x8]
    18f2:	mov    rbx,rsi
    18f5:	mov    r12,rdi
    18f8:	call   18fd <botlish_fn_24+0x2a>
			18f9: R_X86_64_PLT32	botlish_fn_23-0x4 ; high_nibble<int>
    18fd:	mov    rcx,QWORD PTR [r13+0x10]
    1901:	sar    rax,1
    1904:	mov    rdx,QWORD PTR [rcx+rax*8]
    1908:	mov    QWORD PTR [rsp],rdx
    190c:	mov    rax,QWORD PTR [r12+0x30]
    1911:	mov    rax,QWORD PTR [rax+0x8]
    1915:	mov    rcx,QWORD PTR [rax+0x10]
    1919:	and    rbx,0xf
    191d:	shl    rbx,1
    1920:	or     rbx,0x1
    1924:	sar    rbx,1
    1927:	mov    rsi,QWORD PTR [rcx+rbx*8]
    192b:	mov    QWORD PTR [rsp+0x8],rsi
    1930:	lea    rcx,[rsp+0x10]
    1935:	mov    QWORD PTR [rsp+0x10],0x0
    193e:	mov    QWORD PTR [rsp+0x18],rdx
    1943:	mov    QWORD PTR [rsp+0x20],0x0
    194c:	mov    QWORD PTR [rsp+0x28],rsi
    1951:	mov    esi,0x2
    1956:	mov    edx,0x4
    195b:	mov    rdi,r12
    195e:	call   1963 <botlish_fn_24+0x90>
			195f: R_X86_64_PLT32	rt_construct-0x4
    1963:	test   rax,rax
    1966:	jne    1987 <botlish_fn_24+0xb4>
    196c:	xor    rax,rax
    196f:	mov    rbx,QWORD PTR [rsp+0x30]
    1974:	mov    r12,QWORD PTR [rsp+0x38]
    1979:	mov    r13,QWORD PTR [rsp+0x40]
    197e:	add    rsp,0x50
    1982:	mov    rsp,rbp
    1985:	pop    rbp
    1986:	ret
    1987:	mov    rbx,QWORD PTR [rsp+0x30]
    198c:	mov    r12,QWORD PTR [rsp+0x38]
    1991:	mov    r13,QWORD PTR [rsp+0x40]
    1996:	add    rsp,0x50
    199a:	mov    rsp,rbp
    199d:	pop    rbp
    199e:	ret

000000000000199f <botlish_entry_24: hex_pair<int>>:
    199f:	push   rbp
    19a0:	mov    rbp,rsp
    19a3:	sub    rsp,0x10
    19a7:	mov    QWORD PTR [rsp],r12
    19ab:	mov    r12,rdi
    19ae:	mov    rsi,QWORD PTR [rdx]
    19b1:	sar    rsi,1
    19b4:	call   19b9 <botlish_entry_24+0x1a>
			19b5: R_X86_64_PLT32	botlish_fn_24-0x4 ; hex_pair<int>
    19b9:	mov    r8,QWORD PTR [rip+0x0]        # 19c0 <botlish_entry_24+0x21>
			19bc: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    19c0:	mov    rsi,rax
    19c3:	mov    rdi,r12
    19c6:	call   r8
    19c9:	mov    r12,QWORD PTR [rsp]
    19cd:	add    rsp,0x10
    19d1:	mov    rsp,rbp
    19d4:	pop    rbp
    19d5:	ret

00000000000019d6 <botlish_fn_25: pct<int>>:
    19d6:	push   rbp
    19d7:	mov    rbp,rsp
    19da:	sub    rsp,0x40
    19de:	mov    QWORD PTR [rsp+0x30],r12
    19e3:	mov    QWORD PTR [rsp+0x38],r13
    19e8:	mov    QWORD PTR [rsp+0x8],0x0
    19f1:	mov    rax,QWORD PTR [rdi+0x10]
    19f5:	mov    r12,rdi
    19f8:	mov    r13,QWORD PTR [rax+0x10]
    19fc:	mov    QWORD PTR [rsp],r13
    1a00:	call   1a05 <botlish_fn_25+0x2f>
			1a01: R_X86_64_PLT32	botlish_fn_24-0x4 ; hex_pair<int>
    1a05:	test   rax,rax
    1a08:	je     1a4f <botlish_fn_25+0x79>
    1a0e:	mov    QWORD PTR [rsp+0x8],rax
    1a13:	lea    rcx,[rsp+0x10]
    1a18:	mov    QWORD PTR [rsp+0x10],0x0
    1a21:	mov    QWORD PTR [rsp+0x18],r13
    1a26:	mov    QWORD PTR [rsp+0x20],0x0
    1a2f:	mov    QWORD PTR [rsp+0x28],rax
    1a34:	mov    esi,0x2
    1a39:	mov    edx,0x4
    1a3e:	mov    rdi,r12
    1a41:	call   1a46 <botlish_fn_25+0x70>
			1a42: R_X86_64_PLT32	rt_construct-0x4
    1a46:	test   rax,rax
    1a49:	jne    1a65 <botlish_fn_25+0x8f>
    1a4f:	xor    rax,rax
    1a52:	mov    r12,QWORD PTR [rsp+0x30]
    1a57:	mov    r13,QWORD PTR [rsp+0x38]
    1a5c:	add    rsp,0x40
    1a60:	mov    rsp,rbp
    1a63:	pop    rbp
    1a64:	ret
    1a65:	mov    r12,QWORD PTR [rsp+0x30]
    1a6a:	mov    r13,QWORD PTR [rsp+0x38]
    1a6f:	add    rsp,0x40
    1a73:	mov    rsp,rbp
    1a76:	pop    rbp
    1a77:	ret

0000000000001a78 <botlish_entry_25: pct<int>>:
    1a78:	push   rbp
    1a79:	mov    rbp,rsp
    1a7c:	sub    rsp,0x10
    1a80:	mov    QWORD PTR [rsp],r12
    1a84:	mov    r12,rdi
    1a87:	mov    rsi,QWORD PTR [rdx]
    1a8a:	sar    rsi,1
    1a8d:	call   1a92 <botlish_entry_25+0x1a>
			1a8e: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1a92:	mov    r8,QWORD PTR [rip+0x0]        # 1a99 <botlish_entry_25+0x21>
			1a95: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1a99:	mov    rsi,rax
    1a9c:	mov    rdi,r12
    1a9f:	call   r8
    1aa2:	mov    r12,QWORD PTR [rsp]
    1aa6:	add    rsp,0x10
    1aaa:	mov    rsp,rbp
    1aad:	pop    rbp
    1aae:	ret

0000000000001aaf <botlish_fn_26: cont<int, int>>:
    1aaf:	push   rbp
    1ab0:	mov    rbp,rsp
    1ab3:	sub    rsp,0x20
    1ab7:	mov    QWORD PTR [rsp+0x10],r12
    1abc:	mov    r12,rdi
    1abf:	mov    QWORD PTR [rsp],rsi
    1ac3:	mov    QWORD PTR [rsp+0x8],rdx
    1ac8:	mov    rdi,r12
    1acb:	call   1ad0 <botlish_fn_26+0x21>
			1acc: R_X86_64_PLT32	rt_int_shr-0x4
    1ad0:	test   rax,rax
    1ad3:	je     1afb <botlish_fn_26+0x4c>
    1ad9:	sar    rax,1
    1adc:	and    rax,0x3f
    1ae0:	mov    rsi,rax
    1ae3:	or     rsi,0x80
    1aea:	mov    rdi,r12
    1aed:	call   1af2 <botlish_fn_26+0x43>
			1aee: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1af2:	test   rax,rax
    1af5:	jne    1b0c <botlish_fn_26+0x5d>
    1afb:	xor    rax,rax
    1afe:	mov    r12,QWORD PTR [rsp+0x10]
    1b03:	add    rsp,0x20
    1b07:	mov    rsp,rbp
    1b0a:	pop    rbp
    1b0b:	ret
    1b0c:	mov    r12,QWORD PTR [rsp+0x10]
    1b11:	add    rsp,0x20
    1b15:	mov    rsp,rbp
    1b18:	pop    rbp
    1b19:	ret

0000000000001b1a <botlish_entry_26: cont<int, int>>:
    1b1a:	push   rbp
    1b1b:	mov    rbp,rsp
    1b1e:	sub    rsp,0x10
    1b22:	mov    QWORD PTR [rsp],r12
    1b26:	mov    r12,rdi
    1b29:	mov    rsi,QWORD PTR [rdx]
    1b2c:	mov    rdx,QWORD PTR [rdx+0x8]
    1b30:	call   1b35 <botlish_entry_26+0x1b>
			1b31: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1b35:	mov    r8,QWORD PTR [rip+0x0]        # 1b3c <botlish_entry_26+0x22>
			1b38: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1b3c:	mov    rsi,rax
    1b3f:	mov    rdi,r12
    1b42:	call   r8
    1b45:	mov    r12,QWORD PTR [rsp]
    1b49:	add    rsp,0x10
    1b4d:	mov    rsp,rbp
    1b50:	pop    rbp
    1b51:	ret

0000000000001b52 <botlish_fn_27: esc_scalar<int>>:
    1b52:	push   rbp
    1b53:	mov    rbp,rsp
    1b56:	sub    rsp,0xf0
    1b5d:	mov    QWORD PTR [rsp+0xc0],rbx
    1b65:	mov    QWORD PTR [rsp+0xc8],r12
    1b6d:	mov    QWORD PTR [rsp+0xd0],r13
    1b75:	mov    QWORD PTR [rsp+0xd8],r14
    1b7d:	mov    QWORD PTR [rsp+0xe0],r15
    1b85:	mov    rbx,rdi
    1b88:	mov    r12,rsi
    1b8b:	mov    QWORD PTR [rsp+0x8],0x0
    1b94:	mov    QWORD PTR [rsp+0x10],0x0
    1b9d:	mov    QWORD PTR [rsp+0x18],0x0
    1ba6:	mov    QWORD PTR [rsp+0x20],0x0
    1baf:	mov    QWORD PTR [rsp],rsi
    1bb3:	mov    rsi,r12
    1bb6:	mov    rax,rsi
    1bb9:	sar    rax,1
    1bbc:	cmp    rax,0x800
    1bc2:	jl     1dc2 <botlish_fn_27+0x270>
    1bc8:	cmp    rax,0x10000
    1bce:	jl     1cf0 <botlish_fn_27+0x19e>
    1bd4:	mov    rsi,r12
    1bd7:	sar    rsi,0x13
    1bdb:	or     rsi,0xf0
    1be2:	mov    rdi,rbx
    1be5:	call   1bea <botlish_fn_27+0x98>
			1be6: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1bea:	test   rax,rax
    1bed:	je     1e4e <botlish_fn_27+0x2fc>
    1bf3:	mov    QWORD PTR [rsp+0x8],rax
    1bf8:	mov    r13,rax
    1bfb:	mov    edx,0x19
    1c00:	mov    QWORD PTR [rsp+0x10],0x19
    1c09:	mov    rsi,r12
    1c0c:	mov    rdi,rbx
    1c0f:	call   1c14 <botlish_fn_27+0xc2>
			1c10: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1c14:	test   rax,rax
    1c17:	je     1e4e <botlish_fn_27+0x2fc>
    1c1d:	mov    QWORD PTR [rsp+0x10],rax
    1c22:	mov    r14,rax
    1c25:	mov    edx,0xd
    1c2a:	mov    QWORD PTR [rsp+0x18],0xd
    1c33:	mov    rsi,r12
    1c36:	mov    rdi,rbx
    1c39:	call   1c3e <botlish_fn_27+0xec>
			1c3a: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1c3e:	test   rax,rax
    1c41:	je     1e4e <botlish_fn_27+0x2fc>
    1c47:	mov    QWORD PTR [rsp+0x18],rax
    1c4c:	mov    r15,rax
    1c4f:	mov    edx,0x1
    1c54:	mov    QWORD PTR [rsp+0x20],0x1
    1c5d:	mov    rsi,r12
    1c60:	mov    rdi,rbx
    1c63:	call   1c68 <botlish_fn_27+0x116>
			1c64: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1c68:	test   rax,rax
    1c6b:	je     1e4e <botlish_fn_27+0x2fc>
    1c71:	mov    QWORD PTR [rsp],rax
    1c75:	lea    rcx,[rsp+0x78]
    1c7a:	mov    QWORD PTR [rsp+0x78],0x0
    1c83:	mov    rdx,r13
    1c86:	mov    QWORD PTR [rsp+0x80],rdx
    1c8e:	mov    QWORD PTR [rsp+0x88],0x0
    1c9a:	mov    rdx,r14
    1c9d:	mov    QWORD PTR [rsp+0x90],rdx
    1ca5:	mov    QWORD PTR [rsp+0x98],0x0
    1cb1:	mov    rdx,r15
    1cb4:	mov    QWORD PTR [rsp+0xa0],rdx
    1cbc:	mov    QWORD PTR [rsp+0xa8],0x0
    1cc8:	mov    QWORD PTR [rsp+0xb0],rax
    1cd0:	mov    esi,0x2
    1cd5:	mov    edx,0x8
    1cda:	mov    rdi,rbx
    1cdd:	call   1ce2 <botlish_fn_27+0x190>
			1cde: R_X86_64_PLT32	rt_construct-0x4
    1ce2:	test   rax,rax
    1ce5:	je     1e4e <botlish_fn_27+0x2fc>
    1ceb:	jmp    1e85 <botlish_fn_27+0x333>
    1cf0:	mov    edx,0xd
    1cf5:	mov    rsi,r12
    1cf8:	mov    r14,rdx
    1cfb:	sar    rsi,0xd
    1cff:	or     rsi,0xe0
    1d06:	mov    rdi,rbx
    1d09:	call   1d0e <botlish_fn_27+0x1bc>
			1d0a: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1d0e:	test   rax,rax
    1d11:	je     1e4e <botlish_fn_27+0x2fc>
    1d17:	mov    QWORD PTR [rsp+0x8],rax
    1d1c:	mov    r13,rax
    1d1f:	mov    QWORD PTR [rsp+0x10],0xd
    1d28:	mov    rdx,r14
    1d2b:	mov    rsi,r12
    1d2e:	mov    rdi,rbx
    1d31:	call   1d36 <botlish_fn_27+0x1e4>
			1d32: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1d36:	test   rax,rax
    1d39:	je     1e4e <botlish_fn_27+0x2fc>
    1d3f:	mov    QWORD PTR [rsp+0x10],rax
    1d44:	mov    r14,rax
    1d47:	mov    edx,0x1
    1d4c:	mov    QWORD PTR [rsp+0x18],0x1
    1d55:	mov    rsi,r12
    1d58:	mov    rdi,rbx
    1d5b:	call   1d60 <botlish_fn_27+0x20e>
			1d5c: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1d60:	test   rax,rax
    1d63:	je     1e4e <botlish_fn_27+0x2fc>
    1d69:	mov    QWORD PTR [rsp],rax
    1d6d:	lea    rcx,[rsp+0x48]
    1d72:	mov    QWORD PTR [rsp+0x48],0x0
    1d7b:	mov    r11,r13
    1d7e:	mov    QWORD PTR [rsp+0x50],r11
    1d83:	mov    QWORD PTR [rsp+0x58],0x0
    1d8c:	mov    rdx,r14
    1d8f:	mov    QWORD PTR [rsp+0x60],rdx
    1d94:	mov    QWORD PTR [rsp+0x68],0x0
    1d9d:	mov    QWORD PTR [rsp+0x70],rax
    1da2:	mov    esi,0x2
    1da7:	mov    edx,0x6
    1dac:	mov    rdi,rbx
    1daf:	call   1db4 <botlish_fn_27+0x262>
			1db0: R_X86_64_PLT32	rt_construct-0x4
    1db4:	test   rax,rax
    1db7:	je     1e4e <botlish_fn_27+0x2fc>
    1dbd:	jmp    1e85 <botlish_fn_27+0x333>
    1dc2:	mov    rsi,r12
    1dc5:	sar    rsi,0x7
    1dc9:	or     rsi,0xc0
    1dd0:	mov    rdi,rbx
    1dd3:	call   1dd8 <botlish_fn_27+0x286>
			1dd4: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1dd8:	test   rax,rax
    1ddb:	je     1e4e <botlish_fn_27+0x2fc>
    1de1:	mov    QWORD PTR [rsp+0x8],rax
    1de6:	mov    r13,rax
    1de9:	mov    edx,0x1
    1dee:	mov    QWORD PTR [rsp+0x10],0x1
    1df7:	mov    rsi,r12
    1dfa:	mov    rdi,rbx
    1dfd:	call   1e02 <botlish_fn_27+0x2b0>
			1dfe: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1e02:	test   rax,rax
    1e05:	je     1e4e <botlish_fn_27+0x2fc>
    1e0b:	mov    QWORD PTR [rsp],rax
    1e0f:	lea    rcx,[rsp+0x28]
    1e14:	mov    QWORD PTR [rsp+0x28],0x0
    1e1d:	mov    rdx,r13
    1e20:	mov    QWORD PTR [rsp+0x30],rdx
    1e25:	mov    QWORD PTR [rsp+0x38],0x0
    1e2e:	mov    QWORD PTR [rsp+0x40],rax
    1e33:	mov    esi,0x2
    1e38:	mov    edx,0x4
    1e3d:	mov    rdi,rbx
    1e40:	call   1e45 <botlish_fn_27+0x2f3>
			1e41: R_X86_64_PLT32	rt_construct-0x4
    1e45:	test   rax,rax
    1e48:	jne    1e85 <botlish_fn_27+0x333>
    1e4e:	xor    rax,rax
    1e51:	mov    rbx,QWORD PTR [rsp+0xc0]
    1e59:	mov    r12,QWORD PTR [rsp+0xc8]
    1e61:	mov    r13,QWORD PTR [rsp+0xd0]
    1e69:	mov    r14,QWORD PTR [rsp+0xd8]
    1e71:	mov    r15,QWORD PTR [rsp+0xe0]
    1e79:	add    rsp,0xf0
    1e80:	mov    rsp,rbp
    1e83:	pop    rbp
    1e84:	ret
    1e85:	mov    rbx,QWORD PTR [rsp+0xc0]
    1e8d:	mov    r12,QWORD PTR [rsp+0xc8]
    1e95:	mov    r13,QWORD PTR [rsp+0xd0]
    1e9d:	mov    r14,QWORD PTR [rsp+0xd8]
    1ea5:	mov    r15,QWORD PTR [rsp+0xe0]
    1ead:	add    rsp,0xf0
    1eb4:	mov    rsp,rbp
    1eb7:	pop    rbp
    1eb8:	ret

0000000000001eb9 <botlish_entry_27: esc_scalar<int>>:
    1eb9:	push   rbp
    1eba:	mov    rbp,rsp
    1ebd:	sub    rsp,0x10
    1ec1:	mov    QWORD PTR [rsp],r12
    1ec5:	mov    r12,rdi
    1ec8:	mov    rsi,QWORD PTR [rdx]
    1ecb:	call   1ed0 <botlish_entry_27+0x17>
			1ecc: R_X86_64_PLT32	botlish_fn_27-0x4 ; esc_scalar<int>
    1ed0:	mov    r8,QWORD PTR [rip+0x0]        # 1ed7 <botlish_entry_27+0x1e>
			1ed3: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1ed7:	mov    rsi,rax
    1eda:	mov    rdi,r12
    1edd:	call   r8
    1ee0:	mov    r12,QWORD PTR [rsp]
    1ee4:	add    rsp,0x10
    1ee8:	mov    rsp,rbp
    1eeb:	pop    rbp
    1eec:	ret

0000000000001eed <botlish_fn_28: esc_from<str, int, str>>:
    1eed:	push   rbp
    1eee:	mov    rbp,rsp
    1ef1:	sub    rsp,0x100
    1ef8:	mov    QWORD PTR [rsp+0xd0],rbx
    1f00:	mov    QWORD PTR [rsp+0xd8],r12
    1f08:	mov    QWORD PTR [rsp+0xe0],r13
    1f10:	mov    QWORD PTR [rsp+0xe8],r14
    1f18:	mov    QWORD PTR [rsp+0xf0],r15
    1f20:	mov    QWORD PTR [rsp+0xa0],rdi
    1f28:	mov    QWORD PTR [rsp+0x8],0x0
    1f31:	mov    QWORD PTR [rsp+0x10],0x0
    1f3a:	mov    QWORD PTR [rsp+0x18],0x0
    1f43:	mov    QWORD PTR [rsp],rcx
    1f47:	mov    QWORD PTR [rsp+0xb0],rcx
    1f4f:	sar    rdx,1
    1f52:	mov    r15d,0x47
    1f58:	mov    rcx,0xffffffffffffffff
    1f5f:	bsr    rax,rsi
    1f63:	mov    QWORD PTR [rsp+0xa8],rsi
    1f6b:	cmove  rax,rcx
    1f6f:	mov    ecx,0x3f
    1f74:	sub    rcx,rax
    1f77:	sub    r15,rcx
    1f7a:	shr    r15,0x3
    1f7e:	lea    r12,[rsp+0x80]
    1f86:	mov    QWORD PTR [rsp+0xc8],r12
    1f8e:	lea    r13,[rsp+0x50]
    1f93:	mov    QWORD PTR [rsp+0xc0],r13
    1f9b:	lea    rax,[rsp+0x30]
    1fa0:	mov    QWORD PTR [rsp+0xb8],rax
    1fa8:	mov    r14,rdx
    1fab:	cmp    r14,r15
    1fae:	jge    21de <botlish_fn_28+0x2f1>
    1fb4:	mov    rsi,QWORD PTR [rsp+0xa8]
    1fbc:	mov    rdi,QWORD PTR [rsp+0xa0]
    1fc4:	call   1fc9 <botlish_fn_28+0xdc>
			1fc5: R_X86_64_PLT32	rt_ascii_to_str-0x4
    1fc9:	mov    QWORD PTR [rsp+0x8],rax
    1fce:	mov    rbx,r14
    1fd1:	shl    rbx,1
    1fd4:	or     rbx,0x1
    1fd8:	mov    QWORD PTR [rsp+0x10],rbx
    1fdd:	movzx  rdx,BYTE PTR [rax+0x18]
    1fe2:	mov    r13,rax
    1fe5:	test   rdx,rdx
    1fe8:	jne    2009 <botlish_fn_28+0x11c>
    1fee:	mov    rdx,rbx
    1ff1:	mov    rsi,r13
    1ff4:	mov    rdi,QWORD PTR [rsp+0xa0]
    1ffc:	call   2001 <botlish_fn_28+0x114>
			1ffd: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    2001:	mov    rsi,rax
    2004:	jmp    201d <botlish_fn_28+0x130>
    2009:	mov    rsi,rbx
    200c:	sar    rsi,1
    200f:	movzx  rsi,BYTE PTR [r13+rsi*1+0x19]
    2015:	shl    rsi,0x3
    2019:	or     rsi,0x4
    201d:	shr    rsi,0x3
    2021:	shl    rsi,1
    2024:	or     rsi,0x1
    2028:	mov    QWORD PTR [rsp+0x18],rsi
    202d:	mov    r12,rsi
    2030:	sar    r12,1
    2033:	cmp    r12,0x7f
    2037:	jg     215f <botlish_fn_28+0x272>
    203d:	mov    rdi,QWORD PTR [rsp+0xa0]
    2045:	call   204a <botlish_fn_28+0x15d>
			2046: R_X86_64_PLT32	botlish_fn_18-0x4 ; std::web::is_unreserved<int>
    204a:	cmp    rax,0x6
    204e:	je     20e2 <botlish_fn_28+0x1f5>
    2054:	mov    rsi,r12
    2057:	mov    rdi,QWORD PTR [rsp+0xa0]
    205f:	call   2064 <botlish_fn_28+0x177>
			2060: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    2064:	test   rax,rax
    2067:	je     2217 <botlish_fn_28+0x32a>
    206d:	mov    QWORD PTR [rsp+0x8],rax
    2072:	mov    QWORD PTR [rsp+0x80],0x0
    207e:	mov    r12,QWORD PTR [rsp+0xb0]
    2086:	mov    QWORD PTR [rsp+0x88],r12
    208e:	mov    QWORD PTR [rsp+0x90],0x0
    209a:	mov    QWORD PTR [rsp+0x98],rax
    20a2:	mov    esi,0x2
    20a7:	mov    edx,0x4
    20ac:	mov    rcx,QWORD PTR [rsp+0xc8]
    20b4:	mov    rdi,QWORD PTR [rsp+0xa0]
    20bc:	call   20c1 <botlish_fn_28+0x1d4>
			20bd: R_X86_64_PLT32	rt_construct-0x4
    20c1:	test   rax,rax
    20c4:	je     2217 <botlish_fn_28+0x32a>
    20ca:	mov    QWORD PTR [rsp],rax
    20ce:	add    r14,0x1
    20d5:	mov    QWORD PTR [rsp+0xb0],rax
    20dd:	jmp    1fab <botlish_fn_28+0xbe>
    20e2:	mov    r12,QWORD PTR [rsp+0xb0]
    20ea:	add    r14,0x1
    20f1:	mov    rcx,r14
    20f4:	shl    rcx,1
    20f7:	or     rcx,0x1
    20fb:	mov    QWORD PTR [rsp+0x18],rcx
    2100:	mov    QWORD PTR [rsp+0x50],0x0
    2109:	mov    QWORD PTR [rsp+0x58],r12
    210e:	mov    QWORD PTR [rsp+0x60],0x1
    2117:	mov    QWORD PTR [rsp+0x68],r13
    211c:	mov    QWORD PTR [rsp+0x70],rbx
    2121:	mov    QWORD PTR [rsp+0x78],rcx
    2126:	mov    esi,0x2
    212b:	mov    edx,0x6
    2130:	mov    rcx,QWORD PTR [rsp+0xc0]
    2138:	mov    rdi,QWORD PTR [rsp+0xa0]
    2140:	call   2145 <botlish_fn_28+0x258>
			2141: R_X86_64_PLT32	rt_construct-0x4
    2145:	test   rax,rax
    2148:	je     2217 <botlish_fn_28+0x32a>
    214e:	mov    QWORD PTR [rsp],rax
    2152:	mov    QWORD PTR [rsp+0xb0],rax
    215a:	jmp    1fab <botlish_fn_28+0xbe>
    215f:	mov    r12,QWORD PTR [rsp+0xb0]
    2167:	mov    rdi,QWORD PTR [rsp+0xa0]
    216f:	call   2174 <botlish_fn_28+0x287>
			2170: R_X86_64_PLT32	botlish_fn_27-0x4 ; esc_scalar<int>
    2174:	test   rax,rax
    2177:	je     2217 <botlish_fn_28+0x32a>
    217d:	mov    QWORD PTR [rsp+0x8],rax
    2182:	mov    QWORD PTR [rsp+0x30],0x0
    218b:	mov    QWORD PTR [rsp+0x38],r12
    2190:	mov    QWORD PTR [rsp+0x40],0x0
    2199:	mov    QWORD PTR [rsp+0x48],rax
    219e:	mov    esi,0x2
    21a3:	mov    edx,0x4
    21a8:	mov    rcx,QWORD PTR [rsp+0xb8]
    21b0:	mov    rdi,QWORD PTR [rsp+0xa0]
    21b8:	call   21bd <botlish_fn_28+0x2d0>
			21b9: R_X86_64_PLT32	rt_construct-0x4
    21bd:	test   rax,rax
    21c0:	je     2217 <botlish_fn_28+0x32a>
    21c6:	mov    QWORD PTR [rsp],rax
    21ca:	add    r14,0x1
    21d1:	mov    QWORD PTR [rsp+0xb0],rax
    21d9:	jmp    1fab <botlish_fn_28+0xbe>
    21de:	mov    r12,QWORD PTR [rsp+0xb0]
    21e6:	xor    rsi,rsi
    21e9:	lea    rcx,[rsp+0x20]
    21ee:	mov    QWORD PTR [rsp+0x20],0x0
    21f7:	mov    QWORD PTR [rsp+0x28],r12
    21fc:	mov    edx,0x2
    2201:	mov    rdi,QWORD PTR [rsp+0xa0]
    2209:	call   220e <botlish_fn_28+0x321>
			220a: R_X86_64_PLT32	rt_construct-0x4
    220e:	test   rax,rax
    2211:	jne    224e <botlish_fn_28+0x361>
    2217:	xor    rax,rax
    221a:	mov    rbx,QWORD PTR [rsp+0xd0]
    2222:	mov    r12,QWORD PTR [rsp+0xd8]
    222a:	mov    r13,QWORD PTR [rsp+0xe0]
    2232:	mov    r14,QWORD PTR [rsp+0xe8]
    223a:	mov    r15,QWORD PTR [rsp+0xf0]
    2242:	add    rsp,0x100
    2249:	mov    rsp,rbp
    224c:	pop    rbp
    224d:	ret
    224e:	mov    rbx,QWORD PTR [rsp+0xd0]
    2256:	mov    r12,QWORD PTR [rsp+0xd8]
    225e:	mov    r13,QWORD PTR [rsp+0xe0]
    2266:	mov    r14,QWORD PTR [rsp+0xe8]
    226e:	mov    r15,QWORD PTR [rsp+0xf0]
    2276:	add    rsp,0x100
    227d:	mov    rsp,rbp
    2280:	pop    rbp
    2281:	ret

0000000000002282 <botlish_entry_28: esc_from<str, int, str>>:
    2282:	push   rbp
    2283:	mov    rbp,rsp
    2286:	sub    rsp,0x10
    228a:	mov    QWORD PTR [rsp],r12
    228e:	mov    QWORD PTR [rsp+0x8],r13
    2293:	mov    r12,rdi
    2296:	mov    rsi,QWORD PTR [rdx]
    2299:	mov    r13,rdx
    229c:	mov    r8,QWORD PTR [rip+0x0]        # 22a3 <botlish_entry_28+0x21>
			229f: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    22a3:	call   r8
    22a6:	mov    rcx,r13
    22a9:	mov    rdx,QWORD PTR [rcx+0x8]
    22ad:	mov    rcx,QWORD PTR [rcx+0x10]
    22b1:	mov    rsi,rax
    22b4:	mov    rdi,r12
    22b7:	call   22bc <botlish_entry_28+0x3a>
			22b8: R_X86_64_PLT32	botlish_fn_28-0x4 ; esc_from<str, int, str>
    22bc:	mov    r12,QWORD PTR [rsp]
    22c0:	mov    r13,QWORD PTR [rsp+0x8]
    22c5:	add    rsp,0x10
    22c9:	mov    rsp,rbp
    22cc:	pop    rbp
    22cd:	ret

00000000000022ce <botlish_fn_29: check<int, int, str, str>>:
    22ce:	push   rbp
    22cf:	mov    rbp,rsp
    22d2:	sub    rsp,0x50
    22d6:	mov    QWORD PTR [rsp+0x20],rbx
    22db:	mov    QWORD PTR [rsp+0x28],r12
    22e0:	mov    QWORD PTR [rsp+0x30],r13
    22e5:	mov    QWORD PTR [rsp+0x38],r14
    22ea:	mov    QWORD PTR [rsp+0x40],r15
    22ef:	mov    r14,rdi
    22f2:	mov    QWORD PTR [rsp+0x18],0x0
    22fb:	mov    QWORD PTR [rsp],rdx
    22ff:	mov    QWORD PTR [rsp+0x8],rcx
    2304:	mov    QWORD PTR [rsp+0x10],r8
    2309:	mov    r12,r8
    230c:	mov    r13,rsi
    230f:	mov    r15,rdx
    2312:	test   r13,r13
    2315:	jle    23ef <botlish_fn_29+0x121>
    231b:	mov    rbx,rcx
    231e:	mov    rsi,rbx
    2321:	mov    rdi,r14
    2324:	call   2329 <botlish_fn_29+0x5b>
			2325: R_X86_64_PLT32	botlish_fn_8-0x4 ; std::web::emailish?<str>
    2329:	test   rax,rax
    232c:	jne    2357 <botlish_fn_29+0x89>
    2332:	xor    rax,rax
    2335:	mov    rbx,QWORD PTR [rsp+0x20]
    233a:	mov    r12,QWORD PTR [rsp+0x28]
    233f:	mov    r13,QWORD PTR [rsp+0x30]
    2344:	mov    r14,QWORD PTR [rsp+0x38]
    2349:	mov    r15,QWORD PTR [rsp+0x40]
    234e:	add    rsp,0x50
    2352:	mov    rsp,rbp
    2355:	pop    rbp
    2356:	ret
    2357:	cmp    rax,0x6
    235b:	je     2377 <botlish_fn_29+0xa9>
    2361:	mov    edx,0x1
    2366:	mov    QWORD PTR [rsp+0x18],0x1
    236f:	mov    rsi,r15
    2372:	jmp    23a3 <botlish_fn_29+0xd5>
    2377:	mov    rsi,r12
    237a:	mov    rdi,r14
    237d:	call   2382 <botlish_fn_29+0xb4>
			237e: R_X86_64_PLT32	botlish_fn_19-0x4 ; std::web::uri_query_value?<str>
    2382:	cmp    rax,0x6
    2386:	je     2396 <botlish_fn_29+0xc8>
    238c:	mov    edx,0x1
    2391:	jmp    239b <botlish_fn_29+0xcd>
    2396:	mov    edx,0x3
    239b:	mov    QWORD PTR [rsp+0x18],rdx
    23a0:	mov    rsi,r15
    23a3:	mov    rax,rsi
    23a6:	and    rax,rdx
    23a9:	test   rax,0x1
    23af:	je     23ca <botlish_fn_29+0xfc>
    23b5:	lea    rcx,[rdx-0x1]
    23b9:	mov    rax,rsi
    23bc:	add    rax,rcx
    23bf:	seto   cl
    23c2:	test   cl,cl
    23c4:	je     23d2 <botlish_fn_29+0x104>
    23ca:	mov    rdi,r14
    23cd:	call   23d2 <botlish_fn_29+0x104>
			23ce: R_X86_64_PLT32	rt_int_add-0x4
    23d2:	mov    QWORD PTR [rsp],rax
    23d6:	mov    QWORD PTR [rsp+0x8],rbx
    23db:	mov    QWORD PTR [rsp+0x10],r12
    23e0:	sub    r13,0x1
    23e4:	mov    rcx,rbx
    23e7:	mov    r15,rax
    23ea:	jmp    2312 <botlish_fn_29+0x44>
    23ef:	mov    rax,r15
    23f2:	mov    rbx,QWORD PTR [rsp+0x20]
    23f7:	mov    r12,QWORD PTR [rsp+0x28]
    23fc:	mov    r13,QWORD PTR [rsp+0x30]
    2401:	mov    r14,QWORD PTR [rsp+0x38]
    2406:	mov    r15,QWORD PTR [rsp+0x40]
    240b:	add    rsp,0x50
    240f:	mov    rsp,rbp
    2412:	pop    rbp
    2413:	ret

0000000000002414 <botlish_entry_29: check<int, int, str, str>>:
    2414:	push   rbp
    2415:	mov    rbp,rsp
    2418:	mov    rsi,QWORD PTR [rdx]
    241b:	mov    r9,QWORD PTR [rdx+0x8]
    241f:	mov    rcx,QWORD PTR [rdx+0x10]
    2423:	mov    r8,QWORD PTR [rdx+0x18]
    2427:	sar    rsi,1
    242a:	mov    rdx,r9
    242d:	call   2432 <botlish_entry_29+0x1e>
			242e: R_X86_64_PLT32	botlish_fn_29-0x4 ; check<int, int, str, str>
    2432:	mov    rsp,rbp
    2435:	pop    rbp
    2436:	ret

; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 11086  (per function: 1415 217 617 74 74 74 128 128 353 115 154 176 176 295 344 183 770 140 60 477 829 127 103 313 219 287 1255 1615 368)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> byte::from_int<int>
;   botlish_fn_2 / botlish_entry_2 -> byte::set<List[UnicodeChar]>
;   botlish_fn_3 / botlish_entry_3 -> ascii::is_digit<int>
;   botlish_fn_4 / botlish_entry_4 -> ascii::is_upper<int>
;   botlish_fn_5 / botlish_entry_5 -> ascii::is_lower<int>
;   botlish_fn_6 / botlish_entry_6 -> ascii::is_alphabetic<int>
;   botlish_fn_7 / botlish_entry_7 -> ascii::is_alphanumeric<int>
;   botlish_fn_8 / botlish_entry_8 -> web::emailish?<str>
;   botlish_fn_9 / botlish_entry_9 -> char_at<int>
;   botlish_fn_10 / botlish_entry_10 -> char_at<int>
;   botlish_fn_11 / botlish_entry_11 -> local_char?<str>
;   botlish_fn_12 / botlish_entry_12 -> local_char?<generic>
;   botlish_fn_13 / botlish_entry_13 -> scan_while<int, block(e251)>
;   botlish_fn_14 / botlish_entry_14 -> scan_while<int, native(str::is_tcl_alpha)>
;   botlish_fn_15 / botlish_entry_15 -> tld?<int>
;   botlish_fn_16 / botlish_entry_16 -> domain?<int>
;   botlish_fn_17 / botlish_entry_17 -> web::is_unreserved<int>
;   botlish_fn_18 / botlish_entry_18 -> web::uri_query_value?<str>
;   botlish_fn_19 / botlish_entry_19 -> upper_hex?<int>
;   botlish_fn_20 / botlish_entry_20 -> valid_from?<int>
;   botlish_fn_21 / botlish_entry_21 -> web::uri_escape_text<str>
;   botlish_fn_22 / botlish_entry_22 -> high_nibble<int>
;   botlish_fn_23 / botlish_entry_23 -> hex_pair<int>
;   botlish_fn_24 / botlish_entry_24 -> pct<int>
;   botlish_fn_25 / botlish_entry_25 -> cont<int, int>
;   botlish_fn_26 / botlish_entry_26 -> esc_scalar<int>
;   botlish_fn_27 / botlish_entry_27 -> esc_from<str, int, str>
;   botlish_fn_28 / botlish_entry_28 -> check<int, int, str, str>


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
			3fa: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::set<List[UnicodeChar]>
     3fe:	test   rax,rax
     401:	je     4e8 <botlish_fn_0+0x4e8>
     407:	mov    rdi,QWORD PTR [rsp+0x158]
     40f:	mov    rcx,QWORD PTR [rdi+0x30]
     413:	mov    QWORD PTR [rcx+0x10],rax
     417:	mov    esi,0xe2a0e1
     41c:	call   421 <botlish_fn_0+0x421>
			41d: R_X86_64_PLT32	botlish_fn_21-0x4 ; web::uri_escape_text<str>
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
			460: R_X86_64_PLT32	botlish_fn_28-0x4 ; check<int, int, str, str>
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
			4a4: R_X86_64_PLT32	botlish_fn_28-0x4 ; check<int, int, str, str>
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
     561:	add    BYTE PTR [rax],al
     563:	add    BYTE PTR [rax],al
     565:	add    BYTE PTR [rax],al
	...

0000000000000568 <botlish_fn_1: byte::from_int<int>>:
     568:	push   rbp
     569:	mov    rbp,rsp
     56c:	sub    rsp,0x10
     570:	mov    QWORD PTR [rsp],rbx
     574:	mov    QWORD PTR [rsp+0x8],r12
     579:	mov    r12,rdi
     57c:	test   rsi,0x1
     583:	mov    rax,rsi
     586:	jne    5b5 <botlish_fn_1+0x4d>
     58c:	mov    edx,0x1ff
     591:	mov    rbx,rax
     594:	mov    rsi,rbx
     597:	mov    rdi,r12
     59a:	call   59f <botlish_fn_1+0x37>
			59b: R_X86_64_PLT32	rt_int_cmp-0x4
     59f:	mov    r8d,0x2
     5a5:	test   rax,rax
     5a8:	cmovg  r8,QWORD PTR [rip+0x70]        # 620 <botlish_fn_1+0xb8>
     5b0:	jmp    5cd <botlish_fn_1+0x65>
     5b5:	mov    rbx,rax
     5b8:	mov    r8d,0x2
     5be:	cmp    rbx,0x1ff
     5c5:	cmovg  r8,QWORD PTR [rip+0x53]        # 620 <botlish_fn_1+0xb8>
     5cd:	cmp    r8,0x6
     5d1:	je     5ec <botlish_fn_1+0x84>
     5d7:	mov    rax,rbx
     5da:	mov    rbx,QWORD PTR [rsp]
     5de:	mov    r12,QWORD PTR [rsp+0x8]
     5e3:	add    rsp,0x10
     5e7:	mov    rsp,rbp
     5ea:	pop    rbp
     5eb:	ret
     5ec:	mov    rdi,r12
     5ef:	mov    rax,QWORD PTR [rdi+0x10]
     5f3:	mov    rdx,QWORD PTR [rax+0xb8]
     5fa:	mov    esi,0x2
     5ff:	call   604 <botlish_fn_1+0x9c>
			600: R_X86_64_PLT32	rt_fail_declared-0x4
     604:	xor    rax,rax
     607:	mov    rbx,QWORD PTR [rsp]
     60b:	mov    r12,QWORD PTR [rsp+0x8]
     610:	add    rsp,0x10
     614:	mov    rsp,rbp
     617:	pop    rbp
     618:	ret
     619:	add    BYTE PTR [rax],al
     61b:	add    BYTE PTR [rax],al
     61d:	add    BYTE PTR [rax],al
     61f:	add    BYTE PTR [rsi],al
     621:	add    BYTE PTR [rax],al
     623:	add    BYTE PTR [rax],al
     625:	add    BYTE PTR [rax],al
	...

0000000000000628 <botlish_entry_1: byte::from_int<int>>:
     628:	push   rbp
     629:	mov    rbp,rsp
     62c:	mov    rsi,QWORD PTR [rdx]
     62f:	call   634 <botlish_entry_1+0xc>
			630: R_X86_64_PLT32	botlish_fn_1-0x4 ; byte::from_int<int>
     634:	mov    rsp,rbp
     637:	pop    rbp
     638:	ret
     639:	add    BYTE PTR [rax],al
     63b:	add    BYTE PTR [rax],al
     63d:	add    BYTE PTR [rax],al
	...

0000000000000640 <botlish_fn_2: byte::set<List[UnicodeChar]>>:
     640:	push   rbp
     641:	mov    rbp,rsp
     644:	sub    rsp,0x60
     648:	mov    QWORD PTR [rsp+0x30],rbx
     64d:	mov    QWORD PTR [rsp+0x38],r12
     652:	mov    QWORD PTR [rsp+0x40],r13
     657:	mov    QWORD PTR [rsp+0x48],r14
     65c:	mov    QWORD PTR [rsp+0x50],r15
     661:	mov    r13,rdi
     664:	mov    QWORD PTR [rsp+0x18],0x0
     66d:	mov    QWORD PTR [rsp+0x20],0x0
     676:	mov    QWORD PTR [rsp],rsi
     67a:	mov    rbx,rsi
     67d:	mov    rdi,r13
     680:	call   685 <botlish_fn_2+0x45>
			681: R_X86_64_PLT32	rt_list_len-0x4
     685:	mov    QWORD PTR [rsp+0x8],rax
     68a:	mov    r12,rax
     68d:	mov    QWORD PTR [rsp+0x10],0x1
     696:	xor    rdx,rdx
     699:	mov    rdi,r13
     69c:	mov    rsi,rdx
     69f:	call   6a4 <botlish_fn_2+0x64>
			6a0: R_X86_64_PLT32	rt_list_new-0x4
     6a4:	test   rax,rax
     6a7:	je     7d2 <botlish_fn_2+0x192>
     6ad:	mov    QWORD PTR [rsp+0x18],rax
     6b2:	mov    esi,0x1
     6b7:	mov    r14,rsi
     6ba:	mov    r15,rax
     6bd:	mov    rax,rsi
     6c0:	and    rax,r12
     6c3:	mov    r14,rsi
     6c6:	test   rax,0x1
     6cc:	jne    6f5 <botlish_fn_2+0xb5>
     6d2:	mov    rdx,r12
     6d5:	mov    rsi,r14
     6d8:	mov    rdi,r13
     6db:	call   6e0 <botlish_fn_2+0xa0>
			6dc: R_X86_64_PLT32	rt_int_cmp-0x4
     6e0:	mov    ecx,0x2
     6e5:	test   rax,rax
     6e8:	cmovl  rcx,QWORD PTR [rip+0x180]        # 870 <botlish_fn_2+0x230>
     6f0:	jmp    708 <botlish_fn_2+0xc8>
     6f5:	mov    ecx,0x2
     6fa:	mov    rsi,r14
     6fd:	cmp    rsi,r12
     700:	cmovl  rcx,QWORD PTR [rip+0x168]        # 870 <botlish_fn_2+0x230>
     708:	cmp    rcx,0x6
     70c:	je     743 <botlish_fn_2+0x103>
     712:	mov    rsi,r15
     715:	mov    QWORD PTR [rsp],rsi
     719:	mov    rdi,r13
     71c:	call   721 <botlish_fn_2+0xe1>
			71d: R_X86_64_PLT32	rt_set_from_list-0x4
     721:	mov    rbx,QWORD PTR [rsp+0x30]
     726:	mov    r12,QWORD PTR [rsp+0x38]
     72b:	mov    r13,QWORD PTR [rsp+0x40]
     730:	mov    r14,QWORD PTR [rsp+0x48]
     735:	mov    r15,QWORD PTR [rsp+0x50]
     73a:	add    rsp,0x60
     73e:	mov    rsp,rbp
     741:	pop    rbp
     742:	ret
     743:	mov    rsi,r14
     746:	test   rsi,0x1
     74d:	je     769 <botlish_fn_2+0x129>
     753:	mov    rcx,QWORD PTR [rbx+0x8]
     757:	mov    rsi,r14
     75a:	mov    rax,rsi
     75d:	sar    rax,1
     760:	cmp    rax,rcx
     763:	jb     788 <botlish_fn_2+0x148>
     769:	mov    rdx,r14
     76c:	mov    rsi,rbx
     76f:	mov    rdi,r13
     772:	call   777 <botlish_fn_2+0x137>
			773: R_X86_64_PLT32	rt_list_get-0x4
     777:	test   rax,rax
     77a:	je     7d2 <botlish_fn_2+0x192>
     780:	mov    rsi,rax
     783:	jmp    790 <botlish_fn_2+0x150>
     788:	mov    rsi,QWORD PTR [rbx+0x10]
     78c:	mov    rsi,QWORD PTR [rsi+rax*8]
     790:	mov    edx,0x3
     795:	mov    QWORD PTR [rsp+0x28],rdx
     79a:	shr    rsi,0x3
     79e:	shl    rsi,1
     7a1:	or     rsi,0x1
     7a5:	mov    rdi,r13
     7a8:	call   7ad <botlish_fn_2+0x16d>
			7a9: R_X86_64_PLT32	botlish_fn_1-0x4 ; byte::from_int<int>
     7ad:	test   rax,rax
     7b0:	je     7d2 <botlish_fn_2+0x192>
     7b6:	mov    QWORD PTR [rsp+0x20],rax
     7bb:	mov    rdx,rax
     7be:	mov    rsi,r15
     7c1:	mov    rdi,r13
     7c4:	call   7c9 <botlish_fn_2+0x189>
			7c5: R_X86_64_PLT32	rt_list_append-0x4
     7c9:	test   rax,rax
     7cc:	jne    7f7 <botlish_fn_2+0x1b7>
     7d2:	xor    rax,rax
     7d5:	mov    rbx,QWORD PTR [rsp+0x30]
     7da:	mov    r12,QWORD PTR [rsp+0x38]
     7df:	mov    r13,QWORD PTR [rsp+0x40]
     7e4:	mov    r14,QWORD PTR [rsp+0x48]
     7e9:	mov    r15,QWORD PTR [rsp+0x50]
     7ee:	add    rsp,0x60
     7f2:	mov    rsp,rbp
     7f5:	pop    rbp
     7f6:	ret
     7f7:	mov    QWORD PTR [rsp+0x18],rax
     7fc:	mov    r15,rax
     7ff:	mov    QWORD PTR [rsp+0x20],0x3
     808:	mov    rsi,r14
     80b:	test   rsi,0x1
     812:	jne    825 <botlish_fn_2+0x1e5>
     818:	mov    rdx,QWORD PTR [rsp+0x28]
     81d:	mov    rsi,r14
     820:	jmp    852 <botlish_fn_2+0x212>
     825:	mov    rsi,r14
     828:	mov    rcx,rsi
     82b:	add    rcx,0x2
     82f:	seto   al
     832:	test   al,al
     834:	je     847 <botlish_fn_2+0x207>
     83a:	mov    rdx,QWORD PTR [rsp+0x28]
     83f:	mov    rsi,r14
     842:	jmp    852 <botlish_fn_2+0x212>
     847:	mov    rsi,rcx
     84a:	mov    r14,rcx
     84d:	jmp    860 <botlish_fn_2+0x220>
     852:	mov    rdi,r13
     855:	call   85a <botlish_fn_2+0x21a>
			856: R_X86_64_PLT32	rt_int_add-0x4
     85a:	mov    rsi,rax
     85d:	mov    r14,rax
     860:	mov    QWORD PTR [rsp+0x10],rsi
     865:	mov    rsi,r14
     868:	jmp    6bd <botlish_fn_2+0x7d>
     86d:	add    BYTE PTR [rax],al
     86f:	add    BYTE PTR [rsi],al
     871:	add    BYTE PTR [rax],al
     873:	add    BYTE PTR [rax],al
     875:	add    BYTE PTR [rax],al
	...

0000000000000878 <botlish_entry_2: byte::set<List[UnicodeChar]>>:
     878:	push   rbp
     879:	mov    rbp,rsp
     87c:	mov    rsi,QWORD PTR [rdx]
     87f:	call   884 <botlish_entry_2+0xc>
			880: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::set<List[UnicodeChar]>
     884:	mov    rsp,rbp
     887:	pop    rbp
     888:	ret

0000000000000889 <botlish_fn_3: ascii::is_digit<int>>:
     889:	push   rbp
     88a:	mov    rbp,rsp
     88d:	cmp    rsi,0x30
     891:	jge    8a1 <botlish_fn_3+0x18>
     897:	mov    eax,0x2
     89c:	jmp    8ba <botlish_fn_3+0x31>
     8a1:	cmp    rsi,0x39
     8a5:	jle    8b5 <botlish_fn_3+0x2c>
     8ab:	mov    eax,0x2
     8b0:	jmp    8ba <botlish_fn_3+0x31>
     8b5:	mov    eax,0x6
     8ba:	mov    rsp,rbp
     8bd:	pop    rbp
     8be:	ret

00000000000008bf <botlish_entry_3: ascii::is_digit<int>>:
     8bf:	push   rbp
     8c0:	mov    rbp,rsp
     8c3:	mov    rsi,QWORD PTR [rdx]
     8c6:	sar    rsi,1
     8c9:	call   8ce <botlish_entry_3+0xf>
			8ca: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<int>
     8ce:	mov    rsp,rbp
     8d1:	pop    rbp
     8d2:	ret

00000000000008d3 <botlish_fn_4: ascii::is_upper<int>>:
     8d3:	push   rbp
     8d4:	mov    rbp,rsp
     8d7:	cmp    rsi,0x41
     8db:	jge    8eb <botlish_fn_4+0x18>
     8e1:	mov    eax,0x2
     8e6:	jmp    904 <botlish_fn_4+0x31>
     8eb:	cmp    rsi,0x5a
     8ef:	jle    8ff <botlish_fn_4+0x2c>
     8f5:	mov    eax,0x2
     8fa:	jmp    904 <botlish_fn_4+0x31>
     8ff:	mov    eax,0x6
     904:	mov    rsp,rbp
     907:	pop    rbp
     908:	ret

0000000000000909 <botlish_entry_4: ascii::is_upper<int>>:
     909:	push   rbp
     90a:	mov    rbp,rsp
     90d:	mov    rsi,QWORD PTR [rdx]
     910:	sar    rsi,1
     913:	call   918 <botlish_entry_4+0xf>
			914: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_upper<int>
     918:	mov    rsp,rbp
     91b:	pop    rbp
     91c:	ret

000000000000091d <botlish_fn_5: ascii::is_lower<int>>:
     91d:	push   rbp
     91e:	mov    rbp,rsp
     921:	cmp    rsi,0x61
     925:	jge    935 <botlish_fn_5+0x18>
     92b:	mov    eax,0x2
     930:	jmp    94e <botlish_fn_5+0x31>
     935:	cmp    rsi,0x7a
     939:	jle    949 <botlish_fn_5+0x2c>
     93f:	mov    eax,0x2
     944:	jmp    94e <botlish_fn_5+0x31>
     949:	mov    eax,0x6
     94e:	mov    rsp,rbp
     951:	pop    rbp
     952:	ret

0000000000000953 <botlish_entry_5: ascii::is_lower<int>>:
     953:	push   rbp
     954:	mov    rbp,rsp
     957:	mov    rsi,QWORD PTR [rdx]
     95a:	sar    rsi,1
     95d:	call   962 <botlish_entry_5+0xf>
			95e: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_lower<int>
     962:	mov    rsp,rbp
     965:	pop    rbp
     966:	ret

0000000000000967 <botlish_fn_6: ascii::is_alphabetic<int>>:
     967:	push   rbp
     968:	mov    rbp,rsp
     96b:	sub    rsp,0x10
     96f:	mov    QWORD PTR [rsp],r12
     973:	mov    QWORD PTR [rsp+0x8],r14
     978:	mov    r12,rsi
     97b:	mov    r14,rdi
     97e:	mov    rsi,r12
     981:	mov    rdi,r14
     984:	call   989 <botlish_fn_6+0x22>
			985: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_upper<int>
     989:	cmp    rax,0x6
     98d:	je     9bc <botlish_fn_6+0x55>
     993:	mov    rsi,r12
     996:	mov    rdi,r14
     999:	call   99e <botlish_fn_6+0x37>
			99a: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_lower<int>
     99e:	cmp    rax,0x6
     9a2:	je     9b2 <botlish_fn_6+0x4b>
     9a8:	mov    eax,0x2
     9ad:	jmp    9c1 <botlish_fn_6+0x5a>
     9b2:	mov    eax,0x6
     9b7:	jmp    9c1 <botlish_fn_6+0x5a>
     9bc:	mov    eax,0x6
     9c1:	mov    r12,QWORD PTR [rsp]
     9c5:	mov    r14,QWORD PTR [rsp+0x8]
     9ca:	add    rsp,0x10
     9ce:	mov    rsp,rbp
     9d1:	pop    rbp
     9d2:	ret

00000000000009d3 <botlish_entry_6: ascii::is_alphabetic<int>>:
     9d3:	push   rbp
     9d4:	mov    rbp,rsp
     9d7:	mov    rsi,QWORD PTR [rdx]
     9da:	sar    rsi,1
     9dd:	call   9e2 <botlish_entry_6+0xf>
			9de: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_alphabetic<int>
     9e2:	mov    rsp,rbp
     9e5:	pop    rbp
     9e6:	ret

00000000000009e7 <botlish_fn_7: ascii::is_alphanumeric<int>>:
     9e7:	push   rbp
     9e8:	mov    rbp,rsp
     9eb:	sub    rsp,0x10
     9ef:	mov    QWORD PTR [rsp],r12
     9f3:	mov    QWORD PTR [rsp+0x8],r14
     9f8:	mov    r12,rsi
     9fb:	mov    r14,rdi
     9fe:	mov    rsi,r12
     a01:	mov    rdi,r14
     a04:	call   a09 <botlish_fn_7+0x22>
			a05: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_alphabetic<int>
     a09:	cmp    rax,0x6
     a0d:	je     a3c <botlish_fn_7+0x55>
     a13:	mov    rsi,r12
     a16:	mov    rdi,r14
     a19:	call   a1e <botlish_fn_7+0x37>
			a1a: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<int>
     a1e:	cmp    rax,0x6
     a22:	je     a32 <botlish_fn_7+0x4b>
     a28:	mov    eax,0x2
     a2d:	jmp    a41 <botlish_fn_7+0x5a>
     a32:	mov    eax,0x6
     a37:	jmp    a41 <botlish_fn_7+0x5a>
     a3c:	mov    eax,0x6
     a41:	mov    r12,QWORD PTR [rsp]
     a45:	mov    r14,QWORD PTR [rsp+0x8]
     a4a:	add    rsp,0x10
     a4e:	mov    rsp,rbp
     a51:	pop    rbp
     a52:	ret

0000000000000a53 <botlish_entry_7: ascii::is_alphanumeric<int>>:
     a53:	push   rbp
     a54:	mov    rbp,rsp
     a57:	mov    rsi,QWORD PTR [rdx]
     a5a:	sar    rsi,1
     a5d:	call   a62 <botlish_entry_7+0xf>
			a5e: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphanumeric<int>
     a62:	mov    rsp,rbp
     a65:	pop    rbp
     a66:	ret

0000000000000a67 <botlish_fn_8: web::emailish?<str>>:
     a67:	push   rbp
     a68:	mov    rbp,rsp
     a6b:	sub    rsp,0x50
     a6f:	mov    QWORD PTR [rsp+0x30],rbx
     a74:	mov    QWORD PTR [rsp+0x38],r12
     a79:	mov    QWORD PTR [rsp+0x40],r13
     a7e:	mov    QWORD PTR [rsp+0x48],r14
     a83:	mov    r12,rsi
     a86:	mov    QWORD PTR [rsp],rsi
     a8a:	mov    rsi,r12
     a8d:	mov    rdx,QWORD PTR [rsi+0x8]
     a91:	shl    rdx,1
     a94:	mov    rcx,rdx
     a97:	or     rcx,0x1
     a9b:	mov    r14,rdx
     a9e:	mov    QWORD PTR [rsp+0x8],rcx
     aa3:	mov    rax,QWORD PTR [rdi+0x10]
     aa7:	mov    r13,rdi
     aaa:	mov    rdx,QWORD PTR [rax+0xc0]
     ab1:	mov    QWORD PTR [rsp+0x10],rdx
     ab6:	xor    rsi,rsi
     ab9:	mov    r8,r12
     abc:	call   ac1 <botlish_fn_8+0x5a>
			abd: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<int, block(e251)>
     ac1:	test   rax,rax
     ac4:	je     b5f <botlish_fn_8+0xf8>
     aca:	mov    rbx,rax
     acd:	sar    rbx,1
     ad0:	mov    rsi,rax
     ad3:	test   rbx,rbx
     ad6:	je     b8e <botlish_fn_8+0x127>
     adc:	mov    rcx,r14
     adf:	mov    rax,rcx
     ae2:	or     rax,0x1
     ae6:	sar    rax,1
     ae9:	cmp    rbx,rax
     aec:	jge    b84 <botlish_fn_8+0x11d>
     af2:	mov    rdx,rcx
     af5:	or     rdx,0x1
     af9:	mov    r14,rcx
     afc:	lea    r8,[rsp+0x18]
     b01:	mov    rcx,r12
     b04:	mov    rdi,r13
     b07:	call   b0c <botlish_fn_8+0xa5>
			b08: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     b0c:	mov    rdx,QWORD PTR [rsp+0x18]
     b11:	mov    rcx,QWORD PTR [rsp+0x20]
     b16:	mov    rdi,r13
     b19:	mov    rsi,QWORD PTR [rdi+0x10]
     b1d:	mov    r8,QWORD PTR [rsi+0xc8]
     b24:	mov    rsi,rax
     b27:	call   b2c <botlish_fn_8+0xc5>
			b28: R_X86_64_PLT32	rt_str_region_eq-0x4
     b2c:	cmp    rax,0x6
     b30:	je     b40 <botlish_fn_8+0xd9>
     b36:	mov    eax,0x2
     b3b:	jmp    b93 <botlish_fn_8+0x12c>
     b40:	lea    rsi,[rbx+0x1]
     b44:	mov    rdx,r14
     b47:	or     rdx,0x1
     b4b:	mov    rcx,r12
     b4e:	mov    rdi,r13
     b51:	call   b56 <botlish_fn_8+0xef>
			b52: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain?<int>
     b56:	test   rax,rax
     b59:	jne    b93 <botlish_fn_8+0x12c>
     b5f:	xor    rax,rax
     b62:	mov    rbx,QWORD PTR [rsp+0x30]
     b67:	mov    r12,QWORD PTR [rsp+0x38]
     b6c:	mov    r13,QWORD PTR [rsp+0x40]
     b71:	mov    r14,QWORD PTR [rsp+0x48]
     b76:	add    rsp,0x50
     b7a:	mov    rsp,rbp
     b7d:	pop    rbp
     b7e:	ret
     b7f:	jmp    b93 <botlish_fn_8+0x12c>
     b84:	mov    eax,0x2
     b89:	jmp    b93 <botlish_fn_8+0x12c>
     b8e:	mov    eax,0x2
     b93:	mov    rbx,QWORD PTR [rsp+0x30]
     b98:	mov    r12,QWORD PTR [rsp+0x38]
     b9d:	mov    r13,QWORD PTR [rsp+0x40]
     ba2:	mov    r14,QWORD PTR [rsp+0x48]
     ba7:	add    rsp,0x50
     bab:	mov    rsp,rbp
     bae:	pop    rbp
     baf:	ret

0000000000000bb0 <botlish_entry_8: web::emailish?<str>>:
     bb0:	push   rbp
     bb1:	mov    rbp,rsp
     bb4:	mov    rsi,QWORD PTR [rdx]
     bb7:	call   bbc <botlish_entry_8+0xc>
			bb8: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::emailish?<str>
     bbc:	mov    rsp,rbp
     bbf:	pop    rbp
     bc0:	ret

0000000000000bc1 <botlish_fn_9: char_at<int>>:
     bc1:	push   rbp
     bc2:	mov    rbp,rsp
     bc5:	mov    rax,rsi
     bc8:	sar    rax,1
     bcb:	sar    rdx,1
     bce:	cmp    rax,rdx
     bd1:	jge    be2 <botlish_fn_9+0x21>
     bd7:	mov    r11d,0x2
     bdd:	jmp    be8 <botlish_fn_9+0x27>
     be2:	mov    r11d,0x6
     be8:	cmp    r11,0x6
     bec:	je     c0f <botlish_fn_9+0x4e>
     bf2:	mov    QWORD PTR [r8],rsi
     bf5:	add    rax,0x1
     bfc:	shl    rax,1
     bff:	or     rax,0x1
     c03:	mov    QWORD PTR [r8+0x8],rax
     c07:	mov    rax,rcx
     c0a:	mov    rsp,rbp
     c0d:	pop    rbp
     c0e:	ret
     c0f:	mov    rax,QWORD PTR [rdi+0x10]
     c13:	mov    rax,QWORD PTR [rax+0xd0]
     c1a:	mov    QWORD PTR [r8],0x1
     c21:	mov    QWORD PTR [r8+0x8],0x1
     c29:	mov    rsp,rbp
     c2c:	pop    rbp
     c2d:	ret

0000000000000c2e <botlish_entry_9: char_at<int>>:
     c2e:	push   rbp
     c2f:	mov    rbp,rsp
     c32:	ud2

0000000000000c34 <botlish_fn_10: char_at<int>>:
     c34:	push   rbp
     c35:	mov    rbp,rsp
     c38:	sub    rsp,0x20
     c3c:	mov    QWORD PTR [rsp],rsi
     c40:	mov    QWORD PTR [rsp+0x8],rcx
     c45:	mov    r8,rcx
     c48:	mov    rax,rsi
     c4b:	sar    rax,1
     c4e:	sar    rdx,1
     c51:	cmp    rax,rdx
     c54:	jge    c64 <botlish_fn_10+0x30>
     c5a:	mov    ecx,0x2
     c5f:	jmp    c69 <botlish_fn_10+0x35>
     c64:	mov    ecx,0x6
     c69:	cmp    rcx,0x6
     c6d:	je     c97 <botlish_fn_10+0x63>
     c73:	lea    rcx,[rax+0x1]
     c77:	shl    rcx,1
     c7a:	or     rcx,0x1
     c7e:	mov    QWORD PTR [rsp+0x10],rcx
     c83:	mov    rdx,rsi
     c86:	mov    rsi,r8
     c89:	call   c8e <botlish_fn_10+0x5a>
			c8a: R_X86_64_PLT32	rt_substr_proven-0x4
     c8e:	add    rsp,0x20
     c92:	mov    rsp,rbp
     c95:	pop    rbp
     c96:	ret
     c97:	mov    rax,QWORD PTR [rdi+0x10]
     c9b:	mov    rax,QWORD PTR [rax+0xd0]
     ca2:	add    rsp,0x20
     ca6:	mov    rsp,rbp
     ca9:	pop    rbp
     caa:	ret

0000000000000cab <botlish_entry_10: char_at<int>>:
     cab:	push   rbp
     cac:	mov    rbp,rsp
     caf:	mov    rsi,QWORD PTR [rdx]
     cb2:	mov    r8,QWORD PTR [rdx+0x8]
     cb6:	mov    rcx,QWORD PTR [rdx+0x10]
     cba:	mov    rdx,r8
     cbd:	call   cc2 <botlish_entry_10+0x17>
			cbe: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
     cc2:	mov    rsp,rbp
     cc5:	pop    rbp
     cc6:	ret

0000000000000cc7 <botlish_fn_11: local_char?<str>>:
     cc7:	push   rbp
     cc8:	mov    rbp,rsp
     ccb:	sub    rsp,0x10
     ccf:	mov    QWORD PTR [rsp],rbx
     cd3:	mov    QWORD PTR [rsp+0x8],r14
     cd8:	mov    rbx,rdi
     cdb:	mov    r14,rsi
     cde:	mov    rsi,r14
     ce1:	mov    rdi,rbx
     ce4:	call   ce9 <botlish_fn_11+0x22>
			ce5: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     ce9:	test   rax,rax
     cec:	jne    d07 <botlish_fn_11+0x40>
     cf2:	xor    rax,rax
     cf5:	mov    rbx,QWORD PTR [rsp]
     cf9:	mov    r14,QWORD PTR [rsp+0x8]
     cfe:	add    rsp,0x10
     d02:	mov    rsp,rbp
     d05:	pop    rbp
     d06:	ret
     d07:	cmp    rax,0x6
     d0b:	je     d41 <botlish_fn_11+0x7a>
     d11:	mov    rdi,rbx
     d14:	mov    rax,QWORD PTR [rdi+0x30]
     d18:	mov    rsi,QWORD PTR [rax]
     d1b:	mov    rdx,r14
     d1e:	call   d23 <botlish_fn_11+0x5c>
			d1f: R_X86_64_PLT32	rt_set_contains-0x4
     d23:	cmp    rax,0x6
     d27:	je     d37 <botlish_fn_11+0x70>
     d2d:	mov    eax,0x2
     d32:	jmp    d46 <botlish_fn_11+0x7f>
     d37:	mov    eax,0x6
     d3c:	jmp    d46 <botlish_fn_11+0x7f>
     d41:	mov    eax,0x6
     d46:	mov    rbx,QWORD PTR [rsp]
     d4a:	mov    r14,QWORD PTR [rsp+0x8]
     d4f:	add    rsp,0x10
     d53:	mov    rsp,rbp
     d56:	pop    rbp
     d57:	ret

0000000000000d58 <botlish_entry_11: local_char?<str>>:
     d58:	push   rbp
     d59:	mov    rbp,rsp
     d5c:	mov    rsi,QWORD PTR [rdx]
     d5f:	call   d64 <botlish_entry_11+0xc>
			d60: R_X86_64_PLT32	botlish_fn_11-0x4 ; local_char?<str>
     d64:	mov    rsp,rbp
     d67:	pop    rbp
     d68:	ret

0000000000000d69 <botlish_fn_12: local_char?<generic>>:
     d69:	push   rbp
     d6a:	mov    rbp,rsp
     d6d:	sub    rsp,0x10
     d71:	mov    QWORD PTR [rsp],rbx
     d75:	mov    QWORD PTR [rsp+0x8],r14
     d7a:	mov    rbx,rdi
     d7d:	mov    r14,rsi
     d80:	mov    rsi,r14
     d83:	mov    rdi,rbx
     d86:	call   d8b <botlish_fn_12+0x22>
			d87: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     d8b:	test   rax,rax
     d8e:	jne    da9 <botlish_fn_12+0x40>
     d94:	xor    rax,rax
     d97:	mov    rbx,QWORD PTR [rsp]
     d9b:	mov    r14,QWORD PTR [rsp+0x8]
     da0:	add    rsp,0x10
     da4:	mov    rsp,rbp
     da7:	pop    rbp
     da8:	ret
     da9:	cmp    rax,0x6
     dad:	je     de3 <botlish_fn_12+0x7a>
     db3:	mov    rdi,rbx
     db6:	mov    rax,QWORD PTR [rdi+0x30]
     dba:	mov    rsi,QWORD PTR [rax]
     dbd:	mov    rdx,r14
     dc0:	call   dc5 <botlish_fn_12+0x5c>
			dc1: R_X86_64_PLT32	rt_set_contains-0x4
     dc5:	cmp    rax,0x6
     dc9:	je     dd9 <botlish_fn_12+0x70>
     dcf:	mov    eax,0x2
     dd4:	jmp    de8 <botlish_fn_12+0x7f>
     dd9:	mov    eax,0x6
     dde:	jmp    de8 <botlish_fn_12+0x7f>
     de3:	mov    eax,0x6
     de8:	mov    rbx,QWORD PTR [rsp]
     dec:	mov    r14,QWORD PTR [rsp+0x8]
     df1:	add    rsp,0x10
     df5:	mov    rsp,rbp
     df8:	pop    rbp
     df9:	ret

0000000000000dfa <botlish_entry_12: local_char?<generic>>:
     dfa:	push   rbp
     dfb:	mov    rbp,rsp
     dfe:	mov    rsi,QWORD PTR [rdx]
     e01:	call   e06 <botlish_entry_12+0xc>
			e02: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<generic>
     e06:	mov    rsp,rbp
     e09:	pop    rbp
     e0a:	ret

0000000000000e0b <botlish_fn_13: scan_while<int, block(e251)>>:
     e0b:	push   rbp
     e0c:	mov    rbp,rsp
     e0f:	sub    rsp,0x50
     e13:	mov    QWORD PTR [rsp+0x20],rbx
     e18:	mov    QWORD PTR [rsp+0x28],r12
     e1d:	mov    QWORD PTR [rsp+0x30],r13
     e22:	mov    QWORD PTR [rsp+0x38],r14
     e27:	mov    QWORD PTR [rsp+0x40],r15
     e2c:	mov    QWORD PTR [rsp+0x18],rdi
     e31:	mov    QWORD PTR [rsp],rcx
     e35:	mov    QWORD PTR [rsp+0x8],r8
     e3a:	mov    r15,r8
     e3d:	mov    r12,rcx
     e40:	sar    r12,1
     e43:	mov    r14,rcx
     e46:	mov    rbx,rsi
     e49:	cmp    rbx,r12
     e4c:	jl     e77 <botlish_fn_13+0x6c>
     e52:	mov    rax,r14
     e55:	mov    rbx,QWORD PTR [rsp+0x20]
     e5a:	mov    r12,QWORD PTR [rsp+0x28]
     e5f:	mov    r13,QWORD PTR [rsp+0x30]
     e64:	mov    r14,QWORD PTR [rsp+0x38]
     e69:	mov    r15,QWORD PTR [rsp+0x40]
     e6e:	add    rsp,0x50
     e72:	mov    rsp,rbp
     e75:	pop    rbp
     e76:	ret
     e77:	mov    r13,rbx
     e7a:	shl    r13,1
     e7d:	or     r13,0x1
     e81:	mov    QWORD PTR [rsp+0x10],r13
     e86:	mov    rcx,r15
     e89:	mov    rdx,r14
     e8c:	mov    rsi,r13
     e8f:	mov    rdi,QWORD PTR [rsp+0x18]
     e94:	call   e99 <botlish_fn_13+0x8e>
			e95: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
     e99:	mov    rsi,rax
     e9c:	mov    rdi,QWORD PTR [rsp+0x18]
     ea1:	call   ea6 <botlish_fn_13+0x9b>
			ea2: R_X86_64_PLT32	botlish_fn_11-0x4 ; local_char?<str>
     ea6:	test   rax,rax
     ea9:	jne    ed4 <botlish_fn_13+0xc9>
     eaf:	xor    rax,rax
     eb2:	mov    rbx,QWORD PTR [rsp+0x20]
     eb7:	mov    r12,QWORD PTR [rsp+0x28]
     ebc:	mov    r13,QWORD PTR [rsp+0x30]
     ec1:	mov    r14,QWORD PTR [rsp+0x38]
     ec6:	mov    r15,QWORD PTR [rsp+0x40]
     ecb:	add    rsp,0x50
     ecf:	mov    rsp,rbp
     ed2:	pop    rbp
     ed3:	ret
     ed4:	cmp    rax,0x6
     ed8:	je     f03 <botlish_fn_13+0xf8>
     ede:	mov    rax,r13
     ee1:	mov    rbx,QWORD PTR [rsp+0x20]
     ee6:	mov    r12,QWORD PTR [rsp+0x28]
     eeb:	mov    r13,QWORD PTR [rsp+0x30]
     ef0:	mov    r14,QWORD PTR [rsp+0x38]
     ef5:	mov    r15,QWORD PTR [rsp+0x40]
     efa:	add    rsp,0x50
     efe:	mov    rsp,rbp
     f01:	pop    rbp
     f02:	ret
     f03:	add    rbx,0x1
     f0a:	jmp    e49 <botlish_fn_13+0x3e>

0000000000000f0f <botlish_entry_13: scan_while<int, block(e251)>>:
     f0f:	push   rbp
     f10:	mov    rbp,rsp
     f13:	mov    rsi,QWORD PTR [rdx]
     f16:	mov    r9,QWORD PTR [rdx+0x8]
     f1a:	mov    rcx,QWORD PTR [rdx+0x10]
     f1e:	mov    r8,QWORD PTR [rdx+0x18]
     f22:	sar    rsi,1
     f25:	mov    rdx,r9
     f28:	call   f2d <botlish_entry_13+0x1e>
			f29: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<int, block(e251)>
     f2d:	mov    rsp,rbp
     f30:	pop    rbp
     f31:	ret

0000000000000f32 <botlish_fn_14: scan_while<int, native(str::is_tcl_alpha)>>:
     f32:	push   rbp
     f33:	mov    rbp,rsp
     f36:	sub    rsp,0x40
     f3a:	mov    QWORD PTR [rsp+0x10],rbx
     f3f:	mov    QWORD PTR [rsp+0x18],r12
     f44:	mov    QWORD PTR [rsp+0x20],r13
     f49:	mov    QWORD PTR [rsp+0x28],r14
     f4e:	mov    QWORD PTR [rsp+0x30],r15
     f53:	mov    rbx,r8
     f56:	mov    r13,rdi
     f59:	mov    rax,rcx
     f5c:	sar    rax,1
     f5f:	mov    r12,rcx
     f62:	mov    r14,rax
     f65:	mov    rax,rsi
     f68:	mov    rcx,r14
     f6b:	cmp    rax,rcx
     f6e:	mov    r14,rcx
     f71:	jl     fa1 <botlish_fn_14+0x6f>
     f77:	mov    edx,0x1
     f7c:	mov    rax,r14
     f7f:	mov    rbx,QWORD PTR [rsp+0x10]
     f84:	mov    r12,QWORD PTR [rsp+0x18]
     f89:	mov    r13,QWORD PTR [rsp+0x20]
     f8e:	mov    r14,QWORD PTR [rsp+0x28]
     f93:	mov    r15,QWORD PTR [rsp+0x30]
     f98:	add    rsp,0x40
     f9c:	mov    rsp,rbp
     f9f:	pop    rbp
     fa0:	ret
     fa1:	mov    rsi,rax
     fa4:	shl    rsi,1
     fa7:	mov    r15,rax
     faa:	or     rsi,0x1
     fae:	lea    r8,[rsp]
     fb2:	mov    rcx,rbx
     fb5:	mov    rdx,r12
     fb8:	mov    rdi,r13
     fbb:	call   fc0 <botlish_fn_14+0x8e>
			fbc: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     fc0:	mov    rdx,QWORD PTR [rsp]
     fc4:	mov    rcx,QWORD PTR [rsp+0x8]
     fc9:	mov    rsi,rax
     fcc:	mov    rdi,r13
     fcf:	call   fd4 <botlish_fn_14+0xa2>
			fd0: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
     fd4:	test   rax,rax
     fd7:	jne    1005 <botlish_fn_14+0xd3>
     fdd:	xor    rdx,rdx
     fe0:	mov    rax,rdx
     fe3:	mov    rbx,QWORD PTR [rsp+0x10]
     fe8:	mov    r12,QWORD PTR [rsp+0x18]
     fed:	mov    r13,QWORD PTR [rsp+0x20]
     ff2:	mov    r14,QWORD PTR [rsp+0x28]
     ff7:	mov    r15,QWORD PTR [rsp+0x30]
     ffc:	add    rsp,0x40
    1000:	mov    rsp,rbp
    1003:	pop    rbp
    1004:	ret
    1005:	cmp    rax,0x6
    1009:	je     1039 <botlish_fn_14+0x107>
    100f:	mov    edx,0x1
    1014:	mov    rax,r15
    1017:	mov    rbx,QWORD PTR [rsp+0x10]
    101c:	mov    r12,QWORD PTR [rsp+0x18]
    1021:	mov    r13,QWORD PTR [rsp+0x20]
    1026:	mov    r14,QWORD PTR [rsp+0x28]
    102b:	mov    r15,QWORD PTR [rsp+0x30]
    1030:	add    rsp,0x40
    1034:	mov    rsp,rbp
    1037:	pop    rbp
    1038:	ret
    1039:	mov    rax,r15
    103c:	add    rax,0x1
    1043:	mov    rcx,r14
    1046:	jmp    f6b <botlish_fn_14+0x39>

000000000000104b <botlish_entry_14: scan_while<int, native(str::is_tcl_alpha)>>:
    104b:	push   rbp
    104c:	mov    rbp,rsp
    104f:	mov    rsi,QWORD PTR [rdx]
    1052:	mov    rax,QWORD PTR [rdx+0x8]
    1056:	mov    rcx,QWORD PTR [rdx+0x10]
    105a:	mov    r8,QWORD PTR [rdx+0x18]
    105e:	sar    rsi,1
    1061:	mov    rdx,rax
    1064:	call   1069 <botlish_entry_14+0x1e>
			1065: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, native(str::is_tcl_alpha)>
    1069:	shl    rax,1
    106c:	or     rax,0x1
    1070:	mov    rcx,rax
    1073:	xor    rax,rax
    1076:	test   rdx,rdx
    1079:	cmovne rax,rcx
    107d:	mov    rsp,rbp
    1080:	pop    rbp
    1081:	ret
    1082:	add    BYTE PTR [rax],al
    1084:	add    BYTE PTR [rax],al
	...

0000000000001088 <botlish_fn_15: tld?<int>>:
    1088:	push   rbp
    1089:	mov    rbp,rsp
    108c:	sub    rsp,0x10
    1090:	mov    QWORD PTR [rsp],rbx
    1094:	mov    QWORD PTR [rsp+0x8],r12
    1099:	mov    r8,rdx
    109c:	mov    rax,QWORD PTR [rdi+0x10]
    10a0:	mov    rdx,QWORD PTR [rax+0xd8]
    10a7:	mov    r12,r8
    10aa:	mov    r8,rcx
    10ad:	mov    rbx,rsi
    10b0:	mov    rcx,r12
    10b3:	call   10b8 <botlish_fn_15+0x30>
			10b4: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, native(str::is_tcl_alpha)>
    10b8:	test   rdx,rdx
    10bb:	jne    10d6 <botlish_fn_15+0x4e>
    10c1:	xor    rax,rax
    10c4:	mov    rbx,QWORD PTR [rsp]
    10c8:	mov    r12,QWORD PTR [rsp+0x8]
    10cd:	add    rsp,0x10
    10d1:	mov    rsp,rbp
    10d4:	pop    rbp
    10d5:	ret
    10d6:	sar    r12,1
    10d9:	cmp    rax,r12
    10dc:	je     10ec <botlish_fn_15+0x64>
    10e2:	mov    eax,0x2
    10e7:	jmp    1103 <botlish_fn_15+0x7b>
    10ec:	sub    rax,rbx
    10ef:	mov    rcx,rax
    10f2:	mov    eax,0x2
    10f7:	cmp    rcx,0x2
    10fb:	cmovge rax,QWORD PTR [rip+0x15]        # 1118 <botlish_fn_15+0x90>
    1103:	mov    rbx,QWORD PTR [rsp]
    1107:	mov    r12,QWORD PTR [rsp+0x8]
    110c:	add    rsp,0x10
    1110:	mov    rsp,rbp
    1113:	pop    rbp
    1114:	ret
    1115:	add    BYTE PTR [rax],al
    1117:	add    BYTE PTR [rsi],al
    1119:	add    BYTE PTR [rax],al
    111b:	add    BYTE PTR [rax],al
    111d:	add    BYTE PTR [rax],al
	...

0000000000001120 <botlish_entry_15: tld?<int>>:
    1120:	push   rbp
    1121:	mov    rbp,rsp
    1124:	mov    rsi,QWORD PTR [rdx]
    1127:	mov    r8,QWORD PTR [rdx+0x8]
    112b:	mov    rcx,QWORD PTR [rdx+0x10]
    112f:	sar    rsi,1
    1132:	mov    rdx,r8
    1135:	call   113a <botlish_entry_15+0x1a>
			1136: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld?<int>
    113a:	mov    rsp,rbp
    113d:	pop    rbp
    113e:	ret

000000000000113f <botlish_fn_16: domain?<int>>:
    113f:	push   rbp
    1140:	mov    rbp,rsp
    1143:	sub    rsp,0x80
    114a:	mov    QWORD PTR [rsp+0x50],rbx
    114f:	mov    QWORD PTR [rsp+0x58],r12
    1154:	mov    QWORD PTR [rsp+0x60],r13
    1159:	mov    QWORD PTR [rsp+0x68],r14
    115e:	mov    QWORD PTR [rsp+0x70],r15
    1163:	mov    rbx,rsi
    1166:	mov    r15,rcx
    1169:	mov    r14,rdx
    116c:	sar    r14,1
    116f:	mov    QWORD PTR [rsp+0x30],rdx
    1174:	mov    r12,rbx
    1177:	cmp    r12,r14
    117a:	jl     11aa <botlish_fn_16+0x6b>
    1180:	mov    eax,0x2
    1185:	mov    rbx,QWORD PTR [rsp+0x50]
    118a:	mov    r12,QWORD PTR [rsp+0x58]
    118f:	mov    r13,QWORD PTR [rsp+0x60]
    1194:	mov    r14,QWORD PTR [rsp+0x68]
    1199:	mov    r15,QWORD PTR [rsp+0x70]
    119e:	add    rsp,0x80
    11a5:	mov    rsp,rbp
    11a8:	pop    rbp
    11a9:	ret
    11aa:	mov    rsi,r12
    11ad:	shl    rsi,1
    11b0:	or     rsi,0x1
    11b4:	mov    QWORD PTR [rsp+0x48],rsi
    11b9:	lea    r8,[rsp]
    11bd:	mov    r13,rdi
    11c0:	mov    rcx,r15
    11c3:	mov    rdx,QWORD PTR [rsp+0x30]
    11c8:	call   11cd <botlish_fn_16+0x8e>
			11c9: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    11cd:	mov    rdx,QWORD PTR [rsp]
    11d1:	mov    rcx,QWORD PTR [rsp+0x8]
    11d6:	mov    rsi,QWORD PTR [r13+0x10]
    11da:	mov    r8,QWORD PTR [rsi]
    11dd:	mov    rsi,rax
    11e0:	mov    rdi,r13
    11e3:	call   11e8 <botlish_fn_16+0xa9>
			11e4: R_X86_64_PLT32	rt_str_region_eq-0x4
    11e8:	cmp    rax,0x6
    11ec:	je     12d4 <botlish_fn_16+0x195>
    11f2:	lea    r8,[rsp+0x20]
    11f7:	mov    rsi,QWORD PTR [rsp+0x48]
    11fc:	mov    rcx,r15
    11ff:	mov    rdx,QWORD PTR [rsp+0x30]
    1204:	mov    rdi,r13
    1207:	call   120c <botlish_fn_16+0xcd>
			1208: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    120c:	mov    QWORD PTR [rsp+0x48],rax
    1211:	mov    rdx,QWORD PTR [rsp+0x20]
    1216:	mov    QWORD PTR [rsp+0x40],rdx
    121b:	mov    rcx,QWORD PTR [rsp+0x28]
    1220:	mov    QWORD PTR [rsp+0x38],rcx
    1225:	mov    rsi,QWORD PTR [rsp+0x48]
    122a:	mov    rdi,r13
    122d:	call   1232 <botlish_fn_16+0xf3>
			122e: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1232:	test   rax,rax
    1235:	je     1344 <botlish_fn_16+0x205>
    123b:	cmp    rax,0x6
    123f:	je     1282 <botlish_fn_16+0x143>
    1245:	mov    rcx,QWORD PTR [r13+0x10]
    1249:	mov    r8,QWORD PTR [rcx+0x20]
    124d:	mov    rcx,QWORD PTR [rsp+0x38]
    1252:	mov    rdx,QWORD PTR [rsp+0x40]
    1257:	mov    rsi,QWORD PTR [rsp+0x48]
    125c:	mov    rdi,r13
    125f:	call   1264 <botlish_fn_16+0x125>
			1260: R_X86_64_PLT32	rt_str_region_eq-0x4
    1264:	cmp    rax,0x6
    1268:	je     1278 <botlish_fn_16+0x139>
    126e:	mov    ecx,0x2
    1273:	jmp    1287 <botlish_fn_16+0x148>
    1278:	mov    ecx,0x6
    127d:	jmp    1287 <botlish_fn_16+0x148>
    1282:	mov    ecx,0x6
    1287:	cmp    rcx,0x6
    128b:	je     129b <botlish_fn_16+0x15c>
    1291:	mov    eax,0x6
    1296:	jmp    12a0 <botlish_fn_16+0x161>
    129b:	mov    eax,0x2
    12a0:	cmp    rax,0x6
    12a4:	jne    1376 <botlish_fn_16+0x237>
    12aa:	mov    eax,0x2
    12af:	mov    rbx,QWORD PTR [rsp+0x50]
    12b4:	mov    r12,QWORD PTR [rsp+0x58]
    12b9:	mov    r13,QWORD PTR [rsp+0x60]
    12be:	mov    r14,QWORD PTR [rsp+0x68]
    12c3:	mov    r15,QWORD PTR [rsp+0x70]
    12c8:	add    rsp,0x80
    12cf:	mov    rsp,rbp
    12d2:	pop    rbp
    12d3:	ret
    12d4:	cmp    r12,rbx
    12d7:	je     13d9 <botlish_fn_16+0x29a>
    12dd:	mov    rsi,r12
    12e0:	sub    rsi,0x1
    12e4:	shl    rsi,1
    12e7:	or     rsi,0x1
    12eb:	lea    r8,[rsp+0x10]
    12f0:	mov    rcx,r15
    12f3:	mov    rdx,QWORD PTR [rsp+0x30]
    12f8:	mov    rdi,r13
    12fb:	call   1300 <botlish_fn_16+0x1c1>
			12fc: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    1300:	mov    rdx,QWORD PTR [rsp+0x10]
    1305:	mov    rcx,QWORD PTR [rsp+0x18]
    130a:	mov    rsi,QWORD PTR [r13+0x10]
    130e:	mov    r8,QWORD PTR [rsi]
    1311:	mov    rsi,rax
    1314:	mov    rdi,r13
    1317:	call   131c <botlish_fn_16+0x1dd>
			1318: R_X86_64_PLT32	rt_str_region_eq-0x4
    131c:	cmp    rax,0x6
    1320:	je     13af <botlish_fn_16+0x270>
    1326:	lea    rsi,[r12+0x1]
    132b:	mov    rcx,r15
    132e:	mov    rdx,QWORD PTR [rsp+0x30]
    1333:	mov    rdi,r13
    1336:	call   133b <botlish_fn_16+0x1fc>
			1337: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld?<int>
    133b:	test   rax,rax
    133e:	jne    136c <botlish_fn_16+0x22d>
    1344:	xor    rax,rax
    1347:	mov    rbx,QWORD PTR [rsp+0x50]
    134c:	mov    r12,QWORD PTR [rsp+0x58]
    1351:	mov    r13,QWORD PTR [rsp+0x60]
    1356:	mov    r14,QWORD PTR [rsp+0x68]
    135b:	mov    r15,QWORD PTR [rsp+0x70]
    1360:	add    rsp,0x80
    1367:	mov    rsp,rbp
    136a:	pop    rbp
    136b:	ret
    136c:	cmp    rax,0x6
    1370:	je     1385 <botlish_fn_16+0x246>
    1376:	add    r12,0x1
    137d:	mov    rdi,r13
    1380:	jmp    1177 <botlish_fn_16+0x38>
    1385:	mov    eax,0x6
    138a:	mov    rbx,QWORD PTR [rsp+0x50]
    138f:	mov    r12,QWORD PTR [rsp+0x58]
    1394:	mov    r13,QWORD PTR [rsp+0x60]
    1399:	mov    r14,QWORD PTR [rsp+0x68]
    139e:	mov    r15,QWORD PTR [rsp+0x70]
    13a3:	add    rsp,0x80
    13aa:	mov    rsp,rbp
    13ad:	pop    rbp
    13ae:	ret
    13af:	mov    eax,0x2
    13b4:	mov    rbx,QWORD PTR [rsp+0x50]
    13b9:	mov    r12,QWORD PTR [rsp+0x58]
    13be:	mov    r13,QWORD PTR [rsp+0x60]
    13c3:	mov    r14,QWORD PTR [rsp+0x68]
    13c8:	mov    r15,QWORD PTR [rsp+0x70]
    13cd:	add    rsp,0x80
    13d4:	mov    rsp,rbp
    13d7:	pop    rbp
    13d8:	ret
    13d9:	mov    eax,0x2
    13de:	mov    rbx,QWORD PTR [rsp+0x50]
    13e3:	mov    r12,QWORD PTR [rsp+0x58]
    13e8:	mov    r13,QWORD PTR [rsp+0x60]
    13ed:	mov    r14,QWORD PTR [rsp+0x68]
    13f2:	mov    r15,QWORD PTR [rsp+0x70]
    13f7:	add    rsp,0x80
    13fe:	mov    rsp,rbp
    1401:	pop    rbp
    1402:	ret

0000000000001403 <botlish_entry_16: domain?<int>>:
    1403:	push   rbp
    1404:	mov    rbp,rsp
    1407:	mov    rsi,QWORD PTR [rdx]
    140a:	mov    r8,QWORD PTR [rdx+0x8]
    140e:	mov    rcx,QWORD PTR [rdx+0x10]
    1412:	sar    rsi,1
    1415:	mov    rdx,r8
    1418:	call   141d <botlish_entry_16+0x1a>
			1419: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain?<int>
    141d:	mov    rsp,rbp
    1420:	pop    rbp
    1421:	ret

0000000000001422 <botlish_fn_17: web::is_unreserved<int>>:
    1422:	push   rbp
    1423:	mov    rbp,rsp
    1426:	sub    rsp,0x10
    142a:	mov    QWORD PTR [rsp],rbx
    142e:	mov    QWORD PTR [rsp+0x8],r14
    1433:	mov    r14,rsi
    1436:	mov    rsi,r14
    1439:	sar    rsi,1
    143c:	mov    rbx,rdi
    143f:	call   1444 <botlish_fn_17+0x22>
			1440: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphanumeric<int>
    1444:	cmp    rax,0x6
    1448:	je     147f <botlish_fn_17+0x5d>
    144e:	mov    rax,QWORD PTR [rbx+0x30]
    1452:	mov    rsi,QWORD PTR [rax+0x10]
    1456:	mov    rdx,r14
    1459:	mov    rdi,rbx
    145c:	call   1461 <botlish_fn_17+0x3f>
			145d: R_X86_64_PLT32	rt_set_contains-0x4
    1461:	cmp    rax,0x6
    1465:	je     1475 <botlish_fn_17+0x53>
    146b:	mov    eax,0x2
    1470:	jmp    1484 <botlish_fn_17+0x62>
    1475:	mov    eax,0x6
    147a:	jmp    1484 <botlish_fn_17+0x62>
    147f:	mov    eax,0x6
    1484:	mov    rbx,QWORD PTR [rsp]
    1488:	mov    r14,QWORD PTR [rsp+0x8]
    148d:	add    rsp,0x10
    1491:	mov    rsp,rbp
    1494:	pop    rbp
    1495:	ret

0000000000001496 <botlish_entry_17: web::is_unreserved<int>>:
    1496:	push   rbp
    1497:	mov    rbp,rsp
    149a:	mov    rsi,QWORD PTR [rdx]
    149d:	call   14a2 <botlish_entry_17+0xc>
			149e: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<int>
    14a2:	mov    rsp,rbp
    14a5:	pop    rbp
    14a6:	ret

00000000000014a7 <botlish_fn_18: web::uri_query_value?<str>>:
    14a7:	push   rbp
    14a8:	mov    rbp,rsp
    14ab:	sub    rsp,0x10
    14af:	mov    QWORD PTR [rsp],rsi
    14b3:	mov    rdx,rsi
    14b6:	mov    esi,0x1
    14bb:	mov    QWORD PTR [rsp+0x8],0x1
    14c4:	call   14c9 <botlish_fn_18+0x22>
			14c5: R_X86_64_PLT32	botlish_fn_20-0x4 ; valid_from?<int>
    14c9:	add    rsp,0x10
    14cd:	mov    rsp,rbp
    14d0:	pop    rbp
    14d1:	ret

00000000000014d2 <botlish_entry_18: web::uri_query_value?<str>>:
    14d2:	push   rbp
    14d3:	mov    rbp,rsp
    14d6:	mov    rsi,QWORD PTR [rdx]
    14d9:	call   14de <botlish_entry_18+0xc>
			14da: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::uri_query_value?<str>
    14de:	mov    rsp,rbp
    14e1:	pop    rbp
    14e2:	ret
    14e3:	add    BYTE PTR [rax],al
    14e5:	add    BYTE PTR [rax],al
	...

00000000000014e8 <botlish_fn_19: upper_hex?<int>>:
    14e8:	push   rbp
    14e9:	mov    rbp,rsp
    14ec:	sub    rsp,0x20
    14f0:	mov    QWORD PTR [rsp],rbx
    14f4:	mov    QWORD PTR [rsp+0x8],r12
    14f9:	mov    QWORD PTR [rsp+0x10],r13
    14fe:	mov    r12,rdi
    1501:	mov    r13,rdx
    1504:	mov    rdx,r13
    1507:	mov    rdx,QWORD PTR [rdx+0x8]
    150b:	shl    rdx,1
    150e:	mov    rax,rdx
    1511:	or     rax,0x1
    1515:	mov    rcx,rsi
    1518:	and    rcx,rax
    151b:	test   rcx,0x1
    1522:	jne    154f <botlish_fn_19+0x67>
    1528:	or     rdx,0x1
    152c:	mov    rbx,rsi
    152f:	mov    rdi,r12
    1532:	call   1537 <botlish_fn_19+0x4f>
			1533: R_X86_64_PLT32	rt_int_cmp-0x4
    1537:	mov    ecx,0x2
    153c:	test   rax,rax
    153f:	cmovge rcx,QWORD PTR [rip+0x151]        # 1698 <botlish_fn_19+0x1b0>
    1547:	mov    rsi,rbx
    154a:	jmp    1566 <botlish_fn_19+0x7e>
    154f:	mov    rbx,rsi
    1552:	or     rdx,0x1
    1556:	mov    ecx,0x2
    155b:	cmp    rbx,rdx
    155e:	cmovge rcx,QWORD PTR [rip+0x132]        # 1698 <botlish_fn_19+0x1b0>
    1566:	mov    eax,0x6
    156b:	mov    rbx,rax
    156e:	cmp    rcx,0x6
    1572:	je     1582 <botlish_fn_19+0x9a>
    1578:	mov    eax,0x2
    157d:	jmp    1585 <botlish_fn_19+0x9d>
    1582:	mov    rax,rbx
    1585:	cmp    rax,0x6
    1589:	je     167b <botlish_fn_19+0x193>
    158f:	mov    rdx,r13
    1592:	movzx  rax,BYTE PTR [rdx+0x18]
    1597:	test   rax,rax
    159a:	jne    15b3 <botlish_fn_19+0xcb>
    15a0:	mov    rdx,rsi
    15a3:	mov    rsi,r13
    15a6:	mov    rdi,r12
    15a9:	call   15ae <botlish_fn_19+0xc6>
			15aa: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    15ae:	jmp    15cd <botlish_fn_19+0xe5>
    15b3:	mov    rdx,rsi
    15b6:	mov    rsi,r13
    15b9:	mov    rax,rdx
    15bc:	sar    rax,1
    15bf:	movzx  rax,BYTE PTR [rsi+rax*1+0x19]
    15c5:	shl    rax,0x3
    15c9:	or     rax,0x4
    15cd:	mov    rcx,rax
    15d0:	shr    rcx,0x3
    15d4:	shl    rcx,1
    15d7:	or     rcx,0x1
    15db:	mov    edx,0x2
    15e0:	cmp    rcx,0xff
    15e7:	cmovg  rdx,QWORD PTR [rip+0xa9]        # 1698 <botlish_fn_19+0x1b0>
    15ef:	cmp    rdx,0x6
    15f3:	je     1671 <botlish_fn_19+0x189>
    15f9:	shr    rax,0x3
    15fd:	shl    rax,1
    1600:	or     rax,0x1
    1604:	sar    rax,1
    1607:	mov    rdi,r12
    160a:	mov    r12,rax
    160d:	mov    rsi,r12
    1610:	call   1615 <botlish_fn_19+0x12d>
			1611: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<int>
    1615:	cmp    rax,0x6
    1619:	je     1669 <botlish_fn_19+0x181>
    161f:	mov    rax,r12
    1622:	cmp    rax,0x41
    1626:	jge    1636 <botlish_fn_19+0x14e>
    162c:	mov    ecx,0x2
    1631:	jmp    164d <botlish_fn_19+0x165>
    1636:	cmp    rax,0x46
    163a:	jle    164a <botlish_fn_19+0x162>
    1640:	mov    ecx,0x2
    1645:	jmp    164d <botlish_fn_19+0x165>
    164a:	mov    rcx,rbx
    164d:	cmp    rcx,0x6
    1651:	je     1661 <botlish_fn_19+0x179>
    1657:	mov    eax,0x2
    165c:	jmp    1680 <botlish_fn_19+0x198>
    1661:	mov    rax,rbx
    1664:	jmp    1680 <botlish_fn_19+0x198>
    1669:	mov    rax,rbx
    166c:	jmp    1680 <botlish_fn_19+0x198>
    1671:	mov    eax,0x2
    1676:	jmp    1680 <botlish_fn_19+0x198>
    167b:	mov    eax,0x2
    1680:	mov    rbx,QWORD PTR [rsp]
    1684:	mov    r12,QWORD PTR [rsp+0x8]
    1689:	mov    r13,QWORD PTR [rsp+0x10]
    168e:	add    rsp,0x20
    1692:	mov    rsp,rbp
    1695:	pop    rbp
    1696:	ret
    1697:	add    BYTE PTR [rsi],al
    1699:	add    BYTE PTR [rax],al
    169b:	add    BYTE PTR [rax],al
    169d:	add    BYTE PTR [rax],al
	...

00000000000016a0 <botlish_entry_19: upper_hex?<int>>:
    16a0:	push   rbp
    16a1:	mov    rbp,rsp
    16a4:	mov    rsi,QWORD PTR [rdx]
    16a7:	mov    rdx,QWORD PTR [rdx+0x8]
    16ab:	call   16b0 <botlish_entry_19+0x10>
			16ac: R_X86_64_PLT32	botlish_fn_19-0x4 ; upper_hex?<int>
    16b0:	mov    rsp,rbp
    16b3:	pop    rbp
    16b4:	ret
    16b5:	add    BYTE PTR [rax],al
	...

00000000000016b8 <botlish_fn_20: valid_from?<int>>:
    16b8:	push   rbp
    16b9:	mov    rbp,rsp
    16bc:	sub    rsp,0x40
    16c0:	mov    QWORD PTR [rsp+0x20],r12
    16c5:	mov    QWORD PTR [rsp+0x28],r13
    16ca:	mov    QWORD PTR [rsp+0x30],r14
    16cf:	mov    r13,rdi
    16d2:	mov    QWORD PTR [rsp],rsi
    16d6:	mov    r14,rsi
    16d9:	mov    QWORD PTR [rsp+0x8],rdx
    16de:	mov    r12,rdx
    16e1:	mov    rdx,QWORD PTR [r12+0x8]
    16e6:	shl    rdx,1
    16e9:	or     rdx,0x1
    16ed:	mov    rsi,r14
    16f0:	mov    r8,rsi
    16f3:	and    r8,rdx
    16f6:	test   r8,0x1
    16fd:	jne    1723 <botlish_fn_20+0x6b>
    1703:	mov    rsi,r14
    1706:	mov    rdi,r13
    1709:	call   170e <botlish_fn_20+0x56>
			170a: R_X86_64_PLT32	rt_int_cmp-0x4
    170e:	mov    ecx,0x2
    1713:	test   rax,rax
    1716:	cmovge rcx,QWORD PTR [rip+0x292]        # 19b0 <botlish_fn_20+0x2f8>
    171e:	jmp    1736 <botlish_fn_20+0x7e>
    1723:	mov    ecx,0x2
    1728:	mov    rsi,r14
    172b:	cmp    rsi,rdx
    172e:	cmovge rcx,QWORD PTR [rip+0x27a]        # 19b0 <botlish_fn_20+0x2f8>
    1736:	cmp    rcx,0x6
    173a:	je     174a <botlish_fn_20+0x92>
    1740:	mov    ecx,0x2
    1745:	jmp    174f <botlish_fn_20+0x97>
    174a:	mov    ecx,0x6
    174f:	cmp    rcx,0x6
    1753:	je     198e <botlish_fn_20+0x2d6>
    1759:	movzx  rax,BYTE PTR [r12+0x18]
    175f:	test   rax,rax
    1762:	jne    177e <botlish_fn_20+0xc6>
    1768:	mov    rdx,r14
    176b:	mov    rsi,r12
    176e:	mov    rdi,r13
    1771:	call   1776 <botlish_fn_20+0xbe>
			1772: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    1776:	mov    rsi,rax
    1779:	jmp    1795 <botlish_fn_20+0xdd>
    177e:	mov    rsi,r14
    1781:	mov    rax,rsi
    1784:	sar    rax,1
    1787:	movzx  rsi,BYTE PTR [r12+rax*1+0x19]
    178d:	shl    rsi,0x3
    1791:	or     rsi,0x4
    1795:	cmp    rsi,0x12c
    179c:	je     185c <botlish_fn_20+0x1a4>
    17a2:	mov    rcx,rsi
    17a5:	shr    rcx,0x3
    17a9:	shl    rcx,1
    17ac:	or     rcx,0x1
    17b0:	mov    edx,0x2
    17b5:	cmp    rcx,0xff
    17bc:	cmovg  rdx,QWORD PTR [rip+0x1ec]        # 19b0 <botlish_fn_20+0x2f8>
    17c4:	cmp    rdx,0x6
    17c8:	je     1852 <botlish_fn_20+0x19a>
    17ce:	shr    rsi,0x3
    17d2:	shl    rsi,1
    17d5:	or     rsi,0x1
    17d9:	mov    rdi,r13
    17dc:	call   17e1 <botlish_fn_20+0x129>
			17dd: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<int>
    17e1:	cmp    rax,0x6
    17e5:	je     17f5 <botlish_fn_20+0x13d>
    17eb:	mov    eax,0x2
    17f0:	jmp    1993 <botlish_fn_20+0x2db>
    17f5:	mov    QWORD PTR [rsp+0x10],0x3
    17fe:	mov    rsi,r14
    1801:	test   rsi,0x1
    1808:	je     182e <botlish_fn_20+0x176>
    180e:	mov    rsi,r14
    1811:	mov    rcx,rsi
    1814:	add    rcx,0x2
    1818:	seto   al
    181b:	test   al,al
    181d:	jne    182e <botlish_fn_20+0x176>
    1823:	mov    rsi,rcx
    1826:	mov    r14,rcx
    1829:	jmp    1844 <botlish_fn_20+0x18c>
    182e:	mov    edx,0x3
    1833:	mov    rsi,r14
    1836:	mov    rdi,r13
    1839:	call   183e <botlish_fn_20+0x186>
			183a: R_X86_64_PLT32	rt_int_add-0x4
    183e:	mov    rsi,rax
    1841:	mov    r14,rax
    1844:	mov    QWORD PTR [rsp],rsi
    1848:	mov    QWORD PTR [rsp+0x8],r12
    184d:	jmp    16e1 <botlish_fn_20+0x29>
    1852:	mov    eax,0x2
    1857:	jmp    1993 <botlish_fn_20+0x2db>
    185c:	mov    QWORD PTR [rsp+0x10],0x3
    1865:	mov    rsi,r14
    1868:	test   rsi,0x1
    186f:	je     1887 <botlish_fn_20+0x1cf>
    1875:	mov    rsi,r14
    1878:	add    rsi,0x2
    187c:	seto   al
    187f:	test   al,al
    1881:	je     189a <botlish_fn_20+0x1e2>
    1887:	mov    edx,0x3
    188c:	mov    rsi,r14
    188f:	mov    rdi,r13
    1892:	call   1897 <botlish_fn_20+0x1df>
			1893: R_X86_64_PLT32	rt_int_add-0x4
    1897:	mov    rsi,rax
    189a:	mov    rdx,r12
    189d:	mov    rdi,r13
    18a0:	call   18a5 <botlish_fn_20+0x1ed>
			18a1: R_X86_64_PLT32	botlish_fn_19-0x4 ; upper_hex?<int>
    18a5:	cmp    rax,0x6
    18a9:	je     18b9 <botlish_fn_20+0x201>
    18af:	mov    ecx,0x2
    18b4:	jmp    191d <botlish_fn_20+0x265>
    18b9:	mov    QWORD PTR [rsp+0x10],0x5
    18c2:	mov    rsi,r14
    18c5:	test   rsi,0x1
    18cc:	je     18e6 <botlish_fn_20+0x22e>
    18d2:	mov    rsi,r14
    18d5:	add    rsi,0x4
    18d9:	seto   dil
    18dd:	test   dil,dil
    18e0:	je     18f9 <botlish_fn_20+0x241>
    18e6:	mov    edx,0x5
    18eb:	mov    rsi,r14
    18ee:	mov    rdi,r13
    18f1:	call   18f6 <botlish_fn_20+0x23e>
			18f2: R_X86_64_PLT32	rt_int_add-0x4
    18f6:	mov    rsi,rax
    18f9:	mov    rdx,r12
    18fc:	mov    rdi,r13
    18ff:	call   1904 <botlish_fn_20+0x24c>
			1900: R_X86_64_PLT32	botlish_fn_19-0x4 ; upper_hex?<int>
    1904:	cmp    rax,0x6
    1908:	je     1918 <botlish_fn_20+0x260>
    190e:	mov    ecx,0x2
    1913:	jmp    191d <botlish_fn_20+0x265>
    1918:	mov    ecx,0x6
    191d:	cmp    rcx,0x6
    1921:	je     1931 <botlish_fn_20+0x279>
    1927:	mov    eax,0x2
    192c:	jmp    1993 <botlish_fn_20+0x2db>
    1931:	mov    QWORD PTR [rsp+0x10],0x7
    193a:	mov    rsi,r14
    193d:	test   rsi,0x1
    1944:	je     196a <botlish_fn_20+0x2b2>
    194a:	mov    rsi,r14
    194d:	mov    rcx,rsi
    1950:	add    rcx,0x6
    1954:	seto   al
    1957:	test   al,al
    1959:	jne    196a <botlish_fn_20+0x2b2>
    195f:	mov    rsi,rcx
    1962:	mov    r14,rcx
    1965:	jmp    1980 <botlish_fn_20+0x2c8>
    196a:	mov    edx,0x7
    196f:	mov    rsi,r14
    1972:	mov    rdi,r13
    1975:	call   197a <botlish_fn_20+0x2c2>
			1976: R_X86_64_PLT32	rt_int_add-0x4
    197a:	mov    rsi,rax
    197d:	mov    r14,rax
    1980:	mov    QWORD PTR [rsp],rsi
    1984:	mov    QWORD PTR [rsp+0x8],r12
    1989:	jmp    16e1 <botlish_fn_20+0x29>
    198e:	mov    eax,0x6
    1993:	mov    r12,QWORD PTR [rsp+0x20]
    1998:	mov    r13,QWORD PTR [rsp+0x28]
    199d:	mov    r14,QWORD PTR [rsp+0x30]
    19a2:	add    rsp,0x40
    19a6:	mov    rsp,rbp
    19a9:	pop    rbp
    19aa:	ret
    19ab:	add    BYTE PTR [rax],al
    19ad:	add    BYTE PTR [rax],al
    19af:	add    BYTE PTR [rsi],al
    19b1:	add    BYTE PTR [rax],al
    19b3:	add    BYTE PTR [rax],al
    19b5:	add    BYTE PTR [rax],al
	...

00000000000019b8 <botlish_entry_20: valid_from?<int>>:
    19b8:	push   rbp
    19b9:	mov    rbp,rsp
    19bc:	mov    rsi,QWORD PTR [rdx]
    19bf:	mov    rdx,QWORD PTR [rdx+0x8]
    19c3:	call   19c8 <botlish_entry_20+0x10>
			19c4: R_X86_64_PLT32	botlish_fn_20-0x4 ; valid_from?<int>
    19c8:	mov    rsp,rbp
    19cb:	pop    rbp
    19cc:	ret

00000000000019cd <botlish_fn_21: web::uri_escape_text<str>>:
    19cd:	push   rbp
    19ce:	mov    rbp,rsp
    19d1:	sub    rsp,0x10
    19d5:	mov    edx,0x1
    19da:	mov    QWORD PTR [rsp],0x1
    19e2:	mov    r10,QWORD PTR [rdi+0x10]
    19e6:	mov    rcx,QWORD PTR [r10+0xd0]
    19ed:	mov    QWORD PTR [rsp+0x8],rcx
    19f2:	call   19f7 <botlish_fn_21+0x2a>
			19f3: R_X86_64_PLT32	botlish_fn_27-0x4 ; esc_from<str, int, str>
    19f7:	test   rax,rax
    19fa:	jne    1a0c <botlish_fn_21+0x3f>
    1a00:	xor    rax,rax
    1a03:	add    rsp,0x10
    1a07:	mov    rsp,rbp
    1a0a:	pop    rbp
    1a0b:	ret
    1a0c:	add    rsp,0x10
    1a10:	mov    rsp,rbp
    1a13:	pop    rbp
    1a14:	ret

0000000000001a15 <botlish_entry_21: web::uri_escape_text<str>>:
    1a15:	push   rbp
    1a16:	mov    rbp,rsp
    1a19:	sub    rsp,0x10
    1a1d:	mov    QWORD PTR [rsp],r12
    1a21:	mov    r12,rdi
    1a24:	mov    rsi,QWORD PTR [rdx]
    1a27:	mov    r8,QWORD PTR [rip+0x0]        # 1a2e <botlish_entry_21+0x19>
			1a2a: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    1a2e:	call   r8
    1a31:	mov    rsi,rax
    1a34:	mov    rdi,r12
    1a37:	call   1a3c <botlish_entry_21+0x27>
			1a38: R_X86_64_PLT32	botlish_fn_21-0x4 ; web::uri_escape_text<str>
    1a3c:	mov    r12,QWORD PTR [rsp]
    1a40:	add    rsp,0x10
    1a44:	mov    rsp,rbp
    1a47:	pop    rbp
    1a48:	ret

0000000000001a49 <botlish_fn_22: high_nibble<int>>:
    1a49:	push   rbp
    1a4a:	mov    rbp,rsp
    1a4d:	sub    rsp,0x10
    1a51:	mov    QWORD PTR [rsp],rsi
    1a55:	mov    QWORD PTR [rsp+0x8],0x1e1
    1a5e:	test   rsi,0x1
    1a65:	jne    1a7a <botlish_fn_22+0x31>
    1a6b:	mov    edx,0x1e1
    1a70:	call   1a75 <botlish_fn_22+0x2c>
			1a71: R_X86_64_PLT32	rt_int_and-0x4
    1a75:	jmp    1a84 <botlish_fn_22+0x3b>
    1a7a:	and    rsi,0x1e1
    1a81:	mov    rax,rsi
    1a84:	sar    rax,0x5
    1a88:	shl    rax,1
    1a8b:	or     rax,0x1
    1a8f:	add    rsp,0x10
    1a93:	mov    rsp,rbp
    1a96:	pop    rbp
    1a97:	ret

0000000000001a98 <botlish_entry_22: high_nibble<int>>:
    1a98:	push   rbp
    1a99:	mov    rbp,rsp
    1a9c:	mov    rsi,QWORD PTR [rdx]
    1a9f:	call   1aa4 <botlish_entry_22+0xc>
			1aa0: R_X86_64_PLT32	botlish_fn_22-0x4 ; high_nibble<int>
    1aa4:	mov    rsp,rbp
    1aa7:	pop    rbp
    1aa8:	ret

0000000000001aa9 <botlish_fn_23: hex_pair<int>>:
    1aa9:	push   rbp
    1aaa:	mov    rbp,rsp
    1aad:	sub    rsp,0x50
    1ab1:	mov    QWORD PTR [rsp+0x30],rbx
    1ab6:	mov    QWORD PTR [rsp+0x38],r12
    1abb:	mov    QWORD PTR [rsp+0x40],r13
    1ac0:	mov    QWORD PTR [rsp+0x48],r14
    1ac5:	mov    QWORD PTR [rsp],rsi
    1ac9:	mov    r14,rsi
    1acc:	mov    rax,QWORD PTR [rdi+0x30]
    1ad0:	mov    r13,rdi
    1ad3:	mov    rbx,QWORD PTR [rax+0x8]
    1ad7:	mov    QWORD PTR [rsp+0x8],rbx
    1adc:	mov    rsi,r14
    1adf:	call   1ae4 <botlish_fn_23+0x3b>
			1ae0: R_X86_64_PLT32	botlish_fn_22-0x4 ; high_nibble<int>
    1ae4:	mov    rcx,QWORD PTR [rbx+0x10]
    1ae8:	sar    rax,1
    1aeb:	mov    r12,QWORD PTR [rcx+rax*8]
    1aef:	mov    QWORD PTR [rsp],r12
    1af3:	mov    rdi,r13
    1af6:	mov    rax,QWORD PTR [rdi+0x30]
    1afa:	mov    rbx,QWORD PTR [rax+0x8]
    1afe:	mov    edx,0x21
    1b03:	mov    rsi,r14
    1b06:	call   1b0b <botlish_fn_23+0x62>
			1b07: R_X86_64_PLT32	rt_int_mod-0x4
    1b0b:	test   rax,rax
    1b0e:	je     1b60 <botlish_fn_23+0xb7>
    1b14:	mov    rcx,QWORD PTR [rbx+0x10]
    1b18:	sar    rax,1
    1b1b:	mov    rdx,QWORD PTR [rcx+rax*8]
    1b1f:	mov    QWORD PTR [rsp+0x8],rdx
    1b24:	lea    rcx,[rsp+0x10]
    1b29:	mov    QWORD PTR [rsp+0x10],0x0
    1b32:	mov    QWORD PTR [rsp+0x18],r12
    1b37:	mov    QWORD PTR [rsp+0x20],0x0
    1b40:	mov    QWORD PTR [rsp+0x28],rdx
    1b45:	mov    esi,0x2
    1b4a:	mov    edx,0x4
    1b4f:	mov    rdi,r13
    1b52:	call   1b57 <botlish_fn_23+0xae>
			1b53: R_X86_64_PLT32	rt_construct-0x4
    1b57:	test   rax,rax
    1b5a:	jne    1b80 <botlish_fn_23+0xd7>
    1b60:	xor    rax,rax
    1b63:	mov    rbx,QWORD PTR [rsp+0x30]
    1b68:	mov    r12,QWORD PTR [rsp+0x38]
    1b6d:	mov    r13,QWORD PTR [rsp+0x40]
    1b72:	mov    r14,QWORD PTR [rsp+0x48]
    1b77:	add    rsp,0x50
    1b7b:	mov    rsp,rbp
    1b7e:	pop    rbp
    1b7f:	ret
    1b80:	mov    rbx,QWORD PTR [rsp+0x30]
    1b85:	mov    r12,QWORD PTR [rsp+0x38]
    1b8a:	mov    r13,QWORD PTR [rsp+0x40]
    1b8f:	mov    r14,QWORD PTR [rsp+0x48]
    1b94:	add    rsp,0x50
    1b98:	mov    rsp,rbp
    1b9b:	pop    rbp
    1b9c:	ret

0000000000001b9d <botlish_entry_23: hex_pair<int>>:
    1b9d:	push   rbp
    1b9e:	mov    rbp,rsp
    1ba1:	sub    rsp,0x10
    1ba5:	mov    QWORD PTR [rsp],r12
    1ba9:	mov    r12,rdi
    1bac:	mov    rsi,QWORD PTR [rdx]
    1baf:	call   1bb4 <botlish_entry_23+0x17>
			1bb0: R_X86_64_PLT32	botlish_fn_23-0x4 ; hex_pair<int>
    1bb4:	mov    r8,QWORD PTR [rip+0x0]        # 1bbb <botlish_entry_23+0x1e>
			1bb7: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1bbb:	mov    rsi,rax
    1bbe:	mov    rdi,r12
    1bc1:	call   r8
    1bc4:	mov    r12,QWORD PTR [rsp]
    1bc8:	add    rsp,0x10
    1bcc:	mov    rsp,rbp
    1bcf:	pop    rbp
    1bd0:	ret

0000000000001bd1 <botlish_fn_24: pct<int>>:
    1bd1:	push   rbp
    1bd2:	mov    rbp,rsp
    1bd5:	sub    rsp,0x40
    1bd9:	mov    QWORD PTR [rsp+0x30],r12
    1bde:	mov    QWORD PTR [rsp+0x38],r13
    1be3:	mov    QWORD PTR [rsp],rsi
    1be7:	mov    rax,QWORD PTR [rdi+0x10]
    1beb:	mov    r12,rdi
    1bee:	mov    r13,QWORD PTR [rax+0x10]
    1bf2:	mov    QWORD PTR [rsp+0x8],r13
    1bf7:	call   1bfc <botlish_fn_24+0x2b>
			1bf8: R_X86_64_PLT32	botlish_fn_23-0x4 ; hex_pair<int>
    1bfc:	test   rax,rax
    1bff:	je     1c45 <botlish_fn_24+0x74>
    1c05:	mov    QWORD PTR [rsp],rax
    1c09:	lea    rcx,[rsp+0x10]
    1c0e:	mov    QWORD PTR [rsp+0x10],0x0
    1c17:	mov    QWORD PTR [rsp+0x18],r13
    1c1c:	mov    QWORD PTR [rsp+0x20],0x0
    1c25:	mov    QWORD PTR [rsp+0x28],rax
    1c2a:	mov    esi,0x2
    1c2f:	mov    edx,0x4
    1c34:	mov    rdi,r12
    1c37:	call   1c3c <botlish_fn_24+0x6b>
			1c38: R_X86_64_PLT32	rt_construct-0x4
    1c3c:	test   rax,rax
    1c3f:	jne    1c5b <botlish_fn_24+0x8a>
    1c45:	xor    rax,rax
    1c48:	mov    r12,QWORD PTR [rsp+0x30]
    1c4d:	mov    r13,QWORD PTR [rsp+0x38]
    1c52:	add    rsp,0x40
    1c56:	mov    rsp,rbp
    1c59:	pop    rbp
    1c5a:	ret
    1c5b:	mov    r12,QWORD PTR [rsp+0x30]
    1c60:	mov    r13,QWORD PTR [rsp+0x38]
    1c65:	add    rsp,0x40
    1c69:	mov    rsp,rbp
    1c6c:	pop    rbp
    1c6d:	ret

0000000000001c6e <botlish_entry_24: pct<int>>:
    1c6e:	push   rbp
    1c6f:	mov    rbp,rsp
    1c72:	sub    rsp,0x10
    1c76:	mov    QWORD PTR [rsp],r12
    1c7a:	mov    r12,rdi
    1c7d:	mov    rsi,QWORD PTR [rdx]
    1c80:	call   1c85 <botlish_entry_24+0x17>
			1c81: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    1c85:	mov    r8,QWORD PTR [rip+0x0]        # 1c8c <botlish_entry_24+0x1e>
			1c88: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1c8c:	mov    rsi,rax
    1c8f:	mov    rdi,r12
    1c92:	call   r8
    1c95:	mov    r12,QWORD PTR [rsp]
    1c99:	add    rsp,0x10
    1c9d:	mov    rsp,rbp
    1ca0:	pop    rbp
    1ca1:	ret

0000000000001ca2 <botlish_fn_25: cont<int, int>>:
    1ca2:	push   rbp
    1ca3:	mov    rbp,rsp
    1ca6:	sub    rsp,0x30
    1caa:	mov    QWORD PTR [rsp+0x20],rbx
    1caf:	mov    rbx,rdi
    1cb2:	mov    QWORD PTR [rsp],rsi
    1cb6:	mov    QWORD PTR [rsp+0x8],rdx
    1cbb:	mov    QWORD PTR [rsp+0x10],0x101
    1cc4:	mov    rdi,rbx
    1cc7:	call   1ccc <botlish_fn_25+0x2a>
			1cc8: R_X86_64_PLT32	rt_int_shr-0x4
    1ccc:	test   rax,rax
    1ccf:	je     1d52 <botlish_fn_25+0xb0>
    1cd5:	mov    QWORD PTR [rsp],rax
    1cd9:	mov    QWORD PTR [rsp+0x8],0x7f
    1ce2:	test   rax,0x1
    1ce8:	mov    rsi,rax
    1ceb:	jne    1d06 <botlish_fn_25+0x64>
    1cf1:	mov    edx,0x7f
    1cf6:	mov    rdi,rbx
    1cf9:	call   1cfe <botlish_fn_25+0x5c>
			1cfa: R_X86_64_PLT32	rt_int_and-0x4
    1cfe:	mov    rdx,rax
    1d01:	jmp    1d0d <botlish_fn_25+0x6b>
    1d06:	mov    rdx,rsi
    1d09:	and    rdx,0x7f
    1d0d:	mov    QWORD PTR [rsp],rdx
    1d11:	test   rdx,0x1
    1d18:	jne    1d33 <botlish_fn_25+0x91>
    1d1e:	mov    esi,0x101
    1d23:	mov    rdi,rbx
    1d26:	call   1d2b <botlish_fn_25+0x89>
			1d27: R_X86_64_PLT32	rt_int_or-0x4
    1d2b:	mov    rsi,rax
    1d2e:	jmp    1d3d <botlish_fn_25+0x9b>
    1d33:	or     rdx,0x101
    1d3a:	mov    rsi,rdx
    1d3d:	mov    QWORD PTR [rsp],rsi
    1d41:	mov    rdi,rbx
    1d44:	call   1d49 <botlish_fn_25+0xa7>
			1d45: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    1d49:	test   rax,rax
    1d4c:	jne    1d63 <botlish_fn_25+0xc1>
    1d52:	xor    rax,rax
    1d55:	mov    rbx,QWORD PTR [rsp+0x20]
    1d5a:	add    rsp,0x30
    1d5e:	mov    rsp,rbp
    1d61:	pop    rbp
    1d62:	ret
    1d63:	mov    rbx,QWORD PTR [rsp+0x20]
    1d68:	add    rsp,0x30
    1d6c:	mov    rsp,rbp
    1d6f:	pop    rbp
    1d70:	ret

0000000000001d71 <botlish_entry_25: cont<int, int>>:
    1d71:	push   rbp
    1d72:	mov    rbp,rsp
    1d75:	sub    rsp,0x10
    1d79:	mov    QWORD PTR [rsp],r12
    1d7d:	mov    r12,rdi
    1d80:	mov    rsi,QWORD PTR [rdx]
    1d83:	mov    rdx,QWORD PTR [rdx+0x8]
    1d87:	call   1d8c <botlish_entry_25+0x1b>
			1d88: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    1d8c:	mov    r8,QWORD PTR [rip+0x0]        # 1d93 <botlish_entry_25+0x22>
			1d8f: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1d93:	mov    rsi,rax
    1d96:	mov    rdi,r12
    1d99:	call   r8
    1d9c:	mov    r12,QWORD PTR [rsp]
    1da0:	add    rsp,0x10
    1da4:	mov    rsp,rbp
    1da7:	pop    rbp
    1da8:	ret
    1da9:	add    BYTE PTR [rax],al
    1dab:	add    BYTE PTR [rax],al
    1dad:	add    BYTE PTR [rax],al
	...

0000000000001db0 <botlish_fn_26: esc_scalar<int>>:
    1db0:	push   rbp
    1db1:	mov    rbp,rsp
    1db4:	sub    rsp,0xf0
    1dbb:	mov    QWORD PTR [rsp+0xc0],rbx
    1dc3:	mov    QWORD PTR [rsp+0xc8],r12
    1dcb:	mov    QWORD PTR [rsp+0xd0],r13
    1dd3:	mov    QWORD PTR [rsp+0xd8],r14
    1ddb:	mov    QWORD PTR [rsp+0xe0],r15
    1de3:	mov    rbx,rdi
    1de6:	mov    QWORD PTR [rsp+0x18],0x0
    1def:	mov    QWORD PTR [rsp+0x20],0x0
    1df8:	mov    QWORD PTR [rsp],rsi
    1dfc:	test   rsi,0x1
    1e03:	mov    r12,rsi
    1e06:	jne    1e32 <botlish_fn_26+0x82>
    1e0c:	mov    edx,0x1001
    1e11:	mov    rsi,r12
    1e14:	mov    rdi,rbx
    1e17:	call   1e1c <botlish_fn_26+0x6c>
			1e18: R_X86_64_PLT32	rt_int_cmp-0x4
    1e1c:	mov    r11d,0x2
    1e22:	test   rax,rax
    1e25:	cmovl  r11,QWORD PTR [rip+0x3fb]        # 2228 <botlish_fn_26+0x478>
    1e2d:	jmp    1e4a <botlish_fn_26+0x9a>
    1e32:	mov    r11d,0x2
    1e38:	mov    rsi,r12
    1e3b:	cmp    rsi,0x1001
    1e42:	cmovl  r11,QWORD PTR [rip+0x3de]        # 2228 <botlish_fn_26+0x478>
    1e4a:	mov    edx,0x6
    1e4f:	mov    r13,rdx
    1e52:	cmp    r11,0x6
    1e56:	je     2110 <botlish_fn_26+0x360>
    1e5c:	mov    rsi,r12
    1e5f:	test   rsi,0x1
    1e66:	jne    1e91 <botlish_fn_26+0xe1>
    1e6c:	mov    edx,0x20001
    1e71:	mov    rsi,r12
    1e74:	mov    rdi,rbx
    1e77:	call   1e7c <botlish_fn_26+0xcc>
			1e78: R_X86_64_PLT32	rt_int_cmp-0x4
    1e7c:	mov    ecx,0x2
    1e81:	test   rax,rax
    1e84:	cmovl  rcx,QWORD PTR [rip+0x39c]        # 2228 <botlish_fn_26+0x478>
    1e8c:	jmp    1ea8 <botlish_fn_26+0xf8>
    1e91:	mov    ecx,0x2
    1e96:	mov    rsi,r12
    1e99:	cmp    rsi,0x20001
    1ea0:	cmovl  rcx,QWORD PTR [rip+0x380]        # 2228 <botlish_fn_26+0x478>
    1ea8:	cmp    rcx,0x6
    1eac:	je     2023 <botlish_fn_26+0x273>
    1eb2:	mov    QWORD PTR [rsp+0x8],0x1e1
    1ebb:	mov    edx,0x25
    1ec0:	mov    QWORD PTR [rsp+0x10],0x25
    1ec9:	mov    rsi,r12
    1ecc:	mov    rdi,rbx
    1ecf:	call   1ed4 <botlish_fn_26+0x124>
			1ed0: R_X86_64_PLT32	rt_int_shr-0x4
    1ed4:	test   rax,rax
    1ed7:	je     21b9 <botlish_fn_26+0x409>
    1edd:	mov    QWORD PTR [rsp+0x10],rax
    1ee2:	test   rax,0x1
    1ee8:	mov    rdx,rax
    1eeb:	jne    1f06 <botlish_fn_26+0x156>
    1ef1:	mov    esi,0x1e1
    1ef6:	mov    rdi,rbx
    1ef9:	call   1efe <botlish_fn_26+0x14e>
			1efa: R_X86_64_PLT32	rt_int_or-0x4
    1efe:	mov    rsi,rax
    1f01:	jmp    1f10 <botlish_fn_26+0x160>
    1f06:	mov    rsi,rdx
    1f09:	or     rsi,0x1e1
    1f10:	mov    QWORD PTR [rsp+0x8],rsi
    1f15:	mov    rdi,rbx
    1f18:	call   1f1d <botlish_fn_26+0x16d>
			1f19: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    1f1d:	test   rax,rax
    1f20:	je     21b9 <botlish_fn_26+0x409>
    1f26:	mov    QWORD PTR [rsp+0x8],rax
    1f2b:	mov    r13,rax
    1f2e:	mov    edx,0x19
    1f33:	mov    QWORD PTR [rsp+0x10],0x19
    1f3c:	mov    rsi,r12
    1f3f:	mov    rdi,rbx
    1f42:	call   1f47 <botlish_fn_26+0x197>
			1f43: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    1f47:	test   rax,rax
    1f4a:	je     21b9 <botlish_fn_26+0x409>
    1f50:	mov    QWORD PTR [rsp+0x10],rax
    1f55:	mov    r14,rax
    1f58:	mov    edx,0xd
    1f5d:	mov    QWORD PTR [rsp+0x18],0xd
    1f66:	mov    rsi,r12
    1f69:	mov    rdi,rbx
    1f6c:	call   1f71 <botlish_fn_26+0x1c1>
			1f6d: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    1f71:	test   rax,rax
    1f74:	je     21b9 <botlish_fn_26+0x409>
    1f7a:	mov    QWORD PTR [rsp+0x18],rax
    1f7f:	mov    r15,rax
    1f82:	mov    edx,0x1
    1f87:	mov    QWORD PTR [rsp+0x20],0x1
    1f90:	mov    rsi,r12
    1f93:	mov    rdi,rbx
    1f96:	call   1f9b <botlish_fn_26+0x1eb>
			1f97: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    1f9b:	test   rax,rax
    1f9e:	je     21b9 <botlish_fn_26+0x409>
    1fa4:	mov    QWORD PTR [rsp],rax
    1fa8:	lea    rcx,[rsp+0x78]
    1fad:	mov    QWORD PTR [rsp+0x78],0x0
    1fb6:	mov    rdx,r13
    1fb9:	mov    QWORD PTR [rsp+0x80],rdx
    1fc1:	mov    QWORD PTR [rsp+0x88],0x0
    1fcd:	mov    rdx,r14
    1fd0:	mov    QWORD PTR [rsp+0x90],rdx
    1fd8:	mov    QWORD PTR [rsp+0x98],0x0
    1fe4:	mov    rdx,r15
    1fe7:	mov    QWORD PTR [rsp+0xa0],rdx
    1fef:	mov    QWORD PTR [rsp+0xa8],0x0
    1ffb:	mov    QWORD PTR [rsp+0xb0],rax
    2003:	mov    esi,0x2
    2008:	mov    edx,0x8
    200d:	mov    rdi,rbx
    2010:	call   2015 <botlish_fn_26+0x265>
			2011: R_X86_64_PLT32	rt_construct-0x4
    2015:	test   rax,rax
    2018:	je     21b9 <botlish_fn_26+0x409>
    201e:	jmp    21f0 <botlish_fn_26+0x440>
    2023:	mov    QWORD PTR [rsp+0x8],0x1c1
    202c:	mov    edx,0xd
    2031:	mov    rsi,r12
    2034:	mov    r14,rdx
    2037:	sar    rsi,0xd
    203b:	shl    rsi,1
    203e:	mov    rax,rsi
    2041:	or     rax,0x1
    2045:	mov    QWORD PTR [rsp+0x10],rax
    204a:	or     rsi,0x1c1
    2051:	mov    QWORD PTR [rsp+0x8],rsi
    2056:	mov    rdi,rbx
    2059:	call   205e <botlish_fn_26+0x2ae>
			205a: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    205e:	test   rax,rax
    2061:	je     21b9 <botlish_fn_26+0x409>
    2067:	mov    QWORD PTR [rsp+0x8],rax
    206c:	mov    r15,rax
    206f:	mov    QWORD PTR [rsp+0x10],0xd
    2078:	mov    rdx,r14
    207b:	mov    rsi,r12
    207e:	mov    rdi,rbx
    2081:	call   2086 <botlish_fn_26+0x2d6>
			2082: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    2086:	test   rax,rax
    2089:	je     21b9 <botlish_fn_26+0x409>
    208f:	mov    QWORD PTR [rsp+0x10],rax
    2094:	mov    r14,rax
    2097:	mov    edx,0x1
    209c:	mov    QWORD PTR [rsp+0x18],0x1
    20a5:	mov    rsi,r12
    20a8:	mov    rdi,rbx
    20ab:	call   20b0 <botlish_fn_26+0x300>
			20ac: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    20b0:	test   rax,rax
    20b3:	je     21b9 <botlish_fn_26+0x409>
    20b9:	mov    QWORD PTR [rsp],rax
    20bd:	lea    rcx,[rsp+0x48]
    20c2:	mov    QWORD PTR [rsp+0x48],0x0
    20cb:	mov    rdx,r15
    20ce:	mov    QWORD PTR [rsp+0x50],rdx
    20d3:	mov    QWORD PTR [rsp+0x58],0x0
    20dc:	mov    rdx,r14
    20df:	mov    QWORD PTR [rsp+0x60],rdx
    20e4:	mov    QWORD PTR [rsp+0x68],0x0
    20ed:	mov    QWORD PTR [rsp+0x70],rax
    20f2:	mov    esi,0x2
    20f7:	mov    rdx,r13
    20fa:	mov    rdi,rbx
    20fd:	call   2102 <botlish_fn_26+0x352>
			20fe: R_X86_64_PLT32	rt_construct-0x4
    2102:	test   rax,rax
    2105:	je     21b9 <botlish_fn_26+0x409>
    210b:	jmp    21f0 <botlish_fn_26+0x440>
    2110:	mov    QWORD PTR [rsp+0x8],0x181
    2119:	mov    rsi,r12
    211c:	sar    rsi,0x7
    2120:	shl    rsi,1
    2123:	mov    rax,rsi
    2126:	or     rax,0x1
    212a:	mov    QWORD PTR [rsp+0x10],rax
    212f:	or     rsi,0x181
    2136:	mov    QWORD PTR [rsp+0x8],rsi
    213b:	mov    rdi,rbx
    213e:	call   2143 <botlish_fn_26+0x393>
			213f: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    2143:	test   rax,rax
    2146:	je     21b9 <botlish_fn_26+0x409>
    214c:	mov    QWORD PTR [rsp+0x8],rax
    2151:	mov    r13,rax
    2154:	mov    edx,0x1
    2159:	mov    QWORD PTR [rsp+0x10],0x1
    2162:	mov    rsi,r12
    2165:	mov    rdi,rbx
    2168:	call   216d <botlish_fn_26+0x3bd>
			2169: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    216d:	test   rax,rax
    2170:	je     21b9 <botlish_fn_26+0x409>
    2176:	mov    QWORD PTR [rsp],rax
    217a:	lea    rcx,[rsp+0x28]
    217f:	mov    QWORD PTR [rsp+0x28],0x0
    2188:	mov    rdx,r13
    218b:	mov    QWORD PTR [rsp+0x30],rdx
    2190:	mov    QWORD PTR [rsp+0x38],0x0
    2199:	mov    QWORD PTR [rsp+0x40],rax
    219e:	mov    esi,0x2
    21a3:	mov    edx,0x4
    21a8:	mov    rdi,rbx
    21ab:	call   21b0 <botlish_fn_26+0x400>
			21ac: R_X86_64_PLT32	rt_construct-0x4
    21b0:	test   rax,rax
    21b3:	jne    21f0 <botlish_fn_26+0x440>
    21b9:	xor    rax,rax
    21bc:	mov    rbx,QWORD PTR [rsp+0xc0]
    21c4:	mov    r12,QWORD PTR [rsp+0xc8]
    21cc:	mov    r13,QWORD PTR [rsp+0xd0]
    21d4:	mov    r14,QWORD PTR [rsp+0xd8]
    21dc:	mov    r15,QWORD PTR [rsp+0xe0]
    21e4:	add    rsp,0xf0
    21eb:	mov    rsp,rbp
    21ee:	pop    rbp
    21ef:	ret
    21f0:	mov    rbx,QWORD PTR [rsp+0xc0]
    21f8:	mov    r12,QWORD PTR [rsp+0xc8]
    2200:	mov    r13,QWORD PTR [rsp+0xd0]
    2208:	mov    r14,QWORD PTR [rsp+0xd8]
    2210:	mov    r15,QWORD PTR [rsp+0xe0]
    2218:	add    rsp,0xf0
    221f:	mov    rsp,rbp
    2222:	pop    rbp
    2223:	ret
    2224:	add    BYTE PTR [rax],al
    2226:	add    BYTE PTR [rax],al
    2228:	(bad)
    2229:	add    BYTE PTR [rax],al
    222b:	add    BYTE PTR [rax],al
    222d:	add    BYTE PTR [rax],al
	...

0000000000002230 <botlish_entry_26: esc_scalar<int>>:
    2230:	push   rbp
    2231:	mov    rbp,rsp
    2234:	sub    rsp,0x10
    2238:	mov    QWORD PTR [rsp],r12
    223c:	mov    r12,rdi
    223f:	mov    rsi,QWORD PTR [rdx]
    2242:	call   2247 <botlish_entry_26+0x17>
			2243: R_X86_64_PLT32	botlish_fn_26-0x4 ; esc_scalar<int>
    2247:	mov    r8,QWORD PTR [rip+0x0]        # 224e <botlish_entry_26+0x1e>
			224a: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    224e:	mov    rsi,rax
    2251:	mov    rdi,r12
    2254:	call   r8
    2257:	mov    r12,QWORD PTR [rsp]
    225b:	add    rsp,0x10
    225f:	mov    rsp,rbp
    2262:	pop    rbp
    2263:	ret
    2264:	add    BYTE PTR [rax],al
	...

0000000000002268 <botlish_fn_27: esc_from<str, int, str>>:
    2268:	push   rbp
    2269:	mov    rbp,rsp
    226c:	sub    rsp,0x110
    2273:	mov    QWORD PTR [rsp+0xe0],rbx
    227b:	mov    QWORD PTR [rsp+0xe8],r12
    2283:	mov    QWORD PTR [rsp+0xf0],r13
    228b:	mov    QWORD PTR [rsp+0xf8],r14
    2293:	mov    QWORD PTR [rsp+0x100],r15
    229b:	mov    QWORD PTR [rsp+0xa8],rdi
    22a3:	mov    QWORD PTR [rsp+0x10],0x0
    22ac:	mov    QWORD PTR [rsp+0x18],0x0
    22b5:	mov    QWORD PTR [rsp+0x20],0x0
    22be:	mov    QWORD PTR [rsp],rdx
    22c2:	mov    QWORD PTR [rsp+0x8],rcx
    22c7:	mov    r15,rcx
    22ca:	mov    r14d,0x47
    22d0:	mov    rcx,0xffffffffffffffff
    22d7:	bsr    rax,rsi
    22db:	mov    QWORD PTR [rsp+0xb0],rsi
    22e3:	cmove  rax,rcx
    22e7:	mov    ecx,0x3f
    22ec:	sub    rcx,rax
    22ef:	sub    r14,rcx
    22f2:	shr    r14,0x3
    22f6:	shl    r14,1
    22f9:	lea    rbx,[rsp+0x88]
    2301:	lea    r12,[rsp+0x58]
    2306:	lea    r13,[rsp+0x38]
    230b:	mov    rsi,rdx
    230e:	mov    rax,r14
    2311:	or     rax,0x1
    2315:	mov    rcx,rsi
    2318:	and    rcx,rax
    231b:	mov    QWORD PTR [rsp+0xb8],rsi
    2323:	test   rcx,0x1
    232a:	jne    2361 <botlish_fn_27+0xf9>
    2330:	mov    rdx,r14
    2333:	or     rdx,0x1
    2337:	mov    rsi,QWORD PTR [rsp+0xb8]
    233f:	mov    rdi,QWORD PTR [rsp+0xa8]
    2347:	call   234c <botlish_fn_27+0xe4>
			2348: R_X86_64_PLT32	rt_int_cmp-0x4
    234c:	mov    ecx,0x2
    2351:	test   rax,rax
    2354:	cmovge rcx,QWORD PTR [rip+0x4c4]        # 2820 <botlish_fn_27+0x5b8>
    235c:	jmp    2380 <botlish_fn_27+0x118>
    2361:	mov    rax,r14
    2364:	or     rax,0x1
    2368:	mov    ecx,0x2
    236d:	mov    rsi,QWORD PTR [rsp+0xb8]
    2375:	cmp    rsi,rax
    2378:	cmovge rcx,QWORD PTR [rip+0x4a0]        # 2820 <botlish_fn_27+0x5b8>
    2380:	cmp    rcx,0x6
    2384:	je     2394 <botlish_fn_27+0x12c>
    238a:	mov    eax,0x2
    238f:	jmp    2399 <botlish_fn_27+0x131>
    2394:	mov    eax,0x6
    2399:	cmp    rax,0x6
    239d:	je     2783 <botlish_fn_27+0x51b>
    23a3:	mov    rsi,QWORD PTR [rsp+0xb0]
    23ab:	mov    rdi,QWORD PTR [rsp+0xa8]
    23b3:	call   23b8 <botlish_fn_27+0x150>
			23b4: R_X86_64_PLT32	rt_ascii_to_str-0x4
    23b8:	mov    QWORD PTR [rsp+0xd0],rax
    23c0:	mov    QWORD PTR [rsp+0x10],rax
    23c5:	movzx  rcx,BYTE PTR [rax+0x18]
    23ca:	test   rcx,rcx
    23cd:	jne    23f8 <botlish_fn_27+0x190>
    23d3:	mov    rdx,QWORD PTR [rsp+0xb8]
    23db:	mov    rsi,QWORD PTR [rsp+0xd0]
    23e3:	mov    rdi,QWORD PTR [rsp+0xa8]
    23eb:	call   23f0 <botlish_fn_27+0x188>
			23ec: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    23f0:	mov    rsi,rax
    23f3:	jmp    241c <botlish_fn_27+0x1b4>
    23f8:	mov    rsi,QWORD PTR [rsp+0xb8]
    2400:	mov    rcx,rsi
    2403:	sar    rcx,1
    2406:	mov    rax,QWORD PTR [rsp+0xd0]
    240e:	movzx  rsi,BYTE PTR [rax+rcx*1+0x19]
    2414:	shl    rsi,0x3
    2418:	or     rsi,0x4
    241c:	shr    rsi,0x3
    2420:	shl    rsi,1
    2423:	or     rsi,0x1
    2427:	mov    QWORD PTR [rsp+0x10],rsi
    242c:	mov    edi,0x2
    2431:	cmp    rsi,0xff
    2438:	mov    QWORD PTR [rsp+0xc8],rsi
    2440:	cmovg  rdi,QWORD PTR [rip+0x3d8]        # 2820 <botlish_fn_27+0x5b8>
    2448:	cmp    rdi,0x6
    244c:	je     2697 <botlish_fn_27+0x42f>
    2452:	mov    rsi,QWORD PTR [rsp+0xc8]
    245a:	mov    rdi,QWORD PTR [rsp+0xa8]
    2462:	call   2467 <botlish_fn_27+0x1ff>
			2463: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<int>
    2467:	cmp    rax,0x6
    246b:	je     2569 <botlish_fn_27+0x301>
    2471:	mov    QWORD PTR [rsp+0x18],0x3
    247a:	mov    rsi,QWORD PTR [rsp+0xb8]
    2482:	test   rsi,0x1
    2489:	je     24b9 <botlish_fn_27+0x251>
    248f:	mov    rsi,QWORD PTR [rsp+0xb8]
    2497:	mov    rax,rsi
    249a:	add    rax,0x2
    249e:	seto   cl
    24a1:	test   cl,cl
    24a3:	jne    24b9 <botlish_fn_27+0x251>
    24a9:	mov    rsi,rax
    24ac:	mov    QWORD PTR [rsp+0xb8],rax
    24b4:	jmp    24de <botlish_fn_27+0x276>
    24b9:	mov    edx,0x3
    24be:	mov    rsi,QWORD PTR [rsp+0xb8]
    24c6:	mov    rdi,QWORD PTR [rsp+0xa8]
    24ce:	call   24d3 <botlish_fn_27+0x26b>
			24cf: R_X86_64_PLT32	rt_int_add-0x4
    24d3:	mov    rsi,rax
    24d6:	mov    QWORD PTR [rsp+0xb8],rax
    24de:	mov    QWORD PTR [rsp],rsi
    24e2:	mov    rsi,QWORD PTR [rsp+0xc8]
    24ea:	mov    rdi,QWORD PTR [rsp+0xa8]
    24f2:	call   24f7 <botlish_fn_27+0x28f>
			24f3: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    24f7:	test   rax,rax
    24fa:	je     27b4 <botlish_fn_27+0x54c>
    2500:	mov    QWORD PTR [rsp+0x10],rax
    2505:	mov    QWORD PTR [rsp+0x88],0x0
    2511:	mov    QWORD PTR [rsp+0x90],r15
    2519:	mov    QWORD PTR [rsp+0x98],0x0
    2525:	mov    QWORD PTR [rsp+0xa0],rax
    252d:	mov    esi,0x2
    2532:	mov    edx,0x4
    2537:	mov    rcx,rbx
    253a:	mov    rdi,QWORD PTR [rsp+0xa8]
    2542:	call   2547 <botlish_fn_27+0x2df>
			2543: R_X86_64_PLT32	rt_construct-0x4
    2547:	test   rax,rax
    254a:	je     27b4 <botlish_fn_27+0x54c>
    2550:	mov    rsi,QWORD PTR [rsp+0xb8]
    2558:	mov    QWORD PTR [rsp],rsi
    255c:	mov    QWORD PTR [rsp+0x8],rax
    2561:	mov    r15,rax
    2564:	jmp    230e <botlish_fn_27+0xa6>
    2569:	mov    QWORD PTR [rsp+0x18],0x3
    2572:	mov    rsi,QWORD PTR [rsp+0xb8]
    257a:	test   rsi,0x1
    2581:	je     25a1 <botlish_fn_27+0x339>
    2587:	mov    rsi,QWORD PTR [rsp+0xb8]
    258f:	mov    rax,rsi
    2592:	add    rax,0x2
    2596:	seto   cl
    2599:	test   cl,cl
    259b:	je     25bb <botlish_fn_27+0x353>
    25a1:	mov    edx,0x3
    25a6:	mov    rsi,QWORD PTR [rsp+0xb8]
    25ae:	mov    rdi,QWORD PTR [rsp+0xa8]
    25b6:	call   25bb <botlish_fn_27+0x353>
			25b7: R_X86_64_PLT32	rt_int_add-0x4
    25bb:	mov    QWORD PTR [rsp+0x18],rax
    25c0:	mov    QWORD PTR [rsp+0xc0],rax
    25c8:	mov    QWORD PTR [rsp+0x20],0x3
    25d1:	mov    rsi,QWORD PTR [rsp+0xb8]
    25d9:	test   rsi,0x1
    25e0:	je     2600 <botlish_fn_27+0x398>
    25e6:	mov    rsi,QWORD PTR [rsp+0xb8]
    25ee:	mov    rax,rsi
    25f1:	add    rax,0x2
    25f5:	seto   cl
    25f8:	test   cl,cl
    25fa:	je     261a <botlish_fn_27+0x3b2>
    2600:	mov    edx,0x3
    2605:	mov    rsi,QWORD PTR [rsp+0xb8]
    260d:	mov    rdi,QWORD PTR [rsp+0xa8]
    2615:	call   261a <botlish_fn_27+0x3b2>
			2616: R_X86_64_PLT32	rt_int_add-0x4
    261a:	mov    QWORD PTR [rsp+0x20],rax
    261f:	mov    QWORD PTR [rsp+0x58],0x0
    2628:	mov    QWORD PTR [rsp+0x60],r15
    262d:	mov    QWORD PTR [rsp+0x68],0x1
    2636:	mov    rcx,QWORD PTR [rsp+0xd0]
    263e:	mov    QWORD PTR [rsp+0x70],rcx
    2643:	mov    rsi,QWORD PTR [rsp+0xb8]
    264b:	mov    QWORD PTR [rsp+0x78],rsi
    2650:	mov    QWORD PTR [rsp+0x80],rax
    2658:	mov    esi,0x2
    265d:	mov    edx,0x6
    2662:	mov    rcx,r12
    2665:	mov    rdi,QWORD PTR [rsp+0xa8]
    266d:	call   2672 <botlish_fn_27+0x40a>
			266e: R_X86_64_PLT32	rt_construct-0x4
    2672:	test   rax,rax
    2675:	je     27b4 <botlish_fn_27+0x54c>
    267b:	mov    rdi,QWORD PTR [rsp+0xc0]
    2683:	mov    QWORD PTR [rsp],rdi
    2687:	mov    QWORD PTR [rsp+0x8],rax
    268c:	mov    rsi,rdi
    268f:	mov    r15,rax
    2692:	jmp    230e <botlish_fn_27+0xa6>
    2697:	mov    QWORD PTR [rsp+0x18],0x3
    26a0:	mov    rsi,QWORD PTR [rsp+0xb8]
    26a8:	test   rsi,0x1
    26af:	je     26df <botlish_fn_27+0x477>
    26b5:	mov    rsi,QWORD PTR [rsp+0xb8]
    26bd:	mov    rax,rsi
    26c0:	add    rax,0x2
    26c4:	seto   cl
    26c7:	test   cl,cl
    26c9:	jne    26df <botlish_fn_27+0x477>
    26cf:	mov    rsi,rax
    26d2:	mov    QWORD PTR [rsp+0xb8],rax
    26da:	jmp    2704 <botlish_fn_27+0x49c>
    26df:	mov    edx,0x3
    26e4:	mov    rsi,QWORD PTR [rsp+0xb8]
    26ec:	mov    rdi,QWORD PTR [rsp+0xa8]
    26f4:	call   26f9 <botlish_fn_27+0x491>
			26f5: R_X86_64_PLT32	rt_int_add-0x4
    26f9:	mov    rsi,rax
    26fc:	mov    QWORD PTR [rsp+0xb8],rax
    2704:	mov    QWORD PTR [rsp],rsi
    2708:	mov    rsi,QWORD PTR [rsp+0xc8]
    2710:	mov    rdi,QWORD PTR [rsp+0xa8]
    2718:	call   271d <botlish_fn_27+0x4b5>
			2719: R_X86_64_PLT32	botlish_fn_26-0x4 ; esc_scalar<int>
    271d:	test   rax,rax
    2720:	je     27b4 <botlish_fn_27+0x54c>
    2726:	mov    QWORD PTR [rsp+0x10],rax
    272b:	mov    QWORD PTR [rsp+0x38],0x0
    2734:	mov    QWORD PTR [rsp+0x40],r15
    2739:	mov    QWORD PTR [rsp+0x48],0x0
    2742:	mov    QWORD PTR [rsp+0x50],rax
    2747:	mov    esi,0x2
    274c:	mov    edx,0x4
    2751:	mov    rcx,r13
    2754:	mov    rdi,QWORD PTR [rsp+0xa8]
    275c:	call   2761 <botlish_fn_27+0x4f9>
			275d: R_X86_64_PLT32	rt_construct-0x4
    2761:	test   rax,rax
    2764:	je     27b4 <botlish_fn_27+0x54c>
    276a:	mov    rsi,QWORD PTR [rsp+0xb8]
    2772:	mov    QWORD PTR [rsp],rsi
    2776:	mov    QWORD PTR [rsp+0x8],rax
    277b:	mov    r15,rax
    277e:	jmp    230e <botlish_fn_27+0xa6>
    2783:	xor    rsi,rsi
    2786:	lea    rcx,[rsp+0x28]
    278b:	mov    QWORD PTR [rsp+0x28],0x0
    2794:	mov    QWORD PTR [rsp+0x30],r15
    2799:	mov    edx,0x2
    279e:	mov    rdi,QWORD PTR [rsp+0xa8]
    27a6:	call   27ab <botlish_fn_27+0x543>
			27a7: R_X86_64_PLT32	rt_construct-0x4
    27ab:	test   rax,rax
    27ae:	jne    27eb <botlish_fn_27+0x583>
    27b4:	xor    rax,rax
    27b7:	mov    rbx,QWORD PTR [rsp+0xe0]
    27bf:	mov    r12,QWORD PTR [rsp+0xe8]
    27c7:	mov    r13,QWORD PTR [rsp+0xf0]
    27cf:	mov    r14,QWORD PTR [rsp+0xf8]
    27d7:	mov    r15,QWORD PTR [rsp+0x100]
    27df:	add    rsp,0x110
    27e6:	mov    rsp,rbp
    27e9:	pop    rbp
    27ea:	ret
    27eb:	mov    rbx,QWORD PTR [rsp+0xe0]
    27f3:	mov    r12,QWORD PTR [rsp+0xe8]
    27fb:	mov    r13,QWORD PTR [rsp+0xf0]
    2803:	mov    r14,QWORD PTR [rsp+0xf8]
    280b:	mov    r15,QWORD PTR [rsp+0x100]
    2813:	add    rsp,0x110
    281a:	mov    rsp,rbp
    281d:	pop    rbp
    281e:	ret
    281f:	add    BYTE PTR [rsi],al
    2821:	add    BYTE PTR [rax],al
    2823:	add    BYTE PTR [rax],al
    2825:	add    BYTE PTR [rax],al
	...

0000000000002828 <botlish_entry_27: esc_from<str, int, str>>:
    2828:	push   rbp
    2829:	mov    rbp,rsp
    282c:	sub    rsp,0x10
    2830:	mov    QWORD PTR [rsp],r12
    2834:	mov    QWORD PTR [rsp+0x8],r13
    2839:	mov    r12,rdi
    283c:	mov    rsi,QWORD PTR [rdx]
    283f:	mov    r13,rdx
    2842:	mov    r8,QWORD PTR [rip+0x0]        # 2849 <botlish_entry_27+0x21>
			2845: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    2849:	call   r8
    284c:	mov    rcx,r13
    284f:	mov    rdx,QWORD PTR [rcx+0x8]
    2853:	mov    rcx,QWORD PTR [rcx+0x10]
    2857:	mov    rsi,rax
    285a:	mov    rdi,r12
    285d:	call   2862 <botlish_entry_27+0x3a>
			285e: R_X86_64_PLT32	botlish_fn_27-0x4 ; esc_from<str, int, str>
    2862:	mov    r12,QWORD PTR [rsp]
    2866:	mov    r13,QWORD PTR [rsp+0x8]
    286b:	add    rsp,0x10
    286f:	mov    rsp,rbp
    2872:	pop    rbp
    2873:	ret

0000000000002874 <botlish_fn_28: check<int, int, str, str>>:
    2874:	push   rbp
    2875:	mov    rbp,rsp
    2878:	sub    rsp,0x50
    287c:	mov    QWORD PTR [rsp+0x20],rbx
    2881:	mov    QWORD PTR [rsp+0x28],r12
    2886:	mov    QWORD PTR [rsp+0x30],r13
    288b:	mov    QWORD PTR [rsp+0x38],r14
    2890:	mov    QWORD PTR [rsp+0x40],r15
    2895:	mov    r14,rdi
    2898:	mov    QWORD PTR [rsp+0x18],0x0
    28a1:	mov    QWORD PTR [rsp],rdx
    28a5:	mov    QWORD PTR [rsp+0x8],rcx
    28aa:	mov    QWORD PTR [rsp+0x10],r8
    28af:	mov    r12,r8
    28b2:	mov    r13,rsi
    28b5:	mov    r15,rdx
    28b8:	test   r13,r13
    28bb:	jle    2995 <botlish_fn_28+0x121>
    28c1:	mov    rbx,rcx
    28c4:	mov    rsi,rbx
    28c7:	mov    rdi,r14
    28ca:	call   28cf <botlish_fn_28+0x5b>
			28cb: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::emailish?<str>
    28cf:	test   rax,rax
    28d2:	jne    28fd <botlish_fn_28+0x89>
    28d8:	xor    rax,rax
    28db:	mov    rbx,QWORD PTR [rsp+0x20]
    28e0:	mov    r12,QWORD PTR [rsp+0x28]
    28e5:	mov    r13,QWORD PTR [rsp+0x30]
    28ea:	mov    r14,QWORD PTR [rsp+0x38]
    28ef:	mov    r15,QWORD PTR [rsp+0x40]
    28f4:	add    rsp,0x50
    28f8:	mov    rsp,rbp
    28fb:	pop    rbp
    28fc:	ret
    28fd:	cmp    rax,0x6
    2901:	je     291d <botlish_fn_28+0xa9>
    2907:	mov    edx,0x1
    290c:	mov    QWORD PTR [rsp+0x18],0x1
    2915:	mov    rsi,r15
    2918:	jmp    2949 <botlish_fn_28+0xd5>
    291d:	mov    rsi,r12
    2920:	mov    rdi,r14
    2923:	call   2928 <botlish_fn_28+0xb4>
			2924: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::uri_query_value?<str>
    2928:	cmp    rax,0x6
    292c:	je     293c <botlish_fn_28+0xc8>
    2932:	mov    edx,0x1
    2937:	jmp    2941 <botlish_fn_28+0xcd>
    293c:	mov    edx,0x3
    2941:	mov    QWORD PTR [rsp+0x18],rdx
    2946:	mov    rsi,r15
    2949:	mov    rax,rsi
    294c:	and    rax,rdx
    294f:	test   rax,0x1
    2955:	je     2970 <botlish_fn_28+0xfc>
    295b:	lea    rcx,[rdx-0x1]
    295f:	mov    rax,rsi
    2962:	add    rax,rcx
    2965:	seto   cl
    2968:	test   cl,cl
    296a:	je     2978 <botlish_fn_28+0x104>
    2970:	mov    rdi,r14
    2973:	call   2978 <botlish_fn_28+0x104>
			2974: R_X86_64_PLT32	rt_int_add-0x4
    2978:	mov    QWORD PTR [rsp],rax
    297c:	mov    QWORD PTR [rsp+0x8],rbx
    2981:	mov    QWORD PTR [rsp+0x10],r12
    2986:	sub    r13,0x1
    298a:	mov    rcx,rbx
    298d:	mov    r15,rax
    2990:	jmp    28b8 <botlish_fn_28+0x44>
    2995:	mov    rax,r15
    2998:	mov    rbx,QWORD PTR [rsp+0x20]
    299d:	mov    r12,QWORD PTR [rsp+0x28]
    29a2:	mov    r13,QWORD PTR [rsp+0x30]
    29a7:	mov    r14,QWORD PTR [rsp+0x38]
    29ac:	mov    r15,QWORD PTR [rsp+0x40]
    29b1:	add    rsp,0x50
    29b5:	mov    rsp,rbp
    29b8:	pop    rbp
    29b9:	ret

00000000000029ba <botlish_entry_28: check<int, int, str, str>>:
    29ba:	push   rbp
    29bb:	mov    rbp,rsp
    29be:	mov    rsi,QWORD PTR [rdx]
    29c1:	mov    r9,QWORD PTR [rdx+0x8]
    29c5:	mov    rcx,QWORD PTR [rdx+0x10]
    29c9:	mov    r8,QWORD PTR [rdx+0x18]
    29cd:	sar    rsi,1
    29d0:	mov    rdx,r9
    29d3:	call   29d8 <botlish_entry_28+0x1e>
			29d4: R_X86_64_PLT32	botlish_fn_28-0x4 ; check<int, int, str, str>
    29d8:	mov    rsp,rbp
    29db:	pop    rbp
    29dc:	ret

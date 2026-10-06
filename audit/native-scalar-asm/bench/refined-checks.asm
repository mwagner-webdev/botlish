; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 11134  (per function: 1415 217 617 74 74 74 128 128 353 115 154 176 176 295 344 183 770 140 60 501 853 127 103 313 219 287 1255 1615 368)
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
    14fe:	mov    rbx,rdi
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
    152c:	mov    r12,rsi
    152f:	mov    rdi,rbx
    1532:	call   1537 <botlish_fn_19+0x4f>
			1533: R_X86_64_PLT32	rt_int_cmp-0x4
    1537:	mov    ecx,0x2
    153c:	test   rax,rax
    153f:	cmovge rcx,QWORD PTR [rip+0x169]        # 16b0 <botlish_fn_19+0x1c8>
    1547:	mov    rsi,r12
    154a:	jmp    1566 <botlish_fn_19+0x7e>
    154f:	mov    r12,rsi
    1552:	or     rdx,0x1
    1556:	mov    ecx,0x2
    155b:	cmp    r12,rdx
    155e:	cmovge rcx,QWORD PTR [rip+0x14a]        # 16b0 <botlish_fn_19+0x1c8>
    1566:	mov    eax,0x6
    156b:	mov    r12,rax
    156e:	cmp    rcx,0x6
    1572:	je     1582 <botlish_fn_19+0x9a>
    1578:	mov    eax,0x2
    157d:	jmp    1585 <botlish_fn_19+0x9d>
    1582:	mov    rax,r12
    1585:	cmp    rax,0x6
    1589:	je     1692 <botlish_fn_19+0x1aa>
    158f:	mov    rdx,r13
    1592:	movzx  rax,BYTE PTR [rdx+0x18]
    1597:	test   rax,rax
    159a:	jne    15b3 <botlish_fn_19+0xcb>
    15a0:	mov    rdx,rsi
    15a3:	mov    rsi,r13
    15a6:	mov    rdi,rbx
    15a9:	call   15ae <botlish_fn_19+0xc6>
			15aa: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    15ae:	jmp    15ca <botlish_fn_19+0xe2>
    15b3:	mov    rdx,rsi
    15b6:	mov    rsi,r13
    15b9:	sar    rdx,1
    15bc:	movzx  rax,BYTE PTR [rsi+rdx*1+0x19]
    15c2:	shl    rax,0x3
    15c6:	or     rax,0x4
    15ca:	mov    rdx,rax
    15cd:	shr    rdx,0x3
    15d1:	shl    rdx,1
    15d4:	or     rdx,0x1
    15d8:	mov    ecx,0x2
    15dd:	cmp    rdx,0xff
    15e4:	cmovle rcx,QWORD PTR [rip+0xc4]        # 16b0 <botlish_fn_19+0x1c8>
    15ec:	cmp    rcx,0x6
    15f0:	je     1603 <botlish_fn_19+0x11b>
    15f6:	mov    eax,0x2
    15fb:	mov    r12,rax
    15fe:	jmp    1697 <botlish_fn_19+0x1af>
    1603:	shr    rax,0x3
    1607:	shl    rax,1
    160a:	or     rax,0x1
    160e:	sar    rax,1
    1611:	mov    rdi,rbx
    1614:	mov    r13,rax
    1617:	mov    rsi,r13
    161a:	call   161f <botlish_fn_19+0x137>
			161b: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<int>
    161f:	cmp    rax,0x6
    1623:	je     1673 <botlish_fn_19+0x18b>
    1629:	mov    rax,r13
    162c:	cmp    rax,0x41
    1630:	jge    1640 <botlish_fn_19+0x158>
    1636:	mov    esi,0x2
    163b:	jmp    1657 <botlish_fn_19+0x16f>
    1640:	cmp    rax,0x46
    1644:	jle    1654 <botlish_fn_19+0x16c>
    164a:	mov    esi,0x2
    164f:	jmp    1657 <botlish_fn_19+0x16f>
    1654:	mov    rsi,r12
    1657:	cmp    rsi,0x6
    165b:	je     166b <botlish_fn_19+0x183>
    1661:	mov    eax,0x2
    1666:	jmp    1676 <botlish_fn_19+0x18e>
    166b:	mov    rax,r12
    166e:	jmp    1676 <botlish_fn_19+0x18e>
    1673:	mov    rax,r12
    1676:	cmp    rax,0x6
    167a:	je     168a <botlish_fn_19+0x1a2>
    1680:	mov    eax,0x2
    1685:	jmp    1697 <botlish_fn_19+0x1af>
    168a:	mov    rax,r12
    168d:	jmp    1697 <botlish_fn_19+0x1af>
    1692:	mov    eax,0x2
    1697:	mov    rbx,QWORD PTR [rsp]
    169b:	mov    r12,QWORD PTR [rsp+0x8]
    16a0:	mov    r13,QWORD PTR [rsp+0x10]
    16a5:	add    rsp,0x20
    16a9:	mov    rsp,rbp
    16ac:	pop    rbp
    16ad:	ret
    16ae:	add    BYTE PTR [rax],al
    16b0:	(bad)
    16b1:	add    BYTE PTR [rax],al
    16b3:	add    BYTE PTR [rax],al
    16b5:	add    BYTE PTR [rax],al
	...

00000000000016b8 <botlish_entry_19: upper_hex?<int>>:
    16b8:	push   rbp
    16b9:	mov    rbp,rsp
    16bc:	mov    rsi,QWORD PTR [rdx]
    16bf:	mov    rdx,QWORD PTR [rdx+0x8]
    16c3:	call   16c8 <botlish_entry_19+0x10>
			16c4: R_X86_64_PLT32	botlish_fn_19-0x4 ; upper_hex?<int>
    16c8:	mov    rsp,rbp
    16cb:	pop    rbp
    16cc:	ret
    16cd:	add    BYTE PTR [rax],al
	...

00000000000016d0 <botlish_fn_20: valid_from?<int>>:
    16d0:	push   rbp
    16d1:	mov    rbp,rsp
    16d4:	sub    rsp,0x40
    16d8:	mov    QWORD PTR [rsp+0x20],r12
    16dd:	mov    QWORD PTR [rsp+0x28],r13
    16e2:	mov    QWORD PTR [rsp+0x30],r14
    16e7:	mov    r13,rdi
    16ea:	mov    QWORD PTR [rsp],rsi
    16ee:	mov    r14,rsi
    16f1:	mov    QWORD PTR [rsp+0x8],rdx
    16f6:	mov    r12,rdx
    16f9:	mov    rdx,QWORD PTR [r12+0x8]
    16fe:	shl    rdx,1
    1701:	or     rdx,0x1
    1705:	mov    rsi,r14
    1708:	mov    r11,rsi
    170b:	and    r11,rdx
    170e:	test   r11,0x1
    1715:	jne    173b <botlish_fn_20+0x6b>
    171b:	mov    rsi,r14
    171e:	mov    rdi,r13
    1721:	call   1726 <botlish_fn_20+0x56>
			1722: R_X86_64_PLT32	rt_int_cmp-0x4
    1726:	mov    ecx,0x2
    172b:	test   rax,rax
    172e:	cmovge rcx,QWORD PTR [rip+0x2aa]        # 19e0 <botlish_fn_20+0x310>
    1736:	jmp    174e <botlish_fn_20+0x7e>
    173b:	mov    ecx,0x2
    1740:	mov    rsi,r14
    1743:	cmp    rsi,rdx
    1746:	cmovge rcx,QWORD PTR [rip+0x292]        # 19e0 <botlish_fn_20+0x310>
    174e:	cmp    rcx,0x6
    1752:	je     1762 <botlish_fn_20+0x92>
    1758:	mov    ecx,0x2
    175d:	jmp    1767 <botlish_fn_20+0x97>
    1762:	mov    ecx,0x6
    1767:	cmp    rcx,0x6
    176b:	je     19bf <botlish_fn_20+0x2ef>
    1771:	movzx  rax,BYTE PTR [r12+0x18]
    1777:	test   rax,rax
    177a:	jne    1796 <botlish_fn_20+0xc6>
    1780:	mov    rdx,r14
    1783:	mov    rsi,r12
    1786:	mov    rdi,r13
    1789:	call   178e <botlish_fn_20+0xbe>
			178a: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    178e:	mov    rsi,rax
    1791:	jmp    17ad <botlish_fn_20+0xdd>
    1796:	mov    rsi,r14
    1799:	mov    rax,rsi
    179c:	sar    rax,1
    179f:	movzx  rsi,BYTE PTR [r12+rax*1+0x19]
    17a5:	shl    rsi,0x3
    17a9:	or     rsi,0x4
    17ad:	cmp    rsi,0x12c
    17b4:	je     188d <botlish_fn_20+0x1bd>
    17ba:	mov    rcx,rsi
    17bd:	shr    rcx,0x3
    17c1:	shl    rcx,1
    17c4:	or     rcx,0x1
    17c8:	mov    edx,0x2
    17cd:	cmp    rcx,0xff
    17d4:	cmovle rdx,QWORD PTR [rip+0x204]        # 19e0 <botlish_fn_20+0x310>
    17dc:	cmp    rdx,0x6
    17e0:	je     17f0 <botlish_fn_20+0x120>
    17e6:	mov    ecx,0x2
    17eb:	jmp    181c <botlish_fn_20+0x14c>
    17f0:	shr    rsi,0x3
    17f4:	shl    rsi,1
    17f7:	or     rsi,0x1
    17fb:	mov    rdi,r13
    17fe:	call   1803 <botlish_fn_20+0x133>
			17ff: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<int>
    1803:	cmp    rax,0x6
    1807:	je     1817 <botlish_fn_20+0x147>
    180d:	mov    ecx,0x2
    1812:	jmp    181c <botlish_fn_20+0x14c>
    1817:	mov    ecx,0x6
    181c:	cmp    rcx,0x6
    1820:	je     1830 <botlish_fn_20+0x160>
    1826:	mov    eax,0x2
    182b:	jmp    19c4 <botlish_fn_20+0x2f4>
    1830:	mov    QWORD PTR [rsp+0x10],0x3
    1839:	mov    rsi,r14
    183c:	test   rsi,0x1
    1843:	je     1869 <botlish_fn_20+0x199>
    1849:	mov    rsi,r14
    184c:	mov    rcx,rsi
    184f:	add    rcx,0x2
    1853:	seto   al
    1856:	test   al,al
    1858:	jne    1869 <botlish_fn_20+0x199>
    185e:	mov    rsi,rcx
    1861:	mov    r14,rcx
    1864:	jmp    187f <botlish_fn_20+0x1af>
    1869:	mov    edx,0x3
    186e:	mov    rsi,r14
    1871:	mov    rdi,r13
    1874:	call   1879 <botlish_fn_20+0x1a9>
			1875: R_X86_64_PLT32	rt_int_add-0x4
    1879:	mov    rsi,rax
    187c:	mov    r14,rax
    187f:	mov    QWORD PTR [rsp],rsi
    1883:	mov    QWORD PTR [rsp+0x8],r12
    1888:	jmp    16f9 <botlish_fn_20+0x29>
    188d:	mov    QWORD PTR [rsp+0x10],0x3
    1896:	mov    rsi,r14
    1899:	test   rsi,0x1
    18a0:	je     18b8 <botlish_fn_20+0x1e8>
    18a6:	mov    rsi,r14
    18a9:	add    rsi,0x2
    18ad:	seto   al
    18b0:	test   al,al
    18b2:	je     18cb <botlish_fn_20+0x1fb>
    18b8:	mov    edx,0x3
    18bd:	mov    rsi,r14
    18c0:	mov    rdi,r13
    18c3:	call   18c8 <botlish_fn_20+0x1f8>
			18c4: R_X86_64_PLT32	rt_int_add-0x4
    18c8:	mov    rsi,rax
    18cb:	mov    rdx,r12
    18ce:	mov    rdi,r13
    18d1:	call   18d6 <botlish_fn_20+0x206>
			18d2: R_X86_64_PLT32	botlish_fn_19-0x4 ; upper_hex?<int>
    18d6:	cmp    rax,0x6
    18da:	je     18ea <botlish_fn_20+0x21a>
    18e0:	mov    ecx,0x2
    18e5:	jmp    194e <botlish_fn_20+0x27e>
    18ea:	mov    QWORD PTR [rsp+0x10],0x5
    18f3:	mov    rsi,r14
    18f6:	test   rsi,0x1
    18fd:	je     1917 <botlish_fn_20+0x247>
    1903:	mov    rsi,r14
    1906:	add    rsi,0x4
    190a:	seto   r10b
    190e:	test   r10b,r10b
    1911:	je     192a <botlish_fn_20+0x25a>
    1917:	mov    edx,0x5
    191c:	mov    rsi,r14
    191f:	mov    rdi,r13
    1922:	call   1927 <botlish_fn_20+0x257>
			1923: R_X86_64_PLT32	rt_int_add-0x4
    1927:	mov    rsi,rax
    192a:	mov    rdx,r12
    192d:	mov    rdi,r13
    1930:	call   1935 <botlish_fn_20+0x265>
			1931: R_X86_64_PLT32	botlish_fn_19-0x4 ; upper_hex?<int>
    1935:	cmp    rax,0x6
    1939:	je     1949 <botlish_fn_20+0x279>
    193f:	mov    ecx,0x2
    1944:	jmp    194e <botlish_fn_20+0x27e>
    1949:	mov    ecx,0x6
    194e:	cmp    rcx,0x6
    1952:	je     1962 <botlish_fn_20+0x292>
    1958:	mov    eax,0x2
    195d:	jmp    19c4 <botlish_fn_20+0x2f4>
    1962:	mov    QWORD PTR [rsp+0x10],0x7
    196b:	mov    rsi,r14
    196e:	test   rsi,0x1
    1975:	je     199b <botlish_fn_20+0x2cb>
    197b:	mov    rsi,r14
    197e:	mov    rcx,rsi
    1981:	add    rcx,0x6
    1985:	seto   al
    1988:	test   al,al
    198a:	jne    199b <botlish_fn_20+0x2cb>
    1990:	mov    rsi,rcx
    1993:	mov    r14,rcx
    1996:	jmp    19b1 <botlish_fn_20+0x2e1>
    199b:	mov    edx,0x7
    19a0:	mov    rsi,r14
    19a3:	mov    rdi,r13
    19a6:	call   19ab <botlish_fn_20+0x2db>
			19a7: R_X86_64_PLT32	rt_int_add-0x4
    19ab:	mov    rsi,rax
    19ae:	mov    r14,rax
    19b1:	mov    QWORD PTR [rsp],rsi
    19b5:	mov    QWORD PTR [rsp+0x8],r12
    19ba:	jmp    16f9 <botlish_fn_20+0x29>
    19bf:	mov    eax,0x6
    19c4:	mov    r12,QWORD PTR [rsp+0x20]
    19c9:	mov    r13,QWORD PTR [rsp+0x28]
    19ce:	mov    r14,QWORD PTR [rsp+0x30]
    19d3:	add    rsp,0x40
    19d7:	mov    rsp,rbp
    19da:	pop    rbp
    19db:	ret
    19dc:	add    BYTE PTR [rax],al
    19de:	add    BYTE PTR [rax],al
    19e0:	(bad)
    19e1:	add    BYTE PTR [rax],al
    19e3:	add    BYTE PTR [rax],al
    19e5:	add    BYTE PTR [rax],al
	...

00000000000019e8 <botlish_entry_20: valid_from?<int>>:
    19e8:	push   rbp
    19e9:	mov    rbp,rsp
    19ec:	mov    rsi,QWORD PTR [rdx]
    19ef:	mov    rdx,QWORD PTR [rdx+0x8]
    19f3:	call   19f8 <botlish_entry_20+0x10>
			19f4: R_X86_64_PLT32	botlish_fn_20-0x4 ; valid_from?<int>
    19f8:	mov    rsp,rbp
    19fb:	pop    rbp
    19fc:	ret

00000000000019fd <botlish_fn_21: web::uri_escape_text<str>>:
    19fd:	push   rbp
    19fe:	mov    rbp,rsp
    1a01:	sub    rsp,0x10
    1a05:	mov    edx,0x1
    1a0a:	mov    QWORD PTR [rsp],0x1
    1a12:	mov    r10,QWORD PTR [rdi+0x10]
    1a16:	mov    rcx,QWORD PTR [r10+0xd0]
    1a1d:	mov    QWORD PTR [rsp+0x8],rcx
    1a22:	call   1a27 <botlish_fn_21+0x2a>
			1a23: R_X86_64_PLT32	botlish_fn_27-0x4 ; esc_from<str, int, str>
    1a27:	test   rax,rax
    1a2a:	jne    1a3c <botlish_fn_21+0x3f>
    1a30:	xor    rax,rax
    1a33:	add    rsp,0x10
    1a37:	mov    rsp,rbp
    1a3a:	pop    rbp
    1a3b:	ret
    1a3c:	add    rsp,0x10
    1a40:	mov    rsp,rbp
    1a43:	pop    rbp
    1a44:	ret

0000000000001a45 <botlish_entry_21: web::uri_escape_text<str>>:
    1a45:	push   rbp
    1a46:	mov    rbp,rsp
    1a49:	sub    rsp,0x10
    1a4d:	mov    QWORD PTR [rsp],r12
    1a51:	mov    r12,rdi
    1a54:	mov    rsi,QWORD PTR [rdx]
    1a57:	mov    r8,QWORD PTR [rip+0x0]        # 1a5e <botlish_entry_21+0x19>
			1a5a: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    1a5e:	call   r8
    1a61:	mov    rsi,rax
    1a64:	mov    rdi,r12
    1a67:	call   1a6c <botlish_entry_21+0x27>
			1a68: R_X86_64_PLT32	botlish_fn_21-0x4 ; web::uri_escape_text<str>
    1a6c:	mov    r12,QWORD PTR [rsp]
    1a70:	add    rsp,0x10
    1a74:	mov    rsp,rbp
    1a77:	pop    rbp
    1a78:	ret

0000000000001a79 <botlish_fn_22: high_nibble<int>>:
    1a79:	push   rbp
    1a7a:	mov    rbp,rsp
    1a7d:	sub    rsp,0x10
    1a81:	mov    QWORD PTR [rsp],rsi
    1a85:	mov    QWORD PTR [rsp+0x8],0x1e1
    1a8e:	test   rsi,0x1
    1a95:	jne    1aaa <botlish_fn_22+0x31>
    1a9b:	mov    edx,0x1e1
    1aa0:	call   1aa5 <botlish_fn_22+0x2c>
			1aa1: R_X86_64_PLT32	rt_int_and-0x4
    1aa5:	jmp    1ab4 <botlish_fn_22+0x3b>
    1aaa:	and    rsi,0x1e1
    1ab1:	mov    rax,rsi
    1ab4:	sar    rax,0x5
    1ab8:	shl    rax,1
    1abb:	or     rax,0x1
    1abf:	add    rsp,0x10
    1ac3:	mov    rsp,rbp
    1ac6:	pop    rbp
    1ac7:	ret

0000000000001ac8 <botlish_entry_22: high_nibble<int>>:
    1ac8:	push   rbp
    1ac9:	mov    rbp,rsp
    1acc:	mov    rsi,QWORD PTR [rdx]
    1acf:	call   1ad4 <botlish_entry_22+0xc>
			1ad0: R_X86_64_PLT32	botlish_fn_22-0x4 ; high_nibble<int>
    1ad4:	mov    rsp,rbp
    1ad7:	pop    rbp
    1ad8:	ret

0000000000001ad9 <botlish_fn_23: hex_pair<int>>:
    1ad9:	push   rbp
    1ada:	mov    rbp,rsp
    1add:	sub    rsp,0x50
    1ae1:	mov    QWORD PTR [rsp+0x30],rbx
    1ae6:	mov    QWORD PTR [rsp+0x38],r12
    1aeb:	mov    QWORD PTR [rsp+0x40],r13
    1af0:	mov    QWORD PTR [rsp+0x48],r14
    1af5:	mov    QWORD PTR [rsp],rsi
    1af9:	mov    r14,rsi
    1afc:	mov    rax,QWORD PTR [rdi+0x30]
    1b00:	mov    r13,rdi
    1b03:	mov    rbx,QWORD PTR [rax+0x8]
    1b07:	mov    QWORD PTR [rsp+0x8],rbx
    1b0c:	mov    rsi,r14
    1b0f:	call   1b14 <botlish_fn_23+0x3b>
			1b10: R_X86_64_PLT32	botlish_fn_22-0x4 ; high_nibble<int>
    1b14:	mov    rcx,QWORD PTR [rbx+0x10]
    1b18:	sar    rax,1
    1b1b:	mov    r12,QWORD PTR [rcx+rax*8]
    1b1f:	mov    QWORD PTR [rsp],r12
    1b23:	mov    rdi,r13
    1b26:	mov    rax,QWORD PTR [rdi+0x30]
    1b2a:	mov    rbx,QWORD PTR [rax+0x8]
    1b2e:	mov    edx,0x21
    1b33:	mov    rsi,r14
    1b36:	call   1b3b <botlish_fn_23+0x62>
			1b37: R_X86_64_PLT32	rt_int_mod-0x4
    1b3b:	test   rax,rax
    1b3e:	je     1b90 <botlish_fn_23+0xb7>
    1b44:	mov    rcx,QWORD PTR [rbx+0x10]
    1b48:	sar    rax,1
    1b4b:	mov    rdx,QWORD PTR [rcx+rax*8]
    1b4f:	mov    QWORD PTR [rsp+0x8],rdx
    1b54:	lea    rcx,[rsp+0x10]
    1b59:	mov    QWORD PTR [rsp+0x10],0x0
    1b62:	mov    QWORD PTR [rsp+0x18],r12
    1b67:	mov    QWORD PTR [rsp+0x20],0x0
    1b70:	mov    QWORD PTR [rsp+0x28],rdx
    1b75:	mov    esi,0x2
    1b7a:	mov    edx,0x4
    1b7f:	mov    rdi,r13
    1b82:	call   1b87 <botlish_fn_23+0xae>
			1b83: R_X86_64_PLT32	rt_construct-0x4
    1b87:	test   rax,rax
    1b8a:	jne    1bb0 <botlish_fn_23+0xd7>
    1b90:	xor    rax,rax
    1b93:	mov    rbx,QWORD PTR [rsp+0x30]
    1b98:	mov    r12,QWORD PTR [rsp+0x38]
    1b9d:	mov    r13,QWORD PTR [rsp+0x40]
    1ba2:	mov    r14,QWORD PTR [rsp+0x48]
    1ba7:	add    rsp,0x50
    1bab:	mov    rsp,rbp
    1bae:	pop    rbp
    1baf:	ret
    1bb0:	mov    rbx,QWORD PTR [rsp+0x30]
    1bb5:	mov    r12,QWORD PTR [rsp+0x38]
    1bba:	mov    r13,QWORD PTR [rsp+0x40]
    1bbf:	mov    r14,QWORD PTR [rsp+0x48]
    1bc4:	add    rsp,0x50
    1bc8:	mov    rsp,rbp
    1bcb:	pop    rbp
    1bcc:	ret

0000000000001bcd <botlish_entry_23: hex_pair<int>>:
    1bcd:	push   rbp
    1bce:	mov    rbp,rsp
    1bd1:	sub    rsp,0x10
    1bd5:	mov    QWORD PTR [rsp],r12
    1bd9:	mov    r12,rdi
    1bdc:	mov    rsi,QWORD PTR [rdx]
    1bdf:	call   1be4 <botlish_entry_23+0x17>
			1be0: R_X86_64_PLT32	botlish_fn_23-0x4 ; hex_pair<int>
    1be4:	mov    r8,QWORD PTR [rip+0x0]        # 1beb <botlish_entry_23+0x1e>
			1be7: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1beb:	mov    rsi,rax
    1bee:	mov    rdi,r12
    1bf1:	call   r8
    1bf4:	mov    r12,QWORD PTR [rsp]
    1bf8:	add    rsp,0x10
    1bfc:	mov    rsp,rbp
    1bff:	pop    rbp
    1c00:	ret

0000000000001c01 <botlish_fn_24: pct<int>>:
    1c01:	push   rbp
    1c02:	mov    rbp,rsp
    1c05:	sub    rsp,0x40
    1c09:	mov    QWORD PTR [rsp+0x30],r12
    1c0e:	mov    QWORD PTR [rsp+0x38],r13
    1c13:	mov    QWORD PTR [rsp],rsi
    1c17:	mov    rax,QWORD PTR [rdi+0x10]
    1c1b:	mov    r12,rdi
    1c1e:	mov    r13,QWORD PTR [rax+0x10]
    1c22:	mov    QWORD PTR [rsp+0x8],r13
    1c27:	call   1c2c <botlish_fn_24+0x2b>
			1c28: R_X86_64_PLT32	botlish_fn_23-0x4 ; hex_pair<int>
    1c2c:	test   rax,rax
    1c2f:	je     1c75 <botlish_fn_24+0x74>
    1c35:	mov    QWORD PTR [rsp],rax
    1c39:	lea    rcx,[rsp+0x10]
    1c3e:	mov    QWORD PTR [rsp+0x10],0x0
    1c47:	mov    QWORD PTR [rsp+0x18],r13
    1c4c:	mov    QWORD PTR [rsp+0x20],0x0
    1c55:	mov    QWORD PTR [rsp+0x28],rax
    1c5a:	mov    esi,0x2
    1c5f:	mov    edx,0x4
    1c64:	mov    rdi,r12
    1c67:	call   1c6c <botlish_fn_24+0x6b>
			1c68: R_X86_64_PLT32	rt_construct-0x4
    1c6c:	test   rax,rax
    1c6f:	jne    1c8b <botlish_fn_24+0x8a>
    1c75:	xor    rax,rax
    1c78:	mov    r12,QWORD PTR [rsp+0x30]
    1c7d:	mov    r13,QWORD PTR [rsp+0x38]
    1c82:	add    rsp,0x40
    1c86:	mov    rsp,rbp
    1c89:	pop    rbp
    1c8a:	ret
    1c8b:	mov    r12,QWORD PTR [rsp+0x30]
    1c90:	mov    r13,QWORD PTR [rsp+0x38]
    1c95:	add    rsp,0x40
    1c99:	mov    rsp,rbp
    1c9c:	pop    rbp
    1c9d:	ret

0000000000001c9e <botlish_entry_24: pct<int>>:
    1c9e:	push   rbp
    1c9f:	mov    rbp,rsp
    1ca2:	sub    rsp,0x10
    1ca6:	mov    QWORD PTR [rsp],r12
    1caa:	mov    r12,rdi
    1cad:	mov    rsi,QWORD PTR [rdx]
    1cb0:	call   1cb5 <botlish_entry_24+0x17>
			1cb1: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    1cb5:	mov    r8,QWORD PTR [rip+0x0]        # 1cbc <botlish_entry_24+0x1e>
			1cb8: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1cbc:	mov    rsi,rax
    1cbf:	mov    rdi,r12
    1cc2:	call   r8
    1cc5:	mov    r12,QWORD PTR [rsp]
    1cc9:	add    rsp,0x10
    1ccd:	mov    rsp,rbp
    1cd0:	pop    rbp
    1cd1:	ret

0000000000001cd2 <botlish_fn_25: cont<int, int>>:
    1cd2:	push   rbp
    1cd3:	mov    rbp,rsp
    1cd6:	sub    rsp,0x30
    1cda:	mov    QWORD PTR [rsp+0x20],rbx
    1cdf:	mov    rbx,rdi
    1ce2:	mov    QWORD PTR [rsp],rsi
    1ce6:	mov    QWORD PTR [rsp+0x8],rdx
    1ceb:	mov    QWORD PTR [rsp+0x10],0x101
    1cf4:	mov    rdi,rbx
    1cf7:	call   1cfc <botlish_fn_25+0x2a>
			1cf8: R_X86_64_PLT32	rt_int_shr-0x4
    1cfc:	test   rax,rax
    1cff:	je     1d82 <botlish_fn_25+0xb0>
    1d05:	mov    QWORD PTR [rsp],rax
    1d09:	mov    QWORD PTR [rsp+0x8],0x7f
    1d12:	test   rax,0x1
    1d18:	mov    rsi,rax
    1d1b:	jne    1d36 <botlish_fn_25+0x64>
    1d21:	mov    edx,0x7f
    1d26:	mov    rdi,rbx
    1d29:	call   1d2e <botlish_fn_25+0x5c>
			1d2a: R_X86_64_PLT32	rt_int_and-0x4
    1d2e:	mov    rdx,rax
    1d31:	jmp    1d3d <botlish_fn_25+0x6b>
    1d36:	mov    rdx,rsi
    1d39:	and    rdx,0x7f
    1d3d:	mov    QWORD PTR [rsp],rdx
    1d41:	test   rdx,0x1
    1d48:	jne    1d63 <botlish_fn_25+0x91>
    1d4e:	mov    esi,0x101
    1d53:	mov    rdi,rbx
    1d56:	call   1d5b <botlish_fn_25+0x89>
			1d57: R_X86_64_PLT32	rt_int_or-0x4
    1d5b:	mov    rsi,rax
    1d5e:	jmp    1d6d <botlish_fn_25+0x9b>
    1d63:	or     rdx,0x101
    1d6a:	mov    rsi,rdx
    1d6d:	mov    QWORD PTR [rsp],rsi
    1d71:	mov    rdi,rbx
    1d74:	call   1d79 <botlish_fn_25+0xa7>
			1d75: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    1d79:	test   rax,rax
    1d7c:	jne    1d93 <botlish_fn_25+0xc1>
    1d82:	xor    rax,rax
    1d85:	mov    rbx,QWORD PTR [rsp+0x20]
    1d8a:	add    rsp,0x30
    1d8e:	mov    rsp,rbp
    1d91:	pop    rbp
    1d92:	ret
    1d93:	mov    rbx,QWORD PTR [rsp+0x20]
    1d98:	add    rsp,0x30
    1d9c:	mov    rsp,rbp
    1d9f:	pop    rbp
    1da0:	ret

0000000000001da1 <botlish_entry_25: cont<int, int>>:
    1da1:	push   rbp
    1da2:	mov    rbp,rsp
    1da5:	sub    rsp,0x10
    1da9:	mov    QWORD PTR [rsp],r12
    1dad:	mov    r12,rdi
    1db0:	mov    rsi,QWORD PTR [rdx]
    1db3:	mov    rdx,QWORD PTR [rdx+0x8]
    1db7:	call   1dbc <botlish_entry_25+0x1b>
			1db8: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    1dbc:	mov    r8,QWORD PTR [rip+0x0]        # 1dc3 <botlish_entry_25+0x22>
			1dbf: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1dc3:	mov    rsi,rax
    1dc6:	mov    rdi,r12
    1dc9:	call   r8
    1dcc:	mov    r12,QWORD PTR [rsp]
    1dd0:	add    rsp,0x10
    1dd4:	mov    rsp,rbp
    1dd7:	pop    rbp
    1dd8:	ret
    1dd9:	add    BYTE PTR [rax],al
    1ddb:	add    BYTE PTR [rax],al
    1ddd:	add    BYTE PTR [rax],al
	...

0000000000001de0 <botlish_fn_26: esc_scalar<int>>:
    1de0:	push   rbp
    1de1:	mov    rbp,rsp
    1de4:	sub    rsp,0xf0
    1deb:	mov    QWORD PTR [rsp+0xc0],rbx
    1df3:	mov    QWORD PTR [rsp+0xc8],r12
    1dfb:	mov    QWORD PTR [rsp+0xd0],r13
    1e03:	mov    QWORD PTR [rsp+0xd8],r14
    1e0b:	mov    QWORD PTR [rsp+0xe0],r15
    1e13:	mov    rbx,rdi
    1e16:	mov    QWORD PTR [rsp+0x18],0x0
    1e1f:	mov    QWORD PTR [rsp+0x20],0x0
    1e28:	mov    QWORD PTR [rsp],rsi
    1e2c:	test   rsi,0x1
    1e33:	mov    r12,rsi
    1e36:	jne    1e62 <botlish_fn_26+0x82>
    1e3c:	mov    edx,0x1001
    1e41:	mov    rsi,r12
    1e44:	mov    rdi,rbx
    1e47:	call   1e4c <botlish_fn_26+0x6c>
			1e48: R_X86_64_PLT32	rt_int_cmp-0x4
    1e4c:	mov    r11d,0x2
    1e52:	test   rax,rax
    1e55:	cmovl  r11,QWORD PTR [rip+0x3fb]        # 2258 <botlish_fn_26+0x478>
    1e5d:	jmp    1e7a <botlish_fn_26+0x9a>
    1e62:	mov    r11d,0x2
    1e68:	mov    rsi,r12
    1e6b:	cmp    rsi,0x1001
    1e72:	cmovl  r11,QWORD PTR [rip+0x3de]        # 2258 <botlish_fn_26+0x478>
    1e7a:	mov    edx,0x6
    1e7f:	mov    r13,rdx
    1e82:	cmp    r11,0x6
    1e86:	je     2140 <botlish_fn_26+0x360>
    1e8c:	mov    rsi,r12
    1e8f:	test   rsi,0x1
    1e96:	jne    1ec1 <botlish_fn_26+0xe1>
    1e9c:	mov    edx,0x20001
    1ea1:	mov    rsi,r12
    1ea4:	mov    rdi,rbx
    1ea7:	call   1eac <botlish_fn_26+0xcc>
			1ea8: R_X86_64_PLT32	rt_int_cmp-0x4
    1eac:	mov    ecx,0x2
    1eb1:	test   rax,rax
    1eb4:	cmovl  rcx,QWORD PTR [rip+0x39c]        # 2258 <botlish_fn_26+0x478>
    1ebc:	jmp    1ed8 <botlish_fn_26+0xf8>
    1ec1:	mov    ecx,0x2
    1ec6:	mov    rsi,r12
    1ec9:	cmp    rsi,0x20001
    1ed0:	cmovl  rcx,QWORD PTR [rip+0x380]        # 2258 <botlish_fn_26+0x478>
    1ed8:	cmp    rcx,0x6
    1edc:	je     2053 <botlish_fn_26+0x273>
    1ee2:	mov    QWORD PTR [rsp+0x8],0x1e1
    1eeb:	mov    edx,0x25
    1ef0:	mov    QWORD PTR [rsp+0x10],0x25
    1ef9:	mov    rsi,r12
    1efc:	mov    rdi,rbx
    1eff:	call   1f04 <botlish_fn_26+0x124>
			1f00: R_X86_64_PLT32	rt_int_shr-0x4
    1f04:	test   rax,rax
    1f07:	je     21e9 <botlish_fn_26+0x409>
    1f0d:	mov    QWORD PTR [rsp+0x10],rax
    1f12:	test   rax,0x1
    1f18:	mov    rdx,rax
    1f1b:	jne    1f36 <botlish_fn_26+0x156>
    1f21:	mov    esi,0x1e1
    1f26:	mov    rdi,rbx
    1f29:	call   1f2e <botlish_fn_26+0x14e>
			1f2a: R_X86_64_PLT32	rt_int_or-0x4
    1f2e:	mov    rsi,rax
    1f31:	jmp    1f40 <botlish_fn_26+0x160>
    1f36:	mov    rsi,rdx
    1f39:	or     rsi,0x1e1
    1f40:	mov    QWORD PTR [rsp+0x8],rsi
    1f45:	mov    rdi,rbx
    1f48:	call   1f4d <botlish_fn_26+0x16d>
			1f49: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    1f4d:	test   rax,rax
    1f50:	je     21e9 <botlish_fn_26+0x409>
    1f56:	mov    QWORD PTR [rsp+0x8],rax
    1f5b:	mov    r13,rax
    1f5e:	mov    edx,0x19
    1f63:	mov    QWORD PTR [rsp+0x10],0x19
    1f6c:	mov    rsi,r12
    1f6f:	mov    rdi,rbx
    1f72:	call   1f77 <botlish_fn_26+0x197>
			1f73: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    1f77:	test   rax,rax
    1f7a:	je     21e9 <botlish_fn_26+0x409>
    1f80:	mov    QWORD PTR [rsp+0x10],rax
    1f85:	mov    r14,rax
    1f88:	mov    edx,0xd
    1f8d:	mov    QWORD PTR [rsp+0x18],0xd
    1f96:	mov    rsi,r12
    1f99:	mov    rdi,rbx
    1f9c:	call   1fa1 <botlish_fn_26+0x1c1>
			1f9d: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    1fa1:	test   rax,rax
    1fa4:	je     21e9 <botlish_fn_26+0x409>
    1faa:	mov    QWORD PTR [rsp+0x18],rax
    1faf:	mov    r15,rax
    1fb2:	mov    edx,0x1
    1fb7:	mov    QWORD PTR [rsp+0x20],0x1
    1fc0:	mov    rsi,r12
    1fc3:	mov    rdi,rbx
    1fc6:	call   1fcb <botlish_fn_26+0x1eb>
			1fc7: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    1fcb:	test   rax,rax
    1fce:	je     21e9 <botlish_fn_26+0x409>
    1fd4:	mov    QWORD PTR [rsp],rax
    1fd8:	lea    rcx,[rsp+0x78]
    1fdd:	mov    QWORD PTR [rsp+0x78],0x0
    1fe6:	mov    rdx,r13
    1fe9:	mov    QWORD PTR [rsp+0x80],rdx
    1ff1:	mov    QWORD PTR [rsp+0x88],0x0
    1ffd:	mov    rdx,r14
    2000:	mov    QWORD PTR [rsp+0x90],rdx
    2008:	mov    QWORD PTR [rsp+0x98],0x0
    2014:	mov    rdx,r15
    2017:	mov    QWORD PTR [rsp+0xa0],rdx
    201f:	mov    QWORD PTR [rsp+0xa8],0x0
    202b:	mov    QWORD PTR [rsp+0xb0],rax
    2033:	mov    esi,0x2
    2038:	mov    edx,0x8
    203d:	mov    rdi,rbx
    2040:	call   2045 <botlish_fn_26+0x265>
			2041: R_X86_64_PLT32	rt_construct-0x4
    2045:	test   rax,rax
    2048:	je     21e9 <botlish_fn_26+0x409>
    204e:	jmp    2220 <botlish_fn_26+0x440>
    2053:	mov    QWORD PTR [rsp+0x8],0x1c1
    205c:	mov    edx,0xd
    2061:	mov    rsi,r12
    2064:	mov    r14,rdx
    2067:	sar    rsi,0xd
    206b:	shl    rsi,1
    206e:	mov    rax,rsi
    2071:	or     rax,0x1
    2075:	mov    QWORD PTR [rsp+0x10],rax
    207a:	or     rsi,0x1c1
    2081:	mov    QWORD PTR [rsp+0x8],rsi
    2086:	mov    rdi,rbx
    2089:	call   208e <botlish_fn_26+0x2ae>
			208a: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    208e:	test   rax,rax
    2091:	je     21e9 <botlish_fn_26+0x409>
    2097:	mov    QWORD PTR [rsp+0x8],rax
    209c:	mov    r15,rax
    209f:	mov    QWORD PTR [rsp+0x10],0xd
    20a8:	mov    rdx,r14
    20ab:	mov    rsi,r12
    20ae:	mov    rdi,rbx
    20b1:	call   20b6 <botlish_fn_26+0x2d6>
			20b2: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    20b6:	test   rax,rax
    20b9:	je     21e9 <botlish_fn_26+0x409>
    20bf:	mov    QWORD PTR [rsp+0x10],rax
    20c4:	mov    r14,rax
    20c7:	mov    edx,0x1
    20cc:	mov    QWORD PTR [rsp+0x18],0x1
    20d5:	mov    rsi,r12
    20d8:	mov    rdi,rbx
    20db:	call   20e0 <botlish_fn_26+0x300>
			20dc: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    20e0:	test   rax,rax
    20e3:	je     21e9 <botlish_fn_26+0x409>
    20e9:	mov    QWORD PTR [rsp],rax
    20ed:	lea    rcx,[rsp+0x48]
    20f2:	mov    QWORD PTR [rsp+0x48],0x0
    20fb:	mov    rdx,r15
    20fe:	mov    QWORD PTR [rsp+0x50],rdx
    2103:	mov    QWORD PTR [rsp+0x58],0x0
    210c:	mov    rdx,r14
    210f:	mov    QWORD PTR [rsp+0x60],rdx
    2114:	mov    QWORD PTR [rsp+0x68],0x0
    211d:	mov    QWORD PTR [rsp+0x70],rax
    2122:	mov    esi,0x2
    2127:	mov    rdx,r13
    212a:	mov    rdi,rbx
    212d:	call   2132 <botlish_fn_26+0x352>
			212e: R_X86_64_PLT32	rt_construct-0x4
    2132:	test   rax,rax
    2135:	je     21e9 <botlish_fn_26+0x409>
    213b:	jmp    2220 <botlish_fn_26+0x440>
    2140:	mov    QWORD PTR [rsp+0x8],0x181
    2149:	mov    rsi,r12
    214c:	sar    rsi,0x7
    2150:	shl    rsi,1
    2153:	mov    rax,rsi
    2156:	or     rax,0x1
    215a:	mov    QWORD PTR [rsp+0x10],rax
    215f:	or     rsi,0x181
    2166:	mov    QWORD PTR [rsp+0x8],rsi
    216b:	mov    rdi,rbx
    216e:	call   2173 <botlish_fn_26+0x393>
			216f: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    2173:	test   rax,rax
    2176:	je     21e9 <botlish_fn_26+0x409>
    217c:	mov    QWORD PTR [rsp+0x8],rax
    2181:	mov    r13,rax
    2184:	mov    edx,0x1
    2189:	mov    QWORD PTR [rsp+0x10],0x1
    2192:	mov    rsi,r12
    2195:	mov    rdi,rbx
    2198:	call   219d <botlish_fn_26+0x3bd>
			2199: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    219d:	test   rax,rax
    21a0:	je     21e9 <botlish_fn_26+0x409>
    21a6:	mov    QWORD PTR [rsp],rax
    21aa:	lea    rcx,[rsp+0x28]
    21af:	mov    QWORD PTR [rsp+0x28],0x0
    21b8:	mov    rdx,r13
    21bb:	mov    QWORD PTR [rsp+0x30],rdx
    21c0:	mov    QWORD PTR [rsp+0x38],0x0
    21c9:	mov    QWORD PTR [rsp+0x40],rax
    21ce:	mov    esi,0x2
    21d3:	mov    edx,0x4
    21d8:	mov    rdi,rbx
    21db:	call   21e0 <botlish_fn_26+0x400>
			21dc: R_X86_64_PLT32	rt_construct-0x4
    21e0:	test   rax,rax
    21e3:	jne    2220 <botlish_fn_26+0x440>
    21e9:	xor    rax,rax
    21ec:	mov    rbx,QWORD PTR [rsp+0xc0]
    21f4:	mov    r12,QWORD PTR [rsp+0xc8]
    21fc:	mov    r13,QWORD PTR [rsp+0xd0]
    2204:	mov    r14,QWORD PTR [rsp+0xd8]
    220c:	mov    r15,QWORD PTR [rsp+0xe0]
    2214:	add    rsp,0xf0
    221b:	mov    rsp,rbp
    221e:	pop    rbp
    221f:	ret
    2220:	mov    rbx,QWORD PTR [rsp+0xc0]
    2228:	mov    r12,QWORD PTR [rsp+0xc8]
    2230:	mov    r13,QWORD PTR [rsp+0xd0]
    2238:	mov    r14,QWORD PTR [rsp+0xd8]
    2240:	mov    r15,QWORD PTR [rsp+0xe0]
    2248:	add    rsp,0xf0
    224f:	mov    rsp,rbp
    2252:	pop    rbp
    2253:	ret
    2254:	add    BYTE PTR [rax],al
    2256:	add    BYTE PTR [rax],al
    2258:	(bad)
    2259:	add    BYTE PTR [rax],al
    225b:	add    BYTE PTR [rax],al
    225d:	add    BYTE PTR [rax],al
	...

0000000000002260 <botlish_entry_26: esc_scalar<int>>:
    2260:	push   rbp
    2261:	mov    rbp,rsp
    2264:	sub    rsp,0x10
    2268:	mov    QWORD PTR [rsp],r12
    226c:	mov    r12,rdi
    226f:	mov    rsi,QWORD PTR [rdx]
    2272:	call   2277 <botlish_entry_26+0x17>
			2273: R_X86_64_PLT32	botlish_fn_26-0x4 ; esc_scalar<int>
    2277:	mov    r8,QWORD PTR [rip+0x0]        # 227e <botlish_entry_26+0x1e>
			227a: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    227e:	mov    rsi,rax
    2281:	mov    rdi,r12
    2284:	call   r8
    2287:	mov    r12,QWORD PTR [rsp]
    228b:	add    rsp,0x10
    228f:	mov    rsp,rbp
    2292:	pop    rbp
    2293:	ret
    2294:	add    BYTE PTR [rax],al
	...

0000000000002298 <botlish_fn_27: esc_from<str, int, str>>:
    2298:	push   rbp
    2299:	mov    rbp,rsp
    229c:	sub    rsp,0x110
    22a3:	mov    QWORD PTR [rsp+0xe0],rbx
    22ab:	mov    QWORD PTR [rsp+0xe8],r12
    22b3:	mov    QWORD PTR [rsp+0xf0],r13
    22bb:	mov    QWORD PTR [rsp+0xf8],r14
    22c3:	mov    QWORD PTR [rsp+0x100],r15
    22cb:	mov    QWORD PTR [rsp+0xa8],rdi
    22d3:	mov    QWORD PTR [rsp+0x10],0x0
    22dc:	mov    QWORD PTR [rsp+0x18],0x0
    22e5:	mov    QWORD PTR [rsp+0x20],0x0
    22ee:	mov    QWORD PTR [rsp],rdx
    22f2:	mov    QWORD PTR [rsp+0x8],rcx
    22f7:	mov    r15,rcx
    22fa:	mov    r14d,0x47
    2300:	mov    rcx,0xffffffffffffffff
    2307:	bsr    rax,rsi
    230b:	mov    QWORD PTR [rsp+0xb0],rsi
    2313:	cmove  rax,rcx
    2317:	mov    ecx,0x3f
    231c:	sub    rcx,rax
    231f:	sub    r14,rcx
    2322:	shr    r14,0x3
    2326:	shl    r14,1
    2329:	lea    rbx,[rsp+0x88]
    2331:	lea    r12,[rsp+0x58]
    2336:	lea    r13,[rsp+0x38]
    233b:	mov    rsi,rdx
    233e:	mov    rax,r14
    2341:	or     rax,0x1
    2345:	mov    rcx,rsi
    2348:	and    rcx,rax
    234b:	mov    QWORD PTR [rsp+0xb8],rsi
    2353:	test   rcx,0x1
    235a:	jne    2391 <botlish_fn_27+0xf9>
    2360:	mov    rdx,r14
    2363:	or     rdx,0x1
    2367:	mov    rsi,QWORD PTR [rsp+0xb8]
    236f:	mov    rdi,QWORD PTR [rsp+0xa8]
    2377:	call   237c <botlish_fn_27+0xe4>
			2378: R_X86_64_PLT32	rt_int_cmp-0x4
    237c:	mov    ecx,0x2
    2381:	test   rax,rax
    2384:	cmovge rcx,QWORD PTR [rip+0x4c4]        # 2850 <botlish_fn_27+0x5b8>
    238c:	jmp    23b0 <botlish_fn_27+0x118>
    2391:	mov    rax,r14
    2394:	or     rax,0x1
    2398:	mov    ecx,0x2
    239d:	mov    rsi,QWORD PTR [rsp+0xb8]
    23a5:	cmp    rsi,rax
    23a8:	cmovge rcx,QWORD PTR [rip+0x4a0]        # 2850 <botlish_fn_27+0x5b8>
    23b0:	cmp    rcx,0x6
    23b4:	je     23c4 <botlish_fn_27+0x12c>
    23ba:	mov    eax,0x2
    23bf:	jmp    23c9 <botlish_fn_27+0x131>
    23c4:	mov    eax,0x6
    23c9:	cmp    rax,0x6
    23cd:	je     27b3 <botlish_fn_27+0x51b>
    23d3:	mov    rsi,QWORD PTR [rsp+0xb0]
    23db:	mov    rdi,QWORD PTR [rsp+0xa8]
    23e3:	call   23e8 <botlish_fn_27+0x150>
			23e4: R_X86_64_PLT32	rt_ascii_to_str-0x4
    23e8:	mov    QWORD PTR [rsp+0xd0],rax
    23f0:	mov    QWORD PTR [rsp+0x10],rax
    23f5:	movzx  rcx,BYTE PTR [rax+0x18]
    23fa:	test   rcx,rcx
    23fd:	jne    2428 <botlish_fn_27+0x190>
    2403:	mov    rdx,QWORD PTR [rsp+0xb8]
    240b:	mov    rsi,QWORD PTR [rsp+0xd0]
    2413:	mov    rdi,QWORD PTR [rsp+0xa8]
    241b:	call   2420 <botlish_fn_27+0x188>
			241c: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    2420:	mov    rsi,rax
    2423:	jmp    244c <botlish_fn_27+0x1b4>
    2428:	mov    rsi,QWORD PTR [rsp+0xb8]
    2430:	mov    rcx,rsi
    2433:	sar    rcx,1
    2436:	mov    rax,QWORD PTR [rsp+0xd0]
    243e:	movzx  rsi,BYTE PTR [rax+rcx*1+0x19]
    2444:	shl    rsi,0x3
    2448:	or     rsi,0x4
    244c:	shr    rsi,0x3
    2450:	shl    rsi,1
    2453:	or     rsi,0x1
    2457:	mov    QWORD PTR [rsp+0x10],rsi
    245c:	mov    edi,0x2
    2461:	cmp    rsi,0xff
    2468:	mov    QWORD PTR [rsp+0xc8],rsi
    2470:	cmovg  rdi,QWORD PTR [rip+0x3d8]        # 2850 <botlish_fn_27+0x5b8>
    2478:	cmp    rdi,0x6
    247c:	je     26c7 <botlish_fn_27+0x42f>
    2482:	mov    rsi,QWORD PTR [rsp+0xc8]
    248a:	mov    rdi,QWORD PTR [rsp+0xa8]
    2492:	call   2497 <botlish_fn_27+0x1ff>
			2493: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<int>
    2497:	cmp    rax,0x6
    249b:	je     2599 <botlish_fn_27+0x301>
    24a1:	mov    QWORD PTR [rsp+0x18],0x3
    24aa:	mov    rsi,QWORD PTR [rsp+0xb8]
    24b2:	test   rsi,0x1
    24b9:	je     24e9 <botlish_fn_27+0x251>
    24bf:	mov    rsi,QWORD PTR [rsp+0xb8]
    24c7:	mov    rax,rsi
    24ca:	add    rax,0x2
    24ce:	seto   cl
    24d1:	test   cl,cl
    24d3:	jne    24e9 <botlish_fn_27+0x251>
    24d9:	mov    rsi,rax
    24dc:	mov    QWORD PTR [rsp+0xb8],rax
    24e4:	jmp    250e <botlish_fn_27+0x276>
    24e9:	mov    edx,0x3
    24ee:	mov    rsi,QWORD PTR [rsp+0xb8]
    24f6:	mov    rdi,QWORD PTR [rsp+0xa8]
    24fe:	call   2503 <botlish_fn_27+0x26b>
			24ff: R_X86_64_PLT32	rt_int_add-0x4
    2503:	mov    rsi,rax
    2506:	mov    QWORD PTR [rsp+0xb8],rax
    250e:	mov    QWORD PTR [rsp],rsi
    2512:	mov    rsi,QWORD PTR [rsp+0xc8]
    251a:	mov    rdi,QWORD PTR [rsp+0xa8]
    2522:	call   2527 <botlish_fn_27+0x28f>
			2523: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    2527:	test   rax,rax
    252a:	je     27e4 <botlish_fn_27+0x54c>
    2530:	mov    QWORD PTR [rsp+0x10],rax
    2535:	mov    QWORD PTR [rsp+0x88],0x0
    2541:	mov    QWORD PTR [rsp+0x90],r15
    2549:	mov    QWORD PTR [rsp+0x98],0x0
    2555:	mov    QWORD PTR [rsp+0xa0],rax
    255d:	mov    esi,0x2
    2562:	mov    edx,0x4
    2567:	mov    rcx,rbx
    256a:	mov    rdi,QWORD PTR [rsp+0xa8]
    2572:	call   2577 <botlish_fn_27+0x2df>
			2573: R_X86_64_PLT32	rt_construct-0x4
    2577:	test   rax,rax
    257a:	je     27e4 <botlish_fn_27+0x54c>
    2580:	mov    rsi,QWORD PTR [rsp+0xb8]
    2588:	mov    QWORD PTR [rsp],rsi
    258c:	mov    QWORD PTR [rsp+0x8],rax
    2591:	mov    r15,rax
    2594:	jmp    233e <botlish_fn_27+0xa6>
    2599:	mov    QWORD PTR [rsp+0x18],0x3
    25a2:	mov    rsi,QWORD PTR [rsp+0xb8]
    25aa:	test   rsi,0x1
    25b1:	je     25d1 <botlish_fn_27+0x339>
    25b7:	mov    rsi,QWORD PTR [rsp+0xb8]
    25bf:	mov    rax,rsi
    25c2:	add    rax,0x2
    25c6:	seto   cl
    25c9:	test   cl,cl
    25cb:	je     25eb <botlish_fn_27+0x353>
    25d1:	mov    edx,0x3
    25d6:	mov    rsi,QWORD PTR [rsp+0xb8]
    25de:	mov    rdi,QWORD PTR [rsp+0xa8]
    25e6:	call   25eb <botlish_fn_27+0x353>
			25e7: R_X86_64_PLT32	rt_int_add-0x4
    25eb:	mov    QWORD PTR [rsp+0x18],rax
    25f0:	mov    QWORD PTR [rsp+0xc0],rax
    25f8:	mov    QWORD PTR [rsp+0x20],0x3
    2601:	mov    rsi,QWORD PTR [rsp+0xb8]
    2609:	test   rsi,0x1
    2610:	je     2630 <botlish_fn_27+0x398>
    2616:	mov    rsi,QWORD PTR [rsp+0xb8]
    261e:	mov    rax,rsi
    2621:	add    rax,0x2
    2625:	seto   cl
    2628:	test   cl,cl
    262a:	je     264a <botlish_fn_27+0x3b2>
    2630:	mov    edx,0x3
    2635:	mov    rsi,QWORD PTR [rsp+0xb8]
    263d:	mov    rdi,QWORD PTR [rsp+0xa8]
    2645:	call   264a <botlish_fn_27+0x3b2>
			2646: R_X86_64_PLT32	rt_int_add-0x4
    264a:	mov    QWORD PTR [rsp+0x20],rax
    264f:	mov    QWORD PTR [rsp+0x58],0x0
    2658:	mov    QWORD PTR [rsp+0x60],r15
    265d:	mov    QWORD PTR [rsp+0x68],0x1
    2666:	mov    rcx,QWORD PTR [rsp+0xd0]
    266e:	mov    QWORD PTR [rsp+0x70],rcx
    2673:	mov    rsi,QWORD PTR [rsp+0xb8]
    267b:	mov    QWORD PTR [rsp+0x78],rsi
    2680:	mov    QWORD PTR [rsp+0x80],rax
    2688:	mov    esi,0x2
    268d:	mov    edx,0x6
    2692:	mov    rcx,r12
    2695:	mov    rdi,QWORD PTR [rsp+0xa8]
    269d:	call   26a2 <botlish_fn_27+0x40a>
			269e: R_X86_64_PLT32	rt_construct-0x4
    26a2:	test   rax,rax
    26a5:	je     27e4 <botlish_fn_27+0x54c>
    26ab:	mov    rdi,QWORD PTR [rsp+0xc0]
    26b3:	mov    QWORD PTR [rsp],rdi
    26b7:	mov    QWORD PTR [rsp+0x8],rax
    26bc:	mov    rsi,rdi
    26bf:	mov    r15,rax
    26c2:	jmp    233e <botlish_fn_27+0xa6>
    26c7:	mov    QWORD PTR [rsp+0x18],0x3
    26d0:	mov    rsi,QWORD PTR [rsp+0xb8]
    26d8:	test   rsi,0x1
    26df:	je     270f <botlish_fn_27+0x477>
    26e5:	mov    rsi,QWORD PTR [rsp+0xb8]
    26ed:	mov    rax,rsi
    26f0:	add    rax,0x2
    26f4:	seto   cl
    26f7:	test   cl,cl
    26f9:	jne    270f <botlish_fn_27+0x477>
    26ff:	mov    rsi,rax
    2702:	mov    QWORD PTR [rsp+0xb8],rax
    270a:	jmp    2734 <botlish_fn_27+0x49c>
    270f:	mov    edx,0x3
    2714:	mov    rsi,QWORD PTR [rsp+0xb8]
    271c:	mov    rdi,QWORD PTR [rsp+0xa8]
    2724:	call   2729 <botlish_fn_27+0x491>
			2725: R_X86_64_PLT32	rt_int_add-0x4
    2729:	mov    rsi,rax
    272c:	mov    QWORD PTR [rsp+0xb8],rax
    2734:	mov    QWORD PTR [rsp],rsi
    2738:	mov    rsi,QWORD PTR [rsp+0xc8]
    2740:	mov    rdi,QWORD PTR [rsp+0xa8]
    2748:	call   274d <botlish_fn_27+0x4b5>
			2749: R_X86_64_PLT32	botlish_fn_26-0x4 ; esc_scalar<int>
    274d:	test   rax,rax
    2750:	je     27e4 <botlish_fn_27+0x54c>
    2756:	mov    QWORD PTR [rsp+0x10],rax
    275b:	mov    QWORD PTR [rsp+0x38],0x0
    2764:	mov    QWORD PTR [rsp+0x40],r15
    2769:	mov    QWORD PTR [rsp+0x48],0x0
    2772:	mov    QWORD PTR [rsp+0x50],rax
    2777:	mov    esi,0x2
    277c:	mov    edx,0x4
    2781:	mov    rcx,r13
    2784:	mov    rdi,QWORD PTR [rsp+0xa8]
    278c:	call   2791 <botlish_fn_27+0x4f9>
			278d: R_X86_64_PLT32	rt_construct-0x4
    2791:	test   rax,rax
    2794:	je     27e4 <botlish_fn_27+0x54c>
    279a:	mov    rsi,QWORD PTR [rsp+0xb8]
    27a2:	mov    QWORD PTR [rsp],rsi
    27a6:	mov    QWORD PTR [rsp+0x8],rax
    27ab:	mov    r15,rax
    27ae:	jmp    233e <botlish_fn_27+0xa6>
    27b3:	xor    rsi,rsi
    27b6:	lea    rcx,[rsp+0x28]
    27bb:	mov    QWORD PTR [rsp+0x28],0x0
    27c4:	mov    QWORD PTR [rsp+0x30],r15
    27c9:	mov    edx,0x2
    27ce:	mov    rdi,QWORD PTR [rsp+0xa8]
    27d6:	call   27db <botlish_fn_27+0x543>
			27d7: R_X86_64_PLT32	rt_construct-0x4
    27db:	test   rax,rax
    27de:	jne    281b <botlish_fn_27+0x583>
    27e4:	xor    rax,rax
    27e7:	mov    rbx,QWORD PTR [rsp+0xe0]
    27ef:	mov    r12,QWORD PTR [rsp+0xe8]
    27f7:	mov    r13,QWORD PTR [rsp+0xf0]
    27ff:	mov    r14,QWORD PTR [rsp+0xf8]
    2807:	mov    r15,QWORD PTR [rsp+0x100]
    280f:	add    rsp,0x110
    2816:	mov    rsp,rbp
    2819:	pop    rbp
    281a:	ret
    281b:	mov    rbx,QWORD PTR [rsp+0xe0]
    2823:	mov    r12,QWORD PTR [rsp+0xe8]
    282b:	mov    r13,QWORD PTR [rsp+0xf0]
    2833:	mov    r14,QWORD PTR [rsp+0xf8]
    283b:	mov    r15,QWORD PTR [rsp+0x100]
    2843:	add    rsp,0x110
    284a:	mov    rsp,rbp
    284d:	pop    rbp
    284e:	ret
    284f:	add    BYTE PTR [rsi],al
    2851:	add    BYTE PTR [rax],al
    2853:	add    BYTE PTR [rax],al
    2855:	add    BYTE PTR [rax],al
	...

0000000000002858 <botlish_entry_27: esc_from<str, int, str>>:
    2858:	push   rbp
    2859:	mov    rbp,rsp
    285c:	sub    rsp,0x10
    2860:	mov    QWORD PTR [rsp],r12
    2864:	mov    QWORD PTR [rsp+0x8],r13
    2869:	mov    r12,rdi
    286c:	mov    rsi,QWORD PTR [rdx]
    286f:	mov    r13,rdx
    2872:	mov    r8,QWORD PTR [rip+0x0]        # 2879 <botlish_entry_27+0x21>
			2875: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    2879:	call   r8
    287c:	mov    rcx,r13
    287f:	mov    rdx,QWORD PTR [rcx+0x8]
    2883:	mov    rcx,QWORD PTR [rcx+0x10]
    2887:	mov    rsi,rax
    288a:	mov    rdi,r12
    288d:	call   2892 <botlish_entry_27+0x3a>
			288e: R_X86_64_PLT32	botlish_fn_27-0x4 ; esc_from<str, int, str>
    2892:	mov    r12,QWORD PTR [rsp]
    2896:	mov    r13,QWORD PTR [rsp+0x8]
    289b:	add    rsp,0x10
    289f:	mov    rsp,rbp
    28a2:	pop    rbp
    28a3:	ret

00000000000028a4 <botlish_fn_28: check<int, int, str, str>>:
    28a4:	push   rbp
    28a5:	mov    rbp,rsp
    28a8:	sub    rsp,0x50
    28ac:	mov    QWORD PTR [rsp+0x20],rbx
    28b1:	mov    QWORD PTR [rsp+0x28],r12
    28b6:	mov    QWORD PTR [rsp+0x30],r13
    28bb:	mov    QWORD PTR [rsp+0x38],r14
    28c0:	mov    QWORD PTR [rsp+0x40],r15
    28c5:	mov    r14,rdi
    28c8:	mov    QWORD PTR [rsp+0x18],0x0
    28d1:	mov    QWORD PTR [rsp],rdx
    28d5:	mov    QWORD PTR [rsp+0x8],rcx
    28da:	mov    QWORD PTR [rsp+0x10],r8
    28df:	mov    r12,r8
    28e2:	mov    r13,rsi
    28e5:	mov    r15,rdx
    28e8:	test   r13,r13
    28eb:	jle    29c5 <botlish_fn_28+0x121>
    28f1:	mov    rbx,rcx
    28f4:	mov    rsi,rbx
    28f7:	mov    rdi,r14
    28fa:	call   28ff <botlish_fn_28+0x5b>
			28fb: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::emailish?<str>
    28ff:	test   rax,rax
    2902:	jne    292d <botlish_fn_28+0x89>
    2908:	xor    rax,rax
    290b:	mov    rbx,QWORD PTR [rsp+0x20]
    2910:	mov    r12,QWORD PTR [rsp+0x28]
    2915:	mov    r13,QWORD PTR [rsp+0x30]
    291a:	mov    r14,QWORD PTR [rsp+0x38]
    291f:	mov    r15,QWORD PTR [rsp+0x40]
    2924:	add    rsp,0x50
    2928:	mov    rsp,rbp
    292b:	pop    rbp
    292c:	ret
    292d:	cmp    rax,0x6
    2931:	je     294d <botlish_fn_28+0xa9>
    2937:	mov    edx,0x1
    293c:	mov    QWORD PTR [rsp+0x18],0x1
    2945:	mov    rsi,r15
    2948:	jmp    2979 <botlish_fn_28+0xd5>
    294d:	mov    rsi,r12
    2950:	mov    rdi,r14
    2953:	call   2958 <botlish_fn_28+0xb4>
			2954: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::uri_query_value?<str>
    2958:	cmp    rax,0x6
    295c:	je     296c <botlish_fn_28+0xc8>
    2962:	mov    edx,0x1
    2967:	jmp    2971 <botlish_fn_28+0xcd>
    296c:	mov    edx,0x3
    2971:	mov    QWORD PTR [rsp+0x18],rdx
    2976:	mov    rsi,r15
    2979:	mov    rax,rsi
    297c:	and    rax,rdx
    297f:	test   rax,0x1
    2985:	je     29a0 <botlish_fn_28+0xfc>
    298b:	lea    rcx,[rdx-0x1]
    298f:	mov    rax,rsi
    2992:	add    rax,rcx
    2995:	seto   cl
    2998:	test   cl,cl
    299a:	je     29a8 <botlish_fn_28+0x104>
    29a0:	mov    rdi,r14
    29a3:	call   29a8 <botlish_fn_28+0x104>
			29a4: R_X86_64_PLT32	rt_int_add-0x4
    29a8:	mov    QWORD PTR [rsp],rax
    29ac:	mov    QWORD PTR [rsp+0x8],rbx
    29b1:	mov    QWORD PTR [rsp+0x10],r12
    29b6:	sub    r13,0x1
    29ba:	mov    rcx,rbx
    29bd:	mov    r15,rax
    29c0:	jmp    28e8 <botlish_fn_28+0x44>
    29c5:	mov    rax,r15
    29c8:	mov    rbx,QWORD PTR [rsp+0x20]
    29cd:	mov    r12,QWORD PTR [rsp+0x28]
    29d2:	mov    r13,QWORD PTR [rsp+0x30]
    29d7:	mov    r14,QWORD PTR [rsp+0x38]
    29dc:	mov    r15,QWORD PTR [rsp+0x40]
    29e1:	add    rsp,0x50
    29e5:	mov    rsp,rbp
    29e8:	pop    rbp
    29e9:	ret

00000000000029ea <botlish_entry_28: check<int, int, str, str>>:
    29ea:	push   rbp
    29eb:	mov    rbp,rsp
    29ee:	mov    rsi,QWORD PTR [rdx]
    29f1:	mov    r9,QWORD PTR [rdx+0x8]
    29f5:	mov    rcx,QWORD PTR [rdx+0x10]
    29f9:	mov    r8,QWORD PTR [rdx+0x18]
    29fd:	sar    rsi,1
    2a00:	mov    rdx,r9
    2a03:	call   2a08 <botlish_entry_28+0x1e>
			2a04: R_X86_64_PLT32	botlish_fn_28-0x4 ; check<int, int, str, str>
    2a08:	mov    rsp,rbp
    2a0b:	pop    rbp
    2a0c:	ret

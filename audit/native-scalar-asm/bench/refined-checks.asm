; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 11263  (per function: 1415 217 745 74 74 74 128 128 336 154 115 216 176 176 295 344 183 564 140 60 501 861 127 103 313 219 287 1255 1615 368)
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
;   botlish_fn_11 / botlish_entry_11 -> char_is?<int, any>
;   botlish_fn_12 / botlish_entry_12 -> local_char?<str>
;   botlish_fn_13 / botlish_entry_13 -> local_char?<generic>
;   botlish_fn_14 / botlish_entry_14 -> scan_while<int, block(e276)>
;   botlish_fn_15 / botlish_entry_15 -> scan_while<int, native(str::is_tcl_alpha)>
;   botlish_fn_16 / botlish_entry_16 -> tld?<int>
;   botlish_fn_17 / botlish_entry_17 -> domain?<int>
;   botlish_fn_18 / botlish_entry_18 -> web::is_unreserved<int>
;   botlish_fn_19 / botlish_entry_19 -> web::uri_query_value?<str>
;   botlish_fn_20 / botlish_entry_20 -> upper_hex?<int>
;   botlish_fn_21 / botlish_entry_21 -> valid_from?<int>
;   botlish_fn_22 / botlish_entry_22 -> web::uri_escape_text<str>
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
			3fa: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::set<List[UnicodeChar]>
     3fe:	test   rax,rax
     401:	je     4e8 <botlish_fn_0+0x4e8>
     407:	mov    rdi,QWORD PTR [rsp+0x158]
     40f:	mov    rcx,QWORD PTR [rdi+0x30]
     413:	mov    QWORD PTR [rcx+0x10],rax
     417:	mov    esi,0xe2a0e1
     41c:	call   421 <botlish_fn_0+0x421>
			41d: R_X86_64_PLT32	botlish_fn_22-0x4 ; web::uri_escape_text<str>
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
     644:	sub    rsp,0x90
     64b:	mov    QWORD PTR [rsp+0x60],rbx
     650:	mov    QWORD PTR [rsp+0x68],r12
     655:	mov    QWORD PTR [rsp+0x70],r13
     65a:	mov    QWORD PTR [rsp+0x78],r14
     65f:	mov    QWORD PTR [rsp+0x80],r15
     667:	mov    r13,rdi
     66a:	mov    QWORD PTR [rsp+0x18],0x0
     673:	mov    QWORD PTR [rsp+0x20],0x0
     67c:	mov    QWORD PTR [rsp],rsi
     680:	mov    rbx,rsi
     683:	mov    rdi,r13
     686:	call   68b <botlish_fn_2+0x4b>
			687: R_X86_64_PLT32	rt_list_len-0x4
     68b:	mov    QWORD PTR [rsp+0x8],rax
     690:	mov    r12,rax
     693:	mov    QWORD PTR [rsp+0x10],0x1
     69c:	xor    rdx,rdx
     69f:	mov    rdi,r13
     6a2:	mov    rsi,rdx
     6a5:	call   6aa <botlish_fn_2+0x6a>
			6a6: R_X86_64_PLT32	rt_list_new-0x4
     6aa:	test   rax,rax
     6ad:	je     841 <botlish_fn_2+0x201>
     6b3:	mov    QWORD PTR [rsp+0x18],rax
     6b8:	mov    QWORD PTR [rsp+0x58],rax
     6bd:	mov    esi,0x1
     6c2:	mov    r14,rsi
     6c5:	mov    rax,rsi
     6c8:	and    rax,r12
     6cb:	mov    r14,rsi
     6ce:	test   rax,0x1
     6d4:	jne    6fd <botlish_fn_2+0xbd>
     6da:	mov    rdx,r12
     6dd:	mov    rsi,r14
     6e0:	mov    rdi,r13
     6e3:	call   6e8 <botlish_fn_2+0xa8>
			6e4: R_X86_64_PLT32	rt_int_cmp-0x4
     6e8:	mov    ecx,0x2
     6ed:	test   rax,rax
     6f0:	cmovl  rcx,QWORD PTR [rip+0x1e8]        # 8e0 <botlish_fn_2+0x2a0>
     6f8:	jmp    710 <botlish_fn_2+0xd0>
     6fd:	mov    ecx,0x2
     702:	mov    rsi,r14
     705:	cmp    rsi,r12
     708:	cmovl  rcx,QWORD PTR [rip+0x1d0]        # 8e0 <botlish_fn_2+0x2a0>
     710:	cmp    rcx,0x6
     714:	je     784 <botlish_fn_2+0x144>
     71a:	lea    rcx,[rsp+0x48]
     71f:	mov    QWORD PTR [rsp+0x48],0x0
     728:	mov    rax,QWORD PTR [rsp+0x58]
     72d:	mov    QWORD PTR [rsp+0x50],rax
     732:	mov    esi,0x1
     737:	mov    edx,0x2
     73c:	mov    rdi,r13
     73f:	call   744 <botlish_fn_2+0x104>
			740: R_X86_64_PLT32	rt_construct-0x4
     744:	test   rax,rax
     747:	je     841 <botlish_fn_2+0x201>
     74d:	mov    QWORD PTR [rsp],rax
     751:	mov    rsi,rax
     754:	mov    rdi,r13
     757:	call   75c <botlish_fn_2+0x11c>
			758: R_X86_64_PLT32	rt_set_from_list-0x4
     75c:	mov    rbx,QWORD PTR [rsp+0x60]
     761:	mov    r12,QWORD PTR [rsp+0x68]
     766:	mov    r13,QWORD PTR [rsp+0x70]
     76b:	mov    r14,QWORD PTR [rsp+0x78]
     770:	mov    r15,QWORD PTR [rsp+0x80]
     778:	add    rsp,0x90
     77f:	mov    rsp,rbp
     782:	pop    rbp
     783:	ret
     784:	mov    rsi,r14
     787:	test   rsi,0x1
     78e:	je     7aa <botlish_fn_2+0x16a>
     794:	mov    r9,QWORD PTR [rbx+0x8]
     798:	mov    rsi,r14
     79b:	mov    r8,rsi
     79e:	sar    r8,1
     7a1:	cmp    r8,r9
     7a4:	jb     7c9 <botlish_fn_2+0x189>
     7aa:	mov    rdx,r14
     7ad:	mov    rsi,rbx
     7b0:	mov    rdi,r13
     7b3:	call   7b8 <botlish_fn_2+0x178>
			7b4: R_X86_64_PLT32	rt_list_get-0x4
     7b8:	test   rax,rax
     7bb:	je     841 <botlish_fn_2+0x201>
     7c1:	mov    rsi,rax
     7c4:	jmp    7d1 <botlish_fn_2+0x191>
     7c9:	mov    rax,QWORD PTR [rbx+0x10]
     7cd:	mov    rsi,QWORD PTR [rax+r8*8]
     7d1:	mov    edx,0x3
     7d6:	mov    r15,rdx
     7d9:	shr    rsi,0x3
     7dd:	shl    rsi,1
     7e0:	or     rsi,0x1
     7e4:	mov    rdi,r13
     7e7:	call   7ec <botlish_fn_2+0x1ac>
			7e8: R_X86_64_PLT32	botlish_fn_1-0x4 ; byte::from_int<int>
     7ec:	test   rax,rax
     7ef:	je     841 <botlish_fn_2+0x201>
     7f5:	mov    QWORD PTR [rsp+0x20],rax
     7fa:	lea    rcx,[rsp+0x28]
     7ff:	mov    QWORD PTR [rsp+0x28],0x0
     808:	mov    r10,QWORD PTR [rsp+0x58]
     80d:	mov    QWORD PTR [rsp+0x30],r10
     812:	mov    QWORD PTR [rsp+0x38],0x2
     81b:	mov    QWORD PTR [rsp+0x40],rax
     820:	mov    edx,0x4
     825:	mov    rsi,r15
     828:	mov    rdi,r13
     82b:	call   830 <botlish_fn_2+0x1f0>
			82c: R_X86_64_PLT32	rt_construct-0x4
     830:	mov    rcx,rax
     833:	mov    QWORD PTR [rsp+0x58],rax
     838:	test   rax,rcx
     83b:	jne    86c <botlish_fn_2+0x22c>
     841:	xor    rax,rax
     844:	mov    rbx,QWORD PTR [rsp+0x60]
     849:	mov    r12,QWORD PTR [rsp+0x68]
     84e:	mov    r13,QWORD PTR [rsp+0x70]
     853:	mov    r14,QWORD PTR [rsp+0x78]
     858:	mov    r15,QWORD PTR [rsp+0x80]
     860:	add    rsp,0x90
     867:	mov    rsp,rbp
     86a:	pop    rbp
     86b:	ret
     86c:	mov    rax,QWORD PTR [rsp+0x58]
     871:	mov    QWORD PTR [rsp+0x18],rax
     876:	mov    QWORD PTR [rsp+0x20],0x3
     87f:	mov    rsi,r14
     882:	test   rsi,0x1
     889:	jne    89a <botlish_fn_2+0x25a>
     88f:	mov    rdx,r15
     892:	mov    rsi,r14
     895:	jmp    8c5 <botlish_fn_2+0x285>
     89a:	mov    rsi,r14
     89d:	mov    rax,rsi
     8a0:	add    rax,0x2
     8a4:	seto   cl
     8a7:	test   cl,cl
     8a9:	je     8ba <botlish_fn_2+0x27a>
     8af:	mov    rdx,r15
     8b2:	mov    rsi,r14
     8b5:	jmp    8c5 <botlish_fn_2+0x285>
     8ba:	mov    rsi,rax
     8bd:	mov    r14,rax
     8c0:	jmp    8d3 <botlish_fn_2+0x293>
     8c5:	mov    rdi,r13
     8c8:	call   8cd <botlish_fn_2+0x28d>
			8c9: R_X86_64_PLT32	rt_int_add-0x4
     8cd:	mov    rsi,rax
     8d0:	mov    r14,rax
     8d3:	mov    QWORD PTR [rsp+0x10],rsi
     8d8:	mov    rsi,r14
     8db:	jmp    6c5 <botlish_fn_2+0x85>
     8e0:	(bad)
     8e1:	add    BYTE PTR [rax],al
     8e3:	add    BYTE PTR [rax],al
     8e5:	add    BYTE PTR [rax],al
	...

00000000000008e8 <botlish_entry_2: byte::set<List[UnicodeChar]>>:
     8e8:	push   rbp
     8e9:	mov    rbp,rsp
     8ec:	mov    rsi,QWORD PTR [rdx]
     8ef:	call   8f4 <botlish_entry_2+0xc>
			8f0: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::set<List[UnicodeChar]>
     8f4:	mov    rsp,rbp
     8f7:	pop    rbp
     8f8:	ret

00000000000008f9 <botlish_fn_3: ascii::is_digit<int>>:
     8f9:	push   rbp
     8fa:	mov    rbp,rsp
     8fd:	cmp    rsi,0x30
     901:	jge    911 <botlish_fn_3+0x18>
     907:	mov    eax,0x2
     90c:	jmp    92a <botlish_fn_3+0x31>
     911:	cmp    rsi,0x39
     915:	jle    925 <botlish_fn_3+0x2c>
     91b:	mov    eax,0x2
     920:	jmp    92a <botlish_fn_3+0x31>
     925:	mov    eax,0x6
     92a:	mov    rsp,rbp
     92d:	pop    rbp
     92e:	ret

000000000000092f <botlish_entry_3: ascii::is_digit<int>>:
     92f:	push   rbp
     930:	mov    rbp,rsp
     933:	mov    rsi,QWORD PTR [rdx]
     936:	sar    rsi,1
     939:	call   93e <botlish_entry_3+0xf>
			93a: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<int>
     93e:	mov    rsp,rbp
     941:	pop    rbp
     942:	ret

0000000000000943 <botlish_fn_4: ascii::is_upper<int>>:
     943:	push   rbp
     944:	mov    rbp,rsp
     947:	cmp    rsi,0x41
     94b:	jge    95b <botlish_fn_4+0x18>
     951:	mov    eax,0x2
     956:	jmp    974 <botlish_fn_4+0x31>
     95b:	cmp    rsi,0x5a
     95f:	jle    96f <botlish_fn_4+0x2c>
     965:	mov    eax,0x2
     96a:	jmp    974 <botlish_fn_4+0x31>
     96f:	mov    eax,0x6
     974:	mov    rsp,rbp
     977:	pop    rbp
     978:	ret

0000000000000979 <botlish_entry_4: ascii::is_upper<int>>:
     979:	push   rbp
     97a:	mov    rbp,rsp
     97d:	mov    rsi,QWORD PTR [rdx]
     980:	sar    rsi,1
     983:	call   988 <botlish_entry_4+0xf>
			984: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_upper<int>
     988:	mov    rsp,rbp
     98b:	pop    rbp
     98c:	ret

000000000000098d <botlish_fn_5: ascii::is_lower<int>>:
     98d:	push   rbp
     98e:	mov    rbp,rsp
     991:	cmp    rsi,0x61
     995:	jge    9a5 <botlish_fn_5+0x18>
     99b:	mov    eax,0x2
     9a0:	jmp    9be <botlish_fn_5+0x31>
     9a5:	cmp    rsi,0x7a
     9a9:	jle    9b9 <botlish_fn_5+0x2c>
     9af:	mov    eax,0x2
     9b4:	jmp    9be <botlish_fn_5+0x31>
     9b9:	mov    eax,0x6
     9be:	mov    rsp,rbp
     9c1:	pop    rbp
     9c2:	ret

00000000000009c3 <botlish_entry_5: ascii::is_lower<int>>:
     9c3:	push   rbp
     9c4:	mov    rbp,rsp
     9c7:	mov    rsi,QWORD PTR [rdx]
     9ca:	sar    rsi,1
     9cd:	call   9d2 <botlish_entry_5+0xf>
			9ce: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_lower<int>
     9d2:	mov    rsp,rbp
     9d5:	pop    rbp
     9d6:	ret

00000000000009d7 <botlish_fn_6: ascii::is_alphabetic<int>>:
     9d7:	push   rbp
     9d8:	mov    rbp,rsp
     9db:	sub    rsp,0x10
     9df:	mov    QWORD PTR [rsp],r12
     9e3:	mov    QWORD PTR [rsp+0x8],r14
     9e8:	mov    r12,rsi
     9eb:	mov    r14,rdi
     9ee:	mov    rsi,r12
     9f1:	mov    rdi,r14
     9f4:	call   9f9 <botlish_fn_6+0x22>
			9f5: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_upper<int>
     9f9:	cmp    rax,0x6
     9fd:	je     a2c <botlish_fn_6+0x55>
     a03:	mov    rsi,r12
     a06:	mov    rdi,r14
     a09:	call   a0e <botlish_fn_6+0x37>
			a0a: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_lower<int>
     a0e:	cmp    rax,0x6
     a12:	je     a22 <botlish_fn_6+0x4b>
     a18:	mov    eax,0x2
     a1d:	jmp    a31 <botlish_fn_6+0x5a>
     a22:	mov    eax,0x6
     a27:	jmp    a31 <botlish_fn_6+0x5a>
     a2c:	mov    eax,0x6
     a31:	mov    r12,QWORD PTR [rsp]
     a35:	mov    r14,QWORD PTR [rsp+0x8]
     a3a:	add    rsp,0x10
     a3e:	mov    rsp,rbp
     a41:	pop    rbp
     a42:	ret

0000000000000a43 <botlish_entry_6: ascii::is_alphabetic<int>>:
     a43:	push   rbp
     a44:	mov    rbp,rsp
     a47:	mov    rsi,QWORD PTR [rdx]
     a4a:	sar    rsi,1
     a4d:	call   a52 <botlish_entry_6+0xf>
			a4e: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_alphabetic<int>
     a52:	mov    rsp,rbp
     a55:	pop    rbp
     a56:	ret

0000000000000a57 <botlish_fn_7: ascii::is_alphanumeric<int>>:
     a57:	push   rbp
     a58:	mov    rbp,rsp
     a5b:	sub    rsp,0x10
     a5f:	mov    QWORD PTR [rsp],r12
     a63:	mov    QWORD PTR [rsp+0x8],r14
     a68:	mov    r12,rsi
     a6b:	mov    r14,rdi
     a6e:	mov    rsi,r12
     a71:	mov    rdi,r14
     a74:	call   a79 <botlish_fn_7+0x22>
			a75: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_alphabetic<int>
     a79:	cmp    rax,0x6
     a7d:	je     aac <botlish_fn_7+0x55>
     a83:	mov    rsi,r12
     a86:	mov    rdi,r14
     a89:	call   a8e <botlish_fn_7+0x37>
			a8a: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<int>
     a8e:	cmp    rax,0x6
     a92:	je     aa2 <botlish_fn_7+0x4b>
     a98:	mov    eax,0x2
     a9d:	jmp    ab1 <botlish_fn_7+0x5a>
     aa2:	mov    eax,0x6
     aa7:	jmp    ab1 <botlish_fn_7+0x5a>
     aac:	mov    eax,0x6
     ab1:	mov    r12,QWORD PTR [rsp]
     ab5:	mov    r14,QWORD PTR [rsp+0x8]
     aba:	add    rsp,0x10
     abe:	mov    rsp,rbp
     ac1:	pop    rbp
     ac2:	ret

0000000000000ac3 <botlish_entry_7: ascii::is_alphanumeric<int>>:
     ac3:	push   rbp
     ac4:	mov    rbp,rsp
     ac7:	mov    rsi,QWORD PTR [rdx]
     aca:	sar    rsi,1
     acd:	call   ad2 <botlish_entry_7+0xf>
			ace: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphanumeric<int>
     ad2:	mov    rsp,rbp
     ad5:	pop    rbp
     ad6:	ret

0000000000000ad7 <botlish_fn_8: web::emailish?<str>>:
     ad7:	push   rbp
     ad8:	mov    rbp,rsp
     adb:	sub    rsp,0x40
     adf:	mov    QWORD PTR [rsp+0x20],rbx
     ae4:	mov    QWORD PTR [rsp+0x28],r12
     ae9:	mov    QWORD PTR [rsp+0x30],r13
     aee:	mov    QWORD PTR [rsp+0x38],r14
     af3:	mov    r12,rsi
     af6:	mov    QWORD PTR [rsp],rsi
     afa:	mov    rsi,r12
     afd:	mov    rdx,QWORD PTR [rsi+0x8]
     b01:	shl    rdx,1
     b04:	mov    rcx,rdx
     b07:	or     rcx,0x1
     b0b:	mov    r14,rdx
     b0e:	mov    QWORD PTR [rsp+0x8],rcx
     b13:	mov    rax,QWORD PTR [rdi+0x10]
     b17:	mov    r13,rdi
     b1a:	mov    rdx,QWORD PTR [rax+0xc0]
     b21:	mov    QWORD PTR [rsp+0x10],rdx
     b26:	xor    rsi,rsi
     b29:	mov    r8,r12
     b2c:	call   b31 <botlish_fn_8+0x5a>
			b2d: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, block(e276)>
     b31:	test   rax,rax
     b34:	je     bd9 <botlish_fn_8+0x102>
     b3a:	mov    rbx,rax
     b3d:	sar    rbx,1
     b40:	mov    rdi,rax
     b43:	test   rbx,rbx
     b46:	jle    b98 <botlish_fn_8+0xc1>
     b4c:	mov    rsi,r14
     b4f:	mov    rax,rsi
     b52:	or     rax,0x1
     b56:	sar    rax,1
     b59:	cmp    rbx,rax
     b5c:	jl     b6c <botlish_fn_8+0x95>
     b62:	mov    eax,0xa
     b67:	jmp    b98 <botlish_fn_8+0xc1>
     b6c:	mov    edx,0x204
     b71:	mov    rcx,rsi
     b74:	or     rcx,0x1
     b78:	mov    r14,rsi
     b7b:	mov    rsi,rdi
     b7e:	mov    rdi,r13
     b81:	mov    r8,r12
     b84:	call   b89 <botlish_fn_8+0xb2>
			b85: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_is?<int, any>
     b89:	cmp    rax,0x6
     b8d:	je     bba <botlish_fn_8+0xe3>
     b93:	mov    eax,0xa
     b98:	mov    eax,0x2
     b9d:	mov    rbx,QWORD PTR [rsp+0x20]
     ba2:	mov    r12,QWORD PTR [rsp+0x28]
     ba7:	mov    r13,QWORD PTR [rsp+0x30]
     bac:	mov    r14,QWORD PTR [rsp+0x38]
     bb1:	add    rsp,0x40
     bb5:	mov    rsp,rbp
     bb8:	pop    rbp
     bb9:	ret
     bba:	lea    rsi,[rbx+0x1]
     bbe:	mov    rdx,r14
     bc1:	or     rdx,0x1
     bc5:	mov    rcx,r12
     bc8:	mov    rdi,r13
     bcb:	call   bd0 <botlish_fn_8+0xf9>
			bcc: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<int>
     bd0:	test   rax,rax
     bd3:	jne    bf9 <botlish_fn_8+0x122>
     bd9:	xor    rax,rax
     bdc:	mov    rbx,QWORD PTR [rsp+0x20]
     be1:	mov    r12,QWORD PTR [rsp+0x28]
     be6:	mov    r13,QWORD PTR [rsp+0x30]
     beb:	mov    r14,QWORD PTR [rsp+0x38]
     bf0:	add    rsp,0x40
     bf4:	mov    rsp,rbp
     bf7:	pop    rbp
     bf8:	ret
     bf9:	mov    rbx,QWORD PTR [rsp+0x20]
     bfe:	mov    r12,QWORD PTR [rsp+0x28]
     c03:	mov    r13,QWORD PTR [rsp+0x30]
     c08:	mov    r14,QWORD PTR [rsp+0x38]
     c0d:	add    rsp,0x40
     c11:	mov    rsp,rbp
     c14:	pop    rbp
     c15:	ret

0000000000000c16 <botlish_entry_8: web::emailish?<str>>:
     c16:	push   rbp
     c17:	mov    rbp,rsp
     c1a:	mov    rsi,QWORD PTR [rdx]
     c1d:	call   c22 <botlish_entry_8+0xc>
			c1e: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::emailish?<str>
     c22:	mov    rsp,rbp
     c25:	pop    rbp
     c26:	ret

0000000000000c27 <botlish_fn_9: char_at<int>>:
     c27:	push   rbp
     c28:	mov    rbp,rsp
     c2b:	sub    rsp,0x20
     c2f:	mov    QWORD PTR [rsp],rsi
     c33:	mov    QWORD PTR [rsp+0x8],rcx
     c38:	mov    r8,rcx
     c3b:	mov    rax,rsi
     c3e:	sar    rax,1
     c41:	sar    rdx,1
     c44:	cmp    rax,rdx
     c47:	jge    c57 <botlish_fn_9+0x30>
     c4d:	mov    ecx,0x2
     c52:	jmp    c5c <botlish_fn_9+0x35>
     c57:	mov    ecx,0x6
     c5c:	cmp    rcx,0x6
     c60:	je     c8a <botlish_fn_9+0x63>
     c66:	lea    rcx,[rax+0x1]
     c6a:	shl    rcx,1
     c6d:	or     rcx,0x1
     c71:	mov    QWORD PTR [rsp+0x10],rcx
     c76:	mov    rdx,rsi
     c79:	mov    rsi,r8
     c7c:	call   c81 <botlish_fn_9+0x5a>
			c7d: R_X86_64_PLT32	rt_substr_proven-0x4
     c81:	add    rsp,0x20
     c85:	mov    rsp,rbp
     c88:	pop    rbp
     c89:	ret
     c8a:	mov    rax,QWORD PTR [rdi+0x10]
     c8e:	mov    rax,QWORD PTR [rax+0xc8]
     c95:	add    rsp,0x20
     c99:	mov    rsp,rbp
     c9c:	pop    rbp
     c9d:	ret

0000000000000c9e <botlish_entry_9: char_at<int>>:
     c9e:	push   rbp
     c9f:	mov    rbp,rsp
     ca2:	mov    rsi,QWORD PTR [rdx]
     ca5:	mov    r8,QWORD PTR [rdx+0x8]
     ca9:	mov    rcx,QWORD PTR [rdx+0x10]
     cad:	mov    rdx,r8
     cb0:	call   cb5 <botlish_entry_9+0x17>
			cb1: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     cb5:	mov    rsp,rbp
     cb8:	pop    rbp
     cb9:	ret

0000000000000cba <botlish_fn_10: char_at<int>>:
     cba:	push   rbp
     cbb:	mov    rbp,rsp
     cbe:	mov    rax,rsi
     cc1:	sar    rax,1
     cc4:	sar    rdx,1
     cc7:	cmp    rax,rdx
     cca:	jge    cdb <botlish_fn_10+0x21>
     cd0:	mov    r11d,0x2
     cd6:	jmp    ce1 <botlish_fn_10+0x27>
     cdb:	mov    r11d,0x6
     ce1:	cmp    r11,0x6
     ce5:	je     d08 <botlish_fn_10+0x4e>
     ceb:	mov    QWORD PTR [r8],rsi
     cee:	add    rax,0x1
     cf5:	shl    rax,1
     cf8:	or     rax,0x1
     cfc:	mov    QWORD PTR [r8+0x8],rax
     d00:	mov    rax,rcx
     d03:	mov    rsp,rbp
     d06:	pop    rbp
     d07:	ret
     d08:	mov    rax,QWORD PTR [rdi+0x10]
     d0c:	mov    rax,QWORD PTR [rax+0xc8]
     d13:	mov    QWORD PTR [r8],0x1
     d1a:	mov    QWORD PTR [r8+0x8],0x1
     d22:	mov    rsp,rbp
     d25:	pop    rbp
     d26:	ret

0000000000000d27 <botlish_entry_10: char_at<int>>:
     d27:	push   rbp
     d28:	mov    rbp,rsp
     d2b:	ud2
     d2d:	add    BYTE PTR [rax],al
	...

0000000000000d30 <botlish_fn_11: char_is?<int, any>>:
     d30:	push   rbp
     d31:	mov    rbp,rsp
     d34:	sub    rsp,0x10
     d38:	mov    QWORD PTR [rsp],rbx
     d3c:	mov    rbx,rdx
     d3f:	mov    rax,rsi
     d42:	sar    rax,1
     d45:	sar    rcx,1
     d48:	cmp    rax,rcx
     d4b:	jge    d5c <botlish_fn_11+0x2c>
     d51:	mov    r11d,0x2
     d57:	jmp    d62 <botlish_fn_11+0x32>
     d5c:	mov    r11d,0x6
     d62:	cmp    r11,0x6
     d66:	je     dc7 <botlish_fn_11+0x97>
     d6c:	movzx  rcx,BYTE PTR [r8+0x18]
     d71:	mov    rdx,r8
     d74:	test   rcx,rcx
     d77:	jne    d93 <botlish_fn_11+0x63>
     d7d:	mov    rax,rdx
     d80:	mov    rdx,rsi
     d83:	mov    rsi,rax
     d86:	call   d8b <botlish_fn_11+0x5b>
			d87: R_X86_64_PLT32	rt_str_char_at_proven-0x4
     d8b:	mov    rcx,rax
     d8e:	jmp    da7 <botlish_fn_11+0x77>
     d93:	mov    rsi,rdx
     d96:	movzx  rax,BYTE PTR [rsi+rax*1+0x19]
     d9c:	shl    rax,0x3
     da0:	or     rax,0x4
     da4:	mov    rcx,rax
     da7:	mov    eax,0x2
     dac:	mov    rdx,rbx
     daf:	cmp    rcx,rdx
     db2:	cmove  rax,QWORD PTR [rip+0x26]        # de0 <botlish_fn_11+0xb0>
     dba:	mov    rbx,QWORD PTR [rsp]
     dbe:	add    rsp,0x10
     dc2:	mov    rsp,rbp
     dc5:	pop    rbp
     dc6:	ret
     dc7:	mov    eax,0x2
     dcc:	mov    rbx,QWORD PTR [rsp]
     dd0:	add    rsp,0x10
     dd4:	mov    rsp,rbp
     dd7:	pop    rbp
     dd8:	ret
     dd9:	add    BYTE PTR [rax],al
     ddb:	add    BYTE PTR [rax],al
     ddd:	add    BYTE PTR [rax],al
     ddf:	add    BYTE PTR [rsi],al
     de1:	add    BYTE PTR [rax],al
     de3:	add    BYTE PTR [rax],al
     de5:	add    BYTE PTR [rax],al
	...

0000000000000de8 <botlish_entry_11: char_is?<int, any>>:
     de8:	push   rbp
     de9:	mov    rbp,rsp
     dec:	mov    rsi,QWORD PTR [rdx]
     def:	mov    r9,QWORD PTR [rdx+0x8]
     df3:	mov    rcx,QWORD PTR [rdx+0x10]
     df7:	mov    r8,QWORD PTR [rdx+0x18]
     dfb:	mov    rdx,r9
     dfe:	call   e03 <botlish_entry_11+0x1b>
			dff: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_is?<int, any>
     e03:	mov    rsp,rbp
     e06:	pop    rbp
     e07:	ret

0000000000000e08 <botlish_fn_12: local_char?<str>>:
     e08:	push   rbp
     e09:	mov    rbp,rsp
     e0c:	sub    rsp,0x10
     e10:	mov    QWORD PTR [rsp],rbx
     e14:	mov    QWORD PTR [rsp+0x8],r14
     e19:	mov    rbx,rdi
     e1c:	mov    r14,rsi
     e1f:	mov    rsi,r14
     e22:	mov    rdi,rbx
     e25:	call   e2a <botlish_fn_12+0x22>
			e26: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     e2a:	test   rax,rax
     e2d:	jne    e48 <botlish_fn_12+0x40>
     e33:	xor    rax,rax
     e36:	mov    rbx,QWORD PTR [rsp]
     e3a:	mov    r14,QWORD PTR [rsp+0x8]
     e3f:	add    rsp,0x10
     e43:	mov    rsp,rbp
     e46:	pop    rbp
     e47:	ret
     e48:	cmp    rax,0x6
     e4c:	je     e82 <botlish_fn_12+0x7a>
     e52:	mov    rdi,rbx
     e55:	mov    rax,QWORD PTR [rdi+0x30]
     e59:	mov    rsi,QWORD PTR [rax]
     e5c:	mov    rdx,r14
     e5f:	call   e64 <botlish_fn_12+0x5c>
			e60: R_X86_64_PLT32	rt_set_contains-0x4
     e64:	cmp    rax,0x6
     e68:	je     e78 <botlish_fn_12+0x70>
     e6e:	mov    eax,0x2
     e73:	jmp    e87 <botlish_fn_12+0x7f>
     e78:	mov    eax,0x6
     e7d:	jmp    e87 <botlish_fn_12+0x7f>
     e82:	mov    eax,0x6
     e87:	mov    rbx,QWORD PTR [rsp]
     e8b:	mov    r14,QWORD PTR [rsp+0x8]
     e90:	add    rsp,0x10
     e94:	mov    rsp,rbp
     e97:	pop    rbp
     e98:	ret

0000000000000e99 <botlish_entry_12: local_char?<str>>:
     e99:	push   rbp
     e9a:	mov    rbp,rsp
     e9d:	mov    rsi,QWORD PTR [rdx]
     ea0:	call   ea5 <botlish_entry_12+0xc>
			ea1: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     ea5:	mov    rsp,rbp
     ea8:	pop    rbp
     ea9:	ret

0000000000000eaa <botlish_fn_13: local_char?<generic>>:
     eaa:	push   rbp
     eab:	mov    rbp,rsp
     eae:	sub    rsp,0x10
     eb2:	mov    QWORD PTR [rsp],rbx
     eb6:	mov    QWORD PTR [rsp+0x8],r14
     ebb:	mov    rbx,rdi
     ebe:	mov    r14,rsi
     ec1:	mov    rsi,r14
     ec4:	mov    rdi,rbx
     ec7:	call   ecc <botlish_fn_13+0x22>
			ec8: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     ecc:	test   rax,rax
     ecf:	jne    eea <botlish_fn_13+0x40>
     ed5:	xor    rax,rax
     ed8:	mov    rbx,QWORD PTR [rsp]
     edc:	mov    r14,QWORD PTR [rsp+0x8]
     ee1:	add    rsp,0x10
     ee5:	mov    rsp,rbp
     ee8:	pop    rbp
     ee9:	ret
     eea:	cmp    rax,0x6
     eee:	je     f24 <botlish_fn_13+0x7a>
     ef4:	mov    rdi,rbx
     ef7:	mov    rax,QWORD PTR [rdi+0x30]
     efb:	mov    rsi,QWORD PTR [rax]
     efe:	mov    rdx,r14
     f01:	call   f06 <botlish_fn_13+0x5c>
			f02: R_X86_64_PLT32	rt_set_contains-0x4
     f06:	cmp    rax,0x6
     f0a:	je     f1a <botlish_fn_13+0x70>
     f10:	mov    eax,0x2
     f15:	jmp    f29 <botlish_fn_13+0x7f>
     f1a:	mov    eax,0x6
     f1f:	jmp    f29 <botlish_fn_13+0x7f>
     f24:	mov    eax,0x6
     f29:	mov    rbx,QWORD PTR [rsp]
     f2d:	mov    r14,QWORD PTR [rsp+0x8]
     f32:	add    rsp,0x10
     f36:	mov    rsp,rbp
     f39:	pop    rbp
     f3a:	ret

0000000000000f3b <botlish_entry_13: local_char?<generic>>:
     f3b:	push   rbp
     f3c:	mov    rbp,rsp
     f3f:	mov    rsi,QWORD PTR [rdx]
     f42:	call   f47 <botlish_entry_13+0xc>
			f43: R_X86_64_PLT32	botlish_fn_13-0x4 ; local_char?<generic>
     f47:	mov    rsp,rbp
     f4a:	pop    rbp
     f4b:	ret

0000000000000f4c <botlish_fn_14: scan_while<int, block(e276)>>:
     f4c:	push   rbp
     f4d:	mov    rbp,rsp
     f50:	sub    rsp,0x50
     f54:	mov    QWORD PTR [rsp+0x20],rbx
     f59:	mov    QWORD PTR [rsp+0x28],r12
     f5e:	mov    QWORD PTR [rsp+0x30],r13
     f63:	mov    QWORD PTR [rsp+0x38],r14
     f68:	mov    QWORD PTR [rsp+0x40],r15
     f6d:	mov    QWORD PTR [rsp+0x18],rdi
     f72:	mov    QWORD PTR [rsp],rcx
     f76:	mov    QWORD PTR [rsp+0x8],r8
     f7b:	mov    r15,r8
     f7e:	mov    r12,rcx
     f81:	sar    r12,1
     f84:	mov    r14,rcx
     f87:	mov    rbx,rsi
     f8a:	cmp    rbx,r12
     f8d:	jl     fb8 <botlish_fn_14+0x6c>
     f93:	mov    rax,r14
     f96:	mov    rbx,QWORD PTR [rsp+0x20]
     f9b:	mov    r12,QWORD PTR [rsp+0x28]
     fa0:	mov    r13,QWORD PTR [rsp+0x30]
     fa5:	mov    r14,QWORD PTR [rsp+0x38]
     faa:	mov    r15,QWORD PTR [rsp+0x40]
     faf:	add    rsp,0x50
     fb3:	mov    rsp,rbp
     fb6:	pop    rbp
     fb7:	ret
     fb8:	mov    r13,rbx
     fbb:	shl    r13,1
     fbe:	or     r13,0x1
     fc2:	mov    QWORD PTR [rsp+0x10],r13
     fc7:	mov    rcx,r15
     fca:	mov    rdx,r14
     fcd:	mov    rsi,r13
     fd0:	mov    rdi,QWORD PTR [rsp+0x18]
     fd5:	call   fda <botlish_fn_14+0x8e>
			fd6: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     fda:	mov    rsi,rax
     fdd:	mov    rdi,QWORD PTR [rsp+0x18]
     fe2:	call   fe7 <botlish_fn_14+0x9b>
			fe3: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     fe7:	test   rax,rax
     fea:	jne    1015 <botlish_fn_14+0xc9>
     ff0:	xor    rax,rax
     ff3:	mov    rbx,QWORD PTR [rsp+0x20]
     ff8:	mov    r12,QWORD PTR [rsp+0x28]
     ffd:	mov    r13,QWORD PTR [rsp+0x30]
    1002:	mov    r14,QWORD PTR [rsp+0x38]
    1007:	mov    r15,QWORD PTR [rsp+0x40]
    100c:	add    rsp,0x50
    1010:	mov    rsp,rbp
    1013:	pop    rbp
    1014:	ret
    1015:	cmp    rax,0x6
    1019:	je     1044 <botlish_fn_14+0xf8>
    101f:	mov    rax,r13
    1022:	mov    rbx,QWORD PTR [rsp+0x20]
    1027:	mov    r12,QWORD PTR [rsp+0x28]
    102c:	mov    r13,QWORD PTR [rsp+0x30]
    1031:	mov    r14,QWORD PTR [rsp+0x38]
    1036:	mov    r15,QWORD PTR [rsp+0x40]
    103b:	add    rsp,0x50
    103f:	mov    rsp,rbp
    1042:	pop    rbp
    1043:	ret
    1044:	add    rbx,0x1
    104b:	jmp    f8a <botlish_fn_14+0x3e>

0000000000001050 <botlish_entry_14: scan_while<int, block(e276)>>:
    1050:	push   rbp
    1051:	mov    rbp,rsp
    1054:	mov    rsi,QWORD PTR [rdx]
    1057:	mov    r9,QWORD PTR [rdx+0x8]
    105b:	mov    rcx,QWORD PTR [rdx+0x10]
    105f:	mov    r8,QWORD PTR [rdx+0x18]
    1063:	sar    rsi,1
    1066:	mov    rdx,r9
    1069:	call   106e <botlish_entry_14+0x1e>
			106a: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, block(e276)>
    106e:	mov    rsp,rbp
    1071:	pop    rbp
    1072:	ret

0000000000001073 <botlish_fn_15: scan_while<int, native(str::is_tcl_alpha)>>:
    1073:	push   rbp
    1074:	mov    rbp,rsp
    1077:	sub    rsp,0x40
    107b:	mov    QWORD PTR [rsp+0x10],rbx
    1080:	mov    QWORD PTR [rsp+0x18],r12
    1085:	mov    QWORD PTR [rsp+0x20],r13
    108a:	mov    QWORD PTR [rsp+0x28],r14
    108f:	mov    QWORD PTR [rsp+0x30],r15
    1094:	mov    rbx,r8
    1097:	mov    r13,rdi
    109a:	mov    rax,rcx
    109d:	sar    rax,1
    10a0:	mov    r12,rcx
    10a3:	mov    r14,rax
    10a6:	mov    rax,rsi
    10a9:	mov    rcx,r14
    10ac:	cmp    rax,rcx
    10af:	mov    r14,rcx
    10b2:	jl     10e2 <botlish_fn_15+0x6f>
    10b8:	mov    edx,0x1
    10bd:	mov    rax,r14
    10c0:	mov    rbx,QWORD PTR [rsp+0x10]
    10c5:	mov    r12,QWORD PTR [rsp+0x18]
    10ca:	mov    r13,QWORD PTR [rsp+0x20]
    10cf:	mov    r14,QWORD PTR [rsp+0x28]
    10d4:	mov    r15,QWORD PTR [rsp+0x30]
    10d9:	add    rsp,0x40
    10dd:	mov    rsp,rbp
    10e0:	pop    rbp
    10e1:	ret
    10e2:	mov    rsi,rax
    10e5:	shl    rsi,1
    10e8:	mov    r15,rax
    10eb:	or     rsi,0x1
    10ef:	lea    r8,[rsp]
    10f3:	mov    rcx,rbx
    10f6:	mov    rdx,r12
    10f9:	mov    rdi,r13
    10fc:	call   1101 <botlish_fn_15+0x8e>
			10fd: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    1101:	mov    rdx,QWORD PTR [rsp]
    1105:	mov    rcx,QWORD PTR [rsp+0x8]
    110a:	mov    rsi,rax
    110d:	mov    rdi,r13
    1110:	call   1115 <botlish_fn_15+0xa2>
			1111: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    1115:	test   rax,rax
    1118:	jne    1146 <botlish_fn_15+0xd3>
    111e:	xor    rdx,rdx
    1121:	mov    rax,rdx
    1124:	mov    rbx,QWORD PTR [rsp+0x10]
    1129:	mov    r12,QWORD PTR [rsp+0x18]
    112e:	mov    r13,QWORD PTR [rsp+0x20]
    1133:	mov    r14,QWORD PTR [rsp+0x28]
    1138:	mov    r15,QWORD PTR [rsp+0x30]
    113d:	add    rsp,0x40
    1141:	mov    rsp,rbp
    1144:	pop    rbp
    1145:	ret
    1146:	cmp    rax,0x6
    114a:	je     117a <botlish_fn_15+0x107>
    1150:	mov    edx,0x1
    1155:	mov    rax,r15
    1158:	mov    rbx,QWORD PTR [rsp+0x10]
    115d:	mov    r12,QWORD PTR [rsp+0x18]
    1162:	mov    r13,QWORD PTR [rsp+0x20]
    1167:	mov    r14,QWORD PTR [rsp+0x28]
    116c:	mov    r15,QWORD PTR [rsp+0x30]
    1171:	add    rsp,0x40
    1175:	mov    rsp,rbp
    1178:	pop    rbp
    1179:	ret
    117a:	mov    rax,r15
    117d:	add    rax,0x1
    1184:	mov    rcx,r14
    1187:	jmp    10ac <botlish_fn_15+0x39>

000000000000118c <botlish_entry_15: scan_while<int, native(str::is_tcl_alpha)>>:
    118c:	push   rbp
    118d:	mov    rbp,rsp
    1190:	mov    rsi,QWORD PTR [rdx]
    1193:	mov    rax,QWORD PTR [rdx+0x8]
    1197:	mov    rcx,QWORD PTR [rdx+0x10]
    119b:	mov    r8,QWORD PTR [rdx+0x18]
    119f:	sar    rsi,1
    11a2:	mov    rdx,rax
    11a5:	call   11aa <botlish_entry_15+0x1e>
			11a6: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<int, native(str::is_tcl_alpha)>
    11aa:	shl    rax,1
    11ad:	or     rax,0x1
    11b1:	mov    rcx,rax
    11b4:	xor    rax,rax
    11b7:	test   rdx,rdx
    11ba:	cmovne rax,rcx
    11be:	mov    rsp,rbp
    11c1:	pop    rbp
    11c2:	ret
    11c3:	add    BYTE PTR [rax],al
    11c5:	add    BYTE PTR [rax],al
	...

00000000000011c8 <botlish_fn_16: tld?<int>>:
    11c8:	push   rbp
    11c9:	mov    rbp,rsp
    11cc:	sub    rsp,0x10
    11d0:	mov    QWORD PTR [rsp],rbx
    11d4:	mov    QWORD PTR [rsp+0x8],r12
    11d9:	mov    r8,rdx
    11dc:	mov    rax,QWORD PTR [rdi+0x10]
    11e0:	mov    rdx,QWORD PTR [rax+0xd0]
    11e7:	mov    r12,r8
    11ea:	mov    r8,rcx
    11ed:	mov    rbx,rsi
    11f0:	mov    rcx,r12
    11f3:	call   11f8 <botlish_fn_16+0x30>
			11f4: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<int, native(str::is_tcl_alpha)>
    11f8:	test   rdx,rdx
    11fb:	jne    1216 <botlish_fn_16+0x4e>
    1201:	xor    rax,rax
    1204:	mov    rbx,QWORD PTR [rsp]
    1208:	mov    r12,QWORD PTR [rsp+0x8]
    120d:	add    rsp,0x10
    1211:	mov    rsp,rbp
    1214:	pop    rbp
    1215:	ret
    1216:	sar    r12,1
    1219:	cmp    rax,r12
    121c:	je     122c <botlish_fn_16+0x64>
    1222:	mov    eax,0x2
    1227:	jmp    1243 <botlish_fn_16+0x7b>
    122c:	sub    rax,rbx
    122f:	mov    rcx,rax
    1232:	mov    eax,0x2
    1237:	cmp    rcx,0x2
    123b:	cmovge rax,QWORD PTR [rip+0x15]        # 1258 <botlish_fn_16+0x90>
    1243:	mov    rbx,QWORD PTR [rsp]
    1247:	mov    r12,QWORD PTR [rsp+0x8]
    124c:	add    rsp,0x10
    1250:	mov    rsp,rbp
    1253:	pop    rbp
    1254:	ret
    1255:	add    BYTE PTR [rax],al
    1257:	add    BYTE PTR [rsi],al
    1259:	add    BYTE PTR [rax],al
    125b:	add    BYTE PTR [rax],al
    125d:	add    BYTE PTR [rax],al
	...

0000000000001260 <botlish_entry_16: tld?<int>>:
    1260:	push   rbp
    1261:	mov    rbp,rsp
    1264:	mov    rsi,QWORD PTR [rdx]
    1267:	mov    r8,QWORD PTR [rdx+0x8]
    126b:	mov    rcx,QWORD PTR [rdx+0x10]
    126f:	sar    rsi,1
    1272:	mov    rdx,r8
    1275:	call   127a <botlish_entry_16+0x1a>
			1276: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<int>
    127a:	mov    rsp,rbp
    127d:	pop    rbp
    127e:	ret

000000000000127f <botlish_fn_17: domain?<int>>:
    127f:	push   rbp
    1280:	mov    rbp,rsp
    1283:	sub    rsp,0x60
    1287:	mov    QWORD PTR [rsp+0x30],rbx
    128c:	mov    QWORD PTR [rsp+0x38],r12
    1291:	mov    QWORD PTR [rsp+0x40],r13
    1296:	mov    QWORD PTR [rsp+0x48],r14
    129b:	mov    QWORD PTR [rsp+0x50],r15
    12a0:	mov    r13,rsi
    12a3:	mov    r15,rcx
    12a6:	mov    r14,rdx
    12a9:	sar    r14,1
    12ac:	mov    QWORD PTR [rsp+0x10],rdx
    12b1:	mov    r12,r13
    12b4:	cmp    r12,r14
    12b7:	jge    145f <botlish_fn_17+0x1e0>
    12bd:	mov    rsi,r12
    12c0:	shl    rsi,1
    12c3:	or     rsi,0x1
    12c7:	mov    QWORD PTR [rsp+0x28],rsi
    12cc:	mov    edx,0x174
    12d1:	mov    rbx,rdi
    12d4:	mov    rcx,QWORD PTR [rsp+0x10]
    12d9:	mov    r8,r15
    12dc:	call   12e1 <botlish_fn_17+0x62>
			12dd: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_is?<int, any>
    12e1:	cmp    rax,0x6
    12e5:	je     13a6 <botlish_fn_17+0x127>
    12eb:	lea    r8,[rsp]
    12ef:	mov    rsi,QWORD PTR [rsp+0x28]
    12f4:	mov    rcx,r15
    12f7:	mov    rdx,QWORD PTR [rsp+0x10]
    12fc:	mov    rdi,rbx
    12ff:	call   1304 <botlish_fn_17+0x85>
			1300: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
    1304:	mov    QWORD PTR [rsp+0x28],rax
    1309:	mov    rdx,QWORD PTR [rsp]
    130d:	mov    QWORD PTR [rsp+0x20],rdx
    1312:	mov    rcx,QWORD PTR [rsp+0x8]
    1317:	mov    QWORD PTR [rsp+0x18],rcx
    131c:	mov    rsi,QWORD PTR [rsp+0x28]
    1321:	mov    rdi,rbx
    1324:	call   1329 <botlish_fn_17+0xaa>
			1325: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1329:	test   rax,rax
    132c:	je     13fa <botlish_fn_17+0x17b>
    1332:	cmp    rax,0x6
    1336:	je     1379 <botlish_fn_17+0xfa>
    133c:	mov    rax,QWORD PTR [rbx+0x10]
    1340:	mov    r8,QWORD PTR [rax+0x20]
    1344:	mov    rcx,QWORD PTR [rsp+0x18]
    1349:	mov    rdx,QWORD PTR [rsp+0x20]
    134e:	mov    rsi,QWORD PTR [rsp+0x28]
    1353:	mov    rdi,rbx
    1356:	call   135b <botlish_fn_17+0xdc>
			1357: R_X86_64_PLT32	rt_str_region_eq-0x4
    135b:	cmp    rax,0x6
    135f:	je     136f <botlish_fn_17+0xf0>
    1365:	mov    ecx,0x2
    136a:	jmp    137e <botlish_fn_17+0xff>
    136f:	mov    ecx,0x6
    1374:	jmp    137e <botlish_fn_17+0xff>
    1379:	mov    ecx,0x6
    137e:	cmp    rcx,0x6
    1382:	je     1392 <botlish_fn_17+0x113>
    1388:	mov    eax,0x6
    138d:	jmp    1397 <botlish_fn_17+0x118>
    1392:	mov    eax,0x2
    1397:	cmp    rax,0x6
    139b:	jne    1429 <botlish_fn_17+0x1aa>
    13a1:	jmp    145f <botlish_fn_17+0x1e0>
    13a6:	cmp    r12,r13
    13a9:	je     145f <botlish_fn_17+0x1e0>
    13af:	mov    rsi,r12
    13b2:	sub    rsi,0x1
    13b6:	shl    rsi,1
    13b9:	or     rsi,0x1
    13bd:	mov    edx,0x174
    13c2:	mov    rcx,QWORD PTR [rsp+0x10]
    13c7:	mov    rdi,rbx
    13ca:	mov    r8,r15
    13cd:	call   13d2 <botlish_fn_17+0x153>
			13ce: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_is?<int, any>
    13d2:	cmp    rax,0x6
    13d6:	je     145f <botlish_fn_17+0x1e0>
    13dc:	lea    rsi,[r12+0x1]
    13e1:	mov    rcx,r15
    13e4:	mov    rdx,QWORD PTR [rsp+0x10]
    13e9:	mov    rdi,rbx
    13ec:	call   13f1 <botlish_fn_17+0x172>
			13ed: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<int>
    13f1:	test   rax,rax
    13f4:	jne    141f <botlish_fn_17+0x1a0>
    13fa:	xor    rax,rax
    13fd:	mov    rbx,QWORD PTR [rsp+0x30]
    1402:	mov    r12,QWORD PTR [rsp+0x38]
    1407:	mov    r13,QWORD PTR [rsp+0x40]
    140c:	mov    r14,QWORD PTR [rsp+0x48]
    1411:	mov    r15,QWORD PTR [rsp+0x50]
    1416:	add    rsp,0x60
    141a:	mov    rsp,rbp
    141d:	pop    rbp
    141e:	ret
    141f:	cmp    rax,0x6
    1423:	je     1438 <botlish_fn_17+0x1b9>
    1429:	add    r12,0x1
    1430:	mov    rdi,rbx
    1433:	jmp    12b4 <botlish_fn_17+0x35>
    1438:	mov    eax,0x6
    143d:	mov    rbx,QWORD PTR [rsp+0x30]
    1442:	mov    r12,QWORD PTR [rsp+0x38]
    1447:	mov    r13,QWORD PTR [rsp+0x40]
    144c:	mov    r14,QWORD PTR [rsp+0x48]
    1451:	mov    r15,QWORD PTR [rsp+0x50]
    1456:	add    rsp,0x60
    145a:	mov    rsp,rbp
    145d:	pop    rbp
    145e:	ret
    145f:	mov    eax,0x2
    1464:	mov    rbx,QWORD PTR [rsp+0x30]
    1469:	mov    r12,QWORD PTR [rsp+0x38]
    146e:	mov    r13,QWORD PTR [rsp+0x40]
    1473:	mov    r14,QWORD PTR [rsp+0x48]
    1478:	mov    r15,QWORD PTR [rsp+0x50]
    147d:	add    rsp,0x60
    1481:	mov    rsp,rbp
    1484:	pop    rbp
    1485:	ret

0000000000001486 <botlish_entry_17: domain?<int>>:
    1486:	push   rbp
    1487:	mov    rbp,rsp
    148a:	mov    rsi,QWORD PTR [rdx]
    148d:	mov    r8,QWORD PTR [rdx+0x8]
    1491:	mov    rcx,QWORD PTR [rdx+0x10]
    1495:	sar    rsi,1
    1498:	mov    rdx,r8
    149b:	call   14a0 <botlish_entry_17+0x1a>
			149c: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<int>
    14a0:	mov    rsp,rbp
    14a3:	pop    rbp
    14a4:	ret

00000000000014a5 <botlish_fn_18: web::is_unreserved<int>>:
    14a5:	push   rbp
    14a6:	mov    rbp,rsp
    14a9:	sub    rsp,0x10
    14ad:	mov    QWORD PTR [rsp],rbx
    14b1:	mov    QWORD PTR [rsp+0x8],r14
    14b6:	mov    r14,rsi
    14b9:	mov    rsi,r14
    14bc:	sar    rsi,1
    14bf:	mov    rbx,rdi
    14c2:	call   14c7 <botlish_fn_18+0x22>
			14c3: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphanumeric<int>
    14c7:	cmp    rax,0x6
    14cb:	je     1502 <botlish_fn_18+0x5d>
    14d1:	mov    rax,QWORD PTR [rbx+0x30]
    14d5:	mov    rsi,QWORD PTR [rax+0x10]
    14d9:	mov    rdx,r14
    14dc:	mov    rdi,rbx
    14df:	call   14e4 <botlish_fn_18+0x3f>
			14e0: R_X86_64_PLT32	rt_set_contains-0x4
    14e4:	cmp    rax,0x6
    14e8:	je     14f8 <botlish_fn_18+0x53>
    14ee:	mov    eax,0x2
    14f3:	jmp    1507 <botlish_fn_18+0x62>
    14f8:	mov    eax,0x6
    14fd:	jmp    1507 <botlish_fn_18+0x62>
    1502:	mov    eax,0x6
    1507:	mov    rbx,QWORD PTR [rsp]
    150b:	mov    r14,QWORD PTR [rsp+0x8]
    1510:	add    rsp,0x10
    1514:	mov    rsp,rbp
    1517:	pop    rbp
    1518:	ret

0000000000001519 <botlish_entry_18: web::is_unreserved<int>>:
    1519:	push   rbp
    151a:	mov    rbp,rsp
    151d:	mov    rsi,QWORD PTR [rdx]
    1520:	call   1525 <botlish_entry_18+0xc>
			1521: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1525:	mov    rsp,rbp
    1528:	pop    rbp
    1529:	ret

000000000000152a <botlish_fn_19: web::uri_query_value?<str>>:
    152a:	push   rbp
    152b:	mov    rbp,rsp
    152e:	sub    rsp,0x10
    1532:	mov    QWORD PTR [rsp],rsi
    1536:	mov    rdx,rsi
    1539:	mov    esi,0x1
    153e:	mov    QWORD PTR [rsp+0x8],0x1
    1547:	call   154c <botlish_fn_19+0x22>
			1548: R_X86_64_PLT32	botlish_fn_21-0x4 ; valid_from?<int>
    154c:	add    rsp,0x10
    1550:	mov    rsp,rbp
    1553:	pop    rbp
    1554:	ret

0000000000001555 <botlish_entry_19: web::uri_query_value?<str>>:
    1555:	push   rbp
    1556:	mov    rbp,rsp
    1559:	mov    rsi,QWORD PTR [rdx]
    155c:	call   1561 <botlish_entry_19+0xc>
			155d: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_query_value?<str>
    1561:	mov    rsp,rbp
    1564:	pop    rbp
    1565:	ret
	...

0000000000001568 <botlish_fn_20: upper_hex?<int>>:
    1568:	push   rbp
    1569:	mov    rbp,rsp
    156c:	sub    rsp,0x20
    1570:	mov    QWORD PTR [rsp],rbx
    1574:	mov    QWORD PTR [rsp+0x8],r12
    1579:	mov    QWORD PTR [rsp+0x10],r13
    157e:	mov    rbx,rdi
    1581:	mov    r13,rdx
    1584:	mov    rdx,r13
    1587:	mov    rdx,QWORD PTR [rdx+0x8]
    158b:	shl    rdx,1
    158e:	mov    rax,rdx
    1591:	or     rax,0x1
    1595:	mov    rcx,rsi
    1598:	and    rcx,rax
    159b:	test   rcx,0x1
    15a2:	jne    15cf <botlish_fn_20+0x67>
    15a8:	or     rdx,0x1
    15ac:	mov    r12,rsi
    15af:	mov    rdi,rbx
    15b2:	call   15b7 <botlish_fn_20+0x4f>
			15b3: R_X86_64_PLT32	rt_int_cmp-0x4
    15b7:	mov    ecx,0x2
    15bc:	test   rax,rax
    15bf:	cmovge rcx,QWORD PTR [rip+0x169]        # 1730 <botlish_fn_20+0x1c8>
    15c7:	mov    rsi,r12
    15ca:	jmp    15e6 <botlish_fn_20+0x7e>
    15cf:	mov    r12,rsi
    15d2:	or     rdx,0x1
    15d6:	mov    ecx,0x2
    15db:	cmp    r12,rdx
    15de:	cmovge rcx,QWORD PTR [rip+0x14a]        # 1730 <botlish_fn_20+0x1c8>
    15e6:	mov    eax,0x6
    15eb:	mov    r12,rax
    15ee:	cmp    rcx,0x6
    15f2:	je     1602 <botlish_fn_20+0x9a>
    15f8:	mov    eax,0x2
    15fd:	jmp    1605 <botlish_fn_20+0x9d>
    1602:	mov    rax,r12
    1605:	cmp    rax,0x6
    1609:	je     1712 <botlish_fn_20+0x1aa>
    160f:	mov    rdx,r13
    1612:	movzx  rax,BYTE PTR [rdx+0x18]
    1617:	test   rax,rax
    161a:	jne    1633 <botlish_fn_20+0xcb>
    1620:	mov    rdx,rsi
    1623:	mov    rsi,r13
    1626:	mov    rdi,rbx
    1629:	call   162e <botlish_fn_20+0xc6>
			162a: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    162e:	jmp    164a <botlish_fn_20+0xe2>
    1633:	mov    rdx,rsi
    1636:	mov    rsi,r13
    1639:	sar    rdx,1
    163c:	movzx  rax,BYTE PTR [rsi+rdx*1+0x19]
    1642:	shl    rax,0x3
    1646:	or     rax,0x4
    164a:	mov    rdx,rax
    164d:	shr    rdx,0x3
    1651:	shl    rdx,1
    1654:	or     rdx,0x1
    1658:	mov    ecx,0x2
    165d:	cmp    rdx,0xff
    1664:	cmovle rcx,QWORD PTR [rip+0xc4]        # 1730 <botlish_fn_20+0x1c8>
    166c:	cmp    rcx,0x6
    1670:	je     1683 <botlish_fn_20+0x11b>
    1676:	mov    eax,0x2
    167b:	mov    r12,rax
    167e:	jmp    1717 <botlish_fn_20+0x1af>
    1683:	shr    rax,0x3
    1687:	shl    rax,1
    168a:	or     rax,0x1
    168e:	sar    rax,1
    1691:	mov    rdi,rbx
    1694:	mov    r13,rax
    1697:	mov    rsi,r13
    169a:	call   169f <botlish_fn_20+0x137>
			169b: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<int>
    169f:	cmp    rax,0x6
    16a3:	je     16f3 <botlish_fn_20+0x18b>
    16a9:	mov    rax,r13
    16ac:	cmp    rax,0x41
    16b0:	jge    16c0 <botlish_fn_20+0x158>
    16b6:	mov    esi,0x2
    16bb:	jmp    16d7 <botlish_fn_20+0x16f>
    16c0:	cmp    rax,0x46
    16c4:	jle    16d4 <botlish_fn_20+0x16c>
    16ca:	mov    esi,0x2
    16cf:	jmp    16d7 <botlish_fn_20+0x16f>
    16d4:	mov    rsi,r12
    16d7:	cmp    rsi,0x6
    16db:	je     16eb <botlish_fn_20+0x183>
    16e1:	mov    eax,0x2
    16e6:	jmp    16f6 <botlish_fn_20+0x18e>
    16eb:	mov    rax,r12
    16ee:	jmp    16f6 <botlish_fn_20+0x18e>
    16f3:	mov    rax,r12
    16f6:	cmp    rax,0x6
    16fa:	je     170a <botlish_fn_20+0x1a2>
    1700:	mov    eax,0x2
    1705:	jmp    1717 <botlish_fn_20+0x1af>
    170a:	mov    rax,r12
    170d:	jmp    1717 <botlish_fn_20+0x1af>
    1712:	mov    eax,0x2
    1717:	mov    rbx,QWORD PTR [rsp]
    171b:	mov    r12,QWORD PTR [rsp+0x8]
    1720:	mov    r13,QWORD PTR [rsp+0x10]
    1725:	add    rsp,0x20
    1729:	mov    rsp,rbp
    172c:	pop    rbp
    172d:	ret
    172e:	add    BYTE PTR [rax],al
    1730:	(bad)
    1731:	add    BYTE PTR [rax],al
    1733:	add    BYTE PTR [rax],al
    1735:	add    BYTE PTR [rax],al
	...

0000000000001738 <botlish_entry_20: upper_hex?<int>>:
    1738:	push   rbp
    1739:	mov    rbp,rsp
    173c:	mov    rsi,QWORD PTR [rdx]
    173f:	mov    rdx,QWORD PTR [rdx+0x8]
    1743:	call   1748 <botlish_entry_20+0x10>
			1744: R_X86_64_PLT32	botlish_fn_20-0x4 ; upper_hex?<int>
    1748:	mov    rsp,rbp
    174b:	pop    rbp
    174c:	ret
    174d:	add    BYTE PTR [rax],al
	...

0000000000001750 <botlish_fn_21: valid_from?<int>>:
    1750:	push   rbp
    1751:	mov    rbp,rsp
    1754:	sub    rsp,0x40
    1758:	mov    QWORD PTR [rsp+0x20],r12
    175d:	mov    QWORD PTR [rsp+0x28],r13
    1762:	mov    QWORD PTR [rsp+0x30],r14
    1767:	mov    r13,rdi
    176a:	mov    QWORD PTR [rsp],rsi
    176e:	mov    r14,rsi
    1771:	mov    QWORD PTR [rsp+0x8],rdx
    1776:	mov    r12,rdx
    1779:	mov    rdx,QWORD PTR [r12+0x8]
    177e:	shl    rdx,1
    1781:	or     rdx,0x1
    1785:	mov    rsi,r14
    1788:	mov    r8,rsi
    178b:	and    r8,rdx
    178e:	test   r8,0x1
    1795:	jne    17bb <botlish_fn_21+0x6b>
    179b:	mov    rsi,r14
    179e:	mov    rdi,r13
    17a1:	call   17a6 <botlish_fn_21+0x56>
			17a2: R_X86_64_PLT32	rt_int_cmp-0x4
    17a6:	mov    ecx,0x2
    17ab:	test   rax,rax
    17ae:	cmovge rcx,QWORD PTR [rip+0x2b2]        # 1a68 <botlish_fn_21+0x318>
    17b6:	jmp    17ce <botlish_fn_21+0x7e>
    17bb:	mov    ecx,0x2
    17c0:	mov    rsi,r14
    17c3:	cmp    rsi,rdx
    17c6:	cmovge rcx,QWORD PTR [rip+0x29a]        # 1a68 <botlish_fn_21+0x318>
    17ce:	cmp    rcx,0x6
    17d2:	je     17e2 <botlish_fn_21+0x92>
    17d8:	mov    ecx,0x2
    17dd:	jmp    17e7 <botlish_fn_21+0x97>
    17e2:	mov    ecx,0x6
    17e7:	cmp    rcx,0x6
    17eb:	je     1a48 <botlish_fn_21+0x2f8>
    17f1:	movzx  rax,BYTE PTR [r12+0x18]
    17f7:	test   rax,rax
    17fa:	jne    1816 <botlish_fn_21+0xc6>
    1800:	mov    rdx,r14
    1803:	mov    rsi,r12
    1806:	mov    rdi,r13
    1809:	call   180e <botlish_fn_21+0xbe>
			180a: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    180e:	mov    rsi,rax
    1811:	jmp    182d <botlish_fn_21+0xdd>
    1816:	mov    rsi,r14
    1819:	mov    rax,rsi
    181c:	sar    rax,1
    181f:	movzx  rsi,BYTE PTR [r12+rax*1+0x19]
    1825:	shl    rsi,0x3
    1829:	or     rsi,0x4
    182d:	cmp    rsi,0x12c
    1834:	je     1903 <botlish_fn_21+0x1b3>
    183a:	mov    rcx,rsi
    183d:	shr    rcx,0x3
    1841:	shl    rcx,1
    1844:	or     rcx,0x1
    1848:	mov    edx,0x2
    184d:	cmp    rcx,0xff
    1854:	cmovle rdx,QWORD PTR [rip+0x20c]        # 1a68 <botlish_fn_21+0x318>
    185c:	cmp    rdx,0x6
    1860:	je     1870 <botlish_fn_21+0x120>
    1866:	mov    ecx,0x2
    186b:	jmp    189c <botlish_fn_21+0x14c>
    1870:	shr    rsi,0x3
    1874:	shl    rsi,1
    1877:	or     rsi,0x1
    187b:	mov    rdi,r13
    187e:	call   1883 <botlish_fn_21+0x133>
			187f: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1883:	cmp    rax,0x6
    1887:	je     1897 <botlish_fn_21+0x147>
    188d:	mov    ecx,0x2
    1892:	jmp    189c <botlish_fn_21+0x14c>
    1897:	mov    ecx,0x6
    189c:	cmp    rcx,0x6
    18a0:	jne    19ce <botlish_fn_21+0x27e>
    18a6:	mov    QWORD PTR [rsp+0x10],0x3
    18af:	mov    rsi,r14
    18b2:	test   rsi,0x1
    18b9:	je     18df <botlish_fn_21+0x18f>
    18bf:	mov    rsi,r14
    18c2:	mov    rcx,rsi
    18c5:	add    rcx,0x2
    18c9:	seto   al
    18cc:	test   al,al
    18ce:	jne    18df <botlish_fn_21+0x18f>
    18d4:	mov    rsi,rcx
    18d7:	mov    r14,rcx
    18da:	jmp    18f5 <botlish_fn_21+0x1a5>
    18df:	mov    edx,0x3
    18e4:	mov    rsi,r14
    18e7:	mov    rdi,r13
    18ea:	call   18ef <botlish_fn_21+0x19f>
			18eb: R_X86_64_PLT32	rt_int_add-0x4
    18ef:	mov    rsi,rax
    18f2:	mov    r14,rax
    18f5:	mov    QWORD PTR [rsp],rsi
    18f9:	mov    QWORD PTR [rsp+0x8],r12
    18fe:	jmp    1779 <botlish_fn_21+0x29>
    1903:	mov    QWORD PTR [rsp+0x10],0x3
    190c:	mov    rsi,r14
    190f:	test   rsi,0x1
    1916:	je     192e <botlish_fn_21+0x1de>
    191c:	mov    rsi,r14
    191f:	add    rsi,0x2
    1923:	seto   al
    1926:	test   al,al
    1928:	je     1941 <botlish_fn_21+0x1f1>
    192e:	mov    edx,0x3
    1933:	mov    rsi,r14
    1936:	mov    rdi,r13
    1939:	call   193e <botlish_fn_21+0x1ee>
			193a: R_X86_64_PLT32	rt_int_add-0x4
    193e:	mov    rsi,rax
    1941:	mov    rdx,r12
    1944:	mov    rdi,r13
    1947:	call   194c <botlish_fn_21+0x1fc>
			1948: R_X86_64_PLT32	botlish_fn_20-0x4 ; upper_hex?<int>
    194c:	cmp    rax,0x6
    1950:	je     1960 <botlish_fn_21+0x210>
    1956:	mov    ecx,0x2
    195b:	jmp    19c4 <botlish_fn_21+0x274>
    1960:	mov    QWORD PTR [rsp+0x10],0x5
    1969:	mov    rsi,r14
    196c:	test   rsi,0x1
    1973:	je     198d <botlish_fn_21+0x23d>
    1979:	mov    rsi,r14
    197c:	add    rsi,0x4
    1980:	seto   r8b
    1984:	test   r8b,r8b
    1987:	je     19a0 <botlish_fn_21+0x250>
    198d:	mov    edx,0x5
    1992:	mov    rsi,r14
    1995:	mov    rdi,r13
    1998:	call   199d <botlish_fn_21+0x24d>
			1999: R_X86_64_PLT32	rt_int_add-0x4
    199d:	mov    rsi,rax
    19a0:	mov    rdx,r12
    19a3:	mov    rdi,r13
    19a6:	call   19ab <botlish_fn_21+0x25b>
			19a7: R_X86_64_PLT32	botlish_fn_20-0x4 ; upper_hex?<int>
    19ab:	cmp    rax,0x6
    19af:	je     19bf <botlish_fn_21+0x26f>
    19b5:	mov    ecx,0x2
    19ba:	jmp    19c4 <botlish_fn_21+0x274>
    19bf:	mov    ecx,0x6
    19c4:	cmp    rcx,0x6
    19c8:	je     19eb <botlish_fn_21+0x29b>
    19ce:	mov    eax,0x2
    19d3:	mov    r12,QWORD PTR [rsp+0x20]
    19d8:	mov    r13,QWORD PTR [rsp+0x28]
    19dd:	mov    r14,QWORD PTR [rsp+0x30]
    19e2:	add    rsp,0x40
    19e6:	mov    rsp,rbp
    19e9:	pop    rbp
    19ea:	ret
    19eb:	mov    QWORD PTR [rsp+0x10],0x7
    19f4:	mov    rsi,r14
    19f7:	test   rsi,0x1
    19fe:	je     1a24 <botlish_fn_21+0x2d4>
    1a04:	mov    rsi,r14
    1a07:	mov    rcx,rsi
    1a0a:	add    rcx,0x6
    1a0e:	seto   al
    1a11:	test   al,al
    1a13:	jne    1a24 <botlish_fn_21+0x2d4>
    1a19:	mov    rsi,rcx
    1a1c:	mov    r14,rcx
    1a1f:	jmp    1a3a <botlish_fn_21+0x2ea>
    1a24:	mov    edx,0x7
    1a29:	mov    rsi,r14
    1a2c:	mov    rdi,r13
    1a2f:	call   1a34 <botlish_fn_21+0x2e4>
			1a30: R_X86_64_PLT32	rt_int_add-0x4
    1a34:	mov    rsi,rax
    1a37:	mov    r14,rax
    1a3a:	mov    QWORD PTR [rsp],rsi
    1a3e:	mov    QWORD PTR [rsp+0x8],r12
    1a43:	jmp    1779 <botlish_fn_21+0x29>
    1a48:	mov    eax,0x6
    1a4d:	mov    r12,QWORD PTR [rsp+0x20]
    1a52:	mov    r13,QWORD PTR [rsp+0x28]
    1a57:	mov    r14,QWORD PTR [rsp+0x30]
    1a5c:	add    rsp,0x40
    1a60:	mov    rsp,rbp
    1a63:	pop    rbp
    1a64:	ret
    1a65:	add    BYTE PTR [rax],al
    1a67:	add    BYTE PTR [rsi],al
    1a69:	add    BYTE PTR [rax],al
    1a6b:	add    BYTE PTR [rax],al
    1a6d:	add    BYTE PTR [rax],al
	...

0000000000001a70 <botlish_entry_21: valid_from?<int>>:
    1a70:	push   rbp
    1a71:	mov    rbp,rsp
    1a74:	mov    rsi,QWORD PTR [rdx]
    1a77:	mov    rdx,QWORD PTR [rdx+0x8]
    1a7b:	call   1a80 <botlish_entry_21+0x10>
			1a7c: R_X86_64_PLT32	botlish_fn_21-0x4 ; valid_from?<int>
    1a80:	mov    rsp,rbp
    1a83:	pop    rbp
    1a84:	ret

0000000000001a85 <botlish_fn_22: web::uri_escape_text<str>>:
    1a85:	push   rbp
    1a86:	mov    rbp,rsp
    1a89:	sub    rsp,0x10
    1a8d:	mov    edx,0x1
    1a92:	mov    QWORD PTR [rsp],0x1
    1a9a:	mov    r10,QWORD PTR [rdi+0x10]
    1a9e:	mov    rcx,QWORD PTR [r10+0xc8]
    1aa5:	mov    QWORD PTR [rsp+0x8],rcx
    1aaa:	call   1aaf <botlish_fn_22+0x2a>
			1aab: R_X86_64_PLT32	botlish_fn_28-0x4 ; esc_from<str, int, str>
    1aaf:	test   rax,rax
    1ab2:	jne    1ac4 <botlish_fn_22+0x3f>
    1ab8:	xor    rax,rax
    1abb:	add    rsp,0x10
    1abf:	mov    rsp,rbp
    1ac2:	pop    rbp
    1ac3:	ret
    1ac4:	add    rsp,0x10
    1ac8:	mov    rsp,rbp
    1acb:	pop    rbp
    1acc:	ret

0000000000001acd <botlish_entry_22: web::uri_escape_text<str>>:
    1acd:	push   rbp
    1ace:	mov    rbp,rsp
    1ad1:	sub    rsp,0x10
    1ad5:	mov    QWORD PTR [rsp],r12
    1ad9:	mov    r12,rdi
    1adc:	mov    rsi,QWORD PTR [rdx]
    1adf:	mov    r8,QWORD PTR [rip+0x0]        # 1ae6 <botlish_entry_22+0x19>
			1ae2: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    1ae6:	call   r8
    1ae9:	mov    rsi,rax
    1aec:	mov    rdi,r12
    1aef:	call   1af4 <botlish_entry_22+0x27>
			1af0: R_X86_64_PLT32	botlish_fn_22-0x4 ; web::uri_escape_text<str>
    1af4:	mov    r12,QWORD PTR [rsp]
    1af8:	add    rsp,0x10
    1afc:	mov    rsp,rbp
    1aff:	pop    rbp
    1b00:	ret

0000000000001b01 <botlish_fn_23: high_nibble<int>>:
    1b01:	push   rbp
    1b02:	mov    rbp,rsp
    1b05:	sub    rsp,0x10
    1b09:	mov    QWORD PTR [rsp],rsi
    1b0d:	mov    QWORD PTR [rsp+0x8],0x1e1
    1b16:	test   rsi,0x1
    1b1d:	jne    1b32 <botlish_fn_23+0x31>
    1b23:	mov    edx,0x1e1
    1b28:	call   1b2d <botlish_fn_23+0x2c>
			1b29: R_X86_64_PLT32	rt_int_and-0x4
    1b2d:	jmp    1b3c <botlish_fn_23+0x3b>
    1b32:	and    rsi,0x1e1
    1b39:	mov    rax,rsi
    1b3c:	sar    rax,0x5
    1b40:	shl    rax,1
    1b43:	or     rax,0x1
    1b47:	add    rsp,0x10
    1b4b:	mov    rsp,rbp
    1b4e:	pop    rbp
    1b4f:	ret

0000000000001b50 <botlish_entry_23: high_nibble<int>>:
    1b50:	push   rbp
    1b51:	mov    rbp,rsp
    1b54:	mov    rsi,QWORD PTR [rdx]
    1b57:	call   1b5c <botlish_entry_23+0xc>
			1b58: R_X86_64_PLT32	botlish_fn_23-0x4 ; high_nibble<int>
    1b5c:	mov    rsp,rbp
    1b5f:	pop    rbp
    1b60:	ret

0000000000001b61 <botlish_fn_24: hex_pair<int>>:
    1b61:	push   rbp
    1b62:	mov    rbp,rsp
    1b65:	sub    rsp,0x50
    1b69:	mov    QWORD PTR [rsp+0x30],rbx
    1b6e:	mov    QWORD PTR [rsp+0x38],r12
    1b73:	mov    QWORD PTR [rsp+0x40],r13
    1b78:	mov    QWORD PTR [rsp+0x48],r14
    1b7d:	mov    QWORD PTR [rsp],rsi
    1b81:	mov    r14,rsi
    1b84:	mov    rax,QWORD PTR [rdi+0x30]
    1b88:	mov    r13,rdi
    1b8b:	mov    rbx,QWORD PTR [rax+0x8]
    1b8f:	mov    QWORD PTR [rsp+0x8],rbx
    1b94:	mov    rsi,r14
    1b97:	call   1b9c <botlish_fn_24+0x3b>
			1b98: R_X86_64_PLT32	botlish_fn_23-0x4 ; high_nibble<int>
    1b9c:	mov    rcx,QWORD PTR [rbx+0x10]
    1ba0:	sar    rax,1
    1ba3:	mov    r12,QWORD PTR [rcx+rax*8]
    1ba7:	mov    QWORD PTR [rsp],r12
    1bab:	mov    rdi,r13
    1bae:	mov    rax,QWORD PTR [rdi+0x30]
    1bb2:	mov    rbx,QWORD PTR [rax+0x8]
    1bb6:	mov    edx,0x21
    1bbb:	mov    rsi,r14
    1bbe:	call   1bc3 <botlish_fn_24+0x62>
			1bbf: R_X86_64_PLT32	rt_int_mod-0x4
    1bc3:	test   rax,rax
    1bc6:	je     1c18 <botlish_fn_24+0xb7>
    1bcc:	mov    rcx,QWORD PTR [rbx+0x10]
    1bd0:	sar    rax,1
    1bd3:	mov    rdx,QWORD PTR [rcx+rax*8]
    1bd7:	mov    QWORD PTR [rsp+0x8],rdx
    1bdc:	lea    rcx,[rsp+0x10]
    1be1:	mov    QWORD PTR [rsp+0x10],0x0
    1bea:	mov    QWORD PTR [rsp+0x18],r12
    1bef:	mov    QWORD PTR [rsp+0x20],0x0
    1bf8:	mov    QWORD PTR [rsp+0x28],rdx
    1bfd:	mov    esi,0x2
    1c02:	mov    edx,0x4
    1c07:	mov    rdi,r13
    1c0a:	call   1c0f <botlish_fn_24+0xae>
			1c0b: R_X86_64_PLT32	rt_construct-0x4
    1c0f:	test   rax,rax
    1c12:	jne    1c38 <botlish_fn_24+0xd7>
    1c18:	xor    rax,rax
    1c1b:	mov    rbx,QWORD PTR [rsp+0x30]
    1c20:	mov    r12,QWORD PTR [rsp+0x38]
    1c25:	mov    r13,QWORD PTR [rsp+0x40]
    1c2a:	mov    r14,QWORD PTR [rsp+0x48]
    1c2f:	add    rsp,0x50
    1c33:	mov    rsp,rbp
    1c36:	pop    rbp
    1c37:	ret
    1c38:	mov    rbx,QWORD PTR [rsp+0x30]
    1c3d:	mov    r12,QWORD PTR [rsp+0x38]
    1c42:	mov    r13,QWORD PTR [rsp+0x40]
    1c47:	mov    r14,QWORD PTR [rsp+0x48]
    1c4c:	add    rsp,0x50
    1c50:	mov    rsp,rbp
    1c53:	pop    rbp
    1c54:	ret

0000000000001c55 <botlish_entry_24: hex_pair<int>>:
    1c55:	push   rbp
    1c56:	mov    rbp,rsp
    1c59:	sub    rsp,0x10
    1c5d:	mov    QWORD PTR [rsp],r12
    1c61:	mov    r12,rdi
    1c64:	mov    rsi,QWORD PTR [rdx]
    1c67:	call   1c6c <botlish_entry_24+0x17>
			1c68: R_X86_64_PLT32	botlish_fn_24-0x4 ; hex_pair<int>
    1c6c:	mov    r8,QWORD PTR [rip+0x0]        # 1c73 <botlish_entry_24+0x1e>
			1c6f: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1c73:	mov    rsi,rax
    1c76:	mov    rdi,r12
    1c79:	call   r8
    1c7c:	mov    r12,QWORD PTR [rsp]
    1c80:	add    rsp,0x10
    1c84:	mov    rsp,rbp
    1c87:	pop    rbp
    1c88:	ret

0000000000001c89 <botlish_fn_25: pct<int>>:
    1c89:	push   rbp
    1c8a:	mov    rbp,rsp
    1c8d:	sub    rsp,0x40
    1c91:	mov    QWORD PTR [rsp+0x30],r12
    1c96:	mov    QWORD PTR [rsp+0x38],r13
    1c9b:	mov    QWORD PTR [rsp],rsi
    1c9f:	mov    rax,QWORD PTR [rdi+0x10]
    1ca3:	mov    r12,rdi
    1ca6:	mov    r13,QWORD PTR [rax+0x10]
    1caa:	mov    QWORD PTR [rsp+0x8],r13
    1caf:	call   1cb4 <botlish_fn_25+0x2b>
			1cb0: R_X86_64_PLT32	botlish_fn_24-0x4 ; hex_pair<int>
    1cb4:	test   rax,rax
    1cb7:	je     1cfd <botlish_fn_25+0x74>
    1cbd:	mov    QWORD PTR [rsp],rax
    1cc1:	lea    rcx,[rsp+0x10]
    1cc6:	mov    QWORD PTR [rsp+0x10],0x0
    1ccf:	mov    QWORD PTR [rsp+0x18],r13
    1cd4:	mov    QWORD PTR [rsp+0x20],0x0
    1cdd:	mov    QWORD PTR [rsp+0x28],rax
    1ce2:	mov    esi,0x2
    1ce7:	mov    edx,0x4
    1cec:	mov    rdi,r12
    1cef:	call   1cf4 <botlish_fn_25+0x6b>
			1cf0: R_X86_64_PLT32	rt_construct-0x4
    1cf4:	test   rax,rax
    1cf7:	jne    1d13 <botlish_fn_25+0x8a>
    1cfd:	xor    rax,rax
    1d00:	mov    r12,QWORD PTR [rsp+0x30]
    1d05:	mov    r13,QWORD PTR [rsp+0x38]
    1d0a:	add    rsp,0x40
    1d0e:	mov    rsp,rbp
    1d11:	pop    rbp
    1d12:	ret
    1d13:	mov    r12,QWORD PTR [rsp+0x30]
    1d18:	mov    r13,QWORD PTR [rsp+0x38]
    1d1d:	add    rsp,0x40
    1d21:	mov    rsp,rbp
    1d24:	pop    rbp
    1d25:	ret

0000000000001d26 <botlish_entry_25: pct<int>>:
    1d26:	push   rbp
    1d27:	mov    rbp,rsp
    1d2a:	sub    rsp,0x10
    1d2e:	mov    QWORD PTR [rsp],r12
    1d32:	mov    r12,rdi
    1d35:	mov    rsi,QWORD PTR [rdx]
    1d38:	call   1d3d <botlish_entry_25+0x17>
			1d39: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1d3d:	mov    r8,QWORD PTR [rip+0x0]        # 1d44 <botlish_entry_25+0x1e>
			1d40: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1d44:	mov    rsi,rax
    1d47:	mov    rdi,r12
    1d4a:	call   r8
    1d4d:	mov    r12,QWORD PTR [rsp]
    1d51:	add    rsp,0x10
    1d55:	mov    rsp,rbp
    1d58:	pop    rbp
    1d59:	ret

0000000000001d5a <botlish_fn_26: cont<int, int>>:
    1d5a:	push   rbp
    1d5b:	mov    rbp,rsp
    1d5e:	sub    rsp,0x30
    1d62:	mov    QWORD PTR [rsp+0x20],rbx
    1d67:	mov    rbx,rdi
    1d6a:	mov    QWORD PTR [rsp],rsi
    1d6e:	mov    QWORD PTR [rsp+0x8],rdx
    1d73:	mov    QWORD PTR [rsp+0x10],0x101
    1d7c:	mov    rdi,rbx
    1d7f:	call   1d84 <botlish_fn_26+0x2a>
			1d80: R_X86_64_PLT32	rt_int_shr-0x4
    1d84:	test   rax,rax
    1d87:	je     1e0a <botlish_fn_26+0xb0>
    1d8d:	mov    QWORD PTR [rsp],rax
    1d91:	mov    QWORD PTR [rsp+0x8],0x7f
    1d9a:	test   rax,0x1
    1da0:	mov    rsi,rax
    1da3:	jne    1dbe <botlish_fn_26+0x64>
    1da9:	mov    edx,0x7f
    1dae:	mov    rdi,rbx
    1db1:	call   1db6 <botlish_fn_26+0x5c>
			1db2: R_X86_64_PLT32	rt_int_and-0x4
    1db6:	mov    rdx,rax
    1db9:	jmp    1dc5 <botlish_fn_26+0x6b>
    1dbe:	mov    rdx,rsi
    1dc1:	and    rdx,0x7f
    1dc5:	mov    QWORD PTR [rsp],rdx
    1dc9:	test   rdx,0x1
    1dd0:	jne    1deb <botlish_fn_26+0x91>
    1dd6:	mov    esi,0x101
    1ddb:	mov    rdi,rbx
    1dde:	call   1de3 <botlish_fn_26+0x89>
			1ddf: R_X86_64_PLT32	rt_int_or-0x4
    1de3:	mov    rsi,rax
    1de6:	jmp    1df5 <botlish_fn_26+0x9b>
    1deb:	or     rdx,0x101
    1df2:	mov    rsi,rdx
    1df5:	mov    QWORD PTR [rsp],rsi
    1df9:	mov    rdi,rbx
    1dfc:	call   1e01 <botlish_fn_26+0xa7>
			1dfd: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1e01:	test   rax,rax
    1e04:	jne    1e1b <botlish_fn_26+0xc1>
    1e0a:	xor    rax,rax
    1e0d:	mov    rbx,QWORD PTR [rsp+0x20]
    1e12:	add    rsp,0x30
    1e16:	mov    rsp,rbp
    1e19:	pop    rbp
    1e1a:	ret
    1e1b:	mov    rbx,QWORD PTR [rsp+0x20]
    1e20:	add    rsp,0x30
    1e24:	mov    rsp,rbp
    1e27:	pop    rbp
    1e28:	ret

0000000000001e29 <botlish_entry_26: cont<int, int>>:
    1e29:	push   rbp
    1e2a:	mov    rbp,rsp
    1e2d:	sub    rsp,0x10
    1e31:	mov    QWORD PTR [rsp],r12
    1e35:	mov    r12,rdi
    1e38:	mov    rsi,QWORD PTR [rdx]
    1e3b:	mov    rdx,QWORD PTR [rdx+0x8]
    1e3f:	call   1e44 <botlish_entry_26+0x1b>
			1e40: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1e44:	mov    r8,QWORD PTR [rip+0x0]        # 1e4b <botlish_entry_26+0x22>
			1e47: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1e4b:	mov    rsi,rax
    1e4e:	mov    rdi,r12
    1e51:	call   r8
    1e54:	mov    r12,QWORD PTR [rsp]
    1e58:	add    rsp,0x10
    1e5c:	mov    rsp,rbp
    1e5f:	pop    rbp
    1e60:	ret
    1e61:	add    BYTE PTR [rax],al
    1e63:	add    BYTE PTR [rax],al
    1e65:	add    BYTE PTR [rax],al
	...

0000000000001e68 <botlish_fn_27: esc_scalar<int>>:
    1e68:	push   rbp
    1e69:	mov    rbp,rsp
    1e6c:	sub    rsp,0xf0
    1e73:	mov    QWORD PTR [rsp+0xc0],rbx
    1e7b:	mov    QWORD PTR [rsp+0xc8],r12
    1e83:	mov    QWORD PTR [rsp+0xd0],r13
    1e8b:	mov    QWORD PTR [rsp+0xd8],r14
    1e93:	mov    QWORD PTR [rsp+0xe0],r15
    1e9b:	mov    rbx,rdi
    1e9e:	mov    QWORD PTR [rsp+0x18],0x0
    1ea7:	mov    QWORD PTR [rsp+0x20],0x0
    1eb0:	mov    QWORD PTR [rsp],rsi
    1eb4:	test   rsi,0x1
    1ebb:	mov    r12,rsi
    1ebe:	jne    1eea <botlish_fn_27+0x82>
    1ec4:	mov    edx,0x1001
    1ec9:	mov    rsi,r12
    1ecc:	mov    rdi,rbx
    1ecf:	call   1ed4 <botlish_fn_27+0x6c>
			1ed0: R_X86_64_PLT32	rt_int_cmp-0x4
    1ed4:	mov    r11d,0x2
    1eda:	test   rax,rax
    1edd:	cmovl  r11,QWORD PTR [rip+0x3fb]        # 22e0 <botlish_fn_27+0x478>
    1ee5:	jmp    1f02 <botlish_fn_27+0x9a>
    1eea:	mov    r11d,0x2
    1ef0:	mov    rsi,r12
    1ef3:	cmp    rsi,0x1001
    1efa:	cmovl  r11,QWORD PTR [rip+0x3de]        # 22e0 <botlish_fn_27+0x478>
    1f02:	mov    edx,0x6
    1f07:	mov    r13,rdx
    1f0a:	cmp    r11,0x6
    1f0e:	je     21c8 <botlish_fn_27+0x360>
    1f14:	mov    rsi,r12
    1f17:	test   rsi,0x1
    1f1e:	jne    1f49 <botlish_fn_27+0xe1>
    1f24:	mov    edx,0x20001
    1f29:	mov    rsi,r12
    1f2c:	mov    rdi,rbx
    1f2f:	call   1f34 <botlish_fn_27+0xcc>
			1f30: R_X86_64_PLT32	rt_int_cmp-0x4
    1f34:	mov    ecx,0x2
    1f39:	test   rax,rax
    1f3c:	cmovl  rcx,QWORD PTR [rip+0x39c]        # 22e0 <botlish_fn_27+0x478>
    1f44:	jmp    1f60 <botlish_fn_27+0xf8>
    1f49:	mov    ecx,0x2
    1f4e:	mov    rsi,r12
    1f51:	cmp    rsi,0x20001
    1f58:	cmovl  rcx,QWORD PTR [rip+0x380]        # 22e0 <botlish_fn_27+0x478>
    1f60:	cmp    rcx,0x6
    1f64:	je     20db <botlish_fn_27+0x273>
    1f6a:	mov    QWORD PTR [rsp+0x8],0x1e1
    1f73:	mov    edx,0x25
    1f78:	mov    QWORD PTR [rsp+0x10],0x25
    1f81:	mov    rsi,r12
    1f84:	mov    rdi,rbx
    1f87:	call   1f8c <botlish_fn_27+0x124>
			1f88: R_X86_64_PLT32	rt_int_shr-0x4
    1f8c:	test   rax,rax
    1f8f:	je     2271 <botlish_fn_27+0x409>
    1f95:	mov    QWORD PTR [rsp+0x10],rax
    1f9a:	test   rax,0x1
    1fa0:	mov    rdx,rax
    1fa3:	jne    1fbe <botlish_fn_27+0x156>
    1fa9:	mov    esi,0x1e1
    1fae:	mov    rdi,rbx
    1fb1:	call   1fb6 <botlish_fn_27+0x14e>
			1fb2: R_X86_64_PLT32	rt_int_or-0x4
    1fb6:	mov    rsi,rax
    1fb9:	jmp    1fc8 <botlish_fn_27+0x160>
    1fbe:	mov    rsi,rdx
    1fc1:	or     rsi,0x1e1
    1fc8:	mov    QWORD PTR [rsp+0x8],rsi
    1fcd:	mov    rdi,rbx
    1fd0:	call   1fd5 <botlish_fn_27+0x16d>
			1fd1: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1fd5:	test   rax,rax
    1fd8:	je     2271 <botlish_fn_27+0x409>
    1fde:	mov    QWORD PTR [rsp+0x8],rax
    1fe3:	mov    r13,rax
    1fe6:	mov    edx,0x19
    1feb:	mov    QWORD PTR [rsp+0x10],0x19
    1ff4:	mov    rsi,r12
    1ff7:	mov    rdi,rbx
    1ffa:	call   1fff <botlish_fn_27+0x197>
			1ffb: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1fff:	test   rax,rax
    2002:	je     2271 <botlish_fn_27+0x409>
    2008:	mov    QWORD PTR [rsp+0x10],rax
    200d:	mov    r14,rax
    2010:	mov    edx,0xd
    2015:	mov    QWORD PTR [rsp+0x18],0xd
    201e:	mov    rsi,r12
    2021:	mov    rdi,rbx
    2024:	call   2029 <botlish_fn_27+0x1c1>
			2025: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    2029:	test   rax,rax
    202c:	je     2271 <botlish_fn_27+0x409>
    2032:	mov    QWORD PTR [rsp+0x18],rax
    2037:	mov    r15,rax
    203a:	mov    edx,0x1
    203f:	mov    QWORD PTR [rsp+0x20],0x1
    2048:	mov    rsi,r12
    204b:	mov    rdi,rbx
    204e:	call   2053 <botlish_fn_27+0x1eb>
			204f: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    2053:	test   rax,rax
    2056:	je     2271 <botlish_fn_27+0x409>
    205c:	mov    QWORD PTR [rsp],rax
    2060:	lea    rcx,[rsp+0x78]
    2065:	mov    QWORD PTR [rsp+0x78],0x0
    206e:	mov    rdx,r13
    2071:	mov    QWORD PTR [rsp+0x80],rdx
    2079:	mov    QWORD PTR [rsp+0x88],0x0
    2085:	mov    rdx,r14
    2088:	mov    QWORD PTR [rsp+0x90],rdx
    2090:	mov    QWORD PTR [rsp+0x98],0x0
    209c:	mov    rdx,r15
    209f:	mov    QWORD PTR [rsp+0xa0],rdx
    20a7:	mov    QWORD PTR [rsp+0xa8],0x0
    20b3:	mov    QWORD PTR [rsp+0xb0],rax
    20bb:	mov    esi,0x2
    20c0:	mov    edx,0x8
    20c5:	mov    rdi,rbx
    20c8:	call   20cd <botlish_fn_27+0x265>
			20c9: R_X86_64_PLT32	rt_construct-0x4
    20cd:	test   rax,rax
    20d0:	je     2271 <botlish_fn_27+0x409>
    20d6:	jmp    22a8 <botlish_fn_27+0x440>
    20db:	mov    QWORD PTR [rsp+0x8],0x1c1
    20e4:	mov    edx,0xd
    20e9:	mov    rsi,r12
    20ec:	mov    r14,rdx
    20ef:	sar    rsi,0xd
    20f3:	shl    rsi,1
    20f6:	mov    rax,rsi
    20f9:	or     rax,0x1
    20fd:	mov    QWORD PTR [rsp+0x10],rax
    2102:	or     rsi,0x1c1
    2109:	mov    QWORD PTR [rsp+0x8],rsi
    210e:	mov    rdi,rbx
    2111:	call   2116 <botlish_fn_27+0x2ae>
			2112: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    2116:	test   rax,rax
    2119:	je     2271 <botlish_fn_27+0x409>
    211f:	mov    QWORD PTR [rsp+0x8],rax
    2124:	mov    r15,rax
    2127:	mov    QWORD PTR [rsp+0x10],0xd
    2130:	mov    rdx,r14
    2133:	mov    rsi,r12
    2136:	mov    rdi,rbx
    2139:	call   213e <botlish_fn_27+0x2d6>
			213a: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    213e:	test   rax,rax
    2141:	je     2271 <botlish_fn_27+0x409>
    2147:	mov    QWORD PTR [rsp+0x10],rax
    214c:	mov    r14,rax
    214f:	mov    edx,0x1
    2154:	mov    QWORD PTR [rsp+0x18],0x1
    215d:	mov    rsi,r12
    2160:	mov    rdi,rbx
    2163:	call   2168 <botlish_fn_27+0x300>
			2164: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    2168:	test   rax,rax
    216b:	je     2271 <botlish_fn_27+0x409>
    2171:	mov    QWORD PTR [rsp],rax
    2175:	lea    rcx,[rsp+0x48]
    217a:	mov    QWORD PTR [rsp+0x48],0x0
    2183:	mov    rdx,r15
    2186:	mov    QWORD PTR [rsp+0x50],rdx
    218b:	mov    QWORD PTR [rsp+0x58],0x0
    2194:	mov    rdx,r14
    2197:	mov    QWORD PTR [rsp+0x60],rdx
    219c:	mov    QWORD PTR [rsp+0x68],0x0
    21a5:	mov    QWORD PTR [rsp+0x70],rax
    21aa:	mov    esi,0x2
    21af:	mov    rdx,r13
    21b2:	mov    rdi,rbx
    21b5:	call   21ba <botlish_fn_27+0x352>
			21b6: R_X86_64_PLT32	rt_construct-0x4
    21ba:	test   rax,rax
    21bd:	je     2271 <botlish_fn_27+0x409>
    21c3:	jmp    22a8 <botlish_fn_27+0x440>
    21c8:	mov    QWORD PTR [rsp+0x8],0x181
    21d1:	mov    rsi,r12
    21d4:	sar    rsi,0x7
    21d8:	shl    rsi,1
    21db:	mov    rax,rsi
    21de:	or     rax,0x1
    21e2:	mov    QWORD PTR [rsp+0x10],rax
    21e7:	or     rsi,0x181
    21ee:	mov    QWORD PTR [rsp+0x8],rsi
    21f3:	mov    rdi,rbx
    21f6:	call   21fb <botlish_fn_27+0x393>
			21f7: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    21fb:	test   rax,rax
    21fe:	je     2271 <botlish_fn_27+0x409>
    2204:	mov    QWORD PTR [rsp+0x8],rax
    2209:	mov    r13,rax
    220c:	mov    edx,0x1
    2211:	mov    QWORD PTR [rsp+0x10],0x1
    221a:	mov    rsi,r12
    221d:	mov    rdi,rbx
    2220:	call   2225 <botlish_fn_27+0x3bd>
			2221: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    2225:	test   rax,rax
    2228:	je     2271 <botlish_fn_27+0x409>
    222e:	mov    QWORD PTR [rsp],rax
    2232:	lea    rcx,[rsp+0x28]
    2237:	mov    QWORD PTR [rsp+0x28],0x0
    2240:	mov    rdx,r13
    2243:	mov    QWORD PTR [rsp+0x30],rdx
    2248:	mov    QWORD PTR [rsp+0x38],0x0
    2251:	mov    QWORD PTR [rsp+0x40],rax
    2256:	mov    esi,0x2
    225b:	mov    edx,0x4
    2260:	mov    rdi,rbx
    2263:	call   2268 <botlish_fn_27+0x400>
			2264: R_X86_64_PLT32	rt_construct-0x4
    2268:	test   rax,rax
    226b:	jne    22a8 <botlish_fn_27+0x440>
    2271:	xor    rax,rax
    2274:	mov    rbx,QWORD PTR [rsp+0xc0]
    227c:	mov    r12,QWORD PTR [rsp+0xc8]
    2284:	mov    r13,QWORD PTR [rsp+0xd0]
    228c:	mov    r14,QWORD PTR [rsp+0xd8]
    2294:	mov    r15,QWORD PTR [rsp+0xe0]
    229c:	add    rsp,0xf0
    22a3:	mov    rsp,rbp
    22a6:	pop    rbp
    22a7:	ret
    22a8:	mov    rbx,QWORD PTR [rsp+0xc0]
    22b0:	mov    r12,QWORD PTR [rsp+0xc8]
    22b8:	mov    r13,QWORD PTR [rsp+0xd0]
    22c0:	mov    r14,QWORD PTR [rsp+0xd8]
    22c8:	mov    r15,QWORD PTR [rsp+0xe0]
    22d0:	add    rsp,0xf0
    22d7:	mov    rsp,rbp
    22da:	pop    rbp
    22db:	ret
    22dc:	add    BYTE PTR [rax],al
    22de:	add    BYTE PTR [rax],al
    22e0:	(bad)
    22e1:	add    BYTE PTR [rax],al
    22e3:	add    BYTE PTR [rax],al
    22e5:	add    BYTE PTR [rax],al
	...

00000000000022e8 <botlish_entry_27: esc_scalar<int>>:
    22e8:	push   rbp
    22e9:	mov    rbp,rsp
    22ec:	sub    rsp,0x10
    22f0:	mov    QWORD PTR [rsp],r12
    22f4:	mov    r12,rdi
    22f7:	mov    rsi,QWORD PTR [rdx]
    22fa:	call   22ff <botlish_entry_27+0x17>
			22fb: R_X86_64_PLT32	botlish_fn_27-0x4 ; esc_scalar<int>
    22ff:	mov    r8,QWORD PTR [rip+0x0]        # 2306 <botlish_entry_27+0x1e>
			2302: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    2306:	mov    rsi,rax
    2309:	mov    rdi,r12
    230c:	call   r8
    230f:	mov    r12,QWORD PTR [rsp]
    2313:	add    rsp,0x10
    2317:	mov    rsp,rbp
    231a:	pop    rbp
    231b:	ret
    231c:	add    BYTE PTR [rax],al
	...

0000000000002320 <botlish_fn_28: esc_from<str, int, str>>:
    2320:	push   rbp
    2321:	mov    rbp,rsp
    2324:	sub    rsp,0x110
    232b:	mov    QWORD PTR [rsp+0xe0],rbx
    2333:	mov    QWORD PTR [rsp+0xe8],r12
    233b:	mov    QWORD PTR [rsp+0xf0],r13
    2343:	mov    QWORD PTR [rsp+0xf8],r14
    234b:	mov    QWORD PTR [rsp+0x100],r15
    2353:	mov    QWORD PTR [rsp+0xa8],rdi
    235b:	mov    QWORD PTR [rsp+0x10],0x0
    2364:	mov    QWORD PTR [rsp+0x18],0x0
    236d:	mov    QWORD PTR [rsp+0x20],0x0
    2376:	mov    QWORD PTR [rsp],rdx
    237a:	mov    QWORD PTR [rsp+0x8],rcx
    237f:	mov    r15,rcx
    2382:	mov    r14d,0x47
    2388:	mov    rcx,0xffffffffffffffff
    238f:	bsr    rax,rsi
    2393:	mov    QWORD PTR [rsp+0xb0],rsi
    239b:	cmove  rax,rcx
    239f:	mov    ecx,0x3f
    23a4:	sub    rcx,rax
    23a7:	sub    r14,rcx
    23aa:	shr    r14,0x3
    23ae:	shl    r14,1
    23b1:	lea    rbx,[rsp+0x88]
    23b9:	lea    r12,[rsp+0x58]
    23be:	lea    r13,[rsp+0x38]
    23c3:	mov    rsi,rdx
    23c6:	mov    rax,r14
    23c9:	or     rax,0x1
    23cd:	mov    rcx,rsi
    23d0:	and    rcx,rax
    23d3:	mov    QWORD PTR [rsp+0xb8],rsi
    23db:	test   rcx,0x1
    23e2:	jne    2419 <botlish_fn_28+0xf9>
    23e8:	mov    rdx,r14
    23eb:	or     rdx,0x1
    23ef:	mov    rsi,QWORD PTR [rsp+0xb8]
    23f7:	mov    rdi,QWORD PTR [rsp+0xa8]
    23ff:	call   2404 <botlish_fn_28+0xe4>
			2400: R_X86_64_PLT32	rt_int_cmp-0x4
    2404:	mov    ecx,0x2
    2409:	test   rax,rax
    240c:	cmovge rcx,QWORD PTR [rip+0x4c4]        # 28d8 <botlish_fn_28+0x5b8>
    2414:	jmp    2438 <botlish_fn_28+0x118>
    2419:	mov    rax,r14
    241c:	or     rax,0x1
    2420:	mov    ecx,0x2
    2425:	mov    rsi,QWORD PTR [rsp+0xb8]
    242d:	cmp    rsi,rax
    2430:	cmovge rcx,QWORD PTR [rip+0x4a0]        # 28d8 <botlish_fn_28+0x5b8>
    2438:	cmp    rcx,0x6
    243c:	je     244c <botlish_fn_28+0x12c>
    2442:	mov    eax,0x2
    2447:	jmp    2451 <botlish_fn_28+0x131>
    244c:	mov    eax,0x6
    2451:	cmp    rax,0x6
    2455:	je     283b <botlish_fn_28+0x51b>
    245b:	mov    rsi,QWORD PTR [rsp+0xb0]
    2463:	mov    rdi,QWORD PTR [rsp+0xa8]
    246b:	call   2470 <botlish_fn_28+0x150>
			246c: R_X86_64_PLT32	rt_ascii_to_str-0x4
    2470:	mov    QWORD PTR [rsp+0xd0],rax
    2478:	mov    QWORD PTR [rsp+0x10],rax
    247d:	movzx  rcx,BYTE PTR [rax+0x18]
    2482:	test   rcx,rcx
    2485:	jne    24b0 <botlish_fn_28+0x190>
    248b:	mov    rdx,QWORD PTR [rsp+0xb8]
    2493:	mov    rsi,QWORD PTR [rsp+0xd0]
    249b:	mov    rdi,QWORD PTR [rsp+0xa8]
    24a3:	call   24a8 <botlish_fn_28+0x188>
			24a4: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    24a8:	mov    rsi,rax
    24ab:	jmp    24d4 <botlish_fn_28+0x1b4>
    24b0:	mov    rsi,QWORD PTR [rsp+0xb8]
    24b8:	mov    rcx,rsi
    24bb:	sar    rcx,1
    24be:	mov    rax,QWORD PTR [rsp+0xd0]
    24c6:	movzx  rsi,BYTE PTR [rax+rcx*1+0x19]
    24cc:	shl    rsi,0x3
    24d0:	or     rsi,0x4
    24d4:	shr    rsi,0x3
    24d8:	shl    rsi,1
    24db:	or     rsi,0x1
    24df:	mov    QWORD PTR [rsp+0x10],rsi
    24e4:	mov    edi,0x2
    24e9:	cmp    rsi,0xff
    24f0:	mov    QWORD PTR [rsp+0xc8],rsi
    24f8:	cmovg  rdi,QWORD PTR [rip+0x3d8]        # 28d8 <botlish_fn_28+0x5b8>
    2500:	cmp    rdi,0x6
    2504:	je     274f <botlish_fn_28+0x42f>
    250a:	mov    rsi,QWORD PTR [rsp+0xc8]
    2512:	mov    rdi,QWORD PTR [rsp+0xa8]
    251a:	call   251f <botlish_fn_28+0x1ff>
			251b: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    251f:	cmp    rax,0x6
    2523:	je     2621 <botlish_fn_28+0x301>
    2529:	mov    QWORD PTR [rsp+0x18],0x3
    2532:	mov    rsi,QWORD PTR [rsp+0xb8]
    253a:	test   rsi,0x1
    2541:	je     2571 <botlish_fn_28+0x251>
    2547:	mov    rsi,QWORD PTR [rsp+0xb8]
    254f:	mov    rax,rsi
    2552:	add    rax,0x2
    2556:	seto   cl
    2559:	test   cl,cl
    255b:	jne    2571 <botlish_fn_28+0x251>
    2561:	mov    rsi,rax
    2564:	mov    QWORD PTR [rsp+0xb8],rax
    256c:	jmp    2596 <botlish_fn_28+0x276>
    2571:	mov    edx,0x3
    2576:	mov    rsi,QWORD PTR [rsp+0xb8]
    257e:	mov    rdi,QWORD PTR [rsp+0xa8]
    2586:	call   258b <botlish_fn_28+0x26b>
			2587: R_X86_64_PLT32	rt_int_add-0x4
    258b:	mov    rsi,rax
    258e:	mov    QWORD PTR [rsp+0xb8],rax
    2596:	mov    QWORD PTR [rsp],rsi
    259a:	mov    rsi,QWORD PTR [rsp+0xc8]
    25a2:	mov    rdi,QWORD PTR [rsp+0xa8]
    25aa:	call   25af <botlish_fn_28+0x28f>
			25ab: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    25af:	test   rax,rax
    25b2:	je     286c <botlish_fn_28+0x54c>
    25b8:	mov    QWORD PTR [rsp+0x10],rax
    25bd:	mov    QWORD PTR [rsp+0x88],0x0
    25c9:	mov    QWORD PTR [rsp+0x90],r15
    25d1:	mov    QWORD PTR [rsp+0x98],0x0
    25dd:	mov    QWORD PTR [rsp+0xa0],rax
    25e5:	mov    esi,0x2
    25ea:	mov    edx,0x4
    25ef:	mov    rcx,rbx
    25f2:	mov    rdi,QWORD PTR [rsp+0xa8]
    25fa:	call   25ff <botlish_fn_28+0x2df>
			25fb: R_X86_64_PLT32	rt_construct-0x4
    25ff:	test   rax,rax
    2602:	je     286c <botlish_fn_28+0x54c>
    2608:	mov    rsi,QWORD PTR [rsp+0xb8]
    2610:	mov    QWORD PTR [rsp],rsi
    2614:	mov    QWORD PTR [rsp+0x8],rax
    2619:	mov    r15,rax
    261c:	jmp    23c6 <botlish_fn_28+0xa6>
    2621:	mov    QWORD PTR [rsp+0x18],0x3
    262a:	mov    rsi,QWORD PTR [rsp+0xb8]
    2632:	test   rsi,0x1
    2639:	je     2659 <botlish_fn_28+0x339>
    263f:	mov    rsi,QWORD PTR [rsp+0xb8]
    2647:	mov    rax,rsi
    264a:	add    rax,0x2
    264e:	seto   cl
    2651:	test   cl,cl
    2653:	je     2673 <botlish_fn_28+0x353>
    2659:	mov    edx,0x3
    265e:	mov    rsi,QWORD PTR [rsp+0xb8]
    2666:	mov    rdi,QWORD PTR [rsp+0xa8]
    266e:	call   2673 <botlish_fn_28+0x353>
			266f: R_X86_64_PLT32	rt_int_add-0x4
    2673:	mov    QWORD PTR [rsp+0x18],rax
    2678:	mov    QWORD PTR [rsp+0xc0],rax
    2680:	mov    QWORD PTR [rsp+0x20],0x3
    2689:	mov    rsi,QWORD PTR [rsp+0xb8]
    2691:	test   rsi,0x1
    2698:	je     26b8 <botlish_fn_28+0x398>
    269e:	mov    rsi,QWORD PTR [rsp+0xb8]
    26a6:	mov    rax,rsi
    26a9:	add    rax,0x2
    26ad:	seto   cl
    26b0:	test   cl,cl
    26b2:	je     26d2 <botlish_fn_28+0x3b2>
    26b8:	mov    edx,0x3
    26bd:	mov    rsi,QWORD PTR [rsp+0xb8]
    26c5:	mov    rdi,QWORD PTR [rsp+0xa8]
    26cd:	call   26d2 <botlish_fn_28+0x3b2>
			26ce: R_X86_64_PLT32	rt_int_add-0x4
    26d2:	mov    QWORD PTR [rsp+0x20],rax
    26d7:	mov    QWORD PTR [rsp+0x58],0x0
    26e0:	mov    QWORD PTR [rsp+0x60],r15
    26e5:	mov    QWORD PTR [rsp+0x68],0x1
    26ee:	mov    rcx,QWORD PTR [rsp+0xd0]
    26f6:	mov    QWORD PTR [rsp+0x70],rcx
    26fb:	mov    rsi,QWORD PTR [rsp+0xb8]
    2703:	mov    QWORD PTR [rsp+0x78],rsi
    2708:	mov    QWORD PTR [rsp+0x80],rax
    2710:	mov    esi,0x2
    2715:	mov    edx,0x6
    271a:	mov    rcx,r12
    271d:	mov    rdi,QWORD PTR [rsp+0xa8]
    2725:	call   272a <botlish_fn_28+0x40a>
			2726: R_X86_64_PLT32	rt_construct-0x4
    272a:	test   rax,rax
    272d:	je     286c <botlish_fn_28+0x54c>
    2733:	mov    rdi,QWORD PTR [rsp+0xc0]
    273b:	mov    QWORD PTR [rsp],rdi
    273f:	mov    QWORD PTR [rsp+0x8],rax
    2744:	mov    rsi,rdi
    2747:	mov    r15,rax
    274a:	jmp    23c6 <botlish_fn_28+0xa6>
    274f:	mov    QWORD PTR [rsp+0x18],0x3
    2758:	mov    rsi,QWORD PTR [rsp+0xb8]
    2760:	test   rsi,0x1
    2767:	je     2797 <botlish_fn_28+0x477>
    276d:	mov    rsi,QWORD PTR [rsp+0xb8]
    2775:	mov    rax,rsi
    2778:	add    rax,0x2
    277c:	seto   cl
    277f:	test   cl,cl
    2781:	jne    2797 <botlish_fn_28+0x477>
    2787:	mov    rsi,rax
    278a:	mov    QWORD PTR [rsp+0xb8],rax
    2792:	jmp    27bc <botlish_fn_28+0x49c>
    2797:	mov    edx,0x3
    279c:	mov    rsi,QWORD PTR [rsp+0xb8]
    27a4:	mov    rdi,QWORD PTR [rsp+0xa8]
    27ac:	call   27b1 <botlish_fn_28+0x491>
			27ad: R_X86_64_PLT32	rt_int_add-0x4
    27b1:	mov    rsi,rax
    27b4:	mov    QWORD PTR [rsp+0xb8],rax
    27bc:	mov    QWORD PTR [rsp],rsi
    27c0:	mov    rsi,QWORD PTR [rsp+0xc8]
    27c8:	mov    rdi,QWORD PTR [rsp+0xa8]
    27d0:	call   27d5 <botlish_fn_28+0x4b5>
			27d1: R_X86_64_PLT32	botlish_fn_27-0x4 ; esc_scalar<int>
    27d5:	test   rax,rax
    27d8:	je     286c <botlish_fn_28+0x54c>
    27de:	mov    QWORD PTR [rsp+0x10],rax
    27e3:	mov    QWORD PTR [rsp+0x38],0x0
    27ec:	mov    QWORD PTR [rsp+0x40],r15
    27f1:	mov    QWORD PTR [rsp+0x48],0x0
    27fa:	mov    QWORD PTR [rsp+0x50],rax
    27ff:	mov    esi,0x2
    2804:	mov    edx,0x4
    2809:	mov    rcx,r13
    280c:	mov    rdi,QWORD PTR [rsp+0xa8]
    2814:	call   2819 <botlish_fn_28+0x4f9>
			2815: R_X86_64_PLT32	rt_construct-0x4
    2819:	test   rax,rax
    281c:	je     286c <botlish_fn_28+0x54c>
    2822:	mov    rsi,QWORD PTR [rsp+0xb8]
    282a:	mov    QWORD PTR [rsp],rsi
    282e:	mov    QWORD PTR [rsp+0x8],rax
    2833:	mov    r15,rax
    2836:	jmp    23c6 <botlish_fn_28+0xa6>
    283b:	xor    rsi,rsi
    283e:	lea    rcx,[rsp+0x28]
    2843:	mov    QWORD PTR [rsp+0x28],0x0
    284c:	mov    QWORD PTR [rsp+0x30],r15
    2851:	mov    edx,0x2
    2856:	mov    rdi,QWORD PTR [rsp+0xa8]
    285e:	call   2863 <botlish_fn_28+0x543>
			285f: R_X86_64_PLT32	rt_construct-0x4
    2863:	test   rax,rax
    2866:	jne    28a3 <botlish_fn_28+0x583>
    286c:	xor    rax,rax
    286f:	mov    rbx,QWORD PTR [rsp+0xe0]
    2877:	mov    r12,QWORD PTR [rsp+0xe8]
    287f:	mov    r13,QWORD PTR [rsp+0xf0]
    2887:	mov    r14,QWORD PTR [rsp+0xf8]
    288f:	mov    r15,QWORD PTR [rsp+0x100]
    2897:	add    rsp,0x110
    289e:	mov    rsp,rbp
    28a1:	pop    rbp
    28a2:	ret
    28a3:	mov    rbx,QWORD PTR [rsp+0xe0]
    28ab:	mov    r12,QWORD PTR [rsp+0xe8]
    28b3:	mov    r13,QWORD PTR [rsp+0xf0]
    28bb:	mov    r14,QWORD PTR [rsp+0xf8]
    28c3:	mov    r15,QWORD PTR [rsp+0x100]
    28cb:	add    rsp,0x110
    28d2:	mov    rsp,rbp
    28d5:	pop    rbp
    28d6:	ret
    28d7:	add    BYTE PTR [rsi],al
    28d9:	add    BYTE PTR [rax],al
    28db:	add    BYTE PTR [rax],al
    28dd:	add    BYTE PTR [rax],al
	...

00000000000028e0 <botlish_entry_28: esc_from<str, int, str>>:
    28e0:	push   rbp
    28e1:	mov    rbp,rsp
    28e4:	sub    rsp,0x10
    28e8:	mov    QWORD PTR [rsp],r12
    28ec:	mov    QWORD PTR [rsp+0x8],r13
    28f1:	mov    r12,rdi
    28f4:	mov    rsi,QWORD PTR [rdx]
    28f7:	mov    r13,rdx
    28fa:	mov    r8,QWORD PTR [rip+0x0]        # 2901 <botlish_entry_28+0x21>
			28fd: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    2901:	call   r8
    2904:	mov    rcx,r13
    2907:	mov    rdx,QWORD PTR [rcx+0x8]
    290b:	mov    rcx,QWORD PTR [rcx+0x10]
    290f:	mov    rsi,rax
    2912:	mov    rdi,r12
    2915:	call   291a <botlish_entry_28+0x3a>
			2916: R_X86_64_PLT32	botlish_fn_28-0x4 ; esc_from<str, int, str>
    291a:	mov    r12,QWORD PTR [rsp]
    291e:	mov    r13,QWORD PTR [rsp+0x8]
    2923:	add    rsp,0x10
    2927:	mov    rsp,rbp
    292a:	pop    rbp
    292b:	ret

000000000000292c <botlish_fn_29: check<int, int, str, str>>:
    292c:	push   rbp
    292d:	mov    rbp,rsp
    2930:	sub    rsp,0x50
    2934:	mov    QWORD PTR [rsp+0x20],rbx
    2939:	mov    QWORD PTR [rsp+0x28],r12
    293e:	mov    QWORD PTR [rsp+0x30],r13
    2943:	mov    QWORD PTR [rsp+0x38],r14
    2948:	mov    QWORD PTR [rsp+0x40],r15
    294d:	mov    r14,rdi
    2950:	mov    QWORD PTR [rsp+0x18],0x0
    2959:	mov    QWORD PTR [rsp],rdx
    295d:	mov    QWORD PTR [rsp+0x8],rcx
    2962:	mov    QWORD PTR [rsp+0x10],r8
    2967:	mov    r12,r8
    296a:	mov    r13,rsi
    296d:	mov    r15,rdx
    2970:	test   r13,r13
    2973:	jle    2a4d <botlish_fn_29+0x121>
    2979:	mov    rbx,rcx
    297c:	mov    rsi,rbx
    297f:	mov    rdi,r14
    2982:	call   2987 <botlish_fn_29+0x5b>
			2983: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::emailish?<str>
    2987:	test   rax,rax
    298a:	jne    29b5 <botlish_fn_29+0x89>
    2990:	xor    rax,rax
    2993:	mov    rbx,QWORD PTR [rsp+0x20]
    2998:	mov    r12,QWORD PTR [rsp+0x28]
    299d:	mov    r13,QWORD PTR [rsp+0x30]
    29a2:	mov    r14,QWORD PTR [rsp+0x38]
    29a7:	mov    r15,QWORD PTR [rsp+0x40]
    29ac:	add    rsp,0x50
    29b0:	mov    rsp,rbp
    29b3:	pop    rbp
    29b4:	ret
    29b5:	cmp    rax,0x6
    29b9:	je     29d5 <botlish_fn_29+0xa9>
    29bf:	mov    edx,0x1
    29c4:	mov    QWORD PTR [rsp+0x18],0x1
    29cd:	mov    rsi,r15
    29d0:	jmp    2a01 <botlish_fn_29+0xd5>
    29d5:	mov    rsi,r12
    29d8:	mov    rdi,r14
    29db:	call   29e0 <botlish_fn_29+0xb4>
			29dc: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_query_value?<str>
    29e0:	cmp    rax,0x6
    29e4:	je     29f4 <botlish_fn_29+0xc8>
    29ea:	mov    edx,0x1
    29ef:	jmp    29f9 <botlish_fn_29+0xcd>
    29f4:	mov    edx,0x3
    29f9:	mov    QWORD PTR [rsp+0x18],rdx
    29fe:	mov    rsi,r15
    2a01:	mov    rax,rsi
    2a04:	and    rax,rdx
    2a07:	test   rax,0x1
    2a0d:	je     2a28 <botlish_fn_29+0xfc>
    2a13:	lea    rcx,[rdx-0x1]
    2a17:	mov    rax,rsi
    2a1a:	add    rax,rcx
    2a1d:	seto   cl
    2a20:	test   cl,cl
    2a22:	je     2a30 <botlish_fn_29+0x104>
    2a28:	mov    rdi,r14
    2a2b:	call   2a30 <botlish_fn_29+0x104>
			2a2c: R_X86_64_PLT32	rt_int_add-0x4
    2a30:	mov    QWORD PTR [rsp],rax
    2a34:	mov    QWORD PTR [rsp+0x8],rbx
    2a39:	mov    QWORD PTR [rsp+0x10],r12
    2a3e:	sub    r13,0x1
    2a42:	mov    rcx,rbx
    2a45:	mov    r15,rax
    2a48:	jmp    2970 <botlish_fn_29+0x44>
    2a4d:	mov    rax,r15
    2a50:	mov    rbx,QWORD PTR [rsp+0x20]
    2a55:	mov    r12,QWORD PTR [rsp+0x28]
    2a5a:	mov    r13,QWORD PTR [rsp+0x30]
    2a5f:	mov    r14,QWORD PTR [rsp+0x38]
    2a64:	mov    r15,QWORD PTR [rsp+0x40]
    2a69:	add    rsp,0x50
    2a6d:	mov    rsp,rbp
    2a70:	pop    rbp
    2a71:	ret

0000000000002a72 <botlish_entry_29: check<int, int, str, str>>:
    2a72:	push   rbp
    2a73:	mov    rbp,rsp
    2a76:	mov    rsi,QWORD PTR [rdx]
    2a79:	mov    r9,QWORD PTR [rdx+0x8]
    2a7d:	mov    rcx,QWORD PTR [rdx+0x10]
    2a81:	mov    r8,QWORD PTR [rdx+0x18]
    2a85:	sar    rsi,1
    2a88:	mov    rdx,r9
    2a8b:	call   2a90 <botlish_entry_29+0x1e>
			2a8c: R_X86_64_PLT32	botlish_fn_29-0x4 ; check<int, int, str, str>
    2a90:	mov    rsp,rbp
    2a93:	pop    rbp
    2a94:	ret

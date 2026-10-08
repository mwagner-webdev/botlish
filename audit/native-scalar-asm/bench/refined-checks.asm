; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 11262  (per function: 1415 217 745 74 74 74 128 128 353 115 154 176 176 295 344 183 770 140 60 501 853 127 103 313 219 287 1255 1615 368)
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
     adb:	sub    rsp,0x50
     adf:	mov    QWORD PTR [rsp+0x30],rbx
     ae4:	mov    QWORD PTR [rsp+0x38],r12
     ae9:	mov    QWORD PTR [rsp+0x40],r13
     aee:	mov    QWORD PTR [rsp+0x48],r14
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
			b2d: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<int, block(e251)>
     b31:	test   rax,rax
     b34:	je     bcf <botlish_fn_8+0xf8>
     b3a:	mov    rbx,rax
     b3d:	sar    rbx,1
     b40:	mov    rsi,rax
     b43:	test   rbx,rbx
     b46:	je     bfe <botlish_fn_8+0x127>
     b4c:	mov    rcx,r14
     b4f:	mov    rax,rcx
     b52:	or     rax,0x1
     b56:	sar    rax,1
     b59:	cmp    rbx,rax
     b5c:	jge    bf4 <botlish_fn_8+0x11d>
     b62:	mov    rdx,rcx
     b65:	or     rdx,0x1
     b69:	mov    r14,rcx
     b6c:	lea    r8,[rsp+0x18]
     b71:	mov    rcx,r12
     b74:	mov    rdi,r13
     b77:	call   b7c <botlish_fn_8+0xa5>
			b78: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     b7c:	mov    rdx,QWORD PTR [rsp+0x18]
     b81:	mov    rcx,QWORD PTR [rsp+0x20]
     b86:	mov    rdi,r13
     b89:	mov    rsi,QWORD PTR [rdi+0x10]
     b8d:	mov    r8,QWORD PTR [rsi+0xc8]
     b94:	mov    rsi,rax
     b97:	call   b9c <botlish_fn_8+0xc5>
			b98: R_X86_64_PLT32	rt_str_region_eq-0x4
     b9c:	cmp    rax,0x6
     ba0:	je     bb0 <botlish_fn_8+0xd9>
     ba6:	mov    eax,0x2
     bab:	jmp    c03 <botlish_fn_8+0x12c>
     bb0:	lea    rsi,[rbx+0x1]
     bb4:	mov    rdx,r14
     bb7:	or     rdx,0x1
     bbb:	mov    rcx,r12
     bbe:	mov    rdi,r13
     bc1:	call   bc6 <botlish_fn_8+0xef>
			bc2: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain?<int>
     bc6:	test   rax,rax
     bc9:	jne    c03 <botlish_fn_8+0x12c>
     bcf:	xor    rax,rax
     bd2:	mov    rbx,QWORD PTR [rsp+0x30]
     bd7:	mov    r12,QWORD PTR [rsp+0x38]
     bdc:	mov    r13,QWORD PTR [rsp+0x40]
     be1:	mov    r14,QWORD PTR [rsp+0x48]
     be6:	add    rsp,0x50
     bea:	mov    rsp,rbp
     bed:	pop    rbp
     bee:	ret
     bef:	jmp    c03 <botlish_fn_8+0x12c>
     bf4:	mov    eax,0x2
     bf9:	jmp    c03 <botlish_fn_8+0x12c>
     bfe:	mov    eax,0x2
     c03:	mov    rbx,QWORD PTR [rsp+0x30]
     c08:	mov    r12,QWORD PTR [rsp+0x38]
     c0d:	mov    r13,QWORD PTR [rsp+0x40]
     c12:	mov    r14,QWORD PTR [rsp+0x48]
     c17:	add    rsp,0x50
     c1b:	mov    rsp,rbp
     c1e:	pop    rbp
     c1f:	ret

0000000000000c20 <botlish_entry_8: web::emailish?<str>>:
     c20:	push   rbp
     c21:	mov    rbp,rsp
     c24:	mov    rsi,QWORD PTR [rdx]
     c27:	call   c2c <botlish_entry_8+0xc>
			c28: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::emailish?<str>
     c2c:	mov    rsp,rbp
     c2f:	pop    rbp
     c30:	ret

0000000000000c31 <botlish_fn_9: char_at<int>>:
     c31:	push   rbp
     c32:	mov    rbp,rsp
     c35:	mov    rax,rsi
     c38:	sar    rax,1
     c3b:	sar    rdx,1
     c3e:	cmp    rax,rdx
     c41:	jge    c52 <botlish_fn_9+0x21>
     c47:	mov    r11d,0x2
     c4d:	jmp    c58 <botlish_fn_9+0x27>
     c52:	mov    r11d,0x6
     c58:	cmp    r11,0x6
     c5c:	je     c7f <botlish_fn_9+0x4e>
     c62:	mov    QWORD PTR [r8],rsi
     c65:	add    rax,0x1
     c6c:	shl    rax,1
     c6f:	or     rax,0x1
     c73:	mov    QWORD PTR [r8+0x8],rax
     c77:	mov    rax,rcx
     c7a:	mov    rsp,rbp
     c7d:	pop    rbp
     c7e:	ret
     c7f:	mov    rax,QWORD PTR [rdi+0x10]
     c83:	mov    rax,QWORD PTR [rax+0xd0]
     c8a:	mov    QWORD PTR [r8],0x1
     c91:	mov    QWORD PTR [r8+0x8],0x1
     c99:	mov    rsp,rbp
     c9c:	pop    rbp
     c9d:	ret

0000000000000c9e <botlish_entry_9: char_at<int>>:
     c9e:	push   rbp
     c9f:	mov    rbp,rsp
     ca2:	ud2

0000000000000ca4 <botlish_fn_10: char_at<int>>:
     ca4:	push   rbp
     ca5:	mov    rbp,rsp
     ca8:	sub    rsp,0x20
     cac:	mov    QWORD PTR [rsp],rsi
     cb0:	mov    QWORD PTR [rsp+0x8],rcx
     cb5:	mov    r8,rcx
     cb8:	mov    rax,rsi
     cbb:	sar    rax,1
     cbe:	sar    rdx,1
     cc1:	cmp    rax,rdx
     cc4:	jge    cd4 <botlish_fn_10+0x30>
     cca:	mov    ecx,0x2
     ccf:	jmp    cd9 <botlish_fn_10+0x35>
     cd4:	mov    ecx,0x6
     cd9:	cmp    rcx,0x6
     cdd:	je     d07 <botlish_fn_10+0x63>
     ce3:	lea    rcx,[rax+0x1]
     ce7:	shl    rcx,1
     cea:	or     rcx,0x1
     cee:	mov    QWORD PTR [rsp+0x10],rcx
     cf3:	mov    rdx,rsi
     cf6:	mov    rsi,r8
     cf9:	call   cfe <botlish_fn_10+0x5a>
			cfa: R_X86_64_PLT32	rt_substr_proven-0x4
     cfe:	add    rsp,0x20
     d02:	mov    rsp,rbp
     d05:	pop    rbp
     d06:	ret
     d07:	mov    rax,QWORD PTR [rdi+0x10]
     d0b:	mov    rax,QWORD PTR [rax+0xd0]
     d12:	add    rsp,0x20
     d16:	mov    rsp,rbp
     d19:	pop    rbp
     d1a:	ret

0000000000000d1b <botlish_entry_10: char_at<int>>:
     d1b:	push   rbp
     d1c:	mov    rbp,rsp
     d1f:	mov    rsi,QWORD PTR [rdx]
     d22:	mov    r8,QWORD PTR [rdx+0x8]
     d26:	mov    rcx,QWORD PTR [rdx+0x10]
     d2a:	mov    rdx,r8
     d2d:	call   d32 <botlish_entry_10+0x17>
			d2e: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
     d32:	mov    rsp,rbp
     d35:	pop    rbp
     d36:	ret

0000000000000d37 <botlish_fn_11: local_char?<str>>:
     d37:	push   rbp
     d38:	mov    rbp,rsp
     d3b:	sub    rsp,0x10
     d3f:	mov    QWORD PTR [rsp],rbx
     d43:	mov    QWORD PTR [rsp+0x8],r14
     d48:	mov    rbx,rdi
     d4b:	mov    r14,rsi
     d4e:	mov    rsi,r14
     d51:	mov    rdi,rbx
     d54:	call   d59 <botlish_fn_11+0x22>
			d55: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     d59:	test   rax,rax
     d5c:	jne    d77 <botlish_fn_11+0x40>
     d62:	xor    rax,rax
     d65:	mov    rbx,QWORD PTR [rsp]
     d69:	mov    r14,QWORD PTR [rsp+0x8]
     d6e:	add    rsp,0x10
     d72:	mov    rsp,rbp
     d75:	pop    rbp
     d76:	ret
     d77:	cmp    rax,0x6
     d7b:	je     db1 <botlish_fn_11+0x7a>
     d81:	mov    rdi,rbx
     d84:	mov    rax,QWORD PTR [rdi+0x30]
     d88:	mov    rsi,QWORD PTR [rax]
     d8b:	mov    rdx,r14
     d8e:	call   d93 <botlish_fn_11+0x5c>
			d8f: R_X86_64_PLT32	rt_set_contains-0x4
     d93:	cmp    rax,0x6
     d97:	je     da7 <botlish_fn_11+0x70>
     d9d:	mov    eax,0x2
     da2:	jmp    db6 <botlish_fn_11+0x7f>
     da7:	mov    eax,0x6
     dac:	jmp    db6 <botlish_fn_11+0x7f>
     db1:	mov    eax,0x6
     db6:	mov    rbx,QWORD PTR [rsp]
     dba:	mov    r14,QWORD PTR [rsp+0x8]
     dbf:	add    rsp,0x10
     dc3:	mov    rsp,rbp
     dc6:	pop    rbp
     dc7:	ret

0000000000000dc8 <botlish_entry_11: local_char?<str>>:
     dc8:	push   rbp
     dc9:	mov    rbp,rsp
     dcc:	mov    rsi,QWORD PTR [rdx]
     dcf:	call   dd4 <botlish_entry_11+0xc>
			dd0: R_X86_64_PLT32	botlish_fn_11-0x4 ; local_char?<str>
     dd4:	mov    rsp,rbp
     dd7:	pop    rbp
     dd8:	ret

0000000000000dd9 <botlish_fn_12: local_char?<generic>>:
     dd9:	push   rbp
     dda:	mov    rbp,rsp
     ddd:	sub    rsp,0x10
     de1:	mov    QWORD PTR [rsp],rbx
     de5:	mov    QWORD PTR [rsp+0x8],r14
     dea:	mov    rbx,rdi
     ded:	mov    r14,rsi
     df0:	mov    rsi,r14
     df3:	mov    rdi,rbx
     df6:	call   dfb <botlish_fn_12+0x22>
			df7: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     dfb:	test   rax,rax
     dfe:	jne    e19 <botlish_fn_12+0x40>
     e04:	xor    rax,rax
     e07:	mov    rbx,QWORD PTR [rsp]
     e0b:	mov    r14,QWORD PTR [rsp+0x8]
     e10:	add    rsp,0x10
     e14:	mov    rsp,rbp
     e17:	pop    rbp
     e18:	ret
     e19:	cmp    rax,0x6
     e1d:	je     e53 <botlish_fn_12+0x7a>
     e23:	mov    rdi,rbx
     e26:	mov    rax,QWORD PTR [rdi+0x30]
     e2a:	mov    rsi,QWORD PTR [rax]
     e2d:	mov    rdx,r14
     e30:	call   e35 <botlish_fn_12+0x5c>
			e31: R_X86_64_PLT32	rt_set_contains-0x4
     e35:	cmp    rax,0x6
     e39:	je     e49 <botlish_fn_12+0x70>
     e3f:	mov    eax,0x2
     e44:	jmp    e58 <botlish_fn_12+0x7f>
     e49:	mov    eax,0x6
     e4e:	jmp    e58 <botlish_fn_12+0x7f>
     e53:	mov    eax,0x6
     e58:	mov    rbx,QWORD PTR [rsp]
     e5c:	mov    r14,QWORD PTR [rsp+0x8]
     e61:	add    rsp,0x10
     e65:	mov    rsp,rbp
     e68:	pop    rbp
     e69:	ret

0000000000000e6a <botlish_entry_12: local_char?<generic>>:
     e6a:	push   rbp
     e6b:	mov    rbp,rsp
     e6e:	mov    rsi,QWORD PTR [rdx]
     e71:	call   e76 <botlish_entry_12+0xc>
			e72: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<generic>
     e76:	mov    rsp,rbp
     e79:	pop    rbp
     e7a:	ret

0000000000000e7b <botlish_fn_13: scan_while<int, block(e251)>>:
     e7b:	push   rbp
     e7c:	mov    rbp,rsp
     e7f:	sub    rsp,0x50
     e83:	mov    QWORD PTR [rsp+0x20],rbx
     e88:	mov    QWORD PTR [rsp+0x28],r12
     e8d:	mov    QWORD PTR [rsp+0x30],r13
     e92:	mov    QWORD PTR [rsp+0x38],r14
     e97:	mov    QWORD PTR [rsp+0x40],r15
     e9c:	mov    QWORD PTR [rsp+0x18],rdi
     ea1:	mov    QWORD PTR [rsp],rcx
     ea5:	mov    QWORD PTR [rsp+0x8],r8
     eaa:	mov    r15,r8
     ead:	mov    r12,rcx
     eb0:	sar    r12,1
     eb3:	mov    r14,rcx
     eb6:	mov    rbx,rsi
     eb9:	cmp    rbx,r12
     ebc:	jl     ee7 <botlish_fn_13+0x6c>
     ec2:	mov    rax,r14
     ec5:	mov    rbx,QWORD PTR [rsp+0x20]
     eca:	mov    r12,QWORD PTR [rsp+0x28]
     ecf:	mov    r13,QWORD PTR [rsp+0x30]
     ed4:	mov    r14,QWORD PTR [rsp+0x38]
     ed9:	mov    r15,QWORD PTR [rsp+0x40]
     ede:	add    rsp,0x50
     ee2:	mov    rsp,rbp
     ee5:	pop    rbp
     ee6:	ret
     ee7:	mov    r13,rbx
     eea:	shl    r13,1
     eed:	or     r13,0x1
     ef1:	mov    QWORD PTR [rsp+0x10],r13
     ef6:	mov    rcx,r15
     ef9:	mov    rdx,r14
     efc:	mov    rsi,r13
     eff:	mov    rdi,QWORD PTR [rsp+0x18]
     f04:	call   f09 <botlish_fn_13+0x8e>
			f05: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
     f09:	mov    rsi,rax
     f0c:	mov    rdi,QWORD PTR [rsp+0x18]
     f11:	call   f16 <botlish_fn_13+0x9b>
			f12: R_X86_64_PLT32	botlish_fn_11-0x4 ; local_char?<str>
     f16:	test   rax,rax
     f19:	jne    f44 <botlish_fn_13+0xc9>
     f1f:	xor    rax,rax
     f22:	mov    rbx,QWORD PTR [rsp+0x20]
     f27:	mov    r12,QWORD PTR [rsp+0x28]
     f2c:	mov    r13,QWORD PTR [rsp+0x30]
     f31:	mov    r14,QWORD PTR [rsp+0x38]
     f36:	mov    r15,QWORD PTR [rsp+0x40]
     f3b:	add    rsp,0x50
     f3f:	mov    rsp,rbp
     f42:	pop    rbp
     f43:	ret
     f44:	cmp    rax,0x6
     f48:	je     f73 <botlish_fn_13+0xf8>
     f4e:	mov    rax,r13
     f51:	mov    rbx,QWORD PTR [rsp+0x20]
     f56:	mov    r12,QWORD PTR [rsp+0x28]
     f5b:	mov    r13,QWORD PTR [rsp+0x30]
     f60:	mov    r14,QWORD PTR [rsp+0x38]
     f65:	mov    r15,QWORD PTR [rsp+0x40]
     f6a:	add    rsp,0x50
     f6e:	mov    rsp,rbp
     f71:	pop    rbp
     f72:	ret
     f73:	add    rbx,0x1
     f7a:	jmp    eb9 <botlish_fn_13+0x3e>

0000000000000f7f <botlish_entry_13: scan_while<int, block(e251)>>:
     f7f:	push   rbp
     f80:	mov    rbp,rsp
     f83:	mov    rsi,QWORD PTR [rdx]
     f86:	mov    r9,QWORD PTR [rdx+0x8]
     f8a:	mov    rcx,QWORD PTR [rdx+0x10]
     f8e:	mov    r8,QWORD PTR [rdx+0x18]
     f92:	sar    rsi,1
     f95:	mov    rdx,r9
     f98:	call   f9d <botlish_entry_13+0x1e>
			f99: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<int, block(e251)>
     f9d:	mov    rsp,rbp
     fa0:	pop    rbp
     fa1:	ret

0000000000000fa2 <botlish_fn_14: scan_while<int, native(str::is_tcl_alpha)>>:
     fa2:	push   rbp
     fa3:	mov    rbp,rsp
     fa6:	sub    rsp,0x40
     faa:	mov    QWORD PTR [rsp+0x10],rbx
     faf:	mov    QWORD PTR [rsp+0x18],r12
     fb4:	mov    QWORD PTR [rsp+0x20],r13
     fb9:	mov    QWORD PTR [rsp+0x28],r14
     fbe:	mov    QWORD PTR [rsp+0x30],r15
     fc3:	mov    rbx,r8
     fc6:	mov    r13,rdi
     fc9:	mov    rax,rcx
     fcc:	sar    rax,1
     fcf:	mov    r12,rcx
     fd2:	mov    r14,rax
     fd5:	mov    rax,rsi
     fd8:	mov    rcx,r14
     fdb:	cmp    rax,rcx
     fde:	mov    r14,rcx
     fe1:	jl     1011 <botlish_fn_14+0x6f>
     fe7:	mov    edx,0x1
     fec:	mov    rax,r14
     fef:	mov    rbx,QWORD PTR [rsp+0x10]
     ff4:	mov    r12,QWORD PTR [rsp+0x18]
     ff9:	mov    r13,QWORD PTR [rsp+0x20]
     ffe:	mov    r14,QWORD PTR [rsp+0x28]
    1003:	mov    r15,QWORD PTR [rsp+0x30]
    1008:	add    rsp,0x40
    100c:	mov    rsp,rbp
    100f:	pop    rbp
    1010:	ret
    1011:	mov    rsi,rax
    1014:	shl    rsi,1
    1017:	mov    r15,rax
    101a:	or     rsi,0x1
    101e:	lea    r8,[rsp]
    1022:	mov    rcx,rbx
    1025:	mov    rdx,r12
    1028:	mov    rdi,r13
    102b:	call   1030 <botlish_fn_14+0x8e>
			102c: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    1030:	mov    rdx,QWORD PTR [rsp]
    1034:	mov    rcx,QWORD PTR [rsp+0x8]
    1039:	mov    rsi,rax
    103c:	mov    rdi,r13
    103f:	call   1044 <botlish_fn_14+0xa2>
			1040: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    1044:	test   rax,rax
    1047:	jne    1075 <botlish_fn_14+0xd3>
    104d:	xor    rdx,rdx
    1050:	mov    rax,rdx
    1053:	mov    rbx,QWORD PTR [rsp+0x10]
    1058:	mov    r12,QWORD PTR [rsp+0x18]
    105d:	mov    r13,QWORD PTR [rsp+0x20]
    1062:	mov    r14,QWORD PTR [rsp+0x28]
    1067:	mov    r15,QWORD PTR [rsp+0x30]
    106c:	add    rsp,0x40
    1070:	mov    rsp,rbp
    1073:	pop    rbp
    1074:	ret
    1075:	cmp    rax,0x6
    1079:	je     10a9 <botlish_fn_14+0x107>
    107f:	mov    edx,0x1
    1084:	mov    rax,r15
    1087:	mov    rbx,QWORD PTR [rsp+0x10]
    108c:	mov    r12,QWORD PTR [rsp+0x18]
    1091:	mov    r13,QWORD PTR [rsp+0x20]
    1096:	mov    r14,QWORD PTR [rsp+0x28]
    109b:	mov    r15,QWORD PTR [rsp+0x30]
    10a0:	add    rsp,0x40
    10a4:	mov    rsp,rbp
    10a7:	pop    rbp
    10a8:	ret
    10a9:	mov    rax,r15
    10ac:	add    rax,0x1
    10b3:	mov    rcx,r14
    10b6:	jmp    fdb <botlish_fn_14+0x39>

00000000000010bb <botlish_entry_14: scan_while<int, native(str::is_tcl_alpha)>>:
    10bb:	push   rbp
    10bc:	mov    rbp,rsp
    10bf:	mov    rsi,QWORD PTR [rdx]
    10c2:	mov    rax,QWORD PTR [rdx+0x8]
    10c6:	mov    rcx,QWORD PTR [rdx+0x10]
    10ca:	mov    r8,QWORD PTR [rdx+0x18]
    10ce:	sar    rsi,1
    10d1:	mov    rdx,rax
    10d4:	call   10d9 <botlish_entry_14+0x1e>
			10d5: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, native(str::is_tcl_alpha)>
    10d9:	shl    rax,1
    10dc:	or     rax,0x1
    10e0:	mov    rcx,rax
    10e3:	xor    rax,rax
    10e6:	test   rdx,rdx
    10e9:	cmovne rax,rcx
    10ed:	mov    rsp,rbp
    10f0:	pop    rbp
    10f1:	ret
    10f2:	add    BYTE PTR [rax],al
    10f4:	add    BYTE PTR [rax],al
	...

00000000000010f8 <botlish_fn_15: tld?<int>>:
    10f8:	push   rbp
    10f9:	mov    rbp,rsp
    10fc:	sub    rsp,0x10
    1100:	mov    QWORD PTR [rsp],rbx
    1104:	mov    QWORD PTR [rsp+0x8],r12
    1109:	mov    r8,rdx
    110c:	mov    rax,QWORD PTR [rdi+0x10]
    1110:	mov    rdx,QWORD PTR [rax+0xd8]
    1117:	mov    r12,r8
    111a:	mov    r8,rcx
    111d:	mov    rbx,rsi
    1120:	mov    rcx,r12
    1123:	call   1128 <botlish_fn_15+0x30>
			1124: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, native(str::is_tcl_alpha)>
    1128:	test   rdx,rdx
    112b:	jne    1146 <botlish_fn_15+0x4e>
    1131:	xor    rax,rax
    1134:	mov    rbx,QWORD PTR [rsp]
    1138:	mov    r12,QWORD PTR [rsp+0x8]
    113d:	add    rsp,0x10
    1141:	mov    rsp,rbp
    1144:	pop    rbp
    1145:	ret
    1146:	sar    r12,1
    1149:	cmp    rax,r12
    114c:	je     115c <botlish_fn_15+0x64>
    1152:	mov    eax,0x2
    1157:	jmp    1173 <botlish_fn_15+0x7b>
    115c:	sub    rax,rbx
    115f:	mov    rcx,rax
    1162:	mov    eax,0x2
    1167:	cmp    rcx,0x2
    116b:	cmovge rax,QWORD PTR [rip+0x15]        # 1188 <botlish_fn_15+0x90>
    1173:	mov    rbx,QWORD PTR [rsp]
    1177:	mov    r12,QWORD PTR [rsp+0x8]
    117c:	add    rsp,0x10
    1180:	mov    rsp,rbp
    1183:	pop    rbp
    1184:	ret
    1185:	add    BYTE PTR [rax],al
    1187:	add    BYTE PTR [rsi],al
    1189:	add    BYTE PTR [rax],al
    118b:	add    BYTE PTR [rax],al
    118d:	add    BYTE PTR [rax],al
	...

0000000000001190 <botlish_entry_15: tld?<int>>:
    1190:	push   rbp
    1191:	mov    rbp,rsp
    1194:	mov    rsi,QWORD PTR [rdx]
    1197:	mov    r8,QWORD PTR [rdx+0x8]
    119b:	mov    rcx,QWORD PTR [rdx+0x10]
    119f:	sar    rsi,1
    11a2:	mov    rdx,r8
    11a5:	call   11aa <botlish_entry_15+0x1a>
			11a6: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld?<int>
    11aa:	mov    rsp,rbp
    11ad:	pop    rbp
    11ae:	ret

00000000000011af <botlish_fn_16: domain?<int>>:
    11af:	push   rbp
    11b0:	mov    rbp,rsp
    11b3:	sub    rsp,0x80
    11ba:	mov    QWORD PTR [rsp+0x50],rbx
    11bf:	mov    QWORD PTR [rsp+0x58],r12
    11c4:	mov    QWORD PTR [rsp+0x60],r13
    11c9:	mov    QWORD PTR [rsp+0x68],r14
    11ce:	mov    QWORD PTR [rsp+0x70],r15
    11d3:	mov    rbx,rsi
    11d6:	mov    r15,rcx
    11d9:	mov    r14,rdx
    11dc:	sar    r14,1
    11df:	mov    QWORD PTR [rsp+0x30],rdx
    11e4:	mov    r12,rbx
    11e7:	cmp    r12,r14
    11ea:	jl     121a <botlish_fn_16+0x6b>
    11f0:	mov    eax,0x2
    11f5:	mov    rbx,QWORD PTR [rsp+0x50]
    11fa:	mov    r12,QWORD PTR [rsp+0x58]
    11ff:	mov    r13,QWORD PTR [rsp+0x60]
    1204:	mov    r14,QWORD PTR [rsp+0x68]
    1209:	mov    r15,QWORD PTR [rsp+0x70]
    120e:	add    rsp,0x80
    1215:	mov    rsp,rbp
    1218:	pop    rbp
    1219:	ret
    121a:	mov    rsi,r12
    121d:	shl    rsi,1
    1220:	or     rsi,0x1
    1224:	mov    QWORD PTR [rsp+0x48],rsi
    1229:	lea    r8,[rsp]
    122d:	mov    r13,rdi
    1230:	mov    rcx,r15
    1233:	mov    rdx,QWORD PTR [rsp+0x30]
    1238:	call   123d <botlish_fn_16+0x8e>
			1239: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    123d:	mov    rdx,QWORD PTR [rsp]
    1241:	mov    rcx,QWORD PTR [rsp+0x8]
    1246:	mov    rsi,QWORD PTR [r13+0x10]
    124a:	mov    r8,QWORD PTR [rsi]
    124d:	mov    rsi,rax
    1250:	mov    rdi,r13
    1253:	call   1258 <botlish_fn_16+0xa9>
			1254: R_X86_64_PLT32	rt_str_region_eq-0x4
    1258:	cmp    rax,0x6
    125c:	je     1344 <botlish_fn_16+0x195>
    1262:	lea    r8,[rsp+0x20]
    1267:	mov    rsi,QWORD PTR [rsp+0x48]
    126c:	mov    rcx,r15
    126f:	mov    rdx,QWORD PTR [rsp+0x30]
    1274:	mov    rdi,r13
    1277:	call   127c <botlish_fn_16+0xcd>
			1278: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    127c:	mov    QWORD PTR [rsp+0x48],rax
    1281:	mov    rdx,QWORD PTR [rsp+0x20]
    1286:	mov    QWORD PTR [rsp+0x40],rdx
    128b:	mov    rcx,QWORD PTR [rsp+0x28]
    1290:	mov    QWORD PTR [rsp+0x38],rcx
    1295:	mov    rsi,QWORD PTR [rsp+0x48]
    129a:	mov    rdi,r13
    129d:	call   12a2 <botlish_fn_16+0xf3>
			129e: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    12a2:	test   rax,rax
    12a5:	je     13b4 <botlish_fn_16+0x205>
    12ab:	cmp    rax,0x6
    12af:	je     12f2 <botlish_fn_16+0x143>
    12b5:	mov    rcx,QWORD PTR [r13+0x10]
    12b9:	mov    r8,QWORD PTR [rcx+0x20]
    12bd:	mov    rcx,QWORD PTR [rsp+0x38]
    12c2:	mov    rdx,QWORD PTR [rsp+0x40]
    12c7:	mov    rsi,QWORD PTR [rsp+0x48]
    12cc:	mov    rdi,r13
    12cf:	call   12d4 <botlish_fn_16+0x125>
			12d0: R_X86_64_PLT32	rt_str_region_eq-0x4
    12d4:	cmp    rax,0x6
    12d8:	je     12e8 <botlish_fn_16+0x139>
    12de:	mov    ecx,0x2
    12e3:	jmp    12f7 <botlish_fn_16+0x148>
    12e8:	mov    ecx,0x6
    12ed:	jmp    12f7 <botlish_fn_16+0x148>
    12f2:	mov    ecx,0x6
    12f7:	cmp    rcx,0x6
    12fb:	je     130b <botlish_fn_16+0x15c>
    1301:	mov    eax,0x6
    1306:	jmp    1310 <botlish_fn_16+0x161>
    130b:	mov    eax,0x2
    1310:	cmp    rax,0x6
    1314:	jne    13e6 <botlish_fn_16+0x237>
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
    1347:	je     1449 <botlish_fn_16+0x29a>
    134d:	mov    rsi,r12
    1350:	sub    rsi,0x1
    1354:	shl    rsi,1
    1357:	or     rsi,0x1
    135b:	lea    r8,[rsp+0x10]
    1360:	mov    rcx,r15
    1363:	mov    rdx,QWORD PTR [rsp+0x30]
    1368:	mov    rdi,r13
    136b:	call   1370 <botlish_fn_16+0x1c1>
			136c: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    1370:	mov    rdx,QWORD PTR [rsp+0x10]
    1375:	mov    rcx,QWORD PTR [rsp+0x18]
    137a:	mov    rsi,QWORD PTR [r13+0x10]
    137e:	mov    r8,QWORD PTR [rsi]
    1381:	mov    rsi,rax
    1384:	mov    rdi,r13
    1387:	call   138c <botlish_fn_16+0x1dd>
			1388: R_X86_64_PLT32	rt_str_region_eq-0x4
    138c:	cmp    rax,0x6
    1390:	je     141f <botlish_fn_16+0x270>
    1396:	lea    rsi,[r12+0x1]
    139b:	mov    rcx,r15
    139e:	mov    rdx,QWORD PTR [rsp+0x30]
    13a3:	mov    rdi,r13
    13a6:	call   13ab <botlish_fn_16+0x1fc>
			13a7: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld?<int>
    13ab:	test   rax,rax
    13ae:	jne    13dc <botlish_fn_16+0x22d>
    13b4:	xor    rax,rax
    13b7:	mov    rbx,QWORD PTR [rsp+0x50]
    13bc:	mov    r12,QWORD PTR [rsp+0x58]
    13c1:	mov    r13,QWORD PTR [rsp+0x60]
    13c6:	mov    r14,QWORD PTR [rsp+0x68]
    13cb:	mov    r15,QWORD PTR [rsp+0x70]
    13d0:	add    rsp,0x80
    13d7:	mov    rsp,rbp
    13da:	pop    rbp
    13db:	ret
    13dc:	cmp    rax,0x6
    13e0:	je     13f5 <botlish_fn_16+0x246>
    13e6:	add    r12,0x1
    13ed:	mov    rdi,r13
    13f0:	jmp    11e7 <botlish_fn_16+0x38>
    13f5:	mov    eax,0x6
    13fa:	mov    rbx,QWORD PTR [rsp+0x50]
    13ff:	mov    r12,QWORD PTR [rsp+0x58]
    1404:	mov    r13,QWORD PTR [rsp+0x60]
    1409:	mov    r14,QWORD PTR [rsp+0x68]
    140e:	mov    r15,QWORD PTR [rsp+0x70]
    1413:	add    rsp,0x80
    141a:	mov    rsp,rbp
    141d:	pop    rbp
    141e:	ret
    141f:	mov    eax,0x2
    1424:	mov    rbx,QWORD PTR [rsp+0x50]
    1429:	mov    r12,QWORD PTR [rsp+0x58]
    142e:	mov    r13,QWORD PTR [rsp+0x60]
    1433:	mov    r14,QWORD PTR [rsp+0x68]
    1438:	mov    r15,QWORD PTR [rsp+0x70]
    143d:	add    rsp,0x80
    1444:	mov    rsp,rbp
    1447:	pop    rbp
    1448:	ret
    1449:	mov    eax,0x2
    144e:	mov    rbx,QWORD PTR [rsp+0x50]
    1453:	mov    r12,QWORD PTR [rsp+0x58]
    1458:	mov    r13,QWORD PTR [rsp+0x60]
    145d:	mov    r14,QWORD PTR [rsp+0x68]
    1462:	mov    r15,QWORD PTR [rsp+0x70]
    1467:	add    rsp,0x80
    146e:	mov    rsp,rbp
    1471:	pop    rbp
    1472:	ret

0000000000001473 <botlish_entry_16: domain?<int>>:
    1473:	push   rbp
    1474:	mov    rbp,rsp
    1477:	mov    rsi,QWORD PTR [rdx]
    147a:	mov    r8,QWORD PTR [rdx+0x8]
    147e:	mov    rcx,QWORD PTR [rdx+0x10]
    1482:	sar    rsi,1
    1485:	mov    rdx,r8
    1488:	call   148d <botlish_entry_16+0x1a>
			1489: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain?<int>
    148d:	mov    rsp,rbp
    1490:	pop    rbp
    1491:	ret

0000000000001492 <botlish_fn_17: web::is_unreserved<int>>:
    1492:	push   rbp
    1493:	mov    rbp,rsp
    1496:	sub    rsp,0x10
    149a:	mov    QWORD PTR [rsp],rbx
    149e:	mov    QWORD PTR [rsp+0x8],r14
    14a3:	mov    r14,rsi
    14a6:	mov    rsi,r14
    14a9:	sar    rsi,1
    14ac:	mov    rbx,rdi
    14af:	call   14b4 <botlish_fn_17+0x22>
			14b0: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphanumeric<int>
    14b4:	cmp    rax,0x6
    14b8:	je     14ef <botlish_fn_17+0x5d>
    14be:	mov    rax,QWORD PTR [rbx+0x30]
    14c2:	mov    rsi,QWORD PTR [rax+0x10]
    14c6:	mov    rdx,r14
    14c9:	mov    rdi,rbx
    14cc:	call   14d1 <botlish_fn_17+0x3f>
			14cd: R_X86_64_PLT32	rt_set_contains-0x4
    14d1:	cmp    rax,0x6
    14d5:	je     14e5 <botlish_fn_17+0x53>
    14db:	mov    eax,0x2
    14e0:	jmp    14f4 <botlish_fn_17+0x62>
    14e5:	mov    eax,0x6
    14ea:	jmp    14f4 <botlish_fn_17+0x62>
    14ef:	mov    eax,0x6
    14f4:	mov    rbx,QWORD PTR [rsp]
    14f8:	mov    r14,QWORD PTR [rsp+0x8]
    14fd:	add    rsp,0x10
    1501:	mov    rsp,rbp
    1504:	pop    rbp
    1505:	ret

0000000000001506 <botlish_entry_17: web::is_unreserved<int>>:
    1506:	push   rbp
    1507:	mov    rbp,rsp
    150a:	mov    rsi,QWORD PTR [rdx]
    150d:	call   1512 <botlish_entry_17+0xc>
			150e: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<int>
    1512:	mov    rsp,rbp
    1515:	pop    rbp
    1516:	ret

0000000000001517 <botlish_fn_18: web::uri_query_value?<str>>:
    1517:	push   rbp
    1518:	mov    rbp,rsp
    151b:	sub    rsp,0x10
    151f:	mov    QWORD PTR [rsp],rsi
    1523:	mov    rdx,rsi
    1526:	mov    esi,0x1
    152b:	mov    QWORD PTR [rsp+0x8],0x1
    1534:	call   1539 <botlish_fn_18+0x22>
			1535: R_X86_64_PLT32	botlish_fn_20-0x4 ; valid_from?<int>
    1539:	add    rsp,0x10
    153d:	mov    rsp,rbp
    1540:	pop    rbp
    1541:	ret

0000000000001542 <botlish_entry_18: web::uri_query_value?<str>>:
    1542:	push   rbp
    1543:	mov    rbp,rsp
    1546:	mov    rsi,QWORD PTR [rdx]
    1549:	call   154e <botlish_entry_18+0xc>
			154a: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::uri_query_value?<str>
    154e:	mov    rsp,rbp
    1551:	pop    rbp
    1552:	ret
    1553:	add    BYTE PTR [rax],al
    1555:	add    BYTE PTR [rax],al
	...

0000000000001558 <botlish_fn_19: upper_hex?<int>>:
    1558:	push   rbp
    1559:	mov    rbp,rsp
    155c:	sub    rsp,0x20
    1560:	mov    QWORD PTR [rsp],rbx
    1564:	mov    QWORD PTR [rsp+0x8],r12
    1569:	mov    QWORD PTR [rsp+0x10],r13
    156e:	mov    rbx,rdi
    1571:	mov    r13,rdx
    1574:	mov    rdx,r13
    1577:	mov    rdx,QWORD PTR [rdx+0x8]
    157b:	shl    rdx,1
    157e:	mov    rax,rdx
    1581:	or     rax,0x1
    1585:	mov    rcx,rsi
    1588:	and    rcx,rax
    158b:	test   rcx,0x1
    1592:	jne    15bf <botlish_fn_19+0x67>
    1598:	or     rdx,0x1
    159c:	mov    r12,rsi
    159f:	mov    rdi,rbx
    15a2:	call   15a7 <botlish_fn_19+0x4f>
			15a3: R_X86_64_PLT32	rt_int_cmp-0x4
    15a7:	mov    ecx,0x2
    15ac:	test   rax,rax
    15af:	cmovge rcx,QWORD PTR [rip+0x169]        # 1720 <botlish_fn_19+0x1c8>
    15b7:	mov    rsi,r12
    15ba:	jmp    15d6 <botlish_fn_19+0x7e>
    15bf:	mov    r12,rsi
    15c2:	or     rdx,0x1
    15c6:	mov    ecx,0x2
    15cb:	cmp    r12,rdx
    15ce:	cmovge rcx,QWORD PTR [rip+0x14a]        # 1720 <botlish_fn_19+0x1c8>
    15d6:	mov    eax,0x6
    15db:	mov    r12,rax
    15de:	cmp    rcx,0x6
    15e2:	je     15f2 <botlish_fn_19+0x9a>
    15e8:	mov    eax,0x2
    15ed:	jmp    15f5 <botlish_fn_19+0x9d>
    15f2:	mov    rax,r12
    15f5:	cmp    rax,0x6
    15f9:	je     1702 <botlish_fn_19+0x1aa>
    15ff:	mov    rdx,r13
    1602:	movzx  rax,BYTE PTR [rdx+0x18]
    1607:	test   rax,rax
    160a:	jne    1623 <botlish_fn_19+0xcb>
    1610:	mov    rdx,rsi
    1613:	mov    rsi,r13
    1616:	mov    rdi,rbx
    1619:	call   161e <botlish_fn_19+0xc6>
			161a: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    161e:	jmp    163a <botlish_fn_19+0xe2>
    1623:	mov    rdx,rsi
    1626:	mov    rsi,r13
    1629:	sar    rdx,1
    162c:	movzx  rax,BYTE PTR [rsi+rdx*1+0x19]
    1632:	shl    rax,0x3
    1636:	or     rax,0x4
    163a:	mov    rdx,rax
    163d:	shr    rdx,0x3
    1641:	shl    rdx,1
    1644:	or     rdx,0x1
    1648:	mov    ecx,0x2
    164d:	cmp    rdx,0xff
    1654:	cmovle rcx,QWORD PTR [rip+0xc4]        # 1720 <botlish_fn_19+0x1c8>
    165c:	cmp    rcx,0x6
    1660:	je     1673 <botlish_fn_19+0x11b>
    1666:	mov    eax,0x2
    166b:	mov    r12,rax
    166e:	jmp    1707 <botlish_fn_19+0x1af>
    1673:	shr    rax,0x3
    1677:	shl    rax,1
    167a:	or     rax,0x1
    167e:	sar    rax,1
    1681:	mov    rdi,rbx
    1684:	mov    r13,rax
    1687:	mov    rsi,r13
    168a:	call   168f <botlish_fn_19+0x137>
			168b: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<int>
    168f:	cmp    rax,0x6
    1693:	je     16e3 <botlish_fn_19+0x18b>
    1699:	mov    rax,r13
    169c:	cmp    rax,0x41
    16a0:	jge    16b0 <botlish_fn_19+0x158>
    16a6:	mov    esi,0x2
    16ab:	jmp    16c7 <botlish_fn_19+0x16f>
    16b0:	cmp    rax,0x46
    16b4:	jle    16c4 <botlish_fn_19+0x16c>
    16ba:	mov    esi,0x2
    16bf:	jmp    16c7 <botlish_fn_19+0x16f>
    16c4:	mov    rsi,r12
    16c7:	cmp    rsi,0x6
    16cb:	je     16db <botlish_fn_19+0x183>
    16d1:	mov    eax,0x2
    16d6:	jmp    16e6 <botlish_fn_19+0x18e>
    16db:	mov    rax,r12
    16de:	jmp    16e6 <botlish_fn_19+0x18e>
    16e3:	mov    rax,r12
    16e6:	cmp    rax,0x6
    16ea:	je     16fa <botlish_fn_19+0x1a2>
    16f0:	mov    eax,0x2
    16f5:	jmp    1707 <botlish_fn_19+0x1af>
    16fa:	mov    rax,r12
    16fd:	jmp    1707 <botlish_fn_19+0x1af>
    1702:	mov    eax,0x2
    1707:	mov    rbx,QWORD PTR [rsp]
    170b:	mov    r12,QWORD PTR [rsp+0x8]
    1710:	mov    r13,QWORD PTR [rsp+0x10]
    1715:	add    rsp,0x20
    1719:	mov    rsp,rbp
    171c:	pop    rbp
    171d:	ret
    171e:	add    BYTE PTR [rax],al
    1720:	(bad)
    1721:	add    BYTE PTR [rax],al
    1723:	add    BYTE PTR [rax],al
    1725:	add    BYTE PTR [rax],al
	...

0000000000001728 <botlish_entry_19: upper_hex?<int>>:
    1728:	push   rbp
    1729:	mov    rbp,rsp
    172c:	mov    rsi,QWORD PTR [rdx]
    172f:	mov    rdx,QWORD PTR [rdx+0x8]
    1733:	call   1738 <botlish_entry_19+0x10>
			1734: R_X86_64_PLT32	botlish_fn_19-0x4 ; upper_hex?<int>
    1738:	mov    rsp,rbp
    173b:	pop    rbp
    173c:	ret
    173d:	add    BYTE PTR [rax],al
	...

0000000000001740 <botlish_fn_20: valid_from?<int>>:
    1740:	push   rbp
    1741:	mov    rbp,rsp
    1744:	sub    rsp,0x40
    1748:	mov    QWORD PTR [rsp+0x20],r12
    174d:	mov    QWORD PTR [rsp+0x28],r13
    1752:	mov    QWORD PTR [rsp+0x30],r14
    1757:	mov    r13,rdi
    175a:	mov    QWORD PTR [rsp],rsi
    175e:	mov    r14,rsi
    1761:	mov    QWORD PTR [rsp+0x8],rdx
    1766:	mov    r12,rdx
    1769:	mov    rdx,QWORD PTR [r12+0x8]
    176e:	shl    rdx,1
    1771:	or     rdx,0x1
    1775:	mov    rsi,r14
    1778:	mov    r11,rsi
    177b:	and    r11,rdx
    177e:	test   r11,0x1
    1785:	jne    17ab <botlish_fn_20+0x6b>
    178b:	mov    rsi,r14
    178e:	mov    rdi,r13
    1791:	call   1796 <botlish_fn_20+0x56>
			1792: R_X86_64_PLT32	rt_int_cmp-0x4
    1796:	mov    ecx,0x2
    179b:	test   rax,rax
    179e:	cmovge rcx,QWORD PTR [rip+0x2aa]        # 1a50 <botlish_fn_20+0x310>
    17a6:	jmp    17be <botlish_fn_20+0x7e>
    17ab:	mov    ecx,0x2
    17b0:	mov    rsi,r14
    17b3:	cmp    rsi,rdx
    17b6:	cmovge rcx,QWORD PTR [rip+0x292]        # 1a50 <botlish_fn_20+0x310>
    17be:	cmp    rcx,0x6
    17c2:	je     17d2 <botlish_fn_20+0x92>
    17c8:	mov    ecx,0x2
    17cd:	jmp    17d7 <botlish_fn_20+0x97>
    17d2:	mov    ecx,0x6
    17d7:	cmp    rcx,0x6
    17db:	je     1a2f <botlish_fn_20+0x2ef>
    17e1:	movzx  rax,BYTE PTR [r12+0x18]
    17e7:	test   rax,rax
    17ea:	jne    1806 <botlish_fn_20+0xc6>
    17f0:	mov    rdx,r14
    17f3:	mov    rsi,r12
    17f6:	mov    rdi,r13
    17f9:	call   17fe <botlish_fn_20+0xbe>
			17fa: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    17fe:	mov    rsi,rax
    1801:	jmp    181d <botlish_fn_20+0xdd>
    1806:	mov    rsi,r14
    1809:	mov    rax,rsi
    180c:	sar    rax,1
    180f:	movzx  rsi,BYTE PTR [r12+rax*1+0x19]
    1815:	shl    rsi,0x3
    1819:	or     rsi,0x4
    181d:	cmp    rsi,0x12c
    1824:	je     18fd <botlish_fn_20+0x1bd>
    182a:	mov    rcx,rsi
    182d:	shr    rcx,0x3
    1831:	shl    rcx,1
    1834:	or     rcx,0x1
    1838:	mov    edx,0x2
    183d:	cmp    rcx,0xff
    1844:	cmovle rdx,QWORD PTR [rip+0x204]        # 1a50 <botlish_fn_20+0x310>
    184c:	cmp    rdx,0x6
    1850:	je     1860 <botlish_fn_20+0x120>
    1856:	mov    ecx,0x2
    185b:	jmp    188c <botlish_fn_20+0x14c>
    1860:	shr    rsi,0x3
    1864:	shl    rsi,1
    1867:	or     rsi,0x1
    186b:	mov    rdi,r13
    186e:	call   1873 <botlish_fn_20+0x133>
			186f: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<int>
    1873:	cmp    rax,0x6
    1877:	je     1887 <botlish_fn_20+0x147>
    187d:	mov    ecx,0x2
    1882:	jmp    188c <botlish_fn_20+0x14c>
    1887:	mov    ecx,0x6
    188c:	cmp    rcx,0x6
    1890:	je     18a0 <botlish_fn_20+0x160>
    1896:	mov    eax,0x2
    189b:	jmp    1a34 <botlish_fn_20+0x2f4>
    18a0:	mov    QWORD PTR [rsp+0x10],0x3
    18a9:	mov    rsi,r14
    18ac:	test   rsi,0x1
    18b3:	je     18d9 <botlish_fn_20+0x199>
    18b9:	mov    rsi,r14
    18bc:	mov    rcx,rsi
    18bf:	add    rcx,0x2
    18c3:	seto   al
    18c6:	test   al,al
    18c8:	jne    18d9 <botlish_fn_20+0x199>
    18ce:	mov    rsi,rcx
    18d1:	mov    r14,rcx
    18d4:	jmp    18ef <botlish_fn_20+0x1af>
    18d9:	mov    edx,0x3
    18de:	mov    rsi,r14
    18e1:	mov    rdi,r13
    18e4:	call   18e9 <botlish_fn_20+0x1a9>
			18e5: R_X86_64_PLT32	rt_int_add-0x4
    18e9:	mov    rsi,rax
    18ec:	mov    r14,rax
    18ef:	mov    QWORD PTR [rsp],rsi
    18f3:	mov    QWORD PTR [rsp+0x8],r12
    18f8:	jmp    1769 <botlish_fn_20+0x29>
    18fd:	mov    QWORD PTR [rsp+0x10],0x3
    1906:	mov    rsi,r14
    1909:	test   rsi,0x1
    1910:	je     1928 <botlish_fn_20+0x1e8>
    1916:	mov    rsi,r14
    1919:	add    rsi,0x2
    191d:	seto   al
    1920:	test   al,al
    1922:	je     193b <botlish_fn_20+0x1fb>
    1928:	mov    edx,0x3
    192d:	mov    rsi,r14
    1930:	mov    rdi,r13
    1933:	call   1938 <botlish_fn_20+0x1f8>
			1934: R_X86_64_PLT32	rt_int_add-0x4
    1938:	mov    rsi,rax
    193b:	mov    rdx,r12
    193e:	mov    rdi,r13
    1941:	call   1946 <botlish_fn_20+0x206>
			1942: R_X86_64_PLT32	botlish_fn_19-0x4 ; upper_hex?<int>
    1946:	cmp    rax,0x6
    194a:	je     195a <botlish_fn_20+0x21a>
    1950:	mov    ecx,0x2
    1955:	jmp    19be <botlish_fn_20+0x27e>
    195a:	mov    QWORD PTR [rsp+0x10],0x5
    1963:	mov    rsi,r14
    1966:	test   rsi,0x1
    196d:	je     1987 <botlish_fn_20+0x247>
    1973:	mov    rsi,r14
    1976:	add    rsi,0x4
    197a:	seto   r10b
    197e:	test   r10b,r10b
    1981:	je     199a <botlish_fn_20+0x25a>
    1987:	mov    edx,0x5
    198c:	mov    rsi,r14
    198f:	mov    rdi,r13
    1992:	call   1997 <botlish_fn_20+0x257>
			1993: R_X86_64_PLT32	rt_int_add-0x4
    1997:	mov    rsi,rax
    199a:	mov    rdx,r12
    199d:	mov    rdi,r13
    19a0:	call   19a5 <botlish_fn_20+0x265>
			19a1: R_X86_64_PLT32	botlish_fn_19-0x4 ; upper_hex?<int>
    19a5:	cmp    rax,0x6
    19a9:	je     19b9 <botlish_fn_20+0x279>
    19af:	mov    ecx,0x2
    19b4:	jmp    19be <botlish_fn_20+0x27e>
    19b9:	mov    ecx,0x6
    19be:	cmp    rcx,0x6
    19c2:	je     19d2 <botlish_fn_20+0x292>
    19c8:	mov    eax,0x2
    19cd:	jmp    1a34 <botlish_fn_20+0x2f4>
    19d2:	mov    QWORD PTR [rsp+0x10],0x7
    19db:	mov    rsi,r14
    19de:	test   rsi,0x1
    19e5:	je     1a0b <botlish_fn_20+0x2cb>
    19eb:	mov    rsi,r14
    19ee:	mov    rcx,rsi
    19f1:	add    rcx,0x6
    19f5:	seto   al
    19f8:	test   al,al
    19fa:	jne    1a0b <botlish_fn_20+0x2cb>
    1a00:	mov    rsi,rcx
    1a03:	mov    r14,rcx
    1a06:	jmp    1a21 <botlish_fn_20+0x2e1>
    1a0b:	mov    edx,0x7
    1a10:	mov    rsi,r14
    1a13:	mov    rdi,r13
    1a16:	call   1a1b <botlish_fn_20+0x2db>
			1a17: R_X86_64_PLT32	rt_int_add-0x4
    1a1b:	mov    rsi,rax
    1a1e:	mov    r14,rax
    1a21:	mov    QWORD PTR [rsp],rsi
    1a25:	mov    QWORD PTR [rsp+0x8],r12
    1a2a:	jmp    1769 <botlish_fn_20+0x29>
    1a2f:	mov    eax,0x6
    1a34:	mov    r12,QWORD PTR [rsp+0x20]
    1a39:	mov    r13,QWORD PTR [rsp+0x28]
    1a3e:	mov    r14,QWORD PTR [rsp+0x30]
    1a43:	add    rsp,0x40
    1a47:	mov    rsp,rbp
    1a4a:	pop    rbp
    1a4b:	ret
    1a4c:	add    BYTE PTR [rax],al
    1a4e:	add    BYTE PTR [rax],al
    1a50:	(bad)
    1a51:	add    BYTE PTR [rax],al
    1a53:	add    BYTE PTR [rax],al
    1a55:	add    BYTE PTR [rax],al
	...

0000000000001a58 <botlish_entry_20: valid_from?<int>>:
    1a58:	push   rbp
    1a59:	mov    rbp,rsp
    1a5c:	mov    rsi,QWORD PTR [rdx]
    1a5f:	mov    rdx,QWORD PTR [rdx+0x8]
    1a63:	call   1a68 <botlish_entry_20+0x10>
			1a64: R_X86_64_PLT32	botlish_fn_20-0x4 ; valid_from?<int>
    1a68:	mov    rsp,rbp
    1a6b:	pop    rbp
    1a6c:	ret

0000000000001a6d <botlish_fn_21: web::uri_escape_text<str>>:
    1a6d:	push   rbp
    1a6e:	mov    rbp,rsp
    1a71:	sub    rsp,0x10
    1a75:	mov    edx,0x1
    1a7a:	mov    QWORD PTR [rsp],0x1
    1a82:	mov    r10,QWORD PTR [rdi+0x10]
    1a86:	mov    rcx,QWORD PTR [r10+0xd0]
    1a8d:	mov    QWORD PTR [rsp+0x8],rcx
    1a92:	call   1a97 <botlish_fn_21+0x2a>
			1a93: R_X86_64_PLT32	botlish_fn_27-0x4 ; esc_from<str, int, str>
    1a97:	test   rax,rax
    1a9a:	jne    1aac <botlish_fn_21+0x3f>
    1aa0:	xor    rax,rax
    1aa3:	add    rsp,0x10
    1aa7:	mov    rsp,rbp
    1aaa:	pop    rbp
    1aab:	ret
    1aac:	add    rsp,0x10
    1ab0:	mov    rsp,rbp
    1ab3:	pop    rbp
    1ab4:	ret

0000000000001ab5 <botlish_entry_21: web::uri_escape_text<str>>:
    1ab5:	push   rbp
    1ab6:	mov    rbp,rsp
    1ab9:	sub    rsp,0x10
    1abd:	mov    QWORD PTR [rsp],r12
    1ac1:	mov    r12,rdi
    1ac4:	mov    rsi,QWORD PTR [rdx]
    1ac7:	mov    r8,QWORD PTR [rip+0x0]        # 1ace <botlish_entry_21+0x19>
			1aca: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    1ace:	call   r8
    1ad1:	mov    rsi,rax
    1ad4:	mov    rdi,r12
    1ad7:	call   1adc <botlish_entry_21+0x27>
			1ad8: R_X86_64_PLT32	botlish_fn_21-0x4 ; web::uri_escape_text<str>
    1adc:	mov    r12,QWORD PTR [rsp]
    1ae0:	add    rsp,0x10
    1ae4:	mov    rsp,rbp
    1ae7:	pop    rbp
    1ae8:	ret

0000000000001ae9 <botlish_fn_22: high_nibble<int>>:
    1ae9:	push   rbp
    1aea:	mov    rbp,rsp
    1aed:	sub    rsp,0x10
    1af1:	mov    QWORD PTR [rsp],rsi
    1af5:	mov    QWORD PTR [rsp+0x8],0x1e1
    1afe:	test   rsi,0x1
    1b05:	jne    1b1a <botlish_fn_22+0x31>
    1b0b:	mov    edx,0x1e1
    1b10:	call   1b15 <botlish_fn_22+0x2c>
			1b11: R_X86_64_PLT32	rt_int_and-0x4
    1b15:	jmp    1b24 <botlish_fn_22+0x3b>
    1b1a:	and    rsi,0x1e1
    1b21:	mov    rax,rsi
    1b24:	sar    rax,0x5
    1b28:	shl    rax,1
    1b2b:	or     rax,0x1
    1b2f:	add    rsp,0x10
    1b33:	mov    rsp,rbp
    1b36:	pop    rbp
    1b37:	ret

0000000000001b38 <botlish_entry_22: high_nibble<int>>:
    1b38:	push   rbp
    1b39:	mov    rbp,rsp
    1b3c:	mov    rsi,QWORD PTR [rdx]
    1b3f:	call   1b44 <botlish_entry_22+0xc>
			1b40: R_X86_64_PLT32	botlish_fn_22-0x4 ; high_nibble<int>
    1b44:	mov    rsp,rbp
    1b47:	pop    rbp
    1b48:	ret

0000000000001b49 <botlish_fn_23: hex_pair<int>>:
    1b49:	push   rbp
    1b4a:	mov    rbp,rsp
    1b4d:	sub    rsp,0x50
    1b51:	mov    QWORD PTR [rsp+0x30],rbx
    1b56:	mov    QWORD PTR [rsp+0x38],r12
    1b5b:	mov    QWORD PTR [rsp+0x40],r13
    1b60:	mov    QWORD PTR [rsp+0x48],r14
    1b65:	mov    QWORD PTR [rsp],rsi
    1b69:	mov    r14,rsi
    1b6c:	mov    rax,QWORD PTR [rdi+0x30]
    1b70:	mov    r13,rdi
    1b73:	mov    rbx,QWORD PTR [rax+0x8]
    1b77:	mov    QWORD PTR [rsp+0x8],rbx
    1b7c:	mov    rsi,r14
    1b7f:	call   1b84 <botlish_fn_23+0x3b>
			1b80: R_X86_64_PLT32	botlish_fn_22-0x4 ; high_nibble<int>
    1b84:	mov    rcx,QWORD PTR [rbx+0x10]
    1b88:	sar    rax,1
    1b8b:	mov    r12,QWORD PTR [rcx+rax*8]
    1b8f:	mov    QWORD PTR [rsp],r12
    1b93:	mov    rdi,r13
    1b96:	mov    rax,QWORD PTR [rdi+0x30]
    1b9a:	mov    rbx,QWORD PTR [rax+0x8]
    1b9e:	mov    edx,0x21
    1ba3:	mov    rsi,r14
    1ba6:	call   1bab <botlish_fn_23+0x62>
			1ba7: R_X86_64_PLT32	rt_int_mod-0x4
    1bab:	test   rax,rax
    1bae:	je     1c00 <botlish_fn_23+0xb7>
    1bb4:	mov    rcx,QWORD PTR [rbx+0x10]
    1bb8:	sar    rax,1
    1bbb:	mov    rdx,QWORD PTR [rcx+rax*8]
    1bbf:	mov    QWORD PTR [rsp+0x8],rdx
    1bc4:	lea    rcx,[rsp+0x10]
    1bc9:	mov    QWORD PTR [rsp+0x10],0x0
    1bd2:	mov    QWORD PTR [rsp+0x18],r12
    1bd7:	mov    QWORD PTR [rsp+0x20],0x0
    1be0:	mov    QWORD PTR [rsp+0x28],rdx
    1be5:	mov    esi,0x2
    1bea:	mov    edx,0x4
    1bef:	mov    rdi,r13
    1bf2:	call   1bf7 <botlish_fn_23+0xae>
			1bf3: R_X86_64_PLT32	rt_construct-0x4
    1bf7:	test   rax,rax
    1bfa:	jne    1c20 <botlish_fn_23+0xd7>
    1c00:	xor    rax,rax
    1c03:	mov    rbx,QWORD PTR [rsp+0x30]
    1c08:	mov    r12,QWORD PTR [rsp+0x38]
    1c0d:	mov    r13,QWORD PTR [rsp+0x40]
    1c12:	mov    r14,QWORD PTR [rsp+0x48]
    1c17:	add    rsp,0x50
    1c1b:	mov    rsp,rbp
    1c1e:	pop    rbp
    1c1f:	ret
    1c20:	mov    rbx,QWORD PTR [rsp+0x30]
    1c25:	mov    r12,QWORD PTR [rsp+0x38]
    1c2a:	mov    r13,QWORD PTR [rsp+0x40]
    1c2f:	mov    r14,QWORD PTR [rsp+0x48]
    1c34:	add    rsp,0x50
    1c38:	mov    rsp,rbp
    1c3b:	pop    rbp
    1c3c:	ret

0000000000001c3d <botlish_entry_23: hex_pair<int>>:
    1c3d:	push   rbp
    1c3e:	mov    rbp,rsp
    1c41:	sub    rsp,0x10
    1c45:	mov    QWORD PTR [rsp],r12
    1c49:	mov    r12,rdi
    1c4c:	mov    rsi,QWORD PTR [rdx]
    1c4f:	call   1c54 <botlish_entry_23+0x17>
			1c50: R_X86_64_PLT32	botlish_fn_23-0x4 ; hex_pair<int>
    1c54:	mov    r8,QWORD PTR [rip+0x0]        # 1c5b <botlish_entry_23+0x1e>
			1c57: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1c5b:	mov    rsi,rax
    1c5e:	mov    rdi,r12
    1c61:	call   r8
    1c64:	mov    r12,QWORD PTR [rsp]
    1c68:	add    rsp,0x10
    1c6c:	mov    rsp,rbp
    1c6f:	pop    rbp
    1c70:	ret

0000000000001c71 <botlish_fn_24: pct<int>>:
    1c71:	push   rbp
    1c72:	mov    rbp,rsp
    1c75:	sub    rsp,0x40
    1c79:	mov    QWORD PTR [rsp+0x30],r12
    1c7e:	mov    QWORD PTR [rsp+0x38],r13
    1c83:	mov    QWORD PTR [rsp],rsi
    1c87:	mov    rax,QWORD PTR [rdi+0x10]
    1c8b:	mov    r12,rdi
    1c8e:	mov    r13,QWORD PTR [rax+0x10]
    1c92:	mov    QWORD PTR [rsp+0x8],r13
    1c97:	call   1c9c <botlish_fn_24+0x2b>
			1c98: R_X86_64_PLT32	botlish_fn_23-0x4 ; hex_pair<int>
    1c9c:	test   rax,rax
    1c9f:	je     1ce5 <botlish_fn_24+0x74>
    1ca5:	mov    QWORD PTR [rsp],rax
    1ca9:	lea    rcx,[rsp+0x10]
    1cae:	mov    QWORD PTR [rsp+0x10],0x0
    1cb7:	mov    QWORD PTR [rsp+0x18],r13
    1cbc:	mov    QWORD PTR [rsp+0x20],0x0
    1cc5:	mov    QWORD PTR [rsp+0x28],rax
    1cca:	mov    esi,0x2
    1ccf:	mov    edx,0x4
    1cd4:	mov    rdi,r12
    1cd7:	call   1cdc <botlish_fn_24+0x6b>
			1cd8: R_X86_64_PLT32	rt_construct-0x4
    1cdc:	test   rax,rax
    1cdf:	jne    1cfb <botlish_fn_24+0x8a>
    1ce5:	xor    rax,rax
    1ce8:	mov    r12,QWORD PTR [rsp+0x30]
    1ced:	mov    r13,QWORD PTR [rsp+0x38]
    1cf2:	add    rsp,0x40
    1cf6:	mov    rsp,rbp
    1cf9:	pop    rbp
    1cfa:	ret
    1cfb:	mov    r12,QWORD PTR [rsp+0x30]
    1d00:	mov    r13,QWORD PTR [rsp+0x38]
    1d05:	add    rsp,0x40
    1d09:	mov    rsp,rbp
    1d0c:	pop    rbp
    1d0d:	ret

0000000000001d0e <botlish_entry_24: pct<int>>:
    1d0e:	push   rbp
    1d0f:	mov    rbp,rsp
    1d12:	sub    rsp,0x10
    1d16:	mov    QWORD PTR [rsp],r12
    1d1a:	mov    r12,rdi
    1d1d:	mov    rsi,QWORD PTR [rdx]
    1d20:	call   1d25 <botlish_entry_24+0x17>
			1d21: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    1d25:	mov    r8,QWORD PTR [rip+0x0]        # 1d2c <botlish_entry_24+0x1e>
			1d28: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1d2c:	mov    rsi,rax
    1d2f:	mov    rdi,r12
    1d32:	call   r8
    1d35:	mov    r12,QWORD PTR [rsp]
    1d39:	add    rsp,0x10
    1d3d:	mov    rsp,rbp
    1d40:	pop    rbp
    1d41:	ret

0000000000001d42 <botlish_fn_25: cont<int, int>>:
    1d42:	push   rbp
    1d43:	mov    rbp,rsp
    1d46:	sub    rsp,0x30
    1d4a:	mov    QWORD PTR [rsp+0x20],rbx
    1d4f:	mov    rbx,rdi
    1d52:	mov    QWORD PTR [rsp],rsi
    1d56:	mov    QWORD PTR [rsp+0x8],rdx
    1d5b:	mov    QWORD PTR [rsp+0x10],0x101
    1d64:	mov    rdi,rbx
    1d67:	call   1d6c <botlish_fn_25+0x2a>
			1d68: R_X86_64_PLT32	rt_int_shr-0x4
    1d6c:	test   rax,rax
    1d6f:	je     1df2 <botlish_fn_25+0xb0>
    1d75:	mov    QWORD PTR [rsp],rax
    1d79:	mov    QWORD PTR [rsp+0x8],0x7f
    1d82:	test   rax,0x1
    1d88:	mov    rsi,rax
    1d8b:	jne    1da6 <botlish_fn_25+0x64>
    1d91:	mov    edx,0x7f
    1d96:	mov    rdi,rbx
    1d99:	call   1d9e <botlish_fn_25+0x5c>
			1d9a: R_X86_64_PLT32	rt_int_and-0x4
    1d9e:	mov    rdx,rax
    1da1:	jmp    1dad <botlish_fn_25+0x6b>
    1da6:	mov    rdx,rsi
    1da9:	and    rdx,0x7f
    1dad:	mov    QWORD PTR [rsp],rdx
    1db1:	test   rdx,0x1
    1db8:	jne    1dd3 <botlish_fn_25+0x91>
    1dbe:	mov    esi,0x101
    1dc3:	mov    rdi,rbx
    1dc6:	call   1dcb <botlish_fn_25+0x89>
			1dc7: R_X86_64_PLT32	rt_int_or-0x4
    1dcb:	mov    rsi,rax
    1dce:	jmp    1ddd <botlish_fn_25+0x9b>
    1dd3:	or     rdx,0x101
    1dda:	mov    rsi,rdx
    1ddd:	mov    QWORD PTR [rsp],rsi
    1de1:	mov    rdi,rbx
    1de4:	call   1de9 <botlish_fn_25+0xa7>
			1de5: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    1de9:	test   rax,rax
    1dec:	jne    1e03 <botlish_fn_25+0xc1>
    1df2:	xor    rax,rax
    1df5:	mov    rbx,QWORD PTR [rsp+0x20]
    1dfa:	add    rsp,0x30
    1dfe:	mov    rsp,rbp
    1e01:	pop    rbp
    1e02:	ret
    1e03:	mov    rbx,QWORD PTR [rsp+0x20]
    1e08:	add    rsp,0x30
    1e0c:	mov    rsp,rbp
    1e0f:	pop    rbp
    1e10:	ret

0000000000001e11 <botlish_entry_25: cont<int, int>>:
    1e11:	push   rbp
    1e12:	mov    rbp,rsp
    1e15:	sub    rsp,0x10
    1e19:	mov    QWORD PTR [rsp],r12
    1e1d:	mov    r12,rdi
    1e20:	mov    rsi,QWORD PTR [rdx]
    1e23:	mov    rdx,QWORD PTR [rdx+0x8]
    1e27:	call   1e2c <botlish_entry_25+0x1b>
			1e28: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    1e2c:	mov    r8,QWORD PTR [rip+0x0]        # 1e33 <botlish_entry_25+0x22>
			1e2f: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1e33:	mov    rsi,rax
    1e36:	mov    rdi,r12
    1e39:	call   r8
    1e3c:	mov    r12,QWORD PTR [rsp]
    1e40:	add    rsp,0x10
    1e44:	mov    rsp,rbp
    1e47:	pop    rbp
    1e48:	ret
    1e49:	add    BYTE PTR [rax],al
    1e4b:	add    BYTE PTR [rax],al
    1e4d:	add    BYTE PTR [rax],al
	...

0000000000001e50 <botlish_fn_26: esc_scalar<int>>:
    1e50:	push   rbp
    1e51:	mov    rbp,rsp
    1e54:	sub    rsp,0xf0
    1e5b:	mov    QWORD PTR [rsp+0xc0],rbx
    1e63:	mov    QWORD PTR [rsp+0xc8],r12
    1e6b:	mov    QWORD PTR [rsp+0xd0],r13
    1e73:	mov    QWORD PTR [rsp+0xd8],r14
    1e7b:	mov    QWORD PTR [rsp+0xe0],r15
    1e83:	mov    rbx,rdi
    1e86:	mov    QWORD PTR [rsp+0x18],0x0
    1e8f:	mov    QWORD PTR [rsp+0x20],0x0
    1e98:	mov    QWORD PTR [rsp],rsi
    1e9c:	test   rsi,0x1
    1ea3:	mov    r12,rsi
    1ea6:	jne    1ed2 <botlish_fn_26+0x82>
    1eac:	mov    edx,0x1001
    1eb1:	mov    rsi,r12
    1eb4:	mov    rdi,rbx
    1eb7:	call   1ebc <botlish_fn_26+0x6c>
			1eb8: R_X86_64_PLT32	rt_int_cmp-0x4
    1ebc:	mov    r11d,0x2
    1ec2:	test   rax,rax
    1ec5:	cmovl  r11,QWORD PTR [rip+0x3fb]        # 22c8 <botlish_fn_26+0x478>
    1ecd:	jmp    1eea <botlish_fn_26+0x9a>
    1ed2:	mov    r11d,0x2
    1ed8:	mov    rsi,r12
    1edb:	cmp    rsi,0x1001
    1ee2:	cmovl  r11,QWORD PTR [rip+0x3de]        # 22c8 <botlish_fn_26+0x478>
    1eea:	mov    edx,0x6
    1eef:	mov    r13,rdx
    1ef2:	cmp    r11,0x6
    1ef6:	je     21b0 <botlish_fn_26+0x360>
    1efc:	mov    rsi,r12
    1eff:	test   rsi,0x1
    1f06:	jne    1f31 <botlish_fn_26+0xe1>
    1f0c:	mov    edx,0x20001
    1f11:	mov    rsi,r12
    1f14:	mov    rdi,rbx
    1f17:	call   1f1c <botlish_fn_26+0xcc>
			1f18: R_X86_64_PLT32	rt_int_cmp-0x4
    1f1c:	mov    ecx,0x2
    1f21:	test   rax,rax
    1f24:	cmovl  rcx,QWORD PTR [rip+0x39c]        # 22c8 <botlish_fn_26+0x478>
    1f2c:	jmp    1f48 <botlish_fn_26+0xf8>
    1f31:	mov    ecx,0x2
    1f36:	mov    rsi,r12
    1f39:	cmp    rsi,0x20001
    1f40:	cmovl  rcx,QWORD PTR [rip+0x380]        # 22c8 <botlish_fn_26+0x478>
    1f48:	cmp    rcx,0x6
    1f4c:	je     20c3 <botlish_fn_26+0x273>
    1f52:	mov    QWORD PTR [rsp+0x8],0x1e1
    1f5b:	mov    edx,0x25
    1f60:	mov    QWORD PTR [rsp+0x10],0x25
    1f69:	mov    rsi,r12
    1f6c:	mov    rdi,rbx
    1f6f:	call   1f74 <botlish_fn_26+0x124>
			1f70: R_X86_64_PLT32	rt_int_shr-0x4
    1f74:	test   rax,rax
    1f77:	je     2259 <botlish_fn_26+0x409>
    1f7d:	mov    QWORD PTR [rsp+0x10],rax
    1f82:	test   rax,0x1
    1f88:	mov    rdx,rax
    1f8b:	jne    1fa6 <botlish_fn_26+0x156>
    1f91:	mov    esi,0x1e1
    1f96:	mov    rdi,rbx
    1f99:	call   1f9e <botlish_fn_26+0x14e>
			1f9a: R_X86_64_PLT32	rt_int_or-0x4
    1f9e:	mov    rsi,rax
    1fa1:	jmp    1fb0 <botlish_fn_26+0x160>
    1fa6:	mov    rsi,rdx
    1fa9:	or     rsi,0x1e1
    1fb0:	mov    QWORD PTR [rsp+0x8],rsi
    1fb5:	mov    rdi,rbx
    1fb8:	call   1fbd <botlish_fn_26+0x16d>
			1fb9: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    1fbd:	test   rax,rax
    1fc0:	je     2259 <botlish_fn_26+0x409>
    1fc6:	mov    QWORD PTR [rsp+0x8],rax
    1fcb:	mov    r13,rax
    1fce:	mov    edx,0x19
    1fd3:	mov    QWORD PTR [rsp+0x10],0x19
    1fdc:	mov    rsi,r12
    1fdf:	mov    rdi,rbx
    1fe2:	call   1fe7 <botlish_fn_26+0x197>
			1fe3: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    1fe7:	test   rax,rax
    1fea:	je     2259 <botlish_fn_26+0x409>
    1ff0:	mov    QWORD PTR [rsp+0x10],rax
    1ff5:	mov    r14,rax
    1ff8:	mov    edx,0xd
    1ffd:	mov    QWORD PTR [rsp+0x18],0xd
    2006:	mov    rsi,r12
    2009:	mov    rdi,rbx
    200c:	call   2011 <botlish_fn_26+0x1c1>
			200d: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    2011:	test   rax,rax
    2014:	je     2259 <botlish_fn_26+0x409>
    201a:	mov    QWORD PTR [rsp+0x18],rax
    201f:	mov    r15,rax
    2022:	mov    edx,0x1
    2027:	mov    QWORD PTR [rsp+0x20],0x1
    2030:	mov    rsi,r12
    2033:	mov    rdi,rbx
    2036:	call   203b <botlish_fn_26+0x1eb>
			2037: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    203b:	test   rax,rax
    203e:	je     2259 <botlish_fn_26+0x409>
    2044:	mov    QWORD PTR [rsp],rax
    2048:	lea    rcx,[rsp+0x78]
    204d:	mov    QWORD PTR [rsp+0x78],0x0
    2056:	mov    rdx,r13
    2059:	mov    QWORD PTR [rsp+0x80],rdx
    2061:	mov    QWORD PTR [rsp+0x88],0x0
    206d:	mov    rdx,r14
    2070:	mov    QWORD PTR [rsp+0x90],rdx
    2078:	mov    QWORD PTR [rsp+0x98],0x0
    2084:	mov    rdx,r15
    2087:	mov    QWORD PTR [rsp+0xa0],rdx
    208f:	mov    QWORD PTR [rsp+0xa8],0x0
    209b:	mov    QWORD PTR [rsp+0xb0],rax
    20a3:	mov    esi,0x2
    20a8:	mov    edx,0x8
    20ad:	mov    rdi,rbx
    20b0:	call   20b5 <botlish_fn_26+0x265>
			20b1: R_X86_64_PLT32	rt_construct-0x4
    20b5:	test   rax,rax
    20b8:	je     2259 <botlish_fn_26+0x409>
    20be:	jmp    2290 <botlish_fn_26+0x440>
    20c3:	mov    QWORD PTR [rsp+0x8],0x1c1
    20cc:	mov    edx,0xd
    20d1:	mov    rsi,r12
    20d4:	mov    r14,rdx
    20d7:	sar    rsi,0xd
    20db:	shl    rsi,1
    20de:	mov    rax,rsi
    20e1:	or     rax,0x1
    20e5:	mov    QWORD PTR [rsp+0x10],rax
    20ea:	or     rsi,0x1c1
    20f1:	mov    QWORD PTR [rsp+0x8],rsi
    20f6:	mov    rdi,rbx
    20f9:	call   20fe <botlish_fn_26+0x2ae>
			20fa: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    20fe:	test   rax,rax
    2101:	je     2259 <botlish_fn_26+0x409>
    2107:	mov    QWORD PTR [rsp+0x8],rax
    210c:	mov    r15,rax
    210f:	mov    QWORD PTR [rsp+0x10],0xd
    2118:	mov    rdx,r14
    211b:	mov    rsi,r12
    211e:	mov    rdi,rbx
    2121:	call   2126 <botlish_fn_26+0x2d6>
			2122: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    2126:	test   rax,rax
    2129:	je     2259 <botlish_fn_26+0x409>
    212f:	mov    QWORD PTR [rsp+0x10],rax
    2134:	mov    r14,rax
    2137:	mov    edx,0x1
    213c:	mov    QWORD PTR [rsp+0x18],0x1
    2145:	mov    rsi,r12
    2148:	mov    rdi,rbx
    214b:	call   2150 <botlish_fn_26+0x300>
			214c: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    2150:	test   rax,rax
    2153:	je     2259 <botlish_fn_26+0x409>
    2159:	mov    QWORD PTR [rsp],rax
    215d:	lea    rcx,[rsp+0x48]
    2162:	mov    QWORD PTR [rsp+0x48],0x0
    216b:	mov    rdx,r15
    216e:	mov    QWORD PTR [rsp+0x50],rdx
    2173:	mov    QWORD PTR [rsp+0x58],0x0
    217c:	mov    rdx,r14
    217f:	mov    QWORD PTR [rsp+0x60],rdx
    2184:	mov    QWORD PTR [rsp+0x68],0x0
    218d:	mov    QWORD PTR [rsp+0x70],rax
    2192:	mov    esi,0x2
    2197:	mov    rdx,r13
    219a:	mov    rdi,rbx
    219d:	call   21a2 <botlish_fn_26+0x352>
			219e: R_X86_64_PLT32	rt_construct-0x4
    21a2:	test   rax,rax
    21a5:	je     2259 <botlish_fn_26+0x409>
    21ab:	jmp    2290 <botlish_fn_26+0x440>
    21b0:	mov    QWORD PTR [rsp+0x8],0x181
    21b9:	mov    rsi,r12
    21bc:	sar    rsi,0x7
    21c0:	shl    rsi,1
    21c3:	mov    rax,rsi
    21c6:	or     rax,0x1
    21ca:	mov    QWORD PTR [rsp+0x10],rax
    21cf:	or     rsi,0x181
    21d6:	mov    QWORD PTR [rsp+0x8],rsi
    21db:	mov    rdi,rbx
    21de:	call   21e3 <botlish_fn_26+0x393>
			21df: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    21e3:	test   rax,rax
    21e6:	je     2259 <botlish_fn_26+0x409>
    21ec:	mov    QWORD PTR [rsp+0x8],rax
    21f1:	mov    r13,rax
    21f4:	mov    edx,0x1
    21f9:	mov    QWORD PTR [rsp+0x10],0x1
    2202:	mov    rsi,r12
    2205:	mov    rdi,rbx
    2208:	call   220d <botlish_fn_26+0x3bd>
			2209: R_X86_64_PLT32	botlish_fn_25-0x4 ; cont<int, int>
    220d:	test   rax,rax
    2210:	je     2259 <botlish_fn_26+0x409>
    2216:	mov    QWORD PTR [rsp],rax
    221a:	lea    rcx,[rsp+0x28]
    221f:	mov    QWORD PTR [rsp+0x28],0x0
    2228:	mov    rdx,r13
    222b:	mov    QWORD PTR [rsp+0x30],rdx
    2230:	mov    QWORD PTR [rsp+0x38],0x0
    2239:	mov    QWORD PTR [rsp+0x40],rax
    223e:	mov    esi,0x2
    2243:	mov    edx,0x4
    2248:	mov    rdi,rbx
    224b:	call   2250 <botlish_fn_26+0x400>
			224c: R_X86_64_PLT32	rt_construct-0x4
    2250:	test   rax,rax
    2253:	jne    2290 <botlish_fn_26+0x440>
    2259:	xor    rax,rax
    225c:	mov    rbx,QWORD PTR [rsp+0xc0]
    2264:	mov    r12,QWORD PTR [rsp+0xc8]
    226c:	mov    r13,QWORD PTR [rsp+0xd0]
    2274:	mov    r14,QWORD PTR [rsp+0xd8]
    227c:	mov    r15,QWORD PTR [rsp+0xe0]
    2284:	add    rsp,0xf0
    228b:	mov    rsp,rbp
    228e:	pop    rbp
    228f:	ret
    2290:	mov    rbx,QWORD PTR [rsp+0xc0]
    2298:	mov    r12,QWORD PTR [rsp+0xc8]
    22a0:	mov    r13,QWORD PTR [rsp+0xd0]
    22a8:	mov    r14,QWORD PTR [rsp+0xd8]
    22b0:	mov    r15,QWORD PTR [rsp+0xe0]
    22b8:	add    rsp,0xf0
    22bf:	mov    rsp,rbp
    22c2:	pop    rbp
    22c3:	ret
    22c4:	add    BYTE PTR [rax],al
    22c6:	add    BYTE PTR [rax],al
    22c8:	(bad)
    22c9:	add    BYTE PTR [rax],al
    22cb:	add    BYTE PTR [rax],al
    22cd:	add    BYTE PTR [rax],al
	...

00000000000022d0 <botlish_entry_26: esc_scalar<int>>:
    22d0:	push   rbp
    22d1:	mov    rbp,rsp
    22d4:	sub    rsp,0x10
    22d8:	mov    QWORD PTR [rsp],r12
    22dc:	mov    r12,rdi
    22df:	mov    rsi,QWORD PTR [rdx]
    22e2:	call   22e7 <botlish_entry_26+0x17>
			22e3: R_X86_64_PLT32	botlish_fn_26-0x4 ; esc_scalar<int>
    22e7:	mov    r8,QWORD PTR [rip+0x0]        # 22ee <botlish_entry_26+0x1e>
			22ea: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    22ee:	mov    rsi,rax
    22f1:	mov    rdi,r12
    22f4:	call   r8
    22f7:	mov    r12,QWORD PTR [rsp]
    22fb:	add    rsp,0x10
    22ff:	mov    rsp,rbp
    2302:	pop    rbp
    2303:	ret
    2304:	add    BYTE PTR [rax],al
	...

0000000000002308 <botlish_fn_27: esc_from<str, int, str>>:
    2308:	push   rbp
    2309:	mov    rbp,rsp
    230c:	sub    rsp,0x110
    2313:	mov    QWORD PTR [rsp+0xe0],rbx
    231b:	mov    QWORD PTR [rsp+0xe8],r12
    2323:	mov    QWORD PTR [rsp+0xf0],r13
    232b:	mov    QWORD PTR [rsp+0xf8],r14
    2333:	mov    QWORD PTR [rsp+0x100],r15
    233b:	mov    QWORD PTR [rsp+0xa8],rdi
    2343:	mov    QWORD PTR [rsp+0x10],0x0
    234c:	mov    QWORD PTR [rsp+0x18],0x0
    2355:	mov    QWORD PTR [rsp+0x20],0x0
    235e:	mov    QWORD PTR [rsp],rdx
    2362:	mov    QWORD PTR [rsp+0x8],rcx
    2367:	mov    r15,rcx
    236a:	mov    r14d,0x47
    2370:	mov    rcx,0xffffffffffffffff
    2377:	bsr    rax,rsi
    237b:	mov    QWORD PTR [rsp+0xb0],rsi
    2383:	cmove  rax,rcx
    2387:	mov    ecx,0x3f
    238c:	sub    rcx,rax
    238f:	sub    r14,rcx
    2392:	shr    r14,0x3
    2396:	shl    r14,1
    2399:	lea    rbx,[rsp+0x88]
    23a1:	lea    r12,[rsp+0x58]
    23a6:	lea    r13,[rsp+0x38]
    23ab:	mov    rsi,rdx
    23ae:	mov    rax,r14
    23b1:	or     rax,0x1
    23b5:	mov    rcx,rsi
    23b8:	and    rcx,rax
    23bb:	mov    QWORD PTR [rsp+0xb8],rsi
    23c3:	test   rcx,0x1
    23ca:	jne    2401 <botlish_fn_27+0xf9>
    23d0:	mov    rdx,r14
    23d3:	or     rdx,0x1
    23d7:	mov    rsi,QWORD PTR [rsp+0xb8]
    23df:	mov    rdi,QWORD PTR [rsp+0xa8]
    23e7:	call   23ec <botlish_fn_27+0xe4>
			23e8: R_X86_64_PLT32	rt_int_cmp-0x4
    23ec:	mov    ecx,0x2
    23f1:	test   rax,rax
    23f4:	cmovge rcx,QWORD PTR [rip+0x4c4]        # 28c0 <botlish_fn_27+0x5b8>
    23fc:	jmp    2420 <botlish_fn_27+0x118>
    2401:	mov    rax,r14
    2404:	or     rax,0x1
    2408:	mov    ecx,0x2
    240d:	mov    rsi,QWORD PTR [rsp+0xb8]
    2415:	cmp    rsi,rax
    2418:	cmovge rcx,QWORD PTR [rip+0x4a0]        # 28c0 <botlish_fn_27+0x5b8>
    2420:	cmp    rcx,0x6
    2424:	je     2434 <botlish_fn_27+0x12c>
    242a:	mov    eax,0x2
    242f:	jmp    2439 <botlish_fn_27+0x131>
    2434:	mov    eax,0x6
    2439:	cmp    rax,0x6
    243d:	je     2823 <botlish_fn_27+0x51b>
    2443:	mov    rsi,QWORD PTR [rsp+0xb0]
    244b:	mov    rdi,QWORD PTR [rsp+0xa8]
    2453:	call   2458 <botlish_fn_27+0x150>
			2454: R_X86_64_PLT32	rt_ascii_to_str-0x4
    2458:	mov    QWORD PTR [rsp+0xd0],rax
    2460:	mov    QWORD PTR [rsp+0x10],rax
    2465:	movzx  rcx,BYTE PTR [rax+0x18]
    246a:	test   rcx,rcx
    246d:	jne    2498 <botlish_fn_27+0x190>
    2473:	mov    rdx,QWORD PTR [rsp+0xb8]
    247b:	mov    rsi,QWORD PTR [rsp+0xd0]
    2483:	mov    rdi,QWORD PTR [rsp+0xa8]
    248b:	call   2490 <botlish_fn_27+0x188>
			248c: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    2490:	mov    rsi,rax
    2493:	jmp    24bc <botlish_fn_27+0x1b4>
    2498:	mov    rsi,QWORD PTR [rsp+0xb8]
    24a0:	mov    rcx,rsi
    24a3:	sar    rcx,1
    24a6:	mov    rax,QWORD PTR [rsp+0xd0]
    24ae:	movzx  rsi,BYTE PTR [rax+rcx*1+0x19]
    24b4:	shl    rsi,0x3
    24b8:	or     rsi,0x4
    24bc:	shr    rsi,0x3
    24c0:	shl    rsi,1
    24c3:	or     rsi,0x1
    24c7:	mov    QWORD PTR [rsp+0x10],rsi
    24cc:	mov    edi,0x2
    24d1:	cmp    rsi,0xff
    24d8:	mov    QWORD PTR [rsp+0xc8],rsi
    24e0:	cmovg  rdi,QWORD PTR [rip+0x3d8]        # 28c0 <botlish_fn_27+0x5b8>
    24e8:	cmp    rdi,0x6
    24ec:	je     2737 <botlish_fn_27+0x42f>
    24f2:	mov    rsi,QWORD PTR [rsp+0xc8]
    24fa:	mov    rdi,QWORD PTR [rsp+0xa8]
    2502:	call   2507 <botlish_fn_27+0x1ff>
			2503: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<int>
    2507:	cmp    rax,0x6
    250b:	je     2609 <botlish_fn_27+0x301>
    2511:	mov    QWORD PTR [rsp+0x18],0x3
    251a:	mov    rsi,QWORD PTR [rsp+0xb8]
    2522:	test   rsi,0x1
    2529:	je     2559 <botlish_fn_27+0x251>
    252f:	mov    rsi,QWORD PTR [rsp+0xb8]
    2537:	mov    rax,rsi
    253a:	add    rax,0x2
    253e:	seto   cl
    2541:	test   cl,cl
    2543:	jne    2559 <botlish_fn_27+0x251>
    2549:	mov    rsi,rax
    254c:	mov    QWORD PTR [rsp+0xb8],rax
    2554:	jmp    257e <botlish_fn_27+0x276>
    2559:	mov    edx,0x3
    255e:	mov    rsi,QWORD PTR [rsp+0xb8]
    2566:	mov    rdi,QWORD PTR [rsp+0xa8]
    256e:	call   2573 <botlish_fn_27+0x26b>
			256f: R_X86_64_PLT32	rt_int_add-0x4
    2573:	mov    rsi,rax
    2576:	mov    QWORD PTR [rsp+0xb8],rax
    257e:	mov    QWORD PTR [rsp],rsi
    2582:	mov    rsi,QWORD PTR [rsp+0xc8]
    258a:	mov    rdi,QWORD PTR [rsp+0xa8]
    2592:	call   2597 <botlish_fn_27+0x28f>
			2593: R_X86_64_PLT32	botlish_fn_24-0x4 ; pct<int>
    2597:	test   rax,rax
    259a:	je     2854 <botlish_fn_27+0x54c>
    25a0:	mov    QWORD PTR [rsp+0x10],rax
    25a5:	mov    QWORD PTR [rsp+0x88],0x0
    25b1:	mov    QWORD PTR [rsp+0x90],r15
    25b9:	mov    QWORD PTR [rsp+0x98],0x0
    25c5:	mov    QWORD PTR [rsp+0xa0],rax
    25cd:	mov    esi,0x2
    25d2:	mov    edx,0x4
    25d7:	mov    rcx,rbx
    25da:	mov    rdi,QWORD PTR [rsp+0xa8]
    25e2:	call   25e7 <botlish_fn_27+0x2df>
			25e3: R_X86_64_PLT32	rt_construct-0x4
    25e7:	test   rax,rax
    25ea:	je     2854 <botlish_fn_27+0x54c>
    25f0:	mov    rsi,QWORD PTR [rsp+0xb8]
    25f8:	mov    QWORD PTR [rsp],rsi
    25fc:	mov    QWORD PTR [rsp+0x8],rax
    2601:	mov    r15,rax
    2604:	jmp    23ae <botlish_fn_27+0xa6>
    2609:	mov    QWORD PTR [rsp+0x18],0x3
    2612:	mov    rsi,QWORD PTR [rsp+0xb8]
    261a:	test   rsi,0x1
    2621:	je     2641 <botlish_fn_27+0x339>
    2627:	mov    rsi,QWORD PTR [rsp+0xb8]
    262f:	mov    rax,rsi
    2632:	add    rax,0x2
    2636:	seto   cl
    2639:	test   cl,cl
    263b:	je     265b <botlish_fn_27+0x353>
    2641:	mov    edx,0x3
    2646:	mov    rsi,QWORD PTR [rsp+0xb8]
    264e:	mov    rdi,QWORD PTR [rsp+0xa8]
    2656:	call   265b <botlish_fn_27+0x353>
			2657: R_X86_64_PLT32	rt_int_add-0x4
    265b:	mov    QWORD PTR [rsp+0x18],rax
    2660:	mov    QWORD PTR [rsp+0xc0],rax
    2668:	mov    QWORD PTR [rsp+0x20],0x3
    2671:	mov    rsi,QWORD PTR [rsp+0xb8]
    2679:	test   rsi,0x1
    2680:	je     26a0 <botlish_fn_27+0x398>
    2686:	mov    rsi,QWORD PTR [rsp+0xb8]
    268e:	mov    rax,rsi
    2691:	add    rax,0x2
    2695:	seto   cl
    2698:	test   cl,cl
    269a:	je     26ba <botlish_fn_27+0x3b2>
    26a0:	mov    edx,0x3
    26a5:	mov    rsi,QWORD PTR [rsp+0xb8]
    26ad:	mov    rdi,QWORD PTR [rsp+0xa8]
    26b5:	call   26ba <botlish_fn_27+0x3b2>
			26b6: R_X86_64_PLT32	rt_int_add-0x4
    26ba:	mov    QWORD PTR [rsp+0x20],rax
    26bf:	mov    QWORD PTR [rsp+0x58],0x0
    26c8:	mov    QWORD PTR [rsp+0x60],r15
    26cd:	mov    QWORD PTR [rsp+0x68],0x1
    26d6:	mov    rcx,QWORD PTR [rsp+0xd0]
    26de:	mov    QWORD PTR [rsp+0x70],rcx
    26e3:	mov    rsi,QWORD PTR [rsp+0xb8]
    26eb:	mov    QWORD PTR [rsp+0x78],rsi
    26f0:	mov    QWORD PTR [rsp+0x80],rax
    26f8:	mov    esi,0x2
    26fd:	mov    edx,0x6
    2702:	mov    rcx,r12
    2705:	mov    rdi,QWORD PTR [rsp+0xa8]
    270d:	call   2712 <botlish_fn_27+0x40a>
			270e: R_X86_64_PLT32	rt_construct-0x4
    2712:	test   rax,rax
    2715:	je     2854 <botlish_fn_27+0x54c>
    271b:	mov    rdi,QWORD PTR [rsp+0xc0]
    2723:	mov    QWORD PTR [rsp],rdi
    2727:	mov    QWORD PTR [rsp+0x8],rax
    272c:	mov    rsi,rdi
    272f:	mov    r15,rax
    2732:	jmp    23ae <botlish_fn_27+0xa6>
    2737:	mov    QWORD PTR [rsp+0x18],0x3
    2740:	mov    rsi,QWORD PTR [rsp+0xb8]
    2748:	test   rsi,0x1
    274f:	je     277f <botlish_fn_27+0x477>
    2755:	mov    rsi,QWORD PTR [rsp+0xb8]
    275d:	mov    rax,rsi
    2760:	add    rax,0x2
    2764:	seto   cl
    2767:	test   cl,cl
    2769:	jne    277f <botlish_fn_27+0x477>
    276f:	mov    rsi,rax
    2772:	mov    QWORD PTR [rsp+0xb8],rax
    277a:	jmp    27a4 <botlish_fn_27+0x49c>
    277f:	mov    edx,0x3
    2784:	mov    rsi,QWORD PTR [rsp+0xb8]
    278c:	mov    rdi,QWORD PTR [rsp+0xa8]
    2794:	call   2799 <botlish_fn_27+0x491>
			2795: R_X86_64_PLT32	rt_int_add-0x4
    2799:	mov    rsi,rax
    279c:	mov    QWORD PTR [rsp+0xb8],rax
    27a4:	mov    QWORD PTR [rsp],rsi
    27a8:	mov    rsi,QWORD PTR [rsp+0xc8]
    27b0:	mov    rdi,QWORD PTR [rsp+0xa8]
    27b8:	call   27bd <botlish_fn_27+0x4b5>
			27b9: R_X86_64_PLT32	botlish_fn_26-0x4 ; esc_scalar<int>
    27bd:	test   rax,rax
    27c0:	je     2854 <botlish_fn_27+0x54c>
    27c6:	mov    QWORD PTR [rsp+0x10],rax
    27cb:	mov    QWORD PTR [rsp+0x38],0x0
    27d4:	mov    QWORD PTR [rsp+0x40],r15
    27d9:	mov    QWORD PTR [rsp+0x48],0x0
    27e2:	mov    QWORD PTR [rsp+0x50],rax
    27e7:	mov    esi,0x2
    27ec:	mov    edx,0x4
    27f1:	mov    rcx,r13
    27f4:	mov    rdi,QWORD PTR [rsp+0xa8]
    27fc:	call   2801 <botlish_fn_27+0x4f9>
			27fd: R_X86_64_PLT32	rt_construct-0x4
    2801:	test   rax,rax
    2804:	je     2854 <botlish_fn_27+0x54c>
    280a:	mov    rsi,QWORD PTR [rsp+0xb8]
    2812:	mov    QWORD PTR [rsp],rsi
    2816:	mov    QWORD PTR [rsp+0x8],rax
    281b:	mov    r15,rax
    281e:	jmp    23ae <botlish_fn_27+0xa6>
    2823:	xor    rsi,rsi
    2826:	lea    rcx,[rsp+0x28]
    282b:	mov    QWORD PTR [rsp+0x28],0x0
    2834:	mov    QWORD PTR [rsp+0x30],r15
    2839:	mov    edx,0x2
    283e:	mov    rdi,QWORD PTR [rsp+0xa8]
    2846:	call   284b <botlish_fn_27+0x543>
			2847: R_X86_64_PLT32	rt_construct-0x4
    284b:	test   rax,rax
    284e:	jne    288b <botlish_fn_27+0x583>
    2854:	xor    rax,rax
    2857:	mov    rbx,QWORD PTR [rsp+0xe0]
    285f:	mov    r12,QWORD PTR [rsp+0xe8]
    2867:	mov    r13,QWORD PTR [rsp+0xf0]
    286f:	mov    r14,QWORD PTR [rsp+0xf8]
    2877:	mov    r15,QWORD PTR [rsp+0x100]
    287f:	add    rsp,0x110
    2886:	mov    rsp,rbp
    2889:	pop    rbp
    288a:	ret
    288b:	mov    rbx,QWORD PTR [rsp+0xe0]
    2893:	mov    r12,QWORD PTR [rsp+0xe8]
    289b:	mov    r13,QWORD PTR [rsp+0xf0]
    28a3:	mov    r14,QWORD PTR [rsp+0xf8]
    28ab:	mov    r15,QWORD PTR [rsp+0x100]
    28b3:	add    rsp,0x110
    28ba:	mov    rsp,rbp
    28bd:	pop    rbp
    28be:	ret
    28bf:	add    BYTE PTR [rsi],al
    28c1:	add    BYTE PTR [rax],al
    28c3:	add    BYTE PTR [rax],al
    28c5:	add    BYTE PTR [rax],al
	...

00000000000028c8 <botlish_entry_27: esc_from<str, int, str>>:
    28c8:	push   rbp
    28c9:	mov    rbp,rsp
    28cc:	sub    rsp,0x10
    28d0:	mov    QWORD PTR [rsp],r12
    28d4:	mov    QWORD PTR [rsp+0x8],r13
    28d9:	mov    r12,rdi
    28dc:	mov    rsi,QWORD PTR [rdx]
    28df:	mov    r13,rdx
    28e2:	mov    r8,QWORD PTR [rip+0x0]        # 28e9 <botlish_entry_27+0x21>
			28e5: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    28e9:	call   r8
    28ec:	mov    rcx,r13
    28ef:	mov    rdx,QWORD PTR [rcx+0x8]
    28f3:	mov    rcx,QWORD PTR [rcx+0x10]
    28f7:	mov    rsi,rax
    28fa:	mov    rdi,r12
    28fd:	call   2902 <botlish_entry_27+0x3a>
			28fe: R_X86_64_PLT32	botlish_fn_27-0x4 ; esc_from<str, int, str>
    2902:	mov    r12,QWORD PTR [rsp]
    2906:	mov    r13,QWORD PTR [rsp+0x8]
    290b:	add    rsp,0x10
    290f:	mov    rsp,rbp
    2912:	pop    rbp
    2913:	ret

0000000000002914 <botlish_fn_28: check<int, int, str, str>>:
    2914:	push   rbp
    2915:	mov    rbp,rsp
    2918:	sub    rsp,0x50
    291c:	mov    QWORD PTR [rsp+0x20],rbx
    2921:	mov    QWORD PTR [rsp+0x28],r12
    2926:	mov    QWORD PTR [rsp+0x30],r13
    292b:	mov    QWORD PTR [rsp+0x38],r14
    2930:	mov    QWORD PTR [rsp+0x40],r15
    2935:	mov    r14,rdi
    2938:	mov    QWORD PTR [rsp+0x18],0x0
    2941:	mov    QWORD PTR [rsp],rdx
    2945:	mov    QWORD PTR [rsp+0x8],rcx
    294a:	mov    QWORD PTR [rsp+0x10],r8
    294f:	mov    r12,r8
    2952:	mov    r13,rsi
    2955:	mov    r15,rdx
    2958:	test   r13,r13
    295b:	jle    2a35 <botlish_fn_28+0x121>
    2961:	mov    rbx,rcx
    2964:	mov    rsi,rbx
    2967:	mov    rdi,r14
    296a:	call   296f <botlish_fn_28+0x5b>
			296b: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::emailish?<str>
    296f:	test   rax,rax
    2972:	jne    299d <botlish_fn_28+0x89>
    2978:	xor    rax,rax
    297b:	mov    rbx,QWORD PTR [rsp+0x20]
    2980:	mov    r12,QWORD PTR [rsp+0x28]
    2985:	mov    r13,QWORD PTR [rsp+0x30]
    298a:	mov    r14,QWORD PTR [rsp+0x38]
    298f:	mov    r15,QWORD PTR [rsp+0x40]
    2994:	add    rsp,0x50
    2998:	mov    rsp,rbp
    299b:	pop    rbp
    299c:	ret
    299d:	cmp    rax,0x6
    29a1:	je     29bd <botlish_fn_28+0xa9>
    29a7:	mov    edx,0x1
    29ac:	mov    QWORD PTR [rsp+0x18],0x1
    29b5:	mov    rsi,r15
    29b8:	jmp    29e9 <botlish_fn_28+0xd5>
    29bd:	mov    rsi,r12
    29c0:	mov    rdi,r14
    29c3:	call   29c8 <botlish_fn_28+0xb4>
			29c4: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::uri_query_value?<str>
    29c8:	cmp    rax,0x6
    29cc:	je     29dc <botlish_fn_28+0xc8>
    29d2:	mov    edx,0x1
    29d7:	jmp    29e1 <botlish_fn_28+0xcd>
    29dc:	mov    edx,0x3
    29e1:	mov    QWORD PTR [rsp+0x18],rdx
    29e6:	mov    rsi,r15
    29e9:	mov    rax,rsi
    29ec:	and    rax,rdx
    29ef:	test   rax,0x1
    29f5:	je     2a10 <botlish_fn_28+0xfc>
    29fb:	lea    rcx,[rdx-0x1]
    29ff:	mov    rax,rsi
    2a02:	add    rax,rcx
    2a05:	seto   cl
    2a08:	test   cl,cl
    2a0a:	je     2a18 <botlish_fn_28+0x104>
    2a10:	mov    rdi,r14
    2a13:	call   2a18 <botlish_fn_28+0x104>
			2a14: R_X86_64_PLT32	rt_int_add-0x4
    2a18:	mov    QWORD PTR [rsp],rax
    2a1c:	mov    QWORD PTR [rsp+0x8],rbx
    2a21:	mov    QWORD PTR [rsp+0x10],r12
    2a26:	sub    r13,0x1
    2a2a:	mov    rcx,rbx
    2a2d:	mov    r15,rax
    2a30:	jmp    2958 <botlish_fn_28+0x44>
    2a35:	mov    rax,r15
    2a38:	mov    rbx,QWORD PTR [rsp+0x20]
    2a3d:	mov    r12,QWORD PTR [rsp+0x28]
    2a42:	mov    r13,QWORD PTR [rsp+0x30]
    2a47:	mov    r14,QWORD PTR [rsp+0x38]
    2a4c:	mov    r15,QWORD PTR [rsp+0x40]
    2a51:	add    rsp,0x50
    2a55:	mov    rsp,rbp
    2a58:	pop    rbp
    2a59:	ret

0000000000002a5a <botlish_entry_28: check<int, int, str, str>>:
    2a5a:	push   rbp
    2a5b:	mov    rbp,rsp
    2a5e:	mov    rsi,QWORD PTR [rdx]
    2a61:	mov    r9,QWORD PTR [rdx+0x8]
    2a65:	mov    rcx,QWORD PTR [rdx+0x10]
    2a69:	mov    r8,QWORD PTR [rdx+0x18]
    2a6d:	sar    rsi,1
    2a70:	mov    rdx,r9
    2a73:	call   2a78 <botlish_entry_28+0x1e>
			2a74: R_X86_64_PLT32	botlish_fn_28-0x4 ; check<int, int, str, str>
    2a78:	mov    rsp,rbp
    2a7b:	pop    rbp
    2a7c:	ret

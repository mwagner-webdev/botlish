; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 9371  (per function: 1415 217 609 74 74 74 128 128 342 115 154 176 176 295 344 183 770 140 131 357 725 127 103 313 642 367 815 377)
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
;   botlish_fn_24 / botlish_entry_24 -> esc_bytes<List[int], int, str>
;   botlish_fn_25 / botlish_entry_25 -> esc_char<str>
;   botlish_fn_26 / botlish_entry_26 -> esc_from<str, int, str>
;   botlish_fn_27 / botlish_entry_27 -> check<int, int, str, str>


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
			460: R_X86_64_PLT32	botlish_fn_27-0x4 ; check<int, int, str, str>
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
			4a4: R_X86_64_PLT32	botlish_fn_27-0x4 ; check<int, int, str, str>
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
     6a7:	je     7c8 <botlish_fn_2+0x188>
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
     6e8:	cmovl  rcx,QWORD PTR [rip+0x170]        # 860 <botlish_fn_2+0x220>
     6f0:	jmp    708 <botlish_fn_2+0xc8>
     6f5:	mov    ecx,0x2
     6fa:	mov    rsi,r14
     6fd:	cmp    rsi,r12
     700:	cmovl  rcx,QWORD PTR [rip+0x158]        # 860 <botlish_fn_2+0x220>
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
     77a:	je     7c8 <botlish_fn_2+0x188>
     780:	mov    rsi,rax
     783:	jmp    790 <botlish_fn_2+0x150>
     788:	mov    rdx,QWORD PTR [rbx+0x10]
     78c:	mov    rsi,QWORD PTR [rdx+rax*8]
     790:	mov    rdi,r13
     793:	call   798 <botlish_fn_2+0x158>
			794: R_X86_64_PLT32	rt_char_codepoint-0x4
     798:	mov    rsi,rax
     79b:	mov    rdi,r13
     79e:	call   7a3 <botlish_fn_2+0x163>
			79f: R_X86_64_PLT32	botlish_fn_1-0x4 ; byte::from_int<int>
     7a3:	test   rax,rax
     7a6:	je     7c8 <botlish_fn_2+0x188>
     7ac:	mov    QWORD PTR [rsp+0x20],rax
     7b1:	mov    rdx,rax
     7b4:	mov    rsi,r15
     7b7:	mov    rdi,r13
     7ba:	call   7bf <botlish_fn_2+0x17f>
			7bb: R_X86_64_PLT32	rt_list_append-0x4
     7bf:	test   rax,rax
     7c2:	jne    7ed <botlish_fn_2+0x1ad>
     7c8:	xor    rax,rax
     7cb:	mov    rbx,QWORD PTR [rsp+0x30]
     7d0:	mov    r12,QWORD PTR [rsp+0x38]
     7d5:	mov    r13,QWORD PTR [rsp+0x40]
     7da:	mov    r14,QWORD PTR [rsp+0x48]
     7df:	mov    r15,QWORD PTR [rsp+0x50]
     7e4:	add    rsp,0x60
     7e8:	mov    rsp,rbp
     7eb:	pop    rbp
     7ec:	ret
     7ed:	mov    QWORD PTR [rsp+0x18],rax
     7f2:	mov    r15,rax
     7f5:	mov    edx,0x3
     7fa:	mov    QWORD PTR [rsp+0x20],0x3
     803:	mov    rsi,r14
     806:	test   rsi,0x1
     80d:	jne    81b <botlish_fn_2+0x1db>
     813:	mov    rsi,r14
     816:	jmp    843 <botlish_fn_2+0x203>
     81b:	mov    rsi,r14
     81e:	mov    rcx,rsi
     821:	add    rcx,0x2
     825:	seto   al
     828:	test   al,al
     82a:	je     838 <botlish_fn_2+0x1f8>
     830:	mov    rsi,r14
     833:	jmp    843 <botlish_fn_2+0x203>
     838:	mov    rsi,rcx
     83b:	mov    r14,rcx
     83e:	jmp    851 <botlish_fn_2+0x211>
     843:	mov    rdi,r13
     846:	call   84b <botlish_fn_2+0x20b>
			847: R_X86_64_PLT32	rt_int_add-0x4
     84b:	mov    rsi,rax
     84e:	mov    r14,rax
     851:	mov    QWORD PTR [rsp+0x10],rsi
     856:	mov    rsi,r14
     859:	jmp    6bd <botlish_fn_2+0x7d>
     85e:	add    BYTE PTR [rax],al
     860:	(bad)
     861:	add    BYTE PTR [rax],al
     863:	add    BYTE PTR [rax],al
     865:	add    BYTE PTR [rax],al
	...

0000000000000868 <botlish_entry_2: byte::set<List[UnicodeChar]>>:
     868:	push   rbp
     869:	mov    rbp,rsp
     86c:	mov    rsi,QWORD PTR [rdx]
     86f:	call   874 <botlish_entry_2+0xc>
			870: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::set<List[UnicodeChar]>
     874:	mov    rsp,rbp
     877:	pop    rbp
     878:	ret

0000000000000879 <botlish_fn_3: ascii::is_digit<int>>:
     879:	push   rbp
     87a:	mov    rbp,rsp
     87d:	cmp    rsi,0x30
     881:	jge    891 <botlish_fn_3+0x18>
     887:	mov    eax,0x2
     88c:	jmp    8aa <botlish_fn_3+0x31>
     891:	cmp    rsi,0x39
     895:	jle    8a5 <botlish_fn_3+0x2c>
     89b:	mov    eax,0x2
     8a0:	jmp    8aa <botlish_fn_3+0x31>
     8a5:	mov    eax,0x6
     8aa:	mov    rsp,rbp
     8ad:	pop    rbp
     8ae:	ret

00000000000008af <botlish_entry_3: ascii::is_digit<int>>:
     8af:	push   rbp
     8b0:	mov    rbp,rsp
     8b3:	mov    rsi,QWORD PTR [rdx]
     8b6:	sar    rsi,1
     8b9:	call   8be <botlish_entry_3+0xf>
			8ba: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<int>
     8be:	mov    rsp,rbp
     8c1:	pop    rbp
     8c2:	ret

00000000000008c3 <botlish_fn_4: ascii::is_upper<int>>:
     8c3:	push   rbp
     8c4:	mov    rbp,rsp
     8c7:	cmp    rsi,0x41
     8cb:	jge    8db <botlish_fn_4+0x18>
     8d1:	mov    eax,0x2
     8d6:	jmp    8f4 <botlish_fn_4+0x31>
     8db:	cmp    rsi,0x5a
     8df:	jle    8ef <botlish_fn_4+0x2c>
     8e5:	mov    eax,0x2
     8ea:	jmp    8f4 <botlish_fn_4+0x31>
     8ef:	mov    eax,0x6
     8f4:	mov    rsp,rbp
     8f7:	pop    rbp
     8f8:	ret

00000000000008f9 <botlish_entry_4: ascii::is_upper<int>>:
     8f9:	push   rbp
     8fa:	mov    rbp,rsp
     8fd:	mov    rsi,QWORD PTR [rdx]
     900:	sar    rsi,1
     903:	call   908 <botlish_entry_4+0xf>
			904: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_upper<int>
     908:	mov    rsp,rbp
     90b:	pop    rbp
     90c:	ret

000000000000090d <botlish_fn_5: ascii::is_lower<int>>:
     90d:	push   rbp
     90e:	mov    rbp,rsp
     911:	cmp    rsi,0x61
     915:	jge    925 <botlish_fn_5+0x18>
     91b:	mov    eax,0x2
     920:	jmp    93e <botlish_fn_5+0x31>
     925:	cmp    rsi,0x7a
     929:	jle    939 <botlish_fn_5+0x2c>
     92f:	mov    eax,0x2
     934:	jmp    93e <botlish_fn_5+0x31>
     939:	mov    eax,0x6
     93e:	mov    rsp,rbp
     941:	pop    rbp
     942:	ret

0000000000000943 <botlish_entry_5: ascii::is_lower<int>>:
     943:	push   rbp
     944:	mov    rbp,rsp
     947:	mov    rsi,QWORD PTR [rdx]
     94a:	sar    rsi,1
     94d:	call   952 <botlish_entry_5+0xf>
			94e: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_lower<int>
     952:	mov    rsp,rbp
     955:	pop    rbp
     956:	ret

0000000000000957 <botlish_fn_6: ascii::is_alphabetic<int>>:
     957:	push   rbp
     958:	mov    rbp,rsp
     95b:	sub    rsp,0x10
     95f:	mov    QWORD PTR [rsp],r12
     963:	mov    QWORD PTR [rsp+0x8],r14
     968:	mov    r12,rsi
     96b:	mov    r14,rdi
     96e:	mov    rsi,r12
     971:	mov    rdi,r14
     974:	call   979 <botlish_fn_6+0x22>
			975: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_upper<int>
     979:	cmp    rax,0x6
     97d:	je     9ac <botlish_fn_6+0x55>
     983:	mov    rsi,r12
     986:	mov    rdi,r14
     989:	call   98e <botlish_fn_6+0x37>
			98a: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_lower<int>
     98e:	cmp    rax,0x6
     992:	je     9a2 <botlish_fn_6+0x4b>
     998:	mov    eax,0x2
     99d:	jmp    9b1 <botlish_fn_6+0x5a>
     9a2:	mov    eax,0x6
     9a7:	jmp    9b1 <botlish_fn_6+0x5a>
     9ac:	mov    eax,0x6
     9b1:	mov    r12,QWORD PTR [rsp]
     9b5:	mov    r14,QWORD PTR [rsp+0x8]
     9ba:	add    rsp,0x10
     9be:	mov    rsp,rbp
     9c1:	pop    rbp
     9c2:	ret

00000000000009c3 <botlish_entry_6: ascii::is_alphabetic<int>>:
     9c3:	push   rbp
     9c4:	mov    rbp,rsp
     9c7:	mov    rsi,QWORD PTR [rdx]
     9ca:	sar    rsi,1
     9cd:	call   9d2 <botlish_entry_6+0xf>
			9ce: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_alphabetic<int>
     9d2:	mov    rsp,rbp
     9d5:	pop    rbp
     9d6:	ret

00000000000009d7 <botlish_fn_7: ascii::is_alphanumeric<int>>:
     9d7:	push   rbp
     9d8:	mov    rbp,rsp
     9db:	sub    rsp,0x10
     9df:	mov    QWORD PTR [rsp],r12
     9e3:	mov    QWORD PTR [rsp+0x8],r14
     9e8:	mov    r12,rsi
     9eb:	mov    r14,rdi
     9ee:	mov    rsi,r12
     9f1:	mov    rdi,r14
     9f4:	call   9f9 <botlish_fn_7+0x22>
			9f5: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_alphabetic<int>
     9f9:	cmp    rax,0x6
     9fd:	je     a2c <botlish_fn_7+0x55>
     a03:	mov    rsi,r12
     a06:	mov    rdi,r14
     a09:	call   a0e <botlish_fn_7+0x37>
			a0a: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<int>
     a0e:	cmp    rax,0x6
     a12:	je     a22 <botlish_fn_7+0x4b>
     a18:	mov    eax,0x2
     a1d:	jmp    a31 <botlish_fn_7+0x5a>
     a22:	mov    eax,0x6
     a27:	jmp    a31 <botlish_fn_7+0x5a>
     a2c:	mov    eax,0x6
     a31:	mov    r12,QWORD PTR [rsp]
     a35:	mov    r14,QWORD PTR [rsp+0x8]
     a3a:	add    rsp,0x10
     a3e:	mov    rsp,rbp
     a41:	pop    rbp
     a42:	ret

0000000000000a43 <botlish_entry_7: ascii::is_alphanumeric<int>>:
     a43:	push   rbp
     a44:	mov    rbp,rsp
     a47:	mov    rsi,QWORD PTR [rdx]
     a4a:	sar    rsi,1
     a4d:	call   a52 <botlish_entry_7+0xf>
			a4e: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphanumeric<int>
     a52:	mov    rsp,rbp
     a55:	pop    rbp
     a56:	ret

0000000000000a57 <botlish_fn_8: web::emailish?<str>>:
     a57:	push   rbp
     a58:	mov    rbp,rsp
     a5b:	sub    rsp,0x50
     a5f:	mov    QWORD PTR [rsp+0x30],rbx
     a64:	mov    QWORD PTR [rsp+0x38],r12
     a69:	mov    QWORD PTR [rsp+0x40],r13
     a6e:	mov    QWORD PTR [rsp+0x48],r14
     a73:	mov    r13,rdi
     a76:	mov    QWORD PTR [rsp],rsi
     a7a:	mov    r12,rsi
     a7d:	mov    rsi,r12
     a80:	mov    rdi,r13
     a83:	call   a88 <botlish_fn_8+0x31>
			a84: R_X86_64_PLT32	rt_str_len-0x4
     a88:	mov    r14,rax
     a8b:	mov    QWORD PTR [rsp+0x8],rax
     a90:	mov    rdi,r13
     a93:	mov    rax,QWORD PTR [rdi+0x10]
     a97:	mov    rdx,QWORD PTR [rax+0xc0]
     a9e:	mov    QWORD PTR [rsp+0x10],rdx
     aa3:	xor    rsi,rsi
     aa6:	mov    rcx,r14
     aa9:	mov    r8,r12
     aac:	call   ab1 <botlish_fn_8+0x5a>
			aad: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<int, block(e251)>
     ab1:	test   rax,rax
     ab4:	je     b3d <botlish_fn_8+0xe6>
     aba:	mov    rbx,rax
     abd:	sar    rbx,1
     ac0:	mov    rsi,rax
     ac3:	test   rbx,rbx
     ac6:	je     b6c <botlish_fn_8+0x115>
     acc:	mov    rax,r14
     acf:	sar    rax,1
     ad2:	cmp    rbx,rax
     ad5:	jge    b62 <botlish_fn_8+0x10b>
     adb:	lea    r8,[rsp+0x18]
     ae0:	mov    rcx,r12
     ae3:	mov    rdx,r14
     ae6:	mov    rdi,r13
     ae9:	call   aee <botlish_fn_8+0x97>
			aea: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     aee:	mov    rdx,QWORD PTR [rsp+0x18]
     af3:	mov    rcx,QWORD PTR [rsp+0x20]
     af8:	mov    rdi,r13
     afb:	mov    rsi,QWORD PTR [rdi+0x10]
     aff:	mov    r8,QWORD PTR [rsi+0xc8]
     b06:	mov    rsi,rax
     b09:	call   b0e <botlish_fn_8+0xb7>
			b0a: R_X86_64_PLT32	rt_str_region_eq-0x4
     b0e:	cmp    rax,0x6
     b12:	je     b22 <botlish_fn_8+0xcb>
     b18:	mov    eax,0x2
     b1d:	jmp    b71 <botlish_fn_8+0x11a>
     b22:	lea    rsi,[rbx+0x1]
     b26:	mov    rcx,r12
     b29:	mov    rdx,r14
     b2c:	mov    rdi,r13
     b2f:	call   b34 <botlish_fn_8+0xdd>
			b30: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain?<int>
     b34:	test   rax,rax
     b37:	jne    b71 <botlish_fn_8+0x11a>
     b3d:	xor    rax,rax
     b40:	mov    rbx,QWORD PTR [rsp+0x30]
     b45:	mov    r12,QWORD PTR [rsp+0x38]
     b4a:	mov    r13,QWORD PTR [rsp+0x40]
     b4f:	mov    r14,QWORD PTR [rsp+0x48]
     b54:	add    rsp,0x50
     b58:	mov    rsp,rbp
     b5b:	pop    rbp
     b5c:	ret
     b5d:	jmp    b71 <botlish_fn_8+0x11a>
     b62:	mov    eax,0x2
     b67:	jmp    b71 <botlish_fn_8+0x11a>
     b6c:	mov    eax,0x2
     b71:	mov    rbx,QWORD PTR [rsp+0x30]
     b76:	mov    r12,QWORD PTR [rsp+0x38]
     b7b:	mov    r13,QWORD PTR [rsp+0x40]
     b80:	mov    r14,QWORD PTR [rsp+0x48]
     b85:	add    rsp,0x50
     b89:	mov    rsp,rbp
     b8c:	pop    rbp
     b8d:	ret

0000000000000b8e <botlish_entry_8: web::emailish?<str>>:
     b8e:	push   rbp
     b8f:	mov    rbp,rsp
     b92:	mov    rsi,QWORD PTR [rdx]
     b95:	call   b9a <botlish_entry_8+0xc>
			b96: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::emailish?<str>
     b9a:	mov    rsp,rbp
     b9d:	pop    rbp
     b9e:	ret

0000000000000b9f <botlish_fn_9: char_at<int>>:
     b9f:	push   rbp
     ba0:	mov    rbp,rsp
     ba3:	mov    rax,rsi
     ba6:	sar    rax,1
     ba9:	sar    rdx,1
     bac:	cmp    rax,rdx
     baf:	jge    bc0 <botlish_fn_9+0x21>
     bb5:	mov    r11d,0x2
     bbb:	jmp    bc6 <botlish_fn_9+0x27>
     bc0:	mov    r11d,0x6
     bc6:	cmp    r11,0x6
     bca:	je     bed <botlish_fn_9+0x4e>
     bd0:	mov    QWORD PTR [r8],rsi
     bd3:	add    rax,0x1
     bda:	shl    rax,1
     bdd:	or     rax,0x1
     be1:	mov    QWORD PTR [r8+0x8],rax
     be5:	mov    rax,rcx
     be8:	mov    rsp,rbp
     beb:	pop    rbp
     bec:	ret
     bed:	mov    rax,QWORD PTR [rdi+0x10]
     bf1:	mov    rax,QWORD PTR [rax+0xd0]
     bf8:	mov    QWORD PTR [r8],0x1
     bff:	mov    QWORD PTR [r8+0x8],0x1
     c07:	mov    rsp,rbp
     c0a:	pop    rbp
     c0b:	ret

0000000000000c0c <botlish_entry_9: char_at<int>>:
     c0c:	push   rbp
     c0d:	mov    rbp,rsp
     c10:	ud2

0000000000000c12 <botlish_fn_10: char_at<int>>:
     c12:	push   rbp
     c13:	mov    rbp,rsp
     c16:	sub    rsp,0x20
     c1a:	mov    QWORD PTR [rsp],rsi
     c1e:	mov    QWORD PTR [rsp+0x8],rcx
     c23:	mov    r8,rcx
     c26:	mov    rax,rsi
     c29:	sar    rax,1
     c2c:	sar    rdx,1
     c2f:	cmp    rax,rdx
     c32:	jge    c42 <botlish_fn_10+0x30>
     c38:	mov    ecx,0x2
     c3d:	jmp    c47 <botlish_fn_10+0x35>
     c42:	mov    ecx,0x6
     c47:	cmp    rcx,0x6
     c4b:	je     c75 <botlish_fn_10+0x63>
     c51:	lea    rcx,[rax+0x1]
     c55:	shl    rcx,1
     c58:	or     rcx,0x1
     c5c:	mov    QWORD PTR [rsp+0x10],rcx
     c61:	mov    rdx,rsi
     c64:	mov    rsi,r8
     c67:	call   c6c <botlish_fn_10+0x5a>
			c68: R_X86_64_PLT32	rt_substr_proven-0x4
     c6c:	add    rsp,0x20
     c70:	mov    rsp,rbp
     c73:	pop    rbp
     c74:	ret
     c75:	mov    rax,QWORD PTR [rdi+0x10]
     c79:	mov    rax,QWORD PTR [rax+0xd0]
     c80:	add    rsp,0x20
     c84:	mov    rsp,rbp
     c87:	pop    rbp
     c88:	ret

0000000000000c89 <botlish_entry_10: char_at<int>>:
     c89:	push   rbp
     c8a:	mov    rbp,rsp
     c8d:	mov    rsi,QWORD PTR [rdx]
     c90:	mov    r8,QWORD PTR [rdx+0x8]
     c94:	mov    rcx,QWORD PTR [rdx+0x10]
     c98:	mov    rdx,r8
     c9b:	call   ca0 <botlish_entry_10+0x17>
			c9c: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
     ca0:	mov    rsp,rbp
     ca3:	pop    rbp
     ca4:	ret

0000000000000ca5 <botlish_fn_11: local_char?<str>>:
     ca5:	push   rbp
     ca6:	mov    rbp,rsp
     ca9:	sub    rsp,0x10
     cad:	mov    QWORD PTR [rsp],rbx
     cb1:	mov    QWORD PTR [rsp+0x8],r14
     cb6:	mov    rbx,rdi
     cb9:	mov    r14,rsi
     cbc:	mov    rsi,r14
     cbf:	mov    rdi,rbx
     cc2:	call   cc7 <botlish_fn_11+0x22>
			cc3: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     cc7:	test   rax,rax
     cca:	jne    ce5 <botlish_fn_11+0x40>
     cd0:	xor    rax,rax
     cd3:	mov    rbx,QWORD PTR [rsp]
     cd7:	mov    r14,QWORD PTR [rsp+0x8]
     cdc:	add    rsp,0x10
     ce0:	mov    rsp,rbp
     ce3:	pop    rbp
     ce4:	ret
     ce5:	cmp    rax,0x6
     ce9:	je     d1f <botlish_fn_11+0x7a>
     cef:	mov    rdi,rbx
     cf2:	mov    rax,QWORD PTR [rdi+0x30]
     cf6:	mov    rsi,QWORD PTR [rax]
     cf9:	mov    rdx,r14
     cfc:	call   d01 <botlish_fn_11+0x5c>
			cfd: R_X86_64_PLT32	rt_set_contains-0x4
     d01:	cmp    rax,0x6
     d05:	je     d15 <botlish_fn_11+0x70>
     d0b:	mov    eax,0x2
     d10:	jmp    d24 <botlish_fn_11+0x7f>
     d15:	mov    eax,0x6
     d1a:	jmp    d24 <botlish_fn_11+0x7f>
     d1f:	mov    eax,0x6
     d24:	mov    rbx,QWORD PTR [rsp]
     d28:	mov    r14,QWORD PTR [rsp+0x8]
     d2d:	add    rsp,0x10
     d31:	mov    rsp,rbp
     d34:	pop    rbp
     d35:	ret

0000000000000d36 <botlish_entry_11: local_char?<str>>:
     d36:	push   rbp
     d37:	mov    rbp,rsp
     d3a:	mov    rsi,QWORD PTR [rdx]
     d3d:	call   d42 <botlish_entry_11+0xc>
			d3e: R_X86_64_PLT32	botlish_fn_11-0x4 ; local_char?<str>
     d42:	mov    rsp,rbp
     d45:	pop    rbp
     d46:	ret

0000000000000d47 <botlish_fn_12: local_char?<generic>>:
     d47:	push   rbp
     d48:	mov    rbp,rsp
     d4b:	sub    rsp,0x10
     d4f:	mov    QWORD PTR [rsp],rbx
     d53:	mov    QWORD PTR [rsp+0x8],r14
     d58:	mov    rbx,rdi
     d5b:	mov    r14,rsi
     d5e:	mov    rsi,r14
     d61:	mov    rdi,rbx
     d64:	call   d69 <botlish_fn_12+0x22>
			d65: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     d69:	test   rax,rax
     d6c:	jne    d87 <botlish_fn_12+0x40>
     d72:	xor    rax,rax
     d75:	mov    rbx,QWORD PTR [rsp]
     d79:	mov    r14,QWORD PTR [rsp+0x8]
     d7e:	add    rsp,0x10
     d82:	mov    rsp,rbp
     d85:	pop    rbp
     d86:	ret
     d87:	cmp    rax,0x6
     d8b:	je     dc1 <botlish_fn_12+0x7a>
     d91:	mov    rdi,rbx
     d94:	mov    rax,QWORD PTR [rdi+0x30]
     d98:	mov    rsi,QWORD PTR [rax]
     d9b:	mov    rdx,r14
     d9e:	call   da3 <botlish_fn_12+0x5c>
			d9f: R_X86_64_PLT32	rt_set_contains-0x4
     da3:	cmp    rax,0x6
     da7:	je     db7 <botlish_fn_12+0x70>
     dad:	mov    eax,0x2
     db2:	jmp    dc6 <botlish_fn_12+0x7f>
     db7:	mov    eax,0x6
     dbc:	jmp    dc6 <botlish_fn_12+0x7f>
     dc1:	mov    eax,0x6
     dc6:	mov    rbx,QWORD PTR [rsp]
     dca:	mov    r14,QWORD PTR [rsp+0x8]
     dcf:	add    rsp,0x10
     dd3:	mov    rsp,rbp
     dd6:	pop    rbp
     dd7:	ret

0000000000000dd8 <botlish_entry_12: local_char?<generic>>:
     dd8:	push   rbp
     dd9:	mov    rbp,rsp
     ddc:	mov    rsi,QWORD PTR [rdx]
     ddf:	call   de4 <botlish_entry_12+0xc>
			de0: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<generic>
     de4:	mov    rsp,rbp
     de7:	pop    rbp
     de8:	ret

0000000000000de9 <botlish_fn_13: scan_while<int, block(e251)>>:
     de9:	push   rbp
     dea:	mov    rbp,rsp
     ded:	sub    rsp,0x50
     df1:	mov    QWORD PTR [rsp+0x20],rbx
     df6:	mov    QWORD PTR [rsp+0x28],r12
     dfb:	mov    QWORD PTR [rsp+0x30],r13
     e00:	mov    QWORD PTR [rsp+0x38],r14
     e05:	mov    QWORD PTR [rsp+0x40],r15
     e0a:	mov    QWORD PTR [rsp+0x18],rdi
     e0f:	mov    QWORD PTR [rsp],rcx
     e13:	mov    QWORD PTR [rsp+0x8],r8
     e18:	mov    r15,r8
     e1b:	mov    r12,rcx
     e1e:	sar    r12,1
     e21:	mov    r14,rcx
     e24:	mov    rbx,rsi
     e27:	cmp    rbx,r12
     e2a:	jl     e55 <botlish_fn_13+0x6c>
     e30:	mov    rax,r14
     e33:	mov    rbx,QWORD PTR [rsp+0x20]
     e38:	mov    r12,QWORD PTR [rsp+0x28]
     e3d:	mov    r13,QWORD PTR [rsp+0x30]
     e42:	mov    r14,QWORD PTR [rsp+0x38]
     e47:	mov    r15,QWORD PTR [rsp+0x40]
     e4c:	add    rsp,0x50
     e50:	mov    rsp,rbp
     e53:	pop    rbp
     e54:	ret
     e55:	mov    r13,rbx
     e58:	shl    r13,1
     e5b:	or     r13,0x1
     e5f:	mov    QWORD PTR [rsp+0x10],r13
     e64:	mov    rcx,r15
     e67:	mov    rdx,r14
     e6a:	mov    rsi,r13
     e6d:	mov    rdi,QWORD PTR [rsp+0x18]
     e72:	call   e77 <botlish_fn_13+0x8e>
			e73: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
     e77:	mov    rsi,rax
     e7a:	mov    rdi,QWORD PTR [rsp+0x18]
     e7f:	call   e84 <botlish_fn_13+0x9b>
			e80: R_X86_64_PLT32	botlish_fn_11-0x4 ; local_char?<str>
     e84:	test   rax,rax
     e87:	jne    eb2 <botlish_fn_13+0xc9>
     e8d:	xor    rax,rax
     e90:	mov    rbx,QWORD PTR [rsp+0x20]
     e95:	mov    r12,QWORD PTR [rsp+0x28]
     e9a:	mov    r13,QWORD PTR [rsp+0x30]
     e9f:	mov    r14,QWORD PTR [rsp+0x38]
     ea4:	mov    r15,QWORD PTR [rsp+0x40]
     ea9:	add    rsp,0x50
     ead:	mov    rsp,rbp
     eb0:	pop    rbp
     eb1:	ret
     eb2:	cmp    rax,0x6
     eb6:	je     ee1 <botlish_fn_13+0xf8>
     ebc:	mov    rax,r13
     ebf:	mov    rbx,QWORD PTR [rsp+0x20]
     ec4:	mov    r12,QWORD PTR [rsp+0x28]
     ec9:	mov    r13,QWORD PTR [rsp+0x30]
     ece:	mov    r14,QWORD PTR [rsp+0x38]
     ed3:	mov    r15,QWORD PTR [rsp+0x40]
     ed8:	add    rsp,0x50
     edc:	mov    rsp,rbp
     edf:	pop    rbp
     ee0:	ret
     ee1:	add    rbx,0x1
     ee8:	jmp    e27 <botlish_fn_13+0x3e>

0000000000000eed <botlish_entry_13: scan_while<int, block(e251)>>:
     eed:	push   rbp
     eee:	mov    rbp,rsp
     ef1:	mov    rsi,QWORD PTR [rdx]
     ef4:	mov    r9,QWORD PTR [rdx+0x8]
     ef8:	mov    rcx,QWORD PTR [rdx+0x10]
     efc:	mov    r8,QWORD PTR [rdx+0x18]
     f00:	sar    rsi,1
     f03:	mov    rdx,r9
     f06:	call   f0b <botlish_entry_13+0x1e>
			f07: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<int, block(e251)>
     f0b:	mov    rsp,rbp
     f0e:	pop    rbp
     f0f:	ret

0000000000000f10 <botlish_fn_14: scan_while<int, native(str::is_tcl_alpha)>>:
     f10:	push   rbp
     f11:	mov    rbp,rsp
     f14:	sub    rsp,0x40
     f18:	mov    QWORD PTR [rsp+0x10],rbx
     f1d:	mov    QWORD PTR [rsp+0x18],r12
     f22:	mov    QWORD PTR [rsp+0x20],r13
     f27:	mov    QWORD PTR [rsp+0x28],r14
     f2c:	mov    QWORD PTR [rsp+0x30],r15
     f31:	mov    rbx,r8
     f34:	mov    r13,rdi
     f37:	mov    rax,rcx
     f3a:	sar    rax,1
     f3d:	mov    r12,rcx
     f40:	mov    r14,rax
     f43:	mov    rax,rsi
     f46:	mov    rcx,r14
     f49:	cmp    rax,rcx
     f4c:	mov    r14,rcx
     f4f:	jl     f7f <botlish_fn_14+0x6f>
     f55:	mov    edx,0x1
     f5a:	mov    rax,r14
     f5d:	mov    rbx,QWORD PTR [rsp+0x10]
     f62:	mov    r12,QWORD PTR [rsp+0x18]
     f67:	mov    r13,QWORD PTR [rsp+0x20]
     f6c:	mov    r14,QWORD PTR [rsp+0x28]
     f71:	mov    r15,QWORD PTR [rsp+0x30]
     f76:	add    rsp,0x40
     f7a:	mov    rsp,rbp
     f7d:	pop    rbp
     f7e:	ret
     f7f:	mov    rsi,rax
     f82:	shl    rsi,1
     f85:	mov    r15,rax
     f88:	or     rsi,0x1
     f8c:	lea    r8,[rsp]
     f90:	mov    rcx,rbx
     f93:	mov    rdx,r12
     f96:	mov    rdi,r13
     f99:	call   f9e <botlish_fn_14+0x8e>
			f9a: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     f9e:	mov    rdx,QWORD PTR [rsp]
     fa2:	mov    rcx,QWORD PTR [rsp+0x8]
     fa7:	mov    rsi,rax
     faa:	mov    rdi,r13
     fad:	call   fb2 <botlish_fn_14+0xa2>
			fae: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
     fb2:	test   rax,rax
     fb5:	jne    fe3 <botlish_fn_14+0xd3>
     fbb:	xor    rdx,rdx
     fbe:	mov    rax,rdx
     fc1:	mov    rbx,QWORD PTR [rsp+0x10]
     fc6:	mov    r12,QWORD PTR [rsp+0x18]
     fcb:	mov    r13,QWORD PTR [rsp+0x20]
     fd0:	mov    r14,QWORD PTR [rsp+0x28]
     fd5:	mov    r15,QWORD PTR [rsp+0x30]
     fda:	add    rsp,0x40
     fde:	mov    rsp,rbp
     fe1:	pop    rbp
     fe2:	ret
     fe3:	cmp    rax,0x6
     fe7:	je     1017 <botlish_fn_14+0x107>
     fed:	mov    edx,0x1
     ff2:	mov    rax,r15
     ff5:	mov    rbx,QWORD PTR [rsp+0x10]
     ffa:	mov    r12,QWORD PTR [rsp+0x18]
     fff:	mov    r13,QWORD PTR [rsp+0x20]
    1004:	mov    r14,QWORD PTR [rsp+0x28]
    1009:	mov    r15,QWORD PTR [rsp+0x30]
    100e:	add    rsp,0x40
    1012:	mov    rsp,rbp
    1015:	pop    rbp
    1016:	ret
    1017:	mov    rax,r15
    101a:	add    rax,0x1
    1021:	mov    rcx,r14
    1024:	jmp    f49 <botlish_fn_14+0x39>

0000000000001029 <botlish_entry_14: scan_while<int, native(str::is_tcl_alpha)>>:
    1029:	push   rbp
    102a:	mov    rbp,rsp
    102d:	mov    rsi,QWORD PTR [rdx]
    1030:	mov    rax,QWORD PTR [rdx+0x8]
    1034:	mov    rcx,QWORD PTR [rdx+0x10]
    1038:	mov    r8,QWORD PTR [rdx+0x18]
    103c:	sar    rsi,1
    103f:	mov    rdx,rax
    1042:	call   1047 <botlish_entry_14+0x1e>
			1043: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, native(str::is_tcl_alpha)>
    1047:	shl    rax,1
    104a:	or     rax,0x1
    104e:	mov    rcx,rax
    1051:	xor    rax,rax
    1054:	test   rdx,rdx
    1057:	cmovne rax,rcx
    105b:	mov    rsp,rbp
    105e:	pop    rbp
    105f:	ret

0000000000001060 <botlish_fn_15: tld?<int>>:
    1060:	push   rbp
    1061:	mov    rbp,rsp
    1064:	sub    rsp,0x10
    1068:	mov    QWORD PTR [rsp],rbx
    106c:	mov    QWORD PTR [rsp+0x8],r12
    1071:	mov    r8,rdx
    1074:	mov    rax,QWORD PTR [rdi+0x10]
    1078:	mov    rdx,QWORD PTR [rax+0xd8]
    107f:	mov    r12,r8
    1082:	mov    r8,rcx
    1085:	mov    rbx,rsi
    1088:	mov    rcx,r12
    108b:	call   1090 <botlish_fn_15+0x30>
			108c: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, native(str::is_tcl_alpha)>
    1090:	test   rdx,rdx
    1093:	jne    10ae <botlish_fn_15+0x4e>
    1099:	xor    rax,rax
    109c:	mov    rbx,QWORD PTR [rsp]
    10a0:	mov    r12,QWORD PTR [rsp+0x8]
    10a5:	add    rsp,0x10
    10a9:	mov    rsp,rbp
    10ac:	pop    rbp
    10ad:	ret
    10ae:	sar    r12,1
    10b1:	cmp    rax,r12
    10b4:	je     10c4 <botlish_fn_15+0x64>
    10ba:	mov    eax,0x2
    10bf:	jmp    10db <botlish_fn_15+0x7b>
    10c4:	sub    rax,rbx
    10c7:	mov    rcx,rax
    10ca:	mov    eax,0x2
    10cf:	cmp    rcx,0x2
    10d3:	cmovge rax,QWORD PTR [rip+0x15]        # 10f0 <botlish_fn_15+0x90>
    10db:	mov    rbx,QWORD PTR [rsp]
    10df:	mov    r12,QWORD PTR [rsp+0x8]
    10e4:	add    rsp,0x10
    10e8:	mov    rsp,rbp
    10eb:	pop    rbp
    10ec:	ret
    10ed:	add    BYTE PTR [rax],al
    10ef:	add    BYTE PTR [rsi],al
    10f1:	add    BYTE PTR [rax],al
    10f3:	add    BYTE PTR [rax],al
    10f5:	add    BYTE PTR [rax],al
	...

00000000000010f8 <botlish_entry_15: tld?<int>>:
    10f8:	push   rbp
    10f9:	mov    rbp,rsp
    10fc:	mov    rsi,QWORD PTR [rdx]
    10ff:	mov    r8,QWORD PTR [rdx+0x8]
    1103:	mov    rcx,QWORD PTR [rdx+0x10]
    1107:	sar    rsi,1
    110a:	mov    rdx,r8
    110d:	call   1112 <botlish_entry_15+0x1a>
			110e: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld?<int>
    1112:	mov    rsp,rbp
    1115:	pop    rbp
    1116:	ret

0000000000001117 <botlish_fn_16: domain?<int>>:
    1117:	push   rbp
    1118:	mov    rbp,rsp
    111b:	sub    rsp,0x80
    1122:	mov    QWORD PTR [rsp+0x50],rbx
    1127:	mov    QWORD PTR [rsp+0x58],r12
    112c:	mov    QWORD PTR [rsp+0x60],r13
    1131:	mov    QWORD PTR [rsp+0x68],r14
    1136:	mov    QWORD PTR [rsp+0x70],r15
    113b:	mov    rbx,rsi
    113e:	mov    r15,rcx
    1141:	mov    r14,rdx
    1144:	sar    r14,1
    1147:	mov    QWORD PTR [rsp+0x30],rdx
    114c:	mov    r12,rbx
    114f:	cmp    r12,r14
    1152:	jl     1182 <botlish_fn_16+0x6b>
    1158:	mov    eax,0x2
    115d:	mov    rbx,QWORD PTR [rsp+0x50]
    1162:	mov    r12,QWORD PTR [rsp+0x58]
    1167:	mov    r13,QWORD PTR [rsp+0x60]
    116c:	mov    r14,QWORD PTR [rsp+0x68]
    1171:	mov    r15,QWORD PTR [rsp+0x70]
    1176:	add    rsp,0x80
    117d:	mov    rsp,rbp
    1180:	pop    rbp
    1181:	ret
    1182:	mov    rsi,r12
    1185:	shl    rsi,1
    1188:	or     rsi,0x1
    118c:	mov    QWORD PTR [rsp+0x48],rsi
    1191:	lea    r8,[rsp]
    1195:	mov    r13,rdi
    1198:	mov    rcx,r15
    119b:	mov    rdx,QWORD PTR [rsp+0x30]
    11a0:	call   11a5 <botlish_fn_16+0x8e>
			11a1: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    11a5:	mov    rdx,QWORD PTR [rsp]
    11a9:	mov    rcx,QWORD PTR [rsp+0x8]
    11ae:	mov    rsi,QWORD PTR [r13+0x10]
    11b2:	mov    r8,QWORD PTR [rsi]
    11b5:	mov    rsi,rax
    11b8:	mov    rdi,r13
    11bb:	call   11c0 <botlish_fn_16+0xa9>
			11bc: R_X86_64_PLT32	rt_str_region_eq-0x4
    11c0:	cmp    rax,0x6
    11c4:	je     12ac <botlish_fn_16+0x195>
    11ca:	lea    r8,[rsp+0x20]
    11cf:	mov    rsi,QWORD PTR [rsp+0x48]
    11d4:	mov    rcx,r15
    11d7:	mov    rdx,QWORD PTR [rsp+0x30]
    11dc:	mov    rdi,r13
    11df:	call   11e4 <botlish_fn_16+0xcd>
			11e0: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    11e4:	mov    QWORD PTR [rsp+0x48],rax
    11e9:	mov    rdx,QWORD PTR [rsp+0x20]
    11ee:	mov    QWORD PTR [rsp+0x40],rdx
    11f3:	mov    rcx,QWORD PTR [rsp+0x28]
    11f8:	mov    QWORD PTR [rsp+0x38],rcx
    11fd:	mov    rsi,QWORD PTR [rsp+0x48]
    1202:	mov    rdi,r13
    1205:	call   120a <botlish_fn_16+0xf3>
			1206: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    120a:	test   rax,rax
    120d:	je     131c <botlish_fn_16+0x205>
    1213:	cmp    rax,0x6
    1217:	je     125a <botlish_fn_16+0x143>
    121d:	mov    rcx,QWORD PTR [r13+0x10]
    1221:	mov    r8,QWORD PTR [rcx+0x20]
    1225:	mov    rcx,QWORD PTR [rsp+0x38]
    122a:	mov    rdx,QWORD PTR [rsp+0x40]
    122f:	mov    rsi,QWORD PTR [rsp+0x48]
    1234:	mov    rdi,r13
    1237:	call   123c <botlish_fn_16+0x125>
			1238: R_X86_64_PLT32	rt_str_region_eq-0x4
    123c:	cmp    rax,0x6
    1240:	je     1250 <botlish_fn_16+0x139>
    1246:	mov    ecx,0x2
    124b:	jmp    125f <botlish_fn_16+0x148>
    1250:	mov    ecx,0x6
    1255:	jmp    125f <botlish_fn_16+0x148>
    125a:	mov    ecx,0x6
    125f:	cmp    rcx,0x6
    1263:	je     1273 <botlish_fn_16+0x15c>
    1269:	mov    eax,0x6
    126e:	jmp    1278 <botlish_fn_16+0x161>
    1273:	mov    eax,0x2
    1278:	cmp    rax,0x6
    127c:	jne    134e <botlish_fn_16+0x237>
    1282:	mov    eax,0x2
    1287:	mov    rbx,QWORD PTR [rsp+0x50]
    128c:	mov    r12,QWORD PTR [rsp+0x58]
    1291:	mov    r13,QWORD PTR [rsp+0x60]
    1296:	mov    r14,QWORD PTR [rsp+0x68]
    129b:	mov    r15,QWORD PTR [rsp+0x70]
    12a0:	add    rsp,0x80
    12a7:	mov    rsp,rbp
    12aa:	pop    rbp
    12ab:	ret
    12ac:	cmp    r12,rbx
    12af:	je     13b1 <botlish_fn_16+0x29a>
    12b5:	mov    rsi,r12
    12b8:	sub    rsi,0x1
    12bc:	shl    rsi,1
    12bf:	or     rsi,0x1
    12c3:	lea    r8,[rsp+0x10]
    12c8:	mov    rcx,r15
    12cb:	mov    rdx,QWORD PTR [rsp+0x30]
    12d0:	mov    rdi,r13
    12d3:	call   12d8 <botlish_fn_16+0x1c1>
			12d4: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    12d8:	mov    rdx,QWORD PTR [rsp+0x10]
    12dd:	mov    rcx,QWORD PTR [rsp+0x18]
    12e2:	mov    rsi,QWORD PTR [r13+0x10]
    12e6:	mov    r8,QWORD PTR [rsi]
    12e9:	mov    rsi,rax
    12ec:	mov    rdi,r13
    12ef:	call   12f4 <botlish_fn_16+0x1dd>
			12f0: R_X86_64_PLT32	rt_str_region_eq-0x4
    12f4:	cmp    rax,0x6
    12f8:	je     1387 <botlish_fn_16+0x270>
    12fe:	lea    rsi,[r12+0x1]
    1303:	mov    rcx,r15
    1306:	mov    rdx,QWORD PTR [rsp+0x30]
    130b:	mov    rdi,r13
    130e:	call   1313 <botlish_fn_16+0x1fc>
			130f: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld?<int>
    1313:	test   rax,rax
    1316:	jne    1344 <botlish_fn_16+0x22d>
    131c:	xor    rax,rax
    131f:	mov    rbx,QWORD PTR [rsp+0x50]
    1324:	mov    r12,QWORD PTR [rsp+0x58]
    1329:	mov    r13,QWORD PTR [rsp+0x60]
    132e:	mov    r14,QWORD PTR [rsp+0x68]
    1333:	mov    r15,QWORD PTR [rsp+0x70]
    1338:	add    rsp,0x80
    133f:	mov    rsp,rbp
    1342:	pop    rbp
    1343:	ret
    1344:	cmp    rax,0x6
    1348:	je     135d <botlish_fn_16+0x246>
    134e:	add    r12,0x1
    1355:	mov    rdi,r13
    1358:	jmp    114f <botlish_fn_16+0x38>
    135d:	mov    eax,0x6
    1362:	mov    rbx,QWORD PTR [rsp+0x50]
    1367:	mov    r12,QWORD PTR [rsp+0x58]
    136c:	mov    r13,QWORD PTR [rsp+0x60]
    1371:	mov    r14,QWORD PTR [rsp+0x68]
    1376:	mov    r15,QWORD PTR [rsp+0x70]
    137b:	add    rsp,0x80
    1382:	mov    rsp,rbp
    1385:	pop    rbp
    1386:	ret
    1387:	mov    eax,0x2
    138c:	mov    rbx,QWORD PTR [rsp+0x50]
    1391:	mov    r12,QWORD PTR [rsp+0x58]
    1396:	mov    r13,QWORD PTR [rsp+0x60]
    139b:	mov    r14,QWORD PTR [rsp+0x68]
    13a0:	mov    r15,QWORD PTR [rsp+0x70]
    13a5:	add    rsp,0x80
    13ac:	mov    rsp,rbp
    13af:	pop    rbp
    13b0:	ret
    13b1:	mov    eax,0x2
    13b6:	mov    rbx,QWORD PTR [rsp+0x50]
    13bb:	mov    r12,QWORD PTR [rsp+0x58]
    13c0:	mov    r13,QWORD PTR [rsp+0x60]
    13c5:	mov    r14,QWORD PTR [rsp+0x68]
    13ca:	mov    r15,QWORD PTR [rsp+0x70]
    13cf:	add    rsp,0x80
    13d6:	mov    rsp,rbp
    13d9:	pop    rbp
    13da:	ret

00000000000013db <botlish_entry_16: domain?<int>>:
    13db:	push   rbp
    13dc:	mov    rbp,rsp
    13df:	mov    rsi,QWORD PTR [rdx]
    13e2:	mov    r8,QWORD PTR [rdx+0x8]
    13e6:	mov    rcx,QWORD PTR [rdx+0x10]
    13ea:	sar    rsi,1
    13ed:	mov    rdx,r8
    13f0:	call   13f5 <botlish_entry_16+0x1a>
			13f1: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain?<int>
    13f5:	mov    rsp,rbp
    13f8:	pop    rbp
    13f9:	ret

00000000000013fa <botlish_fn_17: web::is_unreserved<int>>:
    13fa:	push   rbp
    13fb:	mov    rbp,rsp
    13fe:	sub    rsp,0x10
    1402:	mov    QWORD PTR [rsp],rbx
    1406:	mov    QWORD PTR [rsp+0x8],r14
    140b:	mov    r14,rsi
    140e:	mov    rsi,r14
    1411:	sar    rsi,1
    1414:	mov    rbx,rdi
    1417:	call   141c <botlish_fn_17+0x22>
			1418: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphanumeric<int>
    141c:	cmp    rax,0x6
    1420:	je     1457 <botlish_fn_17+0x5d>
    1426:	mov    rax,QWORD PTR [rbx+0x30]
    142a:	mov    rsi,QWORD PTR [rax+0x10]
    142e:	mov    rdx,r14
    1431:	mov    rdi,rbx
    1434:	call   1439 <botlish_fn_17+0x3f>
			1435: R_X86_64_PLT32	rt_set_contains-0x4
    1439:	cmp    rax,0x6
    143d:	je     144d <botlish_fn_17+0x53>
    1443:	mov    eax,0x2
    1448:	jmp    145c <botlish_fn_17+0x62>
    144d:	mov    eax,0x6
    1452:	jmp    145c <botlish_fn_17+0x62>
    1457:	mov    eax,0x6
    145c:	mov    rbx,QWORD PTR [rsp]
    1460:	mov    r14,QWORD PTR [rsp+0x8]
    1465:	add    rsp,0x10
    1469:	mov    rsp,rbp
    146c:	pop    rbp
    146d:	ret

000000000000146e <botlish_entry_17: web::is_unreserved<int>>:
    146e:	push   rbp
    146f:	mov    rbp,rsp
    1472:	mov    rsi,QWORD PTR [rdx]
    1475:	call   147a <botlish_entry_17+0xc>
			1476: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<int>
    147a:	mov    rsp,rbp
    147d:	pop    rbp
    147e:	ret

000000000000147f <botlish_fn_18: web::uri_query_value?<str>>:
    147f:	push   rbp
    1480:	mov    rbp,rsp
    1483:	sub    rsp,0x20
    1487:	mov    QWORD PTR [rsp+0x10],r12
    148c:	mov    r12,rdi
    148f:	mov    QWORD PTR [rsp+0x8],0x0
    1498:	mov    QWORD PTR [rsp],rsi
    149c:	mov    rdi,r12
    149f:	call   14a4 <botlish_fn_18+0x25>
			14a0: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    14a4:	test   rax,rax
    14a7:	jne    14be <botlish_fn_18+0x3f>
    14ad:	xor    rax,rax
    14b0:	mov    r12,QWORD PTR [rsp+0x10]
    14b5:	add    rsp,0x20
    14b9:	mov    rsp,rbp
    14bc:	pop    rbp
    14bd:	ret
    14be:	mov    QWORD PTR [rsp],rax
    14c2:	mov    rdx,rax
    14c5:	mov    esi,0x1
    14ca:	mov    QWORD PTR [rsp+0x8],0x1
    14d3:	mov    rdi,r12
    14d6:	call   14db <botlish_fn_18+0x5c>
			14d7: R_X86_64_PLT32	botlish_fn_20-0x4 ; valid_from?<int>
    14db:	mov    r12,QWORD PTR [rsp+0x10]
    14e0:	add    rsp,0x20
    14e4:	mov    rsp,rbp
    14e7:	pop    rbp
    14e8:	ret

00000000000014e9 <botlish_entry_18: web::uri_query_value?<str>>:
    14e9:	push   rbp
    14ea:	mov    rbp,rsp
    14ed:	mov    rsi,QWORD PTR [rdx]
    14f0:	call   14f5 <botlish_entry_18+0xc>
			14f1: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::uri_query_value?<str>
    14f5:	mov    rsp,rbp
    14f8:	pop    rbp
    14f9:	ret
    14fa:	add    BYTE PTR [rax],al
    14fc:	add    BYTE PTR [rax],al
	...

0000000000001500 <botlish_fn_19: upper_hex?<int>>:
    1500:	push   rbp
    1501:	mov    rbp,rsp
    1504:	sub    rsp,0x20
    1508:	mov    QWORD PTR [rsp],rbx
    150c:	mov    QWORD PTR [rsp+0x8],r12
    1511:	mov    QWORD PTR [rsp+0x10],r13
    1516:	mov    QWORD PTR [rsp+0x18],r14
    151b:	mov    rbx,rsi
    151e:	mov    r12,rdi
    1521:	mov    r13,rdx
    1524:	mov    rsi,r13
    1527:	mov    rdi,r12
    152a:	call   152f <botlish_fn_19+0x2f>
			152b: R_X86_64_PLT32	rt_list_len-0x4
    152f:	mov    rcx,rbx
    1532:	and    rcx,rax
    1535:	mov    rdx,rax
    1538:	test   rcx,0x1
    153f:	jne    1566 <botlish_fn_19+0x66>
    1545:	mov    rsi,rbx
    1548:	mov    rdi,r12
    154b:	call   1550 <botlish_fn_19+0x50>
			154c: R_X86_64_PLT32	rt_int_cmp-0x4
    1550:	mov    r10d,0x2
    1556:	test   rax,rax
    1559:	cmovge r10,QWORD PTR [rip+0xd7]        # 1638 <botlish_fn_19+0x138>
    1561:	jmp    1577 <botlish_fn_19+0x77>
    1566:	mov    r10d,0x2
    156c:	cmp    rbx,rdx
    156f:	cmovge r10,QWORD PTR [rip+0xc1]        # 1638 <botlish_fn_19+0x138>
    1577:	mov    eax,0x6
    157c:	mov    r14,rax
    157f:	cmp    r10,0x6
    1583:	je     1593 <botlish_fn_19+0x93>
    1589:	mov    ecx,0x2
    158e:	jmp    1596 <botlish_fn_19+0x96>
    1593:	mov    rcx,r14
    1596:	cmp    rcx,0x6
    159a:	je     1615 <botlish_fn_19+0x115>
    15a0:	mov    rdx,r13
    15a3:	mov    rcx,QWORD PTR [rdx+0x10]
    15a7:	sar    rbx,1
    15aa:	mov    rbx,QWORD PTR [rcx+rbx*8]
    15ae:	sar    rbx,1
    15b1:	mov    rdi,r12
    15b4:	mov    rsi,rbx
    15b7:	call   15bc <botlish_fn_19+0xbc>
			15b8: R_X86_64_PLT32	botlish_fn_3-0x4 ; ascii::is_digit<int>
    15bc:	cmp    rax,0x6
    15c0:	je     160d <botlish_fn_19+0x10d>
    15c6:	cmp    rbx,0x41
    15ca:	jge    15da <botlish_fn_19+0xda>
    15d0:	mov    ecx,0x2
    15d5:	jmp    15f1 <botlish_fn_19+0xf1>
    15da:	cmp    rbx,0x46
    15de:	jle    15ee <botlish_fn_19+0xee>
    15e4:	mov    ecx,0x2
    15e9:	jmp    15f1 <botlish_fn_19+0xf1>
    15ee:	mov    rcx,r14
    15f1:	cmp    rcx,0x6
    15f5:	je     1605 <botlish_fn_19+0x105>
    15fb:	mov    eax,0x2
    1600:	jmp    161a <botlish_fn_19+0x11a>
    1605:	mov    rax,r14
    1608:	jmp    161a <botlish_fn_19+0x11a>
    160d:	mov    rax,r14
    1610:	jmp    161a <botlish_fn_19+0x11a>
    1615:	mov    eax,0x2
    161a:	mov    rbx,QWORD PTR [rsp]
    161e:	mov    r12,QWORD PTR [rsp+0x8]
    1623:	mov    r13,QWORD PTR [rsp+0x10]
    1628:	mov    r14,QWORD PTR [rsp+0x18]
    162d:	add    rsp,0x20
    1631:	mov    rsp,rbp
    1634:	pop    rbp
    1635:	ret
    1636:	add    BYTE PTR [rax],al
    1638:	(bad)
    1639:	add    BYTE PTR [rax],al
    163b:	add    BYTE PTR [rax],al
    163d:	add    BYTE PTR [rax],al
	...

0000000000001640 <botlish_entry_19: upper_hex?<int>>:
    1640:	push   rbp
    1641:	mov    rbp,rsp
    1644:	mov    rsi,QWORD PTR [rdx]
    1647:	mov    rdx,QWORD PTR [rdx+0x8]
    164b:	call   1650 <botlish_entry_19+0x10>
			164c: R_X86_64_PLT32	botlish_fn_19-0x4 ; upper_hex?<int>
    1650:	mov    rsp,rbp
    1653:	pop    rbp
    1654:	ret
    1655:	add    BYTE PTR [rax],al
	...

0000000000001658 <botlish_fn_20: valid_from?<int>>:
    1658:	push   rbp
    1659:	mov    rbp,rsp
    165c:	sub    rsp,0x40
    1660:	mov    QWORD PTR [rsp+0x20],rbx
    1665:	mov    QWORD PTR [rsp+0x28],r12
    166a:	mov    QWORD PTR [rsp+0x30],r13
    166f:	mov    r12,rdi
    1672:	mov    QWORD PTR [rsp],rsi
    1676:	mov    r13,rsi
    1679:	mov    QWORD PTR [rsp+0x8],rdx
    167e:	mov    rbx,rdx
    1681:	mov    rsi,rbx
    1684:	mov    rdi,r12
    1687:	call   168c <botlish_fn_20+0x34>
			1688: R_X86_64_PLT32	rt_list_len-0x4
    168c:	mov    rsi,r13
    168f:	mov    rcx,rsi
    1692:	and    rcx,rax
    1695:	mov    rdx,rax
    1698:	test   rcx,0x1
    169f:	jne    16c5 <botlish_fn_20+0x6d>
    16a5:	mov    rsi,r13
    16a8:	mov    rdi,r12
    16ab:	call   16b0 <botlish_fn_20+0x58>
			16ac: R_X86_64_PLT32	rt_int_cmp-0x4
    16b0:	mov    ecx,0x2
    16b5:	test   rax,rax
    16b8:	cmovge rcx,QWORD PTR [rip+0x228]        # 18e8 <botlish_fn_20+0x290>
    16c0:	jmp    16d8 <botlish_fn_20+0x80>
    16c5:	mov    ecx,0x2
    16ca:	mov    rsi,r13
    16cd:	cmp    rsi,rdx
    16d0:	cmovge rcx,QWORD PTR [rip+0x210]        # 18e8 <botlish_fn_20+0x290>
    16d8:	cmp    rcx,0x6
    16dc:	je     16ec <botlish_fn_20+0x94>
    16e2:	mov    ecx,0x2
    16e7:	jmp    16f1 <botlish_fn_20+0x99>
    16ec:	mov    ecx,0x6
    16f1:	cmp    rcx,0x6
    16f5:	je     18c5 <botlish_fn_20+0x26d>
    16fb:	mov    rsi,QWORD PTR [rbx+0x10]
    16ff:	mov    rax,r13
    1702:	mov    rdi,rax
    1705:	sar    rdi,1
    1708:	mov    rsi,QWORD PTR [rsi+rdi*8]
    170c:	mov    rdi,rsi
    170f:	sar    rdi,1
    1712:	cmp    rdi,0x25
    1716:	je     1795 <botlish_fn_20+0x13d>
    171c:	mov    rdi,r12
    171f:	call   1724 <botlish_fn_20+0xcc>
			1720: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<int>
    1724:	cmp    rax,0x6
    1728:	je     1738 <botlish_fn_20+0xe0>
    172e:	mov    eax,0x2
    1733:	jmp    18ca <botlish_fn_20+0x272>
    1738:	mov    QWORD PTR [rsp+0x10],0x3
    1741:	mov    rsi,r13
    1744:	test   rsi,0x1
    174b:	je     1771 <botlish_fn_20+0x119>
    1751:	mov    rsi,r13
    1754:	mov    rcx,rsi
    1757:	add    rcx,0x2
    175b:	seto   al
    175e:	test   al,al
    1760:	jne    1771 <botlish_fn_20+0x119>
    1766:	mov    rsi,rcx
    1769:	mov    r13,rcx
    176c:	jmp    1787 <botlish_fn_20+0x12f>
    1771:	mov    edx,0x3
    1776:	mov    rsi,r13
    1779:	mov    rdi,r12
    177c:	call   1781 <botlish_fn_20+0x129>
			177d: R_X86_64_PLT32	rt_int_add-0x4
    1781:	mov    rsi,rax
    1784:	mov    r13,rax
    1787:	mov    QWORD PTR [rsp],rsi
    178b:	mov    QWORD PTR [rsp+0x8],rbx
    1790:	jmp    1681 <botlish_fn_20+0x29>
    1795:	mov    QWORD PTR [rsp+0x10],0x3
    179e:	mov    rsi,r13
    17a1:	test   rsi,0x1
    17a8:	je     17c0 <botlish_fn_20+0x168>
    17ae:	mov    rsi,r13
    17b1:	add    rsi,0x2
    17b5:	seto   al
    17b8:	test   al,al
    17ba:	je     17d3 <botlish_fn_20+0x17b>
    17c0:	mov    edx,0x3
    17c5:	mov    rsi,r13
    17c8:	mov    rdi,r12
    17cb:	call   17d0 <botlish_fn_20+0x178>
			17cc: R_X86_64_PLT32	rt_int_add-0x4
    17d0:	mov    rsi,rax
    17d3:	mov    rdx,rbx
    17d6:	mov    rdi,r12
    17d9:	call   17de <botlish_fn_20+0x186>
			17da: R_X86_64_PLT32	botlish_fn_19-0x4 ; upper_hex?<int>
    17de:	cmp    rax,0x6
    17e2:	je     17f2 <botlish_fn_20+0x19a>
    17e8:	mov    ecx,0x2
    17ed:	jmp    1854 <botlish_fn_20+0x1fc>
    17f2:	mov    QWORD PTR [rsp+0x10],0x5
    17fb:	mov    rsi,r13
    17fe:	test   rsi,0x1
    1805:	je     181d <botlish_fn_20+0x1c5>
    180b:	mov    rsi,r13
    180e:	add    rsi,0x4
    1812:	seto   al
    1815:	test   al,al
    1817:	je     1830 <botlish_fn_20+0x1d8>
    181d:	mov    edx,0x5
    1822:	mov    rsi,r13
    1825:	mov    rdi,r12
    1828:	call   182d <botlish_fn_20+0x1d5>
			1829: R_X86_64_PLT32	rt_int_add-0x4
    182d:	mov    rsi,rax
    1830:	mov    rdx,rbx
    1833:	mov    rdi,r12
    1836:	call   183b <botlish_fn_20+0x1e3>
			1837: R_X86_64_PLT32	botlish_fn_19-0x4 ; upper_hex?<int>
    183b:	cmp    rax,0x6
    183f:	je     184f <botlish_fn_20+0x1f7>
    1845:	mov    ecx,0x2
    184a:	jmp    1854 <botlish_fn_20+0x1fc>
    184f:	mov    ecx,0x6
    1854:	cmp    rcx,0x6
    1858:	je     1868 <botlish_fn_20+0x210>
    185e:	mov    eax,0x2
    1863:	jmp    18ca <botlish_fn_20+0x272>
    1868:	mov    QWORD PTR [rsp+0x10],0x7
    1871:	mov    rsi,r13
    1874:	test   rsi,0x1
    187b:	je     18a1 <botlish_fn_20+0x249>
    1881:	mov    rsi,r13
    1884:	mov    rcx,rsi
    1887:	add    rcx,0x6
    188b:	seto   al
    188e:	test   al,al
    1890:	jne    18a1 <botlish_fn_20+0x249>
    1896:	mov    rsi,rcx
    1899:	mov    r13,rcx
    189c:	jmp    18b7 <botlish_fn_20+0x25f>
    18a1:	mov    edx,0x7
    18a6:	mov    rsi,r13
    18a9:	mov    rdi,r12
    18ac:	call   18b1 <botlish_fn_20+0x259>
			18ad: R_X86_64_PLT32	rt_int_add-0x4
    18b1:	mov    rsi,rax
    18b4:	mov    r13,rax
    18b7:	mov    QWORD PTR [rsp],rsi
    18bb:	mov    QWORD PTR [rsp+0x8],rbx
    18c0:	jmp    1681 <botlish_fn_20+0x29>
    18c5:	mov    eax,0x6
    18ca:	mov    rbx,QWORD PTR [rsp+0x20]
    18cf:	mov    r12,QWORD PTR [rsp+0x28]
    18d4:	mov    r13,QWORD PTR [rsp+0x30]
    18d9:	add    rsp,0x40
    18dd:	mov    rsp,rbp
    18e0:	pop    rbp
    18e1:	ret
    18e2:	add    BYTE PTR [rax],al
    18e4:	add    BYTE PTR [rax],al
    18e6:	add    BYTE PTR [rax],al
    18e8:	(bad)
    18e9:	add    BYTE PTR [rax],al
    18eb:	add    BYTE PTR [rax],al
    18ed:	add    BYTE PTR [rax],al
	...

00000000000018f0 <botlish_entry_20: valid_from?<int>>:
    18f0:	push   rbp
    18f1:	mov    rbp,rsp
    18f4:	mov    rsi,QWORD PTR [rdx]
    18f7:	mov    rdx,QWORD PTR [rdx+0x8]
    18fb:	call   1900 <botlish_entry_20+0x10>
			18fc: R_X86_64_PLT32	botlish_fn_20-0x4 ; valid_from?<int>
    1900:	mov    rsp,rbp
    1903:	pop    rbp
    1904:	ret

0000000000001905 <botlish_fn_21: web::uri_escape_text<str>>:
    1905:	push   rbp
    1906:	mov    rbp,rsp
    1909:	sub    rsp,0x10
    190d:	mov    edx,0x1
    1912:	mov    QWORD PTR [rsp],0x1
    191a:	mov    r10,QWORD PTR [rdi+0x10]
    191e:	mov    rcx,QWORD PTR [r10+0xd0]
    1925:	mov    QWORD PTR [rsp+0x8],rcx
    192a:	call   192f <botlish_fn_21+0x2a>
			192b: R_X86_64_PLT32	botlish_fn_26-0x4 ; esc_from<str, int, str>
    192f:	test   rax,rax
    1932:	jne    1944 <botlish_fn_21+0x3f>
    1938:	xor    rax,rax
    193b:	add    rsp,0x10
    193f:	mov    rsp,rbp
    1942:	pop    rbp
    1943:	ret
    1944:	add    rsp,0x10
    1948:	mov    rsp,rbp
    194b:	pop    rbp
    194c:	ret

000000000000194d <botlish_entry_21: web::uri_escape_text<str>>:
    194d:	push   rbp
    194e:	mov    rbp,rsp
    1951:	sub    rsp,0x10
    1955:	mov    QWORD PTR [rsp],r12
    1959:	mov    r12,rdi
    195c:	mov    rsi,QWORD PTR [rdx]
    195f:	mov    r8,QWORD PTR [rip+0x0]        # 1966 <botlish_entry_21+0x19>
			1962: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    1966:	call   r8
    1969:	mov    rsi,rax
    196c:	mov    rdi,r12
    196f:	call   1974 <botlish_entry_21+0x27>
			1970: R_X86_64_PLT32	botlish_fn_21-0x4 ; web::uri_escape_text<str>
    1974:	mov    r12,QWORD PTR [rsp]
    1978:	add    rsp,0x10
    197c:	mov    rsp,rbp
    197f:	pop    rbp
    1980:	ret

0000000000001981 <botlish_fn_22: high_nibble<int>>:
    1981:	push   rbp
    1982:	mov    rbp,rsp
    1985:	sub    rsp,0x10
    1989:	mov    QWORD PTR [rsp],rsi
    198d:	mov    QWORD PTR [rsp+0x8],0x1e1
    1996:	test   rsi,0x1
    199d:	jne    19b2 <botlish_fn_22+0x31>
    19a3:	mov    edx,0x1e1
    19a8:	call   19ad <botlish_fn_22+0x2c>
			19a9: R_X86_64_PLT32	rt_int_and-0x4
    19ad:	jmp    19bc <botlish_fn_22+0x3b>
    19b2:	and    rsi,0x1e1
    19b9:	mov    rax,rsi
    19bc:	sar    rax,0x5
    19c0:	shl    rax,1
    19c3:	or     rax,0x1
    19c7:	add    rsp,0x10
    19cb:	mov    rsp,rbp
    19ce:	pop    rbp
    19cf:	ret

00000000000019d0 <botlish_entry_22: high_nibble<int>>:
    19d0:	push   rbp
    19d1:	mov    rbp,rsp
    19d4:	mov    rsi,QWORD PTR [rdx]
    19d7:	call   19dc <botlish_entry_22+0xc>
			19d8: R_X86_64_PLT32	botlish_fn_22-0x4 ; high_nibble<int>
    19dc:	mov    rsp,rbp
    19df:	pop    rbp
    19e0:	ret

00000000000019e1 <botlish_fn_23: hex_pair<int>>:
    19e1:	push   rbp
    19e2:	mov    rbp,rsp
    19e5:	sub    rsp,0x50
    19e9:	mov    QWORD PTR [rsp+0x30],rbx
    19ee:	mov    QWORD PTR [rsp+0x38],r12
    19f3:	mov    QWORD PTR [rsp+0x40],r13
    19f8:	mov    QWORD PTR [rsp+0x48],r14
    19fd:	mov    QWORD PTR [rsp],rsi
    1a01:	mov    r14,rsi
    1a04:	mov    rax,QWORD PTR [rdi+0x30]
    1a08:	mov    r13,rdi
    1a0b:	mov    rbx,QWORD PTR [rax+0x8]
    1a0f:	mov    QWORD PTR [rsp+0x8],rbx
    1a14:	mov    rsi,r14
    1a17:	call   1a1c <botlish_fn_23+0x3b>
			1a18: R_X86_64_PLT32	botlish_fn_22-0x4 ; high_nibble<int>
    1a1c:	mov    rcx,QWORD PTR [rbx+0x10]
    1a20:	sar    rax,1
    1a23:	mov    r12,QWORD PTR [rcx+rax*8]
    1a27:	mov    QWORD PTR [rsp],r12
    1a2b:	mov    rdi,r13
    1a2e:	mov    rax,QWORD PTR [rdi+0x30]
    1a32:	mov    rbx,QWORD PTR [rax+0x8]
    1a36:	mov    edx,0x21
    1a3b:	mov    rsi,r14
    1a3e:	call   1a43 <botlish_fn_23+0x62>
			1a3f: R_X86_64_PLT32	rt_int_mod-0x4
    1a43:	test   rax,rax
    1a46:	je     1a98 <botlish_fn_23+0xb7>
    1a4c:	mov    rcx,QWORD PTR [rbx+0x10]
    1a50:	sar    rax,1
    1a53:	mov    rdx,QWORD PTR [rcx+rax*8]
    1a57:	mov    QWORD PTR [rsp+0x8],rdx
    1a5c:	lea    rcx,[rsp+0x10]
    1a61:	mov    QWORD PTR [rsp+0x10],0x0
    1a6a:	mov    QWORD PTR [rsp+0x18],r12
    1a6f:	mov    QWORD PTR [rsp+0x20],0x0
    1a78:	mov    QWORD PTR [rsp+0x28],rdx
    1a7d:	mov    esi,0x2
    1a82:	mov    edx,0x4
    1a87:	mov    rdi,r13
    1a8a:	call   1a8f <botlish_fn_23+0xae>
			1a8b: R_X86_64_PLT32	rt_construct-0x4
    1a8f:	test   rax,rax
    1a92:	jne    1ab8 <botlish_fn_23+0xd7>
    1a98:	xor    rax,rax
    1a9b:	mov    rbx,QWORD PTR [rsp+0x30]
    1aa0:	mov    r12,QWORD PTR [rsp+0x38]
    1aa5:	mov    r13,QWORD PTR [rsp+0x40]
    1aaa:	mov    r14,QWORD PTR [rsp+0x48]
    1aaf:	add    rsp,0x50
    1ab3:	mov    rsp,rbp
    1ab6:	pop    rbp
    1ab7:	ret
    1ab8:	mov    rbx,QWORD PTR [rsp+0x30]
    1abd:	mov    r12,QWORD PTR [rsp+0x38]
    1ac2:	mov    r13,QWORD PTR [rsp+0x40]
    1ac7:	mov    r14,QWORD PTR [rsp+0x48]
    1acc:	add    rsp,0x50
    1ad0:	mov    rsp,rbp
    1ad3:	pop    rbp
    1ad4:	ret

0000000000001ad5 <botlish_entry_23: hex_pair<int>>:
    1ad5:	push   rbp
    1ad6:	mov    rbp,rsp
    1ad9:	sub    rsp,0x10
    1add:	mov    QWORD PTR [rsp],r12
    1ae1:	mov    r12,rdi
    1ae4:	mov    rsi,QWORD PTR [rdx]
    1ae7:	call   1aec <botlish_entry_23+0x17>
			1ae8: R_X86_64_PLT32	botlish_fn_23-0x4 ; hex_pair<int>
    1aec:	mov    r8,QWORD PTR [rip+0x0]        # 1af3 <botlish_entry_23+0x1e>
			1aef: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1af3:	mov    rsi,rax
    1af6:	mov    rdi,r12
    1af9:	call   r8
    1afc:	mov    r12,QWORD PTR [rsp]
    1b00:	add    rsp,0x10
    1b04:	mov    rsp,rbp
    1b07:	pop    rbp
    1b08:	ret
    1b09:	add    BYTE PTR [rax],al
    1b0b:	add    BYTE PTR [rax],al
    1b0d:	add    BYTE PTR [rax],al
	...

0000000000001b10 <botlish_fn_24: esc_bytes<List[int], int, str>>:
    1b10:	push   rbp
    1b11:	mov    rbp,rsp
    1b14:	sub    rsp,0xa0
    1b1b:	mov    QWORD PTR [rsp+0x70],rbx
    1b20:	mov    QWORD PTR [rsp+0x78],r12
    1b25:	mov    QWORD PTR [rsp+0x80],r13
    1b2d:	mov    QWORD PTR [rsp+0x88],r14
    1b35:	mov    QWORD PTR [rsp+0x90],r15
    1b3d:	mov    QWORD PTR [rsp+0x20],0x0
    1b46:	mov    QWORD PTR [rsp],rsi
    1b4a:	mov    QWORD PTR [rsp+0x8],rdx
    1b4f:	mov    r14,rdx
    1b52:	mov    QWORD PTR [rsp+0x10],rcx
    1b57:	lea    r13,[rsp+0x28]
    1b5c:	mov    rbx,rdi
    1b5f:	mov    r12,rsi
    1b62:	mov    QWORD PTR [rsp+0x58],rcx
    1b67:	mov    rsi,r12
    1b6a:	mov    rdi,rbx
    1b6d:	call   1b72 <botlish_fn_24+0x62>
			1b6e: R_X86_64_PLT32	rt_list_len-0x4
    1b72:	mov    rcx,r14
    1b75:	and    rcx,rax
    1b78:	mov    rdx,rax
    1b7b:	test   rcx,0x1
    1b82:	jne    1ba8 <botlish_fn_24+0x98>
    1b88:	mov    rsi,r14
    1b8b:	mov    rdi,rbx
    1b8e:	call   1b93 <botlish_fn_24+0x83>
			1b8f: R_X86_64_PLT32	rt_int_cmp-0x4
    1b93:	mov    ecx,0x2
    1b98:	test   rax,rax
    1b9b:	cmovge rcx,QWORD PTR [rip+0x185]        # 1d28 <botlish_fn_24+0x218>
    1ba3:	jmp    1bb8 <botlish_fn_24+0xa8>
    1ba8:	mov    ecx,0x2
    1bad:	cmp    r14,rdx
    1bb0:	cmovge rcx,QWORD PTR [rip+0x170]        # 1d28 <botlish_fn_24+0x218>
    1bb8:	cmp    rcx,0x6
    1bbc:	je     1bcc <botlish_fn_24+0xbc>
    1bc2:	mov    eax,0x2
    1bc7:	jmp    1bd1 <botlish_fn_24+0xc1>
    1bcc:	mov    eax,0x6
    1bd1:	cmp    rax,0x6
    1bd5:	je     1cf5 <botlish_fn_24+0x1e5>
    1bdb:	mov    QWORD PTR [rsp+0x18],0x3
    1be4:	test   r14,0x1
    1beb:	je     1c03 <botlish_fn_24+0xf3>
    1bf1:	mov    rax,r14
    1bf4:	add    rax,0x2
    1bf8:	seto   cl
    1bfb:	test   cl,cl
    1bfd:	je     1c13 <botlish_fn_24+0x103>
    1c03:	mov    edx,0x3
    1c08:	mov    rsi,r14
    1c0b:	mov    rdi,rbx
    1c0e:	call   1c13 <botlish_fn_24+0x103>
			1c0f: R_X86_64_PLT32	rt_int_add-0x4
    1c13:	mov    QWORD PTR [rsp+0x8],rax
    1c18:	mov    QWORD PTR [rsp+0x60],rax
    1c1d:	mov    rax,QWORD PTR [rbx+0x10]
    1c21:	mov    r15,QWORD PTR [rax+0x10]
    1c25:	mov    QWORD PTR [rsp+0x18],r15
    1c2a:	mov    rax,QWORD PTR [r12+0x10]
    1c2f:	sar    r14,1
    1c32:	mov    rsi,QWORD PTR [rax+r14*8]
    1c36:	mov    QWORD PTR [rsp+0x20],rsi
    1c3b:	mov    rdi,rbx
    1c3e:	call   1c43 <botlish_fn_24+0x133>
			1c3f: R_X86_64_PLT32	botlish_fn_23-0x4 ; hex_pair<int>
    1c43:	test   rax,rax
    1c46:	je     1ca4 <botlish_fn_24+0x194>
    1c4c:	mov    QWORD PTR [rsp+0x20],rax
    1c51:	mov    rcx,rax
    1c54:	mov    QWORD PTR [rsp+0x28],0x0
    1c5d:	mov    rax,QWORD PTR [rsp+0x58]
    1c62:	mov    QWORD PTR [rsp+0x30],rax
    1c67:	mov    QWORD PTR [rsp+0x38],0x0
    1c70:	mov    QWORD PTR [rsp+0x40],r15
    1c75:	mov    QWORD PTR [rsp+0x48],0x0
    1c7e:	mov    rax,rcx
    1c81:	mov    QWORD PTR [rsp+0x50],rax
    1c86:	mov    esi,0x2
    1c8b:	mov    edx,0x6
    1c90:	mov    rcx,r13
    1c93:	mov    rdi,rbx
    1c96:	call   1c9b <botlish_fn_24+0x18b>
			1c97: R_X86_64_PLT32	rt_construct-0x4
    1c9b:	test   rax,rax
    1c9e:	jne    1cd5 <botlish_fn_24+0x1c5>
    1ca4:	xor    rax,rax
    1ca7:	mov    rbx,QWORD PTR [rsp+0x70]
    1cac:	mov    r12,QWORD PTR [rsp+0x78]
    1cb1:	mov    r13,QWORD PTR [rsp+0x80]
    1cb9:	mov    r14,QWORD PTR [rsp+0x88]
    1cc1:	mov    r15,QWORD PTR [rsp+0x90]
    1cc9:	add    rsp,0xa0
    1cd0:	mov    rsp,rbp
    1cd3:	pop    rbp
    1cd4:	ret
    1cd5:	mov    QWORD PTR [rsp],r12
    1cd9:	mov    rcx,QWORD PTR [rsp+0x60]
    1cde:	mov    QWORD PTR [rsp+0x8],rcx
    1ce3:	mov    QWORD PTR [rsp+0x10],rax
    1ce8:	mov    r14,rcx
    1ceb:	mov    QWORD PTR [rsp+0x58],rax
    1cf0:	jmp    1b67 <botlish_fn_24+0x57>
    1cf5:	mov    rax,QWORD PTR [rsp+0x58]
    1cfa:	mov    rbx,QWORD PTR [rsp+0x70]
    1cff:	mov    r12,QWORD PTR [rsp+0x78]
    1d04:	mov    r13,QWORD PTR [rsp+0x80]
    1d0c:	mov    r14,QWORD PTR [rsp+0x88]
    1d14:	mov    r15,QWORD PTR [rsp+0x90]
    1d1c:	add    rsp,0xa0
    1d23:	mov    rsp,rbp
    1d26:	pop    rbp
    1d27:	ret
    1d28:	(bad)
    1d29:	add    BYTE PTR [rax],al
    1d2b:	add    BYTE PTR [rax],al
    1d2d:	add    BYTE PTR [rax],al
	...

0000000000001d30 <botlish_entry_24: esc_bytes<List[int], int, str>>:
    1d30:	push   rbp
    1d31:	mov    rbp,rsp
    1d34:	sub    rsp,0x10
    1d38:	mov    QWORD PTR [rsp],r12
    1d3c:	mov    r12,rdi
    1d3f:	mov    rsi,QWORD PTR [rdx]
    1d42:	mov    r8,QWORD PTR [rdx+0x8]
    1d46:	mov    rcx,QWORD PTR [rdx+0x10]
    1d4a:	mov    rdx,r8
    1d4d:	call   1d52 <botlish_entry_24+0x22>
			1d4e: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_bytes<List[int], int, str>
    1d52:	mov    r8,QWORD PTR [rip+0x0]        # 1d59 <botlish_entry_24+0x29>
			1d55: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1d59:	mov    rsi,rax
    1d5c:	mov    rdi,r12
    1d5f:	call   r8
    1d62:	mov    r12,QWORD PTR [rsp]
    1d66:	add    rsp,0x10
    1d6a:	mov    rsp,rbp
    1d6d:	pop    rbp
    1d6e:	ret

0000000000001d6f <botlish_fn_25: esc_char<str>>:
    1d6f:	push   rbp
    1d70:	mov    rbp,rsp
    1d73:	sub    rsp,0x40
    1d77:	mov    QWORD PTR [rsp+0x20],rbx
    1d7c:	mov    QWORD PTR [rsp+0x28],r12
    1d81:	mov    QWORD PTR [rsp+0x30],r13
    1d86:	mov    rbx,rdi
    1d89:	mov    QWORD PTR [rsp+0x8],0x0
    1d92:	mov    QWORD PTR [rsp+0x10],0x0
    1d9b:	mov    QWORD PTR [rsp],rsi
    1d9f:	mov    r13,rsi
    1da2:	mov    rsi,r13
    1da5:	mov    rdi,rbx
    1da8:	call   1dad <botlish_fn_25+0x3e>
			1da9: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1dad:	mov    rcx,rax
    1db0:	mov    r12,rax
    1db3:	test   rax,rcx
    1db6:	je     1e60 <botlish_fn_25+0xf1>
    1dbc:	mov    rax,r12
    1dbf:	mov    QWORD PTR [rsp],rax
    1dc3:	mov    rsi,r12
    1dc6:	mov    rdi,rbx
    1dc9:	call   1dce <botlish_fn_25+0x5f>
			1dca: R_X86_64_PLT32	rt_list_len-0x4
    1dce:	sar    rax,1
    1dd1:	cmp    rax,0x1
    1dd5:	je     1e12 <botlish_fn_25+0xa3>
    1ddb:	mov    edx,0x1
    1de0:	mov    QWORD PTR [rsp+0x8],0x1
    1de9:	mov    rdi,rbx
    1dec:	mov    rax,QWORD PTR [rdi+0x10]
    1df0:	mov    rcx,QWORD PTR [rax+0xd0]
    1df7:	mov    QWORD PTR [rsp+0x10],rcx
    1dfc:	mov    rsi,r12
    1dff:	call   1e04 <botlish_fn_25+0x95>
			1e00: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_bytes<List[int], int, str>
    1e04:	test   rax,rax
    1e07:	je     1e60 <botlish_fn_25+0xf1>
    1e0d:	jmp    1e81 <botlish_fn_25+0x112>
    1e12:	mov    rsi,r12
    1e15:	mov    rax,QWORD PTR [rsi+0x10]
    1e19:	mov    rsi,QWORD PTR [rax]
    1e1c:	mov    rdi,rbx
    1e1f:	call   1e24 <botlish_fn_25+0xb5>
			1e20: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<int>
    1e24:	cmp    rax,0x6
    1e28:	je     1e7e <botlish_fn_25+0x10f>
    1e2e:	mov    edx,0x1
    1e33:	mov    QWORD PTR [rsp+0x8],0x1
    1e3c:	mov    rdi,rbx
    1e3f:	mov    rax,QWORD PTR [rdi+0x10]
    1e43:	mov    rcx,QWORD PTR [rax+0xd0]
    1e4a:	mov    QWORD PTR [rsp+0x10],rcx
    1e4f:	mov    rsi,r12
    1e52:	call   1e57 <botlish_fn_25+0xe8>
			1e53: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_bytes<List[int], int, str>
    1e57:	test   rax,rax
    1e5a:	jne    1e7b <botlish_fn_25+0x10c>
    1e60:	xor    rax,rax
    1e63:	mov    rbx,QWORD PTR [rsp+0x20]
    1e68:	mov    r12,QWORD PTR [rsp+0x28]
    1e6d:	mov    r13,QWORD PTR [rsp+0x30]
    1e72:	add    rsp,0x40
    1e76:	mov    rsp,rbp
    1e79:	pop    rbp
    1e7a:	ret
    1e7b:	mov    r13,rax
    1e7e:	mov    rax,r13
    1e81:	mov    rbx,QWORD PTR [rsp+0x20]
    1e86:	mov    r12,QWORD PTR [rsp+0x28]
    1e8b:	mov    r13,QWORD PTR [rsp+0x30]
    1e90:	add    rsp,0x40
    1e94:	mov    rsp,rbp
    1e97:	pop    rbp
    1e98:	ret

0000000000001e99 <botlish_entry_25: esc_char<str>>:
    1e99:	push   rbp
    1e9a:	mov    rbp,rsp
    1e9d:	sub    rsp,0x10
    1ea1:	mov    QWORD PTR [rsp],r12
    1ea5:	mov    r12,rdi
    1ea8:	mov    rsi,QWORD PTR [rdx]
    1eab:	call   1eb0 <botlish_entry_25+0x17>
			1eac: R_X86_64_PLT32	botlish_fn_25-0x4 ; esc_char<str>
    1eb0:	mov    r8,QWORD PTR [rip+0x0]        # 1eb7 <botlish_entry_25+0x1e>
			1eb3: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1eb7:	mov    rsi,rax
    1eba:	mov    rdi,r12
    1ebd:	call   r8
    1ec0:	mov    r12,QWORD PTR [rsp]
    1ec4:	add    rsp,0x10
    1ec8:	mov    rsp,rbp
    1ecb:	pop    rbp
    1ecc:	ret
    1ecd:	add    BYTE PTR [rax],al
	...

0000000000001ed0 <botlish_fn_26: esc_from<str, int, str>>:
    1ed0:	push   rbp
    1ed1:	mov    rbp,rsp
    1ed4:	sub    rsp,0xa0
    1edb:	mov    QWORD PTR [rsp+0x70],rbx
    1ee0:	mov    QWORD PTR [rsp+0x78],r12
    1ee5:	mov    QWORD PTR [rsp+0x80],r13
    1eed:	mov    QWORD PTR [rsp+0x88],r14
    1ef5:	mov    QWORD PTR [rsp+0x90],r15
    1efd:	mov    r13,rdi
    1f00:	mov    QWORD PTR [rsp+0x10],0x0
    1f09:	mov    QWORD PTR [rsp+0x18],0x0
    1f12:	mov    QWORD PTR [rsp+0x20],0x0
    1f1b:	mov    QWORD PTR [rsp],rdx
    1f1f:	mov    QWORD PTR [rsp+0x8],rcx
    1f24:	mov    QWORD PTR [rsp+0x58],rcx
    1f29:	mov    r12d,0x47
    1f2f:	mov    rcx,0xffffffffffffffff
    1f36:	bsr    rax,rsi
    1f3a:	mov    r15,rsi
    1f3d:	cmove  rax,rcx
    1f41:	mov    ecx,0x3f
    1f46:	sub    rcx,rax
    1f49:	sub    r12,rcx
    1f4c:	shr    r12,0x3
    1f50:	shl    r12,1
    1f53:	lea    rbx,[rsp+0x38]
    1f58:	mov    rax,r12
    1f5b:	or     rax,0x1
    1f5f:	mov    r14,rdx
    1f62:	mov    rcx,r14
    1f65:	and    rcx,rax
    1f68:	test   rcx,0x1
    1f6f:	jne    1f9c <botlish_fn_26+0xcc>
    1f75:	mov    rdx,r12
    1f78:	or     rdx,0x1
    1f7c:	mov    rsi,r14
    1f7f:	mov    rdi,r13
    1f82:	call   1f87 <botlish_fn_26+0xb7>
			1f83: R_X86_64_PLT32	rt_int_cmp-0x4
    1f87:	mov    ecx,0x2
    1f8c:	test   rax,rax
    1f8f:	cmovge rcx,QWORD PTR [rip+0x1f1]        # 2188 <botlish_fn_26+0x2b8>
    1f97:	jmp    1fb3 <botlish_fn_26+0xe3>
    1f9c:	mov    rax,r12
    1f9f:	or     rax,0x1
    1fa3:	mov    ecx,0x2
    1fa8:	cmp    r14,rax
    1fab:	cmovge rcx,QWORD PTR [rip+0x1d5]        # 2188 <botlish_fn_26+0x2b8>
    1fb3:	cmp    rcx,0x6
    1fb7:	je     1fc7 <botlish_fn_26+0xf7>
    1fbd:	mov    eax,0x2
    1fc2:	jmp    1fcc <botlish_fn_26+0xfc>
    1fc7:	mov    eax,0x6
    1fcc:	cmp    rax,0x6
    1fd0:	je     20f3 <botlish_fn_26+0x223>
    1fd6:	mov    QWORD PTR [rsp+0x10],0x3
    1fdf:	test   r14,0x1
    1fe6:	je     1ffe <botlish_fn_26+0x12e>
    1fec:	mov    rax,r14
    1fef:	add    rax,0x2
    1ff3:	seto   cl
    1ff6:	test   cl,cl
    1ff8:	je     200e <botlish_fn_26+0x13e>
    1ffe:	mov    edx,0x3
    2003:	mov    rsi,r14
    2006:	mov    rdi,r13
    2009:	call   200e <botlish_fn_26+0x13e>
			200a: R_X86_64_PLT32	rt_int_add-0x4
    200e:	mov    QWORD PTR [rsp+0x10],rax
    2013:	mov    QWORD PTR [rsp+0x60],rax
    2018:	mov    rsi,r15
    201b:	mov    rdi,r13
    201e:	call   2023 <botlish_fn_26+0x153>
			201f: R_X86_64_PLT32	rt_ascii_to_str-0x4
    2023:	mov    QWORD PTR [rsp+0x18],rax
    2028:	mov    QWORD PTR [rsp+0x68],rax
    202d:	mov    QWORD PTR [rsp+0x20],0x3
    2036:	test   r14,0x1
    203d:	je     2055 <botlish_fn_26+0x185>
    2043:	mov    rcx,r14
    2046:	add    rcx,0x2
    204a:	seto   al
    204d:	test   al,al
    204f:	je     2068 <botlish_fn_26+0x198>
    2055:	mov    edx,0x3
    205a:	mov    rsi,r14
    205d:	mov    rdi,r13
    2060:	call   2065 <botlish_fn_26+0x195>
			2061: R_X86_64_PLT32	rt_int_add-0x4
    2065:	mov    rcx,rax
    2068:	mov    QWORD PTR [rsp+0x20],rcx
    206d:	mov    rdx,r14
    2070:	mov    rsi,QWORD PTR [rsp+0x68]
    2075:	mov    rdi,r13
    2078:	call   207d <botlish_fn_26+0x1ad>
			2079: R_X86_64_PLT32	rt_substr_proven-0x4
    207d:	mov    QWORD PTR [rsp],rax
    2081:	mov    rsi,rax
    2084:	mov    rdi,r13
    2087:	call   208c <botlish_fn_26+0x1bc>
			2088: R_X86_64_PLT32	botlish_fn_25-0x4 ; esc_char<str>
    208c:	test   rax,rax
    208f:	je     2127 <botlish_fn_26+0x257>
    2095:	mov    QWORD PTR [rsp],rax
    2099:	mov    QWORD PTR [rsp+0x38],0x0
    20a2:	mov    rcx,QWORD PTR [rsp+0x58]
    20a7:	mov    QWORD PTR [rsp+0x40],rcx
    20ac:	mov    QWORD PTR [rsp+0x48],0x0
    20b5:	mov    QWORD PTR [rsp+0x50],rax
    20ba:	mov    esi,0x2
    20bf:	mov    edx,0x4
    20c4:	mov    rcx,rbx
    20c7:	mov    rdi,r13
    20ca:	call   20cf <botlish_fn_26+0x1ff>
			20cb: R_X86_64_PLT32	rt_construct-0x4
    20cf:	test   rax,rax
    20d2:	je     2127 <botlish_fn_26+0x257>
    20d8:	mov    rcx,QWORD PTR [rsp+0x60]
    20dd:	mov    QWORD PTR [rsp],rcx
    20e1:	mov    QWORD PTR [rsp+0x8],rax
    20e6:	mov    rdx,rcx
    20e9:	mov    QWORD PTR [rsp+0x58],rax
    20ee:	jmp    1f58 <botlish_fn_26+0x88>
    20f3:	mov    rcx,QWORD PTR [rsp+0x58]
    20f8:	xor    rsi,rsi
    20fb:	lea    rax,[rsp+0x28]
    2100:	mov    QWORD PTR [rsp+0x28],0x0
    2109:	mov    QWORD PTR [rsp+0x30],rcx
    210e:	mov    edx,0x2
    2113:	mov    rcx,rax
    2116:	mov    rdi,r13
    2119:	call   211e <botlish_fn_26+0x24e>
			211a: R_X86_64_PLT32	rt_construct-0x4
    211e:	test   rax,rax
    2121:	jne    2158 <botlish_fn_26+0x288>
    2127:	xor    rax,rax
    212a:	mov    rbx,QWORD PTR [rsp+0x70]
    212f:	mov    r12,QWORD PTR [rsp+0x78]
    2134:	mov    r13,QWORD PTR [rsp+0x80]
    213c:	mov    r14,QWORD PTR [rsp+0x88]
    2144:	mov    r15,QWORD PTR [rsp+0x90]
    214c:	add    rsp,0xa0
    2153:	mov    rsp,rbp
    2156:	pop    rbp
    2157:	ret
    2158:	mov    rbx,QWORD PTR [rsp+0x70]
    215d:	mov    r12,QWORD PTR [rsp+0x78]
    2162:	mov    r13,QWORD PTR [rsp+0x80]
    216a:	mov    r14,QWORD PTR [rsp+0x88]
    2172:	mov    r15,QWORD PTR [rsp+0x90]
    217a:	add    rsp,0xa0
    2181:	mov    rsp,rbp
    2184:	pop    rbp
    2185:	ret
    2186:	add    BYTE PTR [rax],al
    2188:	(bad)
    2189:	add    BYTE PTR [rax],al
    218b:	add    BYTE PTR [rax],al
    218d:	add    BYTE PTR [rax],al
	...

0000000000002190 <botlish_entry_26: esc_from<str, int, str>>:
    2190:	push   rbp
    2191:	mov    rbp,rsp
    2194:	sub    rsp,0x10
    2198:	mov    QWORD PTR [rsp],r12
    219c:	mov    QWORD PTR [rsp+0x8],r13
    21a1:	mov    r12,rdi
    21a4:	mov    rsi,QWORD PTR [rdx]
    21a7:	mov    r13,rdx
    21aa:	mov    r8,QWORD PTR [rip+0x0]        # 21b1 <botlish_entry_26+0x21>
			21ad: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    21b1:	call   r8
    21b4:	mov    rcx,r13
    21b7:	mov    rdx,QWORD PTR [rcx+0x8]
    21bb:	mov    rcx,QWORD PTR [rcx+0x10]
    21bf:	mov    rsi,rax
    21c2:	mov    rdi,r12
    21c5:	call   21ca <botlish_entry_26+0x3a>
			21c6: R_X86_64_PLT32	botlish_fn_26-0x4 ; esc_from<str, int, str>
    21ca:	mov    r12,QWORD PTR [rsp]
    21ce:	mov    r13,QWORD PTR [rsp+0x8]
    21d3:	add    rsp,0x10
    21d7:	mov    rsp,rbp
    21da:	pop    rbp
    21db:	ret

00000000000021dc <botlish_fn_27: check<int, int, str, str>>:
    21dc:	push   rbp
    21dd:	mov    rbp,rsp
    21e0:	sub    rsp,0x50
    21e4:	mov    QWORD PTR [rsp+0x20],rbx
    21e9:	mov    QWORD PTR [rsp+0x28],r12
    21ee:	mov    QWORD PTR [rsp+0x30],r13
    21f3:	mov    QWORD PTR [rsp+0x38],r14
    21f8:	mov    QWORD PTR [rsp+0x40],r15
    21fd:	mov    r14,rdi
    2200:	mov    QWORD PTR [rsp+0x18],0x0
    2209:	mov    QWORD PTR [rsp],rdx
    220d:	mov    QWORD PTR [rsp+0x8],rcx
    2212:	mov    QWORD PTR [rsp+0x10],r8
    2217:	mov    r12,r8
    221a:	mov    r13,rsi
    221d:	mov    r15,rdx
    2220:	test   r13,r13
    2223:	jle    2306 <botlish_fn_27+0x12a>
    2229:	mov    rbx,rcx
    222c:	mov    rsi,rbx
    222f:	mov    rdi,r14
    2232:	call   2237 <botlish_fn_27+0x5b>
			2233: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::emailish?<str>
    2237:	test   rax,rax
    223a:	je     2274 <botlish_fn_27+0x98>
    2240:	cmp    rax,0x6
    2244:	je     2260 <botlish_fn_27+0x84>
    224a:	mov    edx,0x1
    224f:	mov    QWORD PTR [rsp+0x18],0x1
    2258:	mov    rsi,r15
    225b:	jmp    22ba <botlish_fn_27+0xde>
    2260:	mov    rsi,r12
    2263:	mov    rdi,r14
    2266:	call   226b <botlish_fn_27+0x8f>
			2267: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::uri_query_value?<str>
    226b:	test   rax,rax
    226e:	jne    2299 <botlish_fn_27+0xbd>
    2274:	xor    rax,rax
    2277:	mov    rbx,QWORD PTR [rsp+0x20]
    227c:	mov    r12,QWORD PTR [rsp+0x28]
    2281:	mov    r13,QWORD PTR [rsp+0x30]
    2286:	mov    r14,QWORD PTR [rsp+0x38]
    228b:	mov    r15,QWORD PTR [rsp+0x40]
    2290:	add    rsp,0x50
    2294:	mov    rsp,rbp
    2297:	pop    rbp
    2298:	ret
    2299:	cmp    rax,0x6
    229d:	je     22ad <botlish_fn_27+0xd1>
    22a3:	mov    edx,0x1
    22a8:	jmp    22b2 <botlish_fn_27+0xd6>
    22ad:	mov    edx,0x3
    22b2:	mov    QWORD PTR [rsp+0x18],rdx
    22b7:	mov    rsi,r15
    22ba:	mov    rax,rsi
    22bd:	and    rax,rdx
    22c0:	test   rax,0x1
    22c6:	je     22e1 <botlish_fn_27+0x105>
    22cc:	lea    rcx,[rdx-0x1]
    22d0:	mov    rax,rsi
    22d3:	add    rax,rcx
    22d6:	seto   cl
    22d9:	test   cl,cl
    22db:	je     22e9 <botlish_fn_27+0x10d>
    22e1:	mov    rdi,r14
    22e4:	call   22e9 <botlish_fn_27+0x10d>
			22e5: R_X86_64_PLT32	rt_int_add-0x4
    22e9:	mov    QWORD PTR [rsp],rax
    22ed:	mov    QWORD PTR [rsp+0x8],rbx
    22f2:	mov    QWORD PTR [rsp+0x10],r12
    22f7:	sub    r13,0x1
    22fb:	mov    rcx,rbx
    22fe:	mov    r15,rax
    2301:	jmp    2220 <botlish_fn_27+0x44>
    2306:	mov    rax,r15
    2309:	mov    rbx,QWORD PTR [rsp+0x20]
    230e:	mov    r12,QWORD PTR [rsp+0x28]
    2313:	mov    r13,QWORD PTR [rsp+0x30]
    2318:	mov    r14,QWORD PTR [rsp+0x38]
    231d:	mov    r15,QWORD PTR [rsp+0x40]
    2322:	add    rsp,0x50
    2326:	mov    rsp,rbp
    2329:	pop    rbp
    232a:	ret

000000000000232b <botlish_entry_27: check<int, int, str, str>>:
    232b:	push   rbp
    232c:	mov    rbp,rsp
    232f:	mov    rsi,QWORD PTR [rdx]
    2332:	mov    r9,QWORD PTR [rdx+0x8]
    2336:	mov    rcx,QWORD PTR [rdx+0x10]
    233a:	mov    r8,QWORD PTR [rdx+0x18]
    233e:	sar    rsi,1
    2341:	mov    rdx,r9
    2344:	call   2349 <botlish_entry_27+0x1e>
			2345: R_X86_64_PLT32	botlish_fn_27-0x4 ; check<int, int, str, str>
    2349:	mov    rsp,rbp
    234c:	pop    rbp
    234d:	ret

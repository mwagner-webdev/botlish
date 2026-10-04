; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 8187  (per function: 1415 217 609 74 74 74 128 128 342 115 154 176 238 295 344 183 770 140 127 103 313 642 367 815 344)
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
;   botlish_fn_13 / botlish_entry_13 -> scan_while<int, block(e307)>
;   botlish_fn_14 / botlish_entry_14 -> scan_while<int, native(str::is_tcl_alpha)>
;   botlish_fn_15 / botlish_entry_15 -> tld?<int>
;   botlish_fn_16 / botlish_entry_16 -> domain?<int>
;   botlish_fn_17 / botlish_entry_17 -> web::is_unreserved<int>
;   botlish_fn_18 / botlish_entry_18 -> web::uri_escape_text<str>
;   botlish_fn_19 / botlish_entry_19 -> high_nibble<int>
;   botlish_fn_20 / botlish_entry_20 -> hex_pair<int>
;   botlish_fn_21 / botlish_entry_21 -> esc_bytes<List[int], int, str>
;   botlish_fn_22 / botlish_entry_22 -> esc_char<str>
;   botlish_fn_23 / botlish_entry_23 -> esc_from<str, int, str>
;   botlish_fn_24 / botlish_entry_24 -> check<int, int, str, str>


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
			41d: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::uri_escape_text<str>
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
			460: R_X86_64_PLT32	botlish_fn_24-0x4 ; check<int, int, str, str>
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
			4a4: R_X86_64_PLT32	botlish_fn_24-0x4 ; check<int, int, str, str>
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
     5fa:	mov    esi,0x1
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
			aad: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<int, block(e307)>
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
     d53:	mov    QWORD PTR [rsp+0x8],r12
     d58:	xor    r8d,r8d
     d5b:	test   rsi,0x7
     d62:	jne    d72 <botlish_fn_12+0x2b>
     d68:	movzx  rax,BYTE PTR [rsi]
     d6c:	cmp    al,0x2
     d6e:	sete   r8b
     d72:	test   r8b,r8b
     d75:	jne    d95 <botlish_fn_12+0x4e>
     d7b:	mov    rax,QWORD PTR [rdi+0x10]
     d7f:	mov    rcx,QWORD PTR [rax+0xd8]
     d86:	mov    edx,0x1
     d8b:	call   d90 <botlish_fn_12+0x49>
			d8c: R_X86_64_PLT32	rt_type_error-0x4
     d90:	jmp    da9 <botlish_fn_12+0x62>
     d95:	mov    rbx,rsi
     d98:	mov    r12,rdi
     d9b:	call   da0 <botlish_fn_12+0x59>
			d9c: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     da0:	test   rax,rax
     da3:	jne    dbe <botlish_fn_12+0x77>
     da9:	xor    rax,rax
     dac:	mov    rbx,QWORD PTR [rsp]
     db0:	mov    r12,QWORD PTR [rsp+0x8]
     db5:	add    rsp,0x10
     db9:	mov    rsp,rbp
     dbc:	pop    rbp
     dbd:	ret
     dbe:	cmp    rax,0x6
     dc2:	je     df8 <botlish_fn_12+0xb1>
     dc8:	mov    rdi,r12
     dcb:	mov    rax,QWORD PTR [rdi+0x30]
     dcf:	mov    rsi,QWORD PTR [rax]
     dd2:	mov    rdx,rbx
     dd5:	call   dda <botlish_fn_12+0x93>
			dd6: R_X86_64_PLT32	rt_set_contains-0x4
     dda:	cmp    rax,0x6
     dde:	je     dee <botlish_fn_12+0xa7>
     de4:	mov    eax,0x2
     de9:	jmp    dfd <botlish_fn_12+0xb6>
     dee:	mov    eax,0x6
     df3:	jmp    dfd <botlish_fn_12+0xb6>
     df8:	mov    eax,0x6
     dfd:	mov    rbx,QWORD PTR [rsp]
     e01:	mov    r12,QWORD PTR [rsp+0x8]
     e06:	add    rsp,0x10
     e0a:	mov    rsp,rbp
     e0d:	pop    rbp
     e0e:	ret

0000000000000e0f <botlish_entry_12: local_char?<generic>>:
     e0f:	push   rbp
     e10:	mov    rbp,rsp
     e13:	mov    rsi,QWORD PTR [rdx]
     e16:	call   e1b <botlish_entry_12+0xc>
			e17: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<generic>
     e1b:	mov    rsp,rbp
     e1e:	pop    rbp
     e1f:	ret

0000000000000e20 <botlish_fn_13: scan_while<int, block(e307)>>:
     e20:	push   rbp
     e21:	mov    rbp,rsp
     e24:	sub    rsp,0x50
     e28:	mov    QWORD PTR [rsp+0x20],rbx
     e2d:	mov    QWORD PTR [rsp+0x28],r12
     e32:	mov    QWORD PTR [rsp+0x30],r13
     e37:	mov    QWORD PTR [rsp+0x38],r14
     e3c:	mov    QWORD PTR [rsp+0x40],r15
     e41:	mov    QWORD PTR [rsp+0x18],rdi
     e46:	mov    QWORD PTR [rsp],rcx
     e4a:	mov    QWORD PTR [rsp+0x8],r8
     e4f:	mov    r15,r8
     e52:	mov    r12,rcx
     e55:	sar    r12,1
     e58:	mov    r14,rcx
     e5b:	mov    rbx,rsi
     e5e:	cmp    rbx,r12
     e61:	jl     e8c <botlish_fn_13+0x6c>
     e67:	mov    rax,r14
     e6a:	mov    rbx,QWORD PTR [rsp+0x20]
     e6f:	mov    r12,QWORD PTR [rsp+0x28]
     e74:	mov    r13,QWORD PTR [rsp+0x30]
     e79:	mov    r14,QWORD PTR [rsp+0x38]
     e7e:	mov    r15,QWORD PTR [rsp+0x40]
     e83:	add    rsp,0x50
     e87:	mov    rsp,rbp
     e8a:	pop    rbp
     e8b:	ret
     e8c:	mov    r13,rbx
     e8f:	shl    r13,1
     e92:	or     r13,0x1
     e96:	mov    QWORD PTR [rsp+0x10],r13
     e9b:	mov    rcx,r15
     e9e:	mov    rdx,r14
     ea1:	mov    rsi,r13
     ea4:	mov    rdi,QWORD PTR [rsp+0x18]
     ea9:	call   eae <botlish_fn_13+0x8e>
			eaa: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
     eae:	mov    rsi,rax
     eb1:	mov    rdi,QWORD PTR [rsp+0x18]
     eb6:	call   ebb <botlish_fn_13+0x9b>
			eb7: R_X86_64_PLT32	botlish_fn_11-0x4 ; local_char?<str>
     ebb:	test   rax,rax
     ebe:	jne    ee9 <botlish_fn_13+0xc9>
     ec4:	xor    rax,rax
     ec7:	mov    rbx,QWORD PTR [rsp+0x20]
     ecc:	mov    r12,QWORD PTR [rsp+0x28]
     ed1:	mov    r13,QWORD PTR [rsp+0x30]
     ed6:	mov    r14,QWORD PTR [rsp+0x38]
     edb:	mov    r15,QWORD PTR [rsp+0x40]
     ee0:	add    rsp,0x50
     ee4:	mov    rsp,rbp
     ee7:	pop    rbp
     ee8:	ret
     ee9:	cmp    rax,0x6
     eed:	je     f18 <botlish_fn_13+0xf8>
     ef3:	mov    rax,r13
     ef6:	mov    rbx,QWORD PTR [rsp+0x20]
     efb:	mov    r12,QWORD PTR [rsp+0x28]
     f00:	mov    r13,QWORD PTR [rsp+0x30]
     f05:	mov    r14,QWORD PTR [rsp+0x38]
     f0a:	mov    r15,QWORD PTR [rsp+0x40]
     f0f:	add    rsp,0x50
     f13:	mov    rsp,rbp
     f16:	pop    rbp
     f17:	ret
     f18:	add    rbx,0x1
     f1f:	jmp    e5e <botlish_fn_13+0x3e>

0000000000000f24 <botlish_entry_13: scan_while<int, block(e307)>>:
     f24:	push   rbp
     f25:	mov    rbp,rsp
     f28:	mov    rsi,QWORD PTR [rdx]
     f2b:	mov    r9,QWORD PTR [rdx+0x8]
     f2f:	mov    rcx,QWORD PTR [rdx+0x10]
     f33:	mov    r8,QWORD PTR [rdx+0x18]
     f37:	sar    rsi,1
     f3a:	mov    rdx,r9
     f3d:	call   f42 <botlish_entry_13+0x1e>
			f3e: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<int, block(e307)>
     f42:	mov    rsp,rbp
     f45:	pop    rbp
     f46:	ret

0000000000000f47 <botlish_fn_14: scan_while<int, native(str::is_tcl_alpha)>>:
     f47:	push   rbp
     f48:	mov    rbp,rsp
     f4b:	sub    rsp,0x40
     f4f:	mov    QWORD PTR [rsp+0x10],rbx
     f54:	mov    QWORD PTR [rsp+0x18],r12
     f59:	mov    QWORD PTR [rsp+0x20],r13
     f5e:	mov    QWORD PTR [rsp+0x28],r14
     f63:	mov    QWORD PTR [rsp+0x30],r15
     f68:	mov    rbx,r8
     f6b:	mov    r13,rdi
     f6e:	mov    rax,rcx
     f71:	sar    rax,1
     f74:	mov    r12,rcx
     f77:	mov    r14,rax
     f7a:	mov    rax,rsi
     f7d:	mov    rcx,r14
     f80:	cmp    rax,rcx
     f83:	mov    r14,rcx
     f86:	jl     fb6 <botlish_fn_14+0x6f>
     f8c:	mov    edx,0x1
     f91:	mov    rax,r14
     f94:	mov    rbx,QWORD PTR [rsp+0x10]
     f99:	mov    r12,QWORD PTR [rsp+0x18]
     f9e:	mov    r13,QWORD PTR [rsp+0x20]
     fa3:	mov    r14,QWORD PTR [rsp+0x28]
     fa8:	mov    r15,QWORD PTR [rsp+0x30]
     fad:	add    rsp,0x40
     fb1:	mov    rsp,rbp
     fb4:	pop    rbp
     fb5:	ret
     fb6:	mov    rsi,rax
     fb9:	shl    rsi,1
     fbc:	mov    r15,rax
     fbf:	or     rsi,0x1
     fc3:	lea    r8,[rsp]
     fc7:	mov    rcx,rbx
     fca:	mov    rdx,r12
     fcd:	mov    rdi,r13
     fd0:	call   fd5 <botlish_fn_14+0x8e>
			fd1: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     fd5:	mov    rdx,QWORD PTR [rsp]
     fd9:	mov    rcx,QWORD PTR [rsp+0x8]
     fde:	mov    rsi,rax
     fe1:	mov    rdi,r13
     fe4:	call   fe9 <botlish_fn_14+0xa2>
			fe5: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
     fe9:	test   rax,rax
     fec:	jne    101a <botlish_fn_14+0xd3>
     ff2:	xor    rdx,rdx
     ff5:	mov    rax,rdx
     ff8:	mov    rbx,QWORD PTR [rsp+0x10]
     ffd:	mov    r12,QWORD PTR [rsp+0x18]
    1002:	mov    r13,QWORD PTR [rsp+0x20]
    1007:	mov    r14,QWORD PTR [rsp+0x28]
    100c:	mov    r15,QWORD PTR [rsp+0x30]
    1011:	add    rsp,0x40
    1015:	mov    rsp,rbp
    1018:	pop    rbp
    1019:	ret
    101a:	cmp    rax,0x6
    101e:	je     104e <botlish_fn_14+0x107>
    1024:	mov    edx,0x1
    1029:	mov    rax,r15
    102c:	mov    rbx,QWORD PTR [rsp+0x10]
    1031:	mov    r12,QWORD PTR [rsp+0x18]
    1036:	mov    r13,QWORD PTR [rsp+0x20]
    103b:	mov    r14,QWORD PTR [rsp+0x28]
    1040:	mov    r15,QWORD PTR [rsp+0x30]
    1045:	add    rsp,0x40
    1049:	mov    rsp,rbp
    104c:	pop    rbp
    104d:	ret
    104e:	mov    rax,r15
    1051:	add    rax,0x1
    1058:	mov    rcx,r14
    105b:	jmp    f80 <botlish_fn_14+0x39>

0000000000001060 <botlish_entry_14: scan_while<int, native(str::is_tcl_alpha)>>:
    1060:	push   rbp
    1061:	mov    rbp,rsp
    1064:	mov    rsi,QWORD PTR [rdx]
    1067:	mov    rax,QWORD PTR [rdx+0x8]
    106b:	mov    rcx,QWORD PTR [rdx+0x10]
    106f:	mov    r8,QWORD PTR [rdx+0x18]
    1073:	sar    rsi,1
    1076:	mov    rdx,rax
    1079:	call   107e <botlish_entry_14+0x1e>
			107a: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, native(str::is_tcl_alpha)>
    107e:	shl    rax,1
    1081:	or     rax,0x1
    1085:	mov    rcx,rax
    1088:	xor    rax,rax
    108b:	test   rdx,rdx
    108e:	cmovne rax,rcx
    1092:	mov    rsp,rbp
    1095:	pop    rbp
    1096:	ret
	...

0000000000001098 <botlish_fn_15: tld?<int>>:
    1098:	push   rbp
    1099:	mov    rbp,rsp
    109c:	sub    rsp,0x10
    10a0:	mov    QWORD PTR [rsp],rbx
    10a4:	mov    QWORD PTR [rsp+0x8],r12
    10a9:	mov    r8,rdx
    10ac:	mov    rax,QWORD PTR [rdi+0x10]
    10b0:	mov    rdx,QWORD PTR [rax+0xe0]
    10b7:	mov    r12,r8
    10ba:	mov    r8,rcx
    10bd:	mov    rbx,rsi
    10c0:	mov    rcx,r12
    10c3:	call   10c8 <botlish_fn_15+0x30>
			10c4: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, native(str::is_tcl_alpha)>
    10c8:	test   rdx,rdx
    10cb:	jne    10e6 <botlish_fn_15+0x4e>
    10d1:	xor    rax,rax
    10d4:	mov    rbx,QWORD PTR [rsp]
    10d8:	mov    r12,QWORD PTR [rsp+0x8]
    10dd:	add    rsp,0x10
    10e1:	mov    rsp,rbp
    10e4:	pop    rbp
    10e5:	ret
    10e6:	sar    r12,1
    10e9:	cmp    rax,r12
    10ec:	je     10fc <botlish_fn_15+0x64>
    10f2:	mov    eax,0x2
    10f7:	jmp    1113 <botlish_fn_15+0x7b>
    10fc:	sub    rax,rbx
    10ff:	mov    rcx,rax
    1102:	mov    eax,0x2
    1107:	cmp    rcx,0x2
    110b:	cmovge rax,QWORD PTR [rip+0x15]        # 1128 <botlish_fn_15+0x90>
    1113:	mov    rbx,QWORD PTR [rsp]
    1117:	mov    r12,QWORD PTR [rsp+0x8]
    111c:	add    rsp,0x10
    1120:	mov    rsp,rbp
    1123:	pop    rbp
    1124:	ret
    1125:	add    BYTE PTR [rax],al
    1127:	add    BYTE PTR [rsi],al
    1129:	add    BYTE PTR [rax],al
    112b:	add    BYTE PTR [rax],al
    112d:	add    BYTE PTR [rax],al
	...

0000000000001130 <botlish_entry_15: tld?<int>>:
    1130:	push   rbp
    1131:	mov    rbp,rsp
    1134:	mov    rsi,QWORD PTR [rdx]
    1137:	mov    r8,QWORD PTR [rdx+0x8]
    113b:	mov    rcx,QWORD PTR [rdx+0x10]
    113f:	sar    rsi,1
    1142:	mov    rdx,r8
    1145:	call   114a <botlish_entry_15+0x1a>
			1146: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld?<int>
    114a:	mov    rsp,rbp
    114d:	pop    rbp
    114e:	ret

000000000000114f <botlish_fn_16: domain?<int>>:
    114f:	push   rbp
    1150:	mov    rbp,rsp
    1153:	sub    rsp,0x80
    115a:	mov    QWORD PTR [rsp+0x50],rbx
    115f:	mov    QWORD PTR [rsp+0x58],r12
    1164:	mov    QWORD PTR [rsp+0x60],r13
    1169:	mov    QWORD PTR [rsp+0x68],r14
    116e:	mov    QWORD PTR [rsp+0x70],r15
    1173:	mov    rbx,rsi
    1176:	mov    r15,rcx
    1179:	mov    r14,rdx
    117c:	sar    r14,1
    117f:	mov    QWORD PTR [rsp+0x30],rdx
    1184:	mov    r12,rbx
    1187:	cmp    r12,r14
    118a:	jl     11ba <botlish_fn_16+0x6b>
    1190:	mov    eax,0x2
    1195:	mov    rbx,QWORD PTR [rsp+0x50]
    119a:	mov    r12,QWORD PTR [rsp+0x58]
    119f:	mov    r13,QWORD PTR [rsp+0x60]
    11a4:	mov    r14,QWORD PTR [rsp+0x68]
    11a9:	mov    r15,QWORD PTR [rsp+0x70]
    11ae:	add    rsp,0x80
    11b5:	mov    rsp,rbp
    11b8:	pop    rbp
    11b9:	ret
    11ba:	mov    rsi,r12
    11bd:	shl    rsi,1
    11c0:	or     rsi,0x1
    11c4:	mov    QWORD PTR [rsp+0x48],rsi
    11c9:	lea    r8,[rsp]
    11cd:	mov    r13,rdi
    11d0:	mov    rcx,r15
    11d3:	mov    rdx,QWORD PTR [rsp+0x30]
    11d8:	call   11dd <botlish_fn_16+0x8e>
			11d9: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    11dd:	mov    rdx,QWORD PTR [rsp]
    11e1:	mov    rcx,QWORD PTR [rsp+0x8]
    11e6:	mov    rsi,QWORD PTR [r13+0x10]
    11ea:	mov    r8,QWORD PTR [rsi]
    11ed:	mov    rsi,rax
    11f0:	mov    rdi,r13
    11f3:	call   11f8 <botlish_fn_16+0xa9>
			11f4: R_X86_64_PLT32	rt_str_region_eq-0x4
    11f8:	cmp    rax,0x6
    11fc:	je     12e4 <botlish_fn_16+0x195>
    1202:	lea    r8,[rsp+0x20]
    1207:	mov    rsi,QWORD PTR [rsp+0x48]
    120c:	mov    rcx,r15
    120f:	mov    rdx,QWORD PTR [rsp+0x30]
    1214:	mov    rdi,r13
    1217:	call   121c <botlish_fn_16+0xcd>
			1218: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    121c:	mov    QWORD PTR [rsp+0x48],rax
    1221:	mov    rdx,QWORD PTR [rsp+0x20]
    1226:	mov    QWORD PTR [rsp+0x40],rdx
    122b:	mov    rcx,QWORD PTR [rsp+0x28]
    1230:	mov    QWORD PTR [rsp+0x38],rcx
    1235:	mov    rsi,QWORD PTR [rsp+0x48]
    123a:	mov    rdi,r13
    123d:	call   1242 <botlish_fn_16+0xf3>
			123e: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1242:	test   rax,rax
    1245:	je     1354 <botlish_fn_16+0x205>
    124b:	cmp    rax,0x6
    124f:	je     1292 <botlish_fn_16+0x143>
    1255:	mov    rcx,QWORD PTR [r13+0x10]
    1259:	mov    r8,QWORD PTR [rcx+0x20]
    125d:	mov    rcx,QWORD PTR [rsp+0x38]
    1262:	mov    rdx,QWORD PTR [rsp+0x40]
    1267:	mov    rsi,QWORD PTR [rsp+0x48]
    126c:	mov    rdi,r13
    126f:	call   1274 <botlish_fn_16+0x125>
			1270: R_X86_64_PLT32	rt_str_region_eq-0x4
    1274:	cmp    rax,0x6
    1278:	je     1288 <botlish_fn_16+0x139>
    127e:	mov    ecx,0x2
    1283:	jmp    1297 <botlish_fn_16+0x148>
    1288:	mov    ecx,0x6
    128d:	jmp    1297 <botlish_fn_16+0x148>
    1292:	mov    ecx,0x6
    1297:	cmp    rcx,0x6
    129b:	je     12ab <botlish_fn_16+0x15c>
    12a1:	mov    eax,0x6
    12a6:	jmp    12b0 <botlish_fn_16+0x161>
    12ab:	mov    eax,0x2
    12b0:	cmp    rax,0x6
    12b4:	jne    1386 <botlish_fn_16+0x237>
    12ba:	mov    eax,0x2
    12bf:	mov    rbx,QWORD PTR [rsp+0x50]
    12c4:	mov    r12,QWORD PTR [rsp+0x58]
    12c9:	mov    r13,QWORD PTR [rsp+0x60]
    12ce:	mov    r14,QWORD PTR [rsp+0x68]
    12d3:	mov    r15,QWORD PTR [rsp+0x70]
    12d8:	add    rsp,0x80
    12df:	mov    rsp,rbp
    12e2:	pop    rbp
    12e3:	ret
    12e4:	cmp    r12,rbx
    12e7:	je     13e9 <botlish_fn_16+0x29a>
    12ed:	mov    rsi,r12
    12f0:	sub    rsi,0x1
    12f4:	shl    rsi,1
    12f7:	or     rsi,0x1
    12fb:	lea    r8,[rsp+0x10]
    1300:	mov    rcx,r15
    1303:	mov    rdx,QWORD PTR [rsp+0x30]
    1308:	mov    rdi,r13
    130b:	call   1310 <botlish_fn_16+0x1c1>
			130c: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    1310:	mov    rdx,QWORD PTR [rsp+0x10]
    1315:	mov    rcx,QWORD PTR [rsp+0x18]
    131a:	mov    rsi,QWORD PTR [r13+0x10]
    131e:	mov    r8,QWORD PTR [rsi]
    1321:	mov    rsi,rax
    1324:	mov    rdi,r13
    1327:	call   132c <botlish_fn_16+0x1dd>
			1328: R_X86_64_PLT32	rt_str_region_eq-0x4
    132c:	cmp    rax,0x6
    1330:	je     13bf <botlish_fn_16+0x270>
    1336:	lea    rsi,[r12+0x1]
    133b:	mov    rcx,r15
    133e:	mov    rdx,QWORD PTR [rsp+0x30]
    1343:	mov    rdi,r13
    1346:	call   134b <botlish_fn_16+0x1fc>
			1347: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld?<int>
    134b:	test   rax,rax
    134e:	jne    137c <botlish_fn_16+0x22d>
    1354:	xor    rax,rax
    1357:	mov    rbx,QWORD PTR [rsp+0x50]
    135c:	mov    r12,QWORD PTR [rsp+0x58]
    1361:	mov    r13,QWORD PTR [rsp+0x60]
    1366:	mov    r14,QWORD PTR [rsp+0x68]
    136b:	mov    r15,QWORD PTR [rsp+0x70]
    1370:	add    rsp,0x80
    1377:	mov    rsp,rbp
    137a:	pop    rbp
    137b:	ret
    137c:	cmp    rax,0x6
    1380:	je     1395 <botlish_fn_16+0x246>
    1386:	add    r12,0x1
    138d:	mov    rdi,r13
    1390:	jmp    1187 <botlish_fn_16+0x38>
    1395:	mov    eax,0x6
    139a:	mov    rbx,QWORD PTR [rsp+0x50]
    139f:	mov    r12,QWORD PTR [rsp+0x58]
    13a4:	mov    r13,QWORD PTR [rsp+0x60]
    13a9:	mov    r14,QWORD PTR [rsp+0x68]
    13ae:	mov    r15,QWORD PTR [rsp+0x70]
    13b3:	add    rsp,0x80
    13ba:	mov    rsp,rbp
    13bd:	pop    rbp
    13be:	ret
    13bf:	mov    eax,0x2
    13c4:	mov    rbx,QWORD PTR [rsp+0x50]
    13c9:	mov    r12,QWORD PTR [rsp+0x58]
    13ce:	mov    r13,QWORD PTR [rsp+0x60]
    13d3:	mov    r14,QWORD PTR [rsp+0x68]
    13d8:	mov    r15,QWORD PTR [rsp+0x70]
    13dd:	add    rsp,0x80
    13e4:	mov    rsp,rbp
    13e7:	pop    rbp
    13e8:	ret
    13e9:	mov    eax,0x2
    13ee:	mov    rbx,QWORD PTR [rsp+0x50]
    13f3:	mov    r12,QWORD PTR [rsp+0x58]
    13f8:	mov    r13,QWORD PTR [rsp+0x60]
    13fd:	mov    r14,QWORD PTR [rsp+0x68]
    1402:	mov    r15,QWORD PTR [rsp+0x70]
    1407:	add    rsp,0x80
    140e:	mov    rsp,rbp
    1411:	pop    rbp
    1412:	ret

0000000000001413 <botlish_entry_16: domain?<int>>:
    1413:	push   rbp
    1414:	mov    rbp,rsp
    1417:	mov    rsi,QWORD PTR [rdx]
    141a:	mov    r8,QWORD PTR [rdx+0x8]
    141e:	mov    rcx,QWORD PTR [rdx+0x10]
    1422:	sar    rsi,1
    1425:	mov    rdx,r8
    1428:	call   142d <botlish_entry_16+0x1a>
			1429: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain?<int>
    142d:	mov    rsp,rbp
    1430:	pop    rbp
    1431:	ret

0000000000001432 <botlish_fn_17: web::is_unreserved<int>>:
    1432:	push   rbp
    1433:	mov    rbp,rsp
    1436:	sub    rsp,0x10
    143a:	mov    QWORD PTR [rsp],rbx
    143e:	mov    QWORD PTR [rsp+0x8],r14
    1443:	mov    r14,rsi
    1446:	mov    rsi,r14
    1449:	sar    rsi,1
    144c:	mov    rbx,rdi
    144f:	call   1454 <botlish_fn_17+0x22>
			1450: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphanumeric<int>
    1454:	cmp    rax,0x6
    1458:	je     148f <botlish_fn_17+0x5d>
    145e:	mov    rax,QWORD PTR [rbx+0x30]
    1462:	mov    rsi,QWORD PTR [rax+0x10]
    1466:	mov    rdx,r14
    1469:	mov    rdi,rbx
    146c:	call   1471 <botlish_fn_17+0x3f>
			146d: R_X86_64_PLT32	rt_set_contains-0x4
    1471:	cmp    rax,0x6
    1475:	je     1485 <botlish_fn_17+0x53>
    147b:	mov    eax,0x2
    1480:	jmp    1494 <botlish_fn_17+0x62>
    1485:	mov    eax,0x6
    148a:	jmp    1494 <botlish_fn_17+0x62>
    148f:	mov    eax,0x6
    1494:	mov    rbx,QWORD PTR [rsp]
    1498:	mov    r14,QWORD PTR [rsp+0x8]
    149d:	add    rsp,0x10
    14a1:	mov    rsp,rbp
    14a4:	pop    rbp
    14a5:	ret

00000000000014a6 <botlish_entry_17: web::is_unreserved<int>>:
    14a6:	push   rbp
    14a7:	mov    rbp,rsp
    14aa:	mov    rsi,QWORD PTR [rdx]
    14ad:	call   14b2 <botlish_entry_17+0xc>
			14ae: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<int>
    14b2:	mov    rsp,rbp
    14b5:	pop    rbp
    14b6:	ret

00000000000014b7 <botlish_fn_18: web::uri_escape_text<str>>:
    14b7:	push   rbp
    14b8:	mov    rbp,rsp
    14bb:	sub    rsp,0x10
    14bf:	mov    edx,0x1
    14c4:	mov    QWORD PTR [rsp],0x1
    14cc:	mov    r10,QWORD PTR [rdi+0x10]
    14d0:	mov    rcx,QWORD PTR [r10+0xd0]
    14d7:	mov    QWORD PTR [rsp+0x8],rcx
    14dc:	call   14e1 <botlish_fn_18+0x2a>
			14dd: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_from<str, int, str>
    14e1:	test   rax,rax
    14e4:	jne    14f6 <botlish_fn_18+0x3f>
    14ea:	xor    rax,rax
    14ed:	add    rsp,0x10
    14f1:	mov    rsp,rbp
    14f4:	pop    rbp
    14f5:	ret
    14f6:	add    rsp,0x10
    14fa:	mov    rsp,rbp
    14fd:	pop    rbp
    14fe:	ret

00000000000014ff <botlish_entry_18: web::uri_escape_text<str>>:
    14ff:	push   rbp
    1500:	mov    rbp,rsp
    1503:	sub    rsp,0x10
    1507:	mov    QWORD PTR [rsp],r12
    150b:	mov    r12,rdi
    150e:	mov    rsi,QWORD PTR [rdx]
    1511:	mov    r8,QWORD PTR [rip+0x0]        # 1518 <botlish_entry_18+0x19>
			1514: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    1518:	call   r8
    151b:	mov    rsi,rax
    151e:	mov    rdi,r12
    1521:	call   1526 <botlish_entry_18+0x27>
			1522: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::uri_escape_text<str>
    1526:	mov    r12,QWORD PTR [rsp]
    152a:	add    rsp,0x10
    152e:	mov    rsp,rbp
    1531:	pop    rbp
    1532:	ret

0000000000001533 <botlish_fn_19: high_nibble<int>>:
    1533:	push   rbp
    1534:	mov    rbp,rsp
    1537:	sub    rsp,0x10
    153b:	mov    QWORD PTR [rsp],rsi
    153f:	mov    QWORD PTR [rsp+0x8],0x1e1
    1548:	test   rsi,0x1
    154f:	jne    1564 <botlish_fn_19+0x31>
    1555:	mov    edx,0x1e1
    155a:	call   155f <botlish_fn_19+0x2c>
			155b: R_X86_64_PLT32	rt_int_and-0x4
    155f:	jmp    156e <botlish_fn_19+0x3b>
    1564:	and    rsi,0x1e1
    156b:	mov    rax,rsi
    156e:	sar    rax,0x5
    1572:	shl    rax,1
    1575:	or     rax,0x1
    1579:	add    rsp,0x10
    157d:	mov    rsp,rbp
    1580:	pop    rbp
    1581:	ret

0000000000001582 <botlish_entry_19: high_nibble<int>>:
    1582:	push   rbp
    1583:	mov    rbp,rsp
    1586:	mov    rsi,QWORD PTR [rdx]
    1589:	call   158e <botlish_entry_19+0xc>
			158a: R_X86_64_PLT32	botlish_fn_19-0x4 ; high_nibble<int>
    158e:	mov    rsp,rbp
    1591:	pop    rbp
    1592:	ret

0000000000001593 <botlish_fn_20: hex_pair<int>>:
    1593:	push   rbp
    1594:	mov    rbp,rsp
    1597:	sub    rsp,0x50
    159b:	mov    QWORD PTR [rsp+0x30],rbx
    15a0:	mov    QWORD PTR [rsp+0x38],r12
    15a5:	mov    QWORD PTR [rsp+0x40],r13
    15aa:	mov    QWORD PTR [rsp+0x48],r14
    15af:	mov    QWORD PTR [rsp],rsi
    15b3:	mov    r14,rsi
    15b6:	mov    rax,QWORD PTR [rdi+0x30]
    15ba:	mov    r13,rdi
    15bd:	mov    rbx,QWORD PTR [rax+0x8]
    15c1:	mov    QWORD PTR [rsp+0x8],rbx
    15c6:	mov    rsi,r14
    15c9:	call   15ce <botlish_fn_20+0x3b>
			15ca: R_X86_64_PLT32	botlish_fn_19-0x4 ; high_nibble<int>
    15ce:	mov    rcx,QWORD PTR [rbx+0x10]
    15d2:	sar    rax,1
    15d5:	mov    r12,QWORD PTR [rcx+rax*8]
    15d9:	mov    QWORD PTR [rsp],r12
    15dd:	mov    rdi,r13
    15e0:	mov    rax,QWORD PTR [rdi+0x30]
    15e4:	mov    rbx,QWORD PTR [rax+0x8]
    15e8:	mov    edx,0x21
    15ed:	mov    rsi,r14
    15f0:	call   15f5 <botlish_fn_20+0x62>
			15f1: R_X86_64_PLT32	rt_int_mod-0x4
    15f5:	test   rax,rax
    15f8:	je     164a <botlish_fn_20+0xb7>
    15fe:	mov    rcx,QWORD PTR [rbx+0x10]
    1602:	sar    rax,1
    1605:	mov    rdx,QWORD PTR [rcx+rax*8]
    1609:	mov    QWORD PTR [rsp+0x8],rdx
    160e:	lea    rcx,[rsp+0x10]
    1613:	mov    QWORD PTR [rsp+0x10],0x0
    161c:	mov    QWORD PTR [rsp+0x18],r12
    1621:	mov    QWORD PTR [rsp+0x20],0x0
    162a:	mov    QWORD PTR [rsp+0x28],rdx
    162f:	mov    esi,0x2
    1634:	mov    edx,0x4
    1639:	mov    rdi,r13
    163c:	call   1641 <botlish_fn_20+0xae>
			163d: R_X86_64_PLT32	rt_construct-0x4
    1641:	test   rax,rax
    1644:	jne    166a <botlish_fn_20+0xd7>
    164a:	xor    rax,rax
    164d:	mov    rbx,QWORD PTR [rsp+0x30]
    1652:	mov    r12,QWORD PTR [rsp+0x38]
    1657:	mov    r13,QWORD PTR [rsp+0x40]
    165c:	mov    r14,QWORD PTR [rsp+0x48]
    1661:	add    rsp,0x50
    1665:	mov    rsp,rbp
    1668:	pop    rbp
    1669:	ret
    166a:	mov    rbx,QWORD PTR [rsp+0x30]
    166f:	mov    r12,QWORD PTR [rsp+0x38]
    1674:	mov    r13,QWORD PTR [rsp+0x40]
    1679:	mov    r14,QWORD PTR [rsp+0x48]
    167e:	add    rsp,0x50
    1682:	mov    rsp,rbp
    1685:	pop    rbp
    1686:	ret

0000000000001687 <botlish_entry_20: hex_pair<int>>:
    1687:	push   rbp
    1688:	mov    rbp,rsp
    168b:	sub    rsp,0x10
    168f:	mov    QWORD PTR [rsp],r12
    1693:	mov    r12,rdi
    1696:	mov    rsi,QWORD PTR [rdx]
    1699:	call   169e <botlish_entry_20+0x17>
			169a: R_X86_64_PLT32	botlish_fn_20-0x4 ; hex_pair<int>
    169e:	mov    r8,QWORD PTR [rip+0x0]        # 16a5 <botlish_entry_20+0x1e>
			16a1: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    16a5:	mov    rsi,rax
    16a8:	mov    rdi,r12
    16ab:	call   r8
    16ae:	mov    r12,QWORD PTR [rsp]
    16b2:	add    rsp,0x10
    16b6:	mov    rsp,rbp
    16b9:	pop    rbp
    16ba:	ret
    16bb:	add    BYTE PTR [rax],al
    16bd:	add    BYTE PTR [rax],al
	...

00000000000016c0 <botlish_fn_21: esc_bytes<List[int], int, str>>:
    16c0:	push   rbp
    16c1:	mov    rbp,rsp
    16c4:	sub    rsp,0xa0
    16cb:	mov    QWORD PTR [rsp+0x70],rbx
    16d0:	mov    QWORD PTR [rsp+0x78],r12
    16d5:	mov    QWORD PTR [rsp+0x80],r13
    16dd:	mov    QWORD PTR [rsp+0x88],r14
    16e5:	mov    QWORD PTR [rsp+0x90],r15
    16ed:	mov    QWORD PTR [rsp+0x20],0x0
    16f6:	mov    QWORD PTR [rsp],rsi
    16fa:	mov    QWORD PTR [rsp+0x8],rdx
    16ff:	mov    r14,rdx
    1702:	mov    QWORD PTR [rsp+0x10],rcx
    1707:	lea    r13,[rsp+0x28]
    170c:	mov    rbx,rdi
    170f:	mov    r12,rsi
    1712:	mov    QWORD PTR [rsp+0x58],rcx
    1717:	mov    rsi,r12
    171a:	mov    rdi,rbx
    171d:	call   1722 <botlish_fn_21+0x62>
			171e: R_X86_64_PLT32	rt_list_len-0x4
    1722:	mov    rcx,r14
    1725:	and    rcx,rax
    1728:	mov    rdx,rax
    172b:	test   rcx,0x1
    1732:	jne    1758 <botlish_fn_21+0x98>
    1738:	mov    rsi,r14
    173b:	mov    rdi,rbx
    173e:	call   1743 <botlish_fn_21+0x83>
			173f: R_X86_64_PLT32	rt_int_cmp-0x4
    1743:	mov    ecx,0x2
    1748:	test   rax,rax
    174b:	cmovge rcx,QWORD PTR [rip+0x185]        # 18d8 <botlish_fn_21+0x218>
    1753:	jmp    1768 <botlish_fn_21+0xa8>
    1758:	mov    ecx,0x2
    175d:	cmp    r14,rdx
    1760:	cmovge rcx,QWORD PTR [rip+0x170]        # 18d8 <botlish_fn_21+0x218>
    1768:	cmp    rcx,0x6
    176c:	je     177c <botlish_fn_21+0xbc>
    1772:	mov    eax,0x2
    1777:	jmp    1781 <botlish_fn_21+0xc1>
    177c:	mov    eax,0x6
    1781:	cmp    rax,0x6
    1785:	je     18a5 <botlish_fn_21+0x1e5>
    178b:	mov    QWORD PTR [rsp+0x18],0x3
    1794:	test   r14,0x1
    179b:	je     17b3 <botlish_fn_21+0xf3>
    17a1:	mov    rax,r14
    17a4:	add    rax,0x2
    17a8:	seto   cl
    17ab:	test   cl,cl
    17ad:	je     17c3 <botlish_fn_21+0x103>
    17b3:	mov    edx,0x3
    17b8:	mov    rsi,r14
    17bb:	mov    rdi,rbx
    17be:	call   17c3 <botlish_fn_21+0x103>
			17bf: R_X86_64_PLT32	rt_int_add-0x4
    17c3:	mov    QWORD PTR [rsp+0x8],rax
    17c8:	mov    QWORD PTR [rsp+0x60],rax
    17cd:	mov    rax,QWORD PTR [rbx+0x10]
    17d1:	mov    r15,QWORD PTR [rax+0x10]
    17d5:	mov    QWORD PTR [rsp+0x18],r15
    17da:	mov    rax,QWORD PTR [r12+0x10]
    17df:	sar    r14,1
    17e2:	mov    rsi,QWORD PTR [rax+r14*8]
    17e6:	mov    QWORD PTR [rsp+0x20],rsi
    17eb:	mov    rdi,rbx
    17ee:	call   17f3 <botlish_fn_21+0x133>
			17ef: R_X86_64_PLT32	botlish_fn_20-0x4 ; hex_pair<int>
    17f3:	test   rax,rax
    17f6:	je     1854 <botlish_fn_21+0x194>
    17fc:	mov    QWORD PTR [rsp+0x20],rax
    1801:	mov    rcx,rax
    1804:	mov    QWORD PTR [rsp+0x28],0x0
    180d:	mov    rax,QWORD PTR [rsp+0x58]
    1812:	mov    QWORD PTR [rsp+0x30],rax
    1817:	mov    QWORD PTR [rsp+0x38],0x0
    1820:	mov    QWORD PTR [rsp+0x40],r15
    1825:	mov    QWORD PTR [rsp+0x48],0x0
    182e:	mov    rax,rcx
    1831:	mov    QWORD PTR [rsp+0x50],rax
    1836:	mov    esi,0x2
    183b:	mov    edx,0x6
    1840:	mov    rcx,r13
    1843:	mov    rdi,rbx
    1846:	call   184b <botlish_fn_21+0x18b>
			1847: R_X86_64_PLT32	rt_construct-0x4
    184b:	test   rax,rax
    184e:	jne    1885 <botlish_fn_21+0x1c5>
    1854:	xor    rax,rax
    1857:	mov    rbx,QWORD PTR [rsp+0x70]
    185c:	mov    r12,QWORD PTR [rsp+0x78]
    1861:	mov    r13,QWORD PTR [rsp+0x80]
    1869:	mov    r14,QWORD PTR [rsp+0x88]
    1871:	mov    r15,QWORD PTR [rsp+0x90]
    1879:	add    rsp,0xa0
    1880:	mov    rsp,rbp
    1883:	pop    rbp
    1884:	ret
    1885:	mov    QWORD PTR [rsp],r12
    1889:	mov    rcx,QWORD PTR [rsp+0x60]
    188e:	mov    QWORD PTR [rsp+0x8],rcx
    1893:	mov    QWORD PTR [rsp+0x10],rax
    1898:	mov    r14,rcx
    189b:	mov    QWORD PTR [rsp+0x58],rax
    18a0:	jmp    1717 <botlish_fn_21+0x57>
    18a5:	mov    rax,QWORD PTR [rsp+0x58]
    18aa:	mov    rbx,QWORD PTR [rsp+0x70]
    18af:	mov    r12,QWORD PTR [rsp+0x78]
    18b4:	mov    r13,QWORD PTR [rsp+0x80]
    18bc:	mov    r14,QWORD PTR [rsp+0x88]
    18c4:	mov    r15,QWORD PTR [rsp+0x90]
    18cc:	add    rsp,0xa0
    18d3:	mov    rsp,rbp
    18d6:	pop    rbp
    18d7:	ret
    18d8:	(bad)
    18d9:	add    BYTE PTR [rax],al
    18db:	add    BYTE PTR [rax],al
    18dd:	add    BYTE PTR [rax],al
	...

00000000000018e0 <botlish_entry_21: esc_bytes<List[int], int, str>>:
    18e0:	push   rbp
    18e1:	mov    rbp,rsp
    18e4:	sub    rsp,0x10
    18e8:	mov    QWORD PTR [rsp],r12
    18ec:	mov    r12,rdi
    18ef:	mov    rsi,QWORD PTR [rdx]
    18f2:	mov    r8,QWORD PTR [rdx+0x8]
    18f6:	mov    rcx,QWORD PTR [rdx+0x10]
    18fa:	mov    rdx,r8
    18fd:	call   1902 <botlish_entry_21+0x22>
			18fe: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_bytes<List[int], int, str>
    1902:	mov    r8,QWORD PTR [rip+0x0]        # 1909 <botlish_entry_21+0x29>
			1905: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1909:	mov    rsi,rax
    190c:	mov    rdi,r12
    190f:	call   r8
    1912:	mov    r12,QWORD PTR [rsp]
    1916:	add    rsp,0x10
    191a:	mov    rsp,rbp
    191d:	pop    rbp
    191e:	ret

000000000000191f <botlish_fn_22: esc_char<str>>:
    191f:	push   rbp
    1920:	mov    rbp,rsp
    1923:	sub    rsp,0x40
    1927:	mov    QWORD PTR [rsp+0x20],rbx
    192c:	mov    QWORD PTR [rsp+0x28],r12
    1931:	mov    QWORD PTR [rsp+0x30],r13
    1936:	mov    rbx,rdi
    1939:	mov    QWORD PTR [rsp+0x8],0x0
    1942:	mov    QWORD PTR [rsp+0x10],0x0
    194b:	mov    QWORD PTR [rsp],rsi
    194f:	mov    r13,rsi
    1952:	mov    rsi,r13
    1955:	mov    rdi,rbx
    1958:	call   195d <botlish_fn_22+0x3e>
			1959: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    195d:	mov    rcx,rax
    1960:	mov    r12,rax
    1963:	test   rax,rcx
    1966:	je     1a10 <botlish_fn_22+0xf1>
    196c:	mov    rax,r12
    196f:	mov    QWORD PTR [rsp],rax
    1973:	mov    rsi,r12
    1976:	mov    rdi,rbx
    1979:	call   197e <botlish_fn_22+0x5f>
			197a: R_X86_64_PLT32	rt_list_len-0x4
    197e:	sar    rax,1
    1981:	cmp    rax,0x1
    1985:	je     19c2 <botlish_fn_22+0xa3>
    198b:	mov    edx,0x1
    1990:	mov    QWORD PTR [rsp+0x8],0x1
    1999:	mov    rdi,rbx
    199c:	mov    rax,QWORD PTR [rdi+0x10]
    19a0:	mov    rcx,QWORD PTR [rax+0xd0]
    19a7:	mov    QWORD PTR [rsp+0x10],rcx
    19ac:	mov    rsi,r12
    19af:	call   19b4 <botlish_fn_22+0x95>
			19b0: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_bytes<List[int], int, str>
    19b4:	test   rax,rax
    19b7:	je     1a10 <botlish_fn_22+0xf1>
    19bd:	jmp    1a31 <botlish_fn_22+0x112>
    19c2:	mov    rsi,r12
    19c5:	mov    rax,QWORD PTR [rsi+0x10]
    19c9:	mov    rsi,QWORD PTR [rax]
    19cc:	mov    rdi,rbx
    19cf:	call   19d4 <botlish_fn_22+0xb5>
			19d0: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<int>
    19d4:	cmp    rax,0x6
    19d8:	je     1a2e <botlish_fn_22+0x10f>
    19de:	mov    edx,0x1
    19e3:	mov    QWORD PTR [rsp+0x8],0x1
    19ec:	mov    rdi,rbx
    19ef:	mov    rax,QWORD PTR [rdi+0x10]
    19f3:	mov    rcx,QWORD PTR [rax+0xd0]
    19fa:	mov    QWORD PTR [rsp+0x10],rcx
    19ff:	mov    rsi,r12
    1a02:	call   1a07 <botlish_fn_22+0xe8>
			1a03: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_bytes<List[int], int, str>
    1a07:	test   rax,rax
    1a0a:	jne    1a2b <botlish_fn_22+0x10c>
    1a10:	xor    rax,rax
    1a13:	mov    rbx,QWORD PTR [rsp+0x20]
    1a18:	mov    r12,QWORD PTR [rsp+0x28]
    1a1d:	mov    r13,QWORD PTR [rsp+0x30]
    1a22:	add    rsp,0x40
    1a26:	mov    rsp,rbp
    1a29:	pop    rbp
    1a2a:	ret
    1a2b:	mov    r13,rax
    1a2e:	mov    rax,r13
    1a31:	mov    rbx,QWORD PTR [rsp+0x20]
    1a36:	mov    r12,QWORD PTR [rsp+0x28]
    1a3b:	mov    r13,QWORD PTR [rsp+0x30]
    1a40:	add    rsp,0x40
    1a44:	mov    rsp,rbp
    1a47:	pop    rbp
    1a48:	ret

0000000000001a49 <botlish_entry_22: esc_char<str>>:
    1a49:	push   rbp
    1a4a:	mov    rbp,rsp
    1a4d:	sub    rsp,0x10
    1a51:	mov    QWORD PTR [rsp],r12
    1a55:	mov    r12,rdi
    1a58:	mov    rsi,QWORD PTR [rdx]
    1a5b:	call   1a60 <botlish_entry_22+0x17>
			1a5c: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_char<str>
    1a60:	mov    r8,QWORD PTR [rip+0x0]        # 1a67 <botlish_entry_22+0x1e>
			1a63: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1a67:	mov    rsi,rax
    1a6a:	mov    rdi,r12
    1a6d:	call   r8
    1a70:	mov    r12,QWORD PTR [rsp]
    1a74:	add    rsp,0x10
    1a78:	mov    rsp,rbp
    1a7b:	pop    rbp
    1a7c:	ret
    1a7d:	add    BYTE PTR [rax],al
	...

0000000000001a80 <botlish_fn_23: esc_from<str, int, str>>:
    1a80:	push   rbp
    1a81:	mov    rbp,rsp
    1a84:	sub    rsp,0xa0
    1a8b:	mov    QWORD PTR [rsp+0x70],rbx
    1a90:	mov    QWORD PTR [rsp+0x78],r12
    1a95:	mov    QWORD PTR [rsp+0x80],r13
    1a9d:	mov    QWORD PTR [rsp+0x88],r14
    1aa5:	mov    QWORD PTR [rsp+0x90],r15
    1aad:	mov    r13,rdi
    1ab0:	mov    QWORD PTR [rsp+0x10],0x0
    1ab9:	mov    QWORD PTR [rsp+0x18],0x0
    1ac2:	mov    QWORD PTR [rsp+0x20],0x0
    1acb:	mov    QWORD PTR [rsp],rdx
    1acf:	mov    QWORD PTR [rsp+0x8],rcx
    1ad4:	mov    QWORD PTR [rsp+0x58],rcx
    1ad9:	mov    r12d,0x47
    1adf:	mov    rcx,0xffffffffffffffff
    1ae6:	bsr    rax,rsi
    1aea:	mov    r15,rsi
    1aed:	cmove  rax,rcx
    1af1:	mov    ecx,0x3f
    1af6:	sub    rcx,rax
    1af9:	sub    r12,rcx
    1afc:	shr    r12,0x3
    1b00:	shl    r12,1
    1b03:	lea    rbx,[rsp+0x38]
    1b08:	mov    rax,r12
    1b0b:	or     rax,0x1
    1b0f:	mov    r14,rdx
    1b12:	mov    rcx,r14
    1b15:	and    rcx,rax
    1b18:	test   rcx,0x1
    1b1f:	jne    1b4c <botlish_fn_23+0xcc>
    1b25:	mov    rdx,r12
    1b28:	or     rdx,0x1
    1b2c:	mov    rsi,r14
    1b2f:	mov    rdi,r13
    1b32:	call   1b37 <botlish_fn_23+0xb7>
			1b33: R_X86_64_PLT32	rt_int_cmp-0x4
    1b37:	mov    ecx,0x2
    1b3c:	test   rax,rax
    1b3f:	cmovge rcx,QWORD PTR [rip+0x1f1]        # 1d38 <botlish_fn_23+0x2b8>
    1b47:	jmp    1b63 <botlish_fn_23+0xe3>
    1b4c:	mov    rax,r12
    1b4f:	or     rax,0x1
    1b53:	mov    ecx,0x2
    1b58:	cmp    r14,rax
    1b5b:	cmovge rcx,QWORD PTR [rip+0x1d5]        # 1d38 <botlish_fn_23+0x2b8>
    1b63:	cmp    rcx,0x6
    1b67:	je     1b77 <botlish_fn_23+0xf7>
    1b6d:	mov    eax,0x2
    1b72:	jmp    1b7c <botlish_fn_23+0xfc>
    1b77:	mov    eax,0x6
    1b7c:	cmp    rax,0x6
    1b80:	je     1ca3 <botlish_fn_23+0x223>
    1b86:	mov    QWORD PTR [rsp+0x10],0x3
    1b8f:	test   r14,0x1
    1b96:	je     1bae <botlish_fn_23+0x12e>
    1b9c:	mov    rax,r14
    1b9f:	add    rax,0x2
    1ba3:	seto   cl
    1ba6:	test   cl,cl
    1ba8:	je     1bbe <botlish_fn_23+0x13e>
    1bae:	mov    edx,0x3
    1bb3:	mov    rsi,r14
    1bb6:	mov    rdi,r13
    1bb9:	call   1bbe <botlish_fn_23+0x13e>
			1bba: R_X86_64_PLT32	rt_int_add-0x4
    1bbe:	mov    QWORD PTR [rsp+0x10],rax
    1bc3:	mov    QWORD PTR [rsp+0x60],rax
    1bc8:	mov    rsi,r15
    1bcb:	mov    rdi,r13
    1bce:	call   1bd3 <botlish_fn_23+0x153>
			1bcf: R_X86_64_PLT32	rt_ascii_to_str-0x4
    1bd3:	mov    QWORD PTR [rsp+0x18],rax
    1bd8:	mov    QWORD PTR [rsp+0x68],rax
    1bdd:	mov    QWORD PTR [rsp+0x20],0x3
    1be6:	test   r14,0x1
    1bed:	je     1c05 <botlish_fn_23+0x185>
    1bf3:	mov    rcx,r14
    1bf6:	add    rcx,0x2
    1bfa:	seto   al
    1bfd:	test   al,al
    1bff:	je     1c18 <botlish_fn_23+0x198>
    1c05:	mov    edx,0x3
    1c0a:	mov    rsi,r14
    1c0d:	mov    rdi,r13
    1c10:	call   1c15 <botlish_fn_23+0x195>
			1c11: R_X86_64_PLT32	rt_int_add-0x4
    1c15:	mov    rcx,rax
    1c18:	mov    QWORD PTR [rsp+0x20],rcx
    1c1d:	mov    rdx,r14
    1c20:	mov    rsi,QWORD PTR [rsp+0x68]
    1c25:	mov    rdi,r13
    1c28:	call   1c2d <botlish_fn_23+0x1ad>
			1c29: R_X86_64_PLT32	rt_substr_proven-0x4
    1c2d:	mov    QWORD PTR [rsp],rax
    1c31:	mov    rsi,rax
    1c34:	mov    rdi,r13
    1c37:	call   1c3c <botlish_fn_23+0x1bc>
			1c38: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_char<str>
    1c3c:	test   rax,rax
    1c3f:	je     1cd7 <botlish_fn_23+0x257>
    1c45:	mov    QWORD PTR [rsp],rax
    1c49:	mov    QWORD PTR [rsp+0x38],0x0
    1c52:	mov    rcx,QWORD PTR [rsp+0x58]
    1c57:	mov    QWORD PTR [rsp+0x40],rcx
    1c5c:	mov    QWORD PTR [rsp+0x48],0x0
    1c65:	mov    QWORD PTR [rsp+0x50],rax
    1c6a:	mov    esi,0x2
    1c6f:	mov    edx,0x4
    1c74:	mov    rcx,rbx
    1c77:	mov    rdi,r13
    1c7a:	call   1c7f <botlish_fn_23+0x1ff>
			1c7b: R_X86_64_PLT32	rt_construct-0x4
    1c7f:	test   rax,rax
    1c82:	je     1cd7 <botlish_fn_23+0x257>
    1c88:	mov    rcx,QWORD PTR [rsp+0x60]
    1c8d:	mov    QWORD PTR [rsp],rcx
    1c91:	mov    QWORD PTR [rsp+0x8],rax
    1c96:	mov    rdx,rcx
    1c99:	mov    QWORD PTR [rsp+0x58],rax
    1c9e:	jmp    1b08 <botlish_fn_23+0x88>
    1ca3:	mov    rcx,QWORD PTR [rsp+0x58]
    1ca8:	xor    rsi,rsi
    1cab:	lea    rax,[rsp+0x28]
    1cb0:	mov    QWORD PTR [rsp+0x28],0x0
    1cb9:	mov    QWORD PTR [rsp+0x30],rcx
    1cbe:	mov    edx,0x2
    1cc3:	mov    rcx,rax
    1cc6:	mov    rdi,r13
    1cc9:	call   1cce <botlish_fn_23+0x24e>
			1cca: R_X86_64_PLT32	rt_construct-0x4
    1cce:	test   rax,rax
    1cd1:	jne    1d08 <botlish_fn_23+0x288>
    1cd7:	xor    rax,rax
    1cda:	mov    rbx,QWORD PTR [rsp+0x70]
    1cdf:	mov    r12,QWORD PTR [rsp+0x78]
    1ce4:	mov    r13,QWORD PTR [rsp+0x80]
    1cec:	mov    r14,QWORD PTR [rsp+0x88]
    1cf4:	mov    r15,QWORD PTR [rsp+0x90]
    1cfc:	add    rsp,0xa0
    1d03:	mov    rsp,rbp
    1d06:	pop    rbp
    1d07:	ret
    1d08:	mov    rbx,QWORD PTR [rsp+0x70]
    1d0d:	mov    r12,QWORD PTR [rsp+0x78]
    1d12:	mov    r13,QWORD PTR [rsp+0x80]
    1d1a:	mov    r14,QWORD PTR [rsp+0x88]
    1d22:	mov    r15,QWORD PTR [rsp+0x90]
    1d2a:	add    rsp,0xa0
    1d31:	mov    rsp,rbp
    1d34:	pop    rbp
    1d35:	ret
    1d36:	add    BYTE PTR [rax],al
    1d38:	(bad)
    1d39:	add    BYTE PTR [rax],al
    1d3b:	add    BYTE PTR [rax],al
    1d3d:	add    BYTE PTR [rax],al
	...

0000000000001d40 <botlish_entry_23: esc_from<str, int, str>>:
    1d40:	push   rbp
    1d41:	mov    rbp,rsp
    1d44:	sub    rsp,0x10
    1d48:	mov    QWORD PTR [rsp],r12
    1d4c:	mov    QWORD PTR [rsp+0x8],r13
    1d51:	mov    r12,rdi
    1d54:	mov    rsi,QWORD PTR [rdx]
    1d57:	mov    r13,rdx
    1d5a:	mov    r8,QWORD PTR [rip+0x0]        # 1d61 <botlish_entry_23+0x21>
			1d5d: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    1d61:	call   r8
    1d64:	mov    rcx,r13
    1d67:	mov    rdx,QWORD PTR [rcx+0x8]
    1d6b:	mov    rcx,QWORD PTR [rcx+0x10]
    1d6f:	mov    rsi,rax
    1d72:	mov    rdi,r12
    1d75:	call   1d7a <botlish_entry_23+0x3a>
			1d76: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_from<str, int, str>
    1d7a:	mov    r12,QWORD PTR [rsp]
    1d7e:	mov    r13,QWORD PTR [rsp+0x8]
    1d83:	add    rsp,0x10
    1d87:	mov    rsp,rbp
    1d8a:	pop    rbp
    1d8b:	ret

0000000000001d8c <botlish_fn_24: check<int, int, str, str>>:
    1d8c:	push   rbp
    1d8d:	mov    rbp,rsp
    1d90:	sub    rsp,0x50
    1d94:	mov    QWORD PTR [rsp+0x20],rbx
    1d99:	mov    QWORD PTR [rsp+0x28],r12
    1d9e:	mov    QWORD PTR [rsp+0x30],r13
    1da3:	mov    QWORD PTR [rsp+0x38],r14
    1da8:	mov    QWORD PTR [rsp+0x40],r15
    1dad:	mov    r14,rdi
    1db0:	mov    QWORD PTR [rsp+0x18],0x0
    1db9:	mov    QWORD PTR [rsp],rdx
    1dbd:	mov    QWORD PTR [rsp+0x8],rcx
    1dc2:	mov    QWORD PTR [rsp+0x10],r8
    1dc7:	mov    r13,r8
    1dca:	mov    r12,rsi
    1dcd:	mov    r15,rdx
    1dd0:	test   r12,r12
    1dd3:	jle    1e95 <botlish_fn_24+0x109>
    1dd9:	mov    rbx,rcx
    1ddc:	mov    rsi,rbx
    1ddf:	mov    rdi,r14
    1de2:	call   1de7 <botlish_fn_24+0x5b>
			1de3: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::emailish?<str>
    1de7:	test   rax,rax
    1dea:	jne    1e15 <botlish_fn_24+0x89>
    1df0:	xor    rax,rax
    1df3:	mov    rbx,QWORD PTR [rsp+0x20]
    1df8:	mov    r12,QWORD PTR [rsp+0x28]
    1dfd:	mov    r13,QWORD PTR [rsp+0x30]
    1e02:	mov    r14,QWORD PTR [rsp+0x38]
    1e07:	mov    r15,QWORD PTR [rsp+0x40]
    1e0c:	add    rsp,0x50
    1e10:	mov    rsp,rbp
    1e13:	pop    rbp
    1e14:	ret
    1e15:	cmp    rax,0x6
    1e19:	je     1e35 <botlish_fn_24+0xa9>
    1e1f:	mov    edx,0x1
    1e24:	mov    QWORD PTR [rsp+0x18],0x1
    1e2d:	mov    rsi,r15
    1e30:	jmp    1e46 <botlish_fn_24+0xba>
    1e35:	mov    edx,0x3
    1e3a:	mov    QWORD PTR [rsp+0x18],0x3
    1e43:	mov    rsi,r15
    1e46:	mov    rax,rsi
    1e49:	and    rax,rdx
    1e4c:	test   rax,0x1
    1e52:	je     1e6d <botlish_fn_24+0xe1>
    1e58:	lea    rcx,[rdx-0x1]
    1e5c:	mov    rax,rsi
    1e5f:	add    rax,rcx
    1e62:	seto   cl
    1e65:	test   cl,cl
    1e67:	je     1e75 <botlish_fn_24+0xe9>
    1e6d:	mov    rdi,r14
    1e70:	call   1e75 <botlish_fn_24+0xe9>
			1e71: R_X86_64_PLT32	rt_int_add-0x4
    1e75:	mov    QWORD PTR [rsp],rax
    1e79:	mov    QWORD PTR [rsp+0x8],rbx
    1e7e:	mov    r8,r13
    1e81:	mov    QWORD PTR [rsp+0x10],r8
    1e86:	sub    r12,0x1
    1e8a:	mov    rcx,rbx
    1e8d:	mov    r15,rax
    1e90:	jmp    1dd0 <botlish_fn_24+0x44>
    1e95:	mov    rax,r15
    1e98:	mov    rbx,QWORD PTR [rsp+0x20]
    1e9d:	mov    r12,QWORD PTR [rsp+0x28]
    1ea2:	mov    r13,QWORD PTR [rsp+0x30]
    1ea7:	mov    r14,QWORD PTR [rsp+0x38]
    1eac:	mov    r15,QWORD PTR [rsp+0x40]
    1eb1:	add    rsp,0x50
    1eb5:	mov    rsp,rbp
    1eb8:	pop    rbp
    1eb9:	ret

0000000000001eba <botlish_entry_24: check<int, int, str, str>>:
    1eba:	push   rbp
    1ebb:	mov    rbp,rsp
    1ebe:	mov    rsi,QWORD PTR [rdx]
    1ec1:	mov    r9,QWORD PTR [rdx+0x8]
    1ec5:	mov    rcx,QWORD PTR [rdx+0x10]
    1ec9:	mov    r8,QWORD PTR [rdx+0x18]
    1ecd:	sar    rsi,1
    1ed0:	mov    rdx,r9
    1ed3:	call   1ed8 <botlish_entry_24+0x1e>
			1ed4: R_X86_64_PLT32	botlish_fn_24-0x4 ; check<int, int, str, str>
    1ed8:	mov    rsp,rbp
    1edb:	pop    rbp
    1edc:	ret

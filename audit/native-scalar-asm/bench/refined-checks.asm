; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 8704  (per function: 1415 217 609 74 74 74 128 128 351 258 175 176 238 304 352 183 797 140 127 103 474 714 426 823 344)
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
;   botlish_fn_13 / botlish_entry_13 -> scan_while<int, block(e250)>
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
     a73:	mov    r14,rdi
     a76:	mov    QWORD PTR [rsp],rsi
     a7a:	mov    r13,rsi
     a7d:	mov    rsi,r13
     a80:	mov    rdi,r14
     a83:	call   a88 <botlish_fn_8+0x31>
			a84: R_X86_64_PLT32	rt_str_len-0x4
     a88:	mov    r12,rax
     a8b:	mov    QWORD PTR [rsp+0x8],rax
     a90:	mov    rdi,r14
     a93:	mov    rax,QWORD PTR [rdi+0x10]
     a97:	mov    rdx,QWORD PTR [rax+0xc0]
     a9e:	mov    QWORD PTR [rsp+0x10],rdx
     aa3:	xor    rsi,rsi
     aa6:	mov    rcx,r12
     aa9:	mov    r8,r13
     aac:	call   ab1 <botlish_fn_8+0x5a>
			aad: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<int, block(e250)>
     ab1:	test   rax,rax
     ab4:	je     b46 <botlish_fn_8+0xef>
     aba:	mov    rbx,rax
     abd:	sar    rbx,1
     ac0:	mov    rsi,rax
     ac3:	test   rbx,rbx
     ac6:	je     b75 <botlish_fn_8+0x11e>
     acc:	mov    rax,r12
     acf:	sar    rax,1
     ad2:	cmp    rbx,rax
     ad5:	jge    b6b <botlish_fn_8+0x114>
     adb:	lea    r8,[rsp+0x18]
     ae0:	mov    rcx,r13
     ae3:	mov    rdx,r12
     ae6:	mov    rdi,r14
     ae9:	call   aee <botlish_fn_8+0x97>
			aea: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     aee:	test   rax,rax
     af1:	mov    rsi,rax
     af4:	je     b46 <botlish_fn_8+0xef>
     afa:	mov    rdx,QWORD PTR [rsp+0x18]
     aff:	mov    rcx,QWORD PTR [rsp+0x20]
     b04:	mov    rdi,r14
     b07:	mov    rax,QWORD PTR [rdi+0x10]
     b0b:	mov    r8,QWORD PTR [rax+0xc8]
     b12:	call   b17 <botlish_fn_8+0xc0>
			b13: R_X86_64_PLT32	rt_str_region_eq-0x4
     b17:	cmp    rax,0x6
     b1b:	je     b2b <botlish_fn_8+0xd4>
     b21:	mov    eax,0x2
     b26:	jmp    b7a <botlish_fn_8+0x123>
     b2b:	lea    rsi,[rbx+0x1]
     b2f:	mov    rcx,r13
     b32:	mov    rdx,r12
     b35:	mov    rdi,r14
     b38:	call   b3d <botlish_fn_8+0xe6>
			b39: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain?<int>
     b3d:	test   rax,rax
     b40:	jne    b7a <botlish_fn_8+0x123>
     b46:	xor    rax,rax
     b49:	mov    rbx,QWORD PTR [rsp+0x30]
     b4e:	mov    r12,QWORD PTR [rsp+0x38]
     b53:	mov    r13,QWORD PTR [rsp+0x40]
     b58:	mov    r14,QWORD PTR [rsp+0x48]
     b5d:	add    rsp,0x50
     b61:	mov    rsp,rbp
     b64:	pop    rbp
     b65:	ret
     b66:	jmp    b7a <botlish_fn_8+0x123>
     b6b:	mov    eax,0x2
     b70:	jmp    b7a <botlish_fn_8+0x123>
     b75:	mov    eax,0x2
     b7a:	mov    rbx,QWORD PTR [rsp+0x30]
     b7f:	mov    r12,QWORD PTR [rsp+0x38]
     b84:	mov    r13,QWORD PTR [rsp+0x40]
     b89:	mov    r14,QWORD PTR [rsp+0x48]
     b8e:	add    rsp,0x50
     b92:	mov    rsp,rbp
     b95:	pop    rbp
     b96:	ret

0000000000000b97 <botlish_entry_8: web::emailish?<str>>:
     b97:	push   rbp
     b98:	mov    rbp,rsp
     b9b:	mov    rsi,QWORD PTR [rdx]
     b9e:	call   ba3 <botlish_entry_8+0xc>
			b9f: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::emailish?<str>
     ba3:	mov    rsp,rbp
     ba6:	pop    rbp
     ba7:	ret

0000000000000ba8 <botlish_fn_9: char_at<int>>:
     ba8:	push   rbp
     ba9:	mov    rbp,rsp
     bac:	sub    rsp,0x20
     bb0:	mov    QWORD PTR [rsp],rbx
     bb4:	mov    QWORD PTR [rsp+0x8],r12
     bb9:	mov    QWORD PTR [rsp+0x10],r13
     bbe:	mov    QWORD PTR [rsp+0x18],r14
     bc3:	mov    r13,r8
     bc6:	mov    r14,rcx
     bc9:	mov    rax,rsi
     bcc:	sar    rax,1
     bcf:	sar    rdx,1
     bd2:	cmp    rax,rdx
     bd5:	jge    be6 <botlish_fn_9+0x3e>
     bdb:	mov    r11d,0x2
     be1:	jmp    bec <botlish_fn_9+0x44>
     be6:	mov    r11d,0x6
     bec:	cmp    r11,0x6
     bf0:	je     c63 <botlish_fn_9+0xbb>
     bf6:	lea    r12,[rax+0x1]
     bfa:	shl    r12,1
     bfd:	or     r12,0x1
     c01:	mov    rbx,rsi
     c04:	mov    rcx,r12
     c07:	mov    rdx,rbx
     c0a:	mov    rsi,r14
     c0d:	call   c12 <botlish_fn_9+0x6a>
			c0e: R_X86_64_PLT32	rt_str_region_check-0x4
     c12:	test   rax,rax
     c15:	jne    c3a <botlish_fn_9+0x92>
     c1b:	xor    rax,rax
     c1e:	mov    rbx,QWORD PTR [rsp]
     c22:	mov    r12,QWORD PTR [rsp+0x8]
     c27:	mov    r13,QWORD PTR [rsp+0x10]
     c2c:	mov    r14,QWORD PTR [rsp+0x18]
     c31:	add    rsp,0x20
     c35:	mov    rsp,rbp
     c38:	pop    rbp
     c39:	ret
     c3a:	mov    r8,r13
     c3d:	mov    QWORD PTR [r8],rbx
     c40:	mov    QWORD PTR [r8+0x8],r12
     c44:	mov    rax,r14
     c47:	mov    rbx,QWORD PTR [rsp]
     c4b:	mov    r12,QWORD PTR [rsp+0x8]
     c50:	mov    r13,QWORD PTR [rsp+0x10]
     c55:	mov    r14,QWORD PTR [rsp+0x18]
     c5a:	add    rsp,0x20
     c5e:	mov    rsp,rbp
     c61:	pop    rbp
     c62:	ret
     c63:	mov    r8,r13
     c66:	mov    rax,QWORD PTR [rdi+0x10]
     c6a:	mov    rax,QWORD PTR [rax+0xd0]
     c71:	mov    QWORD PTR [r8],0x1
     c78:	mov    QWORD PTR [r8+0x8],0x1
     c80:	mov    rbx,QWORD PTR [rsp]
     c84:	mov    r12,QWORD PTR [rsp+0x8]
     c89:	mov    r13,QWORD PTR [rsp+0x10]
     c8e:	mov    r14,QWORD PTR [rsp+0x18]
     c93:	add    rsp,0x20
     c97:	mov    rsp,rbp
     c9a:	pop    rbp
     c9b:	ret

0000000000000c9c <botlish_entry_9: char_at<int>>:
     c9c:	push   rbp
     c9d:	mov    rbp,rsp
     ca0:	ud2

0000000000000ca2 <botlish_fn_10: char_at<int>>:
     ca2:	push   rbp
     ca3:	mov    rbp,rsp
     ca6:	sub    rsp,0x20
     caa:	mov    QWORD PTR [rsp],rsi
     cae:	mov    QWORD PTR [rsp+0x8],rcx
     cb3:	mov    r8,rcx
     cb6:	mov    rax,rsi
     cb9:	sar    rax,1
     cbc:	sar    rdx,1
     cbf:	cmp    rax,rdx
     cc2:	jge    cd2 <botlish_fn_10+0x30>
     cc8:	mov    ecx,0x2
     ccd:	jmp    cd7 <botlish_fn_10+0x35>
     cd2:	mov    ecx,0x6
     cd7:	cmp    rcx,0x6
     cdb:	je     d1a <botlish_fn_10+0x78>
     ce1:	lea    rcx,[rax+0x1]
     ce5:	shl    rcx,1
     ce8:	or     rcx,0x1
     cec:	mov    QWORD PTR [rsp+0x10],rcx
     cf1:	mov    rdx,rsi
     cf4:	mov    rsi,r8
     cf7:	call   cfc <botlish_fn_10+0x5a>
			cf8: R_X86_64_PLT32	rt_substr-0x4
     cfc:	test   rax,rax
     cff:	jne    d11 <botlish_fn_10+0x6f>
     d05:	xor    rax,rax
     d08:	add    rsp,0x20
     d0c:	mov    rsp,rbp
     d0f:	pop    rbp
     d10:	ret
     d11:	add    rsp,0x20
     d15:	mov    rsp,rbp
     d18:	pop    rbp
     d19:	ret
     d1a:	mov    rax,QWORD PTR [rdi+0x10]
     d1e:	mov    rax,QWORD PTR [rax+0xd0]
     d25:	add    rsp,0x20
     d29:	mov    rsp,rbp
     d2c:	pop    rbp
     d2d:	ret

0000000000000d2e <botlish_entry_10: char_at<int>>:
     d2e:	push   rbp
     d2f:	mov    rbp,rsp
     d32:	mov    rsi,QWORD PTR [rdx]
     d35:	mov    r8,QWORD PTR [rdx+0x8]
     d39:	mov    rcx,QWORD PTR [rdx+0x10]
     d3d:	mov    rdx,r8
     d40:	call   d45 <botlish_entry_10+0x17>
			d41: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
     d45:	mov    rsp,rbp
     d48:	pop    rbp
     d49:	ret

0000000000000d4a <botlish_fn_11: local_char?<str>>:
     d4a:	push   rbp
     d4b:	mov    rbp,rsp
     d4e:	sub    rsp,0x10
     d52:	mov    QWORD PTR [rsp],rbx
     d56:	mov    QWORD PTR [rsp+0x8],r14
     d5b:	mov    rbx,rdi
     d5e:	mov    r14,rsi
     d61:	mov    rsi,r14
     d64:	mov    rdi,rbx
     d67:	call   d6c <botlish_fn_11+0x22>
			d68: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     d6c:	test   rax,rax
     d6f:	jne    d8a <botlish_fn_11+0x40>
     d75:	xor    rax,rax
     d78:	mov    rbx,QWORD PTR [rsp]
     d7c:	mov    r14,QWORD PTR [rsp+0x8]
     d81:	add    rsp,0x10
     d85:	mov    rsp,rbp
     d88:	pop    rbp
     d89:	ret
     d8a:	cmp    rax,0x6
     d8e:	je     dc4 <botlish_fn_11+0x7a>
     d94:	mov    rdi,rbx
     d97:	mov    rax,QWORD PTR [rdi+0x30]
     d9b:	mov    rsi,QWORD PTR [rax]
     d9e:	mov    rdx,r14
     da1:	call   da6 <botlish_fn_11+0x5c>
			da2: R_X86_64_PLT32	rt_set_contains-0x4
     da6:	cmp    rax,0x6
     daa:	je     dba <botlish_fn_11+0x70>
     db0:	mov    eax,0x2
     db5:	jmp    dc9 <botlish_fn_11+0x7f>
     dba:	mov    eax,0x6
     dbf:	jmp    dc9 <botlish_fn_11+0x7f>
     dc4:	mov    eax,0x6
     dc9:	mov    rbx,QWORD PTR [rsp]
     dcd:	mov    r14,QWORD PTR [rsp+0x8]
     dd2:	add    rsp,0x10
     dd6:	mov    rsp,rbp
     dd9:	pop    rbp
     dda:	ret

0000000000000ddb <botlish_entry_11: local_char?<str>>:
     ddb:	push   rbp
     ddc:	mov    rbp,rsp
     ddf:	mov    rsi,QWORD PTR [rdx]
     de2:	call   de7 <botlish_entry_11+0xc>
			de3: R_X86_64_PLT32	botlish_fn_11-0x4 ; local_char?<str>
     de7:	mov    rsp,rbp
     dea:	pop    rbp
     deb:	ret

0000000000000dec <botlish_fn_12: local_char?<generic>>:
     dec:	push   rbp
     ded:	mov    rbp,rsp
     df0:	sub    rsp,0x10
     df4:	mov    QWORD PTR [rsp],rbx
     df8:	mov    QWORD PTR [rsp+0x8],r12
     dfd:	xor    r8d,r8d
     e00:	test   rsi,0x7
     e07:	jne    e17 <botlish_fn_12+0x2b>
     e0d:	movzx  rax,BYTE PTR [rsi]
     e11:	cmp    al,0x2
     e13:	sete   r8b
     e17:	test   r8b,r8b
     e1a:	jne    e3a <botlish_fn_12+0x4e>
     e20:	mov    rax,QWORD PTR [rdi+0x10]
     e24:	mov    rcx,QWORD PTR [rax+0xd8]
     e2b:	mov    edx,0x1
     e30:	call   e35 <botlish_fn_12+0x49>
			e31: R_X86_64_PLT32	rt_type_error-0x4
     e35:	jmp    e4e <botlish_fn_12+0x62>
     e3a:	mov    rbx,rsi
     e3d:	mov    r12,rdi
     e40:	call   e45 <botlish_fn_12+0x59>
			e41: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     e45:	test   rax,rax
     e48:	jne    e63 <botlish_fn_12+0x77>
     e4e:	xor    rax,rax
     e51:	mov    rbx,QWORD PTR [rsp]
     e55:	mov    r12,QWORD PTR [rsp+0x8]
     e5a:	add    rsp,0x10
     e5e:	mov    rsp,rbp
     e61:	pop    rbp
     e62:	ret
     e63:	cmp    rax,0x6
     e67:	je     e9d <botlish_fn_12+0xb1>
     e6d:	mov    rdi,r12
     e70:	mov    rax,QWORD PTR [rdi+0x30]
     e74:	mov    rsi,QWORD PTR [rax]
     e77:	mov    rdx,rbx
     e7a:	call   e7f <botlish_fn_12+0x93>
			e7b: R_X86_64_PLT32	rt_set_contains-0x4
     e7f:	cmp    rax,0x6
     e83:	je     e93 <botlish_fn_12+0xa7>
     e89:	mov    eax,0x2
     e8e:	jmp    ea2 <botlish_fn_12+0xb6>
     e93:	mov    eax,0x6
     e98:	jmp    ea2 <botlish_fn_12+0xb6>
     e9d:	mov    eax,0x6
     ea2:	mov    rbx,QWORD PTR [rsp]
     ea6:	mov    r12,QWORD PTR [rsp+0x8]
     eab:	add    rsp,0x10
     eaf:	mov    rsp,rbp
     eb2:	pop    rbp
     eb3:	ret

0000000000000eb4 <botlish_entry_12: local_char?<generic>>:
     eb4:	push   rbp
     eb5:	mov    rbp,rsp
     eb8:	mov    rsi,QWORD PTR [rdx]
     ebb:	call   ec0 <botlish_entry_12+0xc>
			ebc: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<generic>
     ec0:	mov    rsp,rbp
     ec3:	pop    rbp
     ec4:	ret

0000000000000ec5 <botlish_fn_13: scan_while<int, block(e250)>>:
     ec5:	push   rbp
     ec6:	mov    rbp,rsp
     ec9:	sub    rsp,0x50
     ecd:	mov    QWORD PTR [rsp+0x20],rbx
     ed2:	mov    QWORD PTR [rsp+0x28],r12
     ed7:	mov    QWORD PTR [rsp+0x30],r13
     edc:	mov    QWORD PTR [rsp+0x38],r14
     ee1:	mov    QWORD PTR [rsp+0x40],r15
     ee6:	mov    QWORD PTR [rsp+0x18],rdi
     eeb:	mov    QWORD PTR [rsp],rcx
     eef:	mov    QWORD PTR [rsp+0x8],r8
     ef4:	mov    r15,r8
     ef7:	mov    r12,rcx
     efa:	sar    r12,1
     efd:	mov    r14,rcx
     f00:	mov    rbx,rsi
     f03:	cmp    rbx,r12
     f06:	jl     f31 <botlish_fn_13+0x6c>
     f0c:	mov    rax,r14
     f0f:	mov    rbx,QWORD PTR [rsp+0x20]
     f14:	mov    r12,QWORD PTR [rsp+0x28]
     f19:	mov    r13,QWORD PTR [rsp+0x30]
     f1e:	mov    r14,QWORD PTR [rsp+0x38]
     f23:	mov    r15,QWORD PTR [rsp+0x40]
     f28:	add    rsp,0x50
     f2c:	mov    rsp,rbp
     f2f:	pop    rbp
     f30:	ret
     f31:	mov    r13,rbx
     f34:	shl    r13,1
     f37:	or     r13,0x1
     f3b:	mov    QWORD PTR [rsp+0x10],r13
     f40:	mov    rcx,r15
     f43:	mov    rdx,r14
     f46:	mov    rsi,r13
     f49:	mov    rdi,QWORD PTR [rsp+0x18]
     f4e:	call   f53 <botlish_fn_13+0x8e>
			f4f: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<int>
     f53:	test   rax,rax
     f56:	mov    rsi,rax
     f59:	je     f72 <botlish_fn_13+0xad>
     f5f:	mov    rdi,QWORD PTR [rsp+0x18]
     f64:	call   f69 <botlish_fn_13+0xa4>
			f65: R_X86_64_PLT32	botlish_fn_11-0x4 ; local_char?<str>
     f69:	test   rax,rax
     f6c:	jne    f97 <botlish_fn_13+0xd2>
     f72:	xor    rax,rax
     f75:	mov    rbx,QWORD PTR [rsp+0x20]
     f7a:	mov    r12,QWORD PTR [rsp+0x28]
     f7f:	mov    r13,QWORD PTR [rsp+0x30]
     f84:	mov    r14,QWORD PTR [rsp+0x38]
     f89:	mov    r15,QWORD PTR [rsp+0x40]
     f8e:	add    rsp,0x50
     f92:	mov    rsp,rbp
     f95:	pop    rbp
     f96:	ret
     f97:	cmp    rax,0x6
     f9b:	je     fc6 <botlish_fn_13+0x101>
     fa1:	mov    rax,r13
     fa4:	mov    rbx,QWORD PTR [rsp+0x20]
     fa9:	mov    r12,QWORD PTR [rsp+0x28]
     fae:	mov    r13,QWORD PTR [rsp+0x30]
     fb3:	mov    r14,QWORD PTR [rsp+0x38]
     fb8:	mov    r15,QWORD PTR [rsp+0x40]
     fbd:	add    rsp,0x50
     fc1:	mov    rsp,rbp
     fc4:	pop    rbp
     fc5:	ret
     fc6:	add    rbx,0x1
     fcd:	jmp    f03 <botlish_fn_13+0x3e>

0000000000000fd2 <botlish_entry_13: scan_while<int, block(e250)>>:
     fd2:	push   rbp
     fd3:	mov    rbp,rsp
     fd6:	mov    rsi,QWORD PTR [rdx]
     fd9:	mov    r9,QWORD PTR [rdx+0x8]
     fdd:	mov    rcx,QWORD PTR [rdx+0x10]
     fe1:	mov    r8,QWORD PTR [rdx+0x18]
     fe5:	sar    rsi,1
     fe8:	mov    rdx,r9
     feb:	call   ff0 <botlish_entry_13+0x1e>
			fec: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<int, block(e250)>
     ff0:	mov    rsp,rbp
     ff3:	pop    rbp
     ff4:	ret

0000000000000ff5 <botlish_fn_14: scan_while<int, native(str::is_tcl_alpha)>>:
     ff5:	push   rbp
     ff6:	mov    rbp,rsp
     ff9:	sub    rsp,0x40
     ffd:	mov    QWORD PTR [rsp+0x10],rbx
    1002:	mov    QWORD PTR [rsp+0x18],r12
    1007:	mov    QWORD PTR [rsp+0x20],r13
    100c:	mov    QWORD PTR [rsp+0x28],r14
    1011:	mov    QWORD PTR [rsp+0x30],r15
    1016:	mov    rbx,r8
    1019:	mov    r13,rdi
    101c:	mov    rax,rcx
    101f:	sar    rax,1
    1022:	mov    r12,rcx
    1025:	mov    r14,rax
    1028:	mov    rax,rsi
    102b:	mov    rcx,r14
    102e:	cmp    rax,rcx
    1031:	mov    r14,rcx
    1034:	jl     1064 <botlish_fn_14+0x6f>
    103a:	mov    edx,0x1
    103f:	mov    rax,r14
    1042:	mov    rbx,QWORD PTR [rsp+0x10]
    1047:	mov    r12,QWORD PTR [rsp+0x18]
    104c:	mov    r13,QWORD PTR [rsp+0x20]
    1051:	mov    r14,QWORD PTR [rsp+0x28]
    1056:	mov    r15,QWORD PTR [rsp+0x30]
    105b:	add    rsp,0x40
    105f:	mov    rsp,rbp
    1062:	pop    rbp
    1063:	ret
    1064:	mov    rsi,rax
    1067:	shl    rsi,1
    106a:	mov    r15,rax
    106d:	or     rsi,0x1
    1071:	lea    r8,[rsp]
    1075:	mov    rcx,rbx
    1078:	mov    rdx,r12
    107b:	mov    rdi,r13
    107e:	call   1083 <botlish_fn_14+0x8e>
			107f: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    1083:	test   rax,rax
    1086:	mov    rsi,rax
    1089:	je     10a9 <botlish_fn_14+0xb4>
    108f:	mov    rdx,QWORD PTR [rsp]
    1093:	mov    rcx,QWORD PTR [rsp+0x8]
    1098:	mov    rdi,r13
    109b:	call   10a0 <botlish_fn_14+0xab>
			109c: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    10a0:	test   rax,rax
    10a3:	jne    10d1 <botlish_fn_14+0xdc>
    10a9:	xor    rdx,rdx
    10ac:	mov    rax,rdx
    10af:	mov    rbx,QWORD PTR [rsp+0x10]
    10b4:	mov    r12,QWORD PTR [rsp+0x18]
    10b9:	mov    r13,QWORD PTR [rsp+0x20]
    10be:	mov    r14,QWORD PTR [rsp+0x28]
    10c3:	mov    r15,QWORD PTR [rsp+0x30]
    10c8:	add    rsp,0x40
    10cc:	mov    rsp,rbp
    10cf:	pop    rbp
    10d0:	ret
    10d1:	cmp    rax,0x6
    10d5:	je     1105 <botlish_fn_14+0x110>
    10db:	mov    edx,0x1
    10e0:	mov    rax,r15
    10e3:	mov    rbx,QWORD PTR [rsp+0x10]
    10e8:	mov    r12,QWORD PTR [rsp+0x18]
    10ed:	mov    r13,QWORD PTR [rsp+0x20]
    10f2:	mov    r14,QWORD PTR [rsp+0x28]
    10f7:	mov    r15,QWORD PTR [rsp+0x30]
    10fc:	add    rsp,0x40
    1100:	mov    rsp,rbp
    1103:	pop    rbp
    1104:	ret
    1105:	mov    rax,r15
    1108:	add    rax,0x1
    110f:	mov    rcx,r14
    1112:	jmp    102e <botlish_fn_14+0x39>

0000000000001117 <botlish_entry_14: scan_while<int, native(str::is_tcl_alpha)>>:
    1117:	push   rbp
    1118:	mov    rbp,rsp
    111b:	mov    rsi,QWORD PTR [rdx]
    111e:	mov    rax,QWORD PTR [rdx+0x8]
    1122:	mov    rcx,QWORD PTR [rdx+0x10]
    1126:	mov    r8,QWORD PTR [rdx+0x18]
    112a:	sar    rsi,1
    112d:	mov    rdx,rax
    1130:	call   1135 <botlish_entry_14+0x1e>
			1131: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, native(str::is_tcl_alpha)>
    1135:	shl    rax,1
    1138:	or     rax,0x1
    113c:	mov    rcx,rax
    113f:	xor    rax,rax
    1142:	test   rdx,rdx
    1145:	cmovne rax,rcx
    1149:	mov    rsp,rbp
    114c:	pop    rbp
    114d:	ret
	...

0000000000001150 <botlish_fn_15: tld?<int>>:
    1150:	push   rbp
    1151:	mov    rbp,rsp
    1154:	sub    rsp,0x10
    1158:	mov    QWORD PTR [rsp],rbx
    115c:	mov    QWORD PTR [rsp+0x8],r12
    1161:	mov    r8,rdx
    1164:	mov    rax,QWORD PTR [rdi+0x10]
    1168:	mov    rdx,QWORD PTR [rax+0xe0]
    116f:	mov    r12,r8
    1172:	mov    r8,rcx
    1175:	mov    rbx,rsi
    1178:	mov    rcx,r12
    117b:	call   1180 <botlish_fn_15+0x30>
			117c: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, native(str::is_tcl_alpha)>
    1180:	test   rdx,rdx
    1183:	jne    119e <botlish_fn_15+0x4e>
    1189:	xor    rax,rax
    118c:	mov    rbx,QWORD PTR [rsp]
    1190:	mov    r12,QWORD PTR [rsp+0x8]
    1195:	add    rsp,0x10
    1199:	mov    rsp,rbp
    119c:	pop    rbp
    119d:	ret
    119e:	sar    r12,1
    11a1:	cmp    rax,r12
    11a4:	je     11b4 <botlish_fn_15+0x64>
    11aa:	mov    eax,0x2
    11af:	jmp    11cb <botlish_fn_15+0x7b>
    11b4:	sub    rax,rbx
    11b7:	mov    rcx,rax
    11ba:	mov    eax,0x2
    11bf:	cmp    rcx,0x2
    11c3:	cmovge rax,QWORD PTR [rip+0x15]        # 11e0 <botlish_fn_15+0x90>
    11cb:	mov    rbx,QWORD PTR [rsp]
    11cf:	mov    r12,QWORD PTR [rsp+0x8]
    11d4:	add    rsp,0x10
    11d8:	mov    rsp,rbp
    11db:	pop    rbp
    11dc:	ret
    11dd:	add    BYTE PTR [rax],al
    11df:	add    BYTE PTR [rsi],al
    11e1:	add    BYTE PTR [rax],al
    11e3:	add    BYTE PTR [rax],al
    11e5:	add    BYTE PTR [rax],al
	...

00000000000011e8 <botlish_entry_15: tld?<int>>:
    11e8:	push   rbp
    11e9:	mov    rbp,rsp
    11ec:	mov    rsi,QWORD PTR [rdx]
    11ef:	mov    r8,QWORD PTR [rdx+0x8]
    11f3:	mov    rcx,QWORD PTR [rdx+0x10]
    11f7:	sar    rsi,1
    11fa:	mov    rdx,r8
    11fd:	call   1202 <botlish_entry_15+0x1a>
			11fe: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld?<int>
    1202:	mov    rsp,rbp
    1205:	pop    rbp
    1206:	ret

0000000000001207 <botlish_fn_16: domain?<int>>:
    1207:	push   rbp
    1208:	mov    rbp,rsp
    120b:	sub    rsp,0x80
    1212:	mov    QWORD PTR [rsp+0x50],rbx
    1217:	mov    QWORD PTR [rsp+0x58],r12
    121c:	mov    QWORD PTR [rsp+0x60],r13
    1221:	mov    QWORD PTR [rsp+0x68],r14
    1226:	mov    QWORD PTR [rsp+0x70],r15
    122b:	mov    rbx,rsi
    122e:	mov    r15,rcx
    1231:	mov    r14,rdx
    1234:	sar    r14,1
    1237:	mov    QWORD PTR [rsp+0x30],rdx
    123c:	mov    r12,rbx
    123f:	cmp    r12,r14
    1242:	jl     1272 <botlish_fn_16+0x6b>
    1248:	mov    eax,0x2
    124d:	mov    rbx,QWORD PTR [rsp+0x50]
    1252:	mov    r12,QWORD PTR [rsp+0x58]
    1257:	mov    r13,QWORD PTR [rsp+0x60]
    125c:	mov    r14,QWORD PTR [rsp+0x68]
    1261:	mov    r15,QWORD PTR [rsp+0x70]
    1266:	add    rsp,0x80
    126d:	mov    rsp,rbp
    1270:	pop    rbp
    1271:	ret
    1272:	mov    rsi,r12
    1275:	shl    rsi,1
    1278:	or     rsi,0x1
    127c:	mov    QWORD PTR [rsp+0x48],rsi
    1281:	lea    r8,[rsp]
    1285:	mov    r13,rdi
    1288:	mov    rcx,r15
    128b:	mov    rdx,QWORD PTR [rsp+0x30]
    1290:	call   1295 <botlish_fn_16+0x8e>
			1291: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    1295:	test   rax,rax
    1298:	mov    rsi,rax
    129b:	je     1427 <botlish_fn_16+0x220>
    12a1:	mov    rdx,QWORD PTR [rsp]
    12a5:	mov    rcx,QWORD PTR [rsp+0x8]
    12aa:	mov    rax,QWORD PTR [r13+0x10]
    12ae:	mov    r8,QWORD PTR [rax]
    12b1:	mov    rdi,r13
    12b4:	call   12b9 <botlish_fn_16+0xb2>
			12b5: R_X86_64_PLT32	rt_str_region_eq-0x4
    12b9:	cmp    rax,0x6
    12bd:	je     13ae <botlish_fn_16+0x1a7>
    12c3:	lea    r8,[rsp+0x20]
    12c8:	mov    rsi,QWORD PTR [rsp+0x48]
    12cd:	mov    rcx,r15
    12d0:	mov    rdx,QWORD PTR [rsp+0x30]
    12d5:	mov    rdi,r13
    12d8:	call   12dd <botlish_fn_16+0xd6>
			12d9: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    12dd:	test   rax,rax
    12e0:	mov    QWORD PTR [rsp+0x48],rax
    12e5:	je     1427 <botlish_fn_16+0x220>
    12eb:	mov    rdx,QWORD PTR [rsp+0x20]
    12f0:	mov    QWORD PTR [rsp+0x40],rdx
    12f5:	mov    rcx,QWORD PTR [rsp+0x28]
    12fa:	mov    QWORD PTR [rsp+0x38],rcx
    12ff:	mov    rsi,QWORD PTR [rsp+0x48]
    1304:	mov    rdi,r13
    1307:	call   130c <botlish_fn_16+0x105>
			1308: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    130c:	test   rax,rax
    130f:	je     1427 <botlish_fn_16+0x220>
    1315:	cmp    rax,0x6
    1319:	je     135c <botlish_fn_16+0x155>
    131f:	mov    rdi,QWORD PTR [r13+0x10]
    1323:	mov    r8,QWORD PTR [rdi+0x20]
    1327:	mov    rcx,QWORD PTR [rsp+0x38]
    132c:	mov    rdx,QWORD PTR [rsp+0x40]
    1331:	mov    rsi,QWORD PTR [rsp+0x48]
    1336:	mov    rdi,r13
    1339:	call   133e <botlish_fn_16+0x137>
			133a: R_X86_64_PLT32	rt_str_region_eq-0x4
    133e:	cmp    rax,0x6
    1342:	je     1352 <botlish_fn_16+0x14b>
    1348:	mov    ecx,0x2
    134d:	jmp    1361 <botlish_fn_16+0x15a>
    1352:	mov    ecx,0x6
    1357:	jmp    1361 <botlish_fn_16+0x15a>
    135c:	mov    ecx,0x6
    1361:	cmp    rcx,0x6
    1365:	je     1375 <botlish_fn_16+0x16e>
    136b:	mov    eax,0x6
    1370:	jmp    137a <botlish_fn_16+0x173>
    1375:	mov    eax,0x2
    137a:	cmp    rax,0x6
    137e:	jne    1459 <botlish_fn_16+0x252>
    1384:	mov    eax,0x2
    1389:	mov    rbx,QWORD PTR [rsp+0x50]
    138e:	mov    r12,QWORD PTR [rsp+0x58]
    1393:	mov    r13,QWORD PTR [rsp+0x60]
    1398:	mov    r14,QWORD PTR [rsp+0x68]
    139d:	mov    r15,QWORD PTR [rsp+0x70]
    13a2:	add    rsp,0x80
    13a9:	mov    rsp,rbp
    13ac:	pop    rbp
    13ad:	ret
    13ae:	cmp    r12,rbx
    13b1:	je     14bc <botlish_fn_16+0x2b5>
    13b7:	mov    rsi,r12
    13ba:	sub    rsi,0x1
    13be:	shl    rsi,1
    13c1:	or     rsi,0x1
    13c5:	lea    r8,[rsp+0x10]
    13ca:	mov    rcx,r15
    13cd:	mov    rdx,QWORD PTR [rsp+0x30]
    13d2:	mov    rdi,r13
    13d5:	call   13da <botlish_fn_16+0x1d3>
			13d6: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    13da:	test   rax,rax
    13dd:	mov    rsi,rax
    13e0:	je     1427 <botlish_fn_16+0x220>
    13e6:	mov    rdx,QWORD PTR [rsp+0x10]
    13eb:	mov    rcx,QWORD PTR [rsp+0x18]
    13f0:	mov    rax,QWORD PTR [r13+0x10]
    13f4:	mov    r8,QWORD PTR [rax]
    13f7:	mov    rdi,r13
    13fa:	call   13ff <botlish_fn_16+0x1f8>
			13fb: R_X86_64_PLT32	rt_str_region_eq-0x4
    13ff:	cmp    rax,0x6
    1403:	je     1492 <botlish_fn_16+0x28b>
    1409:	lea    rsi,[r12+0x1]
    140e:	mov    rcx,r15
    1411:	mov    rdx,QWORD PTR [rsp+0x30]
    1416:	mov    rdi,r13
    1419:	call   141e <botlish_fn_16+0x217>
			141a: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld?<int>
    141e:	test   rax,rax
    1421:	jne    144f <botlish_fn_16+0x248>
    1427:	xor    rax,rax
    142a:	mov    rbx,QWORD PTR [rsp+0x50]
    142f:	mov    r12,QWORD PTR [rsp+0x58]
    1434:	mov    r13,QWORD PTR [rsp+0x60]
    1439:	mov    r14,QWORD PTR [rsp+0x68]
    143e:	mov    r15,QWORD PTR [rsp+0x70]
    1443:	add    rsp,0x80
    144a:	mov    rsp,rbp
    144d:	pop    rbp
    144e:	ret
    144f:	cmp    rax,0x6
    1453:	je     1468 <botlish_fn_16+0x261>
    1459:	add    r12,0x1
    1460:	mov    rdi,r13
    1463:	jmp    123f <botlish_fn_16+0x38>
    1468:	mov    eax,0x6
    146d:	mov    rbx,QWORD PTR [rsp+0x50]
    1472:	mov    r12,QWORD PTR [rsp+0x58]
    1477:	mov    r13,QWORD PTR [rsp+0x60]
    147c:	mov    r14,QWORD PTR [rsp+0x68]
    1481:	mov    r15,QWORD PTR [rsp+0x70]
    1486:	add    rsp,0x80
    148d:	mov    rsp,rbp
    1490:	pop    rbp
    1491:	ret
    1492:	mov    eax,0x2
    1497:	mov    rbx,QWORD PTR [rsp+0x50]
    149c:	mov    r12,QWORD PTR [rsp+0x58]
    14a1:	mov    r13,QWORD PTR [rsp+0x60]
    14a6:	mov    r14,QWORD PTR [rsp+0x68]
    14ab:	mov    r15,QWORD PTR [rsp+0x70]
    14b0:	add    rsp,0x80
    14b7:	mov    rsp,rbp
    14ba:	pop    rbp
    14bb:	ret
    14bc:	mov    eax,0x2
    14c1:	mov    rbx,QWORD PTR [rsp+0x50]
    14c6:	mov    r12,QWORD PTR [rsp+0x58]
    14cb:	mov    r13,QWORD PTR [rsp+0x60]
    14d0:	mov    r14,QWORD PTR [rsp+0x68]
    14d5:	mov    r15,QWORD PTR [rsp+0x70]
    14da:	add    rsp,0x80
    14e1:	mov    rsp,rbp
    14e4:	pop    rbp
    14e5:	ret

00000000000014e6 <botlish_entry_16: domain?<int>>:
    14e6:	push   rbp
    14e7:	mov    rbp,rsp
    14ea:	mov    rsi,QWORD PTR [rdx]
    14ed:	mov    r8,QWORD PTR [rdx+0x8]
    14f1:	mov    rcx,QWORD PTR [rdx+0x10]
    14f5:	sar    rsi,1
    14f8:	mov    rdx,r8
    14fb:	call   1500 <botlish_entry_16+0x1a>
			14fc: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain?<int>
    1500:	mov    rsp,rbp
    1503:	pop    rbp
    1504:	ret

0000000000001505 <botlish_fn_17: web::is_unreserved<int>>:
    1505:	push   rbp
    1506:	mov    rbp,rsp
    1509:	sub    rsp,0x10
    150d:	mov    QWORD PTR [rsp],rbx
    1511:	mov    QWORD PTR [rsp+0x8],r14
    1516:	mov    r14,rsi
    1519:	mov    rsi,r14
    151c:	sar    rsi,1
    151f:	mov    rbx,rdi
    1522:	call   1527 <botlish_fn_17+0x22>
			1523: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphanumeric<int>
    1527:	cmp    rax,0x6
    152b:	je     1562 <botlish_fn_17+0x5d>
    1531:	mov    rax,QWORD PTR [rbx+0x30]
    1535:	mov    rsi,QWORD PTR [rax+0x10]
    1539:	mov    rdx,r14
    153c:	mov    rdi,rbx
    153f:	call   1544 <botlish_fn_17+0x3f>
			1540: R_X86_64_PLT32	rt_set_contains-0x4
    1544:	cmp    rax,0x6
    1548:	je     1558 <botlish_fn_17+0x53>
    154e:	mov    eax,0x2
    1553:	jmp    1567 <botlish_fn_17+0x62>
    1558:	mov    eax,0x6
    155d:	jmp    1567 <botlish_fn_17+0x62>
    1562:	mov    eax,0x6
    1567:	mov    rbx,QWORD PTR [rsp]
    156b:	mov    r14,QWORD PTR [rsp+0x8]
    1570:	add    rsp,0x10
    1574:	mov    rsp,rbp
    1577:	pop    rbp
    1578:	ret

0000000000001579 <botlish_entry_17: web::is_unreserved<int>>:
    1579:	push   rbp
    157a:	mov    rbp,rsp
    157d:	mov    rsi,QWORD PTR [rdx]
    1580:	call   1585 <botlish_entry_17+0xc>
			1581: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<int>
    1585:	mov    rsp,rbp
    1588:	pop    rbp
    1589:	ret

000000000000158a <botlish_fn_18: web::uri_escape_text<str>>:
    158a:	push   rbp
    158b:	mov    rbp,rsp
    158e:	sub    rsp,0x10
    1592:	mov    edx,0x1
    1597:	mov    QWORD PTR [rsp],0x1
    159f:	mov    r10,QWORD PTR [rdi+0x10]
    15a3:	mov    rcx,QWORD PTR [r10+0xd0]
    15aa:	mov    QWORD PTR [rsp+0x8],rcx
    15af:	call   15b4 <botlish_fn_18+0x2a>
			15b0: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_from<str, int, str>
    15b4:	test   rax,rax
    15b7:	jne    15c9 <botlish_fn_18+0x3f>
    15bd:	xor    rax,rax
    15c0:	add    rsp,0x10
    15c4:	mov    rsp,rbp
    15c7:	pop    rbp
    15c8:	ret
    15c9:	add    rsp,0x10
    15cd:	mov    rsp,rbp
    15d0:	pop    rbp
    15d1:	ret

00000000000015d2 <botlish_entry_18: web::uri_escape_text<str>>:
    15d2:	push   rbp
    15d3:	mov    rbp,rsp
    15d6:	sub    rsp,0x10
    15da:	mov    QWORD PTR [rsp],r12
    15de:	mov    r12,rdi
    15e1:	mov    rsi,QWORD PTR [rdx]
    15e4:	mov    r8,QWORD PTR [rip+0x0]        # 15eb <botlish_entry_18+0x19>
			15e7: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    15eb:	call   r8
    15ee:	mov    rsi,rax
    15f1:	mov    rdi,r12
    15f4:	call   15f9 <botlish_entry_18+0x27>
			15f5: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::uri_escape_text<str>
    15f9:	mov    r12,QWORD PTR [rsp]
    15fd:	add    rsp,0x10
    1601:	mov    rsp,rbp
    1604:	pop    rbp
    1605:	ret

0000000000001606 <botlish_fn_19: high_nibble<int>>:
    1606:	push   rbp
    1607:	mov    rbp,rsp
    160a:	sub    rsp,0x10
    160e:	mov    QWORD PTR [rsp],rsi
    1612:	mov    QWORD PTR [rsp+0x8],0x1e1
    161b:	test   rsi,0x1
    1622:	jne    1637 <botlish_fn_19+0x31>
    1628:	mov    edx,0x1e1
    162d:	call   1632 <botlish_fn_19+0x2c>
			162e: R_X86_64_PLT32	rt_int_and-0x4
    1632:	jmp    1641 <botlish_fn_19+0x3b>
    1637:	and    rsi,0x1e1
    163e:	mov    rax,rsi
    1641:	sar    rax,0x5
    1645:	shl    rax,1
    1648:	or     rax,0x1
    164c:	add    rsp,0x10
    1650:	mov    rsp,rbp
    1653:	pop    rbp
    1654:	ret

0000000000001655 <botlish_entry_19: high_nibble<int>>:
    1655:	push   rbp
    1656:	mov    rbp,rsp
    1659:	mov    rsi,QWORD PTR [rdx]
    165c:	call   1661 <botlish_entry_19+0xc>
			165d: R_X86_64_PLT32	botlish_fn_19-0x4 ; high_nibble<int>
    1661:	mov    rsp,rbp
    1664:	pop    rbp
    1665:	ret

0000000000001666 <botlish_fn_20: hex_pair<int>>:
    1666:	push   rbp
    1667:	mov    rbp,rsp
    166a:	sub    rsp,0x50
    166e:	mov    QWORD PTR [rsp+0x30],rbx
    1673:	mov    QWORD PTR [rsp+0x38],r12
    1678:	mov    QWORD PTR [rsp+0x40],r13
    167d:	mov    QWORD PTR [rsp+0x48],r14
    1682:	mov    QWORD PTR [rsp],rsi
    1686:	mov    r12,rsi
    1689:	mov    rax,QWORD PTR [rdi+0x30]
    168d:	mov    rbx,rdi
    1690:	mov    rsi,QWORD PTR [rax+0x8]
    1694:	mov    QWORD PTR [rsp+0x8],rsi
    1699:	mov    r13,rsi
    169c:	mov    rsi,r12
    169f:	call   16a4 <botlish_fn_20+0x3e>
			16a0: R_X86_64_PLT32	botlish_fn_19-0x4 ; high_nibble<int>
    16a4:	test   rax,0x1
    16aa:	jne    16bb <botlish_fn_20+0x55>
    16b0:	mov    rdx,rax
    16b3:	mov    rsi,r13
    16b6:	jmp    16d4 <botlish_fn_20+0x6e>
    16bb:	mov    rsi,r13
    16be:	mov    rdx,QWORD PTR [rsi+0x8]
    16c2:	mov    rcx,rax
    16c5:	sar    rcx,1
    16c8:	cmp    rcx,rdx
    16cb:	jb     16ea <botlish_fn_20+0x84>
    16d1:	mov    rdx,rax
    16d4:	mov    rdi,rbx
    16d7:	call   16dc <botlish_fn_20+0x76>
			16d8: R_X86_64_PLT32	rt_list_get-0x4
    16dc:	test   rax,rax
    16df:	je     17af <botlish_fn_20+0x149>
    16e5:	jmp    16f2 <botlish_fn_20+0x8c>
    16ea:	mov    rax,QWORD PTR [rsi+0x10]
    16ee:	mov    rax,QWORD PTR [rax+rcx*8]
    16f2:	mov    QWORD PTR [rsp],rax
    16f6:	mov    rdi,rbx
    16f9:	mov    r14,rax
    16fc:	mov    rax,QWORD PTR [rdi+0x30]
    1700:	mov    rsi,QWORD PTR [rax+0x8]
    1704:	mov    r13,rsi
    1707:	mov    edx,0x21
    170c:	mov    rsi,r12
    170f:	call   1714 <botlish_fn_20+0xae>
			1710: R_X86_64_PLT32	rt_int_mod-0x4
    1714:	test   rax,rax
    1717:	je     17af <botlish_fn_20+0x149>
    171d:	test   rax,0x1
    1723:	jne    1734 <botlish_fn_20+0xce>
    1729:	mov    rdx,rax
    172c:	mov    rsi,r13
    172f:	jmp    174d <botlish_fn_20+0xe7>
    1734:	mov    rsi,r13
    1737:	mov    rdx,QWORD PTR [rsi+0x8]
    173b:	mov    rcx,rax
    173e:	sar    rcx,1
    1741:	cmp    rcx,rdx
    1744:	jb     1763 <botlish_fn_20+0xfd>
    174a:	mov    rdx,rax
    174d:	mov    rdi,rbx
    1750:	call   1755 <botlish_fn_20+0xef>
			1751: R_X86_64_PLT32	rt_list_get-0x4
    1755:	test   rax,rax
    1758:	je     17af <botlish_fn_20+0x149>
    175e:	jmp    176b <botlish_fn_20+0x105>
    1763:	mov    rax,QWORD PTR [rsi+0x10]
    1767:	mov    rax,QWORD PTR [rax+rcx*8]
    176b:	mov    QWORD PTR [rsp+0x8],rax
    1770:	lea    rcx,[rsp+0x10]
    1775:	mov    QWORD PTR [rsp+0x10],0x0
    177e:	mov    rdx,r14
    1781:	mov    QWORD PTR [rsp+0x18],rdx
    1786:	mov    QWORD PTR [rsp+0x20],0x0
    178f:	mov    QWORD PTR [rsp+0x28],rax
    1794:	mov    esi,0x2
    1799:	mov    edx,0x4
    179e:	mov    rdi,rbx
    17a1:	call   17a6 <botlish_fn_20+0x140>
			17a2: R_X86_64_PLT32	rt_construct-0x4
    17a6:	test   rax,rax
    17a9:	jne    17cf <botlish_fn_20+0x169>
    17af:	xor    rax,rax
    17b2:	mov    rbx,QWORD PTR [rsp+0x30]
    17b7:	mov    r12,QWORD PTR [rsp+0x38]
    17bc:	mov    r13,QWORD PTR [rsp+0x40]
    17c1:	mov    r14,QWORD PTR [rsp+0x48]
    17c6:	add    rsp,0x50
    17ca:	mov    rsp,rbp
    17cd:	pop    rbp
    17ce:	ret
    17cf:	mov    rbx,QWORD PTR [rsp+0x30]
    17d4:	mov    r12,QWORD PTR [rsp+0x38]
    17d9:	mov    r13,QWORD PTR [rsp+0x40]
    17de:	mov    r14,QWORD PTR [rsp+0x48]
    17e3:	add    rsp,0x50
    17e7:	mov    rsp,rbp
    17ea:	pop    rbp
    17eb:	ret

00000000000017ec <botlish_entry_20: hex_pair<int>>:
    17ec:	push   rbp
    17ed:	mov    rbp,rsp
    17f0:	sub    rsp,0x10
    17f4:	mov    QWORD PTR [rsp],r12
    17f8:	mov    r12,rdi
    17fb:	mov    rsi,QWORD PTR [rdx]
    17fe:	call   1803 <botlish_entry_20+0x17>
			17ff: R_X86_64_PLT32	botlish_fn_20-0x4 ; hex_pair<int>
    1803:	mov    r8,QWORD PTR [rip+0x0]        # 180a <botlish_entry_20+0x1e>
			1806: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    180a:	mov    rsi,rax
    180d:	mov    rdi,r12
    1810:	call   r8
    1813:	mov    r12,QWORD PTR [rsp]
    1817:	add    rsp,0x10
    181b:	mov    rsp,rbp
    181e:	pop    rbp
    181f:	ret

0000000000001820 <botlish_fn_21: esc_bytes<List[int], int, str>>:
    1820:	push   rbp
    1821:	mov    rbp,rsp
    1824:	sub    rsp,0xa0
    182b:	mov    QWORD PTR [rsp+0x70],rbx
    1830:	mov    QWORD PTR [rsp+0x78],r12
    1835:	mov    QWORD PTR [rsp+0x80],r13
    183d:	mov    QWORD PTR [rsp+0x88],r14
    1845:	mov    QWORD PTR [rsp+0x90],r15
    184d:	mov    QWORD PTR [rsp+0x20],0x0
    1856:	mov    QWORD PTR [rsp],rsi
    185a:	mov    QWORD PTR [rsp+0x8],rdx
    185f:	mov    r14,rdx
    1862:	mov    QWORD PTR [rsp+0x10],rcx
    1867:	lea    r13,[rsp+0x28]
    186c:	mov    rbx,rdi
    186f:	mov    r12,rsi
    1872:	mov    QWORD PTR [rsp+0x58],rcx
    1877:	mov    rsi,r12
    187a:	mov    rdi,rbx
    187d:	call   1882 <botlish_fn_21+0x62>
			187e: R_X86_64_PLT32	rt_list_len-0x4
    1882:	mov    rcx,r14
    1885:	and    rcx,rax
    1888:	mov    rdx,rax
    188b:	test   rcx,0x1
    1892:	jne    18b8 <botlish_fn_21+0x98>
    1898:	mov    rsi,r14
    189b:	mov    rdi,rbx
    189e:	call   18a3 <botlish_fn_21+0x83>
			189f: R_X86_64_PLT32	rt_int_cmp-0x4
    18a3:	mov    ecx,0x2
    18a8:	test   rax,rax
    18ab:	cmovge rcx,QWORD PTR [rip+0x1cd]        # 1a80 <botlish_fn_21+0x260>
    18b3:	jmp    18c8 <botlish_fn_21+0xa8>
    18b8:	mov    ecx,0x2
    18bd:	cmp    r14,rdx
    18c0:	cmovge rcx,QWORD PTR [rip+0x1b8]        # 1a80 <botlish_fn_21+0x260>
    18c8:	cmp    rcx,0x6
    18cc:	je     18dc <botlish_fn_21+0xbc>
    18d2:	mov    eax,0x2
    18d7:	jmp    18e1 <botlish_fn_21+0xc1>
    18dc:	mov    eax,0x6
    18e1:	cmp    rax,0x6
    18e5:	je     1a4a <botlish_fn_21+0x22a>
    18eb:	mov    QWORD PTR [rsp+0x18],0x3
    18f4:	test   r14,0x1
    18fb:	je     1913 <botlish_fn_21+0xf3>
    1901:	mov    rax,r14
    1904:	add    rax,0x2
    1908:	seto   cl
    190b:	test   cl,cl
    190d:	je     1923 <botlish_fn_21+0x103>
    1913:	mov    edx,0x3
    1918:	mov    rsi,r14
    191b:	mov    rdi,rbx
    191e:	call   1923 <botlish_fn_21+0x103>
			191f: R_X86_64_PLT32	rt_int_add-0x4
    1923:	mov    QWORD PTR [rsp+0x8],rax
    1928:	mov    QWORD PTR [rsp+0x60],rax
    192d:	mov    rcx,QWORD PTR [rbx+0x10]
    1931:	mov    r15,QWORD PTR [rcx+0x10]
    1935:	mov    QWORD PTR [rsp+0x18],r15
    193a:	test   r14,0x1
    1941:	jne    194f <botlish_fn_21+0x12f>
    1947:	mov    rdx,r14
    194a:	jmp    1966 <botlish_fn_21+0x146>
    194f:	mov    rdi,QWORD PTR [r12+0x8]
    1954:	mov    rsi,r14
    1957:	sar    rsi,1
    195a:	cmp    rsi,rdi
    195d:	jb     1982 <botlish_fn_21+0x162>
    1963:	mov    rdx,r14
    1966:	mov    rsi,r12
    1969:	mov    rdi,rbx
    196c:	call   1971 <botlish_fn_21+0x151>
			196d: R_X86_64_PLT32	rt_list_get-0x4
    1971:	test   rax,rax
    1974:	je     19f9 <botlish_fn_21+0x1d9>
    197a:	mov    rsi,rax
    197d:	jmp    198b <botlish_fn_21+0x16b>
    1982:	mov    rax,QWORD PTR [r12+0x10]
    1987:	mov    rsi,QWORD PTR [rax+rsi*8]
    198b:	mov    QWORD PTR [rsp+0x20],rsi
    1990:	mov    rdi,rbx
    1993:	call   1998 <botlish_fn_21+0x178>
			1994: R_X86_64_PLT32	botlish_fn_20-0x4 ; hex_pair<int>
    1998:	test   rax,rax
    199b:	je     19f9 <botlish_fn_21+0x1d9>
    19a1:	mov    QWORD PTR [rsp+0x20],rax
    19a6:	mov    rcx,rax
    19a9:	mov    QWORD PTR [rsp+0x28],0x0
    19b2:	mov    rax,QWORD PTR [rsp+0x58]
    19b7:	mov    QWORD PTR [rsp+0x30],rax
    19bc:	mov    QWORD PTR [rsp+0x38],0x0
    19c5:	mov    QWORD PTR [rsp+0x40],r15
    19ca:	mov    QWORD PTR [rsp+0x48],0x0
    19d3:	mov    rax,rcx
    19d6:	mov    QWORD PTR [rsp+0x50],rax
    19db:	mov    esi,0x2
    19e0:	mov    edx,0x6
    19e5:	mov    rcx,r13
    19e8:	mov    rdi,rbx
    19eb:	call   19f0 <botlish_fn_21+0x1d0>
			19ec: R_X86_64_PLT32	rt_construct-0x4
    19f0:	test   rax,rax
    19f3:	jne    1a2a <botlish_fn_21+0x20a>
    19f9:	xor    rax,rax
    19fc:	mov    rbx,QWORD PTR [rsp+0x70]
    1a01:	mov    r12,QWORD PTR [rsp+0x78]
    1a06:	mov    r13,QWORD PTR [rsp+0x80]
    1a0e:	mov    r14,QWORD PTR [rsp+0x88]
    1a16:	mov    r15,QWORD PTR [rsp+0x90]
    1a1e:	add    rsp,0xa0
    1a25:	mov    rsp,rbp
    1a28:	pop    rbp
    1a29:	ret
    1a2a:	mov    QWORD PTR [rsp],r12
    1a2e:	mov    rsi,QWORD PTR [rsp+0x60]
    1a33:	mov    QWORD PTR [rsp+0x8],rsi
    1a38:	mov    QWORD PTR [rsp+0x10],rax
    1a3d:	mov    r14,rsi
    1a40:	mov    QWORD PTR [rsp+0x58],rax
    1a45:	jmp    1877 <botlish_fn_21+0x57>
    1a4a:	mov    rax,QWORD PTR [rsp+0x58]
    1a4f:	mov    rbx,QWORD PTR [rsp+0x70]
    1a54:	mov    r12,QWORD PTR [rsp+0x78]
    1a59:	mov    r13,QWORD PTR [rsp+0x80]
    1a61:	mov    r14,QWORD PTR [rsp+0x88]
    1a69:	mov    r15,QWORD PTR [rsp+0x90]
    1a71:	add    rsp,0xa0
    1a78:	mov    rsp,rbp
    1a7b:	pop    rbp
    1a7c:	ret
    1a7d:	add    BYTE PTR [rax],al
    1a7f:	add    BYTE PTR [rsi],al
    1a81:	add    BYTE PTR [rax],al
    1a83:	add    BYTE PTR [rax],al
    1a85:	add    BYTE PTR [rax],al
	...

0000000000001a88 <botlish_entry_21: esc_bytes<List[int], int, str>>:
    1a88:	push   rbp
    1a89:	mov    rbp,rsp
    1a8c:	sub    rsp,0x10
    1a90:	mov    QWORD PTR [rsp],r12
    1a94:	mov    r12,rdi
    1a97:	mov    rsi,QWORD PTR [rdx]
    1a9a:	mov    r8,QWORD PTR [rdx+0x8]
    1a9e:	mov    rcx,QWORD PTR [rdx+0x10]
    1aa2:	mov    rdx,r8
    1aa5:	call   1aaa <botlish_entry_21+0x22>
			1aa6: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_bytes<List[int], int, str>
    1aaa:	mov    r8,QWORD PTR [rip+0x0]        # 1ab1 <botlish_entry_21+0x29>
			1aad: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1ab1:	mov    rsi,rax
    1ab4:	mov    rdi,r12
    1ab7:	call   r8
    1aba:	mov    r12,QWORD PTR [rsp]
    1abe:	add    rsp,0x10
    1ac2:	mov    rsp,rbp
    1ac5:	pop    rbp
    1ac6:	ret

0000000000001ac7 <botlish_fn_22: esc_char<str>>:
    1ac7:	push   rbp
    1ac8:	mov    rbp,rsp
    1acb:	sub    rsp,0x40
    1acf:	mov    QWORD PTR [rsp+0x20],rbx
    1ad4:	mov    QWORD PTR [rsp+0x28],r12
    1ad9:	mov    QWORD PTR [rsp+0x30],r13
    1ade:	mov    rbx,rdi
    1ae1:	mov    QWORD PTR [rsp+0x8],0x0
    1aea:	mov    QWORD PTR [rsp+0x10],0x0
    1af3:	mov    QWORD PTR [rsp],rsi
    1af7:	mov    r13,rsi
    1afa:	mov    rsi,r13
    1afd:	mov    rdi,rbx
    1b00:	call   1b05 <botlish_fn_22+0x3e>
			1b01: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1b05:	mov    rcx,rax
    1b08:	mov    r12,rax
    1b0b:	test   rax,rcx
    1b0e:	je     1bec <botlish_fn_22+0x125>
    1b14:	mov    rax,r12
    1b17:	mov    QWORD PTR [rsp],rax
    1b1b:	mov    rsi,r12
    1b1e:	mov    rdi,rbx
    1b21:	call   1b26 <botlish_fn_22+0x5f>
			1b22: R_X86_64_PLT32	rt_list_len-0x4
    1b26:	sar    rax,1
    1b29:	cmp    rax,0x1
    1b2d:	je     1b6a <botlish_fn_22+0xa3>
    1b33:	mov    edx,0x1
    1b38:	mov    QWORD PTR [rsp+0x8],0x1
    1b41:	mov    rdi,rbx
    1b44:	mov    rax,QWORD PTR [rdi+0x10]
    1b48:	mov    rcx,QWORD PTR [rax+0xd0]
    1b4f:	mov    QWORD PTR [rsp+0x10],rcx
    1b54:	mov    rsi,r12
    1b57:	call   1b5c <botlish_fn_22+0x95>
			1b58: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_bytes<List[int], int, str>
    1b5c:	test   rax,rax
    1b5f:	je     1bec <botlish_fn_22+0x125>
    1b65:	jmp    1c0d <botlish_fn_22+0x146>
    1b6a:	mov    rsi,r12
    1b6d:	mov    rax,QWORD PTR [rsi+0x8]
    1b71:	mov    r12,rsi
    1b74:	test   rax,rax
    1b77:	jne    1b9e <botlish_fn_22+0xd7>
    1b7d:	mov    edx,0x1
    1b82:	mov    rsi,r12
    1b85:	mov    rdi,rbx
    1b88:	call   1b8d <botlish_fn_22+0xc6>
			1b89: R_X86_64_PLT32	rt_list_get-0x4
    1b8d:	test   rax,rax
    1b90:	je     1bec <botlish_fn_22+0x125>
    1b96:	mov    rsi,rax
    1b99:	jmp    1ba8 <botlish_fn_22+0xe1>
    1b9e:	mov    rsi,r12
    1ba1:	mov    rax,QWORD PTR [rsi+0x10]
    1ba5:	mov    rsi,QWORD PTR [rax]
    1ba8:	mov    rdi,rbx
    1bab:	call   1bb0 <botlish_fn_22+0xe9>
			1bac: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<int>
    1bb0:	cmp    rax,0x6
    1bb4:	je     1c0a <botlish_fn_22+0x143>
    1bba:	mov    edx,0x1
    1bbf:	mov    QWORD PTR [rsp+0x8],0x1
    1bc8:	mov    rdi,rbx
    1bcb:	mov    rax,QWORD PTR [rdi+0x10]
    1bcf:	mov    rcx,QWORD PTR [rax+0xd0]
    1bd6:	mov    QWORD PTR [rsp+0x10],rcx
    1bdb:	mov    rsi,r12
    1bde:	call   1be3 <botlish_fn_22+0x11c>
			1bdf: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_bytes<List[int], int, str>
    1be3:	test   rax,rax
    1be6:	jne    1c07 <botlish_fn_22+0x140>
    1bec:	xor    rax,rax
    1bef:	mov    rbx,QWORD PTR [rsp+0x20]
    1bf4:	mov    r12,QWORD PTR [rsp+0x28]
    1bf9:	mov    r13,QWORD PTR [rsp+0x30]
    1bfe:	add    rsp,0x40
    1c02:	mov    rsp,rbp
    1c05:	pop    rbp
    1c06:	ret
    1c07:	mov    r13,rax
    1c0a:	mov    rax,r13
    1c0d:	mov    rbx,QWORD PTR [rsp+0x20]
    1c12:	mov    r12,QWORD PTR [rsp+0x28]
    1c17:	mov    r13,QWORD PTR [rsp+0x30]
    1c1c:	add    rsp,0x40
    1c20:	mov    rsp,rbp
    1c23:	pop    rbp
    1c24:	ret

0000000000001c25 <botlish_entry_22: esc_char<str>>:
    1c25:	push   rbp
    1c26:	mov    rbp,rsp
    1c29:	sub    rsp,0x10
    1c2d:	mov    QWORD PTR [rsp],r12
    1c31:	mov    r12,rdi
    1c34:	mov    rsi,QWORD PTR [rdx]
    1c37:	call   1c3c <botlish_entry_22+0x17>
			1c38: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_char<str>
    1c3c:	mov    r8,QWORD PTR [rip+0x0]        # 1c43 <botlish_entry_22+0x1e>
			1c3f: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1c43:	mov    rsi,rax
    1c46:	mov    rdi,r12
    1c49:	call   r8
    1c4c:	mov    r12,QWORD PTR [rsp]
    1c50:	add    rsp,0x10
    1c54:	mov    rsp,rbp
    1c57:	pop    rbp
    1c58:	ret
    1c59:	add    BYTE PTR [rax],al
    1c5b:	add    BYTE PTR [rax],al
    1c5d:	add    BYTE PTR [rax],al
	...

0000000000001c60 <botlish_fn_23: esc_from<str, int, str>>:
    1c60:	push   rbp
    1c61:	mov    rbp,rsp
    1c64:	sub    rsp,0xa0
    1c6b:	mov    QWORD PTR [rsp+0x70],rbx
    1c70:	mov    QWORD PTR [rsp+0x78],r12
    1c75:	mov    QWORD PTR [rsp+0x80],r13
    1c7d:	mov    QWORD PTR [rsp+0x88],r14
    1c85:	mov    QWORD PTR [rsp+0x90],r15
    1c8d:	mov    r13,rdi
    1c90:	mov    QWORD PTR [rsp+0x10],0x0
    1c99:	mov    QWORD PTR [rsp+0x18],0x0
    1ca2:	mov    QWORD PTR [rsp+0x20],0x0
    1cab:	mov    QWORD PTR [rsp],rdx
    1caf:	mov    QWORD PTR [rsp+0x8],rcx
    1cb4:	mov    QWORD PTR [rsp+0x58],rcx
    1cb9:	mov    r12d,0x47
    1cbf:	mov    rcx,0xffffffffffffffff
    1cc6:	bsr    rax,rsi
    1cca:	mov    r15,rsi
    1ccd:	cmove  rax,rcx
    1cd1:	mov    ecx,0x3f
    1cd6:	sub    rcx,rax
    1cd9:	sub    r12,rcx
    1cdc:	shr    r12,0x3
    1ce0:	shl    r12,1
    1ce3:	lea    rbx,[rsp+0x38]
    1ce8:	mov    rax,r12
    1ceb:	or     rax,0x1
    1cef:	mov    r14,rdx
    1cf2:	mov    rcx,r14
    1cf5:	and    rcx,rax
    1cf8:	test   rcx,0x1
    1cff:	jne    1d2c <botlish_fn_23+0xcc>
    1d05:	mov    rdx,r12
    1d08:	or     rdx,0x1
    1d0c:	mov    rsi,r14
    1d0f:	mov    rdi,r13
    1d12:	call   1d17 <botlish_fn_23+0xb7>
			1d13: R_X86_64_PLT32	rt_int_cmp-0x4
    1d17:	mov    ecx,0x2
    1d1c:	test   rax,rax
    1d1f:	cmovge rcx,QWORD PTR [rip+0x1f9]        # 1f20 <botlish_fn_23+0x2c0>
    1d27:	jmp    1d43 <botlish_fn_23+0xe3>
    1d2c:	mov    rax,r12
    1d2f:	or     rax,0x1
    1d33:	mov    ecx,0x2
    1d38:	cmp    r14,rax
    1d3b:	cmovge rcx,QWORD PTR [rip+0x1dd]        # 1f20 <botlish_fn_23+0x2c0>
    1d43:	cmp    rcx,0x6
    1d47:	je     1d57 <botlish_fn_23+0xf7>
    1d4d:	mov    eax,0x2
    1d52:	jmp    1d5c <botlish_fn_23+0xfc>
    1d57:	mov    eax,0x6
    1d5c:	cmp    rax,0x6
    1d60:	je     1e8c <botlish_fn_23+0x22c>
    1d66:	mov    QWORD PTR [rsp+0x10],0x3
    1d6f:	test   r14,0x1
    1d76:	je     1d8e <botlish_fn_23+0x12e>
    1d7c:	mov    rax,r14
    1d7f:	add    rax,0x2
    1d83:	seto   cl
    1d86:	test   cl,cl
    1d88:	je     1d9e <botlish_fn_23+0x13e>
    1d8e:	mov    edx,0x3
    1d93:	mov    rsi,r14
    1d96:	mov    rdi,r13
    1d99:	call   1d9e <botlish_fn_23+0x13e>
			1d9a: R_X86_64_PLT32	rt_int_add-0x4
    1d9e:	mov    QWORD PTR [rsp+0x10],rax
    1da3:	mov    QWORD PTR [rsp+0x60],rax
    1da8:	mov    rsi,r15
    1dab:	mov    rdi,r13
    1dae:	call   1db3 <botlish_fn_23+0x153>
			1daf: R_X86_64_PLT32	rt_ascii_to_str-0x4
    1db3:	mov    QWORD PTR [rsp+0x18],rax
    1db8:	mov    QWORD PTR [rsp+0x68],rax
    1dbd:	mov    QWORD PTR [rsp+0x20],0x3
    1dc6:	test   r14,0x1
    1dcd:	je     1de5 <botlish_fn_23+0x185>
    1dd3:	mov    rcx,r14
    1dd6:	add    rcx,0x2
    1dda:	seto   al
    1ddd:	test   al,al
    1ddf:	je     1df8 <botlish_fn_23+0x198>
    1de5:	mov    edx,0x3
    1dea:	mov    rsi,r14
    1ded:	mov    rdi,r13
    1df0:	call   1df5 <botlish_fn_23+0x195>
			1df1: R_X86_64_PLT32	rt_int_add-0x4
    1df5:	mov    rcx,rax
    1df8:	mov    QWORD PTR [rsp+0x20],rcx
    1dfd:	mov    rdx,r14
    1e00:	mov    rsi,QWORD PTR [rsp+0x68]
    1e05:	mov    rdi,r13
    1e08:	call   1e0d <botlish_fn_23+0x1ad>
			1e09: R_X86_64_PLT32	rt_substr-0x4
    1e0d:	test   rax,rax
    1e10:	je     1ec0 <botlish_fn_23+0x260>
    1e16:	mov    QWORD PTR [rsp],rax
    1e1a:	mov    rsi,rax
    1e1d:	mov    rdi,r13
    1e20:	call   1e25 <botlish_fn_23+0x1c5>
			1e21: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_char<str>
    1e25:	test   rax,rax
    1e28:	je     1ec0 <botlish_fn_23+0x260>
    1e2e:	mov    QWORD PTR [rsp],rax
    1e32:	mov    QWORD PTR [rsp+0x38],0x0
    1e3b:	mov    rcx,QWORD PTR [rsp+0x58]
    1e40:	mov    QWORD PTR [rsp+0x40],rcx
    1e45:	mov    QWORD PTR [rsp+0x48],0x0
    1e4e:	mov    QWORD PTR [rsp+0x50],rax
    1e53:	mov    esi,0x2
    1e58:	mov    edx,0x4
    1e5d:	mov    rcx,rbx
    1e60:	mov    rdi,r13
    1e63:	call   1e68 <botlish_fn_23+0x208>
			1e64: R_X86_64_PLT32	rt_construct-0x4
    1e68:	test   rax,rax
    1e6b:	je     1ec0 <botlish_fn_23+0x260>
    1e71:	mov    rcx,QWORD PTR [rsp+0x60]
    1e76:	mov    QWORD PTR [rsp],rcx
    1e7a:	mov    QWORD PTR [rsp+0x8],rax
    1e7f:	mov    rdx,rcx
    1e82:	mov    QWORD PTR [rsp+0x58],rax
    1e87:	jmp    1ce8 <botlish_fn_23+0x88>
    1e8c:	mov    rcx,QWORD PTR [rsp+0x58]
    1e91:	xor    rsi,rsi
    1e94:	lea    rax,[rsp+0x28]
    1e99:	mov    QWORD PTR [rsp+0x28],0x0
    1ea2:	mov    QWORD PTR [rsp+0x30],rcx
    1ea7:	mov    edx,0x2
    1eac:	mov    rcx,rax
    1eaf:	mov    rdi,r13
    1eb2:	call   1eb7 <botlish_fn_23+0x257>
			1eb3: R_X86_64_PLT32	rt_construct-0x4
    1eb7:	test   rax,rax
    1eba:	jne    1ef1 <botlish_fn_23+0x291>
    1ec0:	xor    rax,rax
    1ec3:	mov    rbx,QWORD PTR [rsp+0x70]
    1ec8:	mov    r12,QWORD PTR [rsp+0x78]
    1ecd:	mov    r13,QWORD PTR [rsp+0x80]
    1ed5:	mov    r14,QWORD PTR [rsp+0x88]
    1edd:	mov    r15,QWORD PTR [rsp+0x90]
    1ee5:	add    rsp,0xa0
    1eec:	mov    rsp,rbp
    1eef:	pop    rbp
    1ef0:	ret
    1ef1:	mov    rbx,QWORD PTR [rsp+0x70]
    1ef6:	mov    r12,QWORD PTR [rsp+0x78]
    1efb:	mov    r13,QWORD PTR [rsp+0x80]
    1f03:	mov    r14,QWORD PTR [rsp+0x88]
    1f0b:	mov    r15,QWORD PTR [rsp+0x90]
    1f13:	add    rsp,0xa0
    1f1a:	mov    rsp,rbp
    1f1d:	pop    rbp
    1f1e:	ret
    1f1f:	add    BYTE PTR [rsi],al
    1f21:	add    BYTE PTR [rax],al
    1f23:	add    BYTE PTR [rax],al
    1f25:	add    BYTE PTR [rax],al
	...

0000000000001f28 <botlish_entry_23: esc_from<str, int, str>>:
    1f28:	push   rbp
    1f29:	mov    rbp,rsp
    1f2c:	sub    rsp,0x10
    1f30:	mov    QWORD PTR [rsp],r12
    1f34:	mov    QWORD PTR [rsp+0x8],r13
    1f39:	mov    r12,rdi
    1f3c:	mov    rsi,QWORD PTR [rdx]
    1f3f:	mov    r13,rdx
    1f42:	mov    r8,QWORD PTR [rip+0x0]        # 1f49 <botlish_entry_23+0x21>
			1f45: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    1f49:	call   r8
    1f4c:	mov    rcx,r13
    1f4f:	mov    rdx,QWORD PTR [rcx+0x8]
    1f53:	mov    rcx,QWORD PTR [rcx+0x10]
    1f57:	mov    rsi,rax
    1f5a:	mov    rdi,r12
    1f5d:	call   1f62 <botlish_entry_23+0x3a>
			1f5e: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_from<str, int, str>
    1f62:	mov    r12,QWORD PTR [rsp]
    1f66:	mov    r13,QWORD PTR [rsp+0x8]
    1f6b:	add    rsp,0x10
    1f6f:	mov    rsp,rbp
    1f72:	pop    rbp
    1f73:	ret

0000000000001f74 <botlish_fn_24: check<int, int, str, str>>:
    1f74:	push   rbp
    1f75:	mov    rbp,rsp
    1f78:	sub    rsp,0x50
    1f7c:	mov    QWORD PTR [rsp+0x20],rbx
    1f81:	mov    QWORD PTR [rsp+0x28],r12
    1f86:	mov    QWORD PTR [rsp+0x30],r13
    1f8b:	mov    QWORD PTR [rsp+0x38],r14
    1f90:	mov    QWORD PTR [rsp+0x40],r15
    1f95:	mov    r14,rdi
    1f98:	mov    QWORD PTR [rsp+0x18],0x0
    1fa1:	mov    QWORD PTR [rsp],rdx
    1fa5:	mov    QWORD PTR [rsp+0x8],rcx
    1faa:	mov    QWORD PTR [rsp+0x10],r8
    1faf:	mov    r13,r8
    1fb2:	mov    r12,rsi
    1fb5:	mov    r15,rdx
    1fb8:	test   r12,r12
    1fbb:	jle    207d <botlish_fn_24+0x109>
    1fc1:	mov    rbx,rcx
    1fc4:	mov    rsi,rbx
    1fc7:	mov    rdi,r14
    1fca:	call   1fcf <botlish_fn_24+0x5b>
			1fcb: R_X86_64_PLT32	botlish_fn_8-0x4 ; web::emailish?<str>
    1fcf:	test   rax,rax
    1fd2:	jne    1ffd <botlish_fn_24+0x89>
    1fd8:	xor    rax,rax
    1fdb:	mov    rbx,QWORD PTR [rsp+0x20]
    1fe0:	mov    r12,QWORD PTR [rsp+0x28]
    1fe5:	mov    r13,QWORD PTR [rsp+0x30]
    1fea:	mov    r14,QWORD PTR [rsp+0x38]
    1fef:	mov    r15,QWORD PTR [rsp+0x40]
    1ff4:	add    rsp,0x50
    1ff8:	mov    rsp,rbp
    1ffb:	pop    rbp
    1ffc:	ret
    1ffd:	cmp    rax,0x6
    2001:	je     201d <botlish_fn_24+0xa9>
    2007:	mov    edx,0x1
    200c:	mov    QWORD PTR [rsp+0x18],0x1
    2015:	mov    rsi,r15
    2018:	jmp    202e <botlish_fn_24+0xba>
    201d:	mov    edx,0x3
    2022:	mov    QWORD PTR [rsp+0x18],0x3
    202b:	mov    rsi,r15
    202e:	mov    rax,rsi
    2031:	and    rax,rdx
    2034:	test   rax,0x1
    203a:	je     2055 <botlish_fn_24+0xe1>
    2040:	lea    rcx,[rdx-0x1]
    2044:	mov    rax,rsi
    2047:	add    rax,rcx
    204a:	seto   cl
    204d:	test   cl,cl
    204f:	je     205d <botlish_fn_24+0xe9>
    2055:	mov    rdi,r14
    2058:	call   205d <botlish_fn_24+0xe9>
			2059: R_X86_64_PLT32	rt_int_add-0x4
    205d:	mov    QWORD PTR [rsp],rax
    2061:	mov    QWORD PTR [rsp+0x8],rbx
    2066:	mov    r8,r13
    2069:	mov    QWORD PTR [rsp+0x10],r8
    206e:	sub    r12,0x1
    2072:	mov    rcx,rbx
    2075:	mov    r15,rax
    2078:	jmp    1fb8 <botlish_fn_24+0x44>
    207d:	mov    rax,r15
    2080:	mov    rbx,QWORD PTR [rsp+0x20]
    2085:	mov    r12,QWORD PTR [rsp+0x28]
    208a:	mov    r13,QWORD PTR [rsp+0x30]
    208f:	mov    r14,QWORD PTR [rsp+0x38]
    2094:	mov    r15,QWORD PTR [rsp+0x40]
    2099:	add    rsp,0x50
    209d:	mov    rsp,rbp
    20a0:	pop    rbp
    20a1:	ret

00000000000020a2 <botlish_entry_24: check<int, int, str, str>>:
    20a2:	push   rbp
    20a3:	mov    rbp,rsp
    20a6:	mov    rsi,QWORD PTR [rdx]
    20a9:	mov    r9,QWORD PTR [rdx+0x8]
    20ad:	mov    rcx,QWORD PTR [rdx+0x10]
    20b1:	mov    r8,QWORD PTR [rdx+0x18]
    20b5:	sar    rsi,1
    20b8:	mov    rdx,r9
    20bb:	call   20c0 <botlish_entry_24+0x1e>
			20bc: R_X86_64_PLT32	botlish_fn_24-0x4 ; check<int, int, str, str>
    20c0:	mov    rsp,rbp
    20c3:	pop    rbp
    20c4:	ret

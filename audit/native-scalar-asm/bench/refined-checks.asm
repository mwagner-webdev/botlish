; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 9089  (per function: 1443 39 289 609 74 74 74 125 125 379 262 222 176 238 440 456 468 1076 137 94 103 474 491 426 451 344)
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
     122:	je     504 <botlish_fn_0+0x504>
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
     366:	je     504 <botlish_fn_0+0x504>
     36c:	mov    rdi,QWORD PTR [rsp+0x158]
     374:	mov    r11,QWORD PTR [rdi+0x30]
     378:	mov    QWORD PTR [r11+0x8],rax
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
     3e4:	je     504 <botlish_fn_0+0x504>
     3ea:	mov    QWORD PTR [rsp],rax
     3ee:	mov    rsi,rax
     3f1:	mov    rdi,QWORD PTR [rsp+0x158]
     3f9:	call   3fe <botlish_fn_0+0x3fe>
			3fa: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::set<List[UnicodeChar]>
     3fe:	test   rax,rax
     401:	je     504 <botlish_fn_0+0x504>
     407:	mov    rdi,QWORD PTR [rsp+0x158]
     40f:	mov    rcx,QWORD PTR [rdi+0x30]
     413:	mov    QWORD PTR [rcx+0x10],rax
     417:	mov    rax,QWORD PTR [rdi+0x10]
     41b:	mov    rsi,QWORD PTR [rax+0xa8]
     422:	mov    QWORD PTR [rsp],rsi
     426:	call   42b <botlish_fn_0+0x42b>
			427: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_escape_text<str>
     42b:	test   rax,rax
     42e:	je     504 <botlish_fn_0+0x504>
     434:	mov    QWORD PTR [rsp],rax
     438:	mov    rbx,rax
     43b:	mov    esi,0x321
     440:	mov    QWORD PTR [rsp+0x8],0x321
     449:	mov    edx,0x1
     44e:	mov    QWORD PTR [rsp+0x10],0x1
     457:	mov    rdi,QWORD PTR [rsp+0x158]
     45f:	mov    rcx,QWORD PTR [rdi+0x10]
     463:	mov    rcx,QWORD PTR [rcx+0xb0]
     46a:	mov    QWORD PTR [rsp+0x18],rcx
     46f:	mov    r8,rbx
     472:	call   477 <botlish_fn_0+0x477>
			473: R_X86_64_PLT32	botlish_fn_25-0x4 ; check<int, int, str, str>
     477:	mov    r12,rax
     47a:	test   r12,r12
     47d:	je     504 <botlish_fn_0+0x504>
     483:	mov    QWORD PTR [rsp+0x8],r12
     488:	mov    esi,0x321
     48d:	mov    QWORD PTR [rsp+0x10],0x321
     496:	mov    edx,0x1
     49b:	mov    QWORD PTR [rsp+0x18],0x1
     4a4:	mov    rdi,QWORD PTR [rsp+0x158]
     4ac:	mov    rax,QWORD PTR [rdi+0x10]
     4b0:	mov    rcx,QWORD PTR [rax+0xb8]
     4b7:	mov    QWORD PTR [rsp+0x20],rcx
     4bc:	mov    r8,rbx
     4bf:	call   4c4 <botlish_fn_0+0x4c4>
			4c0: R_X86_64_PLT32	botlish_fn_25-0x4 ; check<int, int, str, str>
     4c4:	test   rax,rax
     4c7:	je     504 <botlish_fn_0+0x504>
     4cd:	mov    QWORD PTR [rsp],rax
     4d1:	lea    rdx,[rsp+0x148]
     4d9:	mov    QWORD PTR [rsp+0x148],r12
     4e1:	mov    QWORD PTR [rsp+0x150],rax
     4e9:	mov    esi,0x2
     4ee:	mov    rdi,QWORD PTR [rsp+0x158]
     4f6:	call   4fb <botlish_fn_0+0x4fb>
			4f7: R_X86_64_PLT32	rt_list_new-0x4
     4fb:	test   rax,rax
     4fe:	jne    53b <botlish_fn_0+0x53b>
     504:	xor    rax,rax
     507:	mov    rbx,QWORD PTR [rsp+0x180]
     50f:	mov    r12,QWORD PTR [rsp+0x188]
     517:	mov    r13,QWORD PTR [rsp+0x190]
     51f:	mov    r14,QWORD PTR [rsp+0x198]
     527:	mov    r15,QWORD PTR [rsp+0x1a0]
     52f:	add    rsp,0x1b0
     536:	mov    rsp,rbp
     539:	pop    rbp
     53a:	ret
     53b:	mov    rbx,QWORD PTR [rsp+0x180]
     543:	mov    r12,QWORD PTR [rsp+0x188]
     54b:	mov    r13,QWORD PTR [rsp+0x190]
     553:	mov    r14,QWORD PTR [rsp+0x198]
     55b:	mov    r15,QWORD PTR [rsp+0x1a0]
     563:	add    rsp,0x1b0
     56a:	mov    rsp,rbp
     56d:	pop    rbp
     56e:	ret

000000000000056f <botlish_entry_0: <program entry>>:
     56f:	push   rbp
     570:	mov    rbp,rsp
     573:	call   578 <botlish_entry_0+0x9>
			574: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     578:	mov    rsp,rbp
     57b:	pop    rbp
     57c:	ret

000000000000057d <botlish_fn_1: char::codepoint<UnicodeChar>>:
     57d:	push   rbp
     57e:	mov    rbp,rsp
     581:	call   586 <botlish_fn_1+0x9>
			582: R_X86_64_PLT32	rt_char_codepoint-0x4
     586:	mov    rsp,rbp
     589:	pop    rbp
     58a:	ret

000000000000058b <botlish_entry_1: char::codepoint<UnicodeChar>>:
     58b:	push   rbp
     58c:	mov    rbp,rsp
     58f:	mov    rsi,QWORD PTR [rdx]
     592:	call   597 <botlish_entry_1+0xc>
			593: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     597:	mov    rsp,rbp
     59a:	pop    rbp
     59b:	ret
     59c:	add    BYTE PTR [rax],al
	...

00000000000005a0 <botlish_fn_2: byte::from_int<int>>:
     5a0:	push   rbp
     5a1:	mov    rbp,rsp
     5a4:	sub    rsp,0x10
     5a8:	mov    QWORD PTR [rsp],rbx
     5ac:	mov    QWORD PTR [rsp+0x8],r12
     5b1:	mov    r12,rdi
     5b4:	test   rsi,0x1
     5bb:	mov    rax,rsi
     5be:	jne    5ed <botlish_fn_2+0x4d>
     5c4:	mov    edx,0x1
     5c9:	mov    rbx,rax
     5cc:	mov    rsi,rbx
     5cf:	mov    rdi,r12
     5d2:	call   5d7 <botlish_fn_2+0x37>
			5d3: R_X86_64_PLT32	rt_int_cmp-0x4
     5d7:	mov    r8d,0x2
     5dd:	test   rax,rax
     5e0:	cmovl  r8,QWORD PTR [rip+0xb0]        # 698 <botlish_fn_2+0xf8>
     5e8:	jmp    601 <botlish_fn_2+0x61>
     5ed:	mov    rbx,rax
     5f0:	mov    r8d,0x2
     5f6:	test   rbx,rbx
     5f9:	cmovle r8,QWORD PTR [rip+0x97]        # 698 <botlish_fn_2+0xf8>
     601:	test   rbx,0x1
     608:	jne    633 <botlish_fn_2+0x93>
     60e:	mov    edx,0x1ff
     613:	mov    rsi,rbx
     616:	mov    rdi,r12
     619:	call   61e <botlish_fn_2+0x7e>
			61a: R_X86_64_PLT32	rt_int_cmp-0x4
     61e:	mov    ecx,0x2
     623:	test   rax,rax
     626:	cmovg  rcx,QWORD PTR [rip+0x6a]        # 698 <botlish_fn_2+0xf8>
     62e:	jmp    647 <botlish_fn_2+0xa7>
     633:	mov    ecx,0x2
     638:	cmp    rbx,0x1ff
     63f:	cmovg  rcx,QWORD PTR [rip+0x51]        # 698 <botlish_fn_2+0xf8>
     647:	cmp    rcx,0x6
     64b:	je     666 <botlish_fn_2+0xc6>
     651:	mov    rax,rbx
     654:	mov    rbx,QWORD PTR [rsp]
     658:	mov    r12,QWORD PTR [rsp+0x8]
     65d:	add    rsp,0x10
     661:	mov    rsp,rbp
     664:	pop    rbp
     665:	ret
     666:	mov    rdi,r12
     669:	mov    rax,QWORD PTR [rdi+0x10]
     66d:	mov    rdx,QWORD PTR [rax+0xc0]
     674:	mov    esi,0x1
     679:	call   67e <botlish_fn_2+0xde>
			67a: R_X86_64_PLT32	rt_fail_declared-0x4
     67e:	xor    rax,rax
     681:	mov    rbx,QWORD PTR [rsp]
     685:	mov    r12,QWORD PTR [rsp+0x8]
     68a:	add    rsp,0x10
     68e:	mov    rsp,rbp
     691:	pop    rbp
     692:	ret
     693:	add    BYTE PTR [rax],al
     695:	add    BYTE PTR [rax],al
     697:	add    BYTE PTR [rsi],al
     699:	add    BYTE PTR [rax],al
     69b:	add    BYTE PTR [rax],al
     69d:	add    BYTE PTR [rax],al
	...

00000000000006a0 <botlish_entry_2: byte::from_int<int>>:
     6a0:	push   rbp
     6a1:	mov    rbp,rsp
     6a4:	mov    rsi,QWORD PTR [rdx]
     6a7:	call   6ac <botlish_entry_2+0xc>
			6a8: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     6ac:	mov    rsp,rbp
     6af:	pop    rbp
     6b0:	ret
     6b1:	add    BYTE PTR [rax],al
     6b3:	add    BYTE PTR [rax],al
     6b5:	add    BYTE PTR [rax],al
	...

00000000000006b8 <botlish_fn_3: byte::set<List[UnicodeChar]>>:
     6b8:	push   rbp
     6b9:	mov    rbp,rsp
     6bc:	sub    rsp,0x60
     6c0:	mov    QWORD PTR [rsp+0x30],rbx
     6c5:	mov    QWORD PTR [rsp+0x38],r12
     6ca:	mov    QWORD PTR [rsp+0x40],r13
     6cf:	mov    QWORD PTR [rsp+0x48],r14
     6d4:	mov    QWORD PTR [rsp+0x50],r15
     6d9:	mov    r13,rdi
     6dc:	mov    QWORD PTR [rsp+0x18],0x0
     6e5:	mov    QWORD PTR [rsp+0x20],0x0
     6ee:	mov    QWORD PTR [rsp],rsi
     6f2:	mov    rbx,rsi
     6f5:	mov    rdi,r13
     6f8:	call   6fd <botlish_fn_3+0x45>
			6f9: R_X86_64_PLT32	rt_list_len-0x4
     6fd:	mov    QWORD PTR [rsp+0x8],rax
     702:	mov    r12,rax
     705:	mov    QWORD PTR [rsp+0x10],0x1
     70e:	xor    rdx,rdx
     711:	mov    rdi,r13
     714:	mov    rsi,rdx
     717:	call   71c <botlish_fn_3+0x64>
			718: R_X86_64_PLT32	rt_list_new-0x4
     71c:	test   rax,rax
     71f:	je     840 <botlish_fn_3+0x188>
     725:	mov    QWORD PTR [rsp+0x18],rax
     72a:	mov    esi,0x1
     72f:	mov    r14,rsi
     732:	mov    r15,rax
     735:	mov    rax,rsi
     738:	and    rax,r12
     73b:	mov    r14,rsi
     73e:	test   rax,0x1
     744:	jne    76d <botlish_fn_3+0xb5>
     74a:	mov    rdx,r12
     74d:	mov    rsi,r14
     750:	mov    rdi,r13
     753:	call   758 <botlish_fn_3+0xa0>
			754: R_X86_64_PLT32	rt_int_cmp-0x4
     758:	mov    ecx,0x2
     75d:	test   rax,rax
     760:	cmovl  rcx,QWORD PTR [rip+0x170]        # 8d8 <botlish_fn_3+0x220>
     768:	jmp    780 <botlish_fn_3+0xc8>
     76d:	mov    ecx,0x2
     772:	mov    rsi,r14
     775:	cmp    rsi,r12
     778:	cmovl  rcx,QWORD PTR [rip+0x158]        # 8d8 <botlish_fn_3+0x220>
     780:	cmp    rcx,0x6
     784:	je     7bb <botlish_fn_3+0x103>
     78a:	mov    rsi,r15
     78d:	mov    QWORD PTR [rsp],rsi
     791:	mov    rdi,r13
     794:	call   799 <botlish_fn_3+0xe1>
			795: R_X86_64_PLT32	rt_set_from_list-0x4
     799:	mov    rbx,QWORD PTR [rsp+0x30]
     79e:	mov    r12,QWORD PTR [rsp+0x38]
     7a3:	mov    r13,QWORD PTR [rsp+0x40]
     7a8:	mov    r14,QWORD PTR [rsp+0x48]
     7ad:	mov    r15,QWORD PTR [rsp+0x50]
     7b2:	add    rsp,0x60
     7b6:	mov    rsp,rbp
     7b9:	pop    rbp
     7ba:	ret
     7bb:	mov    rsi,r14
     7be:	test   rsi,0x1
     7c5:	je     7e1 <botlish_fn_3+0x129>
     7cb:	mov    rcx,QWORD PTR [rbx+0x8]
     7cf:	mov    rsi,r14
     7d2:	mov    rax,rsi
     7d5:	sar    rax,1
     7d8:	cmp    rax,rcx
     7db:	jb     800 <botlish_fn_3+0x148>
     7e1:	mov    rdx,r14
     7e4:	mov    rsi,rbx
     7e7:	mov    rdi,r13
     7ea:	call   7ef <botlish_fn_3+0x137>
			7eb: R_X86_64_PLT32	rt_list_get-0x4
     7ef:	test   rax,rax
     7f2:	je     840 <botlish_fn_3+0x188>
     7f8:	mov    rsi,rax
     7fb:	jmp    808 <botlish_fn_3+0x150>
     800:	mov    rdx,QWORD PTR [rbx+0x10]
     804:	mov    rsi,QWORD PTR [rdx+rax*8]
     808:	mov    rdi,r13
     80b:	call   810 <botlish_fn_3+0x158>
			80c: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     810:	mov    rsi,rax
     813:	mov    rdi,r13
     816:	call   81b <botlish_fn_3+0x163>
			817: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     81b:	test   rax,rax
     81e:	je     840 <botlish_fn_3+0x188>
     824:	mov    QWORD PTR [rsp+0x20],rax
     829:	mov    rdx,rax
     82c:	mov    rsi,r15
     82f:	mov    rdi,r13
     832:	call   837 <botlish_fn_3+0x17f>
			833: R_X86_64_PLT32	rt_list_append-0x4
     837:	test   rax,rax
     83a:	jne    865 <botlish_fn_3+0x1ad>
     840:	xor    rax,rax
     843:	mov    rbx,QWORD PTR [rsp+0x30]
     848:	mov    r12,QWORD PTR [rsp+0x38]
     84d:	mov    r13,QWORD PTR [rsp+0x40]
     852:	mov    r14,QWORD PTR [rsp+0x48]
     857:	mov    r15,QWORD PTR [rsp+0x50]
     85c:	add    rsp,0x60
     860:	mov    rsp,rbp
     863:	pop    rbp
     864:	ret
     865:	mov    QWORD PTR [rsp+0x18],rax
     86a:	mov    r15,rax
     86d:	mov    edx,0x3
     872:	mov    QWORD PTR [rsp+0x20],0x3
     87b:	mov    rsi,r14
     87e:	test   rsi,0x1
     885:	jne    893 <botlish_fn_3+0x1db>
     88b:	mov    rsi,r14
     88e:	jmp    8bb <botlish_fn_3+0x203>
     893:	mov    rsi,r14
     896:	mov    rcx,rsi
     899:	add    rcx,0x2
     89d:	seto   al
     8a0:	test   al,al
     8a2:	je     8b0 <botlish_fn_3+0x1f8>
     8a8:	mov    rsi,r14
     8ab:	jmp    8bb <botlish_fn_3+0x203>
     8b0:	mov    rsi,rcx
     8b3:	mov    r14,rcx
     8b6:	jmp    8c9 <botlish_fn_3+0x211>
     8bb:	mov    rdi,r13
     8be:	call   8c3 <botlish_fn_3+0x20b>
			8bf: R_X86_64_PLT32	rt_int_add-0x4
     8c3:	mov    rsi,rax
     8c6:	mov    r14,rax
     8c9:	mov    QWORD PTR [rsp+0x10],rsi
     8ce:	mov    rsi,r14
     8d1:	jmp    735 <botlish_fn_3+0x7d>
     8d6:	add    BYTE PTR [rax],al
     8d8:	(bad)
     8d9:	add    BYTE PTR [rax],al
     8db:	add    BYTE PTR [rax],al
     8dd:	add    BYTE PTR [rax],al
	...

00000000000008e0 <botlish_entry_3: byte::set<List[UnicodeChar]>>:
     8e0:	push   rbp
     8e1:	mov    rbp,rsp
     8e4:	mov    rsi,QWORD PTR [rdx]
     8e7:	call   8ec <botlish_entry_3+0xc>
			8e8: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::set<List[UnicodeChar]>
     8ec:	mov    rsp,rbp
     8ef:	pop    rbp
     8f0:	ret

00000000000008f1 <botlish_fn_4: ascii::is_digit<int>>:
     8f1:	push   rbp
     8f2:	mov    rbp,rsp
     8f5:	sar    rsi,1
     8f8:	cmp    rsi,0x30
     8fc:	jge    90c <botlish_fn_4+0x1b>
     902:	mov    eax,0x2
     907:	jmp    925 <botlish_fn_4+0x34>
     90c:	cmp    rsi,0x39
     910:	jle    920 <botlish_fn_4+0x2f>
     916:	mov    eax,0x2
     91b:	jmp    925 <botlish_fn_4+0x34>
     920:	mov    eax,0x6
     925:	mov    rsp,rbp
     928:	pop    rbp
     929:	ret

000000000000092a <botlish_entry_4: ascii::is_digit<int>>:
     92a:	push   rbp
     92b:	mov    rbp,rsp
     92e:	mov    rsi,QWORD PTR [rdx]
     931:	call   936 <botlish_entry_4+0xc>
			932: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     936:	mov    rsp,rbp
     939:	pop    rbp
     93a:	ret

000000000000093b <botlish_fn_5: ascii::is_upper<int>>:
     93b:	push   rbp
     93c:	mov    rbp,rsp
     93f:	sar    rsi,1
     942:	cmp    rsi,0x41
     946:	jge    956 <botlish_fn_5+0x1b>
     94c:	mov    eax,0x2
     951:	jmp    96f <botlish_fn_5+0x34>
     956:	cmp    rsi,0x5a
     95a:	jle    96a <botlish_fn_5+0x2f>
     960:	mov    eax,0x2
     965:	jmp    96f <botlish_fn_5+0x34>
     96a:	mov    eax,0x6
     96f:	mov    rsp,rbp
     972:	pop    rbp
     973:	ret

0000000000000974 <botlish_entry_5: ascii::is_upper<int>>:
     974:	push   rbp
     975:	mov    rbp,rsp
     978:	mov    rsi,QWORD PTR [rdx]
     97b:	call   980 <botlish_entry_5+0xc>
			97c: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     980:	mov    rsp,rbp
     983:	pop    rbp
     984:	ret

0000000000000985 <botlish_fn_6: ascii::is_lower<int>>:
     985:	push   rbp
     986:	mov    rbp,rsp
     989:	sar    rsi,1
     98c:	cmp    rsi,0x61
     990:	jge    9a0 <botlish_fn_6+0x1b>
     996:	mov    eax,0x2
     99b:	jmp    9b9 <botlish_fn_6+0x34>
     9a0:	cmp    rsi,0x7a
     9a4:	jle    9b4 <botlish_fn_6+0x2f>
     9aa:	mov    eax,0x2
     9af:	jmp    9b9 <botlish_fn_6+0x34>
     9b4:	mov    eax,0x6
     9b9:	mov    rsp,rbp
     9bc:	pop    rbp
     9bd:	ret

00000000000009be <botlish_entry_6: ascii::is_lower<int>>:
     9be:	push   rbp
     9bf:	mov    rbp,rsp
     9c2:	mov    rsi,QWORD PTR [rdx]
     9c5:	call   9ca <botlish_entry_6+0xc>
			9c6: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     9ca:	mov    rsp,rbp
     9cd:	pop    rbp
     9ce:	ret

00000000000009cf <botlish_fn_7: ascii::is_alphabetic<int>>:
     9cf:	push   rbp
     9d0:	mov    rbp,rsp
     9d3:	sub    rsp,0x10
     9d7:	mov    QWORD PTR [rsp],r12
     9db:	mov    QWORD PTR [rsp+0x8],r14
     9e0:	mov    r12,rsi
     9e3:	mov    r14,rdi
     9e6:	mov    rsi,r12
     9e9:	mov    rdi,r14
     9ec:	call   9f1 <botlish_fn_7+0x22>
			9ed: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     9f1:	cmp    rax,0x6
     9f5:	je     a24 <botlish_fn_7+0x55>
     9fb:	mov    rsi,r12
     9fe:	mov    rdi,r14
     a01:	call   a06 <botlish_fn_7+0x37>
			a02: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     a06:	cmp    rax,0x6
     a0a:	je     a1a <botlish_fn_7+0x4b>
     a10:	mov    eax,0x2
     a15:	jmp    a29 <botlish_fn_7+0x5a>
     a1a:	mov    eax,0x6
     a1f:	jmp    a29 <botlish_fn_7+0x5a>
     a24:	mov    eax,0x6
     a29:	mov    r12,QWORD PTR [rsp]
     a2d:	mov    r14,QWORD PTR [rsp+0x8]
     a32:	add    rsp,0x10
     a36:	mov    rsp,rbp
     a39:	pop    rbp
     a3a:	ret

0000000000000a3b <botlish_entry_7: ascii::is_alphabetic<int>>:
     a3b:	push   rbp
     a3c:	mov    rbp,rsp
     a3f:	mov    rsi,QWORD PTR [rdx]
     a42:	call   a47 <botlish_entry_7+0xc>
			a43: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     a47:	mov    rsp,rbp
     a4a:	pop    rbp
     a4b:	ret

0000000000000a4c <botlish_fn_8: ascii::is_alphanumeric<int>>:
     a4c:	push   rbp
     a4d:	mov    rbp,rsp
     a50:	sub    rsp,0x10
     a54:	mov    QWORD PTR [rsp],r12
     a58:	mov    QWORD PTR [rsp+0x8],r14
     a5d:	mov    r12,rsi
     a60:	mov    r14,rdi
     a63:	mov    rsi,r12
     a66:	mov    rdi,r14
     a69:	call   a6e <botlish_fn_8+0x22>
			a6a: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     a6e:	cmp    rax,0x6
     a72:	je     aa1 <botlish_fn_8+0x55>
     a78:	mov    rsi,r12
     a7b:	mov    rdi,r14
     a7e:	call   a83 <botlish_fn_8+0x37>
			a7f: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     a83:	cmp    rax,0x6
     a87:	je     a97 <botlish_fn_8+0x4b>
     a8d:	mov    eax,0x2
     a92:	jmp    aa6 <botlish_fn_8+0x5a>
     a97:	mov    eax,0x6
     a9c:	jmp    aa6 <botlish_fn_8+0x5a>
     aa1:	mov    eax,0x6
     aa6:	mov    r12,QWORD PTR [rsp]
     aaa:	mov    r14,QWORD PTR [rsp+0x8]
     aaf:	add    rsp,0x10
     ab3:	mov    rsp,rbp
     ab6:	pop    rbp
     ab7:	ret

0000000000000ab8 <botlish_entry_8: ascii::is_alphanumeric<int>>:
     ab8:	push   rbp
     ab9:	mov    rbp,rsp
     abc:	mov    rsi,QWORD PTR [rdx]
     abf:	call   ac4 <botlish_entry_8+0xc>
			ac0: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
     ac4:	mov    rsp,rbp
     ac7:	pop    rbp
     ac8:	ret

0000000000000ac9 <botlish_fn_9: web::emailish?<str>>:
     ac9:	push   rbp
     aca:	mov    rbp,rsp
     acd:	sub    rsp,0x50
     ad1:	mov    QWORD PTR [rsp+0x30],rbx
     ad6:	mov    QWORD PTR [rsp+0x38],r12
     adb:	mov    QWORD PTR [rsp+0x40],r13
     ae0:	mov    QWORD PTR [rsp+0x48],r14
     ae5:	mov    r13,rdi
     ae8:	mov    QWORD PTR [rsp],rsi
     aec:	mov    r12,rsi
     aef:	mov    rsi,r12
     af2:	mov    rdi,r13
     af5:	call   afa <botlish_fn_9+0x31>
			af6: R_X86_64_PLT32	rt_str_len-0x4
     afa:	mov    r14,rax
     afd:	mov    QWORD PTR [rsp+0x8],rax
     b02:	mov    esi,0x1
     b07:	mov    QWORD PTR [rsp+0x10],0x1
     b10:	mov    rdi,r13
     b13:	mov    rax,QWORD PTR [rdi+0x10]
     b17:	mov    rdx,QWORD PTR [rax+0xc8]
     b1e:	mov    QWORD PTR [rsp+0x18],rdx
     b23:	mov    rcx,r14
     b26:	mov    r8,r12
     b29:	call   b2e <botlish_fn_9+0x65>
			b2a: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<any, block(e239)>
     b2e:	test   rax,rax
     b31:	je     bd4 <botlish_fn_9+0x10b>
     b37:	mov    QWORD PTR [rsp+0x10],rax
     b3c:	mov    rbx,rax
     b3f:	sar    rbx,1
     b42:	mov    rsi,rax
     b45:	test   rbx,rbx
     b48:	je     c03 <botlish_fn_9+0x13a>
     b4e:	mov    rax,r14
     b51:	mov    rcx,rax
     b54:	sar    rcx,1
     b57:	cmp    rbx,rcx
     b5a:	jge    bf9 <botlish_fn_9+0x130>
     b60:	lea    rcx,[rsp+0x20]
     b65:	mov    rdx,r12
     b68:	mov    rdi,r13
     b6b:	call   b70 <botlish_fn_9+0xa7>
			b6c: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
     b70:	test   rax,rax
     b73:	mov    rsi,rax
     b76:	je     bd4 <botlish_fn_9+0x10b>
     b7c:	mov    rdx,QWORD PTR [rsp+0x20]
     b81:	mov    rcx,QWORD PTR [rsp+0x28]
     b86:	mov    rdi,r13
     b89:	mov    rax,QWORD PTR [rdi+0x10]
     b8d:	mov    r8,QWORD PTR [rax+0xd0]
     b94:	call   b99 <botlish_fn_9+0xd0>
			b95: R_X86_64_PLT32	rt_str_region_eq-0x4
     b99:	cmp    rax,0x6
     b9d:	je     bad <botlish_fn_9+0xe4>
     ba3:	mov    eax,0x2
     ba8:	jmp    c08 <botlish_fn_9+0x13f>
     bad:	lea    rsi,[rbx+0x1]
     bb1:	shl    rsi,1
     bb4:	or     rsi,0x1
     bb8:	mov    QWORD PTR [rsp+0x10],rsi
     bbd:	mov    rcx,r12
     bc0:	mov    rdx,r14
     bc3:	mov    rdi,r13
     bc6:	call   bcb <botlish_fn_9+0x102>
			bc7: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<generic>
     bcb:	test   rax,rax
     bce:	jne    c08 <botlish_fn_9+0x13f>
     bd4:	xor    rax,rax
     bd7:	mov    rbx,QWORD PTR [rsp+0x30]
     bdc:	mov    r12,QWORD PTR [rsp+0x38]
     be1:	mov    r13,QWORD PTR [rsp+0x40]
     be6:	mov    r14,QWORD PTR [rsp+0x48]
     beb:	add    rsp,0x50
     bef:	mov    rsp,rbp
     bf2:	pop    rbp
     bf3:	ret
     bf4:	jmp    c08 <botlish_fn_9+0x13f>
     bf9:	mov    eax,0x2
     bfe:	jmp    c08 <botlish_fn_9+0x13f>
     c03:	mov    eax,0x2
     c08:	mov    rbx,QWORD PTR [rsp+0x30]
     c0d:	mov    r12,QWORD PTR [rsp+0x38]
     c12:	mov    r13,QWORD PTR [rsp+0x40]
     c17:	mov    r14,QWORD PTR [rsp+0x48]
     c1c:	add    rsp,0x50
     c20:	mov    rsp,rbp
     c23:	pop    rbp
     c24:	ret

0000000000000c25 <botlish_entry_9: web::emailish?<str>>:
     c25:	push   rbp
     c26:	mov    rbp,rsp
     c29:	mov    rsi,QWORD PTR [rdx]
     c2c:	call   c31 <botlish_entry_9+0xc>
			c2d: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
     c31:	mov    rsp,rbp
     c34:	pop    rbp
     c35:	ret

0000000000000c36 <botlish_fn_10: char_at<generic>>:
     c36:	push   rbp
     c37:	mov    rbp,rsp
     c3a:	sub    rsp,0x50
     c3e:	mov    QWORD PTR [rsp+0x20],rbx
     c43:	mov    QWORD PTR [rsp+0x28],r12
     c48:	mov    QWORD PTR [rsp+0x30],r13
     c4d:	mov    QWORD PTR [rsp+0x38],r14
     c52:	mov    QWORD PTR [rsp+0x40],r15
     c57:	mov    r12,rdi
     c5a:	mov    r15,rcx
     c5d:	mov    QWORD PTR [rsp],rsi
     c61:	mov    QWORD PTR [rsp+0x8],rdx
     c66:	mov    r13,rdx
     c69:	mov    QWORD PTR [rsp+0x10],0x3
     c72:	test   rsi,0x1
     c79:	jne    c87 <botlish_fn_10+0x51>
     c7f:	mov    rbx,rsi
     c82:	jmp    ca7 <botlish_fn_10+0x71>
     c87:	mov    rax,rsi
     c8a:	add    rax,0x2
     c8e:	mov    rbx,rsi
     c91:	seto   cl
     c94:	test   cl,cl
     c96:	jne    ca7 <botlish_fn_10+0x71>
     c9c:	mov    rdi,r12
     c9f:	mov    r14,rax
     ca2:	jmp    cbd <botlish_fn_10+0x87>
     ca7:	mov    edx,0x3
     cac:	mov    rsi,rbx
     caf:	mov    rdi,r12
     cb2:	call   cb7 <botlish_fn_10+0x81>
			cb3: R_X86_64_PLT32	rt_int_add-0x4
     cb7:	mov    r14,rax
     cba:	mov    rdi,r12
     cbd:	mov    rcx,r14
     cc0:	mov    rdx,rbx
     cc3:	mov    rsi,r13
     cc6:	call   ccb <botlish_fn_10+0x95>
			cc7: R_X86_64_PLT32	rt_str_region_check-0x4
     ccb:	test   rax,rax
     cce:	jne    cf9 <botlish_fn_10+0xc3>
     cd4:	xor    rax,rax
     cd7:	mov    rbx,QWORD PTR [rsp+0x20]
     cdc:	mov    r12,QWORD PTR [rsp+0x28]
     ce1:	mov    r13,QWORD PTR [rsp+0x30]
     ce6:	mov    r14,QWORD PTR [rsp+0x38]
     ceb:	mov    r15,QWORD PTR [rsp+0x40]
     cf0:	add    rsp,0x50
     cf4:	mov    rsp,rbp
     cf7:	pop    rbp
     cf8:	ret
     cf9:	mov    rcx,r15
     cfc:	mov    QWORD PTR [rcx],rbx
     cff:	mov    rax,r14
     d02:	mov    QWORD PTR [rcx+0x8],rax
     d06:	mov    rax,r13
     d09:	mov    rbx,QWORD PTR [rsp+0x20]
     d0e:	mov    r12,QWORD PTR [rsp+0x28]
     d13:	mov    r13,QWORD PTR [rsp+0x30]
     d18:	mov    r14,QWORD PTR [rsp+0x38]
     d1d:	mov    r15,QWORD PTR [rsp+0x40]
     d22:	add    rsp,0x50
     d26:	mov    rsp,rbp
     d29:	pop    rbp
     d2a:	ret

0000000000000d2b <botlish_entry_10: char_at<generic>>:
     d2b:	push   rbp
     d2c:	mov    rbp,rsp
     d2f:	ud2

0000000000000d31 <botlish_fn_11: char_at<generic>>:
     d31:	push   rbp
     d32:	mov    rbp,rsp
     d35:	sub    rsp,0x40
     d39:	mov    QWORD PTR [rsp+0x20],rbx
     d3e:	mov    QWORD PTR [rsp+0x28],r12
     d43:	mov    QWORD PTR [rsp+0x30],r13
     d48:	mov    r12,rdi
     d4b:	mov    QWORD PTR [rsp],rsi
     d4f:	mov    QWORD PTR [rsp+0x8],rdx
     d54:	mov    r13,rdx
     d57:	mov    QWORD PTR [rsp+0x10],0x3
     d60:	test   rsi,0x1
     d67:	jne    d75 <botlish_fn_11+0x44>
     d6d:	mov    rbx,rsi
     d70:	jmp    d8a <botlish_fn_11+0x59>
     d75:	mov    rcx,rsi
     d78:	add    rcx,0x2
     d7c:	mov    rbx,rsi
     d7f:	seto   al
     d82:	test   al,al
     d84:	je     d9d <botlish_fn_11+0x6c>
     d8a:	mov    edx,0x3
     d8f:	mov    rsi,rbx
     d92:	mov    rdi,r12
     d95:	call   d9a <botlish_fn_11+0x69>
			d96: R_X86_64_PLT32	rt_int_add-0x4
     d9a:	mov    rcx,rax
     d9d:	mov    QWORD PTR [rsp+0x10],rcx
     da2:	mov    rdx,rbx
     da5:	mov    rsi,r13
     da8:	mov    rdi,r12
     dab:	call   db0 <botlish_fn_11+0x7f>
			dac: R_X86_64_PLT32	rt_substr-0x4
     db0:	test   rax,rax
     db3:	jne    dd4 <botlish_fn_11+0xa3>
     db9:	xor    rax,rax
     dbc:	mov    rbx,QWORD PTR [rsp+0x20]
     dc1:	mov    r12,QWORD PTR [rsp+0x28]
     dc6:	mov    r13,QWORD PTR [rsp+0x30]
     dcb:	add    rsp,0x40
     dcf:	mov    rsp,rbp
     dd2:	pop    rbp
     dd3:	ret
     dd4:	mov    rbx,QWORD PTR [rsp+0x20]
     dd9:	mov    r12,QWORD PTR [rsp+0x28]
     dde:	mov    r13,QWORD PTR [rsp+0x30]
     de3:	add    rsp,0x40
     de7:	mov    rsp,rbp
     dea:	pop    rbp
     deb:	ret

0000000000000dec <botlish_entry_11: char_at<generic>>:
     dec:	push   rbp
     ded:	mov    rbp,rsp
     df0:	mov    rsi,QWORD PTR [rdx]
     df3:	mov    rdx,QWORD PTR [rdx+0x8]
     df7:	call   dfc <botlish_entry_11+0x10>
			df8: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
     dfc:	mov    rsp,rbp
     dff:	pop    rbp
     e00:	ret

0000000000000e01 <botlish_fn_12: local_char?<str>>:
     e01:	push   rbp
     e02:	mov    rbp,rsp
     e05:	sub    rsp,0x10
     e09:	mov    QWORD PTR [rsp],rbx
     e0d:	mov    QWORD PTR [rsp+0x8],r14
     e12:	mov    rbx,rdi
     e15:	mov    r14,rsi
     e18:	mov    rsi,r14
     e1b:	mov    rdi,rbx
     e1e:	call   e23 <botlish_fn_12+0x22>
			e1f: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     e23:	test   rax,rax
     e26:	jne    e41 <botlish_fn_12+0x40>
     e2c:	xor    rax,rax
     e2f:	mov    rbx,QWORD PTR [rsp]
     e33:	mov    r14,QWORD PTR [rsp+0x8]
     e38:	add    rsp,0x10
     e3c:	mov    rsp,rbp
     e3f:	pop    rbp
     e40:	ret
     e41:	cmp    rax,0x6
     e45:	je     e7b <botlish_fn_12+0x7a>
     e4b:	mov    rdi,rbx
     e4e:	mov    rax,QWORD PTR [rdi+0x30]
     e52:	mov    rsi,QWORD PTR [rax]
     e55:	mov    rdx,r14
     e58:	call   e5d <botlish_fn_12+0x5c>
			e59: R_X86_64_PLT32	rt_set_contains-0x4
     e5d:	cmp    rax,0x6
     e61:	je     e71 <botlish_fn_12+0x70>
     e67:	mov    eax,0x2
     e6c:	jmp    e80 <botlish_fn_12+0x7f>
     e71:	mov    eax,0x6
     e76:	jmp    e80 <botlish_fn_12+0x7f>
     e7b:	mov    eax,0x6
     e80:	mov    rbx,QWORD PTR [rsp]
     e84:	mov    r14,QWORD PTR [rsp+0x8]
     e89:	add    rsp,0x10
     e8d:	mov    rsp,rbp
     e90:	pop    rbp
     e91:	ret

0000000000000e92 <botlish_entry_12: local_char?<str>>:
     e92:	push   rbp
     e93:	mov    rbp,rsp
     e96:	mov    rsi,QWORD PTR [rdx]
     e99:	call   e9e <botlish_entry_12+0xc>
			e9a: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
     e9e:	mov    rsp,rbp
     ea1:	pop    rbp
     ea2:	ret

0000000000000ea3 <botlish_fn_13: local_char?<generic>>:
     ea3:	push   rbp
     ea4:	mov    rbp,rsp
     ea7:	sub    rsp,0x10
     eab:	mov    QWORD PTR [rsp],rbx
     eaf:	mov    QWORD PTR [rsp+0x8],r12
     eb4:	xor    r8d,r8d
     eb7:	test   rsi,0x7
     ebe:	jne    ece <botlish_fn_13+0x2b>
     ec4:	movzx  rax,BYTE PTR [rsi]
     ec8:	cmp    al,0x2
     eca:	sete   r8b
     ece:	test   r8b,r8b
     ed1:	jne    ef1 <botlish_fn_13+0x4e>
     ed7:	mov    rax,QWORD PTR [rdi+0x10]
     edb:	mov    rcx,QWORD PTR [rax+0xd8]
     ee2:	mov    edx,0x1
     ee7:	call   eec <botlish_fn_13+0x49>
			ee8: R_X86_64_PLT32	rt_type_error-0x4
     eec:	jmp    f05 <botlish_fn_13+0x62>
     ef1:	mov    rbx,rsi
     ef4:	mov    r12,rdi
     ef7:	call   efc <botlish_fn_13+0x59>
			ef8: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     efc:	test   rax,rax
     eff:	jne    f1a <botlish_fn_13+0x77>
     f05:	xor    rax,rax
     f08:	mov    rbx,QWORD PTR [rsp]
     f0c:	mov    r12,QWORD PTR [rsp+0x8]
     f11:	add    rsp,0x10
     f15:	mov    rsp,rbp
     f18:	pop    rbp
     f19:	ret
     f1a:	cmp    rax,0x6
     f1e:	je     f54 <botlish_fn_13+0xb1>
     f24:	mov    rdi,r12
     f27:	mov    rax,QWORD PTR [rdi+0x30]
     f2b:	mov    rsi,QWORD PTR [rax]
     f2e:	mov    rdx,rbx
     f31:	call   f36 <botlish_fn_13+0x93>
			f32: R_X86_64_PLT32	rt_set_contains-0x4
     f36:	cmp    rax,0x6
     f3a:	je     f4a <botlish_fn_13+0xa7>
     f40:	mov    eax,0x2
     f45:	jmp    f59 <botlish_fn_13+0xb6>
     f4a:	mov    eax,0x6
     f4f:	jmp    f59 <botlish_fn_13+0xb6>
     f54:	mov    eax,0x6
     f59:	mov    rbx,QWORD PTR [rsp]
     f5d:	mov    r12,QWORD PTR [rsp+0x8]
     f62:	add    rsp,0x10
     f66:	mov    rsp,rbp
     f69:	pop    rbp
     f6a:	ret

0000000000000f6b <botlish_entry_13: local_char?<generic>>:
     f6b:	push   rbp
     f6c:	mov    rbp,rsp
     f6f:	mov    rsi,QWORD PTR [rdx]
     f72:	call   f77 <botlish_entry_13+0xc>
			f73: R_X86_64_PLT32	botlish_fn_13-0x4 ; local_char?<generic>
     f77:	mov    rsp,rbp
     f7a:	pop    rbp
     f7b:	ret
     f7c:	add    BYTE PTR [rax],al
	...

0000000000000f80 <botlish_fn_14: scan_while<any, block(e239)>>:
     f80:	push   rbp
     f81:	mov    rbp,rsp
     f84:	sub    rsp,0x40
     f88:	mov    QWORD PTR [rsp+0x20],rbx
     f8d:	mov    QWORD PTR [rsp+0x28],r12
     f92:	mov    QWORD PTR [rsp+0x30],r13
     f97:	mov    QWORD PTR [rsp+0x38],r14
     f9c:	mov    rbx,rcx
     f9f:	mov    r13,rdi
     fa2:	mov    QWORD PTR [rsp+0x18],0x0
     fab:	mov    QWORD PTR [rsp],rcx
     faf:	mov    QWORD PTR [rsp+0x8],r8
     fb4:	mov    r12,r8
     fb7:	mov    QWORD PTR [rsp+0x10],rsi
     fbc:	mov    rax,rsi
     fbf:	mov    rcx,rbx
     fc2:	mov    r14,rsi
     fc5:	mov    rcx,rbx
     fc8:	and    rax,rcx
     fcb:	test   rax,0x1
     fd1:	jne    ffa <botlish_fn_14+0x7a>
     fd7:	mov    rdx,rbx
     fda:	mov    rsi,r14
     fdd:	mov    rdi,r13
     fe0:	call   fe5 <botlish_fn_14+0x65>
			fe1: R_X86_64_PLT32	rt_int_cmp-0x4
     fe5:	mov    ecx,0x2
     fea:	test   rax,rax
     fed:	cmovl  rcx,QWORD PTR [rip+0x10b]        # 1100 <botlish_fn_14+0x180>
     ff5:	jmp    1010 <botlish_fn_14+0x90>
     ffa:	mov    ecx,0x2
     fff:	mov    rax,r14
    1002:	mov    rdx,rbx
    1005:	cmp    rax,rdx
    1008:	cmovl  rcx,QWORD PTR [rip+0xf0]        # 1100 <botlish_fn_14+0x180>
    1010:	cmp    rcx,0x6
    1014:	je     103a <botlish_fn_14+0xba>
    101a:	mov    rax,rbx
    101d:	mov    rbx,QWORD PTR [rsp+0x20]
    1022:	mov    r12,QWORD PTR [rsp+0x28]
    1027:	mov    r13,QWORD PTR [rsp+0x30]
    102c:	mov    r14,QWORD PTR [rsp+0x38]
    1031:	add    rsp,0x40
    1035:	mov    rsp,rbp
    1038:	pop    rbp
    1039:	ret
    103a:	mov    rdx,r12
    103d:	mov    rsi,r14
    1040:	mov    rdi,r13
    1043:	call   1048 <botlish_fn_14+0xc8>
			1044: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    1048:	test   rax,rax
    104b:	mov    rsi,rax
    104e:	je     1065 <botlish_fn_14+0xe5>
    1054:	mov    rdi,r13
    1057:	call   105c <botlish_fn_14+0xdc>
			1058: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<str>
    105c:	test   rax,rax
    105f:	jne    1085 <botlish_fn_14+0x105>
    1065:	xor    rax,rax
    1068:	mov    rbx,QWORD PTR [rsp+0x20]
    106d:	mov    r12,QWORD PTR [rsp+0x28]
    1072:	mov    r13,QWORD PTR [rsp+0x30]
    1077:	mov    r14,QWORD PTR [rsp+0x38]
    107c:	add    rsp,0x40
    1080:	mov    rsp,rbp
    1083:	pop    rbp
    1084:	ret
    1085:	cmp    rax,0x6
    1089:	je     10af <botlish_fn_14+0x12f>
    108f:	mov    rax,r14
    1092:	mov    rbx,QWORD PTR [rsp+0x20]
    1097:	mov    r12,QWORD PTR [rsp+0x28]
    109c:	mov    r13,QWORD PTR [rsp+0x30]
    10a1:	mov    r14,QWORD PTR [rsp+0x38]
    10a6:	add    rsp,0x40
    10aa:	mov    rsp,rbp
    10ad:	pop    rbp
    10ae:	ret
    10af:	mov    QWORD PTR [rsp+0x18],0x3
    10b8:	mov    rax,r14
    10bb:	test   rax,0x1
    10c1:	je     10dc <botlish_fn_14+0x15c>
    10c7:	mov    rcx,r14
    10ca:	mov    rax,rcx
    10cd:	add    rax,0x2
    10d1:	seto   cl
    10d4:	test   cl,cl
    10d6:	je     10ec <botlish_fn_14+0x16c>
    10dc:	mov    edx,0x3
    10e1:	mov    rsi,r14
    10e4:	mov    rdi,r13
    10e7:	call   10ec <botlish_fn_14+0x16c>
			10e8: R_X86_64_PLT32	rt_int_add-0x4
    10ec:	mov    QWORD PTR [rsp+0x10],rax
    10f1:	mov    rcx,rbx
    10f4:	mov    r14,rax
    10f7:	jmp    fc5 <botlish_fn_14+0x45>
    10fc:	add    BYTE PTR [rax],al
    10fe:	add    BYTE PTR [rax],al
    1100:	(bad)
    1101:	add    BYTE PTR [rax],al
    1103:	add    BYTE PTR [rax],al
    1105:	add    BYTE PTR [rax],al
	...

0000000000001108 <botlish_entry_14: scan_while<any, block(e239)>>:
    1108:	push   rbp
    1109:	mov    rbp,rsp
    110c:	mov    rsi,QWORD PTR [rdx]
    110f:	mov    r9,QWORD PTR [rdx+0x8]
    1113:	mov    rcx,QWORD PTR [rdx+0x10]
    1117:	mov    r8,QWORD PTR [rdx+0x18]
    111b:	mov    rdx,r9
    111e:	call   1123 <botlish_entry_14+0x1b>
			111f: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<any, block(e239)>
    1123:	mov    rsp,rbp
    1126:	pop    rbp
    1127:	ret

0000000000001128 <botlish_fn_15: scan_while<any, native(is_tcl_alpha)>>:
    1128:	push   rbp
    1129:	mov    rbp,rsp
    112c:	sub    rsp,0x50
    1130:	mov    QWORD PTR [rsp+0x30],rbx
    1135:	mov    QWORD PTR [rsp+0x38],r12
    113a:	mov    QWORD PTR [rsp+0x40],r13
    113f:	mov    QWORD PTR [rsp+0x48],r14
    1144:	mov    rbx,rcx
    1147:	mov    r13,rdi
    114a:	mov    QWORD PTR [rsp+0x18],0x0
    1153:	mov    QWORD PTR [rsp],rcx
    1157:	mov    QWORD PTR [rsp+0x8],r8
    115c:	mov    r12,r8
    115f:	mov    QWORD PTR [rsp+0x10],rsi
    1164:	mov    rax,rsi
    1167:	mov    rcx,rbx
    116a:	mov    r14,rsi
    116d:	mov    rcx,rbx
    1170:	and    rax,rcx
    1173:	test   rax,0x1
    1179:	jne    11a2 <botlish_fn_15+0x7a>
    117f:	mov    rdx,rbx
    1182:	mov    rsi,r14
    1185:	mov    rdi,r13
    1188:	call   118d <botlish_fn_15+0x65>
			1189: R_X86_64_PLT32	rt_int_cmp-0x4
    118d:	mov    ecx,0x2
    1192:	test   rax,rax
    1195:	cmovl  rcx,QWORD PTR [rip+0x11b]        # 12b8 <botlish_fn_15+0x190>
    119d:	jmp    11b8 <botlish_fn_15+0x90>
    11a2:	mov    ecx,0x2
    11a7:	mov    rax,r14
    11aa:	mov    rdx,rbx
    11ad:	cmp    rax,rdx
    11b0:	cmovl  rcx,QWORD PTR [rip+0x100]        # 12b8 <botlish_fn_15+0x190>
    11b8:	cmp    rcx,0x6
    11bc:	je     11e2 <botlish_fn_15+0xba>
    11c2:	mov    rax,rbx
    11c5:	mov    rbx,QWORD PTR [rsp+0x30]
    11ca:	mov    r12,QWORD PTR [rsp+0x38]
    11cf:	mov    r13,QWORD PTR [rsp+0x40]
    11d4:	mov    r14,QWORD PTR [rsp+0x48]
    11d9:	add    rsp,0x50
    11dd:	mov    rsp,rbp
    11e0:	pop    rbp
    11e1:	ret
    11e2:	lea    rcx,[rsp+0x20]
    11e7:	mov    rdx,r12
    11ea:	mov    rsi,r14
    11ed:	mov    rdi,r13
    11f0:	call   11f5 <botlish_fn_15+0xcd>
			11f1: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    11f5:	test   rax,rax
    11f8:	mov    rsi,rax
    11fb:	je     121c <botlish_fn_15+0xf4>
    1201:	mov    rdx,QWORD PTR [rsp+0x20]
    1206:	mov    rcx,QWORD PTR [rsp+0x28]
    120b:	mov    rdi,r13
    120e:	call   1213 <botlish_fn_15+0xeb>
			120f: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    1213:	test   rax,rax
    1216:	jne    123c <botlish_fn_15+0x114>
    121c:	xor    rax,rax
    121f:	mov    rbx,QWORD PTR [rsp+0x30]
    1224:	mov    r12,QWORD PTR [rsp+0x38]
    1229:	mov    r13,QWORD PTR [rsp+0x40]
    122e:	mov    r14,QWORD PTR [rsp+0x48]
    1233:	add    rsp,0x50
    1237:	mov    rsp,rbp
    123a:	pop    rbp
    123b:	ret
    123c:	cmp    rax,0x6
    1240:	je     1266 <botlish_fn_15+0x13e>
    1246:	mov    rax,r14
    1249:	mov    rbx,QWORD PTR [rsp+0x30]
    124e:	mov    r12,QWORD PTR [rsp+0x38]
    1253:	mov    r13,QWORD PTR [rsp+0x40]
    1258:	mov    r14,QWORD PTR [rsp+0x48]
    125d:	add    rsp,0x50
    1261:	mov    rsp,rbp
    1264:	pop    rbp
    1265:	ret
    1266:	mov    QWORD PTR [rsp+0x18],0x3
    126f:	mov    rax,r14
    1272:	test   rax,0x1
    1278:	je     1293 <botlish_fn_15+0x16b>
    127e:	mov    rcx,r14
    1281:	mov    rax,rcx
    1284:	add    rax,0x2
    1288:	seto   cl
    128b:	test   cl,cl
    128d:	je     12a3 <botlish_fn_15+0x17b>
    1293:	mov    edx,0x3
    1298:	mov    rsi,r14
    129b:	mov    rdi,r13
    129e:	call   12a3 <botlish_fn_15+0x17b>
			129f: R_X86_64_PLT32	rt_int_add-0x4
    12a3:	mov    QWORD PTR [rsp+0x10],rax
    12a8:	mov    rcx,rbx
    12ab:	mov    r14,rax
    12ae:	jmp    116d <botlish_fn_15+0x45>
    12b3:	add    BYTE PTR [rax],al
    12b5:	add    BYTE PTR [rax],al
    12b7:	add    BYTE PTR [rsi],al
    12b9:	add    BYTE PTR [rax],al
    12bb:	add    BYTE PTR [rax],al
    12bd:	add    BYTE PTR [rax],al
	...

00000000000012c0 <botlish_entry_15: scan_while<any, native(is_tcl_alpha)>>:
    12c0:	push   rbp
    12c1:	mov    rbp,rsp
    12c4:	mov    rsi,QWORD PTR [rdx]
    12c7:	mov    r9,QWORD PTR [rdx+0x8]
    12cb:	mov    rcx,QWORD PTR [rdx+0x10]
    12cf:	mov    r8,QWORD PTR [rdx+0x18]
    12d3:	mov    rdx,r9
    12d6:	call   12db <botlish_entry_15+0x1b>
			12d7: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<any, native(is_tcl_alpha)>
    12db:	mov    rsp,rbp
    12de:	pop    rbp
    12df:	ret

00000000000012e0 <botlish_fn_16: tld?<generic>>:
    12e0:	push   rbp
    12e1:	mov    rbp,rsp
    12e4:	sub    rsp,0x40
    12e8:	mov    QWORD PTR [rsp+0x20],rbx
    12ed:	mov    QWORD PTR [rsp+0x28],r12
    12f2:	mov    QWORD PTR [rsp+0x30],r13
    12f7:	mov    QWORD PTR [rsp+0x38],r14
    12fc:	mov    QWORD PTR [rsp],rsi
    1300:	mov    r8,rsi
    1303:	mov    QWORD PTR [rsp+0x8],rdx
    1308:	mov    r14,rdx
    130b:	mov    QWORD PTR [rsp+0x10],rcx
    1310:	mov    rax,QWORD PTR [rdi+0x10]
    1314:	mov    r12,rdi
    1317:	mov    rdx,QWORD PTR [rax+0xe0]
    131e:	mov    QWORD PTR [rsp+0x18],rdx
    1323:	mov    rbx,r8
    1326:	mov    r8,rcx
    1329:	mov    rcx,r14
    132c:	mov    rsi,rbx
    132f:	call   1334 <botlish_fn_16+0x54>
			1330: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<any, native(is_tcl_alpha)>
    1334:	mov    rcx,rax
    1337:	mov    r13,rax
    133a:	test   rax,rcx
    133d:	jne    1363 <botlish_fn_16+0x83>
    1343:	xor    rax,rax
    1346:	mov    rbx,QWORD PTR [rsp+0x20]
    134b:	mov    r12,QWORD PTR [rsp+0x28]
    1350:	mov    r13,QWORD PTR [rsp+0x30]
    1355:	mov    r14,QWORD PTR [rsp+0x38]
    135a:	add    rsp,0x40
    135e:	mov    rsp,rbp
    1361:	pop    rbp
    1362:	ret
    1363:	mov    rax,r13
    1366:	mov    QWORD PTR [rsp+0x8],rax
    136b:	mov    rdx,r14
    136e:	and    rax,rdx
    1371:	test   rax,0x1
    1377:	jne    13a0 <botlish_fn_16+0xc0>
    137d:	mov    rsi,r13
    1380:	mov    rdi,r12
    1383:	call   1388 <botlish_fn_16+0xa8>
			1384: R_X86_64_PLT32	rt_int_cmp-0x4
    1388:	mov    ecx,0x2
    138d:	test   rax,rax
    1390:	cmove  rcx,QWORD PTR [rip+0xe0]        # 1478 <botlish_fn_16+0x198>
    1398:	mov    rax,r13
    139b:	jmp    13b3 <botlish_fn_16+0xd3>
    13a0:	mov    ecx,0x2
    13a5:	mov    rax,r13
    13a8:	cmp    rax,rdx
    13ab:	cmove  rcx,QWORD PTR [rip+0xc5]        # 1478 <botlish_fn_16+0x198>
    13b3:	cmp    rcx,0x6
    13b7:	je     13ca <botlish_fn_16+0xea>
    13bd:	mov    ecx,0x2
    13c2:	mov    rax,rcx
    13c5:	jmp    1457 <botlish_fn_16+0x177>
    13ca:	mov    rcx,rax
    13cd:	and    rcx,rbx
    13d0:	test   rcx,0x1
    13d7:	jne    13e8 <botlish_fn_16+0x108>
    13dd:	mov    rdx,rbx
    13e0:	mov    rsi,rax
    13e3:	jmp    1409 <botlish_fn_16+0x129>
    13e8:	mov    rcx,rax
    13eb:	sub    rcx,rbx
    13ee:	mov    r8,rbx
    13f1:	mov    r13,rax
    13f4:	seto   al
    13f7:	lea    rsi,[rcx+0x1]
    13fb:	test   al,al
    13fd:	je     1414 <botlish_fn_16+0x134>
    1403:	mov    rdx,r8
    1406:	mov    rsi,r13
    1409:	mov    rdi,r12
    140c:	call   1411 <botlish_fn_16+0x131>
			140d: R_X86_64_PLT32	rt_int_sub-0x4
    1411:	mov    rsi,rax
    1414:	test   rsi,0x1
    141b:	jne    1446 <botlish_fn_16+0x166>
    1421:	mov    edx,0x5
    1426:	mov    rdi,r12
    1429:	call   142e <botlish_fn_16+0x14e>
			142a: R_X86_64_PLT32	rt_int_cmp-0x4
    142e:	mov    ecx,0x2
    1433:	test   rax,rax
    1436:	mov    rax,rcx
    1439:	cmovge rax,QWORD PTR [rip+0x37]        # 1478 <botlish_fn_16+0x198>
    1441:	jmp    1457 <botlish_fn_16+0x177>
    1446:	mov    eax,0x2
    144b:	cmp    rsi,0x5
    144f:	cmovge rax,QWORD PTR [rip+0x21]        # 1478 <botlish_fn_16+0x198>
    1457:	mov    rbx,QWORD PTR [rsp+0x20]
    145c:	mov    r12,QWORD PTR [rsp+0x28]
    1461:	mov    r13,QWORD PTR [rsp+0x30]
    1466:	mov    r14,QWORD PTR [rsp+0x38]
    146b:	add    rsp,0x40
    146f:	mov    rsp,rbp
    1472:	pop    rbp
    1473:	ret
    1474:	add    BYTE PTR [rax],al
    1476:	add    BYTE PTR [rax],al
    1478:	(bad)
    1479:	add    BYTE PTR [rax],al
    147b:	add    BYTE PTR [rax],al
    147d:	add    BYTE PTR [rax],al
	...

0000000000001480 <botlish_entry_16: tld?<generic>>:
    1480:	push   rbp
    1481:	mov    rbp,rsp
    1484:	mov    rsi,QWORD PTR [rdx]
    1487:	mov    r8,QWORD PTR [rdx+0x8]
    148b:	mov    rcx,QWORD PTR [rdx+0x10]
    148f:	mov    rdx,r8
    1492:	call   1497 <botlish_entry_16+0x17>
			1493: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<generic>
    1497:	mov    rsp,rbp
    149a:	pop    rbp
    149b:	ret
    149c:	add    BYTE PTR [rax],al
	...

00000000000014a0 <botlish_fn_17: domain?<generic>>:
    14a0:	push   rbp
    14a1:	mov    rbp,rsp
    14a4:	sub    rsp,0xa0
    14ab:	mov    QWORD PTR [rsp+0x70],rbx
    14b0:	mov    QWORD PTR [rsp+0x78],r12
    14b5:	mov    QWORD PTR [rsp+0x80],r13
    14bd:	mov    QWORD PTR [rsp+0x88],r14
    14c5:	mov    QWORD PTR [rsp+0x90],r15
    14cd:	mov    r8,rdi
    14d0:	mov    QWORD PTR [rsp+0x20],0x0
    14d9:	mov    QWORD PTR [rsp],rsi
    14dd:	mov    QWORD PTR [rsp+0x8],rdx
    14e2:	mov    QWORD PTR [rsp+0x10],rcx
    14e7:	mov    r15,rcx
    14ea:	mov    QWORD PTR [rsp+0x18],rsi
    14ef:	mov    r12,rsi
    14f2:	mov    r14,rdx
    14f5:	mov    rdi,rsi
    14f8:	and    rdi,r14
    14fb:	mov    QWORD PTR [rsp+0x58],rsi
    1500:	test   rdi,0x1
    1507:	jne    1535 <botlish_fn_17+0x95>
    150d:	mov    rbx,r8
    1510:	mov    rdx,r14
    1513:	mov    rsi,QWORD PTR [rsp+0x58]
    1518:	mov    rdi,rbx
    151b:	call   1520 <botlish_fn_17+0x80>
			151c: R_X86_64_PLT32	rt_int_cmp-0x4
    1520:	mov    ecx,0x2
    1525:	test   rax,rax
    1528:	cmovl  rcx,QWORD PTR [rip+0x358]        # 1888 <botlish_fn_17+0x3e8>
    1530:	jmp    154d <botlish_fn_17+0xad>
    1535:	mov    rbx,r8
    1538:	mov    ecx,0x2
    153d:	mov    rsi,QWORD PTR [rsp+0x58]
    1542:	cmp    rsi,r14
    1545:	cmovl  rcx,QWORD PTR [rip+0x33b]        # 1888 <botlish_fn_17+0x3e8>
    154d:	cmp    rcx,0x6
    1551:	je     158a <botlish_fn_17+0xea>
    1557:	mov    eax,0x2
    155c:	mov    rbx,QWORD PTR [rsp+0x70]
    1561:	mov    r12,QWORD PTR [rsp+0x78]
    1566:	mov    r13,QWORD PTR [rsp+0x80]
    156e:	mov    r14,QWORD PTR [rsp+0x88]
    1576:	mov    r15,QWORD PTR [rsp+0x90]
    157e:	add    rsp,0xa0
    1585:	mov    rsp,rbp
    1588:	pop    rbp
    1589:	ret
    158a:	lea    rcx,[rsp+0x28]
    158f:	mov    rdx,r15
    1592:	mov    rsi,QWORD PTR [rsp+0x58]
    1597:	mov    rdi,rbx
    159a:	call   159f <botlish_fn_17+0xff>
			159b: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    159f:	test   rax,rax
    15a2:	mov    rsi,rax
    15a5:	je     174c <botlish_fn_17+0x2ac>
    15ab:	mov    rdx,QWORD PTR [rsp+0x28]
    15b0:	mov    rcx,QWORD PTR [rsp+0x30]
    15b5:	mov    rax,QWORD PTR [rbx+0x10]
    15b9:	mov    r8,QWORD PTR [rax]
    15bc:	mov    rdi,rbx
    15bf:	call   15c4 <botlish_fn_17+0x124>
			15c0: R_X86_64_PLT32	rt_str_region_eq-0x4
    15c4:	cmp    rax,0x6
    15c8:	je     16b9 <botlish_fn_17+0x219>
    15ce:	lea    rcx,[rsp+0x48]
    15d3:	mov    rdx,r15
    15d6:	mov    rsi,QWORD PTR [rsp+0x58]
    15db:	mov    rdi,rbx
    15de:	call   15e3 <botlish_fn_17+0x143>
			15df: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    15e3:	test   rax,rax
    15e6:	mov    r13,rax
    15e9:	je     174c <botlish_fn_17+0x2ac>
    15ef:	mov    rdx,QWORD PTR [rsp+0x48]
    15f4:	mov    QWORD PTR [rsp+0x68],rdx
    15f9:	mov    rcx,QWORD PTR [rsp+0x50]
    15fe:	mov    QWORD PTR [rsp+0x60],rcx
    1603:	mov    rsi,r13
    1606:	mov    rdi,rbx
    1609:	call   160e <botlish_fn_17+0x16e>
			160a: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    160e:	test   rax,rax
    1611:	je     174c <botlish_fn_17+0x2ac>
    1617:	cmp    rax,0x6
    161b:	je     165c <botlish_fn_17+0x1bc>
    1621:	mov    rax,QWORD PTR [rbx+0x10]
    1625:	mov    r8,QWORD PTR [rax+0x20]
    1629:	mov    rcx,QWORD PTR [rsp+0x60]
    162e:	mov    rdx,QWORD PTR [rsp+0x68]
    1633:	mov    rsi,r13
    1636:	mov    rdi,rbx
    1639:	call   163e <botlish_fn_17+0x19e>
			163a: R_X86_64_PLT32	rt_str_region_eq-0x4
    163e:	cmp    rax,0x6
    1642:	je     1652 <botlish_fn_17+0x1b2>
    1648:	mov    ecx,0x2
    164d:	jmp    1661 <botlish_fn_17+0x1c1>
    1652:	mov    ecx,0x6
    1657:	jmp    1661 <botlish_fn_17+0x1c1>
    165c:	mov    ecx,0x6
    1661:	cmp    rcx,0x6
    1665:	je     1676 <botlish_fn_17+0x1d6>
    166b:	mov    r9d,0x6
    1671:	jmp    167c <botlish_fn_17+0x1dc>
    1676:	mov    r9d,0x2
    167c:	cmp    r9,0x6
    1680:	jne    1787 <botlish_fn_17+0x2e7>
    1686:	mov    eax,0x2
    168b:	mov    rbx,QWORD PTR [rsp+0x70]
    1690:	mov    r12,QWORD PTR [rsp+0x78]
    1695:	mov    r13,QWORD PTR [rsp+0x80]
    169d:	mov    r14,QWORD PTR [rsp+0x88]
    16a5:	mov    r15,QWORD PTR [rsp+0x90]
    16ad:	add    rsp,0xa0
    16b4:	mov    rsp,rbp
    16b7:	pop    rbp
    16b8:	ret
    16b9:	mov    rsi,QWORD PTR [rsp+0x58]
    16be:	mov    r13,rsi
    16c1:	sar    r13,1
    16c4:	mov    rax,r12
    16c7:	sar    rax,1
    16ca:	cmp    r13,rax
    16cd:	je     1854 <botlish_fn_17+0x3b4>
    16d3:	mov    rsi,r13
    16d6:	sub    rsi,0x1
    16da:	shl    rsi,1
    16dd:	or     rsi,0x1
    16e1:	mov    QWORD PTR [rsp+0x20],rsi
    16e6:	lea    rcx,[rsp+0x38]
    16eb:	mov    rdx,r15
    16ee:	mov    rdi,rbx
    16f1:	call   16f6 <botlish_fn_17+0x256>
			16f2: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    16f6:	test   rax,rax
    16f9:	mov    rsi,rax
    16fc:	je     174c <botlish_fn_17+0x2ac>
    1702:	mov    rdx,QWORD PTR [rsp+0x38]
    1707:	mov    rcx,QWORD PTR [rsp+0x40]
    170c:	mov    rax,QWORD PTR [rbx+0x10]
    1710:	mov    r8,QWORD PTR [rax]
    1713:	mov    rdi,rbx
    1716:	call   171b <botlish_fn_17+0x27b>
			1717: R_X86_64_PLT32	rt_str_region_eq-0x4
    171b:	cmp    rax,0x6
    171f:	je     1821 <botlish_fn_17+0x381>
    1725:	lea    rsi,[r13+0x1]
    1729:	shl    rsi,1
    172c:	or     rsi,0x1
    1730:	mov    QWORD PTR [rsp+0x20],rsi
    1735:	mov    rcx,r15
    1738:	mov    rdx,r14
    173b:	mov    rdi,rbx
    173e:	call   1743 <botlish_fn_17+0x2a3>
			173f: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<generic>
    1743:	test   rax,rax
    1746:	jne    177d <botlish_fn_17+0x2dd>
    174c:	xor    rax,rax
    174f:	mov    rbx,QWORD PTR [rsp+0x70]
    1754:	mov    r12,QWORD PTR [rsp+0x78]
    1759:	mov    r13,QWORD PTR [rsp+0x80]
    1761:	mov    r14,QWORD PTR [rsp+0x88]
    1769:	mov    r15,QWORD PTR [rsp+0x90]
    1771:	add    rsp,0xa0
    1778:	mov    rsp,rbp
    177b:	pop    rbp
    177c:	ret
    177d:	cmp    rax,0x6
    1781:	je     17ee <botlish_fn_17+0x34e>
    1787:	mov    QWORD PTR [rsp+0x20],0x3
    1790:	mov    rsi,QWORD PTR [rsp+0x58]
    1795:	test   rsi,0x1
    179c:	je     17c2 <botlish_fn_17+0x322>
    17a2:	mov    rsi,QWORD PTR [rsp+0x58]
    17a7:	add    rsi,0x2
    17ab:	seto   dil
    17af:	test   dil,dil
    17b2:	jne    17c2 <botlish_fn_17+0x322>
    17b8:	mov    QWORD PTR [rsp+0x58],rsi
    17bd:	jmp    17dc <botlish_fn_17+0x33c>
    17c2:	mov    edx,0x3
    17c7:	mov    rsi,QWORD PTR [rsp+0x58]
    17cc:	mov    rdi,rbx
    17cf:	call   17d4 <botlish_fn_17+0x334>
			17d0: R_X86_64_PLT32	rt_int_add-0x4
    17d4:	mov    rsi,rax
    17d7:	mov    QWORD PTR [rsp+0x58],rax
    17dc:	mov    QWORD PTR [rsp+0x18],rsi
    17e1:	mov    rsi,QWORD PTR [rsp+0x58]
    17e6:	mov    r8,rbx
    17e9:	jmp    14f5 <botlish_fn_17+0x55>
    17ee:	mov    eax,0x6
    17f3:	mov    rbx,QWORD PTR [rsp+0x70]
    17f8:	mov    r12,QWORD PTR [rsp+0x78]
    17fd:	mov    r13,QWORD PTR [rsp+0x80]
    1805:	mov    r14,QWORD PTR [rsp+0x88]
    180d:	mov    r15,QWORD PTR [rsp+0x90]
    1815:	add    rsp,0xa0
    181c:	mov    rsp,rbp
    181f:	pop    rbp
    1820:	ret
    1821:	mov    eax,0x2
    1826:	mov    rbx,QWORD PTR [rsp+0x70]
    182b:	mov    r12,QWORD PTR [rsp+0x78]
    1830:	mov    r13,QWORD PTR [rsp+0x80]
    1838:	mov    r14,QWORD PTR [rsp+0x88]
    1840:	mov    r15,QWORD PTR [rsp+0x90]
    1848:	add    rsp,0xa0
    184f:	mov    rsp,rbp
    1852:	pop    rbp
    1853:	ret
    1854:	mov    eax,0x2
    1859:	mov    rbx,QWORD PTR [rsp+0x70]
    185e:	mov    r12,QWORD PTR [rsp+0x78]
    1863:	mov    r13,QWORD PTR [rsp+0x80]
    186b:	mov    r14,QWORD PTR [rsp+0x88]
    1873:	mov    r15,QWORD PTR [rsp+0x90]
    187b:	add    rsp,0xa0
    1882:	mov    rsp,rbp
    1885:	pop    rbp
    1886:	ret
    1887:	add    BYTE PTR [rsi],al
    1889:	add    BYTE PTR [rax],al
    188b:	add    BYTE PTR [rax],al
    188d:	add    BYTE PTR [rax],al
	...

0000000000001890 <botlish_entry_17: domain?<generic>>:
    1890:	push   rbp
    1891:	mov    rbp,rsp
    1894:	mov    rsi,QWORD PTR [rdx]
    1897:	mov    r8,QWORD PTR [rdx+0x8]
    189b:	mov    rcx,QWORD PTR [rdx+0x10]
    189f:	mov    rdx,r8
    18a2:	call   18a7 <botlish_entry_17+0x17>
			18a3: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<generic>
    18a7:	mov    rsp,rbp
    18aa:	pop    rbp
    18ab:	ret

00000000000018ac <botlish_fn_18: web::is_unreserved<int>>:
    18ac:	push   rbp
    18ad:	mov    rbp,rsp
    18b0:	sub    rsp,0x10
    18b4:	mov    QWORD PTR [rsp],rbx
    18b8:	mov    QWORD PTR [rsp+0x8],r13
    18bd:	mov    r13,rsi
    18c0:	mov    rbx,rdi
    18c3:	mov    rsi,r13
    18c6:	call   18cb <botlish_fn_18+0x1f>
			18c7: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
    18cb:	cmp    rax,0x6
    18cf:	je     1906 <botlish_fn_18+0x5a>
    18d5:	mov    rax,QWORD PTR [rbx+0x30]
    18d9:	mov    rsi,QWORD PTR [rax+0x10]
    18dd:	mov    rdx,r13
    18e0:	mov    rdi,rbx
    18e3:	call   18e8 <botlish_fn_18+0x3c>
			18e4: R_X86_64_PLT32	rt_set_contains-0x4
    18e8:	cmp    rax,0x6
    18ec:	je     18fc <botlish_fn_18+0x50>
    18f2:	mov    eax,0x2
    18f7:	jmp    190b <botlish_fn_18+0x5f>
    18fc:	mov    eax,0x6
    1901:	jmp    190b <botlish_fn_18+0x5f>
    1906:	mov    eax,0x6
    190b:	mov    rbx,QWORD PTR [rsp]
    190f:	mov    r13,QWORD PTR [rsp+0x8]
    1914:	add    rsp,0x10
    1918:	mov    rsp,rbp
    191b:	pop    rbp
    191c:	ret

000000000000191d <botlish_entry_18: web::is_unreserved<int>>:
    191d:	push   rbp
    191e:	mov    rbp,rsp
    1921:	mov    rsi,QWORD PTR [rdx]
    1924:	call   1929 <botlish_entry_18+0xc>
			1925: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1929:	mov    rsp,rbp
    192c:	pop    rbp
    192d:	ret

000000000000192e <botlish_fn_19: web::uri_escape_text<str>>:
    192e:	push   rbp
    192f:	mov    rbp,rsp
    1932:	sub    rsp,0x20
    1936:	mov    QWORD PTR [rsp],rsi
    193a:	mov    edx,0x1
    193f:	mov    QWORD PTR [rsp+0x8],0x1
    1948:	mov    r11,QWORD PTR [rdi+0x10]
    194c:	mov    rcx,QWORD PTR [r11+0xe8]
    1953:	mov    QWORD PTR [rsp+0x10],rcx
    1958:	call   195d <botlish_fn_19+0x2f>
			1959: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    195d:	test   rax,rax
    1960:	jne    1972 <botlish_fn_19+0x44>
    1966:	xor    rax,rax
    1969:	add    rsp,0x20
    196d:	mov    rsp,rbp
    1970:	pop    rbp
    1971:	ret
    1972:	add    rsp,0x20
    1976:	mov    rsp,rbp
    1979:	pop    rbp
    197a:	ret

000000000000197b <botlish_entry_19: web::uri_escape_text<str>>:
    197b:	push   rbp
    197c:	mov    rbp,rsp
    197f:	mov    rsi,QWORD PTR [rdx]
    1982:	call   1987 <botlish_entry_19+0xc>
			1983: R_X86_64_PLT32	botlish_fn_19-0x4 ; web::uri_escape_text<str>
    1987:	mov    rsp,rbp
    198a:	pop    rbp
    198b:	ret

000000000000198c <botlish_fn_20: high_nibble<int>>:
    198c:	push   rbp
    198d:	mov    rbp,rsp
    1990:	sub    rsp,0x10
    1994:	mov    QWORD PTR [rsp],rsi
    1998:	mov    QWORD PTR [rsp+0x8],0x1e1
    19a1:	test   rsi,0x1
    19a8:	jne    19bd <botlish_fn_20+0x31>
    19ae:	mov    edx,0x1e1
    19b3:	call   19b8 <botlish_fn_20+0x2c>
			19b4: R_X86_64_PLT32	rt_int_and-0x4
    19b8:	jmp    19c7 <botlish_fn_20+0x3b>
    19bd:	and    rsi,0x1e1
    19c4:	mov    rax,rsi
    19c7:	sar    rax,0x5
    19cb:	shl    rax,1
    19ce:	or     rax,0x1
    19d2:	add    rsp,0x10
    19d6:	mov    rsp,rbp
    19d9:	pop    rbp
    19da:	ret

00000000000019db <botlish_entry_20: high_nibble<int>>:
    19db:	push   rbp
    19dc:	mov    rbp,rsp
    19df:	mov    rsi,QWORD PTR [rdx]
    19e2:	call   19e7 <botlish_entry_20+0xc>
			19e3: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    19e7:	mov    rsp,rbp
    19ea:	pop    rbp
    19eb:	ret

00000000000019ec <botlish_fn_21: hex_pair<int>>:
    19ec:	push   rbp
    19ed:	mov    rbp,rsp
    19f0:	sub    rsp,0x50
    19f4:	mov    QWORD PTR [rsp+0x30],rbx
    19f9:	mov    QWORD PTR [rsp+0x38],r12
    19fe:	mov    QWORD PTR [rsp+0x40],r13
    1a03:	mov    QWORD PTR [rsp+0x48],r14
    1a08:	mov    QWORD PTR [rsp],rsi
    1a0c:	mov    r12,rsi
    1a0f:	mov    rax,QWORD PTR [rdi+0x30]
    1a13:	mov    rbx,rdi
    1a16:	mov    rsi,QWORD PTR [rax+0x8]
    1a1a:	mov    QWORD PTR [rsp+0x8],rsi
    1a1f:	mov    r13,rsi
    1a22:	mov    rsi,r12
    1a25:	call   1a2a <botlish_fn_21+0x3e>
			1a26: R_X86_64_PLT32	botlish_fn_20-0x4 ; high_nibble<int>
    1a2a:	test   rax,0x1
    1a30:	jne    1a41 <botlish_fn_21+0x55>
    1a36:	mov    rdx,rax
    1a39:	mov    rsi,r13
    1a3c:	jmp    1a5a <botlish_fn_21+0x6e>
    1a41:	mov    rsi,r13
    1a44:	mov    rdx,QWORD PTR [rsi+0x8]
    1a48:	mov    rcx,rax
    1a4b:	sar    rcx,1
    1a4e:	cmp    rcx,rdx
    1a51:	jb     1a70 <botlish_fn_21+0x84>
    1a57:	mov    rdx,rax
    1a5a:	mov    rdi,rbx
    1a5d:	call   1a62 <botlish_fn_21+0x76>
			1a5e: R_X86_64_PLT32	rt_list_get-0x4
    1a62:	test   rax,rax
    1a65:	je     1b35 <botlish_fn_21+0x149>
    1a6b:	jmp    1a78 <botlish_fn_21+0x8c>
    1a70:	mov    rax,QWORD PTR [rsi+0x10]
    1a74:	mov    rax,QWORD PTR [rax+rcx*8]
    1a78:	mov    QWORD PTR [rsp],rax
    1a7c:	mov    rdi,rbx
    1a7f:	mov    r14,rax
    1a82:	mov    rax,QWORD PTR [rdi+0x30]
    1a86:	mov    rsi,QWORD PTR [rax+0x8]
    1a8a:	mov    r13,rsi
    1a8d:	mov    edx,0x21
    1a92:	mov    rsi,r12
    1a95:	call   1a9a <botlish_fn_21+0xae>
			1a96: R_X86_64_PLT32	rt_int_mod-0x4
    1a9a:	test   rax,rax
    1a9d:	je     1b35 <botlish_fn_21+0x149>
    1aa3:	test   rax,0x1
    1aa9:	jne    1aba <botlish_fn_21+0xce>
    1aaf:	mov    rdx,rax
    1ab2:	mov    rsi,r13
    1ab5:	jmp    1ad3 <botlish_fn_21+0xe7>
    1aba:	mov    rsi,r13
    1abd:	mov    rdx,QWORD PTR [rsi+0x8]
    1ac1:	mov    rcx,rax
    1ac4:	sar    rcx,1
    1ac7:	cmp    rcx,rdx
    1aca:	jb     1ae9 <botlish_fn_21+0xfd>
    1ad0:	mov    rdx,rax
    1ad3:	mov    rdi,rbx
    1ad6:	call   1adb <botlish_fn_21+0xef>
			1ad7: R_X86_64_PLT32	rt_list_get-0x4
    1adb:	test   rax,rax
    1ade:	je     1b35 <botlish_fn_21+0x149>
    1ae4:	jmp    1af1 <botlish_fn_21+0x105>
    1ae9:	mov    rax,QWORD PTR [rsi+0x10]
    1aed:	mov    rax,QWORD PTR [rax+rcx*8]
    1af1:	mov    QWORD PTR [rsp+0x8],rax
    1af6:	lea    rcx,[rsp+0x10]
    1afb:	mov    QWORD PTR [rsp+0x10],0x0
    1b04:	mov    rdx,r14
    1b07:	mov    QWORD PTR [rsp+0x18],rdx
    1b0c:	mov    QWORD PTR [rsp+0x20],0x0
    1b15:	mov    QWORD PTR [rsp+0x28],rax
    1b1a:	mov    esi,0x2
    1b1f:	mov    edx,0x4
    1b24:	mov    rdi,rbx
    1b27:	call   1b2c <botlish_fn_21+0x140>
			1b28: R_X86_64_PLT32	rt_construct-0x4
    1b2c:	test   rax,rax
    1b2f:	jne    1b55 <botlish_fn_21+0x169>
    1b35:	xor    rax,rax
    1b38:	mov    rbx,QWORD PTR [rsp+0x30]
    1b3d:	mov    r12,QWORD PTR [rsp+0x38]
    1b42:	mov    r13,QWORD PTR [rsp+0x40]
    1b47:	mov    r14,QWORD PTR [rsp+0x48]
    1b4c:	add    rsp,0x50
    1b50:	mov    rsp,rbp
    1b53:	pop    rbp
    1b54:	ret
    1b55:	mov    rbx,QWORD PTR [rsp+0x30]
    1b5a:	mov    r12,QWORD PTR [rsp+0x38]
    1b5f:	mov    r13,QWORD PTR [rsp+0x40]
    1b64:	mov    r14,QWORD PTR [rsp+0x48]
    1b69:	add    rsp,0x50
    1b6d:	mov    rsp,rbp
    1b70:	pop    rbp
    1b71:	ret

0000000000001b72 <botlish_entry_21: hex_pair<int>>:
    1b72:	push   rbp
    1b73:	mov    rbp,rsp
    1b76:	sub    rsp,0x10
    1b7a:	mov    QWORD PTR [rsp],r12
    1b7e:	mov    r12,rdi
    1b81:	mov    rsi,QWORD PTR [rdx]
    1b84:	call   1b89 <botlish_entry_21+0x17>
			1b85: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1b89:	mov    r8,QWORD PTR [rip+0x0]        # 1b90 <botlish_entry_21+0x1e>
			1b8c: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1b90:	mov    rsi,rax
    1b93:	mov    rdi,r12
    1b96:	call   r8
    1b99:	mov    r12,QWORD PTR [rsp]
    1b9d:	add    rsp,0x10
    1ba1:	mov    rsp,rbp
    1ba4:	pop    rbp
    1ba5:	ret

0000000000001ba6 <botlish_fn_22: esc_bytes<List[int], int, str>>:
    1ba6:	push   rbp
    1ba7:	mov    rbp,rsp
    1baa:	sub    rsp,0x90
    1bb1:	mov    QWORD PTR [rsp+0x60],rbx
    1bb6:	mov    QWORD PTR [rsp+0x68],r12
    1bbb:	mov    QWORD PTR [rsp+0x70],r13
    1bc0:	mov    QWORD PTR [rsp+0x78],r14
    1bc5:	mov    QWORD PTR [rsp+0x80],r15
    1bcd:	mov    QWORD PTR [rsp],rsi
    1bd1:	mov    QWORD PTR [rsp+0x8],rcx
    1bd6:	sar    rdx,1
    1bd9:	mov    r13,rdx
    1bdc:	lea    r14,[rsp+0x20]
    1be1:	mov    rbx,rdi
    1be4:	mov    r12,rsi
    1be7:	mov    QWORD PTR [rsp+0x50],rcx
    1bec:	mov    rsi,r12
    1bef:	mov    rdi,rbx
    1bf2:	call   1bf7 <botlish_fn_22+0x51>
			1bf3: R_X86_64_PLT32	rt_list_len-0x4
    1bf7:	sar    rax,1
    1bfa:	cmp    r13,rax
    1bfd:	jge    1d0d <botlish_fn_22+0x167>
    1c03:	mov    rax,QWORD PTR [rbx+0x10]
    1c07:	mov    r15,QWORD PTR [rax+0x10]
    1c0b:	mov    QWORD PTR [rsp+0x10],r15
    1c10:	mov    rcx,QWORD PTR [r12+0x8]
    1c15:	mov    rax,r13
    1c18:	shl    rax,1
    1c1b:	or     rax,0x1
    1c1f:	sar    rax,1
    1c22:	cmp    rax,rcx
    1c25:	jb     1c51 <botlish_fn_22+0xab>
    1c2b:	mov    rdx,r13
    1c2e:	shl    rdx,1
    1c31:	or     rdx,0x1
    1c35:	mov    rsi,r12
    1c38:	mov    rdi,rbx
    1c3b:	call   1c40 <botlish_fn_22+0x9a>
			1c3c: R_X86_64_PLT32	rt_list_get-0x4
    1c40:	test   rax,rax
    1c43:	je     1cc8 <botlish_fn_22+0x122>
    1c49:	mov    rsi,rax
    1c4c:	jmp    1c5a <botlish_fn_22+0xb4>
    1c51:	mov    rcx,QWORD PTR [r12+0x10]
    1c56:	mov    rsi,QWORD PTR [rcx+rax*8]
    1c5a:	mov    QWORD PTR [rsp+0x18],rsi
    1c5f:	mov    rdi,rbx
    1c62:	call   1c67 <botlish_fn_22+0xc1>
			1c63: R_X86_64_PLT32	botlish_fn_21-0x4 ; hex_pair<int>
    1c67:	test   rax,rax
    1c6a:	je     1cc8 <botlish_fn_22+0x122>
    1c70:	mov    QWORD PTR [rsp+0x18],rax
    1c75:	mov    rcx,rax
    1c78:	mov    QWORD PTR [rsp+0x20],0x0
    1c81:	mov    rax,QWORD PTR [rsp+0x50]
    1c86:	mov    QWORD PTR [rsp+0x28],rax
    1c8b:	mov    QWORD PTR [rsp+0x30],0x0
    1c94:	mov    QWORD PTR [rsp+0x38],r15
    1c99:	mov    QWORD PTR [rsp+0x40],0x0
    1ca2:	mov    rax,rcx
    1ca5:	mov    QWORD PTR [rsp+0x48],rax
    1caa:	mov    esi,0x2
    1caf:	mov    edx,0x6
    1cb4:	mov    rcx,r14
    1cb7:	mov    rdi,rbx
    1cba:	call   1cbf <botlish_fn_22+0x119>
			1cbb: R_X86_64_PLT32	rt_construct-0x4
    1cbf:	test   rax,rax
    1cc2:	jne    1cf3 <botlish_fn_22+0x14d>
    1cc8:	xor    rax,rax
    1ccb:	mov    rbx,QWORD PTR [rsp+0x60]
    1cd0:	mov    r12,QWORD PTR [rsp+0x68]
    1cd5:	mov    r13,QWORD PTR [rsp+0x70]
    1cda:	mov    r14,QWORD PTR [rsp+0x78]
    1cdf:	mov    r15,QWORD PTR [rsp+0x80]
    1ce7:	add    rsp,0x90
    1cee:	mov    rsp,rbp
    1cf1:	pop    rbp
    1cf2:	ret
    1cf3:	mov    QWORD PTR [rsp],r12
    1cf7:	mov    QWORD PTR [rsp+0x8],rax
    1cfc:	add    r13,0x1
    1d03:	mov    QWORD PTR [rsp+0x50],rax
    1d08:	jmp    1bec <botlish_fn_22+0x46>
    1d0d:	mov    rax,QWORD PTR [rsp+0x50]
    1d12:	mov    rbx,QWORD PTR [rsp+0x60]
    1d17:	mov    r12,QWORD PTR [rsp+0x68]
    1d1c:	mov    r13,QWORD PTR [rsp+0x70]
    1d21:	mov    r14,QWORD PTR [rsp+0x78]
    1d26:	mov    r15,QWORD PTR [rsp+0x80]
    1d2e:	add    rsp,0x90
    1d35:	mov    rsp,rbp
    1d38:	pop    rbp
    1d39:	ret

0000000000001d3a <botlish_entry_22: esc_bytes<List[int], int, str>>:
    1d3a:	push   rbp
    1d3b:	mov    rbp,rsp
    1d3e:	sub    rsp,0x10
    1d42:	mov    QWORD PTR [rsp],r12
    1d46:	mov    r12,rdi
    1d49:	mov    rsi,QWORD PTR [rdx]
    1d4c:	mov    r8,QWORD PTR [rdx+0x8]
    1d50:	mov    rcx,QWORD PTR [rdx+0x10]
    1d54:	mov    rdx,r8
    1d57:	call   1d5c <botlish_entry_22+0x22>
			1d58: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1d5c:	mov    r8,QWORD PTR [rip+0x0]        # 1d63 <botlish_entry_22+0x29>
			1d5f: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1d63:	mov    rsi,rax
    1d66:	mov    rdi,r12
    1d69:	call   r8
    1d6c:	mov    r12,QWORD PTR [rsp]
    1d70:	add    rsp,0x10
    1d74:	mov    rsp,rbp
    1d77:	pop    rbp
    1d78:	ret

0000000000001d79 <botlish_fn_23: esc_char<str>>:
    1d79:	push   rbp
    1d7a:	mov    rbp,rsp
    1d7d:	sub    rsp,0x40
    1d81:	mov    QWORD PTR [rsp+0x20],rbx
    1d86:	mov    QWORD PTR [rsp+0x28],r12
    1d8b:	mov    QWORD PTR [rsp+0x30],r13
    1d90:	mov    rbx,rdi
    1d93:	mov    QWORD PTR [rsp+0x8],0x0
    1d9c:	mov    QWORD PTR [rsp+0x10],0x0
    1da5:	mov    QWORD PTR [rsp],rsi
    1da9:	mov    r13,rsi
    1dac:	mov    rsi,r13
    1daf:	mov    rdi,rbx
    1db2:	call   1db7 <botlish_fn_23+0x3e>
			1db3: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1db7:	mov    rcx,rax
    1dba:	mov    r12,rax
    1dbd:	test   rax,rcx
    1dc0:	je     1e9e <botlish_fn_23+0x125>
    1dc6:	mov    rax,r12
    1dc9:	mov    QWORD PTR [rsp],rax
    1dcd:	mov    rsi,r12
    1dd0:	mov    rdi,rbx
    1dd3:	call   1dd8 <botlish_fn_23+0x5f>
			1dd4: R_X86_64_PLT32	rt_list_len-0x4
    1dd8:	sar    rax,1
    1ddb:	cmp    rax,0x1
    1ddf:	je     1e1c <botlish_fn_23+0xa3>
    1de5:	mov    edx,0x1
    1dea:	mov    QWORD PTR [rsp+0x8],0x1
    1df3:	mov    rdi,rbx
    1df6:	mov    rax,QWORD PTR [rdi+0x10]
    1dfa:	mov    rcx,QWORD PTR [rax+0xe8]
    1e01:	mov    QWORD PTR [rsp+0x10],rcx
    1e06:	mov    rsi,r12
    1e09:	call   1e0e <botlish_fn_23+0x95>
			1e0a: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1e0e:	test   rax,rax
    1e11:	je     1e9e <botlish_fn_23+0x125>
    1e17:	jmp    1ebf <botlish_fn_23+0x146>
    1e1c:	mov    rsi,r12
    1e1f:	mov    rax,QWORD PTR [rsi+0x8]
    1e23:	mov    r12,rsi
    1e26:	test   rax,rax
    1e29:	jne    1e50 <botlish_fn_23+0xd7>
    1e2f:	mov    edx,0x1
    1e34:	mov    rsi,r12
    1e37:	mov    rdi,rbx
    1e3a:	call   1e3f <botlish_fn_23+0xc6>
			1e3b: R_X86_64_PLT32	rt_list_get-0x4
    1e3f:	test   rax,rax
    1e42:	je     1e9e <botlish_fn_23+0x125>
    1e48:	mov    rsi,rax
    1e4b:	jmp    1e5a <botlish_fn_23+0xe1>
    1e50:	mov    rsi,r12
    1e53:	mov    rax,QWORD PTR [rsi+0x10]
    1e57:	mov    rsi,QWORD PTR [rax]
    1e5a:	mov    rdi,rbx
    1e5d:	call   1e62 <botlish_fn_23+0xe9>
			1e5e: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::is_unreserved<int>
    1e62:	cmp    rax,0x6
    1e66:	je     1ebc <botlish_fn_23+0x143>
    1e6c:	mov    edx,0x1
    1e71:	mov    QWORD PTR [rsp+0x8],0x1
    1e7a:	mov    rdi,rbx
    1e7d:	mov    rax,QWORD PTR [rdi+0x10]
    1e81:	mov    rcx,QWORD PTR [rax+0xe8]
    1e88:	mov    QWORD PTR [rsp+0x10],rcx
    1e8d:	mov    rsi,r12
    1e90:	call   1e95 <botlish_fn_23+0x11c>
			1e91: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_bytes<List[int], int, str>
    1e95:	test   rax,rax
    1e98:	jne    1eb9 <botlish_fn_23+0x140>
    1e9e:	xor    rax,rax
    1ea1:	mov    rbx,QWORD PTR [rsp+0x20]
    1ea6:	mov    r12,QWORD PTR [rsp+0x28]
    1eab:	mov    r13,QWORD PTR [rsp+0x30]
    1eb0:	add    rsp,0x40
    1eb4:	mov    rsp,rbp
    1eb7:	pop    rbp
    1eb8:	ret
    1eb9:	mov    r13,rax
    1ebc:	mov    rax,r13
    1ebf:	mov    rbx,QWORD PTR [rsp+0x20]
    1ec4:	mov    r12,QWORD PTR [rsp+0x28]
    1ec9:	mov    r13,QWORD PTR [rsp+0x30]
    1ece:	add    rsp,0x40
    1ed2:	mov    rsp,rbp
    1ed5:	pop    rbp
    1ed6:	ret

0000000000001ed7 <botlish_entry_23: esc_char<str>>:
    1ed7:	push   rbp
    1ed8:	mov    rbp,rsp
    1edb:	sub    rsp,0x10
    1edf:	mov    QWORD PTR [rsp],r12
    1ee3:	mov    r12,rdi
    1ee6:	mov    rsi,QWORD PTR [rdx]
    1ee9:	call   1eee <botlish_entry_23+0x17>
			1eea: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1eee:	mov    r8,QWORD PTR [rip+0x0]        # 1ef5 <botlish_entry_23+0x1e>
			1ef1: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1ef5:	mov    rsi,rax
    1ef8:	mov    rdi,r12
    1efb:	call   r8
    1efe:	mov    r12,QWORD PTR [rsp]
    1f02:	add    rsp,0x10
    1f06:	mov    rsp,rbp
    1f09:	pop    rbp
    1f0a:	ret

0000000000001f0b <botlish_fn_24: esc_from<str, int, str>>:
    1f0b:	push   rbp
    1f0c:	mov    rbp,rsp
    1f0f:	sub    rsp,0x80
    1f16:	mov    QWORD PTR [rsp+0x50],rbx
    1f1b:	mov    QWORD PTR [rsp+0x58],r12
    1f20:	mov    QWORD PTR [rsp+0x60],r13
    1f25:	mov    QWORD PTR [rsp+0x68],r14
    1f2a:	mov    QWORD PTR [rsp+0x70],r15
    1f2f:	mov    r14,rdi
    1f32:	mov    QWORD PTR [rsp+0x10],0x0
    1f3b:	mov    QWORD PTR [rsp+0x18],0x0
    1f44:	mov    QWORD PTR [rsp],rsi
    1f48:	mov    QWORD PTR [rsp+0x8],rcx
    1f4d:	mov    r15,rcx
    1f50:	sar    rdx,1
    1f53:	mov    r12,rdx
    1f56:	lea    r13,[rsp+0x30]
    1f5b:	mov    rbx,rsi
    1f5e:	mov    rsi,rbx
    1f61:	mov    rdi,r14
    1f64:	call   1f69 <botlish_fn_24+0x5e>
			1f65: R_X86_64_PLT32	rt_str_len-0x4
    1f69:	sar    rax,1
    1f6c:	cmp    r12,rax
    1f6f:	jge    201a <botlish_fn_24+0x10f>
    1f75:	mov    rdx,r12
    1f78:	shl    rdx,1
    1f7b:	or     rdx,0x1
    1f7f:	mov    QWORD PTR [rsp+0x10],rdx
    1f84:	add    r12,0x1
    1f8b:	mov    rcx,r12
    1f8e:	shl    rcx,1
    1f91:	or     rcx,0x1
    1f95:	mov    QWORD PTR [rsp+0x18],rcx
    1f9a:	mov    rsi,rbx
    1f9d:	mov    rdi,r14
    1fa0:	call   1fa5 <botlish_fn_24+0x9a>
			1fa1: R_X86_64_PLT32	rt_substr-0x4
    1fa5:	test   rax,rax
    1fa8:	je     204c <botlish_fn_24+0x141>
    1fae:	mov    QWORD PTR [rsp+0x10],rax
    1fb3:	mov    rsi,rax
    1fb6:	mov    rdi,r14
    1fb9:	call   1fbe <botlish_fn_24+0xb3>
			1fba: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_char<str>
    1fbe:	test   rax,rax
    1fc1:	je     204c <botlish_fn_24+0x141>
    1fc7:	mov    QWORD PTR [rsp+0x10],rax
    1fcc:	mov    QWORD PTR [rsp+0x30],0x0
    1fd5:	mov    rcx,r15
    1fd8:	mov    QWORD PTR [rsp+0x38],rcx
    1fdd:	mov    QWORD PTR [rsp+0x40],0x0
    1fe6:	mov    QWORD PTR [rsp+0x48],rax
    1feb:	mov    esi,0x2
    1ff0:	mov    edx,0x4
    1ff5:	mov    rcx,r13
    1ff8:	mov    rdi,r14
    1ffb:	call   2000 <botlish_fn_24+0xf5>
			1ffc: R_X86_64_PLT32	rt_construct-0x4
    2000:	test   rax,rax
    2003:	je     204c <botlish_fn_24+0x141>
    2009:	mov    QWORD PTR [rsp],rbx
    200d:	mov    QWORD PTR [rsp+0x8],rax
    2012:	mov    r15,rax
    2015:	jmp    1f5e <botlish_fn_24+0x53>
    201a:	mov    rcx,r15
    201d:	xor    rsi,rsi
    2020:	lea    rax,[rsp+0x20]
    2025:	mov    QWORD PTR [rsp+0x20],0x0
    202e:	mov    QWORD PTR [rsp+0x28],rcx
    2033:	mov    edx,0x2
    2038:	mov    rcx,rax
    203b:	mov    rdi,r14
    203e:	call   2043 <botlish_fn_24+0x138>
			203f: R_X86_64_PLT32	rt_construct-0x4
    2043:	test   rax,rax
    2046:	jne    2074 <botlish_fn_24+0x169>
    204c:	xor    rax,rax
    204f:	mov    rbx,QWORD PTR [rsp+0x50]
    2054:	mov    r12,QWORD PTR [rsp+0x58]
    2059:	mov    r13,QWORD PTR [rsp+0x60]
    205e:	mov    r14,QWORD PTR [rsp+0x68]
    2063:	mov    r15,QWORD PTR [rsp+0x70]
    2068:	add    rsp,0x80
    206f:	mov    rsp,rbp
    2072:	pop    rbp
    2073:	ret
    2074:	mov    rbx,QWORD PTR [rsp+0x50]
    2079:	mov    r12,QWORD PTR [rsp+0x58]
    207e:	mov    r13,QWORD PTR [rsp+0x60]
    2083:	mov    r14,QWORD PTR [rsp+0x68]
    2088:	mov    r15,QWORD PTR [rsp+0x70]
    208d:	add    rsp,0x80
    2094:	mov    rsp,rbp
    2097:	pop    rbp
    2098:	ret

0000000000002099 <botlish_entry_24: esc_from<str, int, str>>:
    2099:	push   rbp
    209a:	mov    rbp,rsp
    209d:	mov    rsi,QWORD PTR [rdx]
    20a0:	mov    r8,QWORD PTR [rdx+0x8]
    20a4:	mov    rcx,QWORD PTR [rdx+0x10]
    20a8:	mov    rdx,r8
    20ab:	call   20b0 <botlish_entry_24+0x17>
			20ac: R_X86_64_PLT32	botlish_fn_24-0x4 ; esc_from<str, int, str>
    20b0:	mov    rsp,rbp
    20b3:	pop    rbp
    20b4:	ret

00000000000020b5 <botlish_fn_25: check<int, int, str, str>>:
    20b5:	push   rbp
    20b6:	mov    rbp,rsp
    20b9:	sub    rsp,0x50
    20bd:	mov    QWORD PTR [rsp+0x20],rbx
    20c2:	mov    QWORD PTR [rsp+0x28],r12
    20c7:	mov    QWORD PTR [rsp+0x30],r13
    20cc:	mov    QWORD PTR [rsp+0x38],r14
    20d1:	mov    QWORD PTR [rsp+0x40],r15
    20d6:	mov    r14,rdi
    20d9:	mov    QWORD PTR [rsp+0x18],0x0
    20e2:	mov    QWORD PTR [rsp],rdx
    20e6:	mov    QWORD PTR [rsp+0x8],rcx
    20eb:	mov    QWORD PTR [rsp+0x10],r8
    20f0:	mov    r13,r8
    20f3:	sar    rsi,1
    20f6:	mov    r12,rsi
    20f9:	mov    r15,rdx
    20fc:	test   r12,r12
    20ff:	jle    21c1 <botlish_fn_25+0x10c>
    2105:	mov    rbx,rcx
    2108:	mov    rsi,rbx
    210b:	mov    rdi,r14
    210e:	call   2113 <botlish_fn_25+0x5e>
			210f: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
    2113:	test   rax,rax
    2116:	jne    2141 <botlish_fn_25+0x8c>
    211c:	xor    rax,rax
    211f:	mov    rbx,QWORD PTR [rsp+0x20]
    2124:	mov    r12,QWORD PTR [rsp+0x28]
    2129:	mov    r13,QWORD PTR [rsp+0x30]
    212e:	mov    r14,QWORD PTR [rsp+0x38]
    2133:	mov    r15,QWORD PTR [rsp+0x40]
    2138:	add    rsp,0x50
    213c:	mov    rsp,rbp
    213f:	pop    rbp
    2140:	ret
    2141:	cmp    rax,0x6
    2145:	je     2161 <botlish_fn_25+0xac>
    214b:	mov    edx,0x1
    2150:	mov    QWORD PTR [rsp+0x18],0x1
    2159:	mov    rsi,r15
    215c:	jmp    2172 <botlish_fn_25+0xbd>
    2161:	mov    edx,0x3
    2166:	mov    QWORD PTR [rsp+0x18],0x3
    216f:	mov    rsi,r15
    2172:	mov    rax,rsi
    2175:	and    rax,rdx
    2178:	test   rax,0x1
    217e:	je     2199 <botlish_fn_25+0xe4>
    2184:	lea    rcx,[rdx-0x1]
    2188:	mov    rax,rsi
    218b:	add    rax,rcx
    218e:	seto   cl
    2191:	test   cl,cl
    2193:	je     21a1 <botlish_fn_25+0xec>
    2199:	mov    rdi,r14
    219c:	call   21a1 <botlish_fn_25+0xec>
			219d: R_X86_64_PLT32	rt_int_add-0x4
    21a1:	mov    QWORD PTR [rsp],rax
    21a5:	mov    QWORD PTR [rsp+0x8],rbx
    21aa:	mov    r8,r13
    21ad:	mov    QWORD PTR [rsp+0x10],r8
    21b2:	sub    r12,0x1
    21b6:	mov    rcx,rbx
    21b9:	mov    r15,rax
    21bc:	jmp    20fc <botlish_fn_25+0x47>
    21c1:	mov    rax,r15
    21c4:	mov    rbx,QWORD PTR [rsp+0x20]
    21c9:	mov    r12,QWORD PTR [rsp+0x28]
    21ce:	mov    r13,QWORD PTR [rsp+0x30]
    21d3:	mov    r14,QWORD PTR [rsp+0x38]
    21d8:	mov    r15,QWORD PTR [rsp+0x40]
    21dd:	add    rsp,0x50
    21e1:	mov    rsp,rbp
    21e4:	pop    rbp
    21e5:	ret

00000000000021e6 <botlish_entry_25: check<int, int, str, str>>:
    21e6:	push   rbp
    21e7:	mov    rbp,rsp
    21ea:	mov    rsi,QWORD PTR [rdx]
    21ed:	mov    r9,QWORD PTR [rdx+0x8]
    21f1:	mov    rcx,QWORD PTR [rdx+0x10]
    21f5:	mov    r8,QWORD PTR [rdx+0x18]
    21f9:	mov    rdx,r9
    21fc:	call   2201 <botlish_entry_25+0x1b>
			21fd: R_X86_64_PLT32	botlish_fn_25-0x4 ; check<int, int, str, str>
    2201:	mov    rsp,rbp
    2204:	pop    rbp
    2205:	ret

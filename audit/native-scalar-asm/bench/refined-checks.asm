; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 8903  (per function: 1443 39 289 609 74 74 74 125 125 601 262 222 238 496 468 1244 137 94 103 474 491 426 451 344)
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
;   botlish_fn_12 / botlish_entry_12 -> local_char?<generic>
;   botlish_fn_13 / botlish_entry_13 -> scan_while<generic>
;   botlish_fn_14 / botlish_entry_14 -> tld?<generic>
;   botlish_fn_15 / botlish_entry_15 -> domain?<generic>
;   botlish_fn_16 / botlish_entry_16 -> web::is_unreserved<int>
;   botlish_fn_17 / botlish_entry_17 -> web::uri_escape_text<str>
;   botlish_fn_18 / botlish_entry_18 -> high_nibble<int>
;   botlish_fn_19 / botlish_entry_19 -> hex_pair<int>
;   botlish_fn_20 / botlish_entry_20 -> esc_bytes<List[int], int, str>
;   botlish_fn_21 / botlish_entry_21 -> esc_char<str>
;   botlish_fn_22 / botlish_entry_22 -> esc_from<str, int, str>
;   botlish_fn_23 / botlish_entry_23 -> check<int, int, str, str>


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
			427: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::uri_escape_text<str>
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
			473: R_X86_64_PLT32	botlish_fn_23-0x4 ; check<int, int, str, str>
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
			4c0: R_X86_64_PLT32	botlish_fn_23-0x4 ; check<int, int, str, str>
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
     674:	mov    esi,0x2
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
     ac9:	add    BYTE PTR [rax],al
     acb:	add    BYTE PTR [rax],al
     acd:	add    BYTE PTR [rax],al
	...

0000000000000ad0 <botlish_fn_9: web::emailish?<str>>:
     ad0:	push   rbp
     ad1:	mov    rbp,rsp
     ad4:	sub    rsp,0x50
     ad8:	mov    QWORD PTR [rsp+0x30],rbx
     add:	mov    QWORD PTR [rsp+0x38],r12
     ae2:	mov    QWORD PTR [rsp+0x40],r13
     ae7:	mov    QWORD PTR [rsp+0x48],r14
     aec:	mov    r14,rdi
     aef:	mov    QWORD PTR [rsp],rsi
     af3:	mov    r13,rsi
     af6:	mov    rsi,r13
     af9:	mov    rdi,r14
     afc:	call   b01 <botlish_fn_9+0x31>
			afd: R_X86_64_PLT32	rt_str_len-0x4
     b01:	mov    rbx,rax
     b04:	mov    QWORD PTR [rsp+0x8],rax
     b09:	mov    esi,0x1
     b0e:	mov    QWORD PTR [rsp+0x10],0x1
     b17:	mov    rdi,r14
     b1a:	mov    rcx,QWORD PTR [rdi+0x10]
     b1e:	mov    rdx,QWORD PTR [rcx+0xc8]
     b25:	mov    QWORD PTR [rsp+0x18],rdx
     b2a:	mov    rcx,rbx
     b2d:	mov    r8,r13
     b30:	call   b35 <botlish_fn_9+0x65>
			b31: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<generic>
     b35:	mov    r12,rax
     b38:	test   r12,r12
     b3b:	je     c97 <botlish_fn_9+0x1c7>
     b41:	mov    QWORD PTR [rsp+0x10],r12
     b46:	test   r12,0x1
     b4d:	jne    b78 <botlish_fn_9+0xa8>
     b53:	mov    edx,0x1
     b58:	mov    rsi,r12
     b5b:	mov    rdi,r14
     b5e:	call   b63 <botlish_fn_9+0x93>
			b5f: R_X86_64_PLT32	rt_int_cmp-0x4
     b63:	mov    ecx,0x2
     b68:	test   rax,rax
     b6b:	cmove  rcx,QWORD PTR [rip+0x175]        # ce8 <botlish_fn_9+0x218>
     b73:	jmp    b89 <botlish_fn_9+0xb9>
     b78:	mov    ecx,0x2
     b7d:	cmp    r12,0x1
     b81:	cmove  rcx,QWORD PTR [rip+0x15f]        # ce8 <botlish_fn_9+0x218>
     b89:	cmp    rcx,0x6
     b8d:	je     cc6 <botlish_fn_9+0x1f6>
     b93:	mov    rax,r12
     b96:	and    rax,rbx
     b99:	test   rax,0x1
     b9f:	jne    bc8 <botlish_fn_9+0xf8>
     ba5:	mov    rdx,rbx
     ba8:	mov    rsi,r12
     bab:	mov    rdi,r14
     bae:	call   bb3 <botlish_fn_9+0xe3>
			baf: R_X86_64_PLT32	rt_int_cmp-0x4
     bb3:	mov    ecx,0x2
     bb8:	test   rax,rax
     bbb:	cmovge rcx,QWORD PTR [rip+0x125]        # ce8 <botlish_fn_9+0x218>
     bc3:	jmp    bd8 <botlish_fn_9+0x108>
     bc8:	mov    ecx,0x2
     bcd:	cmp    r12,rbx
     bd0:	cmovge rcx,QWORD PTR [rip+0x110]        # ce8 <botlish_fn_9+0x218>
     bd8:	cmp    rcx,0x6
     bdc:	je     cbc <botlish_fn_9+0x1ec>
     be2:	lea    rcx,[rsp+0x20]
     be7:	mov    rdx,r13
     bea:	mov    rsi,r12
     bed:	mov    rdi,r14
     bf0:	call   bf5 <botlish_fn_9+0x125>
			bf1: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
     bf5:	test   rax,rax
     bf8:	mov    rsi,rax
     bfb:	je     c97 <botlish_fn_9+0x1c7>
     c01:	mov    rdx,QWORD PTR [rsp+0x20]
     c06:	mov    rcx,QWORD PTR [rsp+0x28]
     c0b:	mov    rdi,r14
     c0e:	mov    rdi,QWORD PTR [rdi+0x10]
     c12:	mov    r8,QWORD PTR [rdi+0xd0]
     c19:	mov    rdi,r14
     c1c:	call   c21 <botlish_fn_9+0x151>
			c1d: R_X86_64_PLT32	rt_str_region_eq-0x4
     c21:	cmp    rax,0x6
     c25:	je     c35 <botlish_fn_9+0x165>
     c2b:	mov    eax,0x2
     c30:	jmp    ccb <botlish_fn_9+0x1fb>
     c35:	mov    QWORD PTR [rsp+0x18],0x3
     c3e:	test   r12,0x1
     c45:	jne    c53 <botlish_fn_9+0x183>
     c4b:	mov    rcx,r12
     c4e:	jmp    c68 <botlish_fn_9+0x198>
     c53:	mov    rsi,r12
     c56:	add    rsi,0x2
     c5a:	mov    rcx,r12
     c5d:	seto   al
     c60:	test   al,al
     c62:	je     c7b <botlish_fn_9+0x1ab>
     c68:	mov    edx,0x3
     c6d:	mov    rsi,rcx
     c70:	mov    rdi,r14
     c73:	call   c78 <botlish_fn_9+0x1a8>
			c74: R_X86_64_PLT32	rt_int_add-0x4
     c78:	mov    rsi,rax
     c7b:	mov    QWORD PTR [rsp+0x10],rsi
     c80:	mov    rcx,r13
     c83:	mov    rdx,rbx
     c86:	mov    rdi,r14
     c89:	call   c8e <botlish_fn_9+0x1be>
			c8a: R_X86_64_PLT32	botlish_fn_15-0x4 ; domain?<generic>
     c8e:	test   rax,rax
     c91:	jne    ccb <botlish_fn_9+0x1fb>
     c97:	xor    rax,rax
     c9a:	mov    rbx,QWORD PTR [rsp+0x30]
     c9f:	mov    r12,QWORD PTR [rsp+0x38]
     ca4:	mov    r13,QWORD PTR [rsp+0x40]
     ca9:	mov    r14,QWORD PTR [rsp+0x48]
     cae:	add    rsp,0x50
     cb2:	mov    rsp,rbp
     cb5:	pop    rbp
     cb6:	ret
     cb7:	jmp    ccb <botlish_fn_9+0x1fb>
     cbc:	mov    eax,0x2
     cc1:	jmp    ccb <botlish_fn_9+0x1fb>
     cc6:	mov    eax,0x2
     ccb:	mov    rbx,QWORD PTR [rsp+0x30]
     cd0:	mov    r12,QWORD PTR [rsp+0x38]
     cd5:	mov    r13,QWORD PTR [rsp+0x40]
     cda:	mov    r14,QWORD PTR [rsp+0x48]
     cdf:	add    rsp,0x50
     ce3:	mov    rsp,rbp
     ce6:	pop    rbp
     ce7:	ret
     ce8:	(bad)
     ce9:	add    BYTE PTR [rax],al
     ceb:	add    BYTE PTR [rax],al
     ced:	add    BYTE PTR [rax],al
	...

0000000000000cf0 <botlish_entry_9: web::emailish?<str>>:
     cf0:	push   rbp
     cf1:	mov    rbp,rsp
     cf4:	mov    rsi,QWORD PTR [rdx]
     cf7:	call   cfc <botlish_entry_9+0xc>
			cf8: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
     cfc:	mov    rsp,rbp
     cff:	pop    rbp
     d00:	ret

0000000000000d01 <botlish_fn_10: char_at<generic>>:
     d01:	push   rbp
     d02:	mov    rbp,rsp
     d05:	sub    rsp,0x50
     d09:	mov    QWORD PTR [rsp+0x20],rbx
     d0e:	mov    QWORD PTR [rsp+0x28],r12
     d13:	mov    QWORD PTR [rsp+0x30],r13
     d18:	mov    QWORD PTR [rsp+0x38],r14
     d1d:	mov    QWORD PTR [rsp+0x40],r15
     d22:	mov    r12,rdi
     d25:	mov    r15,rcx
     d28:	mov    QWORD PTR [rsp],rsi
     d2c:	mov    QWORD PTR [rsp+0x8],rdx
     d31:	mov    r13,rdx
     d34:	mov    QWORD PTR [rsp+0x10],0x3
     d3d:	test   rsi,0x1
     d44:	jne    d52 <botlish_fn_10+0x51>
     d4a:	mov    rbx,rsi
     d4d:	jmp    d72 <botlish_fn_10+0x71>
     d52:	mov    rax,rsi
     d55:	add    rax,0x2
     d59:	mov    rbx,rsi
     d5c:	seto   cl
     d5f:	test   cl,cl
     d61:	jne    d72 <botlish_fn_10+0x71>
     d67:	mov    rdi,r12
     d6a:	mov    r14,rax
     d6d:	jmp    d88 <botlish_fn_10+0x87>
     d72:	mov    edx,0x3
     d77:	mov    rsi,rbx
     d7a:	mov    rdi,r12
     d7d:	call   d82 <botlish_fn_10+0x81>
			d7e: R_X86_64_PLT32	rt_int_add-0x4
     d82:	mov    r14,rax
     d85:	mov    rdi,r12
     d88:	mov    rcx,r14
     d8b:	mov    rdx,rbx
     d8e:	mov    rsi,r13
     d91:	call   d96 <botlish_fn_10+0x95>
			d92: R_X86_64_PLT32	rt_str_region_check-0x4
     d96:	test   rax,rax
     d99:	jne    dc4 <botlish_fn_10+0xc3>
     d9f:	xor    rax,rax
     da2:	mov    rbx,QWORD PTR [rsp+0x20]
     da7:	mov    r12,QWORD PTR [rsp+0x28]
     dac:	mov    r13,QWORD PTR [rsp+0x30]
     db1:	mov    r14,QWORD PTR [rsp+0x38]
     db6:	mov    r15,QWORD PTR [rsp+0x40]
     dbb:	add    rsp,0x50
     dbf:	mov    rsp,rbp
     dc2:	pop    rbp
     dc3:	ret
     dc4:	mov    rcx,r15
     dc7:	mov    QWORD PTR [rcx],rbx
     dca:	mov    rax,r14
     dcd:	mov    QWORD PTR [rcx+0x8],rax
     dd1:	mov    rax,r13
     dd4:	mov    rbx,QWORD PTR [rsp+0x20]
     dd9:	mov    r12,QWORD PTR [rsp+0x28]
     dde:	mov    r13,QWORD PTR [rsp+0x30]
     de3:	mov    r14,QWORD PTR [rsp+0x38]
     de8:	mov    r15,QWORD PTR [rsp+0x40]
     ded:	add    rsp,0x50
     df1:	mov    rsp,rbp
     df4:	pop    rbp
     df5:	ret

0000000000000df6 <botlish_entry_10: char_at<generic>>:
     df6:	push   rbp
     df7:	mov    rbp,rsp
     dfa:	ud2

0000000000000dfc <botlish_fn_11: char_at<generic>>:
     dfc:	push   rbp
     dfd:	mov    rbp,rsp
     e00:	sub    rsp,0x40
     e04:	mov    QWORD PTR [rsp+0x20],rbx
     e09:	mov    QWORD PTR [rsp+0x28],r12
     e0e:	mov    QWORD PTR [rsp+0x30],r13
     e13:	mov    r12,rdi
     e16:	mov    QWORD PTR [rsp],rsi
     e1a:	mov    QWORD PTR [rsp+0x8],rdx
     e1f:	mov    r13,rdx
     e22:	mov    QWORD PTR [rsp+0x10],0x3
     e2b:	test   rsi,0x1
     e32:	jne    e40 <botlish_fn_11+0x44>
     e38:	mov    rbx,rsi
     e3b:	jmp    e55 <botlish_fn_11+0x59>
     e40:	mov    rcx,rsi
     e43:	add    rcx,0x2
     e47:	mov    rbx,rsi
     e4a:	seto   al
     e4d:	test   al,al
     e4f:	je     e68 <botlish_fn_11+0x6c>
     e55:	mov    edx,0x3
     e5a:	mov    rsi,rbx
     e5d:	mov    rdi,r12
     e60:	call   e65 <botlish_fn_11+0x69>
			e61: R_X86_64_PLT32	rt_int_add-0x4
     e65:	mov    rcx,rax
     e68:	mov    QWORD PTR [rsp+0x10],rcx
     e6d:	mov    rdx,rbx
     e70:	mov    rsi,r13
     e73:	mov    rdi,r12
     e76:	call   e7b <botlish_fn_11+0x7f>
			e77: R_X86_64_PLT32	rt_substr-0x4
     e7b:	test   rax,rax
     e7e:	jne    e9f <botlish_fn_11+0xa3>
     e84:	xor    rax,rax
     e87:	mov    rbx,QWORD PTR [rsp+0x20]
     e8c:	mov    r12,QWORD PTR [rsp+0x28]
     e91:	mov    r13,QWORD PTR [rsp+0x30]
     e96:	add    rsp,0x40
     e9a:	mov    rsp,rbp
     e9d:	pop    rbp
     e9e:	ret
     e9f:	mov    rbx,QWORD PTR [rsp+0x20]
     ea4:	mov    r12,QWORD PTR [rsp+0x28]
     ea9:	mov    r13,QWORD PTR [rsp+0x30]
     eae:	add    rsp,0x40
     eb2:	mov    rsp,rbp
     eb5:	pop    rbp
     eb6:	ret

0000000000000eb7 <botlish_entry_11: char_at<generic>>:
     eb7:	push   rbp
     eb8:	mov    rbp,rsp
     ebb:	mov    rsi,QWORD PTR [rdx]
     ebe:	mov    rdx,QWORD PTR [rdx+0x8]
     ec2:	call   ec7 <botlish_entry_11+0x10>
			ec3: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
     ec7:	mov    rsp,rbp
     eca:	pop    rbp
     ecb:	ret

0000000000000ecc <botlish_fn_12: local_char?<generic>>:
     ecc:	push   rbp
     ecd:	mov    rbp,rsp
     ed0:	sub    rsp,0x10
     ed4:	mov    QWORD PTR [rsp],rbx
     ed8:	mov    QWORD PTR [rsp+0x8],r12
     edd:	xor    r8d,r8d
     ee0:	test   rsi,0x7
     ee7:	jne    ef7 <botlish_fn_12+0x2b>
     eed:	movzx  rax,BYTE PTR [rsi]
     ef1:	cmp    al,0x2
     ef3:	sete   r8b
     ef7:	test   r8b,r8b
     efa:	jne    f1a <botlish_fn_12+0x4e>
     f00:	mov    rax,QWORD PTR [rdi+0x10]
     f04:	mov    rcx,QWORD PTR [rax+0xd8]
     f0b:	mov    edx,0x1
     f10:	call   f15 <botlish_fn_12+0x49>
			f11: R_X86_64_PLT32	rt_type_error-0x4
     f15:	jmp    f2e <botlish_fn_12+0x62>
     f1a:	mov    rbx,rsi
     f1d:	mov    r12,rdi
     f20:	call   f25 <botlish_fn_12+0x59>
			f21: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     f25:	test   rax,rax
     f28:	jne    f43 <botlish_fn_12+0x77>
     f2e:	xor    rax,rax
     f31:	mov    rbx,QWORD PTR [rsp]
     f35:	mov    r12,QWORD PTR [rsp+0x8]
     f3a:	add    rsp,0x10
     f3e:	mov    rsp,rbp
     f41:	pop    rbp
     f42:	ret
     f43:	cmp    rax,0x6
     f47:	je     f7d <botlish_fn_12+0xb1>
     f4d:	mov    rdi,r12
     f50:	mov    rax,QWORD PTR [rdi+0x30]
     f54:	mov    rsi,QWORD PTR [rax]
     f57:	mov    rdx,rbx
     f5a:	call   f5f <botlish_fn_12+0x93>
			f5b: R_X86_64_PLT32	rt_set_contains-0x4
     f5f:	cmp    rax,0x6
     f63:	je     f73 <botlish_fn_12+0xa7>
     f69:	mov    eax,0x2
     f6e:	jmp    f82 <botlish_fn_12+0xb6>
     f73:	mov    eax,0x6
     f78:	jmp    f82 <botlish_fn_12+0xb6>
     f7d:	mov    eax,0x6
     f82:	mov    rbx,QWORD PTR [rsp]
     f86:	mov    r12,QWORD PTR [rsp+0x8]
     f8b:	add    rsp,0x10
     f8f:	mov    rsp,rbp
     f92:	pop    rbp
     f93:	ret

0000000000000f94 <botlish_entry_12: local_char?<generic>>:
     f94:	push   rbp
     f95:	mov    rbp,rsp
     f98:	mov    rsi,QWORD PTR [rdx]
     f9b:	call   fa0 <botlish_entry_12+0xc>
			f9c: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<generic>
     fa0:	mov    rsp,rbp
     fa3:	pop    rbp
     fa4:	ret
     fa5:	add    BYTE PTR [rax],al
	...

0000000000000fa8 <botlish_fn_13: scan_while<generic>>:
     fa8:	push   rbp
     fa9:	mov    rbp,rsp
     fac:	sub    rsp,0x60
     fb0:	mov    QWORD PTR [rsp+0x30],rbx
     fb5:	mov    QWORD PTR [rsp+0x38],r12
     fba:	mov    QWORD PTR [rsp+0x40],r13
     fbf:	mov    QWORD PTR [rsp+0x48],r14
     fc4:	mov    QWORD PTR [rsp+0x50],r15
     fc9:	mov    rbx,rcx
     fcc:	mov    r14,rdi
     fcf:	mov    QWORD PTR [rsp+0x20],0x0
     fd8:	mov    QWORD PTR [rsp],rdx
     fdc:	mov    r13,rdx
     fdf:	mov    QWORD PTR [rsp+0x8],rcx
     fe4:	mov    QWORD PTR [rsp+0x10],r8
     fe9:	mov    r12,r8
     fec:	mov    QWORD PTR [rsp+0x18],rsi
     ff1:	mov    rax,rsi
     ff4:	mov    rcx,rbx
     ff7:	mov    r15,rsi
     ffa:	mov    rcx,rbx
     ffd:	and    rax,rcx
    1000:	test   rax,0x1
    1006:	jne    102f <botlish_fn_13+0x87>
    100c:	mov    rdx,rbx
    100f:	mov    rsi,r15
    1012:	mov    rdi,r14
    1015:	call   101a <botlish_fn_13+0x72>
			1016: R_X86_64_PLT32	rt_int_cmp-0x4
    101a:	mov    ecx,0x2
    101f:	test   rax,rax
    1022:	cmovl  rcx,QWORD PTR [rip+0x12e]        # 1158 <botlish_fn_13+0x1b0>
    102a:	jmp    1045 <botlish_fn_13+0x9d>
    102f:	mov    ecx,0x2
    1034:	mov    rax,r15
    1037:	mov    rdx,rbx
    103a:	cmp    rax,rdx
    103d:	cmovl  rcx,QWORD PTR [rip+0x113]        # 1158 <botlish_fn_13+0x1b0>
    1045:	cmp    rcx,0x6
    1049:	je     1074 <botlish_fn_13+0xcc>
    104f:	mov    rax,rbx
    1052:	mov    rbx,QWORD PTR [rsp+0x30]
    1057:	mov    r12,QWORD PTR [rsp+0x38]
    105c:	mov    r13,QWORD PTR [rsp+0x40]
    1061:	mov    r14,QWORD PTR [rsp+0x48]
    1066:	mov    r15,QWORD PTR [rsp+0x50]
    106b:	add    rsp,0x60
    106f:	mov    rsp,rbp
    1072:	pop    rbp
    1073:	ret
    1074:	mov    rdx,r12
    1077:	mov    rsi,r15
    107a:	mov    rdi,r14
    107d:	call   1082 <botlish_fn_13+0xda>
			107e: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    1082:	test   rax,rax
    1085:	je     10b3 <botlish_fn_13+0x10b>
    108b:	mov    QWORD PTR [rsp+0x20],rax
    1090:	lea    rcx,[rsp+0x28]
    1095:	mov    QWORD PTR [rsp+0x28],rax
    109a:	mov    edx,0x1
    109f:	mov    rsi,r13
    10a2:	mov    rdi,r14
    10a5:	call   10aa <botlish_fn_13+0x102>
			10a6: R_X86_64_PLT32	rt_call_value-0x4
    10aa:	test   rax,rax
    10ad:	jne    10d8 <botlish_fn_13+0x130>
    10b3:	xor    rax,rax
    10b6:	mov    rbx,QWORD PTR [rsp+0x30]
    10bb:	mov    r12,QWORD PTR [rsp+0x38]
    10c0:	mov    r13,QWORD PTR [rsp+0x40]
    10c5:	mov    r14,QWORD PTR [rsp+0x48]
    10ca:	mov    r15,QWORD PTR [rsp+0x50]
    10cf:	add    rsp,0x60
    10d3:	mov    rsp,rbp
    10d6:	pop    rbp
    10d7:	ret
    10d8:	cmp    rax,0x6
    10dc:	je     1107 <botlish_fn_13+0x15f>
    10e2:	mov    rax,r15
    10e5:	mov    rbx,QWORD PTR [rsp+0x30]
    10ea:	mov    r12,QWORD PTR [rsp+0x38]
    10ef:	mov    r13,QWORD PTR [rsp+0x40]
    10f4:	mov    r14,QWORD PTR [rsp+0x48]
    10f9:	mov    r15,QWORD PTR [rsp+0x50]
    10fe:	add    rsp,0x60
    1102:	mov    rsp,rbp
    1105:	pop    rbp
    1106:	ret
    1107:	mov    QWORD PTR [rsp+0x20],0x3
    1110:	mov    rax,r15
    1113:	test   rax,0x1
    1119:	je     1134 <botlish_fn_13+0x18c>
    111f:	mov    rcx,r15
    1122:	mov    rax,rcx
    1125:	add    rax,0x2
    1129:	seto   cl
    112c:	test   cl,cl
    112e:	je     1144 <botlish_fn_13+0x19c>
    1134:	mov    edx,0x3
    1139:	mov    rsi,r15
    113c:	mov    rdi,r14
    113f:	call   1144 <botlish_fn_13+0x19c>
			1140: R_X86_64_PLT32	rt_int_add-0x4
    1144:	mov    QWORD PTR [rsp+0x18],rax
    1149:	mov    rcx,rbx
    114c:	mov    r15,rax
    114f:	jmp    ffa <botlish_fn_13+0x52>
    1154:	add    BYTE PTR [rax],al
    1156:	add    BYTE PTR [rax],al
    1158:	(bad)
    1159:	add    BYTE PTR [rax],al
    115b:	add    BYTE PTR [rax],al
    115d:	add    BYTE PTR [rax],al
	...

0000000000001160 <botlish_entry_13: scan_while<generic>>:
    1160:	push   rbp
    1161:	mov    rbp,rsp
    1164:	mov    rsi,QWORD PTR [rdx]
    1167:	mov    r9,QWORD PTR [rdx+0x8]
    116b:	mov    rcx,QWORD PTR [rdx+0x10]
    116f:	mov    r8,QWORD PTR [rdx+0x18]
    1173:	mov    rdx,r9
    1176:	call   117b <botlish_entry_13+0x1b>
			1177: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<generic>
    117b:	mov    rsp,rbp
    117e:	pop    rbp
    117f:	ret

0000000000001180 <botlish_fn_14: tld?<generic>>:
    1180:	push   rbp
    1181:	mov    rbp,rsp
    1184:	sub    rsp,0x40
    1188:	mov    QWORD PTR [rsp+0x20],rbx
    118d:	mov    QWORD PTR [rsp+0x28],r12
    1192:	mov    QWORD PTR [rsp+0x30],r13
    1197:	mov    QWORD PTR [rsp+0x38],r14
    119c:	mov    QWORD PTR [rsp],rsi
    11a0:	mov    r8,rsi
    11a3:	mov    QWORD PTR [rsp+0x8],rdx
    11a8:	mov    r14,rdx
    11ab:	mov    QWORD PTR [rsp+0x10],rcx
    11b0:	mov    rax,QWORD PTR [rdi+0x10]
    11b4:	mov    r12,rdi
    11b7:	mov    rdx,QWORD PTR [rax+0xe0]
    11be:	mov    QWORD PTR [rsp+0x18],rdx
    11c3:	mov    rbx,r8
    11c6:	mov    r8,rcx
    11c9:	mov    rcx,r14
    11cc:	mov    rsi,rbx
    11cf:	call   11d4 <botlish_fn_14+0x54>
			11d0: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<generic>
    11d4:	mov    rcx,rax
    11d7:	mov    r13,rax
    11da:	test   rax,rcx
    11dd:	jne    1203 <botlish_fn_14+0x83>
    11e3:	xor    rax,rax
    11e6:	mov    rbx,QWORD PTR [rsp+0x20]
    11eb:	mov    r12,QWORD PTR [rsp+0x28]
    11f0:	mov    r13,QWORD PTR [rsp+0x30]
    11f5:	mov    r14,QWORD PTR [rsp+0x38]
    11fa:	add    rsp,0x40
    11fe:	mov    rsp,rbp
    1201:	pop    rbp
    1202:	ret
    1203:	mov    rax,r13
    1206:	mov    QWORD PTR [rsp+0x8],rax
    120b:	mov    rdx,r14
    120e:	and    rax,rdx
    1211:	test   rax,0x1
    1217:	jne    1240 <botlish_fn_14+0xc0>
    121d:	mov    rsi,r13
    1220:	mov    rdi,r12
    1223:	call   1228 <botlish_fn_14+0xa8>
			1224: R_X86_64_PLT32	rt_int_cmp-0x4
    1228:	mov    ecx,0x2
    122d:	test   rax,rax
    1230:	cmove  rcx,QWORD PTR [rip+0xe0]        # 1318 <botlish_fn_14+0x198>
    1238:	mov    rax,r13
    123b:	jmp    1253 <botlish_fn_14+0xd3>
    1240:	mov    ecx,0x2
    1245:	mov    rax,r13
    1248:	cmp    rax,rdx
    124b:	cmove  rcx,QWORD PTR [rip+0xc5]        # 1318 <botlish_fn_14+0x198>
    1253:	cmp    rcx,0x6
    1257:	je     126a <botlish_fn_14+0xea>
    125d:	mov    ecx,0x2
    1262:	mov    rax,rcx
    1265:	jmp    12f7 <botlish_fn_14+0x177>
    126a:	mov    rcx,rax
    126d:	and    rcx,rbx
    1270:	test   rcx,0x1
    1277:	jne    1288 <botlish_fn_14+0x108>
    127d:	mov    rdx,rbx
    1280:	mov    rsi,rax
    1283:	jmp    12a9 <botlish_fn_14+0x129>
    1288:	mov    rcx,rax
    128b:	sub    rcx,rbx
    128e:	mov    r8,rbx
    1291:	mov    r13,rax
    1294:	seto   al
    1297:	lea    rsi,[rcx+0x1]
    129b:	test   al,al
    129d:	je     12b4 <botlish_fn_14+0x134>
    12a3:	mov    rdx,r8
    12a6:	mov    rsi,r13
    12a9:	mov    rdi,r12
    12ac:	call   12b1 <botlish_fn_14+0x131>
			12ad: R_X86_64_PLT32	rt_int_sub-0x4
    12b1:	mov    rsi,rax
    12b4:	test   rsi,0x1
    12bb:	jne    12e6 <botlish_fn_14+0x166>
    12c1:	mov    edx,0x5
    12c6:	mov    rdi,r12
    12c9:	call   12ce <botlish_fn_14+0x14e>
			12ca: R_X86_64_PLT32	rt_int_cmp-0x4
    12ce:	mov    ecx,0x2
    12d3:	test   rax,rax
    12d6:	mov    rax,rcx
    12d9:	cmovge rax,QWORD PTR [rip+0x37]        # 1318 <botlish_fn_14+0x198>
    12e1:	jmp    12f7 <botlish_fn_14+0x177>
    12e6:	mov    eax,0x2
    12eb:	cmp    rsi,0x5
    12ef:	cmovge rax,QWORD PTR [rip+0x21]        # 1318 <botlish_fn_14+0x198>
    12f7:	mov    rbx,QWORD PTR [rsp+0x20]
    12fc:	mov    r12,QWORD PTR [rsp+0x28]
    1301:	mov    r13,QWORD PTR [rsp+0x30]
    1306:	mov    r14,QWORD PTR [rsp+0x38]
    130b:	add    rsp,0x40
    130f:	mov    rsp,rbp
    1312:	pop    rbp
    1313:	ret
    1314:	add    BYTE PTR [rax],al
    1316:	add    BYTE PTR [rax],al
    1318:	(bad)
    1319:	add    BYTE PTR [rax],al
    131b:	add    BYTE PTR [rax],al
    131d:	add    BYTE PTR [rax],al
	...

0000000000001320 <botlish_entry_14: tld?<generic>>:
    1320:	push   rbp
    1321:	mov    rbp,rsp
    1324:	mov    rsi,QWORD PTR [rdx]
    1327:	mov    r8,QWORD PTR [rdx+0x8]
    132b:	mov    rcx,QWORD PTR [rdx+0x10]
    132f:	mov    rdx,r8
    1332:	call   1337 <botlish_entry_14+0x17>
			1333: R_X86_64_PLT32	botlish_fn_14-0x4 ; tld?<generic>
    1337:	mov    rsp,rbp
    133a:	pop    rbp
    133b:	ret
    133c:	add    BYTE PTR [rax],al
	...

0000000000001340 <botlish_fn_15: domain?<generic>>:
    1340:	push   rbp
    1341:	mov    rbp,rsp
    1344:	sub    rsp,0xa0
    134b:	mov    QWORD PTR [rsp+0x70],rbx
    1350:	mov    QWORD PTR [rsp+0x78],r12
    1355:	mov    QWORD PTR [rsp+0x80],r13
    135d:	mov    QWORD PTR [rsp+0x88],r14
    1365:	mov    QWORD PTR [rsp+0x90],r15
    136d:	mov    QWORD PTR [rsp+0x20],0x0
    1376:	mov    QWORD PTR [rsp],rsi
    137a:	mov    QWORD PTR [rsp+0x8],rdx
    137f:	mov    QWORD PTR [rsp+0x10],rcx
    1384:	mov    r14,rcx
    1387:	mov    QWORD PTR [rsp+0x18],rsi
    138c:	mov    r15,rsi
    138f:	mov    r13,rdx
    1392:	mov    rax,rsi
    1395:	and    rax,r13
    1398:	mov    QWORD PTR [rsp+0x58],rsi
    139d:	test   rax,0x1
    13a3:	jne    13ce <botlish_fn_15+0x8e>
    13a9:	mov    rbx,rdi
    13ac:	mov    rdx,r13
    13af:	mov    rsi,QWORD PTR [rsp+0x58]
    13b4:	call   13b9 <botlish_fn_15+0x79>
			13b5: R_X86_64_PLT32	rt_int_cmp-0x4
    13b9:	mov    ecx,0x2
    13be:	test   rax,rax
    13c1:	cmovl  rcx,QWORD PTR [rip+0x42f]        # 17f8 <botlish_fn_15+0x4b8>
    13c9:	jmp    13e6 <botlish_fn_15+0xa6>
    13ce:	mov    rbx,rdi
    13d1:	mov    ecx,0x2
    13d6:	mov    rsi,QWORD PTR [rsp+0x58]
    13db:	cmp    rsi,r13
    13de:	cmovl  rcx,QWORD PTR [rip+0x412]        # 17f8 <botlish_fn_15+0x4b8>
    13e6:	cmp    rcx,0x6
    13ea:	je     1423 <botlish_fn_15+0xe3>
    13f0:	mov    eax,0x2
    13f5:	mov    rbx,QWORD PTR [rsp+0x70]
    13fa:	mov    r12,QWORD PTR [rsp+0x78]
    13ff:	mov    r13,QWORD PTR [rsp+0x80]
    1407:	mov    r14,QWORD PTR [rsp+0x88]
    140f:	mov    r15,QWORD PTR [rsp+0x90]
    1417:	add    rsp,0xa0
    141e:	mov    rsp,rbp
    1421:	pop    rbp
    1422:	ret
    1423:	lea    rcx,[rsp+0x28]
    1428:	mov    rdx,r14
    142b:	mov    rsi,QWORD PTR [rsp+0x58]
    1430:	mov    rdi,rbx
    1433:	call   1438 <botlish_fn_15+0xf8>
			1434: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    1438:	test   rax,rax
    143b:	mov    rsi,rax
    143e:	je     16a7 <botlish_fn_15+0x367>
    1444:	mov    rdx,QWORD PTR [rsp+0x28]
    1449:	mov    rcx,QWORD PTR [rsp+0x30]
    144e:	mov    rax,QWORD PTR [rbx+0x10]
    1452:	mov    r8,QWORD PTR [rax]
    1455:	mov    rdi,rbx
    1458:	call   145d <botlish_fn_15+0x11d>
			1459: R_X86_64_PLT32	rt_str_region_eq-0x4
    145d:	cmp    rax,0x6
    1461:	je     1558 <botlish_fn_15+0x218>
    1467:	lea    rcx,[rsp+0x48]
    146c:	mov    rdx,r14
    146f:	mov    rsi,QWORD PTR [rsp+0x58]
    1474:	mov    rdi,rbx
    1477:	call   147c <botlish_fn_15+0x13c>
			1478: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    147c:	test   rax,rax
    147f:	mov    r12,rax
    1482:	je     16a7 <botlish_fn_15+0x367>
    1488:	mov    rdx,QWORD PTR [rsp+0x48]
    148d:	mov    QWORD PTR [rsp+0x68],rdx
    1492:	mov    rcx,QWORD PTR [rsp+0x50]
    1497:	mov    QWORD PTR [rsp+0x60],rcx
    149c:	mov    rsi,r12
    149f:	mov    rdi,rbx
    14a2:	call   14a7 <botlish_fn_15+0x167>
			14a3: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    14a7:	test   rax,rax
    14aa:	je     16a7 <botlish_fn_15+0x367>
    14b0:	cmp    rax,0x6
    14b4:	je     14f5 <botlish_fn_15+0x1b5>
    14ba:	mov    rax,QWORD PTR [rbx+0x10]
    14be:	mov    r8,QWORD PTR [rax+0x20]
    14c2:	mov    rcx,QWORD PTR [rsp+0x60]
    14c7:	mov    rdx,QWORD PTR [rsp+0x68]
    14cc:	mov    rsi,r12
    14cf:	mov    rdi,rbx
    14d2:	call   14d7 <botlish_fn_15+0x197>
			14d3: R_X86_64_PLT32	rt_str_region_eq-0x4
    14d7:	cmp    rax,0x6
    14db:	je     14eb <botlish_fn_15+0x1ab>
    14e1:	mov    edx,0x2
    14e6:	jmp    14fa <botlish_fn_15+0x1ba>
    14eb:	mov    edx,0x6
    14f0:	jmp    14fa <botlish_fn_15+0x1ba>
    14f5:	mov    edx,0x6
    14fa:	cmp    rdx,0x6
    14fe:	je     150e <botlish_fn_15+0x1ce>
    1504:	mov    eax,0x6
    1509:	jmp    1513 <botlish_fn_15+0x1d3>
    150e:	mov    eax,0x2
    1513:	cmp    rax,0x6
    1517:	je     1525 <botlish_fn_15+0x1e5>
    151d:	mov    r12,r15
    1520:	jmp    16e2 <botlish_fn_15+0x3a2>
    1525:	mov    eax,0x2
    152a:	mov    rbx,QWORD PTR [rsp+0x70]
    152f:	mov    r12,QWORD PTR [rsp+0x78]
    1534:	mov    r13,QWORD PTR [rsp+0x80]
    153c:	mov    r14,QWORD PTR [rsp+0x88]
    1544:	mov    r15,QWORD PTR [rsp+0x90]
    154c:	add    rsp,0xa0
    1553:	mov    rsp,rbp
    1556:	pop    rbp
    1557:	ret
    1558:	mov    rsi,QWORD PTR [rsp+0x58]
    155d:	mov    r12,r15
    1560:	mov    rax,rsi
    1563:	and    rax,r12
    1566:	test   rax,0x1
    156c:	jne    1597 <botlish_fn_15+0x257>
    1572:	mov    rdx,r12
    1575:	mov    rsi,QWORD PTR [rsp+0x58]
    157a:	mov    rdi,rbx
    157d:	call   1582 <botlish_fn_15+0x242>
			157e: R_X86_64_PLT32	rt_int_cmp-0x4
    1582:	mov    ecx,0x2
    1587:	test   rax,rax
    158a:	cmove  rcx,QWORD PTR [rip+0x266]        # 17f8 <botlish_fn_15+0x4b8>
    1592:	jmp    15ac <botlish_fn_15+0x26c>
    1597:	mov    ecx,0x2
    159c:	mov    rsi,QWORD PTR [rsp+0x58]
    15a1:	cmp    rsi,r12
    15a4:	cmove  rcx,QWORD PTR [rip+0x24c]        # 17f8 <botlish_fn_15+0x4b8>
    15ac:	cmp    rcx,0x6
    15b0:	je     17c5 <botlish_fn_15+0x485>
    15b6:	mov    QWORD PTR [rsp+0x20],0x3
    15bf:	mov    rsi,QWORD PTR [rsp+0x58]
    15c4:	test   rsi,0x1
    15cb:	je     15ee <botlish_fn_15+0x2ae>
    15d1:	mov    rsi,QWORD PTR [rsp+0x58]
    15d6:	sub    rsi,0x3
    15da:	seto   dil
    15de:	add    rsi,0x1
    15e5:	test   dil,dil
    15e8:	je     1603 <botlish_fn_15+0x2c3>
    15ee:	mov    edx,0x3
    15f3:	mov    rsi,QWORD PTR [rsp+0x58]
    15f8:	mov    rdi,rbx
    15fb:	call   1600 <botlish_fn_15+0x2c0>
			15fc: R_X86_64_PLT32	rt_int_sub-0x4
    1600:	mov    rsi,rax
    1603:	mov    QWORD PTR [rsp+0x20],rsi
    1608:	lea    rcx,[rsp+0x38]
    160d:	mov    rdx,r14
    1610:	mov    rdi,rbx
    1613:	call   1618 <botlish_fn_15+0x2d8>
			1614: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    1618:	test   rax,rax
    161b:	mov    rsi,rax
    161e:	je     16a7 <botlish_fn_15+0x367>
    1624:	mov    rdx,QWORD PTR [rsp+0x38]
    1629:	mov    rcx,QWORD PTR [rsp+0x40]
    162e:	mov    rax,QWORD PTR [rbx+0x10]
    1632:	mov    r8,QWORD PTR [rax]
    1635:	mov    rdi,rbx
    1638:	call   163d <botlish_fn_15+0x2fd>
			1639: R_X86_64_PLT32	rt_str_region_eq-0x4
    163d:	cmp    rax,0x6
    1641:	je     1792 <botlish_fn_15+0x452>
    1647:	mov    QWORD PTR [rsp+0x20],0x3
    1650:	mov    rsi,QWORD PTR [rsp+0x58]
    1655:	test   rsi,0x1
    165c:	je     1676 <botlish_fn_15+0x336>
    1662:	mov    rsi,QWORD PTR [rsp+0x58]
    1667:	add    rsi,0x2
    166b:	seto   al
    166e:	test   al,al
    1670:	je     168b <botlish_fn_15+0x34b>
    1676:	mov    edx,0x3
    167b:	mov    rsi,QWORD PTR [rsp+0x58]
    1680:	mov    rdi,rbx
    1683:	call   1688 <botlish_fn_15+0x348>
			1684: R_X86_64_PLT32	rt_int_add-0x4
    1688:	mov    rsi,rax
    168b:	mov    QWORD PTR [rsp+0x20],rsi
    1690:	mov    rcx,r14
    1693:	mov    rdx,r13
    1696:	mov    rdi,rbx
    1699:	call   169e <botlish_fn_15+0x35e>
			169a: R_X86_64_PLT32	botlish_fn_14-0x4 ; tld?<generic>
    169e:	test   rax,rax
    16a1:	jne    16d8 <botlish_fn_15+0x398>
    16a7:	xor    rax,rax
    16aa:	mov    rbx,QWORD PTR [rsp+0x70]
    16af:	mov    r12,QWORD PTR [rsp+0x78]
    16b4:	mov    r13,QWORD PTR [rsp+0x80]
    16bc:	mov    r14,QWORD PTR [rsp+0x88]
    16c4:	mov    r15,QWORD PTR [rsp+0x90]
    16cc:	add    rsp,0xa0
    16d3:	mov    rsp,rbp
    16d6:	pop    rbp
    16d7:	ret
    16d8:	cmp    rax,0x6
    16dc:	je     175f <botlish_fn_15+0x41f>
    16e2:	mov    edx,0x3
    16e7:	mov    QWORD PTR [rsp+0x20],0x3
    16f0:	mov    rsi,QWORD PTR [rsp+0x58]
    16f5:	test   rsi,0x1
    16fc:	jne    170c <botlish_fn_15+0x3cc>
    1702:	mov    rsi,QWORD PTR [rsp+0x58]
    1707:	jmp    173a <botlish_fn_15+0x3fa>
    170c:	mov    rsi,QWORD PTR [rsp+0x58]
    1711:	mov    rax,rsi
    1714:	add    rax,0x2
    1718:	seto   cl
    171b:	test   cl,cl
    171d:	je     172d <botlish_fn_15+0x3ed>
    1723:	mov    rsi,QWORD PTR [rsp+0x58]
    1728:	jmp    173a <botlish_fn_15+0x3fa>
    172d:	mov    rsi,rax
    1730:	mov    QWORD PTR [rsp+0x58],rax
    1735:	jmp    174a <botlish_fn_15+0x40a>
    173a:	mov    rdi,rbx
    173d:	call   1742 <botlish_fn_15+0x402>
			173e: R_X86_64_PLT32	rt_int_add-0x4
    1742:	mov    rsi,rax
    1745:	mov    QWORD PTR [rsp+0x58],rax
    174a:	mov    QWORD PTR [rsp+0x18],rsi
    174f:	mov    rsi,QWORD PTR [rsp+0x58]
    1754:	mov    rdi,rbx
    1757:	mov    r15,r12
    175a:	jmp    1392 <botlish_fn_15+0x52>
    175f:	mov    eax,0x6
    1764:	mov    rbx,QWORD PTR [rsp+0x70]
    1769:	mov    r12,QWORD PTR [rsp+0x78]
    176e:	mov    r13,QWORD PTR [rsp+0x80]
    1776:	mov    r14,QWORD PTR [rsp+0x88]
    177e:	mov    r15,QWORD PTR [rsp+0x90]
    1786:	add    rsp,0xa0
    178d:	mov    rsp,rbp
    1790:	pop    rbp
    1791:	ret
    1792:	mov    eax,0x2
    1797:	mov    rbx,QWORD PTR [rsp+0x70]
    179c:	mov    r12,QWORD PTR [rsp+0x78]
    17a1:	mov    r13,QWORD PTR [rsp+0x80]
    17a9:	mov    r14,QWORD PTR [rsp+0x88]
    17b1:	mov    r15,QWORD PTR [rsp+0x90]
    17b9:	add    rsp,0xa0
    17c0:	mov    rsp,rbp
    17c3:	pop    rbp
    17c4:	ret
    17c5:	mov    eax,0x2
    17ca:	mov    rbx,QWORD PTR [rsp+0x70]
    17cf:	mov    r12,QWORD PTR [rsp+0x78]
    17d4:	mov    r13,QWORD PTR [rsp+0x80]
    17dc:	mov    r14,QWORD PTR [rsp+0x88]
    17e4:	mov    r15,QWORD PTR [rsp+0x90]
    17ec:	add    rsp,0xa0
    17f3:	mov    rsp,rbp
    17f6:	pop    rbp
    17f7:	ret
    17f8:	(bad)
    17f9:	add    BYTE PTR [rax],al
    17fb:	add    BYTE PTR [rax],al
    17fd:	add    BYTE PTR [rax],al
	...

0000000000001800 <botlish_entry_15: domain?<generic>>:
    1800:	push   rbp
    1801:	mov    rbp,rsp
    1804:	mov    rsi,QWORD PTR [rdx]
    1807:	mov    r8,QWORD PTR [rdx+0x8]
    180b:	mov    rcx,QWORD PTR [rdx+0x10]
    180f:	mov    rdx,r8
    1812:	call   1817 <botlish_entry_15+0x17>
			1813: R_X86_64_PLT32	botlish_fn_15-0x4 ; domain?<generic>
    1817:	mov    rsp,rbp
    181a:	pop    rbp
    181b:	ret

000000000000181c <botlish_fn_16: web::is_unreserved<int>>:
    181c:	push   rbp
    181d:	mov    rbp,rsp
    1820:	sub    rsp,0x10
    1824:	mov    QWORD PTR [rsp],rbx
    1828:	mov    QWORD PTR [rsp+0x8],r13
    182d:	mov    r13,rsi
    1830:	mov    rbx,rdi
    1833:	mov    rsi,r13
    1836:	call   183b <botlish_fn_16+0x1f>
			1837: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
    183b:	cmp    rax,0x6
    183f:	je     1876 <botlish_fn_16+0x5a>
    1845:	mov    rax,QWORD PTR [rbx+0x30]
    1849:	mov    rsi,QWORD PTR [rax+0x10]
    184d:	mov    rdx,r13
    1850:	mov    rdi,rbx
    1853:	call   1858 <botlish_fn_16+0x3c>
			1854: R_X86_64_PLT32	rt_set_contains-0x4
    1858:	cmp    rax,0x6
    185c:	je     186c <botlish_fn_16+0x50>
    1862:	mov    eax,0x2
    1867:	jmp    187b <botlish_fn_16+0x5f>
    186c:	mov    eax,0x6
    1871:	jmp    187b <botlish_fn_16+0x5f>
    1876:	mov    eax,0x6
    187b:	mov    rbx,QWORD PTR [rsp]
    187f:	mov    r13,QWORD PTR [rsp+0x8]
    1884:	add    rsp,0x10
    1888:	mov    rsp,rbp
    188b:	pop    rbp
    188c:	ret

000000000000188d <botlish_entry_16: web::is_unreserved<int>>:
    188d:	push   rbp
    188e:	mov    rbp,rsp
    1891:	mov    rsi,QWORD PTR [rdx]
    1894:	call   1899 <botlish_entry_16+0xc>
			1895: R_X86_64_PLT32	botlish_fn_16-0x4 ; web::is_unreserved<int>
    1899:	mov    rsp,rbp
    189c:	pop    rbp
    189d:	ret

000000000000189e <botlish_fn_17: web::uri_escape_text<str>>:
    189e:	push   rbp
    189f:	mov    rbp,rsp
    18a2:	sub    rsp,0x20
    18a6:	mov    QWORD PTR [rsp],rsi
    18aa:	mov    edx,0x1
    18af:	mov    QWORD PTR [rsp+0x8],0x1
    18b8:	mov    r11,QWORD PTR [rdi+0x10]
    18bc:	mov    rcx,QWORD PTR [r11+0xe8]
    18c3:	mov    QWORD PTR [rsp+0x10],rcx
    18c8:	call   18cd <botlish_fn_17+0x2f>
			18c9: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_from<str, int, str>
    18cd:	test   rax,rax
    18d0:	jne    18e2 <botlish_fn_17+0x44>
    18d6:	xor    rax,rax
    18d9:	add    rsp,0x20
    18dd:	mov    rsp,rbp
    18e0:	pop    rbp
    18e1:	ret
    18e2:	add    rsp,0x20
    18e6:	mov    rsp,rbp
    18e9:	pop    rbp
    18ea:	ret

00000000000018eb <botlish_entry_17: web::uri_escape_text<str>>:
    18eb:	push   rbp
    18ec:	mov    rbp,rsp
    18ef:	mov    rsi,QWORD PTR [rdx]
    18f2:	call   18f7 <botlish_entry_17+0xc>
			18f3: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::uri_escape_text<str>
    18f7:	mov    rsp,rbp
    18fa:	pop    rbp
    18fb:	ret

00000000000018fc <botlish_fn_18: high_nibble<int>>:
    18fc:	push   rbp
    18fd:	mov    rbp,rsp
    1900:	sub    rsp,0x10
    1904:	mov    QWORD PTR [rsp],rsi
    1908:	mov    QWORD PTR [rsp+0x8],0x1e1
    1911:	test   rsi,0x1
    1918:	jne    192d <botlish_fn_18+0x31>
    191e:	mov    edx,0x1e1
    1923:	call   1928 <botlish_fn_18+0x2c>
			1924: R_X86_64_PLT32	rt_int_and-0x4
    1928:	jmp    1937 <botlish_fn_18+0x3b>
    192d:	and    rsi,0x1e1
    1934:	mov    rax,rsi
    1937:	sar    rax,0x5
    193b:	shl    rax,1
    193e:	or     rax,0x1
    1942:	add    rsp,0x10
    1946:	mov    rsp,rbp
    1949:	pop    rbp
    194a:	ret

000000000000194b <botlish_entry_18: high_nibble<int>>:
    194b:	push   rbp
    194c:	mov    rbp,rsp
    194f:	mov    rsi,QWORD PTR [rdx]
    1952:	call   1957 <botlish_entry_18+0xc>
			1953: R_X86_64_PLT32	botlish_fn_18-0x4 ; high_nibble<int>
    1957:	mov    rsp,rbp
    195a:	pop    rbp
    195b:	ret

000000000000195c <botlish_fn_19: hex_pair<int>>:
    195c:	push   rbp
    195d:	mov    rbp,rsp
    1960:	sub    rsp,0x50
    1964:	mov    QWORD PTR [rsp+0x30],rbx
    1969:	mov    QWORD PTR [rsp+0x38],r12
    196e:	mov    QWORD PTR [rsp+0x40],r13
    1973:	mov    QWORD PTR [rsp+0x48],r14
    1978:	mov    QWORD PTR [rsp],rsi
    197c:	mov    r12,rsi
    197f:	mov    rax,QWORD PTR [rdi+0x30]
    1983:	mov    rbx,rdi
    1986:	mov    rsi,QWORD PTR [rax+0x8]
    198a:	mov    QWORD PTR [rsp+0x8],rsi
    198f:	mov    r13,rsi
    1992:	mov    rsi,r12
    1995:	call   199a <botlish_fn_19+0x3e>
			1996: R_X86_64_PLT32	botlish_fn_18-0x4 ; high_nibble<int>
    199a:	test   rax,0x1
    19a0:	jne    19b1 <botlish_fn_19+0x55>
    19a6:	mov    rdx,rax
    19a9:	mov    rsi,r13
    19ac:	jmp    19ca <botlish_fn_19+0x6e>
    19b1:	mov    rsi,r13
    19b4:	mov    rdx,QWORD PTR [rsi+0x8]
    19b8:	mov    rcx,rax
    19bb:	sar    rcx,1
    19be:	cmp    rcx,rdx
    19c1:	jb     19e0 <botlish_fn_19+0x84>
    19c7:	mov    rdx,rax
    19ca:	mov    rdi,rbx
    19cd:	call   19d2 <botlish_fn_19+0x76>
			19ce: R_X86_64_PLT32	rt_list_get-0x4
    19d2:	test   rax,rax
    19d5:	je     1aa5 <botlish_fn_19+0x149>
    19db:	jmp    19e8 <botlish_fn_19+0x8c>
    19e0:	mov    rax,QWORD PTR [rsi+0x10]
    19e4:	mov    rax,QWORD PTR [rax+rcx*8]
    19e8:	mov    QWORD PTR [rsp],rax
    19ec:	mov    rdi,rbx
    19ef:	mov    r14,rax
    19f2:	mov    rax,QWORD PTR [rdi+0x30]
    19f6:	mov    rsi,QWORD PTR [rax+0x8]
    19fa:	mov    r13,rsi
    19fd:	mov    edx,0x21
    1a02:	mov    rsi,r12
    1a05:	call   1a0a <botlish_fn_19+0xae>
			1a06: R_X86_64_PLT32	rt_int_mod-0x4
    1a0a:	test   rax,rax
    1a0d:	je     1aa5 <botlish_fn_19+0x149>
    1a13:	test   rax,0x1
    1a19:	jne    1a2a <botlish_fn_19+0xce>
    1a1f:	mov    rdx,rax
    1a22:	mov    rsi,r13
    1a25:	jmp    1a43 <botlish_fn_19+0xe7>
    1a2a:	mov    rsi,r13
    1a2d:	mov    rdx,QWORD PTR [rsi+0x8]
    1a31:	mov    rcx,rax
    1a34:	sar    rcx,1
    1a37:	cmp    rcx,rdx
    1a3a:	jb     1a59 <botlish_fn_19+0xfd>
    1a40:	mov    rdx,rax
    1a43:	mov    rdi,rbx
    1a46:	call   1a4b <botlish_fn_19+0xef>
			1a47: R_X86_64_PLT32	rt_list_get-0x4
    1a4b:	test   rax,rax
    1a4e:	je     1aa5 <botlish_fn_19+0x149>
    1a54:	jmp    1a61 <botlish_fn_19+0x105>
    1a59:	mov    rax,QWORD PTR [rsi+0x10]
    1a5d:	mov    rax,QWORD PTR [rax+rcx*8]
    1a61:	mov    QWORD PTR [rsp+0x8],rax
    1a66:	lea    rcx,[rsp+0x10]
    1a6b:	mov    QWORD PTR [rsp+0x10],0x0
    1a74:	mov    rdx,r14
    1a77:	mov    QWORD PTR [rsp+0x18],rdx
    1a7c:	mov    QWORD PTR [rsp+0x20],0x0
    1a85:	mov    QWORD PTR [rsp+0x28],rax
    1a8a:	mov    esi,0x2
    1a8f:	mov    edx,0x4
    1a94:	mov    rdi,rbx
    1a97:	call   1a9c <botlish_fn_19+0x140>
			1a98: R_X86_64_PLT32	rt_construct-0x4
    1a9c:	test   rax,rax
    1a9f:	jne    1ac5 <botlish_fn_19+0x169>
    1aa5:	xor    rax,rax
    1aa8:	mov    rbx,QWORD PTR [rsp+0x30]
    1aad:	mov    r12,QWORD PTR [rsp+0x38]
    1ab2:	mov    r13,QWORD PTR [rsp+0x40]
    1ab7:	mov    r14,QWORD PTR [rsp+0x48]
    1abc:	add    rsp,0x50
    1ac0:	mov    rsp,rbp
    1ac3:	pop    rbp
    1ac4:	ret
    1ac5:	mov    rbx,QWORD PTR [rsp+0x30]
    1aca:	mov    r12,QWORD PTR [rsp+0x38]
    1acf:	mov    r13,QWORD PTR [rsp+0x40]
    1ad4:	mov    r14,QWORD PTR [rsp+0x48]
    1ad9:	add    rsp,0x50
    1add:	mov    rsp,rbp
    1ae0:	pop    rbp
    1ae1:	ret

0000000000001ae2 <botlish_entry_19: hex_pair<int>>:
    1ae2:	push   rbp
    1ae3:	mov    rbp,rsp
    1ae6:	sub    rsp,0x10
    1aea:	mov    QWORD PTR [rsp],r12
    1aee:	mov    r12,rdi
    1af1:	mov    rsi,QWORD PTR [rdx]
    1af4:	call   1af9 <botlish_entry_19+0x17>
			1af5: R_X86_64_PLT32	botlish_fn_19-0x4 ; hex_pair<int>
    1af9:	mov    r8,QWORD PTR [rip+0x0]        # 1b00 <botlish_entry_19+0x1e>
			1afc: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1b00:	mov    rsi,rax
    1b03:	mov    rdi,r12
    1b06:	call   r8
    1b09:	mov    r12,QWORD PTR [rsp]
    1b0d:	add    rsp,0x10
    1b11:	mov    rsp,rbp
    1b14:	pop    rbp
    1b15:	ret

0000000000001b16 <botlish_fn_20: esc_bytes<List[int], int, str>>:
    1b16:	push   rbp
    1b17:	mov    rbp,rsp
    1b1a:	sub    rsp,0x90
    1b21:	mov    QWORD PTR [rsp+0x60],rbx
    1b26:	mov    QWORD PTR [rsp+0x68],r12
    1b2b:	mov    QWORD PTR [rsp+0x70],r13
    1b30:	mov    QWORD PTR [rsp+0x78],r14
    1b35:	mov    QWORD PTR [rsp+0x80],r15
    1b3d:	mov    QWORD PTR [rsp],rsi
    1b41:	mov    QWORD PTR [rsp+0x8],rcx
    1b46:	sar    rdx,1
    1b49:	mov    r13,rdx
    1b4c:	lea    r14,[rsp+0x20]
    1b51:	mov    rbx,rdi
    1b54:	mov    r12,rsi
    1b57:	mov    QWORD PTR [rsp+0x50],rcx
    1b5c:	mov    rsi,r12
    1b5f:	mov    rdi,rbx
    1b62:	call   1b67 <botlish_fn_20+0x51>
			1b63: R_X86_64_PLT32	rt_list_len-0x4
    1b67:	sar    rax,1
    1b6a:	cmp    r13,rax
    1b6d:	jge    1c7d <botlish_fn_20+0x167>
    1b73:	mov    rax,QWORD PTR [rbx+0x10]
    1b77:	mov    r15,QWORD PTR [rax+0x10]
    1b7b:	mov    QWORD PTR [rsp+0x10],r15
    1b80:	mov    rcx,QWORD PTR [r12+0x8]
    1b85:	mov    rax,r13
    1b88:	shl    rax,1
    1b8b:	or     rax,0x1
    1b8f:	sar    rax,1
    1b92:	cmp    rax,rcx
    1b95:	jb     1bc1 <botlish_fn_20+0xab>
    1b9b:	mov    rdx,r13
    1b9e:	shl    rdx,1
    1ba1:	or     rdx,0x1
    1ba5:	mov    rsi,r12
    1ba8:	mov    rdi,rbx
    1bab:	call   1bb0 <botlish_fn_20+0x9a>
			1bac: R_X86_64_PLT32	rt_list_get-0x4
    1bb0:	test   rax,rax
    1bb3:	je     1c38 <botlish_fn_20+0x122>
    1bb9:	mov    rsi,rax
    1bbc:	jmp    1bca <botlish_fn_20+0xb4>
    1bc1:	mov    rcx,QWORD PTR [r12+0x10]
    1bc6:	mov    rsi,QWORD PTR [rcx+rax*8]
    1bca:	mov    QWORD PTR [rsp+0x18],rsi
    1bcf:	mov    rdi,rbx
    1bd2:	call   1bd7 <botlish_fn_20+0xc1>
			1bd3: R_X86_64_PLT32	botlish_fn_19-0x4 ; hex_pair<int>
    1bd7:	test   rax,rax
    1bda:	je     1c38 <botlish_fn_20+0x122>
    1be0:	mov    QWORD PTR [rsp+0x18],rax
    1be5:	mov    rcx,rax
    1be8:	mov    QWORD PTR [rsp+0x20],0x0
    1bf1:	mov    rax,QWORD PTR [rsp+0x50]
    1bf6:	mov    QWORD PTR [rsp+0x28],rax
    1bfb:	mov    QWORD PTR [rsp+0x30],0x0
    1c04:	mov    QWORD PTR [rsp+0x38],r15
    1c09:	mov    QWORD PTR [rsp+0x40],0x0
    1c12:	mov    rax,rcx
    1c15:	mov    QWORD PTR [rsp+0x48],rax
    1c1a:	mov    esi,0x2
    1c1f:	mov    edx,0x6
    1c24:	mov    rcx,r14
    1c27:	mov    rdi,rbx
    1c2a:	call   1c2f <botlish_fn_20+0x119>
			1c2b: R_X86_64_PLT32	rt_construct-0x4
    1c2f:	test   rax,rax
    1c32:	jne    1c63 <botlish_fn_20+0x14d>
    1c38:	xor    rax,rax
    1c3b:	mov    rbx,QWORD PTR [rsp+0x60]
    1c40:	mov    r12,QWORD PTR [rsp+0x68]
    1c45:	mov    r13,QWORD PTR [rsp+0x70]
    1c4a:	mov    r14,QWORD PTR [rsp+0x78]
    1c4f:	mov    r15,QWORD PTR [rsp+0x80]
    1c57:	add    rsp,0x90
    1c5e:	mov    rsp,rbp
    1c61:	pop    rbp
    1c62:	ret
    1c63:	mov    QWORD PTR [rsp],r12
    1c67:	mov    QWORD PTR [rsp+0x8],rax
    1c6c:	add    r13,0x1
    1c73:	mov    QWORD PTR [rsp+0x50],rax
    1c78:	jmp    1b5c <botlish_fn_20+0x46>
    1c7d:	mov    rax,QWORD PTR [rsp+0x50]
    1c82:	mov    rbx,QWORD PTR [rsp+0x60]
    1c87:	mov    r12,QWORD PTR [rsp+0x68]
    1c8c:	mov    r13,QWORD PTR [rsp+0x70]
    1c91:	mov    r14,QWORD PTR [rsp+0x78]
    1c96:	mov    r15,QWORD PTR [rsp+0x80]
    1c9e:	add    rsp,0x90
    1ca5:	mov    rsp,rbp
    1ca8:	pop    rbp
    1ca9:	ret

0000000000001caa <botlish_entry_20: esc_bytes<List[int], int, str>>:
    1caa:	push   rbp
    1cab:	mov    rbp,rsp
    1cae:	sub    rsp,0x10
    1cb2:	mov    QWORD PTR [rsp],r12
    1cb6:	mov    r12,rdi
    1cb9:	mov    rsi,QWORD PTR [rdx]
    1cbc:	mov    r8,QWORD PTR [rdx+0x8]
    1cc0:	mov    rcx,QWORD PTR [rdx+0x10]
    1cc4:	mov    rdx,r8
    1cc7:	call   1ccc <botlish_entry_20+0x22>
			1cc8: R_X86_64_PLT32	botlish_fn_20-0x4 ; esc_bytes<List[int], int, str>
    1ccc:	mov    r8,QWORD PTR [rip+0x0]        # 1cd3 <botlish_entry_20+0x29>
			1ccf: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1cd3:	mov    rsi,rax
    1cd6:	mov    rdi,r12
    1cd9:	call   r8
    1cdc:	mov    r12,QWORD PTR [rsp]
    1ce0:	add    rsp,0x10
    1ce4:	mov    rsp,rbp
    1ce7:	pop    rbp
    1ce8:	ret

0000000000001ce9 <botlish_fn_21: esc_char<str>>:
    1ce9:	push   rbp
    1cea:	mov    rbp,rsp
    1ced:	sub    rsp,0x40
    1cf1:	mov    QWORD PTR [rsp+0x20],rbx
    1cf6:	mov    QWORD PTR [rsp+0x28],r12
    1cfb:	mov    QWORD PTR [rsp+0x30],r13
    1d00:	mov    rbx,rdi
    1d03:	mov    QWORD PTR [rsp+0x8],0x0
    1d0c:	mov    QWORD PTR [rsp+0x10],0x0
    1d15:	mov    QWORD PTR [rsp],rsi
    1d19:	mov    r13,rsi
    1d1c:	mov    rsi,r13
    1d1f:	mov    rdi,rbx
    1d22:	call   1d27 <botlish_fn_21+0x3e>
			1d23: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1d27:	mov    rcx,rax
    1d2a:	mov    r12,rax
    1d2d:	test   rax,rcx
    1d30:	je     1e0e <botlish_fn_21+0x125>
    1d36:	mov    rax,r12
    1d39:	mov    QWORD PTR [rsp],rax
    1d3d:	mov    rsi,r12
    1d40:	mov    rdi,rbx
    1d43:	call   1d48 <botlish_fn_21+0x5f>
			1d44: R_X86_64_PLT32	rt_list_len-0x4
    1d48:	sar    rax,1
    1d4b:	cmp    rax,0x1
    1d4f:	je     1d8c <botlish_fn_21+0xa3>
    1d55:	mov    edx,0x1
    1d5a:	mov    QWORD PTR [rsp+0x8],0x1
    1d63:	mov    rdi,rbx
    1d66:	mov    rax,QWORD PTR [rdi+0x10]
    1d6a:	mov    rcx,QWORD PTR [rax+0xe8]
    1d71:	mov    QWORD PTR [rsp+0x10],rcx
    1d76:	mov    rsi,r12
    1d79:	call   1d7e <botlish_fn_21+0x95>
			1d7a: R_X86_64_PLT32	botlish_fn_20-0x4 ; esc_bytes<List[int], int, str>
    1d7e:	test   rax,rax
    1d81:	je     1e0e <botlish_fn_21+0x125>
    1d87:	jmp    1e2f <botlish_fn_21+0x146>
    1d8c:	mov    rsi,r12
    1d8f:	mov    rax,QWORD PTR [rsi+0x8]
    1d93:	mov    r12,rsi
    1d96:	test   rax,rax
    1d99:	jne    1dc0 <botlish_fn_21+0xd7>
    1d9f:	mov    edx,0x1
    1da4:	mov    rsi,r12
    1da7:	mov    rdi,rbx
    1daa:	call   1daf <botlish_fn_21+0xc6>
			1dab: R_X86_64_PLT32	rt_list_get-0x4
    1daf:	test   rax,rax
    1db2:	je     1e0e <botlish_fn_21+0x125>
    1db8:	mov    rsi,rax
    1dbb:	jmp    1dca <botlish_fn_21+0xe1>
    1dc0:	mov    rsi,r12
    1dc3:	mov    rax,QWORD PTR [rsi+0x10]
    1dc7:	mov    rsi,QWORD PTR [rax]
    1dca:	mov    rdi,rbx
    1dcd:	call   1dd2 <botlish_fn_21+0xe9>
			1dce: R_X86_64_PLT32	botlish_fn_16-0x4 ; web::is_unreserved<int>
    1dd2:	cmp    rax,0x6
    1dd6:	je     1e2c <botlish_fn_21+0x143>
    1ddc:	mov    edx,0x1
    1de1:	mov    QWORD PTR [rsp+0x8],0x1
    1dea:	mov    rdi,rbx
    1ded:	mov    rax,QWORD PTR [rdi+0x10]
    1df1:	mov    rcx,QWORD PTR [rax+0xe8]
    1df8:	mov    QWORD PTR [rsp+0x10],rcx
    1dfd:	mov    rsi,r12
    1e00:	call   1e05 <botlish_fn_21+0x11c>
			1e01: R_X86_64_PLT32	botlish_fn_20-0x4 ; esc_bytes<List[int], int, str>
    1e05:	test   rax,rax
    1e08:	jne    1e29 <botlish_fn_21+0x140>
    1e0e:	xor    rax,rax
    1e11:	mov    rbx,QWORD PTR [rsp+0x20]
    1e16:	mov    r12,QWORD PTR [rsp+0x28]
    1e1b:	mov    r13,QWORD PTR [rsp+0x30]
    1e20:	add    rsp,0x40
    1e24:	mov    rsp,rbp
    1e27:	pop    rbp
    1e28:	ret
    1e29:	mov    r13,rax
    1e2c:	mov    rax,r13
    1e2f:	mov    rbx,QWORD PTR [rsp+0x20]
    1e34:	mov    r12,QWORD PTR [rsp+0x28]
    1e39:	mov    r13,QWORD PTR [rsp+0x30]
    1e3e:	add    rsp,0x40
    1e42:	mov    rsp,rbp
    1e45:	pop    rbp
    1e46:	ret

0000000000001e47 <botlish_entry_21: esc_char<str>>:
    1e47:	push   rbp
    1e48:	mov    rbp,rsp
    1e4b:	sub    rsp,0x10
    1e4f:	mov    QWORD PTR [rsp],r12
    1e53:	mov    r12,rdi
    1e56:	mov    rsi,QWORD PTR [rdx]
    1e59:	call   1e5e <botlish_entry_21+0x17>
			1e5a: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_char<str>
    1e5e:	mov    r8,QWORD PTR [rip+0x0]        # 1e65 <botlish_entry_21+0x1e>
			1e61: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1e65:	mov    rsi,rax
    1e68:	mov    rdi,r12
    1e6b:	call   r8
    1e6e:	mov    r12,QWORD PTR [rsp]
    1e72:	add    rsp,0x10
    1e76:	mov    rsp,rbp
    1e79:	pop    rbp
    1e7a:	ret

0000000000001e7b <botlish_fn_22: esc_from<str, int, str>>:
    1e7b:	push   rbp
    1e7c:	mov    rbp,rsp
    1e7f:	sub    rsp,0x80
    1e86:	mov    QWORD PTR [rsp+0x50],rbx
    1e8b:	mov    QWORD PTR [rsp+0x58],r12
    1e90:	mov    QWORD PTR [rsp+0x60],r13
    1e95:	mov    QWORD PTR [rsp+0x68],r14
    1e9a:	mov    QWORD PTR [rsp+0x70],r15
    1e9f:	mov    r14,rdi
    1ea2:	mov    QWORD PTR [rsp+0x10],0x0
    1eab:	mov    QWORD PTR [rsp+0x18],0x0
    1eb4:	mov    QWORD PTR [rsp],rsi
    1eb8:	mov    QWORD PTR [rsp+0x8],rcx
    1ebd:	mov    r15,rcx
    1ec0:	sar    rdx,1
    1ec3:	mov    r12,rdx
    1ec6:	lea    r13,[rsp+0x30]
    1ecb:	mov    rbx,rsi
    1ece:	mov    rsi,rbx
    1ed1:	mov    rdi,r14
    1ed4:	call   1ed9 <botlish_fn_22+0x5e>
			1ed5: R_X86_64_PLT32	rt_str_len-0x4
    1ed9:	sar    rax,1
    1edc:	cmp    r12,rax
    1edf:	jge    1f8a <botlish_fn_22+0x10f>
    1ee5:	mov    rdx,r12
    1ee8:	shl    rdx,1
    1eeb:	or     rdx,0x1
    1eef:	mov    QWORD PTR [rsp+0x10],rdx
    1ef4:	add    r12,0x1
    1efb:	mov    rcx,r12
    1efe:	shl    rcx,1
    1f01:	or     rcx,0x1
    1f05:	mov    QWORD PTR [rsp+0x18],rcx
    1f0a:	mov    rsi,rbx
    1f0d:	mov    rdi,r14
    1f10:	call   1f15 <botlish_fn_22+0x9a>
			1f11: R_X86_64_PLT32	rt_substr-0x4
    1f15:	test   rax,rax
    1f18:	je     1fbc <botlish_fn_22+0x141>
    1f1e:	mov    QWORD PTR [rsp+0x10],rax
    1f23:	mov    rsi,rax
    1f26:	mov    rdi,r14
    1f29:	call   1f2e <botlish_fn_22+0xb3>
			1f2a: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_char<str>
    1f2e:	test   rax,rax
    1f31:	je     1fbc <botlish_fn_22+0x141>
    1f37:	mov    QWORD PTR [rsp+0x10],rax
    1f3c:	mov    QWORD PTR [rsp+0x30],0x0
    1f45:	mov    rcx,r15
    1f48:	mov    QWORD PTR [rsp+0x38],rcx
    1f4d:	mov    QWORD PTR [rsp+0x40],0x0
    1f56:	mov    QWORD PTR [rsp+0x48],rax
    1f5b:	mov    esi,0x2
    1f60:	mov    edx,0x4
    1f65:	mov    rcx,r13
    1f68:	mov    rdi,r14
    1f6b:	call   1f70 <botlish_fn_22+0xf5>
			1f6c: R_X86_64_PLT32	rt_construct-0x4
    1f70:	test   rax,rax
    1f73:	je     1fbc <botlish_fn_22+0x141>
    1f79:	mov    QWORD PTR [rsp],rbx
    1f7d:	mov    QWORD PTR [rsp+0x8],rax
    1f82:	mov    r15,rax
    1f85:	jmp    1ece <botlish_fn_22+0x53>
    1f8a:	mov    rcx,r15
    1f8d:	xor    rsi,rsi
    1f90:	lea    rax,[rsp+0x20]
    1f95:	mov    QWORD PTR [rsp+0x20],0x0
    1f9e:	mov    QWORD PTR [rsp+0x28],rcx
    1fa3:	mov    edx,0x2
    1fa8:	mov    rcx,rax
    1fab:	mov    rdi,r14
    1fae:	call   1fb3 <botlish_fn_22+0x138>
			1faf: R_X86_64_PLT32	rt_construct-0x4
    1fb3:	test   rax,rax
    1fb6:	jne    1fe4 <botlish_fn_22+0x169>
    1fbc:	xor    rax,rax
    1fbf:	mov    rbx,QWORD PTR [rsp+0x50]
    1fc4:	mov    r12,QWORD PTR [rsp+0x58]
    1fc9:	mov    r13,QWORD PTR [rsp+0x60]
    1fce:	mov    r14,QWORD PTR [rsp+0x68]
    1fd3:	mov    r15,QWORD PTR [rsp+0x70]
    1fd8:	add    rsp,0x80
    1fdf:	mov    rsp,rbp
    1fe2:	pop    rbp
    1fe3:	ret
    1fe4:	mov    rbx,QWORD PTR [rsp+0x50]
    1fe9:	mov    r12,QWORD PTR [rsp+0x58]
    1fee:	mov    r13,QWORD PTR [rsp+0x60]
    1ff3:	mov    r14,QWORD PTR [rsp+0x68]
    1ff8:	mov    r15,QWORD PTR [rsp+0x70]
    1ffd:	add    rsp,0x80
    2004:	mov    rsp,rbp
    2007:	pop    rbp
    2008:	ret

0000000000002009 <botlish_entry_22: esc_from<str, int, str>>:
    2009:	push   rbp
    200a:	mov    rbp,rsp
    200d:	mov    rsi,QWORD PTR [rdx]
    2010:	mov    r8,QWORD PTR [rdx+0x8]
    2014:	mov    rcx,QWORD PTR [rdx+0x10]
    2018:	mov    rdx,r8
    201b:	call   2020 <botlish_entry_22+0x17>
			201c: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_from<str, int, str>
    2020:	mov    rsp,rbp
    2023:	pop    rbp
    2024:	ret

0000000000002025 <botlish_fn_23: check<int, int, str, str>>:
    2025:	push   rbp
    2026:	mov    rbp,rsp
    2029:	sub    rsp,0x50
    202d:	mov    QWORD PTR [rsp+0x20],rbx
    2032:	mov    QWORD PTR [rsp+0x28],r12
    2037:	mov    QWORD PTR [rsp+0x30],r13
    203c:	mov    QWORD PTR [rsp+0x38],r14
    2041:	mov    QWORD PTR [rsp+0x40],r15
    2046:	mov    r14,rdi
    2049:	mov    QWORD PTR [rsp+0x18],0x0
    2052:	mov    QWORD PTR [rsp],rdx
    2056:	mov    QWORD PTR [rsp+0x8],rcx
    205b:	mov    QWORD PTR [rsp+0x10],r8
    2060:	mov    r13,r8
    2063:	sar    rsi,1
    2066:	mov    r12,rsi
    2069:	mov    r15,rdx
    206c:	test   r12,r12
    206f:	jle    2131 <botlish_fn_23+0x10c>
    2075:	mov    rbx,rcx
    2078:	mov    rsi,rbx
    207b:	mov    rdi,r14
    207e:	call   2083 <botlish_fn_23+0x5e>
			207f: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
    2083:	test   rax,rax
    2086:	jne    20b1 <botlish_fn_23+0x8c>
    208c:	xor    rax,rax
    208f:	mov    rbx,QWORD PTR [rsp+0x20]
    2094:	mov    r12,QWORD PTR [rsp+0x28]
    2099:	mov    r13,QWORD PTR [rsp+0x30]
    209e:	mov    r14,QWORD PTR [rsp+0x38]
    20a3:	mov    r15,QWORD PTR [rsp+0x40]
    20a8:	add    rsp,0x50
    20ac:	mov    rsp,rbp
    20af:	pop    rbp
    20b0:	ret
    20b1:	cmp    rax,0x6
    20b5:	je     20d1 <botlish_fn_23+0xac>
    20bb:	mov    edx,0x1
    20c0:	mov    QWORD PTR [rsp+0x18],0x1
    20c9:	mov    rsi,r15
    20cc:	jmp    20e2 <botlish_fn_23+0xbd>
    20d1:	mov    edx,0x3
    20d6:	mov    QWORD PTR [rsp+0x18],0x3
    20df:	mov    rsi,r15
    20e2:	mov    rax,rsi
    20e5:	and    rax,rdx
    20e8:	test   rax,0x1
    20ee:	je     2109 <botlish_fn_23+0xe4>
    20f4:	lea    rcx,[rdx-0x1]
    20f8:	mov    rax,rsi
    20fb:	add    rax,rcx
    20fe:	seto   cl
    2101:	test   cl,cl
    2103:	je     2111 <botlish_fn_23+0xec>
    2109:	mov    rdi,r14
    210c:	call   2111 <botlish_fn_23+0xec>
			210d: R_X86_64_PLT32	rt_int_add-0x4
    2111:	mov    QWORD PTR [rsp],rax
    2115:	mov    QWORD PTR [rsp+0x8],rbx
    211a:	mov    r8,r13
    211d:	mov    QWORD PTR [rsp+0x10],r8
    2122:	sub    r12,0x1
    2126:	mov    rcx,rbx
    2129:	mov    r15,rax
    212c:	jmp    206c <botlish_fn_23+0x47>
    2131:	mov    rax,r15
    2134:	mov    rbx,QWORD PTR [rsp+0x20]
    2139:	mov    r12,QWORD PTR [rsp+0x28]
    213e:	mov    r13,QWORD PTR [rsp+0x30]
    2143:	mov    r14,QWORD PTR [rsp+0x38]
    2148:	mov    r15,QWORD PTR [rsp+0x40]
    214d:	add    rsp,0x50
    2151:	mov    rsp,rbp
    2154:	pop    rbp
    2155:	ret

0000000000002156 <botlish_entry_23: check<int, int, str, str>>:
    2156:	push   rbp
    2157:	mov    rbp,rsp
    215a:	mov    rsi,QWORD PTR [rdx]
    215d:	mov    r9,QWORD PTR [rdx+0x8]
    2161:	mov    rcx,QWORD PTR [rdx+0x10]
    2165:	mov    r8,QWORD PTR [rdx+0x18]
    2169:	mov    rdx,r9
    216c:	call   2171 <botlish_entry_23+0x1b>
			216d: R_X86_64_PLT32	botlish_fn_23-0x4 ; check<int, int, str, str>
    2171:	mov    rsp,rbp
    2174:	pop    rbp
    2175:	ret

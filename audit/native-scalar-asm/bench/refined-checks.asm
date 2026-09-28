; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 8943  (per function: 1443 39 289 617 74 74 74 125 125 601 262 222 238 528 468 1244 137 94 103 474 491 426 451 344)
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
     71f:	je     849 <botlish_fn_3+0x191>
     725:	mov    esi,0x1
     72a:	mov    r14,rsi
     72d:	mov    QWORD PTR [rsp+0x10],0x1
     736:	mov    QWORD PTR [rsp+0x18],rax
     73b:	mov    r15,rax
     73e:	mov    rax,rsi
     741:	and    rax,r12
     744:	mov    r14,rsi
     747:	test   rax,0x1
     74d:	jne    776 <botlish_fn_3+0xbe>
     753:	mov    rdx,r12
     756:	mov    rsi,r14
     759:	mov    rdi,r13
     75c:	call   761 <botlish_fn_3+0xa9>
			75d: R_X86_64_PLT32	rt_int_cmp-0x4
     761:	mov    ecx,0x2
     766:	test   rax,rax
     769:	cmovl  rcx,QWORD PTR [rip+0x16f]        # 8e0 <botlish_fn_3+0x228>
     771:	jmp    789 <botlish_fn_3+0xd1>
     776:	mov    ecx,0x2
     77b:	mov    rsi,r14
     77e:	cmp    rsi,r12
     781:	cmovl  rcx,QWORD PTR [rip+0x157]        # 8e0 <botlish_fn_3+0x228>
     789:	cmp    rcx,0x6
     78d:	je     7c4 <botlish_fn_3+0x10c>
     793:	mov    rsi,r15
     796:	mov    QWORD PTR [rsp],rsi
     79a:	mov    rdi,r13
     79d:	call   7a2 <botlish_fn_3+0xea>
			79e: R_X86_64_PLT32	rt_set_from_list-0x4
     7a2:	mov    rbx,QWORD PTR [rsp+0x30]
     7a7:	mov    r12,QWORD PTR [rsp+0x38]
     7ac:	mov    r13,QWORD PTR [rsp+0x40]
     7b1:	mov    r14,QWORD PTR [rsp+0x48]
     7b6:	mov    r15,QWORD PTR [rsp+0x50]
     7bb:	add    rsp,0x60
     7bf:	mov    rsp,rbp
     7c2:	pop    rbp
     7c3:	ret
     7c4:	mov    rsi,r14
     7c7:	test   rsi,0x1
     7ce:	je     7ea <botlish_fn_3+0x132>
     7d4:	mov    rcx,QWORD PTR [rbx+0x8]
     7d8:	mov    rsi,r14
     7db:	mov    rax,rsi
     7de:	sar    rax,1
     7e1:	cmp    rax,rcx
     7e4:	jb     809 <botlish_fn_3+0x151>
     7ea:	mov    rdx,r14
     7ed:	mov    rsi,rbx
     7f0:	mov    rdi,r13
     7f3:	call   7f8 <botlish_fn_3+0x140>
			7f4: R_X86_64_PLT32	rt_list_get-0x4
     7f8:	test   rax,rax
     7fb:	je     849 <botlish_fn_3+0x191>
     801:	mov    rsi,rax
     804:	jmp    811 <botlish_fn_3+0x159>
     809:	mov    rsi,QWORD PTR [rbx+0x10]
     80d:	mov    rsi,QWORD PTR [rsi+rax*8]
     811:	mov    rdi,r13
     814:	call   819 <botlish_fn_3+0x161>
			815: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     819:	mov    rsi,rax
     81c:	mov    rdi,r13
     81f:	call   824 <botlish_fn_3+0x16c>
			820: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     824:	test   rax,rax
     827:	je     849 <botlish_fn_3+0x191>
     82d:	mov    QWORD PTR [rsp+0x20],rax
     832:	mov    rdx,rax
     835:	mov    rsi,r15
     838:	mov    rdi,r13
     83b:	call   840 <botlish_fn_3+0x188>
			83c: R_X86_64_PLT32	rt_list_append-0x4
     840:	test   rax,rax
     843:	jne    86e <botlish_fn_3+0x1b6>
     849:	xor    rax,rax
     84c:	mov    rbx,QWORD PTR [rsp+0x30]
     851:	mov    r12,QWORD PTR [rsp+0x38]
     856:	mov    r13,QWORD PTR [rsp+0x40]
     85b:	mov    r14,QWORD PTR [rsp+0x48]
     860:	mov    r15,QWORD PTR [rsp+0x50]
     865:	add    rsp,0x60
     869:	mov    rsp,rbp
     86c:	pop    rbp
     86d:	ret
     86e:	mov    QWORD PTR [rsp+0x18],rax
     873:	mov    r15,rax
     876:	mov    edx,0x3
     87b:	mov    QWORD PTR [rsp+0x20],0x3
     884:	mov    rsi,r14
     887:	test   rsi,0x1
     88e:	jne    89c <botlish_fn_3+0x1e4>
     894:	mov    rsi,r14
     897:	jmp    8c4 <botlish_fn_3+0x20c>
     89c:	mov    rsi,r14
     89f:	mov    rcx,rsi
     8a2:	add    rcx,0x2
     8a6:	seto   al
     8a9:	test   al,al
     8ab:	je     8b9 <botlish_fn_3+0x201>
     8b1:	mov    rsi,r14
     8b4:	jmp    8c4 <botlish_fn_3+0x20c>
     8b9:	mov    rsi,rcx
     8bc:	mov    r14,rcx
     8bf:	jmp    8d2 <botlish_fn_3+0x21a>
     8c4:	mov    rdi,r13
     8c7:	call   8cc <botlish_fn_3+0x214>
			8c8: R_X86_64_PLT32	rt_int_add-0x4
     8cc:	mov    rsi,rax
     8cf:	mov    r14,rax
     8d2:	mov    QWORD PTR [rsp+0x10],rsi
     8d7:	mov    rsi,r14
     8da:	jmp    73e <botlish_fn_3+0x86>
     8df:	add    BYTE PTR [rsi],al
     8e1:	add    BYTE PTR [rax],al
     8e3:	add    BYTE PTR [rax],al
     8e5:	add    BYTE PTR [rax],al
	...

00000000000008e8 <botlish_entry_3: byte::set<List[UnicodeChar]>>:
     8e8:	push   rbp
     8e9:	mov    rbp,rsp
     8ec:	mov    rsi,QWORD PTR [rdx]
     8ef:	call   8f4 <botlish_entry_3+0xc>
			8f0: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::set<List[UnicodeChar]>
     8f4:	mov    rsp,rbp
     8f7:	pop    rbp
     8f8:	ret

00000000000008f9 <botlish_fn_4: ascii::is_digit<int>>:
     8f9:	push   rbp
     8fa:	mov    rbp,rsp
     8fd:	sar    rsi,1
     900:	cmp    rsi,0x30
     904:	jge    914 <botlish_fn_4+0x1b>
     90a:	mov    eax,0x2
     90f:	jmp    92d <botlish_fn_4+0x34>
     914:	cmp    rsi,0x39
     918:	jle    928 <botlish_fn_4+0x2f>
     91e:	mov    eax,0x2
     923:	jmp    92d <botlish_fn_4+0x34>
     928:	mov    eax,0x6
     92d:	mov    rsp,rbp
     930:	pop    rbp
     931:	ret

0000000000000932 <botlish_entry_4: ascii::is_digit<int>>:
     932:	push   rbp
     933:	mov    rbp,rsp
     936:	mov    rsi,QWORD PTR [rdx]
     939:	call   93e <botlish_entry_4+0xc>
			93a: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     93e:	mov    rsp,rbp
     941:	pop    rbp
     942:	ret

0000000000000943 <botlish_fn_5: ascii::is_upper<int>>:
     943:	push   rbp
     944:	mov    rbp,rsp
     947:	sar    rsi,1
     94a:	cmp    rsi,0x41
     94e:	jge    95e <botlish_fn_5+0x1b>
     954:	mov    eax,0x2
     959:	jmp    977 <botlish_fn_5+0x34>
     95e:	cmp    rsi,0x5a
     962:	jle    972 <botlish_fn_5+0x2f>
     968:	mov    eax,0x2
     96d:	jmp    977 <botlish_fn_5+0x34>
     972:	mov    eax,0x6
     977:	mov    rsp,rbp
     97a:	pop    rbp
     97b:	ret

000000000000097c <botlish_entry_5: ascii::is_upper<int>>:
     97c:	push   rbp
     97d:	mov    rbp,rsp
     980:	mov    rsi,QWORD PTR [rdx]
     983:	call   988 <botlish_entry_5+0xc>
			984: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     988:	mov    rsp,rbp
     98b:	pop    rbp
     98c:	ret

000000000000098d <botlish_fn_6: ascii::is_lower<int>>:
     98d:	push   rbp
     98e:	mov    rbp,rsp
     991:	sar    rsi,1
     994:	cmp    rsi,0x61
     998:	jge    9a8 <botlish_fn_6+0x1b>
     99e:	mov    eax,0x2
     9a3:	jmp    9c1 <botlish_fn_6+0x34>
     9a8:	cmp    rsi,0x7a
     9ac:	jle    9bc <botlish_fn_6+0x2f>
     9b2:	mov    eax,0x2
     9b7:	jmp    9c1 <botlish_fn_6+0x34>
     9bc:	mov    eax,0x6
     9c1:	mov    rsp,rbp
     9c4:	pop    rbp
     9c5:	ret

00000000000009c6 <botlish_entry_6: ascii::is_lower<int>>:
     9c6:	push   rbp
     9c7:	mov    rbp,rsp
     9ca:	mov    rsi,QWORD PTR [rdx]
     9cd:	call   9d2 <botlish_entry_6+0xc>
			9ce: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     9d2:	mov    rsp,rbp
     9d5:	pop    rbp
     9d6:	ret

00000000000009d7 <botlish_fn_7: ascii::is_alphabetic<int>>:
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
			9f5: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     9f9:	cmp    rax,0x6
     9fd:	je     a2c <botlish_fn_7+0x55>
     a03:	mov    rsi,r12
     a06:	mov    rdi,r14
     a09:	call   a0e <botlish_fn_7+0x37>
			a0a: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
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

0000000000000a43 <botlish_entry_7: ascii::is_alphabetic<int>>:
     a43:	push   rbp
     a44:	mov    rbp,rsp
     a47:	mov    rsi,QWORD PTR [rdx]
     a4a:	call   a4f <botlish_entry_7+0xc>
			a4b: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     a4f:	mov    rsp,rbp
     a52:	pop    rbp
     a53:	ret

0000000000000a54 <botlish_fn_8: ascii::is_alphanumeric<int>>:
     a54:	push   rbp
     a55:	mov    rbp,rsp
     a58:	sub    rsp,0x10
     a5c:	mov    QWORD PTR [rsp],r12
     a60:	mov    QWORD PTR [rsp+0x8],r14
     a65:	mov    r12,rsi
     a68:	mov    r14,rdi
     a6b:	mov    rsi,r12
     a6e:	mov    rdi,r14
     a71:	call   a76 <botlish_fn_8+0x22>
			a72: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     a76:	cmp    rax,0x6
     a7a:	je     aa9 <botlish_fn_8+0x55>
     a80:	mov    rsi,r12
     a83:	mov    rdi,r14
     a86:	call   a8b <botlish_fn_8+0x37>
			a87: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     a8b:	cmp    rax,0x6
     a8f:	je     a9f <botlish_fn_8+0x4b>
     a95:	mov    eax,0x2
     a9a:	jmp    aae <botlish_fn_8+0x5a>
     a9f:	mov    eax,0x6
     aa4:	jmp    aae <botlish_fn_8+0x5a>
     aa9:	mov    eax,0x6
     aae:	mov    r12,QWORD PTR [rsp]
     ab2:	mov    r14,QWORD PTR [rsp+0x8]
     ab7:	add    rsp,0x10
     abb:	mov    rsp,rbp
     abe:	pop    rbp
     abf:	ret

0000000000000ac0 <botlish_entry_8: ascii::is_alphanumeric<int>>:
     ac0:	push   rbp
     ac1:	mov    rbp,rsp
     ac4:	mov    rsi,QWORD PTR [rdx]
     ac7:	call   acc <botlish_entry_8+0xc>
			ac8: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
     acc:	mov    rsp,rbp
     acf:	pop    rbp
     ad0:	ret
     ad1:	add    BYTE PTR [rax],al
     ad3:	add    BYTE PTR [rax],al
     ad5:	add    BYTE PTR [rax],al
	...

0000000000000ad8 <botlish_fn_9: web::emailish?<str>>:
     ad8:	push   rbp
     ad9:	mov    rbp,rsp
     adc:	sub    rsp,0x50
     ae0:	mov    QWORD PTR [rsp+0x30],rbx
     ae5:	mov    QWORD PTR [rsp+0x38],r12
     aea:	mov    QWORD PTR [rsp+0x40],r13
     aef:	mov    QWORD PTR [rsp+0x48],r14
     af4:	mov    r14,rdi
     af7:	mov    QWORD PTR [rsp],rsi
     afb:	mov    r13,rsi
     afe:	mov    rsi,r13
     b01:	mov    rdi,r14
     b04:	call   b09 <botlish_fn_9+0x31>
			b05: R_X86_64_PLT32	rt_str_len-0x4
     b09:	mov    rbx,rax
     b0c:	mov    QWORD PTR [rsp+0x8],rax
     b11:	mov    esi,0x1
     b16:	mov    QWORD PTR [rsp+0x10],0x1
     b1f:	mov    rdi,r14
     b22:	mov    rcx,QWORD PTR [rdi+0x10]
     b26:	mov    rdx,QWORD PTR [rcx+0xc8]
     b2d:	mov    QWORD PTR [rsp+0x18],rdx
     b32:	mov    rcx,rbx
     b35:	mov    r8,r13
     b38:	call   b3d <botlish_fn_9+0x65>
			b39: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<generic>
     b3d:	mov    r12,rax
     b40:	test   r12,r12
     b43:	je     c9f <botlish_fn_9+0x1c7>
     b49:	mov    QWORD PTR [rsp+0x10],r12
     b4e:	test   r12,0x1
     b55:	jne    b80 <botlish_fn_9+0xa8>
     b5b:	mov    edx,0x1
     b60:	mov    rsi,r12
     b63:	mov    rdi,r14
     b66:	call   b6b <botlish_fn_9+0x93>
			b67: R_X86_64_PLT32	rt_int_cmp-0x4
     b6b:	mov    ecx,0x2
     b70:	test   rax,rax
     b73:	cmove  rcx,QWORD PTR [rip+0x175]        # cf0 <botlish_fn_9+0x218>
     b7b:	jmp    b91 <botlish_fn_9+0xb9>
     b80:	mov    ecx,0x2
     b85:	cmp    r12,0x1
     b89:	cmove  rcx,QWORD PTR [rip+0x15f]        # cf0 <botlish_fn_9+0x218>
     b91:	cmp    rcx,0x6
     b95:	je     cce <botlish_fn_9+0x1f6>
     b9b:	mov    rax,r12
     b9e:	and    rax,rbx
     ba1:	test   rax,0x1
     ba7:	jne    bd0 <botlish_fn_9+0xf8>
     bad:	mov    rdx,rbx
     bb0:	mov    rsi,r12
     bb3:	mov    rdi,r14
     bb6:	call   bbb <botlish_fn_9+0xe3>
			bb7: R_X86_64_PLT32	rt_int_cmp-0x4
     bbb:	mov    ecx,0x2
     bc0:	test   rax,rax
     bc3:	cmovge rcx,QWORD PTR [rip+0x125]        # cf0 <botlish_fn_9+0x218>
     bcb:	jmp    be0 <botlish_fn_9+0x108>
     bd0:	mov    ecx,0x2
     bd5:	cmp    r12,rbx
     bd8:	cmovge rcx,QWORD PTR [rip+0x110]        # cf0 <botlish_fn_9+0x218>
     be0:	cmp    rcx,0x6
     be4:	je     cc4 <botlish_fn_9+0x1ec>
     bea:	lea    rcx,[rsp+0x20]
     bef:	mov    rdx,r13
     bf2:	mov    rsi,r12
     bf5:	mov    rdi,r14
     bf8:	call   bfd <botlish_fn_9+0x125>
			bf9: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
     bfd:	test   rax,rax
     c00:	mov    rsi,rax
     c03:	je     c9f <botlish_fn_9+0x1c7>
     c09:	mov    rdx,QWORD PTR [rsp+0x20]
     c0e:	mov    rcx,QWORD PTR [rsp+0x28]
     c13:	mov    rdi,r14
     c16:	mov    rdi,QWORD PTR [rdi+0x10]
     c1a:	mov    r8,QWORD PTR [rdi+0xd0]
     c21:	mov    rdi,r14
     c24:	call   c29 <botlish_fn_9+0x151>
			c25: R_X86_64_PLT32	rt_str_region_eq-0x4
     c29:	cmp    rax,0x6
     c2d:	je     c3d <botlish_fn_9+0x165>
     c33:	mov    eax,0x2
     c38:	jmp    cd3 <botlish_fn_9+0x1fb>
     c3d:	mov    QWORD PTR [rsp+0x18],0x3
     c46:	test   r12,0x1
     c4d:	jne    c5b <botlish_fn_9+0x183>
     c53:	mov    rcx,r12
     c56:	jmp    c70 <botlish_fn_9+0x198>
     c5b:	mov    rsi,r12
     c5e:	add    rsi,0x2
     c62:	mov    rcx,r12
     c65:	seto   al
     c68:	test   al,al
     c6a:	je     c83 <botlish_fn_9+0x1ab>
     c70:	mov    edx,0x3
     c75:	mov    rsi,rcx
     c78:	mov    rdi,r14
     c7b:	call   c80 <botlish_fn_9+0x1a8>
			c7c: R_X86_64_PLT32	rt_int_add-0x4
     c80:	mov    rsi,rax
     c83:	mov    QWORD PTR [rsp+0x10],rsi
     c88:	mov    rcx,r13
     c8b:	mov    rdx,rbx
     c8e:	mov    rdi,r14
     c91:	call   c96 <botlish_fn_9+0x1be>
			c92: R_X86_64_PLT32	botlish_fn_15-0x4 ; domain?<generic>
     c96:	test   rax,rax
     c99:	jne    cd3 <botlish_fn_9+0x1fb>
     c9f:	xor    rax,rax
     ca2:	mov    rbx,QWORD PTR [rsp+0x30]
     ca7:	mov    r12,QWORD PTR [rsp+0x38]
     cac:	mov    r13,QWORD PTR [rsp+0x40]
     cb1:	mov    r14,QWORD PTR [rsp+0x48]
     cb6:	add    rsp,0x50
     cba:	mov    rsp,rbp
     cbd:	pop    rbp
     cbe:	ret
     cbf:	jmp    cd3 <botlish_fn_9+0x1fb>
     cc4:	mov    eax,0x2
     cc9:	jmp    cd3 <botlish_fn_9+0x1fb>
     cce:	mov    eax,0x2
     cd3:	mov    rbx,QWORD PTR [rsp+0x30]
     cd8:	mov    r12,QWORD PTR [rsp+0x38]
     cdd:	mov    r13,QWORD PTR [rsp+0x40]
     ce2:	mov    r14,QWORD PTR [rsp+0x48]
     ce7:	add    rsp,0x50
     ceb:	mov    rsp,rbp
     cee:	pop    rbp
     cef:	ret
     cf0:	(bad)
     cf1:	add    BYTE PTR [rax],al
     cf3:	add    BYTE PTR [rax],al
     cf5:	add    BYTE PTR [rax],al
	...

0000000000000cf8 <botlish_entry_9: web::emailish?<str>>:
     cf8:	push   rbp
     cf9:	mov    rbp,rsp
     cfc:	mov    rsi,QWORD PTR [rdx]
     cff:	call   d04 <botlish_entry_9+0xc>
			d00: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
     d04:	mov    rsp,rbp
     d07:	pop    rbp
     d08:	ret

0000000000000d09 <botlish_fn_10: char_at<generic>>:
     d09:	push   rbp
     d0a:	mov    rbp,rsp
     d0d:	sub    rsp,0x50
     d11:	mov    QWORD PTR [rsp+0x20],rbx
     d16:	mov    QWORD PTR [rsp+0x28],r12
     d1b:	mov    QWORD PTR [rsp+0x30],r13
     d20:	mov    QWORD PTR [rsp+0x38],r14
     d25:	mov    QWORD PTR [rsp+0x40],r15
     d2a:	mov    r12,rdi
     d2d:	mov    r15,rcx
     d30:	mov    QWORD PTR [rsp],rsi
     d34:	mov    QWORD PTR [rsp+0x8],rdx
     d39:	mov    r13,rdx
     d3c:	mov    QWORD PTR [rsp+0x10],0x3
     d45:	test   rsi,0x1
     d4c:	jne    d5a <botlish_fn_10+0x51>
     d52:	mov    rbx,rsi
     d55:	jmp    d7a <botlish_fn_10+0x71>
     d5a:	mov    rax,rsi
     d5d:	add    rax,0x2
     d61:	mov    rbx,rsi
     d64:	seto   cl
     d67:	test   cl,cl
     d69:	jne    d7a <botlish_fn_10+0x71>
     d6f:	mov    rdi,r12
     d72:	mov    r14,rax
     d75:	jmp    d90 <botlish_fn_10+0x87>
     d7a:	mov    edx,0x3
     d7f:	mov    rsi,rbx
     d82:	mov    rdi,r12
     d85:	call   d8a <botlish_fn_10+0x81>
			d86: R_X86_64_PLT32	rt_int_add-0x4
     d8a:	mov    r14,rax
     d8d:	mov    rdi,r12
     d90:	mov    rcx,r14
     d93:	mov    rdx,rbx
     d96:	mov    rsi,r13
     d99:	call   d9e <botlish_fn_10+0x95>
			d9a: R_X86_64_PLT32	rt_str_region_check-0x4
     d9e:	test   rax,rax
     da1:	jne    dcc <botlish_fn_10+0xc3>
     da7:	xor    rax,rax
     daa:	mov    rbx,QWORD PTR [rsp+0x20]
     daf:	mov    r12,QWORD PTR [rsp+0x28]
     db4:	mov    r13,QWORD PTR [rsp+0x30]
     db9:	mov    r14,QWORD PTR [rsp+0x38]
     dbe:	mov    r15,QWORD PTR [rsp+0x40]
     dc3:	add    rsp,0x50
     dc7:	mov    rsp,rbp
     dca:	pop    rbp
     dcb:	ret
     dcc:	mov    rcx,r15
     dcf:	mov    QWORD PTR [rcx],rbx
     dd2:	mov    rax,r14
     dd5:	mov    QWORD PTR [rcx+0x8],rax
     dd9:	mov    rax,r13
     ddc:	mov    rbx,QWORD PTR [rsp+0x20]
     de1:	mov    r12,QWORD PTR [rsp+0x28]
     de6:	mov    r13,QWORD PTR [rsp+0x30]
     deb:	mov    r14,QWORD PTR [rsp+0x38]
     df0:	mov    r15,QWORD PTR [rsp+0x40]
     df5:	add    rsp,0x50
     df9:	mov    rsp,rbp
     dfc:	pop    rbp
     dfd:	ret

0000000000000dfe <botlish_entry_10: char_at<generic>>:
     dfe:	push   rbp
     dff:	mov    rbp,rsp
     e02:	ud2

0000000000000e04 <botlish_fn_11: char_at<generic>>:
     e04:	push   rbp
     e05:	mov    rbp,rsp
     e08:	sub    rsp,0x40
     e0c:	mov    QWORD PTR [rsp+0x20],rbx
     e11:	mov    QWORD PTR [rsp+0x28],r12
     e16:	mov    QWORD PTR [rsp+0x30],r13
     e1b:	mov    r12,rdi
     e1e:	mov    QWORD PTR [rsp],rsi
     e22:	mov    QWORD PTR [rsp+0x8],rdx
     e27:	mov    r13,rdx
     e2a:	mov    QWORD PTR [rsp+0x10],0x3
     e33:	test   rsi,0x1
     e3a:	jne    e48 <botlish_fn_11+0x44>
     e40:	mov    rbx,rsi
     e43:	jmp    e5d <botlish_fn_11+0x59>
     e48:	mov    rcx,rsi
     e4b:	add    rcx,0x2
     e4f:	mov    rbx,rsi
     e52:	seto   al
     e55:	test   al,al
     e57:	je     e70 <botlish_fn_11+0x6c>
     e5d:	mov    edx,0x3
     e62:	mov    rsi,rbx
     e65:	mov    rdi,r12
     e68:	call   e6d <botlish_fn_11+0x69>
			e69: R_X86_64_PLT32	rt_int_add-0x4
     e6d:	mov    rcx,rax
     e70:	mov    QWORD PTR [rsp+0x10],rcx
     e75:	mov    rdx,rbx
     e78:	mov    rsi,r13
     e7b:	mov    rdi,r12
     e7e:	call   e83 <botlish_fn_11+0x7f>
			e7f: R_X86_64_PLT32	rt_substr-0x4
     e83:	test   rax,rax
     e86:	jne    ea7 <botlish_fn_11+0xa3>
     e8c:	xor    rax,rax
     e8f:	mov    rbx,QWORD PTR [rsp+0x20]
     e94:	mov    r12,QWORD PTR [rsp+0x28]
     e99:	mov    r13,QWORD PTR [rsp+0x30]
     e9e:	add    rsp,0x40
     ea2:	mov    rsp,rbp
     ea5:	pop    rbp
     ea6:	ret
     ea7:	mov    rbx,QWORD PTR [rsp+0x20]
     eac:	mov    r12,QWORD PTR [rsp+0x28]
     eb1:	mov    r13,QWORD PTR [rsp+0x30]
     eb6:	add    rsp,0x40
     eba:	mov    rsp,rbp
     ebd:	pop    rbp
     ebe:	ret

0000000000000ebf <botlish_entry_11: char_at<generic>>:
     ebf:	push   rbp
     ec0:	mov    rbp,rsp
     ec3:	mov    rsi,QWORD PTR [rdx]
     ec6:	mov    rdx,QWORD PTR [rdx+0x8]
     eca:	call   ecf <botlish_entry_11+0x10>
			ecb: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
     ecf:	mov    rsp,rbp
     ed2:	pop    rbp
     ed3:	ret

0000000000000ed4 <botlish_fn_12: local_char?<generic>>:
     ed4:	push   rbp
     ed5:	mov    rbp,rsp
     ed8:	sub    rsp,0x10
     edc:	mov    QWORD PTR [rsp],rbx
     ee0:	mov    QWORD PTR [rsp+0x8],r12
     ee5:	xor    r8d,r8d
     ee8:	test   rsi,0x7
     eef:	jne    eff <botlish_fn_12+0x2b>
     ef5:	movzx  rax,BYTE PTR [rsi]
     ef9:	cmp    al,0x2
     efb:	sete   r8b
     eff:	test   r8b,r8b
     f02:	jne    f22 <botlish_fn_12+0x4e>
     f08:	mov    rax,QWORD PTR [rdi+0x10]
     f0c:	mov    rcx,QWORD PTR [rax+0xd8]
     f13:	mov    edx,0x1
     f18:	call   f1d <botlish_fn_12+0x49>
			f19: R_X86_64_PLT32	rt_type_error-0x4
     f1d:	jmp    f36 <botlish_fn_12+0x62>
     f22:	mov    rbx,rsi
     f25:	mov    r12,rdi
     f28:	call   f2d <botlish_fn_12+0x59>
			f29: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
     f2d:	test   rax,rax
     f30:	jne    f4b <botlish_fn_12+0x77>
     f36:	xor    rax,rax
     f39:	mov    rbx,QWORD PTR [rsp]
     f3d:	mov    r12,QWORD PTR [rsp+0x8]
     f42:	add    rsp,0x10
     f46:	mov    rsp,rbp
     f49:	pop    rbp
     f4a:	ret
     f4b:	cmp    rax,0x6
     f4f:	je     f85 <botlish_fn_12+0xb1>
     f55:	mov    rdi,r12
     f58:	mov    rax,QWORD PTR [rdi+0x30]
     f5c:	mov    rsi,QWORD PTR [rax]
     f5f:	mov    rdx,rbx
     f62:	call   f67 <botlish_fn_12+0x93>
			f63: R_X86_64_PLT32	rt_set_contains-0x4
     f67:	cmp    rax,0x6
     f6b:	je     f7b <botlish_fn_12+0xa7>
     f71:	mov    eax,0x2
     f76:	jmp    f8a <botlish_fn_12+0xb6>
     f7b:	mov    eax,0x6
     f80:	jmp    f8a <botlish_fn_12+0xb6>
     f85:	mov    eax,0x6
     f8a:	mov    rbx,QWORD PTR [rsp]
     f8e:	mov    r12,QWORD PTR [rsp+0x8]
     f93:	add    rsp,0x10
     f97:	mov    rsp,rbp
     f9a:	pop    rbp
     f9b:	ret

0000000000000f9c <botlish_entry_12: local_char?<generic>>:
     f9c:	push   rbp
     f9d:	mov    rbp,rsp
     fa0:	mov    rsi,QWORD PTR [rdx]
     fa3:	call   fa8 <botlish_entry_12+0xc>
			fa4: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<generic>
     fa8:	mov    rsp,rbp
     fab:	pop    rbp
     fac:	ret
     fad:	add    BYTE PTR [rax],al
	...

0000000000000fb0 <botlish_fn_13: scan_while<generic>>:
     fb0:	push   rbp
     fb1:	mov    rbp,rsp
     fb4:	sub    rsp,0x60
     fb8:	mov    QWORD PTR [rsp+0x30],rbx
     fbd:	mov    QWORD PTR [rsp+0x38],r12
     fc2:	mov    QWORD PTR [rsp+0x40],r13
     fc7:	mov    QWORD PTR [rsp+0x48],r14
     fcc:	mov    QWORD PTR [rsp+0x50],r15
     fd1:	mov    rbx,rcx
     fd4:	mov    r14,rdi
     fd7:	mov    QWORD PTR [rsp+0x20],0x0
     fe0:	mov    QWORD PTR [rsp],rdx
     fe4:	mov    r13,rdx
     fe7:	mov    QWORD PTR [rsp+0x8],rcx
     fec:	mov    QWORD PTR [rsp+0x10],r8
     ff1:	mov    r12,r8
     ff4:	mov    QWORD PTR [rsp+0x18],rsi
     ff9:	mov    rax,rsi
     ffc:	mov    rcx,rbx
     fff:	mov    r15,rsi
    1002:	mov    rcx,rbx
    1005:	and    rax,rcx
    1008:	test   rax,0x1
    100e:	jne    1037 <botlish_fn_13+0x87>
    1014:	mov    rdx,rbx
    1017:	mov    rsi,r15
    101a:	mov    rdi,r14
    101d:	call   1022 <botlish_fn_13+0x72>
			101e: R_X86_64_PLT32	rt_int_cmp-0x4
    1022:	mov    ecx,0x2
    1027:	test   rax,rax
    102a:	cmovl  rcx,QWORD PTR [rip+0x146]        # 1178 <botlish_fn_13+0x1c8>
    1032:	jmp    104d <botlish_fn_13+0x9d>
    1037:	mov    ecx,0x2
    103c:	mov    rax,r15
    103f:	mov    rdx,rbx
    1042:	cmp    rax,rdx
    1045:	cmovl  rcx,QWORD PTR [rip+0x12b]        # 1178 <botlish_fn_13+0x1c8>
    104d:	cmp    rcx,0x6
    1051:	je     107c <botlish_fn_13+0xcc>
    1057:	mov    rax,rbx
    105a:	mov    rbx,QWORD PTR [rsp+0x30]
    105f:	mov    r12,QWORD PTR [rsp+0x38]
    1064:	mov    r13,QWORD PTR [rsp+0x40]
    1069:	mov    r14,QWORD PTR [rsp+0x48]
    106e:	mov    r15,QWORD PTR [rsp+0x50]
    1073:	add    rsp,0x60
    1077:	mov    rsp,rbp
    107a:	pop    rbp
    107b:	ret
    107c:	mov    rdx,r12
    107f:	mov    rsi,r15
    1082:	mov    rdi,r14
    1085:	call   108a <botlish_fn_13+0xda>
			1086: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    108a:	test   rax,rax
    108d:	je     10d7 <botlish_fn_13+0x127>
    1093:	mov    QWORD PTR [rsp+0x20],rax
    1098:	lea    rcx,[rsp+0x28]
    109d:	mov    QWORD PTR [rsp+0x28],rax
    10a2:	mov    edx,0x1
    10a7:	mov    rsi,r13
    10aa:	mov    rdi,r14
    10ad:	call   10b2 <botlish_fn_13+0x102>
			10ae: R_X86_64_PLT32	rt_call_value-0x4
    10b2:	test   rax,rax
    10b5:	je     10d7 <botlish_fn_13+0x127>
    10bb:	mov    rcx,rax
    10be:	or     rcx,0x4
    10c2:	mov    rsi,rax
    10c5:	cmp    rcx,0x6
    10c9:	je     10fc <botlish_fn_13+0x14c>
    10cf:	mov    rdi,r14
    10d2:	call   10d7 <botlish_fn_13+0x127>
			10d3: R_X86_64_PLT32	rt_not_boolean-0x4
    10d7:	xor    rax,rax
    10da:	mov    rbx,QWORD PTR [rsp+0x30]
    10df:	mov    r12,QWORD PTR [rsp+0x38]
    10e4:	mov    r13,QWORD PTR [rsp+0x40]
    10e9:	mov    r14,QWORD PTR [rsp+0x48]
    10ee:	mov    r15,QWORD PTR [rsp+0x50]
    10f3:	add    rsp,0x60
    10f7:	mov    rsp,rbp
    10fa:	pop    rbp
    10fb:	ret
    10fc:	cmp    rsi,0x6
    1100:	je     112b <botlish_fn_13+0x17b>
    1106:	mov    rax,r15
    1109:	mov    rbx,QWORD PTR [rsp+0x30]
    110e:	mov    r12,QWORD PTR [rsp+0x38]
    1113:	mov    r13,QWORD PTR [rsp+0x40]
    1118:	mov    r14,QWORD PTR [rsp+0x48]
    111d:	mov    r15,QWORD PTR [rsp+0x50]
    1122:	add    rsp,0x60
    1126:	mov    rsp,rbp
    1129:	pop    rbp
    112a:	ret
    112b:	mov    QWORD PTR [rsp+0x20],0x3
    1134:	mov    rax,r15
    1137:	test   rax,0x1
    113d:	je     1158 <botlish_fn_13+0x1a8>
    1143:	mov    rcx,r15
    1146:	mov    rax,rcx
    1149:	add    rax,0x2
    114d:	seto   dl
    1150:	test   dl,dl
    1152:	je     1168 <botlish_fn_13+0x1b8>
    1158:	mov    edx,0x3
    115d:	mov    rsi,r15
    1160:	mov    rdi,r14
    1163:	call   1168 <botlish_fn_13+0x1b8>
			1164: R_X86_64_PLT32	rt_int_add-0x4
    1168:	mov    QWORD PTR [rsp+0x18],rax
    116d:	mov    rcx,rbx
    1170:	mov    r15,rax
    1173:	jmp    1002 <botlish_fn_13+0x52>
    1178:	(bad)
    1179:	add    BYTE PTR [rax],al
    117b:	add    BYTE PTR [rax],al
    117d:	add    BYTE PTR [rax],al
	...

0000000000001180 <botlish_entry_13: scan_while<generic>>:
    1180:	push   rbp
    1181:	mov    rbp,rsp
    1184:	mov    rsi,QWORD PTR [rdx]
    1187:	mov    r9,QWORD PTR [rdx+0x8]
    118b:	mov    rcx,QWORD PTR [rdx+0x10]
    118f:	mov    r8,QWORD PTR [rdx+0x18]
    1193:	mov    rdx,r9
    1196:	call   119b <botlish_entry_13+0x1b>
			1197: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<generic>
    119b:	mov    rsp,rbp
    119e:	pop    rbp
    119f:	ret

00000000000011a0 <botlish_fn_14: tld?<generic>>:
    11a0:	push   rbp
    11a1:	mov    rbp,rsp
    11a4:	sub    rsp,0x40
    11a8:	mov    QWORD PTR [rsp+0x20],rbx
    11ad:	mov    QWORD PTR [rsp+0x28],r12
    11b2:	mov    QWORD PTR [rsp+0x30],r13
    11b7:	mov    QWORD PTR [rsp+0x38],r14
    11bc:	mov    QWORD PTR [rsp],rsi
    11c0:	mov    r8,rsi
    11c3:	mov    QWORD PTR [rsp+0x8],rdx
    11c8:	mov    r14,rdx
    11cb:	mov    QWORD PTR [rsp+0x10],rcx
    11d0:	mov    rax,QWORD PTR [rdi+0x10]
    11d4:	mov    r12,rdi
    11d7:	mov    rdx,QWORD PTR [rax+0xe0]
    11de:	mov    QWORD PTR [rsp+0x18],rdx
    11e3:	mov    rbx,r8
    11e6:	mov    r8,rcx
    11e9:	mov    rcx,r14
    11ec:	mov    rsi,rbx
    11ef:	call   11f4 <botlish_fn_14+0x54>
			11f0: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<generic>
    11f4:	mov    rcx,rax
    11f7:	mov    r13,rax
    11fa:	test   rax,rcx
    11fd:	jne    1223 <botlish_fn_14+0x83>
    1203:	xor    rax,rax
    1206:	mov    rbx,QWORD PTR [rsp+0x20]
    120b:	mov    r12,QWORD PTR [rsp+0x28]
    1210:	mov    r13,QWORD PTR [rsp+0x30]
    1215:	mov    r14,QWORD PTR [rsp+0x38]
    121a:	add    rsp,0x40
    121e:	mov    rsp,rbp
    1221:	pop    rbp
    1222:	ret
    1223:	mov    rax,r13
    1226:	mov    QWORD PTR [rsp+0x8],rax
    122b:	mov    rdx,r14
    122e:	and    rax,rdx
    1231:	test   rax,0x1
    1237:	jne    1260 <botlish_fn_14+0xc0>
    123d:	mov    rsi,r13
    1240:	mov    rdi,r12
    1243:	call   1248 <botlish_fn_14+0xa8>
			1244: R_X86_64_PLT32	rt_int_cmp-0x4
    1248:	mov    ecx,0x2
    124d:	test   rax,rax
    1250:	cmove  rcx,QWORD PTR [rip+0xe0]        # 1338 <botlish_fn_14+0x198>
    1258:	mov    rax,r13
    125b:	jmp    1273 <botlish_fn_14+0xd3>
    1260:	mov    ecx,0x2
    1265:	mov    rax,r13
    1268:	cmp    rax,rdx
    126b:	cmove  rcx,QWORD PTR [rip+0xc5]        # 1338 <botlish_fn_14+0x198>
    1273:	cmp    rcx,0x6
    1277:	je     128a <botlish_fn_14+0xea>
    127d:	mov    ecx,0x2
    1282:	mov    rax,rcx
    1285:	jmp    1317 <botlish_fn_14+0x177>
    128a:	mov    rcx,rax
    128d:	and    rcx,rbx
    1290:	test   rcx,0x1
    1297:	jne    12a8 <botlish_fn_14+0x108>
    129d:	mov    rdx,rbx
    12a0:	mov    rsi,rax
    12a3:	jmp    12c9 <botlish_fn_14+0x129>
    12a8:	mov    rcx,rax
    12ab:	sub    rcx,rbx
    12ae:	mov    r8,rbx
    12b1:	mov    r13,rax
    12b4:	seto   al
    12b7:	lea    rsi,[rcx+0x1]
    12bb:	test   al,al
    12bd:	je     12d4 <botlish_fn_14+0x134>
    12c3:	mov    rdx,r8
    12c6:	mov    rsi,r13
    12c9:	mov    rdi,r12
    12cc:	call   12d1 <botlish_fn_14+0x131>
			12cd: R_X86_64_PLT32	rt_int_sub-0x4
    12d1:	mov    rsi,rax
    12d4:	test   rsi,0x1
    12db:	jne    1306 <botlish_fn_14+0x166>
    12e1:	mov    edx,0x5
    12e6:	mov    rdi,r12
    12e9:	call   12ee <botlish_fn_14+0x14e>
			12ea: R_X86_64_PLT32	rt_int_cmp-0x4
    12ee:	mov    ecx,0x2
    12f3:	test   rax,rax
    12f6:	mov    rax,rcx
    12f9:	cmovge rax,QWORD PTR [rip+0x37]        # 1338 <botlish_fn_14+0x198>
    1301:	jmp    1317 <botlish_fn_14+0x177>
    1306:	mov    eax,0x2
    130b:	cmp    rsi,0x5
    130f:	cmovge rax,QWORD PTR [rip+0x21]        # 1338 <botlish_fn_14+0x198>
    1317:	mov    rbx,QWORD PTR [rsp+0x20]
    131c:	mov    r12,QWORD PTR [rsp+0x28]
    1321:	mov    r13,QWORD PTR [rsp+0x30]
    1326:	mov    r14,QWORD PTR [rsp+0x38]
    132b:	add    rsp,0x40
    132f:	mov    rsp,rbp
    1332:	pop    rbp
    1333:	ret
    1334:	add    BYTE PTR [rax],al
    1336:	add    BYTE PTR [rax],al
    1338:	(bad)
    1339:	add    BYTE PTR [rax],al
    133b:	add    BYTE PTR [rax],al
    133d:	add    BYTE PTR [rax],al
	...

0000000000001340 <botlish_entry_14: tld?<generic>>:
    1340:	push   rbp
    1341:	mov    rbp,rsp
    1344:	mov    rsi,QWORD PTR [rdx]
    1347:	mov    r8,QWORD PTR [rdx+0x8]
    134b:	mov    rcx,QWORD PTR [rdx+0x10]
    134f:	mov    rdx,r8
    1352:	call   1357 <botlish_entry_14+0x17>
			1353: R_X86_64_PLT32	botlish_fn_14-0x4 ; tld?<generic>
    1357:	mov    rsp,rbp
    135a:	pop    rbp
    135b:	ret
    135c:	add    BYTE PTR [rax],al
	...

0000000000001360 <botlish_fn_15: domain?<generic>>:
    1360:	push   rbp
    1361:	mov    rbp,rsp
    1364:	sub    rsp,0xa0
    136b:	mov    QWORD PTR [rsp+0x70],rbx
    1370:	mov    QWORD PTR [rsp+0x78],r12
    1375:	mov    QWORD PTR [rsp+0x80],r13
    137d:	mov    QWORD PTR [rsp+0x88],r14
    1385:	mov    QWORD PTR [rsp+0x90],r15
    138d:	mov    QWORD PTR [rsp+0x20],0x0
    1396:	mov    QWORD PTR [rsp],rsi
    139a:	mov    QWORD PTR [rsp+0x8],rdx
    139f:	mov    QWORD PTR [rsp+0x10],rcx
    13a4:	mov    r14,rcx
    13a7:	mov    QWORD PTR [rsp+0x18],rsi
    13ac:	mov    r15,rsi
    13af:	mov    r13,rdx
    13b2:	mov    rax,rsi
    13b5:	and    rax,r13
    13b8:	mov    QWORD PTR [rsp+0x58],rsi
    13bd:	test   rax,0x1
    13c3:	jne    13ee <botlish_fn_15+0x8e>
    13c9:	mov    rbx,rdi
    13cc:	mov    rdx,r13
    13cf:	mov    rsi,QWORD PTR [rsp+0x58]
    13d4:	call   13d9 <botlish_fn_15+0x79>
			13d5: R_X86_64_PLT32	rt_int_cmp-0x4
    13d9:	mov    ecx,0x2
    13de:	test   rax,rax
    13e1:	cmovl  rcx,QWORD PTR [rip+0x42f]        # 1818 <botlish_fn_15+0x4b8>
    13e9:	jmp    1406 <botlish_fn_15+0xa6>
    13ee:	mov    rbx,rdi
    13f1:	mov    ecx,0x2
    13f6:	mov    rsi,QWORD PTR [rsp+0x58]
    13fb:	cmp    rsi,r13
    13fe:	cmovl  rcx,QWORD PTR [rip+0x412]        # 1818 <botlish_fn_15+0x4b8>
    1406:	cmp    rcx,0x6
    140a:	je     1443 <botlish_fn_15+0xe3>
    1410:	mov    eax,0x2
    1415:	mov    rbx,QWORD PTR [rsp+0x70]
    141a:	mov    r12,QWORD PTR [rsp+0x78]
    141f:	mov    r13,QWORD PTR [rsp+0x80]
    1427:	mov    r14,QWORD PTR [rsp+0x88]
    142f:	mov    r15,QWORD PTR [rsp+0x90]
    1437:	add    rsp,0xa0
    143e:	mov    rsp,rbp
    1441:	pop    rbp
    1442:	ret
    1443:	lea    rcx,[rsp+0x28]
    1448:	mov    rdx,r14
    144b:	mov    rsi,QWORD PTR [rsp+0x58]
    1450:	mov    rdi,rbx
    1453:	call   1458 <botlish_fn_15+0xf8>
			1454: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    1458:	test   rax,rax
    145b:	mov    rsi,rax
    145e:	je     16c7 <botlish_fn_15+0x367>
    1464:	mov    rdx,QWORD PTR [rsp+0x28]
    1469:	mov    rcx,QWORD PTR [rsp+0x30]
    146e:	mov    rax,QWORD PTR [rbx+0x10]
    1472:	mov    r8,QWORD PTR [rax]
    1475:	mov    rdi,rbx
    1478:	call   147d <botlish_fn_15+0x11d>
			1479: R_X86_64_PLT32	rt_str_region_eq-0x4
    147d:	cmp    rax,0x6
    1481:	je     1578 <botlish_fn_15+0x218>
    1487:	lea    rcx,[rsp+0x48]
    148c:	mov    rdx,r14
    148f:	mov    rsi,QWORD PTR [rsp+0x58]
    1494:	mov    rdi,rbx
    1497:	call   149c <botlish_fn_15+0x13c>
			1498: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    149c:	test   rax,rax
    149f:	mov    r12,rax
    14a2:	je     16c7 <botlish_fn_15+0x367>
    14a8:	mov    rdx,QWORD PTR [rsp+0x48]
    14ad:	mov    QWORD PTR [rsp+0x68],rdx
    14b2:	mov    rcx,QWORD PTR [rsp+0x50]
    14b7:	mov    QWORD PTR [rsp+0x60],rcx
    14bc:	mov    rsi,r12
    14bf:	mov    rdi,rbx
    14c2:	call   14c7 <botlish_fn_15+0x167>
			14c3: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    14c7:	test   rax,rax
    14ca:	je     16c7 <botlish_fn_15+0x367>
    14d0:	cmp    rax,0x6
    14d4:	je     1515 <botlish_fn_15+0x1b5>
    14da:	mov    rax,QWORD PTR [rbx+0x10]
    14de:	mov    r8,QWORD PTR [rax+0x20]
    14e2:	mov    rcx,QWORD PTR [rsp+0x60]
    14e7:	mov    rdx,QWORD PTR [rsp+0x68]
    14ec:	mov    rsi,r12
    14ef:	mov    rdi,rbx
    14f2:	call   14f7 <botlish_fn_15+0x197>
			14f3: R_X86_64_PLT32	rt_str_region_eq-0x4
    14f7:	cmp    rax,0x6
    14fb:	je     150b <botlish_fn_15+0x1ab>
    1501:	mov    edx,0x2
    1506:	jmp    151a <botlish_fn_15+0x1ba>
    150b:	mov    edx,0x6
    1510:	jmp    151a <botlish_fn_15+0x1ba>
    1515:	mov    edx,0x6
    151a:	cmp    rdx,0x6
    151e:	je     152e <botlish_fn_15+0x1ce>
    1524:	mov    eax,0x6
    1529:	jmp    1533 <botlish_fn_15+0x1d3>
    152e:	mov    eax,0x2
    1533:	cmp    rax,0x6
    1537:	je     1545 <botlish_fn_15+0x1e5>
    153d:	mov    r12,r15
    1540:	jmp    1702 <botlish_fn_15+0x3a2>
    1545:	mov    eax,0x2
    154a:	mov    rbx,QWORD PTR [rsp+0x70]
    154f:	mov    r12,QWORD PTR [rsp+0x78]
    1554:	mov    r13,QWORD PTR [rsp+0x80]
    155c:	mov    r14,QWORD PTR [rsp+0x88]
    1564:	mov    r15,QWORD PTR [rsp+0x90]
    156c:	add    rsp,0xa0
    1573:	mov    rsp,rbp
    1576:	pop    rbp
    1577:	ret
    1578:	mov    rsi,QWORD PTR [rsp+0x58]
    157d:	mov    r12,r15
    1580:	mov    rax,rsi
    1583:	and    rax,r12
    1586:	test   rax,0x1
    158c:	jne    15b7 <botlish_fn_15+0x257>
    1592:	mov    rdx,r12
    1595:	mov    rsi,QWORD PTR [rsp+0x58]
    159a:	mov    rdi,rbx
    159d:	call   15a2 <botlish_fn_15+0x242>
			159e: R_X86_64_PLT32	rt_int_cmp-0x4
    15a2:	mov    ecx,0x2
    15a7:	test   rax,rax
    15aa:	cmove  rcx,QWORD PTR [rip+0x266]        # 1818 <botlish_fn_15+0x4b8>
    15b2:	jmp    15cc <botlish_fn_15+0x26c>
    15b7:	mov    ecx,0x2
    15bc:	mov    rsi,QWORD PTR [rsp+0x58]
    15c1:	cmp    rsi,r12
    15c4:	cmove  rcx,QWORD PTR [rip+0x24c]        # 1818 <botlish_fn_15+0x4b8>
    15cc:	cmp    rcx,0x6
    15d0:	je     17e5 <botlish_fn_15+0x485>
    15d6:	mov    QWORD PTR [rsp+0x20],0x3
    15df:	mov    rsi,QWORD PTR [rsp+0x58]
    15e4:	test   rsi,0x1
    15eb:	je     160e <botlish_fn_15+0x2ae>
    15f1:	mov    rsi,QWORD PTR [rsp+0x58]
    15f6:	sub    rsi,0x3
    15fa:	seto   dil
    15fe:	add    rsi,0x1
    1605:	test   dil,dil
    1608:	je     1623 <botlish_fn_15+0x2c3>
    160e:	mov    edx,0x3
    1613:	mov    rsi,QWORD PTR [rsp+0x58]
    1618:	mov    rdi,rbx
    161b:	call   1620 <botlish_fn_15+0x2c0>
			161c: R_X86_64_PLT32	rt_int_sub-0x4
    1620:	mov    rsi,rax
    1623:	mov    QWORD PTR [rsp+0x20],rsi
    1628:	lea    rcx,[rsp+0x38]
    162d:	mov    rdx,r14
    1630:	mov    rdi,rbx
    1633:	call   1638 <botlish_fn_15+0x2d8>
			1634: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    1638:	test   rax,rax
    163b:	mov    rsi,rax
    163e:	je     16c7 <botlish_fn_15+0x367>
    1644:	mov    rdx,QWORD PTR [rsp+0x38]
    1649:	mov    rcx,QWORD PTR [rsp+0x40]
    164e:	mov    rax,QWORD PTR [rbx+0x10]
    1652:	mov    r8,QWORD PTR [rax]
    1655:	mov    rdi,rbx
    1658:	call   165d <botlish_fn_15+0x2fd>
			1659: R_X86_64_PLT32	rt_str_region_eq-0x4
    165d:	cmp    rax,0x6
    1661:	je     17b2 <botlish_fn_15+0x452>
    1667:	mov    QWORD PTR [rsp+0x20],0x3
    1670:	mov    rsi,QWORD PTR [rsp+0x58]
    1675:	test   rsi,0x1
    167c:	je     1696 <botlish_fn_15+0x336>
    1682:	mov    rsi,QWORD PTR [rsp+0x58]
    1687:	add    rsi,0x2
    168b:	seto   al
    168e:	test   al,al
    1690:	je     16ab <botlish_fn_15+0x34b>
    1696:	mov    edx,0x3
    169b:	mov    rsi,QWORD PTR [rsp+0x58]
    16a0:	mov    rdi,rbx
    16a3:	call   16a8 <botlish_fn_15+0x348>
			16a4: R_X86_64_PLT32	rt_int_add-0x4
    16a8:	mov    rsi,rax
    16ab:	mov    QWORD PTR [rsp+0x20],rsi
    16b0:	mov    rcx,r14
    16b3:	mov    rdx,r13
    16b6:	mov    rdi,rbx
    16b9:	call   16be <botlish_fn_15+0x35e>
			16ba: R_X86_64_PLT32	botlish_fn_14-0x4 ; tld?<generic>
    16be:	test   rax,rax
    16c1:	jne    16f8 <botlish_fn_15+0x398>
    16c7:	xor    rax,rax
    16ca:	mov    rbx,QWORD PTR [rsp+0x70]
    16cf:	mov    r12,QWORD PTR [rsp+0x78]
    16d4:	mov    r13,QWORD PTR [rsp+0x80]
    16dc:	mov    r14,QWORD PTR [rsp+0x88]
    16e4:	mov    r15,QWORD PTR [rsp+0x90]
    16ec:	add    rsp,0xa0
    16f3:	mov    rsp,rbp
    16f6:	pop    rbp
    16f7:	ret
    16f8:	cmp    rax,0x6
    16fc:	je     177f <botlish_fn_15+0x41f>
    1702:	mov    edx,0x3
    1707:	mov    QWORD PTR [rsp+0x20],0x3
    1710:	mov    rsi,QWORD PTR [rsp+0x58]
    1715:	test   rsi,0x1
    171c:	jne    172c <botlish_fn_15+0x3cc>
    1722:	mov    rsi,QWORD PTR [rsp+0x58]
    1727:	jmp    175a <botlish_fn_15+0x3fa>
    172c:	mov    rsi,QWORD PTR [rsp+0x58]
    1731:	mov    rax,rsi
    1734:	add    rax,0x2
    1738:	seto   cl
    173b:	test   cl,cl
    173d:	je     174d <botlish_fn_15+0x3ed>
    1743:	mov    rsi,QWORD PTR [rsp+0x58]
    1748:	jmp    175a <botlish_fn_15+0x3fa>
    174d:	mov    rsi,rax
    1750:	mov    QWORD PTR [rsp+0x58],rax
    1755:	jmp    176a <botlish_fn_15+0x40a>
    175a:	mov    rdi,rbx
    175d:	call   1762 <botlish_fn_15+0x402>
			175e: R_X86_64_PLT32	rt_int_add-0x4
    1762:	mov    rsi,rax
    1765:	mov    QWORD PTR [rsp+0x58],rax
    176a:	mov    QWORD PTR [rsp+0x18],rsi
    176f:	mov    rsi,QWORD PTR [rsp+0x58]
    1774:	mov    rdi,rbx
    1777:	mov    r15,r12
    177a:	jmp    13b2 <botlish_fn_15+0x52>
    177f:	mov    eax,0x6
    1784:	mov    rbx,QWORD PTR [rsp+0x70]
    1789:	mov    r12,QWORD PTR [rsp+0x78]
    178e:	mov    r13,QWORD PTR [rsp+0x80]
    1796:	mov    r14,QWORD PTR [rsp+0x88]
    179e:	mov    r15,QWORD PTR [rsp+0x90]
    17a6:	add    rsp,0xa0
    17ad:	mov    rsp,rbp
    17b0:	pop    rbp
    17b1:	ret
    17b2:	mov    eax,0x2
    17b7:	mov    rbx,QWORD PTR [rsp+0x70]
    17bc:	mov    r12,QWORD PTR [rsp+0x78]
    17c1:	mov    r13,QWORD PTR [rsp+0x80]
    17c9:	mov    r14,QWORD PTR [rsp+0x88]
    17d1:	mov    r15,QWORD PTR [rsp+0x90]
    17d9:	add    rsp,0xa0
    17e0:	mov    rsp,rbp
    17e3:	pop    rbp
    17e4:	ret
    17e5:	mov    eax,0x2
    17ea:	mov    rbx,QWORD PTR [rsp+0x70]
    17ef:	mov    r12,QWORD PTR [rsp+0x78]
    17f4:	mov    r13,QWORD PTR [rsp+0x80]
    17fc:	mov    r14,QWORD PTR [rsp+0x88]
    1804:	mov    r15,QWORD PTR [rsp+0x90]
    180c:	add    rsp,0xa0
    1813:	mov    rsp,rbp
    1816:	pop    rbp
    1817:	ret
    1818:	(bad)
    1819:	add    BYTE PTR [rax],al
    181b:	add    BYTE PTR [rax],al
    181d:	add    BYTE PTR [rax],al
	...

0000000000001820 <botlish_entry_15: domain?<generic>>:
    1820:	push   rbp
    1821:	mov    rbp,rsp
    1824:	mov    rsi,QWORD PTR [rdx]
    1827:	mov    r8,QWORD PTR [rdx+0x8]
    182b:	mov    rcx,QWORD PTR [rdx+0x10]
    182f:	mov    rdx,r8
    1832:	call   1837 <botlish_entry_15+0x17>
			1833: R_X86_64_PLT32	botlish_fn_15-0x4 ; domain?<generic>
    1837:	mov    rsp,rbp
    183a:	pop    rbp
    183b:	ret

000000000000183c <botlish_fn_16: web::is_unreserved<int>>:
    183c:	push   rbp
    183d:	mov    rbp,rsp
    1840:	sub    rsp,0x10
    1844:	mov    QWORD PTR [rsp],rbx
    1848:	mov    QWORD PTR [rsp+0x8],r13
    184d:	mov    r13,rsi
    1850:	mov    rbx,rdi
    1853:	mov    rsi,r13
    1856:	call   185b <botlish_fn_16+0x1f>
			1857: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
    185b:	cmp    rax,0x6
    185f:	je     1896 <botlish_fn_16+0x5a>
    1865:	mov    rax,QWORD PTR [rbx+0x30]
    1869:	mov    rsi,QWORD PTR [rax+0x10]
    186d:	mov    rdx,r13
    1870:	mov    rdi,rbx
    1873:	call   1878 <botlish_fn_16+0x3c>
			1874: R_X86_64_PLT32	rt_set_contains-0x4
    1878:	cmp    rax,0x6
    187c:	je     188c <botlish_fn_16+0x50>
    1882:	mov    eax,0x2
    1887:	jmp    189b <botlish_fn_16+0x5f>
    188c:	mov    eax,0x6
    1891:	jmp    189b <botlish_fn_16+0x5f>
    1896:	mov    eax,0x6
    189b:	mov    rbx,QWORD PTR [rsp]
    189f:	mov    r13,QWORD PTR [rsp+0x8]
    18a4:	add    rsp,0x10
    18a8:	mov    rsp,rbp
    18ab:	pop    rbp
    18ac:	ret

00000000000018ad <botlish_entry_16: web::is_unreserved<int>>:
    18ad:	push   rbp
    18ae:	mov    rbp,rsp
    18b1:	mov    rsi,QWORD PTR [rdx]
    18b4:	call   18b9 <botlish_entry_16+0xc>
			18b5: R_X86_64_PLT32	botlish_fn_16-0x4 ; web::is_unreserved<int>
    18b9:	mov    rsp,rbp
    18bc:	pop    rbp
    18bd:	ret

00000000000018be <botlish_fn_17: web::uri_escape_text<str>>:
    18be:	push   rbp
    18bf:	mov    rbp,rsp
    18c2:	sub    rsp,0x20
    18c6:	mov    QWORD PTR [rsp],rsi
    18ca:	mov    edx,0x1
    18cf:	mov    QWORD PTR [rsp+0x8],0x1
    18d8:	mov    r11,QWORD PTR [rdi+0x10]
    18dc:	mov    rcx,QWORD PTR [r11+0xe8]
    18e3:	mov    QWORD PTR [rsp+0x10],rcx
    18e8:	call   18ed <botlish_fn_17+0x2f>
			18e9: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_from<str, int, str>
    18ed:	test   rax,rax
    18f0:	jne    1902 <botlish_fn_17+0x44>
    18f6:	xor    rax,rax
    18f9:	add    rsp,0x20
    18fd:	mov    rsp,rbp
    1900:	pop    rbp
    1901:	ret
    1902:	add    rsp,0x20
    1906:	mov    rsp,rbp
    1909:	pop    rbp
    190a:	ret

000000000000190b <botlish_entry_17: web::uri_escape_text<str>>:
    190b:	push   rbp
    190c:	mov    rbp,rsp
    190f:	mov    rsi,QWORD PTR [rdx]
    1912:	call   1917 <botlish_entry_17+0xc>
			1913: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::uri_escape_text<str>
    1917:	mov    rsp,rbp
    191a:	pop    rbp
    191b:	ret

000000000000191c <botlish_fn_18: high_nibble<int>>:
    191c:	push   rbp
    191d:	mov    rbp,rsp
    1920:	sub    rsp,0x10
    1924:	mov    QWORD PTR [rsp],rsi
    1928:	mov    QWORD PTR [rsp+0x8],0x1e1
    1931:	test   rsi,0x1
    1938:	jne    194d <botlish_fn_18+0x31>
    193e:	mov    edx,0x1e1
    1943:	call   1948 <botlish_fn_18+0x2c>
			1944: R_X86_64_PLT32	rt_int_and-0x4
    1948:	jmp    1957 <botlish_fn_18+0x3b>
    194d:	and    rsi,0x1e1
    1954:	mov    rax,rsi
    1957:	sar    rax,0x5
    195b:	shl    rax,1
    195e:	or     rax,0x1
    1962:	add    rsp,0x10
    1966:	mov    rsp,rbp
    1969:	pop    rbp
    196a:	ret

000000000000196b <botlish_entry_18: high_nibble<int>>:
    196b:	push   rbp
    196c:	mov    rbp,rsp
    196f:	mov    rsi,QWORD PTR [rdx]
    1972:	call   1977 <botlish_entry_18+0xc>
			1973: R_X86_64_PLT32	botlish_fn_18-0x4 ; high_nibble<int>
    1977:	mov    rsp,rbp
    197a:	pop    rbp
    197b:	ret

000000000000197c <botlish_fn_19: hex_pair<int>>:
    197c:	push   rbp
    197d:	mov    rbp,rsp
    1980:	sub    rsp,0x50
    1984:	mov    QWORD PTR [rsp+0x30],rbx
    1989:	mov    QWORD PTR [rsp+0x38],r12
    198e:	mov    QWORD PTR [rsp+0x40],r13
    1993:	mov    QWORD PTR [rsp+0x48],r14
    1998:	mov    QWORD PTR [rsp],rsi
    199c:	mov    r12,rsi
    199f:	mov    rax,QWORD PTR [rdi+0x30]
    19a3:	mov    rbx,rdi
    19a6:	mov    rsi,QWORD PTR [rax+0x8]
    19aa:	mov    QWORD PTR [rsp+0x8],rsi
    19af:	mov    r13,rsi
    19b2:	mov    rsi,r12
    19b5:	call   19ba <botlish_fn_19+0x3e>
			19b6: R_X86_64_PLT32	botlish_fn_18-0x4 ; high_nibble<int>
    19ba:	test   rax,0x1
    19c0:	jne    19d1 <botlish_fn_19+0x55>
    19c6:	mov    rdx,rax
    19c9:	mov    rsi,r13
    19cc:	jmp    19ea <botlish_fn_19+0x6e>
    19d1:	mov    rsi,r13
    19d4:	mov    rdx,QWORD PTR [rsi+0x8]
    19d8:	mov    rcx,rax
    19db:	sar    rcx,1
    19de:	cmp    rcx,rdx
    19e1:	jb     1a00 <botlish_fn_19+0x84>
    19e7:	mov    rdx,rax
    19ea:	mov    rdi,rbx
    19ed:	call   19f2 <botlish_fn_19+0x76>
			19ee: R_X86_64_PLT32	rt_list_get-0x4
    19f2:	test   rax,rax
    19f5:	je     1ac5 <botlish_fn_19+0x149>
    19fb:	jmp    1a08 <botlish_fn_19+0x8c>
    1a00:	mov    rax,QWORD PTR [rsi+0x10]
    1a04:	mov    rax,QWORD PTR [rax+rcx*8]
    1a08:	mov    QWORD PTR [rsp],rax
    1a0c:	mov    rdi,rbx
    1a0f:	mov    r14,rax
    1a12:	mov    rax,QWORD PTR [rdi+0x30]
    1a16:	mov    rsi,QWORD PTR [rax+0x8]
    1a1a:	mov    r13,rsi
    1a1d:	mov    edx,0x21
    1a22:	mov    rsi,r12
    1a25:	call   1a2a <botlish_fn_19+0xae>
			1a26: R_X86_64_PLT32	rt_int_mod-0x4
    1a2a:	test   rax,rax
    1a2d:	je     1ac5 <botlish_fn_19+0x149>
    1a33:	test   rax,0x1
    1a39:	jne    1a4a <botlish_fn_19+0xce>
    1a3f:	mov    rdx,rax
    1a42:	mov    rsi,r13
    1a45:	jmp    1a63 <botlish_fn_19+0xe7>
    1a4a:	mov    rsi,r13
    1a4d:	mov    rdx,QWORD PTR [rsi+0x8]
    1a51:	mov    rcx,rax
    1a54:	sar    rcx,1
    1a57:	cmp    rcx,rdx
    1a5a:	jb     1a79 <botlish_fn_19+0xfd>
    1a60:	mov    rdx,rax
    1a63:	mov    rdi,rbx
    1a66:	call   1a6b <botlish_fn_19+0xef>
			1a67: R_X86_64_PLT32	rt_list_get-0x4
    1a6b:	test   rax,rax
    1a6e:	je     1ac5 <botlish_fn_19+0x149>
    1a74:	jmp    1a81 <botlish_fn_19+0x105>
    1a79:	mov    rax,QWORD PTR [rsi+0x10]
    1a7d:	mov    rax,QWORD PTR [rax+rcx*8]
    1a81:	mov    QWORD PTR [rsp+0x8],rax
    1a86:	lea    rcx,[rsp+0x10]
    1a8b:	mov    QWORD PTR [rsp+0x10],0x0
    1a94:	mov    rdx,r14
    1a97:	mov    QWORD PTR [rsp+0x18],rdx
    1a9c:	mov    QWORD PTR [rsp+0x20],0x0
    1aa5:	mov    QWORD PTR [rsp+0x28],rax
    1aaa:	mov    esi,0x2
    1aaf:	mov    edx,0x4
    1ab4:	mov    rdi,rbx
    1ab7:	call   1abc <botlish_fn_19+0x140>
			1ab8: R_X86_64_PLT32	rt_construct-0x4
    1abc:	test   rax,rax
    1abf:	jne    1ae5 <botlish_fn_19+0x169>
    1ac5:	xor    rax,rax
    1ac8:	mov    rbx,QWORD PTR [rsp+0x30]
    1acd:	mov    r12,QWORD PTR [rsp+0x38]
    1ad2:	mov    r13,QWORD PTR [rsp+0x40]
    1ad7:	mov    r14,QWORD PTR [rsp+0x48]
    1adc:	add    rsp,0x50
    1ae0:	mov    rsp,rbp
    1ae3:	pop    rbp
    1ae4:	ret
    1ae5:	mov    rbx,QWORD PTR [rsp+0x30]
    1aea:	mov    r12,QWORD PTR [rsp+0x38]
    1aef:	mov    r13,QWORD PTR [rsp+0x40]
    1af4:	mov    r14,QWORD PTR [rsp+0x48]
    1af9:	add    rsp,0x50
    1afd:	mov    rsp,rbp
    1b00:	pop    rbp
    1b01:	ret

0000000000001b02 <botlish_entry_19: hex_pair<int>>:
    1b02:	push   rbp
    1b03:	mov    rbp,rsp
    1b06:	sub    rsp,0x10
    1b0a:	mov    QWORD PTR [rsp],r12
    1b0e:	mov    r12,rdi
    1b11:	mov    rsi,QWORD PTR [rdx]
    1b14:	call   1b19 <botlish_entry_19+0x17>
			1b15: R_X86_64_PLT32	botlish_fn_19-0x4 ; hex_pair<int>
    1b19:	mov    r8,QWORD PTR [rip+0x0]        # 1b20 <botlish_entry_19+0x1e>
			1b1c: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1b20:	mov    rsi,rax
    1b23:	mov    rdi,r12
    1b26:	call   r8
    1b29:	mov    r12,QWORD PTR [rsp]
    1b2d:	add    rsp,0x10
    1b31:	mov    rsp,rbp
    1b34:	pop    rbp
    1b35:	ret

0000000000001b36 <botlish_fn_20: esc_bytes<List[int], int, str>>:
    1b36:	push   rbp
    1b37:	mov    rbp,rsp
    1b3a:	sub    rsp,0x90
    1b41:	mov    QWORD PTR [rsp+0x60],rbx
    1b46:	mov    QWORD PTR [rsp+0x68],r12
    1b4b:	mov    QWORD PTR [rsp+0x70],r13
    1b50:	mov    QWORD PTR [rsp+0x78],r14
    1b55:	mov    QWORD PTR [rsp+0x80],r15
    1b5d:	mov    QWORD PTR [rsp],rsi
    1b61:	mov    QWORD PTR [rsp+0x8],rcx
    1b66:	sar    rdx,1
    1b69:	mov    r13,rdx
    1b6c:	lea    r14,[rsp+0x20]
    1b71:	mov    rbx,rdi
    1b74:	mov    r12,rsi
    1b77:	mov    QWORD PTR [rsp+0x50],rcx
    1b7c:	mov    rsi,r12
    1b7f:	mov    rdi,rbx
    1b82:	call   1b87 <botlish_fn_20+0x51>
			1b83: R_X86_64_PLT32	rt_list_len-0x4
    1b87:	sar    rax,1
    1b8a:	cmp    r13,rax
    1b8d:	jge    1c9d <botlish_fn_20+0x167>
    1b93:	mov    rax,QWORD PTR [rbx+0x10]
    1b97:	mov    r15,QWORD PTR [rax+0x10]
    1b9b:	mov    QWORD PTR [rsp+0x10],r15
    1ba0:	mov    rcx,QWORD PTR [r12+0x8]
    1ba5:	mov    rax,r13
    1ba8:	shl    rax,1
    1bab:	or     rax,0x1
    1baf:	sar    rax,1
    1bb2:	cmp    rax,rcx
    1bb5:	jb     1be1 <botlish_fn_20+0xab>
    1bbb:	mov    rdx,r13
    1bbe:	shl    rdx,1
    1bc1:	or     rdx,0x1
    1bc5:	mov    rsi,r12
    1bc8:	mov    rdi,rbx
    1bcb:	call   1bd0 <botlish_fn_20+0x9a>
			1bcc: R_X86_64_PLT32	rt_list_get-0x4
    1bd0:	test   rax,rax
    1bd3:	je     1c58 <botlish_fn_20+0x122>
    1bd9:	mov    rsi,rax
    1bdc:	jmp    1bea <botlish_fn_20+0xb4>
    1be1:	mov    rcx,QWORD PTR [r12+0x10]
    1be6:	mov    rsi,QWORD PTR [rcx+rax*8]
    1bea:	mov    QWORD PTR [rsp+0x18],rsi
    1bef:	mov    rdi,rbx
    1bf2:	call   1bf7 <botlish_fn_20+0xc1>
			1bf3: R_X86_64_PLT32	botlish_fn_19-0x4 ; hex_pair<int>
    1bf7:	test   rax,rax
    1bfa:	je     1c58 <botlish_fn_20+0x122>
    1c00:	mov    QWORD PTR [rsp+0x18],rax
    1c05:	mov    rcx,rax
    1c08:	mov    QWORD PTR [rsp+0x20],0x0
    1c11:	mov    rax,QWORD PTR [rsp+0x50]
    1c16:	mov    QWORD PTR [rsp+0x28],rax
    1c1b:	mov    QWORD PTR [rsp+0x30],0x0
    1c24:	mov    QWORD PTR [rsp+0x38],r15
    1c29:	mov    QWORD PTR [rsp+0x40],0x0
    1c32:	mov    rax,rcx
    1c35:	mov    QWORD PTR [rsp+0x48],rax
    1c3a:	mov    esi,0x2
    1c3f:	mov    edx,0x6
    1c44:	mov    rcx,r14
    1c47:	mov    rdi,rbx
    1c4a:	call   1c4f <botlish_fn_20+0x119>
			1c4b: R_X86_64_PLT32	rt_construct-0x4
    1c4f:	test   rax,rax
    1c52:	jne    1c83 <botlish_fn_20+0x14d>
    1c58:	xor    rax,rax
    1c5b:	mov    rbx,QWORD PTR [rsp+0x60]
    1c60:	mov    r12,QWORD PTR [rsp+0x68]
    1c65:	mov    r13,QWORD PTR [rsp+0x70]
    1c6a:	mov    r14,QWORD PTR [rsp+0x78]
    1c6f:	mov    r15,QWORD PTR [rsp+0x80]
    1c77:	add    rsp,0x90
    1c7e:	mov    rsp,rbp
    1c81:	pop    rbp
    1c82:	ret
    1c83:	mov    QWORD PTR [rsp],r12
    1c87:	mov    QWORD PTR [rsp+0x8],rax
    1c8c:	add    r13,0x1
    1c93:	mov    QWORD PTR [rsp+0x50],rax
    1c98:	jmp    1b7c <botlish_fn_20+0x46>
    1c9d:	mov    rax,QWORD PTR [rsp+0x50]
    1ca2:	mov    rbx,QWORD PTR [rsp+0x60]
    1ca7:	mov    r12,QWORD PTR [rsp+0x68]
    1cac:	mov    r13,QWORD PTR [rsp+0x70]
    1cb1:	mov    r14,QWORD PTR [rsp+0x78]
    1cb6:	mov    r15,QWORD PTR [rsp+0x80]
    1cbe:	add    rsp,0x90
    1cc5:	mov    rsp,rbp
    1cc8:	pop    rbp
    1cc9:	ret

0000000000001cca <botlish_entry_20: esc_bytes<List[int], int, str>>:
    1cca:	push   rbp
    1ccb:	mov    rbp,rsp
    1cce:	sub    rsp,0x10
    1cd2:	mov    QWORD PTR [rsp],r12
    1cd6:	mov    r12,rdi
    1cd9:	mov    rsi,QWORD PTR [rdx]
    1cdc:	mov    r8,QWORD PTR [rdx+0x8]
    1ce0:	mov    rcx,QWORD PTR [rdx+0x10]
    1ce4:	mov    rdx,r8
    1ce7:	call   1cec <botlish_entry_20+0x22>
			1ce8: R_X86_64_PLT32	botlish_fn_20-0x4 ; esc_bytes<List[int], int, str>
    1cec:	mov    r8,QWORD PTR [rip+0x0]        # 1cf3 <botlish_entry_20+0x29>
			1cef: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1cf3:	mov    rsi,rax
    1cf6:	mov    rdi,r12
    1cf9:	call   r8
    1cfc:	mov    r12,QWORD PTR [rsp]
    1d00:	add    rsp,0x10
    1d04:	mov    rsp,rbp
    1d07:	pop    rbp
    1d08:	ret

0000000000001d09 <botlish_fn_21: esc_char<str>>:
    1d09:	push   rbp
    1d0a:	mov    rbp,rsp
    1d0d:	sub    rsp,0x40
    1d11:	mov    QWORD PTR [rsp+0x20],rbx
    1d16:	mov    QWORD PTR [rsp+0x28],r12
    1d1b:	mov    QWORD PTR [rsp+0x30],r13
    1d20:	mov    rbx,rdi
    1d23:	mov    QWORD PTR [rsp+0x8],0x0
    1d2c:	mov    QWORD PTR [rsp+0x10],0x0
    1d35:	mov    QWORD PTR [rsp],rsi
    1d39:	mov    r13,rsi
    1d3c:	mov    rsi,r13
    1d3f:	mov    rdi,rbx
    1d42:	call   1d47 <botlish_fn_21+0x3e>
			1d43: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1d47:	mov    rcx,rax
    1d4a:	mov    r12,rax
    1d4d:	test   rax,rcx
    1d50:	je     1e2e <botlish_fn_21+0x125>
    1d56:	mov    rax,r12
    1d59:	mov    QWORD PTR [rsp],rax
    1d5d:	mov    rsi,r12
    1d60:	mov    rdi,rbx
    1d63:	call   1d68 <botlish_fn_21+0x5f>
			1d64: R_X86_64_PLT32	rt_list_len-0x4
    1d68:	sar    rax,1
    1d6b:	cmp    rax,0x1
    1d6f:	je     1dac <botlish_fn_21+0xa3>
    1d75:	mov    edx,0x1
    1d7a:	mov    QWORD PTR [rsp+0x8],0x1
    1d83:	mov    rdi,rbx
    1d86:	mov    rax,QWORD PTR [rdi+0x10]
    1d8a:	mov    rcx,QWORD PTR [rax+0xe8]
    1d91:	mov    QWORD PTR [rsp+0x10],rcx
    1d96:	mov    rsi,r12
    1d99:	call   1d9e <botlish_fn_21+0x95>
			1d9a: R_X86_64_PLT32	botlish_fn_20-0x4 ; esc_bytes<List[int], int, str>
    1d9e:	test   rax,rax
    1da1:	je     1e2e <botlish_fn_21+0x125>
    1da7:	jmp    1e4f <botlish_fn_21+0x146>
    1dac:	mov    rsi,r12
    1daf:	mov    rax,QWORD PTR [rsi+0x8]
    1db3:	mov    r12,rsi
    1db6:	test   rax,rax
    1db9:	jne    1de0 <botlish_fn_21+0xd7>
    1dbf:	mov    edx,0x1
    1dc4:	mov    rsi,r12
    1dc7:	mov    rdi,rbx
    1dca:	call   1dcf <botlish_fn_21+0xc6>
			1dcb: R_X86_64_PLT32	rt_list_get-0x4
    1dcf:	test   rax,rax
    1dd2:	je     1e2e <botlish_fn_21+0x125>
    1dd8:	mov    rsi,rax
    1ddb:	jmp    1dea <botlish_fn_21+0xe1>
    1de0:	mov    rsi,r12
    1de3:	mov    rax,QWORD PTR [rsi+0x10]
    1de7:	mov    rsi,QWORD PTR [rax]
    1dea:	mov    rdi,rbx
    1ded:	call   1df2 <botlish_fn_21+0xe9>
			1dee: R_X86_64_PLT32	botlish_fn_16-0x4 ; web::is_unreserved<int>
    1df2:	cmp    rax,0x6
    1df6:	je     1e4c <botlish_fn_21+0x143>
    1dfc:	mov    edx,0x1
    1e01:	mov    QWORD PTR [rsp+0x8],0x1
    1e0a:	mov    rdi,rbx
    1e0d:	mov    rax,QWORD PTR [rdi+0x10]
    1e11:	mov    rcx,QWORD PTR [rax+0xe8]
    1e18:	mov    QWORD PTR [rsp+0x10],rcx
    1e1d:	mov    rsi,r12
    1e20:	call   1e25 <botlish_fn_21+0x11c>
			1e21: R_X86_64_PLT32	botlish_fn_20-0x4 ; esc_bytes<List[int], int, str>
    1e25:	test   rax,rax
    1e28:	jne    1e49 <botlish_fn_21+0x140>
    1e2e:	xor    rax,rax
    1e31:	mov    rbx,QWORD PTR [rsp+0x20]
    1e36:	mov    r12,QWORD PTR [rsp+0x28]
    1e3b:	mov    r13,QWORD PTR [rsp+0x30]
    1e40:	add    rsp,0x40
    1e44:	mov    rsp,rbp
    1e47:	pop    rbp
    1e48:	ret
    1e49:	mov    r13,rax
    1e4c:	mov    rax,r13
    1e4f:	mov    rbx,QWORD PTR [rsp+0x20]
    1e54:	mov    r12,QWORD PTR [rsp+0x28]
    1e59:	mov    r13,QWORD PTR [rsp+0x30]
    1e5e:	add    rsp,0x40
    1e62:	mov    rsp,rbp
    1e65:	pop    rbp
    1e66:	ret

0000000000001e67 <botlish_entry_21: esc_char<str>>:
    1e67:	push   rbp
    1e68:	mov    rbp,rsp
    1e6b:	sub    rsp,0x10
    1e6f:	mov    QWORD PTR [rsp],r12
    1e73:	mov    r12,rdi
    1e76:	mov    rsi,QWORD PTR [rdx]
    1e79:	call   1e7e <botlish_entry_21+0x17>
			1e7a: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_char<str>
    1e7e:	mov    r8,QWORD PTR [rip+0x0]        # 1e85 <botlish_entry_21+0x1e>
			1e81: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1e85:	mov    rsi,rax
    1e88:	mov    rdi,r12
    1e8b:	call   r8
    1e8e:	mov    r12,QWORD PTR [rsp]
    1e92:	add    rsp,0x10
    1e96:	mov    rsp,rbp
    1e99:	pop    rbp
    1e9a:	ret

0000000000001e9b <botlish_fn_22: esc_from<str, int, str>>:
    1e9b:	push   rbp
    1e9c:	mov    rbp,rsp
    1e9f:	sub    rsp,0x80
    1ea6:	mov    QWORD PTR [rsp+0x50],rbx
    1eab:	mov    QWORD PTR [rsp+0x58],r12
    1eb0:	mov    QWORD PTR [rsp+0x60],r13
    1eb5:	mov    QWORD PTR [rsp+0x68],r14
    1eba:	mov    QWORD PTR [rsp+0x70],r15
    1ebf:	mov    r14,rdi
    1ec2:	mov    QWORD PTR [rsp+0x10],0x0
    1ecb:	mov    QWORD PTR [rsp+0x18],0x0
    1ed4:	mov    QWORD PTR [rsp],rsi
    1ed8:	mov    QWORD PTR [rsp+0x8],rcx
    1edd:	mov    r15,rcx
    1ee0:	sar    rdx,1
    1ee3:	mov    r12,rdx
    1ee6:	lea    r13,[rsp+0x30]
    1eeb:	mov    rbx,rsi
    1eee:	mov    rsi,rbx
    1ef1:	mov    rdi,r14
    1ef4:	call   1ef9 <botlish_fn_22+0x5e>
			1ef5: R_X86_64_PLT32	rt_str_len-0x4
    1ef9:	sar    rax,1
    1efc:	cmp    r12,rax
    1eff:	jge    1faa <botlish_fn_22+0x10f>
    1f05:	mov    rdx,r12
    1f08:	shl    rdx,1
    1f0b:	or     rdx,0x1
    1f0f:	mov    QWORD PTR [rsp+0x10],rdx
    1f14:	add    r12,0x1
    1f1b:	mov    rcx,r12
    1f1e:	shl    rcx,1
    1f21:	or     rcx,0x1
    1f25:	mov    QWORD PTR [rsp+0x18],rcx
    1f2a:	mov    rsi,rbx
    1f2d:	mov    rdi,r14
    1f30:	call   1f35 <botlish_fn_22+0x9a>
			1f31: R_X86_64_PLT32	rt_substr-0x4
    1f35:	test   rax,rax
    1f38:	je     1fdc <botlish_fn_22+0x141>
    1f3e:	mov    QWORD PTR [rsp+0x10],rax
    1f43:	mov    rsi,rax
    1f46:	mov    rdi,r14
    1f49:	call   1f4e <botlish_fn_22+0xb3>
			1f4a: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_char<str>
    1f4e:	test   rax,rax
    1f51:	je     1fdc <botlish_fn_22+0x141>
    1f57:	mov    QWORD PTR [rsp+0x10],rax
    1f5c:	mov    QWORD PTR [rsp+0x30],0x0
    1f65:	mov    rcx,r15
    1f68:	mov    QWORD PTR [rsp+0x38],rcx
    1f6d:	mov    QWORD PTR [rsp+0x40],0x0
    1f76:	mov    QWORD PTR [rsp+0x48],rax
    1f7b:	mov    esi,0x2
    1f80:	mov    edx,0x4
    1f85:	mov    rcx,r13
    1f88:	mov    rdi,r14
    1f8b:	call   1f90 <botlish_fn_22+0xf5>
			1f8c: R_X86_64_PLT32	rt_construct-0x4
    1f90:	test   rax,rax
    1f93:	je     1fdc <botlish_fn_22+0x141>
    1f99:	mov    QWORD PTR [rsp],rbx
    1f9d:	mov    QWORD PTR [rsp+0x8],rax
    1fa2:	mov    r15,rax
    1fa5:	jmp    1eee <botlish_fn_22+0x53>
    1faa:	mov    rcx,r15
    1fad:	xor    rsi,rsi
    1fb0:	lea    rax,[rsp+0x20]
    1fb5:	mov    QWORD PTR [rsp+0x20],0x0
    1fbe:	mov    QWORD PTR [rsp+0x28],rcx
    1fc3:	mov    edx,0x2
    1fc8:	mov    rcx,rax
    1fcb:	mov    rdi,r14
    1fce:	call   1fd3 <botlish_fn_22+0x138>
			1fcf: R_X86_64_PLT32	rt_construct-0x4
    1fd3:	test   rax,rax
    1fd6:	jne    2004 <botlish_fn_22+0x169>
    1fdc:	xor    rax,rax
    1fdf:	mov    rbx,QWORD PTR [rsp+0x50]
    1fe4:	mov    r12,QWORD PTR [rsp+0x58]
    1fe9:	mov    r13,QWORD PTR [rsp+0x60]
    1fee:	mov    r14,QWORD PTR [rsp+0x68]
    1ff3:	mov    r15,QWORD PTR [rsp+0x70]
    1ff8:	add    rsp,0x80
    1fff:	mov    rsp,rbp
    2002:	pop    rbp
    2003:	ret
    2004:	mov    rbx,QWORD PTR [rsp+0x50]
    2009:	mov    r12,QWORD PTR [rsp+0x58]
    200e:	mov    r13,QWORD PTR [rsp+0x60]
    2013:	mov    r14,QWORD PTR [rsp+0x68]
    2018:	mov    r15,QWORD PTR [rsp+0x70]
    201d:	add    rsp,0x80
    2024:	mov    rsp,rbp
    2027:	pop    rbp
    2028:	ret

0000000000002029 <botlish_entry_22: esc_from<str, int, str>>:
    2029:	push   rbp
    202a:	mov    rbp,rsp
    202d:	mov    rsi,QWORD PTR [rdx]
    2030:	mov    r8,QWORD PTR [rdx+0x8]
    2034:	mov    rcx,QWORD PTR [rdx+0x10]
    2038:	mov    rdx,r8
    203b:	call   2040 <botlish_entry_22+0x17>
			203c: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_from<str, int, str>
    2040:	mov    rsp,rbp
    2043:	pop    rbp
    2044:	ret

0000000000002045 <botlish_fn_23: check<int, int, str, str>>:
    2045:	push   rbp
    2046:	mov    rbp,rsp
    2049:	sub    rsp,0x50
    204d:	mov    QWORD PTR [rsp+0x20],rbx
    2052:	mov    QWORD PTR [rsp+0x28],r12
    2057:	mov    QWORD PTR [rsp+0x30],r13
    205c:	mov    QWORD PTR [rsp+0x38],r14
    2061:	mov    QWORD PTR [rsp+0x40],r15
    2066:	mov    r14,rdi
    2069:	mov    QWORD PTR [rsp+0x18],0x0
    2072:	mov    QWORD PTR [rsp],rdx
    2076:	mov    QWORD PTR [rsp+0x8],rcx
    207b:	mov    QWORD PTR [rsp+0x10],r8
    2080:	mov    r13,r8
    2083:	sar    rsi,1
    2086:	mov    r12,rsi
    2089:	mov    r15,rdx
    208c:	test   r12,r12
    208f:	jle    2151 <botlish_fn_23+0x10c>
    2095:	mov    rbx,rcx
    2098:	mov    rsi,rbx
    209b:	mov    rdi,r14
    209e:	call   20a3 <botlish_fn_23+0x5e>
			209f: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
    20a3:	test   rax,rax
    20a6:	jne    20d1 <botlish_fn_23+0x8c>
    20ac:	xor    rax,rax
    20af:	mov    rbx,QWORD PTR [rsp+0x20]
    20b4:	mov    r12,QWORD PTR [rsp+0x28]
    20b9:	mov    r13,QWORD PTR [rsp+0x30]
    20be:	mov    r14,QWORD PTR [rsp+0x38]
    20c3:	mov    r15,QWORD PTR [rsp+0x40]
    20c8:	add    rsp,0x50
    20cc:	mov    rsp,rbp
    20cf:	pop    rbp
    20d0:	ret
    20d1:	cmp    rax,0x6
    20d5:	je     20f1 <botlish_fn_23+0xac>
    20db:	mov    edx,0x1
    20e0:	mov    QWORD PTR [rsp+0x18],0x1
    20e9:	mov    rsi,r15
    20ec:	jmp    2102 <botlish_fn_23+0xbd>
    20f1:	mov    edx,0x3
    20f6:	mov    QWORD PTR [rsp+0x18],0x3
    20ff:	mov    rsi,r15
    2102:	mov    rax,rsi
    2105:	and    rax,rdx
    2108:	test   rax,0x1
    210e:	je     2129 <botlish_fn_23+0xe4>
    2114:	lea    rcx,[rdx-0x1]
    2118:	mov    rax,rsi
    211b:	add    rax,rcx
    211e:	seto   cl
    2121:	test   cl,cl
    2123:	je     2131 <botlish_fn_23+0xec>
    2129:	mov    rdi,r14
    212c:	call   2131 <botlish_fn_23+0xec>
			212d: R_X86_64_PLT32	rt_int_add-0x4
    2131:	mov    QWORD PTR [rsp],rax
    2135:	mov    QWORD PTR [rsp+0x8],rbx
    213a:	mov    r8,r13
    213d:	mov    QWORD PTR [rsp+0x10],r8
    2142:	sub    r12,0x1
    2146:	mov    rcx,rbx
    2149:	mov    r15,rax
    214c:	jmp    208c <botlish_fn_23+0x47>
    2151:	mov    rax,r15
    2154:	mov    rbx,QWORD PTR [rsp+0x20]
    2159:	mov    r12,QWORD PTR [rsp+0x28]
    215e:	mov    r13,QWORD PTR [rsp+0x30]
    2163:	mov    r14,QWORD PTR [rsp+0x38]
    2168:	mov    r15,QWORD PTR [rsp+0x40]
    216d:	add    rsp,0x50
    2171:	mov    rsp,rbp
    2174:	pop    rbp
    2175:	ret

0000000000002176 <botlish_entry_23: check<int, int, str, str>>:
    2176:	push   rbp
    2177:	mov    rbp,rsp
    217a:	mov    rsi,QWORD PTR [rdx]
    217d:	mov    r9,QWORD PTR [rdx+0x8]
    2181:	mov    rcx,QWORD PTR [rdx+0x10]
    2185:	mov    r8,QWORD PTR [rdx+0x18]
    2189:	mov    rdx,r9
    218c:	call   2191 <botlish_entry_23+0x1b>
			218d: R_X86_64_PLT32	botlish_fn_23-0x4 ; check<int, int, str, str>
    2191:	mov    rsp,rbp
    2194:	pop    rbp
    2195:	ret

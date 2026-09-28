; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 8935  (per function: 1443 39 289 609 74 74 74 125 125 601 262 222 238 528 468 1244 137 94 103 474 491 426 451 344)
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
    1022:	cmovl  rcx,QWORD PTR [rip+0x146]        # 1170 <botlish_fn_13+0x1c8>
    102a:	jmp    1045 <botlish_fn_13+0x9d>
    102f:	mov    ecx,0x2
    1034:	mov    rax,r15
    1037:	mov    rdx,rbx
    103a:	cmp    rax,rdx
    103d:	cmovl  rcx,QWORD PTR [rip+0x12b]        # 1170 <botlish_fn_13+0x1c8>
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
    1085:	je     10cf <botlish_fn_13+0x127>
    108b:	mov    QWORD PTR [rsp+0x20],rax
    1090:	lea    rcx,[rsp+0x28]
    1095:	mov    QWORD PTR [rsp+0x28],rax
    109a:	mov    edx,0x1
    109f:	mov    rsi,r13
    10a2:	mov    rdi,r14
    10a5:	call   10aa <botlish_fn_13+0x102>
			10a6: R_X86_64_PLT32	rt_call_value-0x4
    10aa:	test   rax,rax
    10ad:	je     10cf <botlish_fn_13+0x127>
    10b3:	mov    rcx,rax
    10b6:	or     rcx,0x4
    10ba:	mov    rsi,rax
    10bd:	cmp    rcx,0x6
    10c1:	je     10f4 <botlish_fn_13+0x14c>
    10c7:	mov    rdi,r14
    10ca:	call   10cf <botlish_fn_13+0x127>
			10cb: R_X86_64_PLT32	rt_not_boolean-0x4
    10cf:	xor    rax,rax
    10d2:	mov    rbx,QWORD PTR [rsp+0x30]
    10d7:	mov    r12,QWORD PTR [rsp+0x38]
    10dc:	mov    r13,QWORD PTR [rsp+0x40]
    10e1:	mov    r14,QWORD PTR [rsp+0x48]
    10e6:	mov    r15,QWORD PTR [rsp+0x50]
    10eb:	add    rsp,0x60
    10ef:	mov    rsp,rbp
    10f2:	pop    rbp
    10f3:	ret
    10f4:	cmp    rsi,0x6
    10f8:	je     1123 <botlish_fn_13+0x17b>
    10fe:	mov    rax,r15
    1101:	mov    rbx,QWORD PTR [rsp+0x30]
    1106:	mov    r12,QWORD PTR [rsp+0x38]
    110b:	mov    r13,QWORD PTR [rsp+0x40]
    1110:	mov    r14,QWORD PTR [rsp+0x48]
    1115:	mov    r15,QWORD PTR [rsp+0x50]
    111a:	add    rsp,0x60
    111e:	mov    rsp,rbp
    1121:	pop    rbp
    1122:	ret
    1123:	mov    QWORD PTR [rsp+0x20],0x3
    112c:	mov    rax,r15
    112f:	test   rax,0x1
    1135:	je     1150 <botlish_fn_13+0x1a8>
    113b:	mov    rcx,r15
    113e:	mov    rax,rcx
    1141:	add    rax,0x2
    1145:	seto   dl
    1148:	test   dl,dl
    114a:	je     1160 <botlish_fn_13+0x1b8>
    1150:	mov    edx,0x3
    1155:	mov    rsi,r15
    1158:	mov    rdi,r14
    115b:	call   1160 <botlish_fn_13+0x1b8>
			115c: R_X86_64_PLT32	rt_int_add-0x4
    1160:	mov    QWORD PTR [rsp+0x18],rax
    1165:	mov    rcx,rbx
    1168:	mov    r15,rax
    116b:	jmp    ffa <botlish_fn_13+0x52>
    1170:	(bad)
    1171:	add    BYTE PTR [rax],al
    1173:	add    BYTE PTR [rax],al
    1175:	add    BYTE PTR [rax],al
	...

0000000000001178 <botlish_entry_13: scan_while<generic>>:
    1178:	push   rbp
    1179:	mov    rbp,rsp
    117c:	mov    rsi,QWORD PTR [rdx]
    117f:	mov    r9,QWORD PTR [rdx+0x8]
    1183:	mov    rcx,QWORD PTR [rdx+0x10]
    1187:	mov    r8,QWORD PTR [rdx+0x18]
    118b:	mov    rdx,r9
    118e:	call   1193 <botlish_entry_13+0x1b>
			118f: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<generic>
    1193:	mov    rsp,rbp
    1196:	pop    rbp
    1197:	ret

0000000000001198 <botlish_fn_14: tld?<generic>>:
    1198:	push   rbp
    1199:	mov    rbp,rsp
    119c:	sub    rsp,0x40
    11a0:	mov    QWORD PTR [rsp+0x20],rbx
    11a5:	mov    QWORD PTR [rsp+0x28],r12
    11aa:	mov    QWORD PTR [rsp+0x30],r13
    11af:	mov    QWORD PTR [rsp+0x38],r14
    11b4:	mov    QWORD PTR [rsp],rsi
    11b8:	mov    r8,rsi
    11bb:	mov    QWORD PTR [rsp+0x8],rdx
    11c0:	mov    r14,rdx
    11c3:	mov    QWORD PTR [rsp+0x10],rcx
    11c8:	mov    rax,QWORD PTR [rdi+0x10]
    11cc:	mov    r12,rdi
    11cf:	mov    rdx,QWORD PTR [rax+0xe0]
    11d6:	mov    QWORD PTR [rsp+0x18],rdx
    11db:	mov    rbx,r8
    11de:	mov    r8,rcx
    11e1:	mov    rcx,r14
    11e4:	mov    rsi,rbx
    11e7:	call   11ec <botlish_fn_14+0x54>
			11e8: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<generic>
    11ec:	mov    rcx,rax
    11ef:	mov    r13,rax
    11f2:	test   rax,rcx
    11f5:	jne    121b <botlish_fn_14+0x83>
    11fb:	xor    rax,rax
    11fe:	mov    rbx,QWORD PTR [rsp+0x20]
    1203:	mov    r12,QWORD PTR [rsp+0x28]
    1208:	mov    r13,QWORD PTR [rsp+0x30]
    120d:	mov    r14,QWORD PTR [rsp+0x38]
    1212:	add    rsp,0x40
    1216:	mov    rsp,rbp
    1219:	pop    rbp
    121a:	ret
    121b:	mov    rax,r13
    121e:	mov    QWORD PTR [rsp+0x8],rax
    1223:	mov    rdx,r14
    1226:	and    rax,rdx
    1229:	test   rax,0x1
    122f:	jne    1258 <botlish_fn_14+0xc0>
    1235:	mov    rsi,r13
    1238:	mov    rdi,r12
    123b:	call   1240 <botlish_fn_14+0xa8>
			123c: R_X86_64_PLT32	rt_int_cmp-0x4
    1240:	mov    ecx,0x2
    1245:	test   rax,rax
    1248:	cmove  rcx,QWORD PTR [rip+0xe0]        # 1330 <botlish_fn_14+0x198>
    1250:	mov    rax,r13
    1253:	jmp    126b <botlish_fn_14+0xd3>
    1258:	mov    ecx,0x2
    125d:	mov    rax,r13
    1260:	cmp    rax,rdx
    1263:	cmove  rcx,QWORD PTR [rip+0xc5]        # 1330 <botlish_fn_14+0x198>
    126b:	cmp    rcx,0x6
    126f:	je     1282 <botlish_fn_14+0xea>
    1275:	mov    ecx,0x2
    127a:	mov    rax,rcx
    127d:	jmp    130f <botlish_fn_14+0x177>
    1282:	mov    rcx,rax
    1285:	and    rcx,rbx
    1288:	test   rcx,0x1
    128f:	jne    12a0 <botlish_fn_14+0x108>
    1295:	mov    rdx,rbx
    1298:	mov    rsi,rax
    129b:	jmp    12c1 <botlish_fn_14+0x129>
    12a0:	mov    rcx,rax
    12a3:	sub    rcx,rbx
    12a6:	mov    r8,rbx
    12a9:	mov    r13,rax
    12ac:	seto   al
    12af:	lea    rsi,[rcx+0x1]
    12b3:	test   al,al
    12b5:	je     12cc <botlish_fn_14+0x134>
    12bb:	mov    rdx,r8
    12be:	mov    rsi,r13
    12c1:	mov    rdi,r12
    12c4:	call   12c9 <botlish_fn_14+0x131>
			12c5: R_X86_64_PLT32	rt_int_sub-0x4
    12c9:	mov    rsi,rax
    12cc:	test   rsi,0x1
    12d3:	jne    12fe <botlish_fn_14+0x166>
    12d9:	mov    edx,0x5
    12de:	mov    rdi,r12
    12e1:	call   12e6 <botlish_fn_14+0x14e>
			12e2: R_X86_64_PLT32	rt_int_cmp-0x4
    12e6:	mov    ecx,0x2
    12eb:	test   rax,rax
    12ee:	mov    rax,rcx
    12f1:	cmovge rax,QWORD PTR [rip+0x37]        # 1330 <botlish_fn_14+0x198>
    12f9:	jmp    130f <botlish_fn_14+0x177>
    12fe:	mov    eax,0x2
    1303:	cmp    rsi,0x5
    1307:	cmovge rax,QWORD PTR [rip+0x21]        # 1330 <botlish_fn_14+0x198>
    130f:	mov    rbx,QWORD PTR [rsp+0x20]
    1314:	mov    r12,QWORD PTR [rsp+0x28]
    1319:	mov    r13,QWORD PTR [rsp+0x30]
    131e:	mov    r14,QWORD PTR [rsp+0x38]
    1323:	add    rsp,0x40
    1327:	mov    rsp,rbp
    132a:	pop    rbp
    132b:	ret
    132c:	add    BYTE PTR [rax],al
    132e:	add    BYTE PTR [rax],al
    1330:	(bad)
    1331:	add    BYTE PTR [rax],al
    1333:	add    BYTE PTR [rax],al
    1335:	add    BYTE PTR [rax],al
	...

0000000000001338 <botlish_entry_14: tld?<generic>>:
    1338:	push   rbp
    1339:	mov    rbp,rsp
    133c:	mov    rsi,QWORD PTR [rdx]
    133f:	mov    r8,QWORD PTR [rdx+0x8]
    1343:	mov    rcx,QWORD PTR [rdx+0x10]
    1347:	mov    rdx,r8
    134a:	call   134f <botlish_entry_14+0x17>
			134b: R_X86_64_PLT32	botlish_fn_14-0x4 ; tld?<generic>
    134f:	mov    rsp,rbp
    1352:	pop    rbp
    1353:	ret
    1354:	add    BYTE PTR [rax],al
	...

0000000000001358 <botlish_fn_15: domain?<generic>>:
    1358:	push   rbp
    1359:	mov    rbp,rsp
    135c:	sub    rsp,0xa0
    1363:	mov    QWORD PTR [rsp+0x70],rbx
    1368:	mov    QWORD PTR [rsp+0x78],r12
    136d:	mov    QWORD PTR [rsp+0x80],r13
    1375:	mov    QWORD PTR [rsp+0x88],r14
    137d:	mov    QWORD PTR [rsp+0x90],r15
    1385:	mov    QWORD PTR [rsp+0x20],0x0
    138e:	mov    QWORD PTR [rsp],rsi
    1392:	mov    QWORD PTR [rsp+0x8],rdx
    1397:	mov    QWORD PTR [rsp+0x10],rcx
    139c:	mov    r14,rcx
    139f:	mov    QWORD PTR [rsp+0x18],rsi
    13a4:	mov    r15,rsi
    13a7:	mov    r13,rdx
    13aa:	mov    rax,rsi
    13ad:	and    rax,r13
    13b0:	mov    QWORD PTR [rsp+0x58],rsi
    13b5:	test   rax,0x1
    13bb:	jne    13e6 <botlish_fn_15+0x8e>
    13c1:	mov    rbx,rdi
    13c4:	mov    rdx,r13
    13c7:	mov    rsi,QWORD PTR [rsp+0x58]
    13cc:	call   13d1 <botlish_fn_15+0x79>
			13cd: R_X86_64_PLT32	rt_int_cmp-0x4
    13d1:	mov    ecx,0x2
    13d6:	test   rax,rax
    13d9:	cmovl  rcx,QWORD PTR [rip+0x42f]        # 1810 <botlish_fn_15+0x4b8>
    13e1:	jmp    13fe <botlish_fn_15+0xa6>
    13e6:	mov    rbx,rdi
    13e9:	mov    ecx,0x2
    13ee:	mov    rsi,QWORD PTR [rsp+0x58]
    13f3:	cmp    rsi,r13
    13f6:	cmovl  rcx,QWORD PTR [rip+0x412]        # 1810 <botlish_fn_15+0x4b8>
    13fe:	cmp    rcx,0x6
    1402:	je     143b <botlish_fn_15+0xe3>
    1408:	mov    eax,0x2
    140d:	mov    rbx,QWORD PTR [rsp+0x70]
    1412:	mov    r12,QWORD PTR [rsp+0x78]
    1417:	mov    r13,QWORD PTR [rsp+0x80]
    141f:	mov    r14,QWORD PTR [rsp+0x88]
    1427:	mov    r15,QWORD PTR [rsp+0x90]
    142f:	add    rsp,0xa0
    1436:	mov    rsp,rbp
    1439:	pop    rbp
    143a:	ret
    143b:	lea    rcx,[rsp+0x28]
    1440:	mov    rdx,r14
    1443:	mov    rsi,QWORD PTR [rsp+0x58]
    1448:	mov    rdi,rbx
    144b:	call   1450 <botlish_fn_15+0xf8>
			144c: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    1450:	test   rax,rax
    1453:	mov    rsi,rax
    1456:	je     16bf <botlish_fn_15+0x367>
    145c:	mov    rdx,QWORD PTR [rsp+0x28]
    1461:	mov    rcx,QWORD PTR [rsp+0x30]
    1466:	mov    rax,QWORD PTR [rbx+0x10]
    146a:	mov    r8,QWORD PTR [rax]
    146d:	mov    rdi,rbx
    1470:	call   1475 <botlish_fn_15+0x11d>
			1471: R_X86_64_PLT32	rt_str_region_eq-0x4
    1475:	cmp    rax,0x6
    1479:	je     1570 <botlish_fn_15+0x218>
    147f:	lea    rcx,[rsp+0x48]
    1484:	mov    rdx,r14
    1487:	mov    rsi,QWORD PTR [rsp+0x58]
    148c:	mov    rdi,rbx
    148f:	call   1494 <botlish_fn_15+0x13c>
			1490: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    1494:	test   rax,rax
    1497:	mov    r12,rax
    149a:	je     16bf <botlish_fn_15+0x367>
    14a0:	mov    rdx,QWORD PTR [rsp+0x48]
    14a5:	mov    QWORD PTR [rsp+0x68],rdx
    14aa:	mov    rcx,QWORD PTR [rsp+0x50]
    14af:	mov    QWORD PTR [rsp+0x60],rcx
    14b4:	mov    rsi,r12
    14b7:	mov    rdi,rbx
    14ba:	call   14bf <botlish_fn_15+0x167>
			14bb: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    14bf:	test   rax,rax
    14c2:	je     16bf <botlish_fn_15+0x367>
    14c8:	cmp    rax,0x6
    14cc:	je     150d <botlish_fn_15+0x1b5>
    14d2:	mov    rax,QWORD PTR [rbx+0x10]
    14d6:	mov    r8,QWORD PTR [rax+0x20]
    14da:	mov    rcx,QWORD PTR [rsp+0x60]
    14df:	mov    rdx,QWORD PTR [rsp+0x68]
    14e4:	mov    rsi,r12
    14e7:	mov    rdi,rbx
    14ea:	call   14ef <botlish_fn_15+0x197>
			14eb: R_X86_64_PLT32	rt_str_region_eq-0x4
    14ef:	cmp    rax,0x6
    14f3:	je     1503 <botlish_fn_15+0x1ab>
    14f9:	mov    edx,0x2
    14fe:	jmp    1512 <botlish_fn_15+0x1ba>
    1503:	mov    edx,0x6
    1508:	jmp    1512 <botlish_fn_15+0x1ba>
    150d:	mov    edx,0x6
    1512:	cmp    rdx,0x6
    1516:	je     1526 <botlish_fn_15+0x1ce>
    151c:	mov    eax,0x6
    1521:	jmp    152b <botlish_fn_15+0x1d3>
    1526:	mov    eax,0x2
    152b:	cmp    rax,0x6
    152f:	je     153d <botlish_fn_15+0x1e5>
    1535:	mov    r12,r15
    1538:	jmp    16fa <botlish_fn_15+0x3a2>
    153d:	mov    eax,0x2
    1542:	mov    rbx,QWORD PTR [rsp+0x70]
    1547:	mov    r12,QWORD PTR [rsp+0x78]
    154c:	mov    r13,QWORD PTR [rsp+0x80]
    1554:	mov    r14,QWORD PTR [rsp+0x88]
    155c:	mov    r15,QWORD PTR [rsp+0x90]
    1564:	add    rsp,0xa0
    156b:	mov    rsp,rbp
    156e:	pop    rbp
    156f:	ret
    1570:	mov    rsi,QWORD PTR [rsp+0x58]
    1575:	mov    r12,r15
    1578:	mov    rax,rsi
    157b:	and    rax,r12
    157e:	test   rax,0x1
    1584:	jne    15af <botlish_fn_15+0x257>
    158a:	mov    rdx,r12
    158d:	mov    rsi,QWORD PTR [rsp+0x58]
    1592:	mov    rdi,rbx
    1595:	call   159a <botlish_fn_15+0x242>
			1596: R_X86_64_PLT32	rt_int_cmp-0x4
    159a:	mov    ecx,0x2
    159f:	test   rax,rax
    15a2:	cmove  rcx,QWORD PTR [rip+0x266]        # 1810 <botlish_fn_15+0x4b8>
    15aa:	jmp    15c4 <botlish_fn_15+0x26c>
    15af:	mov    ecx,0x2
    15b4:	mov    rsi,QWORD PTR [rsp+0x58]
    15b9:	cmp    rsi,r12
    15bc:	cmove  rcx,QWORD PTR [rip+0x24c]        # 1810 <botlish_fn_15+0x4b8>
    15c4:	cmp    rcx,0x6
    15c8:	je     17dd <botlish_fn_15+0x485>
    15ce:	mov    QWORD PTR [rsp+0x20],0x3
    15d7:	mov    rsi,QWORD PTR [rsp+0x58]
    15dc:	test   rsi,0x1
    15e3:	je     1606 <botlish_fn_15+0x2ae>
    15e9:	mov    rsi,QWORD PTR [rsp+0x58]
    15ee:	sub    rsi,0x3
    15f2:	seto   dil
    15f6:	add    rsi,0x1
    15fd:	test   dil,dil
    1600:	je     161b <botlish_fn_15+0x2c3>
    1606:	mov    edx,0x3
    160b:	mov    rsi,QWORD PTR [rsp+0x58]
    1610:	mov    rdi,rbx
    1613:	call   1618 <botlish_fn_15+0x2c0>
			1614: R_X86_64_PLT32	rt_int_sub-0x4
    1618:	mov    rsi,rax
    161b:	mov    QWORD PTR [rsp+0x20],rsi
    1620:	lea    rcx,[rsp+0x38]
    1625:	mov    rdx,r14
    1628:	mov    rdi,rbx
    162b:	call   1630 <botlish_fn_15+0x2d8>
			162c: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    1630:	test   rax,rax
    1633:	mov    rsi,rax
    1636:	je     16bf <botlish_fn_15+0x367>
    163c:	mov    rdx,QWORD PTR [rsp+0x38]
    1641:	mov    rcx,QWORD PTR [rsp+0x40]
    1646:	mov    rax,QWORD PTR [rbx+0x10]
    164a:	mov    r8,QWORD PTR [rax]
    164d:	mov    rdi,rbx
    1650:	call   1655 <botlish_fn_15+0x2fd>
			1651: R_X86_64_PLT32	rt_str_region_eq-0x4
    1655:	cmp    rax,0x6
    1659:	je     17aa <botlish_fn_15+0x452>
    165f:	mov    QWORD PTR [rsp+0x20],0x3
    1668:	mov    rsi,QWORD PTR [rsp+0x58]
    166d:	test   rsi,0x1
    1674:	je     168e <botlish_fn_15+0x336>
    167a:	mov    rsi,QWORD PTR [rsp+0x58]
    167f:	add    rsi,0x2
    1683:	seto   al
    1686:	test   al,al
    1688:	je     16a3 <botlish_fn_15+0x34b>
    168e:	mov    edx,0x3
    1693:	mov    rsi,QWORD PTR [rsp+0x58]
    1698:	mov    rdi,rbx
    169b:	call   16a0 <botlish_fn_15+0x348>
			169c: R_X86_64_PLT32	rt_int_add-0x4
    16a0:	mov    rsi,rax
    16a3:	mov    QWORD PTR [rsp+0x20],rsi
    16a8:	mov    rcx,r14
    16ab:	mov    rdx,r13
    16ae:	mov    rdi,rbx
    16b1:	call   16b6 <botlish_fn_15+0x35e>
			16b2: R_X86_64_PLT32	botlish_fn_14-0x4 ; tld?<generic>
    16b6:	test   rax,rax
    16b9:	jne    16f0 <botlish_fn_15+0x398>
    16bf:	xor    rax,rax
    16c2:	mov    rbx,QWORD PTR [rsp+0x70]
    16c7:	mov    r12,QWORD PTR [rsp+0x78]
    16cc:	mov    r13,QWORD PTR [rsp+0x80]
    16d4:	mov    r14,QWORD PTR [rsp+0x88]
    16dc:	mov    r15,QWORD PTR [rsp+0x90]
    16e4:	add    rsp,0xa0
    16eb:	mov    rsp,rbp
    16ee:	pop    rbp
    16ef:	ret
    16f0:	cmp    rax,0x6
    16f4:	je     1777 <botlish_fn_15+0x41f>
    16fa:	mov    edx,0x3
    16ff:	mov    QWORD PTR [rsp+0x20],0x3
    1708:	mov    rsi,QWORD PTR [rsp+0x58]
    170d:	test   rsi,0x1
    1714:	jne    1724 <botlish_fn_15+0x3cc>
    171a:	mov    rsi,QWORD PTR [rsp+0x58]
    171f:	jmp    1752 <botlish_fn_15+0x3fa>
    1724:	mov    rsi,QWORD PTR [rsp+0x58]
    1729:	mov    rax,rsi
    172c:	add    rax,0x2
    1730:	seto   cl
    1733:	test   cl,cl
    1735:	je     1745 <botlish_fn_15+0x3ed>
    173b:	mov    rsi,QWORD PTR [rsp+0x58]
    1740:	jmp    1752 <botlish_fn_15+0x3fa>
    1745:	mov    rsi,rax
    1748:	mov    QWORD PTR [rsp+0x58],rax
    174d:	jmp    1762 <botlish_fn_15+0x40a>
    1752:	mov    rdi,rbx
    1755:	call   175a <botlish_fn_15+0x402>
			1756: R_X86_64_PLT32	rt_int_add-0x4
    175a:	mov    rsi,rax
    175d:	mov    QWORD PTR [rsp+0x58],rax
    1762:	mov    QWORD PTR [rsp+0x18],rsi
    1767:	mov    rsi,QWORD PTR [rsp+0x58]
    176c:	mov    rdi,rbx
    176f:	mov    r15,r12
    1772:	jmp    13aa <botlish_fn_15+0x52>
    1777:	mov    eax,0x6
    177c:	mov    rbx,QWORD PTR [rsp+0x70]
    1781:	mov    r12,QWORD PTR [rsp+0x78]
    1786:	mov    r13,QWORD PTR [rsp+0x80]
    178e:	mov    r14,QWORD PTR [rsp+0x88]
    1796:	mov    r15,QWORD PTR [rsp+0x90]
    179e:	add    rsp,0xa0
    17a5:	mov    rsp,rbp
    17a8:	pop    rbp
    17a9:	ret
    17aa:	mov    eax,0x2
    17af:	mov    rbx,QWORD PTR [rsp+0x70]
    17b4:	mov    r12,QWORD PTR [rsp+0x78]
    17b9:	mov    r13,QWORD PTR [rsp+0x80]
    17c1:	mov    r14,QWORD PTR [rsp+0x88]
    17c9:	mov    r15,QWORD PTR [rsp+0x90]
    17d1:	add    rsp,0xa0
    17d8:	mov    rsp,rbp
    17db:	pop    rbp
    17dc:	ret
    17dd:	mov    eax,0x2
    17e2:	mov    rbx,QWORD PTR [rsp+0x70]
    17e7:	mov    r12,QWORD PTR [rsp+0x78]
    17ec:	mov    r13,QWORD PTR [rsp+0x80]
    17f4:	mov    r14,QWORD PTR [rsp+0x88]
    17fc:	mov    r15,QWORD PTR [rsp+0x90]
    1804:	add    rsp,0xa0
    180b:	mov    rsp,rbp
    180e:	pop    rbp
    180f:	ret
    1810:	(bad)
    1811:	add    BYTE PTR [rax],al
    1813:	add    BYTE PTR [rax],al
    1815:	add    BYTE PTR [rax],al
	...

0000000000001818 <botlish_entry_15: domain?<generic>>:
    1818:	push   rbp
    1819:	mov    rbp,rsp
    181c:	mov    rsi,QWORD PTR [rdx]
    181f:	mov    r8,QWORD PTR [rdx+0x8]
    1823:	mov    rcx,QWORD PTR [rdx+0x10]
    1827:	mov    rdx,r8
    182a:	call   182f <botlish_entry_15+0x17>
			182b: R_X86_64_PLT32	botlish_fn_15-0x4 ; domain?<generic>
    182f:	mov    rsp,rbp
    1832:	pop    rbp
    1833:	ret

0000000000001834 <botlish_fn_16: web::is_unreserved<int>>:
    1834:	push   rbp
    1835:	mov    rbp,rsp
    1838:	sub    rsp,0x10
    183c:	mov    QWORD PTR [rsp],rbx
    1840:	mov    QWORD PTR [rsp+0x8],r13
    1845:	mov    r13,rsi
    1848:	mov    rbx,rdi
    184b:	mov    rsi,r13
    184e:	call   1853 <botlish_fn_16+0x1f>
			184f: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
    1853:	cmp    rax,0x6
    1857:	je     188e <botlish_fn_16+0x5a>
    185d:	mov    rax,QWORD PTR [rbx+0x30]
    1861:	mov    rsi,QWORD PTR [rax+0x10]
    1865:	mov    rdx,r13
    1868:	mov    rdi,rbx
    186b:	call   1870 <botlish_fn_16+0x3c>
			186c: R_X86_64_PLT32	rt_set_contains-0x4
    1870:	cmp    rax,0x6
    1874:	je     1884 <botlish_fn_16+0x50>
    187a:	mov    eax,0x2
    187f:	jmp    1893 <botlish_fn_16+0x5f>
    1884:	mov    eax,0x6
    1889:	jmp    1893 <botlish_fn_16+0x5f>
    188e:	mov    eax,0x6
    1893:	mov    rbx,QWORD PTR [rsp]
    1897:	mov    r13,QWORD PTR [rsp+0x8]
    189c:	add    rsp,0x10
    18a0:	mov    rsp,rbp
    18a3:	pop    rbp
    18a4:	ret

00000000000018a5 <botlish_entry_16: web::is_unreserved<int>>:
    18a5:	push   rbp
    18a6:	mov    rbp,rsp
    18a9:	mov    rsi,QWORD PTR [rdx]
    18ac:	call   18b1 <botlish_entry_16+0xc>
			18ad: R_X86_64_PLT32	botlish_fn_16-0x4 ; web::is_unreserved<int>
    18b1:	mov    rsp,rbp
    18b4:	pop    rbp
    18b5:	ret

00000000000018b6 <botlish_fn_17: web::uri_escape_text<str>>:
    18b6:	push   rbp
    18b7:	mov    rbp,rsp
    18ba:	sub    rsp,0x20
    18be:	mov    QWORD PTR [rsp],rsi
    18c2:	mov    edx,0x1
    18c7:	mov    QWORD PTR [rsp+0x8],0x1
    18d0:	mov    r11,QWORD PTR [rdi+0x10]
    18d4:	mov    rcx,QWORD PTR [r11+0xe8]
    18db:	mov    QWORD PTR [rsp+0x10],rcx
    18e0:	call   18e5 <botlish_fn_17+0x2f>
			18e1: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_from<str, int, str>
    18e5:	test   rax,rax
    18e8:	jne    18fa <botlish_fn_17+0x44>
    18ee:	xor    rax,rax
    18f1:	add    rsp,0x20
    18f5:	mov    rsp,rbp
    18f8:	pop    rbp
    18f9:	ret
    18fa:	add    rsp,0x20
    18fe:	mov    rsp,rbp
    1901:	pop    rbp
    1902:	ret

0000000000001903 <botlish_entry_17: web::uri_escape_text<str>>:
    1903:	push   rbp
    1904:	mov    rbp,rsp
    1907:	mov    rsi,QWORD PTR [rdx]
    190a:	call   190f <botlish_entry_17+0xc>
			190b: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::uri_escape_text<str>
    190f:	mov    rsp,rbp
    1912:	pop    rbp
    1913:	ret

0000000000001914 <botlish_fn_18: high_nibble<int>>:
    1914:	push   rbp
    1915:	mov    rbp,rsp
    1918:	sub    rsp,0x10
    191c:	mov    QWORD PTR [rsp],rsi
    1920:	mov    QWORD PTR [rsp+0x8],0x1e1
    1929:	test   rsi,0x1
    1930:	jne    1945 <botlish_fn_18+0x31>
    1936:	mov    edx,0x1e1
    193b:	call   1940 <botlish_fn_18+0x2c>
			193c: R_X86_64_PLT32	rt_int_and-0x4
    1940:	jmp    194f <botlish_fn_18+0x3b>
    1945:	and    rsi,0x1e1
    194c:	mov    rax,rsi
    194f:	sar    rax,0x5
    1953:	shl    rax,1
    1956:	or     rax,0x1
    195a:	add    rsp,0x10
    195e:	mov    rsp,rbp
    1961:	pop    rbp
    1962:	ret

0000000000001963 <botlish_entry_18: high_nibble<int>>:
    1963:	push   rbp
    1964:	mov    rbp,rsp
    1967:	mov    rsi,QWORD PTR [rdx]
    196a:	call   196f <botlish_entry_18+0xc>
			196b: R_X86_64_PLT32	botlish_fn_18-0x4 ; high_nibble<int>
    196f:	mov    rsp,rbp
    1972:	pop    rbp
    1973:	ret

0000000000001974 <botlish_fn_19: hex_pair<int>>:
    1974:	push   rbp
    1975:	mov    rbp,rsp
    1978:	sub    rsp,0x50
    197c:	mov    QWORD PTR [rsp+0x30],rbx
    1981:	mov    QWORD PTR [rsp+0x38],r12
    1986:	mov    QWORD PTR [rsp+0x40],r13
    198b:	mov    QWORD PTR [rsp+0x48],r14
    1990:	mov    QWORD PTR [rsp],rsi
    1994:	mov    r12,rsi
    1997:	mov    rax,QWORD PTR [rdi+0x30]
    199b:	mov    rbx,rdi
    199e:	mov    rsi,QWORD PTR [rax+0x8]
    19a2:	mov    QWORD PTR [rsp+0x8],rsi
    19a7:	mov    r13,rsi
    19aa:	mov    rsi,r12
    19ad:	call   19b2 <botlish_fn_19+0x3e>
			19ae: R_X86_64_PLT32	botlish_fn_18-0x4 ; high_nibble<int>
    19b2:	test   rax,0x1
    19b8:	jne    19c9 <botlish_fn_19+0x55>
    19be:	mov    rdx,rax
    19c1:	mov    rsi,r13
    19c4:	jmp    19e2 <botlish_fn_19+0x6e>
    19c9:	mov    rsi,r13
    19cc:	mov    rdx,QWORD PTR [rsi+0x8]
    19d0:	mov    rcx,rax
    19d3:	sar    rcx,1
    19d6:	cmp    rcx,rdx
    19d9:	jb     19f8 <botlish_fn_19+0x84>
    19df:	mov    rdx,rax
    19e2:	mov    rdi,rbx
    19e5:	call   19ea <botlish_fn_19+0x76>
			19e6: R_X86_64_PLT32	rt_list_get-0x4
    19ea:	test   rax,rax
    19ed:	je     1abd <botlish_fn_19+0x149>
    19f3:	jmp    1a00 <botlish_fn_19+0x8c>
    19f8:	mov    rax,QWORD PTR [rsi+0x10]
    19fc:	mov    rax,QWORD PTR [rax+rcx*8]
    1a00:	mov    QWORD PTR [rsp],rax
    1a04:	mov    rdi,rbx
    1a07:	mov    r14,rax
    1a0a:	mov    rax,QWORD PTR [rdi+0x30]
    1a0e:	mov    rsi,QWORD PTR [rax+0x8]
    1a12:	mov    r13,rsi
    1a15:	mov    edx,0x21
    1a1a:	mov    rsi,r12
    1a1d:	call   1a22 <botlish_fn_19+0xae>
			1a1e: R_X86_64_PLT32	rt_int_mod-0x4
    1a22:	test   rax,rax
    1a25:	je     1abd <botlish_fn_19+0x149>
    1a2b:	test   rax,0x1
    1a31:	jne    1a42 <botlish_fn_19+0xce>
    1a37:	mov    rdx,rax
    1a3a:	mov    rsi,r13
    1a3d:	jmp    1a5b <botlish_fn_19+0xe7>
    1a42:	mov    rsi,r13
    1a45:	mov    rdx,QWORD PTR [rsi+0x8]
    1a49:	mov    rcx,rax
    1a4c:	sar    rcx,1
    1a4f:	cmp    rcx,rdx
    1a52:	jb     1a71 <botlish_fn_19+0xfd>
    1a58:	mov    rdx,rax
    1a5b:	mov    rdi,rbx
    1a5e:	call   1a63 <botlish_fn_19+0xef>
			1a5f: R_X86_64_PLT32	rt_list_get-0x4
    1a63:	test   rax,rax
    1a66:	je     1abd <botlish_fn_19+0x149>
    1a6c:	jmp    1a79 <botlish_fn_19+0x105>
    1a71:	mov    rax,QWORD PTR [rsi+0x10]
    1a75:	mov    rax,QWORD PTR [rax+rcx*8]
    1a79:	mov    QWORD PTR [rsp+0x8],rax
    1a7e:	lea    rcx,[rsp+0x10]
    1a83:	mov    QWORD PTR [rsp+0x10],0x0
    1a8c:	mov    rdx,r14
    1a8f:	mov    QWORD PTR [rsp+0x18],rdx
    1a94:	mov    QWORD PTR [rsp+0x20],0x0
    1a9d:	mov    QWORD PTR [rsp+0x28],rax
    1aa2:	mov    esi,0x2
    1aa7:	mov    edx,0x4
    1aac:	mov    rdi,rbx
    1aaf:	call   1ab4 <botlish_fn_19+0x140>
			1ab0: R_X86_64_PLT32	rt_construct-0x4
    1ab4:	test   rax,rax
    1ab7:	jne    1add <botlish_fn_19+0x169>
    1abd:	xor    rax,rax
    1ac0:	mov    rbx,QWORD PTR [rsp+0x30]
    1ac5:	mov    r12,QWORD PTR [rsp+0x38]
    1aca:	mov    r13,QWORD PTR [rsp+0x40]
    1acf:	mov    r14,QWORD PTR [rsp+0x48]
    1ad4:	add    rsp,0x50
    1ad8:	mov    rsp,rbp
    1adb:	pop    rbp
    1adc:	ret
    1add:	mov    rbx,QWORD PTR [rsp+0x30]
    1ae2:	mov    r12,QWORD PTR [rsp+0x38]
    1ae7:	mov    r13,QWORD PTR [rsp+0x40]
    1aec:	mov    r14,QWORD PTR [rsp+0x48]
    1af1:	add    rsp,0x50
    1af5:	mov    rsp,rbp
    1af8:	pop    rbp
    1af9:	ret

0000000000001afa <botlish_entry_19: hex_pair<int>>:
    1afa:	push   rbp
    1afb:	mov    rbp,rsp
    1afe:	sub    rsp,0x10
    1b02:	mov    QWORD PTR [rsp],r12
    1b06:	mov    r12,rdi
    1b09:	mov    rsi,QWORD PTR [rdx]
    1b0c:	call   1b11 <botlish_entry_19+0x17>
			1b0d: R_X86_64_PLT32	botlish_fn_19-0x4 ; hex_pair<int>
    1b11:	mov    r8,QWORD PTR [rip+0x0]        # 1b18 <botlish_entry_19+0x1e>
			1b14: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1b18:	mov    rsi,rax
    1b1b:	mov    rdi,r12
    1b1e:	call   r8
    1b21:	mov    r12,QWORD PTR [rsp]
    1b25:	add    rsp,0x10
    1b29:	mov    rsp,rbp
    1b2c:	pop    rbp
    1b2d:	ret

0000000000001b2e <botlish_fn_20: esc_bytes<List[int], int, str>>:
    1b2e:	push   rbp
    1b2f:	mov    rbp,rsp
    1b32:	sub    rsp,0x90
    1b39:	mov    QWORD PTR [rsp+0x60],rbx
    1b3e:	mov    QWORD PTR [rsp+0x68],r12
    1b43:	mov    QWORD PTR [rsp+0x70],r13
    1b48:	mov    QWORD PTR [rsp+0x78],r14
    1b4d:	mov    QWORD PTR [rsp+0x80],r15
    1b55:	mov    QWORD PTR [rsp],rsi
    1b59:	mov    QWORD PTR [rsp+0x8],rcx
    1b5e:	sar    rdx,1
    1b61:	mov    r13,rdx
    1b64:	lea    r14,[rsp+0x20]
    1b69:	mov    rbx,rdi
    1b6c:	mov    r12,rsi
    1b6f:	mov    QWORD PTR [rsp+0x50],rcx
    1b74:	mov    rsi,r12
    1b77:	mov    rdi,rbx
    1b7a:	call   1b7f <botlish_fn_20+0x51>
			1b7b: R_X86_64_PLT32	rt_list_len-0x4
    1b7f:	sar    rax,1
    1b82:	cmp    r13,rax
    1b85:	jge    1c95 <botlish_fn_20+0x167>
    1b8b:	mov    rax,QWORD PTR [rbx+0x10]
    1b8f:	mov    r15,QWORD PTR [rax+0x10]
    1b93:	mov    QWORD PTR [rsp+0x10],r15
    1b98:	mov    rcx,QWORD PTR [r12+0x8]
    1b9d:	mov    rax,r13
    1ba0:	shl    rax,1
    1ba3:	or     rax,0x1
    1ba7:	sar    rax,1
    1baa:	cmp    rax,rcx
    1bad:	jb     1bd9 <botlish_fn_20+0xab>
    1bb3:	mov    rdx,r13
    1bb6:	shl    rdx,1
    1bb9:	or     rdx,0x1
    1bbd:	mov    rsi,r12
    1bc0:	mov    rdi,rbx
    1bc3:	call   1bc8 <botlish_fn_20+0x9a>
			1bc4: R_X86_64_PLT32	rt_list_get-0x4
    1bc8:	test   rax,rax
    1bcb:	je     1c50 <botlish_fn_20+0x122>
    1bd1:	mov    rsi,rax
    1bd4:	jmp    1be2 <botlish_fn_20+0xb4>
    1bd9:	mov    rcx,QWORD PTR [r12+0x10]
    1bde:	mov    rsi,QWORD PTR [rcx+rax*8]
    1be2:	mov    QWORD PTR [rsp+0x18],rsi
    1be7:	mov    rdi,rbx
    1bea:	call   1bef <botlish_fn_20+0xc1>
			1beb: R_X86_64_PLT32	botlish_fn_19-0x4 ; hex_pair<int>
    1bef:	test   rax,rax
    1bf2:	je     1c50 <botlish_fn_20+0x122>
    1bf8:	mov    QWORD PTR [rsp+0x18],rax
    1bfd:	mov    rcx,rax
    1c00:	mov    QWORD PTR [rsp+0x20],0x0
    1c09:	mov    rax,QWORD PTR [rsp+0x50]
    1c0e:	mov    QWORD PTR [rsp+0x28],rax
    1c13:	mov    QWORD PTR [rsp+0x30],0x0
    1c1c:	mov    QWORD PTR [rsp+0x38],r15
    1c21:	mov    QWORD PTR [rsp+0x40],0x0
    1c2a:	mov    rax,rcx
    1c2d:	mov    QWORD PTR [rsp+0x48],rax
    1c32:	mov    esi,0x2
    1c37:	mov    edx,0x6
    1c3c:	mov    rcx,r14
    1c3f:	mov    rdi,rbx
    1c42:	call   1c47 <botlish_fn_20+0x119>
			1c43: R_X86_64_PLT32	rt_construct-0x4
    1c47:	test   rax,rax
    1c4a:	jne    1c7b <botlish_fn_20+0x14d>
    1c50:	xor    rax,rax
    1c53:	mov    rbx,QWORD PTR [rsp+0x60]
    1c58:	mov    r12,QWORD PTR [rsp+0x68]
    1c5d:	mov    r13,QWORD PTR [rsp+0x70]
    1c62:	mov    r14,QWORD PTR [rsp+0x78]
    1c67:	mov    r15,QWORD PTR [rsp+0x80]
    1c6f:	add    rsp,0x90
    1c76:	mov    rsp,rbp
    1c79:	pop    rbp
    1c7a:	ret
    1c7b:	mov    QWORD PTR [rsp],r12
    1c7f:	mov    QWORD PTR [rsp+0x8],rax
    1c84:	add    r13,0x1
    1c8b:	mov    QWORD PTR [rsp+0x50],rax
    1c90:	jmp    1b74 <botlish_fn_20+0x46>
    1c95:	mov    rax,QWORD PTR [rsp+0x50]
    1c9a:	mov    rbx,QWORD PTR [rsp+0x60]
    1c9f:	mov    r12,QWORD PTR [rsp+0x68]
    1ca4:	mov    r13,QWORD PTR [rsp+0x70]
    1ca9:	mov    r14,QWORD PTR [rsp+0x78]
    1cae:	mov    r15,QWORD PTR [rsp+0x80]
    1cb6:	add    rsp,0x90
    1cbd:	mov    rsp,rbp
    1cc0:	pop    rbp
    1cc1:	ret

0000000000001cc2 <botlish_entry_20: esc_bytes<List[int], int, str>>:
    1cc2:	push   rbp
    1cc3:	mov    rbp,rsp
    1cc6:	sub    rsp,0x10
    1cca:	mov    QWORD PTR [rsp],r12
    1cce:	mov    r12,rdi
    1cd1:	mov    rsi,QWORD PTR [rdx]
    1cd4:	mov    r8,QWORD PTR [rdx+0x8]
    1cd8:	mov    rcx,QWORD PTR [rdx+0x10]
    1cdc:	mov    rdx,r8
    1cdf:	call   1ce4 <botlish_entry_20+0x22>
			1ce0: R_X86_64_PLT32	botlish_fn_20-0x4 ; esc_bytes<List[int], int, str>
    1ce4:	mov    r8,QWORD PTR [rip+0x0]        # 1ceb <botlish_entry_20+0x29>
			1ce7: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1ceb:	mov    rsi,rax
    1cee:	mov    rdi,r12
    1cf1:	call   r8
    1cf4:	mov    r12,QWORD PTR [rsp]
    1cf8:	add    rsp,0x10
    1cfc:	mov    rsp,rbp
    1cff:	pop    rbp
    1d00:	ret

0000000000001d01 <botlish_fn_21: esc_char<str>>:
    1d01:	push   rbp
    1d02:	mov    rbp,rsp
    1d05:	sub    rsp,0x40
    1d09:	mov    QWORD PTR [rsp+0x20],rbx
    1d0e:	mov    QWORD PTR [rsp+0x28],r12
    1d13:	mov    QWORD PTR [rsp+0x30],r13
    1d18:	mov    rbx,rdi
    1d1b:	mov    QWORD PTR [rsp+0x8],0x0
    1d24:	mov    QWORD PTR [rsp+0x10],0x0
    1d2d:	mov    QWORD PTR [rsp],rsi
    1d31:	mov    r13,rsi
    1d34:	mov    rsi,r13
    1d37:	mov    rdi,rbx
    1d3a:	call   1d3f <botlish_fn_21+0x3e>
			1d3b: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1d3f:	mov    rcx,rax
    1d42:	mov    r12,rax
    1d45:	test   rax,rcx
    1d48:	je     1e26 <botlish_fn_21+0x125>
    1d4e:	mov    rax,r12
    1d51:	mov    QWORD PTR [rsp],rax
    1d55:	mov    rsi,r12
    1d58:	mov    rdi,rbx
    1d5b:	call   1d60 <botlish_fn_21+0x5f>
			1d5c: R_X86_64_PLT32	rt_list_len-0x4
    1d60:	sar    rax,1
    1d63:	cmp    rax,0x1
    1d67:	je     1da4 <botlish_fn_21+0xa3>
    1d6d:	mov    edx,0x1
    1d72:	mov    QWORD PTR [rsp+0x8],0x1
    1d7b:	mov    rdi,rbx
    1d7e:	mov    rax,QWORD PTR [rdi+0x10]
    1d82:	mov    rcx,QWORD PTR [rax+0xe8]
    1d89:	mov    QWORD PTR [rsp+0x10],rcx
    1d8e:	mov    rsi,r12
    1d91:	call   1d96 <botlish_fn_21+0x95>
			1d92: R_X86_64_PLT32	botlish_fn_20-0x4 ; esc_bytes<List[int], int, str>
    1d96:	test   rax,rax
    1d99:	je     1e26 <botlish_fn_21+0x125>
    1d9f:	jmp    1e47 <botlish_fn_21+0x146>
    1da4:	mov    rsi,r12
    1da7:	mov    rax,QWORD PTR [rsi+0x8]
    1dab:	mov    r12,rsi
    1dae:	test   rax,rax
    1db1:	jne    1dd8 <botlish_fn_21+0xd7>
    1db7:	mov    edx,0x1
    1dbc:	mov    rsi,r12
    1dbf:	mov    rdi,rbx
    1dc2:	call   1dc7 <botlish_fn_21+0xc6>
			1dc3: R_X86_64_PLT32	rt_list_get-0x4
    1dc7:	test   rax,rax
    1dca:	je     1e26 <botlish_fn_21+0x125>
    1dd0:	mov    rsi,rax
    1dd3:	jmp    1de2 <botlish_fn_21+0xe1>
    1dd8:	mov    rsi,r12
    1ddb:	mov    rax,QWORD PTR [rsi+0x10]
    1ddf:	mov    rsi,QWORD PTR [rax]
    1de2:	mov    rdi,rbx
    1de5:	call   1dea <botlish_fn_21+0xe9>
			1de6: R_X86_64_PLT32	botlish_fn_16-0x4 ; web::is_unreserved<int>
    1dea:	cmp    rax,0x6
    1dee:	je     1e44 <botlish_fn_21+0x143>
    1df4:	mov    edx,0x1
    1df9:	mov    QWORD PTR [rsp+0x8],0x1
    1e02:	mov    rdi,rbx
    1e05:	mov    rax,QWORD PTR [rdi+0x10]
    1e09:	mov    rcx,QWORD PTR [rax+0xe8]
    1e10:	mov    QWORD PTR [rsp+0x10],rcx
    1e15:	mov    rsi,r12
    1e18:	call   1e1d <botlish_fn_21+0x11c>
			1e19: R_X86_64_PLT32	botlish_fn_20-0x4 ; esc_bytes<List[int], int, str>
    1e1d:	test   rax,rax
    1e20:	jne    1e41 <botlish_fn_21+0x140>
    1e26:	xor    rax,rax
    1e29:	mov    rbx,QWORD PTR [rsp+0x20]
    1e2e:	mov    r12,QWORD PTR [rsp+0x28]
    1e33:	mov    r13,QWORD PTR [rsp+0x30]
    1e38:	add    rsp,0x40
    1e3c:	mov    rsp,rbp
    1e3f:	pop    rbp
    1e40:	ret
    1e41:	mov    r13,rax
    1e44:	mov    rax,r13
    1e47:	mov    rbx,QWORD PTR [rsp+0x20]
    1e4c:	mov    r12,QWORD PTR [rsp+0x28]
    1e51:	mov    r13,QWORD PTR [rsp+0x30]
    1e56:	add    rsp,0x40
    1e5a:	mov    rsp,rbp
    1e5d:	pop    rbp
    1e5e:	ret

0000000000001e5f <botlish_entry_21: esc_char<str>>:
    1e5f:	push   rbp
    1e60:	mov    rbp,rsp
    1e63:	sub    rsp,0x10
    1e67:	mov    QWORD PTR [rsp],r12
    1e6b:	mov    r12,rdi
    1e6e:	mov    rsi,QWORD PTR [rdx]
    1e71:	call   1e76 <botlish_entry_21+0x17>
			1e72: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_char<str>
    1e76:	mov    r8,QWORD PTR [rip+0x0]        # 1e7d <botlish_entry_21+0x1e>
			1e79: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1e7d:	mov    rsi,rax
    1e80:	mov    rdi,r12
    1e83:	call   r8
    1e86:	mov    r12,QWORD PTR [rsp]
    1e8a:	add    rsp,0x10
    1e8e:	mov    rsp,rbp
    1e91:	pop    rbp
    1e92:	ret

0000000000001e93 <botlish_fn_22: esc_from<str, int, str>>:
    1e93:	push   rbp
    1e94:	mov    rbp,rsp
    1e97:	sub    rsp,0x80
    1e9e:	mov    QWORD PTR [rsp+0x50],rbx
    1ea3:	mov    QWORD PTR [rsp+0x58],r12
    1ea8:	mov    QWORD PTR [rsp+0x60],r13
    1ead:	mov    QWORD PTR [rsp+0x68],r14
    1eb2:	mov    QWORD PTR [rsp+0x70],r15
    1eb7:	mov    r14,rdi
    1eba:	mov    QWORD PTR [rsp+0x10],0x0
    1ec3:	mov    QWORD PTR [rsp+0x18],0x0
    1ecc:	mov    QWORD PTR [rsp],rsi
    1ed0:	mov    QWORD PTR [rsp+0x8],rcx
    1ed5:	mov    r15,rcx
    1ed8:	sar    rdx,1
    1edb:	mov    r12,rdx
    1ede:	lea    r13,[rsp+0x30]
    1ee3:	mov    rbx,rsi
    1ee6:	mov    rsi,rbx
    1ee9:	mov    rdi,r14
    1eec:	call   1ef1 <botlish_fn_22+0x5e>
			1eed: R_X86_64_PLT32	rt_str_len-0x4
    1ef1:	sar    rax,1
    1ef4:	cmp    r12,rax
    1ef7:	jge    1fa2 <botlish_fn_22+0x10f>
    1efd:	mov    rdx,r12
    1f00:	shl    rdx,1
    1f03:	or     rdx,0x1
    1f07:	mov    QWORD PTR [rsp+0x10],rdx
    1f0c:	add    r12,0x1
    1f13:	mov    rcx,r12
    1f16:	shl    rcx,1
    1f19:	or     rcx,0x1
    1f1d:	mov    QWORD PTR [rsp+0x18],rcx
    1f22:	mov    rsi,rbx
    1f25:	mov    rdi,r14
    1f28:	call   1f2d <botlish_fn_22+0x9a>
			1f29: R_X86_64_PLT32	rt_substr-0x4
    1f2d:	test   rax,rax
    1f30:	je     1fd4 <botlish_fn_22+0x141>
    1f36:	mov    QWORD PTR [rsp+0x10],rax
    1f3b:	mov    rsi,rax
    1f3e:	mov    rdi,r14
    1f41:	call   1f46 <botlish_fn_22+0xb3>
			1f42: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_char<str>
    1f46:	test   rax,rax
    1f49:	je     1fd4 <botlish_fn_22+0x141>
    1f4f:	mov    QWORD PTR [rsp+0x10],rax
    1f54:	mov    QWORD PTR [rsp+0x30],0x0
    1f5d:	mov    rcx,r15
    1f60:	mov    QWORD PTR [rsp+0x38],rcx
    1f65:	mov    QWORD PTR [rsp+0x40],0x0
    1f6e:	mov    QWORD PTR [rsp+0x48],rax
    1f73:	mov    esi,0x2
    1f78:	mov    edx,0x4
    1f7d:	mov    rcx,r13
    1f80:	mov    rdi,r14
    1f83:	call   1f88 <botlish_fn_22+0xf5>
			1f84: R_X86_64_PLT32	rt_construct-0x4
    1f88:	test   rax,rax
    1f8b:	je     1fd4 <botlish_fn_22+0x141>
    1f91:	mov    QWORD PTR [rsp],rbx
    1f95:	mov    QWORD PTR [rsp+0x8],rax
    1f9a:	mov    r15,rax
    1f9d:	jmp    1ee6 <botlish_fn_22+0x53>
    1fa2:	mov    rcx,r15
    1fa5:	xor    rsi,rsi
    1fa8:	lea    rax,[rsp+0x20]
    1fad:	mov    QWORD PTR [rsp+0x20],0x0
    1fb6:	mov    QWORD PTR [rsp+0x28],rcx
    1fbb:	mov    edx,0x2
    1fc0:	mov    rcx,rax
    1fc3:	mov    rdi,r14
    1fc6:	call   1fcb <botlish_fn_22+0x138>
			1fc7: R_X86_64_PLT32	rt_construct-0x4
    1fcb:	test   rax,rax
    1fce:	jne    1ffc <botlish_fn_22+0x169>
    1fd4:	xor    rax,rax
    1fd7:	mov    rbx,QWORD PTR [rsp+0x50]
    1fdc:	mov    r12,QWORD PTR [rsp+0x58]
    1fe1:	mov    r13,QWORD PTR [rsp+0x60]
    1fe6:	mov    r14,QWORD PTR [rsp+0x68]
    1feb:	mov    r15,QWORD PTR [rsp+0x70]
    1ff0:	add    rsp,0x80
    1ff7:	mov    rsp,rbp
    1ffa:	pop    rbp
    1ffb:	ret
    1ffc:	mov    rbx,QWORD PTR [rsp+0x50]
    2001:	mov    r12,QWORD PTR [rsp+0x58]
    2006:	mov    r13,QWORD PTR [rsp+0x60]
    200b:	mov    r14,QWORD PTR [rsp+0x68]
    2010:	mov    r15,QWORD PTR [rsp+0x70]
    2015:	add    rsp,0x80
    201c:	mov    rsp,rbp
    201f:	pop    rbp
    2020:	ret

0000000000002021 <botlish_entry_22: esc_from<str, int, str>>:
    2021:	push   rbp
    2022:	mov    rbp,rsp
    2025:	mov    rsi,QWORD PTR [rdx]
    2028:	mov    r8,QWORD PTR [rdx+0x8]
    202c:	mov    rcx,QWORD PTR [rdx+0x10]
    2030:	mov    rdx,r8
    2033:	call   2038 <botlish_entry_22+0x17>
			2034: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_from<str, int, str>
    2038:	mov    rsp,rbp
    203b:	pop    rbp
    203c:	ret

000000000000203d <botlish_fn_23: check<int, int, str, str>>:
    203d:	push   rbp
    203e:	mov    rbp,rsp
    2041:	sub    rsp,0x50
    2045:	mov    QWORD PTR [rsp+0x20],rbx
    204a:	mov    QWORD PTR [rsp+0x28],r12
    204f:	mov    QWORD PTR [rsp+0x30],r13
    2054:	mov    QWORD PTR [rsp+0x38],r14
    2059:	mov    QWORD PTR [rsp+0x40],r15
    205e:	mov    r14,rdi
    2061:	mov    QWORD PTR [rsp+0x18],0x0
    206a:	mov    QWORD PTR [rsp],rdx
    206e:	mov    QWORD PTR [rsp+0x8],rcx
    2073:	mov    QWORD PTR [rsp+0x10],r8
    2078:	mov    r13,r8
    207b:	sar    rsi,1
    207e:	mov    r12,rsi
    2081:	mov    r15,rdx
    2084:	test   r12,r12
    2087:	jle    2149 <botlish_fn_23+0x10c>
    208d:	mov    rbx,rcx
    2090:	mov    rsi,rbx
    2093:	mov    rdi,r14
    2096:	call   209b <botlish_fn_23+0x5e>
			2097: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<str>
    209b:	test   rax,rax
    209e:	jne    20c9 <botlish_fn_23+0x8c>
    20a4:	xor    rax,rax
    20a7:	mov    rbx,QWORD PTR [rsp+0x20]
    20ac:	mov    r12,QWORD PTR [rsp+0x28]
    20b1:	mov    r13,QWORD PTR [rsp+0x30]
    20b6:	mov    r14,QWORD PTR [rsp+0x38]
    20bb:	mov    r15,QWORD PTR [rsp+0x40]
    20c0:	add    rsp,0x50
    20c4:	mov    rsp,rbp
    20c7:	pop    rbp
    20c8:	ret
    20c9:	cmp    rax,0x6
    20cd:	je     20e9 <botlish_fn_23+0xac>
    20d3:	mov    edx,0x1
    20d8:	mov    QWORD PTR [rsp+0x18],0x1
    20e1:	mov    rsi,r15
    20e4:	jmp    20fa <botlish_fn_23+0xbd>
    20e9:	mov    edx,0x3
    20ee:	mov    QWORD PTR [rsp+0x18],0x3
    20f7:	mov    rsi,r15
    20fa:	mov    rax,rsi
    20fd:	and    rax,rdx
    2100:	test   rax,0x1
    2106:	je     2121 <botlish_fn_23+0xe4>
    210c:	lea    rcx,[rdx-0x1]
    2110:	mov    rax,rsi
    2113:	add    rax,rcx
    2116:	seto   cl
    2119:	test   cl,cl
    211b:	je     2129 <botlish_fn_23+0xec>
    2121:	mov    rdi,r14
    2124:	call   2129 <botlish_fn_23+0xec>
			2125: R_X86_64_PLT32	rt_int_add-0x4
    2129:	mov    QWORD PTR [rsp],rax
    212d:	mov    QWORD PTR [rsp+0x8],rbx
    2132:	mov    r8,r13
    2135:	mov    QWORD PTR [rsp+0x10],r8
    213a:	sub    r12,0x1
    213e:	mov    rcx,rbx
    2141:	mov    r15,rax
    2144:	jmp    2084 <botlish_fn_23+0x47>
    2149:	mov    rax,r15
    214c:	mov    rbx,QWORD PTR [rsp+0x20]
    2151:	mov    r12,QWORD PTR [rsp+0x28]
    2156:	mov    r13,QWORD PTR [rsp+0x30]
    215b:	mov    r14,QWORD PTR [rsp+0x38]
    2160:	mov    r15,QWORD PTR [rsp+0x40]
    2165:	add    rsp,0x50
    2169:	mov    rsp,rbp
    216c:	pop    rbp
    216d:	ret

000000000000216e <botlish_entry_23: check<int, int, str, str>>:
    216e:	push   rbp
    216f:	mov    rbp,rsp
    2172:	mov    rsi,QWORD PTR [rdx]
    2175:	mov    r9,QWORD PTR [rdx+0x8]
    2179:	mov    rcx,QWORD PTR [rdx+0x10]
    217d:	mov    r8,QWORD PTR [rdx+0x18]
    2181:	mov    rdx,r9
    2184:	call   2189 <botlish_entry_23+0x1b>
			2185: R_X86_64_PLT32	botlish_fn_23-0x4 ; check<int, int, str, str>
    2189:	mov    rsp,rbp
    218c:	pop    rbp
    218d:	ret

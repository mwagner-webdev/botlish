; source:  bench/refined-checks.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 9385  (per function: 1382 84 745 74 74 74 128 128 272 119 192 249 249 193 232 322 151 360 140 60 389 629 127 50 269 230 173 947 1021 322)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> std::byte::from_int<int>
;   botlish_fn_2 / botlish_entry_2 -> std::byte::set<List[UnicodeChar]>
;   botlish_fn_3 / botlish_entry_3 -> std::ascii::is_digit<int>
;   botlish_fn_4 / botlish_entry_4 -> std::ascii::is_upper<int>
;   botlish_fn_5 / botlish_entry_5 -> std::ascii::is_lower<int>
;   botlish_fn_6 / botlish_entry_6 -> std::ascii::is_alphabetic<int>
;   botlish_fn_7 / botlish_entry_7 -> std::ascii::is_alphanumeric<int>
;   botlish_fn_8 / botlish_entry_8 -> std::web::emailish?<str>
;   botlish_fn_9 / botlish_entry_9 -> char_at<int>
;   botlish_fn_10 / botlish_entry_10 -> char_is?<int, any>
;   botlish_fn_11 / botlish_entry_11 -> local_char?<UnicodeChar>
;   botlish_fn_12 / botlish_entry_12 -> local_char?<generic>
;   botlish_fn_13 / botlish_entry_13 -> label_char?<UnicodeChar>
;   botlish_fn_14 / botlish_entry_14 -> scan_while<int, block(e272)>
;   botlish_fn_15 / botlish_entry_15 -> scan_while<int, native(std::char::is_tcl_alpha)>
;   botlish_fn_16 / botlish_entry_16 -> tld?<int>
;   botlish_fn_17 / botlish_entry_17 -> domain?<int>
;   botlish_fn_18 / botlish_entry_18 -> std::web::is_unreserved<int>
;   botlish_fn_19 / botlish_entry_19 -> std::web::uri_query_value?<str>
;   botlish_fn_20 / botlish_entry_20 -> upper_hex?<int>
;   botlish_fn_21 / botlish_entry_21 -> valid_from?<int>
;   botlish_fn_22 / botlish_entry_22 -> std::web::uri_escape_text<str>
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
      33:	mov    QWORD PTR [rsp+0x158],rdi
      3b:	mov    QWORD PTR [rsp+0x28],0x0
      44:	mov    QWORD PTR [rsp+0x30],0x0
      4d:	mov    QWORD PTR [rsp+0x38],0x0
      56:	mov    QWORD PTR [rsp+0x40],0x0
      5f:	mov    QWORD PTR [rsp+0x48],0x0
      68:	mov    QWORD PTR [rsp+0x50],0x0
      71:	mov    QWORD PTR [rsp+0x58],0x0
      7a:	mov    QWORD PTR [rsp+0x60],0x0
      83:	mov    QWORD PTR [rsp+0x68],0x0
      8c:	mov    QWORD PTR [rsp+0x70],0x0
      95:	mov    QWORD PTR [rsp+0x78],0x0
      9e:	mov    QWORD PTR [rsp],0x174
      a6:	mov    QWORD PTR [rsp+0x8],0x2fc
      af:	mov    QWORD PTR [rsp+0x10],0x12c
      b8:	mov    QWORD PTR [rsp+0x18],0x15c
      c1:	mov    QWORD PTR [rsp+0x20],0x16c
      ca:	lea    rdx,[rsp+0x80]
      d2:	mov    QWORD PTR [rsp+0x80],0x174
      de:	mov    QWORD PTR [rsp+0x88],0x2fc
      ea:	mov    QWORD PTR [rsp+0x90],0x12c
      f6:	mov    QWORD PTR [rsp+0x98],0x15c
     102:	mov    QWORD PTR [rsp+0xa0],0x16c
     10e:	mov    esi,0x5
     113:	mov    rdi,QWORD PTR [rsp+0x158]
     11b:	call   120 <botlish_fn_0+0x120>
			11c: R_X86_64_PLT32	rt_list_new-0x4
     120:	test   rax,rax
     123:	je     4c2 <botlish_fn_0+0x4c2>
     129:	mov    QWORD PTR [rsp],rax
     12d:	mov    rsi,rax
     130:	mov    rdi,QWORD PTR [rsp+0x158]
     138:	call   13d <botlish_fn_0+0x13d>
			139: R_X86_64_PLT32	rt_set_from_list-0x4
     13d:	mov    rdi,QWORD PTR [rsp+0x158]
     145:	mov    rcx,QWORD PTR [rdi+0x40]
     149:	mov    QWORD PTR [rcx],rax
     14c:	mov    rax,QWORD PTR [rdi+0x10]
     150:	mov    rcx,QWORD PTR [rax]
     153:	mov    QWORD PTR [rsp],rcx
     157:	mov    QWORD PTR [rsp+0x178],rcx
     15f:	mov    rax,QWORD PTR [rdi+0x10]
     163:	mov    rdx,QWORD PTR [rax+0x8]
     167:	mov    QWORD PTR [rsp+0x8],rdx
     16c:	mov    QWORD PTR [rsp+0x170],rdx
     174:	mov    rax,QWORD PTR [rdi+0x10]
     178:	mov    rsi,QWORD PTR [rax+0x10]
     17c:	mov    QWORD PTR [rsp+0x10],rsi
     181:	mov    QWORD PTR [rsp+0x168],rsi
     189:	mov    rax,QWORD PTR [rdi+0x10]
     18d:	mov    rdi,QWORD PTR [rax+0x18]
     191:	mov    QWORD PTR [rsp+0x18],rdi
     196:	mov    QWORD PTR [rsp+0x160],rdi
     19e:	mov    rdi,QWORD PTR [rsp+0x158]
     1a6:	mov    rax,QWORD PTR [rdi+0x10]
     1aa:	mov    rdi,QWORD PTR [rax+0x20]
     1ae:	mov    QWORD PTR [rsp+0x20],rdi
     1b3:	mov    rax,QWORD PTR [rsp+0x158]
     1bb:	mov    rax,QWORD PTR [rax+0x10]
     1bf:	mov    r8,QWORD PTR [rax+0x28]
     1c3:	mov    QWORD PTR [rsp+0x28],r8
     1c8:	mov    rax,QWORD PTR [rsp+0x158]
     1d0:	mov    rax,QWORD PTR [rax+0x10]
     1d4:	mov    r9,QWORD PTR [rax+0x30]
     1d8:	mov    QWORD PTR [rsp+0x30],r9
     1dd:	mov    rcx,QWORD PTR [rsp+0x158]
     1e5:	mov    rax,QWORD PTR [rcx+0x10]
     1e9:	mov    r10,QWORD PTR [rax+0x38]
     1ed:	mov    QWORD PTR [rsp+0x38],r10
     1f2:	mov    rsi,QWORD PTR [rsp+0x158]
     1fa:	mov    rax,QWORD PTR [rsi+0x10]
     1fe:	mov    r11,QWORD PTR [rax+0x40]
     202:	mov    QWORD PTR [rsp+0x40],r11
     207:	mov    rax,QWORD PTR [rsp+0x158]
     20f:	mov    rax,QWORD PTR [rax+0x10]
     213:	mov    rbx,QWORD PTR [rax+0x48]
     217:	mov    QWORD PTR [rsp+0x48],rbx
     21c:	mov    rax,QWORD PTR [rsp+0x158]
     224:	mov    rax,QWORD PTR [rax+0x10]
     228:	mov    r12,QWORD PTR [rax+0x50]
     22c:	mov    QWORD PTR [rsp+0x50],r12
     231:	mov    rax,QWORD PTR [rsp+0x158]
     239:	mov    rax,QWORD PTR [rax+0x10]
     23d:	mov    r13,QWORD PTR [rax+0x58]
     241:	mov    QWORD PTR [rsp+0x58],r13
     246:	mov    rax,QWORD PTR [rsp+0x158]
     24e:	mov    rax,QWORD PTR [rax+0x10]
     252:	mov    r14,QWORD PTR [rax+0x60]
     256:	mov    QWORD PTR [rsp+0x60],r14
     25b:	mov    rax,QWORD PTR [rsp+0x158]
     263:	mov    rax,QWORD PTR [rax+0x10]
     267:	mov    r15,QWORD PTR [rax+0x68]
     26b:	mov    QWORD PTR [rsp+0x68],r15
     270:	mov    rax,QWORD PTR [rsp+0x158]
     278:	mov    rax,QWORD PTR [rax+0x10]
     27c:	mov    rax,QWORD PTR [rax+0x70]
     280:	mov    QWORD PTR [rsp+0x70],rax
     285:	mov    rcx,QWORD PTR [rcx+0x10]
     289:	mov    rcx,QWORD PTR [rcx+0x78]
     28d:	mov    QWORD PTR [rsp+0x78],rcx
     292:	lea    rdx,[rsp+0xa8]
     29a:	mov    rsi,QWORD PTR [rsp+0x178]
     2a2:	mov    QWORD PTR [rsp+0xa8],rsi
     2aa:	mov    rsi,QWORD PTR [rsp+0x170]
     2b2:	mov    QWORD PTR [rsp+0xb0],rsi
     2ba:	mov    rsi,QWORD PTR [rsp+0x168]
     2c2:	mov    QWORD PTR [rsp+0xb8],rsi
     2ca:	mov    rsi,QWORD PTR [rsp+0x160]
     2d2:	mov    QWORD PTR [rsp+0xc0],rsi
     2da:	mov    QWORD PTR [rsp+0xc8],rdi
     2e2:	mov    QWORD PTR [rsp+0xd0],r8
     2ea:	mov    QWORD PTR [rsp+0xd8],r9
     2f2:	mov    QWORD PTR [rsp+0xe0],r10
     2fa:	mov    QWORD PTR [rsp+0xe8],r11
     302:	mov    QWORD PTR [rsp+0xf0],rbx
     30a:	mov    QWORD PTR [rsp+0xf8],r12
     312:	mov    QWORD PTR [rsp+0x100],r13
     31a:	mov    QWORD PTR [rsp+0x108],r14
     322:	mov    QWORD PTR [rsp+0x110],r15
     32a:	mov    QWORD PTR [rsp+0x118],rax
     332:	mov    QWORD PTR [rsp+0x120],rcx
     33a:	mov    esi,0x10
     33f:	mov    rdi,QWORD PTR [rsp+0x158]
     347:	call   34c <botlish_fn_0+0x34c>
			348: R_X86_64_PLT32	rt_list_new-0x4
     34c:	test   rax,rax
     34f:	je     4c2 <botlish_fn_0+0x4c2>
     355:	mov    rdi,QWORD PTR [rsp+0x158]
     35d:	mov    rcx,QWORD PTR [rdi+0x40]
     361:	mov    QWORD PTR [rcx+0x8],rax
     365:	mov    QWORD PTR [rsp],0x16c
     36d:	mov    QWORD PTR [rsp+0x8],0x174
     376:	mov    QWORD PTR [rsp+0x10],0x2fc
     37f:	mov    QWORD PTR [rsp+0x18],0x3f4
     388:	lea    rdx,[rsp+0x128]
     390:	mov    QWORD PTR [rsp+0x128],0x16c
     39c:	mov    QWORD PTR [rsp+0x130],0x174
     3a8:	mov    QWORD PTR [rsp+0x138],0x2fc
     3b4:	mov    QWORD PTR [rsp+0x140],0x3f4
     3c0:	mov    esi,0x4
     3c5:	call   3ca <botlish_fn_0+0x3ca>
			3c6: R_X86_64_PLT32	rt_list_new-0x4
     3ca:	test   rax,rax
     3cd:	je     4c2 <botlish_fn_0+0x4c2>
     3d3:	mov    QWORD PTR [rsp],rax
     3d7:	mov    rsi,rax
     3da:	mov    rdi,QWORD PTR [rsp+0x158]
     3e2:	call   3e7 <botlish_fn_0+0x3e7>
			3e3: R_X86_64_PLT32	botlish_fn_2-0x4 ; std::byte::set<List[UnicodeChar]>
     3e7:	test   rax,rax
     3ea:	je     4c2 <botlish_fn_0+0x4c2>
     3f0:	mov    rdi,QWORD PTR [rsp+0x158]
     3f8:	mov    rcx,QWORD PTR [rdi+0x40]
     3fc:	mov    QWORD PTR [rcx+0x10],rax
     400:	mov    esi,0xe2a0e1
     405:	call   40a <botlish_fn_0+0x40a>
			406: R_X86_64_PLT32	botlish_fn_22-0x4 ; std::web::uri_escape_text<str>
     40a:	test   rax,rax
     40d:	je     4c2 <botlish_fn_0+0x4c2>
     413:	mov    QWORD PTR [rsp],rax
     417:	mov    r14,rax
     41a:	mov    ebx,0x1
     41f:	mov    QWORD PTR [rsp+0x8],0x1
     428:	mov    rdi,QWORD PTR [rsp+0x158]
     430:	mov    rcx,QWORD PTR [rdi+0x10]
     434:	mov    rcx,QWORD PTR [rcx+0x80]
     43b:	mov    QWORD PTR [rsp+0x10],rcx
     440:	mov    r12d,0x190
     446:	mov    rdx,rbx
     449:	mov    rsi,r12
     44c:	mov    r8,r14
     44f:	call   454 <botlish_fn_0+0x454>
			450: R_X86_64_PLT32	botlish_fn_29-0x4 ; check<int, int, str, str>
     454:	mov    r13,rax
     457:	mov    QWORD PTR [rsp+0x8],r13
     45c:	mov    QWORD PTR [rsp+0x10],0x1
     465:	mov    rdi,QWORD PTR [rsp+0x158]
     46d:	mov    rax,QWORD PTR [rdi+0x10]
     471:	mov    rcx,QWORD PTR [rax+0x88]
     478:	mov    QWORD PTR [rsp+0x18],rcx
     47d:	mov    rdx,rbx
     480:	mov    rsi,r12
     483:	mov    r8,r14
     486:	call   48b <botlish_fn_0+0x48b>
			487: R_X86_64_PLT32	botlish_fn_29-0x4 ; check<int, int, str, str>
     48b:	mov    QWORD PTR [rsp],rax
     48f:	lea    rdx,[rsp+0x148]
     497:	mov    QWORD PTR [rsp+0x148],r13
     49f:	mov    QWORD PTR [rsp+0x150],rax
     4a7:	mov    esi,0x2
     4ac:	mov    rdi,QWORD PTR [rsp+0x158]
     4b4:	call   4b9 <botlish_fn_0+0x4b9>
			4b5: R_X86_64_PLT32	rt_list_new-0x4
     4b9:	test   rax,rax
     4bc:	jne    4f9 <botlish_fn_0+0x4f9>
     4c2:	xor    rax,rax
     4c5:	mov    rbx,QWORD PTR [rsp+0x180]
     4cd:	mov    r12,QWORD PTR [rsp+0x188]
     4d5:	mov    r13,QWORD PTR [rsp+0x190]
     4dd:	mov    r14,QWORD PTR [rsp+0x198]
     4e5:	mov    r15,QWORD PTR [rsp+0x1a0]
     4ed:	add    rsp,0x1b0
     4f4:	mov    rsp,rbp
     4f7:	pop    rbp
     4f8:	ret
     4f9:	mov    rbx,QWORD PTR [rsp+0x180]
     501:	mov    r12,QWORD PTR [rsp+0x188]
     509:	mov    r13,QWORD PTR [rsp+0x190]
     511:	mov    r14,QWORD PTR [rsp+0x198]
     519:	mov    r15,QWORD PTR [rsp+0x1a0]
     521:	add    rsp,0x1b0
     528:	mov    rsp,rbp
     52b:	pop    rbp
     52c:	ret

000000000000052d <botlish_entry_0: <program entry>>:
     52d:	push   rbp
     52e:	mov    rbp,rsp
     531:	call   536 <botlish_entry_0+0x9>
			532: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     536:	mov    rsp,rbp
     539:	pop    rbp
     53a:	ret

000000000000053b <botlish_fn_1: std::byte::from_int<int>>:
     53b:	push   rbp
     53c:	mov    rbp,rsp
     53f:	mov    r10,rsi
     542:	sar    r10,1
     545:	cmp    r10,0xff
     54c:	jg     55a <botlish_fn_1+0x1f>
     552:	mov    rax,rsi
     555:	mov    rsp,rbp
     558:	pop    rbp
     559:	ret
     55a:	mov    rax,QWORD PTR [rdi+0x10]
     55e:	mov    rdx,QWORD PTR [rax+0x90]
     565:	mov    esi,0x2
     56a:	call   56f <botlish_fn_1+0x34>
			56b: R_X86_64_PLT32	rt_fail_declared-0x4
     56f:	xor    rax,rax
     572:	mov    rsp,rbp
     575:	pop    rbp
     576:	ret

0000000000000577 <botlish_entry_1: std::byte::from_int<int>>:
     577:	push   rbp
     578:	mov    rbp,rsp
     57b:	mov    rsi,QWORD PTR [rdx]
     57e:	call   583 <botlish_entry_1+0xc>
			57f: R_X86_64_PLT32	botlish_fn_1-0x4 ; std::byte::from_int<int>
     583:	mov    rsp,rbp
     586:	pop    rbp
     587:	ret

0000000000000588 <botlish_fn_2: std::byte::set<List[UnicodeChar]>>:
     588:	push   rbp
     589:	mov    rbp,rsp
     58c:	sub    rsp,0x90
     593:	mov    QWORD PTR [rsp+0x60],rbx
     598:	mov    QWORD PTR [rsp+0x68],r12
     59d:	mov    QWORD PTR [rsp+0x70],r13
     5a2:	mov    QWORD PTR [rsp+0x78],r14
     5a7:	mov    QWORD PTR [rsp+0x80],r15
     5af:	mov    r13,rdi
     5b2:	mov    QWORD PTR [rsp+0x18],0x0
     5bb:	mov    QWORD PTR [rsp+0x20],0x0
     5c4:	mov    QWORD PTR [rsp],rsi
     5c8:	mov    rbx,rsi
     5cb:	mov    rdi,r13
     5ce:	call   5d3 <botlish_fn_2+0x4b>
			5cf: R_X86_64_PLT32	rt_list_len-0x4
     5d3:	mov    QWORD PTR [rsp+0x8],rax
     5d8:	mov    r12,rax
     5db:	mov    QWORD PTR [rsp+0x10],0x1
     5e4:	xor    rdx,rdx
     5e7:	mov    rdi,r13
     5ea:	mov    rsi,rdx
     5ed:	call   5f2 <botlish_fn_2+0x6a>
			5ee: R_X86_64_PLT32	rt_list_new-0x4
     5f2:	test   rax,rax
     5f5:	je     789 <botlish_fn_2+0x201>
     5fb:	mov    QWORD PTR [rsp+0x18],rax
     600:	mov    QWORD PTR [rsp+0x58],rax
     605:	mov    esi,0x1
     60a:	mov    r14,rsi
     60d:	mov    rax,rsi
     610:	and    rax,r12
     613:	mov    r14,rsi
     616:	test   rax,0x1
     61c:	jne    645 <botlish_fn_2+0xbd>
     622:	mov    rdx,r12
     625:	mov    rsi,r14
     628:	mov    rdi,r13
     62b:	call   630 <botlish_fn_2+0xa8>
			62c: R_X86_64_PLT32	rt_int_cmp-0x4
     630:	mov    ecx,0x2
     635:	test   rax,rax
     638:	cmovl  rcx,QWORD PTR [rip+0x1e8]        # 828 <botlish_fn_2+0x2a0>
     640:	jmp    658 <botlish_fn_2+0xd0>
     645:	mov    ecx,0x2
     64a:	mov    rsi,r14
     64d:	cmp    rsi,r12
     650:	cmovl  rcx,QWORD PTR [rip+0x1d0]        # 828 <botlish_fn_2+0x2a0>
     658:	cmp    rcx,0x6
     65c:	je     6cc <botlish_fn_2+0x144>
     662:	lea    rcx,[rsp+0x48]
     667:	mov    QWORD PTR [rsp+0x48],0x0
     670:	mov    rax,QWORD PTR [rsp+0x58]
     675:	mov    QWORD PTR [rsp+0x50],rax
     67a:	mov    esi,0x1
     67f:	mov    edx,0x2
     684:	mov    rdi,r13
     687:	call   68c <botlish_fn_2+0x104>
			688: R_X86_64_PLT32	rt_construct-0x4
     68c:	test   rax,rax
     68f:	je     789 <botlish_fn_2+0x201>
     695:	mov    QWORD PTR [rsp],rax
     699:	mov    rsi,rax
     69c:	mov    rdi,r13
     69f:	call   6a4 <botlish_fn_2+0x11c>
			6a0: R_X86_64_PLT32	rt_set_from_list-0x4
     6a4:	mov    rbx,QWORD PTR [rsp+0x60]
     6a9:	mov    r12,QWORD PTR [rsp+0x68]
     6ae:	mov    r13,QWORD PTR [rsp+0x70]
     6b3:	mov    r14,QWORD PTR [rsp+0x78]
     6b8:	mov    r15,QWORD PTR [rsp+0x80]
     6c0:	add    rsp,0x90
     6c7:	mov    rsp,rbp
     6ca:	pop    rbp
     6cb:	ret
     6cc:	mov    rsi,r14
     6cf:	test   rsi,0x1
     6d6:	je     6f2 <botlish_fn_2+0x16a>
     6dc:	mov    r9,QWORD PTR [rbx+0x8]
     6e0:	mov    rsi,r14
     6e3:	mov    r8,rsi
     6e6:	sar    r8,1
     6e9:	cmp    r8,r9
     6ec:	jb     711 <botlish_fn_2+0x189>
     6f2:	mov    rdx,r14
     6f5:	mov    rsi,rbx
     6f8:	mov    rdi,r13
     6fb:	call   700 <botlish_fn_2+0x178>
			6fc: R_X86_64_PLT32	rt_list_get-0x4
     700:	test   rax,rax
     703:	je     789 <botlish_fn_2+0x201>
     709:	mov    rsi,rax
     70c:	jmp    719 <botlish_fn_2+0x191>
     711:	mov    rax,QWORD PTR [rbx+0x10]
     715:	mov    rsi,QWORD PTR [rax+r8*8]
     719:	mov    edx,0x3
     71e:	mov    r15,rdx
     721:	shr    rsi,0x3
     725:	shl    rsi,1
     728:	or     rsi,0x1
     72c:	mov    rdi,r13
     72f:	call   734 <botlish_fn_2+0x1ac>
			730: R_X86_64_PLT32	botlish_fn_1-0x4 ; std::byte::from_int<int>
     734:	test   rax,rax
     737:	je     789 <botlish_fn_2+0x201>
     73d:	mov    QWORD PTR [rsp+0x20],rax
     742:	lea    rcx,[rsp+0x28]
     747:	mov    QWORD PTR [rsp+0x28],0x0
     750:	mov    r10,QWORD PTR [rsp+0x58]
     755:	mov    QWORD PTR [rsp+0x30],r10
     75a:	mov    QWORD PTR [rsp+0x38],0x2
     763:	mov    QWORD PTR [rsp+0x40],rax
     768:	mov    edx,0x4
     76d:	mov    rsi,r15
     770:	mov    rdi,r13
     773:	call   778 <botlish_fn_2+0x1f0>
			774: R_X86_64_PLT32	rt_construct-0x4
     778:	mov    rcx,rax
     77b:	mov    QWORD PTR [rsp+0x58],rax
     780:	test   rax,rcx
     783:	jne    7b4 <botlish_fn_2+0x22c>
     789:	xor    rax,rax
     78c:	mov    rbx,QWORD PTR [rsp+0x60]
     791:	mov    r12,QWORD PTR [rsp+0x68]
     796:	mov    r13,QWORD PTR [rsp+0x70]
     79b:	mov    r14,QWORD PTR [rsp+0x78]
     7a0:	mov    r15,QWORD PTR [rsp+0x80]
     7a8:	add    rsp,0x90
     7af:	mov    rsp,rbp
     7b2:	pop    rbp
     7b3:	ret
     7b4:	mov    rax,QWORD PTR [rsp+0x58]
     7b9:	mov    QWORD PTR [rsp+0x18],rax
     7be:	mov    QWORD PTR [rsp+0x20],0x3
     7c7:	mov    rsi,r14
     7ca:	test   rsi,0x1
     7d1:	jne    7e2 <botlish_fn_2+0x25a>
     7d7:	mov    rdx,r15
     7da:	mov    rsi,r14
     7dd:	jmp    80d <botlish_fn_2+0x285>
     7e2:	mov    rsi,r14
     7e5:	mov    rax,rsi
     7e8:	add    rax,0x2
     7ec:	seto   cl
     7ef:	test   cl,cl
     7f1:	je     802 <botlish_fn_2+0x27a>
     7f7:	mov    rdx,r15
     7fa:	mov    rsi,r14
     7fd:	jmp    80d <botlish_fn_2+0x285>
     802:	mov    rsi,rax
     805:	mov    r14,rax
     808:	jmp    81b <botlish_fn_2+0x293>
     80d:	mov    rdi,r13
     810:	call   815 <botlish_fn_2+0x28d>
			811: R_X86_64_PLT32	rt_int_add-0x4
     815:	mov    rsi,rax
     818:	mov    r14,rax
     81b:	mov    QWORD PTR [rsp+0x10],rsi
     820:	mov    rsi,r14
     823:	jmp    60d <botlish_fn_2+0x85>
     828:	(bad)
     829:	add    BYTE PTR [rax],al
     82b:	add    BYTE PTR [rax],al
     82d:	add    BYTE PTR [rax],al
	...

0000000000000830 <botlish_entry_2: std::byte::set<List[UnicodeChar]>>:
     830:	push   rbp
     831:	mov    rbp,rsp
     834:	mov    rsi,QWORD PTR [rdx]
     837:	call   83c <botlish_entry_2+0xc>
			838: R_X86_64_PLT32	botlish_fn_2-0x4 ; std::byte::set<List[UnicodeChar]>
     83c:	mov    rsp,rbp
     83f:	pop    rbp
     840:	ret

0000000000000841 <botlish_fn_3: std::ascii::is_digit<int>>:
     841:	push   rbp
     842:	mov    rbp,rsp
     845:	cmp    rsi,0x30
     849:	jge    859 <botlish_fn_3+0x18>
     84f:	mov    eax,0x2
     854:	jmp    872 <botlish_fn_3+0x31>
     859:	cmp    rsi,0x39
     85d:	jle    86d <botlish_fn_3+0x2c>
     863:	mov    eax,0x2
     868:	jmp    872 <botlish_fn_3+0x31>
     86d:	mov    eax,0x6
     872:	mov    rsp,rbp
     875:	pop    rbp
     876:	ret

0000000000000877 <botlish_entry_3: std::ascii::is_digit<int>>:
     877:	push   rbp
     878:	mov    rbp,rsp
     87b:	mov    rsi,QWORD PTR [rdx]
     87e:	sar    rsi,1
     881:	call   886 <botlish_entry_3+0xf>
			882: R_X86_64_PLT32	botlish_fn_3-0x4 ; std::ascii::is_digit<int>
     886:	mov    rsp,rbp
     889:	pop    rbp
     88a:	ret

000000000000088b <botlish_fn_4: std::ascii::is_upper<int>>:
     88b:	push   rbp
     88c:	mov    rbp,rsp
     88f:	cmp    rsi,0x41
     893:	jge    8a3 <botlish_fn_4+0x18>
     899:	mov    eax,0x2
     89e:	jmp    8bc <botlish_fn_4+0x31>
     8a3:	cmp    rsi,0x5a
     8a7:	jle    8b7 <botlish_fn_4+0x2c>
     8ad:	mov    eax,0x2
     8b2:	jmp    8bc <botlish_fn_4+0x31>
     8b7:	mov    eax,0x6
     8bc:	mov    rsp,rbp
     8bf:	pop    rbp
     8c0:	ret

00000000000008c1 <botlish_entry_4: std::ascii::is_upper<int>>:
     8c1:	push   rbp
     8c2:	mov    rbp,rsp
     8c5:	mov    rsi,QWORD PTR [rdx]
     8c8:	sar    rsi,1
     8cb:	call   8d0 <botlish_entry_4+0xf>
			8cc: R_X86_64_PLT32	botlish_fn_4-0x4 ; std::ascii::is_upper<int>
     8d0:	mov    rsp,rbp
     8d3:	pop    rbp
     8d4:	ret

00000000000008d5 <botlish_fn_5: std::ascii::is_lower<int>>:
     8d5:	push   rbp
     8d6:	mov    rbp,rsp
     8d9:	cmp    rsi,0x61
     8dd:	jge    8ed <botlish_fn_5+0x18>
     8e3:	mov    eax,0x2
     8e8:	jmp    906 <botlish_fn_5+0x31>
     8ed:	cmp    rsi,0x7a
     8f1:	jle    901 <botlish_fn_5+0x2c>
     8f7:	mov    eax,0x2
     8fc:	jmp    906 <botlish_fn_5+0x31>
     901:	mov    eax,0x6
     906:	mov    rsp,rbp
     909:	pop    rbp
     90a:	ret

000000000000090b <botlish_entry_5: std::ascii::is_lower<int>>:
     90b:	push   rbp
     90c:	mov    rbp,rsp
     90f:	mov    rsi,QWORD PTR [rdx]
     912:	sar    rsi,1
     915:	call   91a <botlish_entry_5+0xf>
			916: R_X86_64_PLT32	botlish_fn_5-0x4 ; std::ascii::is_lower<int>
     91a:	mov    rsp,rbp
     91d:	pop    rbp
     91e:	ret

000000000000091f <botlish_fn_6: std::ascii::is_alphabetic<int>>:
     91f:	push   rbp
     920:	mov    rbp,rsp
     923:	sub    rsp,0x10
     927:	mov    QWORD PTR [rsp],r12
     92b:	mov    QWORD PTR [rsp+0x8],r14
     930:	mov    r12,rsi
     933:	mov    r14,rdi
     936:	mov    rsi,r12
     939:	mov    rdi,r14
     93c:	call   941 <botlish_fn_6+0x22>
			93d: R_X86_64_PLT32	botlish_fn_4-0x4 ; std::ascii::is_upper<int>
     941:	cmp    rax,0x6
     945:	je     974 <botlish_fn_6+0x55>
     94b:	mov    rsi,r12
     94e:	mov    rdi,r14
     951:	call   956 <botlish_fn_6+0x37>
			952: R_X86_64_PLT32	botlish_fn_5-0x4 ; std::ascii::is_lower<int>
     956:	cmp    rax,0x6
     95a:	je     96a <botlish_fn_6+0x4b>
     960:	mov    eax,0x2
     965:	jmp    979 <botlish_fn_6+0x5a>
     96a:	mov    eax,0x6
     96f:	jmp    979 <botlish_fn_6+0x5a>
     974:	mov    eax,0x6
     979:	mov    r12,QWORD PTR [rsp]
     97d:	mov    r14,QWORD PTR [rsp+0x8]
     982:	add    rsp,0x10
     986:	mov    rsp,rbp
     989:	pop    rbp
     98a:	ret

000000000000098b <botlish_entry_6: std::ascii::is_alphabetic<int>>:
     98b:	push   rbp
     98c:	mov    rbp,rsp
     98f:	mov    rsi,QWORD PTR [rdx]
     992:	sar    rsi,1
     995:	call   99a <botlish_entry_6+0xf>
			996: R_X86_64_PLT32	botlish_fn_6-0x4 ; std::ascii::is_alphabetic<int>
     99a:	mov    rsp,rbp
     99d:	pop    rbp
     99e:	ret

000000000000099f <botlish_fn_7: std::ascii::is_alphanumeric<int>>:
     99f:	push   rbp
     9a0:	mov    rbp,rsp
     9a3:	sub    rsp,0x10
     9a7:	mov    QWORD PTR [rsp],r12
     9ab:	mov    QWORD PTR [rsp+0x8],r14
     9b0:	mov    r12,rsi
     9b3:	mov    r14,rdi
     9b6:	mov    rsi,r12
     9b9:	mov    rdi,r14
     9bc:	call   9c1 <botlish_fn_7+0x22>
			9bd: R_X86_64_PLT32	botlish_fn_6-0x4 ; std::ascii::is_alphabetic<int>
     9c1:	cmp    rax,0x6
     9c5:	je     9f4 <botlish_fn_7+0x55>
     9cb:	mov    rsi,r12
     9ce:	mov    rdi,r14
     9d1:	call   9d6 <botlish_fn_7+0x37>
			9d2: R_X86_64_PLT32	botlish_fn_3-0x4 ; std::ascii::is_digit<int>
     9d6:	cmp    rax,0x6
     9da:	je     9ea <botlish_fn_7+0x4b>
     9e0:	mov    eax,0x2
     9e5:	jmp    9f9 <botlish_fn_7+0x5a>
     9ea:	mov    eax,0x6
     9ef:	jmp    9f9 <botlish_fn_7+0x5a>
     9f4:	mov    eax,0x6
     9f9:	mov    r12,QWORD PTR [rsp]
     9fd:	mov    r14,QWORD PTR [rsp+0x8]
     a02:	add    rsp,0x10
     a06:	mov    rsp,rbp
     a09:	pop    rbp
     a0a:	ret

0000000000000a0b <botlish_entry_7: std::ascii::is_alphanumeric<int>>:
     a0b:	push   rbp
     a0c:	mov    rbp,rsp
     a0f:	mov    rsi,QWORD PTR [rdx]
     a12:	sar    rsi,1
     a15:	call   a1a <botlish_entry_7+0xf>
			a16: R_X86_64_PLT32	botlish_fn_7-0x4 ; std::ascii::is_alphanumeric<int>
     a1a:	mov    rsp,rbp
     a1d:	pop    rbp
     a1e:	ret

0000000000000a1f <botlish_fn_8: std::web::emailish?<str>>:
     a1f:	push   rbp
     a20:	mov    rbp,rsp
     a23:	sub    rsp,0x20
     a27:	mov    QWORD PTR [rsp],rbx
     a2b:	mov    QWORD PTR [rsp+0x8],r12
     a30:	mov    QWORD PTR [rsp+0x10],r13
     a35:	mov    QWORD PTR [rsp+0x18],r14
     a3a:	mov    r12,rsi
     a3d:	mov    rsi,r12
     a40:	mov    rdx,QWORD PTR [rsi+0x8]
     a44:	mov    rax,QWORD PTR [rdi+0x10]
     a48:	mov    r13,rdi
     a4b:	mov    rax,QWORD PTR [rax+0x98]
     a52:	xor    rsi,rsi
     a55:	shl    rdx,1
     a58:	mov    rcx,rdx
     a5b:	or     rcx,0x1
     a5f:	mov    r14,rdx
     a62:	mov    rdx,rax
     a65:	mov    r8,r12
     a68:	call   a6d <botlish_fn_8+0x4e>
			a69: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, block(e272)>
     a6d:	mov    rbx,rax
     a70:	sar    rbx,1
     a73:	mov    rdi,rax
     a76:	test   rbx,rbx
     a79:	jle    acb <botlish_fn_8+0xac>
     a7f:	mov    rsi,r14
     a82:	mov    rax,rsi
     a85:	or     rax,0x1
     a89:	sar    rax,1
     a8c:	cmp    rbx,rax
     a8f:	jl     a9f <botlish_fn_8+0x80>
     a95:	mov    eax,0xa
     a9a:	jmp    acb <botlish_fn_8+0xac>
     a9f:	mov    edx,0x204
     aa4:	mov    rcx,rsi
     aa7:	or     rcx,0x1
     aab:	mov    r14,rsi
     aae:	mov    rsi,rdi
     ab1:	mov    rdi,r13
     ab4:	mov    r8,r12
     ab7:	call   abc <botlish_fn_8+0x9d>
			ab8: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_is?<int, any>
     abc:	cmp    rax,0x6
     ac0:	je     aec <botlish_fn_8+0xcd>
     ac6:	mov    eax,0xa
     acb:	mov    eax,0x2
     ad0:	mov    rbx,QWORD PTR [rsp]
     ad4:	mov    r12,QWORD PTR [rsp+0x8]
     ad9:	mov    r13,QWORD PTR [rsp+0x10]
     ade:	mov    r14,QWORD PTR [rsp+0x18]
     ae3:	add    rsp,0x20
     ae7:	mov    rsp,rbp
     aea:	pop    rbp
     aeb:	ret
     aec:	lea    rsi,[rbx+0x1]
     af0:	mov    rdx,r14
     af3:	or     rdx,0x1
     af7:	mov    rcx,r12
     afa:	mov    rdi,r13
     afd:	call   b02 <botlish_fn_8+0xe3>
			afe: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<int>
     b02:	mov    rbx,QWORD PTR [rsp]
     b06:	mov    r12,QWORD PTR [rsp+0x8]
     b0b:	mov    r13,QWORD PTR [rsp+0x10]
     b10:	mov    r14,QWORD PTR [rsp+0x18]
     b15:	add    rsp,0x20
     b19:	mov    rsp,rbp
     b1c:	pop    rbp
     b1d:	ret

0000000000000b1e <botlish_entry_8: std::web::emailish?<str>>:
     b1e:	push   rbp
     b1f:	mov    rbp,rsp
     b22:	mov    rsi,QWORD PTR [rdx]
     b25:	call   b2a <botlish_entry_8+0xc>
			b26: R_X86_64_PLT32	botlish_fn_8-0x4 ; std::web::emailish?<str>
     b2a:	mov    rsp,rbp
     b2d:	pop    rbp
     b2e:	ret

0000000000000b2f <botlish_fn_9: char_at<int>>:
     b2f:	push   rbp
     b30:	mov    rbp,rsp
     b33:	mov    rax,rsi
     b36:	sar    rax,1
     b39:	sar    rdx,1
     b3c:	cmp    rax,rdx
     b3f:	jge    b79 <botlish_fn_9+0x4a>
     b45:	movzx  rdx,BYTE PTR [rcx+0x18]
     b4a:	test   rdx,rdx
     b4d:	jne    b63 <botlish_fn_9+0x34>
     b53:	mov    rdx,rsi
     b56:	mov    rsi,rcx
     b59:	call   b5e <botlish_fn_9+0x2f>
			b5a: R_X86_64_PLT32	rt_str_char_at_proven-0x4
     b5e:	jmp    b74 <botlish_fn_9+0x45>
     b63:	mov    rsi,rcx
     b66:	movzx  rax,BYTE PTR [rsi+rax*1+0x19]
     b6c:	shl    rax,0x3
     b70:	or     rax,0x4
     b74:	mov    rsp,rbp
     b77:	pop    rbp
     b78:	ret
     b79:	mov    eax,0x104
     b7e:	mov    rsp,rbp
     b81:	pop    rbp
     b82:	ret

0000000000000b83 <botlish_entry_9: char_at<int>>:
     b83:	push   rbp
     b84:	mov    rbp,rsp
     b87:	mov    rsi,QWORD PTR [rdx]
     b8a:	mov    r8,QWORD PTR [rdx+0x8]
     b8e:	mov    rcx,QWORD PTR [rdx+0x10]
     b92:	mov    rdx,r8
     b95:	call   b9a <botlish_entry_9+0x17>
			b96: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     b9a:	mov    rsp,rbp
     b9d:	pop    rbp
     b9e:	ret
	...

0000000000000ba0 <botlish_fn_10: char_is?<int, any>>:
     ba0:	push   rbp
     ba1:	mov    rbp,rsp
     ba4:	sub    rsp,0x10
     ba8:	mov    QWORD PTR [rsp],rbx
     bac:	mov    rbx,rdx
     baf:	mov    rax,rsi
     bb2:	sar    rax,1
     bb5:	sar    rcx,1
     bb8:	cmp    rax,rcx
     bbb:	jge    c1c <botlish_fn_10+0x7c>
     bc1:	movzx  rcx,BYTE PTR [r8+0x18]
     bc6:	mov    rdx,r8
     bc9:	test   rcx,rcx
     bcc:	jne    be8 <botlish_fn_10+0x48>
     bd2:	mov    rax,rdx
     bd5:	mov    rdx,rsi
     bd8:	mov    rsi,rax
     bdb:	call   be0 <botlish_fn_10+0x40>
			bdc: R_X86_64_PLT32	rt_str_char_at_proven-0x4
     be0:	mov    rcx,rax
     be3:	jmp    bfc <botlish_fn_10+0x5c>
     be8:	mov    rsi,rdx
     beb:	movzx  rax,BYTE PTR [rsi+rax*1+0x19]
     bf1:	shl    rax,0x3
     bf5:	or     rax,0x4
     bf9:	mov    rcx,rax
     bfc:	mov    eax,0x2
     c01:	mov    rdx,rbx
     c04:	cmp    rcx,rdx
     c07:	cmove  rax,QWORD PTR [rip+0x21]        # c30 <botlish_fn_10+0x90>
     c0f:	mov    rbx,QWORD PTR [rsp]
     c13:	add    rsp,0x10
     c17:	mov    rsp,rbp
     c1a:	pop    rbp
     c1b:	ret
     c1c:	mov    eax,0x2
     c21:	mov    rbx,QWORD PTR [rsp]
     c25:	add    rsp,0x10
     c29:	mov    rsp,rbp
     c2c:	pop    rbp
     c2d:	ret
     c2e:	add    BYTE PTR [rax],al
     c30:	(bad)
     c31:	add    BYTE PTR [rax],al
     c33:	add    BYTE PTR [rax],al
     c35:	add    BYTE PTR [rax],al
	...

0000000000000c38 <botlish_entry_10: char_is?<int, any>>:
     c38:	push   rbp
     c39:	mov    rbp,rsp
     c3c:	mov    rsi,QWORD PTR [rdx]
     c3f:	mov    r9,QWORD PTR [rdx+0x8]
     c43:	mov    rcx,QWORD PTR [rdx+0x10]
     c47:	mov    r8,QWORD PTR [rdx+0x18]
     c4b:	mov    rdx,r9
     c4e:	call   c53 <botlish_entry_10+0x1b>
			c4f: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_is?<int, any>
     c53:	mov    rsp,rbp
     c56:	pop    rbp
     c57:	ret

0000000000000c58 <botlish_fn_11: local_char?<UnicodeChar>>:
     c58:	push   rbp
     c59:	mov    rbp,rsp
     c5c:	sub    rsp,0x20
     c60:	mov    QWORD PTR [rsp],rbx
     c64:	mov    QWORD PTR [rsp+0x8],r12
     c69:	mov    QWORD PTR [rsp+0x10],r13
     c6e:	mov    rax,rsi
     c71:	shr    rax,0x3
     c75:	mov    r12,rsi
     c78:	cmp    rax,0x80
     c7e:	jb     c94 <botlish_fn_11+0x3c>
     c84:	mov    rbx,rdi
     c87:	mov    rsi,r12
     c8a:	call   c8f <botlish_fn_11+0x37>
			c8b: R_X86_64_PLT32	rt_char_is_tcl_alnum-0x4
     c8f:	jmp    ccb <botlish_fn_11+0x73>
     c94:	mov    rbx,rdi
     c97:	mov    rcx,rax
     c9a:	or     rcx,0x20
     c9e:	add    rcx,0xffffffffffffff9f
     ca5:	cmp    rcx,0x1a
     ca9:	setb   cl
     cac:	add    rax,0xffffffffffffffd0
     cb3:	cmp    rax,0xa
     cb7:	setb   al
     cba:	or     ecx,eax
     cbc:	mov    eax,0x2
     cc1:	test   cl,cl
     cc3:	cmovne rax,QWORD PTR [rip+0x5d]        # d28 <botlish_fn_11+0xd0>
     ccb:	mov    ecx,0x6
     cd0:	mov    r13,rcx
     cd3:	cmp    rax,0x6
     cd7:	je     d0b <botlish_fn_11+0xb3>
     cdd:	mov    rax,QWORD PTR [rbx+0x40]
     ce1:	mov    rsi,QWORD PTR [rax]
     ce4:	mov    rdx,r12
     ce7:	mov    rdi,rbx
     cea:	call   cef <botlish_fn_11+0x97>
			ceb: R_X86_64_PLT32	rt_set_contains-0x4
     cef:	cmp    rax,0x6
     cf3:	je     d03 <botlish_fn_11+0xab>
     cf9:	mov    eax,0x2
     cfe:	jmp    d0e <botlish_fn_11+0xb6>
     d03:	mov    rax,r13
     d06:	jmp    d0e <botlish_fn_11+0xb6>
     d0b:	mov    rax,r13
     d0e:	mov    rbx,QWORD PTR [rsp]
     d12:	mov    r12,QWORD PTR [rsp+0x8]
     d17:	mov    r13,QWORD PTR [rsp+0x10]
     d1c:	add    rsp,0x20
     d20:	mov    rsp,rbp
     d23:	pop    rbp
     d24:	ret
     d25:	add    BYTE PTR [rax],al
     d27:	add    BYTE PTR [rsi],al
     d29:	add    BYTE PTR [rax],al
     d2b:	add    BYTE PTR [rax],al
     d2d:	add    BYTE PTR [rax],al
	...

0000000000000d30 <botlish_entry_11: local_char?<UnicodeChar>>:
     d30:	push   rbp
     d31:	mov    rbp,rsp
     d34:	mov    rsi,QWORD PTR [rdx]
     d37:	call   d3c <botlish_entry_11+0xc>
			d38: R_X86_64_PLT32	botlish_fn_11-0x4 ; local_char?<UnicodeChar>
     d3c:	mov    rsp,rbp
     d3f:	pop    rbp
     d40:	ret
     d41:	add    BYTE PTR [rax],al
     d43:	add    BYTE PTR [rax],al
     d45:	add    BYTE PTR [rax],al
	...

0000000000000d48 <botlish_fn_12: local_char?<generic>>:
     d48:	push   rbp
     d49:	mov    rbp,rsp
     d4c:	sub    rsp,0x20
     d50:	mov    QWORD PTR [rsp],rbx
     d54:	mov    QWORD PTR [rsp+0x8],r12
     d59:	mov    QWORD PTR [rsp+0x10],r13
     d5e:	mov    rax,rsi
     d61:	shr    rax,0x3
     d65:	mov    r12,rsi
     d68:	cmp    rax,0x80
     d6e:	jb     d84 <botlish_fn_12+0x3c>
     d74:	mov    rbx,rdi
     d77:	mov    rsi,r12
     d7a:	call   d7f <botlish_fn_12+0x37>
			d7b: R_X86_64_PLT32	rt_char_is_tcl_alnum-0x4
     d7f:	jmp    dbb <botlish_fn_12+0x73>
     d84:	mov    rbx,rdi
     d87:	mov    rcx,rax
     d8a:	or     rcx,0x20
     d8e:	add    rcx,0xffffffffffffff9f
     d95:	cmp    rcx,0x1a
     d99:	setb   cl
     d9c:	add    rax,0xffffffffffffffd0
     da3:	cmp    rax,0xa
     da7:	setb   al
     daa:	or     ecx,eax
     dac:	mov    eax,0x2
     db1:	test   cl,cl
     db3:	cmovne rax,QWORD PTR [rip+0x5d]        # e18 <botlish_fn_12+0xd0>
     dbb:	mov    ecx,0x6
     dc0:	mov    r13,rcx
     dc3:	cmp    rax,0x6
     dc7:	je     dfb <botlish_fn_12+0xb3>
     dcd:	mov    rax,QWORD PTR [rbx+0x40]
     dd1:	mov    rsi,QWORD PTR [rax]
     dd4:	mov    rdx,r12
     dd7:	mov    rdi,rbx
     dda:	call   ddf <botlish_fn_12+0x97>
			ddb: R_X86_64_PLT32	rt_set_contains-0x4
     ddf:	cmp    rax,0x6
     de3:	je     df3 <botlish_fn_12+0xab>
     de9:	mov    eax,0x2
     dee:	jmp    dfe <botlish_fn_12+0xb6>
     df3:	mov    rax,r13
     df6:	jmp    dfe <botlish_fn_12+0xb6>
     dfb:	mov    rax,r13
     dfe:	mov    rbx,QWORD PTR [rsp]
     e02:	mov    r12,QWORD PTR [rsp+0x8]
     e07:	mov    r13,QWORD PTR [rsp+0x10]
     e0c:	add    rsp,0x20
     e10:	mov    rsp,rbp
     e13:	pop    rbp
     e14:	ret
     e15:	add    BYTE PTR [rax],al
     e17:	add    BYTE PTR [rsi],al
     e19:	add    BYTE PTR [rax],al
     e1b:	add    BYTE PTR [rax],al
     e1d:	add    BYTE PTR [rax],al
	...

0000000000000e20 <botlish_entry_12: local_char?<generic>>:
     e20:	push   rbp
     e21:	mov    rbp,rsp
     e24:	mov    rsi,QWORD PTR [rdx]
     e27:	call   e2c <botlish_entry_12+0xc>
			e28: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<generic>
     e2c:	mov    rsp,rbp
     e2f:	pop    rbp
     e30:	ret
     e31:	add    BYTE PTR [rax],al
     e33:	add    BYTE PTR [rax],al
     e35:	add    BYTE PTR [rax],al
	...

0000000000000e38 <botlish_fn_13: label_char?<UnicodeChar>>:
     e38:	push   rbp
     e39:	mov    rbp,rsp
     e3c:	sub    rsp,0x10
     e40:	mov    QWORD PTR [rsp],rbx
     e44:	mov    rax,rsi
     e47:	shr    rax,0x3
     e4b:	cmp    rax,0x80
     e51:	jb     e64 <botlish_fn_13+0x2c>
     e57:	mov    rbx,rsi
     e5a:	call   e5f <botlish_fn_13+0x27>
			e5b: R_X86_64_PLT32	rt_char_is_tcl_alnum-0x4
     e5f:	jmp    e9b <botlish_fn_13+0x63>
     e64:	mov    rbx,rsi
     e67:	mov    rcx,rax
     e6a:	or     rcx,0x20
     e6e:	add    rcx,0xffffffffffffff9f
     e75:	cmp    rcx,0x1a
     e79:	setb   cl
     e7c:	add    rax,0xffffffffffffffd0
     e83:	cmp    rax,0xa
     e87:	setb   al
     e8a:	or     ecx,eax
     e8c:	mov    eax,0x2
     e91:	test   cl,cl
     e93:	cmovne rax,QWORD PTR [rip+0x45]        # ee0 <botlish_fn_13+0xa8>
     e9b:	mov    ecx,0x6
     ea0:	cmp    rax,0x6
     ea4:	je     ec9 <botlish_fn_13+0x91>
     eaa:	cmp    rbx,0x16c
     eb1:	je     ec1 <botlish_fn_13+0x89>
     eb7:	mov    eax,0x2
     ebc:	jmp    ecc <botlish_fn_13+0x94>
     ec1:	mov    rax,rcx
     ec4:	jmp    ecc <botlish_fn_13+0x94>
     ec9:	mov    rax,rcx
     ecc:	mov    rbx,QWORD PTR [rsp]
     ed0:	add    rsp,0x10
     ed4:	mov    rsp,rbp
     ed7:	pop    rbp
     ed8:	ret
     ed9:	add    BYTE PTR [rax],al
     edb:	add    BYTE PTR [rax],al
     edd:	add    BYTE PTR [rax],al
     edf:	add    BYTE PTR [rsi],al
     ee1:	add    BYTE PTR [rax],al
     ee3:	add    BYTE PTR [rax],al
     ee5:	add    BYTE PTR [rax],al
	...

0000000000000ee8 <botlish_entry_13: label_char?<UnicodeChar>>:
     ee8:	push   rbp
     ee9:	mov    rbp,rsp
     eec:	mov    rsi,QWORD PTR [rdx]
     eef:	call   ef4 <botlish_entry_13+0xc>
			ef0: R_X86_64_PLT32	botlish_fn_13-0x4 ; label_char?<UnicodeChar>
     ef4:	mov    rsp,rbp
     ef7:	pop    rbp
     ef8:	ret

0000000000000ef9 <botlish_fn_14: scan_while<int, block(e272)>>:
     ef9:	push   rbp
     efa:	mov    rbp,rsp
     efd:	sub    rsp,0x40
     f01:	mov    QWORD PTR [rsp+0x10],rbx
     f06:	mov    QWORD PTR [rsp+0x18],r12
     f0b:	mov    QWORD PTR [rsp+0x20],r13
     f10:	mov    QWORD PTR [rsp+0x28],r14
     f15:	mov    QWORD PTR [rsp+0x30],r15
     f1a:	mov    r15,r8
     f1d:	mov    QWORD PTR [rsp],rdi
     f21:	mov    r12,rcx
     f24:	sar    r12,1
     f27:	mov    r14,rcx
     f2a:	mov    rbx,rsi
     f2d:	cmp    rbx,r12
     f30:	jl     f5b <botlish_fn_14+0x62>
     f36:	mov    rax,r14
     f39:	mov    rbx,QWORD PTR [rsp+0x10]
     f3e:	mov    r12,QWORD PTR [rsp+0x18]
     f43:	mov    r13,QWORD PTR [rsp+0x20]
     f48:	mov    r14,QWORD PTR [rsp+0x28]
     f4d:	mov    r15,QWORD PTR [rsp+0x30]
     f52:	add    rsp,0x40
     f56:	mov    rsp,rbp
     f59:	pop    rbp
     f5a:	ret
     f5b:	mov    r13,rbx
     f5e:	shl    r13,1
     f61:	or     r13,0x1
     f65:	mov    rcx,r15
     f68:	mov    rdx,r14
     f6b:	mov    rsi,r13
     f6e:	mov    rdi,QWORD PTR [rsp]
     f72:	call   f77 <botlish_fn_14+0x7e>
			f73: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
     f77:	mov    rsi,rax
     f7a:	mov    rdi,QWORD PTR [rsp]
     f7e:	call   f83 <botlish_fn_14+0x8a>
			f7f: R_X86_64_PLT32	botlish_fn_11-0x4 ; local_char?<UnicodeChar>
     f83:	cmp    rax,0x6
     f87:	je     fb2 <botlish_fn_14+0xb9>
     f8d:	mov    rax,r13
     f90:	mov    rbx,QWORD PTR [rsp+0x10]
     f95:	mov    r12,QWORD PTR [rsp+0x18]
     f9a:	mov    r13,QWORD PTR [rsp+0x20]
     f9f:	mov    r14,QWORD PTR [rsp+0x28]
     fa4:	mov    r15,QWORD PTR [rsp+0x30]
     fa9:	add    rsp,0x40
     fad:	mov    rsp,rbp
     fb0:	pop    rbp
     fb1:	ret
     fb2:	add    rbx,0x1
     fb9:	jmp    f2d <botlish_fn_14+0x34>

0000000000000fbe <botlish_entry_14: scan_while<int, block(e272)>>:
     fbe:	push   rbp
     fbf:	mov    rbp,rsp
     fc2:	mov    rsi,QWORD PTR [rdx]
     fc5:	mov    r9,QWORD PTR [rdx+0x8]
     fc9:	mov    rcx,QWORD PTR [rdx+0x10]
     fcd:	mov    r8,QWORD PTR [rdx+0x18]
     fd1:	sar    rsi,1
     fd4:	mov    rdx,r9
     fd7:	call   fdc <botlish_entry_14+0x1e>
			fd8: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<int, block(e272)>
     fdc:	mov    rsp,rbp
     fdf:	pop    rbp
     fe0:	ret
     fe1:	add    BYTE PTR [rax],al
     fe3:	add    BYTE PTR [rax],al
     fe5:	add    BYTE PTR [rax],al
	...

0000000000000fe8 <botlish_fn_15: scan_while<int, native(std::char::is_tcl_alpha)>>:
     fe8:	push   rbp
     fe9:	mov    rbp,rsp
     fec:	sub    rsp,0x30
     ff0:	mov    QWORD PTR [rsp],rbx
     ff4:	mov    QWORD PTR [rsp+0x8],r12
     ff9:	mov    QWORD PTR [rsp+0x10],r13
     ffe:	mov    QWORD PTR [rsp+0x18],r14
    1003:	mov    QWORD PTR [rsp+0x20],r15
    1008:	mov    rbx,r8
    100b:	mov    r13,rdi
    100e:	mov    rax,rcx
    1011:	sar    rax,1
    1014:	mov    r12,rcx
    1017:	mov    r14,rax
    101a:	mov    rax,rsi
    101d:	mov    rcx,r14
    1020:	cmp    rax,rcx
    1023:	mov    r14,rcx
    1026:	jl     1050 <botlish_fn_15+0x68>
    102c:	mov    rax,r14
    102f:	mov    rbx,QWORD PTR [rsp]
    1033:	mov    r12,QWORD PTR [rsp+0x8]
    1038:	mov    r13,QWORD PTR [rsp+0x10]
    103d:	mov    r14,QWORD PTR [rsp+0x18]
    1042:	mov    r15,QWORD PTR [rsp+0x20]
    1047:	add    rsp,0x30
    104b:	mov    rsp,rbp
    104e:	pop    rbp
    104f:	ret
    1050:	mov    rsi,rax
    1053:	shl    rsi,1
    1056:	mov    r15,rax
    1059:	or     rsi,0x1
    105d:	mov    rcx,rbx
    1060:	mov    rdx,r12
    1063:	mov    rdi,r13
    1066:	call   106b <botlish_fn_15+0x83>
			1067: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    106b:	mov    rcx,rax
    106e:	shr    rcx,0x3
    1072:	cmp    rcx,0x80
    1079:	jb     108f <botlish_fn_15+0xa7>
    107f:	mov    rsi,rax
    1082:	mov    rdi,r13
    1085:	call   108a <botlish_fn_15+0xa2>
			1086: R_X86_64_PLT32	rt_char_is_tcl_alpha-0x4
    108a:	jmp    10ab <botlish_fn_15+0xc3>
    108f:	or     rcx,0x20
    1093:	add    rcx,0xffffffffffffff9f
    109a:	mov    eax,0x2
    109f:	cmp    rcx,0x1a
    10a3:	cmovb  rax,QWORD PTR [rip+0x45]        # 10f0 <botlish_fn_15+0x108>
    10ab:	cmp    rax,0x6
    10af:	je     10d9 <botlish_fn_15+0xf1>
    10b5:	mov    rax,r15
    10b8:	mov    rbx,QWORD PTR [rsp]
    10bc:	mov    r12,QWORD PTR [rsp+0x8]
    10c1:	mov    r13,QWORD PTR [rsp+0x10]
    10c6:	mov    r14,QWORD PTR [rsp+0x18]
    10cb:	mov    r15,QWORD PTR [rsp+0x20]
    10d0:	add    rsp,0x30
    10d4:	mov    rsp,rbp
    10d7:	pop    rbp
    10d8:	ret
    10d9:	mov    rax,r15
    10dc:	add    rax,0x1
    10e3:	mov    rcx,r14
    10e6:	jmp    1020 <botlish_fn_15+0x38>
    10eb:	add    BYTE PTR [rax],al
    10ed:	add    BYTE PTR [rax],al
    10ef:	add    BYTE PTR [rsi],al
    10f1:	add    BYTE PTR [rax],al
    10f3:	add    BYTE PTR [rax],al
    10f5:	add    BYTE PTR [rax],al
	...

00000000000010f8 <botlish_entry_15: scan_while<int, native(std::char::is_tcl_alpha)>>:
    10f8:	push   rbp
    10f9:	mov    rbp,rsp
    10fc:	mov    rsi,QWORD PTR [rdx]
    10ff:	mov    r10,QWORD PTR [rdx+0x8]
    1103:	mov    rcx,QWORD PTR [rdx+0x10]
    1107:	mov    r8,QWORD PTR [rdx+0x18]
    110b:	sar    rsi,1
    110e:	mov    rdx,r10
    1111:	call   1116 <botlish_entry_15+0x1e>
			1112: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<int, native(std::char::is_tcl_alpha)>
    1116:	shl    rax,1
    1119:	or     rax,0x1
    111d:	mov    rsp,rbp
    1120:	pop    rbp
    1121:	ret
    1122:	add    BYTE PTR [rax],al
    1124:	add    BYTE PTR [rax],al
	...

0000000000001128 <botlish_fn_16: tld?<int>>:
    1128:	push   rbp
    1129:	mov    rbp,rsp
    112c:	sub    rsp,0x10
    1130:	mov    QWORD PTR [rsp],rbx
    1134:	mov    QWORD PTR [rsp+0x8],r12
    1139:	mov    r12,rdx
    113c:	mov    rax,QWORD PTR [rdi+0x10]
    1140:	mov    rdx,QWORD PTR [rax+0xa0]
    1147:	mov    rbx,rsi
    114a:	mov    r8,rcx
    114d:	mov    rcx,r12
    1150:	call   1155 <botlish_fn_16+0x2d>
			1151: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_while<int, native(std::char::is_tcl_alpha)>
    1155:	mov    rdx,r12
    1158:	sar    rdx,1
    115b:	cmp    rax,rdx
    115e:	je     116e <botlish_fn_16+0x46>
    1164:	mov    eax,0x2
    1169:	jmp    1185 <botlish_fn_16+0x5d>
    116e:	sub    rax,rbx
    1171:	mov    rcx,rax
    1174:	mov    eax,0x2
    1179:	cmp    rcx,0x2
    117d:	cmovge rax,QWORD PTR [rip+0x13]        # 1198 <botlish_fn_16+0x70>
    1185:	mov    rbx,QWORD PTR [rsp]
    1189:	mov    r12,QWORD PTR [rsp+0x8]
    118e:	add    rsp,0x10
    1192:	mov    rsp,rbp
    1195:	pop    rbp
    1196:	ret
    1197:	add    BYTE PTR [rsi],al
    1199:	add    BYTE PTR [rax],al
    119b:	add    BYTE PTR [rax],al
    119d:	add    BYTE PTR [rax],al
	...

00000000000011a0 <botlish_entry_16: tld?<int>>:
    11a0:	push   rbp
    11a1:	mov    rbp,rsp
    11a4:	mov    rsi,QWORD PTR [rdx]
    11a7:	mov    r8,QWORD PTR [rdx+0x8]
    11ab:	mov    rcx,QWORD PTR [rdx+0x10]
    11af:	sar    rsi,1
    11b2:	mov    rdx,r8
    11b5:	call   11ba <botlish_entry_16+0x1a>
			11b6: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<int>
    11ba:	mov    rsp,rbp
    11bd:	pop    rbp
    11be:	ret

00000000000011bf <botlish_fn_17: domain?<int>>:
    11bf:	push   rbp
    11c0:	mov    rbp,rsp
    11c3:	sub    rsp,0x40
    11c7:	mov    QWORD PTR [rsp+0x10],rbx
    11cc:	mov    QWORD PTR [rsp+0x18],r12
    11d1:	mov    QWORD PTR [rsp+0x20],r13
    11d6:	mov    QWORD PTR [rsp+0x28],r14
    11db:	mov    QWORD PTR [rsp+0x30],r15
    11e0:	mov    rbx,rsi
    11e3:	mov    r14,rcx
    11e6:	mov    QWORD PTR [rsp],rdi
    11ea:	mov    r13,rdx
    11ed:	sar    r13,1
    11f0:	mov    r15,rdx
    11f3:	mov    r12,rbx
    11f6:	cmp    r12,r13
    11f9:	jge    12e1 <botlish_fn_17+0x122>
    11ff:	mov    rsi,r12
    1202:	shl    rsi,1
    1205:	or     rsi,0x1
    1209:	mov    QWORD PTR [rsp+0x8],rsi
    120e:	mov    edx,0x174
    1213:	mov    rcx,r15
    1216:	mov    rdi,QWORD PTR [rsp]
    121a:	mov    r8,r14
    121d:	call   1222 <botlish_fn_17+0x63>
			121e: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_is?<int, any>
    1222:	cmp    rax,0x6
    1226:	je     125b <botlish_fn_17+0x9c>
    122c:	mov    rsi,QWORD PTR [rsp+0x8]
    1231:	mov    rcx,r14
    1234:	mov    rdx,r15
    1237:	mov    rdi,QWORD PTR [rsp]
    123b:	call   1240 <botlish_fn_17+0x81>
			123c: R_X86_64_PLT32	botlish_fn_9-0x4 ; char_at<int>
    1240:	mov    rsi,rax
    1243:	mov    rdi,QWORD PTR [rsp]
    1247:	call   124c <botlish_fn_17+0x8d>
			1248: R_X86_64_PLT32	botlish_fn_13-0x4 ; label_char?<UnicodeChar>
    124c:	cmp    rax,0x6
    1250:	jne    12e1 <botlish_fn_17+0x122>
    1256:	jmp    12ae <botlish_fn_17+0xef>
    125b:	cmp    r12,rbx
    125e:	je     12e1 <botlish_fn_17+0x122>
    1264:	mov    rsi,r12
    1267:	sub    rsi,0x1
    126b:	shl    rsi,1
    126e:	or     rsi,0x1
    1272:	mov    edx,0x174
    1277:	mov    rcx,r15
    127a:	mov    rdi,QWORD PTR [rsp]
    127e:	mov    r8,r14
    1281:	call   1286 <botlish_fn_17+0xc7>
			1282: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_is?<int, any>
    1286:	cmp    rax,0x6
    128a:	je     12e1 <botlish_fn_17+0x122>
    1290:	lea    rsi,[r12+0x1]
    1295:	mov    rcx,r14
    1298:	mov    rdx,r15
    129b:	mov    rdi,QWORD PTR [rsp]
    129f:	call   12a4 <botlish_fn_17+0xe5>
			12a0: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld?<int>
    12a4:	cmp    rax,0x6
    12a8:	je     12ba <botlish_fn_17+0xfb>
    12ae:	add    r12,0x1
    12b5:	jmp    11f6 <botlish_fn_17+0x37>
    12ba:	mov    eax,0x6
    12bf:	mov    rbx,QWORD PTR [rsp+0x10]
    12c4:	mov    r12,QWORD PTR [rsp+0x18]
    12c9:	mov    r13,QWORD PTR [rsp+0x20]
    12ce:	mov    r14,QWORD PTR [rsp+0x28]
    12d3:	mov    r15,QWORD PTR [rsp+0x30]
    12d8:	add    rsp,0x40
    12dc:	mov    rsp,rbp
    12df:	pop    rbp
    12e0:	ret
    12e1:	mov    eax,0x2
    12e6:	mov    rbx,QWORD PTR [rsp+0x10]
    12eb:	mov    r12,QWORD PTR [rsp+0x18]
    12f0:	mov    r13,QWORD PTR [rsp+0x20]
    12f5:	mov    r14,QWORD PTR [rsp+0x28]
    12fa:	mov    r15,QWORD PTR [rsp+0x30]
    12ff:	add    rsp,0x40
    1303:	mov    rsp,rbp
    1306:	pop    rbp
    1307:	ret

0000000000001308 <botlish_entry_17: domain?<int>>:
    1308:	push   rbp
    1309:	mov    rbp,rsp
    130c:	mov    rsi,QWORD PTR [rdx]
    130f:	mov    r8,QWORD PTR [rdx+0x8]
    1313:	mov    rcx,QWORD PTR [rdx+0x10]
    1317:	sar    rsi,1
    131a:	mov    rdx,r8
    131d:	call   1322 <botlish_entry_17+0x1a>
			131e: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain?<int>
    1322:	mov    rsp,rbp
    1325:	pop    rbp
    1326:	ret

0000000000001327 <botlish_fn_18: std::web::is_unreserved<int>>:
    1327:	push   rbp
    1328:	mov    rbp,rsp
    132b:	sub    rsp,0x10
    132f:	mov    QWORD PTR [rsp],rbx
    1333:	mov    QWORD PTR [rsp+0x8],r14
    1338:	mov    r14,rsi
    133b:	mov    rsi,r14
    133e:	sar    rsi,1
    1341:	mov    rbx,rdi
    1344:	call   1349 <botlish_fn_18+0x22>
			1345: R_X86_64_PLT32	botlish_fn_7-0x4 ; std::ascii::is_alphanumeric<int>
    1349:	cmp    rax,0x6
    134d:	je     1384 <botlish_fn_18+0x5d>
    1353:	mov    rax,QWORD PTR [rbx+0x40]
    1357:	mov    rsi,QWORD PTR [rax+0x10]
    135b:	mov    rdx,r14
    135e:	mov    rdi,rbx
    1361:	call   1366 <botlish_fn_18+0x3f>
			1362: R_X86_64_PLT32	rt_set_contains-0x4
    1366:	cmp    rax,0x6
    136a:	je     137a <botlish_fn_18+0x53>
    1370:	mov    eax,0x2
    1375:	jmp    1389 <botlish_fn_18+0x62>
    137a:	mov    eax,0x6
    137f:	jmp    1389 <botlish_fn_18+0x62>
    1384:	mov    eax,0x6
    1389:	mov    rbx,QWORD PTR [rsp]
    138d:	mov    r14,QWORD PTR [rsp+0x8]
    1392:	add    rsp,0x10
    1396:	mov    rsp,rbp
    1399:	pop    rbp
    139a:	ret

000000000000139b <botlish_entry_18: std::web::is_unreserved<int>>:
    139b:	push   rbp
    139c:	mov    rbp,rsp
    139f:	mov    rsi,QWORD PTR [rdx]
    13a2:	call   13a7 <botlish_entry_18+0xc>
			13a3: R_X86_64_PLT32	botlish_fn_18-0x4 ; std::web::is_unreserved<int>
    13a7:	mov    rsp,rbp
    13aa:	pop    rbp
    13ab:	ret

00000000000013ac <botlish_fn_19: std::web::uri_query_value?<str>>:
    13ac:	push   rbp
    13ad:	mov    rbp,rsp
    13b0:	sub    rsp,0x10
    13b4:	mov    QWORD PTR [rsp],rsi
    13b8:	mov    rdx,rsi
    13bb:	mov    esi,0x1
    13c0:	mov    QWORD PTR [rsp+0x8],0x1
    13c9:	call   13ce <botlish_fn_19+0x22>
			13ca: R_X86_64_PLT32	botlish_fn_21-0x4 ; valid_from?<int>
    13ce:	add    rsp,0x10
    13d2:	mov    rsp,rbp
    13d5:	pop    rbp
    13d6:	ret

00000000000013d7 <botlish_entry_19: std::web::uri_query_value?<str>>:
    13d7:	push   rbp
    13d8:	mov    rbp,rsp
    13db:	mov    rsi,QWORD PTR [rdx]
    13de:	call   13e3 <botlish_entry_19+0xc>
			13df: R_X86_64_PLT32	botlish_fn_19-0x4 ; std::web::uri_query_value?<str>
    13e3:	mov    rsp,rbp
    13e6:	pop    rbp
    13e7:	ret

00000000000013e8 <botlish_fn_20: upper_hex?<int>>:
    13e8:	push   rbp
    13e9:	mov    rbp,rsp
    13ec:	sub    rsp,0x20
    13f0:	mov    QWORD PTR [rsp],rbx
    13f4:	mov    QWORD PTR [rsp+0x8],r12
    13f9:	mov    QWORD PTR [rsp+0x10],r13
    13fe:	mov    r12,rdi
    1401:	mov    r13,rdx
    1404:	mov    rdx,r13
    1407:	mov    rdx,QWORD PTR [rdx+0x8]
    140b:	shl    rdx,1
    140e:	mov    rax,rdx
    1411:	or     rax,0x1
    1415:	mov    rcx,rsi
    1418:	and    rcx,rax
    141b:	test   rcx,0x1
    1422:	jne    144f <botlish_fn_20+0x67>
    1428:	or     rdx,0x1
    142c:	mov    rbx,rsi
    142f:	mov    rdi,r12
    1432:	call   1437 <botlish_fn_20+0x4f>
			1433: R_X86_64_PLT32	rt_int_cmp-0x4
    1437:	mov    ecx,0x2
    143c:	test   rax,rax
    143f:	cmovge rcx,QWORD PTR [rip+0xf9]        # 1540 <botlish_fn_20+0x158>
    1447:	mov    rsi,rbx
    144a:	jmp    1466 <botlish_fn_20+0x7e>
    144f:	mov    rbx,rsi
    1452:	or     rdx,0x1
    1456:	mov    ecx,0x2
    145b:	cmp    rbx,rdx
    145e:	cmovge rcx,QWORD PTR [rip+0xda]        # 1540 <botlish_fn_20+0x158>
    1466:	mov    eax,0x6
    146b:	mov    rbx,rax
    146e:	cmp    rcx,0x6
    1472:	je     1524 <botlish_fn_20+0x13c>
    1478:	mov    rdx,r13
    147b:	movzx  rax,BYTE PTR [rdx+0x18]
    1480:	test   rax,rax
    1483:	jne    149c <botlish_fn_20+0xb4>
    1489:	mov    rdx,rsi
    148c:	mov    rsi,r13
    148f:	mov    rdi,r12
    1492:	call   1497 <botlish_fn_20+0xaf>
			1493: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    1497:	jmp    14b6 <botlish_fn_20+0xce>
    149c:	mov    rdx,rsi
    149f:	mov    rsi,r13
    14a2:	mov    rax,rdx
    14a5:	sar    rax,1
    14a8:	movzx  rax,BYTE PTR [rsi+rax*1+0x19]
    14ae:	shl    rax,0x3
    14b2:	or     rax,0x4
    14b6:	shr    rax,0x3
    14ba:	shl    rax,1
    14bd:	or     rax,0x1
    14c1:	sar    rax,1
    14c4:	cmp    rax,0x7f
    14c8:	mov    r13,rax
    14cb:	jle    14de <botlish_fn_20+0xf6>
    14d1:	mov    eax,0x2
    14d6:	mov    rbx,rax
    14d9:	jmp    1529 <botlish_fn_20+0x141>
    14de:	mov    rdi,r12
    14e1:	mov    rsi,r13
    14e4:	call   14e9 <botlish_fn_20+0x101>
			14e5: R_X86_64_PLT32	botlish_fn_3-0x4 ; std::ascii::is_digit<int>
    14e9:	cmp    rax,0x6
    14ed:	jne    14fb <botlish_fn_20+0x113>
    14f3:	mov    rax,rbx
    14f6:	jmp    1529 <botlish_fn_20+0x141>
    14fb:	mov    rax,r13
    14fe:	cmp    rax,0x41
    1502:	jl     151a <botlish_fn_20+0x132>
    1508:	cmp    rax,0x46
    150c:	jg     151a <botlish_fn_20+0x132>
    1512:	mov    rax,rbx
    1515:	jmp    1529 <botlish_fn_20+0x141>
    151a:	mov    eax,0x2
    151f:	jmp    1529 <botlish_fn_20+0x141>
    1524:	mov    eax,0x2
    1529:	mov    rbx,QWORD PTR [rsp]
    152d:	mov    r12,QWORD PTR [rsp+0x8]
    1532:	mov    r13,QWORD PTR [rsp+0x10]
    1537:	add    rsp,0x20
    153b:	mov    rsp,rbp
    153e:	pop    rbp
    153f:	ret
    1540:	(bad)
    1541:	add    BYTE PTR [rax],al
    1543:	add    BYTE PTR [rax],al
    1545:	add    BYTE PTR [rax],al
	...

0000000000001548 <botlish_entry_20: upper_hex?<int>>:
    1548:	push   rbp
    1549:	mov    rbp,rsp
    154c:	mov    rsi,QWORD PTR [rdx]
    154f:	mov    rdx,QWORD PTR [rdx+0x8]
    1553:	call   1558 <botlish_entry_20+0x10>
			1554: R_X86_64_PLT32	botlish_fn_20-0x4 ; upper_hex?<int>
    1558:	mov    rsp,rbp
    155b:	pop    rbp
    155c:	ret
    155d:	add    BYTE PTR [rax],al
	...

0000000000001560 <botlish_fn_21: valid_from?<int>>:
    1560:	push   rbp
    1561:	mov    rbp,rsp
    1564:	sub    rsp,0x40
    1568:	mov    QWORD PTR [rsp+0x20],rbx
    156d:	mov    QWORD PTR [rsp+0x28],r12
    1572:	mov    QWORD PTR [rsp+0x30],r13
    1577:	mov    r12,rdi
    157a:	mov    QWORD PTR [rsp],rsi
    157e:	mov    r13,rsi
    1581:	mov    QWORD PTR [rsp+0x8],rdx
    1586:	mov    rbx,rdx
    1589:	mov    rdx,QWORD PTR [rbx+0x8]
    158d:	shl    rdx,1
    1590:	or     rdx,0x1
    1594:	mov    rsi,r13
    1597:	mov    rax,rsi
    159a:	and    rax,rdx
    159d:	test   rax,0x1
    15a3:	jne    15c9 <botlish_fn_21+0x69>
    15a9:	mov    rsi,r13
    15ac:	mov    rdi,r12
    15af:	call   15b4 <botlish_fn_21+0x54>
			15b0: R_X86_64_PLT32	rt_int_cmp-0x4
    15b4:	mov    ecx,0x2
    15b9:	test   rax,rax
    15bc:	cmovge rcx,QWORD PTR [rip+0x1dc]        # 17a0 <botlish_fn_21+0x240>
    15c4:	jmp    15dc <botlish_fn_21+0x7c>
    15c9:	mov    ecx,0x2
    15ce:	mov    rsi,r13
    15d1:	cmp    rsi,rdx
    15d4:	cmovge rcx,QWORD PTR [rip+0x1c4]        # 17a0 <botlish_fn_21+0x240>
    15dc:	cmp    rcx,0x6
    15e0:	je     177f <botlish_fn_21+0x21f>
    15e6:	movzx  rax,BYTE PTR [rbx+0x18]
    15eb:	test   rax,rax
    15ee:	jne    160a <botlish_fn_21+0xaa>
    15f4:	mov    rdx,r13
    15f7:	mov    rsi,rbx
    15fa:	mov    rdi,r12
    15fd:	call   1602 <botlish_fn_21+0xa2>
			15fe: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    1602:	mov    rsi,rax
    1605:	jmp    1621 <botlish_fn_21+0xc1>
    160a:	mov    rsi,r13
    160d:	mov    rax,rsi
    1610:	sar    rax,1
    1613:	movzx  rsi,BYTE PTR [rbx+rax*1+0x19]
    1619:	shl    rsi,0x3
    161d:	or     rsi,0x4
    1621:	cmp    rsi,0x12c
    1628:	je     1689 <botlish_fn_21+0x129>
    162e:	shr    rsi,0x3
    1632:	shl    rsi,1
    1635:	or     rsi,0x1
    1639:	mov    rdi,rsi
    163c:	sar    rdi,1
    163f:	cmp    rdi,0x7f
    1643:	jg     1705 <botlish_fn_21+0x1a5>
    1649:	mov    rdi,r12
    164c:	call   1651 <botlish_fn_21+0xf1>
			164d: R_X86_64_PLT32	botlish_fn_18-0x4 ; std::web::is_unreserved<int>
    1651:	cmp    rax,0x6
    1655:	jne    1705 <botlish_fn_21+0x1a5>
    165b:	mov    rsi,r13
    165e:	sar    rsi,1
    1661:	mov    r13,rsi
    1664:	add    rsi,0x1
    166b:	mov    r13,rsi
    166e:	shl    rsi,1
    1671:	mov    r13,rsi
    1674:	or     rsi,0x1
    1678:	mov    r13,rsi
    167b:	mov    QWORD PTR [rsp],rsi
    167f:	mov    QWORD PTR [rsp+0x8],rbx
    1684:	jmp    1589 <botlish_fn_21+0x29>
    1689:	mov    rsi,r13
    168c:	mov    rax,rsi
    168f:	sar    rax,1
    1692:	lea    rsi,[rax+0x1]
    1696:	shl    rsi,1
    1699:	or     rsi,0x1
    169d:	mov    rdx,rbx
    16a0:	mov    rdi,r12
    16a3:	call   16a8 <botlish_fn_21+0x148>
			16a4: R_X86_64_PLT32	botlish_fn_20-0x4 ; upper_hex?<int>
    16a8:	cmp    rax,0x6
    16ac:	jne    1705 <botlish_fn_21+0x1a5>
    16b2:	mov    QWORD PTR [rsp+0x10],0x5
    16bb:	mov    rsi,r13
    16be:	test   rsi,0x1
    16c5:	je     16dd <botlish_fn_21+0x17d>
    16cb:	mov    rsi,r13
    16ce:	add    rsi,0x4
    16d2:	seto   al
    16d5:	test   al,al
    16d7:	je     16f0 <botlish_fn_21+0x190>
    16dd:	mov    edx,0x5
    16e2:	mov    rsi,r13
    16e5:	mov    rdi,r12
    16e8:	call   16ed <botlish_fn_21+0x18d>
			16e9: R_X86_64_PLT32	rt_int_add-0x4
    16ed:	mov    rsi,rax
    16f0:	mov    rdx,rbx
    16f3:	mov    rdi,r12
    16f6:	call   16fb <botlish_fn_21+0x19b>
			16f7: R_X86_64_PLT32	botlish_fn_20-0x4 ; upper_hex?<int>
    16fb:	cmp    rax,0x6
    16ff:	je     1722 <botlish_fn_21+0x1c2>
    1705:	mov    eax,0x2
    170a:	mov    rbx,QWORD PTR [rsp+0x20]
    170f:	mov    r12,QWORD PTR [rsp+0x28]
    1714:	mov    r13,QWORD PTR [rsp+0x30]
    1719:	add    rsp,0x40
    171d:	mov    rsp,rbp
    1720:	pop    rbp
    1721:	ret
    1722:	mov    QWORD PTR [rsp+0x10],0x7
    172b:	mov    rsi,r13
    172e:	test   rsi,0x1
    1735:	je     175b <botlish_fn_21+0x1fb>
    173b:	mov    rsi,r13
    173e:	mov    rcx,rsi
    1741:	add    rcx,0x6
    1745:	seto   al
    1748:	test   al,al
    174a:	jne    175b <botlish_fn_21+0x1fb>
    1750:	mov    rsi,rcx
    1753:	mov    r13,rcx
    1756:	jmp    1771 <botlish_fn_21+0x211>
    175b:	mov    edx,0x7
    1760:	mov    rsi,r13
    1763:	mov    rdi,r12
    1766:	call   176b <botlish_fn_21+0x20b>
			1767: R_X86_64_PLT32	rt_int_add-0x4
    176b:	mov    rsi,rax
    176e:	mov    r13,rax
    1771:	mov    QWORD PTR [rsp],rsi
    1775:	mov    QWORD PTR [rsp+0x8],rbx
    177a:	jmp    1589 <botlish_fn_21+0x29>
    177f:	mov    eax,0x6
    1784:	mov    rbx,QWORD PTR [rsp+0x20]
    1789:	mov    r12,QWORD PTR [rsp+0x28]
    178e:	mov    r13,QWORD PTR [rsp+0x30]
    1793:	add    rsp,0x40
    1797:	mov    rsp,rbp
    179a:	pop    rbp
    179b:	ret
    179c:	add    BYTE PTR [rax],al
    179e:	add    BYTE PTR [rax],al
    17a0:	(bad)
    17a1:	add    BYTE PTR [rax],al
    17a3:	add    BYTE PTR [rax],al
    17a5:	add    BYTE PTR [rax],al
	...

00000000000017a8 <botlish_entry_21: valid_from?<int>>:
    17a8:	push   rbp
    17a9:	mov    rbp,rsp
    17ac:	mov    rsi,QWORD PTR [rdx]
    17af:	mov    rdx,QWORD PTR [rdx+0x8]
    17b3:	call   17b8 <botlish_entry_21+0x10>
			17b4: R_X86_64_PLT32	botlish_fn_21-0x4 ; valid_from?<int>
    17b8:	mov    rsp,rbp
    17bb:	pop    rbp
    17bc:	ret

00000000000017bd <botlish_fn_22: std::web::uri_escape_text<str>>:
    17bd:	push   rbp
    17be:	mov    rbp,rsp
    17c1:	sub    rsp,0x10
    17c5:	mov    edx,0x1
    17ca:	mov    QWORD PTR [rsp],0x1
    17d2:	mov    r10,QWORD PTR [rdi+0x10]
    17d6:	mov    rcx,QWORD PTR [r10+0xa8]
    17dd:	mov    QWORD PTR [rsp+0x8],rcx
    17e2:	call   17e7 <botlish_fn_22+0x2a>
			17e3: R_X86_64_PLT32	botlish_fn_28-0x4 ; esc_from<str, int, str>
    17e7:	test   rax,rax
    17ea:	jne    17fc <botlish_fn_22+0x3f>
    17f0:	xor    rax,rax
    17f3:	add    rsp,0x10
    17f7:	mov    rsp,rbp
    17fa:	pop    rbp
    17fb:	ret
    17fc:	add    rsp,0x10
    1800:	mov    rsp,rbp
    1803:	pop    rbp
    1804:	ret

0000000000001805 <botlish_entry_22: std::web::uri_escape_text<str>>:
    1805:	push   rbp
    1806:	mov    rbp,rsp
    1809:	sub    rsp,0x10
    180d:	mov    QWORD PTR [rsp],r12
    1811:	mov    r12,rdi
    1814:	mov    rsi,QWORD PTR [rdx]
    1817:	mov    r8,QWORD PTR [rip+0x0]        # 181e <botlish_entry_22+0x19>
			181a: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    181e:	call   r8
    1821:	mov    rsi,rax
    1824:	mov    rdi,r12
    1827:	call   182c <botlish_entry_22+0x27>
			1828: R_X86_64_PLT32	botlish_fn_22-0x4 ; std::web::uri_escape_text<str>
    182c:	mov    r12,QWORD PTR [rsp]
    1830:	add    rsp,0x10
    1834:	mov    rsp,rbp
    1837:	pop    rbp
    1838:	ret

0000000000001839 <botlish_fn_23: high_nibble<int>>:
    1839:	push   rbp
    183a:	mov    rbp,rsp
    183d:	and    rsi,0xf0
    1844:	sar    rsi,0x4
    1848:	shl    rsi,1
    184b:	mov    rax,rsi
    184e:	or     rax,0x1
    1852:	mov    rsp,rbp
    1855:	pop    rbp
    1856:	ret

0000000000001857 <botlish_entry_23: high_nibble<int>>:
    1857:	push   rbp
    1858:	mov    rbp,rsp
    185b:	mov    rsi,QWORD PTR [rdx]
    185e:	sar    rsi,1
    1861:	call   1866 <botlish_entry_23+0xf>
			1862: R_X86_64_PLT32	botlish_fn_23-0x4 ; high_nibble<int>
    1866:	mov    rsp,rbp
    1869:	pop    rbp
    186a:	ret

000000000000186b <botlish_fn_24: hex_pair<int>>:
    186b:	push   rbp
    186c:	mov    rbp,rsp
    186f:	sub    rsp,0x50
    1873:	mov    QWORD PTR [rsp+0x30],rbx
    1878:	mov    QWORD PTR [rsp+0x38],r12
    187d:	mov    QWORD PTR [rsp+0x40],r13
    1882:	mov    rax,QWORD PTR [rdi+0x40]
    1886:	mov    r13,QWORD PTR [rax+0x8]
    188a:	mov    rbx,rsi
    188d:	mov    r12,rdi
    1890:	call   1895 <botlish_fn_24+0x2a>
			1891: R_X86_64_PLT32	botlish_fn_23-0x4 ; high_nibble<int>
    1895:	mov    rcx,QWORD PTR [r13+0x10]
    1899:	sar    rax,1
    189c:	mov    rdx,QWORD PTR [rcx+rax*8]
    18a0:	mov    QWORD PTR [rsp],rdx
    18a4:	mov    rax,QWORD PTR [r12+0x40]
    18a9:	mov    rax,QWORD PTR [rax+0x8]
    18ad:	mov    rcx,QWORD PTR [rax+0x10]
    18b1:	and    rbx,0xf
    18b5:	shl    rbx,1
    18b8:	or     rbx,0x1
    18bc:	sar    rbx,1
    18bf:	mov    rsi,QWORD PTR [rcx+rbx*8]
    18c3:	mov    QWORD PTR [rsp+0x8],rsi
    18c8:	lea    rcx,[rsp+0x10]
    18cd:	mov    QWORD PTR [rsp+0x10],0x0
    18d6:	mov    QWORD PTR [rsp+0x18],rdx
    18db:	mov    QWORD PTR [rsp+0x20],0x0
    18e4:	mov    QWORD PTR [rsp+0x28],rsi
    18e9:	mov    esi,0x2
    18ee:	mov    edx,0x4
    18f3:	mov    rdi,r12
    18f6:	call   18fb <botlish_fn_24+0x90>
			18f7: R_X86_64_PLT32	rt_construct-0x4
    18fb:	test   rax,rax
    18fe:	jne    191f <botlish_fn_24+0xb4>
    1904:	xor    rax,rax
    1907:	mov    rbx,QWORD PTR [rsp+0x30]
    190c:	mov    r12,QWORD PTR [rsp+0x38]
    1911:	mov    r13,QWORD PTR [rsp+0x40]
    1916:	add    rsp,0x50
    191a:	mov    rsp,rbp
    191d:	pop    rbp
    191e:	ret
    191f:	mov    rbx,QWORD PTR [rsp+0x30]
    1924:	mov    r12,QWORD PTR [rsp+0x38]
    1929:	mov    r13,QWORD PTR [rsp+0x40]
    192e:	add    rsp,0x50
    1932:	mov    rsp,rbp
    1935:	pop    rbp
    1936:	ret

0000000000001937 <botlish_entry_24: hex_pair<int>>:
    1937:	push   rbp
    1938:	mov    rbp,rsp
    193b:	sub    rsp,0x10
    193f:	mov    QWORD PTR [rsp],r12
    1943:	mov    r12,rdi
    1946:	mov    rsi,QWORD PTR [rdx]
    1949:	sar    rsi,1
    194c:	call   1951 <botlish_entry_24+0x1a>
			194d: R_X86_64_PLT32	botlish_fn_24-0x4 ; hex_pair<int>
    1951:	mov    r8,QWORD PTR [rip+0x0]        # 1958 <botlish_entry_24+0x21>
			1954: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1958:	mov    rsi,rax
    195b:	mov    rdi,r12
    195e:	call   r8
    1961:	mov    r12,QWORD PTR [rsp]
    1965:	add    rsp,0x10
    1969:	mov    rsp,rbp
    196c:	pop    rbp
    196d:	ret

000000000000196e <botlish_fn_25: pct<int>>:
    196e:	push   rbp
    196f:	mov    rbp,rsp
    1972:	sub    rsp,0x40
    1976:	mov    QWORD PTR [rsp+0x30],r12
    197b:	mov    QWORD PTR [rsp+0x38],r13
    1980:	mov    QWORD PTR [rsp+0x8],0x0
    1989:	mov    rax,QWORD PTR [rdi+0x10]
    198d:	mov    r12,rdi
    1990:	mov    r13,QWORD PTR [rax+0xb0]
    1997:	mov    QWORD PTR [rsp],r13
    199b:	call   19a0 <botlish_fn_25+0x32>
			199c: R_X86_64_PLT32	botlish_fn_24-0x4 ; hex_pair<int>
    19a0:	test   rax,rax
    19a3:	je     19ea <botlish_fn_25+0x7c>
    19a9:	mov    QWORD PTR [rsp+0x8],rax
    19ae:	lea    rcx,[rsp+0x10]
    19b3:	mov    QWORD PTR [rsp+0x10],0x0
    19bc:	mov    QWORD PTR [rsp+0x18],r13
    19c1:	mov    QWORD PTR [rsp+0x20],0x0
    19ca:	mov    QWORD PTR [rsp+0x28],rax
    19cf:	mov    esi,0x2
    19d4:	mov    edx,0x4
    19d9:	mov    rdi,r12
    19dc:	call   19e1 <botlish_fn_25+0x73>
			19dd: R_X86_64_PLT32	rt_construct-0x4
    19e1:	test   rax,rax
    19e4:	jne    1a00 <botlish_fn_25+0x92>
    19ea:	xor    rax,rax
    19ed:	mov    r12,QWORD PTR [rsp+0x30]
    19f2:	mov    r13,QWORD PTR [rsp+0x38]
    19f7:	add    rsp,0x40
    19fb:	mov    rsp,rbp
    19fe:	pop    rbp
    19ff:	ret
    1a00:	mov    r12,QWORD PTR [rsp+0x30]
    1a05:	mov    r13,QWORD PTR [rsp+0x38]
    1a0a:	add    rsp,0x40
    1a0e:	mov    rsp,rbp
    1a11:	pop    rbp
    1a12:	ret

0000000000001a13 <botlish_entry_25: pct<int>>:
    1a13:	push   rbp
    1a14:	mov    rbp,rsp
    1a17:	sub    rsp,0x10
    1a1b:	mov    QWORD PTR [rsp],r12
    1a1f:	mov    r12,rdi
    1a22:	mov    rsi,QWORD PTR [rdx]
    1a25:	sar    rsi,1
    1a28:	call   1a2d <botlish_entry_25+0x1a>
			1a29: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1a2d:	mov    r8,QWORD PTR [rip+0x0]        # 1a34 <botlish_entry_25+0x21>
			1a30: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1a34:	mov    rsi,rax
    1a37:	mov    rdi,r12
    1a3a:	call   r8
    1a3d:	mov    r12,QWORD PTR [rsp]
    1a41:	add    rsp,0x10
    1a45:	mov    rsp,rbp
    1a48:	pop    rbp
    1a49:	ret

0000000000001a4a <botlish_fn_26: cont<int, int>>:
    1a4a:	push   rbp
    1a4b:	mov    rbp,rsp
    1a4e:	sub    rsp,0x20
    1a52:	mov    QWORD PTR [rsp+0x10],r12
    1a57:	mov    r12,rdi
    1a5a:	mov    QWORD PTR [rsp],rsi
    1a5e:	mov    QWORD PTR [rsp+0x8],rdx
    1a63:	mov    rdi,r12
    1a66:	call   1a6b <botlish_fn_26+0x21>
			1a67: R_X86_64_PLT32	rt_int_shr-0x4
    1a6b:	test   rax,rax
    1a6e:	je     1a96 <botlish_fn_26+0x4c>
    1a74:	sar    rax,1
    1a77:	and    rax,0x3f
    1a7b:	mov    rsi,rax
    1a7e:	or     rsi,0x80
    1a85:	mov    rdi,r12
    1a88:	call   1a8d <botlish_fn_26+0x43>
			1a89: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1a8d:	test   rax,rax
    1a90:	jne    1aa7 <botlish_fn_26+0x5d>
    1a96:	xor    rax,rax
    1a99:	mov    r12,QWORD PTR [rsp+0x10]
    1a9e:	add    rsp,0x20
    1aa2:	mov    rsp,rbp
    1aa5:	pop    rbp
    1aa6:	ret
    1aa7:	mov    r12,QWORD PTR [rsp+0x10]
    1aac:	add    rsp,0x20
    1ab0:	mov    rsp,rbp
    1ab3:	pop    rbp
    1ab4:	ret

0000000000001ab5 <botlish_entry_26: cont<int, int>>:
    1ab5:	push   rbp
    1ab6:	mov    rbp,rsp
    1ab9:	sub    rsp,0x10
    1abd:	mov    QWORD PTR [rsp],r12
    1ac1:	mov    r12,rdi
    1ac4:	mov    rsi,QWORD PTR [rdx]
    1ac7:	mov    rdx,QWORD PTR [rdx+0x8]
    1acb:	call   1ad0 <botlish_entry_26+0x1b>
			1acc: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1ad0:	mov    r8,QWORD PTR [rip+0x0]        # 1ad7 <botlish_entry_26+0x22>
			1ad3: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1ad7:	mov    rsi,rax
    1ada:	mov    rdi,r12
    1add:	call   r8
    1ae0:	mov    r12,QWORD PTR [rsp]
    1ae4:	add    rsp,0x10
    1ae8:	mov    rsp,rbp
    1aeb:	pop    rbp
    1aec:	ret

0000000000001aed <botlish_fn_27: esc_scalar<int>>:
    1aed:	push   rbp
    1aee:	mov    rbp,rsp
    1af1:	sub    rsp,0xf0
    1af8:	mov    QWORD PTR [rsp+0xc0],rbx
    1b00:	mov    QWORD PTR [rsp+0xc8],r12
    1b08:	mov    QWORD PTR [rsp+0xd0],r13
    1b10:	mov    QWORD PTR [rsp+0xd8],r14
    1b18:	mov    QWORD PTR [rsp+0xe0],r15
    1b20:	mov    rbx,rdi
    1b23:	mov    r12,rsi
    1b26:	mov    QWORD PTR [rsp+0x8],0x0
    1b2f:	mov    QWORD PTR [rsp+0x10],0x0
    1b38:	mov    QWORD PTR [rsp+0x18],0x0
    1b41:	mov    QWORD PTR [rsp+0x20],0x0
    1b4a:	mov    QWORD PTR [rsp],rsi
    1b4e:	mov    rsi,r12
    1b51:	mov    rax,rsi
    1b54:	sar    rax,1
    1b57:	cmp    rax,0x800
    1b5d:	jl     1d5d <botlish_fn_27+0x270>
    1b63:	cmp    rax,0x10000
    1b69:	jl     1c8b <botlish_fn_27+0x19e>
    1b6f:	mov    rsi,r12
    1b72:	sar    rsi,0x13
    1b76:	or     rsi,0xf0
    1b7d:	mov    rdi,rbx
    1b80:	call   1b85 <botlish_fn_27+0x98>
			1b81: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1b85:	test   rax,rax
    1b88:	je     1de9 <botlish_fn_27+0x2fc>
    1b8e:	mov    QWORD PTR [rsp+0x8],rax
    1b93:	mov    r13,rax
    1b96:	mov    edx,0x19
    1b9b:	mov    QWORD PTR [rsp+0x10],0x19
    1ba4:	mov    rsi,r12
    1ba7:	mov    rdi,rbx
    1baa:	call   1baf <botlish_fn_27+0xc2>
			1bab: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1baf:	test   rax,rax
    1bb2:	je     1de9 <botlish_fn_27+0x2fc>
    1bb8:	mov    QWORD PTR [rsp+0x10],rax
    1bbd:	mov    r14,rax
    1bc0:	mov    edx,0xd
    1bc5:	mov    QWORD PTR [rsp+0x18],0xd
    1bce:	mov    rsi,r12
    1bd1:	mov    rdi,rbx
    1bd4:	call   1bd9 <botlish_fn_27+0xec>
			1bd5: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1bd9:	test   rax,rax
    1bdc:	je     1de9 <botlish_fn_27+0x2fc>
    1be2:	mov    QWORD PTR [rsp+0x18],rax
    1be7:	mov    r15,rax
    1bea:	mov    edx,0x1
    1bef:	mov    QWORD PTR [rsp+0x20],0x1
    1bf8:	mov    rsi,r12
    1bfb:	mov    rdi,rbx
    1bfe:	call   1c03 <botlish_fn_27+0x116>
			1bff: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1c03:	test   rax,rax
    1c06:	je     1de9 <botlish_fn_27+0x2fc>
    1c0c:	mov    QWORD PTR [rsp],rax
    1c10:	lea    rcx,[rsp+0x78]
    1c15:	mov    QWORD PTR [rsp+0x78],0x0
    1c1e:	mov    rdx,r13
    1c21:	mov    QWORD PTR [rsp+0x80],rdx
    1c29:	mov    QWORD PTR [rsp+0x88],0x0
    1c35:	mov    rdx,r14
    1c38:	mov    QWORD PTR [rsp+0x90],rdx
    1c40:	mov    QWORD PTR [rsp+0x98],0x0
    1c4c:	mov    rdx,r15
    1c4f:	mov    QWORD PTR [rsp+0xa0],rdx
    1c57:	mov    QWORD PTR [rsp+0xa8],0x0
    1c63:	mov    QWORD PTR [rsp+0xb0],rax
    1c6b:	mov    esi,0x2
    1c70:	mov    edx,0x8
    1c75:	mov    rdi,rbx
    1c78:	call   1c7d <botlish_fn_27+0x190>
			1c79: R_X86_64_PLT32	rt_construct-0x4
    1c7d:	test   rax,rax
    1c80:	je     1de9 <botlish_fn_27+0x2fc>
    1c86:	jmp    1e20 <botlish_fn_27+0x333>
    1c8b:	mov    edx,0xd
    1c90:	mov    rsi,r12
    1c93:	mov    r14,rdx
    1c96:	sar    rsi,0xd
    1c9a:	or     rsi,0xe0
    1ca1:	mov    rdi,rbx
    1ca4:	call   1ca9 <botlish_fn_27+0x1bc>
			1ca5: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1ca9:	test   rax,rax
    1cac:	je     1de9 <botlish_fn_27+0x2fc>
    1cb2:	mov    QWORD PTR [rsp+0x8],rax
    1cb7:	mov    r13,rax
    1cba:	mov    QWORD PTR [rsp+0x10],0xd
    1cc3:	mov    rdx,r14
    1cc6:	mov    rsi,r12
    1cc9:	mov    rdi,rbx
    1ccc:	call   1cd1 <botlish_fn_27+0x1e4>
			1ccd: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1cd1:	test   rax,rax
    1cd4:	je     1de9 <botlish_fn_27+0x2fc>
    1cda:	mov    QWORD PTR [rsp+0x10],rax
    1cdf:	mov    r14,rax
    1ce2:	mov    edx,0x1
    1ce7:	mov    QWORD PTR [rsp+0x18],0x1
    1cf0:	mov    rsi,r12
    1cf3:	mov    rdi,rbx
    1cf6:	call   1cfb <botlish_fn_27+0x20e>
			1cf7: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1cfb:	test   rax,rax
    1cfe:	je     1de9 <botlish_fn_27+0x2fc>
    1d04:	mov    QWORD PTR [rsp],rax
    1d08:	lea    rcx,[rsp+0x48]
    1d0d:	mov    QWORD PTR [rsp+0x48],0x0
    1d16:	mov    r11,r13
    1d19:	mov    QWORD PTR [rsp+0x50],r11
    1d1e:	mov    QWORD PTR [rsp+0x58],0x0
    1d27:	mov    rdx,r14
    1d2a:	mov    QWORD PTR [rsp+0x60],rdx
    1d2f:	mov    QWORD PTR [rsp+0x68],0x0
    1d38:	mov    QWORD PTR [rsp+0x70],rax
    1d3d:	mov    esi,0x2
    1d42:	mov    edx,0x6
    1d47:	mov    rdi,rbx
    1d4a:	call   1d4f <botlish_fn_27+0x262>
			1d4b: R_X86_64_PLT32	rt_construct-0x4
    1d4f:	test   rax,rax
    1d52:	je     1de9 <botlish_fn_27+0x2fc>
    1d58:	jmp    1e20 <botlish_fn_27+0x333>
    1d5d:	mov    rsi,r12
    1d60:	sar    rsi,0x7
    1d64:	or     rsi,0xc0
    1d6b:	mov    rdi,rbx
    1d6e:	call   1d73 <botlish_fn_27+0x286>
			1d6f: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1d73:	test   rax,rax
    1d76:	je     1de9 <botlish_fn_27+0x2fc>
    1d7c:	mov    QWORD PTR [rsp+0x8],rax
    1d81:	mov    r13,rax
    1d84:	mov    edx,0x1
    1d89:	mov    QWORD PTR [rsp+0x10],0x1
    1d92:	mov    rsi,r12
    1d95:	mov    rdi,rbx
    1d98:	call   1d9d <botlish_fn_27+0x2b0>
			1d99: R_X86_64_PLT32	botlish_fn_26-0x4 ; cont<int, int>
    1d9d:	test   rax,rax
    1da0:	je     1de9 <botlish_fn_27+0x2fc>
    1da6:	mov    QWORD PTR [rsp],rax
    1daa:	lea    rcx,[rsp+0x28]
    1daf:	mov    QWORD PTR [rsp+0x28],0x0
    1db8:	mov    rdx,r13
    1dbb:	mov    QWORD PTR [rsp+0x30],rdx
    1dc0:	mov    QWORD PTR [rsp+0x38],0x0
    1dc9:	mov    QWORD PTR [rsp+0x40],rax
    1dce:	mov    esi,0x2
    1dd3:	mov    edx,0x4
    1dd8:	mov    rdi,rbx
    1ddb:	call   1de0 <botlish_fn_27+0x2f3>
			1ddc: R_X86_64_PLT32	rt_construct-0x4
    1de0:	test   rax,rax
    1de3:	jne    1e20 <botlish_fn_27+0x333>
    1de9:	xor    rax,rax
    1dec:	mov    rbx,QWORD PTR [rsp+0xc0]
    1df4:	mov    r12,QWORD PTR [rsp+0xc8]
    1dfc:	mov    r13,QWORD PTR [rsp+0xd0]
    1e04:	mov    r14,QWORD PTR [rsp+0xd8]
    1e0c:	mov    r15,QWORD PTR [rsp+0xe0]
    1e14:	add    rsp,0xf0
    1e1b:	mov    rsp,rbp
    1e1e:	pop    rbp
    1e1f:	ret
    1e20:	mov    rbx,QWORD PTR [rsp+0xc0]
    1e28:	mov    r12,QWORD PTR [rsp+0xc8]
    1e30:	mov    r13,QWORD PTR [rsp+0xd0]
    1e38:	mov    r14,QWORD PTR [rsp+0xd8]
    1e40:	mov    r15,QWORD PTR [rsp+0xe0]
    1e48:	add    rsp,0xf0
    1e4f:	mov    rsp,rbp
    1e52:	pop    rbp
    1e53:	ret

0000000000001e54 <botlish_entry_27: esc_scalar<int>>:
    1e54:	push   rbp
    1e55:	mov    rbp,rsp
    1e58:	sub    rsp,0x10
    1e5c:	mov    QWORD PTR [rsp],r12
    1e60:	mov    r12,rdi
    1e63:	mov    rsi,QWORD PTR [rdx]
    1e66:	call   1e6b <botlish_entry_27+0x17>
			1e67: R_X86_64_PLT32	botlish_fn_27-0x4 ; esc_scalar<int>
    1e6b:	mov    r8,QWORD PTR [rip+0x0]        # 1e72 <botlish_entry_27+0x1e>
			1e6e: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1e72:	mov    rsi,rax
    1e75:	mov    rdi,r12
    1e78:	call   r8
    1e7b:	mov    r12,QWORD PTR [rsp]
    1e7f:	add    rsp,0x10
    1e83:	mov    rsp,rbp
    1e86:	pop    rbp
    1e87:	ret

0000000000001e88 <botlish_fn_28: esc_from<str, int, str>>:
    1e88:	push   rbp
    1e89:	mov    rbp,rsp
    1e8c:	sub    rsp,0x100
    1e93:	mov    QWORD PTR [rsp+0xd0],rbx
    1e9b:	mov    QWORD PTR [rsp+0xd8],r12
    1ea3:	mov    QWORD PTR [rsp+0xe0],r13
    1eab:	mov    QWORD PTR [rsp+0xe8],r14
    1eb3:	mov    QWORD PTR [rsp+0xf0],r15
    1ebb:	mov    QWORD PTR [rsp+0xa0],rdi
    1ec3:	mov    QWORD PTR [rsp+0x8],0x0
    1ecc:	mov    QWORD PTR [rsp+0x10],0x0
    1ed5:	mov    QWORD PTR [rsp+0x18],0x0
    1ede:	mov    QWORD PTR [rsp],rcx
    1ee2:	mov    QWORD PTR [rsp+0xb0],rcx
    1eea:	sar    rdx,1
    1eed:	mov    r15d,0x47
    1ef3:	mov    rcx,0xffffffffffffffff
    1efa:	bsr    rax,rsi
    1efe:	mov    QWORD PTR [rsp+0xa8],rsi
    1f06:	cmove  rax,rcx
    1f0a:	mov    ecx,0x3f
    1f0f:	sub    rcx,rax
    1f12:	sub    r15,rcx
    1f15:	shr    r15,0x3
    1f19:	lea    r12,[rsp+0x80]
    1f21:	mov    QWORD PTR [rsp+0xc8],r12
    1f29:	lea    r13,[rsp+0x50]
    1f2e:	mov    QWORD PTR [rsp+0xc0],r13
    1f36:	lea    rax,[rsp+0x30]
    1f3b:	mov    QWORD PTR [rsp+0xb8],rax
    1f43:	mov    r14,rdx
    1f46:	cmp    r14,r15
    1f49:	jge    2179 <botlish_fn_28+0x2f1>
    1f4f:	mov    rsi,QWORD PTR [rsp+0xa8]
    1f57:	mov    rdi,QWORD PTR [rsp+0xa0]
    1f5f:	call   1f64 <botlish_fn_28+0xdc>
			1f60: R_X86_64_PLT32	rt_ascii_to_str-0x4
    1f64:	mov    QWORD PTR [rsp+0x8],rax
    1f69:	mov    rbx,r14
    1f6c:	shl    rbx,1
    1f6f:	or     rbx,0x1
    1f73:	mov    QWORD PTR [rsp+0x10],rbx
    1f78:	movzx  rdx,BYTE PTR [rax+0x18]
    1f7d:	mov    r13,rax
    1f80:	test   rdx,rdx
    1f83:	jne    1fa4 <botlish_fn_28+0x11c>
    1f89:	mov    rdx,rbx
    1f8c:	mov    rsi,r13
    1f8f:	mov    rdi,QWORD PTR [rsp+0xa0]
    1f97:	call   1f9c <botlish_fn_28+0x114>
			1f98: R_X86_64_PLT32	rt_str_char_at_proven-0x4
    1f9c:	mov    rsi,rax
    1f9f:	jmp    1fb8 <botlish_fn_28+0x130>
    1fa4:	mov    rsi,rbx
    1fa7:	sar    rsi,1
    1faa:	movzx  rsi,BYTE PTR [r13+rsi*1+0x19]
    1fb0:	shl    rsi,0x3
    1fb4:	or     rsi,0x4
    1fb8:	shr    rsi,0x3
    1fbc:	shl    rsi,1
    1fbf:	or     rsi,0x1
    1fc3:	mov    QWORD PTR [rsp+0x18],rsi
    1fc8:	mov    r12,rsi
    1fcb:	sar    r12,1
    1fce:	cmp    r12,0x7f
    1fd2:	jg     20fa <botlish_fn_28+0x272>
    1fd8:	mov    rdi,QWORD PTR [rsp+0xa0]
    1fe0:	call   1fe5 <botlish_fn_28+0x15d>
			1fe1: R_X86_64_PLT32	botlish_fn_18-0x4 ; std::web::is_unreserved<int>
    1fe5:	cmp    rax,0x6
    1fe9:	je     207d <botlish_fn_28+0x1f5>
    1fef:	mov    rsi,r12
    1ff2:	mov    rdi,QWORD PTR [rsp+0xa0]
    1ffa:	call   1fff <botlish_fn_28+0x177>
			1ffb: R_X86_64_PLT32	botlish_fn_25-0x4 ; pct<int>
    1fff:	test   rax,rax
    2002:	je     21b2 <botlish_fn_28+0x32a>
    2008:	mov    QWORD PTR [rsp+0x8],rax
    200d:	mov    QWORD PTR [rsp+0x80],0x0
    2019:	mov    r12,QWORD PTR [rsp+0xb0]
    2021:	mov    QWORD PTR [rsp+0x88],r12
    2029:	mov    QWORD PTR [rsp+0x90],0x0
    2035:	mov    QWORD PTR [rsp+0x98],rax
    203d:	mov    esi,0x2
    2042:	mov    edx,0x4
    2047:	mov    rcx,QWORD PTR [rsp+0xc8]
    204f:	mov    rdi,QWORD PTR [rsp+0xa0]
    2057:	call   205c <botlish_fn_28+0x1d4>
			2058: R_X86_64_PLT32	rt_construct-0x4
    205c:	test   rax,rax
    205f:	je     21b2 <botlish_fn_28+0x32a>
    2065:	mov    QWORD PTR [rsp],rax
    2069:	add    r14,0x1
    2070:	mov    QWORD PTR [rsp+0xb0],rax
    2078:	jmp    1f46 <botlish_fn_28+0xbe>
    207d:	mov    r12,QWORD PTR [rsp+0xb0]
    2085:	add    r14,0x1
    208c:	mov    rcx,r14
    208f:	shl    rcx,1
    2092:	or     rcx,0x1
    2096:	mov    QWORD PTR [rsp+0x18],rcx
    209b:	mov    QWORD PTR [rsp+0x50],0x0
    20a4:	mov    QWORD PTR [rsp+0x58],r12
    20a9:	mov    QWORD PTR [rsp+0x60],0x1
    20b2:	mov    QWORD PTR [rsp+0x68],r13
    20b7:	mov    QWORD PTR [rsp+0x70],rbx
    20bc:	mov    QWORD PTR [rsp+0x78],rcx
    20c1:	mov    esi,0x2
    20c6:	mov    edx,0x6
    20cb:	mov    rcx,QWORD PTR [rsp+0xc0]
    20d3:	mov    rdi,QWORD PTR [rsp+0xa0]
    20db:	call   20e0 <botlish_fn_28+0x258>
			20dc: R_X86_64_PLT32	rt_construct-0x4
    20e0:	test   rax,rax
    20e3:	je     21b2 <botlish_fn_28+0x32a>
    20e9:	mov    QWORD PTR [rsp],rax
    20ed:	mov    QWORD PTR [rsp+0xb0],rax
    20f5:	jmp    1f46 <botlish_fn_28+0xbe>
    20fa:	mov    r12,QWORD PTR [rsp+0xb0]
    2102:	mov    rdi,QWORD PTR [rsp+0xa0]
    210a:	call   210f <botlish_fn_28+0x287>
			210b: R_X86_64_PLT32	botlish_fn_27-0x4 ; esc_scalar<int>
    210f:	test   rax,rax
    2112:	je     21b2 <botlish_fn_28+0x32a>
    2118:	mov    QWORD PTR [rsp+0x8],rax
    211d:	mov    QWORD PTR [rsp+0x30],0x0
    2126:	mov    QWORD PTR [rsp+0x38],r12
    212b:	mov    QWORD PTR [rsp+0x40],0x0
    2134:	mov    QWORD PTR [rsp+0x48],rax
    2139:	mov    esi,0x2
    213e:	mov    edx,0x4
    2143:	mov    rcx,QWORD PTR [rsp+0xb8]
    214b:	mov    rdi,QWORD PTR [rsp+0xa0]
    2153:	call   2158 <botlish_fn_28+0x2d0>
			2154: R_X86_64_PLT32	rt_construct-0x4
    2158:	test   rax,rax
    215b:	je     21b2 <botlish_fn_28+0x32a>
    2161:	mov    QWORD PTR [rsp],rax
    2165:	add    r14,0x1
    216c:	mov    QWORD PTR [rsp+0xb0],rax
    2174:	jmp    1f46 <botlish_fn_28+0xbe>
    2179:	mov    r12,QWORD PTR [rsp+0xb0]
    2181:	xor    rsi,rsi
    2184:	lea    rcx,[rsp+0x20]
    2189:	mov    QWORD PTR [rsp+0x20],0x0
    2192:	mov    QWORD PTR [rsp+0x28],r12
    2197:	mov    edx,0x2
    219c:	mov    rdi,QWORD PTR [rsp+0xa0]
    21a4:	call   21a9 <botlish_fn_28+0x321>
			21a5: R_X86_64_PLT32	rt_construct-0x4
    21a9:	test   rax,rax
    21ac:	jne    21e9 <botlish_fn_28+0x361>
    21b2:	xor    rax,rax
    21b5:	mov    rbx,QWORD PTR [rsp+0xd0]
    21bd:	mov    r12,QWORD PTR [rsp+0xd8]
    21c5:	mov    r13,QWORD PTR [rsp+0xe0]
    21cd:	mov    r14,QWORD PTR [rsp+0xe8]
    21d5:	mov    r15,QWORD PTR [rsp+0xf0]
    21dd:	add    rsp,0x100
    21e4:	mov    rsp,rbp
    21e7:	pop    rbp
    21e8:	ret
    21e9:	mov    rbx,QWORD PTR [rsp+0xd0]
    21f1:	mov    r12,QWORD PTR [rsp+0xd8]
    21f9:	mov    r13,QWORD PTR [rsp+0xe0]
    2201:	mov    r14,QWORD PTR [rsp+0xe8]
    2209:	mov    r15,QWORD PTR [rsp+0xf0]
    2211:	add    rsp,0x100
    2218:	mov    rsp,rbp
    221b:	pop    rbp
    221c:	ret

000000000000221d <botlish_entry_28: esc_from<str, int, str>>:
    221d:	push   rbp
    221e:	mov    rbp,rsp
    2221:	sub    rsp,0x10
    2225:	mov    QWORD PTR [rsp],r12
    2229:	mov    QWORD PTR [rsp+0x8],r13
    222e:	mov    r12,rdi
    2231:	mov    rsi,QWORD PTR [rdx]
    2234:	mov    r13,rdx
    2237:	mov    r8,QWORD PTR [rip+0x0]        # 223e <botlish_entry_28+0x21>
			223a: R_X86_64_GOTPCREL	rt_str_to_ascii-0x4
    223e:	call   r8
    2241:	mov    rcx,r13
    2244:	mov    rdx,QWORD PTR [rcx+0x8]
    2248:	mov    rcx,QWORD PTR [rcx+0x10]
    224c:	mov    rsi,rax
    224f:	mov    rdi,r12
    2252:	call   2257 <botlish_entry_28+0x3a>
			2253: R_X86_64_PLT32	botlish_fn_28-0x4 ; esc_from<str, int, str>
    2257:	mov    r12,QWORD PTR [rsp]
    225b:	mov    r13,QWORD PTR [rsp+0x8]
    2260:	add    rsp,0x10
    2264:	mov    rsp,rbp
    2267:	pop    rbp
    2268:	ret

0000000000002269 <botlish_fn_29: check<int, int, str, str>>:
    2269:	push   rbp
    226a:	mov    rbp,rsp
    226d:	sub    rsp,0x50
    2271:	mov    QWORD PTR [rsp+0x20],rbx
    2276:	mov    QWORD PTR [rsp+0x28],r12
    227b:	mov    QWORD PTR [rsp+0x30],r13
    2280:	mov    QWORD PTR [rsp+0x38],r14
    2285:	mov    QWORD PTR [rsp+0x40],r15
    228a:	mov    r14,rdi
    228d:	mov    QWORD PTR [rsp+0x18],0x0
    2296:	mov    QWORD PTR [rsp],rdx
    229a:	mov    QWORD PTR [rsp+0x8],rcx
    229f:	mov    QWORD PTR [rsp+0x10],r8
    22a4:	mov    r12,r8
    22a7:	mov    r13,rsi
    22aa:	mov    r15,rdx
    22ad:	test   r13,r13
    22b0:	jle    235c <botlish_fn_29+0xf3>
    22b6:	mov    rbx,rcx
    22b9:	mov    rsi,rbx
    22bc:	mov    rdi,r14
    22bf:	call   22c4 <botlish_fn_29+0x5b>
			22c0: R_X86_64_PLT32	botlish_fn_8-0x4 ; std::web::emailish?<str>
    22c4:	cmp    rax,0x6
    22c8:	je     22e4 <botlish_fn_29+0x7b>
    22ce:	mov    edx,0x1
    22d3:	mov    QWORD PTR [rsp+0x18],0x1
    22dc:	mov    rsi,r15
    22df:	jmp    2310 <botlish_fn_29+0xa7>
    22e4:	mov    rsi,r12
    22e7:	mov    rdi,r14
    22ea:	call   22ef <botlish_fn_29+0x86>
			22eb: R_X86_64_PLT32	botlish_fn_19-0x4 ; std::web::uri_query_value?<str>
    22ef:	cmp    rax,0x6
    22f3:	je     2303 <botlish_fn_29+0x9a>
    22f9:	mov    edx,0x1
    22fe:	jmp    2308 <botlish_fn_29+0x9f>
    2303:	mov    edx,0x3
    2308:	mov    QWORD PTR [rsp+0x18],rdx
    230d:	mov    rsi,r15
    2310:	mov    rax,rsi
    2313:	and    rax,rdx
    2316:	test   rax,0x1
    231c:	je     2337 <botlish_fn_29+0xce>
    2322:	lea    rcx,[rdx-0x1]
    2326:	mov    rax,rsi
    2329:	add    rax,rcx
    232c:	seto   cl
    232f:	test   cl,cl
    2331:	je     233f <botlish_fn_29+0xd6>
    2337:	mov    rdi,r14
    233a:	call   233f <botlish_fn_29+0xd6>
			233b: R_X86_64_PLT32	rt_int_add-0x4
    233f:	mov    QWORD PTR [rsp],rax
    2343:	mov    QWORD PTR [rsp+0x8],rbx
    2348:	mov    QWORD PTR [rsp+0x10],r12
    234d:	sub    r13,0x1
    2351:	mov    rcx,rbx
    2354:	mov    r15,rax
    2357:	jmp    22ad <botlish_fn_29+0x44>
    235c:	mov    rax,r15
    235f:	mov    rbx,QWORD PTR [rsp+0x20]
    2364:	mov    r12,QWORD PTR [rsp+0x28]
    2369:	mov    r13,QWORD PTR [rsp+0x30]
    236e:	mov    r14,QWORD PTR [rsp+0x38]
    2373:	mov    r15,QWORD PTR [rsp+0x40]
    2378:	add    rsp,0x50
    237c:	mov    rsp,rbp
    237f:	pop    rbp
    2380:	ret

0000000000002381 <botlish_entry_29: check<int, int, str, str>>:
    2381:	push   rbp
    2382:	mov    rbp,rsp
    2385:	mov    rsi,QWORD PTR [rdx]
    2388:	mov    r9,QWORD PTR [rdx+0x8]
    238c:	mov    rcx,QWORD PTR [rdx+0x10]
    2390:	mov    r8,QWORD PTR [rdx+0x18]
    2394:	sar    rsi,1
    2397:	mov    rdx,r9
    239a:	call   239f <botlish_entry_29+0x1e>
			239b: R_X86_64_PLT32	botlish_fn_29-0x4 ; check<int, int, str, str>
    239f:	mov    rsp,rbp
    23a2:	pop    rbp
    23a3:	ret

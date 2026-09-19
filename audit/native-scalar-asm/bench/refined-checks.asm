; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 25134  (per function: 456 1177 1817 1521 687 1068 694 1124 632 1305 1377 550 603 514 273 625 625 625 681 801 1305 1377 550 603 514 273 625 625 625 681 801)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> web::uri_escape_text<str>
;   botlish_fn_2 / botlish_entry_2 -> high_nibble<generic>
;   botlish_fn_3 / botlish_entry_3 -> is_unreserved<generic>
;   botlish_fn_4 / botlish_entry_4 -> hex_pair<generic>
;   botlish_fn_5 / botlish_entry_5 -> esc_bytes<generic>
;   botlish_fn_6 / botlish_entry_6 -> esc_char<generic>
;   botlish_fn_7 / botlish_entry_7 -> esc_from<generic>
;   botlish_fn_8 / botlish_entry_8 -> check<int, int, str, str>
;   botlish_fn_9 / botlish_entry_9 -> <str>
;   botlish_fn_10 / botlish_entry_10 -> <generic>
;   botlish_fn_11 / botlish_entry_11 -> char_at<generic>
;   botlish_fn_12 / botlish_entry_12 -> char_at<generic>
;   botlish_fn_13 / botlish_entry_13 -> is_local_char<str>
;   botlish_fn_14 / botlish_entry_14 -> is_label_char<str>
;   botlish_fn_15 / botlish_entry_15 -> scan_local<generic>
;   botlish_fn_16 / botlish_entry_16 -> scan_label<generic>
;   botlish_fn_17 / botlish_entry_17 -> scan_alpha<generic>
;   botlish_fn_18 / botlish_entry_18 -> tld_ok<generic>
;   botlish_fn_19 / botlish_entry_19 -> domain_loop<generic>
;   botlish_fn_20 / botlish_entry_20 -> <str>
;   botlish_fn_21 / botlish_entry_21 -> <generic>
;   botlish_fn_22 / botlish_entry_22 -> char_at<generic>
;   botlish_fn_23 / botlish_entry_23 -> char_at<generic>
;   botlish_fn_24 / botlish_entry_24 -> is_local_char<str>
;   botlish_fn_25 / botlish_entry_25 -> is_label_char<str>
;   botlish_fn_26 / botlish_entry_26 -> scan_local<generic>
;   botlish_fn_27 / botlish_entry_27 -> scan_label<generic>
;   botlish_fn_28 / botlish_entry_28 -> scan_alpha<generic>
;   botlish_fn_29 / botlish_entry_29 -> tld_ok<generic>
;   botlish_fn_30 / botlish_entry_30 -> domain_loop<generic>


refined-checks.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x30
       8:	mov    QWORD PTR [rsp+0x10],rbx
       d:	mov    QWORD PTR [rsp+0x18],r12
      12:	mov    QWORD PTR [rsp+0x20],r13
      17:	mov    QWORD PTR [rsp+0x28],r14
      1c:	mov    r12,QWORD PTR [rdi]
      1f:	mov    rax,QWORD PTR [rdi+0x8]
      23:	lea    rcx,[r12+0x28]
      28:	cmp    rcx,rax
      2b:	ja     195 <botlish_fn_0+0x195>
      31:	lea    rax,[r12+0x28]
      36:	mov    QWORD PTR [rdi],rax
      39:	mov    QWORD PTR [r12],0x0
      41:	mov    QWORD PTR [r12+0x8],0x0
      4a:	mov    QWORD PTR [r12+0x10],0x0
      53:	mov    QWORD PTR [r12+0x18],0x0
      5c:	mov    QWORD PTR [r12+0x20],0x0
      65:	mov    rax,QWORD PTR [rdi+0x10]
      69:	mov    r13,rdi
      6c:	mov    rsi,QWORD PTR [rax]
      6f:	mov    QWORD PTR [r12],rsi
      73:	call   78 <botlish_fn_0+0x78>
			74: R_X86_64_PLT32	botlish_fn_1-0x4 ; web::uri_escape_text<str>
      78:	test   rax,rax
      7b:	jne    89 <botlish_fn_0+0x89>
      81:	mov    rdi,r13
      84:	jmp    14c <botlish_fn_0+0x14c>
      89:	mov    QWORD PTR [r12],rax
      8d:	mov    r14,rax
      90:	mov    esi,0x321
      95:	mov    QWORD PTR [r12+0x8],0x321
      9e:	mov    edx,0x1
      a3:	mov    QWORD PTR [r12+0x10],0x1
      ac:	mov    rdi,r13
      af:	mov    rcx,QWORD PTR [rdi+0x10]
      b3:	mov    rcx,QWORD PTR [rcx+0x8]
      b7:	mov    QWORD PTR [r12+0x18],rcx
      bc:	mov    r8,r14
      bf:	call   c4 <botlish_fn_0+0xc4>
			c0: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
      c4:	mov    rbx,rax
      c7:	test   rbx,rbx
      ca:	jne    d8 <botlish_fn_0+0xd8>
      d0:	mov    rdi,r13
      d3:	jmp    14c <botlish_fn_0+0x14c>
      d8:	mov    QWORD PTR [r12+0x8],rbx
      dd:	mov    esi,0x321
      e2:	mov    QWORD PTR [r12+0x10],0x321
      eb:	mov    edx,0x1
      f0:	mov    QWORD PTR [r12+0x18],0x1
      f9:	mov    rdi,r13
      fc:	mov    rax,QWORD PTR [rdi+0x10]
     100:	mov    rcx,QWORD PTR [rax+0x10]
     104:	mov    QWORD PTR [r12+0x20],rcx
     109:	mov    r8,r14
     10c:	call   111 <botlish_fn_0+0x111>
			10d: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
     111:	test   rax,rax
     114:	jne    122 <botlish_fn_0+0x122>
     11a:	mov    rdi,r13
     11d:	jmp    14c <botlish_fn_0+0x14c>
     122:	mov    QWORD PTR [r12],rax
     126:	lea    rdx,[rsp]
     12a:	mov    QWORD PTR [rsp],rbx
     12e:	mov    QWORD PTR [rsp+0x8],rax
     133:	mov    esi,0x2
     138:	mov    rdi,r13
     13b:	call   140 <botlish_fn_0+0x140>
			13c: R_X86_64_PLT32	rt_list_new-0x4
     140:	test   rax,rax
     143:	jne    172 <botlish_fn_0+0x172>
     149:	mov    rdi,r13
     14c:	mov    rdi,r13
     14f:	mov    QWORD PTR [rdi],r12
     152:	xor    rax,rax
     155:	mov    rbx,QWORD PTR [rsp+0x10]
     15a:	mov    r12,QWORD PTR [rsp+0x18]
     15f:	mov    r13,QWORD PTR [rsp+0x20]
     164:	mov    r14,QWORD PTR [rsp+0x28]
     169:	add    rsp,0x30
     16d:	mov    rsp,rbp
     170:	pop    rbp
     171:	ret
     172:	mov    rdi,r13
     175:	mov    QWORD PTR [rdi],r12
     178:	mov    rbx,QWORD PTR [rsp+0x10]
     17d:	mov    r12,QWORD PTR [rsp+0x18]
     182:	mov    r13,QWORD PTR [rsp+0x20]
     187:	mov    r14,QWORD PTR [rsp+0x28]
     18c:	add    rsp,0x30
     190:	mov    rsp,rbp
     193:	pop    rbp
     194:	ret
     195:	mov    r13,rdi
     198:	call   19d <botlish_fn_0+0x19d>
			199: R_X86_64_PLT32	rt_stack_overflow-0x4
     19d:	xor    rax,rax
     1a0:	mov    rbx,QWORD PTR [rsp+0x10]
     1a5:	mov    r12,QWORD PTR [rsp+0x18]
     1aa:	mov    r13,QWORD PTR [rsp+0x20]
     1af:	mov    r14,QWORD PTR [rsp+0x28]
     1b4:	add    rsp,0x30
     1b8:	mov    rsp,rbp
     1bb:	pop    rbp
     1bc:	ret

00000000000001bd <botlish_entry_0: <program entry>>:
     1bd:	push   rbp
     1be:	mov    rbp,rsp
     1c1:	call   1c6 <botlish_entry_0+0x9>
			1c2: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     1c6:	mov    rsp,rbp
     1c9:	pop    rbp
     1ca:	ret

00000000000001cb <botlish_fn_1: web::uri_escape_text<str>>:
     1cb:	push   rbp
     1cc:	mov    rbp,rsp
     1cf:	sub    rsp,0x110
     1d6:	mov    QWORD PTR [rsp+0xe0],rbx
     1de:	mov    QWORD PTR [rsp+0xe8],r12
     1e6:	mov    QWORD PTR [rsp+0xf0],r13
     1ee:	mov    QWORD PTR [rsp+0xf8],r14
     1f6:	mov    QWORD PTR [rsp+0x100],r15
     1fe:	mov    r12,QWORD PTR [rdi]
     201:	mov    r8,QWORD PTR [rdi+0x8]
     205:	lea    r9,[r12+0x88]
     20d:	cmp    r9,r8
     210:	ja     616 <botlish_fn_1+0x44b>
     216:	lea    r8,[r12+0x88]
     21e:	mov    QWORD PTR [rdi],r8
     221:	mov    QWORD PTR [r12],0x0
     229:	mov    QWORD PTR [r12+0x8],0x0
     232:	mov    QWORD PTR [r12+0x10],0x0
     23b:	mov    QWORD PTR [r12+0x18],0x0
     244:	mov    QWORD PTR [r12+0x20],0x0
     24d:	mov    QWORD PTR [r12+0x28],0x0
     256:	mov    QWORD PTR [r12+0x30],0x0
     25f:	mov    QWORD PTR [r12+0x38],0x0
     268:	mov    QWORD PTR [r12+0x40],0x0
     271:	mov    QWORD PTR [r12+0x48],0x0
     27a:	mov    QWORD PTR [r12+0x50],0x0
     283:	mov    QWORD PTR [r12+0x58],0x0
     28c:	mov    QWORD PTR [r12+0x60],0x0
     295:	mov    QWORD PTR [r12+0x68],0x0
     29e:	mov    QWORD PTR [r12+0x70],0x0
     2a7:	mov    QWORD PTR [r12+0x78],0x0
     2b0:	mov    QWORD PTR [r12+0x80],0x0
     2bc:	mov    QWORD PTR [r12],rsi
     2c0:	mov    QWORD PTR [rsp+0xa8],rsi
     2c8:	mov    rax,QWORD PTR [rdi+0x10]
     2cc:	mov    rdx,QWORD PTR [rax+0x18]
     2d0:	mov    QWORD PTR [r12+0x8],rdx
     2d5:	mov    QWORD PTR [rsp+0xd0],rdx
     2dd:	mov    rax,QWORD PTR [rdi+0x10]
     2e1:	mov    rsi,QWORD PTR [rax+0x20]
     2e5:	mov    QWORD PTR [r12+0x10],rsi
     2ea:	mov    QWORD PTR [rsp+0xc8],rsi
     2f2:	mov    rax,QWORD PTR [rdi+0x10]
     2f6:	mov    r8,QWORD PTR [rax+0x28]
     2fa:	mov    QWORD PTR [r12+0x18],r8
     2ff:	mov    QWORD PTR [rsp+0xc0],r8
     307:	mov    rax,QWORD PTR [rdi+0x10]
     30b:	mov    r9,QWORD PTR [rax+0x30]
     30f:	mov    QWORD PTR [r12+0x20],r9
     314:	mov    QWORD PTR [rsp+0xb8],r9
     31c:	mov    rax,QWORD PTR [rdi+0x10]
     320:	mov    r10,QWORD PTR [rax+0x38]
     324:	mov    QWORD PTR [r12+0x28],r10
     329:	mov    QWORD PTR [rsp+0xb0],r10
     331:	mov    rax,QWORD PTR [rdi+0x10]
     335:	mov    r10,QWORD PTR [rax+0x40]
     339:	mov    QWORD PTR [r12+0x30],r10
     33e:	mov    rax,QWORD PTR [rdi+0x10]
     342:	mov    r11,QWORD PTR [rax+0x48]
     346:	mov    QWORD PTR [r12+0x38],r11
     34b:	mov    rax,QWORD PTR [rdi+0x10]
     34f:	mov    rbx,QWORD PTR [rax+0x50]
     353:	mov    QWORD PTR [r12+0x40],rbx
     358:	mov    rax,QWORD PTR [rdi+0x10]
     35c:	mov    rax,QWORD PTR [rax+0x58]
     360:	mov    QWORD PTR [r12+0x48],rax
     365:	mov    rcx,QWORD PTR [rdi+0x10]
     369:	mov    r13,QWORD PTR [rcx+0x60]
     36d:	mov    QWORD PTR [r12+0x50],r13
     372:	mov    rcx,QWORD PTR [rdi+0x10]
     376:	mov    r14,QWORD PTR [rcx+0x68]
     37a:	mov    QWORD PTR [r12+0x58],r14
     37f:	mov    rcx,QWORD PTR [rdi+0x10]
     383:	mov    r15,QWORD PTR [rcx+0x70]
     387:	mov    QWORD PTR [r12+0x60],r15
     38c:	mov    rcx,QWORD PTR [rdi+0x10]
     390:	mov    rcx,QWORD PTR [rcx+0x78]
     394:	mov    QWORD PTR [r12+0x68],rcx
     399:	mov    rdx,QWORD PTR [rdi+0x10]
     39d:	mov    rdx,QWORD PTR [rdx+0x80]
     3a4:	mov    QWORD PTR [r12+0x70],rdx
     3a9:	mov    rsi,QWORD PTR [rdi+0x10]
     3ad:	mov    rsi,QWORD PTR [rsi+0x88]
     3b4:	mov    QWORD PTR [r12+0x78],rsi
     3b9:	mov    r8,QWORD PTR [rdi+0x10]
     3bd:	mov    QWORD PTR [rsp+0xa0],rdi
     3c5:	mov    rdi,QWORD PTR [r8+0x90]
     3cc:	mov    QWORD PTR [r12+0x80],rdi
     3d4:	lea    r8,[rsp]
     3d8:	mov    r9,QWORD PTR [rsp+0xd0]
     3e0:	mov    QWORD PTR [rsp],r9
     3e4:	mov    r9,QWORD PTR [rsp+0xc8]
     3ec:	mov    QWORD PTR [rsp+0x8],r9
     3f1:	mov    r9,QWORD PTR [rsp+0xc0]
     3f9:	mov    QWORD PTR [rsp+0x10],r9
     3fe:	mov    r9,QWORD PTR [rsp+0xb8]
     406:	mov    QWORD PTR [rsp+0x18],r9
     40b:	mov    r9,QWORD PTR [rsp+0xb0]
     413:	mov    QWORD PTR [rsp+0x20],r9
     418:	mov    QWORD PTR [rsp+0x28],r10
     41d:	mov    QWORD PTR [rsp+0x30],r11
     422:	mov    QWORD PTR [rsp+0x38],rbx
     427:	mov    QWORD PTR [rsp+0x40],rax
     42c:	mov    QWORD PTR [rsp+0x48],r13
     431:	mov    QWORD PTR [rsp+0x50],r14
     436:	mov    QWORD PTR [rsp+0x58],r15
     43b:	mov    QWORD PTR [rsp+0x60],rcx
     440:	mov    QWORD PTR [rsp+0x68],rdx
     445:	mov    QWORD PTR [rsp+0x70],rsi
     44a:	mov    QWORD PTR [rsp+0x78],rdi
     44f:	mov    esi,0x10
     454:	mov    rdx,r8
     457:	mov    rdi,QWORD PTR [rsp+0xa0]
     45f:	call   464 <botlish_fn_1+0x299>
			460: R_X86_64_PLT32	rt_list_new-0x4
     464:	test   rax,rax
     467:	jne    47a <botlish_fn_1+0x2af>
     46d:	mov    rdi,QWORD PTR [rsp+0xa0]
     475:	jmp    595 <botlish_fn_1+0x3ca>
     47a:	mov    QWORD PTR [r12+0x8],rax
     47f:	lea    r8,[rsp+0x80]
     487:	mov    QWORD PTR [rsp+0x80],rax
     48f:	mov    esi,0x4
     494:	mov    rdx,QWORD PTR [rip+0x0]        # 49b <botlish_fn_1+0x2d0>
			497: R_X86_64_GOTPCREL	botlish_entry_4-0x4 ; hex_pair<generic>
     49b:	mov    ebx,0x1
     4a0:	mov    rcx,rbx
     4a3:	mov    rdi,QWORD PTR [rsp+0xa0]
     4ab:	call   4b0 <botlish_fn_1+0x2e5>
			4ac: R_X86_64_PLT32	rt_closure_new-0x4
     4b0:	mov    QWORD PTR [r12+0x8],rax
     4b5:	lea    r8,[rsp+0x88]
     4bd:	mov    QWORD PTR [rsp+0x88],rax
     4c5:	mov    esi,0x5
     4ca:	mov    rdx,QWORD PTR [rip+0x0]        # 4d1 <botlish_fn_1+0x306>
			4cd: R_X86_64_GOTPCREL	botlish_entry_5-0x4 ; esc_bytes<generic>
     4d1:	mov    rcx,rbx
     4d4:	mov    rdi,QWORD PTR [rsp+0xa0]
     4dc:	call   4e1 <botlish_fn_1+0x316>
			4dd: R_X86_64_PLT32	rt_closure_new-0x4
     4e1:	mov    QWORD PTR [r12+0x8],rax
     4e6:	lea    r8,[rsp+0x90]
     4ee:	mov    QWORD PTR [rsp+0x90],rax
     4f6:	mov    esi,0x6
     4fb:	mov    rdx,QWORD PTR [rip+0x0]        # 502 <botlish_fn_1+0x337>
			4fe: R_X86_64_GOTPCREL	botlish_entry_6-0x4 ; esc_char<generic>
     502:	mov    rcx,rbx
     505:	mov    rdi,QWORD PTR [rsp+0xa0]
     50d:	call   512 <botlish_fn_1+0x347>
			50e: R_X86_64_PLT32	rt_closure_new-0x4
     512:	mov    QWORD PTR [r12+0x8],rax
     517:	lea    r8,[rsp+0x98]
     51f:	mov    QWORD PTR [rsp+0x98],rax
     527:	mov    esi,0x7
     52c:	mov    rdx,QWORD PTR [rip+0x0]        # 533 <botlish_fn_1+0x368>
			52f: R_X86_64_GOTPCREL	botlish_entry_7-0x4 ; esc_from<generic>
     533:	mov    rcx,rbx
     536:	mov    rdi,QWORD PTR [rsp+0xa0]
     53e:	call   543 <botlish_fn_1+0x378>
			53f: R_X86_64_PLT32	rt_closure_new-0x4
     543:	mov    QWORD PTR [r12+0x8],rax
     548:	mov    QWORD PTR [r12+0x10],0x1
     551:	mov    rdi,QWORD PTR [rsp+0xa0]
     559:	mov    rdi,QWORD PTR [rdi+0x10]
     55d:	mov    r8,QWORD PTR [rdi+0x98]
     564:	mov    QWORD PTR [r12+0x18],r8
     569:	mov    rcx,rbx
     56c:	mov    rdx,QWORD PTR [rsp+0xa8]
     574:	mov    rsi,rax
     577:	mov    rdi,QWORD PTR [rsp+0xa0]
     57f:	call   584 <botlish_fn_1+0x3b9>
			580: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
     584:	test   rax,rax
     587:	jne    5d7 <botlish_fn_1+0x40c>
     58d:	mov    rdi,QWORD PTR [rsp+0xa0]
     595:	mov    rdi,QWORD PTR [rsp+0xa0]
     59d:	mov    QWORD PTR [rdi],r12
     5a0:	xor    rax,rax
     5a3:	mov    rbx,QWORD PTR [rsp+0xe0]
     5ab:	mov    r12,QWORD PTR [rsp+0xe8]
     5b3:	mov    r13,QWORD PTR [rsp+0xf0]
     5bb:	mov    r14,QWORD PTR [rsp+0xf8]
     5c3:	mov    r15,QWORD PTR [rsp+0x100]
     5cb:	add    rsp,0x110
     5d2:	mov    rsp,rbp
     5d5:	pop    rbp
     5d6:	ret
     5d7:	mov    rdi,QWORD PTR [rsp+0xa0]
     5df:	mov    QWORD PTR [rdi],r12
     5e2:	mov    rbx,QWORD PTR [rsp+0xe0]
     5ea:	mov    r12,QWORD PTR [rsp+0xe8]
     5f2:	mov    r13,QWORD PTR [rsp+0xf0]
     5fa:	mov    r14,QWORD PTR [rsp+0xf8]
     602:	mov    r15,QWORD PTR [rsp+0x100]
     60a:	add    rsp,0x110
     611:	mov    rsp,rbp
     614:	pop    rbp
     615:	ret
     616:	mov    QWORD PTR [rsp+0xa0],rdi
     61e:	call   623 <botlish_fn_1+0x458>
			61f: R_X86_64_PLT32	rt_stack_overflow-0x4
     623:	xor    rax,rax
     626:	mov    rbx,QWORD PTR [rsp+0xe0]
     62e:	mov    r12,QWORD PTR [rsp+0xe8]
     636:	mov    r13,QWORD PTR [rsp+0xf0]
     63e:	mov    r14,QWORD PTR [rsp+0xf8]
     646:	mov    r15,QWORD PTR [rsp+0x100]
     64e:	add    rsp,0x110
     655:	mov    rsp,rbp
     658:	pop    rbp
     659:	ret

000000000000065a <botlish_entry_1: web::uri_escape_text<str>>:
     65a:	push   rbp
     65b:	mov    rbp,rsp
     65e:	mov    rsi,QWORD PTR [rdx]
     661:	call   666 <botlish_entry_1+0xc>
			662: R_X86_64_PLT32	botlish_fn_1-0x4 ; web::uri_escape_text<str>
     666:	mov    rsp,rbp
     669:	pop    rbp
     66a:	ret
     66b:	add    BYTE PTR [rax],al
     66d:	add    BYTE PTR [rax],al
	...

0000000000000670 <botlish_fn_2: high_nibble<generic>>:
     670:	push   rbp
     671:	mov    rbp,rsp
     674:	sub    rsp,0x20
     678:	mov    QWORD PTR [rsp],rbx
     67c:	mov    QWORD PTR [rsp+0x8],r12
     681:	mov    QWORD PTR [rsp+0x10],r13
     686:	mov    rbx,QWORD PTR [rdi]
     689:	mov    rax,QWORD PTR [rdi+0x8]
     68d:	lea    rcx,[rbx+0x8]
     691:	cmp    rcx,rax
     694:	ja     ccf <botlish_fn_2+0x65f>
     69a:	lea    rax,[rbx+0x8]
     69e:	mov    QWORD PTR [rdi],rax
     6a1:	mov    QWORD PTR [rbx],0x0
     6a8:	mov    eax,0x1
     6ad:	test   rsi,0x1
     6b4:	jne    6d2 <botlish_fn_2+0x62>
     6ba:	xor    eax,eax
     6bc:	test   rsi,0x7
     6c3:	jne    6d2 <botlish_fn_2+0x62>
     6c9:	movzx  rax,BYTE PTR [rsi]
     6cd:	cmp    al,0x1
     6cf:	sete   al
     6d2:	test   al,al
     6d4:	jne    710 <botlish_fn_2+0xa0>
     6da:	mov    rax,QWORD PTR [rdi+0x10]
     6de:	mov    r12,rdi
     6e1:	mov    rcx,QWORD PTR [rax+0xa0]
     6e8:	xor    rdx,rdx
     6eb:	call   6f0 <botlish_fn_2+0x80>
			6ec: R_X86_64_PLT32	rt_type_error-0x4
     6f0:	mov    rdi,r12
     6f3:	mov    QWORD PTR [rdi],rbx
     6f6:	xor    rax,rax
     6f9:	mov    rbx,QWORD PTR [rsp]
     6fd:	mov    r12,QWORD PTR [rsp+0x8]
     702:	mov    r13,QWORD PTR [rsp+0x10]
     707:	add    rsp,0x20
     70b:	mov    rsp,rbp
     70e:	pop    rbp
     70f:	ret
     710:	mov    r12,rdi
     713:	test   rsi,0x1
     71a:	mov    r13,rsi
     71d:	jne    748 <botlish_fn_2+0xd8>
     723:	mov    edx,0x1f
     728:	mov    rsi,r13
     72b:	mov    rdi,r12
     72e:	call   733 <botlish_fn_2+0xc3>
			72f: R_X86_64_PLT32	rt_int_cmp-0x4
     733:	mov    ecx,0x2
     738:	test   rax,rax
     73b:	cmovle rcx,QWORD PTR [rip+0x5b5]        # cf8 <botlish_fn_2+0x688>
     743:	jmp    75c <botlish_fn_2+0xec>
     748:	mov    ecx,0x2
     74d:	mov    rsi,r13
     750:	cmp    rsi,0x1f
     754:	cmovle rcx,QWORD PTR [rip+0x59c]        # cf8 <botlish_fn_2+0x688>
     75c:	cmp    rcx,0x6
     760:	je     caa <botlish_fn_2+0x63a>
     766:	mov    rsi,r13
     769:	test   rsi,0x1
     770:	jne    79b <botlish_fn_2+0x12b>
     776:	mov    edx,0x3f
     77b:	mov    rsi,r13
     77e:	mov    rdi,r12
     781:	call   786 <botlish_fn_2+0x116>
			782: R_X86_64_PLT32	rt_int_cmp-0x4
     786:	mov    ecx,0x2
     78b:	test   rax,rax
     78e:	cmovle rcx,QWORD PTR [rip+0x562]        # cf8 <botlish_fn_2+0x688>
     796:	jmp    7af <botlish_fn_2+0x13f>
     79b:	mov    ecx,0x2
     7a0:	mov    rsi,r13
     7a3:	cmp    rsi,0x3f
     7a7:	cmovle rcx,QWORD PTR [rip+0x549]        # cf8 <botlish_fn_2+0x688>
     7af:	cmp    rcx,0x6
     7b3:	je     c9d <botlish_fn_2+0x62d>
     7b9:	mov    rsi,r13
     7bc:	test   rsi,0x1
     7c3:	jne    7ef <botlish_fn_2+0x17f>
     7c9:	mov    edx,0x5f
     7ce:	mov    rsi,r13
     7d1:	mov    rdi,r12
     7d4:	call   7d9 <botlish_fn_2+0x169>
			7d5: R_X86_64_PLT32	rt_int_cmp-0x4
     7d9:	mov    r9d,0x2
     7df:	test   rax,rax
     7e2:	cmovle r9,QWORD PTR [rip+0x50e]        # cf8 <botlish_fn_2+0x688>
     7ea:	jmp    804 <botlish_fn_2+0x194>
     7ef:	mov    r9d,0x2
     7f5:	mov    rsi,r13
     7f8:	cmp    rsi,0x5f
     7fc:	cmovle r9,QWORD PTR [rip+0x4f4]        # cf8 <botlish_fn_2+0x688>
     804:	cmp    r9,0x6
     808:	je     c93 <botlish_fn_2+0x623>
     80e:	mov    rsi,r13
     811:	test   rsi,0x1
     818:	jne    843 <botlish_fn_2+0x1d3>
     81e:	mov    edx,0x7f
     823:	mov    rsi,r13
     826:	mov    rdi,r12
     829:	call   82e <botlish_fn_2+0x1be>
			82a: R_X86_64_PLT32	rt_int_cmp-0x4
     82e:	mov    ecx,0x2
     833:	test   rax,rax
     836:	cmovle rcx,QWORD PTR [rip+0x4ba]        # cf8 <botlish_fn_2+0x688>
     83e:	jmp    857 <botlish_fn_2+0x1e7>
     843:	mov    ecx,0x2
     848:	mov    rsi,r13
     84b:	cmp    rsi,0x7f
     84f:	cmovle rcx,QWORD PTR [rip+0x4a1]        # cf8 <botlish_fn_2+0x688>
     857:	cmp    rcx,0x6
     85b:	je     c89 <botlish_fn_2+0x619>
     861:	mov    rsi,r13
     864:	test   rsi,0x1
     86b:	jne    896 <botlish_fn_2+0x226>
     871:	mov    edx,0x9f
     876:	mov    rsi,r13
     879:	mov    rdi,r12
     87c:	call   881 <botlish_fn_2+0x211>
			87d: R_X86_64_PLT32	rt_int_cmp-0x4
     881:	mov    ecx,0x2
     886:	test   rax,rax
     889:	cmovle rcx,QWORD PTR [rip+0x467]        # cf8 <botlish_fn_2+0x688>
     891:	jmp    8ad <botlish_fn_2+0x23d>
     896:	mov    ecx,0x2
     89b:	mov    rsi,r13
     89e:	cmp    rsi,0x9f
     8a5:	cmovle rcx,QWORD PTR [rip+0x44b]        # cf8 <botlish_fn_2+0x688>
     8ad:	cmp    rcx,0x6
     8b1:	je     c7f <botlish_fn_2+0x60f>
     8b7:	mov    rsi,r13
     8ba:	test   rsi,0x1
     8c1:	jne    8ec <botlish_fn_2+0x27c>
     8c7:	mov    edx,0xbf
     8cc:	mov    rsi,r13
     8cf:	mov    rdi,r12
     8d2:	call   8d7 <botlish_fn_2+0x267>
			8d3: R_X86_64_PLT32	rt_int_cmp-0x4
     8d7:	mov    ecx,0x2
     8dc:	test   rax,rax
     8df:	cmovle rcx,QWORD PTR [rip+0x411]        # cf8 <botlish_fn_2+0x688>
     8e7:	jmp    903 <botlish_fn_2+0x293>
     8ec:	mov    ecx,0x2
     8f1:	mov    rsi,r13
     8f4:	cmp    rsi,0xbf
     8fb:	cmovle rcx,QWORD PTR [rip+0x3f5]        # cf8 <botlish_fn_2+0x688>
     903:	cmp    rcx,0x6
     907:	je     c75 <botlish_fn_2+0x605>
     90d:	mov    rsi,r13
     910:	test   rsi,0x1
     917:	jne    942 <botlish_fn_2+0x2d2>
     91d:	mov    edx,0xdf
     922:	mov    rsi,r13
     925:	mov    rdi,r12
     928:	call   92d <botlish_fn_2+0x2bd>
			929: R_X86_64_PLT32	rt_int_cmp-0x4
     92d:	mov    esi,0x2
     932:	test   rax,rax
     935:	cmovle rsi,QWORD PTR [rip+0x3bb]        # cf8 <botlish_fn_2+0x688>
     93d:	jmp    958 <botlish_fn_2+0x2e8>
     942:	mov    esi,0x2
     947:	mov    rax,r13
     94a:	cmp    rax,0xdf
     950:	cmovle rsi,QWORD PTR [rip+0x3a0]        # cf8 <botlish_fn_2+0x688>
     958:	cmp    rsi,0x6
     95c:	je     c6b <botlish_fn_2+0x5fb>
     962:	mov    rsi,r13
     965:	test   rsi,0x1
     96c:	jne    997 <botlish_fn_2+0x327>
     972:	mov    edx,0xff
     977:	mov    rsi,r13
     97a:	mov    rdi,r12
     97d:	call   982 <botlish_fn_2+0x312>
			97e: R_X86_64_PLT32	rt_int_cmp-0x4
     982:	mov    ecx,0x2
     987:	test   rax,rax
     98a:	cmovle rcx,QWORD PTR [rip+0x366]        # cf8 <botlish_fn_2+0x688>
     992:	jmp    9ae <botlish_fn_2+0x33e>
     997:	mov    ecx,0x2
     99c:	mov    rsi,r13
     99f:	cmp    rsi,0xff
     9a6:	cmovle rcx,QWORD PTR [rip+0x34a]        # cf8 <botlish_fn_2+0x688>
     9ae:	cmp    rcx,0x6
     9b2:	je     c61 <botlish_fn_2+0x5f1>
     9b8:	mov    rsi,r13
     9bb:	test   rsi,0x1
     9c2:	jne    9ed <botlish_fn_2+0x37d>
     9c8:	mov    edx,0x11f
     9cd:	mov    rsi,r13
     9d0:	mov    rdi,r12
     9d3:	call   9d8 <botlish_fn_2+0x368>
			9d4: R_X86_64_PLT32	rt_int_cmp-0x4
     9d8:	mov    ecx,0x2
     9dd:	test   rax,rax
     9e0:	cmovle rcx,QWORD PTR [rip+0x310]        # cf8 <botlish_fn_2+0x688>
     9e8:	jmp    a04 <botlish_fn_2+0x394>
     9ed:	mov    ecx,0x2
     9f2:	mov    rsi,r13
     9f5:	cmp    rsi,0x11f
     9fc:	cmovle rcx,QWORD PTR [rip+0x2f4]        # cf8 <botlish_fn_2+0x688>
     a04:	cmp    rcx,0x6
     a08:	je     c57 <botlish_fn_2+0x5e7>
     a0e:	mov    rsi,r13
     a11:	test   rsi,0x1
     a18:	jne    a43 <botlish_fn_2+0x3d3>
     a1e:	mov    edx,0x13f
     a23:	mov    rsi,r13
     a26:	mov    rdi,r12
     a29:	call   a2e <botlish_fn_2+0x3be>
			a2a: R_X86_64_PLT32	rt_int_cmp-0x4
     a2e:	mov    ecx,0x2
     a33:	test   rax,rax
     a36:	cmovle rcx,QWORD PTR [rip+0x2ba]        # cf8 <botlish_fn_2+0x688>
     a3e:	jmp    a5a <botlish_fn_2+0x3ea>
     a43:	mov    ecx,0x2
     a48:	mov    rsi,r13
     a4b:	cmp    rsi,0x13f
     a52:	cmovle rcx,QWORD PTR [rip+0x29e]        # cf8 <botlish_fn_2+0x688>
     a5a:	cmp    rcx,0x6
     a5e:	je     c4d <botlish_fn_2+0x5dd>
     a64:	mov    rsi,r13
     a67:	test   rsi,0x1
     a6e:	jne    a99 <botlish_fn_2+0x429>
     a74:	mov    edx,0x15f
     a79:	mov    rsi,r13
     a7c:	mov    rdi,r12
     a7f:	call   a84 <botlish_fn_2+0x414>
			a80: R_X86_64_PLT32	rt_int_cmp-0x4
     a84:	mov    esi,0x2
     a89:	test   rax,rax
     a8c:	cmovle rsi,QWORD PTR [rip+0x264]        # cf8 <botlish_fn_2+0x688>
     a94:	jmp    aaf <botlish_fn_2+0x43f>
     a99:	mov    esi,0x2
     a9e:	mov    rax,r13
     aa1:	cmp    rax,0x15f
     aa7:	cmovle rsi,QWORD PTR [rip+0x249]        # cf8 <botlish_fn_2+0x688>
     aaf:	cmp    rsi,0x6
     ab3:	je     c43 <botlish_fn_2+0x5d3>
     ab9:	mov    rsi,r13
     abc:	test   rsi,0x1
     ac3:	jne    aee <botlish_fn_2+0x47e>
     ac9:	mov    edx,0x17f
     ace:	mov    rsi,r13
     ad1:	mov    rdi,r12
     ad4:	call   ad9 <botlish_fn_2+0x469>
			ad5: R_X86_64_PLT32	rt_int_cmp-0x4
     ad9:	mov    ecx,0x2
     ade:	test   rax,rax
     ae1:	cmovle rcx,QWORD PTR [rip+0x20f]        # cf8 <botlish_fn_2+0x688>
     ae9:	jmp    b05 <botlish_fn_2+0x495>
     aee:	mov    ecx,0x2
     af3:	mov    rsi,r13
     af6:	cmp    rsi,0x17f
     afd:	cmovle rcx,QWORD PTR [rip+0x1f3]        # cf8 <botlish_fn_2+0x688>
     b05:	cmp    rcx,0x6
     b09:	je     c39 <botlish_fn_2+0x5c9>
     b0f:	mov    rsi,r13
     b12:	test   rsi,0x1
     b19:	jne    b44 <botlish_fn_2+0x4d4>
     b1f:	mov    edx,0x19f
     b24:	mov    rsi,r13
     b27:	mov    rdi,r12
     b2a:	call   b2f <botlish_fn_2+0x4bf>
			b2b: R_X86_64_PLT32	rt_int_cmp-0x4
     b2f:	mov    ecx,0x2
     b34:	test   rax,rax
     b37:	cmovle rcx,QWORD PTR [rip+0x1b9]        # cf8 <botlish_fn_2+0x688>
     b3f:	jmp    b5b <botlish_fn_2+0x4eb>
     b44:	mov    ecx,0x2
     b49:	mov    rsi,r13
     b4c:	cmp    rsi,0x19f
     b53:	cmovle rcx,QWORD PTR [rip+0x19d]        # cf8 <botlish_fn_2+0x688>
     b5b:	cmp    rcx,0x6
     b5f:	je     c2f <botlish_fn_2+0x5bf>
     b65:	mov    rsi,r13
     b68:	test   rsi,0x1
     b6f:	jne    b9a <botlish_fn_2+0x52a>
     b75:	mov    edx,0x1bf
     b7a:	mov    rsi,r13
     b7d:	mov    rdi,r12
     b80:	call   b85 <botlish_fn_2+0x515>
			b81: R_X86_64_PLT32	rt_int_cmp-0x4
     b85:	mov    ecx,0x2
     b8a:	test   rax,rax
     b8d:	cmovle rcx,QWORD PTR [rip+0x163]        # cf8 <botlish_fn_2+0x688>
     b95:	jmp    bb1 <botlish_fn_2+0x541>
     b9a:	mov    ecx,0x2
     b9f:	mov    rsi,r13
     ba2:	cmp    rsi,0x1bf
     ba9:	cmovle rcx,QWORD PTR [rip+0x147]        # cf8 <botlish_fn_2+0x688>
     bb1:	cmp    rcx,0x6
     bb5:	je     c25 <botlish_fn_2+0x5b5>
     bbb:	mov    rsi,r13
     bbe:	test   rsi,0x1
     bc5:	jne    bf0 <botlish_fn_2+0x580>
     bcb:	mov    edx,0x1df
     bd0:	mov    rsi,r13
     bd3:	mov    rdi,r12
     bd6:	call   bdb <botlish_fn_2+0x56b>
			bd7: R_X86_64_PLT32	rt_int_cmp-0x4
     bdb:	mov    ecx,0x2
     be0:	test   rax,rax
     be3:	cmovle rcx,QWORD PTR [rip+0x10d]        # cf8 <botlish_fn_2+0x688>
     beb:	jmp    c07 <botlish_fn_2+0x597>
     bf0:	mov    ecx,0x2
     bf5:	mov    rsi,r13
     bf8:	cmp    rsi,0x1df
     bff:	cmovle rcx,QWORD PTR [rip+0xf1]        # cf8 <botlish_fn_2+0x688>
     c07:	cmp    rcx,0x6
     c0b:	je     c1b <botlish_fn_2+0x5ab>
     c11:	mov    eax,0x1f
     c16:	jmp    ca2 <botlish_fn_2+0x632>
     c1b:	mov    eax,0x1d
     c20:	jmp    ca2 <botlish_fn_2+0x632>
     c25:	mov    eax,0x1b
     c2a:	jmp    ca2 <botlish_fn_2+0x632>
     c2f:	mov    eax,0x19
     c34:	jmp    ca2 <botlish_fn_2+0x632>
     c39:	mov    eax,0x17
     c3e:	jmp    ca2 <botlish_fn_2+0x632>
     c43:	mov    eax,0x15
     c48:	jmp    ca2 <botlish_fn_2+0x632>
     c4d:	mov    eax,0x13
     c52:	jmp    ca2 <botlish_fn_2+0x632>
     c57:	mov    eax,0x11
     c5c:	jmp    ca2 <botlish_fn_2+0x632>
     c61:	mov    eax,0xf
     c66:	jmp    ca2 <botlish_fn_2+0x632>
     c6b:	mov    eax,0xd
     c70:	jmp    ca2 <botlish_fn_2+0x632>
     c75:	mov    eax,0xb
     c7a:	jmp    ca2 <botlish_fn_2+0x632>
     c7f:	mov    eax,0x9
     c84:	jmp    ca2 <botlish_fn_2+0x632>
     c89:	mov    eax,0x7
     c8e:	jmp    ca2 <botlish_fn_2+0x632>
     c93:	mov    eax,0x5
     c98:	jmp    ca2 <botlish_fn_2+0x632>
     c9d:	mov    eax,0x3
     ca2:	mov    rdi,r12
     ca5:	jmp    cb2 <botlish_fn_2+0x642>
     caa:	mov    eax,0x1
     caf:	mov    rdi,r12
     cb2:	mov    rdi,r12
     cb5:	mov    QWORD PTR [rdi],rbx
     cb8:	mov    rbx,QWORD PTR [rsp]
     cbc:	mov    r12,QWORD PTR [rsp+0x8]
     cc1:	mov    r13,QWORD PTR [rsp+0x10]
     cc6:	add    rsp,0x20
     cca:	mov    rsp,rbp
     ccd:	pop    rbp
     cce:	ret
     ccf:	mov    r12,rdi
     cd2:	call   cd7 <botlish_fn_2+0x667>
			cd3: R_X86_64_PLT32	rt_stack_overflow-0x4
     cd7:	xor    rax,rax
     cda:	mov    rbx,QWORD PTR [rsp]
     cde:	mov    r12,QWORD PTR [rsp+0x8]
     ce3:	mov    r13,QWORD PTR [rsp+0x10]
     ce8:	add    rsp,0x20
     cec:	mov    rsp,rbp
     cef:	pop    rbp
     cf0:	ret
     cf1:	add    BYTE PTR [rax],al
     cf3:	add    BYTE PTR [rax],al
     cf5:	add    BYTE PTR [rax],al
     cf7:	add    BYTE PTR [rsi],al
     cf9:	add    BYTE PTR [rax],al
     cfb:	add    BYTE PTR [rax],al
     cfd:	add    BYTE PTR [rax],al
	...

0000000000000d00 <botlish_entry_2: high_nibble<generic>>:
     d00:	push   rbp
     d01:	mov    rbp,rsp
     d04:	mov    rsi,QWORD PTR [rdx]
     d07:	call   d0c <botlish_entry_2+0xc>
			d08: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
     d0c:	mov    rsp,rbp
     d0f:	pop    rbp
     d10:	ret
     d11:	add    BYTE PTR [rax],al
     d13:	add    BYTE PTR [rax],al
     d15:	add    BYTE PTR [rax],al
	...

0000000000000d18 <botlish_fn_3: is_unreserved<generic>>:
     d18:	push   rbp
     d19:	mov    rbp,rsp
     d1c:	sub    rsp,0x20
     d20:	mov    QWORD PTR [rsp],rbx
     d24:	mov    QWORD PTR [rsp+0x8],r12
     d29:	mov    QWORD PTR [rsp+0x10],r13
     d2e:	mov    QWORD PTR [rsp+0x18],r14
     d33:	mov    rbx,QWORD PTR [rdi]
     d36:	mov    rax,QWORD PTR [rdi+0x8]
     d3a:	lea    rcx,[rbx+0x8]
     d3e:	cmp    rcx,rax
     d41:	ja     1265 <botlish_fn_3+0x54d>
     d47:	lea    rdx,[rbx+0x8]
     d4b:	mov    QWORD PTR [rdi],rdx
     d4e:	mov    QWORD PTR [rbx],0x0
     d55:	mov    eax,0x1
     d5a:	test   rsi,0x1
     d61:	jne    d81 <botlish_fn_3+0x69>
     d67:	xor    eax,eax
     d69:	test   rsi,0x7
     d70:	jne    d81 <botlish_fn_3+0x69>
     d76:	movzx  r11,BYTE PTR [rsi]
     d7a:	cmp    r11b,0x1
     d7e:	sete   al
     d81:	test   al,al
     d83:	jne    dc4 <botlish_fn_3+0xac>
     d89:	mov    rax,QWORD PTR [rdi+0x10]
     d8d:	mov    r12,rdi
     d90:	mov    rcx,QWORD PTR [rax+0xa0]
     d97:	xor    rdx,rdx
     d9a:	call   d9f <botlish_fn_3+0x87>
			d9b: R_X86_64_PLT32	rt_type_error-0x4
     d9f:	mov    rdi,r12
     da2:	mov    QWORD PTR [rdi],rbx
     da5:	xor    rax,rax
     da8:	mov    rbx,QWORD PTR [rsp]
     dac:	mov    r12,QWORD PTR [rsp+0x8]
     db1:	mov    r13,QWORD PTR [rsp+0x10]
     db6:	mov    r14,QWORD PTR [rsp+0x18]
     dbb:	add    rsp,0x20
     dbf:	mov    rsp,rbp
     dc2:	pop    rbp
     dc3:	ret
     dc4:	mov    r12,rdi
     dc7:	test   rsi,0x1
     dce:	mov    r13,rsi
     dd1:	jne    dfc <botlish_fn_3+0xe4>
     dd7:	mov    edx,0x59
     ddc:	mov    rsi,r13
     ddf:	mov    rdi,r12
     de2:	call   de7 <botlish_fn_3+0xcf>
			de3: R_X86_64_PLT32	rt_int_cmp-0x4
     de7:	mov    ecx,0x2
     dec:	test   rax,rax
     def:	cmovle rcx,QWORD PTR [rip+0x499]        # 1290 <botlish_fn_3+0x578>
     df7:	jmp    e10 <botlish_fn_3+0xf8>
     dfc:	mov    ecx,0x2
     e01:	mov    rsi,r13
     e04:	cmp    rsi,0x59
     e08:	cmovle rcx,QWORD PTR [rip+0x480]        # 1290 <botlish_fn_3+0x578>
     e10:	mov    eax,0x6
     e15:	mov    r14,rax
     e18:	cmp    rcx,0x6
     e1c:	je     123b <botlish_fn_3+0x523>
     e22:	mov    rsi,r13
     e25:	test   rsi,0x1
     e2c:	jne    e57 <botlish_fn_3+0x13f>
     e32:	mov    edx,0x5d
     e37:	mov    rsi,r13
     e3a:	mov    rdi,r12
     e3d:	call   e42 <botlish_fn_3+0x12a>
			e3e: R_X86_64_PLT32	rt_int_cmp-0x4
     e42:	mov    ecx,0x2
     e47:	test   rax,rax
     e4a:	cmovle rcx,QWORD PTR [rip+0x43e]        # 1290 <botlish_fn_3+0x578>
     e52:	jmp    e6b <botlish_fn_3+0x153>
     e57:	mov    ecx,0x2
     e5c:	mov    rsi,r13
     e5f:	cmp    rsi,0x5d
     e63:	cmovle rcx,QWORD PTR [rip+0x425]        # 1290 <botlish_fn_3+0x578>
     e6b:	cmp    rcx,0x6
     e6f:	je     1230 <botlish_fn_3+0x518>
     e75:	mov    rsi,r13
     e78:	test   rsi,0x1
     e7f:	jne    eab <botlish_fn_3+0x193>
     e85:	mov    edx,0x5f
     e8a:	mov    rsi,r13
     e8d:	mov    rdi,r12
     e90:	call   e95 <botlish_fn_3+0x17d>
			e91: R_X86_64_PLT32	rt_int_cmp-0x4
     e95:	mov    r10d,0x2
     e9b:	test   rax,rax
     e9e:	cmovle r10,QWORD PTR [rip+0x3ea]        # 1290 <botlish_fn_3+0x578>
     ea6:	jmp    ec0 <botlish_fn_3+0x1a8>
     eab:	mov    r10d,0x2
     eb1:	mov    rsi,r13
     eb4:	cmp    rsi,0x5f
     eb8:	cmovle r10,QWORD PTR [rip+0x3d0]        # 1290 <botlish_fn_3+0x578>
     ec0:	cmp    r10,0x6
     ec4:	je     1226 <botlish_fn_3+0x50e>
     eca:	mov    rsi,r13
     ecd:	test   rsi,0x1
     ed4:	jne    eff <botlish_fn_3+0x1e7>
     eda:	mov    edx,0x73
     edf:	mov    rsi,r13
     ee2:	mov    rdi,r12
     ee5:	call   eea <botlish_fn_3+0x1d2>
			ee6: R_X86_64_PLT32	rt_int_cmp-0x4
     eea:	mov    ecx,0x2
     eef:	test   rax,rax
     ef2:	cmovle rcx,QWORD PTR [rip+0x396]        # 1290 <botlish_fn_3+0x578>
     efa:	jmp    f13 <botlish_fn_3+0x1fb>
     eff:	mov    ecx,0x2
     f04:	mov    rsi,r13
     f07:	cmp    rsi,0x73
     f0b:	cmovle rcx,QWORD PTR [rip+0x37d]        # 1290 <botlish_fn_3+0x578>
     f13:	cmp    rcx,0x6
     f17:	je     121e <botlish_fn_3+0x506>
     f1d:	mov    rsi,r13
     f20:	test   rsi,0x1
     f27:	jne    f52 <botlish_fn_3+0x23a>
     f2d:	mov    edx,0x81
     f32:	mov    rsi,r13
     f35:	mov    rdi,r12
     f38:	call   f3d <botlish_fn_3+0x225>
			f39: R_X86_64_PLT32	rt_int_cmp-0x4
     f3d:	mov    ecx,0x2
     f42:	test   rax,rax
     f45:	cmovle rcx,QWORD PTR [rip+0x343]        # 1290 <botlish_fn_3+0x578>
     f4d:	jmp    f69 <botlish_fn_3+0x251>
     f52:	mov    ecx,0x2
     f57:	mov    rsi,r13
     f5a:	cmp    rsi,0x81
     f61:	cmovle rcx,QWORD PTR [rip+0x327]        # 1290 <botlish_fn_3+0x578>
     f69:	cmp    rcx,0x6
     f6d:	je     1214 <botlish_fn_3+0x4fc>
     f73:	mov    rsi,r13
     f76:	test   rsi,0x1
     f7d:	jne    fa8 <botlish_fn_3+0x290>
     f83:	mov    edx,0xb5
     f88:	mov    rsi,r13
     f8b:	mov    rdi,r12
     f8e:	call   f93 <botlish_fn_3+0x27b>
			f8f: R_X86_64_PLT32	rt_int_cmp-0x4
     f93:	mov    ecx,0x2
     f98:	test   rax,rax
     f9b:	cmovle rcx,QWORD PTR [rip+0x2ed]        # 1290 <botlish_fn_3+0x578>
     fa3:	jmp    fbf <botlish_fn_3+0x2a7>
     fa8:	mov    ecx,0x2
     fad:	mov    rsi,r13
     fb0:	cmp    rsi,0xb5
     fb7:	cmovle rcx,QWORD PTR [rip+0x2d1]        # 1290 <botlish_fn_3+0x578>
     fbf:	cmp    rcx,0x6
     fc3:	je     120c <botlish_fn_3+0x4f4>
     fc9:	mov    rsi,r13
     fcc:	test   rsi,0x1
     fd3:	jne    ffe <botlish_fn_3+0x2e6>
     fd9:	mov    edx,0xbd
     fde:	mov    rsi,r13
     fe1:	mov    rdi,r12
     fe4:	call   fe9 <botlish_fn_3+0x2d1>
			fe5: R_X86_64_PLT32	rt_int_cmp-0x4
     fe9:	mov    edi,0x2
     fee:	test   rax,rax
     ff1:	cmovle rdi,QWORD PTR [rip+0x297]        # 1290 <botlish_fn_3+0x578>
     ff9:	jmp    1015 <botlish_fn_3+0x2fd>
     ffe:	mov    edi,0x2
    1003:	mov    rsi,r13
    1006:	cmp    rsi,0xbd
    100d:	cmovle rdi,QWORD PTR [rip+0x27b]        # 1290 <botlish_fn_3+0x578>
    1015:	cmp    rdi,0x6
    1019:	je     1202 <botlish_fn_3+0x4ea>
    101f:	mov    rsi,r13
    1022:	test   rsi,0x1
    1029:	jne    1054 <botlish_fn_3+0x33c>
    102f:	mov    edx,0xbf
    1034:	mov    rsi,r13
    1037:	mov    rdi,r12
    103a:	call   103f <botlish_fn_3+0x327>
			103b: R_X86_64_PLT32	rt_int_cmp-0x4
    103f:	mov    ecx,0x2
    1044:	test   rax,rax
    1047:	cmovle rcx,QWORD PTR [rip+0x241]        # 1290 <botlish_fn_3+0x578>
    104f:	jmp    106b <botlish_fn_3+0x353>
    1054:	mov    ecx,0x2
    1059:	mov    rsi,r13
    105c:	cmp    rsi,0xbf
    1063:	cmovle rcx,QWORD PTR [rip+0x225]        # 1290 <botlish_fn_3+0x578>
    106b:	cmp    rcx,0x6
    106f:	je     11fa <botlish_fn_3+0x4e2>
    1075:	mov    rsi,r13
    1078:	test   rsi,0x1
    107f:	jne    10aa <botlish_fn_3+0x392>
    1085:	mov    edx,0xc1
    108a:	mov    rsi,r13
    108d:	mov    rdi,r12
    1090:	call   1095 <botlish_fn_3+0x37d>
			1091: R_X86_64_PLT32	rt_int_cmp-0x4
    1095:	mov    ecx,0x2
    109a:	test   rax,rax
    109d:	cmovle rcx,QWORD PTR [rip+0x1eb]        # 1290 <botlish_fn_3+0x578>
    10a5:	jmp    10c1 <botlish_fn_3+0x3a9>
    10aa:	mov    ecx,0x2
    10af:	mov    rsi,r13
    10b2:	cmp    rsi,0xc1
    10b9:	cmovle rcx,QWORD PTR [rip+0x1cf]        # 1290 <botlish_fn_3+0x578>
    10c1:	cmp    rcx,0x6
    10c5:	je     11f0 <botlish_fn_3+0x4d8>
    10cb:	mov    rsi,r13
    10ce:	test   rsi,0x1
    10d5:	jne    1100 <botlish_fn_3+0x3e8>
    10db:	mov    edx,0xf5
    10e0:	mov    rsi,r13
    10e3:	mov    rdi,r12
    10e6:	call   10eb <botlish_fn_3+0x3d3>
			10e7: R_X86_64_PLT32	rt_int_cmp-0x4
    10eb:	mov    ecx,0x2
    10f0:	test   rax,rax
    10f3:	cmovle rcx,QWORD PTR [rip+0x195]        # 1290 <botlish_fn_3+0x578>
    10fb:	jmp    1117 <botlish_fn_3+0x3ff>
    1100:	mov    ecx,0x2
    1105:	mov    rsi,r13
    1108:	cmp    rsi,0xf5
    110f:	cmovle rcx,QWORD PTR [rip+0x179]        # 1290 <botlish_fn_3+0x578>
    1117:	cmp    rcx,0x6
    111b:	je     11e8 <botlish_fn_3+0x4d0>
    1121:	mov    rsi,r13
    1124:	test   rsi,0x1
    112b:	jne    1156 <botlish_fn_3+0x43e>
    1131:	mov    edx,0xfb
    1136:	mov    rsi,r13
    1139:	mov    rdi,r12
    113c:	call   1141 <botlish_fn_3+0x429>
			113d: R_X86_64_PLT32	rt_int_cmp-0x4
    1141:	mov    esi,0x2
    1146:	test   rax,rax
    1149:	cmovle rsi,QWORD PTR [rip+0x13f]        # 1290 <botlish_fn_3+0x578>
    1151:	jmp    116c <botlish_fn_3+0x454>
    1156:	mov    esi,0x2
    115b:	mov    rax,r13
    115e:	cmp    rax,0xfb
    1164:	cmovle rsi,QWORD PTR [rip+0x124]        # 1290 <botlish_fn_3+0x578>
    116c:	cmp    rsi,0x6
    1170:	je     11de <botlish_fn_3+0x4c6>
    1176:	mov    rsi,r13
    1179:	test   rsi,0x1
    1180:	jne    11ab <botlish_fn_3+0x493>
    1186:	mov    edx,0xfd
    118b:	mov    rsi,r13
    118e:	mov    rdi,r12
    1191:	call   1196 <botlish_fn_3+0x47e>
			1192: R_X86_64_PLT32	rt_int_cmp-0x4
    1196:	mov    ecx,0x2
    119b:	test   rax,rax
    119e:	cmovle rcx,QWORD PTR [rip+0xea]        # 1290 <botlish_fn_3+0x578>
    11a6:	jmp    11c2 <botlish_fn_3+0x4aa>
    11ab:	mov    ecx,0x2
    11b0:	mov    rsi,r13
    11b3:	cmp    rsi,0xfd
    11ba:	cmovle rcx,QWORD PTR [rip+0xce]        # 1290 <botlish_fn_3+0x578>
    11c2:	cmp    rcx,0x6
    11c6:	je     11d6 <botlish_fn_3+0x4be>
    11cc:	mov    eax,0x2
    11d1:	jmp    1233 <botlish_fn_3+0x51b>
    11d6:	mov    rax,r14
    11d9:	jmp    1233 <botlish_fn_3+0x51b>
    11de:	mov    eax,0x2
    11e3:	jmp    1233 <botlish_fn_3+0x51b>
    11e8:	mov    rax,r14
    11eb:	jmp    1233 <botlish_fn_3+0x51b>
    11f0:	mov    eax,0x2
    11f5:	jmp    1233 <botlish_fn_3+0x51b>
    11fa:	mov    rax,r14
    11fd:	jmp    1233 <botlish_fn_3+0x51b>
    1202:	mov    eax,0x2
    1207:	jmp    1233 <botlish_fn_3+0x51b>
    120c:	mov    rax,r14
    120f:	jmp    1233 <botlish_fn_3+0x51b>
    1214:	mov    eax,0x2
    1219:	jmp    1233 <botlish_fn_3+0x51b>
    121e:	mov    rax,r14
    1221:	jmp    1233 <botlish_fn_3+0x51b>
    1226:	mov    eax,0x2
    122b:	jmp    1233 <botlish_fn_3+0x51b>
    1230:	mov    rax,r14
    1233:	mov    rdi,r12
    1236:	jmp    1243 <botlish_fn_3+0x52b>
    123b:	mov    eax,0x2
    1240:	mov    rdi,r12
    1243:	mov    rdi,r12
    1246:	mov    QWORD PTR [rdi],rbx
    1249:	mov    rbx,QWORD PTR [rsp]
    124d:	mov    r12,QWORD PTR [rsp+0x8]
    1252:	mov    r13,QWORD PTR [rsp+0x10]
    1257:	mov    r14,QWORD PTR [rsp+0x18]
    125c:	add    rsp,0x20
    1260:	mov    rsp,rbp
    1263:	pop    rbp
    1264:	ret
    1265:	mov    r12,rdi
    1268:	call   126d <botlish_fn_3+0x555>
			1269: R_X86_64_PLT32	rt_stack_overflow-0x4
    126d:	xor    rax,rax
    1270:	mov    rbx,QWORD PTR [rsp]
    1274:	mov    r12,QWORD PTR [rsp+0x8]
    1279:	mov    r13,QWORD PTR [rsp+0x10]
    127e:	mov    r14,QWORD PTR [rsp+0x18]
    1283:	add    rsp,0x20
    1287:	mov    rsp,rbp
    128a:	pop    rbp
    128b:	ret
    128c:	add    BYTE PTR [rax],al
    128e:	add    BYTE PTR [rax],al
    1290:	(bad)
    1291:	add    BYTE PTR [rax],al
    1293:	add    BYTE PTR [rax],al
    1295:	add    BYTE PTR [rax],al
	...

0000000000001298 <botlish_entry_3: is_unreserved<generic>>:
    1298:	push   rbp
    1299:	mov    rbp,rsp
    129c:	mov    rsi,QWORD PTR [rdx]
    129f:	call   12a4 <botlish_entry_3+0xc>
			12a0: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    12a4:	mov    rsp,rbp
    12a7:	pop    rbp
    12a8:	ret

00000000000012a9 <botlish_fn_4: hex_pair<generic>>:
    12a9:	push   rbp
    12aa:	mov    rbp,rsp
    12ad:	sub    rsp,0x30
    12b1:	mov    QWORD PTR [rsp],rbx
    12b5:	mov    QWORD PTR [rsp+0x8],r12
    12ba:	mov    QWORD PTR [rsp+0x10],r13
    12bf:	mov    QWORD PTR [rsp+0x18],r14
    12c4:	mov    QWORD PTR [rsp+0x20],r15
    12c9:	mov    r13,rdx
    12cc:	mov    rbx,QWORD PTR [rdi]
    12cf:	mov    rax,QWORD PTR [rdi+0x8]
    12d3:	lea    rcx,[rbx+0x10]
    12d7:	cmp    rcx,rax
    12da:	ja     14f2 <botlish_fn_4+0x249>
    12e0:	lea    rax,[rbx+0x10]
    12e4:	mov    QWORD PTR [rdi],rax
    12e7:	mov    r12,rdi
    12ea:	mov    QWORD PTR [rbx],0x0
    12f1:	mov    QWORD PTR [rbx+0x8],0x0
    12f9:	mov    rdx,r13
    12fc:	mov    QWORD PTR [rbx],rdx
    12ff:	mov    rax,QWORD PTR [rsi+0x20]
    1303:	mov    r14,rsi
    1306:	mov    rsi,QWORD PTR [rax]
    1309:	mov    QWORD PTR [rbx+0x8],rsi
    130d:	mov    r15,rsi
    1310:	mov    rsi,r13
    1313:	mov    rdi,r12
    1316:	call   131b <botlish_fn_4+0x72>
			1317: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
    131b:	test   rax,rax
    131e:	jne    132c <botlish_fn_4+0x83>
    1324:	mov    rdi,r12
    1327:	jmp    14a1 <botlish_fn_4+0x1f8>
    132c:	test   rax,0x1
    1332:	jne    1343 <botlish_fn_4+0x9a>
    1338:	mov    rdx,rax
    133b:	mov    rsi,r15
    133e:	jmp    135f <botlish_fn_4+0xb6>
    1343:	mov    rsi,r15
    1346:	mov    rdx,QWORD PTR [rsi+0x8]
    134a:	mov    rcx,rax
    134d:	sar    rcx,1
    1350:	mov    rdi,rax
    1353:	cmp    rcx,rdx
    1356:	jb     1380 <botlish_fn_4+0xd7>
    135c:	mov    rdx,rdi
    135f:	mov    rdi,r12
    1362:	call   1367 <botlish_fn_4+0xbe>
			1363: R_X86_64_PLT32	rt_list_get-0x4
    1367:	test   rax,rax
    136a:	jne    1378 <botlish_fn_4+0xcf>
    1370:	mov    rdi,r12
    1373:	jmp    14a1 <botlish_fn_4+0x1f8>
    1378:	mov    rsi,rax
    137b:	jmp    1388 <botlish_fn_4+0xdf>
    1380:	mov    rdx,QWORD PTR [rsi+0x10]
    1384:	mov    rsi,QWORD PTR [rdx+rcx*8]
    1388:	mov    QWORD PTR [rbx],rsi
    138b:	mov    rax,rsi
    138e:	mov    rsi,r14
    1391:	mov    r14,rax
    1394:	mov    rsi,QWORD PTR [rsi+0x20]
    1398:	mov    rsi,QWORD PTR [rsi]
    139b:	mov    r15,rsi
    139e:	mov    ecx,0x1
    13a3:	mov    rdx,r13
    13a6:	test   rdx,0x1
    13ad:	je     13bb <botlish_fn_4+0x112>
    13b3:	mov    r13,rdx
    13b6:	jmp    13e0 <botlish_fn_4+0x137>
    13bb:	xor    ecx,ecx
    13bd:	test   rdx,0x7
    13c4:	je     13d2 <botlish_fn_4+0x129>
    13ca:	mov    r13,rdx
    13cd:	jmp    13e0 <botlish_fn_4+0x137>
    13d2:	movzx  r10,BYTE PTR [rdx]
    13d6:	mov    r13,rdx
    13d9:	cmp    r10b,0x1
    13dd:	sete   cl
    13e0:	test   cl,cl
    13e2:	jne    1409 <botlish_fn_4+0x160>
    13e8:	mov    rdi,r12
    13eb:	mov    rax,QWORD PTR [rdi+0x10]
    13ef:	mov    rcx,QWORD PTR [rax+0xa8]
    13f6:	xor    rdx,rdx
    13f9:	mov    rsi,r13
    13fc:	call   1401 <botlish_fn_4+0x158>
			13fd: R_X86_64_PLT32	rt_type_error-0x4
    1401:	mov    rdi,r12
    1404:	jmp    14a1 <botlish_fn_4+0x1f8>
    1409:	mov    rsi,r13
    140c:	mov    edx,0x21
    1411:	mov    rdi,r12
    1414:	call   1419 <botlish_fn_4+0x170>
			1415: R_X86_64_PLT32	rt_int_mod-0x4
    1419:	test   rax,rax
    141c:	jne    142a <botlish_fn_4+0x181>
    1422:	mov    rdi,r12
    1425:	jmp    14a1 <botlish_fn_4+0x1f8>
    142a:	test   rax,0x1
    1430:	jne    1441 <botlish_fn_4+0x198>
    1436:	mov    rdx,rax
    1439:	mov    rsi,r15
    143c:	jmp    145d <botlish_fn_4+0x1b4>
    1441:	mov    rsi,r15
    1444:	mov    rdx,QWORD PTR [rsi+0x8]
    1448:	mov    rcx,rax
    144b:	sar    rcx,1
    144e:	mov    rdi,rax
    1451:	cmp    rcx,rdx
    1454:	jb     147e <botlish_fn_4+0x1d5>
    145a:	mov    rdx,rdi
    145d:	mov    rdi,r12
    1460:	call   1465 <botlish_fn_4+0x1bc>
			1461: R_X86_64_PLT32	rt_list_get-0x4
    1465:	test   rax,rax
    1468:	jne    1476 <botlish_fn_4+0x1cd>
    146e:	mov    rdi,r12
    1471:	jmp    14a1 <botlish_fn_4+0x1f8>
    1476:	mov    rdx,rax
    1479:	jmp    1486 <botlish_fn_4+0x1dd>
    147e:	mov    rax,QWORD PTR [rsi+0x10]
    1482:	mov    rdx,QWORD PTR [rax+rcx*8]
    1486:	mov    QWORD PTR [rbx+0x8],rdx
    148a:	mov    rsi,r14
    148d:	mov    rdi,r12
    1490:	call   1495 <botlish_fn_4+0x1ec>
			1491: R_X86_64_PLT32	rt_str_cat-0x4
    1495:	test   rax,rax
    1498:	jne    14cb <botlish_fn_4+0x222>
    149e:	mov    rdi,r12
    14a1:	mov    rdi,r12
    14a4:	mov    QWORD PTR [rdi],rbx
    14a7:	xor    rax,rax
    14aa:	mov    rbx,QWORD PTR [rsp]
    14ae:	mov    r12,QWORD PTR [rsp+0x8]
    14b3:	mov    r13,QWORD PTR [rsp+0x10]
    14b8:	mov    r14,QWORD PTR [rsp+0x18]
    14bd:	mov    r15,QWORD PTR [rsp+0x20]
    14c2:	add    rsp,0x30
    14c6:	mov    rsp,rbp
    14c9:	pop    rbp
    14ca:	ret
    14cb:	mov    rdi,r12
    14ce:	mov    QWORD PTR [rdi],rbx
    14d1:	mov    rbx,QWORD PTR [rsp]
    14d5:	mov    r12,QWORD PTR [rsp+0x8]
    14da:	mov    r13,QWORD PTR [rsp+0x10]
    14df:	mov    r14,QWORD PTR [rsp+0x18]
    14e4:	mov    r15,QWORD PTR [rsp+0x20]
    14e9:	add    rsp,0x30
    14ed:	mov    rsp,rbp
    14f0:	pop    rbp
    14f1:	ret
    14f2:	mov    r12,rdi
    14f5:	call   14fa <botlish_fn_4+0x251>
			14f6: R_X86_64_PLT32	rt_stack_overflow-0x4
    14fa:	xor    rax,rax
    14fd:	mov    rbx,QWORD PTR [rsp]
    1501:	mov    r12,QWORD PTR [rsp+0x8]
    1506:	mov    r13,QWORD PTR [rsp+0x10]
    150b:	mov    r14,QWORD PTR [rsp+0x18]
    1510:	mov    r15,QWORD PTR [rsp+0x20]
    1515:	add    rsp,0x30
    1519:	mov    rsp,rbp
    151c:	pop    rbp
    151d:	ret

000000000000151e <botlish_entry_4: hex_pair<generic>>:
    151e:	push   rbp
    151f:	mov    rbp,rsp
    1522:	mov    rdx,QWORD PTR [rdx]
    1525:	call   152a <botlish_entry_4+0xc>
			1526: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    152a:	mov    rsp,rbp
    152d:	pop    rbp
    152e:	ret
	...

0000000000001530 <botlish_fn_5: esc_bytes<generic>>:
    1530:	push   rbp
    1531:	mov    rbp,rsp
    1534:	sub    rsp,0x50
    1538:	mov    QWORD PTR [rsp+0x20],rbx
    153d:	mov    QWORD PTR [rsp+0x28],r12
    1542:	mov    QWORD PTR [rsp+0x30],r13
    1547:	mov    QWORD PTR [rsp+0x38],r14
    154c:	mov    QWORD PTR [rsp+0x40],r15
    1551:	mov    r13,rsi
    1554:	mov    r14,QWORD PTR [rdi]
    1557:	mov    r9,QWORD PTR [rdi+0x8]
    155b:	lea    r10,[r14+0x38]
    155f:	cmp    r10,r9
    1562:	ja     18d3 <botlish_fn_5+0x3a3>
    1568:	lea    r10,[r14+0x38]
    156c:	mov    QWORD PTR [rdi],r10
    156f:	mov    r15,rdi
    1572:	mov    QWORD PTR [r14],0x0
    1579:	mov    QWORD PTR [r14+0x8],0x0
    1581:	mov    QWORD PTR [r14+0x10],0x0
    1589:	mov    QWORD PTR [r14+0x18],0x0
    1591:	mov    QWORD PTR [r14+0x20],0x0
    1599:	mov    QWORD PTR [r14+0x28],0x0
    15a1:	mov    QWORD PTR [r14+0x30],0x0
    15a9:	mov    QWORD PTR [r14],rdx
    15ac:	mov    QWORD PTR [r14+0x8],rcx
    15b0:	mov    QWORD PTR [r14+0x10],r8
    15b4:	mov    QWORD PTR [rsp],rcx
    15b8:	mov    QWORD PTR [rsp+0x8],r8
    15bd:	xor    eax,eax
    15bf:	test   rdx,0x7
    15c6:	je     15d4 <botlish_fn_5+0xa4>
    15cc:	mov    rsi,rdx
    15cf:	jmp    15e0 <botlish_fn_5+0xb0>
    15d4:	movzx  rax,BYTE PTR [rdx]
    15d8:	mov    rsi,rdx
    15db:	cmp    al,0x3
    15dd:	sete   al
    15e0:	test   al,al
    15e2:	jne    1608 <botlish_fn_5+0xd8>
    15e8:	mov    rdi,r15
    15eb:	mov    rax,QWORD PTR [rdi+0x10]
    15ef:	mov    rcx,QWORD PTR [rax+0xb0]
    15f6:	mov    edx,0x4
    15fb:	call   1600 <botlish_fn_5+0xd0>
			15fc: R_X86_64_PLT32	rt_type_error-0x4
    1600:	mov    rdi,r15
    1603:	jmp    185c <botlish_fn_5+0x32c>
    1608:	mov    rbx,rsi
    160b:	mov    rdi,r15
    160e:	call   1613 <botlish_fn_5+0xe3>
			160f: R_X86_64_PLT32	rt_list_len-0x4
    1613:	mov    ecx,0x1
    1618:	mov    rsi,QWORD PTR [rsp]
    161c:	test   rsi,0x1
    1623:	jne    164b <botlish_fn_5+0x11b>
    1629:	xor    ecx,ecx
    162b:	mov    rsi,QWORD PTR [rsp]
    162f:	test   rsi,0x7
    1636:	jne    164b <botlish_fn_5+0x11b>
    163c:	mov    rsi,QWORD PTR [rsp]
    1640:	movzx  rcx,BYTE PTR [rsi]
    1644:	rex cmp cl,0x1
    1648:	sete   cl
    164b:	test   cl,cl
    164d:	jne    1675 <botlish_fn_5+0x145>
    1653:	mov    rdi,r15
    1656:	mov    rax,QWORD PTR [rdi+0x10]
    165a:	mov    rcx,QWORD PTR [rax+0xb8]
    1661:	xor    rdx,rdx
    1664:	mov    rsi,QWORD PTR [rsp]
    1668:	call   166d <botlish_fn_5+0x13d>
			1669: R_X86_64_PLT32	rt_type_error-0x4
    166d:	mov    rdi,r15
    1670:	jmp    185c <botlish_fn_5+0x32c>
    1675:	mov    rsi,QWORD PTR [rsp]
    1679:	mov    rcx,rsi
    167c:	and    rcx,rax
    167f:	mov    rdx,rax
    1682:	test   rcx,0x1
    1689:	jne    16b0 <botlish_fn_5+0x180>
    168f:	mov    rsi,QWORD PTR [rsp]
    1693:	mov    rdi,r15
    1696:	call   169b <botlish_fn_5+0x16b>
			1697: R_X86_64_PLT32	rt_int_cmp-0x4
    169b:	mov    edi,0x2
    16a0:	test   rax,rax
    16a3:	cmovge rdi,QWORD PTR [rip+0x255]        # 1900 <botlish_fn_5+0x3d0>
    16ab:	jmp    16c4 <botlish_fn_5+0x194>
    16b0:	mov    edi,0x2
    16b5:	mov    rsi,QWORD PTR [rsp]
    16b9:	cmp    rsi,rdx
    16bc:	cmovge rdi,QWORD PTR [rip+0x23c]        # 1900 <botlish_fn_5+0x3d0>
    16c4:	cmp    rdi,0x6
    16c8:	je     18a6 <botlish_fn_5+0x376>
    16ce:	mov    r12,r13
    16d1:	mov    QWORD PTR [r14+0x18],r12
    16d5:	mov    QWORD PTR [r14+0x20],0x3
    16dd:	mov    rsi,QWORD PTR [rsp]
    16e1:	test   rsi,0x1
    16e8:	je     170f <botlish_fn_5+0x1df>
    16ee:	mov    rsi,QWORD PTR [rsp]
    16f2:	mov    rax,rsi
    16f5:	add    rax,0x2
    16f9:	mov    rcx,rax
    16fc:	seto   al
    16ff:	test   al,al
    1701:	jne    170f <botlish_fn_5+0x1df>
    1707:	mov    r13,rcx
    170a:	jmp    1726 <botlish_fn_5+0x1f6>
    170f:	mov    edx,0x3
    1714:	mov    rsi,QWORD PTR [rsp]
    1718:	mov    rdi,r15
    171b:	call   1720 <botlish_fn_5+0x1f0>
			171c: R_X86_64_PLT32	rt_int_add-0x4
    1720:	mov    rcx,rax
    1723:	mov    r13,rcx
    1726:	mov    QWORD PTR [r14+0x8],r13
    172a:	mov    rdi,r15
    172d:	mov    rax,QWORD PTR [rdi+0x10]
    1731:	mov    rsi,QWORD PTR [rax+0xc0]
    1738:	mov    QWORD PTR [r14+0x20],rsi
    173c:	mov    QWORD PTR [rsp+0x18],rsi
    1741:	mov    rax,QWORD PTR [r12+0x20]
    1746:	mov    rsi,QWORD PTR [rax]
    1749:	mov    QWORD PTR [r14+0x28],rsi
    174d:	mov    QWORD PTR [rsp+0x10],rsi
    1752:	mov    rsi,QWORD PTR [rsp]
    1756:	test   rsi,0x1
    175d:	jne    176c <botlish_fn_5+0x23c>
    1763:	mov    rdx,QWORD PTR [rsp]
    1767:	jmp    1787 <botlish_fn_5+0x257>
    176c:	mov    rsi,QWORD PTR [rbx+0x8]
    1770:	mov    rdi,QWORD PTR [rsp]
    1774:	mov    rdx,rdi
    1777:	sar    rdx,1
    177a:	cmp    rdx,rsi
    177d:	jb     17ab <botlish_fn_5+0x27b>
    1783:	mov    rdx,QWORD PTR [rsp]
    1787:	mov    rsi,rbx
    178a:	mov    rdi,r15
    178d:	call   1792 <botlish_fn_5+0x262>
			178e: R_X86_64_PLT32	rt_list_get-0x4
    1792:	test   rax,rax
    1795:	jne    17a3 <botlish_fn_5+0x273>
    179b:	mov    rdi,r15
    179e:	jmp    185c <botlish_fn_5+0x32c>
    17a3:	mov    rdx,rax
    17a6:	jmp    17b3 <botlish_fn_5+0x283>
    17ab:	mov    r9,QWORD PTR [rbx+0x10]
    17af:	mov    rdx,QWORD PTR [r9+rdx*8]
    17b3:	mov    QWORD PTR [r14+0x30],rdx
    17b7:	mov    rsi,QWORD PTR [rsp+0x10]
    17bc:	mov    rdi,r15
    17bf:	call   17c4 <botlish_fn_5+0x294>
			17c0: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    17c4:	test   rax,rax
    17c7:	jne    17d5 <botlish_fn_5+0x2a5>
    17cd:	mov    rdi,r15
    17d0:	jmp    185c <botlish_fn_5+0x32c>
    17d5:	mov    QWORD PTR [r14+0x28],rax
    17d9:	mov    rdx,rax
    17dc:	mov    rsi,QWORD PTR [rsp+0x18]
    17e1:	mov    rdi,r15
    17e4:	call   17e9 <botlish_fn_5+0x2b9>
			17e5: R_X86_64_PLT32	rt_str_cat-0x4
    17e9:	test   rax,rax
    17ec:	jne    17fa <botlish_fn_5+0x2ca>
    17f2:	mov    rdi,r15
    17f5:	jmp    185c <botlish_fn_5+0x32c>
    17fa:	mov    QWORD PTR [r14+0x20],rax
    17fe:	mov    rdx,rax
    1801:	xor    edi,edi
    1803:	mov    rsi,QWORD PTR [rsp+0x8]
    1808:	test   rsi,0x7
    180f:	jne    181f <botlish_fn_5+0x2ef>
    1815:	movzx  rax,BYTE PTR [rsi]
    1819:	cmp    al,0x2
    181b:	sete   dil
    181f:	test   dil,dil
    1822:	jne    1848 <botlish_fn_5+0x318>
    1828:	mov    rdi,r15
    182b:	mov    rax,QWORD PTR [rdi+0x10]
    182f:	mov    rcx,QWORD PTR [rax+0xc8]
    1836:	mov    edx,0x1
    183b:	call   1840 <botlish_fn_5+0x310>
			183c: R_X86_64_PLT32	rt_type_error-0x4
    1840:	mov    rdi,r15
    1843:	jmp    185c <botlish_fn_5+0x32c>
    1848:	mov    rdi,r15
    184b:	call   1850 <botlish_fn_5+0x320>
			184c: R_X86_64_PLT32	rt_str_cat-0x4
    1850:	test   rax,rax
    1853:	jne    1887 <botlish_fn_5+0x357>
    1859:	mov    rdi,r15
    185c:	mov    rdi,r15
    185f:	mov    QWORD PTR [rdi],r14
    1862:	xor    rax,rax
    1865:	mov    rbx,QWORD PTR [rsp+0x20]
    186a:	mov    r12,QWORD PTR [rsp+0x28]
    186f:	mov    r13,QWORD PTR [rsp+0x30]
    1874:	mov    r14,QWORD PTR [rsp+0x38]
    1879:	mov    r15,QWORD PTR [rsp+0x40]
    187e:	add    rsp,0x50
    1882:	mov    rsp,rbp
    1885:	pop    rbp
    1886:	ret
    1887:	mov    QWORD PTR [r14],rbx
    188a:	mov    QWORD PTR [r14+0x8],r13
    188e:	mov    QWORD PTR [r14+0x10],rax
    1892:	mov    QWORD PTR [rsp+0x8],rax
    1897:	mov    QWORD PTR [rsp],r13
    189b:	mov    r13,r12
    189e:	mov    rdx,rbx
    18a1:	jmp    15bd <botlish_fn_5+0x8d>
    18a6:	mov    rdi,r15
    18a9:	mov    QWORD PTR [rdi],r14
    18ac:	mov    rax,QWORD PTR [rsp+0x8]
    18b1:	mov    rbx,QWORD PTR [rsp+0x20]
    18b6:	mov    r12,QWORD PTR [rsp+0x28]
    18bb:	mov    r13,QWORD PTR [rsp+0x30]
    18c0:	mov    r14,QWORD PTR [rsp+0x38]
    18c5:	mov    r15,QWORD PTR [rsp+0x40]
    18ca:	add    rsp,0x50
    18ce:	mov    rsp,rbp
    18d1:	pop    rbp
    18d2:	ret
    18d3:	mov    r15,rdi
    18d6:	call   18db <botlish_fn_5+0x3ab>
			18d7: R_X86_64_PLT32	rt_stack_overflow-0x4
    18db:	xor    rax,rax
    18de:	mov    rbx,QWORD PTR [rsp+0x20]
    18e3:	mov    r12,QWORD PTR [rsp+0x28]
    18e8:	mov    r13,QWORD PTR [rsp+0x30]
    18ed:	mov    r14,QWORD PTR [rsp+0x38]
    18f2:	mov    r15,QWORD PTR [rsp+0x40]
    18f7:	add    rsp,0x50
    18fb:	mov    rsp,rbp
    18fe:	pop    rbp
    18ff:	ret
    1900:	(bad)
    1901:	add    BYTE PTR [rax],al
    1903:	add    BYTE PTR [rax],al
    1905:	add    BYTE PTR [rax],al
	...

0000000000001908 <botlish_entry_5: esc_bytes<generic>>:
    1908:	push   rbp
    1909:	mov    rbp,rsp
    190c:	mov    r9,QWORD PTR [rdx]
    190f:	mov    rcx,QWORD PTR [rdx+0x8]
    1913:	mov    r8,QWORD PTR [rdx+0x10]
    1917:	mov    rdx,r9
    191a:	call   191f <botlish_entry_5+0x17>
			191b: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    191f:	mov    rsp,rbp
    1922:	pop    rbp
    1923:	ret

0000000000001924 <botlish_fn_6: esc_char<generic>>:
    1924:	push   rbp
    1925:	mov    rbp,rsp
    1928:	sub    rsp,0x40
    192c:	mov    QWORD PTR [rsp+0x10],rbx
    1931:	mov    QWORD PTR [rsp+0x18],r12
    1936:	mov    QWORD PTR [rsp+0x20],r13
    193b:	mov    QWORD PTR [rsp+0x28],r14
    1940:	mov    QWORD PTR [rsp+0x30],r15
    1945:	mov    rbx,rsi
    1948:	mov    r12,QWORD PTR [rdi]
    194b:	mov    rax,QWORD PTR [rdi+0x8]
    194f:	lea    rcx,[r12+0x20]
    1954:	cmp    rcx,rax
    1957:	ja     1b7a <botlish_fn_6+0x256>
    195d:	lea    rax,[r12+0x20]
    1962:	mov    QWORD PTR [rdi],rax
    1965:	mov    QWORD PTR [r12],0x0
    196d:	mov    QWORD PTR [r12+0x8],0x0
    1976:	mov    QWORD PTR [r12+0x10],0x0
    197f:	mov    QWORD PTR [r12+0x18],0x0
    1988:	mov    QWORD PTR [r12],rdx
    198c:	xor    eax,eax
    198e:	test   rdx,0x7
    1995:	je     19a3 <botlish_fn_6+0x7f>
    199b:	mov    r14,rdx
    199e:	jmp    19af <botlish_fn_6+0x8b>
    19a3:	movzx  rax,BYTE PTR [rdx]
    19a7:	mov    r14,rdx
    19aa:	cmp    al,0x2
    19ac:	sete   al
    19af:	test   al,al
    19b1:	jne    19da <botlish_fn_6+0xb6>
    19b7:	mov    rax,QWORD PTR [rdi+0x10]
    19bb:	mov    r13,rdi
    19be:	mov    rcx,QWORD PTR [rax+0xd0]
    19c5:	mov    edx,0x1
    19ca:	mov    rsi,r14
    19cd:	call   19d2 <botlish_fn_6+0xae>
			19ce: R_X86_64_PLT32	rt_type_error-0x4
    19d2:	mov    rdi,r13
    19d5:	jmp    1b1c <botlish_fn_6+0x1f8>
    19da:	mov    r13,rdi
    19dd:	mov    rsi,r14
    19e0:	call   19e5 <botlish_fn_6+0xc1>
			19e1: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    19e5:	mov    rcx,rax
    19e8:	mov    r15,rax
    19eb:	test   rax,rcx
    19ee:	jne    19fc <botlish_fn_6+0xd8>
    19f4:	mov    rdi,r13
    19f7:	jmp    1b1c <botlish_fn_6+0x1f8>
    19fc:	mov    rax,r15
    19ff:	mov    QWORD PTR [r12+0x8],rax
    1a04:	mov    rsi,r15
    1a07:	mov    rdi,r13
    1a0a:	call   1a0f <botlish_fn_6+0xeb>
			1a0b: R_X86_64_PLT32	rt_list_len-0x4
    1a0f:	mov    ecx,0x1
    1a14:	sar    rax,1
    1a17:	cmp    rax,0x1
    1a1b:	je     1a6c <botlish_fn_6+0x148>
    1a21:	mov    rsi,QWORD PTR [rbx+0x20]
    1a25:	mov    rsi,QWORD PTR [rsi]
    1a28:	mov    QWORD PTR [r12],rsi
    1a2c:	mov    QWORD PTR [r12+0x10],0x1
    1a35:	mov    rdi,r13
    1a38:	mov    rdi,QWORD PTR [rdi+0x10]
    1a3c:	mov    r8,QWORD PTR [rdi+0x98]
    1a43:	mov    QWORD PTR [r12+0x18],r8
    1a48:	mov    rdx,r15
    1a4b:	mov    rdi,r13
    1a4e:	call   1a53 <botlish_fn_6+0x12f>
			1a4f: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    1a53:	test   rax,rax
    1a56:	jne    1a64 <botlish_fn_6+0x140>
    1a5c:	mov    rdi,r13
    1a5f:	jmp    1b1c <botlish_fn_6+0x1f8>
    1a64:	mov    rdi,r13
    1a67:	jmp    1b52 <botlish_fn_6+0x22e>
    1a6c:	mov    rdx,r15
    1a6f:	mov    QWORD PTR [rsp],rcx
    1a73:	mov    r11,QWORD PTR [rdx+0x8]
    1a77:	mov    r15,rdx
    1a7a:	test   r11,r11
    1a7d:	jne    1aab <botlish_fn_6+0x187>
    1a83:	mov    rdx,QWORD PTR [rsp]
    1a87:	mov    rsi,r15
    1a8a:	mov    rdi,r13
    1a8d:	call   1a92 <botlish_fn_6+0x16e>
			1a8e: R_X86_64_PLT32	rt_list_get-0x4
    1a92:	test   rax,rax
    1a95:	jne    1aa3 <botlish_fn_6+0x17f>
    1a9b:	mov    rdi,r13
    1a9e:	jmp    1b1c <botlish_fn_6+0x1f8>
    1aa3:	mov    rsi,rax
    1aa6:	jmp    1ab5 <botlish_fn_6+0x191>
    1aab:	mov    rdx,r15
    1aae:	mov    rax,QWORD PTR [rdx+0x10]
    1ab2:	mov    rsi,QWORD PTR [rax]
    1ab5:	mov    QWORD PTR [r12+0x10],rsi
    1aba:	mov    rdi,r13
    1abd:	call   1ac2 <botlish_fn_6+0x19e>
			1abe: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    1ac2:	test   rax,rax
    1ac5:	jne    1ad3 <botlish_fn_6+0x1af>
    1acb:	mov    rdi,r13
    1ace:	jmp    1b1c <botlish_fn_6+0x1f8>
    1ad3:	cmp    rax,0x6
    1ad7:	je     1b4c <botlish_fn_6+0x228>
    1add:	mov    rax,QWORD PTR [rbx+0x20]
    1ae1:	mov    rsi,QWORD PTR [rax]
    1ae4:	mov    QWORD PTR [r12],rsi
    1ae8:	mov    QWORD PTR [r12+0x10],0x1
    1af1:	mov    rdi,r13
    1af4:	mov    rax,QWORD PTR [rdi+0x10]
    1af8:	mov    r8,QWORD PTR [rax+0x98]
    1aff:	mov    QWORD PTR [r12+0x18],r8
    1b04:	mov    rcx,QWORD PTR [rsp]
    1b08:	mov    rdx,r15
    1b0b:	call   1b10 <botlish_fn_6+0x1ec>
			1b0c: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    1b10:	test   rax,rax
    1b13:	jne    1b4f <botlish_fn_6+0x22b>
    1b19:	mov    rdi,r13
    1b1c:	mov    rdi,r13
    1b1f:	mov    QWORD PTR [rdi],r12
    1b22:	xor    rax,rax
    1b25:	mov    rbx,QWORD PTR [rsp+0x10]
    1b2a:	mov    r12,QWORD PTR [rsp+0x18]
    1b2f:	mov    r13,QWORD PTR [rsp+0x20]
    1b34:	mov    r14,QWORD PTR [rsp+0x28]
    1b39:	mov    r15,QWORD PTR [rsp+0x30]
    1b3e:	add    rsp,0x40
    1b42:	mov    rsp,rbp
    1b45:	pop    rbp
    1b46:	ret
    1b47:	jmp    1b4f <botlish_fn_6+0x22b>
    1b4c:	mov    rax,r14
    1b4f:	mov    rdi,r13
    1b52:	mov    rdi,r13
    1b55:	mov    QWORD PTR [rdi],r12
    1b58:	mov    rbx,QWORD PTR [rsp+0x10]
    1b5d:	mov    r12,QWORD PTR [rsp+0x18]
    1b62:	mov    r13,QWORD PTR [rsp+0x20]
    1b67:	mov    r14,QWORD PTR [rsp+0x28]
    1b6c:	mov    r15,QWORD PTR [rsp+0x30]
    1b71:	add    rsp,0x40
    1b75:	mov    rsp,rbp
    1b78:	pop    rbp
    1b79:	ret
    1b7a:	mov    r13,rdi
    1b7d:	call   1b82 <botlish_fn_6+0x25e>
			1b7e: R_X86_64_PLT32	rt_stack_overflow-0x4
    1b82:	xor    rax,rax
    1b85:	mov    rbx,QWORD PTR [rsp+0x10]
    1b8a:	mov    r12,QWORD PTR [rsp+0x18]
    1b8f:	mov    r13,QWORD PTR [rsp+0x20]
    1b94:	mov    r14,QWORD PTR [rsp+0x28]
    1b99:	mov    r15,QWORD PTR [rsp+0x30]
    1b9e:	add    rsp,0x40
    1ba2:	mov    rsp,rbp
    1ba5:	pop    rbp
    1ba6:	ret

0000000000001ba7 <botlish_entry_6: esc_char<generic>>:
    1ba7:	push   rbp
    1ba8:	mov    rbp,rsp
    1bab:	mov    rdx,QWORD PTR [rdx]
    1bae:	call   1bb3 <botlish_entry_6+0xc>
			1baf: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    1bb3:	mov    rsp,rbp
    1bb6:	pop    rbp
    1bb7:	ret

0000000000001bb8 <botlish_fn_7: esc_from<generic>>:
    1bb8:	push   rbp
    1bb9:	mov    rbp,rsp
    1bbc:	sub    rsp,0x50
    1bc0:	mov    QWORD PTR [rsp+0x20],rbx
    1bc5:	mov    QWORD PTR [rsp+0x28],r12
    1bca:	mov    QWORD PTR [rsp+0x30],r13
    1bcf:	mov    QWORD PTR [rsp+0x38],r14
    1bd4:	mov    QWORD PTR [rsp+0x40],r15
    1bd9:	mov    r12,rsi
    1bdc:	mov    r14,QWORD PTR [rdi]
    1bdf:	mov    rax,QWORD PTR [rdi+0x8]
    1be3:	lea    rsi,[r14+0x38]
    1be7:	cmp    rsi,rax
    1bea:	ja     1f7f <botlish_fn_7+0x3c7>
    1bf0:	lea    rax,[r14+0x38]
    1bf4:	mov    QWORD PTR [rdi],rax
    1bf7:	mov    r15,rdi
    1bfa:	mov    QWORD PTR [r14],0x0
    1c01:	mov    QWORD PTR [r14+0x8],0x0
    1c09:	mov    QWORD PTR [r14+0x10],0x0
    1c11:	mov    QWORD PTR [r14+0x18],0x0
    1c19:	mov    QWORD PTR [r14+0x20],0x0
    1c21:	mov    QWORD PTR [r14+0x28],0x0
    1c29:	mov    QWORD PTR [r14+0x30],0x0
    1c31:	mov    QWORD PTR [r14],rdx
    1c34:	mov    QWORD PTR [r14+0x8],rcx
    1c38:	mov    QWORD PTR [r14+0x10],r8
    1c3c:	mov    QWORD PTR [rsp],rcx
    1c40:	mov    QWORD PTR [rsp+0x8],r8
    1c45:	xor    eax,eax
    1c47:	test   rdx,0x7
    1c4e:	je     1c5c <botlish_fn_7+0xa4>
    1c54:	mov    rsi,rdx
    1c57:	jmp    1c68 <botlish_fn_7+0xb0>
    1c5c:	movzx  rax,BYTE PTR [rdx]
    1c60:	mov    rsi,rdx
    1c63:	cmp    al,0x2
    1c65:	sete   al
    1c68:	test   al,al
    1c6a:	jne    1c90 <botlish_fn_7+0xd8>
    1c70:	mov    rdi,r15
    1c73:	mov    rax,QWORD PTR [rdi+0x10]
    1c77:	mov    rcx,QWORD PTR [rax+0xd8]
    1c7e:	mov    edx,0x1
    1c83:	call   1c88 <botlish_fn_7+0xd0>
			1c84: R_X86_64_PLT32	rt_type_error-0x4
    1c88:	mov    rdi,r15
    1c8b:	jmp    1f0b <botlish_fn_7+0x353>
    1c90:	mov    rbx,rsi
    1c93:	mov    rdi,r15
    1c96:	call   1c9b <botlish_fn_7+0xe3>
			1c97: R_X86_64_PLT32	rt_str_len-0x4
    1c9b:	mov    edx,0x1
    1ca0:	mov    QWORD PTR [rsp+0x18],rdx
    1ca5:	mov    ecx,0x1
    1caa:	mov    rsi,QWORD PTR [rsp]
    1cae:	test   rsi,0x1
    1cb5:	jne    1cdd <botlish_fn_7+0x125>
    1cbb:	xor    ecx,ecx
    1cbd:	mov    rsi,QWORD PTR [rsp]
    1cc1:	test   rsi,0x7
    1cc8:	jne    1cdd <botlish_fn_7+0x125>
    1cce:	mov    rsi,QWORD PTR [rsp]
    1cd2:	movzx  rcx,BYTE PTR [rsi]
    1cd6:	rex cmp cl,0x1
    1cda:	sete   cl
    1cdd:	test   cl,cl
    1cdf:	jne    1d07 <botlish_fn_7+0x14f>
    1ce5:	mov    rdi,r15
    1ce8:	mov    rax,QWORD PTR [rdi+0x10]
    1cec:	mov    rcx,QWORD PTR [rax+0xb8]
    1cf3:	xor    rdx,rdx
    1cf6:	mov    rsi,QWORD PTR [rsp]
    1cfa:	call   1cff <botlish_fn_7+0x147>
			1cfb: R_X86_64_PLT32	rt_type_error-0x4
    1cff:	mov    rdi,r15
    1d02:	jmp    1f0b <botlish_fn_7+0x353>
    1d07:	mov    rsi,QWORD PTR [rsp]
    1d0b:	mov    rcx,rsi
    1d0e:	and    rcx,rax
    1d11:	mov    rdx,rax
    1d14:	test   rcx,0x1
    1d1b:	jne    1d43 <botlish_fn_7+0x18b>
    1d21:	mov    rsi,QWORD PTR [rsp]
    1d25:	mov    rdi,r15
    1d28:	call   1d2d <botlish_fn_7+0x175>
			1d29: R_X86_64_PLT32	rt_int_cmp-0x4
    1d2d:	mov    r8d,0x2
    1d33:	test   rax,rax
    1d36:	cmovge r8,QWORD PTR [rip+0x272]        # 1fb0 <botlish_fn_7+0x3f8>
    1d3e:	jmp    1d58 <botlish_fn_7+0x1a0>
    1d43:	mov    r8d,0x2
    1d49:	mov    rsi,QWORD PTR [rsp]
    1d4d:	cmp    rsi,rdx
    1d50:	cmovge r8,QWORD PTR [rip+0x258]        # 1fb0 <botlish_fn_7+0x3f8>
    1d58:	cmp    r8,0x6
    1d5c:	je     1f52 <botlish_fn_7+0x39a>
    1d62:	mov    QWORD PTR [r14+0x18],r12
    1d66:	mov    QWORD PTR [r14+0x20],0x3
    1d6e:	mov    rsi,QWORD PTR [rsp]
    1d72:	test   rsi,0x1
    1d79:	je     1da0 <botlish_fn_7+0x1e8>
    1d7f:	mov    rsi,QWORD PTR [rsp]
    1d83:	mov    rax,rsi
    1d86:	add    rax,0x2
    1d8a:	mov    rcx,rax
    1d8d:	seto   al
    1d90:	test   al,al
    1d92:	jne    1da0 <botlish_fn_7+0x1e8>
    1d98:	mov    r13,rcx
    1d9b:	jmp    1db7 <botlish_fn_7+0x1ff>
    1da0:	mov    edx,0x3
    1da5:	mov    rsi,QWORD PTR [rsp]
    1da9:	mov    rdi,r15
    1dac:	call   1db1 <botlish_fn_7+0x1f9>
			1dad: R_X86_64_PLT32	rt_int_add-0x4
    1db1:	mov    rcx,rax
    1db4:	mov    r13,rcx
    1db7:	mov    QWORD PTR [r14+0x20],r13
    1dbb:	mov    rdx,QWORD PTR [r12+0x20]
    1dc0:	mov    rsi,QWORD PTR [rdx]
    1dc3:	mov    QWORD PTR [r14+0x28],rsi
    1dc7:	mov    QWORD PTR [rsp+0x10],rsi
    1dcc:	mov    QWORD PTR [r14+0x30],0x3
    1dd4:	mov    rsi,QWORD PTR [rsp]
    1dd8:	test   rsi,0x1
    1ddf:	je     1dfd <botlish_fn_7+0x245>
    1de5:	mov    rsi,QWORD PTR [rsp]
    1de9:	mov    rcx,rsi
    1dec:	add    rcx,0x2
    1df0:	seto   r8b
    1df4:	test   r8b,r8b
    1df7:	je     1e11 <botlish_fn_7+0x259>
    1dfd:	mov    edx,0x3
    1e02:	mov    rsi,QWORD PTR [rsp]
    1e06:	mov    rdi,r15
    1e09:	call   1e0e <botlish_fn_7+0x256>
			1e0a: R_X86_64_PLT32	rt_int_add-0x4
    1e0e:	mov    rcx,rax
    1e11:	mov    QWORD PTR [r14+0x30],rcx
    1e15:	mov    rdx,QWORD PTR [rsp]
    1e19:	mov    rsi,rbx
    1e1c:	mov    rdi,r15
    1e1f:	call   1e24 <botlish_fn_7+0x26c>
			1e20: R_X86_64_PLT32	rt_substr-0x4
    1e24:	test   rax,rax
    1e27:	jne    1e35 <botlish_fn_7+0x27d>
    1e2d:	mov    rdi,r15
    1e30:	jmp    1f0b <botlish_fn_7+0x353>
    1e35:	mov    QWORD PTR [r14+0x8],rax
    1e39:	mov    rdx,rax
    1e3c:	mov    rsi,QWORD PTR [rsp+0x10]
    1e41:	mov    rdi,r15
    1e44:	call   1e49 <botlish_fn_7+0x291>
			1e45: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    1e49:	test   rax,rax
    1e4c:	jne    1e5a <botlish_fn_7+0x2a2>
    1e52:	mov    rdi,r15
    1e55:	jmp    1f0b <botlish_fn_7+0x353>
    1e5a:	mov    QWORD PTR [r14+0x8],rax
    1e5e:	xor    ecx,ecx
    1e60:	mov    rsi,QWORD PTR [rsp+0x8]
    1e65:	test   rsi,0x7
    1e6c:	jne    1e7d <botlish_fn_7+0x2c5>
    1e72:	movzx  rcx,BYTE PTR [rsi]
    1e76:	rex cmp cl,0x2
    1e7a:	sete   cl
    1e7d:	test   cl,cl
    1e7f:	jne    1ea5 <botlish_fn_7+0x2ed>
    1e85:	mov    rdi,r15
    1e88:	mov    rax,QWORD PTR [rdi+0x10]
    1e8c:	mov    rcx,QWORD PTR [rax+0xc8]
    1e93:	mov    rdx,QWORD PTR [rsp+0x18]
    1e98:	call   1e9d <botlish_fn_7+0x2e5>
			1e99: R_X86_64_PLT32	rt_type_error-0x4
    1e9d:	mov    rdi,r15
    1ea0:	jmp    1f0b <botlish_fn_7+0x353>
    1ea5:	mov    rdx,QWORD PTR [rsp+0x18]
    1eaa:	xor    ecx,ecx
    1eac:	test   rax,0x7
    1eb2:	je     1ec0 <botlish_fn_7+0x308>
    1eb8:	mov    r8,rax
    1ebb:	jmp    1ece <botlish_fn_7+0x316>
    1ec0:	movzx  rcx,BYTE PTR [rax]
    1ec4:	mov    r8,rax
    1ec7:	rex cmp cl,0x2
    1ecb:	sete   cl
    1ece:	test   cl,cl
    1ed0:	jne    1ef4 <botlish_fn_7+0x33c>
    1ed6:	mov    rdi,r15
    1ed9:	mov    rax,QWORD PTR [rdi+0x10]
    1edd:	mov    rcx,QWORD PTR [rax+0xc8]
    1ee4:	mov    rsi,r8
    1ee7:	call   1eec <botlish_fn_7+0x334>
			1ee8: R_X86_64_PLT32	rt_type_error-0x4
    1eec:	mov    rdi,r15
    1eef:	jmp    1f0b <botlish_fn_7+0x353>
    1ef4:	mov    rdx,r8
    1ef7:	mov    rdi,r15
    1efa:	call   1eff <botlish_fn_7+0x347>
			1efb: R_X86_64_PLT32	rt_str_cat-0x4
    1eff:	test   rax,rax
    1f02:	jne    1f36 <botlish_fn_7+0x37e>
    1f08:	mov    rdi,r15
    1f0b:	mov    rdi,r15
    1f0e:	mov    QWORD PTR [rdi],r14
    1f11:	xor    rax,rax
    1f14:	mov    rbx,QWORD PTR [rsp+0x20]
    1f19:	mov    r12,QWORD PTR [rsp+0x28]
    1f1e:	mov    r13,QWORD PTR [rsp+0x30]
    1f23:	mov    r14,QWORD PTR [rsp+0x38]
    1f28:	mov    r15,QWORD PTR [rsp+0x40]
    1f2d:	add    rsp,0x50
    1f31:	mov    rsp,rbp
    1f34:	pop    rbp
    1f35:	ret
    1f36:	mov    QWORD PTR [r14],rbx
    1f39:	mov    QWORD PTR [r14+0x8],r13
    1f3d:	mov    QWORD PTR [r14+0x10],rax
    1f41:	mov    rdx,rbx
    1f44:	mov    QWORD PTR [rsp],r13
    1f48:	mov    QWORD PTR [rsp+0x8],rax
    1f4d:	jmp    1c45 <botlish_fn_7+0x8d>
    1f52:	mov    rdi,r15
    1f55:	mov    QWORD PTR [rdi],r14
    1f58:	mov    rax,QWORD PTR [rsp+0x8]
    1f5d:	mov    rbx,QWORD PTR [rsp+0x20]
    1f62:	mov    r12,QWORD PTR [rsp+0x28]
    1f67:	mov    r13,QWORD PTR [rsp+0x30]
    1f6c:	mov    r14,QWORD PTR [rsp+0x38]
    1f71:	mov    r15,QWORD PTR [rsp+0x40]
    1f76:	add    rsp,0x50
    1f7a:	mov    rsp,rbp
    1f7d:	pop    rbp
    1f7e:	ret
    1f7f:	mov    r15,rdi
    1f82:	call   1f87 <botlish_fn_7+0x3cf>
			1f83: R_X86_64_PLT32	rt_stack_overflow-0x4
    1f87:	xor    rax,rax
    1f8a:	mov    rbx,QWORD PTR [rsp+0x20]
    1f8f:	mov    r12,QWORD PTR [rsp+0x28]
    1f94:	mov    r13,QWORD PTR [rsp+0x30]
    1f99:	mov    r14,QWORD PTR [rsp+0x38]
    1f9e:	mov    r15,QWORD PTR [rsp+0x40]
    1fa3:	add    rsp,0x50
    1fa7:	mov    rsp,rbp
    1faa:	pop    rbp
    1fab:	ret
    1fac:	add    BYTE PTR [rax],al
    1fae:	add    BYTE PTR [rax],al
    1fb0:	(bad)
    1fb1:	add    BYTE PTR [rax],al
    1fb3:	add    BYTE PTR [rax],al
    1fb5:	add    BYTE PTR [rax],al
	...

0000000000001fb8 <botlish_entry_7: esc_from<generic>>:
    1fb8:	push   rbp
    1fb9:	mov    rbp,rsp
    1fbc:	mov    r9,QWORD PTR [rdx]
    1fbf:	mov    rcx,QWORD PTR [rdx+0x8]
    1fc3:	mov    r8,QWORD PTR [rdx+0x10]
    1fc7:	mov    rdx,r9
    1fca:	call   1fcf <botlish_entry_7+0x17>
			1fcb: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
    1fcf:	mov    rsp,rbp
    1fd2:	pop    rbp
    1fd3:	ret
    1fd4:	add    BYTE PTR [rax],al
	...

0000000000001fd8 <botlish_fn_8: check<int, int, str, str>>:
    1fd8:	push   rbp
    1fd9:	mov    rbp,rsp
    1fdc:	sub    rsp,0x40
    1fe0:	mov    QWORD PTR [rsp+0x10],rbx
    1fe5:	mov    QWORD PTR [rsp+0x18],r12
    1fea:	mov    QWORD PTR [rsp+0x20],r13
    1fef:	mov    QWORD PTR [rsp+0x28],r14
    1ff4:	mov    QWORD PTR [rsp+0x30],r15
    1ff9:	mov    r13,QWORD PTR [rdi]
    1ffc:	mov    rax,QWORD PTR [rdi+0x8]
    2000:	lea    r9,[r13+0x28]
    2004:	cmp    r9,rax
    2007:	ja     21e3 <botlish_fn_8+0x20b>
    200d:	lea    rax,[r13+0x28]
    2011:	mov    QWORD PTR [rdi],rax
    2014:	mov    r14,rdi
    2017:	mov    QWORD PTR [r13+0x0],0x0
    201f:	mov    QWORD PTR [r13+0x8],0x0
    2027:	mov    QWORD PTR [r13+0x10],0x0
    202f:	mov    QWORD PTR [r13+0x18],0x0
    2037:	mov    QWORD PTR [r13+0x20],0x0
    203f:	mov    QWORD PTR [r13+0x0],rsi
    2043:	mov    QWORD PTR [r13+0x8],rdx
    2047:	mov    QWORD PTR [r13+0x10],rcx
    204b:	mov    r12,rcx
    204e:	mov    QWORD PTR [r13+0x18],r8
    2052:	mov    r15,r8
    2055:	mov    rbx,rsi
    2058:	mov    QWORD PTR [rsp],rdx
    205c:	test   rbx,0x1
    2063:	jne    208e <botlish_fn_8+0xb6>
    2069:	mov    edx,0x1
    206e:	mov    rsi,rbx
    2071:	mov    rdi,r14
    2074:	call   2079 <botlish_fn_8+0xa1>
			2075: R_X86_64_PLT32	rt_int_cmp-0x4
    2079:	mov    ecx,0x2
    207e:	test   rax,rax
    2081:	cmovle rcx,QWORD PTR [rip+0x187]        # 2210 <botlish_fn_8+0x238>
    2089:	jmp    209f <botlish_fn_8+0xc7>
    208e:	mov    ecx,0x2
    2093:	cmp    rbx,0x1
    2097:	cmovle rcx,QWORD PTR [rip+0x171]        # 2210 <botlish_fn_8+0x238>
    209f:	cmp    rcx,0x6
    20a3:	je     21b7 <botlish_fn_8+0x1df>
    20a9:	mov    rdi,r14
    20ac:	mov    rdx,QWORD PTR [rdi+0x10]
    20b0:	mov    rdx,QWORD PTR [rdx+0xe0]
    20b7:	mov    rsi,r12
    20ba:	call   20bf <botlish_fn_8+0xe7>
			20bb: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    20bf:	test   rax,rax
    20c2:	jne    20d0 <botlish_fn_8+0xf8>
    20c8:	mov    rdi,r14
    20cb:	jmp    210e <botlish_fn_8+0x136>
    20d0:	cmp    rax,0x6
    20d4:	je     20ec <botlish_fn_8+0x114>
    20da:	mov    edx,0x1
    20df:	mov    QWORD PTR [r13+0x0],0x1
    20e7:	jmp    2156 <botlish_fn_8+0x17e>
    20ec:	mov    rdi,r14
    20ef:	mov    r9,QWORD PTR [rdi+0x10]
    20f3:	mov    r9,QWORD PTR [r9+0xe8]
    20fa:	mov    rsi,r12
    20fd:	call   2102 <botlish_fn_8+0x12a>
			20fe: R_X86_64_PLT32	botlish_fn_20-0x4 ; <str>
    2102:	test   rax,rax
    2105:	jne    2139 <botlish_fn_8+0x161>
    210b:	mov    rdi,r14
    210e:	mov    rdi,r14
    2111:	mov    QWORD PTR [rdi],r13
    2114:	xor    rax,rax
    2117:	mov    rbx,QWORD PTR [rsp+0x10]
    211c:	mov    r12,QWORD PTR [rsp+0x18]
    2121:	mov    r13,QWORD PTR [rsp+0x20]
    2126:	mov    r14,QWORD PTR [rsp+0x28]
    212b:	mov    r15,QWORD PTR [rsp+0x30]
    2130:	add    rsp,0x40
    2134:	mov    rsp,rbp
    2137:	pop    rbp
    2138:	ret
    2139:	cmp    rax,0x6
    213d:	je     214d <botlish_fn_8+0x175>
    2143:	mov    edx,0x1
    2148:	jmp    2152 <botlish_fn_8+0x17a>
    214d:	mov    edx,0x3
    2152:	mov    QWORD PTR [r13+0x0],rdx
    2156:	sar    rbx,1
    2159:	sub    rbx,0x1
    215d:	shl    rbx,1
    2160:	or     rbx,0x1
    2164:	mov    QWORD PTR [r13+0x20],rbx
    2168:	mov    rsi,QWORD PTR [rsp]
    216c:	mov    rax,rsi
    216f:	and    rax,rdx
    2172:	test   rax,0x1
    2178:	je     2193 <botlish_fn_8+0x1bb>
    217e:	lea    rcx,[rdx-0x1]
    2182:	mov    rax,rsi
    2185:	add    rax,rcx
    2188:	seto   cl
    218b:	test   cl,cl
    218d:	je     219b <botlish_fn_8+0x1c3>
    2193:	mov    rdi,r14
    2196:	call   219b <botlish_fn_8+0x1c3>
			2197: R_X86_64_PLT32	rt_int_add-0x4
    219b:	mov    QWORD PTR [r13+0x0],rbx
    219f:	mov    QWORD PTR [r13+0x8],rax
    21a3:	mov    QWORD PTR [r13+0x10],r12
    21a7:	mov    r8,r15
    21aa:	mov    QWORD PTR [r13+0x18],r8
    21ae:	mov    QWORD PTR [rsp],rax
    21b2:	jmp    205c <botlish_fn_8+0x84>
    21b7:	mov    rdi,r14
    21ba:	mov    QWORD PTR [rdi],r13
    21bd:	mov    rax,QWORD PTR [rsp]
    21c1:	mov    rbx,QWORD PTR [rsp+0x10]
    21c6:	mov    r12,QWORD PTR [rsp+0x18]
    21cb:	mov    r13,QWORD PTR [rsp+0x20]
    21d0:	mov    r14,QWORD PTR [rsp+0x28]
    21d5:	mov    r15,QWORD PTR [rsp+0x30]
    21da:	add    rsp,0x40
    21de:	mov    rsp,rbp
    21e1:	pop    rbp
    21e2:	ret
    21e3:	mov    r14,rdi
    21e6:	call   21eb <botlish_fn_8+0x213>
			21e7: R_X86_64_PLT32	rt_stack_overflow-0x4
    21eb:	xor    rax,rax
    21ee:	mov    rbx,QWORD PTR [rsp+0x10]
    21f3:	mov    r12,QWORD PTR [rsp+0x18]
    21f8:	mov    r13,QWORD PTR [rsp+0x20]
    21fd:	mov    r14,QWORD PTR [rsp+0x28]
    2202:	mov    r15,QWORD PTR [rsp+0x30]
    2207:	add    rsp,0x40
    220b:	mov    rsp,rbp
    220e:	pop    rbp
    220f:	ret
    2210:	(bad)
    2211:	add    BYTE PTR [rax],al
    2213:	add    BYTE PTR [rax],al
    2215:	add    BYTE PTR [rax],al
	...

0000000000002218 <botlish_entry_8: check<int, int, str, str>>:
    2218:	push   rbp
    2219:	mov    rbp,rsp
    221c:	mov    rsi,QWORD PTR [rdx]
    221f:	mov    r9,QWORD PTR [rdx+0x8]
    2223:	mov    rcx,QWORD PTR [rdx+0x10]
    2227:	mov    r8,QWORD PTR [rdx+0x18]
    222b:	mov    rdx,r9
    222e:	call   2233 <botlish_entry_8+0x1b>
			222f: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
    2233:	mov    rsp,rbp
    2236:	pop    rbp
    2237:	ret

0000000000002238 <botlish_fn_9: <str>>:
    2238:	push   rbp
    2239:	mov    rbp,rsp
    223c:	sub    rsp,0xc0
    2243:	mov    QWORD PTR [rsp+0x90],rbx
    224b:	mov    QWORD PTR [rsp+0x98],r12
    2253:	mov    QWORD PTR [rsp+0xa0],r13
    225b:	mov    QWORD PTR [rsp+0xa8],r14
    2263:	mov    QWORD PTR [rsp+0xb0],r15
    226b:	mov    r12,QWORD PTR [rdi]
    226e:	mov    rax,QWORD PTR [rdi+0x8]
    2272:	lea    rcx,[r12+0x28]
    2277:	cmp    rcx,rax
    227a:	ja     269b <botlish_fn_9+0x463>
    2280:	lea    rax,[r12+0x28]
    2285:	mov    QWORD PTR [rdi],rax
    2288:	mov    QWORD PTR [rsp+0x78],rdi
    228d:	mov    QWORD PTR [r12],0x0
    2295:	mov    QWORD PTR [r12+0x8],0x0
    229e:	mov    QWORD PTR [r12+0x10],0x0
    22a7:	mov    QWORD PTR [r12+0x18],0x0
    22b0:	mov    QWORD PTR [r12+0x20],0x0
    22b9:	mov    QWORD PTR [r12],rsi
    22bd:	mov    r13,rsi
    22c0:	mov    rsi,r13
    22c3:	mov    rdi,QWORD PTR [rsp+0x78]
    22c8:	call   22cd <botlish_fn_9+0x95>
			22c9: R_X86_64_PLT32	rt_str_len-0x4
    22cd:	mov    rbx,rax
    22d0:	mov    QWORD PTR [r12+0x8],rbx
    22d5:	lea    r8,[rsp]
    22d9:	mov    QWORD PTR [rsp],r13
    22dd:	mov    esi,0xb
    22e2:	mov    rdx,QWORD PTR [rip+0x0]        # 22e9 <botlish_fn_9+0xb1>
			22e5: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    22e9:	mov    r13d,0x1
    22ef:	mov    rcx,r13
    22f2:	mov    rdi,QWORD PTR [rsp+0x78]
    22f7:	call   22fc <botlish_fn_9+0xc4>
			22f8: R_X86_64_PLT32	rt_closure_new-0x4
    22fc:	mov    r14,rax
    22ff:	mov    QWORD PTR [r12],rax
    2303:	lea    r8,[rsp+0x8]
    2308:	mov    QWORD PTR [rsp+0x8],rbx
    230d:	mov    QWORD PTR [rsp+0x10],rax
    2312:	mov    esi,0xf
    2317:	mov    rdx,QWORD PTR [rip+0x0]        # 231e <botlish_fn_9+0xe6>
			231a: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_local<generic>
    231e:	mov    r15d,0x2
    2324:	mov    rcx,r15
    2327:	mov    rdi,QWORD PTR [rsp+0x78]
    232c:	call   2331 <botlish_fn_9+0xf9>
			232d: R_X86_64_PLT32	rt_closure_new-0x4
    2331:	mov    rsi,rax
    2334:	mov    QWORD PTR [rsp+0x88],rax
    233c:	mov    QWORD PTR [r12+0x10],rsi
    2341:	lea    r8,[rsp+0x18]
    2346:	mov    QWORD PTR [rsp+0x18],rbx
    234b:	mov    rax,r14
    234e:	mov    QWORD PTR [rsp+0x20],rax
    2353:	mov    esi,0x10
    2358:	mov    rdx,QWORD PTR [rip+0x0]        # 235f <botlish_fn_9+0x127>
			235b: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; scan_label<generic>
    235f:	mov    rcx,r15
    2362:	mov    rdi,QWORD PTR [rsp+0x78]
    2367:	call   236c <botlish_fn_9+0x134>
			2368: R_X86_64_PLT32	rt_closure_new-0x4
    236c:	mov    QWORD PTR [r12+0x18],rax
    2371:	mov    QWORD PTR [rsp+0x80],rax
    2379:	lea    r8,[rsp+0x28]
    237e:	mov    QWORD PTR [rsp+0x28],rbx
    2383:	mov    QWORD PTR [rsp+0x30],r14
    2388:	mov    esi,0x11
    238d:	mov    rdx,QWORD PTR [rip+0x0]        # 2394 <botlish_fn_9+0x15c>
			2390: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; scan_alpha<generic>
    2394:	mov    rcx,r15
    2397:	mov    rdi,QWORD PTR [rsp+0x78]
    239c:	call   23a1 <botlish_fn_9+0x169>
			239d: R_X86_64_PLT32	rt_closure_new-0x4
    23a1:	mov    QWORD PTR [r12+0x20],rax
    23a6:	lea    r8,[rsp+0x38]
    23ab:	mov    QWORD PTR [rsp+0x38],rax
    23b0:	mov    QWORD PTR [rsp+0x40],rbx
    23b5:	mov    esi,0x12
    23ba:	mov    rdx,QWORD PTR [rip+0x0]        # 23c1 <botlish_fn_9+0x189>
			23bd: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; tld_ok<generic>
    23c1:	mov    rcx,r15
    23c4:	mov    rdi,QWORD PTR [rsp+0x78]
    23c9:	call   23ce <botlish_fn_9+0x196>
			23ca: R_X86_64_PLT32	rt_closure_new-0x4
    23ce:	mov    QWORD PTR [r12+0x20],rax
    23d3:	lea    r8,[rsp+0x48]
    23d8:	mov    rcx,QWORD PTR [rsp+0x80]
    23e0:	mov    QWORD PTR [rsp+0x48],rcx
    23e5:	mov    QWORD PTR [rsp+0x50],rbx
    23ea:	mov    QWORD PTR [rsp+0x58],r14
    23ef:	mov    QWORD PTR [rsp+0x60],rax
    23f4:	mov    esi,0x13
    23f9:	mov    rdx,QWORD PTR [rip+0x0]        # 2400 <botlish_fn_9+0x1c8>
			23fc: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; domain_loop<generic>
    2400:	mov    ecx,0x4
    2405:	mov    rdi,QWORD PTR [rsp+0x78]
    240a:	call   240f <botlish_fn_9+0x1d7>
			240b: R_X86_64_PLT32	rt_closure_new-0x4
    240f:	mov    QWORD PTR [r12+0x18],rax
    2414:	mov    r15,rax
    2417:	mov    QWORD PTR [r12+0x20],0x1
    2420:	mov    rdx,r13
    2423:	mov    rsi,QWORD PTR [rsp+0x88]
    242b:	mov    rdi,QWORD PTR [rsp+0x78]
    2430:	call   2435 <botlish_fn_9+0x1fd>
			2431: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    2435:	mov    rcx,rax
    2438:	mov    r13,rax
    243b:	test   rax,rcx
    243e:	jne    244e <botlish_fn_9+0x216>
    2444:	mov    rdi,QWORD PTR [rsp+0x78]
    2449:	jmp    25b1 <botlish_fn_9+0x379>
    244e:	mov    rax,r13
    2451:	mov    QWORD PTR [r12+0x10],rax
    2456:	test   rax,0x1
    245c:	jne    2489 <botlish_fn_9+0x251>
    2462:	mov    edx,0x1
    2467:	mov    rsi,r13
    246a:	mov    rdi,QWORD PTR [rsp+0x78]
    246f:	call   2474 <botlish_fn_9+0x23c>
			2470: R_X86_64_PLT32	rt_int_cmp-0x4
    2474:	mov    ecx,0x2
    2479:	test   rax,rax
    247c:	cmove  rcx,QWORD PTR [rip+0x25c]        # 26e0 <botlish_fn_9+0x4a8>
    2484:	jmp    249a <botlish_fn_9+0x262>
    2489:	mov    ecx,0x2
    248e:	cmp    r13,0x1
    2492:	cmove  rcx,QWORD PTR [rip+0x246]        # 26e0 <botlish_fn_9+0x4a8>
    249a:	cmp    rcx,0x6
    249e:	je     2655 <botlish_fn_9+0x41d>
    24a4:	mov    rax,r13
    24a7:	and    rax,rbx
    24aa:	test   rax,0x1
    24b0:	jne    24db <botlish_fn_9+0x2a3>
    24b6:	mov    rdx,rbx
    24b9:	mov    rsi,r13
    24bc:	mov    rdi,QWORD PTR [rsp+0x78]
    24c1:	call   24c6 <botlish_fn_9+0x28e>
			24c2: R_X86_64_PLT32	rt_int_cmp-0x4
    24c6:	mov    ecx,0x2
    24cb:	test   rax,rax
    24ce:	cmovge rcx,QWORD PTR [rip+0x20a]        # 26e0 <botlish_fn_9+0x4a8>
    24d6:	jmp    24eb <botlish_fn_9+0x2b3>
    24db:	mov    ecx,0x2
    24e0:	cmp    r13,rbx
    24e3:	cmovge rcx,QWORD PTR [rip+0x1f5]        # 26e0 <botlish_fn_9+0x4a8>
    24eb:	cmp    rcx,0x6
    24ef:	je     2646 <botlish_fn_9+0x40e>
    24f5:	lea    rcx,[rsp+0x68]
    24fa:	mov    rsi,r14
    24fd:	mov    rdx,r13
    2500:	mov    rdi,QWORD PTR [rsp+0x78]
    2505:	call   250a <botlish_fn_9+0x2d2>
			2506: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    250a:	test   rax,rax
    250d:	mov    rsi,rax
    2510:	jne    2520 <botlish_fn_9+0x2e8>
    2516:	mov    rdi,QWORD PTR [rsp+0x78]
    251b:	jmp    25b1 <botlish_fn_9+0x379>
    2520:	mov    rdx,QWORD PTR [rsp+0x68]
    2525:	mov    rcx,QWORD PTR [rsp+0x70]
    252a:	mov    rdi,QWORD PTR [rsp+0x78]
    252f:	mov    r8,QWORD PTR [rdi+0x10]
    2533:	mov    r8,QWORD PTR [r8+0x100]
    253a:	call   253f <botlish_fn_9+0x307>
			253b: R_X86_64_PLT32	rt_str_region_eq-0x4
    253f:	cmp    rax,0x6
    2543:	je     2556 <botlish_fn_9+0x31e>
    2549:	mov    ecx,0x2
    254e:	mov    rax,rcx
    2551:	jmp    264b <botlish_fn_9+0x413>
    2556:	mov    QWORD PTR [r12],0x3
    255e:	test   r13,0x1
    2565:	je     257d <botlish_fn_9+0x345>
    256b:	mov    rdx,r13
    256e:	add    rdx,0x2
    2572:	seto   al
    2575:	test   al,al
    2577:	je     2592 <botlish_fn_9+0x35a>
    257d:	mov    edx,0x3
    2582:	mov    rsi,r13
    2585:	mov    rdi,QWORD PTR [rsp+0x78]
    258a:	call   258f <botlish_fn_9+0x357>
			258b: R_X86_64_PLT32	rt_int_add-0x4
    258f:	mov    rdx,rax
    2592:	mov    QWORD PTR [r12],rdx
    2596:	mov    rsi,r15
    2599:	mov    rdi,QWORD PTR [rsp+0x78]
    259e:	call   25a3 <botlish_fn_9+0x36b>
			259f: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    25a3:	test   rax,rax
    25a6:	jne    25f0 <botlish_fn_9+0x3b8>
    25ac:	mov    rdi,QWORD PTR [rsp+0x78]
    25b1:	mov    rdi,QWORD PTR [rsp+0x78]
    25b6:	mov    QWORD PTR [rdi],r12
    25b9:	xor    rax,rax
    25bc:	mov    rbx,QWORD PTR [rsp+0x90]
    25c4:	mov    r12,QWORD PTR [rsp+0x98]
    25cc:	mov    r13,QWORD PTR [rsp+0xa0]
    25d4:	mov    r14,QWORD PTR [rsp+0xa8]
    25dc:	mov    r15,QWORD PTR [rsp+0xb0]
    25e4:	add    rsp,0xc0
    25eb:	mov    rsp,rbp
    25ee:	pop    rbp
    25ef:	ret
    25f0:	mov    rcx,rax
    25f3:	and    rcx,rbx
    25f6:	mov    rsi,rax
    25f9:	mov    rax,rbx
    25fc:	test   rcx,0x1
    2603:	jne    262e <botlish_fn_9+0x3f6>
    2609:	mov    rdx,rax
    260c:	mov    rdi,QWORD PTR [rsp+0x78]
    2611:	call   2616 <botlish_fn_9+0x3de>
			2612: R_X86_64_PLT32	rt_int_cmp-0x4
    2616:	mov    ecx,0x2
    261b:	test   rax,rax
    261e:	mov    rax,rcx
    2621:	cmove  rax,QWORD PTR [rip+0xb7]        # 26e0 <botlish_fn_9+0x4a8>
    2629:	jmp    264b <botlish_fn_9+0x413>
    262e:	mov    rdx,rax
    2631:	mov    eax,0x2
    2636:	cmp    rsi,rdx
    2639:	cmove  rax,QWORD PTR [rip+0x9f]        # 26e0 <botlish_fn_9+0x4a8>
    2641:	jmp    264b <botlish_fn_9+0x413>
    2646:	mov    eax,0x2
    264b:	mov    rdi,QWORD PTR [rsp+0x78]
    2650:	jmp    265f <botlish_fn_9+0x427>
    2655:	mov    eax,0x2
    265a:	mov    rdi,QWORD PTR [rsp+0x78]
    265f:	mov    rdi,QWORD PTR [rsp+0x78]
    2664:	mov    QWORD PTR [rdi],r12
    2667:	mov    rbx,QWORD PTR [rsp+0x90]
    266f:	mov    r12,QWORD PTR [rsp+0x98]
    2677:	mov    r13,QWORD PTR [rsp+0xa0]
    267f:	mov    r14,QWORD PTR [rsp+0xa8]
    2687:	mov    r15,QWORD PTR [rsp+0xb0]
    268f:	add    rsp,0xc0
    2696:	mov    rsp,rbp
    2699:	pop    rbp
    269a:	ret
    269b:	mov    QWORD PTR [rsp+0x78],rdi
    26a0:	call   26a5 <botlish_fn_9+0x46d>
			26a1: R_X86_64_PLT32	rt_stack_overflow-0x4
    26a5:	xor    rax,rax
    26a8:	mov    rbx,QWORD PTR [rsp+0x90]
    26b0:	mov    r12,QWORD PTR [rsp+0x98]
    26b8:	mov    r13,QWORD PTR [rsp+0xa0]
    26c0:	mov    r14,QWORD PTR [rsp+0xa8]
    26c8:	mov    r15,QWORD PTR [rsp+0xb0]
    26d0:	add    rsp,0xc0
    26d7:	mov    rsp,rbp
    26da:	pop    rbp
    26db:	ret
    26dc:	add    BYTE PTR [rax],al
    26de:	add    BYTE PTR [rax],al
    26e0:	(bad)
    26e1:	add    BYTE PTR [rax],al
    26e3:	add    BYTE PTR [rax],al
    26e5:	add    BYTE PTR [rax],al
	...

00000000000026e8 <botlish_entry_9: <str>>:
    26e8:	push   rbp
    26e9:	mov    rbp,rsp
    26ec:	mov    rsi,QWORD PTR [rdx]
    26ef:	call   26f4 <botlish_entry_9+0xc>
			26f0: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    26f4:	mov    rsp,rbp
    26f7:	pop    rbp
    26f8:	ret
    26f9:	add    BYTE PTR [rax],al
    26fb:	add    BYTE PTR [rax],al
    26fd:	add    BYTE PTR [rax],al
	...

0000000000002700 <botlish_fn_10: <generic>>:
    2700:	push   rbp
    2701:	mov    rbp,rsp
    2704:	sub    rsp,0xc0
    270b:	mov    QWORD PTR [rsp+0x90],rbx
    2713:	mov    QWORD PTR [rsp+0x98],r12
    271b:	mov    QWORD PTR [rsp+0xa0],r13
    2723:	mov    QWORD PTR [rsp+0xa8],r14
    272b:	mov    QWORD PTR [rsp+0xb0],r15
    2733:	mov    r12,QWORD PTR [rdi]
    2736:	mov    rax,QWORD PTR [rdi+0x8]
    273a:	lea    rcx,[r12+0x28]
    273f:	cmp    rcx,rax
    2742:	ja     2ba2 <botlish_fn_10+0x4a2>
    2748:	lea    rax,[r12+0x28]
    274d:	mov    QWORD PTR [rdi],rax
    2750:	mov    QWORD PTR [r12],0x0
    2758:	mov    QWORD PTR [r12+0x8],0x0
    2761:	mov    QWORD PTR [r12+0x10],0x0
    276a:	mov    QWORD PTR [r12+0x18],0x0
    2773:	mov    QWORD PTR [r12+0x20],0x0
    277c:	mov    QWORD PTR [r12],rsi
    2780:	xor    eax,eax
    2782:	test   rsi,0x7
    2789:	jne    2798 <botlish_fn_10+0x98>
    278f:	movzx  rax,BYTE PTR [rsi]
    2793:	cmp    al,0x2
    2795:	sete   al
    2798:	test   al,al
    279a:	jne    27c4 <botlish_fn_10+0xc4>
    27a0:	mov    rax,QWORD PTR [rdi+0x10]
    27a4:	mov    QWORD PTR [rsp+0x78],rdi
    27a9:	mov    rcx,QWORD PTR [rax+0xd8]
    27b0:	mov    edx,0x1
    27b5:	call   27ba <botlish_fn_10+0xba>
			27b6: R_X86_64_PLT32	rt_type_error-0x4
    27ba:	mov    rdi,QWORD PTR [rsp+0x78]
    27bf:	jmp    2ab8 <botlish_fn_10+0x3b8>
    27c4:	mov    r13,rsi
    27c7:	mov    QWORD PTR [rsp+0x78],rdi
    27cc:	call   27d1 <botlish_fn_10+0xd1>
			27cd: R_X86_64_PLT32	rt_str_len-0x4
    27d1:	mov    rbx,rax
    27d4:	mov    QWORD PTR [r12+0x8],rbx
    27d9:	lea    r8,[rsp]
    27dd:	mov    QWORD PTR [rsp],r13
    27e1:	mov    esi,0xb
    27e6:	mov    rdx,QWORD PTR [rip+0x0]        # 27ed <botlish_fn_10+0xed>
			27e9: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    27ed:	mov    r13d,0x1
    27f3:	mov    rcx,r13
    27f6:	mov    rdi,QWORD PTR [rsp+0x78]
    27fb:	call   2800 <botlish_fn_10+0x100>
			27fc: R_X86_64_PLT32	rt_closure_new-0x4
    2800:	mov    r15,rax
    2803:	mov    QWORD PTR [rsp+0x88],r13
    280b:	mov    QWORD PTR [r12],rax
    280f:	lea    r8,[rsp+0x8]
    2814:	mov    QWORD PTR [rsp+0x8],rbx
    2819:	mov    QWORD PTR [rsp+0x10],rax
    281e:	mov    esi,0xf
    2823:	mov    rdx,QWORD PTR [rip+0x0]        # 282a <botlish_fn_10+0x12a>
			2826: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_local<generic>
    282a:	mov    r14d,0x2
    2830:	mov    rcx,r14
    2833:	mov    rdi,QWORD PTR [rsp+0x78]
    2838:	call   283d <botlish_fn_10+0x13d>
			2839: R_X86_64_PLT32	rt_closure_new-0x4
    283d:	mov    r13,rax
    2840:	mov    QWORD PTR [r12+0x10],r13
    2845:	lea    r8,[rsp+0x18]
    284a:	mov    QWORD PTR [rsp+0x18],rbx
    284f:	mov    rax,r15
    2852:	mov    QWORD PTR [rsp+0x20],rax
    2857:	mov    esi,0x10
    285c:	mov    rdx,QWORD PTR [rip+0x0]        # 2863 <botlish_fn_10+0x163>
			285f: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; scan_label<generic>
    2863:	mov    rcx,r14
    2866:	mov    rdi,QWORD PTR [rsp+0x78]
    286b:	call   2870 <botlish_fn_10+0x170>
			286c: R_X86_64_PLT32	rt_closure_new-0x4
    2870:	mov    QWORD PTR [r12+0x18],rax
    2875:	mov    QWORD PTR [rsp+0x80],rax
    287d:	lea    r8,[rsp+0x28]
    2882:	mov    QWORD PTR [rsp+0x28],rbx
    2887:	mov    QWORD PTR [rsp+0x30],r15
    288c:	mov    esi,0x11
    2891:	mov    rdx,QWORD PTR [rip+0x0]        # 2898 <botlish_fn_10+0x198>
			2894: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; scan_alpha<generic>
    2898:	mov    rcx,r14
    289b:	mov    rdi,QWORD PTR [rsp+0x78]
    28a0:	call   28a5 <botlish_fn_10+0x1a5>
			28a1: R_X86_64_PLT32	rt_closure_new-0x4
    28a5:	mov    QWORD PTR [r12+0x20],rax
    28aa:	lea    r8,[rsp+0x38]
    28af:	mov    QWORD PTR [rsp+0x38],rax
    28b4:	mov    QWORD PTR [rsp+0x40],rbx
    28b9:	mov    esi,0x12
    28be:	mov    rdx,QWORD PTR [rip+0x0]        # 28c5 <botlish_fn_10+0x1c5>
			28c1: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; tld_ok<generic>
    28c5:	mov    rcx,r14
    28c8:	mov    rdi,QWORD PTR [rsp+0x78]
    28cd:	call   28d2 <botlish_fn_10+0x1d2>
			28ce: R_X86_64_PLT32	rt_closure_new-0x4
    28d2:	mov    QWORD PTR [r12+0x20],rax
    28d7:	lea    r8,[rsp+0x48]
    28dc:	mov    rcx,QWORD PTR [rsp+0x80]
    28e4:	mov    QWORD PTR [rsp+0x48],rcx
    28e9:	mov    QWORD PTR [rsp+0x50],rbx
    28ee:	mov    QWORD PTR [rsp+0x58],r15
    28f3:	mov    QWORD PTR [rsp+0x60],rax
    28f8:	mov    esi,0x13
    28fd:	mov    rdx,QWORD PTR [rip+0x0]        # 2904 <botlish_fn_10+0x204>
			2900: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; domain_loop<generic>
    2904:	mov    ecx,0x4
    2909:	mov    rdi,QWORD PTR [rsp+0x78]
    290e:	call   2913 <botlish_fn_10+0x213>
			290f: R_X86_64_PLT32	rt_closure_new-0x4
    2913:	mov    QWORD PTR [r12+0x18],rax
    2918:	mov    r14,rax
    291b:	mov    QWORD PTR [r12+0x20],0x1
    2924:	mov    rsi,r13
    2927:	mov    rdx,QWORD PTR [rsp+0x88]
    292f:	mov    rdi,QWORD PTR [rsp+0x78]
    2934:	call   2939 <botlish_fn_10+0x239>
			2935: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    2939:	mov    rcx,rax
    293c:	mov    r13,rax
    293f:	test   rax,rcx
    2942:	jne    2952 <botlish_fn_10+0x252>
    2948:	mov    rdi,QWORD PTR [rsp+0x78]
    294d:	jmp    2ab8 <botlish_fn_10+0x3b8>
    2952:	mov    rax,r13
    2955:	mov    QWORD PTR [r12+0x10],rax
    295a:	test   rax,0x1
    2960:	jne    2990 <botlish_fn_10+0x290>
    2966:	mov    rdx,QWORD PTR [rsp+0x88]
    296e:	mov    rsi,r13
    2971:	mov    rdi,QWORD PTR [rsp+0x78]
    2976:	call   297b <botlish_fn_10+0x27b>
			2977: R_X86_64_PLT32	rt_int_cmp-0x4
    297b:	mov    ecx,0x2
    2980:	test   rax,rax
    2983:	cmove  rcx,QWORD PTR [rip+0x25d]        # 2be8 <botlish_fn_10+0x4e8>
    298b:	jmp    29a1 <botlish_fn_10+0x2a1>
    2990:	mov    ecx,0x2
    2995:	cmp    r13,0x1
    2999:	cmove  rcx,QWORD PTR [rip+0x247]        # 2be8 <botlish_fn_10+0x4e8>
    29a1:	cmp    rcx,0x6
    29a5:	je     2b5c <botlish_fn_10+0x45c>
    29ab:	mov    rax,r13
    29ae:	and    rax,rbx
    29b1:	test   rax,0x1
    29b7:	jne    29e2 <botlish_fn_10+0x2e2>
    29bd:	mov    rdx,rbx
    29c0:	mov    rsi,r13
    29c3:	mov    rdi,QWORD PTR [rsp+0x78]
    29c8:	call   29cd <botlish_fn_10+0x2cd>
			29c9: R_X86_64_PLT32	rt_int_cmp-0x4
    29cd:	mov    ecx,0x2
    29d2:	test   rax,rax
    29d5:	cmovge rcx,QWORD PTR [rip+0x20b]        # 2be8 <botlish_fn_10+0x4e8>
    29dd:	jmp    29f2 <botlish_fn_10+0x2f2>
    29e2:	mov    ecx,0x2
    29e7:	cmp    r13,rbx
    29ea:	cmovge rcx,QWORD PTR [rip+0x1f6]        # 2be8 <botlish_fn_10+0x4e8>
    29f2:	cmp    rcx,0x6
    29f6:	je     2b4d <botlish_fn_10+0x44d>
    29fc:	lea    rcx,[rsp+0x68]
    2a01:	mov    rsi,r15
    2a04:	mov    rdx,r13
    2a07:	mov    rdi,QWORD PTR [rsp+0x78]
    2a0c:	call   2a11 <botlish_fn_10+0x311>
			2a0d: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    2a11:	test   rax,rax
    2a14:	mov    rsi,rax
    2a17:	jne    2a27 <botlish_fn_10+0x327>
    2a1d:	mov    rdi,QWORD PTR [rsp+0x78]
    2a22:	jmp    2ab8 <botlish_fn_10+0x3b8>
    2a27:	mov    rdx,QWORD PTR [rsp+0x68]
    2a2c:	mov    rcx,QWORD PTR [rsp+0x70]
    2a31:	mov    rdi,QWORD PTR [rsp+0x78]
    2a36:	mov    rax,QWORD PTR [rdi+0x10]
    2a3a:	mov    r8,QWORD PTR [rax+0x100]
    2a41:	call   2a46 <botlish_fn_10+0x346>
			2a42: R_X86_64_PLT32	rt_str_region_eq-0x4
    2a46:	cmp    rax,0x6
    2a4a:	je     2a5d <botlish_fn_10+0x35d>
    2a50:	mov    edi,0x2
    2a55:	mov    rax,rdi
    2a58:	jmp    2b52 <botlish_fn_10+0x452>
    2a5d:	mov    QWORD PTR [r12],0x3
    2a65:	test   r13,0x1
    2a6c:	je     2a84 <botlish_fn_10+0x384>
    2a72:	mov    rdx,r13
    2a75:	add    rdx,0x2
    2a79:	seto   al
    2a7c:	test   al,al
    2a7e:	je     2a99 <botlish_fn_10+0x399>
    2a84:	mov    edx,0x3
    2a89:	mov    rsi,r13
    2a8c:	mov    rdi,QWORD PTR [rsp+0x78]
    2a91:	call   2a96 <botlish_fn_10+0x396>
			2a92: R_X86_64_PLT32	rt_int_add-0x4
    2a96:	mov    rdx,rax
    2a99:	mov    QWORD PTR [r12],rdx
    2a9d:	mov    rsi,r14
    2aa0:	mov    rdi,QWORD PTR [rsp+0x78]
    2aa5:	call   2aaa <botlish_fn_10+0x3aa>
			2aa6: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    2aaa:	test   rax,rax
    2aad:	jne    2af7 <botlish_fn_10+0x3f7>
    2ab3:	mov    rdi,QWORD PTR [rsp+0x78]
    2ab8:	mov    rdi,QWORD PTR [rsp+0x78]
    2abd:	mov    QWORD PTR [rdi],r12
    2ac0:	xor    rax,rax
    2ac3:	mov    rbx,QWORD PTR [rsp+0x90]
    2acb:	mov    r12,QWORD PTR [rsp+0x98]
    2ad3:	mov    r13,QWORD PTR [rsp+0xa0]
    2adb:	mov    r14,QWORD PTR [rsp+0xa8]
    2ae3:	mov    r15,QWORD PTR [rsp+0xb0]
    2aeb:	add    rsp,0xc0
    2af2:	mov    rsp,rbp
    2af5:	pop    rbp
    2af6:	ret
    2af7:	mov    rcx,rax
    2afa:	and    rcx,rbx
    2afd:	mov    rsi,rax
    2b00:	mov    rax,rbx
    2b03:	test   rcx,0x1
    2b0a:	jne    2b35 <botlish_fn_10+0x435>
    2b10:	mov    rdx,rax
    2b13:	mov    rdi,QWORD PTR [rsp+0x78]
    2b18:	call   2b1d <botlish_fn_10+0x41d>
			2b19: R_X86_64_PLT32	rt_int_cmp-0x4
    2b1d:	mov    edi,0x2
    2b22:	test   rax,rax
    2b25:	mov    rax,rdi
    2b28:	cmove  rax,QWORD PTR [rip+0xb8]        # 2be8 <botlish_fn_10+0x4e8>
    2b30:	jmp    2b52 <botlish_fn_10+0x452>
    2b35:	mov    rdx,rax
    2b38:	mov    eax,0x2
    2b3d:	cmp    rsi,rdx
    2b40:	cmove  rax,QWORD PTR [rip+0xa0]        # 2be8 <botlish_fn_10+0x4e8>
    2b48:	jmp    2b52 <botlish_fn_10+0x452>
    2b4d:	mov    eax,0x2
    2b52:	mov    rdi,QWORD PTR [rsp+0x78]
    2b57:	jmp    2b66 <botlish_fn_10+0x466>
    2b5c:	mov    eax,0x2
    2b61:	mov    rdi,QWORD PTR [rsp+0x78]
    2b66:	mov    rdi,QWORD PTR [rsp+0x78]
    2b6b:	mov    QWORD PTR [rdi],r12
    2b6e:	mov    rbx,QWORD PTR [rsp+0x90]
    2b76:	mov    r12,QWORD PTR [rsp+0x98]
    2b7e:	mov    r13,QWORD PTR [rsp+0xa0]
    2b86:	mov    r14,QWORD PTR [rsp+0xa8]
    2b8e:	mov    r15,QWORD PTR [rsp+0xb0]
    2b96:	add    rsp,0xc0
    2b9d:	mov    rsp,rbp
    2ba0:	pop    rbp
    2ba1:	ret
    2ba2:	mov    QWORD PTR [rsp+0x78],rdi
    2ba7:	call   2bac <botlish_fn_10+0x4ac>
			2ba8: R_X86_64_PLT32	rt_stack_overflow-0x4
    2bac:	xor    rax,rax
    2baf:	mov    rbx,QWORD PTR [rsp+0x90]
    2bb7:	mov    r12,QWORD PTR [rsp+0x98]
    2bbf:	mov    r13,QWORD PTR [rsp+0xa0]
    2bc7:	mov    r14,QWORD PTR [rsp+0xa8]
    2bcf:	mov    r15,QWORD PTR [rsp+0xb0]
    2bd7:	add    rsp,0xc0
    2bde:	mov    rsp,rbp
    2be1:	pop    rbp
    2be2:	ret
    2be3:	add    BYTE PTR [rax],al
    2be5:	add    BYTE PTR [rax],al
    2be7:	add    BYTE PTR [rsi],al
    2be9:	add    BYTE PTR [rax],al
    2beb:	add    BYTE PTR [rax],al
    2bed:	add    BYTE PTR [rax],al
	...

0000000000002bf0 <botlish_entry_10: <generic>>:
    2bf0:	push   rbp
    2bf1:	mov    rbp,rsp
    2bf4:	mov    rsi,QWORD PTR [rdx]
    2bf7:	call   2bfc <botlish_entry_10+0xc>
			2bf8: R_X86_64_PLT32	botlish_fn_10-0x4 ; <generic>
    2bfc:	mov    rsp,rbp
    2bff:	pop    rbp
    2c00:	ret

0000000000002c01 <botlish_fn_11: char_at<generic>>:
    2c01:	push   rbp
    2c02:	mov    rbp,rsp
    2c05:	sub    rsp,0x20
    2c09:	mov    QWORD PTR [rsp],rbx
    2c0d:	mov    QWORD PTR [rsp+0x8],r12
    2c12:	mov    QWORD PTR [rsp+0x10],r13
    2c17:	mov    QWORD PTR [rsp+0x18],r14
    2c1c:	mov    rbx,QWORD PTR [rdi]
    2c1f:	mov    rax,QWORD PTR [rdi+0x8]
    2c23:	lea    rcx,[rbx+0x18]
    2c27:	cmp    rcx,rax
    2c2a:	ja     2dcb <botlish_fn_11+0x1ca>
    2c30:	lea    rax,[rbx+0x18]
    2c34:	mov    QWORD PTR [rdi],rax
    2c37:	mov    QWORD PTR [rbx],0x0
    2c3e:	mov    QWORD PTR [rbx+0x8],0x0
    2c46:	mov    QWORD PTR [rbx+0x10],0x0
    2c4e:	mov    QWORD PTR [rbx],rdx
    2c51:	mov    rax,QWORD PTR [rsi+0x20]
    2c55:	mov    rsi,QWORD PTR [rax]
    2c58:	mov    QWORD PTR [rbx+0x8],rsi
    2c5c:	mov    r14,rsi
    2c5f:	mov    QWORD PTR [rbx+0x10],0x3
    2c67:	mov    ecx,0x1
    2c6c:	test   rdx,0x1
    2c73:	je     2c81 <botlish_fn_11+0x80>
    2c79:	mov    r13,rdx
    2c7c:	jmp    2ca4 <botlish_fn_11+0xa3>
    2c81:	xor    ecx,ecx
    2c83:	test   rdx,0x7
    2c8a:	je     2c98 <botlish_fn_11+0x97>
    2c90:	mov    r13,rdx
    2c93:	jmp    2ca4 <botlish_fn_11+0xa3>
    2c98:	movzx  rax,BYTE PTR [rdx]
    2c9c:	mov    r13,rdx
    2c9f:	cmp    al,0x1
    2ca1:	sete   cl
    2ca4:	test   cl,cl
    2ca6:	jne    2ccd <botlish_fn_11+0xcc>
    2cac:	mov    rax,QWORD PTR [rdi+0x10]
    2cb0:	mov    r12,rdi
    2cb3:	mov    rcx,QWORD PTR [rax+0x108]
    2cba:	xor    rdx,rdx
    2cbd:	mov    rsi,r13
    2cc0:	call   2cc5 <botlish_fn_11+0xc4>
			2cc1: R_X86_64_PLT32	rt_type_error-0x4
    2cc5:	mov    rdi,r12
    2cc8:	jmp    2d84 <botlish_fn_11+0x183>
    2ccd:	mov    rsi,r13
    2cd0:	mov    r12,rdi
    2cd3:	test   rsi,0x1
    2cda:	je     2cf7 <botlish_fn_11+0xf6>
    2ce0:	mov    rsi,r13
    2ce3:	mov    rcx,rsi
    2ce6:	add    rcx,0x2
    2cea:	seto   sil
    2cee:	test   sil,sil
    2cf1:	je     2d0a <botlish_fn_11+0x109>
    2cf7:	mov    edx,0x3
    2cfc:	mov    rsi,r13
    2cff:	mov    rdi,r12
    2d02:	call   2d07 <botlish_fn_11+0x106>
			2d03: R_X86_64_PLT32	rt_int_add-0x4
    2d07:	mov    rcx,rax
    2d0a:	mov    QWORD PTR [rbx+0x10],rcx
    2d0e:	mov    edx,0x1
    2d13:	mov    rsi,r13
    2d16:	test   rsi,0x1
    2d1d:	jne    2d41 <botlish_fn_11+0x140>
    2d23:	xor    edx,edx
    2d25:	mov    rsi,r13
    2d28:	test   rsi,0x7
    2d2f:	jne    2d41 <botlish_fn_11+0x140>
    2d35:	mov    rsi,r13
    2d38:	movzx  rax,BYTE PTR [rsi]
    2d3c:	cmp    al,0x1
    2d3e:	sete   dl
    2d41:	test   dl,dl
    2d43:	jne    2d6a <botlish_fn_11+0x169>
    2d49:	mov    rdi,r12
    2d4c:	mov    rax,QWORD PTR [rdi+0x10]
    2d50:	mov    rcx,QWORD PTR [rax+0x110]
    2d57:	xor    rdx,rdx
    2d5a:	mov    rsi,r13
    2d5d:	call   2d62 <botlish_fn_11+0x161>
			2d5e: R_X86_64_PLT32	rt_type_error-0x4
    2d62:	mov    rdi,r12
    2d65:	jmp    2d84 <botlish_fn_11+0x183>
    2d6a:	mov    rdx,r13
    2d6d:	mov    rsi,r14
    2d70:	mov    rdi,r12
    2d73:	call   2d78 <botlish_fn_11+0x177>
			2d74: R_X86_64_PLT32	rt_substr-0x4
    2d78:	test   rax,rax
    2d7b:	jne    2da9 <botlish_fn_11+0x1a8>
    2d81:	mov    rdi,r12
    2d84:	mov    rdi,r12
    2d87:	mov    QWORD PTR [rdi],rbx
    2d8a:	xor    rax,rax
    2d8d:	mov    rbx,QWORD PTR [rsp]
    2d91:	mov    r12,QWORD PTR [rsp+0x8]
    2d96:	mov    r13,QWORD PTR [rsp+0x10]
    2d9b:	mov    r14,QWORD PTR [rsp+0x18]
    2da0:	add    rsp,0x20
    2da4:	mov    rsp,rbp
    2da7:	pop    rbp
    2da8:	ret
    2da9:	mov    rdi,r12
    2dac:	mov    QWORD PTR [rdi],rbx
    2daf:	mov    rbx,QWORD PTR [rsp]
    2db3:	mov    r12,QWORD PTR [rsp+0x8]
    2db8:	mov    r13,QWORD PTR [rsp+0x10]
    2dbd:	mov    r14,QWORD PTR [rsp+0x18]
    2dc2:	add    rsp,0x20
    2dc6:	mov    rsp,rbp
    2dc9:	pop    rbp
    2dca:	ret
    2dcb:	mov    r12,rdi
    2dce:	call   2dd3 <botlish_fn_11+0x1d2>
			2dcf: R_X86_64_PLT32	rt_stack_overflow-0x4
    2dd3:	xor    rax,rax
    2dd6:	mov    rbx,QWORD PTR [rsp]
    2dda:	mov    r12,QWORD PTR [rsp+0x8]
    2ddf:	mov    r13,QWORD PTR [rsp+0x10]
    2de4:	mov    r14,QWORD PTR [rsp+0x18]
    2de9:	add    rsp,0x20
    2ded:	mov    rsp,rbp
    2df0:	pop    rbp
    2df1:	ret

0000000000002df2 <botlish_entry_11: char_at<generic>>:
    2df2:	push   rbp
    2df3:	mov    rbp,rsp
    2df6:	mov    rdx,QWORD PTR [rdx]
    2df9:	call   2dfe <botlish_entry_11+0xc>
			2dfa: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2dfe:	mov    rsp,rbp
    2e01:	pop    rbp
    2e02:	ret

0000000000002e03 <botlish_fn_12: char_at<generic>>:
    2e03:	push   rbp
    2e04:	mov    rbp,rsp
    2e07:	sub    rsp,0x40
    2e0b:	mov    QWORD PTR [rsp+0x10],rbx
    2e10:	mov    QWORD PTR [rsp+0x18],r12
    2e15:	mov    QWORD PTR [rsp+0x20],r13
    2e1a:	mov    QWORD PTR [rsp+0x28],r14
    2e1f:	mov    QWORD PTR [rsp+0x30],r15
    2e24:	mov    r15,rcx
    2e27:	mov    rbx,QWORD PTR [rdi]
    2e2a:	mov    rax,QWORD PTR [rdi+0x8]
    2e2e:	lea    rcx,[rbx+0x18]
    2e32:	cmp    rcx,rax
    2e35:	ja     3004 <botlish_fn_12+0x201>
    2e3b:	lea    rax,[rbx+0x18]
    2e3f:	mov    QWORD PTR [rdi],rax
    2e42:	mov    QWORD PTR [rbx],0x0
    2e49:	mov    QWORD PTR [rbx+0x8],0x0
    2e51:	mov    QWORD PTR [rbx+0x10],0x0
    2e59:	mov    QWORD PTR [rbx],rdx
    2e5c:	mov    rax,QWORD PTR [rsi+0x20]
    2e60:	mov    rax,QWORD PTR [rax]
    2e63:	mov    QWORD PTR [rbx+0x8],rax
    2e67:	mov    QWORD PTR [rsp],rax
    2e6b:	mov    QWORD PTR [rbx+0x10],0x3
    2e73:	mov    eax,0x1
    2e78:	test   rdx,0x1
    2e7f:	je     2e8d <botlish_fn_12+0x8a>
    2e85:	mov    r14,rdx
    2e88:	jmp    2eb0 <botlish_fn_12+0xad>
    2e8d:	xor    eax,eax
    2e8f:	test   rdx,0x7
    2e96:	je     2ea4 <botlish_fn_12+0xa1>
    2e9c:	mov    r14,rdx
    2e9f:	jmp    2eb0 <botlish_fn_12+0xad>
    2ea4:	movzx  rax,BYTE PTR [rdx]
    2ea8:	mov    r14,rdx
    2eab:	cmp    al,0x1
    2ead:	sete   al
    2eb0:	test   al,al
    2eb2:	jne    2ed9 <botlish_fn_12+0xd6>
    2eb8:	mov    rax,QWORD PTR [rdi+0x10]
    2ebc:	mov    r13,rdi
    2ebf:	mov    rcx,QWORD PTR [rax+0x108]
    2ec6:	xor    rdx,rdx
    2ec9:	mov    rsi,r14
    2ecc:	call   2ed1 <botlish_fn_12+0xce>
			2ecd: R_X86_64_PLT32	rt_type_error-0x4
    2ed1:	mov    rdi,r13
    2ed4:	jmp    2fa0 <botlish_fn_12+0x19d>
    2ed9:	mov    rsi,r14
    2edc:	mov    r13,rdi
    2edf:	test   rsi,0x1
    2ee6:	jne    2ef4 <botlish_fn_12+0xf1>
    2eec:	mov    r14,rsi
    2eef:	jmp    2f13 <botlish_fn_12+0x110>
    2ef4:	mov    rax,rsi
    2ef7:	add    rax,0x2
    2efb:	mov    r14,rsi
    2efe:	seto   sil
    2f02:	test   sil,sil
    2f05:	jne    2f13 <botlish_fn_12+0x110>
    2f0b:	mov    r12,rax
    2f0e:	jmp    2f26 <botlish_fn_12+0x123>
    2f13:	mov    edx,0x3
    2f18:	mov    rsi,r14
    2f1b:	mov    rdi,r13
    2f1e:	call   2f23 <botlish_fn_12+0x120>
			2f1f: R_X86_64_PLT32	rt_int_add-0x4
    2f23:	mov    r12,rax
    2f26:	mov    ecx,0x1
    2f2b:	mov    rsi,r14
    2f2e:	test   rsi,0x1
    2f35:	jne    2f59 <botlish_fn_12+0x156>
    2f3b:	xor    ecx,ecx
    2f3d:	mov    rsi,r14
    2f40:	test   rsi,0x7
    2f47:	jne    2f59 <botlish_fn_12+0x156>
    2f4d:	mov    rsi,r14
    2f50:	movzx  rax,BYTE PTR [rsi]
    2f54:	cmp    al,0x1
    2f56:	sete   cl
    2f59:	test   cl,cl
    2f5b:	jne    2f82 <botlish_fn_12+0x17f>
    2f61:	mov    rdi,r13
    2f64:	mov    rax,QWORD PTR [rdi+0x10]
    2f68:	mov    rcx,QWORD PTR [rax+0x110]
    2f6f:	xor    rdx,rdx
    2f72:	mov    rsi,r14
    2f75:	call   2f7a <botlish_fn_12+0x177>
			2f76: R_X86_64_PLT32	rt_type_error-0x4
    2f7a:	mov    rdi,r13
    2f7d:	jmp    2fa0 <botlish_fn_12+0x19d>
    2f82:	mov    rcx,r12
    2f85:	mov    rdx,r14
    2f88:	mov    rsi,QWORD PTR [rsp]
    2f8c:	mov    rdi,r13
    2f8f:	call   2f94 <botlish_fn_12+0x191>
			2f90: R_X86_64_PLT32	rt_str_region_check-0x4
    2f94:	test   rax,rax
    2f97:	jne    2fcb <botlish_fn_12+0x1c8>
    2f9d:	mov    rdi,r13
    2fa0:	mov    rdi,r13
    2fa3:	mov    QWORD PTR [rdi],rbx
    2fa6:	xor    rax,rax
    2fa9:	mov    rbx,QWORD PTR [rsp+0x10]
    2fae:	mov    r12,QWORD PTR [rsp+0x18]
    2fb3:	mov    r13,QWORD PTR [rsp+0x20]
    2fb8:	mov    r14,QWORD PTR [rsp+0x28]
    2fbd:	mov    r15,QWORD PTR [rsp+0x30]
    2fc2:	add    rsp,0x40
    2fc6:	mov    rsp,rbp
    2fc9:	pop    rbp
    2fca:	ret
    2fcb:	mov    rdi,r13
    2fce:	mov    QWORD PTR [rdi],rbx
    2fd1:	mov    rcx,r15
    2fd4:	mov    rsi,r14
    2fd7:	mov    QWORD PTR [rcx],rsi
    2fda:	mov    QWORD PTR [rcx+0x8],r12
    2fde:	mov    rax,QWORD PTR [rsp]
    2fe2:	mov    rbx,QWORD PTR [rsp+0x10]
    2fe7:	mov    r12,QWORD PTR [rsp+0x18]
    2fec:	mov    r13,QWORD PTR [rsp+0x20]
    2ff1:	mov    r14,QWORD PTR [rsp+0x28]
    2ff6:	mov    r15,QWORD PTR [rsp+0x30]
    2ffb:	add    rsp,0x40
    2fff:	mov    rsp,rbp
    3002:	pop    rbp
    3003:	ret
    3004:	mov    r13,rdi
    3007:	call   300c <botlish_fn_12+0x209>
			3008: R_X86_64_PLT32	rt_stack_overflow-0x4
    300c:	xor    rax,rax
    300f:	mov    rbx,QWORD PTR [rsp+0x10]
    3014:	mov    r12,QWORD PTR [rsp+0x18]
    3019:	mov    r13,QWORD PTR [rsp+0x20]
    301e:	mov    r14,QWORD PTR [rsp+0x28]
    3023:	mov    r15,QWORD PTR [rsp+0x30]
    3028:	add    rsp,0x40
    302c:	mov    rsp,rbp
    302f:	pop    rbp
    3030:	ret

0000000000003031 <botlish_entry_12: char_at<generic>>:
    3031:	push   rbp
    3032:	mov    rbp,rsp
    3035:	ud2

0000000000003037 <botlish_fn_13: is_local_char<str>>:
    3037:	push   rbp
    3038:	mov    rbp,rsp
    303b:	sub    rsp,0x20
    303f:	mov    QWORD PTR [rsp],rbx
    3043:	mov    QWORD PTR [rsp+0x8],r12
    3048:	mov    QWORD PTR [rsp+0x10],r13
    304d:	mov    r13,rsi
    3050:	mov    rbx,QWORD PTR [rdi]
    3053:	mov    rax,QWORD PTR [rdi+0x8]
    3057:	lea    rcx,[rbx+0x8]
    305b:	cmp    rcx,rax
    305e:	ja     31d0 <botlish_fn_13+0x199>
    3064:	lea    rax,[rbx+0x8]
    3068:	mov    QWORD PTR [rdi],rax
    306b:	mov    r12,rdi
    306e:	mov    QWORD PTR [rbx],0x0
    3075:	mov    rsi,r13
    3078:	mov    rdi,r12
    307b:	call   3080 <botlish_fn_13+0x49>
			307c: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    3080:	test   rax,rax
    3083:	jne    30a9 <botlish_fn_13+0x72>
    3089:	mov    rdi,r12
    308c:	mov    QWORD PTR [rdi],rbx
    308f:	xor    rax,rax
    3092:	mov    rbx,QWORD PTR [rsp]
    3096:	mov    r12,QWORD PTR [rsp+0x8]
    309b:	mov    r13,QWORD PTR [rsp+0x10]
    30a0:	add    rsp,0x20
    30a4:	mov    rsp,rbp
    30a7:	pop    rbp
    30a8:	ret
    30a9:	cmp    rax,0x6
    30ad:	je     31ab <botlish_fn_13+0x174>
    30b3:	mov    rdi,r12
    30b6:	mov    rax,QWORD PTR [rdi+0x10]
    30ba:	mov    rsi,QWORD PTR [rax+0x118]
    30c1:	mov    edx,0x1
    30c6:	mov    ecx,0x3
    30cb:	mov    r8,r13
    30ce:	call   30d3 <botlish_fn_13+0x9c>
			30cf: R_X86_64_PLT32	rt_str_region_eq-0x4
    30d3:	cmp    rax,0x6
    30d7:	je     319e <botlish_fn_13+0x167>
    30dd:	mov    rdi,r12
    30e0:	mov    rax,QWORD PTR [rdi+0x10]
    30e4:	mov    rsi,QWORD PTR [rax+0x120]
    30eb:	mov    edx,0x1
    30f0:	mov    ecx,0x3
    30f5:	mov    r8,r13
    30f8:	call   30fd <botlish_fn_13+0xc6>
			30f9: R_X86_64_PLT32	rt_str_region_eq-0x4
    30fd:	cmp    rax,0x6
    3101:	je     3194 <botlish_fn_13+0x15d>
    3107:	mov    rdi,r12
    310a:	mov    rax,QWORD PTR [rdi+0x10]
    310e:	mov    rsi,QWORD PTR [rax+0xc0]
    3115:	mov    edx,0x1
    311a:	mov    ecx,0x3
    311f:	mov    r8,r13
    3122:	call   3127 <botlish_fn_13+0xf0>
			3123: R_X86_64_PLT32	rt_str_region_eq-0x4
    3127:	cmp    rax,0x6
    312b:	je     318a <botlish_fn_13+0x153>
    3131:	mov    rdi,r12
    3134:	mov    rcx,QWORD PTR [rdi+0x10]
    3138:	mov    rsi,QWORD PTR [rcx+0x108]
    313f:	mov    edx,0x1
    3144:	mov    ecx,0x3
    3149:	mov    r8,r13
    314c:	call   3151 <botlish_fn_13+0x11a>
			314d: R_X86_64_PLT32	rt_str_region_eq-0x4
    3151:	cmp    rax,0x6
    3155:	je     3180 <botlish_fn_13+0x149>
    315b:	mov    rdi,r12
    315e:	mov    rsi,QWORD PTR [rdi+0x10]
    3162:	mov    rsi,QWORD PTR [rsi+0x128]
    3169:	mov    edx,0x1
    316e:	mov    ecx,0x3
    3173:	mov    r8,r13
    3176:	call   317b <botlish_fn_13+0x144>
			3177: R_X86_64_PLT32	rt_str_region_eq-0x4
    317b:	jmp    31a3 <botlish_fn_13+0x16c>
    3180:	mov    eax,0x6
    3185:	jmp    31a3 <botlish_fn_13+0x16c>
    318a:	mov    eax,0x6
    318f:	jmp    31a3 <botlish_fn_13+0x16c>
    3194:	mov    eax,0x6
    3199:	jmp    31a3 <botlish_fn_13+0x16c>
    319e:	mov    eax,0x6
    31a3:	mov    rdi,r12
    31a6:	jmp    31b3 <botlish_fn_13+0x17c>
    31ab:	mov    eax,0x6
    31b0:	mov    rdi,r12
    31b3:	mov    rdi,r12
    31b6:	mov    QWORD PTR [rdi],rbx
    31b9:	mov    rbx,QWORD PTR [rsp]
    31bd:	mov    r12,QWORD PTR [rsp+0x8]
    31c2:	mov    r13,QWORD PTR [rsp+0x10]
    31c7:	add    rsp,0x20
    31cb:	mov    rsp,rbp
    31ce:	pop    rbp
    31cf:	ret
    31d0:	mov    r12,rdi
    31d3:	call   31d8 <botlish_fn_13+0x1a1>
			31d4: R_X86_64_PLT32	rt_stack_overflow-0x4
    31d8:	xor    rax,rax
    31db:	mov    rbx,QWORD PTR [rsp]
    31df:	mov    r12,QWORD PTR [rsp+0x8]
    31e4:	mov    r13,QWORD PTR [rsp+0x10]
    31e9:	add    rsp,0x20
    31ed:	mov    rsp,rbp
    31f0:	pop    rbp
    31f1:	ret

00000000000031f2 <botlish_entry_13: is_local_char<str>>:
    31f2:	push   rbp
    31f3:	mov    rbp,rsp
    31f6:	mov    rsi,QWORD PTR [rdx]
    31f9:	call   31fe <botlish_entry_13+0xc>
			31fa: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_local_char<str>
    31fe:	mov    rsp,rbp
    3201:	pop    rbp
    3202:	ret

0000000000003203 <botlish_fn_14: is_label_char<str>>:
    3203:	push   rbp
    3204:	mov    rbp,rsp
    3207:	sub    rsp,0x20
    320b:	mov    QWORD PTR [rsp],rbx
    320f:	mov    QWORD PTR [rsp+0x8],r12
    3214:	mov    QWORD PTR [rsp+0x10],r13
    3219:	mov    r13,rsi
    321c:	mov    rbx,QWORD PTR [rdi]
    321f:	mov    rax,QWORD PTR [rdi+0x8]
    3223:	lea    rcx,[rbx+0x8]
    3227:	cmp    rcx,rax
    322a:	ja     32cc <botlish_fn_14+0xc9>
    3230:	lea    rax,[rbx+0x8]
    3234:	mov    QWORD PTR [rdi],rax
    3237:	mov    r12,rdi
    323a:	mov    QWORD PTR [rbx],0x0
    3241:	mov    rsi,r13
    3244:	mov    rdi,r12
    3247:	call   324c <botlish_fn_14+0x49>
			3248: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    324c:	test   rax,rax
    324f:	jne    3275 <botlish_fn_14+0x72>
    3255:	mov    rdi,r12
    3258:	mov    QWORD PTR [rdi],rbx
    325b:	xor    rax,rax
    325e:	mov    rbx,QWORD PTR [rsp]
    3262:	mov    r12,QWORD PTR [rsp+0x8]
    3267:	mov    r13,QWORD PTR [rsp+0x10]
    326c:	add    rsp,0x20
    3270:	mov    rsp,rbp
    3273:	pop    rbp
    3274:	ret
    3275:	cmp    rax,0x6
    3279:	je     32a7 <botlish_fn_14+0xa4>
    327f:	mov    rdi,r12
    3282:	mov    rax,QWORD PTR [rdi+0x10]
    3286:	mov    rsi,QWORD PTR [rax+0x128]
    328d:	mov    edx,0x1
    3292:	mov    ecx,0x3
    3297:	mov    r8,r13
    329a:	call   329f <botlish_fn_14+0x9c>
			329b: R_X86_64_PLT32	rt_str_region_eq-0x4
    329f:	mov    rdi,r12
    32a2:	jmp    32af <botlish_fn_14+0xac>
    32a7:	mov    eax,0x6
    32ac:	mov    rdi,r12
    32af:	mov    rdi,r12
    32b2:	mov    QWORD PTR [rdi],rbx
    32b5:	mov    rbx,QWORD PTR [rsp]
    32b9:	mov    r12,QWORD PTR [rsp+0x8]
    32be:	mov    r13,QWORD PTR [rsp+0x10]
    32c3:	add    rsp,0x20
    32c7:	mov    rsp,rbp
    32ca:	pop    rbp
    32cb:	ret
    32cc:	mov    r12,rdi
    32cf:	call   32d4 <botlish_fn_14+0xd1>
			32d0: R_X86_64_PLT32	rt_stack_overflow-0x4
    32d4:	xor    rax,rax
    32d7:	mov    rbx,QWORD PTR [rsp]
    32db:	mov    r12,QWORD PTR [rsp+0x8]
    32e0:	mov    r13,QWORD PTR [rsp+0x10]
    32e5:	add    rsp,0x20
    32e9:	mov    rsp,rbp
    32ec:	pop    rbp
    32ed:	ret

00000000000032ee <botlish_entry_14: is_label_char<str>>:
    32ee:	push   rbp
    32ef:	mov    rbp,rsp
    32f2:	mov    rsi,QWORD PTR [rdx]
    32f5:	call   32fa <botlish_entry_14+0xc>
			32f6: R_X86_64_PLT32	botlish_fn_14-0x4 ; is_label_char<str>
    32fa:	mov    rsp,rbp
    32fd:	pop    rbp
    32fe:	ret
	...

0000000000003300 <botlish_fn_15: scan_local<generic>>:
    3300:	push   rbp
    3301:	mov    rbp,rsp
    3304:	sub    rsp,0x20
    3308:	mov    QWORD PTR [rsp],rbx
    330c:	mov    QWORD PTR [rsp+0x8],r12
    3311:	mov    QWORD PTR [rsp+0x10],r13
    3316:	mov    QWORD PTR [rsp+0x18],r14
    331b:	mov    r12,QWORD PTR [rdi]
    331e:	mov    rax,QWORD PTR [rdi+0x8]
    3322:	lea    rcx,[r12+0x18]
    3327:	cmp    rcx,rax
    332a:	ja     350f <botlish_fn_15+0x20f>
    3330:	lea    rax,[r12+0x18]
    3335:	mov    QWORD PTR [rdi],rax
    3338:	mov    r13,rdi
    333b:	mov    QWORD PTR [r12],0x0
    3343:	mov    QWORD PTR [r12+0x8],0x0
    334c:	mov    QWORD PTR [r12+0x10],0x0
    3355:	mov    QWORD PTR [r12],rdx
    3359:	mov    rbx,rsi
    335c:	mov    rsi,rdx
    335f:	mov    rax,QWORD PTR [rbx+0x20]
    3363:	mov    rdx,QWORD PTR [rax]
    3366:	mov    ecx,0x1
    336b:	test   rsi,0x1
    3372:	jne    3390 <botlish_fn_15+0x90>
    3378:	xor    ecx,ecx
    337a:	test   rsi,0x7
    3381:	jne    3390 <botlish_fn_15+0x90>
    3387:	movzx  rax,BYTE PTR [rsi]
    338b:	cmp    al,0x1
    338d:	sete   cl
    3390:	test   cl,cl
    3392:	jne    33b6 <botlish_fn_15+0xb6>
    3398:	mov    rdi,r13
    339b:	mov    rax,QWORD PTR [rdi+0x10]
    339f:	mov    rcx,QWORD PTR [rax+0xb8]
    33a6:	xor    rdx,rdx
    33a9:	call   33ae <botlish_fn_15+0xae>
			33aa: R_X86_64_PLT32	rt_type_error-0x4
    33ae:	mov    rdi,r13
    33b1:	jmp    344d <botlish_fn_15+0x14d>
    33b6:	mov    rax,rsi
    33b9:	and    rax,rdx
    33bc:	mov    r14,rsi
    33bf:	test   rax,0x1
    33c5:	jne    33eb <botlish_fn_15+0xeb>
    33cb:	mov    rsi,r14
    33ce:	mov    rdi,r13
    33d1:	call   33d6 <botlish_fn_15+0xd6>
			33d2: R_X86_64_PLT32	rt_int_cmp-0x4
    33d6:	mov    ecx,0x2
    33db:	test   rax,rax
    33de:	cmovge rcx,QWORD PTR [rip+0x152]        # 3538 <botlish_fn_15+0x238>
    33e6:	jmp    33fe <botlish_fn_15+0xfe>
    33eb:	mov    ecx,0x2
    33f0:	mov    rsi,r14
    33f3:	cmp    rsi,rdx
    33f6:	cmovge rcx,QWORD PTR [rip+0x13a]        # 3538 <botlish_fn_15+0x238>
    33fe:	cmp    rcx,0x6
    3402:	je     34e7 <botlish_fn_15+0x1e7>
    3408:	mov    rdi,QWORD PTR [rbx+0x20]
    340c:	mov    rsi,QWORD PTR [rdi+0x8]
    3410:	mov    QWORD PTR [r12+0x8],rsi
    3415:	mov    rdx,r14
    3418:	mov    rdi,r13
    341b:	call   3420 <botlish_fn_15+0x120>
			341c: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    3420:	test   rax,rax
    3423:	jne    3431 <botlish_fn_15+0x131>
    3429:	mov    rdi,r13
    342c:	jmp    344d <botlish_fn_15+0x14d>
    3431:	mov    QWORD PTR [r12+0x8],rax
    3436:	mov    rsi,rax
    3439:	mov    rdi,r13
    343c:	call   3441 <botlish_fn_15+0x141>
			343d: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_local_char<str>
    3441:	test   rax,rax
    3444:	jne    3472 <botlish_fn_15+0x172>
    344a:	mov    rdi,r13
    344d:	mov    rdi,r13
    3450:	mov    QWORD PTR [rdi],r12
    3453:	xor    rax,rax
    3456:	mov    rbx,QWORD PTR [rsp]
    345a:	mov    r12,QWORD PTR [rsp+0x8]
    345f:	mov    r13,QWORD PTR [rsp+0x10]
    3464:	mov    r14,QWORD PTR [rsp+0x18]
    3469:	add    rsp,0x20
    346d:	mov    rsp,rbp
    3470:	pop    rbp
    3471:	ret
    3472:	cmp    rax,0x6
    3476:	je     3487 <botlish_fn_15+0x187>
    347c:	mov    rax,r14
    347f:	mov    rdi,r13
    3482:	jmp    34ed <botlish_fn_15+0x1ed>
    3487:	mov    QWORD PTR [r12+0x8],rbx
    348c:	mov    QWORD PTR [r12+0x10],0x3
    3495:	mov    rsi,r14
    3498:	test   rsi,0x1
    349f:	je     34c5 <botlish_fn_15+0x1c5>
    34a5:	mov    rsi,r14
    34a8:	mov    rcx,rsi
    34ab:	add    rcx,0x2
    34af:	seto   al
    34b2:	test   al,al
    34b4:	jne    34c5 <botlish_fn_15+0x1c5>
    34ba:	mov    rsi,rcx
    34bd:	mov    r14,rcx
    34c0:	jmp    34db <botlish_fn_15+0x1db>
    34c5:	mov    edx,0x3
    34ca:	mov    rsi,r14
    34cd:	mov    rdi,r13
    34d0:	call   34d5 <botlish_fn_15+0x1d5>
			34d1: R_X86_64_PLT32	rt_int_add-0x4
    34d5:	mov    rsi,rax
    34d8:	mov    r14,rax
    34db:	mov    QWORD PTR [r12],rsi
    34df:	mov    rsi,r14
    34e2:	jmp    335f <botlish_fn_15+0x5f>
    34e7:	mov    rax,r14
    34ea:	mov    rdi,r13
    34ed:	mov    rdi,r13
    34f0:	mov    QWORD PTR [rdi],r12
    34f3:	mov    rbx,QWORD PTR [rsp]
    34f7:	mov    r12,QWORD PTR [rsp+0x8]
    34fc:	mov    r13,QWORD PTR [rsp+0x10]
    3501:	mov    r14,QWORD PTR [rsp+0x18]
    3506:	add    rsp,0x20
    350a:	mov    rsp,rbp
    350d:	pop    rbp
    350e:	ret
    350f:	mov    r13,rdi
    3512:	call   3517 <botlish_fn_15+0x217>
			3513: R_X86_64_PLT32	rt_stack_overflow-0x4
    3517:	xor    rax,rax
    351a:	mov    rbx,QWORD PTR [rsp]
    351e:	mov    r12,QWORD PTR [rsp+0x8]
    3523:	mov    r13,QWORD PTR [rsp+0x10]
    3528:	mov    r14,QWORD PTR [rsp+0x18]
    352d:	add    rsp,0x20
    3531:	mov    rsp,rbp
    3534:	pop    rbp
    3535:	ret
    3536:	add    BYTE PTR [rax],al
    3538:	(bad)
    3539:	add    BYTE PTR [rax],al
    353b:	add    BYTE PTR [rax],al
    353d:	add    BYTE PTR [rax],al
	...

0000000000003540 <botlish_entry_15: scan_local<generic>>:
    3540:	push   rbp
    3541:	mov    rbp,rsp
    3544:	mov    rdx,QWORD PTR [rdx]
    3547:	call   354c <botlish_entry_15+0xc>
			3548: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    354c:	mov    rsp,rbp
    354f:	pop    rbp
    3550:	ret
    3551:	add    BYTE PTR [rax],al
    3553:	add    BYTE PTR [rax],al
    3555:	add    BYTE PTR [rax],al
	...

0000000000003558 <botlish_fn_16: scan_label<generic>>:
    3558:	push   rbp
    3559:	mov    rbp,rsp
    355c:	sub    rsp,0x20
    3560:	mov    QWORD PTR [rsp],rbx
    3564:	mov    QWORD PTR [rsp+0x8],r12
    3569:	mov    QWORD PTR [rsp+0x10],r13
    356e:	mov    QWORD PTR [rsp+0x18],r14
    3573:	mov    r12,QWORD PTR [rdi]
    3576:	mov    rax,QWORD PTR [rdi+0x8]
    357a:	lea    rcx,[r12+0x18]
    357f:	cmp    rcx,rax
    3582:	ja     3767 <botlish_fn_16+0x20f>
    3588:	lea    rax,[r12+0x18]
    358d:	mov    QWORD PTR [rdi],rax
    3590:	mov    r13,rdi
    3593:	mov    QWORD PTR [r12],0x0
    359b:	mov    QWORD PTR [r12+0x8],0x0
    35a4:	mov    QWORD PTR [r12+0x10],0x0
    35ad:	mov    QWORD PTR [r12],rdx
    35b1:	mov    rbx,rsi
    35b4:	mov    rsi,rdx
    35b7:	mov    rax,QWORD PTR [rbx+0x20]
    35bb:	mov    rdx,QWORD PTR [rax]
    35be:	mov    ecx,0x1
    35c3:	test   rsi,0x1
    35ca:	jne    35e8 <botlish_fn_16+0x90>
    35d0:	xor    ecx,ecx
    35d2:	test   rsi,0x7
    35d9:	jne    35e8 <botlish_fn_16+0x90>
    35df:	movzx  rax,BYTE PTR [rsi]
    35e3:	cmp    al,0x1
    35e5:	sete   cl
    35e8:	test   cl,cl
    35ea:	jne    360e <botlish_fn_16+0xb6>
    35f0:	mov    rdi,r13
    35f3:	mov    rax,QWORD PTR [rdi+0x10]
    35f7:	mov    rcx,QWORD PTR [rax+0xb8]
    35fe:	xor    rdx,rdx
    3601:	call   3606 <botlish_fn_16+0xae>
			3602: R_X86_64_PLT32	rt_type_error-0x4
    3606:	mov    rdi,r13
    3609:	jmp    36a5 <botlish_fn_16+0x14d>
    360e:	mov    rax,rsi
    3611:	and    rax,rdx
    3614:	mov    r14,rsi
    3617:	test   rax,0x1
    361d:	jne    3643 <botlish_fn_16+0xeb>
    3623:	mov    rsi,r14
    3626:	mov    rdi,r13
    3629:	call   362e <botlish_fn_16+0xd6>
			362a: R_X86_64_PLT32	rt_int_cmp-0x4
    362e:	mov    ecx,0x2
    3633:	test   rax,rax
    3636:	cmovge rcx,QWORD PTR [rip+0x152]        # 3790 <botlish_fn_16+0x238>
    363e:	jmp    3656 <botlish_fn_16+0xfe>
    3643:	mov    ecx,0x2
    3648:	mov    rsi,r14
    364b:	cmp    rsi,rdx
    364e:	cmovge rcx,QWORD PTR [rip+0x13a]        # 3790 <botlish_fn_16+0x238>
    3656:	cmp    rcx,0x6
    365a:	je     373f <botlish_fn_16+0x1e7>
    3660:	mov    rdi,QWORD PTR [rbx+0x20]
    3664:	mov    rsi,QWORD PTR [rdi+0x8]
    3668:	mov    QWORD PTR [r12+0x8],rsi
    366d:	mov    rdx,r14
    3670:	mov    rdi,r13
    3673:	call   3678 <botlish_fn_16+0x120>
			3674: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    3678:	test   rax,rax
    367b:	jne    3689 <botlish_fn_16+0x131>
    3681:	mov    rdi,r13
    3684:	jmp    36a5 <botlish_fn_16+0x14d>
    3689:	mov    QWORD PTR [r12+0x8],rax
    368e:	mov    rsi,rax
    3691:	mov    rdi,r13
    3694:	call   3699 <botlish_fn_16+0x141>
			3695: R_X86_64_PLT32	botlish_fn_14-0x4 ; is_label_char<str>
    3699:	test   rax,rax
    369c:	jne    36ca <botlish_fn_16+0x172>
    36a2:	mov    rdi,r13
    36a5:	mov    rdi,r13
    36a8:	mov    QWORD PTR [rdi],r12
    36ab:	xor    rax,rax
    36ae:	mov    rbx,QWORD PTR [rsp]
    36b2:	mov    r12,QWORD PTR [rsp+0x8]
    36b7:	mov    r13,QWORD PTR [rsp+0x10]
    36bc:	mov    r14,QWORD PTR [rsp+0x18]
    36c1:	add    rsp,0x20
    36c5:	mov    rsp,rbp
    36c8:	pop    rbp
    36c9:	ret
    36ca:	cmp    rax,0x6
    36ce:	je     36df <botlish_fn_16+0x187>
    36d4:	mov    rax,r14
    36d7:	mov    rdi,r13
    36da:	jmp    3745 <botlish_fn_16+0x1ed>
    36df:	mov    QWORD PTR [r12+0x8],rbx
    36e4:	mov    QWORD PTR [r12+0x10],0x3
    36ed:	mov    rsi,r14
    36f0:	test   rsi,0x1
    36f7:	je     371d <botlish_fn_16+0x1c5>
    36fd:	mov    rsi,r14
    3700:	mov    rcx,rsi
    3703:	add    rcx,0x2
    3707:	seto   al
    370a:	test   al,al
    370c:	jne    371d <botlish_fn_16+0x1c5>
    3712:	mov    rsi,rcx
    3715:	mov    r14,rcx
    3718:	jmp    3733 <botlish_fn_16+0x1db>
    371d:	mov    edx,0x3
    3722:	mov    rsi,r14
    3725:	mov    rdi,r13
    3728:	call   372d <botlish_fn_16+0x1d5>
			3729: R_X86_64_PLT32	rt_int_add-0x4
    372d:	mov    rsi,rax
    3730:	mov    r14,rax
    3733:	mov    QWORD PTR [r12],rsi
    3737:	mov    rsi,r14
    373a:	jmp    35b7 <botlish_fn_16+0x5f>
    373f:	mov    rax,r14
    3742:	mov    rdi,r13
    3745:	mov    rdi,r13
    3748:	mov    QWORD PTR [rdi],r12
    374b:	mov    rbx,QWORD PTR [rsp]
    374f:	mov    r12,QWORD PTR [rsp+0x8]
    3754:	mov    r13,QWORD PTR [rsp+0x10]
    3759:	mov    r14,QWORD PTR [rsp+0x18]
    375e:	add    rsp,0x20
    3762:	mov    rsp,rbp
    3765:	pop    rbp
    3766:	ret
    3767:	mov    r13,rdi
    376a:	call   376f <botlish_fn_16+0x217>
			376b: R_X86_64_PLT32	rt_stack_overflow-0x4
    376f:	xor    rax,rax
    3772:	mov    rbx,QWORD PTR [rsp]
    3776:	mov    r12,QWORD PTR [rsp+0x8]
    377b:	mov    r13,QWORD PTR [rsp+0x10]
    3780:	mov    r14,QWORD PTR [rsp+0x18]
    3785:	add    rsp,0x20
    3789:	mov    rsp,rbp
    378c:	pop    rbp
    378d:	ret
    378e:	add    BYTE PTR [rax],al
    3790:	(bad)
    3791:	add    BYTE PTR [rax],al
    3793:	add    BYTE PTR [rax],al
    3795:	add    BYTE PTR [rax],al
	...

0000000000003798 <botlish_entry_16: scan_label<generic>>:
    3798:	push   rbp
    3799:	mov    rbp,rsp
    379c:	mov    rdx,QWORD PTR [rdx]
    379f:	call   37a4 <botlish_entry_16+0xc>
			37a0: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_label<generic>
    37a4:	mov    rsp,rbp
    37a7:	pop    rbp
    37a8:	ret
    37a9:	add    BYTE PTR [rax],al
    37ab:	add    BYTE PTR [rax],al
    37ad:	add    BYTE PTR [rax],al
	...

00000000000037b0 <botlish_fn_17: scan_alpha<generic>>:
    37b0:	push   rbp
    37b1:	mov    rbp,rsp
    37b4:	sub    rsp,0x20
    37b8:	mov    QWORD PTR [rsp],rbx
    37bc:	mov    QWORD PTR [rsp+0x8],r12
    37c1:	mov    QWORD PTR [rsp+0x10],r13
    37c6:	mov    QWORD PTR [rsp+0x18],r14
    37cb:	mov    r12,QWORD PTR [rdi]
    37ce:	mov    rax,QWORD PTR [rdi+0x8]
    37d2:	lea    rcx,[r12+0x18]
    37d7:	cmp    rcx,rax
    37da:	ja     39ba <botlish_fn_17+0x20a>
    37e0:	lea    rax,[r12+0x18]
    37e5:	mov    QWORD PTR [rdi],rax
    37e8:	mov    r13,rdi
    37eb:	mov    QWORD PTR [r12],0x0
    37f3:	mov    QWORD PTR [r12+0x8],0x0
    37fc:	mov    QWORD PTR [r12+0x10],0x0
    3805:	mov    QWORD PTR [r12],rdx
    3809:	mov    rbx,rsi
    380c:	mov    rsi,rdx
    380f:	mov    rax,QWORD PTR [rbx+0x20]
    3813:	mov    rdx,QWORD PTR [rax]
    3816:	mov    ecx,0x1
    381b:	test   rsi,0x1
    3822:	jne    3840 <botlish_fn_17+0x90>
    3828:	xor    ecx,ecx
    382a:	test   rsi,0x7
    3831:	jne    3840 <botlish_fn_17+0x90>
    3837:	movzx  rax,BYTE PTR [rsi]
    383b:	cmp    al,0x1
    383d:	sete   cl
    3840:	test   cl,cl
    3842:	jne    3866 <botlish_fn_17+0xb6>
    3848:	mov    rdi,r13
    384b:	mov    rax,QWORD PTR [rdi+0x10]
    384f:	mov    rcx,QWORD PTR [rax+0xb8]
    3856:	xor    rdx,rdx
    3859:	call   385e <botlish_fn_17+0xae>
			385a: R_X86_64_PLT32	rt_type_error-0x4
    385e:	mov    rdi,r13
    3861:	jmp    38f8 <botlish_fn_17+0x148>
    3866:	mov    rax,rsi
    3869:	and    rax,rdx
    386c:	mov    r14,rsi
    386f:	test   rax,0x1
    3875:	jne    389b <botlish_fn_17+0xeb>
    387b:	mov    rsi,r14
    387e:	mov    rdi,r13
    3881:	call   3886 <botlish_fn_17+0xd6>
			3882: R_X86_64_PLT32	rt_int_cmp-0x4
    3886:	mov    ecx,0x2
    388b:	test   rax,rax
    388e:	cmovge rcx,QWORD PTR [rip+0x152]        # 39e8 <botlish_fn_17+0x238>
    3896:	jmp    38ae <botlish_fn_17+0xfe>
    389b:	mov    ecx,0x2
    38a0:	mov    rsi,r14
    38a3:	cmp    rsi,rdx
    38a6:	cmovge rcx,QWORD PTR [rip+0x13a]        # 39e8 <botlish_fn_17+0x238>
    38ae:	cmp    rcx,0x6
    38b2:	je     3992 <botlish_fn_17+0x1e2>
    38b8:	mov    rdi,QWORD PTR [rbx+0x20]
    38bc:	mov    rsi,QWORD PTR [rdi+0x8]
    38c0:	mov    QWORD PTR [r12+0x8],rsi
    38c5:	mov    rdx,r14
    38c8:	mov    rdi,r13
    38cb:	call   38d0 <botlish_fn_17+0x120>
			38cc: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    38d0:	test   rax,rax
    38d3:	mov    rsi,rax
    38d6:	jne    38e4 <botlish_fn_17+0x134>
    38dc:	mov    rdi,r13
    38df:	jmp    38f8 <botlish_fn_17+0x148>
    38e4:	mov    rdi,r13
    38e7:	call   38ec <botlish_fn_17+0x13c>
			38e8: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    38ec:	test   rax,rax
    38ef:	jne    391d <botlish_fn_17+0x16d>
    38f5:	mov    rdi,r13
    38f8:	mov    rdi,r13
    38fb:	mov    QWORD PTR [rdi],r12
    38fe:	xor    rax,rax
    3901:	mov    rbx,QWORD PTR [rsp]
    3905:	mov    r12,QWORD PTR [rsp+0x8]
    390a:	mov    r13,QWORD PTR [rsp+0x10]
    390f:	mov    r14,QWORD PTR [rsp+0x18]
    3914:	add    rsp,0x20
    3918:	mov    rsp,rbp
    391b:	pop    rbp
    391c:	ret
    391d:	cmp    rax,0x6
    3921:	je     3932 <botlish_fn_17+0x182>
    3927:	mov    rax,r14
    392a:	mov    rdi,r13
    392d:	jmp    3998 <botlish_fn_17+0x1e8>
    3932:	mov    QWORD PTR [r12+0x8],rbx
    3937:	mov    QWORD PTR [r12+0x10],0x3
    3940:	mov    rsi,r14
    3943:	test   rsi,0x1
    394a:	je     3970 <botlish_fn_17+0x1c0>
    3950:	mov    rsi,r14
    3953:	mov    rcx,rsi
    3956:	add    rcx,0x2
    395a:	seto   al
    395d:	test   al,al
    395f:	jne    3970 <botlish_fn_17+0x1c0>
    3965:	mov    rsi,rcx
    3968:	mov    r14,rcx
    396b:	jmp    3986 <botlish_fn_17+0x1d6>
    3970:	mov    edx,0x3
    3975:	mov    rsi,r14
    3978:	mov    rdi,r13
    397b:	call   3980 <botlish_fn_17+0x1d0>
			397c: R_X86_64_PLT32	rt_int_add-0x4
    3980:	mov    rsi,rax
    3983:	mov    r14,rax
    3986:	mov    QWORD PTR [r12],rsi
    398a:	mov    rsi,r14
    398d:	jmp    380f <botlish_fn_17+0x5f>
    3992:	mov    rax,r14
    3995:	mov    rdi,r13
    3998:	mov    rdi,r13
    399b:	mov    QWORD PTR [rdi],r12
    399e:	mov    rbx,QWORD PTR [rsp]
    39a2:	mov    r12,QWORD PTR [rsp+0x8]
    39a7:	mov    r13,QWORD PTR [rsp+0x10]
    39ac:	mov    r14,QWORD PTR [rsp+0x18]
    39b1:	add    rsp,0x20
    39b5:	mov    rsp,rbp
    39b8:	pop    rbp
    39b9:	ret
    39ba:	mov    r13,rdi
    39bd:	call   39c2 <botlish_fn_17+0x212>
			39be: R_X86_64_PLT32	rt_stack_overflow-0x4
    39c2:	xor    rax,rax
    39c5:	mov    rbx,QWORD PTR [rsp]
    39c9:	mov    r12,QWORD PTR [rsp+0x8]
    39ce:	mov    r13,QWORD PTR [rsp+0x10]
    39d3:	mov    r14,QWORD PTR [rsp+0x18]
    39d8:	add    rsp,0x20
    39dc:	mov    rsp,rbp
    39df:	pop    rbp
    39e0:	ret
    39e1:	add    BYTE PTR [rax],al
    39e3:	add    BYTE PTR [rax],al
    39e5:	add    BYTE PTR [rax],al
    39e7:	add    BYTE PTR [rsi],al
    39e9:	add    BYTE PTR [rax],al
    39eb:	add    BYTE PTR [rax],al
    39ed:	add    BYTE PTR [rax],al
	...

00000000000039f0 <botlish_entry_17: scan_alpha<generic>>:
    39f0:	push   rbp
    39f1:	mov    rbp,rsp
    39f4:	mov    rdx,QWORD PTR [rdx]
    39f7:	call   39fc <botlish_entry_17+0xc>
			39f8: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_alpha<generic>
    39fc:	mov    rsp,rbp
    39ff:	pop    rbp
    3a00:	ret
    3a01:	add    BYTE PTR [rax],al
    3a03:	add    BYTE PTR [rax],al
    3a05:	add    BYTE PTR [rax],al
	...

0000000000003a08 <botlish_fn_18: tld_ok<generic>>:
    3a08:	push   rbp
    3a09:	mov    rbp,rsp
    3a0c:	sub    rsp,0x30
    3a10:	mov    QWORD PTR [rsp],rbx
    3a14:	mov    QWORD PTR [rsp+0x8],r12
    3a19:	mov    QWORD PTR [rsp+0x10],r13
    3a1e:	mov    QWORD PTR [rsp+0x18],r14
    3a23:	mov    QWORD PTR [rsp+0x20],r15
    3a28:	mov    rbx,QWORD PTR [rdi]
    3a2b:	mov    rax,QWORD PTR [rdi+0x8]
    3a2f:	lea    rcx,[rbx+0x10]
    3a33:	cmp    rcx,rax
    3a36:	ja     3c4a <botlish_fn_18+0x242>
    3a3c:	lea    rax,[rbx+0x10]
    3a40:	mov    QWORD PTR [rdi],rax
    3a43:	mov    r12,rdi
    3a46:	mov    QWORD PTR [rbx],0x0
    3a4d:	mov    QWORD PTR [rbx+0x8],0x0
    3a55:	mov    QWORD PTR [rbx],rdx
    3a58:	mov    r8,rdx
    3a5b:	mov    rax,QWORD PTR [rsi+0x20]
    3a5f:	mov    r15,rsi
    3a62:	mov    rsi,QWORD PTR [rax]
    3a65:	mov    QWORD PTR [rbx+0x8],rsi
    3a69:	mov    r13,r8
    3a6c:	mov    rdx,r13
    3a6f:	mov    rdi,r12
    3a72:	call   3a77 <botlish_fn_18+0x6f>
			3a73: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_alpha<generic>
    3a77:	mov    rcx,rax
    3a7a:	mov    r14,rax
    3a7d:	test   rax,rcx
    3a80:	jne    3a8e <botlish_fn_18+0x86>
    3a86:	mov    rdi,r12
    3a89:	jmp    3b66 <botlish_fn_18+0x15e>
    3a8e:	mov    rax,r14
    3a91:	mov    QWORD PTR [rbx+0x8],rax
    3a95:	mov    rsi,r15
    3a98:	mov    rax,QWORD PTR [rsi+0x20]
    3a9c:	mov    rdx,QWORD PTR [rax+0x8]
    3aa0:	mov    rax,r14
    3aa3:	and    rax,rdx
    3aa6:	test   rax,0x1
    3aac:	jne    3ad5 <botlish_fn_18+0xcd>
    3ab2:	mov    rsi,r14
    3ab5:	mov    rdi,r12
    3ab8:	call   3abd <botlish_fn_18+0xb5>
			3ab9: R_X86_64_PLT32	rt_int_cmp-0x4
    3abd:	mov    ecx,0x2
    3ac2:	test   rax,rax
    3ac5:	cmove  rcx,QWORD PTR [rip+0x1ab]        # 3c78 <botlish_fn_18+0x270>
    3acd:	mov    rax,r14
    3ad0:	jmp    3ae8 <botlish_fn_18+0xe0>
    3ad5:	mov    ecx,0x2
    3ada:	mov    rax,r14
    3add:	cmp    rax,rdx
    3ae0:	cmove  rcx,QWORD PTR [rip+0x190]        # 3c78 <botlish_fn_18+0x270>
    3ae8:	cmp    rcx,0x6
    3aec:	je     3b02 <botlish_fn_18+0xfa>
    3af2:	mov    ecx,0x2
    3af7:	mov    rax,rcx
    3afa:	mov    rdi,r12
    3afd:	jmp    3c23 <botlish_fn_18+0x21b>
    3b02:	mov    ecx,0x1
    3b07:	test   r13,0x1
    3b0e:	je     3b1c <botlish_fn_18+0x114>
    3b14:	mov    r8,r13
    3b17:	jmp    3b42 <botlish_fn_18+0x13a>
    3b1c:	xor    ecx,ecx
    3b1e:	test   r13,0x7
    3b25:	je     3b33 <botlish_fn_18+0x12b>
    3b2b:	mov    r8,r13
    3b2e:	jmp    3b42 <botlish_fn_18+0x13a>
    3b33:	movzx  rcx,BYTE PTR [r13+0x0]
    3b38:	mov    r8,r13
    3b3b:	rex cmp cl,0x1
    3b3f:	sete   cl
    3b42:	test   cl,cl
    3b44:	jne    3b90 <botlish_fn_18+0x188>
    3b4a:	mov    rdi,r12
    3b4d:	mov    rax,QWORD PTR [rdi+0x10]
    3b51:	mov    rcx,QWORD PTR [rax+0x128]
    3b58:	xor    rdx,rdx
    3b5b:	mov    rsi,r8
    3b5e:	call   3b63 <botlish_fn_18+0x15b>
			3b5f: R_X86_64_PLT32	rt_type_error-0x4
    3b63:	mov    rdi,r12
    3b66:	mov    rdi,r12
    3b69:	mov    QWORD PTR [rdi],rbx
    3b6c:	xor    rax,rax
    3b6f:	mov    rbx,QWORD PTR [rsp]
    3b73:	mov    r12,QWORD PTR [rsp+0x8]
    3b78:	mov    r13,QWORD PTR [rsp+0x10]
    3b7d:	mov    r14,QWORD PTR [rsp+0x18]
    3b82:	mov    r15,QWORD PTR [rsp+0x20]
    3b87:	add    rsp,0x30
    3b8b:	mov    rsp,rbp
    3b8e:	pop    rbp
    3b8f:	ret
    3b90:	mov    rdx,r8
    3b93:	mov    rcx,rax
    3b96:	and    rcx,rdx
    3b99:	test   rcx,0x1
    3ba0:	jne    3bb1 <botlish_fn_18+0x1a9>
    3ba6:	mov    rdx,r8
    3ba9:	mov    rsi,rax
    3bac:	jmp    3bd2 <botlish_fn_18+0x1ca>
    3bb1:	mov    rdx,r8
    3bb4:	mov    rcx,rax
    3bb7:	sub    rcx,rdx
    3bba:	mov    r14,rax
    3bbd:	seto   al
    3bc0:	lea    rsi,[rcx+0x1]
    3bc4:	test   al,al
    3bc6:	je     3bdd <botlish_fn_18+0x1d5>
    3bcc:	mov    rdx,r8
    3bcf:	mov    rsi,r14
    3bd2:	mov    rdi,r12
    3bd5:	call   3bda <botlish_fn_18+0x1d2>
			3bd6: R_X86_64_PLT32	rt_int_sub-0x4
    3bda:	mov    rsi,rax
    3bdd:	test   rsi,0x1
    3be4:	jne    3c0f <botlish_fn_18+0x207>
    3bea:	mov    edx,0x5
    3bef:	mov    rdi,r12
    3bf2:	call   3bf7 <botlish_fn_18+0x1ef>
			3bf3: R_X86_64_PLT32	rt_int_cmp-0x4
    3bf7:	mov    ecx,0x2
    3bfc:	test   rax,rax
    3bff:	mov    rax,rcx
    3c02:	cmovge rax,QWORD PTR [rip+0x6e]        # 3c78 <botlish_fn_18+0x270>
    3c0a:	jmp    3c20 <botlish_fn_18+0x218>
    3c0f:	mov    eax,0x2
    3c14:	cmp    rsi,0x5
    3c18:	cmovge rax,QWORD PTR [rip+0x58]        # 3c78 <botlish_fn_18+0x270>
    3c20:	mov    rdi,r12
    3c23:	mov    rdi,r12
    3c26:	mov    QWORD PTR [rdi],rbx
    3c29:	mov    rbx,QWORD PTR [rsp]
    3c2d:	mov    r12,QWORD PTR [rsp+0x8]
    3c32:	mov    r13,QWORD PTR [rsp+0x10]
    3c37:	mov    r14,QWORD PTR [rsp+0x18]
    3c3c:	mov    r15,QWORD PTR [rsp+0x20]
    3c41:	add    rsp,0x30
    3c45:	mov    rsp,rbp
    3c48:	pop    rbp
    3c49:	ret
    3c4a:	mov    r12,rdi
    3c4d:	call   3c52 <botlish_fn_18+0x24a>
			3c4e: R_X86_64_PLT32	rt_stack_overflow-0x4
    3c52:	xor    rax,rax
    3c55:	mov    rbx,QWORD PTR [rsp]
    3c59:	mov    r12,QWORD PTR [rsp+0x8]
    3c5e:	mov    r13,QWORD PTR [rsp+0x10]
    3c63:	mov    r14,QWORD PTR [rsp+0x18]
    3c68:	mov    r15,QWORD PTR [rsp+0x20]
    3c6d:	add    rsp,0x30
    3c71:	mov    rsp,rbp
    3c74:	pop    rbp
    3c75:	ret
    3c76:	add    BYTE PTR [rax],al
    3c78:	(bad)
    3c79:	add    BYTE PTR [rax],al
    3c7b:	add    BYTE PTR [rax],al
    3c7d:	add    BYTE PTR [rax],al
	...

0000000000003c80 <botlish_entry_18: tld_ok<generic>>:
    3c80:	push   rbp
    3c81:	mov    rbp,rsp
    3c84:	mov    rdx,QWORD PTR [rdx]
    3c87:	call   3c8c <botlish_entry_18+0xc>
			3c88: R_X86_64_PLT32	botlish_fn_18-0x4 ; tld_ok<generic>
    3c8c:	mov    rsp,rbp
    3c8f:	pop    rbp
    3c90:	ret
    3c91:	add    BYTE PTR [rax],al
    3c93:	add    BYTE PTR [rax],al
    3c95:	add    BYTE PTR [rax],al
	...

0000000000003c98 <botlish_fn_19: domain_loop<generic>>:
    3c98:	push   rbp
    3c99:	mov    rbp,rsp
    3c9c:	sub    rsp,0x50
    3ca0:	mov    QWORD PTR [rsp+0x20],rbx
    3ca5:	mov    QWORD PTR [rsp+0x28],r12
    3caa:	mov    QWORD PTR [rsp+0x30],r13
    3caf:	mov    QWORD PTR [rsp+0x38],r14
    3cb4:	mov    QWORD PTR [rsp+0x40],r15
    3cb9:	mov    r13,QWORD PTR [rdi]
    3cbc:	mov    rax,QWORD PTR [rdi+0x8]
    3cc0:	lea    rcx,[r13+0x10]
    3cc4:	cmp    rcx,rax
    3cc7:	ja     3f46 <botlish_fn_19+0x2ae>
    3ccd:	lea    rax,[r13+0x10]
    3cd1:	mov    QWORD PTR [rdi],rax
    3cd4:	mov    r15,rdi
    3cd7:	mov    QWORD PTR [r13+0x0],0x0
    3cdf:	mov    QWORD PTR [r13+0x8],0x0
    3ce7:	mov    QWORD PTR [r13+0x0],rdx
    3ceb:	mov    QWORD PTR [rsp+0x10],rdx
    3cf0:	lea    rbx,[rsp]
    3cf4:	mov    r12,rsi
    3cf7:	mov    rax,QWORD PTR [r12+0x20]
    3cfc:	mov    rsi,QWORD PTR [rax]
    3cff:	mov    QWORD PTR [r13+0x8],rsi
    3d03:	mov    rdx,QWORD PTR [rsp+0x10]
    3d08:	mov    rdi,r15
    3d0b:	call   3d10 <botlish_fn_19+0x78>
			3d0c: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_label<generic>
    3d10:	mov    rcx,rax
    3d13:	mov    r14,rax
    3d16:	test   rax,rcx
    3d19:	jne    3d27 <botlish_fn_19+0x8f>
    3d1f:	mov    rdi,r15
    3d22:	jmp    3eb4 <botlish_fn_19+0x21c>
    3d27:	mov    rax,r14
    3d2a:	mov    QWORD PTR [r13+0x0],rax
    3d2e:	mov    rdx,QWORD PTR [rsp+0x10]
    3d33:	mov    rsi,rax
    3d36:	and    rsi,rdx
    3d39:	test   rsi,0x1
    3d40:	jne    3d67 <botlish_fn_19+0xcf>
    3d46:	mov    rdx,QWORD PTR [rsp+0x10]
    3d4b:	mov    rsi,r14
    3d4e:	mov    rdi,r15
    3d51:	call   3d56 <botlish_fn_19+0xbe>
			3d52: R_X86_64_PLT32	rt_value_eq-0x4
    3d56:	test   rax,rax
    3d59:	jne    3d7c <botlish_fn_19+0xe4>
    3d5f:	mov    rdi,r15
    3d62:	jmp    3eb4 <botlish_fn_19+0x21c>
    3d67:	mov    eax,0x2
    3d6c:	mov    rdx,QWORD PTR [rsp+0x10]
    3d71:	cmp    r14,rdx
    3d74:	cmove  rax,QWORD PTR [rip+0x1fc]        # 3f78 <botlish_fn_19+0x2e0>
    3d7c:	cmp    rax,0x6
    3d80:	je     3f14 <botlish_fn_19+0x27c>
    3d86:	mov    rax,QWORD PTR [r12+0x20]
    3d8b:	mov    rdx,QWORD PTR [rax+0x8]
    3d8f:	mov    rax,r14
    3d92:	and    rax,rdx
    3d95:	test   rax,0x1
    3d9b:	jne    3dc1 <botlish_fn_19+0x129>
    3da1:	mov    rsi,r14
    3da4:	mov    rdi,r15
    3da7:	call   3dac <botlish_fn_19+0x114>
			3da8: R_X86_64_PLT32	rt_int_cmp-0x4
    3dac:	mov    ecx,0x2
    3db1:	test   rax,rax
    3db4:	cmovge rcx,QWORD PTR [rip+0x1bc]        # 3f78 <botlish_fn_19+0x2e0>
    3dbc:	jmp    3dd1 <botlish_fn_19+0x139>
    3dc1:	mov    ecx,0x2
    3dc6:	cmp    r14,rdx
    3dc9:	cmovge rcx,QWORD PTR [rip+0x1a7]        # 3f78 <botlish_fn_19+0x2e0>
    3dd1:	cmp    rcx,0x6
    3dd5:	je     3f05 <botlish_fn_19+0x26d>
    3ddb:	mov    rax,QWORD PTR [r12+0x20]
    3de0:	mov    rsi,QWORD PTR [rax+0x10]
    3de4:	mov    QWORD PTR [r13+0x8],rsi
    3de8:	mov    rcx,rbx
    3deb:	mov    rdx,r14
    3dee:	mov    rdi,r15
    3df1:	call   3df6 <botlish_fn_19+0x15e>
			3df2: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    3df6:	test   rax,rax
    3df9:	mov    rsi,rax
    3dfc:	jne    3e0a <botlish_fn_19+0x172>
    3e02:	mov    rdi,r15
    3e05:	jmp    3eb4 <botlish_fn_19+0x21c>
    3e0a:	mov    rdx,QWORD PTR [rsp]
    3e0e:	mov    rcx,QWORD PTR [rsp+0x8]
    3e13:	mov    rdi,r15
    3e16:	mov    rax,QWORD PTR [rdi+0x10]
    3e1a:	mov    r8,QWORD PTR [rax+0x118]
    3e21:	call   3e26 <botlish_fn_19+0x18e>
			3e22: R_X86_64_PLT32	rt_str_region_eq-0x4
    3e26:	cmp    rax,0x6
    3e2a:	je     3e3c <botlish_fn_19+0x1a4>
    3e30:	mov    rax,0xffffffffffffffff
    3e37:	jmp    3f0c <botlish_fn_19+0x274>
    3e3c:	mov    QWORD PTR [r13+0x8],0x3
    3e44:	test   r14,0x1
    3e4b:	je     3e72 <botlish_fn_19+0x1da>
    3e51:	mov    rdx,r14
    3e54:	add    rdx,0x2
    3e58:	mov    QWORD PTR [rsp+0x10],rdx
    3e5d:	seto   al
    3e60:	test   al,al
    3e62:	jne    3e72 <botlish_fn_19+0x1da>
    3e68:	mov    rdx,QWORD PTR [rsp+0x10]
    3e6d:	jmp    3e8a <botlish_fn_19+0x1f2>
    3e72:	mov    edx,0x3
    3e77:	mov    rsi,r14
    3e7a:	mov    rdi,r15
    3e7d:	call   3e82 <botlish_fn_19+0x1ea>
			3e7e: R_X86_64_PLT32	rt_int_add-0x4
    3e82:	mov    rdx,rax
    3e85:	mov    QWORD PTR [rsp+0x10],rax
    3e8a:	mov    QWORD PTR [r13+0x0],rdx
    3e8e:	mov    rax,QWORD PTR [r12+0x20]
    3e93:	mov    rsi,QWORD PTR [rax+0x18]
    3e97:	mov    QWORD PTR [r13+0x8],rsi
    3e9b:	mov    rdx,QWORD PTR [rsp+0x10]
    3ea0:	mov    rdi,r15
    3ea3:	call   3ea8 <botlish_fn_19+0x210>
			3ea4: R_X86_64_PLT32	botlish_fn_18-0x4 ; tld_ok<generic>
    3ea8:	test   rax,rax
    3eab:	jne    3edf <botlish_fn_19+0x247>
    3eb1:	mov    rdi,r15
    3eb4:	mov    rdi,r15
    3eb7:	mov    QWORD PTR [rdi],r13
    3eba:	xor    rax,rax
    3ebd:	mov    rbx,QWORD PTR [rsp+0x20]
    3ec2:	mov    r12,QWORD PTR [rsp+0x28]
    3ec7:	mov    r13,QWORD PTR [rsp+0x30]
    3ecc:	mov    r14,QWORD PTR [rsp+0x38]
    3ed1:	mov    r15,QWORD PTR [rsp+0x40]
    3ed6:	add    rsp,0x50
    3eda:	mov    rsp,rbp
    3edd:	pop    rbp
    3ede:	ret
    3edf:	cmp    rax,0x6
    3ee3:	je     3ef7 <botlish_fn_19+0x25f>
    3ee9:	mov    rdx,QWORD PTR [rsp+0x10]
    3eee:	mov    QWORD PTR [r13+0x0],rdx
    3ef2:	jmp    3cf7 <botlish_fn_19+0x5f>
    3ef7:	mov    rax,QWORD PTR [r12+0x20]
    3efc:	mov    rax,QWORD PTR [rax+0x8]
    3f00:	jmp    3f0c <botlish_fn_19+0x274>
    3f05:	mov    rax,0xffffffffffffffff
    3f0c:	mov    rdi,r15
    3f0f:	jmp    3f1e <botlish_fn_19+0x286>
    3f14:	mov    rax,0xffffffffffffffff
    3f1b:	mov    rdi,r15
    3f1e:	mov    rdi,r15
    3f21:	mov    QWORD PTR [rdi],r13
    3f24:	mov    rbx,QWORD PTR [rsp+0x20]
    3f29:	mov    r12,QWORD PTR [rsp+0x28]
    3f2e:	mov    r13,QWORD PTR [rsp+0x30]
    3f33:	mov    r14,QWORD PTR [rsp+0x38]
    3f38:	mov    r15,QWORD PTR [rsp+0x40]
    3f3d:	add    rsp,0x50
    3f41:	mov    rsp,rbp
    3f44:	pop    rbp
    3f45:	ret
    3f46:	mov    r15,rdi
    3f49:	call   3f4e <botlish_fn_19+0x2b6>
			3f4a: R_X86_64_PLT32	rt_stack_overflow-0x4
    3f4e:	xor    rax,rax
    3f51:	mov    rbx,QWORD PTR [rsp+0x20]
    3f56:	mov    r12,QWORD PTR [rsp+0x28]
    3f5b:	mov    r13,QWORD PTR [rsp+0x30]
    3f60:	mov    r14,QWORD PTR [rsp+0x38]
    3f65:	mov    r15,QWORD PTR [rsp+0x40]
    3f6a:	add    rsp,0x50
    3f6e:	mov    rsp,rbp
    3f71:	pop    rbp
    3f72:	ret
    3f73:	add    BYTE PTR [rax],al
    3f75:	add    BYTE PTR [rax],al
    3f77:	add    BYTE PTR [rsi],al
    3f79:	add    BYTE PTR [rax],al
    3f7b:	add    BYTE PTR [rax],al
    3f7d:	add    BYTE PTR [rax],al
	...

0000000000003f80 <botlish_entry_19: domain_loop<generic>>:
    3f80:	push   rbp
    3f81:	mov    rbp,rsp
    3f84:	mov    rdx,QWORD PTR [rdx]
    3f87:	call   3f8c <botlish_entry_19+0xc>
			3f88: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    3f8c:	mov    rsp,rbp
    3f8f:	pop    rbp
    3f90:	ret
    3f91:	add    BYTE PTR [rax],al
    3f93:	add    BYTE PTR [rax],al
    3f95:	add    BYTE PTR [rax],al
	...

0000000000003f98 <botlish_fn_20: <str>>:
    3f98:	push   rbp
    3f99:	mov    rbp,rsp
    3f9c:	sub    rsp,0xc0
    3fa3:	mov    QWORD PTR [rsp+0x90],rbx
    3fab:	mov    QWORD PTR [rsp+0x98],r12
    3fb3:	mov    QWORD PTR [rsp+0xa0],r13
    3fbb:	mov    QWORD PTR [rsp+0xa8],r14
    3fc3:	mov    QWORD PTR [rsp+0xb0],r15
    3fcb:	mov    r12,QWORD PTR [rdi]
    3fce:	mov    rax,QWORD PTR [rdi+0x8]
    3fd2:	lea    rcx,[r12+0x28]
    3fd7:	cmp    rcx,rax
    3fda:	ja     43fb <botlish_fn_20+0x463>
    3fe0:	lea    rax,[r12+0x28]
    3fe5:	mov    QWORD PTR [rdi],rax
    3fe8:	mov    QWORD PTR [rsp+0x78],rdi
    3fed:	mov    QWORD PTR [r12],0x0
    3ff5:	mov    QWORD PTR [r12+0x8],0x0
    3ffe:	mov    QWORD PTR [r12+0x10],0x0
    4007:	mov    QWORD PTR [r12+0x18],0x0
    4010:	mov    QWORD PTR [r12+0x20],0x0
    4019:	mov    QWORD PTR [r12],rsi
    401d:	mov    r13,rsi
    4020:	mov    rsi,r13
    4023:	mov    rdi,QWORD PTR [rsp+0x78]
    4028:	call   402d <botlish_fn_20+0x95>
			4029: R_X86_64_PLT32	rt_str_len-0x4
    402d:	mov    rbx,rax
    4030:	mov    QWORD PTR [r12+0x8],rbx
    4035:	lea    r8,[rsp]
    4039:	mov    QWORD PTR [rsp],r13
    403d:	mov    esi,0x16
    4042:	mov    rdx,QWORD PTR [rip+0x0]        # 4049 <botlish_fn_20+0xb1>
			4045: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; char_at<generic>
    4049:	mov    r13d,0x1
    404f:	mov    rcx,r13
    4052:	mov    rdi,QWORD PTR [rsp+0x78]
    4057:	call   405c <botlish_fn_20+0xc4>
			4058: R_X86_64_PLT32	rt_closure_new-0x4
    405c:	mov    r14,rax
    405f:	mov    QWORD PTR [r12],rax
    4063:	lea    r8,[rsp+0x8]
    4068:	mov    QWORD PTR [rsp+0x8],rbx
    406d:	mov    QWORD PTR [rsp+0x10],rax
    4072:	mov    esi,0x1a
    4077:	mov    rdx,QWORD PTR [rip+0x0]        # 407e <botlish_fn_20+0xe6>
			407a: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; scan_local<generic>
    407e:	mov    r15d,0x2
    4084:	mov    rcx,r15
    4087:	mov    rdi,QWORD PTR [rsp+0x78]
    408c:	call   4091 <botlish_fn_20+0xf9>
			408d: R_X86_64_PLT32	rt_closure_new-0x4
    4091:	mov    rsi,rax
    4094:	mov    QWORD PTR [rsp+0x88],rax
    409c:	mov    QWORD PTR [r12+0x10],rsi
    40a1:	lea    r8,[rsp+0x18]
    40a6:	mov    QWORD PTR [rsp+0x18],rbx
    40ab:	mov    rax,r14
    40ae:	mov    QWORD PTR [rsp+0x20],rax
    40b3:	mov    esi,0x1b
    40b8:	mov    rdx,QWORD PTR [rip+0x0]        # 40bf <botlish_fn_20+0x127>
			40bb: R_X86_64_GOTPCREL	botlish_entry_27-0x4 ; scan_label<generic>
    40bf:	mov    rcx,r15
    40c2:	mov    rdi,QWORD PTR [rsp+0x78]
    40c7:	call   40cc <botlish_fn_20+0x134>
			40c8: R_X86_64_PLT32	rt_closure_new-0x4
    40cc:	mov    QWORD PTR [r12+0x18],rax
    40d1:	mov    QWORD PTR [rsp+0x80],rax
    40d9:	lea    r8,[rsp+0x28]
    40de:	mov    QWORD PTR [rsp+0x28],rbx
    40e3:	mov    QWORD PTR [rsp+0x30],r14
    40e8:	mov    esi,0x1c
    40ed:	mov    rdx,QWORD PTR [rip+0x0]        # 40f4 <botlish_fn_20+0x15c>
			40f0: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; scan_alpha<generic>
    40f4:	mov    rcx,r15
    40f7:	mov    rdi,QWORD PTR [rsp+0x78]
    40fc:	call   4101 <botlish_fn_20+0x169>
			40fd: R_X86_64_PLT32	rt_closure_new-0x4
    4101:	mov    QWORD PTR [r12+0x20],rax
    4106:	lea    r8,[rsp+0x38]
    410b:	mov    QWORD PTR [rsp+0x38],rax
    4110:	mov    QWORD PTR [rsp+0x40],rbx
    4115:	mov    esi,0x1d
    411a:	mov    rdx,QWORD PTR [rip+0x0]        # 4121 <botlish_fn_20+0x189>
			411d: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; tld_ok<generic>
    4121:	mov    rcx,r15
    4124:	mov    rdi,QWORD PTR [rsp+0x78]
    4129:	call   412e <botlish_fn_20+0x196>
			412a: R_X86_64_PLT32	rt_closure_new-0x4
    412e:	mov    QWORD PTR [r12+0x20],rax
    4133:	lea    r8,[rsp+0x48]
    4138:	mov    rcx,QWORD PTR [rsp+0x80]
    4140:	mov    QWORD PTR [rsp+0x48],rcx
    4145:	mov    QWORD PTR [rsp+0x50],rbx
    414a:	mov    QWORD PTR [rsp+0x58],r14
    414f:	mov    QWORD PTR [rsp+0x60],rax
    4154:	mov    esi,0x1e
    4159:	mov    rdx,QWORD PTR [rip+0x0]        # 4160 <botlish_fn_20+0x1c8>
			415c: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; domain_loop<generic>
    4160:	mov    ecx,0x4
    4165:	mov    rdi,QWORD PTR [rsp+0x78]
    416a:	call   416f <botlish_fn_20+0x1d7>
			416b: R_X86_64_PLT32	rt_closure_new-0x4
    416f:	mov    QWORD PTR [r12+0x18],rax
    4174:	mov    r15,rax
    4177:	mov    QWORD PTR [r12+0x20],0x1
    4180:	mov    rdx,r13
    4183:	mov    rsi,QWORD PTR [rsp+0x88]
    418b:	mov    rdi,QWORD PTR [rsp+0x78]
    4190:	call   4195 <botlish_fn_20+0x1fd>
			4191: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    4195:	mov    rcx,rax
    4198:	mov    r13,rax
    419b:	test   rax,rcx
    419e:	jne    41ae <botlish_fn_20+0x216>
    41a4:	mov    rdi,QWORD PTR [rsp+0x78]
    41a9:	jmp    4311 <botlish_fn_20+0x379>
    41ae:	mov    rax,r13
    41b1:	mov    QWORD PTR [r12+0x10],rax
    41b6:	test   rax,0x1
    41bc:	jne    41e9 <botlish_fn_20+0x251>
    41c2:	mov    edx,0x1
    41c7:	mov    rsi,r13
    41ca:	mov    rdi,QWORD PTR [rsp+0x78]
    41cf:	call   41d4 <botlish_fn_20+0x23c>
			41d0: R_X86_64_PLT32	rt_int_cmp-0x4
    41d4:	mov    ecx,0x2
    41d9:	test   rax,rax
    41dc:	cmove  rcx,QWORD PTR [rip+0x25c]        # 4440 <botlish_fn_20+0x4a8>
    41e4:	jmp    41fa <botlish_fn_20+0x262>
    41e9:	mov    ecx,0x2
    41ee:	cmp    r13,0x1
    41f2:	cmove  rcx,QWORD PTR [rip+0x246]        # 4440 <botlish_fn_20+0x4a8>
    41fa:	cmp    rcx,0x6
    41fe:	je     43b5 <botlish_fn_20+0x41d>
    4204:	mov    rax,r13
    4207:	and    rax,rbx
    420a:	test   rax,0x1
    4210:	jne    423b <botlish_fn_20+0x2a3>
    4216:	mov    rdx,rbx
    4219:	mov    rsi,r13
    421c:	mov    rdi,QWORD PTR [rsp+0x78]
    4221:	call   4226 <botlish_fn_20+0x28e>
			4222: R_X86_64_PLT32	rt_int_cmp-0x4
    4226:	mov    ecx,0x2
    422b:	test   rax,rax
    422e:	cmovge rcx,QWORD PTR [rip+0x20a]        # 4440 <botlish_fn_20+0x4a8>
    4236:	jmp    424b <botlish_fn_20+0x2b3>
    423b:	mov    ecx,0x2
    4240:	cmp    r13,rbx
    4243:	cmovge rcx,QWORD PTR [rip+0x1f5]        # 4440 <botlish_fn_20+0x4a8>
    424b:	cmp    rcx,0x6
    424f:	je     43a6 <botlish_fn_20+0x40e>
    4255:	lea    rcx,[rsp+0x68]
    425a:	mov    rsi,r14
    425d:	mov    rdx,r13
    4260:	mov    rdi,QWORD PTR [rsp+0x78]
    4265:	call   426a <botlish_fn_20+0x2d2>
			4266: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    426a:	test   rax,rax
    426d:	mov    rsi,rax
    4270:	jne    4280 <botlish_fn_20+0x2e8>
    4276:	mov    rdi,QWORD PTR [rsp+0x78]
    427b:	jmp    4311 <botlish_fn_20+0x379>
    4280:	mov    rdx,QWORD PTR [rsp+0x68]
    4285:	mov    rcx,QWORD PTR [rsp+0x70]
    428a:	mov    rdi,QWORD PTR [rsp+0x78]
    428f:	mov    r8,QWORD PTR [rdi+0x10]
    4293:	mov    r8,QWORD PTR [r8+0x100]
    429a:	call   429f <botlish_fn_20+0x307>
			429b: R_X86_64_PLT32	rt_str_region_eq-0x4
    429f:	cmp    rax,0x6
    42a3:	je     42b6 <botlish_fn_20+0x31e>
    42a9:	mov    ecx,0x2
    42ae:	mov    rax,rcx
    42b1:	jmp    43ab <botlish_fn_20+0x413>
    42b6:	mov    QWORD PTR [r12],0x3
    42be:	test   r13,0x1
    42c5:	je     42dd <botlish_fn_20+0x345>
    42cb:	mov    rdx,r13
    42ce:	add    rdx,0x2
    42d2:	seto   al
    42d5:	test   al,al
    42d7:	je     42f2 <botlish_fn_20+0x35a>
    42dd:	mov    edx,0x3
    42e2:	mov    rsi,r13
    42e5:	mov    rdi,QWORD PTR [rsp+0x78]
    42ea:	call   42ef <botlish_fn_20+0x357>
			42eb: R_X86_64_PLT32	rt_int_add-0x4
    42ef:	mov    rdx,rax
    42f2:	mov    QWORD PTR [r12],rdx
    42f6:	mov    rsi,r15
    42f9:	mov    rdi,QWORD PTR [rsp+0x78]
    42fe:	call   4303 <botlish_fn_20+0x36b>
			42ff: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    4303:	test   rax,rax
    4306:	jne    4350 <botlish_fn_20+0x3b8>
    430c:	mov    rdi,QWORD PTR [rsp+0x78]
    4311:	mov    rdi,QWORD PTR [rsp+0x78]
    4316:	mov    QWORD PTR [rdi],r12
    4319:	xor    rax,rax
    431c:	mov    rbx,QWORD PTR [rsp+0x90]
    4324:	mov    r12,QWORD PTR [rsp+0x98]
    432c:	mov    r13,QWORD PTR [rsp+0xa0]
    4334:	mov    r14,QWORD PTR [rsp+0xa8]
    433c:	mov    r15,QWORD PTR [rsp+0xb0]
    4344:	add    rsp,0xc0
    434b:	mov    rsp,rbp
    434e:	pop    rbp
    434f:	ret
    4350:	mov    rcx,rax
    4353:	and    rcx,rbx
    4356:	mov    rsi,rax
    4359:	mov    rax,rbx
    435c:	test   rcx,0x1
    4363:	jne    438e <botlish_fn_20+0x3f6>
    4369:	mov    rdx,rax
    436c:	mov    rdi,QWORD PTR [rsp+0x78]
    4371:	call   4376 <botlish_fn_20+0x3de>
			4372: R_X86_64_PLT32	rt_int_cmp-0x4
    4376:	mov    ecx,0x2
    437b:	test   rax,rax
    437e:	mov    rax,rcx
    4381:	cmove  rax,QWORD PTR [rip+0xb7]        # 4440 <botlish_fn_20+0x4a8>
    4389:	jmp    43ab <botlish_fn_20+0x413>
    438e:	mov    rdx,rax
    4391:	mov    eax,0x2
    4396:	cmp    rsi,rdx
    4399:	cmove  rax,QWORD PTR [rip+0x9f]        # 4440 <botlish_fn_20+0x4a8>
    43a1:	jmp    43ab <botlish_fn_20+0x413>
    43a6:	mov    eax,0x2
    43ab:	mov    rdi,QWORD PTR [rsp+0x78]
    43b0:	jmp    43bf <botlish_fn_20+0x427>
    43b5:	mov    eax,0x2
    43ba:	mov    rdi,QWORD PTR [rsp+0x78]
    43bf:	mov    rdi,QWORD PTR [rsp+0x78]
    43c4:	mov    QWORD PTR [rdi],r12
    43c7:	mov    rbx,QWORD PTR [rsp+0x90]
    43cf:	mov    r12,QWORD PTR [rsp+0x98]
    43d7:	mov    r13,QWORD PTR [rsp+0xa0]
    43df:	mov    r14,QWORD PTR [rsp+0xa8]
    43e7:	mov    r15,QWORD PTR [rsp+0xb0]
    43ef:	add    rsp,0xc0
    43f6:	mov    rsp,rbp
    43f9:	pop    rbp
    43fa:	ret
    43fb:	mov    QWORD PTR [rsp+0x78],rdi
    4400:	call   4405 <botlish_fn_20+0x46d>
			4401: R_X86_64_PLT32	rt_stack_overflow-0x4
    4405:	xor    rax,rax
    4408:	mov    rbx,QWORD PTR [rsp+0x90]
    4410:	mov    r12,QWORD PTR [rsp+0x98]
    4418:	mov    r13,QWORD PTR [rsp+0xa0]
    4420:	mov    r14,QWORD PTR [rsp+0xa8]
    4428:	mov    r15,QWORD PTR [rsp+0xb0]
    4430:	add    rsp,0xc0
    4437:	mov    rsp,rbp
    443a:	pop    rbp
    443b:	ret
    443c:	add    BYTE PTR [rax],al
    443e:	add    BYTE PTR [rax],al
    4440:	(bad)
    4441:	add    BYTE PTR [rax],al
    4443:	add    BYTE PTR [rax],al
    4445:	add    BYTE PTR [rax],al
	...

0000000000004448 <botlish_entry_20: <str>>:
    4448:	push   rbp
    4449:	mov    rbp,rsp
    444c:	mov    rsi,QWORD PTR [rdx]
    444f:	call   4454 <botlish_entry_20+0xc>
			4450: R_X86_64_PLT32	botlish_fn_20-0x4 ; <str>
    4454:	mov    rsp,rbp
    4457:	pop    rbp
    4458:	ret
    4459:	add    BYTE PTR [rax],al
    445b:	add    BYTE PTR [rax],al
    445d:	add    BYTE PTR [rax],al
	...

0000000000004460 <botlish_fn_21: <generic>>:
    4460:	push   rbp
    4461:	mov    rbp,rsp
    4464:	sub    rsp,0xc0
    446b:	mov    QWORD PTR [rsp+0x90],rbx
    4473:	mov    QWORD PTR [rsp+0x98],r12
    447b:	mov    QWORD PTR [rsp+0xa0],r13
    4483:	mov    QWORD PTR [rsp+0xa8],r14
    448b:	mov    QWORD PTR [rsp+0xb0],r15
    4493:	mov    r12,QWORD PTR [rdi]
    4496:	mov    rax,QWORD PTR [rdi+0x8]
    449a:	lea    rcx,[r12+0x28]
    449f:	cmp    rcx,rax
    44a2:	ja     4902 <botlish_fn_21+0x4a2>
    44a8:	lea    rax,[r12+0x28]
    44ad:	mov    QWORD PTR [rdi],rax
    44b0:	mov    QWORD PTR [r12],0x0
    44b8:	mov    QWORD PTR [r12+0x8],0x0
    44c1:	mov    QWORD PTR [r12+0x10],0x0
    44ca:	mov    QWORD PTR [r12+0x18],0x0
    44d3:	mov    QWORD PTR [r12+0x20],0x0
    44dc:	mov    QWORD PTR [r12],rsi
    44e0:	xor    eax,eax
    44e2:	test   rsi,0x7
    44e9:	jne    44f8 <botlish_fn_21+0x98>
    44ef:	movzx  rax,BYTE PTR [rsi]
    44f3:	cmp    al,0x2
    44f5:	sete   al
    44f8:	test   al,al
    44fa:	jne    4524 <botlish_fn_21+0xc4>
    4500:	mov    rax,QWORD PTR [rdi+0x10]
    4504:	mov    QWORD PTR [rsp+0x78],rdi
    4509:	mov    rcx,QWORD PTR [rax+0xd8]
    4510:	mov    edx,0x1
    4515:	call   451a <botlish_fn_21+0xba>
			4516: R_X86_64_PLT32	rt_type_error-0x4
    451a:	mov    rdi,QWORD PTR [rsp+0x78]
    451f:	jmp    4818 <botlish_fn_21+0x3b8>
    4524:	mov    r13,rsi
    4527:	mov    QWORD PTR [rsp+0x78],rdi
    452c:	call   4531 <botlish_fn_21+0xd1>
			452d: R_X86_64_PLT32	rt_str_len-0x4
    4531:	mov    rbx,rax
    4534:	mov    QWORD PTR [r12+0x8],rbx
    4539:	lea    r8,[rsp]
    453d:	mov    QWORD PTR [rsp],r13
    4541:	mov    esi,0x16
    4546:	mov    rdx,QWORD PTR [rip+0x0]        # 454d <botlish_fn_21+0xed>
			4549: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; char_at<generic>
    454d:	mov    r13d,0x1
    4553:	mov    rcx,r13
    4556:	mov    rdi,QWORD PTR [rsp+0x78]
    455b:	call   4560 <botlish_fn_21+0x100>
			455c: R_X86_64_PLT32	rt_closure_new-0x4
    4560:	mov    r15,rax
    4563:	mov    QWORD PTR [rsp+0x88],r13
    456b:	mov    QWORD PTR [r12],rax
    456f:	lea    r8,[rsp+0x8]
    4574:	mov    QWORD PTR [rsp+0x8],rbx
    4579:	mov    QWORD PTR [rsp+0x10],rax
    457e:	mov    esi,0x1a
    4583:	mov    rdx,QWORD PTR [rip+0x0]        # 458a <botlish_fn_21+0x12a>
			4586: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; scan_local<generic>
    458a:	mov    r14d,0x2
    4590:	mov    rcx,r14
    4593:	mov    rdi,QWORD PTR [rsp+0x78]
    4598:	call   459d <botlish_fn_21+0x13d>
			4599: R_X86_64_PLT32	rt_closure_new-0x4
    459d:	mov    r13,rax
    45a0:	mov    QWORD PTR [r12+0x10],r13
    45a5:	lea    r8,[rsp+0x18]
    45aa:	mov    QWORD PTR [rsp+0x18],rbx
    45af:	mov    rax,r15
    45b2:	mov    QWORD PTR [rsp+0x20],rax
    45b7:	mov    esi,0x1b
    45bc:	mov    rdx,QWORD PTR [rip+0x0]        # 45c3 <botlish_fn_21+0x163>
			45bf: R_X86_64_GOTPCREL	botlish_entry_27-0x4 ; scan_label<generic>
    45c3:	mov    rcx,r14
    45c6:	mov    rdi,QWORD PTR [rsp+0x78]
    45cb:	call   45d0 <botlish_fn_21+0x170>
			45cc: R_X86_64_PLT32	rt_closure_new-0x4
    45d0:	mov    QWORD PTR [r12+0x18],rax
    45d5:	mov    QWORD PTR [rsp+0x80],rax
    45dd:	lea    r8,[rsp+0x28]
    45e2:	mov    QWORD PTR [rsp+0x28],rbx
    45e7:	mov    QWORD PTR [rsp+0x30],r15
    45ec:	mov    esi,0x1c
    45f1:	mov    rdx,QWORD PTR [rip+0x0]        # 45f8 <botlish_fn_21+0x198>
			45f4: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; scan_alpha<generic>
    45f8:	mov    rcx,r14
    45fb:	mov    rdi,QWORD PTR [rsp+0x78]
    4600:	call   4605 <botlish_fn_21+0x1a5>
			4601: R_X86_64_PLT32	rt_closure_new-0x4
    4605:	mov    QWORD PTR [r12+0x20],rax
    460a:	lea    r8,[rsp+0x38]
    460f:	mov    QWORD PTR [rsp+0x38],rax
    4614:	mov    QWORD PTR [rsp+0x40],rbx
    4619:	mov    esi,0x1d
    461e:	mov    rdx,QWORD PTR [rip+0x0]        # 4625 <botlish_fn_21+0x1c5>
			4621: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; tld_ok<generic>
    4625:	mov    rcx,r14
    4628:	mov    rdi,QWORD PTR [rsp+0x78]
    462d:	call   4632 <botlish_fn_21+0x1d2>
			462e: R_X86_64_PLT32	rt_closure_new-0x4
    4632:	mov    QWORD PTR [r12+0x20],rax
    4637:	lea    r8,[rsp+0x48]
    463c:	mov    rcx,QWORD PTR [rsp+0x80]
    4644:	mov    QWORD PTR [rsp+0x48],rcx
    4649:	mov    QWORD PTR [rsp+0x50],rbx
    464e:	mov    QWORD PTR [rsp+0x58],r15
    4653:	mov    QWORD PTR [rsp+0x60],rax
    4658:	mov    esi,0x1e
    465d:	mov    rdx,QWORD PTR [rip+0x0]        # 4664 <botlish_fn_21+0x204>
			4660: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; domain_loop<generic>
    4664:	mov    ecx,0x4
    4669:	mov    rdi,QWORD PTR [rsp+0x78]
    466e:	call   4673 <botlish_fn_21+0x213>
			466f: R_X86_64_PLT32	rt_closure_new-0x4
    4673:	mov    QWORD PTR [r12+0x18],rax
    4678:	mov    r14,rax
    467b:	mov    QWORD PTR [r12+0x20],0x1
    4684:	mov    rsi,r13
    4687:	mov    rdx,QWORD PTR [rsp+0x88]
    468f:	mov    rdi,QWORD PTR [rsp+0x78]
    4694:	call   4699 <botlish_fn_21+0x239>
			4695: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    4699:	mov    rcx,rax
    469c:	mov    r13,rax
    469f:	test   rax,rcx
    46a2:	jne    46b2 <botlish_fn_21+0x252>
    46a8:	mov    rdi,QWORD PTR [rsp+0x78]
    46ad:	jmp    4818 <botlish_fn_21+0x3b8>
    46b2:	mov    rax,r13
    46b5:	mov    QWORD PTR [r12+0x10],rax
    46ba:	test   rax,0x1
    46c0:	jne    46f0 <botlish_fn_21+0x290>
    46c6:	mov    rdx,QWORD PTR [rsp+0x88]
    46ce:	mov    rsi,r13
    46d1:	mov    rdi,QWORD PTR [rsp+0x78]
    46d6:	call   46db <botlish_fn_21+0x27b>
			46d7: R_X86_64_PLT32	rt_int_cmp-0x4
    46db:	mov    ecx,0x2
    46e0:	test   rax,rax
    46e3:	cmove  rcx,QWORD PTR [rip+0x25d]        # 4948 <botlish_fn_21+0x4e8>
    46eb:	jmp    4701 <botlish_fn_21+0x2a1>
    46f0:	mov    ecx,0x2
    46f5:	cmp    r13,0x1
    46f9:	cmove  rcx,QWORD PTR [rip+0x247]        # 4948 <botlish_fn_21+0x4e8>
    4701:	cmp    rcx,0x6
    4705:	je     48bc <botlish_fn_21+0x45c>
    470b:	mov    rax,r13
    470e:	and    rax,rbx
    4711:	test   rax,0x1
    4717:	jne    4742 <botlish_fn_21+0x2e2>
    471d:	mov    rdx,rbx
    4720:	mov    rsi,r13
    4723:	mov    rdi,QWORD PTR [rsp+0x78]
    4728:	call   472d <botlish_fn_21+0x2cd>
			4729: R_X86_64_PLT32	rt_int_cmp-0x4
    472d:	mov    ecx,0x2
    4732:	test   rax,rax
    4735:	cmovge rcx,QWORD PTR [rip+0x20b]        # 4948 <botlish_fn_21+0x4e8>
    473d:	jmp    4752 <botlish_fn_21+0x2f2>
    4742:	mov    ecx,0x2
    4747:	cmp    r13,rbx
    474a:	cmovge rcx,QWORD PTR [rip+0x1f6]        # 4948 <botlish_fn_21+0x4e8>
    4752:	cmp    rcx,0x6
    4756:	je     48ad <botlish_fn_21+0x44d>
    475c:	lea    rcx,[rsp+0x68]
    4761:	mov    rsi,r15
    4764:	mov    rdx,r13
    4767:	mov    rdi,QWORD PTR [rsp+0x78]
    476c:	call   4771 <botlish_fn_21+0x311>
			476d: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    4771:	test   rax,rax
    4774:	mov    rsi,rax
    4777:	jne    4787 <botlish_fn_21+0x327>
    477d:	mov    rdi,QWORD PTR [rsp+0x78]
    4782:	jmp    4818 <botlish_fn_21+0x3b8>
    4787:	mov    rdx,QWORD PTR [rsp+0x68]
    478c:	mov    rcx,QWORD PTR [rsp+0x70]
    4791:	mov    rdi,QWORD PTR [rsp+0x78]
    4796:	mov    rax,QWORD PTR [rdi+0x10]
    479a:	mov    r8,QWORD PTR [rax+0x100]
    47a1:	call   47a6 <botlish_fn_21+0x346>
			47a2: R_X86_64_PLT32	rt_str_region_eq-0x4
    47a6:	cmp    rax,0x6
    47aa:	je     47bd <botlish_fn_21+0x35d>
    47b0:	mov    edi,0x2
    47b5:	mov    rax,rdi
    47b8:	jmp    48b2 <botlish_fn_21+0x452>
    47bd:	mov    QWORD PTR [r12],0x3
    47c5:	test   r13,0x1
    47cc:	je     47e4 <botlish_fn_21+0x384>
    47d2:	mov    rdx,r13
    47d5:	add    rdx,0x2
    47d9:	seto   al
    47dc:	test   al,al
    47de:	je     47f9 <botlish_fn_21+0x399>
    47e4:	mov    edx,0x3
    47e9:	mov    rsi,r13
    47ec:	mov    rdi,QWORD PTR [rsp+0x78]
    47f1:	call   47f6 <botlish_fn_21+0x396>
			47f2: R_X86_64_PLT32	rt_int_add-0x4
    47f6:	mov    rdx,rax
    47f9:	mov    QWORD PTR [r12],rdx
    47fd:	mov    rsi,r14
    4800:	mov    rdi,QWORD PTR [rsp+0x78]
    4805:	call   480a <botlish_fn_21+0x3aa>
			4806: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    480a:	test   rax,rax
    480d:	jne    4857 <botlish_fn_21+0x3f7>
    4813:	mov    rdi,QWORD PTR [rsp+0x78]
    4818:	mov    rdi,QWORD PTR [rsp+0x78]
    481d:	mov    QWORD PTR [rdi],r12
    4820:	xor    rax,rax
    4823:	mov    rbx,QWORD PTR [rsp+0x90]
    482b:	mov    r12,QWORD PTR [rsp+0x98]
    4833:	mov    r13,QWORD PTR [rsp+0xa0]
    483b:	mov    r14,QWORD PTR [rsp+0xa8]
    4843:	mov    r15,QWORD PTR [rsp+0xb0]
    484b:	add    rsp,0xc0
    4852:	mov    rsp,rbp
    4855:	pop    rbp
    4856:	ret
    4857:	mov    rcx,rax
    485a:	and    rcx,rbx
    485d:	mov    rsi,rax
    4860:	mov    rax,rbx
    4863:	test   rcx,0x1
    486a:	jne    4895 <botlish_fn_21+0x435>
    4870:	mov    rdx,rax
    4873:	mov    rdi,QWORD PTR [rsp+0x78]
    4878:	call   487d <botlish_fn_21+0x41d>
			4879: R_X86_64_PLT32	rt_int_cmp-0x4
    487d:	mov    edi,0x2
    4882:	test   rax,rax
    4885:	mov    rax,rdi
    4888:	cmove  rax,QWORD PTR [rip+0xb8]        # 4948 <botlish_fn_21+0x4e8>
    4890:	jmp    48b2 <botlish_fn_21+0x452>
    4895:	mov    rdx,rax
    4898:	mov    eax,0x2
    489d:	cmp    rsi,rdx
    48a0:	cmove  rax,QWORD PTR [rip+0xa0]        # 4948 <botlish_fn_21+0x4e8>
    48a8:	jmp    48b2 <botlish_fn_21+0x452>
    48ad:	mov    eax,0x2
    48b2:	mov    rdi,QWORD PTR [rsp+0x78]
    48b7:	jmp    48c6 <botlish_fn_21+0x466>
    48bc:	mov    eax,0x2
    48c1:	mov    rdi,QWORD PTR [rsp+0x78]
    48c6:	mov    rdi,QWORD PTR [rsp+0x78]
    48cb:	mov    QWORD PTR [rdi],r12
    48ce:	mov    rbx,QWORD PTR [rsp+0x90]
    48d6:	mov    r12,QWORD PTR [rsp+0x98]
    48de:	mov    r13,QWORD PTR [rsp+0xa0]
    48e6:	mov    r14,QWORD PTR [rsp+0xa8]
    48ee:	mov    r15,QWORD PTR [rsp+0xb0]
    48f6:	add    rsp,0xc0
    48fd:	mov    rsp,rbp
    4900:	pop    rbp
    4901:	ret
    4902:	mov    QWORD PTR [rsp+0x78],rdi
    4907:	call   490c <botlish_fn_21+0x4ac>
			4908: R_X86_64_PLT32	rt_stack_overflow-0x4
    490c:	xor    rax,rax
    490f:	mov    rbx,QWORD PTR [rsp+0x90]
    4917:	mov    r12,QWORD PTR [rsp+0x98]
    491f:	mov    r13,QWORD PTR [rsp+0xa0]
    4927:	mov    r14,QWORD PTR [rsp+0xa8]
    492f:	mov    r15,QWORD PTR [rsp+0xb0]
    4937:	add    rsp,0xc0
    493e:	mov    rsp,rbp
    4941:	pop    rbp
    4942:	ret
    4943:	add    BYTE PTR [rax],al
    4945:	add    BYTE PTR [rax],al
    4947:	add    BYTE PTR [rsi],al
    4949:	add    BYTE PTR [rax],al
    494b:	add    BYTE PTR [rax],al
    494d:	add    BYTE PTR [rax],al
	...

0000000000004950 <botlish_entry_21: <generic>>:
    4950:	push   rbp
    4951:	mov    rbp,rsp
    4954:	mov    rsi,QWORD PTR [rdx]
    4957:	call   495c <botlish_entry_21+0xc>
			4958: R_X86_64_PLT32	botlish_fn_21-0x4 ; <generic>
    495c:	mov    rsp,rbp
    495f:	pop    rbp
    4960:	ret

0000000000004961 <botlish_fn_22: char_at<generic>>:
    4961:	push   rbp
    4962:	mov    rbp,rsp
    4965:	sub    rsp,0x20
    4969:	mov    QWORD PTR [rsp],rbx
    496d:	mov    QWORD PTR [rsp+0x8],r12
    4972:	mov    QWORD PTR [rsp+0x10],r13
    4977:	mov    QWORD PTR [rsp+0x18],r14
    497c:	mov    rbx,QWORD PTR [rdi]
    497f:	mov    rax,QWORD PTR [rdi+0x8]
    4983:	lea    rcx,[rbx+0x18]
    4987:	cmp    rcx,rax
    498a:	ja     4b2b <botlish_fn_22+0x1ca>
    4990:	lea    rax,[rbx+0x18]
    4994:	mov    QWORD PTR [rdi],rax
    4997:	mov    QWORD PTR [rbx],0x0
    499e:	mov    QWORD PTR [rbx+0x8],0x0
    49a6:	mov    QWORD PTR [rbx+0x10],0x0
    49ae:	mov    QWORD PTR [rbx],rdx
    49b1:	mov    rax,QWORD PTR [rsi+0x20]
    49b5:	mov    rsi,QWORD PTR [rax]
    49b8:	mov    QWORD PTR [rbx+0x8],rsi
    49bc:	mov    r14,rsi
    49bf:	mov    QWORD PTR [rbx+0x10],0x3
    49c7:	mov    ecx,0x1
    49cc:	test   rdx,0x1
    49d3:	je     49e1 <botlish_fn_22+0x80>
    49d9:	mov    r13,rdx
    49dc:	jmp    4a04 <botlish_fn_22+0xa3>
    49e1:	xor    ecx,ecx
    49e3:	test   rdx,0x7
    49ea:	je     49f8 <botlish_fn_22+0x97>
    49f0:	mov    r13,rdx
    49f3:	jmp    4a04 <botlish_fn_22+0xa3>
    49f8:	movzx  rax,BYTE PTR [rdx]
    49fc:	mov    r13,rdx
    49ff:	cmp    al,0x1
    4a01:	sete   cl
    4a04:	test   cl,cl
    4a06:	jne    4a2d <botlish_fn_22+0xcc>
    4a0c:	mov    rax,QWORD PTR [rdi+0x10]
    4a10:	mov    r12,rdi
    4a13:	mov    rcx,QWORD PTR [rax+0x108]
    4a1a:	xor    rdx,rdx
    4a1d:	mov    rsi,r13
    4a20:	call   4a25 <botlish_fn_22+0xc4>
			4a21: R_X86_64_PLT32	rt_type_error-0x4
    4a25:	mov    rdi,r12
    4a28:	jmp    4ae4 <botlish_fn_22+0x183>
    4a2d:	mov    rsi,r13
    4a30:	mov    r12,rdi
    4a33:	test   rsi,0x1
    4a3a:	je     4a57 <botlish_fn_22+0xf6>
    4a40:	mov    rsi,r13
    4a43:	mov    rcx,rsi
    4a46:	add    rcx,0x2
    4a4a:	seto   sil
    4a4e:	test   sil,sil
    4a51:	je     4a6a <botlish_fn_22+0x109>
    4a57:	mov    edx,0x3
    4a5c:	mov    rsi,r13
    4a5f:	mov    rdi,r12
    4a62:	call   4a67 <botlish_fn_22+0x106>
			4a63: R_X86_64_PLT32	rt_int_add-0x4
    4a67:	mov    rcx,rax
    4a6a:	mov    QWORD PTR [rbx+0x10],rcx
    4a6e:	mov    edx,0x1
    4a73:	mov    rsi,r13
    4a76:	test   rsi,0x1
    4a7d:	jne    4aa1 <botlish_fn_22+0x140>
    4a83:	xor    edx,edx
    4a85:	mov    rsi,r13
    4a88:	test   rsi,0x7
    4a8f:	jne    4aa1 <botlish_fn_22+0x140>
    4a95:	mov    rsi,r13
    4a98:	movzx  rax,BYTE PTR [rsi]
    4a9c:	cmp    al,0x1
    4a9e:	sete   dl
    4aa1:	test   dl,dl
    4aa3:	jne    4aca <botlish_fn_22+0x169>
    4aa9:	mov    rdi,r12
    4aac:	mov    rax,QWORD PTR [rdi+0x10]
    4ab0:	mov    rcx,QWORD PTR [rax+0x110]
    4ab7:	xor    rdx,rdx
    4aba:	mov    rsi,r13
    4abd:	call   4ac2 <botlish_fn_22+0x161>
			4abe: R_X86_64_PLT32	rt_type_error-0x4
    4ac2:	mov    rdi,r12
    4ac5:	jmp    4ae4 <botlish_fn_22+0x183>
    4aca:	mov    rdx,r13
    4acd:	mov    rsi,r14
    4ad0:	mov    rdi,r12
    4ad3:	call   4ad8 <botlish_fn_22+0x177>
			4ad4: R_X86_64_PLT32	rt_substr-0x4
    4ad8:	test   rax,rax
    4adb:	jne    4b09 <botlish_fn_22+0x1a8>
    4ae1:	mov    rdi,r12
    4ae4:	mov    rdi,r12
    4ae7:	mov    QWORD PTR [rdi],rbx
    4aea:	xor    rax,rax
    4aed:	mov    rbx,QWORD PTR [rsp]
    4af1:	mov    r12,QWORD PTR [rsp+0x8]
    4af6:	mov    r13,QWORD PTR [rsp+0x10]
    4afb:	mov    r14,QWORD PTR [rsp+0x18]
    4b00:	add    rsp,0x20
    4b04:	mov    rsp,rbp
    4b07:	pop    rbp
    4b08:	ret
    4b09:	mov    rdi,r12
    4b0c:	mov    QWORD PTR [rdi],rbx
    4b0f:	mov    rbx,QWORD PTR [rsp]
    4b13:	mov    r12,QWORD PTR [rsp+0x8]
    4b18:	mov    r13,QWORD PTR [rsp+0x10]
    4b1d:	mov    r14,QWORD PTR [rsp+0x18]
    4b22:	add    rsp,0x20
    4b26:	mov    rsp,rbp
    4b29:	pop    rbp
    4b2a:	ret
    4b2b:	mov    r12,rdi
    4b2e:	call   4b33 <botlish_fn_22+0x1d2>
			4b2f: R_X86_64_PLT32	rt_stack_overflow-0x4
    4b33:	xor    rax,rax
    4b36:	mov    rbx,QWORD PTR [rsp]
    4b3a:	mov    r12,QWORD PTR [rsp+0x8]
    4b3f:	mov    r13,QWORD PTR [rsp+0x10]
    4b44:	mov    r14,QWORD PTR [rsp+0x18]
    4b49:	add    rsp,0x20
    4b4d:	mov    rsp,rbp
    4b50:	pop    rbp
    4b51:	ret

0000000000004b52 <botlish_entry_22: char_at<generic>>:
    4b52:	push   rbp
    4b53:	mov    rbp,rsp
    4b56:	mov    rdx,QWORD PTR [rdx]
    4b59:	call   4b5e <botlish_entry_22+0xc>
			4b5a: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    4b5e:	mov    rsp,rbp
    4b61:	pop    rbp
    4b62:	ret

0000000000004b63 <botlish_fn_23: char_at<generic>>:
    4b63:	push   rbp
    4b64:	mov    rbp,rsp
    4b67:	sub    rsp,0x40
    4b6b:	mov    QWORD PTR [rsp+0x10],rbx
    4b70:	mov    QWORD PTR [rsp+0x18],r12
    4b75:	mov    QWORD PTR [rsp+0x20],r13
    4b7a:	mov    QWORD PTR [rsp+0x28],r14
    4b7f:	mov    QWORD PTR [rsp+0x30],r15
    4b84:	mov    r15,rcx
    4b87:	mov    rbx,QWORD PTR [rdi]
    4b8a:	mov    rax,QWORD PTR [rdi+0x8]
    4b8e:	lea    rcx,[rbx+0x18]
    4b92:	cmp    rcx,rax
    4b95:	ja     4d64 <botlish_fn_23+0x201>
    4b9b:	lea    rax,[rbx+0x18]
    4b9f:	mov    QWORD PTR [rdi],rax
    4ba2:	mov    QWORD PTR [rbx],0x0
    4ba9:	mov    QWORD PTR [rbx+0x8],0x0
    4bb1:	mov    QWORD PTR [rbx+0x10],0x0
    4bb9:	mov    QWORD PTR [rbx],rdx
    4bbc:	mov    rax,QWORD PTR [rsi+0x20]
    4bc0:	mov    rax,QWORD PTR [rax]
    4bc3:	mov    QWORD PTR [rbx+0x8],rax
    4bc7:	mov    QWORD PTR [rsp],rax
    4bcb:	mov    QWORD PTR [rbx+0x10],0x3
    4bd3:	mov    eax,0x1
    4bd8:	test   rdx,0x1
    4bdf:	je     4bed <botlish_fn_23+0x8a>
    4be5:	mov    r14,rdx
    4be8:	jmp    4c10 <botlish_fn_23+0xad>
    4bed:	xor    eax,eax
    4bef:	test   rdx,0x7
    4bf6:	je     4c04 <botlish_fn_23+0xa1>
    4bfc:	mov    r14,rdx
    4bff:	jmp    4c10 <botlish_fn_23+0xad>
    4c04:	movzx  rax,BYTE PTR [rdx]
    4c08:	mov    r14,rdx
    4c0b:	cmp    al,0x1
    4c0d:	sete   al
    4c10:	test   al,al
    4c12:	jne    4c39 <botlish_fn_23+0xd6>
    4c18:	mov    rax,QWORD PTR [rdi+0x10]
    4c1c:	mov    r13,rdi
    4c1f:	mov    rcx,QWORD PTR [rax+0x108]
    4c26:	xor    rdx,rdx
    4c29:	mov    rsi,r14
    4c2c:	call   4c31 <botlish_fn_23+0xce>
			4c2d: R_X86_64_PLT32	rt_type_error-0x4
    4c31:	mov    rdi,r13
    4c34:	jmp    4d00 <botlish_fn_23+0x19d>
    4c39:	mov    rsi,r14
    4c3c:	mov    r13,rdi
    4c3f:	test   rsi,0x1
    4c46:	jne    4c54 <botlish_fn_23+0xf1>
    4c4c:	mov    r14,rsi
    4c4f:	jmp    4c73 <botlish_fn_23+0x110>
    4c54:	mov    rax,rsi
    4c57:	add    rax,0x2
    4c5b:	mov    r14,rsi
    4c5e:	seto   sil
    4c62:	test   sil,sil
    4c65:	jne    4c73 <botlish_fn_23+0x110>
    4c6b:	mov    r12,rax
    4c6e:	jmp    4c86 <botlish_fn_23+0x123>
    4c73:	mov    edx,0x3
    4c78:	mov    rsi,r14
    4c7b:	mov    rdi,r13
    4c7e:	call   4c83 <botlish_fn_23+0x120>
			4c7f: R_X86_64_PLT32	rt_int_add-0x4
    4c83:	mov    r12,rax
    4c86:	mov    ecx,0x1
    4c8b:	mov    rsi,r14
    4c8e:	test   rsi,0x1
    4c95:	jne    4cb9 <botlish_fn_23+0x156>
    4c9b:	xor    ecx,ecx
    4c9d:	mov    rsi,r14
    4ca0:	test   rsi,0x7
    4ca7:	jne    4cb9 <botlish_fn_23+0x156>
    4cad:	mov    rsi,r14
    4cb0:	movzx  rax,BYTE PTR [rsi]
    4cb4:	cmp    al,0x1
    4cb6:	sete   cl
    4cb9:	test   cl,cl
    4cbb:	jne    4ce2 <botlish_fn_23+0x17f>
    4cc1:	mov    rdi,r13
    4cc4:	mov    rax,QWORD PTR [rdi+0x10]
    4cc8:	mov    rcx,QWORD PTR [rax+0x110]
    4ccf:	xor    rdx,rdx
    4cd2:	mov    rsi,r14
    4cd5:	call   4cda <botlish_fn_23+0x177>
			4cd6: R_X86_64_PLT32	rt_type_error-0x4
    4cda:	mov    rdi,r13
    4cdd:	jmp    4d00 <botlish_fn_23+0x19d>
    4ce2:	mov    rcx,r12
    4ce5:	mov    rdx,r14
    4ce8:	mov    rsi,QWORD PTR [rsp]
    4cec:	mov    rdi,r13
    4cef:	call   4cf4 <botlish_fn_23+0x191>
			4cf0: R_X86_64_PLT32	rt_str_region_check-0x4
    4cf4:	test   rax,rax
    4cf7:	jne    4d2b <botlish_fn_23+0x1c8>
    4cfd:	mov    rdi,r13
    4d00:	mov    rdi,r13
    4d03:	mov    QWORD PTR [rdi],rbx
    4d06:	xor    rax,rax
    4d09:	mov    rbx,QWORD PTR [rsp+0x10]
    4d0e:	mov    r12,QWORD PTR [rsp+0x18]
    4d13:	mov    r13,QWORD PTR [rsp+0x20]
    4d18:	mov    r14,QWORD PTR [rsp+0x28]
    4d1d:	mov    r15,QWORD PTR [rsp+0x30]
    4d22:	add    rsp,0x40
    4d26:	mov    rsp,rbp
    4d29:	pop    rbp
    4d2a:	ret
    4d2b:	mov    rdi,r13
    4d2e:	mov    QWORD PTR [rdi],rbx
    4d31:	mov    rcx,r15
    4d34:	mov    rsi,r14
    4d37:	mov    QWORD PTR [rcx],rsi
    4d3a:	mov    QWORD PTR [rcx+0x8],r12
    4d3e:	mov    rax,QWORD PTR [rsp]
    4d42:	mov    rbx,QWORD PTR [rsp+0x10]
    4d47:	mov    r12,QWORD PTR [rsp+0x18]
    4d4c:	mov    r13,QWORD PTR [rsp+0x20]
    4d51:	mov    r14,QWORD PTR [rsp+0x28]
    4d56:	mov    r15,QWORD PTR [rsp+0x30]
    4d5b:	add    rsp,0x40
    4d5f:	mov    rsp,rbp
    4d62:	pop    rbp
    4d63:	ret
    4d64:	mov    r13,rdi
    4d67:	call   4d6c <botlish_fn_23+0x209>
			4d68: R_X86_64_PLT32	rt_stack_overflow-0x4
    4d6c:	xor    rax,rax
    4d6f:	mov    rbx,QWORD PTR [rsp+0x10]
    4d74:	mov    r12,QWORD PTR [rsp+0x18]
    4d79:	mov    r13,QWORD PTR [rsp+0x20]
    4d7e:	mov    r14,QWORD PTR [rsp+0x28]
    4d83:	mov    r15,QWORD PTR [rsp+0x30]
    4d88:	add    rsp,0x40
    4d8c:	mov    rsp,rbp
    4d8f:	pop    rbp
    4d90:	ret

0000000000004d91 <botlish_entry_23: char_at<generic>>:
    4d91:	push   rbp
    4d92:	mov    rbp,rsp
    4d95:	ud2

0000000000004d97 <botlish_fn_24: is_local_char<str>>:
    4d97:	push   rbp
    4d98:	mov    rbp,rsp
    4d9b:	sub    rsp,0x20
    4d9f:	mov    QWORD PTR [rsp],rbx
    4da3:	mov    QWORD PTR [rsp+0x8],r12
    4da8:	mov    QWORD PTR [rsp+0x10],r13
    4dad:	mov    r13,rsi
    4db0:	mov    rbx,QWORD PTR [rdi]
    4db3:	mov    rax,QWORD PTR [rdi+0x8]
    4db7:	lea    rcx,[rbx+0x8]
    4dbb:	cmp    rcx,rax
    4dbe:	ja     4f30 <botlish_fn_24+0x199>
    4dc4:	lea    rax,[rbx+0x8]
    4dc8:	mov    QWORD PTR [rdi],rax
    4dcb:	mov    r12,rdi
    4dce:	mov    QWORD PTR [rbx],0x0
    4dd5:	mov    rsi,r13
    4dd8:	mov    rdi,r12
    4ddb:	call   4de0 <botlish_fn_24+0x49>
			4ddc: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    4de0:	test   rax,rax
    4de3:	jne    4e09 <botlish_fn_24+0x72>
    4de9:	mov    rdi,r12
    4dec:	mov    QWORD PTR [rdi],rbx
    4def:	xor    rax,rax
    4df2:	mov    rbx,QWORD PTR [rsp]
    4df6:	mov    r12,QWORD PTR [rsp+0x8]
    4dfb:	mov    r13,QWORD PTR [rsp+0x10]
    4e00:	add    rsp,0x20
    4e04:	mov    rsp,rbp
    4e07:	pop    rbp
    4e08:	ret
    4e09:	cmp    rax,0x6
    4e0d:	je     4f0b <botlish_fn_24+0x174>
    4e13:	mov    rdi,r12
    4e16:	mov    rax,QWORD PTR [rdi+0x10]
    4e1a:	mov    rsi,QWORD PTR [rax+0x118]
    4e21:	mov    edx,0x1
    4e26:	mov    ecx,0x3
    4e2b:	mov    r8,r13
    4e2e:	call   4e33 <botlish_fn_24+0x9c>
			4e2f: R_X86_64_PLT32	rt_str_region_eq-0x4
    4e33:	cmp    rax,0x6
    4e37:	je     4efe <botlish_fn_24+0x167>
    4e3d:	mov    rdi,r12
    4e40:	mov    rax,QWORD PTR [rdi+0x10]
    4e44:	mov    rsi,QWORD PTR [rax+0x120]
    4e4b:	mov    edx,0x1
    4e50:	mov    ecx,0x3
    4e55:	mov    r8,r13
    4e58:	call   4e5d <botlish_fn_24+0xc6>
			4e59: R_X86_64_PLT32	rt_str_region_eq-0x4
    4e5d:	cmp    rax,0x6
    4e61:	je     4ef4 <botlish_fn_24+0x15d>
    4e67:	mov    rdi,r12
    4e6a:	mov    rax,QWORD PTR [rdi+0x10]
    4e6e:	mov    rsi,QWORD PTR [rax+0xc0]
    4e75:	mov    edx,0x1
    4e7a:	mov    ecx,0x3
    4e7f:	mov    r8,r13
    4e82:	call   4e87 <botlish_fn_24+0xf0>
			4e83: R_X86_64_PLT32	rt_str_region_eq-0x4
    4e87:	cmp    rax,0x6
    4e8b:	je     4eea <botlish_fn_24+0x153>
    4e91:	mov    rdi,r12
    4e94:	mov    rcx,QWORD PTR [rdi+0x10]
    4e98:	mov    rsi,QWORD PTR [rcx+0x108]
    4e9f:	mov    edx,0x1
    4ea4:	mov    ecx,0x3
    4ea9:	mov    r8,r13
    4eac:	call   4eb1 <botlish_fn_24+0x11a>
			4ead: R_X86_64_PLT32	rt_str_region_eq-0x4
    4eb1:	cmp    rax,0x6
    4eb5:	je     4ee0 <botlish_fn_24+0x149>
    4ebb:	mov    rdi,r12
    4ebe:	mov    rsi,QWORD PTR [rdi+0x10]
    4ec2:	mov    rsi,QWORD PTR [rsi+0x128]
    4ec9:	mov    edx,0x1
    4ece:	mov    ecx,0x3
    4ed3:	mov    r8,r13
    4ed6:	call   4edb <botlish_fn_24+0x144>
			4ed7: R_X86_64_PLT32	rt_str_region_eq-0x4
    4edb:	jmp    4f03 <botlish_fn_24+0x16c>
    4ee0:	mov    eax,0x6
    4ee5:	jmp    4f03 <botlish_fn_24+0x16c>
    4eea:	mov    eax,0x6
    4eef:	jmp    4f03 <botlish_fn_24+0x16c>
    4ef4:	mov    eax,0x6
    4ef9:	jmp    4f03 <botlish_fn_24+0x16c>
    4efe:	mov    eax,0x6
    4f03:	mov    rdi,r12
    4f06:	jmp    4f13 <botlish_fn_24+0x17c>
    4f0b:	mov    eax,0x6
    4f10:	mov    rdi,r12
    4f13:	mov    rdi,r12
    4f16:	mov    QWORD PTR [rdi],rbx
    4f19:	mov    rbx,QWORD PTR [rsp]
    4f1d:	mov    r12,QWORD PTR [rsp+0x8]
    4f22:	mov    r13,QWORD PTR [rsp+0x10]
    4f27:	add    rsp,0x20
    4f2b:	mov    rsp,rbp
    4f2e:	pop    rbp
    4f2f:	ret
    4f30:	mov    r12,rdi
    4f33:	call   4f38 <botlish_fn_24+0x1a1>
			4f34: R_X86_64_PLT32	rt_stack_overflow-0x4
    4f38:	xor    rax,rax
    4f3b:	mov    rbx,QWORD PTR [rsp]
    4f3f:	mov    r12,QWORD PTR [rsp+0x8]
    4f44:	mov    r13,QWORD PTR [rsp+0x10]
    4f49:	add    rsp,0x20
    4f4d:	mov    rsp,rbp
    4f50:	pop    rbp
    4f51:	ret

0000000000004f52 <botlish_entry_24: is_local_char<str>>:
    4f52:	push   rbp
    4f53:	mov    rbp,rsp
    4f56:	mov    rsi,QWORD PTR [rdx]
    4f59:	call   4f5e <botlish_entry_24+0xc>
			4f5a: R_X86_64_PLT32	botlish_fn_24-0x4 ; is_local_char<str>
    4f5e:	mov    rsp,rbp
    4f61:	pop    rbp
    4f62:	ret

0000000000004f63 <botlish_fn_25: is_label_char<str>>:
    4f63:	push   rbp
    4f64:	mov    rbp,rsp
    4f67:	sub    rsp,0x20
    4f6b:	mov    QWORD PTR [rsp],rbx
    4f6f:	mov    QWORD PTR [rsp+0x8],r12
    4f74:	mov    QWORD PTR [rsp+0x10],r13
    4f79:	mov    r13,rsi
    4f7c:	mov    rbx,QWORD PTR [rdi]
    4f7f:	mov    rax,QWORD PTR [rdi+0x8]
    4f83:	lea    rcx,[rbx+0x8]
    4f87:	cmp    rcx,rax
    4f8a:	ja     502c <botlish_fn_25+0xc9>
    4f90:	lea    rax,[rbx+0x8]
    4f94:	mov    QWORD PTR [rdi],rax
    4f97:	mov    r12,rdi
    4f9a:	mov    QWORD PTR [rbx],0x0
    4fa1:	mov    rsi,r13
    4fa4:	mov    rdi,r12
    4fa7:	call   4fac <botlish_fn_25+0x49>
			4fa8: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    4fac:	test   rax,rax
    4faf:	jne    4fd5 <botlish_fn_25+0x72>
    4fb5:	mov    rdi,r12
    4fb8:	mov    QWORD PTR [rdi],rbx
    4fbb:	xor    rax,rax
    4fbe:	mov    rbx,QWORD PTR [rsp]
    4fc2:	mov    r12,QWORD PTR [rsp+0x8]
    4fc7:	mov    r13,QWORD PTR [rsp+0x10]
    4fcc:	add    rsp,0x20
    4fd0:	mov    rsp,rbp
    4fd3:	pop    rbp
    4fd4:	ret
    4fd5:	cmp    rax,0x6
    4fd9:	je     5007 <botlish_fn_25+0xa4>
    4fdf:	mov    rdi,r12
    4fe2:	mov    rax,QWORD PTR [rdi+0x10]
    4fe6:	mov    rsi,QWORD PTR [rax+0x128]
    4fed:	mov    edx,0x1
    4ff2:	mov    ecx,0x3
    4ff7:	mov    r8,r13
    4ffa:	call   4fff <botlish_fn_25+0x9c>
			4ffb: R_X86_64_PLT32	rt_str_region_eq-0x4
    4fff:	mov    rdi,r12
    5002:	jmp    500f <botlish_fn_25+0xac>
    5007:	mov    eax,0x6
    500c:	mov    rdi,r12
    500f:	mov    rdi,r12
    5012:	mov    QWORD PTR [rdi],rbx
    5015:	mov    rbx,QWORD PTR [rsp]
    5019:	mov    r12,QWORD PTR [rsp+0x8]
    501e:	mov    r13,QWORD PTR [rsp+0x10]
    5023:	add    rsp,0x20
    5027:	mov    rsp,rbp
    502a:	pop    rbp
    502b:	ret
    502c:	mov    r12,rdi
    502f:	call   5034 <botlish_fn_25+0xd1>
			5030: R_X86_64_PLT32	rt_stack_overflow-0x4
    5034:	xor    rax,rax
    5037:	mov    rbx,QWORD PTR [rsp]
    503b:	mov    r12,QWORD PTR [rsp+0x8]
    5040:	mov    r13,QWORD PTR [rsp+0x10]
    5045:	add    rsp,0x20
    5049:	mov    rsp,rbp
    504c:	pop    rbp
    504d:	ret

000000000000504e <botlish_entry_25: is_label_char<str>>:
    504e:	push   rbp
    504f:	mov    rbp,rsp
    5052:	mov    rsi,QWORD PTR [rdx]
    5055:	call   505a <botlish_entry_25+0xc>
			5056: R_X86_64_PLT32	botlish_fn_25-0x4 ; is_label_char<str>
    505a:	mov    rsp,rbp
    505d:	pop    rbp
    505e:	ret
	...

0000000000005060 <botlish_fn_26: scan_local<generic>>:
    5060:	push   rbp
    5061:	mov    rbp,rsp
    5064:	sub    rsp,0x20
    5068:	mov    QWORD PTR [rsp],rbx
    506c:	mov    QWORD PTR [rsp+0x8],r12
    5071:	mov    QWORD PTR [rsp+0x10],r13
    5076:	mov    QWORD PTR [rsp+0x18],r14
    507b:	mov    r12,QWORD PTR [rdi]
    507e:	mov    rax,QWORD PTR [rdi+0x8]
    5082:	lea    rcx,[r12+0x18]
    5087:	cmp    rcx,rax
    508a:	ja     526f <botlish_fn_26+0x20f>
    5090:	lea    rax,[r12+0x18]
    5095:	mov    QWORD PTR [rdi],rax
    5098:	mov    r13,rdi
    509b:	mov    QWORD PTR [r12],0x0
    50a3:	mov    QWORD PTR [r12+0x8],0x0
    50ac:	mov    QWORD PTR [r12+0x10],0x0
    50b5:	mov    QWORD PTR [r12],rdx
    50b9:	mov    rbx,rsi
    50bc:	mov    rsi,rdx
    50bf:	mov    rax,QWORD PTR [rbx+0x20]
    50c3:	mov    rdx,QWORD PTR [rax]
    50c6:	mov    ecx,0x1
    50cb:	test   rsi,0x1
    50d2:	jne    50f0 <botlish_fn_26+0x90>
    50d8:	xor    ecx,ecx
    50da:	test   rsi,0x7
    50e1:	jne    50f0 <botlish_fn_26+0x90>
    50e7:	movzx  rax,BYTE PTR [rsi]
    50eb:	cmp    al,0x1
    50ed:	sete   cl
    50f0:	test   cl,cl
    50f2:	jne    5116 <botlish_fn_26+0xb6>
    50f8:	mov    rdi,r13
    50fb:	mov    rax,QWORD PTR [rdi+0x10]
    50ff:	mov    rcx,QWORD PTR [rax+0xb8]
    5106:	xor    rdx,rdx
    5109:	call   510e <botlish_fn_26+0xae>
			510a: R_X86_64_PLT32	rt_type_error-0x4
    510e:	mov    rdi,r13
    5111:	jmp    51ad <botlish_fn_26+0x14d>
    5116:	mov    rax,rsi
    5119:	and    rax,rdx
    511c:	mov    r14,rsi
    511f:	test   rax,0x1
    5125:	jne    514b <botlish_fn_26+0xeb>
    512b:	mov    rsi,r14
    512e:	mov    rdi,r13
    5131:	call   5136 <botlish_fn_26+0xd6>
			5132: R_X86_64_PLT32	rt_int_cmp-0x4
    5136:	mov    ecx,0x2
    513b:	test   rax,rax
    513e:	cmovge rcx,QWORD PTR [rip+0x152]        # 5298 <botlish_fn_26+0x238>
    5146:	jmp    515e <botlish_fn_26+0xfe>
    514b:	mov    ecx,0x2
    5150:	mov    rsi,r14
    5153:	cmp    rsi,rdx
    5156:	cmovge rcx,QWORD PTR [rip+0x13a]        # 5298 <botlish_fn_26+0x238>
    515e:	cmp    rcx,0x6
    5162:	je     5247 <botlish_fn_26+0x1e7>
    5168:	mov    rdi,QWORD PTR [rbx+0x20]
    516c:	mov    rsi,QWORD PTR [rdi+0x8]
    5170:	mov    QWORD PTR [r12+0x8],rsi
    5175:	mov    rdx,r14
    5178:	mov    rdi,r13
    517b:	call   5180 <botlish_fn_26+0x120>
			517c: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    5180:	test   rax,rax
    5183:	jne    5191 <botlish_fn_26+0x131>
    5189:	mov    rdi,r13
    518c:	jmp    51ad <botlish_fn_26+0x14d>
    5191:	mov    QWORD PTR [r12+0x8],rax
    5196:	mov    rsi,rax
    5199:	mov    rdi,r13
    519c:	call   51a1 <botlish_fn_26+0x141>
			519d: R_X86_64_PLT32	botlish_fn_24-0x4 ; is_local_char<str>
    51a1:	test   rax,rax
    51a4:	jne    51d2 <botlish_fn_26+0x172>
    51aa:	mov    rdi,r13
    51ad:	mov    rdi,r13
    51b0:	mov    QWORD PTR [rdi],r12
    51b3:	xor    rax,rax
    51b6:	mov    rbx,QWORD PTR [rsp]
    51ba:	mov    r12,QWORD PTR [rsp+0x8]
    51bf:	mov    r13,QWORD PTR [rsp+0x10]
    51c4:	mov    r14,QWORD PTR [rsp+0x18]
    51c9:	add    rsp,0x20
    51cd:	mov    rsp,rbp
    51d0:	pop    rbp
    51d1:	ret
    51d2:	cmp    rax,0x6
    51d6:	je     51e7 <botlish_fn_26+0x187>
    51dc:	mov    rax,r14
    51df:	mov    rdi,r13
    51e2:	jmp    524d <botlish_fn_26+0x1ed>
    51e7:	mov    QWORD PTR [r12+0x8],rbx
    51ec:	mov    QWORD PTR [r12+0x10],0x3
    51f5:	mov    rsi,r14
    51f8:	test   rsi,0x1
    51ff:	je     5225 <botlish_fn_26+0x1c5>
    5205:	mov    rsi,r14
    5208:	mov    rcx,rsi
    520b:	add    rcx,0x2
    520f:	seto   al
    5212:	test   al,al
    5214:	jne    5225 <botlish_fn_26+0x1c5>
    521a:	mov    rsi,rcx
    521d:	mov    r14,rcx
    5220:	jmp    523b <botlish_fn_26+0x1db>
    5225:	mov    edx,0x3
    522a:	mov    rsi,r14
    522d:	mov    rdi,r13
    5230:	call   5235 <botlish_fn_26+0x1d5>
			5231: R_X86_64_PLT32	rt_int_add-0x4
    5235:	mov    rsi,rax
    5238:	mov    r14,rax
    523b:	mov    QWORD PTR [r12],rsi
    523f:	mov    rsi,r14
    5242:	jmp    50bf <botlish_fn_26+0x5f>
    5247:	mov    rax,r14
    524a:	mov    rdi,r13
    524d:	mov    rdi,r13
    5250:	mov    QWORD PTR [rdi],r12
    5253:	mov    rbx,QWORD PTR [rsp]
    5257:	mov    r12,QWORD PTR [rsp+0x8]
    525c:	mov    r13,QWORD PTR [rsp+0x10]
    5261:	mov    r14,QWORD PTR [rsp+0x18]
    5266:	add    rsp,0x20
    526a:	mov    rsp,rbp
    526d:	pop    rbp
    526e:	ret
    526f:	mov    r13,rdi
    5272:	call   5277 <botlish_fn_26+0x217>
			5273: R_X86_64_PLT32	rt_stack_overflow-0x4
    5277:	xor    rax,rax
    527a:	mov    rbx,QWORD PTR [rsp]
    527e:	mov    r12,QWORD PTR [rsp+0x8]
    5283:	mov    r13,QWORD PTR [rsp+0x10]
    5288:	mov    r14,QWORD PTR [rsp+0x18]
    528d:	add    rsp,0x20
    5291:	mov    rsp,rbp
    5294:	pop    rbp
    5295:	ret
    5296:	add    BYTE PTR [rax],al
    5298:	(bad)
    5299:	add    BYTE PTR [rax],al
    529b:	add    BYTE PTR [rax],al
    529d:	add    BYTE PTR [rax],al
	...

00000000000052a0 <botlish_entry_26: scan_local<generic>>:
    52a0:	push   rbp
    52a1:	mov    rbp,rsp
    52a4:	mov    rdx,QWORD PTR [rdx]
    52a7:	call   52ac <botlish_entry_26+0xc>
			52a8: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    52ac:	mov    rsp,rbp
    52af:	pop    rbp
    52b0:	ret
    52b1:	add    BYTE PTR [rax],al
    52b3:	add    BYTE PTR [rax],al
    52b5:	add    BYTE PTR [rax],al
	...

00000000000052b8 <botlish_fn_27: scan_label<generic>>:
    52b8:	push   rbp
    52b9:	mov    rbp,rsp
    52bc:	sub    rsp,0x20
    52c0:	mov    QWORD PTR [rsp],rbx
    52c4:	mov    QWORD PTR [rsp+0x8],r12
    52c9:	mov    QWORD PTR [rsp+0x10],r13
    52ce:	mov    QWORD PTR [rsp+0x18],r14
    52d3:	mov    r12,QWORD PTR [rdi]
    52d6:	mov    rax,QWORD PTR [rdi+0x8]
    52da:	lea    rcx,[r12+0x18]
    52df:	cmp    rcx,rax
    52e2:	ja     54c7 <botlish_fn_27+0x20f>
    52e8:	lea    rax,[r12+0x18]
    52ed:	mov    QWORD PTR [rdi],rax
    52f0:	mov    r13,rdi
    52f3:	mov    QWORD PTR [r12],0x0
    52fb:	mov    QWORD PTR [r12+0x8],0x0
    5304:	mov    QWORD PTR [r12+0x10],0x0
    530d:	mov    QWORD PTR [r12],rdx
    5311:	mov    rbx,rsi
    5314:	mov    rsi,rdx
    5317:	mov    rax,QWORD PTR [rbx+0x20]
    531b:	mov    rdx,QWORD PTR [rax]
    531e:	mov    ecx,0x1
    5323:	test   rsi,0x1
    532a:	jne    5348 <botlish_fn_27+0x90>
    5330:	xor    ecx,ecx
    5332:	test   rsi,0x7
    5339:	jne    5348 <botlish_fn_27+0x90>
    533f:	movzx  rax,BYTE PTR [rsi]
    5343:	cmp    al,0x1
    5345:	sete   cl
    5348:	test   cl,cl
    534a:	jne    536e <botlish_fn_27+0xb6>
    5350:	mov    rdi,r13
    5353:	mov    rax,QWORD PTR [rdi+0x10]
    5357:	mov    rcx,QWORD PTR [rax+0xb8]
    535e:	xor    rdx,rdx
    5361:	call   5366 <botlish_fn_27+0xae>
			5362: R_X86_64_PLT32	rt_type_error-0x4
    5366:	mov    rdi,r13
    5369:	jmp    5405 <botlish_fn_27+0x14d>
    536e:	mov    rax,rsi
    5371:	and    rax,rdx
    5374:	mov    r14,rsi
    5377:	test   rax,0x1
    537d:	jne    53a3 <botlish_fn_27+0xeb>
    5383:	mov    rsi,r14
    5386:	mov    rdi,r13
    5389:	call   538e <botlish_fn_27+0xd6>
			538a: R_X86_64_PLT32	rt_int_cmp-0x4
    538e:	mov    ecx,0x2
    5393:	test   rax,rax
    5396:	cmovge rcx,QWORD PTR [rip+0x152]        # 54f0 <botlish_fn_27+0x238>
    539e:	jmp    53b6 <botlish_fn_27+0xfe>
    53a3:	mov    ecx,0x2
    53a8:	mov    rsi,r14
    53ab:	cmp    rsi,rdx
    53ae:	cmovge rcx,QWORD PTR [rip+0x13a]        # 54f0 <botlish_fn_27+0x238>
    53b6:	cmp    rcx,0x6
    53ba:	je     549f <botlish_fn_27+0x1e7>
    53c0:	mov    rdi,QWORD PTR [rbx+0x20]
    53c4:	mov    rsi,QWORD PTR [rdi+0x8]
    53c8:	mov    QWORD PTR [r12+0x8],rsi
    53cd:	mov    rdx,r14
    53d0:	mov    rdi,r13
    53d3:	call   53d8 <botlish_fn_27+0x120>
			53d4: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    53d8:	test   rax,rax
    53db:	jne    53e9 <botlish_fn_27+0x131>
    53e1:	mov    rdi,r13
    53e4:	jmp    5405 <botlish_fn_27+0x14d>
    53e9:	mov    QWORD PTR [r12+0x8],rax
    53ee:	mov    rsi,rax
    53f1:	mov    rdi,r13
    53f4:	call   53f9 <botlish_fn_27+0x141>
			53f5: R_X86_64_PLT32	botlish_fn_25-0x4 ; is_label_char<str>
    53f9:	test   rax,rax
    53fc:	jne    542a <botlish_fn_27+0x172>
    5402:	mov    rdi,r13
    5405:	mov    rdi,r13
    5408:	mov    QWORD PTR [rdi],r12
    540b:	xor    rax,rax
    540e:	mov    rbx,QWORD PTR [rsp]
    5412:	mov    r12,QWORD PTR [rsp+0x8]
    5417:	mov    r13,QWORD PTR [rsp+0x10]
    541c:	mov    r14,QWORD PTR [rsp+0x18]
    5421:	add    rsp,0x20
    5425:	mov    rsp,rbp
    5428:	pop    rbp
    5429:	ret
    542a:	cmp    rax,0x6
    542e:	je     543f <botlish_fn_27+0x187>
    5434:	mov    rax,r14
    5437:	mov    rdi,r13
    543a:	jmp    54a5 <botlish_fn_27+0x1ed>
    543f:	mov    QWORD PTR [r12+0x8],rbx
    5444:	mov    QWORD PTR [r12+0x10],0x3
    544d:	mov    rsi,r14
    5450:	test   rsi,0x1
    5457:	je     547d <botlish_fn_27+0x1c5>
    545d:	mov    rsi,r14
    5460:	mov    rcx,rsi
    5463:	add    rcx,0x2
    5467:	seto   al
    546a:	test   al,al
    546c:	jne    547d <botlish_fn_27+0x1c5>
    5472:	mov    rsi,rcx
    5475:	mov    r14,rcx
    5478:	jmp    5493 <botlish_fn_27+0x1db>
    547d:	mov    edx,0x3
    5482:	mov    rsi,r14
    5485:	mov    rdi,r13
    5488:	call   548d <botlish_fn_27+0x1d5>
			5489: R_X86_64_PLT32	rt_int_add-0x4
    548d:	mov    rsi,rax
    5490:	mov    r14,rax
    5493:	mov    QWORD PTR [r12],rsi
    5497:	mov    rsi,r14
    549a:	jmp    5317 <botlish_fn_27+0x5f>
    549f:	mov    rax,r14
    54a2:	mov    rdi,r13
    54a5:	mov    rdi,r13
    54a8:	mov    QWORD PTR [rdi],r12
    54ab:	mov    rbx,QWORD PTR [rsp]
    54af:	mov    r12,QWORD PTR [rsp+0x8]
    54b4:	mov    r13,QWORD PTR [rsp+0x10]
    54b9:	mov    r14,QWORD PTR [rsp+0x18]
    54be:	add    rsp,0x20
    54c2:	mov    rsp,rbp
    54c5:	pop    rbp
    54c6:	ret
    54c7:	mov    r13,rdi
    54ca:	call   54cf <botlish_fn_27+0x217>
			54cb: R_X86_64_PLT32	rt_stack_overflow-0x4
    54cf:	xor    rax,rax
    54d2:	mov    rbx,QWORD PTR [rsp]
    54d6:	mov    r12,QWORD PTR [rsp+0x8]
    54db:	mov    r13,QWORD PTR [rsp+0x10]
    54e0:	mov    r14,QWORD PTR [rsp+0x18]
    54e5:	add    rsp,0x20
    54e9:	mov    rsp,rbp
    54ec:	pop    rbp
    54ed:	ret
    54ee:	add    BYTE PTR [rax],al
    54f0:	(bad)
    54f1:	add    BYTE PTR [rax],al
    54f3:	add    BYTE PTR [rax],al
    54f5:	add    BYTE PTR [rax],al
	...

00000000000054f8 <botlish_entry_27: scan_label<generic>>:
    54f8:	push   rbp
    54f9:	mov    rbp,rsp
    54fc:	mov    rdx,QWORD PTR [rdx]
    54ff:	call   5504 <botlish_entry_27+0xc>
			5500: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_label<generic>
    5504:	mov    rsp,rbp
    5507:	pop    rbp
    5508:	ret
    5509:	add    BYTE PTR [rax],al
    550b:	add    BYTE PTR [rax],al
    550d:	add    BYTE PTR [rax],al
	...

0000000000005510 <botlish_fn_28: scan_alpha<generic>>:
    5510:	push   rbp
    5511:	mov    rbp,rsp
    5514:	sub    rsp,0x20
    5518:	mov    QWORD PTR [rsp],rbx
    551c:	mov    QWORD PTR [rsp+0x8],r12
    5521:	mov    QWORD PTR [rsp+0x10],r13
    5526:	mov    QWORD PTR [rsp+0x18],r14
    552b:	mov    r12,QWORD PTR [rdi]
    552e:	mov    rax,QWORD PTR [rdi+0x8]
    5532:	lea    rcx,[r12+0x18]
    5537:	cmp    rcx,rax
    553a:	ja     571a <botlish_fn_28+0x20a>
    5540:	lea    rax,[r12+0x18]
    5545:	mov    QWORD PTR [rdi],rax
    5548:	mov    r13,rdi
    554b:	mov    QWORD PTR [r12],0x0
    5553:	mov    QWORD PTR [r12+0x8],0x0
    555c:	mov    QWORD PTR [r12+0x10],0x0
    5565:	mov    QWORD PTR [r12],rdx
    5569:	mov    rbx,rsi
    556c:	mov    rsi,rdx
    556f:	mov    rax,QWORD PTR [rbx+0x20]
    5573:	mov    rdx,QWORD PTR [rax]
    5576:	mov    ecx,0x1
    557b:	test   rsi,0x1
    5582:	jne    55a0 <botlish_fn_28+0x90>
    5588:	xor    ecx,ecx
    558a:	test   rsi,0x7
    5591:	jne    55a0 <botlish_fn_28+0x90>
    5597:	movzx  rax,BYTE PTR [rsi]
    559b:	cmp    al,0x1
    559d:	sete   cl
    55a0:	test   cl,cl
    55a2:	jne    55c6 <botlish_fn_28+0xb6>
    55a8:	mov    rdi,r13
    55ab:	mov    rax,QWORD PTR [rdi+0x10]
    55af:	mov    rcx,QWORD PTR [rax+0xb8]
    55b6:	xor    rdx,rdx
    55b9:	call   55be <botlish_fn_28+0xae>
			55ba: R_X86_64_PLT32	rt_type_error-0x4
    55be:	mov    rdi,r13
    55c1:	jmp    5658 <botlish_fn_28+0x148>
    55c6:	mov    rax,rsi
    55c9:	and    rax,rdx
    55cc:	mov    r14,rsi
    55cf:	test   rax,0x1
    55d5:	jne    55fb <botlish_fn_28+0xeb>
    55db:	mov    rsi,r14
    55de:	mov    rdi,r13
    55e1:	call   55e6 <botlish_fn_28+0xd6>
			55e2: R_X86_64_PLT32	rt_int_cmp-0x4
    55e6:	mov    ecx,0x2
    55eb:	test   rax,rax
    55ee:	cmovge rcx,QWORD PTR [rip+0x152]        # 5748 <botlish_fn_28+0x238>
    55f6:	jmp    560e <botlish_fn_28+0xfe>
    55fb:	mov    ecx,0x2
    5600:	mov    rsi,r14
    5603:	cmp    rsi,rdx
    5606:	cmovge rcx,QWORD PTR [rip+0x13a]        # 5748 <botlish_fn_28+0x238>
    560e:	cmp    rcx,0x6
    5612:	je     56f2 <botlish_fn_28+0x1e2>
    5618:	mov    rdi,QWORD PTR [rbx+0x20]
    561c:	mov    rsi,QWORD PTR [rdi+0x8]
    5620:	mov    QWORD PTR [r12+0x8],rsi
    5625:	mov    rdx,r14
    5628:	mov    rdi,r13
    562b:	call   5630 <botlish_fn_28+0x120>
			562c: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    5630:	test   rax,rax
    5633:	mov    rsi,rax
    5636:	jne    5644 <botlish_fn_28+0x134>
    563c:	mov    rdi,r13
    563f:	jmp    5658 <botlish_fn_28+0x148>
    5644:	mov    rdi,r13
    5647:	call   564c <botlish_fn_28+0x13c>
			5648: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    564c:	test   rax,rax
    564f:	jne    567d <botlish_fn_28+0x16d>
    5655:	mov    rdi,r13
    5658:	mov    rdi,r13
    565b:	mov    QWORD PTR [rdi],r12
    565e:	xor    rax,rax
    5661:	mov    rbx,QWORD PTR [rsp]
    5665:	mov    r12,QWORD PTR [rsp+0x8]
    566a:	mov    r13,QWORD PTR [rsp+0x10]
    566f:	mov    r14,QWORD PTR [rsp+0x18]
    5674:	add    rsp,0x20
    5678:	mov    rsp,rbp
    567b:	pop    rbp
    567c:	ret
    567d:	cmp    rax,0x6
    5681:	je     5692 <botlish_fn_28+0x182>
    5687:	mov    rax,r14
    568a:	mov    rdi,r13
    568d:	jmp    56f8 <botlish_fn_28+0x1e8>
    5692:	mov    QWORD PTR [r12+0x8],rbx
    5697:	mov    QWORD PTR [r12+0x10],0x3
    56a0:	mov    rsi,r14
    56a3:	test   rsi,0x1
    56aa:	je     56d0 <botlish_fn_28+0x1c0>
    56b0:	mov    rsi,r14
    56b3:	mov    rcx,rsi
    56b6:	add    rcx,0x2
    56ba:	seto   al
    56bd:	test   al,al
    56bf:	jne    56d0 <botlish_fn_28+0x1c0>
    56c5:	mov    rsi,rcx
    56c8:	mov    r14,rcx
    56cb:	jmp    56e6 <botlish_fn_28+0x1d6>
    56d0:	mov    edx,0x3
    56d5:	mov    rsi,r14
    56d8:	mov    rdi,r13
    56db:	call   56e0 <botlish_fn_28+0x1d0>
			56dc: R_X86_64_PLT32	rt_int_add-0x4
    56e0:	mov    rsi,rax
    56e3:	mov    r14,rax
    56e6:	mov    QWORD PTR [r12],rsi
    56ea:	mov    rsi,r14
    56ed:	jmp    556f <botlish_fn_28+0x5f>
    56f2:	mov    rax,r14
    56f5:	mov    rdi,r13
    56f8:	mov    rdi,r13
    56fb:	mov    QWORD PTR [rdi],r12
    56fe:	mov    rbx,QWORD PTR [rsp]
    5702:	mov    r12,QWORD PTR [rsp+0x8]
    5707:	mov    r13,QWORD PTR [rsp+0x10]
    570c:	mov    r14,QWORD PTR [rsp+0x18]
    5711:	add    rsp,0x20
    5715:	mov    rsp,rbp
    5718:	pop    rbp
    5719:	ret
    571a:	mov    r13,rdi
    571d:	call   5722 <botlish_fn_28+0x212>
			571e: R_X86_64_PLT32	rt_stack_overflow-0x4
    5722:	xor    rax,rax
    5725:	mov    rbx,QWORD PTR [rsp]
    5729:	mov    r12,QWORD PTR [rsp+0x8]
    572e:	mov    r13,QWORD PTR [rsp+0x10]
    5733:	mov    r14,QWORD PTR [rsp+0x18]
    5738:	add    rsp,0x20
    573c:	mov    rsp,rbp
    573f:	pop    rbp
    5740:	ret
    5741:	add    BYTE PTR [rax],al
    5743:	add    BYTE PTR [rax],al
    5745:	add    BYTE PTR [rax],al
    5747:	add    BYTE PTR [rsi],al
    5749:	add    BYTE PTR [rax],al
    574b:	add    BYTE PTR [rax],al
    574d:	add    BYTE PTR [rax],al
	...

0000000000005750 <botlish_entry_28: scan_alpha<generic>>:
    5750:	push   rbp
    5751:	mov    rbp,rsp
    5754:	mov    rdx,QWORD PTR [rdx]
    5757:	call   575c <botlish_entry_28+0xc>
			5758: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_alpha<generic>
    575c:	mov    rsp,rbp
    575f:	pop    rbp
    5760:	ret
    5761:	add    BYTE PTR [rax],al
    5763:	add    BYTE PTR [rax],al
    5765:	add    BYTE PTR [rax],al
	...

0000000000005768 <botlish_fn_29: tld_ok<generic>>:
    5768:	push   rbp
    5769:	mov    rbp,rsp
    576c:	sub    rsp,0x30
    5770:	mov    QWORD PTR [rsp],rbx
    5774:	mov    QWORD PTR [rsp+0x8],r12
    5779:	mov    QWORD PTR [rsp+0x10],r13
    577e:	mov    QWORD PTR [rsp+0x18],r14
    5783:	mov    QWORD PTR [rsp+0x20],r15
    5788:	mov    rbx,QWORD PTR [rdi]
    578b:	mov    rax,QWORD PTR [rdi+0x8]
    578f:	lea    rcx,[rbx+0x10]
    5793:	cmp    rcx,rax
    5796:	ja     59aa <botlish_fn_29+0x242>
    579c:	lea    rax,[rbx+0x10]
    57a0:	mov    QWORD PTR [rdi],rax
    57a3:	mov    r12,rdi
    57a6:	mov    QWORD PTR [rbx],0x0
    57ad:	mov    QWORD PTR [rbx+0x8],0x0
    57b5:	mov    QWORD PTR [rbx],rdx
    57b8:	mov    r8,rdx
    57bb:	mov    rax,QWORD PTR [rsi+0x20]
    57bf:	mov    r15,rsi
    57c2:	mov    rsi,QWORD PTR [rax]
    57c5:	mov    QWORD PTR [rbx+0x8],rsi
    57c9:	mov    r13,r8
    57cc:	mov    rdx,r13
    57cf:	mov    rdi,r12
    57d2:	call   57d7 <botlish_fn_29+0x6f>
			57d3: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_alpha<generic>
    57d7:	mov    rcx,rax
    57da:	mov    r14,rax
    57dd:	test   rax,rcx
    57e0:	jne    57ee <botlish_fn_29+0x86>
    57e6:	mov    rdi,r12
    57e9:	jmp    58c6 <botlish_fn_29+0x15e>
    57ee:	mov    rax,r14
    57f1:	mov    QWORD PTR [rbx+0x8],rax
    57f5:	mov    rsi,r15
    57f8:	mov    rax,QWORD PTR [rsi+0x20]
    57fc:	mov    rdx,QWORD PTR [rax+0x8]
    5800:	mov    rax,r14
    5803:	and    rax,rdx
    5806:	test   rax,0x1
    580c:	jne    5835 <botlish_fn_29+0xcd>
    5812:	mov    rsi,r14
    5815:	mov    rdi,r12
    5818:	call   581d <botlish_fn_29+0xb5>
			5819: R_X86_64_PLT32	rt_int_cmp-0x4
    581d:	mov    ecx,0x2
    5822:	test   rax,rax
    5825:	cmove  rcx,QWORD PTR [rip+0x1ab]        # 59d8 <botlish_fn_29+0x270>
    582d:	mov    rax,r14
    5830:	jmp    5848 <botlish_fn_29+0xe0>
    5835:	mov    ecx,0x2
    583a:	mov    rax,r14
    583d:	cmp    rax,rdx
    5840:	cmove  rcx,QWORD PTR [rip+0x190]        # 59d8 <botlish_fn_29+0x270>
    5848:	cmp    rcx,0x6
    584c:	je     5862 <botlish_fn_29+0xfa>
    5852:	mov    ecx,0x2
    5857:	mov    rax,rcx
    585a:	mov    rdi,r12
    585d:	jmp    5983 <botlish_fn_29+0x21b>
    5862:	mov    ecx,0x1
    5867:	test   r13,0x1
    586e:	je     587c <botlish_fn_29+0x114>
    5874:	mov    r8,r13
    5877:	jmp    58a2 <botlish_fn_29+0x13a>
    587c:	xor    ecx,ecx
    587e:	test   r13,0x7
    5885:	je     5893 <botlish_fn_29+0x12b>
    588b:	mov    r8,r13
    588e:	jmp    58a2 <botlish_fn_29+0x13a>
    5893:	movzx  rcx,BYTE PTR [r13+0x0]
    5898:	mov    r8,r13
    589b:	rex cmp cl,0x1
    589f:	sete   cl
    58a2:	test   cl,cl
    58a4:	jne    58f0 <botlish_fn_29+0x188>
    58aa:	mov    rdi,r12
    58ad:	mov    rax,QWORD PTR [rdi+0x10]
    58b1:	mov    rcx,QWORD PTR [rax+0x128]
    58b8:	xor    rdx,rdx
    58bb:	mov    rsi,r8
    58be:	call   58c3 <botlish_fn_29+0x15b>
			58bf: R_X86_64_PLT32	rt_type_error-0x4
    58c3:	mov    rdi,r12
    58c6:	mov    rdi,r12
    58c9:	mov    QWORD PTR [rdi],rbx
    58cc:	xor    rax,rax
    58cf:	mov    rbx,QWORD PTR [rsp]
    58d3:	mov    r12,QWORD PTR [rsp+0x8]
    58d8:	mov    r13,QWORD PTR [rsp+0x10]
    58dd:	mov    r14,QWORD PTR [rsp+0x18]
    58e2:	mov    r15,QWORD PTR [rsp+0x20]
    58e7:	add    rsp,0x30
    58eb:	mov    rsp,rbp
    58ee:	pop    rbp
    58ef:	ret
    58f0:	mov    rdx,r8
    58f3:	mov    rcx,rax
    58f6:	and    rcx,rdx
    58f9:	test   rcx,0x1
    5900:	jne    5911 <botlish_fn_29+0x1a9>
    5906:	mov    rdx,r8
    5909:	mov    rsi,rax
    590c:	jmp    5932 <botlish_fn_29+0x1ca>
    5911:	mov    rdx,r8
    5914:	mov    rcx,rax
    5917:	sub    rcx,rdx
    591a:	mov    r14,rax
    591d:	seto   al
    5920:	lea    rsi,[rcx+0x1]
    5924:	test   al,al
    5926:	je     593d <botlish_fn_29+0x1d5>
    592c:	mov    rdx,r8
    592f:	mov    rsi,r14
    5932:	mov    rdi,r12
    5935:	call   593a <botlish_fn_29+0x1d2>
			5936: R_X86_64_PLT32	rt_int_sub-0x4
    593a:	mov    rsi,rax
    593d:	test   rsi,0x1
    5944:	jne    596f <botlish_fn_29+0x207>
    594a:	mov    edx,0x5
    594f:	mov    rdi,r12
    5952:	call   5957 <botlish_fn_29+0x1ef>
			5953: R_X86_64_PLT32	rt_int_cmp-0x4
    5957:	mov    ecx,0x2
    595c:	test   rax,rax
    595f:	mov    rax,rcx
    5962:	cmovge rax,QWORD PTR [rip+0x6e]        # 59d8 <botlish_fn_29+0x270>
    596a:	jmp    5980 <botlish_fn_29+0x218>
    596f:	mov    eax,0x2
    5974:	cmp    rsi,0x5
    5978:	cmovge rax,QWORD PTR [rip+0x58]        # 59d8 <botlish_fn_29+0x270>
    5980:	mov    rdi,r12
    5983:	mov    rdi,r12
    5986:	mov    QWORD PTR [rdi],rbx
    5989:	mov    rbx,QWORD PTR [rsp]
    598d:	mov    r12,QWORD PTR [rsp+0x8]
    5992:	mov    r13,QWORD PTR [rsp+0x10]
    5997:	mov    r14,QWORD PTR [rsp+0x18]
    599c:	mov    r15,QWORD PTR [rsp+0x20]
    59a1:	add    rsp,0x30
    59a5:	mov    rsp,rbp
    59a8:	pop    rbp
    59a9:	ret
    59aa:	mov    r12,rdi
    59ad:	call   59b2 <botlish_fn_29+0x24a>
			59ae: R_X86_64_PLT32	rt_stack_overflow-0x4
    59b2:	xor    rax,rax
    59b5:	mov    rbx,QWORD PTR [rsp]
    59b9:	mov    r12,QWORD PTR [rsp+0x8]
    59be:	mov    r13,QWORD PTR [rsp+0x10]
    59c3:	mov    r14,QWORD PTR [rsp+0x18]
    59c8:	mov    r15,QWORD PTR [rsp+0x20]
    59cd:	add    rsp,0x30
    59d1:	mov    rsp,rbp
    59d4:	pop    rbp
    59d5:	ret
    59d6:	add    BYTE PTR [rax],al
    59d8:	(bad)
    59d9:	add    BYTE PTR [rax],al
    59db:	add    BYTE PTR [rax],al
    59dd:	add    BYTE PTR [rax],al
	...

00000000000059e0 <botlish_entry_29: tld_ok<generic>>:
    59e0:	push   rbp
    59e1:	mov    rbp,rsp
    59e4:	mov    rdx,QWORD PTR [rdx]
    59e7:	call   59ec <botlish_entry_29+0xc>
			59e8: R_X86_64_PLT32	botlish_fn_29-0x4 ; tld_ok<generic>
    59ec:	mov    rsp,rbp
    59ef:	pop    rbp
    59f0:	ret
    59f1:	add    BYTE PTR [rax],al
    59f3:	add    BYTE PTR [rax],al
    59f5:	add    BYTE PTR [rax],al
	...

00000000000059f8 <botlish_fn_30: domain_loop<generic>>:
    59f8:	push   rbp
    59f9:	mov    rbp,rsp
    59fc:	sub    rsp,0x50
    5a00:	mov    QWORD PTR [rsp+0x20],rbx
    5a05:	mov    QWORD PTR [rsp+0x28],r12
    5a0a:	mov    QWORD PTR [rsp+0x30],r13
    5a0f:	mov    QWORD PTR [rsp+0x38],r14
    5a14:	mov    QWORD PTR [rsp+0x40],r15
    5a19:	mov    r13,QWORD PTR [rdi]
    5a1c:	mov    rax,QWORD PTR [rdi+0x8]
    5a20:	lea    rcx,[r13+0x10]
    5a24:	cmp    rcx,rax
    5a27:	ja     5ca6 <botlish_fn_30+0x2ae>
    5a2d:	lea    rax,[r13+0x10]
    5a31:	mov    QWORD PTR [rdi],rax
    5a34:	mov    r15,rdi
    5a37:	mov    QWORD PTR [r13+0x0],0x0
    5a3f:	mov    QWORD PTR [r13+0x8],0x0
    5a47:	mov    QWORD PTR [r13+0x0],rdx
    5a4b:	mov    QWORD PTR [rsp+0x10],rdx
    5a50:	lea    rbx,[rsp]
    5a54:	mov    r12,rsi
    5a57:	mov    rax,QWORD PTR [r12+0x20]
    5a5c:	mov    rsi,QWORD PTR [rax]
    5a5f:	mov    QWORD PTR [r13+0x8],rsi
    5a63:	mov    rdx,QWORD PTR [rsp+0x10]
    5a68:	mov    rdi,r15
    5a6b:	call   5a70 <botlish_fn_30+0x78>
			5a6c: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_label<generic>
    5a70:	mov    rcx,rax
    5a73:	mov    r14,rax
    5a76:	test   rax,rcx
    5a79:	jne    5a87 <botlish_fn_30+0x8f>
    5a7f:	mov    rdi,r15
    5a82:	jmp    5c14 <botlish_fn_30+0x21c>
    5a87:	mov    rax,r14
    5a8a:	mov    QWORD PTR [r13+0x0],rax
    5a8e:	mov    rdx,QWORD PTR [rsp+0x10]
    5a93:	mov    rsi,rax
    5a96:	and    rsi,rdx
    5a99:	test   rsi,0x1
    5aa0:	jne    5ac7 <botlish_fn_30+0xcf>
    5aa6:	mov    rdx,QWORD PTR [rsp+0x10]
    5aab:	mov    rsi,r14
    5aae:	mov    rdi,r15
    5ab1:	call   5ab6 <botlish_fn_30+0xbe>
			5ab2: R_X86_64_PLT32	rt_value_eq-0x4
    5ab6:	test   rax,rax
    5ab9:	jne    5adc <botlish_fn_30+0xe4>
    5abf:	mov    rdi,r15
    5ac2:	jmp    5c14 <botlish_fn_30+0x21c>
    5ac7:	mov    eax,0x2
    5acc:	mov    rdx,QWORD PTR [rsp+0x10]
    5ad1:	cmp    r14,rdx
    5ad4:	cmove  rax,QWORD PTR [rip+0x1fc]        # 5cd8 <botlish_fn_30+0x2e0>
    5adc:	cmp    rax,0x6
    5ae0:	je     5c74 <botlish_fn_30+0x27c>
    5ae6:	mov    rax,QWORD PTR [r12+0x20]
    5aeb:	mov    rdx,QWORD PTR [rax+0x8]
    5aef:	mov    rax,r14
    5af2:	and    rax,rdx
    5af5:	test   rax,0x1
    5afb:	jne    5b21 <botlish_fn_30+0x129>
    5b01:	mov    rsi,r14
    5b04:	mov    rdi,r15
    5b07:	call   5b0c <botlish_fn_30+0x114>
			5b08: R_X86_64_PLT32	rt_int_cmp-0x4
    5b0c:	mov    ecx,0x2
    5b11:	test   rax,rax
    5b14:	cmovge rcx,QWORD PTR [rip+0x1bc]        # 5cd8 <botlish_fn_30+0x2e0>
    5b1c:	jmp    5b31 <botlish_fn_30+0x139>
    5b21:	mov    ecx,0x2
    5b26:	cmp    r14,rdx
    5b29:	cmovge rcx,QWORD PTR [rip+0x1a7]        # 5cd8 <botlish_fn_30+0x2e0>
    5b31:	cmp    rcx,0x6
    5b35:	je     5c65 <botlish_fn_30+0x26d>
    5b3b:	mov    rax,QWORD PTR [r12+0x20]
    5b40:	mov    rsi,QWORD PTR [rax+0x10]
    5b44:	mov    QWORD PTR [r13+0x8],rsi
    5b48:	mov    rcx,rbx
    5b4b:	mov    rdx,r14
    5b4e:	mov    rdi,r15
    5b51:	call   5b56 <botlish_fn_30+0x15e>
			5b52: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    5b56:	test   rax,rax
    5b59:	mov    rsi,rax
    5b5c:	jne    5b6a <botlish_fn_30+0x172>
    5b62:	mov    rdi,r15
    5b65:	jmp    5c14 <botlish_fn_30+0x21c>
    5b6a:	mov    rdx,QWORD PTR [rsp]
    5b6e:	mov    rcx,QWORD PTR [rsp+0x8]
    5b73:	mov    rdi,r15
    5b76:	mov    rax,QWORD PTR [rdi+0x10]
    5b7a:	mov    r8,QWORD PTR [rax+0x118]
    5b81:	call   5b86 <botlish_fn_30+0x18e>
			5b82: R_X86_64_PLT32	rt_str_region_eq-0x4
    5b86:	cmp    rax,0x6
    5b8a:	je     5b9c <botlish_fn_30+0x1a4>
    5b90:	mov    rax,0xffffffffffffffff
    5b97:	jmp    5c6c <botlish_fn_30+0x274>
    5b9c:	mov    QWORD PTR [r13+0x8],0x3
    5ba4:	test   r14,0x1
    5bab:	je     5bd2 <botlish_fn_30+0x1da>
    5bb1:	mov    rdx,r14
    5bb4:	add    rdx,0x2
    5bb8:	mov    QWORD PTR [rsp+0x10],rdx
    5bbd:	seto   al
    5bc0:	test   al,al
    5bc2:	jne    5bd2 <botlish_fn_30+0x1da>
    5bc8:	mov    rdx,QWORD PTR [rsp+0x10]
    5bcd:	jmp    5bea <botlish_fn_30+0x1f2>
    5bd2:	mov    edx,0x3
    5bd7:	mov    rsi,r14
    5bda:	mov    rdi,r15
    5bdd:	call   5be2 <botlish_fn_30+0x1ea>
			5bde: R_X86_64_PLT32	rt_int_add-0x4
    5be2:	mov    rdx,rax
    5be5:	mov    QWORD PTR [rsp+0x10],rax
    5bea:	mov    QWORD PTR [r13+0x0],rdx
    5bee:	mov    rax,QWORD PTR [r12+0x20]
    5bf3:	mov    rsi,QWORD PTR [rax+0x18]
    5bf7:	mov    QWORD PTR [r13+0x8],rsi
    5bfb:	mov    rdx,QWORD PTR [rsp+0x10]
    5c00:	mov    rdi,r15
    5c03:	call   5c08 <botlish_fn_30+0x210>
			5c04: R_X86_64_PLT32	botlish_fn_29-0x4 ; tld_ok<generic>
    5c08:	test   rax,rax
    5c0b:	jne    5c3f <botlish_fn_30+0x247>
    5c11:	mov    rdi,r15
    5c14:	mov    rdi,r15
    5c17:	mov    QWORD PTR [rdi],r13
    5c1a:	xor    rax,rax
    5c1d:	mov    rbx,QWORD PTR [rsp+0x20]
    5c22:	mov    r12,QWORD PTR [rsp+0x28]
    5c27:	mov    r13,QWORD PTR [rsp+0x30]
    5c2c:	mov    r14,QWORD PTR [rsp+0x38]
    5c31:	mov    r15,QWORD PTR [rsp+0x40]
    5c36:	add    rsp,0x50
    5c3a:	mov    rsp,rbp
    5c3d:	pop    rbp
    5c3e:	ret
    5c3f:	cmp    rax,0x6
    5c43:	je     5c57 <botlish_fn_30+0x25f>
    5c49:	mov    rdx,QWORD PTR [rsp+0x10]
    5c4e:	mov    QWORD PTR [r13+0x0],rdx
    5c52:	jmp    5a57 <botlish_fn_30+0x5f>
    5c57:	mov    rax,QWORD PTR [r12+0x20]
    5c5c:	mov    rax,QWORD PTR [rax+0x8]
    5c60:	jmp    5c6c <botlish_fn_30+0x274>
    5c65:	mov    rax,0xffffffffffffffff
    5c6c:	mov    rdi,r15
    5c6f:	jmp    5c7e <botlish_fn_30+0x286>
    5c74:	mov    rax,0xffffffffffffffff
    5c7b:	mov    rdi,r15
    5c7e:	mov    rdi,r15
    5c81:	mov    QWORD PTR [rdi],r13
    5c84:	mov    rbx,QWORD PTR [rsp+0x20]
    5c89:	mov    r12,QWORD PTR [rsp+0x28]
    5c8e:	mov    r13,QWORD PTR [rsp+0x30]
    5c93:	mov    r14,QWORD PTR [rsp+0x38]
    5c98:	mov    r15,QWORD PTR [rsp+0x40]
    5c9d:	add    rsp,0x50
    5ca1:	mov    rsp,rbp
    5ca4:	pop    rbp
    5ca5:	ret
    5ca6:	mov    r15,rdi
    5ca9:	call   5cae <botlish_fn_30+0x2b6>
			5caa: R_X86_64_PLT32	rt_stack_overflow-0x4
    5cae:	xor    rax,rax
    5cb1:	mov    rbx,QWORD PTR [rsp+0x20]
    5cb6:	mov    r12,QWORD PTR [rsp+0x28]
    5cbb:	mov    r13,QWORD PTR [rsp+0x30]
    5cc0:	mov    r14,QWORD PTR [rsp+0x38]
    5cc5:	mov    r15,QWORD PTR [rsp+0x40]
    5cca:	add    rsp,0x50
    5cce:	mov    rsp,rbp
    5cd1:	pop    rbp
    5cd2:	ret
    5cd3:	add    BYTE PTR [rax],al
    5cd5:	add    BYTE PTR [rax],al
    5cd7:	add    BYTE PTR [rsi],al
    5cd9:	add    BYTE PTR [rax],al
    5cdb:	add    BYTE PTR [rax],al
    5cdd:	add    BYTE PTR [rax],al
	...

0000000000005ce0 <botlish_entry_30: domain_loop<generic>>:
    5ce0:	push   rbp
    5ce1:	mov    rbp,rsp
    5ce4:	mov    rdx,QWORD PTR [rdx]
    5ce7:	call   5cec <botlish_entry_30+0xc>
			5ce8: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    5cec:	mov    rsp,rbp
    5cef:	pop    rbp
    5cf0:	ret

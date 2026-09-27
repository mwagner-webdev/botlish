; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10027  (per function: 1588 39 289 617 74 74 74 125 125 833 262 222 272 249 552 468 660 155 125 103 453 750 486 828 604)
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
;   botlish_fn_9 / botlish_entry_9 -> web::is_emailish<generic>
;   botlish_fn_10 / botlish_entry_10 -> char_at<generic>
;   botlish_fn_11 / botlish_entry_11 -> char_at<generic>
;   botlish_fn_12 / botlish_entry_12 -> is_local_char<generic>
;   botlish_fn_13 / botlish_entry_13 -> is_label_char<generic>
;   botlish_fn_14 / botlish_entry_14 -> scan_while<generic>
;   botlish_fn_15 / botlish_entry_15 -> tld_ok<generic>
;   botlish_fn_16 / botlish_entry_16 -> domain_loop<generic>
;   botlish_fn_17 / botlish_entry_17 -> web::is_unreserved<generic>
;   botlish_fn_18 / botlish_entry_18 -> web::uri_escape_text<generic>
;   botlish_fn_19 / botlish_entry_19 -> high_nibble<generic>
;   botlish_fn_20 / botlish_entry_20 -> hex_pair<generic>
;   botlish_fn_21 / botlish_entry_21 -> esc_bytes<generic>
;   botlish_fn_22 / botlish_entry_22 -> esc_char<generic>
;   botlish_fn_23 / botlish_entry_23 -> esc_from<generic>
;   botlish_fn_24 / botlish_entry_24 -> check<generic>


refined-checks.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x1e0
       b:	mov    QWORD PTR [rsp+0x1b0],rbx
      13:	mov    QWORD PTR [rsp+0x1b8],r12
      1b:	mov    QWORD PTR [rsp+0x1c0],r13
      23:	mov    QWORD PTR [rsp+0x1c8],r14
      2b:	mov    QWORD PTR [rsp+0x1d0],r15
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
      96:	mov    QWORD PTR [rsp+0x80],0x0
      a2:	mov    rax,QWORD PTR [rdi+0x10]
      a6:	mov    rax,QWORD PTR [rax]
      a9:	mov    QWORD PTR [rsp],rax
      ad:	mov    rcx,QWORD PTR [rdi+0x10]
      b1:	mov    rcx,QWORD PTR [rcx+0x8]
      b5:	mov    QWORD PTR [rsp+0x8],rcx
      ba:	mov    rdx,QWORD PTR [rdi+0x10]
      be:	mov    r8,QWORD PTR [rdx+0x10]
      c2:	mov    QWORD PTR [rsp+0x10],r8
      c7:	mov    rdx,QWORD PTR [rdi+0x10]
      cb:	mov    rsi,QWORD PTR [rdx+0x18]
      cf:	mov    QWORD PTR [rsp+0x18],rsi
      d4:	mov    rdx,QWORD PTR [rdi+0x10]
      d8:	mov    QWORD PTR [rsp+0x180],rdi
      e0:	mov    rdi,QWORD PTR [rdx+0x20]
      e4:	mov    QWORD PTR [rsp+0x20],rdi
      e9:	lea    rdx,[rsp+0x88]
      f1:	mov    QWORD PTR [rsp+0x88],rax
      f9:	mov    QWORD PTR [rsp+0x90],rcx
     101:	mov    QWORD PTR [rsp+0x98],r8
     109:	mov    QWORD PTR [rsp+0xa0],rsi
     111:	mov    QWORD PTR [rsp+0xa8],rdi
     119:	mov    esi,0x5
     11e:	mov    rdi,QWORD PTR [rsp+0x180]
     126:	call   12b <botlish_fn_0+0x12b>
			127: R_X86_64_PLT32	rt_list_new-0x4
     12b:	test   rax,rax
     12e:	je     57b <botlish_fn_0+0x57b>
     134:	mov    QWORD PTR [rsp],rax
     138:	mov    rsi,rax
     13b:	mov    rdi,QWORD PTR [rsp+0x180]
     143:	call   148 <botlish_fn_0+0x148>
			144: R_X86_64_PLT32	rt_set_from_list-0x4
     148:	mov    QWORD PTR [rsp],rax
     14c:	lea    r8,[rsp+0xb0]
     154:	mov    QWORD PTR [rsp+0xb0],rax
     15c:	mov    esi,0x9
     161:	mov    rdx,QWORD PTR [rip+0x0]        # 168 <botlish_fn_0+0x168>
			164: R_X86_64_GOTPCREL	botlish_entry_9-0x4 ; web::is_emailish<generic>
     168:	mov    ecx,0x1
     16d:	mov    rdi,QWORD PTR [rsp+0x180]
     175:	call   17a <botlish_fn_0+0x17a>
			176: R_X86_64_PLT32	rt_closure_new-0x4
     17a:	mov    QWORD PTR [rsp],rax
     17e:	mov    rdi,QWORD PTR [rsp+0x180]
     186:	mov    QWORD PTR [rsp+0x1a8],rax
     18e:	mov    rax,QWORD PTR [rdi+0x10]
     192:	mov    rdx,QWORD PTR [rax+0x28]
     196:	mov    QWORD PTR [rsp+0x8],rdx
     19b:	mov    QWORD PTR [rsp+0x1a0],rdx
     1a3:	mov    rax,QWORD PTR [rdi+0x10]
     1a7:	mov    rsi,QWORD PTR [rax+0x30]
     1ab:	mov    QWORD PTR [rsp+0x10],rsi
     1b0:	mov    QWORD PTR [rsp+0x198],rsi
     1b8:	mov    rax,QWORD PTR [rdi+0x10]
     1bc:	mov    rdi,QWORD PTR [rax+0x38]
     1c0:	mov    QWORD PTR [rsp+0x18],rdi
     1c5:	mov    QWORD PTR [rsp+0x190],rdi
     1cd:	mov    rdi,QWORD PTR [rsp+0x180]
     1d5:	mov    rax,QWORD PTR [rdi+0x10]
     1d9:	mov    r8,QWORD PTR [rax+0x40]
     1dd:	mov    QWORD PTR [rsp+0x20],r8
     1e2:	mov    QWORD PTR [rsp+0x188],r8
     1ea:	mov    rax,QWORD PTR [rdi+0x10]
     1ee:	mov    r8,QWORD PTR [rax+0x48]
     1f2:	mov    QWORD PTR [rsp+0x28],r8
     1f7:	mov    rax,QWORD PTR [rdi+0x10]
     1fb:	mov    r9,QWORD PTR [rax+0x50]
     1ff:	mov    QWORD PTR [rsp+0x30],r9
     204:	mov    rax,QWORD PTR [rdi+0x10]
     208:	mov    r10,QWORD PTR [rax+0x58]
     20c:	mov    QWORD PTR [rsp+0x38],r10
     211:	mov    rax,QWORD PTR [rdi+0x10]
     215:	mov    r11,QWORD PTR [rax+0x60]
     219:	mov    QWORD PTR [rsp+0x40],r11
     21e:	mov    rax,QWORD PTR [rdi+0x10]
     222:	mov    rbx,QWORD PTR [rax+0x68]
     226:	mov    QWORD PTR [rsp+0x48],rbx
     22b:	mov    rax,QWORD PTR [rdi+0x10]
     22f:	mov    r12,QWORD PTR [rax+0x70]
     233:	mov    QWORD PTR [rsp+0x50],r12
     238:	mov    rcx,QWORD PTR [rdi+0x10]
     23c:	mov    rax,QWORD PTR [rcx+0x78]
     240:	mov    QWORD PTR [rsp+0x58],rax
     245:	mov    rdx,QWORD PTR [rdi+0x10]
     249:	mov    r13,QWORD PTR [rdx+0x80]
     250:	mov    QWORD PTR [rsp+0x60],r13
     255:	mov    rsi,QWORD PTR [rdi+0x10]
     259:	mov    r14,QWORD PTR [rsi+0x88]
     260:	mov    QWORD PTR [rsp+0x68],r14
     265:	mov    rsi,QWORD PTR [rdi+0x10]
     269:	mov    r15,QWORD PTR [rsi+0x90]
     270:	mov    QWORD PTR [rsp+0x70],r15
     275:	mov    rsi,QWORD PTR [rdi+0x10]
     279:	mov    rcx,QWORD PTR [rsi+0x98]
     280:	mov    QWORD PTR [rsp+0x78],rcx
     285:	mov    rsi,QWORD PTR [rdi+0x10]
     289:	mov    rdx,QWORD PTR [rsi+0xa0]
     290:	mov    QWORD PTR [rsp+0x80],rdx
     298:	lea    rdi,[rsp+0xb8]
     2a0:	mov    rsi,QWORD PTR [rsp+0x1a0]
     2a8:	mov    QWORD PTR [rsp+0xb8],rsi
     2b0:	mov    rsi,QWORD PTR [rsp+0x198]
     2b8:	mov    QWORD PTR [rsp+0xc0],rsi
     2c0:	mov    rsi,QWORD PTR [rsp+0x190]
     2c8:	mov    QWORD PTR [rsp+0xc8],rsi
     2d0:	mov    rsi,QWORD PTR [rsp+0x188]
     2d8:	mov    QWORD PTR [rsp+0xd0],rsi
     2e0:	mov    QWORD PTR [rsp+0xd8],r8
     2e8:	mov    QWORD PTR [rsp+0xe0],r9
     2f0:	mov    QWORD PTR [rsp+0xe8],r10
     2f8:	mov    QWORD PTR [rsp+0xf0],r11
     300:	mov    QWORD PTR [rsp+0xf8],rbx
     308:	mov    QWORD PTR [rsp+0x100],r12
     310:	mov    QWORD PTR [rsp+0x108],rax
     318:	mov    QWORD PTR [rsp+0x110],r13
     320:	mov    QWORD PTR [rsp+0x118],r14
     328:	mov    QWORD PTR [rsp+0x120],r15
     330:	mov    QWORD PTR [rsp+0x128],rcx
     338:	mov    QWORD PTR [rsp+0x130],rdx
     340:	mov    esi,0x10
     345:	mov    rdx,rdi
     348:	mov    rdi,QWORD PTR [rsp+0x180]
     350:	call   355 <botlish_fn_0+0x355>
			351: R_X86_64_PLT32	rt_list_new-0x4
     355:	test   rax,rax
     358:	je     57b <botlish_fn_0+0x57b>
     35e:	mov    QWORD PTR [rsp+0x8],rax
     363:	mov    rbx,rax
     366:	mov    QWORD PTR [rsp+0x10],0x16c
     36f:	mov    QWORD PTR [rsp+0x18],0x174
     378:	mov    QWORD PTR [rsp+0x20],0x2fc
     381:	mov    QWORD PTR [rsp+0x28],0x3f4
     38a:	lea    rdx,[rsp+0x138]
     392:	mov    QWORD PTR [rsp+0x138],0x16c
     39e:	mov    QWORD PTR [rsp+0x140],0x174
     3aa:	mov    QWORD PTR [rsp+0x148],0x2fc
     3b6:	mov    QWORD PTR [rsp+0x150],0x3f4
     3c2:	mov    esi,0x4
     3c7:	mov    rdi,QWORD PTR [rsp+0x180]
     3cf:	call   3d4 <botlish_fn_0+0x3d4>
			3d0: R_X86_64_PLT32	rt_list_new-0x4
     3d4:	test   rax,rax
     3d7:	je     57b <botlish_fn_0+0x57b>
     3dd:	mov    QWORD PTR [rsp+0x10],rax
     3e2:	mov    rsi,rax
     3e5:	mov    rdi,QWORD PTR [rsp+0x180]
     3ed:	call   3f2 <botlish_fn_0+0x3f2>
			3ee: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::set<List[UnicodeChar]>
     3f2:	test   rax,rax
     3f5:	je     57b <botlish_fn_0+0x57b>
     3fb:	mov    QWORD PTR [rsp+0x10],rax
     400:	lea    r8,[rsp+0x158]
     408:	mov    QWORD PTR [rsp+0x158],rax
     410:	mov    esi,0x11
     415:	mov    rdx,QWORD PTR [rip+0x0]        # 41c <botlish_fn_0+0x41c>
			418: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; web::is_unreserved<generic>
     41c:	mov    ecx,0x1
     421:	mov    rdi,QWORD PTR [rsp+0x180]
     429:	call   42e <botlish_fn_0+0x42e>
			42a: R_X86_64_PLT32	rt_closure_new-0x4
     42e:	mov    QWORD PTR [rsp+0x10],rax
     433:	lea    r8,[rsp+0x160]
     43b:	mov    rcx,rbx
     43e:	mov    QWORD PTR [rsp+0x160],rcx
     446:	mov    QWORD PTR [rsp+0x168],rax
     44e:	mov    esi,0x12
     453:	mov    rdx,QWORD PTR [rip+0x0]        # 45a <botlish_fn_0+0x45a>
			456: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; web::uri_escape_text<generic>
     45a:	mov    ecx,0x2
     45f:	mov    rdi,QWORD PTR [rsp+0x180]
     467:	call   46c <botlish_fn_0+0x46c>
			468: R_X86_64_PLT32	rt_closure_new-0x4
     46c:	mov    QWORD PTR [rsp+0x8],rax
     471:	mov    rdi,QWORD PTR [rsp+0x180]
     479:	mov    rcx,QWORD PTR [rdi+0x10]
     47d:	mov    rdx,QWORD PTR [rcx+0xa8]
     484:	mov    QWORD PTR [rsp+0x10],rdx
     489:	mov    rsi,rax
     48c:	call   491 <botlish_fn_0+0x491>
			48d: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::uri_escape_text<generic>
     491:	test   rax,rax
     494:	je     57b <botlish_fn_0+0x57b>
     49a:	mov    QWORD PTR [rsp+0x8],rax
     49f:	mov    r12,rax
     4a2:	mov    esi,0x321
     4a7:	mov    QWORD PTR [rsp+0x10],0x321
     4b0:	mov    edx,0x1
     4b5:	mov    QWORD PTR [rsp+0x18],0x1
     4be:	mov    rdi,QWORD PTR [rsp+0x180]
     4c6:	mov    rcx,QWORD PTR [rdi+0x10]
     4ca:	mov    rcx,QWORD PTR [rcx+0xb0]
     4d1:	mov    QWORD PTR [rsp+0x20],rcx
     4d6:	mov    r8,r12
     4d9:	mov    r9,QWORD PTR [rsp+0x1a8]
     4e1:	call   4e6 <botlish_fn_0+0x4e6>
			4e2: R_X86_64_PLT32	botlish_fn_24-0x4 ; check<generic>
     4e6:	mov    rbx,rax
     4e9:	test   rbx,rbx
     4ec:	je     57b <botlish_fn_0+0x57b>
     4f2:	mov    QWORD PTR [rsp+0x10],rbx
     4f7:	mov    esi,0x321
     4fc:	mov    QWORD PTR [rsp+0x18],0x321
     505:	mov    edx,0x1
     50a:	mov    QWORD PTR [rsp+0x20],0x1
     513:	mov    rdi,QWORD PTR [rsp+0x180]
     51b:	mov    rax,QWORD PTR [rdi+0x10]
     51f:	mov    rcx,QWORD PTR [rax+0xb8]
     526:	mov    QWORD PTR [rsp+0x28],rcx
     52b:	mov    r8,r12
     52e:	mov    r9,QWORD PTR [rsp+0x1a8]
     536:	call   53b <botlish_fn_0+0x53b>
			537: R_X86_64_PLT32	botlish_fn_24-0x4 ; check<generic>
     53b:	test   rax,rax
     53e:	je     57b <botlish_fn_0+0x57b>
     544:	mov    QWORD PTR [rsp],rax
     548:	lea    rdx,[rsp+0x170]
     550:	mov    QWORD PTR [rsp+0x170],rbx
     558:	mov    QWORD PTR [rsp+0x178],rax
     560:	mov    esi,0x2
     565:	mov    rdi,QWORD PTR [rsp+0x180]
     56d:	call   572 <botlish_fn_0+0x572>
			56e: R_X86_64_PLT32	rt_list_new-0x4
     572:	test   rax,rax
     575:	jne    5b2 <botlish_fn_0+0x5b2>
     57b:	xor    rax,rax
     57e:	mov    rbx,QWORD PTR [rsp+0x1b0]
     586:	mov    r12,QWORD PTR [rsp+0x1b8]
     58e:	mov    r13,QWORD PTR [rsp+0x1c0]
     596:	mov    r14,QWORD PTR [rsp+0x1c8]
     59e:	mov    r15,QWORD PTR [rsp+0x1d0]
     5a6:	add    rsp,0x1e0
     5ad:	mov    rsp,rbp
     5b0:	pop    rbp
     5b1:	ret
     5b2:	mov    rbx,QWORD PTR [rsp+0x1b0]
     5ba:	mov    r12,QWORD PTR [rsp+0x1b8]
     5c2:	mov    r13,QWORD PTR [rsp+0x1c0]
     5ca:	mov    r14,QWORD PTR [rsp+0x1c8]
     5d2:	mov    r15,QWORD PTR [rsp+0x1d0]
     5da:	add    rsp,0x1e0
     5e1:	mov    rsp,rbp
     5e4:	pop    rbp
     5e5:	ret

00000000000005e6 <botlish_entry_0: <program entry>>:
     5e6:	push   rbp
     5e7:	mov    rbp,rsp
     5ea:	call   5ef <botlish_entry_0+0x9>
			5eb: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     5ef:	mov    rsp,rbp
     5f2:	pop    rbp
     5f3:	ret

00000000000005f4 <botlish_fn_1: char::codepoint<UnicodeChar>>:
     5f4:	push   rbp
     5f5:	mov    rbp,rsp
     5f8:	call   5fd <botlish_fn_1+0x9>
			5f9: R_X86_64_PLT32	rt_char_codepoint-0x4
     5fd:	mov    rsp,rbp
     600:	pop    rbp
     601:	ret

0000000000000602 <botlish_entry_1: char::codepoint<UnicodeChar>>:
     602:	push   rbp
     603:	mov    rbp,rsp
     606:	mov    rsi,QWORD PTR [rdx]
     609:	call   60e <botlish_entry_1+0xc>
			60a: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     60e:	mov    rsp,rbp
     611:	pop    rbp
     612:	ret
     613:	add    BYTE PTR [rax],al
     615:	add    BYTE PTR [rax],al
	...

0000000000000618 <botlish_fn_2: byte::from_int<int>>:
     618:	push   rbp
     619:	mov    rbp,rsp
     61c:	sub    rsp,0x10
     620:	mov    QWORD PTR [rsp],rbx
     624:	mov    QWORD PTR [rsp+0x8],r12
     629:	mov    r12,rdi
     62c:	test   rsi,0x1
     633:	mov    rax,rsi
     636:	jne    665 <botlish_fn_2+0x4d>
     63c:	mov    edx,0x1
     641:	mov    rbx,rax
     644:	mov    rsi,rbx
     647:	mov    rdi,r12
     64a:	call   64f <botlish_fn_2+0x37>
			64b: R_X86_64_PLT32	rt_int_cmp-0x4
     64f:	mov    r8d,0x2
     655:	test   rax,rax
     658:	cmovl  r8,QWORD PTR [rip+0xb0]        # 710 <botlish_fn_2+0xf8>
     660:	jmp    679 <botlish_fn_2+0x61>
     665:	mov    rbx,rax
     668:	mov    r8d,0x2
     66e:	test   rbx,rbx
     671:	cmovle r8,QWORD PTR [rip+0x97]        # 710 <botlish_fn_2+0xf8>
     679:	test   rbx,0x1
     680:	jne    6ab <botlish_fn_2+0x93>
     686:	mov    edx,0x1ff
     68b:	mov    rsi,rbx
     68e:	mov    rdi,r12
     691:	call   696 <botlish_fn_2+0x7e>
			692: R_X86_64_PLT32	rt_int_cmp-0x4
     696:	mov    ecx,0x2
     69b:	test   rax,rax
     69e:	cmovg  rcx,QWORD PTR [rip+0x6a]        # 710 <botlish_fn_2+0xf8>
     6a6:	jmp    6bf <botlish_fn_2+0xa7>
     6ab:	mov    ecx,0x2
     6b0:	cmp    rbx,0x1ff
     6b7:	cmovg  rcx,QWORD PTR [rip+0x51]        # 710 <botlish_fn_2+0xf8>
     6bf:	cmp    rcx,0x6
     6c3:	je     6de <botlish_fn_2+0xc6>
     6c9:	mov    rax,rbx
     6cc:	mov    rbx,QWORD PTR [rsp]
     6d0:	mov    r12,QWORD PTR [rsp+0x8]
     6d5:	add    rsp,0x10
     6d9:	mov    rsp,rbp
     6dc:	pop    rbp
     6dd:	ret
     6de:	mov    rdi,r12
     6e1:	mov    rax,QWORD PTR [rdi+0x10]
     6e5:	mov    rdx,QWORD PTR [rax+0xc0]
     6ec:	mov    esi,0x2
     6f1:	call   6f6 <botlish_fn_2+0xde>
			6f2: R_X86_64_PLT32	rt_fail_declared-0x4
     6f6:	xor    rax,rax
     6f9:	mov    rbx,QWORD PTR [rsp]
     6fd:	mov    r12,QWORD PTR [rsp+0x8]
     702:	add    rsp,0x10
     706:	mov    rsp,rbp
     709:	pop    rbp
     70a:	ret
     70b:	add    BYTE PTR [rax],al
     70d:	add    BYTE PTR [rax],al
     70f:	add    BYTE PTR [rsi],al
     711:	add    BYTE PTR [rax],al
     713:	add    BYTE PTR [rax],al
     715:	add    BYTE PTR [rax],al
	...

0000000000000718 <botlish_entry_2: byte::from_int<int>>:
     718:	push   rbp
     719:	mov    rbp,rsp
     71c:	mov    rsi,QWORD PTR [rdx]
     71f:	call   724 <botlish_entry_2+0xc>
			720: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     724:	mov    rsp,rbp
     727:	pop    rbp
     728:	ret
     729:	add    BYTE PTR [rax],al
     72b:	add    BYTE PTR [rax],al
     72d:	add    BYTE PTR [rax],al
	...

0000000000000730 <botlish_fn_3: byte::set<List[UnicodeChar]>>:
     730:	push   rbp
     731:	mov    rbp,rsp
     734:	sub    rsp,0x60
     738:	mov    QWORD PTR [rsp+0x30],rbx
     73d:	mov    QWORD PTR [rsp+0x38],r12
     742:	mov    QWORD PTR [rsp+0x40],r13
     747:	mov    QWORD PTR [rsp+0x48],r14
     74c:	mov    QWORD PTR [rsp+0x50],r15
     751:	mov    r13,rdi
     754:	mov    QWORD PTR [rsp+0x18],0x0
     75d:	mov    QWORD PTR [rsp+0x20],0x0
     766:	mov    QWORD PTR [rsp],rsi
     76a:	mov    rbx,rsi
     76d:	mov    rdi,r13
     770:	call   775 <botlish_fn_3+0x45>
			771: R_X86_64_PLT32	rt_list_len-0x4
     775:	mov    QWORD PTR [rsp+0x8],rax
     77a:	mov    r12,rax
     77d:	mov    QWORD PTR [rsp+0x10],0x1
     786:	xor    rdx,rdx
     789:	mov    rdi,r13
     78c:	mov    rsi,rdx
     78f:	call   794 <botlish_fn_3+0x64>
			790: R_X86_64_PLT32	rt_list_new-0x4
     794:	test   rax,rax
     797:	je     8c1 <botlish_fn_3+0x191>
     79d:	mov    esi,0x1
     7a2:	mov    r14,rsi
     7a5:	mov    QWORD PTR [rsp+0x10],0x1
     7ae:	mov    QWORD PTR [rsp+0x18],rax
     7b3:	mov    r15,rax
     7b6:	mov    rax,rsi
     7b9:	and    rax,r12
     7bc:	mov    r14,rsi
     7bf:	test   rax,0x1
     7c5:	jne    7ee <botlish_fn_3+0xbe>
     7cb:	mov    rdx,r12
     7ce:	mov    rsi,r14
     7d1:	mov    rdi,r13
     7d4:	call   7d9 <botlish_fn_3+0xa9>
			7d5: R_X86_64_PLT32	rt_int_cmp-0x4
     7d9:	mov    ecx,0x2
     7de:	test   rax,rax
     7e1:	cmovl  rcx,QWORD PTR [rip+0x16f]        # 958 <botlish_fn_3+0x228>
     7e9:	jmp    801 <botlish_fn_3+0xd1>
     7ee:	mov    ecx,0x2
     7f3:	mov    rsi,r14
     7f6:	cmp    rsi,r12
     7f9:	cmovl  rcx,QWORD PTR [rip+0x157]        # 958 <botlish_fn_3+0x228>
     801:	cmp    rcx,0x6
     805:	je     83c <botlish_fn_3+0x10c>
     80b:	mov    rsi,r15
     80e:	mov    QWORD PTR [rsp],rsi
     812:	mov    rdi,r13
     815:	call   81a <botlish_fn_3+0xea>
			816: R_X86_64_PLT32	rt_set_from_list-0x4
     81a:	mov    rbx,QWORD PTR [rsp+0x30]
     81f:	mov    r12,QWORD PTR [rsp+0x38]
     824:	mov    r13,QWORD PTR [rsp+0x40]
     829:	mov    r14,QWORD PTR [rsp+0x48]
     82e:	mov    r15,QWORD PTR [rsp+0x50]
     833:	add    rsp,0x60
     837:	mov    rsp,rbp
     83a:	pop    rbp
     83b:	ret
     83c:	mov    rsi,r14
     83f:	test   rsi,0x1
     846:	je     862 <botlish_fn_3+0x132>
     84c:	mov    rcx,QWORD PTR [rbx+0x8]
     850:	mov    rsi,r14
     853:	mov    rax,rsi
     856:	sar    rax,1
     859:	cmp    rax,rcx
     85c:	jb     881 <botlish_fn_3+0x151>
     862:	mov    rdx,r14
     865:	mov    rsi,rbx
     868:	mov    rdi,r13
     86b:	call   870 <botlish_fn_3+0x140>
			86c: R_X86_64_PLT32	rt_list_get-0x4
     870:	test   rax,rax
     873:	je     8c1 <botlish_fn_3+0x191>
     879:	mov    rsi,rax
     87c:	jmp    889 <botlish_fn_3+0x159>
     881:	mov    rsi,QWORD PTR [rbx+0x10]
     885:	mov    rsi,QWORD PTR [rsi+rax*8]
     889:	mov    rdi,r13
     88c:	call   891 <botlish_fn_3+0x161>
			88d: R_X86_64_PLT32	botlish_fn_1-0x4 ; char::codepoint<UnicodeChar>
     891:	mov    rsi,rax
     894:	mov    rdi,r13
     897:	call   89c <botlish_fn_3+0x16c>
			898: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::from_int<int>
     89c:	test   rax,rax
     89f:	je     8c1 <botlish_fn_3+0x191>
     8a5:	mov    QWORD PTR [rsp+0x20],rax
     8aa:	mov    rdx,rax
     8ad:	mov    rsi,r15
     8b0:	mov    rdi,r13
     8b3:	call   8b8 <botlish_fn_3+0x188>
			8b4: R_X86_64_PLT32	rt_list_append-0x4
     8b8:	test   rax,rax
     8bb:	jne    8e6 <botlish_fn_3+0x1b6>
     8c1:	xor    rax,rax
     8c4:	mov    rbx,QWORD PTR [rsp+0x30]
     8c9:	mov    r12,QWORD PTR [rsp+0x38]
     8ce:	mov    r13,QWORD PTR [rsp+0x40]
     8d3:	mov    r14,QWORD PTR [rsp+0x48]
     8d8:	mov    r15,QWORD PTR [rsp+0x50]
     8dd:	add    rsp,0x60
     8e1:	mov    rsp,rbp
     8e4:	pop    rbp
     8e5:	ret
     8e6:	mov    QWORD PTR [rsp+0x18],rax
     8eb:	mov    r15,rax
     8ee:	mov    edx,0x3
     8f3:	mov    QWORD PTR [rsp+0x20],0x3
     8fc:	mov    rsi,r14
     8ff:	test   rsi,0x1
     906:	jne    914 <botlish_fn_3+0x1e4>
     90c:	mov    rsi,r14
     90f:	jmp    93c <botlish_fn_3+0x20c>
     914:	mov    rsi,r14
     917:	mov    rcx,rsi
     91a:	add    rcx,0x2
     91e:	seto   al
     921:	test   al,al
     923:	je     931 <botlish_fn_3+0x201>
     929:	mov    rsi,r14
     92c:	jmp    93c <botlish_fn_3+0x20c>
     931:	mov    rsi,rcx
     934:	mov    r14,rcx
     937:	jmp    94a <botlish_fn_3+0x21a>
     93c:	mov    rdi,r13
     93f:	call   944 <botlish_fn_3+0x214>
			940: R_X86_64_PLT32	rt_int_add-0x4
     944:	mov    rsi,rax
     947:	mov    r14,rax
     94a:	mov    QWORD PTR [rsp+0x10],rsi
     94f:	mov    rsi,r14
     952:	jmp    7b6 <botlish_fn_3+0x86>
     957:	add    BYTE PTR [rsi],al
     959:	add    BYTE PTR [rax],al
     95b:	add    BYTE PTR [rax],al
     95d:	add    BYTE PTR [rax],al
	...

0000000000000960 <botlish_entry_3: byte::set<List[UnicodeChar]>>:
     960:	push   rbp
     961:	mov    rbp,rsp
     964:	mov    rsi,QWORD PTR [rdx]
     967:	call   96c <botlish_entry_3+0xc>
			968: R_X86_64_PLT32	botlish_fn_3-0x4 ; byte::set<List[UnicodeChar]>
     96c:	mov    rsp,rbp
     96f:	pop    rbp
     970:	ret

0000000000000971 <botlish_fn_4: ascii::is_digit<int>>:
     971:	push   rbp
     972:	mov    rbp,rsp
     975:	sar    rsi,1
     978:	cmp    rsi,0x30
     97c:	jge    98c <botlish_fn_4+0x1b>
     982:	mov    eax,0x2
     987:	jmp    9a5 <botlish_fn_4+0x34>
     98c:	cmp    rsi,0x39
     990:	jle    9a0 <botlish_fn_4+0x2f>
     996:	mov    eax,0x2
     99b:	jmp    9a5 <botlish_fn_4+0x34>
     9a0:	mov    eax,0x6
     9a5:	mov    rsp,rbp
     9a8:	pop    rbp
     9a9:	ret

00000000000009aa <botlish_entry_4: ascii::is_digit<int>>:
     9aa:	push   rbp
     9ab:	mov    rbp,rsp
     9ae:	mov    rsi,QWORD PTR [rdx]
     9b1:	call   9b6 <botlish_entry_4+0xc>
			9b2: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     9b6:	mov    rsp,rbp
     9b9:	pop    rbp
     9ba:	ret

00000000000009bb <botlish_fn_5: ascii::is_upper<int>>:
     9bb:	push   rbp
     9bc:	mov    rbp,rsp
     9bf:	sar    rsi,1
     9c2:	cmp    rsi,0x41
     9c6:	jge    9d6 <botlish_fn_5+0x1b>
     9cc:	mov    eax,0x2
     9d1:	jmp    9ef <botlish_fn_5+0x34>
     9d6:	cmp    rsi,0x5a
     9da:	jle    9ea <botlish_fn_5+0x2f>
     9e0:	mov    eax,0x2
     9e5:	jmp    9ef <botlish_fn_5+0x34>
     9ea:	mov    eax,0x6
     9ef:	mov    rsp,rbp
     9f2:	pop    rbp
     9f3:	ret

00000000000009f4 <botlish_entry_5: ascii::is_upper<int>>:
     9f4:	push   rbp
     9f5:	mov    rbp,rsp
     9f8:	mov    rsi,QWORD PTR [rdx]
     9fb:	call   a00 <botlish_entry_5+0xc>
			9fc: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     a00:	mov    rsp,rbp
     a03:	pop    rbp
     a04:	ret

0000000000000a05 <botlish_fn_6: ascii::is_lower<int>>:
     a05:	push   rbp
     a06:	mov    rbp,rsp
     a09:	sar    rsi,1
     a0c:	cmp    rsi,0x61
     a10:	jge    a20 <botlish_fn_6+0x1b>
     a16:	mov    eax,0x2
     a1b:	jmp    a39 <botlish_fn_6+0x34>
     a20:	cmp    rsi,0x7a
     a24:	jle    a34 <botlish_fn_6+0x2f>
     a2a:	mov    eax,0x2
     a2f:	jmp    a39 <botlish_fn_6+0x34>
     a34:	mov    eax,0x6
     a39:	mov    rsp,rbp
     a3c:	pop    rbp
     a3d:	ret

0000000000000a3e <botlish_entry_6: ascii::is_lower<int>>:
     a3e:	push   rbp
     a3f:	mov    rbp,rsp
     a42:	mov    rsi,QWORD PTR [rdx]
     a45:	call   a4a <botlish_entry_6+0xc>
			a46: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     a4a:	mov    rsp,rbp
     a4d:	pop    rbp
     a4e:	ret

0000000000000a4f <botlish_fn_7: ascii::is_alphabetic<int>>:
     a4f:	push   rbp
     a50:	mov    rbp,rsp
     a53:	sub    rsp,0x10
     a57:	mov    QWORD PTR [rsp],r12
     a5b:	mov    QWORD PTR [rsp+0x8],r14
     a60:	mov    r12,rsi
     a63:	mov    r14,rdi
     a66:	mov    rsi,r12
     a69:	mov    rdi,r14
     a6c:	call   a71 <botlish_fn_7+0x22>
			a6d: R_X86_64_PLT32	botlish_fn_5-0x4 ; ascii::is_upper<int>
     a71:	cmp    rax,0x6
     a75:	je     aa4 <botlish_fn_7+0x55>
     a7b:	mov    rsi,r12
     a7e:	mov    rdi,r14
     a81:	call   a86 <botlish_fn_7+0x37>
			a82: R_X86_64_PLT32	botlish_fn_6-0x4 ; ascii::is_lower<int>
     a86:	cmp    rax,0x6
     a8a:	je     a9a <botlish_fn_7+0x4b>
     a90:	mov    eax,0x2
     a95:	jmp    aa9 <botlish_fn_7+0x5a>
     a9a:	mov    eax,0x6
     a9f:	jmp    aa9 <botlish_fn_7+0x5a>
     aa4:	mov    eax,0x6
     aa9:	mov    r12,QWORD PTR [rsp]
     aad:	mov    r14,QWORD PTR [rsp+0x8]
     ab2:	add    rsp,0x10
     ab6:	mov    rsp,rbp
     ab9:	pop    rbp
     aba:	ret

0000000000000abb <botlish_entry_7: ascii::is_alphabetic<int>>:
     abb:	push   rbp
     abc:	mov    rbp,rsp
     abf:	mov    rsi,QWORD PTR [rdx]
     ac2:	call   ac7 <botlish_entry_7+0xc>
			ac3: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     ac7:	mov    rsp,rbp
     aca:	pop    rbp
     acb:	ret

0000000000000acc <botlish_fn_8: ascii::is_alphanumeric<int>>:
     acc:	push   rbp
     acd:	mov    rbp,rsp
     ad0:	sub    rsp,0x10
     ad4:	mov    QWORD PTR [rsp],r12
     ad8:	mov    QWORD PTR [rsp+0x8],r14
     add:	mov    r12,rsi
     ae0:	mov    r14,rdi
     ae3:	mov    rsi,r12
     ae6:	mov    rdi,r14
     ae9:	call   aee <botlish_fn_8+0x22>
			aea: R_X86_64_PLT32	botlish_fn_7-0x4 ; ascii::is_alphabetic<int>
     aee:	cmp    rax,0x6
     af2:	je     b21 <botlish_fn_8+0x55>
     af8:	mov    rsi,r12
     afb:	mov    rdi,r14
     afe:	call   b03 <botlish_fn_8+0x37>
			aff: R_X86_64_PLT32	botlish_fn_4-0x4 ; ascii::is_digit<int>
     b03:	cmp    rax,0x6
     b07:	je     b17 <botlish_fn_8+0x4b>
     b0d:	mov    eax,0x2
     b12:	jmp    b26 <botlish_fn_8+0x5a>
     b17:	mov    eax,0x6
     b1c:	jmp    b26 <botlish_fn_8+0x5a>
     b21:	mov    eax,0x6
     b26:	mov    r12,QWORD PTR [rsp]
     b2a:	mov    r14,QWORD PTR [rsp+0x8]
     b2f:	add    rsp,0x10
     b33:	mov    rsp,rbp
     b36:	pop    rbp
     b37:	ret

0000000000000b38 <botlish_entry_8: ascii::is_alphanumeric<int>>:
     b38:	push   rbp
     b39:	mov    rbp,rsp
     b3c:	mov    rsi,QWORD PTR [rdx]
     b3f:	call   b44 <botlish_entry_8+0xc>
			b40: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
     b44:	mov    rsp,rbp
     b47:	pop    rbp
     b48:	ret
     b49:	add    BYTE PTR [rax],al
     b4b:	add    BYTE PTR [rax],al
     b4d:	add    BYTE PTR [rax],al
	...

0000000000000b50 <botlish_fn_9: web::is_emailish<generic>>:
     b50:	push   rbp
     b51:	mov    rbp,rsp
     b54:	sub    rsp,0x70
     b58:	mov    QWORD PTR [rsp+0x40],rbx
     b5d:	mov    QWORD PTR [rsp+0x48],r12
     b62:	mov    QWORD PTR [rsp+0x50],r13
     b67:	mov    QWORD PTR [rsp+0x58],r14
     b6c:	mov    QWORD PTR [rsp+0x60],r15
     b71:	mov    r12,rsi
     b74:	mov    QWORD PTR [rsp+0x18],0x0
     b7d:	mov    QWORD PTR [rsp],rdx
     b81:	xor    r8d,r8d
     b84:	test   rdx,0x7
     b8b:	je     b99 <botlish_fn_9+0x49>
     b91:	mov    r14,rdx
     b94:	jmp    ba8 <botlish_fn_9+0x58>
     b99:	movzx  rsi,BYTE PTR [rdx]
     b9d:	mov    r14,rdx
     ba0:	cmp    sil,0x2
     ba4:	sete   r8b
     ba8:	test   r8b,r8b
     bab:	jne    bce <botlish_fn_9+0x7e>
     bb1:	mov    r9,QWORD PTR [rdi+0x10]
     bb5:	mov    rcx,QWORD PTR [r9+0xc8]
     bbc:	mov    edx,0x1
     bc1:	mov    rsi,r14
     bc4:	call   bc9 <botlish_fn_9+0x79>
			bc5: R_X86_64_PLT32	rt_type_error-0x4
     bc9:	jmp    d93 <botlish_fn_9+0x243>
     bce:	mov    r15,rdi
     bd1:	mov    rsi,r14
     bd4:	call   bd9 <botlish_fn_9+0x89>
			bd5: R_X86_64_PLT32	rt_str_len-0x4
     bd9:	mov    rbx,rax
     bdc:	mov    QWORD PTR [rsp+0x8],rax
     be1:	mov    rsi,r12
     be4:	mov    r11,QWORD PTR [rsi+0x20]
     be8:	mov    r11,QWORD PTR [r11]
     beb:	mov    QWORD PTR [rsp+0x10],r11
     bf0:	lea    r8,[rsp+0x20]
     bf5:	mov    QWORD PTR [rsp+0x20],r11
     bfa:	mov    esi,0xc
     bff:	mov    rdx,QWORD PTR [rip+0x0]        # c06 <botlish_fn_9+0xb6>
			c02: R_X86_64_GOTPCREL	botlish_entry_12-0x4 ; is_local_char<generic>
     c06:	mov    r13d,0x1
     c0c:	mov    rcx,r13
     c0f:	mov    rdi,r15
     c12:	call   c17 <botlish_fn_9+0xc7>
			c13: R_X86_64_PLT32	rt_closure_new-0x4
     c17:	mov    QWORD PTR [rsp+0x10],rax
     c1c:	mov    QWORD PTR [rsp+0x18],0x1
     c25:	mov    rdx,rax
     c28:	mov    rcx,rbx
     c2b:	mov    rsi,r13
     c2e:	mov    rdi,r15
     c31:	mov    r8,r14
     c34:	call   c39 <botlish_fn_9+0xe9>
			c35: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<generic>
     c39:	mov    rcx,rax
     c3c:	mov    r12,rax
     c3f:	test   rax,rcx
     c42:	je     d93 <botlish_fn_9+0x243>
     c48:	mov    rax,r12
     c4b:	mov    QWORD PTR [rsp+0x10],rax
     c50:	test   rax,0x1
     c56:	jne    c7f <botlish_fn_9+0x12f>
     c5c:	mov    rdx,r13
     c5f:	mov    rsi,r12
     c62:	mov    rdi,r15
     c65:	call   c6a <botlish_fn_9+0x11a>
			c66: R_X86_64_PLT32	rt_int_cmp-0x4
     c6a:	mov    ecx,0x2
     c6f:	test   rax,rax
     c72:	cmove  rcx,QWORD PTR [rip+0x1c6]        # e40 <botlish_fn_9+0x2f0>
     c7a:	jmp    c90 <botlish_fn_9+0x140>
     c7f:	mov    ecx,0x2
     c84:	cmp    r12,0x1
     c88:	cmove  rcx,QWORD PTR [rip+0x1b0]        # e40 <botlish_fn_9+0x2f0>
     c90:	cmp    rcx,0x6
     c94:	je     e13 <botlish_fn_9+0x2c3>
     c9a:	mov    rax,r12
     c9d:	and    rax,rbx
     ca0:	test   rax,0x1
     ca6:	jne    ccf <botlish_fn_9+0x17f>
     cac:	mov    rdx,rbx
     caf:	mov    rsi,r12
     cb2:	mov    rdi,r15
     cb5:	call   cba <botlish_fn_9+0x16a>
			cb6: R_X86_64_PLT32	rt_int_cmp-0x4
     cba:	mov    ecx,0x2
     cbf:	test   rax,rax
     cc2:	cmovge rcx,QWORD PTR [rip+0x176]        # e40 <botlish_fn_9+0x2f0>
     cca:	jmp    cdf <botlish_fn_9+0x18f>
     ccf:	mov    ecx,0x2
     cd4:	cmp    r12,rbx
     cd7:	cmovge rcx,QWORD PTR [rip+0x161]        # e40 <botlish_fn_9+0x2f0>
     cdf:	cmp    rcx,0x6
     ce3:	je     e09 <botlish_fn_9+0x2b9>
     ce9:	lea    rcx,[rsp+0x28]
     cee:	mov    rdx,r14
     cf1:	mov    rsi,r12
     cf4:	mov    rdi,r15
     cf7:	call   cfc <botlish_fn_9+0x1ac>
			cf8: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
     cfc:	test   rax,rax
     cff:	mov    rsi,rax
     d02:	je     d93 <botlish_fn_9+0x243>
     d08:	mov    rdx,QWORD PTR [rsp+0x28]
     d0d:	mov    rcx,QWORD PTR [rsp+0x30]
     d12:	mov    rdi,r15
     d15:	mov    rax,QWORD PTR [rdi+0x10]
     d19:	mov    r8,QWORD PTR [rax+0xd0]
     d20:	call   d25 <botlish_fn_9+0x1d5>
			d21: R_X86_64_PLT32	rt_str_region_eq-0x4
     d25:	cmp    rax,0x6
     d29:	je     d3c <botlish_fn_9+0x1ec>
     d2f:	mov    ecx,0x2
     d34:	mov    rax,rcx
     d37:	jmp    e18 <botlish_fn_9+0x2c8>
     d3c:	mov    QWORD PTR [rsp+0x18],0x3
     d45:	test   r12,0x1
     d4c:	je     d64 <botlish_fn_9+0x214>
     d52:	mov    rsi,r12
     d55:	add    rsi,0x2
     d59:	seto   al
     d5c:	test   al,al
     d5e:	je     d77 <botlish_fn_9+0x227>
     d64:	mov    edx,0x3
     d69:	mov    rsi,r12
     d6c:	mov    rdi,r15
     d6f:	call   d74 <botlish_fn_9+0x224>
			d70: R_X86_64_PLT32	rt_int_add-0x4
     d74:	mov    rsi,rax
     d77:	mov    QWORD PTR [rsp+0x10],rsi
     d7c:	mov    rcx,r14
     d7f:	mov    rdx,rbx
     d82:	mov    rdi,r15
     d85:	call   d8a <botlish_fn_9+0x23a>
			d86: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain_loop<generic>
     d8a:	test   rax,rax
     d8d:	jne    db8 <botlish_fn_9+0x268>
     d93:	xor    rax,rax
     d96:	mov    rbx,QWORD PTR [rsp+0x40]
     d9b:	mov    r12,QWORD PTR [rsp+0x48]
     da0:	mov    r13,QWORD PTR [rsp+0x50]
     da5:	mov    r14,QWORD PTR [rsp+0x58]
     daa:	mov    r15,QWORD PTR [rsp+0x60]
     daf:	add    rsp,0x70
     db3:	mov    rsp,rbp
     db6:	pop    rbp
     db7:	ret
     db8:	mov    rcx,rax
     dbb:	and    rcx,rbx
     dbe:	mov    rsi,rax
     dc1:	test   rcx,0x1
     dc8:	jne    df1 <botlish_fn_9+0x2a1>
     dce:	mov    rdx,rbx
     dd1:	mov    rdi,r15
     dd4:	call   dd9 <botlish_fn_9+0x289>
			dd5: R_X86_64_PLT32	rt_int_cmp-0x4
     dd9:	mov    ecx,0x2
     dde:	test   rax,rax
     de1:	mov    rax,rcx
     de4:	cmove  rax,QWORD PTR [rip+0x54]        # e40 <botlish_fn_9+0x2f0>
     dec:	jmp    e18 <botlish_fn_9+0x2c8>
     df1:	mov    rdx,rbx
     df4:	mov    eax,0x2
     df9:	cmp    rsi,rdx
     dfc:	cmove  rax,QWORD PTR [rip+0x3c]        # e40 <botlish_fn_9+0x2f0>
     e04:	jmp    e18 <botlish_fn_9+0x2c8>
     e09:	mov    eax,0x2
     e0e:	jmp    e18 <botlish_fn_9+0x2c8>
     e13:	mov    eax,0x2
     e18:	mov    rbx,QWORD PTR [rsp+0x40]
     e1d:	mov    r12,QWORD PTR [rsp+0x48]
     e22:	mov    r13,QWORD PTR [rsp+0x50]
     e27:	mov    r14,QWORD PTR [rsp+0x58]
     e2c:	mov    r15,QWORD PTR [rsp+0x60]
     e31:	add    rsp,0x70
     e35:	mov    rsp,rbp
     e38:	pop    rbp
     e39:	ret
     e3a:	add    BYTE PTR [rax],al
     e3c:	add    BYTE PTR [rax],al
     e3e:	add    BYTE PTR [rax],al
     e40:	(bad)
     e41:	add    BYTE PTR [rax],al
     e43:	add    BYTE PTR [rax],al
     e45:	add    BYTE PTR [rax],al
	...

0000000000000e48 <botlish_entry_9: web::is_emailish<generic>>:
     e48:	push   rbp
     e49:	mov    rbp,rsp
     e4c:	mov    rdx,QWORD PTR [rdx]
     e4f:	call   e54 <botlish_entry_9+0xc>
			e50: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_emailish<generic>
     e54:	mov    rsp,rbp
     e57:	pop    rbp
     e58:	ret

0000000000000e59 <botlish_fn_10: char_at<generic>>:
     e59:	push   rbp
     e5a:	mov    rbp,rsp
     e5d:	sub    rsp,0x50
     e61:	mov    QWORD PTR [rsp+0x20],rbx
     e66:	mov    QWORD PTR [rsp+0x28],r12
     e6b:	mov    QWORD PTR [rsp+0x30],r13
     e70:	mov    QWORD PTR [rsp+0x38],r14
     e75:	mov    QWORD PTR [rsp+0x40],r15
     e7a:	mov    r12,rdi
     e7d:	mov    r15,rcx
     e80:	mov    QWORD PTR [rsp],rsi
     e84:	mov    QWORD PTR [rsp+0x8],rdx
     e89:	mov    r13,rdx
     e8c:	mov    QWORD PTR [rsp+0x10],0x3
     e95:	test   rsi,0x1
     e9c:	jne    eaa <botlish_fn_10+0x51>
     ea2:	mov    rbx,rsi
     ea5:	jmp    eca <botlish_fn_10+0x71>
     eaa:	mov    rax,rsi
     ead:	add    rax,0x2
     eb1:	mov    rbx,rsi
     eb4:	seto   cl
     eb7:	test   cl,cl
     eb9:	jne    eca <botlish_fn_10+0x71>
     ebf:	mov    rdi,r12
     ec2:	mov    r14,rax
     ec5:	jmp    ee0 <botlish_fn_10+0x87>
     eca:	mov    edx,0x3
     ecf:	mov    rsi,rbx
     ed2:	mov    rdi,r12
     ed5:	call   eda <botlish_fn_10+0x81>
			ed6: R_X86_64_PLT32	rt_int_add-0x4
     eda:	mov    r14,rax
     edd:	mov    rdi,r12
     ee0:	mov    rcx,r14
     ee3:	mov    rdx,rbx
     ee6:	mov    rsi,r13
     ee9:	call   eee <botlish_fn_10+0x95>
			eea: R_X86_64_PLT32	rt_str_region_check-0x4
     eee:	test   rax,rax
     ef1:	jne    f1c <botlish_fn_10+0xc3>
     ef7:	xor    rax,rax
     efa:	mov    rbx,QWORD PTR [rsp+0x20]
     eff:	mov    r12,QWORD PTR [rsp+0x28]
     f04:	mov    r13,QWORD PTR [rsp+0x30]
     f09:	mov    r14,QWORD PTR [rsp+0x38]
     f0e:	mov    r15,QWORD PTR [rsp+0x40]
     f13:	add    rsp,0x50
     f17:	mov    rsp,rbp
     f1a:	pop    rbp
     f1b:	ret
     f1c:	mov    rcx,r15
     f1f:	mov    QWORD PTR [rcx],rbx
     f22:	mov    rax,r14
     f25:	mov    QWORD PTR [rcx+0x8],rax
     f29:	mov    rax,r13
     f2c:	mov    rbx,QWORD PTR [rsp+0x20]
     f31:	mov    r12,QWORD PTR [rsp+0x28]
     f36:	mov    r13,QWORD PTR [rsp+0x30]
     f3b:	mov    r14,QWORD PTR [rsp+0x38]
     f40:	mov    r15,QWORD PTR [rsp+0x40]
     f45:	add    rsp,0x50
     f49:	mov    rsp,rbp
     f4c:	pop    rbp
     f4d:	ret

0000000000000f4e <botlish_entry_10: char_at<generic>>:
     f4e:	push   rbp
     f4f:	mov    rbp,rsp
     f52:	ud2

0000000000000f54 <botlish_fn_11: char_at<generic>>:
     f54:	push   rbp
     f55:	mov    rbp,rsp
     f58:	sub    rsp,0x40
     f5c:	mov    QWORD PTR [rsp+0x20],rbx
     f61:	mov    QWORD PTR [rsp+0x28],r12
     f66:	mov    QWORD PTR [rsp+0x30],r13
     f6b:	mov    r12,rdi
     f6e:	mov    QWORD PTR [rsp],rsi
     f72:	mov    QWORD PTR [rsp+0x8],rdx
     f77:	mov    r13,rdx
     f7a:	mov    QWORD PTR [rsp+0x10],0x3
     f83:	test   rsi,0x1
     f8a:	jne    f98 <botlish_fn_11+0x44>
     f90:	mov    rbx,rsi
     f93:	jmp    fad <botlish_fn_11+0x59>
     f98:	mov    rcx,rsi
     f9b:	add    rcx,0x2
     f9f:	mov    rbx,rsi
     fa2:	seto   al
     fa5:	test   al,al
     fa7:	je     fc0 <botlish_fn_11+0x6c>
     fad:	mov    edx,0x3
     fb2:	mov    rsi,rbx
     fb5:	mov    rdi,r12
     fb8:	call   fbd <botlish_fn_11+0x69>
			fb9: R_X86_64_PLT32	rt_int_add-0x4
     fbd:	mov    rcx,rax
     fc0:	mov    QWORD PTR [rsp+0x10],rcx
     fc5:	mov    rdx,rbx
     fc8:	mov    rsi,r13
     fcb:	mov    rdi,r12
     fce:	call   fd3 <botlish_fn_11+0x7f>
			fcf: R_X86_64_PLT32	rt_substr-0x4
     fd3:	test   rax,rax
     fd6:	jne    ff7 <botlish_fn_11+0xa3>
     fdc:	xor    rax,rax
     fdf:	mov    rbx,QWORD PTR [rsp+0x20]
     fe4:	mov    r12,QWORD PTR [rsp+0x28]
     fe9:	mov    r13,QWORD PTR [rsp+0x30]
     fee:	add    rsp,0x40
     ff2:	mov    rsp,rbp
     ff5:	pop    rbp
     ff6:	ret
     ff7:	mov    rbx,QWORD PTR [rsp+0x20]
     ffc:	mov    r12,QWORD PTR [rsp+0x28]
    1001:	mov    r13,QWORD PTR [rsp+0x30]
    1006:	add    rsp,0x40
    100a:	mov    rsp,rbp
    100d:	pop    rbp
    100e:	ret

000000000000100f <botlish_entry_11: char_at<generic>>:
    100f:	push   rbp
    1010:	mov    rbp,rsp
    1013:	mov    rsi,QWORD PTR [rdx]
    1016:	mov    rdx,QWORD PTR [rdx+0x8]
    101a:	call   101f <botlish_entry_11+0x10>
			101b: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    101f:	mov    rsp,rbp
    1022:	pop    rbp
    1023:	ret

0000000000001024 <botlish_fn_12: is_local_char<generic>>:
    1024:	push   rbp
    1025:	mov    rbp,rsp
    1028:	sub    rsp,0x20
    102c:	mov    QWORD PTR [rsp],rbx
    1030:	mov    QWORD PTR [rsp+0x8],r12
    1035:	mov    QWORD PTR [rsp+0x10],r13
    103a:	mov    r12,rsi
    103d:	xor    esi,esi
    103f:	test   rdx,0x7
    1046:	je     1054 <botlish_fn_12+0x30>
    104c:	mov    rbx,rdx
    104f:	jmp    1061 <botlish_fn_12+0x3d>
    1054:	movzx  rax,BYTE PTR [rdx]
    1058:	mov    rbx,rdx
    105b:	cmp    al,0x2
    105d:	sete   sil
    1061:	test   sil,sil
    1064:	jne    1087 <botlish_fn_12+0x63>
    106a:	mov    rax,QWORD PTR [rdi+0x10]
    106e:	mov    rcx,QWORD PTR [rax+0xd8]
    1075:	mov    edx,0x1
    107a:	mov    rsi,rbx
    107d:	call   1082 <botlish_fn_12+0x5e>
			107e: R_X86_64_PLT32	rt_type_error-0x4
    1082:	jmp    109b <botlish_fn_12+0x77>
    1087:	mov    r13,rdi
    108a:	mov    rsi,rbx
    108d:	call   1092 <botlish_fn_12+0x6e>
			108e: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    1092:	test   rax,rax
    1095:	jne    10b5 <botlish_fn_12+0x91>
    109b:	xor    rax,rax
    109e:	mov    rbx,QWORD PTR [rsp]
    10a2:	mov    r12,QWORD PTR [rsp+0x8]
    10a7:	mov    r13,QWORD PTR [rsp+0x10]
    10ac:	add    rsp,0x20
    10b0:	mov    rsp,rbp
    10b3:	pop    rbp
    10b4:	ret
    10b5:	cmp    rax,0x6
    10b9:	je     10f2 <botlish_fn_12+0xce>
    10bf:	mov    rsi,r12
    10c2:	mov    rax,QWORD PTR [rsi+0x20]
    10c6:	mov    rsi,QWORD PTR [rax]
    10c9:	mov    rdx,rbx
    10cc:	mov    rdi,r13
    10cf:	call   10d4 <botlish_fn_12+0xb0>
			10d0: R_X86_64_PLT32	rt_set_contains-0x4
    10d4:	cmp    rax,0x6
    10d8:	je     10e8 <botlish_fn_12+0xc4>
    10de:	mov    eax,0x2
    10e3:	jmp    10f7 <botlish_fn_12+0xd3>
    10e8:	mov    eax,0x6
    10ed:	jmp    10f7 <botlish_fn_12+0xd3>
    10f2:	mov    eax,0x6
    10f7:	mov    rbx,QWORD PTR [rsp]
    10fb:	mov    r12,QWORD PTR [rsp+0x8]
    1100:	mov    r13,QWORD PTR [rsp+0x10]
    1105:	add    rsp,0x20
    1109:	mov    rsp,rbp
    110c:	pop    rbp
    110d:	ret

000000000000110e <botlish_entry_12: is_local_char<generic>>:
    110e:	push   rbp
    110f:	mov    rbp,rsp
    1112:	mov    rdx,QWORD PTR [rdx]
    1115:	call   111a <botlish_entry_12+0xc>
			1116: R_X86_64_PLT32	botlish_fn_12-0x4 ; is_local_char<generic>
    111a:	mov    rsp,rbp
    111d:	pop    rbp
    111e:	ret

000000000000111f <botlish_fn_13: is_label_char<generic>>:
    111f:	push   rbp
    1120:	mov    rbp,rsp
    1123:	sub    rsp,0x10
    1127:	mov    QWORD PTR [rsp],rbx
    112b:	mov    QWORD PTR [rsp+0x8],r12
    1130:	xor    r8d,r8d
    1133:	test   rsi,0x7
    113a:	jne    114a <botlish_fn_13+0x2b>
    1140:	movzx  rax,BYTE PTR [rsi]
    1144:	cmp    al,0x2
    1146:	sete   r8b
    114a:	test   r8b,r8b
    114d:	jne    116d <botlish_fn_13+0x4e>
    1153:	mov    rax,QWORD PTR [rdi+0x10]
    1157:	mov    rcx,QWORD PTR [rax+0xd8]
    115e:	mov    edx,0x1
    1163:	call   1168 <botlish_fn_13+0x49>
			1164: R_X86_64_PLT32	rt_type_error-0x4
    1168:	jmp    1181 <botlish_fn_13+0x62>
    116d:	mov    rbx,rsi
    1170:	mov    r12,rdi
    1173:	call   1178 <botlish_fn_13+0x59>
			1174: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    1178:	test   rax,rax
    117b:	jne    1196 <botlish_fn_13+0x77>
    1181:	xor    rax,rax
    1184:	mov    rbx,QWORD PTR [rsp]
    1188:	mov    r12,QWORD PTR [rsp+0x8]
    118d:	add    rsp,0x10
    1191:	mov    rsp,rbp
    1194:	pop    rbp
    1195:	ret
    1196:	cmp    rax,0x6
    119a:	je     11db <botlish_fn_13+0xbc>
    11a0:	mov    rdi,r12
    11a3:	mov    rax,QWORD PTR [rdi+0x10]
    11a7:	mov    rsi,QWORD PTR [rax+0x20]
    11ab:	mov    edx,0x1
    11b0:	mov    ecx,0x3
    11b5:	mov    r8,rbx
    11b8:	call   11bd <botlish_fn_13+0x9e>
			11b9: R_X86_64_PLT32	rt_str_region_eq-0x4
    11bd:	cmp    rax,0x6
    11c1:	je     11d1 <botlish_fn_13+0xb2>
    11c7:	mov    eax,0x2
    11cc:	jmp    11e0 <botlish_fn_13+0xc1>
    11d1:	mov    eax,0x6
    11d6:	jmp    11e0 <botlish_fn_13+0xc1>
    11db:	mov    eax,0x6
    11e0:	mov    rbx,QWORD PTR [rsp]
    11e4:	mov    r12,QWORD PTR [rsp+0x8]
    11e9:	add    rsp,0x10
    11ed:	mov    rsp,rbp
    11f0:	pop    rbp
    11f1:	ret

00000000000011f2 <botlish_entry_13: is_label_char<generic>>:
    11f2:	push   rbp
    11f3:	mov    rbp,rsp
    11f6:	mov    rsi,QWORD PTR [rdx]
    11f9:	call   11fe <botlish_entry_13+0xc>
			11fa: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_label_char<generic>
    11fe:	mov    rsp,rbp
    1201:	pop    rbp
    1202:	ret
    1203:	add    BYTE PTR [rax],al
    1205:	add    BYTE PTR [rax],al
	...

0000000000001208 <botlish_fn_14: scan_while<generic>>:
    1208:	push   rbp
    1209:	mov    rbp,rsp
    120c:	sub    rsp,0x70
    1210:	mov    QWORD PTR [rsp+0x40],rbx
    1215:	mov    QWORD PTR [rsp+0x48],r12
    121a:	mov    QWORD PTR [rsp+0x50],r13
    121f:	mov    QWORD PTR [rsp+0x58],r14
    1224:	mov    QWORD PTR [rsp+0x60],r15
    1229:	mov    QWORD PTR [rsp+0x30],rdi
    122e:	mov    QWORD PTR [rsp+0x20],0x0
    1237:	mov    QWORD PTR [rsp],rsi
    123b:	mov    r15,rsi
    123e:	mov    QWORD PTR [rsp+0x8],rdx
    1243:	mov    r13,rdx
    1246:	mov    QWORD PTR [rsp+0x10],rcx
    124b:	mov    QWORD PTR [rsp+0x18],r8
    1250:	mov    r12,r8
    1253:	lea    r14,[rsp+0x28]
    1258:	mov    rbx,rcx
    125b:	mov    rax,rsi
    125e:	and    rax,rbx
    1261:	mov    r15,rsi
    1264:	test   rax,0x1
    126a:	jne    1295 <botlish_fn_14+0x8d>
    1270:	mov    rdx,rbx
    1273:	mov    rsi,r15
    1276:	mov    rdi,QWORD PTR [rsp+0x30]
    127b:	call   1280 <botlish_fn_14+0x78>
			127c: R_X86_64_PLT32	rt_int_cmp-0x4
    1280:	mov    ecx,0x2
    1285:	test   rax,rax
    1288:	cmovge rcx,QWORD PTR [rip+0x150]        # 13e0 <botlish_fn_14+0x1d8>
    1290:	jmp    12a8 <botlish_fn_14+0xa0>
    1295:	mov    ecx,0x2
    129a:	mov    rsi,r15
    129d:	cmp    rsi,rbx
    12a0:	cmovge rcx,QWORD PTR [rip+0x138]        # 13e0 <botlish_fn_14+0x1d8>
    12a8:	cmp    rcx,0x6
    12ac:	je     13b4 <botlish_fn_14+0x1ac>
    12b2:	mov    rdx,r12
    12b5:	mov    rsi,r15
    12b8:	mov    rdi,QWORD PTR [rsp+0x30]
    12bd:	call   12c2 <botlish_fn_14+0xba>
			12be: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    12c2:	test   rax,rax
    12c5:	je     1311 <botlish_fn_14+0x109>
    12cb:	mov    QWORD PTR [rsp+0x20],rax
    12d0:	mov    QWORD PTR [rsp+0x28],rax
    12d5:	mov    edx,0x1
    12da:	mov    rcx,r14
    12dd:	mov    rsi,r13
    12e0:	mov    rdi,QWORD PTR [rsp+0x30]
    12e5:	call   12ea <botlish_fn_14+0xe2>
			12e6: R_X86_64_PLT32	rt_call_value-0x4
    12ea:	test   rax,rax
    12ed:	je     1311 <botlish_fn_14+0x109>
    12f3:	mov    rcx,rax
    12f6:	or     rcx,0x4
    12fa:	mov    rsi,rax
    12fd:	cmp    rcx,0x6
    1301:	je     1336 <botlish_fn_14+0x12e>
    1307:	mov    rdi,QWORD PTR [rsp+0x30]
    130c:	call   1311 <botlish_fn_14+0x109>
			130d: R_X86_64_PLT32	rt_not_boolean-0x4
    1311:	xor    rax,rax
    1314:	mov    rbx,QWORD PTR [rsp+0x40]
    1319:	mov    r12,QWORD PTR [rsp+0x48]
    131e:	mov    r13,QWORD PTR [rsp+0x50]
    1323:	mov    r14,QWORD PTR [rsp+0x58]
    1328:	mov    r15,QWORD PTR [rsp+0x60]
    132d:	add    rsp,0x70
    1331:	mov    rsp,rbp
    1334:	pop    rbp
    1335:	ret
    1336:	cmp    rsi,0x6
    133a:	je     1348 <botlish_fn_14+0x140>
    1340:	mov    rax,r15
    1343:	jmp    13b7 <botlish_fn_14+0x1af>
    1348:	mov    QWORD PTR [rsp+0x20],0x3
    1351:	mov    rsi,r15
    1354:	test   rsi,0x1
    135b:	je     1381 <botlish_fn_14+0x179>
    1361:	mov    rsi,r15
    1364:	mov    rcx,rsi
    1367:	add    rcx,0x2
    136b:	seto   al
    136e:	test   al,al
    1370:	jne    1381 <botlish_fn_14+0x179>
    1376:	mov    rsi,rcx
    1379:	mov    r15,rcx
    137c:	jmp    1399 <botlish_fn_14+0x191>
    1381:	mov    edx,0x3
    1386:	mov    rsi,r15
    1389:	mov    rdi,QWORD PTR [rsp+0x30]
    138e:	call   1393 <botlish_fn_14+0x18b>
			138f: R_X86_64_PLT32	rt_int_add-0x4
    1393:	mov    rsi,rax
    1396:	mov    r15,rax
    1399:	mov    QWORD PTR [rsp],rsi
    139d:	mov    QWORD PTR [rsp+0x8],r13
    13a2:	mov    QWORD PTR [rsp+0x10],rbx
    13a7:	mov    QWORD PTR [rsp+0x18],r12
    13ac:	mov    rsi,r15
    13af:	jmp    125b <botlish_fn_14+0x53>
    13b4:	mov    rax,r15
    13b7:	mov    rbx,QWORD PTR [rsp+0x40]
    13bc:	mov    r12,QWORD PTR [rsp+0x48]
    13c1:	mov    r13,QWORD PTR [rsp+0x50]
    13c6:	mov    r14,QWORD PTR [rsp+0x58]
    13cb:	mov    r15,QWORD PTR [rsp+0x60]
    13d0:	add    rsp,0x70
    13d4:	mov    rsp,rbp
    13d7:	pop    rbp
    13d8:	ret
    13d9:	add    BYTE PTR [rax],al
    13db:	add    BYTE PTR [rax],al
    13dd:	add    BYTE PTR [rax],al
    13df:	add    BYTE PTR [rsi],al
    13e1:	add    BYTE PTR [rax],al
    13e3:	add    BYTE PTR [rax],al
    13e5:	add    BYTE PTR [rax],al
	...

00000000000013e8 <botlish_entry_14: scan_while<generic>>:
    13e8:	push   rbp
    13e9:	mov    rbp,rsp
    13ec:	mov    rsi,QWORD PTR [rdx]
    13ef:	mov    r9,QWORD PTR [rdx+0x8]
    13f3:	mov    rcx,QWORD PTR [rdx+0x10]
    13f7:	mov    r8,QWORD PTR [rdx+0x18]
    13fb:	mov    rdx,r9
    13fe:	call   1403 <botlish_entry_14+0x1b>
			13ff: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<generic>
    1403:	mov    rsp,rbp
    1406:	pop    rbp
    1407:	ret

0000000000001408 <botlish_fn_15: tld_ok<generic>>:
    1408:	push   rbp
    1409:	mov    rbp,rsp
    140c:	sub    rsp,0x40
    1410:	mov    QWORD PTR [rsp+0x20],rbx
    1415:	mov    QWORD PTR [rsp+0x28],r12
    141a:	mov    QWORD PTR [rsp+0x30],r13
    141f:	mov    QWORD PTR [rsp+0x38],r14
    1424:	mov    QWORD PTR [rsp],rsi
    1428:	mov    r8,rsi
    142b:	mov    QWORD PTR [rsp+0x8],rdx
    1430:	mov    r14,rdx
    1433:	mov    QWORD PTR [rsp+0x10],rcx
    1438:	mov    rax,QWORD PTR [rdi+0x10]
    143c:	mov    r12,rdi
    143f:	mov    rdx,QWORD PTR [rax+0xe0]
    1446:	mov    QWORD PTR [rsp+0x18],rdx
    144b:	mov    rbx,r8
    144e:	mov    r8,rcx
    1451:	mov    rcx,r14
    1454:	mov    rsi,rbx
    1457:	call   145c <botlish_fn_15+0x54>
			1458: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<generic>
    145c:	mov    rcx,rax
    145f:	mov    r13,rax
    1462:	test   rax,rcx
    1465:	jne    148b <botlish_fn_15+0x83>
    146b:	xor    rax,rax
    146e:	mov    rbx,QWORD PTR [rsp+0x20]
    1473:	mov    r12,QWORD PTR [rsp+0x28]
    1478:	mov    r13,QWORD PTR [rsp+0x30]
    147d:	mov    r14,QWORD PTR [rsp+0x38]
    1482:	add    rsp,0x40
    1486:	mov    rsp,rbp
    1489:	pop    rbp
    148a:	ret
    148b:	mov    rax,r13
    148e:	mov    QWORD PTR [rsp+0x8],rax
    1493:	mov    rdx,r14
    1496:	and    rax,rdx
    1499:	test   rax,0x1
    149f:	jne    14c8 <botlish_fn_15+0xc0>
    14a5:	mov    rsi,r13
    14a8:	mov    rdi,r12
    14ab:	call   14b0 <botlish_fn_15+0xa8>
			14ac: R_X86_64_PLT32	rt_int_cmp-0x4
    14b0:	mov    ecx,0x2
    14b5:	test   rax,rax
    14b8:	cmove  rcx,QWORD PTR [rip+0xe0]        # 15a0 <botlish_fn_15+0x198>
    14c0:	mov    rax,r13
    14c3:	jmp    14db <botlish_fn_15+0xd3>
    14c8:	mov    ecx,0x2
    14cd:	mov    rax,r13
    14d0:	cmp    rax,rdx
    14d3:	cmove  rcx,QWORD PTR [rip+0xc5]        # 15a0 <botlish_fn_15+0x198>
    14db:	cmp    rcx,0x6
    14df:	je     14f2 <botlish_fn_15+0xea>
    14e5:	mov    ecx,0x2
    14ea:	mov    rax,rcx
    14ed:	jmp    157f <botlish_fn_15+0x177>
    14f2:	mov    rcx,rax
    14f5:	and    rcx,rbx
    14f8:	test   rcx,0x1
    14ff:	jne    1510 <botlish_fn_15+0x108>
    1505:	mov    rdx,rbx
    1508:	mov    rsi,rax
    150b:	jmp    1531 <botlish_fn_15+0x129>
    1510:	mov    rcx,rax
    1513:	sub    rcx,rbx
    1516:	mov    r8,rbx
    1519:	mov    r13,rax
    151c:	seto   al
    151f:	lea    rsi,[rcx+0x1]
    1523:	test   al,al
    1525:	je     153c <botlish_fn_15+0x134>
    152b:	mov    rdx,r8
    152e:	mov    rsi,r13
    1531:	mov    rdi,r12
    1534:	call   1539 <botlish_fn_15+0x131>
			1535: R_X86_64_PLT32	rt_int_sub-0x4
    1539:	mov    rsi,rax
    153c:	test   rsi,0x1
    1543:	jne    156e <botlish_fn_15+0x166>
    1549:	mov    edx,0x5
    154e:	mov    rdi,r12
    1551:	call   1556 <botlish_fn_15+0x14e>
			1552: R_X86_64_PLT32	rt_int_cmp-0x4
    1556:	mov    ecx,0x2
    155b:	test   rax,rax
    155e:	mov    rax,rcx
    1561:	cmovge rax,QWORD PTR [rip+0x37]        # 15a0 <botlish_fn_15+0x198>
    1569:	jmp    157f <botlish_fn_15+0x177>
    156e:	mov    eax,0x2
    1573:	cmp    rsi,0x5
    1577:	cmovge rax,QWORD PTR [rip+0x21]        # 15a0 <botlish_fn_15+0x198>
    157f:	mov    rbx,QWORD PTR [rsp+0x20]
    1584:	mov    r12,QWORD PTR [rsp+0x28]
    1589:	mov    r13,QWORD PTR [rsp+0x30]
    158e:	mov    r14,QWORD PTR [rsp+0x38]
    1593:	add    rsp,0x40
    1597:	mov    rsp,rbp
    159a:	pop    rbp
    159b:	ret
    159c:	add    BYTE PTR [rax],al
    159e:	add    BYTE PTR [rax],al
    15a0:	(bad)
    15a1:	add    BYTE PTR [rax],al
    15a3:	add    BYTE PTR [rax],al
    15a5:	add    BYTE PTR [rax],al
	...

00000000000015a8 <botlish_entry_15: tld_ok<generic>>:
    15a8:	push   rbp
    15a9:	mov    rbp,rsp
    15ac:	mov    rsi,QWORD PTR [rdx]
    15af:	mov    r8,QWORD PTR [rdx+0x8]
    15b3:	mov    rcx,QWORD PTR [rdx+0x10]
    15b7:	mov    rdx,r8
    15ba:	call   15bf <botlish_entry_15+0x17>
			15bb: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld_ok<generic>
    15bf:	mov    rsp,rbp
    15c2:	pop    rbp
    15c3:	ret
    15c4:	add    BYTE PTR [rax],al
	...

00000000000015c8 <botlish_fn_16: domain_loop<generic>>:
    15c8:	push   rbp
    15c9:	mov    rbp,rsp
    15cc:	sub    rsp,0x70
    15d0:	mov    QWORD PTR [rsp+0x40],rbx
    15d5:	mov    QWORD PTR [rsp+0x48],r12
    15da:	mov    QWORD PTR [rsp+0x50],r13
    15df:	mov    QWORD PTR [rsp+0x58],r14
    15e4:	mov    QWORD PTR [rsp+0x60],r15
    15e9:	mov    rax,rdi
    15ec:	mov    QWORD PTR [rsp],rsi
    15f0:	mov    QWORD PTR [rsp+0x8],rdx
    15f5:	mov    rdi,rdx
    15f8:	mov    QWORD PTR [rsp+0x10],rcx
    15fd:	lea    rbx,[rsp+0x20]
    1602:	mov    r12,rax
    1605:	mov    QWORD PTR [rsp+0x30],rsi
    160a:	mov    rax,QWORD PTR [r12+0x10]
    160f:	mov    rdx,QWORD PTR [rax+0xe8]
    1616:	mov    QWORD PTR [rsp+0x18],rdx
    161b:	mov    r13,rcx
    161e:	mov    r14,rdi
    1621:	mov    rcx,r14
    1624:	mov    rsi,QWORD PTR [rsp+0x30]
    1629:	mov    rdi,r12
    162c:	mov    r8,r13
    162f:	call   1634 <botlish_fn_16+0x6c>
			1630: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_while<generic>
    1634:	mov    rsi,rax
    1637:	mov    r15,rax
    163a:	test   rax,rsi
    163d:	je     1790 <botlish_fn_16+0x1c8>
    1643:	mov    rax,r15
    1646:	mov    QWORD PTR [rsp],rax
    164a:	mov    rdx,QWORD PTR [rsp+0x30]
    164f:	and    rax,rdx
    1652:	test   rax,0x1
    1658:	jne    167e <botlish_fn_16+0xb6>
    165e:	mov    rsi,r15
    1661:	mov    rdi,r12
    1664:	call   1669 <botlish_fn_16+0xa1>
			1665: R_X86_64_PLT32	rt_int_cmp-0x4
    1669:	mov    ecx,0x2
    166e:	test   rax,rax
    1671:	cmove  rcx,QWORD PTR [rip+0x19f]        # 1818 <botlish_fn_16+0x250>
    1679:	jmp    168e <botlish_fn_16+0xc6>
    167e:	mov    ecx,0x2
    1683:	cmp    r15,rdx
    1686:	cmove  rcx,QWORD PTR [rip+0x18a]        # 1818 <botlish_fn_16+0x250>
    168e:	cmp    rcx,0x6
    1692:	je     17ec <botlish_fn_16+0x224>
    1698:	mov    rax,r15
    169b:	and    rax,r14
    169e:	test   rax,0x1
    16a4:	jne    16cd <botlish_fn_16+0x105>
    16aa:	mov    rdx,r14
    16ad:	mov    rsi,r15
    16b0:	mov    rdi,r12
    16b3:	call   16b8 <botlish_fn_16+0xf0>
			16b4: R_X86_64_PLT32	rt_int_cmp-0x4
    16b8:	mov    ecx,0x2
    16bd:	test   rax,rax
    16c0:	cmovge rcx,QWORD PTR [rip+0x150]        # 1818 <botlish_fn_16+0x250>
    16c8:	jmp    16dd <botlish_fn_16+0x115>
    16cd:	mov    ecx,0x2
    16d2:	cmp    r15,r14
    16d5:	cmovge rcx,QWORD PTR [rip+0x13b]        # 1818 <botlish_fn_16+0x250>
    16dd:	cmp    rcx,0x6
    16e1:	je     17dd <botlish_fn_16+0x215>
    16e7:	mov    rcx,rbx
    16ea:	mov    rdx,r13
    16ed:	mov    rsi,r15
    16f0:	mov    rdi,r12
    16f3:	call   16f8 <botlish_fn_16+0x130>
			16f4: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    16f8:	test   rax,rax
    16fb:	mov    rsi,rax
    16fe:	je     1790 <botlish_fn_16+0x1c8>
    1704:	mov    rdx,QWORD PTR [rsp+0x20]
    1709:	mov    rcx,QWORD PTR [rsp+0x28]
    170e:	mov    r8,QWORD PTR [r12+0x10]
    1713:	mov    r8,QWORD PTR [r8]
    1716:	mov    rdi,r12
    1719:	call   171e <botlish_fn_16+0x156>
			171a: R_X86_64_PLT32	rt_str_region_eq-0x4
    171e:	cmp    rax,0x6
    1722:	je     1734 <botlish_fn_16+0x16c>
    1728:	mov    r14,0xffffffffffffffff
    172f:	jmp    17e4 <botlish_fn_16+0x21c>
    1734:	mov    QWORD PTR [rsp+0x18],0x3
    173d:	test   r15,0x1
    1744:	je     175c <botlish_fn_16+0x194>
    174a:	mov    rdx,r15
    174d:	add    rdx,0x2
    1751:	seto   al
    1754:	test   al,al
    1756:	je     176f <botlish_fn_16+0x1a7>
    175c:	mov    edx,0x3
    1761:	mov    rsi,r15
    1764:	mov    rdi,r12
    1767:	call   176c <botlish_fn_16+0x1a4>
			1768: R_X86_64_PLT32	rt_int_add-0x4
    176c:	mov    rdx,rax
    176f:	mov    QWORD PTR [rsp],rdx
    1773:	mov    r15,rdx
    1776:	mov    rcx,r13
    1779:	mov    rdx,r14
    177c:	mov    rsi,r15
    177f:	mov    rdi,r12
    1782:	call   1787 <botlish_fn_16+0x1bf>
			1783: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld_ok<generic>
    1787:	test   rax,rax
    178a:	jne    17b5 <botlish_fn_16+0x1ed>
    1790:	xor    rax,rax
    1793:	mov    rbx,QWORD PTR [rsp+0x40]
    1798:	mov    r12,QWORD PTR [rsp+0x48]
    179d:	mov    r13,QWORD PTR [rsp+0x50]
    17a2:	mov    r14,QWORD PTR [rsp+0x58]
    17a7:	mov    r15,QWORD PTR [rsp+0x60]
    17ac:	add    rsp,0x70
    17b0:	mov    rsp,rbp
    17b3:	pop    rbp
    17b4:	ret
    17b5:	cmp    rax,0x6
    17b9:	je     17e4 <botlish_fn_16+0x21c>
    17bf:	mov    QWORD PTR [rsp],r15
    17c3:	mov    QWORD PTR [rsp+0x8],r14
    17c8:	mov    QWORD PTR [rsp+0x10],r13
    17cd:	mov    rcx,r13
    17d0:	mov    rdi,r14
    17d3:	mov    QWORD PTR [rsp+0x30],r15
    17d8:	jmp    160a <botlish_fn_16+0x42>
    17dd:	mov    r14,0xffffffffffffffff
    17e4:	mov    rax,r14
    17e7:	jmp    17f3 <botlish_fn_16+0x22b>
    17ec:	mov    rax,0xffffffffffffffff
    17f3:	mov    rbx,QWORD PTR [rsp+0x40]
    17f8:	mov    r12,QWORD PTR [rsp+0x48]
    17fd:	mov    r13,QWORD PTR [rsp+0x50]
    1802:	mov    r14,QWORD PTR [rsp+0x58]
    1807:	mov    r15,QWORD PTR [rsp+0x60]
    180c:	add    rsp,0x70
    1810:	mov    rsp,rbp
    1813:	pop    rbp
    1814:	ret
    1815:	add    BYTE PTR [rax],al
    1817:	add    BYTE PTR [rsi],al
    1819:	add    BYTE PTR [rax],al
    181b:	add    BYTE PTR [rax],al
    181d:	add    BYTE PTR [rax],al
	...

0000000000001820 <botlish_entry_16: domain_loop<generic>>:
    1820:	push   rbp
    1821:	mov    rbp,rsp
    1824:	mov    rsi,QWORD PTR [rdx]
    1827:	mov    r8,QWORD PTR [rdx+0x8]
    182b:	mov    rcx,QWORD PTR [rdx+0x10]
    182f:	mov    rdx,r8
    1832:	call   1837 <botlish_entry_16+0x17>
			1833: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain_loop<generic>
    1837:	mov    rsp,rbp
    183a:	pop    rbp
    183b:	ret

000000000000183c <botlish_fn_17: web::is_unreserved<generic>>:
    183c:	push   rbp
    183d:	mov    rbp,rsp
    1840:	sub    rsp,0x20
    1844:	mov    QWORD PTR [rsp],rbx
    1848:	mov    QWORD PTR [rsp+0x8],r12
    184d:	mov    QWORD PTR [rsp+0x10],r14
    1852:	mov    rbx,rdi
    1855:	mov    r12,rsi
    1858:	mov    r14,rdx
    185b:	mov    rsi,r14
    185e:	mov    rdi,rbx
    1861:	call   1866 <botlish_fn_17+0x2a>
			1862: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
    1866:	cmp    rax,0x6
    186a:	je     18a3 <botlish_fn_17+0x67>
    1870:	mov    rsi,r12
    1873:	mov    rax,QWORD PTR [rsi+0x20]
    1877:	mov    rsi,QWORD PTR [rax]
    187a:	mov    rdx,r14
    187d:	mov    rdi,rbx
    1880:	call   1885 <botlish_fn_17+0x49>
			1881: R_X86_64_PLT32	rt_set_contains-0x4
    1885:	cmp    rax,0x6
    1889:	je     1899 <botlish_fn_17+0x5d>
    188f:	mov    eax,0x2
    1894:	jmp    18a8 <botlish_fn_17+0x6c>
    1899:	mov    eax,0x6
    189e:	jmp    18a8 <botlish_fn_17+0x6c>
    18a3:	mov    eax,0x6
    18a8:	mov    rbx,QWORD PTR [rsp]
    18ac:	mov    r12,QWORD PTR [rsp+0x8]
    18b1:	mov    r14,QWORD PTR [rsp+0x10]
    18b6:	add    rsp,0x20
    18ba:	mov    rsp,rbp
    18bd:	pop    rbp
    18be:	ret

00000000000018bf <botlish_entry_17: web::is_unreserved<generic>>:
    18bf:	push   rbp
    18c0:	mov    rbp,rsp
    18c3:	mov    rdx,QWORD PTR [rdx]
    18c6:	call   18cb <botlish_entry_17+0xc>
			18c7: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<generic>
    18cb:	mov    rsp,rbp
    18ce:	pop    rbp
    18cf:	ret

00000000000018d0 <botlish_fn_18: web::uri_escape_text<generic>>:
    18d0:	push   rbp
    18d1:	mov    rbp,rsp
    18d4:	sub    rsp,0x30
    18d8:	mov    QWORD PTR [rsp],rdx
    18dc:	mov    r10,rdx
    18df:	mov    edx,0x1
    18e4:	mov    QWORD PTR [rsp+0x8],0x1
    18ed:	mov    rax,QWORD PTR [rdi+0x10]
    18f1:	mov    rcx,QWORD PTR [rax+0xf0]
    18f8:	mov    QWORD PTR [rsp+0x10],rcx
    18fd:	mov    rax,QWORD PTR [rsi+0x20]
    1901:	mov    r8,QWORD PTR [rax+0x8]
    1905:	mov    QWORD PTR [rsp+0x18],r8
    190a:	mov    rax,QWORD PTR [rsi+0x20]
    190e:	mov    r9,QWORD PTR [rax]
    1911:	mov    QWORD PTR [rsp+0x20],r9
    1916:	mov    rsi,r10
    1919:	call   191e <botlish_fn_18+0x4e>
			191a: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_from<generic>
    191e:	test   rax,rax
    1921:	jne    1933 <botlish_fn_18+0x63>
    1927:	xor    rax,rax
    192a:	add    rsp,0x30
    192e:	mov    rsp,rbp
    1931:	pop    rbp
    1932:	ret
    1933:	add    rsp,0x30
    1937:	mov    rsp,rbp
    193a:	pop    rbp
    193b:	ret

000000000000193c <botlish_entry_18: web::uri_escape_text<generic>>:
    193c:	push   rbp
    193d:	mov    rbp,rsp
    1940:	mov    rdx,QWORD PTR [rdx]
    1943:	call   1948 <botlish_entry_18+0xc>
			1944: R_X86_64_PLT32	botlish_fn_18-0x4 ; web::uri_escape_text<generic>
    1948:	mov    rsp,rbp
    194b:	pop    rbp
    194c:	ret

000000000000194d <botlish_fn_19: high_nibble<generic>>:
    194d:	push   rbp
    194e:	mov    rbp,rsp
    1951:	sub    rsp,0x10
    1955:	mov    QWORD PTR [rsp],rsi
    1959:	mov    QWORD PTR [rsp+0x8],0x1e1
    1962:	test   rsi,0x1
    1969:	jne    197e <botlish_fn_19+0x31>
    196f:	mov    edx,0x1e1
    1974:	call   1979 <botlish_fn_19+0x2c>
			1975: R_X86_64_PLT32	rt_int_and-0x4
    1979:	jmp    1988 <botlish_fn_19+0x3b>
    197e:	and    rsi,0x1e1
    1985:	mov    rax,rsi
    1988:	sar    rax,0x5
    198c:	shl    rax,1
    198f:	or     rax,0x1
    1993:	add    rsp,0x10
    1997:	mov    rsp,rbp
    199a:	pop    rbp
    199b:	ret

000000000000199c <botlish_entry_19: high_nibble<generic>>:
    199c:	push   rbp
    199d:	mov    rbp,rsp
    19a0:	mov    rsi,QWORD PTR [rdx]
    19a3:	call   19a8 <botlish_entry_19+0xc>
			19a4: R_X86_64_PLT32	botlish_fn_19-0x4 ; high_nibble<generic>
    19a8:	mov    rsp,rbp
    19ab:	pop    rbp
    19ac:	ret

00000000000019ad <botlish_fn_20: hex_pair<generic>>:
    19ad:	push   rbp
    19ae:	mov    rbp,rsp
    19b1:	sub    rsp,0x50
    19b5:	mov    QWORD PTR [rsp+0x30],rbx
    19ba:	mov    QWORD PTR [rsp+0x38],r12
    19bf:	mov    QWORD PTR [rsp+0x40],r13
    19c4:	mov    QWORD PTR [rsp+0x48],r14
    19c9:	mov    r12,rdi
    19cc:	mov    QWORD PTR [rsp],rsi
    19d0:	mov    r13,rsi
    19d3:	mov    QWORD PTR [rsp+0x8],rdx
    19d8:	mov    rbx,rdx
    19db:	mov    rsi,r13
    19de:	mov    rdi,r12
    19e1:	call   19e6 <botlish_fn_20+0x39>
			19e2: R_X86_64_PLT32	botlish_fn_19-0x4 ; high_nibble<generic>
    19e6:	test   rax,0x1
    19ec:	jne    19fa <botlish_fn_20+0x4d>
    19f2:	mov    rdx,rax
    19f5:	jmp    1a10 <botlish_fn_20+0x63>
    19fa:	mov    rdx,QWORD PTR [rbx+0x8]
    19fe:	mov    rcx,rax
    1a01:	sar    rcx,1
    1a04:	cmp    rcx,rdx
    1a07:	jb     1a29 <botlish_fn_20+0x7c>
    1a0d:	mov    rdx,rax
    1a10:	mov    rsi,rbx
    1a13:	mov    rdi,r12
    1a16:	call   1a1b <botlish_fn_20+0x6e>
			1a17: R_X86_64_PLT32	rt_list_get-0x4
    1a1b:	test   rax,rax
    1a1e:	je     1ae6 <botlish_fn_20+0x139>
    1a24:	jmp    1a31 <botlish_fn_20+0x84>
    1a29:	mov    rax,QWORD PTR [rbx+0x10]
    1a2d:	mov    rax,QWORD PTR [rax+rcx*8]
    1a31:	mov    QWORD PTR [rsp],rax
    1a35:	mov    r14,rax
    1a38:	mov    edx,0x21
    1a3d:	mov    rsi,r13
    1a40:	mov    rdi,r12
    1a43:	call   1a48 <botlish_fn_20+0x9b>
			1a44: R_X86_64_PLT32	rt_int_mod-0x4
    1a48:	test   rax,rax
    1a4b:	je     1ae6 <botlish_fn_20+0x139>
    1a51:	test   rax,0x1
    1a57:	jne    1a68 <botlish_fn_20+0xbb>
    1a5d:	mov    rdx,rax
    1a60:	mov    rsi,rbx
    1a63:	jmp    1a81 <botlish_fn_20+0xd4>
    1a68:	mov    rdx,QWORD PTR [rbx+0x8]
    1a6c:	mov    rcx,rax
    1a6f:	sar    rcx,1
    1a72:	cmp    rcx,rdx
    1a75:	jb     1a97 <botlish_fn_20+0xea>
    1a7b:	mov    rdx,rax
    1a7e:	mov    rsi,rbx
    1a81:	mov    rdi,r12
    1a84:	call   1a89 <botlish_fn_20+0xdc>
			1a85: R_X86_64_PLT32	rt_list_get-0x4
    1a89:	test   rax,rax
    1a8c:	je     1ae6 <botlish_fn_20+0x139>
    1a92:	jmp    1aa2 <botlish_fn_20+0xf5>
    1a97:	mov    rsi,rbx
    1a9a:	mov    rax,QWORD PTR [rsi+0x10]
    1a9e:	mov    rax,QWORD PTR [rax+rcx*8]
    1aa2:	mov    QWORD PTR [rsp+0x8],rax
    1aa7:	lea    rcx,[rsp+0x10]
    1aac:	mov    QWORD PTR [rsp+0x10],0x0
    1ab5:	mov    rdx,r14
    1ab8:	mov    QWORD PTR [rsp+0x18],rdx
    1abd:	mov    QWORD PTR [rsp+0x20],0x0
    1ac6:	mov    QWORD PTR [rsp+0x28],rax
    1acb:	mov    esi,0x2
    1ad0:	mov    edx,0x4
    1ad5:	mov    rdi,r12
    1ad8:	call   1add <botlish_fn_20+0x130>
			1ad9: R_X86_64_PLT32	rt_construct-0x4
    1add:	test   rax,rax
    1ae0:	jne    1b06 <botlish_fn_20+0x159>
    1ae6:	xor    rax,rax
    1ae9:	mov    rbx,QWORD PTR [rsp+0x30]
    1aee:	mov    r12,QWORD PTR [rsp+0x38]
    1af3:	mov    r13,QWORD PTR [rsp+0x40]
    1af8:	mov    r14,QWORD PTR [rsp+0x48]
    1afd:	add    rsp,0x50
    1b01:	mov    rsp,rbp
    1b04:	pop    rbp
    1b05:	ret
    1b06:	mov    rbx,QWORD PTR [rsp+0x30]
    1b0b:	mov    r12,QWORD PTR [rsp+0x38]
    1b10:	mov    r13,QWORD PTR [rsp+0x40]
    1b15:	mov    r14,QWORD PTR [rsp+0x48]
    1b1a:	add    rsp,0x50
    1b1e:	mov    rsp,rbp
    1b21:	pop    rbp
    1b22:	ret

0000000000001b23 <botlish_entry_20: hex_pair<generic>>:
    1b23:	push   rbp
    1b24:	mov    rbp,rsp
    1b27:	sub    rsp,0x10
    1b2b:	mov    QWORD PTR [rsp],r12
    1b2f:	mov    r12,rdi
    1b32:	mov    rsi,QWORD PTR [rdx]
    1b35:	mov    rdx,QWORD PTR [rdx+0x8]
    1b39:	call   1b3e <botlish_entry_20+0x1b>
			1b3a: R_X86_64_PLT32	botlish_fn_20-0x4 ; hex_pair<generic>
    1b3e:	mov    r8,QWORD PTR [rip+0x0]        # 1b45 <botlish_entry_20+0x22>
			1b41: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1b45:	mov    rsi,rax
    1b48:	mov    rdi,r12
    1b4b:	call   r8
    1b4e:	mov    r12,QWORD PTR [rsp]
    1b52:	add    rsp,0x10
    1b56:	mov    rsp,rbp
    1b59:	pop    rbp
    1b5a:	ret
    1b5b:	add    BYTE PTR [rax],al
    1b5d:	add    BYTE PTR [rax],al
	...

0000000000001b60 <botlish_fn_21: esc_bytes<generic>>:
    1b60:	push   rbp
    1b61:	mov    rbp,rsp
    1b64:	sub    rsp,0xb0
    1b6b:	mov    QWORD PTR [rsp+0x80],rbx
    1b73:	mov    QWORD PTR [rsp+0x88],r12
    1b7b:	mov    QWORD PTR [rsp+0x90],r13
    1b83:	mov    QWORD PTR [rsp+0x98],r14
    1b8b:	mov    QWORD PTR [rsp+0xa0],r15
    1b93:	mov    QWORD PTR [rsp+0x28],0x0
    1b9c:	mov    QWORD PTR [rsp],rsi
    1ba0:	mov    QWORD PTR [rsp+0x8],rdx
    1ba5:	mov    r13,rdx
    1ba8:	mov    QWORD PTR [rsp+0x10],rcx
    1bad:	mov    QWORD PTR [rsp+0x18],r8
    1bb2:	mov    QWORD PTR [rsp+0x60],r8
    1bb7:	lea    rax,[rsp+0x30]
    1bbc:	mov    QWORD PTR [rsp+0x70],rax
    1bc1:	mov    rbx,rdi
    1bc4:	mov    r12,rsi
    1bc7:	mov    QWORD PTR [rsp+0x68],rcx
    1bcc:	mov    rsi,r12
    1bcf:	mov    rdi,rbx
    1bd2:	call   1bd7 <botlish_fn_21+0x77>
			1bd3: R_X86_64_PLT32	rt_list_len-0x4
    1bd7:	mov    r15,r13
    1bda:	mov    rcx,r15
    1bdd:	and    rcx,rax
    1be0:	mov    rdx,rax
    1be3:	test   rcx,0x1
    1bea:	jne    1c10 <botlish_fn_21+0xb0>
    1bf0:	mov    rsi,r15
    1bf3:	mov    rdi,rbx
    1bf6:	call   1bfb <botlish_fn_21+0x9b>
			1bf7: R_X86_64_PLT32	rt_int_cmp-0x4
    1bfb:	mov    ecx,0x2
    1c00:	test   rax,rax
    1c03:	cmovge rcx,QWORD PTR [rip+0x1dd]        # 1de8 <botlish_fn_21+0x288>
    1c0b:	jmp    1c20 <botlish_fn_21+0xc0>
    1c10:	mov    ecx,0x2
    1c15:	cmp    r15,rdx
    1c18:	cmovge rcx,QWORD PTR [rip+0x1c8]        # 1de8 <botlish_fn_21+0x288>
    1c20:	cmp    rcx,0x6
    1c24:	je     1daa <botlish_fn_21+0x24a>
    1c2a:	mov    QWORD PTR [rsp+0x20],0x3
    1c33:	test   r15,0x1
    1c3a:	je     1c5d <botlish_fn_21+0xfd>
    1c40:	mov    rax,r15
    1c43:	add    rax,0x2
    1c47:	mov    rcx,rax
    1c4a:	seto   al
    1c4d:	test   al,al
    1c4f:	jne    1c5d <botlish_fn_21+0xfd>
    1c55:	mov    r14,rcx
    1c58:	jmp    1c73 <botlish_fn_21+0x113>
    1c5d:	mov    edx,0x3
    1c62:	mov    rsi,r15
    1c65:	mov    rdi,rbx
    1c68:	call   1c6d <botlish_fn_21+0x10d>
			1c69: R_X86_64_PLT32	rt_int_add-0x4
    1c6d:	mov    rcx,rax
    1c70:	mov    r14,rcx
    1c73:	mov    QWORD PTR [rsp+0x8],r14
    1c78:	mov    rax,QWORD PTR [rbx+0x10]
    1c7c:	mov    r13,QWORD PTR [rax+0x10]
    1c80:	mov    QWORD PTR [rsp+0x20],r13
    1c85:	test   r15,0x1
    1c8c:	jne    1c9a <botlish_fn_21+0x13a>
    1c92:	mov    rdx,r15
    1c95:	jmp    1cb1 <botlish_fn_21+0x151>
    1c9a:	mov    rcx,QWORD PTR [r12+0x8]
    1c9f:	mov    rax,r15
    1ca2:	sar    rax,1
    1ca5:	cmp    rax,rcx
    1ca8:	jb     1ccd <botlish_fn_21+0x16d>
    1cae:	mov    rdx,r15
    1cb1:	mov    rsi,r12
    1cb4:	mov    rdi,rbx
    1cb7:	call   1cbc <botlish_fn_21+0x15c>
			1cb8: R_X86_64_PLT32	rt_list_get-0x4
    1cbc:	test   rax,rax
    1cbf:	je     1d4e <botlish_fn_21+0x1ee>
    1cc5:	mov    rsi,rax
    1cc8:	jmp    1cd6 <botlish_fn_21+0x176>
    1ccd:	mov    rdi,QWORD PTR [r12+0x10]
    1cd2:	mov    rsi,QWORD PTR [rdi+rax*8]
    1cd6:	mov    QWORD PTR [rsp+0x28],rsi
    1cdb:	mov    r15,QWORD PTR [rsp+0x60]
    1ce0:	mov    rdx,r15
    1ce3:	mov    rdi,rbx
    1ce6:	call   1ceb <botlish_fn_21+0x18b>
			1ce7: R_X86_64_PLT32	botlish_fn_20-0x4 ; hex_pair<generic>
    1ceb:	test   rax,rax
    1cee:	je     1d4e <botlish_fn_21+0x1ee>
    1cf4:	mov    QWORD PTR [rsp+0x28],rax
    1cf9:	mov    rcx,rax
    1cfc:	mov    QWORD PTR [rsp+0x30],0x0
    1d05:	mov    rax,QWORD PTR [rsp+0x68]
    1d0a:	mov    QWORD PTR [rsp+0x38],rax
    1d0f:	mov    QWORD PTR [rsp+0x40],0x0
    1d18:	mov    QWORD PTR [rsp+0x48],r13
    1d1d:	mov    QWORD PTR [rsp+0x50],0x0
    1d26:	mov    rax,rcx
    1d29:	mov    QWORD PTR [rsp+0x58],rax
    1d2e:	mov    esi,0x2
    1d33:	mov    edx,0x6
    1d38:	mov    rcx,QWORD PTR [rsp+0x70]
    1d3d:	mov    rdi,rbx
    1d40:	call   1d45 <botlish_fn_21+0x1e5>
			1d41: R_X86_64_PLT32	rt_construct-0x4
    1d45:	test   rax,rax
    1d48:	jne    1d85 <botlish_fn_21+0x225>
    1d4e:	xor    rax,rax
    1d51:	mov    rbx,QWORD PTR [rsp+0x80]
    1d59:	mov    r12,QWORD PTR [rsp+0x88]
    1d61:	mov    r13,QWORD PTR [rsp+0x90]
    1d69:	mov    r14,QWORD PTR [rsp+0x98]
    1d71:	mov    r15,QWORD PTR [rsp+0xa0]
    1d79:	add    rsp,0xb0
    1d80:	mov    rsp,rbp
    1d83:	pop    rbp
    1d84:	ret
    1d85:	mov    QWORD PTR [rsp],r12
    1d89:	mov    QWORD PTR [rsp+0x8],r14
    1d8e:	mov    QWORD PTR [rsp+0x10],rax
    1d93:	mov    QWORD PTR [rsp+0x18],r15
    1d98:	mov    r13,r14
    1d9b:	mov    QWORD PTR [rsp+0x60],r15
    1da0:	mov    QWORD PTR [rsp+0x68],rax
    1da5:	jmp    1bcc <botlish_fn_21+0x6c>
    1daa:	mov    rax,QWORD PTR [rsp+0x68]
    1daf:	mov    rbx,QWORD PTR [rsp+0x80]
    1db7:	mov    r12,QWORD PTR [rsp+0x88]
    1dbf:	mov    r13,QWORD PTR [rsp+0x90]
    1dc7:	mov    r14,QWORD PTR [rsp+0x98]
    1dcf:	mov    r15,QWORD PTR [rsp+0xa0]
    1dd7:	add    rsp,0xb0
    1dde:	mov    rsp,rbp
    1de1:	pop    rbp
    1de2:	ret
    1de3:	add    BYTE PTR [rax],al
    1de5:	add    BYTE PTR [rax],al
    1de7:	add    BYTE PTR [rsi],al
    1de9:	add    BYTE PTR [rax],al
    1deb:	add    BYTE PTR [rax],al
    1ded:	add    BYTE PTR [rax],al
	...

0000000000001df0 <botlish_entry_21: esc_bytes<generic>>:
    1df0:	push   rbp
    1df1:	mov    rbp,rsp
    1df4:	sub    rsp,0x10
    1df8:	mov    QWORD PTR [rsp],r12
    1dfc:	mov    r12,rdi
    1dff:	mov    rsi,QWORD PTR [rdx]
    1e02:	mov    r9,QWORD PTR [rdx+0x8]
    1e06:	mov    rcx,QWORD PTR [rdx+0x10]
    1e0a:	mov    r8,QWORD PTR [rdx+0x18]
    1e0e:	mov    rdx,r9
    1e11:	call   1e16 <botlish_entry_21+0x26>
			1e12: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_bytes<generic>
    1e16:	mov    r9,QWORD PTR [rip+0x0]        # 1e1d <botlish_entry_21+0x2d>
			1e19: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1e1d:	mov    rsi,rax
    1e20:	mov    rdi,r12
    1e23:	call   r9
    1e26:	mov    r12,QWORD PTR [rsp]
    1e2a:	add    rsp,0x10
    1e2e:	mov    rsp,rbp
    1e31:	pop    rbp
    1e32:	ret

0000000000001e33 <botlish_fn_22: esc_char<generic>>:
    1e33:	push   rbp
    1e34:	mov    rbp,rsp
    1e37:	sub    rsp,0x50
    1e3b:	mov    QWORD PTR [rsp+0x20],rbx
    1e40:	mov    QWORD PTR [rsp+0x28],r12
    1e45:	mov    QWORD PTR [rsp+0x30],r13
    1e4a:	mov    QWORD PTR [rsp+0x38],r14
    1e4f:	mov    QWORD PTR [rsp+0x40],r15
    1e54:	mov    r12,rdi
    1e57:	mov    QWORD PTR [rsp+0x18],0x0
    1e60:	mov    QWORD PTR [rsp],rsi
    1e64:	mov    r14,rsi
    1e67:	mov    QWORD PTR [rsp+0x8],rdx
    1e6c:	mov    r15,rdx
    1e6f:	mov    QWORD PTR [rsp+0x10],rcx
    1e74:	mov    rbx,rcx
    1e77:	mov    rsi,r14
    1e7a:	mov    rdi,r12
    1e7d:	call   1e82 <botlish_fn_22+0x4f>
			1e7e: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1e82:	mov    rcx,rax
    1e85:	mov    r13,rax
    1e88:	test   rax,rcx
    1e8b:	je     1f75 <botlish_fn_22+0x142>
    1e91:	mov    rax,r13
    1e94:	mov    QWORD PTR [rsp],rax
    1e98:	mov    rsi,r13
    1e9b:	mov    rdi,r12
    1e9e:	call   1ea3 <botlish_fn_22+0x70>
			1e9f: R_X86_64_PLT32	rt_list_len-0x4
    1ea3:	sar    rax,1
    1ea6:	cmp    rax,0x1
    1eaa:	je     1eea <botlish_fn_22+0xb7>
    1eb0:	mov    edx,0x1
    1eb5:	mov    QWORD PTR [rsp+0x8],0x1
    1ebe:	mov    rdi,r12
    1ec1:	mov    rax,QWORD PTR [rdi+0x10]
    1ec5:	mov    rcx,QWORD PTR [rax+0xf0]
    1ecc:	mov    QWORD PTR [rsp+0x18],rcx
    1ed1:	mov    rsi,r13
    1ed4:	mov    r8,rbx
    1ed7:	call   1edc <botlish_fn_22+0xa9>
			1ed8: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_bytes<generic>
    1edc:	test   rax,rax
    1edf:	je     1f75 <botlish_fn_22+0x142>
    1ee5:	jmp    1fa0 <botlish_fn_22+0x16d>
    1eea:	mov    rsi,r13
    1eed:	mov    rax,QWORD PTR [rsi+0x8]
    1ef1:	mov    r13,rsi
    1ef4:	test   rax,rax
    1ef7:	jne    1f21 <botlish_fn_22+0xee>
    1efd:	mov    edx,0x1
    1f02:	mov    rsi,r13
    1f05:	mov    rdi,r12
    1f08:	call   1f0d <botlish_fn_22+0xda>
			1f09: R_X86_64_PLT32	rt_list_get-0x4
    1f0d:	test   rax,rax
    1f10:	je     1f75 <botlish_fn_22+0x142>
    1f16:	mov    rdx,rax
    1f19:	mov    rsi,r15
    1f1c:	jmp    1f2e <botlish_fn_22+0xfb>
    1f21:	mov    rsi,r13
    1f24:	mov    rax,QWORD PTR [rsi+0x10]
    1f28:	mov    rdx,QWORD PTR [rax]
    1f2b:	mov    rsi,r15
    1f2e:	mov    rdi,r12
    1f31:	call   1f36 <botlish_fn_22+0x103>
			1f32: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::is_unreserved<generic>
    1f36:	cmp    rax,0x6
    1f3a:	je     1f9d <botlish_fn_22+0x16a>
    1f40:	mov    edx,0x1
    1f45:	mov    QWORD PTR [rsp+0x8],0x1
    1f4e:	mov    rdi,r12
    1f51:	mov    rax,QWORD PTR [rdi+0x10]
    1f55:	mov    rcx,QWORD PTR [rax+0xf0]
    1f5c:	mov    QWORD PTR [rsp+0x18],rcx
    1f61:	mov    rsi,r13
    1f64:	mov    r8,rbx
    1f67:	call   1f6c <botlish_fn_22+0x139>
			1f68: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_bytes<generic>
    1f6c:	test   rax,rax
    1f6f:	jne    1f9a <botlish_fn_22+0x167>
    1f75:	xor    rax,rax
    1f78:	mov    rbx,QWORD PTR [rsp+0x20]
    1f7d:	mov    r12,QWORD PTR [rsp+0x28]
    1f82:	mov    r13,QWORD PTR [rsp+0x30]
    1f87:	mov    r14,QWORD PTR [rsp+0x38]
    1f8c:	mov    r15,QWORD PTR [rsp+0x40]
    1f91:	add    rsp,0x50
    1f95:	mov    rsp,rbp
    1f98:	pop    rbp
    1f99:	ret
    1f9a:	mov    r14,rax
    1f9d:	mov    rax,r14
    1fa0:	mov    rbx,QWORD PTR [rsp+0x20]
    1fa5:	mov    r12,QWORD PTR [rsp+0x28]
    1faa:	mov    r13,QWORD PTR [rsp+0x30]
    1faf:	mov    r14,QWORD PTR [rsp+0x38]
    1fb4:	mov    r15,QWORD PTR [rsp+0x40]
    1fb9:	add    rsp,0x50
    1fbd:	mov    rsp,rbp
    1fc0:	pop    rbp
    1fc1:	ret

0000000000001fc2 <botlish_entry_22: esc_char<generic>>:
    1fc2:	push   rbp
    1fc3:	mov    rbp,rsp
    1fc6:	sub    rsp,0x10
    1fca:	mov    QWORD PTR [rsp],r12
    1fce:	mov    r12,rdi
    1fd1:	mov    rsi,QWORD PTR [rdx]
    1fd4:	mov    r8,QWORD PTR [rdx+0x8]
    1fd8:	mov    rcx,QWORD PTR [rdx+0x10]
    1fdc:	mov    rdx,r8
    1fdf:	call   1fe4 <botlish_entry_22+0x22>
			1fe0: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_char<generic>
    1fe4:	mov    r8,QWORD PTR [rip+0x0]        # 1feb <botlish_entry_22+0x29>
			1fe7: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1feb:	mov    rsi,rax
    1fee:	mov    rdi,r12
    1ff1:	call   r8
    1ff4:	mov    r12,QWORD PTR [rsp]
    1ff8:	add    rsp,0x10
    1ffc:	mov    rsp,rbp
    1fff:	pop    rbp
    2000:	ret
    2001:	add    BYTE PTR [rax],al
    2003:	add    BYTE PTR [rax],al
    2005:	add    BYTE PTR [rax],al
	...

0000000000002008 <botlish_fn_23: esc_from<generic>>:
    2008:	push   rbp
    2009:	mov    rbp,rsp
    200c:	sub    rsp,0xb0
    2013:	mov    QWORD PTR [rsp+0x80],rbx
    201b:	mov    QWORD PTR [rsp+0x88],r12
    2023:	mov    QWORD PTR [rsp+0x90],r13
    202b:	mov    QWORD PTR [rsp+0x98],r14
    2033:	mov    QWORD PTR [rsp+0xa0],r15
    203b:	mov    r14,rdi
    203e:	mov    QWORD PTR [rsp+0x28],0x0
    2047:	mov    QWORD PTR [rsp+0x30],0x0
    2050:	mov    QWORD PTR [rsp],rsi
    2054:	mov    QWORD PTR [rsp+0x8],rdx
    2059:	mov    r12,rdx
    205c:	mov    QWORD PTR [rsp+0x10],rcx
    2061:	mov    QWORD PTR [rsp+0x68],rcx
    2066:	mov    QWORD PTR [rsp+0x18],r8
    206b:	mov    r15,r8
    206e:	mov    QWORD PTR [rsp+0x20],r9
    2073:	mov    r13,r9
    2076:	xor    eax,eax
    2078:	test   rsi,0x7
    207f:	jne    208e <botlish_fn_23+0x86>
    2085:	movzx  rax,BYTE PTR [rsi]
    2089:	cmp    al,0x2
    208b:	sete   al
    208e:	test   al,al
    2090:	jne    20b3 <botlish_fn_23+0xab>
    2096:	mov    rdi,r14
    2099:	mov    rax,QWORD PTR [rdi+0x10]
    209d:	mov    rcx,QWORD PTR [rax+0xc8]
    20a4:	mov    edx,0x1
    20a9:	call   20ae <botlish_fn_23+0xa6>
			20aa: R_X86_64_PLT32	rt_type_error-0x4
    20ae:	jmp    2270 <botlish_fn_23+0x268>
    20b3:	mov    rbx,rsi
    20b6:	mov    rdi,r14
    20b9:	call   20be <botlish_fn_23+0xb6>
			20ba: R_X86_64_PLT32	rt_str_len-0x4
    20be:	mov    rcx,r12
    20c1:	and    rcx,rax
    20c4:	mov    rdx,rax
    20c7:	test   rcx,0x1
    20ce:	jne    20f4 <botlish_fn_23+0xec>
    20d4:	mov    rsi,r12
    20d7:	mov    rdi,r14
    20da:	call   20df <botlish_fn_23+0xd7>
			20db: R_X86_64_PLT32	rt_int_cmp-0x4
    20df:	mov    ecx,0x2
    20e4:	test   rax,rax
    20e7:	cmovge rcx,QWORD PTR [rip+0x1f1]        # 22e0 <botlish_fn_23+0x2d8>
    20ef:	jmp    2104 <botlish_fn_23+0xfc>
    20f4:	mov    ecx,0x2
    20f9:	cmp    r12,rdx
    20fc:	cmovge rcx,QWORD PTR [rip+0x1dc]        # 22e0 <botlish_fn_23+0x2d8>
    2104:	cmp    rcx,0x6
    2108:	je     223f <botlish_fn_23+0x237>
    210e:	mov    QWORD PTR [rsp+0x28],0x3
    2117:	test   r12,0x1
    211e:	je     2136 <botlish_fn_23+0x12e>
    2124:	mov    rax,r12
    2127:	add    rax,0x2
    212b:	seto   cl
    212e:	test   cl,cl
    2130:	je     2146 <botlish_fn_23+0x13e>
    2136:	mov    edx,0x3
    213b:	mov    rsi,r12
    213e:	mov    rdi,r14
    2141:	call   2146 <botlish_fn_23+0x13e>
			2142: R_X86_64_PLT32	rt_int_add-0x4
    2146:	mov    QWORD PTR [rsp+0x28],rax
    214b:	mov    QWORD PTR [rsp+0x70],rax
    2150:	mov    QWORD PTR [rsp+0x30],0x3
    2159:	test   r12,0x1
    2160:	je     2178 <botlish_fn_23+0x170>
    2166:	mov    rcx,r12
    2169:	add    rcx,0x2
    216d:	seto   al
    2170:	test   al,al
    2172:	je     218b <botlish_fn_23+0x183>
    2178:	mov    edx,0x3
    217d:	mov    rsi,r12
    2180:	mov    rdi,r14
    2183:	call   2188 <botlish_fn_23+0x180>
			2184: R_X86_64_PLT32	rt_int_add-0x4
    2188:	mov    rcx,rax
    218b:	mov    QWORD PTR [rsp+0x30],rcx
    2190:	mov    rdx,r12
    2193:	mov    rsi,rbx
    2196:	mov    rdi,r14
    2199:	call   219e <botlish_fn_23+0x196>
			219a: R_X86_64_PLT32	rt_substr-0x4
    219e:	test   rax,rax
    21a1:	je     2270 <botlish_fn_23+0x268>
    21a7:	mov    QWORD PTR [rsp+0x8],rax
    21ac:	mov    rsi,rax
    21af:	mov    r12,r15
    21b2:	mov    rcx,r13
    21b5:	mov    rdx,r12
    21b8:	mov    rdi,r14
    21bb:	call   21c0 <botlish_fn_23+0x1b8>
			21bc: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_char<generic>
    21c0:	test   rax,rax
    21c3:	je     2270 <botlish_fn_23+0x268>
    21c9:	mov    QWORD PTR [rsp+0x8],rax
    21ce:	lea    rcx,[rsp+0x48]
    21d3:	mov    QWORD PTR [rsp+0x48],0x0
    21dc:	mov    r11,QWORD PTR [rsp+0x68]
    21e1:	mov    QWORD PTR [rsp+0x50],r11
    21e6:	mov    QWORD PTR [rsp+0x58],0x0
    21ef:	mov    QWORD PTR [rsp+0x60],rax
    21f4:	mov    esi,0x2
    21f9:	mov    edx,0x4
    21fe:	mov    rdi,r14
    2201:	call   2206 <botlish_fn_23+0x1fe>
			2202: R_X86_64_PLT32	rt_construct-0x4
    2206:	test   rax,rax
    2209:	je     2270 <botlish_fn_23+0x268>
    220f:	mov    QWORD PTR [rsp],rbx
    2213:	mov    rcx,QWORD PTR [rsp+0x70]
    2218:	mov    QWORD PTR [rsp+0x8],rcx
    221d:	mov    QWORD PTR [rsp+0x10],rax
    2222:	mov    QWORD PTR [rsp+0x18],r12
    2227:	mov    QWORD PTR [rsp+0x20],r13
    222c:	mov    QWORD PTR [rsp+0x68],rax
    2231:	mov    r15,r12
    2234:	mov    r12,rcx
    2237:	mov    rsi,rbx
    223a:	jmp    2076 <botlish_fn_23+0x6e>
    223f:	mov    r11,QWORD PTR [rsp+0x68]
    2244:	xor    rsi,rsi
    2247:	lea    rcx,[rsp+0x38]
    224c:	mov    QWORD PTR [rsp+0x38],0x0
    2255:	mov    QWORD PTR [rsp+0x40],r11
    225a:	mov    edx,0x2
    225f:	mov    rdi,r14
    2262:	call   2267 <botlish_fn_23+0x25f>
			2263: R_X86_64_PLT32	rt_construct-0x4
    2267:	test   rax,rax
    226a:	jne    22a7 <botlish_fn_23+0x29f>
    2270:	xor    rax,rax
    2273:	mov    rbx,QWORD PTR [rsp+0x80]
    227b:	mov    r12,QWORD PTR [rsp+0x88]
    2283:	mov    r13,QWORD PTR [rsp+0x90]
    228b:	mov    r14,QWORD PTR [rsp+0x98]
    2293:	mov    r15,QWORD PTR [rsp+0xa0]
    229b:	add    rsp,0xb0
    22a2:	mov    rsp,rbp
    22a5:	pop    rbp
    22a6:	ret
    22a7:	mov    rbx,QWORD PTR [rsp+0x80]
    22af:	mov    r12,QWORD PTR [rsp+0x88]
    22b7:	mov    r13,QWORD PTR [rsp+0x90]
    22bf:	mov    r14,QWORD PTR [rsp+0x98]
    22c7:	mov    r15,QWORD PTR [rsp+0xa0]
    22cf:	add    rsp,0xb0
    22d6:	mov    rsp,rbp
    22d9:	pop    rbp
    22da:	ret
    22db:	add    BYTE PTR [rax],al
    22dd:	add    BYTE PTR [rax],al
    22df:	add    BYTE PTR [rsi],al
    22e1:	add    BYTE PTR [rax],al
    22e3:	add    BYTE PTR [rax],al
    22e5:	add    BYTE PTR [rax],al
	...

00000000000022e8 <botlish_entry_23: esc_from<generic>>:
    22e8:	push   rbp
    22e9:	mov    rbp,rsp
    22ec:	mov    rsi,QWORD PTR [rdx]
    22ef:	mov    r10,QWORD PTR [rdx+0x8]
    22f3:	mov    rcx,QWORD PTR [rdx+0x10]
    22f7:	mov    r8,QWORD PTR [rdx+0x18]
    22fb:	mov    r9,QWORD PTR [rdx+0x20]
    22ff:	mov    rdx,r10
    2302:	call   2307 <botlish_entry_23+0x1f>
			2303: R_X86_64_PLT32	botlish_fn_23-0x4 ; esc_from<generic>
    2307:	mov    rsp,rbp
    230a:	pop    rbp
    230b:	ret
    230c:	add    BYTE PTR [rax],al
	...

0000000000002310 <botlish_fn_24: check<generic>>:
    2310:	push   rbp
    2311:	mov    rbp,rsp
    2314:	sub    rsp,0x80
    231b:	mov    QWORD PTR [rsp+0x50],rbx
    2320:	mov    QWORD PTR [rsp+0x58],r12
    2325:	mov    QWORD PTR [rsp+0x60],r13
    232a:	mov    QWORD PTR [rsp+0x68],r14
    232f:	mov    QWORD PTR [rsp+0x70],r15
    2334:	mov    r14,rdi
    2337:	mov    QWORD PTR [rsp+0x28],0x0
    2340:	mov    QWORD PTR [rsp+0x30],0x0
    2349:	mov    QWORD PTR [rsp],rsi
    234d:	mov    r15,rsi
    2350:	mov    QWORD PTR [rsp+0x8],rdx
    2355:	mov    QWORD PTR [rsp+0x10],rcx
    235a:	mov    r12,rcx
    235d:	mov    QWORD PTR [rsp+0x18],r8
    2362:	mov    r13,r8
    2365:	mov    QWORD PTR [rsp+0x20],r9
    236a:	mov    rbx,r9
    236d:	mov    QWORD PTR [rsp+0x38],rdx
    2372:	test   rsi,0x1
    2379:	mov    r15,rsi
    237c:	jne    23a7 <botlish_fn_24+0x97>
    2382:	mov    edx,0x1
    2387:	mov    rsi,r15
    238a:	mov    rdi,r14
    238d:	call   2392 <botlish_fn_24+0x82>
			238e: R_X86_64_PLT32	rt_int_cmp-0x4
    2392:	mov    ecx,0x2
    2397:	test   rax,rax
    239a:	cmovle rcx,QWORD PTR [rip+0x19e]        # 2540 <botlish_fn_24+0x230>
    23a2:	jmp    23bb <botlish_fn_24+0xab>
    23a7:	mov    ecx,0x2
    23ac:	mov    rsi,r15
    23af:	cmp    rsi,0x1
    23b3:	cmovle rcx,QWORD PTR [rip+0x185]        # 2540 <botlish_fn_24+0x230>
    23bb:	cmp    rcx,0x6
    23bf:	je     250f <botlish_fn_24+0x1ff>
    23c5:	mov    rdx,r12
    23c8:	mov    rsi,rbx
    23cb:	mov    rdi,r14
    23ce:	call   23d3 <botlish_fn_24+0xc3>
			23cf: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::is_emailish<generic>
    23d3:	test   rax,rax
    23d6:	jne    2404 <botlish_fn_24+0xf4>
    23dc:	xor    rax,rax
    23df:	mov    rbx,QWORD PTR [rsp+0x50]
    23e4:	mov    r12,QWORD PTR [rsp+0x58]
    23e9:	mov    r13,QWORD PTR [rsp+0x60]
    23ee:	mov    r14,QWORD PTR [rsp+0x68]
    23f3:	mov    r15,QWORD PTR [rsp+0x70]
    23f8:	add    rsp,0x80
    23ff:	mov    rsp,rbp
    2402:	pop    rbp
    2403:	ret
    2404:	cmp    rax,0x6
    2408:	je     2426 <botlish_fn_24+0x116>
    240e:	mov    edx,0x1
    2413:	mov    QWORD PTR [rsp+0x28],0x1
    241c:	mov    QWORD PTR [rsp+0x40],rdx
    2421:	jmp    2439 <botlish_fn_24+0x129>
    2426:	mov    edx,0x3
    242b:	mov    QWORD PTR [rsp+0x40],rdx
    2430:	mov    QWORD PTR [rsp+0x28],0x3
    2439:	mov    edx,0x3
    243e:	mov    QWORD PTR [rsp+0x30],0x3
    2447:	mov    rsi,r15
    244a:	test   rsi,0x1
    2451:	jne    245f <botlish_fn_24+0x14f>
    2457:	mov    rsi,r15
    245a:	jmp    248e <botlish_fn_24+0x17e>
    245f:	mov    rsi,r15
    2462:	mov    rax,rsi
    2465:	sub    rax,0x3
    2469:	seto   cl
    246c:	add    rax,0x1
    2473:	test   cl,cl
    2475:	je     2483 <botlish_fn_24+0x173>
    247b:	mov    rsi,r15
    247e:	jmp    248e <botlish_fn_24+0x17e>
    2483:	mov    rsi,rax
    2486:	mov    r15,rax
    2489:	jmp    249c <botlish_fn_24+0x18c>
    248e:	mov    rdi,r14
    2491:	call   2496 <botlish_fn_24+0x186>
			2492: R_X86_64_PLT32	rt_int_sub-0x4
    2496:	mov    rsi,rax
    2499:	mov    r15,rax
    249c:	mov    QWORD PTR [rsp],rsi
    24a0:	mov    rdx,QWORD PTR [rsp+0x40]
    24a5:	mov    rsi,QWORD PTR [rsp+0x38]
    24aa:	mov    rdi,rsi
    24ad:	and    rdi,rdx
    24b0:	test   rdi,0x1
    24b7:	je     24dc <botlish_fn_24+0x1cc>
    24bd:	lea    r8,[rdx-0x1]
    24c1:	mov    rax,rsi
    24c4:	add    rax,r8
    24c7:	seto   r9b
    24cb:	test   r9b,r9b
    24ce:	jne    24dc <botlish_fn_24+0x1cc>
    24d4:	mov    rsi,r15
    24d7:	jmp    24e7 <botlish_fn_24+0x1d7>
    24dc:	mov    rdi,r14
    24df:	call   24e4 <botlish_fn_24+0x1d4>
			24e0: R_X86_64_PLT32	rt_int_add-0x4
    24e4:	mov    rsi,r15
    24e7:	mov    rsi,r15
    24ea:	mov    QWORD PTR [rsp],rsi
    24ee:	mov    QWORD PTR [rsp+0x8],rax
    24f3:	mov    QWORD PTR [rsp+0x10],r12
    24f8:	mov    r8,r13
    24fb:	mov    QWORD PTR [rsp+0x18],r8
    2500:	mov    QWORD PTR [rsp+0x20],rbx
    2505:	mov    QWORD PTR [rsp+0x38],rax
    250a:	jmp    2372 <botlish_fn_24+0x62>
    250f:	mov    rax,QWORD PTR [rsp+0x38]
    2514:	mov    rbx,QWORD PTR [rsp+0x50]
    2519:	mov    r12,QWORD PTR [rsp+0x58]
    251e:	mov    r13,QWORD PTR [rsp+0x60]
    2523:	mov    r14,QWORD PTR [rsp+0x68]
    2528:	mov    r15,QWORD PTR [rsp+0x70]
    252d:	add    rsp,0x80
    2534:	mov    rsp,rbp
    2537:	pop    rbp
    2538:	ret
    2539:	add    BYTE PTR [rax],al
    253b:	add    BYTE PTR [rax],al
    253d:	add    BYTE PTR [rax],al
    253f:	add    BYTE PTR [rsi],al
    2541:	add    BYTE PTR [rax],al
    2543:	add    BYTE PTR [rax],al
    2545:	add    BYTE PTR [rax],al
	...

0000000000002548 <botlish_entry_24: check<generic>>:
    2548:	push   rbp
    2549:	mov    rbp,rsp
    254c:	mov    rsi,QWORD PTR [rdx]
    254f:	mov    r10,QWORD PTR [rdx+0x8]
    2553:	mov    rcx,QWORD PTR [rdx+0x10]
    2557:	mov    r8,QWORD PTR [rdx+0x18]
    255b:	mov    r9,QWORD PTR [rdx+0x20]
    255f:	mov    rdx,r10
    2562:	call   2567 <botlish_entry_24+0x1f>
			2563: R_X86_64_PLT32	botlish_fn_24-0x4 ; check<generic>
    2567:	mov    rsp,rbp
    256a:	pop    rbp
    256b:	ret

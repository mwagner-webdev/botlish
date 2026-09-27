; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 10258  (per function: 1588 39 289 617 74 74 74 125 125 753 262 222 272 528 468 1244 155 125 103 453 750 486 828 604)
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
;   botlish_fn_9 / botlish_entry_9 -> web::emailish?<generic>
;   botlish_fn_10 / botlish_entry_10 -> char_at<generic>
;   botlish_fn_11 / botlish_entry_11 -> char_at<generic>
;   botlish_fn_12 / botlish_entry_12 -> local_char?<generic>
;   botlish_fn_13 / botlish_entry_13 -> scan_while<generic>
;   botlish_fn_14 / botlish_entry_14 -> tld?<generic>
;   botlish_fn_15 / botlish_entry_15 -> domain?<generic>
;   botlish_fn_16 / botlish_entry_16 -> web::is_unreserved<generic>
;   botlish_fn_17 / botlish_entry_17 -> web::uri_escape_text<generic>
;   botlish_fn_18 / botlish_entry_18 -> high_nibble<generic>
;   botlish_fn_19 / botlish_entry_19 -> hex_pair<generic>
;   botlish_fn_20 / botlish_entry_20 -> esc_bytes<generic>
;   botlish_fn_21 / botlish_entry_21 -> esc_char<generic>
;   botlish_fn_22 / botlish_entry_22 -> esc_from<generic>
;   botlish_fn_23 / botlish_entry_23 -> check<generic>


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
			164: R_X86_64_GOTPCREL	botlish_entry_9-0x4 ; web::emailish?<generic>
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
     410:	mov    esi,0x10
     415:	mov    rdx,QWORD PTR [rip+0x0]        # 41c <botlish_fn_0+0x41c>
			418: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; web::is_unreserved<generic>
     41c:	mov    ecx,0x1
     421:	mov    rdi,QWORD PTR [rsp+0x180]
     429:	call   42e <botlish_fn_0+0x42e>
			42a: R_X86_64_PLT32	rt_closure_new-0x4
     42e:	mov    QWORD PTR [rsp+0x10],rax
     433:	lea    r8,[rsp+0x160]
     43b:	mov    rcx,rbx
     43e:	mov    QWORD PTR [rsp+0x160],rcx
     446:	mov    QWORD PTR [rsp+0x168],rax
     44e:	mov    esi,0x11
     453:	mov    rdx,QWORD PTR [rip+0x0]        # 45a <botlish_fn_0+0x45a>
			456: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; web::uri_escape_text<generic>
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
			48d: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::uri_escape_text<generic>
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
			4e2: R_X86_64_PLT32	botlish_fn_23-0x4 ; check<generic>
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
			537: R_X86_64_PLT32	botlish_fn_23-0x4 ; check<generic>
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

0000000000000b50 <botlish_fn_9: web::emailish?<generic>>:
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
     b91:	mov    r13,rdx
     b94:	jmp    ba6 <botlish_fn_9+0x56>
     b99:	movzx  rax,BYTE PTR [rdx]
     b9d:	mov    r13,rdx
     ba0:	cmp    al,0x2
     ba2:	sete   r8b
     ba6:	test   r8b,r8b
     ba9:	jne    bcc <botlish_fn_9+0x7c>
     baf:	mov    rdx,QWORD PTR [rdi+0x10]
     bb3:	mov    rcx,QWORD PTR [rdx+0xc8]
     bba:	mov    edx,0x1
     bbf:	mov    rsi,r13
     bc2:	call   bc7 <botlish_fn_9+0x77>
			bc3: R_X86_64_PLT32	rt_type_error-0x4
     bc7:	jmp    d91 <botlish_fn_9+0x241>
     bcc:	mov    r14,rdi
     bcf:	mov    rsi,r13
     bd2:	call   bd7 <botlish_fn_9+0x87>
			bd3: R_X86_64_PLT32	rt_str_len-0x4
     bd7:	mov    rbx,rax
     bda:	mov    QWORD PTR [rsp+0x8],rax
     bdf:	mov    rsi,r12
     be2:	mov    rsi,QWORD PTR [rsi+0x20]
     be6:	mov    rsi,QWORD PTR [rsi]
     be9:	mov    QWORD PTR [rsp+0x10],rsi
     bee:	lea    r8,[rsp+0x20]
     bf3:	mov    QWORD PTR [rsp+0x20],rsi
     bf8:	mov    esi,0xc
     bfd:	mov    rdx,QWORD PTR [rip+0x0]        # c04 <botlish_fn_9+0xb4>
			c00: R_X86_64_GOTPCREL	botlish_entry_12-0x4 ; local_char?<generic>
     c04:	mov    r12d,0x1
     c0a:	mov    rcx,r12
     c0d:	mov    rdi,r14
     c10:	call   c15 <botlish_fn_9+0xc5>
			c11: R_X86_64_PLT32	rt_closure_new-0x4
     c15:	mov    r15,r12
     c18:	mov    QWORD PTR [rsp+0x10],rax
     c1d:	mov    QWORD PTR [rsp+0x18],0x1
     c26:	mov    rdx,rax
     c29:	mov    rcx,rbx
     c2c:	mov    rsi,r15
     c2f:	mov    rdi,r14
     c32:	mov    r8,r13
     c35:	call   c3a <botlish_fn_9+0xea>
			c36: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<generic>
     c3a:	mov    rcx,rax
     c3d:	mov    r12,rax
     c40:	test   rax,rcx
     c43:	je     d91 <botlish_fn_9+0x241>
     c49:	mov    rax,r12
     c4c:	mov    QWORD PTR [rsp+0x10],rax
     c51:	test   rax,0x1
     c57:	jne    c80 <botlish_fn_9+0x130>
     c5d:	mov    rdx,r15
     c60:	mov    rsi,r12
     c63:	mov    rdi,r14
     c66:	call   c6b <botlish_fn_9+0x11b>
			c67: R_X86_64_PLT32	rt_int_cmp-0x4
     c6b:	mov    ecx,0x2
     c70:	test   rax,rax
     c73:	cmove  rcx,QWORD PTR [rip+0x175]        # df0 <botlish_fn_9+0x2a0>
     c7b:	jmp    c91 <botlish_fn_9+0x141>
     c80:	mov    ecx,0x2
     c85:	cmp    r12,0x1
     c89:	cmove  rcx,QWORD PTR [rip+0x15f]        # df0 <botlish_fn_9+0x2a0>
     c91:	cmp    rcx,0x6
     c95:	je     dc5 <botlish_fn_9+0x275>
     c9b:	mov    rax,r12
     c9e:	and    rax,rbx
     ca1:	test   rax,0x1
     ca7:	jne    cd0 <botlish_fn_9+0x180>
     cad:	mov    rdx,rbx
     cb0:	mov    rsi,r12
     cb3:	mov    rdi,r14
     cb6:	call   cbb <botlish_fn_9+0x16b>
			cb7: R_X86_64_PLT32	rt_int_cmp-0x4
     cbb:	mov    ecx,0x2
     cc0:	test   rax,rax
     cc3:	cmovge rcx,QWORD PTR [rip+0x125]        # df0 <botlish_fn_9+0x2a0>
     ccb:	jmp    ce0 <botlish_fn_9+0x190>
     cd0:	mov    ecx,0x2
     cd5:	cmp    r12,rbx
     cd8:	cmovge rcx,QWORD PTR [rip+0x110]        # df0 <botlish_fn_9+0x2a0>
     ce0:	cmp    rcx,0x6
     ce4:	je     dbb <botlish_fn_9+0x26b>
     cea:	lea    rcx,[rsp+0x28]
     cef:	mov    rdx,r13
     cf2:	mov    rsi,r12
     cf5:	mov    rdi,r14
     cf8:	call   cfd <botlish_fn_9+0x1ad>
			cf9: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
     cfd:	test   rax,rax
     d00:	mov    rsi,rax
     d03:	je     d91 <botlish_fn_9+0x241>
     d09:	mov    rdx,QWORD PTR [rsp+0x28]
     d0e:	mov    rcx,QWORD PTR [rsp+0x30]
     d13:	mov    rdi,r14
     d16:	mov    rax,QWORD PTR [rdi+0x10]
     d1a:	mov    r8,QWORD PTR [rax+0xd0]
     d21:	call   d26 <botlish_fn_9+0x1d6>
			d22: R_X86_64_PLT32	rt_str_region_eq-0x4
     d26:	cmp    rax,0x6
     d2a:	je     d3a <botlish_fn_9+0x1ea>
     d30:	mov    eax,0x2
     d35:	jmp    dca <botlish_fn_9+0x27a>
     d3a:	mov    QWORD PTR [rsp+0x18],0x3
     d43:	test   r12,0x1
     d4a:	je     d62 <botlish_fn_9+0x212>
     d50:	mov    rsi,r12
     d53:	add    rsi,0x2
     d57:	seto   al
     d5a:	test   al,al
     d5c:	je     d75 <botlish_fn_9+0x225>
     d62:	mov    edx,0x3
     d67:	mov    rsi,r12
     d6a:	mov    rdi,r14
     d6d:	call   d72 <botlish_fn_9+0x222>
			d6e: R_X86_64_PLT32	rt_int_add-0x4
     d72:	mov    rsi,rax
     d75:	mov    QWORD PTR [rsp+0x10],rsi
     d7a:	mov    rcx,r13
     d7d:	mov    rdx,rbx
     d80:	mov    rdi,r14
     d83:	call   d88 <botlish_fn_9+0x238>
			d84: R_X86_64_PLT32	botlish_fn_15-0x4 ; domain?<generic>
     d88:	test   rax,rax
     d8b:	jne    dca <botlish_fn_9+0x27a>
     d91:	xor    rax,rax
     d94:	mov    rbx,QWORD PTR [rsp+0x40]
     d99:	mov    r12,QWORD PTR [rsp+0x48]
     d9e:	mov    r13,QWORD PTR [rsp+0x50]
     da3:	mov    r14,QWORD PTR [rsp+0x58]
     da8:	mov    r15,QWORD PTR [rsp+0x60]
     dad:	add    rsp,0x70
     db1:	mov    rsp,rbp
     db4:	pop    rbp
     db5:	ret
     db6:	jmp    dca <botlish_fn_9+0x27a>
     dbb:	mov    eax,0x2
     dc0:	jmp    dca <botlish_fn_9+0x27a>
     dc5:	mov    eax,0x2
     dca:	mov    rbx,QWORD PTR [rsp+0x40]
     dcf:	mov    r12,QWORD PTR [rsp+0x48]
     dd4:	mov    r13,QWORD PTR [rsp+0x50]
     dd9:	mov    r14,QWORD PTR [rsp+0x58]
     dde:	mov    r15,QWORD PTR [rsp+0x60]
     de3:	add    rsp,0x70
     de7:	mov    rsp,rbp
     dea:	pop    rbp
     deb:	ret
     dec:	add    BYTE PTR [rax],al
     dee:	add    BYTE PTR [rax],al
     df0:	(bad)
     df1:	add    BYTE PTR [rax],al
     df3:	add    BYTE PTR [rax],al
     df5:	add    BYTE PTR [rax],al
	...

0000000000000df8 <botlish_entry_9: web::emailish?<generic>>:
     df8:	push   rbp
     df9:	mov    rbp,rsp
     dfc:	mov    rdx,QWORD PTR [rdx]
     dff:	call   e04 <botlish_entry_9+0xc>
			e00: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<generic>
     e04:	mov    rsp,rbp
     e07:	pop    rbp
     e08:	ret

0000000000000e09 <botlish_fn_10: char_at<generic>>:
     e09:	push   rbp
     e0a:	mov    rbp,rsp
     e0d:	sub    rsp,0x50
     e11:	mov    QWORD PTR [rsp+0x20],rbx
     e16:	mov    QWORD PTR [rsp+0x28],r12
     e1b:	mov    QWORD PTR [rsp+0x30],r13
     e20:	mov    QWORD PTR [rsp+0x38],r14
     e25:	mov    QWORD PTR [rsp+0x40],r15
     e2a:	mov    r12,rdi
     e2d:	mov    r15,rcx
     e30:	mov    QWORD PTR [rsp],rsi
     e34:	mov    QWORD PTR [rsp+0x8],rdx
     e39:	mov    r13,rdx
     e3c:	mov    QWORD PTR [rsp+0x10],0x3
     e45:	test   rsi,0x1
     e4c:	jne    e5a <botlish_fn_10+0x51>
     e52:	mov    rbx,rsi
     e55:	jmp    e7a <botlish_fn_10+0x71>
     e5a:	mov    rax,rsi
     e5d:	add    rax,0x2
     e61:	mov    rbx,rsi
     e64:	seto   cl
     e67:	test   cl,cl
     e69:	jne    e7a <botlish_fn_10+0x71>
     e6f:	mov    rdi,r12
     e72:	mov    r14,rax
     e75:	jmp    e90 <botlish_fn_10+0x87>
     e7a:	mov    edx,0x3
     e7f:	mov    rsi,rbx
     e82:	mov    rdi,r12
     e85:	call   e8a <botlish_fn_10+0x81>
			e86: R_X86_64_PLT32	rt_int_add-0x4
     e8a:	mov    r14,rax
     e8d:	mov    rdi,r12
     e90:	mov    rcx,r14
     e93:	mov    rdx,rbx
     e96:	mov    rsi,r13
     e99:	call   e9e <botlish_fn_10+0x95>
			e9a: R_X86_64_PLT32	rt_str_region_check-0x4
     e9e:	test   rax,rax
     ea1:	jne    ecc <botlish_fn_10+0xc3>
     ea7:	xor    rax,rax
     eaa:	mov    rbx,QWORD PTR [rsp+0x20]
     eaf:	mov    r12,QWORD PTR [rsp+0x28]
     eb4:	mov    r13,QWORD PTR [rsp+0x30]
     eb9:	mov    r14,QWORD PTR [rsp+0x38]
     ebe:	mov    r15,QWORD PTR [rsp+0x40]
     ec3:	add    rsp,0x50
     ec7:	mov    rsp,rbp
     eca:	pop    rbp
     ecb:	ret
     ecc:	mov    rcx,r15
     ecf:	mov    QWORD PTR [rcx],rbx
     ed2:	mov    rax,r14
     ed5:	mov    QWORD PTR [rcx+0x8],rax
     ed9:	mov    rax,r13
     edc:	mov    rbx,QWORD PTR [rsp+0x20]
     ee1:	mov    r12,QWORD PTR [rsp+0x28]
     ee6:	mov    r13,QWORD PTR [rsp+0x30]
     eeb:	mov    r14,QWORD PTR [rsp+0x38]
     ef0:	mov    r15,QWORD PTR [rsp+0x40]
     ef5:	add    rsp,0x50
     ef9:	mov    rsp,rbp
     efc:	pop    rbp
     efd:	ret

0000000000000efe <botlish_entry_10: char_at<generic>>:
     efe:	push   rbp
     eff:	mov    rbp,rsp
     f02:	ud2

0000000000000f04 <botlish_fn_11: char_at<generic>>:
     f04:	push   rbp
     f05:	mov    rbp,rsp
     f08:	sub    rsp,0x40
     f0c:	mov    QWORD PTR [rsp+0x20],rbx
     f11:	mov    QWORD PTR [rsp+0x28],r12
     f16:	mov    QWORD PTR [rsp+0x30],r13
     f1b:	mov    r12,rdi
     f1e:	mov    QWORD PTR [rsp],rsi
     f22:	mov    QWORD PTR [rsp+0x8],rdx
     f27:	mov    r13,rdx
     f2a:	mov    QWORD PTR [rsp+0x10],0x3
     f33:	test   rsi,0x1
     f3a:	jne    f48 <botlish_fn_11+0x44>
     f40:	mov    rbx,rsi
     f43:	jmp    f5d <botlish_fn_11+0x59>
     f48:	mov    rcx,rsi
     f4b:	add    rcx,0x2
     f4f:	mov    rbx,rsi
     f52:	seto   al
     f55:	test   al,al
     f57:	je     f70 <botlish_fn_11+0x6c>
     f5d:	mov    edx,0x3
     f62:	mov    rsi,rbx
     f65:	mov    rdi,r12
     f68:	call   f6d <botlish_fn_11+0x69>
			f69: R_X86_64_PLT32	rt_int_add-0x4
     f6d:	mov    rcx,rax
     f70:	mov    QWORD PTR [rsp+0x10],rcx
     f75:	mov    rdx,rbx
     f78:	mov    rsi,r13
     f7b:	mov    rdi,r12
     f7e:	call   f83 <botlish_fn_11+0x7f>
			f7f: R_X86_64_PLT32	rt_substr-0x4
     f83:	test   rax,rax
     f86:	jne    fa7 <botlish_fn_11+0xa3>
     f8c:	xor    rax,rax
     f8f:	mov    rbx,QWORD PTR [rsp+0x20]
     f94:	mov    r12,QWORD PTR [rsp+0x28]
     f99:	mov    r13,QWORD PTR [rsp+0x30]
     f9e:	add    rsp,0x40
     fa2:	mov    rsp,rbp
     fa5:	pop    rbp
     fa6:	ret
     fa7:	mov    rbx,QWORD PTR [rsp+0x20]
     fac:	mov    r12,QWORD PTR [rsp+0x28]
     fb1:	mov    r13,QWORD PTR [rsp+0x30]
     fb6:	add    rsp,0x40
     fba:	mov    rsp,rbp
     fbd:	pop    rbp
     fbe:	ret

0000000000000fbf <botlish_entry_11: char_at<generic>>:
     fbf:	push   rbp
     fc0:	mov    rbp,rsp
     fc3:	mov    rsi,QWORD PTR [rdx]
     fc6:	mov    rdx,QWORD PTR [rdx+0x8]
     fca:	call   fcf <botlish_entry_11+0x10>
			fcb: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
     fcf:	mov    rsp,rbp
     fd2:	pop    rbp
     fd3:	ret

0000000000000fd4 <botlish_fn_12: local_char?<generic>>:
     fd4:	push   rbp
     fd5:	mov    rbp,rsp
     fd8:	sub    rsp,0x20
     fdc:	mov    QWORD PTR [rsp],rbx
     fe0:	mov    QWORD PTR [rsp+0x8],r12
     fe5:	mov    QWORD PTR [rsp+0x10],r13
     fea:	mov    r12,rsi
     fed:	xor    esi,esi
     fef:	test   rdx,0x7
     ff6:	je     1004 <botlish_fn_12+0x30>
     ffc:	mov    rbx,rdx
     fff:	jmp    1011 <botlish_fn_12+0x3d>
    1004:	movzx  rax,BYTE PTR [rdx]
    1008:	mov    rbx,rdx
    100b:	cmp    al,0x2
    100d:	sete   sil
    1011:	test   sil,sil
    1014:	jne    1037 <botlish_fn_12+0x63>
    101a:	mov    rax,QWORD PTR [rdi+0x10]
    101e:	mov    rcx,QWORD PTR [rax+0xd8]
    1025:	mov    edx,0x1
    102a:	mov    rsi,rbx
    102d:	call   1032 <botlish_fn_12+0x5e>
			102e: R_X86_64_PLT32	rt_type_error-0x4
    1032:	jmp    104b <botlish_fn_12+0x77>
    1037:	mov    r13,rdi
    103a:	mov    rsi,rbx
    103d:	call   1042 <botlish_fn_12+0x6e>
			103e: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    1042:	test   rax,rax
    1045:	jne    1065 <botlish_fn_12+0x91>
    104b:	xor    rax,rax
    104e:	mov    rbx,QWORD PTR [rsp]
    1052:	mov    r12,QWORD PTR [rsp+0x8]
    1057:	mov    r13,QWORD PTR [rsp+0x10]
    105c:	add    rsp,0x20
    1060:	mov    rsp,rbp
    1063:	pop    rbp
    1064:	ret
    1065:	cmp    rax,0x6
    1069:	je     10a2 <botlish_fn_12+0xce>
    106f:	mov    rsi,r12
    1072:	mov    rax,QWORD PTR [rsi+0x20]
    1076:	mov    rsi,QWORD PTR [rax]
    1079:	mov    rdx,rbx
    107c:	mov    rdi,r13
    107f:	call   1084 <botlish_fn_12+0xb0>
			1080: R_X86_64_PLT32	rt_set_contains-0x4
    1084:	cmp    rax,0x6
    1088:	je     1098 <botlish_fn_12+0xc4>
    108e:	mov    eax,0x2
    1093:	jmp    10a7 <botlish_fn_12+0xd3>
    1098:	mov    eax,0x6
    109d:	jmp    10a7 <botlish_fn_12+0xd3>
    10a2:	mov    eax,0x6
    10a7:	mov    rbx,QWORD PTR [rsp]
    10ab:	mov    r12,QWORD PTR [rsp+0x8]
    10b0:	mov    r13,QWORD PTR [rsp+0x10]
    10b5:	add    rsp,0x20
    10b9:	mov    rsp,rbp
    10bc:	pop    rbp
    10bd:	ret

00000000000010be <botlish_entry_12: local_char?<generic>>:
    10be:	push   rbp
    10bf:	mov    rbp,rsp
    10c2:	mov    rdx,QWORD PTR [rdx]
    10c5:	call   10ca <botlish_entry_12+0xc>
			10c6: R_X86_64_PLT32	botlish_fn_12-0x4 ; local_char?<generic>
    10ca:	mov    rsp,rbp
    10cd:	pop    rbp
    10ce:	ret
	...

00000000000010d0 <botlish_fn_13: scan_while<generic>>:
    10d0:	push   rbp
    10d1:	mov    rbp,rsp
    10d4:	sub    rsp,0x60
    10d8:	mov    QWORD PTR [rsp+0x30],rbx
    10dd:	mov    QWORD PTR [rsp+0x38],r12
    10e2:	mov    QWORD PTR [rsp+0x40],r13
    10e7:	mov    QWORD PTR [rsp+0x48],r14
    10ec:	mov    QWORD PTR [rsp+0x50],r15
    10f1:	mov    rbx,rcx
    10f4:	mov    r14,rdi
    10f7:	mov    QWORD PTR [rsp+0x20],0x0
    1100:	mov    QWORD PTR [rsp],rdx
    1104:	mov    r13,rdx
    1107:	mov    QWORD PTR [rsp+0x8],rcx
    110c:	mov    QWORD PTR [rsp+0x10],r8
    1111:	mov    r12,r8
    1114:	mov    QWORD PTR [rsp+0x18],rsi
    1119:	mov    rax,rsi
    111c:	mov    rcx,rbx
    111f:	mov    r15,rsi
    1122:	mov    rcx,rbx
    1125:	and    rax,rcx
    1128:	test   rax,0x1
    112e:	jne    1157 <botlish_fn_13+0x87>
    1134:	mov    rdx,rbx
    1137:	mov    rsi,r15
    113a:	mov    rdi,r14
    113d:	call   1142 <botlish_fn_13+0x72>
			113e: R_X86_64_PLT32	rt_int_cmp-0x4
    1142:	mov    ecx,0x2
    1147:	test   rax,rax
    114a:	cmovl  rcx,QWORD PTR [rip+0x146]        # 1298 <botlish_fn_13+0x1c8>
    1152:	jmp    116d <botlish_fn_13+0x9d>
    1157:	mov    ecx,0x2
    115c:	mov    rax,r15
    115f:	mov    rdx,rbx
    1162:	cmp    rax,rdx
    1165:	cmovl  rcx,QWORD PTR [rip+0x12b]        # 1298 <botlish_fn_13+0x1c8>
    116d:	cmp    rcx,0x6
    1171:	je     119c <botlish_fn_13+0xcc>
    1177:	mov    rax,rbx
    117a:	mov    rbx,QWORD PTR [rsp+0x30]
    117f:	mov    r12,QWORD PTR [rsp+0x38]
    1184:	mov    r13,QWORD PTR [rsp+0x40]
    1189:	mov    r14,QWORD PTR [rsp+0x48]
    118e:	mov    r15,QWORD PTR [rsp+0x50]
    1193:	add    rsp,0x60
    1197:	mov    rsp,rbp
    119a:	pop    rbp
    119b:	ret
    119c:	mov    rdx,r12
    119f:	mov    rsi,r15
    11a2:	mov    rdi,r14
    11a5:	call   11aa <botlish_fn_13+0xda>
			11a6: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    11aa:	test   rax,rax
    11ad:	je     11f7 <botlish_fn_13+0x127>
    11b3:	mov    QWORD PTR [rsp+0x20],rax
    11b8:	lea    rcx,[rsp+0x28]
    11bd:	mov    QWORD PTR [rsp+0x28],rax
    11c2:	mov    edx,0x1
    11c7:	mov    rsi,r13
    11ca:	mov    rdi,r14
    11cd:	call   11d2 <botlish_fn_13+0x102>
			11ce: R_X86_64_PLT32	rt_call_value-0x4
    11d2:	test   rax,rax
    11d5:	je     11f7 <botlish_fn_13+0x127>
    11db:	mov    rcx,rax
    11de:	or     rcx,0x4
    11e2:	mov    rsi,rax
    11e5:	cmp    rcx,0x6
    11e9:	je     121c <botlish_fn_13+0x14c>
    11ef:	mov    rdi,r14
    11f2:	call   11f7 <botlish_fn_13+0x127>
			11f3: R_X86_64_PLT32	rt_not_boolean-0x4
    11f7:	xor    rax,rax
    11fa:	mov    rbx,QWORD PTR [rsp+0x30]
    11ff:	mov    r12,QWORD PTR [rsp+0x38]
    1204:	mov    r13,QWORD PTR [rsp+0x40]
    1209:	mov    r14,QWORD PTR [rsp+0x48]
    120e:	mov    r15,QWORD PTR [rsp+0x50]
    1213:	add    rsp,0x60
    1217:	mov    rsp,rbp
    121a:	pop    rbp
    121b:	ret
    121c:	cmp    rsi,0x6
    1220:	je     124b <botlish_fn_13+0x17b>
    1226:	mov    rax,r15
    1229:	mov    rbx,QWORD PTR [rsp+0x30]
    122e:	mov    r12,QWORD PTR [rsp+0x38]
    1233:	mov    r13,QWORD PTR [rsp+0x40]
    1238:	mov    r14,QWORD PTR [rsp+0x48]
    123d:	mov    r15,QWORD PTR [rsp+0x50]
    1242:	add    rsp,0x60
    1246:	mov    rsp,rbp
    1249:	pop    rbp
    124a:	ret
    124b:	mov    QWORD PTR [rsp+0x20],0x3
    1254:	mov    rax,r15
    1257:	test   rax,0x1
    125d:	je     1278 <botlish_fn_13+0x1a8>
    1263:	mov    rcx,r15
    1266:	mov    rax,rcx
    1269:	add    rax,0x2
    126d:	seto   dl
    1270:	test   dl,dl
    1272:	je     1288 <botlish_fn_13+0x1b8>
    1278:	mov    edx,0x3
    127d:	mov    rsi,r15
    1280:	mov    rdi,r14
    1283:	call   1288 <botlish_fn_13+0x1b8>
			1284: R_X86_64_PLT32	rt_int_add-0x4
    1288:	mov    QWORD PTR [rsp+0x18],rax
    128d:	mov    rcx,rbx
    1290:	mov    r15,rax
    1293:	jmp    1122 <botlish_fn_13+0x52>
    1298:	(bad)
    1299:	add    BYTE PTR [rax],al
    129b:	add    BYTE PTR [rax],al
    129d:	add    BYTE PTR [rax],al
	...

00000000000012a0 <botlish_entry_13: scan_while<generic>>:
    12a0:	push   rbp
    12a1:	mov    rbp,rsp
    12a4:	mov    rsi,QWORD PTR [rdx]
    12a7:	mov    r9,QWORD PTR [rdx+0x8]
    12ab:	mov    rcx,QWORD PTR [rdx+0x10]
    12af:	mov    r8,QWORD PTR [rdx+0x18]
    12b3:	mov    rdx,r9
    12b6:	call   12bb <botlish_entry_13+0x1b>
			12b7: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<generic>
    12bb:	mov    rsp,rbp
    12be:	pop    rbp
    12bf:	ret

00000000000012c0 <botlish_fn_14: tld?<generic>>:
    12c0:	push   rbp
    12c1:	mov    rbp,rsp
    12c4:	sub    rsp,0x40
    12c8:	mov    QWORD PTR [rsp+0x20],rbx
    12cd:	mov    QWORD PTR [rsp+0x28],r12
    12d2:	mov    QWORD PTR [rsp+0x30],r13
    12d7:	mov    QWORD PTR [rsp+0x38],r14
    12dc:	mov    QWORD PTR [rsp],rsi
    12e0:	mov    r8,rsi
    12e3:	mov    QWORD PTR [rsp+0x8],rdx
    12e8:	mov    r14,rdx
    12eb:	mov    QWORD PTR [rsp+0x10],rcx
    12f0:	mov    rax,QWORD PTR [rdi+0x10]
    12f4:	mov    r12,rdi
    12f7:	mov    rdx,QWORD PTR [rax+0xe0]
    12fe:	mov    QWORD PTR [rsp+0x18],rdx
    1303:	mov    rbx,r8
    1306:	mov    r8,rcx
    1309:	mov    rcx,r14
    130c:	mov    rsi,rbx
    130f:	call   1314 <botlish_fn_14+0x54>
			1310: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_while<generic>
    1314:	mov    rcx,rax
    1317:	mov    r13,rax
    131a:	test   rax,rcx
    131d:	jne    1343 <botlish_fn_14+0x83>
    1323:	xor    rax,rax
    1326:	mov    rbx,QWORD PTR [rsp+0x20]
    132b:	mov    r12,QWORD PTR [rsp+0x28]
    1330:	mov    r13,QWORD PTR [rsp+0x30]
    1335:	mov    r14,QWORD PTR [rsp+0x38]
    133a:	add    rsp,0x40
    133e:	mov    rsp,rbp
    1341:	pop    rbp
    1342:	ret
    1343:	mov    rax,r13
    1346:	mov    QWORD PTR [rsp+0x8],rax
    134b:	mov    rdx,r14
    134e:	and    rax,rdx
    1351:	test   rax,0x1
    1357:	jne    1380 <botlish_fn_14+0xc0>
    135d:	mov    rsi,r13
    1360:	mov    rdi,r12
    1363:	call   1368 <botlish_fn_14+0xa8>
			1364: R_X86_64_PLT32	rt_int_cmp-0x4
    1368:	mov    ecx,0x2
    136d:	test   rax,rax
    1370:	cmove  rcx,QWORD PTR [rip+0xe0]        # 1458 <botlish_fn_14+0x198>
    1378:	mov    rax,r13
    137b:	jmp    1393 <botlish_fn_14+0xd3>
    1380:	mov    ecx,0x2
    1385:	mov    rax,r13
    1388:	cmp    rax,rdx
    138b:	cmove  rcx,QWORD PTR [rip+0xc5]        # 1458 <botlish_fn_14+0x198>
    1393:	cmp    rcx,0x6
    1397:	je     13aa <botlish_fn_14+0xea>
    139d:	mov    ecx,0x2
    13a2:	mov    rax,rcx
    13a5:	jmp    1437 <botlish_fn_14+0x177>
    13aa:	mov    rcx,rax
    13ad:	and    rcx,rbx
    13b0:	test   rcx,0x1
    13b7:	jne    13c8 <botlish_fn_14+0x108>
    13bd:	mov    rdx,rbx
    13c0:	mov    rsi,rax
    13c3:	jmp    13e9 <botlish_fn_14+0x129>
    13c8:	mov    rcx,rax
    13cb:	sub    rcx,rbx
    13ce:	mov    r8,rbx
    13d1:	mov    r13,rax
    13d4:	seto   al
    13d7:	lea    rsi,[rcx+0x1]
    13db:	test   al,al
    13dd:	je     13f4 <botlish_fn_14+0x134>
    13e3:	mov    rdx,r8
    13e6:	mov    rsi,r13
    13e9:	mov    rdi,r12
    13ec:	call   13f1 <botlish_fn_14+0x131>
			13ed: R_X86_64_PLT32	rt_int_sub-0x4
    13f1:	mov    rsi,rax
    13f4:	test   rsi,0x1
    13fb:	jne    1426 <botlish_fn_14+0x166>
    1401:	mov    edx,0x5
    1406:	mov    rdi,r12
    1409:	call   140e <botlish_fn_14+0x14e>
			140a: R_X86_64_PLT32	rt_int_cmp-0x4
    140e:	mov    ecx,0x2
    1413:	test   rax,rax
    1416:	mov    rax,rcx
    1419:	cmovge rax,QWORD PTR [rip+0x37]        # 1458 <botlish_fn_14+0x198>
    1421:	jmp    1437 <botlish_fn_14+0x177>
    1426:	mov    eax,0x2
    142b:	cmp    rsi,0x5
    142f:	cmovge rax,QWORD PTR [rip+0x21]        # 1458 <botlish_fn_14+0x198>
    1437:	mov    rbx,QWORD PTR [rsp+0x20]
    143c:	mov    r12,QWORD PTR [rsp+0x28]
    1441:	mov    r13,QWORD PTR [rsp+0x30]
    1446:	mov    r14,QWORD PTR [rsp+0x38]
    144b:	add    rsp,0x40
    144f:	mov    rsp,rbp
    1452:	pop    rbp
    1453:	ret
    1454:	add    BYTE PTR [rax],al
    1456:	add    BYTE PTR [rax],al
    1458:	(bad)
    1459:	add    BYTE PTR [rax],al
    145b:	add    BYTE PTR [rax],al
    145d:	add    BYTE PTR [rax],al
	...

0000000000001460 <botlish_entry_14: tld?<generic>>:
    1460:	push   rbp
    1461:	mov    rbp,rsp
    1464:	mov    rsi,QWORD PTR [rdx]
    1467:	mov    r8,QWORD PTR [rdx+0x8]
    146b:	mov    rcx,QWORD PTR [rdx+0x10]
    146f:	mov    rdx,r8
    1472:	call   1477 <botlish_entry_14+0x17>
			1473: R_X86_64_PLT32	botlish_fn_14-0x4 ; tld?<generic>
    1477:	mov    rsp,rbp
    147a:	pop    rbp
    147b:	ret
    147c:	add    BYTE PTR [rax],al
	...

0000000000001480 <botlish_fn_15: domain?<generic>>:
    1480:	push   rbp
    1481:	mov    rbp,rsp
    1484:	sub    rsp,0xa0
    148b:	mov    QWORD PTR [rsp+0x70],rbx
    1490:	mov    QWORD PTR [rsp+0x78],r12
    1495:	mov    QWORD PTR [rsp+0x80],r13
    149d:	mov    QWORD PTR [rsp+0x88],r14
    14a5:	mov    QWORD PTR [rsp+0x90],r15
    14ad:	mov    QWORD PTR [rsp+0x20],0x0
    14b6:	mov    QWORD PTR [rsp],rsi
    14ba:	mov    QWORD PTR [rsp+0x8],rdx
    14bf:	mov    QWORD PTR [rsp+0x10],rcx
    14c4:	mov    r14,rcx
    14c7:	mov    QWORD PTR [rsp+0x18],rsi
    14cc:	mov    r15,rsi
    14cf:	mov    r13,rdx
    14d2:	mov    rax,rsi
    14d5:	and    rax,r13
    14d8:	mov    QWORD PTR [rsp+0x58],rsi
    14dd:	test   rax,0x1
    14e3:	jne    150e <botlish_fn_15+0x8e>
    14e9:	mov    rbx,rdi
    14ec:	mov    rdx,r13
    14ef:	mov    rsi,QWORD PTR [rsp+0x58]
    14f4:	call   14f9 <botlish_fn_15+0x79>
			14f5: R_X86_64_PLT32	rt_int_cmp-0x4
    14f9:	mov    ecx,0x2
    14fe:	test   rax,rax
    1501:	cmovl  rcx,QWORD PTR [rip+0x42f]        # 1938 <botlish_fn_15+0x4b8>
    1509:	jmp    1526 <botlish_fn_15+0xa6>
    150e:	mov    rbx,rdi
    1511:	mov    ecx,0x2
    1516:	mov    rsi,QWORD PTR [rsp+0x58]
    151b:	cmp    rsi,r13
    151e:	cmovl  rcx,QWORD PTR [rip+0x412]        # 1938 <botlish_fn_15+0x4b8>
    1526:	cmp    rcx,0x6
    152a:	je     1563 <botlish_fn_15+0xe3>
    1530:	mov    eax,0x2
    1535:	mov    rbx,QWORD PTR [rsp+0x70]
    153a:	mov    r12,QWORD PTR [rsp+0x78]
    153f:	mov    r13,QWORD PTR [rsp+0x80]
    1547:	mov    r14,QWORD PTR [rsp+0x88]
    154f:	mov    r15,QWORD PTR [rsp+0x90]
    1557:	add    rsp,0xa0
    155e:	mov    rsp,rbp
    1561:	pop    rbp
    1562:	ret
    1563:	lea    rcx,[rsp+0x28]
    1568:	mov    rdx,r14
    156b:	mov    rsi,QWORD PTR [rsp+0x58]
    1570:	mov    rdi,rbx
    1573:	call   1578 <botlish_fn_15+0xf8>
			1574: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    1578:	test   rax,rax
    157b:	mov    rsi,rax
    157e:	je     17e7 <botlish_fn_15+0x367>
    1584:	mov    rdx,QWORD PTR [rsp+0x28]
    1589:	mov    rcx,QWORD PTR [rsp+0x30]
    158e:	mov    rax,QWORD PTR [rbx+0x10]
    1592:	mov    r8,QWORD PTR [rax]
    1595:	mov    rdi,rbx
    1598:	call   159d <botlish_fn_15+0x11d>
			1599: R_X86_64_PLT32	rt_str_region_eq-0x4
    159d:	cmp    rax,0x6
    15a1:	je     1698 <botlish_fn_15+0x218>
    15a7:	lea    rcx,[rsp+0x48]
    15ac:	mov    rdx,r14
    15af:	mov    rsi,QWORD PTR [rsp+0x58]
    15b4:	mov    rdi,rbx
    15b7:	call   15bc <botlish_fn_15+0x13c>
			15b8: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    15bc:	test   rax,rax
    15bf:	mov    r12,rax
    15c2:	je     17e7 <botlish_fn_15+0x367>
    15c8:	mov    rdx,QWORD PTR [rsp+0x48]
    15cd:	mov    QWORD PTR [rsp+0x68],rdx
    15d2:	mov    rcx,QWORD PTR [rsp+0x50]
    15d7:	mov    QWORD PTR [rsp+0x60],rcx
    15dc:	mov    rsi,r12
    15df:	mov    rdi,rbx
    15e2:	call   15e7 <botlish_fn_15+0x167>
			15e3: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    15e7:	test   rax,rax
    15ea:	je     17e7 <botlish_fn_15+0x367>
    15f0:	cmp    rax,0x6
    15f4:	je     1635 <botlish_fn_15+0x1b5>
    15fa:	mov    rax,QWORD PTR [rbx+0x10]
    15fe:	mov    r8,QWORD PTR [rax+0x20]
    1602:	mov    rcx,QWORD PTR [rsp+0x60]
    1607:	mov    rdx,QWORD PTR [rsp+0x68]
    160c:	mov    rsi,r12
    160f:	mov    rdi,rbx
    1612:	call   1617 <botlish_fn_15+0x197>
			1613: R_X86_64_PLT32	rt_str_region_eq-0x4
    1617:	cmp    rax,0x6
    161b:	je     162b <botlish_fn_15+0x1ab>
    1621:	mov    edx,0x2
    1626:	jmp    163a <botlish_fn_15+0x1ba>
    162b:	mov    edx,0x6
    1630:	jmp    163a <botlish_fn_15+0x1ba>
    1635:	mov    edx,0x6
    163a:	cmp    rdx,0x6
    163e:	je     164e <botlish_fn_15+0x1ce>
    1644:	mov    eax,0x6
    1649:	jmp    1653 <botlish_fn_15+0x1d3>
    164e:	mov    eax,0x2
    1653:	cmp    rax,0x6
    1657:	je     1665 <botlish_fn_15+0x1e5>
    165d:	mov    r12,r15
    1660:	jmp    1822 <botlish_fn_15+0x3a2>
    1665:	mov    eax,0x2
    166a:	mov    rbx,QWORD PTR [rsp+0x70]
    166f:	mov    r12,QWORD PTR [rsp+0x78]
    1674:	mov    r13,QWORD PTR [rsp+0x80]
    167c:	mov    r14,QWORD PTR [rsp+0x88]
    1684:	mov    r15,QWORD PTR [rsp+0x90]
    168c:	add    rsp,0xa0
    1693:	mov    rsp,rbp
    1696:	pop    rbp
    1697:	ret
    1698:	mov    rsi,QWORD PTR [rsp+0x58]
    169d:	mov    r12,r15
    16a0:	mov    rax,rsi
    16a3:	and    rax,r12
    16a6:	test   rax,0x1
    16ac:	jne    16d7 <botlish_fn_15+0x257>
    16b2:	mov    rdx,r12
    16b5:	mov    rsi,QWORD PTR [rsp+0x58]
    16ba:	mov    rdi,rbx
    16bd:	call   16c2 <botlish_fn_15+0x242>
			16be: R_X86_64_PLT32	rt_int_cmp-0x4
    16c2:	mov    ecx,0x2
    16c7:	test   rax,rax
    16ca:	cmove  rcx,QWORD PTR [rip+0x266]        # 1938 <botlish_fn_15+0x4b8>
    16d2:	jmp    16ec <botlish_fn_15+0x26c>
    16d7:	mov    ecx,0x2
    16dc:	mov    rsi,QWORD PTR [rsp+0x58]
    16e1:	cmp    rsi,r12
    16e4:	cmove  rcx,QWORD PTR [rip+0x24c]        # 1938 <botlish_fn_15+0x4b8>
    16ec:	cmp    rcx,0x6
    16f0:	je     1905 <botlish_fn_15+0x485>
    16f6:	mov    QWORD PTR [rsp+0x20],0x3
    16ff:	mov    rsi,QWORD PTR [rsp+0x58]
    1704:	test   rsi,0x1
    170b:	je     172e <botlish_fn_15+0x2ae>
    1711:	mov    rsi,QWORD PTR [rsp+0x58]
    1716:	sub    rsi,0x3
    171a:	seto   dil
    171e:	add    rsi,0x1
    1725:	test   dil,dil
    1728:	je     1743 <botlish_fn_15+0x2c3>
    172e:	mov    edx,0x3
    1733:	mov    rsi,QWORD PTR [rsp+0x58]
    1738:	mov    rdi,rbx
    173b:	call   1740 <botlish_fn_15+0x2c0>
			173c: R_X86_64_PLT32	rt_int_sub-0x4
    1740:	mov    rsi,rax
    1743:	mov    QWORD PTR [rsp+0x20],rsi
    1748:	lea    rcx,[rsp+0x38]
    174d:	mov    rdx,r14
    1750:	mov    rdi,rbx
    1753:	call   1758 <botlish_fn_15+0x2d8>
			1754: R_X86_64_PLT32	botlish_fn_10-0x4 ; char_at<generic>
    1758:	test   rax,rax
    175b:	mov    rsi,rax
    175e:	je     17e7 <botlish_fn_15+0x367>
    1764:	mov    rdx,QWORD PTR [rsp+0x38]
    1769:	mov    rcx,QWORD PTR [rsp+0x40]
    176e:	mov    rax,QWORD PTR [rbx+0x10]
    1772:	mov    r8,QWORD PTR [rax]
    1775:	mov    rdi,rbx
    1778:	call   177d <botlish_fn_15+0x2fd>
			1779: R_X86_64_PLT32	rt_str_region_eq-0x4
    177d:	cmp    rax,0x6
    1781:	je     18d2 <botlish_fn_15+0x452>
    1787:	mov    QWORD PTR [rsp+0x20],0x3
    1790:	mov    rsi,QWORD PTR [rsp+0x58]
    1795:	test   rsi,0x1
    179c:	je     17b6 <botlish_fn_15+0x336>
    17a2:	mov    rsi,QWORD PTR [rsp+0x58]
    17a7:	add    rsi,0x2
    17ab:	seto   al
    17ae:	test   al,al
    17b0:	je     17cb <botlish_fn_15+0x34b>
    17b6:	mov    edx,0x3
    17bb:	mov    rsi,QWORD PTR [rsp+0x58]
    17c0:	mov    rdi,rbx
    17c3:	call   17c8 <botlish_fn_15+0x348>
			17c4: R_X86_64_PLT32	rt_int_add-0x4
    17c8:	mov    rsi,rax
    17cb:	mov    QWORD PTR [rsp+0x20],rsi
    17d0:	mov    rcx,r14
    17d3:	mov    rdx,r13
    17d6:	mov    rdi,rbx
    17d9:	call   17de <botlish_fn_15+0x35e>
			17da: R_X86_64_PLT32	botlish_fn_14-0x4 ; tld?<generic>
    17de:	test   rax,rax
    17e1:	jne    1818 <botlish_fn_15+0x398>
    17e7:	xor    rax,rax
    17ea:	mov    rbx,QWORD PTR [rsp+0x70]
    17ef:	mov    r12,QWORD PTR [rsp+0x78]
    17f4:	mov    r13,QWORD PTR [rsp+0x80]
    17fc:	mov    r14,QWORD PTR [rsp+0x88]
    1804:	mov    r15,QWORD PTR [rsp+0x90]
    180c:	add    rsp,0xa0
    1813:	mov    rsp,rbp
    1816:	pop    rbp
    1817:	ret
    1818:	cmp    rax,0x6
    181c:	je     189f <botlish_fn_15+0x41f>
    1822:	mov    edx,0x3
    1827:	mov    QWORD PTR [rsp+0x20],0x3
    1830:	mov    rsi,QWORD PTR [rsp+0x58]
    1835:	test   rsi,0x1
    183c:	jne    184c <botlish_fn_15+0x3cc>
    1842:	mov    rsi,QWORD PTR [rsp+0x58]
    1847:	jmp    187a <botlish_fn_15+0x3fa>
    184c:	mov    rsi,QWORD PTR [rsp+0x58]
    1851:	mov    rax,rsi
    1854:	add    rax,0x2
    1858:	seto   cl
    185b:	test   cl,cl
    185d:	je     186d <botlish_fn_15+0x3ed>
    1863:	mov    rsi,QWORD PTR [rsp+0x58]
    1868:	jmp    187a <botlish_fn_15+0x3fa>
    186d:	mov    rsi,rax
    1870:	mov    QWORD PTR [rsp+0x58],rax
    1875:	jmp    188a <botlish_fn_15+0x40a>
    187a:	mov    rdi,rbx
    187d:	call   1882 <botlish_fn_15+0x402>
			187e: R_X86_64_PLT32	rt_int_add-0x4
    1882:	mov    rsi,rax
    1885:	mov    QWORD PTR [rsp+0x58],rax
    188a:	mov    QWORD PTR [rsp+0x18],rsi
    188f:	mov    rsi,QWORD PTR [rsp+0x58]
    1894:	mov    rdi,rbx
    1897:	mov    r15,r12
    189a:	jmp    14d2 <botlish_fn_15+0x52>
    189f:	mov    eax,0x6
    18a4:	mov    rbx,QWORD PTR [rsp+0x70]
    18a9:	mov    r12,QWORD PTR [rsp+0x78]
    18ae:	mov    r13,QWORD PTR [rsp+0x80]
    18b6:	mov    r14,QWORD PTR [rsp+0x88]
    18be:	mov    r15,QWORD PTR [rsp+0x90]
    18c6:	add    rsp,0xa0
    18cd:	mov    rsp,rbp
    18d0:	pop    rbp
    18d1:	ret
    18d2:	mov    eax,0x2
    18d7:	mov    rbx,QWORD PTR [rsp+0x70]
    18dc:	mov    r12,QWORD PTR [rsp+0x78]
    18e1:	mov    r13,QWORD PTR [rsp+0x80]
    18e9:	mov    r14,QWORD PTR [rsp+0x88]
    18f1:	mov    r15,QWORD PTR [rsp+0x90]
    18f9:	add    rsp,0xa0
    1900:	mov    rsp,rbp
    1903:	pop    rbp
    1904:	ret
    1905:	mov    eax,0x2
    190a:	mov    rbx,QWORD PTR [rsp+0x70]
    190f:	mov    r12,QWORD PTR [rsp+0x78]
    1914:	mov    r13,QWORD PTR [rsp+0x80]
    191c:	mov    r14,QWORD PTR [rsp+0x88]
    1924:	mov    r15,QWORD PTR [rsp+0x90]
    192c:	add    rsp,0xa0
    1933:	mov    rsp,rbp
    1936:	pop    rbp
    1937:	ret
    1938:	(bad)
    1939:	add    BYTE PTR [rax],al
    193b:	add    BYTE PTR [rax],al
    193d:	add    BYTE PTR [rax],al
	...

0000000000001940 <botlish_entry_15: domain?<generic>>:
    1940:	push   rbp
    1941:	mov    rbp,rsp
    1944:	mov    rsi,QWORD PTR [rdx]
    1947:	mov    r8,QWORD PTR [rdx+0x8]
    194b:	mov    rcx,QWORD PTR [rdx+0x10]
    194f:	mov    rdx,r8
    1952:	call   1957 <botlish_entry_15+0x17>
			1953: R_X86_64_PLT32	botlish_fn_15-0x4 ; domain?<generic>
    1957:	mov    rsp,rbp
    195a:	pop    rbp
    195b:	ret

000000000000195c <botlish_fn_16: web::is_unreserved<generic>>:
    195c:	push   rbp
    195d:	mov    rbp,rsp
    1960:	sub    rsp,0x20
    1964:	mov    QWORD PTR [rsp],rbx
    1968:	mov    QWORD PTR [rsp+0x8],r12
    196d:	mov    QWORD PTR [rsp+0x10],r14
    1972:	mov    rbx,rdi
    1975:	mov    r12,rsi
    1978:	mov    r14,rdx
    197b:	mov    rsi,r14
    197e:	mov    rdi,rbx
    1981:	call   1986 <botlish_fn_16+0x2a>
			1982: R_X86_64_PLT32	botlish_fn_8-0x4 ; ascii::is_alphanumeric<int>
    1986:	cmp    rax,0x6
    198a:	je     19c3 <botlish_fn_16+0x67>
    1990:	mov    rsi,r12
    1993:	mov    rax,QWORD PTR [rsi+0x20]
    1997:	mov    rsi,QWORD PTR [rax]
    199a:	mov    rdx,r14
    199d:	mov    rdi,rbx
    19a0:	call   19a5 <botlish_fn_16+0x49>
			19a1: R_X86_64_PLT32	rt_set_contains-0x4
    19a5:	cmp    rax,0x6
    19a9:	je     19b9 <botlish_fn_16+0x5d>
    19af:	mov    eax,0x2
    19b4:	jmp    19c8 <botlish_fn_16+0x6c>
    19b9:	mov    eax,0x6
    19be:	jmp    19c8 <botlish_fn_16+0x6c>
    19c3:	mov    eax,0x6
    19c8:	mov    rbx,QWORD PTR [rsp]
    19cc:	mov    r12,QWORD PTR [rsp+0x8]
    19d1:	mov    r14,QWORD PTR [rsp+0x10]
    19d6:	add    rsp,0x20
    19da:	mov    rsp,rbp
    19dd:	pop    rbp
    19de:	ret

00000000000019df <botlish_entry_16: web::is_unreserved<generic>>:
    19df:	push   rbp
    19e0:	mov    rbp,rsp
    19e3:	mov    rdx,QWORD PTR [rdx]
    19e6:	call   19eb <botlish_entry_16+0xc>
			19e7: R_X86_64_PLT32	botlish_fn_16-0x4 ; web::is_unreserved<generic>
    19eb:	mov    rsp,rbp
    19ee:	pop    rbp
    19ef:	ret

00000000000019f0 <botlish_fn_17: web::uri_escape_text<generic>>:
    19f0:	push   rbp
    19f1:	mov    rbp,rsp
    19f4:	sub    rsp,0x30
    19f8:	mov    QWORD PTR [rsp],rdx
    19fc:	mov    r10,rdx
    19ff:	mov    edx,0x1
    1a04:	mov    QWORD PTR [rsp+0x8],0x1
    1a0d:	mov    rax,QWORD PTR [rdi+0x10]
    1a11:	mov    rcx,QWORD PTR [rax+0xe8]
    1a18:	mov    QWORD PTR [rsp+0x10],rcx
    1a1d:	mov    rax,QWORD PTR [rsi+0x20]
    1a21:	mov    r8,QWORD PTR [rax+0x8]
    1a25:	mov    QWORD PTR [rsp+0x18],r8
    1a2a:	mov    rax,QWORD PTR [rsi+0x20]
    1a2e:	mov    r9,QWORD PTR [rax]
    1a31:	mov    QWORD PTR [rsp+0x20],r9
    1a36:	mov    rsi,r10
    1a39:	call   1a3e <botlish_fn_17+0x4e>
			1a3a: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_from<generic>
    1a3e:	test   rax,rax
    1a41:	jne    1a53 <botlish_fn_17+0x63>
    1a47:	xor    rax,rax
    1a4a:	add    rsp,0x30
    1a4e:	mov    rsp,rbp
    1a51:	pop    rbp
    1a52:	ret
    1a53:	add    rsp,0x30
    1a57:	mov    rsp,rbp
    1a5a:	pop    rbp
    1a5b:	ret

0000000000001a5c <botlish_entry_17: web::uri_escape_text<generic>>:
    1a5c:	push   rbp
    1a5d:	mov    rbp,rsp
    1a60:	mov    rdx,QWORD PTR [rdx]
    1a63:	call   1a68 <botlish_entry_17+0xc>
			1a64: R_X86_64_PLT32	botlish_fn_17-0x4 ; web::uri_escape_text<generic>
    1a68:	mov    rsp,rbp
    1a6b:	pop    rbp
    1a6c:	ret

0000000000001a6d <botlish_fn_18: high_nibble<generic>>:
    1a6d:	push   rbp
    1a6e:	mov    rbp,rsp
    1a71:	sub    rsp,0x10
    1a75:	mov    QWORD PTR [rsp],rsi
    1a79:	mov    QWORD PTR [rsp+0x8],0x1e1
    1a82:	test   rsi,0x1
    1a89:	jne    1a9e <botlish_fn_18+0x31>
    1a8f:	mov    edx,0x1e1
    1a94:	call   1a99 <botlish_fn_18+0x2c>
			1a95: R_X86_64_PLT32	rt_int_and-0x4
    1a99:	jmp    1aa8 <botlish_fn_18+0x3b>
    1a9e:	and    rsi,0x1e1
    1aa5:	mov    rax,rsi
    1aa8:	sar    rax,0x5
    1aac:	shl    rax,1
    1aaf:	or     rax,0x1
    1ab3:	add    rsp,0x10
    1ab7:	mov    rsp,rbp
    1aba:	pop    rbp
    1abb:	ret

0000000000001abc <botlish_entry_18: high_nibble<generic>>:
    1abc:	push   rbp
    1abd:	mov    rbp,rsp
    1ac0:	mov    rsi,QWORD PTR [rdx]
    1ac3:	call   1ac8 <botlish_entry_18+0xc>
			1ac4: R_X86_64_PLT32	botlish_fn_18-0x4 ; high_nibble<generic>
    1ac8:	mov    rsp,rbp
    1acb:	pop    rbp
    1acc:	ret

0000000000001acd <botlish_fn_19: hex_pair<generic>>:
    1acd:	push   rbp
    1ace:	mov    rbp,rsp
    1ad1:	sub    rsp,0x50
    1ad5:	mov    QWORD PTR [rsp+0x30],rbx
    1ada:	mov    QWORD PTR [rsp+0x38],r12
    1adf:	mov    QWORD PTR [rsp+0x40],r13
    1ae4:	mov    QWORD PTR [rsp+0x48],r14
    1ae9:	mov    r12,rdi
    1aec:	mov    QWORD PTR [rsp],rsi
    1af0:	mov    r13,rsi
    1af3:	mov    QWORD PTR [rsp+0x8],rdx
    1af8:	mov    rbx,rdx
    1afb:	mov    rsi,r13
    1afe:	mov    rdi,r12
    1b01:	call   1b06 <botlish_fn_19+0x39>
			1b02: R_X86_64_PLT32	botlish_fn_18-0x4 ; high_nibble<generic>
    1b06:	test   rax,0x1
    1b0c:	jne    1b1a <botlish_fn_19+0x4d>
    1b12:	mov    rdx,rax
    1b15:	jmp    1b30 <botlish_fn_19+0x63>
    1b1a:	mov    rdx,QWORD PTR [rbx+0x8]
    1b1e:	mov    rcx,rax
    1b21:	sar    rcx,1
    1b24:	cmp    rcx,rdx
    1b27:	jb     1b49 <botlish_fn_19+0x7c>
    1b2d:	mov    rdx,rax
    1b30:	mov    rsi,rbx
    1b33:	mov    rdi,r12
    1b36:	call   1b3b <botlish_fn_19+0x6e>
			1b37: R_X86_64_PLT32	rt_list_get-0x4
    1b3b:	test   rax,rax
    1b3e:	je     1c06 <botlish_fn_19+0x139>
    1b44:	jmp    1b51 <botlish_fn_19+0x84>
    1b49:	mov    rax,QWORD PTR [rbx+0x10]
    1b4d:	mov    rax,QWORD PTR [rax+rcx*8]
    1b51:	mov    QWORD PTR [rsp],rax
    1b55:	mov    r14,rax
    1b58:	mov    edx,0x21
    1b5d:	mov    rsi,r13
    1b60:	mov    rdi,r12
    1b63:	call   1b68 <botlish_fn_19+0x9b>
			1b64: R_X86_64_PLT32	rt_int_mod-0x4
    1b68:	test   rax,rax
    1b6b:	je     1c06 <botlish_fn_19+0x139>
    1b71:	test   rax,0x1
    1b77:	jne    1b88 <botlish_fn_19+0xbb>
    1b7d:	mov    rdx,rax
    1b80:	mov    rsi,rbx
    1b83:	jmp    1ba1 <botlish_fn_19+0xd4>
    1b88:	mov    rdx,QWORD PTR [rbx+0x8]
    1b8c:	mov    rcx,rax
    1b8f:	sar    rcx,1
    1b92:	cmp    rcx,rdx
    1b95:	jb     1bb7 <botlish_fn_19+0xea>
    1b9b:	mov    rdx,rax
    1b9e:	mov    rsi,rbx
    1ba1:	mov    rdi,r12
    1ba4:	call   1ba9 <botlish_fn_19+0xdc>
			1ba5: R_X86_64_PLT32	rt_list_get-0x4
    1ba9:	test   rax,rax
    1bac:	je     1c06 <botlish_fn_19+0x139>
    1bb2:	jmp    1bc2 <botlish_fn_19+0xf5>
    1bb7:	mov    rsi,rbx
    1bba:	mov    rax,QWORD PTR [rsi+0x10]
    1bbe:	mov    rax,QWORD PTR [rax+rcx*8]
    1bc2:	mov    QWORD PTR [rsp+0x8],rax
    1bc7:	lea    rcx,[rsp+0x10]
    1bcc:	mov    QWORD PTR [rsp+0x10],0x0
    1bd5:	mov    rdx,r14
    1bd8:	mov    QWORD PTR [rsp+0x18],rdx
    1bdd:	mov    QWORD PTR [rsp+0x20],0x0
    1be6:	mov    QWORD PTR [rsp+0x28],rax
    1beb:	mov    esi,0x2
    1bf0:	mov    edx,0x4
    1bf5:	mov    rdi,r12
    1bf8:	call   1bfd <botlish_fn_19+0x130>
			1bf9: R_X86_64_PLT32	rt_construct-0x4
    1bfd:	test   rax,rax
    1c00:	jne    1c26 <botlish_fn_19+0x159>
    1c06:	xor    rax,rax
    1c09:	mov    rbx,QWORD PTR [rsp+0x30]
    1c0e:	mov    r12,QWORD PTR [rsp+0x38]
    1c13:	mov    r13,QWORD PTR [rsp+0x40]
    1c18:	mov    r14,QWORD PTR [rsp+0x48]
    1c1d:	add    rsp,0x50
    1c21:	mov    rsp,rbp
    1c24:	pop    rbp
    1c25:	ret
    1c26:	mov    rbx,QWORD PTR [rsp+0x30]
    1c2b:	mov    r12,QWORD PTR [rsp+0x38]
    1c30:	mov    r13,QWORD PTR [rsp+0x40]
    1c35:	mov    r14,QWORD PTR [rsp+0x48]
    1c3a:	add    rsp,0x50
    1c3e:	mov    rsp,rbp
    1c41:	pop    rbp
    1c42:	ret

0000000000001c43 <botlish_entry_19: hex_pair<generic>>:
    1c43:	push   rbp
    1c44:	mov    rbp,rsp
    1c47:	sub    rsp,0x10
    1c4b:	mov    QWORD PTR [rsp],r12
    1c4f:	mov    r12,rdi
    1c52:	mov    rsi,QWORD PTR [rdx]
    1c55:	mov    rdx,QWORD PTR [rdx+0x8]
    1c59:	call   1c5e <botlish_entry_19+0x1b>
			1c5a: R_X86_64_PLT32	botlish_fn_19-0x4 ; hex_pair<generic>
    1c5e:	mov    r8,QWORD PTR [rip+0x0]        # 1c65 <botlish_entry_19+0x22>
			1c61: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1c65:	mov    rsi,rax
    1c68:	mov    rdi,r12
    1c6b:	call   r8
    1c6e:	mov    r12,QWORD PTR [rsp]
    1c72:	add    rsp,0x10
    1c76:	mov    rsp,rbp
    1c79:	pop    rbp
    1c7a:	ret
    1c7b:	add    BYTE PTR [rax],al
    1c7d:	add    BYTE PTR [rax],al
	...

0000000000001c80 <botlish_fn_20: esc_bytes<generic>>:
    1c80:	push   rbp
    1c81:	mov    rbp,rsp
    1c84:	sub    rsp,0xb0
    1c8b:	mov    QWORD PTR [rsp+0x80],rbx
    1c93:	mov    QWORD PTR [rsp+0x88],r12
    1c9b:	mov    QWORD PTR [rsp+0x90],r13
    1ca3:	mov    QWORD PTR [rsp+0x98],r14
    1cab:	mov    QWORD PTR [rsp+0xa0],r15
    1cb3:	mov    QWORD PTR [rsp+0x28],0x0
    1cbc:	mov    QWORD PTR [rsp],rsi
    1cc0:	mov    QWORD PTR [rsp+0x8],rdx
    1cc5:	mov    r13,rdx
    1cc8:	mov    QWORD PTR [rsp+0x10],rcx
    1ccd:	mov    QWORD PTR [rsp+0x18],r8
    1cd2:	mov    QWORD PTR [rsp+0x60],r8
    1cd7:	lea    rax,[rsp+0x30]
    1cdc:	mov    QWORD PTR [rsp+0x70],rax
    1ce1:	mov    rbx,rdi
    1ce4:	mov    r12,rsi
    1ce7:	mov    QWORD PTR [rsp+0x68],rcx
    1cec:	mov    rsi,r12
    1cef:	mov    rdi,rbx
    1cf2:	call   1cf7 <botlish_fn_20+0x77>
			1cf3: R_X86_64_PLT32	rt_list_len-0x4
    1cf7:	mov    r15,r13
    1cfa:	mov    rcx,r15
    1cfd:	and    rcx,rax
    1d00:	mov    rdx,rax
    1d03:	test   rcx,0x1
    1d0a:	jne    1d30 <botlish_fn_20+0xb0>
    1d10:	mov    rsi,r15
    1d13:	mov    rdi,rbx
    1d16:	call   1d1b <botlish_fn_20+0x9b>
			1d17: R_X86_64_PLT32	rt_int_cmp-0x4
    1d1b:	mov    ecx,0x2
    1d20:	test   rax,rax
    1d23:	cmovge rcx,QWORD PTR [rip+0x1dd]        # 1f08 <botlish_fn_20+0x288>
    1d2b:	jmp    1d40 <botlish_fn_20+0xc0>
    1d30:	mov    ecx,0x2
    1d35:	cmp    r15,rdx
    1d38:	cmovge rcx,QWORD PTR [rip+0x1c8]        # 1f08 <botlish_fn_20+0x288>
    1d40:	cmp    rcx,0x6
    1d44:	je     1eca <botlish_fn_20+0x24a>
    1d4a:	mov    QWORD PTR [rsp+0x20],0x3
    1d53:	test   r15,0x1
    1d5a:	je     1d7d <botlish_fn_20+0xfd>
    1d60:	mov    rax,r15
    1d63:	add    rax,0x2
    1d67:	mov    rcx,rax
    1d6a:	seto   al
    1d6d:	test   al,al
    1d6f:	jne    1d7d <botlish_fn_20+0xfd>
    1d75:	mov    r14,rcx
    1d78:	jmp    1d93 <botlish_fn_20+0x113>
    1d7d:	mov    edx,0x3
    1d82:	mov    rsi,r15
    1d85:	mov    rdi,rbx
    1d88:	call   1d8d <botlish_fn_20+0x10d>
			1d89: R_X86_64_PLT32	rt_int_add-0x4
    1d8d:	mov    rcx,rax
    1d90:	mov    r14,rcx
    1d93:	mov    QWORD PTR [rsp+0x8],r14
    1d98:	mov    rax,QWORD PTR [rbx+0x10]
    1d9c:	mov    r13,QWORD PTR [rax+0x10]
    1da0:	mov    QWORD PTR [rsp+0x20],r13
    1da5:	test   r15,0x1
    1dac:	jne    1dba <botlish_fn_20+0x13a>
    1db2:	mov    rdx,r15
    1db5:	jmp    1dd1 <botlish_fn_20+0x151>
    1dba:	mov    rcx,QWORD PTR [r12+0x8]
    1dbf:	mov    rax,r15
    1dc2:	sar    rax,1
    1dc5:	cmp    rax,rcx
    1dc8:	jb     1ded <botlish_fn_20+0x16d>
    1dce:	mov    rdx,r15
    1dd1:	mov    rsi,r12
    1dd4:	mov    rdi,rbx
    1dd7:	call   1ddc <botlish_fn_20+0x15c>
			1dd8: R_X86_64_PLT32	rt_list_get-0x4
    1ddc:	test   rax,rax
    1ddf:	je     1e6e <botlish_fn_20+0x1ee>
    1de5:	mov    rsi,rax
    1de8:	jmp    1df6 <botlish_fn_20+0x176>
    1ded:	mov    rdi,QWORD PTR [r12+0x10]
    1df2:	mov    rsi,QWORD PTR [rdi+rax*8]
    1df6:	mov    QWORD PTR [rsp+0x28],rsi
    1dfb:	mov    r15,QWORD PTR [rsp+0x60]
    1e00:	mov    rdx,r15
    1e03:	mov    rdi,rbx
    1e06:	call   1e0b <botlish_fn_20+0x18b>
			1e07: R_X86_64_PLT32	botlish_fn_19-0x4 ; hex_pair<generic>
    1e0b:	test   rax,rax
    1e0e:	je     1e6e <botlish_fn_20+0x1ee>
    1e14:	mov    QWORD PTR [rsp+0x28],rax
    1e19:	mov    rcx,rax
    1e1c:	mov    QWORD PTR [rsp+0x30],0x0
    1e25:	mov    rax,QWORD PTR [rsp+0x68]
    1e2a:	mov    QWORD PTR [rsp+0x38],rax
    1e2f:	mov    QWORD PTR [rsp+0x40],0x0
    1e38:	mov    QWORD PTR [rsp+0x48],r13
    1e3d:	mov    QWORD PTR [rsp+0x50],0x0
    1e46:	mov    rax,rcx
    1e49:	mov    QWORD PTR [rsp+0x58],rax
    1e4e:	mov    esi,0x2
    1e53:	mov    edx,0x6
    1e58:	mov    rcx,QWORD PTR [rsp+0x70]
    1e5d:	mov    rdi,rbx
    1e60:	call   1e65 <botlish_fn_20+0x1e5>
			1e61: R_X86_64_PLT32	rt_construct-0x4
    1e65:	test   rax,rax
    1e68:	jne    1ea5 <botlish_fn_20+0x225>
    1e6e:	xor    rax,rax
    1e71:	mov    rbx,QWORD PTR [rsp+0x80]
    1e79:	mov    r12,QWORD PTR [rsp+0x88]
    1e81:	mov    r13,QWORD PTR [rsp+0x90]
    1e89:	mov    r14,QWORD PTR [rsp+0x98]
    1e91:	mov    r15,QWORD PTR [rsp+0xa0]
    1e99:	add    rsp,0xb0
    1ea0:	mov    rsp,rbp
    1ea3:	pop    rbp
    1ea4:	ret
    1ea5:	mov    QWORD PTR [rsp],r12
    1ea9:	mov    QWORD PTR [rsp+0x8],r14
    1eae:	mov    QWORD PTR [rsp+0x10],rax
    1eb3:	mov    QWORD PTR [rsp+0x18],r15
    1eb8:	mov    r13,r14
    1ebb:	mov    QWORD PTR [rsp+0x60],r15
    1ec0:	mov    QWORD PTR [rsp+0x68],rax
    1ec5:	jmp    1cec <botlish_fn_20+0x6c>
    1eca:	mov    rax,QWORD PTR [rsp+0x68]
    1ecf:	mov    rbx,QWORD PTR [rsp+0x80]
    1ed7:	mov    r12,QWORD PTR [rsp+0x88]
    1edf:	mov    r13,QWORD PTR [rsp+0x90]
    1ee7:	mov    r14,QWORD PTR [rsp+0x98]
    1eef:	mov    r15,QWORD PTR [rsp+0xa0]
    1ef7:	add    rsp,0xb0
    1efe:	mov    rsp,rbp
    1f01:	pop    rbp
    1f02:	ret
    1f03:	add    BYTE PTR [rax],al
    1f05:	add    BYTE PTR [rax],al
    1f07:	add    BYTE PTR [rsi],al
    1f09:	add    BYTE PTR [rax],al
    1f0b:	add    BYTE PTR [rax],al
    1f0d:	add    BYTE PTR [rax],al
	...

0000000000001f10 <botlish_entry_20: esc_bytes<generic>>:
    1f10:	push   rbp
    1f11:	mov    rbp,rsp
    1f14:	sub    rsp,0x10
    1f18:	mov    QWORD PTR [rsp],r12
    1f1c:	mov    r12,rdi
    1f1f:	mov    rsi,QWORD PTR [rdx]
    1f22:	mov    r9,QWORD PTR [rdx+0x8]
    1f26:	mov    rcx,QWORD PTR [rdx+0x10]
    1f2a:	mov    r8,QWORD PTR [rdx+0x18]
    1f2e:	mov    rdx,r9
    1f31:	call   1f36 <botlish_entry_20+0x26>
			1f32: R_X86_64_PLT32	botlish_fn_20-0x4 ; esc_bytes<generic>
    1f36:	mov    r9,QWORD PTR [rip+0x0]        # 1f3d <botlish_entry_20+0x2d>
			1f39: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    1f3d:	mov    rsi,rax
    1f40:	mov    rdi,r12
    1f43:	call   r9
    1f46:	mov    r12,QWORD PTR [rsp]
    1f4a:	add    rsp,0x10
    1f4e:	mov    rsp,rbp
    1f51:	pop    rbp
    1f52:	ret

0000000000001f53 <botlish_fn_21: esc_char<generic>>:
    1f53:	push   rbp
    1f54:	mov    rbp,rsp
    1f57:	sub    rsp,0x50
    1f5b:	mov    QWORD PTR [rsp+0x20],rbx
    1f60:	mov    QWORD PTR [rsp+0x28],r12
    1f65:	mov    QWORD PTR [rsp+0x30],r13
    1f6a:	mov    QWORD PTR [rsp+0x38],r14
    1f6f:	mov    QWORD PTR [rsp+0x40],r15
    1f74:	mov    r12,rdi
    1f77:	mov    QWORD PTR [rsp+0x18],0x0
    1f80:	mov    QWORD PTR [rsp],rsi
    1f84:	mov    r14,rsi
    1f87:	mov    QWORD PTR [rsp+0x8],rdx
    1f8c:	mov    r15,rdx
    1f8f:	mov    QWORD PTR [rsp+0x10],rcx
    1f94:	mov    rbx,rcx
    1f97:	mov    rsi,r14
    1f9a:	mov    rdi,r12
    1f9d:	call   1fa2 <botlish_fn_21+0x4f>
			1f9e: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1fa2:	mov    rcx,rax
    1fa5:	mov    r13,rax
    1fa8:	test   rax,rcx
    1fab:	je     2095 <botlish_fn_21+0x142>
    1fb1:	mov    rax,r13
    1fb4:	mov    QWORD PTR [rsp],rax
    1fb8:	mov    rsi,r13
    1fbb:	mov    rdi,r12
    1fbe:	call   1fc3 <botlish_fn_21+0x70>
			1fbf: R_X86_64_PLT32	rt_list_len-0x4
    1fc3:	sar    rax,1
    1fc6:	cmp    rax,0x1
    1fca:	je     200a <botlish_fn_21+0xb7>
    1fd0:	mov    edx,0x1
    1fd5:	mov    QWORD PTR [rsp+0x8],0x1
    1fde:	mov    rdi,r12
    1fe1:	mov    rax,QWORD PTR [rdi+0x10]
    1fe5:	mov    rcx,QWORD PTR [rax+0xe8]
    1fec:	mov    QWORD PTR [rsp+0x18],rcx
    1ff1:	mov    rsi,r13
    1ff4:	mov    r8,rbx
    1ff7:	call   1ffc <botlish_fn_21+0xa9>
			1ff8: R_X86_64_PLT32	botlish_fn_20-0x4 ; esc_bytes<generic>
    1ffc:	test   rax,rax
    1fff:	je     2095 <botlish_fn_21+0x142>
    2005:	jmp    20c0 <botlish_fn_21+0x16d>
    200a:	mov    rsi,r13
    200d:	mov    rax,QWORD PTR [rsi+0x8]
    2011:	mov    r13,rsi
    2014:	test   rax,rax
    2017:	jne    2041 <botlish_fn_21+0xee>
    201d:	mov    edx,0x1
    2022:	mov    rsi,r13
    2025:	mov    rdi,r12
    2028:	call   202d <botlish_fn_21+0xda>
			2029: R_X86_64_PLT32	rt_list_get-0x4
    202d:	test   rax,rax
    2030:	je     2095 <botlish_fn_21+0x142>
    2036:	mov    rdx,rax
    2039:	mov    rsi,r15
    203c:	jmp    204e <botlish_fn_21+0xfb>
    2041:	mov    rsi,r13
    2044:	mov    rax,QWORD PTR [rsi+0x10]
    2048:	mov    rdx,QWORD PTR [rax]
    204b:	mov    rsi,r15
    204e:	mov    rdi,r12
    2051:	call   2056 <botlish_fn_21+0x103>
			2052: R_X86_64_PLT32	botlish_fn_16-0x4 ; web::is_unreserved<generic>
    2056:	cmp    rax,0x6
    205a:	je     20bd <botlish_fn_21+0x16a>
    2060:	mov    edx,0x1
    2065:	mov    QWORD PTR [rsp+0x8],0x1
    206e:	mov    rdi,r12
    2071:	mov    rax,QWORD PTR [rdi+0x10]
    2075:	mov    rcx,QWORD PTR [rax+0xe8]
    207c:	mov    QWORD PTR [rsp+0x18],rcx
    2081:	mov    rsi,r13
    2084:	mov    r8,rbx
    2087:	call   208c <botlish_fn_21+0x139>
			2088: R_X86_64_PLT32	botlish_fn_20-0x4 ; esc_bytes<generic>
    208c:	test   rax,rax
    208f:	jne    20ba <botlish_fn_21+0x167>
    2095:	xor    rax,rax
    2098:	mov    rbx,QWORD PTR [rsp+0x20]
    209d:	mov    r12,QWORD PTR [rsp+0x28]
    20a2:	mov    r13,QWORD PTR [rsp+0x30]
    20a7:	mov    r14,QWORD PTR [rsp+0x38]
    20ac:	mov    r15,QWORD PTR [rsp+0x40]
    20b1:	add    rsp,0x50
    20b5:	mov    rsp,rbp
    20b8:	pop    rbp
    20b9:	ret
    20ba:	mov    r14,rax
    20bd:	mov    rax,r14
    20c0:	mov    rbx,QWORD PTR [rsp+0x20]
    20c5:	mov    r12,QWORD PTR [rsp+0x28]
    20ca:	mov    r13,QWORD PTR [rsp+0x30]
    20cf:	mov    r14,QWORD PTR [rsp+0x38]
    20d4:	mov    r15,QWORD PTR [rsp+0x40]
    20d9:	add    rsp,0x50
    20dd:	mov    rsp,rbp
    20e0:	pop    rbp
    20e1:	ret

00000000000020e2 <botlish_entry_21: esc_char<generic>>:
    20e2:	push   rbp
    20e3:	mov    rbp,rsp
    20e6:	sub    rsp,0x10
    20ea:	mov    QWORD PTR [rsp],r12
    20ee:	mov    r12,rdi
    20f1:	mov    rsi,QWORD PTR [rdx]
    20f4:	mov    r8,QWORD PTR [rdx+0x8]
    20f8:	mov    rcx,QWORD PTR [rdx+0x10]
    20fc:	mov    rdx,r8
    20ff:	call   2104 <botlish_entry_21+0x22>
			2100: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_char<generic>
    2104:	mov    r8,QWORD PTR [rip+0x0]        # 210b <botlish_entry_21+0x29>
			2107: R_X86_64_GOTPCREL	rt_plan_materialize-0x4
    210b:	mov    rsi,rax
    210e:	mov    rdi,r12
    2111:	call   r8
    2114:	mov    r12,QWORD PTR [rsp]
    2118:	add    rsp,0x10
    211c:	mov    rsp,rbp
    211f:	pop    rbp
    2120:	ret
    2121:	add    BYTE PTR [rax],al
    2123:	add    BYTE PTR [rax],al
    2125:	add    BYTE PTR [rax],al
	...

0000000000002128 <botlish_fn_22: esc_from<generic>>:
    2128:	push   rbp
    2129:	mov    rbp,rsp
    212c:	sub    rsp,0xb0
    2133:	mov    QWORD PTR [rsp+0x80],rbx
    213b:	mov    QWORD PTR [rsp+0x88],r12
    2143:	mov    QWORD PTR [rsp+0x90],r13
    214b:	mov    QWORD PTR [rsp+0x98],r14
    2153:	mov    QWORD PTR [rsp+0xa0],r15
    215b:	mov    r14,rdi
    215e:	mov    QWORD PTR [rsp+0x28],0x0
    2167:	mov    QWORD PTR [rsp+0x30],0x0
    2170:	mov    QWORD PTR [rsp],rsi
    2174:	mov    QWORD PTR [rsp+0x8],rdx
    2179:	mov    r12,rdx
    217c:	mov    QWORD PTR [rsp+0x10],rcx
    2181:	mov    QWORD PTR [rsp+0x68],rcx
    2186:	mov    QWORD PTR [rsp+0x18],r8
    218b:	mov    r15,r8
    218e:	mov    QWORD PTR [rsp+0x20],r9
    2193:	mov    r13,r9
    2196:	xor    eax,eax
    2198:	test   rsi,0x7
    219f:	jne    21ae <botlish_fn_22+0x86>
    21a5:	movzx  rax,BYTE PTR [rsi]
    21a9:	cmp    al,0x2
    21ab:	sete   al
    21ae:	test   al,al
    21b0:	jne    21d3 <botlish_fn_22+0xab>
    21b6:	mov    rdi,r14
    21b9:	mov    rax,QWORD PTR [rdi+0x10]
    21bd:	mov    rcx,QWORD PTR [rax+0xc8]
    21c4:	mov    edx,0x1
    21c9:	call   21ce <botlish_fn_22+0xa6>
			21ca: R_X86_64_PLT32	rt_type_error-0x4
    21ce:	jmp    2390 <botlish_fn_22+0x268>
    21d3:	mov    rbx,rsi
    21d6:	mov    rdi,r14
    21d9:	call   21de <botlish_fn_22+0xb6>
			21da: R_X86_64_PLT32	rt_str_len-0x4
    21de:	mov    rcx,r12
    21e1:	and    rcx,rax
    21e4:	mov    rdx,rax
    21e7:	test   rcx,0x1
    21ee:	jne    2214 <botlish_fn_22+0xec>
    21f4:	mov    rsi,r12
    21f7:	mov    rdi,r14
    21fa:	call   21ff <botlish_fn_22+0xd7>
			21fb: R_X86_64_PLT32	rt_int_cmp-0x4
    21ff:	mov    ecx,0x2
    2204:	test   rax,rax
    2207:	cmovge rcx,QWORD PTR [rip+0x1f1]        # 2400 <botlish_fn_22+0x2d8>
    220f:	jmp    2224 <botlish_fn_22+0xfc>
    2214:	mov    ecx,0x2
    2219:	cmp    r12,rdx
    221c:	cmovge rcx,QWORD PTR [rip+0x1dc]        # 2400 <botlish_fn_22+0x2d8>
    2224:	cmp    rcx,0x6
    2228:	je     235f <botlish_fn_22+0x237>
    222e:	mov    QWORD PTR [rsp+0x28],0x3
    2237:	test   r12,0x1
    223e:	je     2256 <botlish_fn_22+0x12e>
    2244:	mov    rax,r12
    2247:	add    rax,0x2
    224b:	seto   cl
    224e:	test   cl,cl
    2250:	je     2266 <botlish_fn_22+0x13e>
    2256:	mov    edx,0x3
    225b:	mov    rsi,r12
    225e:	mov    rdi,r14
    2261:	call   2266 <botlish_fn_22+0x13e>
			2262: R_X86_64_PLT32	rt_int_add-0x4
    2266:	mov    QWORD PTR [rsp+0x28],rax
    226b:	mov    QWORD PTR [rsp+0x70],rax
    2270:	mov    QWORD PTR [rsp+0x30],0x3
    2279:	test   r12,0x1
    2280:	je     2298 <botlish_fn_22+0x170>
    2286:	mov    rcx,r12
    2289:	add    rcx,0x2
    228d:	seto   al
    2290:	test   al,al
    2292:	je     22ab <botlish_fn_22+0x183>
    2298:	mov    edx,0x3
    229d:	mov    rsi,r12
    22a0:	mov    rdi,r14
    22a3:	call   22a8 <botlish_fn_22+0x180>
			22a4: R_X86_64_PLT32	rt_int_add-0x4
    22a8:	mov    rcx,rax
    22ab:	mov    QWORD PTR [rsp+0x30],rcx
    22b0:	mov    rdx,r12
    22b3:	mov    rsi,rbx
    22b6:	mov    rdi,r14
    22b9:	call   22be <botlish_fn_22+0x196>
			22ba: R_X86_64_PLT32	rt_substr-0x4
    22be:	test   rax,rax
    22c1:	je     2390 <botlish_fn_22+0x268>
    22c7:	mov    QWORD PTR [rsp+0x8],rax
    22cc:	mov    rsi,rax
    22cf:	mov    r12,r15
    22d2:	mov    rcx,r13
    22d5:	mov    rdx,r12
    22d8:	mov    rdi,r14
    22db:	call   22e0 <botlish_fn_22+0x1b8>
			22dc: R_X86_64_PLT32	botlish_fn_21-0x4 ; esc_char<generic>
    22e0:	test   rax,rax
    22e3:	je     2390 <botlish_fn_22+0x268>
    22e9:	mov    QWORD PTR [rsp+0x8],rax
    22ee:	lea    rcx,[rsp+0x48]
    22f3:	mov    QWORD PTR [rsp+0x48],0x0
    22fc:	mov    r11,QWORD PTR [rsp+0x68]
    2301:	mov    QWORD PTR [rsp+0x50],r11
    2306:	mov    QWORD PTR [rsp+0x58],0x0
    230f:	mov    QWORD PTR [rsp+0x60],rax
    2314:	mov    esi,0x2
    2319:	mov    edx,0x4
    231e:	mov    rdi,r14
    2321:	call   2326 <botlish_fn_22+0x1fe>
			2322: R_X86_64_PLT32	rt_construct-0x4
    2326:	test   rax,rax
    2329:	je     2390 <botlish_fn_22+0x268>
    232f:	mov    QWORD PTR [rsp],rbx
    2333:	mov    rcx,QWORD PTR [rsp+0x70]
    2338:	mov    QWORD PTR [rsp+0x8],rcx
    233d:	mov    QWORD PTR [rsp+0x10],rax
    2342:	mov    QWORD PTR [rsp+0x18],r12
    2347:	mov    QWORD PTR [rsp+0x20],r13
    234c:	mov    QWORD PTR [rsp+0x68],rax
    2351:	mov    r15,r12
    2354:	mov    r12,rcx
    2357:	mov    rsi,rbx
    235a:	jmp    2196 <botlish_fn_22+0x6e>
    235f:	mov    r11,QWORD PTR [rsp+0x68]
    2364:	xor    rsi,rsi
    2367:	lea    rcx,[rsp+0x38]
    236c:	mov    QWORD PTR [rsp+0x38],0x0
    2375:	mov    QWORD PTR [rsp+0x40],r11
    237a:	mov    edx,0x2
    237f:	mov    rdi,r14
    2382:	call   2387 <botlish_fn_22+0x25f>
			2383: R_X86_64_PLT32	rt_construct-0x4
    2387:	test   rax,rax
    238a:	jne    23c7 <botlish_fn_22+0x29f>
    2390:	xor    rax,rax
    2393:	mov    rbx,QWORD PTR [rsp+0x80]
    239b:	mov    r12,QWORD PTR [rsp+0x88]
    23a3:	mov    r13,QWORD PTR [rsp+0x90]
    23ab:	mov    r14,QWORD PTR [rsp+0x98]
    23b3:	mov    r15,QWORD PTR [rsp+0xa0]
    23bb:	add    rsp,0xb0
    23c2:	mov    rsp,rbp
    23c5:	pop    rbp
    23c6:	ret
    23c7:	mov    rbx,QWORD PTR [rsp+0x80]
    23cf:	mov    r12,QWORD PTR [rsp+0x88]
    23d7:	mov    r13,QWORD PTR [rsp+0x90]
    23df:	mov    r14,QWORD PTR [rsp+0x98]
    23e7:	mov    r15,QWORD PTR [rsp+0xa0]
    23ef:	add    rsp,0xb0
    23f6:	mov    rsp,rbp
    23f9:	pop    rbp
    23fa:	ret
    23fb:	add    BYTE PTR [rax],al
    23fd:	add    BYTE PTR [rax],al
    23ff:	add    BYTE PTR [rsi],al
    2401:	add    BYTE PTR [rax],al
    2403:	add    BYTE PTR [rax],al
    2405:	add    BYTE PTR [rax],al
	...

0000000000002408 <botlish_entry_22: esc_from<generic>>:
    2408:	push   rbp
    2409:	mov    rbp,rsp
    240c:	mov    rsi,QWORD PTR [rdx]
    240f:	mov    r10,QWORD PTR [rdx+0x8]
    2413:	mov    rcx,QWORD PTR [rdx+0x10]
    2417:	mov    r8,QWORD PTR [rdx+0x18]
    241b:	mov    r9,QWORD PTR [rdx+0x20]
    241f:	mov    rdx,r10
    2422:	call   2427 <botlish_entry_22+0x1f>
			2423: R_X86_64_PLT32	botlish_fn_22-0x4 ; esc_from<generic>
    2427:	mov    rsp,rbp
    242a:	pop    rbp
    242b:	ret
    242c:	add    BYTE PTR [rax],al
	...

0000000000002430 <botlish_fn_23: check<generic>>:
    2430:	push   rbp
    2431:	mov    rbp,rsp
    2434:	sub    rsp,0x80
    243b:	mov    QWORD PTR [rsp+0x50],rbx
    2440:	mov    QWORD PTR [rsp+0x58],r12
    2445:	mov    QWORD PTR [rsp+0x60],r13
    244a:	mov    QWORD PTR [rsp+0x68],r14
    244f:	mov    QWORD PTR [rsp+0x70],r15
    2454:	mov    r14,rdi
    2457:	mov    QWORD PTR [rsp+0x28],0x0
    2460:	mov    QWORD PTR [rsp+0x30],0x0
    2469:	mov    QWORD PTR [rsp],rsi
    246d:	mov    r15,rsi
    2470:	mov    QWORD PTR [rsp+0x8],rdx
    2475:	mov    QWORD PTR [rsp+0x10],rcx
    247a:	mov    r12,rcx
    247d:	mov    QWORD PTR [rsp+0x18],r8
    2482:	mov    r13,r8
    2485:	mov    QWORD PTR [rsp+0x20],r9
    248a:	mov    rbx,r9
    248d:	mov    QWORD PTR [rsp+0x38],rdx
    2492:	test   rsi,0x1
    2499:	mov    r15,rsi
    249c:	jne    24c7 <botlish_fn_23+0x97>
    24a2:	mov    edx,0x1
    24a7:	mov    rsi,r15
    24aa:	mov    rdi,r14
    24ad:	call   24b2 <botlish_fn_23+0x82>
			24ae: R_X86_64_PLT32	rt_int_cmp-0x4
    24b2:	mov    ecx,0x2
    24b7:	test   rax,rax
    24ba:	cmovle rcx,QWORD PTR [rip+0x19e]        # 2660 <botlish_fn_23+0x230>
    24c2:	jmp    24db <botlish_fn_23+0xab>
    24c7:	mov    ecx,0x2
    24cc:	mov    rsi,r15
    24cf:	cmp    rsi,0x1
    24d3:	cmovle rcx,QWORD PTR [rip+0x185]        # 2660 <botlish_fn_23+0x230>
    24db:	cmp    rcx,0x6
    24df:	je     262f <botlish_fn_23+0x1ff>
    24e5:	mov    rdx,r12
    24e8:	mov    rsi,rbx
    24eb:	mov    rdi,r14
    24ee:	call   24f3 <botlish_fn_23+0xc3>
			24ef: R_X86_64_PLT32	botlish_fn_9-0x4 ; web::emailish?<generic>
    24f3:	test   rax,rax
    24f6:	jne    2524 <botlish_fn_23+0xf4>
    24fc:	xor    rax,rax
    24ff:	mov    rbx,QWORD PTR [rsp+0x50]
    2504:	mov    r12,QWORD PTR [rsp+0x58]
    2509:	mov    r13,QWORD PTR [rsp+0x60]
    250e:	mov    r14,QWORD PTR [rsp+0x68]
    2513:	mov    r15,QWORD PTR [rsp+0x70]
    2518:	add    rsp,0x80
    251f:	mov    rsp,rbp
    2522:	pop    rbp
    2523:	ret
    2524:	cmp    rax,0x6
    2528:	je     2546 <botlish_fn_23+0x116>
    252e:	mov    edx,0x1
    2533:	mov    QWORD PTR [rsp+0x28],0x1
    253c:	mov    QWORD PTR [rsp+0x40],rdx
    2541:	jmp    2559 <botlish_fn_23+0x129>
    2546:	mov    edx,0x3
    254b:	mov    QWORD PTR [rsp+0x40],rdx
    2550:	mov    QWORD PTR [rsp+0x28],0x3
    2559:	mov    edx,0x3
    255e:	mov    QWORD PTR [rsp+0x30],0x3
    2567:	mov    rsi,r15
    256a:	test   rsi,0x1
    2571:	jne    257f <botlish_fn_23+0x14f>
    2577:	mov    rsi,r15
    257a:	jmp    25ae <botlish_fn_23+0x17e>
    257f:	mov    rsi,r15
    2582:	mov    rax,rsi
    2585:	sub    rax,0x3
    2589:	seto   cl
    258c:	add    rax,0x1
    2593:	test   cl,cl
    2595:	je     25a3 <botlish_fn_23+0x173>
    259b:	mov    rsi,r15
    259e:	jmp    25ae <botlish_fn_23+0x17e>
    25a3:	mov    rsi,rax
    25a6:	mov    r15,rax
    25a9:	jmp    25bc <botlish_fn_23+0x18c>
    25ae:	mov    rdi,r14
    25b1:	call   25b6 <botlish_fn_23+0x186>
			25b2: R_X86_64_PLT32	rt_int_sub-0x4
    25b6:	mov    rsi,rax
    25b9:	mov    r15,rax
    25bc:	mov    QWORD PTR [rsp],rsi
    25c0:	mov    rdx,QWORD PTR [rsp+0x40]
    25c5:	mov    rsi,QWORD PTR [rsp+0x38]
    25ca:	mov    rdi,rsi
    25cd:	and    rdi,rdx
    25d0:	test   rdi,0x1
    25d7:	je     25fc <botlish_fn_23+0x1cc>
    25dd:	lea    r8,[rdx-0x1]
    25e1:	mov    rax,rsi
    25e4:	add    rax,r8
    25e7:	seto   r9b
    25eb:	test   r9b,r9b
    25ee:	jne    25fc <botlish_fn_23+0x1cc>
    25f4:	mov    rsi,r15
    25f7:	jmp    2607 <botlish_fn_23+0x1d7>
    25fc:	mov    rdi,r14
    25ff:	call   2604 <botlish_fn_23+0x1d4>
			2600: R_X86_64_PLT32	rt_int_add-0x4
    2604:	mov    rsi,r15
    2607:	mov    rsi,r15
    260a:	mov    QWORD PTR [rsp],rsi
    260e:	mov    QWORD PTR [rsp+0x8],rax
    2613:	mov    QWORD PTR [rsp+0x10],r12
    2618:	mov    r8,r13
    261b:	mov    QWORD PTR [rsp+0x18],r8
    2620:	mov    QWORD PTR [rsp+0x20],rbx
    2625:	mov    QWORD PTR [rsp+0x38],rax
    262a:	jmp    2492 <botlish_fn_23+0x62>
    262f:	mov    rax,QWORD PTR [rsp+0x38]
    2634:	mov    rbx,QWORD PTR [rsp+0x50]
    2639:	mov    r12,QWORD PTR [rsp+0x58]
    263e:	mov    r13,QWORD PTR [rsp+0x60]
    2643:	mov    r14,QWORD PTR [rsp+0x68]
    2648:	mov    r15,QWORD PTR [rsp+0x70]
    264d:	add    rsp,0x80
    2654:	mov    rsp,rbp
    2657:	pop    rbp
    2658:	ret
    2659:	add    BYTE PTR [rax],al
    265b:	add    BYTE PTR [rax],al
    265d:	add    BYTE PTR [rax],al
    265f:	add    BYTE PTR [rsi],al
    2661:	add    BYTE PTR [rax],al
    2663:	add    BYTE PTR [rax],al
    2665:	add    BYTE PTR [rax],al
	...

0000000000002668 <botlish_entry_23: check<generic>>:
    2668:	push   rbp
    2669:	mov    rbp,rsp
    266c:	mov    rsi,QWORD PTR [rdx]
    266f:	mov    r10,QWORD PTR [rdx+0x8]
    2673:	mov    rcx,QWORD PTR [rdx+0x10]
    2677:	mov    r8,QWORD PTR [rdx+0x18]
    267b:	mov    r9,QWORD PTR [rdx+0x20]
    267f:	mov    rdx,r10
    2682:	call   2687 <botlish_entry_23+0x1f>
			2683: R_X86_64_PLT32	botlish_fn_23-0x4 ; check<generic>
    2687:	mov    rsp,rbp
    268a:	pop    rbp
    268b:	ret

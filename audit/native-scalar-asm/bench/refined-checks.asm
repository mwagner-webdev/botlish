; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 17772  (per function: 935 112 1713 1425 473 864 506 952 504 681 769 450 884 644 540 540 636 681 769 450 884 644 540 540 636)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> web::uri_escape_text<generic>
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
;   botlish_fn_12 / botlish_entry_12 -> scan_local<generic>
;   botlish_fn_13 / botlish_entry_13 -> scan_label<generic>
;   botlish_fn_14 / botlish_entry_14 -> scan_alpha<generic>
;   botlish_fn_15 / botlish_entry_15 -> tld_ok<generic>
;   botlish_fn_16 / botlish_entry_16 -> domain_loop<generic>
;   botlish_fn_17 / botlish_entry_17 -> <str>
;   botlish_fn_18 / botlish_entry_18 -> <generic>
;   botlish_fn_19 / botlish_entry_19 -> char_at<generic>
;   botlish_fn_20 / botlish_entry_20 -> scan_local<generic>
;   botlish_fn_21 / botlish_entry_21 -> scan_label<generic>
;   botlish_fn_22 / botlish_entry_22 -> scan_alpha<generic>
;   botlish_fn_23 / botlish_entry_23 -> tld_ok<generic>
;   botlish_fn_24 / botlish_entry_24 -> domain_loop<generic>


refined-checks.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x170
       b:	mov    QWORD PTR [rsp+0x140],rbx
      13:	mov    QWORD PTR [rsp+0x148],r12
      1b:	mov    QWORD PTR [rsp+0x150],r13
      23:	mov    QWORD PTR [rsp+0x158],r14
      2b:	mov    QWORD PTR [rsp+0x160],r15
      33:	mov    rax,QWORD PTR [rdi+0x10]
      37:	mov    rcx,QWORD PTR [rax]
      3a:	mov    QWORD PTR [rsp],rcx
      3e:	mov    QWORD PTR [rsp+0x138],rcx
      46:	mov    rax,QWORD PTR [rdi+0x10]
      4a:	mov    rdx,QWORD PTR [rax+0x8]
      4e:	mov    QWORD PTR [rsp+0x8],rdx
      53:	mov    QWORD PTR [rsp+0x130],rdx
      5b:	mov    rax,QWORD PTR [rdi+0x10]
      5f:	mov    rsi,QWORD PTR [rax+0x10]
      63:	mov    QWORD PTR [rsp+0x10],rsi
      68:	mov    QWORD PTR [rsp+0x128],rsi
      70:	mov    rax,QWORD PTR [rdi+0x10]
      74:	mov    r8,QWORD PTR [rax+0x18]
      78:	mov    QWORD PTR [rsp+0x18],r8
      7d:	mov    QWORD PTR [rsp+0x120],r8
      85:	mov    rax,QWORD PTR [rdi+0x10]
      89:	mov    r8,QWORD PTR [rax+0x20]
      8d:	mov    QWORD PTR [rsp+0x20],r8
      92:	mov    rcx,QWORD PTR [rdi+0x10]
      96:	mov    r9,QWORD PTR [rcx+0x28]
      9a:	mov    QWORD PTR [rsp+0x28],r9
      9f:	mov    rdx,QWORD PTR [rdi+0x10]
      a3:	mov    r10,QWORD PTR [rdx+0x30]
      a7:	mov    QWORD PTR [rsp+0x30],r10
      ac:	mov    r11,QWORD PTR [rdi+0x10]
      b0:	mov    r11,QWORD PTR [r11+0x38]
      b4:	mov    QWORD PTR [rsp+0x38],r11
      b9:	mov    rax,QWORD PTR [rdi+0x10]
      bd:	mov    r12,QWORD PTR [rax+0x40]
      c1:	mov    QWORD PTR [rsp+0x40],r12
      c6:	mov    rax,QWORD PTR [rdi+0x10]
      ca:	mov    r13,QWORD PTR [rax+0x48]
      ce:	mov    QWORD PTR [rsp+0x48],r13
      d3:	mov    rax,QWORD PTR [rdi+0x10]
      d7:	mov    r14,QWORD PTR [rax+0x50]
      db:	mov    QWORD PTR [rsp+0x50],r14
      e0:	mov    rax,QWORD PTR [rdi+0x10]
      e4:	mov    r15,QWORD PTR [rax+0x58]
      e8:	mov    QWORD PTR [rsp+0x58],r15
      ed:	mov    rax,QWORD PTR [rdi+0x10]
      f1:	mov    rbx,QWORD PTR [rax+0x60]
      f5:	mov    QWORD PTR [rsp+0x60],rbx
      fa:	mov    rax,QWORD PTR [rdi+0x10]
      fe:	mov    rax,QWORD PTR [rax+0x68]
     102:	mov    QWORD PTR [rsp+0x68],rax
     107:	mov    rcx,QWORD PTR [rdi+0x10]
     10b:	mov    rcx,QWORD PTR [rcx+0x70]
     10f:	mov    QWORD PTR [rsp+0x70],rcx
     114:	mov    rdx,QWORD PTR [rdi+0x10]
     118:	mov    QWORD PTR [rsp+0x118],rdi
     120:	mov    rdi,QWORD PTR [rdx+0x78]
     124:	mov    QWORD PTR [rsp+0x78],rdi
     129:	lea    rdx,[rsp+0x80]
     131:	mov    rsi,QWORD PTR [rsp+0x138]
     139:	mov    QWORD PTR [rsp+0x80],rsi
     141:	mov    rsi,QWORD PTR [rsp+0x130]
     149:	mov    QWORD PTR [rsp+0x88],rsi
     151:	mov    rsi,QWORD PTR [rsp+0x128]
     159:	mov    QWORD PTR [rsp+0x90],rsi
     161:	mov    rsi,QWORD PTR [rsp+0x120]
     169:	mov    QWORD PTR [rsp+0x98],rsi
     171:	mov    QWORD PTR [rsp+0xa0],r8
     179:	mov    QWORD PTR [rsp+0xa8],r9
     181:	mov    QWORD PTR [rsp+0xb0],r10
     189:	mov    QWORD PTR [rsp+0xb8],r11
     191:	mov    QWORD PTR [rsp+0xc0],r12
     199:	mov    QWORD PTR [rsp+0xc8],r13
     1a1:	mov    QWORD PTR [rsp+0xd0],r14
     1a9:	mov    QWORD PTR [rsp+0xd8],r15
     1b1:	mov    QWORD PTR [rsp+0xe0],rbx
     1b9:	mov    QWORD PTR [rsp+0xe8],rax
     1c1:	mov    QWORD PTR [rsp+0xf0],rcx
     1c9:	mov    QWORD PTR [rsp+0xf8],rdi
     1d1:	mov    esi,0x10
     1d6:	mov    rdi,QWORD PTR [rsp+0x118]
     1de:	call   1e3 <botlish_fn_0+0x1e3>
			1df: R_X86_64_PLT32	rt_list_new-0x4
     1e3:	test   rax,rax
     1e6:	je     319 <botlish_fn_0+0x319>
     1ec:	mov    QWORD PTR [rsp],rax
     1f0:	lea    r8,[rsp+0x100]
     1f8:	mov    QWORD PTR [rsp+0x100],rax
     200:	mov    ecx,0x1
     205:	mov    rdx,QWORD PTR [rip+0x0]        # 20c <botlish_fn_0+0x20c>
			208: R_X86_64_GOTPCREL	botlish_entry_1-0x4 ; web::uri_escape_text<generic>
     20c:	mov    rdi,QWORD PTR [rsp+0x118]
     214:	mov    rsi,rcx
     217:	call   21c <botlish_fn_0+0x21c>
			218: R_X86_64_PLT32	rt_closure_new-0x4
     21c:	mov    QWORD PTR [rsp],rax
     220:	mov    rdi,QWORD PTR [rsp+0x118]
     228:	mov    rcx,QWORD PTR [rdi+0x10]
     22c:	mov    rdx,QWORD PTR [rcx+0x80]
     233:	mov    QWORD PTR [rsp+0x8],rdx
     238:	mov    rsi,rax
     23b:	call   240 <botlish_fn_0+0x240>
			23c: R_X86_64_PLT32	botlish_fn_1-0x4 ; web::uri_escape_text<generic>
     240:	test   rax,rax
     243:	je     319 <botlish_fn_0+0x319>
     249:	mov    QWORD PTR [rsp],rax
     24d:	mov    r12,rax
     250:	mov    esi,0x321
     255:	mov    QWORD PTR [rsp+0x8],0x321
     25e:	mov    edx,0x1
     263:	mov    QWORD PTR [rsp+0x10],0x1
     26c:	mov    rdi,QWORD PTR [rsp+0x118]
     274:	mov    rcx,QWORD PTR [rdi+0x10]
     278:	mov    rcx,QWORD PTR [rcx+0x88]
     27f:	mov    QWORD PTR [rsp+0x18],rcx
     284:	mov    r8,r12
     287:	call   28c <botlish_fn_0+0x28c>
			288: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
     28c:	mov    rbx,rax
     28f:	test   rbx,rbx
     292:	je     319 <botlish_fn_0+0x319>
     298:	mov    QWORD PTR [rsp+0x8],rbx
     29d:	mov    esi,0x321
     2a2:	mov    QWORD PTR [rsp+0x10],0x321
     2ab:	mov    edx,0x1
     2b0:	mov    QWORD PTR [rsp+0x18],0x1
     2b9:	mov    rdi,QWORD PTR [rsp+0x118]
     2c1:	mov    rax,QWORD PTR [rdi+0x10]
     2c5:	mov    rcx,QWORD PTR [rax+0x90]
     2cc:	mov    QWORD PTR [rsp+0x20],rcx
     2d1:	mov    r8,r12
     2d4:	call   2d9 <botlish_fn_0+0x2d9>
			2d5: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
     2d9:	test   rax,rax
     2dc:	je     319 <botlish_fn_0+0x319>
     2e2:	mov    QWORD PTR [rsp],rax
     2e6:	lea    rdx,[rsp+0x108]
     2ee:	mov    QWORD PTR [rsp+0x108],rbx
     2f6:	mov    QWORD PTR [rsp+0x110],rax
     2fe:	mov    esi,0x2
     303:	mov    rdi,QWORD PTR [rsp+0x118]
     30b:	call   310 <botlish_fn_0+0x310>
			30c: R_X86_64_PLT32	rt_list_new-0x4
     310:	test   rax,rax
     313:	jne    350 <botlish_fn_0+0x350>
     319:	xor    rax,rax
     31c:	mov    rbx,QWORD PTR [rsp+0x140]
     324:	mov    r12,QWORD PTR [rsp+0x148]
     32c:	mov    r13,QWORD PTR [rsp+0x150]
     334:	mov    r14,QWORD PTR [rsp+0x158]
     33c:	mov    r15,QWORD PTR [rsp+0x160]
     344:	add    rsp,0x170
     34b:	mov    rsp,rbp
     34e:	pop    rbp
     34f:	ret
     350:	mov    rbx,QWORD PTR [rsp+0x140]
     358:	mov    r12,QWORD PTR [rsp+0x148]
     360:	mov    r13,QWORD PTR [rsp+0x150]
     368:	mov    r14,QWORD PTR [rsp+0x158]
     370:	mov    r15,QWORD PTR [rsp+0x160]
     378:	add    rsp,0x170
     37f:	mov    rsp,rbp
     382:	pop    rbp
     383:	ret

0000000000000384 <botlish_entry_0: <program entry>>:
     384:	push   rbp
     385:	mov    rbp,rsp
     388:	call   38d <botlish_entry_0+0x9>
			389: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     38d:	mov    rsp,rbp
     390:	pop    rbp
     391:	ret

0000000000000392 <botlish_fn_1: web::uri_escape_text<generic>>:
     392:	push   rbp
     393:	mov    rbp,rsp
     396:	sub    rsp,0x20
     39a:	mov    QWORD PTR [rsp],rdx
     39e:	mov    r9,rdx
     3a1:	mov    edx,0x1
     3a6:	mov    QWORD PTR [rsp+0x8],0x1
     3af:	mov    rax,QWORD PTR [rdi+0x10]
     3b3:	mov    rcx,QWORD PTR [rax+0x98]
     3ba:	mov    QWORD PTR [rsp+0x10],rcx
     3bf:	mov    rax,QWORD PTR [rsi+0x20]
     3c3:	mov    r8,QWORD PTR [rax]
     3c6:	mov    QWORD PTR [rsp+0x18],r8
     3cb:	mov    rsi,r9
     3ce:	call   3d3 <botlish_fn_1+0x41>
			3cf: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
     3d3:	test   rax,rax
     3d6:	jne    3e8 <botlish_fn_1+0x56>
     3dc:	xor    rax,rax
     3df:	add    rsp,0x20
     3e3:	mov    rsp,rbp
     3e6:	pop    rbp
     3e7:	ret
     3e8:	add    rsp,0x20
     3ec:	mov    rsp,rbp
     3ef:	pop    rbp
     3f0:	ret

00000000000003f1 <botlish_entry_1: web::uri_escape_text<generic>>:
     3f1:	push   rbp
     3f2:	mov    rbp,rsp
     3f5:	mov    rdx,QWORD PTR [rdx]
     3f8:	call   3fd <botlish_entry_1+0xc>
			3f9: R_X86_64_PLT32	botlish_fn_1-0x4 ; web::uri_escape_text<generic>
     3fd:	mov    rsp,rbp
     400:	pop    rbp
     401:	ret
     402:	add    BYTE PTR [rax],al
     404:	add    BYTE PTR [rax],al
	...

0000000000000408 <botlish_fn_2: high_nibble<generic>>:
     408:	push   rbp
     409:	mov    rbp,rsp
     40c:	sub    rsp,0x10
     410:	mov    QWORD PTR [rsp],rbx
     414:	mov    QWORD PTR [rsp+0x8],r12
     419:	mov    r8d,0x1
     41f:	test   rsi,0x1
     426:	jne    446 <botlish_fn_2+0x3e>
     42c:	xor    r8d,r8d
     42f:	test   rsi,0x7
     436:	jne    446 <botlish_fn_2+0x3e>
     43c:	movzx  rax,BYTE PTR [rsi]
     440:	cmp    al,0x1
     442:	sete   r8b
     446:	test   r8b,r8b
     449:	jne    47a <botlish_fn_2+0x72>
     44f:	mov    rax,QWORD PTR [rdi+0x10]
     453:	mov    rcx,QWORD PTR [rax+0xa0]
     45a:	xor    rbx,rbx
     45d:	mov    rdx,rbx
     460:	call   465 <botlish_fn_2+0x5d>
			461: R_X86_64_PLT32	rt_type_error-0x4
     465:	mov    rax,rbx
     468:	mov    rbx,QWORD PTR [rsp]
     46c:	mov    r12,QWORD PTR [rsp+0x8]
     471:	add    rsp,0x10
     475:	mov    rsp,rbp
     478:	pop    rbp
     479:	ret
     47a:	mov    r12,rdi
     47d:	test   rsi,0x1
     484:	mov    rbx,rsi
     487:	jne    4b2 <botlish_fn_2+0xaa>
     48d:	mov    edx,0x1f
     492:	mov    rsi,rbx
     495:	mov    rdi,r12
     498:	call   49d <botlish_fn_2+0x95>
			499: R_X86_64_PLT32	rt_int_cmp-0x4
     49d:	mov    ecx,0x2
     4a2:	test   rax,rax
     4a5:	cmovle rcx,QWORD PTR [rip+0x583]        # a30 <botlish_fn_2+0x628>
     4ad:	jmp    4c6 <botlish_fn_2+0xbe>
     4b2:	mov    ecx,0x2
     4b7:	mov    rsi,rbx
     4ba:	cmp    rsi,0x1f
     4be:	cmovle rcx,QWORD PTR [rip+0x56a]        # a30 <botlish_fn_2+0x628>
     4c6:	cmp    rcx,0x6
     4ca:	je     a13 <botlish_fn_2+0x60b>
     4d0:	mov    rsi,rbx
     4d3:	test   rsi,0x1
     4da:	jne    505 <botlish_fn_2+0xfd>
     4e0:	mov    edx,0x3f
     4e5:	mov    rsi,rbx
     4e8:	mov    rdi,r12
     4eb:	call   4f0 <botlish_fn_2+0xe8>
			4ec: R_X86_64_PLT32	rt_int_cmp-0x4
     4f0:	mov    ecx,0x2
     4f5:	test   rax,rax
     4f8:	cmovle rcx,QWORD PTR [rip+0x530]        # a30 <botlish_fn_2+0x628>
     500:	jmp    519 <botlish_fn_2+0x111>
     505:	mov    ecx,0x2
     50a:	mov    rsi,rbx
     50d:	cmp    rsi,0x3f
     511:	cmovle rcx,QWORD PTR [rip+0x517]        # a30 <botlish_fn_2+0x628>
     519:	cmp    rcx,0x6
     51d:	je     a09 <botlish_fn_2+0x601>
     523:	mov    rsi,rbx
     526:	test   rsi,0x1
     52d:	jne    558 <botlish_fn_2+0x150>
     533:	mov    edx,0x5f
     538:	mov    rsi,rbx
     53b:	mov    rdi,r12
     53e:	call   543 <botlish_fn_2+0x13b>
			53f: R_X86_64_PLT32	rt_int_cmp-0x4
     543:	mov    ecx,0x2
     548:	test   rax,rax
     54b:	cmovle rcx,QWORD PTR [rip+0x4dd]        # a30 <botlish_fn_2+0x628>
     553:	jmp    56c <botlish_fn_2+0x164>
     558:	mov    ecx,0x2
     55d:	mov    rsi,rbx
     560:	cmp    rsi,0x5f
     564:	cmovle rcx,QWORD PTR [rip+0x4c4]        # a30 <botlish_fn_2+0x628>
     56c:	cmp    rcx,0x6
     570:	je     9ff <botlish_fn_2+0x5f7>
     576:	mov    rsi,rbx
     579:	test   rsi,0x1
     580:	jne    5ab <botlish_fn_2+0x1a3>
     586:	mov    edx,0x7f
     58b:	mov    rsi,rbx
     58e:	mov    rdi,r12
     591:	call   596 <botlish_fn_2+0x18e>
			592: R_X86_64_PLT32	rt_int_cmp-0x4
     596:	mov    ecx,0x2
     59b:	test   rax,rax
     59e:	cmovle rcx,QWORD PTR [rip+0x48a]        # a30 <botlish_fn_2+0x628>
     5a6:	jmp    5bf <botlish_fn_2+0x1b7>
     5ab:	mov    ecx,0x2
     5b0:	mov    rsi,rbx
     5b3:	cmp    rsi,0x7f
     5b7:	cmovle rcx,QWORD PTR [rip+0x471]        # a30 <botlish_fn_2+0x628>
     5bf:	cmp    rcx,0x6
     5c3:	je     9f5 <botlish_fn_2+0x5ed>
     5c9:	mov    rsi,rbx
     5cc:	test   rsi,0x1
     5d3:	jne    5fe <botlish_fn_2+0x1f6>
     5d9:	mov    edx,0x9f
     5de:	mov    rsi,rbx
     5e1:	mov    rdi,r12
     5e4:	call   5e9 <botlish_fn_2+0x1e1>
			5e5: R_X86_64_PLT32	rt_int_cmp-0x4
     5e9:	mov    ecx,0x2
     5ee:	test   rax,rax
     5f1:	cmovle rcx,QWORD PTR [rip+0x437]        # a30 <botlish_fn_2+0x628>
     5f9:	jmp    615 <botlish_fn_2+0x20d>
     5fe:	mov    ecx,0x2
     603:	mov    rsi,rbx
     606:	cmp    rsi,0x9f
     60d:	cmovle rcx,QWORD PTR [rip+0x41b]        # a30 <botlish_fn_2+0x628>
     615:	cmp    rcx,0x6
     619:	je     9eb <botlish_fn_2+0x5e3>
     61f:	mov    rsi,rbx
     622:	test   rsi,0x1
     629:	jne    654 <botlish_fn_2+0x24c>
     62f:	mov    edx,0xbf
     634:	mov    rsi,rbx
     637:	mov    rdi,r12
     63a:	call   63f <botlish_fn_2+0x237>
			63b: R_X86_64_PLT32	rt_int_cmp-0x4
     63f:	mov    ecx,0x2
     644:	test   rax,rax
     647:	cmovle rcx,QWORD PTR [rip+0x3e1]        # a30 <botlish_fn_2+0x628>
     64f:	jmp    66b <botlish_fn_2+0x263>
     654:	mov    ecx,0x2
     659:	mov    rsi,rbx
     65c:	cmp    rsi,0xbf
     663:	cmovle rcx,QWORD PTR [rip+0x3c5]        # a30 <botlish_fn_2+0x628>
     66b:	cmp    rcx,0x6
     66f:	je     9e1 <botlish_fn_2+0x5d9>
     675:	mov    rsi,rbx
     678:	test   rsi,0x1
     67f:	jne    6aa <botlish_fn_2+0x2a2>
     685:	mov    edx,0xdf
     68a:	mov    rsi,rbx
     68d:	mov    rdi,r12
     690:	call   695 <botlish_fn_2+0x28d>
			691: R_X86_64_PLT32	rt_int_cmp-0x4
     695:	mov    ecx,0x2
     69a:	test   rax,rax
     69d:	cmovle rcx,QWORD PTR [rip+0x38b]        # a30 <botlish_fn_2+0x628>
     6a5:	jmp    6c1 <botlish_fn_2+0x2b9>
     6aa:	mov    ecx,0x2
     6af:	mov    rsi,rbx
     6b2:	cmp    rsi,0xdf
     6b9:	cmovle rcx,QWORD PTR [rip+0x36f]        # a30 <botlish_fn_2+0x628>
     6c1:	cmp    rcx,0x6
     6c5:	je     9d7 <botlish_fn_2+0x5cf>
     6cb:	mov    rsi,rbx
     6ce:	test   rsi,0x1
     6d5:	jne    701 <botlish_fn_2+0x2f9>
     6db:	mov    edx,0xff
     6e0:	mov    rsi,rbx
     6e3:	mov    rdi,r12
     6e6:	call   6eb <botlish_fn_2+0x2e3>
			6e7: R_X86_64_PLT32	rt_int_cmp-0x4
     6eb:	mov    r10d,0x2
     6f1:	test   rax,rax
     6f4:	cmovle r10,QWORD PTR [rip+0x334]        # a30 <botlish_fn_2+0x628>
     6fc:	jmp    719 <botlish_fn_2+0x311>
     701:	mov    r10d,0x2
     707:	mov    rsi,rbx
     70a:	cmp    rsi,0xff
     711:	cmovle r10,QWORD PTR [rip+0x317]        # a30 <botlish_fn_2+0x628>
     719:	cmp    r10,0x6
     71d:	je     9cd <botlish_fn_2+0x5c5>
     723:	mov    rsi,rbx
     726:	test   rsi,0x1
     72d:	jne    758 <botlish_fn_2+0x350>
     733:	mov    edx,0x11f
     738:	mov    rsi,rbx
     73b:	mov    rdi,r12
     73e:	call   743 <botlish_fn_2+0x33b>
			73f: R_X86_64_PLT32	rt_int_cmp-0x4
     743:	mov    ecx,0x2
     748:	test   rax,rax
     74b:	cmovle rcx,QWORD PTR [rip+0x2dd]        # a30 <botlish_fn_2+0x628>
     753:	jmp    76f <botlish_fn_2+0x367>
     758:	mov    ecx,0x2
     75d:	mov    rsi,rbx
     760:	cmp    rsi,0x11f
     767:	cmovle rcx,QWORD PTR [rip+0x2c1]        # a30 <botlish_fn_2+0x628>
     76f:	cmp    rcx,0x6
     773:	je     9c3 <botlish_fn_2+0x5bb>
     779:	mov    rsi,rbx
     77c:	test   rsi,0x1
     783:	jne    7ae <botlish_fn_2+0x3a6>
     789:	mov    edx,0x13f
     78e:	mov    rsi,rbx
     791:	mov    rdi,r12
     794:	call   799 <botlish_fn_2+0x391>
			795: R_X86_64_PLT32	rt_int_cmp-0x4
     799:	mov    ecx,0x2
     79e:	test   rax,rax
     7a1:	cmovle rcx,QWORD PTR [rip+0x287]        # a30 <botlish_fn_2+0x628>
     7a9:	jmp    7c5 <botlish_fn_2+0x3bd>
     7ae:	mov    ecx,0x2
     7b3:	mov    rsi,rbx
     7b6:	cmp    rsi,0x13f
     7bd:	cmovle rcx,QWORD PTR [rip+0x26b]        # a30 <botlish_fn_2+0x628>
     7c5:	cmp    rcx,0x6
     7c9:	je     9b9 <botlish_fn_2+0x5b1>
     7cf:	mov    rsi,rbx
     7d2:	test   rsi,0x1
     7d9:	jne    804 <botlish_fn_2+0x3fc>
     7df:	mov    edx,0x15f
     7e4:	mov    rsi,rbx
     7e7:	mov    rdi,r12
     7ea:	call   7ef <botlish_fn_2+0x3e7>
			7eb: R_X86_64_PLT32	rt_int_cmp-0x4
     7ef:	mov    ecx,0x2
     7f4:	test   rax,rax
     7f7:	cmovle rcx,QWORD PTR [rip+0x231]        # a30 <botlish_fn_2+0x628>
     7ff:	jmp    81b <botlish_fn_2+0x413>
     804:	mov    ecx,0x2
     809:	mov    rsi,rbx
     80c:	cmp    rsi,0x15f
     813:	cmovle rcx,QWORD PTR [rip+0x215]        # a30 <botlish_fn_2+0x628>
     81b:	cmp    rcx,0x6
     81f:	je     9af <botlish_fn_2+0x5a7>
     825:	mov    rsi,rbx
     828:	test   rsi,0x1
     82f:	jne    85a <botlish_fn_2+0x452>
     835:	mov    edx,0x17f
     83a:	mov    rsi,rbx
     83d:	mov    rdi,r12
     840:	call   845 <botlish_fn_2+0x43d>
			841: R_X86_64_PLT32	rt_int_cmp-0x4
     845:	mov    edi,0x2
     84a:	test   rax,rax
     84d:	cmovle rdi,QWORD PTR [rip+0x1db]        # a30 <botlish_fn_2+0x628>
     855:	jmp    871 <botlish_fn_2+0x469>
     85a:	mov    edi,0x2
     85f:	mov    rsi,rbx
     862:	cmp    rsi,0x17f
     869:	cmovle rdi,QWORD PTR [rip+0x1bf]        # a30 <botlish_fn_2+0x628>
     871:	cmp    rdi,0x6
     875:	je     9a5 <botlish_fn_2+0x59d>
     87b:	mov    rsi,rbx
     87e:	test   rsi,0x1
     885:	jne    8b0 <botlish_fn_2+0x4a8>
     88b:	mov    edx,0x19f
     890:	mov    rsi,rbx
     893:	mov    rdi,r12
     896:	call   89b <botlish_fn_2+0x493>
			897: R_X86_64_PLT32	rt_int_cmp-0x4
     89b:	mov    ecx,0x2
     8a0:	test   rax,rax
     8a3:	cmovle rcx,QWORD PTR [rip+0x185]        # a30 <botlish_fn_2+0x628>
     8ab:	jmp    8c7 <botlish_fn_2+0x4bf>
     8b0:	mov    ecx,0x2
     8b5:	mov    rsi,rbx
     8b8:	cmp    rsi,0x19f
     8bf:	cmovle rcx,QWORD PTR [rip+0x169]        # a30 <botlish_fn_2+0x628>
     8c7:	cmp    rcx,0x6
     8cb:	je     99b <botlish_fn_2+0x593>
     8d1:	mov    rsi,rbx
     8d4:	test   rsi,0x1
     8db:	jne    906 <botlish_fn_2+0x4fe>
     8e1:	mov    edx,0x1bf
     8e6:	mov    rsi,rbx
     8e9:	mov    rdi,r12
     8ec:	call   8f1 <botlish_fn_2+0x4e9>
			8ed: R_X86_64_PLT32	rt_int_cmp-0x4
     8f1:	mov    ecx,0x2
     8f6:	test   rax,rax
     8f9:	cmovle rcx,QWORD PTR [rip+0x12f]        # a30 <botlish_fn_2+0x628>
     901:	jmp    91d <botlish_fn_2+0x515>
     906:	mov    ecx,0x2
     90b:	mov    rsi,rbx
     90e:	cmp    rsi,0x1bf
     915:	cmovle rcx,QWORD PTR [rip+0x113]        # a30 <botlish_fn_2+0x628>
     91d:	cmp    rcx,0x6
     921:	je     991 <botlish_fn_2+0x589>
     927:	mov    rsi,rbx
     92a:	test   rsi,0x1
     931:	jne    95c <botlish_fn_2+0x554>
     937:	mov    edx,0x1df
     93c:	mov    rsi,rbx
     93f:	mov    rdi,r12
     942:	call   947 <botlish_fn_2+0x53f>
			943: R_X86_64_PLT32	rt_int_cmp-0x4
     947:	mov    ecx,0x2
     94c:	test   rax,rax
     94f:	cmovle rcx,QWORD PTR [rip+0xd9]        # a30 <botlish_fn_2+0x628>
     957:	jmp    973 <botlish_fn_2+0x56b>
     95c:	mov    ecx,0x2
     961:	mov    rsi,rbx
     964:	cmp    rsi,0x1df
     96b:	cmovle rcx,QWORD PTR [rip+0xbd]        # a30 <botlish_fn_2+0x628>
     973:	cmp    rcx,0x6
     977:	je     987 <botlish_fn_2+0x57f>
     97d:	mov    eax,0x1f
     982:	jmp    a18 <botlish_fn_2+0x610>
     987:	mov    eax,0x1d
     98c:	jmp    a18 <botlish_fn_2+0x610>
     991:	mov    eax,0x1b
     996:	jmp    a18 <botlish_fn_2+0x610>
     99b:	mov    eax,0x19
     9a0:	jmp    a18 <botlish_fn_2+0x610>
     9a5:	mov    eax,0x17
     9aa:	jmp    a18 <botlish_fn_2+0x610>
     9af:	mov    eax,0x15
     9b4:	jmp    a18 <botlish_fn_2+0x610>
     9b9:	mov    eax,0x13
     9be:	jmp    a18 <botlish_fn_2+0x610>
     9c3:	mov    eax,0x11
     9c8:	jmp    a18 <botlish_fn_2+0x610>
     9cd:	mov    eax,0xf
     9d2:	jmp    a18 <botlish_fn_2+0x610>
     9d7:	mov    eax,0xd
     9dc:	jmp    a18 <botlish_fn_2+0x610>
     9e1:	mov    eax,0xb
     9e6:	jmp    a18 <botlish_fn_2+0x610>
     9eb:	mov    eax,0x9
     9f0:	jmp    a18 <botlish_fn_2+0x610>
     9f5:	mov    eax,0x7
     9fa:	jmp    a18 <botlish_fn_2+0x610>
     9ff:	mov    eax,0x5
     a04:	jmp    a18 <botlish_fn_2+0x610>
     a09:	mov    eax,0x3
     a0e:	jmp    a18 <botlish_fn_2+0x610>
     a13:	mov    eax,0x1
     a18:	mov    rbx,QWORD PTR [rsp]
     a1c:	mov    r12,QWORD PTR [rsp+0x8]
     a21:	add    rsp,0x10
     a25:	mov    rsp,rbp
     a28:	pop    rbp
     a29:	ret
     a2a:	add    BYTE PTR [rax],al
     a2c:	add    BYTE PTR [rax],al
     a2e:	add    BYTE PTR [rax],al
     a30:	(bad)
     a31:	add    BYTE PTR [rax],al
     a33:	add    BYTE PTR [rax],al
     a35:	add    BYTE PTR [rax],al
	...

0000000000000a38 <botlish_entry_2: high_nibble<generic>>:
     a38:	push   rbp
     a39:	mov    rbp,rsp
     a3c:	mov    rsi,QWORD PTR [rdx]
     a3f:	call   a44 <botlish_entry_2+0xc>
			a40: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
     a44:	mov    rsp,rbp
     a47:	pop    rbp
     a48:	ret
     a49:	add    BYTE PTR [rax],al
     a4b:	add    BYTE PTR [rax],al
     a4d:	add    BYTE PTR [rax],al
	...

0000000000000a50 <botlish_fn_3: is_unreserved<generic>>:
     a50:	push   rbp
     a51:	mov    rbp,rsp
     a54:	sub    rsp,0x20
     a58:	mov    QWORD PTR [rsp],rbx
     a5c:	mov    QWORD PTR [rsp+0x8],r12
     a61:	mov    QWORD PTR [rsp+0x10],r13
     a66:	mov    r8d,0x1
     a6c:	test   rsi,0x1
     a73:	jne    a93 <botlish_fn_3+0x43>
     a79:	xor    r8d,r8d
     a7c:	test   rsi,0x7
     a83:	jne    a93 <botlish_fn_3+0x43>
     a89:	movzx  rax,BYTE PTR [rsi]
     a8d:	cmp    al,0x1
     a8f:	sete   r8b
     a93:	test   r8b,r8b
     a96:	jne    acc <botlish_fn_3+0x7c>
     a9c:	mov    rdx,QWORD PTR [rdi+0x10]
     aa0:	mov    rcx,QWORD PTR [rdx+0xa0]
     aa7:	xor    rbx,rbx
     aaa:	mov    rdx,rbx
     aad:	call   ab2 <botlish_fn_3+0x62>
			aae: R_X86_64_PLT32	rt_type_error-0x4
     ab2:	mov    rax,rbx
     ab5:	mov    rbx,QWORD PTR [rsp]
     ab9:	mov    r12,QWORD PTR [rsp+0x8]
     abe:	mov    r13,QWORD PTR [rsp+0x10]
     ac3:	add    rsp,0x20
     ac7:	mov    rsp,rbp
     aca:	pop    rbp
     acb:	ret
     acc:	mov    r12,rdi
     acf:	test   rsi,0x1
     ad6:	mov    rbx,rsi
     ad9:	jne    b04 <botlish_fn_3+0xb4>
     adf:	mov    edx,0x59
     ae4:	mov    rsi,rbx
     ae7:	mov    rdi,r12
     aea:	call   aef <botlish_fn_3+0x9f>
			aeb: R_X86_64_PLT32	rt_int_cmp-0x4
     aef:	mov    ecx,0x2
     af4:	test   rax,rax
     af7:	cmovle rcx,QWORD PTR [rip+0x461]        # f60 <botlish_fn_3+0x510>
     aff:	jmp    b18 <botlish_fn_3+0xc8>
     b04:	mov    ecx,0x2
     b09:	mov    rsi,rbx
     b0c:	cmp    rsi,0x59
     b10:	cmovle rcx,QWORD PTR [rip+0x448]        # f60 <botlish_fn_3+0x510>
     b18:	mov    eax,0x6
     b1d:	mov    r13,rax
     b20:	cmp    rcx,0x6
     b24:	je     f43 <botlish_fn_3+0x4f3>
     b2a:	mov    rsi,rbx
     b2d:	test   rsi,0x1
     b34:	jne    b5f <botlish_fn_3+0x10f>
     b3a:	mov    edx,0x5d
     b3f:	mov    rsi,rbx
     b42:	mov    rdi,r12
     b45:	call   b4a <botlish_fn_3+0xfa>
			b46: R_X86_64_PLT32	rt_int_cmp-0x4
     b4a:	mov    ecx,0x2
     b4f:	test   rax,rax
     b52:	cmovle rcx,QWORD PTR [rip+0x406]        # f60 <botlish_fn_3+0x510>
     b5a:	jmp    b73 <botlish_fn_3+0x123>
     b5f:	mov    ecx,0x2
     b64:	mov    rsi,rbx
     b67:	cmp    rsi,0x5d
     b6b:	cmovle rcx,QWORD PTR [rip+0x3ed]        # f60 <botlish_fn_3+0x510>
     b73:	cmp    rcx,0x6
     b77:	je     f3b <botlish_fn_3+0x4eb>
     b7d:	mov    rsi,rbx
     b80:	test   rsi,0x1
     b87:	jne    bb2 <botlish_fn_3+0x162>
     b8d:	mov    edx,0x5f
     b92:	mov    rsi,rbx
     b95:	mov    rdi,r12
     b98:	call   b9d <botlish_fn_3+0x14d>
			b99: R_X86_64_PLT32	rt_int_cmp-0x4
     b9d:	mov    ecx,0x2
     ba2:	test   rax,rax
     ba5:	cmovle rcx,QWORD PTR [rip+0x3b3]        # f60 <botlish_fn_3+0x510>
     bad:	jmp    bc6 <botlish_fn_3+0x176>
     bb2:	mov    ecx,0x2
     bb7:	mov    rsi,rbx
     bba:	cmp    rsi,0x5f
     bbe:	cmovle rcx,QWORD PTR [rip+0x39a]        # f60 <botlish_fn_3+0x510>
     bc6:	cmp    rcx,0x6
     bca:	je     f31 <botlish_fn_3+0x4e1>
     bd0:	mov    rsi,rbx
     bd3:	test   rsi,0x1
     bda:	jne    c05 <botlish_fn_3+0x1b5>
     be0:	mov    edx,0x73
     be5:	mov    rsi,rbx
     be8:	mov    rdi,r12
     beb:	call   bf0 <botlish_fn_3+0x1a0>
			bec: R_X86_64_PLT32	rt_int_cmp-0x4
     bf0:	mov    ecx,0x2
     bf5:	test   rax,rax
     bf8:	cmovle rcx,QWORD PTR [rip+0x360]        # f60 <botlish_fn_3+0x510>
     c00:	jmp    c19 <botlish_fn_3+0x1c9>
     c05:	mov    ecx,0x2
     c0a:	mov    rsi,rbx
     c0d:	cmp    rsi,0x73
     c11:	cmovle rcx,QWORD PTR [rip+0x347]        # f60 <botlish_fn_3+0x510>
     c19:	cmp    rcx,0x6
     c1d:	je     f29 <botlish_fn_3+0x4d9>
     c23:	mov    rsi,rbx
     c26:	test   rsi,0x1
     c2d:	jne    c58 <botlish_fn_3+0x208>
     c33:	mov    edx,0x81
     c38:	mov    rsi,rbx
     c3b:	mov    rdi,r12
     c3e:	call   c43 <botlish_fn_3+0x1f3>
			c3f: R_X86_64_PLT32	rt_int_cmp-0x4
     c43:	mov    ecx,0x2
     c48:	test   rax,rax
     c4b:	cmovle rcx,QWORD PTR [rip+0x30d]        # f60 <botlish_fn_3+0x510>
     c53:	jmp    c6f <botlish_fn_3+0x21f>
     c58:	mov    ecx,0x2
     c5d:	mov    rsi,rbx
     c60:	cmp    rsi,0x81
     c67:	cmovle rcx,QWORD PTR [rip+0x2f1]        # f60 <botlish_fn_3+0x510>
     c6f:	cmp    rcx,0x6
     c73:	je     f1f <botlish_fn_3+0x4cf>
     c79:	mov    rsi,rbx
     c7c:	test   rsi,0x1
     c83:	jne    cae <botlish_fn_3+0x25e>
     c89:	mov    edx,0xb5
     c8e:	mov    rsi,rbx
     c91:	mov    rdi,r12
     c94:	call   c99 <botlish_fn_3+0x249>
			c95: R_X86_64_PLT32	rt_int_cmp-0x4
     c99:	mov    ecx,0x2
     c9e:	test   rax,rax
     ca1:	cmovle rcx,QWORD PTR [rip+0x2b7]        # f60 <botlish_fn_3+0x510>
     ca9:	jmp    cc5 <botlish_fn_3+0x275>
     cae:	mov    ecx,0x2
     cb3:	mov    rsi,rbx
     cb6:	cmp    rsi,0xb5
     cbd:	cmovle rcx,QWORD PTR [rip+0x29b]        # f60 <botlish_fn_3+0x510>
     cc5:	cmp    rcx,0x6
     cc9:	je     f17 <botlish_fn_3+0x4c7>
     ccf:	mov    rsi,rbx
     cd2:	test   rsi,0x1
     cd9:	jne    d04 <botlish_fn_3+0x2b4>
     cdf:	mov    edx,0xbd
     ce4:	mov    rsi,rbx
     ce7:	mov    rdi,r12
     cea:	call   cef <botlish_fn_3+0x29f>
			ceb: R_X86_64_PLT32	rt_int_cmp-0x4
     cef:	mov    ecx,0x2
     cf4:	test   rax,rax
     cf7:	cmovle rcx,QWORD PTR [rip+0x261]        # f60 <botlish_fn_3+0x510>
     cff:	jmp    d1b <botlish_fn_3+0x2cb>
     d04:	mov    ecx,0x2
     d09:	mov    rsi,rbx
     d0c:	cmp    rsi,0xbd
     d13:	cmovle rcx,QWORD PTR [rip+0x245]        # f60 <botlish_fn_3+0x510>
     d1b:	cmp    rcx,0x6
     d1f:	je     f0d <botlish_fn_3+0x4bd>
     d25:	mov    rsi,rbx
     d28:	test   rsi,0x1
     d2f:	jne    d5b <botlish_fn_3+0x30b>
     d35:	mov    edx,0xbf
     d3a:	mov    rsi,rbx
     d3d:	mov    rdi,r12
     d40:	call   d45 <botlish_fn_3+0x2f5>
			d41: R_X86_64_PLT32	rt_int_cmp-0x4
     d45:	mov    r11d,0x2
     d4b:	test   rax,rax
     d4e:	cmovle r11,QWORD PTR [rip+0x20a]        # f60 <botlish_fn_3+0x510>
     d56:	jmp    d73 <botlish_fn_3+0x323>
     d5b:	mov    r11d,0x2
     d61:	mov    rsi,rbx
     d64:	cmp    rsi,0xbf
     d6b:	cmovle r11,QWORD PTR [rip+0x1ed]        # f60 <botlish_fn_3+0x510>
     d73:	cmp    r11,0x6
     d77:	je     f05 <botlish_fn_3+0x4b5>
     d7d:	mov    rsi,rbx
     d80:	test   rsi,0x1
     d87:	jne    db2 <botlish_fn_3+0x362>
     d8d:	mov    edx,0xc1
     d92:	mov    rsi,rbx
     d95:	mov    rdi,r12
     d98:	call   d9d <botlish_fn_3+0x34d>
			d99: R_X86_64_PLT32	rt_int_cmp-0x4
     d9d:	mov    ecx,0x2
     da2:	test   rax,rax
     da5:	cmovle rcx,QWORD PTR [rip+0x1b3]        # f60 <botlish_fn_3+0x510>
     dad:	jmp    dc9 <botlish_fn_3+0x379>
     db2:	mov    ecx,0x2
     db7:	mov    rsi,rbx
     dba:	cmp    rsi,0xc1
     dc1:	cmovle rcx,QWORD PTR [rip+0x197]        # f60 <botlish_fn_3+0x510>
     dc9:	cmp    rcx,0x6
     dcd:	je     efb <botlish_fn_3+0x4ab>
     dd3:	mov    rsi,rbx
     dd6:	test   rsi,0x1
     ddd:	jne    e08 <botlish_fn_3+0x3b8>
     de3:	mov    edx,0xf5
     de8:	mov    rsi,rbx
     deb:	mov    rdi,r12
     dee:	call   df3 <botlish_fn_3+0x3a3>
			def: R_X86_64_PLT32	rt_int_cmp-0x4
     df3:	mov    ecx,0x2
     df8:	test   rax,rax
     dfb:	cmovle rcx,QWORD PTR [rip+0x15d]        # f60 <botlish_fn_3+0x510>
     e03:	jmp    e1f <botlish_fn_3+0x3cf>
     e08:	mov    ecx,0x2
     e0d:	mov    rsi,rbx
     e10:	cmp    rsi,0xf5
     e17:	cmovle rcx,QWORD PTR [rip+0x141]        # f60 <botlish_fn_3+0x510>
     e1f:	cmp    rcx,0x6
     e23:	je     ef3 <botlish_fn_3+0x4a3>
     e29:	mov    rsi,rbx
     e2c:	test   rsi,0x1
     e33:	jne    e5e <botlish_fn_3+0x40e>
     e39:	mov    edx,0xfb
     e3e:	mov    rsi,rbx
     e41:	mov    rdi,r12
     e44:	call   e49 <botlish_fn_3+0x3f9>
			e45: R_X86_64_PLT32	rt_int_cmp-0x4
     e49:	mov    ecx,0x2
     e4e:	test   rax,rax
     e51:	cmovle rcx,QWORD PTR [rip+0x107]        # f60 <botlish_fn_3+0x510>
     e59:	jmp    e75 <botlish_fn_3+0x425>
     e5e:	mov    ecx,0x2
     e63:	mov    rsi,rbx
     e66:	cmp    rsi,0xfb
     e6d:	cmovle rcx,QWORD PTR [rip+0xeb]        # f60 <botlish_fn_3+0x510>
     e75:	cmp    rcx,0x6
     e79:	je     ee9 <botlish_fn_3+0x499>
     e7f:	mov    rsi,rbx
     e82:	test   rsi,0x1
     e89:	jne    eb5 <botlish_fn_3+0x465>
     e8f:	mov    edx,0xfd
     e94:	mov    rsi,rbx
     e97:	mov    rdi,r12
     e9a:	call   e9f <botlish_fn_3+0x44f>
			e9b: R_X86_64_PLT32	rt_int_cmp-0x4
     e9f:	mov    r8d,0x2
     ea5:	test   rax,rax
     ea8:	cmovle r8,QWORD PTR [rip+0xb0]        # f60 <botlish_fn_3+0x510>
     eb0:	jmp    ecd <botlish_fn_3+0x47d>
     eb5:	mov    r8d,0x2
     ebb:	mov    rsi,rbx
     ebe:	cmp    rsi,0xfd
     ec5:	cmovle r8,QWORD PTR [rip+0x93]        # f60 <botlish_fn_3+0x510>
     ecd:	cmp    r8,0x6
     ed1:	je     ee1 <botlish_fn_3+0x491>
     ed7:	mov    eax,0x2
     edc:	jmp    f48 <botlish_fn_3+0x4f8>
     ee1:	mov    rax,r13
     ee4:	jmp    f48 <botlish_fn_3+0x4f8>
     ee9:	mov    eax,0x2
     eee:	jmp    f48 <botlish_fn_3+0x4f8>
     ef3:	mov    rax,r13
     ef6:	jmp    f48 <botlish_fn_3+0x4f8>
     efb:	mov    eax,0x2
     f00:	jmp    f48 <botlish_fn_3+0x4f8>
     f05:	mov    rax,r13
     f08:	jmp    f48 <botlish_fn_3+0x4f8>
     f0d:	mov    eax,0x2
     f12:	jmp    f48 <botlish_fn_3+0x4f8>
     f17:	mov    rax,r13
     f1a:	jmp    f48 <botlish_fn_3+0x4f8>
     f1f:	mov    eax,0x2
     f24:	jmp    f48 <botlish_fn_3+0x4f8>
     f29:	mov    rax,r13
     f2c:	jmp    f48 <botlish_fn_3+0x4f8>
     f31:	mov    eax,0x2
     f36:	jmp    f48 <botlish_fn_3+0x4f8>
     f3b:	mov    rax,r13
     f3e:	jmp    f48 <botlish_fn_3+0x4f8>
     f43:	mov    eax,0x2
     f48:	mov    rbx,QWORD PTR [rsp]
     f4c:	mov    r12,QWORD PTR [rsp+0x8]
     f51:	mov    r13,QWORD PTR [rsp+0x10]
     f56:	add    rsp,0x20
     f5a:	mov    rsp,rbp
     f5d:	pop    rbp
     f5e:	ret
     f5f:	add    BYTE PTR [rsi],al
     f61:	add    BYTE PTR [rax],al
     f63:	add    BYTE PTR [rax],al
     f65:	add    BYTE PTR [rax],al
	...

0000000000000f68 <botlish_entry_3: is_unreserved<generic>>:
     f68:	push   rbp
     f69:	mov    rbp,rsp
     f6c:	mov    rsi,QWORD PTR [rdx]
     f6f:	call   f74 <botlish_entry_3+0xc>
			f70: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
     f74:	mov    rsp,rbp
     f77:	pop    rbp
     f78:	ret

0000000000000f79 <botlish_fn_4: hex_pair<generic>>:
     f79:	push   rbp
     f7a:	mov    rbp,rsp
     f7d:	sub    rsp,0x30
     f81:	mov    QWORD PTR [rsp+0x10],rbx
     f86:	mov    QWORD PTR [rsp+0x18],r12
     f8b:	mov    QWORD PTR [rsp+0x20],r13
     f90:	mov    QWORD PTR [rsp+0x28],r14
     f95:	mov    rbx,rdx
     f98:	mov    r12,rdi
     f9b:	mov    r13,rsi
     f9e:	mov    rsi,r13
     fa1:	mov    rdi,r12
     fa4:	call   fa9 <botlish_fn_4+0x30>
			fa5: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
     fa9:	test   rax,rax
     fac:	je     10da <botlish_fn_4+0x161>
     fb2:	test   rax,0x1
     fb8:	jne    fc6 <botlish_fn_4+0x4d>
     fbe:	mov    rdx,rax
     fc1:	jmp    fdc <botlish_fn_4+0x63>
     fc6:	mov    rdx,QWORD PTR [rbx+0x8]
     fca:	mov    rcx,rax
     fcd:	sar    rcx,1
     fd0:	cmp    rcx,rdx
     fd3:	jb     ff8 <botlish_fn_4+0x7f>
     fd9:	mov    rdx,rax
     fdc:	mov    rsi,rbx
     fdf:	mov    rdi,r12
     fe2:	call   fe7 <botlish_fn_4+0x6e>
			fe3: R_X86_64_PLT32	rt_list_get-0x4
     fe7:	test   rax,rax
     fea:	je     10da <botlish_fn_4+0x161>
     ff0:	mov    rsi,rax
     ff3:	jmp    1000 <botlish_fn_4+0x87>
     ff8:	mov    rax,QWORD PTR [rbx+0x10]
     ffc:	mov    rsi,QWORD PTR [rax+rcx*8]
    1000:	mov    QWORD PTR [rsp],rsi
    1004:	mov    r14,rsi
    1007:	mov    ecx,0x1
    100c:	mov    rsi,r13
    100f:	test   rsi,0x1
    1016:	jne    1034 <botlish_fn_4+0xbb>
    101c:	xor    ecx,ecx
    101e:	test   rsi,0x7
    1025:	jne    1034 <botlish_fn_4+0xbb>
    102b:	movzx  rax,BYTE PTR [rsi]
    102f:	cmp    al,0x1
    1031:	sete   cl
    1034:	test   cl,cl
    1036:	jne    1057 <botlish_fn_4+0xde>
    103c:	mov    rdi,r12
    103f:	mov    rax,QWORD PTR [rdi+0x10]
    1043:	mov    rcx,QWORD PTR [rax+0xa8]
    104a:	xor    rdx,rdx
    104d:	call   1052 <botlish_fn_4+0xd9>
			104e: R_X86_64_PLT32	rt_type_error-0x4
    1052:	jmp    10da <botlish_fn_4+0x161>
    1057:	mov    edx,0x21
    105c:	mov    rdi,r12
    105f:	call   1064 <botlish_fn_4+0xeb>
			1060: R_X86_64_PLT32	rt_int_mod-0x4
    1064:	test   rax,rax
    1067:	je     10da <botlish_fn_4+0x161>
    106d:	test   rax,0x1
    1073:	jne    1084 <botlish_fn_4+0x10b>
    1079:	mov    rdx,rax
    107c:	mov    rsi,rbx
    107f:	jmp    109d <botlish_fn_4+0x124>
    1084:	mov    rdi,QWORD PTR [rbx+0x8]
    1088:	mov    rsi,rax
    108b:	sar    rsi,1
    108e:	mov    rdx,rax
    1091:	cmp    rsi,rdi
    1094:	jb     10b6 <botlish_fn_4+0x13d>
    109a:	mov    rsi,rbx
    109d:	mov    rdi,r12
    10a0:	call   10a5 <botlish_fn_4+0x12c>
			10a1: R_X86_64_PLT32	rt_list_get-0x4
    10a5:	test   rax,rax
    10a8:	je     10da <botlish_fn_4+0x161>
    10ae:	mov    rdx,rax
    10b1:	jmp    10c1 <botlish_fn_4+0x148>
    10b6:	mov    rax,rbx
    10b9:	mov    r10,QWORD PTR [rax+0x10]
    10bd:	mov    rdx,QWORD PTR [r10+rsi*8]
    10c1:	mov    QWORD PTR [rsp+0x8],rdx
    10c6:	mov    rsi,r14
    10c9:	mov    rdi,r12
    10cc:	call   10d1 <botlish_fn_4+0x158>
			10cd: R_X86_64_PLT32	rt_str_cat-0x4
    10d1:	test   rax,rax
    10d4:	jne    10fa <botlish_fn_4+0x181>
    10da:	xor    rax,rax
    10dd:	mov    rbx,QWORD PTR [rsp+0x10]
    10e2:	mov    r12,QWORD PTR [rsp+0x18]
    10e7:	mov    r13,QWORD PTR [rsp+0x20]
    10ec:	mov    r14,QWORD PTR [rsp+0x28]
    10f1:	add    rsp,0x30
    10f5:	mov    rsp,rbp
    10f8:	pop    rbp
    10f9:	ret
    10fa:	mov    rbx,QWORD PTR [rsp+0x10]
    10ff:	mov    r12,QWORD PTR [rsp+0x18]
    1104:	mov    r13,QWORD PTR [rsp+0x20]
    1109:	mov    r14,QWORD PTR [rsp+0x28]
    110e:	add    rsp,0x30
    1112:	mov    rsp,rbp
    1115:	pop    rbp
    1116:	ret

0000000000001117 <botlish_entry_4: hex_pair<generic>>:
    1117:	push   rbp
    1118:	mov    rbp,rsp
    111b:	mov    rsi,QWORD PTR [rdx]
    111e:	mov    rdx,QWORD PTR [rdx+0x8]
    1122:	call   1127 <botlish_entry_4+0x10>
			1123: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    1127:	mov    rsp,rbp
    112a:	pop    rbp
    112b:	ret
    112c:	add    BYTE PTR [rax],al
	...

0000000000001130 <botlish_fn_5: esc_bytes<generic>>:
    1130:	push   rbp
    1131:	mov    rbp,rsp
    1134:	sub    rsp,0x70
    1138:	mov    QWORD PTR [rsp+0x40],rbx
    113d:	mov    QWORD PTR [rsp+0x48],r12
    1142:	mov    QWORD PTR [rsp+0x50],r13
    1147:	mov    QWORD PTR [rsp+0x58],r14
    114c:	mov    QWORD PTR [rsp+0x60],r15
    1151:	mov    r13,rdi
    1154:	mov    QWORD PTR [rsp+0x28],0x0
    115d:	mov    QWORD PTR [rsp],rsi
    1161:	mov    QWORD PTR [rsp+0x8],rdx
    1166:	mov    QWORD PTR [rsp+0x10],rcx
    116b:	mov    QWORD PTR [rsp+0x18],r8
    1170:	mov    r12,r8
    1173:	mov    r14,rcx
    1176:	mov    r15,rdx
    1179:	xor    eax,eax
    117b:	test   rsi,0x7
    1182:	jne    1193 <botlish_fn_5+0x63>
    1188:	movzx  r8,BYTE PTR [rsi]
    118c:	cmp    r8b,0x3
    1190:	sete   al
    1193:	test   al,al
    1195:	jne    11b8 <botlish_fn_5+0x88>
    119b:	mov    rdi,r13
    119e:	mov    rax,QWORD PTR [rdi+0x10]
    11a2:	mov    rcx,QWORD PTR [rax+0xb0]
    11a9:	mov    edx,0x4
    11ae:	call   11b3 <botlish_fn_5+0x83>
			11af: R_X86_64_PLT32	rt_type_error-0x4
    11b3:	jmp    13be <botlish_fn_5+0x28e>
    11b8:	mov    rbx,rsi
    11bb:	mov    rdi,r13
    11be:	call   11c3 <botlish_fn_5+0x93>
			11bf: R_X86_64_PLT32	rt_list_len-0x4
    11c3:	mov    ecx,0x1
    11c8:	mov    rsi,r15
    11cb:	test   rsi,0x1
    11d2:	jne    11f8 <botlish_fn_5+0xc8>
    11d8:	xor    ecx,ecx
    11da:	mov    rsi,r15
    11dd:	test   rsi,0x7
    11e4:	jne    11f8 <botlish_fn_5+0xc8>
    11ea:	mov    rsi,r15
    11ed:	movzx  rcx,BYTE PTR [rsi]
    11f1:	rex cmp cl,0x1
    11f5:	sete   cl
    11f8:	test   cl,cl
    11fa:	jne    121e <botlish_fn_5+0xee>
    1200:	mov    rdi,r13
    1203:	mov    rax,QWORD PTR [rdi+0x10]
    1207:	mov    rcx,QWORD PTR [rax+0xb8]
    120e:	xor    rdx,rdx
    1211:	mov    rsi,r15
    1214:	call   1219 <botlish_fn_5+0xe9>
			1215: R_X86_64_PLT32	rt_type_error-0x4
    1219:	jmp    13be <botlish_fn_5+0x28e>
    121e:	mov    rsi,r15
    1221:	mov    rcx,rsi
    1224:	and    rcx,rax
    1227:	mov    rdx,rax
    122a:	test   rcx,0x1
    1231:	jne    1257 <botlish_fn_5+0x127>
    1237:	mov    rsi,r15
    123a:	mov    rdi,r13
    123d:	call   1242 <botlish_fn_5+0x112>
			123e: R_X86_64_PLT32	rt_int_cmp-0x4
    1242:	mov    ecx,0x2
    1247:	test   rax,rax
    124a:	cmovge rcx,QWORD PTR [rip+0x1de]        # 1430 <botlish_fn_5+0x300>
    1252:	jmp    126a <botlish_fn_5+0x13a>
    1257:	mov    ecx,0x2
    125c:	mov    rsi,r15
    125f:	cmp    rsi,rdx
    1262:	cmovge rcx,QWORD PTR [rip+0x1c6]        # 1430 <botlish_fn_5+0x300>
    126a:	cmp    rcx,0x6
    126e:	je     1409 <botlish_fn_5+0x2d9>
    1274:	mov    QWORD PTR [rsp+0x20],0x3
    127d:	mov    rsi,r15
    1280:	test   rsi,0x1
    1287:	je     12a2 <botlish_fn_5+0x172>
    128d:	mov    rsi,r15
    1290:	mov    rax,rsi
    1293:	add    rax,0x2
    1297:	seto   cl
    129a:	test   cl,cl
    129c:	je     12b2 <botlish_fn_5+0x182>
    12a2:	mov    edx,0x3
    12a7:	mov    rsi,r15
    12aa:	mov    rdi,r13
    12ad:	call   12b2 <botlish_fn_5+0x182>
			12ae: R_X86_64_PLT32	rt_int_add-0x4
    12b2:	mov    QWORD PTR [rsp+0x8],rax
    12b7:	mov    rdi,r13
    12ba:	mov    QWORD PTR [rsp+0x30],rax
    12bf:	mov    rax,QWORD PTR [rdi+0x10]
    12c3:	mov    rsi,QWORD PTR [rax+0xc0]
    12ca:	mov    QWORD PTR [rsp+0x20],rsi
    12cf:	mov    QWORD PTR [rsp+0x38],rsi
    12d4:	mov    rsi,r15
    12d7:	test   rsi,0x1
    12de:	jne    12ec <botlish_fn_5+0x1bc>
    12e4:	mov    rdx,r15
    12e7:	jmp    1305 <botlish_fn_5+0x1d5>
    12ec:	mov    rcx,QWORD PTR [rbx+0x8]
    12f0:	mov    rsi,r15
    12f3:	mov    rax,rsi
    12f6:	sar    rax,1
    12f9:	cmp    rax,rcx
    12fc:	jb     1321 <botlish_fn_5+0x1f1>
    1302:	mov    rdx,r15
    1305:	mov    rsi,rbx
    1308:	mov    rdi,r13
    130b:	call   1310 <botlish_fn_5+0x1e0>
			130c: R_X86_64_PLT32	rt_list_get-0x4
    1310:	test   rax,rax
    1313:	je     13be <botlish_fn_5+0x28e>
    1319:	mov    rsi,rax
    131c:	jmp    1329 <botlish_fn_5+0x1f9>
    1321:	mov    rcx,QWORD PTR [rbx+0x10]
    1325:	mov    rsi,QWORD PTR [rcx+rax*8]
    1329:	mov    QWORD PTR [rsp+0x28],rsi
    132e:	mov    rdx,r12
    1331:	mov    rdi,r13
    1334:	call   1339 <botlish_fn_5+0x209>
			1335: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    1339:	test   rax,rax
    133c:	je     13be <botlish_fn_5+0x28e>
    1342:	mov    QWORD PTR [rsp+0x28],rax
    1347:	mov    rdx,rax
    134a:	mov    rsi,QWORD PTR [rsp+0x38]
    134f:	mov    rdi,r13
    1352:	call   1357 <botlish_fn_5+0x227>
			1353: R_X86_64_PLT32	rt_str_cat-0x4
    1357:	test   rax,rax
    135a:	je     13be <botlish_fn_5+0x28e>
    1360:	mov    QWORD PTR [rsp+0x20],rax
    1365:	mov    rdx,rax
    1368:	xor    eax,eax
    136a:	mov    rsi,r14
    136d:	test   rsi,0x7
    1374:	jne    1385 <botlish_fn_5+0x255>
    137a:	movzx  rdi,BYTE PTR [rsi]
    137e:	cmp    dil,0x2
    1382:	sete   al
    1385:	test   al,al
    1387:	jne    13ad <botlish_fn_5+0x27d>
    138d:	mov    rdi,r13
    1390:	mov    rdi,QWORD PTR [rdi+0x10]
    1394:	mov    rcx,QWORD PTR [rdi+0xc8]
    139b:	mov    edx,0x1
    13a0:	mov    rdi,r13
    13a3:	call   13a8 <botlish_fn_5+0x278>
			13a4: R_X86_64_PLT32	rt_type_error-0x4
    13a8:	jmp    13be <botlish_fn_5+0x28e>
    13ad:	mov    rdi,r13
    13b0:	call   13b5 <botlish_fn_5+0x285>
			13b1: R_X86_64_PLT32	rt_str_cat-0x4
    13b5:	test   rax,rax
    13b8:	jne    13e3 <botlish_fn_5+0x2b3>
    13be:	xor    rax,rax
    13c1:	mov    rbx,QWORD PTR [rsp+0x40]
    13c6:	mov    r12,QWORD PTR [rsp+0x48]
    13cb:	mov    r13,QWORD PTR [rsp+0x50]
    13d0:	mov    r14,QWORD PTR [rsp+0x58]
    13d5:	mov    r15,QWORD PTR [rsp+0x60]
    13da:	add    rsp,0x70
    13de:	mov    rsp,rbp
    13e1:	pop    rbp
    13e2:	ret
    13e3:	mov    QWORD PTR [rsp],rbx
    13e7:	mov    rcx,QWORD PTR [rsp+0x30]
    13ec:	mov    QWORD PTR [rsp+0x8],rcx
    13f1:	mov    QWORD PTR [rsp+0x10],rax
    13f6:	mov    QWORD PTR [rsp+0x18],r12
    13fb:	mov    rsi,rbx
    13fe:	mov    r14,rax
    1401:	mov    r15,rcx
    1404:	jmp    1179 <botlish_fn_5+0x49>
    1409:	mov    rax,r14
    140c:	mov    rbx,QWORD PTR [rsp+0x40]
    1411:	mov    r12,QWORD PTR [rsp+0x48]
    1416:	mov    r13,QWORD PTR [rsp+0x50]
    141b:	mov    r14,QWORD PTR [rsp+0x58]
    1420:	mov    r15,QWORD PTR [rsp+0x60]
    1425:	add    rsp,0x70
    1429:	mov    rsp,rbp
    142c:	pop    rbp
    142d:	ret
    142e:	add    BYTE PTR [rax],al
    1430:	(bad)
    1431:	add    BYTE PTR [rax],al
    1433:	add    BYTE PTR [rax],al
    1435:	add    BYTE PTR [rax],al
	...

0000000000001438 <botlish_entry_5: esc_bytes<generic>>:
    1438:	push   rbp
    1439:	mov    rbp,rsp
    143c:	mov    rsi,QWORD PTR [rdx]
    143f:	mov    r9,QWORD PTR [rdx+0x8]
    1443:	mov    rcx,QWORD PTR [rdx+0x10]
    1447:	mov    r8,QWORD PTR [rdx+0x18]
    144b:	mov    rdx,r9
    144e:	call   1453 <botlish_entry_5+0x1b>
			144f: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    1453:	mov    rsp,rbp
    1456:	pop    rbp
    1457:	ret

0000000000001458 <botlish_fn_6: esc_char<generic>>:
    1458:	push   rbp
    1459:	mov    rbp,rsp
    145c:	sub    rsp,0x50
    1460:	mov    QWORD PTR [rsp+0x20],rbx
    1465:	mov    QWORD PTR [rsp+0x28],r12
    146a:	mov    QWORD PTR [rsp+0x30],r13
    146f:	mov    QWORD PTR [rsp+0x38],r14
    1474:	mov    QWORD PTR [rsp+0x40],r15
    1479:	mov    QWORD PTR [rsp+0x10],0x0
    1482:	mov    QWORD PTR [rsp+0x18],0x0
    148b:	mov    QWORD PTR [rsp],rsi
    148f:	mov    QWORD PTR [rsp+0x8],rdx
    1494:	mov    rbx,rdx
    1497:	xor    r9d,r9d
    149a:	test   rsi,0x7
    14a1:	jne    14b1 <botlish_fn_6+0x59>
    14a7:	movzx  rax,BYTE PTR [rsi]
    14ab:	cmp    al,0x2
    14ad:	sete   r9b
    14b1:	test   r9b,r9b
    14b4:	jne    14d4 <botlish_fn_6+0x7c>
    14ba:	mov    rax,QWORD PTR [rdi+0x10]
    14be:	mov    rcx,QWORD PTR [rax+0xd0]
    14c5:	mov    edx,0x1
    14ca:	call   14cf <botlish_fn_6+0x77>
			14cb: R_X86_64_PLT32	rt_type_error-0x4
    14cf:	jmp    15d4 <botlish_fn_6+0x17c>
    14d4:	mov    r12,rdi
    14d7:	mov    r15,rsi
    14da:	call   14df <botlish_fn_6+0x87>
			14db: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    14df:	mov    rcx,rax
    14e2:	mov    r13,rax
    14e5:	test   rax,rcx
    14e8:	je     15d4 <botlish_fn_6+0x17c>
    14ee:	mov    rax,r13
    14f1:	mov    QWORD PTR [rsp],rax
    14f5:	mov    rsi,r13
    14f8:	mov    rdi,r12
    14fb:	call   1500 <botlish_fn_6+0xa8>
			14fc: R_X86_64_PLT32	rt_list_len-0x4
    1500:	mov    edx,0x1
    1505:	sar    rax,1
    1508:	cmp    rax,0x1
    150c:	je     1547 <botlish_fn_6+0xef>
    1512:	mov    QWORD PTR [rsp+0x10],0x1
    151b:	mov    rdi,r12
    151e:	mov    rax,QWORD PTR [rdi+0x10]
    1522:	mov    rcx,QWORD PTR [rax+0x98]
    1529:	mov    QWORD PTR [rsp+0x18],rcx
    152e:	mov    rsi,r13
    1531:	mov    r8,rbx
    1534:	call   1539 <botlish_fn_6+0xe1>
			1535: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    1539:	test   rax,rax
    153c:	je     15d4 <botlish_fn_6+0x17c>
    1542:	jmp    15ff <botlish_fn_6+0x1a7>
    1547:	mov    rsi,r13
    154a:	mov    r14,rdx
    154d:	mov    rax,QWORD PTR [rsi+0x8]
    1551:	mov    r13,rsi
    1554:	test   rax,rax
    1557:	jne    157c <botlish_fn_6+0x124>
    155d:	mov    rdx,r14
    1560:	mov    rsi,r13
    1563:	mov    rdi,r12
    1566:	call   156b <botlish_fn_6+0x113>
			1567: R_X86_64_PLT32	rt_list_get-0x4
    156b:	test   rax,rax
    156e:	je     15d4 <botlish_fn_6+0x17c>
    1574:	mov    rsi,rax
    1577:	jmp    1586 <botlish_fn_6+0x12e>
    157c:	mov    rsi,r13
    157f:	mov    rcx,QWORD PTR [rsi+0x10]
    1583:	mov    rsi,QWORD PTR [rcx]
    1586:	mov    rdi,r12
    1589:	call   158e <botlish_fn_6+0x136>
			158a: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    158e:	test   rax,rax
    1591:	je     15d4 <botlish_fn_6+0x17c>
    1597:	cmp    rax,0x6
    159b:	je     15fc <botlish_fn_6+0x1a4>
    15a1:	mov    QWORD PTR [rsp+0x10],0x1
    15aa:	mov    rdi,r12
    15ad:	mov    r8,QWORD PTR [rdi+0x10]
    15b1:	mov    rcx,QWORD PTR [r8+0x98]
    15b8:	mov    QWORD PTR [rsp+0x18],rcx
    15bd:	mov    rdx,r14
    15c0:	mov    rsi,r13
    15c3:	mov    r8,rbx
    15c6:	call   15cb <botlish_fn_6+0x173>
			15c7: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    15cb:	test   rax,rax
    15ce:	jne    15f9 <botlish_fn_6+0x1a1>
    15d4:	xor    rax,rax
    15d7:	mov    rbx,QWORD PTR [rsp+0x20]
    15dc:	mov    r12,QWORD PTR [rsp+0x28]
    15e1:	mov    r13,QWORD PTR [rsp+0x30]
    15e6:	mov    r14,QWORD PTR [rsp+0x38]
    15eb:	mov    r15,QWORD PTR [rsp+0x40]
    15f0:	add    rsp,0x50
    15f4:	mov    rsp,rbp
    15f7:	pop    rbp
    15f8:	ret
    15f9:	mov    r15,rax
    15fc:	mov    rax,r15
    15ff:	mov    rbx,QWORD PTR [rsp+0x20]
    1604:	mov    r12,QWORD PTR [rsp+0x28]
    1609:	mov    r13,QWORD PTR [rsp+0x30]
    160e:	mov    r14,QWORD PTR [rsp+0x38]
    1613:	mov    r15,QWORD PTR [rsp+0x40]
    1618:	add    rsp,0x50
    161c:	mov    rsp,rbp
    161f:	pop    rbp
    1620:	ret

0000000000001621 <botlish_entry_6: esc_char<generic>>:
    1621:	push   rbp
    1622:	mov    rbp,rsp
    1625:	mov    rsi,QWORD PTR [rdx]
    1628:	mov    rdx,QWORD PTR [rdx+0x8]
    162c:	call   1631 <botlish_entry_6+0x10>
			162d: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    1631:	mov    rsp,rbp
    1634:	pop    rbp
    1635:	ret
	...

0000000000001638 <botlish_fn_7: esc_from<generic>>:
    1638:	push   rbp
    1639:	mov    rbp,rsp
    163c:	sub    rsp,0x70
    1640:	mov    QWORD PTR [rsp+0x40],rbx
    1645:	mov    QWORD PTR [rsp+0x48],r12
    164a:	mov    QWORD PTR [rsp+0x50],r13
    164f:	mov    QWORD PTR [rsp+0x58],r14
    1654:	mov    QWORD PTR [rsp+0x60],r15
    1659:	mov    r13,rdi
    165c:	mov    QWORD PTR [rsp+0x28],0x0
    1665:	mov    QWORD PTR [rsp],rsi
    1669:	mov    QWORD PTR [rsp+0x8],rdx
    166e:	mov    QWORD PTR [rsp+0x10],rcx
    1673:	mov    QWORD PTR [rsp+0x18],r8
    1678:	mov    r12,r8
    167b:	mov    r14,rcx
    167e:	mov    QWORD PTR [rsp+0x30],rdx
    1683:	xor    eax,eax
    1685:	test   rsi,0x7
    168c:	jne    169b <botlish_fn_7+0x63>
    1692:	movzx  rax,BYTE PTR [rsi]
    1696:	cmp    al,0x2
    1698:	sete   al
    169b:	test   al,al
    169d:	jne    16c0 <botlish_fn_7+0x88>
    16a3:	mov    rdi,r13
    16a6:	mov    rax,QWORD PTR [rdi+0x10]
    16aa:	mov    rcx,QWORD PTR [rax+0xd8]
    16b1:	mov    edx,0x1
    16b6:	call   16bb <botlish_fn_7+0x83>
			16b7: R_X86_64_PLT32	rt_type_error-0x4
    16bb:	jmp    1904 <botlish_fn_7+0x2cc>
    16c0:	mov    rbx,rsi
    16c3:	mov    rdi,r13
    16c6:	call   16cb <botlish_fn_7+0x93>
			16c7: R_X86_64_PLT32	rt_str_len-0x4
    16cb:	mov    edx,0x1
    16d0:	mov    r15,rdx
    16d3:	mov    ecx,0x1
    16d8:	mov    rsi,QWORD PTR [rsp+0x30]
    16dd:	test   rsi,0x1
    16e4:	jne    170e <botlish_fn_7+0xd6>
    16ea:	xor    ecx,ecx
    16ec:	mov    rsi,QWORD PTR [rsp+0x30]
    16f1:	test   rsi,0x7
    16f8:	jne    170e <botlish_fn_7+0xd6>
    16fe:	mov    rsi,QWORD PTR [rsp+0x30]
    1703:	movzx  rcx,BYTE PTR [rsi]
    1707:	rex cmp cl,0x1
    170b:	sete   cl
    170e:	test   cl,cl
    1710:	jne    1736 <botlish_fn_7+0xfe>
    1716:	mov    rdi,r13
    1719:	mov    rax,QWORD PTR [rdi+0x10]
    171d:	mov    rcx,QWORD PTR [rax+0xb8]
    1724:	xor    rdx,rdx
    1727:	mov    rsi,QWORD PTR [rsp+0x30]
    172c:	call   1731 <botlish_fn_7+0xf9>
			172d: R_X86_64_PLT32	rt_type_error-0x4
    1731:	jmp    1904 <botlish_fn_7+0x2cc>
    1736:	mov    rsi,QWORD PTR [rsp+0x30]
    173b:	mov    rcx,rsi
    173e:	and    rcx,rax
    1741:	mov    rdx,rax
    1744:	test   rcx,0x1
    174b:	jne    1773 <botlish_fn_7+0x13b>
    1751:	mov    rsi,QWORD PTR [rsp+0x30]
    1756:	mov    rdi,r13
    1759:	call   175e <botlish_fn_7+0x126>
			175a: R_X86_64_PLT32	rt_int_cmp-0x4
    175e:	mov    ecx,0x2
    1763:	test   rax,rax
    1766:	cmovge rcx,QWORD PTR [rip+0x20a]        # 1978 <botlish_fn_7+0x340>
    176e:	jmp    1788 <botlish_fn_7+0x150>
    1773:	mov    ecx,0x2
    1778:	mov    rsi,QWORD PTR [rsp+0x30]
    177d:	cmp    rsi,rdx
    1780:	cmovge rcx,QWORD PTR [rip+0x1f0]        # 1978 <botlish_fn_7+0x340>
    1788:	cmp    rcx,0x6
    178c:	je     1951 <botlish_fn_7+0x319>
    1792:	mov    QWORD PTR [rsp+0x20],0x3
    179b:	mov    rsi,QWORD PTR [rsp+0x30]
    17a0:	test   rsi,0x1
    17a7:	je     17c4 <botlish_fn_7+0x18c>
    17ad:	mov    rsi,QWORD PTR [rsp+0x30]
    17b2:	mov    rax,rsi
    17b5:	add    rax,0x2
    17b9:	seto   cl
    17bc:	test   cl,cl
    17be:	je     17d6 <botlish_fn_7+0x19e>
    17c4:	mov    edx,0x3
    17c9:	mov    rsi,QWORD PTR [rsp+0x30]
    17ce:	mov    rdi,r13
    17d1:	call   17d6 <botlish_fn_7+0x19e>
			17d2: R_X86_64_PLT32	rt_int_add-0x4
    17d6:	mov    QWORD PTR [rsp+0x20],rax
    17db:	mov    QWORD PTR [rsp+0x38],rax
    17e0:	mov    QWORD PTR [rsp+0x28],0x3
    17e9:	mov    rsi,QWORD PTR [rsp+0x30]
    17ee:	test   rsi,0x1
    17f5:	je     1812 <botlish_fn_7+0x1da>
    17fb:	mov    rsi,QWORD PTR [rsp+0x30]
    1800:	mov    rcx,rsi
    1803:	add    rcx,0x2
    1807:	seto   al
    180a:	test   al,al
    180c:	je     1827 <botlish_fn_7+0x1ef>
    1812:	mov    edx,0x3
    1817:	mov    rsi,QWORD PTR [rsp+0x30]
    181c:	mov    rdi,r13
    181f:	call   1824 <botlish_fn_7+0x1ec>
			1820: R_X86_64_PLT32	rt_int_add-0x4
    1824:	mov    rcx,rax
    1827:	mov    QWORD PTR [rsp+0x28],rcx
    182c:	mov    rdx,QWORD PTR [rsp+0x30]
    1831:	mov    rsi,rbx
    1834:	mov    rdi,r13
    1837:	call   183c <botlish_fn_7+0x204>
			1838: R_X86_64_PLT32	rt_substr-0x4
    183c:	test   rax,rax
    183f:	je     1904 <botlish_fn_7+0x2cc>
    1845:	mov    QWORD PTR [rsp+0x8],rax
    184a:	mov    rsi,rax
    184d:	mov    rdx,r12
    1850:	mov    rdi,r13
    1853:	call   1858 <botlish_fn_7+0x220>
			1854: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    1858:	test   rax,rax
    185b:	je     1904 <botlish_fn_7+0x2cc>
    1861:	mov    QWORD PTR [rsp+0x8],rax
    1866:	xor    ecx,ecx
    1868:	mov    rsi,r14
    186b:	test   rsi,0x7
    1872:	jne    1883 <botlish_fn_7+0x24b>
    1878:	movzx  rdi,BYTE PTR [rsi]
    187c:	cmp    dil,0x2
    1880:	sete   cl
    1883:	test   cl,cl
    1885:	jne    18a6 <botlish_fn_7+0x26e>
    188b:	mov    rdi,r13
    188e:	mov    r9,QWORD PTR [rdi+0x10]
    1892:	mov    rcx,QWORD PTR [r9+0xc8]
    1899:	mov    rdx,r15
    189c:	call   18a1 <botlish_fn_7+0x269>
			189d: R_X86_64_PLT32	rt_type_error-0x4
    18a1:	jmp    1904 <botlish_fn_7+0x2cc>
    18a6:	mov    rdx,r15
    18a9:	xor    ecx,ecx
    18ab:	test   rax,0x7
    18b1:	je     18bf <botlish_fn_7+0x287>
    18b7:	mov    r8,rax
    18ba:	jmp    18cd <botlish_fn_7+0x295>
    18bf:	movzx  rcx,BYTE PTR [rax]
    18c3:	mov    r8,rax
    18c6:	rex cmp cl,0x2
    18ca:	sete   cl
    18cd:	test   cl,cl
    18cf:	jne    18f0 <botlish_fn_7+0x2b8>
    18d5:	mov    rdi,r13
    18d8:	mov    rax,QWORD PTR [rdi+0x10]
    18dc:	mov    rcx,QWORD PTR [rax+0xc8]
    18e3:	mov    rsi,r8
    18e6:	call   18eb <botlish_fn_7+0x2b3>
			18e7: R_X86_64_PLT32	rt_type_error-0x4
    18eb:	jmp    1904 <botlish_fn_7+0x2cc>
    18f0:	mov    rdx,r8
    18f3:	mov    rdi,r13
    18f6:	call   18fb <botlish_fn_7+0x2c3>
			18f7: R_X86_64_PLT32	rt_str_cat-0x4
    18fb:	test   rax,rax
    18fe:	jne    1929 <botlish_fn_7+0x2f1>
    1904:	xor    rax,rax
    1907:	mov    rbx,QWORD PTR [rsp+0x40]
    190c:	mov    r12,QWORD PTR [rsp+0x48]
    1911:	mov    r13,QWORD PTR [rsp+0x50]
    1916:	mov    r14,QWORD PTR [rsp+0x58]
    191b:	mov    r15,QWORD PTR [rsp+0x60]
    1920:	add    rsp,0x70
    1924:	mov    rsp,rbp
    1927:	pop    rbp
    1928:	ret
    1929:	mov    QWORD PTR [rsp],rbx
    192d:	mov    rcx,QWORD PTR [rsp+0x38]
    1932:	mov    QWORD PTR [rsp+0x8],rcx
    1937:	mov    QWORD PTR [rsp+0x10],rax
    193c:	mov    QWORD PTR [rsp+0x18],r12
    1941:	mov    rsi,rbx
    1944:	mov    r14,rax
    1947:	mov    QWORD PTR [rsp+0x30],rcx
    194c:	jmp    1683 <botlish_fn_7+0x4b>
    1951:	mov    rax,r14
    1954:	mov    rbx,QWORD PTR [rsp+0x40]
    1959:	mov    r12,QWORD PTR [rsp+0x48]
    195e:	mov    r13,QWORD PTR [rsp+0x50]
    1963:	mov    r14,QWORD PTR [rsp+0x58]
    1968:	mov    r15,QWORD PTR [rsp+0x60]
    196d:	add    rsp,0x70
    1971:	mov    rsp,rbp
    1974:	pop    rbp
    1975:	ret
    1976:	add    BYTE PTR [rax],al
    1978:	(bad)
    1979:	add    BYTE PTR [rax],al
    197b:	add    BYTE PTR [rax],al
    197d:	add    BYTE PTR [rax],al
	...

0000000000001980 <botlish_entry_7: esc_from<generic>>:
    1980:	push   rbp
    1981:	mov    rbp,rsp
    1984:	mov    rsi,QWORD PTR [rdx]
    1987:	mov    r9,QWORD PTR [rdx+0x8]
    198b:	mov    rcx,QWORD PTR [rdx+0x10]
    198f:	mov    r8,QWORD PTR [rdx+0x18]
    1993:	mov    rdx,r9
    1996:	call   199b <botlish_entry_7+0x1b>
			1997: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
    199b:	mov    rsp,rbp
    199e:	pop    rbp
    199f:	ret

00000000000019a0 <botlish_fn_8: check<int, int, str, str>>:
    19a0:	push   rbp
    19a1:	mov    rbp,rsp
    19a4:	sub    rsp,0x60
    19a8:	mov    QWORD PTR [rsp+0x30],rbx
    19ad:	mov    QWORD PTR [rsp+0x38],r12
    19b2:	mov    QWORD PTR [rsp+0x40],r13
    19b7:	mov    QWORD PTR [rsp+0x48],r14
    19bc:	mov    QWORD PTR [rsp+0x50],r15
    19c1:	mov    QWORD PTR [rsp+0x20],0x0
    19ca:	mov    QWORD PTR [rsp],rsi
    19ce:	mov    QWORD PTR [rsp+0x8],rdx
    19d3:	mov    QWORD PTR [rsp+0x10],rcx
    19d8:	mov    r12,rcx
    19db:	mov    QWORD PTR [rsp+0x18],r8
    19e0:	mov    r14,r8
    19e3:	mov    r13,rsi
    19e6:	mov    r15,rdx
    19e9:	test   r13,0x1
    19f0:	jne    1a1b <botlish_fn_8+0x7b>
    19f6:	mov    edx,0x1
    19fb:	mov    rbx,rdi
    19fe:	mov    rsi,r13
    1a01:	call   1a06 <botlish_fn_8+0x66>
			1a02: R_X86_64_PLT32	rt_int_cmp-0x4
    1a06:	mov    ecx,0x2
    1a0b:	test   rax,rax
    1a0e:	cmovle rcx,QWORD PTR [rip+0x152]        # 1b68 <botlish_fn_8+0x1c8>
    1a16:	jmp    1a2f <botlish_fn_8+0x8f>
    1a1b:	mov    rbx,rdi
    1a1e:	mov    ecx,0x2
    1a23:	cmp    r13,0x1
    1a27:	cmovle rcx,QWORD PTR [rip+0x139]        # 1b68 <botlish_fn_8+0x1c8>
    1a2f:	cmp    rcx,0x6
    1a33:	je     1b3c <botlish_fn_8+0x19c>
    1a39:	mov    rax,QWORD PTR [rbx+0x10]
    1a3d:	mov    rax,QWORD PTR [rax+0xe0]
    1a44:	mov    rsi,r12
    1a47:	mov    rdi,rbx
    1a4a:	call   1a4f <botlish_fn_8+0xaf>
			1a4b: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    1a4f:	test   rax,rax
    1a52:	je     1a93 <botlish_fn_8+0xf3>
    1a58:	cmp    rax,0x6
    1a5c:	je     1a74 <botlish_fn_8+0xd4>
    1a62:	mov    edx,0x1
    1a67:	mov    QWORD PTR [rsp],0x1
    1a6f:	jmp    1ad5 <botlish_fn_8+0x135>
    1a74:	mov    rax,QWORD PTR [rbx+0x10]
    1a78:	mov    rax,QWORD PTR [rax+0xe8]
    1a7f:	mov    rsi,r12
    1a82:	mov    rdi,rbx
    1a85:	call   1a8a <botlish_fn_8+0xea>
			1a86: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    1a8a:	test   rax,rax
    1a8d:	jne    1ab8 <botlish_fn_8+0x118>
    1a93:	xor    rax,rax
    1a96:	mov    rbx,QWORD PTR [rsp+0x30]
    1a9b:	mov    r12,QWORD PTR [rsp+0x38]
    1aa0:	mov    r13,QWORD PTR [rsp+0x40]
    1aa5:	mov    r14,QWORD PTR [rsp+0x48]
    1aaa:	mov    r15,QWORD PTR [rsp+0x50]
    1aaf:	add    rsp,0x60
    1ab3:	mov    rsp,rbp
    1ab6:	pop    rbp
    1ab7:	ret
    1ab8:	cmp    rax,0x6
    1abc:	je     1acc <botlish_fn_8+0x12c>
    1ac2:	mov    edx,0x1
    1ac7:	jmp    1ad1 <botlish_fn_8+0x131>
    1acc:	mov    edx,0x3
    1ad1:	mov    QWORD PTR [rsp],rdx
    1ad5:	sar    r13,1
    1ad8:	sub    r13,0x1
    1adc:	shl    r13,1
    1adf:	or     r13,0x1
    1ae3:	mov    QWORD PTR [rsp+0x20],r13
    1ae8:	mov    rsi,r15
    1aeb:	mov    r8,rsi
    1aee:	and    r8,rdx
    1af1:	test   r8,0x1
    1af8:	je     1b13 <botlish_fn_8+0x173>
    1afe:	lea    r11,[rdx-0x1]
    1b02:	mov    rax,rsi
    1b05:	add    rax,r11
    1b08:	seto   cl
    1b0b:	test   cl,cl
    1b0d:	je     1b1b <botlish_fn_8+0x17b>
    1b13:	mov    rdi,rbx
    1b16:	call   1b1b <botlish_fn_8+0x17b>
			1b17: R_X86_64_PLT32	rt_int_add-0x4
    1b1b:	mov    QWORD PTR [rsp],r13
    1b1f:	mov    QWORD PTR [rsp+0x8],rax
    1b24:	mov    QWORD PTR [rsp+0x10],r12
    1b29:	mov    r8,r14
    1b2c:	mov    QWORD PTR [rsp+0x18],r8
    1b31:	mov    rdi,rbx
    1b34:	mov    r15,rax
    1b37:	jmp    19e9 <botlish_fn_8+0x49>
    1b3c:	mov    rax,r15
    1b3f:	mov    rbx,QWORD PTR [rsp+0x30]
    1b44:	mov    r12,QWORD PTR [rsp+0x38]
    1b49:	mov    r13,QWORD PTR [rsp+0x40]
    1b4e:	mov    r14,QWORD PTR [rsp+0x48]
    1b53:	mov    r15,QWORD PTR [rsp+0x50]
    1b58:	add    rsp,0x60
    1b5c:	mov    rsp,rbp
    1b5f:	pop    rbp
    1b60:	ret
    1b61:	add    BYTE PTR [rax],al
    1b63:	add    BYTE PTR [rax],al
    1b65:	add    BYTE PTR [rax],al
    1b67:	add    BYTE PTR [rsi],al
    1b69:	add    BYTE PTR [rax],al
    1b6b:	add    BYTE PTR [rax],al
    1b6d:	add    BYTE PTR [rax],al
	...

0000000000001b70 <botlish_entry_8: check<int, int, str, str>>:
    1b70:	push   rbp
    1b71:	mov    rbp,rsp
    1b74:	mov    rsi,QWORD PTR [rdx]
    1b77:	mov    r9,QWORD PTR [rdx+0x8]
    1b7b:	mov    rcx,QWORD PTR [rdx+0x10]
    1b7f:	mov    r8,QWORD PTR [rdx+0x18]
    1b83:	mov    rdx,r9
    1b86:	call   1b8b <botlish_entry_8+0x1b>
			1b87: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
    1b8b:	mov    rsp,rbp
    1b8e:	pop    rbp
    1b8f:	ret

0000000000001b90 <botlish_fn_9: <str>>:
    1b90:	push   rbp
    1b91:	mov    rbp,rsp
    1b94:	sub    rsp,0x50
    1b98:	mov    QWORD PTR [rsp+0x30],rbx
    1b9d:	mov    QWORD PTR [rsp+0x38],r12
    1ba2:	mov    QWORD PTR [rsp+0x40],r13
    1ba7:	mov    QWORD PTR [rsp+0x48],r14
    1bac:	mov    r13,rdi
    1baf:	mov    QWORD PTR [rsp+0x18],0x0
    1bb8:	mov    QWORD PTR [rsp],rsi
    1bbc:	mov    r14,rsi
    1bbf:	mov    rsi,r14
    1bc2:	mov    rdi,r13
    1bc5:	call   1bca <botlish_fn_9+0x3a>
			1bc6: R_X86_64_PLT32	rt_str_len-0x4
    1bca:	mov    rbx,rax
    1bcd:	mov    QWORD PTR [rsp+0x8],rax
    1bd2:	mov    esi,0x1
    1bd7:	mov    QWORD PTR [rsp+0x10],0x1
    1be0:	mov    rcx,r14
    1be3:	mov    rdx,rbx
    1be6:	mov    rdi,r13
    1be9:	call   1bee <botlish_fn_9+0x5e>
			1bea: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_local<generic>
    1bee:	mov    r12,rax
    1bf1:	test   r12,r12
    1bf4:	je     1d51 <botlish_fn_9+0x1c1>
    1bfa:	mov    QWORD PTR [rsp+0x10],r12
    1bff:	test   r12,0x1
    1c06:	jne    1c31 <botlish_fn_9+0xa1>
    1c0c:	mov    edx,0x1
    1c11:	mov    rsi,r12
    1c14:	mov    rdi,r13
    1c17:	call   1c1c <botlish_fn_9+0x8c>
			1c18: R_X86_64_PLT32	rt_int_cmp-0x4
    1c1c:	mov    ecx,0x2
    1c21:	test   rax,rax
    1c24:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 1df0 <botlish_fn_9+0x260>
    1c2c:	jmp    1c42 <botlish_fn_9+0xb2>
    1c31:	mov    ecx,0x2
    1c36:	cmp    r12,0x1
    1c3a:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 1df0 <botlish_fn_9+0x260>
    1c42:	cmp    rcx,0x6
    1c46:	je     1dcc <botlish_fn_9+0x23c>
    1c4c:	mov    rcx,r12
    1c4f:	and    rcx,rbx
    1c52:	test   rcx,0x1
    1c59:	jne    1c82 <botlish_fn_9+0xf2>
    1c5f:	mov    rdx,rbx
    1c62:	mov    rsi,r12
    1c65:	mov    rdi,r13
    1c68:	call   1c6d <botlish_fn_9+0xdd>
			1c69: R_X86_64_PLT32	rt_int_cmp-0x4
    1c6d:	mov    ecx,0x2
    1c72:	test   rax,rax
    1c75:	cmovge rcx,QWORD PTR [rip+0x173]        # 1df0 <botlish_fn_9+0x260>
    1c7d:	jmp    1c92 <botlish_fn_9+0x102>
    1c82:	mov    ecx,0x2
    1c87:	cmp    r12,rbx
    1c8a:	cmovge rcx,QWORD PTR [rip+0x15e]        # 1df0 <botlish_fn_9+0x260>
    1c92:	cmp    rcx,0x6
    1c96:	je     1dc2 <botlish_fn_9+0x232>
    1c9c:	lea    rcx,[rsp+0x20]
    1ca1:	mov    rdx,r14
    1ca4:	mov    rsi,r12
    1ca7:	mov    rdi,r13
    1caa:	call   1caf <botlish_fn_9+0x11f>
			1cab: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    1caf:	test   rax,rax
    1cb2:	mov    rsi,rax
    1cb5:	je     1d51 <botlish_fn_9+0x1c1>
    1cbb:	mov    rdx,QWORD PTR [rsp+0x20]
    1cc0:	mov    rcx,QWORD PTR [rsp+0x28]
    1cc5:	mov    rdi,r13
    1cc8:	mov    rax,QWORD PTR [rdi+0x10]
    1ccc:	mov    r8,QWORD PTR [rax+0x100]
    1cd3:	call   1cd8 <botlish_fn_9+0x148>
			1cd4: R_X86_64_PLT32	rt_str_region_eq-0x4
    1cd8:	cmp    rax,0x6
    1cdc:	je     1cef <botlish_fn_9+0x15f>
    1ce2:	mov    ecx,0x2
    1ce7:	mov    rax,rcx
    1cea:	jmp    1dd1 <botlish_fn_9+0x241>
    1cef:	mov    QWORD PTR [rsp+0x18],0x3
    1cf8:	test   r12,0x1
    1cff:	jne    1d0d <botlish_fn_9+0x17d>
    1d05:	mov    rcx,r12
    1d08:	jmp    1d22 <botlish_fn_9+0x192>
    1d0d:	mov    rsi,r12
    1d10:	add    rsi,0x2
    1d14:	mov    rcx,r12
    1d17:	seto   al
    1d1a:	test   al,al
    1d1c:	je     1d35 <botlish_fn_9+0x1a5>
    1d22:	mov    edx,0x3
    1d27:	mov    rsi,rcx
    1d2a:	mov    rdi,r13
    1d2d:	call   1d32 <botlish_fn_9+0x1a2>
			1d2e: R_X86_64_PLT32	rt_int_add-0x4
    1d32:	mov    rsi,rax
    1d35:	mov    QWORD PTR [rsp+0x10],rsi
    1d3a:	mov    rcx,r14
    1d3d:	mov    rdx,rbx
    1d40:	mov    rdi,r13
    1d43:	call   1d48 <botlish_fn_9+0x1b8>
			1d44: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain_loop<generic>
    1d48:	test   rax,rax
    1d4b:	jne    1d71 <botlish_fn_9+0x1e1>
    1d51:	xor    rax,rax
    1d54:	mov    rbx,QWORD PTR [rsp+0x30]
    1d59:	mov    r12,QWORD PTR [rsp+0x38]
    1d5e:	mov    r13,QWORD PTR [rsp+0x40]
    1d63:	mov    r14,QWORD PTR [rsp+0x48]
    1d68:	add    rsp,0x50
    1d6c:	mov    rsp,rbp
    1d6f:	pop    rbp
    1d70:	ret
    1d71:	mov    rcx,rax
    1d74:	and    rcx,rbx
    1d77:	mov    rsi,rax
    1d7a:	test   rcx,0x1
    1d81:	jne    1daa <botlish_fn_9+0x21a>
    1d87:	mov    rdx,rbx
    1d8a:	mov    rdi,r13
    1d8d:	call   1d92 <botlish_fn_9+0x202>
			1d8e: R_X86_64_PLT32	rt_int_cmp-0x4
    1d92:	mov    ecx,0x2
    1d97:	test   rax,rax
    1d9a:	mov    rax,rcx
    1d9d:	cmove  rax,QWORD PTR [rip+0x4b]        # 1df0 <botlish_fn_9+0x260>
    1da5:	jmp    1dd1 <botlish_fn_9+0x241>
    1daa:	mov    rdx,rbx
    1dad:	mov    eax,0x2
    1db2:	cmp    rsi,rdx
    1db5:	cmove  rax,QWORD PTR [rip+0x33]        # 1df0 <botlish_fn_9+0x260>
    1dbd:	jmp    1dd1 <botlish_fn_9+0x241>
    1dc2:	mov    eax,0x2
    1dc7:	jmp    1dd1 <botlish_fn_9+0x241>
    1dcc:	mov    eax,0x2
    1dd1:	mov    rbx,QWORD PTR [rsp+0x30]
    1dd6:	mov    r12,QWORD PTR [rsp+0x38]
    1ddb:	mov    r13,QWORD PTR [rsp+0x40]
    1de0:	mov    r14,QWORD PTR [rsp+0x48]
    1de5:	add    rsp,0x50
    1de9:	mov    rsp,rbp
    1dec:	pop    rbp
    1ded:	ret
    1dee:	add    BYTE PTR [rax],al
    1df0:	(bad)
    1df1:	add    BYTE PTR [rax],al
    1df3:	add    BYTE PTR [rax],al
    1df5:	add    BYTE PTR [rax],al
	...

0000000000001df8 <botlish_entry_9: <str>>:
    1df8:	push   rbp
    1df9:	mov    rbp,rsp
    1dfc:	mov    rsi,QWORD PTR [rdx]
    1dff:	call   1e04 <botlish_entry_9+0xc>
			1e00: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    1e04:	mov    rsp,rbp
    1e07:	pop    rbp
    1e08:	ret
    1e09:	add    BYTE PTR [rax],al
    1e0b:	add    BYTE PTR [rax],al
    1e0d:	add    BYTE PTR [rax],al
	...

0000000000001e10 <botlish_fn_10: <generic>>:
    1e10:	push   rbp
    1e11:	mov    rbp,rsp
    1e14:	sub    rsp,0x60
    1e18:	mov    QWORD PTR [rsp+0x30],rbx
    1e1d:	mov    QWORD PTR [rsp+0x38],r12
    1e22:	mov    QWORD PTR [rsp+0x40],r13
    1e27:	mov    QWORD PTR [rsp+0x48],r14
    1e2c:	mov    QWORD PTR [rsp+0x50],r15
    1e31:	mov    QWORD PTR [rsp+0x18],0x0
    1e3a:	mov    QWORD PTR [rsp],rsi
    1e3e:	xor    r8d,r8d
    1e41:	test   rsi,0x7
    1e48:	jne    1e58 <botlish_fn_10+0x48>
    1e4e:	movzx  rax,BYTE PTR [rsi]
    1e52:	cmp    al,0x2
    1e54:	sete   r8b
    1e58:	test   r8b,r8b
    1e5b:	jne    1e7b <botlish_fn_10+0x6b>
    1e61:	mov    rdx,QWORD PTR [rdi+0x10]
    1e65:	mov    rcx,QWORD PTR [rdx+0xd8]
    1e6c:	mov    edx,0x1
    1e71:	call   1e76 <botlish_fn_10+0x66>
			1e72: R_X86_64_PLT32	rt_type_error-0x4
    1e76:	jmp    2010 <botlish_fn_10+0x200>
    1e7b:	mov    r13,rsi
    1e7e:	mov    r14,rdi
    1e81:	call   1e86 <botlish_fn_10+0x76>
			1e82: R_X86_64_PLT32	rt_str_len-0x4
    1e86:	mov    rbx,rax
    1e89:	mov    QWORD PTR [rsp+0x8],rax
    1e8e:	mov    edx,0x1
    1e93:	mov    r15,rdx
    1e96:	mov    QWORD PTR [rsp+0x10],0x1
    1e9f:	mov    rcx,r13
    1ea2:	mov    rdx,rbx
    1ea5:	mov    rsi,r15
    1ea8:	mov    rdi,r14
    1eab:	call   1eb0 <botlish_fn_10+0xa0>
			1eac: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_local<generic>
    1eb0:	mov    r12,rax
    1eb3:	test   r12,r12
    1eb6:	je     2010 <botlish_fn_10+0x200>
    1ebc:	mov    QWORD PTR [rsp+0x10],r12
    1ec1:	test   r12,0x1
    1ec8:	jne    1ef1 <botlish_fn_10+0xe1>
    1ece:	mov    rdx,r15
    1ed1:	mov    rsi,r12
    1ed4:	mov    rdi,r14
    1ed7:	call   1edc <botlish_fn_10+0xcc>
			1ed8: R_X86_64_PLT32	rt_int_cmp-0x4
    1edc:	mov    ecx,0x2
    1ee1:	test   rax,rax
    1ee4:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 20b8 <botlish_fn_10+0x2a8>
    1eec:	jmp    1f02 <botlish_fn_10+0xf2>
    1ef1:	mov    ecx,0x2
    1ef6:	cmp    r12,0x1
    1efa:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 20b8 <botlish_fn_10+0x2a8>
    1f02:	cmp    rcx,0x6
    1f06:	je     2090 <botlish_fn_10+0x280>
    1f0c:	mov    rax,r12
    1f0f:	and    rax,rbx
    1f12:	test   rax,0x1
    1f18:	jne    1f41 <botlish_fn_10+0x131>
    1f1e:	mov    rdx,rbx
    1f21:	mov    rsi,r12
    1f24:	mov    rdi,r14
    1f27:	call   1f2c <botlish_fn_10+0x11c>
			1f28: R_X86_64_PLT32	rt_int_cmp-0x4
    1f2c:	mov    ecx,0x2
    1f31:	test   rax,rax
    1f34:	cmovge rcx,QWORD PTR [rip+0x17c]        # 20b8 <botlish_fn_10+0x2a8>
    1f3c:	jmp    1f51 <botlish_fn_10+0x141>
    1f41:	mov    ecx,0x2
    1f46:	cmp    r12,rbx
    1f49:	cmovge rcx,QWORD PTR [rip+0x167]        # 20b8 <botlish_fn_10+0x2a8>
    1f51:	cmp    rcx,0x6
    1f55:	je     2086 <botlish_fn_10+0x276>
    1f5b:	lea    rcx,[rsp+0x20]
    1f60:	mov    rdx,r13
    1f63:	mov    rsi,r12
    1f66:	mov    rdi,r14
    1f69:	call   1f6e <botlish_fn_10+0x15e>
			1f6a: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    1f6e:	test   rax,rax
    1f71:	mov    rsi,rax
    1f74:	je     2010 <botlish_fn_10+0x200>
    1f7a:	mov    rdx,QWORD PTR [rsp+0x20]
    1f7f:	mov    rcx,QWORD PTR [rsp+0x28]
    1f84:	mov    rdi,r14
    1f87:	mov    rax,QWORD PTR [rdi+0x10]
    1f8b:	mov    r8,QWORD PTR [rax+0x100]
    1f92:	call   1f97 <botlish_fn_10+0x187>
			1f93: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f97:	cmp    rax,0x6
    1f9b:	je     1fae <botlish_fn_10+0x19e>
    1fa1:	mov    ecx,0x2
    1fa6:	mov    rax,rcx
    1fa9:	jmp    2095 <botlish_fn_10+0x285>
    1fae:	mov    QWORD PTR [rsp+0x18],0x3
    1fb7:	test   r12,0x1
    1fbe:	jne    1fcc <botlish_fn_10+0x1bc>
    1fc4:	mov    rdi,r12
    1fc7:	jmp    1fe1 <botlish_fn_10+0x1d1>
    1fcc:	mov    rsi,r12
    1fcf:	add    rsi,0x2
    1fd3:	mov    rdi,r12
    1fd6:	seto   al
    1fd9:	test   al,al
    1fdb:	je     1ff4 <botlish_fn_10+0x1e4>
    1fe1:	mov    edx,0x3
    1fe6:	mov    rsi,rdi
    1fe9:	mov    rdi,r14
    1fec:	call   1ff1 <botlish_fn_10+0x1e1>
			1fed: R_X86_64_PLT32	rt_int_add-0x4
    1ff1:	mov    rsi,rax
    1ff4:	mov    QWORD PTR [rsp+0x10],rsi
    1ff9:	mov    rcx,r13
    1ffc:	mov    rdx,rbx
    1fff:	mov    rdi,r14
    2002:	call   2007 <botlish_fn_10+0x1f7>
			2003: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain_loop<generic>
    2007:	test   rax,rax
    200a:	jne    2035 <botlish_fn_10+0x225>
    2010:	xor    rax,rax
    2013:	mov    rbx,QWORD PTR [rsp+0x30]
    2018:	mov    r12,QWORD PTR [rsp+0x38]
    201d:	mov    r13,QWORD PTR [rsp+0x40]
    2022:	mov    r14,QWORD PTR [rsp+0x48]
    2027:	mov    r15,QWORD PTR [rsp+0x50]
    202c:	add    rsp,0x60
    2030:	mov    rsp,rbp
    2033:	pop    rbp
    2034:	ret
    2035:	mov    rcx,rax
    2038:	and    rcx,rbx
    203b:	mov    rsi,rax
    203e:	test   rcx,0x1
    2045:	jne    206e <botlish_fn_10+0x25e>
    204b:	mov    rdx,rbx
    204e:	mov    rdi,r14
    2051:	call   2056 <botlish_fn_10+0x246>
			2052: R_X86_64_PLT32	rt_int_cmp-0x4
    2056:	mov    ecx,0x2
    205b:	test   rax,rax
    205e:	mov    rax,rcx
    2061:	cmove  rax,QWORD PTR [rip+0x4f]        # 20b8 <botlish_fn_10+0x2a8>
    2069:	jmp    2095 <botlish_fn_10+0x285>
    206e:	mov    rdx,rbx
    2071:	mov    eax,0x2
    2076:	cmp    rsi,rdx
    2079:	cmove  rax,QWORD PTR [rip+0x37]        # 20b8 <botlish_fn_10+0x2a8>
    2081:	jmp    2095 <botlish_fn_10+0x285>
    2086:	mov    eax,0x2
    208b:	jmp    2095 <botlish_fn_10+0x285>
    2090:	mov    eax,0x2
    2095:	mov    rbx,QWORD PTR [rsp+0x30]
    209a:	mov    r12,QWORD PTR [rsp+0x38]
    209f:	mov    r13,QWORD PTR [rsp+0x40]
    20a4:	mov    r14,QWORD PTR [rsp+0x48]
    20a9:	mov    r15,QWORD PTR [rsp+0x50]
    20ae:	add    rsp,0x60
    20b2:	mov    rsp,rbp
    20b5:	pop    rbp
    20b6:	ret
    20b7:	add    BYTE PTR [rsi],al
    20b9:	add    BYTE PTR [rax],al
    20bb:	add    BYTE PTR [rax],al
    20bd:	add    BYTE PTR [rax],al
	...

00000000000020c0 <botlish_entry_10: <generic>>:
    20c0:	push   rbp
    20c1:	mov    rbp,rsp
    20c4:	mov    rsi,QWORD PTR [rdx]
    20c7:	call   20cc <botlish_entry_10+0xc>
			20c8: R_X86_64_PLT32	botlish_fn_10-0x4 ; <generic>
    20cc:	mov    rsp,rbp
    20cf:	pop    rbp
    20d0:	ret

00000000000020d1 <botlish_fn_11: char_at<generic>>:
    20d1:	push   rbp
    20d2:	mov    rbp,rsp
    20d5:	sub    rsp,0x50
    20d9:	mov    QWORD PTR [rsp+0x20],rbx
    20de:	mov    QWORD PTR [rsp+0x28],r12
    20e3:	mov    QWORD PTR [rsp+0x30],r13
    20e8:	mov    QWORD PTR [rsp+0x38],r14
    20ed:	mov    QWORD PTR [rsp+0x40],r15
    20f2:	mov    r14,rcx
    20f5:	mov    QWORD PTR [rsp],rsi
    20f9:	mov    QWORD PTR [rsp+0x8],rdx
    20fe:	mov    r13,rdx
    2101:	mov    QWORD PTR [rsp+0x10],0x3
    210a:	mov    r9d,0x1
    2110:	test   rsi,0x1
    2117:	jne    2137 <botlish_fn_11+0x66>
    211d:	xor    r9d,r9d
    2120:	test   rsi,0x7
    2127:	jne    2137 <botlish_fn_11+0x66>
    212d:	movzx  rax,BYTE PTR [rsi]
    2131:	cmp    al,0x1
    2133:	sete   r9b
    2137:	test   r9b,r9b
    213a:	jne    2158 <botlish_fn_11+0x87>
    2140:	mov    rax,QWORD PTR [rdi+0x10]
    2144:	mov    rcx,QWORD PTR [rax+0x108]
    214b:	xor    rdx,rdx
    214e:	call   2153 <botlish_fn_11+0x82>
			214f: R_X86_64_PLT32	rt_type_error-0x4
    2153:	jmp    2215 <botlish_fn_11+0x144>
    2158:	mov    r12,rdi
    215b:	test   rsi,0x1
    2162:	jne    2170 <botlish_fn_11+0x9f>
    2168:	mov    rbx,rsi
    216b:	jmp    218d <botlish_fn_11+0xbc>
    2170:	mov    rax,rsi
    2173:	add    rax,0x2
    2177:	mov    rbx,rsi
    217a:	seto   cl
    217d:	test   cl,cl
    217f:	jne    218d <botlish_fn_11+0xbc>
    2185:	mov    r15,rax
    2188:	jmp    21a0 <botlish_fn_11+0xcf>
    218d:	mov    edx,0x3
    2192:	mov    rsi,rbx
    2195:	mov    rdi,r12
    2198:	call   219d <botlish_fn_11+0xcc>
			2199: R_X86_64_PLT32	rt_int_add-0x4
    219d:	mov    r15,rax
    21a0:	mov    ecx,0x1
    21a5:	mov    rsi,rbx
    21a8:	test   rsi,0x1
    21af:	jne    21d5 <botlish_fn_11+0x104>
    21b5:	xor    ecx,ecx
    21b7:	mov    rsi,rbx
    21ba:	test   rsi,0x7
    21c1:	jne    21d5 <botlish_fn_11+0x104>
    21c7:	mov    rsi,rbx
    21ca:	movzx  rcx,BYTE PTR [rsi]
    21ce:	rex cmp cl,0x1
    21d2:	sete   cl
    21d5:	test   cl,cl
    21d7:	jne    21fb <botlish_fn_11+0x12a>
    21dd:	mov    rdi,r12
    21e0:	mov    rsi,QWORD PTR [rdi+0x10]
    21e4:	mov    rcx,QWORD PTR [rsi+0x110]
    21eb:	xor    rdx,rdx
    21ee:	mov    rsi,rbx
    21f1:	call   21f6 <botlish_fn_11+0x125>
			21f2: R_X86_64_PLT32	rt_type_error-0x4
    21f6:	jmp    2215 <botlish_fn_11+0x144>
    21fb:	mov    rdi,r12
    21fe:	mov    rcx,r15
    2201:	mov    rdx,rbx
    2204:	mov    rsi,r13
    2207:	call   220c <botlish_fn_11+0x13b>
			2208: R_X86_64_PLT32	rt_str_region_check-0x4
    220c:	test   rax,rax
    220f:	jne    223a <botlish_fn_11+0x169>
    2215:	xor    rax,rax
    2218:	mov    rbx,QWORD PTR [rsp+0x20]
    221d:	mov    r12,QWORD PTR [rsp+0x28]
    2222:	mov    r13,QWORD PTR [rsp+0x30]
    2227:	mov    r14,QWORD PTR [rsp+0x38]
    222c:	mov    r15,QWORD PTR [rsp+0x40]
    2231:	add    rsp,0x50
    2235:	mov    rsp,rbp
    2238:	pop    rbp
    2239:	ret
    223a:	mov    rcx,r14
    223d:	mov    rsi,rbx
    2240:	mov    QWORD PTR [rcx],rsi
    2243:	mov    rax,r15
    2246:	mov    QWORD PTR [rcx+0x8],rax
    224a:	mov    rax,r13
    224d:	mov    rbx,QWORD PTR [rsp+0x20]
    2252:	mov    r12,QWORD PTR [rsp+0x28]
    2257:	mov    r13,QWORD PTR [rsp+0x30]
    225c:	mov    r14,QWORD PTR [rsp+0x38]
    2261:	mov    r15,QWORD PTR [rsp+0x40]
    2266:	add    rsp,0x50
    226a:	mov    rsp,rbp
    226d:	pop    rbp
    226e:	ret

000000000000226f <botlish_entry_11: char_at<generic>>:
    226f:	push   rbp
    2270:	mov    rbp,rsp
    2273:	ud2
    2275:	add    BYTE PTR [rax],al
	...

0000000000002278 <botlish_fn_12: scan_local<generic>>:
    2278:	push   rbp
    2279:	mov    rbp,rsp
    227c:	sub    rsp,0x80
    2283:	mov    QWORD PTR [rsp+0x50],rbx
    2288:	mov    QWORD PTR [rsp+0x58],r12
    228d:	mov    QWORD PTR [rsp+0x60],r13
    2292:	mov    QWORD PTR [rsp+0x68],r14
    2297:	mov    QWORD PTR [rsp+0x70],r15
    229c:	mov    rax,rdi
    229f:	mov    QWORD PTR [rsp+0x18],0x0
    22a8:	mov    QWORD PTR [rsp],rsi
    22ac:	mov    r14,rsi
    22af:	mov    QWORD PTR [rsp+0x8],rdx
    22b4:	mov    QWORD PTR [rsp+0x10],rcx
    22b9:	mov    r12,rcx
    22bc:	mov    r11d,0x1
    22c2:	mov    rsi,r14
    22c5:	test   rsi,0x1
    22cc:	jne    22ee <botlish_fn_12+0x76>
    22d2:	xor    r11d,r11d
    22d5:	test   rsi,0x7
    22dc:	jne    22ee <botlish_fn_12+0x76>
    22e2:	movzx  rdi,BYTE PTR [rsi]
    22e6:	cmp    dil,0x1
    22ea:	sete   r11b
    22ee:	test   r11b,r11b
    22f1:	jne    2312 <botlish_fn_12+0x9a>
    22f7:	mov    rdi,rax
    22fa:	mov    r9,QWORD PTR [rdi+0x10]
    22fe:	mov    rcx,QWORD PTR [r9+0xb8]
    2305:	xor    rdx,rdx
    2308:	call   230d <botlish_fn_12+0x95>
			2309: R_X86_64_PLT32	rt_type_error-0x4
    230d:	jmp    23c5 <botlish_fn_12+0x14d>
    2312:	mov    r13,rdx
    2315:	mov    r10,rsi
    2318:	and    r10,r13
    231b:	mov    r14,rsi
    231e:	test   r10,0x1
    2325:	jne    2351 <botlish_fn_12+0xd9>
    232b:	mov    rbx,rax
    232e:	mov    rdx,r13
    2331:	mov    rsi,r14
    2334:	mov    rdi,rbx
    2337:	call   233c <botlish_fn_12+0xc4>
			2338: R_X86_64_PLT32	rt_int_cmp-0x4
    233c:	mov    ecx,0x2
    2341:	test   rax,rax
    2344:	cmovge rcx,QWORD PTR [rip+0x24c]        # 2598 <botlish_fn_12+0x320>
    234c:	jmp    2367 <botlish_fn_12+0xef>
    2351:	mov    rbx,rax
    2354:	mov    ecx,0x2
    2359:	mov    rsi,r14
    235c:	cmp    rsi,r13
    235f:	cmovge rcx,QWORD PTR [rip+0x231]        # 2598 <botlish_fn_12+0x320>
    2367:	mov    eax,0x6
    236c:	mov    QWORD PTR [rsp+0x30],rax
    2371:	cmp    rcx,0x6
    2375:	je     256b <botlish_fn_12+0x2f3>
    237b:	lea    rcx,[rsp+0x20]
    2380:	mov    rdx,r12
    2383:	mov    rsi,r14
    2386:	mov    rdi,rbx
    2389:	call   238e <botlish_fn_12+0x116>
			238a: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    238e:	mov    rsi,rax
    2391:	mov    r15,rax
    2394:	test   rax,rsi
    2397:	je     23c5 <botlish_fn_12+0x14d>
    239d:	mov    rdx,QWORD PTR [rsp+0x20]
    23a2:	mov    QWORD PTR [rsp+0x40],rdx
    23a7:	mov    rcx,QWORD PTR [rsp+0x28]
    23ac:	mov    QWORD PTR [rsp+0x38],rcx
    23b1:	mov    rsi,r15
    23b4:	mov    rdi,rbx
    23b7:	call   23bc <botlish_fn_12+0x144>
			23b8: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    23bc:	test   rax,rax
    23bf:	jne    23ed <botlish_fn_12+0x175>
    23c5:	xor    rax,rax
    23c8:	mov    rbx,QWORD PTR [rsp+0x50]
    23cd:	mov    r12,QWORD PTR [rsp+0x58]
    23d2:	mov    r13,QWORD PTR [rsp+0x60]
    23d7:	mov    r14,QWORD PTR [rsp+0x68]
    23dc:	mov    r15,QWORD PTR [rsp+0x70]
    23e1:	add    rsp,0x80
    23e8:	mov    rsp,rbp
    23eb:	pop    rbp
    23ec:	ret
    23ed:	cmp    rax,0x6
    23f1:	je     24ec <botlish_fn_12+0x274>
    23f7:	mov    rax,QWORD PTR [rbx+0x10]
    23fb:	mov    r8,QWORD PTR [rax+0x118]
    2402:	mov    rcx,QWORD PTR [rsp+0x38]
    2407:	mov    rdx,QWORD PTR [rsp+0x40]
    240c:	mov    rsi,r15
    240f:	mov    rdi,rbx
    2412:	call   2417 <botlish_fn_12+0x19f>
			2413: R_X86_64_PLT32	rt_str_region_eq-0x4
    2417:	cmp    rax,0x6
    241b:	je     24e2 <botlish_fn_12+0x26a>
    2421:	mov    rax,QWORD PTR [rbx+0x10]
    2425:	mov    r8,QWORD PTR [rax+0x120]
    242c:	mov    rcx,QWORD PTR [rsp+0x38]
    2431:	mov    rdx,QWORD PTR [rsp+0x40]
    2436:	mov    rsi,r15
    2439:	mov    rdi,rbx
    243c:	call   2441 <botlish_fn_12+0x1c9>
			243d: R_X86_64_PLT32	rt_str_region_eq-0x4
    2441:	cmp    rax,0x6
    2445:	je     24d8 <botlish_fn_12+0x260>
    244b:	mov    rax,QWORD PTR [rbx+0x10]
    244f:	mov    r8,QWORD PTR [rax+0xc0]
    2456:	mov    rcx,QWORD PTR [rsp+0x38]
    245b:	mov    rdx,QWORD PTR [rsp+0x40]
    2460:	mov    rsi,r15
    2463:	mov    rdi,rbx
    2466:	call   246b <botlish_fn_12+0x1f3>
			2467: R_X86_64_PLT32	rt_str_region_eq-0x4
    246b:	cmp    rax,0x6
    246f:	je     24ce <botlish_fn_12+0x256>
    2475:	mov    rax,QWORD PTR [rbx+0x10]
    2479:	mov    r8,QWORD PTR [rax+0x108]
    2480:	mov    rcx,QWORD PTR [rsp+0x38]
    2485:	mov    rdx,QWORD PTR [rsp+0x40]
    248a:	mov    rsi,r15
    248d:	mov    rdi,rbx
    2490:	call   2495 <botlish_fn_12+0x21d>
			2491: R_X86_64_PLT32	rt_str_region_eq-0x4
    2495:	cmp    rax,0x6
    2499:	je     24c4 <botlish_fn_12+0x24c>
    249f:	mov    rax,QWORD PTR [rbx+0x10]
    24a3:	mov    r8,QWORD PTR [rax+0x128]
    24aa:	mov    rcx,QWORD PTR [rsp+0x38]
    24af:	mov    rdx,QWORD PTR [rsp+0x40]
    24b4:	mov    rsi,r15
    24b7:	mov    rdi,rbx
    24ba:	call   24bf <botlish_fn_12+0x247>
			24bb: R_X86_64_PLT32	rt_str_region_eq-0x4
    24bf:	jmp    24f1 <botlish_fn_12+0x279>
    24c4:	mov    rax,QWORD PTR [rsp+0x30]
    24c9:	jmp    24f1 <botlish_fn_12+0x279>
    24ce:	mov    rax,QWORD PTR [rsp+0x30]
    24d3:	jmp    24f1 <botlish_fn_12+0x279>
    24d8:	mov    rax,QWORD PTR [rsp+0x30]
    24dd:	jmp    24f1 <botlish_fn_12+0x279>
    24e2:	mov    rax,QWORD PTR [rsp+0x30]
    24e7:	jmp    24f1 <botlish_fn_12+0x279>
    24ec:	mov    rax,QWORD PTR [rsp+0x30]
    24f1:	cmp    rax,0x6
    24f5:	je     2503 <botlish_fn_12+0x28b>
    24fb:	mov    rax,r14
    24fe:	jmp    256e <botlish_fn_12+0x2f6>
    2503:	mov    QWORD PTR [rsp+0x18],0x3
    250c:	mov    rsi,r14
    250f:	test   rsi,0x1
    2516:	je     253c <botlish_fn_12+0x2c4>
    251c:	mov    rsi,r14
    251f:	mov    rax,rsi
    2522:	add    rax,0x2
    2526:	seto   cl
    2529:	test   cl,cl
    252b:	jne    253c <botlish_fn_12+0x2c4>
    2531:	mov    rsi,rax
    2534:	mov    r14,rax
    2537:	jmp    2552 <botlish_fn_12+0x2da>
    253c:	mov    edx,0x3
    2541:	mov    rsi,r14
    2544:	mov    rdi,rbx
    2547:	call   254c <botlish_fn_12+0x2d4>
			2548: R_X86_64_PLT32	rt_int_add-0x4
    254c:	mov    rsi,rax
    254f:	mov    r14,rax
    2552:	mov    QWORD PTR [rsp],rsi
    2556:	mov    QWORD PTR [rsp+0x8],r13
    255b:	mov    QWORD PTR [rsp+0x10],r12
    2560:	mov    rax,rbx
    2563:	mov    rdx,r13
    2566:	jmp    22bc <botlish_fn_12+0x44>
    256b:	mov    rax,r14
    256e:	mov    rbx,QWORD PTR [rsp+0x50]
    2573:	mov    r12,QWORD PTR [rsp+0x58]
    2578:	mov    r13,QWORD PTR [rsp+0x60]
    257d:	mov    r14,QWORD PTR [rsp+0x68]
    2582:	mov    r15,QWORD PTR [rsp+0x70]
    2587:	add    rsp,0x80
    258e:	mov    rsp,rbp
    2591:	pop    rbp
    2592:	ret
    2593:	add    BYTE PTR [rax],al
    2595:	add    BYTE PTR [rax],al
    2597:	add    BYTE PTR [rsi],al
    2599:	add    BYTE PTR [rax],al
    259b:	add    BYTE PTR [rax],al
    259d:	add    BYTE PTR [rax],al
	...

00000000000025a0 <botlish_entry_12: scan_local<generic>>:
    25a0:	push   rbp
    25a1:	mov    rbp,rsp
    25a4:	mov    rsi,QWORD PTR [rdx]
    25a7:	mov    r8,QWORD PTR [rdx+0x8]
    25ab:	mov    rcx,QWORD PTR [rdx+0x10]
    25af:	mov    rdx,r8
    25b2:	call   25b7 <botlish_entry_12+0x17>
			25b3: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_local<generic>
    25b7:	mov    rsp,rbp
    25ba:	pop    rbp
    25bb:	ret
    25bc:	add    BYTE PTR [rax],al
	...

00000000000025c0 <botlish_fn_13: scan_label<generic>>:
    25c0:	push   rbp
    25c1:	mov    rbp,rsp
    25c4:	sub    rsp,0x80
    25cb:	mov    QWORD PTR [rsp+0x50],rbx
    25d0:	mov    QWORD PTR [rsp+0x58],r12
    25d5:	mov    QWORD PTR [rsp+0x60],r13
    25da:	mov    QWORD PTR [rsp+0x68],r14
    25df:	mov    QWORD PTR [rsp+0x70],r15
    25e4:	mov    QWORD PTR [rsp+0x18],0x0
    25ed:	mov    QWORD PTR [rsp],rsi
    25f1:	mov    r14,rsi
    25f4:	mov    QWORD PTR [rsp+0x8],rdx
    25f9:	mov    QWORD PTR [rsp+0x10],rcx
    25fe:	mov    r12,rcx
    2601:	mov    r11d,0x1
    2607:	mov    rsi,r14
    260a:	test   rsi,0x1
    2611:	jne    2631 <botlish_fn_13+0x71>
    2617:	xor    r11d,r11d
    261a:	test   rsi,0x7
    2621:	jne    2631 <botlish_fn_13+0x71>
    2627:	movzx  rax,BYTE PTR [rsi]
    262b:	cmp    al,0x1
    262d:	sete   r11b
    2631:	test   r11b,r11b
    2634:	jne    2652 <botlish_fn_13+0x92>
    263a:	mov    rax,QWORD PTR [rdi+0x10]
    263e:	mov    rcx,QWORD PTR [rax+0xb8]
    2645:	xor    rdx,rdx
    2648:	call   264d <botlish_fn_13+0x8d>
			2649: R_X86_64_PLT32	rt_type_error-0x4
    264d:	jmp    26fe <botlish_fn_13+0x13e>
    2652:	mov    r13,rdx
    2655:	mov    rax,rsi
    2658:	and    rax,r13
    265b:	mov    r14,rsi
    265e:	test   rax,0x1
    2664:	jne    268d <botlish_fn_13+0xcd>
    266a:	mov    rbx,rdi
    266d:	mov    rdx,r13
    2670:	mov    rsi,r14
    2673:	call   2678 <botlish_fn_13+0xb8>
			2674: R_X86_64_PLT32	rt_int_cmp-0x4
    2678:	mov    ecx,0x2
    267d:	test   rax,rax
    2680:	cmovge rcx,QWORD PTR [rip+0x178]        # 2800 <botlish_fn_13+0x240>
    2688:	jmp    26a3 <botlish_fn_13+0xe3>
    268d:	mov    rbx,rdi
    2690:	mov    ecx,0x2
    2695:	mov    rsi,r14
    2698:	cmp    rsi,r13
    269b:	cmovge rcx,QWORD PTR [rip+0x15d]        # 2800 <botlish_fn_13+0x240>
    26a3:	mov    eax,0x6
    26a8:	mov    QWORD PTR [rsp+0x30],rax
    26ad:	cmp    rcx,0x6
    26b1:	je     27d4 <botlish_fn_13+0x214>
    26b7:	lea    rcx,[rsp+0x20]
    26bc:	mov    rdx,r12
    26bf:	mov    rsi,r14
    26c2:	mov    rdi,rbx
    26c5:	call   26ca <botlish_fn_13+0x10a>
			26c6: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    26ca:	test   rax,rax
    26cd:	mov    r15,rax
    26d0:	je     26fe <botlish_fn_13+0x13e>
    26d6:	mov    rdx,QWORD PTR [rsp+0x20]
    26db:	mov    QWORD PTR [rsp+0x40],rdx
    26e0:	mov    rcx,QWORD PTR [rsp+0x28]
    26e5:	mov    QWORD PTR [rsp+0x38],rcx
    26ea:	mov    rsi,r15
    26ed:	mov    rdi,rbx
    26f0:	call   26f5 <botlish_fn_13+0x135>
			26f1: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    26f5:	test   rax,rax
    26f8:	jne    2726 <botlish_fn_13+0x166>
    26fe:	xor    rax,rax
    2701:	mov    rbx,QWORD PTR [rsp+0x50]
    2706:	mov    r12,QWORD PTR [rsp+0x58]
    270b:	mov    r13,QWORD PTR [rsp+0x60]
    2710:	mov    r14,QWORD PTR [rsp+0x68]
    2715:	mov    r15,QWORD PTR [rsp+0x70]
    271a:	add    rsp,0x80
    2721:	mov    rsp,rbp
    2724:	pop    rbp
    2725:	ret
    2726:	cmp    rax,0x6
    272a:	je     2755 <botlish_fn_13+0x195>
    2730:	mov    r11,QWORD PTR [rbx+0x10]
    2734:	mov    r8,QWORD PTR [r11+0x128]
    273b:	mov    rcx,QWORD PTR [rsp+0x38]
    2740:	mov    rdx,QWORD PTR [rsp+0x40]
    2745:	mov    rsi,r15
    2748:	mov    rdi,rbx
    274b:	call   2750 <botlish_fn_13+0x190>
			274c: R_X86_64_PLT32	rt_str_region_eq-0x4
    2750:	jmp    275a <botlish_fn_13+0x19a>
    2755:	mov    rax,QWORD PTR [rsp+0x30]
    275a:	cmp    rax,0x6
    275e:	je     276c <botlish_fn_13+0x1ac>
    2764:	mov    rax,r14
    2767:	jmp    27d7 <botlish_fn_13+0x217>
    276c:	mov    QWORD PTR [rsp+0x18],0x3
    2775:	mov    rsi,r14
    2778:	test   rsi,0x1
    277f:	je     27a5 <botlish_fn_13+0x1e5>
    2785:	mov    rsi,r14
    2788:	mov    rax,rsi
    278b:	add    rax,0x2
    278f:	seto   cl
    2792:	test   cl,cl
    2794:	jne    27a5 <botlish_fn_13+0x1e5>
    279a:	mov    rsi,rax
    279d:	mov    r14,rax
    27a0:	jmp    27bb <botlish_fn_13+0x1fb>
    27a5:	mov    edx,0x3
    27aa:	mov    rsi,r14
    27ad:	mov    rdi,rbx
    27b0:	call   27b5 <botlish_fn_13+0x1f5>
			27b1: R_X86_64_PLT32	rt_int_add-0x4
    27b5:	mov    rsi,rax
    27b8:	mov    r14,rax
    27bb:	mov    QWORD PTR [rsp],rsi
    27bf:	mov    QWORD PTR [rsp+0x8],r13
    27c4:	mov    QWORD PTR [rsp+0x10],r12
    27c9:	mov    rdx,r13
    27cc:	mov    rdi,rbx
    27cf:	jmp    2601 <botlish_fn_13+0x41>
    27d4:	mov    rax,r14
    27d7:	mov    rbx,QWORD PTR [rsp+0x50]
    27dc:	mov    r12,QWORD PTR [rsp+0x58]
    27e1:	mov    r13,QWORD PTR [rsp+0x60]
    27e6:	mov    r14,QWORD PTR [rsp+0x68]
    27eb:	mov    r15,QWORD PTR [rsp+0x70]
    27f0:	add    rsp,0x80
    27f7:	mov    rsp,rbp
    27fa:	pop    rbp
    27fb:	ret
    27fc:	add    BYTE PTR [rax],al
    27fe:	add    BYTE PTR [rax],al
    2800:	(bad)
    2801:	add    BYTE PTR [rax],al
    2803:	add    BYTE PTR [rax],al
    2805:	add    BYTE PTR [rax],al
	...

0000000000002808 <botlish_entry_13: scan_label<generic>>:
    2808:	push   rbp
    2809:	mov    rbp,rsp
    280c:	mov    rsi,QWORD PTR [rdx]
    280f:	mov    r8,QWORD PTR [rdx+0x8]
    2813:	mov    rcx,QWORD PTR [rdx+0x10]
    2817:	mov    rdx,r8
    281a:	call   281f <botlish_entry_13+0x17>
			281b: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_label<generic>
    281f:	mov    rsp,rbp
    2822:	pop    rbp
    2823:	ret
    2824:	add    BYTE PTR [rax],al
	...

0000000000002828 <botlish_fn_14: scan_alpha<generic>>:
    2828:	push   rbp
    2829:	mov    rbp,rsp
    282c:	sub    rsp,0x50
    2830:	mov    QWORD PTR [rsp+0x30],rbx
    2835:	mov    QWORD PTR [rsp+0x38],r12
    283a:	mov    QWORD PTR [rsp+0x40],r13
    283f:	mov    QWORD PTR [rsp+0x48],r14
    2844:	mov    r14,rdi
    2847:	mov    QWORD PTR [rsp+0x18],0x0
    2850:	mov    QWORD PTR [rsp],rsi
    2854:	mov    r13,rsi
    2857:	mov    QWORD PTR [rsp+0x8],rdx
    285c:	mov    r12,rdx
    285f:	mov    QWORD PTR [rsp+0x10],rcx
    2864:	mov    rbx,rcx
    2867:	mov    r11d,0x1
    286d:	mov    rsi,r13
    2870:	test   rsi,0x1
    2877:	jne    2897 <botlish_fn_14+0x6f>
    287d:	xor    r11d,r11d
    2880:	test   rsi,0x7
    2887:	jne    2897 <botlish_fn_14+0x6f>
    288d:	movzx  rax,BYTE PTR [rsi]
    2891:	cmp    al,0x1
    2893:	sete   r11b
    2897:	test   r11b,r11b
    289a:	jne    28bb <botlish_fn_14+0x93>
    28a0:	mov    rdi,r14
    28a3:	mov    rax,QWORD PTR [rdi+0x10]
    28a7:	mov    rcx,QWORD PTR [rax+0xb8]
    28ae:	xor    rdx,rdx
    28b1:	call   28b6 <botlish_fn_14+0x8e>
			28b2: R_X86_64_PLT32	rt_type_error-0x4
    28b6:	jmp    294a <botlish_fn_14+0x122>
    28bb:	mov    rax,rsi
    28be:	and    rax,r12
    28c1:	mov    r13,rsi
    28c4:	test   rax,0x1
    28ca:	jne    28f3 <botlish_fn_14+0xcb>
    28d0:	mov    rdx,r12
    28d3:	mov    rsi,r13
    28d6:	mov    rdi,r14
    28d9:	call   28de <botlish_fn_14+0xb6>
			28da: R_X86_64_PLT32	rt_int_cmp-0x4
    28de:	mov    ecx,0x2
    28e3:	test   rax,rax
    28e6:	cmovge rcx,QWORD PTR [rip+0x112]        # 2a00 <botlish_fn_14+0x1d8>
    28ee:	jmp    2906 <botlish_fn_14+0xde>
    28f3:	mov    ecx,0x2
    28f8:	mov    rsi,r13
    28fb:	cmp    rsi,r12
    28fe:	cmovge rcx,QWORD PTR [rip+0xfa]        # 2a00 <botlish_fn_14+0x1d8>
    2906:	cmp    rcx,0x6
    290a:	je     29de <botlish_fn_14+0x1b6>
    2910:	lea    rcx,[rsp+0x20]
    2915:	mov    rdx,rbx
    2918:	mov    rsi,r13
    291b:	mov    rdi,r14
    291e:	call   2923 <botlish_fn_14+0xfb>
			291f: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2923:	test   rax,rax
    2926:	mov    rsi,rax
    2929:	je     294a <botlish_fn_14+0x122>
    292f:	mov    rdx,QWORD PTR [rsp+0x20]
    2934:	mov    rcx,QWORD PTR [rsp+0x28]
    2939:	mov    rdi,r14
    293c:	call   2941 <botlish_fn_14+0x119>
			293d: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    2941:	test   rax,rax
    2944:	jne    296a <botlish_fn_14+0x142>
    294a:	xor    rax,rax
    294d:	mov    rbx,QWORD PTR [rsp+0x30]
    2952:	mov    r12,QWORD PTR [rsp+0x38]
    2957:	mov    r13,QWORD PTR [rsp+0x40]
    295c:	mov    r14,QWORD PTR [rsp+0x48]
    2961:	add    rsp,0x50
    2965:	mov    rsp,rbp
    2968:	pop    rbp
    2969:	ret
    296a:	cmp    rax,0x6
    296e:	je     297c <botlish_fn_14+0x154>
    2974:	mov    rax,r13
    2977:	jmp    29e1 <botlish_fn_14+0x1b9>
    297c:	mov    QWORD PTR [rsp+0x18],0x3
    2985:	mov    rsi,r13
    2988:	test   rsi,0x1
    298f:	je     29b5 <botlish_fn_14+0x18d>
    2995:	mov    rsi,r13
    2998:	mov    r11,rsi
    299b:	add    r11,0x2
    299f:	seto   al
    29a2:	test   al,al
    29a4:	jne    29b5 <botlish_fn_14+0x18d>
    29aa:	mov    rsi,r11
    29ad:	mov    r13,r11
    29b0:	jmp    29cb <botlish_fn_14+0x1a3>
    29b5:	mov    edx,0x3
    29ba:	mov    rsi,r13
    29bd:	mov    rdi,r14
    29c0:	call   29c5 <botlish_fn_14+0x19d>
			29c1: R_X86_64_PLT32	rt_int_add-0x4
    29c5:	mov    rsi,rax
    29c8:	mov    r13,rax
    29cb:	mov    QWORD PTR [rsp],rsi
    29cf:	mov    QWORD PTR [rsp+0x8],r12
    29d4:	mov    QWORD PTR [rsp+0x10],rbx
    29d9:	jmp    2867 <botlish_fn_14+0x3f>
    29de:	mov    rax,r13
    29e1:	mov    rbx,QWORD PTR [rsp+0x30]
    29e6:	mov    r12,QWORD PTR [rsp+0x38]
    29eb:	mov    r13,QWORD PTR [rsp+0x40]
    29f0:	mov    r14,QWORD PTR [rsp+0x48]
    29f5:	add    rsp,0x50
    29f9:	mov    rsp,rbp
    29fc:	pop    rbp
    29fd:	ret
    29fe:	add    BYTE PTR [rax],al
    2a00:	(bad)
    2a01:	add    BYTE PTR [rax],al
    2a03:	add    BYTE PTR [rax],al
    2a05:	add    BYTE PTR [rax],al
	...

0000000000002a08 <botlish_entry_14: scan_alpha<generic>>:
    2a08:	push   rbp
    2a09:	mov    rbp,rsp
    2a0c:	mov    rsi,QWORD PTR [rdx]
    2a0f:	mov    r8,QWORD PTR [rdx+0x8]
    2a13:	mov    rcx,QWORD PTR [rdx+0x10]
    2a17:	mov    rdx,r8
    2a1a:	call   2a1f <botlish_entry_14+0x17>
			2a1b: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_alpha<generic>
    2a1f:	mov    rsp,rbp
    2a22:	pop    rbp
    2a23:	ret
    2a24:	add    BYTE PTR [rax],al
	...

0000000000002a28 <botlish_fn_15: tld_ok<generic>>:
    2a28:	push   rbp
    2a29:	mov    rbp,rsp
    2a2c:	sub    rsp,0x40
    2a30:	mov    QWORD PTR [rsp+0x20],rbx
    2a35:	mov    QWORD PTR [rsp+0x28],r12
    2a3a:	mov    QWORD PTR [rsp+0x30],r13
    2a3f:	mov    QWORD PTR [rsp+0x38],r14
    2a44:	mov    rbx,rdi
    2a47:	mov    QWORD PTR [rsp],rsi
    2a4b:	mov    r12,rsi
    2a4e:	mov    QWORD PTR [rsp+0x8],rdx
    2a53:	mov    r14,rdx
    2a56:	mov    QWORD PTR [rsp+0x10],rcx
    2a5b:	mov    rdx,r14
    2a5e:	mov    rsi,r12
    2a61:	mov    rdi,rbx
    2a64:	call   2a69 <botlish_fn_15+0x41>
			2a65: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_alpha<generic>
    2a69:	mov    rsi,rax
    2a6c:	mov    r13,rax
    2a6f:	test   rax,rsi
    2a72:	je     2b35 <botlish_fn_15+0x10d>
    2a78:	mov    rax,r13
    2a7b:	mov    QWORD PTR [rsp+0x8],rax
    2a80:	mov    rdx,r14
    2a83:	and    rax,rdx
    2a86:	test   rax,0x1
    2a8c:	jne    2ab5 <botlish_fn_15+0x8d>
    2a92:	mov    rsi,r13
    2a95:	mov    rdi,rbx
    2a98:	call   2a9d <botlish_fn_15+0x75>
			2a99: R_X86_64_PLT32	rt_int_cmp-0x4
    2a9d:	mov    ecx,0x2
    2aa2:	test   rax,rax
    2aa5:	cmove  rcx,QWORD PTR [rip+0x15b]        # 2c08 <botlish_fn_15+0x1e0>
    2aad:	mov    rax,r13
    2ab0:	jmp    2ac8 <botlish_fn_15+0xa0>
    2ab5:	mov    ecx,0x2
    2aba:	mov    rax,r13
    2abd:	cmp    rax,rdx
    2ac0:	cmove  rcx,QWORD PTR [rip+0x140]        # 2c08 <botlish_fn_15+0x1e0>
    2ac8:	cmp    rcx,0x6
    2acc:	je     2adf <botlish_fn_15+0xb7>
    2ad2:	mov    ecx,0x2
    2ad7:	mov    rax,rcx
    2ada:	jmp    2be7 <botlish_fn_15+0x1bf>
    2adf:	mov    ecx,0x1
    2ae4:	mov    rsi,r12
    2ae7:	test   rsi,0x1
    2aee:	jne    2b14 <botlish_fn_15+0xec>
    2af4:	xor    ecx,ecx
    2af6:	mov    rsi,r12
    2af9:	test   rsi,0x7
    2b00:	jne    2b14 <botlish_fn_15+0xec>
    2b06:	mov    rsi,r12
    2b09:	movzx  rcx,BYTE PTR [rsi]
    2b0d:	rex cmp cl,0x1
    2b11:	sete   cl
    2b14:	test   cl,cl
    2b16:	jne    2b55 <botlish_fn_15+0x12d>
    2b1c:	mov    rdi,rbx
    2b1f:	mov    rsi,QWORD PTR [rdi+0x10]
    2b23:	mov    rcx,QWORD PTR [rsi+0x128]
    2b2a:	xor    rdx,rdx
    2b2d:	mov    rsi,r12
    2b30:	call   2b35 <botlish_fn_15+0x10d>
			2b31: R_X86_64_PLT32	rt_type_error-0x4
    2b35:	xor    rax,rax
    2b38:	mov    rbx,QWORD PTR [rsp+0x20]
    2b3d:	mov    r12,QWORD PTR [rsp+0x28]
    2b42:	mov    r13,QWORD PTR [rsp+0x30]
    2b47:	mov    r14,QWORD PTR [rsp+0x38]
    2b4c:	add    rsp,0x40
    2b50:	mov    rsp,rbp
    2b53:	pop    rbp
    2b54:	ret
    2b55:	mov    rsi,r12
    2b58:	mov    rdi,rax
    2b5b:	and    rdi,rsi
    2b5e:	test   rdi,0x1
    2b65:	jne    2b76 <botlish_fn_15+0x14e>
    2b6b:	mov    rdx,r12
    2b6e:	mov    rsi,rax
    2b71:	jmp    2b99 <botlish_fn_15+0x171>
    2b76:	mov    rsi,r12
    2b79:	mov    r8,rax
    2b7c:	sub    r8,rsi
    2b7f:	mov    r13,rax
    2b82:	seto   r10b
    2b86:	lea    rsi,[r8+0x1]
    2b8a:	test   r10b,r10b
    2b8d:	je     2ba4 <botlish_fn_15+0x17c>
    2b93:	mov    rdx,r12
    2b96:	mov    rsi,r13
    2b99:	mov    rdi,rbx
    2b9c:	call   2ba1 <botlish_fn_15+0x179>
			2b9d: R_X86_64_PLT32	rt_int_sub-0x4
    2ba1:	mov    rsi,rax
    2ba4:	test   rsi,0x1
    2bab:	jne    2bd6 <botlish_fn_15+0x1ae>
    2bb1:	mov    edx,0x5
    2bb6:	mov    rdi,rbx
    2bb9:	call   2bbe <botlish_fn_15+0x196>
			2bba: R_X86_64_PLT32	rt_int_cmp-0x4
    2bbe:	mov    ecx,0x2
    2bc3:	test   rax,rax
    2bc6:	mov    rax,rcx
    2bc9:	cmovge rax,QWORD PTR [rip+0x37]        # 2c08 <botlish_fn_15+0x1e0>
    2bd1:	jmp    2be7 <botlish_fn_15+0x1bf>
    2bd6:	mov    eax,0x2
    2bdb:	cmp    rsi,0x5
    2bdf:	cmovge rax,QWORD PTR [rip+0x21]        # 2c08 <botlish_fn_15+0x1e0>
    2be7:	mov    rbx,QWORD PTR [rsp+0x20]
    2bec:	mov    r12,QWORD PTR [rsp+0x28]
    2bf1:	mov    r13,QWORD PTR [rsp+0x30]
    2bf6:	mov    r14,QWORD PTR [rsp+0x38]
    2bfb:	add    rsp,0x40
    2bff:	mov    rsp,rbp
    2c02:	pop    rbp
    2c03:	ret
    2c04:	add    BYTE PTR [rax],al
    2c06:	add    BYTE PTR [rax],al
    2c08:	(bad)
    2c09:	add    BYTE PTR [rax],al
    2c0b:	add    BYTE PTR [rax],al
    2c0d:	add    BYTE PTR [rax],al
	...

0000000000002c10 <botlish_entry_15: tld_ok<generic>>:
    2c10:	push   rbp
    2c11:	mov    rbp,rsp
    2c14:	mov    rsi,QWORD PTR [rdx]
    2c17:	mov    r8,QWORD PTR [rdx+0x8]
    2c1b:	mov    rcx,QWORD PTR [rdx+0x10]
    2c1f:	mov    rdx,r8
    2c22:	call   2c27 <botlish_entry_15+0x17>
			2c23: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld_ok<generic>
    2c27:	mov    rsp,rbp
    2c2a:	pop    rbp
    2c2b:	ret
    2c2c:	add    BYTE PTR [rax],al
	...

0000000000002c30 <botlish_fn_16: domain_loop<generic>>:
    2c30:	push   rbp
    2c31:	mov    rbp,rsp
    2c34:	sub    rsp,0x70
    2c38:	mov    QWORD PTR [rsp+0x40],rbx
    2c3d:	mov    QWORD PTR [rsp+0x48],r12
    2c42:	mov    QWORD PTR [rsp+0x50],r13
    2c47:	mov    QWORD PTR [rsp+0x58],r14
    2c4c:	mov    QWORD PTR [rsp+0x60],r15
    2c51:	mov    QWORD PTR [rsp+0x18],0x0
    2c5a:	mov    QWORD PTR [rsp],rsi
    2c5e:	mov    QWORD PTR [rsp+0x8],rdx
    2c63:	mov    QWORD PTR [rsp+0x10],rcx
    2c68:	lea    rbx,[rsp+0x20]
    2c6d:	mov    r12,rdi
    2c70:	mov    r13,rcx
    2c73:	mov    r14,rdx
    2c76:	mov    QWORD PTR [rsp+0x30],rsi
    2c7b:	mov    rcx,r13
    2c7e:	mov    rdx,r14
    2c81:	mov    rsi,QWORD PTR [rsp+0x30]
    2c86:	mov    rdi,r12
    2c89:	call   2c8e <botlish_fn_16+0x5e>
			2c8a: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_label<generic>
    2c8e:	mov    rcx,rax
    2c91:	mov    r15,rax
    2c94:	test   rax,rcx
    2c97:	je     2de7 <botlish_fn_16+0x1b7>
    2c9d:	mov    rax,r15
    2ca0:	mov    QWORD PTR [rsp],rax
    2ca4:	mov    rdx,QWORD PTR [rsp+0x30]
    2ca9:	and    rax,rdx
    2cac:	test   rax,0x1
    2cb2:	jne    2cd1 <botlish_fn_16+0xa1>
    2cb8:	mov    rsi,r15
    2cbb:	mov    rdi,r12
    2cbe:	call   2cc3 <botlish_fn_16+0x93>
			2cbf: R_X86_64_PLT32	rt_value_eq-0x4
    2cc3:	test   rax,rax
    2cc6:	je     2de7 <botlish_fn_16+0x1b7>
    2ccc:	jmp    2ce1 <botlish_fn_16+0xb1>
    2cd1:	mov    eax,0x2
    2cd6:	cmp    r15,rdx
    2cd9:	cmove  rax,QWORD PTR [rip+0x187]        # 2e68 <botlish_fn_16+0x238>
    2ce1:	cmp    rax,0x6
    2ce5:	je     2e3d <botlish_fn_16+0x20d>
    2ceb:	mov    rax,r15
    2cee:	and    rax,r14
    2cf1:	test   rax,0x1
    2cf7:	jne    2d20 <botlish_fn_16+0xf0>
    2cfd:	mov    rdx,r14
    2d00:	mov    rsi,r15
    2d03:	mov    rdi,r12
    2d06:	call   2d0b <botlish_fn_16+0xdb>
			2d07: R_X86_64_PLT32	rt_int_cmp-0x4
    2d0b:	mov    ecx,0x2
    2d10:	test   rax,rax
    2d13:	cmovge rcx,QWORD PTR [rip+0x14d]        # 2e68 <botlish_fn_16+0x238>
    2d1b:	jmp    2d30 <botlish_fn_16+0x100>
    2d20:	mov    ecx,0x2
    2d25:	cmp    r15,r14
    2d28:	cmovge rcx,QWORD PTR [rip+0x138]        # 2e68 <botlish_fn_16+0x238>
    2d30:	cmp    rcx,0x6
    2d34:	je     2e2e <botlish_fn_16+0x1fe>
    2d3a:	mov    rcx,rbx
    2d3d:	mov    rdx,r13
    2d40:	mov    rsi,r15
    2d43:	mov    rdi,r12
    2d46:	call   2d4b <botlish_fn_16+0x11b>
			2d47: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2d4b:	test   rax,rax
    2d4e:	je     2de7 <botlish_fn_16+0x1b7>
    2d54:	mov    rdx,QWORD PTR [rsp+0x20]
    2d59:	mov    rcx,QWORD PTR [rsp+0x28]
    2d5e:	mov    rsi,QWORD PTR [r12+0x10]
    2d63:	mov    r8,QWORD PTR [rsi+0x118]
    2d6a:	mov    rsi,rax
    2d6d:	mov    rdi,r12
    2d70:	call   2d75 <botlish_fn_16+0x145>
			2d71: R_X86_64_PLT32	rt_str_region_eq-0x4
    2d75:	cmp    rax,0x6
    2d79:	je     2d8b <botlish_fn_16+0x15b>
    2d7f:	mov    r14,0xffffffffffffffff
    2d86:	jmp    2e35 <botlish_fn_16+0x205>
    2d8b:	mov    QWORD PTR [rsp+0x18],0x3
    2d94:	test   r15,0x1
    2d9b:	je     2db3 <botlish_fn_16+0x183>
    2da1:	mov    rdx,r15
    2da4:	add    rdx,0x2
    2da8:	seto   al
    2dab:	test   al,al
    2dad:	je     2dc6 <botlish_fn_16+0x196>
    2db3:	mov    edx,0x3
    2db8:	mov    rsi,r15
    2dbb:	mov    rdi,r12
    2dbe:	call   2dc3 <botlish_fn_16+0x193>
			2dbf: R_X86_64_PLT32	rt_int_add-0x4
    2dc3:	mov    rdx,rax
    2dc6:	mov    QWORD PTR [rsp],rdx
    2dca:	mov    r15,rdx
    2dcd:	mov    rcx,r13
    2dd0:	mov    rdx,r14
    2dd3:	mov    rsi,r15
    2dd6:	mov    rdi,r12
    2dd9:	call   2dde <botlish_fn_16+0x1ae>
			2dda: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld_ok<generic>
    2dde:	test   rax,rax
    2de1:	jne    2e0c <botlish_fn_16+0x1dc>
    2de7:	xor    rax,rax
    2dea:	mov    rbx,QWORD PTR [rsp+0x40]
    2def:	mov    r12,QWORD PTR [rsp+0x48]
    2df4:	mov    r13,QWORD PTR [rsp+0x50]
    2df9:	mov    r14,QWORD PTR [rsp+0x58]
    2dfe:	mov    r15,QWORD PTR [rsp+0x60]
    2e03:	add    rsp,0x70
    2e07:	mov    rsp,rbp
    2e0a:	pop    rbp
    2e0b:	ret
    2e0c:	cmp    rax,0x6
    2e10:	je     2e35 <botlish_fn_16+0x205>
    2e16:	mov    QWORD PTR [rsp],r15
    2e1a:	mov    QWORD PTR [rsp+0x8],r14
    2e1f:	mov    QWORD PTR [rsp+0x10],r13
    2e24:	mov    QWORD PTR [rsp+0x30],r15
    2e29:	jmp    2c7b <botlish_fn_16+0x4b>
    2e2e:	mov    r14,0xffffffffffffffff
    2e35:	mov    rax,r14
    2e38:	jmp    2e44 <botlish_fn_16+0x214>
    2e3d:	mov    rax,0xffffffffffffffff
    2e44:	mov    rbx,QWORD PTR [rsp+0x40]
    2e49:	mov    r12,QWORD PTR [rsp+0x48]
    2e4e:	mov    r13,QWORD PTR [rsp+0x50]
    2e53:	mov    r14,QWORD PTR [rsp+0x58]
    2e58:	mov    r15,QWORD PTR [rsp+0x60]
    2e5d:	add    rsp,0x70
    2e61:	mov    rsp,rbp
    2e64:	pop    rbp
    2e65:	ret
    2e66:	add    BYTE PTR [rax],al
    2e68:	(bad)
    2e69:	add    BYTE PTR [rax],al
    2e6b:	add    BYTE PTR [rax],al
    2e6d:	add    BYTE PTR [rax],al
	...

0000000000002e70 <botlish_entry_16: domain_loop<generic>>:
    2e70:	push   rbp
    2e71:	mov    rbp,rsp
    2e74:	mov    rsi,QWORD PTR [rdx]
    2e77:	mov    r8,QWORD PTR [rdx+0x8]
    2e7b:	mov    rcx,QWORD PTR [rdx+0x10]
    2e7f:	mov    rdx,r8
    2e82:	call   2e87 <botlish_entry_16+0x17>
			2e83: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain_loop<generic>
    2e87:	mov    rsp,rbp
    2e8a:	pop    rbp
    2e8b:	ret
    2e8c:	add    BYTE PTR [rax],al
	...

0000000000002e90 <botlish_fn_17: <str>>:
    2e90:	push   rbp
    2e91:	mov    rbp,rsp
    2e94:	sub    rsp,0x50
    2e98:	mov    QWORD PTR [rsp+0x30],rbx
    2e9d:	mov    QWORD PTR [rsp+0x38],r12
    2ea2:	mov    QWORD PTR [rsp+0x40],r13
    2ea7:	mov    QWORD PTR [rsp+0x48],r14
    2eac:	mov    r13,rdi
    2eaf:	mov    QWORD PTR [rsp+0x18],0x0
    2eb8:	mov    QWORD PTR [rsp],rsi
    2ebc:	mov    r14,rsi
    2ebf:	mov    rsi,r14
    2ec2:	mov    rdi,r13
    2ec5:	call   2eca <botlish_fn_17+0x3a>
			2ec6: R_X86_64_PLT32	rt_str_len-0x4
    2eca:	mov    rbx,rax
    2ecd:	mov    QWORD PTR [rsp+0x8],rax
    2ed2:	mov    esi,0x1
    2ed7:	mov    QWORD PTR [rsp+0x10],0x1
    2ee0:	mov    rcx,r14
    2ee3:	mov    rdx,rbx
    2ee6:	mov    rdi,r13
    2ee9:	call   2eee <botlish_fn_17+0x5e>
			2eea: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    2eee:	mov    r12,rax
    2ef1:	test   r12,r12
    2ef4:	je     3051 <botlish_fn_17+0x1c1>
    2efa:	mov    QWORD PTR [rsp+0x10],r12
    2eff:	test   r12,0x1
    2f06:	jne    2f31 <botlish_fn_17+0xa1>
    2f0c:	mov    edx,0x1
    2f11:	mov    rsi,r12
    2f14:	mov    rdi,r13
    2f17:	call   2f1c <botlish_fn_17+0x8c>
			2f18: R_X86_64_PLT32	rt_int_cmp-0x4
    2f1c:	mov    ecx,0x2
    2f21:	test   rax,rax
    2f24:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 30f0 <botlish_fn_17+0x260>
    2f2c:	jmp    2f42 <botlish_fn_17+0xb2>
    2f31:	mov    ecx,0x2
    2f36:	cmp    r12,0x1
    2f3a:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 30f0 <botlish_fn_17+0x260>
    2f42:	cmp    rcx,0x6
    2f46:	je     30cc <botlish_fn_17+0x23c>
    2f4c:	mov    rcx,r12
    2f4f:	and    rcx,rbx
    2f52:	test   rcx,0x1
    2f59:	jne    2f82 <botlish_fn_17+0xf2>
    2f5f:	mov    rdx,rbx
    2f62:	mov    rsi,r12
    2f65:	mov    rdi,r13
    2f68:	call   2f6d <botlish_fn_17+0xdd>
			2f69: R_X86_64_PLT32	rt_int_cmp-0x4
    2f6d:	mov    ecx,0x2
    2f72:	test   rax,rax
    2f75:	cmovge rcx,QWORD PTR [rip+0x173]        # 30f0 <botlish_fn_17+0x260>
    2f7d:	jmp    2f92 <botlish_fn_17+0x102>
    2f82:	mov    ecx,0x2
    2f87:	cmp    r12,rbx
    2f8a:	cmovge rcx,QWORD PTR [rip+0x15e]        # 30f0 <botlish_fn_17+0x260>
    2f92:	cmp    rcx,0x6
    2f96:	je     30c2 <botlish_fn_17+0x232>
    2f9c:	lea    rcx,[rsp+0x20]
    2fa1:	mov    rdx,r14
    2fa4:	mov    rsi,r12
    2fa7:	mov    rdi,r13
    2faa:	call   2faf <botlish_fn_17+0x11f>
			2fab: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    2faf:	test   rax,rax
    2fb2:	mov    rsi,rax
    2fb5:	je     3051 <botlish_fn_17+0x1c1>
    2fbb:	mov    rdx,QWORD PTR [rsp+0x20]
    2fc0:	mov    rcx,QWORD PTR [rsp+0x28]
    2fc5:	mov    rdi,r13
    2fc8:	mov    rax,QWORD PTR [rdi+0x10]
    2fcc:	mov    r8,QWORD PTR [rax+0x100]
    2fd3:	call   2fd8 <botlish_fn_17+0x148>
			2fd4: R_X86_64_PLT32	rt_str_region_eq-0x4
    2fd8:	cmp    rax,0x6
    2fdc:	je     2fef <botlish_fn_17+0x15f>
    2fe2:	mov    ecx,0x2
    2fe7:	mov    rax,rcx
    2fea:	jmp    30d1 <botlish_fn_17+0x241>
    2fef:	mov    QWORD PTR [rsp+0x18],0x3
    2ff8:	test   r12,0x1
    2fff:	jne    300d <botlish_fn_17+0x17d>
    3005:	mov    rcx,r12
    3008:	jmp    3022 <botlish_fn_17+0x192>
    300d:	mov    rsi,r12
    3010:	add    rsi,0x2
    3014:	mov    rcx,r12
    3017:	seto   al
    301a:	test   al,al
    301c:	je     3035 <botlish_fn_17+0x1a5>
    3022:	mov    edx,0x3
    3027:	mov    rsi,rcx
    302a:	mov    rdi,r13
    302d:	call   3032 <botlish_fn_17+0x1a2>
			302e: R_X86_64_PLT32	rt_int_add-0x4
    3032:	mov    rsi,rax
    3035:	mov    QWORD PTR [rsp+0x10],rsi
    303a:	mov    rcx,r14
    303d:	mov    rdx,rbx
    3040:	mov    rdi,r13
    3043:	call   3048 <botlish_fn_17+0x1b8>
			3044: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    3048:	test   rax,rax
    304b:	jne    3071 <botlish_fn_17+0x1e1>
    3051:	xor    rax,rax
    3054:	mov    rbx,QWORD PTR [rsp+0x30]
    3059:	mov    r12,QWORD PTR [rsp+0x38]
    305e:	mov    r13,QWORD PTR [rsp+0x40]
    3063:	mov    r14,QWORD PTR [rsp+0x48]
    3068:	add    rsp,0x50
    306c:	mov    rsp,rbp
    306f:	pop    rbp
    3070:	ret
    3071:	mov    rcx,rax
    3074:	and    rcx,rbx
    3077:	mov    rsi,rax
    307a:	test   rcx,0x1
    3081:	jne    30aa <botlish_fn_17+0x21a>
    3087:	mov    rdx,rbx
    308a:	mov    rdi,r13
    308d:	call   3092 <botlish_fn_17+0x202>
			308e: R_X86_64_PLT32	rt_int_cmp-0x4
    3092:	mov    ecx,0x2
    3097:	test   rax,rax
    309a:	mov    rax,rcx
    309d:	cmove  rax,QWORD PTR [rip+0x4b]        # 30f0 <botlish_fn_17+0x260>
    30a5:	jmp    30d1 <botlish_fn_17+0x241>
    30aa:	mov    rdx,rbx
    30ad:	mov    eax,0x2
    30b2:	cmp    rsi,rdx
    30b5:	cmove  rax,QWORD PTR [rip+0x33]        # 30f0 <botlish_fn_17+0x260>
    30bd:	jmp    30d1 <botlish_fn_17+0x241>
    30c2:	mov    eax,0x2
    30c7:	jmp    30d1 <botlish_fn_17+0x241>
    30cc:	mov    eax,0x2
    30d1:	mov    rbx,QWORD PTR [rsp+0x30]
    30d6:	mov    r12,QWORD PTR [rsp+0x38]
    30db:	mov    r13,QWORD PTR [rsp+0x40]
    30e0:	mov    r14,QWORD PTR [rsp+0x48]
    30e5:	add    rsp,0x50
    30e9:	mov    rsp,rbp
    30ec:	pop    rbp
    30ed:	ret
    30ee:	add    BYTE PTR [rax],al
    30f0:	(bad)
    30f1:	add    BYTE PTR [rax],al
    30f3:	add    BYTE PTR [rax],al
    30f5:	add    BYTE PTR [rax],al
	...

00000000000030f8 <botlish_entry_17: <str>>:
    30f8:	push   rbp
    30f9:	mov    rbp,rsp
    30fc:	mov    rsi,QWORD PTR [rdx]
    30ff:	call   3104 <botlish_entry_17+0xc>
			3100: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    3104:	mov    rsp,rbp
    3107:	pop    rbp
    3108:	ret
    3109:	add    BYTE PTR [rax],al
    310b:	add    BYTE PTR [rax],al
    310d:	add    BYTE PTR [rax],al
	...

0000000000003110 <botlish_fn_18: <generic>>:
    3110:	push   rbp
    3111:	mov    rbp,rsp
    3114:	sub    rsp,0x60
    3118:	mov    QWORD PTR [rsp+0x30],rbx
    311d:	mov    QWORD PTR [rsp+0x38],r12
    3122:	mov    QWORD PTR [rsp+0x40],r13
    3127:	mov    QWORD PTR [rsp+0x48],r14
    312c:	mov    QWORD PTR [rsp+0x50],r15
    3131:	mov    QWORD PTR [rsp+0x18],0x0
    313a:	mov    QWORD PTR [rsp],rsi
    313e:	xor    r8d,r8d
    3141:	test   rsi,0x7
    3148:	jne    3158 <botlish_fn_18+0x48>
    314e:	movzx  rax,BYTE PTR [rsi]
    3152:	cmp    al,0x2
    3154:	sete   r8b
    3158:	test   r8b,r8b
    315b:	jne    317b <botlish_fn_18+0x6b>
    3161:	mov    rdx,QWORD PTR [rdi+0x10]
    3165:	mov    rcx,QWORD PTR [rdx+0xd8]
    316c:	mov    edx,0x1
    3171:	call   3176 <botlish_fn_18+0x66>
			3172: R_X86_64_PLT32	rt_type_error-0x4
    3176:	jmp    3310 <botlish_fn_18+0x200>
    317b:	mov    r13,rsi
    317e:	mov    r14,rdi
    3181:	call   3186 <botlish_fn_18+0x76>
			3182: R_X86_64_PLT32	rt_str_len-0x4
    3186:	mov    rbx,rax
    3189:	mov    QWORD PTR [rsp+0x8],rax
    318e:	mov    edx,0x1
    3193:	mov    r15,rdx
    3196:	mov    QWORD PTR [rsp+0x10],0x1
    319f:	mov    rcx,r13
    31a2:	mov    rdx,rbx
    31a5:	mov    rsi,r15
    31a8:	mov    rdi,r14
    31ab:	call   31b0 <botlish_fn_18+0xa0>
			31ac: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    31b0:	mov    r12,rax
    31b3:	test   r12,r12
    31b6:	je     3310 <botlish_fn_18+0x200>
    31bc:	mov    QWORD PTR [rsp+0x10],r12
    31c1:	test   r12,0x1
    31c8:	jne    31f1 <botlish_fn_18+0xe1>
    31ce:	mov    rdx,r15
    31d1:	mov    rsi,r12
    31d4:	mov    rdi,r14
    31d7:	call   31dc <botlish_fn_18+0xcc>
			31d8: R_X86_64_PLT32	rt_int_cmp-0x4
    31dc:	mov    ecx,0x2
    31e1:	test   rax,rax
    31e4:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 33b8 <botlish_fn_18+0x2a8>
    31ec:	jmp    3202 <botlish_fn_18+0xf2>
    31f1:	mov    ecx,0x2
    31f6:	cmp    r12,0x1
    31fa:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 33b8 <botlish_fn_18+0x2a8>
    3202:	cmp    rcx,0x6
    3206:	je     3390 <botlish_fn_18+0x280>
    320c:	mov    rax,r12
    320f:	and    rax,rbx
    3212:	test   rax,0x1
    3218:	jne    3241 <botlish_fn_18+0x131>
    321e:	mov    rdx,rbx
    3221:	mov    rsi,r12
    3224:	mov    rdi,r14
    3227:	call   322c <botlish_fn_18+0x11c>
			3228: R_X86_64_PLT32	rt_int_cmp-0x4
    322c:	mov    ecx,0x2
    3231:	test   rax,rax
    3234:	cmovge rcx,QWORD PTR [rip+0x17c]        # 33b8 <botlish_fn_18+0x2a8>
    323c:	jmp    3251 <botlish_fn_18+0x141>
    3241:	mov    ecx,0x2
    3246:	cmp    r12,rbx
    3249:	cmovge rcx,QWORD PTR [rip+0x167]        # 33b8 <botlish_fn_18+0x2a8>
    3251:	cmp    rcx,0x6
    3255:	je     3386 <botlish_fn_18+0x276>
    325b:	lea    rcx,[rsp+0x20]
    3260:	mov    rdx,r13
    3263:	mov    rsi,r12
    3266:	mov    rdi,r14
    3269:	call   326e <botlish_fn_18+0x15e>
			326a: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    326e:	test   rax,rax
    3271:	mov    rsi,rax
    3274:	je     3310 <botlish_fn_18+0x200>
    327a:	mov    rdx,QWORD PTR [rsp+0x20]
    327f:	mov    rcx,QWORD PTR [rsp+0x28]
    3284:	mov    rdi,r14
    3287:	mov    rax,QWORD PTR [rdi+0x10]
    328b:	mov    r8,QWORD PTR [rax+0x100]
    3292:	call   3297 <botlish_fn_18+0x187>
			3293: R_X86_64_PLT32	rt_str_region_eq-0x4
    3297:	cmp    rax,0x6
    329b:	je     32ae <botlish_fn_18+0x19e>
    32a1:	mov    ecx,0x2
    32a6:	mov    rax,rcx
    32a9:	jmp    3395 <botlish_fn_18+0x285>
    32ae:	mov    QWORD PTR [rsp+0x18],0x3
    32b7:	test   r12,0x1
    32be:	jne    32cc <botlish_fn_18+0x1bc>
    32c4:	mov    rdi,r12
    32c7:	jmp    32e1 <botlish_fn_18+0x1d1>
    32cc:	mov    rsi,r12
    32cf:	add    rsi,0x2
    32d3:	mov    rdi,r12
    32d6:	seto   al
    32d9:	test   al,al
    32db:	je     32f4 <botlish_fn_18+0x1e4>
    32e1:	mov    edx,0x3
    32e6:	mov    rsi,rdi
    32e9:	mov    rdi,r14
    32ec:	call   32f1 <botlish_fn_18+0x1e1>
			32ed: R_X86_64_PLT32	rt_int_add-0x4
    32f1:	mov    rsi,rax
    32f4:	mov    QWORD PTR [rsp+0x10],rsi
    32f9:	mov    rcx,r13
    32fc:	mov    rdx,rbx
    32ff:	mov    rdi,r14
    3302:	call   3307 <botlish_fn_18+0x1f7>
			3303: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    3307:	test   rax,rax
    330a:	jne    3335 <botlish_fn_18+0x225>
    3310:	xor    rax,rax
    3313:	mov    rbx,QWORD PTR [rsp+0x30]
    3318:	mov    r12,QWORD PTR [rsp+0x38]
    331d:	mov    r13,QWORD PTR [rsp+0x40]
    3322:	mov    r14,QWORD PTR [rsp+0x48]
    3327:	mov    r15,QWORD PTR [rsp+0x50]
    332c:	add    rsp,0x60
    3330:	mov    rsp,rbp
    3333:	pop    rbp
    3334:	ret
    3335:	mov    rcx,rax
    3338:	and    rcx,rbx
    333b:	mov    rsi,rax
    333e:	test   rcx,0x1
    3345:	jne    336e <botlish_fn_18+0x25e>
    334b:	mov    rdx,rbx
    334e:	mov    rdi,r14
    3351:	call   3356 <botlish_fn_18+0x246>
			3352: R_X86_64_PLT32	rt_int_cmp-0x4
    3356:	mov    ecx,0x2
    335b:	test   rax,rax
    335e:	mov    rax,rcx
    3361:	cmove  rax,QWORD PTR [rip+0x4f]        # 33b8 <botlish_fn_18+0x2a8>
    3369:	jmp    3395 <botlish_fn_18+0x285>
    336e:	mov    rdx,rbx
    3371:	mov    eax,0x2
    3376:	cmp    rsi,rdx
    3379:	cmove  rax,QWORD PTR [rip+0x37]        # 33b8 <botlish_fn_18+0x2a8>
    3381:	jmp    3395 <botlish_fn_18+0x285>
    3386:	mov    eax,0x2
    338b:	jmp    3395 <botlish_fn_18+0x285>
    3390:	mov    eax,0x2
    3395:	mov    rbx,QWORD PTR [rsp+0x30]
    339a:	mov    r12,QWORD PTR [rsp+0x38]
    339f:	mov    r13,QWORD PTR [rsp+0x40]
    33a4:	mov    r14,QWORD PTR [rsp+0x48]
    33a9:	mov    r15,QWORD PTR [rsp+0x50]
    33ae:	add    rsp,0x60
    33b2:	mov    rsp,rbp
    33b5:	pop    rbp
    33b6:	ret
    33b7:	add    BYTE PTR [rsi],al
    33b9:	add    BYTE PTR [rax],al
    33bb:	add    BYTE PTR [rax],al
    33bd:	add    BYTE PTR [rax],al
	...

00000000000033c0 <botlish_entry_18: <generic>>:
    33c0:	push   rbp
    33c1:	mov    rbp,rsp
    33c4:	mov    rsi,QWORD PTR [rdx]
    33c7:	call   33cc <botlish_entry_18+0xc>
			33c8: R_X86_64_PLT32	botlish_fn_18-0x4 ; <generic>
    33cc:	mov    rsp,rbp
    33cf:	pop    rbp
    33d0:	ret

00000000000033d1 <botlish_fn_19: char_at<generic>>:
    33d1:	push   rbp
    33d2:	mov    rbp,rsp
    33d5:	sub    rsp,0x50
    33d9:	mov    QWORD PTR [rsp+0x20],rbx
    33de:	mov    QWORD PTR [rsp+0x28],r12
    33e3:	mov    QWORD PTR [rsp+0x30],r13
    33e8:	mov    QWORD PTR [rsp+0x38],r14
    33ed:	mov    QWORD PTR [rsp+0x40],r15
    33f2:	mov    r14,rcx
    33f5:	mov    QWORD PTR [rsp],rsi
    33f9:	mov    QWORD PTR [rsp+0x8],rdx
    33fe:	mov    r13,rdx
    3401:	mov    QWORD PTR [rsp+0x10],0x3
    340a:	mov    r9d,0x1
    3410:	test   rsi,0x1
    3417:	jne    3437 <botlish_fn_19+0x66>
    341d:	xor    r9d,r9d
    3420:	test   rsi,0x7
    3427:	jne    3437 <botlish_fn_19+0x66>
    342d:	movzx  rax,BYTE PTR [rsi]
    3431:	cmp    al,0x1
    3433:	sete   r9b
    3437:	test   r9b,r9b
    343a:	jne    3458 <botlish_fn_19+0x87>
    3440:	mov    rax,QWORD PTR [rdi+0x10]
    3444:	mov    rcx,QWORD PTR [rax+0x108]
    344b:	xor    rdx,rdx
    344e:	call   3453 <botlish_fn_19+0x82>
			344f: R_X86_64_PLT32	rt_type_error-0x4
    3453:	jmp    3515 <botlish_fn_19+0x144>
    3458:	mov    r12,rdi
    345b:	test   rsi,0x1
    3462:	jne    3470 <botlish_fn_19+0x9f>
    3468:	mov    rbx,rsi
    346b:	jmp    348d <botlish_fn_19+0xbc>
    3470:	mov    rax,rsi
    3473:	add    rax,0x2
    3477:	mov    rbx,rsi
    347a:	seto   cl
    347d:	test   cl,cl
    347f:	jne    348d <botlish_fn_19+0xbc>
    3485:	mov    r15,rax
    3488:	jmp    34a0 <botlish_fn_19+0xcf>
    348d:	mov    edx,0x3
    3492:	mov    rsi,rbx
    3495:	mov    rdi,r12
    3498:	call   349d <botlish_fn_19+0xcc>
			3499: R_X86_64_PLT32	rt_int_add-0x4
    349d:	mov    r15,rax
    34a0:	mov    ecx,0x1
    34a5:	mov    rsi,rbx
    34a8:	test   rsi,0x1
    34af:	jne    34d5 <botlish_fn_19+0x104>
    34b5:	xor    ecx,ecx
    34b7:	mov    rsi,rbx
    34ba:	test   rsi,0x7
    34c1:	jne    34d5 <botlish_fn_19+0x104>
    34c7:	mov    rsi,rbx
    34ca:	movzx  rcx,BYTE PTR [rsi]
    34ce:	rex cmp cl,0x1
    34d2:	sete   cl
    34d5:	test   cl,cl
    34d7:	jne    34fb <botlish_fn_19+0x12a>
    34dd:	mov    rdi,r12
    34e0:	mov    rsi,QWORD PTR [rdi+0x10]
    34e4:	mov    rcx,QWORD PTR [rsi+0x110]
    34eb:	xor    rdx,rdx
    34ee:	mov    rsi,rbx
    34f1:	call   34f6 <botlish_fn_19+0x125>
			34f2: R_X86_64_PLT32	rt_type_error-0x4
    34f6:	jmp    3515 <botlish_fn_19+0x144>
    34fb:	mov    rdi,r12
    34fe:	mov    rcx,r15
    3501:	mov    rdx,rbx
    3504:	mov    rsi,r13
    3507:	call   350c <botlish_fn_19+0x13b>
			3508: R_X86_64_PLT32	rt_str_region_check-0x4
    350c:	test   rax,rax
    350f:	jne    353a <botlish_fn_19+0x169>
    3515:	xor    rax,rax
    3518:	mov    rbx,QWORD PTR [rsp+0x20]
    351d:	mov    r12,QWORD PTR [rsp+0x28]
    3522:	mov    r13,QWORD PTR [rsp+0x30]
    3527:	mov    r14,QWORD PTR [rsp+0x38]
    352c:	mov    r15,QWORD PTR [rsp+0x40]
    3531:	add    rsp,0x50
    3535:	mov    rsp,rbp
    3538:	pop    rbp
    3539:	ret
    353a:	mov    rcx,r14
    353d:	mov    rsi,rbx
    3540:	mov    QWORD PTR [rcx],rsi
    3543:	mov    rax,r15
    3546:	mov    QWORD PTR [rcx+0x8],rax
    354a:	mov    rax,r13
    354d:	mov    rbx,QWORD PTR [rsp+0x20]
    3552:	mov    r12,QWORD PTR [rsp+0x28]
    3557:	mov    r13,QWORD PTR [rsp+0x30]
    355c:	mov    r14,QWORD PTR [rsp+0x38]
    3561:	mov    r15,QWORD PTR [rsp+0x40]
    3566:	add    rsp,0x50
    356a:	mov    rsp,rbp
    356d:	pop    rbp
    356e:	ret

000000000000356f <botlish_entry_19: char_at<generic>>:
    356f:	push   rbp
    3570:	mov    rbp,rsp
    3573:	ud2
    3575:	add    BYTE PTR [rax],al
	...

0000000000003578 <botlish_fn_20: scan_local<generic>>:
    3578:	push   rbp
    3579:	mov    rbp,rsp
    357c:	sub    rsp,0x80
    3583:	mov    QWORD PTR [rsp+0x50],rbx
    3588:	mov    QWORD PTR [rsp+0x58],r12
    358d:	mov    QWORD PTR [rsp+0x60],r13
    3592:	mov    QWORD PTR [rsp+0x68],r14
    3597:	mov    QWORD PTR [rsp+0x70],r15
    359c:	mov    rax,rdi
    359f:	mov    QWORD PTR [rsp+0x18],0x0
    35a8:	mov    QWORD PTR [rsp],rsi
    35ac:	mov    r14,rsi
    35af:	mov    QWORD PTR [rsp+0x8],rdx
    35b4:	mov    QWORD PTR [rsp+0x10],rcx
    35b9:	mov    r12,rcx
    35bc:	mov    r11d,0x1
    35c2:	mov    rsi,r14
    35c5:	test   rsi,0x1
    35cc:	jne    35ee <botlish_fn_20+0x76>
    35d2:	xor    r11d,r11d
    35d5:	test   rsi,0x7
    35dc:	jne    35ee <botlish_fn_20+0x76>
    35e2:	movzx  rdi,BYTE PTR [rsi]
    35e6:	cmp    dil,0x1
    35ea:	sete   r11b
    35ee:	test   r11b,r11b
    35f1:	jne    3612 <botlish_fn_20+0x9a>
    35f7:	mov    rdi,rax
    35fa:	mov    r9,QWORD PTR [rdi+0x10]
    35fe:	mov    rcx,QWORD PTR [r9+0xb8]
    3605:	xor    rdx,rdx
    3608:	call   360d <botlish_fn_20+0x95>
			3609: R_X86_64_PLT32	rt_type_error-0x4
    360d:	jmp    36c5 <botlish_fn_20+0x14d>
    3612:	mov    r13,rdx
    3615:	mov    r10,rsi
    3618:	and    r10,r13
    361b:	mov    r14,rsi
    361e:	test   r10,0x1
    3625:	jne    3651 <botlish_fn_20+0xd9>
    362b:	mov    rbx,rax
    362e:	mov    rdx,r13
    3631:	mov    rsi,r14
    3634:	mov    rdi,rbx
    3637:	call   363c <botlish_fn_20+0xc4>
			3638: R_X86_64_PLT32	rt_int_cmp-0x4
    363c:	mov    ecx,0x2
    3641:	test   rax,rax
    3644:	cmovge rcx,QWORD PTR [rip+0x24c]        # 3898 <botlish_fn_20+0x320>
    364c:	jmp    3667 <botlish_fn_20+0xef>
    3651:	mov    rbx,rax
    3654:	mov    ecx,0x2
    3659:	mov    rsi,r14
    365c:	cmp    rsi,r13
    365f:	cmovge rcx,QWORD PTR [rip+0x231]        # 3898 <botlish_fn_20+0x320>
    3667:	mov    eax,0x6
    366c:	mov    QWORD PTR [rsp+0x30],rax
    3671:	cmp    rcx,0x6
    3675:	je     386b <botlish_fn_20+0x2f3>
    367b:	lea    rcx,[rsp+0x20]
    3680:	mov    rdx,r12
    3683:	mov    rsi,r14
    3686:	mov    rdi,rbx
    3689:	call   368e <botlish_fn_20+0x116>
			368a: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    368e:	mov    rsi,rax
    3691:	mov    r15,rax
    3694:	test   rax,rsi
    3697:	je     36c5 <botlish_fn_20+0x14d>
    369d:	mov    rdx,QWORD PTR [rsp+0x20]
    36a2:	mov    QWORD PTR [rsp+0x40],rdx
    36a7:	mov    rcx,QWORD PTR [rsp+0x28]
    36ac:	mov    QWORD PTR [rsp+0x38],rcx
    36b1:	mov    rsi,r15
    36b4:	mov    rdi,rbx
    36b7:	call   36bc <botlish_fn_20+0x144>
			36b8: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    36bc:	test   rax,rax
    36bf:	jne    36ed <botlish_fn_20+0x175>
    36c5:	xor    rax,rax
    36c8:	mov    rbx,QWORD PTR [rsp+0x50]
    36cd:	mov    r12,QWORD PTR [rsp+0x58]
    36d2:	mov    r13,QWORD PTR [rsp+0x60]
    36d7:	mov    r14,QWORD PTR [rsp+0x68]
    36dc:	mov    r15,QWORD PTR [rsp+0x70]
    36e1:	add    rsp,0x80
    36e8:	mov    rsp,rbp
    36eb:	pop    rbp
    36ec:	ret
    36ed:	cmp    rax,0x6
    36f1:	je     37ec <botlish_fn_20+0x274>
    36f7:	mov    rax,QWORD PTR [rbx+0x10]
    36fb:	mov    r8,QWORD PTR [rax+0x118]
    3702:	mov    rcx,QWORD PTR [rsp+0x38]
    3707:	mov    rdx,QWORD PTR [rsp+0x40]
    370c:	mov    rsi,r15
    370f:	mov    rdi,rbx
    3712:	call   3717 <botlish_fn_20+0x19f>
			3713: R_X86_64_PLT32	rt_str_region_eq-0x4
    3717:	cmp    rax,0x6
    371b:	je     37e2 <botlish_fn_20+0x26a>
    3721:	mov    rax,QWORD PTR [rbx+0x10]
    3725:	mov    r8,QWORD PTR [rax+0x120]
    372c:	mov    rcx,QWORD PTR [rsp+0x38]
    3731:	mov    rdx,QWORD PTR [rsp+0x40]
    3736:	mov    rsi,r15
    3739:	mov    rdi,rbx
    373c:	call   3741 <botlish_fn_20+0x1c9>
			373d: R_X86_64_PLT32	rt_str_region_eq-0x4
    3741:	cmp    rax,0x6
    3745:	je     37d8 <botlish_fn_20+0x260>
    374b:	mov    rax,QWORD PTR [rbx+0x10]
    374f:	mov    r8,QWORD PTR [rax+0xc0]
    3756:	mov    rcx,QWORD PTR [rsp+0x38]
    375b:	mov    rdx,QWORD PTR [rsp+0x40]
    3760:	mov    rsi,r15
    3763:	mov    rdi,rbx
    3766:	call   376b <botlish_fn_20+0x1f3>
			3767: R_X86_64_PLT32	rt_str_region_eq-0x4
    376b:	cmp    rax,0x6
    376f:	je     37ce <botlish_fn_20+0x256>
    3775:	mov    rax,QWORD PTR [rbx+0x10]
    3779:	mov    r8,QWORD PTR [rax+0x108]
    3780:	mov    rcx,QWORD PTR [rsp+0x38]
    3785:	mov    rdx,QWORD PTR [rsp+0x40]
    378a:	mov    rsi,r15
    378d:	mov    rdi,rbx
    3790:	call   3795 <botlish_fn_20+0x21d>
			3791: R_X86_64_PLT32	rt_str_region_eq-0x4
    3795:	cmp    rax,0x6
    3799:	je     37c4 <botlish_fn_20+0x24c>
    379f:	mov    rax,QWORD PTR [rbx+0x10]
    37a3:	mov    r8,QWORD PTR [rax+0x128]
    37aa:	mov    rcx,QWORD PTR [rsp+0x38]
    37af:	mov    rdx,QWORD PTR [rsp+0x40]
    37b4:	mov    rsi,r15
    37b7:	mov    rdi,rbx
    37ba:	call   37bf <botlish_fn_20+0x247>
			37bb: R_X86_64_PLT32	rt_str_region_eq-0x4
    37bf:	jmp    37f1 <botlish_fn_20+0x279>
    37c4:	mov    rax,QWORD PTR [rsp+0x30]
    37c9:	jmp    37f1 <botlish_fn_20+0x279>
    37ce:	mov    rax,QWORD PTR [rsp+0x30]
    37d3:	jmp    37f1 <botlish_fn_20+0x279>
    37d8:	mov    rax,QWORD PTR [rsp+0x30]
    37dd:	jmp    37f1 <botlish_fn_20+0x279>
    37e2:	mov    rax,QWORD PTR [rsp+0x30]
    37e7:	jmp    37f1 <botlish_fn_20+0x279>
    37ec:	mov    rax,QWORD PTR [rsp+0x30]
    37f1:	cmp    rax,0x6
    37f5:	je     3803 <botlish_fn_20+0x28b>
    37fb:	mov    rax,r14
    37fe:	jmp    386e <botlish_fn_20+0x2f6>
    3803:	mov    QWORD PTR [rsp+0x18],0x3
    380c:	mov    rsi,r14
    380f:	test   rsi,0x1
    3816:	je     383c <botlish_fn_20+0x2c4>
    381c:	mov    rsi,r14
    381f:	mov    rax,rsi
    3822:	add    rax,0x2
    3826:	seto   cl
    3829:	test   cl,cl
    382b:	jne    383c <botlish_fn_20+0x2c4>
    3831:	mov    rsi,rax
    3834:	mov    r14,rax
    3837:	jmp    3852 <botlish_fn_20+0x2da>
    383c:	mov    edx,0x3
    3841:	mov    rsi,r14
    3844:	mov    rdi,rbx
    3847:	call   384c <botlish_fn_20+0x2d4>
			3848: R_X86_64_PLT32	rt_int_add-0x4
    384c:	mov    rsi,rax
    384f:	mov    r14,rax
    3852:	mov    QWORD PTR [rsp],rsi
    3856:	mov    QWORD PTR [rsp+0x8],r13
    385b:	mov    QWORD PTR [rsp+0x10],r12
    3860:	mov    rax,rbx
    3863:	mov    rdx,r13
    3866:	jmp    35bc <botlish_fn_20+0x44>
    386b:	mov    rax,r14
    386e:	mov    rbx,QWORD PTR [rsp+0x50]
    3873:	mov    r12,QWORD PTR [rsp+0x58]
    3878:	mov    r13,QWORD PTR [rsp+0x60]
    387d:	mov    r14,QWORD PTR [rsp+0x68]
    3882:	mov    r15,QWORD PTR [rsp+0x70]
    3887:	add    rsp,0x80
    388e:	mov    rsp,rbp
    3891:	pop    rbp
    3892:	ret
    3893:	add    BYTE PTR [rax],al
    3895:	add    BYTE PTR [rax],al
    3897:	add    BYTE PTR [rsi],al
    3899:	add    BYTE PTR [rax],al
    389b:	add    BYTE PTR [rax],al
    389d:	add    BYTE PTR [rax],al
	...

00000000000038a0 <botlish_entry_20: scan_local<generic>>:
    38a0:	push   rbp
    38a1:	mov    rbp,rsp
    38a4:	mov    rsi,QWORD PTR [rdx]
    38a7:	mov    r8,QWORD PTR [rdx+0x8]
    38ab:	mov    rcx,QWORD PTR [rdx+0x10]
    38af:	mov    rdx,r8
    38b2:	call   38b7 <botlish_entry_20+0x17>
			38b3: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    38b7:	mov    rsp,rbp
    38ba:	pop    rbp
    38bb:	ret
    38bc:	add    BYTE PTR [rax],al
	...

00000000000038c0 <botlish_fn_21: scan_label<generic>>:
    38c0:	push   rbp
    38c1:	mov    rbp,rsp
    38c4:	sub    rsp,0x80
    38cb:	mov    QWORD PTR [rsp+0x50],rbx
    38d0:	mov    QWORD PTR [rsp+0x58],r12
    38d5:	mov    QWORD PTR [rsp+0x60],r13
    38da:	mov    QWORD PTR [rsp+0x68],r14
    38df:	mov    QWORD PTR [rsp+0x70],r15
    38e4:	mov    QWORD PTR [rsp+0x18],0x0
    38ed:	mov    QWORD PTR [rsp],rsi
    38f1:	mov    r14,rsi
    38f4:	mov    QWORD PTR [rsp+0x8],rdx
    38f9:	mov    QWORD PTR [rsp+0x10],rcx
    38fe:	mov    r12,rcx
    3901:	mov    r11d,0x1
    3907:	mov    rsi,r14
    390a:	test   rsi,0x1
    3911:	jne    3931 <botlish_fn_21+0x71>
    3917:	xor    r11d,r11d
    391a:	test   rsi,0x7
    3921:	jne    3931 <botlish_fn_21+0x71>
    3927:	movzx  rax,BYTE PTR [rsi]
    392b:	cmp    al,0x1
    392d:	sete   r11b
    3931:	test   r11b,r11b
    3934:	jne    3952 <botlish_fn_21+0x92>
    393a:	mov    rax,QWORD PTR [rdi+0x10]
    393e:	mov    rcx,QWORD PTR [rax+0xb8]
    3945:	xor    rdx,rdx
    3948:	call   394d <botlish_fn_21+0x8d>
			3949: R_X86_64_PLT32	rt_type_error-0x4
    394d:	jmp    39fe <botlish_fn_21+0x13e>
    3952:	mov    r13,rdx
    3955:	mov    rax,rsi
    3958:	and    rax,r13
    395b:	mov    r14,rsi
    395e:	test   rax,0x1
    3964:	jne    398d <botlish_fn_21+0xcd>
    396a:	mov    rbx,rdi
    396d:	mov    rdx,r13
    3970:	mov    rsi,r14
    3973:	call   3978 <botlish_fn_21+0xb8>
			3974: R_X86_64_PLT32	rt_int_cmp-0x4
    3978:	mov    ecx,0x2
    397d:	test   rax,rax
    3980:	cmovge rcx,QWORD PTR [rip+0x178]        # 3b00 <botlish_fn_21+0x240>
    3988:	jmp    39a3 <botlish_fn_21+0xe3>
    398d:	mov    rbx,rdi
    3990:	mov    ecx,0x2
    3995:	mov    rsi,r14
    3998:	cmp    rsi,r13
    399b:	cmovge rcx,QWORD PTR [rip+0x15d]        # 3b00 <botlish_fn_21+0x240>
    39a3:	mov    eax,0x6
    39a8:	mov    QWORD PTR [rsp+0x30],rax
    39ad:	cmp    rcx,0x6
    39b1:	je     3ad4 <botlish_fn_21+0x214>
    39b7:	lea    rcx,[rsp+0x20]
    39bc:	mov    rdx,r12
    39bf:	mov    rsi,r14
    39c2:	mov    rdi,rbx
    39c5:	call   39ca <botlish_fn_21+0x10a>
			39c6: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    39ca:	test   rax,rax
    39cd:	mov    r15,rax
    39d0:	je     39fe <botlish_fn_21+0x13e>
    39d6:	mov    rdx,QWORD PTR [rsp+0x20]
    39db:	mov    QWORD PTR [rsp+0x40],rdx
    39e0:	mov    rcx,QWORD PTR [rsp+0x28]
    39e5:	mov    QWORD PTR [rsp+0x38],rcx
    39ea:	mov    rsi,r15
    39ed:	mov    rdi,rbx
    39f0:	call   39f5 <botlish_fn_21+0x135>
			39f1: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    39f5:	test   rax,rax
    39f8:	jne    3a26 <botlish_fn_21+0x166>
    39fe:	xor    rax,rax
    3a01:	mov    rbx,QWORD PTR [rsp+0x50]
    3a06:	mov    r12,QWORD PTR [rsp+0x58]
    3a0b:	mov    r13,QWORD PTR [rsp+0x60]
    3a10:	mov    r14,QWORD PTR [rsp+0x68]
    3a15:	mov    r15,QWORD PTR [rsp+0x70]
    3a1a:	add    rsp,0x80
    3a21:	mov    rsp,rbp
    3a24:	pop    rbp
    3a25:	ret
    3a26:	cmp    rax,0x6
    3a2a:	je     3a55 <botlish_fn_21+0x195>
    3a30:	mov    r11,QWORD PTR [rbx+0x10]
    3a34:	mov    r8,QWORD PTR [r11+0x128]
    3a3b:	mov    rcx,QWORD PTR [rsp+0x38]
    3a40:	mov    rdx,QWORD PTR [rsp+0x40]
    3a45:	mov    rsi,r15
    3a48:	mov    rdi,rbx
    3a4b:	call   3a50 <botlish_fn_21+0x190>
			3a4c: R_X86_64_PLT32	rt_str_region_eq-0x4
    3a50:	jmp    3a5a <botlish_fn_21+0x19a>
    3a55:	mov    rax,QWORD PTR [rsp+0x30]
    3a5a:	cmp    rax,0x6
    3a5e:	je     3a6c <botlish_fn_21+0x1ac>
    3a64:	mov    rax,r14
    3a67:	jmp    3ad7 <botlish_fn_21+0x217>
    3a6c:	mov    QWORD PTR [rsp+0x18],0x3
    3a75:	mov    rsi,r14
    3a78:	test   rsi,0x1
    3a7f:	je     3aa5 <botlish_fn_21+0x1e5>
    3a85:	mov    rsi,r14
    3a88:	mov    rax,rsi
    3a8b:	add    rax,0x2
    3a8f:	seto   cl
    3a92:	test   cl,cl
    3a94:	jne    3aa5 <botlish_fn_21+0x1e5>
    3a9a:	mov    rsi,rax
    3a9d:	mov    r14,rax
    3aa0:	jmp    3abb <botlish_fn_21+0x1fb>
    3aa5:	mov    edx,0x3
    3aaa:	mov    rsi,r14
    3aad:	mov    rdi,rbx
    3ab0:	call   3ab5 <botlish_fn_21+0x1f5>
			3ab1: R_X86_64_PLT32	rt_int_add-0x4
    3ab5:	mov    rsi,rax
    3ab8:	mov    r14,rax
    3abb:	mov    QWORD PTR [rsp],rsi
    3abf:	mov    QWORD PTR [rsp+0x8],r13
    3ac4:	mov    QWORD PTR [rsp+0x10],r12
    3ac9:	mov    rdx,r13
    3acc:	mov    rdi,rbx
    3acf:	jmp    3901 <botlish_fn_21+0x41>
    3ad4:	mov    rax,r14
    3ad7:	mov    rbx,QWORD PTR [rsp+0x50]
    3adc:	mov    r12,QWORD PTR [rsp+0x58]
    3ae1:	mov    r13,QWORD PTR [rsp+0x60]
    3ae6:	mov    r14,QWORD PTR [rsp+0x68]
    3aeb:	mov    r15,QWORD PTR [rsp+0x70]
    3af0:	add    rsp,0x80
    3af7:	mov    rsp,rbp
    3afa:	pop    rbp
    3afb:	ret
    3afc:	add    BYTE PTR [rax],al
    3afe:	add    BYTE PTR [rax],al
    3b00:	(bad)
    3b01:	add    BYTE PTR [rax],al
    3b03:	add    BYTE PTR [rax],al
    3b05:	add    BYTE PTR [rax],al
	...

0000000000003b08 <botlish_entry_21: scan_label<generic>>:
    3b08:	push   rbp
    3b09:	mov    rbp,rsp
    3b0c:	mov    rsi,QWORD PTR [rdx]
    3b0f:	mov    r8,QWORD PTR [rdx+0x8]
    3b13:	mov    rcx,QWORD PTR [rdx+0x10]
    3b17:	mov    rdx,r8
    3b1a:	call   3b1f <botlish_entry_21+0x17>
			3b1b: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    3b1f:	mov    rsp,rbp
    3b22:	pop    rbp
    3b23:	ret
    3b24:	add    BYTE PTR [rax],al
	...

0000000000003b28 <botlish_fn_22: scan_alpha<generic>>:
    3b28:	push   rbp
    3b29:	mov    rbp,rsp
    3b2c:	sub    rsp,0x50
    3b30:	mov    QWORD PTR [rsp+0x30],rbx
    3b35:	mov    QWORD PTR [rsp+0x38],r12
    3b3a:	mov    QWORD PTR [rsp+0x40],r13
    3b3f:	mov    QWORD PTR [rsp+0x48],r14
    3b44:	mov    r14,rdi
    3b47:	mov    QWORD PTR [rsp+0x18],0x0
    3b50:	mov    QWORD PTR [rsp],rsi
    3b54:	mov    r13,rsi
    3b57:	mov    QWORD PTR [rsp+0x8],rdx
    3b5c:	mov    r12,rdx
    3b5f:	mov    QWORD PTR [rsp+0x10],rcx
    3b64:	mov    rbx,rcx
    3b67:	mov    r11d,0x1
    3b6d:	mov    rsi,r13
    3b70:	test   rsi,0x1
    3b77:	jne    3b97 <botlish_fn_22+0x6f>
    3b7d:	xor    r11d,r11d
    3b80:	test   rsi,0x7
    3b87:	jne    3b97 <botlish_fn_22+0x6f>
    3b8d:	movzx  rax,BYTE PTR [rsi]
    3b91:	cmp    al,0x1
    3b93:	sete   r11b
    3b97:	test   r11b,r11b
    3b9a:	jne    3bbb <botlish_fn_22+0x93>
    3ba0:	mov    rdi,r14
    3ba3:	mov    rax,QWORD PTR [rdi+0x10]
    3ba7:	mov    rcx,QWORD PTR [rax+0xb8]
    3bae:	xor    rdx,rdx
    3bb1:	call   3bb6 <botlish_fn_22+0x8e>
			3bb2: R_X86_64_PLT32	rt_type_error-0x4
    3bb6:	jmp    3c4a <botlish_fn_22+0x122>
    3bbb:	mov    rax,rsi
    3bbe:	and    rax,r12
    3bc1:	mov    r13,rsi
    3bc4:	test   rax,0x1
    3bca:	jne    3bf3 <botlish_fn_22+0xcb>
    3bd0:	mov    rdx,r12
    3bd3:	mov    rsi,r13
    3bd6:	mov    rdi,r14
    3bd9:	call   3bde <botlish_fn_22+0xb6>
			3bda: R_X86_64_PLT32	rt_int_cmp-0x4
    3bde:	mov    ecx,0x2
    3be3:	test   rax,rax
    3be6:	cmovge rcx,QWORD PTR [rip+0x112]        # 3d00 <botlish_fn_22+0x1d8>
    3bee:	jmp    3c06 <botlish_fn_22+0xde>
    3bf3:	mov    ecx,0x2
    3bf8:	mov    rsi,r13
    3bfb:	cmp    rsi,r12
    3bfe:	cmovge rcx,QWORD PTR [rip+0xfa]        # 3d00 <botlish_fn_22+0x1d8>
    3c06:	cmp    rcx,0x6
    3c0a:	je     3cde <botlish_fn_22+0x1b6>
    3c10:	lea    rcx,[rsp+0x20]
    3c15:	mov    rdx,rbx
    3c18:	mov    rsi,r13
    3c1b:	mov    rdi,r14
    3c1e:	call   3c23 <botlish_fn_22+0xfb>
			3c1f: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    3c23:	test   rax,rax
    3c26:	mov    rsi,rax
    3c29:	je     3c4a <botlish_fn_22+0x122>
    3c2f:	mov    rdx,QWORD PTR [rsp+0x20]
    3c34:	mov    rcx,QWORD PTR [rsp+0x28]
    3c39:	mov    rdi,r14
    3c3c:	call   3c41 <botlish_fn_22+0x119>
			3c3d: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    3c41:	test   rax,rax
    3c44:	jne    3c6a <botlish_fn_22+0x142>
    3c4a:	xor    rax,rax
    3c4d:	mov    rbx,QWORD PTR [rsp+0x30]
    3c52:	mov    r12,QWORD PTR [rsp+0x38]
    3c57:	mov    r13,QWORD PTR [rsp+0x40]
    3c5c:	mov    r14,QWORD PTR [rsp+0x48]
    3c61:	add    rsp,0x50
    3c65:	mov    rsp,rbp
    3c68:	pop    rbp
    3c69:	ret
    3c6a:	cmp    rax,0x6
    3c6e:	je     3c7c <botlish_fn_22+0x154>
    3c74:	mov    rax,r13
    3c77:	jmp    3ce1 <botlish_fn_22+0x1b9>
    3c7c:	mov    QWORD PTR [rsp+0x18],0x3
    3c85:	mov    rsi,r13
    3c88:	test   rsi,0x1
    3c8f:	je     3cb5 <botlish_fn_22+0x18d>
    3c95:	mov    rsi,r13
    3c98:	mov    r11,rsi
    3c9b:	add    r11,0x2
    3c9f:	seto   al
    3ca2:	test   al,al
    3ca4:	jne    3cb5 <botlish_fn_22+0x18d>
    3caa:	mov    rsi,r11
    3cad:	mov    r13,r11
    3cb0:	jmp    3ccb <botlish_fn_22+0x1a3>
    3cb5:	mov    edx,0x3
    3cba:	mov    rsi,r13
    3cbd:	mov    rdi,r14
    3cc0:	call   3cc5 <botlish_fn_22+0x19d>
			3cc1: R_X86_64_PLT32	rt_int_add-0x4
    3cc5:	mov    rsi,rax
    3cc8:	mov    r13,rax
    3ccb:	mov    QWORD PTR [rsp],rsi
    3ccf:	mov    QWORD PTR [rsp+0x8],r12
    3cd4:	mov    QWORD PTR [rsp+0x10],rbx
    3cd9:	jmp    3b67 <botlish_fn_22+0x3f>
    3cde:	mov    rax,r13
    3ce1:	mov    rbx,QWORD PTR [rsp+0x30]
    3ce6:	mov    r12,QWORD PTR [rsp+0x38]
    3ceb:	mov    r13,QWORD PTR [rsp+0x40]
    3cf0:	mov    r14,QWORD PTR [rsp+0x48]
    3cf5:	add    rsp,0x50
    3cf9:	mov    rsp,rbp
    3cfc:	pop    rbp
    3cfd:	ret
    3cfe:	add    BYTE PTR [rax],al
    3d00:	(bad)
    3d01:	add    BYTE PTR [rax],al
    3d03:	add    BYTE PTR [rax],al
    3d05:	add    BYTE PTR [rax],al
	...

0000000000003d08 <botlish_entry_22: scan_alpha<generic>>:
    3d08:	push   rbp
    3d09:	mov    rbp,rsp
    3d0c:	mov    rsi,QWORD PTR [rdx]
    3d0f:	mov    r8,QWORD PTR [rdx+0x8]
    3d13:	mov    rcx,QWORD PTR [rdx+0x10]
    3d17:	mov    rdx,r8
    3d1a:	call   3d1f <botlish_entry_22+0x17>
			3d1b: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    3d1f:	mov    rsp,rbp
    3d22:	pop    rbp
    3d23:	ret
    3d24:	add    BYTE PTR [rax],al
	...

0000000000003d28 <botlish_fn_23: tld_ok<generic>>:
    3d28:	push   rbp
    3d29:	mov    rbp,rsp
    3d2c:	sub    rsp,0x40
    3d30:	mov    QWORD PTR [rsp+0x20],rbx
    3d35:	mov    QWORD PTR [rsp+0x28],r12
    3d3a:	mov    QWORD PTR [rsp+0x30],r13
    3d3f:	mov    QWORD PTR [rsp+0x38],r14
    3d44:	mov    rbx,rdi
    3d47:	mov    QWORD PTR [rsp],rsi
    3d4b:	mov    r12,rsi
    3d4e:	mov    QWORD PTR [rsp+0x8],rdx
    3d53:	mov    r14,rdx
    3d56:	mov    QWORD PTR [rsp+0x10],rcx
    3d5b:	mov    rdx,r14
    3d5e:	mov    rsi,r12
    3d61:	mov    rdi,rbx
    3d64:	call   3d69 <botlish_fn_23+0x41>
			3d65: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    3d69:	mov    rsi,rax
    3d6c:	mov    r13,rax
    3d6f:	test   rax,rsi
    3d72:	je     3e35 <botlish_fn_23+0x10d>
    3d78:	mov    rax,r13
    3d7b:	mov    QWORD PTR [rsp+0x8],rax
    3d80:	mov    rdx,r14
    3d83:	and    rax,rdx
    3d86:	test   rax,0x1
    3d8c:	jne    3db5 <botlish_fn_23+0x8d>
    3d92:	mov    rsi,r13
    3d95:	mov    rdi,rbx
    3d98:	call   3d9d <botlish_fn_23+0x75>
			3d99: R_X86_64_PLT32	rt_int_cmp-0x4
    3d9d:	mov    ecx,0x2
    3da2:	test   rax,rax
    3da5:	cmove  rcx,QWORD PTR [rip+0x15b]        # 3f08 <botlish_fn_23+0x1e0>
    3dad:	mov    rax,r13
    3db0:	jmp    3dc8 <botlish_fn_23+0xa0>
    3db5:	mov    ecx,0x2
    3dba:	mov    rax,r13
    3dbd:	cmp    rax,rdx
    3dc0:	cmove  rcx,QWORD PTR [rip+0x140]        # 3f08 <botlish_fn_23+0x1e0>
    3dc8:	cmp    rcx,0x6
    3dcc:	je     3ddf <botlish_fn_23+0xb7>
    3dd2:	mov    ecx,0x2
    3dd7:	mov    rax,rcx
    3dda:	jmp    3ee7 <botlish_fn_23+0x1bf>
    3ddf:	mov    ecx,0x1
    3de4:	mov    rsi,r12
    3de7:	test   rsi,0x1
    3dee:	jne    3e14 <botlish_fn_23+0xec>
    3df4:	xor    ecx,ecx
    3df6:	mov    rsi,r12
    3df9:	test   rsi,0x7
    3e00:	jne    3e14 <botlish_fn_23+0xec>
    3e06:	mov    rsi,r12
    3e09:	movzx  rcx,BYTE PTR [rsi]
    3e0d:	rex cmp cl,0x1
    3e11:	sete   cl
    3e14:	test   cl,cl
    3e16:	jne    3e55 <botlish_fn_23+0x12d>
    3e1c:	mov    rdi,rbx
    3e1f:	mov    rsi,QWORD PTR [rdi+0x10]
    3e23:	mov    rcx,QWORD PTR [rsi+0x128]
    3e2a:	xor    rdx,rdx
    3e2d:	mov    rsi,r12
    3e30:	call   3e35 <botlish_fn_23+0x10d>
			3e31: R_X86_64_PLT32	rt_type_error-0x4
    3e35:	xor    rax,rax
    3e38:	mov    rbx,QWORD PTR [rsp+0x20]
    3e3d:	mov    r12,QWORD PTR [rsp+0x28]
    3e42:	mov    r13,QWORD PTR [rsp+0x30]
    3e47:	mov    r14,QWORD PTR [rsp+0x38]
    3e4c:	add    rsp,0x40
    3e50:	mov    rsp,rbp
    3e53:	pop    rbp
    3e54:	ret
    3e55:	mov    rsi,r12
    3e58:	mov    rdi,rax
    3e5b:	and    rdi,rsi
    3e5e:	test   rdi,0x1
    3e65:	jne    3e76 <botlish_fn_23+0x14e>
    3e6b:	mov    rdx,r12
    3e6e:	mov    rsi,rax
    3e71:	jmp    3e99 <botlish_fn_23+0x171>
    3e76:	mov    rsi,r12
    3e79:	mov    r8,rax
    3e7c:	sub    r8,rsi
    3e7f:	mov    r13,rax
    3e82:	seto   r10b
    3e86:	lea    rsi,[r8+0x1]
    3e8a:	test   r10b,r10b
    3e8d:	je     3ea4 <botlish_fn_23+0x17c>
    3e93:	mov    rdx,r12
    3e96:	mov    rsi,r13
    3e99:	mov    rdi,rbx
    3e9c:	call   3ea1 <botlish_fn_23+0x179>
			3e9d: R_X86_64_PLT32	rt_int_sub-0x4
    3ea1:	mov    rsi,rax
    3ea4:	test   rsi,0x1
    3eab:	jne    3ed6 <botlish_fn_23+0x1ae>
    3eb1:	mov    edx,0x5
    3eb6:	mov    rdi,rbx
    3eb9:	call   3ebe <botlish_fn_23+0x196>
			3eba: R_X86_64_PLT32	rt_int_cmp-0x4
    3ebe:	mov    ecx,0x2
    3ec3:	test   rax,rax
    3ec6:	mov    rax,rcx
    3ec9:	cmovge rax,QWORD PTR [rip+0x37]        # 3f08 <botlish_fn_23+0x1e0>
    3ed1:	jmp    3ee7 <botlish_fn_23+0x1bf>
    3ed6:	mov    eax,0x2
    3edb:	cmp    rsi,0x5
    3edf:	cmovge rax,QWORD PTR [rip+0x21]        # 3f08 <botlish_fn_23+0x1e0>
    3ee7:	mov    rbx,QWORD PTR [rsp+0x20]
    3eec:	mov    r12,QWORD PTR [rsp+0x28]
    3ef1:	mov    r13,QWORD PTR [rsp+0x30]
    3ef6:	mov    r14,QWORD PTR [rsp+0x38]
    3efb:	add    rsp,0x40
    3eff:	mov    rsp,rbp
    3f02:	pop    rbp
    3f03:	ret
    3f04:	add    BYTE PTR [rax],al
    3f06:	add    BYTE PTR [rax],al
    3f08:	(bad)
    3f09:	add    BYTE PTR [rax],al
    3f0b:	add    BYTE PTR [rax],al
    3f0d:	add    BYTE PTR [rax],al
	...

0000000000003f10 <botlish_entry_23: tld_ok<generic>>:
    3f10:	push   rbp
    3f11:	mov    rbp,rsp
    3f14:	mov    rsi,QWORD PTR [rdx]
    3f17:	mov    r8,QWORD PTR [rdx+0x8]
    3f1b:	mov    rcx,QWORD PTR [rdx+0x10]
    3f1f:	mov    rdx,r8
    3f22:	call   3f27 <botlish_entry_23+0x17>
			3f23: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    3f27:	mov    rsp,rbp
    3f2a:	pop    rbp
    3f2b:	ret
    3f2c:	add    BYTE PTR [rax],al
	...

0000000000003f30 <botlish_fn_24: domain_loop<generic>>:
    3f30:	push   rbp
    3f31:	mov    rbp,rsp
    3f34:	sub    rsp,0x70
    3f38:	mov    QWORD PTR [rsp+0x40],rbx
    3f3d:	mov    QWORD PTR [rsp+0x48],r12
    3f42:	mov    QWORD PTR [rsp+0x50],r13
    3f47:	mov    QWORD PTR [rsp+0x58],r14
    3f4c:	mov    QWORD PTR [rsp+0x60],r15
    3f51:	mov    QWORD PTR [rsp+0x18],0x0
    3f5a:	mov    QWORD PTR [rsp],rsi
    3f5e:	mov    QWORD PTR [rsp+0x8],rdx
    3f63:	mov    QWORD PTR [rsp+0x10],rcx
    3f68:	lea    rbx,[rsp+0x20]
    3f6d:	mov    r12,rdi
    3f70:	mov    r13,rcx
    3f73:	mov    r14,rdx
    3f76:	mov    QWORD PTR [rsp+0x30],rsi
    3f7b:	mov    rcx,r13
    3f7e:	mov    rdx,r14
    3f81:	mov    rsi,QWORD PTR [rsp+0x30]
    3f86:	mov    rdi,r12
    3f89:	call   3f8e <botlish_fn_24+0x5e>
			3f8a: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    3f8e:	mov    rcx,rax
    3f91:	mov    r15,rax
    3f94:	test   rax,rcx
    3f97:	je     40e7 <botlish_fn_24+0x1b7>
    3f9d:	mov    rax,r15
    3fa0:	mov    QWORD PTR [rsp],rax
    3fa4:	mov    rdx,QWORD PTR [rsp+0x30]
    3fa9:	and    rax,rdx
    3fac:	test   rax,0x1
    3fb2:	jne    3fd1 <botlish_fn_24+0xa1>
    3fb8:	mov    rsi,r15
    3fbb:	mov    rdi,r12
    3fbe:	call   3fc3 <botlish_fn_24+0x93>
			3fbf: R_X86_64_PLT32	rt_value_eq-0x4
    3fc3:	test   rax,rax
    3fc6:	je     40e7 <botlish_fn_24+0x1b7>
    3fcc:	jmp    3fe1 <botlish_fn_24+0xb1>
    3fd1:	mov    eax,0x2
    3fd6:	cmp    r15,rdx
    3fd9:	cmove  rax,QWORD PTR [rip+0x187]        # 4168 <botlish_fn_24+0x238>
    3fe1:	cmp    rax,0x6
    3fe5:	je     413d <botlish_fn_24+0x20d>
    3feb:	mov    rax,r15
    3fee:	and    rax,r14
    3ff1:	test   rax,0x1
    3ff7:	jne    4020 <botlish_fn_24+0xf0>
    3ffd:	mov    rdx,r14
    4000:	mov    rsi,r15
    4003:	mov    rdi,r12
    4006:	call   400b <botlish_fn_24+0xdb>
			4007: R_X86_64_PLT32	rt_int_cmp-0x4
    400b:	mov    ecx,0x2
    4010:	test   rax,rax
    4013:	cmovge rcx,QWORD PTR [rip+0x14d]        # 4168 <botlish_fn_24+0x238>
    401b:	jmp    4030 <botlish_fn_24+0x100>
    4020:	mov    ecx,0x2
    4025:	cmp    r15,r14
    4028:	cmovge rcx,QWORD PTR [rip+0x138]        # 4168 <botlish_fn_24+0x238>
    4030:	cmp    rcx,0x6
    4034:	je     412e <botlish_fn_24+0x1fe>
    403a:	mov    rcx,rbx
    403d:	mov    rdx,r13
    4040:	mov    rsi,r15
    4043:	mov    rdi,r12
    4046:	call   404b <botlish_fn_24+0x11b>
			4047: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    404b:	test   rax,rax
    404e:	je     40e7 <botlish_fn_24+0x1b7>
    4054:	mov    rdx,QWORD PTR [rsp+0x20]
    4059:	mov    rcx,QWORD PTR [rsp+0x28]
    405e:	mov    rsi,QWORD PTR [r12+0x10]
    4063:	mov    r8,QWORD PTR [rsi+0x118]
    406a:	mov    rsi,rax
    406d:	mov    rdi,r12
    4070:	call   4075 <botlish_fn_24+0x145>
			4071: R_X86_64_PLT32	rt_str_region_eq-0x4
    4075:	cmp    rax,0x6
    4079:	je     408b <botlish_fn_24+0x15b>
    407f:	mov    r14,0xffffffffffffffff
    4086:	jmp    4135 <botlish_fn_24+0x205>
    408b:	mov    QWORD PTR [rsp+0x18],0x3
    4094:	test   r15,0x1
    409b:	je     40b3 <botlish_fn_24+0x183>
    40a1:	mov    rdx,r15
    40a4:	add    rdx,0x2
    40a8:	seto   al
    40ab:	test   al,al
    40ad:	je     40c6 <botlish_fn_24+0x196>
    40b3:	mov    edx,0x3
    40b8:	mov    rsi,r15
    40bb:	mov    rdi,r12
    40be:	call   40c3 <botlish_fn_24+0x193>
			40bf: R_X86_64_PLT32	rt_int_add-0x4
    40c3:	mov    rdx,rax
    40c6:	mov    QWORD PTR [rsp],rdx
    40ca:	mov    r15,rdx
    40cd:	mov    rcx,r13
    40d0:	mov    rdx,r14
    40d3:	mov    rsi,r15
    40d6:	mov    rdi,r12
    40d9:	call   40de <botlish_fn_24+0x1ae>
			40da: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    40de:	test   rax,rax
    40e1:	jne    410c <botlish_fn_24+0x1dc>
    40e7:	xor    rax,rax
    40ea:	mov    rbx,QWORD PTR [rsp+0x40]
    40ef:	mov    r12,QWORD PTR [rsp+0x48]
    40f4:	mov    r13,QWORD PTR [rsp+0x50]
    40f9:	mov    r14,QWORD PTR [rsp+0x58]
    40fe:	mov    r15,QWORD PTR [rsp+0x60]
    4103:	add    rsp,0x70
    4107:	mov    rsp,rbp
    410a:	pop    rbp
    410b:	ret
    410c:	cmp    rax,0x6
    4110:	je     4135 <botlish_fn_24+0x205>
    4116:	mov    QWORD PTR [rsp],r15
    411a:	mov    QWORD PTR [rsp+0x8],r14
    411f:	mov    QWORD PTR [rsp+0x10],r13
    4124:	mov    QWORD PTR [rsp+0x30],r15
    4129:	jmp    3f7b <botlish_fn_24+0x4b>
    412e:	mov    r14,0xffffffffffffffff
    4135:	mov    rax,r14
    4138:	jmp    4144 <botlish_fn_24+0x214>
    413d:	mov    rax,0xffffffffffffffff
    4144:	mov    rbx,QWORD PTR [rsp+0x40]
    4149:	mov    r12,QWORD PTR [rsp+0x48]
    414e:	mov    r13,QWORD PTR [rsp+0x50]
    4153:	mov    r14,QWORD PTR [rsp+0x58]
    4158:	mov    r15,QWORD PTR [rsp+0x60]
    415d:	add    rsp,0x70
    4161:	mov    rsp,rbp
    4164:	pop    rbp
    4165:	ret
    4166:	add    BYTE PTR [rax],al
    4168:	(bad)
    4169:	add    BYTE PTR [rax],al
    416b:	add    BYTE PTR [rax],al
    416d:	add    BYTE PTR [rax],al
	...

0000000000004170 <botlish_entry_24: domain_loop<generic>>:
    4170:	push   rbp
    4171:	mov    rbp,rsp
    4174:	mov    rsi,QWORD PTR [rdx]
    4177:	mov    r8,QWORD PTR [rdx+0x8]
    417b:	mov    rcx,QWORD PTR [rdx+0x10]
    417f:	mov    rdx,r8
    4182:	call   4187 <botlish_entry_24+0x17>
			4183: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    4187:	mov    rsp,rbp
    418a:	pop    rbp
    418b:	ret

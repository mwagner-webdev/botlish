; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 18894  (per function: 935 112 1713 1425 473 864 506 952 504 761 817 427 456 884 644 540 540 636 761 817 427 456 884 644 540 540 636)
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
;   botlish_fn_12 / botlish_entry_12 -> char_at<generic>
;   botlish_fn_13 / botlish_entry_13 -> scan_local<generic>
;   botlish_fn_14 / botlish_entry_14 -> scan_label<generic>
;   botlish_fn_15 / botlish_entry_15 -> scan_alpha<generic>
;   botlish_fn_16 / botlish_entry_16 -> tld_ok<generic>
;   botlish_fn_17 / botlish_entry_17 -> domain_loop<generic>
;   botlish_fn_18 / botlish_entry_18 -> <str>
;   botlish_fn_19 / botlish_entry_19 -> <generic>
;   botlish_fn_20 / botlish_entry_20 -> char_at<generic>
;   botlish_fn_21 / botlish_entry_21 -> char_at<generic>
;   botlish_fn_22 / botlish_entry_22 -> scan_local<generic>
;   botlish_fn_23 / botlish_entry_23 -> scan_label<generic>
;   botlish_fn_24 / botlish_entry_24 -> scan_alpha<generic>
;   botlish_fn_25 / botlish_entry_25 -> tld_ok<generic>
;   botlish_fn_26 / botlish_entry_26 -> domain_loop<generic>


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
			1a86: R_X86_64_PLT32	botlish_fn_18-0x4 ; <str>
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
    1b94:	sub    rsp,0x70
    1b98:	mov    QWORD PTR [rsp+0x40],rbx
    1b9d:	mov    QWORD PTR [rsp+0x48],r12
    1ba2:	mov    QWORD PTR [rsp+0x50],r13
    1ba7:	mov    QWORD PTR [rsp+0x58],r14
    1bac:	mov    QWORD PTR [rsp+0x60],r15
    1bb1:	mov    r13,rdi
    1bb4:	mov    QWORD PTR [rsp+0x10],0x0
    1bbd:	mov    QWORD PTR [rsp+0x18],0x0
    1bc6:	mov    QWORD PTR [rsp],rsi
    1bca:	mov    r12,rsi
    1bcd:	mov    rsi,r12
    1bd0:	mov    rdi,r13
    1bd3:	call   1bd8 <botlish_fn_9+0x48>
			1bd4: R_X86_64_PLT32	rt_str_len-0x4
    1bd8:	mov    r14,rax
    1bdb:	mov    QWORD PTR [rsp+0x8],rax
    1be0:	lea    r8,[rsp+0x20]
    1be5:	mov    QWORD PTR [rsp+0x20],r12
    1bea:	mov    esi,0xb
    1bef:	mov    rdx,QWORD PTR [rip+0x0]        # 1bf6 <botlish_fn_9+0x66>
			1bf2: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    1bf6:	mov    ebx,0x1
    1bfb:	mov    rcx,rbx
    1bfe:	mov    rdi,r13
    1c01:	call   1c06 <botlish_fn_9+0x76>
			1c02: R_X86_64_PLT32	rt_closure_new-0x4
    1c06:	mov    r15,rax
    1c09:	mov    QWORD PTR [rsp],rax
    1c0d:	mov    QWORD PTR [rsp+0x10],0x1
    1c16:	mov    rsi,rbx
    1c19:	mov    rcx,r15
    1c1c:	mov    rdx,r14
    1c1f:	mov    rdi,r13
    1c22:	call   1c27 <botlish_fn_9+0x97>
			1c23: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_local<generic>
    1c27:	mov    r12,rax
    1c2a:	test   r12,r12
    1c2d:	je     1d8d <botlish_fn_9+0x1fd>
    1c33:	mov    QWORD PTR [rsp+0x10],r12
    1c38:	test   r12,0x1
    1c3f:	jne    1c6a <botlish_fn_9+0xda>
    1c45:	mov    edx,0x1
    1c4a:	mov    rsi,r12
    1c4d:	mov    rdi,r13
    1c50:	call   1c55 <botlish_fn_9+0xc5>
			1c51: R_X86_64_PLT32	rt_int_cmp-0x4
    1c55:	mov    ecx,0x2
    1c5a:	test   rax,rax
    1c5d:	cmove  rcx,QWORD PTR [rip+0x1d3]        # 1e38 <botlish_fn_9+0x2a8>
    1c65:	jmp    1c7b <botlish_fn_9+0xeb>
    1c6a:	mov    ecx,0x2
    1c6f:	cmp    r12,0x1
    1c73:	cmove  rcx,QWORD PTR [rip+0x1bd]        # 1e38 <botlish_fn_9+0x2a8>
    1c7b:	cmp    rcx,0x6
    1c7f:	je     1e10 <botlish_fn_9+0x280>
    1c85:	mov    rbx,r14
    1c88:	mov    r8,r12
    1c8b:	and    r8,rbx
    1c8e:	test   r8,0x1
    1c95:	jne    1cbe <botlish_fn_9+0x12e>
    1c9b:	mov    rdx,rbx
    1c9e:	mov    rsi,r12
    1ca1:	mov    rdi,r13
    1ca4:	call   1ca9 <botlish_fn_9+0x119>
			1ca5: R_X86_64_PLT32	rt_int_cmp-0x4
    1ca9:	mov    ecx,0x2
    1cae:	test   rax,rax
    1cb1:	cmovge rcx,QWORD PTR [rip+0x17f]        # 1e38 <botlish_fn_9+0x2a8>
    1cb9:	jmp    1cce <botlish_fn_9+0x13e>
    1cbe:	mov    ecx,0x2
    1cc3:	cmp    r12,rbx
    1cc6:	cmovge rcx,QWORD PTR [rip+0x16a]        # 1e38 <botlish_fn_9+0x2a8>
    1cce:	cmp    rcx,0x6
    1cd2:	je     1e06 <botlish_fn_9+0x276>
    1cd8:	lea    rcx,[rsp+0x28]
    1cdd:	mov    rdx,r12
    1ce0:	mov    rsi,r15
    1ce3:	mov    rdi,r13
    1ce6:	call   1ceb <botlish_fn_9+0x15b>
			1ce7: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    1ceb:	test   rax,rax
    1cee:	mov    rsi,rax
    1cf1:	je     1d8d <botlish_fn_9+0x1fd>
    1cf7:	mov    rdx,QWORD PTR [rsp+0x28]
    1cfc:	mov    rcx,QWORD PTR [rsp+0x30]
    1d01:	mov    rdi,r13
    1d04:	mov    rax,QWORD PTR [rdi+0x10]
    1d08:	mov    r8,QWORD PTR [rax+0x100]
    1d0f:	call   1d14 <botlish_fn_9+0x184>
			1d10: R_X86_64_PLT32	rt_str_region_eq-0x4
    1d14:	cmp    rax,0x6
    1d18:	je     1d2b <botlish_fn_9+0x19b>
    1d1e:	mov    esi,0x2
    1d23:	mov    rax,rsi
    1d26:	jmp    1e15 <botlish_fn_9+0x285>
    1d2b:	mov    QWORD PTR [rsp+0x18],0x3
    1d34:	test   r12,0x1
    1d3b:	jne    1d49 <botlish_fn_9+0x1b9>
    1d41:	mov    rcx,r12
    1d44:	jmp    1d5e <botlish_fn_9+0x1ce>
    1d49:	mov    rsi,r12
    1d4c:	add    rsi,0x2
    1d50:	mov    rcx,r12
    1d53:	seto   al
    1d56:	test   al,al
    1d58:	je     1d71 <botlish_fn_9+0x1e1>
    1d5e:	mov    edx,0x3
    1d63:	mov    rsi,rcx
    1d66:	mov    rdi,r13
    1d69:	call   1d6e <botlish_fn_9+0x1de>
			1d6a: R_X86_64_PLT32	rt_int_add-0x4
    1d6e:	mov    rsi,rax
    1d71:	mov    QWORD PTR [rsp+0x10],rsi
    1d76:	mov    rcx,r15
    1d79:	mov    rdx,rbx
    1d7c:	mov    rdi,r13
    1d7f:	call   1d84 <botlish_fn_9+0x1f4>
			1d80: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain_loop<generic>
    1d84:	test   rax,rax
    1d87:	jne    1db2 <botlish_fn_9+0x222>
    1d8d:	xor    rax,rax
    1d90:	mov    rbx,QWORD PTR [rsp+0x40]
    1d95:	mov    r12,QWORD PTR [rsp+0x48]
    1d9a:	mov    r13,QWORD PTR [rsp+0x50]
    1d9f:	mov    r14,QWORD PTR [rsp+0x58]
    1da4:	mov    r15,QWORD PTR [rsp+0x60]
    1da9:	add    rsp,0x70
    1dad:	mov    rsp,rbp
    1db0:	pop    rbp
    1db1:	ret
    1db2:	mov    rcx,rax
    1db5:	and    rcx,rbx
    1db8:	mov    rsi,rax
    1dbb:	mov    r14,rbx
    1dbe:	test   rcx,0x1
    1dc5:	jne    1dee <botlish_fn_9+0x25e>
    1dcb:	mov    rdx,r14
    1dce:	mov    rdi,r13
    1dd1:	call   1dd6 <botlish_fn_9+0x246>
			1dd2: R_X86_64_PLT32	rt_int_cmp-0x4
    1dd6:	mov    esi,0x2
    1ddb:	test   rax,rax
    1dde:	mov    rax,rsi
    1de1:	cmove  rax,QWORD PTR [rip+0x4f]        # 1e38 <botlish_fn_9+0x2a8>
    1de9:	jmp    1e15 <botlish_fn_9+0x285>
    1dee:	mov    rdx,r14
    1df1:	mov    eax,0x2
    1df6:	cmp    rsi,rdx
    1df9:	cmove  rax,QWORD PTR [rip+0x37]        # 1e38 <botlish_fn_9+0x2a8>
    1e01:	jmp    1e15 <botlish_fn_9+0x285>
    1e06:	mov    eax,0x2
    1e0b:	jmp    1e15 <botlish_fn_9+0x285>
    1e10:	mov    eax,0x2
    1e15:	mov    rbx,QWORD PTR [rsp+0x40]
    1e1a:	mov    r12,QWORD PTR [rsp+0x48]
    1e1f:	mov    r13,QWORD PTR [rsp+0x50]
    1e24:	mov    r14,QWORD PTR [rsp+0x58]
    1e29:	mov    r15,QWORD PTR [rsp+0x60]
    1e2e:	add    rsp,0x70
    1e32:	mov    rsp,rbp
    1e35:	pop    rbp
    1e36:	ret
    1e37:	add    BYTE PTR [rsi],al
    1e39:	add    BYTE PTR [rax],al
    1e3b:	add    BYTE PTR [rax],al
    1e3d:	add    BYTE PTR [rax],al
	...

0000000000001e40 <botlish_entry_9: <str>>:
    1e40:	push   rbp
    1e41:	mov    rbp,rsp
    1e44:	mov    rsi,QWORD PTR [rdx]
    1e47:	call   1e4c <botlish_entry_9+0xc>
			1e48: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    1e4c:	mov    rsp,rbp
    1e4f:	pop    rbp
    1e50:	ret
    1e51:	add    BYTE PTR [rax],al
    1e53:	add    BYTE PTR [rax],al
    1e55:	add    BYTE PTR [rax],al
	...

0000000000001e58 <botlish_fn_10: <generic>>:
    1e58:	push   rbp
    1e59:	mov    rbp,rsp
    1e5c:	sub    rsp,0x70
    1e60:	mov    QWORD PTR [rsp+0x40],rbx
    1e65:	mov    QWORD PTR [rsp+0x48],r12
    1e6a:	mov    QWORD PTR [rsp+0x50],r13
    1e6f:	mov    QWORD PTR [rsp+0x58],r14
    1e74:	mov    QWORD PTR [rsp+0x60],r15
    1e79:	mov    QWORD PTR [rsp+0x10],0x0
    1e82:	mov    QWORD PTR [rsp+0x18],0x0
    1e8b:	mov    QWORD PTR [rsp],rsi
    1e8f:	xor    r8d,r8d
    1e92:	test   rsi,0x7
    1e99:	jne    1eab <botlish_fn_10+0x53>
    1e9f:	movzx  r8,BYTE PTR [rsi]
    1ea3:	cmp    r8b,0x2
    1ea7:	sete   r8b
    1eab:	test   r8b,r8b
    1eae:	jne    1ece <botlish_fn_10+0x76>
    1eb4:	mov    r8,QWORD PTR [rdi+0x10]
    1eb8:	mov    rcx,QWORD PTR [r8+0xd8]
    1ebf:	mov    edx,0x1
    1ec4:	call   1ec9 <botlish_fn_10+0x71>
			1ec5: R_X86_64_PLT32	rt_type_error-0x4
    1ec9:	jmp    208f <botlish_fn_10+0x237>
    1ece:	mov    rbx,rsi
    1ed1:	mov    r14,rdi
    1ed4:	call   1ed9 <botlish_fn_10+0x81>
			1ed5: R_X86_64_PLT32	rt_str_len-0x4
    1ed9:	mov    r13,rax
    1edc:	mov    QWORD PTR [rsp+0x8],rax
    1ee1:	lea    r8,[rsp+0x20]
    1ee6:	mov    QWORD PTR [rsp+0x20],rbx
    1eeb:	mov    esi,0xb
    1ef0:	mov    rdx,QWORD PTR [rip+0x0]        # 1ef7 <botlish_fn_10+0x9f>
			1ef3: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    1ef7:	mov    r12d,0x1
    1efd:	mov    rcx,r12
    1f00:	mov    rdi,r14
    1f03:	call   1f08 <botlish_fn_10+0xb0>
			1f04: R_X86_64_PLT32	rt_closure_new-0x4
    1f08:	mov    rbx,r12
    1f0b:	mov    r15,rax
    1f0e:	mov    QWORD PTR [rsp],rax
    1f12:	mov    QWORD PTR [rsp+0x10],0x1
    1f1b:	mov    rcx,r15
    1f1e:	mov    rdx,r13
    1f21:	mov    rsi,rbx
    1f24:	mov    rdi,r14
    1f27:	call   1f2c <botlish_fn_10+0xd4>
			1f28: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_local<generic>
    1f2c:	mov    r12,rax
    1f2f:	test   r12,r12
    1f32:	je     208f <botlish_fn_10+0x237>
    1f38:	mov    QWORD PTR [rsp+0x10],r12
    1f3d:	test   r12,0x1
    1f44:	jne    1f6d <botlish_fn_10+0x115>
    1f4a:	mov    rdx,rbx
    1f4d:	mov    rsi,r12
    1f50:	mov    rdi,r14
    1f53:	call   1f58 <botlish_fn_10+0x100>
			1f54: R_X86_64_PLT32	rt_int_cmp-0x4
    1f58:	mov    ecx,0x2
    1f5d:	test   rax,rax
    1f60:	cmove  rcx,QWORD PTR [rip+0x1d8]        # 2140 <botlish_fn_10+0x2e8>
    1f68:	jmp    1f7e <botlish_fn_10+0x126>
    1f6d:	mov    ecx,0x2
    1f72:	cmp    r12,0x1
    1f76:	cmove  rcx,QWORD PTR [rip+0x1c2]        # 2140 <botlish_fn_10+0x2e8>
    1f7e:	cmp    rcx,0x6
    1f82:	je     2112 <botlish_fn_10+0x2ba>
    1f88:	mov    rbx,r13
    1f8b:	mov    rax,r12
    1f8e:	and    rax,rbx
    1f91:	test   rax,0x1
    1f97:	jne    1fc0 <botlish_fn_10+0x168>
    1f9d:	mov    rdx,rbx
    1fa0:	mov    rsi,r12
    1fa3:	mov    rdi,r14
    1fa6:	call   1fab <botlish_fn_10+0x153>
			1fa7: R_X86_64_PLT32	rt_int_cmp-0x4
    1fab:	mov    ecx,0x2
    1fb0:	test   rax,rax
    1fb3:	cmovge rcx,QWORD PTR [rip+0x185]        # 2140 <botlish_fn_10+0x2e8>
    1fbb:	jmp    1fd0 <botlish_fn_10+0x178>
    1fc0:	mov    ecx,0x2
    1fc5:	cmp    r12,rbx
    1fc8:	cmovge rcx,QWORD PTR [rip+0x170]        # 2140 <botlish_fn_10+0x2e8>
    1fd0:	cmp    rcx,0x6
    1fd4:	je     2108 <botlish_fn_10+0x2b0>
    1fda:	lea    rcx,[rsp+0x28]
    1fdf:	mov    rdx,r12
    1fe2:	mov    rsi,r15
    1fe5:	mov    rdi,r14
    1fe8:	call   1fed <botlish_fn_10+0x195>
			1fe9: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    1fed:	test   rax,rax
    1ff0:	mov    rsi,rax
    1ff3:	je     208f <botlish_fn_10+0x237>
    1ff9:	mov    rdx,QWORD PTR [rsp+0x28]
    1ffe:	mov    rcx,QWORD PTR [rsp+0x30]
    2003:	mov    rdi,r14
    2006:	mov    rax,QWORD PTR [rdi+0x10]
    200a:	mov    r8,QWORD PTR [rax+0x100]
    2011:	call   2016 <botlish_fn_10+0x1be>
			2012: R_X86_64_PLT32	rt_str_region_eq-0x4
    2016:	cmp    rax,0x6
    201a:	je     202d <botlish_fn_10+0x1d5>
    2020:	mov    ecx,0x2
    2025:	mov    rax,rcx
    2028:	jmp    2117 <botlish_fn_10+0x2bf>
    202d:	mov    QWORD PTR [rsp+0x18],0x3
    2036:	test   r12,0x1
    203d:	jne    204b <botlish_fn_10+0x1f3>
    2043:	mov    rdi,r12
    2046:	jmp    2060 <botlish_fn_10+0x208>
    204b:	mov    rsi,r12
    204e:	add    rsi,0x2
    2052:	mov    rdi,r12
    2055:	seto   al
    2058:	test   al,al
    205a:	je     2073 <botlish_fn_10+0x21b>
    2060:	mov    edx,0x3
    2065:	mov    rsi,rdi
    2068:	mov    rdi,r14
    206b:	call   2070 <botlish_fn_10+0x218>
			206c: R_X86_64_PLT32	rt_int_add-0x4
    2070:	mov    rsi,rax
    2073:	mov    QWORD PTR [rsp+0x10],rsi
    2078:	mov    rcx,r15
    207b:	mov    rdx,rbx
    207e:	mov    rdi,r14
    2081:	call   2086 <botlish_fn_10+0x22e>
			2082: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain_loop<generic>
    2086:	test   rax,rax
    2089:	jne    20b4 <botlish_fn_10+0x25c>
    208f:	xor    rax,rax
    2092:	mov    rbx,QWORD PTR [rsp+0x40]
    2097:	mov    r12,QWORD PTR [rsp+0x48]
    209c:	mov    r13,QWORD PTR [rsp+0x50]
    20a1:	mov    r14,QWORD PTR [rsp+0x58]
    20a6:	mov    r15,QWORD PTR [rsp+0x60]
    20ab:	add    rsp,0x70
    20af:	mov    rsp,rbp
    20b2:	pop    rbp
    20b3:	ret
    20b4:	mov    rcx,rax
    20b7:	and    rcx,rbx
    20ba:	mov    rsi,rax
    20bd:	mov    r13,rbx
    20c0:	test   rcx,0x1
    20c7:	jne    20f0 <botlish_fn_10+0x298>
    20cd:	mov    rdx,r13
    20d0:	mov    rdi,r14
    20d3:	call   20d8 <botlish_fn_10+0x280>
			20d4: R_X86_64_PLT32	rt_int_cmp-0x4
    20d8:	mov    ecx,0x2
    20dd:	test   rax,rax
    20e0:	mov    rax,rcx
    20e3:	cmove  rax,QWORD PTR [rip+0x55]        # 2140 <botlish_fn_10+0x2e8>
    20eb:	jmp    2117 <botlish_fn_10+0x2bf>
    20f0:	mov    rdx,r13
    20f3:	mov    eax,0x2
    20f8:	cmp    rsi,rdx
    20fb:	cmove  rax,QWORD PTR [rip+0x3d]        # 2140 <botlish_fn_10+0x2e8>
    2103:	jmp    2117 <botlish_fn_10+0x2bf>
    2108:	mov    eax,0x2
    210d:	jmp    2117 <botlish_fn_10+0x2bf>
    2112:	mov    eax,0x2
    2117:	mov    rbx,QWORD PTR [rsp+0x40]
    211c:	mov    r12,QWORD PTR [rsp+0x48]
    2121:	mov    r13,QWORD PTR [rsp+0x50]
    2126:	mov    r14,QWORD PTR [rsp+0x58]
    212b:	mov    r15,QWORD PTR [rsp+0x60]
    2130:	add    rsp,0x70
    2134:	mov    rsp,rbp
    2137:	pop    rbp
    2138:	ret
    2139:	add    BYTE PTR [rax],al
    213b:	add    BYTE PTR [rax],al
    213d:	add    BYTE PTR [rax],al
    213f:	add    BYTE PTR [rsi],al
    2141:	add    BYTE PTR [rax],al
    2143:	add    BYTE PTR [rax],al
    2145:	add    BYTE PTR [rax],al
	...

0000000000002148 <botlish_entry_10: <generic>>:
    2148:	push   rbp
    2149:	mov    rbp,rsp
    214c:	mov    rsi,QWORD PTR [rdx]
    214f:	call   2154 <botlish_entry_10+0xc>
			2150: R_X86_64_PLT32	botlish_fn_10-0x4 ; <generic>
    2154:	mov    rsp,rbp
    2157:	pop    rbp
    2158:	ret

0000000000002159 <botlish_fn_11: char_at<generic>>:
    2159:	push   rbp
    215a:	mov    rbp,rsp
    215d:	sub    rsp,0x40
    2161:	mov    QWORD PTR [rsp+0x20],rbx
    2166:	mov    QWORD PTR [rsp+0x28],r12
    216b:	mov    QWORD PTR [rsp+0x30],r13
    2170:	mov    QWORD PTR [rsp],rdx
    2174:	mov    rax,QWORD PTR [rsi+0x20]
    2178:	mov    rsi,QWORD PTR [rax]
    217b:	mov    QWORD PTR [rsp+0x8],rsi
    2180:	mov    r13,rsi
    2183:	mov    QWORD PTR [rsp+0x10],0x3
    218c:	mov    r10d,0x1
    2192:	test   rdx,0x1
    2199:	je     21a7 <botlish_fn_11+0x4e>
    219f:	mov    rbx,rdx
    21a2:	jmp    21cc <botlish_fn_11+0x73>
    21a7:	xor    r10d,r10d
    21aa:	test   rdx,0x7
    21b1:	je     21bf <botlish_fn_11+0x66>
    21b7:	mov    rbx,rdx
    21ba:	jmp    21cc <botlish_fn_11+0x73>
    21bf:	movzx  rax,BYTE PTR [rdx]
    21c3:	mov    rbx,rdx
    21c6:	cmp    al,0x1
    21c8:	sete   r10b
    21cc:	test   r10b,r10b
    21cf:	jne    21f0 <botlish_fn_11+0x97>
    21d5:	mov    rax,QWORD PTR [rdi+0x10]
    21d9:	mov    rcx,QWORD PTR [rax+0x108]
    21e0:	xor    rdx,rdx
    21e3:	mov    rsi,rbx
    21e6:	call   21eb <botlish_fn_11+0x92>
			21e7: R_X86_64_PLT32	rt_type_error-0x4
    21eb:	jmp    22a2 <botlish_fn_11+0x149>
    21f0:	mov    rsi,rbx
    21f3:	mov    r12,rdi
    21f6:	test   rsi,0x1
    21fd:	je     2218 <botlish_fn_11+0xbf>
    2203:	mov    rsi,rbx
    2206:	mov    rcx,rsi
    2209:	add    rcx,0x2
    220d:	seto   al
    2210:	test   al,al
    2212:	je     222b <botlish_fn_11+0xd2>
    2218:	mov    edx,0x3
    221d:	mov    rsi,rbx
    2220:	mov    rdi,r12
    2223:	call   2228 <botlish_fn_11+0xcf>
			2224: R_X86_64_PLT32	rt_int_add-0x4
    2228:	mov    rcx,rax
    222b:	mov    QWORD PTR [rsp+0x10],rcx
    2230:	mov    eax,0x1
    2235:	mov    rsi,rbx
    2238:	test   rsi,0x1
    223f:	jne    2265 <botlish_fn_11+0x10c>
    2245:	xor    eax,eax
    2247:	mov    rsi,rbx
    224a:	test   rsi,0x7
    2251:	jne    2265 <botlish_fn_11+0x10c>
    2257:	mov    rsi,rbx
    225a:	movzx  rdx,BYTE PTR [rsi]
    225e:	rex cmp dl,0x1
    2262:	sete   al
    2265:	test   al,al
    2267:	jne    228b <botlish_fn_11+0x132>
    226d:	mov    rdi,r12
    2270:	mov    rsi,QWORD PTR [rdi+0x10]
    2274:	mov    rcx,QWORD PTR [rsi+0x110]
    227b:	xor    rdx,rdx
    227e:	mov    rsi,rbx
    2281:	call   2286 <botlish_fn_11+0x12d>
			2282: R_X86_64_PLT32	rt_type_error-0x4
    2286:	jmp    22a2 <botlish_fn_11+0x149>
    228b:	mov    rdx,rbx
    228e:	mov    rsi,r13
    2291:	mov    rdi,r12
    2294:	call   2299 <botlish_fn_11+0x140>
			2295: R_X86_64_PLT32	rt_substr-0x4
    2299:	test   rax,rax
    229c:	jne    22bd <botlish_fn_11+0x164>
    22a2:	xor    rax,rax
    22a5:	mov    rbx,QWORD PTR [rsp+0x20]
    22aa:	mov    r12,QWORD PTR [rsp+0x28]
    22af:	mov    r13,QWORD PTR [rsp+0x30]
    22b4:	add    rsp,0x40
    22b8:	mov    rsp,rbp
    22bb:	pop    rbp
    22bc:	ret
    22bd:	mov    rbx,QWORD PTR [rsp+0x20]
    22c2:	mov    r12,QWORD PTR [rsp+0x28]
    22c7:	mov    r13,QWORD PTR [rsp+0x30]
    22cc:	add    rsp,0x40
    22d0:	mov    rsp,rbp
    22d3:	pop    rbp
    22d4:	ret

00000000000022d5 <botlish_entry_11: char_at<generic>>:
    22d5:	push   rbp
    22d6:	mov    rbp,rsp
    22d9:	mov    rdx,QWORD PTR [rdx]
    22dc:	call   22e1 <botlish_entry_11+0xc>
			22dd: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    22e1:	mov    rsp,rbp
    22e4:	pop    rbp
    22e5:	ret

00000000000022e6 <botlish_fn_12: char_at<generic>>:
    22e6:	push   rbp
    22e7:	mov    rbp,rsp
    22ea:	sub    rsp,0x40
    22ee:	mov    QWORD PTR [rsp+0x20],rbx
    22f3:	mov    QWORD PTR [rsp+0x28],r12
    22f8:	mov    QWORD PTR [rsp+0x30],r13
    22fd:	mov    QWORD PTR [rsp+0x38],r14
    2302:	mov    r13,rcx
    2305:	mov    QWORD PTR [rsp],rdx
    2309:	mov    rax,QWORD PTR [rsi+0x20]
    230d:	mov    rax,QWORD PTR [rax]
    2310:	mov    QWORD PTR [rsp+0x8],rax
    2315:	mov    r14,rax
    2318:	mov    QWORD PTR [rsp+0x10],0x3
    2321:	mov    r11d,0x1
    2327:	test   rdx,0x1
    232e:	je     233c <botlish_fn_12+0x56>
    2334:	mov    r12,rdx
    2337:	jmp    2361 <botlish_fn_12+0x7b>
    233c:	xor    r11d,r11d
    233f:	test   rdx,0x7
    2346:	je     2354 <botlish_fn_12+0x6e>
    234c:	mov    r12,rdx
    234f:	jmp    2361 <botlish_fn_12+0x7b>
    2354:	movzx  rax,BYTE PTR [rdx]
    2358:	mov    r12,rdx
    235b:	cmp    al,0x1
    235d:	sete   r11b
    2361:	test   r11b,r11b
    2364:	jne    2385 <botlish_fn_12+0x9f>
    236a:	mov    rax,QWORD PTR [rdi+0x10]
    236e:	mov    rcx,QWORD PTR [rax+0x108]
    2375:	xor    rdx,rdx
    2378:	mov    rsi,r12
    237b:	call   2380 <botlish_fn_12+0x9a>
			237c: R_X86_64_PLT32	rt_type_error-0x4
    2380:	jmp    243d <botlish_fn_12+0x157>
    2385:	mov    rbx,rdi
    2388:	mov    rsi,r12
    238b:	test   rsi,0x1
    2392:	jne    23a0 <botlish_fn_12+0xba>
    2398:	mov    r12,rsi
    239b:	jmp    23b5 <botlish_fn_12+0xcf>
    23a0:	mov    rax,rsi
    23a3:	add    rax,0x2
    23a7:	mov    r12,rsi
    23aa:	seto   cl
    23ad:	test   cl,cl
    23af:	je     23c5 <botlish_fn_12+0xdf>
    23b5:	mov    edx,0x3
    23ba:	mov    rsi,r12
    23bd:	mov    rdi,rbx
    23c0:	call   23c5 <botlish_fn_12+0xdf>
			23c1: R_X86_64_PLT32	rt_int_add-0x4
    23c5:	mov    ecx,0x1
    23ca:	mov    rsi,r12
    23cd:	test   rsi,0x1
    23d4:	jne    23fa <botlish_fn_12+0x114>
    23da:	xor    ecx,ecx
    23dc:	mov    rsi,r12
    23df:	test   rsi,0x7
    23e6:	jne    23fa <botlish_fn_12+0x114>
    23ec:	mov    rsi,r12
    23ef:	movzx  rdx,BYTE PTR [rsi]
    23f3:	rex cmp dl,0x1
    23f7:	sete   cl
    23fa:	test   cl,cl
    23fc:	jne    2420 <botlish_fn_12+0x13a>
    2402:	mov    rdi,rbx
    2405:	mov    rsi,QWORD PTR [rdi+0x10]
    2409:	mov    rcx,QWORD PTR [rsi+0x110]
    2410:	xor    rdx,rdx
    2413:	mov    rsi,r12
    2416:	call   241b <botlish_fn_12+0x135>
			2417: R_X86_64_PLT32	rt_type_error-0x4
    241b:	jmp    243d <botlish_fn_12+0x157>
    2420:	mov    rdi,rbx
    2423:	mov    rbx,rax
    2426:	mov    rcx,rbx
    2429:	mov    rdx,r12
    242c:	mov    rsi,r14
    242f:	call   2434 <botlish_fn_12+0x14e>
			2430: R_X86_64_PLT32	rt_str_region_check-0x4
    2434:	test   rax,rax
    2437:	jne    245d <botlish_fn_12+0x177>
    243d:	xor    rax,rax
    2440:	mov    rbx,QWORD PTR [rsp+0x20]
    2445:	mov    r12,QWORD PTR [rsp+0x28]
    244a:	mov    r13,QWORD PTR [rsp+0x30]
    244f:	mov    r14,QWORD PTR [rsp+0x38]
    2454:	add    rsp,0x40
    2458:	mov    rsp,rbp
    245b:	pop    rbp
    245c:	ret
    245d:	mov    rcx,r13
    2460:	mov    rsi,r12
    2463:	mov    QWORD PTR [rcx],rsi
    2466:	mov    QWORD PTR [rcx+0x8],rbx
    246a:	mov    rax,r14
    246d:	mov    rbx,QWORD PTR [rsp+0x20]
    2472:	mov    r12,QWORD PTR [rsp+0x28]
    2477:	mov    r13,QWORD PTR [rsp+0x30]
    247c:	mov    r14,QWORD PTR [rsp+0x38]
    2481:	add    rsp,0x40
    2485:	mov    rsp,rbp
    2488:	pop    rbp
    2489:	ret

000000000000248a <botlish_entry_12: char_at<generic>>:
    248a:	push   rbp
    248b:	mov    rbp,rsp
    248e:	ud2

0000000000002490 <botlish_fn_13: scan_local<generic>>:
    2490:	push   rbp
    2491:	mov    rbp,rsp
    2494:	sub    rsp,0x80
    249b:	mov    QWORD PTR [rsp+0x50],rbx
    24a0:	mov    QWORD PTR [rsp+0x58],r12
    24a5:	mov    QWORD PTR [rsp+0x60],r13
    24aa:	mov    QWORD PTR [rsp+0x68],r14
    24af:	mov    QWORD PTR [rsp+0x70],r15
    24b4:	mov    rax,rdi
    24b7:	mov    QWORD PTR [rsp+0x18],0x0
    24c0:	mov    QWORD PTR [rsp],rsi
    24c4:	mov    r14,rsi
    24c7:	mov    QWORD PTR [rsp+0x8],rdx
    24cc:	mov    QWORD PTR [rsp+0x10],rcx
    24d1:	mov    r12,rcx
    24d4:	mov    r11d,0x1
    24da:	mov    rsi,r14
    24dd:	test   rsi,0x1
    24e4:	jne    2506 <botlish_fn_13+0x76>
    24ea:	xor    r11d,r11d
    24ed:	test   rsi,0x7
    24f4:	jne    2506 <botlish_fn_13+0x76>
    24fa:	movzx  rdi,BYTE PTR [rsi]
    24fe:	cmp    dil,0x1
    2502:	sete   r11b
    2506:	test   r11b,r11b
    2509:	jne    252a <botlish_fn_13+0x9a>
    250f:	mov    rdi,rax
    2512:	mov    r9,QWORD PTR [rdi+0x10]
    2516:	mov    rcx,QWORD PTR [r9+0xb8]
    251d:	xor    rdx,rdx
    2520:	call   2525 <botlish_fn_13+0x95>
			2521: R_X86_64_PLT32	rt_type_error-0x4
    2525:	jmp    25dd <botlish_fn_13+0x14d>
    252a:	mov    r13,rdx
    252d:	mov    r10,rsi
    2530:	and    r10,r13
    2533:	mov    r14,rsi
    2536:	test   r10,0x1
    253d:	jne    2569 <botlish_fn_13+0xd9>
    2543:	mov    rbx,rax
    2546:	mov    rdx,r13
    2549:	mov    rsi,r14
    254c:	mov    rdi,rbx
    254f:	call   2554 <botlish_fn_13+0xc4>
			2550: R_X86_64_PLT32	rt_int_cmp-0x4
    2554:	mov    ecx,0x2
    2559:	test   rax,rax
    255c:	cmovge rcx,QWORD PTR [rip+0x24c]        # 27b0 <botlish_fn_13+0x320>
    2564:	jmp    257f <botlish_fn_13+0xef>
    2569:	mov    rbx,rax
    256c:	mov    ecx,0x2
    2571:	mov    rsi,r14
    2574:	cmp    rsi,r13
    2577:	cmovge rcx,QWORD PTR [rip+0x231]        # 27b0 <botlish_fn_13+0x320>
    257f:	mov    eax,0x6
    2584:	mov    QWORD PTR [rsp+0x30],rax
    2589:	cmp    rcx,0x6
    258d:	je     2783 <botlish_fn_13+0x2f3>
    2593:	lea    rcx,[rsp+0x20]
    2598:	mov    rdx,r14
    259b:	mov    rsi,r12
    259e:	mov    rdi,rbx
    25a1:	call   25a6 <botlish_fn_13+0x116>
			25a2: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    25a6:	mov    rsi,rax
    25a9:	mov    r15,rax
    25ac:	test   rax,rsi
    25af:	je     25dd <botlish_fn_13+0x14d>
    25b5:	mov    rdx,QWORD PTR [rsp+0x20]
    25ba:	mov    QWORD PTR [rsp+0x40],rdx
    25bf:	mov    rcx,QWORD PTR [rsp+0x28]
    25c4:	mov    QWORD PTR [rsp+0x38],rcx
    25c9:	mov    rsi,r15
    25cc:	mov    rdi,rbx
    25cf:	call   25d4 <botlish_fn_13+0x144>
			25d0: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    25d4:	test   rax,rax
    25d7:	jne    2605 <botlish_fn_13+0x175>
    25dd:	xor    rax,rax
    25e0:	mov    rbx,QWORD PTR [rsp+0x50]
    25e5:	mov    r12,QWORD PTR [rsp+0x58]
    25ea:	mov    r13,QWORD PTR [rsp+0x60]
    25ef:	mov    r14,QWORD PTR [rsp+0x68]
    25f4:	mov    r15,QWORD PTR [rsp+0x70]
    25f9:	add    rsp,0x80
    2600:	mov    rsp,rbp
    2603:	pop    rbp
    2604:	ret
    2605:	cmp    rax,0x6
    2609:	je     2704 <botlish_fn_13+0x274>
    260f:	mov    rax,QWORD PTR [rbx+0x10]
    2613:	mov    r8,QWORD PTR [rax+0x118]
    261a:	mov    rcx,QWORD PTR [rsp+0x38]
    261f:	mov    rdx,QWORD PTR [rsp+0x40]
    2624:	mov    rsi,r15
    2627:	mov    rdi,rbx
    262a:	call   262f <botlish_fn_13+0x19f>
			262b: R_X86_64_PLT32	rt_str_region_eq-0x4
    262f:	cmp    rax,0x6
    2633:	je     26fa <botlish_fn_13+0x26a>
    2639:	mov    rax,QWORD PTR [rbx+0x10]
    263d:	mov    r8,QWORD PTR [rax+0x120]
    2644:	mov    rcx,QWORD PTR [rsp+0x38]
    2649:	mov    rdx,QWORD PTR [rsp+0x40]
    264e:	mov    rsi,r15
    2651:	mov    rdi,rbx
    2654:	call   2659 <botlish_fn_13+0x1c9>
			2655: R_X86_64_PLT32	rt_str_region_eq-0x4
    2659:	cmp    rax,0x6
    265d:	je     26f0 <botlish_fn_13+0x260>
    2663:	mov    rax,QWORD PTR [rbx+0x10]
    2667:	mov    r8,QWORD PTR [rax+0xc0]
    266e:	mov    rcx,QWORD PTR [rsp+0x38]
    2673:	mov    rdx,QWORD PTR [rsp+0x40]
    2678:	mov    rsi,r15
    267b:	mov    rdi,rbx
    267e:	call   2683 <botlish_fn_13+0x1f3>
			267f: R_X86_64_PLT32	rt_str_region_eq-0x4
    2683:	cmp    rax,0x6
    2687:	je     26e6 <botlish_fn_13+0x256>
    268d:	mov    rax,QWORD PTR [rbx+0x10]
    2691:	mov    r8,QWORD PTR [rax+0x108]
    2698:	mov    rcx,QWORD PTR [rsp+0x38]
    269d:	mov    rdx,QWORD PTR [rsp+0x40]
    26a2:	mov    rsi,r15
    26a5:	mov    rdi,rbx
    26a8:	call   26ad <botlish_fn_13+0x21d>
			26a9: R_X86_64_PLT32	rt_str_region_eq-0x4
    26ad:	cmp    rax,0x6
    26b1:	je     26dc <botlish_fn_13+0x24c>
    26b7:	mov    rax,QWORD PTR [rbx+0x10]
    26bb:	mov    r8,QWORD PTR [rax+0x128]
    26c2:	mov    rcx,QWORD PTR [rsp+0x38]
    26c7:	mov    rdx,QWORD PTR [rsp+0x40]
    26cc:	mov    rsi,r15
    26cf:	mov    rdi,rbx
    26d2:	call   26d7 <botlish_fn_13+0x247>
			26d3: R_X86_64_PLT32	rt_str_region_eq-0x4
    26d7:	jmp    2709 <botlish_fn_13+0x279>
    26dc:	mov    rax,QWORD PTR [rsp+0x30]
    26e1:	jmp    2709 <botlish_fn_13+0x279>
    26e6:	mov    rax,QWORD PTR [rsp+0x30]
    26eb:	jmp    2709 <botlish_fn_13+0x279>
    26f0:	mov    rax,QWORD PTR [rsp+0x30]
    26f5:	jmp    2709 <botlish_fn_13+0x279>
    26fa:	mov    rax,QWORD PTR [rsp+0x30]
    26ff:	jmp    2709 <botlish_fn_13+0x279>
    2704:	mov    rax,QWORD PTR [rsp+0x30]
    2709:	cmp    rax,0x6
    270d:	je     271b <botlish_fn_13+0x28b>
    2713:	mov    rax,r14
    2716:	jmp    2786 <botlish_fn_13+0x2f6>
    271b:	mov    QWORD PTR [rsp+0x18],0x3
    2724:	mov    rsi,r14
    2727:	test   rsi,0x1
    272e:	je     2754 <botlish_fn_13+0x2c4>
    2734:	mov    rsi,r14
    2737:	mov    rax,rsi
    273a:	add    rax,0x2
    273e:	seto   cl
    2741:	test   cl,cl
    2743:	jne    2754 <botlish_fn_13+0x2c4>
    2749:	mov    rsi,rax
    274c:	mov    r14,rax
    274f:	jmp    276a <botlish_fn_13+0x2da>
    2754:	mov    edx,0x3
    2759:	mov    rsi,r14
    275c:	mov    rdi,rbx
    275f:	call   2764 <botlish_fn_13+0x2d4>
			2760: R_X86_64_PLT32	rt_int_add-0x4
    2764:	mov    rsi,rax
    2767:	mov    r14,rax
    276a:	mov    QWORD PTR [rsp],rsi
    276e:	mov    QWORD PTR [rsp+0x8],r13
    2773:	mov    QWORD PTR [rsp+0x10],r12
    2778:	mov    rax,rbx
    277b:	mov    rdx,r13
    277e:	jmp    24d4 <botlish_fn_13+0x44>
    2783:	mov    rax,r14
    2786:	mov    rbx,QWORD PTR [rsp+0x50]
    278b:	mov    r12,QWORD PTR [rsp+0x58]
    2790:	mov    r13,QWORD PTR [rsp+0x60]
    2795:	mov    r14,QWORD PTR [rsp+0x68]
    279a:	mov    r15,QWORD PTR [rsp+0x70]
    279f:	add    rsp,0x80
    27a6:	mov    rsp,rbp
    27a9:	pop    rbp
    27aa:	ret
    27ab:	add    BYTE PTR [rax],al
    27ad:	add    BYTE PTR [rax],al
    27af:	add    BYTE PTR [rsi],al
    27b1:	add    BYTE PTR [rax],al
    27b3:	add    BYTE PTR [rax],al
    27b5:	add    BYTE PTR [rax],al
	...

00000000000027b8 <botlish_entry_13: scan_local<generic>>:
    27b8:	push   rbp
    27b9:	mov    rbp,rsp
    27bc:	mov    rsi,QWORD PTR [rdx]
    27bf:	mov    r8,QWORD PTR [rdx+0x8]
    27c3:	mov    rcx,QWORD PTR [rdx+0x10]
    27c7:	mov    rdx,r8
    27ca:	call   27cf <botlish_entry_13+0x17>
			27cb: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_local<generic>
    27cf:	mov    rsp,rbp
    27d2:	pop    rbp
    27d3:	ret
    27d4:	add    BYTE PTR [rax],al
	...

00000000000027d8 <botlish_fn_14: scan_label<generic>>:
    27d8:	push   rbp
    27d9:	mov    rbp,rsp
    27dc:	sub    rsp,0x80
    27e3:	mov    QWORD PTR [rsp+0x50],rbx
    27e8:	mov    QWORD PTR [rsp+0x58],r12
    27ed:	mov    QWORD PTR [rsp+0x60],r13
    27f2:	mov    QWORD PTR [rsp+0x68],r14
    27f7:	mov    QWORD PTR [rsp+0x70],r15
    27fc:	mov    QWORD PTR [rsp+0x18],0x0
    2805:	mov    QWORD PTR [rsp],rsi
    2809:	mov    r14,rsi
    280c:	mov    QWORD PTR [rsp+0x8],rdx
    2811:	mov    QWORD PTR [rsp+0x10],rcx
    2816:	mov    r12,rcx
    2819:	mov    r11d,0x1
    281f:	mov    rsi,r14
    2822:	test   rsi,0x1
    2829:	jne    2849 <botlish_fn_14+0x71>
    282f:	xor    r11d,r11d
    2832:	test   rsi,0x7
    2839:	jne    2849 <botlish_fn_14+0x71>
    283f:	movzx  rax,BYTE PTR [rsi]
    2843:	cmp    al,0x1
    2845:	sete   r11b
    2849:	test   r11b,r11b
    284c:	jne    286a <botlish_fn_14+0x92>
    2852:	mov    rax,QWORD PTR [rdi+0x10]
    2856:	mov    rcx,QWORD PTR [rax+0xb8]
    285d:	xor    rdx,rdx
    2860:	call   2865 <botlish_fn_14+0x8d>
			2861: R_X86_64_PLT32	rt_type_error-0x4
    2865:	jmp    2916 <botlish_fn_14+0x13e>
    286a:	mov    r13,rdx
    286d:	mov    rax,rsi
    2870:	and    rax,r13
    2873:	mov    r14,rsi
    2876:	test   rax,0x1
    287c:	jne    28a5 <botlish_fn_14+0xcd>
    2882:	mov    rbx,rdi
    2885:	mov    rdx,r13
    2888:	mov    rsi,r14
    288b:	call   2890 <botlish_fn_14+0xb8>
			288c: R_X86_64_PLT32	rt_int_cmp-0x4
    2890:	mov    ecx,0x2
    2895:	test   rax,rax
    2898:	cmovge rcx,QWORD PTR [rip+0x178]        # 2a18 <botlish_fn_14+0x240>
    28a0:	jmp    28bb <botlish_fn_14+0xe3>
    28a5:	mov    rbx,rdi
    28a8:	mov    ecx,0x2
    28ad:	mov    rsi,r14
    28b0:	cmp    rsi,r13
    28b3:	cmovge rcx,QWORD PTR [rip+0x15d]        # 2a18 <botlish_fn_14+0x240>
    28bb:	mov    eax,0x6
    28c0:	mov    QWORD PTR [rsp+0x30],rax
    28c5:	cmp    rcx,0x6
    28c9:	je     29ec <botlish_fn_14+0x214>
    28cf:	lea    rcx,[rsp+0x20]
    28d4:	mov    rdx,r14
    28d7:	mov    rsi,r12
    28da:	mov    rdi,rbx
    28dd:	call   28e2 <botlish_fn_14+0x10a>
			28de: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    28e2:	test   rax,rax
    28e5:	mov    r15,rax
    28e8:	je     2916 <botlish_fn_14+0x13e>
    28ee:	mov    rdx,QWORD PTR [rsp+0x20]
    28f3:	mov    QWORD PTR [rsp+0x40],rdx
    28f8:	mov    rcx,QWORD PTR [rsp+0x28]
    28fd:	mov    QWORD PTR [rsp+0x38],rcx
    2902:	mov    rsi,r15
    2905:	mov    rdi,rbx
    2908:	call   290d <botlish_fn_14+0x135>
			2909: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    290d:	test   rax,rax
    2910:	jne    293e <botlish_fn_14+0x166>
    2916:	xor    rax,rax
    2919:	mov    rbx,QWORD PTR [rsp+0x50]
    291e:	mov    r12,QWORD PTR [rsp+0x58]
    2923:	mov    r13,QWORD PTR [rsp+0x60]
    2928:	mov    r14,QWORD PTR [rsp+0x68]
    292d:	mov    r15,QWORD PTR [rsp+0x70]
    2932:	add    rsp,0x80
    2939:	mov    rsp,rbp
    293c:	pop    rbp
    293d:	ret
    293e:	cmp    rax,0x6
    2942:	je     296d <botlish_fn_14+0x195>
    2948:	mov    r11,QWORD PTR [rbx+0x10]
    294c:	mov    r8,QWORD PTR [r11+0x128]
    2953:	mov    rcx,QWORD PTR [rsp+0x38]
    2958:	mov    rdx,QWORD PTR [rsp+0x40]
    295d:	mov    rsi,r15
    2960:	mov    rdi,rbx
    2963:	call   2968 <botlish_fn_14+0x190>
			2964: R_X86_64_PLT32	rt_str_region_eq-0x4
    2968:	jmp    2972 <botlish_fn_14+0x19a>
    296d:	mov    rax,QWORD PTR [rsp+0x30]
    2972:	cmp    rax,0x6
    2976:	je     2984 <botlish_fn_14+0x1ac>
    297c:	mov    rax,r14
    297f:	jmp    29ef <botlish_fn_14+0x217>
    2984:	mov    QWORD PTR [rsp+0x18],0x3
    298d:	mov    rsi,r14
    2990:	test   rsi,0x1
    2997:	je     29bd <botlish_fn_14+0x1e5>
    299d:	mov    rsi,r14
    29a0:	mov    rax,rsi
    29a3:	add    rax,0x2
    29a7:	seto   cl
    29aa:	test   cl,cl
    29ac:	jne    29bd <botlish_fn_14+0x1e5>
    29b2:	mov    rsi,rax
    29b5:	mov    r14,rax
    29b8:	jmp    29d3 <botlish_fn_14+0x1fb>
    29bd:	mov    edx,0x3
    29c2:	mov    rsi,r14
    29c5:	mov    rdi,rbx
    29c8:	call   29cd <botlish_fn_14+0x1f5>
			29c9: R_X86_64_PLT32	rt_int_add-0x4
    29cd:	mov    rsi,rax
    29d0:	mov    r14,rax
    29d3:	mov    QWORD PTR [rsp],rsi
    29d7:	mov    QWORD PTR [rsp+0x8],r13
    29dc:	mov    QWORD PTR [rsp+0x10],r12
    29e1:	mov    rdx,r13
    29e4:	mov    rdi,rbx
    29e7:	jmp    2819 <botlish_fn_14+0x41>
    29ec:	mov    rax,r14
    29ef:	mov    rbx,QWORD PTR [rsp+0x50]
    29f4:	mov    r12,QWORD PTR [rsp+0x58]
    29f9:	mov    r13,QWORD PTR [rsp+0x60]
    29fe:	mov    r14,QWORD PTR [rsp+0x68]
    2a03:	mov    r15,QWORD PTR [rsp+0x70]
    2a08:	add    rsp,0x80
    2a0f:	mov    rsp,rbp
    2a12:	pop    rbp
    2a13:	ret
    2a14:	add    BYTE PTR [rax],al
    2a16:	add    BYTE PTR [rax],al
    2a18:	(bad)
    2a19:	add    BYTE PTR [rax],al
    2a1b:	add    BYTE PTR [rax],al
    2a1d:	add    BYTE PTR [rax],al
	...

0000000000002a20 <botlish_entry_14: scan_label<generic>>:
    2a20:	push   rbp
    2a21:	mov    rbp,rsp
    2a24:	mov    rsi,QWORD PTR [rdx]
    2a27:	mov    r8,QWORD PTR [rdx+0x8]
    2a2b:	mov    rcx,QWORD PTR [rdx+0x10]
    2a2f:	mov    rdx,r8
    2a32:	call   2a37 <botlish_entry_14+0x17>
			2a33: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_label<generic>
    2a37:	mov    rsp,rbp
    2a3a:	pop    rbp
    2a3b:	ret
    2a3c:	add    BYTE PTR [rax],al
	...

0000000000002a40 <botlish_fn_15: scan_alpha<generic>>:
    2a40:	push   rbp
    2a41:	mov    rbp,rsp
    2a44:	sub    rsp,0x50
    2a48:	mov    QWORD PTR [rsp+0x30],rbx
    2a4d:	mov    QWORD PTR [rsp+0x38],r12
    2a52:	mov    QWORD PTR [rsp+0x40],r13
    2a57:	mov    QWORD PTR [rsp+0x48],r14
    2a5c:	mov    r14,rdi
    2a5f:	mov    QWORD PTR [rsp+0x18],0x0
    2a68:	mov    QWORD PTR [rsp],rsi
    2a6c:	mov    r13,rsi
    2a6f:	mov    QWORD PTR [rsp+0x8],rdx
    2a74:	mov    r12,rdx
    2a77:	mov    QWORD PTR [rsp+0x10],rcx
    2a7c:	mov    rbx,rcx
    2a7f:	mov    r11d,0x1
    2a85:	mov    rsi,r13
    2a88:	test   rsi,0x1
    2a8f:	jne    2aaf <botlish_fn_15+0x6f>
    2a95:	xor    r11d,r11d
    2a98:	test   rsi,0x7
    2a9f:	jne    2aaf <botlish_fn_15+0x6f>
    2aa5:	movzx  rax,BYTE PTR [rsi]
    2aa9:	cmp    al,0x1
    2aab:	sete   r11b
    2aaf:	test   r11b,r11b
    2ab2:	jne    2ad3 <botlish_fn_15+0x93>
    2ab8:	mov    rdi,r14
    2abb:	mov    rax,QWORD PTR [rdi+0x10]
    2abf:	mov    rcx,QWORD PTR [rax+0xb8]
    2ac6:	xor    rdx,rdx
    2ac9:	call   2ace <botlish_fn_15+0x8e>
			2aca: R_X86_64_PLT32	rt_type_error-0x4
    2ace:	jmp    2b62 <botlish_fn_15+0x122>
    2ad3:	mov    rax,rsi
    2ad6:	and    rax,r12
    2ad9:	mov    r13,rsi
    2adc:	test   rax,0x1
    2ae2:	jne    2b0b <botlish_fn_15+0xcb>
    2ae8:	mov    rdx,r12
    2aeb:	mov    rsi,r13
    2aee:	mov    rdi,r14
    2af1:	call   2af6 <botlish_fn_15+0xb6>
			2af2: R_X86_64_PLT32	rt_int_cmp-0x4
    2af6:	mov    ecx,0x2
    2afb:	test   rax,rax
    2afe:	cmovge rcx,QWORD PTR [rip+0x112]        # 2c18 <botlish_fn_15+0x1d8>
    2b06:	jmp    2b1e <botlish_fn_15+0xde>
    2b0b:	mov    ecx,0x2
    2b10:	mov    rsi,r13
    2b13:	cmp    rsi,r12
    2b16:	cmovge rcx,QWORD PTR [rip+0xfa]        # 2c18 <botlish_fn_15+0x1d8>
    2b1e:	cmp    rcx,0x6
    2b22:	je     2bf6 <botlish_fn_15+0x1b6>
    2b28:	lea    rcx,[rsp+0x20]
    2b2d:	mov    rdx,r13
    2b30:	mov    rsi,rbx
    2b33:	mov    rdi,r14
    2b36:	call   2b3b <botlish_fn_15+0xfb>
			2b37: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    2b3b:	test   rax,rax
    2b3e:	mov    rsi,rax
    2b41:	je     2b62 <botlish_fn_15+0x122>
    2b47:	mov    rdx,QWORD PTR [rsp+0x20]
    2b4c:	mov    rcx,QWORD PTR [rsp+0x28]
    2b51:	mov    rdi,r14
    2b54:	call   2b59 <botlish_fn_15+0x119>
			2b55: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    2b59:	test   rax,rax
    2b5c:	jne    2b82 <botlish_fn_15+0x142>
    2b62:	xor    rax,rax
    2b65:	mov    rbx,QWORD PTR [rsp+0x30]
    2b6a:	mov    r12,QWORD PTR [rsp+0x38]
    2b6f:	mov    r13,QWORD PTR [rsp+0x40]
    2b74:	mov    r14,QWORD PTR [rsp+0x48]
    2b79:	add    rsp,0x50
    2b7d:	mov    rsp,rbp
    2b80:	pop    rbp
    2b81:	ret
    2b82:	cmp    rax,0x6
    2b86:	je     2b94 <botlish_fn_15+0x154>
    2b8c:	mov    rax,r13
    2b8f:	jmp    2bf9 <botlish_fn_15+0x1b9>
    2b94:	mov    QWORD PTR [rsp+0x18],0x3
    2b9d:	mov    rsi,r13
    2ba0:	test   rsi,0x1
    2ba7:	je     2bcd <botlish_fn_15+0x18d>
    2bad:	mov    rsi,r13
    2bb0:	mov    r11,rsi
    2bb3:	add    r11,0x2
    2bb7:	seto   al
    2bba:	test   al,al
    2bbc:	jne    2bcd <botlish_fn_15+0x18d>
    2bc2:	mov    rsi,r11
    2bc5:	mov    r13,r11
    2bc8:	jmp    2be3 <botlish_fn_15+0x1a3>
    2bcd:	mov    edx,0x3
    2bd2:	mov    rsi,r13
    2bd5:	mov    rdi,r14
    2bd8:	call   2bdd <botlish_fn_15+0x19d>
			2bd9: R_X86_64_PLT32	rt_int_add-0x4
    2bdd:	mov    rsi,rax
    2be0:	mov    r13,rax
    2be3:	mov    QWORD PTR [rsp],rsi
    2be7:	mov    QWORD PTR [rsp+0x8],r12
    2bec:	mov    QWORD PTR [rsp+0x10],rbx
    2bf1:	jmp    2a7f <botlish_fn_15+0x3f>
    2bf6:	mov    rax,r13
    2bf9:	mov    rbx,QWORD PTR [rsp+0x30]
    2bfe:	mov    r12,QWORD PTR [rsp+0x38]
    2c03:	mov    r13,QWORD PTR [rsp+0x40]
    2c08:	mov    r14,QWORD PTR [rsp+0x48]
    2c0d:	add    rsp,0x50
    2c11:	mov    rsp,rbp
    2c14:	pop    rbp
    2c15:	ret
    2c16:	add    BYTE PTR [rax],al
    2c18:	(bad)
    2c19:	add    BYTE PTR [rax],al
    2c1b:	add    BYTE PTR [rax],al
    2c1d:	add    BYTE PTR [rax],al
	...

0000000000002c20 <botlish_entry_15: scan_alpha<generic>>:
    2c20:	push   rbp
    2c21:	mov    rbp,rsp
    2c24:	mov    rsi,QWORD PTR [rdx]
    2c27:	mov    r8,QWORD PTR [rdx+0x8]
    2c2b:	mov    rcx,QWORD PTR [rdx+0x10]
    2c2f:	mov    rdx,r8
    2c32:	call   2c37 <botlish_entry_15+0x17>
			2c33: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_alpha<generic>
    2c37:	mov    rsp,rbp
    2c3a:	pop    rbp
    2c3b:	ret
    2c3c:	add    BYTE PTR [rax],al
	...

0000000000002c40 <botlish_fn_16: tld_ok<generic>>:
    2c40:	push   rbp
    2c41:	mov    rbp,rsp
    2c44:	sub    rsp,0x40
    2c48:	mov    QWORD PTR [rsp+0x20],rbx
    2c4d:	mov    QWORD PTR [rsp+0x28],r12
    2c52:	mov    QWORD PTR [rsp+0x30],r13
    2c57:	mov    QWORD PTR [rsp+0x38],r14
    2c5c:	mov    rbx,rdi
    2c5f:	mov    QWORD PTR [rsp],rsi
    2c63:	mov    r12,rsi
    2c66:	mov    QWORD PTR [rsp+0x8],rdx
    2c6b:	mov    r14,rdx
    2c6e:	mov    QWORD PTR [rsp+0x10],rcx
    2c73:	mov    rdx,r14
    2c76:	mov    rsi,r12
    2c79:	mov    rdi,rbx
    2c7c:	call   2c81 <botlish_fn_16+0x41>
			2c7d: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_alpha<generic>
    2c81:	mov    rsi,rax
    2c84:	mov    r13,rax
    2c87:	test   rax,rsi
    2c8a:	je     2d4d <botlish_fn_16+0x10d>
    2c90:	mov    rax,r13
    2c93:	mov    QWORD PTR [rsp+0x8],rax
    2c98:	mov    rdx,r14
    2c9b:	and    rax,rdx
    2c9e:	test   rax,0x1
    2ca4:	jne    2ccd <botlish_fn_16+0x8d>
    2caa:	mov    rsi,r13
    2cad:	mov    rdi,rbx
    2cb0:	call   2cb5 <botlish_fn_16+0x75>
			2cb1: R_X86_64_PLT32	rt_int_cmp-0x4
    2cb5:	mov    ecx,0x2
    2cba:	test   rax,rax
    2cbd:	cmove  rcx,QWORD PTR [rip+0x15b]        # 2e20 <botlish_fn_16+0x1e0>
    2cc5:	mov    rax,r13
    2cc8:	jmp    2ce0 <botlish_fn_16+0xa0>
    2ccd:	mov    ecx,0x2
    2cd2:	mov    rax,r13
    2cd5:	cmp    rax,rdx
    2cd8:	cmove  rcx,QWORD PTR [rip+0x140]        # 2e20 <botlish_fn_16+0x1e0>
    2ce0:	cmp    rcx,0x6
    2ce4:	je     2cf7 <botlish_fn_16+0xb7>
    2cea:	mov    ecx,0x2
    2cef:	mov    rax,rcx
    2cf2:	jmp    2dff <botlish_fn_16+0x1bf>
    2cf7:	mov    ecx,0x1
    2cfc:	mov    rsi,r12
    2cff:	test   rsi,0x1
    2d06:	jne    2d2c <botlish_fn_16+0xec>
    2d0c:	xor    ecx,ecx
    2d0e:	mov    rsi,r12
    2d11:	test   rsi,0x7
    2d18:	jne    2d2c <botlish_fn_16+0xec>
    2d1e:	mov    rsi,r12
    2d21:	movzx  rcx,BYTE PTR [rsi]
    2d25:	rex cmp cl,0x1
    2d29:	sete   cl
    2d2c:	test   cl,cl
    2d2e:	jne    2d6d <botlish_fn_16+0x12d>
    2d34:	mov    rdi,rbx
    2d37:	mov    rsi,QWORD PTR [rdi+0x10]
    2d3b:	mov    rcx,QWORD PTR [rsi+0x128]
    2d42:	xor    rdx,rdx
    2d45:	mov    rsi,r12
    2d48:	call   2d4d <botlish_fn_16+0x10d>
			2d49: R_X86_64_PLT32	rt_type_error-0x4
    2d4d:	xor    rax,rax
    2d50:	mov    rbx,QWORD PTR [rsp+0x20]
    2d55:	mov    r12,QWORD PTR [rsp+0x28]
    2d5a:	mov    r13,QWORD PTR [rsp+0x30]
    2d5f:	mov    r14,QWORD PTR [rsp+0x38]
    2d64:	add    rsp,0x40
    2d68:	mov    rsp,rbp
    2d6b:	pop    rbp
    2d6c:	ret
    2d6d:	mov    rsi,r12
    2d70:	mov    rdi,rax
    2d73:	and    rdi,rsi
    2d76:	test   rdi,0x1
    2d7d:	jne    2d8e <botlish_fn_16+0x14e>
    2d83:	mov    rdx,r12
    2d86:	mov    rsi,rax
    2d89:	jmp    2db1 <botlish_fn_16+0x171>
    2d8e:	mov    rsi,r12
    2d91:	mov    r8,rax
    2d94:	sub    r8,rsi
    2d97:	mov    r13,rax
    2d9a:	seto   r10b
    2d9e:	lea    rsi,[r8+0x1]
    2da2:	test   r10b,r10b
    2da5:	je     2dbc <botlish_fn_16+0x17c>
    2dab:	mov    rdx,r12
    2dae:	mov    rsi,r13
    2db1:	mov    rdi,rbx
    2db4:	call   2db9 <botlish_fn_16+0x179>
			2db5: R_X86_64_PLT32	rt_int_sub-0x4
    2db9:	mov    rsi,rax
    2dbc:	test   rsi,0x1
    2dc3:	jne    2dee <botlish_fn_16+0x1ae>
    2dc9:	mov    edx,0x5
    2dce:	mov    rdi,rbx
    2dd1:	call   2dd6 <botlish_fn_16+0x196>
			2dd2: R_X86_64_PLT32	rt_int_cmp-0x4
    2dd6:	mov    ecx,0x2
    2ddb:	test   rax,rax
    2dde:	mov    rax,rcx
    2de1:	cmovge rax,QWORD PTR [rip+0x37]        # 2e20 <botlish_fn_16+0x1e0>
    2de9:	jmp    2dff <botlish_fn_16+0x1bf>
    2dee:	mov    eax,0x2
    2df3:	cmp    rsi,0x5
    2df7:	cmovge rax,QWORD PTR [rip+0x21]        # 2e20 <botlish_fn_16+0x1e0>
    2dff:	mov    rbx,QWORD PTR [rsp+0x20]
    2e04:	mov    r12,QWORD PTR [rsp+0x28]
    2e09:	mov    r13,QWORD PTR [rsp+0x30]
    2e0e:	mov    r14,QWORD PTR [rsp+0x38]
    2e13:	add    rsp,0x40
    2e17:	mov    rsp,rbp
    2e1a:	pop    rbp
    2e1b:	ret
    2e1c:	add    BYTE PTR [rax],al
    2e1e:	add    BYTE PTR [rax],al
    2e20:	(bad)
    2e21:	add    BYTE PTR [rax],al
    2e23:	add    BYTE PTR [rax],al
    2e25:	add    BYTE PTR [rax],al
	...

0000000000002e28 <botlish_entry_16: tld_ok<generic>>:
    2e28:	push   rbp
    2e29:	mov    rbp,rsp
    2e2c:	mov    rsi,QWORD PTR [rdx]
    2e2f:	mov    r8,QWORD PTR [rdx+0x8]
    2e33:	mov    rcx,QWORD PTR [rdx+0x10]
    2e37:	mov    rdx,r8
    2e3a:	call   2e3f <botlish_entry_16+0x17>
			2e3b: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld_ok<generic>
    2e3f:	mov    rsp,rbp
    2e42:	pop    rbp
    2e43:	ret
    2e44:	add    BYTE PTR [rax],al
	...

0000000000002e48 <botlish_fn_17: domain_loop<generic>>:
    2e48:	push   rbp
    2e49:	mov    rbp,rsp
    2e4c:	sub    rsp,0x70
    2e50:	mov    QWORD PTR [rsp+0x40],rbx
    2e55:	mov    QWORD PTR [rsp+0x48],r12
    2e5a:	mov    QWORD PTR [rsp+0x50],r13
    2e5f:	mov    QWORD PTR [rsp+0x58],r14
    2e64:	mov    QWORD PTR [rsp+0x60],r15
    2e69:	mov    QWORD PTR [rsp+0x18],0x0
    2e72:	mov    QWORD PTR [rsp],rsi
    2e76:	mov    QWORD PTR [rsp+0x8],rdx
    2e7b:	mov    QWORD PTR [rsp+0x10],rcx
    2e80:	lea    rbx,[rsp+0x20]
    2e85:	mov    r12,rdi
    2e88:	mov    r13,rcx
    2e8b:	mov    r14,rdx
    2e8e:	mov    QWORD PTR [rsp+0x30],rsi
    2e93:	mov    rcx,r13
    2e96:	mov    rdx,r14
    2e99:	mov    rsi,QWORD PTR [rsp+0x30]
    2e9e:	mov    rdi,r12
    2ea1:	call   2ea6 <botlish_fn_17+0x5e>
			2ea2: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_label<generic>
    2ea6:	mov    rcx,rax
    2ea9:	mov    r15,rax
    2eac:	test   rax,rcx
    2eaf:	je     2fff <botlish_fn_17+0x1b7>
    2eb5:	mov    rax,r15
    2eb8:	mov    QWORD PTR [rsp],rax
    2ebc:	mov    rdx,QWORD PTR [rsp+0x30]
    2ec1:	and    rax,rdx
    2ec4:	test   rax,0x1
    2eca:	jne    2ee9 <botlish_fn_17+0xa1>
    2ed0:	mov    rsi,r15
    2ed3:	mov    rdi,r12
    2ed6:	call   2edb <botlish_fn_17+0x93>
			2ed7: R_X86_64_PLT32	rt_value_eq-0x4
    2edb:	test   rax,rax
    2ede:	je     2fff <botlish_fn_17+0x1b7>
    2ee4:	jmp    2ef9 <botlish_fn_17+0xb1>
    2ee9:	mov    eax,0x2
    2eee:	cmp    r15,rdx
    2ef1:	cmove  rax,QWORD PTR [rip+0x187]        # 3080 <botlish_fn_17+0x238>
    2ef9:	cmp    rax,0x6
    2efd:	je     3055 <botlish_fn_17+0x20d>
    2f03:	mov    rax,r15
    2f06:	and    rax,r14
    2f09:	test   rax,0x1
    2f0f:	jne    2f38 <botlish_fn_17+0xf0>
    2f15:	mov    rdx,r14
    2f18:	mov    rsi,r15
    2f1b:	mov    rdi,r12
    2f1e:	call   2f23 <botlish_fn_17+0xdb>
			2f1f: R_X86_64_PLT32	rt_int_cmp-0x4
    2f23:	mov    ecx,0x2
    2f28:	test   rax,rax
    2f2b:	cmovge rcx,QWORD PTR [rip+0x14d]        # 3080 <botlish_fn_17+0x238>
    2f33:	jmp    2f48 <botlish_fn_17+0x100>
    2f38:	mov    ecx,0x2
    2f3d:	cmp    r15,r14
    2f40:	cmovge rcx,QWORD PTR [rip+0x138]        # 3080 <botlish_fn_17+0x238>
    2f48:	cmp    rcx,0x6
    2f4c:	je     3046 <botlish_fn_17+0x1fe>
    2f52:	mov    rcx,rbx
    2f55:	mov    rdx,r15
    2f58:	mov    rsi,r13
    2f5b:	mov    rdi,r12
    2f5e:	call   2f63 <botlish_fn_17+0x11b>
			2f5f: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    2f63:	test   rax,rax
    2f66:	je     2fff <botlish_fn_17+0x1b7>
    2f6c:	mov    rdx,QWORD PTR [rsp+0x20]
    2f71:	mov    rcx,QWORD PTR [rsp+0x28]
    2f76:	mov    rsi,QWORD PTR [r12+0x10]
    2f7b:	mov    r8,QWORD PTR [rsi+0x118]
    2f82:	mov    rsi,rax
    2f85:	mov    rdi,r12
    2f88:	call   2f8d <botlish_fn_17+0x145>
			2f89: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f8d:	cmp    rax,0x6
    2f91:	je     2fa3 <botlish_fn_17+0x15b>
    2f97:	mov    r14,0xffffffffffffffff
    2f9e:	jmp    304d <botlish_fn_17+0x205>
    2fa3:	mov    QWORD PTR [rsp+0x18],0x3
    2fac:	test   r15,0x1
    2fb3:	je     2fcb <botlish_fn_17+0x183>
    2fb9:	mov    rdx,r15
    2fbc:	add    rdx,0x2
    2fc0:	seto   al
    2fc3:	test   al,al
    2fc5:	je     2fde <botlish_fn_17+0x196>
    2fcb:	mov    edx,0x3
    2fd0:	mov    rsi,r15
    2fd3:	mov    rdi,r12
    2fd6:	call   2fdb <botlish_fn_17+0x193>
			2fd7: R_X86_64_PLT32	rt_int_add-0x4
    2fdb:	mov    rdx,rax
    2fde:	mov    QWORD PTR [rsp],rdx
    2fe2:	mov    r15,rdx
    2fe5:	mov    rcx,r13
    2fe8:	mov    rdx,r14
    2feb:	mov    rsi,r15
    2fee:	mov    rdi,r12
    2ff1:	call   2ff6 <botlish_fn_17+0x1ae>
			2ff2: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld_ok<generic>
    2ff6:	test   rax,rax
    2ff9:	jne    3024 <botlish_fn_17+0x1dc>
    2fff:	xor    rax,rax
    3002:	mov    rbx,QWORD PTR [rsp+0x40]
    3007:	mov    r12,QWORD PTR [rsp+0x48]
    300c:	mov    r13,QWORD PTR [rsp+0x50]
    3011:	mov    r14,QWORD PTR [rsp+0x58]
    3016:	mov    r15,QWORD PTR [rsp+0x60]
    301b:	add    rsp,0x70
    301f:	mov    rsp,rbp
    3022:	pop    rbp
    3023:	ret
    3024:	cmp    rax,0x6
    3028:	je     304d <botlish_fn_17+0x205>
    302e:	mov    QWORD PTR [rsp],r15
    3032:	mov    QWORD PTR [rsp+0x8],r14
    3037:	mov    QWORD PTR [rsp+0x10],r13
    303c:	mov    QWORD PTR [rsp+0x30],r15
    3041:	jmp    2e93 <botlish_fn_17+0x4b>
    3046:	mov    r14,0xffffffffffffffff
    304d:	mov    rax,r14
    3050:	jmp    305c <botlish_fn_17+0x214>
    3055:	mov    rax,0xffffffffffffffff
    305c:	mov    rbx,QWORD PTR [rsp+0x40]
    3061:	mov    r12,QWORD PTR [rsp+0x48]
    3066:	mov    r13,QWORD PTR [rsp+0x50]
    306b:	mov    r14,QWORD PTR [rsp+0x58]
    3070:	mov    r15,QWORD PTR [rsp+0x60]
    3075:	add    rsp,0x70
    3079:	mov    rsp,rbp
    307c:	pop    rbp
    307d:	ret
    307e:	add    BYTE PTR [rax],al
    3080:	(bad)
    3081:	add    BYTE PTR [rax],al
    3083:	add    BYTE PTR [rax],al
    3085:	add    BYTE PTR [rax],al
	...

0000000000003088 <botlish_entry_17: domain_loop<generic>>:
    3088:	push   rbp
    3089:	mov    rbp,rsp
    308c:	mov    rsi,QWORD PTR [rdx]
    308f:	mov    r8,QWORD PTR [rdx+0x8]
    3093:	mov    rcx,QWORD PTR [rdx+0x10]
    3097:	mov    rdx,r8
    309a:	call   309f <botlish_entry_17+0x17>
			309b: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain_loop<generic>
    309f:	mov    rsp,rbp
    30a2:	pop    rbp
    30a3:	ret
    30a4:	add    BYTE PTR [rax],al
	...

00000000000030a8 <botlish_fn_18: <str>>:
    30a8:	push   rbp
    30a9:	mov    rbp,rsp
    30ac:	sub    rsp,0x70
    30b0:	mov    QWORD PTR [rsp+0x40],rbx
    30b5:	mov    QWORD PTR [rsp+0x48],r12
    30ba:	mov    QWORD PTR [rsp+0x50],r13
    30bf:	mov    QWORD PTR [rsp+0x58],r14
    30c4:	mov    QWORD PTR [rsp+0x60],r15
    30c9:	mov    r13,rdi
    30cc:	mov    QWORD PTR [rsp+0x10],0x0
    30d5:	mov    QWORD PTR [rsp+0x18],0x0
    30de:	mov    QWORD PTR [rsp],rsi
    30e2:	mov    r12,rsi
    30e5:	mov    rsi,r12
    30e8:	mov    rdi,r13
    30eb:	call   30f0 <botlish_fn_18+0x48>
			30ec: R_X86_64_PLT32	rt_str_len-0x4
    30f0:	mov    r14,rax
    30f3:	mov    QWORD PTR [rsp+0x8],rax
    30f8:	lea    r8,[rsp+0x20]
    30fd:	mov    QWORD PTR [rsp+0x20],r12
    3102:	mov    esi,0x14
    3107:	mov    rdx,QWORD PTR [rip+0x0]        # 310e <botlish_fn_18+0x66>
			310a: R_X86_64_GOTPCREL	botlish_entry_20-0x4 ; char_at<generic>
    310e:	mov    ebx,0x1
    3113:	mov    rcx,rbx
    3116:	mov    rdi,r13
    3119:	call   311e <botlish_fn_18+0x76>
			311a: R_X86_64_PLT32	rt_closure_new-0x4
    311e:	mov    r15,rax
    3121:	mov    QWORD PTR [rsp],rax
    3125:	mov    QWORD PTR [rsp+0x10],0x1
    312e:	mov    rsi,rbx
    3131:	mov    rcx,r15
    3134:	mov    rdx,r14
    3137:	mov    rdi,r13
    313a:	call   313f <botlish_fn_18+0x97>
			313b: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_local<generic>
    313f:	mov    r12,rax
    3142:	test   r12,r12
    3145:	je     32a5 <botlish_fn_18+0x1fd>
    314b:	mov    QWORD PTR [rsp+0x10],r12
    3150:	test   r12,0x1
    3157:	jne    3182 <botlish_fn_18+0xda>
    315d:	mov    edx,0x1
    3162:	mov    rsi,r12
    3165:	mov    rdi,r13
    3168:	call   316d <botlish_fn_18+0xc5>
			3169: R_X86_64_PLT32	rt_int_cmp-0x4
    316d:	mov    ecx,0x2
    3172:	test   rax,rax
    3175:	cmove  rcx,QWORD PTR [rip+0x1d3]        # 3350 <botlish_fn_18+0x2a8>
    317d:	jmp    3193 <botlish_fn_18+0xeb>
    3182:	mov    ecx,0x2
    3187:	cmp    r12,0x1
    318b:	cmove  rcx,QWORD PTR [rip+0x1bd]        # 3350 <botlish_fn_18+0x2a8>
    3193:	cmp    rcx,0x6
    3197:	je     3328 <botlish_fn_18+0x280>
    319d:	mov    rbx,r14
    31a0:	mov    r8,r12
    31a3:	and    r8,rbx
    31a6:	test   r8,0x1
    31ad:	jne    31d6 <botlish_fn_18+0x12e>
    31b3:	mov    rdx,rbx
    31b6:	mov    rsi,r12
    31b9:	mov    rdi,r13
    31bc:	call   31c1 <botlish_fn_18+0x119>
			31bd: R_X86_64_PLT32	rt_int_cmp-0x4
    31c1:	mov    ecx,0x2
    31c6:	test   rax,rax
    31c9:	cmovge rcx,QWORD PTR [rip+0x17f]        # 3350 <botlish_fn_18+0x2a8>
    31d1:	jmp    31e6 <botlish_fn_18+0x13e>
    31d6:	mov    ecx,0x2
    31db:	cmp    r12,rbx
    31de:	cmovge rcx,QWORD PTR [rip+0x16a]        # 3350 <botlish_fn_18+0x2a8>
    31e6:	cmp    rcx,0x6
    31ea:	je     331e <botlish_fn_18+0x276>
    31f0:	lea    rcx,[rsp+0x28]
    31f5:	mov    rdx,r12
    31f8:	mov    rsi,r15
    31fb:	mov    rdi,r13
    31fe:	call   3203 <botlish_fn_18+0x15b>
			31ff: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    3203:	test   rax,rax
    3206:	mov    rsi,rax
    3209:	je     32a5 <botlish_fn_18+0x1fd>
    320f:	mov    rdx,QWORD PTR [rsp+0x28]
    3214:	mov    rcx,QWORD PTR [rsp+0x30]
    3219:	mov    rdi,r13
    321c:	mov    rax,QWORD PTR [rdi+0x10]
    3220:	mov    r8,QWORD PTR [rax+0x100]
    3227:	call   322c <botlish_fn_18+0x184>
			3228: R_X86_64_PLT32	rt_str_region_eq-0x4
    322c:	cmp    rax,0x6
    3230:	je     3243 <botlish_fn_18+0x19b>
    3236:	mov    esi,0x2
    323b:	mov    rax,rsi
    323e:	jmp    332d <botlish_fn_18+0x285>
    3243:	mov    QWORD PTR [rsp+0x18],0x3
    324c:	test   r12,0x1
    3253:	jne    3261 <botlish_fn_18+0x1b9>
    3259:	mov    rcx,r12
    325c:	jmp    3276 <botlish_fn_18+0x1ce>
    3261:	mov    rsi,r12
    3264:	add    rsi,0x2
    3268:	mov    rcx,r12
    326b:	seto   al
    326e:	test   al,al
    3270:	je     3289 <botlish_fn_18+0x1e1>
    3276:	mov    edx,0x3
    327b:	mov    rsi,rcx
    327e:	mov    rdi,r13
    3281:	call   3286 <botlish_fn_18+0x1de>
			3282: R_X86_64_PLT32	rt_int_add-0x4
    3286:	mov    rsi,rax
    3289:	mov    QWORD PTR [rsp+0x10],rsi
    328e:	mov    rcx,r15
    3291:	mov    rdx,rbx
    3294:	mov    rdi,r13
    3297:	call   329c <botlish_fn_18+0x1f4>
			3298: R_X86_64_PLT32	botlish_fn_26-0x4 ; domain_loop<generic>
    329c:	test   rax,rax
    329f:	jne    32ca <botlish_fn_18+0x222>
    32a5:	xor    rax,rax
    32a8:	mov    rbx,QWORD PTR [rsp+0x40]
    32ad:	mov    r12,QWORD PTR [rsp+0x48]
    32b2:	mov    r13,QWORD PTR [rsp+0x50]
    32b7:	mov    r14,QWORD PTR [rsp+0x58]
    32bc:	mov    r15,QWORD PTR [rsp+0x60]
    32c1:	add    rsp,0x70
    32c5:	mov    rsp,rbp
    32c8:	pop    rbp
    32c9:	ret
    32ca:	mov    rcx,rax
    32cd:	and    rcx,rbx
    32d0:	mov    rsi,rax
    32d3:	mov    r14,rbx
    32d6:	test   rcx,0x1
    32dd:	jne    3306 <botlish_fn_18+0x25e>
    32e3:	mov    rdx,r14
    32e6:	mov    rdi,r13
    32e9:	call   32ee <botlish_fn_18+0x246>
			32ea: R_X86_64_PLT32	rt_int_cmp-0x4
    32ee:	mov    esi,0x2
    32f3:	test   rax,rax
    32f6:	mov    rax,rsi
    32f9:	cmove  rax,QWORD PTR [rip+0x4f]        # 3350 <botlish_fn_18+0x2a8>
    3301:	jmp    332d <botlish_fn_18+0x285>
    3306:	mov    rdx,r14
    3309:	mov    eax,0x2
    330e:	cmp    rsi,rdx
    3311:	cmove  rax,QWORD PTR [rip+0x37]        # 3350 <botlish_fn_18+0x2a8>
    3319:	jmp    332d <botlish_fn_18+0x285>
    331e:	mov    eax,0x2
    3323:	jmp    332d <botlish_fn_18+0x285>
    3328:	mov    eax,0x2
    332d:	mov    rbx,QWORD PTR [rsp+0x40]
    3332:	mov    r12,QWORD PTR [rsp+0x48]
    3337:	mov    r13,QWORD PTR [rsp+0x50]
    333c:	mov    r14,QWORD PTR [rsp+0x58]
    3341:	mov    r15,QWORD PTR [rsp+0x60]
    3346:	add    rsp,0x70
    334a:	mov    rsp,rbp
    334d:	pop    rbp
    334e:	ret
    334f:	add    BYTE PTR [rsi],al
    3351:	add    BYTE PTR [rax],al
    3353:	add    BYTE PTR [rax],al
    3355:	add    BYTE PTR [rax],al
	...

0000000000003358 <botlish_entry_18: <str>>:
    3358:	push   rbp
    3359:	mov    rbp,rsp
    335c:	mov    rsi,QWORD PTR [rdx]
    335f:	call   3364 <botlish_entry_18+0xc>
			3360: R_X86_64_PLT32	botlish_fn_18-0x4 ; <str>
    3364:	mov    rsp,rbp
    3367:	pop    rbp
    3368:	ret
    3369:	add    BYTE PTR [rax],al
    336b:	add    BYTE PTR [rax],al
    336d:	add    BYTE PTR [rax],al
	...

0000000000003370 <botlish_fn_19: <generic>>:
    3370:	push   rbp
    3371:	mov    rbp,rsp
    3374:	sub    rsp,0x70
    3378:	mov    QWORD PTR [rsp+0x40],rbx
    337d:	mov    QWORD PTR [rsp+0x48],r12
    3382:	mov    QWORD PTR [rsp+0x50],r13
    3387:	mov    QWORD PTR [rsp+0x58],r14
    338c:	mov    QWORD PTR [rsp+0x60],r15
    3391:	mov    QWORD PTR [rsp+0x10],0x0
    339a:	mov    QWORD PTR [rsp+0x18],0x0
    33a3:	mov    QWORD PTR [rsp],rsi
    33a7:	xor    r8d,r8d
    33aa:	test   rsi,0x7
    33b1:	jne    33c3 <botlish_fn_19+0x53>
    33b7:	movzx  r8,BYTE PTR [rsi]
    33bb:	cmp    r8b,0x2
    33bf:	sete   r8b
    33c3:	test   r8b,r8b
    33c6:	jne    33e6 <botlish_fn_19+0x76>
    33cc:	mov    r8,QWORD PTR [rdi+0x10]
    33d0:	mov    rcx,QWORD PTR [r8+0xd8]
    33d7:	mov    edx,0x1
    33dc:	call   33e1 <botlish_fn_19+0x71>
			33dd: R_X86_64_PLT32	rt_type_error-0x4
    33e1:	jmp    35a7 <botlish_fn_19+0x237>
    33e6:	mov    rbx,rsi
    33e9:	mov    r14,rdi
    33ec:	call   33f1 <botlish_fn_19+0x81>
			33ed: R_X86_64_PLT32	rt_str_len-0x4
    33f1:	mov    r13,rax
    33f4:	mov    QWORD PTR [rsp+0x8],rax
    33f9:	lea    r8,[rsp+0x20]
    33fe:	mov    QWORD PTR [rsp+0x20],rbx
    3403:	mov    esi,0x14
    3408:	mov    rdx,QWORD PTR [rip+0x0]        # 340f <botlish_fn_19+0x9f>
			340b: R_X86_64_GOTPCREL	botlish_entry_20-0x4 ; char_at<generic>
    340f:	mov    r12d,0x1
    3415:	mov    rcx,r12
    3418:	mov    rdi,r14
    341b:	call   3420 <botlish_fn_19+0xb0>
			341c: R_X86_64_PLT32	rt_closure_new-0x4
    3420:	mov    rbx,r12
    3423:	mov    r15,rax
    3426:	mov    QWORD PTR [rsp],rax
    342a:	mov    QWORD PTR [rsp+0x10],0x1
    3433:	mov    rcx,r15
    3436:	mov    rdx,r13
    3439:	mov    rsi,rbx
    343c:	mov    rdi,r14
    343f:	call   3444 <botlish_fn_19+0xd4>
			3440: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_local<generic>
    3444:	mov    r12,rax
    3447:	test   r12,r12
    344a:	je     35a7 <botlish_fn_19+0x237>
    3450:	mov    QWORD PTR [rsp+0x10],r12
    3455:	test   r12,0x1
    345c:	jne    3485 <botlish_fn_19+0x115>
    3462:	mov    rdx,rbx
    3465:	mov    rsi,r12
    3468:	mov    rdi,r14
    346b:	call   3470 <botlish_fn_19+0x100>
			346c: R_X86_64_PLT32	rt_int_cmp-0x4
    3470:	mov    ecx,0x2
    3475:	test   rax,rax
    3478:	cmove  rcx,QWORD PTR [rip+0x1d8]        # 3658 <botlish_fn_19+0x2e8>
    3480:	jmp    3496 <botlish_fn_19+0x126>
    3485:	mov    ecx,0x2
    348a:	cmp    r12,0x1
    348e:	cmove  rcx,QWORD PTR [rip+0x1c2]        # 3658 <botlish_fn_19+0x2e8>
    3496:	cmp    rcx,0x6
    349a:	je     362a <botlish_fn_19+0x2ba>
    34a0:	mov    rbx,r13
    34a3:	mov    rax,r12
    34a6:	and    rax,rbx
    34a9:	test   rax,0x1
    34af:	jne    34d8 <botlish_fn_19+0x168>
    34b5:	mov    rdx,rbx
    34b8:	mov    rsi,r12
    34bb:	mov    rdi,r14
    34be:	call   34c3 <botlish_fn_19+0x153>
			34bf: R_X86_64_PLT32	rt_int_cmp-0x4
    34c3:	mov    ecx,0x2
    34c8:	test   rax,rax
    34cb:	cmovge rcx,QWORD PTR [rip+0x185]        # 3658 <botlish_fn_19+0x2e8>
    34d3:	jmp    34e8 <botlish_fn_19+0x178>
    34d8:	mov    ecx,0x2
    34dd:	cmp    r12,rbx
    34e0:	cmovge rcx,QWORD PTR [rip+0x170]        # 3658 <botlish_fn_19+0x2e8>
    34e8:	cmp    rcx,0x6
    34ec:	je     3620 <botlish_fn_19+0x2b0>
    34f2:	lea    rcx,[rsp+0x28]
    34f7:	mov    rdx,r12
    34fa:	mov    rsi,r15
    34fd:	mov    rdi,r14
    3500:	call   3505 <botlish_fn_19+0x195>
			3501: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    3505:	test   rax,rax
    3508:	mov    rsi,rax
    350b:	je     35a7 <botlish_fn_19+0x237>
    3511:	mov    rdx,QWORD PTR [rsp+0x28]
    3516:	mov    rcx,QWORD PTR [rsp+0x30]
    351b:	mov    rdi,r14
    351e:	mov    rax,QWORD PTR [rdi+0x10]
    3522:	mov    r8,QWORD PTR [rax+0x100]
    3529:	call   352e <botlish_fn_19+0x1be>
			352a: R_X86_64_PLT32	rt_str_region_eq-0x4
    352e:	cmp    rax,0x6
    3532:	je     3545 <botlish_fn_19+0x1d5>
    3538:	mov    ecx,0x2
    353d:	mov    rax,rcx
    3540:	jmp    362f <botlish_fn_19+0x2bf>
    3545:	mov    QWORD PTR [rsp+0x18],0x3
    354e:	test   r12,0x1
    3555:	jne    3563 <botlish_fn_19+0x1f3>
    355b:	mov    rdi,r12
    355e:	jmp    3578 <botlish_fn_19+0x208>
    3563:	mov    rsi,r12
    3566:	add    rsi,0x2
    356a:	mov    rdi,r12
    356d:	seto   al
    3570:	test   al,al
    3572:	je     358b <botlish_fn_19+0x21b>
    3578:	mov    edx,0x3
    357d:	mov    rsi,rdi
    3580:	mov    rdi,r14
    3583:	call   3588 <botlish_fn_19+0x218>
			3584: R_X86_64_PLT32	rt_int_add-0x4
    3588:	mov    rsi,rax
    358b:	mov    QWORD PTR [rsp+0x10],rsi
    3590:	mov    rcx,r15
    3593:	mov    rdx,rbx
    3596:	mov    rdi,r14
    3599:	call   359e <botlish_fn_19+0x22e>
			359a: R_X86_64_PLT32	botlish_fn_26-0x4 ; domain_loop<generic>
    359e:	test   rax,rax
    35a1:	jne    35cc <botlish_fn_19+0x25c>
    35a7:	xor    rax,rax
    35aa:	mov    rbx,QWORD PTR [rsp+0x40]
    35af:	mov    r12,QWORD PTR [rsp+0x48]
    35b4:	mov    r13,QWORD PTR [rsp+0x50]
    35b9:	mov    r14,QWORD PTR [rsp+0x58]
    35be:	mov    r15,QWORD PTR [rsp+0x60]
    35c3:	add    rsp,0x70
    35c7:	mov    rsp,rbp
    35ca:	pop    rbp
    35cb:	ret
    35cc:	mov    rcx,rax
    35cf:	and    rcx,rbx
    35d2:	mov    rsi,rax
    35d5:	mov    r13,rbx
    35d8:	test   rcx,0x1
    35df:	jne    3608 <botlish_fn_19+0x298>
    35e5:	mov    rdx,r13
    35e8:	mov    rdi,r14
    35eb:	call   35f0 <botlish_fn_19+0x280>
			35ec: R_X86_64_PLT32	rt_int_cmp-0x4
    35f0:	mov    ecx,0x2
    35f5:	test   rax,rax
    35f8:	mov    rax,rcx
    35fb:	cmove  rax,QWORD PTR [rip+0x55]        # 3658 <botlish_fn_19+0x2e8>
    3603:	jmp    362f <botlish_fn_19+0x2bf>
    3608:	mov    rdx,r13
    360b:	mov    eax,0x2
    3610:	cmp    rsi,rdx
    3613:	cmove  rax,QWORD PTR [rip+0x3d]        # 3658 <botlish_fn_19+0x2e8>
    361b:	jmp    362f <botlish_fn_19+0x2bf>
    3620:	mov    eax,0x2
    3625:	jmp    362f <botlish_fn_19+0x2bf>
    362a:	mov    eax,0x2
    362f:	mov    rbx,QWORD PTR [rsp+0x40]
    3634:	mov    r12,QWORD PTR [rsp+0x48]
    3639:	mov    r13,QWORD PTR [rsp+0x50]
    363e:	mov    r14,QWORD PTR [rsp+0x58]
    3643:	mov    r15,QWORD PTR [rsp+0x60]
    3648:	add    rsp,0x70
    364c:	mov    rsp,rbp
    364f:	pop    rbp
    3650:	ret
    3651:	add    BYTE PTR [rax],al
    3653:	add    BYTE PTR [rax],al
    3655:	add    BYTE PTR [rax],al
    3657:	add    BYTE PTR [rsi],al
    3659:	add    BYTE PTR [rax],al
    365b:	add    BYTE PTR [rax],al
    365d:	add    BYTE PTR [rax],al
	...

0000000000003660 <botlish_entry_19: <generic>>:
    3660:	push   rbp
    3661:	mov    rbp,rsp
    3664:	mov    rsi,QWORD PTR [rdx]
    3667:	call   366c <botlish_entry_19+0xc>
			3668: R_X86_64_PLT32	botlish_fn_19-0x4 ; <generic>
    366c:	mov    rsp,rbp
    366f:	pop    rbp
    3670:	ret

0000000000003671 <botlish_fn_20: char_at<generic>>:
    3671:	push   rbp
    3672:	mov    rbp,rsp
    3675:	sub    rsp,0x40
    3679:	mov    QWORD PTR [rsp+0x20],rbx
    367e:	mov    QWORD PTR [rsp+0x28],r12
    3683:	mov    QWORD PTR [rsp+0x30],r13
    3688:	mov    QWORD PTR [rsp],rdx
    368c:	mov    rax,QWORD PTR [rsi+0x20]
    3690:	mov    rsi,QWORD PTR [rax]
    3693:	mov    QWORD PTR [rsp+0x8],rsi
    3698:	mov    r13,rsi
    369b:	mov    QWORD PTR [rsp+0x10],0x3
    36a4:	mov    r10d,0x1
    36aa:	test   rdx,0x1
    36b1:	je     36bf <botlish_fn_20+0x4e>
    36b7:	mov    rbx,rdx
    36ba:	jmp    36e4 <botlish_fn_20+0x73>
    36bf:	xor    r10d,r10d
    36c2:	test   rdx,0x7
    36c9:	je     36d7 <botlish_fn_20+0x66>
    36cf:	mov    rbx,rdx
    36d2:	jmp    36e4 <botlish_fn_20+0x73>
    36d7:	movzx  rax,BYTE PTR [rdx]
    36db:	mov    rbx,rdx
    36de:	cmp    al,0x1
    36e0:	sete   r10b
    36e4:	test   r10b,r10b
    36e7:	jne    3708 <botlish_fn_20+0x97>
    36ed:	mov    rax,QWORD PTR [rdi+0x10]
    36f1:	mov    rcx,QWORD PTR [rax+0x108]
    36f8:	xor    rdx,rdx
    36fb:	mov    rsi,rbx
    36fe:	call   3703 <botlish_fn_20+0x92>
			36ff: R_X86_64_PLT32	rt_type_error-0x4
    3703:	jmp    37ba <botlish_fn_20+0x149>
    3708:	mov    rsi,rbx
    370b:	mov    r12,rdi
    370e:	test   rsi,0x1
    3715:	je     3730 <botlish_fn_20+0xbf>
    371b:	mov    rsi,rbx
    371e:	mov    rcx,rsi
    3721:	add    rcx,0x2
    3725:	seto   al
    3728:	test   al,al
    372a:	je     3743 <botlish_fn_20+0xd2>
    3730:	mov    edx,0x3
    3735:	mov    rsi,rbx
    3738:	mov    rdi,r12
    373b:	call   3740 <botlish_fn_20+0xcf>
			373c: R_X86_64_PLT32	rt_int_add-0x4
    3740:	mov    rcx,rax
    3743:	mov    QWORD PTR [rsp+0x10],rcx
    3748:	mov    eax,0x1
    374d:	mov    rsi,rbx
    3750:	test   rsi,0x1
    3757:	jne    377d <botlish_fn_20+0x10c>
    375d:	xor    eax,eax
    375f:	mov    rsi,rbx
    3762:	test   rsi,0x7
    3769:	jne    377d <botlish_fn_20+0x10c>
    376f:	mov    rsi,rbx
    3772:	movzx  rdx,BYTE PTR [rsi]
    3776:	rex cmp dl,0x1
    377a:	sete   al
    377d:	test   al,al
    377f:	jne    37a3 <botlish_fn_20+0x132>
    3785:	mov    rdi,r12
    3788:	mov    rsi,QWORD PTR [rdi+0x10]
    378c:	mov    rcx,QWORD PTR [rsi+0x110]
    3793:	xor    rdx,rdx
    3796:	mov    rsi,rbx
    3799:	call   379e <botlish_fn_20+0x12d>
			379a: R_X86_64_PLT32	rt_type_error-0x4
    379e:	jmp    37ba <botlish_fn_20+0x149>
    37a3:	mov    rdx,rbx
    37a6:	mov    rsi,r13
    37a9:	mov    rdi,r12
    37ac:	call   37b1 <botlish_fn_20+0x140>
			37ad: R_X86_64_PLT32	rt_substr-0x4
    37b1:	test   rax,rax
    37b4:	jne    37d5 <botlish_fn_20+0x164>
    37ba:	xor    rax,rax
    37bd:	mov    rbx,QWORD PTR [rsp+0x20]
    37c2:	mov    r12,QWORD PTR [rsp+0x28]
    37c7:	mov    r13,QWORD PTR [rsp+0x30]
    37cc:	add    rsp,0x40
    37d0:	mov    rsp,rbp
    37d3:	pop    rbp
    37d4:	ret
    37d5:	mov    rbx,QWORD PTR [rsp+0x20]
    37da:	mov    r12,QWORD PTR [rsp+0x28]
    37df:	mov    r13,QWORD PTR [rsp+0x30]
    37e4:	add    rsp,0x40
    37e8:	mov    rsp,rbp
    37eb:	pop    rbp
    37ec:	ret

00000000000037ed <botlish_entry_20: char_at<generic>>:
    37ed:	push   rbp
    37ee:	mov    rbp,rsp
    37f1:	mov    rdx,QWORD PTR [rdx]
    37f4:	call   37f9 <botlish_entry_20+0xc>
			37f5: R_X86_64_PLT32	botlish_fn_20-0x4 ; char_at<generic>
    37f9:	mov    rsp,rbp
    37fc:	pop    rbp
    37fd:	ret

00000000000037fe <botlish_fn_21: char_at<generic>>:
    37fe:	push   rbp
    37ff:	mov    rbp,rsp
    3802:	sub    rsp,0x40
    3806:	mov    QWORD PTR [rsp+0x20],rbx
    380b:	mov    QWORD PTR [rsp+0x28],r12
    3810:	mov    QWORD PTR [rsp+0x30],r13
    3815:	mov    QWORD PTR [rsp+0x38],r14
    381a:	mov    r13,rcx
    381d:	mov    QWORD PTR [rsp],rdx
    3821:	mov    rax,QWORD PTR [rsi+0x20]
    3825:	mov    rax,QWORD PTR [rax]
    3828:	mov    QWORD PTR [rsp+0x8],rax
    382d:	mov    r14,rax
    3830:	mov    QWORD PTR [rsp+0x10],0x3
    3839:	mov    r11d,0x1
    383f:	test   rdx,0x1
    3846:	je     3854 <botlish_fn_21+0x56>
    384c:	mov    r12,rdx
    384f:	jmp    3879 <botlish_fn_21+0x7b>
    3854:	xor    r11d,r11d
    3857:	test   rdx,0x7
    385e:	je     386c <botlish_fn_21+0x6e>
    3864:	mov    r12,rdx
    3867:	jmp    3879 <botlish_fn_21+0x7b>
    386c:	movzx  rax,BYTE PTR [rdx]
    3870:	mov    r12,rdx
    3873:	cmp    al,0x1
    3875:	sete   r11b
    3879:	test   r11b,r11b
    387c:	jne    389d <botlish_fn_21+0x9f>
    3882:	mov    rax,QWORD PTR [rdi+0x10]
    3886:	mov    rcx,QWORD PTR [rax+0x108]
    388d:	xor    rdx,rdx
    3890:	mov    rsi,r12
    3893:	call   3898 <botlish_fn_21+0x9a>
			3894: R_X86_64_PLT32	rt_type_error-0x4
    3898:	jmp    3955 <botlish_fn_21+0x157>
    389d:	mov    rbx,rdi
    38a0:	mov    rsi,r12
    38a3:	test   rsi,0x1
    38aa:	jne    38b8 <botlish_fn_21+0xba>
    38b0:	mov    r12,rsi
    38b3:	jmp    38cd <botlish_fn_21+0xcf>
    38b8:	mov    rax,rsi
    38bb:	add    rax,0x2
    38bf:	mov    r12,rsi
    38c2:	seto   cl
    38c5:	test   cl,cl
    38c7:	je     38dd <botlish_fn_21+0xdf>
    38cd:	mov    edx,0x3
    38d2:	mov    rsi,r12
    38d5:	mov    rdi,rbx
    38d8:	call   38dd <botlish_fn_21+0xdf>
			38d9: R_X86_64_PLT32	rt_int_add-0x4
    38dd:	mov    ecx,0x1
    38e2:	mov    rsi,r12
    38e5:	test   rsi,0x1
    38ec:	jne    3912 <botlish_fn_21+0x114>
    38f2:	xor    ecx,ecx
    38f4:	mov    rsi,r12
    38f7:	test   rsi,0x7
    38fe:	jne    3912 <botlish_fn_21+0x114>
    3904:	mov    rsi,r12
    3907:	movzx  rdx,BYTE PTR [rsi]
    390b:	rex cmp dl,0x1
    390f:	sete   cl
    3912:	test   cl,cl
    3914:	jne    3938 <botlish_fn_21+0x13a>
    391a:	mov    rdi,rbx
    391d:	mov    rsi,QWORD PTR [rdi+0x10]
    3921:	mov    rcx,QWORD PTR [rsi+0x110]
    3928:	xor    rdx,rdx
    392b:	mov    rsi,r12
    392e:	call   3933 <botlish_fn_21+0x135>
			392f: R_X86_64_PLT32	rt_type_error-0x4
    3933:	jmp    3955 <botlish_fn_21+0x157>
    3938:	mov    rdi,rbx
    393b:	mov    rbx,rax
    393e:	mov    rcx,rbx
    3941:	mov    rdx,r12
    3944:	mov    rsi,r14
    3947:	call   394c <botlish_fn_21+0x14e>
			3948: R_X86_64_PLT32	rt_str_region_check-0x4
    394c:	test   rax,rax
    394f:	jne    3975 <botlish_fn_21+0x177>
    3955:	xor    rax,rax
    3958:	mov    rbx,QWORD PTR [rsp+0x20]
    395d:	mov    r12,QWORD PTR [rsp+0x28]
    3962:	mov    r13,QWORD PTR [rsp+0x30]
    3967:	mov    r14,QWORD PTR [rsp+0x38]
    396c:	add    rsp,0x40
    3970:	mov    rsp,rbp
    3973:	pop    rbp
    3974:	ret
    3975:	mov    rcx,r13
    3978:	mov    rsi,r12
    397b:	mov    QWORD PTR [rcx],rsi
    397e:	mov    QWORD PTR [rcx+0x8],rbx
    3982:	mov    rax,r14
    3985:	mov    rbx,QWORD PTR [rsp+0x20]
    398a:	mov    r12,QWORD PTR [rsp+0x28]
    398f:	mov    r13,QWORD PTR [rsp+0x30]
    3994:	mov    r14,QWORD PTR [rsp+0x38]
    3999:	add    rsp,0x40
    399d:	mov    rsp,rbp
    39a0:	pop    rbp
    39a1:	ret

00000000000039a2 <botlish_entry_21: char_at<generic>>:
    39a2:	push   rbp
    39a3:	mov    rbp,rsp
    39a6:	ud2

00000000000039a8 <botlish_fn_22: scan_local<generic>>:
    39a8:	push   rbp
    39a9:	mov    rbp,rsp
    39ac:	sub    rsp,0x80
    39b3:	mov    QWORD PTR [rsp+0x50],rbx
    39b8:	mov    QWORD PTR [rsp+0x58],r12
    39bd:	mov    QWORD PTR [rsp+0x60],r13
    39c2:	mov    QWORD PTR [rsp+0x68],r14
    39c7:	mov    QWORD PTR [rsp+0x70],r15
    39cc:	mov    rax,rdi
    39cf:	mov    QWORD PTR [rsp+0x18],0x0
    39d8:	mov    QWORD PTR [rsp],rsi
    39dc:	mov    r14,rsi
    39df:	mov    QWORD PTR [rsp+0x8],rdx
    39e4:	mov    QWORD PTR [rsp+0x10],rcx
    39e9:	mov    r12,rcx
    39ec:	mov    r11d,0x1
    39f2:	mov    rsi,r14
    39f5:	test   rsi,0x1
    39fc:	jne    3a1e <botlish_fn_22+0x76>
    3a02:	xor    r11d,r11d
    3a05:	test   rsi,0x7
    3a0c:	jne    3a1e <botlish_fn_22+0x76>
    3a12:	movzx  rdi,BYTE PTR [rsi]
    3a16:	cmp    dil,0x1
    3a1a:	sete   r11b
    3a1e:	test   r11b,r11b
    3a21:	jne    3a42 <botlish_fn_22+0x9a>
    3a27:	mov    rdi,rax
    3a2a:	mov    r9,QWORD PTR [rdi+0x10]
    3a2e:	mov    rcx,QWORD PTR [r9+0xb8]
    3a35:	xor    rdx,rdx
    3a38:	call   3a3d <botlish_fn_22+0x95>
			3a39: R_X86_64_PLT32	rt_type_error-0x4
    3a3d:	jmp    3af5 <botlish_fn_22+0x14d>
    3a42:	mov    r13,rdx
    3a45:	mov    r10,rsi
    3a48:	and    r10,r13
    3a4b:	mov    r14,rsi
    3a4e:	test   r10,0x1
    3a55:	jne    3a81 <botlish_fn_22+0xd9>
    3a5b:	mov    rbx,rax
    3a5e:	mov    rdx,r13
    3a61:	mov    rsi,r14
    3a64:	mov    rdi,rbx
    3a67:	call   3a6c <botlish_fn_22+0xc4>
			3a68: R_X86_64_PLT32	rt_int_cmp-0x4
    3a6c:	mov    ecx,0x2
    3a71:	test   rax,rax
    3a74:	cmovge rcx,QWORD PTR [rip+0x24c]        # 3cc8 <botlish_fn_22+0x320>
    3a7c:	jmp    3a97 <botlish_fn_22+0xef>
    3a81:	mov    rbx,rax
    3a84:	mov    ecx,0x2
    3a89:	mov    rsi,r14
    3a8c:	cmp    rsi,r13
    3a8f:	cmovge rcx,QWORD PTR [rip+0x231]        # 3cc8 <botlish_fn_22+0x320>
    3a97:	mov    eax,0x6
    3a9c:	mov    QWORD PTR [rsp+0x30],rax
    3aa1:	cmp    rcx,0x6
    3aa5:	je     3c9b <botlish_fn_22+0x2f3>
    3aab:	lea    rcx,[rsp+0x20]
    3ab0:	mov    rdx,r14
    3ab3:	mov    rsi,r12
    3ab6:	mov    rdi,rbx
    3ab9:	call   3abe <botlish_fn_22+0x116>
			3aba: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    3abe:	mov    rsi,rax
    3ac1:	mov    r15,rax
    3ac4:	test   rax,rsi
    3ac7:	je     3af5 <botlish_fn_22+0x14d>
    3acd:	mov    rdx,QWORD PTR [rsp+0x20]
    3ad2:	mov    QWORD PTR [rsp+0x40],rdx
    3ad7:	mov    rcx,QWORD PTR [rsp+0x28]
    3adc:	mov    QWORD PTR [rsp+0x38],rcx
    3ae1:	mov    rsi,r15
    3ae4:	mov    rdi,rbx
    3ae7:	call   3aec <botlish_fn_22+0x144>
			3ae8: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    3aec:	test   rax,rax
    3aef:	jne    3b1d <botlish_fn_22+0x175>
    3af5:	xor    rax,rax
    3af8:	mov    rbx,QWORD PTR [rsp+0x50]
    3afd:	mov    r12,QWORD PTR [rsp+0x58]
    3b02:	mov    r13,QWORD PTR [rsp+0x60]
    3b07:	mov    r14,QWORD PTR [rsp+0x68]
    3b0c:	mov    r15,QWORD PTR [rsp+0x70]
    3b11:	add    rsp,0x80
    3b18:	mov    rsp,rbp
    3b1b:	pop    rbp
    3b1c:	ret
    3b1d:	cmp    rax,0x6
    3b21:	je     3c1c <botlish_fn_22+0x274>
    3b27:	mov    rax,QWORD PTR [rbx+0x10]
    3b2b:	mov    r8,QWORD PTR [rax+0x118]
    3b32:	mov    rcx,QWORD PTR [rsp+0x38]
    3b37:	mov    rdx,QWORD PTR [rsp+0x40]
    3b3c:	mov    rsi,r15
    3b3f:	mov    rdi,rbx
    3b42:	call   3b47 <botlish_fn_22+0x19f>
			3b43: R_X86_64_PLT32	rt_str_region_eq-0x4
    3b47:	cmp    rax,0x6
    3b4b:	je     3c12 <botlish_fn_22+0x26a>
    3b51:	mov    rax,QWORD PTR [rbx+0x10]
    3b55:	mov    r8,QWORD PTR [rax+0x120]
    3b5c:	mov    rcx,QWORD PTR [rsp+0x38]
    3b61:	mov    rdx,QWORD PTR [rsp+0x40]
    3b66:	mov    rsi,r15
    3b69:	mov    rdi,rbx
    3b6c:	call   3b71 <botlish_fn_22+0x1c9>
			3b6d: R_X86_64_PLT32	rt_str_region_eq-0x4
    3b71:	cmp    rax,0x6
    3b75:	je     3c08 <botlish_fn_22+0x260>
    3b7b:	mov    rax,QWORD PTR [rbx+0x10]
    3b7f:	mov    r8,QWORD PTR [rax+0xc0]
    3b86:	mov    rcx,QWORD PTR [rsp+0x38]
    3b8b:	mov    rdx,QWORD PTR [rsp+0x40]
    3b90:	mov    rsi,r15
    3b93:	mov    rdi,rbx
    3b96:	call   3b9b <botlish_fn_22+0x1f3>
			3b97: R_X86_64_PLT32	rt_str_region_eq-0x4
    3b9b:	cmp    rax,0x6
    3b9f:	je     3bfe <botlish_fn_22+0x256>
    3ba5:	mov    rax,QWORD PTR [rbx+0x10]
    3ba9:	mov    r8,QWORD PTR [rax+0x108]
    3bb0:	mov    rcx,QWORD PTR [rsp+0x38]
    3bb5:	mov    rdx,QWORD PTR [rsp+0x40]
    3bba:	mov    rsi,r15
    3bbd:	mov    rdi,rbx
    3bc0:	call   3bc5 <botlish_fn_22+0x21d>
			3bc1: R_X86_64_PLT32	rt_str_region_eq-0x4
    3bc5:	cmp    rax,0x6
    3bc9:	je     3bf4 <botlish_fn_22+0x24c>
    3bcf:	mov    rax,QWORD PTR [rbx+0x10]
    3bd3:	mov    r8,QWORD PTR [rax+0x128]
    3bda:	mov    rcx,QWORD PTR [rsp+0x38]
    3bdf:	mov    rdx,QWORD PTR [rsp+0x40]
    3be4:	mov    rsi,r15
    3be7:	mov    rdi,rbx
    3bea:	call   3bef <botlish_fn_22+0x247>
			3beb: R_X86_64_PLT32	rt_str_region_eq-0x4
    3bef:	jmp    3c21 <botlish_fn_22+0x279>
    3bf4:	mov    rax,QWORD PTR [rsp+0x30]
    3bf9:	jmp    3c21 <botlish_fn_22+0x279>
    3bfe:	mov    rax,QWORD PTR [rsp+0x30]
    3c03:	jmp    3c21 <botlish_fn_22+0x279>
    3c08:	mov    rax,QWORD PTR [rsp+0x30]
    3c0d:	jmp    3c21 <botlish_fn_22+0x279>
    3c12:	mov    rax,QWORD PTR [rsp+0x30]
    3c17:	jmp    3c21 <botlish_fn_22+0x279>
    3c1c:	mov    rax,QWORD PTR [rsp+0x30]
    3c21:	cmp    rax,0x6
    3c25:	je     3c33 <botlish_fn_22+0x28b>
    3c2b:	mov    rax,r14
    3c2e:	jmp    3c9e <botlish_fn_22+0x2f6>
    3c33:	mov    QWORD PTR [rsp+0x18],0x3
    3c3c:	mov    rsi,r14
    3c3f:	test   rsi,0x1
    3c46:	je     3c6c <botlish_fn_22+0x2c4>
    3c4c:	mov    rsi,r14
    3c4f:	mov    rax,rsi
    3c52:	add    rax,0x2
    3c56:	seto   cl
    3c59:	test   cl,cl
    3c5b:	jne    3c6c <botlish_fn_22+0x2c4>
    3c61:	mov    rsi,rax
    3c64:	mov    r14,rax
    3c67:	jmp    3c82 <botlish_fn_22+0x2da>
    3c6c:	mov    edx,0x3
    3c71:	mov    rsi,r14
    3c74:	mov    rdi,rbx
    3c77:	call   3c7c <botlish_fn_22+0x2d4>
			3c78: R_X86_64_PLT32	rt_int_add-0x4
    3c7c:	mov    rsi,rax
    3c7f:	mov    r14,rax
    3c82:	mov    QWORD PTR [rsp],rsi
    3c86:	mov    QWORD PTR [rsp+0x8],r13
    3c8b:	mov    QWORD PTR [rsp+0x10],r12
    3c90:	mov    rax,rbx
    3c93:	mov    rdx,r13
    3c96:	jmp    39ec <botlish_fn_22+0x44>
    3c9b:	mov    rax,r14
    3c9e:	mov    rbx,QWORD PTR [rsp+0x50]
    3ca3:	mov    r12,QWORD PTR [rsp+0x58]
    3ca8:	mov    r13,QWORD PTR [rsp+0x60]
    3cad:	mov    r14,QWORD PTR [rsp+0x68]
    3cb2:	mov    r15,QWORD PTR [rsp+0x70]
    3cb7:	add    rsp,0x80
    3cbe:	mov    rsp,rbp
    3cc1:	pop    rbp
    3cc2:	ret
    3cc3:	add    BYTE PTR [rax],al
    3cc5:	add    BYTE PTR [rax],al
    3cc7:	add    BYTE PTR [rsi],al
    3cc9:	add    BYTE PTR [rax],al
    3ccb:	add    BYTE PTR [rax],al
    3ccd:	add    BYTE PTR [rax],al
	...

0000000000003cd0 <botlish_entry_22: scan_local<generic>>:
    3cd0:	push   rbp
    3cd1:	mov    rbp,rsp
    3cd4:	mov    rsi,QWORD PTR [rdx]
    3cd7:	mov    r8,QWORD PTR [rdx+0x8]
    3cdb:	mov    rcx,QWORD PTR [rdx+0x10]
    3cdf:	mov    rdx,r8
    3ce2:	call   3ce7 <botlish_entry_22+0x17>
			3ce3: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_local<generic>
    3ce7:	mov    rsp,rbp
    3cea:	pop    rbp
    3ceb:	ret
    3cec:	add    BYTE PTR [rax],al
	...

0000000000003cf0 <botlish_fn_23: scan_label<generic>>:
    3cf0:	push   rbp
    3cf1:	mov    rbp,rsp
    3cf4:	sub    rsp,0x80
    3cfb:	mov    QWORD PTR [rsp+0x50],rbx
    3d00:	mov    QWORD PTR [rsp+0x58],r12
    3d05:	mov    QWORD PTR [rsp+0x60],r13
    3d0a:	mov    QWORD PTR [rsp+0x68],r14
    3d0f:	mov    QWORD PTR [rsp+0x70],r15
    3d14:	mov    QWORD PTR [rsp+0x18],0x0
    3d1d:	mov    QWORD PTR [rsp],rsi
    3d21:	mov    r14,rsi
    3d24:	mov    QWORD PTR [rsp+0x8],rdx
    3d29:	mov    QWORD PTR [rsp+0x10],rcx
    3d2e:	mov    r12,rcx
    3d31:	mov    r11d,0x1
    3d37:	mov    rsi,r14
    3d3a:	test   rsi,0x1
    3d41:	jne    3d61 <botlish_fn_23+0x71>
    3d47:	xor    r11d,r11d
    3d4a:	test   rsi,0x7
    3d51:	jne    3d61 <botlish_fn_23+0x71>
    3d57:	movzx  rax,BYTE PTR [rsi]
    3d5b:	cmp    al,0x1
    3d5d:	sete   r11b
    3d61:	test   r11b,r11b
    3d64:	jne    3d82 <botlish_fn_23+0x92>
    3d6a:	mov    rax,QWORD PTR [rdi+0x10]
    3d6e:	mov    rcx,QWORD PTR [rax+0xb8]
    3d75:	xor    rdx,rdx
    3d78:	call   3d7d <botlish_fn_23+0x8d>
			3d79: R_X86_64_PLT32	rt_type_error-0x4
    3d7d:	jmp    3e2e <botlish_fn_23+0x13e>
    3d82:	mov    r13,rdx
    3d85:	mov    rax,rsi
    3d88:	and    rax,r13
    3d8b:	mov    r14,rsi
    3d8e:	test   rax,0x1
    3d94:	jne    3dbd <botlish_fn_23+0xcd>
    3d9a:	mov    rbx,rdi
    3d9d:	mov    rdx,r13
    3da0:	mov    rsi,r14
    3da3:	call   3da8 <botlish_fn_23+0xb8>
			3da4: R_X86_64_PLT32	rt_int_cmp-0x4
    3da8:	mov    ecx,0x2
    3dad:	test   rax,rax
    3db0:	cmovge rcx,QWORD PTR [rip+0x178]        # 3f30 <botlish_fn_23+0x240>
    3db8:	jmp    3dd3 <botlish_fn_23+0xe3>
    3dbd:	mov    rbx,rdi
    3dc0:	mov    ecx,0x2
    3dc5:	mov    rsi,r14
    3dc8:	cmp    rsi,r13
    3dcb:	cmovge rcx,QWORD PTR [rip+0x15d]        # 3f30 <botlish_fn_23+0x240>
    3dd3:	mov    eax,0x6
    3dd8:	mov    QWORD PTR [rsp+0x30],rax
    3ddd:	cmp    rcx,0x6
    3de1:	je     3f04 <botlish_fn_23+0x214>
    3de7:	lea    rcx,[rsp+0x20]
    3dec:	mov    rdx,r14
    3def:	mov    rsi,r12
    3df2:	mov    rdi,rbx
    3df5:	call   3dfa <botlish_fn_23+0x10a>
			3df6: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    3dfa:	test   rax,rax
    3dfd:	mov    r15,rax
    3e00:	je     3e2e <botlish_fn_23+0x13e>
    3e06:	mov    rdx,QWORD PTR [rsp+0x20]
    3e0b:	mov    QWORD PTR [rsp+0x40],rdx
    3e10:	mov    rcx,QWORD PTR [rsp+0x28]
    3e15:	mov    QWORD PTR [rsp+0x38],rcx
    3e1a:	mov    rsi,r15
    3e1d:	mov    rdi,rbx
    3e20:	call   3e25 <botlish_fn_23+0x135>
			3e21: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    3e25:	test   rax,rax
    3e28:	jne    3e56 <botlish_fn_23+0x166>
    3e2e:	xor    rax,rax
    3e31:	mov    rbx,QWORD PTR [rsp+0x50]
    3e36:	mov    r12,QWORD PTR [rsp+0x58]
    3e3b:	mov    r13,QWORD PTR [rsp+0x60]
    3e40:	mov    r14,QWORD PTR [rsp+0x68]
    3e45:	mov    r15,QWORD PTR [rsp+0x70]
    3e4a:	add    rsp,0x80
    3e51:	mov    rsp,rbp
    3e54:	pop    rbp
    3e55:	ret
    3e56:	cmp    rax,0x6
    3e5a:	je     3e85 <botlish_fn_23+0x195>
    3e60:	mov    r11,QWORD PTR [rbx+0x10]
    3e64:	mov    r8,QWORD PTR [r11+0x128]
    3e6b:	mov    rcx,QWORD PTR [rsp+0x38]
    3e70:	mov    rdx,QWORD PTR [rsp+0x40]
    3e75:	mov    rsi,r15
    3e78:	mov    rdi,rbx
    3e7b:	call   3e80 <botlish_fn_23+0x190>
			3e7c: R_X86_64_PLT32	rt_str_region_eq-0x4
    3e80:	jmp    3e8a <botlish_fn_23+0x19a>
    3e85:	mov    rax,QWORD PTR [rsp+0x30]
    3e8a:	cmp    rax,0x6
    3e8e:	je     3e9c <botlish_fn_23+0x1ac>
    3e94:	mov    rax,r14
    3e97:	jmp    3f07 <botlish_fn_23+0x217>
    3e9c:	mov    QWORD PTR [rsp+0x18],0x3
    3ea5:	mov    rsi,r14
    3ea8:	test   rsi,0x1
    3eaf:	je     3ed5 <botlish_fn_23+0x1e5>
    3eb5:	mov    rsi,r14
    3eb8:	mov    rax,rsi
    3ebb:	add    rax,0x2
    3ebf:	seto   cl
    3ec2:	test   cl,cl
    3ec4:	jne    3ed5 <botlish_fn_23+0x1e5>
    3eca:	mov    rsi,rax
    3ecd:	mov    r14,rax
    3ed0:	jmp    3eeb <botlish_fn_23+0x1fb>
    3ed5:	mov    edx,0x3
    3eda:	mov    rsi,r14
    3edd:	mov    rdi,rbx
    3ee0:	call   3ee5 <botlish_fn_23+0x1f5>
			3ee1: R_X86_64_PLT32	rt_int_add-0x4
    3ee5:	mov    rsi,rax
    3ee8:	mov    r14,rax
    3eeb:	mov    QWORD PTR [rsp],rsi
    3eef:	mov    QWORD PTR [rsp+0x8],r13
    3ef4:	mov    QWORD PTR [rsp+0x10],r12
    3ef9:	mov    rdx,r13
    3efc:	mov    rdi,rbx
    3eff:	jmp    3d31 <botlish_fn_23+0x41>
    3f04:	mov    rax,r14
    3f07:	mov    rbx,QWORD PTR [rsp+0x50]
    3f0c:	mov    r12,QWORD PTR [rsp+0x58]
    3f11:	mov    r13,QWORD PTR [rsp+0x60]
    3f16:	mov    r14,QWORD PTR [rsp+0x68]
    3f1b:	mov    r15,QWORD PTR [rsp+0x70]
    3f20:	add    rsp,0x80
    3f27:	mov    rsp,rbp
    3f2a:	pop    rbp
    3f2b:	ret
    3f2c:	add    BYTE PTR [rax],al
    3f2e:	add    BYTE PTR [rax],al
    3f30:	(bad)
    3f31:	add    BYTE PTR [rax],al
    3f33:	add    BYTE PTR [rax],al
    3f35:	add    BYTE PTR [rax],al
	...

0000000000003f38 <botlish_entry_23: scan_label<generic>>:
    3f38:	push   rbp
    3f39:	mov    rbp,rsp
    3f3c:	mov    rsi,QWORD PTR [rdx]
    3f3f:	mov    r8,QWORD PTR [rdx+0x8]
    3f43:	mov    rcx,QWORD PTR [rdx+0x10]
    3f47:	mov    rdx,r8
    3f4a:	call   3f4f <botlish_entry_23+0x17>
			3f4b: R_X86_64_PLT32	botlish_fn_23-0x4 ; scan_label<generic>
    3f4f:	mov    rsp,rbp
    3f52:	pop    rbp
    3f53:	ret
    3f54:	add    BYTE PTR [rax],al
	...

0000000000003f58 <botlish_fn_24: scan_alpha<generic>>:
    3f58:	push   rbp
    3f59:	mov    rbp,rsp
    3f5c:	sub    rsp,0x50
    3f60:	mov    QWORD PTR [rsp+0x30],rbx
    3f65:	mov    QWORD PTR [rsp+0x38],r12
    3f6a:	mov    QWORD PTR [rsp+0x40],r13
    3f6f:	mov    QWORD PTR [rsp+0x48],r14
    3f74:	mov    r14,rdi
    3f77:	mov    QWORD PTR [rsp+0x18],0x0
    3f80:	mov    QWORD PTR [rsp],rsi
    3f84:	mov    r13,rsi
    3f87:	mov    QWORD PTR [rsp+0x8],rdx
    3f8c:	mov    r12,rdx
    3f8f:	mov    QWORD PTR [rsp+0x10],rcx
    3f94:	mov    rbx,rcx
    3f97:	mov    r11d,0x1
    3f9d:	mov    rsi,r13
    3fa0:	test   rsi,0x1
    3fa7:	jne    3fc7 <botlish_fn_24+0x6f>
    3fad:	xor    r11d,r11d
    3fb0:	test   rsi,0x7
    3fb7:	jne    3fc7 <botlish_fn_24+0x6f>
    3fbd:	movzx  rax,BYTE PTR [rsi]
    3fc1:	cmp    al,0x1
    3fc3:	sete   r11b
    3fc7:	test   r11b,r11b
    3fca:	jne    3feb <botlish_fn_24+0x93>
    3fd0:	mov    rdi,r14
    3fd3:	mov    rax,QWORD PTR [rdi+0x10]
    3fd7:	mov    rcx,QWORD PTR [rax+0xb8]
    3fde:	xor    rdx,rdx
    3fe1:	call   3fe6 <botlish_fn_24+0x8e>
			3fe2: R_X86_64_PLT32	rt_type_error-0x4
    3fe6:	jmp    407a <botlish_fn_24+0x122>
    3feb:	mov    rax,rsi
    3fee:	and    rax,r12
    3ff1:	mov    r13,rsi
    3ff4:	test   rax,0x1
    3ffa:	jne    4023 <botlish_fn_24+0xcb>
    4000:	mov    rdx,r12
    4003:	mov    rsi,r13
    4006:	mov    rdi,r14
    4009:	call   400e <botlish_fn_24+0xb6>
			400a: R_X86_64_PLT32	rt_int_cmp-0x4
    400e:	mov    ecx,0x2
    4013:	test   rax,rax
    4016:	cmovge rcx,QWORD PTR [rip+0x112]        # 4130 <botlish_fn_24+0x1d8>
    401e:	jmp    4036 <botlish_fn_24+0xde>
    4023:	mov    ecx,0x2
    4028:	mov    rsi,r13
    402b:	cmp    rsi,r12
    402e:	cmovge rcx,QWORD PTR [rip+0xfa]        # 4130 <botlish_fn_24+0x1d8>
    4036:	cmp    rcx,0x6
    403a:	je     410e <botlish_fn_24+0x1b6>
    4040:	lea    rcx,[rsp+0x20]
    4045:	mov    rdx,r13
    4048:	mov    rsi,rbx
    404b:	mov    rdi,r14
    404e:	call   4053 <botlish_fn_24+0xfb>
			404f: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    4053:	test   rax,rax
    4056:	mov    rsi,rax
    4059:	je     407a <botlish_fn_24+0x122>
    405f:	mov    rdx,QWORD PTR [rsp+0x20]
    4064:	mov    rcx,QWORD PTR [rsp+0x28]
    4069:	mov    rdi,r14
    406c:	call   4071 <botlish_fn_24+0x119>
			406d: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    4071:	test   rax,rax
    4074:	jne    409a <botlish_fn_24+0x142>
    407a:	xor    rax,rax
    407d:	mov    rbx,QWORD PTR [rsp+0x30]
    4082:	mov    r12,QWORD PTR [rsp+0x38]
    4087:	mov    r13,QWORD PTR [rsp+0x40]
    408c:	mov    r14,QWORD PTR [rsp+0x48]
    4091:	add    rsp,0x50
    4095:	mov    rsp,rbp
    4098:	pop    rbp
    4099:	ret
    409a:	cmp    rax,0x6
    409e:	je     40ac <botlish_fn_24+0x154>
    40a4:	mov    rax,r13
    40a7:	jmp    4111 <botlish_fn_24+0x1b9>
    40ac:	mov    QWORD PTR [rsp+0x18],0x3
    40b5:	mov    rsi,r13
    40b8:	test   rsi,0x1
    40bf:	je     40e5 <botlish_fn_24+0x18d>
    40c5:	mov    rsi,r13
    40c8:	mov    r11,rsi
    40cb:	add    r11,0x2
    40cf:	seto   al
    40d2:	test   al,al
    40d4:	jne    40e5 <botlish_fn_24+0x18d>
    40da:	mov    rsi,r11
    40dd:	mov    r13,r11
    40e0:	jmp    40fb <botlish_fn_24+0x1a3>
    40e5:	mov    edx,0x3
    40ea:	mov    rsi,r13
    40ed:	mov    rdi,r14
    40f0:	call   40f5 <botlish_fn_24+0x19d>
			40f1: R_X86_64_PLT32	rt_int_add-0x4
    40f5:	mov    rsi,rax
    40f8:	mov    r13,rax
    40fb:	mov    QWORD PTR [rsp],rsi
    40ff:	mov    QWORD PTR [rsp+0x8],r12
    4104:	mov    QWORD PTR [rsp+0x10],rbx
    4109:	jmp    3f97 <botlish_fn_24+0x3f>
    410e:	mov    rax,r13
    4111:	mov    rbx,QWORD PTR [rsp+0x30]
    4116:	mov    r12,QWORD PTR [rsp+0x38]
    411b:	mov    r13,QWORD PTR [rsp+0x40]
    4120:	mov    r14,QWORD PTR [rsp+0x48]
    4125:	add    rsp,0x50
    4129:	mov    rsp,rbp
    412c:	pop    rbp
    412d:	ret
    412e:	add    BYTE PTR [rax],al
    4130:	(bad)
    4131:	add    BYTE PTR [rax],al
    4133:	add    BYTE PTR [rax],al
    4135:	add    BYTE PTR [rax],al
	...

0000000000004138 <botlish_entry_24: scan_alpha<generic>>:
    4138:	push   rbp
    4139:	mov    rbp,rsp
    413c:	mov    rsi,QWORD PTR [rdx]
    413f:	mov    r8,QWORD PTR [rdx+0x8]
    4143:	mov    rcx,QWORD PTR [rdx+0x10]
    4147:	mov    rdx,r8
    414a:	call   414f <botlish_entry_24+0x17>
			414b: R_X86_64_PLT32	botlish_fn_24-0x4 ; scan_alpha<generic>
    414f:	mov    rsp,rbp
    4152:	pop    rbp
    4153:	ret
    4154:	add    BYTE PTR [rax],al
	...

0000000000004158 <botlish_fn_25: tld_ok<generic>>:
    4158:	push   rbp
    4159:	mov    rbp,rsp
    415c:	sub    rsp,0x40
    4160:	mov    QWORD PTR [rsp+0x20],rbx
    4165:	mov    QWORD PTR [rsp+0x28],r12
    416a:	mov    QWORD PTR [rsp+0x30],r13
    416f:	mov    QWORD PTR [rsp+0x38],r14
    4174:	mov    rbx,rdi
    4177:	mov    QWORD PTR [rsp],rsi
    417b:	mov    r12,rsi
    417e:	mov    QWORD PTR [rsp+0x8],rdx
    4183:	mov    r14,rdx
    4186:	mov    QWORD PTR [rsp+0x10],rcx
    418b:	mov    rdx,r14
    418e:	mov    rsi,r12
    4191:	mov    rdi,rbx
    4194:	call   4199 <botlish_fn_25+0x41>
			4195: R_X86_64_PLT32	botlish_fn_24-0x4 ; scan_alpha<generic>
    4199:	mov    rsi,rax
    419c:	mov    r13,rax
    419f:	test   rax,rsi
    41a2:	je     4265 <botlish_fn_25+0x10d>
    41a8:	mov    rax,r13
    41ab:	mov    QWORD PTR [rsp+0x8],rax
    41b0:	mov    rdx,r14
    41b3:	and    rax,rdx
    41b6:	test   rax,0x1
    41bc:	jne    41e5 <botlish_fn_25+0x8d>
    41c2:	mov    rsi,r13
    41c5:	mov    rdi,rbx
    41c8:	call   41cd <botlish_fn_25+0x75>
			41c9: R_X86_64_PLT32	rt_int_cmp-0x4
    41cd:	mov    ecx,0x2
    41d2:	test   rax,rax
    41d5:	cmove  rcx,QWORD PTR [rip+0x15b]        # 4338 <botlish_fn_25+0x1e0>
    41dd:	mov    rax,r13
    41e0:	jmp    41f8 <botlish_fn_25+0xa0>
    41e5:	mov    ecx,0x2
    41ea:	mov    rax,r13
    41ed:	cmp    rax,rdx
    41f0:	cmove  rcx,QWORD PTR [rip+0x140]        # 4338 <botlish_fn_25+0x1e0>
    41f8:	cmp    rcx,0x6
    41fc:	je     420f <botlish_fn_25+0xb7>
    4202:	mov    ecx,0x2
    4207:	mov    rax,rcx
    420a:	jmp    4317 <botlish_fn_25+0x1bf>
    420f:	mov    ecx,0x1
    4214:	mov    rsi,r12
    4217:	test   rsi,0x1
    421e:	jne    4244 <botlish_fn_25+0xec>
    4224:	xor    ecx,ecx
    4226:	mov    rsi,r12
    4229:	test   rsi,0x7
    4230:	jne    4244 <botlish_fn_25+0xec>
    4236:	mov    rsi,r12
    4239:	movzx  rcx,BYTE PTR [rsi]
    423d:	rex cmp cl,0x1
    4241:	sete   cl
    4244:	test   cl,cl
    4246:	jne    4285 <botlish_fn_25+0x12d>
    424c:	mov    rdi,rbx
    424f:	mov    rsi,QWORD PTR [rdi+0x10]
    4253:	mov    rcx,QWORD PTR [rsi+0x128]
    425a:	xor    rdx,rdx
    425d:	mov    rsi,r12
    4260:	call   4265 <botlish_fn_25+0x10d>
			4261: R_X86_64_PLT32	rt_type_error-0x4
    4265:	xor    rax,rax
    4268:	mov    rbx,QWORD PTR [rsp+0x20]
    426d:	mov    r12,QWORD PTR [rsp+0x28]
    4272:	mov    r13,QWORD PTR [rsp+0x30]
    4277:	mov    r14,QWORD PTR [rsp+0x38]
    427c:	add    rsp,0x40
    4280:	mov    rsp,rbp
    4283:	pop    rbp
    4284:	ret
    4285:	mov    rsi,r12
    4288:	mov    rdi,rax
    428b:	and    rdi,rsi
    428e:	test   rdi,0x1
    4295:	jne    42a6 <botlish_fn_25+0x14e>
    429b:	mov    rdx,r12
    429e:	mov    rsi,rax
    42a1:	jmp    42c9 <botlish_fn_25+0x171>
    42a6:	mov    rsi,r12
    42a9:	mov    r8,rax
    42ac:	sub    r8,rsi
    42af:	mov    r13,rax
    42b2:	seto   r10b
    42b6:	lea    rsi,[r8+0x1]
    42ba:	test   r10b,r10b
    42bd:	je     42d4 <botlish_fn_25+0x17c>
    42c3:	mov    rdx,r12
    42c6:	mov    rsi,r13
    42c9:	mov    rdi,rbx
    42cc:	call   42d1 <botlish_fn_25+0x179>
			42cd: R_X86_64_PLT32	rt_int_sub-0x4
    42d1:	mov    rsi,rax
    42d4:	test   rsi,0x1
    42db:	jne    4306 <botlish_fn_25+0x1ae>
    42e1:	mov    edx,0x5
    42e6:	mov    rdi,rbx
    42e9:	call   42ee <botlish_fn_25+0x196>
			42ea: R_X86_64_PLT32	rt_int_cmp-0x4
    42ee:	mov    ecx,0x2
    42f3:	test   rax,rax
    42f6:	mov    rax,rcx
    42f9:	cmovge rax,QWORD PTR [rip+0x37]        # 4338 <botlish_fn_25+0x1e0>
    4301:	jmp    4317 <botlish_fn_25+0x1bf>
    4306:	mov    eax,0x2
    430b:	cmp    rsi,0x5
    430f:	cmovge rax,QWORD PTR [rip+0x21]        # 4338 <botlish_fn_25+0x1e0>
    4317:	mov    rbx,QWORD PTR [rsp+0x20]
    431c:	mov    r12,QWORD PTR [rsp+0x28]
    4321:	mov    r13,QWORD PTR [rsp+0x30]
    4326:	mov    r14,QWORD PTR [rsp+0x38]
    432b:	add    rsp,0x40
    432f:	mov    rsp,rbp
    4332:	pop    rbp
    4333:	ret
    4334:	add    BYTE PTR [rax],al
    4336:	add    BYTE PTR [rax],al
    4338:	(bad)
    4339:	add    BYTE PTR [rax],al
    433b:	add    BYTE PTR [rax],al
    433d:	add    BYTE PTR [rax],al
	...

0000000000004340 <botlish_entry_25: tld_ok<generic>>:
    4340:	push   rbp
    4341:	mov    rbp,rsp
    4344:	mov    rsi,QWORD PTR [rdx]
    4347:	mov    r8,QWORD PTR [rdx+0x8]
    434b:	mov    rcx,QWORD PTR [rdx+0x10]
    434f:	mov    rdx,r8
    4352:	call   4357 <botlish_entry_25+0x17>
			4353: R_X86_64_PLT32	botlish_fn_25-0x4 ; tld_ok<generic>
    4357:	mov    rsp,rbp
    435a:	pop    rbp
    435b:	ret
    435c:	add    BYTE PTR [rax],al
	...

0000000000004360 <botlish_fn_26: domain_loop<generic>>:
    4360:	push   rbp
    4361:	mov    rbp,rsp
    4364:	sub    rsp,0x70
    4368:	mov    QWORD PTR [rsp+0x40],rbx
    436d:	mov    QWORD PTR [rsp+0x48],r12
    4372:	mov    QWORD PTR [rsp+0x50],r13
    4377:	mov    QWORD PTR [rsp+0x58],r14
    437c:	mov    QWORD PTR [rsp+0x60],r15
    4381:	mov    QWORD PTR [rsp+0x18],0x0
    438a:	mov    QWORD PTR [rsp],rsi
    438e:	mov    QWORD PTR [rsp+0x8],rdx
    4393:	mov    QWORD PTR [rsp+0x10],rcx
    4398:	lea    rbx,[rsp+0x20]
    439d:	mov    r12,rdi
    43a0:	mov    r13,rcx
    43a3:	mov    r14,rdx
    43a6:	mov    QWORD PTR [rsp+0x30],rsi
    43ab:	mov    rcx,r13
    43ae:	mov    rdx,r14
    43b1:	mov    rsi,QWORD PTR [rsp+0x30]
    43b6:	mov    rdi,r12
    43b9:	call   43be <botlish_fn_26+0x5e>
			43ba: R_X86_64_PLT32	botlish_fn_23-0x4 ; scan_label<generic>
    43be:	mov    rcx,rax
    43c1:	mov    r15,rax
    43c4:	test   rax,rcx
    43c7:	je     4517 <botlish_fn_26+0x1b7>
    43cd:	mov    rax,r15
    43d0:	mov    QWORD PTR [rsp],rax
    43d4:	mov    rdx,QWORD PTR [rsp+0x30]
    43d9:	and    rax,rdx
    43dc:	test   rax,0x1
    43e2:	jne    4401 <botlish_fn_26+0xa1>
    43e8:	mov    rsi,r15
    43eb:	mov    rdi,r12
    43ee:	call   43f3 <botlish_fn_26+0x93>
			43ef: R_X86_64_PLT32	rt_value_eq-0x4
    43f3:	test   rax,rax
    43f6:	je     4517 <botlish_fn_26+0x1b7>
    43fc:	jmp    4411 <botlish_fn_26+0xb1>
    4401:	mov    eax,0x2
    4406:	cmp    r15,rdx
    4409:	cmove  rax,QWORD PTR [rip+0x187]        # 4598 <botlish_fn_26+0x238>
    4411:	cmp    rax,0x6
    4415:	je     456d <botlish_fn_26+0x20d>
    441b:	mov    rax,r15
    441e:	and    rax,r14
    4421:	test   rax,0x1
    4427:	jne    4450 <botlish_fn_26+0xf0>
    442d:	mov    rdx,r14
    4430:	mov    rsi,r15
    4433:	mov    rdi,r12
    4436:	call   443b <botlish_fn_26+0xdb>
			4437: R_X86_64_PLT32	rt_int_cmp-0x4
    443b:	mov    ecx,0x2
    4440:	test   rax,rax
    4443:	cmovge rcx,QWORD PTR [rip+0x14d]        # 4598 <botlish_fn_26+0x238>
    444b:	jmp    4460 <botlish_fn_26+0x100>
    4450:	mov    ecx,0x2
    4455:	cmp    r15,r14
    4458:	cmovge rcx,QWORD PTR [rip+0x138]        # 4598 <botlish_fn_26+0x238>
    4460:	cmp    rcx,0x6
    4464:	je     455e <botlish_fn_26+0x1fe>
    446a:	mov    rcx,rbx
    446d:	mov    rdx,r15
    4470:	mov    rsi,r13
    4473:	mov    rdi,r12
    4476:	call   447b <botlish_fn_26+0x11b>
			4477: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    447b:	test   rax,rax
    447e:	je     4517 <botlish_fn_26+0x1b7>
    4484:	mov    rdx,QWORD PTR [rsp+0x20]
    4489:	mov    rcx,QWORD PTR [rsp+0x28]
    448e:	mov    rsi,QWORD PTR [r12+0x10]
    4493:	mov    r8,QWORD PTR [rsi+0x118]
    449a:	mov    rsi,rax
    449d:	mov    rdi,r12
    44a0:	call   44a5 <botlish_fn_26+0x145>
			44a1: R_X86_64_PLT32	rt_str_region_eq-0x4
    44a5:	cmp    rax,0x6
    44a9:	je     44bb <botlish_fn_26+0x15b>
    44af:	mov    r14,0xffffffffffffffff
    44b6:	jmp    4565 <botlish_fn_26+0x205>
    44bb:	mov    QWORD PTR [rsp+0x18],0x3
    44c4:	test   r15,0x1
    44cb:	je     44e3 <botlish_fn_26+0x183>
    44d1:	mov    rdx,r15
    44d4:	add    rdx,0x2
    44d8:	seto   al
    44db:	test   al,al
    44dd:	je     44f6 <botlish_fn_26+0x196>
    44e3:	mov    edx,0x3
    44e8:	mov    rsi,r15
    44eb:	mov    rdi,r12
    44ee:	call   44f3 <botlish_fn_26+0x193>
			44ef: R_X86_64_PLT32	rt_int_add-0x4
    44f3:	mov    rdx,rax
    44f6:	mov    QWORD PTR [rsp],rdx
    44fa:	mov    r15,rdx
    44fd:	mov    rcx,r13
    4500:	mov    rdx,r14
    4503:	mov    rsi,r15
    4506:	mov    rdi,r12
    4509:	call   450e <botlish_fn_26+0x1ae>
			450a: R_X86_64_PLT32	botlish_fn_25-0x4 ; tld_ok<generic>
    450e:	test   rax,rax
    4511:	jne    453c <botlish_fn_26+0x1dc>
    4517:	xor    rax,rax
    451a:	mov    rbx,QWORD PTR [rsp+0x40]
    451f:	mov    r12,QWORD PTR [rsp+0x48]
    4524:	mov    r13,QWORD PTR [rsp+0x50]
    4529:	mov    r14,QWORD PTR [rsp+0x58]
    452e:	mov    r15,QWORD PTR [rsp+0x60]
    4533:	add    rsp,0x70
    4537:	mov    rsp,rbp
    453a:	pop    rbp
    453b:	ret
    453c:	cmp    rax,0x6
    4540:	je     4565 <botlish_fn_26+0x205>
    4546:	mov    QWORD PTR [rsp],r15
    454a:	mov    QWORD PTR [rsp+0x8],r14
    454f:	mov    QWORD PTR [rsp+0x10],r13
    4554:	mov    QWORD PTR [rsp+0x30],r15
    4559:	jmp    43ab <botlish_fn_26+0x4b>
    455e:	mov    r14,0xffffffffffffffff
    4565:	mov    rax,r14
    4568:	jmp    4574 <botlish_fn_26+0x214>
    456d:	mov    rax,0xffffffffffffffff
    4574:	mov    rbx,QWORD PTR [rsp+0x40]
    4579:	mov    r12,QWORD PTR [rsp+0x48]
    457e:	mov    r13,QWORD PTR [rsp+0x50]
    4583:	mov    r14,QWORD PTR [rsp+0x58]
    4588:	mov    r15,QWORD PTR [rsp+0x60]
    458d:	add    rsp,0x70
    4591:	mov    rsp,rbp
    4594:	pop    rbp
    4595:	ret
    4596:	add    BYTE PTR [rax],al
    4598:	(bad)
    4599:	add    BYTE PTR [rax],al
    459b:	add    BYTE PTR [rax],al
    459d:	add    BYTE PTR [rax],al
	...

00000000000045a0 <botlish_entry_26: domain_loop<generic>>:
    45a0:	push   rbp
    45a1:	mov    rbp,rsp
    45a4:	mov    rsi,QWORD PTR [rdx]
    45a7:	mov    r8,QWORD PTR [rdx+0x8]
    45ab:	mov    rcx,QWORD PTR [rdx+0x10]
    45af:	mov    rdx,r8
    45b2:	call   45b7 <botlish_entry_26+0x17>
			45b3: R_X86_64_PLT32	botlish_fn_26-0x4 ; domain_loop<generic>
    45b7:	mov    rsp,rbp
    45ba:	pop    rbp
    45bb:	ret

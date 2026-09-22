; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 20846  (per function: 935 365 1713 1425 527 932 541 988 504 1185 1225 427 456 849 617 505 553 641 1185 1225 427 456 849 617 505 553 641)
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
     396:	sub    rsp,0x60
     39a:	mov    QWORD PTR [rsp+0x40],rbx
     39f:	mov    QWORD PTR [rsp+0x48],r12
     3a4:	mov    QWORD PTR [rsp+0x50],r13
     3a9:	mov    QWORD PTR [rsp+0x10],0x0
     3b2:	mov    QWORD PTR [rsp+0x18],0x0
     3bb:	mov    QWORD PTR [rsp],rdx
     3bf:	mov    r13,rdx
     3c2:	mov    rax,QWORD PTR [rsi+0x20]
     3c6:	mov    rax,QWORD PTR [rax]
     3c9:	mov    QWORD PTR [rsp+0x8],rax
     3ce:	lea    r8,[rsp+0x20]
     3d3:	mov    QWORD PTR [rsp+0x20],rax
     3d8:	mov    esi,0x4
     3dd:	mov    rdx,QWORD PTR [rip+0x0]        # 3e4 <botlish_fn_1+0x52>
			3e0: R_X86_64_GOTPCREL	botlish_entry_4-0x4 ; hex_pair<generic>
     3e4:	mov    r12d,0x1
     3ea:	mov    rbx,rdi
     3ed:	mov    rcx,r12
     3f0:	call   3f5 <botlish_fn_1+0x63>
			3f1: R_X86_64_PLT32	rt_closure_new-0x4
     3f5:	mov    QWORD PTR [rsp+0x8],rax
     3fa:	lea    r8,[rsp+0x28]
     3ff:	mov    QWORD PTR [rsp+0x28],rax
     404:	mov    esi,0x5
     409:	mov    rdx,QWORD PTR [rip+0x0]        # 410 <botlish_fn_1+0x7e>
			40c: R_X86_64_GOTPCREL	botlish_entry_5-0x4 ; esc_bytes<generic>
     410:	mov    rcx,r12
     413:	mov    rdi,rbx
     416:	call   41b <botlish_fn_1+0x89>
			417: R_X86_64_PLT32	rt_closure_new-0x4
     41b:	mov    QWORD PTR [rsp+0x8],rax
     420:	lea    r8,[rsp+0x30]
     425:	mov    QWORD PTR [rsp+0x30],rax
     42a:	mov    esi,0x6
     42f:	mov    rdx,QWORD PTR [rip+0x0]        # 436 <botlish_fn_1+0xa4>
			432: R_X86_64_GOTPCREL	botlish_entry_6-0x4 ; esc_char<generic>
     436:	mov    rcx,r12
     439:	mov    rdi,rbx
     43c:	call   441 <botlish_fn_1+0xaf>
			43d: R_X86_64_PLT32	rt_closure_new-0x4
     441:	mov    QWORD PTR [rsp+0x8],rax
     446:	lea    r8,[rsp+0x38]
     44b:	mov    QWORD PTR [rsp+0x38],rax
     450:	mov    esi,0x7
     455:	mov    rdx,QWORD PTR [rip+0x0]        # 45c <botlish_fn_1+0xca>
			458: R_X86_64_GOTPCREL	botlish_entry_7-0x4 ; esc_from<generic>
     45c:	mov    rcx,r12
     45f:	mov    rdi,rbx
     462:	call   467 <botlish_fn_1+0xd5>
			463: R_X86_64_PLT32	rt_closure_new-0x4
     467:	mov    QWORD PTR [rsp+0x8],rax
     46c:	mov    QWORD PTR [rsp+0x10],0x1
     475:	mov    rcx,QWORD PTR [rbx+0x10]
     479:	mov    r8,QWORD PTR [rcx+0x98]
     480:	mov    QWORD PTR [rsp+0x18],r8
     485:	mov    rcx,r12
     488:	mov    rdx,r13
     48b:	mov    rsi,rax
     48e:	mov    rdi,rbx
     491:	call   496 <botlish_fn_1+0x104>
			492: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
     496:	test   rax,rax
     499:	jne    4ba <botlish_fn_1+0x128>
     49f:	xor    rax,rax
     4a2:	mov    rbx,QWORD PTR [rsp+0x40]
     4a7:	mov    r12,QWORD PTR [rsp+0x48]
     4ac:	mov    r13,QWORD PTR [rsp+0x50]
     4b1:	add    rsp,0x60
     4b5:	mov    rsp,rbp
     4b8:	pop    rbp
     4b9:	ret
     4ba:	mov    rbx,QWORD PTR [rsp+0x40]
     4bf:	mov    r12,QWORD PTR [rsp+0x48]
     4c4:	mov    r13,QWORD PTR [rsp+0x50]
     4c9:	add    rsp,0x60
     4cd:	mov    rsp,rbp
     4d0:	pop    rbp
     4d1:	ret

00000000000004d2 <botlish_entry_1: web::uri_escape_text<generic>>:
     4d2:	push   rbp
     4d3:	mov    rbp,rsp
     4d6:	mov    rdx,QWORD PTR [rdx]
     4d9:	call   4de <botlish_entry_1+0xc>
			4da: R_X86_64_PLT32	botlish_fn_1-0x4 ; web::uri_escape_text<generic>
     4de:	mov    rsp,rbp
     4e1:	pop    rbp
     4e2:	ret
     4e3:	add    BYTE PTR [rax],al
     4e5:	add    BYTE PTR [rax],al
	...

00000000000004e8 <botlish_fn_2: high_nibble<generic>>:
     4e8:	push   rbp
     4e9:	mov    rbp,rsp
     4ec:	sub    rsp,0x10
     4f0:	mov    QWORD PTR [rsp],rbx
     4f4:	mov    QWORD PTR [rsp+0x8],r12
     4f9:	mov    r8d,0x1
     4ff:	test   rsi,0x1
     506:	jne    526 <botlish_fn_2+0x3e>
     50c:	xor    r8d,r8d
     50f:	test   rsi,0x7
     516:	jne    526 <botlish_fn_2+0x3e>
     51c:	movzx  rax,BYTE PTR [rsi]
     520:	cmp    al,0x1
     522:	sete   r8b
     526:	test   r8b,r8b
     529:	jne    55a <botlish_fn_2+0x72>
     52f:	mov    rax,QWORD PTR [rdi+0x10]
     533:	mov    rcx,QWORD PTR [rax+0xa0]
     53a:	xor    rbx,rbx
     53d:	mov    rdx,rbx
     540:	call   545 <botlish_fn_2+0x5d>
			541: R_X86_64_PLT32	rt_type_error-0x4
     545:	mov    rax,rbx
     548:	mov    rbx,QWORD PTR [rsp]
     54c:	mov    r12,QWORD PTR [rsp+0x8]
     551:	add    rsp,0x10
     555:	mov    rsp,rbp
     558:	pop    rbp
     559:	ret
     55a:	mov    r12,rdi
     55d:	test   rsi,0x1
     564:	mov    rbx,rsi
     567:	jne    592 <botlish_fn_2+0xaa>
     56d:	mov    edx,0x1f
     572:	mov    rsi,rbx
     575:	mov    rdi,r12
     578:	call   57d <botlish_fn_2+0x95>
			579: R_X86_64_PLT32	rt_int_cmp-0x4
     57d:	mov    ecx,0x2
     582:	test   rax,rax
     585:	cmovle rcx,QWORD PTR [rip+0x583]        # b10 <botlish_fn_2+0x628>
     58d:	jmp    5a6 <botlish_fn_2+0xbe>
     592:	mov    ecx,0x2
     597:	mov    rsi,rbx
     59a:	cmp    rsi,0x1f
     59e:	cmovle rcx,QWORD PTR [rip+0x56a]        # b10 <botlish_fn_2+0x628>
     5a6:	cmp    rcx,0x6
     5aa:	je     af3 <botlish_fn_2+0x60b>
     5b0:	mov    rsi,rbx
     5b3:	test   rsi,0x1
     5ba:	jne    5e5 <botlish_fn_2+0xfd>
     5c0:	mov    edx,0x3f
     5c5:	mov    rsi,rbx
     5c8:	mov    rdi,r12
     5cb:	call   5d0 <botlish_fn_2+0xe8>
			5cc: R_X86_64_PLT32	rt_int_cmp-0x4
     5d0:	mov    ecx,0x2
     5d5:	test   rax,rax
     5d8:	cmovle rcx,QWORD PTR [rip+0x530]        # b10 <botlish_fn_2+0x628>
     5e0:	jmp    5f9 <botlish_fn_2+0x111>
     5e5:	mov    ecx,0x2
     5ea:	mov    rsi,rbx
     5ed:	cmp    rsi,0x3f
     5f1:	cmovle rcx,QWORD PTR [rip+0x517]        # b10 <botlish_fn_2+0x628>
     5f9:	cmp    rcx,0x6
     5fd:	je     ae9 <botlish_fn_2+0x601>
     603:	mov    rsi,rbx
     606:	test   rsi,0x1
     60d:	jne    638 <botlish_fn_2+0x150>
     613:	mov    edx,0x5f
     618:	mov    rsi,rbx
     61b:	mov    rdi,r12
     61e:	call   623 <botlish_fn_2+0x13b>
			61f: R_X86_64_PLT32	rt_int_cmp-0x4
     623:	mov    ecx,0x2
     628:	test   rax,rax
     62b:	cmovle rcx,QWORD PTR [rip+0x4dd]        # b10 <botlish_fn_2+0x628>
     633:	jmp    64c <botlish_fn_2+0x164>
     638:	mov    ecx,0x2
     63d:	mov    rsi,rbx
     640:	cmp    rsi,0x5f
     644:	cmovle rcx,QWORD PTR [rip+0x4c4]        # b10 <botlish_fn_2+0x628>
     64c:	cmp    rcx,0x6
     650:	je     adf <botlish_fn_2+0x5f7>
     656:	mov    rsi,rbx
     659:	test   rsi,0x1
     660:	jne    68b <botlish_fn_2+0x1a3>
     666:	mov    edx,0x7f
     66b:	mov    rsi,rbx
     66e:	mov    rdi,r12
     671:	call   676 <botlish_fn_2+0x18e>
			672: R_X86_64_PLT32	rt_int_cmp-0x4
     676:	mov    ecx,0x2
     67b:	test   rax,rax
     67e:	cmovle rcx,QWORD PTR [rip+0x48a]        # b10 <botlish_fn_2+0x628>
     686:	jmp    69f <botlish_fn_2+0x1b7>
     68b:	mov    ecx,0x2
     690:	mov    rsi,rbx
     693:	cmp    rsi,0x7f
     697:	cmovle rcx,QWORD PTR [rip+0x471]        # b10 <botlish_fn_2+0x628>
     69f:	cmp    rcx,0x6
     6a3:	je     ad5 <botlish_fn_2+0x5ed>
     6a9:	mov    rsi,rbx
     6ac:	test   rsi,0x1
     6b3:	jne    6de <botlish_fn_2+0x1f6>
     6b9:	mov    edx,0x9f
     6be:	mov    rsi,rbx
     6c1:	mov    rdi,r12
     6c4:	call   6c9 <botlish_fn_2+0x1e1>
			6c5: R_X86_64_PLT32	rt_int_cmp-0x4
     6c9:	mov    ecx,0x2
     6ce:	test   rax,rax
     6d1:	cmovle rcx,QWORD PTR [rip+0x437]        # b10 <botlish_fn_2+0x628>
     6d9:	jmp    6f5 <botlish_fn_2+0x20d>
     6de:	mov    ecx,0x2
     6e3:	mov    rsi,rbx
     6e6:	cmp    rsi,0x9f
     6ed:	cmovle rcx,QWORD PTR [rip+0x41b]        # b10 <botlish_fn_2+0x628>
     6f5:	cmp    rcx,0x6
     6f9:	je     acb <botlish_fn_2+0x5e3>
     6ff:	mov    rsi,rbx
     702:	test   rsi,0x1
     709:	jne    734 <botlish_fn_2+0x24c>
     70f:	mov    edx,0xbf
     714:	mov    rsi,rbx
     717:	mov    rdi,r12
     71a:	call   71f <botlish_fn_2+0x237>
			71b: R_X86_64_PLT32	rt_int_cmp-0x4
     71f:	mov    ecx,0x2
     724:	test   rax,rax
     727:	cmovle rcx,QWORD PTR [rip+0x3e1]        # b10 <botlish_fn_2+0x628>
     72f:	jmp    74b <botlish_fn_2+0x263>
     734:	mov    ecx,0x2
     739:	mov    rsi,rbx
     73c:	cmp    rsi,0xbf
     743:	cmovle rcx,QWORD PTR [rip+0x3c5]        # b10 <botlish_fn_2+0x628>
     74b:	cmp    rcx,0x6
     74f:	je     ac1 <botlish_fn_2+0x5d9>
     755:	mov    rsi,rbx
     758:	test   rsi,0x1
     75f:	jne    78a <botlish_fn_2+0x2a2>
     765:	mov    edx,0xdf
     76a:	mov    rsi,rbx
     76d:	mov    rdi,r12
     770:	call   775 <botlish_fn_2+0x28d>
			771: R_X86_64_PLT32	rt_int_cmp-0x4
     775:	mov    ecx,0x2
     77a:	test   rax,rax
     77d:	cmovle rcx,QWORD PTR [rip+0x38b]        # b10 <botlish_fn_2+0x628>
     785:	jmp    7a1 <botlish_fn_2+0x2b9>
     78a:	mov    ecx,0x2
     78f:	mov    rsi,rbx
     792:	cmp    rsi,0xdf
     799:	cmovle rcx,QWORD PTR [rip+0x36f]        # b10 <botlish_fn_2+0x628>
     7a1:	cmp    rcx,0x6
     7a5:	je     ab7 <botlish_fn_2+0x5cf>
     7ab:	mov    rsi,rbx
     7ae:	test   rsi,0x1
     7b5:	jne    7e1 <botlish_fn_2+0x2f9>
     7bb:	mov    edx,0xff
     7c0:	mov    rsi,rbx
     7c3:	mov    rdi,r12
     7c6:	call   7cb <botlish_fn_2+0x2e3>
			7c7: R_X86_64_PLT32	rt_int_cmp-0x4
     7cb:	mov    r10d,0x2
     7d1:	test   rax,rax
     7d4:	cmovle r10,QWORD PTR [rip+0x334]        # b10 <botlish_fn_2+0x628>
     7dc:	jmp    7f9 <botlish_fn_2+0x311>
     7e1:	mov    r10d,0x2
     7e7:	mov    rsi,rbx
     7ea:	cmp    rsi,0xff
     7f1:	cmovle r10,QWORD PTR [rip+0x317]        # b10 <botlish_fn_2+0x628>
     7f9:	cmp    r10,0x6
     7fd:	je     aad <botlish_fn_2+0x5c5>
     803:	mov    rsi,rbx
     806:	test   rsi,0x1
     80d:	jne    838 <botlish_fn_2+0x350>
     813:	mov    edx,0x11f
     818:	mov    rsi,rbx
     81b:	mov    rdi,r12
     81e:	call   823 <botlish_fn_2+0x33b>
			81f: R_X86_64_PLT32	rt_int_cmp-0x4
     823:	mov    ecx,0x2
     828:	test   rax,rax
     82b:	cmovle rcx,QWORD PTR [rip+0x2dd]        # b10 <botlish_fn_2+0x628>
     833:	jmp    84f <botlish_fn_2+0x367>
     838:	mov    ecx,0x2
     83d:	mov    rsi,rbx
     840:	cmp    rsi,0x11f
     847:	cmovle rcx,QWORD PTR [rip+0x2c1]        # b10 <botlish_fn_2+0x628>
     84f:	cmp    rcx,0x6
     853:	je     aa3 <botlish_fn_2+0x5bb>
     859:	mov    rsi,rbx
     85c:	test   rsi,0x1
     863:	jne    88e <botlish_fn_2+0x3a6>
     869:	mov    edx,0x13f
     86e:	mov    rsi,rbx
     871:	mov    rdi,r12
     874:	call   879 <botlish_fn_2+0x391>
			875: R_X86_64_PLT32	rt_int_cmp-0x4
     879:	mov    ecx,0x2
     87e:	test   rax,rax
     881:	cmovle rcx,QWORD PTR [rip+0x287]        # b10 <botlish_fn_2+0x628>
     889:	jmp    8a5 <botlish_fn_2+0x3bd>
     88e:	mov    ecx,0x2
     893:	mov    rsi,rbx
     896:	cmp    rsi,0x13f
     89d:	cmovle rcx,QWORD PTR [rip+0x26b]        # b10 <botlish_fn_2+0x628>
     8a5:	cmp    rcx,0x6
     8a9:	je     a99 <botlish_fn_2+0x5b1>
     8af:	mov    rsi,rbx
     8b2:	test   rsi,0x1
     8b9:	jne    8e4 <botlish_fn_2+0x3fc>
     8bf:	mov    edx,0x15f
     8c4:	mov    rsi,rbx
     8c7:	mov    rdi,r12
     8ca:	call   8cf <botlish_fn_2+0x3e7>
			8cb: R_X86_64_PLT32	rt_int_cmp-0x4
     8cf:	mov    ecx,0x2
     8d4:	test   rax,rax
     8d7:	cmovle rcx,QWORD PTR [rip+0x231]        # b10 <botlish_fn_2+0x628>
     8df:	jmp    8fb <botlish_fn_2+0x413>
     8e4:	mov    ecx,0x2
     8e9:	mov    rsi,rbx
     8ec:	cmp    rsi,0x15f
     8f3:	cmovle rcx,QWORD PTR [rip+0x215]        # b10 <botlish_fn_2+0x628>
     8fb:	cmp    rcx,0x6
     8ff:	je     a8f <botlish_fn_2+0x5a7>
     905:	mov    rsi,rbx
     908:	test   rsi,0x1
     90f:	jne    93a <botlish_fn_2+0x452>
     915:	mov    edx,0x17f
     91a:	mov    rsi,rbx
     91d:	mov    rdi,r12
     920:	call   925 <botlish_fn_2+0x43d>
			921: R_X86_64_PLT32	rt_int_cmp-0x4
     925:	mov    edi,0x2
     92a:	test   rax,rax
     92d:	cmovle rdi,QWORD PTR [rip+0x1db]        # b10 <botlish_fn_2+0x628>
     935:	jmp    951 <botlish_fn_2+0x469>
     93a:	mov    edi,0x2
     93f:	mov    rsi,rbx
     942:	cmp    rsi,0x17f
     949:	cmovle rdi,QWORD PTR [rip+0x1bf]        # b10 <botlish_fn_2+0x628>
     951:	cmp    rdi,0x6
     955:	je     a85 <botlish_fn_2+0x59d>
     95b:	mov    rsi,rbx
     95e:	test   rsi,0x1
     965:	jne    990 <botlish_fn_2+0x4a8>
     96b:	mov    edx,0x19f
     970:	mov    rsi,rbx
     973:	mov    rdi,r12
     976:	call   97b <botlish_fn_2+0x493>
			977: R_X86_64_PLT32	rt_int_cmp-0x4
     97b:	mov    ecx,0x2
     980:	test   rax,rax
     983:	cmovle rcx,QWORD PTR [rip+0x185]        # b10 <botlish_fn_2+0x628>
     98b:	jmp    9a7 <botlish_fn_2+0x4bf>
     990:	mov    ecx,0x2
     995:	mov    rsi,rbx
     998:	cmp    rsi,0x19f
     99f:	cmovle rcx,QWORD PTR [rip+0x169]        # b10 <botlish_fn_2+0x628>
     9a7:	cmp    rcx,0x6
     9ab:	je     a7b <botlish_fn_2+0x593>
     9b1:	mov    rsi,rbx
     9b4:	test   rsi,0x1
     9bb:	jne    9e6 <botlish_fn_2+0x4fe>
     9c1:	mov    edx,0x1bf
     9c6:	mov    rsi,rbx
     9c9:	mov    rdi,r12
     9cc:	call   9d1 <botlish_fn_2+0x4e9>
			9cd: R_X86_64_PLT32	rt_int_cmp-0x4
     9d1:	mov    ecx,0x2
     9d6:	test   rax,rax
     9d9:	cmovle rcx,QWORD PTR [rip+0x12f]        # b10 <botlish_fn_2+0x628>
     9e1:	jmp    9fd <botlish_fn_2+0x515>
     9e6:	mov    ecx,0x2
     9eb:	mov    rsi,rbx
     9ee:	cmp    rsi,0x1bf
     9f5:	cmovle rcx,QWORD PTR [rip+0x113]        # b10 <botlish_fn_2+0x628>
     9fd:	cmp    rcx,0x6
     a01:	je     a71 <botlish_fn_2+0x589>
     a07:	mov    rsi,rbx
     a0a:	test   rsi,0x1
     a11:	jne    a3c <botlish_fn_2+0x554>
     a17:	mov    edx,0x1df
     a1c:	mov    rsi,rbx
     a1f:	mov    rdi,r12
     a22:	call   a27 <botlish_fn_2+0x53f>
			a23: R_X86_64_PLT32	rt_int_cmp-0x4
     a27:	mov    ecx,0x2
     a2c:	test   rax,rax
     a2f:	cmovle rcx,QWORD PTR [rip+0xd9]        # b10 <botlish_fn_2+0x628>
     a37:	jmp    a53 <botlish_fn_2+0x56b>
     a3c:	mov    ecx,0x2
     a41:	mov    rsi,rbx
     a44:	cmp    rsi,0x1df
     a4b:	cmovle rcx,QWORD PTR [rip+0xbd]        # b10 <botlish_fn_2+0x628>
     a53:	cmp    rcx,0x6
     a57:	je     a67 <botlish_fn_2+0x57f>
     a5d:	mov    eax,0x1f
     a62:	jmp    af8 <botlish_fn_2+0x610>
     a67:	mov    eax,0x1d
     a6c:	jmp    af8 <botlish_fn_2+0x610>
     a71:	mov    eax,0x1b
     a76:	jmp    af8 <botlish_fn_2+0x610>
     a7b:	mov    eax,0x19
     a80:	jmp    af8 <botlish_fn_2+0x610>
     a85:	mov    eax,0x17
     a8a:	jmp    af8 <botlish_fn_2+0x610>
     a8f:	mov    eax,0x15
     a94:	jmp    af8 <botlish_fn_2+0x610>
     a99:	mov    eax,0x13
     a9e:	jmp    af8 <botlish_fn_2+0x610>
     aa3:	mov    eax,0x11
     aa8:	jmp    af8 <botlish_fn_2+0x610>
     aad:	mov    eax,0xf
     ab2:	jmp    af8 <botlish_fn_2+0x610>
     ab7:	mov    eax,0xd
     abc:	jmp    af8 <botlish_fn_2+0x610>
     ac1:	mov    eax,0xb
     ac6:	jmp    af8 <botlish_fn_2+0x610>
     acb:	mov    eax,0x9
     ad0:	jmp    af8 <botlish_fn_2+0x610>
     ad5:	mov    eax,0x7
     ada:	jmp    af8 <botlish_fn_2+0x610>
     adf:	mov    eax,0x5
     ae4:	jmp    af8 <botlish_fn_2+0x610>
     ae9:	mov    eax,0x3
     aee:	jmp    af8 <botlish_fn_2+0x610>
     af3:	mov    eax,0x1
     af8:	mov    rbx,QWORD PTR [rsp]
     afc:	mov    r12,QWORD PTR [rsp+0x8]
     b01:	add    rsp,0x10
     b05:	mov    rsp,rbp
     b08:	pop    rbp
     b09:	ret
     b0a:	add    BYTE PTR [rax],al
     b0c:	add    BYTE PTR [rax],al
     b0e:	add    BYTE PTR [rax],al
     b10:	(bad)
     b11:	add    BYTE PTR [rax],al
     b13:	add    BYTE PTR [rax],al
     b15:	add    BYTE PTR [rax],al
	...

0000000000000b18 <botlish_entry_2: high_nibble<generic>>:
     b18:	push   rbp
     b19:	mov    rbp,rsp
     b1c:	mov    rsi,QWORD PTR [rdx]
     b1f:	call   b24 <botlish_entry_2+0xc>
			b20: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
     b24:	mov    rsp,rbp
     b27:	pop    rbp
     b28:	ret
     b29:	add    BYTE PTR [rax],al
     b2b:	add    BYTE PTR [rax],al
     b2d:	add    BYTE PTR [rax],al
	...

0000000000000b30 <botlish_fn_3: is_unreserved<generic>>:
     b30:	push   rbp
     b31:	mov    rbp,rsp
     b34:	sub    rsp,0x20
     b38:	mov    QWORD PTR [rsp],rbx
     b3c:	mov    QWORD PTR [rsp+0x8],r12
     b41:	mov    QWORD PTR [rsp+0x10],r13
     b46:	mov    r8d,0x1
     b4c:	test   rsi,0x1
     b53:	jne    b73 <botlish_fn_3+0x43>
     b59:	xor    r8d,r8d
     b5c:	test   rsi,0x7
     b63:	jne    b73 <botlish_fn_3+0x43>
     b69:	movzx  rax,BYTE PTR [rsi]
     b6d:	cmp    al,0x1
     b6f:	sete   r8b
     b73:	test   r8b,r8b
     b76:	jne    bac <botlish_fn_3+0x7c>
     b7c:	mov    rdx,QWORD PTR [rdi+0x10]
     b80:	mov    rcx,QWORD PTR [rdx+0xa0]
     b87:	xor    rbx,rbx
     b8a:	mov    rdx,rbx
     b8d:	call   b92 <botlish_fn_3+0x62>
			b8e: R_X86_64_PLT32	rt_type_error-0x4
     b92:	mov    rax,rbx
     b95:	mov    rbx,QWORD PTR [rsp]
     b99:	mov    r12,QWORD PTR [rsp+0x8]
     b9e:	mov    r13,QWORD PTR [rsp+0x10]
     ba3:	add    rsp,0x20
     ba7:	mov    rsp,rbp
     baa:	pop    rbp
     bab:	ret
     bac:	mov    r12,rdi
     baf:	test   rsi,0x1
     bb6:	mov    rbx,rsi
     bb9:	jne    be4 <botlish_fn_3+0xb4>
     bbf:	mov    edx,0x59
     bc4:	mov    rsi,rbx
     bc7:	mov    rdi,r12
     bca:	call   bcf <botlish_fn_3+0x9f>
			bcb: R_X86_64_PLT32	rt_int_cmp-0x4
     bcf:	mov    ecx,0x2
     bd4:	test   rax,rax
     bd7:	cmovle rcx,QWORD PTR [rip+0x461]        # 1040 <botlish_fn_3+0x510>
     bdf:	jmp    bf8 <botlish_fn_3+0xc8>
     be4:	mov    ecx,0x2
     be9:	mov    rsi,rbx
     bec:	cmp    rsi,0x59
     bf0:	cmovle rcx,QWORD PTR [rip+0x448]        # 1040 <botlish_fn_3+0x510>
     bf8:	mov    eax,0x6
     bfd:	mov    r13,rax
     c00:	cmp    rcx,0x6
     c04:	je     1023 <botlish_fn_3+0x4f3>
     c0a:	mov    rsi,rbx
     c0d:	test   rsi,0x1
     c14:	jne    c3f <botlish_fn_3+0x10f>
     c1a:	mov    edx,0x5d
     c1f:	mov    rsi,rbx
     c22:	mov    rdi,r12
     c25:	call   c2a <botlish_fn_3+0xfa>
			c26: R_X86_64_PLT32	rt_int_cmp-0x4
     c2a:	mov    ecx,0x2
     c2f:	test   rax,rax
     c32:	cmovle rcx,QWORD PTR [rip+0x406]        # 1040 <botlish_fn_3+0x510>
     c3a:	jmp    c53 <botlish_fn_3+0x123>
     c3f:	mov    ecx,0x2
     c44:	mov    rsi,rbx
     c47:	cmp    rsi,0x5d
     c4b:	cmovle rcx,QWORD PTR [rip+0x3ed]        # 1040 <botlish_fn_3+0x510>
     c53:	cmp    rcx,0x6
     c57:	je     101b <botlish_fn_3+0x4eb>
     c5d:	mov    rsi,rbx
     c60:	test   rsi,0x1
     c67:	jne    c92 <botlish_fn_3+0x162>
     c6d:	mov    edx,0x5f
     c72:	mov    rsi,rbx
     c75:	mov    rdi,r12
     c78:	call   c7d <botlish_fn_3+0x14d>
			c79: R_X86_64_PLT32	rt_int_cmp-0x4
     c7d:	mov    ecx,0x2
     c82:	test   rax,rax
     c85:	cmovle rcx,QWORD PTR [rip+0x3b3]        # 1040 <botlish_fn_3+0x510>
     c8d:	jmp    ca6 <botlish_fn_3+0x176>
     c92:	mov    ecx,0x2
     c97:	mov    rsi,rbx
     c9a:	cmp    rsi,0x5f
     c9e:	cmovle rcx,QWORD PTR [rip+0x39a]        # 1040 <botlish_fn_3+0x510>
     ca6:	cmp    rcx,0x6
     caa:	je     1011 <botlish_fn_3+0x4e1>
     cb0:	mov    rsi,rbx
     cb3:	test   rsi,0x1
     cba:	jne    ce5 <botlish_fn_3+0x1b5>
     cc0:	mov    edx,0x73
     cc5:	mov    rsi,rbx
     cc8:	mov    rdi,r12
     ccb:	call   cd0 <botlish_fn_3+0x1a0>
			ccc: R_X86_64_PLT32	rt_int_cmp-0x4
     cd0:	mov    ecx,0x2
     cd5:	test   rax,rax
     cd8:	cmovle rcx,QWORD PTR [rip+0x360]        # 1040 <botlish_fn_3+0x510>
     ce0:	jmp    cf9 <botlish_fn_3+0x1c9>
     ce5:	mov    ecx,0x2
     cea:	mov    rsi,rbx
     ced:	cmp    rsi,0x73
     cf1:	cmovle rcx,QWORD PTR [rip+0x347]        # 1040 <botlish_fn_3+0x510>
     cf9:	cmp    rcx,0x6
     cfd:	je     1009 <botlish_fn_3+0x4d9>
     d03:	mov    rsi,rbx
     d06:	test   rsi,0x1
     d0d:	jne    d38 <botlish_fn_3+0x208>
     d13:	mov    edx,0x81
     d18:	mov    rsi,rbx
     d1b:	mov    rdi,r12
     d1e:	call   d23 <botlish_fn_3+0x1f3>
			d1f: R_X86_64_PLT32	rt_int_cmp-0x4
     d23:	mov    ecx,0x2
     d28:	test   rax,rax
     d2b:	cmovle rcx,QWORD PTR [rip+0x30d]        # 1040 <botlish_fn_3+0x510>
     d33:	jmp    d4f <botlish_fn_3+0x21f>
     d38:	mov    ecx,0x2
     d3d:	mov    rsi,rbx
     d40:	cmp    rsi,0x81
     d47:	cmovle rcx,QWORD PTR [rip+0x2f1]        # 1040 <botlish_fn_3+0x510>
     d4f:	cmp    rcx,0x6
     d53:	je     fff <botlish_fn_3+0x4cf>
     d59:	mov    rsi,rbx
     d5c:	test   rsi,0x1
     d63:	jne    d8e <botlish_fn_3+0x25e>
     d69:	mov    edx,0xb5
     d6e:	mov    rsi,rbx
     d71:	mov    rdi,r12
     d74:	call   d79 <botlish_fn_3+0x249>
			d75: R_X86_64_PLT32	rt_int_cmp-0x4
     d79:	mov    ecx,0x2
     d7e:	test   rax,rax
     d81:	cmovle rcx,QWORD PTR [rip+0x2b7]        # 1040 <botlish_fn_3+0x510>
     d89:	jmp    da5 <botlish_fn_3+0x275>
     d8e:	mov    ecx,0x2
     d93:	mov    rsi,rbx
     d96:	cmp    rsi,0xb5
     d9d:	cmovle rcx,QWORD PTR [rip+0x29b]        # 1040 <botlish_fn_3+0x510>
     da5:	cmp    rcx,0x6
     da9:	je     ff7 <botlish_fn_3+0x4c7>
     daf:	mov    rsi,rbx
     db2:	test   rsi,0x1
     db9:	jne    de4 <botlish_fn_3+0x2b4>
     dbf:	mov    edx,0xbd
     dc4:	mov    rsi,rbx
     dc7:	mov    rdi,r12
     dca:	call   dcf <botlish_fn_3+0x29f>
			dcb: R_X86_64_PLT32	rt_int_cmp-0x4
     dcf:	mov    ecx,0x2
     dd4:	test   rax,rax
     dd7:	cmovle rcx,QWORD PTR [rip+0x261]        # 1040 <botlish_fn_3+0x510>
     ddf:	jmp    dfb <botlish_fn_3+0x2cb>
     de4:	mov    ecx,0x2
     de9:	mov    rsi,rbx
     dec:	cmp    rsi,0xbd
     df3:	cmovle rcx,QWORD PTR [rip+0x245]        # 1040 <botlish_fn_3+0x510>
     dfb:	cmp    rcx,0x6
     dff:	je     fed <botlish_fn_3+0x4bd>
     e05:	mov    rsi,rbx
     e08:	test   rsi,0x1
     e0f:	jne    e3b <botlish_fn_3+0x30b>
     e15:	mov    edx,0xbf
     e1a:	mov    rsi,rbx
     e1d:	mov    rdi,r12
     e20:	call   e25 <botlish_fn_3+0x2f5>
			e21: R_X86_64_PLT32	rt_int_cmp-0x4
     e25:	mov    r11d,0x2
     e2b:	test   rax,rax
     e2e:	cmovle r11,QWORD PTR [rip+0x20a]        # 1040 <botlish_fn_3+0x510>
     e36:	jmp    e53 <botlish_fn_3+0x323>
     e3b:	mov    r11d,0x2
     e41:	mov    rsi,rbx
     e44:	cmp    rsi,0xbf
     e4b:	cmovle r11,QWORD PTR [rip+0x1ed]        # 1040 <botlish_fn_3+0x510>
     e53:	cmp    r11,0x6
     e57:	je     fe5 <botlish_fn_3+0x4b5>
     e5d:	mov    rsi,rbx
     e60:	test   rsi,0x1
     e67:	jne    e92 <botlish_fn_3+0x362>
     e6d:	mov    edx,0xc1
     e72:	mov    rsi,rbx
     e75:	mov    rdi,r12
     e78:	call   e7d <botlish_fn_3+0x34d>
			e79: R_X86_64_PLT32	rt_int_cmp-0x4
     e7d:	mov    ecx,0x2
     e82:	test   rax,rax
     e85:	cmovle rcx,QWORD PTR [rip+0x1b3]        # 1040 <botlish_fn_3+0x510>
     e8d:	jmp    ea9 <botlish_fn_3+0x379>
     e92:	mov    ecx,0x2
     e97:	mov    rsi,rbx
     e9a:	cmp    rsi,0xc1
     ea1:	cmovle rcx,QWORD PTR [rip+0x197]        # 1040 <botlish_fn_3+0x510>
     ea9:	cmp    rcx,0x6
     ead:	je     fdb <botlish_fn_3+0x4ab>
     eb3:	mov    rsi,rbx
     eb6:	test   rsi,0x1
     ebd:	jne    ee8 <botlish_fn_3+0x3b8>
     ec3:	mov    edx,0xf5
     ec8:	mov    rsi,rbx
     ecb:	mov    rdi,r12
     ece:	call   ed3 <botlish_fn_3+0x3a3>
			ecf: R_X86_64_PLT32	rt_int_cmp-0x4
     ed3:	mov    ecx,0x2
     ed8:	test   rax,rax
     edb:	cmovle rcx,QWORD PTR [rip+0x15d]        # 1040 <botlish_fn_3+0x510>
     ee3:	jmp    eff <botlish_fn_3+0x3cf>
     ee8:	mov    ecx,0x2
     eed:	mov    rsi,rbx
     ef0:	cmp    rsi,0xf5
     ef7:	cmovle rcx,QWORD PTR [rip+0x141]        # 1040 <botlish_fn_3+0x510>
     eff:	cmp    rcx,0x6
     f03:	je     fd3 <botlish_fn_3+0x4a3>
     f09:	mov    rsi,rbx
     f0c:	test   rsi,0x1
     f13:	jne    f3e <botlish_fn_3+0x40e>
     f19:	mov    edx,0xfb
     f1e:	mov    rsi,rbx
     f21:	mov    rdi,r12
     f24:	call   f29 <botlish_fn_3+0x3f9>
			f25: R_X86_64_PLT32	rt_int_cmp-0x4
     f29:	mov    ecx,0x2
     f2e:	test   rax,rax
     f31:	cmovle rcx,QWORD PTR [rip+0x107]        # 1040 <botlish_fn_3+0x510>
     f39:	jmp    f55 <botlish_fn_3+0x425>
     f3e:	mov    ecx,0x2
     f43:	mov    rsi,rbx
     f46:	cmp    rsi,0xfb
     f4d:	cmovle rcx,QWORD PTR [rip+0xeb]        # 1040 <botlish_fn_3+0x510>
     f55:	cmp    rcx,0x6
     f59:	je     fc9 <botlish_fn_3+0x499>
     f5f:	mov    rsi,rbx
     f62:	test   rsi,0x1
     f69:	jne    f95 <botlish_fn_3+0x465>
     f6f:	mov    edx,0xfd
     f74:	mov    rsi,rbx
     f77:	mov    rdi,r12
     f7a:	call   f7f <botlish_fn_3+0x44f>
			f7b: R_X86_64_PLT32	rt_int_cmp-0x4
     f7f:	mov    r8d,0x2
     f85:	test   rax,rax
     f88:	cmovle r8,QWORD PTR [rip+0xb0]        # 1040 <botlish_fn_3+0x510>
     f90:	jmp    fad <botlish_fn_3+0x47d>
     f95:	mov    r8d,0x2
     f9b:	mov    rsi,rbx
     f9e:	cmp    rsi,0xfd
     fa5:	cmovle r8,QWORD PTR [rip+0x93]        # 1040 <botlish_fn_3+0x510>
     fad:	cmp    r8,0x6
     fb1:	je     fc1 <botlish_fn_3+0x491>
     fb7:	mov    eax,0x2
     fbc:	jmp    1028 <botlish_fn_3+0x4f8>
     fc1:	mov    rax,r13
     fc4:	jmp    1028 <botlish_fn_3+0x4f8>
     fc9:	mov    eax,0x2
     fce:	jmp    1028 <botlish_fn_3+0x4f8>
     fd3:	mov    rax,r13
     fd6:	jmp    1028 <botlish_fn_3+0x4f8>
     fdb:	mov    eax,0x2
     fe0:	jmp    1028 <botlish_fn_3+0x4f8>
     fe5:	mov    rax,r13
     fe8:	jmp    1028 <botlish_fn_3+0x4f8>
     fed:	mov    eax,0x2
     ff2:	jmp    1028 <botlish_fn_3+0x4f8>
     ff7:	mov    rax,r13
     ffa:	jmp    1028 <botlish_fn_3+0x4f8>
     fff:	mov    eax,0x2
    1004:	jmp    1028 <botlish_fn_3+0x4f8>
    1009:	mov    rax,r13
    100c:	jmp    1028 <botlish_fn_3+0x4f8>
    1011:	mov    eax,0x2
    1016:	jmp    1028 <botlish_fn_3+0x4f8>
    101b:	mov    rax,r13
    101e:	jmp    1028 <botlish_fn_3+0x4f8>
    1023:	mov    eax,0x2
    1028:	mov    rbx,QWORD PTR [rsp]
    102c:	mov    r12,QWORD PTR [rsp+0x8]
    1031:	mov    r13,QWORD PTR [rsp+0x10]
    1036:	add    rsp,0x20
    103a:	mov    rsp,rbp
    103d:	pop    rbp
    103e:	ret
    103f:	add    BYTE PTR [rsi],al
    1041:	add    BYTE PTR [rax],al
    1043:	add    BYTE PTR [rax],al
    1045:	add    BYTE PTR [rax],al
	...

0000000000001048 <botlish_entry_3: is_unreserved<generic>>:
    1048:	push   rbp
    1049:	mov    rbp,rsp
    104c:	mov    rsi,QWORD PTR [rdx]
    104f:	call   1054 <botlish_entry_3+0xc>
			1050: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    1054:	mov    rsp,rbp
    1057:	pop    rbp
    1058:	ret

0000000000001059 <botlish_fn_4: hex_pair<generic>>:
    1059:	push   rbp
    105a:	mov    rbp,rsp
    105d:	sub    rsp,0x30
    1061:	mov    QWORD PTR [rsp+0x10],rbx
    1066:	mov    QWORD PTR [rsp+0x18],r12
    106b:	mov    QWORD PTR [rsp+0x20],r13
    1070:	mov    QWORD PTR [rsp+0x28],r14
    1075:	mov    rbx,rdi
    1078:	mov    r12,rdx
    107b:	mov    rax,QWORD PTR [rsi+0x20]
    107f:	mov    r13,rsi
    1082:	mov    rsi,QWORD PTR [rax]
    1085:	mov    r14,rsi
    1088:	mov    rsi,r12
    108b:	mov    rdi,rbx
    108e:	call   1093 <botlish_fn_4+0x3a>
			108f: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
    1093:	test   rax,rax
    1096:	je     11ed <botlish_fn_4+0x194>
    109c:	test   rax,0x1
    10a2:	jne    10b3 <botlish_fn_4+0x5a>
    10a8:	mov    rdx,rax
    10ab:	mov    rsi,r14
    10ae:	jmp    10cc <botlish_fn_4+0x73>
    10b3:	mov    rsi,r14
    10b6:	mov    rdx,QWORD PTR [rsi+0x8]
    10ba:	mov    rcx,rax
    10bd:	sar    rcx,1
    10c0:	cmp    rcx,rdx
    10c3:	jb     10e5 <botlish_fn_4+0x8c>
    10c9:	mov    rdx,rax
    10cc:	mov    rdi,rbx
    10cf:	call   10d4 <botlish_fn_4+0x7b>
			10d0: R_X86_64_PLT32	rt_list_get-0x4
    10d4:	test   rax,rax
    10d7:	je     11ed <botlish_fn_4+0x194>
    10dd:	mov    rsi,rax
    10e0:	jmp    10ed <botlish_fn_4+0x94>
    10e5:	mov    rax,QWORD PTR [rsi+0x10]
    10e9:	mov    rsi,QWORD PTR [rax+rcx*8]
    10ed:	mov    QWORD PTR [rsp],rsi
    10f1:	mov    rax,rsi
    10f4:	mov    rsi,r13
    10f7:	mov    r13,rax
    10fa:	mov    rax,QWORD PTR [rsi+0x20]
    10fe:	mov    rsi,QWORD PTR [rax]
    1101:	mov    r14,rsi
    1104:	mov    eax,0x1
    1109:	mov    rdx,r12
    110c:	test   rdx,0x1
    1113:	je     1121 <botlish_fn_4+0xc8>
    1119:	mov    r12,rdx
    111c:	jmp    1144 <botlish_fn_4+0xeb>
    1121:	xor    eax,eax
    1123:	test   rdx,0x7
    112a:	je     1138 <botlish_fn_4+0xdf>
    1130:	mov    r12,rdx
    1133:	jmp    1144 <botlish_fn_4+0xeb>
    1138:	movzx  rax,BYTE PTR [rdx]
    113c:	mov    r12,rdx
    113f:	cmp    al,0x1
    1141:	sete   al
    1144:	test   al,al
    1146:	jne    116a <botlish_fn_4+0x111>
    114c:	mov    rdi,rbx
    114f:	mov    rax,QWORD PTR [rdi+0x10]
    1153:	mov    rcx,QWORD PTR [rax+0xa8]
    115a:	xor    rdx,rdx
    115d:	mov    rsi,r12
    1160:	call   1165 <botlish_fn_4+0x10c>
			1161: R_X86_64_PLT32	rt_type_error-0x4
    1165:	jmp    11ed <botlish_fn_4+0x194>
    116a:	mov    rsi,r12
    116d:	mov    edx,0x21
    1172:	mov    rdi,rbx
    1175:	call   117a <botlish_fn_4+0x121>
			1176: R_X86_64_PLT32	rt_int_mod-0x4
    117a:	test   rax,rax
    117d:	je     11ed <botlish_fn_4+0x194>
    1183:	test   rax,0x1
    1189:	jne    119a <botlish_fn_4+0x141>
    118f:	mov    rdx,rax
    1192:	mov    rsi,r14
    1195:	jmp    11b3 <botlish_fn_4+0x15a>
    119a:	mov    rsi,r14
    119d:	mov    r8,QWORD PTR [rsi+0x8]
    11a1:	mov    rdi,rax
    11a4:	sar    rdi,1
    11a7:	mov    rdx,rax
    11aa:	cmp    rdi,r8
    11ad:	jb     11cc <botlish_fn_4+0x173>
    11b3:	mov    rdi,rbx
    11b6:	call   11bb <botlish_fn_4+0x162>
			11b7: R_X86_64_PLT32	rt_list_get-0x4
    11bb:	test   rax,rax
    11be:	je     11ed <botlish_fn_4+0x194>
    11c4:	mov    rdx,rax
    11c7:	jmp    11d4 <botlish_fn_4+0x17b>
    11cc:	mov    rax,QWORD PTR [rsi+0x10]
    11d0:	mov    rdx,QWORD PTR [rax+rdi*8]
    11d4:	mov    QWORD PTR [rsp+0x8],rdx
    11d9:	mov    rsi,r13
    11dc:	mov    rdi,rbx
    11df:	call   11e4 <botlish_fn_4+0x18b>
			11e0: R_X86_64_PLT32	rt_str_cat-0x4
    11e4:	test   rax,rax
    11e7:	jne    120d <botlish_fn_4+0x1b4>
    11ed:	xor    rax,rax
    11f0:	mov    rbx,QWORD PTR [rsp+0x10]
    11f5:	mov    r12,QWORD PTR [rsp+0x18]
    11fa:	mov    r13,QWORD PTR [rsp+0x20]
    11ff:	mov    r14,QWORD PTR [rsp+0x28]
    1204:	add    rsp,0x30
    1208:	mov    rsp,rbp
    120b:	pop    rbp
    120c:	ret
    120d:	mov    rbx,QWORD PTR [rsp+0x10]
    1212:	mov    r12,QWORD PTR [rsp+0x18]
    1217:	mov    r13,QWORD PTR [rsp+0x20]
    121c:	mov    r14,QWORD PTR [rsp+0x28]
    1221:	add    rsp,0x30
    1225:	mov    rsp,rbp
    1228:	pop    rbp
    1229:	ret

000000000000122a <botlish_entry_4: hex_pair<generic>>:
    122a:	push   rbp
    122b:	mov    rbp,rsp
    122e:	mov    rdx,QWORD PTR [rdx]
    1231:	call   1236 <botlish_entry_4+0xc>
			1232: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    1236:	mov    rsp,rbp
    1239:	pop    rbp
    123a:	ret
    123b:	add    BYTE PTR [rax],al
    123d:	add    BYTE PTR [rax],al
	...

0000000000001240 <botlish_fn_5: esc_bytes<generic>>:
    1240:	push   rbp
    1241:	mov    rbp,rsp
    1244:	sub    rsp,0x80
    124b:	mov    QWORD PTR [rsp+0x50],rbx
    1250:	mov    QWORD PTR [rsp+0x58],r12
    1255:	mov    QWORD PTR [rsp+0x60],r13
    125a:	mov    QWORD PTR [rsp+0x68],r14
    125f:	mov    QWORD PTR [rsp+0x70],r15
    1264:	mov    r13,rdi
    1267:	mov    r14,rsi
    126a:	mov    QWORD PTR [rsp+0x28],0x0
    1273:	mov    QWORD PTR [rsp+0x30],0x0
    127c:	mov    QWORD PTR [rsp],rdx
    1280:	mov    QWORD PTR [rsp+0x8],rcx
    1285:	mov    QWORD PTR [rsp+0x10],r8
    128a:	mov    r15,r8
    128d:	mov    QWORD PTR [rsp+0x38],rcx
    1292:	xor    eax,eax
    1294:	test   rdx,0x7
    129b:	je     12a9 <botlish_fn_5+0x69>
    12a1:	mov    rsi,rdx
    12a4:	jmp    12b7 <botlish_fn_5+0x77>
    12a9:	movzx  r10,BYTE PTR [rdx]
    12ad:	mov    rsi,rdx
    12b0:	cmp    r10b,0x3
    12b4:	sete   al
    12b7:	test   al,al
    12b9:	jne    12dc <botlish_fn_5+0x9c>
    12bf:	mov    rdi,r13
    12c2:	mov    rax,QWORD PTR [rdi+0x10]
    12c6:	mov    rcx,QWORD PTR [rax+0xb0]
    12cd:	mov    edx,0x4
    12d2:	call   12d7 <botlish_fn_5+0x97>
			12d3: R_X86_64_PLT32	rt_type_error-0x4
    12d7:	jmp    1514 <botlish_fn_5+0x2d4>
    12dc:	mov    r12,rsi
    12df:	mov    rdi,r13
    12e2:	call   12e7 <botlish_fn_5+0xa7>
			12e3: R_X86_64_PLT32	rt_list_len-0x4
    12e7:	mov    ecx,0x1
    12ec:	mov    rsi,QWORD PTR [rsp+0x38]
    12f1:	test   rsi,0x1
    12f8:	jne    1322 <botlish_fn_5+0xe2>
    12fe:	xor    ecx,ecx
    1300:	mov    rsi,QWORD PTR [rsp+0x38]
    1305:	test   rsi,0x7
    130c:	jne    1322 <botlish_fn_5+0xe2>
    1312:	mov    rsi,QWORD PTR [rsp+0x38]
    1317:	movzx  rcx,BYTE PTR [rsi]
    131b:	rex cmp cl,0x1
    131f:	sete   cl
    1322:	test   cl,cl
    1324:	jne    134a <botlish_fn_5+0x10a>
    132a:	mov    rdi,r13
    132d:	mov    rax,QWORD PTR [rdi+0x10]
    1331:	mov    rcx,QWORD PTR [rax+0xb8]
    1338:	xor    rdx,rdx
    133b:	mov    rsi,QWORD PTR [rsp+0x38]
    1340:	call   1345 <botlish_fn_5+0x105>
			1341: R_X86_64_PLT32	rt_type_error-0x4
    1345:	jmp    1514 <botlish_fn_5+0x2d4>
    134a:	mov    rsi,QWORD PTR [rsp+0x38]
    134f:	mov    rcx,rsi
    1352:	and    rcx,rax
    1355:	mov    rdx,rax
    1358:	test   rcx,0x1
    135f:	jne    1387 <botlish_fn_5+0x147>
    1365:	mov    rsi,QWORD PTR [rsp+0x38]
    136a:	mov    rdi,r13
    136d:	call   1372 <botlish_fn_5+0x132>
			136e: R_X86_64_PLT32	rt_int_cmp-0x4
    1372:	mov    ecx,0x2
    1377:	test   rax,rax
    137a:	cmovge rcx,QWORD PTR [rip+0x20e]        # 1590 <botlish_fn_5+0x350>
    1382:	jmp    139c <botlish_fn_5+0x15c>
    1387:	mov    ecx,0x2
    138c:	mov    rsi,QWORD PTR [rsp+0x38]
    1391:	cmp    rsi,rdx
    1394:	cmovge rcx,QWORD PTR [rip+0x1f4]        # 1590 <botlish_fn_5+0x350>
    139c:	cmp    rcx,0x6
    13a0:	je     1562 <botlish_fn_5+0x322>
    13a6:	mov    rbx,r14
    13a9:	mov    QWORD PTR [rsp+0x18],rbx
    13ae:	mov    QWORD PTR [rsp+0x20],0x3
    13b7:	mov    rsi,QWORD PTR [rsp+0x38]
    13bc:	test   rsi,0x1
    13c3:	je     13e0 <botlish_fn_5+0x1a0>
    13c9:	mov    rsi,QWORD PTR [rsp+0x38]
    13ce:	mov    rax,rsi
    13d1:	add    rax,0x2
    13d5:	seto   cl
    13d8:	test   cl,cl
    13da:	je     13f2 <botlish_fn_5+0x1b2>
    13e0:	mov    edx,0x3
    13e5:	mov    rsi,QWORD PTR [rsp+0x38]
    13ea:	mov    rdi,r13
    13ed:	call   13f2 <botlish_fn_5+0x1b2>
			13ee: R_X86_64_PLT32	rt_int_add-0x4
    13f2:	mov    QWORD PTR [rsp+0x8],rax
    13f7:	mov    rdi,r13
    13fa:	mov    QWORD PTR [rsp+0x40],rax
    13ff:	mov    rax,QWORD PTR [rdi+0x10]
    1403:	mov    rsi,QWORD PTR [rax+0xc0]
    140a:	mov    QWORD PTR [rsp+0x20],rsi
    140f:	mov    r14,rsi
    1412:	mov    rax,QWORD PTR [rbx+0x20]
    1416:	mov    rsi,QWORD PTR [rax]
    1419:	mov    QWORD PTR [rsp+0x28],rsi
    141e:	mov    QWORD PTR [rsp+0x48],rsi
    1423:	mov    rsi,QWORD PTR [rsp+0x38]
    1428:	test   rsi,0x1
    142f:	jne    143f <botlish_fn_5+0x1ff>
    1435:	mov    rdx,QWORD PTR [rsp+0x38]
    143a:	jmp    145d <botlish_fn_5+0x21d>
    143f:	mov    rcx,QWORD PTR [r12+0x8]
    1444:	mov    rsi,QWORD PTR [rsp+0x38]
    1449:	mov    rax,rsi
    144c:	sar    rax,1
    144f:	cmp    rax,rcx
    1452:	jb     1479 <botlish_fn_5+0x239>
    1458:	mov    rdx,QWORD PTR [rsp+0x38]
    145d:	mov    rsi,r12
    1460:	mov    rdi,r13
    1463:	call   1468 <botlish_fn_5+0x228>
			1464: R_X86_64_PLT32	rt_list_get-0x4
    1468:	test   rax,rax
    146b:	je     1514 <botlish_fn_5+0x2d4>
    1471:	mov    rdx,rax
    1474:	jmp    1482 <botlish_fn_5+0x242>
    1479:	mov    rcx,QWORD PTR [r12+0x10]
    147e:	mov    rdx,QWORD PTR [rcx+rax*8]
    1482:	mov    QWORD PTR [rsp+0x30],rdx
    1487:	mov    rsi,QWORD PTR [rsp+0x48]
    148c:	mov    rdi,r13
    148f:	call   1494 <botlish_fn_5+0x254>
			1490: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    1494:	test   rax,rax
    1497:	je     1514 <botlish_fn_5+0x2d4>
    149d:	mov    QWORD PTR [rsp+0x28],rax
    14a2:	mov    rdx,rax
    14a5:	mov    rsi,r14
    14a8:	mov    rdi,r13
    14ab:	call   14b0 <botlish_fn_5+0x270>
			14ac: R_X86_64_PLT32	rt_str_cat-0x4
    14b0:	test   rax,rax
    14b3:	je     1514 <botlish_fn_5+0x2d4>
    14b9:	mov    QWORD PTR [rsp+0x20],rax
    14be:	mov    rdx,rax
    14c1:	xor    eax,eax
    14c3:	mov    rsi,r15
    14c6:	test   rsi,0x7
    14cd:	jne    14de <botlish_fn_5+0x29e>
    14d3:	movzx  rdi,BYTE PTR [rsi]
    14d7:	cmp    dil,0x2
    14db:	sete   al
    14de:	test   al,al
    14e0:	jne    1503 <botlish_fn_5+0x2c3>
    14e6:	mov    rdi,r13
    14e9:	mov    r11,QWORD PTR [rdi+0x10]
    14ed:	mov    rcx,QWORD PTR [r11+0xc8]
    14f4:	mov    edx,0x1
    14f9:	call   14fe <botlish_fn_5+0x2be>
			14fa: R_X86_64_PLT32	rt_type_error-0x4
    14fe:	jmp    1514 <botlish_fn_5+0x2d4>
    1503:	mov    rdi,r13
    1506:	call   150b <botlish_fn_5+0x2cb>
			1507: R_X86_64_PLT32	rt_str_cat-0x4
    150b:	test   rax,rax
    150e:	jne    153c <botlish_fn_5+0x2fc>
    1514:	xor    rax,rax
    1517:	mov    rbx,QWORD PTR [rsp+0x50]
    151c:	mov    r12,QWORD PTR [rsp+0x58]
    1521:	mov    r13,QWORD PTR [rsp+0x60]
    1526:	mov    r14,QWORD PTR [rsp+0x68]
    152b:	mov    r15,QWORD PTR [rsp+0x70]
    1530:	add    rsp,0x80
    1537:	mov    rsp,rbp
    153a:	pop    rbp
    153b:	ret
    153c:	mov    QWORD PTR [rsp],r12
    1540:	mov    rcx,QWORD PTR [rsp+0x40]
    1545:	mov    QWORD PTR [rsp+0x8],rcx
    154a:	mov    QWORD PTR [rsp+0x10],rax
    154f:	mov    rdx,r12
    1552:	mov    r14,rbx
    1555:	mov    r15,rax
    1558:	mov    QWORD PTR [rsp+0x38],rcx
    155d:	jmp    1292 <botlish_fn_5+0x52>
    1562:	mov    rax,r15
    1565:	mov    rbx,QWORD PTR [rsp+0x50]
    156a:	mov    r12,QWORD PTR [rsp+0x58]
    156f:	mov    r13,QWORD PTR [rsp+0x60]
    1574:	mov    r14,QWORD PTR [rsp+0x68]
    1579:	mov    r15,QWORD PTR [rsp+0x70]
    157e:	add    rsp,0x80
    1585:	mov    rsp,rbp
    1588:	pop    rbp
    1589:	ret
    158a:	add    BYTE PTR [rax],al
    158c:	add    BYTE PTR [rax],al
    158e:	add    BYTE PTR [rax],al
    1590:	(bad)
    1591:	add    BYTE PTR [rax],al
    1593:	add    BYTE PTR [rax],al
    1595:	add    BYTE PTR [rax],al
	...

0000000000001598 <botlish_entry_5: esc_bytes<generic>>:
    1598:	push   rbp
    1599:	mov    rbp,rsp
    159c:	mov    r9,QWORD PTR [rdx]
    159f:	mov    rcx,QWORD PTR [rdx+0x8]
    15a3:	mov    r8,QWORD PTR [rdx+0x10]
    15a7:	mov    rdx,r9
    15aa:	call   15af <botlish_entry_5+0x17>
			15ab: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    15af:	mov    rsp,rbp
    15b2:	pop    rbp
    15b3:	ret

00000000000015b4 <botlish_fn_6: esc_char<generic>>:
    15b4:	push   rbp
    15b5:	mov    rbp,rsp
    15b8:	sub    rsp,0x50
    15bc:	mov    QWORD PTR [rsp+0x20],rbx
    15c1:	mov    QWORD PTR [rsp+0x28],r12
    15c6:	mov    QWORD PTR [rsp+0x30],r13
    15cb:	mov    QWORD PTR [rsp+0x38],r14
    15d0:	mov    QWORD PTR [rsp+0x40],r15
    15d5:	mov    r12,rsi
    15d8:	mov    QWORD PTR [rsp+0x8],0x0
    15e1:	mov    QWORD PTR [rsp+0x10],0x0
    15ea:	mov    QWORD PTR [rsp+0x18],0x0
    15f3:	mov    QWORD PTR [rsp],rdx
    15f7:	xor    r9d,r9d
    15fa:	test   rdx,0x7
    1601:	je     160f <botlish_fn_6+0x5b>
    1607:	mov    rbx,rdx
    160a:	jmp    161c <botlish_fn_6+0x68>
    160f:	movzx  rax,BYTE PTR [rdx]
    1613:	mov    rbx,rdx
    1616:	cmp    al,0x2
    1618:	sete   r9b
    161c:	test   r9b,r9b
    161f:	jne    1642 <botlish_fn_6+0x8e>
    1625:	mov    rax,QWORD PTR [rdi+0x10]
    1629:	mov    rcx,QWORD PTR [rax+0xd0]
    1630:	mov    edx,0x1
    1635:	mov    rsi,rbx
    1638:	call   163d <botlish_fn_6+0x89>
			1639: R_X86_64_PLT32	rt_type_error-0x4
    163d:	jmp    1756 <botlish_fn_6+0x1a2>
    1642:	mov    r13,rdi
    1645:	mov    rsi,rbx
    1648:	call   164d <botlish_fn_6+0x99>
			1649: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    164d:	mov    rcx,rax
    1650:	mov    r14,rax
    1653:	test   rax,rcx
    1656:	je     1756 <botlish_fn_6+0x1a2>
    165c:	mov    rax,r14
    165f:	mov    QWORD PTR [rsp],rax
    1663:	mov    rsi,r14
    1666:	mov    rdi,r13
    1669:	call   166e <botlish_fn_6+0xba>
			166a: R_X86_64_PLT32	rt_list_len-0x4
    166e:	mov    ecx,0x1
    1673:	sar    rax,1
    1676:	cmp    rax,0x1
    167a:	je     16bf <botlish_fn_6+0x10b>
    1680:	mov    rax,QWORD PTR [r12+0x20]
    1685:	mov    rsi,QWORD PTR [rax]
    1688:	mov    QWORD PTR [rsp+0x8],rsi
    168d:	mov    QWORD PTR [rsp+0x10],0x1
    1696:	mov    rdi,r13
    1699:	mov    rax,QWORD PTR [rdi+0x10]
    169d:	mov    r8,QWORD PTR [rax+0x98]
    16a4:	mov    QWORD PTR [rsp+0x18],r8
    16a9:	mov    rdx,r14
    16ac:	call   16b1 <botlish_fn_6+0xfd>
			16ad: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    16b1:	test   rax,rax
    16b4:	je     1756 <botlish_fn_6+0x1a2>
    16ba:	jmp    1783 <botlish_fn_6+0x1cf>
    16bf:	mov    rdx,r14
    16c2:	mov    r15,rcx
    16c5:	mov    rax,QWORD PTR [rdx+0x8]
    16c9:	mov    r14,rdx
    16cc:	test   rax,rax
    16cf:	jne    16f4 <botlish_fn_6+0x140>
    16d5:	mov    rdx,r15
    16d8:	mov    rsi,r14
    16db:	mov    rdi,r13
    16de:	call   16e3 <botlish_fn_6+0x12f>
			16df: R_X86_64_PLT32	rt_list_get-0x4
    16e3:	test   rax,rax
    16e6:	je     1756 <botlish_fn_6+0x1a2>
    16ec:	mov    rsi,rax
    16ef:	jmp    16fe <botlish_fn_6+0x14a>
    16f4:	mov    rdx,r14
    16f7:	mov    rsi,QWORD PTR [rdx+0x10]
    16fb:	mov    rsi,QWORD PTR [rsi]
    16fe:	mov    rdi,r13
    1701:	call   1706 <botlish_fn_6+0x152>
			1702: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    1706:	test   rax,rax
    1709:	je     1756 <botlish_fn_6+0x1a2>
    170f:	cmp    rax,0x6
    1713:	je     1780 <botlish_fn_6+0x1cc>
    1719:	mov    rax,QWORD PTR [r12+0x20]
    171e:	mov    rsi,QWORD PTR [rax]
    1721:	mov    QWORD PTR [rsp+0x8],rsi
    1726:	mov    QWORD PTR [rsp+0x10],0x1
    172f:	mov    rdi,r13
    1732:	mov    rax,QWORD PTR [rdi+0x10]
    1736:	mov    r8,QWORD PTR [rax+0x98]
    173d:	mov    QWORD PTR [rsp+0x18],r8
    1742:	mov    rcx,r15
    1745:	mov    rdx,r14
    1748:	call   174d <botlish_fn_6+0x199>
			1749: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    174d:	test   rax,rax
    1750:	jne    1783 <botlish_fn_6+0x1cf>
    1756:	xor    rax,rax
    1759:	mov    rbx,QWORD PTR [rsp+0x20]
    175e:	mov    r12,QWORD PTR [rsp+0x28]
    1763:	mov    r13,QWORD PTR [rsp+0x30]
    1768:	mov    r14,QWORD PTR [rsp+0x38]
    176d:	mov    r15,QWORD PTR [rsp+0x40]
    1772:	add    rsp,0x50
    1776:	mov    rsp,rbp
    1779:	pop    rbp
    177a:	ret
    177b:	jmp    1783 <botlish_fn_6+0x1cf>
    1780:	mov    rax,rbx
    1783:	mov    rbx,QWORD PTR [rsp+0x20]
    1788:	mov    r12,QWORD PTR [rsp+0x28]
    178d:	mov    r13,QWORD PTR [rsp+0x30]
    1792:	mov    r14,QWORD PTR [rsp+0x38]
    1797:	mov    r15,QWORD PTR [rsp+0x40]
    179c:	add    rsp,0x50
    17a0:	mov    rsp,rbp
    17a3:	pop    rbp
    17a4:	ret

00000000000017a5 <botlish_entry_6: esc_char<generic>>:
    17a5:	push   rbp
    17a6:	mov    rbp,rsp
    17a9:	mov    rdx,QWORD PTR [rdx]
    17ac:	call   17b1 <botlish_entry_6+0xc>
			17ad: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    17b1:	mov    rsp,rbp
    17b4:	pop    rbp
    17b5:	ret
	...

00000000000017b8 <botlish_fn_7: esc_from<generic>>:
    17b8:	push   rbp
    17b9:	mov    rbp,rsp
    17bc:	sub    rsp,0x80
    17c3:	mov    QWORD PTR [rsp+0x50],rbx
    17c8:	mov    QWORD PTR [rsp+0x58],r12
    17cd:	mov    QWORD PTR [rsp+0x60],r13
    17d2:	mov    QWORD PTR [rsp+0x68],r14
    17d7:	mov    QWORD PTR [rsp+0x70],r15
    17dc:	mov    r12,rsi
    17df:	mov    r13,rdi
    17e2:	mov    QWORD PTR [rsp+0x28],0x0
    17eb:	mov    QWORD PTR [rsp+0x30],0x0
    17f4:	mov    QWORD PTR [rsp],rdx
    17f8:	mov    QWORD PTR [rsp+0x8],rcx
    17fd:	mov    QWORD PTR [rsp+0x10],r8
    1802:	mov    r14,r8
    1805:	mov    QWORD PTR [rsp+0x38],rcx
    180a:	xor    eax,eax
    180c:	test   rdx,0x7
    1813:	je     1821 <botlish_fn_7+0x69>
    1819:	mov    rsi,rdx
    181c:	jmp    182d <botlish_fn_7+0x75>
    1821:	movzx  rax,BYTE PTR [rdx]
    1825:	mov    rsi,rdx
    1828:	cmp    al,0x2
    182a:	sete   al
    182d:	test   al,al
    182f:	jne    1852 <botlish_fn_7+0x9a>
    1835:	mov    rdi,r13
    1838:	mov    rax,QWORD PTR [rdi+0x10]
    183c:	mov    rcx,QWORD PTR [rax+0xd8]
    1843:	mov    edx,0x1
    1848:	call   184d <botlish_fn_7+0x95>
			1849: R_X86_64_PLT32	rt_type_error-0x4
    184d:	jmp    1ab1 <botlish_fn_7+0x2f9>
    1852:	mov    rbx,rsi
    1855:	mov    rdi,r13
    1858:	call   185d <botlish_fn_7+0xa5>
			1859: R_X86_64_PLT32	rt_str_len-0x4
    185d:	mov    edx,0x1
    1862:	mov    r15,rdx
    1865:	mov    ecx,0x1
    186a:	mov    rsi,QWORD PTR [rsp+0x38]
    186f:	test   rsi,0x1
    1876:	jne    18a0 <botlish_fn_7+0xe8>
    187c:	xor    ecx,ecx
    187e:	mov    rsi,QWORD PTR [rsp+0x38]
    1883:	test   rsi,0x7
    188a:	jne    18a0 <botlish_fn_7+0xe8>
    1890:	mov    rsi,QWORD PTR [rsp+0x38]
    1895:	movzx  rcx,BYTE PTR [rsi]
    1899:	rex cmp cl,0x1
    189d:	sete   cl
    18a0:	test   cl,cl
    18a2:	jne    18c8 <botlish_fn_7+0x110>
    18a8:	mov    rdi,r13
    18ab:	mov    rax,QWORD PTR [rdi+0x10]
    18af:	mov    rcx,QWORD PTR [rax+0xb8]
    18b6:	xor    rdx,rdx
    18b9:	mov    rsi,QWORD PTR [rsp+0x38]
    18be:	call   18c3 <botlish_fn_7+0x10b>
			18bf: R_X86_64_PLT32	rt_type_error-0x4
    18c3:	jmp    1ab1 <botlish_fn_7+0x2f9>
    18c8:	mov    rsi,QWORD PTR [rsp+0x38]
    18cd:	mov    rcx,rsi
    18d0:	and    rcx,rax
    18d3:	mov    rdx,rax
    18d6:	test   rcx,0x1
    18dd:	jne    1905 <botlish_fn_7+0x14d>
    18e3:	mov    rsi,QWORD PTR [rsp+0x38]
    18e8:	mov    rdi,r13
    18eb:	call   18f0 <botlish_fn_7+0x138>
			18ec: R_X86_64_PLT32	rt_int_cmp-0x4
    18f0:	mov    ecx,0x2
    18f5:	test   rax,rax
    18f8:	cmovge rcx,QWORD PTR [rip+0x228]        # 1b28 <botlish_fn_7+0x370>
    1900:	jmp    191a <botlish_fn_7+0x162>
    1905:	mov    ecx,0x2
    190a:	mov    rsi,QWORD PTR [rsp+0x38]
    190f:	cmp    rsi,rdx
    1912:	cmovge rcx,QWORD PTR [rip+0x20e]        # 1b28 <botlish_fn_7+0x370>
    191a:	cmp    rcx,0x6
    191e:	je     1afc <botlish_fn_7+0x344>
    1924:	mov    QWORD PTR [rsp+0x18],r12
    1929:	mov    QWORD PTR [rsp+0x20],0x3
    1932:	mov    rsi,QWORD PTR [rsp+0x38]
    1937:	test   rsi,0x1
    193e:	je     195b <botlish_fn_7+0x1a3>
    1944:	mov    rsi,QWORD PTR [rsp+0x38]
    1949:	mov    rax,rsi
    194c:	add    rax,0x2
    1950:	seto   cl
    1953:	test   cl,cl
    1955:	je     196d <botlish_fn_7+0x1b5>
    195b:	mov    edx,0x3
    1960:	mov    rsi,QWORD PTR [rsp+0x38]
    1965:	mov    rdi,r13
    1968:	call   196d <botlish_fn_7+0x1b5>
			1969: R_X86_64_PLT32	rt_int_add-0x4
    196d:	mov    QWORD PTR [rsp+0x20],rax
    1972:	mov    QWORD PTR [rsp+0x40],rax
    1977:	mov    rax,QWORD PTR [r12+0x20]
    197c:	mov    rsi,QWORD PTR [rax]
    197f:	mov    QWORD PTR [rsp+0x28],rsi
    1984:	mov    QWORD PTR [rsp+0x48],rsi
    1989:	mov    QWORD PTR [rsp+0x30],0x3
    1992:	mov    rsi,QWORD PTR [rsp+0x38]
    1997:	test   rsi,0x1
    199e:	je     19bb <botlish_fn_7+0x203>
    19a4:	mov    rsi,QWORD PTR [rsp+0x38]
    19a9:	mov    rcx,rsi
    19ac:	add    rcx,0x2
    19b0:	seto   al
    19b3:	test   al,al
    19b5:	je     19d0 <botlish_fn_7+0x218>
    19bb:	mov    edx,0x3
    19c0:	mov    rsi,QWORD PTR [rsp+0x38]
    19c5:	mov    rdi,r13
    19c8:	call   19cd <botlish_fn_7+0x215>
			19c9: R_X86_64_PLT32	rt_int_add-0x4
    19cd:	mov    rcx,rax
    19d0:	mov    QWORD PTR [rsp+0x30],rcx
    19d5:	mov    rdx,QWORD PTR [rsp+0x38]
    19da:	mov    rsi,rbx
    19dd:	mov    rdi,r13
    19e0:	call   19e5 <botlish_fn_7+0x22d>
			19e1: R_X86_64_PLT32	rt_substr-0x4
    19e5:	test   rax,rax
    19e8:	je     1ab1 <botlish_fn_7+0x2f9>
    19ee:	mov    QWORD PTR [rsp+0x8],rax
    19f3:	mov    rdx,rax
    19f6:	mov    rsi,QWORD PTR [rsp+0x48]
    19fb:	mov    rdi,r13
    19fe:	call   1a03 <botlish_fn_7+0x24b>
			19ff: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    1a03:	test   rax,rax
    1a06:	je     1ab1 <botlish_fn_7+0x2f9>
    1a0c:	mov    QWORD PTR [rsp+0x8],rax
    1a11:	xor    ecx,ecx
    1a13:	mov    rsi,r14
    1a16:	test   rsi,0x7
    1a1d:	jne    1a2e <botlish_fn_7+0x276>
    1a23:	movzx  r9,BYTE PTR [rsi]
    1a27:	cmp    r9b,0x2
    1a2b:	sete   cl
    1a2e:	test   cl,cl
    1a30:	jne    1a51 <botlish_fn_7+0x299>
    1a36:	mov    rdi,r13
    1a39:	mov    rax,QWORD PTR [rdi+0x10]
    1a3d:	mov    rcx,QWORD PTR [rax+0xc8]
    1a44:	mov    rdx,r15
    1a47:	call   1a4c <botlish_fn_7+0x294>
			1a48: R_X86_64_PLT32	rt_type_error-0x4
    1a4c:	jmp    1ab1 <botlish_fn_7+0x2f9>
    1a51:	mov    rdx,r15
    1a54:	xor    edi,edi
    1a56:	test   rax,0x7
    1a5c:	je     1a6a <botlish_fn_7+0x2b2>
    1a62:	mov    r8,rax
    1a65:	jmp    1a79 <botlish_fn_7+0x2c1>
    1a6a:	movzx  rcx,BYTE PTR [rax]
    1a6e:	mov    r8,rax
    1a71:	rex cmp cl,0x2
    1a75:	sete   dil
    1a79:	test   dil,dil
    1a7c:	jne    1a9d <botlish_fn_7+0x2e5>
    1a82:	mov    rdi,r13
    1a85:	mov    rax,QWORD PTR [rdi+0x10]
    1a89:	mov    rcx,QWORD PTR [rax+0xc8]
    1a90:	mov    rsi,r8
    1a93:	call   1a98 <botlish_fn_7+0x2e0>
			1a94: R_X86_64_PLT32	rt_type_error-0x4
    1a98:	jmp    1ab1 <botlish_fn_7+0x2f9>
    1a9d:	mov    rdx,r8
    1aa0:	mov    rdi,r13
    1aa3:	call   1aa8 <botlish_fn_7+0x2f0>
			1aa4: R_X86_64_PLT32	rt_str_cat-0x4
    1aa8:	test   rax,rax
    1aab:	jne    1ad9 <botlish_fn_7+0x321>
    1ab1:	xor    rax,rax
    1ab4:	mov    rbx,QWORD PTR [rsp+0x50]
    1ab9:	mov    r12,QWORD PTR [rsp+0x58]
    1abe:	mov    r13,QWORD PTR [rsp+0x60]
    1ac3:	mov    r14,QWORD PTR [rsp+0x68]
    1ac8:	mov    r15,QWORD PTR [rsp+0x70]
    1acd:	add    rsp,0x80
    1ad4:	mov    rsp,rbp
    1ad7:	pop    rbp
    1ad8:	ret
    1ad9:	mov    QWORD PTR [rsp],rbx
    1add:	mov    rcx,QWORD PTR [rsp+0x40]
    1ae2:	mov    QWORD PTR [rsp+0x8],rcx
    1ae7:	mov    QWORD PTR [rsp+0x10],rax
    1aec:	mov    rdx,rbx
    1aef:	mov    r14,rax
    1af2:	mov    QWORD PTR [rsp+0x38],rcx
    1af7:	jmp    180a <botlish_fn_7+0x52>
    1afc:	mov    rax,r14
    1aff:	mov    rbx,QWORD PTR [rsp+0x50]
    1b04:	mov    r12,QWORD PTR [rsp+0x58]
    1b09:	mov    r13,QWORD PTR [rsp+0x60]
    1b0e:	mov    r14,QWORD PTR [rsp+0x68]
    1b13:	mov    r15,QWORD PTR [rsp+0x70]
    1b18:	add    rsp,0x80
    1b1f:	mov    rsp,rbp
    1b22:	pop    rbp
    1b23:	ret
    1b24:	add    BYTE PTR [rax],al
    1b26:	add    BYTE PTR [rax],al
    1b28:	(bad)
    1b29:	add    BYTE PTR [rax],al
    1b2b:	add    BYTE PTR [rax],al
    1b2d:	add    BYTE PTR [rax],al
	...

0000000000001b30 <botlish_entry_7: esc_from<generic>>:
    1b30:	push   rbp
    1b31:	mov    rbp,rsp
    1b34:	mov    r9,QWORD PTR [rdx]
    1b37:	mov    rcx,QWORD PTR [rdx+0x8]
    1b3b:	mov    r8,QWORD PTR [rdx+0x10]
    1b3f:	mov    rdx,r9
    1b42:	call   1b47 <botlish_entry_7+0x17>
			1b43: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
    1b47:	mov    rsp,rbp
    1b4a:	pop    rbp
    1b4b:	ret
    1b4c:	add    BYTE PTR [rax],al
	...

0000000000001b50 <botlish_fn_8: check<int, int, str, str>>:
    1b50:	push   rbp
    1b51:	mov    rbp,rsp
    1b54:	sub    rsp,0x60
    1b58:	mov    QWORD PTR [rsp+0x30],rbx
    1b5d:	mov    QWORD PTR [rsp+0x38],r12
    1b62:	mov    QWORD PTR [rsp+0x40],r13
    1b67:	mov    QWORD PTR [rsp+0x48],r14
    1b6c:	mov    QWORD PTR [rsp+0x50],r15
    1b71:	mov    QWORD PTR [rsp+0x20],0x0
    1b7a:	mov    QWORD PTR [rsp],rsi
    1b7e:	mov    QWORD PTR [rsp+0x8],rdx
    1b83:	mov    QWORD PTR [rsp+0x10],rcx
    1b88:	mov    r12,rcx
    1b8b:	mov    QWORD PTR [rsp+0x18],r8
    1b90:	mov    r14,r8
    1b93:	mov    r13,rsi
    1b96:	mov    r15,rdx
    1b99:	test   r13,0x1
    1ba0:	jne    1bcb <botlish_fn_8+0x7b>
    1ba6:	mov    edx,0x1
    1bab:	mov    rbx,rdi
    1bae:	mov    rsi,r13
    1bb1:	call   1bb6 <botlish_fn_8+0x66>
			1bb2: R_X86_64_PLT32	rt_int_cmp-0x4
    1bb6:	mov    ecx,0x2
    1bbb:	test   rax,rax
    1bbe:	cmovle rcx,QWORD PTR [rip+0x152]        # 1d18 <botlish_fn_8+0x1c8>
    1bc6:	jmp    1bdf <botlish_fn_8+0x8f>
    1bcb:	mov    rbx,rdi
    1bce:	mov    ecx,0x2
    1bd3:	cmp    r13,0x1
    1bd7:	cmovle rcx,QWORD PTR [rip+0x139]        # 1d18 <botlish_fn_8+0x1c8>
    1bdf:	cmp    rcx,0x6
    1be3:	je     1cec <botlish_fn_8+0x19c>
    1be9:	mov    rax,QWORD PTR [rbx+0x10]
    1bed:	mov    rax,QWORD PTR [rax+0xe0]
    1bf4:	mov    rsi,r12
    1bf7:	mov    rdi,rbx
    1bfa:	call   1bff <botlish_fn_8+0xaf>
			1bfb: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    1bff:	test   rax,rax
    1c02:	je     1c43 <botlish_fn_8+0xf3>
    1c08:	cmp    rax,0x6
    1c0c:	je     1c24 <botlish_fn_8+0xd4>
    1c12:	mov    edx,0x1
    1c17:	mov    QWORD PTR [rsp],0x1
    1c1f:	jmp    1c85 <botlish_fn_8+0x135>
    1c24:	mov    rax,QWORD PTR [rbx+0x10]
    1c28:	mov    rax,QWORD PTR [rax+0xe8]
    1c2f:	mov    rsi,r12
    1c32:	mov    rdi,rbx
    1c35:	call   1c3a <botlish_fn_8+0xea>
			1c36: R_X86_64_PLT32	botlish_fn_18-0x4 ; <str>
    1c3a:	test   rax,rax
    1c3d:	jne    1c68 <botlish_fn_8+0x118>
    1c43:	xor    rax,rax
    1c46:	mov    rbx,QWORD PTR [rsp+0x30]
    1c4b:	mov    r12,QWORD PTR [rsp+0x38]
    1c50:	mov    r13,QWORD PTR [rsp+0x40]
    1c55:	mov    r14,QWORD PTR [rsp+0x48]
    1c5a:	mov    r15,QWORD PTR [rsp+0x50]
    1c5f:	add    rsp,0x60
    1c63:	mov    rsp,rbp
    1c66:	pop    rbp
    1c67:	ret
    1c68:	cmp    rax,0x6
    1c6c:	je     1c7c <botlish_fn_8+0x12c>
    1c72:	mov    edx,0x1
    1c77:	jmp    1c81 <botlish_fn_8+0x131>
    1c7c:	mov    edx,0x3
    1c81:	mov    QWORD PTR [rsp],rdx
    1c85:	sar    r13,1
    1c88:	sub    r13,0x1
    1c8c:	shl    r13,1
    1c8f:	or     r13,0x1
    1c93:	mov    QWORD PTR [rsp+0x20],r13
    1c98:	mov    rsi,r15
    1c9b:	mov    r8,rsi
    1c9e:	and    r8,rdx
    1ca1:	test   r8,0x1
    1ca8:	je     1cc3 <botlish_fn_8+0x173>
    1cae:	lea    r11,[rdx-0x1]
    1cb2:	mov    rax,rsi
    1cb5:	add    rax,r11
    1cb8:	seto   cl
    1cbb:	test   cl,cl
    1cbd:	je     1ccb <botlish_fn_8+0x17b>
    1cc3:	mov    rdi,rbx
    1cc6:	call   1ccb <botlish_fn_8+0x17b>
			1cc7: R_X86_64_PLT32	rt_int_add-0x4
    1ccb:	mov    QWORD PTR [rsp],r13
    1ccf:	mov    QWORD PTR [rsp+0x8],rax
    1cd4:	mov    QWORD PTR [rsp+0x10],r12
    1cd9:	mov    r8,r14
    1cdc:	mov    QWORD PTR [rsp+0x18],r8
    1ce1:	mov    rdi,rbx
    1ce4:	mov    r15,rax
    1ce7:	jmp    1b99 <botlish_fn_8+0x49>
    1cec:	mov    rax,r15
    1cef:	mov    rbx,QWORD PTR [rsp+0x30]
    1cf4:	mov    r12,QWORD PTR [rsp+0x38]
    1cf9:	mov    r13,QWORD PTR [rsp+0x40]
    1cfe:	mov    r14,QWORD PTR [rsp+0x48]
    1d03:	mov    r15,QWORD PTR [rsp+0x50]
    1d08:	add    rsp,0x60
    1d0c:	mov    rsp,rbp
    1d0f:	pop    rbp
    1d10:	ret
    1d11:	add    BYTE PTR [rax],al
    1d13:	add    BYTE PTR [rax],al
    1d15:	add    BYTE PTR [rax],al
    1d17:	add    BYTE PTR [rsi],al
    1d19:	add    BYTE PTR [rax],al
    1d1b:	add    BYTE PTR [rax],al
    1d1d:	add    BYTE PTR [rax],al
	...

0000000000001d20 <botlish_entry_8: check<int, int, str, str>>:
    1d20:	push   rbp
    1d21:	mov    rbp,rsp
    1d24:	mov    rsi,QWORD PTR [rdx]
    1d27:	mov    r9,QWORD PTR [rdx+0x8]
    1d2b:	mov    rcx,QWORD PTR [rdx+0x10]
    1d2f:	mov    r8,QWORD PTR [rdx+0x18]
    1d33:	mov    rdx,r9
    1d36:	call   1d3b <botlish_entry_8+0x1b>
			1d37: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
    1d3b:	mov    rsp,rbp
    1d3e:	pop    rbp
    1d3f:	ret

0000000000001d40 <botlish_fn_9: <str>>:
    1d40:	push   rbp
    1d41:	mov    rbp,rsp
    1d44:	sub    rsp,0xe0
    1d4b:	mov    QWORD PTR [rsp+0xb0],rbx
    1d53:	mov    QWORD PTR [rsp+0xb8],r12
    1d5b:	mov    QWORD PTR [rsp+0xc0],r13
    1d63:	mov    QWORD PTR [rsp+0xc8],r14
    1d6b:	mov    QWORD PTR [rsp+0xd0],r15
    1d73:	mov    r15,rdi
    1d76:	mov    QWORD PTR [rsp+0x10],0x0
    1d7f:	mov    QWORD PTR [rsp+0x18],0x0
    1d88:	mov    QWORD PTR [rsp+0x20],0x0
    1d91:	mov    QWORD PTR [rsp],rsi
    1d95:	mov    rbx,rsi
    1d98:	mov    rsi,rbx
    1d9b:	mov    rdi,r15
    1d9e:	call   1da3 <botlish_fn_9+0x63>
			1d9f: R_X86_64_PLT32	rt_str_len-0x4
    1da3:	mov    QWORD PTR [rsp+0xa8],rax
    1dab:	mov    QWORD PTR [rsp+0x8],rax
    1db0:	lea    r8,[rsp+0x28]
    1db5:	mov    QWORD PTR [rsp+0x28],rbx
    1dba:	mov    esi,0xb
    1dbf:	mov    rdx,QWORD PTR [rip+0x0]        # 1dc6 <botlish_fn_9+0x86>
			1dc2: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    1dc6:	mov    ebx,0x1
    1dcb:	mov    rcx,rbx
    1dce:	mov    rdi,r15
    1dd1:	call   1dd6 <botlish_fn_9+0x96>
			1dd2: R_X86_64_PLT32	rt_closure_new-0x4
    1dd6:	mov    r14,rax
    1dd9:	mov    QWORD PTR [rsp],rax
    1ddd:	lea    r8,[rsp+0x30]
    1de2:	mov    rax,QWORD PTR [rsp+0xa8]
    1dea:	mov    QWORD PTR [rsp+0x30],rax
    1def:	mov    rax,r14
    1df2:	mov    QWORD PTR [rsp+0x38],rax
    1df7:	mov    esi,0xd
    1dfc:	mov    rdx,QWORD PTR [rip+0x0]        # 1e03 <botlish_fn_9+0xc3>
			1dff: R_X86_64_GOTPCREL	botlish_entry_13-0x4 ; scan_local<generic>
    1e03:	mov    r13d,0x2
    1e09:	mov    rcx,r13
    1e0c:	mov    rdi,r15
    1e0f:	call   1e14 <botlish_fn_9+0xd4>
			1e10: R_X86_64_PLT32	rt_closure_new-0x4
    1e14:	mov    r12,rax
    1e17:	mov    QWORD PTR [rsp+0x10],r12
    1e1c:	lea    r8,[rsp+0x40]
    1e21:	mov    rax,QWORD PTR [rsp+0xa8]
    1e29:	mov    QWORD PTR [rsp+0x40],rax
    1e2e:	mov    rax,r14
    1e31:	mov    QWORD PTR [rsp+0x48],rax
    1e36:	mov    esi,0xe
    1e3b:	mov    rdx,QWORD PTR [rip+0x0]        # 1e42 <botlish_fn_9+0x102>
			1e3e: R_X86_64_GOTPCREL	botlish_entry_14-0x4 ; scan_label<generic>
    1e42:	mov    rcx,r13
    1e45:	mov    rdi,r15
    1e48:	call   1e4d <botlish_fn_9+0x10d>
			1e49: R_X86_64_PLT32	rt_closure_new-0x4
    1e4d:	mov    QWORD PTR [rsp+0x18],rax
    1e52:	mov    QWORD PTR [rsp+0xa0],rax
    1e5a:	lea    r8,[rsp+0x50]
    1e5f:	mov    rax,QWORD PTR [rsp+0xa8]
    1e67:	mov    QWORD PTR [rsp+0x50],rax
    1e6c:	mov    QWORD PTR [rsp+0x58],r14
    1e71:	mov    esi,0xf
    1e76:	mov    rdx,QWORD PTR [rip+0x0]        # 1e7d <botlish_fn_9+0x13d>
			1e79: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_alpha<generic>
    1e7d:	mov    rcx,r13
    1e80:	mov    rdi,r15
    1e83:	call   1e88 <botlish_fn_9+0x148>
			1e84: R_X86_64_PLT32	rt_closure_new-0x4
    1e88:	mov    QWORD PTR [rsp+0x20],rax
    1e8d:	lea    r8,[rsp+0x60]
    1e92:	mov    QWORD PTR [rsp+0x60],rax
    1e97:	mov    rax,QWORD PTR [rsp+0xa8]
    1e9f:	mov    QWORD PTR [rsp+0x68],rax
    1ea4:	mov    esi,0x10
    1ea9:	mov    rdx,QWORD PTR [rip+0x0]        # 1eb0 <botlish_fn_9+0x170>
			1eac: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; tld_ok<generic>
    1eb0:	mov    rcx,r13
    1eb3:	mov    rdi,r15
    1eb6:	call   1ebb <botlish_fn_9+0x17b>
			1eb7: R_X86_64_PLT32	rt_closure_new-0x4
    1ebb:	mov    QWORD PTR [rsp+0x20],rax
    1ec0:	lea    r8,[rsp+0x70]
    1ec5:	mov    rcx,QWORD PTR [rsp+0xa0]
    1ecd:	mov    QWORD PTR [rsp+0x70],rcx
    1ed2:	mov    rcx,QWORD PTR [rsp+0xa8]
    1eda:	mov    QWORD PTR [rsp+0x78],rcx
    1edf:	mov    QWORD PTR [rsp+0x80],r14
    1ee7:	mov    QWORD PTR [rsp+0x88],rax
    1eef:	mov    esi,0x11
    1ef4:	mov    rdx,QWORD PTR [rip+0x0]        # 1efb <botlish_fn_9+0x1bb>
			1ef7: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; domain_loop<generic>
    1efb:	mov    ecx,0x4
    1f00:	mov    rdi,r15
    1f03:	call   1f08 <botlish_fn_9+0x1c8>
			1f04: R_X86_64_PLT32	rt_closure_new-0x4
    1f08:	mov    QWORD PTR [rsp+0x18],rax
    1f0d:	mov    r13,rax
    1f10:	mov    QWORD PTR [rsp+0x20],0x1
    1f19:	mov    rdx,rbx
    1f1c:	mov    rsi,r12
    1f1f:	mov    rdi,r15
    1f22:	call   1f27 <botlish_fn_9+0x1e7>
			1f23: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_local<generic>
    1f27:	mov    rcx,rax
    1f2a:	mov    r12,rax
    1f2d:	test   rax,rcx
    1f30:	je     2091 <botlish_fn_9+0x351>
    1f36:	mov    rax,r12
    1f39:	mov    QWORD PTR [rsp+0x10],rax
    1f3e:	test   rax,0x1
    1f44:	jne    1f6f <botlish_fn_9+0x22f>
    1f4a:	mov    edx,0x1
    1f4f:	mov    rsi,r12
    1f52:	mov    rdi,r15
    1f55:	call   1f5a <botlish_fn_9+0x21a>
			1f56: R_X86_64_PLT32	rt_int_cmp-0x4
    1f5a:	mov    esi,0x2
    1f5f:	test   rax,rax
    1f62:	cmove  rsi,QWORD PTR [rip+0x206]        # 2170 <botlish_fn_9+0x430>
    1f6a:	jmp    1f80 <botlish_fn_9+0x240>
    1f6f:	mov    esi,0x2
    1f74:	cmp    r12,0x1
    1f78:	cmove  rsi,QWORD PTR [rip+0x1f0]        # 2170 <botlish_fn_9+0x430>
    1f80:	cmp    rsi,0x6
    1f84:	je     2135 <botlish_fn_9+0x3f5>
    1f8a:	mov    rbx,QWORD PTR [rsp+0xa8]
    1f92:	mov    rax,r12
    1f95:	and    rax,rbx
    1f98:	test   rax,0x1
    1f9e:	jne    1fc7 <botlish_fn_9+0x287>
    1fa4:	mov    rdx,rbx
    1fa7:	mov    rsi,r12
    1faa:	mov    rdi,r15
    1fad:	call   1fb2 <botlish_fn_9+0x272>
			1fae: R_X86_64_PLT32	rt_int_cmp-0x4
    1fb2:	mov    ecx,0x2
    1fb7:	test   rax,rax
    1fba:	cmovge rcx,QWORD PTR [rip+0x1ae]        # 2170 <botlish_fn_9+0x430>
    1fc2:	jmp    1fd7 <botlish_fn_9+0x297>
    1fc7:	mov    ecx,0x2
    1fcc:	cmp    r12,rbx
    1fcf:	cmovge rcx,QWORD PTR [rip+0x199]        # 2170 <botlish_fn_9+0x430>
    1fd7:	cmp    rcx,0x6
    1fdb:	je     212b <botlish_fn_9+0x3eb>
    1fe1:	lea    rcx,[rsp+0x90]
    1fe9:	mov    rsi,r14
    1fec:	mov    rdx,r12
    1fef:	mov    rdi,r15
    1ff2:	call   1ff7 <botlish_fn_9+0x2b7>
			1ff3: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    1ff7:	test   rax,rax
    1ffa:	mov    rsi,rax
    1ffd:	je     2091 <botlish_fn_9+0x351>
    2003:	mov    rdx,QWORD PTR [rsp+0x90]
    200b:	mov    rcx,QWORD PTR [rsp+0x98]
    2013:	mov    rdi,r15
    2016:	mov    rax,QWORD PTR [rdi+0x10]
    201a:	mov    r8,QWORD PTR [rax+0x100]
    2021:	call   2026 <botlish_fn_9+0x2e6>
			2022: R_X86_64_PLT32	rt_str_region_eq-0x4
    2026:	cmp    rax,0x6
    202a:	je     203d <botlish_fn_9+0x2fd>
    2030:	mov    ecx,0x2
    2035:	mov    rax,rcx
    2038:	jmp    213a <botlish_fn_9+0x3fa>
    203d:	mov    QWORD PTR [rsp],0x3
    2045:	test   r12,0x1
    204c:	je     2066 <botlish_fn_9+0x326>
    2052:	mov    rdx,r12
    2055:	add    rdx,0x2
    2059:	seto   sil
    205d:	test   sil,sil
    2060:	je     2079 <botlish_fn_9+0x339>
    2066:	mov    edx,0x3
    206b:	mov    rsi,r12
    206e:	mov    rdi,r15
    2071:	call   2076 <botlish_fn_9+0x336>
			2072: R_X86_64_PLT32	rt_int_add-0x4
    2076:	mov    rdx,rax
    2079:	mov    QWORD PTR [rsp],rdx
    207d:	mov    rsi,r13
    2080:	mov    rdi,r15
    2083:	call   2088 <botlish_fn_9+0x348>
			2084: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain_loop<generic>
    2088:	test   rax,rax
    208b:	jne    20c8 <botlish_fn_9+0x388>
    2091:	xor    rax,rax
    2094:	mov    rbx,QWORD PTR [rsp+0xb0]
    209c:	mov    r12,QWORD PTR [rsp+0xb8]
    20a4:	mov    r13,QWORD PTR [rsp+0xc0]
    20ac:	mov    r14,QWORD PTR [rsp+0xc8]
    20b4:	mov    r15,QWORD PTR [rsp+0xd0]
    20bc:	add    rsp,0xe0
    20c3:	mov    rsp,rbp
    20c6:	pop    rbp
    20c7:	ret
    20c8:	mov    rcx,rax
    20cb:	and    rcx,rbx
    20ce:	mov    rsi,rax
    20d1:	mov    QWORD PTR [rsp+0xa8],rbx
    20d9:	test   rcx,0x1
    20e0:	jne    210e <botlish_fn_9+0x3ce>
    20e6:	mov    rdx,QWORD PTR [rsp+0xa8]
    20ee:	mov    rdi,r15
    20f1:	call   20f6 <botlish_fn_9+0x3b6>
			20f2: R_X86_64_PLT32	rt_int_cmp-0x4
    20f6:	mov    ecx,0x2
    20fb:	test   rax,rax
    20fe:	mov    rax,rcx
    2101:	cmove  rax,QWORD PTR [rip+0x67]        # 2170 <botlish_fn_9+0x430>
    2109:	jmp    213a <botlish_fn_9+0x3fa>
    210e:	mov    rdx,QWORD PTR [rsp+0xa8]
    2116:	mov    eax,0x2
    211b:	cmp    rsi,rdx
    211e:	cmove  rax,QWORD PTR [rip+0x4a]        # 2170 <botlish_fn_9+0x430>
    2126:	jmp    213a <botlish_fn_9+0x3fa>
    212b:	mov    eax,0x2
    2130:	jmp    213a <botlish_fn_9+0x3fa>
    2135:	mov    eax,0x2
    213a:	mov    rbx,QWORD PTR [rsp+0xb0]
    2142:	mov    r12,QWORD PTR [rsp+0xb8]
    214a:	mov    r13,QWORD PTR [rsp+0xc0]
    2152:	mov    r14,QWORD PTR [rsp+0xc8]
    215a:	mov    r15,QWORD PTR [rsp+0xd0]
    2162:	add    rsp,0xe0
    2169:	mov    rsp,rbp
    216c:	pop    rbp
    216d:	ret
    216e:	add    BYTE PTR [rax],al
    2170:	(bad)
    2171:	add    BYTE PTR [rax],al
    2173:	add    BYTE PTR [rax],al
    2175:	add    BYTE PTR [rax],al
	...

0000000000002178 <botlish_entry_9: <str>>:
    2178:	push   rbp
    2179:	mov    rbp,rsp
    217c:	mov    rsi,QWORD PTR [rdx]
    217f:	call   2184 <botlish_entry_9+0xc>
			2180: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    2184:	mov    rsp,rbp
    2187:	pop    rbp
    2188:	ret
    2189:	add    BYTE PTR [rax],al
    218b:	add    BYTE PTR [rax],al
    218d:	add    BYTE PTR [rax],al
	...

0000000000002190 <botlish_fn_10: <generic>>:
    2190:	push   rbp
    2191:	mov    rbp,rsp
    2194:	sub    rsp,0xe0
    219b:	mov    QWORD PTR [rsp+0xb0],rbx
    21a3:	mov    QWORD PTR [rsp+0xb8],r12
    21ab:	mov    QWORD PTR [rsp+0xc0],r13
    21b3:	mov    QWORD PTR [rsp+0xc8],r14
    21bb:	mov    QWORD PTR [rsp+0xd0],r15
    21c3:	mov    QWORD PTR [rsp+0x10],0x0
    21cc:	mov    QWORD PTR [rsp+0x18],0x0
    21d5:	mov    QWORD PTR [rsp+0x20],0x0
    21de:	mov    QWORD PTR [rsp],rsi
    21e2:	xor    r8d,r8d
    21e5:	test   rsi,0x7
    21ec:	jne    21fc <botlish_fn_10+0x6c>
    21f2:	movzx  rax,BYTE PTR [rsi]
    21f6:	cmp    al,0x2
    21f8:	sete   r8b
    21fc:	test   r8b,r8b
    21ff:	jne    221f <botlish_fn_10+0x8f>
    2205:	mov    rax,QWORD PTR [rdi+0x10]
    2209:	mov    rcx,QWORD PTR [rax+0xd8]
    2210:	mov    edx,0x1
    2215:	call   221a <botlish_fn_10+0x8a>
			2216: R_X86_64_PLT32	rt_type_error-0x4
    221a:	jmp    250e <botlish_fn_10+0x37e>
    221f:	mov    rbx,rsi
    2222:	mov    r15,rdi
    2225:	call   222a <botlish_fn_10+0x9a>
			2226: R_X86_64_PLT32	rt_str_len-0x4
    222a:	mov    r14,rax
    222d:	mov    QWORD PTR [rsp+0x8],rax
    2232:	lea    r8,[rsp+0x28]
    2237:	mov    QWORD PTR [rsp+0x28],rbx
    223c:	mov    esi,0xb
    2241:	mov    rdx,QWORD PTR [rip+0x0]        # 2248 <botlish_fn_10+0xb8>
			2244: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    2248:	mov    ebx,0x1
    224d:	mov    rcx,rbx
    2250:	mov    rdi,r15
    2253:	call   2258 <botlish_fn_10+0xc8>
			2254: R_X86_64_PLT32	rt_closure_new-0x4
    2258:	mov    r13,rax
    225b:	mov    QWORD PTR [rsp+0xa8],rbx
    2263:	mov    QWORD PTR [rsp],rax
    2267:	lea    r8,[rsp+0x30]
    226c:	mov    rax,r14
    226f:	mov    QWORD PTR [rsp+0x30],rax
    2274:	mov    rax,r13
    2277:	mov    QWORD PTR [rsp+0x38],rax
    227c:	mov    esi,0xd
    2281:	mov    rdx,QWORD PTR [rip+0x0]        # 2288 <botlish_fn_10+0xf8>
			2284: R_X86_64_GOTPCREL	botlish_entry_13-0x4 ; scan_local<generic>
    2288:	mov    r12d,0x2
    228e:	mov    rcx,r12
    2291:	mov    rdi,r15
    2294:	call   2299 <botlish_fn_10+0x109>
			2295: R_X86_64_PLT32	rt_closure_new-0x4
    2299:	mov    rbx,rax
    229c:	mov    QWORD PTR [rsp+0x10],rbx
    22a1:	lea    r8,[rsp+0x40]
    22a6:	mov    rax,r14
    22a9:	mov    QWORD PTR [rsp+0x40],rax
    22ae:	mov    rax,r13
    22b1:	mov    QWORD PTR [rsp+0x48],rax
    22b6:	mov    esi,0xe
    22bb:	mov    rdx,QWORD PTR [rip+0x0]        # 22c2 <botlish_fn_10+0x132>
			22be: R_X86_64_GOTPCREL	botlish_entry_14-0x4 ; scan_label<generic>
    22c2:	mov    rcx,r12
    22c5:	mov    rdi,r15
    22c8:	call   22cd <botlish_fn_10+0x13d>
			22c9: R_X86_64_PLT32	rt_closure_new-0x4
    22cd:	mov    QWORD PTR [rsp+0x18],rax
    22d2:	mov    QWORD PTR [rsp+0xa0],rax
    22da:	lea    r8,[rsp+0x50]
    22df:	mov    rax,r14
    22e2:	mov    QWORD PTR [rsp+0x50],rax
    22e7:	mov    QWORD PTR [rsp+0x58],r13
    22ec:	mov    esi,0xf
    22f1:	mov    rdx,QWORD PTR [rip+0x0]        # 22f8 <botlish_fn_10+0x168>
			22f4: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_alpha<generic>
    22f8:	mov    rcx,r12
    22fb:	mov    rdi,r15
    22fe:	call   2303 <botlish_fn_10+0x173>
			22ff: R_X86_64_PLT32	rt_closure_new-0x4
    2303:	mov    QWORD PTR [rsp+0x20],rax
    2308:	lea    r8,[rsp+0x60]
    230d:	mov    QWORD PTR [rsp+0x60],rax
    2312:	mov    rax,r14
    2315:	mov    QWORD PTR [rsp+0x68],rax
    231a:	mov    esi,0x10
    231f:	mov    rdx,QWORD PTR [rip+0x0]        # 2326 <botlish_fn_10+0x196>
			2322: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; tld_ok<generic>
    2326:	mov    rcx,r12
    2329:	mov    rdi,r15
    232c:	call   2331 <botlish_fn_10+0x1a1>
			232d: R_X86_64_PLT32	rt_closure_new-0x4
    2331:	mov    QWORD PTR [rsp+0x20],rax
    2336:	lea    r8,[rsp+0x70]
    233b:	mov    rcx,QWORD PTR [rsp+0xa0]
    2343:	mov    QWORD PTR [rsp+0x70],rcx
    2348:	mov    rcx,r14
    234b:	mov    QWORD PTR [rsp+0x78],rcx
    2350:	mov    QWORD PTR [rsp+0x80],r13
    2358:	mov    QWORD PTR [rsp+0x88],rax
    2360:	mov    esi,0x11
    2365:	mov    rdx,QWORD PTR [rip+0x0]        # 236c <botlish_fn_10+0x1dc>
			2368: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; domain_loop<generic>
    236c:	mov    ecx,0x4
    2371:	mov    rdi,r15
    2374:	call   2379 <botlish_fn_10+0x1e9>
			2375: R_X86_64_PLT32	rt_closure_new-0x4
    2379:	mov    QWORD PTR [rsp+0x18],rax
    237e:	mov    QWORD PTR [rsp+0xa0],rax
    2386:	mov    QWORD PTR [rsp+0x20],0x1
    238f:	mov    rsi,rbx
    2392:	mov    rdx,QWORD PTR [rsp+0xa8]
    239a:	mov    rdi,r15
    239d:	call   23a2 <botlish_fn_10+0x212>
			239e: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_local<generic>
    23a2:	mov    rcx,rax
    23a5:	mov    r12,rax
    23a8:	test   rax,rcx
    23ab:	je     250e <botlish_fn_10+0x37e>
    23b1:	mov    rax,r12
    23b4:	mov    QWORD PTR [rsp+0x10],rax
    23b9:	test   rax,0x1
    23bf:	jne    23ed <botlish_fn_10+0x25d>
    23c5:	mov    rdx,QWORD PTR [rsp+0xa8]
    23cd:	mov    rsi,r12
    23d0:	mov    rdi,r15
    23d3:	call   23d8 <botlish_fn_10+0x248>
			23d4: R_X86_64_PLT32	rt_int_cmp-0x4
    23d8:	mov    ecx,0x2
    23dd:	test   rax,rax
    23e0:	cmove  rcx,QWORD PTR [rip+0x1f8]        # 25e0 <botlish_fn_10+0x450>
    23e8:	jmp    23fe <botlish_fn_10+0x26e>
    23ed:	mov    ecx,0x2
    23f2:	cmp    r12,0x1
    23f6:	cmove  rcx,QWORD PTR [rip+0x1e2]        # 25e0 <botlish_fn_10+0x450>
    23fe:	cmp    rcx,0x6
    2402:	je     25a3 <botlish_fn_10+0x413>
    2408:	mov    rbx,r14
    240b:	mov    rcx,r12
    240e:	and    rcx,rbx
    2411:	test   rcx,0x1
    2418:	jne    2441 <botlish_fn_10+0x2b1>
    241e:	mov    rdx,rbx
    2421:	mov    rsi,r12
    2424:	mov    rdi,r15
    2427:	call   242c <botlish_fn_10+0x29c>
			2428: R_X86_64_PLT32	rt_int_cmp-0x4
    242c:	mov    ecx,0x2
    2431:	test   rax,rax
    2434:	cmovge rcx,QWORD PTR [rip+0x1a4]        # 25e0 <botlish_fn_10+0x450>
    243c:	jmp    2451 <botlish_fn_10+0x2c1>
    2441:	mov    ecx,0x2
    2446:	cmp    r12,rbx
    2449:	cmovge rcx,QWORD PTR [rip+0x18f]        # 25e0 <botlish_fn_10+0x450>
    2451:	cmp    rcx,0x6
    2455:	je     2599 <botlish_fn_10+0x409>
    245b:	lea    rcx,[rsp+0x90]
    2463:	mov    rsi,r13
    2466:	mov    rdx,r12
    2469:	mov    rdi,r15
    246c:	call   2471 <botlish_fn_10+0x2e1>
			246d: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    2471:	test   rax,rax
    2474:	mov    rsi,rax
    2477:	je     250e <botlish_fn_10+0x37e>
    247d:	mov    rdx,QWORD PTR [rsp+0x90]
    2485:	mov    rcx,QWORD PTR [rsp+0x98]
    248d:	mov    rdi,r15
    2490:	mov    rax,QWORD PTR [rdi+0x10]
    2494:	mov    r8,QWORD PTR [rax+0x100]
    249b:	call   24a0 <botlish_fn_10+0x310>
			249c: R_X86_64_PLT32	rt_str_region_eq-0x4
    24a0:	cmp    rax,0x6
    24a4:	je     24b7 <botlish_fn_10+0x327>
    24aa:	mov    ecx,0x2
    24af:	mov    rax,rcx
    24b2:	jmp    25a8 <botlish_fn_10+0x418>
    24b7:	mov    QWORD PTR [rsp],0x3
    24bf:	test   r12,0x1
    24c6:	je     24de <botlish_fn_10+0x34e>
    24cc:	mov    rdx,r12
    24cf:	add    rdx,0x2
    24d3:	seto   al
    24d6:	test   al,al
    24d8:	je     24f1 <botlish_fn_10+0x361>
    24de:	mov    edx,0x3
    24e3:	mov    rsi,r12
    24e6:	mov    rdi,r15
    24e9:	call   24ee <botlish_fn_10+0x35e>
			24ea: R_X86_64_PLT32	rt_int_add-0x4
    24ee:	mov    rdx,rax
    24f1:	mov    QWORD PTR [rsp],rdx
    24f5:	mov    rsi,QWORD PTR [rsp+0xa0]
    24fd:	mov    rdi,r15
    2500:	call   2505 <botlish_fn_10+0x375>
			2501: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain_loop<generic>
    2505:	test   rax,rax
    2508:	jne    2545 <botlish_fn_10+0x3b5>
    250e:	xor    rax,rax
    2511:	mov    rbx,QWORD PTR [rsp+0xb0]
    2519:	mov    r12,QWORD PTR [rsp+0xb8]
    2521:	mov    r13,QWORD PTR [rsp+0xc0]
    2529:	mov    r14,QWORD PTR [rsp+0xc8]
    2531:	mov    r15,QWORD PTR [rsp+0xd0]
    2539:	add    rsp,0xe0
    2540:	mov    rsp,rbp
    2543:	pop    rbp
    2544:	ret
    2545:	mov    rcx,rax
    2548:	and    rcx,rbx
    254b:	mov    rsi,rax
    254e:	mov    r14,rbx
    2551:	test   rcx,0x1
    2558:	jne    2581 <botlish_fn_10+0x3f1>
    255e:	mov    rdx,r14
    2561:	mov    rdi,r15
    2564:	call   2569 <botlish_fn_10+0x3d9>
			2565: R_X86_64_PLT32	rt_int_cmp-0x4
    2569:	mov    ecx,0x2
    256e:	test   rax,rax
    2571:	mov    rax,rcx
    2574:	cmove  rax,QWORD PTR [rip+0x64]        # 25e0 <botlish_fn_10+0x450>
    257c:	jmp    25a8 <botlish_fn_10+0x418>
    2581:	mov    rdx,r14
    2584:	mov    eax,0x2
    2589:	cmp    rsi,rdx
    258c:	cmove  rax,QWORD PTR [rip+0x4c]        # 25e0 <botlish_fn_10+0x450>
    2594:	jmp    25a8 <botlish_fn_10+0x418>
    2599:	mov    eax,0x2
    259e:	jmp    25a8 <botlish_fn_10+0x418>
    25a3:	mov    eax,0x2
    25a8:	mov    rbx,QWORD PTR [rsp+0xb0]
    25b0:	mov    r12,QWORD PTR [rsp+0xb8]
    25b8:	mov    r13,QWORD PTR [rsp+0xc0]
    25c0:	mov    r14,QWORD PTR [rsp+0xc8]
    25c8:	mov    r15,QWORD PTR [rsp+0xd0]
    25d0:	add    rsp,0xe0
    25d7:	mov    rsp,rbp
    25da:	pop    rbp
    25db:	ret
    25dc:	add    BYTE PTR [rax],al
    25de:	add    BYTE PTR [rax],al
    25e0:	(bad)
    25e1:	add    BYTE PTR [rax],al
    25e3:	add    BYTE PTR [rax],al
    25e5:	add    BYTE PTR [rax],al
	...

00000000000025e8 <botlish_entry_10: <generic>>:
    25e8:	push   rbp
    25e9:	mov    rbp,rsp
    25ec:	mov    rsi,QWORD PTR [rdx]
    25ef:	call   25f4 <botlish_entry_10+0xc>
			25f0: R_X86_64_PLT32	botlish_fn_10-0x4 ; <generic>
    25f4:	mov    rsp,rbp
    25f7:	pop    rbp
    25f8:	ret

00000000000025f9 <botlish_fn_11: char_at<generic>>:
    25f9:	push   rbp
    25fa:	mov    rbp,rsp
    25fd:	sub    rsp,0x40
    2601:	mov    QWORD PTR [rsp+0x20],rbx
    2606:	mov    QWORD PTR [rsp+0x28],r12
    260b:	mov    QWORD PTR [rsp+0x30],r13
    2610:	mov    QWORD PTR [rsp],rdx
    2614:	mov    rax,QWORD PTR [rsi+0x20]
    2618:	mov    rsi,QWORD PTR [rax]
    261b:	mov    QWORD PTR [rsp+0x8],rsi
    2620:	mov    r13,rsi
    2623:	mov    QWORD PTR [rsp+0x10],0x3
    262c:	mov    r10d,0x1
    2632:	test   rdx,0x1
    2639:	je     2647 <botlish_fn_11+0x4e>
    263f:	mov    rbx,rdx
    2642:	jmp    266c <botlish_fn_11+0x73>
    2647:	xor    r10d,r10d
    264a:	test   rdx,0x7
    2651:	je     265f <botlish_fn_11+0x66>
    2657:	mov    rbx,rdx
    265a:	jmp    266c <botlish_fn_11+0x73>
    265f:	movzx  rax,BYTE PTR [rdx]
    2663:	mov    rbx,rdx
    2666:	cmp    al,0x1
    2668:	sete   r10b
    266c:	test   r10b,r10b
    266f:	jne    2690 <botlish_fn_11+0x97>
    2675:	mov    rax,QWORD PTR [rdi+0x10]
    2679:	mov    rcx,QWORD PTR [rax+0x108]
    2680:	xor    rdx,rdx
    2683:	mov    rsi,rbx
    2686:	call   268b <botlish_fn_11+0x92>
			2687: R_X86_64_PLT32	rt_type_error-0x4
    268b:	jmp    2742 <botlish_fn_11+0x149>
    2690:	mov    rsi,rbx
    2693:	mov    r12,rdi
    2696:	test   rsi,0x1
    269d:	je     26b8 <botlish_fn_11+0xbf>
    26a3:	mov    rsi,rbx
    26a6:	mov    rcx,rsi
    26a9:	add    rcx,0x2
    26ad:	seto   al
    26b0:	test   al,al
    26b2:	je     26cb <botlish_fn_11+0xd2>
    26b8:	mov    edx,0x3
    26bd:	mov    rsi,rbx
    26c0:	mov    rdi,r12
    26c3:	call   26c8 <botlish_fn_11+0xcf>
			26c4: R_X86_64_PLT32	rt_int_add-0x4
    26c8:	mov    rcx,rax
    26cb:	mov    QWORD PTR [rsp+0x10],rcx
    26d0:	mov    eax,0x1
    26d5:	mov    rsi,rbx
    26d8:	test   rsi,0x1
    26df:	jne    2705 <botlish_fn_11+0x10c>
    26e5:	xor    eax,eax
    26e7:	mov    rsi,rbx
    26ea:	test   rsi,0x7
    26f1:	jne    2705 <botlish_fn_11+0x10c>
    26f7:	mov    rsi,rbx
    26fa:	movzx  rdx,BYTE PTR [rsi]
    26fe:	rex cmp dl,0x1
    2702:	sete   al
    2705:	test   al,al
    2707:	jne    272b <botlish_fn_11+0x132>
    270d:	mov    rdi,r12
    2710:	mov    rsi,QWORD PTR [rdi+0x10]
    2714:	mov    rcx,QWORD PTR [rsi+0x110]
    271b:	xor    rdx,rdx
    271e:	mov    rsi,rbx
    2721:	call   2726 <botlish_fn_11+0x12d>
			2722: R_X86_64_PLT32	rt_type_error-0x4
    2726:	jmp    2742 <botlish_fn_11+0x149>
    272b:	mov    rdx,rbx
    272e:	mov    rsi,r13
    2731:	mov    rdi,r12
    2734:	call   2739 <botlish_fn_11+0x140>
			2735: R_X86_64_PLT32	rt_substr-0x4
    2739:	test   rax,rax
    273c:	jne    275d <botlish_fn_11+0x164>
    2742:	xor    rax,rax
    2745:	mov    rbx,QWORD PTR [rsp+0x20]
    274a:	mov    r12,QWORD PTR [rsp+0x28]
    274f:	mov    r13,QWORD PTR [rsp+0x30]
    2754:	add    rsp,0x40
    2758:	mov    rsp,rbp
    275b:	pop    rbp
    275c:	ret
    275d:	mov    rbx,QWORD PTR [rsp+0x20]
    2762:	mov    r12,QWORD PTR [rsp+0x28]
    2767:	mov    r13,QWORD PTR [rsp+0x30]
    276c:	add    rsp,0x40
    2770:	mov    rsp,rbp
    2773:	pop    rbp
    2774:	ret

0000000000002775 <botlish_entry_11: char_at<generic>>:
    2775:	push   rbp
    2776:	mov    rbp,rsp
    2779:	mov    rdx,QWORD PTR [rdx]
    277c:	call   2781 <botlish_entry_11+0xc>
			277d: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2781:	mov    rsp,rbp
    2784:	pop    rbp
    2785:	ret

0000000000002786 <botlish_fn_12: char_at<generic>>:
    2786:	push   rbp
    2787:	mov    rbp,rsp
    278a:	sub    rsp,0x40
    278e:	mov    QWORD PTR [rsp+0x20],rbx
    2793:	mov    QWORD PTR [rsp+0x28],r12
    2798:	mov    QWORD PTR [rsp+0x30],r13
    279d:	mov    QWORD PTR [rsp+0x38],r14
    27a2:	mov    r13,rcx
    27a5:	mov    QWORD PTR [rsp],rdx
    27a9:	mov    rax,QWORD PTR [rsi+0x20]
    27ad:	mov    rax,QWORD PTR [rax]
    27b0:	mov    QWORD PTR [rsp+0x8],rax
    27b5:	mov    r14,rax
    27b8:	mov    QWORD PTR [rsp+0x10],0x3
    27c1:	mov    r11d,0x1
    27c7:	test   rdx,0x1
    27ce:	je     27dc <botlish_fn_12+0x56>
    27d4:	mov    r12,rdx
    27d7:	jmp    2801 <botlish_fn_12+0x7b>
    27dc:	xor    r11d,r11d
    27df:	test   rdx,0x7
    27e6:	je     27f4 <botlish_fn_12+0x6e>
    27ec:	mov    r12,rdx
    27ef:	jmp    2801 <botlish_fn_12+0x7b>
    27f4:	movzx  rax,BYTE PTR [rdx]
    27f8:	mov    r12,rdx
    27fb:	cmp    al,0x1
    27fd:	sete   r11b
    2801:	test   r11b,r11b
    2804:	jne    2825 <botlish_fn_12+0x9f>
    280a:	mov    rax,QWORD PTR [rdi+0x10]
    280e:	mov    rcx,QWORD PTR [rax+0x108]
    2815:	xor    rdx,rdx
    2818:	mov    rsi,r12
    281b:	call   2820 <botlish_fn_12+0x9a>
			281c: R_X86_64_PLT32	rt_type_error-0x4
    2820:	jmp    28dd <botlish_fn_12+0x157>
    2825:	mov    rbx,rdi
    2828:	mov    rsi,r12
    282b:	test   rsi,0x1
    2832:	jne    2840 <botlish_fn_12+0xba>
    2838:	mov    r12,rsi
    283b:	jmp    2855 <botlish_fn_12+0xcf>
    2840:	mov    rax,rsi
    2843:	add    rax,0x2
    2847:	mov    r12,rsi
    284a:	seto   cl
    284d:	test   cl,cl
    284f:	je     2865 <botlish_fn_12+0xdf>
    2855:	mov    edx,0x3
    285a:	mov    rsi,r12
    285d:	mov    rdi,rbx
    2860:	call   2865 <botlish_fn_12+0xdf>
			2861: R_X86_64_PLT32	rt_int_add-0x4
    2865:	mov    ecx,0x1
    286a:	mov    rsi,r12
    286d:	test   rsi,0x1
    2874:	jne    289a <botlish_fn_12+0x114>
    287a:	xor    ecx,ecx
    287c:	mov    rsi,r12
    287f:	test   rsi,0x7
    2886:	jne    289a <botlish_fn_12+0x114>
    288c:	mov    rsi,r12
    288f:	movzx  rdx,BYTE PTR [rsi]
    2893:	rex cmp dl,0x1
    2897:	sete   cl
    289a:	test   cl,cl
    289c:	jne    28c0 <botlish_fn_12+0x13a>
    28a2:	mov    rdi,rbx
    28a5:	mov    rsi,QWORD PTR [rdi+0x10]
    28a9:	mov    rcx,QWORD PTR [rsi+0x110]
    28b0:	xor    rdx,rdx
    28b3:	mov    rsi,r12
    28b6:	call   28bb <botlish_fn_12+0x135>
			28b7: R_X86_64_PLT32	rt_type_error-0x4
    28bb:	jmp    28dd <botlish_fn_12+0x157>
    28c0:	mov    rdi,rbx
    28c3:	mov    rbx,rax
    28c6:	mov    rcx,rbx
    28c9:	mov    rdx,r12
    28cc:	mov    rsi,r14
    28cf:	call   28d4 <botlish_fn_12+0x14e>
			28d0: R_X86_64_PLT32	rt_str_region_check-0x4
    28d4:	test   rax,rax
    28d7:	jne    28fd <botlish_fn_12+0x177>
    28dd:	xor    rax,rax
    28e0:	mov    rbx,QWORD PTR [rsp+0x20]
    28e5:	mov    r12,QWORD PTR [rsp+0x28]
    28ea:	mov    r13,QWORD PTR [rsp+0x30]
    28ef:	mov    r14,QWORD PTR [rsp+0x38]
    28f4:	add    rsp,0x40
    28f8:	mov    rsp,rbp
    28fb:	pop    rbp
    28fc:	ret
    28fd:	mov    rcx,r13
    2900:	mov    rsi,r12
    2903:	mov    QWORD PTR [rcx],rsi
    2906:	mov    QWORD PTR [rcx+0x8],rbx
    290a:	mov    rax,r14
    290d:	mov    rbx,QWORD PTR [rsp+0x20]
    2912:	mov    r12,QWORD PTR [rsp+0x28]
    2917:	mov    r13,QWORD PTR [rsp+0x30]
    291c:	mov    r14,QWORD PTR [rsp+0x38]
    2921:	add    rsp,0x40
    2925:	mov    rsp,rbp
    2928:	pop    rbp
    2929:	ret

000000000000292a <botlish_entry_12: char_at<generic>>:
    292a:	push   rbp
    292b:	mov    rbp,rsp
    292e:	ud2

0000000000002930 <botlish_fn_13: scan_local<generic>>:
    2930:	push   rbp
    2931:	mov    rbp,rsp
    2934:	sub    rsp,0x70
    2938:	mov    QWORD PTR [rsp+0x40],rbx
    293d:	mov    QWORD PTR [rsp+0x48],r12
    2942:	mov    QWORD PTR [rsp+0x50],r13
    2947:	mov    QWORD PTR [rsp+0x58],r14
    294c:	mov    QWORD PTR [rsp+0x60],r15
    2951:	mov    rcx,rdi
    2954:	mov    QWORD PTR [rsp+0x10],0x0
    295d:	mov    QWORD PTR [rsp],rdx
    2961:	mov    r12,rsi
    2964:	mov    rsi,rdx
    2967:	mov    rax,QWORD PTR [r12+0x20]
    296c:	mov    rdx,QWORD PTR [rax]
    296f:	mov    r10d,0x1
    2975:	test   rsi,0x1
    297c:	jne    299e <botlish_fn_13+0x6e>
    2982:	xor    r10d,r10d
    2985:	test   rsi,0x7
    298c:	jne    299e <botlish_fn_13+0x6e>
    2992:	movzx  rdi,BYTE PTR [rsi]
    2996:	cmp    dil,0x1
    299a:	sete   r10b
    299e:	test   r10b,r10b
    29a1:	jne    29c2 <botlish_fn_13+0x92>
    29a7:	mov    rdi,rcx
    29aa:	mov    r10,QWORD PTR [rdi+0x10]
    29ae:	mov    rcx,QWORD PTR [r10+0xb8]
    29b5:	xor    rdx,rdx
    29b8:	call   29bd <botlish_fn_13+0x8d>
			29b9: R_X86_64_PLT32	rt_type_error-0x4
    29bd:	jmp    2a78 <botlish_fn_13+0x148>
    29c2:	mov    r11,rsi
    29c5:	and    r11,rdx
    29c8:	mov    r13,rsi
    29cb:	test   r11,0x1
    29d2:	jne    29fb <botlish_fn_13+0xcb>
    29d8:	mov    rbx,rcx
    29db:	mov    rsi,r13
    29de:	mov    rdi,rbx
    29e1:	call   29e6 <botlish_fn_13+0xb6>
			29e2: R_X86_64_PLT32	rt_int_cmp-0x4
    29e6:	mov    ecx,0x2
    29eb:	test   rax,rax
    29ee:	cmovge rcx,QWORD PTR [rip+0x242]        # 2c38 <botlish_fn_13+0x308>
    29f6:	jmp    2a11 <botlish_fn_13+0xe1>
    29fb:	mov    rbx,rcx
    29fe:	mov    ecx,0x2
    2a03:	mov    rsi,r13
    2a06:	cmp    rsi,rdx
    2a09:	cmovge rcx,QWORD PTR [rip+0x227]        # 2c38 <botlish_fn_13+0x308>
    2a11:	mov    eax,0x6
    2a16:	mov    QWORD PTR [rsp+0x28],rax
    2a1b:	cmp    rcx,0x6
    2a1f:	je     2c0c <botlish_fn_13+0x2dc>
    2a25:	mov    rax,QWORD PTR [r12+0x20]
    2a2a:	mov    rsi,QWORD PTR [rax+0x8]
    2a2e:	mov    QWORD PTR [rsp+0x8],rsi
    2a33:	lea    rcx,[rsp+0x18]
    2a38:	mov    rdx,r13
    2a3b:	mov    rdi,rbx
    2a3e:	call   2a43 <botlish_fn_13+0x113>
			2a3f: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    2a43:	mov    r8,rax
    2a46:	mov    r14,rax
    2a49:	test   rax,r8
    2a4c:	je     2a78 <botlish_fn_13+0x148>
    2a52:	mov    rdx,QWORD PTR [rsp+0x18]
    2a57:	mov    r15,rdx
    2a5a:	mov    rcx,QWORD PTR [rsp+0x20]
    2a5f:	mov    QWORD PTR [rsp+0x30],rcx
    2a64:	mov    rsi,r14
    2a67:	mov    rdi,rbx
    2a6a:	call   2a6f <botlish_fn_13+0x13f>
			2a6b: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    2a6f:	test   rax,rax
    2a72:	jne    2a9d <botlish_fn_13+0x16d>
    2a78:	xor    rax,rax
    2a7b:	mov    rbx,QWORD PTR [rsp+0x40]
    2a80:	mov    r12,QWORD PTR [rsp+0x48]
    2a85:	mov    r13,QWORD PTR [rsp+0x50]
    2a8a:	mov    r14,QWORD PTR [rsp+0x58]
    2a8f:	mov    r15,QWORD PTR [rsp+0x60]
    2a94:	add    rsp,0x70
    2a98:	mov    rsp,rbp
    2a9b:	pop    rbp
    2a9c:	ret
    2a9d:	cmp    rax,0x6
    2aa1:	je     2b92 <botlish_fn_13+0x262>
    2aa7:	mov    rax,QWORD PTR [rbx+0x10]
    2aab:	mov    r8,QWORD PTR [rax+0x118]
    2ab2:	mov    rcx,QWORD PTR [rsp+0x30]
    2ab7:	mov    rdx,r15
    2aba:	mov    rsi,r14
    2abd:	mov    rdi,rbx
    2ac0:	call   2ac5 <botlish_fn_13+0x195>
			2ac1: R_X86_64_PLT32	rt_str_region_eq-0x4
    2ac5:	cmp    rax,0x6
    2ac9:	je     2b88 <botlish_fn_13+0x258>
    2acf:	mov    rax,QWORD PTR [rbx+0x10]
    2ad3:	mov    r8,QWORD PTR [rax+0x120]
    2ada:	mov    rcx,QWORD PTR [rsp+0x30]
    2adf:	mov    rdx,r15
    2ae2:	mov    rsi,r14
    2ae5:	mov    rdi,rbx
    2ae8:	call   2aed <botlish_fn_13+0x1bd>
			2ae9: R_X86_64_PLT32	rt_str_region_eq-0x4
    2aed:	cmp    rax,0x6
    2af1:	je     2b7e <botlish_fn_13+0x24e>
    2af7:	mov    rax,QWORD PTR [rbx+0x10]
    2afb:	mov    r8,QWORD PTR [rax+0xc0]
    2b02:	mov    rcx,QWORD PTR [rsp+0x30]
    2b07:	mov    rdx,r15
    2b0a:	mov    rsi,r14
    2b0d:	mov    rdi,rbx
    2b10:	call   2b15 <botlish_fn_13+0x1e5>
			2b11: R_X86_64_PLT32	rt_str_region_eq-0x4
    2b15:	cmp    rax,0x6
    2b19:	je     2b74 <botlish_fn_13+0x244>
    2b1f:	mov    rax,QWORD PTR [rbx+0x10]
    2b23:	mov    r8,QWORD PTR [rax+0x108]
    2b2a:	mov    rcx,QWORD PTR [rsp+0x30]
    2b2f:	mov    rdx,r15
    2b32:	mov    rsi,r14
    2b35:	mov    rdi,rbx
    2b38:	call   2b3d <botlish_fn_13+0x20d>
			2b39: R_X86_64_PLT32	rt_str_region_eq-0x4
    2b3d:	cmp    rax,0x6
    2b41:	je     2b6a <botlish_fn_13+0x23a>
    2b47:	mov    rax,QWORD PTR [rbx+0x10]
    2b4b:	mov    r8,QWORD PTR [rax+0x128]
    2b52:	mov    rcx,QWORD PTR [rsp+0x30]
    2b57:	mov    rdx,r15
    2b5a:	mov    rsi,r14
    2b5d:	mov    rdi,rbx
    2b60:	call   2b65 <botlish_fn_13+0x235>
			2b61: R_X86_64_PLT32	rt_str_region_eq-0x4
    2b65:	jmp    2b97 <botlish_fn_13+0x267>
    2b6a:	mov    rax,QWORD PTR [rsp+0x28]
    2b6f:	jmp    2b97 <botlish_fn_13+0x267>
    2b74:	mov    rax,QWORD PTR [rsp+0x28]
    2b79:	jmp    2b97 <botlish_fn_13+0x267>
    2b7e:	mov    rax,QWORD PTR [rsp+0x28]
    2b83:	jmp    2b97 <botlish_fn_13+0x267>
    2b88:	mov    rax,QWORD PTR [rsp+0x28]
    2b8d:	jmp    2b97 <botlish_fn_13+0x267>
    2b92:	mov    rax,QWORD PTR [rsp+0x28]
    2b97:	cmp    rax,0x6
    2b9b:	je     2ba9 <botlish_fn_13+0x279>
    2ba1:	mov    rax,r13
    2ba4:	jmp    2c0f <botlish_fn_13+0x2df>
    2ba9:	mov    QWORD PTR [rsp+0x8],r12
    2bae:	mov    QWORD PTR [rsp+0x10],0x3
    2bb7:	mov    rsi,r13
    2bba:	test   rsi,0x1
    2bc1:	je     2be7 <botlish_fn_13+0x2b7>
    2bc7:	mov    rsi,r13
    2bca:	mov    rax,rsi
    2bcd:	add    rax,0x2
    2bd1:	seto   cl
    2bd4:	test   cl,cl
    2bd6:	jne    2be7 <botlish_fn_13+0x2b7>
    2bdc:	mov    rsi,rax
    2bdf:	mov    r13,rax
    2be2:	jmp    2bfd <botlish_fn_13+0x2cd>
    2be7:	mov    edx,0x3
    2bec:	mov    rsi,r13
    2bef:	mov    rdi,rbx
    2bf2:	call   2bf7 <botlish_fn_13+0x2c7>
			2bf3: R_X86_64_PLT32	rt_int_add-0x4
    2bf7:	mov    rsi,rax
    2bfa:	mov    r13,rax
    2bfd:	mov    QWORD PTR [rsp],rsi
    2c01:	mov    rcx,rbx
    2c04:	mov    rsi,r13
    2c07:	jmp    2967 <botlish_fn_13+0x37>
    2c0c:	mov    rax,r13
    2c0f:	mov    rbx,QWORD PTR [rsp+0x40]
    2c14:	mov    r12,QWORD PTR [rsp+0x48]
    2c19:	mov    r13,QWORD PTR [rsp+0x50]
    2c1e:	mov    r14,QWORD PTR [rsp+0x58]
    2c23:	mov    r15,QWORD PTR [rsp+0x60]
    2c28:	add    rsp,0x70
    2c2c:	mov    rsp,rbp
    2c2f:	pop    rbp
    2c30:	ret
    2c31:	add    BYTE PTR [rax],al
    2c33:	add    BYTE PTR [rax],al
    2c35:	add    BYTE PTR [rax],al
    2c37:	add    BYTE PTR [rsi],al
    2c39:	add    BYTE PTR [rax],al
    2c3b:	add    BYTE PTR [rax],al
    2c3d:	add    BYTE PTR [rax],al
	...

0000000000002c40 <botlish_entry_13: scan_local<generic>>:
    2c40:	push   rbp
    2c41:	mov    rbp,rsp
    2c44:	mov    rdx,QWORD PTR [rdx]
    2c47:	call   2c4c <botlish_entry_13+0xc>
			2c48: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_local<generic>
    2c4c:	mov    rsp,rbp
    2c4f:	pop    rbp
    2c50:	ret
    2c51:	add    BYTE PTR [rax],al
    2c53:	add    BYTE PTR [rax],al
    2c55:	add    BYTE PTR [rax],al
	...

0000000000002c58 <botlish_fn_14: scan_label<generic>>:
    2c58:	push   rbp
    2c59:	mov    rbp,rsp
    2c5c:	sub    rsp,0x70
    2c60:	mov    QWORD PTR [rsp+0x40],rbx
    2c65:	mov    QWORD PTR [rsp+0x48],r12
    2c6a:	mov    QWORD PTR [rsp+0x50],r13
    2c6f:	mov    QWORD PTR [rsp+0x58],r14
    2c74:	mov    QWORD PTR [rsp+0x60],r15
    2c79:	mov    QWORD PTR [rsp+0x10],0x0
    2c82:	mov    QWORD PTR [rsp],rdx
    2c86:	mov    r12,rsi
    2c89:	mov    rsi,rdx
    2c8c:	mov    rax,QWORD PTR [r12+0x20]
    2c91:	mov    rdx,QWORD PTR [rax]
    2c94:	mov    r10d,0x1
    2c9a:	test   rsi,0x1
    2ca1:	jne    2cc1 <botlish_fn_14+0x69>
    2ca7:	xor    r10d,r10d
    2caa:	test   rsi,0x7
    2cb1:	jne    2cc1 <botlish_fn_14+0x69>
    2cb7:	movzx  rax,BYTE PTR [rsi]
    2cbb:	cmp    al,0x1
    2cbd:	sete   r10b
    2cc1:	test   r10b,r10b
    2cc4:	jne    2ce2 <botlish_fn_14+0x8a>
    2cca:	mov    rax,QWORD PTR [rdi+0x10]
    2cce:	mov    rcx,QWORD PTR [rax+0xb8]
    2cd5:	xor    rdx,rdx
    2cd8:	call   2cdd <botlish_fn_14+0x85>
			2cd9: R_X86_64_PLT32	rt_type_error-0x4
    2cdd:	jmp    2d91 <botlish_fn_14+0x139>
    2ce2:	mov    rax,rsi
    2ce5:	and    rax,rdx
    2ce8:	mov    r13,rsi
    2ceb:	test   rax,0x1
    2cf1:	jne    2d17 <botlish_fn_14+0xbf>
    2cf7:	mov    rbx,rdi
    2cfa:	mov    rsi,r13
    2cfd:	call   2d02 <botlish_fn_14+0xaa>
			2cfe: R_X86_64_PLT32	rt_int_cmp-0x4
    2d02:	mov    ecx,0x2
    2d07:	test   rax,rax
    2d0a:	cmovge rcx,QWORD PTR [rip+0x176]        # 2e88 <botlish_fn_14+0x230>
    2d12:	jmp    2d2d <botlish_fn_14+0xd5>
    2d17:	mov    rbx,rdi
    2d1a:	mov    ecx,0x2
    2d1f:	mov    rsi,r13
    2d22:	cmp    rsi,rdx
    2d25:	cmovge rcx,QWORD PTR [rip+0x15b]        # 2e88 <botlish_fn_14+0x230>
    2d2d:	mov    eax,0x6
    2d32:	mov    QWORD PTR [rsp+0x28],rax
    2d37:	cmp    rcx,0x6
    2d3b:	je     2e5d <botlish_fn_14+0x205>
    2d41:	mov    rsi,QWORD PTR [r12+0x20]
    2d46:	mov    rsi,QWORD PTR [rsi+0x8]
    2d4a:	mov    QWORD PTR [rsp+0x8],rsi
    2d4f:	lea    rcx,[rsp+0x18]
    2d54:	mov    rdx,r13
    2d57:	mov    rdi,rbx
    2d5a:	call   2d5f <botlish_fn_14+0x107>
			2d5b: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    2d5f:	test   rax,rax
    2d62:	mov    r14,rax
    2d65:	je     2d91 <botlish_fn_14+0x139>
    2d6b:	mov    rdx,QWORD PTR [rsp+0x18]
    2d70:	mov    r15,rdx
    2d73:	mov    rcx,QWORD PTR [rsp+0x20]
    2d78:	mov    QWORD PTR [rsp+0x30],rcx
    2d7d:	mov    rsi,r14
    2d80:	mov    rdi,rbx
    2d83:	call   2d88 <botlish_fn_14+0x130>
			2d84: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    2d88:	test   rax,rax
    2d8b:	jne    2db6 <botlish_fn_14+0x15e>
    2d91:	xor    rax,rax
    2d94:	mov    rbx,QWORD PTR [rsp+0x40]
    2d99:	mov    r12,QWORD PTR [rsp+0x48]
    2d9e:	mov    r13,QWORD PTR [rsp+0x50]
    2da3:	mov    r14,QWORD PTR [rsp+0x58]
    2da8:	mov    r15,QWORD PTR [rsp+0x60]
    2dad:	add    rsp,0x70
    2db1:	mov    rsp,rbp
    2db4:	pop    rbp
    2db5:	ret
    2db6:	cmp    rax,0x6
    2dba:	je     2de3 <botlish_fn_14+0x18b>
    2dc0:	mov    rax,QWORD PTR [rbx+0x10]
    2dc4:	mov    r8,QWORD PTR [rax+0x128]
    2dcb:	mov    rcx,QWORD PTR [rsp+0x30]
    2dd0:	mov    rdx,r15
    2dd3:	mov    rsi,r14
    2dd6:	mov    rdi,rbx
    2dd9:	call   2dde <botlish_fn_14+0x186>
			2dda: R_X86_64_PLT32	rt_str_region_eq-0x4
    2dde:	jmp    2de8 <botlish_fn_14+0x190>
    2de3:	mov    rax,QWORD PTR [rsp+0x28]
    2de8:	cmp    rax,0x6
    2dec:	je     2dfa <botlish_fn_14+0x1a2>
    2df2:	mov    rax,r13
    2df5:	jmp    2e60 <botlish_fn_14+0x208>
    2dfa:	mov    QWORD PTR [rsp+0x8],r12
    2dff:	mov    QWORD PTR [rsp+0x10],0x3
    2e08:	mov    rsi,r13
    2e0b:	test   rsi,0x1
    2e12:	je     2e38 <botlish_fn_14+0x1e0>
    2e18:	mov    rsi,r13
    2e1b:	mov    rax,rsi
    2e1e:	add    rax,0x2
    2e22:	seto   cl
    2e25:	test   cl,cl
    2e27:	jne    2e38 <botlish_fn_14+0x1e0>
    2e2d:	mov    rsi,rax
    2e30:	mov    r13,rax
    2e33:	jmp    2e4e <botlish_fn_14+0x1f6>
    2e38:	mov    edx,0x3
    2e3d:	mov    rsi,r13
    2e40:	mov    rdi,rbx
    2e43:	call   2e48 <botlish_fn_14+0x1f0>
			2e44: R_X86_64_PLT32	rt_int_add-0x4
    2e48:	mov    rsi,rax
    2e4b:	mov    r13,rax
    2e4e:	mov    QWORD PTR [rsp],rsi
    2e52:	mov    rsi,r13
    2e55:	mov    rdi,rbx
    2e58:	jmp    2c8c <botlish_fn_14+0x34>
    2e5d:	mov    rax,r13
    2e60:	mov    rbx,QWORD PTR [rsp+0x40]
    2e65:	mov    r12,QWORD PTR [rsp+0x48]
    2e6a:	mov    r13,QWORD PTR [rsp+0x50]
    2e6f:	mov    r14,QWORD PTR [rsp+0x58]
    2e74:	mov    r15,QWORD PTR [rsp+0x60]
    2e79:	add    rsp,0x70
    2e7d:	mov    rsp,rbp
    2e80:	pop    rbp
    2e81:	ret
    2e82:	add    BYTE PTR [rax],al
    2e84:	add    BYTE PTR [rax],al
    2e86:	add    BYTE PTR [rax],al
    2e88:	(bad)
    2e89:	add    BYTE PTR [rax],al
    2e8b:	add    BYTE PTR [rax],al
    2e8d:	add    BYTE PTR [rax],al
	...

0000000000002e90 <botlish_entry_14: scan_label<generic>>:
    2e90:	push   rbp
    2e91:	mov    rbp,rsp
    2e94:	mov    rdx,QWORD PTR [rdx]
    2e97:	call   2e9c <botlish_entry_14+0xc>
			2e98: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_label<generic>
    2e9c:	mov    rsp,rbp
    2e9f:	pop    rbp
    2ea0:	ret
    2ea1:	add    BYTE PTR [rax],al
    2ea3:	add    BYTE PTR [rax],al
    2ea5:	add    BYTE PTR [rax],al
	...

0000000000002ea8 <botlish_fn_15: scan_alpha<generic>>:
    2ea8:	push   rbp
    2ea9:	mov    rbp,rsp
    2eac:	sub    rsp,0x50
    2eb0:	mov    QWORD PTR [rsp+0x30],rbx
    2eb5:	mov    QWORD PTR [rsp+0x38],r12
    2eba:	mov    QWORD PTR [rsp+0x40],r13
    2ebf:	mov    r12,rdi
    2ec2:	mov    QWORD PTR [rsp+0x10],0x0
    2ecb:	mov    QWORD PTR [rsp],rdx
    2ecf:	mov    rbx,rsi
    2ed2:	mov    rsi,rdx
    2ed5:	mov    rax,QWORD PTR [rbx+0x20]
    2ed9:	mov    rdx,QWORD PTR [rax]
    2edc:	mov    r10d,0x1
    2ee2:	test   rsi,0x1
    2ee9:	jne    2f09 <botlish_fn_15+0x61>
    2eef:	xor    r10d,r10d
    2ef2:	test   rsi,0x7
    2ef9:	jne    2f09 <botlish_fn_15+0x61>
    2eff:	movzx  rax,BYTE PTR [rsi]
    2f03:	cmp    al,0x1
    2f05:	sete   r10b
    2f09:	test   r10b,r10b
    2f0c:	jne    2f2d <botlish_fn_15+0x85>
    2f12:	mov    rdi,r12
    2f15:	mov    rax,QWORD PTR [rdi+0x10]
    2f19:	mov    rcx,QWORD PTR [rax+0xb8]
    2f20:	xor    rdx,rdx
    2f23:	call   2f28 <botlish_fn_15+0x80>
			2f24: R_X86_64_PLT32	rt_type_error-0x4
    2f28:	jmp    2fc3 <botlish_fn_15+0x11b>
    2f2d:	mov    rax,rsi
    2f30:	and    rax,rdx
    2f33:	mov    r13,rsi
    2f36:	test   rax,0x1
    2f3c:	jne    2f62 <botlish_fn_15+0xba>
    2f42:	mov    rsi,r13
    2f45:	mov    rdi,r12
    2f48:	call   2f4d <botlish_fn_15+0xa5>
			2f49: R_X86_64_PLT32	rt_int_cmp-0x4
    2f4d:	mov    ecx,0x2
    2f52:	test   rax,rax
    2f55:	cmovge rcx,QWORD PTR [rip+0x113]        # 3070 <botlish_fn_15+0x1c8>
    2f5d:	jmp    2f75 <botlish_fn_15+0xcd>
    2f62:	mov    ecx,0x2
    2f67:	mov    rsi,r13
    2f6a:	cmp    rsi,rdx
    2f6d:	cmovge rcx,QWORD PTR [rip+0xfb]        # 3070 <botlish_fn_15+0x1c8>
    2f75:	cmp    rcx,0x6
    2f79:	je     3050 <botlish_fn_15+0x1a8>
    2f7f:	mov    rax,QWORD PTR [rbx+0x20]
    2f83:	mov    rsi,QWORD PTR [rax+0x8]
    2f87:	mov    QWORD PTR [rsp+0x8],rsi
    2f8c:	lea    rcx,[rsp+0x18]
    2f91:	mov    rdx,r13
    2f94:	mov    rdi,r12
    2f97:	call   2f9c <botlish_fn_15+0xf4>
			2f98: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    2f9c:	test   rax,rax
    2f9f:	mov    rsi,rax
    2fa2:	je     2fc3 <botlish_fn_15+0x11b>
    2fa8:	mov    rdx,QWORD PTR [rsp+0x18]
    2fad:	mov    rcx,QWORD PTR [rsp+0x20]
    2fb2:	mov    rdi,r12
    2fb5:	call   2fba <botlish_fn_15+0x112>
			2fb6: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    2fba:	test   rax,rax
    2fbd:	jne    2fde <botlish_fn_15+0x136>
    2fc3:	xor    rax,rax
    2fc6:	mov    rbx,QWORD PTR [rsp+0x30]
    2fcb:	mov    r12,QWORD PTR [rsp+0x38]
    2fd0:	mov    r13,QWORD PTR [rsp+0x40]
    2fd5:	add    rsp,0x50
    2fd9:	mov    rsp,rbp
    2fdc:	pop    rbp
    2fdd:	ret
    2fde:	cmp    rax,0x6
    2fe2:	je     2ff0 <botlish_fn_15+0x148>
    2fe8:	mov    rax,r13
    2feb:	jmp    3053 <botlish_fn_15+0x1ab>
    2ff0:	mov    QWORD PTR [rsp+0x8],rbx
    2ff5:	mov    QWORD PTR [rsp+0x10],0x3
    2ffe:	mov    rsi,r13
    3001:	test   rsi,0x1
    3008:	je     302e <botlish_fn_15+0x186>
    300e:	mov    rsi,r13
    3011:	mov    rcx,rsi
    3014:	add    rcx,0x2
    3018:	seto   al
    301b:	test   al,al
    301d:	jne    302e <botlish_fn_15+0x186>
    3023:	mov    rsi,rcx
    3026:	mov    r13,rcx
    3029:	jmp    3044 <botlish_fn_15+0x19c>
    302e:	mov    edx,0x3
    3033:	mov    rsi,r13
    3036:	mov    rdi,r12
    3039:	call   303e <botlish_fn_15+0x196>
			303a: R_X86_64_PLT32	rt_int_add-0x4
    303e:	mov    rsi,rax
    3041:	mov    r13,rax
    3044:	mov    QWORD PTR [rsp],rsi
    3048:	mov    rsi,r13
    304b:	jmp    2ed5 <botlish_fn_15+0x2d>
    3050:	mov    rax,r13
    3053:	mov    rbx,QWORD PTR [rsp+0x30]
    3058:	mov    r12,QWORD PTR [rsp+0x38]
    305d:	mov    r13,QWORD PTR [rsp+0x40]
    3062:	add    rsp,0x50
    3066:	mov    rsp,rbp
    3069:	pop    rbp
    306a:	ret
    306b:	add    BYTE PTR [rax],al
    306d:	add    BYTE PTR [rax],al
    306f:	add    BYTE PTR [rsi],al
    3071:	add    BYTE PTR [rax],al
    3073:	add    BYTE PTR [rax],al
    3075:	add    BYTE PTR [rax],al
	...

0000000000003078 <botlish_entry_15: scan_alpha<generic>>:
    3078:	push   rbp
    3079:	mov    rbp,rsp
    307c:	mov    rdx,QWORD PTR [rdx]
    307f:	call   3084 <botlish_entry_15+0xc>
			3080: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_alpha<generic>
    3084:	mov    rsp,rbp
    3087:	pop    rbp
    3088:	ret
    3089:	add    BYTE PTR [rax],al
    308b:	add    BYTE PTR [rax],al
    308d:	add    BYTE PTR [rax],al
	...

0000000000003090 <botlish_fn_16: tld_ok<generic>>:
    3090:	push   rbp
    3091:	mov    rbp,rsp
    3094:	sub    rsp,0x30
    3098:	mov    QWORD PTR [rsp+0x10],rbx
    309d:	mov    QWORD PTR [rsp+0x18],r12
    30a2:	mov    QWORD PTR [rsp+0x20],r13
    30a7:	mov    QWORD PTR [rsp+0x28],r14
    30ac:	mov    r12,rdi
    30af:	mov    QWORD PTR [rsp],rdx
    30b3:	mov    r9,rdx
    30b6:	mov    rax,QWORD PTR [rsi+0x20]
    30ba:	mov    r14,rsi
    30bd:	mov    rsi,QWORD PTR [rax]
    30c0:	mov    QWORD PTR [rsp+0x8],rsi
    30c5:	mov    rbx,r9
    30c8:	mov    rdx,rbx
    30cb:	mov    rdi,r12
    30ce:	call   30d3 <botlish_fn_16+0x43>
			30cf: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_alpha<generic>
    30d3:	mov    rsi,rax
    30d6:	mov    r13,rax
    30d9:	test   rax,rsi
    30dc:	je     31b4 <botlish_fn_16+0x124>
    30e2:	mov    rax,r13
    30e5:	mov    QWORD PTR [rsp+0x8],rax
    30ea:	mov    rsi,r14
    30ed:	mov    rax,QWORD PTR [rsi+0x20]
    30f1:	mov    rdx,QWORD PTR [rax+0x8]
    30f5:	mov    rax,r13
    30f8:	and    rax,rdx
    30fb:	test   rax,0x1
    3101:	jne    312a <botlish_fn_16+0x9a>
    3107:	mov    rsi,r13
    310a:	mov    rdi,r12
    310d:	call   3112 <botlish_fn_16+0x82>
			310e: R_X86_64_PLT32	rt_int_cmp-0x4
    3112:	mov    ecx,0x2
    3117:	test   rax,rax
    311a:	cmove  rcx,QWORD PTR [rip+0x166]        # 3288 <botlish_fn_16+0x1f8>
    3122:	mov    rax,r13
    3125:	jmp    313d <botlish_fn_16+0xad>
    312a:	mov    ecx,0x2
    312f:	mov    rax,r13
    3132:	cmp    rax,rdx
    3135:	cmove  rcx,QWORD PTR [rip+0x14b]        # 3288 <botlish_fn_16+0x1f8>
    313d:	cmp    rcx,0x6
    3141:	je     3154 <botlish_fn_16+0xc4>
    3147:	mov    ecx,0x2
    314c:	mov    rax,rcx
    314f:	jmp    3264 <botlish_fn_16+0x1d4>
    3154:	mov    ecx,0x1
    3159:	test   rbx,0x1
    3160:	je     316e <botlish_fn_16+0xde>
    3166:	mov    r9,rbx
    3169:	jmp    3193 <botlish_fn_16+0x103>
    316e:	xor    ecx,ecx
    3170:	test   rbx,0x7
    3177:	je     3185 <botlish_fn_16+0xf5>
    317d:	mov    r9,rbx
    3180:	jmp    3193 <botlish_fn_16+0x103>
    3185:	movzx  rdx,BYTE PTR [rbx]
    3189:	mov    r9,rbx
    318c:	rex cmp dl,0x1
    3190:	sete   cl
    3193:	test   cl,cl
    3195:	jne    31d4 <botlish_fn_16+0x144>
    319b:	mov    rdi,r12
    319e:	mov    rsi,QWORD PTR [rdi+0x10]
    31a2:	mov    rcx,QWORD PTR [rsi+0x128]
    31a9:	xor    rdx,rdx
    31ac:	mov    rsi,r9
    31af:	call   31b4 <botlish_fn_16+0x124>
			31b0: R_X86_64_PLT32	rt_type_error-0x4
    31b4:	xor    rax,rax
    31b7:	mov    rbx,QWORD PTR [rsp+0x10]
    31bc:	mov    r12,QWORD PTR [rsp+0x18]
    31c1:	mov    r13,QWORD PTR [rsp+0x20]
    31c6:	mov    r14,QWORD PTR [rsp+0x28]
    31cb:	add    rsp,0x30
    31cf:	mov    rsp,rbp
    31d2:	pop    rbp
    31d3:	ret
    31d4:	mov    rbx,r9
    31d7:	mov    r8,rax
    31da:	and    r8,rbx
    31dd:	test   r8,0x1
    31e4:	jne    31f5 <botlish_fn_16+0x165>
    31ea:	mov    rdx,r9
    31ed:	mov    rsi,rax
    31f0:	jmp    3216 <botlish_fn_16+0x186>
    31f5:	mov    rbx,r9
    31f8:	mov    r10,rax
    31fb:	sub    r10,rbx
    31fe:	mov    r13,rax
    3201:	seto   al
    3204:	lea    rsi,[r10+0x1]
    3208:	test   al,al
    320a:	je     3221 <botlish_fn_16+0x191>
    3210:	mov    rdx,r9
    3213:	mov    rsi,r13
    3216:	mov    rdi,r12
    3219:	call   321e <botlish_fn_16+0x18e>
			321a: R_X86_64_PLT32	rt_int_sub-0x4
    321e:	mov    rsi,rax
    3221:	test   rsi,0x1
    3228:	jne    3253 <botlish_fn_16+0x1c3>
    322e:	mov    edx,0x5
    3233:	mov    rdi,r12
    3236:	call   323b <botlish_fn_16+0x1ab>
			3237: R_X86_64_PLT32	rt_int_cmp-0x4
    323b:	mov    ecx,0x2
    3240:	test   rax,rax
    3243:	mov    rax,rcx
    3246:	cmovge rax,QWORD PTR [rip+0x3a]        # 3288 <botlish_fn_16+0x1f8>
    324e:	jmp    3264 <botlish_fn_16+0x1d4>
    3253:	mov    eax,0x2
    3258:	cmp    rsi,0x5
    325c:	cmovge rax,QWORD PTR [rip+0x24]        # 3288 <botlish_fn_16+0x1f8>
    3264:	mov    rbx,QWORD PTR [rsp+0x10]
    3269:	mov    r12,QWORD PTR [rsp+0x18]
    326e:	mov    r13,QWORD PTR [rsp+0x20]
    3273:	mov    r14,QWORD PTR [rsp+0x28]
    3278:	add    rsp,0x30
    327c:	mov    rsp,rbp
    327f:	pop    rbp
    3280:	ret
    3281:	add    BYTE PTR [rax],al
    3283:	add    BYTE PTR [rax],al
    3285:	add    BYTE PTR [rax],al
    3287:	add    BYTE PTR [rsi],al
    3289:	add    BYTE PTR [rax],al
    328b:	add    BYTE PTR [rax],al
    328d:	add    BYTE PTR [rax],al
	...

0000000000003290 <botlish_entry_16: tld_ok<generic>>:
    3290:	push   rbp
    3291:	mov    rbp,rsp
    3294:	mov    rdx,QWORD PTR [rdx]
    3297:	call   329c <botlish_entry_16+0xc>
			3298: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld_ok<generic>
    329c:	mov    rsp,rbp
    329f:	pop    rbp
    32a0:	ret
    32a1:	add    BYTE PTR [rax],al
    32a3:	add    BYTE PTR [rax],al
    32a5:	add    BYTE PTR [rax],al
	...

00000000000032a8 <botlish_fn_17: domain_loop<generic>>:
    32a8:	push   rbp
    32a9:	mov    rbp,rsp
    32ac:	sub    rsp,0x50
    32b0:	mov    QWORD PTR [rsp+0x20],rbx
    32b5:	mov    QWORD PTR [rsp+0x28],r12
    32ba:	mov    QWORD PTR [rsp+0x30],r13
    32bf:	mov    QWORD PTR [rsp+0x38],r14
    32c4:	mov    QWORD PTR [rsp+0x40],r15
    32c9:	mov    QWORD PTR [rsp],rdx
    32cd:	mov    r15,rdx
    32d0:	lea    r13,[rsp+0x10]
    32d5:	mov    rbx,rsi
    32d8:	mov    rax,QWORD PTR [rbx+0x20]
    32dc:	mov    rsi,QWORD PTR [rax]
    32df:	mov    QWORD PTR [rsp+0x8],rsi
    32e4:	mov    r12,rdi
    32e7:	mov    rdx,r15
    32ea:	call   32ef <botlish_fn_17+0x47>
			32eb: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_label<generic>
    32ef:	mov    r10,rax
    32f2:	mov    r14,rax
    32f5:	test   rax,r10
    32f8:	je     346e <botlish_fn_17+0x1c6>
    32fe:	mov    rax,r14
    3301:	mov    QWORD PTR [rsp],rax
    3305:	mov    rdx,r15
    3308:	and    rax,rdx
    330b:	test   rax,0x1
    3311:	jne    3333 <botlish_fn_17+0x8b>
    3317:	mov    rdx,r15
    331a:	mov    rsi,r14
    331d:	mov    rdi,r12
    3320:	call   3325 <botlish_fn_17+0x7d>
			3321: R_X86_64_PLT32	rt_value_eq-0x4
    3325:	test   rax,rax
    3328:	je     346e <botlish_fn_17+0x1c6>
    332e:	jmp    3346 <botlish_fn_17+0x9e>
    3333:	mov    eax,0x2
    3338:	mov    rdx,r15
    333b:	cmp    r14,rdx
    333e:	cmove  rax,QWORD PTR [rip+0x1aa]        # 34f0 <botlish_fn_17+0x248>
    3346:	cmp    rax,0x6
    334a:	je     34c5 <botlish_fn_17+0x21d>
    3350:	mov    rdx,QWORD PTR [rbx+0x20]
    3354:	mov    rdx,QWORD PTR [rdx+0x8]
    3358:	mov    rsi,r14
    335b:	and    rsi,rdx
    335e:	test   rsi,0x1
    3365:	jne    338b <botlish_fn_17+0xe3>
    336b:	mov    rsi,r14
    336e:	mov    rdi,r12
    3371:	call   3376 <botlish_fn_17+0xce>
			3372: R_X86_64_PLT32	rt_int_cmp-0x4
    3376:	mov    ecx,0x2
    337b:	test   rax,rax
    337e:	cmovge rcx,QWORD PTR [rip+0x16a]        # 34f0 <botlish_fn_17+0x248>
    3386:	jmp    339b <botlish_fn_17+0xf3>
    338b:	mov    ecx,0x2
    3390:	cmp    r14,rdx
    3393:	cmovge rcx,QWORD PTR [rip+0x155]        # 34f0 <botlish_fn_17+0x248>
    339b:	cmp    rcx,0x6
    339f:	je     34b9 <botlish_fn_17+0x211>
    33a5:	mov    r10,QWORD PTR [rbx+0x20]
    33a9:	mov    rsi,QWORD PTR [r10+0x10]
    33ad:	mov    QWORD PTR [rsp+0x8],rsi
    33b2:	mov    rcx,r13
    33b5:	mov    rdx,r14
    33b8:	mov    rdi,r12
    33bb:	call   33c0 <botlish_fn_17+0x118>
			33bc: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    33c0:	test   rax,rax
    33c3:	mov    rsi,rax
    33c6:	je     346e <botlish_fn_17+0x1c6>
    33cc:	mov    rdx,QWORD PTR [rsp+0x10]
    33d1:	mov    rcx,QWORD PTR [rsp+0x18]
    33d6:	mov    rax,QWORD PTR [r12+0x10]
    33db:	mov    r8,QWORD PTR [rax+0x118]
    33e2:	mov    rdi,r12
    33e5:	call   33ea <botlish_fn_17+0x142>
			33e6: R_X86_64_PLT32	rt_str_region_eq-0x4
    33ea:	cmp    rax,0x6
    33ee:	je     3400 <botlish_fn_17+0x158>
    33f4:	mov    rax,0xffffffffffffffff
    33fb:	jmp    34cc <botlish_fn_17+0x224>
    3400:	mov    QWORD PTR [rsp+0x8],0x3
    3409:	test   r14,0x1
    3410:	je     3433 <botlish_fn_17+0x18b>
    3416:	mov    rdx,r14
    3419:	add    rdx,0x2
    341d:	mov    r15,rdx
    3420:	seto   al
    3423:	test   al,al
    3425:	jne    3433 <botlish_fn_17+0x18b>
    342b:	mov    rdx,r15
    342e:	jmp    3449 <botlish_fn_17+0x1a1>
    3433:	mov    edx,0x3
    3438:	mov    rsi,r14
    343b:	mov    rdi,r12
    343e:	call   3443 <botlish_fn_17+0x19b>
			343f: R_X86_64_PLT32	rt_int_add-0x4
    3443:	mov    rdx,rax
    3446:	mov    r15,rax
    3449:	mov    QWORD PTR [rsp],rdx
    344d:	mov    rax,QWORD PTR [rbx+0x20]
    3451:	mov    rsi,QWORD PTR [rax+0x18]
    3455:	mov    QWORD PTR [rsp+0x8],rsi
    345a:	mov    rdx,r15
    345d:	mov    rdi,r12
    3460:	call   3465 <botlish_fn_17+0x1bd>
			3461: R_X86_64_PLT32	botlish_fn_16-0x4 ; tld_ok<generic>
    3465:	test   rax,rax
    3468:	jne    3493 <botlish_fn_17+0x1eb>
    346e:	xor    rax,rax
    3471:	mov    rbx,QWORD PTR [rsp+0x20]
    3476:	mov    r12,QWORD PTR [rsp+0x28]
    347b:	mov    r13,QWORD PTR [rsp+0x30]
    3480:	mov    r14,QWORD PTR [rsp+0x38]
    3485:	mov    r15,QWORD PTR [rsp+0x40]
    348a:	add    rsp,0x50
    348e:	mov    rsp,rbp
    3491:	pop    rbp
    3492:	ret
    3493:	cmp    rax,0x6
    3497:	je     34ac <botlish_fn_17+0x204>
    349d:	mov    rdx,r15
    34a0:	mov    QWORD PTR [rsp],rdx
    34a4:	mov    rdi,r12
    34a7:	jmp    32d8 <botlish_fn_17+0x30>
    34ac:	mov    rax,QWORD PTR [rbx+0x20]
    34b0:	mov    rax,QWORD PTR [rax+0x8]
    34b4:	jmp    34cc <botlish_fn_17+0x224>
    34b9:	mov    rax,0xffffffffffffffff
    34c0:	jmp    34cc <botlish_fn_17+0x224>
    34c5:	mov    rax,0xffffffffffffffff
    34cc:	mov    rbx,QWORD PTR [rsp+0x20]
    34d1:	mov    r12,QWORD PTR [rsp+0x28]
    34d6:	mov    r13,QWORD PTR [rsp+0x30]
    34db:	mov    r14,QWORD PTR [rsp+0x38]
    34e0:	mov    r15,QWORD PTR [rsp+0x40]
    34e5:	add    rsp,0x50
    34e9:	mov    rsp,rbp
    34ec:	pop    rbp
    34ed:	ret
    34ee:	add    BYTE PTR [rax],al
    34f0:	(bad)
    34f1:	add    BYTE PTR [rax],al
    34f3:	add    BYTE PTR [rax],al
    34f5:	add    BYTE PTR [rax],al
	...

00000000000034f8 <botlish_entry_17: domain_loop<generic>>:
    34f8:	push   rbp
    34f9:	mov    rbp,rsp
    34fc:	mov    rdx,QWORD PTR [rdx]
    34ff:	call   3504 <botlish_entry_17+0xc>
			3500: R_X86_64_PLT32	botlish_fn_17-0x4 ; domain_loop<generic>
    3504:	mov    rsp,rbp
    3507:	pop    rbp
    3508:	ret
    3509:	add    BYTE PTR [rax],al
    350b:	add    BYTE PTR [rax],al
    350d:	add    BYTE PTR [rax],al
	...

0000000000003510 <botlish_fn_18: <str>>:
    3510:	push   rbp
    3511:	mov    rbp,rsp
    3514:	sub    rsp,0xe0
    351b:	mov    QWORD PTR [rsp+0xb0],rbx
    3523:	mov    QWORD PTR [rsp+0xb8],r12
    352b:	mov    QWORD PTR [rsp+0xc0],r13
    3533:	mov    QWORD PTR [rsp+0xc8],r14
    353b:	mov    QWORD PTR [rsp+0xd0],r15
    3543:	mov    r15,rdi
    3546:	mov    QWORD PTR [rsp+0x10],0x0
    354f:	mov    QWORD PTR [rsp+0x18],0x0
    3558:	mov    QWORD PTR [rsp+0x20],0x0
    3561:	mov    QWORD PTR [rsp],rsi
    3565:	mov    rbx,rsi
    3568:	mov    rsi,rbx
    356b:	mov    rdi,r15
    356e:	call   3573 <botlish_fn_18+0x63>
			356f: R_X86_64_PLT32	rt_str_len-0x4
    3573:	mov    QWORD PTR [rsp+0xa8],rax
    357b:	mov    QWORD PTR [rsp+0x8],rax
    3580:	lea    r8,[rsp+0x28]
    3585:	mov    QWORD PTR [rsp+0x28],rbx
    358a:	mov    esi,0x14
    358f:	mov    rdx,QWORD PTR [rip+0x0]        # 3596 <botlish_fn_18+0x86>
			3592: R_X86_64_GOTPCREL	botlish_entry_20-0x4 ; char_at<generic>
    3596:	mov    ebx,0x1
    359b:	mov    rcx,rbx
    359e:	mov    rdi,r15
    35a1:	call   35a6 <botlish_fn_18+0x96>
			35a2: R_X86_64_PLT32	rt_closure_new-0x4
    35a6:	mov    r14,rax
    35a9:	mov    QWORD PTR [rsp],rax
    35ad:	lea    r8,[rsp+0x30]
    35b2:	mov    rax,QWORD PTR [rsp+0xa8]
    35ba:	mov    QWORD PTR [rsp+0x30],rax
    35bf:	mov    rax,r14
    35c2:	mov    QWORD PTR [rsp+0x38],rax
    35c7:	mov    esi,0x16
    35cc:	mov    rdx,QWORD PTR [rip+0x0]        # 35d3 <botlish_fn_18+0xc3>
			35cf: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; scan_local<generic>
    35d3:	mov    r13d,0x2
    35d9:	mov    rcx,r13
    35dc:	mov    rdi,r15
    35df:	call   35e4 <botlish_fn_18+0xd4>
			35e0: R_X86_64_PLT32	rt_closure_new-0x4
    35e4:	mov    r12,rax
    35e7:	mov    QWORD PTR [rsp+0x10],r12
    35ec:	lea    r8,[rsp+0x40]
    35f1:	mov    rax,QWORD PTR [rsp+0xa8]
    35f9:	mov    QWORD PTR [rsp+0x40],rax
    35fe:	mov    rax,r14
    3601:	mov    QWORD PTR [rsp+0x48],rax
    3606:	mov    esi,0x17
    360b:	mov    rdx,QWORD PTR [rip+0x0]        # 3612 <botlish_fn_18+0x102>
			360e: R_X86_64_GOTPCREL	botlish_entry_23-0x4 ; scan_label<generic>
    3612:	mov    rcx,r13
    3615:	mov    rdi,r15
    3618:	call   361d <botlish_fn_18+0x10d>
			3619: R_X86_64_PLT32	rt_closure_new-0x4
    361d:	mov    QWORD PTR [rsp+0x18],rax
    3622:	mov    QWORD PTR [rsp+0xa0],rax
    362a:	lea    r8,[rsp+0x50]
    362f:	mov    rax,QWORD PTR [rsp+0xa8]
    3637:	mov    QWORD PTR [rsp+0x50],rax
    363c:	mov    QWORD PTR [rsp+0x58],r14
    3641:	mov    esi,0x18
    3646:	mov    rdx,QWORD PTR [rip+0x0]        # 364d <botlish_fn_18+0x13d>
			3649: R_X86_64_GOTPCREL	botlish_entry_24-0x4 ; scan_alpha<generic>
    364d:	mov    rcx,r13
    3650:	mov    rdi,r15
    3653:	call   3658 <botlish_fn_18+0x148>
			3654: R_X86_64_PLT32	rt_closure_new-0x4
    3658:	mov    QWORD PTR [rsp+0x20],rax
    365d:	lea    r8,[rsp+0x60]
    3662:	mov    QWORD PTR [rsp+0x60],rax
    3667:	mov    rax,QWORD PTR [rsp+0xa8]
    366f:	mov    QWORD PTR [rsp+0x68],rax
    3674:	mov    esi,0x19
    3679:	mov    rdx,QWORD PTR [rip+0x0]        # 3680 <botlish_fn_18+0x170>
			367c: R_X86_64_GOTPCREL	botlish_entry_25-0x4 ; tld_ok<generic>
    3680:	mov    rcx,r13
    3683:	mov    rdi,r15
    3686:	call   368b <botlish_fn_18+0x17b>
			3687: R_X86_64_PLT32	rt_closure_new-0x4
    368b:	mov    QWORD PTR [rsp+0x20],rax
    3690:	lea    r8,[rsp+0x70]
    3695:	mov    rcx,QWORD PTR [rsp+0xa0]
    369d:	mov    QWORD PTR [rsp+0x70],rcx
    36a2:	mov    rcx,QWORD PTR [rsp+0xa8]
    36aa:	mov    QWORD PTR [rsp+0x78],rcx
    36af:	mov    QWORD PTR [rsp+0x80],r14
    36b7:	mov    QWORD PTR [rsp+0x88],rax
    36bf:	mov    esi,0x1a
    36c4:	mov    rdx,QWORD PTR [rip+0x0]        # 36cb <botlish_fn_18+0x1bb>
			36c7: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; domain_loop<generic>
    36cb:	mov    ecx,0x4
    36d0:	mov    rdi,r15
    36d3:	call   36d8 <botlish_fn_18+0x1c8>
			36d4: R_X86_64_PLT32	rt_closure_new-0x4
    36d8:	mov    QWORD PTR [rsp+0x18],rax
    36dd:	mov    r13,rax
    36e0:	mov    QWORD PTR [rsp+0x20],0x1
    36e9:	mov    rdx,rbx
    36ec:	mov    rsi,r12
    36ef:	mov    rdi,r15
    36f2:	call   36f7 <botlish_fn_18+0x1e7>
			36f3: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_local<generic>
    36f7:	mov    rcx,rax
    36fa:	mov    r12,rax
    36fd:	test   rax,rcx
    3700:	je     3861 <botlish_fn_18+0x351>
    3706:	mov    rax,r12
    3709:	mov    QWORD PTR [rsp+0x10],rax
    370e:	test   rax,0x1
    3714:	jne    373f <botlish_fn_18+0x22f>
    371a:	mov    edx,0x1
    371f:	mov    rsi,r12
    3722:	mov    rdi,r15
    3725:	call   372a <botlish_fn_18+0x21a>
			3726: R_X86_64_PLT32	rt_int_cmp-0x4
    372a:	mov    esi,0x2
    372f:	test   rax,rax
    3732:	cmove  rsi,QWORD PTR [rip+0x206]        # 3940 <botlish_fn_18+0x430>
    373a:	jmp    3750 <botlish_fn_18+0x240>
    373f:	mov    esi,0x2
    3744:	cmp    r12,0x1
    3748:	cmove  rsi,QWORD PTR [rip+0x1f0]        # 3940 <botlish_fn_18+0x430>
    3750:	cmp    rsi,0x6
    3754:	je     3905 <botlish_fn_18+0x3f5>
    375a:	mov    rbx,QWORD PTR [rsp+0xa8]
    3762:	mov    rax,r12
    3765:	and    rax,rbx
    3768:	test   rax,0x1
    376e:	jne    3797 <botlish_fn_18+0x287>
    3774:	mov    rdx,rbx
    3777:	mov    rsi,r12
    377a:	mov    rdi,r15
    377d:	call   3782 <botlish_fn_18+0x272>
			377e: R_X86_64_PLT32	rt_int_cmp-0x4
    3782:	mov    ecx,0x2
    3787:	test   rax,rax
    378a:	cmovge rcx,QWORD PTR [rip+0x1ae]        # 3940 <botlish_fn_18+0x430>
    3792:	jmp    37a7 <botlish_fn_18+0x297>
    3797:	mov    ecx,0x2
    379c:	cmp    r12,rbx
    379f:	cmovge rcx,QWORD PTR [rip+0x199]        # 3940 <botlish_fn_18+0x430>
    37a7:	cmp    rcx,0x6
    37ab:	je     38fb <botlish_fn_18+0x3eb>
    37b1:	lea    rcx,[rsp+0x90]
    37b9:	mov    rsi,r14
    37bc:	mov    rdx,r12
    37bf:	mov    rdi,r15
    37c2:	call   37c7 <botlish_fn_18+0x2b7>
			37c3: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    37c7:	test   rax,rax
    37ca:	mov    rsi,rax
    37cd:	je     3861 <botlish_fn_18+0x351>
    37d3:	mov    rdx,QWORD PTR [rsp+0x90]
    37db:	mov    rcx,QWORD PTR [rsp+0x98]
    37e3:	mov    rdi,r15
    37e6:	mov    rax,QWORD PTR [rdi+0x10]
    37ea:	mov    r8,QWORD PTR [rax+0x100]
    37f1:	call   37f6 <botlish_fn_18+0x2e6>
			37f2: R_X86_64_PLT32	rt_str_region_eq-0x4
    37f6:	cmp    rax,0x6
    37fa:	je     380d <botlish_fn_18+0x2fd>
    3800:	mov    ecx,0x2
    3805:	mov    rax,rcx
    3808:	jmp    390a <botlish_fn_18+0x3fa>
    380d:	mov    QWORD PTR [rsp],0x3
    3815:	test   r12,0x1
    381c:	je     3836 <botlish_fn_18+0x326>
    3822:	mov    rdx,r12
    3825:	add    rdx,0x2
    3829:	seto   sil
    382d:	test   sil,sil
    3830:	je     3849 <botlish_fn_18+0x339>
    3836:	mov    edx,0x3
    383b:	mov    rsi,r12
    383e:	mov    rdi,r15
    3841:	call   3846 <botlish_fn_18+0x336>
			3842: R_X86_64_PLT32	rt_int_add-0x4
    3846:	mov    rdx,rax
    3849:	mov    QWORD PTR [rsp],rdx
    384d:	mov    rsi,r13
    3850:	mov    rdi,r15
    3853:	call   3858 <botlish_fn_18+0x348>
			3854: R_X86_64_PLT32	botlish_fn_26-0x4 ; domain_loop<generic>
    3858:	test   rax,rax
    385b:	jne    3898 <botlish_fn_18+0x388>
    3861:	xor    rax,rax
    3864:	mov    rbx,QWORD PTR [rsp+0xb0]
    386c:	mov    r12,QWORD PTR [rsp+0xb8]
    3874:	mov    r13,QWORD PTR [rsp+0xc0]
    387c:	mov    r14,QWORD PTR [rsp+0xc8]
    3884:	mov    r15,QWORD PTR [rsp+0xd0]
    388c:	add    rsp,0xe0
    3893:	mov    rsp,rbp
    3896:	pop    rbp
    3897:	ret
    3898:	mov    rcx,rax
    389b:	and    rcx,rbx
    389e:	mov    rsi,rax
    38a1:	mov    QWORD PTR [rsp+0xa8],rbx
    38a9:	test   rcx,0x1
    38b0:	jne    38de <botlish_fn_18+0x3ce>
    38b6:	mov    rdx,QWORD PTR [rsp+0xa8]
    38be:	mov    rdi,r15
    38c1:	call   38c6 <botlish_fn_18+0x3b6>
			38c2: R_X86_64_PLT32	rt_int_cmp-0x4
    38c6:	mov    ecx,0x2
    38cb:	test   rax,rax
    38ce:	mov    rax,rcx
    38d1:	cmove  rax,QWORD PTR [rip+0x67]        # 3940 <botlish_fn_18+0x430>
    38d9:	jmp    390a <botlish_fn_18+0x3fa>
    38de:	mov    rdx,QWORD PTR [rsp+0xa8]
    38e6:	mov    eax,0x2
    38eb:	cmp    rsi,rdx
    38ee:	cmove  rax,QWORD PTR [rip+0x4a]        # 3940 <botlish_fn_18+0x430>
    38f6:	jmp    390a <botlish_fn_18+0x3fa>
    38fb:	mov    eax,0x2
    3900:	jmp    390a <botlish_fn_18+0x3fa>
    3905:	mov    eax,0x2
    390a:	mov    rbx,QWORD PTR [rsp+0xb0]
    3912:	mov    r12,QWORD PTR [rsp+0xb8]
    391a:	mov    r13,QWORD PTR [rsp+0xc0]
    3922:	mov    r14,QWORD PTR [rsp+0xc8]
    392a:	mov    r15,QWORD PTR [rsp+0xd0]
    3932:	add    rsp,0xe0
    3939:	mov    rsp,rbp
    393c:	pop    rbp
    393d:	ret
    393e:	add    BYTE PTR [rax],al
    3940:	(bad)
    3941:	add    BYTE PTR [rax],al
    3943:	add    BYTE PTR [rax],al
    3945:	add    BYTE PTR [rax],al
	...

0000000000003948 <botlish_entry_18: <str>>:
    3948:	push   rbp
    3949:	mov    rbp,rsp
    394c:	mov    rsi,QWORD PTR [rdx]
    394f:	call   3954 <botlish_entry_18+0xc>
			3950: R_X86_64_PLT32	botlish_fn_18-0x4 ; <str>
    3954:	mov    rsp,rbp
    3957:	pop    rbp
    3958:	ret
    3959:	add    BYTE PTR [rax],al
    395b:	add    BYTE PTR [rax],al
    395d:	add    BYTE PTR [rax],al
	...

0000000000003960 <botlish_fn_19: <generic>>:
    3960:	push   rbp
    3961:	mov    rbp,rsp
    3964:	sub    rsp,0xe0
    396b:	mov    QWORD PTR [rsp+0xb0],rbx
    3973:	mov    QWORD PTR [rsp+0xb8],r12
    397b:	mov    QWORD PTR [rsp+0xc0],r13
    3983:	mov    QWORD PTR [rsp+0xc8],r14
    398b:	mov    QWORD PTR [rsp+0xd0],r15
    3993:	mov    QWORD PTR [rsp+0x10],0x0
    399c:	mov    QWORD PTR [rsp+0x18],0x0
    39a5:	mov    QWORD PTR [rsp+0x20],0x0
    39ae:	mov    QWORD PTR [rsp],rsi
    39b2:	xor    r8d,r8d
    39b5:	test   rsi,0x7
    39bc:	jne    39cc <botlish_fn_19+0x6c>
    39c2:	movzx  rax,BYTE PTR [rsi]
    39c6:	cmp    al,0x2
    39c8:	sete   r8b
    39cc:	test   r8b,r8b
    39cf:	jne    39ef <botlish_fn_19+0x8f>
    39d5:	mov    rax,QWORD PTR [rdi+0x10]
    39d9:	mov    rcx,QWORD PTR [rax+0xd8]
    39e0:	mov    edx,0x1
    39e5:	call   39ea <botlish_fn_19+0x8a>
			39e6: R_X86_64_PLT32	rt_type_error-0x4
    39ea:	jmp    3cde <botlish_fn_19+0x37e>
    39ef:	mov    rbx,rsi
    39f2:	mov    r15,rdi
    39f5:	call   39fa <botlish_fn_19+0x9a>
			39f6: R_X86_64_PLT32	rt_str_len-0x4
    39fa:	mov    r14,rax
    39fd:	mov    QWORD PTR [rsp+0x8],rax
    3a02:	lea    r8,[rsp+0x28]
    3a07:	mov    QWORD PTR [rsp+0x28],rbx
    3a0c:	mov    esi,0x14
    3a11:	mov    rdx,QWORD PTR [rip+0x0]        # 3a18 <botlish_fn_19+0xb8>
			3a14: R_X86_64_GOTPCREL	botlish_entry_20-0x4 ; char_at<generic>
    3a18:	mov    ebx,0x1
    3a1d:	mov    rcx,rbx
    3a20:	mov    rdi,r15
    3a23:	call   3a28 <botlish_fn_19+0xc8>
			3a24: R_X86_64_PLT32	rt_closure_new-0x4
    3a28:	mov    r13,rax
    3a2b:	mov    QWORD PTR [rsp+0xa8],rbx
    3a33:	mov    QWORD PTR [rsp],rax
    3a37:	lea    r8,[rsp+0x30]
    3a3c:	mov    rax,r14
    3a3f:	mov    QWORD PTR [rsp+0x30],rax
    3a44:	mov    rax,r13
    3a47:	mov    QWORD PTR [rsp+0x38],rax
    3a4c:	mov    esi,0x16
    3a51:	mov    rdx,QWORD PTR [rip+0x0]        # 3a58 <botlish_fn_19+0xf8>
			3a54: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; scan_local<generic>
    3a58:	mov    r12d,0x2
    3a5e:	mov    rcx,r12
    3a61:	mov    rdi,r15
    3a64:	call   3a69 <botlish_fn_19+0x109>
			3a65: R_X86_64_PLT32	rt_closure_new-0x4
    3a69:	mov    rbx,rax
    3a6c:	mov    QWORD PTR [rsp+0x10],rbx
    3a71:	lea    r8,[rsp+0x40]
    3a76:	mov    rax,r14
    3a79:	mov    QWORD PTR [rsp+0x40],rax
    3a7e:	mov    rax,r13
    3a81:	mov    QWORD PTR [rsp+0x48],rax
    3a86:	mov    esi,0x17
    3a8b:	mov    rdx,QWORD PTR [rip+0x0]        # 3a92 <botlish_fn_19+0x132>
			3a8e: R_X86_64_GOTPCREL	botlish_entry_23-0x4 ; scan_label<generic>
    3a92:	mov    rcx,r12
    3a95:	mov    rdi,r15
    3a98:	call   3a9d <botlish_fn_19+0x13d>
			3a99: R_X86_64_PLT32	rt_closure_new-0x4
    3a9d:	mov    QWORD PTR [rsp+0x18],rax
    3aa2:	mov    QWORD PTR [rsp+0xa0],rax
    3aaa:	lea    r8,[rsp+0x50]
    3aaf:	mov    rax,r14
    3ab2:	mov    QWORD PTR [rsp+0x50],rax
    3ab7:	mov    QWORD PTR [rsp+0x58],r13
    3abc:	mov    esi,0x18
    3ac1:	mov    rdx,QWORD PTR [rip+0x0]        # 3ac8 <botlish_fn_19+0x168>
			3ac4: R_X86_64_GOTPCREL	botlish_entry_24-0x4 ; scan_alpha<generic>
    3ac8:	mov    rcx,r12
    3acb:	mov    rdi,r15
    3ace:	call   3ad3 <botlish_fn_19+0x173>
			3acf: R_X86_64_PLT32	rt_closure_new-0x4
    3ad3:	mov    QWORD PTR [rsp+0x20],rax
    3ad8:	lea    r8,[rsp+0x60]
    3add:	mov    QWORD PTR [rsp+0x60],rax
    3ae2:	mov    rax,r14
    3ae5:	mov    QWORD PTR [rsp+0x68],rax
    3aea:	mov    esi,0x19
    3aef:	mov    rdx,QWORD PTR [rip+0x0]        # 3af6 <botlish_fn_19+0x196>
			3af2: R_X86_64_GOTPCREL	botlish_entry_25-0x4 ; tld_ok<generic>
    3af6:	mov    rcx,r12
    3af9:	mov    rdi,r15
    3afc:	call   3b01 <botlish_fn_19+0x1a1>
			3afd: R_X86_64_PLT32	rt_closure_new-0x4
    3b01:	mov    QWORD PTR [rsp+0x20],rax
    3b06:	lea    r8,[rsp+0x70]
    3b0b:	mov    rcx,QWORD PTR [rsp+0xa0]
    3b13:	mov    QWORD PTR [rsp+0x70],rcx
    3b18:	mov    rcx,r14
    3b1b:	mov    QWORD PTR [rsp+0x78],rcx
    3b20:	mov    QWORD PTR [rsp+0x80],r13
    3b28:	mov    QWORD PTR [rsp+0x88],rax
    3b30:	mov    esi,0x1a
    3b35:	mov    rdx,QWORD PTR [rip+0x0]        # 3b3c <botlish_fn_19+0x1dc>
			3b38: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; domain_loop<generic>
    3b3c:	mov    ecx,0x4
    3b41:	mov    rdi,r15
    3b44:	call   3b49 <botlish_fn_19+0x1e9>
			3b45: R_X86_64_PLT32	rt_closure_new-0x4
    3b49:	mov    QWORD PTR [rsp+0x18],rax
    3b4e:	mov    QWORD PTR [rsp+0xa0],rax
    3b56:	mov    QWORD PTR [rsp+0x20],0x1
    3b5f:	mov    rsi,rbx
    3b62:	mov    rdx,QWORD PTR [rsp+0xa8]
    3b6a:	mov    rdi,r15
    3b6d:	call   3b72 <botlish_fn_19+0x212>
			3b6e: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_local<generic>
    3b72:	mov    rcx,rax
    3b75:	mov    r12,rax
    3b78:	test   rax,rcx
    3b7b:	je     3cde <botlish_fn_19+0x37e>
    3b81:	mov    rax,r12
    3b84:	mov    QWORD PTR [rsp+0x10],rax
    3b89:	test   rax,0x1
    3b8f:	jne    3bbd <botlish_fn_19+0x25d>
    3b95:	mov    rdx,QWORD PTR [rsp+0xa8]
    3b9d:	mov    rsi,r12
    3ba0:	mov    rdi,r15
    3ba3:	call   3ba8 <botlish_fn_19+0x248>
			3ba4: R_X86_64_PLT32	rt_int_cmp-0x4
    3ba8:	mov    ecx,0x2
    3bad:	test   rax,rax
    3bb0:	cmove  rcx,QWORD PTR [rip+0x1f8]        # 3db0 <botlish_fn_19+0x450>
    3bb8:	jmp    3bce <botlish_fn_19+0x26e>
    3bbd:	mov    ecx,0x2
    3bc2:	cmp    r12,0x1
    3bc6:	cmove  rcx,QWORD PTR [rip+0x1e2]        # 3db0 <botlish_fn_19+0x450>
    3bce:	cmp    rcx,0x6
    3bd2:	je     3d73 <botlish_fn_19+0x413>
    3bd8:	mov    rbx,r14
    3bdb:	mov    rcx,r12
    3bde:	and    rcx,rbx
    3be1:	test   rcx,0x1
    3be8:	jne    3c11 <botlish_fn_19+0x2b1>
    3bee:	mov    rdx,rbx
    3bf1:	mov    rsi,r12
    3bf4:	mov    rdi,r15
    3bf7:	call   3bfc <botlish_fn_19+0x29c>
			3bf8: R_X86_64_PLT32	rt_int_cmp-0x4
    3bfc:	mov    ecx,0x2
    3c01:	test   rax,rax
    3c04:	cmovge rcx,QWORD PTR [rip+0x1a4]        # 3db0 <botlish_fn_19+0x450>
    3c0c:	jmp    3c21 <botlish_fn_19+0x2c1>
    3c11:	mov    ecx,0x2
    3c16:	cmp    r12,rbx
    3c19:	cmovge rcx,QWORD PTR [rip+0x18f]        # 3db0 <botlish_fn_19+0x450>
    3c21:	cmp    rcx,0x6
    3c25:	je     3d69 <botlish_fn_19+0x409>
    3c2b:	lea    rcx,[rsp+0x90]
    3c33:	mov    rsi,r13
    3c36:	mov    rdx,r12
    3c39:	mov    rdi,r15
    3c3c:	call   3c41 <botlish_fn_19+0x2e1>
			3c3d: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    3c41:	test   rax,rax
    3c44:	mov    rsi,rax
    3c47:	je     3cde <botlish_fn_19+0x37e>
    3c4d:	mov    rdx,QWORD PTR [rsp+0x90]
    3c55:	mov    rcx,QWORD PTR [rsp+0x98]
    3c5d:	mov    rdi,r15
    3c60:	mov    rax,QWORD PTR [rdi+0x10]
    3c64:	mov    r8,QWORD PTR [rax+0x100]
    3c6b:	call   3c70 <botlish_fn_19+0x310>
			3c6c: R_X86_64_PLT32	rt_str_region_eq-0x4
    3c70:	cmp    rax,0x6
    3c74:	je     3c87 <botlish_fn_19+0x327>
    3c7a:	mov    ecx,0x2
    3c7f:	mov    rax,rcx
    3c82:	jmp    3d78 <botlish_fn_19+0x418>
    3c87:	mov    QWORD PTR [rsp],0x3
    3c8f:	test   r12,0x1
    3c96:	je     3cae <botlish_fn_19+0x34e>
    3c9c:	mov    rdx,r12
    3c9f:	add    rdx,0x2
    3ca3:	seto   al
    3ca6:	test   al,al
    3ca8:	je     3cc1 <botlish_fn_19+0x361>
    3cae:	mov    edx,0x3
    3cb3:	mov    rsi,r12
    3cb6:	mov    rdi,r15
    3cb9:	call   3cbe <botlish_fn_19+0x35e>
			3cba: R_X86_64_PLT32	rt_int_add-0x4
    3cbe:	mov    rdx,rax
    3cc1:	mov    QWORD PTR [rsp],rdx
    3cc5:	mov    rsi,QWORD PTR [rsp+0xa0]
    3ccd:	mov    rdi,r15
    3cd0:	call   3cd5 <botlish_fn_19+0x375>
			3cd1: R_X86_64_PLT32	botlish_fn_26-0x4 ; domain_loop<generic>
    3cd5:	test   rax,rax
    3cd8:	jne    3d15 <botlish_fn_19+0x3b5>
    3cde:	xor    rax,rax
    3ce1:	mov    rbx,QWORD PTR [rsp+0xb0]
    3ce9:	mov    r12,QWORD PTR [rsp+0xb8]
    3cf1:	mov    r13,QWORD PTR [rsp+0xc0]
    3cf9:	mov    r14,QWORD PTR [rsp+0xc8]
    3d01:	mov    r15,QWORD PTR [rsp+0xd0]
    3d09:	add    rsp,0xe0
    3d10:	mov    rsp,rbp
    3d13:	pop    rbp
    3d14:	ret
    3d15:	mov    rcx,rax
    3d18:	and    rcx,rbx
    3d1b:	mov    rsi,rax
    3d1e:	mov    r14,rbx
    3d21:	test   rcx,0x1
    3d28:	jne    3d51 <botlish_fn_19+0x3f1>
    3d2e:	mov    rdx,r14
    3d31:	mov    rdi,r15
    3d34:	call   3d39 <botlish_fn_19+0x3d9>
			3d35: R_X86_64_PLT32	rt_int_cmp-0x4
    3d39:	mov    ecx,0x2
    3d3e:	test   rax,rax
    3d41:	mov    rax,rcx
    3d44:	cmove  rax,QWORD PTR [rip+0x64]        # 3db0 <botlish_fn_19+0x450>
    3d4c:	jmp    3d78 <botlish_fn_19+0x418>
    3d51:	mov    rdx,r14
    3d54:	mov    eax,0x2
    3d59:	cmp    rsi,rdx
    3d5c:	cmove  rax,QWORD PTR [rip+0x4c]        # 3db0 <botlish_fn_19+0x450>
    3d64:	jmp    3d78 <botlish_fn_19+0x418>
    3d69:	mov    eax,0x2
    3d6e:	jmp    3d78 <botlish_fn_19+0x418>
    3d73:	mov    eax,0x2
    3d78:	mov    rbx,QWORD PTR [rsp+0xb0]
    3d80:	mov    r12,QWORD PTR [rsp+0xb8]
    3d88:	mov    r13,QWORD PTR [rsp+0xc0]
    3d90:	mov    r14,QWORD PTR [rsp+0xc8]
    3d98:	mov    r15,QWORD PTR [rsp+0xd0]
    3da0:	add    rsp,0xe0
    3da7:	mov    rsp,rbp
    3daa:	pop    rbp
    3dab:	ret
    3dac:	add    BYTE PTR [rax],al
    3dae:	add    BYTE PTR [rax],al
    3db0:	(bad)
    3db1:	add    BYTE PTR [rax],al
    3db3:	add    BYTE PTR [rax],al
    3db5:	add    BYTE PTR [rax],al
	...

0000000000003db8 <botlish_entry_19: <generic>>:
    3db8:	push   rbp
    3db9:	mov    rbp,rsp
    3dbc:	mov    rsi,QWORD PTR [rdx]
    3dbf:	call   3dc4 <botlish_entry_19+0xc>
			3dc0: R_X86_64_PLT32	botlish_fn_19-0x4 ; <generic>
    3dc4:	mov    rsp,rbp
    3dc7:	pop    rbp
    3dc8:	ret

0000000000003dc9 <botlish_fn_20: char_at<generic>>:
    3dc9:	push   rbp
    3dca:	mov    rbp,rsp
    3dcd:	sub    rsp,0x40
    3dd1:	mov    QWORD PTR [rsp+0x20],rbx
    3dd6:	mov    QWORD PTR [rsp+0x28],r12
    3ddb:	mov    QWORD PTR [rsp+0x30],r13
    3de0:	mov    QWORD PTR [rsp],rdx
    3de4:	mov    rax,QWORD PTR [rsi+0x20]
    3de8:	mov    rsi,QWORD PTR [rax]
    3deb:	mov    QWORD PTR [rsp+0x8],rsi
    3df0:	mov    r13,rsi
    3df3:	mov    QWORD PTR [rsp+0x10],0x3
    3dfc:	mov    r10d,0x1
    3e02:	test   rdx,0x1
    3e09:	je     3e17 <botlish_fn_20+0x4e>
    3e0f:	mov    rbx,rdx
    3e12:	jmp    3e3c <botlish_fn_20+0x73>
    3e17:	xor    r10d,r10d
    3e1a:	test   rdx,0x7
    3e21:	je     3e2f <botlish_fn_20+0x66>
    3e27:	mov    rbx,rdx
    3e2a:	jmp    3e3c <botlish_fn_20+0x73>
    3e2f:	movzx  rax,BYTE PTR [rdx]
    3e33:	mov    rbx,rdx
    3e36:	cmp    al,0x1
    3e38:	sete   r10b
    3e3c:	test   r10b,r10b
    3e3f:	jne    3e60 <botlish_fn_20+0x97>
    3e45:	mov    rax,QWORD PTR [rdi+0x10]
    3e49:	mov    rcx,QWORD PTR [rax+0x108]
    3e50:	xor    rdx,rdx
    3e53:	mov    rsi,rbx
    3e56:	call   3e5b <botlish_fn_20+0x92>
			3e57: R_X86_64_PLT32	rt_type_error-0x4
    3e5b:	jmp    3f12 <botlish_fn_20+0x149>
    3e60:	mov    rsi,rbx
    3e63:	mov    r12,rdi
    3e66:	test   rsi,0x1
    3e6d:	je     3e88 <botlish_fn_20+0xbf>
    3e73:	mov    rsi,rbx
    3e76:	mov    rcx,rsi
    3e79:	add    rcx,0x2
    3e7d:	seto   al
    3e80:	test   al,al
    3e82:	je     3e9b <botlish_fn_20+0xd2>
    3e88:	mov    edx,0x3
    3e8d:	mov    rsi,rbx
    3e90:	mov    rdi,r12
    3e93:	call   3e98 <botlish_fn_20+0xcf>
			3e94: R_X86_64_PLT32	rt_int_add-0x4
    3e98:	mov    rcx,rax
    3e9b:	mov    QWORD PTR [rsp+0x10],rcx
    3ea0:	mov    eax,0x1
    3ea5:	mov    rsi,rbx
    3ea8:	test   rsi,0x1
    3eaf:	jne    3ed5 <botlish_fn_20+0x10c>
    3eb5:	xor    eax,eax
    3eb7:	mov    rsi,rbx
    3eba:	test   rsi,0x7
    3ec1:	jne    3ed5 <botlish_fn_20+0x10c>
    3ec7:	mov    rsi,rbx
    3eca:	movzx  rdx,BYTE PTR [rsi]
    3ece:	rex cmp dl,0x1
    3ed2:	sete   al
    3ed5:	test   al,al
    3ed7:	jne    3efb <botlish_fn_20+0x132>
    3edd:	mov    rdi,r12
    3ee0:	mov    rsi,QWORD PTR [rdi+0x10]
    3ee4:	mov    rcx,QWORD PTR [rsi+0x110]
    3eeb:	xor    rdx,rdx
    3eee:	mov    rsi,rbx
    3ef1:	call   3ef6 <botlish_fn_20+0x12d>
			3ef2: R_X86_64_PLT32	rt_type_error-0x4
    3ef6:	jmp    3f12 <botlish_fn_20+0x149>
    3efb:	mov    rdx,rbx
    3efe:	mov    rsi,r13
    3f01:	mov    rdi,r12
    3f04:	call   3f09 <botlish_fn_20+0x140>
			3f05: R_X86_64_PLT32	rt_substr-0x4
    3f09:	test   rax,rax
    3f0c:	jne    3f2d <botlish_fn_20+0x164>
    3f12:	xor    rax,rax
    3f15:	mov    rbx,QWORD PTR [rsp+0x20]
    3f1a:	mov    r12,QWORD PTR [rsp+0x28]
    3f1f:	mov    r13,QWORD PTR [rsp+0x30]
    3f24:	add    rsp,0x40
    3f28:	mov    rsp,rbp
    3f2b:	pop    rbp
    3f2c:	ret
    3f2d:	mov    rbx,QWORD PTR [rsp+0x20]
    3f32:	mov    r12,QWORD PTR [rsp+0x28]
    3f37:	mov    r13,QWORD PTR [rsp+0x30]
    3f3c:	add    rsp,0x40
    3f40:	mov    rsp,rbp
    3f43:	pop    rbp
    3f44:	ret

0000000000003f45 <botlish_entry_20: char_at<generic>>:
    3f45:	push   rbp
    3f46:	mov    rbp,rsp
    3f49:	mov    rdx,QWORD PTR [rdx]
    3f4c:	call   3f51 <botlish_entry_20+0xc>
			3f4d: R_X86_64_PLT32	botlish_fn_20-0x4 ; char_at<generic>
    3f51:	mov    rsp,rbp
    3f54:	pop    rbp
    3f55:	ret

0000000000003f56 <botlish_fn_21: char_at<generic>>:
    3f56:	push   rbp
    3f57:	mov    rbp,rsp
    3f5a:	sub    rsp,0x40
    3f5e:	mov    QWORD PTR [rsp+0x20],rbx
    3f63:	mov    QWORD PTR [rsp+0x28],r12
    3f68:	mov    QWORD PTR [rsp+0x30],r13
    3f6d:	mov    QWORD PTR [rsp+0x38],r14
    3f72:	mov    r13,rcx
    3f75:	mov    QWORD PTR [rsp],rdx
    3f79:	mov    rax,QWORD PTR [rsi+0x20]
    3f7d:	mov    rax,QWORD PTR [rax]
    3f80:	mov    QWORD PTR [rsp+0x8],rax
    3f85:	mov    r14,rax
    3f88:	mov    QWORD PTR [rsp+0x10],0x3
    3f91:	mov    r11d,0x1
    3f97:	test   rdx,0x1
    3f9e:	je     3fac <botlish_fn_21+0x56>
    3fa4:	mov    r12,rdx
    3fa7:	jmp    3fd1 <botlish_fn_21+0x7b>
    3fac:	xor    r11d,r11d
    3faf:	test   rdx,0x7
    3fb6:	je     3fc4 <botlish_fn_21+0x6e>
    3fbc:	mov    r12,rdx
    3fbf:	jmp    3fd1 <botlish_fn_21+0x7b>
    3fc4:	movzx  rax,BYTE PTR [rdx]
    3fc8:	mov    r12,rdx
    3fcb:	cmp    al,0x1
    3fcd:	sete   r11b
    3fd1:	test   r11b,r11b
    3fd4:	jne    3ff5 <botlish_fn_21+0x9f>
    3fda:	mov    rax,QWORD PTR [rdi+0x10]
    3fde:	mov    rcx,QWORD PTR [rax+0x108]
    3fe5:	xor    rdx,rdx
    3fe8:	mov    rsi,r12
    3feb:	call   3ff0 <botlish_fn_21+0x9a>
			3fec: R_X86_64_PLT32	rt_type_error-0x4
    3ff0:	jmp    40ad <botlish_fn_21+0x157>
    3ff5:	mov    rbx,rdi
    3ff8:	mov    rsi,r12
    3ffb:	test   rsi,0x1
    4002:	jne    4010 <botlish_fn_21+0xba>
    4008:	mov    r12,rsi
    400b:	jmp    4025 <botlish_fn_21+0xcf>
    4010:	mov    rax,rsi
    4013:	add    rax,0x2
    4017:	mov    r12,rsi
    401a:	seto   cl
    401d:	test   cl,cl
    401f:	je     4035 <botlish_fn_21+0xdf>
    4025:	mov    edx,0x3
    402a:	mov    rsi,r12
    402d:	mov    rdi,rbx
    4030:	call   4035 <botlish_fn_21+0xdf>
			4031: R_X86_64_PLT32	rt_int_add-0x4
    4035:	mov    ecx,0x1
    403a:	mov    rsi,r12
    403d:	test   rsi,0x1
    4044:	jne    406a <botlish_fn_21+0x114>
    404a:	xor    ecx,ecx
    404c:	mov    rsi,r12
    404f:	test   rsi,0x7
    4056:	jne    406a <botlish_fn_21+0x114>
    405c:	mov    rsi,r12
    405f:	movzx  rdx,BYTE PTR [rsi]
    4063:	rex cmp dl,0x1
    4067:	sete   cl
    406a:	test   cl,cl
    406c:	jne    4090 <botlish_fn_21+0x13a>
    4072:	mov    rdi,rbx
    4075:	mov    rsi,QWORD PTR [rdi+0x10]
    4079:	mov    rcx,QWORD PTR [rsi+0x110]
    4080:	xor    rdx,rdx
    4083:	mov    rsi,r12
    4086:	call   408b <botlish_fn_21+0x135>
			4087: R_X86_64_PLT32	rt_type_error-0x4
    408b:	jmp    40ad <botlish_fn_21+0x157>
    4090:	mov    rdi,rbx
    4093:	mov    rbx,rax
    4096:	mov    rcx,rbx
    4099:	mov    rdx,r12
    409c:	mov    rsi,r14
    409f:	call   40a4 <botlish_fn_21+0x14e>
			40a0: R_X86_64_PLT32	rt_str_region_check-0x4
    40a4:	test   rax,rax
    40a7:	jne    40cd <botlish_fn_21+0x177>
    40ad:	xor    rax,rax
    40b0:	mov    rbx,QWORD PTR [rsp+0x20]
    40b5:	mov    r12,QWORD PTR [rsp+0x28]
    40ba:	mov    r13,QWORD PTR [rsp+0x30]
    40bf:	mov    r14,QWORD PTR [rsp+0x38]
    40c4:	add    rsp,0x40
    40c8:	mov    rsp,rbp
    40cb:	pop    rbp
    40cc:	ret
    40cd:	mov    rcx,r13
    40d0:	mov    rsi,r12
    40d3:	mov    QWORD PTR [rcx],rsi
    40d6:	mov    QWORD PTR [rcx+0x8],rbx
    40da:	mov    rax,r14
    40dd:	mov    rbx,QWORD PTR [rsp+0x20]
    40e2:	mov    r12,QWORD PTR [rsp+0x28]
    40e7:	mov    r13,QWORD PTR [rsp+0x30]
    40ec:	mov    r14,QWORD PTR [rsp+0x38]
    40f1:	add    rsp,0x40
    40f5:	mov    rsp,rbp
    40f8:	pop    rbp
    40f9:	ret

00000000000040fa <botlish_entry_21: char_at<generic>>:
    40fa:	push   rbp
    40fb:	mov    rbp,rsp
    40fe:	ud2

0000000000004100 <botlish_fn_22: scan_local<generic>>:
    4100:	push   rbp
    4101:	mov    rbp,rsp
    4104:	sub    rsp,0x70
    4108:	mov    QWORD PTR [rsp+0x40],rbx
    410d:	mov    QWORD PTR [rsp+0x48],r12
    4112:	mov    QWORD PTR [rsp+0x50],r13
    4117:	mov    QWORD PTR [rsp+0x58],r14
    411c:	mov    QWORD PTR [rsp+0x60],r15
    4121:	mov    rcx,rdi
    4124:	mov    QWORD PTR [rsp+0x10],0x0
    412d:	mov    QWORD PTR [rsp],rdx
    4131:	mov    r12,rsi
    4134:	mov    rsi,rdx
    4137:	mov    rax,QWORD PTR [r12+0x20]
    413c:	mov    rdx,QWORD PTR [rax]
    413f:	mov    r10d,0x1
    4145:	test   rsi,0x1
    414c:	jne    416e <botlish_fn_22+0x6e>
    4152:	xor    r10d,r10d
    4155:	test   rsi,0x7
    415c:	jne    416e <botlish_fn_22+0x6e>
    4162:	movzx  rdi,BYTE PTR [rsi]
    4166:	cmp    dil,0x1
    416a:	sete   r10b
    416e:	test   r10b,r10b
    4171:	jne    4192 <botlish_fn_22+0x92>
    4177:	mov    rdi,rcx
    417a:	mov    r10,QWORD PTR [rdi+0x10]
    417e:	mov    rcx,QWORD PTR [r10+0xb8]
    4185:	xor    rdx,rdx
    4188:	call   418d <botlish_fn_22+0x8d>
			4189: R_X86_64_PLT32	rt_type_error-0x4
    418d:	jmp    4248 <botlish_fn_22+0x148>
    4192:	mov    r11,rsi
    4195:	and    r11,rdx
    4198:	mov    r13,rsi
    419b:	test   r11,0x1
    41a2:	jne    41cb <botlish_fn_22+0xcb>
    41a8:	mov    rbx,rcx
    41ab:	mov    rsi,r13
    41ae:	mov    rdi,rbx
    41b1:	call   41b6 <botlish_fn_22+0xb6>
			41b2: R_X86_64_PLT32	rt_int_cmp-0x4
    41b6:	mov    ecx,0x2
    41bb:	test   rax,rax
    41be:	cmovge rcx,QWORD PTR [rip+0x242]        # 4408 <botlish_fn_22+0x308>
    41c6:	jmp    41e1 <botlish_fn_22+0xe1>
    41cb:	mov    rbx,rcx
    41ce:	mov    ecx,0x2
    41d3:	mov    rsi,r13
    41d6:	cmp    rsi,rdx
    41d9:	cmovge rcx,QWORD PTR [rip+0x227]        # 4408 <botlish_fn_22+0x308>
    41e1:	mov    eax,0x6
    41e6:	mov    QWORD PTR [rsp+0x28],rax
    41eb:	cmp    rcx,0x6
    41ef:	je     43dc <botlish_fn_22+0x2dc>
    41f5:	mov    rax,QWORD PTR [r12+0x20]
    41fa:	mov    rsi,QWORD PTR [rax+0x8]
    41fe:	mov    QWORD PTR [rsp+0x8],rsi
    4203:	lea    rcx,[rsp+0x18]
    4208:	mov    rdx,r13
    420b:	mov    rdi,rbx
    420e:	call   4213 <botlish_fn_22+0x113>
			420f: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    4213:	mov    r8,rax
    4216:	mov    r14,rax
    4219:	test   rax,r8
    421c:	je     4248 <botlish_fn_22+0x148>
    4222:	mov    rdx,QWORD PTR [rsp+0x18]
    4227:	mov    r15,rdx
    422a:	mov    rcx,QWORD PTR [rsp+0x20]
    422f:	mov    QWORD PTR [rsp+0x30],rcx
    4234:	mov    rsi,r14
    4237:	mov    rdi,rbx
    423a:	call   423f <botlish_fn_22+0x13f>
			423b: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    423f:	test   rax,rax
    4242:	jne    426d <botlish_fn_22+0x16d>
    4248:	xor    rax,rax
    424b:	mov    rbx,QWORD PTR [rsp+0x40]
    4250:	mov    r12,QWORD PTR [rsp+0x48]
    4255:	mov    r13,QWORD PTR [rsp+0x50]
    425a:	mov    r14,QWORD PTR [rsp+0x58]
    425f:	mov    r15,QWORD PTR [rsp+0x60]
    4264:	add    rsp,0x70
    4268:	mov    rsp,rbp
    426b:	pop    rbp
    426c:	ret
    426d:	cmp    rax,0x6
    4271:	je     4362 <botlish_fn_22+0x262>
    4277:	mov    rax,QWORD PTR [rbx+0x10]
    427b:	mov    r8,QWORD PTR [rax+0x118]
    4282:	mov    rcx,QWORD PTR [rsp+0x30]
    4287:	mov    rdx,r15
    428a:	mov    rsi,r14
    428d:	mov    rdi,rbx
    4290:	call   4295 <botlish_fn_22+0x195>
			4291: R_X86_64_PLT32	rt_str_region_eq-0x4
    4295:	cmp    rax,0x6
    4299:	je     4358 <botlish_fn_22+0x258>
    429f:	mov    rax,QWORD PTR [rbx+0x10]
    42a3:	mov    r8,QWORD PTR [rax+0x120]
    42aa:	mov    rcx,QWORD PTR [rsp+0x30]
    42af:	mov    rdx,r15
    42b2:	mov    rsi,r14
    42b5:	mov    rdi,rbx
    42b8:	call   42bd <botlish_fn_22+0x1bd>
			42b9: R_X86_64_PLT32	rt_str_region_eq-0x4
    42bd:	cmp    rax,0x6
    42c1:	je     434e <botlish_fn_22+0x24e>
    42c7:	mov    rax,QWORD PTR [rbx+0x10]
    42cb:	mov    r8,QWORD PTR [rax+0xc0]
    42d2:	mov    rcx,QWORD PTR [rsp+0x30]
    42d7:	mov    rdx,r15
    42da:	mov    rsi,r14
    42dd:	mov    rdi,rbx
    42e0:	call   42e5 <botlish_fn_22+0x1e5>
			42e1: R_X86_64_PLT32	rt_str_region_eq-0x4
    42e5:	cmp    rax,0x6
    42e9:	je     4344 <botlish_fn_22+0x244>
    42ef:	mov    rax,QWORD PTR [rbx+0x10]
    42f3:	mov    r8,QWORD PTR [rax+0x108]
    42fa:	mov    rcx,QWORD PTR [rsp+0x30]
    42ff:	mov    rdx,r15
    4302:	mov    rsi,r14
    4305:	mov    rdi,rbx
    4308:	call   430d <botlish_fn_22+0x20d>
			4309: R_X86_64_PLT32	rt_str_region_eq-0x4
    430d:	cmp    rax,0x6
    4311:	je     433a <botlish_fn_22+0x23a>
    4317:	mov    rax,QWORD PTR [rbx+0x10]
    431b:	mov    r8,QWORD PTR [rax+0x128]
    4322:	mov    rcx,QWORD PTR [rsp+0x30]
    4327:	mov    rdx,r15
    432a:	mov    rsi,r14
    432d:	mov    rdi,rbx
    4330:	call   4335 <botlish_fn_22+0x235>
			4331: R_X86_64_PLT32	rt_str_region_eq-0x4
    4335:	jmp    4367 <botlish_fn_22+0x267>
    433a:	mov    rax,QWORD PTR [rsp+0x28]
    433f:	jmp    4367 <botlish_fn_22+0x267>
    4344:	mov    rax,QWORD PTR [rsp+0x28]
    4349:	jmp    4367 <botlish_fn_22+0x267>
    434e:	mov    rax,QWORD PTR [rsp+0x28]
    4353:	jmp    4367 <botlish_fn_22+0x267>
    4358:	mov    rax,QWORD PTR [rsp+0x28]
    435d:	jmp    4367 <botlish_fn_22+0x267>
    4362:	mov    rax,QWORD PTR [rsp+0x28]
    4367:	cmp    rax,0x6
    436b:	je     4379 <botlish_fn_22+0x279>
    4371:	mov    rax,r13
    4374:	jmp    43df <botlish_fn_22+0x2df>
    4379:	mov    QWORD PTR [rsp+0x8],r12
    437e:	mov    QWORD PTR [rsp+0x10],0x3
    4387:	mov    rsi,r13
    438a:	test   rsi,0x1
    4391:	je     43b7 <botlish_fn_22+0x2b7>
    4397:	mov    rsi,r13
    439a:	mov    rax,rsi
    439d:	add    rax,0x2
    43a1:	seto   cl
    43a4:	test   cl,cl
    43a6:	jne    43b7 <botlish_fn_22+0x2b7>
    43ac:	mov    rsi,rax
    43af:	mov    r13,rax
    43b2:	jmp    43cd <botlish_fn_22+0x2cd>
    43b7:	mov    edx,0x3
    43bc:	mov    rsi,r13
    43bf:	mov    rdi,rbx
    43c2:	call   43c7 <botlish_fn_22+0x2c7>
			43c3: R_X86_64_PLT32	rt_int_add-0x4
    43c7:	mov    rsi,rax
    43ca:	mov    r13,rax
    43cd:	mov    QWORD PTR [rsp],rsi
    43d1:	mov    rcx,rbx
    43d4:	mov    rsi,r13
    43d7:	jmp    4137 <botlish_fn_22+0x37>
    43dc:	mov    rax,r13
    43df:	mov    rbx,QWORD PTR [rsp+0x40]
    43e4:	mov    r12,QWORD PTR [rsp+0x48]
    43e9:	mov    r13,QWORD PTR [rsp+0x50]
    43ee:	mov    r14,QWORD PTR [rsp+0x58]
    43f3:	mov    r15,QWORD PTR [rsp+0x60]
    43f8:	add    rsp,0x70
    43fc:	mov    rsp,rbp
    43ff:	pop    rbp
    4400:	ret
    4401:	add    BYTE PTR [rax],al
    4403:	add    BYTE PTR [rax],al
    4405:	add    BYTE PTR [rax],al
    4407:	add    BYTE PTR [rsi],al
    4409:	add    BYTE PTR [rax],al
    440b:	add    BYTE PTR [rax],al
    440d:	add    BYTE PTR [rax],al
	...

0000000000004410 <botlish_entry_22: scan_local<generic>>:
    4410:	push   rbp
    4411:	mov    rbp,rsp
    4414:	mov    rdx,QWORD PTR [rdx]
    4417:	call   441c <botlish_entry_22+0xc>
			4418: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_local<generic>
    441c:	mov    rsp,rbp
    441f:	pop    rbp
    4420:	ret
    4421:	add    BYTE PTR [rax],al
    4423:	add    BYTE PTR [rax],al
    4425:	add    BYTE PTR [rax],al
	...

0000000000004428 <botlish_fn_23: scan_label<generic>>:
    4428:	push   rbp
    4429:	mov    rbp,rsp
    442c:	sub    rsp,0x70
    4430:	mov    QWORD PTR [rsp+0x40],rbx
    4435:	mov    QWORD PTR [rsp+0x48],r12
    443a:	mov    QWORD PTR [rsp+0x50],r13
    443f:	mov    QWORD PTR [rsp+0x58],r14
    4444:	mov    QWORD PTR [rsp+0x60],r15
    4449:	mov    QWORD PTR [rsp+0x10],0x0
    4452:	mov    QWORD PTR [rsp],rdx
    4456:	mov    r12,rsi
    4459:	mov    rsi,rdx
    445c:	mov    rax,QWORD PTR [r12+0x20]
    4461:	mov    rdx,QWORD PTR [rax]
    4464:	mov    r10d,0x1
    446a:	test   rsi,0x1
    4471:	jne    4491 <botlish_fn_23+0x69>
    4477:	xor    r10d,r10d
    447a:	test   rsi,0x7
    4481:	jne    4491 <botlish_fn_23+0x69>
    4487:	movzx  rax,BYTE PTR [rsi]
    448b:	cmp    al,0x1
    448d:	sete   r10b
    4491:	test   r10b,r10b
    4494:	jne    44b2 <botlish_fn_23+0x8a>
    449a:	mov    rax,QWORD PTR [rdi+0x10]
    449e:	mov    rcx,QWORD PTR [rax+0xb8]
    44a5:	xor    rdx,rdx
    44a8:	call   44ad <botlish_fn_23+0x85>
			44a9: R_X86_64_PLT32	rt_type_error-0x4
    44ad:	jmp    4561 <botlish_fn_23+0x139>
    44b2:	mov    rax,rsi
    44b5:	and    rax,rdx
    44b8:	mov    r13,rsi
    44bb:	test   rax,0x1
    44c1:	jne    44e7 <botlish_fn_23+0xbf>
    44c7:	mov    rbx,rdi
    44ca:	mov    rsi,r13
    44cd:	call   44d2 <botlish_fn_23+0xaa>
			44ce: R_X86_64_PLT32	rt_int_cmp-0x4
    44d2:	mov    ecx,0x2
    44d7:	test   rax,rax
    44da:	cmovge rcx,QWORD PTR [rip+0x176]        # 4658 <botlish_fn_23+0x230>
    44e2:	jmp    44fd <botlish_fn_23+0xd5>
    44e7:	mov    rbx,rdi
    44ea:	mov    ecx,0x2
    44ef:	mov    rsi,r13
    44f2:	cmp    rsi,rdx
    44f5:	cmovge rcx,QWORD PTR [rip+0x15b]        # 4658 <botlish_fn_23+0x230>
    44fd:	mov    eax,0x6
    4502:	mov    QWORD PTR [rsp+0x28],rax
    4507:	cmp    rcx,0x6
    450b:	je     462d <botlish_fn_23+0x205>
    4511:	mov    rsi,QWORD PTR [r12+0x20]
    4516:	mov    rsi,QWORD PTR [rsi+0x8]
    451a:	mov    QWORD PTR [rsp+0x8],rsi
    451f:	lea    rcx,[rsp+0x18]
    4524:	mov    rdx,r13
    4527:	mov    rdi,rbx
    452a:	call   452f <botlish_fn_23+0x107>
			452b: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    452f:	test   rax,rax
    4532:	mov    r14,rax
    4535:	je     4561 <botlish_fn_23+0x139>
    453b:	mov    rdx,QWORD PTR [rsp+0x18]
    4540:	mov    r15,rdx
    4543:	mov    rcx,QWORD PTR [rsp+0x20]
    4548:	mov    QWORD PTR [rsp+0x30],rcx
    454d:	mov    rsi,r14
    4550:	mov    rdi,rbx
    4553:	call   4558 <botlish_fn_23+0x130>
			4554: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    4558:	test   rax,rax
    455b:	jne    4586 <botlish_fn_23+0x15e>
    4561:	xor    rax,rax
    4564:	mov    rbx,QWORD PTR [rsp+0x40]
    4569:	mov    r12,QWORD PTR [rsp+0x48]
    456e:	mov    r13,QWORD PTR [rsp+0x50]
    4573:	mov    r14,QWORD PTR [rsp+0x58]
    4578:	mov    r15,QWORD PTR [rsp+0x60]
    457d:	add    rsp,0x70
    4581:	mov    rsp,rbp
    4584:	pop    rbp
    4585:	ret
    4586:	cmp    rax,0x6
    458a:	je     45b3 <botlish_fn_23+0x18b>
    4590:	mov    rax,QWORD PTR [rbx+0x10]
    4594:	mov    r8,QWORD PTR [rax+0x128]
    459b:	mov    rcx,QWORD PTR [rsp+0x30]
    45a0:	mov    rdx,r15
    45a3:	mov    rsi,r14
    45a6:	mov    rdi,rbx
    45a9:	call   45ae <botlish_fn_23+0x186>
			45aa: R_X86_64_PLT32	rt_str_region_eq-0x4
    45ae:	jmp    45b8 <botlish_fn_23+0x190>
    45b3:	mov    rax,QWORD PTR [rsp+0x28]
    45b8:	cmp    rax,0x6
    45bc:	je     45ca <botlish_fn_23+0x1a2>
    45c2:	mov    rax,r13
    45c5:	jmp    4630 <botlish_fn_23+0x208>
    45ca:	mov    QWORD PTR [rsp+0x8],r12
    45cf:	mov    QWORD PTR [rsp+0x10],0x3
    45d8:	mov    rsi,r13
    45db:	test   rsi,0x1
    45e2:	je     4608 <botlish_fn_23+0x1e0>
    45e8:	mov    rsi,r13
    45eb:	mov    rax,rsi
    45ee:	add    rax,0x2
    45f2:	seto   cl
    45f5:	test   cl,cl
    45f7:	jne    4608 <botlish_fn_23+0x1e0>
    45fd:	mov    rsi,rax
    4600:	mov    r13,rax
    4603:	jmp    461e <botlish_fn_23+0x1f6>
    4608:	mov    edx,0x3
    460d:	mov    rsi,r13
    4610:	mov    rdi,rbx
    4613:	call   4618 <botlish_fn_23+0x1f0>
			4614: R_X86_64_PLT32	rt_int_add-0x4
    4618:	mov    rsi,rax
    461b:	mov    r13,rax
    461e:	mov    QWORD PTR [rsp],rsi
    4622:	mov    rsi,r13
    4625:	mov    rdi,rbx
    4628:	jmp    445c <botlish_fn_23+0x34>
    462d:	mov    rax,r13
    4630:	mov    rbx,QWORD PTR [rsp+0x40]
    4635:	mov    r12,QWORD PTR [rsp+0x48]
    463a:	mov    r13,QWORD PTR [rsp+0x50]
    463f:	mov    r14,QWORD PTR [rsp+0x58]
    4644:	mov    r15,QWORD PTR [rsp+0x60]
    4649:	add    rsp,0x70
    464d:	mov    rsp,rbp
    4650:	pop    rbp
    4651:	ret
    4652:	add    BYTE PTR [rax],al
    4654:	add    BYTE PTR [rax],al
    4656:	add    BYTE PTR [rax],al
    4658:	(bad)
    4659:	add    BYTE PTR [rax],al
    465b:	add    BYTE PTR [rax],al
    465d:	add    BYTE PTR [rax],al
	...

0000000000004660 <botlish_entry_23: scan_label<generic>>:
    4660:	push   rbp
    4661:	mov    rbp,rsp
    4664:	mov    rdx,QWORD PTR [rdx]
    4667:	call   466c <botlish_entry_23+0xc>
			4668: R_X86_64_PLT32	botlish_fn_23-0x4 ; scan_label<generic>
    466c:	mov    rsp,rbp
    466f:	pop    rbp
    4670:	ret
    4671:	add    BYTE PTR [rax],al
    4673:	add    BYTE PTR [rax],al
    4675:	add    BYTE PTR [rax],al
	...

0000000000004678 <botlish_fn_24: scan_alpha<generic>>:
    4678:	push   rbp
    4679:	mov    rbp,rsp
    467c:	sub    rsp,0x50
    4680:	mov    QWORD PTR [rsp+0x30],rbx
    4685:	mov    QWORD PTR [rsp+0x38],r12
    468a:	mov    QWORD PTR [rsp+0x40],r13
    468f:	mov    r12,rdi
    4692:	mov    QWORD PTR [rsp+0x10],0x0
    469b:	mov    QWORD PTR [rsp],rdx
    469f:	mov    rbx,rsi
    46a2:	mov    rsi,rdx
    46a5:	mov    rax,QWORD PTR [rbx+0x20]
    46a9:	mov    rdx,QWORD PTR [rax]
    46ac:	mov    r10d,0x1
    46b2:	test   rsi,0x1
    46b9:	jne    46d9 <botlish_fn_24+0x61>
    46bf:	xor    r10d,r10d
    46c2:	test   rsi,0x7
    46c9:	jne    46d9 <botlish_fn_24+0x61>
    46cf:	movzx  rax,BYTE PTR [rsi]
    46d3:	cmp    al,0x1
    46d5:	sete   r10b
    46d9:	test   r10b,r10b
    46dc:	jne    46fd <botlish_fn_24+0x85>
    46e2:	mov    rdi,r12
    46e5:	mov    rax,QWORD PTR [rdi+0x10]
    46e9:	mov    rcx,QWORD PTR [rax+0xb8]
    46f0:	xor    rdx,rdx
    46f3:	call   46f8 <botlish_fn_24+0x80>
			46f4: R_X86_64_PLT32	rt_type_error-0x4
    46f8:	jmp    4793 <botlish_fn_24+0x11b>
    46fd:	mov    rax,rsi
    4700:	and    rax,rdx
    4703:	mov    r13,rsi
    4706:	test   rax,0x1
    470c:	jne    4732 <botlish_fn_24+0xba>
    4712:	mov    rsi,r13
    4715:	mov    rdi,r12
    4718:	call   471d <botlish_fn_24+0xa5>
			4719: R_X86_64_PLT32	rt_int_cmp-0x4
    471d:	mov    ecx,0x2
    4722:	test   rax,rax
    4725:	cmovge rcx,QWORD PTR [rip+0x113]        # 4840 <botlish_fn_24+0x1c8>
    472d:	jmp    4745 <botlish_fn_24+0xcd>
    4732:	mov    ecx,0x2
    4737:	mov    rsi,r13
    473a:	cmp    rsi,rdx
    473d:	cmovge rcx,QWORD PTR [rip+0xfb]        # 4840 <botlish_fn_24+0x1c8>
    4745:	cmp    rcx,0x6
    4749:	je     4820 <botlish_fn_24+0x1a8>
    474f:	mov    rax,QWORD PTR [rbx+0x20]
    4753:	mov    rsi,QWORD PTR [rax+0x8]
    4757:	mov    QWORD PTR [rsp+0x8],rsi
    475c:	lea    rcx,[rsp+0x18]
    4761:	mov    rdx,r13
    4764:	mov    rdi,r12
    4767:	call   476c <botlish_fn_24+0xf4>
			4768: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    476c:	test   rax,rax
    476f:	mov    rsi,rax
    4772:	je     4793 <botlish_fn_24+0x11b>
    4778:	mov    rdx,QWORD PTR [rsp+0x18]
    477d:	mov    rcx,QWORD PTR [rsp+0x20]
    4782:	mov    rdi,r12
    4785:	call   478a <botlish_fn_24+0x112>
			4786: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    478a:	test   rax,rax
    478d:	jne    47ae <botlish_fn_24+0x136>
    4793:	xor    rax,rax
    4796:	mov    rbx,QWORD PTR [rsp+0x30]
    479b:	mov    r12,QWORD PTR [rsp+0x38]
    47a0:	mov    r13,QWORD PTR [rsp+0x40]
    47a5:	add    rsp,0x50
    47a9:	mov    rsp,rbp
    47ac:	pop    rbp
    47ad:	ret
    47ae:	cmp    rax,0x6
    47b2:	je     47c0 <botlish_fn_24+0x148>
    47b8:	mov    rax,r13
    47bb:	jmp    4823 <botlish_fn_24+0x1ab>
    47c0:	mov    QWORD PTR [rsp+0x8],rbx
    47c5:	mov    QWORD PTR [rsp+0x10],0x3
    47ce:	mov    rsi,r13
    47d1:	test   rsi,0x1
    47d8:	je     47fe <botlish_fn_24+0x186>
    47de:	mov    rsi,r13
    47e1:	mov    rcx,rsi
    47e4:	add    rcx,0x2
    47e8:	seto   al
    47eb:	test   al,al
    47ed:	jne    47fe <botlish_fn_24+0x186>
    47f3:	mov    rsi,rcx
    47f6:	mov    r13,rcx
    47f9:	jmp    4814 <botlish_fn_24+0x19c>
    47fe:	mov    edx,0x3
    4803:	mov    rsi,r13
    4806:	mov    rdi,r12
    4809:	call   480e <botlish_fn_24+0x196>
			480a: R_X86_64_PLT32	rt_int_add-0x4
    480e:	mov    rsi,rax
    4811:	mov    r13,rax
    4814:	mov    QWORD PTR [rsp],rsi
    4818:	mov    rsi,r13
    481b:	jmp    46a5 <botlish_fn_24+0x2d>
    4820:	mov    rax,r13
    4823:	mov    rbx,QWORD PTR [rsp+0x30]
    4828:	mov    r12,QWORD PTR [rsp+0x38]
    482d:	mov    r13,QWORD PTR [rsp+0x40]
    4832:	add    rsp,0x50
    4836:	mov    rsp,rbp
    4839:	pop    rbp
    483a:	ret
    483b:	add    BYTE PTR [rax],al
    483d:	add    BYTE PTR [rax],al
    483f:	add    BYTE PTR [rsi],al
    4841:	add    BYTE PTR [rax],al
    4843:	add    BYTE PTR [rax],al
    4845:	add    BYTE PTR [rax],al
	...

0000000000004848 <botlish_entry_24: scan_alpha<generic>>:
    4848:	push   rbp
    4849:	mov    rbp,rsp
    484c:	mov    rdx,QWORD PTR [rdx]
    484f:	call   4854 <botlish_entry_24+0xc>
			4850: R_X86_64_PLT32	botlish_fn_24-0x4 ; scan_alpha<generic>
    4854:	mov    rsp,rbp
    4857:	pop    rbp
    4858:	ret
    4859:	add    BYTE PTR [rax],al
    485b:	add    BYTE PTR [rax],al
    485d:	add    BYTE PTR [rax],al
	...

0000000000004860 <botlish_fn_25: tld_ok<generic>>:
    4860:	push   rbp
    4861:	mov    rbp,rsp
    4864:	sub    rsp,0x30
    4868:	mov    QWORD PTR [rsp+0x10],rbx
    486d:	mov    QWORD PTR [rsp+0x18],r12
    4872:	mov    QWORD PTR [rsp+0x20],r13
    4877:	mov    QWORD PTR [rsp+0x28],r14
    487c:	mov    r12,rdi
    487f:	mov    QWORD PTR [rsp],rdx
    4883:	mov    r9,rdx
    4886:	mov    rax,QWORD PTR [rsi+0x20]
    488a:	mov    r14,rsi
    488d:	mov    rsi,QWORD PTR [rax]
    4890:	mov    QWORD PTR [rsp+0x8],rsi
    4895:	mov    rbx,r9
    4898:	mov    rdx,rbx
    489b:	mov    rdi,r12
    489e:	call   48a3 <botlish_fn_25+0x43>
			489f: R_X86_64_PLT32	botlish_fn_24-0x4 ; scan_alpha<generic>
    48a3:	mov    rsi,rax
    48a6:	mov    r13,rax
    48a9:	test   rax,rsi
    48ac:	je     4984 <botlish_fn_25+0x124>
    48b2:	mov    rax,r13
    48b5:	mov    QWORD PTR [rsp+0x8],rax
    48ba:	mov    rsi,r14
    48bd:	mov    rax,QWORD PTR [rsi+0x20]
    48c1:	mov    rdx,QWORD PTR [rax+0x8]
    48c5:	mov    rax,r13
    48c8:	and    rax,rdx
    48cb:	test   rax,0x1
    48d1:	jne    48fa <botlish_fn_25+0x9a>
    48d7:	mov    rsi,r13
    48da:	mov    rdi,r12
    48dd:	call   48e2 <botlish_fn_25+0x82>
			48de: R_X86_64_PLT32	rt_int_cmp-0x4
    48e2:	mov    ecx,0x2
    48e7:	test   rax,rax
    48ea:	cmove  rcx,QWORD PTR [rip+0x166]        # 4a58 <botlish_fn_25+0x1f8>
    48f2:	mov    rax,r13
    48f5:	jmp    490d <botlish_fn_25+0xad>
    48fa:	mov    ecx,0x2
    48ff:	mov    rax,r13
    4902:	cmp    rax,rdx
    4905:	cmove  rcx,QWORD PTR [rip+0x14b]        # 4a58 <botlish_fn_25+0x1f8>
    490d:	cmp    rcx,0x6
    4911:	je     4924 <botlish_fn_25+0xc4>
    4917:	mov    ecx,0x2
    491c:	mov    rax,rcx
    491f:	jmp    4a34 <botlish_fn_25+0x1d4>
    4924:	mov    ecx,0x1
    4929:	test   rbx,0x1
    4930:	je     493e <botlish_fn_25+0xde>
    4936:	mov    r9,rbx
    4939:	jmp    4963 <botlish_fn_25+0x103>
    493e:	xor    ecx,ecx
    4940:	test   rbx,0x7
    4947:	je     4955 <botlish_fn_25+0xf5>
    494d:	mov    r9,rbx
    4950:	jmp    4963 <botlish_fn_25+0x103>
    4955:	movzx  rdx,BYTE PTR [rbx]
    4959:	mov    r9,rbx
    495c:	rex cmp dl,0x1
    4960:	sete   cl
    4963:	test   cl,cl
    4965:	jne    49a4 <botlish_fn_25+0x144>
    496b:	mov    rdi,r12
    496e:	mov    rsi,QWORD PTR [rdi+0x10]
    4972:	mov    rcx,QWORD PTR [rsi+0x128]
    4979:	xor    rdx,rdx
    497c:	mov    rsi,r9
    497f:	call   4984 <botlish_fn_25+0x124>
			4980: R_X86_64_PLT32	rt_type_error-0x4
    4984:	xor    rax,rax
    4987:	mov    rbx,QWORD PTR [rsp+0x10]
    498c:	mov    r12,QWORD PTR [rsp+0x18]
    4991:	mov    r13,QWORD PTR [rsp+0x20]
    4996:	mov    r14,QWORD PTR [rsp+0x28]
    499b:	add    rsp,0x30
    499f:	mov    rsp,rbp
    49a2:	pop    rbp
    49a3:	ret
    49a4:	mov    rbx,r9
    49a7:	mov    r8,rax
    49aa:	and    r8,rbx
    49ad:	test   r8,0x1
    49b4:	jne    49c5 <botlish_fn_25+0x165>
    49ba:	mov    rdx,r9
    49bd:	mov    rsi,rax
    49c0:	jmp    49e6 <botlish_fn_25+0x186>
    49c5:	mov    rbx,r9
    49c8:	mov    r10,rax
    49cb:	sub    r10,rbx
    49ce:	mov    r13,rax
    49d1:	seto   al
    49d4:	lea    rsi,[r10+0x1]
    49d8:	test   al,al
    49da:	je     49f1 <botlish_fn_25+0x191>
    49e0:	mov    rdx,r9
    49e3:	mov    rsi,r13
    49e6:	mov    rdi,r12
    49e9:	call   49ee <botlish_fn_25+0x18e>
			49ea: R_X86_64_PLT32	rt_int_sub-0x4
    49ee:	mov    rsi,rax
    49f1:	test   rsi,0x1
    49f8:	jne    4a23 <botlish_fn_25+0x1c3>
    49fe:	mov    edx,0x5
    4a03:	mov    rdi,r12
    4a06:	call   4a0b <botlish_fn_25+0x1ab>
			4a07: R_X86_64_PLT32	rt_int_cmp-0x4
    4a0b:	mov    ecx,0x2
    4a10:	test   rax,rax
    4a13:	mov    rax,rcx
    4a16:	cmovge rax,QWORD PTR [rip+0x3a]        # 4a58 <botlish_fn_25+0x1f8>
    4a1e:	jmp    4a34 <botlish_fn_25+0x1d4>
    4a23:	mov    eax,0x2
    4a28:	cmp    rsi,0x5
    4a2c:	cmovge rax,QWORD PTR [rip+0x24]        # 4a58 <botlish_fn_25+0x1f8>
    4a34:	mov    rbx,QWORD PTR [rsp+0x10]
    4a39:	mov    r12,QWORD PTR [rsp+0x18]
    4a3e:	mov    r13,QWORD PTR [rsp+0x20]
    4a43:	mov    r14,QWORD PTR [rsp+0x28]
    4a48:	add    rsp,0x30
    4a4c:	mov    rsp,rbp
    4a4f:	pop    rbp
    4a50:	ret
    4a51:	add    BYTE PTR [rax],al
    4a53:	add    BYTE PTR [rax],al
    4a55:	add    BYTE PTR [rax],al
    4a57:	add    BYTE PTR [rsi],al
    4a59:	add    BYTE PTR [rax],al
    4a5b:	add    BYTE PTR [rax],al
    4a5d:	add    BYTE PTR [rax],al
	...

0000000000004a60 <botlish_entry_25: tld_ok<generic>>:
    4a60:	push   rbp
    4a61:	mov    rbp,rsp
    4a64:	mov    rdx,QWORD PTR [rdx]
    4a67:	call   4a6c <botlish_entry_25+0xc>
			4a68: R_X86_64_PLT32	botlish_fn_25-0x4 ; tld_ok<generic>
    4a6c:	mov    rsp,rbp
    4a6f:	pop    rbp
    4a70:	ret
    4a71:	add    BYTE PTR [rax],al
    4a73:	add    BYTE PTR [rax],al
    4a75:	add    BYTE PTR [rax],al
	...

0000000000004a78 <botlish_fn_26: domain_loop<generic>>:
    4a78:	push   rbp
    4a79:	mov    rbp,rsp
    4a7c:	sub    rsp,0x50
    4a80:	mov    QWORD PTR [rsp+0x20],rbx
    4a85:	mov    QWORD PTR [rsp+0x28],r12
    4a8a:	mov    QWORD PTR [rsp+0x30],r13
    4a8f:	mov    QWORD PTR [rsp+0x38],r14
    4a94:	mov    QWORD PTR [rsp+0x40],r15
    4a99:	mov    QWORD PTR [rsp],rdx
    4a9d:	mov    r15,rdx
    4aa0:	lea    r13,[rsp+0x10]
    4aa5:	mov    rbx,rsi
    4aa8:	mov    rax,QWORD PTR [rbx+0x20]
    4aac:	mov    rsi,QWORD PTR [rax]
    4aaf:	mov    QWORD PTR [rsp+0x8],rsi
    4ab4:	mov    r12,rdi
    4ab7:	mov    rdx,r15
    4aba:	call   4abf <botlish_fn_26+0x47>
			4abb: R_X86_64_PLT32	botlish_fn_23-0x4 ; scan_label<generic>
    4abf:	mov    r10,rax
    4ac2:	mov    r14,rax
    4ac5:	test   rax,r10
    4ac8:	je     4c3e <botlish_fn_26+0x1c6>
    4ace:	mov    rax,r14
    4ad1:	mov    QWORD PTR [rsp],rax
    4ad5:	mov    rdx,r15
    4ad8:	and    rax,rdx
    4adb:	test   rax,0x1
    4ae1:	jne    4b03 <botlish_fn_26+0x8b>
    4ae7:	mov    rdx,r15
    4aea:	mov    rsi,r14
    4aed:	mov    rdi,r12
    4af0:	call   4af5 <botlish_fn_26+0x7d>
			4af1: R_X86_64_PLT32	rt_value_eq-0x4
    4af5:	test   rax,rax
    4af8:	je     4c3e <botlish_fn_26+0x1c6>
    4afe:	jmp    4b16 <botlish_fn_26+0x9e>
    4b03:	mov    eax,0x2
    4b08:	mov    rdx,r15
    4b0b:	cmp    r14,rdx
    4b0e:	cmove  rax,QWORD PTR [rip+0x1aa]        # 4cc0 <botlish_fn_26+0x248>
    4b16:	cmp    rax,0x6
    4b1a:	je     4c95 <botlish_fn_26+0x21d>
    4b20:	mov    rdx,QWORD PTR [rbx+0x20]
    4b24:	mov    rdx,QWORD PTR [rdx+0x8]
    4b28:	mov    rsi,r14
    4b2b:	and    rsi,rdx
    4b2e:	test   rsi,0x1
    4b35:	jne    4b5b <botlish_fn_26+0xe3>
    4b3b:	mov    rsi,r14
    4b3e:	mov    rdi,r12
    4b41:	call   4b46 <botlish_fn_26+0xce>
			4b42: R_X86_64_PLT32	rt_int_cmp-0x4
    4b46:	mov    ecx,0x2
    4b4b:	test   rax,rax
    4b4e:	cmovge rcx,QWORD PTR [rip+0x16a]        # 4cc0 <botlish_fn_26+0x248>
    4b56:	jmp    4b6b <botlish_fn_26+0xf3>
    4b5b:	mov    ecx,0x2
    4b60:	cmp    r14,rdx
    4b63:	cmovge rcx,QWORD PTR [rip+0x155]        # 4cc0 <botlish_fn_26+0x248>
    4b6b:	cmp    rcx,0x6
    4b6f:	je     4c89 <botlish_fn_26+0x211>
    4b75:	mov    r10,QWORD PTR [rbx+0x20]
    4b79:	mov    rsi,QWORD PTR [r10+0x10]
    4b7d:	mov    QWORD PTR [rsp+0x8],rsi
    4b82:	mov    rcx,r13
    4b85:	mov    rdx,r14
    4b88:	mov    rdi,r12
    4b8b:	call   4b90 <botlish_fn_26+0x118>
			4b8c: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    4b90:	test   rax,rax
    4b93:	mov    rsi,rax
    4b96:	je     4c3e <botlish_fn_26+0x1c6>
    4b9c:	mov    rdx,QWORD PTR [rsp+0x10]
    4ba1:	mov    rcx,QWORD PTR [rsp+0x18]
    4ba6:	mov    rax,QWORD PTR [r12+0x10]
    4bab:	mov    r8,QWORD PTR [rax+0x118]
    4bb2:	mov    rdi,r12
    4bb5:	call   4bba <botlish_fn_26+0x142>
			4bb6: R_X86_64_PLT32	rt_str_region_eq-0x4
    4bba:	cmp    rax,0x6
    4bbe:	je     4bd0 <botlish_fn_26+0x158>
    4bc4:	mov    rax,0xffffffffffffffff
    4bcb:	jmp    4c9c <botlish_fn_26+0x224>
    4bd0:	mov    QWORD PTR [rsp+0x8],0x3
    4bd9:	test   r14,0x1
    4be0:	je     4c03 <botlish_fn_26+0x18b>
    4be6:	mov    rdx,r14
    4be9:	add    rdx,0x2
    4bed:	mov    r15,rdx
    4bf0:	seto   al
    4bf3:	test   al,al
    4bf5:	jne    4c03 <botlish_fn_26+0x18b>
    4bfb:	mov    rdx,r15
    4bfe:	jmp    4c19 <botlish_fn_26+0x1a1>
    4c03:	mov    edx,0x3
    4c08:	mov    rsi,r14
    4c0b:	mov    rdi,r12
    4c0e:	call   4c13 <botlish_fn_26+0x19b>
			4c0f: R_X86_64_PLT32	rt_int_add-0x4
    4c13:	mov    rdx,rax
    4c16:	mov    r15,rax
    4c19:	mov    QWORD PTR [rsp],rdx
    4c1d:	mov    rax,QWORD PTR [rbx+0x20]
    4c21:	mov    rsi,QWORD PTR [rax+0x18]
    4c25:	mov    QWORD PTR [rsp+0x8],rsi
    4c2a:	mov    rdx,r15
    4c2d:	mov    rdi,r12
    4c30:	call   4c35 <botlish_fn_26+0x1bd>
			4c31: R_X86_64_PLT32	botlish_fn_25-0x4 ; tld_ok<generic>
    4c35:	test   rax,rax
    4c38:	jne    4c63 <botlish_fn_26+0x1eb>
    4c3e:	xor    rax,rax
    4c41:	mov    rbx,QWORD PTR [rsp+0x20]
    4c46:	mov    r12,QWORD PTR [rsp+0x28]
    4c4b:	mov    r13,QWORD PTR [rsp+0x30]
    4c50:	mov    r14,QWORD PTR [rsp+0x38]
    4c55:	mov    r15,QWORD PTR [rsp+0x40]
    4c5a:	add    rsp,0x50
    4c5e:	mov    rsp,rbp
    4c61:	pop    rbp
    4c62:	ret
    4c63:	cmp    rax,0x6
    4c67:	je     4c7c <botlish_fn_26+0x204>
    4c6d:	mov    rdx,r15
    4c70:	mov    QWORD PTR [rsp],rdx
    4c74:	mov    rdi,r12
    4c77:	jmp    4aa8 <botlish_fn_26+0x30>
    4c7c:	mov    rax,QWORD PTR [rbx+0x20]
    4c80:	mov    rax,QWORD PTR [rax+0x8]
    4c84:	jmp    4c9c <botlish_fn_26+0x224>
    4c89:	mov    rax,0xffffffffffffffff
    4c90:	jmp    4c9c <botlish_fn_26+0x224>
    4c95:	mov    rax,0xffffffffffffffff
    4c9c:	mov    rbx,QWORD PTR [rsp+0x20]
    4ca1:	mov    r12,QWORD PTR [rsp+0x28]
    4ca6:	mov    r13,QWORD PTR [rsp+0x30]
    4cab:	mov    r14,QWORD PTR [rsp+0x38]
    4cb0:	mov    r15,QWORD PTR [rsp+0x40]
    4cb5:	add    rsp,0x50
    4cb9:	mov    rsp,rbp
    4cbc:	pop    rbp
    4cbd:	ret
    4cbe:	add    BYTE PTR [rax],al
    4cc0:	(bad)
    4cc1:	add    BYTE PTR [rax],al
    4cc3:	add    BYTE PTR [rax],al
    4cc5:	add    BYTE PTR [rax],al
	...

0000000000004cc8 <botlish_entry_26: domain_loop<generic>>:
    4cc8:	push   rbp
    4cc9:	mov    rbp,rsp
    4ccc:	mov    rdx,QWORD PTR [rdx]
    4ccf:	call   4cd4 <botlish_entry_26+0xc>
			4cd0: R_X86_64_PLT32	botlish_fn_26-0x4 ; domain_loop<generic>
    4cd4:	mov    rsp,rbp
    4cd7:	pop    rbp
    4cd8:	ret

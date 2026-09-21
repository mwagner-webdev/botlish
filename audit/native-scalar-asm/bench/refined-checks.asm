; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 20986  (per function: 935 365 1713 1425 527 932 541 988 504 1185 1225 427 456 401 165 489 489 497 553 641 1185 1225 427 456 401 165 489 489 497 553 641)
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
			1c36: R_X86_64_PLT32	botlish_fn_20-0x4 ; <str>
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
    1df7:	mov    esi,0xf
    1dfc:	mov    rdx,QWORD PTR [rip+0x0]        # 1e03 <botlish_fn_9+0xc3>
			1dff: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_local<generic>
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
    1e36:	mov    esi,0x10
    1e3b:	mov    rdx,QWORD PTR [rip+0x0]        # 1e42 <botlish_fn_9+0x102>
			1e3e: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; scan_label<generic>
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
    1e71:	mov    esi,0x11
    1e76:	mov    rdx,QWORD PTR [rip+0x0]        # 1e7d <botlish_fn_9+0x13d>
			1e79: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; scan_alpha<generic>
    1e7d:	mov    rcx,r13
    1e80:	mov    rdi,r15
    1e83:	call   1e88 <botlish_fn_9+0x148>
			1e84: R_X86_64_PLT32	rt_closure_new-0x4
    1e88:	mov    QWORD PTR [rsp+0x20],rax
    1e8d:	lea    r8,[rsp+0x60]
    1e92:	mov    QWORD PTR [rsp+0x60],rax
    1e97:	mov    rax,QWORD PTR [rsp+0xa8]
    1e9f:	mov    QWORD PTR [rsp+0x68],rax
    1ea4:	mov    esi,0x12
    1ea9:	mov    rdx,QWORD PTR [rip+0x0]        # 1eb0 <botlish_fn_9+0x170>
			1eac: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; tld_ok<generic>
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
    1eef:	mov    esi,0x13
    1ef4:	mov    rdx,QWORD PTR [rip+0x0]        # 1efb <botlish_fn_9+0x1bb>
			1ef7: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; domain_loop<generic>
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
			1f23: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
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
			2084: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
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
    227c:	mov    esi,0xf
    2281:	mov    rdx,QWORD PTR [rip+0x0]        # 2288 <botlish_fn_10+0xf8>
			2284: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_local<generic>
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
    22b6:	mov    esi,0x10
    22bb:	mov    rdx,QWORD PTR [rip+0x0]        # 22c2 <botlish_fn_10+0x132>
			22be: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; scan_label<generic>
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
    22ec:	mov    esi,0x11
    22f1:	mov    rdx,QWORD PTR [rip+0x0]        # 22f8 <botlish_fn_10+0x168>
			22f4: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; scan_alpha<generic>
    22f8:	mov    rcx,r12
    22fb:	mov    rdi,r15
    22fe:	call   2303 <botlish_fn_10+0x173>
			22ff: R_X86_64_PLT32	rt_closure_new-0x4
    2303:	mov    QWORD PTR [rsp+0x20],rax
    2308:	lea    r8,[rsp+0x60]
    230d:	mov    QWORD PTR [rsp+0x60],rax
    2312:	mov    rax,r14
    2315:	mov    QWORD PTR [rsp+0x68],rax
    231a:	mov    esi,0x12
    231f:	mov    rdx,QWORD PTR [rip+0x0]        # 2326 <botlish_fn_10+0x196>
			2322: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; tld_ok<generic>
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
    2360:	mov    esi,0x13
    2365:	mov    rdx,QWORD PTR [rip+0x0]        # 236c <botlish_fn_10+0x1dc>
			2368: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; domain_loop<generic>
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
			239e: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
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
			2501: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
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

0000000000002930 <botlish_fn_13: is_local_char<str>>:
    2930:	push   rbp
    2931:	mov    rbp,rsp
    2934:	sub    rsp,0x10
    2938:	mov    QWORD PTR [rsp],rbx
    293c:	mov    QWORD PTR [rsp+0x8],r12
    2941:	mov    rbx,rsi
    2944:	mov    r12,rdi
    2947:	mov    rsi,rbx
    294a:	mov    rdi,r12
    294d:	call   2952 <botlish_fn_13+0x22>
			294e: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    2952:	test   rax,rax
    2955:	jne    2970 <botlish_fn_13+0x40>
    295b:	xor    rax,rax
    295e:	mov    rbx,QWORD PTR [rsp]
    2962:	mov    r12,QWORD PTR [rsp+0x8]
    2967:	add    rsp,0x10
    296b:	mov    rsp,rbp
    296e:	pop    rbp
    296f:	ret
    2970:	cmp    rax,0x6
    2974:	je     2a6f <botlish_fn_13+0x13f>
    297a:	mov    rdi,r12
    297d:	mov    rax,QWORD PTR [rdi+0x10]
    2981:	mov    rsi,QWORD PTR [rax+0x118]
    2988:	mov    edx,0x1
    298d:	mov    ecx,0x3
    2992:	mov    r8,rbx
    2995:	call   299a <botlish_fn_13+0x6a>
			2996: R_X86_64_PLT32	rt_str_region_eq-0x4
    299a:	cmp    rax,0x6
    299e:	je     2a65 <botlish_fn_13+0x135>
    29a4:	mov    rdi,r12
    29a7:	mov    rax,QWORD PTR [rdi+0x10]
    29ab:	mov    rsi,QWORD PTR [rax+0x120]
    29b2:	mov    edx,0x1
    29b7:	mov    ecx,0x3
    29bc:	mov    r8,rbx
    29bf:	call   29c4 <botlish_fn_13+0x94>
			29c0: R_X86_64_PLT32	rt_str_region_eq-0x4
    29c4:	cmp    rax,0x6
    29c8:	je     2a5b <botlish_fn_13+0x12b>
    29ce:	mov    rdi,r12
    29d1:	mov    rax,QWORD PTR [rdi+0x10]
    29d5:	mov    rsi,QWORD PTR [rax+0xc0]
    29dc:	mov    edx,0x1
    29e1:	mov    ecx,0x3
    29e6:	mov    r8,rbx
    29e9:	call   29ee <botlish_fn_13+0xbe>
			29ea: R_X86_64_PLT32	rt_str_region_eq-0x4
    29ee:	cmp    rax,0x6
    29f2:	je     2a51 <botlish_fn_13+0x121>
    29f8:	mov    rdi,r12
    29fb:	mov    rax,QWORD PTR [rdi+0x10]
    29ff:	mov    rsi,QWORD PTR [rax+0x108]
    2a06:	mov    edx,0x1
    2a0b:	mov    ecx,0x3
    2a10:	mov    r8,rbx
    2a13:	call   2a18 <botlish_fn_13+0xe8>
			2a14: R_X86_64_PLT32	rt_str_region_eq-0x4
    2a18:	cmp    rax,0x6
    2a1c:	je     2a47 <botlish_fn_13+0x117>
    2a22:	mov    rdi,r12
    2a25:	mov    rax,QWORD PTR [rdi+0x10]
    2a29:	mov    rsi,QWORD PTR [rax+0x128]
    2a30:	mov    edx,0x1
    2a35:	mov    ecx,0x3
    2a3a:	mov    r8,rbx
    2a3d:	call   2a42 <botlish_fn_13+0x112>
			2a3e: R_X86_64_PLT32	rt_str_region_eq-0x4
    2a42:	jmp    2a74 <botlish_fn_13+0x144>
    2a47:	mov    eax,0x6
    2a4c:	jmp    2a74 <botlish_fn_13+0x144>
    2a51:	mov    eax,0x6
    2a56:	jmp    2a74 <botlish_fn_13+0x144>
    2a5b:	mov    eax,0x6
    2a60:	jmp    2a74 <botlish_fn_13+0x144>
    2a65:	mov    eax,0x6
    2a6a:	jmp    2a74 <botlish_fn_13+0x144>
    2a6f:	mov    eax,0x6
    2a74:	mov    rbx,QWORD PTR [rsp]
    2a78:	mov    r12,QWORD PTR [rsp+0x8]
    2a7d:	add    rsp,0x10
    2a81:	mov    rsp,rbp
    2a84:	pop    rbp
    2a85:	ret

0000000000002a86 <botlish_entry_13: is_local_char<str>>:
    2a86:	push   rbp
    2a87:	mov    rbp,rsp
    2a8a:	mov    rsi,QWORD PTR [rdx]
    2a8d:	call   2a92 <botlish_entry_13+0xc>
			2a8e: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_local_char<str>
    2a92:	mov    rsp,rbp
    2a95:	pop    rbp
    2a96:	ret

0000000000002a97 <botlish_fn_14: is_label_char<str>>:
    2a97:	push   rbp
    2a98:	mov    rbp,rsp
    2a9b:	sub    rsp,0x10
    2a9f:	mov    QWORD PTR [rsp],r13
    2aa3:	mov    QWORD PTR [rsp+0x8],r15
    2aa8:	mov    r13,rsi
    2aab:	mov    r15,rdi
    2aae:	mov    rsi,r13
    2ab1:	mov    rdi,r15
    2ab4:	call   2ab9 <botlish_fn_14+0x22>
			2ab5: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    2ab9:	test   rax,rax
    2abc:	jne    2ad7 <botlish_fn_14+0x40>
    2ac2:	xor    rax,rax
    2ac5:	mov    r13,QWORD PTR [rsp]
    2ac9:	mov    r15,QWORD PTR [rsp+0x8]
    2ace:	add    rsp,0x10
    2ad2:	mov    rsp,rbp
    2ad5:	pop    rbp
    2ad6:	ret
    2ad7:	cmp    rax,0x6
    2adb:	je     2b06 <botlish_fn_14+0x6f>
    2ae1:	mov    rdi,r15
    2ae4:	mov    rax,QWORD PTR [rdi+0x10]
    2ae8:	mov    rsi,QWORD PTR [rax+0x128]
    2aef:	mov    edx,0x1
    2af4:	mov    ecx,0x3
    2af9:	mov    r8,r13
    2afc:	call   2b01 <botlish_fn_14+0x6a>
			2afd: R_X86_64_PLT32	rt_str_region_eq-0x4
    2b01:	jmp    2b0b <botlish_fn_14+0x74>
    2b06:	mov    eax,0x6
    2b0b:	mov    r13,QWORD PTR [rsp]
    2b0f:	mov    r15,QWORD PTR [rsp+0x8]
    2b14:	add    rsp,0x10
    2b18:	mov    rsp,rbp
    2b1b:	pop    rbp
    2b1c:	ret

0000000000002b1d <botlish_entry_14: is_label_char<str>>:
    2b1d:	push   rbp
    2b1e:	mov    rbp,rsp
    2b21:	mov    rsi,QWORD PTR [rdx]
    2b24:	call   2b29 <botlish_entry_14+0xc>
			2b25: R_X86_64_PLT32	botlish_fn_14-0x4 ; is_label_char<str>
    2b29:	mov    rsp,rbp
    2b2c:	pop    rbp
    2b2d:	ret
	...

0000000000002b30 <botlish_fn_15: scan_local<generic>>:
    2b30:	push   rbp
    2b31:	mov    rbp,rsp
    2b34:	sub    rsp,0x40
    2b38:	mov    QWORD PTR [rsp+0x20],rbx
    2b3d:	mov    QWORD PTR [rsp+0x28],r12
    2b42:	mov    QWORD PTR [rsp+0x30],r13
    2b47:	mov    r12,rdi
    2b4a:	mov    QWORD PTR [rsp+0x10],0x0
    2b53:	mov    QWORD PTR [rsp],rdx
    2b57:	mov    rbx,rsi
    2b5a:	mov    rsi,rdx
    2b5d:	mov    rax,QWORD PTR [rbx+0x20]
    2b61:	mov    rdx,QWORD PTR [rax]
    2b64:	mov    r10d,0x1
    2b6a:	test   rsi,0x1
    2b71:	jne    2b91 <botlish_fn_15+0x61>
    2b77:	xor    r10d,r10d
    2b7a:	test   rsi,0x7
    2b81:	jne    2b91 <botlish_fn_15+0x61>
    2b87:	movzx  rax,BYTE PTR [rsi]
    2b8b:	cmp    al,0x1
    2b8d:	sete   r10b
    2b91:	test   r10b,r10b
    2b94:	jne    2bb5 <botlish_fn_15+0x85>
    2b9a:	mov    rdi,r12
    2b9d:	mov    rax,QWORD PTR [rdi+0x10]
    2ba1:	mov    rcx,QWORD PTR [rax+0xb8]
    2ba8:	xor    rdx,rdx
    2bab:	call   2bb0 <botlish_fn_15+0x80>
			2bac: R_X86_64_PLT32	rt_type_error-0x4
    2bb0:	jmp    2c3c <botlish_fn_15+0x10c>
    2bb5:	mov    rax,rsi
    2bb8:	and    rax,rdx
    2bbb:	mov    r13,rsi
    2bbe:	test   rax,0x1
    2bc4:	jne    2bea <botlish_fn_15+0xba>
    2bca:	mov    rsi,r13
    2bcd:	mov    rdi,r12
    2bd0:	call   2bd5 <botlish_fn_15+0xa5>
			2bd1: R_X86_64_PLT32	rt_int_cmp-0x4
    2bd5:	mov    ecx,0x2
    2bda:	test   rax,rax
    2bdd:	cmovge rcx,QWORD PTR [rip+0x103]        # 2ce8 <botlish_fn_15+0x1b8>
    2be5:	jmp    2bfd <botlish_fn_15+0xcd>
    2bea:	mov    ecx,0x2
    2bef:	mov    rsi,r13
    2bf2:	cmp    rsi,rdx
    2bf5:	cmovge rcx,QWORD PTR [rip+0xeb]        # 2ce8 <botlish_fn_15+0x1b8>
    2bfd:	cmp    rcx,0x6
    2c01:	je     2cc9 <botlish_fn_15+0x199>
    2c07:	mov    rax,QWORD PTR [rbx+0x20]
    2c0b:	mov    rsi,QWORD PTR [rax+0x8]
    2c0f:	mov    QWORD PTR [rsp+0x8],rsi
    2c14:	mov    rdx,r13
    2c17:	mov    rdi,r12
    2c1a:	call   2c1f <botlish_fn_15+0xef>
			2c1b: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2c1f:	test   rax,rax
    2c22:	mov    rsi,rax
    2c25:	je     2c3c <botlish_fn_15+0x10c>
    2c2b:	mov    rdi,r12
    2c2e:	call   2c33 <botlish_fn_15+0x103>
			2c2f: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_local_char<str>
    2c33:	test   rax,rax
    2c36:	jne    2c57 <botlish_fn_15+0x127>
    2c3c:	xor    rax,rax
    2c3f:	mov    rbx,QWORD PTR [rsp+0x20]
    2c44:	mov    r12,QWORD PTR [rsp+0x28]
    2c49:	mov    r13,QWORD PTR [rsp+0x30]
    2c4e:	add    rsp,0x40
    2c52:	mov    rsp,rbp
    2c55:	pop    rbp
    2c56:	ret
    2c57:	cmp    rax,0x6
    2c5b:	je     2c69 <botlish_fn_15+0x139>
    2c61:	mov    rax,r13
    2c64:	jmp    2ccc <botlish_fn_15+0x19c>
    2c69:	mov    QWORD PTR [rsp+0x8],rbx
    2c6e:	mov    QWORD PTR [rsp+0x10],0x3
    2c77:	mov    rsi,r13
    2c7a:	test   rsi,0x1
    2c81:	je     2ca7 <botlish_fn_15+0x177>
    2c87:	mov    rsi,r13
    2c8a:	mov    r11,rsi
    2c8d:	add    r11,0x2
    2c91:	seto   al
    2c94:	test   al,al
    2c96:	jne    2ca7 <botlish_fn_15+0x177>
    2c9c:	mov    rsi,r11
    2c9f:	mov    r13,r11
    2ca2:	jmp    2cbd <botlish_fn_15+0x18d>
    2ca7:	mov    edx,0x3
    2cac:	mov    rsi,r13
    2caf:	mov    rdi,r12
    2cb2:	call   2cb7 <botlish_fn_15+0x187>
			2cb3: R_X86_64_PLT32	rt_int_add-0x4
    2cb7:	mov    rsi,rax
    2cba:	mov    r13,rax
    2cbd:	mov    QWORD PTR [rsp],rsi
    2cc1:	mov    rsi,r13
    2cc4:	jmp    2b5d <botlish_fn_15+0x2d>
    2cc9:	mov    rax,r13
    2ccc:	mov    rbx,QWORD PTR [rsp+0x20]
    2cd1:	mov    r12,QWORD PTR [rsp+0x28]
    2cd6:	mov    r13,QWORD PTR [rsp+0x30]
    2cdb:	add    rsp,0x40
    2cdf:	mov    rsp,rbp
    2ce2:	pop    rbp
    2ce3:	ret
    2ce4:	add    BYTE PTR [rax],al
    2ce6:	add    BYTE PTR [rax],al
    2ce8:	(bad)
    2ce9:	add    BYTE PTR [rax],al
    2ceb:	add    BYTE PTR [rax],al
    2ced:	add    BYTE PTR [rax],al
	...

0000000000002cf0 <botlish_entry_15: scan_local<generic>>:
    2cf0:	push   rbp
    2cf1:	mov    rbp,rsp
    2cf4:	mov    rdx,QWORD PTR [rdx]
    2cf7:	call   2cfc <botlish_entry_15+0xc>
			2cf8: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    2cfc:	mov    rsp,rbp
    2cff:	pop    rbp
    2d00:	ret
    2d01:	add    BYTE PTR [rax],al
    2d03:	add    BYTE PTR [rax],al
    2d05:	add    BYTE PTR [rax],al
	...

0000000000002d08 <botlish_fn_16: scan_label<generic>>:
    2d08:	push   rbp
    2d09:	mov    rbp,rsp
    2d0c:	sub    rsp,0x40
    2d10:	mov    QWORD PTR [rsp+0x20],rbx
    2d15:	mov    QWORD PTR [rsp+0x28],r12
    2d1a:	mov    QWORD PTR [rsp+0x30],r13
    2d1f:	mov    r12,rdi
    2d22:	mov    QWORD PTR [rsp+0x10],0x0
    2d2b:	mov    QWORD PTR [rsp],rdx
    2d2f:	mov    rbx,rsi
    2d32:	mov    rsi,rdx
    2d35:	mov    rax,QWORD PTR [rbx+0x20]
    2d39:	mov    rdx,QWORD PTR [rax]
    2d3c:	mov    r10d,0x1
    2d42:	test   rsi,0x1
    2d49:	jne    2d69 <botlish_fn_16+0x61>
    2d4f:	xor    r10d,r10d
    2d52:	test   rsi,0x7
    2d59:	jne    2d69 <botlish_fn_16+0x61>
    2d5f:	movzx  rax,BYTE PTR [rsi]
    2d63:	cmp    al,0x1
    2d65:	sete   r10b
    2d69:	test   r10b,r10b
    2d6c:	jne    2d8d <botlish_fn_16+0x85>
    2d72:	mov    rdi,r12
    2d75:	mov    rax,QWORD PTR [rdi+0x10]
    2d79:	mov    rcx,QWORD PTR [rax+0xb8]
    2d80:	xor    rdx,rdx
    2d83:	call   2d88 <botlish_fn_16+0x80>
			2d84: R_X86_64_PLT32	rt_type_error-0x4
    2d88:	jmp    2e14 <botlish_fn_16+0x10c>
    2d8d:	mov    rax,rsi
    2d90:	and    rax,rdx
    2d93:	mov    r13,rsi
    2d96:	test   rax,0x1
    2d9c:	jne    2dc2 <botlish_fn_16+0xba>
    2da2:	mov    rsi,r13
    2da5:	mov    rdi,r12
    2da8:	call   2dad <botlish_fn_16+0xa5>
			2da9: R_X86_64_PLT32	rt_int_cmp-0x4
    2dad:	mov    ecx,0x2
    2db2:	test   rax,rax
    2db5:	cmovge rcx,QWORD PTR [rip+0x103]        # 2ec0 <botlish_fn_16+0x1b8>
    2dbd:	jmp    2dd5 <botlish_fn_16+0xcd>
    2dc2:	mov    ecx,0x2
    2dc7:	mov    rsi,r13
    2dca:	cmp    rsi,rdx
    2dcd:	cmovge rcx,QWORD PTR [rip+0xeb]        # 2ec0 <botlish_fn_16+0x1b8>
    2dd5:	cmp    rcx,0x6
    2dd9:	je     2ea1 <botlish_fn_16+0x199>
    2ddf:	mov    rax,QWORD PTR [rbx+0x20]
    2de3:	mov    rsi,QWORD PTR [rax+0x8]
    2de7:	mov    QWORD PTR [rsp+0x8],rsi
    2dec:	mov    rdx,r13
    2def:	mov    rdi,r12
    2df2:	call   2df7 <botlish_fn_16+0xef>
			2df3: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2df7:	test   rax,rax
    2dfa:	mov    rsi,rax
    2dfd:	je     2e14 <botlish_fn_16+0x10c>
    2e03:	mov    rdi,r12
    2e06:	call   2e0b <botlish_fn_16+0x103>
			2e07: R_X86_64_PLT32	botlish_fn_14-0x4 ; is_label_char<str>
    2e0b:	test   rax,rax
    2e0e:	jne    2e2f <botlish_fn_16+0x127>
    2e14:	xor    rax,rax
    2e17:	mov    rbx,QWORD PTR [rsp+0x20]
    2e1c:	mov    r12,QWORD PTR [rsp+0x28]
    2e21:	mov    r13,QWORD PTR [rsp+0x30]
    2e26:	add    rsp,0x40
    2e2a:	mov    rsp,rbp
    2e2d:	pop    rbp
    2e2e:	ret
    2e2f:	cmp    rax,0x6
    2e33:	je     2e41 <botlish_fn_16+0x139>
    2e39:	mov    rax,r13
    2e3c:	jmp    2ea4 <botlish_fn_16+0x19c>
    2e41:	mov    QWORD PTR [rsp+0x8],rbx
    2e46:	mov    QWORD PTR [rsp+0x10],0x3
    2e4f:	mov    rsi,r13
    2e52:	test   rsi,0x1
    2e59:	je     2e7f <botlish_fn_16+0x177>
    2e5f:	mov    rsi,r13
    2e62:	mov    r11,rsi
    2e65:	add    r11,0x2
    2e69:	seto   al
    2e6c:	test   al,al
    2e6e:	jne    2e7f <botlish_fn_16+0x177>
    2e74:	mov    rsi,r11
    2e77:	mov    r13,r11
    2e7a:	jmp    2e95 <botlish_fn_16+0x18d>
    2e7f:	mov    edx,0x3
    2e84:	mov    rsi,r13
    2e87:	mov    rdi,r12
    2e8a:	call   2e8f <botlish_fn_16+0x187>
			2e8b: R_X86_64_PLT32	rt_int_add-0x4
    2e8f:	mov    rsi,rax
    2e92:	mov    r13,rax
    2e95:	mov    QWORD PTR [rsp],rsi
    2e99:	mov    rsi,r13
    2e9c:	jmp    2d35 <botlish_fn_16+0x2d>
    2ea1:	mov    rax,r13
    2ea4:	mov    rbx,QWORD PTR [rsp+0x20]
    2ea9:	mov    r12,QWORD PTR [rsp+0x28]
    2eae:	mov    r13,QWORD PTR [rsp+0x30]
    2eb3:	add    rsp,0x40
    2eb7:	mov    rsp,rbp
    2eba:	pop    rbp
    2ebb:	ret
    2ebc:	add    BYTE PTR [rax],al
    2ebe:	add    BYTE PTR [rax],al
    2ec0:	(bad)
    2ec1:	add    BYTE PTR [rax],al
    2ec3:	add    BYTE PTR [rax],al
    2ec5:	add    BYTE PTR [rax],al
	...

0000000000002ec8 <botlish_entry_16: scan_label<generic>>:
    2ec8:	push   rbp
    2ec9:	mov    rbp,rsp
    2ecc:	mov    rdx,QWORD PTR [rdx]
    2ecf:	call   2ed4 <botlish_entry_16+0xc>
			2ed0: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_label<generic>
    2ed4:	mov    rsp,rbp
    2ed7:	pop    rbp
    2ed8:	ret
    2ed9:	add    BYTE PTR [rax],al
    2edb:	add    BYTE PTR [rax],al
    2edd:	add    BYTE PTR [rax],al
	...

0000000000002ee0 <botlish_fn_17: scan_alpha<generic>>:
    2ee0:	push   rbp
    2ee1:	mov    rbp,rsp
    2ee4:	sub    rsp,0x40
    2ee8:	mov    QWORD PTR [rsp+0x20],rbx
    2eed:	mov    QWORD PTR [rsp+0x28],r12
    2ef2:	mov    QWORD PTR [rsp+0x30],r13
    2ef7:	mov    r12,rdi
    2efa:	mov    QWORD PTR [rsp+0x10],0x0
    2f03:	mov    QWORD PTR [rsp],rdx
    2f07:	mov    rbx,rsi
    2f0a:	mov    rsi,rdx
    2f0d:	mov    rax,QWORD PTR [rbx+0x20]
    2f11:	mov    rdx,QWORD PTR [rax]
    2f14:	mov    r10d,0x1
    2f1a:	test   rsi,0x1
    2f21:	jne    2f41 <botlish_fn_17+0x61>
    2f27:	xor    r10d,r10d
    2f2a:	test   rsi,0x7
    2f31:	jne    2f41 <botlish_fn_17+0x61>
    2f37:	movzx  rax,BYTE PTR [rsi]
    2f3b:	cmp    al,0x1
    2f3d:	sete   r10b
    2f41:	test   r10b,r10b
    2f44:	jne    2f65 <botlish_fn_17+0x85>
    2f4a:	mov    rdi,r12
    2f4d:	mov    rax,QWORD PTR [rdi+0x10]
    2f51:	mov    rcx,QWORD PTR [rax+0xb8]
    2f58:	xor    rdx,rdx
    2f5b:	call   2f60 <botlish_fn_17+0x80>
			2f5c: R_X86_64_PLT32	rt_type_error-0x4
    2f60:	jmp    2fec <botlish_fn_17+0x10c>
    2f65:	mov    rax,rsi
    2f68:	and    rax,rdx
    2f6b:	mov    r13,rsi
    2f6e:	test   rax,0x1
    2f74:	jne    2f9a <botlish_fn_17+0xba>
    2f7a:	mov    rsi,r13
    2f7d:	mov    rdi,r12
    2f80:	call   2f85 <botlish_fn_17+0xa5>
			2f81: R_X86_64_PLT32	rt_int_cmp-0x4
    2f85:	mov    ecx,0x2
    2f8a:	test   rax,rax
    2f8d:	cmovge rcx,QWORD PTR [rip+0x103]        # 3098 <botlish_fn_17+0x1b8>
    2f95:	jmp    2fad <botlish_fn_17+0xcd>
    2f9a:	mov    ecx,0x2
    2f9f:	mov    rsi,r13
    2fa2:	cmp    rsi,rdx
    2fa5:	cmovge rcx,QWORD PTR [rip+0xeb]        # 3098 <botlish_fn_17+0x1b8>
    2fad:	cmp    rcx,0x6
    2fb1:	je     3079 <botlish_fn_17+0x199>
    2fb7:	mov    rax,QWORD PTR [rbx+0x20]
    2fbb:	mov    rsi,QWORD PTR [rax+0x8]
    2fbf:	mov    QWORD PTR [rsp+0x8],rsi
    2fc4:	mov    rdx,r13
    2fc7:	mov    rdi,r12
    2fca:	call   2fcf <botlish_fn_17+0xef>
			2fcb: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2fcf:	test   rax,rax
    2fd2:	mov    rsi,rax
    2fd5:	je     2fec <botlish_fn_17+0x10c>
    2fdb:	mov    rdi,r12
    2fde:	call   2fe3 <botlish_fn_17+0x103>
			2fdf: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    2fe3:	test   rax,rax
    2fe6:	jne    3007 <botlish_fn_17+0x127>
    2fec:	xor    rax,rax
    2fef:	mov    rbx,QWORD PTR [rsp+0x20]
    2ff4:	mov    r12,QWORD PTR [rsp+0x28]
    2ff9:	mov    r13,QWORD PTR [rsp+0x30]
    2ffe:	add    rsp,0x40
    3002:	mov    rsp,rbp
    3005:	pop    rbp
    3006:	ret
    3007:	cmp    rax,0x6
    300b:	je     3019 <botlish_fn_17+0x139>
    3011:	mov    rax,r13
    3014:	jmp    307c <botlish_fn_17+0x19c>
    3019:	mov    QWORD PTR [rsp+0x8],rbx
    301e:	mov    QWORD PTR [rsp+0x10],0x3
    3027:	mov    rsi,r13
    302a:	test   rsi,0x1
    3031:	je     3057 <botlish_fn_17+0x177>
    3037:	mov    rsi,r13
    303a:	mov    r11,rsi
    303d:	add    r11,0x2
    3041:	seto   al
    3044:	test   al,al
    3046:	jne    3057 <botlish_fn_17+0x177>
    304c:	mov    rsi,r11
    304f:	mov    r13,r11
    3052:	jmp    306d <botlish_fn_17+0x18d>
    3057:	mov    edx,0x3
    305c:	mov    rsi,r13
    305f:	mov    rdi,r12
    3062:	call   3067 <botlish_fn_17+0x187>
			3063: R_X86_64_PLT32	rt_int_add-0x4
    3067:	mov    rsi,rax
    306a:	mov    r13,rax
    306d:	mov    QWORD PTR [rsp],rsi
    3071:	mov    rsi,r13
    3074:	jmp    2f0d <botlish_fn_17+0x2d>
    3079:	mov    rax,r13
    307c:	mov    rbx,QWORD PTR [rsp+0x20]
    3081:	mov    r12,QWORD PTR [rsp+0x28]
    3086:	mov    r13,QWORD PTR [rsp+0x30]
    308b:	add    rsp,0x40
    308f:	mov    rsp,rbp
    3092:	pop    rbp
    3093:	ret
    3094:	add    BYTE PTR [rax],al
    3096:	add    BYTE PTR [rax],al
    3098:	(bad)
    3099:	add    BYTE PTR [rax],al
    309b:	add    BYTE PTR [rax],al
    309d:	add    BYTE PTR [rax],al
	...

00000000000030a0 <botlish_entry_17: scan_alpha<generic>>:
    30a0:	push   rbp
    30a1:	mov    rbp,rsp
    30a4:	mov    rdx,QWORD PTR [rdx]
    30a7:	call   30ac <botlish_entry_17+0xc>
			30a8: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_alpha<generic>
    30ac:	mov    rsp,rbp
    30af:	pop    rbp
    30b0:	ret
    30b1:	add    BYTE PTR [rax],al
    30b3:	add    BYTE PTR [rax],al
    30b5:	add    BYTE PTR [rax],al
	...

00000000000030b8 <botlish_fn_18: tld_ok<generic>>:
    30b8:	push   rbp
    30b9:	mov    rbp,rsp
    30bc:	sub    rsp,0x30
    30c0:	mov    QWORD PTR [rsp+0x10],rbx
    30c5:	mov    QWORD PTR [rsp+0x18],r12
    30ca:	mov    QWORD PTR [rsp+0x20],r13
    30cf:	mov    QWORD PTR [rsp+0x28],r14
    30d4:	mov    r12,rdi
    30d7:	mov    QWORD PTR [rsp],rdx
    30db:	mov    r9,rdx
    30de:	mov    rax,QWORD PTR [rsi+0x20]
    30e2:	mov    r14,rsi
    30e5:	mov    rsi,QWORD PTR [rax]
    30e8:	mov    QWORD PTR [rsp+0x8],rsi
    30ed:	mov    rbx,r9
    30f0:	mov    rdx,rbx
    30f3:	mov    rdi,r12
    30f6:	call   30fb <botlish_fn_18+0x43>
			30f7: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_alpha<generic>
    30fb:	mov    rsi,rax
    30fe:	mov    r13,rax
    3101:	test   rax,rsi
    3104:	je     31dc <botlish_fn_18+0x124>
    310a:	mov    rax,r13
    310d:	mov    QWORD PTR [rsp+0x8],rax
    3112:	mov    rsi,r14
    3115:	mov    rax,QWORD PTR [rsi+0x20]
    3119:	mov    rdx,QWORD PTR [rax+0x8]
    311d:	mov    rax,r13
    3120:	and    rax,rdx
    3123:	test   rax,0x1
    3129:	jne    3152 <botlish_fn_18+0x9a>
    312f:	mov    rsi,r13
    3132:	mov    rdi,r12
    3135:	call   313a <botlish_fn_18+0x82>
			3136: R_X86_64_PLT32	rt_int_cmp-0x4
    313a:	mov    ecx,0x2
    313f:	test   rax,rax
    3142:	cmove  rcx,QWORD PTR [rip+0x166]        # 32b0 <botlish_fn_18+0x1f8>
    314a:	mov    rax,r13
    314d:	jmp    3165 <botlish_fn_18+0xad>
    3152:	mov    ecx,0x2
    3157:	mov    rax,r13
    315a:	cmp    rax,rdx
    315d:	cmove  rcx,QWORD PTR [rip+0x14b]        # 32b0 <botlish_fn_18+0x1f8>
    3165:	cmp    rcx,0x6
    3169:	je     317c <botlish_fn_18+0xc4>
    316f:	mov    ecx,0x2
    3174:	mov    rax,rcx
    3177:	jmp    328c <botlish_fn_18+0x1d4>
    317c:	mov    ecx,0x1
    3181:	test   rbx,0x1
    3188:	je     3196 <botlish_fn_18+0xde>
    318e:	mov    r9,rbx
    3191:	jmp    31bb <botlish_fn_18+0x103>
    3196:	xor    ecx,ecx
    3198:	test   rbx,0x7
    319f:	je     31ad <botlish_fn_18+0xf5>
    31a5:	mov    r9,rbx
    31a8:	jmp    31bb <botlish_fn_18+0x103>
    31ad:	movzx  rdx,BYTE PTR [rbx]
    31b1:	mov    r9,rbx
    31b4:	rex cmp dl,0x1
    31b8:	sete   cl
    31bb:	test   cl,cl
    31bd:	jne    31fc <botlish_fn_18+0x144>
    31c3:	mov    rdi,r12
    31c6:	mov    rsi,QWORD PTR [rdi+0x10]
    31ca:	mov    rcx,QWORD PTR [rsi+0x128]
    31d1:	xor    rdx,rdx
    31d4:	mov    rsi,r9
    31d7:	call   31dc <botlish_fn_18+0x124>
			31d8: R_X86_64_PLT32	rt_type_error-0x4
    31dc:	xor    rax,rax
    31df:	mov    rbx,QWORD PTR [rsp+0x10]
    31e4:	mov    r12,QWORD PTR [rsp+0x18]
    31e9:	mov    r13,QWORD PTR [rsp+0x20]
    31ee:	mov    r14,QWORD PTR [rsp+0x28]
    31f3:	add    rsp,0x30
    31f7:	mov    rsp,rbp
    31fa:	pop    rbp
    31fb:	ret
    31fc:	mov    rbx,r9
    31ff:	mov    r8,rax
    3202:	and    r8,rbx
    3205:	test   r8,0x1
    320c:	jne    321d <botlish_fn_18+0x165>
    3212:	mov    rdx,r9
    3215:	mov    rsi,rax
    3218:	jmp    323e <botlish_fn_18+0x186>
    321d:	mov    rbx,r9
    3220:	mov    r10,rax
    3223:	sub    r10,rbx
    3226:	mov    r13,rax
    3229:	seto   al
    322c:	lea    rsi,[r10+0x1]
    3230:	test   al,al
    3232:	je     3249 <botlish_fn_18+0x191>
    3238:	mov    rdx,r9
    323b:	mov    rsi,r13
    323e:	mov    rdi,r12
    3241:	call   3246 <botlish_fn_18+0x18e>
			3242: R_X86_64_PLT32	rt_int_sub-0x4
    3246:	mov    rsi,rax
    3249:	test   rsi,0x1
    3250:	jne    327b <botlish_fn_18+0x1c3>
    3256:	mov    edx,0x5
    325b:	mov    rdi,r12
    325e:	call   3263 <botlish_fn_18+0x1ab>
			325f: R_X86_64_PLT32	rt_int_cmp-0x4
    3263:	mov    ecx,0x2
    3268:	test   rax,rax
    326b:	mov    rax,rcx
    326e:	cmovge rax,QWORD PTR [rip+0x3a]        # 32b0 <botlish_fn_18+0x1f8>
    3276:	jmp    328c <botlish_fn_18+0x1d4>
    327b:	mov    eax,0x2
    3280:	cmp    rsi,0x5
    3284:	cmovge rax,QWORD PTR [rip+0x24]        # 32b0 <botlish_fn_18+0x1f8>
    328c:	mov    rbx,QWORD PTR [rsp+0x10]
    3291:	mov    r12,QWORD PTR [rsp+0x18]
    3296:	mov    r13,QWORD PTR [rsp+0x20]
    329b:	mov    r14,QWORD PTR [rsp+0x28]
    32a0:	add    rsp,0x30
    32a4:	mov    rsp,rbp
    32a7:	pop    rbp
    32a8:	ret
    32a9:	add    BYTE PTR [rax],al
    32ab:	add    BYTE PTR [rax],al
    32ad:	add    BYTE PTR [rax],al
    32af:	add    BYTE PTR [rsi],al
    32b1:	add    BYTE PTR [rax],al
    32b3:	add    BYTE PTR [rax],al
    32b5:	add    BYTE PTR [rax],al
	...

00000000000032b8 <botlish_entry_18: tld_ok<generic>>:
    32b8:	push   rbp
    32b9:	mov    rbp,rsp
    32bc:	mov    rdx,QWORD PTR [rdx]
    32bf:	call   32c4 <botlish_entry_18+0xc>
			32c0: R_X86_64_PLT32	botlish_fn_18-0x4 ; tld_ok<generic>
    32c4:	mov    rsp,rbp
    32c7:	pop    rbp
    32c8:	ret
    32c9:	add    BYTE PTR [rax],al
    32cb:	add    BYTE PTR [rax],al
    32cd:	add    BYTE PTR [rax],al
	...

00000000000032d0 <botlish_fn_19: domain_loop<generic>>:
    32d0:	push   rbp
    32d1:	mov    rbp,rsp
    32d4:	sub    rsp,0x50
    32d8:	mov    QWORD PTR [rsp+0x20],rbx
    32dd:	mov    QWORD PTR [rsp+0x28],r12
    32e2:	mov    QWORD PTR [rsp+0x30],r13
    32e7:	mov    QWORD PTR [rsp+0x38],r14
    32ec:	mov    QWORD PTR [rsp+0x40],r15
    32f1:	mov    QWORD PTR [rsp],rdx
    32f5:	mov    r15,rdx
    32f8:	lea    r13,[rsp+0x10]
    32fd:	mov    rbx,rsi
    3300:	mov    rax,QWORD PTR [rbx+0x20]
    3304:	mov    rsi,QWORD PTR [rax]
    3307:	mov    QWORD PTR [rsp+0x8],rsi
    330c:	mov    r12,rdi
    330f:	mov    rdx,r15
    3312:	call   3317 <botlish_fn_19+0x47>
			3313: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_label<generic>
    3317:	mov    r10,rax
    331a:	mov    r14,rax
    331d:	test   rax,r10
    3320:	je     3496 <botlish_fn_19+0x1c6>
    3326:	mov    rax,r14
    3329:	mov    QWORD PTR [rsp],rax
    332d:	mov    rdx,r15
    3330:	and    rax,rdx
    3333:	test   rax,0x1
    3339:	jne    335b <botlish_fn_19+0x8b>
    333f:	mov    rdx,r15
    3342:	mov    rsi,r14
    3345:	mov    rdi,r12
    3348:	call   334d <botlish_fn_19+0x7d>
			3349: R_X86_64_PLT32	rt_value_eq-0x4
    334d:	test   rax,rax
    3350:	je     3496 <botlish_fn_19+0x1c6>
    3356:	jmp    336e <botlish_fn_19+0x9e>
    335b:	mov    eax,0x2
    3360:	mov    rdx,r15
    3363:	cmp    r14,rdx
    3366:	cmove  rax,QWORD PTR [rip+0x1aa]        # 3518 <botlish_fn_19+0x248>
    336e:	cmp    rax,0x6
    3372:	je     34ed <botlish_fn_19+0x21d>
    3378:	mov    rdx,QWORD PTR [rbx+0x20]
    337c:	mov    rdx,QWORD PTR [rdx+0x8]
    3380:	mov    rsi,r14
    3383:	and    rsi,rdx
    3386:	test   rsi,0x1
    338d:	jne    33b3 <botlish_fn_19+0xe3>
    3393:	mov    rsi,r14
    3396:	mov    rdi,r12
    3399:	call   339e <botlish_fn_19+0xce>
			339a: R_X86_64_PLT32	rt_int_cmp-0x4
    339e:	mov    ecx,0x2
    33a3:	test   rax,rax
    33a6:	cmovge rcx,QWORD PTR [rip+0x16a]        # 3518 <botlish_fn_19+0x248>
    33ae:	jmp    33c3 <botlish_fn_19+0xf3>
    33b3:	mov    ecx,0x2
    33b8:	cmp    r14,rdx
    33bb:	cmovge rcx,QWORD PTR [rip+0x155]        # 3518 <botlish_fn_19+0x248>
    33c3:	cmp    rcx,0x6
    33c7:	je     34e1 <botlish_fn_19+0x211>
    33cd:	mov    r10,QWORD PTR [rbx+0x20]
    33d1:	mov    rsi,QWORD PTR [r10+0x10]
    33d5:	mov    QWORD PTR [rsp+0x8],rsi
    33da:	mov    rcx,r13
    33dd:	mov    rdx,r14
    33e0:	mov    rdi,r12
    33e3:	call   33e8 <botlish_fn_19+0x118>
			33e4: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    33e8:	test   rax,rax
    33eb:	mov    rsi,rax
    33ee:	je     3496 <botlish_fn_19+0x1c6>
    33f4:	mov    rdx,QWORD PTR [rsp+0x10]
    33f9:	mov    rcx,QWORD PTR [rsp+0x18]
    33fe:	mov    rax,QWORD PTR [r12+0x10]
    3403:	mov    r8,QWORD PTR [rax+0x118]
    340a:	mov    rdi,r12
    340d:	call   3412 <botlish_fn_19+0x142>
			340e: R_X86_64_PLT32	rt_str_region_eq-0x4
    3412:	cmp    rax,0x6
    3416:	je     3428 <botlish_fn_19+0x158>
    341c:	mov    rax,0xffffffffffffffff
    3423:	jmp    34f4 <botlish_fn_19+0x224>
    3428:	mov    QWORD PTR [rsp+0x8],0x3
    3431:	test   r14,0x1
    3438:	je     345b <botlish_fn_19+0x18b>
    343e:	mov    rdx,r14
    3441:	add    rdx,0x2
    3445:	mov    r15,rdx
    3448:	seto   al
    344b:	test   al,al
    344d:	jne    345b <botlish_fn_19+0x18b>
    3453:	mov    rdx,r15
    3456:	jmp    3471 <botlish_fn_19+0x1a1>
    345b:	mov    edx,0x3
    3460:	mov    rsi,r14
    3463:	mov    rdi,r12
    3466:	call   346b <botlish_fn_19+0x19b>
			3467: R_X86_64_PLT32	rt_int_add-0x4
    346b:	mov    rdx,rax
    346e:	mov    r15,rax
    3471:	mov    QWORD PTR [rsp],rdx
    3475:	mov    rax,QWORD PTR [rbx+0x20]
    3479:	mov    rsi,QWORD PTR [rax+0x18]
    347d:	mov    QWORD PTR [rsp+0x8],rsi
    3482:	mov    rdx,r15
    3485:	mov    rdi,r12
    3488:	call   348d <botlish_fn_19+0x1bd>
			3489: R_X86_64_PLT32	botlish_fn_18-0x4 ; tld_ok<generic>
    348d:	test   rax,rax
    3490:	jne    34bb <botlish_fn_19+0x1eb>
    3496:	xor    rax,rax
    3499:	mov    rbx,QWORD PTR [rsp+0x20]
    349e:	mov    r12,QWORD PTR [rsp+0x28]
    34a3:	mov    r13,QWORD PTR [rsp+0x30]
    34a8:	mov    r14,QWORD PTR [rsp+0x38]
    34ad:	mov    r15,QWORD PTR [rsp+0x40]
    34b2:	add    rsp,0x50
    34b6:	mov    rsp,rbp
    34b9:	pop    rbp
    34ba:	ret
    34bb:	cmp    rax,0x6
    34bf:	je     34d4 <botlish_fn_19+0x204>
    34c5:	mov    rdx,r15
    34c8:	mov    QWORD PTR [rsp],rdx
    34cc:	mov    rdi,r12
    34cf:	jmp    3300 <botlish_fn_19+0x30>
    34d4:	mov    rax,QWORD PTR [rbx+0x20]
    34d8:	mov    rax,QWORD PTR [rax+0x8]
    34dc:	jmp    34f4 <botlish_fn_19+0x224>
    34e1:	mov    rax,0xffffffffffffffff
    34e8:	jmp    34f4 <botlish_fn_19+0x224>
    34ed:	mov    rax,0xffffffffffffffff
    34f4:	mov    rbx,QWORD PTR [rsp+0x20]
    34f9:	mov    r12,QWORD PTR [rsp+0x28]
    34fe:	mov    r13,QWORD PTR [rsp+0x30]
    3503:	mov    r14,QWORD PTR [rsp+0x38]
    3508:	mov    r15,QWORD PTR [rsp+0x40]
    350d:	add    rsp,0x50
    3511:	mov    rsp,rbp
    3514:	pop    rbp
    3515:	ret
    3516:	add    BYTE PTR [rax],al
    3518:	(bad)
    3519:	add    BYTE PTR [rax],al
    351b:	add    BYTE PTR [rax],al
    351d:	add    BYTE PTR [rax],al
	...

0000000000003520 <botlish_entry_19: domain_loop<generic>>:
    3520:	push   rbp
    3521:	mov    rbp,rsp
    3524:	mov    rdx,QWORD PTR [rdx]
    3527:	call   352c <botlish_entry_19+0xc>
			3528: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    352c:	mov    rsp,rbp
    352f:	pop    rbp
    3530:	ret
    3531:	add    BYTE PTR [rax],al
    3533:	add    BYTE PTR [rax],al
    3535:	add    BYTE PTR [rax],al
	...

0000000000003538 <botlish_fn_20: <str>>:
    3538:	push   rbp
    3539:	mov    rbp,rsp
    353c:	sub    rsp,0xe0
    3543:	mov    QWORD PTR [rsp+0xb0],rbx
    354b:	mov    QWORD PTR [rsp+0xb8],r12
    3553:	mov    QWORD PTR [rsp+0xc0],r13
    355b:	mov    QWORD PTR [rsp+0xc8],r14
    3563:	mov    QWORD PTR [rsp+0xd0],r15
    356b:	mov    r15,rdi
    356e:	mov    QWORD PTR [rsp+0x10],0x0
    3577:	mov    QWORD PTR [rsp+0x18],0x0
    3580:	mov    QWORD PTR [rsp+0x20],0x0
    3589:	mov    QWORD PTR [rsp],rsi
    358d:	mov    rbx,rsi
    3590:	mov    rsi,rbx
    3593:	mov    rdi,r15
    3596:	call   359b <botlish_fn_20+0x63>
			3597: R_X86_64_PLT32	rt_str_len-0x4
    359b:	mov    QWORD PTR [rsp+0xa8],rax
    35a3:	mov    QWORD PTR [rsp+0x8],rax
    35a8:	lea    r8,[rsp+0x28]
    35ad:	mov    QWORD PTR [rsp+0x28],rbx
    35b2:	mov    esi,0x16
    35b7:	mov    rdx,QWORD PTR [rip+0x0]        # 35be <botlish_fn_20+0x86>
			35ba: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; char_at<generic>
    35be:	mov    ebx,0x1
    35c3:	mov    rcx,rbx
    35c6:	mov    rdi,r15
    35c9:	call   35ce <botlish_fn_20+0x96>
			35ca: R_X86_64_PLT32	rt_closure_new-0x4
    35ce:	mov    r14,rax
    35d1:	mov    QWORD PTR [rsp],rax
    35d5:	lea    r8,[rsp+0x30]
    35da:	mov    rax,QWORD PTR [rsp+0xa8]
    35e2:	mov    QWORD PTR [rsp+0x30],rax
    35e7:	mov    rax,r14
    35ea:	mov    QWORD PTR [rsp+0x38],rax
    35ef:	mov    esi,0x1a
    35f4:	mov    rdx,QWORD PTR [rip+0x0]        # 35fb <botlish_fn_20+0xc3>
			35f7: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; scan_local<generic>
    35fb:	mov    r13d,0x2
    3601:	mov    rcx,r13
    3604:	mov    rdi,r15
    3607:	call   360c <botlish_fn_20+0xd4>
			3608: R_X86_64_PLT32	rt_closure_new-0x4
    360c:	mov    r12,rax
    360f:	mov    QWORD PTR [rsp+0x10],r12
    3614:	lea    r8,[rsp+0x40]
    3619:	mov    rax,QWORD PTR [rsp+0xa8]
    3621:	mov    QWORD PTR [rsp+0x40],rax
    3626:	mov    rax,r14
    3629:	mov    QWORD PTR [rsp+0x48],rax
    362e:	mov    esi,0x1b
    3633:	mov    rdx,QWORD PTR [rip+0x0]        # 363a <botlish_fn_20+0x102>
			3636: R_X86_64_GOTPCREL	botlish_entry_27-0x4 ; scan_label<generic>
    363a:	mov    rcx,r13
    363d:	mov    rdi,r15
    3640:	call   3645 <botlish_fn_20+0x10d>
			3641: R_X86_64_PLT32	rt_closure_new-0x4
    3645:	mov    QWORD PTR [rsp+0x18],rax
    364a:	mov    QWORD PTR [rsp+0xa0],rax
    3652:	lea    r8,[rsp+0x50]
    3657:	mov    rax,QWORD PTR [rsp+0xa8]
    365f:	mov    QWORD PTR [rsp+0x50],rax
    3664:	mov    QWORD PTR [rsp+0x58],r14
    3669:	mov    esi,0x1c
    366e:	mov    rdx,QWORD PTR [rip+0x0]        # 3675 <botlish_fn_20+0x13d>
			3671: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; scan_alpha<generic>
    3675:	mov    rcx,r13
    3678:	mov    rdi,r15
    367b:	call   3680 <botlish_fn_20+0x148>
			367c: R_X86_64_PLT32	rt_closure_new-0x4
    3680:	mov    QWORD PTR [rsp+0x20],rax
    3685:	lea    r8,[rsp+0x60]
    368a:	mov    QWORD PTR [rsp+0x60],rax
    368f:	mov    rax,QWORD PTR [rsp+0xa8]
    3697:	mov    QWORD PTR [rsp+0x68],rax
    369c:	mov    esi,0x1d
    36a1:	mov    rdx,QWORD PTR [rip+0x0]        # 36a8 <botlish_fn_20+0x170>
			36a4: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; tld_ok<generic>
    36a8:	mov    rcx,r13
    36ab:	mov    rdi,r15
    36ae:	call   36b3 <botlish_fn_20+0x17b>
			36af: R_X86_64_PLT32	rt_closure_new-0x4
    36b3:	mov    QWORD PTR [rsp+0x20],rax
    36b8:	lea    r8,[rsp+0x70]
    36bd:	mov    rcx,QWORD PTR [rsp+0xa0]
    36c5:	mov    QWORD PTR [rsp+0x70],rcx
    36ca:	mov    rcx,QWORD PTR [rsp+0xa8]
    36d2:	mov    QWORD PTR [rsp+0x78],rcx
    36d7:	mov    QWORD PTR [rsp+0x80],r14
    36df:	mov    QWORD PTR [rsp+0x88],rax
    36e7:	mov    esi,0x1e
    36ec:	mov    rdx,QWORD PTR [rip+0x0]        # 36f3 <botlish_fn_20+0x1bb>
			36ef: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; domain_loop<generic>
    36f3:	mov    ecx,0x4
    36f8:	mov    rdi,r15
    36fb:	call   3700 <botlish_fn_20+0x1c8>
			36fc: R_X86_64_PLT32	rt_closure_new-0x4
    3700:	mov    QWORD PTR [rsp+0x18],rax
    3705:	mov    r13,rax
    3708:	mov    QWORD PTR [rsp+0x20],0x1
    3711:	mov    rdx,rbx
    3714:	mov    rsi,r12
    3717:	mov    rdi,r15
    371a:	call   371f <botlish_fn_20+0x1e7>
			371b: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    371f:	mov    rcx,rax
    3722:	mov    r12,rax
    3725:	test   rax,rcx
    3728:	je     3889 <botlish_fn_20+0x351>
    372e:	mov    rax,r12
    3731:	mov    QWORD PTR [rsp+0x10],rax
    3736:	test   rax,0x1
    373c:	jne    3767 <botlish_fn_20+0x22f>
    3742:	mov    edx,0x1
    3747:	mov    rsi,r12
    374a:	mov    rdi,r15
    374d:	call   3752 <botlish_fn_20+0x21a>
			374e: R_X86_64_PLT32	rt_int_cmp-0x4
    3752:	mov    esi,0x2
    3757:	test   rax,rax
    375a:	cmove  rsi,QWORD PTR [rip+0x206]        # 3968 <botlish_fn_20+0x430>
    3762:	jmp    3778 <botlish_fn_20+0x240>
    3767:	mov    esi,0x2
    376c:	cmp    r12,0x1
    3770:	cmove  rsi,QWORD PTR [rip+0x1f0]        # 3968 <botlish_fn_20+0x430>
    3778:	cmp    rsi,0x6
    377c:	je     392d <botlish_fn_20+0x3f5>
    3782:	mov    rbx,QWORD PTR [rsp+0xa8]
    378a:	mov    rax,r12
    378d:	and    rax,rbx
    3790:	test   rax,0x1
    3796:	jne    37bf <botlish_fn_20+0x287>
    379c:	mov    rdx,rbx
    379f:	mov    rsi,r12
    37a2:	mov    rdi,r15
    37a5:	call   37aa <botlish_fn_20+0x272>
			37a6: R_X86_64_PLT32	rt_int_cmp-0x4
    37aa:	mov    ecx,0x2
    37af:	test   rax,rax
    37b2:	cmovge rcx,QWORD PTR [rip+0x1ae]        # 3968 <botlish_fn_20+0x430>
    37ba:	jmp    37cf <botlish_fn_20+0x297>
    37bf:	mov    ecx,0x2
    37c4:	cmp    r12,rbx
    37c7:	cmovge rcx,QWORD PTR [rip+0x199]        # 3968 <botlish_fn_20+0x430>
    37cf:	cmp    rcx,0x6
    37d3:	je     3923 <botlish_fn_20+0x3eb>
    37d9:	lea    rcx,[rsp+0x90]
    37e1:	mov    rsi,r14
    37e4:	mov    rdx,r12
    37e7:	mov    rdi,r15
    37ea:	call   37ef <botlish_fn_20+0x2b7>
			37eb: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    37ef:	test   rax,rax
    37f2:	mov    rsi,rax
    37f5:	je     3889 <botlish_fn_20+0x351>
    37fb:	mov    rdx,QWORD PTR [rsp+0x90]
    3803:	mov    rcx,QWORD PTR [rsp+0x98]
    380b:	mov    rdi,r15
    380e:	mov    rax,QWORD PTR [rdi+0x10]
    3812:	mov    r8,QWORD PTR [rax+0x100]
    3819:	call   381e <botlish_fn_20+0x2e6>
			381a: R_X86_64_PLT32	rt_str_region_eq-0x4
    381e:	cmp    rax,0x6
    3822:	je     3835 <botlish_fn_20+0x2fd>
    3828:	mov    ecx,0x2
    382d:	mov    rax,rcx
    3830:	jmp    3932 <botlish_fn_20+0x3fa>
    3835:	mov    QWORD PTR [rsp],0x3
    383d:	test   r12,0x1
    3844:	je     385e <botlish_fn_20+0x326>
    384a:	mov    rdx,r12
    384d:	add    rdx,0x2
    3851:	seto   sil
    3855:	test   sil,sil
    3858:	je     3871 <botlish_fn_20+0x339>
    385e:	mov    edx,0x3
    3863:	mov    rsi,r12
    3866:	mov    rdi,r15
    3869:	call   386e <botlish_fn_20+0x336>
			386a: R_X86_64_PLT32	rt_int_add-0x4
    386e:	mov    rdx,rax
    3871:	mov    QWORD PTR [rsp],rdx
    3875:	mov    rsi,r13
    3878:	mov    rdi,r15
    387b:	call   3880 <botlish_fn_20+0x348>
			387c: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    3880:	test   rax,rax
    3883:	jne    38c0 <botlish_fn_20+0x388>
    3889:	xor    rax,rax
    388c:	mov    rbx,QWORD PTR [rsp+0xb0]
    3894:	mov    r12,QWORD PTR [rsp+0xb8]
    389c:	mov    r13,QWORD PTR [rsp+0xc0]
    38a4:	mov    r14,QWORD PTR [rsp+0xc8]
    38ac:	mov    r15,QWORD PTR [rsp+0xd0]
    38b4:	add    rsp,0xe0
    38bb:	mov    rsp,rbp
    38be:	pop    rbp
    38bf:	ret
    38c0:	mov    rcx,rax
    38c3:	and    rcx,rbx
    38c6:	mov    rsi,rax
    38c9:	mov    QWORD PTR [rsp+0xa8],rbx
    38d1:	test   rcx,0x1
    38d8:	jne    3906 <botlish_fn_20+0x3ce>
    38de:	mov    rdx,QWORD PTR [rsp+0xa8]
    38e6:	mov    rdi,r15
    38e9:	call   38ee <botlish_fn_20+0x3b6>
			38ea: R_X86_64_PLT32	rt_int_cmp-0x4
    38ee:	mov    ecx,0x2
    38f3:	test   rax,rax
    38f6:	mov    rax,rcx
    38f9:	cmove  rax,QWORD PTR [rip+0x67]        # 3968 <botlish_fn_20+0x430>
    3901:	jmp    3932 <botlish_fn_20+0x3fa>
    3906:	mov    rdx,QWORD PTR [rsp+0xa8]
    390e:	mov    eax,0x2
    3913:	cmp    rsi,rdx
    3916:	cmove  rax,QWORD PTR [rip+0x4a]        # 3968 <botlish_fn_20+0x430>
    391e:	jmp    3932 <botlish_fn_20+0x3fa>
    3923:	mov    eax,0x2
    3928:	jmp    3932 <botlish_fn_20+0x3fa>
    392d:	mov    eax,0x2
    3932:	mov    rbx,QWORD PTR [rsp+0xb0]
    393a:	mov    r12,QWORD PTR [rsp+0xb8]
    3942:	mov    r13,QWORD PTR [rsp+0xc0]
    394a:	mov    r14,QWORD PTR [rsp+0xc8]
    3952:	mov    r15,QWORD PTR [rsp+0xd0]
    395a:	add    rsp,0xe0
    3961:	mov    rsp,rbp
    3964:	pop    rbp
    3965:	ret
    3966:	add    BYTE PTR [rax],al
    3968:	(bad)
    3969:	add    BYTE PTR [rax],al
    396b:	add    BYTE PTR [rax],al
    396d:	add    BYTE PTR [rax],al
	...

0000000000003970 <botlish_entry_20: <str>>:
    3970:	push   rbp
    3971:	mov    rbp,rsp
    3974:	mov    rsi,QWORD PTR [rdx]
    3977:	call   397c <botlish_entry_20+0xc>
			3978: R_X86_64_PLT32	botlish_fn_20-0x4 ; <str>
    397c:	mov    rsp,rbp
    397f:	pop    rbp
    3980:	ret
    3981:	add    BYTE PTR [rax],al
    3983:	add    BYTE PTR [rax],al
    3985:	add    BYTE PTR [rax],al
	...

0000000000003988 <botlish_fn_21: <generic>>:
    3988:	push   rbp
    3989:	mov    rbp,rsp
    398c:	sub    rsp,0xe0
    3993:	mov    QWORD PTR [rsp+0xb0],rbx
    399b:	mov    QWORD PTR [rsp+0xb8],r12
    39a3:	mov    QWORD PTR [rsp+0xc0],r13
    39ab:	mov    QWORD PTR [rsp+0xc8],r14
    39b3:	mov    QWORD PTR [rsp+0xd0],r15
    39bb:	mov    QWORD PTR [rsp+0x10],0x0
    39c4:	mov    QWORD PTR [rsp+0x18],0x0
    39cd:	mov    QWORD PTR [rsp+0x20],0x0
    39d6:	mov    QWORD PTR [rsp],rsi
    39da:	xor    r8d,r8d
    39dd:	test   rsi,0x7
    39e4:	jne    39f4 <botlish_fn_21+0x6c>
    39ea:	movzx  rax,BYTE PTR [rsi]
    39ee:	cmp    al,0x2
    39f0:	sete   r8b
    39f4:	test   r8b,r8b
    39f7:	jne    3a17 <botlish_fn_21+0x8f>
    39fd:	mov    rax,QWORD PTR [rdi+0x10]
    3a01:	mov    rcx,QWORD PTR [rax+0xd8]
    3a08:	mov    edx,0x1
    3a0d:	call   3a12 <botlish_fn_21+0x8a>
			3a0e: R_X86_64_PLT32	rt_type_error-0x4
    3a12:	jmp    3d06 <botlish_fn_21+0x37e>
    3a17:	mov    rbx,rsi
    3a1a:	mov    r15,rdi
    3a1d:	call   3a22 <botlish_fn_21+0x9a>
			3a1e: R_X86_64_PLT32	rt_str_len-0x4
    3a22:	mov    r14,rax
    3a25:	mov    QWORD PTR [rsp+0x8],rax
    3a2a:	lea    r8,[rsp+0x28]
    3a2f:	mov    QWORD PTR [rsp+0x28],rbx
    3a34:	mov    esi,0x16
    3a39:	mov    rdx,QWORD PTR [rip+0x0]        # 3a40 <botlish_fn_21+0xb8>
			3a3c: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; char_at<generic>
    3a40:	mov    ebx,0x1
    3a45:	mov    rcx,rbx
    3a48:	mov    rdi,r15
    3a4b:	call   3a50 <botlish_fn_21+0xc8>
			3a4c: R_X86_64_PLT32	rt_closure_new-0x4
    3a50:	mov    r13,rax
    3a53:	mov    QWORD PTR [rsp+0xa8],rbx
    3a5b:	mov    QWORD PTR [rsp],rax
    3a5f:	lea    r8,[rsp+0x30]
    3a64:	mov    rax,r14
    3a67:	mov    QWORD PTR [rsp+0x30],rax
    3a6c:	mov    rax,r13
    3a6f:	mov    QWORD PTR [rsp+0x38],rax
    3a74:	mov    esi,0x1a
    3a79:	mov    rdx,QWORD PTR [rip+0x0]        # 3a80 <botlish_fn_21+0xf8>
			3a7c: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; scan_local<generic>
    3a80:	mov    r12d,0x2
    3a86:	mov    rcx,r12
    3a89:	mov    rdi,r15
    3a8c:	call   3a91 <botlish_fn_21+0x109>
			3a8d: R_X86_64_PLT32	rt_closure_new-0x4
    3a91:	mov    rbx,rax
    3a94:	mov    QWORD PTR [rsp+0x10],rbx
    3a99:	lea    r8,[rsp+0x40]
    3a9e:	mov    rax,r14
    3aa1:	mov    QWORD PTR [rsp+0x40],rax
    3aa6:	mov    rax,r13
    3aa9:	mov    QWORD PTR [rsp+0x48],rax
    3aae:	mov    esi,0x1b
    3ab3:	mov    rdx,QWORD PTR [rip+0x0]        # 3aba <botlish_fn_21+0x132>
			3ab6: R_X86_64_GOTPCREL	botlish_entry_27-0x4 ; scan_label<generic>
    3aba:	mov    rcx,r12
    3abd:	mov    rdi,r15
    3ac0:	call   3ac5 <botlish_fn_21+0x13d>
			3ac1: R_X86_64_PLT32	rt_closure_new-0x4
    3ac5:	mov    QWORD PTR [rsp+0x18],rax
    3aca:	mov    QWORD PTR [rsp+0xa0],rax
    3ad2:	lea    r8,[rsp+0x50]
    3ad7:	mov    rax,r14
    3ada:	mov    QWORD PTR [rsp+0x50],rax
    3adf:	mov    QWORD PTR [rsp+0x58],r13
    3ae4:	mov    esi,0x1c
    3ae9:	mov    rdx,QWORD PTR [rip+0x0]        # 3af0 <botlish_fn_21+0x168>
			3aec: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; scan_alpha<generic>
    3af0:	mov    rcx,r12
    3af3:	mov    rdi,r15
    3af6:	call   3afb <botlish_fn_21+0x173>
			3af7: R_X86_64_PLT32	rt_closure_new-0x4
    3afb:	mov    QWORD PTR [rsp+0x20],rax
    3b00:	lea    r8,[rsp+0x60]
    3b05:	mov    QWORD PTR [rsp+0x60],rax
    3b0a:	mov    rax,r14
    3b0d:	mov    QWORD PTR [rsp+0x68],rax
    3b12:	mov    esi,0x1d
    3b17:	mov    rdx,QWORD PTR [rip+0x0]        # 3b1e <botlish_fn_21+0x196>
			3b1a: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; tld_ok<generic>
    3b1e:	mov    rcx,r12
    3b21:	mov    rdi,r15
    3b24:	call   3b29 <botlish_fn_21+0x1a1>
			3b25: R_X86_64_PLT32	rt_closure_new-0x4
    3b29:	mov    QWORD PTR [rsp+0x20],rax
    3b2e:	lea    r8,[rsp+0x70]
    3b33:	mov    rcx,QWORD PTR [rsp+0xa0]
    3b3b:	mov    QWORD PTR [rsp+0x70],rcx
    3b40:	mov    rcx,r14
    3b43:	mov    QWORD PTR [rsp+0x78],rcx
    3b48:	mov    QWORD PTR [rsp+0x80],r13
    3b50:	mov    QWORD PTR [rsp+0x88],rax
    3b58:	mov    esi,0x1e
    3b5d:	mov    rdx,QWORD PTR [rip+0x0]        # 3b64 <botlish_fn_21+0x1dc>
			3b60: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; domain_loop<generic>
    3b64:	mov    ecx,0x4
    3b69:	mov    rdi,r15
    3b6c:	call   3b71 <botlish_fn_21+0x1e9>
			3b6d: R_X86_64_PLT32	rt_closure_new-0x4
    3b71:	mov    QWORD PTR [rsp+0x18],rax
    3b76:	mov    QWORD PTR [rsp+0xa0],rax
    3b7e:	mov    QWORD PTR [rsp+0x20],0x1
    3b87:	mov    rsi,rbx
    3b8a:	mov    rdx,QWORD PTR [rsp+0xa8]
    3b92:	mov    rdi,r15
    3b95:	call   3b9a <botlish_fn_21+0x212>
			3b96: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    3b9a:	mov    rcx,rax
    3b9d:	mov    r12,rax
    3ba0:	test   rax,rcx
    3ba3:	je     3d06 <botlish_fn_21+0x37e>
    3ba9:	mov    rax,r12
    3bac:	mov    QWORD PTR [rsp+0x10],rax
    3bb1:	test   rax,0x1
    3bb7:	jne    3be5 <botlish_fn_21+0x25d>
    3bbd:	mov    rdx,QWORD PTR [rsp+0xa8]
    3bc5:	mov    rsi,r12
    3bc8:	mov    rdi,r15
    3bcb:	call   3bd0 <botlish_fn_21+0x248>
			3bcc: R_X86_64_PLT32	rt_int_cmp-0x4
    3bd0:	mov    ecx,0x2
    3bd5:	test   rax,rax
    3bd8:	cmove  rcx,QWORD PTR [rip+0x1f8]        # 3dd8 <botlish_fn_21+0x450>
    3be0:	jmp    3bf6 <botlish_fn_21+0x26e>
    3be5:	mov    ecx,0x2
    3bea:	cmp    r12,0x1
    3bee:	cmove  rcx,QWORD PTR [rip+0x1e2]        # 3dd8 <botlish_fn_21+0x450>
    3bf6:	cmp    rcx,0x6
    3bfa:	je     3d9b <botlish_fn_21+0x413>
    3c00:	mov    rbx,r14
    3c03:	mov    rcx,r12
    3c06:	and    rcx,rbx
    3c09:	test   rcx,0x1
    3c10:	jne    3c39 <botlish_fn_21+0x2b1>
    3c16:	mov    rdx,rbx
    3c19:	mov    rsi,r12
    3c1c:	mov    rdi,r15
    3c1f:	call   3c24 <botlish_fn_21+0x29c>
			3c20: R_X86_64_PLT32	rt_int_cmp-0x4
    3c24:	mov    ecx,0x2
    3c29:	test   rax,rax
    3c2c:	cmovge rcx,QWORD PTR [rip+0x1a4]        # 3dd8 <botlish_fn_21+0x450>
    3c34:	jmp    3c49 <botlish_fn_21+0x2c1>
    3c39:	mov    ecx,0x2
    3c3e:	cmp    r12,rbx
    3c41:	cmovge rcx,QWORD PTR [rip+0x18f]        # 3dd8 <botlish_fn_21+0x450>
    3c49:	cmp    rcx,0x6
    3c4d:	je     3d91 <botlish_fn_21+0x409>
    3c53:	lea    rcx,[rsp+0x90]
    3c5b:	mov    rsi,r13
    3c5e:	mov    rdx,r12
    3c61:	mov    rdi,r15
    3c64:	call   3c69 <botlish_fn_21+0x2e1>
			3c65: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    3c69:	test   rax,rax
    3c6c:	mov    rsi,rax
    3c6f:	je     3d06 <botlish_fn_21+0x37e>
    3c75:	mov    rdx,QWORD PTR [rsp+0x90]
    3c7d:	mov    rcx,QWORD PTR [rsp+0x98]
    3c85:	mov    rdi,r15
    3c88:	mov    rax,QWORD PTR [rdi+0x10]
    3c8c:	mov    r8,QWORD PTR [rax+0x100]
    3c93:	call   3c98 <botlish_fn_21+0x310>
			3c94: R_X86_64_PLT32	rt_str_region_eq-0x4
    3c98:	cmp    rax,0x6
    3c9c:	je     3caf <botlish_fn_21+0x327>
    3ca2:	mov    ecx,0x2
    3ca7:	mov    rax,rcx
    3caa:	jmp    3da0 <botlish_fn_21+0x418>
    3caf:	mov    QWORD PTR [rsp],0x3
    3cb7:	test   r12,0x1
    3cbe:	je     3cd6 <botlish_fn_21+0x34e>
    3cc4:	mov    rdx,r12
    3cc7:	add    rdx,0x2
    3ccb:	seto   al
    3cce:	test   al,al
    3cd0:	je     3ce9 <botlish_fn_21+0x361>
    3cd6:	mov    edx,0x3
    3cdb:	mov    rsi,r12
    3cde:	mov    rdi,r15
    3ce1:	call   3ce6 <botlish_fn_21+0x35e>
			3ce2: R_X86_64_PLT32	rt_int_add-0x4
    3ce6:	mov    rdx,rax
    3ce9:	mov    QWORD PTR [rsp],rdx
    3ced:	mov    rsi,QWORD PTR [rsp+0xa0]
    3cf5:	mov    rdi,r15
    3cf8:	call   3cfd <botlish_fn_21+0x375>
			3cf9: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    3cfd:	test   rax,rax
    3d00:	jne    3d3d <botlish_fn_21+0x3b5>
    3d06:	xor    rax,rax
    3d09:	mov    rbx,QWORD PTR [rsp+0xb0]
    3d11:	mov    r12,QWORD PTR [rsp+0xb8]
    3d19:	mov    r13,QWORD PTR [rsp+0xc0]
    3d21:	mov    r14,QWORD PTR [rsp+0xc8]
    3d29:	mov    r15,QWORD PTR [rsp+0xd0]
    3d31:	add    rsp,0xe0
    3d38:	mov    rsp,rbp
    3d3b:	pop    rbp
    3d3c:	ret
    3d3d:	mov    rcx,rax
    3d40:	and    rcx,rbx
    3d43:	mov    rsi,rax
    3d46:	mov    r14,rbx
    3d49:	test   rcx,0x1
    3d50:	jne    3d79 <botlish_fn_21+0x3f1>
    3d56:	mov    rdx,r14
    3d59:	mov    rdi,r15
    3d5c:	call   3d61 <botlish_fn_21+0x3d9>
			3d5d: R_X86_64_PLT32	rt_int_cmp-0x4
    3d61:	mov    ecx,0x2
    3d66:	test   rax,rax
    3d69:	mov    rax,rcx
    3d6c:	cmove  rax,QWORD PTR [rip+0x64]        # 3dd8 <botlish_fn_21+0x450>
    3d74:	jmp    3da0 <botlish_fn_21+0x418>
    3d79:	mov    rdx,r14
    3d7c:	mov    eax,0x2
    3d81:	cmp    rsi,rdx
    3d84:	cmove  rax,QWORD PTR [rip+0x4c]        # 3dd8 <botlish_fn_21+0x450>
    3d8c:	jmp    3da0 <botlish_fn_21+0x418>
    3d91:	mov    eax,0x2
    3d96:	jmp    3da0 <botlish_fn_21+0x418>
    3d9b:	mov    eax,0x2
    3da0:	mov    rbx,QWORD PTR [rsp+0xb0]
    3da8:	mov    r12,QWORD PTR [rsp+0xb8]
    3db0:	mov    r13,QWORD PTR [rsp+0xc0]
    3db8:	mov    r14,QWORD PTR [rsp+0xc8]
    3dc0:	mov    r15,QWORD PTR [rsp+0xd0]
    3dc8:	add    rsp,0xe0
    3dcf:	mov    rsp,rbp
    3dd2:	pop    rbp
    3dd3:	ret
    3dd4:	add    BYTE PTR [rax],al
    3dd6:	add    BYTE PTR [rax],al
    3dd8:	(bad)
    3dd9:	add    BYTE PTR [rax],al
    3ddb:	add    BYTE PTR [rax],al
    3ddd:	add    BYTE PTR [rax],al
	...

0000000000003de0 <botlish_entry_21: <generic>>:
    3de0:	push   rbp
    3de1:	mov    rbp,rsp
    3de4:	mov    rsi,QWORD PTR [rdx]
    3de7:	call   3dec <botlish_entry_21+0xc>
			3de8: R_X86_64_PLT32	botlish_fn_21-0x4 ; <generic>
    3dec:	mov    rsp,rbp
    3def:	pop    rbp
    3df0:	ret

0000000000003df1 <botlish_fn_22: char_at<generic>>:
    3df1:	push   rbp
    3df2:	mov    rbp,rsp
    3df5:	sub    rsp,0x40
    3df9:	mov    QWORD PTR [rsp+0x20],rbx
    3dfe:	mov    QWORD PTR [rsp+0x28],r12
    3e03:	mov    QWORD PTR [rsp+0x30],r13
    3e08:	mov    QWORD PTR [rsp],rdx
    3e0c:	mov    rax,QWORD PTR [rsi+0x20]
    3e10:	mov    rsi,QWORD PTR [rax]
    3e13:	mov    QWORD PTR [rsp+0x8],rsi
    3e18:	mov    r13,rsi
    3e1b:	mov    QWORD PTR [rsp+0x10],0x3
    3e24:	mov    r10d,0x1
    3e2a:	test   rdx,0x1
    3e31:	je     3e3f <botlish_fn_22+0x4e>
    3e37:	mov    rbx,rdx
    3e3a:	jmp    3e64 <botlish_fn_22+0x73>
    3e3f:	xor    r10d,r10d
    3e42:	test   rdx,0x7
    3e49:	je     3e57 <botlish_fn_22+0x66>
    3e4f:	mov    rbx,rdx
    3e52:	jmp    3e64 <botlish_fn_22+0x73>
    3e57:	movzx  rax,BYTE PTR [rdx]
    3e5b:	mov    rbx,rdx
    3e5e:	cmp    al,0x1
    3e60:	sete   r10b
    3e64:	test   r10b,r10b
    3e67:	jne    3e88 <botlish_fn_22+0x97>
    3e6d:	mov    rax,QWORD PTR [rdi+0x10]
    3e71:	mov    rcx,QWORD PTR [rax+0x108]
    3e78:	xor    rdx,rdx
    3e7b:	mov    rsi,rbx
    3e7e:	call   3e83 <botlish_fn_22+0x92>
			3e7f: R_X86_64_PLT32	rt_type_error-0x4
    3e83:	jmp    3f3a <botlish_fn_22+0x149>
    3e88:	mov    rsi,rbx
    3e8b:	mov    r12,rdi
    3e8e:	test   rsi,0x1
    3e95:	je     3eb0 <botlish_fn_22+0xbf>
    3e9b:	mov    rsi,rbx
    3e9e:	mov    rcx,rsi
    3ea1:	add    rcx,0x2
    3ea5:	seto   al
    3ea8:	test   al,al
    3eaa:	je     3ec3 <botlish_fn_22+0xd2>
    3eb0:	mov    edx,0x3
    3eb5:	mov    rsi,rbx
    3eb8:	mov    rdi,r12
    3ebb:	call   3ec0 <botlish_fn_22+0xcf>
			3ebc: R_X86_64_PLT32	rt_int_add-0x4
    3ec0:	mov    rcx,rax
    3ec3:	mov    QWORD PTR [rsp+0x10],rcx
    3ec8:	mov    eax,0x1
    3ecd:	mov    rsi,rbx
    3ed0:	test   rsi,0x1
    3ed7:	jne    3efd <botlish_fn_22+0x10c>
    3edd:	xor    eax,eax
    3edf:	mov    rsi,rbx
    3ee2:	test   rsi,0x7
    3ee9:	jne    3efd <botlish_fn_22+0x10c>
    3eef:	mov    rsi,rbx
    3ef2:	movzx  rdx,BYTE PTR [rsi]
    3ef6:	rex cmp dl,0x1
    3efa:	sete   al
    3efd:	test   al,al
    3eff:	jne    3f23 <botlish_fn_22+0x132>
    3f05:	mov    rdi,r12
    3f08:	mov    rsi,QWORD PTR [rdi+0x10]
    3f0c:	mov    rcx,QWORD PTR [rsi+0x110]
    3f13:	xor    rdx,rdx
    3f16:	mov    rsi,rbx
    3f19:	call   3f1e <botlish_fn_22+0x12d>
			3f1a: R_X86_64_PLT32	rt_type_error-0x4
    3f1e:	jmp    3f3a <botlish_fn_22+0x149>
    3f23:	mov    rdx,rbx
    3f26:	mov    rsi,r13
    3f29:	mov    rdi,r12
    3f2c:	call   3f31 <botlish_fn_22+0x140>
			3f2d: R_X86_64_PLT32	rt_substr-0x4
    3f31:	test   rax,rax
    3f34:	jne    3f55 <botlish_fn_22+0x164>
    3f3a:	xor    rax,rax
    3f3d:	mov    rbx,QWORD PTR [rsp+0x20]
    3f42:	mov    r12,QWORD PTR [rsp+0x28]
    3f47:	mov    r13,QWORD PTR [rsp+0x30]
    3f4c:	add    rsp,0x40
    3f50:	mov    rsp,rbp
    3f53:	pop    rbp
    3f54:	ret
    3f55:	mov    rbx,QWORD PTR [rsp+0x20]
    3f5a:	mov    r12,QWORD PTR [rsp+0x28]
    3f5f:	mov    r13,QWORD PTR [rsp+0x30]
    3f64:	add    rsp,0x40
    3f68:	mov    rsp,rbp
    3f6b:	pop    rbp
    3f6c:	ret

0000000000003f6d <botlish_entry_22: char_at<generic>>:
    3f6d:	push   rbp
    3f6e:	mov    rbp,rsp
    3f71:	mov    rdx,QWORD PTR [rdx]
    3f74:	call   3f79 <botlish_entry_22+0xc>
			3f75: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    3f79:	mov    rsp,rbp
    3f7c:	pop    rbp
    3f7d:	ret

0000000000003f7e <botlish_fn_23: char_at<generic>>:
    3f7e:	push   rbp
    3f7f:	mov    rbp,rsp
    3f82:	sub    rsp,0x40
    3f86:	mov    QWORD PTR [rsp+0x20],rbx
    3f8b:	mov    QWORD PTR [rsp+0x28],r12
    3f90:	mov    QWORD PTR [rsp+0x30],r13
    3f95:	mov    QWORD PTR [rsp+0x38],r14
    3f9a:	mov    r13,rcx
    3f9d:	mov    QWORD PTR [rsp],rdx
    3fa1:	mov    rax,QWORD PTR [rsi+0x20]
    3fa5:	mov    rax,QWORD PTR [rax]
    3fa8:	mov    QWORD PTR [rsp+0x8],rax
    3fad:	mov    r14,rax
    3fb0:	mov    QWORD PTR [rsp+0x10],0x3
    3fb9:	mov    r11d,0x1
    3fbf:	test   rdx,0x1
    3fc6:	je     3fd4 <botlish_fn_23+0x56>
    3fcc:	mov    r12,rdx
    3fcf:	jmp    3ff9 <botlish_fn_23+0x7b>
    3fd4:	xor    r11d,r11d
    3fd7:	test   rdx,0x7
    3fde:	je     3fec <botlish_fn_23+0x6e>
    3fe4:	mov    r12,rdx
    3fe7:	jmp    3ff9 <botlish_fn_23+0x7b>
    3fec:	movzx  rax,BYTE PTR [rdx]
    3ff0:	mov    r12,rdx
    3ff3:	cmp    al,0x1
    3ff5:	sete   r11b
    3ff9:	test   r11b,r11b
    3ffc:	jne    401d <botlish_fn_23+0x9f>
    4002:	mov    rax,QWORD PTR [rdi+0x10]
    4006:	mov    rcx,QWORD PTR [rax+0x108]
    400d:	xor    rdx,rdx
    4010:	mov    rsi,r12
    4013:	call   4018 <botlish_fn_23+0x9a>
			4014: R_X86_64_PLT32	rt_type_error-0x4
    4018:	jmp    40d5 <botlish_fn_23+0x157>
    401d:	mov    rbx,rdi
    4020:	mov    rsi,r12
    4023:	test   rsi,0x1
    402a:	jne    4038 <botlish_fn_23+0xba>
    4030:	mov    r12,rsi
    4033:	jmp    404d <botlish_fn_23+0xcf>
    4038:	mov    rax,rsi
    403b:	add    rax,0x2
    403f:	mov    r12,rsi
    4042:	seto   cl
    4045:	test   cl,cl
    4047:	je     405d <botlish_fn_23+0xdf>
    404d:	mov    edx,0x3
    4052:	mov    rsi,r12
    4055:	mov    rdi,rbx
    4058:	call   405d <botlish_fn_23+0xdf>
			4059: R_X86_64_PLT32	rt_int_add-0x4
    405d:	mov    ecx,0x1
    4062:	mov    rsi,r12
    4065:	test   rsi,0x1
    406c:	jne    4092 <botlish_fn_23+0x114>
    4072:	xor    ecx,ecx
    4074:	mov    rsi,r12
    4077:	test   rsi,0x7
    407e:	jne    4092 <botlish_fn_23+0x114>
    4084:	mov    rsi,r12
    4087:	movzx  rdx,BYTE PTR [rsi]
    408b:	rex cmp dl,0x1
    408f:	sete   cl
    4092:	test   cl,cl
    4094:	jne    40b8 <botlish_fn_23+0x13a>
    409a:	mov    rdi,rbx
    409d:	mov    rsi,QWORD PTR [rdi+0x10]
    40a1:	mov    rcx,QWORD PTR [rsi+0x110]
    40a8:	xor    rdx,rdx
    40ab:	mov    rsi,r12
    40ae:	call   40b3 <botlish_fn_23+0x135>
			40af: R_X86_64_PLT32	rt_type_error-0x4
    40b3:	jmp    40d5 <botlish_fn_23+0x157>
    40b8:	mov    rdi,rbx
    40bb:	mov    rbx,rax
    40be:	mov    rcx,rbx
    40c1:	mov    rdx,r12
    40c4:	mov    rsi,r14
    40c7:	call   40cc <botlish_fn_23+0x14e>
			40c8: R_X86_64_PLT32	rt_str_region_check-0x4
    40cc:	test   rax,rax
    40cf:	jne    40f5 <botlish_fn_23+0x177>
    40d5:	xor    rax,rax
    40d8:	mov    rbx,QWORD PTR [rsp+0x20]
    40dd:	mov    r12,QWORD PTR [rsp+0x28]
    40e2:	mov    r13,QWORD PTR [rsp+0x30]
    40e7:	mov    r14,QWORD PTR [rsp+0x38]
    40ec:	add    rsp,0x40
    40f0:	mov    rsp,rbp
    40f3:	pop    rbp
    40f4:	ret
    40f5:	mov    rcx,r13
    40f8:	mov    rsi,r12
    40fb:	mov    QWORD PTR [rcx],rsi
    40fe:	mov    QWORD PTR [rcx+0x8],rbx
    4102:	mov    rax,r14
    4105:	mov    rbx,QWORD PTR [rsp+0x20]
    410a:	mov    r12,QWORD PTR [rsp+0x28]
    410f:	mov    r13,QWORD PTR [rsp+0x30]
    4114:	mov    r14,QWORD PTR [rsp+0x38]
    4119:	add    rsp,0x40
    411d:	mov    rsp,rbp
    4120:	pop    rbp
    4121:	ret

0000000000004122 <botlish_entry_23: char_at<generic>>:
    4122:	push   rbp
    4123:	mov    rbp,rsp
    4126:	ud2

0000000000004128 <botlish_fn_24: is_local_char<str>>:
    4128:	push   rbp
    4129:	mov    rbp,rsp
    412c:	sub    rsp,0x10
    4130:	mov    QWORD PTR [rsp],rbx
    4134:	mov    QWORD PTR [rsp+0x8],r12
    4139:	mov    rbx,rsi
    413c:	mov    r12,rdi
    413f:	mov    rsi,rbx
    4142:	mov    rdi,r12
    4145:	call   414a <botlish_fn_24+0x22>
			4146: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    414a:	test   rax,rax
    414d:	jne    4168 <botlish_fn_24+0x40>
    4153:	xor    rax,rax
    4156:	mov    rbx,QWORD PTR [rsp]
    415a:	mov    r12,QWORD PTR [rsp+0x8]
    415f:	add    rsp,0x10
    4163:	mov    rsp,rbp
    4166:	pop    rbp
    4167:	ret
    4168:	cmp    rax,0x6
    416c:	je     4267 <botlish_fn_24+0x13f>
    4172:	mov    rdi,r12
    4175:	mov    rax,QWORD PTR [rdi+0x10]
    4179:	mov    rsi,QWORD PTR [rax+0x118]
    4180:	mov    edx,0x1
    4185:	mov    ecx,0x3
    418a:	mov    r8,rbx
    418d:	call   4192 <botlish_fn_24+0x6a>
			418e: R_X86_64_PLT32	rt_str_region_eq-0x4
    4192:	cmp    rax,0x6
    4196:	je     425d <botlish_fn_24+0x135>
    419c:	mov    rdi,r12
    419f:	mov    rax,QWORD PTR [rdi+0x10]
    41a3:	mov    rsi,QWORD PTR [rax+0x120]
    41aa:	mov    edx,0x1
    41af:	mov    ecx,0x3
    41b4:	mov    r8,rbx
    41b7:	call   41bc <botlish_fn_24+0x94>
			41b8: R_X86_64_PLT32	rt_str_region_eq-0x4
    41bc:	cmp    rax,0x6
    41c0:	je     4253 <botlish_fn_24+0x12b>
    41c6:	mov    rdi,r12
    41c9:	mov    rax,QWORD PTR [rdi+0x10]
    41cd:	mov    rsi,QWORD PTR [rax+0xc0]
    41d4:	mov    edx,0x1
    41d9:	mov    ecx,0x3
    41de:	mov    r8,rbx
    41e1:	call   41e6 <botlish_fn_24+0xbe>
			41e2: R_X86_64_PLT32	rt_str_region_eq-0x4
    41e6:	cmp    rax,0x6
    41ea:	je     4249 <botlish_fn_24+0x121>
    41f0:	mov    rdi,r12
    41f3:	mov    rax,QWORD PTR [rdi+0x10]
    41f7:	mov    rsi,QWORD PTR [rax+0x108]
    41fe:	mov    edx,0x1
    4203:	mov    ecx,0x3
    4208:	mov    r8,rbx
    420b:	call   4210 <botlish_fn_24+0xe8>
			420c: R_X86_64_PLT32	rt_str_region_eq-0x4
    4210:	cmp    rax,0x6
    4214:	je     423f <botlish_fn_24+0x117>
    421a:	mov    rdi,r12
    421d:	mov    rax,QWORD PTR [rdi+0x10]
    4221:	mov    rsi,QWORD PTR [rax+0x128]
    4228:	mov    edx,0x1
    422d:	mov    ecx,0x3
    4232:	mov    r8,rbx
    4235:	call   423a <botlish_fn_24+0x112>
			4236: R_X86_64_PLT32	rt_str_region_eq-0x4
    423a:	jmp    426c <botlish_fn_24+0x144>
    423f:	mov    eax,0x6
    4244:	jmp    426c <botlish_fn_24+0x144>
    4249:	mov    eax,0x6
    424e:	jmp    426c <botlish_fn_24+0x144>
    4253:	mov    eax,0x6
    4258:	jmp    426c <botlish_fn_24+0x144>
    425d:	mov    eax,0x6
    4262:	jmp    426c <botlish_fn_24+0x144>
    4267:	mov    eax,0x6
    426c:	mov    rbx,QWORD PTR [rsp]
    4270:	mov    r12,QWORD PTR [rsp+0x8]
    4275:	add    rsp,0x10
    4279:	mov    rsp,rbp
    427c:	pop    rbp
    427d:	ret

000000000000427e <botlish_entry_24: is_local_char<str>>:
    427e:	push   rbp
    427f:	mov    rbp,rsp
    4282:	mov    rsi,QWORD PTR [rdx]
    4285:	call   428a <botlish_entry_24+0xc>
			4286: R_X86_64_PLT32	botlish_fn_24-0x4 ; is_local_char<str>
    428a:	mov    rsp,rbp
    428d:	pop    rbp
    428e:	ret

000000000000428f <botlish_fn_25: is_label_char<str>>:
    428f:	push   rbp
    4290:	mov    rbp,rsp
    4293:	sub    rsp,0x10
    4297:	mov    QWORD PTR [rsp],r13
    429b:	mov    QWORD PTR [rsp+0x8],r15
    42a0:	mov    r13,rsi
    42a3:	mov    r15,rdi
    42a6:	mov    rsi,r13
    42a9:	mov    rdi,r15
    42ac:	call   42b1 <botlish_fn_25+0x22>
			42ad: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    42b1:	test   rax,rax
    42b4:	jne    42cf <botlish_fn_25+0x40>
    42ba:	xor    rax,rax
    42bd:	mov    r13,QWORD PTR [rsp]
    42c1:	mov    r15,QWORD PTR [rsp+0x8]
    42c6:	add    rsp,0x10
    42ca:	mov    rsp,rbp
    42cd:	pop    rbp
    42ce:	ret
    42cf:	cmp    rax,0x6
    42d3:	je     42fe <botlish_fn_25+0x6f>
    42d9:	mov    rdi,r15
    42dc:	mov    rax,QWORD PTR [rdi+0x10]
    42e0:	mov    rsi,QWORD PTR [rax+0x128]
    42e7:	mov    edx,0x1
    42ec:	mov    ecx,0x3
    42f1:	mov    r8,r13
    42f4:	call   42f9 <botlish_fn_25+0x6a>
			42f5: R_X86_64_PLT32	rt_str_region_eq-0x4
    42f9:	jmp    4303 <botlish_fn_25+0x74>
    42fe:	mov    eax,0x6
    4303:	mov    r13,QWORD PTR [rsp]
    4307:	mov    r15,QWORD PTR [rsp+0x8]
    430c:	add    rsp,0x10
    4310:	mov    rsp,rbp
    4313:	pop    rbp
    4314:	ret

0000000000004315 <botlish_entry_25: is_label_char<str>>:
    4315:	push   rbp
    4316:	mov    rbp,rsp
    4319:	mov    rsi,QWORD PTR [rdx]
    431c:	call   4321 <botlish_entry_25+0xc>
			431d: R_X86_64_PLT32	botlish_fn_25-0x4 ; is_label_char<str>
    4321:	mov    rsp,rbp
    4324:	pop    rbp
    4325:	ret
	...

0000000000004328 <botlish_fn_26: scan_local<generic>>:
    4328:	push   rbp
    4329:	mov    rbp,rsp
    432c:	sub    rsp,0x40
    4330:	mov    QWORD PTR [rsp+0x20],rbx
    4335:	mov    QWORD PTR [rsp+0x28],r12
    433a:	mov    QWORD PTR [rsp+0x30],r13
    433f:	mov    r12,rdi
    4342:	mov    QWORD PTR [rsp+0x10],0x0
    434b:	mov    QWORD PTR [rsp],rdx
    434f:	mov    rbx,rsi
    4352:	mov    rsi,rdx
    4355:	mov    rax,QWORD PTR [rbx+0x20]
    4359:	mov    rdx,QWORD PTR [rax]
    435c:	mov    r10d,0x1
    4362:	test   rsi,0x1
    4369:	jne    4389 <botlish_fn_26+0x61>
    436f:	xor    r10d,r10d
    4372:	test   rsi,0x7
    4379:	jne    4389 <botlish_fn_26+0x61>
    437f:	movzx  rax,BYTE PTR [rsi]
    4383:	cmp    al,0x1
    4385:	sete   r10b
    4389:	test   r10b,r10b
    438c:	jne    43ad <botlish_fn_26+0x85>
    4392:	mov    rdi,r12
    4395:	mov    rax,QWORD PTR [rdi+0x10]
    4399:	mov    rcx,QWORD PTR [rax+0xb8]
    43a0:	xor    rdx,rdx
    43a3:	call   43a8 <botlish_fn_26+0x80>
			43a4: R_X86_64_PLT32	rt_type_error-0x4
    43a8:	jmp    4434 <botlish_fn_26+0x10c>
    43ad:	mov    rax,rsi
    43b0:	and    rax,rdx
    43b3:	mov    r13,rsi
    43b6:	test   rax,0x1
    43bc:	jne    43e2 <botlish_fn_26+0xba>
    43c2:	mov    rsi,r13
    43c5:	mov    rdi,r12
    43c8:	call   43cd <botlish_fn_26+0xa5>
			43c9: R_X86_64_PLT32	rt_int_cmp-0x4
    43cd:	mov    ecx,0x2
    43d2:	test   rax,rax
    43d5:	cmovge rcx,QWORD PTR [rip+0x103]        # 44e0 <botlish_fn_26+0x1b8>
    43dd:	jmp    43f5 <botlish_fn_26+0xcd>
    43e2:	mov    ecx,0x2
    43e7:	mov    rsi,r13
    43ea:	cmp    rsi,rdx
    43ed:	cmovge rcx,QWORD PTR [rip+0xeb]        # 44e0 <botlish_fn_26+0x1b8>
    43f5:	cmp    rcx,0x6
    43f9:	je     44c1 <botlish_fn_26+0x199>
    43ff:	mov    rax,QWORD PTR [rbx+0x20]
    4403:	mov    rsi,QWORD PTR [rax+0x8]
    4407:	mov    QWORD PTR [rsp+0x8],rsi
    440c:	mov    rdx,r13
    440f:	mov    rdi,r12
    4412:	call   4417 <botlish_fn_26+0xef>
			4413: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    4417:	test   rax,rax
    441a:	mov    rsi,rax
    441d:	je     4434 <botlish_fn_26+0x10c>
    4423:	mov    rdi,r12
    4426:	call   442b <botlish_fn_26+0x103>
			4427: R_X86_64_PLT32	botlish_fn_24-0x4 ; is_local_char<str>
    442b:	test   rax,rax
    442e:	jne    444f <botlish_fn_26+0x127>
    4434:	xor    rax,rax
    4437:	mov    rbx,QWORD PTR [rsp+0x20]
    443c:	mov    r12,QWORD PTR [rsp+0x28]
    4441:	mov    r13,QWORD PTR [rsp+0x30]
    4446:	add    rsp,0x40
    444a:	mov    rsp,rbp
    444d:	pop    rbp
    444e:	ret
    444f:	cmp    rax,0x6
    4453:	je     4461 <botlish_fn_26+0x139>
    4459:	mov    rax,r13
    445c:	jmp    44c4 <botlish_fn_26+0x19c>
    4461:	mov    QWORD PTR [rsp+0x8],rbx
    4466:	mov    QWORD PTR [rsp+0x10],0x3
    446f:	mov    rsi,r13
    4472:	test   rsi,0x1
    4479:	je     449f <botlish_fn_26+0x177>
    447f:	mov    rsi,r13
    4482:	mov    r11,rsi
    4485:	add    r11,0x2
    4489:	seto   al
    448c:	test   al,al
    448e:	jne    449f <botlish_fn_26+0x177>
    4494:	mov    rsi,r11
    4497:	mov    r13,r11
    449a:	jmp    44b5 <botlish_fn_26+0x18d>
    449f:	mov    edx,0x3
    44a4:	mov    rsi,r13
    44a7:	mov    rdi,r12
    44aa:	call   44af <botlish_fn_26+0x187>
			44ab: R_X86_64_PLT32	rt_int_add-0x4
    44af:	mov    rsi,rax
    44b2:	mov    r13,rax
    44b5:	mov    QWORD PTR [rsp],rsi
    44b9:	mov    rsi,r13
    44bc:	jmp    4355 <botlish_fn_26+0x2d>
    44c1:	mov    rax,r13
    44c4:	mov    rbx,QWORD PTR [rsp+0x20]
    44c9:	mov    r12,QWORD PTR [rsp+0x28]
    44ce:	mov    r13,QWORD PTR [rsp+0x30]
    44d3:	add    rsp,0x40
    44d7:	mov    rsp,rbp
    44da:	pop    rbp
    44db:	ret
    44dc:	add    BYTE PTR [rax],al
    44de:	add    BYTE PTR [rax],al
    44e0:	(bad)
    44e1:	add    BYTE PTR [rax],al
    44e3:	add    BYTE PTR [rax],al
    44e5:	add    BYTE PTR [rax],al
	...

00000000000044e8 <botlish_entry_26: scan_local<generic>>:
    44e8:	push   rbp
    44e9:	mov    rbp,rsp
    44ec:	mov    rdx,QWORD PTR [rdx]
    44ef:	call   44f4 <botlish_entry_26+0xc>
			44f0: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    44f4:	mov    rsp,rbp
    44f7:	pop    rbp
    44f8:	ret
    44f9:	add    BYTE PTR [rax],al
    44fb:	add    BYTE PTR [rax],al
    44fd:	add    BYTE PTR [rax],al
	...

0000000000004500 <botlish_fn_27: scan_label<generic>>:
    4500:	push   rbp
    4501:	mov    rbp,rsp
    4504:	sub    rsp,0x40
    4508:	mov    QWORD PTR [rsp+0x20],rbx
    450d:	mov    QWORD PTR [rsp+0x28],r12
    4512:	mov    QWORD PTR [rsp+0x30],r13
    4517:	mov    r12,rdi
    451a:	mov    QWORD PTR [rsp+0x10],0x0
    4523:	mov    QWORD PTR [rsp],rdx
    4527:	mov    rbx,rsi
    452a:	mov    rsi,rdx
    452d:	mov    rax,QWORD PTR [rbx+0x20]
    4531:	mov    rdx,QWORD PTR [rax]
    4534:	mov    r10d,0x1
    453a:	test   rsi,0x1
    4541:	jne    4561 <botlish_fn_27+0x61>
    4547:	xor    r10d,r10d
    454a:	test   rsi,0x7
    4551:	jne    4561 <botlish_fn_27+0x61>
    4557:	movzx  rax,BYTE PTR [rsi]
    455b:	cmp    al,0x1
    455d:	sete   r10b
    4561:	test   r10b,r10b
    4564:	jne    4585 <botlish_fn_27+0x85>
    456a:	mov    rdi,r12
    456d:	mov    rax,QWORD PTR [rdi+0x10]
    4571:	mov    rcx,QWORD PTR [rax+0xb8]
    4578:	xor    rdx,rdx
    457b:	call   4580 <botlish_fn_27+0x80>
			457c: R_X86_64_PLT32	rt_type_error-0x4
    4580:	jmp    460c <botlish_fn_27+0x10c>
    4585:	mov    rax,rsi
    4588:	and    rax,rdx
    458b:	mov    r13,rsi
    458e:	test   rax,0x1
    4594:	jne    45ba <botlish_fn_27+0xba>
    459a:	mov    rsi,r13
    459d:	mov    rdi,r12
    45a0:	call   45a5 <botlish_fn_27+0xa5>
			45a1: R_X86_64_PLT32	rt_int_cmp-0x4
    45a5:	mov    ecx,0x2
    45aa:	test   rax,rax
    45ad:	cmovge rcx,QWORD PTR [rip+0x103]        # 46b8 <botlish_fn_27+0x1b8>
    45b5:	jmp    45cd <botlish_fn_27+0xcd>
    45ba:	mov    ecx,0x2
    45bf:	mov    rsi,r13
    45c2:	cmp    rsi,rdx
    45c5:	cmovge rcx,QWORD PTR [rip+0xeb]        # 46b8 <botlish_fn_27+0x1b8>
    45cd:	cmp    rcx,0x6
    45d1:	je     4699 <botlish_fn_27+0x199>
    45d7:	mov    rax,QWORD PTR [rbx+0x20]
    45db:	mov    rsi,QWORD PTR [rax+0x8]
    45df:	mov    QWORD PTR [rsp+0x8],rsi
    45e4:	mov    rdx,r13
    45e7:	mov    rdi,r12
    45ea:	call   45ef <botlish_fn_27+0xef>
			45eb: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    45ef:	test   rax,rax
    45f2:	mov    rsi,rax
    45f5:	je     460c <botlish_fn_27+0x10c>
    45fb:	mov    rdi,r12
    45fe:	call   4603 <botlish_fn_27+0x103>
			45ff: R_X86_64_PLT32	botlish_fn_25-0x4 ; is_label_char<str>
    4603:	test   rax,rax
    4606:	jne    4627 <botlish_fn_27+0x127>
    460c:	xor    rax,rax
    460f:	mov    rbx,QWORD PTR [rsp+0x20]
    4614:	mov    r12,QWORD PTR [rsp+0x28]
    4619:	mov    r13,QWORD PTR [rsp+0x30]
    461e:	add    rsp,0x40
    4622:	mov    rsp,rbp
    4625:	pop    rbp
    4626:	ret
    4627:	cmp    rax,0x6
    462b:	je     4639 <botlish_fn_27+0x139>
    4631:	mov    rax,r13
    4634:	jmp    469c <botlish_fn_27+0x19c>
    4639:	mov    QWORD PTR [rsp+0x8],rbx
    463e:	mov    QWORD PTR [rsp+0x10],0x3
    4647:	mov    rsi,r13
    464a:	test   rsi,0x1
    4651:	je     4677 <botlish_fn_27+0x177>
    4657:	mov    rsi,r13
    465a:	mov    r11,rsi
    465d:	add    r11,0x2
    4661:	seto   al
    4664:	test   al,al
    4666:	jne    4677 <botlish_fn_27+0x177>
    466c:	mov    rsi,r11
    466f:	mov    r13,r11
    4672:	jmp    468d <botlish_fn_27+0x18d>
    4677:	mov    edx,0x3
    467c:	mov    rsi,r13
    467f:	mov    rdi,r12
    4682:	call   4687 <botlish_fn_27+0x187>
			4683: R_X86_64_PLT32	rt_int_add-0x4
    4687:	mov    rsi,rax
    468a:	mov    r13,rax
    468d:	mov    QWORD PTR [rsp],rsi
    4691:	mov    rsi,r13
    4694:	jmp    452d <botlish_fn_27+0x2d>
    4699:	mov    rax,r13
    469c:	mov    rbx,QWORD PTR [rsp+0x20]
    46a1:	mov    r12,QWORD PTR [rsp+0x28]
    46a6:	mov    r13,QWORD PTR [rsp+0x30]
    46ab:	add    rsp,0x40
    46af:	mov    rsp,rbp
    46b2:	pop    rbp
    46b3:	ret
    46b4:	add    BYTE PTR [rax],al
    46b6:	add    BYTE PTR [rax],al
    46b8:	(bad)
    46b9:	add    BYTE PTR [rax],al
    46bb:	add    BYTE PTR [rax],al
    46bd:	add    BYTE PTR [rax],al
	...

00000000000046c0 <botlish_entry_27: scan_label<generic>>:
    46c0:	push   rbp
    46c1:	mov    rbp,rsp
    46c4:	mov    rdx,QWORD PTR [rdx]
    46c7:	call   46cc <botlish_entry_27+0xc>
			46c8: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_label<generic>
    46cc:	mov    rsp,rbp
    46cf:	pop    rbp
    46d0:	ret
    46d1:	add    BYTE PTR [rax],al
    46d3:	add    BYTE PTR [rax],al
    46d5:	add    BYTE PTR [rax],al
	...

00000000000046d8 <botlish_fn_28: scan_alpha<generic>>:
    46d8:	push   rbp
    46d9:	mov    rbp,rsp
    46dc:	sub    rsp,0x40
    46e0:	mov    QWORD PTR [rsp+0x20],rbx
    46e5:	mov    QWORD PTR [rsp+0x28],r12
    46ea:	mov    QWORD PTR [rsp+0x30],r13
    46ef:	mov    r12,rdi
    46f2:	mov    QWORD PTR [rsp+0x10],0x0
    46fb:	mov    QWORD PTR [rsp],rdx
    46ff:	mov    rbx,rsi
    4702:	mov    rsi,rdx
    4705:	mov    rax,QWORD PTR [rbx+0x20]
    4709:	mov    rdx,QWORD PTR [rax]
    470c:	mov    r10d,0x1
    4712:	test   rsi,0x1
    4719:	jne    4739 <botlish_fn_28+0x61>
    471f:	xor    r10d,r10d
    4722:	test   rsi,0x7
    4729:	jne    4739 <botlish_fn_28+0x61>
    472f:	movzx  rax,BYTE PTR [rsi]
    4733:	cmp    al,0x1
    4735:	sete   r10b
    4739:	test   r10b,r10b
    473c:	jne    475d <botlish_fn_28+0x85>
    4742:	mov    rdi,r12
    4745:	mov    rax,QWORD PTR [rdi+0x10]
    4749:	mov    rcx,QWORD PTR [rax+0xb8]
    4750:	xor    rdx,rdx
    4753:	call   4758 <botlish_fn_28+0x80>
			4754: R_X86_64_PLT32	rt_type_error-0x4
    4758:	jmp    47e4 <botlish_fn_28+0x10c>
    475d:	mov    rax,rsi
    4760:	and    rax,rdx
    4763:	mov    r13,rsi
    4766:	test   rax,0x1
    476c:	jne    4792 <botlish_fn_28+0xba>
    4772:	mov    rsi,r13
    4775:	mov    rdi,r12
    4778:	call   477d <botlish_fn_28+0xa5>
			4779: R_X86_64_PLT32	rt_int_cmp-0x4
    477d:	mov    ecx,0x2
    4782:	test   rax,rax
    4785:	cmovge rcx,QWORD PTR [rip+0x103]        # 4890 <botlish_fn_28+0x1b8>
    478d:	jmp    47a5 <botlish_fn_28+0xcd>
    4792:	mov    ecx,0x2
    4797:	mov    rsi,r13
    479a:	cmp    rsi,rdx
    479d:	cmovge rcx,QWORD PTR [rip+0xeb]        # 4890 <botlish_fn_28+0x1b8>
    47a5:	cmp    rcx,0x6
    47a9:	je     4871 <botlish_fn_28+0x199>
    47af:	mov    rax,QWORD PTR [rbx+0x20]
    47b3:	mov    rsi,QWORD PTR [rax+0x8]
    47b7:	mov    QWORD PTR [rsp+0x8],rsi
    47bc:	mov    rdx,r13
    47bf:	mov    rdi,r12
    47c2:	call   47c7 <botlish_fn_28+0xef>
			47c3: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    47c7:	test   rax,rax
    47ca:	mov    rsi,rax
    47cd:	je     47e4 <botlish_fn_28+0x10c>
    47d3:	mov    rdi,r12
    47d6:	call   47db <botlish_fn_28+0x103>
			47d7: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    47db:	test   rax,rax
    47de:	jne    47ff <botlish_fn_28+0x127>
    47e4:	xor    rax,rax
    47e7:	mov    rbx,QWORD PTR [rsp+0x20]
    47ec:	mov    r12,QWORD PTR [rsp+0x28]
    47f1:	mov    r13,QWORD PTR [rsp+0x30]
    47f6:	add    rsp,0x40
    47fa:	mov    rsp,rbp
    47fd:	pop    rbp
    47fe:	ret
    47ff:	cmp    rax,0x6
    4803:	je     4811 <botlish_fn_28+0x139>
    4809:	mov    rax,r13
    480c:	jmp    4874 <botlish_fn_28+0x19c>
    4811:	mov    QWORD PTR [rsp+0x8],rbx
    4816:	mov    QWORD PTR [rsp+0x10],0x3
    481f:	mov    rsi,r13
    4822:	test   rsi,0x1
    4829:	je     484f <botlish_fn_28+0x177>
    482f:	mov    rsi,r13
    4832:	mov    r11,rsi
    4835:	add    r11,0x2
    4839:	seto   al
    483c:	test   al,al
    483e:	jne    484f <botlish_fn_28+0x177>
    4844:	mov    rsi,r11
    4847:	mov    r13,r11
    484a:	jmp    4865 <botlish_fn_28+0x18d>
    484f:	mov    edx,0x3
    4854:	mov    rsi,r13
    4857:	mov    rdi,r12
    485a:	call   485f <botlish_fn_28+0x187>
			485b: R_X86_64_PLT32	rt_int_add-0x4
    485f:	mov    rsi,rax
    4862:	mov    r13,rax
    4865:	mov    QWORD PTR [rsp],rsi
    4869:	mov    rsi,r13
    486c:	jmp    4705 <botlish_fn_28+0x2d>
    4871:	mov    rax,r13
    4874:	mov    rbx,QWORD PTR [rsp+0x20]
    4879:	mov    r12,QWORD PTR [rsp+0x28]
    487e:	mov    r13,QWORD PTR [rsp+0x30]
    4883:	add    rsp,0x40
    4887:	mov    rsp,rbp
    488a:	pop    rbp
    488b:	ret
    488c:	add    BYTE PTR [rax],al
    488e:	add    BYTE PTR [rax],al
    4890:	(bad)
    4891:	add    BYTE PTR [rax],al
    4893:	add    BYTE PTR [rax],al
    4895:	add    BYTE PTR [rax],al
	...

0000000000004898 <botlish_entry_28: scan_alpha<generic>>:
    4898:	push   rbp
    4899:	mov    rbp,rsp
    489c:	mov    rdx,QWORD PTR [rdx]
    489f:	call   48a4 <botlish_entry_28+0xc>
			48a0: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_alpha<generic>
    48a4:	mov    rsp,rbp
    48a7:	pop    rbp
    48a8:	ret
    48a9:	add    BYTE PTR [rax],al
    48ab:	add    BYTE PTR [rax],al
    48ad:	add    BYTE PTR [rax],al
	...

00000000000048b0 <botlish_fn_29: tld_ok<generic>>:
    48b0:	push   rbp
    48b1:	mov    rbp,rsp
    48b4:	sub    rsp,0x30
    48b8:	mov    QWORD PTR [rsp+0x10],rbx
    48bd:	mov    QWORD PTR [rsp+0x18],r12
    48c2:	mov    QWORD PTR [rsp+0x20],r13
    48c7:	mov    QWORD PTR [rsp+0x28],r14
    48cc:	mov    r12,rdi
    48cf:	mov    QWORD PTR [rsp],rdx
    48d3:	mov    r9,rdx
    48d6:	mov    rax,QWORD PTR [rsi+0x20]
    48da:	mov    r14,rsi
    48dd:	mov    rsi,QWORD PTR [rax]
    48e0:	mov    QWORD PTR [rsp+0x8],rsi
    48e5:	mov    rbx,r9
    48e8:	mov    rdx,rbx
    48eb:	mov    rdi,r12
    48ee:	call   48f3 <botlish_fn_29+0x43>
			48ef: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_alpha<generic>
    48f3:	mov    rsi,rax
    48f6:	mov    r13,rax
    48f9:	test   rax,rsi
    48fc:	je     49d4 <botlish_fn_29+0x124>
    4902:	mov    rax,r13
    4905:	mov    QWORD PTR [rsp+0x8],rax
    490a:	mov    rsi,r14
    490d:	mov    rax,QWORD PTR [rsi+0x20]
    4911:	mov    rdx,QWORD PTR [rax+0x8]
    4915:	mov    rax,r13
    4918:	and    rax,rdx
    491b:	test   rax,0x1
    4921:	jne    494a <botlish_fn_29+0x9a>
    4927:	mov    rsi,r13
    492a:	mov    rdi,r12
    492d:	call   4932 <botlish_fn_29+0x82>
			492e: R_X86_64_PLT32	rt_int_cmp-0x4
    4932:	mov    ecx,0x2
    4937:	test   rax,rax
    493a:	cmove  rcx,QWORD PTR [rip+0x166]        # 4aa8 <botlish_fn_29+0x1f8>
    4942:	mov    rax,r13
    4945:	jmp    495d <botlish_fn_29+0xad>
    494a:	mov    ecx,0x2
    494f:	mov    rax,r13
    4952:	cmp    rax,rdx
    4955:	cmove  rcx,QWORD PTR [rip+0x14b]        # 4aa8 <botlish_fn_29+0x1f8>
    495d:	cmp    rcx,0x6
    4961:	je     4974 <botlish_fn_29+0xc4>
    4967:	mov    ecx,0x2
    496c:	mov    rax,rcx
    496f:	jmp    4a84 <botlish_fn_29+0x1d4>
    4974:	mov    ecx,0x1
    4979:	test   rbx,0x1
    4980:	je     498e <botlish_fn_29+0xde>
    4986:	mov    r9,rbx
    4989:	jmp    49b3 <botlish_fn_29+0x103>
    498e:	xor    ecx,ecx
    4990:	test   rbx,0x7
    4997:	je     49a5 <botlish_fn_29+0xf5>
    499d:	mov    r9,rbx
    49a0:	jmp    49b3 <botlish_fn_29+0x103>
    49a5:	movzx  rdx,BYTE PTR [rbx]
    49a9:	mov    r9,rbx
    49ac:	rex cmp dl,0x1
    49b0:	sete   cl
    49b3:	test   cl,cl
    49b5:	jne    49f4 <botlish_fn_29+0x144>
    49bb:	mov    rdi,r12
    49be:	mov    rsi,QWORD PTR [rdi+0x10]
    49c2:	mov    rcx,QWORD PTR [rsi+0x128]
    49c9:	xor    rdx,rdx
    49cc:	mov    rsi,r9
    49cf:	call   49d4 <botlish_fn_29+0x124>
			49d0: R_X86_64_PLT32	rt_type_error-0x4
    49d4:	xor    rax,rax
    49d7:	mov    rbx,QWORD PTR [rsp+0x10]
    49dc:	mov    r12,QWORD PTR [rsp+0x18]
    49e1:	mov    r13,QWORD PTR [rsp+0x20]
    49e6:	mov    r14,QWORD PTR [rsp+0x28]
    49eb:	add    rsp,0x30
    49ef:	mov    rsp,rbp
    49f2:	pop    rbp
    49f3:	ret
    49f4:	mov    rbx,r9
    49f7:	mov    r8,rax
    49fa:	and    r8,rbx
    49fd:	test   r8,0x1
    4a04:	jne    4a15 <botlish_fn_29+0x165>
    4a0a:	mov    rdx,r9
    4a0d:	mov    rsi,rax
    4a10:	jmp    4a36 <botlish_fn_29+0x186>
    4a15:	mov    rbx,r9
    4a18:	mov    r10,rax
    4a1b:	sub    r10,rbx
    4a1e:	mov    r13,rax
    4a21:	seto   al
    4a24:	lea    rsi,[r10+0x1]
    4a28:	test   al,al
    4a2a:	je     4a41 <botlish_fn_29+0x191>
    4a30:	mov    rdx,r9
    4a33:	mov    rsi,r13
    4a36:	mov    rdi,r12
    4a39:	call   4a3e <botlish_fn_29+0x18e>
			4a3a: R_X86_64_PLT32	rt_int_sub-0x4
    4a3e:	mov    rsi,rax
    4a41:	test   rsi,0x1
    4a48:	jne    4a73 <botlish_fn_29+0x1c3>
    4a4e:	mov    edx,0x5
    4a53:	mov    rdi,r12
    4a56:	call   4a5b <botlish_fn_29+0x1ab>
			4a57: R_X86_64_PLT32	rt_int_cmp-0x4
    4a5b:	mov    ecx,0x2
    4a60:	test   rax,rax
    4a63:	mov    rax,rcx
    4a66:	cmovge rax,QWORD PTR [rip+0x3a]        # 4aa8 <botlish_fn_29+0x1f8>
    4a6e:	jmp    4a84 <botlish_fn_29+0x1d4>
    4a73:	mov    eax,0x2
    4a78:	cmp    rsi,0x5
    4a7c:	cmovge rax,QWORD PTR [rip+0x24]        # 4aa8 <botlish_fn_29+0x1f8>
    4a84:	mov    rbx,QWORD PTR [rsp+0x10]
    4a89:	mov    r12,QWORD PTR [rsp+0x18]
    4a8e:	mov    r13,QWORD PTR [rsp+0x20]
    4a93:	mov    r14,QWORD PTR [rsp+0x28]
    4a98:	add    rsp,0x30
    4a9c:	mov    rsp,rbp
    4a9f:	pop    rbp
    4aa0:	ret
    4aa1:	add    BYTE PTR [rax],al
    4aa3:	add    BYTE PTR [rax],al
    4aa5:	add    BYTE PTR [rax],al
    4aa7:	add    BYTE PTR [rsi],al
    4aa9:	add    BYTE PTR [rax],al
    4aab:	add    BYTE PTR [rax],al
    4aad:	add    BYTE PTR [rax],al
	...

0000000000004ab0 <botlish_entry_29: tld_ok<generic>>:
    4ab0:	push   rbp
    4ab1:	mov    rbp,rsp
    4ab4:	mov    rdx,QWORD PTR [rdx]
    4ab7:	call   4abc <botlish_entry_29+0xc>
			4ab8: R_X86_64_PLT32	botlish_fn_29-0x4 ; tld_ok<generic>
    4abc:	mov    rsp,rbp
    4abf:	pop    rbp
    4ac0:	ret
    4ac1:	add    BYTE PTR [rax],al
    4ac3:	add    BYTE PTR [rax],al
    4ac5:	add    BYTE PTR [rax],al
	...

0000000000004ac8 <botlish_fn_30: domain_loop<generic>>:
    4ac8:	push   rbp
    4ac9:	mov    rbp,rsp
    4acc:	sub    rsp,0x50
    4ad0:	mov    QWORD PTR [rsp+0x20],rbx
    4ad5:	mov    QWORD PTR [rsp+0x28],r12
    4ada:	mov    QWORD PTR [rsp+0x30],r13
    4adf:	mov    QWORD PTR [rsp+0x38],r14
    4ae4:	mov    QWORD PTR [rsp+0x40],r15
    4ae9:	mov    QWORD PTR [rsp],rdx
    4aed:	mov    r15,rdx
    4af0:	lea    r13,[rsp+0x10]
    4af5:	mov    rbx,rsi
    4af8:	mov    rax,QWORD PTR [rbx+0x20]
    4afc:	mov    rsi,QWORD PTR [rax]
    4aff:	mov    QWORD PTR [rsp+0x8],rsi
    4b04:	mov    r12,rdi
    4b07:	mov    rdx,r15
    4b0a:	call   4b0f <botlish_fn_30+0x47>
			4b0b: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_label<generic>
    4b0f:	mov    r10,rax
    4b12:	mov    r14,rax
    4b15:	test   rax,r10
    4b18:	je     4c8e <botlish_fn_30+0x1c6>
    4b1e:	mov    rax,r14
    4b21:	mov    QWORD PTR [rsp],rax
    4b25:	mov    rdx,r15
    4b28:	and    rax,rdx
    4b2b:	test   rax,0x1
    4b31:	jne    4b53 <botlish_fn_30+0x8b>
    4b37:	mov    rdx,r15
    4b3a:	mov    rsi,r14
    4b3d:	mov    rdi,r12
    4b40:	call   4b45 <botlish_fn_30+0x7d>
			4b41: R_X86_64_PLT32	rt_value_eq-0x4
    4b45:	test   rax,rax
    4b48:	je     4c8e <botlish_fn_30+0x1c6>
    4b4e:	jmp    4b66 <botlish_fn_30+0x9e>
    4b53:	mov    eax,0x2
    4b58:	mov    rdx,r15
    4b5b:	cmp    r14,rdx
    4b5e:	cmove  rax,QWORD PTR [rip+0x1aa]        # 4d10 <botlish_fn_30+0x248>
    4b66:	cmp    rax,0x6
    4b6a:	je     4ce5 <botlish_fn_30+0x21d>
    4b70:	mov    rdx,QWORD PTR [rbx+0x20]
    4b74:	mov    rdx,QWORD PTR [rdx+0x8]
    4b78:	mov    rsi,r14
    4b7b:	and    rsi,rdx
    4b7e:	test   rsi,0x1
    4b85:	jne    4bab <botlish_fn_30+0xe3>
    4b8b:	mov    rsi,r14
    4b8e:	mov    rdi,r12
    4b91:	call   4b96 <botlish_fn_30+0xce>
			4b92: R_X86_64_PLT32	rt_int_cmp-0x4
    4b96:	mov    ecx,0x2
    4b9b:	test   rax,rax
    4b9e:	cmovge rcx,QWORD PTR [rip+0x16a]        # 4d10 <botlish_fn_30+0x248>
    4ba6:	jmp    4bbb <botlish_fn_30+0xf3>
    4bab:	mov    ecx,0x2
    4bb0:	cmp    r14,rdx
    4bb3:	cmovge rcx,QWORD PTR [rip+0x155]        # 4d10 <botlish_fn_30+0x248>
    4bbb:	cmp    rcx,0x6
    4bbf:	je     4cd9 <botlish_fn_30+0x211>
    4bc5:	mov    r10,QWORD PTR [rbx+0x20]
    4bc9:	mov    rsi,QWORD PTR [r10+0x10]
    4bcd:	mov    QWORD PTR [rsp+0x8],rsi
    4bd2:	mov    rcx,r13
    4bd5:	mov    rdx,r14
    4bd8:	mov    rdi,r12
    4bdb:	call   4be0 <botlish_fn_30+0x118>
			4bdc: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    4be0:	test   rax,rax
    4be3:	mov    rsi,rax
    4be6:	je     4c8e <botlish_fn_30+0x1c6>
    4bec:	mov    rdx,QWORD PTR [rsp+0x10]
    4bf1:	mov    rcx,QWORD PTR [rsp+0x18]
    4bf6:	mov    rax,QWORD PTR [r12+0x10]
    4bfb:	mov    r8,QWORD PTR [rax+0x118]
    4c02:	mov    rdi,r12
    4c05:	call   4c0a <botlish_fn_30+0x142>
			4c06: R_X86_64_PLT32	rt_str_region_eq-0x4
    4c0a:	cmp    rax,0x6
    4c0e:	je     4c20 <botlish_fn_30+0x158>
    4c14:	mov    rax,0xffffffffffffffff
    4c1b:	jmp    4cec <botlish_fn_30+0x224>
    4c20:	mov    QWORD PTR [rsp+0x8],0x3
    4c29:	test   r14,0x1
    4c30:	je     4c53 <botlish_fn_30+0x18b>
    4c36:	mov    rdx,r14
    4c39:	add    rdx,0x2
    4c3d:	mov    r15,rdx
    4c40:	seto   al
    4c43:	test   al,al
    4c45:	jne    4c53 <botlish_fn_30+0x18b>
    4c4b:	mov    rdx,r15
    4c4e:	jmp    4c69 <botlish_fn_30+0x1a1>
    4c53:	mov    edx,0x3
    4c58:	mov    rsi,r14
    4c5b:	mov    rdi,r12
    4c5e:	call   4c63 <botlish_fn_30+0x19b>
			4c5f: R_X86_64_PLT32	rt_int_add-0x4
    4c63:	mov    rdx,rax
    4c66:	mov    r15,rax
    4c69:	mov    QWORD PTR [rsp],rdx
    4c6d:	mov    rax,QWORD PTR [rbx+0x20]
    4c71:	mov    rsi,QWORD PTR [rax+0x18]
    4c75:	mov    QWORD PTR [rsp+0x8],rsi
    4c7a:	mov    rdx,r15
    4c7d:	mov    rdi,r12
    4c80:	call   4c85 <botlish_fn_30+0x1bd>
			4c81: R_X86_64_PLT32	botlish_fn_29-0x4 ; tld_ok<generic>
    4c85:	test   rax,rax
    4c88:	jne    4cb3 <botlish_fn_30+0x1eb>
    4c8e:	xor    rax,rax
    4c91:	mov    rbx,QWORD PTR [rsp+0x20]
    4c96:	mov    r12,QWORD PTR [rsp+0x28]
    4c9b:	mov    r13,QWORD PTR [rsp+0x30]
    4ca0:	mov    r14,QWORD PTR [rsp+0x38]
    4ca5:	mov    r15,QWORD PTR [rsp+0x40]
    4caa:	add    rsp,0x50
    4cae:	mov    rsp,rbp
    4cb1:	pop    rbp
    4cb2:	ret
    4cb3:	cmp    rax,0x6
    4cb7:	je     4ccc <botlish_fn_30+0x204>
    4cbd:	mov    rdx,r15
    4cc0:	mov    QWORD PTR [rsp],rdx
    4cc4:	mov    rdi,r12
    4cc7:	jmp    4af8 <botlish_fn_30+0x30>
    4ccc:	mov    rax,QWORD PTR [rbx+0x20]
    4cd0:	mov    rax,QWORD PTR [rax+0x8]
    4cd4:	jmp    4cec <botlish_fn_30+0x224>
    4cd9:	mov    rax,0xffffffffffffffff
    4ce0:	jmp    4cec <botlish_fn_30+0x224>
    4ce5:	mov    rax,0xffffffffffffffff
    4cec:	mov    rbx,QWORD PTR [rsp+0x20]
    4cf1:	mov    r12,QWORD PTR [rsp+0x28]
    4cf6:	mov    r13,QWORD PTR [rsp+0x30]
    4cfb:	mov    r14,QWORD PTR [rsp+0x38]
    4d00:	mov    r15,QWORD PTR [rsp+0x40]
    4d05:	add    rsp,0x50
    4d09:	mov    rsp,rbp
    4d0c:	pop    rbp
    4d0d:	ret
    4d0e:	add    BYTE PTR [rax],al
    4d10:	(bad)
    4d11:	add    BYTE PTR [rax],al
    4d13:	add    BYTE PTR [rax],al
    4d15:	add    BYTE PTR [rax],al
	...

0000000000004d18 <botlish_entry_30: domain_loop<generic>>:
    4d18:	push   rbp
    4d19:	mov    rbp,rsp
    4d1c:	mov    rdx,QWORD PTR [rdx]
    4d1f:	call   4d24 <botlish_entry_30+0xc>
			4d20: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    4d24:	mov    rsp,rbp
    4d27:	pop    rbp
    4d28:	ret

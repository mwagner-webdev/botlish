; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 21002  (per function: 935 365 1713 1425 539 932 545 988 504 1185 1225 427 456 401 165 489 489 497 553 641 1185 1225 427 456 401 165 489 489 497 553 641)
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
    107b:	mov    QWORD PTR [rsp],rdx
    107f:	mov    rax,QWORD PTR [rsi+0x20]
    1083:	mov    r13,rsi
    1086:	mov    rsi,QWORD PTR [rax]
    1089:	mov    QWORD PTR [rsp+0x8],rsi
    108e:	mov    r14,rsi
    1091:	mov    rsi,r12
    1094:	mov    rdi,rbx
    1097:	call   109c <botlish_fn_4+0x43>
			1098: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
    109c:	test   rax,rax
    109f:	je     11f6 <botlish_fn_4+0x19d>
    10a5:	test   rax,0x1
    10ab:	jne    10bc <botlish_fn_4+0x63>
    10b1:	mov    rdx,rax
    10b4:	mov    rsi,r14
    10b7:	jmp    10d5 <botlish_fn_4+0x7c>
    10bc:	mov    rsi,r14
    10bf:	mov    rdx,QWORD PTR [rsi+0x8]
    10c3:	mov    rcx,rax
    10c6:	sar    rcx,1
    10c9:	cmp    rcx,rdx
    10cc:	jb     10ee <botlish_fn_4+0x95>
    10d2:	mov    rdx,rax
    10d5:	mov    rdi,rbx
    10d8:	call   10dd <botlish_fn_4+0x84>
			10d9: R_X86_64_PLT32	rt_list_get-0x4
    10dd:	test   rax,rax
    10e0:	je     11f6 <botlish_fn_4+0x19d>
    10e6:	mov    rsi,rax
    10e9:	jmp    10f6 <botlish_fn_4+0x9d>
    10ee:	mov    rax,QWORD PTR [rsi+0x10]
    10f2:	mov    rsi,QWORD PTR [rax+rcx*8]
    10f6:	mov    QWORD PTR [rsp],rsi
    10fa:	mov    rax,rsi
    10fd:	mov    rsi,r13
    1100:	mov    r13,rax
    1103:	mov    rax,QWORD PTR [rsi+0x20]
    1107:	mov    rsi,QWORD PTR [rax]
    110a:	mov    r14,rsi
    110d:	mov    eax,0x1
    1112:	mov    rdx,r12
    1115:	test   rdx,0x1
    111c:	je     112a <botlish_fn_4+0xd1>
    1122:	mov    r12,rdx
    1125:	jmp    114d <botlish_fn_4+0xf4>
    112a:	xor    eax,eax
    112c:	test   rdx,0x7
    1133:	je     1141 <botlish_fn_4+0xe8>
    1139:	mov    r12,rdx
    113c:	jmp    114d <botlish_fn_4+0xf4>
    1141:	movzx  rax,BYTE PTR [rdx]
    1145:	mov    r12,rdx
    1148:	cmp    al,0x1
    114a:	sete   al
    114d:	test   al,al
    114f:	jne    1173 <botlish_fn_4+0x11a>
    1155:	mov    rdi,rbx
    1158:	mov    rdx,QWORD PTR [rdi+0x10]
    115c:	mov    rcx,QWORD PTR [rdx+0xa8]
    1163:	xor    rdx,rdx
    1166:	mov    rsi,r12
    1169:	call   116e <botlish_fn_4+0x115>
			116a: R_X86_64_PLT32	rt_type_error-0x4
    116e:	jmp    11f6 <botlish_fn_4+0x19d>
    1173:	mov    rsi,r12
    1176:	mov    edx,0x21
    117b:	mov    rdi,rbx
    117e:	call   1183 <botlish_fn_4+0x12a>
			117f: R_X86_64_PLT32	rt_int_mod-0x4
    1183:	test   rax,rax
    1186:	je     11f6 <botlish_fn_4+0x19d>
    118c:	test   rax,0x1
    1192:	jne    11a3 <botlish_fn_4+0x14a>
    1198:	mov    rdx,rax
    119b:	mov    rsi,r14
    119e:	jmp    11bc <botlish_fn_4+0x163>
    11a3:	mov    rsi,r14
    11a6:	mov    r10,QWORD PTR [rsi+0x8]
    11aa:	mov    r9,rax
    11ad:	sar    r9,1
    11b0:	mov    rdx,rax
    11b3:	cmp    r9,r10
    11b6:	jb     11d5 <botlish_fn_4+0x17c>
    11bc:	mov    rdi,rbx
    11bf:	call   11c4 <botlish_fn_4+0x16b>
			11c0: R_X86_64_PLT32	rt_list_get-0x4
    11c4:	test   rax,rax
    11c7:	je     11f6 <botlish_fn_4+0x19d>
    11cd:	mov    rdx,rax
    11d0:	jmp    11dd <botlish_fn_4+0x184>
    11d5:	mov    rax,QWORD PTR [rsi+0x10]
    11d9:	mov    rdx,QWORD PTR [rax+r9*8]
    11dd:	mov    QWORD PTR [rsp+0x8],rdx
    11e2:	mov    rsi,r13
    11e5:	mov    rdi,rbx
    11e8:	call   11ed <botlish_fn_4+0x194>
			11e9: R_X86_64_PLT32	rt_str_cat-0x4
    11ed:	test   rax,rax
    11f0:	jne    1216 <botlish_fn_4+0x1bd>
    11f6:	xor    rax,rax
    11f9:	mov    rbx,QWORD PTR [rsp+0x10]
    11fe:	mov    r12,QWORD PTR [rsp+0x18]
    1203:	mov    r13,QWORD PTR [rsp+0x20]
    1208:	mov    r14,QWORD PTR [rsp+0x28]
    120d:	add    rsp,0x30
    1211:	mov    rsp,rbp
    1214:	pop    rbp
    1215:	ret
    1216:	mov    rbx,QWORD PTR [rsp+0x10]
    121b:	mov    r12,QWORD PTR [rsp+0x18]
    1220:	mov    r13,QWORD PTR [rsp+0x20]
    1225:	mov    r14,QWORD PTR [rsp+0x28]
    122a:	add    rsp,0x30
    122e:	mov    rsp,rbp
    1231:	pop    rbp
    1232:	ret

0000000000001233 <botlish_entry_4: hex_pair<generic>>:
    1233:	push   rbp
    1234:	mov    rbp,rsp
    1237:	mov    rdx,QWORD PTR [rdx]
    123a:	call   123f <botlish_entry_4+0xc>
			123b: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    123f:	mov    rsp,rbp
    1242:	pop    rbp
    1243:	ret
    1244:	add    BYTE PTR [rax],al
	...

0000000000001248 <botlish_fn_5: esc_bytes<generic>>:
    1248:	push   rbp
    1249:	mov    rbp,rsp
    124c:	sub    rsp,0x80
    1253:	mov    QWORD PTR [rsp+0x50],rbx
    1258:	mov    QWORD PTR [rsp+0x58],r12
    125d:	mov    QWORD PTR [rsp+0x60],r13
    1262:	mov    QWORD PTR [rsp+0x68],r14
    1267:	mov    QWORD PTR [rsp+0x70],r15
    126c:	mov    r13,rdi
    126f:	mov    r14,rsi
    1272:	mov    QWORD PTR [rsp+0x28],0x0
    127b:	mov    QWORD PTR [rsp+0x30],0x0
    1284:	mov    QWORD PTR [rsp],rdx
    1288:	mov    QWORD PTR [rsp+0x8],rcx
    128d:	mov    QWORD PTR [rsp+0x10],r8
    1292:	mov    r15,r8
    1295:	mov    QWORD PTR [rsp+0x38],rcx
    129a:	xor    eax,eax
    129c:	test   rdx,0x7
    12a3:	je     12b1 <botlish_fn_5+0x69>
    12a9:	mov    rsi,rdx
    12ac:	jmp    12bf <botlish_fn_5+0x77>
    12b1:	movzx  r10,BYTE PTR [rdx]
    12b5:	mov    rsi,rdx
    12b8:	cmp    r10b,0x3
    12bc:	sete   al
    12bf:	test   al,al
    12c1:	jne    12e4 <botlish_fn_5+0x9c>
    12c7:	mov    rdi,r13
    12ca:	mov    rax,QWORD PTR [rdi+0x10]
    12ce:	mov    rcx,QWORD PTR [rax+0xb0]
    12d5:	mov    edx,0x4
    12da:	call   12df <botlish_fn_5+0x97>
			12db: R_X86_64_PLT32	rt_type_error-0x4
    12df:	jmp    151c <botlish_fn_5+0x2d4>
    12e4:	mov    r12,rsi
    12e7:	mov    rdi,r13
    12ea:	call   12ef <botlish_fn_5+0xa7>
			12eb: R_X86_64_PLT32	rt_list_len-0x4
    12ef:	mov    ecx,0x1
    12f4:	mov    rsi,QWORD PTR [rsp+0x38]
    12f9:	test   rsi,0x1
    1300:	jne    132a <botlish_fn_5+0xe2>
    1306:	xor    ecx,ecx
    1308:	mov    rsi,QWORD PTR [rsp+0x38]
    130d:	test   rsi,0x7
    1314:	jne    132a <botlish_fn_5+0xe2>
    131a:	mov    rsi,QWORD PTR [rsp+0x38]
    131f:	movzx  rcx,BYTE PTR [rsi]
    1323:	rex cmp cl,0x1
    1327:	sete   cl
    132a:	test   cl,cl
    132c:	jne    1352 <botlish_fn_5+0x10a>
    1332:	mov    rdi,r13
    1335:	mov    rax,QWORD PTR [rdi+0x10]
    1339:	mov    rcx,QWORD PTR [rax+0xb8]
    1340:	xor    rdx,rdx
    1343:	mov    rsi,QWORD PTR [rsp+0x38]
    1348:	call   134d <botlish_fn_5+0x105>
			1349: R_X86_64_PLT32	rt_type_error-0x4
    134d:	jmp    151c <botlish_fn_5+0x2d4>
    1352:	mov    rsi,QWORD PTR [rsp+0x38]
    1357:	mov    rcx,rsi
    135a:	and    rcx,rax
    135d:	mov    rdx,rax
    1360:	test   rcx,0x1
    1367:	jne    138f <botlish_fn_5+0x147>
    136d:	mov    rsi,QWORD PTR [rsp+0x38]
    1372:	mov    rdi,r13
    1375:	call   137a <botlish_fn_5+0x132>
			1376: R_X86_64_PLT32	rt_int_cmp-0x4
    137a:	mov    ecx,0x2
    137f:	test   rax,rax
    1382:	cmovge rcx,QWORD PTR [rip+0x20e]        # 1598 <botlish_fn_5+0x350>
    138a:	jmp    13a4 <botlish_fn_5+0x15c>
    138f:	mov    ecx,0x2
    1394:	mov    rsi,QWORD PTR [rsp+0x38]
    1399:	cmp    rsi,rdx
    139c:	cmovge rcx,QWORD PTR [rip+0x1f4]        # 1598 <botlish_fn_5+0x350>
    13a4:	cmp    rcx,0x6
    13a8:	je     156a <botlish_fn_5+0x322>
    13ae:	mov    rbx,r14
    13b1:	mov    QWORD PTR [rsp+0x18],rbx
    13b6:	mov    QWORD PTR [rsp+0x20],0x3
    13bf:	mov    rsi,QWORD PTR [rsp+0x38]
    13c4:	test   rsi,0x1
    13cb:	je     13e8 <botlish_fn_5+0x1a0>
    13d1:	mov    rsi,QWORD PTR [rsp+0x38]
    13d6:	mov    rax,rsi
    13d9:	add    rax,0x2
    13dd:	seto   cl
    13e0:	test   cl,cl
    13e2:	je     13fa <botlish_fn_5+0x1b2>
    13e8:	mov    edx,0x3
    13ed:	mov    rsi,QWORD PTR [rsp+0x38]
    13f2:	mov    rdi,r13
    13f5:	call   13fa <botlish_fn_5+0x1b2>
			13f6: R_X86_64_PLT32	rt_int_add-0x4
    13fa:	mov    QWORD PTR [rsp+0x8],rax
    13ff:	mov    rdi,r13
    1402:	mov    QWORD PTR [rsp+0x40],rax
    1407:	mov    rax,QWORD PTR [rdi+0x10]
    140b:	mov    rsi,QWORD PTR [rax+0xc0]
    1412:	mov    QWORD PTR [rsp+0x20],rsi
    1417:	mov    r14,rsi
    141a:	mov    rax,QWORD PTR [rbx+0x20]
    141e:	mov    rsi,QWORD PTR [rax]
    1421:	mov    QWORD PTR [rsp+0x28],rsi
    1426:	mov    QWORD PTR [rsp+0x48],rsi
    142b:	mov    rsi,QWORD PTR [rsp+0x38]
    1430:	test   rsi,0x1
    1437:	jne    1447 <botlish_fn_5+0x1ff>
    143d:	mov    rdx,QWORD PTR [rsp+0x38]
    1442:	jmp    1465 <botlish_fn_5+0x21d>
    1447:	mov    rcx,QWORD PTR [r12+0x8]
    144c:	mov    rsi,QWORD PTR [rsp+0x38]
    1451:	mov    rax,rsi
    1454:	sar    rax,1
    1457:	cmp    rax,rcx
    145a:	jb     1481 <botlish_fn_5+0x239>
    1460:	mov    rdx,QWORD PTR [rsp+0x38]
    1465:	mov    rsi,r12
    1468:	mov    rdi,r13
    146b:	call   1470 <botlish_fn_5+0x228>
			146c: R_X86_64_PLT32	rt_list_get-0x4
    1470:	test   rax,rax
    1473:	je     151c <botlish_fn_5+0x2d4>
    1479:	mov    rdx,rax
    147c:	jmp    148a <botlish_fn_5+0x242>
    1481:	mov    rcx,QWORD PTR [r12+0x10]
    1486:	mov    rdx,QWORD PTR [rcx+rax*8]
    148a:	mov    QWORD PTR [rsp+0x30],rdx
    148f:	mov    rsi,QWORD PTR [rsp+0x48]
    1494:	mov    rdi,r13
    1497:	call   149c <botlish_fn_5+0x254>
			1498: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    149c:	test   rax,rax
    149f:	je     151c <botlish_fn_5+0x2d4>
    14a5:	mov    QWORD PTR [rsp+0x28],rax
    14aa:	mov    rdx,rax
    14ad:	mov    rsi,r14
    14b0:	mov    rdi,r13
    14b3:	call   14b8 <botlish_fn_5+0x270>
			14b4: R_X86_64_PLT32	rt_str_cat-0x4
    14b8:	test   rax,rax
    14bb:	je     151c <botlish_fn_5+0x2d4>
    14c1:	mov    QWORD PTR [rsp+0x20],rax
    14c6:	mov    rdx,rax
    14c9:	xor    eax,eax
    14cb:	mov    rsi,r15
    14ce:	test   rsi,0x7
    14d5:	jne    14e6 <botlish_fn_5+0x29e>
    14db:	movzx  rdi,BYTE PTR [rsi]
    14df:	cmp    dil,0x2
    14e3:	sete   al
    14e6:	test   al,al
    14e8:	jne    150b <botlish_fn_5+0x2c3>
    14ee:	mov    rdi,r13
    14f1:	mov    r11,QWORD PTR [rdi+0x10]
    14f5:	mov    rcx,QWORD PTR [r11+0xc8]
    14fc:	mov    edx,0x1
    1501:	call   1506 <botlish_fn_5+0x2be>
			1502: R_X86_64_PLT32	rt_type_error-0x4
    1506:	jmp    151c <botlish_fn_5+0x2d4>
    150b:	mov    rdi,r13
    150e:	call   1513 <botlish_fn_5+0x2cb>
			150f: R_X86_64_PLT32	rt_str_cat-0x4
    1513:	test   rax,rax
    1516:	jne    1544 <botlish_fn_5+0x2fc>
    151c:	xor    rax,rax
    151f:	mov    rbx,QWORD PTR [rsp+0x50]
    1524:	mov    r12,QWORD PTR [rsp+0x58]
    1529:	mov    r13,QWORD PTR [rsp+0x60]
    152e:	mov    r14,QWORD PTR [rsp+0x68]
    1533:	mov    r15,QWORD PTR [rsp+0x70]
    1538:	add    rsp,0x80
    153f:	mov    rsp,rbp
    1542:	pop    rbp
    1543:	ret
    1544:	mov    QWORD PTR [rsp],r12
    1548:	mov    rcx,QWORD PTR [rsp+0x40]
    154d:	mov    QWORD PTR [rsp+0x8],rcx
    1552:	mov    QWORD PTR [rsp+0x10],rax
    1557:	mov    rdx,r12
    155a:	mov    r14,rbx
    155d:	mov    r15,rax
    1560:	mov    QWORD PTR [rsp+0x38],rcx
    1565:	jmp    129a <botlish_fn_5+0x52>
    156a:	mov    rax,r15
    156d:	mov    rbx,QWORD PTR [rsp+0x50]
    1572:	mov    r12,QWORD PTR [rsp+0x58]
    1577:	mov    r13,QWORD PTR [rsp+0x60]
    157c:	mov    r14,QWORD PTR [rsp+0x68]
    1581:	mov    r15,QWORD PTR [rsp+0x70]
    1586:	add    rsp,0x80
    158d:	mov    rsp,rbp
    1590:	pop    rbp
    1591:	ret
    1592:	add    BYTE PTR [rax],al
    1594:	add    BYTE PTR [rax],al
    1596:	add    BYTE PTR [rax],al
    1598:	(bad)
    1599:	add    BYTE PTR [rax],al
    159b:	add    BYTE PTR [rax],al
    159d:	add    BYTE PTR [rax],al
	...

00000000000015a0 <botlish_entry_5: esc_bytes<generic>>:
    15a0:	push   rbp
    15a1:	mov    rbp,rsp
    15a4:	mov    r9,QWORD PTR [rdx]
    15a7:	mov    rcx,QWORD PTR [rdx+0x8]
    15ab:	mov    r8,QWORD PTR [rdx+0x10]
    15af:	mov    rdx,r9
    15b2:	call   15b7 <botlish_entry_5+0x17>
			15b3: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    15b7:	mov    rsp,rbp
    15ba:	pop    rbp
    15bb:	ret

00000000000015bc <botlish_fn_6: esc_char<generic>>:
    15bc:	push   rbp
    15bd:	mov    rbp,rsp
    15c0:	sub    rsp,0x50
    15c4:	mov    QWORD PTR [rsp+0x20],rbx
    15c9:	mov    QWORD PTR [rsp+0x28],r12
    15ce:	mov    QWORD PTR [rsp+0x30],r13
    15d3:	mov    QWORD PTR [rsp+0x38],r14
    15d8:	mov    QWORD PTR [rsp+0x40],r15
    15dd:	mov    r12,rsi
    15e0:	mov    QWORD PTR [rsp+0x8],0x0
    15e9:	mov    QWORD PTR [rsp+0x10],0x0
    15f2:	mov    QWORD PTR [rsp+0x18],0x0
    15fb:	mov    QWORD PTR [rsp],rdx
    15ff:	xor    r9d,r9d
    1602:	test   rdx,0x7
    1609:	je     1617 <botlish_fn_6+0x5b>
    160f:	mov    rbx,rdx
    1612:	jmp    1624 <botlish_fn_6+0x68>
    1617:	movzx  rax,BYTE PTR [rdx]
    161b:	mov    rbx,rdx
    161e:	cmp    al,0x2
    1620:	sete   r9b
    1624:	test   r9b,r9b
    1627:	jne    164a <botlish_fn_6+0x8e>
    162d:	mov    rax,QWORD PTR [rdi+0x10]
    1631:	mov    rcx,QWORD PTR [rax+0xd0]
    1638:	mov    edx,0x1
    163d:	mov    rsi,rbx
    1640:	call   1645 <botlish_fn_6+0x89>
			1641: R_X86_64_PLT32	rt_type_error-0x4
    1645:	jmp    1762 <botlish_fn_6+0x1a6>
    164a:	mov    r13,rdi
    164d:	mov    rsi,rbx
    1650:	call   1655 <botlish_fn_6+0x99>
			1651: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1655:	mov    rcx,rax
    1658:	mov    r14,rax
    165b:	test   rax,rcx
    165e:	je     1762 <botlish_fn_6+0x1a6>
    1664:	mov    rax,r14
    1667:	mov    QWORD PTR [rsp+0x8],rax
    166c:	mov    rsi,r14
    166f:	mov    rdi,r13
    1672:	call   1677 <botlish_fn_6+0xbb>
			1673: R_X86_64_PLT32	rt_list_len-0x4
    1677:	mov    ecx,0x1
    167c:	sar    rax,1
    167f:	cmp    rax,0x1
    1683:	je     16c7 <botlish_fn_6+0x10b>
    1689:	mov    rax,QWORD PTR [r12+0x20]
    168e:	mov    rsi,QWORD PTR [rax]
    1691:	mov    QWORD PTR [rsp],rsi
    1695:	mov    QWORD PTR [rsp+0x10],0x1
    169e:	mov    rdi,r13
    16a1:	mov    rax,QWORD PTR [rdi+0x10]
    16a5:	mov    r8,QWORD PTR [rax+0x98]
    16ac:	mov    QWORD PTR [rsp+0x18],r8
    16b1:	mov    rdx,r14
    16b4:	call   16b9 <botlish_fn_6+0xfd>
			16b5: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    16b9:	test   rax,rax
    16bc:	je     1762 <botlish_fn_6+0x1a6>
    16c2:	jmp    178f <botlish_fn_6+0x1d3>
    16c7:	mov    rdx,r14
    16ca:	mov    r15,rcx
    16cd:	mov    rax,QWORD PTR [rdx+0x8]
    16d1:	mov    r14,rdx
    16d4:	test   rax,rax
    16d7:	jne    16fc <botlish_fn_6+0x140>
    16dd:	mov    rdx,r15
    16e0:	mov    rsi,r14
    16e3:	mov    rdi,r13
    16e6:	call   16eb <botlish_fn_6+0x12f>
			16e7: R_X86_64_PLT32	rt_list_get-0x4
    16eb:	test   rax,rax
    16ee:	je     1762 <botlish_fn_6+0x1a6>
    16f4:	mov    rsi,rax
    16f7:	jmp    1706 <botlish_fn_6+0x14a>
    16fc:	mov    rdx,r14
    16ff:	mov    rsi,QWORD PTR [rdx+0x10]
    1703:	mov    rsi,QWORD PTR [rsi]
    1706:	mov    QWORD PTR [rsp+0x10],rsi
    170b:	mov    rdi,r13
    170e:	call   1713 <botlish_fn_6+0x157>
			170f: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    1713:	test   rax,rax
    1716:	je     1762 <botlish_fn_6+0x1a6>
    171c:	cmp    rax,0x6
    1720:	je     178c <botlish_fn_6+0x1d0>
    1726:	mov    rax,QWORD PTR [r12+0x20]
    172b:	mov    rsi,QWORD PTR [rax]
    172e:	mov    QWORD PTR [rsp],rsi
    1732:	mov    QWORD PTR [rsp+0x10],0x1
    173b:	mov    rdi,r13
    173e:	mov    rax,QWORD PTR [rdi+0x10]
    1742:	mov    r8,QWORD PTR [rax+0x98]
    1749:	mov    QWORD PTR [rsp+0x18],r8
    174e:	mov    rcx,r15
    1751:	mov    rdx,r14
    1754:	call   1759 <botlish_fn_6+0x19d>
			1755: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    1759:	test   rax,rax
    175c:	jne    178f <botlish_fn_6+0x1d3>
    1762:	xor    rax,rax
    1765:	mov    rbx,QWORD PTR [rsp+0x20]
    176a:	mov    r12,QWORD PTR [rsp+0x28]
    176f:	mov    r13,QWORD PTR [rsp+0x30]
    1774:	mov    r14,QWORD PTR [rsp+0x38]
    1779:	mov    r15,QWORD PTR [rsp+0x40]
    177e:	add    rsp,0x50
    1782:	mov    rsp,rbp
    1785:	pop    rbp
    1786:	ret
    1787:	jmp    178f <botlish_fn_6+0x1d3>
    178c:	mov    rax,rbx
    178f:	mov    rbx,QWORD PTR [rsp+0x20]
    1794:	mov    r12,QWORD PTR [rsp+0x28]
    1799:	mov    r13,QWORD PTR [rsp+0x30]
    179e:	mov    r14,QWORD PTR [rsp+0x38]
    17a3:	mov    r15,QWORD PTR [rsp+0x40]
    17a8:	add    rsp,0x50
    17ac:	mov    rsp,rbp
    17af:	pop    rbp
    17b0:	ret

00000000000017b1 <botlish_entry_6: esc_char<generic>>:
    17b1:	push   rbp
    17b2:	mov    rbp,rsp
    17b5:	mov    rdx,QWORD PTR [rdx]
    17b8:	call   17bd <botlish_entry_6+0xc>
			17b9: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    17bd:	mov    rsp,rbp
    17c0:	pop    rbp
    17c1:	ret
    17c2:	add    BYTE PTR [rax],al
    17c4:	add    BYTE PTR [rax],al
	...

00000000000017c8 <botlish_fn_7: esc_from<generic>>:
    17c8:	push   rbp
    17c9:	mov    rbp,rsp
    17cc:	sub    rsp,0x80
    17d3:	mov    QWORD PTR [rsp+0x50],rbx
    17d8:	mov    QWORD PTR [rsp+0x58],r12
    17dd:	mov    QWORD PTR [rsp+0x60],r13
    17e2:	mov    QWORD PTR [rsp+0x68],r14
    17e7:	mov    QWORD PTR [rsp+0x70],r15
    17ec:	mov    r12,rsi
    17ef:	mov    r13,rdi
    17f2:	mov    QWORD PTR [rsp+0x28],0x0
    17fb:	mov    QWORD PTR [rsp+0x30],0x0
    1804:	mov    QWORD PTR [rsp],rdx
    1808:	mov    QWORD PTR [rsp+0x8],rcx
    180d:	mov    QWORD PTR [rsp+0x10],r8
    1812:	mov    r14,r8
    1815:	mov    QWORD PTR [rsp+0x38],rcx
    181a:	xor    eax,eax
    181c:	test   rdx,0x7
    1823:	je     1831 <botlish_fn_7+0x69>
    1829:	mov    rsi,rdx
    182c:	jmp    183d <botlish_fn_7+0x75>
    1831:	movzx  rax,BYTE PTR [rdx]
    1835:	mov    rsi,rdx
    1838:	cmp    al,0x2
    183a:	sete   al
    183d:	test   al,al
    183f:	jne    1862 <botlish_fn_7+0x9a>
    1845:	mov    rdi,r13
    1848:	mov    rax,QWORD PTR [rdi+0x10]
    184c:	mov    rcx,QWORD PTR [rax+0xd8]
    1853:	mov    edx,0x1
    1858:	call   185d <botlish_fn_7+0x95>
			1859: R_X86_64_PLT32	rt_type_error-0x4
    185d:	jmp    1ac1 <botlish_fn_7+0x2f9>
    1862:	mov    rbx,rsi
    1865:	mov    rdi,r13
    1868:	call   186d <botlish_fn_7+0xa5>
			1869: R_X86_64_PLT32	rt_str_len-0x4
    186d:	mov    edx,0x1
    1872:	mov    r15,rdx
    1875:	mov    ecx,0x1
    187a:	mov    rsi,QWORD PTR [rsp+0x38]
    187f:	test   rsi,0x1
    1886:	jne    18b0 <botlish_fn_7+0xe8>
    188c:	xor    ecx,ecx
    188e:	mov    rsi,QWORD PTR [rsp+0x38]
    1893:	test   rsi,0x7
    189a:	jne    18b0 <botlish_fn_7+0xe8>
    18a0:	mov    rsi,QWORD PTR [rsp+0x38]
    18a5:	movzx  rcx,BYTE PTR [rsi]
    18a9:	rex cmp cl,0x1
    18ad:	sete   cl
    18b0:	test   cl,cl
    18b2:	jne    18d8 <botlish_fn_7+0x110>
    18b8:	mov    rdi,r13
    18bb:	mov    rax,QWORD PTR [rdi+0x10]
    18bf:	mov    rcx,QWORD PTR [rax+0xb8]
    18c6:	xor    rdx,rdx
    18c9:	mov    rsi,QWORD PTR [rsp+0x38]
    18ce:	call   18d3 <botlish_fn_7+0x10b>
			18cf: R_X86_64_PLT32	rt_type_error-0x4
    18d3:	jmp    1ac1 <botlish_fn_7+0x2f9>
    18d8:	mov    rsi,QWORD PTR [rsp+0x38]
    18dd:	mov    rcx,rsi
    18e0:	and    rcx,rax
    18e3:	mov    rdx,rax
    18e6:	test   rcx,0x1
    18ed:	jne    1915 <botlish_fn_7+0x14d>
    18f3:	mov    rsi,QWORD PTR [rsp+0x38]
    18f8:	mov    rdi,r13
    18fb:	call   1900 <botlish_fn_7+0x138>
			18fc: R_X86_64_PLT32	rt_int_cmp-0x4
    1900:	mov    ecx,0x2
    1905:	test   rax,rax
    1908:	cmovge rcx,QWORD PTR [rip+0x228]        # 1b38 <botlish_fn_7+0x370>
    1910:	jmp    192a <botlish_fn_7+0x162>
    1915:	mov    ecx,0x2
    191a:	mov    rsi,QWORD PTR [rsp+0x38]
    191f:	cmp    rsi,rdx
    1922:	cmovge rcx,QWORD PTR [rip+0x20e]        # 1b38 <botlish_fn_7+0x370>
    192a:	cmp    rcx,0x6
    192e:	je     1b0c <botlish_fn_7+0x344>
    1934:	mov    QWORD PTR [rsp+0x18],r12
    1939:	mov    QWORD PTR [rsp+0x20],0x3
    1942:	mov    rsi,QWORD PTR [rsp+0x38]
    1947:	test   rsi,0x1
    194e:	je     196b <botlish_fn_7+0x1a3>
    1954:	mov    rsi,QWORD PTR [rsp+0x38]
    1959:	mov    rax,rsi
    195c:	add    rax,0x2
    1960:	seto   cl
    1963:	test   cl,cl
    1965:	je     197d <botlish_fn_7+0x1b5>
    196b:	mov    edx,0x3
    1970:	mov    rsi,QWORD PTR [rsp+0x38]
    1975:	mov    rdi,r13
    1978:	call   197d <botlish_fn_7+0x1b5>
			1979: R_X86_64_PLT32	rt_int_add-0x4
    197d:	mov    QWORD PTR [rsp+0x20],rax
    1982:	mov    QWORD PTR [rsp+0x40],rax
    1987:	mov    rax,QWORD PTR [r12+0x20]
    198c:	mov    rsi,QWORD PTR [rax]
    198f:	mov    QWORD PTR [rsp+0x28],rsi
    1994:	mov    QWORD PTR [rsp+0x48],rsi
    1999:	mov    QWORD PTR [rsp+0x30],0x3
    19a2:	mov    rsi,QWORD PTR [rsp+0x38]
    19a7:	test   rsi,0x1
    19ae:	je     19cb <botlish_fn_7+0x203>
    19b4:	mov    rsi,QWORD PTR [rsp+0x38]
    19b9:	mov    rcx,rsi
    19bc:	add    rcx,0x2
    19c0:	seto   al
    19c3:	test   al,al
    19c5:	je     19e0 <botlish_fn_7+0x218>
    19cb:	mov    edx,0x3
    19d0:	mov    rsi,QWORD PTR [rsp+0x38]
    19d5:	mov    rdi,r13
    19d8:	call   19dd <botlish_fn_7+0x215>
			19d9: R_X86_64_PLT32	rt_int_add-0x4
    19dd:	mov    rcx,rax
    19e0:	mov    QWORD PTR [rsp+0x30],rcx
    19e5:	mov    rdx,QWORD PTR [rsp+0x38]
    19ea:	mov    rsi,rbx
    19ed:	mov    rdi,r13
    19f0:	call   19f5 <botlish_fn_7+0x22d>
			19f1: R_X86_64_PLT32	rt_substr-0x4
    19f5:	test   rax,rax
    19f8:	je     1ac1 <botlish_fn_7+0x2f9>
    19fe:	mov    QWORD PTR [rsp+0x8],rax
    1a03:	mov    rdx,rax
    1a06:	mov    rsi,QWORD PTR [rsp+0x48]
    1a0b:	mov    rdi,r13
    1a0e:	call   1a13 <botlish_fn_7+0x24b>
			1a0f: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    1a13:	test   rax,rax
    1a16:	je     1ac1 <botlish_fn_7+0x2f9>
    1a1c:	mov    QWORD PTR [rsp+0x8],rax
    1a21:	xor    ecx,ecx
    1a23:	mov    rsi,r14
    1a26:	test   rsi,0x7
    1a2d:	jne    1a3e <botlish_fn_7+0x276>
    1a33:	movzx  r9,BYTE PTR [rsi]
    1a37:	cmp    r9b,0x2
    1a3b:	sete   cl
    1a3e:	test   cl,cl
    1a40:	jne    1a61 <botlish_fn_7+0x299>
    1a46:	mov    rdi,r13
    1a49:	mov    rax,QWORD PTR [rdi+0x10]
    1a4d:	mov    rcx,QWORD PTR [rax+0xc8]
    1a54:	mov    rdx,r15
    1a57:	call   1a5c <botlish_fn_7+0x294>
			1a58: R_X86_64_PLT32	rt_type_error-0x4
    1a5c:	jmp    1ac1 <botlish_fn_7+0x2f9>
    1a61:	mov    rdx,r15
    1a64:	xor    edi,edi
    1a66:	test   rax,0x7
    1a6c:	je     1a7a <botlish_fn_7+0x2b2>
    1a72:	mov    r8,rax
    1a75:	jmp    1a89 <botlish_fn_7+0x2c1>
    1a7a:	movzx  rcx,BYTE PTR [rax]
    1a7e:	mov    r8,rax
    1a81:	rex cmp cl,0x2
    1a85:	sete   dil
    1a89:	test   dil,dil
    1a8c:	jne    1aad <botlish_fn_7+0x2e5>
    1a92:	mov    rdi,r13
    1a95:	mov    rax,QWORD PTR [rdi+0x10]
    1a99:	mov    rcx,QWORD PTR [rax+0xc8]
    1aa0:	mov    rsi,r8
    1aa3:	call   1aa8 <botlish_fn_7+0x2e0>
			1aa4: R_X86_64_PLT32	rt_type_error-0x4
    1aa8:	jmp    1ac1 <botlish_fn_7+0x2f9>
    1aad:	mov    rdx,r8
    1ab0:	mov    rdi,r13
    1ab3:	call   1ab8 <botlish_fn_7+0x2f0>
			1ab4: R_X86_64_PLT32	rt_str_cat-0x4
    1ab8:	test   rax,rax
    1abb:	jne    1ae9 <botlish_fn_7+0x321>
    1ac1:	xor    rax,rax
    1ac4:	mov    rbx,QWORD PTR [rsp+0x50]
    1ac9:	mov    r12,QWORD PTR [rsp+0x58]
    1ace:	mov    r13,QWORD PTR [rsp+0x60]
    1ad3:	mov    r14,QWORD PTR [rsp+0x68]
    1ad8:	mov    r15,QWORD PTR [rsp+0x70]
    1add:	add    rsp,0x80
    1ae4:	mov    rsp,rbp
    1ae7:	pop    rbp
    1ae8:	ret
    1ae9:	mov    QWORD PTR [rsp],rbx
    1aed:	mov    rcx,QWORD PTR [rsp+0x40]
    1af2:	mov    QWORD PTR [rsp+0x8],rcx
    1af7:	mov    QWORD PTR [rsp+0x10],rax
    1afc:	mov    rdx,rbx
    1aff:	mov    r14,rax
    1b02:	mov    QWORD PTR [rsp+0x38],rcx
    1b07:	jmp    181a <botlish_fn_7+0x52>
    1b0c:	mov    rax,r14
    1b0f:	mov    rbx,QWORD PTR [rsp+0x50]
    1b14:	mov    r12,QWORD PTR [rsp+0x58]
    1b19:	mov    r13,QWORD PTR [rsp+0x60]
    1b1e:	mov    r14,QWORD PTR [rsp+0x68]
    1b23:	mov    r15,QWORD PTR [rsp+0x70]
    1b28:	add    rsp,0x80
    1b2f:	mov    rsp,rbp
    1b32:	pop    rbp
    1b33:	ret
    1b34:	add    BYTE PTR [rax],al
    1b36:	add    BYTE PTR [rax],al
    1b38:	(bad)
    1b39:	add    BYTE PTR [rax],al
    1b3b:	add    BYTE PTR [rax],al
    1b3d:	add    BYTE PTR [rax],al
	...

0000000000001b40 <botlish_entry_7: esc_from<generic>>:
    1b40:	push   rbp
    1b41:	mov    rbp,rsp
    1b44:	mov    r9,QWORD PTR [rdx]
    1b47:	mov    rcx,QWORD PTR [rdx+0x8]
    1b4b:	mov    r8,QWORD PTR [rdx+0x10]
    1b4f:	mov    rdx,r9
    1b52:	call   1b57 <botlish_entry_7+0x17>
			1b53: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
    1b57:	mov    rsp,rbp
    1b5a:	pop    rbp
    1b5b:	ret
    1b5c:	add    BYTE PTR [rax],al
	...

0000000000001b60 <botlish_fn_8: check<int, int, str, str>>:
    1b60:	push   rbp
    1b61:	mov    rbp,rsp
    1b64:	sub    rsp,0x60
    1b68:	mov    QWORD PTR [rsp+0x30],rbx
    1b6d:	mov    QWORD PTR [rsp+0x38],r12
    1b72:	mov    QWORD PTR [rsp+0x40],r13
    1b77:	mov    QWORD PTR [rsp+0x48],r14
    1b7c:	mov    QWORD PTR [rsp+0x50],r15
    1b81:	mov    QWORD PTR [rsp+0x20],0x0
    1b8a:	mov    QWORD PTR [rsp],rsi
    1b8e:	mov    QWORD PTR [rsp+0x8],rdx
    1b93:	mov    QWORD PTR [rsp+0x10],rcx
    1b98:	mov    r12,rcx
    1b9b:	mov    QWORD PTR [rsp+0x18],r8
    1ba0:	mov    r14,r8
    1ba3:	mov    r13,rsi
    1ba6:	mov    r15,rdx
    1ba9:	test   r13,0x1
    1bb0:	jne    1bdb <botlish_fn_8+0x7b>
    1bb6:	mov    edx,0x1
    1bbb:	mov    rbx,rdi
    1bbe:	mov    rsi,r13
    1bc1:	call   1bc6 <botlish_fn_8+0x66>
			1bc2: R_X86_64_PLT32	rt_int_cmp-0x4
    1bc6:	mov    ecx,0x2
    1bcb:	test   rax,rax
    1bce:	cmovle rcx,QWORD PTR [rip+0x152]        # 1d28 <botlish_fn_8+0x1c8>
    1bd6:	jmp    1bef <botlish_fn_8+0x8f>
    1bdb:	mov    rbx,rdi
    1bde:	mov    ecx,0x2
    1be3:	cmp    r13,0x1
    1be7:	cmovle rcx,QWORD PTR [rip+0x139]        # 1d28 <botlish_fn_8+0x1c8>
    1bef:	cmp    rcx,0x6
    1bf3:	je     1cfc <botlish_fn_8+0x19c>
    1bf9:	mov    rax,QWORD PTR [rbx+0x10]
    1bfd:	mov    rax,QWORD PTR [rax+0xe0]
    1c04:	mov    rsi,r12
    1c07:	mov    rdi,rbx
    1c0a:	call   1c0f <botlish_fn_8+0xaf>
			1c0b: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    1c0f:	test   rax,rax
    1c12:	je     1c53 <botlish_fn_8+0xf3>
    1c18:	cmp    rax,0x6
    1c1c:	je     1c34 <botlish_fn_8+0xd4>
    1c22:	mov    edx,0x1
    1c27:	mov    QWORD PTR [rsp],0x1
    1c2f:	jmp    1c95 <botlish_fn_8+0x135>
    1c34:	mov    rax,QWORD PTR [rbx+0x10]
    1c38:	mov    rax,QWORD PTR [rax+0xe8]
    1c3f:	mov    rsi,r12
    1c42:	mov    rdi,rbx
    1c45:	call   1c4a <botlish_fn_8+0xea>
			1c46: R_X86_64_PLT32	botlish_fn_20-0x4 ; <str>
    1c4a:	test   rax,rax
    1c4d:	jne    1c78 <botlish_fn_8+0x118>
    1c53:	xor    rax,rax
    1c56:	mov    rbx,QWORD PTR [rsp+0x30]
    1c5b:	mov    r12,QWORD PTR [rsp+0x38]
    1c60:	mov    r13,QWORD PTR [rsp+0x40]
    1c65:	mov    r14,QWORD PTR [rsp+0x48]
    1c6a:	mov    r15,QWORD PTR [rsp+0x50]
    1c6f:	add    rsp,0x60
    1c73:	mov    rsp,rbp
    1c76:	pop    rbp
    1c77:	ret
    1c78:	cmp    rax,0x6
    1c7c:	je     1c8c <botlish_fn_8+0x12c>
    1c82:	mov    edx,0x1
    1c87:	jmp    1c91 <botlish_fn_8+0x131>
    1c8c:	mov    edx,0x3
    1c91:	mov    QWORD PTR [rsp],rdx
    1c95:	sar    r13,1
    1c98:	sub    r13,0x1
    1c9c:	shl    r13,1
    1c9f:	or     r13,0x1
    1ca3:	mov    QWORD PTR [rsp+0x20],r13
    1ca8:	mov    rsi,r15
    1cab:	mov    r8,rsi
    1cae:	and    r8,rdx
    1cb1:	test   r8,0x1
    1cb8:	je     1cd3 <botlish_fn_8+0x173>
    1cbe:	lea    r11,[rdx-0x1]
    1cc2:	mov    rax,rsi
    1cc5:	add    rax,r11
    1cc8:	seto   cl
    1ccb:	test   cl,cl
    1ccd:	je     1cdb <botlish_fn_8+0x17b>
    1cd3:	mov    rdi,rbx
    1cd6:	call   1cdb <botlish_fn_8+0x17b>
			1cd7: R_X86_64_PLT32	rt_int_add-0x4
    1cdb:	mov    QWORD PTR [rsp],r13
    1cdf:	mov    QWORD PTR [rsp+0x8],rax
    1ce4:	mov    QWORD PTR [rsp+0x10],r12
    1ce9:	mov    r8,r14
    1cec:	mov    QWORD PTR [rsp+0x18],r8
    1cf1:	mov    rdi,rbx
    1cf4:	mov    r15,rax
    1cf7:	jmp    1ba9 <botlish_fn_8+0x49>
    1cfc:	mov    rax,r15
    1cff:	mov    rbx,QWORD PTR [rsp+0x30]
    1d04:	mov    r12,QWORD PTR [rsp+0x38]
    1d09:	mov    r13,QWORD PTR [rsp+0x40]
    1d0e:	mov    r14,QWORD PTR [rsp+0x48]
    1d13:	mov    r15,QWORD PTR [rsp+0x50]
    1d18:	add    rsp,0x60
    1d1c:	mov    rsp,rbp
    1d1f:	pop    rbp
    1d20:	ret
    1d21:	add    BYTE PTR [rax],al
    1d23:	add    BYTE PTR [rax],al
    1d25:	add    BYTE PTR [rax],al
    1d27:	add    BYTE PTR [rsi],al
    1d29:	add    BYTE PTR [rax],al
    1d2b:	add    BYTE PTR [rax],al
    1d2d:	add    BYTE PTR [rax],al
	...

0000000000001d30 <botlish_entry_8: check<int, int, str, str>>:
    1d30:	push   rbp
    1d31:	mov    rbp,rsp
    1d34:	mov    rsi,QWORD PTR [rdx]
    1d37:	mov    r9,QWORD PTR [rdx+0x8]
    1d3b:	mov    rcx,QWORD PTR [rdx+0x10]
    1d3f:	mov    r8,QWORD PTR [rdx+0x18]
    1d43:	mov    rdx,r9
    1d46:	call   1d4b <botlish_entry_8+0x1b>
			1d47: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
    1d4b:	mov    rsp,rbp
    1d4e:	pop    rbp
    1d4f:	ret

0000000000001d50 <botlish_fn_9: <str>>:
    1d50:	push   rbp
    1d51:	mov    rbp,rsp
    1d54:	sub    rsp,0xe0
    1d5b:	mov    QWORD PTR [rsp+0xb0],rbx
    1d63:	mov    QWORD PTR [rsp+0xb8],r12
    1d6b:	mov    QWORD PTR [rsp+0xc0],r13
    1d73:	mov    QWORD PTR [rsp+0xc8],r14
    1d7b:	mov    QWORD PTR [rsp+0xd0],r15
    1d83:	mov    r15,rdi
    1d86:	mov    QWORD PTR [rsp+0x10],0x0
    1d8f:	mov    QWORD PTR [rsp+0x18],0x0
    1d98:	mov    QWORD PTR [rsp+0x20],0x0
    1da1:	mov    QWORD PTR [rsp],rsi
    1da5:	mov    rbx,rsi
    1da8:	mov    rsi,rbx
    1dab:	mov    rdi,r15
    1dae:	call   1db3 <botlish_fn_9+0x63>
			1daf: R_X86_64_PLT32	rt_str_len-0x4
    1db3:	mov    QWORD PTR [rsp+0xa8],rax
    1dbb:	mov    QWORD PTR [rsp+0x8],rax
    1dc0:	lea    r8,[rsp+0x28]
    1dc5:	mov    QWORD PTR [rsp+0x28],rbx
    1dca:	mov    esi,0xb
    1dcf:	mov    rdx,QWORD PTR [rip+0x0]        # 1dd6 <botlish_fn_9+0x86>
			1dd2: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    1dd6:	mov    ebx,0x1
    1ddb:	mov    rcx,rbx
    1dde:	mov    rdi,r15
    1de1:	call   1de6 <botlish_fn_9+0x96>
			1de2: R_X86_64_PLT32	rt_closure_new-0x4
    1de6:	mov    r14,rax
    1de9:	mov    QWORD PTR [rsp],rax
    1ded:	lea    r8,[rsp+0x30]
    1df2:	mov    rax,QWORD PTR [rsp+0xa8]
    1dfa:	mov    QWORD PTR [rsp+0x30],rax
    1dff:	mov    rax,r14
    1e02:	mov    QWORD PTR [rsp+0x38],rax
    1e07:	mov    esi,0xf
    1e0c:	mov    rdx,QWORD PTR [rip+0x0]        # 1e13 <botlish_fn_9+0xc3>
			1e0f: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_local<generic>
    1e13:	mov    r13d,0x2
    1e19:	mov    rcx,r13
    1e1c:	mov    rdi,r15
    1e1f:	call   1e24 <botlish_fn_9+0xd4>
			1e20: R_X86_64_PLT32	rt_closure_new-0x4
    1e24:	mov    r12,rax
    1e27:	mov    QWORD PTR [rsp+0x10],r12
    1e2c:	lea    r8,[rsp+0x40]
    1e31:	mov    rax,QWORD PTR [rsp+0xa8]
    1e39:	mov    QWORD PTR [rsp+0x40],rax
    1e3e:	mov    rax,r14
    1e41:	mov    QWORD PTR [rsp+0x48],rax
    1e46:	mov    esi,0x10
    1e4b:	mov    rdx,QWORD PTR [rip+0x0]        # 1e52 <botlish_fn_9+0x102>
			1e4e: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; scan_label<generic>
    1e52:	mov    rcx,r13
    1e55:	mov    rdi,r15
    1e58:	call   1e5d <botlish_fn_9+0x10d>
			1e59: R_X86_64_PLT32	rt_closure_new-0x4
    1e5d:	mov    QWORD PTR [rsp+0x18],rax
    1e62:	mov    QWORD PTR [rsp+0xa0],rax
    1e6a:	lea    r8,[rsp+0x50]
    1e6f:	mov    rax,QWORD PTR [rsp+0xa8]
    1e77:	mov    QWORD PTR [rsp+0x50],rax
    1e7c:	mov    QWORD PTR [rsp+0x58],r14
    1e81:	mov    esi,0x11
    1e86:	mov    rdx,QWORD PTR [rip+0x0]        # 1e8d <botlish_fn_9+0x13d>
			1e89: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; scan_alpha<generic>
    1e8d:	mov    rcx,r13
    1e90:	mov    rdi,r15
    1e93:	call   1e98 <botlish_fn_9+0x148>
			1e94: R_X86_64_PLT32	rt_closure_new-0x4
    1e98:	mov    QWORD PTR [rsp+0x20],rax
    1e9d:	lea    r8,[rsp+0x60]
    1ea2:	mov    QWORD PTR [rsp+0x60],rax
    1ea7:	mov    rax,QWORD PTR [rsp+0xa8]
    1eaf:	mov    QWORD PTR [rsp+0x68],rax
    1eb4:	mov    esi,0x12
    1eb9:	mov    rdx,QWORD PTR [rip+0x0]        # 1ec0 <botlish_fn_9+0x170>
			1ebc: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; tld_ok<generic>
    1ec0:	mov    rcx,r13
    1ec3:	mov    rdi,r15
    1ec6:	call   1ecb <botlish_fn_9+0x17b>
			1ec7: R_X86_64_PLT32	rt_closure_new-0x4
    1ecb:	mov    QWORD PTR [rsp+0x20],rax
    1ed0:	lea    r8,[rsp+0x70]
    1ed5:	mov    rcx,QWORD PTR [rsp+0xa0]
    1edd:	mov    QWORD PTR [rsp+0x70],rcx
    1ee2:	mov    rcx,QWORD PTR [rsp+0xa8]
    1eea:	mov    QWORD PTR [rsp+0x78],rcx
    1eef:	mov    QWORD PTR [rsp+0x80],r14
    1ef7:	mov    QWORD PTR [rsp+0x88],rax
    1eff:	mov    esi,0x13
    1f04:	mov    rdx,QWORD PTR [rip+0x0]        # 1f0b <botlish_fn_9+0x1bb>
			1f07: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; domain_loop<generic>
    1f0b:	mov    ecx,0x4
    1f10:	mov    rdi,r15
    1f13:	call   1f18 <botlish_fn_9+0x1c8>
			1f14: R_X86_64_PLT32	rt_closure_new-0x4
    1f18:	mov    QWORD PTR [rsp+0x18],rax
    1f1d:	mov    r13,rax
    1f20:	mov    QWORD PTR [rsp+0x20],0x1
    1f29:	mov    rdx,rbx
    1f2c:	mov    rsi,r12
    1f2f:	mov    rdi,r15
    1f32:	call   1f37 <botlish_fn_9+0x1e7>
			1f33: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    1f37:	mov    rcx,rax
    1f3a:	mov    r12,rax
    1f3d:	test   rax,rcx
    1f40:	je     20a1 <botlish_fn_9+0x351>
    1f46:	mov    rax,r12
    1f49:	mov    QWORD PTR [rsp+0x10],rax
    1f4e:	test   rax,0x1
    1f54:	jne    1f7f <botlish_fn_9+0x22f>
    1f5a:	mov    edx,0x1
    1f5f:	mov    rsi,r12
    1f62:	mov    rdi,r15
    1f65:	call   1f6a <botlish_fn_9+0x21a>
			1f66: R_X86_64_PLT32	rt_int_cmp-0x4
    1f6a:	mov    esi,0x2
    1f6f:	test   rax,rax
    1f72:	cmove  rsi,QWORD PTR [rip+0x206]        # 2180 <botlish_fn_9+0x430>
    1f7a:	jmp    1f90 <botlish_fn_9+0x240>
    1f7f:	mov    esi,0x2
    1f84:	cmp    r12,0x1
    1f88:	cmove  rsi,QWORD PTR [rip+0x1f0]        # 2180 <botlish_fn_9+0x430>
    1f90:	cmp    rsi,0x6
    1f94:	je     2145 <botlish_fn_9+0x3f5>
    1f9a:	mov    rbx,QWORD PTR [rsp+0xa8]
    1fa2:	mov    rax,r12
    1fa5:	and    rax,rbx
    1fa8:	test   rax,0x1
    1fae:	jne    1fd7 <botlish_fn_9+0x287>
    1fb4:	mov    rdx,rbx
    1fb7:	mov    rsi,r12
    1fba:	mov    rdi,r15
    1fbd:	call   1fc2 <botlish_fn_9+0x272>
			1fbe: R_X86_64_PLT32	rt_int_cmp-0x4
    1fc2:	mov    ecx,0x2
    1fc7:	test   rax,rax
    1fca:	cmovge rcx,QWORD PTR [rip+0x1ae]        # 2180 <botlish_fn_9+0x430>
    1fd2:	jmp    1fe7 <botlish_fn_9+0x297>
    1fd7:	mov    ecx,0x2
    1fdc:	cmp    r12,rbx
    1fdf:	cmovge rcx,QWORD PTR [rip+0x199]        # 2180 <botlish_fn_9+0x430>
    1fe7:	cmp    rcx,0x6
    1feb:	je     213b <botlish_fn_9+0x3eb>
    1ff1:	lea    rcx,[rsp+0x90]
    1ff9:	mov    rsi,r14
    1ffc:	mov    rdx,r12
    1fff:	mov    rdi,r15
    2002:	call   2007 <botlish_fn_9+0x2b7>
			2003: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    2007:	test   rax,rax
    200a:	mov    rsi,rax
    200d:	je     20a1 <botlish_fn_9+0x351>
    2013:	mov    rdx,QWORD PTR [rsp+0x90]
    201b:	mov    rcx,QWORD PTR [rsp+0x98]
    2023:	mov    rdi,r15
    2026:	mov    rax,QWORD PTR [rdi+0x10]
    202a:	mov    r8,QWORD PTR [rax+0x100]
    2031:	call   2036 <botlish_fn_9+0x2e6>
			2032: R_X86_64_PLT32	rt_str_region_eq-0x4
    2036:	cmp    rax,0x6
    203a:	je     204d <botlish_fn_9+0x2fd>
    2040:	mov    ecx,0x2
    2045:	mov    rax,rcx
    2048:	jmp    214a <botlish_fn_9+0x3fa>
    204d:	mov    QWORD PTR [rsp],0x3
    2055:	test   r12,0x1
    205c:	je     2076 <botlish_fn_9+0x326>
    2062:	mov    rdx,r12
    2065:	add    rdx,0x2
    2069:	seto   sil
    206d:	test   sil,sil
    2070:	je     2089 <botlish_fn_9+0x339>
    2076:	mov    edx,0x3
    207b:	mov    rsi,r12
    207e:	mov    rdi,r15
    2081:	call   2086 <botlish_fn_9+0x336>
			2082: R_X86_64_PLT32	rt_int_add-0x4
    2086:	mov    rdx,rax
    2089:	mov    QWORD PTR [rsp],rdx
    208d:	mov    rsi,r13
    2090:	mov    rdi,r15
    2093:	call   2098 <botlish_fn_9+0x348>
			2094: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    2098:	test   rax,rax
    209b:	jne    20d8 <botlish_fn_9+0x388>
    20a1:	xor    rax,rax
    20a4:	mov    rbx,QWORD PTR [rsp+0xb0]
    20ac:	mov    r12,QWORD PTR [rsp+0xb8]
    20b4:	mov    r13,QWORD PTR [rsp+0xc0]
    20bc:	mov    r14,QWORD PTR [rsp+0xc8]
    20c4:	mov    r15,QWORD PTR [rsp+0xd0]
    20cc:	add    rsp,0xe0
    20d3:	mov    rsp,rbp
    20d6:	pop    rbp
    20d7:	ret
    20d8:	mov    rcx,rax
    20db:	and    rcx,rbx
    20de:	mov    rsi,rax
    20e1:	mov    QWORD PTR [rsp+0xa8],rbx
    20e9:	test   rcx,0x1
    20f0:	jne    211e <botlish_fn_9+0x3ce>
    20f6:	mov    rdx,QWORD PTR [rsp+0xa8]
    20fe:	mov    rdi,r15
    2101:	call   2106 <botlish_fn_9+0x3b6>
			2102: R_X86_64_PLT32	rt_int_cmp-0x4
    2106:	mov    ecx,0x2
    210b:	test   rax,rax
    210e:	mov    rax,rcx
    2111:	cmove  rax,QWORD PTR [rip+0x67]        # 2180 <botlish_fn_9+0x430>
    2119:	jmp    214a <botlish_fn_9+0x3fa>
    211e:	mov    rdx,QWORD PTR [rsp+0xa8]
    2126:	mov    eax,0x2
    212b:	cmp    rsi,rdx
    212e:	cmove  rax,QWORD PTR [rip+0x4a]        # 2180 <botlish_fn_9+0x430>
    2136:	jmp    214a <botlish_fn_9+0x3fa>
    213b:	mov    eax,0x2
    2140:	jmp    214a <botlish_fn_9+0x3fa>
    2145:	mov    eax,0x2
    214a:	mov    rbx,QWORD PTR [rsp+0xb0]
    2152:	mov    r12,QWORD PTR [rsp+0xb8]
    215a:	mov    r13,QWORD PTR [rsp+0xc0]
    2162:	mov    r14,QWORD PTR [rsp+0xc8]
    216a:	mov    r15,QWORD PTR [rsp+0xd0]
    2172:	add    rsp,0xe0
    2179:	mov    rsp,rbp
    217c:	pop    rbp
    217d:	ret
    217e:	add    BYTE PTR [rax],al
    2180:	(bad)
    2181:	add    BYTE PTR [rax],al
    2183:	add    BYTE PTR [rax],al
    2185:	add    BYTE PTR [rax],al
	...

0000000000002188 <botlish_entry_9: <str>>:
    2188:	push   rbp
    2189:	mov    rbp,rsp
    218c:	mov    rsi,QWORD PTR [rdx]
    218f:	call   2194 <botlish_entry_9+0xc>
			2190: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    2194:	mov    rsp,rbp
    2197:	pop    rbp
    2198:	ret
    2199:	add    BYTE PTR [rax],al
    219b:	add    BYTE PTR [rax],al
    219d:	add    BYTE PTR [rax],al
	...

00000000000021a0 <botlish_fn_10: <generic>>:
    21a0:	push   rbp
    21a1:	mov    rbp,rsp
    21a4:	sub    rsp,0xe0
    21ab:	mov    QWORD PTR [rsp+0xb0],rbx
    21b3:	mov    QWORD PTR [rsp+0xb8],r12
    21bb:	mov    QWORD PTR [rsp+0xc0],r13
    21c3:	mov    QWORD PTR [rsp+0xc8],r14
    21cb:	mov    QWORD PTR [rsp+0xd0],r15
    21d3:	mov    QWORD PTR [rsp+0x10],0x0
    21dc:	mov    QWORD PTR [rsp+0x18],0x0
    21e5:	mov    QWORD PTR [rsp+0x20],0x0
    21ee:	mov    QWORD PTR [rsp],rsi
    21f2:	xor    r8d,r8d
    21f5:	test   rsi,0x7
    21fc:	jne    220c <botlish_fn_10+0x6c>
    2202:	movzx  rax,BYTE PTR [rsi]
    2206:	cmp    al,0x2
    2208:	sete   r8b
    220c:	test   r8b,r8b
    220f:	jne    222f <botlish_fn_10+0x8f>
    2215:	mov    rax,QWORD PTR [rdi+0x10]
    2219:	mov    rcx,QWORD PTR [rax+0xd8]
    2220:	mov    edx,0x1
    2225:	call   222a <botlish_fn_10+0x8a>
			2226: R_X86_64_PLT32	rt_type_error-0x4
    222a:	jmp    251e <botlish_fn_10+0x37e>
    222f:	mov    rbx,rsi
    2232:	mov    r15,rdi
    2235:	call   223a <botlish_fn_10+0x9a>
			2236: R_X86_64_PLT32	rt_str_len-0x4
    223a:	mov    r14,rax
    223d:	mov    QWORD PTR [rsp+0x8],rax
    2242:	lea    r8,[rsp+0x28]
    2247:	mov    QWORD PTR [rsp+0x28],rbx
    224c:	mov    esi,0xb
    2251:	mov    rdx,QWORD PTR [rip+0x0]        # 2258 <botlish_fn_10+0xb8>
			2254: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    2258:	mov    ebx,0x1
    225d:	mov    rcx,rbx
    2260:	mov    rdi,r15
    2263:	call   2268 <botlish_fn_10+0xc8>
			2264: R_X86_64_PLT32	rt_closure_new-0x4
    2268:	mov    r13,rax
    226b:	mov    QWORD PTR [rsp+0xa8],rbx
    2273:	mov    QWORD PTR [rsp],rax
    2277:	lea    r8,[rsp+0x30]
    227c:	mov    rax,r14
    227f:	mov    QWORD PTR [rsp+0x30],rax
    2284:	mov    rax,r13
    2287:	mov    QWORD PTR [rsp+0x38],rax
    228c:	mov    esi,0xf
    2291:	mov    rdx,QWORD PTR [rip+0x0]        # 2298 <botlish_fn_10+0xf8>
			2294: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_local<generic>
    2298:	mov    r12d,0x2
    229e:	mov    rcx,r12
    22a1:	mov    rdi,r15
    22a4:	call   22a9 <botlish_fn_10+0x109>
			22a5: R_X86_64_PLT32	rt_closure_new-0x4
    22a9:	mov    rbx,rax
    22ac:	mov    QWORD PTR [rsp+0x10],rbx
    22b1:	lea    r8,[rsp+0x40]
    22b6:	mov    rax,r14
    22b9:	mov    QWORD PTR [rsp+0x40],rax
    22be:	mov    rax,r13
    22c1:	mov    QWORD PTR [rsp+0x48],rax
    22c6:	mov    esi,0x10
    22cb:	mov    rdx,QWORD PTR [rip+0x0]        # 22d2 <botlish_fn_10+0x132>
			22ce: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; scan_label<generic>
    22d2:	mov    rcx,r12
    22d5:	mov    rdi,r15
    22d8:	call   22dd <botlish_fn_10+0x13d>
			22d9: R_X86_64_PLT32	rt_closure_new-0x4
    22dd:	mov    QWORD PTR [rsp+0x18],rax
    22e2:	mov    QWORD PTR [rsp+0xa0],rax
    22ea:	lea    r8,[rsp+0x50]
    22ef:	mov    rax,r14
    22f2:	mov    QWORD PTR [rsp+0x50],rax
    22f7:	mov    QWORD PTR [rsp+0x58],r13
    22fc:	mov    esi,0x11
    2301:	mov    rdx,QWORD PTR [rip+0x0]        # 2308 <botlish_fn_10+0x168>
			2304: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; scan_alpha<generic>
    2308:	mov    rcx,r12
    230b:	mov    rdi,r15
    230e:	call   2313 <botlish_fn_10+0x173>
			230f: R_X86_64_PLT32	rt_closure_new-0x4
    2313:	mov    QWORD PTR [rsp+0x20],rax
    2318:	lea    r8,[rsp+0x60]
    231d:	mov    QWORD PTR [rsp+0x60],rax
    2322:	mov    rax,r14
    2325:	mov    QWORD PTR [rsp+0x68],rax
    232a:	mov    esi,0x12
    232f:	mov    rdx,QWORD PTR [rip+0x0]        # 2336 <botlish_fn_10+0x196>
			2332: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; tld_ok<generic>
    2336:	mov    rcx,r12
    2339:	mov    rdi,r15
    233c:	call   2341 <botlish_fn_10+0x1a1>
			233d: R_X86_64_PLT32	rt_closure_new-0x4
    2341:	mov    QWORD PTR [rsp+0x20],rax
    2346:	lea    r8,[rsp+0x70]
    234b:	mov    rcx,QWORD PTR [rsp+0xa0]
    2353:	mov    QWORD PTR [rsp+0x70],rcx
    2358:	mov    rcx,r14
    235b:	mov    QWORD PTR [rsp+0x78],rcx
    2360:	mov    QWORD PTR [rsp+0x80],r13
    2368:	mov    QWORD PTR [rsp+0x88],rax
    2370:	mov    esi,0x13
    2375:	mov    rdx,QWORD PTR [rip+0x0]        # 237c <botlish_fn_10+0x1dc>
			2378: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; domain_loop<generic>
    237c:	mov    ecx,0x4
    2381:	mov    rdi,r15
    2384:	call   2389 <botlish_fn_10+0x1e9>
			2385: R_X86_64_PLT32	rt_closure_new-0x4
    2389:	mov    QWORD PTR [rsp+0x18],rax
    238e:	mov    QWORD PTR [rsp+0xa0],rax
    2396:	mov    QWORD PTR [rsp+0x20],0x1
    239f:	mov    rsi,rbx
    23a2:	mov    rdx,QWORD PTR [rsp+0xa8]
    23aa:	mov    rdi,r15
    23ad:	call   23b2 <botlish_fn_10+0x212>
			23ae: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    23b2:	mov    rcx,rax
    23b5:	mov    r12,rax
    23b8:	test   rax,rcx
    23bb:	je     251e <botlish_fn_10+0x37e>
    23c1:	mov    rax,r12
    23c4:	mov    QWORD PTR [rsp+0x10],rax
    23c9:	test   rax,0x1
    23cf:	jne    23fd <botlish_fn_10+0x25d>
    23d5:	mov    rdx,QWORD PTR [rsp+0xa8]
    23dd:	mov    rsi,r12
    23e0:	mov    rdi,r15
    23e3:	call   23e8 <botlish_fn_10+0x248>
			23e4: R_X86_64_PLT32	rt_int_cmp-0x4
    23e8:	mov    ecx,0x2
    23ed:	test   rax,rax
    23f0:	cmove  rcx,QWORD PTR [rip+0x1f8]        # 25f0 <botlish_fn_10+0x450>
    23f8:	jmp    240e <botlish_fn_10+0x26e>
    23fd:	mov    ecx,0x2
    2402:	cmp    r12,0x1
    2406:	cmove  rcx,QWORD PTR [rip+0x1e2]        # 25f0 <botlish_fn_10+0x450>
    240e:	cmp    rcx,0x6
    2412:	je     25b3 <botlish_fn_10+0x413>
    2418:	mov    rbx,r14
    241b:	mov    rcx,r12
    241e:	and    rcx,rbx
    2421:	test   rcx,0x1
    2428:	jne    2451 <botlish_fn_10+0x2b1>
    242e:	mov    rdx,rbx
    2431:	mov    rsi,r12
    2434:	mov    rdi,r15
    2437:	call   243c <botlish_fn_10+0x29c>
			2438: R_X86_64_PLT32	rt_int_cmp-0x4
    243c:	mov    ecx,0x2
    2441:	test   rax,rax
    2444:	cmovge rcx,QWORD PTR [rip+0x1a4]        # 25f0 <botlish_fn_10+0x450>
    244c:	jmp    2461 <botlish_fn_10+0x2c1>
    2451:	mov    ecx,0x2
    2456:	cmp    r12,rbx
    2459:	cmovge rcx,QWORD PTR [rip+0x18f]        # 25f0 <botlish_fn_10+0x450>
    2461:	cmp    rcx,0x6
    2465:	je     25a9 <botlish_fn_10+0x409>
    246b:	lea    rcx,[rsp+0x90]
    2473:	mov    rsi,r13
    2476:	mov    rdx,r12
    2479:	mov    rdi,r15
    247c:	call   2481 <botlish_fn_10+0x2e1>
			247d: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    2481:	test   rax,rax
    2484:	mov    rsi,rax
    2487:	je     251e <botlish_fn_10+0x37e>
    248d:	mov    rdx,QWORD PTR [rsp+0x90]
    2495:	mov    rcx,QWORD PTR [rsp+0x98]
    249d:	mov    rdi,r15
    24a0:	mov    rax,QWORD PTR [rdi+0x10]
    24a4:	mov    r8,QWORD PTR [rax+0x100]
    24ab:	call   24b0 <botlish_fn_10+0x310>
			24ac: R_X86_64_PLT32	rt_str_region_eq-0x4
    24b0:	cmp    rax,0x6
    24b4:	je     24c7 <botlish_fn_10+0x327>
    24ba:	mov    ecx,0x2
    24bf:	mov    rax,rcx
    24c2:	jmp    25b8 <botlish_fn_10+0x418>
    24c7:	mov    QWORD PTR [rsp],0x3
    24cf:	test   r12,0x1
    24d6:	je     24ee <botlish_fn_10+0x34e>
    24dc:	mov    rdx,r12
    24df:	add    rdx,0x2
    24e3:	seto   al
    24e6:	test   al,al
    24e8:	je     2501 <botlish_fn_10+0x361>
    24ee:	mov    edx,0x3
    24f3:	mov    rsi,r12
    24f6:	mov    rdi,r15
    24f9:	call   24fe <botlish_fn_10+0x35e>
			24fa: R_X86_64_PLT32	rt_int_add-0x4
    24fe:	mov    rdx,rax
    2501:	mov    QWORD PTR [rsp],rdx
    2505:	mov    rsi,QWORD PTR [rsp+0xa0]
    250d:	mov    rdi,r15
    2510:	call   2515 <botlish_fn_10+0x375>
			2511: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    2515:	test   rax,rax
    2518:	jne    2555 <botlish_fn_10+0x3b5>
    251e:	xor    rax,rax
    2521:	mov    rbx,QWORD PTR [rsp+0xb0]
    2529:	mov    r12,QWORD PTR [rsp+0xb8]
    2531:	mov    r13,QWORD PTR [rsp+0xc0]
    2539:	mov    r14,QWORD PTR [rsp+0xc8]
    2541:	mov    r15,QWORD PTR [rsp+0xd0]
    2549:	add    rsp,0xe0
    2550:	mov    rsp,rbp
    2553:	pop    rbp
    2554:	ret
    2555:	mov    rcx,rax
    2558:	and    rcx,rbx
    255b:	mov    rsi,rax
    255e:	mov    r14,rbx
    2561:	test   rcx,0x1
    2568:	jne    2591 <botlish_fn_10+0x3f1>
    256e:	mov    rdx,r14
    2571:	mov    rdi,r15
    2574:	call   2579 <botlish_fn_10+0x3d9>
			2575: R_X86_64_PLT32	rt_int_cmp-0x4
    2579:	mov    ecx,0x2
    257e:	test   rax,rax
    2581:	mov    rax,rcx
    2584:	cmove  rax,QWORD PTR [rip+0x64]        # 25f0 <botlish_fn_10+0x450>
    258c:	jmp    25b8 <botlish_fn_10+0x418>
    2591:	mov    rdx,r14
    2594:	mov    eax,0x2
    2599:	cmp    rsi,rdx
    259c:	cmove  rax,QWORD PTR [rip+0x4c]        # 25f0 <botlish_fn_10+0x450>
    25a4:	jmp    25b8 <botlish_fn_10+0x418>
    25a9:	mov    eax,0x2
    25ae:	jmp    25b8 <botlish_fn_10+0x418>
    25b3:	mov    eax,0x2
    25b8:	mov    rbx,QWORD PTR [rsp+0xb0]
    25c0:	mov    r12,QWORD PTR [rsp+0xb8]
    25c8:	mov    r13,QWORD PTR [rsp+0xc0]
    25d0:	mov    r14,QWORD PTR [rsp+0xc8]
    25d8:	mov    r15,QWORD PTR [rsp+0xd0]
    25e0:	add    rsp,0xe0
    25e7:	mov    rsp,rbp
    25ea:	pop    rbp
    25eb:	ret
    25ec:	add    BYTE PTR [rax],al
    25ee:	add    BYTE PTR [rax],al
    25f0:	(bad)
    25f1:	add    BYTE PTR [rax],al
    25f3:	add    BYTE PTR [rax],al
    25f5:	add    BYTE PTR [rax],al
	...

00000000000025f8 <botlish_entry_10: <generic>>:
    25f8:	push   rbp
    25f9:	mov    rbp,rsp
    25fc:	mov    rsi,QWORD PTR [rdx]
    25ff:	call   2604 <botlish_entry_10+0xc>
			2600: R_X86_64_PLT32	botlish_fn_10-0x4 ; <generic>
    2604:	mov    rsp,rbp
    2607:	pop    rbp
    2608:	ret

0000000000002609 <botlish_fn_11: char_at<generic>>:
    2609:	push   rbp
    260a:	mov    rbp,rsp
    260d:	sub    rsp,0x40
    2611:	mov    QWORD PTR [rsp+0x20],rbx
    2616:	mov    QWORD PTR [rsp+0x28],r12
    261b:	mov    QWORD PTR [rsp+0x30],r13
    2620:	mov    QWORD PTR [rsp],rdx
    2624:	mov    rax,QWORD PTR [rsi+0x20]
    2628:	mov    rsi,QWORD PTR [rax]
    262b:	mov    QWORD PTR [rsp+0x8],rsi
    2630:	mov    r13,rsi
    2633:	mov    QWORD PTR [rsp+0x10],0x3
    263c:	mov    r10d,0x1
    2642:	test   rdx,0x1
    2649:	je     2657 <botlish_fn_11+0x4e>
    264f:	mov    rbx,rdx
    2652:	jmp    267c <botlish_fn_11+0x73>
    2657:	xor    r10d,r10d
    265a:	test   rdx,0x7
    2661:	je     266f <botlish_fn_11+0x66>
    2667:	mov    rbx,rdx
    266a:	jmp    267c <botlish_fn_11+0x73>
    266f:	movzx  rax,BYTE PTR [rdx]
    2673:	mov    rbx,rdx
    2676:	cmp    al,0x1
    2678:	sete   r10b
    267c:	test   r10b,r10b
    267f:	jne    26a0 <botlish_fn_11+0x97>
    2685:	mov    rax,QWORD PTR [rdi+0x10]
    2689:	mov    rcx,QWORD PTR [rax+0x108]
    2690:	xor    rdx,rdx
    2693:	mov    rsi,rbx
    2696:	call   269b <botlish_fn_11+0x92>
			2697: R_X86_64_PLT32	rt_type_error-0x4
    269b:	jmp    2752 <botlish_fn_11+0x149>
    26a0:	mov    rsi,rbx
    26a3:	mov    r12,rdi
    26a6:	test   rsi,0x1
    26ad:	je     26c8 <botlish_fn_11+0xbf>
    26b3:	mov    rsi,rbx
    26b6:	mov    rcx,rsi
    26b9:	add    rcx,0x2
    26bd:	seto   al
    26c0:	test   al,al
    26c2:	je     26db <botlish_fn_11+0xd2>
    26c8:	mov    edx,0x3
    26cd:	mov    rsi,rbx
    26d0:	mov    rdi,r12
    26d3:	call   26d8 <botlish_fn_11+0xcf>
			26d4: R_X86_64_PLT32	rt_int_add-0x4
    26d8:	mov    rcx,rax
    26db:	mov    QWORD PTR [rsp+0x10],rcx
    26e0:	mov    eax,0x1
    26e5:	mov    rsi,rbx
    26e8:	test   rsi,0x1
    26ef:	jne    2715 <botlish_fn_11+0x10c>
    26f5:	xor    eax,eax
    26f7:	mov    rsi,rbx
    26fa:	test   rsi,0x7
    2701:	jne    2715 <botlish_fn_11+0x10c>
    2707:	mov    rsi,rbx
    270a:	movzx  rdx,BYTE PTR [rsi]
    270e:	rex cmp dl,0x1
    2712:	sete   al
    2715:	test   al,al
    2717:	jne    273b <botlish_fn_11+0x132>
    271d:	mov    rdi,r12
    2720:	mov    rsi,QWORD PTR [rdi+0x10]
    2724:	mov    rcx,QWORD PTR [rsi+0x110]
    272b:	xor    rdx,rdx
    272e:	mov    rsi,rbx
    2731:	call   2736 <botlish_fn_11+0x12d>
			2732: R_X86_64_PLT32	rt_type_error-0x4
    2736:	jmp    2752 <botlish_fn_11+0x149>
    273b:	mov    rdx,rbx
    273e:	mov    rsi,r13
    2741:	mov    rdi,r12
    2744:	call   2749 <botlish_fn_11+0x140>
			2745: R_X86_64_PLT32	rt_substr-0x4
    2749:	test   rax,rax
    274c:	jne    276d <botlish_fn_11+0x164>
    2752:	xor    rax,rax
    2755:	mov    rbx,QWORD PTR [rsp+0x20]
    275a:	mov    r12,QWORD PTR [rsp+0x28]
    275f:	mov    r13,QWORD PTR [rsp+0x30]
    2764:	add    rsp,0x40
    2768:	mov    rsp,rbp
    276b:	pop    rbp
    276c:	ret
    276d:	mov    rbx,QWORD PTR [rsp+0x20]
    2772:	mov    r12,QWORD PTR [rsp+0x28]
    2777:	mov    r13,QWORD PTR [rsp+0x30]
    277c:	add    rsp,0x40
    2780:	mov    rsp,rbp
    2783:	pop    rbp
    2784:	ret

0000000000002785 <botlish_entry_11: char_at<generic>>:
    2785:	push   rbp
    2786:	mov    rbp,rsp
    2789:	mov    rdx,QWORD PTR [rdx]
    278c:	call   2791 <botlish_entry_11+0xc>
			278d: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2791:	mov    rsp,rbp
    2794:	pop    rbp
    2795:	ret

0000000000002796 <botlish_fn_12: char_at<generic>>:
    2796:	push   rbp
    2797:	mov    rbp,rsp
    279a:	sub    rsp,0x40
    279e:	mov    QWORD PTR [rsp+0x20],rbx
    27a3:	mov    QWORD PTR [rsp+0x28],r12
    27a8:	mov    QWORD PTR [rsp+0x30],r13
    27ad:	mov    QWORD PTR [rsp+0x38],r14
    27b2:	mov    r13,rcx
    27b5:	mov    QWORD PTR [rsp],rdx
    27b9:	mov    rax,QWORD PTR [rsi+0x20]
    27bd:	mov    rax,QWORD PTR [rax]
    27c0:	mov    QWORD PTR [rsp+0x8],rax
    27c5:	mov    r14,rax
    27c8:	mov    QWORD PTR [rsp+0x10],0x3
    27d1:	mov    r11d,0x1
    27d7:	test   rdx,0x1
    27de:	je     27ec <botlish_fn_12+0x56>
    27e4:	mov    r12,rdx
    27e7:	jmp    2811 <botlish_fn_12+0x7b>
    27ec:	xor    r11d,r11d
    27ef:	test   rdx,0x7
    27f6:	je     2804 <botlish_fn_12+0x6e>
    27fc:	mov    r12,rdx
    27ff:	jmp    2811 <botlish_fn_12+0x7b>
    2804:	movzx  rax,BYTE PTR [rdx]
    2808:	mov    r12,rdx
    280b:	cmp    al,0x1
    280d:	sete   r11b
    2811:	test   r11b,r11b
    2814:	jne    2835 <botlish_fn_12+0x9f>
    281a:	mov    rax,QWORD PTR [rdi+0x10]
    281e:	mov    rcx,QWORD PTR [rax+0x108]
    2825:	xor    rdx,rdx
    2828:	mov    rsi,r12
    282b:	call   2830 <botlish_fn_12+0x9a>
			282c: R_X86_64_PLT32	rt_type_error-0x4
    2830:	jmp    28ed <botlish_fn_12+0x157>
    2835:	mov    rbx,rdi
    2838:	mov    rsi,r12
    283b:	test   rsi,0x1
    2842:	jne    2850 <botlish_fn_12+0xba>
    2848:	mov    r12,rsi
    284b:	jmp    2865 <botlish_fn_12+0xcf>
    2850:	mov    rax,rsi
    2853:	add    rax,0x2
    2857:	mov    r12,rsi
    285a:	seto   cl
    285d:	test   cl,cl
    285f:	je     2875 <botlish_fn_12+0xdf>
    2865:	mov    edx,0x3
    286a:	mov    rsi,r12
    286d:	mov    rdi,rbx
    2870:	call   2875 <botlish_fn_12+0xdf>
			2871: R_X86_64_PLT32	rt_int_add-0x4
    2875:	mov    ecx,0x1
    287a:	mov    rsi,r12
    287d:	test   rsi,0x1
    2884:	jne    28aa <botlish_fn_12+0x114>
    288a:	xor    ecx,ecx
    288c:	mov    rsi,r12
    288f:	test   rsi,0x7
    2896:	jne    28aa <botlish_fn_12+0x114>
    289c:	mov    rsi,r12
    289f:	movzx  rdx,BYTE PTR [rsi]
    28a3:	rex cmp dl,0x1
    28a7:	sete   cl
    28aa:	test   cl,cl
    28ac:	jne    28d0 <botlish_fn_12+0x13a>
    28b2:	mov    rdi,rbx
    28b5:	mov    rsi,QWORD PTR [rdi+0x10]
    28b9:	mov    rcx,QWORD PTR [rsi+0x110]
    28c0:	xor    rdx,rdx
    28c3:	mov    rsi,r12
    28c6:	call   28cb <botlish_fn_12+0x135>
			28c7: R_X86_64_PLT32	rt_type_error-0x4
    28cb:	jmp    28ed <botlish_fn_12+0x157>
    28d0:	mov    rdi,rbx
    28d3:	mov    rbx,rax
    28d6:	mov    rcx,rbx
    28d9:	mov    rdx,r12
    28dc:	mov    rsi,r14
    28df:	call   28e4 <botlish_fn_12+0x14e>
			28e0: R_X86_64_PLT32	rt_str_region_check-0x4
    28e4:	test   rax,rax
    28e7:	jne    290d <botlish_fn_12+0x177>
    28ed:	xor    rax,rax
    28f0:	mov    rbx,QWORD PTR [rsp+0x20]
    28f5:	mov    r12,QWORD PTR [rsp+0x28]
    28fa:	mov    r13,QWORD PTR [rsp+0x30]
    28ff:	mov    r14,QWORD PTR [rsp+0x38]
    2904:	add    rsp,0x40
    2908:	mov    rsp,rbp
    290b:	pop    rbp
    290c:	ret
    290d:	mov    rcx,r13
    2910:	mov    rsi,r12
    2913:	mov    QWORD PTR [rcx],rsi
    2916:	mov    QWORD PTR [rcx+0x8],rbx
    291a:	mov    rax,r14
    291d:	mov    rbx,QWORD PTR [rsp+0x20]
    2922:	mov    r12,QWORD PTR [rsp+0x28]
    2927:	mov    r13,QWORD PTR [rsp+0x30]
    292c:	mov    r14,QWORD PTR [rsp+0x38]
    2931:	add    rsp,0x40
    2935:	mov    rsp,rbp
    2938:	pop    rbp
    2939:	ret

000000000000293a <botlish_entry_12: char_at<generic>>:
    293a:	push   rbp
    293b:	mov    rbp,rsp
    293e:	ud2

0000000000002940 <botlish_fn_13: is_local_char<str>>:
    2940:	push   rbp
    2941:	mov    rbp,rsp
    2944:	sub    rsp,0x10
    2948:	mov    QWORD PTR [rsp],rbx
    294c:	mov    QWORD PTR [rsp+0x8],r12
    2951:	mov    rbx,rsi
    2954:	mov    r12,rdi
    2957:	mov    rsi,rbx
    295a:	mov    rdi,r12
    295d:	call   2962 <botlish_fn_13+0x22>
			295e: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    2962:	test   rax,rax
    2965:	jne    2980 <botlish_fn_13+0x40>
    296b:	xor    rax,rax
    296e:	mov    rbx,QWORD PTR [rsp]
    2972:	mov    r12,QWORD PTR [rsp+0x8]
    2977:	add    rsp,0x10
    297b:	mov    rsp,rbp
    297e:	pop    rbp
    297f:	ret
    2980:	cmp    rax,0x6
    2984:	je     2a7f <botlish_fn_13+0x13f>
    298a:	mov    rdi,r12
    298d:	mov    rax,QWORD PTR [rdi+0x10]
    2991:	mov    rsi,QWORD PTR [rax+0x118]
    2998:	mov    edx,0x1
    299d:	mov    ecx,0x3
    29a2:	mov    r8,rbx
    29a5:	call   29aa <botlish_fn_13+0x6a>
			29a6: R_X86_64_PLT32	rt_str_region_eq-0x4
    29aa:	cmp    rax,0x6
    29ae:	je     2a75 <botlish_fn_13+0x135>
    29b4:	mov    rdi,r12
    29b7:	mov    rax,QWORD PTR [rdi+0x10]
    29bb:	mov    rsi,QWORD PTR [rax+0x120]
    29c2:	mov    edx,0x1
    29c7:	mov    ecx,0x3
    29cc:	mov    r8,rbx
    29cf:	call   29d4 <botlish_fn_13+0x94>
			29d0: R_X86_64_PLT32	rt_str_region_eq-0x4
    29d4:	cmp    rax,0x6
    29d8:	je     2a6b <botlish_fn_13+0x12b>
    29de:	mov    rdi,r12
    29e1:	mov    rax,QWORD PTR [rdi+0x10]
    29e5:	mov    rsi,QWORD PTR [rax+0xc0]
    29ec:	mov    edx,0x1
    29f1:	mov    ecx,0x3
    29f6:	mov    r8,rbx
    29f9:	call   29fe <botlish_fn_13+0xbe>
			29fa: R_X86_64_PLT32	rt_str_region_eq-0x4
    29fe:	cmp    rax,0x6
    2a02:	je     2a61 <botlish_fn_13+0x121>
    2a08:	mov    rdi,r12
    2a0b:	mov    rax,QWORD PTR [rdi+0x10]
    2a0f:	mov    rsi,QWORD PTR [rax+0x108]
    2a16:	mov    edx,0x1
    2a1b:	mov    ecx,0x3
    2a20:	mov    r8,rbx
    2a23:	call   2a28 <botlish_fn_13+0xe8>
			2a24: R_X86_64_PLT32	rt_str_region_eq-0x4
    2a28:	cmp    rax,0x6
    2a2c:	je     2a57 <botlish_fn_13+0x117>
    2a32:	mov    rdi,r12
    2a35:	mov    rax,QWORD PTR [rdi+0x10]
    2a39:	mov    rsi,QWORD PTR [rax+0x128]
    2a40:	mov    edx,0x1
    2a45:	mov    ecx,0x3
    2a4a:	mov    r8,rbx
    2a4d:	call   2a52 <botlish_fn_13+0x112>
			2a4e: R_X86_64_PLT32	rt_str_region_eq-0x4
    2a52:	jmp    2a84 <botlish_fn_13+0x144>
    2a57:	mov    eax,0x6
    2a5c:	jmp    2a84 <botlish_fn_13+0x144>
    2a61:	mov    eax,0x6
    2a66:	jmp    2a84 <botlish_fn_13+0x144>
    2a6b:	mov    eax,0x6
    2a70:	jmp    2a84 <botlish_fn_13+0x144>
    2a75:	mov    eax,0x6
    2a7a:	jmp    2a84 <botlish_fn_13+0x144>
    2a7f:	mov    eax,0x6
    2a84:	mov    rbx,QWORD PTR [rsp]
    2a88:	mov    r12,QWORD PTR [rsp+0x8]
    2a8d:	add    rsp,0x10
    2a91:	mov    rsp,rbp
    2a94:	pop    rbp
    2a95:	ret

0000000000002a96 <botlish_entry_13: is_local_char<str>>:
    2a96:	push   rbp
    2a97:	mov    rbp,rsp
    2a9a:	mov    rsi,QWORD PTR [rdx]
    2a9d:	call   2aa2 <botlish_entry_13+0xc>
			2a9e: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_local_char<str>
    2aa2:	mov    rsp,rbp
    2aa5:	pop    rbp
    2aa6:	ret

0000000000002aa7 <botlish_fn_14: is_label_char<str>>:
    2aa7:	push   rbp
    2aa8:	mov    rbp,rsp
    2aab:	sub    rsp,0x10
    2aaf:	mov    QWORD PTR [rsp],r13
    2ab3:	mov    QWORD PTR [rsp+0x8],r15
    2ab8:	mov    r13,rsi
    2abb:	mov    r15,rdi
    2abe:	mov    rsi,r13
    2ac1:	mov    rdi,r15
    2ac4:	call   2ac9 <botlish_fn_14+0x22>
			2ac5: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    2ac9:	test   rax,rax
    2acc:	jne    2ae7 <botlish_fn_14+0x40>
    2ad2:	xor    rax,rax
    2ad5:	mov    r13,QWORD PTR [rsp]
    2ad9:	mov    r15,QWORD PTR [rsp+0x8]
    2ade:	add    rsp,0x10
    2ae2:	mov    rsp,rbp
    2ae5:	pop    rbp
    2ae6:	ret
    2ae7:	cmp    rax,0x6
    2aeb:	je     2b16 <botlish_fn_14+0x6f>
    2af1:	mov    rdi,r15
    2af4:	mov    rax,QWORD PTR [rdi+0x10]
    2af8:	mov    rsi,QWORD PTR [rax+0x128]
    2aff:	mov    edx,0x1
    2b04:	mov    ecx,0x3
    2b09:	mov    r8,r13
    2b0c:	call   2b11 <botlish_fn_14+0x6a>
			2b0d: R_X86_64_PLT32	rt_str_region_eq-0x4
    2b11:	jmp    2b1b <botlish_fn_14+0x74>
    2b16:	mov    eax,0x6
    2b1b:	mov    r13,QWORD PTR [rsp]
    2b1f:	mov    r15,QWORD PTR [rsp+0x8]
    2b24:	add    rsp,0x10
    2b28:	mov    rsp,rbp
    2b2b:	pop    rbp
    2b2c:	ret

0000000000002b2d <botlish_entry_14: is_label_char<str>>:
    2b2d:	push   rbp
    2b2e:	mov    rbp,rsp
    2b31:	mov    rsi,QWORD PTR [rdx]
    2b34:	call   2b39 <botlish_entry_14+0xc>
			2b35: R_X86_64_PLT32	botlish_fn_14-0x4 ; is_label_char<str>
    2b39:	mov    rsp,rbp
    2b3c:	pop    rbp
    2b3d:	ret
	...

0000000000002b40 <botlish_fn_15: scan_local<generic>>:
    2b40:	push   rbp
    2b41:	mov    rbp,rsp
    2b44:	sub    rsp,0x40
    2b48:	mov    QWORD PTR [rsp+0x20],rbx
    2b4d:	mov    QWORD PTR [rsp+0x28],r12
    2b52:	mov    QWORD PTR [rsp+0x30],r13
    2b57:	mov    r12,rdi
    2b5a:	mov    QWORD PTR [rsp+0x10],0x0
    2b63:	mov    QWORD PTR [rsp],rdx
    2b67:	mov    rbx,rsi
    2b6a:	mov    rsi,rdx
    2b6d:	mov    rax,QWORD PTR [rbx+0x20]
    2b71:	mov    rdx,QWORD PTR [rax]
    2b74:	mov    r10d,0x1
    2b7a:	test   rsi,0x1
    2b81:	jne    2ba1 <botlish_fn_15+0x61>
    2b87:	xor    r10d,r10d
    2b8a:	test   rsi,0x7
    2b91:	jne    2ba1 <botlish_fn_15+0x61>
    2b97:	movzx  rax,BYTE PTR [rsi]
    2b9b:	cmp    al,0x1
    2b9d:	sete   r10b
    2ba1:	test   r10b,r10b
    2ba4:	jne    2bc5 <botlish_fn_15+0x85>
    2baa:	mov    rdi,r12
    2bad:	mov    rax,QWORD PTR [rdi+0x10]
    2bb1:	mov    rcx,QWORD PTR [rax+0xb8]
    2bb8:	xor    rdx,rdx
    2bbb:	call   2bc0 <botlish_fn_15+0x80>
			2bbc: R_X86_64_PLT32	rt_type_error-0x4
    2bc0:	jmp    2c51 <botlish_fn_15+0x111>
    2bc5:	mov    rax,rsi
    2bc8:	and    rax,rdx
    2bcb:	mov    r13,rsi
    2bce:	test   rax,0x1
    2bd4:	jne    2bfa <botlish_fn_15+0xba>
    2bda:	mov    rsi,r13
    2bdd:	mov    rdi,r12
    2be0:	call   2be5 <botlish_fn_15+0xa5>
			2be1: R_X86_64_PLT32	rt_int_cmp-0x4
    2be5:	mov    ecx,0x2
    2bea:	test   rax,rax
    2bed:	cmovge rcx,QWORD PTR [rip+0x10b]        # 2d00 <botlish_fn_15+0x1c0>
    2bf5:	jmp    2c0d <botlish_fn_15+0xcd>
    2bfa:	mov    ecx,0x2
    2bff:	mov    rsi,r13
    2c02:	cmp    rsi,rdx
    2c05:	cmovge rcx,QWORD PTR [rip+0xf3]        # 2d00 <botlish_fn_15+0x1c0>
    2c0d:	cmp    rcx,0x6
    2c11:	je     2cde <botlish_fn_15+0x19e>
    2c17:	mov    rax,QWORD PTR [rbx+0x20]
    2c1b:	mov    rsi,QWORD PTR [rax+0x8]
    2c1f:	mov    QWORD PTR [rsp+0x8],rsi
    2c24:	mov    rdx,r13
    2c27:	mov    rdi,r12
    2c2a:	call   2c2f <botlish_fn_15+0xef>
			2c2b: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2c2f:	test   rax,rax
    2c32:	je     2c51 <botlish_fn_15+0x111>
    2c38:	mov    QWORD PTR [rsp+0x8],rax
    2c3d:	mov    rsi,rax
    2c40:	mov    rdi,r12
    2c43:	call   2c48 <botlish_fn_15+0x108>
			2c44: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_local_char<str>
    2c48:	test   rax,rax
    2c4b:	jne    2c6c <botlish_fn_15+0x12c>
    2c51:	xor    rax,rax
    2c54:	mov    rbx,QWORD PTR [rsp+0x20]
    2c59:	mov    r12,QWORD PTR [rsp+0x28]
    2c5e:	mov    r13,QWORD PTR [rsp+0x30]
    2c63:	add    rsp,0x40
    2c67:	mov    rsp,rbp
    2c6a:	pop    rbp
    2c6b:	ret
    2c6c:	cmp    rax,0x6
    2c70:	je     2c7e <botlish_fn_15+0x13e>
    2c76:	mov    rax,r13
    2c79:	jmp    2ce1 <botlish_fn_15+0x1a1>
    2c7e:	mov    QWORD PTR [rsp+0x8],rbx
    2c83:	mov    QWORD PTR [rsp+0x10],0x3
    2c8c:	mov    rsi,r13
    2c8f:	test   rsi,0x1
    2c96:	je     2cbc <botlish_fn_15+0x17c>
    2c9c:	mov    rsi,r13
    2c9f:	mov    rcx,rsi
    2ca2:	add    rcx,0x2
    2ca6:	seto   al
    2ca9:	test   al,al
    2cab:	jne    2cbc <botlish_fn_15+0x17c>
    2cb1:	mov    rsi,rcx
    2cb4:	mov    r13,rcx
    2cb7:	jmp    2cd2 <botlish_fn_15+0x192>
    2cbc:	mov    edx,0x3
    2cc1:	mov    rsi,r13
    2cc4:	mov    rdi,r12
    2cc7:	call   2ccc <botlish_fn_15+0x18c>
			2cc8: R_X86_64_PLT32	rt_int_add-0x4
    2ccc:	mov    rsi,rax
    2ccf:	mov    r13,rax
    2cd2:	mov    QWORD PTR [rsp],rsi
    2cd6:	mov    rsi,r13
    2cd9:	jmp    2b6d <botlish_fn_15+0x2d>
    2cde:	mov    rax,r13
    2ce1:	mov    rbx,QWORD PTR [rsp+0x20]
    2ce6:	mov    r12,QWORD PTR [rsp+0x28]
    2ceb:	mov    r13,QWORD PTR [rsp+0x30]
    2cf0:	add    rsp,0x40
    2cf4:	mov    rsp,rbp
    2cf7:	pop    rbp
    2cf8:	ret
    2cf9:	add    BYTE PTR [rax],al
    2cfb:	add    BYTE PTR [rax],al
    2cfd:	add    BYTE PTR [rax],al
    2cff:	add    BYTE PTR [rsi],al
    2d01:	add    BYTE PTR [rax],al
    2d03:	add    BYTE PTR [rax],al
    2d05:	add    BYTE PTR [rax],al
	...

0000000000002d08 <botlish_entry_15: scan_local<generic>>:
    2d08:	push   rbp
    2d09:	mov    rbp,rsp
    2d0c:	mov    rdx,QWORD PTR [rdx]
    2d0f:	call   2d14 <botlish_entry_15+0xc>
			2d10: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    2d14:	mov    rsp,rbp
    2d17:	pop    rbp
    2d18:	ret
    2d19:	add    BYTE PTR [rax],al
    2d1b:	add    BYTE PTR [rax],al
    2d1d:	add    BYTE PTR [rax],al
	...

0000000000002d20 <botlish_fn_16: scan_label<generic>>:
    2d20:	push   rbp
    2d21:	mov    rbp,rsp
    2d24:	sub    rsp,0x40
    2d28:	mov    QWORD PTR [rsp+0x20],rbx
    2d2d:	mov    QWORD PTR [rsp+0x28],r12
    2d32:	mov    QWORD PTR [rsp+0x30],r13
    2d37:	mov    r12,rdi
    2d3a:	mov    QWORD PTR [rsp+0x10],0x0
    2d43:	mov    QWORD PTR [rsp],rdx
    2d47:	mov    rbx,rsi
    2d4a:	mov    rsi,rdx
    2d4d:	mov    rax,QWORD PTR [rbx+0x20]
    2d51:	mov    rdx,QWORD PTR [rax]
    2d54:	mov    r10d,0x1
    2d5a:	test   rsi,0x1
    2d61:	jne    2d81 <botlish_fn_16+0x61>
    2d67:	xor    r10d,r10d
    2d6a:	test   rsi,0x7
    2d71:	jne    2d81 <botlish_fn_16+0x61>
    2d77:	movzx  rax,BYTE PTR [rsi]
    2d7b:	cmp    al,0x1
    2d7d:	sete   r10b
    2d81:	test   r10b,r10b
    2d84:	jne    2da5 <botlish_fn_16+0x85>
    2d8a:	mov    rdi,r12
    2d8d:	mov    rax,QWORD PTR [rdi+0x10]
    2d91:	mov    rcx,QWORD PTR [rax+0xb8]
    2d98:	xor    rdx,rdx
    2d9b:	call   2da0 <botlish_fn_16+0x80>
			2d9c: R_X86_64_PLT32	rt_type_error-0x4
    2da0:	jmp    2e31 <botlish_fn_16+0x111>
    2da5:	mov    rax,rsi
    2da8:	and    rax,rdx
    2dab:	mov    r13,rsi
    2dae:	test   rax,0x1
    2db4:	jne    2dda <botlish_fn_16+0xba>
    2dba:	mov    rsi,r13
    2dbd:	mov    rdi,r12
    2dc0:	call   2dc5 <botlish_fn_16+0xa5>
			2dc1: R_X86_64_PLT32	rt_int_cmp-0x4
    2dc5:	mov    ecx,0x2
    2dca:	test   rax,rax
    2dcd:	cmovge rcx,QWORD PTR [rip+0x10b]        # 2ee0 <botlish_fn_16+0x1c0>
    2dd5:	jmp    2ded <botlish_fn_16+0xcd>
    2dda:	mov    ecx,0x2
    2ddf:	mov    rsi,r13
    2de2:	cmp    rsi,rdx
    2de5:	cmovge rcx,QWORD PTR [rip+0xf3]        # 2ee0 <botlish_fn_16+0x1c0>
    2ded:	cmp    rcx,0x6
    2df1:	je     2ebe <botlish_fn_16+0x19e>
    2df7:	mov    rax,QWORD PTR [rbx+0x20]
    2dfb:	mov    rsi,QWORD PTR [rax+0x8]
    2dff:	mov    QWORD PTR [rsp+0x8],rsi
    2e04:	mov    rdx,r13
    2e07:	mov    rdi,r12
    2e0a:	call   2e0f <botlish_fn_16+0xef>
			2e0b: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2e0f:	test   rax,rax
    2e12:	je     2e31 <botlish_fn_16+0x111>
    2e18:	mov    QWORD PTR [rsp+0x8],rax
    2e1d:	mov    rsi,rax
    2e20:	mov    rdi,r12
    2e23:	call   2e28 <botlish_fn_16+0x108>
			2e24: R_X86_64_PLT32	botlish_fn_14-0x4 ; is_label_char<str>
    2e28:	test   rax,rax
    2e2b:	jne    2e4c <botlish_fn_16+0x12c>
    2e31:	xor    rax,rax
    2e34:	mov    rbx,QWORD PTR [rsp+0x20]
    2e39:	mov    r12,QWORD PTR [rsp+0x28]
    2e3e:	mov    r13,QWORD PTR [rsp+0x30]
    2e43:	add    rsp,0x40
    2e47:	mov    rsp,rbp
    2e4a:	pop    rbp
    2e4b:	ret
    2e4c:	cmp    rax,0x6
    2e50:	je     2e5e <botlish_fn_16+0x13e>
    2e56:	mov    rax,r13
    2e59:	jmp    2ec1 <botlish_fn_16+0x1a1>
    2e5e:	mov    QWORD PTR [rsp+0x8],rbx
    2e63:	mov    QWORD PTR [rsp+0x10],0x3
    2e6c:	mov    rsi,r13
    2e6f:	test   rsi,0x1
    2e76:	je     2e9c <botlish_fn_16+0x17c>
    2e7c:	mov    rsi,r13
    2e7f:	mov    rcx,rsi
    2e82:	add    rcx,0x2
    2e86:	seto   al
    2e89:	test   al,al
    2e8b:	jne    2e9c <botlish_fn_16+0x17c>
    2e91:	mov    rsi,rcx
    2e94:	mov    r13,rcx
    2e97:	jmp    2eb2 <botlish_fn_16+0x192>
    2e9c:	mov    edx,0x3
    2ea1:	mov    rsi,r13
    2ea4:	mov    rdi,r12
    2ea7:	call   2eac <botlish_fn_16+0x18c>
			2ea8: R_X86_64_PLT32	rt_int_add-0x4
    2eac:	mov    rsi,rax
    2eaf:	mov    r13,rax
    2eb2:	mov    QWORD PTR [rsp],rsi
    2eb6:	mov    rsi,r13
    2eb9:	jmp    2d4d <botlish_fn_16+0x2d>
    2ebe:	mov    rax,r13
    2ec1:	mov    rbx,QWORD PTR [rsp+0x20]
    2ec6:	mov    r12,QWORD PTR [rsp+0x28]
    2ecb:	mov    r13,QWORD PTR [rsp+0x30]
    2ed0:	add    rsp,0x40
    2ed4:	mov    rsp,rbp
    2ed7:	pop    rbp
    2ed8:	ret
    2ed9:	add    BYTE PTR [rax],al
    2edb:	add    BYTE PTR [rax],al
    2edd:	add    BYTE PTR [rax],al
    2edf:	add    BYTE PTR [rsi],al
    2ee1:	add    BYTE PTR [rax],al
    2ee3:	add    BYTE PTR [rax],al
    2ee5:	add    BYTE PTR [rax],al
	...

0000000000002ee8 <botlish_entry_16: scan_label<generic>>:
    2ee8:	push   rbp
    2ee9:	mov    rbp,rsp
    2eec:	mov    rdx,QWORD PTR [rdx]
    2eef:	call   2ef4 <botlish_entry_16+0xc>
			2ef0: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_label<generic>
    2ef4:	mov    rsp,rbp
    2ef7:	pop    rbp
    2ef8:	ret
    2ef9:	add    BYTE PTR [rax],al
    2efb:	add    BYTE PTR [rax],al
    2efd:	add    BYTE PTR [rax],al
	...

0000000000002f00 <botlish_fn_17: scan_alpha<generic>>:
    2f00:	push   rbp
    2f01:	mov    rbp,rsp
    2f04:	sub    rsp,0x40
    2f08:	mov    QWORD PTR [rsp+0x20],rbx
    2f0d:	mov    QWORD PTR [rsp+0x28],r12
    2f12:	mov    QWORD PTR [rsp+0x30],r13
    2f17:	mov    r12,rdi
    2f1a:	mov    QWORD PTR [rsp+0x10],0x0
    2f23:	mov    QWORD PTR [rsp],rdx
    2f27:	mov    rbx,rsi
    2f2a:	mov    rsi,rdx
    2f2d:	mov    rax,QWORD PTR [rbx+0x20]
    2f31:	mov    rdx,QWORD PTR [rax]
    2f34:	mov    r10d,0x1
    2f3a:	test   rsi,0x1
    2f41:	jne    2f61 <botlish_fn_17+0x61>
    2f47:	xor    r10d,r10d
    2f4a:	test   rsi,0x7
    2f51:	jne    2f61 <botlish_fn_17+0x61>
    2f57:	movzx  rax,BYTE PTR [rsi]
    2f5b:	cmp    al,0x1
    2f5d:	sete   r10b
    2f61:	test   r10b,r10b
    2f64:	jne    2f85 <botlish_fn_17+0x85>
    2f6a:	mov    rdi,r12
    2f6d:	mov    rax,QWORD PTR [rdi+0x10]
    2f71:	mov    rcx,QWORD PTR [rax+0xb8]
    2f78:	xor    rdx,rdx
    2f7b:	call   2f80 <botlish_fn_17+0x80>
			2f7c: R_X86_64_PLT32	rt_type_error-0x4
    2f80:	jmp    300c <botlish_fn_17+0x10c>
    2f85:	mov    rax,rsi
    2f88:	and    rax,rdx
    2f8b:	mov    r13,rsi
    2f8e:	test   rax,0x1
    2f94:	jne    2fba <botlish_fn_17+0xba>
    2f9a:	mov    rsi,r13
    2f9d:	mov    rdi,r12
    2fa0:	call   2fa5 <botlish_fn_17+0xa5>
			2fa1: R_X86_64_PLT32	rt_int_cmp-0x4
    2fa5:	mov    ecx,0x2
    2faa:	test   rax,rax
    2fad:	cmovge rcx,QWORD PTR [rip+0x103]        # 30b8 <botlish_fn_17+0x1b8>
    2fb5:	jmp    2fcd <botlish_fn_17+0xcd>
    2fba:	mov    ecx,0x2
    2fbf:	mov    rsi,r13
    2fc2:	cmp    rsi,rdx
    2fc5:	cmovge rcx,QWORD PTR [rip+0xeb]        # 30b8 <botlish_fn_17+0x1b8>
    2fcd:	cmp    rcx,0x6
    2fd1:	je     3099 <botlish_fn_17+0x199>
    2fd7:	mov    rax,QWORD PTR [rbx+0x20]
    2fdb:	mov    rsi,QWORD PTR [rax+0x8]
    2fdf:	mov    QWORD PTR [rsp+0x8],rsi
    2fe4:	mov    rdx,r13
    2fe7:	mov    rdi,r12
    2fea:	call   2fef <botlish_fn_17+0xef>
			2feb: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2fef:	test   rax,rax
    2ff2:	mov    rsi,rax
    2ff5:	je     300c <botlish_fn_17+0x10c>
    2ffb:	mov    rdi,r12
    2ffe:	call   3003 <botlish_fn_17+0x103>
			2fff: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    3003:	test   rax,rax
    3006:	jne    3027 <botlish_fn_17+0x127>
    300c:	xor    rax,rax
    300f:	mov    rbx,QWORD PTR [rsp+0x20]
    3014:	mov    r12,QWORD PTR [rsp+0x28]
    3019:	mov    r13,QWORD PTR [rsp+0x30]
    301e:	add    rsp,0x40
    3022:	mov    rsp,rbp
    3025:	pop    rbp
    3026:	ret
    3027:	cmp    rax,0x6
    302b:	je     3039 <botlish_fn_17+0x139>
    3031:	mov    rax,r13
    3034:	jmp    309c <botlish_fn_17+0x19c>
    3039:	mov    QWORD PTR [rsp+0x8],rbx
    303e:	mov    QWORD PTR [rsp+0x10],0x3
    3047:	mov    rsi,r13
    304a:	test   rsi,0x1
    3051:	je     3077 <botlish_fn_17+0x177>
    3057:	mov    rsi,r13
    305a:	mov    r11,rsi
    305d:	add    r11,0x2
    3061:	seto   al
    3064:	test   al,al
    3066:	jne    3077 <botlish_fn_17+0x177>
    306c:	mov    rsi,r11
    306f:	mov    r13,r11
    3072:	jmp    308d <botlish_fn_17+0x18d>
    3077:	mov    edx,0x3
    307c:	mov    rsi,r13
    307f:	mov    rdi,r12
    3082:	call   3087 <botlish_fn_17+0x187>
			3083: R_X86_64_PLT32	rt_int_add-0x4
    3087:	mov    rsi,rax
    308a:	mov    r13,rax
    308d:	mov    QWORD PTR [rsp],rsi
    3091:	mov    rsi,r13
    3094:	jmp    2f2d <botlish_fn_17+0x2d>
    3099:	mov    rax,r13
    309c:	mov    rbx,QWORD PTR [rsp+0x20]
    30a1:	mov    r12,QWORD PTR [rsp+0x28]
    30a6:	mov    r13,QWORD PTR [rsp+0x30]
    30ab:	add    rsp,0x40
    30af:	mov    rsp,rbp
    30b2:	pop    rbp
    30b3:	ret
    30b4:	add    BYTE PTR [rax],al
    30b6:	add    BYTE PTR [rax],al
    30b8:	(bad)
    30b9:	add    BYTE PTR [rax],al
    30bb:	add    BYTE PTR [rax],al
    30bd:	add    BYTE PTR [rax],al
	...

00000000000030c0 <botlish_entry_17: scan_alpha<generic>>:
    30c0:	push   rbp
    30c1:	mov    rbp,rsp
    30c4:	mov    rdx,QWORD PTR [rdx]
    30c7:	call   30cc <botlish_entry_17+0xc>
			30c8: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_alpha<generic>
    30cc:	mov    rsp,rbp
    30cf:	pop    rbp
    30d0:	ret
    30d1:	add    BYTE PTR [rax],al
    30d3:	add    BYTE PTR [rax],al
    30d5:	add    BYTE PTR [rax],al
	...

00000000000030d8 <botlish_fn_18: tld_ok<generic>>:
    30d8:	push   rbp
    30d9:	mov    rbp,rsp
    30dc:	sub    rsp,0x30
    30e0:	mov    QWORD PTR [rsp+0x10],rbx
    30e5:	mov    QWORD PTR [rsp+0x18],r12
    30ea:	mov    QWORD PTR [rsp+0x20],r13
    30ef:	mov    QWORD PTR [rsp+0x28],r14
    30f4:	mov    r12,rdi
    30f7:	mov    QWORD PTR [rsp],rdx
    30fb:	mov    r9,rdx
    30fe:	mov    rax,QWORD PTR [rsi+0x20]
    3102:	mov    r14,rsi
    3105:	mov    rsi,QWORD PTR [rax]
    3108:	mov    QWORD PTR [rsp+0x8],rsi
    310d:	mov    rbx,r9
    3110:	mov    rdx,rbx
    3113:	mov    rdi,r12
    3116:	call   311b <botlish_fn_18+0x43>
			3117: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_alpha<generic>
    311b:	mov    rsi,rax
    311e:	mov    r13,rax
    3121:	test   rax,rsi
    3124:	je     31fc <botlish_fn_18+0x124>
    312a:	mov    rax,r13
    312d:	mov    QWORD PTR [rsp+0x8],rax
    3132:	mov    rsi,r14
    3135:	mov    rax,QWORD PTR [rsi+0x20]
    3139:	mov    rdx,QWORD PTR [rax+0x8]
    313d:	mov    rax,r13
    3140:	and    rax,rdx
    3143:	test   rax,0x1
    3149:	jne    3172 <botlish_fn_18+0x9a>
    314f:	mov    rsi,r13
    3152:	mov    rdi,r12
    3155:	call   315a <botlish_fn_18+0x82>
			3156: R_X86_64_PLT32	rt_int_cmp-0x4
    315a:	mov    ecx,0x2
    315f:	test   rax,rax
    3162:	cmove  rcx,QWORD PTR [rip+0x166]        # 32d0 <botlish_fn_18+0x1f8>
    316a:	mov    rax,r13
    316d:	jmp    3185 <botlish_fn_18+0xad>
    3172:	mov    ecx,0x2
    3177:	mov    rax,r13
    317a:	cmp    rax,rdx
    317d:	cmove  rcx,QWORD PTR [rip+0x14b]        # 32d0 <botlish_fn_18+0x1f8>
    3185:	cmp    rcx,0x6
    3189:	je     319c <botlish_fn_18+0xc4>
    318f:	mov    ecx,0x2
    3194:	mov    rax,rcx
    3197:	jmp    32ac <botlish_fn_18+0x1d4>
    319c:	mov    ecx,0x1
    31a1:	test   rbx,0x1
    31a8:	je     31b6 <botlish_fn_18+0xde>
    31ae:	mov    r9,rbx
    31b1:	jmp    31db <botlish_fn_18+0x103>
    31b6:	xor    ecx,ecx
    31b8:	test   rbx,0x7
    31bf:	je     31cd <botlish_fn_18+0xf5>
    31c5:	mov    r9,rbx
    31c8:	jmp    31db <botlish_fn_18+0x103>
    31cd:	movzx  rdx,BYTE PTR [rbx]
    31d1:	mov    r9,rbx
    31d4:	rex cmp dl,0x1
    31d8:	sete   cl
    31db:	test   cl,cl
    31dd:	jne    321c <botlish_fn_18+0x144>
    31e3:	mov    rdi,r12
    31e6:	mov    rsi,QWORD PTR [rdi+0x10]
    31ea:	mov    rcx,QWORD PTR [rsi+0x128]
    31f1:	xor    rdx,rdx
    31f4:	mov    rsi,r9
    31f7:	call   31fc <botlish_fn_18+0x124>
			31f8: R_X86_64_PLT32	rt_type_error-0x4
    31fc:	xor    rax,rax
    31ff:	mov    rbx,QWORD PTR [rsp+0x10]
    3204:	mov    r12,QWORD PTR [rsp+0x18]
    3209:	mov    r13,QWORD PTR [rsp+0x20]
    320e:	mov    r14,QWORD PTR [rsp+0x28]
    3213:	add    rsp,0x30
    3217:	mov    rsp,rbp
    321a:	pop    rbp
    321b:	ret
    321c:	mov    rbx,r9
    321f:	mov    r8,rax
    3222:	and    r8,rbx
    3225:	test   r8,0x1
    322c:	jne    323d <botlish_fn_18+0x165>
    3232:	mov    rdx,r9
    3235:	mov    rsi,rax
    3238:	jmp    325e <botlish_fn_18+0x186>
    323d:	mov    rbx,r9
    3240:	mov    r10,rax
    3243:	sub    r10,rbx
    3246:	mov    r13,rax
    3249:	seto   al
    324c:	lea    rsi,[r10+0x1]
    3250:	test   al,al
    3252:	je     3269 <botlish_fn_18+0x191>
    3258:	mov    rdx,r9
    325b:	mov    rsi,r13
    325e:	mov    rdi,r12
    3261:	call   3266 <botlish_fn_18+0x18e>
			3262: R_X86_64_PLT32	rt_int_sub-0x4
    3266:	mov    rsi,rax
    3269:	test   rsi,0x1
    3270:	jne    329b <botlish_fn_18+0x1c3>
    3276:	mov    edx,0x5
    327b:	mov    rdi,r12
    327e:	call   3283 <botlish_fn_18+0x1ab>
			327f: R_X86_64_PLT32	rt_int_cmp-0x4
    3283:	mov    ecx,0x2
    3288:	test   rax,rax
    328b:	mov    rax,rcx
    328e:	cmovge rax,QWORD PTR [rip+0x3a]        # 32d0 <botlish_fn_18+0x1f8>
    3296:	jmp    32ac <botlish_fn_18+0x1d4>
    329b:	mov    eax,0x2
    32a0:	cmp    rsi,0x5
    32a4:	cmovge rax,QWORD PTR [rip+0x24]        # 32d0 <botlish_fn_18+0x1f8>
    32ac:	mov    rbx,QWORD PTR [rsp+0x10]
    32b1:	mov    r12,QWORD PTR [rsp+0x18]
    32b6:	mov    r13,QWORD PTR [rsp+0x20]
    32bb:	mov    r14,QWORD PTR [rsp+0x28]
    32c0:	add    rsp,0x30
    32c4:	mov    rsp,rbp
    32c7:	pop    rbp
    32c8:	ret
    32c9:	add    BYTE PTR [rax],al
    32cb:	add    BYTE PTR [rax],al
    32cd:	add    BYTE PTR [rax],al
    32cf:	add    BYTE PTR [rsi],al
    32d1:	add    BYTE PTR [rax],al
    32d3:	add    BYTE PTR [rax],al
    32d5:	add    BYTE PTR [rax],al
	...

00000000000032d8 <botlish_entry_18: tld_ok<generic>>:
    32d8:	push   rbp
    32d9:	mov    rbp,rsp
    32dc:	mov    rdx,QWORD PTR [rdx]
    32df:	call   32e4 <botlish_entry_18+0xc>
			32e0: R_X86_64_PLT32	botlish_fn_18-0x4 ; tld_ok<generic>
    32e4:	mov    rsp,rbp
    32e7:	pop    rbp
    32e8:	ret
    32e9:	add    BYTE PTR [rax],al
    32eb:	add    BYTE PTR [rax],al
    32ed:	add    BYTE PTR [rax],al
	...

00000000000032f0 <botlish_fn_19: domain_loop<generic>>:
    32f0:	push   rbp
    32f1:	mov    rbp,rsp
    32f4:	sub    rsp,0x50
    32f8:	mov    QWORD PTR [rsp+0x20],rbx
    32fd:	mov    QWORD PTR [rsp+0x28],r12
    3302:	mov    QWORD PTR [rsp+0x30],r13
    3307:	mov    QWORD PTR [rsp+0x38],r14
    330c:	mov    QWORD PTR [rsp+0x40],r15
    3311:	mov    QWORD PTR [rsp],rdx
    3315:	mov    r15,rdx
    3318:	lea    r13,[rsp+0x10]
    331d:	mov    rbx,rsi
    3320:	mov    rax,QWORD PTR [rbx+0x20]
    3324:	mov    rsi,QWORD PTR [rax]
    3327:	mov    QWORD PTR [rsp+0x8],rsi
    332c:	mov    r12,rdi
    332f:	mov    rdx,r15
    3332:	call   3337 <botlish_fn_19+0x47>
			3333: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_label<generic>
    3337:	mov    r10,rax
    333a:	mov    r14,rax
    333d:	test   rax,r10
    3340:	je     34b6 <botlish_fn_19+0x1c6>
    3346:	mov    rax,r14
    3349:	mov    QWORD PTR [rsp],rax
    334d:	mov    rdx,r15
    3350:	and    rax,rdx
    3353:	test   rax,0x1
    3359:	jne    337b <botlish_fn_19+0x8b>
    335f:	mov    rdx,r15
    3362:	mov    rsi,r14
    3365:	mov    rdi,r12
    3368:	call   336d <botlish_fn_19+0x7d>
			3369: R_X86_64_PLT32	rt_value_eq-0x4
    336d:	test   rax,rax
    3370:	je     34b6 <botlish_fn_19+0x1c6>
    3376:	jmp    338e <botlish_fn_19+0x9e>
    337b:	mov    eax,0x2
    3380:	mov    rdx,r15
    3383:	cmp    r14,rdx
    3386:	cmove  rax,QWORD PTR [rip+0x1aa]        # 3538 <botlish_fn_19+0x248>
    338e:	cmp    rax,0x6
    3392:	je     350d <botlish_fn_19+0x21d>
    3398:	mov    rdx,QWORD PTR [rbx+0x20]
    339c:	mov    rdx,QWORD PTR [rdx+0x8]
    33a0:	mov    rsi,r14
    33a3:	and    rsi,rdx
    33a6:	test   rsi,0x1
    33ad:	jne    33d3 <botlish_fn_19+0xe3>
    33b3:	mov    rsi,r14
    33b6:	mov    rdi,r12
    33b9:	call   33be <botlish_fn_19+0xce>
			33ba: R_X86_64_PLT32	rt_int_cmp-0x4
    33be:	mov    ecx,0x2
    33c3:	test   rax,rax
    33c6:	cmovge rcx,QWORD PTR [rip+0x16a]        # 3538 <botlish_fn_19+0x248>
    33ce:	jmp    33e3 <botlish_fn_19+0xf3>
    33d3:	mov    ecx,0x2
    33d8:	cmp    r14,rdx
    33db:	cmovge rcx,QWORD PTR [rip+0x155]        # 3538 <botlish_fn_19+0x248>
    33e3:	cmp    rcx,0x6
    33e7:	je     3501 <botlish_fn_19+0x211>
    33ed:	mov    r10,QWORD PTR [rbx+0x20]
    33f1:	mov    rsi,QWORD PTR [r10+0x10]
    33f5:	mov    QWORD PTR [rsp+0x8],rsi
    33fa:	mov    rcx,r13
    33fd:	mov    rdx,r14
    3400:	mov    rdi,r12
    3403:	call   3408 <botlish_fn_19+0x118>
			3404: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    3408:	test   rax,rax
    340b:	mov    rsi,rax
    340e:	je     34b6 <botlish_fn_19+0x1c6>
    3414:	mov    rdx,QWORD PTR [rsp+0x10]
    3419:	mov    rcx,QWORD PTR [rsp+0x18]
    341e:	mov    rax,QWORD PTR [r12+0x10]
    3423:	mov    r8,QWORD PTR [rax+0x118]
    342a:	mov    rdi,r12
    342d:	call   3432 <botlish_fn_19+0x142>
			342e: R_X86_64_PLT32	rt_str_region_eq-0x4
    3432:	cmp    rax,0x6
    3436:	je     3448 <botlish_fn_19+0x158>
    343c:	mov    rax,0xffffffffffffffff
    3443:	jmp    3514 <botlish_fn_19+0x224>
    3448:	mov    QWORD PTR [rsp+0x8],0x3
    3451:	test   r14,0x1
    3458:	je     347b <botlish_fn_19+0x18b>
    345e:	mov    rdx,r14
    3461:	add    rdx,0x2
    3465:	mov    r15,rdx
    3468:	seto   al
    346b:	test   al,al
    346d:	jne    347b <botlish_fn_19+0x18b>
    3473:	mov    rdx,r15
    3476:	jmp    3491 <botlish_fn_19+0x1a1>
    347b:	mov    edx,0x3
    3480:	mov    rsi,r14
    3483:	mov    rdi,r12
    3486:	call   348b <botlish_fn_19+0x19b>
			3487: R_X86_64_PLT32	rt_int_add-0x4
    348b:	mov    rdx,rax
    348e:	mov    r15,rax
    3491:	mov    QWORD PTR [rsp],rdx
    3495:	mov    rax,QWORD PTR [rbx+0x20]
    3499:	mov    rsi,QWORD PTR [rax+0x18]
    349d:	mov    QWORD PTR [rsp+0x8],rsi
    34a2:	mov    rdx,r15
    34a5:	mov    rdi,r12
    34a8:	call   34ad <botlish_fn_19+0x1bd>
			34a9: R_X86_64_PLT32	botlish_fn_18-0x4 ; tld_ok<generic>
    34ad:	test   rax,rax
    34b0:	jne    34db <botlish_fn_19+0x1eb>
    34b6:	xor    rax,rax
    34b9:	mov    rbx,QWORD PTR [rsp+0x20]
    34be:	mov    r12,QWORD PTR [rsp+0x28]
    34c3:	mov    r13,QWORD PTR [rsp+0x30]
    34c8:	mov    r14,QWORD PTR [rsp+0x38]
    34cd:	mov    r15,QWORD PTR [rsp+0x40]
    34d2:	add    rsp,0x50
    34d6:	mov    rsp,rbp
    34d9:	pop    rbp
    34da:	ret
    34db:	cmp    rax,0x6
    34df:	je     34f4 <botlish_fn_19+0x204>
    34e5:	mov    rdx,r15
    34e8:	mov    QWORD PTR [rsp],rdx
    34ec:	mov    rdi,r12
    34ef:	jmp    3320 <botlish_fn_19+0x30>
    34f4:	mov    rax,QWORD PTR [rbx+0x20]
    34f8:	mov    rax,QWORD PTR [rax+0x8]
    34fc:	jmp    3514 <botlish_fn_19+0x224>
    3501:	mov    rax,0xffffffffffffffff
    3508:	jmp    3514 <botlish_fn_19+0x224>
    350d:	mov    rax,0xffffffffffffffff
    3514:	mov    rbx,QWORD PTR [rsp+0x20]
    3519:	mov    r12,QWORD PTR [rsp+0x28]
    351e:	mov    r13,QWORD PTR [rsp+0x30]
    3523:	mov    r14,QWORD PTR [rsp+0x38]
    3528:	mov    r15,QWORD PTR [rsp+0x40]
    352d:	add    rsp,0x50
    3531:	mov    rsp,rbp
    3534:	pop    rbp
    3535:	ret
    3536:	add    BYTE PTR [rax],al
    3538:	(bad)
    3539:	add    BYTE PTR [rax],al
    353b:	add    BYTE PTR [rax],al
    353d:	add    BYTE PTR [rax],al
	...

0000000000003540 <botlish_entry_19: domain_loop<generic>>:
    3540:	push   rbp
    3541:	mov    rbp,rsp
    3544:	mov    rdx,QWORD PTR [rdx]
    3547:	call   354c <botlish_entry_19+0xc>
			3548: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    354c:	mov    rsp,rbp
    354f:	pop    rbp
    3550:	ret
    3551:	add    BYTE PTR [rax],al
    3553:	add    BYTE PTR [rax],al
    3555:	add    BYTE PTR [rax],al
	...

0000000000003558 <botlish_fn_20: <str>>:
    3558:	push   rbp
    3559:	mov    rbp,rsp
    355c:	sub    rsp,0xe0
    3563:	mov    QWORD PTR [rsp+0xb0],rbx
    356b:	mov    QWORD PTR [rsp+0xb8],r12
    3573:	mov    QWORD PTR [rsp+0xc0],r13
    357b:	mov    QWORD PTR [rsp+0xc8],r14
    3583:	mov    QWORD PTR [rsp+0xd0],r15
    358b:	mov    r15,rdi
    358e:	mov    QWORD PTR [rsp+0x10],0x0
    3597:	mov    QWORD PTR [rsp+0x18],0x0
    35a0:	mov    QWORD PTR [rsp+0x20],0x0
    35a9:	mov    QWORD PTR [rsp],rsi
    35ad:	mov    rbx,rsi
    35b0:	mov    rsi,rbx
    35b3:	mov    rdi,r15
    35b6:	call   35bb <botlish_fn_20+0x63>
			35b7: R_X86_64_PLT32	rt_str_len-0x4
    35bb:	mov    QWORD PTR [rsp+0xa8],rax
    35c3:	mov    QWORD PTR [rsp+0x8],rax
    35c8:	lea    r8,[rsp+0x28]
    35cd:	mov    QWORD PTR [rsp+0x28],rbx
    35d2:	mov    esi,0x16
    35d7:	mov    rdx,QWORD PTR [rip+0x0]        # 35de <botlish_fn_20+0x86>
			35da: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; char_at<generic>
    35de:	mov    ebx,0x1
    35e3:	mov    rcx,rbx
    35e6:	mov    rdi,r15
    35e9:	call   35ee <botlish_fn_20+0x96>
			35ea: R_X86_64_PLT32	rt_closure_new-0x4
    35ee:	mov    r14,rax
    35f1:	mov    QWORD PTR [rsp],rax
    35f5:	lea    r8,[rsp+0x30]
    35fa:	mov    rax,QWORD PTR [rsp+0xa8]
    3602:	mov    QWORD PTR [rsp+0x30],rax
    3607:	mov    rax,r14
    360a:	mov    QWORD PTR [rsp+0x38],rax
    360f:	mov    esi,0x1a
    3614:	mov    rdx,QWORD PTR [rip+0x0]        # 361b <botlish_fn_20+0xc3>
			3617: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; scan_local<generic>
    361b:	mov    r13d,0x2
    3621:	mov    rcx,r13
    3624:	mov    rdi,r15
    3627:	call   362c <botlish_fn_20+0xd4>
			3628: R_X86_64_PLT32	rt_closure_new-0x4
    362c:	mov    r12,rax
    362f:	mov    QWORD PTR [rsp+0x10],r12
    3634:	lea    r8,[rsp+0x40]
    3639:	mov    rax,QWORD PTR [rsp+0xa8]
    3641:	mov    QWORD PTR [rsp+0x40],rax
    3646:	mov    rax,r14
    3649:	mov    QWORD PTR [rsp+0x48],rax
    364e:	mov    esi,0x1b
    3653:	mov    rdx,QWORD PTR [rip+0x0]        # 365a <botlish_fn_20+0x102>
			3656: R_X86_64_GOTPCREL	botlish_entry_27-0x4 ; scan_label<generic>
    365a:	mov    rcx,r13
    365d:	mov    rdi,r15
    3660:	call   3665 <botlish_fn_20+0x10d>
			3661: R_X86_64_PLT32	rt_closure_new-0x4
    3665:	mov    QWORD PTR [rsp+0x18],rax
    366a:	mov    QWORD PTR [rsp+0xa0],rax
    3672:	lea    r8,[rsp+0x50]
    3677:	mov    rax,QWORD PTR [rsp+0xa8]
    367f:	mov    QWORD PTR [rsp+0x50],rax
    3684:	mov    QWORD PTR [rsp+0x58],r14
    3689:	mov    esi,0x1c
    368e:	mov    rdx,QWORD PTR [rip+0x0]        # 3695 <botlish_fn_20+0x13d>
			3691: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; scan_alpha<generic>
    3695:	mov    rcx,r13
    3698:	mov    rdi,r15
    369b:	call   36a0 <botlish_fn_20+0x148>
			369c: R_X86_64_PLT32	rt_closure_new-0x4
    36a0:	mov    QWORD PTR [rsp+0x20],rax
    36a5:	lea    r8,[rsp+0x60]
    36aa:	mov    QWORD PTR [rsp+0x60],rax
    36af:	mov    rax,QWORD PTR [rsp+0xa8]
    36b7:	mov    QWORD PTR [rsp+0x68],rax
    36bc:	mov    esi,0x1d
    36c1:	mov    rdx,QWORD PTR [rip+0x0]        # 36c8 <botlish_fn_20+0x170>
			36c4: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; tld_ok<generic>
    36c8:	mov    rcx,r13
    36cb:	mov    rdi,r15
    36ce:	call   36d3 <botlish_fn_20+0x17b>
			36cf: R_X86_64_PLT32	rt_closure_new-0x4
    36d3:	mov    QWORD PTR [rsp+0x20],rax
    36d8:	lea    r8,[rsp+0x70]
    36dd:	mov    rcx,QWORD PTR [rsp+0xa0]
    36e5:	mov    QWORD PTR [rsp+0x70],rcx
    36ea:	mov    rcx,QWORD PTR [rsp+0xa8]
    36f2:	mov    QWORD PTR [rsp+0x78],rcx
    36f7:	mov    QWORD PTR [rsp+0x80],r14
    36ff:	mov    QWORD PTR [rsp+0x88],rax
    3707:	mov    esi,0x1e
    370c:	mov    rdx,QWORD PTR [rip+0x0]        # 3713 <botlish_fn_20+0x1bb>
			370f: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; domain_loop<generic>
    3713:	mov    ecx,0x4
    3718:	mov    rdi,r15
    371b:	call   3720 <botlish_fn_20+0x1c8>
			371c: R_X86_64_PLT32	rt_closure_new-0x4
    3720:	mov    QWORD PTR [rsp+0x18],rax
    3725:	mov    r13,rax
    3728:	mov    QWORD PTR [rsp+0x20],0x1
    3731:	mov    rdx,rbx
    3734:	mov    rsi,r12
    3737:	mov    rdi,r15
    373a:	call   373f <botlish_fn_20+0x1e7>
			373b: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    373f:	mov    rcx,rax
    3742:	mov    r12,rax
    3745:	test   rax,rcx
    3748:	je     38a9 <botlish_fn_20+0x351>
    374e:	mov    rax,r12
    3751:	mov    QWORD PTR [rsp+0x10],rax
    3756:	test   rax,0x1
    375c:	jne    3787 <botlish_fn_20+0x22f>
    3762:	mov    edx,0x1
    3767:	mov    rsi,r12
    376a:	mov    rdi,r15
    376d:	call   3772 <botlish_fn_20+0x21a>
			376e: R_X86_64_PLT32	rt_int_cmp-0x4
    3772:	mov    esi,0x2
    3777:	test   rax,rax
    377a:	cmove  rsi,QWORD PTR [rip+0x206]        # 3988 <botlish_fn_20+0x430>
    3782:	jmp    3798 <botlish_fn_20+0x240>
    3787:	mov    esi,0x2
    378c:	cmp    r12,0x1
    3790:	cmove  rsi,QWORD PTR [rip+0x1f0]        # 3988 <botlish_fn_20+0x430>
    3798:	cmp    rsi,0x6
    379c:	je     394d <botlish_fn_20+0x3f5>
    37a2:	mov    rbx,QWORD PTR [rsp+0xa8]
    37aa:	mov    rax,r12
    37ad:	and    rax,rbx
    37b0:	test   rax,0x1
    37b6:	jne    37df <botlish_fn_20+0x287>
    37bc:	mov    rdx,rbx
    37bf:	mov    rsi,r12
    37c2:	mov    rdi,r15
    37c5:	call   37ca <botlish_fn_20+0x272>
			37c6: R_X86_64_PLT32	rt_int_cmp-0x4
    37ca:	mov    ecx,0x2
    37cf:	test   rax,rax
    37d2:	cmovge rcx,QWORD PTR [rip+0x1ae]        # 3988 <botlish_fn_20+0x430>
    37da:	jmp    37ef <botlish_fn_20+0x297>
    37df:	mov    ecx,0x2
    37e4:	cmp    r12,rbx
    37e7:	cmovge rcx,QWORD PTR [rip+0x199]        # 3988 <botlish_fn_20+0x430>
    37ef:	cmp    rcx,0x6
    37f3:	je     3943 <botlish_fn_20+0x3eb>
    37f9:	lea    rcx,[rsp+0x90]
    3801:	mov    rsi,r14
    3804:	mov    rdx,r12
    3807:	mov    rdi,r15
    380a:	call   380f <botlish_fn_20+0x2b7>
			380b: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    380f:	test   rax,rax
    3812:	mov    rsi,rax
    3815:	je     38a9 <botlish_fn_20+0x351>
    381b:	mov    rdx,QWORD PTR [rsp+0x90]
    3823:	mov    rcx,QWORD PTR [rsp+0x98]
    382b:	mov    rdi,r15
    382e:	mov    rax,QWORD PTR [rdi+0x10]
    3832:	mov    r8,QWORD PTR [rax+0x100]
    3839:	call   383e <botlish_fn_20+0x2e6>
			383a: R_X86_64_PLT32	rt_str_region_eq-0x4
    383e:	cmp    rax,0x6
    3842:	je     3855 <botlish_fn_20+0x2fd>
    3848:	mov    ecx,0x2
    384d:	mov    rax,rcx
    3850:	jmp    3952 <botlish_fn_20+0x3fa>
    3855:	mov    QWORD PTR [rsp],0x3
    385d:	test   r12,0x1
    3864:	je     387e <botlish_fn_20+0x326>
    386a:	mov    rdx,r12
    386d:	add    rdx,0x2
    3871:	seto   sil
    3875:	test   sil,sil
    3878:	je     3891 <botlish_fn_20+0x339>
    387e:	mov    edx,0x3
    3883:	mov    rsi,r12
    3886:	mov    rdi,r15
    3889:	call   388e <botlish_fn_20+0x336>
			388a: R_X86_64_PLT32	rt_int_add-0x4
    388e:	mov    rdx,rax
    3891:	mov    QWORD PTR [rsp],rdx
    3895:	mov    rsi,r13
    3898:	mov    rdi,r15
    389b:	call   38a0 <botlish_fn_20+0x348>
			389c: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    38a0:	test   rax,rax
    38a3:	jne    38e0 <botlish_fn_20+0x388>
    38a9:	xor    rax,rax
    38ac:	mov    rbx,QWORD PTR [rsp+0xb0]
    38b4:	mov    r12,QWORD PTR [rsp+0xb8]
    38bc:	mov    r13,QWORD PTR [rsp+0xc0]
    38c4:	mov    r14,QWORD PTR [rsp+0xc8]
    38cc:	mov    r15,QWORD PTR [rsp+0xd0]
    38d4:	add    rsp,0xe0
    38db:	mov    rsp,rbp
    38de:	pop    rbp
    38df:	ret
    38e0:	mov    rcx,rax
    38e3:	and    rcx,rbx
    38e6:	mov    rsi,rax
    38e9:	mov    QWORD PTR [rsp+0xa8],rbx
    38f1:	test   rcx,0x1
    38f8:	jne    3926 <botlish_fn_20+0x3ce>
    38fe:	mov    rdx,QWORD PTR [rsp+0xa8]
    3906:	mov    rdi,r15
    3909:	call   390e <botlish_fn_20+0x3b6>
			390a: R_X86_64_PLT32	rt_int_cmp-0x4
    390e:	mov    ecx,0x2
    3913:	test   rax,rax
    3916:	mov    rax,rcx
    3919:	cmove  rax,QWORD PTR [rip+0x67]        # 3988 <botlish_fn_20+0x430>
    3921:	jmp    3952 <botlish_fn_20+0x3fa>
    3926:	mov    rdx,QWORD PTR [rsp+0xa8]
    392e:	mov    eax,0x2
    3933:	cmp    rsi,rdx
    3936:	cmove  rax,QWORD PTR [rip+0x4a]        # 3988 <botlish_fn_20+0x430>
    393e:	jmp    3952 <botlish_fn_20+0x3fa>
    3943:	mov    eax,0x2
    3948:	jmp    3952 <botlish_fn_20+0x3fa>
    394d:	mov    eax,0x2
    3952:	mov    rbx,QWORD PTR [rsp+0xb0]
    395a:	mov    r12,QWORD PTR [rsp+0xb8]
    3962:	mov    r13,QWORD PTR [rsp+0xc0]
    396a:	mov    r14,QWORD PTR [rsp+0xc8]
    3972:	mov    r15,QWORD PTR [rsp+0xd0]
    397a:	add    rsp,0xe0
    3981:	mov    rsp,rbp
    3984:	pop    rbp
    3985:	ret
    3986:	add    BYTE PTR [rax],al
    3988:	(bad)
    3989:	add    BYTE PTR [rax],al
    398b:	add    BYTE PTR [rax],al
    398d:	add    BYTE PTR [rax],al
	...

0000000000003990 <botlish_entry_20: <str>>:
    3990:	push   rbp
    3991:	mov    rbp,rsp
    3994:	mov    rsi,QWORD PTR [rdx]
    3997:	call   399c <botlish_entry_20+0xc>
			3998: R_X86_64_PLT32	botlish_fn_20-0x4 ; <str>
    399c:	mov    rsp,rbp
    399f:	pop    rbp
    39a0:	ret
    39a1:	add    BYTE PTR [rax],al
    39a3:	add    BYTE PTR [rax],al
    39a5:	add    BYTE PTR [rax],al
	...

00000000000039a8 <botlish_fn_21: <generic>>:
    39a8:	push   rbp
    39a9:	mov    rbp,rsp
    39ac:	sub    rsp,0xe0
    39b3:	mov    QWORD PTR [rsp+0xb0],rbx
    39bb:	mov    QWORD PTR [rsp+0xb8],r12
    39c3:	mov    QWORD PTR [rsp+0xc0],r13
    39cb:	mov    QWORD PTR [rsp+0xc8],r14
    39d3:	mov    QWORD PTR [rsp+0xd0],r15
    39db:	mov    QWORD PTR [rsp+0x10],0x0
    39e4:	mov    QWORD PTR [rsp+0x18],0x0
    39ed:	mov    QWORD PTR [rsp+0x20],0x0
    39f6:	mov    QWORD PTR [rsp],rsi
    39fa:	xor    r8d,r8d
    39fd:	test   rsi,0x7
    3a04:	jne    3a14 <botlish_fn_21+0x6c>
    3a0a:	movzx  rax,BYTE PTR [rsi]
    3a0e:	cmp    al,0x2
    3a10:	sete   r8b
    3a14:	test   r8b,r8b
    3a17:	jne    3a37 <botlish_fn_21+0x8f>
    3a1d:	mov    rax,QWORD PTR [rdi+0x10]
    3a21:	mov    rcx,QWORD PTR [rax+0xd8]
    3a28:	mov    edx,0x1
    3a2d:	call   3a32 <botlish_fn_21+0x8a>
			3a2e: R_X86_64_PLT32	rt_type_error-0x4
    3a32:	jmp    3d26 <botlish_fn_21+0x37e>
    3a37:	mov    rbx,rsi
    3a3a:	mov    r15,rdi
    3a3d:	call   3a42 <botlish_fn_21+0x9a>
			3a3e: R_X86_64_PLT32	rt_str_len-0x4
    3a42:	mov    r14,rax
    3a45:	mov    QWORD PTR [rsp+0x8],rax
    3a4a:	lea    r8,[rsp+0x28]
    3a4f:	mov    QWORD PTR [rsp+0x28],rbx
    3a54:	mov    esi,0x16
    3a59:	mov    rdx,QWORD PTR [rip+0x0]        # 3a60 <botlish_fn_21+0xb8>
			3a5c: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; char_at<generic>
    3a60:	mov    ebx,0x1
    3a65:	mov    rcx,rbx
    3a68:	mov    rdi,r15
    3a6b:	call   3a70 <botlish_fn_21+0xc8>
			3a6c: R_X86_64_PLT32	rt_closure_new-0x4
    3a70:	mov    r13,rax
    3a73:	mov    QWORD PTR [rsp+0xa8],rbx
    3a7b:	mov    QWORD PTR [rsp],rax
    3a7f:	lea    r8,[rsp+0x30]
    3a84:	mov    rax,r14
    3a87:	mov    QWORD PTR [rsp+0x30],rax
    3a8c:	mov    rax,r13
    3a8f:	mov    QWORD PTR [rsp+0x38],rax
    3a94:	mov    esi,0x1a
    3a99:	mov    rdx,QWORD PTR [rip+0x0]        # 3aa0 <botlish_fn_21+0xf8>
			3a9c: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; scan_local<generic>
    3aa0:	mov    r12d,0x2
    3aa6:	mov    rcx,r12
    3aa9:	mov    rdi,r15
    3aac:	call   3ab1 <botlish_fn_21+0x109>
			3aad: R_X86_64_PLT32	rt_closure_new-0x4
    3ab1:	mov    rbx,rax
    3ab4:	mov    QWORD PTR [rsp+0x10],rbx
    3ab9:	lea    r8,[rsp+0x40]
    3abe:	mov    rax,r14
    3ac1:	mov    QWORD PTR [rsp+0x40],rax
    3ac6:	mov    rax,r13
    3ac9:	mov    QWORD PTR [rsp+0x48],rax
    3ace:	mov    esi,0x1b
    3ad3:	mov    rdx,QWORD PTR [rip+0x0]        # 3ada <botlish_fn_21+0x132>
			3ad6: R_X86_64_GOTPCREL	botlish_entry_27-0x4 ; scan_label<generic>
    3ada:	mov    rcx,r12
    3add:	mov    rdi,r15
    3ae0:	call   3ae5 <botlish_fn_21+0x13d>
			3ae1: R_X86_64_PLT32	rt_closure_new-0x4
    3ae5:	mov    QWORD PTR [rsp+0x18],rax
    3aea:	mov    QWORD PTR [rsp+0xa0],rax
    3af2:	lea    r8,[rsp+0x50]
    3af7:	mov    rax,r14
    3afa:	mov    QWORD PTR [rsp+0x50],rax
    3aff:	mov    QWORD PTR [rsp+0x58],r13
    3b04:	mov    esi,0x1c
    3b09:	mov    rdx,QWORD PTR [rip+0x0]        # 3b10 <botlish_fn_21+0x168>
			3b0c: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; scan_alpha<generic>
    3b10:	mov    rcx,r12
    3b13:	mov    rdi,r15
    3b16:	call   3b1b <botlish_fn_21+0x173>
			3b17: R_X86_64_PLT32	rt_closure_new-0x4
    3b1b:	mov    QWORD PTR [rsp+0x20],rax
    3b20:	lea    r8,[rsp+0x60]
    3b25:	mov    QWORD PTR [rsp+0x60],rax
    3b2a:	mov    rax,r14
    3b2d:	mov    QWORD PTR [rsp+0x68],rax
    3b32:	mov    esi,0x1d
    3b37:	mov    rdx,QWORD PTR [rip+0x0]        # 3b3e <botlish_fn_21+0x196>
			3b3a: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; tld_ok<generic>
    3b3e:	mov    rcx,r12
    3b41:	mov    rdi,r15
    3b44:	call   3b49 <botlish_fn_21+0x1a1>
			3b45: R_X86_64_PLT32	rt_closure_new-0x4
    3b49:	mov    QWORD PTR [rsp+0x20],rax
    3b4e:	lea    r8,[rsp+0x70]
    3b53:	mov    rcx,QWORD PTR [rsp+0xa0]
    3b5b:	mov    QWORD PTR [rsp+0x70],rcx
    3b60:	mov    rcx,r14
    3b63:	mov    QWORD PTR [rsp+0x78],rcx
    3b68:	mov    QWORD PTR [rsp+0x80],r13
    3b70:	mov    QWORD PTR [rsp+0x88],rax
    3b78:	mov    esi,0x1e
    3b7d:	mov    rdx,QWORD PTR [rip+0x0]        # 3b84 <botlish_fn_21+0x1dc>
			3b80: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; domain_loop<generic>
    3b84:	mov    ecx,0x4
    3b89:	mov    rdi,r15
    3b8c:	call   3b91 <botlish_fn_21+0x1e9>
			3b8d: R_X86_64_PLT32	rt_closure_new-0x4
    3b91:	mov    QWORD PTR [rsp+0x18],rax
    3b96:	mov    QWORD PTR [rsp+0xa0],rax
    3b9e:	mov    QWORD PTR [rsp+0x20],0x1
    3ba7:	mov    rsi,rbx
    3baa:	mov    rdx,QWORD PTR [rsp+0xa8]
    3bb2:	mov    rdi,r15
    3bb5:	call   3bba <botlish_fn_21+0x212>
			3bb6: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    3bba:	mov    rcx,rax
    3bbd:	mov    r12,rax
    3bc0:	test   rax,rcx
    3bc3:	je     3d26 <botlish_fn_21+0x37e>
    3bc9:	mov    rax,r12
    3bcc:	mov    QWORD PTR [rsp+0x10],rax
    3bd1:	test   rax,0x1
    3bd7:	jne    3c05 <botlish_fn_21+0x25d>
    3bdd:	mov    rdx,QWORD PTR [rsp+0xa8]
    3be5:	mov    rsi,r12
    3be8:	mov    rdi,r15
    3beb:	call   3bf0 <botlish_fn_21+0x248>
			3bec: R_X86_64_PLT32	rt_int_cmp-0x4
    3bf0:	mov    ecx,0x2
    3bf5:	test   rax,rax
    3bf8:	cmove  rcx,QWORD PTR [rip+0x1f8]        # 3df8 <botlish_fn_21+0x450>
    3c00:	jmp    3c16 <botlish_fn_21+0x26e>
    3c05:	mov    ecx,0x2
    3c0a:	cmp    r12,0x1
    3c0e:	cmove  rcx,QWORD PTR [rip+0x1e2]        # 3df8 <botlish_fn_21+0x450>
    3c16:	cmp    rcx,0x6
    3c1a:	je     3dbb <botlish_fn_21+0x413>
    3c20:	mov    rbx,r14
    3c23:	mov    rcx,r12
    3c26:	and    rcx,rbx
    3c29:	test   rcx,0x1
    3c30:	jne    3c59 <botlish_fn_21+0x2b1>
    3c36:	mov    rdx,rbx
    3c39:	mov    rsi,r12
    3c3c:	mov    rdi,r15
    3c3f:	call   3c44 <botlish_fn_21+0x29c>
			3c40: R_X86_64_PLT32	rt_int_cmp-0x4
    3c44:	mov    ecx,0x2
    3c49:	test   rax,rax
    3c4c:	cmovge rcx,QWORD PTR [rip+0x1a4]        # 3df8 <botlish_fn_21+0x450>
    3c54:	jmp    3c69 <botlish_fn_21+0x2c1>
    3c59:	mov    ecx,0x2
    3c5e:	cmp    r12,rbx
    3c61:	cmovge rcx,QWORD PTR [rip+0x18f]        # 3df8 <botlish_fn_21+0x450>
    3c69:	cmp    rcx,0x6
    3c6d:	je     3db1 <botlish_fn_21+0x409>
    3c73:	lea    rcx,[rsp+0x90]
    3c7b:	mov    rsi,r13
    3c7e:	mov    rdx,r12
    3c81:	mov    rdi,r15
    3c84:	call   3c89 <botlish_fn_21+0x2e1>
			3c85: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    3c89:	test   rax,rax
    3c8c:	mov    rsi,rax
    3c8f:	je     3d26 <botlish_fn_21+0x37e>
    3c95:	mov    rdx,QWORD PTR [rsp+0x90]
    3c9d:	mov    rcx,QWORD PTR [rsp+0x98]
    3ca5:	mov    rdi,r15
    3ca8:	mov    rax,QWORD PTR [rdi+0x10]
    3cac:	mov    r8,QWORD PTR [rax+0x100]
    3cb3:	call   3cb8 <botlish_fn_21+0x310>
			3cb4: R_X86_64_PLT32	rt_str_region_eq-0x4
    3cb8:	cmp    rax,0x6
    3cbc:	je     3ccf <botlish_fn_21+0x327>
    3cc2:	mov    ecx,0x2
    3cc7:	mov    rax,rcx
    3cca:	jmp    3dc0 <botlish_fn_21+0x418>
    3ccf:	mov    QWORD PTR [rsp],0x3
    3cd7:	test   r12,0x1
    3cde:	je     3cf6 <botlish_fn_21+0x34e>
    3ce4:	mov    rdx,r12
    3ce7:	add    rdx,0x2
    3ceb:	seto   al
    3cee:	test   al,al
    3cf0:	je     3d09 <botlish_fn_21+0x361>
    3cf6:	mov    edx,0x3
    3cfb:	mov    rsi,r12
    3cfe:	mov    rdi,r15
    3d01:	call   3d06 <botlish_fn_21+0x35e>
			3d02: R_X86_64_PLT32	rt_int_add-0x4
    3d06:	mov    rdx,rax
    3d09:	mov    QWORD PTR [rsp],rdx
    3d0d:	mov    rsi,QWORD PTR [rsp+0xa0]
    3d15:	mov    rdi,r15
    3d18:	call   3d1d <botlish_fn_21+0x375>
			3d19: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    3d1d:	test   rax,rax
    3d20:	jne    3d5d <botlish_fn_21+0x3b5>
    3d26:	xor    rax,rax
    3d29:	mov    rbx,QWORD PTR [rsp+0xb0]
    3d31:	mov    r12,QWORD PTR [rsp+0xb8]
    3d39:	mov    r13,QWORD PTR [rsp+0xc0]
    3d41:	mov    r14,QWORD PTR [rsp+0xc8]
    3d49:	mov    r15,QWORD PTR [rsp+0xd0]
    3d51:	add    rsp,0xe0
    3d58:	mov    rsp,rbp
    3d5b:	pop    rbp
    3d5c:	ret
    3d5d:	mov    rcx,rax
    3d60:	and    rcx,rbx
    3d63:	mov    rsi,rax
    3d66:	mov    r14,rbx
    3d69:	test   rcx,0x1
    3d70:	jne    3d99 <botlish_fn_21+0x3f1>
    3d76:	mov    rdx,r14
    3d79:	mov    rdi,r15
    3d7c:	call   3d81 <botlish_fn_21+0x3d9>
			3d7d: R_X86_64_PLT32	rt_int_cmp-0x4
    3d81:	mov    ecx,0x2
    3d86:	test   rax,rax
    3d89:	mov    rax,rcx
    3d8c:	cmove  rax,QWORD PTR [rip+0x64]        # 3df8 <botlish_fn_21+0x450>
    3d94:	jmp    3dc0 <botlish_fn_21+0x418>
    3d99:	mov    rdx,r14
    3d9c:	mov    eax,0x2
    3da1:	cmp    rsi,rdx
    3da4:	cmove  rax,QWORD PTR [rip+0x4c]        # 3df8 <botlish_fn_21+0x450>
    3dac:	jmp    3dc0 <botlish_fn_21+0x418>
    3db1:	mov    eax,0x2
    3db6:	jmp    3dc0 <botlish_fn_21+0x418>
    3dbb:	mov    eax,0x2
    3dc0:	mov    rbx,QWORD PTR [rsp+0xb0]
    3dc8:	mov    r12,QWORD PTR [rsp+0xb8]
    3dd0:	mov    r13,QWORD PTR [rsp+0xc0]
    3dd8:	mov    r14,QWORD PTR [rsp+0xc8]
    3de0:	mov    r15,QWORD PTR [rsp+0xd0]
    3de8:	add    rsp,0xe0
    3def:	mov    rsp,rbp
    3df2:	pop    rbp
    3df3:	ret
    3df4:	add    BYTE PTR [rax],al
    3df6:	add    BYTE PTR [rax],al
    3df8:	(bad)
    3df9:	add    BYTE PTR [rax],al
    3dfb:	add    BYTE PTR [rax],al
    3dfd:	add    BYTE PTR [rax],al
	...

0000000000003e00 <botlish_entry_21: <generic>>:
    3e00:	push   rbp
    3e01:	mov    rbp,rsp
    3e04:	mov    rsi,QWORD PTR [rdx]
    3e07:	call   3e0c <botlish_entry_21+0xc>
			3e08: R_X86_64_PLT32	botlish_fn_21-0x4 ; <generic>
    3e0c:	mov    rsp,rbp
    3e0f:	pop    rbp
    3e10:	ret

0000000000003e11 <botlish_fn_22: char_at<generic>>:
    3e11:	push   rbp
    3e12:	mov    rbp,rsp
    3e15:	sub    rsp,0x40
    3e19:	mov    QWORD PTR [rsp+0x20],rbx
    3e1e:	mov    QWORD PTR [rsp+0x28],r12
    3e23:	mov    QWORD PTR [rsp+0x30],r13
    3e28:	mov    QWORD PTR [rsp],rdx
    3e2c:	mov    rax,QWORD PTR [rsi+0x20]
    3e30:	mov    rsi,QWORD PTR [rax]
    3e33:	mov    QWORD PTR [rsp+0x8],rsi
    3e38:	mov    r13,rsi
    3e3b:	mov    QWORD PTR [rsp+0x10],0x3
    3e44:	mov    r10d,0x1
    3e4a:	test   rdx,0x1
    3e51:	je     3e5f <botlish_fn_22+0x4e>
    3e57:	mov    rbx,rdx
    3e5a:	jmp    3e84 <botlish_fn_22+0x73>
    3e5f:	xor    r10d,r10d
    3e62:	test   rdx,0x7
    3e69:	je     3e77 <botlish_fn_22+0x66>
    3e6f:	mov    rbx,rdx
    3e72:	jmp    3e84 <botlish_fn_22+0x73>
    3e77:	movzx  rax,BYTE PTR [rdx]
    3e7b:	mov    rbx,rdx
    3e7e:	cmp    al,0x1
    3e80:	sete   r10b
    3e84:	test   r10b,r10b
    3e87:	jne    3ea8 <botlish_fn_22+0x97>
    3e8d:	mov    rax,QWORD PTR [rdi+0x10]
    3e91:	mov    rcx,QWORD PTR [rax+0x108]
    3e98:	xor    rdx,rdx
    3e9b:	mov    rsi,rbx
    3e9e:	call   3ea3 <botlish_fn_22+0x92>
			3e9f: R_X86_64_PLT32	rt_type_error-0x4
    3ea3:	jmp    3f5a <botlish_fn_22+0x149>
    3ea8:	mov    rsi,rbx
    3eab:	mov    r12,rdi
    3eae:	test   rsi,0x1
    3eb5:	je     3ed0 <botlish_fn_22+0xbf>
    3ebb:	mov    rsi,rbx
    3ebe:	mov    rcx,rsi
    3ec1:	add    rcx,0x2
    3ec5:	seto   al
    3ec8:	test   al,al
    3eca:	je     3ee3 <botlish_fn_22+0xd2>
    3ed0:	mov    edx,0x3
    3ed5:	mov    rsi,rbx
    3ed8:	mov    rdi,r12
    3edb:	call   3ee0 <botlish_fn_22+0xcf>
			3edc: R_X86_64_PLT32	rt_int_add-0x4
    3ee0:	mov    rcx,rax
    3ee3:	mov    QWORD PTR [rsp+0x10],rcx
    3ee8:	mov    eax,0x1
    3eed:	mov    rsi,rbx
    3ef0:	test   rsi,0x1
    3ef7:	jne    3f1d <botlish_fn_22+0x10c>
    3efd:	xor    eax,eax
    3eff:	mov    rsi,rbx
    3f02:	test   rsi,0x7
    3f09:	jne    3f1d <botlish_fn_22+0x10c>
    3f0f:	mov    rsi,rbx
    3f12:	movzx  rdx,BYTE PTR [rsi]
    3f16:	rex cmp dl,0x1
    3f1a:	sete   al
    3f1d:	test   al,al
    3f1f:	jne    3f43 <botlish_fn_22+0x132>
    3f25:	mov    rdi,r12
    3f28:	mov    rsi,QWORD PTR [rdi+0x10]
    3f2c:	mov    rcx,QWORD PTR [rsi+0x110]
    3f33:	xor    rdx,rdx
    3f36:	mov    rsi,rbx
    3f39:	call   3f3e <botlish_fn_22+0x12d>
			3f3a: R_X86_64_PLT32	rt_type_error-0x4
    3f3e:	jmp    3f5a <botlish_fn_22+0x149>
    3f43:	mov    rdx,rbx
    3f46:	mov    rsi,r13
    3f49:	mov    rdi,r12
    3f4c:	call   3f51 <botlish_fn_22+0x140>
			3f4d: R_X86_64_PLT32	rt_substr-0x4
    3f51:	test   rax,rax
    3f54:	jne    3f75 <botlish_fn_22+0x164>
    3f5a:	xor    rax,rax
    3f5d:	mov    rbx,QWORD PTR [rsp+0x20]
    3f62:	mov    r12,QWORD PTR [rsp+0x28]
    3f67:	mov    r13,QWORD PTR [rsp+0x30]
    3f6c:	add    rsp,0x40
    3f70:	mov    rsp,rbp
    3f73:	pop    rbp
    3f74:	ret
    3f75:	mov    rbx,QWORD PTR [rsp+0x20]
    3f7a:	mov    r12,QWORD PTR [rsp+0x28]
    3f7f:	mov    r13,QWORD PTR [rsp+0x30]
    3f84:	add    rsp,0x40
    3f88:	mov    rsp,rbp
    3f8b:	pop    rbp
    3f8c:	ret

0000000000003f8d <botlish_entry_22: char_at<generic>>:
    3f8d:	push   rbp
    3f8e:	mov    rbp,rsp
    3f91:	mov    rdx,QWORD PTR [rdx]
    3f94:	call   3f99 <botlish_entry_22+0xc>
			3f95: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    3f99:	mov    rsp,rbp
    3f9c:	pop    rbp
    3f9d:	ret

0000000000003f9e <botlish_fn_23: char_at<generic>>:
    3f9e:	push   rbp
    3f9f:	mov    rbp,rsp
    3fa2:	sub    rsp,0x40
    3fa6:	mov    QWORD PTR [rsp+0x20],rbx
    3fab:	mov    QWORD PTR [rsp+0x28],r12
    3fb0:	mov    QWORD PTR [rsp+0x30],r13
    3fb5:	mov    QWORD PTR [rsp+0x38],r14
    3fba:	mov    r13,rcx
    3fbd:	mov    QWORD PTR [rsp],rdx
    3fc1:	mov    rax,QWORD PTR [rsi+0x20]
    3fc5:	mov    rax,QWORD PTR [rax]
    3fc8:	mov    QWORD PTR [rsp+0x8],rax
    3fcd:	mov    r14,rax
    3fd0:	mov    QWORD PTR [rsp+0x10],0x3
    3fd9:	mov    r11d,0x1
    3fdf:	test   rdx,0x1
    3fe6:	je     3ff4 <botlish_fn_23+0x56>
    3fec:	mov    r12,rdx
    3fef:	jmp    4019 <botlish_fn_23+0x7b>
    3ff4:	xor    r11d,r11d
    3ff7:	test   rdx,0x7
    3ffe:	je     400c <botlish_fn_23+0x6e>
    4004:	mov    r12,rdx
    4007:	jmp    4019 <botlish_fn_23+0x7b>
    400c:	movzx  rax,BYTE PTR [rdx]
    4010:	mov    r12,rdx
    4013:	cmp    al,0x1
    4015:	sete   r11b
    4019:	test   r11b,r11b
    401c:	jne    403d <botlish_fn_23+0x9f>
    4022:	mov    rax,QWORD PTR [rdi+0x10]
    4026:	mov    rcx,QWORD PTR [rax+0x108]
    402d:	xor    rdx,rdx
    4030:	mov    rsi,r12
    4033:	call   4038 <botlish_fn_23+0x9a>
			4034: R_X86_64_PLT32	rt_type_error-0x4
    4038:	jmp    40f5 <botlish_fn_23+0x157>
    403d:	mov    rbx,rdi
    4040:	mov    rsi,r12
    4043:	test   rsi,0x1
    404a:	jne    4058 <botlish_fn_23+0xba>
    4050:	mov    r12,rsi
    4053:	jmp    406d <botlish_fn_23+0xcf>
    4058:	mov    rax,rsi
    405b:	add    rax,0x2
    405f:	mov    r12,rsi
    4062:	seto   cl
    4065:	test   cl,cl
    4067:	je     407d <botlish_fn_23+0xdf>
    406d:	mov    edx,0x3
    4072:	mov    rsi,r12
    4075:	mov    rdi,rbx
    4078:	call   407d <botlish_fn_23+0xdf>
			4079: R_X86_64_PLT32	rt_int_add-0x4
    407d:	mov    ecx,0x1
    4082:	mov    rsi,r12
    4085:	test   rsi,0x1
    408c:	jne    40b2 <botlish_fn_23+0x114>
    4092:	xor    ecx,ecx
    4094:	mov    rsi,r12
    4097:	test   rsi,0x7
    409e:	jne    40b2 <botlish_fn_23+0x114>
    40a4:	mov    rsi,r12
    40a7:	movzx  rdx,BYTE PTR [rsi]
    40ab:	rex cmp dl,0x1
    40af:	sete   cl
    40b2:	test   cl,cl
    40b4:	jne    40d8 <botlish_fn_23+0x13a>
    40ba:	mov    rdi,rbx
    40bd:	mov    rsi,QWORD PTR [rdi+0x10]
    40c1:	mov    rcx,QWORD PTR [rsi+0x110]
    40c8:	xor    rdx,rdx
    40cb:	mov    rsi,r12
    40ce:	call   40d3 <botlish_fn_23+0x135>
			40cf: R_X86_64_PLT32	rt_type_error-0x4
    40d3:	jmp    40f5 <botlish_fn_23+0x157>
    40d8:	mov    rdi,rbx
    40db:	mov    rbx,rax
    40de:	mov    rcx,rbx
    40e1:	mov    rdx,r12
    40e4:	mov    rsi,r14
    40e7:	call   40ec <botlish_fn_23+0x14e>
			40e8: R_X86_64_PLT32	rt_str_region_check-0x4
    40ec:	test   rax,rax
    40ef:	jne    4115 <botlish_fn_23+0x177>
    40f5:	xor    rax,rax
    40f8:	mov    rbx,QWORD PTR [rsp+0x20]
    40fd:	mov    r12,QWORD PTR [rsp+0x28]
    4102:	mov    r13,QWORD PTR [rsp+0x30]
    4107:	mov    r14,QWORD PTR [rsp+0x38]
    410c:	add    rsp,0x40
    4110:	mov    rsp,rbp
    4113:	pop    rbp
    4114:	ret
    4115:	mov    rcx,r13
    4118:	mov    rsi,r12
    411b:	mov    QWORD PTR [rcx],rsi
    411e:	mov    QWORD PTR [rcx+0x8],rbx
    4122:	mov    rax,r14
    4125:	mov    rbx,QWORD PTR [rsp+0x20]
    412a:	mov    r12,QWORD PTR [rsp+0x28]
    412f:	mov    r13,QWORD PTR [rsp+0x30]
    4134:	mov    r14,QWORD PTR [rsp+0x38]
    4139:	add    rsp,0x40
    413d:	mov    rsp,rbp
    4140:	pop    rbp
    4141:	ret

0000000000004142 <botlish_entry_23: char_at<generic>>:
    4142:	push   rbp
    4143:	mov    rbp,rsp
    4146:	ud2

0000000000004148 <botlish_fn_24: is_local_char<str>>:
    4148:	push   rbp
    4149:	mov    rbp,rsp
    414c:	sub    rsp,0x10
    4150:	mov    QWORD PTR [rsp],rbx
    4154:	mov    QWORD PTR [rsp+0x8],r12
    4159:	mov    rbx,rsi
    415c:	mov    r12,rdi
    415f:	mov    rsi,rbx
    4162:	mov    rdi,r12
    4165:	call   416a <botlish_fn_24+0x22>
			4166: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    416a:	test   rax,rax
    416d:	jne    4188 <botlish_fn_24+0x40>
    4173:	xor    rax,rax
    4176:	mov    rbx,QWORD PTR [rsp]
    417a:	mov    r12,QWORD PTR [rsp+0x8]
    417f:	add    rsp,0x10
    4183:	mov    rsp,rbp
    4186:	pop    rbp
    4187:	ret
    4188:	cmp    rax,0x6
    418c:	je     4287 <botlish_fn_24+0x13f>
    4192:	mov    rdi,r12
    4195:	mov    rax,QWORD PTR [rdi+0x10]
    4199:	mov    rsi,QWORD PTR [rax+0x118]
    41a0:	mov    edx,0x1
    41a5:	mov    ecx,0x3
    41aa:	mov    r8,rbx
    41ad:	call   41b2 <botlish_fn_24+0x6a>
			41ae: R_X86_64_PLT32	rt_str_region_eq-0x4
    41b2:	cmp    rax,0x6
    41b6:	je     427d <botlish_fn_24+0x135>
    41bc:	mov    rdi,r12
    41bf:	mov    rax,QWORD PTR [rdi+0x10]
    41c3:	mov    rsi,QWORD PTR [rax+0x120]
    41ca:	mov    edx,0x1
    41cf:	mov    ecx,0x3
    41d4:	mov    r8,rbx
    41d7:	call   41dc <botlish_fn_24+0x94>
			41d8: R_X86_64_PLT32	rt_str_region_eq-0x4
    41dc:	cmp    rax,0x6
    41e0:	je     4273 <botlish_fn_24+0x12b>
    41e6:	mov    rdi,r12
    41e9:	mov    rax,QWORD PTR [rdi+0x10]
    41ed:	mov    rsi,QWORD PTR [rax+0xc0]
    41f4:	mov    edx,0x1
    41f9:	mov    ecx,0x3
    41fe:	mov    r8,rbx
    4201:	call   4206 <botlish_fn_24+0xbe>
			4202: R_X86_64_PLT32	rt_str_region_eq-0x4
    4206:	cmp    rax,0x6
    420a:	je     4269 <botlish_fn_24+0x121>
    4210:	mov    rdi,r12
    4213:	mov    rax,QWORD PTR [rdi+0x10]
    4217:	mov    rsi,QWORD PTR [rax+0x108]
    421e:	mov    edx,0x1
    4223:	mov    ecx,0x3
    4228:	mov    r8,rbx
    422b:	call   4230 <botlish_fn_24+0xe8>
			422c: R_X86_64_PLT32	rt_str_region_eq-0x4
    4230:	cmp    rax,0x6
    4234:	je     425f <botlish_fn_24+0x117>
    423a:	mov    rdi,r12
    423d:	mov    rax,QWORD PTR [rdi+0x10]
    4241:	mov    rsi,QWORD PTR [rax+0x128]
    4248:	mov    edx,0x1
    424d:	mov    ecx,0x3
    4252:	mov    r8,rbx
    4255:	call   425a <botlish_fn_24+0x112>
			4256: R_X86_64_PLT32	rt_str_region_eq-0x4
    425a:	jmp    428c <botlish_fn_24+0x144>
    425f:	mov    eax,0x6
    4264:	jmp    428c <botlish_fn_24+0x144>
    4269:	mov    eax,0x6
    426e:	jmp    428c <botlish_fn_24+0x144>
    4273:	mov    eax,0x6
    4278:	jmp    428c <botlish_fn_24+0x144>
    427d:	mov    eax,0x6
    4282:	jmp    428c <botlish_fn_24+0x144>
    4287:	mov    eax,0x6
    428c:	mov    rbx,QWORD PTR [rsp]
    4290:	mov    r12,QWORD PTR [rsp+0x8]
    4295:	add    rsp,0x10
    4299:	mov    rsp,rbp
    429c:	pop    rbp
    429d:	ret

000000000000429e <botlish_entry_24: is_local_char<str>>:
    429e:	push   rbp
    429f:	mov    rbp,rsp
    42a2:	mov    rsi,QWORD PTR [rdx]
    42a5:	call   42aa <botlish_entry_24+0xc>
			42a6: R_X86_64_PLT32	botlish_fn_24-0x4 ; is_local_char<str>
    42aa:	mov    rsp,rbp
    42ad:	pop    rbp
    42ae:	ret

00000000000042af <botlish_fn_25: is_label_char<str>>:
    42af:	push   rbp
    42b0:	mov    rbp,rsp
    42b3:	sub    rsp,0x10
    42b7:	mov    QWORD PTR [rsp],r13
    42bb:	mov    QWORD PTR [rsp+0x8],r15
    42c0:	mov    r13,rsi
    42c3:	mov    r15,rdi
    42c6:	mov    rsi,r13
    42c9:	mov    rdi,r15
    42cc:	call   42d1 <botlish_fn_25+0x22>
			42cd: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    42d1:	test   rax,rax
    42d4:	jne    42ef <botlish_fn_25+0x40>
    42da:	xor    rax,rax
    42dd:	mov    r13,QWORD PTR [rsp]
    42e1:	mov    r15,QWORD PTR [rsp+0x8]
    42e6:	add    rsp,0x10
    42ea:	mov    rsp,rbp
    42ed:	pop    rbp
    42ee:	ret
    42ef:	cmp    rax,0x6
    42f3:	je     431e <botlish_fn_25+0x6f>
    42f9:	mov    rdi,r15
    42fc:	mov    rax,QWORD PTR [rdi+0x10]
    4300:	mov    rsi,QWORD PTR [rax+0x128]
    4307:	mov    edx,0x1
    430c:	mov    ecx,0x3
    4311:	mov    r8,r13
    4314:	call   4319 <botlish_fn_25+0x6a>
			4315: R_X86_64_PLT32	rt_str_region_eq-0x4
    4319:	jmp    4323 <botlish_fn_25+0x74>
    431e:	mov    eax,0x6
    4323:	mov    r13,QWORD PTR [rsp]
    4327:	mov    r15,QWORD PTR [rsp+0x8]
    432c:	add    rsp,0x10
    4330:	mov    rsp,rbp
    4333:	pop    rbp
    4334:	ret

0000000000004335 <botlish_entry_25: is_label_char<str>>:
    4335:	push   rbp
    4336:	mov    rbp,rsp
    4339:	mov    rsi,QWORD PTR [rdx]
    433c:	call   4341 <botlish_entry_25+0xc>
			433d: R_X86_64_PLT32	botlish_fn_25-0x4 ; is_label_char<str>
    4341:	mov    rsp,rbp
    4344:	pop    rbp
    4345:	ret
	...

0000000000004348 <botlish_fn_26: scan_local<generic>>:
    4348:	push   rbp
    4349:	mov    rbp,rsp
    434c:	sub    rsp,0x40
    4350:	mov    QWORD PTR [rsp+0x20],rbx
    4355:	mov    QWORD PTR [rsp+0x28],r12
    435a:	mov    QWORD PTR [rsp+0x30],r13
    435f:	mov    r12,rdi
    4362:	mov    QWORD PTR [rsp+0x10],0x0
    436b:	mov    QWORD PTR [rsp],rdx
    436f:	mov    rbx,rsi
    4372:	mov    rsi,rdx
    4375:	mov    rax,QWORD PTR [rbx+0x20]
    4379:	mov    rdx,QWORD PTR [rax]
    437c:	mov    r10d,0x1
    4382:	test   rsi,0x1
    4389:	jne    43a9 <botlish_fn_26+0x61>
    438f:	xor    r10d,r10d
    4392:	test   rsi,0x7
    4399:	jne    43a9 <botlish_fn_26+0x61>
    439f:	movzx  rax,BYTE PTR [rsi]
    43a3:	cmp    al,0x1
    43a5:	sete   r10b
    43a9:	test   r10b,r10b
    43ac:	jne    43cd <botlish_fn_26+0x85>
    43b2:	mov    rdi,r12
    43b5:	mov    rax,QWORD PTR [rdi+0x10]
    43b9:	mov    rcx,QWORD PTR [rax+0xb8]
    43c0:	xor    rdx,rdx
    43c3:	call   43c8 <botlish_fn_26+0x80>
			43c4: R_X86_64_PLT32	rt_type_error-0x4
    43c8:	jmp    4459 <botlish_fn_26+0x111>
    43cd:	mov    rax,rsi
    43d0:	and    rax,rdx
    43d3:	mov    r13,rsi
    43d6:	test   rax,0x1
    43dc:	jne    4402 <botlish_fn_26+0xba>
    43e2:	mov    rsi,r13
    43e5:	mov    rdi,r12
    43e8:	call   43ed <botlish_fn_26+0xa5>
			43e9: R_X86_64_PLT32	rt_int_cmp-0x4
    43ed:	mov    ecx,0x2
    43f2:	test   rax,rax
    43f5:	cmovge rcx,QWORD PTR [rip+0x10b]        # 4508 <botlish_fn_26+0x1c0>
    43fd:	jmp    4415 <botlish_fn_26+0xcd>
    4402:	mov    ecx,0x2
    4407:	mov    rsi,r13
    440a:	cmp    rsi,rdx
    440d:	cmovge rcx,QWORD PTR [rip+0xf3]        # 4508 <botlish_fn_26+0x1c0>
    4415:	cmp    rcx,0x6
    4419:	je     44e6 <botlish_fn_26+0x19e>
    441f:	mov    rax,QWORD PTR [rbx+0x20]
    4423:	mov    rsi,QWORD PTR [rax+0x8]
    4427:	mov    QWORD PTR [rsp+0x8],rsi
    442c:	mov    rdx,r13
    442f:	mov    rdi,r12
    4432:	call   4437 <botlish_fn_26+0xef>
			4433: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    4437:	test   rax,rax
    443a:	je     4459 <botlish_fn_26+0x111>
    4440:	mov    QWORD PTR [rsp+0x8],rax
    4445:	mov    rsi,rax
    4448:	mov    rdi,r12
    444b:	call   4450 <botlish_fn_26+0x108>
			444c: R_X86_64_PLT32	botlish_fn_24-0x4 ; is_local_char<str>
    4450:	test   rax,rax
    4453:	jne    4474 <botlish_fn_26+0x12c>
    4459:	xor    rax,rax
    445c:	mov    rbx,QWORD PTR [rsp+0x20]
    4461:	mov    r12,QWORD PTR [rsp+0x28]
    4466:	mov    r13,QWORD PTR [rsp+0x30]
    446b:	add    rsp,0x40
    446f:	mov    rsp,rbp
    4472:	pop    rbp
    4473:	ret
    4474:	cmp    rax,0x6
    4478:	je     4486 <botlish_fn_26+0x13e>
    447e:	mov    rax,r13
    4481:	jmp    44e9 <botlish_fn_26+0x1a1>
    4486:	mov    QWORD PTR [rsp+0x8],rbx
    448b:	mov    QWORD PTR [rsp+0x10],0x3
    4494:	mov    rsi,r13
    4497:	test   rsi,0x1
    449e:	je     44c4 <botlish_fn_26+0x17c>
    44a4:	mov    rsi,r13
    44a7:	mov    rcx,rsi
    44aa:	add    rcx,0x2
    44ae:	seto   al
    44b1:	test   al,al
    44b3:	jne    44c4 <botlish_fn_26+0x17c>
    44b9:	mov    rsi,rcx
    44bc:	mov    r13,rcx
    44bf:	jmp    44da <botlish_fn_26+0x192>
    44c4:	mov    edx,0x3
    44c9:	mov    rsi,r13
    44cc:	mov    rdi,r12
    44cf:	call   44d4 <botlish_fn_26+0x18c>
			44d0: R_X86_64_PLT32	rt_int_add-0x4
    44d4:	mov    rsi,rax
    44d7:	mov    r13,rax
    44da:	mov    QWORD PTR [rsp],rsi
    44de:	mov    rsi,r13
    44e1:	jmp    4375 <botlish_fn_26+0x2d>
    44e6:	mov    rax,r13
    44e9:	mov    rbx,QWORD PTR [rsp+0x20]
    44ee:	mov    r12,QWORD PTR [rsp+0x28]
    44f3:	mov    r13,QWORD PTR [rsp+0x30]
    44f8:	add    rsp,0x40
    44fc:	mov    rsp,rbp
    44ff:	pop    rbp
    4500:	ret
    4501:	add    BYTE PTR [rax],al
    4503:	add    BYTE PTR [rax],al
    4505:	add    BYTE PTR [rax],al
    4507:	add    BYTE PTR [rsi],al
    4509:	add    BYTE PTR [rax],al
    450b:	add    BYTE PTR [rax],al
    450d:	add    BYTE PTR [rax],al
	...

0000000000004510 <botlish_entry_26: scan_local<generic>>:
    4510:	push   rbp
    4511:	mov    rbp,rsp
    4514:	mov    rdx,QWORD PTR [rdx]
    4517:	call   451c <botlish_entry_26+0xc>
			4518: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    451c:	mov    rsp,rbp
    451f:	pop    rbp
    4520:	ret
    4521:	add    BYTE PTR [rax],al
    4523:	add    BYTE PTR [rax],al
    4525:	add    BYTE PTR [rax],al
	...

0000000000004528 <botlish_fn_27: scan_label<generic>>:
    4528:	push   rbp
    4529:	mov    rbp,rsp
    452c:	sub    rsp,0x40
    4530:	mov    QWORD PTR [rsp+0x20],rbx
    4535:	mov    QWORD PTR [rsp+0x28],r12
    453a:	mov    QWORD PTR [rsp+0x30],r13
    453f:	mov    r12,rdi
    4542:	mov    QWORD PTR [rsp+0x10],0x0
    454b:	mov    QWORD PTR [rsp],rdx
    454f:	mov    rbx,rsi
    4552:	mov    rsi,rdx
    4555:	mov    rax,QWORD PTR [rbx+0x20]
    4559:	mov    rdx,QWORD PTR [rax]
    455c:	mov    r10d,0x1
    4562:	test   rsi,0x1
    4569:	jne    4589 <botlish_fn_27+0x61>
    456f:	xor    r10d,r10d
    4572:	test   rsi,0x7
    4579:	jne    4589 <botlish_fn_27+0x61>
    457f:	movzx  rax,BYTE PTR [rsi]
    4583:	cmp    al,0x1
    4585:	sete   r10b
    4589:	test   r10b,r10b
    458c:	jne    45ad <botlish_fn_27+0x85>
    4592:	mov    rdi,r12
    4595:	mov    rax,QWORD PTR [rdi+0x10]
    4599:	mov    rcx,QWORD PTR [rax+0xb8]
    45a0:	xor    rdx,rdx
    45a3:	call   45a8 <botlish_fn_27+0x80>
			45a4: R_X86_64_PLT32	rt_type_error-0x4
    45a8:	jmp    4639 <botlish_fn_27+0x111>
    45ad:	mov    rax,rsi
    45b0:	and    rax,rdx
    45b3:	mov    r13,rsi
    45b6:	test   rax,0x1
    45bc:	jne    45e2 <botlish_fn_27+0xba>
    45c2:	mov    rsi,r13
    45c5:	mov    rdi,r12
    45c8:	call   45cd <botlish_fn_27+0xa5>
			45c9: R_X86_64_PLT32	rt_int_cmp-0x4
    45cd:	mov    ecx,0x2
    45d2:	test   rax,rax
    45d5:	cmovge rcx,QWORD PTR [rip+0x10b]        # 46e8 <botlish_fn_27+0x1c0>
    45dd:	jmp    45f5 <botlish_fn_27+0xcd>
    45e2:	mov    ecx,0x2
    45e7:	mov    rsi,r13
    45ea:	cmp    rsi,rdx
    45ed:	cmovge rcx,QWORD PTR [rip+0xf3]        # 46e8 <botlish_fn_27+0x1c0>
    45f5:	cmp    rcx,0x6
    45f9:	je     46c6 <botlish_fn_27+0x19e>
    45ff:	mov    rax,QWORD PTR [rbx+0x20]
    4603:	mov    rsi,QWORD PTR [rax+0x8]
    4607:	mov    QWORD PTR [rsp+0x8],rsi
    460c:	mov    rdx,r13
    460f:	mov    rdi,r12
    4612:	call   4617 <botlish_fn_27+0xef>
			4613: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    4617:	test   rax,rax
    461a:	je     4639 <botlish_fn_27+0x111>
    4620:	mov    QWORD PTR [rsp+0x8],rax
    4625:	mov    rsi,rax
    4628:	mov    rdi,r12
    462b:	call   4630 <botlish_fn_27+0x108>
			462c: R_X86_64_PLT32	botlish_fn_25-0x4 ; is_label_char<str>
    4630:	test   rax,rax
    4633:	jne    4654 <botlish_fn_27+0x12c>
    4639:	xor    rax,rax
    463c:	mov    rbx,QWORD PTR [rsp+0x20]
    4641:	mov    r12,QWORD PTR [rsp+0x28]
    4646:	mov    r13,QWORD PTR [rsp+0x30]
    464b:	add    rsp,0x40
    464f:	mov    rsp,rbp
    4652:	pop    rbp
    4653:	ret
    4654:	cmp    rax,0x6
    4658:	je     4666 <botlish_fn_27+0x13e>
    465e:	mov    rax,r13
    4661:	jmp    46c9 <botlish_fn_27+0x1a1>
    4666:	mov    QWORD PTR [rsp+0x8],rbx
    466b:	mov    QWORD PTR [rsp+0x10],0x3
    4674:	mov    rsi,r13
    4677:	test   rsi,0x1
    467e:	je     46a4 <botlish_fn_27+0x17c>
    4684:	mov    rsi,r13
    4687:	mov    rcx,rsi
    468a:	add    rcx,0x2
    468e:	seto   al
    4691:	test   al,al
    4693:	jne    46a4 <botlish_fn_27+0x17c>
    4699:	mov    rsi,rcx
    469c:	mov    r13,rcx
    469f:	jmp    46ba <botlish_fn_27+0x192>
    46a4:	mov    edx,0x3
    46a9:	mov    rsi,r13
    46ac:	mov    rdi,r12
    46af:	call   46b4 <botlish_fn_27+0x18c>
			46b0: R_X86_64_PLT32	rt_int_add-0x4
    46b4:	mov    rsi,rax
    46b7:	mov    r13,rax
    46ba:	mov    QWORD PTR [rsp],rsi
    46be:	mov    rsi,r13
    46c1:	jmp    4555 <botlish_fn_27+0x2d>
    46c6:	mov    rax,r13
    46c9:	mov    rbx,QWORD PTR [rsp+0x20]
    46ce:	mov    r12,QWORD PTR [rsp+0x28]
    46d3:	mov    r13,QWORD PTR [rsp+0x30]
    46d8:	add    rsp,0x40
    46dc:	mov    rsp,rbp
    46df:	pop    rbp
    46e0:	ret
    46e1:	add    BYTE PTR [rax],al
    46e3:	add    BYTE PTR [rax],al
    46e5:	add    BYTE PTR [rax],al
    46e7:	add    BYTE PTR [rsi],al
    46e9:	add    BYTE PTR [rax],al
    46eb:	add    BYTE PTR [rax],al
    46ed:	add    BYTE PTR [rax],al
	...

00000000000046f0 <botlish_entry_27: scan_label<generic>>:
    46f0:	push   rbp
    46f1:	mov    rbp,rsp
    46f4:	mov    rdx,QWORD PTR [rdx]
    46f7:	call   46fc <botlish_entry_27+0xc>
			46f8: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_label<generic>
    46fc:	mov    rsp,rbp
    46ff:	pop    rbp
    4700:	ret
    4701:	add    BYTE PTR [rax],al
    4703:	add    BYTE PTR [rax],al
    4705:	add    BYTE PTR [rax],al
	...

0000000000004708 <botlish_fn_28: scan_alpha<generic>>:
    4708:	push   rbp
    4709:	mov    rbp,rsp
    470c:	sub    rsp,0x40
    4710:	mov    QWORD PTR [rsp+0x20],rbx
    4715:	mov    QWORD PTR [rsp+0x28],r12
    471a:	mov    QWORD PTR [rsp+0x30],r13
    471f:	mov    r12,rdi
    4722:	mov    QWORD PTR [rsp+0x10],0x0
    472b:	mov    QWORD PTR [rsp],rdx
    472f:	mov    rbx,rsi
    4732:	mov    rsi,rdx
    4735:	mov    rax,QWORD PTR [rbx+0x20]
    4739:	mov    rdx,QWORD PTR [rax]
    473c:	mov    r10d,0x1
    4742:	test   rsi,0x1
    4749:	jne    4769 <botlish_fn_28+0x61>
    474f:	xor    r10d,r10d
    4752:	test   rsi,0x7
    4759:	jne    4769 <botlish_fn_28+0x61>
    475f:	movzx  rax,BYTE PTR [rsi]
    4763:	cmp    al,0x1
    4765:	sete   r10b
    4769:	test   r10b,r10b
    476c:	jne    478d <botlish_fn_28+0x85>
    4772:	mov    rdi,r12
    4775:	mov    rax,QWORD PTR [rdi+0x10]
    4779:	mov    rcx,QWORD PTR [rax+0xb8]
    4780:	xor    rdx,rdx
    4783:	call   4788 <botlish_fn_28+0x80>
			4784: R_X86_64_PLT32	rt_type_error-0x4
    4788:	jmp    4814 <botlish_fn_28+0x10c>
    478d:	mov    rax,rsi
    4790:	and    rax,rdx
    4793:	mov    r13,rsi
    4796:	test   rax,0x1
    479c:	jne    47c2 <botlish_fn_28+0xba>
    47a2:	mov    rsi,r13
    47a5:	mov    rdi,r12
    47a8:	call   47ad <botlish_fn_28+0xa5>
			47a9: R_X86_64_PLT32	rt_int_cmp-0x4
    47ad:	mov    ecx,0x2
    47b2:	test   rax,rax
    47b5:	cmovge rcx,QWORD PTR [rip+0x103]        # 48c0 <botlish_fn_28+0x1b8>
    47bd:	jmp    47d5 <botlish_fn_28+0xcd>
    47c2:	mov    ecx,0x2
    47c7:	mov    rsi,r13
    47ca:	cmp    rsi,rdx
    47cd:	cmovge rcx,QWORD PTR [rip+0xeb]        # 48c0 <botlish_fn_28+0x1b8>
    47d5:	cmp    rcx,0x6
    47d9:	je     48a1 <botlish_fn_28+0x199>
    47df:	mov    rax,QWORD PTR [rbx+0x20]
    47e3:	mov    rsi,QWORD PTR [rax+0x8]
    47e7:	mov    QWORD PTR [rsp+0x8],rsi
    47ec:	mov    rdx,r13
    47ef:	mov    rdi,r12
    47f2:	call   47f7 <botlish_fn_28+0xef>
			47f3: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    47f7:	test   rax,rax
    47fa:	mov    rsi,rax
    47fd:	je     4814 <botlish_fn_28+0x10c>
    4803:	mov    rdi,r12
    4806:	call   480b <botlish_fn_28+0x103>
			4807: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    480b:	test   rax,rax
    480e:	jne    482f <botlish_fn_28+0x127>
    4814:	xor    rax,rax
    4817:	mov    rbx,QWORD PTR [rsp+0x20]
    481c:	mov    r12,QWORD PTR [rsp+0x28]
    4821:	mov    r13,QWORD PTR [rsp+0x30]
    4826:	add    rsp,0x40
    482a:	mov    rsp,rbp
    482d:	pop    rbp
    482e:	ret
    482f:	cmp    rax,0x6
    4833:	je     4841 <botlish_fn_28+0x139>
    4839:	mov    rax,r13
    483c:	jmp    48a4 <botlish_fn_28+0x19c>
    4841:	mov    QWORD PTR [rsp+0x8],rbx
    4846:	mov    QWORD PTR [rsp+0x10],0x3
    484f:	mov    rsi,r13
    4852:	test   rsi,0x1
    4859:	je     487f <botlish_fn_28+0x177>
    485f:	mov    rsi,r13
    4862:	mov    r11,rsi
    4865:	add    r11,0x2
    4869:	seto   al
    486c:	test   al,al
    486e:	jne    487f <botlish_fn_28+0x177>
    4874:	mov    rsi,r11
    4877:	mov    r13,r11
    487a:	jmp    4895 <botlish_fn_28+0x18d>
    487f:	mov    edx,0x3
    4884:	mov    rsi,r13
    4887:	mov    rdi,r12
    488a:	call   488f <botlish_fn_28+0x187>
			488b: R_X86_64_PLT32	rt_int_add-0x4
    488f:	mov    rsi,rax
    4892:	mov    r13,rax
    4895:	mov    QWORD PTR [rsp],rsi
    4899:	mov    rsi,r13
    489c:	jmp    4735 <botlish_fn_28+0x2d>
    48a1:	mov    rax,r13
    48a4:	mov    rbx,QWORD PTR [rsp+0x20]
    48a9:	mov    r12,QWORD PTR [rsp+0x28]
    48ae:	mov    r13,QWORD PTR [rsp+0x30]
    48b3:	add    rsp,0x40
    48b7:	mov    rsp,rbp
    48ba:	pop    rbp
    48bb:	ret
    48bc:	add    BYTE PTR [rax],al
    48be:	add    BYTE PTR [rax],al
    48c0:	(bad)
    48c1:	add    BYTE PTR [rax],al
    48c3:	add    BYTE PTR [rax],al
    48c5:	add    BYTE PTR [rax],al
	...

00000000000048c8 <botlish_entry_28: scan_alpha<generic>>:
    48c8:	push   rbp
    48c9:	mov    rbp,rsp
    48cc:	mov    rdx,QWORD PTR [rdx]
    48cf:	call   48d4 <botlish_entry_28+0xc>
			48d0: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_alpha<generic>
    48d4:	mov    rsp,rbp
    48d7:	pop    rbp
    48d8:	ret
    48d9:	add    BYTE PTR [rax],al
    48db:	add    BYTE PTR [rax],al
    48dd:	add    BYTE PTR [rax],al
	...

00000000000048e0 <botlish_fn_29: tld_ok<generic>>:
    48e0:	push   rbp
    48e1:	mov    rbp,rsp
    48e4:	sub    rsp,0x30
    48e8:	mov    QWORD PTR [rsp+0x10],rbx
    48ed:	mov    QWORD PTR [rsp+0x18],r12
    48f2:	mov    QWORD PTR [rsp+0x20],r13
    48f7:	mov    QWORD PTR [rsp+0x28],r14
    48fc:	mov    r12,rdi
    48ff:	mov    QWORD PTR [rsp],rdx
    4903:	mov    r9,rdx
    4906:	mov    rax,QWORD PTR [rsi+0x20]
    490a:	mov    r14,rsi
    490d:	mov    rsi,QWORD PTR [rax]
    4910:	mov    QWORD PTR [rsp+0x8],rsi
    4915:	mov    rbx,r9
    4918:	mov    rdx,rbx
    491b:	mov    rdi,r12
    491e:	call   4923 <botlish_fn_29+0x43>
			491f: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_alpha<generic>
    4923:	mov    rsi,rax
    4926:	mov    r13,rax
    4929:	test   rax,rsi
    492c:	je     4a04 <botlish_fn_29+0x124>
    4932:	mov    rax,r13
    4935:	mov    QWORD PTR [rsp+0x8],rax
    493a:	mov    rsi,r14
    493d:	mov    rax,QWORD PTR [rsi+0x20]
    4941:	mov    rdx,QWORD PTR [rax+0x8]
    4945:	mov    rax,r13
    4948:	and    rax,rdx
    494b:	test   rax,0x1
    4951:	jne    497a <botlish_fn_29+0x9a>
    4957:	mov    rsi,r13
    495a:	mov    rdi,r12
    495d:	call   4962 <botlish_fn_29+0x82>
			495e: R_X86_64_PLT32	rt_int_cmp-0x4
    4962:	mov    ecx,0x2
    4967:	test   rax,rax
    496a:	cmove  rcx,QWORD PTR [rip+0x166]        # 4ad8 <botlish_fn_29+0x1f8>
    4972:	mov    rax,r13
    4975:	jmp    498d <botlish_fn_29+0xad>
    497a:	mov    ecx,0x2
    497f:	mov    rax,r13
    4982:	cmp    rax,rdx
    4985:	cmove  rcx,QWORD PTR [rip+0x14b]        # 4ad8 <botlish_fn_29+0x1f8>
    498d:	cmp    rcx,0x6
    4991:	je     49a4 <botlish_fn_29+0xc4>
    4997:	mov    ecx,0x2
    499c:	mov    rax,rcx
    499f:	jmp    4ab4 <botlish_fn_29+0x1d4>
    49a4:	mov    ecx,0x1
    49a9:	test   rbx,0x1
    49b0:	je     49be <botlish_fn_29+0xde>
    49b6:	mov    r9,rbx
    49b9:	jmp    49e3 <botlish_fn_29+0x103>
    49be:	xor    ecx,ecx
    49c0:	test   rbx,0x7
    49c7:	je     49d5 <botlish_fn_29+0xf5>
    49cd:	mov    r9,rbx
    49d0:	jmp    49e3 <botlish_fn_29+0x103>
    49d5:	movzx  rdx,BYTE PTR [rbx]
    49d9:	mov    r9,rbx
    49dc:	rex cmp dl,0x1
    49e0:	sete   cl
    49e3:	test   cl,cl
    49e5:	jne    4a24 <botlish_fn_29+0x144>
    49eb:	mov    rdi,r12
    49ee:	mov    rsi,QWORD PTR [rdi+0x10]
    49f2:	mov    rcx,QWORD PTR [rsi+0x128]
    49f9:	xor    rdx,rdx
    49fc:	mov    rsi,r9
    49ff:	call   4a04 <botlish_fn_29+0x124>
			4a00: R_X86_64_PLT32	rt_type_error-0x4
    4a04:	xor    rax,rax
    4a07:	mov    rbx,QWORD PTR [rsp+0x10]
    4a0c:	mov    r12,QWORD PTR [rsp+0x18]
    4a11:	mov    r13,QWORD PTR [rsp+0x20]
    4a16:	mov    r14,QWORD PTR [rsp+0x28]
    4a1b:	add    rsp,0x30
    4a1f:	mov    rsp,rbp
    4a22:	pop    rbp
    4a23:	ret
    4a24:	mov    rbx,r9
    4a27:	mov    r8,rax
    4a2a:	and    r8,rbx
    4a2d:	test   r8,0x1
    4a34:	jne    4a45 <botlish_fn_29+0x165>
    4a3a:	mov    rdx,r9
    4a3d:	mov    rsi,rax
    4a40:	jmp    4a66 <botlish_fn_29+0x186>
    4a45:	mov    rbx,r9
    4a48:	mov    r10,rax
    4a4b:	sub    r10,rbx
    4a4e:	mov    r13,rax
    4a51:	seto   al
    4a54:	lea    rsi,[r10+0x1]
    4a58:	test   al,al
    4a5a:	je     4a71 <botlish_fn_29+0x191>
    4a60:	mov    rdx,r9
    4a63:	mov    rsi,r13
    4a66:	mov    rdi,r12
    4a69:	call   4a6e <botlish_fn_29+0x18e>
			4a6a: R_X86_64_PLT32	rt_int_sub-0x4
    4a6e:	mov    rsi,rax
    4a71:	test   rsi,0x1
    4a78:	jne    4aa3 <botlish_fn_29+0x1c3>
    4a7e:	mov    edx,0x5
    4a83:	mov    rdi,r12
    4a86:	call   4a8b <botlish_fn_29+0x1ab>
			4a87: R_X86_64_PLT32	rt_int_cmp-0x4
    4a8b:	mov    ecx,0x2
    4a90:	test   rax,rax
    4a93:	mov    rax,rcx
    4a96:	cmovge rax,QWORD PTR [rip+0x3a]        # 4ad8 <botlish_fn_29+0x1f8>
    4a9e:	jmp    4ab4 <botlish_fn_29+0x1d4>
    4aa3:	mov    eax,0x2
    4aa8:	cmp    rsi,0x5
    4aac:	cmovge rax,QWORD PTR [rip+0x24]        # 4ad8 <botlish_fn_29+0x1f8>
    4ab4:	mov    rbx,QWORD PTR [rsp+0x10]
    4ab9:	mov    r12,QWORD PTR [rsp+0x18]
    4abe:	mov    r13,QWORD PTR [rsp+0x20]
    4ac3:	mov    r14,QWORD PTR [rsp+0x28]
    4ac8:	add    rsp,0x30
    4acc:	mov    rsp,rbp
    4acf:	pop    rbp
    4ad0:	ret
    4ad1:	add    BYTE PTR [rax],al
    4ad3:	add    BYTE PTR [rax],al
    4ad5:	add    BYTE PTR [rax],al
    4ad7:	add    BYTE PTR [rsi],al
    4ad9:	add    BYTE PTR [rax],al
    4adb:	add    BYTE PTR [rax],al
    4add:	add    BYTE PTR [rax],al
	...

0000000000004ae0 <botlish_entry_29: tld_ok<generic>>:
    4ae0:	push   rbp
    4ae1:	mov    rbp,rsp
    4ae4:	mov    rdx,QWORD PTR [rdx]
    4ae7:	call   4aec <botlish_entry_29+0xc>
			4ae8: R_X86_64_PLT32	botlish_fn_29-0x4 ; tld_ok<generic>
    4aec:	mov    rsp,rbp
    4aef:	pop    rbp
    4af0:	ret
    4af1:	add    BYTE PTR [rax],al
    4af3:	add    BYTE PTR [rax],al
    4af5:	add    BYTE PTR [rax],al
	...

0000000000004af8 <botlish_fn_30: domain_loop<generic>>:
    4af8:	push   rbp
    4af9:	mov    rbp,rsp
    4afc:	sub    rsp,0x50
    4b00:	mov    QWORD PTR [rsp+0x20],rbx
    4b05:	mov    QWORD PTR [rsp+0x28],r12
    4b0a:	mov    QWORD PTR [rsp+0x30],r13
    4b0f:	mov    QWORD PTR [rsp+0x38],r14
    4b14:	mov    QWORD PTR [rsp+0x40],r15
    4b19:	mov    QWORD PTR [rsp],rdx
    4b1d:	mov    r15,rdx
    4b20:	lea    r13,[rsp+0x10]
    4b25:	mov    rbx,rsi
    4b28:	mov    rax,QWORD PTR [rbx+0x20]
    4b2c:	mov    rsi,QWORD PTR [rax]
    4b2f:	mov    QWORD PTR [rsp+0x8],rsi
    4b34:	mov    r12,rdi
    4b37:	mov    rdx,r15
    4b3a:	call   4b3f <botlish_fn_30+0x47>
			4b3b: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_label<generic>
    4b3f:	mov    r10,rax
    4b42:	mov    r14,rax
    4b45:	test   rax,r10
    4b48:	je     4cbe <botlish_fn_30+0x1c6>
    4b4e:	mov    rax,r14
    4b51:	mov    QWORD PTR [rsp],rax
    4b55:	mov    rdx,r15
    4b58:	and    rax,rdx
    4b5b:	test   rax,0x1
    4b61:	jne    4b83 <botlish_fn_30+0x8b>
    4b67:	mov    rdx,r15
    4b6a:	mov    rsi,r14
    4b6d:	mov    rdi,r12
    4b70:	call   4b75 <botlish_fn_30+0x7d>
			4b71: R_X86_64_PLT32	rt_value_eq-0x4
    4b75:	test   rax,rax
    4b78:	je     4cbe <botlish_fn_30+0x1c6>
    4b7e:	jmp    4b96 <botlish_fn_30+0x9e>
    4b83:	mov    eax,0x2
    4b88:	mov    rdx,r15
    4b8b:	cmp    r14,rdx
    4b8e:	cmove  rax,QWORD PTR [rip+0x1aa]        # 4d40 <botlish_fn_30+0x248>
    4b96:	cmp    rax,0x6
    4b9a:	je     4d15 <botlish_fn_30+0x21d>
    4ba0:	mov    rdx,QWORD PTR [rbx+0x20]
    4ba4:	mov    rdx,QWORD PTR [rdx+0x8]
    4ba8:	mov    rsi,r14
    4bab:	and    rsi,rdx
    4bae:	test   rsi,0x1
    4bb5:	jne    4bdb <botlish_fn_30+0xe3>
    4bbb:	mov    rsi,r14
    4bbe:	mov    rdi,r12
    4bc1:	call   4bc6 <botlish_fn_30+0xce>
			4bc2: R_X86_64_PLT32	rt_int_cmp-0x4
    4bc6:	mov    ecx,0x2
    4bcb:	test   rax,rax
    4bce:	cmovge rcx,QWORD PTR [rip+0x16a]        # 4d40 <botlish_fn_30+0x248>
    4bd6:	jmp    4beb <botlish_fn_30+0xf3>
    4bdb:	mov    ecx,0x2
    4be0:	cmp    r14,rdx
    4be3:	cmovge rcx,QWORD PTR [rip+0x155]        # 4d40 <botlish_fn_30+0x248>
    4beb:	cmp    rcx,0x6
    4bef:	je     4d09 <botlish_fn_30+0x211>
    4bf5:	mov    r10,QWORD PTR [rbx+0x20]
    4bf9:	mov    rsi,QWORD PTR [r10+0x10]
    4bfd:	mov    QWORD PTR [rsp+0x8],rsi
    4c02:	mov    rcx,r13
    4c05:	mov    rdx,r14
    4c08:	mov    rdi,r12
    4c0b:	call   4c10 <botlish_fn_30+0x118>
			4c0c: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    4c10:	test   rax,rax
    4c13:	mov    rsi,rax
    4c16:	je     4cbe <botlish_fn_30+0x1c6>
    4c1c:	mov    rdx,QWORD PTR [rsp+0x10]
    4c21:	mov    rcx,QWORD PTR [rsp+0x18]
    4c26:	mov    rax,QWORD PTR [r12+0x10]
    4c2b:	mov    r8,QWORD PTR [rax+0x118]
    4c32:	mov    rdi,r12
    4c35:	call   4c3a <botlish_fn_30+0x142>
			4c36: R_X86_64_PLT32	rt_str_region_eq-0x4
    4c3a:	cmp    rax,0x6
    4c3e:	je     4c50 <botlish_fn_30+0x158>
    4c44:	mov    rax,0xffffffffffffffff
    4c4b:	jmp    4d1c <botlish_fn_30+0x224>
    4c50:	mov    QWORD PTR [rsp+0x8],0x3
    4c59:	test   r14,0x1
    4c60:	je     4c83 <botlish_fn_30+0x18b>
    4c66:	mov    rdx,r14
    4c69:	add    rdx,0x2
    4c6d:	mov    r15,rdx
    4c70:	seto   al
    4c73:	test   al,al
    4c75:	jne    4c83 <botlish_fn_30+0x18b>
    4c7b:	mov    rdx,r15
    4c7e:	jmp    4c99 <botlish_fn_30+0x1a1>
    4c83:	mov    edx,0x3
    4c88:	mov    rsi,r14
    4c8b:	mov    rdi,r12
    4c8e:	call   4c93 <botlish_fn_30+0x19b>
			4c8f: R_X86_64_PLT32	rt_int_add-0x4
    4c93:	mov    rdx,rax
    4c96:	mov    r15,rax
    4c99:	mov    QWORD PTR [rsp],rdx
    4c9d:	mov    rax,QWORD PTR [rbx+0x20]
    4ca1:	mov    rsi,QWORD PTR [rax+0x18]
    4ca5:	mov    QWORD PTR [rsp+0x8],rsi
    4caa:	mov    rdx,r15
    4cad:	mov    rdi,r12
    4cb0:	call   4cb5 <botlish_fn_30+0x1bd>
			4cb1: R_X86_64_PLT32	botlish_fn_29-0x4 ; tld_ok<generic>
    4cb5:	test   rax,rax
    4cb8:	jne    4ce3 <botlish_fn_30+0x1eb>
    4cbe:	xor    rax,rax
    4cc1:	mov    rbx,QWORD PTR [rsp+0x20]
    4cc6:	mov    r12,QWORD PTR [rsp+0x28]
    4ccb:	mov    r13,QWORD PTR [rsp+0x30]
    4cd0:	mov    r14,QWORD PTR [rsp+0x38]
    4cd5:	mov    r15,QWORD PTR [rsp+0x40]
    4cda:	add    rsp,0x50
    4cde:	mov    rsp,rbp
    4ce1:	pop    rbp
    4ce2:	ret
    4ce3:	cmp    rax,0x6
    4ce7:	je     4cfc <botlish_fn_30+0x204>
    4ced:	mov    rdx,r15
    4cf0:	mov    QWORD PTR [rsp],rdx
    4cf4:	mov    rdi,r12
    4cf7:	jmp    4b28 <botlish_fn_30+0x30>
    4cfc:	mov    rax,QWORD PTR [rbx+0x20]
    4d00:	mov    rax,QWORD PTR [rax+0x8]
    4d04:	jmp    4d1c <botlish_fn_30+0x224>
    4d09:	mov    rax,0xffffffffffffffff
    4d10:	jmp    4d1c <botlish_fn_30+0x224>
    4d15:	mov    rax,0xffffffffffffffff
    4d1c:	mov    rbx,QWORD PTR [rsp+0x20]
    4d21:	mov    r12,QWORD PTR [rsp+0x28]
    4d26:	mov    r13,QWORD PTR [rsp+0x30]
    4d2b:	mov    r14,QWORD PTR [rsp+0x38]
    4d30:	mov    r15,QWORD PTR [rsp+0x40]
    4d35:	add    rsp,0x50
    4d39:	mov    rsp,rbp
    4d3c:	pop    rbp
    4d3d:	ret
    4d3e:	add    BYTE PTR [rax],al
    4d40:	(bad)
    4d41:	add    BYTE PTR [rax],al
    4d43:	add    BYTE PTR [rax],al
    4d45:	add    BYTE PTR [rax],al
	...

0000000000004d48 <botlish_entry_30: domain_loop<generic>>:
    4d48:	push   rbp
    4d49:	mov    rbp,rsp
    4d4c:	mov    rdx,QWORD PTR [rdx]
    4d4f:	call   4d54 <botlish_entry_30+0xc>
			4d50: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    4d54:	mov    rsp,rbp
    4d57:	pop    rbp
    4d58:	ret

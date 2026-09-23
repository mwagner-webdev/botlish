; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 16411  (per function: 937 203 40 112 96 1425 484 864 506 952 504 681 769 450 884 644 540 540 636 681 769 450 884 644 540 540 636)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> byte::high_nibble<generic>
;   botlish_fn_2 / botlish_entry_2 -> byte::nibble<int>
;   botlish_fn_3 / botlish_entry_3 -> web::uri_escape_text<generic>
;   botlish_fn_4 / botlish_entry_4 -> high_nibble<generic>
;   botlish_fn_5 / botlish_entry_5 -> is_unreserved<generic>
;   botlish_fn_6 / botlish_entry_6 -> hex_pair<generic>
;   botlish_fn_7 / botlish_entry_7 -> esc_bytes<generic>
;   botlish_fn_8 / botlish_entry_8 -> esc_char<generic>
;   botlish_fn_9 / botlish_entry_9 -> esc_from<generic>
;   botlish_fn_10 / botlish_entry_10 -> check<int, int, str, str>
;   botlish_fn_11 / botlish_entry_11 -> <str>
;   botlish_fn_12 / botlish_entry_12 -> <generic>
;   botlish_fn_13 / botlish_entry_13 -> char_at<generic>
;   botlish_fn_14 / botlish_entry_14 -> scan_local<generic>
;   botlish_fn_15 / botlish_entry_15 -> scan_label<generic>
;   botlish_fn_16 / botlish_entry_16 -> scan_alpha<generic>
;   botlish_fn_17 / botlish_entry_17 -> tld_ok<generic>
;   botlish_fn_18 / botlish_entry_18 -> domain_loop<generic>
;   botlish_fn_19 / botlish_entry_19 -> <str>
;   botlish_fn_20 / botlish_entry_20 -> <generic>
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
      85:	mov    rcx,QWORD PTR [rdi+0x10]
      89:	mov    r8,QWORD PTR [rcx+0x20]
      8d:	mov    QWORD PTR [rsp+0x20],r8
      92:	mov    rdx,QWORD PTR [rdi+0x10]
      96:	mov    r9,QWORD PTR [rdx+0x28]
      9a:	mov    QWORD PTR [rsp+0x28],r9
      9f:	mov    r10,QWORD PTR [rdi+0x10]
      a3:	mov    r10,QWORD PTR [r10+0x30]
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
     1e6:	je     31b <botlish_fn_0+0x31b>
     1ec:	mov    QWORD PTR [rsp],rax
     1f0:	lea    r8,[rsp+0x100]
     1f8:	mov    QWORD PTR [rsp+0x100],rax
     200:	mov    esi,0x3
     205:	mov    rdx,QWORD PTR [rip+0x0]        # 20c <botlish_fn_0+0x20c>
			208: R_X86_64_GOTPCREL	botlish_entry_3-0x4 ; web::uri_escape_text<generic>
     20c:	mov    ecx,0x1
     211:	mov    rdi,QWORD PTR [rsp+0x118]
     219:	call   21e <botlish_fn_0+0x21e>
			21a: R_X86_64_PLT32	rt_closure_new-0x4
     21e:	mov    QWORD PTR [rsp],rax
     222:	mov    rdi,QWORD PTR [rsp+0x118]
     22a:	mov    rcx,QWORD PTR [rdi+0x10]
     22e:	mov    rdx,QWORD PTR [rcx+0x80]
     235:	mov    QWORD PTR [rsp+0x8],rdx
     23a:	mov    rsi,rax
     23d:	call   242 <botlish_fn_0+0x242>
			23e: R_X86_64_PLT32	botlish_fn_3-0x4 ; web::uri_escape_text<generic>
     242:	test   rax,rax
     245:	je     31b <botlish_fn_0+0x31b>
     24b:	mov    QWORD PTR [rsp],rax
     24f:	mov    r12,rax
     252:	mov    esi,0x321
     257:	mov    QWORD PTR [rsp+0x8],0x321
     260:	mov    edx,0x1
     265:	mov    QWORD PTR [rsp+0x10],0x1
     26e:	mov    rdi,QWORD PTR [rsp+0x118]
     276:	mov    rcx,QWORD PTR [rdi+0x10]
     27a:	mov    rcx,QWORD PTR [rcx+0x88]
     281:	mov    QWORD PTR [rsp+0x18],rcx
     286:	mov    r8,r12
     289:	call   28e <botlish_fn_0+0x28e>
			28a: R_X86_64_PLT32	botlish_fn_10-0x4 ; check<int, int, str, str>
     28e:	mov    rbx,rax
     291:	test   rbx,rbx
     294:	je     31b <botlish_fn_0+0x31b>
     29a:	mov    QWORD PTR [rsp+0x8],rbx
     29f:	mov    esi,0x321
     2a4:	mov    QWORD PTR [rsp+0x10],0x321
     2ad:	mov    edx,0x1
     2b2:	mov    QWORD PTR [rsp+0x18],0x1
     2bb:	mov    rdi,QWORD PTR [rsp+0x118]
     2c3:	mov    rax,QWORD PTR [rdi+0x10]
     2c7:	mov    rcx,QWORD PTR [rax+0x90]
     2ce:	mov    QWORD PTR [rsp+0x20],rcx
     2d3:	mov    r8,r12
     2d6:	call   2db <botlish_fn_0+0x2db>
			2d7: R_X86_64_PLT32	botlish_fn_10-0x4 ; check<int, int, str, str>
     2db:	test   rax,rax
     2de:	je     31b <botlish_fn_0+0x31b>
     2e4:	mov    QWORD PTR [rsp],rax
     2e8:	lea    rdx,[rsp+0x108]
     2f0:	mov    QWORD PTR [rsp+0x108],rbx
     2f8:	mov    QWORD PTR [rsp+0x110],rax
     300:	mov    esi,0x2
     305:	mov    rdi,QWORD PTR [rsp+0x118]
     30d:	call   312 <botlish_fn_0+0x312>
			30e: R_X86_64_PLT32	rt_list_new-0x4
     312:	test   rax,rax
     315:	jne    352 <botlish_fn_0+0x352>
     31b:	xor    rax,rax
     31e:	mov    rbx,QWORD PTR [rsp+0x140]
     326:	mov    r12,QWORD PTR [rsp+0x148]
     32e:	mov    r13,QWORD PTR [rsp+0x150]
     336:	mov    r14,QWORD PTR [rsp+0x158]
     33e:	mov    r15,QWORD PTR [rsp+0x160]
     346:	add    rsp,0x170
     34d:	mov    rsp,rbp
     350:	pop    rbp
     351:	ret
     352:	mov    rbx,QWORD PTR [rsp+0x140]
     35a:	mov    r12,QWORD PTR [rsp+0x148]
     362:	mov    r13,QWORD PTR [rsp+0x150]
     36a:	mov    r14,QWORD PTR [rsp+0x158]
     372:	mov    r15,QWORD PTR [rsp+0x160]
     37a:	add    rsp,0x170
     381:	mov    rsp,rbp
     384:	pop    rbp
     385:	ret

0000000000000386 <botlish_entry_0: <program entry>>:
     386:	push   rbp
     387:	mov    rbp,rsp
     38a:	call   38f <botlish_entry_0+0x9>
			38b: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     38f:	mov    rsp,rbp
     392:	pop    rbp
     393:	ret

0000000000000394 <botlish_fn_1: byte::high_nibble<generic>>:
     394:	push   rbp
     395:	mov    rbp,rsp
     398:	sub    rsp,0x20
     39c:	mov    QWORD PTR [rsp+0x10],rbx
     3a1:	mov    QWORD PTR [rsp],rsi
     3a5:	mov    QWORD PTR [rsp+0x8],0x1e1
     3ae:	mov    r8d,0x1
     3b4:	test   rsi,0x1
     3bb:	jne    3db <botlish_fn_1+0x47>
     3c1:	xor    r8d,r8d
     3c4:	test   rsi,0x7
     3cb:	jne    3db <botlish_fn_1+0x47>
     3d1:	movzx  rax,BYTE PTR [rsi]
     3d5:	cmp    al,0x1
     3d7:	sete   r8b
     3db:	test   r8b,r8b
     3de:	jne    40b <botlish_fn_1+0x77>
     3e4:	mov    rax,QWORD PTR [rdi+0x10]
     3e8:	mov    rcx,QWORD PTR [rax+0x98]
     3ef:	xor    rbx,rbx
     3f2:	mov    rdx,rbx
     3f5:	call   3fa <botlish_fn_1+0x66>
			3f6: R_X86_64_PLT32	rt_type_error-0x4
     3fa:	mov    rax,rbx
     3fd:	mov    rbx,QWORD PTR [rsp+0x10]
     402:	add    rsp,0x20
     406:	mov    rsp,rbp
     409:	pop    rbp
     40a:	ret
     40b:	test   rsi,0x1
     412:	jne    427 <botlish_fn_1+0x93>
     418:	mov    edx,0x1e1
     41d:	call   422 <botlish_fn_1+0x8e>
			41e: R_X86_64_PLT32	rt_int_and-0x4
     422:	jmp    431 <botlish_fn_1+0x9d>
     427:	and    rsi,0x1e1
     42e:	mov    rax,rsi
     431:	mov    rbx,QWORD PTR [rsp+0x10]
     436:	add    rsp,0x20
     43a:	mov    rsp,rbp
     43d:	pop    rbp
     43e:	ret

000000000000043f <botlish_entry_1: byte::high_nibble<generic>>:
     43f:	push   rbp
     440:	mov    rbp,rsp
     443:	mov    rsi,QWORD PTR [rdx]
     446:	call   44b <botlish_entry_1+0xc>
			447: R_X86_64_PLT32	botlish_fn_1-0x4 ; byte::high_nibble<generic>
     44b:	mov    rsp,rbp
     44e:	pop    rbp
     44f:	ret

0000000000000450 <botlish_fn_2: byte::nibble<int>>:
     450:	push   rbp
     451:	mov    rbp,rsp
     454:	sar    rsi,0x5
     458:	shl    rsi,1
     45b:	mov    rax,rsi
     45e:	or     rax,0x1
     462:	mov    rsp,rbp
     465:	pop    rbp
     466:	ret

0000000000000467 <botlish_entry_2: byte::nibble<int>>:
     467:	push   rbp
     468:	mov    rbp,rsp
     46b:	mov    rsi,QWORD PTR [rdx]
     46e:	call   473 <botlish_entry_2+0xc>
			46f: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::nibble<int>
     473:	mov    rsp,rbp
     476:	pop    rbp
     477:	ret

0000000000000478 <botlish_fn_3: web::uri_escape_text<generic>>:
     478:	push   rbp
     479:	mov    rbp,rsp
     47c:	sub    rsp,0x20
     480:	mov    QWORD PTR [rsp],rdx
     484:	mov    r9,rdx
     487:	mov    edx,0x1
     48c:	mov    QWORD PTR [rsp+0x8],0x1
     495:	mov    rax,QWORD PTR [rdi+0x10]
     499:	mov    rcx,QWORD PTR [rax+0xa0]
     4a0:	mov    QWORD PTR [rsp+0x10],rcx
     4a5:	mov    rax,QWORD PTR [rsi+0x20]
     4a9:	mov    r8,QWORD PTR [rax]
     4ac:	mov    QWORD PTR [rsp+0x18],r8
     4b1:	mov    rsi,r9
     4b4:	call   4b9 <botlish_fn_3+0x41>
			4b5: R_X86_64_PLT32	botlish_fn_9-0x4 ; esc_from<generic>
     4b9:	test   rax,rax
     4bc:	jne    4ce <botlish_fn_3+0x56>
     4c2:	xor    rax,rax
     4c5:	add    rsp,0x20
     4c9:	mov    rsp,rbp
     4cc:	pop    rbp
     4cd:	ret
     4ce:	add    rsp,0x20
     4d2:	mov    rsp,rbp
     4d5:	pop    rbp
     4d6:	ret

00000000000004d7 <botlish_entry_3: web::uri_escape_text<generic>>:
     4d7:	push   rbp
     4d8:	mov    rbp,rsp
     4db:	mov    rdx,QWORD PTR [rdx]
     4de:	call   4e3 <botlish_entry_3+0xc>
			4df: R_X86_64_PLT32	botlish_fn_3-0x4 ; web::uri_escape_text<generic>
     4e3:	mov    rsp,rbp
     4e6:	pop    rbp
     4e7:	ret

00000000000004e8 <botlish_fn_4: high_nibble<generic>>:
     4e8:	push   rbp
     4e9:	mov    rbp,rsp
     4ec:	sub    rsp,0x20
     4f0:	mov    QWORD PTR [rsp+0x10],r12
     4f5:	mov    r12,rdi
     4f8:	mov    QWORD PTR [rsp],rsi
     4fc:	mov    rdi,r12
     4ff:	call   504 <botlish_fn_4+0x1c>
			500: R_X86_64_PLT32	botlish_fn_1-0x4 ; byte::high_nibble<generic>
     504:	test   rax,rax
     507:	mov    rsi,rax
     50a:	jne    521 <botlish_fn_4+0x39>
     510:	xor    rax,rax
     513:	mov    r12,QWORD PTR [rsp+0x10]
     518:	add    rsp,0x20
     51c:	mov    rsp,rbp
     51f:	pop    rbp
     520:	ret
     521:	mov    rdi,r12
     524:	call   529 <botlish_fn_4+0x41>
			525: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::nibble<int>
     529:	mov    r12,QWORD PTR [rsp+0x10]
     52e:	add    rsp,0x20
     532:	mov    rsp,rbp
     535:	pop    rbp
     536:	ret

0000000000000537 <botlish_entry_4: high_nibble<generic>>:
     537:	push   rbp
     538:	mov    rbp,rsp
     53b:	mov    rsi,QWORD PTR [rdx]
     53e:	call   543 <botlish_entry_4+0xc>
			53f: R_X86_64_PLT32	botlish_fn_4-0x4 ; high_nibble<generic>
     543:	mov    rsp,rbp
     546:	pop    rbp
     547:	ret

0000000000000548 <botlish_fn_5: is_unreserved<generic>>:
     548:	push   rbp
     549:	mov    rbp,rsp
     54c:	sub    rsp,0x20
     550:	mov    QWORD PTR [rsp],rbx
     554:	mov    QWORD PTR [rsp+0x8],r12
     559:	mov    QWORD PTR [rsp+0x10],r13
     55e:	mov    r8d,0x1
     564:	test   rsi,0x1
     56b:	jne    58b <botlish_fn_5+0x43>
     571:	xor    r8d,r8d
     574:	test   rsi,0x7
     57b:	jne    58b <botlish_fn_5+0x43>
     581:	movzx  rax,BYTE PTR [rsi]
     585:	cmp    al,0x1
     587:	sete   r8b
     58b:	test   r8b,r8b
     58e:	jne    5c4 <botlish_fn_5+0x7c>
     594:	mov    rdx,QWORD PTR [rdi+0x10]
     598:	mov    rcx,QWORD PTR [rdx+0xa8]
     59f:	xor    rbx,rbx
     5a2:	mov    rdx,rbx
     5a5:	call   5aa <botlish_fn_5+0x62>
			5a6: R_X86_64_PLT32	rt_type_error-0x4
     5aa:	mov    rax,rbx
     5ad:	mov    rbx,QWORD PTR [rsp]
     5b1:	mov    r12,QWORD PTR [rsp+0x8]
     5b6:	mov    r13,QWORD PTR [rsp+0x10]
     5bb:	add    rsp,0x20
     5bf:	mov    rsp,rbp
     5c2:	pop    rbp
     5c3:	ret
     5c4:	mov    r12,rdi
     5c7:	test   rsi,0x1
     5ce:	mov    rbx,rsi
     5d1:	jne    5fc <botlish_fn_5+0xb4>
     5d7:	mov    edx,0x59
     5dc:	mov    rsi,rbx
     5df:	mov    rdi,r12
     5e2:	call   5e7 <botlish_fn_5+0x9f>
			5e3: R_X86_64_PLT32	rt_int_cmp-0x4
     5e7:	mov    ecx,0x2
     5ec:	test   rax,rax
     5ef:	cmovle rcx,QWORD PTR [rip+0x461]        # a58 <botlish_fn_5+0x510>
     5f7:	jmp    610 <botlish_fn_5+0xc8>
     5fc:	mov    ecx,0x2
     601:	mov    rsi,rbx
     604:	cmp    rsi,0x59
     608:	cmovle rcx,QWORD PTR [rip+0x448]        # a58 <botlish_fn_5+0x510>
     610:	mov    eax,0x6
     615:	mov    r13,rax
     618:	cmp    rcx,0x6
     61c:	je     a3b <botlish_fn_5+0x4f3>
     622:	mov    rsi,rbx
     625:	test   rsi,0x1
     62c:	jne    657 <botlish_fn_5+0x10f>
     632:	mov    edx,0x5d
     637:	mov    rsi,rbx
     63a:	mov    rdi,r12
     63d:	call   642 <botlish_fn_5+0xfa>
			63e: R_X86_64_PLT32	rt_int_cmp-0x4
     642:	mov    ecx,0x2
     647:	test   rax,rax
     64a:	cmovle rcx,QWORD PTR [rip+0x406]        # a58 <botlish_fn_5+0x510>
     652:	jmp    66b <botlish_fn_5+0x123>
     657:	mov    ecx,0x2
     65c:	mov    rsi,rbx
     65f:	cmp    rsi,0x5d
     663:	cmovle rcx,QWORD PTR [rip+0x3ed]        # a58 <botlish_fn_5+0x510>
     66b:	cmp    rcx,0x6
     66f:	je     a33 <botlish_fn_5+0x4eb>
     675:	mov    rsi,rbx
     678:	test   rsi,0x1
     67f:	jne    6aa <botlish_fn_5+0x162>
     685:	mov    edx,0x5f
     68a:	mov    rsi,rbx
     68d:	mov    rdi,r12
     690:	call   695 <botlish_fn_5+0x14d>
			691: R_X86_64_PLT32	rt_int_cmp-0x4
     695:	mov    ecx,0x2
     69a:	test   rax,rax
     69d:	cmovle rcx,QWORD PTR [rip+0x3b3]        # a58 <botlish_fn_5+0x510>
     6a5:	jmp    6be <botlish_fn_5+0x176>
     6aa:	mov    ecx,0x2
     6af:	mov    rsi,rbx
     6b2:	cmp    rsi,0x5f
     6b6:	cmovle rcx,QWORD PTR [rip+0x39a]        # a58 <botlish_fn_5+0x510>
     6be:	cmp    rcx,0x6
     6c2:	je     a29 <botlish_fn_5+0x4e1>
     6c8:	mov    rsi,rbx
     6cb:	test   rsi,0x1
     6d2:	jne    6fd <botlish_fn_5+0x1b5>
     6d8:	mov    edx,0x73
     6dd:	mov    rsi,rbx
     6e0:	mov    rdi,r12
     6e3:	call   6e8 <botlish_fn_5+0x1a0>
			6e4: R_X86_64_PLT32	rt_int_cmp-0x4
     6e8:	mov    ecx,0x2
     6ed:	test   rax,rax
     6f0:	cmovle rcx,QWORD PTR [rip+0x360]        # a58 <botlish_fn_5+0x510>
     6f8:	jmp    711 <botlish_fn_5+0x1c9>
     6fd:	mov    ecx,0x2
     702:	mov    rsi,rbx
     705:	cmp    rsi,0x73
     709:	cmovle rcx,QWORD PTR [rip+0x347]        # a58 <botlish_fn_5+0x510>
     711:	cmp    rcx,0x6
     715:	je     a21 <botlish_fn_5+0x4d9>
     71b:	mov    rsi,rbx
     71e:	test   rsi,0x1
     725:	jne    750 <botlish_fn_5+0x208>
     72b:	mov    edx,0x81
     730:	mov    rsi,rbx
     733:	mov    rdi,r12
     736:	call   73b <botlish_fn_5+0x1f3>
			737: R_X86_64_PLT32	rt_int_cmp-0x4
     73b:	mov    ecx,0x2
     740:	test   rax,rax
     743:	cmovle rcx,QWORD PTR [rip+0x30d]        # a58 <botlish_fn_5+0x510>
     74b:	jmp    767 <botlish_fn_5+0x21f>
     750:	mov    ecx,0x2
     755:	mov    rsi,rbx
     758:	cmp    rsi,0x81
     75f:	cmovle rcx,QWORD PTR [rip+0x2f1]        # a58 <botlish_fn_5+0x510>
     767:	cmp    rcx,0x6
     76b:	je     a17 <botlish_fn_5+0x4cf>
     771:	mov    rsi,rbx
     774:	test   rsi,0x1
     77b:	jne    7a6 <botlish_fn_5+0x25e>
     781:	mov    edx,0xb5
     786:	mov    rsi,rbx
     789:	mov    rdi,r12
     78c:	call   791 <botlish_fn_5+0x249>
			78d: R_X86_64_PLT32	rt_int_cmp-0x4
     791:	mov    ecx,0x2
     796:	test   rax,rax
     799:	cmovle rcx,QWORD PTR [rip+0x2b7]        # a58 <botlish_fn_5+0x510>
     7a1:	jmp    7bd <botlish_fn_5+0x275>
     7a6:	mov    ecx,0x2
     7ab:	mov    rsi,rbx
     7ae:	cmp    rsi,0xb5
     7b5:	cmovle rcx,QWORD PTR [rip+0x29b]        # a58 <botlish_fn_5+0x510>
     7bd:	cmp    rcx,0x6
     7c1:	je     a0f <botlish_fn_5+0x4c7>
     7c7:	mov    rsi,rbx
     7ca:	test   rsi,0x1
     7d1:	jne    7fc <botlish_fn_5+0x2b4>
     7d7:	mov    edx,0xbd
     7dc:	mov    rsi,rbx
     7df:	mov    rdi,r12
     7e2:	call   7e7 <botlish_fn_5+0x29f>
			7e3: R_X86_64_PLT32	rt_int_cmp-0x4
     7e7:	mov    ecx,0x2
     7ec:	test   rax,rax
     7ef:	cmovle rcx,QWORD PTR [rip+0x261]        # a58 <botlish_fn_5+0x510>
     7f7:	jmp    813 <botlish_fn_5+0x2cb>
     7fc:	mov    ecx,0x2
     801:	mov    rsi,rbx
     804:	cmp    rsi,0xbd
     80b:	cmovle rcx,QWORD PTR [rip+0x245]        # a58 <botlish_fn_5+0x510>
     813:	cmp    rcx,0x6
     817:	je     a05 <botlish_fn_5+0x4bd>
     81d:	mov    rsi,rbx
     820:	test   rsi,0x1
     827:	jne    853 <botlish_fn_5+0x30b>
     82d:	mov    edx,0xbf
     832:	mov    rsi,rbx
     835:	mov    rdi,r12
     838:	call   83d <botlish_fn_5+0x2f5>
			839: R_X86_64_PLT32	rt_int_cmp-0x4
     83d:	mov    r11d,0x2
     843:	test   rax,rax
     846:	cmovle r11,QWORD PTR [rip+0x20a]        # a58 <botlish_fn_5+0x510>
     84e:	jmp    86b <botlish_fn_5+0x323>
     853:	mov    r11d,0x2
     859:	mov    rsi,rbx
     85c:	cmp    rsi,0xbf
     863:	cmovle r11,QWORD PTR [rip+0x1ed]        # a58 <botlish_fn_5+0x510>
     86b:	cmp    r11,0x6
     86f:	je     9fd <botlish_fn_5+0x4b5>
     875:	mov    rsi,rbx
     878:	test   rsi,0x1
     87f:	jne    8aa <botlish_fn_5+0x362>
     885:	mov    edx,0xc1
     88a:	mov    rsi,rbx
     88d:	mov    rdi,r12
     890:	call   895 <botlish_fn_5+0x34d>
			891: R_X86_64_PLT32	rt_int_cmp-0x4
     895:	mov    ecx,0x2
     89a:	test   rax,rax
     89d:	cmovle rcx,QWORD PTR [rip+0x1b3]        # a58 <botlish_fn_5+0x510>
     8a5:	jmp    8c1 <botlish_fn_5+0x379>
     8aa:	mov    ecx,0x2
     8af:	mov    rsi,rbx
     8b2:	cmp    rsi,0xc1
     8b9:	cmovle rcx,QWORD PTR [rip+0x197]        # a58 <botlish_fn_5+0x510>
     8c1:	cmp    rcx,0x6
     8c5:	je     9f3 <botlish_fn_5+0x4ab>
     8cb:	mov    rsi,rbx
     8ce:	test   rsi,0x1
     8d5:	jne    900 <botlish_fn_5+0x3b8>
     8db:	mov    edx,0xf5
     8e0:	mov    rsi,rbx
     8e3:	mov    rdi,r12
     8e6:	call   8eb <botlish_fn_5+0x3a3>
			8e7: R_X86_64_PLT32	rt_int_cmp-0x4
     8eb:	mov    ecx,0x2
     8f0:	test   rax,rax
     8f3:	cmovle rcx,QWORD PTR [rip+0x15d]        # a58 <botlish_fn_5+0x510>
     8fb:	jmp    917 <botlish_fn_5+0x3cf>
     900:	mov    ecx,0x2
     905:	mov    rsi,rbx
     908:	cmp    rsi,0xf5
     90f:	cmovle rcx,QWORD PTR [rip+0x141]        # a58 <botlish_fn_5+0x510>
     917:	cmp    rcx,0x6
     91b:	je     9eb <botlish_fn_5+0x4a3>
     921:	mov    rsi,rbx
     924:	test   rsi,0x1
     92b:	jne    956 <botlish_fn_5+0x40e>
     931:	mov    edx,0xfb
     936:	mov    rsi,rbx
     939:	mov    rdi,r12
     93c:	call   941 <botlish_fn_5+0x3f9>
			93d: R_X86_64_PLT32	rt_int_cmp-0x4
     941:	mov    ecx,0x2
     946:	test   rax,rax
     949:	cmovle rcx,QWORD PTR [rip+0x107]        # a58 <botlish_fn_5+0x510>
     951:	jmp    96d <botlish_fn_5+0x425>
     956:	mov    ecx,0x2
     95b:	mov    rsi,rbx
     95e:	cmp    rsi,0xfb
     965:	cmovle rcx,QWORD PTR [rip+0xeb]        # a58 <botlish_fn_5+0x510>
     96d:	cmp    rcx,0x6
     971:	je     9e1 <botlish_fn_5+0x499>
     977:	mov    rsi,rbx
     97a:	test   rsi,0x1
     981:	jne    9ad <botlish_fn_5+0x465>
     987:	mov    edx,0xfd
     98c:	mov    rsi,rbx
     98f:	mov    rdi,r12
     992:	call   997 <botlish_fn_5+0x44f>
			993: R_X86_64_PLT32	rt_int_cmp-0x4
     997:	mov    r8d,0x2
     99d:	test   rax,rax
     9a0:	cmovle r8,QWORD PTR [rip+0xb0]        # a58 <botlish_fn_5+0x510>
     9a8:	jmp    9c5 <botlish_fn_5+0x47d>
     9ad:	mov    r8d,0x2
     9b3:	mov    rsi,rbx
     9b6:	cmp    rsi,0xfd
     9bd:	cmovle r8,QWORD PTR [rip+0x93]        # a58 <botlish_fn_5+0x510>
     9c5:	cmp    r8,0x6
     9c9:	je     9d9 <botlish_fn_5+0x491>
     9cf:	mov    eax,0x2
     9d4:	jmp    a40 <botlish_fn_5+0x4f8>
     9d9:	mov    rax,r13
     9dc:	jmp    a40 <botlish_fn_5+0x4f8>
     9e1:	mov    eax,0x2
     9e6:	jmp    a40 <botlish_fn_5+0x4f8>
     9eb:	mov    rax,r13
     9ee:	jmp    a40 <botlish_fn_5+0x4f8>
     9f3:	mov    eax,0x2
     9f8:	jmp    a40 <botlish_fn_5+0x4f8>
     9fd:	mov    rax,r13
     a00:	jmp    a40 <botlish_fn_5+0x4f8>
     a05:	mov    eax,0x2
     a0a:	jmp    a40 <botlish_fn_5+0x4f8>
     a0f:	mov    rax,r13
     a12:	jmp    a40 <botlish_fn_5+0x4f8>
     a17:	mov    eax,0x2
     a1c:	jmp    a40 <botlish_fn_5+0x4f8>
     a21:	mov    rax,r13
     a24:	jmp    a40 <botlish_fn_5+0x4f8>
     a29:	mov    eax,0x2
     a2e:	jmp    a40 <botlish_fn_5+0x4f8>
     a33:	mov    rax,r13
     a36:	jmp    a40 <botlish_fn_5+0x4f8>
     a3b:	mov    eax,0x2
     a40:	mov    rbx,QWORD PTR [rsp]
     a44:	mov    r12,QWORD PTR [rsp+0x8]
     a49:	mov    r13,QWORD PTR [rsp+0x10]
     a4e:	add    rsp,0x20
     a52:	mov    rsp,rbp
     a55:	pop    rbp
     a56:	ret
     a57:	add    BYTE PTR [rsi],al
     a59:	add    BYTE PTR [rax],al
     a5b:	add    BYTE PTR [rax],al
     a5d:	add    BYTE PTR [rax],al
	...

0000000000000a60 <botlish_entry_5: is_unreserved<generic>>:
     a60:	push   rbp
     a61:	mov    rbp,rsp
     a64:	mov    rsi,QWORD PTR [rdx]
     a67:	call   a6c <botlish_entry_5+0xc>
			a68: R_X86_64_PLT32	botlish_fn_5-0x4 ; is_unreserved<generic>
     a6c:	mov    rsp,rbp
     a6f:	pop    rbp
     a70:	ret

0000000000000a71 <botlish_fn_6: hex_pair<generic>>:
     a71:	push   rbp
     a72:	mov    rbp,rsp
     a75:	sub    rsp,0x30
     a79:	mov    QWORD PTR [rsp+0x10],rbx
     a7e:	mov    QWORD PTR [rsp+0x18],r12
     a83:	mov    QWORD PTR [rsp+0x20],r13
     a88:	mov    QWORD PTR [rsp+0x28],r14
     a8d:	mov    r12,rdi
     a90:	mov    QWORD PTR [rsp],rsi
     a94:	mov    r13,rsi
     a97:	mov    QWORD PTR [rsp+0x8],rdx
     a9c:	mov    rbx,rdx
     a9f:	mov    rsi,r13
     aa2:	mov    rdi,r12
     aa5:	call   aaa <botlish_fn_6+0x39>
			aa6: R_X86_64_PLT32	botlish_fn_4-0x4 ; high_nibble<generic>
     aaa:	test   rax,rax
     aad:	je     bdb <botlish_fn_6+0x16a>
     ab3:	test   rax,0x1
     ab9:	jne    ac7 <botlish_fn_6+0x56>
     abf:	mov    rdx,rax
     ac2:	jmp    add <botlish_fn_6+0x6c>
     ac7:	mov    rdx,QWORD PTR [rbx+0x8]
     acb:	mov    rcx,rax
     ace:	sar    rcx,1
     ad1:	cmp    rcx,rdx
     ad4:	jb     af9 <botlish_fn_6+0x88>
     ada:	mov    rdx,rax
     add:	mov    rsi,rbx
     ae0:	mov    rdi,r12
     ae3:	call   ae8 <botlish_fn_6+0x77>
			ae4: R_X86_64_PLT32	rt_list_get-0x4
     ae8:	test   rax,rax
     aeb:	je     bdb <botlish_fn_6+0x16a>
     af1:	mov    rsi,rax
     af4:	jmp    b01 <botlish_fn_6+0x90>
     af9:	mov    rax,QWORD PTR [rbx+0x10]
     afd:	mov    rsi,QWORD PTR [rax+rcx*8]
     b01:	mov    QWORD PTR [rsp],rsi
     b05:	mov    r14,rsi
     b08:	mov    ecx,0x1
     b0d:	mov    rsi,r13
     b10:	test   rsi,0x1
     b17:	jne    b35 <botlish_fn_6+0xc4>
     b1d:	xor    ecx,ecx
     b1f:	test   rsi,0x7
     b26:	jne    b35 <botlish_fn_6+0xc4>
     b2c:	movzx  rax,BYTE PTR [rsi]
     b30:	cmp    al,0x1
     b32:	sete   cl
     b35:	test   cl,cl
     b37:	jne    b58 <botlish_fn_6+0xe7>
     b3d:	mov    rdi,r12
     b40:	mov    rax,QWORD PTR [rdi+0x10]
     b44:	mov    rcx,QWORD PTR [rax+0xb0]
     b4b:	xor    rdx,rdx
     b4e:	call   b53 <botlish_fn_6+0xe2>
			b4f: R_X86_64_PLT32	rt_type_error-0x4
     b53:	jmp    bdb <botlish_fn_6+0x16a>
     b58:	mov    edx,0x21
     b5d:	mov    rdi,r12
     b60:	call   b65 <botlish_fn_6+0xf4>
			b61: R_X86_64_PLT32	rt_int_mod-0x4
     b65:	test   rax,rax
     b68:	je     bdb <botlish_fn_6+0x16a>
     b6e:	test   rax,0x1
     b74:	jne    b85 <botlish_fn_6+0x114>
     b7a:	mov    rdx,rax
     b7d:	mov    rsi,rbx
     b80:	jmp    b9e <botlish_fn_6+0x12d>
     b85:	mov    rdi,QWORD PTR [rbx+0x8]
     b89:	mov    rsi,rax
     b8c:	sar    rsi,1
     b8f:	mov    rdx,rax
     b92:	cmp    rsi,rdi
     b95:	jb     bb7 <botlish_fn_6+0x146>
     b9b:	mov    rsi,rbx
     b9e:	mov    rdi,r12
     ba1:	call   ba6 <botlish_fn_6+0x135>
			ba2: R_X86_64_PLT32	rt_list_get-0x4
     ba6:	test   rax,rax
     ba9:	je     bdb <botlish_fn_6+0x16a>
     baf:	mov    rdx,rax
     bb2:	jmp    bc2 <botlish_fn_6+0x151>
     bb7:	mov    rax,rbx
     bba:	mov    rax,QWORD PTR [rax+0x10]
     bbe:	mov    rdx,QWORD PTR [rax+rsi*8]
     bc2:	mov    QWORD PTR [rsp+0x8],rdx
     bc7:	mov    rsi,r14
     bca:	mov    rdi,r12
     bcd:	call   bd2 <botlish_fn_6+0x161>
			bce: R_X86_64_PLT32	rt_str_cat-0x4
     bd2:	test   rax,rax
     bd5:	jne    bfb <botlish_fn_6+0x18a>
     bdb:	xor    rax,rax
     bde:	mov    rbx,QWORD PTR [rsp+0x10]
     be3:	mov    r12,QWORD PTR [rsp+0x18]
     be8:	mov    r13,QWORD PTR [rsp+0x20]
     bed:	mov    r14,QWORD PTR [rsp+0x28]
     bf2:	add    rsp,0x30
     bf6:	mov    rsp,rbp
     bf9:	pop    rbp
     bfa:	ret
     bfb:	mov    rbx,QWORD PTR [rsp+0x10]
     c00:	mov    r12,QWORD PTR [rsp+0x18]
     c05:	mov    r13,QWORD PTR [rsp+0x20]
     c0a:	mov    r14,QWORD PTR [rsp+0x28]
     c0f:	add    rsp,0x30
     c13:	mov    rsp,rbp
     c16:	pop    rbp
     c17:	ret

0000000000000c18 <botlish_entry_6: hex_pair<generic>>:
     c18:	push   rbp
     c19:	mov    rbp,rsp
     c1c:	mov    rsi,QWORD PTR [rdx]
     c1f:	mov    rdx,QWORD PTR [rdx+0x8]
     c23:	call   c28 <botlish_entry_6+0x10>
			c24: R_X86_64_PLT32	botlish_fn_6-0x4 ; hex_pair<generic>
     c28:	mov    rsp,rbp
     c2b:	pop    rbp
     c2c:	ret
     c2d:	add    BYTE PTR [rax],al
	...

0000000000000c30 <botlish_fn_7: esc_bytes<generic>>:
     c30:	push   rbp
     c31:	mov    rbp,rsp
     c34:	sub    rsp,0x70
     c38:	mov    QWORD PTR [rsp+0x40],rbx
     c3d:	mov    QWORD PTR [rsp+0x48],r12
     c42:	mov    QWORD PTR [rsp+0x50],r13
     c47:	mov    QWORD PTR [rsp+0x58],r14
     c4c:	mov    QWORD PTR [rsp+0x60],r15
     c51:	mov    r13,rdi
     c54:	mov    QWORD PTR [rsp+0x28],0x0
     c5d:	mov    QWORD PTR [rsp],rsi
     c61:	mov    QWORD PTR [rsp+0x8],rdx
     c66:	mov    QWORD PTR [rsp+0x10],rcx
     c6b:	mov    QWORD PTR [rsp+0x18],r8
     c70:	mov    r12,r8
     c73:	mov    r14,rcx
     c76:	mov    r15,rdx
     c79:	xor    eax,eax
     c7b:	test   rsi,0x7
     c82:	jne    c93 <botlish_fn_7+0x63>
     c88:	movzx  r8,BYTE PTR [rsi]
     c8c:	cmp    r8b,0x3
     c90:	sete   al
     c93:	test   al,al
     c95:	jne    cb8 <botlish_fn_7+0x88>
     c9b:	mov    rdi,r13
     c9e:	mov    rax,QWORD PTR [rdi+0x10]
     ca2:	mov    rcx,QWORD PTR [rax+0xb8]
     ca9:	mov    edx,0x4
     cae:	call   cb3 <botlish_fn_7+0x83>
			caf: R_X86_64_PLT32	rt_type_error-0x4
     cb3:	jmp    ebe <botlish_fn_7+0x28e>
     cb8:	mov    rbx,rsi
     cbb:	mov    rdi,r13
     cbe:	call   cc3 <botlish_fn_7+0x93>
			cbf: R_X86_64_PLT32	rt_list_len-0x4
     cc3:	mov    ecx,0x1
     cc8:	mov    rsi,r15
     ccb:	test   rsi,0x1
     cd2:	jne    cf8 <botlish_fn_7+0xc8>
     cd8:	xor    ecx,ecx
     cda:	mov    rsi,r15
     cdd:	test   rsi,0x7
     ce4:	jne    cf8 <botlish_fn_7+0xc8>
     cea:	mov    rsi,r15
     ced:	movzx  rcx,BYTE PTR [rsi]
     cf1:	rex cmp cl,0x1
     cf5:	sete   cl
     cf8:	test   cl,cl
     cfa:	jne    d1e <botlish_fn_7+0xee>
     d00:	mov    rdi,r13
     d03:	mov    rax,QWORD PTR [rdi+0x10]
     d07:	mov    rcx,QWORD PTR [rax+0xc0]
     d0e:	xor    rdx,rdx
     d11:	mov    rsi,r15
     d14:	call   d19 <botlish_fn_7+0xe9>
			d15: R_X86_64_PLT32	rt_type_error-0x4
     d19:	jmp    ebe <botlish_fn_7+0x28e>
     d1e:	mov    rsi,r15
     d21:	mov    rcx,rsi
     d24:	and    rcx,rax
     d27:	mov    rdx,rax
     d2a:	test   rcx,0x1
     d31:	jne    d57 <botlish_fn_7+0x127>
     d37:	mov    rsi,r15
     d3a:	mov    rdi,r13
     d3d:	call   d42 <botlish_fn_7+0x112>
			d3e: R_X86_64_PLT32	rt_int_cmp-0x4
     d42:	mov    ecx,0x2
     d47:	test   rax,rax
     d4a:	cmovge rcx,QWORD PTR [rip+0x1de]        # f30 <botlish_fn_7+0x300>
     d52:	jmp    d6a <botlish_fn_7+0x13a>
     d57:	mov    ecx,0x2
     d5c:	mov    rsi,r15
     d5f:	cmp    rsi,rdx
     d62:	cmovge rcx,QWORD PTR [rip+0x1c6]        # f30 <botlish_fn_7+0x300>
     d6a:	cmp    rcx,0x6
     d6e:	je     f09 <botlish_fn_7+0x2d9>
     d74:	mov    QWORD PTR [rsp+0x20],0x3
     d7d:	mov    rsi,r15
     d80:	test   rsi,0x1
     d87:	je     da2 <botlish_fn_7+0x172>
     d8d:	mov    rsi,r15
     d90:	mov    rax,rsi
     d93:	add    rax,0x2
     d97:	seto   cl
     d9a:	test   cl,cl
     d9c:	je     db2 <botlish_fn_7+0x182>
     da2:	mov    edx,0x3
     da7:	mov    rsi,r15
     daa:	mov    rdi,r13
     dad:	call   db2 <botlish_fn_7+0x182>
			dae: R_X86_64_PLT32	rt_int_add-0x4
     db2:	mov    QWORD PTR [rsp+0x8],rax
     db7:	mov    rdi,r13
     dba:	mov    QWORD PTR [rsp+0x30],rax
     dbf:	mov    rax,QWORD PTR [rdi+0x10]
     dc3:	mov    rsi,QWORD PTR [rax+0xc8]
     dca:	mov    QWORD PTR [rsp+0x20],rsi
     dcf:	mov    QWORD PTR [rsp+0x38],rsi
     dd4:	mov    rsi,r15
     dd7:	test   rsi,0x1
     dde:	jne    dec <botlish_fn_7+0x1bc>
     de4:	mov    rdx,r15
     de7:	jmp    e05 <botlish_fn_7+0x1d5>
     dec:	mov    rcx,QWORD PTR [rbx+0x8]
     df0:	mov    rsi,r15
     df3:	mov    rax,rsi
     df6:	sar    rax,1
     df9:	cmp    rax,rcx
     dfc:	jb     e21 <botlish_fn_7+0x1f1>
     e02:	mov    rdx,r15
     e05:	mov    rsi,rbx
     e08:	mov    rdi,r13
     e0b:	call   e10 <botlish_fn_7+0x1e0>
			e0c: R_X86_64_PLT32	rt_list_get-0x4
     e10:	test   rax,rax
     e13:	je     ebe <botlish_fn_7+0x28e>
     e19:	mov    rsi,rax
     e1c:	jmp    e29 <botlish_fn_7+0x1f9>
     e21:	mov    rcx,QWORD PTR [rbx+0x10]
     e25:	mov    rsi,QWORD PTR [rcx+rax*8]
     e29:	mov    QWORD PTR [rsp+0x28],rsi
     e2e:	mov    rdx,r12
     e31:	mov    rdi,r13
     e34:	call   e39 <botlish_fn_7+0x209>
			e35: R_X86_64_PLT32	botlish_fn_6-0x4 ; hex_pair<generic>
     e39:	test   rax,rax
     e3c:	je     ebe <botlish_fn_7+0x28e>
     e42:	mov    QWORD PTR [rsp+0x28],rax
     e47:	mov    rdx,rax
     e4a:	mov    rsi,QWORD PTR [rsp+0x38]
     e4f:	mov    rdi,r13
     e52:	call   e57 <botlish_fn_7+0x227>
			e53: R_X86_64_PLT32	rt_str_cat-0x4
     e57:	test   rax,rax
     e5a:	je     ebe <botlish_fn_7+0x28e>
     e60:	mov    QWORD PTR [rsp+0x20],rax
     e65:	mov    rdx,rax
     e68:	xor    eax,eax
     e6a:	mov    rsi,r14
     e6d:	test   rsi,0x7
     e74:	jne    e85 <botlish_fn_7+0x255>
     e7a:	movzx  rdi,BYTE PTR [rsi]
     e7e:	cmp    dil,0x2
     e82:	sete   al
     e85:	test   al,al
     e87:	jne    ead <botlish_fn_7+0x27d>
     e8d:	mov    rdi,r13
     e90:	mov    rdi,QWORD PTR [rdi+0x10]
     e94:	mov    rcx,QWORD PTR [rdi+0xd0]
     e9b:	mov    edx,0x1
     ea0:	mov    rdi,r13
     ea3:	call   ea8 <botlish_fn_7+0x278>
			ea4: R_X86_64_PLT32	rt_type_error-0x4
     ea8:	jmp    ebe <botlish_fn_7+0x28e>
     ead:	mov    rdi,r13
     eb0:	call   eb5 <botlish_fn_7+0x285>
			eb1: R_X86_64_PLT32	rt_str_cat-0x4
     eb5:	test   rax,rax
     eb8:	jne    ee3 <botlish_fn_7+0x2b3>
     ebe:	xor    rax,rax
     ec1:	mov    rbx,QWORD PTR [rsp+0x40]
     ec6:	mov    r12,QWORD PTR [rsp+0x48]
     ecb:	mov    r13,QWORD PTR [rsp+0x50]
     ed0:	mov    r14,QWORD PTR [rsp+0x58]
     ed5:	mov    r15,QWORD PTR [rsp+0x60]
     eda:	add    rsp,0x70
     ede:	mov    rsp,rbp
     ee1:	pop    rbp
     ee2:	ret
     ee3:	mov    QWORD PTR [rsp],rbx
     ee7:	mov    rcx,QWORD PTR [rsp+0x30]
     eec:	mov    QWORD PTR [rsp+0x8],rcx
     ef1:	mov    QWORD PTR [rsp+0x10],rax
     ef6:	mov    QWORD PTR [rsp+0x18],r12
     efb:	mov    rsi,rbx
     efe:	mov    r14,rax
     f01:	mov    r15,rcx
     f04:	jmp    c79 <botlish_fn_7+0x49>
     f09:	mov    rax,r14
     f0c:	mov    rbx,QWORD PTR [rsp+0x40]
     f11:	mov    r12,QWORD PTR [rsp+0x48]
     f16:	mov    r13,QWORD PTR [rsp+0x50]
     f1b:	mov    r14,QWORD PTR [rsp+0x58]
     f20:	mov    r15,QWORD PTR [rsp+0x60]
     f25:	add    rsp,0x70
     f29:	mov    rsp,rbp
     f2c:	pop    rbp
     f2d:	ret
     f2e:	add    BYTE PTR [rax],al
     f30:	(bad)
     f31:	add    BYTE PTR [rax],al
     f33:	add    BYTE PTR [rax],al
     f35:	add    BYTE PTR [rax],al
	...

0000000000000f38 <botlish_entry_7: esc_bytes<generic>>:
     f38:	push   rbp
     f39:	mov    rbp,rsp
     f3c:	mov    rsi,QWORD PTR [rdx]
     f3f:	mov    r9,QWORD PTR [rdx+0x8]
     f43:	mov    rcx,QWORD PTR [rdx+0x10]
     f47:	mov    r8,QWORD PTR [rdx+0x18]
     f4b:	mov    rdx,r9
     f4e:	call   f53 <botlish_entry_7+0x1b>
			f4f: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_bytes<generic>
     f53:	mov    rsp,rbp
     f56:	pop    rbp
     f57:	ret

0000000000000f58 <botlish_fn_8: esc_char<generic>>:
     f58:	push   rbp
     f59:	mov    rbp,rsp
     f5c:	sub    rsp,0x50
     f60:	mov    QWORD PTR [rsp+0x20],rbx
     f65:	mov    QWORD PTR [rsp+0x28],r12
     f6a:	mov    QWORD PTR [rsp+0x30],r13
     f6f:	mov    QWORD PTR [rsp+0x38],r14
     f74:	mov    QWORD PTR [rsp+0x40],r15
     f79:	mov    QWORD PTR [rsp+0x10],0x0
     f82:	mov    QWORD PTR [rsp+0x18],0x0
     f8b:	mov    QWORD PTR [rsp],rsi
     f8f:	mov    QWORD PTR [rsp+0x8],rdx
     f94:	mov    rbx,rdx
     f97:	xor    r9d,r9d
     f9a:	test   rsi,0x7
     fa1:	jne    fb1 <botlish_fn_8+0x59>
     fa7:	movzx  rax,BYTE PTR [rsi]
     fab:	cmp    al,0x2
     fad:	sete   r9b
     fb1:	test   r9b,r9b
     fb4:	jne    fd4 <botlish_fn_8+0x7c>
     fba:	mov    rax,QWORD PTR [rdi+0x10]
     fbe:	mov    rcx,QWORD PTR [rax+0xd8]
     fc5:	mov    edx,0x1
     fca:	call   fcf <botlish_fn_8+0x77>
			fcb: R_X86_64_PLT32	rt_type_error-0x4
     fcf:	jmp    10d4 <botlish_fn_8+0x17c>
     fd4:	mov    r12,rdi
     fd7:	mov    r15,rsi
     fda:	call   fdf <botlish_fn_8+0x87>
			fdb: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
     fdf:	mov    rcx,rax
     fe2:	mov    r13,rax
     fe5:	test   rax,rcx
     fe8:	je     10d4 <botlish_fn_8+0x17c>
     fee:	mov    rax,r13
     ff1:	mov    QWORD PTR [rsp],rax
     ff5:	mov    rsi,r13
     ff8:	mov    rdi,r12
     ffb:	call   1000 <botlish_fn_8+0xa8>
			ffc: R_X86_64_PLT32	rt_list_len-0x4
    1000:	mov    edx,0x1
    1005:	sar    rax,1
    1008:	cmp    rax,0x1
    100c:	je     1047 <botlish_fn_8+0xef>
    1012:	mov    QWORD PTR [rsp+0x10],0x1
    101b:	mov    rdi,r12
    101e:	mov    rax,QWORD PTR [rdi+0x10]
    1022:	mov    rcx,QWORD PTR [rax+0xa0]
    1029:	mov    QWORD PTR [rsp+0x18],rcx
    102e:	mov    rsi,r13
    1031:	mov    r8,rbx
    1034:	call   1039 <botlish_fn_8+0xe1>
			1035: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_bytes<generic>
    1039:	test   rax,rax
    103c:	je     10d4 <botlish_fn_8+0x17c>
    1042:	jmp    10ff <botlish_fn_8+0x1a7>
    1047:	mov    rsi,r13
    104a:	mov    r14,rdx
    104d:	mov    rax,QWORD PTR [rsi+0x8]
    1051:	mov    r13,rsi
    1054:	test   rax,rax
    1057:	jne    107c <botlish_fn_8+0x124>
    105d:	mov    rdx,r14
    1060:	mov    rsi,r13
    1063:	mov    rdi,r12
    1066:	call   106b <botlish_fn_8+0x113>
			1067: R_X86_64_PLT32	rt_list_get-0x4
    106b:	test   rax,rax
    106e:	je     10d4 <botlish_fn_8+0x17c>
    1074:	mov    rsi,rax
    1077:	jmp    1086 <botlish_fn_8+0x12e>
    107c:	mov    rsi,r13
    107f:	mov    rcx,QWORD PTR [rsi+0x10]
    1083:	mov    rsi,QWORD PTR [rcx]
    1086:	mov    rdi,r12
    1089:	call   108e <botlish_fn_8+0x136>
			108a: R_X86_64_PLT32	botlish_fn_5-0x4 ; is_unreserved<generic>
    108e:	test   rax,rax
    1091:	je     10d4 <botlish_fn_8+0x17c>
    1097:	cmp    rax,0x6
    109b:	je     10fc <botlish_fn_8+0x1a4>
    10a1:	mov    QWORD PTR [rsp+0x10],0x1
    10aa:	mov    rdi,r12
    10ad:	mov    r8,QWORD PTR [rdi+0x10]
    10b1:	mov    rcx,QWORD PTR [r8+0xa0]
    10b8:	mov    QWORD PTR [rsp+0x18],rcx
    10bd:	mov    rdx,r14
    10c0:	mov    rsi,r13
    10c3:	mov    r8,rbx
    10c6:	call   10cb <botlish_fn_8+0x173>
			10c7: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_bytes<generic>
    10cb:	test   rax,rax
    10ce:	jne    10f9 <botlish_fn_8+0x1a1>
    10d4:	xor    rax,rax
    10d7:	mov    rbx,QWORD PTR [rsp+0x20]
    10dc:	mov    r12,QWORD PTR [rsp+0x28]
    10e1:	mov    r13,QWORD PTR [rsp+0x30]
    10e6:	mov    r14,QWORD PTR [rsp+0x38]
    10eb:	mov    r15,QWORD PTR [rsp+0x40]
    10f0:	add    rsp,0x50
    10f4:	mov    rsp,rbp
    10f7:	pop    rbp
    10f8:	ret
    10f9:	mov    r15,rax
    10fc:	mov    rax,r15
    10ff:	mov    rbx,QWORD PTR [rsp+0x20]
    1104:	mov    r12,QWORD PTR [rsp+0x28]
    1109:	mov    r13,QWORD PTR [rsp+0x30]
    110e:	mov    r14,QWORD PTR [rsp+0x38]
    1113:	mov    r15,QWORD PTR [rsp+0x40]
    1118:	add    rsp,0x50
    111c:	mov    rsp,rbp
    111f:	pop    rbp
    1120:	ret

0000000000001121 <botlish_entry_8: esc_char<generic>>:
    1121:	push   rbp
    1122:	mov    rbp,rsp
    1125:	mov    rsi,QWORD PTR [rdx]
    1128:	mov    rdx,QWORD PTR [rdx+0x8]
    112c:	call   1131 <botlish_entry_8+0x10>
			112d: R_X86_64_PLT32	botlish_fn_8-0x4 ; esc_char<generic>
    1131:	mov    rsp,rbp
    1134:	pop    rbp
    1135:	ret
	...

0000000000001138 <botlish_fn_9: esc_from<generic>>:
    1138:	push   rbp
    1139:	mov    rbp,rsp
    113c:	sub    rsp,0x70
    1140:	mov    QWORD PTR [rsp+0x40],rbx
    1145:	mov    QWORD PTR [rsp+0x48],r12
    114a:	mov    QWORD PTR [rsp+0x50],r13
    114f:	mov    QWORD PTR [rsp+0x58],r14
    1154:	mov    QWORD PTR [rsp+0x60],r15
    1159:	mov    r13,rdi
    115c:	mov    QWORD PTR [rsp+0x28],0x0
    1165:	mov    QWORD PTR [rsp],rsi
    1169:	mov    QWORD PTR [rsp+0x8],rdx
    116e:	mov    QWORD PTR [rsp+0x10],rcx
    1173:	mov    QWORD PTR [rsp+0x18],r8
    1178:	mov    r12,r8
    117b:	mov    r14,rcx
    117e:	mov    QWORD PTR [rsp+0x30],rdx
    1183:	xor    eax,eax
    1185:	test   rsi,0x7
    118c:	jne    119b <botlish_fn_9+0x63>
    1192:	movzx  rax,BYTE PTR [rsi]
    1196:	cmp    al,0x2
    1198:	sete   al
    119b:	test   al,al
    119d:	jne    11c0 <botlish_fn_9+0x88>
    11a3:	mov    rdi,r13
    11a6:	mov    rax,QWORD PTR [rdi+0x10]
    11aa:	mov    rcx,QWORD PTR [rax+0xe0]
    11b1:	mov    edx,0x1
    11b6:	call   11bb <botlish_fn_9+0x83>
			11b7: R_X86_64_PLT32	rt_type_error-0x4
    11bb:	jmp    1404 <botlish_fn_9+0x2cc>
    11c0:	mov    rbx,rsi
    11c3:	mov    rdi,r13
    11c6:	call   11cb <botlish_fn_9+0x93>
			11c7: R_X86_64_PLT32	rt_str_len-0x4
    11cb:	mov    edx,0x1
    11d0:	mov    r15,rdx
    11d3:	mov    ecx,0x1
    11d8:	mov    rsi,QWORD PTR [rsp+0x30]
    11dd:	test   rsi,0x1
    11e4:	jne    120e <botlish_fn_9+0xd6>
    11ea:	xor    ecx,ecx
    11ec:	mov    rsi,QWORD PTR [rsp+0x30]
    11f1:	test   rsi,0x7
    11f8:	jne    120e <botlish_fn_9+0xd6>
    11fe:	mov    rsi,QWORD PTR [rsp+0x30]
    1203:	movzx  rcx,BYTE PTR [rsi]
    1207:	rex cmp cl,0x1
    120b:	sete   cl
    120e:	test   cl,cl
    1210:	jne    1236 <botlish_fn_9+0xfe>
    1216:	mov    rdi,r13
    1219:	mov    rax,QWORD PTR [rdi+0x10]
    121d:	mov    rcx,QWORD PTR [rax+0xc0]
    1224:	xor    rdx,rdx
    1227:	mov    rsi,QWORD PTR [rsp+0x30]
    122c:	call   1231 <botlish_fn_9+0xf9>
			122d: R_X86_64_PLT32	rt_type_error-0x4
    1231:	jmp    1404 <botlish_fn_9+0x2cc>
    1236:	mov    rsi,QWORD PTR [rsp+0x30]
    123b:	mov    rcx,rsi
    123e:	and    rcx,rax
    1241:	mov    rdx,rax
    1244:	test   rcx,0x1
    124b:	jne    1273 <botlish_fn_9+0x13b>
    1251:	mov    rsi,QWORD PTR [rsp+0x30]
    1256:	mov    rdi,r13
    1259:	call   125e <botlish_fn_9+0x126>
			125a: R_X86_64_PLT32	rt_int_cmp-0x4
    125e:	mov    ecx,0x2
    1263:	test   rax,rax
    1266:	cmovge rcx,QWORD PTR [rip+0x20a]        # 1478 <botlish_fn_9+0x340>
    126e:	jmp    1288 <botlish_fn_9+0x150>
    1273:	mov    ecx,0x2
    1278:	mov    rsi,QWORD PTR [rsp+0x30]
    127d:	cmp    rsi,rdx
    1280:	cmovge rcx,QWORD PTR [rip+0x1f0]        # 1478 <botlish_fn_9+0x340>
    1288:	cmp    rcx,0x6
    128c:	je     1451 <botlish_fn_9+0x319>
    1292:	mov    QWORD PTR [rsp+0x20],0x3
    129b:	mov    rsi,QWORD PTR [rsp+0x30]
    12a0:	test   rsi,0x1
    12a7:	je     12c4 <botlish_fn_9+0x18c>
    12ad:	mov    rsi,QWORD PTR [rsp+0x30]
    12b2:	mov    rax,rsi
    12b5:	add    rax,0x2
    12b9:	seto   cl
    12bc:	test   cl,cl
    12be:	je     12d6 <botlish_fn_9+0x19e>
    12c4:	mov    edx,0x3
    12c9:	mov    rsi,QWORD PTR [rsp+0x30]
    12ce:	mov    rdi,r13
    12d1:	call   12d6 <botlish_fn_9+0x19e>
			12d2: R_X86_64_PLT32	rt_int_add-0x4
    12d6:	mov    QWORD PTR [rsp+0x20],rax
    12db:	mov    QWORD PTR [rsp+0x38],rax
    12e0:	mov    QWORD PTR [rsp+0x28],0x3
    12e9:	mov    rsi,QWORD PTR [rsp+0x30]
    12ee:	test   rsi,0x1
    12f5:	je     1312 <botlish_fn_9+0x1da>
    12fb:	mov    rsi,QWORD PTR [rsp+0x30]
    1300:	mov    rcx,rsi
    1303:	add    rcx,0x2
    1307:	seto   al
    130a:	test   al,al
    130c:	je     1327 <botlish_fn_9+0x1ef>
    1312:	mov    edx,0x3
    1317:	mov    rsi,QWORD PTR [rsp+0x30]
    131c:	mov    rdi,r13
    131f:	call   1324 <botlish_fn_9+0x1ec>
			1320: R_X86_64_PLT32	rt_int_add-0x4
    1324:	mov    rcx,rax
    1327:	mov    QWORD PTR [rsp+0x28],rcx
    132c:	mov    rdx,QWORD PTR [rsp+0x30]
    1331:	mov    rsi,rbx
    1334:	mov    rdi,r13
    1337:	call   133c <botlish_fn_9+0x204>
			1338: R_X86_64_PLT32	rt_substr-0x4
    133c:	test   rax,rax
    133f:	je     1404 <botlish_fn_9+0x2cc>
    1345:	mov    QWORD PTR [rsp+0x8],rax
    134a:	mov    rsi,rax
    134d:	mov    rdx,r12
    1350:	mov    rdi,r13
    1353:	call   1358 <botlish_fn_9+0x220>
			1354: R_X86_64_PLT32	botlish_fn_8-0x4 ; esc_char<generic>
    1358:	test   rax,rax
    135b:	je     1404 <botlish_fn_9+0x2cc>
    1361:	mov    QWORD PTR [rsp+0x8],rax
    1366:	xor    ecx,ecx
    1368:	mov    rsi,r14
    136b:	test   rsi,0x7
    1372:	jne    1383 <botlish_fn_9+0x24b>
    1378:	movzx  rdi,BYTE PTR [rsi]
    137c:	cmp    dil,0x2
    1380:	sete   cl
    1383:	test   cl,cl
    1385:	jne    13a6 <botlish_fn_9+0x26e>
    138b:	mov    rdi,r13
    138e:	mov    r9,QWORD PTR [rdi+0x10]
    1392:	mov    rcx,QWORD PTR [r9+0xd0]
    1399:	mov    rdx,r15
    139c:	call   13a1 <botlish_fn_9+0x269>
			139d: R_X86_64_PLT32	rt_type_error-0x4
    13a1:	jmp    1404 <botlish_fn_9+0x2cc>
    13a6:	mov    rdx,r15
    13a9:	xor    ecx,ecx
    13ab:	test   rax,0x7
    13b1:	je     13bf <botlish_fn_9+0x287>
    13b7:	mov    r8,rax
    13ba:	jmp    13cd <botlish_fn_9+0x295>
    13bf:	movzx  rcx,BYTE PTR [rax]
    13c3:	mov    r8,rax
    13c6:	rex cmp cl,0x2
    13ca:	sete   cl
    13cd:	test   cl,cl
    13cf:	jne    13f0 <botlish_fn_9+0x2b8>
    13d5:	mov    rdi,r13
    13d8:	mov    rax,QWORD PTR [rdi+0x10]
    13dc:	mov    rcx,QWORD PTR [rax+0xd0]
    13e3:	mov    rsi,r8
    13e6:	call   13eb <botlish_fn_9+0x2b3>
			13e7: R_X86_64_PLT32	rt_type_error-0x4
    13eb:	jmp    1404 <botlish_fn_9+0x2cc>
    13f0:	mov    rdx,r8
    13f3:	mov    rdi,r13
    13f6:	call   13fb <botlish_fn_9+0x2c3>
			13f7: R_X86_64_PLT32	rt_str_cat-0x4
    13fb:	test   rax,rax
    13fe:	jne    1429 <botlish_fn_9+0x2f1>
    1404:	xor    rax,rax
    1407:	mov    rbx,QWORD PTR [rsp+0x40]
    140c:	mov    r12,QWORD PTR [rsp+0x48]
    1411:	mov    r13,QWORD PTR [rsp+0x50]
    1416:	mov    r14,QWORD PTR [rsp+0x58]
    141b:	mov    r15,QWORD PTR [rsp+0x60]
    1420:	add    rsp,0x70
    1424:	mov    rsp,rbp
    1427:	pop    rbp
    1428:	ret
    1429:	mov    QWORD PTR [rsp],rbx
    142d:	mov    rcx,QWORD PTR [rsp+0x38]
    1432:	mov    QWORD PTR [rsp+0x8],rcx
    1437:	mov    QWORD PTR [rsp+0x10],rax
    143c:	mov    QWORD PTR [rsp+0x18],r12
    1441:	mov    rsi,rbx
    1444:	mov    r14,rax
    1447:	mov    QWORD PTR [rsp+0x30],rcx
    144c:	jmp    1183 <botlish_fn_9+0x4b>
    1451:	mov    rax,r14
    1454:	mov    rbx,QWORD PTR [rsp+0x40]
    1459:	mov    r12,QWORD PTR [rsp+0x48]
    145e:	mov    r13,QWORD PTR [rsp+0x50]
    1463:	mov    r14,QWORD PTR [rsp+0x58]
    1468:	mov    r15,QWORD PTR [rsp+0x60]
    146d:	add    rsp,0x70
    1471:	mov    rsp,rbp
    1474:	pop    rbp
    1475:	ret
    1476:	add    BYTE PTR [rax],al
    1478:	(bad)
    1479:	add    BYTE PTR [rax],al
    147b:	add    BYTE PTR [rax],al
    147d:	add    BYTE PTR [rax],al
	...

0000000000001480 <botlish_entry_9: esc_from<generic>>:
    1480:	push   rbp
    1481:	mov    rbp,rsp
    1484:	mov    rsi,QWORD PTR [rdx]
    1487:	mov    r9,QWORD PTR [rdx+0x8]
    148b:	mov    rcx,QWORD PTR [rdx+0x10]
    148f:	mov    r8,QWORD PTR [rdx+0x18]
    1493:	mov    rdx,r9
    1496:	call   149b <botlish_entry_9+0x1b>
			1497: R_X86_64_PLT32	botlish_fn_9-0x4 ; esc_from<generic>
    149b:	mov    rsp,rbp
    149e:	pop    rbp
    149f:	ret

00000000000014a0 <botlish_fn_10: check<int, int, str, str>>:
    14a0:	push   rbp
    14a1:	mov    rbp,rsp
    14a4:	sub    rsp,0x60
    14a8:	mov    QWORD PTR [rsp+0x30],rbx
    14ad:	mov    QWORD PTR [rsp+0x38],r12
    14b2:	mov    QWORD PTR [rsp+0x40],r13
    14b7:	mov    QWORD PTR [rsp+0x48],r14
    14bc:	mov    QWORD PTR [rsp+0x50],r15
    14c1:	mov    QWORD PTR [rsp+0x20],0x0
    14ca:	mov    QWORD PTR [rsp],rsi
    14ce:	mov    QWORD PTR [rsp+0x8],rdx
    14d3:	mov    QWORD PTR [rsp+0x10],rcx
    14d8:	mov    r12,rcx
    14db:	mov    QWORD PTR [rsp+0x18],r8
    14e0:	mov    r14,r8
    14e3:	mov    r13,rsi
    14e6:	mov    r15,rdx
    14e9:	test   r13,0x1
    14f0:	jne    151b <botlish_fn_10+0x7b>
    14f6:	mov    edx,0x1
    14fb:	mov    rbx,rdi
    14fe:	mov    rsi,r13
    1501:	call   1506 <botlish_fn_10+0x66>
			1502: R_X86_64_PLT32	rt_int_cmp-0x4
    1506:	mov    ecx,0x2
    150b:	test   rax,rax
    150e:	cmovle rcx,QWORD PTR [rip+0x152]        # 1668 <botlish_fn_10+0x1c8>
    1516:	jmp    152f <botlish_fn_10+0x8f>
    151b:	mov    rbx,rdi
    151e:	mov    ecx,0x2
    1523:	cmp    r13,0x1
    1527:	cmovle rcx,QWORD PTR [rip+0x139]        # 1668 <botlish_fn_10+0x1c8>
    152f:	cmp    rcx,0x6
    1533:	je     163c <botlish_fn_10+0x19c>
    1539:	mov    rax,QWORD PTR [rbx+0x10]
    153d:	mov    rax,QWORD PTR [rax+0xe8]
    1544:	mov    rsi,r12
    1547:	mov    rdi,rbx
    154a:	call   154f <botlish_fn_10+0xaf>
			154b: R_X86_64_PLT32	botlish_fn_11-0x4 ; <str>
    154f:	test   rax,rax
    1552:	je     1593 <botlish_fn_10+0xf3>
    1558:	cmp    rax,0x6
    155c:	je     1574 <botlish_fn_10+0xd4>
    1562:	mov    edx,0x1
    1567:	mov    QWORD PTR [rsp],0x1
    156f:	jmp    15d5 <botlish_fn_10+0x135>
    1574:	mov    rax,QWORD PTR [rbx+0x10]
    1578:	mov    rax,QWORD PTR [rax+0xf0]
    157f:	mov    rsi,r12
    1582:	mov    rdi,rbx
    1585:	call   158a <botlish_fn_10+0xea>
			1586: R_X86_64_PLT32	botlish_fn_19-0x4 ; <str>
    158a:	test   rax,rax
    158d:	jne    15b8 <botlish_fn_10+0x118>
    1593:	xor    rax,rax
    1596:	mov    rbx,QWORD PTR [rsp+0x30]
    159b:	mov    r12,QWORD PTR [rsp+0x38]
    15a0:	mov    r13,QWORD PTR [rsp+0x40]
    15a5:	mov    r14,QWORD PTR [rsp+0x48]
    15aa:	mov    r15,QWORD PTR [rsp+0x50]
    15af:	add    rsp,0x60
    15b3:	mov    rsp,rbp
    15b6:	pop    rbp
    15b7:	ret
    15b8:	cmp    rax,0x6
    15bc:	je     15cc <botlish_fn_10+0x12c>
    15c2:	mov    edx,0x1
    15c7:	jmp    15d1 <botlish_fn_10+0x131>
    15cc:	mov    edx,0x3
    15d1:	mov    QWORD PTR [rsp],rdx
    15d5:	sar    r13,1
    15d8:	sub    r13,0x1
    15dc:	shl    r13,1
    15df:	or     r13,0x1
    15e3:	mov    QWORD PTR [rsp+0x20],r13
    15e8:	mov    rsi,r15
    15eb:	mov    r8,rsi
    15ee:	and    r8,rdx
    15f1:	test   r8,0x1
    15f8:	je     1613 <botlish_fn_10+0x173>
    15fe:	lea    r11,[rdx-0x1]
    1602:	mov    rax,rsi
    1605:	add    rax,r11
    1608:	seto   cl
    160b:	test   cl,cl
    160d:	je     161b <botlish_fn_10+0x17b>
    1613:	mov    rdi,rbx
    1616:	call   161b <botlish_fn_10+0x17b>
			1617: R_X86_64_PLT32	rt_int_add-0x4
    161b:	mov    QWORD PTR [rsp],r13
    161f:	mov    QWORD PTR [rsp+0x8],rax
    1624:	mov    QWORD PTR [rsp+0x10],r12
    1629:	mov    r8,r14
    162c:	mov    QWORD PTR [rsp+0x18],r8
    1631:	mov    rdi,rbx
    1634:	mov    r15,rax
    1637:	jmp    14e9 <botlish_fn_10+0x49>
    163c:	mov    rax,r15
    163f:	mov    rbx,QWORD PTR [rsp+0x30]
    1644:	mov    r12,QWORD PTR [rsp+0x38]
    1649:	mov    r13,QWORD PTR [rsp+0x40]
    164e:	mov    r14,QWORD PTR [rsp+0x48]
    1653:	mov    r15,QWORD PTR [rsp+0x50]
    1658:	add    rsp,0x60
    165c:	mov    rsp,rbp
    165f:	pop    rbp
    1660:	ret
    1661:	add    BYTE PTR [rax],al
    1663:	add    BYTE PTR [rax],al
    1665:	add    BYTE PTR [rax],al
    1667:	add    BYTE PTR [rsi],al
    1669:	add    BYTE PTR [rax],al
    166b:	add    BYTE PTR [rax],al
    166d:	add    BYTE PTR [rax],al
	...

0000000000001670 <botlish_entry_10: check<int, int, str, str>>:
    1670:	push   rbp
    1671:	mov    rbp,rsp
    1674:	mov    rsi,QWORD PTR [rdx]
    1677:	mov    r9,QWORD PTR [rdx+0x8]
    167b:	mov    rcx,QWORD PTR [rdx+0x10]
    167f:	mov    r8,QWORD PTR [rdx+0x18]
    1683:	mov    rdx,r9
    1686:	call   168b <botlish_entry_10+0x1b>
			1687: R_X86_64_PLT32	botlish_fn_10-0x4 ; check<int, int, str, str>
    168b:	mov    rsp,rbp
    168e:	pop    rbp
    168f:	ret

0000000000001690 <botlish_fn_11: <str>>:
    1690:	push   rbp
    1691:	mov    rbp,rsp
    1694:	sub    rsp,0x50
    1698:	mov    QWORD PTR [rsp+0x30],rbx
    169d:	mov    QWORD PTR [rsp+0x38],r12
    16a2:	mov    QWORD PTR [rsp+0x40],r13
    16a7:	mov    QWORD PTR [rsp+0x48],r14
    16ac:	mov    r13,rdi
    16af:	mov    QWORD PTR [rsp+0x18],0x0
    16b8:	mov    QWORD PTR [rsp],rsi
    16bc:	mov    r14,rsi
    16bf:	mov    rsi,r14
    16c2:	mov    rdi,r13
    16c5:	call   16ca <botlish_fn_11+0x3a>
			16c6: R_X86_64_PLT32	rt_str_len-0x4
    16ca:	mov    rbx,rax
    16cd:	mov    QWORD PTR [rsp+0x8],rax
    16d2:	mov    esi,0x1
    16d7:	mov    QWORD PTR [rsp+0x10],0x1
    16e0:	mov    rcx,r14
    16e3:	mov    rdx,rbx
    16e6:	mov    rdi,r13
    16e9:	call   16ee <botlish_fn_11+0x5e>
			16ea: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_local<generic>
    16ee:	mov    r12,rax
    16f1:	test   r12,r12
    16f4:	je     1851 <botlish_fn_11+0x1c1>
    16fa:	mov    QWORD PTR [rsp+0x10],r12
    16ff:	test   r12,0x1
    1706:	jne    1731 <botlish_fn_11+0xa1>
    170c:	mov    edx,0x1
    1711:	mov    rsi,r12
    1714:	mov    rdi,r13
    1717:	call   171c <botlish_fn_11+0x8c>
			1718: R_X86_64_PLT32	rt_int_cmp-0x4
    171c:	mov    ecx,0x2
    1721:	test   rax,rax
    1724:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 18f0 <botlish_fn_11+0x260>
    172c:	jmp    1742 <botlish_fn_11+0xb2>
    1731:	mov    ecx,0x2
    1736:	cmp    r12,0x1
    173a:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 18f0 <botlish_fn_11+0x260>
    1742:	cmp    rcx,0x6
    1746:	je     18cc <botlish_fn_11+0x23c>
    174c:	mov    rcx,r12
    174f:	and    rcx,rbx
    1752:	test   rcx,0x1
    1759:	jne    1782 <botlish_fn_11+0xf2>
    175f:	mov    rdx,rbx
    1762:	mov    rsi,r12
    1765:	mov    rdi,r13
    1768:	call   176d <botlish_fn_11+0xdd>
			1769: R_X86_64_PLT32	rt_int_cmp-0x4
    176d:	mov    ecx,0x2
    1772:	test   rax,rax
    1775:	cmovge rcx,QWORD PTR [rip+0x173]        # 18f0 <botlish_fn_11+0x260>
    177d:	jmp    1792 <botlish_fn_11+0x102>
    1782:	mov    ecx,0x2
    1787:	cmp    r12,rbx
    178a:	cmovge rcx,QWORD PTR [rip+0x15e]        # 18f0 <botlish_fn_11+0x260>
    1792:	cmp    rcx,0x6
    1796:	je     18c2 <botlish_fn_11+0x232>
    179c:	lea    rcx,[rsp+0x20]
    17a1:	mov    rdx,r14
    17a4:	mov    rsi,r12
    17a7:	mov    rdi,r13
    17aa:	call   17af <botlish_fn_11+0x11f>
			17ab: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    17af:	test   rax,rax
    17b2:	mov    rsi,rax
    17b5:	je     1851 <botlish_fn_11+0x1c1>
    17bb:	mov    rdx,QWORD PTR [rsp+0x20]
    17c0:	mov    rcx,QWORD PTR [rsp+0x28]
    17c5:	mov    rdi,r13
    17c8:	mov    rax,QWORD PTR [rdi+0x10]
    17cc:	mov    r8,QWORD PTR [rax+0x108]
    17d3:	call   17d8 <botlish_fn_11+0x148>
			17d4: R_X86_64_PLT32	rt_str_region_eq-0x4
    17d8:	cmp    rax,0x6
    17dc:	je     17ef <botlish_fn_11+0x15f>
    17e2:	mov    ecx,0x2
    17e7:	mov    rax,rcx
    17ea:	jmp    18d1 <botlish_fn_11+0x241>
    17ef:	mov    QWORD PTR [rsp+0x18],0x3
    17f8:	test   r12,0x1
    17ff:	jne    180d <botlish_fn_11+0x17d>
    1805:	mov    rcx,r12
    1808:	jmp    1822 <botlish_fn_11+0x192>
    180d:	mov    rsi,r12
    1810:	add    rsi,0x2
    1814:	mov    rcx,r12
    1817:	seto   al
    181a:	test   al,al
    181c:	je     1835 <botlish_fn_11+0x1a5>
    1822:	mov    edx,0x3
    1827:	mov    rsi,rcx
    182a:	mov    rdi,r13
    182d:	call   1832 <botlish_fn_11+0x1a2>
			182e: R_X86_64_PLT32	rt_int_add-0x4
    1832:	mov    rsi,rax
    1835:	mov    QWORD PTR [rsp+0x10],rsi
    183a:	mov    rcx,r14
    183d:	mov    rdx,rbx
    1840:	mov    rdi,r13
    1843:	call   1848 <botlish_fn_11+0x1b8>
			1844: R_X86_64_PLT32	botlish_fn_18-0x4 ; domain_loop<generic>
    1848:	test   rax,rax
    184b:	jne    1871 <botlish_fn_11+0x1e1>
    1851:	xor    rax,rax
    1854:	mov    rbx,QWORD PTR [rsp+0x30]
    1859:	mov    r12,QWORD PTR [rsp+0x38]
    185e:	mov    r13,QWORD PTR [rsp+0x40]
    1863:	mov    r14,QWORD PTR [rsp+0x48]
    1868:	add    rsp,0x50
    186c:	mov    rsp,rbp
    186f:	pop    rbp
    1870:	ret
    1871:	mov    rcx,rax
    1874:	and    rcx,rbx
    1877:	mov    rsi,rax
    187a:	test   rcx,0x1
    1881:	jne    18aa <botlish_fn_11+0x21a>
    1887:	mov    rdx,rbx
    188a:	mov    rdi,r13
    188d:	call   1892 <botlish_fn_11+0x202>
			188e: R_X86_64_PLT32	rt_int_cmp-0x4
    1892:	mov    ecx,0x2
    1897:	test   rax,rax
    189a:	mov    rax,rcx
    189d:	cmove  rax,QWORD PTR [rip+0x4b]        # 18f0 <botlish_fn_11+0x260>
    18a5:	jmp    18d1 <botlish_fn_11+0x241>
    18aa:	mov    rdx,rbx
    18ad:	mov    eax,0x2
    18b2:	cmp    rsi,rdx
    18b5:	cmove  rax,QWORD PTR [rip+0x33]        # 18f0 <botlish_fn_11+0x260>
    18bd:	jmp    18d1 <botlish_fn_11+0x241>
    18c2:	mov    eax,0x2
    18c7:	jmp    18d1 <botlish_fn_11+0x241>
    18cc:	mov    eax,0x2
    18d1:	mov    rbx,QWORD PTR [rsp+0x30]
    18d6:	mov    r12,QWORD PTR [rsp+0x38]
    18db:	mov    r13,QWORD PTR [rsp+0x40]
    18e0:	mov    r14,QWORD PTR [rsp+0x48]
    18e5:	add    rsp,0x50
    18e9:	mov    rsp,rbp
    18ec:	pop    rbp
    18ed:	ret
    18ee:	add    BYTE PTR [rax],al
    18f0:	(bad)
    18f1:	add    BYTE PTR [rax],al
    18f3:	add    BYTE PTR [rax],al
    18f5:	add    BYTE PTR [rax],al
	...

00000000000018f8 <botlish_entry_11: <str>>:
    18f8:	push   rbp
    18f9:	mov    rbp,rsp
    18fc:	mov    rsi,QWORD PTR [rdx]
    18ff:	call   1904 <botlish_entry_11+0xc>
			1900: R_X86_64_PLT32	botlish_fn_11-0x4 ; <str>
    1904:	mov    rsp,rbp
    1907:	pop    rbp
    1908:	ret
    1909:	add    BYTE PTR [rax],al
    190b:	add    BYTE PTR [rax],al
    190d:	add    BYTE PTR [rax],al
	...

0000000000001910 <botlish_fn_12: <generic>>:
    1910:	push   rbp
    1911:	mov    rbp,rsp
    1914:	sub    rsp,0x60
    1918:	mov    QWORD PTR [rsp+0x30],rbx
    191d:	mov    QWORD PTR [rsp+0x38],r12
    1922:	mov    QWORD PTR [rsp+0x40],r13
    1927:	mov    QWORD PTR [rsp+0x48],r14
    192c:	mov    QWORD PTR [rsp+0x50],r15
    1931:	mov    QWORD PTR [rsp+0x18],0x0
    193a:	mov    QWORD PTR [rsp],rsi
    193e:	xor    r8d,r8d
    1941:	test   rsi,0x7
    1948:	jne    1958 <botlish_fn_12+0x48>
    194e:	movzx  rax,BYTE PTR [rsi]
    1952:	cmp    al,0x2
    1954:	sete   r8b
    1958:	test   r8b,r8b
    195b:	jne    197b <botlish_fn_12+0x6b>
    1961:	mov    rdx,QWORD PTR [rdi+0x10]
    1965:	mov    rcx,QWORD PTR [rdx+0xe0]
    196c:	mov    edx,0x1
    1971:	call   1976 <botlish_fn_12+0x66>
			1972: R_X86_64_PLT32	rt_type_error-0x4
    1976:	jmp    1b10 <botlish_fn_12+0x200>
    197b:	mov    r13,rsi
    197e:	mov    r14,rdi
    1981:	call   1986 <botlish_fn_12+0x76>
			1982: R_X86_64_PLT32	rt_str_len-0x4
    1986:	mov    rbx,rax
    1989:	mov    QWORD PTR [rsp+0x8],rax
    198e:	mov    edx,0x1
    1993:	mov    r15,rdx
    1996:	mov    QWORD PTR [rsp+0x10],0x1
    199f:	mov    rcx,r13
    19a2:	mov    rdx,rbx
    19a5:	mov    rsi,r15
    19a8:	mov    rdi,r14
    19ab:	call   19b0 <botlish_fn_12+0xa0>
			19ac: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_local<generic>
    19b0:	mov    r12,rax
    19b3:	test   r12,r12
    19b6:	je     1b10 <botlish_fn_12+0x200>
    19bc:	mov    QWORD PTR [rsp+0x10],r12
    19c1:	test   r12,0x1
    19c8:	jne    19f1 <botlish_fn_12+0xe1>
    19ce:	mov    rdx,r15
    19d1:	mov    rsi,r12
    19d4:	mov    rdi,r14
    19d7:	call   19dc <botlish_fn_12+0xcc>
			19d8: R_X86_64_PLT32	rt_int_cmp-0x4
    19dc:	mov    ecx,0x2
    19e1:	test   rax,rax
    19e4:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 1bb8 <botlish_fn_12+0x2a8>
    19ec:	jmp    1a02 <botlish_fn_12+0xf2>
    19f1:	mov    ecx,0x2
    19f6:	cmp    r12,0x1
    19fa:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 1bb8 <botlish_fn_12+0x2a8>
    1a02:	cmp    rcx,0x6
    1a06:	je     1b90 <botlish_fn_12+0x280>
    1a0c:	mov    rax,r12
    1a0f:	and    rax,rbx
    1a12:	test   rax,0x1
    1a18:	jne    1a41 <botlish_fn_12+0x131>
    1a1e:	mov    rdx,rbx
    1a21:	mov    rsi,r12
    1a24:	mov    rdi,r14
    1a27:	call   1a2c <botlish_fn_12+0x11c>
			1a28: R_X86_64_PLT32	rt_int_cmp-0x4
    1a2c:	mov    ecx,0x2
    1a31:	test   rax,rax
    1a34:	cmovge rcx,QWORD PTR [rip+0x17c]        # 1bb8 <botlish_fn_12+0x2a8>
    1a3c:	jmp    1a51 <botlish_fn_12+0x141>
    1a41:	mov    ecx,0x2
    1a46:	cmp    r12,rbx
    1a49:	cmovge rcx,QWORD PTR [rip+0x167]        # 1bb8 <botlish_fn_12+0x2a8>
    1a51:	cmp    rcx,0x6
    1a55:	je     1b86 <botlish_fn_12+0x276>
    1a5b:	lea    rcx,[rsp+0x20]
    1a60:	mov    rdx,r13
    1a63:	mov    rsi,r12
    1a66:	mov    rdi,r14
    1a69:	call   1a6e <botlish_fn_12+0x15e>
			1a6a: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    1a6e:	test   rax,rax
    1a71:	mov    rsi,rax
    1a74:	je     1b10 <botlish_fn_12+0x200>
    1a7a:	mov    rdx,QWORD PTR [rsp+0x20]
    1a7f:	mov    rcx,QWORD PTR [rsp+0x28]
    1a84:	mov    rdi,r14
    1a87:	mov    rax,QWORD PTR [rdi+0x10]
    1a8b:	mov    r8,QWORD PTR [rax+0x108]
    1a92:	call   1a97 <botlish_fn_12+0x187>
			1a93: R_X86_64_PLT32	rt_str_region_eq-0x4
    1a97:	cmp    rax,0x6
    1a9b:	je     1aae <botlish_fn_12+0x19e>
    1aa1:	mov    ecx,0x2
    1aa6:	mov    rax,rcx
    1aa9:	jmp    1b95 <botlish_fn_12+0x285>
    1aae:	mov    QWORD PTR [rsp+0x18],0x3
    1ab7:	test   r12,0x1
    1abe:	jne    1acc <botlish_fn_12+0x1bc>
    1ac4:	mov    rdi,r12
    1ac7:	jmp    1ae1 <botlish_fn_12+0x1d1>
    1acc:	mov    rsi,r12
    1acf:	add    rsi,0x2
    1ad3:	mov    rdi,r12
    1ad6:	seto   al
    1ad9:	test   al,al
    1adb:	je     1af4 <botlish_fn_12+0x1e4>
    1ae1:	mov    edx,0x3
    1ae6:	mov    rsi,rdi
    1ae9:	mov    rdi,r14
    1aec:	call   1af1 <botlish_fn_12+0x1e1>
			1aed: R_X86_64_PLT32	rt_int_add-0x4
    1af1:	mov    rsi,rax
    1af4:	mov    QWORD PTR [rsp+0x10],rsi
    1af9:	mov    rcx,r13
    1afc:	mov    rdx,rbx
    1aff:	mov    rdi,r14
    1b02:	call   1b07 <botlish_fn_12+0x1f7>
			1b03: R_X86_64_PLT32	botlish_fn_18-0x4 ; domain_loop<generic>
    1b07:	test   rax,rax
    1b0a:	jne    1b35 <botlish_fn_12+0x225>
    1b10:	xor    rax,rax
    1b13:	mov    rbx,QWORD PTR [rsp+0x30]
    1b18:	mov    r12,QWORD PTR [rsp+0x38]
    1b1d:	mov    r13,QWORD PTR [rsp+0x40]
    1b22:	mov    r14,QWORD PTR [rsp+0x48]
    1b27:	mov    r15,QWORD PTR [rsp+0x50]
    1b2c:	add    rsp,0x60
    1b30:	mov    rsp,rbp
    1b33:	pop    rbp
    1b34:	ret
    1b35:	mov    rcx,rax
    1b38:	and    rcx,rbx
    1b3b:	mov    rsi,rax
    1b3e:	test   rcx,0x1
    1b45:	jne    1b6e <botlish_fn_12+0x25e>
    1b4b:	mov    rdx,rbx
    1b4e:	mov    rdi,r14
    1b51:	call   1b56 <botlish_fn_12+0x246>
			1b52: R_X86_64_PLT32	rt_int_cmp-0x4
    1b56:	mov    ecx,0x2
    1b5b:	test   rax,rax
    1b5e:	mov    rax,rcx
    1b61:	cmove  rax,QWORD PTR [rip+0x4f]        # 1bb8 <botlish_fn_12+0x2a8>
    1b69:	jmp    1b95 <botlish_fn_12+0x285>
    1b6e:	mov    rdx,rbx
    1b71:	mov    eax,0x2
    1b76:	cmp    rsi,rdx
    1b79:	cmove  rax,QWORD PTR [rip+0x37]        # 1bb8 <botlish_fn_12+0x2a8>
    1b81:	jmp    1b95 <botlish_fn_12+0x285>
    1b86:	mov    eax,0x2
    1b8b:	jmp    1b95 <botlish_fn_12+0x285>
    1b90:	mov    eax,0x2
    1b95:	mov    rbx,QWORD PTR [rsp+0x30]
    1b9a:	mov    r12,QWORD PTR [rsp+0x38]
    1b9f:	mov    r13,QWORD PTR [rsp+0x40]
    1ba4:	mov    r14,QWORD PTR [rsp+0x48]
    1ba9:	mov    r15,QWORD PTR [rsp+0x50]
    1bae:	add    rsp,0x60
    1bb2:	mov    rsp,rbp
    1bb5:	pop    rbp
    1bb6:	ret
    1bb7:	add    BYTE PTR [rsi],al
    1bb9:	add    BYTE PTR [rax],al
    1bbb:	add    BYTE PTR [rax],al
    1bbd:	add    BYTE PTR [rax],al
	...

0000000000001bc0 <botlish_entry_12: <generic>>:
    1bc0:	push   rbp
    1bc1:	mov    rbp,rsp
    1bc4:	mov    rsi,QWORD PTR [rdx]
    1bc7:	call   1bcc <botlish_entry_12+0xc>
			1bc8: R_X86_64_PLT32	botlish_fn_12-0x4 ; <generic>
    1bcc:	mov    rsp,rbp
    1bcf:	pop    rbp
    1bd0:	ret

0000000000001bd1 <botlish_fn_13: char_at<generic>>:
    1bd1:	push   rbp
    1bd2:	mov    rbp,rsp
    1bd5:	sub    rsp,0x50
    1bd9:	mov    QWORD PTR [rsp+0x20],rbx
    1bde:	mov    QWORD PTR [rsp+0x28],r12
    1be3:	mov    QWORD PTR [rsp+0x30],r13
    1be8:	mov    QWORD PTR [rsp+0x38],r14
    1bed:	mov    QWORD PTR [rsp+0x40],r15
    1bf2:	mov    r14,rcx
    1bf5:	mov    QWORD PTR [rsp],rsi
    1bf9:	mov    QWORD PTR [rsp+0x8],rdx
    1bfe:	mov    r13,rdx
    1c01:	mov    QWORD PTR [rsp+0x10],0x3
    1c0a:	mov    r9d,0x1
    1c10:	test   rsi,0x1
    1c17:	jne    1c37 <botlish_fn_13+0x66>
    1c1d:	xor    r9d,r9d
    1c20:	test   rsi,0x7
    1c27:	jne    1c37 <botlish_fn_13+0x66>
    1c2d:	movzx  rax,BYTE PTR [rsi]
    1c31:	cmp    al,0x1
    1c33:	sete   r9b
    1c37:	test   r9b,r9b
    1c3a:	jne    1c58 <botlish_fn_13+0x87>
    1c40:	mov    rax,QWORD PTR [rdi+0x10]
    1c44:	mov    rcx,QWORD PTR [rax+0x110]
    1c4b:	xor    rdx,rdx
    1c4e:	call   1c53 <botlish_fn_13+0x82>
			1c4f: R_X86_64_PLT32	rt_type_error-0x4
    1c53:	jmp    1d15 <botlish_fn_13+0x144>
    1c58:	mov    r12,rdi
    1c5b:	test   rsi,0x1
    1c62:	jne    1c70 <botlish_fn_13+0x9f>
    1c68:	mov    rbx,rsi
    1c6b:	jmp    1c8d <botlish_fn_13+0xbc>
    1c70:	mov    rax,rsi
    1c73:	add    rax,0x2
    1c77:	mov    rbx,rsi
    1c7a:	seto   cl
    1c7d:	test   cl,cl
    1c7f:	jne    1c8d <botlish_fn_13+0xbc>
    1c85:	mov    r15,rax
    1c88:	jmp    1ca0 <botlish_fn_13+0xcf>
    1c8d:	mov    edx,0x3
    1c92:	mov    rsi,rbx
    1c95:	mov    rdi,r12
    1c98:	call   1c9d <botlish_fn_13+0xcc>
			1c99: R_X86_64_PLT32	rt_int_add-0x4
    1c9d:	mov    r15,rax
    1ca0:	mov    ecx,0x1
    1ca5:	mov    rsi,rbx
    1ca8:	test   rsi,0x1
    1caf:	jne    1cd5 <botlish_fn_13+0x104>
    1cb5:	xor    ecx,ecx
    1cb7:	mov    rsi,rbx
    1cba:	test   rsi,0x7
    1cc1:	jne    1cd5 <botlish_fn_13+0x104>
    1cc7:	mov    rsi,rbx
    1cca:	movzx  rcx,BYTE PTR [rsi]
    1cce:	rex cmp cl,0x1
    1cd2:	sete   cl
    1cd5:	test   cl,cl
    1cd7:	jne    1cfb <botlish_fn_13+0x12a>
    1cdd:	mov    rdi,r12
    1ce0:	mov    rsi,QWORD PTR [rdi+0x10]
    1ce4:	mov    rcx,QWORD PTR [rsi+0x118]
    1ceb:	xor    rdx,rdx
    1cee:	mov    rsi,rbx
    1cf1:	call   1cf6 <botlish_fn_13+0x125>
			1cf2: R_X86_64_PLT32	rt_type_error-0x4
    1cf6:	jmp    1d15 <botlish_fn_13+0x144>
    1cfb:	mov    rdi,r12
    1cfe:	mov    rcx,r15
    1d01:	mov    rdx,rbx
    1d04:	mov    rsi,r13
    1d07:	call   1d0c <botlish_fn_13+0x13b>
			1d08: R_X86_64_PLT32	rt_str_region_check-0x4
    1d0c:	test   rax,rax
    1d0f:	jne    1d3a <botlish_fn_13+0x169>
    1d15:	xor    rax,rax
    1d18:	mov    rbx,QWORD PTR [rsp+0x20]
    1d1d:	mov    r12,QWORD PTR [rsp+0x28]
    1d22:	mov    r13,QWORD PTR [rsp+0x30]
    1d27:	mov    r14,QWORD PTR [rsp+0x38]
    1d2c:	mov    r15,QWORD PTR [rsp+0x40]
    1d31:	add    rsp,0x50
    1d35:	mov    rsp,rbp
    1d38:	pop    rbp
    1d39:	ret
    1d3a:	mov    rcx,r14
    1d3d:	mov    rsi,rbx
    1d40:	mov    QWORD PTR [rcx],rsi
    1d43:	mov    rax,r15
    1d46:	mov    QWORD PTR [rcx+0x8],rax
    1d4a:	mov    rax,r13
    1d4d:	mov    rbx,QWORD PTR [rsp+0x20]
    1d52:	mov    r12,QWORD PTR [rsp+0x28]
    1d57:	mov    r13,QWORD PTR [rsp+0x30]
    1d5c:	mov    r14,QWORD PTR [rsp+0x38]
    1d61:	mov    r15,QWORD PTR [rsp+0x40]
    1d66:	add    rsp,0x50
    1d6a:	mov    rsp,rbp
    1d6d:	pop    rbp
    1d6e:	ret

0000000000001d6f <botlish_entry_13: char_at<generic>>:
    1d6f:	push   rbp
    1d70:	mov    rbp,rsp
    1d73:	ud2
    1d75:	add    BYTE PTR [rax],al
	...

0000000000001d78 <botlish_fn_14: scan_local<generic>>:
    1d78:	push   rbp
    1d79:	mov    rbp,rsp
    1d7c:	sub    rsp,0x80
    1d83:	mov    QWORD PTR [rsp+0x50],rbx
    1d88:	mov    QWORD PTR [rsp+0x58],r12
    1d8d:	mov    QWORD PTR [rsp+0x60],r13
    1d92:	mov    QWORD PTR [rsp+0x68],r14
    1d97:	mov    QWORD PTR [rsp+0x70],r15
    1d9c:	mov    rax,rdi
    1d9f:	mov    QWORD PTR [rsp+0x18],0x0
    1da8:	mov    QWORD PTR [rsp],rsi
    1dac:	mov    r14,rsi
    1daf:	mov    QWORD PTR [rsp+0x8],rdx
    1db4:	mov    QWORD PTR [rsp+0x10],rcx
    1db9:	mov    r12,rcx
    1dbc:	mov    r11d,0x1
    1dc2:	mov    rsi,r14
    1dc5:	test   rsi,0x1
    1dcc:	jne    1dee <botlish_fn_14+0x76>
    1dd2:	xor    r11d,r11d
    1dd5:	test   rsi,0x7
    1ddc:	jne    1dee <botlish_fn_14+0x76>
    1de2:	movzx  rdi,BYTE PTR [rsi]
    1de6:	cmp    dil,0x1
    1dea:	sete   r11b
    1dee:	test   r11b,r11b
    1df1:	jne    1e12 <botlish_fn_14+0x9a>
    1df7:	mov    rdi,rax
    1dfa:	mov    r9,QWORD PTR [rdi+0x10]
    1dfe:	mov    rcx,QWORD PTR [r9+0xc0]
    1e05:	xor    rdx,rdx
    1e08:	call   1e0d <botlish_fn_14+0x95>
			1e09: R_X86_64_PLT32	rt_type_error-0x4
    1e0d:	jmp    1ec5 <botlish_fn_14+0x14d>
    1e12:	mov    r13,rdx
    1e15:	mov    r10,rsi
    1e18:	and    r10,r13
    1e1b:	mov    r14,rsi
    1e1e:	test   r10,0x1
    1e25:	jne    1e51 <botlish_fn_14+0xd9>
    1e2b:	mov    rbx,rax
    1e2e:	mov    rdx,r13
    1e31:	mov    rsi,r14
    1e34:	mov    rdi,rbx
    1e37:	call   1e3c <botlish_fn_14+0xc4>
			1e38: R_X86_64_PLT32	rt_int_cmp-0x4
    1e3c:	mov    ecx,0x2
    1e41:	test   rax,rax
    1e44:	cmovge rcx,QWORD PTR [rip+0x24c]        # 2098 <botlish_fn_14+0x320>
    1e4c:	jmp    1e67 <botlish_fn_14+0xef>
    1e51:	mov    rbx,rax
    1e54:	mov    ecx,0x2
    1e59:	mov    rsi,r14
    1e5c:	cmp    rsi,r13
    1e5f:	cmovge rcx,QWORD PTR [rip+0x231]        # 2098 <botlish_fn_14+0x320>
    1e67:	mov    eax,0x6
    1e6c:	mov    QWORD PTR [rsp+0x30],rax
    1e71:	cmp    rcx,0x6
    1e75:	je     206b <botlish_fn_14+0x2f3>
    1e7b:	lea    rcx,[rsp+0x20]
    1e80:	mov    rdx,r12
    1e83:	mov    rsi,r14
    1e86:	mov    rdi,rbx
    1e89:	call   1e8e <botlish_fn_14+0x116>
			1e8a: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    1e8e:	mov    rsi,rax
    1e91:	mov    r15,rax
    1e94:	test   rax,rsi
    1e97:	je     1ec5 <botlish_fn_14+0x14d>
    1e9d:	mov    rdx,QWORD PTR [rsp+0x20]
    1ea2:	mov    QWORD PTR [rsp+0x40],rdx
    1ea7:	mov    rcx,QWORD PTR [rsp+0x28]
    1eac:	mov    QWORD PTR [rsp+0x38],rcx
    1eb1:	mov    rsi,r15
    1eb4:	mov    rdi,rbx
    1eb7:	call   1ebc <botlish_fn_14+0x144>
			1eb8: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1ebc:	test   rax,rax
    1ebf:	jne    1eed <botlish_fn_14+0x175>
    1ec5:	xor    rax,rax
    1ec8:	mov    rbx,QWORD PTR [rsp+0x50]
    1ecd:	mov    r12,QWORD PTR [rsp+0x58]
    1ed2:	mov    r13,QWORD PTR [rsp+0x60]
    1ed7:	mov    r14,QWORD PTR [rsp+0x68]
    1edc:	mov    r15,QWORD PTR [rsp+0x70]
    1ee1:	add    rsp,0x80
    1ee8:	mov    rsp,rbp
    1eeb:	pop    rbp
    1eec:	ret
    1eed:	cmp    rax,0x6
    1ef1:	je     1fec <botlish_fn_14+0x274>
    1ef7:	mov    rax,QWORD PTR [rbx+0x10]
    1efb:	mov    r8,QWORD PTR [rax+0x120]
    1f02:	mov    rcx,QWORD PTR [rsp+0x38]
    1f07:	mov    rdx,QWORD PTR [rsp+0x40]
    1f0c:	mov    rsi,r15
    1f0f:	mov    rdi,rbx
    1f12:	call   1f17 <botlish_fn_14+0x19f>
			1f13: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f17:	cmp    rax,0x6
    1f1b:	je     1fe2 <botlish_fn_14+0x26a>
    1f21:	mov    rax,QWORD PTR [rbx+0x10]
    1f25:	mov    r8,QWORD PTR [rax+0x128]
    1f2c:	mov    rcx,QWORD PTR [rsp+0x38]
    1f31:	mov    rdx,QWORD PTR [rsp+0x40]
    1f36:	mov    rsi,r15
    1f39:	mov    rdi,rbx
    1f3c:	call   1f41 <botlish_fn_14+0x1c9>
			1f3d: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f41:	cmp    rax,0x6
    1f45:	je     1fd8 <botlish_fn_14+0x260>
    1f4b:	mov    rax,QWORD PTR [rbx+0x10]
    1f4f:	mov    r8,QWORD PTR [rax+0xc8]
    1f56:	mov    rcx,QWORD PTR [rsp+0x38]
    1f5b:	mov    rdx,QWORD PTR [rsp+0x40]
    1f60:	mov    rsi,r15
    1f63:	mov    rdi,rbx
    1f66:	call   1f6b <botlish_fn_14+0x1f3>
			1f67: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f6b:	cmp    rax,0x6
    1f6f:	je     1fce <botlish_fn_14+0x256>
    1f75:	mov    rax,QWORD PTR [rbx+0x10]
    1f79:	mov    r8,QWORD PTR [rax+0x110]
    1f80:	mov    rcx,QWORD PTR [rsp+0x38]
    1f85:	mov    rdx,QWORD PTR [rsp+0x40]
    1f8a:	mov    rsi,r15
    1f8d:	mov    rdi,rbx
    1f90:	call   1f95 <botlish_fn_14+0x21d>
			1f91: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f95:	cmp    rax,0x6
    1f99:	je     1fc4 <botlish_fn_14+0x24c>
    1f9f:	mov    rax,QWORD PTR [rbx+0x10]
    1fa3:	mov    r8,QWORD PTR [rax+0x130]
    1faa:	mov    rcx,QWORD PTR [rsp+0x38]
    1faf:	mov    rdx,QWORD PTR [rsp+0x40]
    1fb4:	mov    rsi,r15
    1fb7:	mov    rdi,rbx
    1fba:	call   1fbf <botlish_fn_14+0x247>
			1fbb: R_X86_64_PLT32	rt_str_region_eq-0x4
    1fbf:	jmp    1ff1 <botlish_fn_14+0x279>
    1fc4:	mov    rax,QWORD PTR [rsp+0x30]
    1fc9:	jmp    1ff1 <botlish_fn_14+0x279>
    1fce:	mov    rax,QWORD PTR [rsp+0x30]
    1fd3:	jmp    1ff1 <botlish_fn_14+0x279>
    1fd8:	mov    rax,QWORD PTR [rsp+0x30]
    1fdd:	jmp    1ff1 <botlish_fn_14+0x279>
    1fe2:	mov    rax,QWORD PTR [rsp+0x30]
    1fe7:	jmp    1ff1 <botlish_fn_14+0x279>
    1fec:	mov    rax,QWORD PTR [rsp+0x30]
    1ff1:	cmp    rax,0x6
    1ff5:	je     2003 <botlish_fn_14+0x28b>
    1ffb:	mov    rax,r14
    1ffe:	jmp    206e <botlish_fn_14+0x2f6>
    2003:	mov    QWORD PTR [rsp+0x18],0x3
    200c:	mov    rsi,r14
    200f:	test   rsi,0x1
    2016:	je     203c <botlish_fn_14+0x2c4>
    201c:	mov    rsi,r14
    201f:	mov    rax,rsi
    2022:	add    rax,0x2
    2026:	seto   cl
    2029:	test   cl,cl
    202b:	jne    203c <botlish_fn_14+0x2c4>
    2031:	mov    rsi,rax
    2034:	mov    r14,rax
    2037:	jmp    2052 <botlish_fn_14+0x2da>
    203c:	mov    edx,0x3
    2041:	mov    rsi,r14
    2044:	mov    rdi,rbx
    2047:	call   204c <botlish_fn_14+0x2d4>
			2048: R_X86_64_PLT32	rt_int_add-0x4
    204c:	mov    rsi,rax
    204f:	mov    r14,rax
    2052:	mov    QWORD PTR [rsp],rsi
    2056:	mov    QWORD PTR [rsp+0x8],r13
    205b:	mov    QWORD PTR [rsp+0x10],r12
    2060:	mov    rax,rbx
    2063:	mov    rdx,r13
    2066:	jmp    1dbc <botlish_fn_14+0x44>
    206b:	mov    rax,r14
    206e:	mov    rbx,QWORD PTR [rsp+0x50]
    2073:	mov    r12,QWORD PTR [rsp+0x58]
    2078:	mov    r13,QWORD PTR [rsp+0x60]
    207d:	mov    r14,QWORD PTR [rsp+0x68]
    2082:	mov    r15,QWORD PTR [rsp+0x70]
    2087:	add    rsp,0x80
    208e:	mov    rsp,rbp
    2091:	pop    rbp
    2092:	ret
    2093:	add    BYTE PTR [rax],al
    2095:	add    BYTE PTR [rax],al
    2097:	add    BYTE PTR [rsi],al
    2099:	add    BYTE PTR [rax],al
    209b:	add    BYTE PTR [rax],al
    209d:	add    BYTE PTR [rax],al
	...

00000000000020a0 <botlish_entry_14: scan_local<generic>>:
    20a0:	push   rbp
    20a1:	mov    rbp,rsp
    20a4:	mov    rsi,QWORD PTR [rdx]
    20a7:	mov    r8,QWORD PTR [rdx+0x8]
    20ab:	mov    rcx,QWORD PTR [rdx+0x10]
    20af:	mov    rdx,r8
    20b2:	call   20b7 <botlish_entry_14+0x17>
			20b3: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_local<generic>
    20b7:	mov    rsp,rbp
    20ba:	pop    rbp
    20bb:	ret
    20bc:	add    BYTE PTR [rax],al
	...

00000000000020c0 <botlish_fn_15: scan_label<generic>>:
    20c0:	push   rbp
    20c1:	mov    rbp,rsp
    20c4:	sub    rsp,0x80
    20cb:	mov    QWORD PTR [rsp+0x50],rbx
    20d0:	mov    QWORD PTR [rsp+0x58],r12
    20d5:	mov    QWORD PTR [rsp+0x60],r13
    20da:	mov    QWORD PTR [rsp+0x68],r14
    20df:	mov    QWORD PTR [rsp+0x70],r15
    20e4:	mov    QWORD PTR [rsp+0x18],0x0
    20ed:	mov    QWORD PTR [rsp],rsi
    20f1:	mov    r14,rsi
    20f4:	mov    QWORD PTR [rsp+0x8],rdx
    20f9:	mov    QWORD PTR [rsp+0x10],rcx
    20fe:	mov    r12,rcx
    2101:	mov    r11d,0x1
    2107:	mov    rsi,r14
    210a:	test   rsi,0x1
    2111:	jne    2131 <botlish_fn_15+0x71>
    2117:	xor    r11d,r11d
    211a:	test   rsi,0x7
    2121:	jne    2131 <botlish_fn_15+0x71>
    2127:	movzx  rax,BYTE PTR [rsi]
    212b:	cmp    al,0x1
    212d:	sete   r11b
    2131:	test   r11b,r11b
    2134:	jne    2152 <botlish_fn_15+0x92>
    213a:	mov    rax,QWORD PTR [rdi+0x10]
    213e:	mov    rcx,QWORD PTR [rax+0xc0]
    2145:	xor    rdx,rdx
    2148:	call   214d <botlish_fn_15+0x8d>
			2149: R_X86_64_PLT32	rt_type_error-0x4
    214d:	jmp    21fe <botlish_fn_15+0x13e>
    2152:	mov    r13,rdx
    2155:	mov    rax,rsi
    2158:	and    rax,r13
    215b:	mov    r14,rsi
    215e:	test   rax,0x1
    2164:	jne    218d <botlish_fn_15+0xcd>
    216a:	mov    rbx,rdi
    216d:	mov    rdx,r13
    2170:	mov    rsi,r14
    2173:	call   2178 <botlish_fn_15+0xb8>
			2174: R_X86_64_PLT32	rt_int_cmp-0x4
    2178:	mov    ecx,0x2
    217d:	test   rax,rax
    2180:	cmovge rcx,QWORD PTR [rip+0x178]        # 2300 <botlish_fn_15+0x240>
    2188:	jmp    21a3 <botlish_fn_15+0xe3>
    218d:	mov    rbx,rdi
    2190:	mov    ecx,0x2
    2195:	mov    rsi,r14
    2198:	cmp    rsi,r13
    219b:	cmovge rcx,QWORD PTR [rip+0x15d]        # 2300 <botlish_fn_15+0x240>
    21a3:	mov    eax,0x6
    21a8:	mov    QWORD PTR [rsp+0x30],rax
    21ad:	cmp    rcx,0x6
    21b1:	je     22d4 <botlish_fn_15+0x214>
    21b7:	lea    rcx,[rsp+0x20]
    21bc:	mov    rdx,r12
    21bf:	mov    rsi,r14
    21c2:	mov    rdi,rbx
    21c5:	call   21ca <botlish_fn_15+0x10a>
			21c6: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    21ca:	test   rax,rax
    21cd:	mov    r15,rax
    21d0:	je     21fe <botlish_fn_15+0x13e>
    21d6:	mov    rdx,QWORD PTR [rsp+0x20]
    21db:	mov    QWORD PTR [rsp+0x40],rdx
    21e0:	mov    rcx,QWORD PTR [rsp+0x28]
    21e5:	mov    QWORD PTR [rsp+0x38],rcx
    21ea:	mov    rsi,r15
    21ed:	mov    rdi,rbx
    21f0:	call   21f5 <botlish_fn_15+0x135>
			21f1: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    21f5:	test   rax,rax
    21f8:	jne    2226 <botlish_fn_15+0x166>
    21fe:	xor    rax,rax
    2201:	mov    rbx,QWORD PTR [rsp+0x50]
    2206:	mov    r12,QWORD PTR [rsp+0x58]
    220b:	mov    r13,QWORD PTR [rsp+0x60]
    2210:	mov    r14,QWORD PTR [rsp+0x68]
    2215:	mov    r15,QWORD PTR [rsp+0x70]
    221a:	add    rsp,0x80
    2221:	mov    rsp,rbp
    2224:	pop    rbp
    2225:	ret
    2226:	cmp    rax,0x6
    222a:	je     2255 <botlish_fn_15+0x195>
    2230:	mov    r11,QWORD PTR [rbx+0x10]
    2234:	mov    r8,QWORD PTR [r11+0x130]
    223b:	mov    rcx,QWORD PTR [rsp+0x38]
    2240:	mov    rdx,QWORD PTR [rsp+0x40]
    2245:	mov    rsi,r15
    2248:	mov    rdi,rbx
    224b:	call   2250 <botlish_fn_15+0x190>
			224c: R_X86_64_PLT32	rt_str_region_eq-0x4
    2250:	jmp    225a <botlish_fn_15+0x19a>
    2255:	mov    rax,QWORD PTR [rsp+0x30]
    225a:	cmp    rax,0x6
    225e:	je     226c <botlish_fn_15+0x1ac>
    2264:	mov    rax,r14
    2267:	jmp    22d7 <botlish_fn_15+0x217>
    226c:	mov    QWORD PTR [rsp+0x18],0x3
    2275:	mov    rsi,r14
    2278:	test   rsi,0x1
    227f:	je     22a5 <botlish_fn_15+0x1e5>
    2285:	mov    rsi,r14
    2288:	mov    rax,rsi
    228b:	add    rax,0x2
    228f:	seto   cl
    2292:	test   cl,cl
    2294:	jne    22a5 <botlish_fn_15+0x1e5>
    229a:	mov    rsi,rax
    229d:	mov    r14,rax
    22a0:	jmp    22bb <botlish_fn_15+0x1fb>
    22a5:	mov    edx,0x3
    22aa:	mov    rsi,r14
    22ad:	mov    rdi,rbx
    22b0:	call   22b5 <botlish_fn_15+0x1f5>
			22b1: R_X86_64_PLT32	rt_int_add-0x4
    22b5:	mov    rsi,rax
    22b8:	mov    r14,rax
    22bb:	mov    QWORD PTR [rsp],rsi
    22bf:	mov    QWORD PTR [rsp+0x8],r13
    22c4:	mov    QWORD PTR [rsp+0x10],r12
    22c9:	mov    rdx,r13
    22cc:	mov    rdi,rbx
    22cf:	jmp    2101 <botlish_fn_15+0x41>
    22d4:	mov    rax,r14
    22d7:	mov    rbx,QWORD PTR [rsp+0x50]
    22dc:	mov    r12,QWORD PTR [rsp+0x58]
    22e1:	mov    r13,QWORD PTR [rsp+0x60]
    22e6:	mov    r14,QWORD PTR [rsp+0x68]
    22eb:	mov    r15,QWORD PTR [rsp+0x70]
    22f0:	add    rsp,0x80
    22f7:	mov    rsp,rbp
    22fa:	pop    rbp
    22fb:	ret
    22fc:	add    BYTE PTR [rax],al
    22fe:	add    BYTE PTR [rax],al
    2300:	(bad)
    2301:	add    BYTE PTR [rax],al
    2303:	add    BYTE PTR [rax],al
    2305:	add    BYTE PTR [rax],al
	...

0000000000002308 <botlish_entry_15: scan_label<generic>>:
    2308:	push   rbp
    2309:	mov    rbp,rsp
    230c:	mov    rsi,QWORD PTR [rdx]
    230f:	mov    r8,QWORD PTR [rdx+0x8]
    2313:	mov    rcx,QWORD PTR [rdx+0x10]
    2317:	mov    rdx,r8
    231a:	call   231f <botlish_entry_15+0x17>
			231b: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_label<generic>
    231f:	mov    rsp,rbp
    2322:	pop    rbp
    2323:	ret
    2324:	add    BYTE PTR [rax],al
	...

0000000000002328 <botlish_fn_16: scan_alpha<generic>>:
    2328:	push   rbp
    2329:	mov    rbp,rsp
    232c:	sub    rsp,0x50
    2330:	mov    QWORD PTR [rsp+0x30],rbx
    2335:	mov    QWORD PTR [rsp+0x38],r12
    233a:	mov    QWORD PTR [rsp+0x40],r13
    233f:	mov    QWORD PTR [rsp+0x48],r14
    2344:	mov    r14,rdi
    2347:	mov    QWORD PTR [rsp+0x18],0x0
    2350:	mov    QWORD PTR [rsp],rsi
    2354:	mov    r13,rsi
    2357:	mov    QWORD PTR [rsp+0x8],rdx
    235c:	mov    r12,rdx
    235f:	mov    QWORD PTR [rsp+0x10],rcx
    2364:	mov    rbx,rcx
    2367:	mov    r11d,0x1
    236d:	mov    rsi,r13
    2370:	test   rsi,0x1
    2377:	jne    2397 <botlish_fn_16+0x6f>
    237d:	xor    r11d,r11d
    2380:	test   rsi,0x7
    2387:	jne    2397 <botlish_fn_16+0x6f>
    238d:	movzx  rax,BYTE PTR [rsi]
    2391:	cmp    al,0x1
    2393:	sete   r11b
    2397:	test   r11b,r11b
    239a:	jne    23bb <botlish_fn_16+0x93>
    23a0:	mov    rdi,r14
    23a3:	mov    rax,QWORD PTR [rdi+0x10]
    23a7:	mov    rcx,QWORD PTR [rax+0xc0]
    23ae:	xor    rdx,rdx
    23b1:	call   23b6 <botlish_fn_16+0x8e>
			23b2: R_X86_64_PLT32	rt_type_error-0x4
    23b6:	jmp    244a <botlish_fn_16+0x122>
    23bb:	mov    rax,rsi
    23be:	and    rax,r12
    23c1:	mov    r13,rsi
    23c4:	test   rax,0x1
    23ca:	jne    23f3 <botlish_fn_16+0xcb>
    23d0:	mov    rdx,r12
    23d3:	mov    rsi,r13
    23d6:	mov    rdi,r14
    23d9:	call   23de <botlish_fn_16+0xb6>
			23da: R_X86_64_PLT32	rt_int_cmp-0x4
    23de:	mov    ecx,0x2
    23e3:	test   rax,rax
    23e6:	cmovge rcx,QWORD PTR [rip+0x112]        # 2500 <botlish_fn_16+0x1d8>
    23ee:	jmp    2406 <botlish_fn_16+0xde>
    23f3:	mov    ecx,0x2
    23f8:	mov    rsi,r13
    23fb:	cmp    rsi,r12
    23fe:	cmovge rcx,QWORD PTR [rip+0xfa]        # 2500 <botlish_fn_16+0x1d8>
    2406:	cmp    rcx,0x6
    240a:	je     24de <botlish_fn_16+0x1b6>
    2410:	lea    rcx,[rsp+0x20]
    2415:	mov    rdx,rbx
    2418:	mov    rsi,r13
    241b:	mov    rdi,r14
    241e:	call   2423 <botlish_fn_16+0xfb>
			241f: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    2423:	test   rax,rax
    2426:	mov    rsi,rax
    2429:	je     244a <botlish_fn_16+0x122>
    242f:	mov    rdx,QWORD PTR [rsp+0x20]
    2434:	mov    rcx,QWORD PTR [rsp+0x28]
    2439:	mov    rdi,r14
    243c:	call   2441 <botlish_fn_16+0x119>
			243d: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    2441:	test   rax,rax
    2444:	jne    246a <botlish_fn_16+0x142>
    244a:	xor    rax,rax
    244d:	mov    rbx,QWORD PTR [rsp+0x30]
    2452:	mov    r12,QWORD PTR [rsp+0x38]
    2457:	mov    r13,QWORD PTR [rsp+0x40]
    245c:	mov    r14,QWORD PTR [rsp+0x48]
    2461:	add    rsp,0x50
    2465:	mov    rsp,rbp
    2468:	pop    rbp
    2469:	ret
    246a:	cmp    rax,0x6
    246e:	je     247c <botlish_fn_16+0x154>
    2474:	mov    rax,r13
    2477:	jmp    24e1 <botlish_fn_16+0x1b9>
    247c:	mov    QWORD PTR [rsp+0x18],0x3
    2485:	mov    rsi,r13
    2488:	test   rsi,0x1
    248f:	je     24b5 <botlish_fn_16+0x18d>
    2495:	mov    rsi,r13
    2498:	mov    r11,rsi
    249b:	add    r11,0x2
    249f:	seto   al
    24a2:	test   al,al
    24a4:	jne    24b5 <botlish_fn_16+0x18d>
    24aa:	mov    rsi,r11
    24ad:	mov    r13,r11
    24b0:	jmp    24cb <botlish_fn_16+0x1a3>
    24b5:	mov    edx,0x3
    24ba:	mov    rsi,r13
    24bd:	mov    rdi,r14
    24c0:	call   24c5 <botlish_fn_16+0x19d>
			24c1: R_X86_64_PLT32	rt_int_add-0x4
    24c5:	mov    rsi,rax
    24c8:	mov    r13,rax
    24cb:	mov    QWORD PTR [rsp],rsi
    24cf:	mov    QWORD PTR [rsp+0x8],r12
    24d4:	mov    QWORD PTR [rsp+0x10],rbx
    24d9:	jmp    2367 <botlish_fn_16+0x3f>
    24de:	mov    rax,r13
    24e1:	mov    rbx,QWORD PTR [rsp+0x30]
    24e6:	mov    r12,QWORD PTR [rsp+0x38]
    24eb:	mov    r13,QWORD PTR [rsp+0x40]
    24f0:	mov    r14,QWORD PTR [rsp+0x48]
    24f5:	add    rsp,0x50
    24f9:	mov    rsp,rbp
    24fc:	pop    rbp
    24fd:	ret
    24fe:	add    BYTE PTR [rax],al
    2500:	(bad)
    2501:	add    BYTE PTR [rax],al
    2503:	add    BYTE PTR [rax],al
    2505:	add    BYTE PTR [rax],al
	...

0000000000002508 <botlish_entry_16: scan_alpha<generic>>:
    2508:	push   rbp
    2509:	mov    rbp,rsp
    250c:	mov    rsi,QWORD PTR [rdx]
    250f:	mov    r8,QWORD PTR [rdx+0x8]
    2513:	mov    rcx,QWORD PTR [rdx+0x10]
    2517:	mov    rdx,r8
    251a:	call   251f <botlish_entry_16+0x17>
			251b: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_alpha<generic>
    251f:	mov    rsp,rbp
    2522:	pop    rbp
    2523:	ret
    2524:	add    BYTE PTR [rax],al
	...

0000000000002528 <botlish_fn_17: tld_ok<generic>>:
    2528:	push   rbp
    2529:	mov    rbp,rsp
    252c:	sub    rsp,0x40
    2530:	mov    QWORD PTR [rsp+0x20],rbx
    2535:	mov    QWORD PTR [rsp+0x28],r12
    253a:	mov    QWORD PTR [rsp+0x30],r13
    253f:	mov    QWORD PTR [rsp+0x38],r14
    2544:	mov    rbx,rdi
    2547:	mov    QWORD PTR [rsp],rsi
    254b:	mov    r12,rsi
    254e:	mov    QWORD PTR [rsp+0x8],rdx
    2553:	mov    r14,rdx
    2556:	mov    QWORD PTR [rsp+0x10],rcx
    255b:	mov    rdx,r14
    255e:	mov    rsi,r12
    2561:	mov    rdi,rbx
    2564:	call   2569 <botlish_fn_17+0x41>
			2565: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_alpha<generic>
    2569:	mov    rsi,rax
    256c:	mov    r13,rax
    256f:	test   rax,rsi
    2572:	je     2635 <botlish_fn_17+0x10d>
    2578:	mov    rax,r13
    257b:	mov    QWORD PTR [rsp+0x8],rax
    2580:	mov    rdx,r14
    2583:	and    rax,rdx
    2586:	test   rax,0x1
    258c:	jne    25b5 <botlish_fn_17+0x8d>
    2592:	mov    rsi,r13
    2595:	mov    rdi,rbx
    2598:	call   259d <botlish_fn_17+0x75>
			2599: R_X86_64_PLT32	rt_int_cmp-0x4
    259d:	mov    ecx,0x2
    25a2:	test   rax,rax
    25a5:	cmove  rcx,QWORD PTR [rip+0x15b]        # 2708 <botlish_fn_17+0x1e0>
    25ad:	mov    rax,r13
    25b0:	jmp    25c8 <botlish_fn_17+0xa0>
    25b5:	mov    ecx,0x2
    25ba:	mov    rax,r13
    25bd:	cmp    rax,rdx
    25c0:	cmove  rcx,QWORD PTR [rip+0x140]        # 2708 <botlish_fn_17+0x1e0>
    25c8:	cmp    rcx,0x6
    25cc:	je     25df <botlish_fn_17+0xb7>
    25d2:	mov    ecx,0x2
    25d7:	mov    rax,rcx
    25da:	jmp    26e7 <botlish_fn_17+0x1bf>
    25df:	mov    ecx,0x1
    25e4:	mov    rsi,r12
    25e7:	test   rsi,0x1
    25ee:	jne    2614 <botlish_fn_17+0xec>
    25f4:	xor    ecx,ecx
    25f6:	mov    rsi,r12
    25f9:	test   rsi,0x7
    2600:	jne    2614 <botlish_fn_17+0xec>
    2606:	mov    rsi,r12
    2609:	movzx  rcx,BYTE PTR [rsi]
    260d:	rex cmp cl,0x1
    2611:	sete   cl
    2614:	test   cl,cl
    2616:	jne    2655 <botlish_fn_17+0x12d>
    261c:	mov    rdi,rbx
    261f:	mov    rsi,QWORD PTR [rdi+0x10]
    2623:	mov    rcx,QWORD PTR [rsi+0x130]
    262a:	xor    rdx,rdx
    262d:	mov    rsi,r12
    2630:	call   2635 <botlish_fn_17+0x10d>
			2631: R_X86_64_PLT32	rt_type_error-0x4
    2635:	xor    rax,rax
    2638:	mov    rbx,QWORD PTR [rsp+0x20]
    263d:	mov    r12,QWORD PTR [rsp+0x28]
    2642:	mov    r13,QWORD PTR [rsp+0x30]
    2647:	mov    r14,QWORD PTR [rsp+0x38]
    264c:	add    rsp,0x40
    2650:	mov    rsp,rbp
    2653:	pop    rbp
    2654:	ret
    2655:	mov    rsi,r12
    2658:	mov    rdi,rax
    265b:	and    rdi,rsi
    265e:	test   rdi,0x1
    2665:	jne    2676 <botlish_fn_17+0x14e>
    266b:	mov    rdx,r12
    266e:	mov    rsi,rax
    2671:	jmp    2699 <botlish_fn_17+0x171>
    2676:	mov    rsi,r12
    2679:	mov    r8,rax
    267c:	sub    r8,rsi
    267f:	mov    r13,rax
    2682:	seto   r10b
    2686:	lea    rsi,[r8+0x1]
    268a:	test   r10b,r10b
    268d:	je     26a4 <botlish_fn_17+0x17c>
    2693:	mov    rdx,r12
    2696:	mov    rsi,r13
    2699:	mov    rdi,rbx
    269c:	call   26a1 <botlish_fn_17+0x179>
			269d: R_X86_64_PLT32	rt_int_sub-0x4
    26a1:	mov    rsi,rax
    26a4:	test   rsi,0x1
    26ab:	jne    26d6 <botlish_fn_17+0x1ae>
    26b1:	mov    edx,0x5
    26b6:	mov    rdi,rbx
    26b9:	call   26be <botlish_fn_17+0x196>
			26ba: R_X86_64_PLT32	rt_int_cmp-0x4
    26be:	mov    ecx,0x2
    26c3:	test   rax,rax
    26c6:	mov    rax,rcx
    26c9:	cmovge rax,QWORD PTR [rip+0x37]        # 2708 <botlish_fn_17+0x1e0>
    26d1:	jmp    26e7 <botlish_fn_17+0x1bf>
    26d6:	mov    eax,0x2
    26db:	cmp    rsi,0x5
    26df:	cmovge rax,QWORD PTR [rip+0x21]        # 2708 <botlish_fn_17+0x1e0>
    26e7:	mov    rbx,QWORD PTR [rsp+0x20]
    26ec:	mov    r12,QWORD PTR [rsp+0x28]
    26f1:	mov    r13,QWORD PTR [rsp+0x30]
    26f6:	mov    r14,QWORD PTR [rsp+0x38]
    26fb:	add    rsp,0x40
    26ff:	mov    rsp,rbp
    2702:	pop    rbp
    2703:	ret
    2704:	add    BYTE PTR [rax],al
    2706:	add    BYTE PTR [rax],al
    2708:	(bad)
    2709:	add    BYTE PTR [rax],al
    270b:	add    BYTE PTR [rax],al
    270d:	add    BYTE PTR [rax],al
	...

0000000000002710 <botlish_entry_17: tld_ok<generic>>:
    2710:	push   rbp
    2711:	mov    rbp,rsp
    2714:	mov    rsi,QWORD PTR [rdx]
    2717:	mov    r8,QWORD PTR [rdx+0x8]
    271b:	mov    rcx,QWORD PTR [rdx+0x10]
    271f:	mov    rdx,r8
    2722:	call   2727 <botlish_entry_17+0x17>
			2723: R_X86_64_PLT32	botlish_fn_17-0x4 ; tld_ok<generic>
    2727:	mov    rsp,rbp
    272a:	pop    rbp
    272b:	ret
    272c:	add    BYTE PTR [rax],al
	...

0000000000002730 <botlish_fn_18: domain_loop<generic>>:
    2730:	push   rbp
    2731:	mov    rbp,rsp
    2734:	sub    rsp,0x70
    2738:	mov    QWORD PTR [rsp+0x40],rbx
    273d:	mov    QWORD PTR [rsp+0x48],r12
    2742:	mov    QWORD PTR [rsp+0x50],r13
    2747:	mov    QWORD PTR [rsp+0x58],r14
    274c:	mov    QWORD PTR [rsp+0x60],r15
    2751:	mov    QWORD PTR [rsp+0x18],0x0
    275a:	mov    QWORD PTR [rsp],rsi
    275e:	mov    QWORD PTR [rsp+0x8],rdx
    2763:	mov    QWORD PTR [rsp+0x10],rcx
    2768:	lea    rbx,[rsp+0x20]
    276d:	mov    r12,rdi
    2770:	mov    r13,rcx
    2773:	mov    r14,rdx
    2776:	mov    QWORD PTR [rsp+0x30],rsi
    277b:	mov    rcx,r13
    277e:	mov    rdx,r14
    2781:	mov    rsi,QWORD PTR [rsp+0x30]
    2786:	mov    rdi,r12
    2789:	call   278e <botlish_fn_18+0x5e>
			278a: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_label<generic>
    278e:	mov    rcx,rax
    2791:	mov    r15,rax
    2794:	test   rax,rcx
    2797:	je     28e7 <botlish_fn_18+0x1b7>
    279d:	mov    rax,r15
    27a0:	mov    QWORD PTR [rsp],rax
    27a4:	mov    rdx,QWORD PTR [rsp+0x30]
    27a9:	and    rax,rdx
    27ac:	test   rax,0x1
    27b2:	jne    27d1 <botlish_fn_18+0xa1>
    27b8:	mov    rsi,r15
    27bb:	mov    rdi,r12
    27be:	call   27c3 <botlish_fn_18+0x93>
			27bf: R_X86_64_PLT32	rt_value_eq-0x4
    27c3:	test   rax,rax
    27c6:	je     28e7 <botlish_fn_18+0x1b7>
    27cc:	jmp    27e1 <botlish_fn_18+0xb1>
    27d1:	mov    eax,0x2
    27d6:	cmp    r15,rdx
    27d9:	cmove  rax,QWORD PTR [rip+0x187]        # 2968 <botlish_fn_18+0x238>
    27e1:	cmp    rax,0x6
    27e5:	je     293d <botlish_fn_18+0x20d>
    27eb:	mov    rax,r15
    27ee:	and    rax,r14
    27f1:	test   rax,0x1
    27f7:	jne    2820 <botlish_fn_18+0xf0>
    27fd:	mov    rdx,r14
    2800:	mov    rsi,r15
    2803:	mov    rdi,r12
    2806:	call   280b <botlish_fn_18+0xdb>
			2807: R_X86_64_PLT32	rt_int_cmp-0x4
    280b:	mov    ecx,0x2
    2810:	test   rax,rax
    2813:	cmovge rcx,QWORD PTR [rip+0x14d]        # 2968 <botlish_fn_18+0x238>
    281b:	jmp    2830 <botlish_fn_18+0x100>
    2820:	mov    ecx,0x2
    2825:	cmp    r15,r14
    2828:	cmovge rcx,QWORD PTR [rip+0x138]        # 2968 <botlish_fn_18+0x238>
    2830:	cmp    rcx,0x6
    2834:	je     292e <botlish_fn_18+0x1fe>
    283a:	mov    rcx,rbx
    283d:	mov    rdx,r13
    2840:	mov    rsi,r15
    2843:	mov    rdi,r12
    2846:	call   284b <botlish_fn_18+0x11b>
			2847: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    284b:	test   rax,rax
    284e:	je     28e7 <botlish_fn_18+0x1b7>
    2854:	mov    rdx,QWORD PTR [rsp+0x20]
    2859:	mov    rcx,QWORD PTR [rsp+0x28]
    285e:	mov    rsi,QWORD PTR [r12+0x10]
    2863:	mov    r8,QWORD PTR [rsi+0x120]
    286a:	mov    rsi,rax
    286d:	mov    rdi,r12
    2870:	call   2875 <botlish_fn_18+0x145>
			2871: R_X86_64_PLT32	rt_str_region_eq-0x4
    2875:	cmp    rax,0x6
    2879:	je     288b <botlish_fn_18+0x15b>
    287f:	mov    r14,0xffffffffffffffff
    2886:	jmp    2935 <botlish_fn_18+0x205>
    288b:	mov    QWORD PTR [rsp+0x18],0x3
    2894:	test   r15,0x1
    289b:	je     28b3 <botlish_fn_18+0x183>
    28a1:	mov    rdx,r15
    28a4:	add    rdx,0x2
    28a8:	seto   al
    28ab:	test   al,al
    28ad:	je     28c6 <botlish_fn_18+0x196>
    28b3:	mov    edx,0x3
    28b8:	mov    rsi,r15
    28bb:	mov    rdi,r12
    28be:	call   28c3 <botlish_fn_18+0x193>
			28bf: R_X86_64_PLT32	rt_int_add-0x4
    28c3:	mov    rdx,rax
    28c6:	mov    QWORD PTR [rsp],rdx
    28ca:	mov    r15,rdx
    28cd:	mov    rcx,r13
    28d0:	mov    rdx,r14
    28d3:	mov    rsi,r15
    28d6:	mov    rdi,r12
    28d9:	call   28de <botlish_fn_18+0x1ae>
			28da: R_X86_64_PLT32	botlish_fn_17-0x4 ; tld_ok<generic>
    28de:	test   rax,rax
    28e1:	jne    290c <botlish_fn_18+0x1dc>
    28e7:	xor    rax,rax
    28ea:	mov    rbx,QWORD PTR [rsp+0x40]
    28ef:	mov    r12,QWORD PTR [rsp+0x48]
    28f4:	mov    r13,QWORD PTR [rsp+0x50]
    28f9:	mov    r14,QWORD PTR [rsp+0x58]
    28fe:	mov    r15,QWORD PTR [rsp+0x60]
    2903:	add    rsp,0x70
    2907:	mov    rsp,rbp
    290a:	pop    rbp
    290b:	ret
    290c:	cmp    rax,0x6
    2910:	je     2935 <botlish_fn_18+0x205>
    2916:	mov    QWORD PTR [rsp],r15
    291a:	mov    QWORD PTR [rsp+0x8],r14
    291f:	mov    QWORD PTR [rsp+0x10],r13
    2924:	mov    QWORD PTR [rsp+0x30],r15
    2929:	jmp    277b <botlish_fn_18+0x4b>
    292e:	mov    r14,0xffffffffffffffff
    2935:	mov    rax,r14
    2938:	jmp    2944 <botlish_fn_18+0x214>
    293d:	mov    rax,0xffffffffffffffff
    2944:	mov    rbx,QWORD PTR [rsp+0x40]
    2949:	mov    r12,QWORD PTR [rsp+0x48]
    294e:	mov    r13,QWORD PTR [rsp+0x50]
    2953:	mov    r14,QWORD PTR [rsp+0x58]
    2958:	mov    r15,QWORD PTR [rsp+0x60]
    295d:	add    rsp,0x70
    2961:	mov    rsp,rbp
    2964:	pop    rbp
    2965:	ret
    2966:	add    BYTE PTR [rax],al
    2968:	(bad)
    2969:	add    BYTE PTR [rax],al
    296b:	add    BYTE PTR [rax],al
    296d:	add    BYTE PTR [rax],al
	...

0000000000002970 <botlish_entry_18: domain_loop<generic>>:
    2970:	push   rbp
    2971:	mov    rbp,rsp
    2974:	mov    rsi,QWORD PTR [rdx]
    2977:	mov    r8,QWORD PTR [rdx+0x8]
    297b:	mov    rcx,QWORD PTR [rdx+0x10]
    297f:	mov    rdx,r8
    2982:	call   2987 <botlish_entry_18+0x17>
			2983: R_X86_64_PLT32	botlish_fn_18-0x4 ; domain_loop<generic>
    2987:	mov    rsp,rbp
    298a:	pop    rbp
    298b:	ret
    298c:	add    BYTE PTR [rax],al
	...

0000000000002990 <botlish_fn_19: <str>>:
    2990:	push   rbp
    2991:	mov    rbp,rsp
    2994:	sub    rsp,0x50
    2998:	mov    QWORD PTR [rsp+0x30],rbx
    299d:	mov    QWORD PTR [rsp+0x38],r12
    29a2:	mov    QWORD PTR [rsp+0x40],r13
    29a7:	mov    QWORD PTR [rsp+0x48],r14
    29ac:	mov    r13,rdi
    29af:	mov    QWORD PTR [rsp+0x18],0x0
    29b8:	mov    QWORD PTR [rsp],rsi
    29bc:	mov    r14,rsi
    29bf:	mov    rsi,r14
    29c2:	mov    rdi,r13
    29c5:	call   29ca <botlish_fn_19+0x3a>
			29c6: R_X86_64_PLT32	rt_str_len-0x4
    29ca:	mov    rbx,rax
    29cd:	mov    QWORD PTR [rsp+0x8],rax
    29d2:	mov    esi,0x1
    29d7:	mov    QWORD PTR [rsp+0x10],0x1
    29e0:	mov    rcx,r14
    29e3:	mov    rdx,rbx
    29e6:	mov    rdi,r13
    29e9:	call   29ee <botlish_fn_19+0x5e>
			29ea: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_local<generic>
    29ee:	mov    r12,rax
    29f1:	test   r12,r12
    29f4:	je     2b51 <botlish_fn_19+0x1c1>
    29fa:	mov    QWORD PTR [rsp+0x10],r12
    29ff:	test   r12,0x1
    2a06:	jne    2a31 <botlish_fn_19+0xa1>
    2a0c:	mov    edx,0x1
    2a11:	mov    rsi,r12
    2a14:	mov    rdi,r13
    2a17:	call   2a1c <botlish_fn_19+0x8c>
			2a18: R_X86_64_PLT32	rt_int_cmp-0x4
    2a1c:	mov    ecx,0x2
    2a21:	test   rax,rax
    2a24:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 2bf0 <botlish_fn_19+0x260>
    2a2c:	jmp    2a42 <botlish_fn_19+0xb2>
    2a31:	mov    ecx,0x2
    2a36:	cmp    r12,0x1
    2a3a:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 2bf0 <botlish_fn_19+0x260>
    2a42:	cmp    rcx,0x6
    2a46:	je     2bcc <botlish_fn_19+0x23c>
    2a4c:	mov    rcx,r12
    2a4f:	and    rcx,rbx
    2a52:	test   rcx,0x1
    2a59:	jne    2a82 <botlish_fn_19+0xf2>
    2a5f:	mov    rdx,rbx
    2a62:	mov    rsi,r12
    2a65:	mov    rdi,r13
    2a68:	call   2a6d <botlish_fn_19+0xdd>
			2a69: R_X86_64_PLT32	rt_int_cmp-0x4
    2a6d:	mov    ecx,0x2
    2a72:	test   rax,rax
    2a75:	cmovge rcx,QWORD PTR [rip+0x173]        # 2bf0 <botlish_fn_19+0x260>
    2a7d:	jmp    2a92 <botlish_fn_19+0x102>
    2a82:	mov    ecx,0x2
    2a87:	cmp    r12,rbx
    2a8a:	cmovge rcx,QWORD PTR [rip+0x15e]        # 2bf0 <botlish_fn_19+0x260>
    2a92:	cmp    rcx,0x6
    2a96:	je     2bc2 <botlish_fn_19+0x232>
    2a9c:	lea    rcx,[rsp+0x20]
    2aa1:	mov    rdx,r14
    2aa4:	mov    rsi,r12
    2aa7:	mov    rdi,r13
    2aaa:	call   2aaf <botlish_fn_19+0x11f>
			2aab: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    2aaf:	test   rax,rax
    2ab2:	mov    rsi,rax
    2ab5:	je     2b51 <botlish_fn_19+0x1c1>
    2abb:	mov    rdx,QWORD PTR [rsp+0x20]
    2ac0:	mov    rcx,QWORD PTR [rsp+0x28]
    2ac5:	mov    rdi,r13
    2ac8:	mov    rax,QWORD PTR [rdi+0x10]
    2acc:	mov    r8,QWORD PTR [rax+0x108]
    2ad3:	call   2ad8 <botlish_fn_19+0x148>
			2ad4: R_X86_64_PLT32	rt_str_region_eq-0x4
    2ad8:	cmp    rax,0x6
    2adc:	je     2aef <botlish_fn_19+0x15f>
    2ae2:	mov    ecx,0x2
    2ae7:	mov    rax,rcx
    2aea:	jmp    2bd1 <botlish_fn_19+0x241>
    2aef:	mov    QWORD PTR [rsp+0x18],0x3
    2af8:	test   r12,0x1
    2aff:	jne    2b0d <botlish_fn_19+0x17d>
    2b05:	mov    rcx,r12
    2b08:	jmp    2b22 <botlish_fn_19+0x192>
    2b0d:	mov    rsi,r12
    2b10:	add    rsi,0x2
    2b14:	mov    rcx,r12
    2b17:	seto   al
    2b1a:	test   al,al
    2b1c:	je     2b35 <botlish_fn_19+0x1a5>
    2b22:	mov    edx,0x3
    2b27:	mov    rsi,rcx
    2b2a:	mov    rdi,r13
    2b2d:	call   2b32 <botlish_fn_19+0x1a2>
			2b2e: R_X86_64_PLT32	rt_int_add-0x4
    2b32:	mov    rsi,rax
    2b35:	mov    QWORD PTR [rsp+0x10],rsi
    2b3a:	mov    rcx,r14
    2b3d:	mov    rdx,rbx
    2b40:	mov    rdi,r13
    2b43:	call   2b48 <botlish_fn_19+0x1b8>
			2b44: R_X86_64_PLT32	botlish_fn_26-0x4 ; domain_loop<generic>
    2b48:	test   rax,rax
    2b4b:	jne    2b71 <botlish_fn_19+0x1e1>
    2b51:	xor    rax,rax
    2b54:	mov    rbx,QWORD PTR [rsp+0x30]
    2b59:	mov    r12,QWORD PTR [rsp+0x38]
    2b5e:	mov    r13,QWORD PTR [rsp+0x40]
    2b63:	mov    r14,QWORD PTR [rsp+0x48]
    2b68:	add    rsp,0x50
    2b6c:	mov    rsp,rbp
    2b6f:	pop    rbp
    2b70:	ret
    2b71:	mov    rcx,rax
    2b74:	and    rcx,rbx
    2b77:	mov    rsi,rax
    2b7a:	test   rcx,0x1
    2b81:	jne    2baa <botlish_fn_19+0x21a>
    2b87:	mov    rdx,rbx
    2b8a:	mov    rdi,r13
    2b8d:	call   2b92 <botlish_fn_19+0x202>
			2b8e: R_X86_64_PLT32	rt_int_cmp-0x4
    2b92:	mov    ecx,0x2
    2b97:	test   rax,rax
    2b9a:	mov    rax,rcx
    2b9d:	cmove  rax,QWORD PTR [rip+0x4b]        # 2bf0 <botlish_fn_19+0x260>
    2ba5:	jmp    2bd1 <botlish_fn_19+0x241>
    2baa:	mov    rdx,rbx
    2bad:	mov    eax,0x2
    2bb2:	cmp    rsi,rdx
    2bb5:	cmove  rax,QWORD PTR [rip+0x33]        # 2bf0 <botlish_fn_19+0x260>
    2bbd:	jmp    2bd1 <botlish_fn_19+0x241>
    2bc2:	mov    eax,0x2
    2bc7:	jmp    2bd1 <botlish_fn_19+0x241>
    2bcc:	mov    eax,0x2
    2bd1:	mov    rbx,QWORD PTR [rsp+0x30]
    2bd6:	mov    r12,QWORD PTR [rsp+0x38]
    2bdb:	mov    r13,QWORD PTR [rsp+0x40]
    2be0:	mov    r14,QWORD PTR [rsp+0x48]
    2be5:	add    rsp,0x50
    2be9:	mov    rsp,rbp
    2bec:	pop    rbp
    2bed:	ret
    2bee:	add    BYTE PTR [rax],al
    2bf0:	(bad)
    2bf1:	add    BYTE PTR [rax],al
    2bf3:	add    BYTE PTR [rax],al
    2bf5:	add    BYTE PTR [rax],al
	...

0000000000002bf8 <botlish_entry_19: <str>>:
    2bf8:	push   rbp
    2bf9:	mov    rbp,rsp
    2bfc:	mov    rsi,QWORD PTR [rdx]
    2bff:	call   2c04 <botlish_entry_19+0xc>
			2c00: R_X86_64_PLT32	botlish_fn_19-0x4 ; <str>
    2c04:	mov    rsp,rbp
    2c07:	pop    rbp
    2c08:	ret
    2c09:	add    BYTE PTR [rax],al
    2c0b:	add    BYTE PTR [rax],al
    2c0d:	add    BYTE PTR [rax],al
	...

0000000000002c10 <botlish_fn_20: <generic>>:
    2c10:	push   rbp
    2c11:	mov    rbp,rsp
    2c14:	sub    rsp,0x60
    2c18:	mov    QWORD PTR [rsp+0x30],rbx
    2c1d:	mov    QWORD PTR [rsp+0x38],r12
    2c22:	mov    QWORD PTR [rsp+0x40],r13
    2c27:	mov    QWORD PTR [rsp+0x48],r14
    2c2c:	mov    QWORD PTR [rsp+0x50],r15
    2c31:	mov    QWORD PTR [rsp+0x18],0x0
    2c3a:	mov    QWORD PTR [rsp],rsi
    2c3e:	xor    r8d,r8d
    2c41:	test   rsi,0x7
    2c48:	jne    2c58 <botlish_fn_20+0x48>
    2c4e:	movzx  rax,BYTE PTR [rsi]
    2c52:	cmp    al,0x2
    2c54:	sete   r8b
    2c58:	test   r8b,r8b
    2c5b:	jne    2c7b <botlish_fn_20+0x6b>
    2c61:	mov    rdx,QWORD PTR [rdi+0x10]
    2c65:	mov    rcx,QWORD PTR [rdx+0xe0]
    2c6c:	mov    edx,0x1
    2c71:	call   2c76 <botlish_fn_20+0x66>
			2c72: R_X86_64_PLT32	rt_type_error-0x4
    2c76:	jmp    2e10 <botlish_fn_20+0x200>
    2c7b:	mov    r13,rsi
    2c7e:	mov    r14,rdi
    2c81:	call   2c86 <botlish_fn_20+0x76>
			2c82: R_X86_64_PLT32	rt_str_len-0x4
    2c86:	mov    rbx,rax
    2c89:	mov    QWORD PTR [rsp+0x8],rax
    2c8e:	mov    edx,0x1
    2c93:	mov    r15,rdx
    2c96:	mov    QWORD PTR [rsp+0x10],0x1
    2c9f:	mov    rcx,r13
    2ca2:	mov    rdx,rbx
    2ca5:	mov    rsi,r15
    2ca8:	mov    rdi,r14
    2cab:	call   2cb0 <botlish_fn_20+0xa0>
			2cac: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_local<generic>
    2cb0:	mov    r12,rax
    2cb3:	test   r12,r12
    2cb6:	je     2e10 <botlish_fn_20+0x200>
    2cbc:	mov    QWORD PTR [rsp+0x10],r12
    2cc1:	test   r12,0x1
    2cc8:	jne    2cf1 <botlish_fn_20+0xe1>
    2cce:	mov    rdx,r15
    2cd1:	mov    rsi,r12
    2cd4:	mov    rdi,r14
    2cd7:	call   2cdc <botlish_fn_20+0xcc>
			2cd8: R_X86_64_PLT32	rt_int_cmp-0x4
    2cdc:	mov    ecx,0x2
    2ce1:	test   rax,rax
    2ce4:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 2eb8 <botlish_fn_20+0x2a8>
    2cec:	jmp    2d02 <botlish_fn_20+0xf2>
    2cf1:	mov    ecx,0x2
    2cf6:	cmp    r12,0x1
    2cfa:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 2eb8 <botlish_fn_20+0x2a8>
    2d02:	cmp    rcx,0x6
    2d06:	je     2e90 <botlish_fn_20+0x280>
    2d0c:	mov    rax,r12
    2d0f:	and    rax,rbx
    2d12:	test   rax,0x1
    2d18:	jne    2d41 <botlish_fn_20+0x131>
    2d1e:	mov    rdx,rbx
    2d21:	mov    rsi,r12
    2d24:	mov    rdi,r14
    2d27:	call   2d2c <botlish_fn_20+0x11c>
			2d28: R_X86_64_PLT32	rt_int_cmp-0x4
    2d2c:	mov    ecx,0x2
    2d31:	test   rax,rax
    2d34:	cmovge rcx,QWORD PTR [rip+0x17c]        # 2eb8 <botlish_fn_20+0x2a8>
    2d3c:	jmp    2d51 <botlish_fn_20+0x141>
    2d41:	mov    ecx,0x2
    2d46:	cmp    r12,rbx
    2d49:	cmovge rcx,QWORD PTR [rip+0x167]        # 2eb8 <botlish_fn_20+0x2a8>
    2d51:	cmp    rcx,0x6
    2d55:	je     2e86 <botlish_fn_20+0x276>
    2d5b:	lea    rcx,[rsp+0x20]
    2d60:	mov    rdx,r13
    2d63:	mov    rsi,r12
    2d66:	mov    rdi,r14
    2d69:	call   2d6e <botlish_fn_20+0x15e>
			2d6a: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    2d6e:	test   rax,rax
    2d71:	mov    rsi,rax
    2d74:	je     2e10 <botlish_fn_20+0x200>
    2d7a:	mov    rdx,QWORD PTR [rsp+0x20]
    2d7f:	mov    rcx,QWORD PTR [rsp+0x28]
    2d84:	mov    rdi,r14
    2d87:	mov    rax,QWORD PTR [rdi+0x10]
    2d8b:	mov    r8,QWORD PTR [rax+0x108]
    2d92:	call   2d97 <botlish_fn_20+0x187>
			2d93: R_X86_64_PLT32	rt_str_region_eq-0x4
    2d97:	cmp    rax,0x6
    2d9b:	je     2dae <botlish_fn_20+0x19e>
    2da1:	mov    ecx,0x2
    2da6:	mov    rax,rcx
    2da9:	jmp    2e95 <botlish_fn_20+0x285>
    2dae:	mov    QWORD PTR [rsp+0x18],0x3
    2db7:	test   r12,0x1
    2dbe:	jne    2dcc <botlish_fn_20+0x1bc>
    2dc4:	mov    rdi,r12
    2dc7:	jmp    2de1 <botlish_fn_20+0x1d1>
    2dcc:	mov    rsi,r12
    2dcf:	add    rsi,0x2
    2dd3:	mov    rdi,r12
    2dd6:	seto   al
    2dd9:	test   al,al
    2ddb:	je     2df4 <botlish_fn_20+0x1e4>
    2de1:	mov    edx,0x3
    2de6:	mov    rsi,rdi
    2de9:	mov    rdi,r14
    2dec:	call   2df1 <botlish_fn_20+0x1e1>
			2ded: R_X86_64_PLT32	rt_int_add-0x4
    2df1:	mov    rsi,rax
    2df4:	mov    QWORD PTR [rsp+0x10],rsi
    2df9:	mov    rcx,r13
    2dfc:	mov    rdx,rbx
    2dff:	mov    rdi,r14
    2e02:	call   2e07 <botlish_fn_20+0x1f7>
			2e03: R_X86_64_PLT32	botlish_fn_26-0x4 ; domain_loop<generic>
    2e07:	test   rax,rax
    2e0a:	jne    2e35 <botlish_fn_20+0x225>
    2e10:	xor    rax,rax
    2e13:	mov    rbx,QWORD PTR [rsp+0x30]
    2e18:	mov    r12,QWORD PTR [rsp+0x38]
    2e1d:	mov    r13,QWORD PTR [rsp+0x40]
    2e22:	mov    r14,QWORD PTR [rsp+0x48]
    2e27:	mov    r15,QWORD PTR [rsp+0x50]
    2e2c:	add    rsp,0x60
    2e30:	mov    rsp,rbp
    2e33:	pop    rbp
    2e34:	ret
    2e35:	mov    rcx,rax
    2e38:	and    rcx,rbx
    2e3b:	mov    rsi,rax
    2e3e:	test   rcx,0x1
    2e45:	jne    2e6e <botlish_fn_20+0x25e>
    2e4b:	mov    rdx,rbx
    2e4e:	mov    rdi,r14
    2e51:	call   2e56 <botlish_fn_20+0x246>
			2e52: R_X86_64_PLT32	rt_int_cmp-0x4
    2e56:	mov    ecx,0x2
    2e5b:	test   rax,rax
    2e5e:	mov    rax,rcx
    2e61:	cmove  rax,QWORD PTR [rip+0x4f]        # 2eb8 <botlish_fn_20+0x2a8>
    2e69:	jmp    2e95 <botlish_fn_20+0x285>
    2e6e:	mov    rdx,rbx
    2e71:	mov    eax,0x2
    2e76:	cmp    rsi,rdx
    2e79:	cmove  rax,QWORD PTR [rip+0x37]        # 2eb8 <botlish_fn_20+0x2a8>
    2e81:	jmp    2e95 <botlish_fn_20+0x285>
    2e86:	mov    eax,0x2
    2e8b:	jmp    2e95 <botlish_fn_20+0x285>
    2e90:	mov    eax,0x2
    2e95:	mov    rbx,QWORD PTR [rsp+0x30]
    2e9a:	mov    r12,QWORD PTR [rsp+0x38]
    2e9f:	mov    r13,QWORD PTR [rsp+0x40]
    2ea4:	mov    r14,QWORD PTR [rsp+0x48]
    2ea9:	mov    r15,QWORD PTR [rsp+0x50]
    2eae:	add    rsp,0x60
    2eb2:	mov    rsp,rbp
    2eb5:	pop    rbp
    2eb6:	ret
    2eb7:	add    BYTE PTR [rsi],al
    2eb9:	add    BYTE PTR [rax],al
    2ebb:	add    BYTE PTR [rax],al
    2ebd:	add    BYTE PTR [rax],al
	...

0000000000002ec0 <botlish_entry_20: <generic>>:
    2ec0:	push   rbp
    2ec1:	mov    rbp,rsp
    2ec4:	mov    rsi,QWORD PTR [rdx]
    2ec7:	call   2ecc <botlish_entry_20+0xc>
			2ec8: R_X86_64_PLT32	botlish_fn_20-0x4 ; <generic>
    2ecc:	mov    rsp,rbp
    2ecf:	pop    rbp
    2ed0:	ret

0000000000002ed1 <botlish_fn_21: char_at<generic>>:
    2ed1:	push   rbp
    2ed2:	mov    rbp,rsp
    2ed5:	sub    rsp,0x50
    2ed9:	mov    QWORD PTR [rsp+0x20],rbx
    2ede:	mov    QWORD PTR [rsp+0x28],r12
    2ee3:	mov    QWORD PTR [rsp+0x30],r13
    2ee8:	mov    QWORD PTR [rsp+0x38],r14
    2eed:	mov    QWORD PTR [rsp+0x40],r15
    2ef2:	mov    r14,rcx
    2ef5:	mov    QWORD PTR [rsp],rsi
    2ef9:	mov    QWORD PTR [rsp+0x8],rdx
    2efe:	mov    r13,rdx
    2f01:	mov    QWORD PTR [rsp+0x10],0x3
    2f0a:	mov    r9d,0x1
    2f10:	test   rsi,0x1
    2f17:	jne    2f37 <botlish_fn_21+0x66>
    2f1d:	xor    r9d,r9d
    2f20:	test   rsi,0x7
    2f27:	jne    2f37 <botlish_fn_21+0x66>
    2f2d:	movzx  rax,BYTE PTR [rsi]
    2f31:	cmp    al,0x1
    2f33:	sete   r9b
    2f37:	test   r9b,r9b
    2f3a:	jne    2f58 <botlish_fn_21+0x87>
    2f40:	mov    rax,QWORD PTR [rdi+0x10]
    2f44:	mov    rcx,QWORD PTR [rax+0x110]
    2f4b:	xor    rdx,rdx
    2f4e:	call   2f53 <botlish_fn_21+0x82>
			2f4f: R_X86_64_PLT32	rt_type_error-0x4
    2f53:	jmp    3015 <botlish_fn_21+0x144>
    2f58:	mov    r12,rdi
    2f5b:	test   rsi,0x1
    2f62:	jne    2f70 <botlish_fn_21+0x9f>
    2f68:	mov    rbx,rsi
    2f6b:	jmp    2f8d <botlish_fn_21+0xbc>
    2f70:	mov    rax,rsi
    2f73:	add    rax,0x2
    2f77:	mov    rbx,rsi
    2f7a:	seto   cl
    2f7d:	test   cl,cl
    2f7f:	jne    2f8d <botlish_fn_21+0xbc>
    2f85:	mov    r15,rax
    2f88:	jmp    2fa0 <botlish_fn_21+0xcf>
    2f8d:	mov    edx,0x3
    2f92:	mov    rsi,rbx
    2f95:	mov    rdi,r12
    2f98:	call   2f9d <botlish_fn_21+0xcc>
			2f99: R_X86_64_PLT32	rt_int_add-0x4
    2f9d:	mov    r15,rax
    2fa0:	mov    ecx,0x1
    2fa5:	mov    rsi,rbx
    2fa8:	test   rsi,0x1
    2faf:	jne    2fd5 <botlish_fn_21+0x104>
    2fb5:	xor    ecx,ecx
    2fb7:	mov    rsi,rbx
    2fba:	test   rsi,0x7
    2fc1:	jne    2fd5 <botlish_fn_21+0x104>
    2fc7:	mov    rsi,rbx
    2fca:	movzx  rcx,BYTE PTR [rsi]
    2fce:	rex cmp cl,0x1
    2fd2:	sete   cl
    2fd5:	test   cl,cl
    2fd7:	jne    2ffb <botlish_fn_21+0x12a>
    2fdd:	mov    rdi,r12
    2fe0:	mov    rsi,QWORD PTR [rdi+0x10]
    2fe4:	mov    rcx,QWORD PTR [rsi+0x118]
    2feb:	xor    rdx,rdx
    2fee:	mov    rsi,rbx
    2ff1:	call   2ff6 <botlish_fn_21+0x125>
			2ff2: R_X86_64_PLT32	rt_type_error-0x4
    2ff6:	jmp    3015 <botlish_fn_21+0x144>
    2ffb:	mov    rdi,r12
    2ffe:	mov    rcx,r15
    3001:	mov    rdx,rbx
    3004:	mov    rsi,r13
    3007:	call   300c <botlish_fn_21+0x13b>
			3008: R_X86_64_PLT32	rt_str_region_check-0x4
    300c:	test   rax,rax
    300f:	jne    303a <botlish_fn_21+0x169>
    3015:	xor    rax,rax
    3018:	mov    rbx,QWORD PTR [rsp+0x20]
    301d:	mov    r12,QWORD PTR [rsp+0x28]
    3022:	mov    r13,QWORD PTR [rsp+0x30]
    3027:	mov    r14,QWORD PTR [rsp+0x38]
    302c:	mov    r15,QWORD PTR [rsp+0x40]
    3031:	add    rsp,0x50
    3035:	mov    rsp,rbp
    3038:	pop    rbp
    3039:	ret
    303a:	mov    rcx,r14
    303d:	mov    rsi,rbx
    3040:	mov    QWORD PTR [rcx],rsi
    3043:	mov    rax,r15
    3046:	mov    QWORD PTR [rcx+0x8],rax
    304a:	mov    rax,r13
    304d:	mov    rbx,QWORD PTR [rsp+0x20]
    3052:	mov    r12,QWORD PTR [rsp+0x28]
    3057:	mov    r13,QWORD PTR [rsp+0x30]
    305c:	mov    r14,QWORD PTR [rsp+0x38]
    3061:	mov    r15,QWORD PTR [rsp+0x40]
    3066:	add    rsp,0x50
    306a:	mov    rsp,rbp
    306d:	pop    rbp
    306e:	ret

000000000000306f <botlish_entry_21: char_at<generic>>:
    306f:	push   rbp
    3070:	mov    rbp,rsp
    3073:	ud2
    3075:	add    BYTE PTR [rax],al
	...

0000000000003078 <botlish_fn_22: scan_local<generic>>:
    3078:	push   rbp
    3079:	mov    rbp,rsp
    307c:	sub    rsp,0x80
    3083:	mov    QWORD PTR [rsp+0x50],rbx
    3088:	mov    QWORD PTR [rsp+0x58],r12
    308d:	mov    QWORD PTR [rsp+0x60],r13
    3092:	mov    QWORD PTR [rsp+0x68],r14
    3097:	mov    QWORD PTR [rsp+0x70],r15
    309c:	mov    rax,rdi
    309f:	mov    QWORD PTR [rsp+0x18],0x0
    30a8:	mov    QWORD PTR [rsp],rsi
    30ac:	mov    r14,rsi
    30af:	mov    QWORD PTR [rsp+0x8],rdx
    30b4:	mov    QWORD PTR [rsp+0x10],rcx
    30b9:	mov    r12,rcx
    30bc:	mov    r11d,0x1
    30c2:	mov    rsi,r14
    30c5:	test   rsi,0x1
    30cc:	jne    30ee <botlish_fn_22+0x76>
    30d2:	xor    r11d,r11d
    30d5:	test   rsi,0x7
    30dc:	jne    30ee <botlish_fn_22+0x76>
    30e2:	movzx  rdi,BYTE PTR [rsi]
    30e6:	cmp    dil,0x1
    30ea:	sete   r11b
    30ee:	test   r11b,r11b
    30f1:	jne    3112 <botlish_fn_22+0x9a>
    30f7:	mov    rdi,rax
    30fa:	mov    r9,QWORD PTR [rdi+0x10]
    30fe:	mov    rcx,QWORD PTR [r9+0xc0]
    3105:	xor    rdx,rdx
    3108:	call   310d <botlish_fn_22+0x95>
			3109: R_X86_64_PLT32	rt_type_error-0x4
    310d:	jmp    31c5 <botlish_fn_22+0x14d>
    3112:	mov    r13,rdx
    3115:	mov    r10,rsi
    3118:	and    r10,r13
    311b:	mov    r14,rsi
    311e:	test   r10,0x1
    3125:	jne    3151 <botlish_fn_22+0xd9>
    312b:	mov    rbx,rax
    312e:	mov    rdx,r13
    3131:	mov    rsi,r14
    3134:	mov    rdi,rbx
    3137:	call   313c <botlish_fn_22+0xc4>
			3138: R_X86_64_PLT32	rt_int_cmp-0x4
    313c:	mov    ecx,0x2
    3141:	test   rax,rax
    3144:	cmovge rcx,QWORD PTR [rip+0x24c]        # 3398 <botlish_fn_22+0x320>
    314c:	jmp    3167 <botlish_fn_22+0xef>
    3151:	mov    rbx,rax
    3154:	mov    ecx,0x2
    3159:	mov    rsi,r14
    315c:	cmp    rsi,r13
    315f:	cmovge rcx,QWORD PTR [rip+0x231]        # 3398 <botlish_fn_22+0x320>
    3167:	mov    eax,0x6
    316c:	mov    QWORD PTR [rsp+0x30],rax
    3171:	cmp    rcx,0x6
    3175:	je     336b <botlish_fn_22+0x2f3>
    317b:	lea    rcx,[rsp+0x20]
    3180:	mov    rdx,r12
    3183:	mov    rsi,r14
    3186:	mov    rdi,rbx
    3189:	call   318e <botlish_fn_22+0x116>
			318a: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    318e:	mov    rsi,rax
    3191:	mov    r15,rax
    3194:	test   rax,rsi
    3197:	je     31c5 <botlish_fn_22+0x14d>
    319d:	mov    rdx,QWORD PTR [rsp+0x20]
    31a2:	mov    QWORD PTR [rsp+0x40],rdx
    31a7:	mov    rcx,QWORD PTR [rsp+0x28]
    31ac:	mov    QWORD PTR [rsp+0x38],rcx
    31b1:	mov    rsi,r15
    31b4:	mov    rdi,rbx
    31b7:	call   31bc <botlish_fn_22+0x144>
			31b8: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    31bc:	test   rax,rax
    31bf:	jne    31ed <botlish_fn_22+0x175>
    31c5:	xor    rax,rax
    31c8:	mov    rbx,QWORD PTR [rsp+0x50]
    31cd:	mov    r12,QWORD PTR [rsp+0x58]
    31d2:	mov    r13,QWORD PTR [rsp+0x60]
    31d7:	mov    r14,QWORD PTR [rsp+0x68]
    31dc:	mov    r15,QWORD PTR [rsp+0x70]
    31e1:	add    rsp,0x80
    31e8:	mov    rsp,rbp
    31eb:	pop    rbp
    31ec:	ret
    31ed:	cmp    rax,0x6
    31f1:	je     32ec <botlish_fn_22+0x274>
    31f7:	mov    rax,QWORD PTR [rbx+0x10]
    31fb:	mov    r8,QWORD PTR [rax+0x120]
    3202:	mov    rcx,QWORD PTR [rsp+0x38]
    3207:	mov    rdx,QWORD PTR [rsp+0x40]
    320c:	mov    rsi,r15
    320f:	mov    rdi,rbx
    3212:	call   3217 <botlish_fn_22+0x19f>
			3213: R_X86_64_PLT32	rt_str_region_eq-0x4
    3217:	cmp    rax,0x6
    321b:	je     32e2 <botlish_fn_22+0x26a>
    3221:	mov    rax,QWORD PTR [rbx+0x10]
    3225:	mov    r8,QWORD PTR [rax+0x128]
    322c:	mov    rcx,QWORD PTR [rsp+0x38]
    3231:	mov    rdx,QWORD PTR [rsp+0x40]
    3236:	mov    rsi,r15
    3239:	mov    rdi,rbx
    323c:	call   3241 <botlish_fn_22+0x1c9>
			323d: R_X86_64_PLT32	rt_str_region_eq-0x4
    3241:	cmp    rax,0x6
    3245:	je     32d8 <botlish_fn_22+0x260>
    324b:	mov    rax,QWORD PTR [rbx+0x10]
    324f:	mov    r8,QWORD PTR [rax+0xc8]
    3256:	mov    rcx,QWORD PTR [rsp+0x38]
    325b:	mov    rdx,QWORD PTR [rsp+0x40]
    3260:	mov    rsi,r15
    3263:	mov    rdi,rbx
    3266:	call   326b <botlish_fn_22+0x1f3>
			3267: R_X86_64_PLT32	rt_str_region_eq-0x4
    326b:	cmp    rax,0x6
    326f:	je     32ce <botlish_fn_22+0x256>
    3275:	mov    rax,QWORD PTR [rbx+0x10]
    3279:	mov    r8,QWORD PTR [rax+0x110]
    3280:	mov    rcx,QWORD PTR [rsp+0x38]
    3285:	mov    rdx,QWORD PTR [rsp+0x40]
    328a:	mov    rsi,r15
    328d:	mov    rdi,rbx
    3290:	call   3295 <botlish_fn_22+0x21d>
			3291: R_X86_64_PLT32	rt_str_region_eq-0x4
    3295:	cmp    rax,0x6
    3299:	je     32c4 <botlish_fn_22+0x24c>
    329f:	mov    rax,QWORD PTR [rbx+0x10]
    32a3:	mov    r8,QWORD PTR [rax+0x130]
    32aa:	mov    rcx,QWORD PTR [rsp+0x38]
    32af:	mov    rdx,QWORD PTR [rsp+0x40]
    32b4:	mov    rsi,r15
    32b7:	mov    rdi,rbx
    32ba:	call   32bf <botlish_fn_22+0x247>
			32bb: R_X86_64_PLT32	rt_str_region_eq-0x4
    32bf:	jmp    32f1 <botlish_fn_22+0x279>
    32c4:	mov    rax,QWORD PTR [rsp+0x30]
    32c9:	jmp    32f1 <botlish_fn_22+0x279>
    32ce:	mov    rax,QWORD PTR [rsp+0x30]
    32d3:	jmp    32f1 <botlish_fn_22+0x279>
    32d8:	mov    rax,QWORD PTR [rsp+0x30]
    32dd:	jmp    32f1 <botlish_fn_22+0x279>
    32e2:	mov    rax,QWORD PTR [rsp+0x30]
    32e7:	jmp    32f1 <botlish_fn_22+0x279>
    32ec:	mov    rax,QWORD PTR [rsp+0x30]
    32f1:	cmp    rax,0x6
    32f5:	je     3303 <botlish_fn_22+0x28b>
    32fb:	mov    rax,r14
    32fe:	jmp    336e <botlish_fn_22+0x2f6>
    3303:	mov    QWORD PTR [rsp+0x18],0x3
    330c:	mov    rsi,r14
    330f:	test   rsi,0x1
    3316:	je     333c <botlish_fn_22+0x2c4>
    331c:	mov    rsi,r14
    331f:	mov    rax,rsi
    3322:	add    rax,0x2
    3326:	seto   cl
    3329:	test   cl,cl
    332b:	jne    333c <botlish_fn_22+0x2c4>
    3331:	mov    rsi,rax
    3334:	mov    r14,rax
    3337:	jmp    3352 <botlish_fn_22+0x2da>
    333c:	mov    edx,0x3
    3341:	mov    rsi,r14
    3344:	mov    rdi,rbx
    3347:	call   334c <botlish_fn_22+0x2d4>
			3348: R_X86_64_PLT32	rt_int_add-0x4
    334c:	mov    rsi,rax
    334f:	mov    r14,rax
    3352:	mov    QWORD PTR [rsp],rsi
    3356:	mov    QWORD PTR [rsp+0x8],r13
    335b:	mov    QWORD PTR [rsp+0x10],r12
    3360:	mov    rax,rbx
    3363:	mov    rdx,r13
    3366:	jmp    30bc <botlish_fn_22+0x44>
    336b:	mov    rax,r14
    336e:	mov    rbx,QWORD PTR [rsp+0x50]
    3373:	mov    r12,QWORD PTR [rsp+0x58]
    3378:	mov    r13,QWORD PTR [rsp+0x60]
    337d:	mov    r14,QWORD PTR [rsp+0x68]
    3382:	mov    r15,QWORD PTR [rsp+0x70]
    3387:	add    rsp,0x80
    338e:	mov    rsp,rbp
    3391:	pop    rbp
    3392:	ret
    3393:	add    BYTE PTR [rax],al
    3395:	add    BYTE PTR [rax],al
    3397:	add    BYTE PTR [rsi],al
    3399:	add    BYTE PTR [rax],al
    339b:	add    BYTE PTR [rax],al
    339d:	add    BYTE PTR [rax],al
	...

00000000000033a0 <botlish_entry_22: scan_local<generic>>:
    33a0:	push   rbp
    33a1:	mov    rbp,rsp
    33a4:	mov    rsi,QWORD PTR [rdx]
    33a7:	mov    r8,QWORD PTR [rdx+0x8]
    33ab:	mov    rcx,QWORD PTR [rdx+0x10]
    33af:	mov    rdx,r8
    33b2:	call   33b7 <botlish_entry_22+0x17>
			33b3: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_local<generic>
    33b7:	mov    rsp,rbp
    33ba:	pop    rbp
    33bb:	ret
    33bc:	add    BYTE PTR [rax],al
	...

00000000000033c0 <botlish_fn_23: scan_label<generic>>:
    33c0:	push   rbp
    33c1:	mov    rbp,rsp
    33c4:	sub    rsp,0x80
    33cb:	mov    QWORD PTR [rsp+0x50],rbx
    33d0:	mov    QWORD PTR [rsp+0x58],r12
    33d5:	mov    QWORD PTR [rsp+0x60],r13
    33da:	mov    QWORD PTR [rsp+0x68],r14
    33df:	mov    QWORD PTR [rsp+0x70],r15
    33e4:	mov    QWORD PTR [rsp+0x18],0x0
    33ed:	mov    QWORD PTR [rsp],rsi
    33f1:	mov    r14,rsi
    33f4:	mov    QWORD PTR [rsp+0x8],rdx
    33f9:	mov    QWORD PTR [rsp+0x10],rcx
    33fe:	mov    r12,rcx
    3401:	mov    r11d,0x1
    3407:	mov    rsi,r14
    340a:	test   rsi,0x1
    3411:	jne    3431 <botlish_fn_23+0x71>
    3417:	xor    r11d,r11d
    341a:	test   rsi,0x7
    3421:	jne    3431 <botlish_fn_23+0x71>
    3427:	movzx  rax,BYTE PTR [rsi]
    342b:	cmp    al,0x1
    342d:	sete   r11b
    3431:	test   r11b,r11b
    3434:	jne    3452 <botlish_fn_23+0x92>
    343a:	mov    rax,QWORD PTR [rdi+0x10]
    343e:	mov    rcx,QWORD PTR [rax+0xc0]
    3445:	xor    rdx,rdx
    3448:	call   344d <botlish_fn_23+0x8d>
			3449: R_X86_64_PLT32	rt_type_error-0x4
    344d:	jmp    34fe <botlish_fn_23+0x13e>
    3452:	mov    r13,rdx
    3455:	mov    rax,rsi
    3458:	and    rax,r13
    345b:	mov    r14,rsi
    345e:	test   rax,0x1
    3464:	jne    348d <botlish_fn_23+0xcd>
    346a:	mov    rbx,rdi
    346d:	mov    rdx,r13
    3470:	mov    rsi,r14
    3473:	call   3478 <botlish_fn_23+0xb8>
			3474: R_X86_64_PLT32	rt_int_cmp-0x4
    3478:	mov    ecx,0x2
    347d:	test   rax,rax
    3480:	cmovge rcx,QWORD PTR [rip+0x178]        # 3600 <botlish_fn_23+0x240>
    3488:	jmp    34a3 <botlish_fn_23+0xe3>
    348d:	mov    rbx,rdi
    3490:	mov    ecx,0x2
    3495:	mov    rsi,r14
    3498:	cmp    rsi,r13
    349b:	cmovge rcx,QWORD PTR [rip+0x15d]        # 3600 <botlish_fn_23+0x240>
    34a3:	mov    eax,0x6
    34a8:	mov    QWORD PTR [rsp+0x30],rax
    34ad:	cmp    rcx,0x6
    34b1:	je     35d4 <botlish_fn_23+0x214>
    34b7:	lea    rcx,[rsp+0x20]
    34bc:	mov    rdx,r12
    34bf:	mov    rsi,r14
    34c2:	mov    rdi,rbx
    34c5:	call   34ca <botlish_fn_23+0x10a>
			34c6: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    34ca:	test   rax,rax
    34cd:	mov    r15,rax
    34d0:	je     34fe <botlish_fn_23+0x13e>
    34d6:	mov    rdx,QWORD PTR [rsp+0x20]
    34db:	mov    QWORD PTR [rsp+0x40],rdx
    34e0:	mov    rcx,QWORD PTR [rsp+0x28]
    34e5:	mov    QWORD PTR [rsp+0x38],rcx
    34ea:	mov    rsi,r15
    34ed:	mov    rdi,rbx
    34f0:	call   34f5 <botlish_fn_23+0x135>
			34f1: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    34f5:	test   rax,rax
    34f8:	jne    3526 <botlish_fn_23+0x166>
    34fe:	xor    rax,rax
    3501:	mov    rbx,QWORD PTR [rsp+0x50]
    3506:	mov    r12,QWORD PTR [rsp+0x58]
    350b:	mov    r13,QWORD PTR [rsp+0x60]
    3510:	mov    r14,QWORD PTR [rsp+0x68]
    3515:	mov    r15,QWORD PTR [rsp+0x70]
    351a:	add    rsp,0x80
    3521:	mov    rsp,rbp
    3524:	pop    rbp
    3525:	ret
    3526:	cmp    rax,0x6
    352a:	je     3555 <botlish_fn_23+0x195>
    3530:	mov    r11,QWORD PTR [rbx+0x10]
    3534:	mov    r8,QWORD PTR [r11+0x130]
    353b:	mov    rcx,QWORD PTR [rsp+0x38]
    3540:	mov    rdx,QWORD PTR [rsp+0x40]
    3545:	mov    rsi,r15
    3548:	mov    rdi,rbx
    354b:	call   3550 <botlish_fn_23+0x190>
			354c: R_X86_64_PLT32	rt_str_region_eq-0x4
    3550:	jmp    355a <botlish_fn_23+0x19a>
    3555:	mov    rax,QWORD PTR [rsp+0x30]
    355a:	cmp    rax,0x6
    355e:	je     356c <botlish_fn_23+0x1ac>
    3564:	mov    rax,r14
    3567:	jmp    35d7 <botlish_fn_23+0x217>
    356c:	mov    QWORD PTR [rsp+0x18],0x3
    3575:	mov    rsi,r14
    3578:	test   rsi,0x1
    357f:	je     35a5 <botlish_fn_23+0x1e5>
    3585:	mov    rsi,r14
    3588:	mov    rax,rsi
    358b:	add    rax,0x2
    358f:	seto   cl
    3592:	test   cl,cl
    3594:	jne    35a5 <botlish_fn_23+0x1e5>
    359a:	mov    rsi,rax
    359d:	mov    r14,rax
    35a0:	jmp    35bb <botlish_fn_23+0x1fb>
    35a5:	mov    edx,0x3
    35aa:	mov    rsi,r14
    35ad:	mov    rdi,rbx
    35b0:	call   35b5 <botlish_fn_23+0x1f5>
			35b1: R_X86_64_PLT32	rt_int_add-0x4
    35b5:	mov    rsi,rax
    35b8:	mov    r14,rax
    35bb:	mov    QWORD PTR [rsp],rsi
    35bf:	mov    QWORD PTR [rsp+0x8],r13
    35c4:	mov    QWORD PTR [rsp+0x10],r12
    35c9:	mov    rdx,r13
    35cc:	mov    rdi,rbx
    35cf:	jmp    3401 <botlish_fn_23+0x41>
    35d4:	mov    rax,r14
    35d7:	mov    rbx,QWORD PTR [rsp+0x50]
    35dc:	mov    r12,QWORD PTR [rsp+0x58]
    35e1:	mov    r13,QWORD PTR [rsp+0x60]
    35e6:	mov    r14,QWORD PTR [rsp+0x68]
    35eb:	mov    r15,QWORD PTR [rsp+0x70]
    35f0:	add    rsp,0x80
    35f7:	mov    rsp,rbp
    35fa:	pop    rbp
    35fb:	ret
    35fc:	add    BYTE PTR [rax],al
    35fe:	add    BYTE PTR [rax],al
    3600:	(bad)
    3601:	add    BYTE PTR [rax],al
    3603:	add    BYTE PTR [rax],al
    3605:	add    BYTE PTR [rax],al
	...

0000000000003608 <botlish_entry_23: scan_label<generic>>:
    3608:	push   rbp
    3609:	mov    rbp,rsp
    360c:	mov    rsi,QWORD PTR [rdx]
    360f:	mov    r8,QWORD PTR [rdx+0x8]
    3613:	mov    rcx,QWORD PTR [rdx+0x10]
    3617:	mov    rdx,r8
    361a:	call   361f <botlish_entry_23+0x17>
			361b: R_X86_64_PLT32	botlish_fn_23-0x4 ; scan_label<generic>
    361f:	mov    rsp,rbp
    3622:	pop    rbp
    3623:	ret
    3624:	add    BYTE PTR [rax],al
	...

0000000000003628 <botlish_fn_24: scan_alpha<generic>>:
    3628:	push   rbp
    3629:	mov    rbp,rsp
    362c:	sub    rsp,0x50
    3630:	mov    QWORD PTR [rsp+0x30],rbx
    3635:	mov    QWORD PTR [rsp+0x38],r12
    363a:	mov    QWORD PTR [rsp+0x40],r13
    363f:	mov    QWORD PTR [rsp+0x48],r14
    3644:	mov    r14,rdi
    3647:	mov    QWORD PTR [rsp+0x18],0x0
    3650:	mov    QWORD PTR [rsp],rsi
    3654:	mov    r13,rsi
    3657:	mov    QWORD PTR [rsp+0x8],rdx
    365c:	mov    r12,rdx
    365f:	mov    QWORD PTR [rsp+0x10],rcx
    3664:	mov    rbx,rcx
    3667:	mov    r11d,0x1
    366d:	mov    rsi,r13
    3670:	test   rsi,0x1
    3677:	jne    3697 <botlish_fn_24+0x6f>
    367d:	xor    r11d,r11d
    3680:	test   rsi,0x7
    3687:	jne    3697 <botlish_fn_24+0x6f>
    368d:	movzx  rax,BYTE PTR [rsi]
    3691:	cmp    al,0x1
    3693:	sete   r11b
    3697:	test   r11b,r11b
    369a:	jne    36bb <botlish_fn_24+0x93>
    36a0:	mov    rdi,r14
    36a3:	mov    rax,QWORD PTR [rdi+0x10]
    36a7:	mov    rcx,QWORD PTR [rax+0xc0]
    36ae:	xor    rdx,rdx
    36b1:	call   36b6 <botlish_fn_24+0x8e>
			36b2: R_X86_64_PLT32	rt_type_error-0x4
    36b6:	jmp    374a <botlish_fn_24+0x122>
    36bb:	mov    rax,rsi
    36be:	and    rax,r12
    36c1:	mov    r13,rsi
    36c4:	test   rax,0x1
    36ca:	jne    36f3 <botlish_fn_24+0xcb>
    36d0:	mov    rdx,r12
    36d3:	mov    rsi,r13
    36d6:	mov    rdi,r14
    36d9:	call   36de <botlish_fn_24+0xb6>
			36da: R_X86_64_PLT32	rt_int_cmp-0x4
    36de:	mov    ecx,0x2
    36e3:	test   rax,rax
    36e6:	cmovge rcx,QWORD PTR [rip+0x112]        # 3800 <botlish_fn_24+0x1d8>
    36ee:	jmp    3706 <botlish_fn_24+0xde>
    36f3:	mov    ecx,0x2
    36f8:	mov    rsi,r13
    36fb:	cmp    rsi,r12
    36fe:	cmovge rcx,QWORD PTR [rip+0xfa]        # 3800 <botlish_fn_24+0x1d8>
    3706:	cmp    rcx,0x6
    370a:	je     37de <botlish_fn_24+0x1b6>
    3710:	lea    rcx,[rsp+0x20]
    3715:	mov    rdx,rbx
    3718:	mov    rsi,r13
    371b:	mov    rdi,r14
    371e:	call   3723 <botlish_fn_24+0xfb>
			371f: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    3723:	test   rax,rax
    3726:	mov    rsi,rax
    3729:	je     374a <botlish_fn_24+0x122>
    372f:	mov    rdx,QWORD PTR [rsp+0x20]
    3734:	mov    rcx,QWORD PTR [rsp+0x28]
    3739:	mov    rdi,r14
    373c:	call   3741 <botlish_fn_24+0x119>
			373d: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    3741:	test   rax,rax
    3744:	jne    376a <botlish_fn_24+0x142>
    374a:	xor    rax,rax
    374d:	mov    rbx,QWORD PTR [rsp+0x30]
    3752:	mov    r12,QWORD PTR [rsp+0x38]
    3757:	mov    r13,QWORD PTR [rsp+0x40]
    375c:	mov    r14,QWORD PTR [rsp+0x48]
    3761:	add    rsp,0x50
    3765:	mov    rsp,rbp
    3768:	pop    rbp
    3769:	ret
    376a:	cmp    rax,0x6
    376e:	je     377c <botlish_fn_24+0x154>
    3774:	mov    rax,r13
    3777:	jmp    37e1 <botlish_fn_24+0x1b9>
    377c:	mov    QWORD PTR [rsp+0x18],0x3
    3785:	mov    rsi,r13
    3788:	test   rsi,0x1
    378f:	je     37b5 <botlish_fn_24+0x18d>
    3795:	mov    rsi,r13
    3798:	mov    r11,rsi
    379b:	add    r11,0x2
    379f:	seto   al
    37a2:	test   al,al
    37a4:	jne    37b5 <botlish_fn_24+0x18d>
    37aa:	mov    rsi,r11
    37ad:	mov    r13,r11
    37b0:	jmp    37cb <botlish_fn_24+0x1a3>
    37b5:	mov    edx,0x3
    37ba:	mov    rsi,r13
    37bd:	mov    rdi,r14
    37c0:	call   37c5 <botlish_fn_24+0x19d>
			37c1: R_X86_64_PLT32	rt_int_add-0x4
    37c5:	mov    rsi,rax
    37c8:	mov    r13,rax
    37cb:	mov    QWORD PTR [rsp],rsi
    37cf:	mov    QWORD PTR [rsp+0x8],r12
    37d4:	mov    QWORD PTR [rsp+0x10],rbx
    37d9:	jmp    3667 <botlish_fn_24+0x3f>
    37de:	mov    rax,r13
    37e1:	mov    rbx,QWORD PTR [rsp+0x30]
    37e6:	mov    r12,QWORD PTR [rsp+0x38]
    37eb:	mov    r13,QWORD PTR [rsp+0x40]
    37f0:	mov    r14,QWORD PTR [rsp+0x48]
    37f5:	add    rsp,0x50
    37f9:	mov    rsp,rbp
    37fc:	pop    rbp
    37fd:	ret
    37fe:	add    BYTE PTR [rax],al
    3800:	(bad)
    3801:	add    BYTE PTR [rax],al
    3803:	add    BYTE PTR [rax],al
    3805:	add    BYTE PTR [rax],al
	...

0000000000003808 <botlish_entry_24: scan_alpha<generic>>:
    3808:	push   rbp
    3809:	mov    rbp,rsp
    380c:	mov    rsi,QWORD PTR [rdx]
    380f:	mov    r8,QWORD PTR [rdx+0x8]
    3813:	mov    rcx,QWORD PTR [rdx+0x10]
    3817:	mov    rdx,r8
    381a:	call   381f <botlish_entry_24+0x17>
			381b: R_X86_64_PLT32	botlish_fn_24-0x4 ; scan_alpha<generic>
    381f:	mov    rsp,rbp
    3822:	pop    rbp
    3823:	ret
    3824:	add    BYTE PTR [rax],al
	...

0000000000003828 <botlish_fn_25: tld_ok<generic>>:
    3828:	push   rbp
    3829:	mov    rbp,rsp
    382c:	sub    rsp,0x40
    3830:	mov    QWORD PTR [rsp+0x20],rbx
    3835:	mov    QWORD PTR [rsp+0x28],r12
    383a:	mov    QWORD PTR [rsp+0x30],r13
    383f:	mov    QWORD PTR [rsp+0x38],r14
    3844:	mov    rbx,rdi
    3847:	mov    QWORD PTR [rsp],rsi
    384b:	mov    r12,rsi
    384e:	mov    QWORD PTR [rsp+0x8],rdx
    3853:	mov    r14,rdx
    3856:	mov    QWORD PTR [rsp+0x10],rcx
    385b:	mov    rdx,r14
    385e:	mov    rsi,r12
    3861:	mov    rdi,rbx
    3864:	call   3869 <botlish_fn_25+0x41>
			3865: R_X86_64_PLT32	botlish_fn_24-0x4 ; scan_alpha<generic>
    3869:	mov    rsi,rax
    386c:	mov    r13,rax
    386f:	test   rax,rsi
    3872:	je     3935 <botlish_fn_25+0x10d>
    3878:	mov    rax,r13
    387b:	mov    QWORD PTR [rsp+0x8],rax
    3880:	mov    rdx,r14
    3883:	and    rax,rdx
    3886:	test   rax,0x1
    388c:	jne    38b5 <botlish_fn_25+0x8d>
    3892:	mov    rsi,r13
    3895:	mov    rdi,rbx
    3898:	call   389d <botlish_fn_25+0x75>
			3899: R_X86_64_PLT32	rt_int_cmp-0x4
    389d:	mov    ecx,0x2
    38a2:	test   rax,rax
    38a5:	cmove  rcx,QWORD PTR [rip+0x15b]        # 3a08 <botlish_fn_25+0x1e0>
    38ad:	mov    rax,r13
    38b0:	jmp    38c8 <botlish_fn_25+0xa0>
    38b5:	mov    ecx,0x2
    38ba:	mov    rax,r13
    38bd:	cmp    rax,rdx
    38c0:	cmove  rcx,QWORD PTR [rip+0x140]        # 3a08 <botlish_fn_25+0x1e0>
    38c8:	cmp    rcx,0x6
    38cc:	je     38df <botlish_fn_25+0xb7>
    38d2:	mov    ecx,0x2
    38d7:	mov    rax,rcx
    38da:	jmp    39e7 <botlish_fn_25+0x1bf>
    38df:	mov    ecx,0x1
    38e4:	mov    rsi,r12
    38e7:	test   rsi,0x1
    38ee:	jne    3914 <botlish_fn_25+0xec>
    38f4:	xor    ecx,ecx
    38f6:	mov    rsi,r12
    38f9:	test   rsi,0x7
    3900:	jne    3914 <botlish_fn_25+0xec>
    3906:	mov    rsi,r12
    3909:	movzx  rcx,BYTE PTR [rsi]
    390d:	rex cmp cl,0x1
    3911:	sete   cl
    3914:	test   cl,cl
    3916:	jne    3955 <botlish_fn_25+0x12d>
    391c:	mov    rdi,rbx
    391f:	mov    rsi,QWORD PTR [rdi+0x10]
    3923:	mov    rcx,QWORD PTR [rsi+0x130]
    392a:	xor    rdx,rdx
    392d:	mov    rsi,r12
    3930:	call   3935 <botlish_fn_25+0x10d>
			3931: R_X86_64_PLT32	rt_type_error-0x4
    3935:	xor    rax,rax
    3938:	mov    rbx,QWORD PTR [rsp+0x20]
    393d:	mov    r12,QWORD PTR [rsp+0x28]
    3942:	mov    r13,QWORD PTR [rsp+0x30]
    3947:	mov    r14,QWORD PTR [rsp+0x38]
    394c:	add    rsp,0x40
    3950:	mov    rsp,rbp
    3953:	pop    rbp
    3954:	ret
    3955:	mov    rsi,r12
    3958:	mov    rdi,rax
    395b:	and    rdi,rsi
    395e:	test   rdi,0x1
    3965:	jne    3976 <botlish_fn_25+0x14e>
    396b:	mov    rdx,r12
    396e:	mov    rsi,rax
    3971:	jmp    3999 <botlish_fn_25+0x171>
    3976:	mov    rsi,r12
    3979:	mov    r8,rax
    397c:	sub    r8,rsi
    397f:	mov    r13,rax
    3982:	seto   r10b
    3986:	lea    rsi,[r8+0x1]
    398a:	test   r10b,r10b
    398d:	je     39a4 <botlish_fn_25+0x17c>
    3993:	mov    rdx,r12
    3996:	mov    rsi,r13
    3999:	mov    rdi,rbx
    399c:	call   39a1 <botlish_fn_25+0x179>
			399d: R_X86_64_PLT32	rt_int_sub-0x4
    39a1:	mov    rsi,rax
    39a4:	test   rsi,0x1
    39ab:	jne    39d6 <botlish_fn_25+0x1ae>
    39b1:	mov    edx,0x5
    39b6:	mov    rdi,rbx
    39b9:	call   39be <botlish_fn_25+0x196>
			39ba: R_X86_64_PLT32	rt_int_cmp-0x4
    39be:	mov    ecx,0x2
    39c3:	test   rax,rax
    39c6:	mov    rax,rcx
    39c9:	cmovge rax,QWORD PTR [rip+0x37]        # 3a08 <botlish_fn_25+0x1e0>
    39d1:	jmp    39e7 <botlish_fn_25+0x1bf>
    39d6:	mov    eax,0x2
    39db:	cmp    rsi,0x5
    39df:	cmovge rax,QWORD PTR [rip+0x21]        # 3a08 <botlish_fn_25+0x1e0>
    39e7:	mov    rbx,QWORD PTR [rsp+0x20]
    39ec:	mov    r12,QWORD PTR [rsp+0x28]
    39f1:	mov    r13,QWORD PTR [rsp+0x30]
    39f6:	mov    r14,QWORD PTR [rsp+0x38]
    39fb:	add    rsp,0x40
    39ff:	mov    rsp,rbp
    3a02:	pop    rbp
    3a03:	ret
    3a04:	add    BYTE PTR [rax],al
    3a06:	add    BYTE PTR [rax],al
    3a08:	(bad)
    3a09:	add    BYTE PTR [rax],al
    3a0b:	add    BYTE PTR [rax],al
    3a0d:	add    BYTE PTR [rax],al
	...

0000000000003a10 <botlish_entry_25: tld_ok<generic>>:
    3a10:	push   rbp
    3a11:	mov    rbp,rsp
    3a14:	mov    rsi,QWORD PTR [rdx]
    3a17:	mov    r8,QWORD PTR [rdx+0x8]
    3a1b:	mov    rcx,QWORD PTR [rdx+0x10]
    3a1f:	mov    rdx,r8
    3a22:	call   3a27 <botlish_entry_25+0x17>
			3a23: R_X86_64_PLT32	botlish_fn_25-0x4 ; tld_ok<generic>
    3a27:	mov    rsp,rbp
    3a2a:	pop    rbp
    3a2b:	ret
    3a2c:	add    BYTE PTR [rax],al
	...

0000000000003a30 <botlish_fn_26: domain_loop<generic>>:
    3a30:	push   rbp
    3a31:	mov    rbp,rsp
    3a34:	sub    rsp,0x70
    3a38:	mov    QWORD PTR [rsp+0x40],rbx
    3a3d:	mov    QWORD PTR [rsp+0x48],r12
    3a42:	mov    QWORD PTR [rsp+0x50],r13
    3a47:	mov    QWORD PTR [rsp+0x58],r14
    3a4c:	mov    QWORD PTR [rsp+0x60],r15
    3a51:	mov    QWORD PTR [rsp+0x18],0x0
    3a5a:	mov    QWORD PTR [rsp],rsi
    3a5e:	mov    QWORD PTR [rsp+0x8],rdx
    3a63:	mov    QWORD PTR [rsp+0x10],rcx
    3a68:	lea    rbx,[rsp+0x20]
    3a6d:	mov    r12,rdi
    3a70:	mov    r13,rcx
    3a73:	mov    r14,rdx
    3a76:	mov    QWORD PTR [rsp+0x30],rsi
    3a7b:	mov    rcx,r13
    3a7e:	mov    rdx,r14
    3a81:	mov    rsi,QWORD PTR [rsp+0x30]
    3a86:	mov    rdi,r12
    3a89:	call   3a8e <botlish_fn_26+0x5e>
			3a8a: R_X86_64_PLT32	botlish_fn_23-0x4 ; scan_label<generic>
    3a8e:	mov    rcx,rax
    3a91:	mov    r15,rax
    3a94:	test   rax,rcx
    3a97:	je     3be7 <botlish_fn_26+0x1b7>
    3a9d:	mov    rax,r15
    3aa0:	mov    QWORD PTR [rsp],rax
    3aa4:	mov    rdx,QWORD PTR [rsp+0x30]
    3aa9:	and    rax,rdx
    3aac:	test   rax,0x1
    3ab2:	jne    3ad1 <botlish_fn_26+0xa1>
    3ab8:	mov    rsi,r15
    3abb:	mov    rdi,r12
    3abe:	call   3ac3 <botlish_fn_26+0x93>
			3abf: R_X86_64_PLT32	rt_value_eq-0x4
    3ac3:	test   rax,rax
    3ac6:	je     3be7 <botlish_fn_26+0x1b7>
    3acc:	jmp    3ae1 <botlish_fn_26+0xb1>
    3ad1:	mov    eax,0x2
    3ad6:	cmp    r15,rdx
    3ad9:	cmove  rax,QWORD PTR [rip+0x187]        # 3c68 <botlish_fn_26+0x238>
    3ae1:	cmp    rax,0x6
    3ae5:	je     3c3d <botlish_fn_26+0x20d>
    3aeb:	mov    rax,r15
    3aee:	and    rax,r14
    3af1:	test   rax,0x1
    3af7:	jne    3b20 <botlish_fn_26+0xf0>
    3afd:	mov    rdx,r14
    3b00:	mov    rsi,r15
    3b03:	mov    rdi,r12
    3b06:	call   3b0b <botlish_fn_26+0xdb>
			3b07: R_X86_64_PLT32	rt_int_cmp-0x4
    3b0b:	mov    ecx,0x2
    3b10:	test   rax,rax
    3b13:	cmovge rcx,QWORD PTR [rip+0x14d]        # 3c68 <botlish_fn_26+0x238>
    3b1b:	jmp    3b30 <botlish_fn_26+0x100>
    3b20:	mov    ecx,0x2
    3b25:	cmp    r15,r14
    3b28:	cmovge rcx,QWORD PTR [rip+0x138]        # 3c68 <botlish_fn_26+0x238>
    3b30:	cmp    rcx,0x6
    3b34:	je     3c2e <botlish_fn_26+0x1fe>
    3b3a:	mov    rcx,rbx
    3b3d:	mov    rdx,r13
    3b40:	mov    rsi,r15
    3b43:	mov    rdi,r12
    3b46:	call   3b4b <botlish_fn_26+0x11b>
			3b47: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    3b4b:	test   rax,rax
    3b4e:	je     3be7 <botlish_fn_26+0x1b7>
    3b54:	mov    rdx,QWORD PTR [rsp+0x20]
    3b59:	mov    rcx,QWORD PTR [rsp+0x28]
    3b5e:	mov    rsi,QWORD PTR [r12+0x10]
    3b63:	mov    r8,QWORD PTR [rsi+0x120]
    3b6a:	mov    rsi,rax
    3b6d:	mov    rdi,r12
    3b70:	call   3b75 <botlish_fn_26+0x145>
			3b71: R_X86_64_PLT32	rt_str_region_eq-0x4
    3b75:	cmp    rax,0x6
    3b79:	je     3b8b <botlish_fn_26+0x15b>
    3b7f:	mov    r14,0xffffffffffffffff
    3b86:	jmp    3c35 <botlish_fn_26+0x205>
    3b8b:	mov    QWORD PTR [rsp+0x18],0x3
    3b94:	test   r15,0x1
    3b9b:	je     3bb3 <botlish_fn_26+0x183>
    3ba1:	mov    rdx,r15
    3ba4:	add    rdx,0x2
    3ba8:	seto   al
    3bab:	test   al,al
    3bad:	je     3bc6 <botlish_fn_26+0x196>
    3bb3:	mov    edx,0x3
    3bb8:	mov    rsi,r15
    3bbb:	mov    rdi,r12
    3bbe:	call   3bc3 <botlish_fn_26+0x193>
			3bbf: R_X86_64_PLT32	rt_int_add-0x4
    3bc3:	mov    rdx,rax
    3bc6:	mov    QWORD PTR [rsp],rdx
    3bca:	mov    r15,rdx
    3bcd:	mov    rcx,r13
    3bd0:	mov    rdx,r14
    3bd3:	mov    rsi,r15
    3bd6:	mov    rdi,r12
    3bd9:	call   3bde <botlish_fn_26+0x1ae>
			3bda: R_X86_64_PLT32	botlish_fn_25-0x4 ; tld_ok<generic>
    3bde:	test   rax,rax
    3be1:	jne    3c0c <botlish_fn_26+0x1dc>
    3be7:	xor    rax,rax
    3bea:	mov    rbx,QWORD PTR [rsp+0x40]
    3bef:	mov    r12,QWORD PTR [rsp+0x48]
    3bf4:	mov    r13,QWORD PTR [rsp+0x50]
    3bf9:	mov    r14,QWORD PTR [rsp+0x58]
    3bfe:	mov    r15,QWORD PTR [rsp+0x60]
    3c03:	add    rsp,0x70
    3c07:	mov    rsp,rbp
    3c0a:	pop    rbp
    3c0b:	ret
    3c0c:	cmp    rax,0x6
    3c10:	je     3c35 <botlish_fn_26+0x205>
    3c16:	mov    QWORD PTR [rsp],r15
    3c1a:	mov    QWORD PTR [rsp+0x8],r14
    3c1f:	mov    QWORD PTR [rsp+0x10],r13
    3c24:	mov    QWORD PTR [rsp+0x30],r15
    3c29:	jmp    3a7b <botlish_fn_26+0x4b>
    3c2e:	mov    r14,0xffffffffffffffff
    3c35:	mov    rax,r14
    3c38:	jmp    3c44 <botlish_fn_26+0x214>
    3c3d:	mov    rax,0xffffffffffffffff
    3c44:	mov    rbx,QWORD PTR [rsp+0x40]
    3c49:	mov    r12,QWORD PTR [rsp+0x48]
    3c4e:	mov    r13,QWORD PTR [rsp+0x50]
    3c53:	mov    r14,QWORD PTR [rsp+0x58]
    3c58:	mov    r15,QWORD PTR [rsp+0x60]
    3c5d:	add    rsp,0x70
    3c61:	mov    rsp,rbp
    3c64:	pop    rbp
    3c65:	ret
    3c66:	add    BYTE PTR [rax],al
    3c68:	(bad)
    3c69:	add    BYTE PTR [rax],al
    3c6b:	add    BYTE PTR [rax],al
    3c6d:	add    BYTE PTR [rax],al
	...

0000000000003c70 <botlish_entry_26: domain_loop<generic>>:
    3c70:	push   rbp
    3c71:	mov    rbp,rsp
    3c74:	mov    rsi,QWORD PTR [rdx]
    3c77:	mov    r8,QWORD PTR [rdx+0x8]
    3c7b:	mov    rcx,QWORD PTR [rdx+0x10]
    3c7f:	mov    rdx,r8
    3c82:	call   3c87 <botlish_entry_26+0x17>
			3c83: R_X86_64_PLT32	botlish_fn_26-0x4 ; domain_loop<generic>
    3c87:	mov    rsp,rbp
    3c8a:	pop    rbp
    3c8b:	ret

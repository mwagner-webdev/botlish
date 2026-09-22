; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 16713  (per function: 937 203 329 112 109 1425 484 864 506 952 504 681 769 450 884 644 540 540 636 681 769 450 884 644 540 540 636)
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
     454:	sub    rsp,0x40
     458:	mov    QWORD PTR [rsp+0x20],rbx
     45d:	mov    QWORD PTR [rsp+0x28],r12
     462:	mov    QWORD PTR [rsp+0x30],r13
     467:	mov    r12,rdi
     46a:	mov    QWORD PTR [rsp+0x10],0x0
     473:	mov    QWORD PTR [rsp],rsi
     477:	mov    QWORD PTR [rsp+0x8],0x1f
     480:	test   rsi,0x1
     487:	jne    4a5 <botlish_fn_2+0x55>
     48d:	mov    edx,0x1f
     492:	mov    rbx,rsi
     495:	mov    rdi,r12
     498:	call   49d <botlish_fn_2+0x4d>
			499: R_X86_64_PLT32	rt_int_and-0x4
     49d:	mov    rsi,rax
     4a0:	jmp    4ac <botlish_fn_2+0x5c>
     4a5:	mov    rbx,rsi
     4a8:	and    rsi,0x1f
     4ac:	mov    QWORD PTR [rsp+0x8],rsi
     4b1:	mov    r13,rsi
     4b4:	mov    edx,0x9
     4b9:	mov    QWORD PTR [rsp+0x10],0x9
     4c2:	mov    rsi,rbx
     4c5:	mov    rdi,r12
     4c8:	call   4cd <botlish_fn_2+0x7d>
			4c9: R_X86_64_PLT32	rt_int_shr-0x4
     4cd:	test   rax,rax
     4d0:	jne    4f1 <botlish_fn_2+0xa1>
     4d6:	xor    rax,rax
     4d9:	mov    rbx,QWORD PTR [rsp+0x20]
     4de:	mov    r12,QWORD PTR [rsp+0x28]
     4e3:	mov    r13,QWORD PTR [rsp+0x30]
     4e8:	add    rsp,0x40
     4ec:	mov    rsp,rbp
     4ef:	pop    rbp
     4f0:	ret
     4f1:	mov    QWORD PTR [rsp],rax
     4f5:	mov    rsi,r13
     4f8:	mov    rcx,rsi
     4fb:	and    rcx,rax
     4fe:	mov    rdx,rax
     501:	test   rcx,0x1
     508:	jne    51e <botlish_fn_2+0xce>
     50e:	mov    rdi,r12
     511:	call   516 <botlish_fn_2+0xc6>
			512: R_X86_64_PLT32	rt_int_or-0x4
     516:	mov    rsi,rax
     519:	jmp    521 <botlish_fn_2+0xd1>
     51e:	or     rsi,rdx
     521:	mov    QWORD PTR [rsp],rsi
     525:	mov    QWORD PTR [rsp+0x8],0x1f
     52e:	test   rsi,0x1
     535:	jne    54d <botlish_fn_2+0xfd>
     53b:	mov    edx,0x1f
     540:	mov    rdi,r12
     543:	call   548 <botlish_fn_2+0xf8>
			544: R_X86_64_PLT32	rt_int_and-0x4
     548:	jmp    554 <botlish_fn_2+0x104>
     54d:	and    rsi,0x1f
     551:	mov    rax,rsi
     554:	mov    rbx,QWORD PTR [rsp+0x20]
     559:	mov    r12,QWORD PTR [rsp+0x28]
     55e:	mov    r13,QWORD PTR [rsp+0x30]
     563:	add    rsp,0x40
     567:	mov    rsp,rbp
     56a:	pop    rbp
     56b:	ret

000000000000056c <botlish_entry_2: byte::nibble<int>>:
     56c:	push   rbp
     56d:	mov    rbp,rsp
     570:	mov    rsi,QWORD PTR [rdx]
     573:	call   578 <botlish_entry_2+0xc>
			574: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::nibble<int>
     578:	mov    rsp,rbp
     57b:	pop    rbp
     57c:	ret

000000000000057d <botlish_fn_3: web::uri_escape_text<generic>>:
     57d:	push   rbp
     57e:	mov    rbp,rsp
     581:	sub    rsp,0x20
     585:	mov    QWORD PTR [rsp],rdx
     589:	mov    r9,rdx
     58c:	mov    edx,0x1
     591:	mov    QWORD PTR [rsp+0x8],0x1
     59a:	mov    rax,QWORD PTR [rdi+0x10]
     59e:	mov    rcx,QWORD PTR [rax+0xa0]
     5a5:	mov    QWORD PTR [rsp+0x10],rcx
     5aa:	mov    rax,QWORD PTR [rsi+0x20]
     5ae:	mov    r8,QWORD PTR [rax]
     5b1:	mov    QWORD PTR [rsp+0x18],r8
     5b6:	mov    rsi,r9
     5b9:	call   5be <botlish_fn_3+0x41>
			5ba: R_X86_64_PLT32	botlish_fn_9-0x4 ; esc_from<generic>
     5be:	test   rax,rax
     5c1:	jne    5d3 <botlish_fn_3+0x56>
     5c7:	xor    rax,rax
     5ca:	add    rsp,0x20
     5ce:	mov    rsp,rbp
     5d1:	pop    rbp
     5d2:	ret
     5d3:	add    rsp,0x20
     5d7:	mov    rsp,rbp
     5da:	pop    rbp
     5db:	ret

00000000000005dc <botlish_entry_3: web::uri_escape_text<generic>>:
     5dc:	push   rbp
     5dd:	mov    rbp,rsp
     5e0:	mov    rdx,QWORD PTR [rdx]
     5e3:	call   5e8 <botlish_entry_3+0xc>
			5e4: R_X86_64_PLT32	botlish_fn_3-0x4 ; web::uri_escape_text<generic>
     5e8:	mov    rsp,rbp
     5eb:	pop    rbp
     5ec:	ret

00000000000005ed <botlish_fn_4: high_nibble<generic>>:
     5ed:	push   rbp
     5ee:	mov    rbp,rsp
     5f1:	sub    rsp,0x20
     5f5:	mov    QWORD PTR [rsp+0x10],r12
     5fa:	mov    r12,rdi
     5fd:	mov    QWORD PTR [rsp],rsi
     601:	mov    rdi,r12
     604:	call   609 <botlish_fn_4+0x1c>
			605: R_X86_64_PLT32	botlish_fn_1-0x4 ; byte::high_nibble<generic>
     609:	test   rax,rax
     60c:	je     62a <botlish_fn_4+0x3d>
     612:	mov    QWORD PTR [rsp],rax
     616:	mov    rsi,rax
     619:	mov    rdi,r12
     61c:	call   621 <botlish_fn_4+0x34>
			61d: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::nibble<int>
     621:	test   rax,rax
     624:	jne    63b <botlish_fn_4+0x4e>
     62a:	xor    rax,rax
     62d:	mov    r12,QWORD PTR [rsp+0x10]
     632:	add    rsp,0x20
     636:	mov    rsp,rbp
     639:	pop    rbp
     63a:	ret
     63b:	mov    r12,QWORD PTR [rsp+0x10]
     640:	add    rsp,0x20
     644:	mov    rsp,rbp
     647:	pop    rbp
     648:	ret

0000000000000649 <botlish_entry_4: high_nibble<generic>>:
     649:	push   rbp
     64a:	mov    rbp,rsp
     64d:	mov    rsi,QWORD PTR [rdx]
     650:	call   655 <botlish_entry_4+0xc>
			651: R_X86_64_PLT32	botlish_fn_4-0x4 ; high_nibble<generic>
     655:	mov    rsp,rbp
     658:	pop    rbp
     659:	ret
     65a:	add    BYTE PTR [rax],al
     65c:	add    BYTE PTR [rax],al
	...

0000000000000660 <botlish_fn_5: is_unreserved<generic>>:
     660:	push   rbp
     661:	mov    rbp,rsp
     664:	sub    rsp,0x20
     668:	mov    QWORD PTR [rsp],rbx
     66c:	mov    QWORD PTR [rsp+0x8],r12
     671:	mov    QWORD PTR [rsp+0x10],r13
     676:	mov    r8d,0x1
     67c:	test   rsi,0x1
     683:	jne    6a3 <botlish_fn_5+0x43>
     689:	xor    r8d,r8d
     68c:	test   rsi,0x7
     693:	jne    6a3 <botlish_fn_5+0x43>
     699:	movzx  rax,BYTE PTR [rsi]
     69d:	cmp    al,0x1
     69f:	sete   r8b
     6a3:	test   r8b,r8b
     6a6:	jne    6dc <botlish_fn_5+0x7c>
     6ac:	mov    rdx,QWORD PTR [rdi+0x10]
     6b0:	mov    rcx,QWORD PTR [rdx+0xa8]
     6b7:	xor    rbx,rbx
     6ba:	mov    rdx,rbx
     6bd:	call   6c2 <botlish_fn_5+0x62>
			6be: R_X86_64_PLT32	rt_type_error-0x4
     6c2:	mov    rax,rbx
     6c5:	mov    rbx,QWORD PTR [rsp]
     6c9:	mov    r12,QWORD PTR [rsp+0x8]
     6ce:	mov    r13,QWORD PTR [rsp+0x10]
     6d3:	add    rsp,0x20
     6d7:	mov    rsp,rbp
     6da:	pop    rbp
     6db:	ret
     6dc:	mov    r12,rdi
     6df:	test   rsi,0x1
     6e6:	mov    rbx,rsi
     6e9:	jne    714 <botlish_fn_5+0xb4>
     6ef:	mov    edx,0x59
     6f4:	mov    rsi,rbx
     6f7:	mov    rdi,r12
     6fa:	call   6ff <botlish_fn_5+0x9f>
			6fb: R_X86_64_PLT32	rt_int_cmp-0x4
     6ff:	mov    ecx,0x2
     704:	test   rax,rax
     707:	cmovle rcx,QWORD PTR [rip+0x461]        # b70 <botlish_fn_5+0x510>
     70f:	jmp    728 <botlish_fn_5+0xc8>
     714:	mov    ecx,0x2
     719:	mov    rsi,rbx
     71c:	cmp    rsi,0x59
     720:	cmovle rcx,QWORD PTR [rip+0x448]        # b70 <botlish_fn_5+0x510>
     728:	mov    eax,0x6
     72d:	mov    r13,rax
     730:	cmp    rcx,0x6
     734:	je     b53 <botlish_fn_5+0x4f3>
     73a:	mov    rsi,rbx
     73d:	test   rsi,0x1
     744:	jne    76f <botlish_fn_5+0x10f>
     74a:	mov    edx,0x5d
     74f:	mov    rsi,rbx
     752:	mov    rdi,r12
     755:	call   75a <botlish_fn_5+0xfa>
			756: R_X86_64_PLT32	rt_int_cmp-0x4
     75a:	mov    ecx,0x2
     75f:	test   rax,rax
     762:	cmovle rcx,QWORD PTR [rip+0x406]        # b70 <botlish_fn_5+0x510>
     76a:	jmp    783 <botlish_fn_5+0x123>
     76f:	mov    ecx,0x2
     774:	mov    rsi,rbx
     777:	cmp    rsi,0x5d
     77b:	cmovle rcx,QWORD PTR [rip+0x3ed]        # b70 <botlish_fn_5+0x510>
     783:	cmp    rcx,0x6
     787:	je     b4b <botlish_fn_5+0x4eb>
     78d:	mov    rsi,rbx
     790:	test   rsi,0x1
     797:	jne    7c2 <botlish_fn_5+0x162>
     79d:	mov    edx,0x5f
     7a2:	mov    rsi,rbx
     7a5:	mov    rdi,r12
     7a8:	call   7ad <botlish_fn_5+0x14d>
			7a9: R_X86_64_PLT32	rt_int_cmp-0x4
     7ad:	mov    ecx,0x2
     7b2:	test   rax,rax
     7b5:	cmovle rcx,QWORD PTR [rip+0x3b3]        # b70 <botlish_fn_5+0x510>
     7bd:	jmp    7d6 <botlish_fn_5+0x176>
     7c2:	mov    ecx,0x2
     7c7:	mov    rsi,rbx
     7ca:	cmp    rsi,0x5f
     7ce:	cmovle rcx,QWORD PTR [rip+0x39a]        # b70 <botlish_fn_5+0x510>
     7d6:	cmp    rcx,0x6
     7da:	je     b41 <botlish_fn_5+0x4e1>
     7e0:	mov    rsi,rbx
     7e3:	test   rsi,0x1
     7ea:	jne    815 <botlish_fn_5+0x1b5>
     7f0:	mov    edx,0x73
     7f5:	mov    rsi,rbx
     7f8:	mov    rdi,r12
     7fb:	call   800 <botlish_fn_5+0x1a0>
			7fc: R_X86_64_PLT32	rt_int_cmp-0x4
     800:	mov    ecx,0x2
     805:	test   rax,rax
     808:	cmovle rcx,QWORD PTR [rip+0x360]        # b70 <botlish_fn_5+0x510>
     810:	jmp    829 <botlish_fn_5+0x1c9>
     815:	mov    ecx,0x2
     81a:	mov    rsi,rbx
     81d:	cmp    rsi,0x73
     821:	cmovle rcx,QWORD PTR [rip+0x347]        # b70 <botlish_fn_5+0x510>
     829:	cmp    rcx,0x6
     82d:	je     b39 <botlish_fn_5+0x4d9>
     833:	mov    rsi,rbx
     836:	test   rsi,0x1
     83d:	jne    868 <botlish_fn_5+0x208>
     843:	mov    edx,0x81
     848:	mov    rsi,rbx
     84b:	mov    rdi,r12
     84e:	call   853 <botlish_fn_5+0x1f3>
			84f: R_X86_64_PLT32	rt_int_cmp-0x4
     853:	mov    ecx,0x2
     858:	test   rax,rax
     85b:	cmovle rcx,QWORD PTR [rip+0x30d]        # b70 <botlish_fn_5+0x510>
     863:	jmp    87f <botlish_fn_5+0x21f>
     868:	mov    ecx,0x2
     86d:	mov    rsi,rbx
     870:	cmp    rsi,0x81
     877:	cmovle rcx,QWORD PTR [rip+0x2f1]        # b70 <botlish_fn_5+0x510>
     87f:	cmp    rcx,0x6
     883:	je     b2f <botlish_fn_5+0x4cf>
     889:	mov    rsi,rbx
     88c:	test   rsi,0x1
     893:	jne    8be <botlish_fn_5+0x25e>
     899:	mov    edx,0xb5
     89e:	mov    rsi,rbx
     8a1:	mov    rdi,r12
     8a4:	call   8a9 <botlish_fn_5+0x249>
			8a5: R_X86_64_PLT32	rt_int_cmp-0x4
     8a9:	mov    ecx,0x2
     8ae:	test   rax,rax
     8b1:	cmovle rcx,QWORD PTR [rip+0x2b7]        # b70 <botlish_fn_5+0x510>
     8b9:	jmp    8d5 <botlish_fn_5+0x275>
     8be:	mov    ecx,0x2
     8c3:	mov    rsi,rbx
     8c6:	cmp    rsi,0xb5
     8cd:	cmovle rcx,QWORD PTR [rip+0x29b]        # b70 <botlish_fn_5+0x510>
     8d5:	cmp    rcx,0x6
     8d9:	je     b27 <botlish_fn_5+0x4c7>
     8df:	mov    rsi,rbx
     8e2:	test   rsi,0x1
     8e9:	jne    914 <botlish_fn_5+0x2b4>
     8ef:	mov    edx,0xbd
     8f4:	mov    rsi,rbx
     8f7:	mov    rdi,r12
     8fa:	call   8ff <botlish_fn_5+0x29f>
			8fb: R_X86_64_PLT32	rt_int_cmp-0x4
     8ff:	mov    ecx,0x2
     904:	test   rax,rax
     907:	cmovle rcx,QWORD PTR [rip+0x261]        # b70 <botlish_fn_5+0x510>
     90f:	jmp    92b <botlish_fn_5+0x2cb>
     914:	mov    ecx,0x2
     919:	mov    rsi,rbx
     91c:	cmp    rsi,0xbd
     923:	cmovle rcx,QWORD PTR [rip+0x245]        # b70 <botlish_fn_5+0x510>
     92b:	cmp    rcx,0x6
     92f:	je     b1d <botlish_fn_5+0x4bd>
     935:	mov    rsi,rbx
     938:	test   rsi,0x1
     93f:	jne    96b <botlish_fn_5+0x30b>
     945:	mov    edx,0xbf
     94a:	mov    rsi,rbx
     94d:	mov    rdi,r12
     950:	call   955 <botlish_fn_5+0x2f5>
			951: R_X86_64_PLT32	rt_int_cmp-0x4
     955:	mov    r11d,0x2
     95b:	test   rax,rax
     95e:	cmovle r11,QWORD PTR [rip+0x20a]        # b70 <botlish_fn_5+0x510>
     966:	jmp    983 <botlish_fn_5+0x323>
     96b:	mov    r11d,0x2
     971:	mov    rsi,rbx
     974:	cmp    rsi,0xbf
     97b:	cmovle r11,QWORD PTR [rip+0x1ed]        # b70 <botlish_fn_5+0x510>
     983:	cmp    r11,0x6
     987:	je     b15 <botlish_fn_5+0x4b5>
     98d:	mov    rsi,rbx
     990:	test   rsi,0x1
     997:	jne    9c2 <botlish_fn_5+0x362>
     99d:	mov    edx,0xc1
     9a2:	mov    rsi,rbx
     9a5:	mov    rdi,r12
     9a8:	call   9ad <botlish_fn_5+0x34d>
			9a9: R_X86_64_PLT32	rt_int_cmp-0x4
     9ad:	mov    ecx,0x2
     9b2:	test   rax,rax
     9b5:	cmovle rcx,QWORD PTR [rip+0x1b3]        # b70 <botlish_fn_5+0x510>
     9bd:	jmp    9d9 <botlish_fn_5+0x379>
     9c2:	mov    ecx,0x2
     9c7:	mov    rsi,rbx
     9ca:	cmp    rsi,0xc1
     9d1:	cmovle rcx,QWORD PTR [rip+0x197]        # b70 <botlish_fn_5+0x510>
     9d9:	cmp    rcx,0x6
     9dd:	je     b0b <botlish_fn_5+0x4ab>
     9e3:	mov    rsi,rbx
     9e6:	test   rsi,0x1
     9ed:	jne    a18 <botlish_fn_5+0x3b8>
     9f3:	mov    edx,0xf5
     9f8:	mov    rsi,rbx
     9fb:	mov    rdi,r12
     9fe:	call   a03 <botlish_fn_5+0x3a3>
			9ff: R_X86_64_PLT32	rt_int_cmp-0x4
     a03:	mov    ecx,0x2
     a08:	test   rax,rax
     a0b:	cmovle rcx,QWORD PTR [rip+0x15d]        # b70 <botlish_fn_5+0x510>
     a13:	jmp    a2f <botlish_fn_5+0x3cf>
     a18:	mov    ecx,0x2
     a1d:	mov    rsi,rbx
     a20:	cmp    rsi,0xf5
     a27:	cmovle rcx,QWORD PTR [rip+0x141]        # b70 <botlish_fn_5+0x510>
     a2f:	cmp    rcx,0x6
     a33:	je     b03 <botlish_fn_5+0x4a3>
     a39:	mov    rsi,rbx
     a3c:	test   rsi,0x1
     a43:	jne    a6e <botlish_fn_5+0x40e>
     a49:	mov    edx,0xfb
     a4e:	mov    rsi,rbx
     a51:	mov    rdi,r12
     a54:	call   a59 <botlish_fn_5+0x3f9>
			a55: R_X86_64_PLT32	rt_int_cmp-0x4
     a59:	mov    ecx,0x2
     a5e:	test   rax,rax
     a61:	cmovle rcx,QWORD PTR [rip+0x107]        # b70 <botlish_fn_5+0x510>
     a69:	jmp    a85 <botlish_fn_5+0x425>
     a6e:	mov    ecx,0x2
     a73:	mov    rsi,rbx
     a76:	cmp    rsi,0xfb
     a7d:	cmovle rcx,QWORD PTR [rip+0xeb]        # b70 <botlish_fn_5+0x510>
     a85:	cmp    rcx,0x6
     a89:	je     af9 <botlish_fn_5+0x499>
     a8f:	mov    rsi,rbx
     a92:	test   rsi,0x1
     a99:	jne    ac5 <botlish_fn_5+0x465>
     a9f:	mov    edx,0xfd
     aa4:	mov    rsi,rbx
     aa7:	mov    rdi,r12
     aaa:	call   aaf <botlish_fn_5+0x44f>
			aab: R_X86_64_PLT32	rt_int_cmp-0x4
     aaf:	mov    r8d,0x2
     ab5:	test   rax,rax
     ab8:	cmovle r8,QWORD PTR [rip+0xb0]        # b70 <botlish_fn_5+0x510>
     ac0:	jmp    add <botlish_fn_5+0x47d>
     ac5:	mov    r8d,0x2
     acb:	mov    rsi,rbx
     ace:	cmp    rsi,0xfd
     ad5:	cmovle r8,QWORD PTR [rip+0x93]        # b70 <botlish_fn_5+0x510>
     add:	cmp    r8,0x6
     ae1:	je     af1 <botlish_fn_5+0x491>
     ae7:	mov    eax,0x2
     aec:	jmp    b58 <botlish_fn_5+0x4f8>
     af1:	mov    rax,r13
     af4:	jmp    b58 <botlish_fn_5+0x4f8>
     af9:	mov    eax,0x2
     afe:	jmp    b58 <botlish_fn_5+0x4f8>
     b03:	mov    rax,r13
     b06:	jmp    b58 <botlish_fn_5+0x4f8>
     b0b:	mov    eax,0x2
     b10:	jmp    b58 <botlish_fn_5+0x4f8>
     b15:	mov    rax,r13
     b18:	jmp    b58 <botlish_fn_5+0x4f8>
     b1d:	mov    eax,0x2
     b22:	jmp    b58 <botlish_fn_5+0x4f8>
     b27:	mov    rax,r13
     b2a:	jmp    b58 <botlish_fn_5+0x4f8>
     b2f:	mov    eax,0x2
     b34:	jmp    b58 <botlish_fn_5+0x4f8>
     b39:	mov    rax,r13
     b3c:	jmp    b58 <botlish_fn_5+0x4f8>
     b41:	mov    eax,0x2
     b46:	jmp    b58 <botlish_fn_5+0x4f8>
     b4b:	mov    rax,r13
     b4e:	jmp    b58 <botlish_fn_5+0x4f8>
     b53:	mov    eax,0x2
     b58:	mov    rbx,QWORD PTR [rsp]
     b5c:	mov    r12,QWORD PTR [rsp+0x8]
     b61:	mov    r13,QWORD PTR [rsp+0x10]
     b66:	add    rsp,0x20
     b6a:	mov    rsp,rbp
     b6d:	pop    rbp
     b6e:	ret
     b6f:	add    BYTE PTR [rsi],al
     b71:	add    BYTE PTR [rax],al
     b73:	add    BYTE PTR [rax],al
     b75:	add    BYTE PTR [rax],al
	...

0000000000000b78 <botlish_entry_5: is_unreserved<generic>>:
     b78:	push   rbp
     b79:	mov    rbp,rsp
     b7c:	mov    rsi,QWORD PTR [rdx]
     b7f:	call   b84 <botlish_entry_5+0xc>
			b80: R_X86_64_PLT32	botlish_fn_5-0x4 ; is_unreserved<generic>
     b84:	mov    rsp,rbp
     b87:	pop    rbp
     b88:	ret

0000000000000b89 <botlish_fn_6: hex_pair<generic>>:
     b89:	push   rbp
     b8a:	mov    rbp,rsp
     b8d:	sub    rsp,0x30
     b91:	mov    QWORD PTR [rsp+0x10],rbx
     b96:	mov    QWORD PTR [rsp+0x18],r12
     b9b:	mov    QWORD PTR [rsp+0x20],r13
     ba0:	mov    QWORD PTR [rsp+0x28],r14
     ba5:	mov    r12,rdi
     ba8:	mov    QWORD PTR [rsp],rsi
     bac:	mov    r13,rsi
     baf:	mov    QWORD PTR [rsp+0x8],rdx
     bb4:	mov    rbx,rdx
     bb7:	mov    rsi,r13
     bba:	mov    rdi,r12
     bbd:	call   bc2 <botlish_fn_6+0x39>
			bbe: R_X86_64_PLT32	botlish_fn_4-0x4 ; high_nibble<generic>
     bc2:	test   rax,rax
     bc5:	je     cf3 <botlish_fn_6+0x16a>
     bcb:	test   rax,0x1
     bd1:	jne    bdf <botlish_fn_6+0x56>
     bd7:	mov    rdx,rax
     bda:	jmp    bf5 <botlish_fn_6+0x6c>
     bdf:	mov    rdx,QWORD PTR [rbx+0x8]
     be3:	mov    rcx,rax
     be6:	sar    rcx,1
     be9:	cmp    rcx,rdx
     bec:	jb     c11 <botlish_fn_6+0x88>
     bf2:	mov    rdx,rax
     bf5:	mov    rsi,rbx
     bf8:	mov    rdi,r12
     bfb:	call   c00 <botlish_fn_6+0x77>
			bfc: R_X86_64_PLT32	rt_list_get-0x4
     c00:	test   rax,rax
     c03:	je     cf3 <botlish_fn_6+0x16a>
     c09:	mov    rsi,rax
     c0c:	jmp    c19 <botlish_fn_6+0x90>
     c11:	mov    rax,QWORD PTR [rbx+0x10]
     c15:	mov    rsi,QWORD PTR [rax+rcx*8]
     c19:	mov    QWORD PTR [rsp],rsi
     c1d:	mov    r14,rsi
     c20:	mov    ecx,0x1
     c25:	mov    rsi,r13
     c28:	test   rsi,0x1
     c2f:	jne    c4d <botlish_fn_6+0xc4>
     c35:	xor    ecx,ecx
     c37:	test   rsi,0x7
     c3e:	jne    c4d <botlish_fn_6+0xc4>
     c44:	movzx  rax,BYTE PTR [rsi]
     c48:	cmp    al,0x1
     c4a:	sete   cl
     c4d:	test   cl,cl
     c4f:	jne    c70 <botlish_fn_6+0xe7>
     c55:	mov    rdi,r12
     c58:	mov    rax,QWORD PTR [rdi+0x10]
     c5c:	mov    rcx,QWORD PTR [rax+0xb0]
     c63:	xor    rdx,rdx
     c66:	call   c6b <botlish_fn_6+0xe2>
			c67: R_X86_64_PLT32	rt_type_error-0x4
     c6b:	jmp    cf3 <botlish_fn_6+0x16a>
     c70:	mov    edx,0x21
     c75:	mov    rdi,r12
     c78:	call   c7d <botlish_fn_6+0xf4>
			c79: R_X86_64_PLT32	rt_int_mod-0x4
     c7d:	test   rax,rax
     c80:	je     cf3 <botlish_fn_6+0x16a>
     c86:	test   rax,0x1
     c8c:	jne    c9d <botlish_fn_6+0x114>
     c92:	mov    rdx,rax
     c95:	mov    rsi,rbx
     c98:	jmp    cb6 <botlish_fn_6+0x12d>
     c9d:	mov    rdi,QWORD PTR [rbx+0x8]
     ca1:	mov    rsi,rax
     ca4:	sar    rsi,1
     ca7:	mov    rdx,rax
     caa:	cmp    rsi,rdi
     cad:	jb     ccf <botlish_fn_6+0x146>
     cb3:	mov    rsi,rbx
     cb6:	mov    rdi,r12
     cb9:	call   cbe <botlish_fn_6+0x135>
			cba: R_X86_64_PLT32	rt_list_get-0x4
     cbe:	test   rax,rax
     cc1:	je     cf3 <botlish_fn_6+0x16a>
     cc7:	mov    rdx,rax
     cca:	jmp    cda <botlish_fn_6+0x151>
     ccf:	mov    rax,rbx
     cd2:	mov    rax,QWORD PTR [rax+0x10]
     cd6:	mov    rdx,QWORD PTR [rax+rsi*8]
     cda:	mov    QWORD PTR [rsp+0x8],rdx
     cdf:	mov    rsi,r14
     ce2:	mov    rdi,r12
     ce5:	call   cea <botlish_fn_6+0x161>
			ce6: R_X86_64_PLT32	rt_str_cat-0x4
     cea:	test   rax,rax
     ced:	jne    d13 <botlish_fn_6+0x18a>
     cf3:	xor    rax,rax
     cf6:	mov    rbx,QWORD PTR [rsp+0x10]
     cfb:	mov    r12,QWORD PTR [rsp+0x18]
     d00:	mov    r13,QWORD PTR [rsp+0x20]
     d05:	mov    r14,QWORD PTR [rsp+0x28]
     d0a:	add    rsp,0x30
     d0e:	mov    rsp,rbp
     d11:	pop    rbp
     d12:	ret
     d13:	mov    rbx,QWORD PTR [rsp+0x10]
     d18:	mov    r12,QWORD PTR [rsp+0x18]
     d1d:	mov    r13,QWORD PTR [rsp+0x20]
     d22:	mov    r14,QWORD PTR [rsp+0x28]
     d27:	add    rsp,0x30
     d2b:	mov    rsp,rbp
     d2e:	pop    rbp
     d2f:	ret

0000000000000d30 <botlish_entry_6: hex_pair<generic>>:
     d30:	push   rbp
     d31:	mov    rbp,rsp
     d34:	mov    rsi,QWORD PTR [rdx]
     d37:	mov    rdx,QWORD PTR [rdx+0x8]
     d3b:	call   d40 <botlish_entry_6+0x10>
			d3c: R_X86_64_PLT32	botlish_fn_6-0x4 ; hex_pair<generic>
     d40:	mov    rsp,rbp
     d43:	pop    rbp
     d44:	ret
     d45:	add    BYTE PTR [rax],al
	...

0000000000000d48 <botlish_fn_7: esc_bytes<generic>>:
     d48:	push   rbp
     d49:	mov    rbp,rsp
     d4c:	sub    rsp,0x70
     d50:	mov    QWORD PTR [rsp+0x40],rbx
     d55:	mov    QWORD PTR [rsp+0x48],r12
     d5a:	mov    QWORD PTR [rsp+0x50],r13
     d5f:	mov    QWORD PTR [rsp+0x58],r14
     d64:	mov    QWORD PTR [rsp+0x60],r15
     d69:	mov    r13,rdi
     d6c:	mov    QWORD PTR [rsp+0x28],0x0
     d75:	mov    QWORD PTR [rsp],rsi
     d79:	mov    QWORD PTR [rsp+0x8],rdx
     d7e:	mov    QWORD PTR [rsp+0x10],rcx
     d83:	mov    QWORD PTR [rsp+0x18],r8
     d88:	mov    r12,r8
     d8b:	mov    r14,rcx
     d8e:	mov    r15,rdx
     d91:	xor    eax,eax
     d93:	test   rsi,0x7
     d9a:	jne    dab <botlish_fn_7+0x63>
     da0:	movzx  r8,BYTE PTR [rsi]
     da4:	cmp    r8b,0x3
     da8:	sete   al
     dab:	test   al,al
     dad:	jne    dd0 <botlish_fn_7+0x88>
     db3:	mov    rdi,r13
     db6:	mov    rax,QWORD PTR [rdi+0x10]
     dba:	mov    rcx,QWORD PTR [rax+0xb8]
     dc1:	mov    edx,0x4
     dc6:	call   dcb <botlish_fn_7+0x83>
			dc7: R_X86_64_PLT32	rt_type_error-0x4
     dcb:	jmp    fd6 <botlish_fn_7+0x28e>
     dd0:	mov    rbx,rsi
     dd3:	mov    rdi,r13
     dd6:	call   ddb <botlish_fn_7+0x93>
			dd7: R_X86_64_PLT32	rt_list_len-0x4
     ddb:	mov    ecx,0x1
     de0:	mov    rsi,r15
     de3:	test   rsi,0x1
     dea:	jne    e10 <botlish_fn_7+0xc8>
     df0:	xor    ecx,ecx
     df2:	mov    rsi,r15
     df5:	test   rsi,0x7
     dfc:	jne    e10 <botlish_fn_7+0xc8>
     e02:	mov    rsi,r15
     e05:	movzx  rcx,BYTE PTR [rsi]
     e09:	rex cmp cl,0x1
     e0d:	sete   cl
     e10:	test   cl,cl
     e12:	jne    e36 <botlish_fn_7+0xee>
     e18:	mov    rdi,r13
     e1b:	mov    rax,QWORD PTR [rdi+0x10]
     e1f:	mov    rcx,QWORD PTR [rax+0xc0]
     e26:	xor    rdx,rdx
     e29:	mov    rsi,r15
     e2c:	call   e31 <botlish_fn_7+0xe9>
			e2d: R_X86_64_PLT32	rt_type_error-0x4
     e31:	jmp    fd6 <botlish_fn_7+0x28e>
     e36:	mov    rsi,r15
     e39:	mov    rcx,rsi
     e3c:	and    rcx,rax
     e3f:	mov    rdx,rax
     e42:	test   rcx,0x1
     e49:	jne    e6f <botlish_fn_7+0x127>
     e4f:	mov    rsi,r15
     e52:	mov    rdi,r13
     e55:	call   e5a <botlish_fn_7+0x112>
			e56: R_X86_64_PLT32	rt_int_cmp-0x4
     e5a:	mov    ecx,0x2
     e5f:	test   rax,rax
     e62:	cmovge rcx,QWORD PTR [rip+0x1de]        # 1048 <botlish_fn_7+0x300>
     e6a:	jmp    e82 <botlish_fn_7+0x13a>
     e6f:	mov    ecx,0x2
     e74:	mov    rsi,r15
     e77:	cmp    rsi,rdx
     e7a:	cmovge rcx,QWORD PTR [rip+0x1c6]        # 1048 <botlish_fn_7+0x300>
     e82:	cmp    rcx,0x6
     e86:	je     1021 <botlish_fn_7+0x2d9>
     e8c:	mov    QWORD PTR [rsp+0x20],0x3
     e95:	mov    rsi,r15
     e98:	test   rsi,0x1
     e9f:	je     eba <botlish_fn_7+0x172>
     ea5:	mov    rsi,r15
     ea8:	mov    rax,rsi
     eab:	add    rax,0x2
     eaf:	seto   cl
     eb2:	test   cl,cl
     eb4:	je     eca <botlish_fn_7+0x182>
     eba:	mov    edx,0x3
     ebf:	mov    rsi,r15
     ec2:	mov    rdi,r13
     ec5:	call   eca <botlish_fn_7+0x182>
			ec6: R_X86_64_PLT32	rt_int_add-0x4
     eca:	mov    QWORD PTR [rsp+0x8],rax
     ecf:	mov    rdi,r13
     ed2:	mov    QWORD PTR [rsp+0x30],rax
     ed7:	mov    rax,QWORD PTR [rdi+0x10]
     edb:	mov    rsi,QWORD PTR [rax+0xc8]
     ee2:	mov    QWORD PTR [rsp+0x20],rsi
     ee7:	mov    QWORD PTR [rsp+0x38],rsi
     eec:	mov    rsi,r15
     eef:	test   rsi,0x1
     ef6:	jne    f04 <botlish_fn_7+0x1bc>
     efc:	mov    rdx,r15
     eff:	jmp    f1d <botlish_fn_7+0x1d5>
     f04:	mov    rcx,QWORD PTR [rbx+0x8]
     f08:	mov    rsi,r15
     f0b:	mov    rax,rsi
     f0e:	sar    rax,1
     f11:	cmp    rax,rcx
     f14:	jb     f39 <botlish_fn_7+0x1f1>
     f1a:	mov    rdx,r15
     f1d:	mov    rsi,rbx
     f20:	mov    rdi,r13
     f23:	call   f28 <botlish_fn_7+0x1e0>
			f24: R_X86_64_PLT32	rt_list_get-0x4
     f28:	test   rax,rax
     f2b:	je     fd6 <botlish_fn_7+0x28e>
     f31:	mov    rsi,rax
     f34:	jmp    f41 <botlish_fn_7+0x1f9>
     f39:	mov    rcx,QWORD PTR [rbx+0x10]
     f3d:	mov    rsi,QWORD PTR [rcx+rax*8]
     f41:	mov    QWORD PTR [rsp+0x28],rsi
     f46:	mov    rdx,r12
     f49:	mov    rdi,r13
     f4c:	call   f51 <botlish_fn_7+0x209>
			f4d: R_X86_64_PLT32	botlish_fn_6-0x4 ; hex_pair<generic>
     f51:	test   rax,rax
     f54:	je     fd6 <botlish_fn_7+0x28e>
     f5a:	mov    QWORD PTR [rsp+0x28],rax
     f5f:	mov    rdx,rax
     f62:	mov    rsi,QWORD PTR [rsp+0x38]
     f67:	mov    rdi,r13
     f6a:	call   f6f <botlish_fn_7+0x227>
			f6b: R_X86_64_PLT32	rt_str_cat-0x4
     f6f:	test   rax,rax
     f72:	je     fd6 <botlish_fn_7+0x28e>
     f78:	mov    QWORD PTR [rsp+0x20],rax
     f7d:	mov    rdx,rax
     f80:	xor    eax,eax
     f82:	mov    rsi,r14
     f85:	test   rsi,0x7
     f8c:	jne    f9d <botlish_fn_7+0x255>
     f92:	movzx  rdi,BYTE PTR [rsi]
     f96:	cmp    dil,0x2
     f9a:	sete   al
     f9d:	test   al,al
     f9f:	jne    fc5 <botlish_fn_7+0x27d>
     fa5:	mov    rdi,r13
     fa8:	mov    rdi,QWORD PTR [rdi+0x10]
     fac:	mov    rcx,QWORD PTR [rdi+0xd0]
     fb3:	mov    edx,0x1
     fb8:	mov    rdi,r13
     fbb:	call   fc0 <botlish_fn_7+0x278>
			fbc: R_X86_64_PLT32	rt_type_error-0x4
     fc0:	jmp    fd6 <botlish_fn_7+0x28e>
     fc5:	mov    rdi,r13
     fc8:	call   fcd <botlish_fn_7+0x285>
			fc9: R_X86_64_PLT32	rt_str_cat-0x4
     fcd:	test   rax,rax
     fd0:	jne    ffb <botlish_fn_7+0x2b3>
     fd6:	xor    rax,rax
     fd9:	mov    rbx,QWORD PTR [rsp+0x40]
     fde:	mov    r12,QWORD PTR [rsp+0x48]
     fe3:	mov    r13,QWORD PTR [rsp+0x50]
     fe8:	mov    r14,QWORD PTR [rsp+0x58]
     fed:	mov    r15,QWORD PTR [rsp+0x60]
     ff2:	add    rsp,0x70
     ff6:	mov    rsp,rbp
     ff9:	pop    rbp
     ffa:	ret
     ffb:	mov    QWORD PTR [rsp],rbx
     fff:	mov    rcx,QWORD PTR [rsp+0x30]
    1004:	mov    QWORD PTR [rsp+0x8],rcx
    1009:	mov    QWORD PTR [rsp+0x10],rax
    100e:	mov    QWORD PTR [rsp+0x18],r12
    1013:	mov    rsi,rbx
    1016:	mov    r14,rax
    1019:	mov    r15,rcx
    101c:	jmp    d91 <botlish_fn_7+0x49>
    1021:	mov    rax,r14
    1024:	mov    rbx,QWORD PTR [rsp+0x40]
    1029:	mov    r12,QWORD PTR [rsp+0x48]
    102e:	mov    r13,QWORD PTR [rsp+0x50]
    1033:	mov    r14,QWORD PTR [rsp+0x58]
    1038:	mov    r15,QWORD PTR [rsp+0x60]
    103d:	add    rsp,0x70
    1041:	mov    rsp,rbp
    1044:	pop    rbp
    1045:	ret
    1046:	add    BYTE PTR [rax],al
    1048:	(bad)
    1049:	add    BYTE PTR [rax],al
    104b:	add    BYTE PTR [rax],al
    104d:	add    BYTE PTR [rax],al
	...

0000000000001050 <botlish_entry_7: esc_bytes<generic>>:
    1050:	push   rbp
    1051:	mov    rbp,rsp
    1054:	mov    rsi,QWORD PTR [rdx]
    1057:	mov    r9,QWORD PTR [rdx+0x8]
    105b:	mov    rcx,QWORD PTR [rdx+0x10]
    105f:	mov    r8,QWORD PTR [rdx+0x18]
    1063:	mov    rdx,r9
    1066:	call   106b <botlish_entry_7+0x1b>
			1067: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_bytes<generic>
    106b:	mov    rsp,rbp
    106e:	pop    rbp
    106f:	ret

0000000000001070 <botlish_fn_8: esc_char<generic>>:
    1070:	push   rbp
    1071:	mov    rbp,rsp
    1074:	sub    rsp,0x50
    1078:	mov    QWORD PTR [rsp+0x20],rbx
    107d:	mov    QWORD PTR [rsp+0x28],r12
    1082:	mov    QWORD PTR [rsp+0x30],r13
    1087:	mov    QWORD PTR [rsp+0x38],r14
    108c:	mov    QWORD PTR [rsp+0x40],r15
    1091:	mov    QWORD PTR [rsp+0x10],0x0
    109a:	mov    QWORD PTR [rsp+0x18],0x0
    10a3:	mov    QWORD PTR [rsp],rsi
    10a7:	mov    QWORD PTR [rsp+0x8],rdx
    10ac:	mov    rbx,rdx
    10af:	xor    r9d,r9d
    10b2:	test   rsi,0x7
    10b9:	jne    10c9 <botlish_fn_8+0x59>
    10bf:	movzx  rax,BYTE PTR [rsi]
    10c3:	cmp    al,0x2
    10c5:	sete   r9b
    10c9:	test   r9b,r9b
    10cc:	jne    10ec <botlish_fn_8+0x7c>
    10d2:	mov    rax,QWORD PTR [rdi+0x10]
    10d6:	mov    rcx,QWORD PTR [rax+0xd8]
    10dd:	mov    edx,0x1
    10e2:	call   10e7 <botlish_fn_8+0x77>
			10e3: R_X86_64_PLT32	rt_type_error-0x4
    10e7:	jmp    11ec <botlish_fn_8+0x17c>
    10ec:	mov    r12,rdi
    10ef:	mov    r15,rsi
    10f2:	call   10f7 <botlish_fn_8+0x87>
			10f3: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    10f7:	mov    rcx,rax
    10fa:	mov    r13,rax
    10fd:	test   rax,rcx
    1100:	je     11ec <botlish_fn_8+0x17c>
    1106:	mov    rax,r13
    1109:	mov    QWORD PTR [rsp],rax
    110d:	mov    rsi,r13
    1110:	mov    rdi,r12
    1113:	call   1118 <botlish_fn_8+0xa8>
			1114: R_X86_64_PLT32	rt_list_len-0x4
    1118:	mov    edx,0x1
    111d:	sar    rax,1
    1120:	cmp    rax,0x1
    1124:	je     115f <botlish_fn_8+0xef>
    112a:	mov    QWORD PTR [rsp+0x10],0x1
    1133:	mov    rdi,r12
    1136:	mov    rax,QWORD PTR [rdi+0x10]
    113a:	mov    rcx,QWORD PTR [rax+0xa0]
    1141:	mov    QWORD PTR [rsp+0x18],rcx
    1146:	mov    rsi,r13
    1149:	mov    r8,rbx
    114c:	call   1151 <botlish_fn_8+0xe1>
			114d: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_bytes<generic>
    1151:	test   rax,rax
    1154:	je     11ec <botlish_fn_8+0x17c>
    115a:	jmp    1217 <botlish_fn_8+0x1a7>
    115f:	mov    rsi,r13
    1162:	mov    r14,rdx
    1165:	mov    rax,QWORD PTR [rsi+0x8]
    1169:	mov    r13,rsi
    116c:	test   rax,rax
    116f:	jne    1194 <botlish_fn_8+0x124>
    1175:	mov    rdx,r14
    1178:	mov    rsi,r13
    117b:	mov    rdi,r12
    117e:	call   1183 <botlish_fn_8+0x113>
			117f: R_X86_64_PLT32	rt_list_get-0x4
    1183:	test   rax,rax
    1186:	je     11ec <botlish_fn_8+0x17c>
    118c:	mov    rsi,rax
    118f:	jmp    119e <botlish_fn_8+0x12e>
    1194:	mov    rsi,r13
    1197:	mov    rcx,QWORD PTR [rsi+0x10]
    119b:	mov    rsi,QWORD PTR [rcx]
    119e:	mov    rdi,r12
    11a1:	call   11a6 <botlish_fn_8+0x136>
			11a2: R_X86_64_PLT32	botlish_fn_5-0x4 ; is_unreserved<generic>
    11a6:	test   rax,rax
    11a9:	je     11ec <botlish_fn_8+0x17c>
    11af:	cmp    rax,0x6
    11b3:	je     1214 <botlish_fn_8+0x1a4>
    11b9:	mov    QWORD PTR [rsp+0x10],0x1
    11c2:	mov    rdi,r12
    11c5:	mov    r8,QWORD PTR [rdi+0x10]
    11c9:	mov    rcx,QWORD PTR [r8+0xa0]
    11d0:	mov    QWORD PTR [rsp+0x18],rcx
    11d5:	mov    rdx,r14
    11d8:	mov    rsi,r13
    11db:	mov    r8,rbx
    11de:	call   11e3 <botlish_fn_8+0x173>
			11df: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_bytes<generic>
    11e3:	test   rax,rax
    11e6:	jne    1211 <botlish_fn_8+0x1a1>
    11ec:	xor    rax,rax
    11ef:	mov    rbx,QWORD PTR [rsp+0x20]
    11f4:	mov    r12,QWORD PTR [rsp+0x28]
    11f9:	mov    r13,QWORD PTR [rsp+0x30]
    11fe:	mov    r14,QWORD PTR [rsp+0x38]
    1203:	mov    r15,QWORD PTR [rsp+0x40]
    1208:	add    rsp,0x50
    120c:	mov    rsp,rbp
    120f:	pop    rbp
    1210:	ret
    1211:	mov    r15,rax
    1214:	mov    rax,r15
    1217:	mov    rbx,QWORD PTR [rsp+0x20]
    121c:	mov    r12,QWORD PTR [rsp+0x28]
    1221:	mov    r13,QWORD PTR [rsp+0x30]
    1226:	mov    r14,QWORD PTR [rsp+0x38]
    122b:	mov    r15,QWORD PTR [rsp+0x40]
    1230:	add    rsp,0x50
    1234:	mov    rsp,rbp
    1237:	pop    rbp
    1238:	ret

0000000000001239 <botlish_entry_8: esc_char<generic>>:
    1239:	push   rbp
    123a:	mov    rbp,rsp
    123d:	mov    rsi,QWORD PTR [rdx]
    1240:	mov    rdx,QWORD PTR [rdx+0x8]
    1244:	call   1249 <botlish_entry_8+0x10>
			1245: R_X86_64_PLT32	botlish_fn_8-0x4 ; esc_char<generic>
    1249:	mov    rsp,rbp
    124c:	pop    rbp
    124d:	ret
	...

0000000000001250 <botlish_fn_9: esc_from<generic>>:
    1250:	push   rbp
    1251:	mov    rbp,rsp
    1254:	sub    rsp,0x70
    1258:	mov    QWORD PTR [rsp+0x40],rbx
    125d:	mov    QWORD PTR [rsp+0x48],r12
    1262:	mov    QWORD PTR [rsp+0x50],r13
    1267:	mov    QWORD PTR [rsp+0x58],r14
    126c:	mov    QWORD PTR [rsp+0x60],r15
    1271:	mov    r13,rdi
    1274:	mov    QWORD PTR [rsp+0x28],0x0
    127d:	mov    QWORD PTR [rsp],rsi
    1281:	mov    QWORD PTR [rsp+0x8],rdx
    1286:	mov    QWORD PTR [rsp+0x10],rcx
    128b:	mov    QWORD PTR [rsp+0x18],r8
    1290:	mov    r12,r8
    1293:	mov    r14,rcx
    1296:	mov    QWORD PTR [rsp+0x30],rdx
    129b:	xor    eax,eax
    129d:	test   rsi,0x7
    12a4:	jne    12b3 <botlish_fn_9+0x63>
    12aa:	movzx  rax,BYTE PTR [rsi]
    12ae:	cmp    al,0x2
    12b0:	sete   al
    12b3:	test   al,al
    12b5:	jne    12d8 <botlish_fn_9+0x88>
    12bb:	mov    rdi,r13
    12be:	mov    rax,QWORD PTR [rdi+0x10]
    12c2:	mov    rcx,QWORD PTR [rax+0xe0]
    12c9:	mov    edx,0x1
    12ce:	call   12d3 <botlish_fn_9+0x83>
			12cf: R_X86_64_PLT32	rt_type_error-0x4
    12d3:	jmp    151c <botlish_fn_9+0x2cc>
    12d8:	mov    rbx,rsi
    12db:	mov    rdi,r13
    12de:	call   12e3 <botlish_fn_9+0x93>
			12df: R_X86_64_PLT32	rt_str_len-0x4
    12e3:	mov    edx,0x1
    12e8:	mov    r15,rdx
    12eb:	mov    ecx,0x1
    12f0:	mov    rsi,QWORD PTR [rsp+0x30]
    12f5:	test   rsi,0x1
    12fc:	jne    1326 <botlish_fn_9+0xd6>
    1302:	xor    ecx,ecx
    1304:	mov    rsi,QWORD PTR [rsp+0x30]
    1309:	test   rsi,0x7
    1310:	jne    1326 <botlish_fn_9+0xd6>
    1316:	mov    rsi,QWORD PTR [rsp+0x30]
    131b:	movzx  rcx,BYTE PTR [rsi]
    131f:	rex cmp cl,0x1
    1323:	sete   cl
    1326:	test   cl,cl
    1328:	jne    134e <botlish_fn_9+0xfe>
    132e:	mov    rdi,r13
    1331:	mov    rax,QWORD PTR [rdi+0x10]
    1335:	mov    rcx,QWORD PTR [rax+0xc0]
    133c:	xor    rdx,rdx
    133f:	mov    rsi,QWORD PTR [rsp+0x30]
    1344:	call   1349 <botlish_fn_9+0xf9>
			1345: R_X86_64_PLT32	rt_type_error-0x4
    1349:	jmp    151c <botlish_fn_9+0x2cc>
    134e:	mov    rsi,QWORD PTR [rsp+0x30]
    1353:	mov    rcx,rsi
    1356:	and    rcx,rax
    1359:	mov    rdx,rax
    135c:	test   rcx,0x1
    1363:	jne    138b <botlish_fn_9+0x13b>
    1369:	mov    rsi,QWORD PTR [rsp+0x30]
    136e:	mov    rdi,r13
    1371:	call   1376 <botlish_fn_9+0x126>
			1372: R_X86_64_PLT32	rt_int_cmp-0x4
    1376:	mov    ecx,0x2
    137b:	test   rax,rax
    137e:	cmovge rcx,QWORD PTR [rip+0x20a]        # 1590 <botlish_fn_9+0x340>
    1386:	jmp    13a0 <botlish_fn_9+0x150>
    138b:	mov    ecx,0x2
    1390:	mov    rsi,QWORD PTR [rsp+0x30]
    1395:	cmp    rsi,rdx
    1398:	cmovge rcx,QWORD PTR [rip+0x1f0]        # 1590 <botlish_fn_9+0x340>
    13a0:	cmp    rcx,0x6
    13a4:	je     1569 <botlish_fn_9+0x319>
    13aa:	mov    QWORD PTR [rsp+0x20],0x3
    13b3:	mov    rsi,QWORD PTR [rsp+0x30]
    13b8:	test   rsi,0x1
    13bf:	je     13dc <botlish_fn_9+0x18c>
    13c5:	mov    rsi,QWORD PTR [rsp+0x30]
    13ca:	mov    rax,rsi
    13cd:	add    rax,0x2
    13d1:	seto   cl
    13d4:	test   cl,cl
    13d6:	je     13ee <botlish_fn_9+0x19e>
    13dc:	mov    edx,0x3
    13e1:	mov    rsi,QWORD PTR [rsp+0x30]
    13e6:	mov    rdi,r13
    13e9:	call   13ee <botlish_fn_9+0x19e>
			13ea: R_X86_64_PLT32	rt_int_add-0x4
    13ee:	mov    QWORD PTR [rsp+0x20],rax
    13f3:	mov    QWORD PTR [rsp+0x38],rax
    13f8:	mov    QWORD PTR [rsp+0x28],0x3
    1401:	mov    rsi,QWORD PTR [rsp+0x30]
    1406:	test   rsi,0x1
    140d:	je     142a <botlish_fn_9+0x1da>
    1413:	mov    rsi,QWORD PTR [rsp+0x30]
    1418:	mov    rcx,rsi
    141b:	add    rcx,0x2
    141f:	seto   al
    1422:	test   al,al
    1424:	je     143f <botlish_fn_9+0x1ef>
    142a:	mov    edx,0x3
    142f:	mov    rsi,QWORD PTR [rsp+0x30]
    1434:	mov    rdi,r13
    1437:	call   143c <botlish_fn_9+0x1ec>
			1438: R_X86_64_PLT32	rt_int_add-0x4
    143c:	mov    rcx,rax
    143f:	mov    QWORD PTR [rsp+0x28],rcx
    1444:	mov    rdx,QWORD PTR [rsp+0x30]
    1449:	mov    rsi,rbx
    144c:	mov    rdi,r13
    144f:	call   1454 <botlish_fn_9+0x204>
			1450: R_X86_64_PLT32	rt_substr-0x4
    1454:	test   rax,rax
    1457:	je     151c <botlish_fn_9+0x2cc>
    145d:	mov    QWORD PTR [rsp+0x8],rax
    1462:	mov    rsi,rax
    1465:	mov    rdx,r12
    1468:	mov    rdi,r13
    146b:	call   1470 <botlish_fn_9+0x220>
			146c: R_X86_64_PLT32	botlish_fn_8-0x4 ; esc_char<generic>
    1470:	test   rax,rax
    1473:	je     151c <botlish_fn_9+0x2cc>
    1479:	mov    QWORD PTR [rsp+0x8],rax
    147e:	xor    ecx,ecx
    1480:	mov    rsi,r14
    1483:	test   rsi,0x7
    148a:	jne    149b <botlish_fn_9+0x24b>
    1490:	movzx  rdi,BYTE PTR [rsi]
    1494:	cmp    dil,0x2
    1498:	sete   cl
    149b:	test   cl,cl
    149d:	jne    14be <botlish_fn_9+0x26e>
    14a3:	mov    rdi,r13
    14a6:	mov    r9,QWORD PTR [rdi+0x10]
    14aa:	mov    rcx,QWORD PTR [r9+0xd0]
    14b1:	mov    rdx,r15
    14b4:	call   14b9 <botlish_fn_9+0x269>
			14b5: R_X86_64_PLT32	rt_type_error-0x4
    14b9:	jmp    151c <botlish_fn_9+0x2cc>
    14be:	mov    rdx,r15
    14c1:	xor    ecx,ecx
    14c3:	test   rax,0x7
    14c9:	je     14d7 <botlish_fn_9+0x287>
    14cf:	mov    r8,rax
    14d2:	jmp    14e5 <botlish_fn_9+0x295>
    14d7:	movzx  rcx,BYTE PTR [rax]
    14db:	mov    r8,rax
    14de:	rex cmp cl,0x2
    14e2:	sete   cl
    14e5:	test   cl,cl
    14e7:	jne    1508 <botlish_fn_9+0x2b8>
    14ed:	mov    rdi,r13
    14f0:	mov    rax,QWORD PTR [rdi+0x10]
    14f4:	mov    rcx,QWORD PTR [rax+0xd0]
    14fb:	mov    rsi,r8
    14fe:	call   1503 <botlish_fn_9+0x2b3>
			14ff: R_X86_64_PLT32	rt_type_error-0x4
    1503:	jmp    151c <botlish_fn_9+0x2cc>
    1508:	mov    rdx,r8
    150b:	mov    rdi,r13
    150e:	call   1513 <botlish_fn_9+0x2c3>
			150f: R_X86_64_PLT32	rt_str_cat-0x4
    1513:	test   rax,rax
    1516:	jne    1541 <botlish_fn_9+0x2f1>
    151c:	xor    rax,rax
    151f:	mov    rbx,QWORD PTR [rsp+0x40]
    1524:	mov    r12,QWORD PTR [rsp+0x48]
    1529:	mov    r13,QWORD PTR [rsp+0x50]
    152e:	mov    r14,QWORD PTR [rsp+0x58]
    1533:	mov    r15,QWORD PTR [rsp+0x60]
    1538:	add    rsp,0x70
    153c:	mov    rsp,rbp
    153f:	pop    rbp
    1540:	ret
    1541:	mov    QWORD PTR [rsp],rbx
    1545:	mov    rcx,QWORD PTR [rsp+0x38]
    154a:	mov    QWORD PTR [rsp+0x8],rcx
    154f:	mov    QWORD PTR [rsp+0x10],rax
    1554:	mov    QWORD PTR [rsp+0x18],r12
    1559:	mov    rsi,rbx
    155c:	mov    r14,rax
    155f:	mov    QWORD PTR [rsp+0x30],rcx
    1564:	jmp    129b <botlish_fn_9+0x4b>
    1569:	mov    rax,r14
    156c:	mov    rbx,QWORD PTR [rsp+0x40]
    1571:	mov    r12,QWORD PTR [rsp+0x48]
    1576:	mov    r13,QWORD PTR [rsp+0x50]
    157b:	mov    r14,QWORD PTR [rsp+0x58]
    1580:	mov    r15,QWORD PTR [rsp+0x60]
    1585:	add    rsp,0x70
    1589:	mov    rsp,rbp
    158c:	pop    rbp
    158d:	ret
    158e:	add    BYTE PTR [rax],al
    1590:	(bad)
    1591:	add    BYTE PTR [rax],al
    1593:	add    BYTE PTR [rax],al
    1595:	add    BYTE PTR [rax],al
	...

0000000000001598 <botlish_entry_9: esc_from<generic>>:
    1598:	push   rbp
    1599:	mov    rbp,rsp
    159c:	mov    rsi,QWORD PTR [rdx]
    159f:	mov    r9,QWORD PTR [rdx+0x8]
    15a3:	mov    rcx,QWORD PTR [rdx+0x10]
    15a7:	mov    r8,QWORD PTR [rdx+0x18]
    15ab:	mov    rdx,r9
    15ae:	call   15b3 <botlish_entry_9+0x1b>
			15af: R_X86_64_PLT32	botlish_fn_9-0x4 ; esc_from<generic>
    15b3:	mov    rsp,rbp
    15b6:	pop    rbp
    15b7:	ret

00000000000015b8 <botlish_fn_10: check<int, int, str, str>>:
    15b8:	push   rbp
    15b9:	mov    rbp,rsp
    15bc:	sub    rsp,0x60
    15c0:	mov    QWORD PTR [rsp+0x30],rbx
    15c5:	mov    QWORD PTR [rsp+0x38],r12
    15ca:	mov    QWORD PTR [rsp+0x40],r13
    15cf:	mov    QWORD PTR [rsp+0x48],r14
    15d4:	mov    QWORD PTR [rsp+0x50],r15
    15d9:	mov    QWORD PTR [rsp+0x20],0x0
    15e2:	mov    QWORD PTR [rsp],rsi
    15e6:	mov    QWORD PTR [rsp+0x8],rdx
    15eb:	mov    QWORD PTR [rsp+0x10],rcx
    15f0:	mov    r12,rcx
    15f3:	mov    QWORD PTR [rsp+0x18],r8
    15f8:	mov    r14,r8
    15fb:	mov    r13,rsi
    15fe:	mov    r15,rdx
    1601:	test   r13,0x1
    1608:	jne    1633 <botlish_fn_10+0x7b>
    160e:	mov    edx,0x1
    1613:	mov    rbx,rdi
    1616:	mov    rsi,r13
    1619:	call   161e <botlish_fn_10+0x66>
			161a: R_X86_64_PLT32	rt_int_cmp-0x4
    161e:	mov    ecx,0x2
    1623:	test   rax,rax
    1626:	cmovle rcx,QWORD PTR [rip+0x152]        # 1780 <botlish_fn_10+0x1c8>
    162e:	jmp    1647 <botlish_fn_10+0x8f>
    1633:	mov    rbx,rdi
    1636:	mov    ecx,0x2
    163b:	cmp    r13,0x1
    163f:	cmovle rcx,QWORD PTR [rip+0x139]        # 1780 <botlish_fn_10+0x1c8>
    1647:	cmp    rcx,0x6
    164b:	je     1754 <botlish_fn_10+0x19c>
    1651:	mov    rax,QWORD PTR [rbx+0x10]
    1655:	mov    rax,QWORD PTR [rax+0xe8]
    165c:	mov    rsi,r12
    165f:	mov    rdi,rbx
    1662:	call   1667 <botlish_fn_10+0xaf>
			1663: R_X86_64_PLT32	botlish_fn_11-0x4 ; <str>
    1667:	test   rax,rax
    166a:	je     16ab <botlish_fn_10+0xf3>
    1670:	cmp    rax,0x6
    1674:	je     168c <botlish_fn_10+0xd4>
    167a:	mov    edx,0x1
    167f:	mov    QWORD PTR [rsp],0x1
    1687:	jmp    16ed <botlish_fn_10+0x135>
    168c:	mov    rax,QWORD PTR [rbx+0x10]
    1690:	mov    rax,QWORD PTR [rax+0xf0]
    1697:	mov    rsi,r12
    169a:	mov    rdi,rbx
    169d:	call   16a2 <botlish_fn_10+0xea>
			169e: R_X86_64_PLT32	botlish_fn_19-0x4 ; <str>
    16a2:	test   rax,rax
    16a5:	jne    16d0 <botlish_fn_10+0x118>
    16ab:	xor    rax,rax
    16ae:	mov    rbx,QWORD PTR [rsp+0x30]
    16b3:	mov    r12,QWORD PTR [rsp+0x38]
    16b8:	mov    r13,QWORD PTR [rsp+0x40]
    16bd:	mov    r14,QWORD PTR [rsp+0x48]
    16c2:	mov    r15,QWORD PTR [rsp+0x50]
    16c7:	add    rsp,0x60
    16cb:	mov    rsp,rbp
    16ce:	pop    rbp
    16cf:	ret
    16d0:	cmp    rax,0x6
    16d4:	je     16e4 <botlish_fn_10+0x12c>
    16da:	mov    edx,0x1
    16df:	jmp    16e9 <botlish_fn_10+0x131>
    16e4:	mov    edx,0x3
    16e9:	mov    QWORD PTR [rsp],rdx
    16ed:	sar    r13,1
    16f0:	sub    r13,0x1
    16f4:	shl    r13,1
    16f7:	or     r13,0x1
    16fb:	mov    QWORD PTR [rsp+0x20],r13
    1700:	mov    rsi,r15
    1703:	mov    r8,rsi
    1706:	and    r8,rdx
    1709:	test   r8,0x1
    1710:	je     172b <botlish_fn_10+0x173>
    1716:	lea    r11,[rdx-0x1]
    171a:	mov    rax,rsi
    171d:	add    rax,r11
    1720:	seto   cl
    1723:	test   cl,cl
    1725:	je     1733 <botlish_fn_10+0x17b>
    172b:	mov    rdi,rbx
    172e:	call   1733 <botlish_fn_10+0x17b>
			172f: R_X86_64_PLT32	rt_int_add-0x4
    1733:	mov    QWORD PTR [rsp],r13
    1737:	mov    QWORD PTR [rsp+0x8],rax
    173c:	mov    QWORD PTR [rsp+0x10],r12
    1741:	mov    r8,r14
    1744:	mov    QWORD PTR [rsp+0x18],r8
    1749:	mov    rdi,rbx
    174c:	mov    r15,rax
    174f:	jmp    1601 <botlish_fn_10+0x49>
    1754:	mov    rax,r15
    1757:	mov    rbx,QWORD PTR [rsp+0x30]
    175c:	mov    r12,QWORD PTR [rsp+0x38]
    1761:	mov    r13,QWORD PTR [rsp+0x40]
    1766:	mov    r14,QWORD PTR [rsp+0x48]
    176b:	mov    r15,QWORD PTR [rsp+0x50]
    1770:	add    rsp,0x60
    1774:	mov    rsp,rbp
    1777:	pop    rbp
    1778:	ret
    1779:	add    BYTE PTR [rax],al
    177b:	add    BYTE PTR [rax],al
    177d:	add    BYTE PTR [rax],al
    177f:	add    BYTE PTR [rsi],al
    1781:	add    BYTE PTR [rax],al
    1783:	add    BYTE PTR [rax],al
    1785:	add    BYTE PTR [rax],al
	...

0000000000001788 <botlish_entry_10: check<int, int, str, str>>:
    1788:	push   rbp
    1789:	mov    rbp,rsp
    178c:	mov    rsi,QWORD PTR [rdx]
    178f:	mov    r9,QWORD PTR [rdx+0x8]
    1793:	mov    rcx,QWORD PTR [rdx+0x10]
    1797:	mov    r8,QWORD PTR [rdx+0x18]
    179b:	mov    rdx,r9
    179e:	call   17a3 <botlish_entry_10+0x1b>
			179f: R_X86_64_PLT32	botlish_fn_10-0x4 ; check<int, int, str, str>
    17a3:	mov    rsp,rbp
    17a6:	pop    rbp
    17a7:	ret

00000000000017a8 <botlish_fn_11: <str>>:
    17a8:	push   rbp
    17a9:	mov    rbp,rsp
    17ac:	sub    rsp,0x50
    17b0:	mov    QWORD PTR [rsp+0x30],rbx
    17b5:	mov    QWORD PTR [rsp+0x38],r12
    17ba:	mov    QWORD PTR [rsp+0x40],r13
    17bf:	mov    QWORD PTR [rsp+0x48],r14
    17c4:	mov    r13,rdi
    17c7:	mov    QWORD PTR [rsp+0x18],0x0
    17d0:	mov    QWORD PTR [rsp],rsi
    17d4:	mov    r14,rsi
    17d7:	mov    rsi,r14
    17da:	mov    rdi,r13
    17dd:	call   17e2 <botlish_fn_11+0x3a>
			17de: R_X86_64_PLT32	rt_str_len-0x4
    17e2:	mov    rbx,rax
    17e5:	mov    QWORD PTR [rsp+0x8],rax
    17ea:	mov    esi,0x1
    17ef:	mov    QWORD PTR [rsp+0x10],0x1
    17f8:	mov    rcx,r14
    17fb:	mov    rdx,rbx
    17fe:	mov    rdi,r13
    1801:	call   1806 <botlish_fn_11+0x5e>
			1802: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_local<generic>
    1806:	mov    r12,rax
    1809:	test   r12,r12
    180c:	je     1969 <botlish_fn_11+0x1c1>
    1812:	mov    QWORD PTR [rsp+0x10],r12
    1817:	test   r12,0x1
    181e:	jne    1849 <botlish_fn_11+0xa1>
    1824:	mov    edx,0x1
    1829:	mov    rsi,r12
    182c:	mov    rdi,r13
    182f:	call   1834 <botlish_fn_11+0x8c>
			1830: R_X86_64_PLT32	rt_int_cmp-0x4
    1834:	mov    ecx,0x2
    1839:	test   rax,rax
    183c:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 1a08 <botlish_fn_11+0x260>
    1844:	jmp    185a <botlish_fn_11+0xb2>
    1849:	mov    ecx,0x2
    184e:	cmp    r12,0x1
    1852:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 1a08 <botlish_fn_11+0x260>
    185a:	cmp    rcx,0x6
    185e:	je     19e4 <botlish_fn_11+0x23c>
    1864:	mov    rcx,r12
    1867:	and    rcx,rbx
    186a:	test   rcx,0x1
    1871:	jne    189a <botlish_fn_11+0xf2>
    1877:	mov    rdx,rbx
    187a:	mov    rsi,r12
    187d:	mov    rdi,r13
    1880:	call   1885 <botlish_fn_11+0xdd>
			1881: R_X86_64_PLT32	rt_int_cmp-0x4
    1885:	mov    ecx,0x2
    188a:	test   rax,rax
    188d:	cmovge rcx,QWORD PTR [rip+0x173]        # 1a08 <botlish_fn_11+0x260>
    1895:	jmp    18aa <botlish_fn_11+0x102>
    189a:	mov    ecx,0x2
    189f:	cmp    r12,rbx
    18a2:	cmovge rcx,QWORD PTR [rip+0x15e]        # 1a08 <botlish_fn_11+0x260>
    18aa:	cmp    rcx,0x6
    18ae:	je     19da <botlish_fn_11+0x232>
    18b4:	lea    rcx,[rsp+0x20]
    18b9:	mov    rdx,r14
    18bc:	mov    rsi,r12
    18bf:	mov    rdi,r13
    18c2:	call   18c7 <botlish_fn_11+0x11f>
			18c3: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    18c7:	test   rax,rax
    18ca:	mov    rsi,rax
    18cd:	je     1969 <botlish_fn_11+0x1c1>
    18d3:	mov    rdx,QWORD PTR [rsp+0x20]
    18d8:	mov    rcx,QWORD PTR [rsp+0x28]
    18dd:	mov    rdi,r13
    18e0:	mov    rax,QWORD PTR [rdi+0x10]
    18e4:	mov    r8,QWORD PTR [rax+0x108]
    18eb:	call   18f0 <botlish_fn_11+0x148>
			18ec: R_X86_64_PLT32	rt_str_region_eq-0x4
    18f0:	cmp    rax,0x6
    18f4:	je     1907 <botlish_fn_11+0x15f>
    18fa:	mov    ecx,0x2
    18ff:	mov    rax,rcx
    1902:	jmp    19e9 <botlish_fn_11+0x241>
    1907:	mov    QWORD PTR [rsp+0x18],0x3
    1910:	test   r12,0x1
    1917:	jne    1925 <botlish_fn_11+0x17d>
    191d:	mov    rcx,r12
    1920:	jmp    193a <botlish_fn_11+0x192>
    1925:	mov    rsi,r12
    1928:	add    rsi,0x2
    192c:	mov    rcx,r12
    192f:	seto   al
    1932:	test   al,al
    1934:	je     194d <botlish_fn_11+0x1a5>
    193a:	mov    edx,0x3
    193f:	mov    rsi,rcx
    1942:	mov    rdi,r13
    1945:	call   194a <botlish_fn_11+0x1a2>
			1946: R_X86_64_PLT32	rt_int_add-0x4
    194a:	mov    rsi,rax
    194d:	mov    QWORD PTR [rsp+0x10],rsi
    1952:	mov    rcx,r14
    1955:	mov    rdx,rbx
    1958:	mov    rdi,r13
    195b:	call   1960 <botlish_fn_11+0x1b8>
			195c: R_X86_64_PLT32	botlish_fn_18-0x4 ; domain_loop<generic>
    1960:	test   rax,rax
    1963:	jne    1989 <botlish_fn_11+0x1e1>
    1969:	xor    rax,rax
    196c:	mov    rbx,QWORD PTR [rsp+0x30]
    1971:	mov    r12,QWORD PTR [rsp+0x38]
    1976:	mov    r13,QWORD PTR [rsp+0x40]
    197b:	mov    r14,QWORD PTR [rsp+0x48]
    1980:	add    rsp,0x50
    1984:	mov    rsp,rbp
    1987:	pop    rbp
    1988:	ret
    1989:	mov    rcx,rax
    198c:	and    rcx,rbx
    198f:	mov    rsi,rax
    1992:	test   rcx,0x1
    1999:	jne    19c2 <botlish_fn_11+0x21a>
    199f:	mov    rdx,rbx
    19a2:	mov    rdi,r13
    19a5:	call   19aa <botlish_fn_11+0x202>
			19a6: R_X86_64_PLT32	rt_int_cmp-0x4
    19aa:	mov    ecx,0x2
    19af:	test   rax,rax
    19b2:	mov    rax,rcx
    19b5:	cmove  rax,QWORD PTR [rip+0x4b]        # 1a08 <botlish_fn_11+0x260>
    19bd:	jmp    19e9 <botlish_fn_11+0x241>
    19c2:	mov    rdx,rbx
    19c5:	mov    eax,0x2
    19ca:	cmp    rsi,rdx
    19cd:	cmove  rax,QWORD PTR [rip+0x33]        # 1a08 <botlish_fn_11+0x260>
    19d5:	jmp    19e9 <botlish_fn_11+0x241>
    19da:	mov    eax,0x2
    19df:	jmp    19e9 <botlish_fn_11+0x241>
    19e4:	mov    eax,0x2
    19e9:	mov    rbx,QWORD PTR [rsp+0x30]
    19ee:	mov    r12,QWORD PTR [rsp+0x38]
    19f3:	mov    r13,QWORD PTR [rsp+0x40]
    19f8:	mov    r14,QWORD PTR [rsp+0x48]
    19fd:	add    rsp,0x50
    1a01:	mov    rsp,rbp
    1a04:	pop    rbp
    1a05:	ret
    1a06:	add    BYTE PTR [rax],al
    1a08:	(bad)
    1a09:	add    BYTE PTR [rax],al
    1a0b:	add    BYTE PTR [rax],al
    1a0d:	add    BYTE PTR [rax],al
	...

0000000000001a10 <botlish_entry_11: <str>>:
    1a10:	push   rbp
    1a11:	mov    rbp,rsp
    1a14:	mov    rsi,QWORD PTR [rdx]
    1a17:	call   1a1c <botlish_entry_11+0xc>
			1a18: R_X86_64_PLT32	botlish_fn_11-0x4 ; <str>
    1a1c:	mov    rsp,rbp
    1a1f:	pop    rbp
    1a20:	ret
    1a21:	add    BYTE PTR [rax],al
    1a23:	add    BYTE PTR [rax],al
    1a25:	add    BYTE PTR [rax],al
	...

0000000000001a28 <botlish_fn_12: <generic>>:
    1a28:	push   rbp
    1a29:	mov    rbp,rsp
    1a2c:	sub    rsp,0x60
    1a30:	mov    QWORD PTR [rsp+0x30],rbx
    1a35:	mov    QWORD PTR [rsp+0x38],r12
    1a3a:	mov    QWORD PTR [rsp+0x40],r13
    1a3f:	mov    QWORD PTR [rsp+0x48],r14
    1a44:	mov    QWORD PTR [rsp+0x50],r15
    1a49:	mov    QWORD PTR [rsp+0x18],0x0
    1a52:	mov    QWORD PTR [rsp],rsi
    1a56:	xor    r8d,r8d
    1a59:	test   rsi,0x7
    1a60:	jne    1a70 <botlish_fn_12+0x48>
    1a66:	movzx  rax,BYTE PTR [rsi]
    1a6a:	cmp    al,0x2
    1a6c:	sete   r8b
    1a70:	test   r8b,r8b
    1a73:	jne    1a93 <botlish_fn_12+0x6b>
    1a79:	mov    rdx,QWORD PTR [rdi+0x10]
    1a7d:	mov    rcx,QWORD PTR [rdx+0xe0]
    1a84:	mov    edx,0x1
    1a89:	call   1a8e <botlish_fn_12+0x66>
			1a8a: R_X86_64_PLT32	rt_type_error-0x4
    1a8e:	jmp    1c28 <botlish_fn_12+0x200>
    1a93:	mov    r13,rsi
    1a96:	mov    r14,rdi
    1a99:	call   1a9e <botlish_fn_12+0x76>
			1a9a: R_X86_64_PLT32	rt_str_len-0x4
    1a9e:	mov    rbx,rax
    1aa1:	mov    QWORD PTR [rsp+0x8],rax
    1aa6:	mov    edx,0x1
    1aab:	mov    r15,rdx
    1aae:	mov    QWORD PTR [rsp+0x10],0x1
    1ab7:	mov    rcx,r13
    1aba:	mov    rdx,rbx
    1abd:	mov    rsi,r15
    1ac0:	mov    rdi,r14
    1ac3:	call   1ac8 <botlish_fn_12+0xa0>
			1ac4: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_local<generic>
    1ac8:	mov    r12,rax
    1acb:	test   r12,r12
    1ace:	je     1c28 <botlish_fn_12+0x200>
    1ad4:	mov    QWORD PTR [rsp+0x10],r12
    1ad9:	test   r12,0x1
    1ae0:	jne    1b09 <botlish_fn_12+0xe1>
    1ae6:	mov    rdx,r15
    1ae9:	mov    rsi,r12
    1aec:	mov    rdi,r14
    1aef:	call   1af4 <botlish_fn_12+0xcc>
			1af0: R_X86_64_PLT32	rt_int_cmp-0x4
    1af4:	mov    ecx,0x2
    1af9:	test   rax,rax
    1afc:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 1cd0 <botlish_fn_12+0x2a8>
    1b04:	jmp    1b1a <botlish_fn_12+0xf2>
    1b09:	mov    ecx,0x2
    1b0e:	cmp    r12,0x1
    1b12:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 1cd0 <botlish_fn_12+0x2a8>
    1b1a:	cmp    rcx,0x6
    1b1e:	je     1ca8 <botlish_fn_12+0x280>
    1b24:	mov    rax,r12
    1b27:	and    rax,rbx
    1b2a:	test   rax,0x1
    1b30:	jne    1b59 <botlish_fn_12+0x131>
    1b36:	mov    rdx,rbx
    1b39:	mov    rsi,r12
    1b3c:	mov    rdi,r14
    1b3f:	call   1b44 <botlish_fn_12+0x11c>
			1b40: R_X86_64_PLT32	rt_int_cmp-0x4
    1b44:	mov    ecx,0x2
    1b49:	test   rax,rax
    1b4c:	cmovge rcx,QWORD PTR [rip+0x17c]        # 1cd0 <botlish_fn_12+0x2a8>
    1b54:	jmp    1b69 <botlish_fn_12+0x141>
    1b59:	mov    ecx,0x2
    1b5e:	cmp    r12,rbx
    1b61:	cmovge rcx,QWORD PTR [rip+0x167]        # 1cd0 <botlish_fn_12+0x2a8>
    1b69:	cmp    rcx,0x6
    1b6d:	je     1c9e <botlish_fn_12+0x276>
    1b73:	lea    rcx,[rsp+0x20]
    1b78:	mov    rdx,r13
    1b7b:	mov    rsi,r12
    1b7e:	mov    rdi,r14
    1b81:	call   1b86 <botlish_fn_12+0x15e>
			1b82: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    1b86:	test   rax,rax
    1b89:	mov    rsi,rax
    1b8c:	je     1c28 <botlish_fn_12+0x200>
    1b92:	mov    rdx,QWORD PTR [rsp+0x20]
    1b97:	mov    rcx,QWORD PTR [rsp+0x28]
    1b9c:	mov    rdi,r14
    1b9f:	mov    rax,QWORD PTR [rdi+0x10]
    1ba3:	mov    r8,QWORD PTR [rax+0x108]
    1baa:	call   1baf <botlish_fn_12+0x187>
			1bab: R_X86_64_PLT32	rt_str_region_eq-0x4
    1baf:	cmp    rax,0x6
    1bb3:	je     1bc6 <botlish_fn_12+0x19e>
    1bb9:	mov    ecx,0x2
    1bbe:	mov    rax,rcx
    1bc1:	jmp    1cad <botlish_fn_12+0x285>
    1bc6:	mov    QWORD PTR [rsp+0x18],0x3
    1bcf:	test   r12,0x1
    1bd6:	jne    1be4 <botlish_fn_12+0x1bc>
    1bdc:	mov    rdi,r12
    1bdf:	jmp    1bf9 <botlish_fn_12+0x1d1>
    1be4:	mov    rsi,r12
    1be7:	add    rsi,0x2
    1beb:	mov    rdi,r12
    1bee:	seto   al
    1bf1:	test   al,al
    1bf3:	je     1c0c <botlish_fn_12+0x1e4>
    1bf9:	mov    edx,0x3
    1bfe:	mov    rsi,rdi
    1c01:	mov    rdi,r14
    1c04:	call   1c09 <botlish_fn_12+0x1e1>
			1c05: R_X86_64_PLT32	rt_int_add-0x4
    1c09:	mov    rsi,rax
    1c0c:	mov    QWORD PTR [rsp+0x10],rsi
    1c11:	mov    rcx,r13
    1c14:	mov    rdx,rbx
    1c17:	mov    rdi,r14
    1c1a:	call   1c1f <botlish_fn_12+0x1f7>
			1c1b: R_X86_64_PLT32	botlish_fn_18-0x4 ; domain_loop<generic>
    1c1f:	test   rax,rax
    1c22:	jne    1c4d <botlish_fn_12+0x225>
    1c28:	xor    rax,rax
    1c2b:	mov    rbx,QWORD PTR [rsp+0x30]
    1c30:	mov    r12,QWORD PTR [rsp+0x38]
    1c35:	mov    r13,QWORD PTR [rsp+0x40]
    1c3a:	mov    r14,QWORD PTR [rsp+0x48]
    1c3f:	mov    r15,QWORD PTR [rsp+0x50]
    1c44:	add    rsp,0x60
    1c48:	mov    rsp,rbp
    1c4b:	pop    rbp
    1c4c:	ret
    1c4d:	mov    rcx,rax
    1c50:	and    rcx,rbx
    1c53:	mov    rsi,rax
    1c56:	test   rcx,0x1
    1c5d:	jne    1c86 <botlish_fn_12+0x25e>
    1c63:	mov    rdx,rbx
    1c66:	mov    rdi,r14
    1c69:	call   1c6e <botlish_fn_12+0x246>
			1c6a: R_X86_64_PLT32	rt_int_cmp-0x4
    1c6e:	mov    ecx,0x2
    1c73:	test   rax,rax
    1c76:	mov    rax,rcx
    1c79:	cmove  rax,QWORD PTR [rip+0x4f]        # 1cd0 <botlish_fn_12+0x2a8>
    1c81:	jmp    1cad <botlish_fn_12+0x285>
    1c86:	mov    rdx,rbx
    1c89:	mov    eax,0x2
    1c8e:	cmp    rsi,rdx
    1c91:	cmove  rax,QWORD PTR [rip+0x37]        # 1cd0 <botlish_fn_12+0x2a8>
    1c99:	jmp    1cad <botlish_fn_12+0x285>
    1c9e:	mov    eax,0x2
    1ca3:	jmp    1cad <botlish_fn_12+0x285>
    1ca8:	mov    eax,0x2
    1cad:	mov    rbx,QWORD PTR [rsp+0x30]
    1cb2:	mov    r12,QWORD PTR [rsp+0x38]
    1cb7:	mov    r13,QWORD PTR [rsp+0x40]
    1cbc:	mov    r14,QWORD PTR [rsp+0x48]
    1cc1:	mov    r15,QWORD PTR [rsp+0x50]
    1cc6:	add    rsp,0x60
    1cca:	mov    rsp,rbp
    1ccd:	pop    rbp
    1cce:	ret
    1ccf:	add    BYTE PTR [rsi],al
    1cd1:	add    BYTE PTR [rax],al
    1cd3:	add    BYTE PTR [rax],al
    1cd5:	add    BYTE PTR [rax],al
	...

0000000000001cd8 <botlish_entry_12: <generic>>:
    1cd8:	push   rbp
    1cd9:	mov    rbp,rsp
    1cdc:	mov    rsi,QWORD PTR [rdx]
    1cdf:	call   1ce4 <botlish_entry_12+0xc>
			1ce0: R_X86_64_PLT32	botlish_fn_12-0x4 ; <generic>
    1ce4:	mov    rsp,rbp
    1ce7:	pop    rbp
    1ce8:	ret

0000000000001ce9 <botlish_fn_13: char_at<generic>>:
    1ce9:	push   rbp
    1cea:	mov    rbp,rsp
    1ced:	sub    rsp,0x50
    1cf1:	mov    QWORD PTR [rsp+0x20],rbx
    1cf6:	mov    QWORD PTR [rsp+0x28],r12
    1cfb:	mov    QWORD PTR [rsp+0x30],r13
    1d00:	mov    QWORD PTR [rsp+0x38],r14
    1d05:	mov    QWORD PTR [rsp+0x40],r15
    1d0a:	mov    r14,rcx
    1d0d:	mov    QWORD PTR [rsp],rsi
    1d11:	mov    QWORD PTR [rsp+0x8],rdx
    1d16:	mov    r13,rdx
    1d19:	mov    QWORD PTR [rsp+0x10],0x3
    1d22:	mov    r9d,0x1
    1d28:	test   rsi,0x1
    1d2f:	jne    1d4f <botlish_fn_13+0x66>
    1d35:	xor    r9d,r9d
    1d38:	test   rsi,0x7
    1d3f:	jne    1d4f <botlish_fn_13+0x66>
    1d45:	movzx  rax,BYTE PTR [rsi]
    1d49:	cmp    al,0x1
    1d4b:	sete   r9b
    1d4f:	test   r9b,r9b
    1d52:	jne    1d70 <botlish_fn_13+0x87>
    1d58:	mov    rax,QWORD PTR [rdi+0x10]
    1d5c:	mov    rcx,QWORD PTR [rax+0x110]
    1d63:	xor    rdx,rdx
    1d66:	call   1d6b <botlish_fn_13+0x82>
			1d67: R_X86_64_PLT32	rt_type_error-0x4
    1d6b:	jmp    1e2d <botlish_fn_13+0x144>
    1d70:	mov    r12,rdi
    1d73:	test   rsi,0x1
    1d7a:	jne    1d88 <botlish_fn_13+0x9f>
    1d80:	mov    rbx,rsi
    1d83:	jmp    1da5 <botlish_fn_13+0xbc>
    1d88:	mov    rax,rsi
    1d8b:	add    rax,0x2
    1d8f:	mov    rbx,rsi
    1d92:	seto   cl
    1d95:	test   cl,cl
    1d97:	jne    1da5 <botlish_fn_13+0xbc>
    1d9d:	mov    r15,rax
    1da0:	jmp    1db8 <botlish_fn_13+0xcf>
    1da5:	mov    edx,0x3
    1daa:	mov    rsi,rbx
    1dad:	mov    rdi,r12
    1db0:	call   1db5 <botlish_fn_13+0xcc>
			1db1: R_X86_64_PLT32	rt_int_add-0x4
    1db5:	mov    r15,rax
    1db8:	mov    ecx,0x1
    1dbd:	mov    rsi,rbx
    1dc0:	test   rsi,0x1
    1dc7:	jne    1ded <botlish_fn_13+0x104>
    1dcd:	xor    ecx,ecx
    1dcf:	mov    rsi,rbx
    1dd2:	test   rsi,0x7
    1dd9:	jne    1ded <botlish_fn_13+0x104>
    1ddf:	mov    rsi,rbx
    1de2:	movzx  rcx,BYTE PTR [rsi]
    1de6:	rex cmp cl,0x1
    1dea:	sete   cl
    1ded:	test   cl,cl
    1def:	jne    1e13 <botlish_fn_13+0x12a>
    1df5:	mov    rdi,r12
    1df8:	mov    rsi,QWORD PTR [rdi+0x10]
    1dfc:	mov    rcx,QWORD PTR [rsi+0x118]
    1e03:	xor    rdx,rdx
    1e06:	mov    rsi,rbx
    1e09:	call   1e0e <botlish_fn_13+0x125>
			1e0a: R_X86_64_PLT32	rt_type_error-0x4
    1e0e:	jmp    1e2d <botlish_fn_13+0x144>
    1e13:	mov    rdi,r12
    1e16:	mov    rcx,r15
    1e19:	mov    rdx,rbx
    1e1c:	mov    rsi,r13
    1e1f:	call   1e24 <botlish_fn_13+0x13b>
			1e20: R_X86_64_PLT32	rt_str_region_check-0x4
    1e24:	test   rax,rax
    1e27:	jne    1e52 <botlish_fn_13+0x169>
    1e2d:	xor    rax,rax
    1e30:	mov    rbx,QWORD PTR [rsp+0x20]
    1e35:	mov    r12,QWORD PTR [rsp+0x28]
    1e3a:	mov    r13,QWORD PTR [rsp+0x30]
    1e3f:	mov    r14,QWORD PTR [rsp+0x38]
    1e44:	mov    r15,QWORD PTR [rsp+0x40]
    1e49:	add    rsp,0x50
    1e4d:	mov    rsp,rbp
    1e50:	pop    rbp
    1e51:	ret
    1e52:	mov    rcx,r14
    1e55:	mov    rsi,rbx
    1e58:	mov    QWORD PTR [rcx],rsi
    1e5b:	mov    rax,r15
    1e5e:	mov    QWORD PTR [rcx+0x8],rax
    1e62:	mov    rax,r13
    1e65:	mov    rbx,QWORD PTR [rsp+0x20]
    1e6a:	mov    r12,QWORD PTR [rsp+0x28]
    1e6f:	mov    r13,QWORD PTR [rsp+0x30]
    1e74:	mov    r14,QWORD PTR [rsp+0x38]
    1e79:	mov    r15,QWORD PTR [rsp+0x40]
    1e7e:	add    rsp,0x50
    1e82:	mov    rsp,rbp
    1e85:	pop    rbp
    1e86:	ret

0000000000001e87 <botlish_entry_13: char_at<generic>>:
    1e87:	push   rbp
    1e88:	mov    rbp,rsp
    1e8b:	ud2
    1e8d:	add    BYTE PTR [rax],al
	...

0000000000001e90 <botlish_fn_14: scan_local<generic>>:
    1e90:	push   rbp
    1e91:	mov    rbp,rsp
    1e94:	sub    rsp,0x80
    1e9b:	mov    QWORD PTR [rsp+0x50],rbx
    1ea0:	mov    QWORD PTR [rsp+0x58],r12
    1ea5:	mov    QWORD PTR [rsp+0x60],r13
    1eaa:	mov    QWORD PTR [rsp+0x68],r14
    1eaf:	mov    QWORD PTR [rsp+0x70],r15
    1eb4:	mov    rax,rdi
    1eb7:	mov    QWORD PTR [rsp+0x18],0x0
    1ec0:	mov    QWORD PTR [rsp],rsi
    1ec4:	mov    r14,rsi
    1ec7:	mov    QWORD PTR [rsp+0x8],rdx
    1ecc:	mov    QWORD PTR [rsp+0x10],rcx
    1ed1:	mov    r12,rcx
    1ed4:	mov    r11d,0x1
    1eda:	mov    rsi,r14
    1edd:	test   rsi,0x1
    1ee4:	jne    1f06 <botlish_fn_14+0x76>
    1eea:	xor    r11d,r11d
    1eed:	test   rsi,0x7
    1ef4:	jne    1f06 <botlish_fn_14+0x76>
    1efa:	movzx  rdi,BYTE PTR [rsi]
    1efe:	cmp    dil,0x1
    1f02:	sete   r11b
    1f06:	test   r11b,r11b
    1f09:	jne    1f2a <botlish_fn_14+0x9a>
    1f0f:	mov    rdi,rax
    1f12:	mov    r9,QWORD PTR [rdi+0x10]
    1f16:	mov    rcx,QWORD PTR [r9+0xc0]
    1f1d:	xor    rdx,rdx
    1f20:	call   1f25 <botlish_fn_14+0x95>
			1f21: R_X86_64_PLT32	rt_type_error-0x4
    1f25:	jmp    1fdd <botlish_fn_14+0x14d>
    1f2a:	mov    r13,rdx
    1f2d:	mov    r10,rsi
    1f30:	and    r10,r13
    1f33:	mov    r14,rsi
    1f36:	test   r10,0x1
    1f3d:	jne    1f69 <botlish_fn_14+0xd9>
    1f43:	mov    rbx,rax
    1f46:	mov    rdx,r13
    1f49:	mov    rsi,r14
    1f4c:	mov    rdi,rbx
    1f4f:	call   1f54 <botlish_fn_14+0xc4>
			1f50: R_X86_64_PLT32	rt_int_cmp-0x4
    1f54:	mov    ecx,0x2
    1f59:	test   rax,rax
    1f5c:	cmovge rcx,QWORD PTR [rip+0x24c]        # 21b0 <botlish_fn_14+0x320>
    1f64:	jmp    1f7f <botlish_fn_14+0xef>
    1f69:	mov    rbx,rax
    1f6c:	mov    ecx,0x2
    1f71:	mov    rsi,r14
    1f74:	cmp    rsi,r13
    1f77:	cmovge rcx,QWORD PTR [rip+0x231]        # 21b0 <botlish_fn_14+0x320>
    1f7f:	mov    eax,0x6
    1f84:	mov    QWORD PTR [rsp+0x30],rax
    1f89:	cmp    rcx,0x6
    1f8d:	je     2183 <botlish_fn_14+0x2f3>
    1f93:	lea    rcx,[rsp+0x20]
    1f98:	mov    rdx,r12
    1f9b:	mov    rsi,r14
    1f9e:	mov    rdi,rbx
    1fa1:	call   1fa6 <botlish_fn_14+0x116>
			1fa2: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    1fa6:	mov    rsi,rax
    1fa9:	mov    r15,rax
    1fac:	test   rax,rsi
    1faf:	je     1fdd <botlish_fn_14+0x14d>
    1fb5:	mov    rdx,QWORD PTR [rsp+0x20]
    1fba:	mov    QWORD PTR [rsp+0x40],rdx
    1fbf:	mov    rcx,QWORD PTR [rsp+0x28]
    1fc4:	mov    QWORD PTR [rsp+0x38],rcx
    1fc9:	mov    rsi,r15
    1fcc:	mov    rdi,rbx
    1fcf:	call   1fd4 <botlish_fn_14+0x144>
			1fd0: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1fd4:	test   rax,rax
    1fd7:	jne    2005 <botlish_fn_14+0x175>
    1fdd:	xor    rax,rax
    1fe0:	mov    rbx,QWORD PTR [rsp+0x50]
    1fe5:	mov    r12,QWORD PTR [rsp+0x58]
    1fea:	mov    r13,QWORD PTR [rsp+0x60]
    1fef:	mov    r14,QWORD PTR [rsp+0x68]
    1ff4:	mov    r15,QWORD PTR [rsp+0x70]
    1ff9:	add    rsp,0x80
    2000:	mov    rsp,rbp
    2003:	pop    rbp
    2004:	ret
    2005:	cmp    rax,0x6
    2009:	je     2104 <botlish_fn_14+0x274>
    200f:	mov    rax,QWORD PTR [rbx+0x10]
    2013:	mov    r8,QWORD PTR [rax+0x120]
    201a:	mov    rcx,QWORD PTR [rsp+0x38]
    201f:	mov    rdx,QWORD PTR [rsp+0x40]
    2024:	mov    rsi,r15
    2027:	mov    rdi,rbx
    202a:	call   202f <botlish_fn_14+0x19f>
			202b: R_X86_64_PLT32	rt_str_region_eq-0x4
    202f:	cmp    rax,0x6
    2033:	je     20fa <botlish_fn_14+0x26a>
    2039:	mov    rax,QWORD PTR [rbx+0x10]
    203d:	mov    r8,QWORD PTR [rax+0x128]
    2044:	mov    rcx,QWORD PTR [rsp+0x38]
    2049:	mov    rdx,QWORD PTR [rsp+0x40]
    204e:	mov    rsi,r15
    2051:	mov    rdi,rbx
    2054:	call   2059 <botlish_fn_14+0x1c9>
			2055: R_X86_64_PLT32	rt_str_region_eq-0x4
    2059:	cmp    rax,0x6
    205d:	je     20f0 <botlish_fn_14+0x260>
    2063:	mov    rax,QWORD PTR [rbx+0x10]
    2067:	mov    r8,QWORD PTR [rax+0xc8]
    206e:	mov    rcx,QWORD PTR [rsp+0x38]
    2073:	mov    rdx,QWORD PTR [rsp+0x40]
    2078:	mov    rsi,r15
    207b:	mov    rdi,rbx
    207e:	call   2083 <botlish_fn_14+0x1f3>
			207f: R_X86_64_PLT32	rt_str_region_eq-0x4
    2083:	cmp    rax,0x6
    2087:	je     20e6 <botlish_fn_14+0x256>
    208d:	mov    rax,QWORD PTR [rbx+0x10]
    2091:	mov    r8,QWORD PTR [rax+0x110]
    2098:	mov    rcx,QWORD PTR [rsp+0x38]
    209d:	mov    rdx,QWORD PTR [rsp+0x40]
    20a2:	mov    rsi,r15
    20a5:	mov    rdi,rbx
    20a8:	call   20ad <botlish_fn_14+0x21d>
			20a9: R_X86_64_PLT32	rt_str_region_eq-0x4
    20ad:	cmp    rax,0x6
    20b1:	je     20dc <botlish_fn_14+0x24c>
    20b7:	mov    rax,QWORD PTR [rbx+0x10]
    20bb:	mov    r8,QWORD PTR [rax+0x130]
    20c2:	mov    rcx,QWORD PTR [rsp+0x38]
    20c7:	mov    rdx,QWORD PTR [rsp+0x40]
    20cc:	mov    rsi,r15
    20cf:	mov    rdi,rbx
    20d2:	call   20d7 <botlish_fn_14+0x247>
			20d3: R_X86_64_PLT32	rt_str_region_eq-0x4
    20d7:	jmp    2109 <botlish_fn_14+0x279>
    20dc:	mov    rax,QWORD PTR [rsp+0x30]
    20e1:	jmp    2109 <botlish_fn_14+0x279>
    20e6:	mov    rax,QWORD PTR [rsp+0x30]
    20eb:	jmp    2109 <botlish_fn_14+0x279>
    20f0:	mov    rax,QWORD PTR [rsp+0x30]
    20f5:	jmp    2109 <botlish_fn_14+0x279>
    20fa:	mov    rax,QWORD PTR [rsp+0x30]
    20ff:	jmp    2109 <botlish_fn_14+0x279>
    2104:	mov    rax,QWORD PTR [rsp+0x30]
    2109:	cmp    rax,0x6
    210d:	je     211b <botlish_fn_14+0x28b>
    2113:	mov    rax,r14
    2116:	jmp    2186 <botlish_fn_14+0x2f6>
    211b:	mov    QWORD PTR [rsp+0x18],0x3
    2124:	mov    rsi,r14
    2127:	test   rsi,0x1
    212e:	je     2154 <botlish_fn_14+0x2c4>
    2134:	mov    rsi,r14
    2137:	mov    rax,rsi
    213a:	add    rax,0x2
    213e:	seto   cl
    2141:	test   cl,cl
    2143:	jne    2154 <botlish_fn_14+0x2c4>
    2149:	mov    rsi,rax
    214c:	mov    r14,rax
    214f:	jmp    216a <botlish_fn_14+0x2da>
    2154:	mov    edx,0x3
    2159:	mov    rsi,r14
    215c:	mov    rdi,rbx
    215f:	call   2164 <botlish_fn_14+0x2d4>
			2160: R_X86_64_PLT32	rt_int_add-0x4
    2164:	mov    rsi,rax
    2167:	mov    r14,rax
    216a:	mov    QWORD PTR [rsp],rsi
    216e:	mov    QWORD PTR [rsp+0x8],r13
    2173:	mov    QWORD PTR [rsp+0x10],r12
    2178:	mov    rax,rbx
    217b:	mov    rdx,r13
    217e:	jmp    1ed4 <botlish_fn_14+0x44>
    2183:	mov    rax,r14
    2186:	mov    rbx,QWORD PTR [rsp+0x50]
    218b:	mov    r12,QWORD PTR [rsp+0x58]
    2190:	mov    r13,QWORD PTR [rsp+0x60]
    2195:	mov    r14,QWORD PTR [rsp+0x68]
    219a:	mov    r15,QWORD PTR [rsp+0x70]
    219f:	add    rsp,0x80
    21a6:	mov    rsp,rbp
    21a9:	pop    rbp
    21aa:	ret
    21ab:	add    BYTE PTR [rax],al
    21ad:	add    BYTE PTR [rax],al
    21af:	add    BYTE PTR [rsi],al
    21b1:	add    BYTE PTR [rax],al
    21b3:	add    BYTE PTR [rax],al
    21b5:	add    BYTE PTR [rax],al
	...

00000000000021b8 <botlish_entry_14: scan_local<generic>>:
    21b8:	push   rbp
    21b9:	mov    rbp,rsp
    21bc:	mov    rsi,QWORD PTR [rdx]
    21bf:	mov    r8,QWORD PTR [rdx+0x8]
    21c3:	mov    rcx,QWORD PTR [rdx+0x10]
    21c7:	mov    rdx,r8
    21ca:	call   21cf <botlish_entry_14+0x17>
			21cb: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_local<generic>
    21cf:	mov    rsp,rbp
    21d2:	pop    rbp
    21d3:	ret
    21d4:	add    BYTE PTR [rax],al
	...

00000000000021d8 <botlish_fn_15: scan_label<generic>>:
    21d8:	push   rbp
    21d9:	mov    rbp,rsp
    21dc:	sub    rsp,0x80
    21e3:	mov    QWORD PTR [rsp+0x50],rbx
    21e8:	mov    QWORD PTR [rsp+0x58],r12
    21ed:	mov    QWORD PTR [rsp+0x60],r13
    21f2:	mov    QWORD PTR [rsp+0x68],r14
    21f7:	mov    QWORD PTR [rsp+0x70],r15
    21fc:	mov    QWORD PTR [rsp+0x18],0x0
    2205:	mov    QWORD PTR [rsp],rsi
    2209:	mov    r14,rsi
    220c:	mov    QWORD PTR [rsp+0x8],rdx
    2211:	mov    QWORD PTR [rsp+0x10],rcx
    2216:	mov    r12,rcx
    2219:	mov    r11d,0x1
    221f:	mov    rsi,r14
    2222:	test   rsi,0x1
    2229:	jne    2249 <botlish_fn_15+0x71>
    222f:	xor    r11d,r11d
    2232:	test   rsi,0x7
    2239:	jne    2249 <botlish_fn_15+0x71>
    223f:	movzx  rax,BYTE PTR [rsi]
    2243:	cmp    al,0x1
    2245:	sete   r11b
    2249:	test   r11b,r11b
    224c:	jne    226a <botlish_fn_15+0x92>
    2252:	mov    rax,QWORD PTR [rdi+0x10]
    2256:	mov    rcx,QWORD PTR [rax+0xc0]
    225d:	xor    rdx,rdx
    2260:	call   2265 <botlish_fn_15+0x8d>
			2261: R_X86_64_PLT32	rt_type_error-0x4
    2265:	jmp    2316 <botlish_fn_15+0x13e>
    226a:	mov    r13,rdx
    226d:	mov    rax,rsi
    2270:	and    rax,r13
    2273:	mov    r14,rsi
    2276:	test   rax,0x1
    227c:	jne    22a5 <botlish_fn_15+0xcd>
    2282:	mov    rbx,rdi
    2285:	mov    rdx,r13
    2288:	mov    rsi,r14
    228b:	call   2290 <botlish_fn_15+0xb8>
			228c: R_X86_64_PLT32	rt_int_cmp-0x4
    2290:	mov    ecx,0x2
    2295:	test   rax,rax
    2298:	cmovge rcx,QWORD PTR [rip+0x178]        # 2418 <botlish_fn_15+0x240>
    22a0:	jmp    22bb <botlish_fn_15+0xe3>
    22a5:	mov    rbx,rdi
    22a8:	mov    ecx,0x2
    22ad:	mov    rsi,r14
    22b0:	cmp    rsi,r13
    22b3:	cmovge rcx,QWORD PTR [rip+0x15d]        # 2418 <botlish_fn_15+0x240>
    22bb:	mov    eax,0x6
    22c0:	mov    QWORD PTR [rsp+0x30],rax
    22c5:	cmp    rcx,0x6
    22c9:	je     23ec <botlish_fn_15+0x214>
    22cf:	lea    rcx,[rsp+0x20]
    22d4:	mov    rdx,r12
    22d7:	mov    rsi,r14
    22da:	mov    rdi,rbx
    22dd:	call   22e2 <botlish_fn_15+0x10a>
			22de: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    22e2:	test   rax,rax
    22e5:	mov    r15,rax
    22e8:	je     2316 <botlish_fn_15+0x13e>
    22ee:	mov    rdx,QWORD PTR [rsp+0x20]
    22f3:	mov    QWORD PTR [rsp+0x40],rdx
    22f8:	mov    rcx,QWORD PTR [rsp+0x28]
    22fd:	mov    QWORD PTR [rsp+0x38],rcx
    2302:	mov    rsi,r15
    2305:	mov    rdi,rbx
    2308:	call   230d <botlish_fn_15+0x135>
			2309: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    230d:	test   rax,rax
    2310:	jne    233e <botlish_fn_15+0x166>
    2316:	xor    rax,rax
    2319:	mov    rbx,QWORD PTR [rsp+0x50]
    231e:	mov    r12,QWORD PTR [rsp+0x58]
    2323:	mov    r13,QWORD PTR [rsp+0x60]
    2328:	mov    r14,QWORD PTR [rsp+0x68]
    232d:	mov    r15,QWORD PTR [rsp+0x70]
    2332:	add    rsp,0x80
    2339:	mov    rsp,rbp
    233c:	pop    rbp
    233d:	ret
    233e:	cmp    rax,0x6
    2342:	je     236d <botlish_fn_15+0x195>
    2348:	mov    r11,QWORD PTR [rbx+0x10]
    234c:	mov    r8,QWORD PTR [r11+0x130]
    2353:	mov    rcx,QWORD PTR [rsp+0x38]
    2358:	mov    rdx,QWORD PTR [rsp+0x40]
    235d:	mov    rsi,r15
    2360:	mov    rdi,rbx
    2363:	call   2368 <botlish_fn_15+0x190>
			2364: R_X86_64_PLT32	rt_str_region_eq-0x4
    2368:	jmp    2372 <botlish_fn_15+0x19a>
    236d:	mov    rax,QWORD PTR [rsp+0x30]
    2372:	cmp    rax,0x6
    2376:	je     2384 <botlish_fn_15+0x1ac>
    237c:	mov    rax,r14
    237f:	jmp    23ef <botlish_fn_15+0x217>
    2384:	mov    QWORD PTR [rsp+0x18],0x3
    238d:	mov    rsi,r14
    2390:	test   rsi,0x1
    2397:	je     23bd <botlish_fn_15+0x1e5>
    239d:	mov    rsi,r14
    23a0:	mov    rax,rsi
    23a3:	add    rax,0x2
    23a7:	seto   cl
    23aa:	test   cl,cl
    23ac:	jne    23bd <botlish_fn_15+0x1e5>
    23b2:	mov    rsi,rax
    23b5:	mov    r14,rax
    23b8:	jmp    23d3 <botlish_fn_15+0x1fb>
    23bd:	mov    edx,0x3
    23c2:	mov    rsi,r14
    23c5:	mov    rdi,rbx
    23c8:	call   23cd <botlish_fn_15+0x1f5>
			23c9: R_X86_64_PLT32	rt_int_add-0x4
    23cd:	mov    rsi,rax
    23d0:	mov    r14,rax
    23d3:	mov    QWORD PTR [rsp],rsi
    23d7:	mov    QWORD PTR [rsp+0x8],r13
    23dc:	mov    QWORD PTR [rsp+0x10],r12
    23e1:	mov    rdx,r13
    23e4:	mov    rdi,rbx
    23e7:	jmp    2219 <botlish_fn_15+0x41>
    23ec:	mov    rax,r14
    23ef:	mov    rbx,QWORD PTR [rsp+0x50]
    23f4:	mov    r12,QWORD PTR [rsp+0x58]
    23f9:	mov    r13,QWORD PTR [rsp+0x60]
    23fe:	mov    r14,QWORD PTR [rsp+0x68]
    2403:	mov    r15,QWORD PTR [rsp+0x70]
    2408:	add    rsp,0x80
    240f:	mov    rsp,rbp
    2412:	pop    rbp
    2413:	ret
    2414:	add    BYTE PTR [rax],al
    2416:	add    BYTE PTR [rax],al
    2418:	(bad)
    2419:	add    BYTE PTR [rax],al
    241b:	add    BYTE PTR [rax],al
    241d:	add    BYTE PTR [rax],al
	...

0000000000002420 <botlish_entry_15: scan_label<generic>>:
    2420:	push   rbp
    2421:	mov    rbp,rsp
    2424:	mov    rsi,QWORD PTR [rdx]
    2427:	mov    r8,QWORD PTR [rdx+0x8]
    242b:	mov    rcx,QWORD PTR [rdx+0x10]
    242f:	mov    rdx,r8
    2432:	call   2437 <botlish_entry_15+0x17>
			2433: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_label<generic>
    2437:	mov    rsp,rbp
    243a:	pop    rbp
    243b:	ret
    243c:	add    BYTE PTR [rax],al
	...

0000000000002440 <botlish_fn_16: scan_alpha<generic>>:
    2440:	push   rbp
    2441:	mov    rbp,rsp
    2444:	sub    rsp,0x50
    2448:	mov    QWORD PTR [rsp+0x30],rbx
    244d:	mov    QWORD PTR [rsp+0x38],r12
    2452:	mov    QWORD PTR [rsp+0x40],r13
    2457:	mov    QWORD PTR [rsp+0x48],r14
    245c:	mov    r14,rdi
    245f:	mov    QWORD PTR [rsp+0x18],0x0
    2468:	mov    QWORD PTR [rsp],rsi
    246c:	mov    r13,rsi
    246f:	mov    QWORD PTR [rsp+0x8],rdx
    2474:	mov    r12,rdx
    2477:	mov    QWORD PTR [rsp+0x10],rcx
    247c:	mov    rbx,rcx
    247f:	mov    r11d,0x1
    2485:	mov    rsi,r13
    2488:	test   rsi,0x1
    248f:	jne    24af <botlish_fn_16+0x6f>
    2495:	xor    r11d,r11d
    2498:	test   rsi,0x7
    249f:	jne    24af <botlish_fn_16+0x6f>
    24a5:	movzx  rax,BYTE PTR [rsi]
    24a9:	cmp    al,0x1
    24ab:	sete   r11b
    24af:	test   r11b,r11b
    24b2:	jne    24d3 <botlish_fn_16+0x93>
    24b8:	mov    rdi,r14
    24bb:	mov    rax,QWORD PTR [rdi+0x10]
    24bf:	mov    rcx,QWORD PTR [rax+0xc0]
    24c6:	xor    rdx,rdx
    24c9:	call   24ce <botlish_fn_16+0x8e>
			24ca: R_X86_64_PLT32	rt_type_error-0x4
    24ce:	jmp    2562 <botlish_fn_16+0x122>
    24d3:	mov    rax,rsi
    24d6:	and    rax,r12
    24d9:	mov    r13,rsi
    24dc:	test   rax,0x1
    24e2:	jne    250b <botlish_fn_16+0xcb>
    24e8:	mov    rdx,r12
    24eb:	mov    rsi,r13
    24ee:	mov    rdi,r14
    24f1:	call   24f6 <botlish_fn_16+0xb6>
			24f2: R_X86_64_PLT32	rt_int_cmp-0x4
    24f6:	mov    ecx,0x2
    24fb:	test   rax,rax
    24fe:	cmovge rcx,QWORD PTR [rip+0x112]        # 2618 <botlish_fn_16+0x1d8>
    2506:	jmp    251e <botlish_fn_16+0xde>
    250b:	mov    ecx,0x2
    2510:	mov    rsi,r13
    2513:	cmp    rsi,r12
    2516:	cmovge rcx,QWORD PTR [rip+0xfa]        # 2618 <botlish_fn_16+0x1d8>
    251e:	cmp    rcx,0x6
    2522:	je     25f6 <botlish_fn_16+0x1b6>
    2528:	lea    rcx,[rsp+0x20]
    252d:	mov    rdx,rbx
    2530:	mov    rsi,r13
    2533:	mov    rdi,r14
    2536:	call   253b <botlish_fn_16+0xfb>
			2537: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    253b:	test   rax,rax
    253e:	mov    rsi,rax
    2541:	je     2562 <botlish_fn_16+0x122>
    2547:	mov    rdx,QWORD PTR [rsp+0x20]
    254c:	mov    rcx,QWORD PTR [rsp+0x28]
    2551:	mov    rdi,r14
    2554:	call   2559 <botlish_fn_16+0x119>
			2555: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    2559:	test   rax,rax
    255c:	jne    2582 <botlish_fn_16+0x142>
    2562:	xor    rax,rax
    2565:	mov    rbx,QWORD PTR [rsp+0x30]
    256a:	mov    r12,QWORD PTR [rsp+0x38]
    256f:	mov    r13,QWORD PTR [rsp+0x40]
    2574:	mov    r14,QWORD PTR [rsp+0x48]
    2579:	add    rsp,0x50
    257d:	mov    rsp,rbp
    2580:	pop    rbp
    2581:	ret
    2582:	cmp    rax,0x6
    2586:	je     2594 <botlish_fn_16+0x154>
    258c:	mov    rax,r13
    258f:	jmp    25f9 <botlish_fn_16+0x1b9>
    2594:	mov    QWORD PTR [rsp+0x18],0x3
    259d:	mov    rsi,r13
    25a0:	test   rsi,0x1
    25a7:	je     25cd <botlish_fn_16+0x18d>
    25ad:	mov    rsi,r13
    25b0:	mov    r11,rsi
    25b3:	add    r11,0x2
    25b7:	seto   al
    25ba:	test   al,al
    25bc:	jne    25cd <botlish_fn_16+0x18d>
    25c2:	mov    rsi,r11
    25c5:	mov    r13,r11
    25c8:	jmp    25e3 <botlish_fn_16+0x1a3>
    25cd:	mov    edx,0x3
    25d2:	mov    rsi,r13
    25d5:	mov    rdi,r14
    25d8:	call   25dd <botlish_fn_16+0x19d>
			25d9: R_X86_64_PLT32	rt_int_add-0x4
    25dd:	mov    rsi,rax
    25e0:	mov    r13,rax
    25e3:	mov    QWORD PTR [rsp],rsi
    25e7:	mov    QWORD PTR [rsp+0x8],r12
    25ec:	mov    QWORD PTR [rsp+0x10],rbx
    25f1:	jmp    247f <botlish_fn_16+0x3f>
    25f6:	mov    rax,r13
    25f9:	mov    rbx,QWORD PTR [rsp+0x30]
    25fe:	mov    r12,QWORD PTR [rsp+0x38]
    2603:	mov    r13,QWORD PTR [rsp+0x40]
    2608:	mov    r14,QWORD PTR [rsp+0x48]
    260d:	add    rsp,0x50
    2611:	mov    rsp,rbp
    2614:	pop    rbp
    2615:	ret
    2616:	add    BYTE PTR [rax],al
    2618:	(bad)
    2619:	add    BYTE PTR [rax],al
    261b:	add    BYTE PTR [rax],al
    261d:	add    BYTE PTR [rax],al
	...

0000000000002620 <botlish_entry_16: scan_alpha<generic>>:
    2620:	push   rbp
    2621:	mov    rbp,rsp
    2624:	mov    rsi,QWORD PTR [rdx]
    2627:	mov    r8,QWORD PTR [rdx+0x8]
    262b:	mov    rcx,QWORD PTR [rdx+0x10]
    262f:	mov    rdx,r8
    2632:	call   2637 <botlish_entry_16+0x17>
			2633: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_alpha<generic>
    2637:	mov    rsp,rbp
    263a:	pop    rbp
    263b:	ret
    263c:	add    BYTE PTR [rax],al
	...

0000000000002640 <botlish_fn_17: tld_ok<generic>>:
    2640:	push   rbp
    2641:	mov    rbp,rsp
    2644:	sub    rsp,0x40
    2648:	mov    QWORD PTR [rsp+0x20],rbx
    264d:	mov    QWORD PTR [rsp+0x28],r12
    2652:	mov    QWORD PTR [rsp+0x30],r13
    2657:	mov    QWORD PTR [rsp+0x38],r14
    265c:	mov    rbx,rdi
    265f:	mov    QWORD PTR [rsp],rsi
    2663:	mov    r12,rsi
    2666:	mov    QWORD PTR [rsp+0x8],rdx
    266b:	mov    r14,rdx
    266e:	mov    QWORD PTR [rsp+0x10],rcx
    2673:	mov    rdx,r14
    2676:	mov    rsi,r12
    2679:	mov    rdi,rbx
    267c:	call   2681 <botlish_fn_17+0x41>
			267d: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_alpha<generic>
    2681:	mov    rsi,rax
    2684:	mov    r13,rax
    2687:	test   rax,rsi
    268a:	je     274d <botlish_fn_17+0x10d>
    2690:	mov    rax,r13
    2693:	mov    QWORD PTR [rsp+0x8],rax
    2698:	mov    rdx,r14
    269b:	and    rax,rdx
    269e:	test   rax,0x1
    26a4:	jne    26cd <botlish_fn_17+0x8d>
    26aa:	mov    rsi,r13
    26ad:	mov    rdi,rbx
    26b0:	call   26b5 <botlish_fn_17+0x75>
			26b1: R_X86_64_PLT32	rt_int_cmp-0x4
    26b5:	mov    ecx,0x2
    26ba:	test   rax,rax
    26bd:	cmove  rcx,QWORD PTR [rip+0x15b]        # 2820 <botlish_fn_17+0x1e0>
    26c5:	mov    rax,r13
    26c8:	jmp    26e0 <botlish_fn_17+0xa0>
    26cd:	mov    ecx,0x2
    26d2:	mov    rax,r13
    26d5:	cmp    rax,rdx
    26d8:	cmove  rcx,QWORD PTR [rip+0x140]        # 2820 <botlish_fn_17+0x1e0>
    26e0:	cmp    rcx,0x6
    26e4:	je     26f7 <botlish_fn_17+0xb7>
    26ea:	mov    ecx,0x2
    26ef:	mov    rax,rcx
    26f2:	jmp    27ff <botlish_fn_17+0x1bf>
    26f7:	mov    ecx,0x1
    26fc:	mov    rsi,r12
    26ff:	test   rsi,0x1
    2706:	jne    272c <botlish_fn_17+0xec>
    270c:	xor    ecx,ecx
    270e:	mov    rsi,r12
    2711:	test   rsi,0x7
    2718:	jne    272c <botlish_fn_17+0xec>
    271e:	mov    rsi,r12
    2721:	movzx  rcx,BYTE PTR [rsi]
    2725:	rex cmp cl,0x1
    2729:	sete   cl
    272c:	test   cl,cl
    272e:	jne    276d <botlish_fn_17+0x12d>
    2734:	mov    rdi,rbx
    2737:	mov    rsi,QWORD PTR [rdi+0x10]
    273b:	mov    rcx,QWORD PTR [rsi+0x130]
    2742:	xor    rdx,rdx
    2745:	mov    rsi,r12
    2748:	call   274d <botlish_fn_17+0x10d>
			2749: R_X86_64_PLT32	rt_type_error-0x4
    274d:	xor    rax,rax
    2750:	mov    rbx,QWORD PTR [rsp+0x20]
    2755:	mov    r12,QWORD PTR [rsp+0x28]
    275a:	mov    r13,QWORD PTR [rsp+0x30]
    275f:	mov    r14,QWORD PTR [rsp+0x38]
    2764:	add    rsp,0x40
    2768:	mov    rsp,rbp
    276b:	pop    rbp
    276c:	ret
    276d:	mov    rsi,r12
    2770:	mov    rdi,rax
    2773:	and    rdi,rsi
    2776:	test   rdi,0x1
    277d:	jne    278e <botlish_fn_17+0x14e>
    2783:	mov    rdx,r12
    2786:	mov    rsi,rax
    2789:	jmp    27b1 <botlish_fn_17+0x171>
    278e:	mov    rsi,r12
    2791:	mov    r8,rax
    2794:	sub    r8,rsi
    2797:	mov    r13,rax
    279a:	seto   r10b
    279e:	lea    rsi,[r8+0x1]
    27a2:	test   r10b,r10b
    27a5:	je     27bc <botlish_fn_17+0x17c>
    27ab:	mov    rdx,r12
    27ae:	mov    rsi,r13
    27b1:	mov    rdi,rbx
    27b4:	call   27b9 <botlish_fn_17+0x179>
			27b5: R_X86_64_PLT32	rt_int_sub-0x4
    27b9:	mov    rsi,rax
    27bc:	test   rsi,0x1
    27c3:	jne    27ee <botlish_fn_17+0x1ae>
    27c9:	mov    edx,0x5
    27ce:	mov    rdi,rbx
    27d1:	call   27d6 <botlish_fn_17+0x196>
			27d2: R_X86_64_PLT32	rt_int_cmp-0x4
    27d6:	mov    ecx,0x2
    27db:	test   rax,rax
    27de:	mov    rax,rcx
    27e1:	cmovge rax,QWORD PTR [rip+0x37]        # 2820 <botlish_fn_17+0x1e0>
    27e9:	jmp    27ff <botlish_fn_17+0x1bf>
    27ee:	mov    eax,0x2
    27f3:	cmp    rsi,0x5
    27f7:	cmovge rax,QWORD PTR [rip+0x21]        # 2820 <botlish_fn_17+0x1e0>
    27ff:	mov    rbx,QWORD PTR [rsp+0x20]
    2804:	mov    r12,QWORD PTR [rsp+0x28]
    2809:	mov    r13,QWORD PTR [rsp+0x30]
    280e:	mov    r14,QWORD PTR [rsp+0x38]
    2813:	add    rsp,0x40
    2817:	mov    rsp,rbp
    281a:	pop    rbp
    281b:	ret
    281c:	add    BYTE PTR [rax],al
    281e:	add    BYTE PTR [rax],al
    2820:	(bad)
    2821:	add    BYTE PTR [rax],al
    2823:	add    BYTE PTR [rax],al
    2825:	add    BYTE PTR [rax],al
	...

0000000000002828 <botlish_entry_17: tld_ok<generic>>:
    2828:	push   rbp
    2829:	mov    rbp,rsp
    282c:	mov    rsi,QWORD PTR [rdx]
    282f:	mov    r8,QWORD PTR [rdx+0x8]
    2833:	mov    rcx,QWORD PTR [rdx+0x10]
    2837:	mov    rdx,r8
    283a:	call   283f <botlish_entry_17+0x17>
			283b: R_X86_64_PLT32	botlish_fn_17-0x4 ; tld_ok<generic>
    283f:	mov    rsp,rbp
    2842:	pop    rbp
    2843:	ret
    2844:	add    BYTE PTR [rax],al
	...

0000000000002848 <botlish_fn_18: domain_loop<generic>>:
    2848:	push   rbp
    2849:	mov    rbp,rsp
    284c:	sub    rsp,0x70
    2850:	mov    QWORD PTR [rsp+0x40],rbx
    2855:	mov    QWORD PTR [rsp+0x48],r12
    285a:	mov    QWORD PTR [rsp+0x50],r13
    285f:	mov    QWORD PTR [rsp+0x58],r14
    2864:	mov    QWORD PTR [rsp+0x60],r15
    2869:	mov    QWORD PTR [rsp+0x18],0x0
    2872:	mov    QWORD PTR [rsp],rsi
    2876:	mov    QWORD PTR [rsp+0x8],rdx
    287b:	mov    QWORD PTR [rsp+0x10],rcx
    2880:	lea    rbx,[rsp+0x20]
    2885:	mov    r12,rdi
    2888:	mov    r13,rcx
    288b:	mov    r14,rdx
    288e:	mov    QWORD PTR [rsp+0x30],rsi
    2893:	mov    rcx,r13
    2896:	mov    rdx,r14
    2899:	mov    rsi,QWORD PTR [rsp+0x30]
    289e:	mov    rdi,r12
    28a1:	call   28a6 <botlish_fn_18+0x5e>
			28a2: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_label<generic>
    28a6:	mov    rcx,rax
    28a9:	mov    r15,rax
    28ac:	test   rax,rcx
    28af:	je     29ff <botlish_fn_18+0x1b7>
    28b5:	mov    rax,r15
    28b8:	mov    QWORD PTR [rsp],rax
    28bc:	mov    rdx,QWORD PTR [rsp+0x30]
    28c1:	and    rax,rdx
    28c4:	test   rax,0x1
    28ca:	jne    28e9 <botlish_fn_18+0xa1>
    28d0:	mov    rsi,r15
    28d3:	mov    rdi,r12
    28d6:	call   28db <botlish_fn_18+0x93>
			28d7: R_X86_64_PLT32	rt_value_eq-0x4
    28db:	test   rax,rax
    28de:	je     29ff <botlish_fn_18+0x1b7>
    28e4:	jmp    28f9 <botlish_fn_18+0xb1>
    28e9:	mov    eax,0x2
    28ee:	cmp    r15,rdx
    28f1:	cmove  rax,QWORD PTR [rip+0x187]        # 2a80 <botlish_fn_18+0x238>
    28f9:	cmp    rax,0x6
    28fd:	je     2a55 <botlish_fn_18+0x20d>
    2903:	mov    rax,r15
    2906:	and    rax,r14
    2909:	test   rax,0x1
    290f:	jne    2938 <botlish_fn_18+0xf0>
    2915:	mov    rdx,r14
    2918:	mov    rsi,r15
    291b:	mov    rdi,r12
    291e:	call   2923 <botlish_fn_18+0xdb>
			291f: R_X86_64_PLT32	rt_int_cmp-0x4
    2923:	mov    ecx,0x2
    2928:	test   rax,rax
    292b:	cmovge rcx,QWORD PTR [rip+0x14d]        # 2a80 <botlish_fn_18+0x238>
    2933:	jmp    2948 <botlish_fn_18+0x100>
    2938:	mov    ecx,0x2
    293d:	cmp    r15,r14
    2940:	cmovge rcx,QWORD PTR [rip+0x138]        # 2a80 <botlish_fn_18+0x238>
    2948:	cmp    rcx,0x6
    294c:	je     2a46 <botlish_fn_18+0x1fe>
    2952:	mov    rcx,rbx
    2955:	mov    rdx,r13
    2958:	mov    rsi,r15
    295b:	mov    rdi,r12
    295e:	call   2963 <botlish_fn_18+0x11b>
			295f: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    2963:	test   rax,rax
    2966:	je     29ff <botlish_fn_18+0x1b7>
    296c:	mov    rdx,QWORD PTR [rsp+0x20]
    2971:	mov    rcx,QWORD PTR [rsp+0x28]
    2976:	mov    rsi,QWORD PTR [r12+0x10]
    297b:	mov    r8,QWORD PTR [rsi+0x120]
    2982:	mov    rsi,rax
    2985:	mov    rdi,r12
    2988:	call   298d <botlish_fn_18+0x145>
			2989: R_X86_64_PLT32	rt_str_region_eq-0x4
    298d:	cmp    rax,0x6
    2991:	je     29a3 <botlish_fn_18+0x15b>
    2997:	mov    r14,0xffffffffffffffff
    299e:	jmp    2a4d <botlish_fn_18+0x205>
    29a3:	mov    QWORD PTR [rsp+0x18],0x3
    29ac:	test   r15,0x1
    29b3:	je     29cb <botlish_fn_18+0x183>
    29b9:	mov    rdx,r15
    29bc:	add    rdx,0x2
    29c0:	seto   al
    29c3:	test   al,al
    29c5:	je     29de <botlish_fn_18+0x196>
    29cb:	mov    edx,0x3
    29d0:	mov    rsi,r15
    29d3:	mov    rdi,r12
    29d6:	call   29db <botlish_fn_18+0x193>
			29d7: R_X86_64_PLT32	rt_int_add-0x4
    29db:	mov    rdx,rax
    29de:	mov    QWORD PTR [rsp],rdx
    29e2:	mov    r15,rdx
    29e5:	mov    rcx,r13
    29e8:	mov    rdx,r14
    29eb:	mov    rsi,r15
    29ee:	mov    rdi,r12
    29f1:	call   29f6 <botlish_fn_18+0x1ae>
			29f2: R_X86_64_PLT32	botlish_fn_17-0x4 ; tld_ok<generic>
    29f6:	test   rax,rax
    29f9:	jne    2a24 <botlish_fn_18+0x1dc>
    29ff:	xor    rax,rax
    2a02:	mov    rbx,QWORD PTR [rsp+0x40]
    2a07:	mov    r12,QWORD PTR [rsp+0x48]
    2a0c:	mov    r13,QWORD PTR [rsp+0x50]
    2a11:	mov    r14,QWORD PTR [rsp+0x58]
    2a16:	mov    r15,QWORD PTR [rsp+0x60]
    2a1b:	add    rsp,0x70
    2a1f:	mov    rsp,rbp
    2a22:	pop    rbp
    2a23:	ret
    2a24:	cmp    rax,0x6
    2a28:	je     2a4d <botlish_fn_18+0x205>
    2a2e:	mov    QWORD PTR [rsp],r15
    2a32:	mov    QWORD PTR [rsp+0x8],r14
    2a37:	mov    QWORD PTR [rsp+0x10],r13
    2a3c:	mov    QWORD PTR [rsp+0x30],r15
    2a41:	jmp    2893 <botlish_fn_18+0x4b>
    2a46:	mov    r14,0xffffffffffffffff
    2a4d:	mov    rax,r14
    2a50:	jmp    2a5c <botlish_fn_18+0x214>
    2a55:	mov    rax,0xffffffffffffffff
    2a5c:	mov    rbx,QWORD PTR [rsp+0x40]
    2a61:	mov    r12,QWORD PTR [rsp+0x48]
    2a66:	mov    r13,QWORD PTR [rsp+0x50]
    2a6b:	mov    r14,QWORD PTR [rsp+0x58]
    2a70:	mov    r15,QWORD PTR [rsp+0x60]
    2a75:	add    rsp,0x70
    2a79:	mov    rsp,rbp
    2a7c:	pop    rbp
    2a7d:	ret
    2a7e:	add    BYTE PTR [rax],al
    2a80:	(bad)
    2a81:	add    BYTE PTR [rax],al
    2a83:	add    BYTE PTR [rax],al
    2a85:	add    BYTE PTR [rax],al
	...

0000000000002a88 <botlish_entry_18: domain_loop<generic>>:
    2a88:	push   rbp
    2a89:	mov    rbp,rsp
    2a8c:	mov    rsi,QWORD PTR [rdx]
    2a8f:	mov    r8,QWORD PTR [rdx+0x8]
    2a93:	mov    rcx,QWORD PTR [rdx+0x10]
    2a97:	mov    rdx,r8
    2a9a:	call   2a9f <botlish_entry_18+0x17>
			2a9b: R_X86_64_PLT32	botlish_fn_18-0x4 ; domain_loop<generic>
    2a9f:	mov    rsp,rbp
    2aa2:	pop    rbp
    2aa3:	ret
    2aa4:	add    BYTE PTR [rax],al
	...

0000000000002aa8 <botlish_fn_19: <str>>:
    2aa8:	push   rbp
    2aa9:	mov    rbp,rsp
    2aac:	sub    rsp,0x50
    2ab0:	mov    QWORD PTR [rsp+0x30],rbx
    2ab5:	mov    QWORD PTR [rsp+0x38],r12
    2aba:	mov    QWORD PTR [rsp+0x40],r13
    2abf:	mov    QWORD PTR [rsp+0x48],r14
    2ac4:	mov    r13,rdi
    2ac7:	mov    QWORD PTR [rsp+0x18],0x0
    2ad0:	mov    QWORD PTR [rsp],rsi
    2ad4:	mov    r14,rsi
    2ad7:	mov    rsi,r14
    2ada:	mov    rdi,r13
    2add:	call   2ae2 <botlish_fn_19+0x3a>
			2ade: R_X86_64_PLT32	rt_str_len-0x4
    2ae2:	mov    rbx,rax
    2ae5:	mov    QWORD PTR [rsp+0x8],rax
    2aea:	mov    esi,0x1
    2aef:	mov    QWORD PTR [rsp+0x10],0x1
    2af8:	mov    rcx,r14
    2afb:	mov    rdx,rbx
    2afe:	mov    rdi,r13
    2b01:	call   2b06 <botlish_fn_19+0x5e>
			2b02: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_local<generic>
    2b06:	mov    r12,rax
    2b09:	test   r12,r12
    2b0c:	je     2c69 <botlish_fn_19+0x1c1>
    2b12:	mov    QWORD PTR [rsp+0x10],r12
    2b17:	test   r12,0x1
    2b1e:	jne    2b49 <botlish_fn_19+0xa1>
    2b24:	mov    edx,0x1
    2b29:	mov    rsi,r12
    2b2c:	mov    rdi,r13
    2b2f:	call   2b34 <botlish_fn_19+0x8c>
			2b30: R_X86_64_PLT32	rt_int_cmp-0x4
    2b34:	mov    ecx,0x2
    2b39:	test   rax,rax
    2b3c:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 2d08 <botlish_fn_19+0x260>
    2b44:	jmp    2b5a <botlish_fn_19+0xb2>
    2b49:	mov    ecx,0x2
    2b4e:	cmp    r12,0x1
    2b52:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 2d08 <botlish_fn_19+0x260>
    2b5a:	cmp    rcx,0x6
    2b5e:	je     2ce4 <botlish_fn_19+0x23c>
    2b64:	mov    rcx,r12
    2b67:	and    rcx,rbx
    2b6a:	test   rcx,0x1
    2b71:	jne    2b9a <botlish_fn_19+0xf2>
    2b77:	mov    rdx,rbx
    2b7a:	mov    rsi,r12
    2b7d:	mov    rdi,r13
    2b80:	call   2b85 <botlish_fn_19+0xdd>
			2b81: R_X86_64_PLT32	rt_int_cmp-0x4
    2b85:	mov    ecx,0x2
    2b8a:	test   rax,rax
    2b8d:	cmovge rcx,QWORD PTR [rip+0x173]        # 2d08 <botlish_fn_19+0x260>
    2b95:	jmp    2baa <botlish_fn_19+0x102>
    2b9a:	mov    ecx,0x2
    2b9f:	cmp    r12,rbx
    2ba2:	cmovge rcx,QWORD PTR [rip+0x15e]        # 2d08 <botlish_fn_19+0x260>
    2baa:	cmp    rcx,0x6
    2bae:	je     2cda <botlish_fn_19+0x232>
    2bb4:	lea    rcx,[rsp+0x20]
    2bb9:	mov    rdx,r14
    2bbc:	mov    rsi,r12
    2bbf:	mov    rdi,r13
    2bc2:	call   2bc7 <botlish_fn_19+0x11f>
			2bc3: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    2bc7:	test   rax,rax
    2bca:	mov    rsi,rax
    2bcd:	je     2c69 <botlish_fn_19+0x1c1>
    2bd3:	mov    rdx,QWORD PTR [rsp+0x20]
    2bd8:	mov    rcx,QWORD PTR [rsp+0x28]
    2bdd:	mov    rdi,r13
    2be0:	mov    rax,QWORD PTR [rdi+0x10]
    2be4:	mov    r8,QWORD PTR [rax+0x108]
    2beb:	call   2bf0 <botlish_fn_19+0x148>
			2bec: R_X86_64_PLT32	rt_str_region_eq-0x4
    2bf0:	cmp    rax,0x6
    2bf4:	je     2c07 <botlish_fn_19+0x15f>
    2bfa:	mov    ecx,0x2
    2bff:	mov    rax,rcx
    2c02:	jmp    2ce9 <botlish_fn_19+0x241>
    2c07:	mov    QWORD PTR [rsp+0x18],0x3
    2c10:	test   r12,0x1
    2c17:	jne    2c25 <botlish_fn_19+0x17d>
    2c1d:	mov    rcx,r12
    2c20:	jmp    2c3a <botlish_fn_19+0x192>
    2c25:	mov    rsi,r12
    2c28:	add    rsi,0x2
    2c2c:	mov    rcx,r12
    2c2f:	seto   al
    2c32:	test   al,al
    2c34:	je     2c4d <botlish_fn_19+0x1a5>
    2c3a:	mov    edx,0x3
    2c3f:	mov    rsi,rcx
    2c42:	mov    rdi,r13
    2c45:	call   2c4a <botlish_fn_19+0x1a2>
			2c46: R_X86_64_PLT32	rt_int_add-0x4
    2c4a:	mov    rsi,rax
    2c4d:	mov    QWORD PTR [rsp+0x10],rsi
    2c52:	mov    rcx,r14
    2c55:	mov    rdx,rbx
    2c58:	mov    rdi,r13
    2c5b:	call   2c60 <botlish_fn_19+0x1b8>
			2c5c: R_X86_64_PLT32	botlish_fn_26-0x4 ; domain_loop<generic>
    2c60:	test   rax,rax
    2c63:	jne    2c89 <botlish_fn_19+0x1e1>
    2c69:	xor    rax,rax
    2c6c:	mov    rbx,QWORD PTR [rsp+0x30]
    2c71:	mov    r12,QWORD PTR [rsp+0x38]
    2c76:	mov    r13,QWORD PTR [rsp+0x40]
    2c7b:	mov    r14,QWORD PTR [rsp+0x48]
    2c80:	add    rsp,0x50
    2c84:	mov    rsp,rbp
    2c87:	pop    rbp
    2c88:	ret
    2c89:	mov    rcx,rax
    2c8c:	and    rcx,rbx
    2c8f:	mov    rsi,rax
    2c92:	test   rcx,0x1
    2c99:	jne    2cc2 <botlish_fn_19+0x21a>
    2c9f:	mov    rdx,rbx
    2ca2:	mov    rdi,r13
    2ca5:	call   2caa <botlish_fn_19+0x202>
			2ca6: R_X86_64_PLT32	rt_int_cmp-0x4
    2caa:	mov    ecx,0x2
    2caf:	test   rax,rax
    2cb2:	mov    rax,rcx
    2cb5:	cmove  rax,QWORD PTR [rip+0x4b]        # 2d08 <botlish_fn_19+0x260>
    2cbd:	jmp    2ce9 <botlish_fn_19+0x241>
    2cc2:	mov    rdx,rbx
    2cc5:	mov    eax,0x2
    2cca:	cmp    rsi,rdx
    2ccd:	cmove  rax,QWORD PTR [rip+0x33]        # 2d08 <botlish_fn_19+0x260>
    2cd5:	jmp    2ce9 <botlish_fn_19+0x241>
    2cda:	mov    eax,0x2
    2cdf:	jmp    2ce9 <botlish_fn_19+0x241>
    2ce4:	mov    eax,0x2
    2ce9:	mov    rbx,QWORD PTR [rsp+0x30]
    2cee:	mov    r12,QWORD PTR [rsp+0x38]
    2cf3:	mov    r13,QWORD PTR [rsp+0x40]
    2cf8:	mov    r14,QWORD PTR [rsp+0x48]
    2cfd:	add    rsp,0x50
    2d01:	mov    rsp,rbp
    2d04:	pop    rbp
    2d05:	ret
    2d06:	add    BYTE PTR [rax],al
    2d08:	(bad)
    2d09:	add    BYTE PTR [rax],al
    2d0b:	add    BYTE PTR [rax],al
    2d0d:	add    BYTE PTR [rax],al
	...

0000000000002d10 <botlish_entry_19: <str>>:
    2d10:	push   rbp
    2d11:	mov    rbp,rsp
    2d14:	mov    rsi,QWORD PTR [rdx]
    2d17:	call   2d1c <botlish_entry_19+0xc>
			2d18: R_X86_64_PLT32	botlish_fn_19-0x4 ; <str>
    2d1c:	mov    rsp,rbp
    2d1f:	pop    rbp
    2d20:	ret
    2d21:	add    BYTE PTR [rax],al
    2d23:	add    BYTE PTR [rax],al
    2d25:	add    BYTE PTR [rax],al
	...

0000000000002d28 <botlish_fn_20: <generic>>:
    2d28:	push   rbp
    2d29:	mov    rbp,rsp
    2d2c:	sub    rsp,0x60
    2d30:	mov    QWORD PTR [rsp+0x30],rbx
    2d35:	mov    QWORD PTR [rsp+0x38],r12
    2d3a:	mov    QWORD PTR [rsp+0x40],r13
    2d3f:	mov    QWORD PTR [rsp+0x48],r14
    2d44:	mov    QWORD PTR [rsp+0x50],r15
    2d49:	mov    QWORD PTR [rsp+0x18],0x0
    2d52:	mov    QWORD PTR [rsp],rsi
    2d56:	xor    r8d,r8d
    2d59:	test   rsi,0x7
    2d60:	jne    2d70 <botlish_fn_20+0x48>
    2d66:	movzx  rax,BYTE PTR [rsi]
    2d6a:	cmp    al,0x2
    2d6c:	sete   r8b
    2d70:	test   r8b,r8b
    2d73:	jne    2d93 <botlish_fn_20+0x6b>
    2d79:	mov    rdx,QWORD PTR [rdi+0x10]
    2d7d:	mov    rcx,QWORD PTR [rdx+0xe0]
    2d84:	mov    edx,0x1
    2d89:	call   2d8e <botlish_fn_20+0x66>
			2d8a: R_X86_64_PLT32	rt_type_error-0x4
    2d8e:	jmp    2f28 <botlish_fn_20+0x200>
    2d93:	mov    r13,rsi
    2d96:	mov    r14,rdi
    2d99:	call   2d9e <botlish_fn_20+0x76>
			2d9a: R_X86_64_PLT32	rt_str_len-0x4
    2d9e:	mov    rbx,rax
    2da1:	mov    QWORD PTR [rsp+0x8],rax
    2da6:	mov    edx,0x1
    2dab:	mov    r15,rdx
    2dae:	mov    QWORD PTR [rsp+0x10],0x1
    2db7:	mov    rcx,r13
    2dba:	mov    rdx,rbx
    2dbd:	mov    rsi,r15
    2dc0:	mov    rdi,r14
    2dc3:	call   2dc8 <botlish_fn_20+0xa0>
			2dc4: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_local<generic>
    2dc8:	mov    r12,rax
    2dcb:	test   r12,r12
    2dce:	je     2f28 <botlish_fn_20+0x200>
    2dd4:	mov    QWORD PTR [rsp+0x10],r12
    2dd9:	test   r12,0x1
    2de0:	jne    2e09 <botlish_fn_20+0xe1>
    2de6:	mov    rdx,r15
    2de9:	mov    rsi,r12
    2dec:	mov    rdi,r14
    2def:	call   2df4 <botlish_fn_20+0xcc>
			2df0: R_X86_64_PLT32	rt_int_cmp-0x4
    2df4:	mov    ecx,0x2
    2df9:	test   rax,rax
    2dfc:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 2fd0 <botlish_fn_20+0x2a8>
    2e04:	jmp    2e1a <botlish_fn_20+0xf2>
    2e09:	mov    ecx,0x2
    2e0e:	cmp    r12,0x1
    2e12:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 2fd0 <botlish_fn_20+0x2a8>
    2e1a:	cmp    rcx,0x6
    2e1e:	je     2fa8 <botlish_fn_20+0x280>
    2e24:	mov    rax,r12
    2e27:	and    rax,rbx
    2e2a:	test   rax,0x1
    2e30:	jne    2e59 <botlish_fn_20+0x131>
    2e36:	mov    rdx,rbx
    2e39:	mov    rsi,r12
    2e3c:	mov    rdi,r14
    2e3f:	call   2e44 <botlish_fn_20+0x11c>
			2e40: R_X86_64_PLT32	rt_int_cmp-0x4
    2e44:	mov    ecx,0x2
    2e49:	test   rax,rax
    2e4c:	cmovge rcx,QWORD PTR [rip+0x17c]        # 2fd0 <botlish_fn_20+0x2a8>
    2e54:	jmp    2e69 <botlish_fn_20+0x141>
    2e59:	mov    ecx,0x2
    2e5e:	cmp    r12,rbx
    2e61:	cmovge rcx,QWORD PTR [rip+0x167]        # 2fd0 <botlish_fn_20+0x2a8>
    2e69:	cmp    rcx,0x6
    2e6d:	je     2f9e <botlish_fn_20+0x276>
    2e73:	lea    rcx,[rsp+0x20]
    2e78:	mov    rdx,r13
    2e7b:	mov    rsi,r12
    2e7e:	mov    rdi,r14
    2e81:	call   2e86 <botlish_fn_20+0x15e>
			2e82: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    2e86:	test   rax,rax
    2e89:	mov    rsi,rax
    2e8c:	je     2f28 <botlish_fn_20+0x200>
    2e92:	mov    rdx,QWORD PTR [rsp+0x20]
    2e97:	mov    rcx,QWORD PTR [rsp+0x28]
    2e9c:	mov    rdi,r14
    2e9f:	mov    rax,QWORD PTR [rdi+0x10]
    2ea3:	mov    r8,QWORD PTR [rax+0x108]
    2eaa:	call   2eaf <botlish_fn_20+0x187>
			2eab: R_X86_64_PLT32	rt_str_region_eq-0x4
    2eaf:	cmp    rax,0x6
    2eb3:	je     2ec6 <botlish_fn_20+0x19e>
    2eb9:	mov    ecx,0x2
    2ebe:	mov    rax,rcx
    2ec1:	jmp    2fad <botlish_fn_20+0x285>
    2ec6:	mov    QWORD PTR [rsp+0x18],0x3
    2ecf:	test   r12,0x1
    2ed6:	jne    2ee4 <botlish_fn_20+0x1bc>
    2edc:	mov    rdi,r12
    2edf:	jmp    2ef9 <botlish_fn_20+0x1d1>
    2ee4:	mov    rsi,r12
    2ee7:	add    rsi,0x2
    2eeb:	mov    rdi,r12
    2eee:	seto   al
    2ef1:	test   al,al
    2ef3:	je     2f0c <botlish_fn_20+0x1e4>
    2ef9:	mov    edx,0x3
    2efe:	mov    rsi,rdi
    2f01:	mov    rdi,r14
    2f04:	call   2f09 <botlish_fn_20+0x1e1>
			2f05: R_X86_64_PLT32	rt_int_add-0x4
    2f09:	mov    rsi,rax
    2f0c:	mov    QWORD PTR [rsp+0x10],rsi
    2f11:	mov    rcx,r13
    2f14:	mov    rdx,rbx
    2f17:	mov    rdi,r14
    2f1a:	call   2f1f <botlish_fn_20+0x1f7>
			2f1b: R_X86_64_PLT32	botlish_fn_26-0x4 ; domain_loop<generic>
    2f1f:	test   rax,rax
    2f22:	jne    2f4d <botlish_fn_20+0x225>
    2f28:	xor    rax,rax
    2f2b:	mov    rbx,QWORD PTR [rsp+0x30]
    2f30:	mov    r12,QWORD PTR [rsp+0x38]
    2f35:	mov    r13,QWORD PTR [rsp+0x40]
    2f3a:	mov    r14,QWORD PTR [rsp+0x48]
    2f3f:	mov    r15,QWORD PTR [rsp+0x50]
    2f44:	add    rsp,0x60
    2f48:	mov    rsp,rbp
    2f4b:	pop    rbp
    2f4c:	ret
    2f4d:	mov    rcx,rax
    2f50:	and    rcx,rbx
    2f53:	mov    rsi,rax
    2f56:	test   rcx,0x1
    2f5d:	jne    2f86 <botlish_fn_20+0x25e>
    2f63:	mov    rdx,rbx
    2f66:	mov    rdi,r14
    2f69:	call   2f6e <botlish_fn_20+0x246>
			2f6a: R_X86_64_PLT32	rt_int_cmp-0x4
    2f6e:	mov    ecx,0x2
    2f73:	test   rax,rax
    2f76:	mov    rax,rcx
    2f79:	cmove  rax,QWORD PTR [rip+0x4f]        # 2fd0 <botlish_fn_20+0x2a8>
    2f81:	jmp    2fad <botlish_fn_20+0x285>
    2f86:	mov    rdx,rbx
    2f89:	mov    eax,0x2
    2f8e:	cmp    rsi,rdx
    2f91:	cmove  rax,QWORD PTR [rip+0x37]        # 2fd0 <botlish_fn_20+0x2a8>
    2f99:	jmp    2fad <botlish_fn_20+0x285>
    2f9e:	mov    eax,0x2
    2fa3:	jmp    2fad <botlish_fn_20+0x285>
    2fa8:	mov    eax,0x2
    2fad:	mov    rbx,QWORD PTR [rsp+0x30]
    2fb2:	mov    r12,QWORD PTR [rsp+0x38]
    2fb7:	mov    r13,QWORD PTR [rsp+0x40]
    2fbc:	mov    r14,QWORD PTR [rsp+0x48]
    2fc1:	mov    r15,QWORD PTR [rsp+0x50]
    2fc6:	add    rsp,0x60
    2fca:	mov    rsp,rbp
    2fcd:	pop    rbp
    2fce:	ret
    2fcf:	add    BYTE PTR [rsi],al
    2fd1:	add    BYTE PTR [rax],al
    2fd3:	add    BYTE PTR [rax],al
    2fd5:	add    BYTE PTR [rax],al
	...

0000000000002fd8 <botlish_entry_20: <generic>>:
    2fd8:	push   rbp
    2fd9:	mov    rbp,rsp
    2fdc:	mov    rsi,QWORD PTR [rdx]
    2fdf:	call   2fe4 <botlish_entry_20+0xc>
			2fe0: R_X86_64_PLT32	botlish_fn_20-0x4 ; <generic>
    2fe4:	mov    rsp,rbp
    2fe7:	pop    rbp
    2fe8:	ret

0000000000002fe9 <botlish_fn_21: char_at<generic>>:
    2fe9:	push   rbp
    2fea:	mov    rbp,rsp
    2fed:	sub    rsp,0x50
    2ff1:	mov    QWORD PTR [rsp+0x20],rbx
    2ff6:	mov    QWORD PTR [rsp+0x28],r12
    2ffb:	mov    QWORD PTR [rsp+0x30],r13
    3000:	mov    QWORD PTR [rsp+0x38],r14
    3005:	mov    QWORD PTR [rsp+0x40],r15
    300a:	mov    r14,rcx
    300d:	mov    QWORD PTR [rsp],rsi
    3011:	mov    QWORD PTR [rsp+0x8],rdx
    3016:	mov    r13,rdx
    3019:	mov    QWORD PTR [rsp+0x10],0x3
    3022:	mov    r9d,0x1
    3028:	test   rsi,0x1
    302f:	jne    304f <botlish_fn_21+0x66>
    3035:	xor    r9d,r9d
    3038:	test   rsi,0x7
    303f:	jne    304f <botlish_fn_21+0x66>
    3045:	movzx  rax,BYTE PTR [rsi]
    3049:	cmp    al,0x1
    304b:	sete   r9b
    304f:	test   r9b,r9b
    3052:	jne    3070 <botlish_fn_21+0x87>
    3058:	mov    rax,QWORD PTR [rdi+0x10]
    305c:	mov    rcx,QWORD PTR [rax+0x110]
    3063:	xor    rdx,rdx
    3066:	call   306b <botlish_fn_21+0x82>
			3067: R_X86_64_PLT32	rt_type_error-0x4
    306b:	jmp    312d <botlish_fn_21+0x144>
    3070:	mov    r12,rdi
    3073:	test   rsi,0x1
    307a:	jne    3088 <botlish_fn_21+0x9f>
    3080:	mov    rbx,rsi
    3083:	jmp    30a5 <botlish_fn_21+0xbc>
    3088:	mov    rax,rsi
    308b:	add    rax,0x2
    308f:	mov    rbx,rsi
    3092:	seto   cl
    3095:	test   cl,cl
    3097:	jne    30a5 <botlish_fn_21+0xbc>
    309d:	mov    r15,rax
    30a0:	jmp    30b8 <botlish_fn_21+0xcf>
    30a5:	mov    edx,0x3
    30aa:	mov    rsi,rbx
    30ad:	mov    rdi,r12
    30b0:	call   30b5 <botlish_fn_21+0xcc>
			30b1: R_X86_64_PLT32	rt_int_add-0x4
    30b5:	mov    r15,rax
    30b8:	mov    ecx,0x1
    30bd:	mov    rsi,rbx
    30c0:	test   rsi,0x1
    30c7:	jne    30ed <botlish_fn_21+0x104>
    30cd:	xor    ecx,ecx
    30cf:	mov    rsi,rbx
    30d2:	test   rsi,0x7
    30d9:	jne    30ed <botlish_fn_21+0x104>
    30df:	mov    rsi,rbx
    30e2:	movzx  rcx,BYTE PTR [rsi]
    30e6:	rex cmp cl,0x1
    30ea:	sete   cl
    30ed:	test   cl,cl
    30ef:	jne    3113 <botlish_fn_21+0x12a>
    30f5:	mov    rdi,r12
    30f8:	mov    rsi,QWORD PTR [rdi+0x10]
    30fc:	mov    rcx,QWORD PTR [rsi+0x118]
    3103:	xor    rdx,rdx
    3106:	mov    rsi,rbx
    3109:	call   310e <botlish_fn_21+0x125>
			310a: R_X86_64_PLT32	rt_type_error-0x4
    310e:	jmp    312d <botlish_fn_21+0x144>
    3113:	mov    rdi,r12
    3116:	mov    rcx,r15
    3119:	mov    rdx,rbx
    311c:	mov    rsi,r13
    311f:	call   3124 <botlish_fn_21+0x13b>
			3120: R_X86_64_PLT32	rt_str_region_check-0x4
    3124:	test   rax,rax
    3127:	jne    3152 <botlish_fn_21+0x169>
    312d:	xor    rax,rax
    3130:	mov    rbx,QWORD PTR [rsp+0x20]
    3135:	mov    r12,QWORD PTR [rsp+0x28]
    313a:	mov    r13,QWORD PTR [rsp+0x30]
    313f:	mov    r14,QWORD PTR [rsp+0x38]
    3144:	mov    r15,QWORD PTR [rsp+0x40]
    3149:	add    rsp,0x50
    314d:	mov    rsp,rbp
    3150:	pop    rbp
    3151:	ret
    3152:	mov    rcx,r14
    3155:	mov    rsi,rbx
    3158:	mov    QWORD PTR [rcx],rsi
    315b:	mov    rax,r15
    315e:	mov    QWORD PTR [rcx+0x8],rax
    3162:	mov    rax,r13
    3165:	mov    rbx,QWORD PTR [rsp+0x20]
    316a:	mov    r12,QWORD PTR [rsp+0x28]
    316f:	mov    r13,QWORD PTR [rsp+0x30]
    3174:	mov    r14,QWORD PTR [rsp+0x38]
    3179:	mov    r15,QWORD PTR [rsp+0x40]
    317e:	add    rsp,0x50
    3182:	mov    rsp,rbp
    3185:	pop    rbp
    3186:	ret

0000000000003187 <botlish_entry_21: char_at<generic>>:
    3187:	push   rbp
    3188:	mov    rbp,rsp
    318b:	ud2
    318d:	add    BYTE PTR [rax],al
	...

0000000000003190 <botlish_fn_22: scan_local<generic>>:
    3190:	push   rbp
    3191:	mov    rbp,rsp
    3194:	sub    rsp,0x80
    319b:	mov    QWORD PTR [rsp+0x50],rbx
    31a0:	mov    QWORD PTR [rsp+0x58],r12
    31a5:	mov    QWORD PTR [rsp+0x60],r13
    31aa:	mov    QWORD PTR [rsp+0x68],r14
    31af:	mov    QWORD PTR [rsp+0x70],r15
    31b4:	mov    rax,rdi
    31b7:	mov    QWORD PTR [rsp+0x18],0x0
    31c0:	mov    QWORD PTR [rsp],rsi
    31c4:	mov    r14,rsi
    31c7:	mov    QWORD PTR [rsp+0x8],rdx
    31cc:	mov    QWORD PTR [rsp+0x10],rcx
    31d1:	mov    r12,rcx
    31d4:	mov    r11d,0x1
    31da:	mov    rsi,r14
    31dd:	test   rsi,0x1
    31e4:	jne    3206 <botlish_fn_22+0x76>
    31ea:	xor    r11d,r11d
    31ed:	test   rsi,0x7
    31f4:	jne    3206 <botlish_fn_22+0x76>
    31fa:	movzx  rdi,BYTE PTR [rsi]
    31fe:	cmp    dil,0x1
    3202:	sete   r11b
    3206:	test   r11b,r11b
    3209:	jne    322a <botlish_fn_22+0x9a>
    320f:	mov    rdi,rax
    3212:	mov    r9,QWORD PTR [rdi+0x10]
    3216:	mov    rcx,QWORD PTR [r9+0xc0]
    321d:	xor    rdx,rdx
    3220:	call   3225 <botlish_fn_22+0x95>
			3221: R_X86_64_PLT32	rt_type_error-0x4
    3225:	jmp    32dd <botlish_fn_22+0x14d>
    322a:	mov    r13,rdx
    322d:	mov    r10,rsi
    3230:	and    r10,r13
    3233:	mov    r14,rsi
    3236:	test   r10,0x1
    323d:	jne    3269 <botlish_fn_22+0xd9>
    3243:	mov    rbx,rax
    3246:	mov    rdx,r13
    3249:	mov    rsi,r14
    324c:	mov    rdi,rbx
    324f:	call   3254 <botlish_fn_22+0xc4>
			3250: R_X86_64_PLT32	rt_int_cmp-0x4
    3254:	mov    ecx,0x2
    3259:	test   rax,rax
    325c:	cmovge rcx,QWORD PTR [rip+0x24c]        # 34b0 <botlish_fn_22+0x320>
    3264:	jmp    327f <botlish_fn_22+0xef>
    3269:	mov    rbx,rax
    326c:	mov    ecx,0x2
    3271:	mov    rsi,r14
    3274:	cmp    rsi,r13
    3277:	cmovge rcx,QWORD PTR [rip+0x231]        # 34b0 <botlish_fn_22+0x320>
    327f:	mov    eax,0x6
    3284:	mov    QWORD PTR [rsp+0x30],rax
    3289:	cmp    rcx,0x6
    328d:	je     3483 <botlish_fn_22+0x2f3>
    3293:	lea    rcx,[rsp+0x20]
    3298:	mov    rdx,r12
    329b:	mov    rsi,r14
    329e:	mov    rdi,rbx
    32a1:	call   32a6 <botlish_fn_22+0x116>
			32a2: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    32a6:	mov    rsi,rax
    32a9:	mov    r15,rax
    32ac:	test   rax,rsi
    32af:	je     32dd <botlish_fn_22+0x14d>
    32b5:	mov    rdx,QWORD PTR [rsp+0x20]
    32ba:	mov    QWORD PTR [rsp+0x40],rdx
    32bf:	mov    rcx,QWORD PTR [rsp+0x28]
    32c4:	mov    QWORD PTR [rsp+0x38],rcx
    32c9:	mov    rsi,r15
    32cc:	mov    rdi,rbx
    32cf:	call   32d4 <botlish_fn_22+0x144>
			32d0: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    32d4:	test   rax,rax
    32d7:	jne    3305 <botlish_fn_22+0x175>
    32dd:	xor    rax,rax
    32e0:	mov    rbx,QWORD PTR [rsp+0x50]
    32e5:	mov    r12,QWORD PTR [rsp+0x58]
    32ea:	mov    r13,QWORD PTR [rsp+0x60]
    32ef:	mov    r14,QWORD PTR [rsp+0x68]
    32f4:	mov    r15,QWORD PTR [rsp+0x70]
    32f9:	add    rsp,0x80
    3300:	mov    rsp,rbp
    3303:	pop    rbp
    3304:	ret
    3305:	cmp    rax,0x6
    3309:	je     3404 <botlish_fn_22+0x274>
    330f:	mov    rax,QWORD PTR [rbx+0x10]
    3313:	mov    r8,QWORD PTR [rax+0x120]
    331a:	mov    rcx,QWORD PTR [rsp+0x38]
    331f:	mov    rdx,QWORD PTR [rsp+0x40]
    3324:	mov    rsi,r15
    3327:	mov    rdi,rbx
    332a:	call   332f <botlish_fn_22+0x19f>
			332b: R_X86_64_PLT32	rt_str_region_eq-0x4
    332f:	cmp    rax,0x6
    3333:	je     33fa <botlish_fn_22+0x26a>
    3339:	mov    rax,QWORD PTR [rbx+0x10]
    333d:	mov    r8,QWORD PTR [rax+0x128]
    3344:	mov    rcx,QWORD PTR [rsp+0x38]
    3349:	mov    rdx,QWORD PTR [rsp+0x40]
    334e:	mov    rsi,r15
    3351:	mov    rdi,rbx
    3354:	call   3359 <botlish_fn_22+0x1c9>
			3355: R_X86_64_PLT32	rt_str_region_eq-0x4
    3359:	cmp    rax,0x6
    335d:	je     33f0 <botlish_fn_22+0x260>
    3363:	mov    rax,QWORD PTR [rbx+0x10]
    3367:	mov    r8,QWORD PTR [rax+0xc8]
    336e:	mov    rcx,QWORD PTR [rsp+0x38]
    3373:	mov    rdx,QWORD PTR [rsp+0x40]
    3378:	mov    rsi,r15
    337b:	mov    rdi,rbx
    337e:	call   3383 <botlish_fn_22+0x1f3>
			337f: R_X86_64_PLT32	rt_str_region_eq-0x4
    3383:	cmp    rax,0x6
    3387:	je     33e6 <botlish_fn_22+0x256>
    338d:	mov    rax,QWORD PTR [rbx+0x10]
    3391:	mov    r8,QWORD PTR [rax+0x110]
    3398:	mov    rcx,QWORD PTR [rsp+0x38]
    339d:	mov    rdx,QWORD PTR [rsp+0x40]
    33a2:	mov    rsi,r15
    33a5:	mov    rdi,rbx
    33a8:	call   33ad <botlish_fn_22+0x21d>
			33a9: R_X86_64_PLT32	rt_str_region_eq-0x4
    33ad:	cmp    rax,0x6
    33b1:	je     33dc <botlish_fn_22+0x24c>
    33b7:	mov    rax,QWORD PTR [rbx+0x10]
    33bb:	mov    r8,QWORD PTR [rax+0x130]
    33c2:	mov    rcx,QWORD PTR [rsp+0x38]
    33c7:	mov    rdx,QWORD PTR [rsp+0x40]
    33cc:	mov    rsi,r15
    33cf:	mov    rdi,rbx
    33d2:	call   33d7 <botlish_fn_22+0x247>
			33d3: R_X86_64_PLT32	rt_str_region_eq-0x4
    33d7:	jmp    3409 <botlish_fn_22+0x279>
    33dc:	mov    rax,QWORD PTR [rsp+0x30]
    33e1:	jmp    3409 <botlish_fn_22+0x279>
    33e6:	mov    rax,QWORD PTR [rsp+0x30]
    33eb:	jmp    3409 <botlish_fn_22+0x279>
    33f0:	mov    rax,QWORD PTR [rsp+0x30]
    33f5:	jmp    3409 <botlish_fn_22+0x279>
    33fa:	mov    rax,QWORD PTR [rsp+0x30]
    33ff:	jmp    3409 <botlish_fn_22+0x279>
    3404:	mov    rax,QWORD PTR [rsp+0x30]
    3409:	cmp    rax,0x6
    340d:	je     341b <botlish_fn_22+0x28b>
    3413:	mov    rax,r14
    3416:	jmp    3486 <botlish_fn_22+0x2f6>
    341b:	mov    QWORD PTR [rsp+0x18],0x3
    3424:	mov    rsi,r14
    3427:	test   rsi,0x1
    342e:	je     3454 <botlish_fn_22+0x2c4>
    3434:	mov    rsi,r14
    3437:	mov    rax,rsi
    343a:	add    rax,0x2
    343e:	seto   cl
    3441:	test   cl,cl
    3443:	jne    3454 <botlish_fn_22+0x2c4>
    3449:	mov    rsi,rax
    344c:	mov    r14,rax
    344f:	jmp    346a <botlish_fn_22+0x2da>
    3454:	mov    edx,0x3
    3459:	mov    rsi,r14
    345c:	mov    rdi,rbx
    345f:	call   3464 <botlish_fn_22+0x2d4>
			3460: R_X86_64_PLT32	rt_int_add-0x4
    3464:	mov    rsi,rax
    3467:	mov    r14,rax
    346a:	mov    QWORD PTR [rsp],rsi
    346e:	mov    QWORD PTR [rsp+0x8],r13
    3473:	mov    QWORD PTR [rsp+0x10],r12
    3478:	mov    rax,rbx
    347b:	mov    rdx,r13
    347e:	jmp    31d4 <botlish_fn_22+0x44>
    3483:	mov    rax,r14
    3486:	mov    rbx,QWORD PTR [rsp+0x50]
    348b:	mov    r12,QWORD PTR [rsp+0x58]
    3490:	mov    r13,QWORD PTR [rsp+0x60]
    3495:	mov    r14,QWORD PTR [rsp+0x68]
    349a:	mov    r15,QWORD PTR [rsp+0x70]
    349f:	add    rsp,0x80
    34a6:	mov    rsp,rbp
    34a9:	pop    rbp
    34aa:	ret
    34ab:	add    BYTE PTR [rax],al
    34ad:	add    BYTE PTR [rax],al
    34af:	add    BYTE PTR [rsi],al
    34b1:	add    BYTE PTR [rax],al
    34b3:	add    BYTE PTR [rax],al
    34b5:	add    BYTE PTR [rax],al
	...

00000000000034b8 <botlish_entry_22: scan_local<generic>>:
    34b8:	push   rbp
    34b9:	mov    rbp,rsp
    34bc:	mov    rsi,QWORD PTR [rdx]
    34bf:	mov    r8,QWORD PTR [rdx+0x8]
    34c3:	mov    rcx,QWORD PTR [rdx+0x10]
    34c7:	mov    rdx,r8
    34ca:	call   34cf <botlish_entry_22+0x17>
			34cb: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_local<generic>
    34cf:	mov    rsp,rbp
    34d2:	pop    rbp
    34d3:	ret
    34d4:	add    BYTE PTR [rax],al
	...

00000000000034d8 <botlish_fn_23: scan_label<generic>>:
    34d8:	push   rbp
    34d9:	mov    rbp,rsp
    34dc:	sub    rsp,0x80
    34e3:	mov    QWORD PTR [rsp+0x50],rbx
    34e8:	mov    QWORD PTR [rsp+0x58],r12
    34ed:	mov    QWORD PTR [rsp+0x60],r13
    34f2:	mov    QWORD PTR [rsp+0x68],r14
    34f7:	mov    QWORD PTR [rsp+0x70],r15
    34fc:	mov    QWORD PTR [rsp+0x18],0x0
    3505:	mov    QWORD PTR [rsp],rsi
    3509:	mov    r14,rsi
    350c:	mov    QWORD PTR [rsp+0x8],rdx
    3511:	mov    QWORD PTR [rsp+0x10],rcx
    3516:	mov    r12,rcx
    3519:	mov    r11d,0x1
    351f:	mov    rsi,r14
    3522:	test   rsi,0x1
    3529:	jne    3549 <botlish_fn_23+0x71>
    352f:	xor    r11d,r11d
    3532:	test   rsi,0x7
    3539:	jne    3549 <botlish_fn_23+0x71>
    353f:	movzx  rax,BYTE PTR [rsi]
    3543:	cmp    al,0x1
    3545:	sete   r11b
    3549:	test   r11b,r11b
    354c:	jne    356a <botlish_fn_23+0x92>
    3552:	mov    rax,QWORD PTR [rdi+0x10]
    3556:	mov    rcx,QWORD PTR [rax+0xc0]
    355d:	xor    rdx,rdx
    3560:	call   3565 <botlish_fn_23+0x8d>
			3561: R_X86_64_PLT32	rt_type_error-0x4
    3565:	jmp    3616 <botlish_fn_23+0x13e>
    356a:	mov    r13,rdx
    356d:	mov    rax,rsi
    3570:	and    rax,r13
    3573:	mov    r14,rsi
    3576:	test   rax,0x1
    357c:	jne    35a5 <botlish_fn_23+0xcd>
    3582:	mov    rbx,rdi
    3585:	mov    rdx,r13
    3588:	mov    rsi,r14
    358b:	call   3590 <botlish_fn_23+0xb8>
			358c: R_X86_64_PLT32	rt_int_cmp-0x4
    3590:	mov    ecx,0x2
    3595:	test   rax,rax
    3598:	cmovge rcx,QWORD PTR [rip+0x178]        # 3718 <botlish_fn_23+0x240>
    35a0:	jmp    35bb <botlish_fn_23+0xe3>
    35a5:	mov    rbx,rdi
    35a8:	mov    ecx,0x2
    35ad:	mov    rsi,r14
    35b0:	cmp    rsi,r13
    35b3:	cmovge rcx,QWORD PTR [rip+0x15d]        # 3718 <botlish_fn_23+0x240>
    35bb:	mov    eax,0x6
    35c0:	mov    QWORD PTR [rsp+0x30],rax
    35c5:	cmp    rcx,0x6
    35c9:	je     36ec <botlish_fn_23+0x214>
    35cf:	lea    rcx,[rsp+0x20]
    35d4:	mov    rdx,r12
    35d7:	mov    rsi,r14
    35da:	mov    rdi,rbx
    35dd:	call   35e2 <botlish_fn_23+0x10a>
			35de: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    35e2:	test   rax,rax
    35e5:	mov    r15,rax
    35e8:	je     3616 <botlish_fn_23+0x13e>
    35ee:	mov    rdx,QWORD PTR [rsp+0x20]
    35f3:	mov    QWORD PTR [rsp+0x40],rdx
    35f8:	mov    rcx,QWORD PTR [rsp+0x28]
    35fd:	mov    QWORD PTR [rsp+0x38],rcx
    3602:	mov    rsi,r15
    3605:	mov    rdi,rbx
    3608:	call   360d <botlish_fn_23+0x135>
			3609: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    360d:	test   rax,rax
    3610:	jne    363e <botlish_fn_23+0x166>
    3616:	xor    rax,rax
    3619:	mov    rbx,QWORD PTR [rsp+0x50]
    361e:	mov    r12,QWORD PTR [rsp+0x58]
    3623:	mov    r13,QWORD PTR [rsp+0x60]
    3628:	mov    r14,QWORD PTR [rsp+0x68]
    362d:	mov    r15,QWORD PTR [rsp+0x70]
    3632:	add    rsp,0x80
    3639:	mov    rsp,rbp
    363c:	pop    rbp
    363d:	ret
    363e:	cmp    rax,0x6
    3642:	je     366d <botlish_fn_23+0x195>
    3648:	mov    r11,QWORD PTR [rbx+0x10]
    364c:	mov    r8,QWORD PTR [r11+0x130]
    3653:	mov    rcx,QWORD PTR [rsp+0x38]
    3658:	mov    rdx,QWORD PTR [rsp+0x40]
    365d:	mov    rsi,r15
    3660:	mov    rdi,rbx
    3663:	call   3668 <botlish_fn_23+0x190>
			3664: R_X86_64_PLT32	rt_str_region_eq-0x4
    3668:	jmp    3672 <botlish_fn_23+0x19a>
    366d:	mov    rax,QWORD PTR [rsp+0x30]
    3672:	cmp    rax,0x6
    3676:	je     3684 <botlish_fn_23+0x1ac>
    367c:	mov    rax,r14
    367f:	jmp    36ef <botlish_fn_23+0x217>
    3684:	mov    QWORD PTR [rsp+0x18],0x3
    368d:	mov    rsi,r14
    3690:	test   rsi,0x1
    3697:	je     36bd <botlish_fn_23+0x1e5>
    369d:	mov    rsi,r14
    36a0:	mov    rax,rsi
    36a3:	add    rax,0x2
    36a7:	seto   cl
    36aa:	test   cl,cl
    36ac:	jne    36bd <botlish_fn_23+0x1e5>
    36b2:	mov    rsi,rax
    36b5:	mov    r14,rax
    36b8:	jmp    36d3 <botlish_fn_23+0x1fb>
    36bd:	mov    edx,0x3
    36c2:	mov    rsi,r14
    36c5:	mov    rdi,rbx
    36c8:	call   36cd <botlish_fn_23+0x1f5>
			36c9: R_X86_64_PLT32	rt_int_add-0x4
    36cd:	mov    rsi,rax
    36d0:	mov    r14,rax
    36d3:	mov    QWORD PTR [rsp],rsi
    36d7:	mov    QWORD PTR [rsp+0x8],r13
    36dc:	mov    QWORD PTR [rsp+0x10],r12
    36e1:	mov    rdx,r13
    36e4:	mov    rdi,rbx
    36e7:	jmp    3519 <botlish_fn_23+0x41>
    36ec:	mov    rax,r14
    36ef:	mov    rbx,QWORD PTR [rsp+0x50]
    36f4:	mov    r12,QWORD PTR [rsp+0x58]
    36f9:	mov    r13,QWORD PTR [rsp+0x60]
    36fe:	mov    r14,QWORD PTR [rsp+0x68]
    3703:	mov    r15,QWORD PTR [rsp+0x70]
    3708:	add    rsp,0x80
    370f:	mov    rsp,rbp
    3712:	pop    rbp
    3713:	ret
    3714:	add    BYTE PTR [rax],al
    3716:	add    BYTE PTR [rax],al
    3718:	(bad)
    3719:	add    BYTE PTR [rax],al
    371b:	add    BYTE PTR [rax],al
    371d:	add    BYTE PTR [rax],al
	...

0000000000003720 <botlish_entry_23: scan_label<generic>>:
    3720:	push   rbp
    3721:	mov    rbp,rsp
    3724:	mov    rsi,QWORD PTR [rdx]
    3727:	mov    r8,QWORD PTR [rdx+0x8]
    372b:	mov    rcx,QWORD PTR [rdx+0x10]
    372f:	mov    rdx,r8
    3732:	call   3737 <botlish_entry_23+0x17>
			3733: R_X86_64_PLT32	botlish_fn_23-0x4 ; scan_label<generic>
    3737:	mov    rsp,rbp
    373a:	pop    rbp
    373b:	ret
    373c:	add    BYTE PTR [rax],al
	...

0000000000003740 <botlish_fn_24: scan_alpha<generic>>:
    3740:	push   rbp
    3741:	mov    rbp,rsp
    3744:	sub    rsp,0x50
    3748:	mov    QWORD PTR [rsp+0x30],rbx
    374d:	mov    QWORD PTR [rsp+0x38],r12
    3752:	mov    QWORD PTR [rsp+0x40],r13
    3757:	mov    QWORD PTR [rsp+0x48],r14
    375c:	mov    r14,rdi
    375f:	mov    QWORD PTR [rsp+0x18],0x0
    3768:	mov    QWORD PTR [rsp],rsi
    376c:	mov    r13,rsi
    376f:	mov    QWORD PTR [rsp+0x8],rdx
    3774:	mov    r12,rdx
    3777:	mov    QWORD PTR [rsp+0x10],rcx
    377c:	mov    rbx,rcx
    377f:	mov    r11d,0x1
    3785:	mov    rsi,r13
    3788:	test   rsi,0x1
    378f:	jne    37af <botlish_fn_24+0x6f>
    3795:	xor    r11d,r11d
    3798:	test   rsi,0x7
    379f:	jne    37af <botlish_fn_24+0x6f>
    37a5:	movzx  rax,BYTE PTR [rsi]
    37a9:	cmp    al,0x1
    37ab:	sete   r11b
    37af:	test   r11b,r11b
    37b2:	jne    37d3 <botlish_fn_24+0x93>
    37b8:	mov    rdi,r14
    37bb:	mov    rax,QWORD PTR [rdi+0x10]
    37bf:	mov    rcx,QWORD PTR [rax+0xc0]
    37c6:	xor    rdx,rdx
    37c9:	call   37ce <botlish_fn_24+0x8e>
			37ca: R_X86_64_PLT32	rt_type_error-0x4
    37ce:	jmp    3862 <botlish_fn_24+0x122>
    37d3:	mov    rax,rsi
    37d6:	and    rax,r12
    37d9:	mov    r13,rsi
    37dc:	test   rax,0x1
    37e2:	jne    380b <botlish_fn_24+0xcb>
    37e8:	mov    rdx,r12
    37eb:	mov    rsi,r13
    37ee:	mov    rdi,r14
    37f1:	call   37f6 <botlish_fn_24+0xb6>
			37f2: R_X86_64_PLT32	rt_int_cmp-0x4
    37f6:	mov    ecx,0x2
    37fb:	test   rax,rax
    37fe:	cmovge rcx,QWORD PTR [rip+0x112]        # 3918 <botlish_fn_24+0x1d8>
    3806:	jmp    381e <botlish_fn_24+0xde>
    380b:	mov    ecx,0x2
    3810:	mov    rsi,r13
    3813:	cmp    rsi,r12
    3816:	cmovge rcx,QWORD PTR [rip+0xfa]        # 3918 <botlish_fn_24+0x1d8>
    381e:	cmp    rcx,0x6
    3822:	je     38f6 <botlish_fn_24+0x1b6>
    3828:	lea    rcx,[rsp+0x20]
    382d:	mov    rdx,rbx
    3830:	mov    rsi,r13
    3833:	mov    rdi,r14
    3836:	call   383b <botlish_fn_24+0xfb>
			3837: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    383b:	test   rax,rax
    383e:	mov    rsi,rax
    3841:	je     3862 <botlish_fn_24+0x122>
    3847:	mov    rdx,QWORD PTR [rsp+0x20]
    384c:	mov    rcx,QWORD PTR [rsp+0x28]
    3851:	mov    rdi,r14
    3854:	call   3859 <botlish_fn_24+0x119>
			3855: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    3859:	test   rax,rax
    385c:	jne    3882 <botlish_fn_24+0x142>
    3862:	xor    rax,rax
    3865:	mov    rbx,QWORD PTR [rsp+0x30]
    386a:	mov    r12,QWORD PTR [rsp+0x38]
    386f:	mov    r13,QWORD PTR [rsp+0x40]
    3874:	mov    r14,QWORD PTR [rsp+0x48]
    3879:	add    rsp,0x50
    387d:	mov    rsp,rbp
    3880:	pop    rbp
    3881:	ret
    3882:	cmp    rax,0x6
    3886:	je     3894 <botlish_fn_24+0x154>
    388c:	mov    rax,r13
    388f:	jmp    38f9 <botlish_fn_24+0x1b9>
    3894:	mov    QWORD PTR [rsp+0x18],0x3
    389d:	mov    rsi,r13
    38a0:	test   rsi,0x1
    38a7:	je     38cd <botlish_fn_24+0x18d>
    38ad:	mov    rsi,r13
    38b0:	mov    r11,rsi
    38b3:	add    r11,0x2
    38b7:	seto   al
    38ba:	test   al,al
    38bc:	jne    38cd <botlish_fn_24+0x18d>
    38c2:	mov    rsi,r11
    38c5:	mov    r13,r11
    38c8:	jmp    38e3 <botlish_fn_24+0x1a3>
    38cd:	mov    edx,0x3
    38d2:	mov    rsi,r13
    38d5:	mov    rdi,r14
    38d8:	call   38dd <botlish_fn_24+0x19d>
			38d9: R_X86_64_PLT32	rt_int_add-0x4
    38dd:	mov    rsi,rax
    38e0:	mov    r13,rax
    38e3:	mov    QWORD PTR [rsp],rsi
    38e7:	mov    QWORD PTR [rsp+0x8],r12
    38ec:	mov    QWORD PTR [rsp+0x10],rbx
    38f1:	jmp    377f <botlish_fn_24+0x3f>
    38f6:	mov    rax,r13
    38f9:	mov    rbx,QWORD PTR [rsp+0x30]
    38fe:	mov    r12,QWORD PTR [rsp+0x38]
    3903:	mov    r13,QWORD PTR [rsp+0x40]
    3908:	mov    r14,QWORD PTR [rsp+0x48]
    390d:	add    rsp,0x50
    3911:	mov    rsp,rbp
    3914:	pop    rbp
    3915:	ret
    3916:	add    BYTE PTR [rax],al
    3918:	(bad)
    3919:	add    BYTE PTR [rax],al
    391b:	add    BYTE PTR [rax],al
    391d:	add    BYTE PTR [rax],al
	...

0000000000003920 <botlish_entry_24: scan_alpha<generic>>:
    3920:	push   rbp
    3921:	mov    rbp,rsp
    3924:	mov    rsi,QWORD PTR [rdx]
    3927:	mov    r8,QWORD PTR [rdx+0x8]
    392b:	mov    rcx,QWORD PTR [rdx+0x10]
    392f:	mov    rdx,r8
    3932:	call   3937 <botlish_entry_24+0x17>
			3933: R_X86_64_PLT32	botlish_fn_24-0x4 ; scan_alpha<generic>
    3937:	mov    rsp,rbp
    393a:	pop    rbp
    393b:	ret
    393c:	add    BYTE PTR [rax],al
	...

0000000000003940 <botlish_fn_25: tld_ok<generic>>:
    3940:	push   rbp
    3941:	mov    rbp,rsp
    3944:	sub    rsp,0x40
    3948:	mov    QWORD PTR [rsp+0x20],rbx
    394d:	mov    QWORD PTR [rsp+0x28],r12
    3952:	mov    QWORD PTR [rsp+0x30],r13
    3957:	mov    QWORD PTR [rsp+0x38],r14
    395c:	mov    rbx,rdi
    395f:	mov    QWORD PTR [rsp],rsi
    3963:	mov    r12,rsi
    3966:	mov    QWORD PTR [rsp+0x8],rdx
    396b:	mov    r14,rdx
    396e:	mov    QWORD PTR [rsp+0x10],rcx
    3973:	mov    rdx,r14
    3976:	mov    rsi,r12
    3979:	mov    rdi,rbx
    397c:	call   3981 <botlish_fn_25+0x41>
			397d: R_X86_64_PLT32	botlish_fn_24-0x4 ; scan_alpha<generic>
    3981:	mov    rsi,rax
    3984:	mov    r13,rax
    3987:	test   rax,rsi
    398a:	je     3a4d <botlish_fn_25+0x10d>
    3990:	mov    rax,r13
    3993:	mov    QWORD PTR [rsp+0x8],rax
    3998:	mov    rdx,r14
    399b:	and    rax,rdx
    399e:	test   rax,0x1
    39a4:	jne    39cd <botlish_fn_25+0x8d>
    39aa:	mov    rsi,r13
    39ad:	mov    rdi,rbx
    39b0:	call   39b5 <botlish_fn_25+0x75>
			39b1: R_X86_64_PLT32	rt_int_cmp-0x4
    39b5:	mov    ecx,0x2
    39ba:	test   rax,rax
    39bd:	cmove  rcx,QWORD PTR [rip+0x15b]        # 3b20 <botlish_fn_25+0x1e0>
    39c5:	mov    rax,r13
    39c8:	jmp    39e0 <botlish_fn_25+0xa0>
    39cd:	mov    ecx,0x2
    39d2:	mov    rax,r13
    39d5:	cmp    rax,rdx
    39d8:	cmove  rcx,QWORD PTR [rip+0x140]        # 3b20 <botlish_fn_25+0x1e0>
    39e0:	cmp    rcx,0x6
    39e4:	je     39f7 <botlish_fn_25+0xb7>
    39ea:	mov    ecx,0x2
    39ef:	mov    rax,rcx
    39f2:	jmp    3aff <botlish_fn_25+0x1bf>
    39f7:	mov    ecx,0x1
    39fc:	mov    rsi,r12
    39ff:	test   rsi,0x1
    3a06:	jne    3a2c <botlish_fn_25+0xec>
    3a0c:	xor    ecx,ecx
    3a0e:	mov    rsi,r12
    3a11:	test   rsi,0x7
    3a18:	jne    3a2c <botlish_fn_25+0xec>
    3a1e:	mov    rsi,r12
    3a21:	movzx  rcx,BYTE PTR [rsi]
    3a25:	rex cmp cl,0x1
    3a29:	sete   cl
    3a2c:	test   cl,cl
    3a2e:	jne    3a6d <botlish_fn_25+0x12d>
    3a34:	mov    rdi,rbx
    3a37:	mov    rsi,QWORD PTR [rdi+0x10]
    3a3b:	mov    rcx,QWORD PTR [rsi+0x130]
    3a42:	xor    rdx,rdx
    3a45:	mov    rsi,r12
    3a48:	call   3a4d <botlish_fn_25+0x10d>
			3a49: R_X86_64_PLT32	rt_type_error-0x4
    3a4d:	xor    rax,rax
    3a50:	mov    rbx,QWORD PTR [rsp+0x20]
    3a55:	mov    r12,QWORD PTR [rsp+0x28]
    3a5a:	mov    r13,QWORD PTR [rsp+0x30]
    3a5f:	mov    r14,QWORD PTR [rsp+0x38]
    3a64:	add    rsp,0x40
    3a68:	mov    rsp,rbp
    3a6b:	pop    rbp
    3a6c:	ret
    3a6d:	mov    rsi,r12
    3a70:	mov    rdi,rax
    3a73:	and    rdi,rsi
    3a76:	test   rdi,0x1
    3a7d:	jne    3a8e <botlish_fn_25+0x14e>
    3a83:	mov    rdx,r12
    3a86:	mov    rsi,rax
    3a89:	jmp    3ab1 <botlish_fn_25+0x171>
    3a8e:	mov    rsi,r12
    3a91:	mov    r8,rax
    3a94:	sub    r8,rsi
    3a97:	mov    r13,rax
    3a9a:	seto   r10b
    3a9e:	lea    rsi,[r8+0x1]
    3aa2:	test   r10b,r10b
    3aa5:	je     3abc <botlish_fn_25+0x17c>
    3aab:	mov    rdx,r12
    3aae:	mov    rsi,r13
    3ab1:	mov    rdi,rbx
    3ab4:	call   3ab9 <botlish_fn_25+0x179>
			3ab5: R_X86_64_PLT32	rt_int_sub-0x4
    3ab9:	mov    rsi,rax
    3abc:	test   rsi,0x1
    3ac3:	jne    3aee <botlish_fn_25+0x1ae>
    3ac9:	mov    edx,0x5
    3ace:	mov    rdi,rbx
    3ad1:	call   3ad6 <botlish_fn_25+0x196>
			3ad2: R_X86_64_PLT32	rt_int_cmp-0x4
    3ad6:	mov    ecx,0x2
    3adb:	test   rax,rax
    3ade:	mov    rax,rcx
    3ae1:	cmovge rax,QWORD PTR [rip+0x37]        # 3b20 <botlish_fn_25+0x1e0>
    3ae9:	jmp    3aff <botlish_fn_25+0x1bf>
    3aee:	mov    eax,0x2
    3af3:	cmp    rsi,0x5
    3af7:	cmovge rax,QWORD PTR [rip+0x21]        # 3b20 <botlish_fn_25+0x1e0>
    3aff:	mov    rbx,QWORD PTR [rsp+0x20]
    3b04:	mov    r12,QWORD PTR [rsp+0x28]
    3b09:	mov    r13,QWORD PTR [rsp+0x30]
    3b0e:	mov    r14,QWORD PTR [rsp+0x38]
    3b13:	add    rsp,0x40
    3b17:	mov    rsp,rbp
    3b1a:	pop    rbp
    3b1b:	ret
    3b1c:	add    BYTE PTR [rax],al
    3b1e:	add    BYTE PTR [rax],al
    3b20:	(bad)
    3b21:	add    BYTE PTR [rax],al
    3b23:	add    BYTE PTR [rax],al
    3b25:	add    BYTE PTR [rax],al
	...

0000000000003b28 <botlish_entry_25: tld_ok<generic>>:
    3b28:	push   rbp
    3b29:	mov    rbp,rsp
    3b2c:	mov    rsi,QWORD PTR [rdx]
    3b2f:	mov    r8,QWORD PTR [rdx+0x8]
    3b33:	mov    rcx,QWORD PTR [rdx+0x10]
    3b37:	mov    rdx,r8
    3b3a:	call   3b3f <botlish_entry_25+0x17>
			3b3b: R_X86_64_PLT32	botlish_fn_25-0x4 ; tld_ok<generic>
    3b3f:	mov    rsp,rbp
    3b42:	pop    rbp
    3b43:	ret
    3b44:	add    BYTE PTR [rax],al
	...

0000000000003b48 <botlish_fn_26: domain_loop<generic>>:
    3b48:	push   rbp
    3b49:	mov    rbp,rsp
    3b4c:	sub    rsp,0x70
    3b50:	mov    QWORD PTR [rsp+0x40],rbx
    3b55:	mov    QWORD PTR [rsp+0x48],r12
    3b5a:	mov    QWORD PTR [rsp+0x50],r13
    3b5f:	mov    QWORD PTR [rsp+0x58],r14
    3b64:	mov    QWORD PTR [rsp+0x60],r15
    3b69:	mov    QWORD PTR [rsp+0x18],0x0
    3b72:	mov    QWORD PTR [rsp],rsi
    3b76:	mov    QWORD PTR [rsp+0x8],rdx
    3b7b:	mov    QWORD PTR [rsp+0x10],rcx
    3b80:	lea    rbx,[rsp+0x20]
    3b85:	mov    r12,rdi
    3b88:	mov    r13,rcx
    3b8b:	mov    r14,rdx
    3b8e:	mov    QWORD PTR [rsp+0x30],rsi
    3b93:	mov    rcx,r13
    3b96:	mov    rdx,r14
    3b99:	mov    rsi,QWORD PTR [rsp+0x30]
    3b9e:	mov    rdi,r12
    3ba1:	call   3ba6 <botlish_fn_26+0x5e>
			3ba2: R_X86_64_PLT32	botlish_fn_23-0x4 ; scan_label<generic>
    3ba6:	mov    rcx,rax
    3ba9:	mov    r15,rax
    3bac:	test   rax,rcx
    3baf:	je     3cff <botlish_fn_26+0x1b7>
    3bb5:	mov    rax,r15
    3bb8:	mov    QWORD PTR [rsp],rax
    3bbc:	mov    rdx,QWORD PTR [rsp+0x30]
    3bc1:	and    rax,rdx
    3bc4:	test   rax,0x1
    3bca:	jne    3be9 <botlish_fn_26+0xa1>
    3bd0:	mov    rsi,r15
    3bd3:	mov    rdi,r12
    3bd6:	call   3bdb <botlish_fn_26+0x93>
			3bd7: R_X86_64_PLT32	rt_value_eq-0x4
    3bdb:	test   rax,rax
    3bde:	je     3cff <botlish_fn_26+0x1b7>
    3be4:	jmp    3bf9 <botlish_fn_26+0xb1>
    3be9:	mov    eax,0x2
    3bee:	cmp    r15,rdx
    3bf1:	cmove  rax,QWORD PTR [rip+0x187]        # 3d80 <botlish_fn_26+0x238>
    3bf9:	cmp    rax,0x6
    3bfd:	je     3d55 <botlish_fn_26+0x20d>
    3c03:	mov    rax,r15
    3c06:	and    rax,r14
    3c09:	test   rax,0x1
    3c0f:	jne    3c38 <botlish_fn_26+0xf0>
    3c15:	mov    rdx,r14
    3c18:	mov    rsi,r15
    3c1b:	mov    rdi,r12
    3c1e:	call   3c23 <botlish_fn_26+0xdb>
			3c1f: R_X86_64_PLT32	rt_int_cmp-0x4
    3c23:	mov    ecx,0x2
    3c28:	test   rax,rax
    3c2b:	cmovge rcx,QWORD PTR [rip+0x14d]        # 3d80 <botlish_fn_26+0x238>
    3c33:	jmp    3c48 <botlish_fn_26+0x100>
    3c38:	mov    ecx,0x2
    3c3d:	cmp    r15,r14
    3c40:	cmovge rcx,QWORD PTR [rip+0x138]        # 3d80 <botlish_fn_26+0x238>
    3c48:	cmp    rcx,0x6
    3c4c:	je     3d46 <botlish_fn_26+0x1fe>
    3c52:	mov    rcx,rbx
    3c55:	mov    rdx,r13
    3c58:	mov    rsi,r15
    3c5b:	mov    rdi,r12
    3c5e:	call   3c63 <botlish_fn_26+0x11b>
			3c5f: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    3c63:	test   rax,rax
    3c66:	je     3cff <botlish_fn_26+0x1b7>
    3c6c:	mov    rdx,QWORD PTR [rsp+0x20]
    3c71:	mov    rcx,QWORD PTR [rsp+0x28]
    3c76:	mov    rsi,QWORD PTR [r12+0x10]
    3c7b:	mov    r8,QWORD PTR [rsi+0x120]
    3c82:	mov    rsi,rax
    3c85:	mov    rdi,r12
    3c88:	call   3c8d <botlish_fn_26+0x145>
			3c89: R_X86_64_PLT32	rt_str_region_eq-0x4
    3c8d:	cmp    rax,0x6
    3c91:	je     3ca3 <botlish_fn_26+0x15b>
    3c97:	mov    r14,0xffffffffffffffff
    3c9e:	jmp    3d4d <botlish_fn_26+0x205>
    3ca3:	mov    QWORD PTR [rsp+0x18],0x3
    3cac:	test   r15,0x1
    3cb3:	je     3ccb <botlish_fn_26+0x183>
    3cb9:	mov    rdx,r15
    3cbc:	add    rdx,0x2
    3cc0:	seto   al
    3cc3:	test   al,al
    3cc5:	je     3cde <botlish_fn_26+0x196>
    3ccb:	mov    edx,0x3
    3cd0:	mov    rsi,r15
    3cd3:	mov    rdi,r12
    3cd6:	call   3cdb <botlish_fn_26+0x193>
			3cd7: R_X86_64_PLT32	rt_int_add-0x4
    3cdb:	mov    rdx,rax
    3cde:	mov    QWORD PTR [rsp],rdx
    3ce2:	mov    r15,rdx
    3ce5:	mov    rcx,r13
    3ce8:	mov    rdx,r14
    3ceb:	mov    rsi,r15
    3cee:	mov    rdi,r12
    3cf1:	call   3cf6 <botlish_fn_26+0x1ae>
			3cf2: R_X86_64_PLT32	botlish_fn_25-0x4 ; tld_ok<generic>
    3cf6:	test   rax,rax
    3cf9:	jne    3d24 <botlish_fn_26+0x1dc>
    3cff:	xor    rax,rax
    3d02:	mov    rbx,QWORD PTR [rsp+0x40]
    3d07:	mov    r12,QWORD PTR [rsp+0x48]
    3d0c:	mov    r13,QWORD PTR [rsp+0x50]
    3d11:	mov    r14,QWORD PTR [rsp+0x58]
    3d16:	mov    r15,QWORD PTR [rsp+0x60]
    3d1b:	add    rsp,0x70
    3d1f:	mov    rsp,rbp
    3d22:	pop    rbp
    3d23:	ret
    3d24:	cmp    rax,0x6
    3d28:	je     3d4d <botlish_fn_26+0x205>
    3d2e:	mov    QWORD PTR [rsp],r15
    3d32:	mov    QWORD PTR [rsp+0x8],r14
    3d37:	mov    QWORD PTR [rsp+0x10],r13
    3d3c:	mov    QWORD PTR [rsp+0x30],r15
    3d41:	jmp    3b93 <botlish_fn_26+0x4b>
    3d46:	mov    r14,0xffffffffffffffff
    3d4d:	mov    rax,r14
    3d50:	jmp    3d5c <botlish_fn_26+0x214>
    3d55:	mov    rax,0xffffffffffffffff
    3d5c:	mov    rbx,QWORD PTR [rsp+0x40]
    3d61:	mov    r12,QWORD PTR [rsp+0x48]
    3d66:	mov    r13,QWORD PTR [rsp+0x50]
    3d6b:	mov    r14,QWORD PTR [rsp+0x58]
    3d70:	mov    r15,QWORD PTR [rsp+0x60]
    3d75:	add    rsp,0x70
    3d79:	mov    rsp,rbp
    3d7c:	pop    rbp
    3d7d:	ret
    3d7e:	add    BYTE PTR [rax],al
    3d80:	(bad)
    3d81:	add    BYTE PTR [rax],al
    3d83:	add    BYTE PTR [rax],al
    3d85:	add    BYTE PTR [rax],al
	...

0000000000003d88 <botlish_entry_26: domain_loop<generic>>:
    3d88:	push   rbp
    3d89:	mov    rbp,rsp
    3d8c:	mov    rsi,QWORD PTR [rdx]
    3d8f:	mov    r8,QWORD PTR [rdx+0x8]
    3d93:	mov    rcx,QWORD PTR [rdx+0x10]
    3d97:	mov    rdx,r8
    3d9a:	call   3d9f <botlish_entry_26+0x17>
			3d9b: R_X86_64_PLT32	botlish_fn_26-0x4 ; domain_loop<generic>
    3d9f:	mov    rsp,rbp
    3da2:	pop    rbp
    3da3:	ret

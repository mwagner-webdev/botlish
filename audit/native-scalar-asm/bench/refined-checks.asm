; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 16655  (per function: 937 203 271 112 109 1425 484 864 506 952 504 681 769 450 884 644 540 540 636 681 769 450 884 644 540 540 636)
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
     462:	mov    QWORD PTR [rsp+0x30],r15
     467:	mov    r15,rdi
     46a:	mov    QWORD PTR [rsp+0x10],0x0
     473:	mov    QWORD PTR [rsp],rsi
     477:	mov    QWORD PTR [rsp+0x8],0x1f
     480:	test   rsi,0x1
     487:	jne    4a5 <botlish_fn_2+0x55>
     48d:	mov    edx,0x1f
     492:	mov    rbx,rsi
     495:	mov    rdi,r15
     498:	call   49d <botlish_fn_2+0x4d>
			499: R_X86_64_PLT32	rt_int_and-0x4
     49d:	mov    rsi,rax
     4a0:	jmp    4ac <botlish_fn_2+0x5c>
     4a5:	mov    rbx,rsi
     4a8:	and    rsi,0x1f
     4ac:	mov    QWORD PTR [rsp+0x8],rsi
     4b1:	mov    r12,rsi
     4b4:	mov    edx,0x9
     4b9:	mov    QWORD PTR [rsp+0x10],0x9
     4c2:	mov    rsi,rbx
     4c5:	mov    rdi,r15
     4c8:	call   4cd <botlish_fn_2+0x7d>
			4c9: R_X86_64_PLT32	rt_int_shr-0x4
     4cd:	test   rax,rax
     4d0:	jne    4f1 <botlish_fn_2+0xa1>
     4d6:	xor    rax,rax
     4d9:	mov    rbx,QWORD PTR [rsp+0x20]
     4de:	mov    r12,QWORD PTR [rsp+0x28]
     4e3:	mov    r15,QWORD PTR [rsp+0x30]
     4e8:	add    rsp,0x40
     4ec:	mov    rsp,rbp
     4ef:	pop    rbp
     4f0:	ret
     4f1:	mov    QWORD PTR [rsp],rax
     4f5:	mov    rsi,r12
     4f8:	mov    rcx,rsi
     4fb:	and    rcx,rax
     4fe:	mov    rdx,rax
     501:	test   rcx,0x1
     508:	jne    51b <botlish_fn_2+0xcb>
     50e:	mov    rdi,r15
     511:	call   516 <botlish_fn_2+0xc6>
			512: R_X86_64_PLT32	rt_int_or-0x4
     516:	jmp    521 <botlish_fn_2+0xd1>
     51b:	or     rsi,rdx
     51e:	mov    rax,rsi
     521:	mov    rbx,QWORD PTR [rsp+0x20]
     526:	mov    r12,QWORD PTR [rsp+0x28]
     52b:	mov    r15,QWORD PTR [rsp+0x30]
     530:	add    rsp,0x40
     534:	mov    rsp,rbp
     537:	pop    rbp
     538:	ret

0000000000000539 <botlish_entry_2: byte::nibble<int>>:
     539:	push   rbp
     53a:	mov    rbp,rsp
     53d:	mov    rsi,QWORD PTR [rdx]
     540:	call   545 <botlish_entry_2+0xc>
			541: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::nibble<int>
     545:	mov    rsp,rbp
     548:	pop    rbp
     549:	ret

000000000000054a <botlish_fn_3: web::uri_escape_text<generic>>:
     54a:	push   rbp
     54b:	mov    rbp,rsp
     54e:	sub    rsp,0x20
     552:	mov    QWORD PTR [rsp],rdx
     556:	mov    r9,rdx
     559:	mov    edx,0x1
     55e:	mov    QWORD PTR [rsp+0x8],0x1
     567:	mov    rax,QWORD PTR [rdi+0x10]
     56b:	mov    rcx,QWORD PTR [rax+0xa0]
     572:	mov    QWORD PTR [rsp+0x10],rcx
     577:	mov    rax,QWORD PTR [rsi+0x20]
     57b:	mov    r8,QWORD PTR [rax]
     57e:	mov    QWORD PTR [rsp+0x18],r8
     583:	mov    rsi,r9
     586:	call   58b <botlish_fn_3+0x41>
			587: R_X86_64_PLT32	botlish_fn_9-0x4 ; esc_from<generic>
     58b:	test   rax,rax
     58e:	jne    5a0 <botlish_fn_3+0x56>
     594:	xor    rax,rax
     597:	add    rsp,0x20
     59b:	mov    rsp,rbp
     59e:	pop    rbp
     59f:	ret
     5a0:	add    rsp,0x20
     5a4:	mov    rsp,rbp
     5a7:	pop    rbp
     5a8:	ret

00000000000005a9 <botlish_entry_3: web::uri_escape_text<generic>>:
     5a9:	push   rbp
     5aa:	mov    rbp,rsp
     5ad:	mov    rdx,QWORD PTR [rdx]
     5b0:	call   5b5 <botlish_entry_3+0xc>
			5b1: R_X86_64_PLT32	botlish_fn_3-0x4 ; web::uri_escape_text<generic>
     5b5:	mov    rsp,rbp
     5b8:	pop    rbp
     5b9:	ret

00000000000005ba <botlish_fn_4: high_nibble<generic>>:
     5ba:	push   rbp
     5bb:	mov    rbp,rsp
     5be:	sub    rsp,0x20
     5c2:	mov    QWORD PTR [rsp+0x10],r12
     5c7:	mov    r12,rdi
     5ca:	mov    QWORD PTR [rsp],rsi
     5ce:	mov    rdi,r12
     5d1:	call   5d6 <botlish_fn_4+0x1c>
			5d2: R_X86_64_PLT32	botlish_fn_1-0x4 ; byte::high_nibble<generic>
     5d6:	test   rax,rax
     5d9:	je     5f7 <botlish_fn_4+0x3d>
     5df:	mov    QWORD PTR [rsp],rax
     5e3:	mov    rsi,rax
     5e6:	mov    rdi,r12
     5e9:	call   5ee <botlish_fn_4+0x34>
			5ea: R_X86_64_PLT32	botlish_fn_2-0x4 ; byte::nibble<int>
     5ee:	test   rax,rax
     5f1:	jne    608 <botlish_fn_4+0x4e>
     5f7:	xor    rax,rax
     5fa:	mov    r12,QWORD PTR [rsp+0x10]
     5ff:	add    rsp,0x20
     603:	mov    rsp,rbp
     606:	pop    rbp
     607:	ret
     608:	mov    r12,QWORD PTR [rsp+0x10]
     60d:	add    rsp,0x20
     611:	mov    rsp,rbp
     614:	pop    rbp
     615:	ret

0000000000000616 <botlish_entry_4: high_nibble<generic>>:
     616:	push   rbp
     617:	mov    rbp,rsp
     61a:	mov    rsi,QWORD PTR [rdx]
     61d:	call   622 <botlish_entry_4+0xc>
			61e: R_X86_64_PLT32	botlish_fn_4-0x4 ; high_nibble<generic>
     622:	mov    rsp,rbp
     625:	pop    rbp
     626:	ret
	...

0000000000000628 <botlish_fn_5: is_unreserved<generic>>:
     628:	push   rbp
     629:	mov    rbp,rsp
     62c:	sub    rsp,0x20
     630:	mov    QWORD PTR [rsp],rbx
     634:	mov    QWORD PTR [rsp+0x8],r12
     639:	mov    QWORD PTR [rsp+0x10],r13
     63e:	mov    r8d,0x1
     644:	test   rsi,0x1
     64b:	jne    66b <botlish_fn_5+0x43>
     651:	xor    r8d,r8d
     654:	test   rsi,0x7
     65b:	jne    66b <botlish_fn_5+0x43>
     661:	movzx  rax,BYTE PTR [rsi]
     665:	cmp    al,0x1
     667:	sete   r8b
     66b:	test   r8b,r8b
     66e:	jne    6a4 <botlish_fn_5+0x7c>
     674:	mov    rdx,QWORD PTR [rdi+0x10]
     678:	mov    rcx,QWORD PTR [rdx+0xa8]
     67f:	xor    rbx,rbx
     682:	mov    rdx,rbx
     685:	call   68a <botlish_fn_5+0x62>
			686: R_X86_64_PLT32	rt_type_error-0x4
     68a:	mov    rax,rbx
     68d:	mov    rbx,QWORD PTR [rsp]
     691:	mov    r12,QWORD PTR [rsp+0x8]
     696:	mov    r13,QWORD PTR [rsp+0x10]
     69b:	add    rsp,0x20
     69f:	mov    rsp,rbp
     6a2:	pop    rbp
     6a3:	ret
     6a4:	mov    r12,rdi
     6a7:	test   rsi,0x1
     6ae:	mov    rbx,rsi
     6b1:	jne    6dc <botlish_fn_5+0xb4>
     6b7:	mov    edx,0x59
     6bc:	mov    rsi,rbx
     6bf:	mov    rdi,r12
     6c2:	call   6c7 <botlish_fn_5+0x9f>
			6c3: R_X86_64_PLT32	rt_int_cmp-0x4
     6c7:	mov    ecx,0x2
     6cc:	test   rax,rax
     6cf:	cmovle rcx,QWORD PTR [rip+0x461]        # b38 <botlish_fn_5+0x510>
     6d7:	jmp    6f0 <botlish_fn_5+0xc8>
     6dc:	mov    ecx,0x2
     6e1:	mov    rsi,rbx
     6e4:	cmp    rsi,0x59
     6e8:	cmovle rcx,QWORD PTR [rip+0x448]        # b38 <botlish_fn_5+0x510>
     6f0:	mov    eax,0x6
     6f5:	mov    r13,rax
     6f8:	cmp    rcx,0x6
     6fc:	je     b1b <botlish_fn_5+0x4f3>
     702:	mov    rsi,rbx
     705:	test   rsi,0x1
     70c:	jne    737 <botlish_fn_5+0x10f>
     712:	mov    edx,0x5d
     717:	mov    rsi,rbx
     71a:	mov    rdi,r12
     71d:	call   722 <botlish_fn_5+0xfa>
			71e: R_X86_64_PLT32	rt_int_cmp-0x4
     722:	mov    ecx,0x2
     727:	test   rax,rax
     72a:	cmovle rcx,QWORD PTR [rip+0x406]        # b38 <botlish_fn_5+0x510>
     732:	jmp    74b <botlish_fn_5+0x123>
     737:	mov    ecx,0x2
     73c:	mov    rsi,rbx
     73f:	cmp    rsi,0x5d
     743:	cmovle rcx,QWORD PTR [rip+0x3ed]        # b38 <botlish_fn_5+0x510>
     74b:	cmp    rcx,0x6
     74f:	je     b13 <botlish_fn_5+0x4eb>
     755:	mov    rsi,rbx
     758:	test   rsi,0x1
     75f:	jne    78a <botlish_fn_5+0x162>
     765:	mov    edx,0x5f
     76a:	mov    rsi,rbx
     76d:	mov    rdi,r12
     770:	call   775 <botlish_fn_5+0x14d>
			771: R_X86_64_PLT32	rt_int_cmp-0x4
     775:	mov    ecx,0x2
     77a:	test   rax,rax
     77d:	cmovle rcx,QWORD PTR [rip+0x3b3]        # b38 <botlish_fn_5+0x510>
     785:	jmp    79e <botlish_fn_5+0x176>
     78a:	mov    ecx,0x2
     78f:	mov    rsi,rbx
     792:	cmp    rsi,0x5f
     796:	cmovle rcx,QWORD PTR [rip+0x39a]        # b38 <botlish_fn_5+0x510>
     79e:	cmp    rcx,0x6
     7a2:	je     b09 <botlish_fn_5+0x4e1>
     7a8:	mov    rsi,rbx
     7ab:	test   rsi,0x1
     7b2:	jne    7dd <botlish_fn_5+0x1b5>
     7b8:	mov    edx,0x73
     7bd:	mov    rsi,rbx
     7c0:	mov    rdi,r12
     7c3:	call   7c8 <botlish_fn_5+0x1a0>
			7c4: R_X86_64_PLT32	rt_int_cmp-0x4
     7c8:	mov    ecx,0x2
     7cd:	test   rax,rax
     7d0:	cmovle rcx,QWORD PTR [rip+0x360]        # b38 <botlish_fn_5+0x510>
     7d8:	jmp    7f1 <botlish_fn_5+0x1c9>
     7dd:	mov    ecx,0x2
     7e2:	mov    rsi,rbx
     7e5:	cmp    rsi,0x73
     7e9:	cmovle rcx,QWORD PTR [rip+0x347]        # b38 <botlish_fn_5+0x510>
     7f1:	cmp    rcx,0x6
     7f5:	je     b01 <botlish_fn_5+0x4d9>
     7fb:	mov    rsi,rbx
     7fe:	test   rsi,0x1
     805:	jne    830 <botlish_fn_5+0x208>
     80b:	mov    edx,0x81
     810:	mov    rsi,rbx
     813:	mov    rdi,r12
     816:	call   81b <botlish_fn_5+0x1f3>
			817: R_X86_64_PLT32	rt_int_cmp-0x4
     81b:	mov    ecx,0x2
     820:	test   rax,rax
     823:	cmovle rcx,QWORD PTR [rip+0x30d]        # b38 <botlish_fn_5+0x510>
     82b:	jmp    847 <botlish_fn_5+0x21f>
     830:	mov    ecx,0x2
     835:	mov    rsi,rbx
     838:	cmp    rsi,0x81
     83f:	cmovle rcx,QWORD PTR [rip+0x2f1]        # b38 <botlish_fn_5+0x510>
     847:	cmp    rcx,0x6
     84b:	je     af7 <botlish_fn_5+0x4cf>
     851:	mov    rsi,rbx
     854:	test   rsi,0x1
     85b:	jne    886 <botlish_fn_5+0x25e>
     861:	mov    edx,0xb5
     866:	mov    rsi,rbx
     869:	mov    rdi,r12
     86c:	call   871 <botlish_fn_5+0x249>
			86d: R_X86_64_PLT32	rt_int_cmp-0x4
     871:	mov    ecx,0x2
     876:	test   rax,rax
     879:	cmovle rcx,QWORD PTR [rip+0x2b7]        # b38 <botlish_fn_5+0x510>
     881:	jmp    89d <botlish_fn_5+0x275>
     886:	mov    ecx,0x2
     88b:	mov    rsi,rbx
     88e:	cmp    rsi,0xb5
     895:	cmovle rcx,QWORD PTR [rip+0x29b]        # b38 <botlish_fn_5+0x510>
     89d:	cmp    rcx,0x6
     8a1:	je     aef <botlish_fn_5+0x4c7>
     8a7:	mov    rsi,rbx
     8aa:	test   rsi,0x1
     8b1:	jne    8dc <botlish_fn_5+0x2b4>
     8b7:	mov    edx,0xbd
     8bc:	mov    rsi,rbx
     8bf:	mov    rdi,r12
     8c2:	call   8c7 <botlish_fn_5+0x29f>
			8c3: R_X86_64_PLT32	rt_int_cmp-0x4
     8c7:	mov    ecx,0x2
     8cc:	test   rax,rax
     8cf:	cmovle rcx,QWORD PTR [rip+0x261]        # b38 <botlish_fn_5+0x510>
     8d7:	jmp    8f3 <botlish_fn_5+0x2cb>
     8dc:	mov    ecx,0x2
     8e1:	mov    rsi,rbx
     8e4:	cmp    rsi,0xbd
     8eb:	cmovle rcx,QWORD PTR [rip+0x245]        # b38 <botlish_fn_5+0x510>
     8f3:	cmp    rcx,0x6
     8f7:	je     ae5 <botlish_fn_5+0x4bd>
     8fd:	mov    rsi,rbx
     900:	test   rsi,0x1
     907:	jne    933 <botlish_fn_5+0x30b>
     90d:	mov    edx,0xbf
     912:	mov    rsi,rbx
     915:	mov    rdi,r12
     918:	call   91d <botlish_fn_5+0x2f5>
			919: R_X86_64_PLT32	rt_int_cmp-0x4
     91d:	mov    r11d,0x2
     923:	test   rax,rax
     926:	cmovle r11,QWORD PTR [rip+0x20a]        # b38 <botlish_fn_5+0x510>
     92e:	jmp    94b <botlish_fn_5+0x323>
     933:	mov    r11d,0x2
     939:	mov    rsi,rbx
     93c:	cmp    rsi,0xbf
     943:	cmovle r11,QWORD PTR [rip+0x1ed]        # b38 <botlish_fn_5+0x510>
     94b:	cmp    r11,0x6
     94f:	je     add <botlish_fn_5+0x4b5>
     955:	mov    rsi,rbx
     958:	test   rsi,0x1
     95f:	jne    98a <botlish_fn_5+0x362>
     965:	mov    edx,0xc1
     96a:	mov    rsi,rbx
     96d:	mov    rdi,r12
     970:	call   975 <botlish_fn_5+0x34d>
			971: R_X86_64_PLT32	rt_int_cmp-0x4
     975:	mov    ecx,0x2
     97a:	test   rax,rax
     97d:	cmovle rcx,QWORD PTR [rip+0x1b3]        # b38 <botlish_fn_5+0x510>
     985:	jmp    9a1 <botlish_fn_5+0x379>
     98a:	mov    ecx,0x2
     98f:	mov    rsi,rbx
     992:	cmp    rsi,0xc1
     999:	cmovle rcx,QWORD PTR [rip+0x197]        # b38 <botlish_fn_5+0x510>
     9a1:	cmp    rcx,0x6
     9a5:	je     ad3 <botlish_fn_5+0x4ab>
     9ab:	mov    rsi,rbx
     9ae:	test   rsi,0x1
     9b5:	jne    9e0 <botlish_fn_5+0x3b8>
     9bb:	mov    edx,0xf5
     9c0:	mov    rsi,rbx
     9c3:	mov    rdi,r12
     9c6:	call   9cb <botlish_fn_5+0x3a3>
			9c7: R_X86_64_PLT32	rt_int_cmp-0x4
     9cb:	mov    ecx,0x2
     9d0:	test   rax,rax
     9d3:	cmovle rcx,QWORD PTR [rip+0x15d]        # b38 <botlish_fn_5+0x510>
     9db:	jmp    9f7 <botlish_fn_5+0x3cf>
     9e0:	mov    ecx,0x2
     9e5:	mov    rsi,rbx
     9e8:	cmp    rsi,0xf5
     9ef:	cmovle rcx,QWORD PTR [rip+0x141]        # b38 <botlish_fn_5+0x510>
     9f7:	cmp    rcx,0x6
     9fb:	je     acb <botlish_fn_5+0x4a3>
     a01:	mov    rsi,rbx
     a04:	test   rsi,0x1
     a0b:	jne    a36 <botlish_fn_5+0x40e>
     a11:	mov    edx,0xfb
     a16:	mov    rsi,rbx
     a19:	mov    rdi,r12
     a1c:	call   a21 <botlish_fn_5+0x3f9>
			a1d: R_X86_64_PLT32	rt_int_cmp-0x4
     a21:	mov    ecx,0x2
     a26:	test   rax,rax
     a29:	cmovle rcx,QWORD PTR [rip+0x107]        # b38 <botlish_fn_5+0x510>
     a31:	jmp    a4d <botlish_fn_5+0x425>
     a36:	mov    ecx,0x2
     a3b:	mov    rsi,rbx
     a3e:	cmp    rsi,0xfb
     a45:	cmovle rcx,QWORD PTR [rip+0xeb]        # b38 <botlish_fn_5+0x510>
     a4d:	cmp    rcx,0x6
     a51:	je     ac1 <botlish_fn_5+0x499>
     a57:	mov    rsi,rbx
     a5a:	test   rsi,0x1
     a61:	jne    a8d <botlish_fn_5+0x465>
     a67:	mov    edx,0xfd
     a6c:	mov    rsi,rbx
     a6f:	mov    rdi,r12
     a72:	call   a77 <botlish_fn_5+0x44f>
			a73: R_X86_64_PLT32	rt_int_cmp-0x4
     a77:	mov    r8d,0x2
     a7d:	test   rax,rax
     a80:	cmovle r8,QWORD PTR [rip+0xb0]        # b38 <botlish_fn_5+0x510>
     a88:	jmp    aa5 <botlish_fn_5+0x47d>
     a8d:	mov    r8d,0x2
     a93:	mov    rsi,rbx
     a96:	cmp    rsi,0xfd
     a9d:	cmovle r8,QWORD PTR [rip+0x93]        # b38 <botlish_fn_5+0x510>
     aa5:	cmp    r8,0x6
     aa9:	je     ab9 <botlish_fn_5+0x491>
     aaf:	mov    eax,0x2
     ab4:	jmp    b20 <botlish_fn_5+0x4f8>
     ab9:	mov    rax,r13
     abc:	jmp    b20 <botlish_fn_5+0x4f8>
     ac1:	mov    eax,0x2
     ac6:	jmp    b20 <botlish_fn_5+0x4f8>
     acb:	mov    rax,r13
     ace:	jmp    b20 <botlish_fn_5+0x4f8>
     ad3:	mov    eax,0x2
     ad8:	jmp    b20 <botlish_fn_5+0x4f8>
     add:	mov    rax,r13
     ae0:	jmp    b20 <botlish_fn_5+0x4f8>
     ae5:	mov    eax,0x2
     aea:	jmp    b20 <botlish_fn_5+0x4f8>
     aef:	mov    rax,r13
     af2:	jmp    b20 <botlish_fn_5+0x4f8>
     af7:	mov    eax,0x2
     afc:	jmp    b20 <botlish_fn_5+0x4f8>
     b01:	mov    rax,r13
     b04:	jmp    b20 <botlish_fn_5+0x4f8>
     b09:	mov    eax,0x2
     b0e:	jmp    b20 <botlish_fn_5+0x4f8>
     b13:	mov    rax,r13
     b16:	jmp    b20 <botlish_fn_5+0x4f8>
     b1b:	mov    eax,0x2
     b20:	mov    rbx,QWORD PTR [rsp]
     b24:	mov    r12,QWORD PTR [rsp+0x8]
     b29:	mov    r13,QWORD PTR [rsp+0x10]
     b2e:	add    rsp,0x20
     b32:	mov    rsp,rbp
     b35:	pop    rbp
     b36:	ret
     b37:	add    BYTE PTR [rsi],al
     b39:	add    BYTE PTR [rax],al
     b3b:	add    BYTE PTR [rax],al
     b3d:	add    BYTE PTR [rax],al
	...

0000000000000b40 <botlish_entry_5: is_unreserved<generic>>:
     b40:	push   rbp
     b41:	mov    rbp,rsp
     b44:	mov    rsi,QWORD PTR [rdx]
     b47:	call   b4c <botlish_entry_5+0xc>
			b48: R_X86_64_PLT32	botlish_fn_5-0x4 ; is_unreserved<generic>
     b4c:	mov    rsp,rbp
     b4f:	pop    rbp
     b50:	ret

0000000000000b51 <botlish_fn_6: hex_pair<generic>>:
     b51:	push   rbp
     b52:	mov    rbp,rsp
     b55:	sub    rsp,0x30
     b59:	mov    QWORD PTR [rsp+0x10],rbx
     b5e:	mov    QWORD PTR [rsp+0x18],r12
     b63:	mov    QWORD PTR [rsp+0x20],r13
     b68:	mov    QWORD PTR [rsp+0x28],r14
     b6d:	mov    r12,rdi
     b70:	mov    QWORD PTR [rsp],rsi
     b74:	mov    r13,rsi
     b77:	mov    QWORD PTR [rsp+0x8],rdx
     b7c:	mov    rbx,rdx
     b7f:	mov    rsi,r13
     b82:	mov    rdi,r12
     b85:	call   b8a <botlish_fn_6+0x39>
			b86: R_X86_64_PLT32	botlish_fn_4-0x4 ; high_nibble<generic>
     b8a:	test   rax,rax
     b8d:	je     cbb <botlish_fn_6+0x16a>
     b93:	test   rax,0x1
     b99:	jne    ba7 <botlish_fn_6+0x56>
     b9f:	mov    rdx,rax
     ba2:	jmp    bbd <botlish_fn_6+0x6c>
     ba7:	mov    rdx,QWORD PTR [rbx+0x8]
     bab:	mov    rcx,rax
     bae:	sar    rcx,1
     bb1:	cmp    rcx,rdx
     bb4:	jb     bd9 <botlish_fn_6+0x88>
     bba:	mov    rdx,rax
     bbd:	mov    rsi,rbx
     bc0:	mov    rdi,r12
     bc3:	call   bc8 <botlish_fn_6+0x77>
			bc4: R_X86_64_PLT32	rt_list_get-0x4
     bc8:	test   rax,rax
     bcb:	je     cbb <botlish_fn_6+0x16a>
     bd1:	mov    rsi,rax
     bd4:	jmp    be1 <botlish_fn_6+0x90>
     bd9:	mov    rax,QWORD PTR [rbx+0x10]
     bdd:	mov    rsi,QWORD PTR [rax+rcx*8]
     be1:	mov    QWORD PTR [rsp],rsi
     be5:	mov    r14,rsi
     be8:	mov    ecx,0x1
     bed:	mov    rsi,r13
     bf0:	test   rsi,0x1
     bf7:	jne    c15 <botlish_fn_6+0xc4>
     bfd:	xor    ecx,ecx
     bff:	test   rsi,0x7
     c06:	jne    c15 <botlish_fn_6+0xc4>
     c0c:	movzx  rax,BYTE PTR [rsi]
     c10:	cmp    al,0x1
     c12:	sete   cl
     c15:	test   cl,cl
     c17:	jne    c38 <botlish_fn_6+0xe7>
     c1d:	mov    rdi,r12
     c20:	mov    rax,QWORD PTR [rdi+0x10]
     c24:	mov    rcx,QWORD PTR [rax+0xb0]
     c2b:	xor    rdx,rdx
     c2e:	call   c33 <botlish_fn_6+0xe2>
			c2f: R_X86_64_PLT32	rt_type_error-0x4
     c33:	jmp    cbb <botlish_fn_6+0x16a>
     c38:	mov    edx,0x21
     c3d:	mov    rdi,r12
     c40:	call   c45 <botlish_fn_6+0xf4>
			c41: R_X86_64_PLT32	rt_int_mod-0x4
     c45:	test   rax,rax
     c48:	je     cbb <botlish_fn_6+0x16a>
     c4e:	test   rax,0x1
     c54:	jne    c65 <botlish_fn_6+0x114>
     c5a:	mov    rdx,rax
     c5d:	mov    rsi,rbx
     c60:	jmp    c7e <botlish_fn_6+0x12d>
     c65:	mov    rdi,QWORD PTR [rbx+0x8]
     c69:	mov    rsi,rax
     c6c:	sar    rsi,1
     c6f:	mov    rdx,rax
     c72:	cmp    rsi,rdi
     c75:	jb     c97 <botlish_fn_6+0x146>
     c7b:	mov    rsi,rbx
     c7e:	mov    rdi,r12
     c81:	call   c86 <botlish_fn_6+0x135>
			c82: R_X86_64_PLT32	rt_list_get-0x4
     c86:	test   rax,rax
     c89:	je     cbb <botlish_fn_6+0x16a>
     c8f:	mov    rdx,rax
     c92:	jmp    ca2 <botlish_fn_6+0x151>
     c97:	mov    rax,rbx
     c9a:	mov    rax,QWORD PTR [rax+0x10]
     c9e:	mov    rdx,QWORD PTR [rax+rsi*8]
     ca2:	mov    QWORD PTR [rsp+0x8],rdx
     ca7:	mov    rsi,r14
     caa:	mov    rdi,r12
     cad:	call   cb2 <botlish_fn_6+0x161>
			cae: R_X86_64_PLT32	rt_str_cat-0x4
     cb2:	test   rax,rax
     cb5:	jne    cdb <botlish_fn_6+0x18a>
     cbb:	xor    rax,rax
     cbe:	mov    rbx,QWORD PTR [rsp+0x10]
     cc3:	mov    r12,QWORD PTR [rsp+0x18]
     cc8:	mov    r13,QWORD PTR [rsp+0x20]
     ccd:	mov    r14,QWORD PTR [rsp+0x28]
     cd2:	add    rsp,0x30
     cd6:	mov    rsp,rbp
     cd9:	pop    rbp
     cda:	ret
     cdb:	mov    rbx,QWORD PTR [rsp+0x10]
     ce0:	mov    r12,QWORD PTR [rsp+0x18]
     ce5:	mov    r13,QWORD PTR [rsp+0x20]
     cea:	mov    r14,QWORD PTR [rsp+0x28]
     cef:	add    rsp,0x30
     cf3:	mov    rsp,rbp
     cf6:	pop    rbp
     cf7:	ret

0000000000000cf8 <botlish_entry_6: hex_pair<generic>>:
     cf8:	push   rbp
     cf9:	mov    rbp,rsp
     cfc:	mov    rsi,QWORD PTR [rdx]
     cff:	mov    rdx,QWORD PTR [rdx+0x8]
     d03:	call   d08 <botlish_entry_6+0x10>
			d04: R_X86_64_PLT32	botlish_fn_6-0x4 ; hex_pair<generic>
     d08:	mov    rsp,rbp
     d0b:	pop    rbp
     d0c:	ret
     d0d:	add    BYTE PTR [rax],al
	...

0000000000000d10 <botlish_fn_7: esc_bytes<generic>>:
     d10:	push   rbp
     d11:	mov    rbp,rsp
     d14:	sub    rsp,0x70
     d18:	mov    QWORD PTR [rsp+0x40],rbx
     d1d:	mov    QWORD PTR [rsp+0x48],r12
     d22:	mov    QWORD PTR [rsp+0x50],r13
     d27:	mov    QWORD PTR [rsp+0x58],r14
     d2c:	mov    QWORD PTR [rsp+0x60],r15
     d31:	mov    r13,rdi
     d34:	mov    QWORD PTR [rsp+0x28],0x0
     d3d:	mov    QWORD PTR [rsp],rsi
     d41:	mov    QWORD PTR [rsp+0x8],rdx
     d46:	mov    QWORD PTR [rsp+0x10],rcx
     d4b:	mov    QWORD PTR [rsp+0x18],r8
     d50:	mov    r12,r8
     d53:	mov    r14,rcx
     d56:	mov    r15,rdx
     d59:	xor    eax,eax
     d5b:	test   rsi,0x7
     d62:	jne    d73 <botlish_fn_7+0x63>
     d68:	movzx  r8,BYTE PTR [rsi]
     d6c:	cmp    r8b,0x3
     d70:	sete   al
     d73:	test   al,al
     d75:	jne    d98 <botlish_fn_7+0x88>
     d7b:	mov    rdi,r13
     d7e:	mov    rax,QWORD PTR [rdi+0x10]
     d82:	mov    rcx,QWORD PTR [rax+0xb8]
     d89:	mov    edx,0x4
     d8e:	call   d93 <botlish_fn_7+0x83>
			d8f: R_X86_64_PLT32	rt_type_error-0x4
     d93:	jmp    f9e <botlish_fn_7+0x28e>
     d98:	mov    rbx,rsi
     d9b:	mov    rdi,r13
     d9e:	call   da3 <botlish_fn_7+0x93>
			d9f: R_X86_64_PLT32	rt_list_len-0x4
     da3:	mov    ecx,0x1
     da8:	mov    rsi,r15
     dab:	test   rsi,0x1
     db2:	jne    dd8 <botlish_fn_7+0xc8>
     db8:	xor    ecx,ecx
     dba:	mov    rsi,r15
     dbd:	test   rsi,0x7
     dc4:	jne    dd8 <botlish_fn_7+0xc8>
     dca:	mov    rsi,r15
     dcd:	movzx  rcx,BYTE PTR [rsi]
     dd1:	rex cmp cl,0x1
     dd5:	sete   cl
     dd8:	test   cl,cl
     dda:	jne    dfe <botlish_fn_7+0xee>
     de0:	mov    rdi,r13
     de3:	mov    rax,QWORD PTR [rdi+0x10]
     de7:	mov    rcx,QWORD PTR [rax+0xc0]
     dee:	xor    rdx,rdx
     df1:	mov    rsi,r15
     df4:	call   df9 <botlish_fn_7+0xe9>
			df5: R_X86_64_PLT32	rt_type_error-0x4
     df9:	jmp    f9e <botlish_fn_7+0x28e>
     dfe:	mov    rsi,r15
     e01:	mov    rcx,rsi
     e04:	and    rcx,rax
     e07:	mov    rdx,rax
     e0a:	test   rcx,0x1
     e11:	jne    e37 <botlish_fn_7+0x127>
     e17:	mov    rsi,r15
     e1a:	mov    rdi,r13
     e1d:	call   e22 <botlish_fn_7+0x112>
			e1e: R_X86_64_PLT32	rt_int_cmp-0x4
     e22:	mov    ecx,0x2
     e27:	test   rax,rax
     e2a:	cmovge rcx,QWORD PTR [rip+0x1de]        # 1010 <botlish_fn_7+0x300>
     e32:	jmp    e4a <botlish_fn_7+0x13a>
     e37:	mov    ecx,0x2
     e3c:	mov    rsi,r15
     e3f:	cmp    rsi,rdx
     e42:	cmovge rcx,QWORD PTR [rip+0x1c6]        # 1010 <botlish_fn_7+0x300>
     e4a:	cmp    rcx,0x6
     e4e:	je     fe9 <botlish_fn_7+0x2d9>
     e54:	mov    QWORD PTR [rsp+0x20],0x3
     e5d:	mov    rsi,r15
     e60:	test   rsi,0x1
     e67:	je     e82 <botlish_fn_7+0x172>
     e6d:	mov    rsi,r15
     e70:	mov    rax,rsi
     e73:	add    rax,0x2
     e77:	seto   cl
     e7a:	test   cl,cl
     e7c:	je     e92 <botlish_fn_7+0x182>
     e82:	mov    edx,0x3
     e87:	mov    rsi,r15
     e8a:	mov    rdi,r13
     e8d:	call   e92 <botlish_fn_7+0x182>
			e8e: R_X86_64_PLT32	rt_int_add-0x4
     e92:	mov    QWORD PTR [rsp+0x8],rax
     e97:	mov    rdi,r13
     e9a:	mov    QWORD PTR [rsp+0x30],rax
     e9f:	mov    rax,QWORD PTR [rdi+0x10]
     ea3:	mov    rsi,QWORD PTR [rax+0xc8]
     eaa:	mov    QWORD PTR [rsp+0x20],rsi
     eaf:	mov    QWORD PTR [rsp+0x38],rsi
     eb4:	mov    rsi,r15
     eb7:	test   rsi,0x1
     ebe:	jne    ecc <botlish_fn_7+0x1bc>
     ec4:	mov    rdx,r15
     ec7:	jmp    ee5 <botlish_fn_7+0x1d5>
     ecc:	mov    rcx,QWORD PTR [rbx+0x8]
     ed0:	mov    rsi,r15
     ed3:	mov    rax,rsi
     ed6:	sar    rax,1
     ed9:	cmp    rax,rcx
     edc:	jb     f01 <botlish_fn_7+0x1f1>
     ee2:	mov    rdx,r15
     ee5:	mov    rsi,rbx
     ee8:	mov    rdi,r13
     eeb:	call   ef0 <botlish_fn_7+0x1e0>
			eec: R_X86_64_PLT32	rt_list_get-0x4
     ef0:	test   rax,rax
     ef3:	je     f9e <botlish_fn_7+0x28e>
     ef9:	mov    rsi,rax
     efc:	jmp    f09 <botlish_fn_7+0x1f9>
     f01:	mov    rcx,QWORD PTR [rbx+0x10]
     f05:	mov    rsi,QWORD PTR [rcx+rax*8]
     f09:	mov    QWORD PTR [rsp+0x28],rsi
     f0e:	mov    rdx,r12
     f11:	mov    rdi,r13
     f14:	call   f19 <botlish_fn_7+0x209>
			f15: R_X86_64_PLT32	botlish_fn_6-0x4 ; hex_pair<generic>
     f19:	test   rax,rax
     f1c:	je     f9e <botlish_fn_7+0x28e>
     f22:	mov    QWORD PTR [rsp+0x28],rax
     f27:	mov    rdx,rax
     f2a:	mov    rsi,QWORD PTR [rsp+0x38]
     f2f:	mov    rdi,r13
     f32:	call   f37 <botlish_fn_7+0x227>
			f33: R_X86_64_PLT32	rt_str_cat-0x4
     f37:	test   rax,rax
     f3a:	je     f9e <botlish_fn_7+0x28e>
     f40:	mov    QWORD PTR [rsp+0x20],rax
     f45:	mov    rdx,rax
     f48:	xor    eax,eax
     f4a:	mov    rsi,r14
     f4d:	test   rsi,0x7
     f54:	jne    f65 <botlish_fn_7+0x255>
     f5a:	movzx  rdi,BYTE PTR [rsi]
     f5e:	cmp    dil,0x2
     f62:	sete   al
     f65:	test   al,al
     f67:	jne    f8d <botlish_fn_7+0x27d>
     f6d:	mov    rdi,r13
     f70:	mov    rdi,QWORD PTR [rdi+0x10]
     f74:	mov    rcx,QWORD PTR [rdi+0xd0]
     f7b:	mov    edx,0x1
     f80:	mov    rdi,r13
     f83:	call   f88 <botlish_fn_7+0x278>
			f84: R_X86_64_PLT32	rt_type_error-0x4
     f88:	jmp    f9e <botlish_fn_7+0x28e>
     f8d:	mov    rdi,r13
     f90:	call   f95 <botlish_fn_7+0x285>
			f91: R_X86_64_PLT32	rt_str_cat-0x4
     f95:	test   rax,rax
     f98:	jne    fc3 <botlish_fn_7+0x2b3>
     f9e:	xor    rax,rax
     fa1:	mov    rbx,QWORD PTR [rsp+0x40]
     fa6:	mov    r12,QWORD PTR [rsp+0x48]
     fab:	mov    r13,QWORD PTR [rsp+0x50]
     fb0:	mov    r14,QWORD PTR [rsp+0x58]
     fb5:	mov    r15,QWORD PTR [rsp+0x60]
     fba:	add    rsp,0x70
     fbe:	mov    rsp,rbp
     fc1:	pop    rbp
     fc2:	ret
     fc3:	mov    QWORD PTR [rsp],rbx
     fc7:	mov    rcx,QWORD PTR [rsp+0x30]
     fcc:	mov    QWORD PTR [rsp+0x8],rcx
     fd1:	mov    QWORD PTR [rsp+0x10],rax
     fd6:	mov    QWORD PTR [rsp+0x18],r12
     fdb:	mov    rsi,rbx
     fde:	mov    r14,rax
     fe1:	mov    r15,rcx
     fe4:	jmp    d59 <botlish_fn_7+0x49>
     fe9:	mov    rax,r14
     fec:	mov    rbx,QWORD PTR [rsp+0x40]
     ff1:	mov    r12,QWORD PTR [rsp+0x48]
     ff6:	mov    r13,QWORD PTR [rsp+0x50]
     ffb:	mov    r14,QWORD PTR [rsp+0x58]
    1000:	mov    r15,QWORD PTR [rsp+0x60]
    1005:	add    rsp,0x70
    1009:	mov    rsp,rbp
    100c:	pop    rbp
    100d:	ret
    100e:	add    BYTE PTR [rax],al
    1010:	(bad)
    1011:	add    BYTE PTR [rax],al
    1013:	add    BYTE PTR [rax],al
    1015:	add    BYTE PTR [rax],al
	...

0000000000001018 <botlish_entry_7: esc_bytes<generic>>:
    1018:	push   rbp
    1019:	mov    rbp,rsp
    101c:	mov    rsi,QWORD PTR [rdx]
    101f:	mov    r9,QWORD PTR [rdx+0x8]
    1023:	mov    rcx,QWORD PTR [rdx+0x10]
    1027:	mov    r8,QWORD PTR [rdx+0x18]
    102b:	mov    rdx,r9
    102e:	call   1033 <botlish_entry_7+0x1b>
			102f: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_bytes<generic>
    1033:	mov    rsp,rbp
    1036:	pop    rbp
    1037:	ret

0000000000001038 <botlish_fn_8: esc_char<generic>>:
    1038:	push   rbp
    1039:	mov    rbp,rsp
    103c:	sub    rsp,0x50
    1040:	mov    QWORD PTR [rsp+0x20],rbx
    1045:	mov    QWORD PTR [rsp+0x28],r12
    104a:	mov    QWORD PTR [rsp+0x30],r13
    104f:	mov    QWORD PTR [rsp+0x38],r14
    1054:	mov    QWORD PTR [rsp+0x40],r15
    1059:	mov    QWORD PTR [rsp+0x10],0x0
    1062:	mov    QWORD PTR [rsp+0x18],0x0
    106b:	mov    QWORD PTR [rsp],rsi
    106f:	mov    QWORD PTR [rsp+0x8],rdx
    1074:	mov    rbx,rdx
    1077:	xor    r9d,r9d
    107a:	test   rsi,0x7
    1081:	jne    1091 <botlish_fn_8+0x59>
    1087:	movzx  rax,BYTE PTR [rsi]
    108b:	cmp    al,0x2
    108d:	sete   r9b
    1091:	test   r9b,r9b
    1094:	jne    10b4 <botlish_fn_8+0x7c>
    109a:	mov    rax,QWORD PTR [rdi+0x10]
    109e:	mov    rcx,QWORD PTR [rax+0xd8]
    10a5:	mov    edx,0x1
    10aa:	call   10af <botlish_fn_8+0x77>
			10ab: R_X86_64_PLT32	rt_type_error-0x4
    10af:	jmp    11b4 <botlish_fn_8+0x17c>
    10b4:	mov    r12,rdi
    10b7:	mov    r15,rsi
    10ba:	call   10bf <botlish_fn_8+0x87>
			10bb: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    10bf:	mov    rcx,rax
    10c2:	mov    r13,rax
    10c5:	test   rax,rcx
    10c8:	je     11b4 <botlish_fn_8+0x17c>
    10ce:	mov    rax,r13
    10d1:	mov    QWORD PTR [rsp],rax
    10d5:	mov    rsi,r13
    10d8:	mov    rdi,r12
    10db:	call   10e0 <botlish_fn_8+0xa8>
			10dc: R_X86_64_PLT32	rt_list_len-0x4
    10e0:	mov    edx,0x1
    10e5:	sar    rax,1
    10e8:	cmp    rax,0x1
    10ec:	je     1127 <botlish_fn_8+0xef>
    10f2:	mov    QWORD PTR [rsp+0x10],0x1
    10fb:	mov    rdi,r12
    10fe:	mov    rax,QWORD PTR [rdi+0x10]
    1102:	mov    rcx,QWORD PTR [rax+0xa0]
    1109:	mov    QWORD PTR [rsp+0x18],rcx
    110e:	mov    rsi,r13
    1111:	mov    r8,rbx
    1114:	call   1119 <botlish_fn_8+0xe1>
			1115: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_bytes<generic>
    1119:	test   rax,rax
    111c:	je     11b4 <botlish_fn_8+0x17c>
    1122:	jmp    11df <botlish_fn_8+0x1a7>
    1127:	mov    rsi,r13
    112a:	mov    r14,rdx
    112d:	mov    rax,QWORD PTR [rsi+0x8]
    1131:	mov    r13,rsi
    1134:	test   rax,rax
    1137:	jne    115c <botlish_fn_8+0x124>
    113d:	mov    rdx,r14
    1140:	mov    rsi,r13
    1143:	mov    rdi,r12
    1146:	call   114b <botlish_fn_8+0x113>
			1147: R_X86_64_PLT32	rt_list_get-0x4
    114b:	test   rax,rax
    114e:	je     11b4 <botlish_fn_8+0x17c>
    1154:	mov    rsi,rax
    1157:	jmp    1166 <botlish_fn_8+0x12e>
    115c:	mov    rsi,r13
    115f:	mov    rcx,QWORD PTR [rsi+0x10]
    1163:	mov    rsi,QWORD PTR [rcx]
    1166:	mov    rdi,r12
    1169:	call   116e <botlish_fn_8+0x136>
			116a: R_X86_64_PLT32	botlish_fn_5-0x4 ; is_unreserved<generic>
    116e:	test   rax,rax
    1171:	je     11b4 <botlish_fn_8+0x17c>
    1177:	cmp    rax,0x6
    117b:	je     11dc <botlish_fn_8+0x1a4>
    1181:	mov    QWORD PTR [rsp+0x10],0x1
    118a:	mov    rdi,r12
    118d:	mov    r8,QWORD PTR [rdi+0x10]
    1191:	mov    rcx,QWORD PTR [r8+0xa0]
    1198:	mov    QWORD PTR [rsp+0x18],rcx
    119d:	mov    rdx,r14
    11a0:	mov    rsi,r13
    11a3:	mov    r8,rbx
    11a6:	call   11ab <botlish_fn_8+0x173>
			11a7: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_bytes<generic>
    11ab:	test   rax,rax
    11ae:	jne    11d9 <botlish_fn_8+0x1a1>
    11b4:	xor    rax,rax
    11b7:	mov    rbx,QWORD PTR [rsp+0x20]
    11bc:	mov    r12,QWORD PTR [rsp+0x28]
    11c1:	mov    r13,QWORD PTR [rsp+0x30]
    11c6:	mov    r14,QWORD PTR [rsp+0x38]
    11cb:	mov    r15,QWORD PTR [rsp+0x40]
    11d0:	add    rsp,0x50
    11d4:	mov    rsp,rbp
    11d7:	pop    rbp
    11d8:	ret
    11d9:	mov    r15,rax
    11dc:	mov    rax,r15
    11df:	mov    rbx,QWORD PTR [rsp+0x20]
    11e4:	mov    r12,QWORD PTR [rsp+0x28]
    11e9:	mov    r13,QWORD PTR [rsp+0x30]
    11ee:	mov    r14,QWORD PTR [rsp+0x38]
    11f3:	mov    r15,QWORD PTR [rsp+0x40]
    11f8:	add    rsp,0x50
    11fc:	mov    rsp,rbp
    11ff:	pop    rbp
    1200:	ret

0000000000001201 <botlish_entry_8: esc_char<generic>>:
    1201:	push   rbp
    1202:	mov    rbp,rsp
    1205:	mov    rsi,QWORD PTR [rdx]
    1208:	mov    rdx,QWORD PTR [rdx+0x8]
    120c:	call   1211 <botlish_entry_8+0x10>
			120d: R_X86_64_PLT32	botlish_fn_8-0x4 ; esc_char<generic>
    1211:	mov    rsp,rbp
    1214:	pop    rbp
    1215:	ret
	...

0000000000001218 <botlish_fn_9: esc_from<generic>>:
    1218:	push   rbp
    1219:	mov    rbp,rsp
    121c:	sub    rsp,0x70
    1220:	mov    QWORD PTR [rsp+0x40],rbx
    1225:	mov    QWORD PTR [rsp+0x48],r12
    122a:	mov    QWORD PTR [rsp+0x50],r13
    122f:	mov    QWORD PTR [rsp+0x58],r14
    1234:	mov    QWORD PTR [rsp+0x60],r15
    1239:	mov    r13,rdi
    123c:	mov    QWORD PTR [rsp+0x28],0x0
    1245:	mov    QWORD PTR [rsp],rsi
    1249:	mov    QWORD PTR [rsp+0x8],rdx
    124e:	mov    QWORD PTR [rsp+0x10],rcx
    1253:	mov    QWORD PTR [rsp+0x18],r8
    1258:	mov    r12,r8
    125b:	mov    r14,rcx
    125e:	mov    QWORD PTR [rsp+0x30],rdx
    1263:	xor    eax,eax
    1265:	test   rsi,0x7
    126c:	jne    127b <botlish_fn_9+0x63>
    1272:	movzx  rax,BYTE PTR [rsi]
    1276:	cmp    al,0x2
    1278:	sete   al
    127b:	test   al,al
    127d:	jne    12a0 <botlish_fn_9+0x88>
    1283:	mov    rdi,r13
    1286:	mov    rax,QWORD PTR [rdi+0x10]
    128a:	mov    rcx,QWORD PTR [rax+0xe0]
    1291:	mov    edx,0x1
    1296:	call   129b <botlish_fn_9+0x83>
			1297: R_X86_64_PLT32	rt_type_error-0x4
    129b:	jmp    14e4 <botlish_fn_9+0x2cc>
    12a0:	mov    rbx,rsi
    12a3:	mov    rdi,r13
    12a6:	call   12ab <botlish_fn_9+0x93>
			12a7: R_X86_64_PLT32	rt_str_len-0x4
    12ab:	mov    edx,0x1
    12b0:	mov    r15,rdx
    12b3:	mov    ecx,0x1
    12b8:	mov    rsi,QWORD PTR [rsp+0x30]
    12bd:	test   rsi,0x1
    12c4:	jne    12ee <botlish_fn_9+0xd6>
    12ca:	xor    ecx,ecx
    12cc:	mov    rsi,QWORD PTR [rsp+0x30]
    12d1:	test   rsi,0x7
    12d8:	jne    12ee <botlish_fn_9+0xd6>
    12de:	mov    rsi,QWORD PTR [rsp+0x30]
    12e3:	movzx  rcx,BYTE PTR [rsi]
    12e7:	rex cmp cl,0x1
    12eb:	sete   cl
    12ee:	test   cl,cl
    12f0:	jne    1316 <botlish_fn_9+0xfe>
    12f6:	mov    rdi,r13
    12f9:	mov    rax,QWORD PTR [rdi+0x10]
    12fd:	mov    rcx,QWORD PTR [rax+0xc0]
    1304:	xor    rdx,rdx
    1307:	mov    rsi,QWORD PTR [rsp+0x30]
    130c:	call   1311 <botlish_fn_9+0xf9>
			130d: R_X86_64_PLT32	rt_type_error-0x4
    1311:	jmp    14e4 <botlish_fn_9+0x2cc>
    1316:	mov    rsi,QWORD PTR [rsp+0x30]
    131b:	mov    rcx,rsi
    131e:	and    rcx,rax
    1321:	mov    rdx,rax
    1324:	test   rcx,0x1
    132b:	jne    1353 <botlish_fn_9+0x13b>
    1331:	mov    rsi,QWORD PTR [rsp+0x30]
    1336:	mov    rdi,r13
    1339:	call   133e <botlish_fn_9+0x126>
			133a: R_X86_64_PLT32	rt_int_cmp-0x4
    133e:	mov    ecx,0x2
    1343:	test   rax,rax
    1346:	cmovge rcx,QWORD PTR [rip+0x20a]        # 1558 <botlish_fn_9+0x340>
    134e:	jmp    1368 <botlish_fn_9+0x150>
    1353:	mov    ecx,0x2
    1358:	mov    rsi,QWORD PTR [rsp+0x30]
    135d:	cmp    rsi,rdx
    1360:	cmovge rcx,QWORD PTR [rip+0x1f0]        # 1558 <botlish_fn_9+0x340>
    1368:	cmp    rcx,0x6
    136c:	je     1531 <botlish_fn_9+0x319>
    1372:	mov    QWORD PTR [rsp+0x20],0x3
    137b:	mov    rsi,QWORD PTR [rsp+0x30]
    1380:	test   rsi,0x1
    1387:	je     13a4 <botlish_fn_9+0x18c>
    138d:	mov    rsi,QWORD PTR [rsp+0x30]
    1392:	mov    rax,rsi
    1395:	add    rax,0x2
    1399:	seto   cl
    139c:	test   cl,cl
    139e:	je     13b6 <botlish_fn_9+0x19e>
    13a4:	mov    edx,0x3
    13a9:	mov    rsi,QWORD PTR [rsp+0x30]
    13ae:	mov    rdi,r13
    13b1:	call   13b6 <botlish_fn_9+0x19e>
			13b2: R_X86_64_PLT32	rt_int_add-0x4
    13b6:	mov    QWORD PTR [rsp+0x20],rax
    13bb:	mov    QWORD PTR [rsp+0x38],rax
    13c0:	mov    QWORD PTR [rsp+0x28],0x3
    13c9:	mov    rsi,QWORD PTR [rsp+0x30]
    13ce:	test   rsi,0x1
    13d5:	je     13f2 <botlish_fn_9+0x1da>
    13db:	mov    rsi,QWORD PTR [rsp+0x30]
    13e0:	mov    rcx,rsi
    13e3:	add    rcx,0x2
    13e7:	seto   al
    13ea:	test   al,al
    13ec:	je     1407 <botlish_fn_9+0x1ef>
    13f2:	mov    edx,0x3
    13f7:	mov    rsi,QWORD PTR [rsp+0x30]
    13fc:	mov    rdi,r13
    13ff:	call   1404 <botlish_fn_9+0x1ec>
			1400: R_X86_64_PLT32	rt_int_add-0x4
    1404:	mov    rcx,rax
    1407:	mov    QWORD PTR [rsp+0x28],rcx
    140c:	mov    rdx,QWORD PTR [rsp+0x30]
    1411:	mov    rsi,rbx
    1414:	mov    rdi,r13
    1417:	call   141c <botlish_fn_9+0x204>
			1418: R_X86_64_PLT32	rt_substr-0x4
    141c:	test   rax,rax
    141f:	je     14e4 <botlish_fn_9+0x2cc>
    1425:	mov    QWORD PTR [rsp+0x8],rax
    142a:	mov    rsi,rax
    142d:	mov    rdx,r12
    1430:	mov    rdi,r13
    1433:	call   1438 <botlish_fn_9+0x220>
			1434: R_X86_64_PLT32	botlish_fn_8-0x4 ; esc_char<generic>
    1438:	test   rax,rax
    143b:	je     14e4 <botlish_fn_9+0x2cc>
    1441:	mov    QWORD PTR [rsp+0x8],rax
    1446:	xor    ecx,ecx
    1448:	mov    rsi,r14
    144b:	test   rsi,0x7
    1452:	jne    1463 <botlish_fn_9+0x24b>
    1458:	movzx  rdi,BYTE PTR [rsi]
    145c:	cmp    dil,0x2
    1460:	sete   cl
    1463:	test   cl,cl
    1465:	jne    1486 <botlish_fn_9+0x26e>
    146b:	mov    rdi,r13
    146e:	mov    r9,QWORD PTR [rdi+0x10]
    1472:	mov    rcx,QWORD PTR [r9+0xd0]
    1479:	mov    rdx,r15
    147c:	call   1481 <botlish_fn_9+0x269>
			147d: R_X86_64_PLT32	rt_type_error-0x4
    1481:	jmp    14e4 <botlish_fn_9+0x2cc>
    1486:	mov    rdx,r15
    1489:	xor    ecx,ecx
    148b:	test   rax,0x7
    1491:	je     149f <botlish_fn_9+0x287>
    1497:	mov    r8,rax
    149a:	jmp    14ad <botlish_fn_9+0x295>
    149f:	movzx  rcx,BYTE PTR [rax]
    14a3:	mov    r8,rax
    14a6:	rex cmp cl,0x2
    14aa:	sete   cl
    14ad:	test   cl,cl
    14af:	jne    14d0 <botlish_fn_9+0x2b8>
    14b5:	mov    rdi,r13
    14b8:	mov    rax,QWORD PTR [rdi+0x10]
    14bc:	mov    rcx,QWORD PTR [rax+0xd0]
    14c3:	mov    rsi,r8
    14c6:	call   14cb <botlish_fn_9+0x2b3>
			14c7: R_X86_64_PLT32	rt_type_error-0x4
    14cb:	jmp    14e4 <botlish_fn_9+0x2cc>
    14d0:	mov    rdx,r8
    14d3:	mov    rdi,r13
    14d6:	call   14db <botlish_fn_9+0x2c3>
			14d7: R_X86_64_PLT32	rt_str_cat-0x4
    14db:	test   rax,rax
    14de:	jne    1509 <botlish_fn_9+0x2f1>
    14e4:	xor    rax,rax
    14e7:	mov    rbx,QWORD PTR [rsp+0x40]
    14ec:	mov    r12,QWORD PTR [rsp+0x48]
    14f1:	mov    r13,QWORD PTR [rsp+0x50]
    14f6:	mov    r14,QWORD PTR [rsp+0x58]
    14fb:	mov    r15,QWORD PTR [rsp+0x60]
    1500:	add    rsp,0x70
    1504:	mov    rsp,rbp
    1507:	pop    rbp
    1508:	ret
    1509:	mov    QWORD PTR [rsp],rbx
    150d:	mov    rcx,QWORD PTR [rsp+0x38]
    1512:	mov    QWORD PTR [rsp+0x8],rcx
    1517:	mov    QWORD PTR [rsp+0x10],rax
    151c:	mov    QWORD PTR [rsp+0x18],r12
    1521:	mov    rsi,rbx
    1524:	mov    r14,rax
    1527:	mov    QWORD PTR [rsp+0x30],rcx
    152c:	jmp    1263 <botlish_fn_9+0x4b>
    1531:	mov    rax,r14
    1534:	mov    rbx,QWORD PTR [rsp+0x40]
    1539:	mov    r12,QWORD PTR [rsp+0x48]
    153e:	mov    r13,QWORD PTR [rsp+0x50]
    1543:	mov    r14,QWORD PTR [rsp+0x58]
    1548:	mov    r15,QWORD PTR [rsp+0x60]
    154d:	add    rsp,0x70
    1551:	mov    rsp,rbp
    1554:	pop    rbp
    1555:	ret
    1556:	add    BYTE PTR [rax],al
    1558:	(bad)
    1559:	add    BYTE PTR [rax],al
    155b:	add    BYTE PTR [rax],al
    155d:	add    BYTE PTR [rax],al
	...

0000000000001560 <botlish_entry_9: esc_from<generic>>:
    1560:	push   rbp
    1561:	mov    rbp,rsp
    1564:	mov    rsi,QWORD PTR [rdx]
    1567:	mov    r9,QWORD PTR [rdx+0x8]
    156b:	mov    rcx,QWORD PTR [rdx+0x10]
    156f:	mov    r8,QWORD PTR [rdx+0x18]
    1573:	mov    rdx,r9
    1576:	call   157b <botlish_entry_9+0x1b>
			1577: R_X86_64_PLT32	botlish_fn_9-0x4 ; esc_from<generic>
    157b:	mov    rsp,rbp
    157e:	pop    rbp
    157f:	ret

0000000000001580 <botlish_fn_10: check<int, int, str, str>>:
    1580:	push   rbp
    1581:	mov    rbp,rsp
    1584:	sub    rsp,0x60
    1588:	mov    QWORD PTR [rsp+0x30],rbx
    158d:	mov    QWORD PTR [rsp+0x38],r12
    1592:	mov    QWORD PTR [rsp+0x40],r13
    1597:	mov    QWORD PTR [rsp+0x48],r14
    159c:	mov    QWORD PTR [rsp+0x50],r15
    15a1:	mov    QWORD PTR [rsp+0x20],0x0
    15aa:	mov    QWORD PTR [rsp],rsi
    15ae:	mov    QWORD PTR [rsp+0x8],rdx
    15b3:	mov    QWORD PTR [rsp+0x10],rcx
    15b8:	mov    r12,rcx
    15bb:	mov    QWORD PTR [rsp+0x18],r8
    15c0:	mov    r14,r8
    15c3:	mov    r13,rsi
    15c6:	mov    r15,rdx
    15c9:	test   r13,0x1
    15d0:	jne    15fb <botlish_fn_10+0x7b>
    15d6:	mov    edx,0x1
    15db:	mov    rbx,rdi
    15de:	mov    rsi,r13
    15e1:	call   15e6 <botlish_fn_10+0x66>
			15e2: R_X86_64_PLT32	rt_int_cmp-0x4
    15e6:	mov    ecx,0x2
    15eb:	test   rax,rax
    15ee:	cmovle rcx,QWORD PTR [rip+0x152]        # 1748 <botlish_fn_10+0x1c8>
    15f6:	jmp    160f <botlish_fn_10+0x8f>
    15fb:	mov    rbx,rdi
    15fe:	mov    ecx,0x2
    1603:	cmp    r13,0x1
    1607:	cmovle rcx,QWORD PTR [rip+0x139]        # 1748 <botlish_fn_10+0x1c8>
    160f:	cmp    rcx,0x6
    1613:	je     171c <botlish_fn_10+0x19c>
    1619:	mov    rax,QWORD PTR [rbx+0x10]
    161d:	mov    rax,QWORD PTR [rax+0xe8]
    1624:	mov    rsi,r12
    1627:	mov    rdi,rbx
    162a:	call   162f <botlish_fn_10+0xaf>
			162b: R_X86_64_PLT32	botlish_fn_11-0x4 ; <str>
    162f:	test   rax,rax
    1632:	je     1673 <botlish_fn_10+0xf3>
    1638:	cmp    rax,0x6
    163c:	je     1654 <botlish_fn_10+0xd4>
    1642:	mov    edx,0x1
    1647:	mov    QWORD PTR [rsp],0x1
    164f:	jmp    16b5 <botlish_fn_10+0x135>
    1654:	mov    rax,QWORD PTR [rbx+0x10]
    1658:	mov    rax,QWORD PTR [rax+0xf0]
    165f:	mov    rsi,r12
    1662:	mov    rdi,rbx
    1665:	call   166a <botlish_fn_10+0xea>
			1666: R_X86_64_PLT32	botlish_fn_19-0x4 ; <str>
    166a:	test   rax,rax
    166d:	jne    1698 <botlish_fn_10+0x118>
    1673:	xor    rax,rax
    1676:	mov    rbx,QWORD PTR [rsp+0x30]
    167b:	mov    r12,QWORD PTR [rsp+0x38]
    1680:	mov    r13,QWORD PTR [rsp+0x40]
    1685:	mov    r14,QWORD PTR [rsp+0x48]
    168a:	mov    r15,QWORD PTR [rsp+0x50]
    168f:	add    rsp,0x60
    1693:	mov    rsp,rbp
    1696:	pop    rbp
    1697:	ret
    1698:	cmp    rax,0x6
    169c:	je     16ac <botlish_fn_10+0x12c>
    16a2:	mov    edx,0x1
    16a7:	jmp    16b1 <botlish_fn_10+0x131>
    16ac:	mov    edx,0x3
    16b1:	mov    QWORD PTR [rsp],rdx
    16b5:	sar    r13,1
    16b8:	sub    r13,0x1
    16bc:	shl    r13,1
    16bf:	or     r13,0x1
    16c3:	mov    QWORD PTR [rsp+0x20],r13
    16c8:	mov    rsi,r15
    16cb:	mov    r8,rsi
    16ce:	and    r8,rdx
    16d1:	test   r8,0x1
    16d8:	je     16f3 <botlish_fn_10+0x173>
    16de:	lea    r11,[rdx-0x1]
    16e2:	mov    rax,rsi
    16e5:	add    rax,r11
    16e8:	seto   cl
    16eb:	test   cl,cl
    16ed:	je     16fb <botlish_fn_10+0x17b>
    16f3:	mov    rdi,rbx
    16f6:	call   16fb <botlish_fn_10+0x17b>
			16f7: R_X86_64_PLT32	rt_int_add-0x4
    16fb:	mov    QWORD PTR [rsp],r13
    16ff:	mov    QWORD PTR [rsp+0x8],rax
    1704:	mov    QWORD PTR [rsp+0x10],r12
    1709:	mov    r8,r14
    170c:	mov    QWORD PTR [rsp+0x18],r8
    1711:	mov    rdi,rbx
    1714:	mov    r15,rax
    1717:	jmp    15c9 <botlish_fn_10+0x49>
    171c:	mov    rax,r15
    171f:	mov    rbx,QWORD PTR [rsp+0x30]
    1724:	mov    r12,QWORD PTR [rsp+0x38]
    1729:	mov    r13,QWORD PTR [rsp+0x40]
    172e:	mov    r14,QWORD PTR [rsp+0x48]
    1733:	mov    r15,QWORD PTR [rsp+0x50]
    1738:	add    rsp,0x60
    173c:	mov    rsp,rbp
    173f:	pop    rbp
    1740:	ret
    1741:	add    BYTE PTR [rax],al
    1743:	add    BYTE PTR [rax],al
    1745:	add    BYTE PTR [rax],al
    1747:	add    BYTE PTR [rsi],al
    1749:	add    BYTE PTR [rax],al
    174b:	add    BYTE PTR [rax],al
    174d:	add    BYTE PTR [rax],al
	...

0000000000001750 <botlish_entry_10: check<int, int, str, str>>:
    1750:	push   rbp
    1751:	mov    rbp,rsp
    1754:	mov    rsi,QWORD PTR [rdx]
    1757:	mov    r9,QWORD PTR [rdx+0x8]
    175b:	mov    rcx,QWORD PTR [rdx+0x10]
    175f:	mov    r8,QWORD PTR [rdx+0x18]
    1763:	mov    rdx,r9
    1766:	call   176b <botlish_entry_10+0x1b>
			1767: R_X86_64_PLT32	botlish_fn_10-0x4 ; check<int, int, str, str>
    176b:	mov    rsp,rbp
    176e:	pop    rbp
    176f:	ret

0000000000001770 <botlish_fn_11: <str>>:
    1770:	push   rbp
    1771:	mov    rbp,rsp
    1774:	sub    rsp,0x50
    1778:	mov    QWORD PTR [rsp+0x30],rbx
    177d:	mov    QWORD PTR [rsp+0x38],r12
    1782:	mov    QWORD PTR [rsp+0x40],r13
    1787:	mov    QWORD PTR [rsp+0x48],r14
    178c:	mov    r13,rdi
    178f:	mov    QWORD PTR [rsp+0x18],0x0
    1798:	mov    QWORD PTR [rsp],rsi
    179c:	mov    r14,rsi
    179f:	mov    rsi,r14
    17a2:	mov    rdi,r13
    17a5:	call   17aa <botlish_fn_11+0x3a>
			17a6: R_X86_64_PLT32	rt_str_len-0x4
    17aa:	mov    rbx,rax
    17ad:	mov    QWORD PTR [rsp+0x8],rax
    17b2:	mov    esi,0x1
    17b7:	mov    QWORD PTR [rsp+0x10],0x1
    17c0:	mov    rcx,r14
    17c3:	mov    rdx,rbx
    17c6:	mov    rdi,r13
    17c9:	call   17ce <botlish_fn_11+0x5e>
			17ca: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_local<generic>
    17ce:	mov    r12,rax
    17d1:	test   r12,r12
    17d4:	je     1931 <botlish_fn_11+0x1c1>
    17da:	mov    QWORD PTR [rsp+0x10],r12
    17df:	test   r12,0x1
    17e6:	jne    1811 <botlish_fn_11+0xa1>
    17ec:	mov    edx,0x1
    17f1:	mov    rsi,r12
    17f4:	mov    rdi,r13
    17f7:	call   17fc <botlish_fn_11+0x8c>
			17f8: R_X86_64_PLT32	rt_int_cmp-0x4
    17fc:	mov    ecx,0x2
    1801:	test   rax,rax
    1804:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 19d0 <botlish_fn_11+0x260>
    180c:	jmp    1822 <botlish_fn_11+0xb2>
    1811:	mov    ecx,0x2
    1816:	cmp    r12,0x1
    181a:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 19d0 <botlish_fn_11+0x260>
    1822:	cmp    rcx,0x6
    1826:	je     19ac <botlish_fn_11+0x23c>
    182c:	mov    rcx,r12
    182f:	and    rcx,rbx
    1832:	test   rcx,0x1
    1839:	jne    1862 <botlish_fn_11+0xf2>
    183f:	mov    rdx,rbx
    1842:	mov    rsi,r12
    1845:	mov    rdi,r13
    1848:	call   184d <botlish_fn_11+0xdd>
			1849: R_X86_64_PLT32	rt_int_cmp-0x4
    184d:	mov    ecx,0x2
    1852:	test   rax,rax
    1855:	cmovge rcx,QWORD PTR [rip+0x173]        # 19d0 <botlish_fn_11+0x260>
    185d:	jmp    1872 <botlish_fn_11+0x102>
    1862:	mov    ecx,0x2
    1867:	cmp    r12,rbx
    186a:	cmovge rcx,QWORD PTR [rip+0x15e]        # 19d0 <botlish_fn_11+0x260>
    1872:	cmp    rcx,0x6
    1876:	je     19a2 <botlish_fn_11+0x232>
    187c:	lea    rcx,[rsp+0x20]
    1881:	mov    rdx,r14
    1884:	mov    rsi,r12
    1887:	mov    rdi,r13
    188a:	call   188f <botlish_fn_11+0x11f>
			188b: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    188f:	test   rax,rax
    1892:	mov    rsi,rax
    1895:	je     1931 <botlish_fn_11+0x1c1>
    189b:	mov    rdx,QWORD PTR [rsp+0x20]
    18a0:	mov    rcx,QWORD PTR [rsp+0x28]
    18a5:	mov    rdi,r13
    18a8:	mov    rax,QWORD PTR [rdi+0x10]
    18ac:	mov    r8,QWORD PTR [rax+0x108]
    18b3:	call   18b8 <botlish_fn_11+0x148>
			18b4: R_X86_64_PLT32	rt_str_region_eq-0x4
    18b8:	cmp    rax,0x6
    18bc:	je     18cf <botlish_fn_11+0x15f>
    18c2:	mov    ecx,0x2
    18c7:	mov    rax,rcx
    18ca:	jmp    19b1 <botlish_fn_11+0x241>
    18cf:	mov    QWORD PTR [rsp+0x18],0x3
    18d8:	test   r12,0x1
    18df:	jne    18ed <botlish_fn_11+0x17d>
    18e5:	mov    rcx,r12
    18e8:	jmp    1902 <botlish_fn_11+0x192>
    18ed:	mov    rsi,r12
    18f0:	add    rsi,0x2
    18f4:	mov    rcx,r12
    18f7:	seto   al
    18fa:	test   al,al
    18fc:	je     1915 <botlish_fn_11+0x1a5>
    1902:	mov    edx,0x3
    1907:	mov    rsi,rcx
    190a:	mov    rdi,r13
    190d:	call   1912 <botlish_fn_11+0x1a2>
			190e: R_X86_64_PLT32	rt_int_add-0x4
    1912:	mov    rsi,rax
    1915:	mov    QWORD PTR [rsp+0x10],rsi
    191a:	mov    rcx,r14
    191d:	mov    rdx,rbx
    1920:	mov    rdi,r13
    1923:	call   1928 <botlish_fn_11+0x1b8>
			1924: R_X86_64_PLT32	botlish_fn_18-0x4 ; domain_loop<generic>
    1928:	test   rax,rax
    192b:	jne    1951 <botlish_fn_11+0x1e1>
    1931:	xor    rax,rax
    1934:	mov    rbx,QWORD PTR [rsp+0x30]
    1939:	mov    r12,QWORD PTR [rsp+0x38]
    193e:	mov    r13,QWORD PTR [rsp+0x40]
    1943:	mov    r14,QWORD PTR [rsp+0x48]
    1948:	add    rsp,0x50
    194c:	mov    rsp,rbp
    194f:	pop    rbp
    1950:	ret
    1951:	mov    rcx,rax
    1954:	and    rcx,rbx
    1957:	mov    rsi,rax
    195a:	test   rcx,0x1
    1961:	jne    198a <botlish_fn_11+0x21a>
    1967:	mov    rdx,rbx
    196a:	mov    rdi,r13
    196d:	call   1972 <botlish_fn_11+0x202>
			196e: R_X86_64_PLT32	rt_int_cmp-0x4
    1972:	mov    ecx,0x2
    1977:	test   rax,rax
    197a:	mov    rax,rcx
    197d:	cmove  rax,QWORD PTR [rip+0x4b]        # 19d0 <botlish_fn_11+0x260>
    1985:	jmp    19b1 <botlish_fn_11+0x241>
    198a:	mov    rdx,rbx
    198d:	mov    eax,0x2
    1992:	cmp    rsi,rdx
    1995:	cmove  rax,QWORD PTR [rip+0x33]        # 19d0 <botlish_fn_11+0x260>
    199d:	jmp    19b1 <botlish_fn_11+0x241>
    19a2:	mov    eax,0x2
    19a7:	jmp    19b1 <botlish_fn_11+0x241>
    19ac:	mov    eax,0x2
    19b1:	mov    rbx,QWORD PTR [rsp+0x30]
    19b6:	mov    r12,QWORD PTR [rsp+0x38]
    19bb:	mov    r13,QWORD PTR [rsp+0x40]
    19c0:	mov    r14,QWORD PTR [rsp+0x48]
    19c5:	add    rsp,0x50
    19c9:	mov    rsp,rbp
    19cc:	pop    rbp
    19cd:	ret
    19ce:	add    BYTE PTR [rax],al
    19d0:	(bad)
    19d1:	add    BYTE PTR [rax],al
    19d3:	add    BYTE PTR [rax],al
    19d5:	add    BYTE PTR [rax],al
	...

00000000000019d8 <botlish_entry_11: <str>>:
    19d8:	push   rbp
    19d9:	mov    rbp,rsp
    19dc:	mov    rsi,QWORD PTR [rdx]
    19df:	call   19e4 <botlish_entry_11+0xc>
			19e0: R_X86_64_PLT32	botlish_fn_11-0x4 ; <str>
    19e4:	mov    rsp,rbp
    19e7:	pop    rbp
    19e8:	ret
    19e9:	add    BYTE PTR [rax],al
    19eb:	add    BYTE PTR [rax],al
    19ed:	add    BYTE PTR [rax],al
	...

00000000000019f0 <botlish_fn_12: <generic>>:
    19f0:	push   rbp
    19f1:	mov    rbp,rsp
    19f4:	sub    rsp,0x60
    19f8:	mov    QWORD PTR [rsp+0x30],rbx
    19fd:	mov    QWORD PTR [rsp+0x38],r12
    1a02:	mov    QWORD PTR [rsp+0x40],r13
    1a07:	mov    QWORD PTR [rsp+0x48],r14
    1a0c:	mov    QWORD PTR [rsp+0x50],r15
    1a11:	mov    QWORD PTR [rsp+0x18],0x0
    1a1a:	mov    QWORD PTR [rsp],rsi
    1a1e:	xor    r8d,r8d
    1a21:	test   rsi,0x7
    1a28:	jne    1a38 <botlish_fn_12+0x48>
    1a2e:	movzx  rax,BYTE PTR [rsi]
    1a32:	cmp    al,0x2
    1a34:	sete   r8b
    1a38:	test   r8b,r8b
    1a3b:	jne    1a5b <botlish_fn_12+0x6b>
    1a41:	mov    rdx,QWORD PTR [rdi+0x10]
    1a45:	mov    rcx,QWORD PTR [rdx+0xe0]
    1a4c:	mov    edx,0x1
    1a51:	call   1a56 <botlish_fn_12+0x66>
			1a52: R_X86_64_PLT32	rt_type_error-0x4
    1a56:	jmp    1bf0 <botlish_fn_12+0x200>
    1a5b:	mov    r13,rsi
    1a5e:	mov    r14,rdi
    1a61:	call   1a66 <botlish_fn_12+0x76>
			1a62: R_X86_64_PLT32	rt_str_len-0x4
    1a66:	mov    rbx,rax
    1a69:	mov    QWORD PTR [rsp+0x8],rax
    1a6e:	mov    edx,0x1
    1a73:	mov    r15,rdx
    1a76:	mov    QWORD PTR [rsp+0x10],0x1
    1a7f:	mov    rcx,r13
    1a82:	mov    rdx,rbx
    1a85:	mov    rsi,r15
    1a88:	mov    rdi,r14
    1a8b:	call   1a90 <botlish_fn_12+0xa0>
			1a8c: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_local<generic>
    1a90:	mov    r12,rax
    1a93:	test   r12,r12
    1a96:	je     1bf0 <botlish_fn_12+0x200>
    1a9c:	mov    QWORD PTR [rsp+0x10],r12
    1aa1:	test   r12,0x1
    1aa8:	jne    1ad1 <botlish_fn_12+0xe1>
    1aae:	mov    rdx,r15
    1ab1:	mov    rsi,r12
    1ab4:	mov    rdi,r14
    1ab7:	call   1abc <botlish_fn_12+0xcc>
			1ab8: R_X86_64_PLT32	rt_int_cmp-0x4
    1abc:	mov    ecx,0x2
    1ac1:	test   rax,rax
    1ac4:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 1c98 <botlish_fn_12+0x2a8>
    1acc:	jmp    1ae2 <botlish_fn_12+0xf2>
    1ad1:	mov    ecx,0x2
    1ad6:	cmp    r12,0x1
    1ada:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 1c98 <botlish_fn_12+0x2a8>
    1ae2:	cmp    rcx,0x6
    1ae6:	je     1c70 <botlish_fn_12+0x280>
    1aec:	mov    rax,r12
    1aef:	and    rax,rbx
    1af2:	test   rax,0x1
    1af8:	jne    1b21 <botlish_fn_12+0x131>
    1afe:	mov    rdx,rbx
    1b01:	mov    rsi,r12
    1b04:	mov    rdi,r14
    1b07:	call   1b0c <botlish_fn_12+0x11c>
			1b08: R_X86_64_PLT32	rt_int_cmp-0x4
    1b0c:	mov    ecx,0x2
    1b11:	test   rax,rax
    1b14:	cmovge rcx,QWORD PTR [rip+0x17c]        # 1c98 <botlish_fn_12+0x2a8>
    1b1c:	jmp    1b31 <botlish_fn_12+0x141>
    1b21:	mov    ecx,0x2
    1b26:	cmp    r12,rbx
    1b29:	cmovge rcx,QWORD PTR [rip+0x167]        # 1c98 <botlish_fn_12+0x2a8>
    1b31:	cmp    rcx,0x6
    1b35:	je     1c66 <botlish_fn_12+0x276>
    1b3b:	lea    rcx,[rsp+0x20]
    1b40:	mov    rdx,r13
    1b43:	mov    rsi,r12
    1b46:	mov    rdi,r14
    1b49:	call   1b4e <botlish_fn_12+0x15e>
			1b4a: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    1b4e:	test   rax,rax
    1b51:	mov    rsi,rax
    1b54:	je     1bf0 <botlish_fn_12+0x200>
    1b5a:	mov    rdx,QWORD PTR [rsp+0x20]
    1b5f:	mov    rcx,QWORD PTR [rsp+0x28]
    1b64:	mov    rdi,r14
    1b67:	mov    rax,QWORD PTR [rdi+0x10]
    1b6b:	mov    r8,QWORD PTR [rax+0x108]
    1b72:	call   1b77 <botlish_fn_12+0x187>
			1b73: R_X86_64_PLT32	rt_str_region_eq-0x4
    1b77:	cmp    rax,0x6
    1b7b:	je     1b8e <botlish_fn_12+0x19e>
    1b81:	mov    ecx,0x2
    1b86:	mov    rax,rcx
    1b89:	jmp    1c75 <botlish_fn_12+0x285>
    1b8e:	mov    QWORD PTR [rsp+0x18],0x3
    1b97:	test   r12,0x1
    1b9e:	jne    1bac <botlish_fn_12+0x1bc>
    1ba4:	mov    rdi,r12
    1ba7:	jmp    1bc1 <botlish_fn_12+0x1d1>
    1bac:	mov    rsi,r12
    1baf:	add    rsi,0x2
    1bb3:	mov    rdi,r12
    1bb6:	seto   al
    1bb9:	test   al,al
    1bbb:	je     1bd4 <botlish_fn_12+0x1e4>
    1bc1:	mov    edx,0x3
    1bc6:	mov    rsi,rdi
    1bc9:	mov    rdi,r14
    1bcc:	call   1bd1 <botlish_fn_12+0x1e1>
			1bcd: R_X86_64_PLT32	rt_int_add-0x4
    1bd1:	mov    rsi,rax
    1bd4:	mov    QWORD PTR [rsp+0x10],rsi
    1bd9:	mov    rcx,r13
    1bdc:	mov    rdx,rbx
    1bdf:	mov    rdi,r14
    1be2:	call   1be7 <botlish_fn_12+0x1f7>
			1be3: R_X86_64_PLT32	botlish_fn_18-0x4 ; domain_loop<generic>
    1be7:	test   rax,rax
    1bea:	jne    1c15 <botlish_fn_12+0x225>
    1bf0:	xor    rax,rax
    1bf3:	mov    rbx,QWORD PTR [rsp+0x30]
    1bf8:	mov    r12,QWORD PTR [rsp+0x38]
    1bfd:	mov    r13,QWORD PTR [rsp+0x40]
    1c02:	mov    r14,QWORD PTR [rsp+0x48]
    1c07:	mov    r15,QWORD PTR [rsp+0x50]
    1c0c:	add    rsp,0x60
    1c10:	mov    rsp,rbp
    1c13:	pop    rbp
    1c14:	ret
    1c15:	mov    rcx,rax
    1c18:	and    rcx,rbx
    1c1b:	mov    rsi,rax
    1c1e:	test   rcx,0x1
    1c25:	jne    1c4e <botlish_fn_12+0x25e>
    1c2b:	mov    rdx,rbx
    1c2e:	mov    rdi,r14
    1c31:	call   1c36 <botlish_fn_12+0x246>
			1c32: R_X86_64_PLT32	rt_int_cmp-0x4
    1c36:	mov    ecx,0x2
    1c3b:	test   rax,rax
    1c3e:	mov    rax,rcx
    1c41:	cmove  rax,QWORD PTR [rip+0x4f]        # 1c98 <botlish_fn_12+0x2a8>
    1c49:	jmp    1c75 <botlish_fn_12+0x285>
    1c4e:	mov    rdx,rbx
    1c51:	mov    eax,0x2
    1c56:	cmp    rsi,rdx
    1c59:	cmove  rax,QWORD PTR [rip+0x37]        # 1c98 <botlish_fn_12+0x2a8>
    1c61:	jmp    1c75 <botlish_fn_12+0x285>
    1c66:	mov    eax,0x2
    1c6b:	jmp    1c75 <botlish_fn_12+0x285>
    1c70:	mov    eax,0x2
    1c75:	mov    rbx,QWORD PTR [rsp+0x30]
    1c7a:	mov    r12,QWORD PTR [rsp+0x38]
    1c7f:	mov    r13,QWORD PTR [rsp+0x40]
    1c84:	mov    r14,QWORD PTR [rsp+0x48]
    1c89:	mov    r15,QWORD PTR [rsp+0x50]
    1c8e:	add    rsp,0x60
    1c92:	mov    rsp,rbp
    1c95:	pop    rbp
    1c96:	ret
    1c97:	add    BYTE PTR [rsi],al
    1c99:	add    BYTE PTR [rax],al
    1c9b:	add    BYTE PTR [rax],al
    1c9d:	add    BYTE PTR [rax],al
	...

0000000000001ca0 <botlish_entry_12: <generic>>:
    1ca0:	push   rbp
    1ca1:	mov    rbp,rsp
    1ca4:	mov    rsi,QWORD PTR [rdx]
    1ca7:	call   1cac <botlish_entry_12+0xc>
			1ca8: R_X86_64_PLT32	botlish_fn_12-0x4 ; <generic>
    1cac:	mov    rsp,rbp
    1caf:	pop    rbp
    1cb0:	ret

0000000000001cb1 <botlish_fn_13: char_at<generic>>:
    1cb1:	push   rbp
    1cb2:	mov    rbp,rsp
    1cb5:	sub    rsp,0x50
    1cb9:	mov    QWORD PTR [rsp+0x20],rbx
    1cbe:	mov    QWORD PTR [rsp+0x28],r12
    1cc3:	mov    QWORD PTR [rsp+0x30],r13
    1cc8:	mov    QWORD PTR [rsp+0x38],r14
    1ccd:	mov    QWORD PTR [rsp+0x40],r15
    1cd2:	mov    r14,rcx
    1cd5:	mov    QWORD PTR [rsp],rsi
    1cd9:	mov    QWORD PTR [rsp+0x8],rdx
    1cde:	mov    r13,rdx
    1ce1:	mov    QWORD PTR [rsp+0x10],0x3
    1cea:	mov    r9d,0x1
    1cf0:	test   rsi,0x1
    1cf7:	jne    1d17 <botlish_fn_13+0x66>
    1cfd:	xor    r9d,r9d
    1d00:	test   rsi,0x7
    1d07:	jne    1d17 <botlish_fn_13+0x66>
    1d0d:	movzx  rax,BYTE PTR [rsi]
    1d11:	cmp    al,0x1
    1d13:	sete   r9b
    1d17:	test   r9b,r9b
    1d1a:	jne    1d38 <botlish_fn_13+0x87>
    1d20:	mov    rax,QWORD PTR [rdi+0x10]
    1d24:	mov    rcx,QWORD PTR [rax+0x110]
    1d2b:	xor    rdx,rdx
    1d2e:	call   1d33 <botlish_fn_13+0x82>
			1d2f: R_X86_64_PLT32	rt_type_error-0x4
    1d33:	jmp    1df5 <botlish_fn_13+0x144>
    1d38:	mov    r12,rdi
    1d3b:	test   rsi,0x1
    1d42:	jne    1d50 <botlish_fn_13+0x9f>
    1d48:	mov    rbx,rsi
    1d4b:	jmp    1d6d <botlish_fn_13+0xbc>
    1d50:	mov    rax,rsi
    1d53:	add    rax,0x2
    1d57:	mov    rbx,rsi
    1d5a:	seto   cl
    1d5d:	test   cl,cl
    1d5f:	jne    1d6d <botlish_fn_13+0xbc>
    1d65:	mov    r15,rax
    1d68:	jmp    1d80 <botlish_fn_13+0xcf>
    1d6d:	mov    edx,0x3
    1d72:	mov    rsi,rbx
    1d75:	mov    rdi,r12
    1d78:	call   1d7d <botlish_fn_13+0xcc>
			1d79: R_X86_64_PLT32	rt_int_add-0x4
    1d7d:	mov    r15,rax
    1d80:	mov    ecx,0x1
    1d85:	mov    rsi,rbx
    1d88:	test   rsi,0x1
    1d8f:	jne    1db5 <botlish_fn_13+0x104>
    1d95:	xor    ecx,ecx
    1d97:	mov    rsi,rbx
    1d9a:	test   rsi,0x7
    1da1:	jne    1db5 <botlish_fn_13+0x104>
    1da7:	mov    rsi,rbx
    1daa:	movzx  rcx,BYTE PTR [rsi]
    1dae:	rex cmp cl,0x1
    1db2:	sete   cl
    1db5:	test   cl,cl
    1db7:	jne    1ddb <botlish_fn_13+0x12a>
    1dbd:	mov    rdi,r12
    1dc0:	mov    rsi,QWORD PTR [rdi+0x10]
    1dc4:	mov    rcx,QWORD PTR [rsi+0x118]
    1dcb:	xor    rdx,rdx
    1dce:	mov    rsi,rbx
    1dd1:	call   1dd6 <botlish_fn_13+0x125>
			1dd2: R_X86_64_PLT32	rt_type_error-0x4
    1dd6:	jmp    1df5 <botlish_fn_13+0x144>
    1ddb:	mov    rdi,r12
    1dde:	mov    rcx,r15
    1de1:	mov    rdx,rbx
    1de4:	mov    rsi,r13
    1de7:	call   1dec <botlish_fn_13+0x13b>
			1de8: R_X86_64_PLT32	rt_str_region_check-0x4
    1dec:	test   rax,rax
    1def:	jne    1e1a <botlish_fn_13+0x169>
    1df5:	xor    rax,rax
    1df8:	mov    rbx,QWORD PTR [rsp+0x20]
    1dfd:	mov    r12,QWORD PTR [rsp+0x28]
    1e02:	mov    r13,QWORD PTR [rsp+0x30]
    1e07:	mov    r14,QWORD PTR [rsp+0x38]
    1e0c:	mov    r15,QWORD PTR [rsp+0x40]
    1e11:	add    rsp,0x50
    1e15:	mov    rsp,rbp
    1e18:	pop    rbp
    1e19:	ret
    1e1a:	mov    rcx,r14
    1e1d:	mov    rsi,rbx
    1e20:	mov    QWORD PTR [rcx],rsi
    1e23:	mov    rax,r15
    1e26:	mov    QWORD PTR [rcx+0x8],rax
    1e2a:	mov    rax,r13
    1e2d:	mov    rbx,QWORD PTR [rsp+0x20]
    1e32:	mov    r12,QWORD PTR [rsp+0x28]
    1e37:	mov    r13,QWORD PTR [rsp+0x30]
    1e3c:	mov    r14,QWORD PTR [rsp+0x38]
    1e41:	mov    r15,QWORD PTR [rsp+0x40]
    1e46:	add    rsp,0x50
    1e4a:	mov    rsp,rbp
    1e4d:	pop    rbp
    1e4e:	ret

0000000000001e4f <botlish_entry_13: char_at<generic>>:
    1e4f:	push   rbp
    1e50:	mov    rbp,rsp
    1e53:	ud2
    1e55:	add    BYTE PTR [rax],al
	...

0000000000001e58 <botlish_fn_14: scan_local<generic>>:
    1e58:	push   rbp
    1e59:	mov    rbp,rsp
    1e5c:	sub    rsp,0x80
    1e63:	mov    QWORD PTR [rsp+0x50],rbx
    1e68:	mov    QWORD PTR [rsp+0x58],r12
    1e6d:	mov    QWORD PTR [rsp+0x60],r13
    1e72:	mov    QWORD PTR [rsp+0x68],r14
    1e77:	mov    QWORD PTR [rsp+0x70],r15
    1e7c:	mov    rax,rdi
    1e7f:	mov    QWORD PTR [rsp+0x18],0x0
    1e88:	mov    QWORD PTR [rsp],rsi
    1e8c:	mov    r14,rsi
    1e8f:	mov    QWORD PTR [rsp+0x8],rdx
    1e94:	mov    QWORD PTR [rsp+0x10],rcx
    1e99:	mov    r12,rcx
    1e9c:	mov    r11d,0x1
    1ea2:	mov    rsi,r14
    1ea5:	test   rsi,0x1
    1eac:	jne    1ece <botlish_fn_14+0x76>
    1eb2:	xor    r11d,r11d
    1eb5:	test   rsi,0x7
    1ebc:	jne    1ece <botlish_fn_14+0x76>
    1ec2:	movzx  rdi,BYTE PTR [rsi]
    1ec6:	cmp    dil,0x1
    1eca:	sete   r11b
    1ece:	test   r11b,r11b
    1ed1:	jne    1ef2 <botlish_fn_14+0x9a>
    1ed7:	mov    rdi,rax
    1eda:	mov    r9,QWORD PTR [rdi+0x10]
    1ede:	mov    rcx,QWORD PTR [r9+0xc0]
    1ee5:	xor    rdx,rdx
    1ee8:	call   1eed <botlish_fn_14+0x95>
			1ee9: R_X86_64_PLT32	rt_type_error-0x4
    1eed:	jmp    1fa5 <botlish_fn_14+0x14d>
    1ef2:	mov    r13,rdx
    1ef5:	mov    r10,rsi
    1ef8:	and    r10,r13
    1efb:	mov    r14,rsi
    1efe:	test   r10,0x1
    1f05:	jne    1f31 <botlish_fn_14+0xd9>
    1f0b:	mov    rbx,rax
    1f0e:	mov    rdx,r13
    1f11:	mov    rsi,r14
    1f14:	mov    rdi,rbx
    1f17:	call   1f1c <botlish_fn_14+0xc4>
			1f18: R_X86_64_PLT32	rt_int_cmp-0x4
    1f1c:	mov    ecx,0x2
    1f21:	test   rax,rax
    1f24:	cmovge rcx,QWORD PTR [rip+0x24c]        # 2178 <botlish_fn_14+0x320>
    1f2c:	jmp    1f47 <botlish_fn_14+0xef>
    1f31:	mov    rbx,rax
    1f34:	mov    ecx,0x2
    1f39:	mov    rsi,r14
    1f3c:	cmp    rsi,r13
    1f3f:	cmovge rcx,QWORD PTR [rip+0x231]        # 2178 <botlish_fn_14+0x320>
    1f47:	mov    eax,0x6
    1f4c:	mov    QWORD PTR [rsp+0x30],rax
    1f51:	cmp    rcx,0x6
    1f55:	je     214b <botlish_fn_14+0x2f3>
    1f5b:	lea    rcx,[rsp+0x20]
    1f60:	mov    rdx,r12
    1f63:	mov    rsi,r14
    1f66:	mov    rdi,rbx
    1f69:	call   1f6e <botlish_fn_14+0x116>
			1f6a: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    1f6e:	mov    rsi,rax
    1f71:	mov    r15,rax
    1f74:	test   rax,rsi
    1f77:	je     1fa5 <botlish_fn_14+0x14d>
    1f7d:	mov    rdx,QWORD PTR [rsp+0x20]
    1f82:	mov    QWORD PTR [rsp+0x40],rdx
    1f87:	mov    rcx,QWORD PTR [rsp+0x28]
    1f8c:	mov    QWORD PTR [rsp+0x38],rcx
    1f91:	mov    rsi,r15
    1f94:	mov    rdi,rbx
    1f97:	call   1f9c <botlish_fn_14+0x144>
			1f98: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1f9c:	test   rax,rax
    1f9f:	jne    1fcd <botlish_fn_14+0x175>
    1fa5:	xor    rax,rax
    1fa8:	mov    rbx,QWORD PTR [rsp+0x50]
    1fad:	mov    r12,QWORD PTR [rsp+0x58]
    1fb2:	mov    r13,QWORD PTR [rsp+0x60]
    1fb7:	mov    r14,QWORD PTR [rsp+0x68]
    1fbc:	mov    r15,QWORD PTR [rsp+0x70]
    1fc1:	add    rsp,0x80
    1fc8:	mov    rsp,rbp
    1fcb:	pop    rbp
    1fcc:	ret
    1fcd:	cmp    rax,0x6
    1fd1:	je     20cc <botlish_fn_14+0x274>
    1fd7:	mov    rax,QWORD PTR [rbx+0x10]
    1fdb:	mov    r8,QWORD PTR [rax+0x120]
    1fe2:	mov    rcx,QWORD PTR [rsp+0x38]
    1fe7:	mov    rdx,QWORD PTR [rsp+0x40]
    1fec:	mov    rsi,r15
    1fef:	mov    rdi,rbx
    1ff2:	call   1ff7 <botlish_fn_14+0x19f>
			1ff3: R_X86_64_PLT32	rt_str_region_eq-0x4
    1ff7:	cmp    rax,0x6
    1ffb:	je     20c2 <botlish_fn_14+0x26a>
    2001:	mov    rax,QWORD PTR [rbx+0x10]
    2005:	mov    r8,QWORD PTR [rax+0x128]
    200c:	mov    rcx,QWORD PTR [rsp+0x38]
    2011:	mov    rdx,QWORD PTR [rsp+0x40]
    2016:	mov    rsi,r15
    2019:	mov    rdi,rbx
    201c:	call   2021 <botlish_fn_14+0x1c9>
			201d: R_X86_64_PLT32	rt_str_region_eq-0x4
    2021:	cmp    rax,0x6
    2025:	je     20b8 <botlish_fn_14+0x260>
    202b:	mov    rax,QWORD PTR [rbx+0x10]
    202f:	mov    r8,QWORD PTR [rax+0xc8]
    2036:	mov    rcx,QWORD PTR [rsp+0x38]
    203b:	mov    rdx,QWORD PTR [rsp+0x40]
    2040:	mov    rsi,r15
    2043:	mov    rdi,rbx
    2046:	call   204b <botlish_fn_14+0x1f3>
			2047: R_X86_64_PLT32	rt_str_region_eq-0x4
    204b:	cmp    rax,0x6
    204f:	je     20ae <botlish_fn_14+0x256>
    2055:	mov    rax,QWORD PTR [rbx+0x10]
    2059:	mov    r8,QWORD PTR [rax+0x110]
    2060:	mov    rcx,QWORD PTR [rsp+0x38]
    2065:	mov    rdx,QWORD PTR [rsp+0x40]
    206a:	mov    rsi,r15
    206d:	mov    rdi,rbx
    2070:	call   2075 <botlish_fn_14+0x21d>
			2071: R_X86_64_PLT32	rt_str_region_eq-0x4
    2075:	cmp    rax,0x6
    2079:	je     20a4 <botlish_fn_14+0x24c>
    207f:	mov    rax,QWORD PTR [rbx+0x10]
    2083:	mov    r8,QWORD PTR [rax+0x130]
    208a:	mov    rcx,QWORD PTR [rsp+0x38]
    208f:	mov    rdx,QWORD PTR [rsp+0x40]
    2094:	mov    rsi,r15
    2097:	mov    rdi,rbx
    209a:	call   209f <botlish_fn_14+0x247>
			209b: R_X86_64_PLT32	rt_str_region_eq-0x4
    209f:	jmp    20d1 <botlish_fn_14+0x279>
    20a4:	mov    rax,QWORD PTR [rsp+0x30]
    20a9:	jmp    20d1 <botlish_fn_14+0x279>
    20ae:	mov    rax,QWORD PTR [rsp+0x30]
    20b3:	jmp    20d1 <botlish_fn_14+0x279>
    20b8:	mov    rax,QWORD PTR [rsp+0x30]
    20bd:	jmp    20d1 <botlish_fn_14+0x279>
    20c2:	mov    rax,QWORD PTR [rsp+0x30]
    20c7:	jmp    20d1 <botlish_fn_14+0x279>
    20cc:	mov    rax,QWORD PTR [rsp+0x30]
    20d1:	cmp    rax,0x6
    20d5:	je     20e3 <botlish_fn_14+0x28b>
    20db:	mov    rax,r14
    20de:	jmp    214e <botlish_fn_14+0x2f6>
    20e3:	mov    QWORD PTR [rsp+0x18],0x3
    20ec:	mov    rsi,r14
    20ef:	test   rsi,0x1
    20f6:	je     211c <botlish_fn_14+0x2c4>
    20fc:	mov    rsi,r14
    20ff:	mov    rax,rsi
    2102:	add    rax,0x2
    2106:	seto   cl
    2109:	test   cl,cl
    210b:	jne    211c <botlish_fn_14+0x2c4>
    2111:	mov    rsi,rax
    2114:	mov    r14,rax
    2117:	jmp    2132 <botlish_fn_14+0x2da>
    211c:	mov    edx,0x3
    2121:	mov    rsi,r14
    2124:	mov    rdi,rbx
    2127:	call   212c <botlish_fn_14+0x2d4>
			2128: R_X86_64_PLT32	rt_int_add-0x4
    212c:	mov    rsi,rax
    212f:	mov    r14,rax
    2132:	mov    QWORD PTR [rsp],rsi
    2136:	mov    QWORD PTR [rsp+0x8],r13
    213b:	mov    QWORD PTR [rsp+0x10],r12
    2140:	mov    rax,rbx
    2143:	mov    rdx,r13
    2146:	jmp    1e9c <botlish_fn_14+0x44>
    214b:	mov    rax,r14
    214e:	mov    rbx,QWORD PTR [rsp+0x50]
    2153:	mov    r12,QWORD PTR [rsp+0x58]
    2158:	mov    r13,QWORD PTR [rsp+0x60]
    215d:	mov    r14,QWORD PTR [rsp+0x68]
    2162:	mov    r15,QWORD PTR [rsp+0x70]
    2167:	add    rsp,0x80
    216e:	mov    rsp,rbp
    2171:	pop    rbp
    2172:	ret
    2173:	add    BYTE PTR [rax],al
    2175:	add    BYTE PTR [rax],al
    2177:	add    BYTE PTR [rsi],al
    2179:	add    BYTE PTR [rax],al
    217b:	add    BYTE PTR [rax],al
    217d:	add    BYTE PTR [rax],al
	...

0000000000002180 <botlish_entry_14: scan_local<generic>>:
    2180:	push   rbp
    2181:	mov    rbp,rsp
    2184:	mov    rsi,QWORD PTR [rdx]
    2187:	mov    r8,QWORD PTR [rdx+0x8]
    218b:	mov    rcx,QWORD PTR [rdx+0x10]
    218f:	mov    rdx,r8
    2192:	call   2197 <botlish_entry_14+0x17>
			2193: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_local<generic>
    2197:	mov    rsp,rbp
    219a:	pop    rbp
    219b:	ret
    219c:	add    BYTE PTR [rax],al
	...

00000000000021a0 <botlish_fn_15: scan_label<generic>>:
    21a0:	push   rbp
    21a1:	mov    rbp,rsp
    21a4:	sub    rsp,0x80
    21ab:	mov    QWORD PTR [rsp+0x50],rbx
    21b0:	mov    QWORD PTR [rsp+0x58],r12
    21b5:	mov    QWORD PTR [rsp+0x60],r13
    21ba:	mov    QWORD PTR [rsp+0x68],r14
    21bf:	mov    QWORD PTR [rsp+0x70],r15
    21c4:	mov    QWORD PTR [rsp+0x18],0x0
    21cd:	mov    QWORD PTR [rsp],rsi
    21d1:	mov    r14,rsi
    21d4:	mov    QWORD PTR [rsp+0x8],rdx
    21d9:	mov    QWORD PTR [rsp+0x10],rcx
    21de:	mov    r12,rcx
    21e1:	mov    r11d,0x1
    21e7:	mov    rsi,r14
    21ea:	test   rsi,0x1
    21f1:	jne    2211 <botlish_fn_15+0x71>
    21f7:	xor    r11d,r11d
    21fa:	test   rsi,0x7
    2201:	jne    2211 <botlish_fn_15+0x71>
    2207:	movzx  rax,BYTE PTR [rsi]
    220b:	cmp    al,0x1
    220d:	sete   r11b
    2211:	test   r11b,r11b
    2214:	jne    2232 <botlish_fn_15+0x92>
    221a:	mov    rax,QWORD PTR [rdi+0x10]
    221e:	mov    rcx,QWORD PTR [rax+0xc0]
    2225:	xor    rdx,rdx
    2228:	call   222d <botlish_fn_15+0x8d>
			2229: R_X86_64_PLT32	rt_type_error-0x4
    222d:	jmp    22de <botlish_fn_15+0x13e>
    2232:	mov    r13,rdx
    2235:	mov    rax,rsi
    2238:	and    rax,r13
    223b:	mov    r14,rsi
    223e:	test   rax,0x1
    2244:	jne    226d <botlish_fn_15+0xcd>
    224a:	mov    rbx,rdi
    224d:	mov    rdx,r13
    2250:	mov    rsi,r14
    2253:	call   2258 <botlish_fn_15+0xb8>
			2254: R_X86_64_PLT32	rt_int_cmp-0x4
    2258:	mov    ecx,0x2
    225d:	test   rax,rax
    2260:	cmovge rcx,QWORD PTR [rip+0x178]        # 23e0 <botlish_fn_15+0x240>
    2268:	jmp    2283 <botlish_fn_15+0xe3>
    226d:	mov    rbx,rdi
    2270:	mov    ecx,0x2
    2275:	mov    rsi,r14
    2278:	cmp    rsi,r13
    227b:	cmovge rcx,QWORD PTR [rip+0x15d]        # 23e0 <botlish_fn_15+0x240>
    2283:	mov    eax,0x6
    2288:	mov    QWORD PTR [rsp+0x30],rax
    228d:	cmp    rcx,0x6
    2291:	je     23b4 <botlish_fn_15+0x214>
    2297:	lea    rcx,[rsp+0x20]
    229c:	mov    rdx,r12
    229f:	mov    rsi,r14
    22a2:	mov    rdi,rbx
    22a5:	call   22aa <botlish_fn_15+0x10a>
			22a6: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    22aa:	test   rax,rax
    22ad:	mov    r15,rax
    22b0:	je     22de <botlish_fn_15+0x13e>
    22b6:	mov    rdx,QWORD PTR [rsp+0x20]
    22bb:	mov    QWORD PTR [rsp+0x40],rdx
    22c0:	mov    rcx,QWORD PTR [rsp+0x28]
    22c5:	mov    QWORD PTR [rsp+0x38],rcx
    22ca:	mov    rsi,r15
    22cd:	mov    rdi,rbx
    22d0:	call   22d5 <botlish_fn_15+0x135>
			22d1: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    22d5:	test   rax,rax
    22d8:	jne    2306 <botlish_fn_15+0x166>
    22de:	xor    rax,rax
    22e1:	mov    rbx,QWORD PTR [rsp+0x50]
    22e6:	mov    r12,QWORD PTR [rsp+0x58]
    22eb:	mov    r13,QWORD PTR [rsp+0x60]
    22f0:	mov    r14,QWORD PTR [rsp+0x68]
    22f5:	mov    r15,QWORD PTR [rsp+0x70]
    22fa:	add    rsp,0x80
    2301:	mov    rsp,rbp
    2304:	pop    rbp
    2305:	ret
    2306:	cmp    rax,0x6
    230a:	je     2335 <botlish_fn_15+0x195>
    2310:	mov    r11,QWORD PTR [rbx+0x10]
    2314:	mov    r8,QWORD PTR [r11+0x130]
    231b:	mov    rcx,QWORD PTR [rsp+0x38]
    2320:	mov    rdx,QWORD PTR [rsp+0x40]
    2325:	mov    rsi,r15
    2328:	mov    rdi,rbx
    232b:	call   2330 <botlish_fn_15+0x190>
			232c: R_X86_64_PLT32	rt_str_region_eq-0x4
    2330:	jmp    233a <botlish_fn_15+0x19a>
    2335:	mov    rax,QWORD PTR [rsp+0x30]
    233a:	cmp    rax,0x6
    233e:	je     234c <botlish_fn_15+0x1ac>
    2344:	mov    rax,r14
    2347:	jmp    23b7 <botlish_fn_15+0x217>
    234c:	mov    QWORD PTR [rsp+0x18],0x3
    2355:	mov    rsi,r14
    2358:	test   rsi,0x1
    235f:	je     2385 <botlish_fn_15+0x1e5>
    2365:	mov    rsi,r14
    2368:	mov    rax,rsi
    236b:	add    rax,0x2
    236f:	seto   cl
    2372:	test   cl,cl
    2374:	jne    2385 <botlish_fn_15+0x1e5>
    237a:	mov    rsi,rax
    237d:	mov    r14,rax
    2380:	jmp    239b <botlish_fn_15+0x1fb>
    2385:	mov    edx,0x3
    238a:	mov    rsi,r14
    238d:	mov    rdi,rbx
    2390:	call   2395 <botlish_fn_15+0x1f5>
			2391: R_X86_64_PLT32	rt_int_add-0x4
    2395:	mov    rsi,rax
    2398:	mov    r14,rax
    239b:	mov    QWORD PTR [rsp],rsi
    239f:	mov    QWORD PTR [rsp+0x8],r13
    23a4:	mov    QWORD PTR [rsp+0x10],r12
    23a9:	mov    rdx,r13
    23ac:	mov    rdi,rbx
    23af:	jmp    21e1 <botlish_fn_15+0x41>
    23b4:	mov    rax,r14
    23b7:	mov    rbx,QWORD PTR [rsp+0x50]
    23bc:	mov    r12,QWORD PTR [rsp+0x58]
    23c1:	mov    r13,QWORD PTR [rsp+0x60]
    23c6:	mov    r14,QWORD PTR [rsp+0x68]
    23cb:	mov    r15,QWORD PTR [rsp+0x70]
    23d0:	add    rsp,0x80
    23d7:	mov    rsp,rbp
    23da:	pop    rbp
    23db:	ret
    23dc:	add    BYTE PTR [rax],al
    23de:	add    BYTE PTR [rax],al
    23e0:	(bad)
    23e1:	add    BYTE PTR [rax],al
    23e3:	add    BYTE PTR [rax],al
    23e5:	add    BYTE PTR [rax],al
	...

00000000000023e8 <botlish_entry_15: scan_label<generic>>:
    23e8:	push   rbp
    23e9:	mov    rbp,rsp
    23ec:	mov    rsi,QWORD PTR [rdx]
    23ef:	mov    r8,QWORD PTR [rdx+0x8]
    23f3:	mov    rcx,QWORD PTR [rdx+0x10]
    23f7:	mov    rdx,r8
    23fa:	call   23ff <botlish_entry_15+0x17>
			23fb: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_label<generic>
    23ff:	mov    rsp,rbp
    2402:	pop    rbp
    2403:	ret
    2404:	add    BYTE PTR [rax],al
	...

0000000000002408 <botlish_fn_16: scan_alpha<generic>>:
    2408:	push   rbp
    2409:	mov    rbp,rsp
    240c:	sub    rsp,0x50
    2410:	mov    QWORD PTR [rsp+0x30],rbx
    2415:	mov    QWORD PTR [rsp+0x38],r12
    241a:	mov    QWORD PTR [rsp+0x40],r13
    241f:	mov    QWORD PTR [rsp+0x48],r14
    2424:	mov    r14,rdi
    2427:	mov    QWORD PTR [rsp+0x18],0x0
    2430:	mov    QWORD PTR [rsp],rsi
    2434:	mov    r13,rsi
    2437:	mov    QWORD PTR [rsp+0x8],rdx
    243c:	mov    r12,rdx
    243f:	mov    QWORD PTR [rsp+0x10],rcx
    2444:	mov    rbx,rcx
    2447:	mov    r11d,0x1
    244d:	mov    rsi,r13
    2450:	test   rsi,0x1
    2457:	jne    2477 <botlish_fn_16+0x6f>
    245d:	xor    r11d,r11d
    2460:	test   rsi,0x7
    2467:	jne    2477 <botlish_fn_16+0x6f>
    246d:	movzx  rax,BYTE PTR [rsi]
    2471:	cmp    al,0x1
    2473:	sete   r11b
    2477:	test   r11b,r11b
    247a:	jne    249b <botlish_fn_16+0x93>
    2480:	mov    rdi,r14
    2483:	mov    rax,QWORD PTR [rdi+0x10]
    2487:	mov    rcx,QWORD PTR [rax+0xc0]
    248e:	xor    rdx,rdx
    2491:	call   2496 <botlish_fn_16+0x8e>
			2492: R_X86_64_PLT32	rt_type_error-0x4
    2496:	jmp    252a <botlish_fn_16+0x122>
    249b:	mov    rax,rsi
    249e:	and    rax,r12
    24a1:	mov    r13,rsi
    24a4:	test   rax,0x1
    24aa:	jne    24d3 <botlish_fn_16+0xcb>
    24b0:	mov    rdx,r12
    24b3:	mov    rsi,r13
    24b6:	mov    rdi,r14
    24b9:	call   24be <botlish_fn_16+0xb6>
			24ba: R_X86_64_PLT32	rt_int_cmp-0x4
    24be:	mov    ecx,0x2
    24c3:	test   rax,rax
    24c6:	cmovge rcx,QWORD PTR [rip+0x112]        # 25e0 <botlish_fn_16+0x1d8>
    24ce:	jmp    24e6 <botlish_fn_16+0xde>
    24d3:	mov    ecx,0x2
    24d8:	mov    rsi,r13
    24db:	cmp    rsi,r12
    24de:	cmovge rcx,QWORD PTR [rip+0xfa]        # 25e0 <botlish_fn_16+0x1d8>
    24e6:	cmp    rcx,0x6
    24ea:	je     25be <botlish_fn_16+0x1b6>
    24f0:	lea    rcx,[rsp+0x20]
    24f5:	mov    rdx,rbx
    24f8:	mov    rsi,r13
    24fb:	mov    rdi,r14
    24fe:	call   2503 <botlish_fn_16+0xfb>
			24ff: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    2503:	test   rax,rax
    2506:	mov    rsi,rax
    2509:	je     252a <botlish_fn_16+0x122>
    250f:	mov    rdx,QWORD PTR [rsp+0x20]
    2514:	mov    rcx,QWORD PTR [rsp+0x28]
    2519:	mov    rdi,r14
    251c:	call   2521 <botlish_fn_16+0x119>
			251d: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    2521:	test   rax,rax
    2524:	jne    254a <botlish_fn_16+0x142>
    252a:	xor    rax,rax
    252d:	mov    rbx,QWORD PTR [rsp+0x30]
    2532:	mov    r12,QWORD PTR [rsp+0x38]
    2537:	mov    r13,QWORD PTR [rsp+0x40]
    253c:	mov    r14,QWORD PTR [rsp+0x48]
    2541:	add    rsp,0x50
    2545:	mov    rsp,rbp
    2548:	pop    rbp
    2549:	ret
    254a:	cmp    rax,0x6
    254e:	je     255c <botlish_fn_16+0x154>
    2554:	mov    rax,r13
    2557:	jmp    25c1 <botlish_fn_16+0x1b9>
    255c:	mov    QWORD PTR [rsp+0x18],0x3
    2565:	mov    rsi,r13
    2568:	test   rsi,0x1
    256f:	je     2595 <botlish_fn_16+0x18d>
    2575:	mov    rsi,r13
    2578:	mov    r11,rsi
    257b:	add    r11,0x2
    257f:	seto   al
    2582:	test   al,al
    2584:	jne    2595 <botlish_fn_16+0x18d>
    258a:	mov    rsi,r11
    258d:	mov    r13,r11
    2590:	jmp    25ab <botlish_fn_16+0x1a3>
    2595:	mov    edx,0x3
    259a:	mov    rsi,r13
    259d:	mov    rdi,r14
    25a0:	call   25a5 <botlish_fn_16+0x19d>
			25a1: R_X86_64_PLT32	rt_int_add-0x4
    25a5:	mov    rsi,rax
    25a8:	mov    r13,rax
    25ab:	mov    QWORD PTR [rsp],rsi
    25af:	mov    QWORD PTR [rsp+0x8],r12
    25b4:	mov    QWORD PTR [rsp+0x10],rbx
    25b9:	jmp    2447 <botlish_fn_16+0x3f>
    25be:	mov    rax,r13
    25c1:	mov    rbx,QWORD PTR [rsp+0x30]
    25c6:	mov    r12,QWORD PTR [rsp+0x38]
    25cb:	mov    r13,QWORD PTR [rsp+0x40]
    25d0:	mov    r14,QWORD PTR [rsp+0x48]
    25d5:	add    rsp,0x50
    25d9:	mov    rsp,rbp
    25dc:	pop    rbp
    25dd:	ret
    25de:	add    BYTE PTR [rax],al
    25e0:	(bad)
    25e1:	add    BYTE PTR [rax],al
    25e3:	add    BYTE PTR [rax],al
    25e5:	add    BYTE PTR [rax],al
	...

00000000000025e8 <botlish_entry_16: scan_alpha<generic>>:
    25e8:	push   rbp
    25e9:	mov    rbp,rsp
    25ec:	mov    rsi,QWORD PTR [rdx]
    25ef:	mov    r8,QWORD PTR [rdx+0x8]
    25f3:	mov    rcx,QWORD PTR [rdx+0x10]
    25f7:	mov    rdx,r8
    25fa:	call   25ff <botlish_entry_16+0x17>
			25fb: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_alpha<generic>
    25ff:	mov    rsp,rbp
    2602:	pop    rbp
    2603:	ret
    2604:	add    BYTE PTR [rax],al
	...

0000000000002608 <botlish_fn_17: tld_ok<generic>>:
    2608:	push   rbp
    2609:	mov    rbp,rsp
    260c:	sub    rsp,0x40
    2610:	mov    QWORD PTR [rsp+0x20],rbx
    2615:	mov    QWORD PTR [rsp+0x28],r12
    261a:	mov    QWORD PTR [rsp+0x30],r13
    261f:	mov    QWORD PTR [rsp+0x38],r14
    2624:	mov    rbx,rdi
    2627:	mov    QWORD PTR [rsp],rsi
    262b:	mov    r12,rsi
    262e:	mov    QWORD PTR [rsp+0x8],rdx
    2633:	mov    r14,rdx
    2636:	mov    QWORD PTR [rsp+0x10],rcx
    263b:	mov    rdx,r14
    263e:	mov    rsi,r12
    2641:	mov    rdi,rbx
    2644:	call   2649 <botlish_fn_17+0x41>
			2645: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_alpha<generic>
    2649:	mov    rsi,rax
    264c:	mov    r13,rax
    264f:	test   rax,rsi
    2652:	je     2715 <botlish_fn_17+0x10d>
    2658:	mov    rax,r13
    265b:	mov    QWORD PTR [rsp+0x8],rax
    2660:	mov    rdx,r14
    2663:	and    rax,rdx
    2666:	test   rax,0x1
    266c:	jne    2695 <botlish_fn_17+0x8d>
    2672:	mov    rsi,r13
    2675:	mov    rdi,rbx
    2678:	call   267d <botlish_fn_17+0x75>
			2679: R_X86_64_PLT32	rt_int_cmp-0x4
    267d:	mov    ecx,0x2
    2682:	test   rax,rax
    2685:	cmove  rcx,QWORD PTR [rip+0x15b]        # 27e8 <botlish_fn_17+0x1e0>
    268d:	mov    rax,r13
    2690:	jmp    26a8 <botlish_fn_17+0xa0>
    2695:	mov    ecx,0x2
    269a:	mov    rax,r13
    269d:	cmp    rax,rdx
    26a0:	cmove  rcx,QWORD PTR [rip+0x140]        # 27e8 <botlish_fn_17+0x1e0>
    26a8:	cmp    rcx,0x6
    26ac:	je     26bf <botlish_fn_17+0xb7>
    26b2:	mov    ecx,0x2
    26b7:	mov    rax,rcx
    26ba:	jmp    27c7 <botlish_fn_17+0x1bf>
    26bf:	mov    ecx,0x1
    26c4:	mov    rsi,r12
    26c7:	test   rsi,0x1
    26ce:	jne    26f4 <botlish_fn_17+0xec>
    26d4:	xor    ecx,ecx
    26d6:	mov    rsi,r12
    26d9:	test   rsi,0x7
    26e0:	jne    26f4 <botlish_fn_17+0xec>
    26e6:	mov    rsi,r12
    26e9:	movzx  rcx,BYTE PTR [rsi]
    26ed:	rex cmp cl,0x1
    26f1:	sete   cl
    26f4:	test   cl,cl
    26f6:	jne    2735 <botlish_fn_17+0x12d>
    26fc:	mov    rdi,rbx
    26ff:	mov    rsi,QWORD PTR [rdi+0x10]
    2703:	mov    rcx,QWORD PTR [rsi+0x130]
    270a:	xor    rdx,rdx
    270d:	mov    rsi,r12
    2710:	call   2715 <botlish_fn_17+0x10d>
			2711: R_X86_64_PLT32	rt_type_error-0x4
    2715:	xor    rax,rax
    2718:	mov    rbx,QWORD PTR [rsp+0x20]
    271d:	mov    r12,QWORD PTR [rsp+0x28]
    2722:	mov    r13,QWORD PTR [rsp+0x30]
    2727:	mov    r14,QWORD PTR [rsp+0x38]
    272c:	add    rsp,0x40
    2730:	mov    rsp,rbp
    2733:	pop    rbp
    2734:	ret
    2735:	mov    rsi,r12
    2738:	mov    rdi,rax
    273b:	and    rdi,rsi
    273e:	test   rdi,0x1
    2745:	jne    2756 <botlish_fn_17+0x14e>
    274b:	mov    rdx,r12
    274e:	mov    rsi,rax
    2751:	jmp    2779 <botlish_fn_17+0x171>
    2756:	mov    rsi,r12
    2759:	mov    r8,rax
    275c:	sub    r8,rsi
    275f:	mov    r13,rax
    2762:	seto   r10b
    2766:	lea    rsi,[r8+0x1]
    276a:	test   r10b,r10b
    276d:	je     2784 <botlish_fn_17+0x17c>
    2773:	mov    rdx,r12
    2776:	mov    rsi,r13
    2779:	mov    rdi,rbx
    277c:	call   2781 <botlish_fn_17+0x179>
			277d: R_X86_64_PLT32	rt_int_sub-0x4
    2781:	mov    rsi,rax
    2784:	test   rsi,0x1
    278b:	jne    27b6 <botlish_fn_17+0x1ae>
    2791:	mov    edx,0x5
    2796:	mov    rdi,rbx
    2799:	call   279e <botlish_fn_17+0x196>
			279a: R_X86_64_PLT32	rt_int_cmp-0x4
    279e:	mov    ecx,0x2
    27a3:	test   rax,rax
    27a6:	mov    rax,rcx
    27a9:	cmovge rax,QWORD PTR [rip+0x37]        # 27e8 <botlish_fn_17+0x1e0>
    27b1:	jmp    27c7 <botlish_fn_17+0x1bf>
    27b6:	mov    eax,0x2
    27bb:	cmp    rsi,0x5
    27bf:	cmovge rax,QWORD PTR [rip+0x21]        # 27e8 <botlish_fn_17+0x1e0>
    27c7:	mov    rbx,QWORD PTR [rsp+0x20]
    27cc:	mov    r12,QWORD PTR [rsp+0x28]
    27d1:	mov    r13,QWORD PTR [rsp+0x30]
    27d6:	mov    r14,QWORD PTR [rsp+0x38]
    27db:	add    rsp,0x40
    27df:	mov    rsp,rbp
    27e2:	pop    rbp
    27e3:	ret
    27e4:	add    BYTE PTR [rax],al
    27e6:	add    BYTE PTR [rax],al
    27e8:	(bad)
    27e9:	add    BYTE PTR [rax],al
    27eb:	add    BYTE PTR [rax],al
    27ed:	add    BYTE PTR [rax],al
	...

00000000000027f0 <botlish_entry_17: tld_ok<generic>>:
    27f0:	push   rbp
    27f1:	mov    rbp,rsp
    27f4:	mov    rsi,QWORD PTR [rdx]
    27f7:	mov    r8,QWORD PTR [rdx+0x8]
    27fb:	mov    rcx,QWORD PTR [rdx+0x10]
    27ff:	mov    rdx,r8
    2802:	call   2807 <botlish_entry_17+0x17>
			2803: R_X86_64_PLT32	botlish_fn_17-0x4 ; tld_ok<generic>
    2807:	mov    rsp,rbp
    280a:	pop    rbp
    280b:	ret
    280c:	add    BYTE PTR [rax],al
	...

0000000000002810 <botlish_fn_18: domain_loop<generic>>:
    2810:	push   rbp
    2811:	mov    rbp,rsp
    2814:	sub    rsp,0x70
    2818:	mov    QWORD PTR [rsp+0x40],rbx
    281d:	mov    QWORD PTR [rsp+0x48],r12
    2822:	mov    QWORD PTR [rsp+0x50],r13
    2827:	mov    QWORD PTR [rsp+0x58],r14
    282c:	mov    QWORD PTR [rsp+0x60],r15
    2831:	mov    QWORD PTR [rsp+0x18],0x0
    283a:	mov    QWORD PTR [rsp],rsi
    283e:	mov    QWORD PTR [rsp+0x8],rdx
    2843:	mov    QWORD PTR [rsp+0x10],rcx
    2848:	lea    rbx,[rsp+0x20]
    284d:	mov    r12,rdi
    2850:	mov    r13,rcx
    2853:	mov    r14,rdx
    2856:	mov    QWORD PTR [rsp+0x30],rsi
    285b:	mov    rcx,r13
    285e:	mov    rdx,r14
    2861:	mov    rsi,QWORD PTR [rsp+0x30]
    2866:	mov    rdi,r12
    2869:	call   286e <botlish_fn_18+0x5e>
			286a: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_label<generic>
    286e:	mov    rcx,rax
    2871:	mov    r15,rax
    2874:	test   rax,rcx
    2877:	je     29c7 <botlish_fn_18+0x1b7>
    287d:	mov    rax,r15
    2880:	mov    QWORD PTR [rsp],rax
    2884:	mov    rdx,QWORD PTR [rsp+0x30]
    2889:	and    rax,rdx
    288c:	test   rax,0x1
    2892:	jne    28b1 <botlish_fn_18+0xa1>
    2898:	mov    rsi,r15
    289b:	mov    rdi,r12
    289e:	call   28a3 <botlish_fn_18+0x93>
			289f: R_X86_64_PLT32	rt_value_eq-0x4
    28a3:	test   rax,rax
    28a6:	je     29c7 <botlish_fn_18+0x1b7>
    28ac:	jmp    28c1 <botlish_fn_18+0xb1>
    28b1:	mov    eax,0x2
    28b6:	cmp    r15,rdx
    28b9:	cmove  rax,QWORD PTR [rip+0x187]        # 2a48 <botlish_fn_18+0x238>
    28c1:	cmp    rax,0x6
    28c5:	je     2a1d <botlish_fn_18+0x20d>
    28cb:	mov    rax,r15
    28ce:	and    rax,r14
    28d1:	test   rax,0x1
    28d7:	jne    2900 <botlish_fn_18+0xf0>
    28dd:	mov    rdx,r14
    28e0:	mov    rsi,r15
    28e3:	mov    rdi,r12
    28e6:	call   28eb <botlish_fn_18+0xdb>
			28e7: R_X86_64_PLT32	rt_int_cmp-0x4
    28eb:	mov    ecx,0x2
    28f0:	test   rax,rax
    28f3:	cmovge rcx,QWORD PTR [rip+0x14d]        # 2a48 <botlish_fn_18+0x238>
    28fb:	jmp    2910 <botlish_fn_18+0x100>
    2900:	mov    ecx,0x2
    2905:	cmp    r15,r14
    2908:	cmovge rcx,QWORD PTR [rip+0x138]        # 2a48 <botlish_fn_18+0x238>
    2910:	cmp    rcx,0x6
    2914:	je     2a0e <botlish_fn_18+0x1fe>
    291a:	mov    rcx,rbx
    291d:	mov    rdx,r13
    2920:	mov    rsi,r15
    2923:	mov    rdi,r12
    2926:	call   292b <botlish_fn_18+0x11b>
			2927: R_X86_64_PLT32	botlish_fn_13-0x4 ; char_at<generic>
    292b:	test   rax,rax
    292e:	je     29c7 <botlish_fn_18+0x1b7>
    2934:	mov    rdx,QWORD PTR [rsp+0x20]
    2939:	mov    rcx,QWORD PTR [rsp+0x28]
    293e:	mov    rsi,QWORD PTR [r12+0x10]
    2943:	mov    r8,QWORD PTR [rsi+0x120]
    294a:	mov    rsi,rax
    294d:	mov    rdi,r12
    2950:	call   2955 <botlish_fn_18+0x145>
			2951: R_X86_64_PLT32	rt_str_region_eq-0x4
    2955:	cmp    rax,0x6
    2959:	je     296b <botlish_fn_18+0x15b>
    295f:	mov    r14,0xffffffffffffffff
    2966:	jmp    2a15 <botlish_fn_18+0x205>
    296b:	mov    QWORD PTR [rsp+0x18],0x3
    2974:	test   r15,0x1
    297b:	je     2993 <botlish_fn_18+0x183>
    2981:	mov    rdx,r15
    2984:	add    rdx,0x2
    2988:	seto   al
    298b:	test   al,al
    298d:	je     29a6 <botlish_fn_18+0x196>
    2993:	mov    edx,0x3
    2998:	mov    rsi,r15
    299b:	mov    rdi,r12
    299e:	call   29a3 <botlish_fn_18+0x193>
			299f: R_X86_64_PLT32	rt_int_add-0x4
    29a3:	mov    rdx,rax
    29a6:	mov    QWORD PTR [rsp],rdx
    29aa:	mov    r15,rdx
    29ad:	mov    rcx,r13
    29b0:	mov    rdx,r14
    29b3:	mov    rsi,r15
    29b6:	mov    rdi,r12
    29b9:	call   29be <botlish_fn_18+0x1ae>
			29ba: R_X86_64_PLT32	botlish_fn_17-0x4 ; tld_ok<generic>
    29be:	test   rax,rax
    29c1:	jne    29ec <botlish_fn_18+0x1dc>
    29c7:	xor    rax,rax
    29ca:	mov    rbx,QWORD PTR [rsp+0x40]
    29cf:	mov    r12,QWORD PTR [rsp+0x48]
    29d4:	mov    r13,QWORD PTR [rsp+0x50]
    29d9:	mov    r14,QWORD PTR [rsp+0x58]
    29de:	mov    r15,QWORD PTR [rsp+0x60]
    29e3:	add    rsp,0x70
    29e7:	mov    rsp,rbp
    29ea:	pop    rbp
    29eb:	ret
    29ec:	cmp    rax,0x6
    29f0:	je     2a15 <botlish_fn_18+0x205>
    29f6:	mov    QWORD PTR [rsp],r15
    29fa:	mov    QWORD PTR [rsp+0x8],r14
    29ff:	mov    QWORD PTR [rsp+0x10],r13
    2a04:	mov    QWORD PTR [rsp+0x30],r15
    2a09:	jmp    285b <botlish_fn_18+0x4b>
    2a0e:	mov    r14,0xffffffffffffffff
    2a15:	mov    rax,r14
    2a18:	jmp    2a24 <botlish_fn_18+0x214>
    2a1d:	mov    rax,0xffffffffffffffff
    2a24:	mov    rbx,QWORD PTR [rsp+0x40]
    2a29:	mov    r12,QWORD PTR [rsp+0x48]
    2a2e:	mov    r13,QWORD PTR [rsp+0x50]
    2a33:	mov    r14,QWORD PTR [rsp+0x58]
    2a38:	mov    r15,QWORD PTR [rsp+0x60]
    2a3d:	add    rsp,0x70
    2a41:	mov    rsp,rbp
    2a44:	pop    rbp
    2a45:	ret
    2a46:	add    BYTE PTR [rax],al
    2a48:	(bad)
    2a49:	add    BYTE PTR [rax],al
    2a4b:	add    BYTE PTR [rax],al
    2a4d:	add    BYTE PTR [rax],al
	...

0000000000002a50 <botlish_entry_18: domain_loop<generic>>:
    2a50:	push   rbp
    2a51:	mov    rbp,rsp
    2a54:	mov    rsi,QWORD PTR [rdx]
    2a57:	mov    r8,QWORD PTR [rdx+0x8]
    2a5b:	mov    rcx,QWORD PTR [rdx+0x10]
    2a5f:	mov    rdx,r8
    2a62:	call   2a67 <botlish_entry_18+0x17>
			2a63: R_X86_64_PLT32	botlish_fn_18-0x4 ; domain_loop<generic>
    2a67:	mov    rsp,rbp
    2a6a:	pop    rbp
    2a6b:	ret
    2a6c:	add    BYTE PTR [rax],al
	...

0000000000002a70 <botlish_fn_19: <str>>:
    2a70:	push   rbp
    2a71:	mov    rbp,rsp
    2a74:	sub    rsp,0x50
    2a78:	mov    QWORD PTR [rsp+0x30],rbx
    2a7d:	mov    QWORD PTR [rsp+0x38],r12
    2a82:	mov    QWORD PTR [rsp+0x40],r13
    2a87:	mov    QWORD PTR [rsp+0x48],r14
    2a8c:	mov    r13,rdi
    2a8f:	mov    QWORD PTR [rsp+0x18],0x0
    2a98:	mov    QWORD PTR [rsp],rsi
    2a9c:	mov    r14,rsi
    2a9f:	mov    rsi,r14
    2aa2:	mov    rdi,r13
    2aa5:	call   2aaa <botlish_fn_19+0x3a>
			2aa6: R_X86_64_PLT32	rt_str_len-0x4
    2aaa:	mov    rbx,rax
    2aad:	mov    QWORD PTR [rsp+0x8],rax
    2ab2:	mov    esi,0x1
    2ab7:	mov    QWORD PTR [rsp+0x10],0x1
    2ac0:	mov    rcx,r14
    2ac3:	mov    rdx,rbx
    2ac6:	mov    rdi,r13
    2ac9:	call   2ace <botlish_fn_19+0x5e>
			2aca: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_local<generic>
    2ace:	mov    r12,rax
    2ad1:	test   r12,r12
    2ad4:	je     2c31 <botlish_fn_19+0x1c1>
    2ada:	mov    QWORD PTR [rsp+0x10],r12
    2adf:	test   r12,0x1
    2ae6:	jne    2b11 <botlish_fn_19+0xa1>
    2aec:	mov    edx,0x1
    2af1:	mov    rsi,r12
    2af4:	mov    rdi,r13
    2af7:	call   2afc <botlish_fn_19+0x8c>
			2af8: R_X86_64_PLT32	rt_int_cmp-0x4
    2afc:	mov    ecx,0x2
    2b01:	test   rax,rax
    2b04:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 2cd0 <botlish_fn_19+0x260>
    2b0c:	jmp    2b22 <botlish_fn_19+0xb2>
    2b11:	mov    ecx,0x2
    2b16:	cmp    r12,0x1
    2b1a:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 2cd0 <botlish_fn_19+0x260>
    2b22:	cmp    rcx,0x6
    2b26:	je     2cac <botlish_fn_19+0x23c>
    2b2c:	mov    rcx,r12
    2b2f:	and    rcx,rbx
    2b32:	test   rcx,0x1
    2b39:	jne    2b62 <botlish_fn_19+0xf2>
    2b3f:	mov    rdx,rbx
    2b42:	mov    rsi,r12
    2b45:	mov    rdi,r13
    2b48:	call   2b4d <botlish_fn_19+0xdd>
			2b49: R_X86_64_PLT32	rt_int_cmp-0x4
    2b4d:	mov    ecx,0x2
    2b52:	test   rax,rax
    2b55:	cmovge rcx,QWORD PTR [rip+0x173]        # 2cd0 <botlish_fn_19+0x260>
    2b5d:	jmp    2b72 <botlish_fn_19+0x102>
    2b62:	mov    ecx,0x2
    2b67:	cmp    r12,rbx
    2b6a:	cmovge rcx,QWORD PTR [rip+0x15e]        # 2cd0 <botlish_fn_19+0x260>
    2b72:	cmp    rcx,0x6
    2b76:	je     2ca2 <botlish_fn_19+0x232>
    2b7c:	lea    rcx,[rsp+0x20]
    2b81:	mov    rdx,r14
    2b84:	mov    rsi,r12
    2b87:	mov    rdi,r13
    2b8a:	call   2b8f <botlish_fn_19+0x11f>
			2b8b: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    2b8f:	test   rax,rax
    2b92:	mov    rsi,rax
    2b95:	je     2c31 <botlish_fn_19+0x1c1>
    2b9b:	mov    rdx,QWORD PTR [rsp+0x20]
    2ba0:	mov    rcx,QWORD PTR [rsp+0x28]
    2ba5:	mov    rdi,r13
    2ba8:	mov    rax,QWORD PTR [rdi+0x10]
    2bac:	mov    r8,QWORD PTR [rax+0x108]
    2bb3:	call   2bb8 <botlish_fn_19+0x148>
			2bb4: R_X86_64_PLT32	rt_str_region_eq-0x4
    2bb8:	cmp    rax,0x6
    2bbc:	je     2bcf <botlish_fn_19+0x15f>
    2bc2:	mov    ecx,0x2
    2bc7:	mov    rax,rcx
    2bca:	jmp    2cb1 <botlish_fn_19+0x241>
    2bcf:	mov    QWORD PTR [rsp+0x18],0x3
    2bd8:	test   r12,0x1
    2bdf:	jne    2bed <botlish_fn_19+0x17d>
    2be5:	mov    rcx,r12
    2be8:	jmp    2c02 <botlish_fn_19+0x192>
    2bed:	mov    rsi,r12
    2bf0:	add    rsi,0x2
    2bf4:	mov    rcx,r12
    2bf7:	seto   al
    2bfa:	test   al,al
    2bfc:	je     2c15 <botlish_fn_19+0x1a5>
    2c02:	mov    edx,0x3
    2c07:	mov    rsi,rcx
    2c0a:	mov    rdi,r13
    2c0d:	call   2c12 <botlish_fn_19+0x1a2>
			2c0e: R_X86_64_PLT32	rt_int_add-0x4
    2c12:	mov    rsi,rax
    2c15:	mov    QWORD PTR [rsp+0x10],rsi
    2c1a:	mov    rcx,r14
    2c1d:	mov    rdx,rbx
    2c20:	mov    rdi,r13
    2c23:	call   2c28 <botlish_fn_19+0x1b8>
			2c24: R_X86_64_PLT32	botlish_fn_26-0x4 ; domain_loop<generic>
    2c28:	test   rax,rax
    2c2b:	jne    2c51 <botlish_fn_19+0x1e1>
    2c31:	xor    rax,rax
    2c34:	mov    rbx,QWORD PTR [rsp+0x30]
    2c39:	mov    r12,QWORD PTR [rsp+0x38]
    2c3e:	mov    r13,QWORD PTR [rsp+0x40]
    2c43:	mov    r14,QWORD PTR [rsp+0x48]
    2c48:	add    rsp,0x50
    2c4c:	mov    rsp,rbp
    2c4f:	pop    rbp
    2c50:	ret
    2c51:	mov    rcx,rax
    2c54:	and    rcx,rbx
    2c57:	mov    rsi,rax
    2c5a:	test   rcx,0x1
    2c61:	jne    2c8a <botlish_fn_19+0x21a>
    2c67:	mov    rdx,rbx
    2c6a:	mov    rdi,r13
    2c6d:	call   2c72 <botlish_fn_19+0x202>
			2c6e: R_X86_64_PLT32	rt_int_cmp-0x4
    2c72:	mov    ecx,0x2
    2c77:	test   rax,rax
    2c7a:	mov    rax,rcx
    2c7d:	cmove  rax,QWORD PTR [rip+0x4b]        # 2cd0 <botlish_fn_19+0x260>
    2c85:	jmp    2cb1 <botlish_fn_19+0x241>
    2c8a:	mov    rdx,rbx
    2c8d:	mov    eax,0x2
    2c92:	cmp    rsi,rdx
    2c95:	cmove  rax,QWORD PTR [rip+0x33]        # 2cd0 <botlish_fn_19+0x260>
    2c9d:	jmp    2cb1 <botlish_fn_19+0x241>
    2ca2:	mov    eax,0x2
    2ca7:	jmp    2cb1 <botlish_fn_19+0x241>
    2cac:	mov    eax,0x2
    2cb1:	mov    rbx,QWORD PTR [rsp+0x30]
    2cb6:	mov    r12,QWORD PTR [rsp+0x38]
    2cbb:	mov    r13,QWORD PTR [rsp+0x40]
    2cc0:	mov    r14,QWORD PTR [rsp+0x48]
    2cc5:	add    rsp,0x50
    2cc9:	mov    rsp,rbp
    2ccc:	pop    rbp
    2ccd:	ret
    2cce:	add    BYTE PTR [rax],al
    2cd0:	(bad)
    2cd1:	add    BYTE PTR [rax],al
    2cd3:	add    BYTE PTR [rax],al
    2cd5:	add    BYTE PTR [rax],al
	...

0000000000002cd8 <botlish_entry_19: <str>>:
    2cd8:	push   rbp
    2cd9:	mov    rbp,rsp
    2cdc:	mov    rsi,QWORD PTR [rdx]
    2cdf:	call   2ce4 <botlish_entry_19+0xc>
			2ce0: R_X86_64_PLT32	botlish_fn_19-0x4 ; <str>
    2ce4:	mov    rsp,rbp
    2ce7:	pop    rbp
    2ce8:	ret
    2ce9:	add    BYTE PTR [rax],al
    2ceb:	add    BYTE PTR [rax],al
    2ced:	add    BYTE PTR [rax],al
	...

0000000000002cf0 <botlish_fn_20: <generic>>:
    2cf0:	push   rbp
    2cf1:	mov    rbp,rsp
    2cf4:	sub    rsp,0x60
    2cf8:	mov    QWORD PTR [rsp+0x30],rbx
    2cfd:	mov    QWORD PTR [rsp+0x38],r12
    2d02:	mov    QWORD PTR [rsp+0x40],r13
    2d07:	mov    QWORD PTR [rsp+0x48],r14
    2d0c:	mov    QWORD PTR [rsp+0x50],r15
    2d11:	mov    QWORD PTR [rsp+0x18],0x0
    2d1a:	mov    QWORD PTR [rsp],rsi
    2d1e:	xor    r8d,r8d
    2d21:	test   rsi,0x7
    2d28:	jne    2d38 <botlish_fn_20+0x48>
    2d2e:	movzx  rax,BYTE PTR [rsi]
    2d32:	cmp    al,0x2
    2d34:	sete   r8b
    2d38:	test   r8b,r8b
    2d3b:	jne    2d5b <botlish_fn_20+0x6b>
    2d41:	mov    rdx,QWORD PTR [rdi+0x10]
    2d45:	mov    rcx,QWORD PTR [rdx+0xe0]
    2d4c:	mov    edx,0x1
    2d51:	call   2d56 <botlish_fn_20+0x66>
			2d52: R_X86_64_PLT32	rt_type_error-0x4
    2d56:	jmp    2ef0 <botlish_fn_20+0x200>
    2d5b:	mov    r13,rsi
    2d5e:	mov    r14,rdi
    2d61:	call   2d66 <botlish_fn_20+0x76>
			2d62: R_X86_64_PLT32	rt_str_len-0x4
    2d66:	mov    rbx,rax
    2d69:	mov    QWORD PTR [rsp+0x8],rax
    2d6e:	mov    edx,0x1
    2d73:	mov    r15,rdx
    2d76:	mov    QWORD PTR [rsp+0x10],0x1
    2d7f:	mov    rcx,r13
    2d82:	mov    rdx,rbx
    2d85:	mov    rsi,r15
    2d88:	mov    rdi,r14
    2d8b:	call   2d90 <botlish_fn_20+0xa0>
			2d8c: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_local<generic>
    2d90:	mov    r12,rax
    2d93:	test   r12,r12
    2d96:	je     2ef0 <botlish_fn_20+0x200>
    2d9c:	mov    QWORD PTR [rsp+0x10],r12
    2da1:	test   r12,0x1
    2da8:	jne    2dd1 <botlish_fn_20+0xe1>
    2dae:	mov    rdx,r15
    2db1:	mov    rsi,r12
    2db4:	mov    rdi,r14
    2db7:	call   2dbc <botlish_fn_20+0xcc>
			2db8: R_X86_64_PLT32	rt_int_cmp-0x4
    2dbc:	mov    ecx,0x2
    2dc1:	test   rax,rax
    2dc4:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 2f98 <botlish_fn_20+0x2a8>
    2dcc:	jmp    2de2 <botlish_fn_20+0xf2>
    2dd1:	mov    ecx,0x2
    2dd6:	cmp    r12,0x1
    2dda:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 2f98 <botlish_fn_20+0x2a8>
    2de2:	cmp    rcx,0x6
    2de6:	je     2f70 <botlish_fn_20+0x280>
    2dec:	mov    rax,r12
    2def:	and    rax,rbx
    2df2:	test   rax,0x1
    2df8:	jne    2e21 <botlish_fn_20+0x131>
    2dfe:	mov    rdx,rbx
    2e01:	mov    rsi,r12
    2e04:	mov    rdi,r14
    2e07:	call   2e0c <botlish_fn_20+0x11c>
			2e08: R_X86_64_PLT32	rt_int_cmp-0x4
    2e0c:	mov    ecx,0x2
    2e11:	test   rax,rax
    2e14:	cmovge rcx,QWORD PTR [rip+0x17c]        # 2f98 <botlish_fn_20+0x2a8>
    2e1c:	jmp    2e31 <botlish_fn_20+0x141>
    2e21:	mov    ecx,0x2
    2e26:	cmp    r12,rbx
    2e29:	cmovge rcx,QWORD PTR [rip+0x167]        # 2f98 <botlish_fn_20+0x2a8>
    2e31:	cmp    rcx,0x6
    2e35:	je     2f66 <botlish_fn_20+0x276>
    2e3b:	lea    rcx,[rsp+0x20]
    2e40:	mov    rdx,r13
    2e43:	mov    rsi,r12
    2e46:	mov    rdi,r14
    2e49:	call   2e4e <botlish_fn_20+0x15e>
			2e4a: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    2e4e:	test   rax,rax
    2e51:	mov    rsi,rax
    2e54:	je     2ef0 <botlish_fn_20+0x200>
    2e5a:	mov    rdx,QWORD PTR [rsp+0x20]
    2e5f:	mov    rcx,QWORD PTR [rsp+0x28]
    2e64:	mov    rdi,r14
    2e67:	mov    rax,QWORD PTR [rdi+0x10]
    2e6b:	mov    r8,QWORD PTR [rax+0x108]
    2e72:	call   2e77 <botlish_fn_20+0x187>
			2e73: R_X86_64_PLT32	rt_str_region_eq-0x4
    2e77:	cmp    rax,0x6
    2e7b:	je     2e8e <botlish_fn_20+0x19e>
    2e81:	mov    ecx,0x2
    2e86:	mov    rax,rcx
    2e89:	jmp    2f75 <botlish_fn_20+0x285>
    2e8e:	mov    QWORD PTR [rsp+0x18],0x3
    2e97:	test   r12,0x1
    2e9e:	jne    2eac <botlish_fn_20+0x1bc>
    2ea4:	mov    rdi,r12
    2ea7:	jmp    2ec1 <botlish_fn_20+0x1d1>
    2eac:	mov    rsi,r12
    2eaf:	add    rsi,0x2
    2eb3:	mov    rdi,r12
    2eb6:	seto   al
    2eb9:	test   al,al
    2ebb:	je     2ed4 <botlish_fn_20+0x1e4>
    2ec1:	mov    edx,0x3
    2ec6:	mov    rsi,rdi
    2ec9:	mov    rdi,r14
    2ecc:	call   2ed1 <botlish_fn_20+0x1e1>
			2ecd: R_X86_64_PLT32	rt_int_add-0x4
    2ed1:	mov    rsi,rax
    2ed4:	mov    QWORD PTR [rsp+0x10],rsi
    2ed9:	mov    rcx,r13
    2edc:	mov    rdx,rbx
    2edf:	mov    rdi,r14
    2ee2:	call   2ee7 <botlish_fn_20+0x1f7>
			2ee3: R_X86_64_PLT32	botlish_fn_26-0x4 ; domain_loop<generic>
    2ee7:	test   rax,rax
    2eea:	jne    2f15 <botlish_fn_20+0x225>
    2ef0:	xor    rax,rax
    2ef3:	mov    rbx,QWORD PTR [rsp+0x30]
    2ef8:	mov    r12,QWORD PTR [rsp+0x38]
    2efd:	mov    r13,QWORD PTR [rsp+0x40]
    2f02:	mov    r14,QWORD PTR [rsp+0x48]
    2f07:	mov    r15,QWORD PTR [rsp+0x50]
    2f0c:	add    rsp,0x60
    2f10:	mov    rsp,rbp
    2f13:	pop    rbp
    2f14:	ret
    2f15:	mov    rcx,rax
    2f18:	and    rcx,rbx
    2f1b:	mov    rsi,rax
    2f1e:	test   rcx,0x1
    2f25:	jne    2f4e <botlish_fn_20+0x25e>
    2f2b:	mov    rdx,rbx
    2f2e:	mov    rdi,r14
    2f31:	call   2f36 <botlish_fn_20+0x246>
			2f32: R_X86_64_PLT32	rt_int_cmp-0x4
    2f36:	mov    ecx,0x2
    2f3b:	test   rax,rax
    2f3e:	mov    rax,rcx
    2f41:	cmove  rax,QWORD PTR [rip+0x4f]        # 2f98 <botlish_fn_20+0x2a8>
    2f49:	jmp    2f75 <botlish_fn_20+0x285>
    2f4e:	mov    rdx,rbx
    2f51:	mov    eax,0x2
    2f56:	cmp    rsi,rdx
    2f59:	cmove  rax,QWORD PTR [rip+0x37]        # 2f98 <botlish_fn_20+0x2a8>
    2f61:	jmp    2f75 <botlish_fn_20+0x285>
    2f66:	mov    eax,0x2
    2f6b:	jmp    2f75 <botlish_fn_20+0x285>
    2f70:	mov    eax,0x2
    2f75:	mov    rbx,QWORD PTR [rsp+0x30]
    2f7a:	mov    r12,QWORD PTR [rsp+0x38]
    2f7f:	mov    r13,QWORD PTR [rsp+0x40]
    2f84:	mov    r14,QWORD PTR [rsp+0x48]
    2f89:	mov    r15,QWORD PTR [rsp+0x50]
    2f8e:	add    rsp,0x60
    2f92:	mov    rsp,rbp
    2f95:	pop    rbp
    2f96:	ret
    2f97:	add    BYTE PTR [rsi],al
    2f99:	add    BYTE PTR [rax],al
    2f9b:	add    BYTE PTR [rax],al
    2f9d:	add    BYTE PTR [rax],al
	...

0000000000002fa0 <botlish_entry_20: <generic>>:
    2fa0:	push   rbp
    2fa1:	mov    rbp,rsp
    2fa4:	mov    rsi,QWORD PTR [rdx]
    2fa7:	call   2fac <botlish_entry_20+0xc>
			2fa8: R_X86_64_PLT32	botlish_fn_20-0x4 ; <generic>
    2fac:	mov    rsp,rbp
    2faf:	pop    rbp
    2fb0:	ret

0000000000002fb1 <botlish_fn_21: char_at<generic>>:
    2fb1:	push   rbp
    2fb2:	mov    rbp,rsp
    2fb5:	sub    rsp,0x50
    2fb9:	mov    QWORD PTR [rsp+0x20],rbx
    2fbe:	mov    QWORD PTR [rsp+0x28],r12
    2fc3:	mov    QWORD PTR [rsp+0x30],r13
    2fc8:	mov    QWORD PTR [rsp+0x38],r14
    2fcd:	mov    QWORD PTR [rsp+0x40],r15
    2fd2:	mov    r14,rcx
    2fd5:	mov    QWORD PTR [rsp],rsi
    2fd9:	mov    QWORD PTR [rsp+0x8],rdx
    2fde:	mov    r13,rdx
    2fe1:	mov    QWORD PTR [rsp+0x10],0x3
    2fea:	mov    r9d,0x1
    2ff0:	test   rsi,0x1
    2ff7:	jne    3017 <botlish_fn_21+0x66>
    2ffd:	xor    r9d,r9d
    3000:	test   rsi,0x7
    3007:	jne    3017 <botlish_fn_21+0x66>
    300d:	movzx  rax,BYTE PTR [rsi]
    3011:	cmp    al,0x1
    3013:	sete   r9b
    3017:	test   r9b,r9b
    301a:	jne    3038 <botlish_fn_21+0x87>
    3020:	mov    rax,QWORD PTR [rdi+0x10]
    3024:	mov    rcx,QWORD PTR [rax+0x110]
    302b:	xor    rdx,rdx
    302e:	call   3033 <botlish_fn_21+0x82>
			302f: R_X86_64_PLT32	rt_type_error-0x4
    3033:	jmp    30f5 <botlish_fn_21+0x144>
    3038:	mov    r12,rdi
    303b:	test   rsi,0x1
    3042:	jne    3050 <botlish_fn_21+0x9f>
    3048:	mov    rbx,rsi
    304b:	jmp    306d <botlish_fn_21+0xbc>
    3050:	mov    rax,rsi
    3053:	add    rax,0x2
    3057:	mov    rbx,rsi
    305a:	seto   cl
    305d:	test   cl,cl
    305f:	jne    306d <botlish_fn_21+0xbc>
    3065:	mov    r15,rax
    3068:	jmp    3080 <botlish_fn_21+0xcf>
    306d:	mov    edx,0x3
    3072:	mov    rsi,rbx
    3075:	mov    rdi,r12
    3078:	call   307d <botlish_fn_21+0xcc>
			3079: R_X86_64_PLT32	rt_int_add-0x4
    307d:	mov    r15,rax
    3080:	mov    ecx,0x1
    3085:	mov    rsi,rbx
    3088:	test   rsi,0x1
    308f:	jne    30b5 <botlish_fn_21+0x104>
    3095:	xor    ecx,ecx
    3097:	mov    rsi,rbx
    309a:	test   rsi,0x7
    30a1:	jne    30b5 <botlish_fn_21+0x104>
    30a7:	mov    rsi,rbx
    30aa:	movzx  rcx,BYTE PTR [rsi]
    30ae:	rex cmp cl,0x1
    30b2:	sete   cl
    30b5:	test   cl,cl
    30b7:	jne    30db <botlish_fn_21+0x12a>
    30bd:	mov    rdi,r12
    30c0:	mov    rsi,QWORD PTR [rdi+0x10]
    30c4:	mov    rcx,QWORD PTR [rsi+0x118]
    30cb:	xor    rdx,rdx
    30ce:	mov    rsi,rbx
    30d1:	call   30d6 <botlish_fn_21+0x125>
			30d2: R_X86_64_PLT32	rt_type_error-0x4
    30d6:	jmp    30f5 <botlish_fn_21+0x144>
    30db:	mov    rdi,r12
    30de:	mov    rcx,r15
    30e1:	mov    rdx,rbx
    30e4:	mov    rsi,r13
    30e7:	call   30ec <botlish_fn_21+0x13b>
			30e8: R_X86_64_PLT32	rt_str_region_check-0x4
    30ec:	test   rax,rax
    30ef:	jne    311a <botlish_fn_21+0x169>
    30f5:	xor    rax,rax
    30f8:	mov    rbx,QWORD PTR [rsp+0x20]
    30fd:	mov    r12,QWORD PTR [rsp+0x28]
    3102:	mov    r13,QWORD PTR [rsp+0x30]
    3107:	mov    r14,QWORD PTR [rsp+0x38]
    310c:	mov    r15,QWORD PTR [rsp+0x40]
    3111:	add    rsp,0x50
    3115:	mov    rsp,rbp
    3118:	pop    rbp
    3119:	ret
    311a:	mov    rcx,r14
    311d:	mov    rsi,rbx
    3120:	mov    QWORD PTR [rcx],rsi
    3123:	mov    rax,r15
    3126:	mov    QWORD PTR [rcx+0x8],rax
    312a:	mov    rax,r13
    312d:	mov    rbx,QWORD PTR [rsp+0x20]
    3132:	mov    r12,QWORD PTR [rsp+0x28]
    3137:	mov    r13,QWORD PTR [rsp+0x30]
    313c:	mov    r14,QWORD PTR [rsp+0x38]
    3141:	mov    r15,QWORD PTR [rsp+0x40]
    3146:	add    rsp,0x50
    314a:	mov    rsp,rbp
    314d:	pop    rbp
    314e:	ret

000000000000314f <botlish_entry_21: char_at<generic>>:
    314f:	push   rbp
    3150:	mov    rbp,rsp
    3153:	ud2
    3155:	add    BYTE PTR [rax],al
	...

0000000000003158 <botlish_fn_22: scan_local<generic>>:
    3158:	push   rbp
    3159:	mov    rbp,rsp
    315c:	sub    rsp,0x80
    3163:	mov    QWORD PTR [rsp+0x50],rbx
    3168:	mov    QWORD PTR [rsp+0x58],r12
    316d:	mov    QWORD PTR [rsp+0x60],r13
    3172:	mov    QWORD PTR [rsp+0x68],r14
    3177:	mov    QWORD PTR [rsp+0x70],r15
    317c:	mov    rax,rdi
    317f:	mov    QWORD PTR [rsp+0x18],0x0
    3188:	mov    QWORD PTR [rsp],rsi
    318c:	mov    r14,rsi
    318f:	mov    QWORD PTR [rsp+0x8],rdx
    3194:	mov    QWORD PTR [rsp+0x10],rcx
    3199:	mov    r12,rcx
    319c:	mov    r11d,0x1
    31a2:	mov    rsi,r14
    31a5:	test   rsi,0x1
    31ac:	jne    31ce <botlish_fn_22+0x76>
    31b2:	xor    r11d,r11d
    31b5:	test   rsi,0x7
    31bc:	jne    31ce <botlish_fn_22+0x76>
    31c2:	movzx  rdi,BYTE PTR [rsi]
    31c6:	cmp    dil,0x1
    31ca:	sete   r11b
    31ce:	test   r11b,r11b
    31d1:	jne    31f2 <botlish_fn_22+0x9a>
    31d7:	mov    rdi,rax
    31da:	mov    r9,QWORD PTR [rdi+0x10]
    31de:	mov    rcx,QWORD PTR [r9+0xc0]
    31e5:	xor    rdx,rdx
    31e8:	call   31ed <botlish_fn_22+0x95>
			31e9: R_X86_64_PLT32	rt_type_error-0x4
    31ed:	jmp    32a5 <botlish_fn_22+0x14d>
    31f2:	mov    r13,rdx
    31f5:	mov    r10,rsi
    31f8:	and    r10,r13
    31fb:	mov    r14,rsi
    31fe:	test   r10,0x1
    3205:	jne    3231 <botlish_fn_22+0xd9>
    320b:	mov    rbx,rax
    320e:	mov    rdx,r13
    3211:	mov    rsi,r14
    3214:	mov    rdi,rbx
    3217:	call   321c <botlish_fn_22+0xc4>
			3218: R_X86_64_PLT32	rt_int_cmp-0x4
    321c:	mov    ecx,0x2
    3221:	test   rax,rax
    3224:	cmovge rcx,QWORD PTR [rip+0x24c]        # 3478 <botlish_fn_22+0x320>
    322c:	jmp    3247 <botlish_fn_22+0xef>
    3231:	mov    rbx,rax
    3234:	mov    ecx,0x2
    3239:	mov    rsi,r14
    323c:	cmp    rsi,r13
    323f:	cmovge rcx,QWORD PTR [rip+0x231]        # 3478 <botlish_fn_22+0x320>
    3247:	mov    eax,0x6
    324c:	mov    QWORD PTR [rsp+0x30],rax
    3251:	cmp    rcx,0x6
    3255:	je     344b <botlish_fn_22+0x2f3>
    325b:	lea    rcx,[rsp+0x20]
    3260:	mov    rdx,r12
    3263:	mov    rsi,r14
    3266:	mov    rdi,rbx
    3269:	call   326e <botlish_fn_22+0x116>
			326a: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    326e:	mov    rsi,rax
    3271:	mov    r15,rax
    3274:	test   rax,rsi
    3277:	je     32a5 <botlish_fn_22+0x14d>
    327d:	mov    rdx,QWORD PTR [rsp+0x20]
    3282:	mov    QWORD PTR [rsp+0x40],rdx
    3287:	mov    rcx,QWORD PTR [rsp+0x28]
    328c:	mov    QWORD PTR [rsp+0x38],rcx
    3291:	mov    rsi,r15
    3294:	mov    rdi,rbx
    3297:	call   329c <botlish_fn_22+0x144>
			3298: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    329c:	test   rax,rax
    329f:	jne    32cd <botlish_fn_22+0x175>
    32a5:	xor    rax,rax
    32a8:	mov    rbx,QWORD PTR [rsp+0x50]
    32ad:	mov    r12,QWORD PTR [rsp+0x58]
    32b2:	mov    r13,QWORD PTR [rsp+0x60]
    32b7:	mov    r14,QWORD PTR [rsp+0x68]
    32bc:	mov    r15,QWORD PTR [rsp+0x70]
    32c1:	add    rsp,0x80
    32c8:	mov    rsp,rbp
    32cb:	pop    rbp
    32cc:	ret
    32cd:	cmp    rax,0x6
    32d1:	je     33cc <botlish_fn_22+0x274>
    32d7:	mov    rax,QWORD PTR [rbx+0x10]
    32db:	mov    r8,QWORD PTR [rax+0x120]
    32e2:	mov    rcx,QWORD PTR [rsp+0x38]
    32e7:	mov    rdx,QWORD PTR [rsp+0x40]
    32ec:	mov    rsi,r15
    32ef:	mov    rdi,rbx
    32f2:	call   32f7 <botlish_fn_22+0x19f>
			32f3: R_X86_64_PLT32	rt_str_region_eq-0x4
    32f7:	cmp    rax,0x6
    32fb:	je     33c2 <botlish_fn_22+0x26a>
    3301:	mov    rax,QWORD PTR [rbx+0x10]
    3305:	mov    r8,QWORD PTR [rax+0x128]
    330c:	mov    rcx,QWORD PTR [rsp+0x38]
    3311:	mov    rdx,QWORD PTR [rsp+0x40]
    3316:	mov    rsi,r15
    3319:	mov    rdi,rbx
    331c:	call   3321 <botlish_fn_22+0x1c9>
			331d: R_X86_64_PLT32	rt_str_region_eq-0x4
    3321:	cmp    rax,0x6
    3325:	je     33b8 <botlish_fn_22+0x260>
    332b:	mov    rax,QWORD PTR [rbx+0x10]
    332f:	mov    r8,QWORD PTR [rax+0xc8]
    3336:	mov    rcx,QWORD PTR [rsp+0x38]
    333b:	mov    rdx,QWORD PTR [rsp+0x40]
    3340:	mov    rsi,r15
    3343:	mov    rdi,rbx
    3346:	call   334b <botlish_fn_22+0x1f3>
			3347: R_X86_64_PLT32	rt_str_region_eq-0x4
    334b:	cmp    rax,0x6
    334f:	je     33ae <botlish_fn_22+0x256>
    3355:	mov    rax,QWORD PTR [rbx+0x10]
    3359:	mov    r8,QWORD PTR [rax+0x110]
    3360:	mov    rcx,QWORD PTR [rsp+0x38]
    3365:	mov    rdx,QWORD PTR [rsp+0x40]
    336a:	mov    rsi,r15
    336d:	mov    rdi,rbx
    3370:	call   3375 <botlish_fn_22+0x21d>
			3371: R_X86_64_PLT32	rt_str_region_eq-0x4
    3375:	cmp    rax,0x6
    3379:	je     33a4 <botlish_fn_22+0x24c>
    337f:	mov    rax,QWORD PTR [rbx+0x10]
    3383:	mov    r8,QWORD PTR [rax+0x130]
    338a:	mov    rcx,QWORD PTR [rsp+0x38]
    338f:	mov    rdx,QWORD PTR [rsp+0x40]
    3394:	mov    rsi,r15
    3397:	mov    rdi,rbx
    339a:	call   339f <botlish_fn_22+0x247>
			339b: R_X86_64_PLT32	rt_str_region_eq-0x4
    339f:	jmp    33d1 <botlish_fn_22+0x279>
    33a4:	mov    rax,QWORD PTR [rsp+0x30]
    33a9:	jmp    33d1 <botlish_fn_22+0x279>
    33ae:	mov    rax,QWORD PTR [rsp+0x30]
    33b3:	jmp    33d1 <botlish_fn_22+0x279>
    33b8:	mov    rax,QWORD PTR [rsp+0x30]
    33bd:	jmp    33d1 <botlish_fn_22+0x279>
    33c2:	mov    rax,QWORD PTR [rsp+0x30]
    33c7:	jmp    33d1 <botlish_fn_22+0x279>
    33cc:	mov    rax,QWORD PTR [rsp+0x30]
    33d1:	cmp    rax,0x6
    33d5:	je     33e3 <botlish_fn_22+0x28b>
    33db:	mov    rax,r14
    33de:	jmp    344e <botlish_fn_22+0x2f6>
    33e3:	mov    QWORD PTR [rsp+0x18],0x3
    33ec:	mov    rsi,r14
    33ef:	test   rsi,0x1
    33f6:	je     341c <botlish_fn_22+0x2c4>
    33fc:	mov    rsi,r14
    33ff:	mov    rax,rsi
    3402:	add    rax,0x2
    3406:	seto   cl
    3409:	test   cl,cl
    340b:	jne    341c <botlish_fn_22+0x2c4>
    3411:	mov    rsi,rax
    3414:	mov    r14,rax
    3417:	jmp    3432 <botlish_fn_22+0x2da>
    341c:	mov    edx,0x3
    3421:	mov    rsi,r14
    3424:	mov    rdi,rbx
    3427:	call   342c <botlish_fn_22+0x2d4>
			3428: R_X86_64_PLT32	rt_int_add-0x4
    342c:	mov    rsi,rax
    342f:	mov    r14,rax
    3432:	mov    QWORD PTR [rsp],rsi
    3436:	mov    QWORD PTR [rsp+0x8],r13
    343b:	mov    QWORD PTR [rsp+0x10],r12
    3440:	mov    rax,rbx
    3443:	mov    rdx,r13
    3446:	jmp    319c <botlish_fn_22+0x44>
    344b:	mov    rax,r14
    344e:	mov    rbx,QWORD PTR [rsp+0x50]
    3453:	mov    r12,QWORD PTR [rsp+0x58]
    3458:	mov    r13,QWORD PTR [rsp+0x60]
    345d:	mov    r14,QWORD PTR [rsp+0x68]
    3462:	mov    r15,QWORD PTR [rsp+0x70]
    3467:	add    rsp,0x80
    346e:	mov    rsp,rbp
    3471:	pop    rbp
    3472:	ret
    3473:	add    BYTE PTR [rax],al
    3475:	add    BYTE PTR [rax],al
    3477:	add    BYTE PTR [rsi],al
    3479:	add    BYTE PTR [rax],al
    347b:	add    BYTE PTR [rax],al
    347d:	add    BYTE PTR [rax],al
	...

0000000000003480 <botlish_entry_22: scan_local<generic>>:
    3480:	push   rbp
    3481:	mov    rbp,rsp
    3484:	mov    rsi,QWORD PTR [rdx]
    3487:	mov    r8,QWORD PTR [rdx+0x8]
    348b:	mov    rcx,QWORD PTR [rdx+0x10]
    348f:	mov    rdx,r8
    3492:	call   3497 <botlish_entry_22+0x17>
			3493: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_local<generic>
    3497:	mov    rsp,rbp
    349a:	pop    rbp
    349b:	ret
    349c:	add    BYTE PTR [rax],al
	...

00000000000034a0 <botlish_fn_23: scan_label<generic>>:
    34a0:	push   rbp
    34a1:	mov    rbp,rsp
    34a4:	sub    rsp,0x80
    34ab:	mov    QWORD PTR [rsp+0x50],rbx
    34b0:	mov    QWORD PTR [rsp+0x58],r12
    34b5:	mov    QWORD PTR [rsp+0x60],r13
    34ba:	mov    QWORD PTR [rsp+0x68],r14
    34bf:	mov    QWORD PTR [rsp+0x70],r15
    34c4:	mov    QWORD PTR [rsp+0x18],0x0
    34cd:	mov    QWORD PTR [rsp],rsi
    34d1:	mov    r14,rsi
    34d4:	mov    QWORD PTR [rsp+0x8],rdx
    34d9:	mov    QWORD PTR [rsp+0x10],rcx
    34de:	mov    r12,rcx
    34e1:	mov    r11d,0x1
    34e7:	mov    rsi,r14
    34ea:	test   rsi,0x1
    34f1:	jne    3511 <botlish_fn_23+0x71>
    34f7:	xor    r11d,r11d
    34fa:	test   rsi,0x7
    3501:	jne    3511 <botlish_fn_23+0x71>
    3507:	movzx  rax,BYTE PTR [rsi]
    350b:	cmp    al,0x1
    350d:	sete   r11b
    3511:	test   r11b,r11b
    3514:	jne    3532 <botlish_fn_23+0x92>
    351a:	mov    rax,QWORD PTR [rdi+0x10]
    351e:	mov    rcx,QWORD PTR [rax+0xc0]
    3525:	xor    rdx,rdx
    3528:	call   352d <botlish_fn_23+0x8d>
			3529: R_X86_64_PLT32	rt_type_error-0x4
    352d:	jmp    35de <botlish_fn_23+0x13e>
    3532:	mov    r13,rdx
    3535:	mov    rax,rsi
    3538:	and    rax,r13
    353b:	mov    r14,rsi
    353e:	test   rax,0x1
    3544:	jne    356d <botlish_fn_23+0xcd>
    354a:	mov    rbx,rdi
    354d:	mov    rdx,r13
    3550:	mov    rsi,r14
    3553:	call   3558 <botlish_fn_23+0xb8>
			3554: R_X86_64_PLT32	rt_int_cmp-0x4
    3558:	mov    ecx,0x2
    355d:	test   rax,rax
    3560:	cmovge rcx,QWORD PTR [rip+0x178]        # 36e0 <botlish_fn_23+0x240>
    3568:	jmp    3583 <botlish_fn_23+0xe3>
    356d:	mov    rbx,rdi
    3570:	mov    ecx,0x2
    3575:	mov    rsi,r14
    3578:	cmp    rsi,r13
    357b:	cmovge rcx,QWORD PTR [rip+0x15d]        # 36e0 <botlish_fn_23+0x240>
    3583:	mov    eax,0x6
    3588:	mov    QWORD PTR [rsp+0x30],rax
    358d:	cmp    rcx,0x6
    3591:	je     36b4 <botlish_fn_23+0x214>
    3597:	lea    rcx,[rsp+0x20]
    359c:	mov    rdx,r12
    359f:	mov    rsi,r14
    35a2:	mov    rdi,rbx
    35a5:	call   35aa <botlish_fn_23+0x10a>
			35a6: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    35aa:	test   rax,rax
    35ad:	mov    r15,rax
    35b0:	je     35de <botlish_fn_23+0x13e>
    35b6:	mov    rdx,QWORD PTR [rsp+0x20]
    35bb:	mov    QWORD PTR [rsp+0x40],rdx
    35c0:	mov    rcx,QWORD PTR [rsp+0x28]
    35c5:	mov    QWORD PTR [rsp+0x38],rcx
    35ca:	mov    rsi,r15
    35cd:	mov    rdi,rbx
    35d0:	call   35d5 <botlish_fn_23+0x135>
			35d1: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    35d5:	test   rax,rax
    35d8:	jne    3606 <botlish_fn_23+0x166>
    35de:	xor    rax,rax
    35e1:	mov    rbx,QWORD PTR [rsp+0x50]
    35e6:	mov    r12,QWORD PTR [rsp+0x58]
    35eb:	mov    r13,QWORD PTR [rsp+0x60]
    35f0:	mov    r14,QWORD PTR [rsp+0x68]
    35f5:	mov    r15,QWORD PTR [rsp+0x70]
    35fa:	add    rsp,0x80
    3601:	mov    rsp,rbp
    3604:	pop    rbp
    3605:	ret
    3606:	cmp    rax,0x6
    360a:	je     3635 <botlish_fn_23+0x195>
    3610:	mov    r11,QWORD PTR [rbx+0x10]
    3614:	mov    r8,QWORD PTR [r11+0x130]
    361b:	mov    rcx,QWORD PTR [rsp+0x38]
    3620:	mov    rdx,QWORD PTR [rsp+0x40]
    3625:	mov    rsi,r15
    3628:	mov    rdi,rbx
    362b:	call   3630 <botlish_fn_23+0x190>
			362c: R_X86_64_PLT32	rt_str_region_eq-0x4
    3630:	jmp    363a <botlish_fn_23+0x19a>
    3635:	mov    rax,QWORD PTR [rsp+0x30]
    363a:	cmp    rax,0x6
    363e:	je     364c <botlish_fn_23+0x1ac>
    3644:	mov    rax,r14
    3647:	jmp    36b7 <botlish_fn_23+0x217>
    364c:	mov    QWORD PTR [rsp+0x18],0x3
    3655:	mov    rsi,r14
    3658:	test   rsi,0x1
    365f:	je     3685 <botlish_fn_23+0x1e5>
    3665:	mov    rsi,r14
    3668:	mov    rax,rsi
    366b:	add    rax,0x2
    366f:	seto   cl
    3672:	test   cl,cl
    3674:	jne    3685 <botlish_fn_23+0x1e5>
    367a:	mov    rsi,rax
    367d:	mov    r14,rax
    3680:	jmp    369b <botlish_fn_23+0x1fb>
    3685:	mov    edx,0x3
    368a:	mov    rsi,r14
    368d:	mov    rdi,rbx
    3690:	call   3695 <botlish_fn_23+0x1f5>
			3691: R_X86_64_PLT32	rt_int_add-0x4
    3695:	mov    rsi,rax
    3698:	mov    r14,rax
    369b:	mov    QWORD PTR [rsp],rsi
    369f:	mov    QWORD PTR [rsp+0x8],r13
    36a4:	mov    QWORD PTR [rsp+0x10],r12
    36a9:	mov    rdx,r13
    36ac:	mov    rdi,rbx
    36af:	jmp    34e1 <botlish_fn_23+0x41>
    36b4:	mov    rax,r14
    36b7:	mov    rbx,QWORD PTR [rsp+0x50]
    36bc:	mov    r12,QWORD PTR [rsp+0x58]
    36c1:	mov    r13,QWORD PTR [rsp+0x60]
    36c6:	mov    r14,QWORD PTR [rsp+0x68]
    36cb:	mov    r15,QWORD PTR [rsp+0x70]
    36d0:	add    rsp,0x80
    36d7:	mov    rsp,rbp
    36da:	pop    rbp
    36db:	ret
    36dc:	add    BYTE PTR [rax],al
    36de:	add    BYTE PTR [rax],al
    36e0:	(bad)
    36e1:	add    BYTE PTR [rax],al
    36e3:	add    BYTE PTR [rax],al
    36e5:	add    BYTE PTR [rax],al
	...

00000000000036e8 <botlish_entry_23: scan_label<generic>>:
    36e8:	push   rbp
    36e9:	mov    rbp,rsp
    36ec:	mov    rsi,QWORD PTR [rdx]
    36ef:	mov    r8,QWORD PTR [rdx+0x8]
    36f3:	mov    rcx,QWORD PTR [rdx+0x10]
    36f7:	mov    rdx,r8
    36fa:	call   36ff <botlish_entry_23+0x17>
			36fb: R_X86_64_PLT32	botlish_fn_23-0x4 ; scan_label<generic>
    36ff:	mov    rsp,rbp
    3702:	pop    rbp
    3703:	ret
    3704:	add    BYTE PTR [rax],al
	...

0000000000003708 <botlish_fn_24: scan_alpha<generic>>:
    3708:	push   rbp
    3709:	mov    rbp,rsp
    370c:	sub    rsp,0x50
    3710:	mov    QWORD PTR [rsp+0x30],rbx
    3715:	mov    QWORD PTR [rsp+0x38],r12
    371a:	mov    QWORD PTR [rsp+0x40],r13
    371f:	mov    QWORD PTR [rsp+0x48],r14
    3724:	mov    r14,rdi
    3727:	mov    QWORD PTR [rsp+0x18],0x0
    3730:	mov    QWORD PTR [rsp],rsi
    3734:	mov    r13,rsi
    3737:	mov    QWORD PTR [rsp+0x8],rdx
    373c:	mov    r12,rdx
    373f:	mov    QWORD PTR [rsp+0x10],rcx
    3744:	mov    rbx,rcx
    3747:	mov    r11d,0x1
    374d:	mov    rsi,r13
    3750:	test   rsi,0x1
    3757:	jne    3777 <botlish_fn_24+0x6f>
    375d:	xor    r11d,r11d
    3760:	test   rsi,0x7
    3767:	jne    3777 <botlish_fn_24+0x6f>
    376d:	movzx  rax,BYTE PTR [rsi]
    3771:	cmp    al,0x1
    3773:	sete   r11b
    3777:	test   r11b,r11b
    377a:	jne    379b <botlish_fn_24+0x93>
    3780:	mov    rdi,r14
    3783:	mov    rax,QWORD PTR [rdi+0x10]
    3787:	mov    rcx,QWORD PTR [rax+0xc0]
    378e:	xor    rdx,rdx
    3791:	call   3796 <botlish_fn_24+0x8e>
			3792: R_X86_64_PLT32	rt_type_error-0x4
    3796:	jmp    382a <botlish_fn_24+0x122>
    379b:	mov    rax,rsi
    379e:	and    rax,r12
    37a1:	mov    r13,rsi
    37a4:	test   rax,0x1
    37aa:	jne    37d3 <botlish_fn_24+0xcb>
    37b0:	mov    rdx,r12
    37b3:	mov    rsi,r13
    37b6:	mov    rdi,r14
    37b9:	call   37be <botlish_fn_24+0xb6>
			37ba: R_X86_64_PLT32	rt_int_cmp-0x4
    37be:	mov    ecx,0x2
    37c3:	test   rax,rax
    37c6:	cmovge rcx,QWORD PTR [rip+0x112]        # 38e0 <botlish_fn_24+0x1d8>
    37ce:	jmp    37e6 <botlish_fn_24+0xde>
    37d3:	mov    ecx,0x2
    37d8:	mov    rsi,r13
    37db:	cmp    rsi,r12
    37de:	cmovge rcx,QWORD PTR [rip+0xfa]        # 38e0 <botlish_fn_24+0x1d8>
    37e6:	cmp    rcx,0x6
    37ea:	je     38be <botlish_fn_24+0x1b6>
    37f0:	lea    rcx,[rsp+0x20]
    37f5:	mov    rdx,rbx
    37f8:	mov    rsi,r13
    37fb:	mov    rdi,r14
    37fe:	call   3803 <botlish_fn_24+0xfb>
			37ff: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    3803:	test   rax,rax
    3806:	mov    rsi,rax
    3809:	je     382a <botlish_fn_24+0x122>
    380f:	mov    rdx,QWORD PTR [rsp+0x20]
    3814:	mov    rcx,QWORD PTR [rsp+0x28]
    3819:	mov    rdi,r14
    381c:	call   3821 <botlish_fn_24+0x119>
			381d: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    3821:	test   rax,rax
    3824:	jne    384a <botlish_fn_24+0x142>
    382a:	xor    rax,rax
    382d:	mov    rbx,QWORD PTR [rsp+0x30]
    3832:	mov    r12,QWORD PTR [rsp+0x38]
    3837:	mov    r13,QWORD PTR [rsp+0x40]
    383c:	mov    r14,QWORD PTR [rsp+0x48]
    3841:	add    rsp,0x50
    3845:	mov    rsp,rbp
    3848:	pop    rbp
    3849:	ret
    384a:	cmp    rax,0x6
    384e:	je     385c <botlish_fn_24+0x154>
    3854:	mov    rax,r13
    3857:	jmp    38c1 <botlish_fn_24+0x1b9>
    385c:	mov    QWORD PTR [rsp+0x18],0x3
    3865:	mov    rsi,r13
    3868:	test   rsi,0x1
    386f:	je     3895 <botlish_fn_24+0x18d>
    3875:	mov    rsi,r13
    3878:	mov    r11,rsi
    387b:	add    r11,0x2
    387f:	seto   al
    3882:	test   al,al
    3884:	jne    3895 <botlish_fn_24+0x18d>
    388a:	mov    rsi,r11
    388d:	mov    r13,r11
    3890:	jmp    38ab <botlish_fn_24+0x1a3>
    3895:	mov    edx,0x3
    389a:	mov    rsi,r13
    389d:	mov    rdi,r14
    38a0:	call   38a5 <botlish_fn_24+0x19d>
			38a1: R_X86_64_PLT32	rt_int_add-0x4
    38a5:	mov    rsi,rax
    38a8:	mov    r13,rax
    38ab:	mov    QWORD PTR [rsp],rsi
    38af:	mov    QWORD PTR [rsp+0x8],r12
    38b4:	mov    QWORD PTR [rsp+0x10],rbx
    38b9:	jmp    3747 <botlish_fn_24+0x3f>
    38be:	mov    rax,r13
    38c1:	mov    rbx,QWORD PTR [rsp+0x30]
    38c6:	mov    r12,QWORD PTR [rsp+0x38]
    38cb:	mov    r13,QWORD PTR [rsp+0x40]
    38d0:	mov    r14,QWORD PTR [rsp+0x48]
    38d5:	add    rsp,0x50
    38d9:	mov    rsp,rbp
    38dc:	pop    rbp
    38dd:	ret
    38de:	add    BYTE PTR [rax],al
    38e0:	(bad)
    38e1:	add    BYTE PTR [rax],al
    38e3:	add    BYTE PTR [rax],al
    38e5:	add    BYTE PTR [rax],al
	...

00000000000038e8 <botlish_entry_24: scan_alpha<generic>>:
    38e8:	push   rbp
    38e9:	mov    rbp,rsp
    38ec:	mov    rsi,QWORD PTR [rdx]
    38ef:	mov    r8,QWORD PTR [rdx+0x8]
    38f3:	mov    rcx,QWORD PTR [rdx+0x10]
    38f7:	mov    rdx,r8
    38fa:	call   38ff <botlish_entry_24+0x17>
			38fb: R_X86_64_PLT32	botlish_fn_24-0x4 ; scan_alpha<generic>
    38ff:	mov    rsp,rbp
    3902:	pop    rbp
    3903:	ret
    3904:	add    BYTE PTR [rax],al
	...

0000000000003908 <botlish_fn_25: tld_ok<generic>>:
    3908:	push   rbp
    3909:	mov    rbp,rsp
    390c:	sub    rsp,0x40
    3910:	mov    QWORD PTR [rsp+0x20],rbx
    3915:	mov    QWORD PTR [rsp+0x28],r12
    391a:	mov    QWORD PTR [rsp+0x30],r13
    391f:	mov    QWORD PTR [rsp+0x38],r14
    3924:	mov    rbx,rdi
    3927:	mov    QWORD PTR [rsp],rsi
    392b:	mov    r12,rsi
    392e:	mov    QWORD PTR [rsp+0x8],rdx
    3933:	mov    r14,rdx
    3936:	mov    QWORD PTR [rsp+0x10],rcx
    393b:	mov    rdx,r14
    393e:	mov    rsi,r12
    3941:	mov    rdi,rbx
    3944:	call   3949 <botlish_fn_25+0x41>
			3945: R_X86_64_PLT32	botlish_fn_24-0x4 ; scan_alpha<generic>
    3949:	mov    rsi,rax
    394c:	mov    r13,rax
    394f:	test   rax,rsi
    3952:	je     3a15 <botlish_fn_25+0x10d>
    3958:	mov    rax,r13
    395b:	mov    QWORD PTR [rsp+0x8],rax
    3960:	mov    rdx,r14
    3963:	and    rax,rdx
    3966:	test   rax,0x1
    396c:	jne    3995 <botlish_fn_25+0x8d>
    3972:	mov    rsi,r13
    3975:	mov    rdi,rbx
    3978:	call   397d <botlish_fn_25+0x75>
			3979: R_X86_64_PLT32	rt_int_cmp-0x4
    397d:	mov    ecx,0x2
    3982:	test   rax,rax
    3985:	cmove  rcx,QWORD PTR [rip+0x15b]        # 3ae8 <botlish_fn_25+0x1e0>
    398d:	mov    rax,r13
    3990:	jmp    39a8 <botlish_fn_25+0xa0>
    3995:	mov    ecx,0x2
    399a:	mov    rax,r13
    399d:	cmp    rax,rdx
    39a0:	cmove  rcx,QWORD PTR [rip+0x140]        # 3ae8 <botlish_fn_25+0x1e0>
    39a8:	cmp    rcx,0x6
    39ac:	je     39bf <botlish_fn_25+0xb7>
    39b2:	mov    ecx,0x2
    39b7:	mov    rax,rcx
    39ba:	jmp    3ac7 <botlish_fn_25+0x1bf>
    39bf:	mov    ecx,0x1
    39c4:	mov    rsi,r12
    39c7:	test   rsi,0x1
    39ce:	jne    39f4 <botlish_fn_25+0xec>
    39d4:	xor    ecx,ecx
    39d6:	mov    rsi,r12
    39d9:	test   rsi,0x7
    39e0:	jne    39f4 <botlish_fn_25+0xec>
    39e6:	mov    rsi,r12
    39e9:	movzx  rcx,BYTE PTR [rsi]
    39ed:	rex cmp cl,0x1
    39f1:	sete   cl
    39f4:	test   cl,cl
    39f6:	jne    3a35 <botlish_fn_25+0x12d>
    39fc:	mov    rdi,rbx
    39ff:	mov    rsi,QWORD PTR [rdi+0x10]
    3a03:	mov    rcx,QWORD PTR [rsi+0x130]
    3a0a:	xor    rdx,rdx
    3a0d:	mov    rsi,r12
    3a10:	call   3a15 <botlish_fn_25+0x10d>
			3a11: R_X86_64_PLT32	rt_type_error-0x4
    3a15:	xor    rax,rax
    3a18:	mov    rbx,QWORD PTR [rsp+0x20]
    3a1d:	mov    r12,QWORD PTR [rsp+0x28]
    3a22:	mov    r13,QWORD PTR [rsp+0x30]
    3a27:	mov    r14,QWORD PTR [rsp+0x38]
    3a2c:	add    rsp,0x40
    3a30:	mov    rsp,rbp
    3a33:	pop    rbp
    3a34:	ret
    3a35:	mov    rsi,r12
    3a38:	mov    rdi,rax
    3a3b:	and    rdi,rsi
    3a3e:	test   rdi,0x1
    3a45:	jne    3a56 <botlish_fn_25+0x14e>
    3a4b:	mov    rdx,r12
    3a4e:	mov    rsi,rax
    3a51:	jmp    3a79 <botlish_fn_25+0x171>
    3a56:	mov    rsi,r12
    3a59:	mov    r8,rax
    3a5c:	sub    r8,rsi
    3a5f:	mov    r13,rax
    3a62:	seto   r10b
    3a66:	lea    rsi,[r8+0x1]
    3a6a:	test   r10b,r10b
    3a6d:	je     3a84 <botlish_fn_25+0x17c>
    3a73:	mov    rdx,r12
    3a76:	mov    rsi,r13
    3a79:	mov    rdi,rbx
    3a7c:	call   3a81 <botlish_fn_25+0x179>
			3a7d: R_X86_64_PLT32	rt_int_sub-0x4
    3a81:	mov    rsi,rax
    3a84:	test   rsi,0x1
    3a8b:	jne    3ab6 <botlish_fn_25+0x1ae>
    3a91:	mov    edx,0x5
    3a96:	mov    rdi,rbx
    3a99:	call   3a9e <botlish_fn_25+0x196>
			3a9a: R_X86_64_PLT32	rt_int_cmp-0x4
    3a9e:	mov    ecx,0x2
    3aa3:	test   rax,rax
    3aa6:	mov    rax,rcx
    3aa9:	cmovge rax,QWORD PTR [rip+0x37]        # 3ae8 <botlish_fn_25+0x1e0>
    3ab1:	jmp    3ac7 <botlish_fn_25+0x1bf>
    3ab6:	mov    eax,0x2
    3abb:	cmp    rsi,0x5
    3abf:	cmovge rax,QWORD PTR [rip+0x21]        # 3ae8 <botlish_fn_25+0x1e0>
    3ac7:	mov    rbx,QWORD PTR [rsp+0x20]
    3acc:	mov    r12,QWORD PTR [rsp+0x28]
    3ad1:	mov    r13,QWORD PTR [rsp+0x30]
    3ad6:	mov    r14,QWORD PTR [rsp+0x38]
    3adb:	add    rsp,0x40
    3adf:	mov    rsp,rbp
    3ae2:	pop    rbp
    3ae3:	ret
    3ae4:	add    BYTE PTR [rax],al
    3ae6:	add    BYTE PTR [rax],al
    3ae8:	(bad)
    3ae9:	add    BYTE PTR [rax],al
    3aeb:	add    BYTE PTR [rax],al
    3aed:	add    BYTE PTR [rax],al
	...

0000000000003af0 <botlish_entry_25: tld_ok<generic>>:
    3af0:	push   rbp
    3af1:	mov    rbp,rsp
    3af4:	mov    rsi,QWORD PTR [rdx]
    3af7:	mov    r8,QWORD PTR [rdx+0x8]
    3afb:	mov    rcx,QWORD PTR [rdx+0x10]
    3aff:	mov    rdx,r8
    3b02:	call   3b07 <botlish_entry_25+0x17>
			3b03: R_X86_64_PLT32	botlish_fn_25-0x4 ; tld_ok<generic>
    3b07:	mov    rsp,rbp
    3b0a:	pop    rbp
    3b0b:	ret
    3b0c:	add    BYTE PTR [rax],al
	...

0000000000003b10 <botlish_fn_26: domain_loop<generic>>:
    3b10:	push   rbp
    3b11:	mov    rbp,rsp
    3b14:	sub    rsp,0x70
    3b18:	mov    QWORD PTR [rsp+0x40],rbx
    3b1d:	mov    QWORD PTR [rsp+0x48],r12
    3b22:	mov    QWORD PTR [rsp+0x50],r13
    3b27:	mov    QWORD PTR [rsp+0x58],r14
    3b2c:	mov    QWORD PTR [rsp+0x60],r15
    3b31:	mov    QWORD PTR [rsp+0x18],0x0
    3b3a:	mov    QWORD PTR [rsp],rsi
    3b3e:	mov    QWORD PTR [rsp+0x8],rdx
    3b43:	mov    QWORD PTR [rsp+0x10],rcx
    3b48:	lea    rbx,[rsp+0x20]
    3b4d:	mov    r12,rdi
    3b50:	mov    r13,rcx
    3b53:	mov    r14,rdx
    3b56:	mov    QWORD PTR [rsp+0x30],rsi
    3b5b:	mov    rcx,r13
    3b5e:	mov    rdx,r14
    3b61:	mov    rsi,QWORD PTR [rsp+0x30]
    3b66:	mov    rdi,r12
    3b69:	call   3b6e <botlish_fn_26+0x5e>
			3b6a: R_X86_64_PLT32	botlish_fn_23-0x4 ; scan_label<generic>
    3b6e:	mov    rcx,rax
    3b71:	mov    r15,rax
    3b74:	test   rax,rcx
    3b77:	je     3cc7 <botlish_fn_26+0x1b7>
    3b7d:	mov    rax,r15
    3b80:	mov    QWORD PTR [rsp],rax
    3b84:	mov    rdx,QWORD PTR [rsp+0x30]
    3b89:	and    rax,rdx
    3b8c:	test   rax,0x1
    3b92:	jne    3bb1 <botlish_fn_26+0xa1>
    3b98:	mov    rsi,r15
    3b9b:	mov    rdi,r12
    3b9e:	call   3ba3 <botlish_fn_26+0x93>
			3b9f: R_X86_64_PLT32	rt_value_eq-0x4
    3ba3:	test   rax,rax
    3ba6:	je     3cc7 <botlish_fn_26+0x1b7>
    3bac:	jmp    3bc1 <botlish_fn_26+0xb1>
    3bb1:	mov    eax,0x2
    3bb6:	cmp    r15,rdx
    3bb9:	cmove  rax,QWORD PTR [rip+0x187]        # 3d48 <botlish_fn_26+0x238>
    3bc1:	cmp    rax,0x6
    3bc5:	je     3d1d <botlish_fn_26+0x20d>
    3bcb:	mov    rax,r15
    3bce:	and    rax,r14
    3bd1:	test   rax,0x1
    3bd7:	jne    3c00 <botlish_fn_26+0xf0>
    3bdd:	mov    rdx,r14
    3be0:	mov    rsi,r15
    3be3:	mov    rdi,r12
    3be6:	call   3beb <botlish_fn_26+0xdb>
			3be7: R_X86_64_PLT32	rt_int_cmp-0x4
    3beb:	mov    ecx,0x2
    3bf0:	test   rax,rax
    3bf3:	cmovge rcx,QWORD PTR [rip+0x14d]        # 3d48 <botlish_fn_26+0x238>
    3bfb:	jmp    3c10 <botlish_fn_26+0x100>
    3c00:	mov    ecx,0x2
    3c05:	cmp    r15,r14
    3c08:	cmovge rcx,QWORD PTR [rip+0x138]        # 3d48 <botlish_fn_26+0x238>
    3c10:	cmp    rcx,0x6
    3c14:	je     3d0e <botlish_fn_26+0x1fe>
    3c1a:	mov    rcx,rbx
    3c1d:	mov    rdx,r13
    3c20:	mov    rsi,r15
    3c23:	mov    rdi,r12
    3c26:	call   3c2b <botlish_fn_26+0x11b>
			3c27: R_X86_64_PLT32	botlish_fn_21-0x4 ; char_at<generic>
    3c2b:	test   rax,rax
    3c2e:	je     3cc7 <botlish_fn_26+0x1b7>
    3c34:	mov    rdx,QWORD PTR [rsp+0x20]
    3c39:	mov    rcx,QWORD PTR [rsp+0x28]
    3c3e:	mov    rsi,QWORD PTR [r12+0x10]
    3c43:	mov    r8,QWORD PTR [rsi+0x120]
    3c4a:	mov    rsi,rax
    3c4d:	mov    rdi,r12
    3c50:	call   3c55 <botlish_fn_26+0x145>
			3c51: R_X86_64_PLT32	rt_str_region_eq-0x4
    3c55:	cmp    rax,0x6
    3c59:	je     3c6b <botlish_fn_26+0x15b>
    3c5f:	mov    r14,0xffffffffffffffff
    3c66:	jmp    3d15 <botlish_fn_26+0x205>
    3c6b:	mov    QWORD PTR [rsp+0x18],0x3
    3c74:	test   r15,0x1
    3c7b:	je     3c93 <botlish_fn_26+0x183>
    3c81:	mov    rdx,r15
    3c84:	add    rdx,0x2
    3c88:	seto   al
    3c8b:	test   al,al
    3c8d:	je     3ca6 <botlish_fn_26+0x196>
    3c93:	mov    edx,0x3
    3c98:	mov    rsi,r15
    3c9b:	mov    rdi,r12
    3c9e:	call   3ca3 <botlish_fn_26+0x193>
			3c9f: R_X86_64_PLT32	rt_int_add-0x4
    3ca3:	mov    rdx,rax
    3ca6:	mov    QWORD PTR [rsp],rdx
    3caa:	mov    r15,rdx
    3cad:	mov    rcx,r13
    3cb0:	mov    rdx,r14
    3cb3:	mov    rsi,r15
    3cb6:	mov    rdi,r12
    3cb9:	call   3cbe <botlish_fn_26+0x1ae>
			3cba: R_X86_64_PLT32	botlish_fn_25-0x4 ; tld_ok<generic>
    3cbe:	test   rax,rax
    3cc1:	jne    3cec <botlish_fn_26+0x1dc>
    3cc7:	xor    rax,rax
    3cca:	mov    rbx,QWORD PTR [rsp+0x40]
    3ccf:	mov    r12,QWORD PTR [rsp+0x48]
    3cd4:	mov    r13,QWORD PTR [rsp+0x50]
    3cd9:	mov    r14,QWORD PTR [rsp+0x58]
    3cde:	mov    r15,QWORD PTR [rsp+0x60]
    3ce3:	add    rsp,0x70
    3ce7:	mov    rsp,rbp
    3cea:	pop    rbp
    3ceb:	ret
    3cec:	cmp    rax,0x6
    3cf0:	je     3d15 <botlish_fn_26+0x205>
    3cf6:	mov    QWORD PTR [rsp],r15
    3cfa:	mov    QWORD PTR [rsp+0x8],r14
    3cff:	mov    QWORD PTR [rsp+0x10],r13
    3d04:	mov    QWORD PTR [rsp+0x30],r15
    3d09:	jmp    3b5b <botlish_fn_26+0x4b>
    3d0e:	mov    r14,0xffffffffffffffff
    3d15:	mov    rax,r14
    3d18:	jmp    3d24 <botlish_fn_26+0x214>
    3d1d:	mov    rax,0xffffffffffffffff
    3d24:	mov    rbx,QWORD PTR [rsp+0x40]
    3d29:	mov    r12,QWORD PTR [rsp+0x48]
    3d2e:	mov    r13,QWORD PTR [rsp+0x50]
    3d33:	mov    r14,QWORD PTR [rsp+0x58]
    3d38:	mov    r15,QWORD PTR [rsp+0x60]
    3d3d:	add    rsp,0x70
    3d41:	mov    rsp,rbp
    3d44:	pop    rbp
    3d45:	ret
    3d46:	add    BYTE PTR [rax],al
    3d48:	(bad)
    3d49:	add    BYTE PTR [rax],al
    3d4b:	add    BYTE PTR [rax],al
    3d4d:	add    BYTE PTR [rax],al
	...

0000000000003d50 <botlish_entry_26: domain_loop<generic>>:
    3d50:	push   rbp
    3d51:	mov    rbp,rsp
    3d54:	mov    rsi,QWORD PTR [rdx]
    3d57:	mov    r8,QWORD PTR [rdx+0x8]
    3d5b:	mov    rcx,QWORD PTR [rdx+0x10]
    3d5f:	mov    rdx,r8
    3d62:	call   3d67 <botlish_entry_26+0x17>
			3d63: R_X86_64_PLT32	botlish_fn_26-0x4 ; domain_loop<generic>
    3d67:	mov    rsp,rbp
    3d6a:	pop    rbp
    3d6b:	ret

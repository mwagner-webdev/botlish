; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 16284  (per function: 935 112 214 1425 484 864 506 952 504 681 769 450 884 644 540 540 636 681 769 450 884 644 540 540 636)
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

0000000000000402 <botlish_fn_2: high_nibble<generic>>:
     402:	push   rbp
     403:	mov    rbp,rsp
     406:	sub    rsp,0x20
     40a:	mov    QWORD PTR [rsp+0x10],rbx
     40f:	mov    QWORD PTR [rsp],rsi
     413:	mov    QWORD PTR [rsp+0x8],0x1e1
     41c:	mov    r8d,0x1
     422:	test   rsi,0x1
     429:	jne    449 <botlish_fn_2+0x47>
     42f:	xor    r8d,r8d
     432:	test   rsi,0x7
     439:	jne    449 <botlish_fn_2+0x47>
     43f:	movzx  rax,BYTE PTR [rsi]
     443:	cmp    al,0x1
     445:	sete   r8b
     449:	test   r8b,r8b
     44c:	jne    479 <botlish_fn_2+0x77>
     452:	mov    rax,QWORD PTR [rdi+0x10]
     456:	mov    rcx,QWORD PTR [rax+0xa0]
     45d:	xor    rbx,rbx
     460:	mov    rdx,rbx
     463:	call   468 <botlish_fn_2+0x66>
			464: R_X86_64_PLT32	rt_type_error-0x4
     468:	mov    rax,rbx
     46b:	mov    rbx,QWORD PTR [rsp+0x10]
     470:	add    rsp,0x20
     474:	mov    rsp,rbp
     477:	pop    rbp
     478:	ret
     479:	test   rsi,0x1
     480:	jne    495 <botlish_fn_2+0x93>
     486:	mov    edx,0x1e1
     48b:	call   490 <botlish_fn_2+0x8e>
			48c: R_X86_64_PLT32	rt_int_and-0x4
     490:	jmp    49f <botlish_fn_2+0x9d>
     495:	and    rsi,0x1e1
     49c:	mov    rax,rsi
     49f:	sar    rax,0x5
     4a3:	shl    rax,1
     4a6:	or     rax,0x1
     4aa:	mov    rbx,QWORD PTR [rsp+0x10]
     4af:	add    rsp,0x20
     4b3:	mov    rsp,rbp
     4b6:	pop    rbp
     4b7:	ret

00000000000004b8 <botlish_entry_2: high_nibble<generic>>:
     4b8:	push   rbp
     4b9:	mov    rbp,rsp
     4bc:	mov    rsi,QWORD PTR [rdx]
     4bf:	call   4c4 <botlish_entry_2+0xc>
			4c0: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
     4c4:	mov    rsp,rbp
     4c7:	pop    rbp
     4c8:	ret
     4c9:	add    BYTE PTR [rax],al
     4cb:	add    BYTE PTR [rax],al
     4cd:	add    BYTE PTR [rax],al
	...

00000000000004d0 <botlish_fn_3: is_unreserved<generic>>:
     4d0:	push   rbp
     4d1:	mov    rbp,rsp
     4d4:	sub    rsp,0x20
     4d8:	mov    QWORD PTR [rsp],rbx
     4dc:	mov    QWORD PTR [rsp+0x8],r12
     4e1:	mov    QWORD PTR [rsp+0x10],r13
     4e6:	mov    r8d,0x1
     4ec:	test   rsi,0x1
     4f3:	jne    513 <botlish_fn_3+0x43>
     4f9:	xor    r8d,r8d
     4fc:	test   rsi,0x7
     503:	jne    513 <botlish_fn_3+0x43>
     509:	movzx  rax,BYTE PTR [rsi]
     50d:	cmp    al,0x1
     50f:	sete   r8b
     513:	test   r8b,r8b
     516:	jne    54c <botlish_fn_3+0x7c>
     51c:	mov    rdx,QWORD PTR [rdi+0x10]
     520:	mov    rcx,QWORD PTR [rdx+0xa8]
     527:	xor    rbx,rbx
     52a:	mov    rdx,rbx
     52d:	call   532 <botlish_fn_3+0x62>
			52e: R_X86_64_PLT32	rt_type_error-0x4
     532:	mov    rax,rbx
     535:	mov    rbx,QWORD PTR [rsp]
     539:	mov    r12,QWORD PTR [rsp+0x8]
     53e:	mov    r13,QWORD PTR [rsp+0x10]
     543:	add    rsp,0x20
     547:	mov    rsp,rbp
     54a:	pop    rbp
     54b:	ret
     54c:	mov    r12,rdi
     54f:	test   rsi,0x1
     556:	mov    rbx,rsi
     559:	jne    584 <botlish_fn_3+0xb4>
     55f:	mov    edx,0x59
     564:	mov    rsi,rbx
     567:	mov    rdi,r12
     56a:	call   56f <botlish_fn_3+0x9f>
			56b: R_X86_64_PLT32	rt_int_cmp-0x4
     56f:	mov    ecx,0x2
     574:	test   rax,rax
     577:	cmovle rcx,QWORD PTR [rip+0x461]        # 9e0 <botlish_fn_3+0x510>
     57f:	jmp    598 <botlish_fn_3+0xc8>
     584:	mov    ecx,0x2
     589:	mov    rsi,rbx
     58c:	cmp    rsi,0x59
     590:	cmovle rcx,QWORD PTR [rip+0x448]        # 9e0 <botlish_fn_3+0x510>
     598:	mov    eax,0x6
     59d:	mov    r13,rax
     5a0:	cmp    rcx,0x6
     5a4:	je     9c3 <botlish_fn_3+0x4f3>
     5aa:	mov    rsi,rbx
     5ad:	test   rsi,0x1
     5b4:	jne    5df <botlish_fn_3+0x10f>
     5ba:	mov    edx,0x5d
     5bf:	mov    rsi,rbx
     5c2:	mov    rdi,r12
     5c5:	call   5ca <botlish_fn_3+0xfa>
			5c6: R_X86_64_PLT32	rt_int_cmp-0x4
     5ca:	mov    ecx,0x2
     5cf:	test   rax,rax
     5d2:	cmovle rcx,QWORD PTR [rip+0x406]        # 9e0 <botlish_fn_3+0x510>
     5da:	jmp    5f3 <botlish_fn_3+0x123>
     5df:	mov    ecx,0x2
     5e4:	mov    rsi,rbx
     5e7:	cmp    rsi,0x5d
     5eb:	cmovle rcx,QWORD PTR [rip+0x3ed]        # 9e0 <botlish_fn_3+0x510>
     5f3:	cmp    rcx,0x6
     5f7:	je     9bb <botlish_fn_3+0x4eb>
     5fd:	mov    rsi,rbx
     600:	test   rsi,0x1
     607:	jne    632 <botlish_fn_3+0x162>
     60d:	mov    edx,0x5f
     612:	mov    rsi,rbx
     615:	mov    rdi,r12
     618:	call   61d <botlish_fn_3+0x14d>
			619: R_X86_64_PLT32	rt_int_cmp-0x4
     61d:	mov    ecx,0x2
     622:	test   rax,rax
     625:	cmovle rcx,QWORD PTR [rip+0x3b3]        # 9e0 <botlish_fn_3+0x510>
     62d:	jmp    646 <botlish_fn_3+0x176>
     632:	mov    ecx,0x2
     637:	mov    rsi,rbx
     63a:	cmp    rsi,0x5f
     63e:	cmovle rcx,QWORD PTR [rip+0x39a]        # 9e0 <botlish_fn_3+0x510>
     646:	cmp    rcx,0x6
     64a:	je     9b1 <botlish_fn_3+0x4e1>
     650:	mov    rsi,rbx
     653:	test   rsi,0x1
     65a:	jne    685 <botlish_fn_3+0x1b5>
     660:	mov    edx,0x73
     665:	mov    rsi,rbx
     668:	mov    rdi,r12
     66b:	call   670 <botlish_fn_3+0x1a0>
			66c: R_X86_64_PLT32	rt_int_cmp-0x4
     670:	mov    ecx,0x2
     675:	test   rax,rax
     678:	cmovle rcx,QWORD PTR [rip+0x360]        # 9e0 <botlish_fn_3+0x510>
     680:	jmp    699 <botlish_fn_3+0x1c9>
     685:	mov    ecx,0x2
     68a:	mov    rsi,rbx
     68d:	cmp    rsi,0x73
     691:	cmovle rcx,QWORD PTR [rip+0x347]        # 9e0 <botlish_fn_3+0x510>
     699:	cmp    rcx,0x6
     69d:	je     9a9 <botlish_fn_3+0x4d9>
     6a3:	mov    rsi,rbx
     6a6:	test   rsi,0x1
     6ad:	jne    6d8 <botlish_fn_3+0x208>
     6b3:	mov    edx,0x81
     6b8:	mov    rsi,rbx
     6bb:	mov    rdi,r12
     6be:	call   6c3 <botlish_fn_3+0x1f3>
			6bf: R_X86_64_PLT32	rt_int_cmp-0x4
     6c3:	mov    ecx,0x2
     6c8:	test   rax,rax
     6cb:	cmovle rcx,QWORD PTR [rip+0x30d]        # 9e0 <botlish_fn_3+0x510>
     6d3:	jmp    6ef <botlish_fn_3+0x21f>
     6d8:	mov    ecx,0x2
     6dd:	mov    rsi,rbx
     6e0:	cmp    rsi,0x81
     6e7:	cmovle rcx,QWORD PTR [rip+0x2f1]        # 9e0 <botlish_fn_3+0x510>
     6ef:	cmp    rcx,0x6
     6f3:	je     99f <botlish_fn_3+0x4cf>
     6f9:	mov    rsi,rbx
     6fc:	test   rsi,0x1
     703:	jne    72e <botlish_fn_3+0x25e>
     709:	mov    edx,0xb5
     70e:	mov    rsi,rbx
     711:	mov    rdi,r12
     714:	call   719 <botlish_fn_3+0x249>
			715: R_X86_64_PLT32	rt_int_cmp-0x4
     719:	mov    ecx,0x2
     71e:	test   rax,rax
     721:	cmovle rcx,QWORD PTR [rip+0x2b7]        # 9e0 <botlish_fn_3+0x510>
     729:	jmp    745 <botlish_fn_3+0x275>
     72e:	mov    ecx,0x2
     733:	mov    rsi,rbx
     736:	cmp    rsi,0xb5
     73d:	cmovle rcx,QWORD PTR [rip+0x29b]        # 9e0 <botlish_fn_3+0x510>
     745:	cmp    rcx,0x6
     749:	je     997 <botlish_fn_3+0x4c7>
     74f:	mov    rsi,rbx
     752:	test   rsi,0x1
     759:	jne    784 <botlish_fn_3+0x2b4>
     75f:	mov    edx,0xbd
     764:	mov    rsi,rbx
     767:	mov    rdi,r12
     76a:	call   76f <botlish_fn_3+0x29f>
			76b: R_X86_64_PLT32	rt_int_cmp-0x4
     76f:	mov    ecx,0x2
     774:	test   rax,rax
     777:	cmovle rcx,QWORD PTR [rip+0x261]        # 9e0 <botlish_fn_3+0x510>
     77f:	jmp    79b <botlish_fn_3+0x2cb>
     784:	mov    ecx,0x2
     789:	mov    rsi,rbx
     78c:	cmp    rsi,0xbd
     793:	cmovle rcx,QWORD PTR [rip+0x245]        # 9e0 <botlish_fn_3+0x510>
     79b:	cmp    rcx,0x6
     79f:	je     98d <botlish_fn_3+0x4bd>
     7a5:	mov    rsi,rbx
     7a8:	test   rsi,0x1
     7af:	jne    7db <botlish_fn_3+0x30b>
     7b5:	mov    edx,0xbf
     7ba:	mov    rsi,rbx
     7bd:	mov    rdi,r12
     7c0:	call   7c5 <botlish_fn_3+0x2f5>
			7c1: R_X86_64_PLT32	rt_int_cmp-0x4
     7c5:	mov    r11d,0x2
     7cb:	test   rax,rax
     7ce:	cmovle r11,QWORD PTR [rip+0x20a]        # 9e0 <botlish_fn_3+0x510>
     7d6:	jmp    7f3 <botlish_fn_3+0x323>
     7db:	mov    r11d,0x2
     7e1:	mov    rsi,rbx
     7e4:	cmp    rsi,0xbf
     7eb:	cmovle r11,QWORD PTR [rip+0x1ed]        # 9e0 <botlish_fn_3+0x510>
     7f3:	cmp    r11,0x6
     7f7:	je     985 <botlish_fn_3+0x4b5>
     7fd:	mov    rsi,rbx
     800:	test   rsi,0x1
     807:	jne    832 <botlish_fn_3+0x362>
     80d:	mov    edx,0xc1
     812:	mov    rsi,rbx
     815:	mov    rdi,r12
     818:	call   81d <botlish_fn_3+0x34d>
			819: R_X86_64_PLT32	rt_int_cmp-0x4
     81d:	mov    ecx,0x2
     822:	test   rax,rax
     825:	cmovle rcx,QWORD PTR [rip+0x1b3]        # 9e0 <botlish_fn_3+0x510>
     82d:	jmp    849 <botlish_fn_3+0x379>
     832:	mov    ecx,0x2
     837:	mov    rsi,rbx
     83a:	cmp    rsi,0xc1
     841:	cmovle rcx,QWORD PTR [rip+0x197]        # 9e0 <botlish_fn_3+0x510>
     849:	cmp    rcx,0x6
     84d:	je     97b <botlish_fn_3+0x4ab>
     853:	mov    rsi,rbx
     856:	test   rsi,0x1
     85d:	jne    888 <botlish_fn_3+0x3b8>
     863:	mov    edx,0xf5
     868:	mov    rsi,rbx
     86b:	mov    rdi,r12
     86e:	call   873 <botlish_fn_3+0x3a3>
			86f: R_X86_64_PLT32	rt_int_cmp-0x4
     873:	mov    ecx,0x2
     878:	test   rax,rax
     87b:	cmovle rcx,QWORD PTR [rip+0x15d]        # 9e0 <botlish_fn_3+0x510>
     883:	jmp    89f <botlish_fn_3+0x3cf>
     888:	mov    ecx,0x2
     88d:	mov    rsi,rbx
     890:	cmp    rsi,0xf5
     897:	cmovle rcx,QWORD PTR [rip+0x141]        # 9e0 <botlish_fn_3+0x510>
     89f:	cmp    rcx,0x6
     8a3:	je     973 <botlish_fn_3+0x4a3>
     8a9:	mov    rsi,rbx
     8ac:	test   rsi,0x1
     8b3:	jne    8de <botlish_fn_3+0x40e>
     8b9:	mov    edx,0xfb
     8be:	mov    rsi,rbx
     8c1:	mov    rdi,r12
     8c4:	call   8c9 <botlish_fn_3+0x3f9>
			8c5: R_X86_64_PLT32	rt_int_cmp-0x4
     8c9:	mov    ecx,0x2
     8ce:	test   rax,rax
     8d1:	cmovle rcx,QWORD PTR [rip+0x107]        # 9e0 <botlish_fn_3+0x510>
     8d9:	jmp    8f5 <botlish_fn_3+0x425>
     8de:	mov    ecx,0x2
     8e3:	mov    rsi,rbx
     8e6:	cmp    rsi,0xfb
     8ed:	cmovle rcx,QWORD PTR [rip+0xeb]        # 9e0 <botlish_fn_3+0x510>
     8f5:	cmp    rcx,0x6
     8f9:	je     969 <botlish_fn_3+0x499>
     8ff:	mov    rsi,rbx
     902:	test   rsi,0x1
     909:	jne    935 <botlish_fn_3+0x465>
     90f:	mov    edx,0xfd
     914:	mov    rsi,rbx
     917:	mov    rdi,r12
     91a:	call   91f <botlish_fn_3+0x44f>
			91b: R_X86_64_PLT32	rt_int_cmp-0x4
     91f:	mov    r8d,0x2
     925:	test   rax,rax
     928:	cmovle r8,QWORD PTR [rip+0xb0]        # 9e0 <botlish_fn_3+0x510>
     930:	jmp    94d <botlish_fn_3+0x47d>
     935:	mov    r8d,0x2
     93b:	mov    rsi,rbx
     93e:	cmp    rsi,0xfd
     945:	cmovle r8,QWORD PTR [rip+0x93]        # 9e0 <botlish_fn_3+0x510>
     94d:	cmp    r8,0x6
     951:	je     961 <botlish_fn_3+0x491>
     957:	mov    eax,0x2
     95c:	jmp    9c8 <botlish_fn_3+0x4f8>
     961:	mov    rax,r13
     964:	jmp    9c8 <botlish_fn_3+0x4f8>
     969:	mov    eax,0x2
     96e:	jmp    9c8 <botlish_fn_3+0x4f8>
     973:	mov    rax,r13
     976:	jmp    9c8 <botlish_fn_3+0x4f8>
     97b:	mov    eax,0x2
     980:	jmp    9c8 <botlish_fn_3+0x4f8>
     985:	mov    rax,r13
     988:	jmp    9c8 <botlish_fn_3+0x4f8>
     98d:	mov    eax,0x2
     992:	jmp    9c8 <botlish_fn_3+0x4f8>
     997:	mov    rax,r13
     99a:	jmp    9c8 <botlish_fn_3+0x4f8>
     99f:	mov    eax,0x2
     9a4:	jmp    9c8 <botlish_fn_3+0x4f8>
     9a9:	mov    rax,r13
     9ac:	jmp    9c8 <botlish_fn_3+0x4f8>
     9b1:	mov    eax,0x2
     9b6:	jmp    9c8 <botlish_fn_3+0x4f8>
     9bb:	mov    rax,r13
     9be:	jmp    9c8 <botlish_fn_3+0x4f8>
     9c3:	mov    eax,0x2
     9c8:	mov    rbx,QWORD PTR [rsp]
     9cc:	mov    r12,QWORD PTR [rsp+0x8]
     9d1:	mov    r13,QWORD PTR [rsp+0x10]
     9d6:	add    rsp,0x20
     9da:	mov    rsp,rbp
     9dd:	pop    rbp
     9de:	ret
     9df:	add    BYTE PTR [rsi],al
     9e1:	add    BYTE PTR [rax],al
     9e3:	add    BYTE PTR [rax],al
     9e5:	add    BYTE PTR [rax],al
	...

00000000000009e8 <botlish_entry_3: is_unreserved<generic>>:
     9e8:	push   rbp
     9e9:	mov    rbp,rsp
     9ec:	mov    rsi,QWORD PTR [rdx]
     9ef:	call   9f4 <botlish_entry_3+0xc>
			9f0: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
     9f4:	mov    rsp,rbp
     9f7:	pop    rbp
     9f8:	ret

00000000000009f9 <botlish_fn_4: hex_pair<generic>>:
     9f9:	push   rbp
     9fa:	mov    rbp,rsp
     9fd:	sub    rsp,0x30
     a01:	mov    QWORD PTR [rsp+0x10],rbx
     a06:	mov    QWORD PTR [rsp+0x18],r12
     a0b:	mov    QWORD PTR [rsp+0x20],r13
     a10:	mov    QWORD PTR [rsp+0x28],r14
     a15:	mov    r12,rdi
     a18:	mov    QWORD PTR [rsp],rsi
     a1c:	mov    r13,rsi
     a1f:	mov    QWORD PTR [rsp+0x8],rdx
     a24:	mov    rbx,rdx
     a27:	mov    rsi,r13
     a2a:	mov    rdi,r12
     a2d:	call   a32 <botlish_fn_4+0x39>
			a2e: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
     a32:	test   rax,rax
     a35:	je     b63 <botlish_fn_4+0x16a>
     a3b:	test   rax,0x1
     a41:	jne    a4f <botlish_fn_4+0x56>
     a47:	mov    rdx,rax
     a4a:	jmp    a65 <botlish_fn_4+0x6c>
     a4f:	mov    rdx,QWORD PTR [rbx+0x8]
     a53:	mov    rcx,rax
     a56:	sar    rcx,1
     a59:	cmp    rcx,rdx
     a5c:	jb     a81 <botlish_fn_4+0x88>
     a62:	mov    rdx,rax
     a65:	mov    rsi,rbx
     a68:	mov    rdi,r12
     a6b:	call   a70 <botlish_fn_4+0x77>
			a6c: R_X86_64_PLT32	rt_list_get-0x4
     a70:	test   rax,rax
     a73:	je     b63 <botlish_fn_4+0x16a>
     a79:	mov    rsi,rax
     a7c:	jmp    a89 <botlish_fn_4+0x90>
     a81:	mov    rax,QWORD PTR [rbx+0x10]
     a85:	mov    rsi,QWORD PTR [rax+rcx*8]
     a89:	mov    QWORD PTR [rsp],rsi
     a8d:	mov    r14,rsi
     a90:	mov    ecx,0x1
     a95:	mov    rsi,r13
     a98:	test   rsi,0x1
     a9f:	jne    abd <botlish_fn_4+0xc4>
     aa5:	xor    ecx,ecx
     aa7:	test   rsi,0x7
     aae:	jne    abd <botlish_fn_4+0xc4>
     ab4:	movzx  rax,BYTE PTR [rsi]
     ab8:	cmp    al,0x1
     aba:	sete   cl
     abd:	test   cl,cl
     abf:	jne    ae0 <botlish_fn_4+0xe7>
     ac5:	mov    rdi,r12
     ac8:	mov    rax,QWORD PTR [rdi+0x10]
     acc:	mov    rcx,QWORD PTR [rax+0xb0]
     ad3:	xor    rdx,rdx
     ad6:	call   adb <botlish_fn_4+0xe2>
			ad7: R_X86_64_PLT32	rt_type_error-0x4
     adb:	jmp    b63 <botlish_fn_4+0x16a>
     ae0:	mov    edx,0x21
     ae5:	mov    rdi,r12
     ae8:	call   aed <botlish_fn_4+0xf4>
			ae9: R_X86_64_PLT32	rt_int_mod-0x4
     aed:	test   rax,rax
     af0:	je     b63 <botlish_fn_4+0x16a>
     af6:	test   rax,0x1
     afc:	jne    b0d <botlish_fn_4+0x114>
     b02:	mov    rdx,rax
     b05:	mov    rsi,rbx
     b08:	jmp    b26 <botlish_fn_4+0x12d>
     b0d:	mov    rdi,QWORD PTR [rbx+0x8]
     b11:	mov    rsi,rax
     b14:	sar    rsi,1
     b17:	mov    rdx,rax
     b1a:	cmp    rsi,rdi
     b1d:	jb     b3f <botlish_fn_4+0x146>
     b23:	mov    rsi,rbx
     b26:	mov    rdi,r12
     b29:	call   b2e <botlish_fn_4+0x135>
			b2a: R_X86_64_PLT32	rt_list_get-0x4
     b2e:	test   rax,rax
     b31:	je     b63 <botlish_fn_4+0x16a>
     b37:	mov    rdx,rax
     b3a:	jmp    b4a <botlish_fn_4+0x151>
     b3f:	mov    rax,rbx
     b42:	mov    rax,QWORD PTR [rax+0x10]
     b46:	mov    rdx,QWORD PTR [rax+rsi*8]
     b4a:	mov    QWORD PTR [rsp+0x8],rdx
     b4f:	mov    rsi,r14
     b52:	mov    rdi,r12
     b55:	call   b5a <botlish_fn_4+0x161>
			b56: R_X86_64_PLT32	rt_str_cat-0x4
     b5a:	test   rax,rax
     b5d:	jne    b83 <botlish_fn_4+0x18a>
     b63:	xor    rax,rax
     b66:	mov    rbx,QWORD PTR [rsp+0x10]
     b6b:	mov    r12,QWORD PTR [rsp+0x18]
     b70:	mov    r13,QWORD PTR [rsp+0x20]
     b75:	mov    r14,QWORD PTR [rsp+0x28]
     b7a:	add    rsp,0x30
     b7e:	mov    rsp,rbp
     b81:	pop    rbp
     b82:	ret
     b83:	mov    rbx,QWORD PTR [rsp+0x10]
     b88:	mov    r12,QWORD PTR [rsp+0x18]
     b8d:	mov    r13,QWORD PTR [rsp+0x20]
     b92:	mov    r14,QWORD PTR [rsp+0x28]
     b97:	add    rsp,0x30
     b9b:	mov    rsp,rbp
     b9e:	pop    rbp
     b9f:	ret

0000000000000ba0 <botlish_entry_4: hex_pair<generic>>:
     ba0:	push   rbp
     ba1:	mov    rbp,rsp
     ba4:	mov    rsi,QWORD PTR [rdx]
     ba7:	mov    rdx,QWORD PTR [rdx+0x8]
     bab:	call   bb0 <botlish_entry_4+0x10>
			bac: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
     bb0:	mov    rsp,rbp
     bb3:	pop    rbp
     bb4:	ret
     bb5:	add    BYTE PTR [rax],al
	...

0000000000000bb8 <botlish_fn_5: esc_bytes<generic>>:
     bb8:	push   rbp
     bb9:	mov    rbp,rsp
     bbc:	sub    rsp,0x70
     bc0:	mov    QWORD PTR [rsp+0x40],rbx
     bc5:	mov    QWORD PTR [rsp+0x48],r12
     bca:	mov    QWORD PTR [rsp+0x50],r13
     bcf:	mov    QWORD PTR [rsp+0x58],r14
     bd4:	mov    QWORD PTR [rsp+0x60],r15
     bd9:	mov    r13,rdi
     bdc:	mov    QWORD PTR [rsp+0x28],0x0
     be5:	mov    QWORD PTR [rsp],rsi
     be9:	mov    QWORD PTR [rsp+0x8],rdx
     bee:	mov    QWORD PTR [rsp+0x10],rcx
     bf3:	mov    QWORD PTR [rsp+0x18],r8
     bf8:	mov    r12,r8
     bfb:	mov    r14,rcx
     bfe:	mov    r15,rdx
     c01:	xor    eax,eax
     c03:	test   rsi,0x7
     c0a:	jne    c1b <botlish_fn_5+0x63>
     c10:	movzx  r8,BYTE PTR [rsi]
     c14:	cmp    r8b,0x3
     c18:	sete   al
     c1b:	test   al,al
     c1d:	jne    c40 <botlish_fn_5+0x88>
     c23:	mov    rdi,r13
     c26:	mov    rax,QWORD PTR [rdi+0x10]
     c2a:	mov    rcx,QWORD PTR [rax+0xb8]
     c31:	mov    edx,0x4
     c36:	call   c3b <botlish_fn_5+0x83>
			c37: R_X86_64_PLT32	rt_type_error-0x4
     c3b:	jmp    e46 <botlish_fn_5+0x28e>
     c40:	mov    rbx,rsi
     c43:	mov    rdi,r13
     c46:	call   c4b <botlish_fn_5+0x93>
			c47: R_X86_64_PLT32	rt_list_len-0x4
     c4b:	mov    ecx,0x1
     c50:	mov    rsi,r15
     c53:	test   rsi,0x1
     c5a:	jne    c80 <botlish_fn_5+0xc8>
     c60:	xor    ecx,ecx
     c62:	mov    rsi,r15
     c65:	test   rsi,0x7
     c6c:	jne    c80 <botlish_fn_5+0xc8>
     c72:	mov    rsi,r15
     c75:	movzx  rcx,BYTE PTR [rsi]
     c79:	rex cmp cl,0x1
     c7d:	sete   cl
     c80:	test   cl,cl
     c82:	jne    ca6 <botlish_fn_5+0xee>
     c88:	mov    rdi,r13
     c8b:	mov    rax,QWORD PTR [rdi+0x10]
     c8f:	mov    rcx,QWORD PTR [rax+0xc0]
     c96:	xor    rdx,rdx
     c99:	mov    rsi,r15
     c9c:	call   ca1 <botlish_fn_5+0xe9>
			c9d: R_X86_64_PLT32	rt_type_error-0x4
     ca1:	jmp    e46 <botlish_fn_5+0x28e>
     ca6:	mov    rsi,r15
     ca9:	mov    rcx,rsi
     cac:	and    rcx,rax
     caf:	mov    rdx,rax
     cb2:	test   rcx,0x1
     cb9:	jne    cdf <botlish_fn_5+0x127>
     cbf:	mov    rsi,r15
     cc2:	mov    rdi,r13
     cc5:	call   cca <botlish_fn_5+0x112>
			cc6: R_X86_64_PLT32	rt_int_cmp-0x4
     cca:	mov    ecx,0x2
     ccf:	test   rax,rax
     cd2:	cmovge rcx,QWORD PTR [rip+0x1de]        # eb8 <botlish_fn_5+0x300>
     cda:	jmp    cf2 <botlish_fn_5+0x13a>
     cdf:	mov    ecx,0x2
     ce4:	mov    rsi,r15
     ce7:	cmp    rsi,rdx
     cea:	cmovge rcx,QWORD PTR [rip+0x1c6]        # eb8 <botlish_fn_5+0x300>
     cf2:	cmp    rcx,0x6
     cf6:	je     e91 <botlish_fn_5+0x2d9>
     cfc:	mov    QWORD PTR [rsp+0x20],0x3
     d05:	mov    rsi,r15
     d08:	test   rsi,0x1
     d0f:	je     d2a <botlish_fn_5+0x172>
     d15:	mov    rsi,r15
     d18:	mov    rax,rsi
     d1b:	add    rax,0x2
     d1f:	seto   cl
     d22:	test   cl,cl
     d24:	je     d3a <botlish_fn_5+0x182>
     d2a:	mov    edx,0x3
     d2f:	mov    rsi,r15
     d32:	mov    rdi,r13
     d35:	call   d3a <botlish_fn_5+0x182>
			d36: R_X86_64_PLT32	rt_int_add-0x4
     d3a:	mov    QWORD PTR [rsp+0x8],rax
     d3f:	mov    rdi,r13
     d42:	mov    QWORD PTR [rsp+0x30],rax
     d47:	mov    rax,QWORD PTR [rdi+0x10]
     d4b:	mov    rsi,QWORD PTR [rax+0xc8]
     d52:	mov    QWORD PTR [rsp+0x20],rsi
     d57:	mov    QWORD PTR [rsp+0x38],rsi
     d5c:	mov    rsi,r15
     d5f:	test   rsi,0x1
     d66:	jne    d74 <botlish_fn_5+0x1bc>
     d6c:	mov    rdx,r15
     d6f:	jmp    d8d <botlish_fn_5+0x1d5>
     d74:	mov    rcx,QWORD PTR [rbx+0x8]
     d78:	mov    rsi,r15
     d7b:	mov    rax,rsi
     d7e:	sar    rax,1
     d81:	cmp    rax,rcx
     d84:	jb     da9 <botlish_fn_5+0x1f1>
     d8a:	mov    rdx,r15
     d8d:	mov    rsi,rbx
     d90:	mov    rdi,r13
     d93:	call   d98 <botlish_fn_5+0x1e0>
			d94: R_X86_64_PLT32	rt_list_get-0x4
     d98:	test   rax,rax
     d9b:	je     e46 <botlish_fn_5+0x28e>
     da1:	mov    rsi,rax
     da4:	jmp    db1 <botlish_fn_5+0x1f9>
     da9:	mov    rcx,QWORD PTR [rbx+0x10]
     dad:	mov    rsi,QWORD PTR [rcx+rax*8]
     db1:	mov    QWORD PTR [rsp+0x28],rsi
     db6:	mov    rdx,r12
     db9:	mov    rdi,r13
     dbc:	call   dc1 <botlish_fn_5+0x209>
			dbd: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
     dc1:	test   rax,rax
     dc4:	je     e46 <botlish_fn_5+0x28e>
     dca:	mov    QWORD PTR [rsp+0x28],rax
     dcf:	mov    rdx,rax
     dd2:	mov    rsi,QWORD PTR [rsp+0x38]
     dd7:	mov    rdi,r13
     dda:	call   ddf <botlish_fn_5+0x227>
			ddb: R_X86_64_PLT32	rt_str_cat-0x4
     ddf:	test   rax,rax
     de2:	je     e46 <botlish_fn_5+0x28e>
     de8:	mov    QWORD PTR [rsp+0x20],rax
     ded:	mov    rdx,rax
     df0:	xor    eax,eax
     df2:	mov    rsi,r14
     df5:	test   rsi,0x7
     dfc:	jne    e0d <botlish_fn_5+0x255>
     e02:	movzx  rdi,BYTE PTR [rsi]
     e06:	cmp    dil,0x2
     e0a:	sete   al
     e0d:	test   al,al
     e0f:	jne    e35 <botlish_fn_5+0x27d>
     e15:	mov    rdi,r13
     e18:	mov    rdi,QWORD PTR [rdi+0x10]
     e1c:	mov    rcx,QWORD PTR [rdi+0xd0]
     e23:	mov    edx,0x1
     e28:	mov    rdi,r13
     e2b:	call   e30 <botlish_fn_5+0x278>
			e2c: R_X86_64_PLT32	rt_type_error-0x4
     e30:	jmp    e46 <botlish_fn_5+0x28e>
     e35:	mov    rdi,r13
     e38:	call   e3d <botlish_fn_5+0x285>
			e39: R_X86_64_PLT32	rt_str_cat-0x4
     e3d:	test   rax,rax
     e40:	jne    e6b <botlish_fn_5+0x2b3>
     e46:	xor    rax,rax
     e49:	mov    rbx,QWORD PTR [rsp+0x40]
     e4e:	mov    r12,QWORD PTR [rsp+0x48]
     e53:	mov    r13,QWORD PTR [rsp+0x50]
     e58:	mov    r14,QWORD PTR [rsp+0x58]
     e5d:	mov    r15,QWORD PTR [rsp+0x60]
     e62:	add    rsp,0x70
     e66:	mov    rsp,rbp
     e69:	pop    rbp
     e6a:	ret
     e6b:	mov    QWORD PTR [rsp],rbx
     e6f:	mov    rcx,QWORD PTR [rsp+0x30]
     e74:	mov    QWORD PTR [rsp+0x8],rcx
     e79:	mov    QWORD PTR [rsp+0x10],rax
     e7e:	mov    QWORD PTR [rsp+0x18],r12
     e83:	mov    rsi,rbx
     e86:	mov    r14,rax
     e89:	mov    r15,rcx
     e8c:	jmp    c01 <botlish_fn_5+0x49>
     e91:	mov    rax,r14
     e94:	mov    rbx,QWORD PTR [rsp+0x40]
     e99:	mov    r12,QWORD PTR [rsp+0x48]
     e9e:	mov    r13,QWORD PTR [rsp+0x50]
     ea3:	mov    r14,QWORD PTR [rsp+0x58]
     ea8:	mov    r15,QWORD PTR [rsp+0x60]
     ead:	add    rsp,0x70
     eb1:	mov    rsp,rbp
     eb4:	pop    rbp
     eb5:	ret
     eb6:	add    BYTE PTR [rax],al
     eb8:	(bad)
     eb9:	add    BYTE PTR [rax],al
     ebb:	add    BYTE PTR [rax],al
     ebd:	add    BYTE PTR [rax],al
	...

0000000000000ec0 <botlish_entry_5: esc_bytes<generic>>:
     ec0:	push   rbp
     ec1:	mov    rbp,rsp
     ec4:	mov    rsi,QWORD PTR [rdx]
     ec7:	mov    r9,QWORD PTR [rdx+0x8]
     ecb:	mov    rcx,QWORD PTR [rdx+0x10]
     ecf:	mov    r8,QWORD PTR [rdx+0x18]
     ed3:	mov    rdx,r9
     ed6:	call   edb <botlish_entry_5+0x1b>
			ed7: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
     edb:	mov    rsp,rbp
     ede:	pop    rbp
     edf:	ret

0000000000000ee0 <botlish_fn_6: esc_char<generic>>:
     ee0:	push   rbp
     ee1:	mov    rbp,rsp
     ee4:	sub    rsp,0x50
     ee8:	mov    QWORD PTR [rsp+0x20],rbx
     eed:	mov    QWORD PTR [rsp+0x28],r12
     ef2:	mov    QWORD PTR [rsp+0x30],r13
     ef7:	mov    QWORD PTR [rsp+0x38],r14
     efc:	mov    QWORD PTR [rsp+0x40],r15
     f01:	mov    QWORD PTR [rsp+0x10],0x0
     f0a:	mov    QWORD PTR [rsp+0x18],0x0
     f13:	mov    QWORD PTR [rsp],rsi
     f17:	mov    QWORD PTR [rsp+0x8],rdx
     f1c:	mov    rbx,rdx
     f1f:	xor    r9d,r9d
     f22:	test   rsi,0x7
     f29:	jne    f39 <botlish_fn_6+0x59>
     f2f:	movzx  rax,BYTE PTR [rsi]
     f33:	cmp    al,0x2
     f35:	sete   r9b
     f39:	test   r9b,r9b
     f3c:	jne    f5c <botlish_fn_6+0x7c>
     f42:	mov    rax,QWORD PTR [rdi+0x10]
     f46:	mov    rcx,QWORD PTR [rax+0xd8]
     f4d:	mov    edx,0x1
     f52:	call   f57 <botlish_fn_6+0x77>
			f53: R_X86_64_PLT32	rt_type_error-0x4
     f57:	jmp    105c <botlish_fn_6+0x17c>
     f5c:	mov    r12,rdi
     f5f:	mov    r15,rsi
     f62:	call   f67 <botlish_fn_6+0x87>
			f63: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
     f67:	mov    rcx,rax
     f6a:	mov    r13,rax
     f6d:	test   rax,rcx
     f70:	je     105c <botlish_fn_6+0x17c>
     f76:	mov    rax,r13
     f79:	mov    QWORD PTR [rsp],rax
     f7d:	mov    rsi,r13
     f80:	mov    rdi,r12
     f83:	call   f88 <botlish_fn_6+0xa8>
			f84: R_X86_64_PLT32	rt_list_len-0x4
     f88:	mov    edx,0x1
     f8d:	sar    rax,1
     f90:	cmp    rax,0x1
     f94:	je     fcf <botlish_fn_6+0xef>
     f9a:	mov    QWORD PTR [rsp+0x10],0x1
     fa3:	mov    rdi,r12
     fa6:	mov    rax,QWORD PTR [rdi+0x10]
     faa:	mov    rcx,QWORD PTR [rax+0x98]
     fb1:	mov    QWORD PTR [rsp+0x18],rcx
     fb6:	mov    rsi,r13
     fb9:	mov    r8,rbx
     fbc:	call   fc1 <botlish_fn_6+0xe1>
			fbd: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
     fc1:	test   rax,rax
     fc4:	je     105c <botlish_fn_6+0x17c>
     fca:	jmp    1087 <botlish_fn_6+0x1a7>
     fcf:	mov    rsi,r13
     fd2:	mov    r14,rdx
     fd5:	mov    rax,QWORD PTR [rsi+0x8]
     fd9:	mov    r13,rsi
     fdc:	test   rax,rax
     fdf:	jne    1004 <botlish_fn_6+0x124>
     fe5:	mov    rdx,r14
     fe8:	mov    rsi,r13
     feb:	mov    rdi,r12
     fee:	call   ff3 <botlish_fn_6+0x113>
			fef: R_X86_64_PLT32	rt_list_get-0x4
     ff3:	test   rax,rax
     ff6:	je     105c <botlish_fn_6+0x17c>
     ffc:	mov    rsi,rax
     fff:	jmp    100e <botlish_fn_6+0x12e>
    1004:	mov    rsi,r13
    1007:	mov    rcx,QWORD PTR [rsi+0x10]
    100b:	mov    rsi,QWORD PTR [rcx]
    100e:	mov    rdi,r12
    1011:	call   1016 <botlish_fn_6+0x136>
			1012: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    1016:	test   rax,rax
    1019:	je     105c <botlish_fn_6+0x17c>
    101f:	cmp    rax,0x6
    1023:	je     1084 <botlish_fn_6+0x1a4>
    1029:	mov    QWORD PTR [rsp+0x10],0x1
    1032:	mov    rdi,r12
    1035:	mov    r8,QWORD PTR [rdi+0x10]
    1039:	mov    rcx,QWORD PTR [r8+0x98]
    1040:	mov    QWORD PTR [rsp+0x18],rcx
    1045:	mov    rdx,r14
    1048:	mov    rsi,r13
    104b:	mov    r8,rbx
    104e:	call   1053 <botlish_fn_6+0x173>
			104f: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    1053:	test   rax,rax
    1056:	jne    1081 <botlish_fn_6+0x1a1>
    105c:	xor    rax,rax
    105f:	mov    rbx,QWORD PTR [rsp+0x20]
    1064:	mov    r12,QWORD PTR [rsp+0x28]
    1069:	mov    r13,QWORD PTR [rsp+0x30]
    106e:	mov    r14,QWORD PTR [rsp+0x38]
    1073:	mov    r15,QWORD PTR [rsp+0x40]
    1078:	add    rsp,0x50
    107c:	mov    rsp,rbp
    107f:	pop    rbp
    1080:	ret
    1081:	mov    r15,rax
    1084:	mov    rax,r15
    1087:	mov    rbx,QWORD PTR [rsp+0x20]
    108c:	mov    r12,QWORD PTR [rsp+0x28]
    1091:	mov    r13,QWORD PTR [rsp+0x30]
    1096:	mov    r14,QWORD PTR [rsp+0x38]
    109b:	mov    r15,QWORD PTR [rsp+0x40]
    10a0:	add    rsp,0x50
    10a4:	mov    rsp,rbp
    10a7:	pop    rbp
    10a8:	ret

00000000000010a9 <botlish_entry_6: esc_char<generic>>:
    10a9:	push   rbp
    10aa:	mov    rbp,rsp
    10ad:	mov    rsi,QWORD PTR [rdx]
    10b0:	mov    rdx,QWORD PTR [rdx+0x8]
    10b4:	call   10b9 <botlish_entry_6+0x10>
			10b5: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    10b9:	mov    rsp,rbp
    10bc:	pop    rbp
    10bd:	ret
	...

00000000000010c0 <botlish_fn_7: esc_from<generic>>:
    10c0:	push   rbp
    10c1:	mov    rbp,rsp
    10c4:	sub    rsp,0x70
    10c8:	mov    QWORD PTR [rsp+0x40],rbx
    10cd:	mov    QWORD PTR [rsp+0x48],r12
    10d2:	mov    QWORD PTR [rsp+0x50],r13
    10d7:	mov    QWORD PTR [rsp+0x58],r14
    10dc:	mov    QWORD PTR [rsp+0x60],r15
    10e1:	mov    r13,rdi
    10e4:	mov    QWORD PTR [rsp+0x28],0x0
    10ed:	mov    QWORD PTR [rsp],rsi
    10f1:	mov    QWORD PTR [rsp+0x8],rdx
    10f6:	mov    QWORD PTR [rsp+0x10],rcx
    10fb:	mov    QWORD PTR [rsp+0x18],r8
    1100:	mov    r12,r8
    1103:	mov    r14,rcx
    1106:	mov    QWORD PTR [rsp+0x30],rdx
    110b:	xor    eax,eax
    110d:	test   rsi,0x7
    1114:	jne    1123 <botlish_fn_7+0x63>
    111a:	movzx  rax,BYTE PTR [rsi]
    111e:	cmp    al,0x2
    1120:	sete   al
    1123:	test   al,al
    1125:	jne    1148 <botlish_fn_7+0x88>
    112b:	mov    rdi,r13
    112e:	mov    rax,QWORD PTR [rdi+0x10]
    1132:	mov    rcx,QWORD PTR [rax+0xe0]
    1139:	mov    edx,0x1
    113e:	call   1143 <botlish_fn_7+0x83>
			113f: R_X86_64_PLT32	rt_type_error-0x4
    1143:	jmp    138c <botlish_fn_7+0x2cc>
    1148:	mov    rbx,rsi
    114b:	mov    rdi,r13
    114e:	call   1153 <botlish_fn_7+0x93>
			114f: R_X86_64_PLT32	rt_str_len-0x4
    1153:	mov    edx,0x1
    1158:	mov    r15,rdx
    115b:	mov    ecx,0x1
    1160:	mov    rsi,QWORD PTR [rsp+0x30]
    1165:	test   rsi,0x1
    116c:	jne    1196 <botlish_fn_7+0xd6>
    1172:	xor    ecx,ecx
    1174:	mov    rsi,QWORD PTR [rsp+0x30]
    1179:	test   rsi,0x7
    1180:	jne    1196 <botlish_fn_7+0xd6>
    1186:	mov    rsi,QWORD PTR [rsp+0x30]
    118b:	movzx  rcx,BYTE PTR [rsi]
    118f:	rex cmp cl,0x1
    1193:	sete   cl
    1196:	test   cl,cl
    1198:	jne    11be <botlish_fn_7+0xfe>
    119e:	mov    rdi,r13
    11a1:	mov    rax,QWORD PTR [rdi+0x10]
    11a5:	mov    rcx,QWORD PTR [rax+0xc0]
    11ac:	xor    rdx,rdx
    11af:	mov    rsi,QWORD PTR [rsp+0x30]
    11b4:	call   11b9 <botlish_fn_7+0xf9>
			11b5: R_X86_64_PLT32	rt_type_error-0x4
    11b9:	jmp    138c <botlish_fn_7+0x2cc>
    11be:	mov    rsi,QWORD PTR [rsp+0x30]
    11c3:	mov    rcx,rsi
    11c6:	and    rcx,rax
    11c9:	mov    rdx,rax
    11cc:	test   rcx,0x1
    11d3:	jne    11fb <botlish_fn_7+0x13b>
    11d9:	mov    rsi,QWORD PTR [rsp+0x30]
    11de:	mov    rdi,r13
    11e1:	call   11e6 <botlish_fn_7+0x126>
			11e2: R_X86_64_PLT32	rt_int_cmp-0x4
    11e6:	mov    ecx,0x2
    11eb:	test   rax,rax
    11ee:	cmovge rcx,QWORD PTR [rip+0x20a]        # 1400 <botlish_fn_7+0x340>
    11f6:	jmp    1210 <botlish_fn_7+0x150>
    11fb:	mov    ecx,0x2
    1200:	mov    rsi,QWORD PTR [rsp+0x30]
    1205:	cmp    rsi,rdx
    1208:	cmovge rcx,QWORD PTR [rip+0x1f0]        # 1400 <botlish_fn_7+0x340>
    1210:	cmp    rcx,0x6
    1214:	je     13d9 <botlish_fn_7+0x319>
    121a:	mov    QWORD PTR [rsp+0x20],0x3
    1223:	mov    rsi,QWORD PTR [rsp+0x30]
    1228:	test   rsi,0x1
    122f:	je     124c <botlish_fn_7+0x18c>
    1235:	mov    rsi,QWORD PTR [rsp+0x30]
    123a:	mov    rax,rsi
    123d:	add    rax,0x2
    1241:	seto   cl
    1244:	test   cl,cl
    1246:	je     125e <botlish_fn_7+0x19e>
    124c:	mov    edx,0x3
    1251:	mov    rsi,QWORD PTR [rsp+0x30]
    1256:	mov    rdi,r13
    1259:	call   125e <botlish_fn_7+0x19e>
			125a: R_X86_64_PLT32	rt_int_add-0x4
    125e:	mov    QWORD PTR [rsp+0x20],rax
    1263:	mov    QWORD PTR [rsp+0x38],rax
    1268:	mov    QWORD PTR [rsp+0x28],0x3
    1271:	mov    rsi,QWORD PTR [rsp+0x30]
    1276:	test   rsi,0x1
    127d:	je     129a <botlish_fn_7+0x1da>
    1283:	mov    rsi,QWORD PTR [rsp+0x30]
    1288:	mov    rcx,rsi
    128b:	add    rcx,0x2
    128f:	seto   al
    1292:	test   al,al
    1294:	je     12af <botlish_fn_7+0x1ef>
    129a:	mov    edx,0x3
    129f:	mov    rsi,QWORD PTR [rsp+0x30]
    12a4:	mov    rdi,r13
    12a7:	call   12ac <botlish_fn_7+0x1ec>
			12a8: R_X86_64_PLT32	rt_int_add-0x4
    12ac:	mov    rcx,rax
    12af:	mov    QWORD PTR [rsp+0x28],rcx
    12b4:	mov    rdx,QWORD PTR [rsp+0x30]
    12b9:	mov    rsi,rbx
    12bc:	mov    rdi,r13
    12bf:	call   12c4 <botlish_fn_7+0x204>
			12c0: R_X86_64_PLT32	rt_substr-0x4
    12c4:	test   rax,rax
    12c7:	je     138c <botlish_fn_7+0x2cc>
    12cd:	mov    QWORD PTR [rsp+0x8],rax
    12d2:	mov    rsi,rax
    12d5:	mov    rdx,r12
    12d8:	mov    rdi,r13
    12db:	call   12e0 <botlish_fn_7+0x220>
			12dc: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    12e0:	test   rax,rax
    12e3:	je     138c <botlish_fn_7+0x2cc>
    12e9:	mov    QWORD PTR [rsp+0x8],rax
    12ee:	xor    ecx,ecx
    12f0:	mov    rsi,r14
    12f3:	test   rsi,0x7
    12fa:	jne    130b <botlish_fn_7+0x24b>
    1300:	movzx  rdi,BYTE PTR [rsi]
    1304:	cmp    dil,0x2
    1308:	sete   cl
    130b:	test   cl,cl
    130d:	jne    132e <botlish_fn_7+0x26e>
    1313:	mov    rdi,r13
    1316:	mov    r9,QWORD PTR [rdi+0x10]
    131a:	mov    rcx,QWORD PTR [r9+0xd0]
    1321:	mov    rdx,r15
    1324:	call   1329 <botlish_fn_7+0x269>
			1325: R_X86_64_PLT32	rt_type_error-0x4
    1329:	jmp    138c <botlish_fn_7+0x2cc>
    132e:	mov    rdx,r15
    1331:	xor    ecx,ecx
    1333:	test   rax,0x7
    1339:	je     1347 <botlish_fn_7+0x287>
    133f:	mov    r8,rax
    1342:	jmp    1355 <botlish_fn_7+0x295>
    1347:	movzx  rcx,BYTE PTR [rax]
    134b:	mov    r8,rax
    134e:	rex cmp cl,0x2
    1352:	sete   cl
    1355:	test   cl,cl
    1357:	jne    1378 <botlish_fn_7+0x2b8>
    135d:	mov    rdi,r13
    1360:	mov    rax,QWORD PTR [rdi+0x10]
    1364:	mov    rcx,QWORD PTR [rax+0xd0]
    136b:	mov    rsi,r8
    136e:	call   1373 <botlish_fn_7+0x2b3>
			136f: R_X86_64_PLT32	rt_type_error-0x4
    1373:	jmp    138c <botlish_fn_7+0x2cc>
    1378:	mov    rdx,r8
    137b:	mov    rdi,r13
    137e:	call   1383 <botlish_fn_7+0x2c3>
			137f: R_X86_64_PLT32	rt_str_cat-0x4
    1383:	test   rax,rax
    1386:	jne    13b1 <botlish_fn_7+0x2f1>
    138c:	xor    rax,rax
    138f:	mov    rbx,QWORD PTR [rsp+0x40]
    1394:	mov    r12,QWORD PTR [rsp+0x48]
    1399:	mov    r13,QWORD PTR [rsp+0x50]
    139e:	mov    r14,QWORD PTR [rsp+0x58]
    13a3:	mov    r15,QWORD PTR [rsp+0x60]
    13a8:	add    rsp,0x70
    13ac:	mov    rsp,rbp
    13af:	pop    rbp
    13b0:	ret
    13b1:	mov    QWORD PTR [rsp],rbx
    13b5:	mov    rcx,QWORD PTR [rsp+0x38]
    13ba:	mov    QWORD PTR [rsp+0x8],rcx
    13bf:	mov    QWORD PTR [rsp+0x10],rax
    13c4:	mov    QWORD PTR [rsp+0x18],r12
    13c9:	mov    rsi,rbx
    13cc:	mov    r14,rax
    13cf:	mov    QWORD PTR [rsp+0x30],rcx
    13d4:	jmp    110b <botlish_fn_7+0x4b>
    13d9:	mov    rax,r14
    13dc:	mov    rbx,QWORD PTR [rsp+0x40]
    13e1:	mov    r12,QWORD PTR [rsp+0x48]
    13e6:	mov    r13,QWORD PTR [rsp+0x50]
    13eb:	mov    r14,QWORD PTR [rsp+0x58]
    13f0:	mov    r15,QWORD PTR [rsp+0x60]
    13f5:	add    rsp,0x70
    13f9:	mov    rsp,rbp
    13fc:	pop    rbp
    13fd:	ret
    13fe:	add    BYTE PTR [rax],al
    1400:	(bad)
    1401:	add    BYTE PTR [rax],al
    1403:	add    BYTE PTR [rax],al
    1405:	add    BYTE PTR [rax],al
	...

0000000000001408 <botlish_entry_7: esc_from<generic>>:
    1408:	push   rbp
    1409:	mov    rbp,rsp
    140c:	mov    rsi,QWORD PTR [rdx]
    140f:	mov    r9,QWORD PTR [rdx+0x8]
    1413:	mov    rcx,QWORD PTR [rdx+0x10]
    1417:	mov    r8,QWORD PTR [rdx+0x18]
    141b:	mov    rdx,r9
    141e:	call   1423 <botlish_entry_7+0x1b>
			141f: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
    1423:	mov    rsp,rbp
    1426:	pop    rbp
    1427:	ret

0000000000001428 <botlish_fn_8: check<int, int, str, str>>:
    1428:	push   rbp
    1429:	mov    rbp,rsp
    142c:	sub    rsp,0x60
    1430:	mov    QWORD PTR [rsp+0x30],rbx
    1435:	mov    QWORD PTR [rsp+0x38],r12
    143a:	mov    QWORD PTR [rsp+0x40],r13
    143f:	mov    QWORD PTR [rsp+0x48],r14
    1444:	mov    QWORD PTR [rsp+0x50],r15
    1449:	mov    QWORD PTR [rsp+0x20],0x0
    1452:	mov    QWORD PTR [rsp],rsi
    1456:	mov    QWORD PTR [rsp+0x8],rdx
    145b:	mov    QWORD PTR [rsp+0x10],rcx
    1460:	mov    r12,rcx
    1463:	mov    QWORD PTR [rsp+0x18],r8
    1468:	mov    r14,r8
    146b:	mov    r13,rsi
    146e:	mov    r15,rdx
    1471:	test   r13,0x1
    1478:	jne    14a3 <botlish_fn_8+0x7b>
    147e:	mov    edx,0x1
    1483:	mov    rbx,rdi
    1486:	mov    rsi,r13
    1489:	call   148e <botlish_fn_8+0x66>
			148a: R_X86_64_PLT32	rt_int_cmp-0x4
    148e:	mov    ecx,0x2
    1493:	test   rax,rax
    1496:	cmovle rcx,QWORD PTR [rip+0x152]        # 15f0 <botlish_fn_8+0x1c8>
    149e:	jmp    14b7 <botlish_fn_8+0x8f>
    14a3:	mov    rbx,rdi
    14a6:	mov    ecx,0x2
    14ab:	cmp    r13,0x1
    14af:	cmovle rcx,QWORD PTR [rip+0x139]        # 15f0 <botlish_fn_8+0x1c8>
    14b7:	cmp    rcx,0x6
    14bb:	je     15c4 <botlish_fn_8+0x19c>
    14c1:	mov    rax,QWORD PTR [rbx+0x10]
    14c5:	mov    rax,QWORD PTR [rax+0xe8]
    14cc:	mov    rsi,r12
    14cf:	mov    rdi,rbx
    14d2:	call   14d7 <botlish_fn_8+0xaf>
			14d3: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    14d7:	test   rax,rax
    14da:	je     151b <botlish_fn_8+0xf3>
    14e0:	cmp    rax,0x6
    14e4:	je     14fc <botlish_fn_8+0xd4>
    14ea:	mov    edx,0x1
    14ef:	mov    QWORD PTR [rsp],0x1
    14f7:	jmp    155d <botlish_fn_8+0x135>
    14fc:	mov    rax,QWORD PTR [rbx+0x10]
    1500:	mov    rax,QWORD PTR [rax+0xf0]
    1507:	mov    rsi,r12
    150a:	mov    rdi,rbx
    150d:	call   1512 <botlish_fn_8+0xea>
			150e: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    1512:	test   rax,rax
    1515:	jne    1540 <botlish_fn_8+0x118>
    151b:	xor    rax,rax
    151e:	mov    rbx,QWORD PTR [rsp+0x30]
    1523:	mov    r12,QWORD PTR [rsp+0x38]
    1528:	mov    r13,QWORD PTR [rsp+0x40]
    152d:	mov    r14,QWORD PTR [rsp+0x48]
    1532:	mov    r15,QWORD PTR [rsp+0x50]
    1537:	add    rsp,0x60
    153b:	mov    rsp,rbp
    153e:	pop    rbp
    153f:	ret
    1540:	cmp    rax,0x6
    1544:	je     1554 <botlish_fn_8+0x12c>
    154a:	mov    edx,0x1
    154f:	jmp    1559 <botlish_fn_8+0x131>
    1554:	mov    edx,0x3
    1559:	mov    QWORD PTR [rsp],rdx
    155d:	sar    r13,1
    1560:	sub    r13,0x1
    1564:	shl    r13,1
    1567:	or     r13,0x1
    156b:	mov    QWORD PTR [rsp+0x20],r13
    1570:	mov    rsi,r15
    1573:	mov    r8,rsi
    1576:	and    r8,rdx
    1579:	test   r8,0x1
    1580:	je     159b <botlish_fn_8+0x173>
    1586:	lea    r11,[rdx-0x1]
    158a:	mov    rax,rsi
    158d:	add    rax,r11
    1590:	seto   cl
    1593:	test   cl,cl
    1595:	je     15a3 <botlish_fn_8+0x17b>
    159b:	mov    rdi,rbx
    159e:	call   15a3 <botlish_fn_8+0x17b>
			159f: R_X86_64_PLT32	rt_int_add-0x4
    15a3:	mov    QWORD PTR [rsp],r13
    15a7:	mov    QWORD PTR [rsp+0x8],rax
    15ac:	mov    QWORD PTR [rsp+0x10],r12
    15b1:	mov    r8,r14
    15b4:	mov    QWORD PTR [rsp+0x18],r8
    15b9:	mov    rdi,rbx
    15bc:	mov    r15,rax
    15bf:	jmp    1471 <botlish_fn_8+0x49>
    15c4:	mov    rax,r15
    15c7:	mov    rbx,QWORD PTR [rsp+0x30]
    15cc:	mov    r12,QWORD PTR [rsp+0x38]
    15d1:	mov    r13,QWORD PTR [rsp+0x40]
    15d6:	mov    r14,QWORD PTR [rsp+0x48]
    15db:	mov    r15,QWORD PTR [rsp+0x50]
    15e0:	add    rsp,0x60
    15e4:	mov    rsp,rbp
    15e7:	pop    rbp
    15e8:	ret
    15e9:	add    BYTE PTR [rax],al
    15eb:	add    BYTE PTR [rax],al
    15ed:	add    BYTE PTR [rax],al
    15ef:	add    BYTE PTR [rsi],al
    15f1:	add    BYTE PTR [rax],al
    15f3:	add    BYTE PTR [rax],al
    15f5:	add    BYTE PTR [rax],al
	...

00000000000015f8 <botlish_entry_8: check<int, int, str, str>>:
    15f8:	push   rbp
    15f9:	mov    rbp,rsp
    15fc:	mov    rsi,QWORD PTR [rdx]
    15ff:	mov    r9,QWORD PTR [rdx+0x8]
    1603:	mov    rcx,QWORD PTR [rdx+0x10]
    1607:	mov    r8,QWORD PTR [rdx+0x18]
    160b:	mov    rdx,r9
    160e:	call   1613 <botlish_entry_8+0x1b>
			160f: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
    1613:	mov    rsp,rbp
    1616:	pop    rbp
    1617:	ret

0000000000001618 <botlish_fn_9: <str>>:
    1618:	push   rbp
    1619:	mov    rbp,rsp
    161c:	sub    rsp,0x50
    1620:	mov    QWORD PTR [rsp+0x30],rbx
    1625:	mov    QWORD PTR [rsp+0x38],r12
    162a:	mov    QWORD PTR [rsp+0x40],r13
    162f:	mov    QWORD PTR [rsp+0x48],r14
    1634:	mov    r13,rdi
    1637:	mov    QWORD PTR [rsp+0x18],0x0
    1640:	mov    QWORD PTR [rsp],rsi
    1644:	mov    r14,rsi
    1647:	mov    rsi,r14
    164a:	mov    rdi,r13
    164d:	call   1652 <botlish_fn_9+0x3a>
			164e: R_X86_64_PLT32	rt_str_len-0x4
    1652:	mov    rbx,rax
    1655:	mov    QWORD PTR [rsp+0x8],rax
    165a:	mov    esi,0x1
    165f:	mov    QWORD PTR [rsp+0x10],0x1
    1668:	mov    rcx,r14
    166b:	mov    rdx,rbx
    166e:	mov    rdi,r13
    1671:	call   1676 <botlish_fn_9+0x5e>
			1672: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_local<generic>
    1676:	mov    r12,rax
    1679:	test   r12,r12
    167c:	je     17d9 <botlish_fn_9+0x1c1>
    1682:	mov    QWORD PTR [rsp+0x10],r12
    1687:	test   r12,0x1
    168e:	jne    16b9 <botlish_fn_9+0xa1>
    1694:	mov    edx,0x1
    1699:	mov    rsi,r12
    169c:	mov    rdi,r13
    169f:	call   16a4 <botlish_fn_9+0x8c>
			16a0: R_X86_64_PLT32	rt_int_cmp-0x4
    16a4:	mov    ecx,0x2
    16a9:	test   rax,rax
    16ac:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 1878 <botlish_fn_9+0x260>
    16b4:	jmp    16ca <botlish_fn_9+0xb2>
    16b9:	mov    ecx,0x2
    16be:	cmp    r12,0x1
    16c2:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 1878 <botlish_fn_9+0x260>
    16ca:	cmp    rcx,0x6
    16ce:	je     1854 <botlish_fn_9+0x23c>
    16d4:	mov    rcx,r12
    16d7:	and    rcx,rbx
    16da:	test   rcx,0x1
    16e1:	jne    170a <botlish_fn_9+0xf2>
    16e7:	mov    rdx,rbx
    16ea:	mov    rsi,r12
    16ed:	mov    rdi,r13
    16f0:	call   16f5 <botlish_fn_9+0xdd>
			16f1: R_X86_64_PLT32	rt_int_cmp-0x4
    16f5:	mov    ecx,0x2
    16fa:	test   rax,rax
    16fd:	cmovge rcx,QWORD PTR [rip+0x173]        # 1878 <botlish_fn_9+0x260>
    1705:	jmp    171a <botlish_fn_9+0x102>
    170a:	mov    ecx,0x2
    170f:	cmp    r12,rbx
    1712:	cmovge rcx,QWORD PTR [rip+0x15e]        # 1878 <botlish_fn_9+0x260>
    171a:	cmp    rcx,0x6
    171e:	je     184a <botlish_fn_9+0x232>
    1724:	lea    rcx,[rsp+0x20]
    1729:	mov    rdx,r14
    172c:	mov    rsi,r12
    172f:	mov    rdi,r13
    1732:	call   1737 <botlish_fn_9+0x11f>
			1733: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    1737:	test   rax,rax
    173a:	mov    rsi,rax
    173d:	je     17d9 <botlish_fn_9+0x1c1>
    1743:	mov    rdx,QWORD PTR [rsp+0x20]
    1748:	mov    rcx,QWORD PTR [rsp+0x28]
    174d:	mov    rdi,r13
    1750:	mov    rax,QWORD PTR [rdi+0x10]
    1754:	mov    r8,QWORD PTR [rax+0x108]
    175b:	call   1760 <botlish_fn_9+0x148>
			175c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1760:	cmp    rax,0x6
    1764:	je     1777 <botlish_fn_9+0x15f>
    176a:	mov    ecx,0x2
    176f:	mov    rax,rcx
    1772:	jmp    1859 <botlish_fn_9+0x241>
    1777:	mov    QWORD PTR [rsp+0x18],0x3
    1780:	test   r12,0x1
    1787:	jne    1795 <botlish_fn_9+0x17d>
    178d:	mov    rcx,r12
    1790:	jmp    17aa <botlish_fn_9+0x192>
    1795:	mov    rsi,r12
    1798:	add    rsi,0x2
    179c:	mov    rcx,r12
    179f:	seto   al
    17a2:	test   al,al
    17a4:	je     17bd <botlish_fn_9+0x1a5>
    17aa:	mov    edx,0x3
    17af:	mov    rsi,rcx
    17b2:	mov    rdi,r13
    17b5:	call   17ba <botlish_fn_9+0x1a2>
			17b6: R_X86_64_PLT32	rt_int_add-0x4
    17ba:	mov    rsi,rax
    17bd:	mov    QWORD PTR [rsp+0x10],rsi
    17c2:	mov    rcx,r14
    17c5:	mov    rdx,rbx
    17c8:	mov    rdi,r13
    17cb:	call   17d0 <botlish_fn_9+0x1b8>
			17cc: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain_loop<generic>
    17d0:	test   rax,rax
    17d3:	jne    17f9 <botlish_fn_9+0x1e1>
    17d9:	xor    rax,rax
    17dc:	mov    rbx,QWORD PTR [rsp+0x30]
    17e1:	mov    r12,QWORD PTR [rsp+0x38]
    17e6:	mov    r13,QWORD PTR [rsp+0x40]
    17eb:	mov    r14,QWORD PTR [rsp+0x48]
    17f0:	add    rsp,0x50
    17f4:	mov    rsp,rbp
    17f7:	pop    rbp
    17f8:	ret
    17f9:	mov    rcx,rax
    17fc:	and    rcx,rbx
    17ff:	mov    rsi,rax
    1802:	test   rcx,0x1
    1809:	jne    1832 <botlish_fn_9+0x21a>
    180f:	mov    rdx,rbx
    1812:	mov    rdi,r13
    1815:	call   181a <botlish_fn_9+0x202>
			1816: R_X86_64_PLT32	rt_int_cmp-0x4
    181a:	mov    ecx,0x2
    181f:	test   rax,rax
    1822:	mov    rax,rcx
    1825:	cmove  rax,QWORD PTR [rip+0x4b]        # 1878 <botlish_fn_9+0x260>
    182d:	jmp    1859 <botlish_fn_9+0x241>
    1832:	mov    rdx,rbx
    1835:	mov    eax,0x2
    183a:	cmp    rsi,rdx
    183d:	cmove  rax,QWORD PTR [rip+0x33]        # 1878 <botlish_fn_9+0x260>
    1845:	jmp    1859 <botlish_fn_9+0x241>
    184a:	mov    eax,0x2
    184f:	jmp    1859 <botlish_fn_9+0x241>
    1854:	mov    eax,0x2
    1859:	mov    rbx,QWORD PTR [rsp+0x30]
    185e:	mov    r12,QWORD PTR [rsp+0x38]
    1863:	mov    r13,QWORD PTR [rsp+0x40]
    1868:	mov    r14,QWORD PTR [rsp+0x48]
    186d:	add    rsp,0x50
    1871:	mov    rsp,rbp
    1874:	pop    rbp
    1875:	ret
    1876:	add    BYTE PTR [rax],al
    1878:	(bad)
    1879:	add    BYTE PTR [rax],al
    187b:	add    BYTE PTR [rax],al
    187d:	add    BYTE PTR [rax],al
	...

0000000000001880 <botlish_entry_9: <str>>:
    1880:	push   rbp
    1881:	mov    rbp,rsp
    1884:	mov    rsi,QWORD PTR [rdx]
    1887:	call   188c <botlish_entry_9+0xc>
			1888: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    188c:	mov    rsp,rbp
    188f:	pop    rbp
    1890:	ret
    1891:	add    BYTE PTR [rax],al
    1893:	add    BYTE PTR [rax],al
    1895:	add    BYTE PTR [rax],al
	...

0000000000001898 <botlish_fn_10: <generic>>:
    1898:	push   rbp
    1899:	mov    rbp,rsp
    189c:	sub    rsp,0x60
    18a0:	mov    QWORD PTR [rsp+0x30],rbx
    18a5:	mov    QWORD PTR [rsp+0x38],r12
    18aa:	mov    QWORD PTR [rsp+0x40],r13
    18af:	mov    QWORD PTR [rsp+0x48],r14
    18b4:	mov    QWORD PTR [rsp+0x50],r15
    18b9:	mov    QWORD PTR [rsp+0x18],0x0
    18c2:	mov    QWORD PTR [rsp],rsi
    18c6:	xor    r8d,r8d
    18c9:	test   rsi,0x7
    18d0:	jne    18e0 <botlish_fn_10+0x48>
    18d6:	movzx  rax,BYTE PTR [rsi]
    18da:	cmp    al,0x2
    18dc:	sete   r8b
    18e0:	test   r8b,r8b
    18e3:	jne    1903 <botlish_fn_10+0x6b>
    18e9:	mov    rdx,QWORD PTR [rdi+0x10]
    18ed:	mov    rcx,QWORD PTR [rdx+0xe0]
    18f4:	mov    edx,0x1
    18f9:	call   18fe <botlish_fn_10+0x66>
			18fa: R_X86_64_PLT32	rt_type_error-0x4
    18fe:	jmp    1a98 <botlish_fn_10+0x200>
    1903:	mov    r13,rsi
    1906:	mov    r14,rdi
    1909:	call   190e <botlish_fn_10+0x76>
			190a: R_X86_64_PLT32	rt_str_len-0x4
    190e:	mov    rbx,rax
    1911:	mov    QWORD PTR [rsp+0x8],rax
    1916:	mov    edx,0x1
    191b:	mov    r15,rdx
    191e:	mov    QWORD PTR [rsp+0x10],0x1
    1927:	mov    rcx,r13
    192a:	mov    rdx,rbx
    192d:	mov    rsi,r15
    1930:	mov    rdi,r14
    1933:	call   1938 <botlish_fn_10+0xa0>
			1934: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_local<generic>
    1938:	mov    r12,rax
    193b:	test   r12,r12
    193e:	je     1a98 <botlish_fn_10+0x200>
    1944:	mov    QWORD PTR [rsp+0x10],r12
    1949:	test   r12,0x1
    1950:	jne    1979 <botlish_fn_10+0xe1>
    1956:	mov    rdx,r15
    1959:	mov    rsi,r12
    195c:	mov    rdi,r14
    195f:	call   1964 <botlish_fn_10+0xcc>
			1960: R_X86_64_PLT32	rt_int_cmp-0x4
    1964:	mov    ecx,0x2
    1969:	test   rax,rax
    196c:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 1b40 <botlish_fn_10+0x2a8>
    1974:	jmp    198a <botlish_fn_10+0xf2>
    1979:	mov    ecx,0x2
    197e:	cmp    r12,0x1
    1982:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 1b40 <botlish_fn_10+0x2a8>
    198a:	cmp    rcx,0x6
    198e:	je     1b18 <botlish_fn_10+0x280>
    1994:	mov    rax,r12
    1997:	and    rax,rbx
    199a:	test   rax,0x1
    19a0:	jne    19c9 <botlish_fn_10+0x131>
    19a6:	mov    rdx,rbx
    19a9:	mov    rsi,r12
    19ac:	mov    rdi,r14
    19af:	call   19b4 <botlish_fn_10+0x11c>
			19b0: R_X86_64_PLT32	rt_int_cmp-0x4
    19b4:	mov    ecx,0x2
    19b9:	test   rax,rax
    19bc:	cmovge rcx,QWORD PTR [rip+0x17c]        # 1b40 <botlish_fn_10+0x2a8>
    19c4:	jmp    19d9 <botlish_fn_10+0x141>
    19c9:	mov    ecx,0x2
    19ce:	cmp    r12,rbx
    19d1:	cmovge rcx,QWORD PTR [rip+0x167]        # 1b40 <botlish_fn_10+0x2a8>
    19d9:	cmp    rcx,0x6
    19dd:	je     1b0e <botlish_fn_10+0x276>
    19e3:	lea    rcx,[rsp+0x20]
    19e8:	mov    rdx,r13
    19eb:	mov    rsi,r12
    19ee:	mov    rdi,r14
    19f1:	call   19f6 <botlish_fn_10+0x15e>
			19f2: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    19f6:	test   rax,rax
    19f9:	mov    rsi,rax
    19fc:	je     1a98 <botlish_fn_10+0x200>
    1a02:	mov    rdx,QWORD PTR [rsp+0x20]
    1a07:	mov    rcx,QWORD PTR [rsp+0x28]
    1a0c:	mov    rdi,r14
    1a0f:	mov    rax,QWORD PTR [rdi+0x10]
    1a13:	mov    r8,QWORD PTR [rax+0x108]
    1a1a:	call   1a1f <botlish_fn_10+0x187>
			1a1b: R_X86_64_PLT32	rt_str_region_eq-0x4
    1a1f:	cmp    rax,0x6
    1a23:	je     1a36 <botlish_fn_10+0x19e>
    1a29:	mov    ecx,0x2
    1a2e:	mov    rax,rcx
    1a31:	jmp    1b1d <botlish_fn_10+0x285>
    1a36:	mov    QWORD PTR [rsp+0x18],0x3
    1a3f:	test   r12,0x1
    1a46:	jne    1a54 <botlish_fn_10+0x1bc>
    1a4c:	mov    rdi,r12
    1a4f:	jmp    1a69 <botlish_fn_10+0x1d1>
    1a54:	mov    rsi,r12
    1a57:	add    rsi,0x2
    1a5b:	mov    rdi,r12
    1a5e:	seto   al
    1a61:	test   al,al
    1a63:	je     1a7c <botlish_fn_10+0x1e4>
    1a69:	mov    edx,0x3
    1a6e:	mov    rsi,rdi
    1a71:	mov    rdi,r14
    1a74:	call   1a79 <botlish_fn_10+0x1e1>
			1a75: R_X86_64_PLT32	rt_int_add-0x4
    1a79:	mov    rsi,rax
    1a7c:	mov    QWORD PTR [rsp+0x10],rsi
    1a81:	mov    rcx,r13
    1a84:	mov    rdx,rbx
    1a87:	mov    rdi,r14
    1a8a:	call   1a8f <botlish_fn_10+0x1f7>
			1a8b: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain_loop<generic>
    1a8f:	test   rax,rax
    1a92:	jne    1abd <botlish_fn_10+0x225>
    1a98:	xor    rax,rax
    1a9b:	mov    rbx,QWORD PTR [rsp+0x30]
    1aa0:	mov    r12,QWORD PTR [rsp+0x38]
    1aa5:	mov    r13,QWORD PTR [rsp+0x40]
    1aaa:	mov    r14,QWORD PTR [rsp+0x48]
    1aaf:	mov    r15,QWORD PTR [rsp+0x50]
    1ab4:	add    rsp,0x60
    1ab8:	mov    rsp,rbp
    1abb:	pop    rbp
    1abc:	ret
    1abd:	mov    rcx,rax
    1ac0:	and    rcx,rbx
    1ac3:	mov    rsi,rax
    1ac6:	test   rcx,0x1
    1acd:	jne    1af6 <botlish_fn_10+0x25e>
    1ad3:	mov    rdx,rbx
    1ad6:	mov    rdi,r14
    1ad9:	call   1ade <botlish_fn_10+0x246>
			1ada: R_X86_64_PLT32	rt_int_cmp-0x4
    1ade:	mov    ecx,0x2
    1ae3:	test   rax,rax
    1ae6:	mov    rax,rcx
    1ae9:	cmove  rax,QWORD PTR [rip+0x4f]        # 1b40 <botlish_fn_10+0x2a8>
    1af1:	jmp    1b1d <botlish_fn_10+0x285>
    1af6:	mov    rdx,rbx
    1af9:	mov    eax,0x2
    1afe:	cmp    rsi,rdx
    1b01:	cmove  rax,QWORD PTR [rip+0x37]        # 1b40 <botlish_fn_10+0x2a8>
    1b09:	jmp    1b1d <botlish_fn_10+0x285>
    1b0e:	mov    eax,0x2
    1b13:	jmp    1b1d <botlish_fn_10+0x285>
    1b18:	mov    eax,0x2
    1b1d:	mov    rbx,QWORD PTR [rsp+0x30]
    1b22:	mov    r12,QWORD PTR [rsp+0x38]
    1b27:	mov    r13,QWORD PTR [rsp+0x40]
    1b2c:	mov    r14,QWORD PTR [rsp+0x48]
    1b31:	mov    r15,QWORD PTR [rsp+0x50]
    1b36:	add    rsp,0x60
    1b3a:	mov    rsp,rbp
    1b3d:	pop    rbp
    1b3e:	ret
    1b3f:	add    BYTE PTR [rsi],al
    1b41:	add    BYTE PTR [rax],al
    1b43:	add    BYTE PTR [rax],al
    1b45:	add    BYTE PTR [rax],al
	...

0000000000001b48 <botlish_entry_10: <generic>>:
    1b48:	push   rbp
    1b49:	mov    rbp,rsp
    1b4c:	mov    rsi,QWORD PTR [rdx]
    1b4f:	call   1b54 <botlish_entry_10+0xc>
			1b50: R_X86_64_PLT32	botlish_fn_10-0x4 ; <generic>
    1b54:	mov    rsp,rbp
    1b57:	pop    rbp
    1b58:	ret

0000000000001b59 <botlish_fn_11: char_at<generic>>:
    1b59:	push   rbp
    1b5a:	mov    rbp,rsp
    1b5d:	sub    rsp,0x50
    1b61:	mov    QWORD PTR [rsp+0x20],rbx
    1b66:	mov    QWORD PTR [rsp+0x28],r12
    1b6b:	mov    QWORD PTR [rsp+0x30],r13
    1b70:	mov    QWORD PTR [rsp+0x38],r14
    1b75:	mov    QWORD PTR [rsp+0x40],r15
    1b7a:	mov    r14,rcx
    1b7d:	mov    QWORD PTR [rsp],rsi
    1b81:	mov    QWORD PTR [rsp+0x8],rdx
    1b86:	mov    r13,rdx
    1b89:	mov    QWORD PTR [rsp+0x10],0x3
    1b92:	mov    r9d,0x1
    1b98:	test   rsi,0x1
    1b9f:	jne    1bbf <botlish_fn_11+0x66>
    1ba5:	xor    r9d,r9d
    1ba8:	test   rsi,0x7
    1baf:	jne    1bbf <botlish_fn_11+0x66>
    1bb5:	movzx  rax,BYTE PTR [rsi]
    1bb9:	cmp    al,0x1
    1bbb:	sete   r9b
    1bbf:	test   r9b,r9b
    1bc2:	jne    1be0 <botlish_fn_11+0x87>
    1bc8:	mov    rax,QWORD PTR [rdi+0x10]
    1bcc:	mov    rcx,QWORD PTR [rax+0x110]
    1bd3:	xor    rdx,rdx
    1bd6:	call   1bdb <botlish_fn_11+0x82>
			1bd7: R_X86_64_PLT32	rt_type_error-0x4
    1bdb:	jmp    1c9d <botlish_fn_11+0x144>
    1be0:	mov    r12,rdi
    1be3:	test   rsi,0x1
    1bea:	jne    1bf8 <botlish_fn_11+0x9f>
    1bf0:	mov    rbx,rsi
    1bf3:	jmp    1c15 <botlish_fn_11+0xbc>
    1bf8:	mov    rax,rsi
    1bfb:	add    rax,0x2
    1bff:	mov    rbx,rsi
    1c02:	seto   cl
    1c05:	test   cl,cl
    1c07:	jne    1c15 <botlish_fn_11+0xbc>
    1c0d:	mov    r15,rax
    1c10:	jmp    1c28 <botlish_fn_11+0xcf>
    1c15:	mov    edx,0x3
    1c1a:	mov    rsi,rbx
    1c1d:	mov    rdi,r12
    1c20:	call   1c25 <botlish_fn_11+0xcc>
			1c21: R_X86_64_PLT32	rt_int_add-0x4
    1c25:	mov    r15,rax
    1c28:	mov    ecx,0x1
    1c2d:	mov    rsi,rbx
    1c30:	test   rsi,0x1
    1c37:	jne    1c5d <botlish_fn_11+0x104>
    1c3d:	xor    ecx,ecx
    1c3f:	mov    rsi,rbx
    1c42:	test   rsi,0x7
    1c49:	jne    1c5d <botlish_fn_11+0x104>
    1c4f:	mov    rsi,rbx
    1c52:	movzx  rcx,BYTE PTR [rsi]
    1c56:	rex cmp cl,0x1
    1c5a:	sete   cl
    1c5d:	test   cl,cl
    1c5f:	jne    1c83 <botlish_fn_11+0x12a>
    1c65:	mov    rdi,r12
    1c68:	mov    rsi,QWORD PTR [rdi+0x10]
    1c6c:	mov    rcx,QWORD PTR [rsi+0x118]
    1c73:	xor    rdx,rdx
    1c76:	mov    rsi,rbx
    1c79:	call   1c7e <botlish_fn_11+0x125>
			1c7a: R_X86_64_PLT32	rt_type_error-0x4
    1c7e:	jmp    1c9d <botlish_fn_11+0x144>
    1c83:	mov    rdi,r12
    1c86:	mov    rcx,r15
    1c89:	mov    rdx,rbx
    1c8c:	mov    rsi,r13
    1c8f:	call   1c94 <botlish_fn_11+0x13b>
			1c90: R_X86_64_PLT32	rt_str_region_check-0x4
    1c94:	test   rax,rax
    1c97:	jne    1cc2 <botlish_fn_11+0x169>
    1c9d:	xor    rax,rax
    1ca0:	mov    rbx,QWORD PTR [rsp+0x20]
    1ca5:	mov    r12,QWORD PTR [rsp+0x28]
    1caa:	mov    r13,QWORD PTR [rsp+0x30]
    1caf:	mov    r14,QWORD PTR [rsp+0x38]
    1cb4:	mov    r15,QWORD PTR [rsp+0x40]
    1cb9:	add    rsp,0x50
    1cbd:	mov    rsp,rbp
    1cc0:	pop    rbp
    1cc1:	ret
    1cc2:	mov    rcx,r14
    1cc5:	mov    rsi,rbx
    1cc8:	mov    QWORD PTR [rcx],rsi
    1ccb:	mov    rax,r15
    1cce:	mov    QWORD PTR [rcx+0x8],rax
    1cd2:	mov    rax,r13
    1cd5:	mov    rbx,QWORD PTR [rsp+0x20]
    1cda:	mov    r12,QWORD PTR [rsp+0x28]
    1cdf:	mov    r13,QWORD PTR [rsp+0x30]
    1ce4:	mov    r14,QWORD PTR [rsp+0x38]
    1ce9:	mov    r15,QWORD PTR [rsp+0x40]
    1cee:	add    rsp,0x50
    1cf2:	mov    rsp,rbp
    1cf5:	pop    rbp
    1cf6:	ret

0000000000001cf7 <botlish_entry_11: char_at<generic>>:
    1cf7:	push   rbp
    1cf8:	mov    rbp,rsp
    1cfb:	ud2
    1cfd:	add    BYTE PTR [rax],al
	...

0000000000001d00 <botlish_fn_12: scan_local<generic>>:
    1d00:	push   rbp
    1d01:	mov    rbp,rsp
    1d04:	sub    rsp,0x80
    1d0b:	mov    QWORD PTR [rsp+0x50],rbx
    1d10:	mov    QWORD PTR [rsp+0x58],r12
    1d15:	mov    QWORD PTR [rsp+0x60],r13
    1d1a:	mov    QWORD PTR [rsp+0x68],r14
    1d1f:	mov    QWORD PTR [rsp+0x70],r15
    1d24:	mov    rax,rdi
    1d27:	mov    QWORD PTR [rsp+0x18],0x0
    1d30:	mov    QWORD PTR [rsp],rsi
    1d34:	mov    r14,rsi
    1d37:	mov    QWORD PTR [rsp+0x8],rdx
    1d3c:	mov    QWORD PTR [rsp+0x10],rcx
    1d41:	mov    r12,rcx
    1d44:	mov    r11d,0x1
    1d4a:	mov    rsi,r14
    1d4d:	test   rsi,0x1
    1d54:	jne    1d76 <botlish_fn_12+0x76>
    1d5a:	xor    r11d,r11d
    1d5d:	test   rsi,0x7
    1d64:	jne    1d76 <botlish_fn_12+0x76>
    1d6a:	movzx  rdi,BYTE PTR [rsi]
    1d6e:	cmp    dil,0x1
    1d72:	sete   r11b
    1d76:	test   r11b,r11b
    1d79:	jne    1d9a <botlish_fn_12+0x9a>
    1d7f:	mov    rdi,rax
    1d82:	mov    r9,QWORD PTR [rdi+0x10]
    1d86:	mov    rcx,QWORD PTR [r9+0xc0]
    1d8d:	xor    rdx,rdx
    1d90:	call   1d95 <botlish_fn_12+0x95>
			1d91: R_X86_64_PLT32	rt_type_error-0x4
    1d95:	jmp    1e4d <botlish_fn_12+0x14d>
    1d9a:	mov    r13,rdx
    1d9d:	mov    r10,rsi
    1da0:	and    r10,r13
    1da3:	mov    r14,rsi
    1da6:	test   r10,0x1
    1dad:	jne    1dd9 <botlish_fn_12+0xd9>
    1db3:	mov    rbx,rax
    1db6:	mov    rdx,r13
    1db9:	mov    rsi,r14
    1dbc:	mov    rdi,rbx
    1dbf:	call   1dc4 <botlish_fn_12+0xc4>
			1dc0: R_X86_64_PLT32	rt_int_cmp-0x4
    1dc4:	mov    ecx,0x2
    1dc9:	test   rax,rax
    1dcc:	cmovge rcx,QWORD PTR [rip+0x24c]        # 2020 <botlish_fn_12+0x320>
    1dd4:	jmp    1def <botlish_fn_12+0xef>
    1dd9:	mov    rbx,rax
    1ddc:	mov    ecx,0x2
    1de1:	mov    rsi,r14
    1de4:	cmp    rsi,r13
    1de7:	cmovge rcx,QWORD PTR [rip+0x231]        # 2020 <botlish_fn_12+0x320>
    1def:	mov    eax,0x6
    1df4:	mov    QWORD PTR [rsp+0x30],rax
    1df9:	cmp    rcx,0x6
    1dfd:	je     1ff3 <botlish_fn_12+0x2f3>
    1e03:	lea    rcx,[rsp+0x20]
    1e08:	mov    rdx,r12
    1e0b:	mov    rsi,r14
    1e0e:	mov    rdi,rbx
    1e11:	call   1e16 <botlish_fn_12+0x116>
			1e12: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    1e16:	mov    rsi,rax
    1e19:	mov    r15,rax
    1e1c:	test   rax,rsi
    1e1f:	je     1e4d <botlish_fn_12+0x14d>
    1e25:	mov    rdx,QWORD PTR [rsp+0x20]
    1e2a:	mov    QWORD PTR [rsp+0x40],rdx
    1e2f:	mov    rcx,QWORD PTR [rsp+0x28]
    1e34:	mov    QWORD PTR [rsp+0x38],rcx
    1e39:	mov    rsi,r15
    1e3c:	mov    rdi,rbx
    1e3f:	call   1e44 <botlish_fn_12+0x144>
			1e40: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    1e44:	test   rax,rax
    1e47:	jne    1e75 <botlish_fn_12+0x175>
    1e4d:	xor    rax,rax
    1e50:	mov    rbx,QWORD PTR [rsp+0x50]
    1e55:	mov    r12,QWORD PTR [rsp+0x58]
    1e5a:	mov    r13,QWORD PTR [rsp+0x60]
    1e5f:	mov    r14,QWORD PTR [rsp+0x68]
    1e64:	mov    r15,QWORD PTR [rsp+0x70]
    1e69:	add    rsp,0x80
    1e70:	mov    rsp,rbp
    1e73:	pop    rbp
    1e74:	ret
    1e75:	cmp    rax,0x6
    1e79:	je     1f74 <botlish_fn_12+0x274>
    1e7f:	mov    rax,QWORD PTR [rbx+0x10]
    1e83:	mov    r8,QWORD PTR [rax+0x120]
    1e8a:	mov    rcx,QWORD PTR [rsp+0x38]
    1e8f:	mov    rdx,QWORD PTR [rsp+0x40]
    1e94:	mov    rsi,r15
    1e97:	mov    rdi,rbx
    1e9a:	call   1e9f <botlish_fn_12+0x19f>
			1e9b: R_X86_64_PLT32	rt_str_region_eq-0x4
    1e9f:	cmp    rax,0x6
    1ea3:	je     1f6a <botlish_fn_12+0x26a>
    1ea9:	mov    rax,QWORD PTR [rbx+0x10]
    1ead:	mov    r8,QWORD PTR [rax+0x128]
    1eb4:	mov    rcx,QWORD PTR [rsp+0x38]
    1eb9:	mov    rdx,QWORD PTR [rsp+0x40]
    1ebe:	mov    rsi,r15
    1ec1:	mov    rdi,rbx
    1ec4:	call   1ec9 <botlish_fn_12+0x1c9>
			1ec5: R_X86_64_PLT32	rt_str_region_eq-0x4
    1ec9:	cmp    rax,0x6
    1ecd:	je     1f60 <botlish_fn_12+0x260>
    1ed3:	mov    rax,QWORD PTR [rbx+0x10]
    1ed7:	mov    r8,QWORD PTR [rax+0xc8]
    1ede:	mov    rcx,QWORD PTR [rsp+0x38]
    1ee3:	mov    rdx,QWORD PTR [rsp+0x40]
    1ee8:	mov    rsi,r15
    1eeb:	mov    rdi,rbx
    1eee:	call   1ef3 <botlish_fn_12+0x1f3>
			1eef: R_X86_64_PLT32	rt_str_region_eq-0x4
    1ef3:	cmp    rax,0x6
    1ef7:	je     1f56 <botlish_fn_12+0x256>
    1efd:	mov    rax,QWORD PTR [rbx+0x10]
    1f01:	mov    r8,QWORD PTR [rax+0x110]
    1f08:	mov    rcx,QWORD PTR [rsp+0x38]
    1f0d:	mov    rdx,QWORD PTR [rsp+0x40]
    1f12:	mov    rsi,r15
    1f15:	mov    rdi,rbx
    1f18:	call   1f1d <botlish_fn_12+0x21d>
			1f19: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f1d:	cmp    rax,0x6
    1f21:	je     1f4c <botlish_fn_12+0x24c>
    1f27:	mov    rax,QWORD PTR [rbx+0x10]
    1f2b:	mov    r8,QWORD PTR [rax+0x130]
    1f32:	mov    rcx,QWORD PTR [rsp+0x38]
    1f37:	mov    rdx,QWORD PTR [rsp+0x40]
    1f3c:	mov    rsi,r15
    1f3f:	mov    rdi,rbx
    1f42:	call   1f47 <botlish_fn_12+0x247>
			1f43: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f47:	jmp    1f79 <botlish_fn_12+0x279>
    1f4c:	mov    rax,QWORD PTR [rsp+0x30]
    1f51:	jmp    1f79 <botlish_fn_12+0x279>
    1f56:	mov    rax,QWORD PTR [rsp+0x30]
    1f5b:	jmp    1f79 <botlish_fn_12+0x279>
    1f60:	mov    rax,QWORD PTR [rsp+0x30]
    1f65:	jmp    1f79 <botlish_fn_12+0x279>
    1f6a:	mov    rax,QWORD PTR [rsp+0x30]
    1f6f:	jmp    1f79 <botlish_fn_12+0x279>
    1f74:	mov    rax,QWORD PTR [rsp+0x30]
    1f79:	cmp    rax,0x6
    1f7d:	je     1f8b <botlish_fn_12+0x28b>
    1f83:	mov    rax,r14
    1f86:	jmp    1ff6 <botlish_fn_12+0x2f6>
    1f8b:	mov    QWORD PTR [rsp+0x18],0x3
    1f94:	mov    rsi,r14
    1f97:	test   rsi,0x1
    1f9e:	je     1fc4 <botlish_fn_12+0x2c4>
    1fa4:	mov    rsi,r14
    1fa7:	mov    rax,rsi
    1faa:	add    rax,0x2
    1fae:	seto   cl
    1fb1:	test   cl,cl
    1fb3:	jne    1fc4 <botlish_fn_12+0x2c4>
    1fb9:	mov    rsi,rax
    1fbc:	mov    r14,rax
    1fbf:	jmp    1fda <botlish_fn_12+0x2da>
    1fc4:	mov    edx,0x3
    1fc9:	mov    rsi,r14
    1fcc:	mov    rdi,rbx
    1fcf:	call   1fd4 <botlish_fn_12+0x2d4>
			1fd0: R_X86_64_PLT32	rt_int_add-0x4
    1fd4:	mov    rsi,rax
    1fd7:	mov    r14,rax
    1fda:	mov    QWORD PTR [rsp],rsi
    1fde:	mov    QWORD PTR [rsp+0x8],r13
    1fe3:	mov    QWORD PTR [rsp+0x10],r12
    1fe8:	mov    rax,rbx
    1feb:	mov    rdx,r13
    1fee:	jmp    1d44 <botlish_fn_12+0x44>
    1ff3:	mov    rax,r14
    1ff6:	mov    rbx,QWORD PTR [rsp+0x50]
    1ffb:	mov    r12,QWORD PTR [rsp+0x58]
    2000:	mov    r13,QWORD PTR [rsp+0x60]
    2005:	mov    r14,QWORD PTR [rsp+0x68]
    200a:	mov    r15,QWORD PTR [rsp+0x70]
    200f:	add    rsp,0x80
    2016:	mov    rsp,rbp
    2019:	pop    rbp
    201a:	ret
    201b:	add    BYTE PTR [rax],al
    201d:	add    BYTE PTR [rax],al
    201f:	add    BYTE PTR [rsi],al
    2021:	add    BYTE PTR [rax],al
    2023:	add    BYTE PTR [rax],al
    2025:	add    BYTE PTR [rax],al
	...

0000000000002028 <botlish_entry_12: scan_local<generic>>:
    2028:	push   rbp
    2029:	mov    rbp,rsp
    202c:	mov    rsi,QWORD PTR [rdx]
    202f:	mov    r8,QWORD PTR [rdx+0x8]
    2033:	mov    rcx,QWORD PTR [rdx+0x10]
    2037:	mov    rdx,r8
    203a:	call   203f <botlish_entry_12+0x17>
			203b: R_X86_64_PLT32	botlish_fn_12-0x4 ; scan_local<generic>
    203f:	mov    rsp,rbp
    2042:	pop    rbp
    2043:	ret
    2044:	add    BYTE PTR [rax],al
	...

0000000000002048 <botlish_fn_13: scan_label<generic>>:
    2048:	push   rbp
    2049:	mov    rbp,rsp
    204c:	sub    rsp,0x80
    2053:	mov    QWORD PTR [rsp+0x50],rbx
    2058:	mov    QWORD PTR [rsp+0x58],r12
    205d:	mov    QWORD PTR [rsp+0x60],r13
    2062:	mov    QWORD PTR [rsp+0x68],r14
    2067:	mov    QWORD PTR [rsp+0x70],r15
    206c:	mov    QWORD PTR [rsp+0x18],0x0
    2075:	mov    QWORD PTR [rsp],rsi
    2079:	mov    r14,rsi
    207c:	mov    QWORD PTR [rsp+0x8],rdx
    2081:	mov    QWORD PTR [rsp+0x10],rcx
    2086:	mov    r12,rcx
    2089:	mov    r11d,0x1
    208f:	mov    rsi,r14
    2092:	test   rsi,0x1
    2099:	jne    20b9 <botlish_fn_13+0x71>
    209f:	xor    r11d,r11d
    20a2:	test   rsi,0x7
    20a9:	jne    20b9 <botlish_fn_13+0x71>
    20af:	movzx  rax,BYTE PTR [rsi]
    20b3:	cmp    al,0x1
    20b5:	sete   r11b
    20b9:	test   r11b,r11b
    20bc:	jne    20da <botlish_fn_13+0x92>
    20c2:	mov    rax,QWORD PTR [rdi+0x10]
    20c6:	mov    rcx,QWORD PTR [rax+0xc0]
    20cd:	xor    rdx,rdx
    20d0:	call   20d5 <botlish_fn_13+0x8d>
			20d1: R_X86_64_PLT32	rt_type_error-0x4
    20d5:	jmp    2186 <botlish_fn_13+0x13e>
    20da:	mov    r13,rdx
    20dd:	mov    rax,rsi
    20e0:	and    rax,r13
    20e3:	mov    r14,rsi
    20e6:	test   rax,0x1
    20ec:	jne    2115 <botlish_fn_13+0xcd>
    20f2:	mov    rbx,rdi
    20f5:	mov    rdx,r13
    20f8:	mov    rsi,r14
    20fb:	call   2100 <botlish_fn_13+0xb8>
			20fc: R_X86_64_PLT32	rt_int_cmp-0x4
    2100:	mov    ecx,0x2
    2105:	test   rax,rax
    2108:	cmovge rcx,QWORD PTR [rip+0x178]        # 2288 <botlish_fn_13+0x240>
    2110:	jmp    212b <botlish_fn_13+0xe3>
    2115:	mov    rbx,rdi
    2118:	mov    ecx,0x2
    211d:	mov    rsi,r14
    2120:	cmp    rsi,r13
    2123:	cmovge rcx,QWORD PTR [rip+0x15d]        # 2288 <botlish_fn_13+0x240>
    212b:	mov    eax,0x6
    2130:	mov    QWORD PTR [rsp+0x30],rax
    2135:	cmp    rcx,0x6
    2139:	je     225c <botlish_fn_13+0x214>
    213f:	lea    rcx,[rsp+0x20]
    2144:	mov    rdx,r12
    2147:	mov    rsi,r14
    214a:	mov    rdi,rbx
    214d:	call   2152 <botlish_fn_13+0x10a>
			214e: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2152:	test   rax,rax
    2155:	mov    r15,rax
    2158:	je     2186 <botlish_fn_13+0x13e>
    215e:	mov    rdx,QWORD PTR [rsp+0x20]
    2163:	mov    QWORD PTR [rsp+0x40],rdx
    2168:	mov    rcx,QWORD PTR [rsp+0x28]
    216d:	mov    QWORD PTR [rsp+0x38],rcx
    2172:	mov    rsi,r15
    2175:	mov    rdi,rbx
    2178:	call   217d <botlish_fn_13+0x135>
			2179: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    217d:	test   rax,rax
    2180:	jne    21ae <botlish_fn_13+0x166>
    2186:	xor    rax,rax
    2189:	mov    rbx,QWORD PTR [rsp+0x50]
    218e:	mov    r12,QWORD PTR [rsp+0x58]
    2193:	mov    r13,QWORD PTR [rsp+0x60]
    2198:	mov    r14,QWORD PTR [rsp+0x68]
    219d:	mov    r15,QWORD PTR [rsp+0x70]
    21a2:	add    rsp,0x80
    21a9:	mov    rsp,rbp
    21ac:	pop    rbp
    21ad:	ret
    21ae:	cmp    rax,0x6
    21b2:	je     21dd <botlish_fn_13+0x195>
    21b8:	mov    r11,QWORD PTR [rbx+0x10]
    21bc:	mov    r8,QWORD PTR [r11+0x130]
    21c3:	mov    rcx,QWORD PTR [rsp+0x38]
    21c8:	mov    rdx,QWORD PTR [rsp+0x40]
    21cd:	mov    rsi,r15
    21d0:	mov    rdi,rbx
    21d3:	call   21d8 <botlish_fn_13+0x190>
			21d4: R_X86_64_PLT32	rt_str_region_eq-0x4
    21d8:	jmp    21e2 <botlish_fn_13+0x19a>
    21dd:	mov    rax,QWORD PTR [rsp+0x30]
    21e2:	cmp    rax,0x6
    21e6:	je     21f4 <botlish_fn_13+0x1ac>
    21ec:	mov    rax,r14
    21ef:	jmp    225f <botlish_fn_13+0x217>
    21f4:	mov    QWORD PTR [rsp+0x18],0x3
    21fd:	mov    rsi,r14
    2200:	test   rsi,0x1
    2207:	je     222d <botlish_fn_13+0x1e5>
    220d:	mov    rsi,r14
    2210:	mov    rax,rsi
    2213:	add    rax,0x2
    2217:	seto   cl
    221a:	test   cl,cl
    221c:	jne    222d <botlish_fn_13+0x1e5>
    2222:	mov    rsi,rax
    2225:	mov    r14,rax
    2228:	jmp    2243 <botlish_fn_13+0x1fb>
    222d:	mov    edx,0x3
    2232:	mov    rsi,r14
    2235:	mov    rdi,rbx
    2238:	call   223d <botlish_fn_13+0x1f5>
			2239: R_X86_64_PLT32	rt_int_add-0x4
    223d:	mov    rsi,rax
    2240:	mov    r14,rax
    2243:	mov    QWORD PTR [rsp],rsi
    2247:	mov    QWORD PTR [rsp+0x8],r13
    224c:	mov    QWORD PTR [rsp+0x10],r12
    2251:	mov    rdx,r13
    2254:	mov    rdi,rbx
    2257:	jmp    2089 <botlish_fn_13+0x41>
    225c:	mov    rax,r14
    225f:	mov    rbx,QWORD PTR [rsp+0x50]
    2264:	mov    r12,QWORD PTR [rsp+0x58]
    2269:	mov    r13,QWORD PTR [rsp+0x60]
    226e:	mov    r14,QWORD PTR [rsp+0x68]
    2273:	mov    r15,QWORD PTR [rsp+0x70]
    2278:	add    rsp,0x80
    227f:	mov    rsp,rbp
    2282:	pop    rbp
    2283:	ret
    2284:	add    BYTE PTR [rax],al
    2286:	add    BYTE PTR [rax],al
    2288:	(bad)
    2289:	add    BYTE PTR [rax],al
    228b:	add    BYTE PTR [rax],al
    228d:	add    BYTE PTR [rax],al
	...

0000000000002290 <botlish_entry_13: scan_label<generic>>:
    2290:	push   rbp
    2291:	mov    rbp,rsp
    2294:	mov    rsi,QWORD PTR [rdx]
    2297:	mov    r8,QWORD PTR [rdx+0x8]
    229b:	mov    rcx,QWORD PTR [rdx+0x10]
    229f:	mov    rdx,r8
    22a2:	call   22a7 <botlish_entry_13+0x17>
			22a3: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_label<generic>
    22a7:	mov    rsp,rbp
    22aa:	pop    rbp
    22ab:	ret
    22ac:	add    BYTE PTR [rax],al
	...

00000000000022b0 <botlish_fn_14: scan_alpha<generic>>:
    22b0:	push   rbp
    22b1:	mov    rbp,rsp
    22b4:	sub    rsp,0x50
    22b8:	mov    QWORD PTR [rsp+0x30],rbx
    22bd:	mov    QWORD PTR [rsp+0x38],r12
    22c2:	mov    QWORD PTR [rsp+0x40],r13
    22c7:	mov    QWORD PTR [rsp+0x48],r14
    22cc:	mov    r14,rdi
    22cf:	mov    QWORD PTR [rsp+0x18],0x0
    22d8:	mov    QWORD PTR [rsp],rsi
    22dc:	mov    r13,rsi
    22df:	mov    QWORD PTR [rsp+0x8],rdx
    22e4:	mov    r12,rdx
    22e7:	mov    QWORD PTR [rsp+0x10],rcx
    22ec:	mov    rbx,rcx
    22ef:	mov    r11d,0x1
    22f5:	mov    rsi,r13
    22f8:	test   rsi,0x1
    22ff:	jne    231f <botlish_fn_14+0x6f>
    2305:	xor    r11d,r11d
    2308:	test   rsi,0x7
    230f:	jne    231f <botlish_fn_14+0x6f>
    2315:	movzx  rax,BYTE PTR [rsi]
    2319:	cmp    al,0x1
    231b:	sete   r11b
    231f:	test   r11b,r11b
    2322:	jne    2343 <botlish_fn_14+0x93>
    2328:	mov    rdi,r14
    232b:	mov    rax,QWORD PTR [rdi+0x10]
    232f:	mov    rcx,QWORD PTR [rax+0xc0]
    2336:	xor    rdx,rdx
    2339:	call   233e <botlish_fn_14+0x8e>
			233a: R_X86_64_PLT32	rt_type_error-0x4
    233e:	jmp    23d2 <botlish_fn_14+0x122>
    2343:	mov    rax,rsi
    2346:	and    rax,r12
    2349:	mov    r13,rsi
    234c:	test   rax,0x1
    2352:	jne    237b <botlish_fn_14+0xcb>
    2358:	mov    rdx,r12
    235b:	mov    rsi,r13
    235e:	mov    rdi,r14
    2361:	call   2366 <botlish_fn_14+0xb6>
			2362: R_X86_64_PLT32	rt_int_cmp-0x4
    2366:	mov    ecx,0x2
    236b:	test   rax,rax
    236e:	cmovge rcx,QWORD PTR [rip+0x112]        # 2488 <botlish_fn_14+0x1d8>
    2376:	jmp    238e <botlish_fn_14+0xde>
    237b:	mov    ecx,0x2
    2380:	mov    rsi,r13
    2383:	cmp    rsi,r12
    2386:	cmovge rcx,QWORD PTR [rip+0xfa]        # 2488 <botlish_fn_14+0x1d8>
    238e:	cmp    rcx,0x6
    2392:	je     2466 <botlish_fn_14+0x1b6>
    2398:	lea    rcx,[rsp+0x20]
    239d:	mov    rdx,rbx
    23a0:	mov    rsi,r13
    23a3:	mov    rdi,r14
    23a6:	call   23ab <botlish_fn_14+0xfb>
			23a7: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    23ab:	test   rax,rax
    23ae:	mov    rsi,rax
    23b1:	je     23d2 <botlish_fn_14+0x122>
    23b7:	mov    rdx,QWORD PTR [rsp+0x20]
    23bc:	mov    rcx,QWORD PTR [rsp+0x28]
    23c1:	mov    rdi,r14
    23c4:	call   23c9 <botlish_fn_14+0x119>
			23c5: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    23c9:	test   rax,rax
    23cc:	jne    23f2 <botlish_fn_14+0x142>
    23d2:	xor    rax,rax
    23d5:	mov    rbx,QWORD PTR [rsp+0x30]
    23da:	mov    r12,QWORD PTR [rsp+0x38]
    23df:	mov    r13,QWORD PTR [rsp+0x40]
    23e4:	mov    r14,QWORD PTR [rsp+0x48]
    23e9:	add    rsp,0x50
    23ed:	mov    rsp,rbp
    23f0:	pop    rbp
    23f1:	ret
    23f2:	cmp    rax,0x6
    23f6:	je     2404 <botlish_fn_14+0x154>
    23fc:	mov    rax,r13
    23ff:	jmp    2469 <botlish_fn_14+0x1b9>
    2404:	mov    QWORD PTR [rsp+0x18],0x3
    240d:	mov    rsi,r13
    2410:	test   rsi,0x1
    2417:	je     243d <botlish_fn_14+0x18d>
    241d:	mov    rsi,r13
    2420:	mov    r11,rsi
    2423:	add    r11,0x2
    2427:	seto   al
    242a:	test   al,al
    242c:	jne    243d <botlish_fn_14+0x18d>
    2432:	mov    rsi,r11
    2435:	mov    r13,r11
    2438:	jmp    2453 <botlish_fn_14+0x1a3>
    243d:	mov    edx,0x3
    2442:	mov    rsi,r13
    2445:	mov    rdi,r14
    2448:	call   244d <botlish_fn_14+0x19d>
			2449: R_X86_64_PLT32	rt_int_add-0x4
    244d:	mov    rsi,rax
    2450:	mov    r13,rax
    2453:	mov    QWORD PTR [rsp],rsi
    2457:	mov    QWORD PTR [rsp+0x8],r12
    245c:	mov    QWORD PTR [rsp+0x10],rbx
    2461:	jmp    22ef <botlish_fn_14+0x3f>
    2466:	mov    rax,r13
    2469:	mov    rbx,QWORD PTR [rsp+0x30]
    246e:	mov    r12,QWORD PTR [rsp+0x38]
    2473:	mov    r13,QWORD PTR [rsp+0x40]
    2478:	mov    r14,QWORD PTR [rsp+0x48]
    247d:	add    rsp,0x50
    2481:	mov    rsp,rbp
    2484:	pop    rbp
    2485:	ret
    2486:	add    BYTE PTR [rax],al
    2488:	(bad)
    2489:	add    BYTE PTR [rax],al
    248b:	add    BYTE PTR [rax],al
    248d:	add    BYTE PTR [rax],al
	...

0000000000002490 <botlish_entry_14: scan_alpha<generic>>:
    2490:	push   rbp
    2491:	mov    rbp,rsp
    2494:	mov    rsi,QWORD PTR [rdx]
    2497:	mov    r8,QWORD PTR [rdx+0x8]
    249b:	mov    rcx,QWORD PTR [rdx+0x10]
    249f:	mov    rdx,r8
    24a2:	call   24a7 <botlish_entry_14+0x17>
			24a3: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_alpha<generic>
    24a7:	mov    rsp,rbp
    24aa:	pop    rbp
    24ab:	ret
    24ac:	add    BYTE PTR [rax],al
	...

00000000000024b0 <botlish_fn_15: tld_ok<generic>>:
    24b0:	push   rbp
    24b1:	mov    rbp,rsp
    24b4:	sub    rsp,0x40
    24b8:	mov    QWORD PTR [rsp+0x20],rbx
    24bd:	mov    QWORD PTR [rsp+0x28],r12
    24c2:	mov    QWORD PTR [rsp+0x30],r13
    24c7:	mov    QWORD PTR [rsp+0x38],r14
    24cc:	mov    rbx,rdi
    24cf:	mov    QWORD PTR [rsp],rsi
    24d3:	mov    r12,rsi
    24d6:	mov    QWORD PTR [rsp+0x8],rdx
    24db:	mov    r14,rdx
    24de:	mov    QWORD PTR [rsp+0x10],rcx
    24e3:	mov    rdx,r14
    24e6:	mov    rsi,r12
    24e9:	mov    rdi,rbx
    24ec:	call   24f1 <botlish_fn_15+0x41>
			24ed: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_alpha<generic>
    24f1:	mov    rsi,rax
    24f4:	mov    r13,rax
    24f7:	test   rax,rsi
    24fa:	je     25bd <botlish_fn_15+0x10d>
    2500:	mov    rax,r13
    2503:	mov    QWORD PTR [rsp+0x8],rax
    2508:	mov    rdx,r14
    250b:	and    rax,rdx
    250e:	test   rax,0x1
    2514:	jne    253d <botlish_fn_15+0x8d>
    251a:	mov    rsi,r13
    251d:	mov    rdi,rbx
    2520:	call   2525 <botlish_fn_15+0x75>
			2521: R_X86_64_PLT32	rt_int_cmp-0x4
    2525:	mov    ecx,0x2
    252a:	test   rax,rax
    252d:	cmove  rcx,QWORD PTR [rip+0x15b]        # 2690 <botlish_fn_15+0x1e0>
    2535:	mov    rax,r13
    2538:	jmp    2550 <botlish_fn_15+0xa0>
    253d:	mov    ecx,0x2
    2542:	mov    rax,r13
    2545:	cmp    rax,rdx
    2548:	cmove  rcx,QWORD PTR [rip+0x140]        # 2690 <botlish_fn_15+0x1e0>
    2550:	cmp    rcx,0x6
    2554:	je     2567 <botlish_fn_15+0xb7>
    255a:	mov    ecx,0x2
    255f:	mov    rax,rcx
    2562:	jmp    266f <botlish_fn_15+0x1bf>
    2567:	mov    ecx,0x1
    256c:	mov    rsi,r12
    256f:	test   rsi,0x1
    2576:	jne    259c <botlish_fn_15+0xec>
    257c:	xor    ecx,ecx
    257e:	mov    rsi,r12
    2581:	test   rsi,0x7
    2588:	jne    259c <botlish_fn_15+0xec>
    258e:	mov    rsi,r12
    2591:	movzx  rcx,BYTE PTR [rsi]
    2595:	rex cmp cl,0x1
    2599:	sete   cl
    259c:	test   cl,cl
    259e:	jne    25dd <botlish_fn_15+0x12d>
    25a4:	mov    rdi,rbx
    25a7:	mov    rsi,QWORD PTR [rdi+0x10]
    25ab:	mov    rcx,QWORD PTR [rsi+0x130]
    25b2:	xor    rdx,rdx
    25b5:	mov    rsi,r12
    25b8:	call   25bd <botlish_fn_15+0x10d>
			25b9: R_X86_64_PLT32	rt_type_error-0x4
    25bd:	xor    rax,rax
    25c0:	mov    rbx,QWORD PTR [rsp+0x20]
    25c5:	mov    r12,QWORD PTR [rsp+0x28]
    25ca:	mov    r13,QWORD PTR [rsp+0x30]
    25cf:	mov    r14,QWORD PTR [rsp+0x38]
    25d4:	add    rsp,0x40
    25d8:	mov    rsp,rbp
    25db:	pop    rbp
    25dc:	ret
    25dd:	mov    rsi,r12
    25e0:	mov    rdi,rax
    25e3:	and    rdi,rsi
    25e6:	test   rdi,0x1
    25ed:	jne    25fe <botlish_fn_15+0x14e>
    25f3:	mov    rdx,r12
    25f6:	mov    rsi,rax
    25f9:	jmp    2621 <botlish_fn_15+0x171>
    25fe:	mov    rsi,r12
    2601:	mov    r8,rax
    2604:	sub    r8,rsi
    2607:	mov    r13,rax
    260a:	seto   r10b
    260e:	lea    rsi,[r8+0x1]
    2612:	test   r10b,r10b
    2615:	je     262c <botlish_fn_15+0x17c>
    261b:	mov    rdx,r12
    261e:	mov    rsi,r13
    2621:	mov    rdi,rbx
    2624:	call   2629 <botlish_fn_15+0x179>
			2625: R_X86_64_PLT32	rt_int_sub-0x4
    2629:	mov    rsi,rax
    262c:	test   rsi,0x1
    2633:	jne    265e <botlish_fn_15+0x1ae>
    2639:	mov    edx,0x5
    263e:	mov    rdi,rbx
    2641:	call   2646 <botlish_fn_15+0x196>
			2642: R_X86_64_PLT32	rt_int_cmp-0x4
    2646:	mov    ecx,0x2
    264b:	test   rax,rax
    264e:	mov    rax,rcx
    2651:	cmovge rax,QWORD PTR [rip+0x37]        # 2690 <botlish_fn_15+0x1e0>
    2659:	jmp    266f <botlish_fn_15+0x1bf>
    265e:	mov    eax,0x2
    2663:	cmp    rsi,0x5
    2667:	cmovge rax,QWORD PTR [rip+0x21]        # 2690 <botlish_fn_15+0x1e0>
    266f:	mov    rbx,QWORD PTR [rsp+0x20]
    2674:	mov    r12,QWORD PTR [rsp+0x28]
    2679:	mov    r13,QWORD PTR [rsp+0x30]
    267e:	mov    r14,QWORD PTR [rsp+0x38]
    2683:	add    rsp,0x40
    2687:	mov    rsp,rbp
    268a:	pop    rbp
    268b:	ret
    268c:	add    BYTE PTR [rax],al
    268e:	add    BYTE PTR [rax],al
    2690:	(bad)
    2691:	add    BYTE PTR [rax],al
    2693:	add    BYTE PTR [rax],al
    2695:	add    BYTE PTR [rax],al
	...

0000000000002698 <botlish_entry_15: tld_ok<generic>>:
    2698:	push   rbp
    2699:	mov    rbp,rsp
    269c:	mov    rsi,QWORD PTR [rdx]
    269f:	mov    r8,QWORD PTR [rdx+0x8]
    26a3:	mov    rcx,QWORD PTR [rdx+0x10]
    26a7:	mov    rdx,r8
    26aa:	call   26af <botlish_entry_15+0x17>
			26ab: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld_ok<generic>
    26af:	mov    rsp,rbp
    26b2:	pop    rbp
    26b3:	ret
    26b4:	add    BYTE PTR [rax],al
	...

00000000000026b8 <botlish_fn_16: domain_loop<generic>>:
    26b8:	push   rbp
    26b9:	mov    rbp,rsp
    26bc:	sub    rsp,0x70
    26c0:	mov    QWORD PTR [rsp+0x40],rbx
    26c5:	mov    QWORD PTR [rsp+0x48],r12
    26ca:	mov    QWORD PTR [rsp+0x50],r13
    26cf:	mov    QWORD PTR [rsp+0x58],r14
    26d4:	mov    QWORD PTR [rsp+0x60],r15
    26d9:	mov    QWORD PTR [rsp+0x18],0x0
    26e2:	mov    QWORD PTR [rsp],rsi
    26e6:	mov    QWORD PTR [rsp+0x8],rdx
    26eb:	mov    QWORD PTR [rsp+0x10],rcx
    26f0:	lea    rbx,[rsp+0x20]
    26f5:	mov    r12,rdi
    26f8:	mov    r13,rcx
    26fb:	mov    r14,rdx
    26fe:	mov    QWORD PTR [rsp+0x30],rsi
    2703:	mov    rcx,r13
    2706:	mov    rdx,r14
    2709:	mov    rsi,QWORD PTR [rsp+0x30]
    270e:	mov    rdi,r12
    2711:	call   2716 <botlish_fn_16+0x5e>
			2712: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_label<generic>
    2716:	mov    rcx,rax
    2719:	mov    r15,rax
    271c:	test   rax,rcx
    271f:	je     286f <botlish_fn_16+0x1b7>
    2725:	mov    rax,r15
    2728:	mov    QWORD PTR [rsp],rax
    272c:	mov    rdx,QWORD PTR [rsp+0x30]
    2731:	and    rax,rdx
    2734:	test   rax,0x1
    273a:	jne    2759 <botlish_fn_16+0xa1>
    2740:	mov    rsi,r15
    2743:	mov    rdi,r12
    2746:	call   274b <botlish_fn_16+0x93>
			2747: R_X86_64_PLT32	rt_value_eq-0x4
    274b:	test   rax,rax
    274e:	je     286f <botlish_fn_16+0x1b7>
    2754:	jmp    2769 <botlish_fn_16+0xb1>
    2759:	mov    eax,0x2
    275e:	cmp    r15,rdx
    2761:	cmove  rax,QWORD PTR [rip+0x187]        # 28f0 <botlish_fn_16+0x238>
    2769:	cmp    rax,0x6
    276d:	je     28c5 <botlish_fn_16+0x20d>
    2773:	mov    rax,r15
    2776:	and    rax,r14
    2779:	test   rax,0x1
    277f:	jne    27a8 <botlish_fn_16+0xf0>
    2785:	mov    rdx,r14
    2788:	mov    rsi,r15
    278b:	mov    rdi,r12
    278e:	call   2793 <botlish_fn_16+0xdb>
			278f: R_X86_64_PLT32	rt_int_cmp-0x4
    2793:	mov    ecx,0x2
    2798:	test   rax,rax
    279b:	cmovge rcx,QWORD PTR [rip+0x14d]        # 28f0 <botlish_fn_16+0x238>
    27a3:	jmp    27b8 <botlish_fn_16+0x100>
    27a8:	mov    ecx,0x2
    27ad:	cmp    r15,r14
    27b0:	cmovge rcx,QWORD PTR [rip+0x138]        # 28f0 <botlish_fn_16+0x238>
    27b8:	cmp    rcx,0x6
    27bc:	je     28b6 <botlish_fn_16+0x1fe>
    27c2:	mov    rcx,rbx
    27c5:	mov    rdx,r13
    27c8:	mov    rsi,r15
    27cb:	mov    rdi,r12
    27ce:	call   27d3 <botlish_fn_16+0x11b>
			27cf: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    27d3:	test   rax,rax
    27d6:	je     286f <botlish_fn_16+0x1b7>
    27dc:	mov    rdx,QWORD PTR [rsp+0x20]
    27e1:	mov    rcx,QWORD PTR [rsp+0x28]
    27e6:	mov    rsi,QWORD PTR [r12+0x10]
    27eb:	mov    r8,QWORD PTR [rsi+0x120]
    27f2:	mov    rsi,rax
    27f5:	mov    rdi,r12
    27f8:	call   27fd <botlish_fn_16+0x145>
			27f9: R_X86_64_PLT32	rt_str_region_eq-0x4
    27fd:	cmp    rax,0x6
    2801:	je     2813 <botlish_fn_16+0x15b>
    2807:	mov    r14,0xffffffffffffffff
    280e:	jmp    28bd <botlish_fn_16+0x205>
    2813:	mov    QWORD PTR [rsp+0x18],0x3
    281c:	test   r15,0x1
    2823:	je     283b <botlish_fn_16+0x183>
    2829:	mov    rdx,r15
    282c:	add    rdx,0x2
    2830:	seto   al
    2833:	test   al,al
    2835:	je     284e <botlish_fn_16+0x196>
    283b:	mov    edx,0x3
    2840:	mov    rsi,r15
    2843:	mov    rdi,r12
    2846:	call   284b <botlish_fn_16+0x193>
			2847: R_X86_64_PLT32	rt_int_add-0x4
    284b:	mov    rdx,rax
    284e:	mov    QWORD PTR [rsp],rdx
    2852:	mov    r15,rdx
    2855:	mov    rcx,r13
    2858:	mov    rdx,r14
    285b:	mov    rsi,r15
    285e:	mov    rdi,r12
    2861:	call   2866 <botlish_fn_16+0x1ae>
			2862: R_X86_64_PLT32	botlish_fn_15-0x4 ; tld_ok<generic>
    2866:	test   rax,rax
    2869:	jne    2894 <botlish_fn_16+0x1dc>
    286f:	xor    rax,rax
    2872:	mov    rbx,QWORD PTR [rsp+0x40]
    2877:	mov    r12,QWORD PTR [rsp+0x48]
    287c:	mov    r13,QWORD PTR [rsp+0x50]
    2881:	mov    r14,QWORD PTR [rsp+0x58]
    2886:	mov    r15,QWORD PTR [rsp+0x60]
    288b:	add    rsp,0x70
    288f:	mov    rsp,rbp
    2892:	pop    rbp
    2893:	ret
    2894:	cmp    rax,0x6
    2898:	je     28bd <botlish_fn_16+0x205>
    289e:	mov    QWORD PTR [rsp],r15
    28a2:	mov    QWORD PTR [rsp+0x8],r14
    28a7:	mov    QWORD PTR [rsp+0x10],r13
    28ac:	mov    QWORD PTR [rsp+0x30],r15
    28b1:	jmp    2703 <botlish_fn_16+0x4b>
    28b6:	mov    r14,0xffffffffffffffff
    28bd:	mov    rax,r14
    28c0:	jmp    28cc <botlish_fn_16+0x214>
    28c5:	mov    rax,0xffffffffffffffff
    28cc:	mov    rbx,QWORD PTR [rsp+0x40]
    28d1:	mov    r12,QWORD PTR [rsp+0x48]
    28d6:	mov    r13,QWORD PTR [rsp+0x50]
    28db:	mov    r14,QWORD PTR [rsp+0x58]
    28e0:	mov    r15,QWORD PTR [rsp+0x60]
    28e5:	add    rsp,0x70
    28e9:	mov    rsp,rbp
    28ec:	pop    rbp
    28ed:	ret
    28ee:	add    BYTE PTR [rax],al
    28f0:	(bad)
    28f1:	add    BYTE PTR [rax],al
    28f3:	add    BYTE PTR [rax],al
    28f5:	add    BYTE PTR [rax],al
	...

00000000000028f8 <botlish_entry_16: domain_loop<generic>>:
    28f8:	push   rbp
    28f9:	mov    rbp,rsp
    28fc:	mov    rsi,QWORD PTR [rdx]
    28ff:	mov    r8,QWORD PTR [rdx+0x8]
    2903:	mov    rcx,QWORD PTR [rdx+0x10]
    2907:	mov    rdx,r8
    290a:	call   290f <botlish_entry_16+0x17>
			290b: R_X86_64_PLT32	botlish_fn_16-0x4 ; domain_loop<generic>
    290f:	mov    rsp,rbp
    2912:	pop    rbp
    2913:	ret
    2914:	add    BYTE PTR [rax],al
	...

0000000000002918 <botlish_fn_17: <str>>:
    2918:	push   rbp
    2919:	mov    rbp,rsp
    291c:	sub    rsp,0x50
    2920:	mov    QWORD PTR [rsp+0x30],rbx
    2925:	mov    QWORD PTR [rsp+0x38],r12
    292a:	mov    QWORD PTR [rsp+0x40],r13
    292f:	mov    QWORD PTR [rsp+0x48],r14
    2934:	mov    r13,rdi
    2937:	mov    QWORD PTR [rsp+0x18],0x0
    2940:	mov    QWORD PTR [rsp],rsi
    2944:	mov    r14,rsi
    2947:	mov    rsi,r14
    294a:	mov    rdi,r13
    294d:	call   2952 <botlish_fn_17+0x3a>
			294e: R_X86_64_PLT32	rt_str_len-0x4
    2952:	mov    rbx,rax
    2955:	mov    QWORD PTR [rsp+0x8],rax
    295a:	mov    esi,0x1
    295f:	mov    QWORD PTR [rsp+0x10],0x1
    2968:	mov    rcx,r14
    296b:	mov    rdx,rbx
    296e:	mov    rdi,r13
    2971:	call   2976 <botlish_fn_17+0x5e>
			2972: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    2976:	mov    r12,rax
    2979:	test   r12,r12
    297c:	je     2ad9 <botlish_fn_17+0x1c1>
    2982:	mov    QWORD PTR [rsp+0x10],r12
    2987:	test   r12,0x1
    298e:	jne    29b9 <botlish_fn_17+0xa1>
    2994:	mov    edx,0x1
    2999:	mov    rsi,r12
    299c:	mov    rdi,r13
    299f:	call   29a4 <botlish_fn_17+0x8c>
			29a0: R_X86_64_PLT32	rt_int_cmp-0x4
    29a4:	mov    ecx,0x2
    29a9:	test   rax,rax
    29ac:	cmove  rcx,QWORD PTR [rip+0x1c4]        # 2b78 <botlish_fn_17+0x260>
    29b4:	jmp    29ca <botlish_fn_17+0xb2>
    29b9:	mov    ecx,0x2
    29be:	cmp    r12,0x1
    29c2:	cmove  rcx,QWORD PTR [rip+0x1ae]        # 2b78 <botlish_fn_17+0x260>
    29ca:	cmp    rcx,0x6
    29ce:	je     2b54 <botlish_fn_17+0x23c>
    29d4:	mov    rcx,r12
    29d7:	and    rcx,rbx
    29da:	test   rcx,0x1
    29e1:	jne    2a0a <botlish_fn_17+0xf2>
    29e7:	mov    rdx,rbx
    29ea:	mov    rsi,r12
    29ed:	mov    rdi,r13
    29f0:	call   29f5 <botlish_fn_17+0xdd>
			29f1: R_X86_64_PLT32	rt_int_cmp-0x4
    29f5:	mov    ecx,0x2
    29fa:	test   rax,rax
    29fd:	cmovge rcx,QWORD PTR [rip+0x173]        # 2b78 <botlish_fn_17+0x260>
    2a05:	jmp    2a1a <botlish_fn_17+0x102>
    2a0a:	mov    ecx,0x2
    2a0f:	cmp    r12,rbx
    2a12:	cmovge rcx,QWORD PTR [rip+0x15e]        # 2b78 <botlish_fn_17+0x260>
    2a1a:	cmp    rcx,0x6
    2a1e:	je     2b4a <botlish_fn_17+0x232>
    2a24:	lea    rcx,[rsp+0x20]
    2a29:	mov    rdx,r14
    2a2c:	mov    rsi,r12
    2a2f:	mov    rdi,r13
    2a32:	call   2a37 <botlish_fn_17+0x11f>
			2a33: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    2a37:	test   rax,rax
    2a3a:	mov    rsi,rax
    2a3d:	je     2ad9 <botlish_fn_17+0x1c1>
    2a43:	mov    rdx,QWORD PTR [rsp+0x20]
    2a48:	mov    rcx,QWORD PTR [rsp+0x28]
    2a4d:	mov    rdi,r13
    2a50:	mov    rax,QWORD PTR [rdi+0x10]
    2a54:	mov    r8,QWORD PTR [rax+0x108]
    2a5b:	call   2a60 <botlish_fn_17+0x148>
			2a5c: R_X86_64_PLT32	rt_str_region_eq-0x4
    2a60:	cmp    rax,0x6
    2a64:	je     2a77 <botlish_fn_17+0x15f>
    2a6a:	mov    ecx,0x2
    2a6f:	mov    rax,rcx
    2a72:	jmp    2b59 <botlish_fn_17+0x241>
    2a77:	mov    QWORD PTR [rsp+0x18],0x3
    2a80:	test   r12,0x1
    2a87:	jne    2a95 <botlish_fn_17+0x17d>
    2a8d:	mov    rcx,r12
    2a90:	jmp    2aaa <botlish_fn_17+0x192>
    2a95:	mov    rsi,r12
    2a98:	add    rsi,0x2
    2a9c:	mov    rcx,r12
    2a9f:	seto   al
    2aa2:	test   al,al
    2aa4:	je     2abd <botlish_fn_17+0x1a5>
    2aaa:	mov    edx,0x3
    2aaf:	mov    rsi,rcx
    2ab2:	mov    rdi,r13
    2ab5:	call   2aba <botlish_fn_17+0x1a2>
			2ab6: R_X86_64_PLT32	rt_int_add-0x4
    2aba:	mov    rsi,rax
    2abd:	mov    QWORD PTR [rsp+0x10],rsi
    2ac2:	mov    rcx,r14
    2ac5:	mov    rdx,rbx
    2ac8:	mov    rdi,r13
    2acb:	call   2ad0 <botlish_fn_17+0x1b8>
			2acc: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    2ad0:	test   rax,rax
    2ad3:	jne    2af9 <botlish_fn_17+0x1e1>
    2ad9:	xor    rax,rax
    2adc:	mov    rbx,QWORD PTR [rsp+0x30]
    2ae1:	mov    r12,QWORD PTR [rsp+0x38]
    2ae6:	mov    r13,QWORD PTR [rsp+0x40]
    2aeb:	mov    r14,QWORD PTR [rsp+0x48]
    2af0:	add    rsp,0x50
    2af4:	mov    rsp,rbp
    2af7:	pop    rbp
    2af8:	ret
    2af9:	mov    rcx,rax
    2afc:	and    rcx,rbx
    2aff:	mov    rsi,rax
    2b02:	test   rcx,0x1
    2b09:	jne    2b32 <botlish_fn_17+0x21a>
    2b0f:	mov    rdx,rbx
    2b12:	mov    rdi,r13
    2b15:	call   2b1a <botlish_fn_17+0x202>
			2b16: R_X86_64_PLT32	rt_int_cmp-0x4
    2b1a:	mov    ecx,0x2
    2b1f:	test   rax,rax
    2b22:	mov    rax,rcx
    2b25:	cmove  rax,QWORD PTR [rip+0x4b]        # 2b78 <botlish_fn_17+0x260>
    2b2d:	jmp    2b59 <botlish_fn_17+0x241>
    2b32:	mov    rdx,rbx
    2b35:	mov    eax,0x2
    2b3a:	cmp    rsi,rdx
    2b3d:	cmove  rax,QWORD PTR [rip+0x33]        # 2b78 <botlish_fn_17+0x260>
    2b45:	jmp    2b59 <botlish_fn_17+0x241>
    2b4a:	mov    eax,0x2
    2b4f:	jmp    2b59 <botlish_fn_17+0x241>
    2b54:	mov    eax,0x2
    2b59:	mov    rbx,QWORD PTR [rsp+0x30]
    2b5e:	mov    r12,QWORD PTR [rsp+0x38]
    2b63:	mov    r13,QWORD PTR [rsp+0x40]
    2b68:	mov    r14,QWORD PTR [rsp+0x48]
    2b6d:	add    rsp,0x50
    2b71:	mov    rsp,rbp
    2b74:	pop    rbp
    2b75:	ret
    2b76:	add    BYTE PTR [rax],al
    2b78:	(bad)
    2b79:	add    BYTE PTR [rax],al
    2b7b:	add    BYTE PTR [rax],al
    2b7d:	add    BYTE PTR [rax],al
	...

0000000000002b80 <botlish_entry_17: <str>>:
    2b80:	push   rbp
    2b81:	mov    rbp,rsp
    2b84:	mov    rsi,QWORD PTR [rdx]
    2b87:	call   2b8c <botlish_entry_17+0xc>
			2b88: R_X86_64_PLT32	botlish_fn_17-0x4 ; <str>
    2b8c:	mov    rsp,rbp
    2b8f:	pop    rbp
    2b90:	ret
    2b91:	add    BYTE PTR [rax],al
    2b93:	add    BYTE PTR [rax],al
    2b95:	add    BYTE PTR [rax],al
	...

0000000000002b98 <botlish_fn_18: <generic>>:
    2b98:	push   rbp
    2b99:	mov    rbp,rsp
    2b9c:	sub    rsp,0x60
    2ba0:	mov    QWORD PTR [rsp+0x30],rbx
    2ba5:	mov    QWORD PTR [rsp+0x38],r12
    2baa:	mov    QWORD PTR [rsp+0x40],r13
    2baf:	mov    QWORD PTR [rsp+0x48],r14
    2bb4:	mov    QWORD PTR [rsp+0x50],r15
    2bb9:	mov    QWORD PTR [rsp+0x18],0x0
    2bc2:	mov    QWORD PTR [rsp],rsi
    2bc6:	xor    r8d,r8d
    2bc9:	test   rsi,0x7
    2bd0:	jne    2be0 <botlish_fn_18+0x48>
    2bd6:	movzx  rax,BYTE PTR [rsi]
    2bda:	cmp    al,0x2
    2bdc:	sete   r8b
    2be0:	test   r8b,r8b
    2be3:	jne    2c03 <botlish_fn_18+0x6b>
    2be9:	mov    rdx,QWORD PTR [rdi+0x10]
    2bed:	mov    rcx,QWORD PTR [rdx+0xe0]
    2bf4:	mov    edx,0x1
    2bf9:	call   2bfe <botlish_fn_18+0x66>
			2bfa: R_X86_64_PLT32	rt_type_error-0x4
    2bfe:	jmp    2d98 <botlish_fn_18+0x200>
    2c03:	mov    r13,rsi
    2c06:	mov    r14,rdi
    2c09:	call   2c0e <botlish_fn_18+0x76>
			2c0a: R_X86_64_PLT32	rt_str_len-0x4
    2c0e:	mov    rbx,rax
    2c11:	mov    QWORD PTR [rsp+0x8],rax
    2c16:	mov    edx,0x1
    2c1b:	mov    r15,rdx
    2c1e:	mov    QWORD PTR [rsp+0x10],0x1
    2c27:	mov    rcx,r13
    2c2a:	mov    rdx,rbx
    2c2d:	mov    rsi,r15
    2c30:	mov    rdi,r14
    2c33:	call   2c38 <botlish_fn_18+0xa0>
			2c34: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    2c38:	mov    r12,rax
    2c3b:	test   r12,r12
    2c3e:	je     2d98 <botlish_fn_18+0x200>
    2c44:	mov    QWORD PTR [rsp+0x10],r12
    2c49:	test   r12,0x1
    2c50:	jne    2c79 <botlish_fn_18+0xe1>
    2c56:	mov    rdx,r15
    2c59:	mov    rsi,r12
    2c5c:	mov    rdi,r14
    2c5f:	call   2c64 <botlish_fn_18+0xcc>
			2c60: R_X86_64_PLT32	rt_int_cmp-0x4
    2c64:	mov    ecx,0x2
    2c69:	test   rax,rax
    2c6c:	cmove  rcx,QWORD PTR [rip+0x1cc]        # 2e40 <botlish_fn_18+0x2a8>
    2c74:	jmp    2c8a <botlish_fn_18+0xf2>
    2c79:	mov    ecx,0x2
    2c7e:	cmp    r12,0x1
    2c82:	cmove  rcx,QWORD PTR [rip+0x1b6]        # 2e40 <botlish_fn_18+0x2a8>
    2c8a:	cmp    rcx,0x6
    2c8e:	je     2e18 <botlish_fn_18+0x280>
    2c94:	mov    rax,r12
    2c97:	and    rax,rbx
    2c9a:	test   rax,0x1
    2ca0:	jne    2cc9 <botlish_fn_18+0x131>
    2ca6:	mov    rdx,rbx
    2ca9:	mov    rsi,r12
    2cac:	mov    rdi,r14
    2caf:	call   2cb4 <botlish_fn_18+0x11c>
			2cb0: R_X86_64_PLT32	rt_int_cmp-0x4
    2cb4:	mov    ecx,0x2
    2cb9:	test   rax,rax
    2cbc:	cmovge rcx,QWORD PTR [rip+0x17c]        # 2e40 <botlish_fn_18+0x2a8>
    2cc4:	jmp    2cd9 <botlish_fn_18+0x141>
    2cc9:	mov    ecx,0x2
    2cce:	cmp    r12,rbx
    2cd1:	cmovge rcx,QWORD PTR [rip+0x167]        # 2e40 <botlish_fn_18+0x2a8>
    2cd9:	cmp    rcx,0x6
    2cdd:	je     2e0e <botlish_fn_18+0x276>
    2ce3:	lea    rcx,[rsp+0x20]
    2ce8:	mov    rdx,r13
    2ceb:	mov    rsi,r12
    2cee:	mov    rdi,r14
    2cf1:	call   2cf6 <botlish_fn_18+0x15e>
			2cf2: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    2cf6:	test   rax,rax
    2cf9:	mov    rsi,rax
    2cfc:	je     2d98 <botlish_fn_18+0x200>
    2d02:	mov    rdx,QWORD PTR [rsp+0x20]
    2d07:	mov    rcx,QWORD PTR [rsp+0x28]
    2d0c:	mov    rdi,r14
    2d0f:	mov    rax,QWORD PTR [rdi+0x10]
    2d13:	mov    r8,QWORD PTR [rax+0x108]
    2d1a:	call   2d1f <botlish_fn_18+0x187>
			2d1b: R_X86_64_PLT32	rt_str_region_eq-0x4
    2d1f:	cmp    rax,0x6
    2d23:	je     2d36 <botlish_fn_18+0x19e>
    2d29:	mov    ecx,0x2
    2d2e:	mov    rax,rcx
    2d31:	jmp    2e1d <botlish_fn_18+0x285>
    2d36:	mov    QWORD PTR [rsp+0x18],0x3
    2d3f:	test   r12,0x1
    2d46:	jne    2d54 <botlish_fn_18+0x1bc>
    2d4c:	mov    rdi,r12
    2d4f:	jmp    2d69 <botlish_fn_18+0x1d1>
    2d54:	mov    rsi,r12
    2d57:	add    rsi,0x2
    2d5b:	mov    rdi,r12
    2d5e:	seto   al
    2d61:	test   al,al
    2d63:	je     2d7c <botlish_fn_18+0x1e4>
    2d69:	mov    edx,0x3
    2d6e:	mov    rsi,rdi
    2d71:	mov    rdi,r14
    2d74:	call   2d79 <botlish_fn_18+0x1e1>
			2d75: R_X86_64_PLT32	rt_int_add-0x4
    2d79:	mov    rsi,rax
    2d7c:	mov    QWORD PTR [rsp+0x10],rsi
    2d81:	mov    rcx,r13
    2d84:	mov    rdx,rbx
    2d87:	mov    rdi,r14
    2d8a:	call   2d8f <botlish_fn_18+0x1f7>
			2d8b: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    2d8f:	test   rax,rax
    2d92:	jne    2dbd <botlish_fn_18+0x225>
    2d98:	xor    rax,rax
    2d9b:	mov    rbx,QWORD PTR [rsp+0x30]
    2da0:	mov    r12,QWORD PTR [rsp+0x38]
    2da5:	mov    r13,QWORD PTR [rsp+0x40]
    2daa:	mov    r14,QWORD PTR [rsp+0x48]
    2daf:	mov    r15,QWORD PTR [rsp+0x50]
    2db4:	add    rsp,0x60
    2db8:	mov    rsp,rbp
    2dbb:	pop    rbp
    2dbc:	ret
    2dbd:	mov    rcx,rax
    2dc0:	and    rcx,rbx
    2dc3:	mov    rsi,rax
    2dc6:	test   rcx,0x1
    2dcd:	jne    2df6 <botlish_fn_18+0x25e>
    2dd3:	mov    rdx,rbx
    2dd6:	mov    rdi,r14
    2dd9:	call   2dde <botlish_fn_18+0x246>
			2dda: R_X86_64_PLT32	rt_int_cmp-0x4
    2dde:	mov    ecx,0x2
    2de3:	test   rax,rax
    2de6:	mov    rax,rcx
    2de9:	cmove  rax,QWORD PTR [rip+0x4f]        # 2e40 <botlish_fn_18+0x2a8>
    2df1:	jmp    2e1d <botlish_fn_18+0x285>
    2df6:	mov    rdx,rbx
    2df9:	mov    eax,0x2
    2dfe:	cmp    rsi,rdx
    2e01:	cmove  rax,QWORD PTR [rip+0x37]        # 2e40 <botlish_fn_18+0x2a8>
    2e09:	jmp    2e1d <botlish_fn_18+0x285>
    2e0e:	mov    eax,0x2
    2e13:	jmp    2e1d <botlish_fn_18+0x285>
    2e18:	mov    eax,0x2
    2e1d:	mov    rbx,QWORD PTR [rsp+0x30]
    2e22:	mov    r12,QWORD PTR [rsp+0x38]
    2e27:	mov    r13,QWORD PTR [rsp+0x40]
    2e2c:	mov    r14,QWORD PTR [rsp+0x48]
    2e31:	mov    r15,QWORD PTR [rsp+0x50]
    2e36:	add    rsp,0x60
    2e3a:	mov    rsp,rbp
    2e3d:	pop    rbp
    2e3e:	ret
    2e3f:	add    BYTE PTR [rsi],al
    2e41:	add    BYTE PTR [rax],al
    2e43:	add    BYTE PTR [rax],al
    2e45:	add    BYTE PTR [rax],al
	...

0000000000002e48 <botlish_entry_18: <generic>>:
    2e48:	push   rbp
    2e49:	mov    rbp,rsp
    2e4c:	mov    rsi,QWORD PTR [rdx]
    2e4f:	call   2e54 <botlish_entry_18+0xc>
			2e50: R_X86_64_PLT32	botlish_fn_18-0x4 ; <generic>
    2e54:	mov    rsp,rbp
    2e57:	pop    rbp
    2e58:	ret

0000000000002e59 <botlish_fn_19: char_at<generic>>:
    2e59:	push   rbp
    2e5a:	mov    rbp,rsp
    2e5d:	sub    rsp,0x50
    2e61:	mov    QWORD PTR [rsp+0x20],rbx
    2e66:	mov    QWORD PTR [rsp+0x28],r12
    2e6b:	mov    QWORD PTR [rsp+0x30],r13
    2e70:	mov    QWORD PTR [rsp+0x38],r14
    2e75:	mov    QWORD PTR [rsp+0x40],r15
    2e7a:	mov    r14,rcx
    2e7d:	mov    QWORD PTR [rsp],rsi
    2e81:	mov    QWORD PTR [rsp+0x8],rdx
    2e86:	mov    r13,rdx
    2e89:	mov    QWORD PTR [rsp+0x10],0x3
    2e92:	mov    r9d,0x1
    2e98:	test   rsi,0x1
    2e9f:	jne    2ebf <botlish_fn_19+0x66>
    2ea5:	xor    r9d,r9d
    2ea8:	test   rsi,0x7
    2eaf:	jne    2ebf <botlish_fn_19+0x66>
    2eb5:	movzx  rax,BYTE PTR [rsi]
    2eb9:	cmp    al,0x1
    2ebb:	sete   r9b
    2ebf:	test   r9b,r9b
    2ec2:	jne    2ee0 <botlish_fn_19+0x87>
    2ec8:	mov    rax,QWORD PTR [rdi+0x10]
    2ecc:	mov    rcx,QWORD PTR [rax+0x110]
    2ed3:	xor    rdx,rdx
    2ed6:	call   2edb <botlish_fn_19+0x82>
			2ed7: R_X86_64_PLT32	rt_type_error-0x4
    2edb:	jmp    2f9d <botlish_fn_19+0x144>
    2ee0:	mov    r12,rdi
    2ee3:	test   rsi,0x1
    2eea:	jne    2ef8 <botlish_fn_19+0x9f>
    2ef0:	mov    rbx,rsi
    2ef3:	jmp    2f15 <botlish_fn_19+0xbc>
    2ef8:	mov    rax,rsi
    2efb:	add    rax,0x2
    2eff:	mov    rbx,rsi
    2f02:	seto   cl
    2f05:	test   cl,cl
    2f07:	jne    2f15 <botlish_fn_19+0xbc>
    2f0d:	mov    r15,rax
    2f10:	jmp    2f28 <botlish_fn_19+0xcf>
    2f15:	mov    edx,0x3
    2f1a:	mov    rsi,rbx
    2f1d:	mov    rdi,r12
    2f20:	call   2f25 <botlish_fn_19+0xcc>
			2f21: R_X86_64_PLT32	rt_int_add-0x4
    2f25:	mov    r15,rax
    2f28:	mov    ecx,0x1
    2f2d:	mov    rsi,rbx
    2f30:	test   rsi,0x1
    2f37:	jne    2f5d <botlish_fn_19+0x104>
    2f3d:	xor    ecx,ecx
    2f3f:	mov    rsi,rbx
    2f42:	test   rsi,0x7
    2f49:	jne    2f5d <botlish_fn_19+0x104>
    2f4f:	mov    rsi,rbx
    2f52:	movzx  rcx,BYTE PTR [rsi]
    2f56:	rex cmp cl,0x1
    2f5a:	sete   cl
    2f5d:	test   cl,cl
    2f5f:	jne    2f83 <botlish_fn_19+0x12a>
    2f65:	mov    rdi,r12
    2f68:	mov    rsi,QWORD PTR [rdi+0x10]
    2f6c:	mov    rcx,QWORD PTR [rsi+0x118]
    2f73:	xor    rdx,rdx
    2f76:	mov    rsi,rbx
    2f79:	call   2f7e <botlish_fn_19+0x125>
			2f7a: R_X86_64_PLT32	rt_type_error-0x4
    2f7e:	jmp    2f9d <botlish_fn_19+0x144>
    2f83:	mov    rdi,r12
    2f86:	mov    rcx,r15
    2f89:	mov    rdx,rbx
    2f8c:	mov    rsi,r13
    2f8f:	call   2f94 <botlish_fn_19+0x13b>
			2f90: R_X86_64_PLT32	rt_str_region_check-0x4
    2f94:	test   rax,rax
    2f97:	jne    2fc2 <botlish_fn_19+0x169>
    2f9d:	xor    rax,rax
    2fa0:	mov    rbx,QWORD PTR [rsp+0x20]
    2fa5:	mov    r12,QWORD PTR [rsp+0x28]
    2faa:	mov    r13,QWORD PTR [rsp+0x30]
    2faf:	mov    r14,QWORD PTR [rsp+0x38]
    2fb4:	mov    r15,QWORD PTR [rsp+0x40]
    2fb9:	add    rsp,0x50
    2fbd:	mov    rsp,rbp
    2fc0:	pop    rbp
    2fc1:	ret
    2fc2:	mov    rcx,r14
    2fc5:	mov    rsi,rbx
    2fc8:	mov    QWORD PTR [rcx],rsi
    2fcb:	mov    rax,r15
    2fce:	mov    QWORD PTR [rcx+0x8],rax
    2fd2:	mov    rax,r13
    2fd5:	mov    rbx,QWORD PTR [rsp+0x20]
    2fda:	mov    r12,QWORD PTR [rsp+0x28]
    2fdf:	mov    r13,QWORD PTR [rsp+0x30]
    2fe4:	mov    r14,QWORD PTR [rsp+0x38]
    2fe9:	mov    r15,QWORD PTR [rsp+0x40]
    2fee:	add    rsp,0x50
    2ff2:	mov    rsp,rbp
    2ff5:	pop    rbp
    2ff6:	ret

0000000000002ff7 <botlish_entry_19: char_at<generic>>:
    2ff7:	push   rbp
    2ff8:	mov    rbp,rsp
    2ffb:	ud2
    2ffd:	add    BYTE PTR [rax],al
	...

0000000000003000 <botlish_fn_20: scan_local<generic>>:
    3000:	push   rbp
    3001:	mov    rbp,rsp
    3004:	sub    rsp,0x80
    300b:	mov    QWORD PTR [rsp+0x50],rbx
    3010:	mov    QWORD PTR [rsp+0x58],r12
    3015:	mov    QWORD PTR [rsp+0x60],r13
    301a:	mov    QWORD PTR [rsp+0x68],r14
    301f:	mov    QWORD PTR [rsp+0x70],r15
    3024:	mov    rax,rdi
    3027:	mov    QWORD PTR [rsp+0x18],0x0
    3030:	mov    QWORD PTR [rsp],rsi
    3034:	mov    r14,rsi
    3037:	mov    QWORD PTR [rsp+0x8],rdx
    303c:	mov    QWORD PTR [rsp+0x10],rcx
    3041:	mov    r12,rcx
    3044:	mov    r11d,0x1
    304a:	mov    rsi,r14
    304d:	test   rsi,0x1
    3054:	jne    3076 <botlish_fn_20+0x76>
    305a:	xor    r11d,r11d
    305d:	test   rsi,0x7
    3064:	jne    3076 <botlish_fn_20+0x76>
    306a:	movzx  rdi,BYTE PTR [rsi]
    306e:	cmp    dil,0x1
    3072:	sete   r11b
    3076:	test   r11b,r11b
    3079:	jne    309a <botlish_fn_20+0x9a>
    307f:	mov    rdi,rax
    3082:	mov    r9,QWORD PTR [rdi+0x10]
    3086:	mov    rcx,QWORD PTR [r9+0xc0]
    308d:	xor    rdx,rdx
    3090:	call   3095 <botlish_fn_20+0x95>
			3091: R_X86_64_PLT32	rt_type_error-0x4
    3095:	jmp    314d <botlish_fn_20+0x14d>
    309a:	mov    r13,rdx
    309d:	mov    r10,rsi
    30a0:	and    r10,r13
    30a3:	mov    r14,rsi
    30a6:	test   r10,0x1
    30ad:	jne    30d9 <botlish_fn_20+0xd9>
    30b3:	mov    rbx,rax
    30b6:	mov    rdx,r13
    30b9:	mov    rsi,r14
    30bc:	mov    rdi,rbx
    30bf:	call   30c4 <botlish_fn_20+0xc4>
			30c0: R_X86_64_PLT32	rt_int_cmp-0x4
    30c4:	mov    ecx,0x2
    30c9:	test   rax,rax
    30cc:	cmovge rcx,QWORD PTR [rip+0x24c]        # 3320 <botlish_fn_20+0x320>
    30d4:	jmp    30ef <botlish_fn_20+0xef>
    30d9:	mov    rbx,rax
    30dc:	mov    ecx,0x2
    30e1:	mov    rsi,r14
    30e4:	cmp    rsi,r13
    30e7:	cmovge rcx,QWORD PTR [rip+0x231]        # 3320 <botlish_fn_20+0x320>
    30ef:	mov    eax,0x6
    30f4:	mov    QWORD PTR [rsp+0x30],rax
    30f9:	cmp    rcx,0x6
    30fd:	je     32f3 <botlish_fn_20+0x2f3>
    3103:	lea    rcx,[rsp+0x20]
    3108:	mov    rdx,r12
    310b:	mov    rsi,r14
    310e:	mov    rdi,rbx
    3111:	call   3116 <botlish_fn_20+0x116>
			3112: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    3116:	mov    rsi,rax
    3119:	mov    r15,rax
    311c:	test   rax,rsi
    311f:	je     314d <botlish_fn_20+0x14d>
    3125:	mov    rdx,QWORD PTR [rsp+0x20]
    312a:	mov    QWORD PTR [rsp+0x40],rdx
    312f:	mov    rcx,QWORD PTR [rsp+0x28]
    3134:	mov    QWORD PTR [rsp+0x38],rcx
    3139:	mov    rsi,r15
    313c:	mov    rdi,rbx
    313f:	call   3144 <botlish_fn_20+0x144>
			3140: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    3144:	test   rax,rax
    3147:	jne    3175 <botlish_fn_20+0x175>
    314d:	xor    rax,rax
    3150:	mov    rbx,QWORD PTR [rsp+0x50]
    3155:	mov    r12,QWORD PTR [rsp+0x58]
    315a:	mov    r13,QWORD PTR [rsp+0x60]
    315f:	mov    r14,QWORD PTR [rsp+0x68]
    3164:	mov    r15,QWORD PTR [rsp+0x70]
    3169:	add    rsp,0x80
    3170:	mov    rsp,rbp
    3173:	pop    rbp
    3174:	ret
    3175:	cmp    rax,0x6
    3179:	je     3274 <botlish_fn_20+0x274>
    317f:	mov    rax,QWORD PTR [rbx+0x10]
    3183:	mov    r8,QWORD PTR [rax+0x120]
    318a:	mov    rcx,QWORD PTR [rsp+0x38]
    318f:	mov    rdx,QWORD PTR [rsp+0x40]
    3194:	mov    rsi,r15
    3197:	mov    rdi,rbx
    319a:	call   319f <botlish_fn_20+0x19f>
			319b: R_X86_64_PLT32	rt_str_region_eq-0x4
    319f:	cmp    rax,0x6
    31a3:	je     326a <botlish_fn_20+0x26a>
    31a9:	mov    rax,QWORD PTR [rbx+0x10]
    31ad:	mov    r8,QWORD PTR [rax+0x128]
    31b4:	mov    rcx,QWORD PTR [rsp+0x38]
    31b9:	mov    rdx,QWORD PTR [rsp+0x40]
    31be:	mov    rsi,r15
    31c1:	mov    rdi,rbx
    31c4:	call   31c9 <botlish_fn_20+0x1c9>
			31c5: R_X86_64_PLT32	rt_str_region_eq-0x4
    31c9:	cmp    rax,0x6
    31cd:	je     3260 <botlish_fn_20+0x260>
    31d3:	mov    rax,QWORD PTR [rbx+0x10]
    31d7:	mov    r8,QWORD PTR [rax+0xc8]
    31de:	mov    rcx,QWORD PTR [rsp+0x38]
    31e3:	mov    rdx,QWORD PTR [rsp+0x40]
    31e8:	mov    rsi,r15
    31eb:	mov    rdi,rbx
    31ee:	call   31f3 <botlish_fn_20+0x1f3>
			31ef: R_X86_64_PLT32	rt_str_region_eq-0x4
    31f3:	cmp    rax,0x6
    31f7:	je     3256 <botlish_fn_20+0x256>
    31fd:	mov    rax,QWORD PTR [rbx+0x10]
    3201:	mov    r8,QWORD PTR [rax+0x110]
    3208:	mov    rcx,QWORD PTR [rsp+0x38]
    320d:	mov    rdx,QWORD PTR [rsp+0x40]
    3212:	mov    rsi,r15
    3215:	mov    rdi,rbx
    3218:	call   321d <botlish_fn_20+0x21d>
			3219: R_X86_64_PLT32	rt_str_region_eq-0x4
    321d:	cmp    rax,0x6
    3221:	je     324c <botlish_fn_20+0x24c>
    3227:	mov    rax,QWORD PTR [rbx+0x10]
    322b:	mov    r8,QWORD PTR [rax+0x130]
    3232:	mov    rcx,QWORD PTR [rsp+0x38]
    3237:	mov    rdx,QWORD PTR [rsp+0x40]
    323c:	mov    rsi,r15
    323f:	mov    rdi,rbx
    3242:	call   3247 <botlish_fn_20+0x247>
			3243: R_X86_64_PLT32	rt_str_region_eq-0x4
    3247:	jmp    3279 <botlish_fn_20+0x279>
    324c:	mov    rax,QWORD PTR [rsp+0x30]
    3251:	jmp    3279 <botlish_fn_20+0x279>
    3256:	mov    rax,QWORD PTR [rsp+0x30]
    325b:	jmp    3279 <botlish_fn_20+0x279>
    3260:	mov    rax,QWORD PTR [rsp+0x30]
    3265:	jmp    3279 <botlish_fn_20+0x279>
    326a:	mov    rax,QWORD PTR [rsp+0x30]
    326f:	jmp    3279 <botlish_fn_20+0x279>
    3274:	mov    rax,QWORD PTR [rsp+0x30]
    3279:	cmp    rax,0x6
    327d:	je     328b <botlish_fn_20+0x28b>
    3283:	mov    rax,r14
    3286:	jmp    32f6 <botlish_fn_20+0x2f6>
    328b:	mov    QWORD PTR [rsp+0x18],0x3
    3294:	mov    rsi,r14
    3297:	test   rsi,0x1
    329e:	je     32c4 <botlish_fn_20+0x2c4>
    32a4:	mov    rsi,r14
    32a7:	mov    rax,rsi
    32aa:	add    rax,0x2
    32ae:	seto   cl
    32b1:	test   cl,cl
    32b3:	jne    32c4 <botlish_fn_20+0x2c4>
    32b9:	mov    rsi,rax
    32bc:	mov    r14,rax
    32bf:	jmp    32da <botlish_fn_20+0x2da>
    32c4:	mov    edx,0x3
    32c9:	mov    rsi,r14
    32cc:	mov    rdi,rbx
    32cf:	call   32d4 <botlish_fn_20+0x2d4>
			32d0: R_X86_64_PLT32	rt_int_add-0x4
    32d4:	mov    rsi,rax
    32d7:	mov    r14,rax
    32da:	mov    QWORD PTR [rsp],rsi
    32de:	mov    QWORD PTR [rsp+0x8],r13
    32e3:	mov    QWORD PTR [rsp+0x10],r12
    32e8:	mov    rax,rbx
    32eb:	mov    rdx,r13
    32ee:	jmp    3044 <botlish_fn_20+0x44>
    32f3:	mov    rax,r14
    32f6:	mov    rbx,QWORD PTR [rsp+0x50]
    32fb:	mov    r12,QWORD PTR [rsp+0x58]
    3300:	mov    r13,QWORD PTR [rsp+0x60]
    3305:	mov    r14,QWORD PTR [rsp+0x68]
    330a:	mov    r15,QWORD PTR [rsp+0x70]
    330f:	add    rsp,0x80
    3316:	mov    rsp,rbp
    3319:	pop    rbp
    331a:	ret
    331b:	add    BYTE PTR [rax],al
    331d:	add    BYTE PTR [rax],al
    331f:	add    BYTE PTR [rsi],al
    3321:	add    BYTE PTR [rax],al
    3323:	add    BYTE PTR [rax],al
    3325:	add    BYTE PTR [rax],al
	...

0000000000003328 <botlish_entry_20: scan_local<generic>>:
    3328:	push   rbp
    3329:	mov    rbp,rsp
    332c:	mov    rsi,QWORD PTR [rdx]
    332f:	mov    r8,QWORD PTR [rdx+0x8]
    3333:	mov    rcx,QWORD PTR [rdx+0x10]
    3337:	mov    rdx,r8
    333a:	call   333f <botlish_entry_20+0x17>
			333b: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_local<generic>
    333f:	mov    rsp,rbp
    3342:	pop    rbp
    3343:	ret
    3344:	add    BYTE PTR [rax],al
	...

0000000000003348 <botlish_fn_21: scan_label<generic>>:
    3348:	push   rbp
    3349:	mov    rbp,rsp
    334c:	sub    rsp,0x80
    3353:	mov    QWORD PTR [rsp+0x50],rbx
    3358:	mov    QWORD PTR [rsp+0x58],r12
    335d:	mov    QWORD PTR [rsp+0x60],r13
    3362:	mov    QWORD PTR [rsp+0x68],r14
    3367:	mov    QWORD PTR [rsp+0x70],r15
    336c:	mov    QWORD PTR [rsp+0x18],0x0
    3375:	mov    QWORD PTR [rsp],rsi
    3379:	mov    r14,rsi
    337c:	mov    QWORD PTR [rsp+0x8],rdx
    3381:	mov    QWORD PTR [rsp+0x10],rcx
    3386:	mov    r12,rcx
    3389:	mov    r11d,0x1
    338f:	mov    rsi,r14
    3392:	test   rsi,0x1
    3399:	jne    33b9 <botlish_fn_21+0x71>
    339f:	xor    r11d,r11d
    33a2:	test   rsi,0x7
    33a9:	jne    33b9 <botlish_fn_21+0x71>
    33af:	movzx  rax,BYTE PTR [rsi]
    33b3:	cmp    al,0x1
    33b5:	sete   r11b
    33b9:	test   r11b,r11b
    33bc:	jne    33da <botlish_fn_21+0x92>
    33c2:	mov    rax,QWORD PTR [rdi+0x10]
    33c6:	mov    rcx,QWORD PTR [rax+0xc0]
    33cd:	xor    rdx,rdx
    33d0:	call   33d5 <botlish_fn_21+0x8d>
			33d1: R_X86_64_PLT32	rt_type_error-0x4
    33d5:	jmp    3486 <botlish_fn_21+0x13e>
    33da:	mov    r13,rdx
    33dd:	mov    rax,rsi
    33e0:	and    rax,r13
    33e3:	mov    r14,rsi
    33e6:	test   rax,0x1
    33ec:	jne    3415 <botlish_fn_21+0xcd>
    33f2:	mov    rbx,rdi
    33f5:	mov    rdx,r13
    33f8:	mov    rsi,r14
    33fb:	call   3400 <botlish_fn_21+0xb8>
			33fc: R_X86_64_PLT32	rt_int_cmp-0x4
    3400:	mov    ecx,0x2
    3405:	test   rax,rax
    3408:	cmovge rcx,QWORD PTR [rip+0x178]        # 3588 <botlish_fn_21+0x240>
    3410:	jmp    342b <botlish_fn_21+0xe3>
    3415:	mov    rbx,rdi
    3418:	mov    ecx,0x2
    341d:	mov    rsi,r14
    3420:	cmp    rsi,r13
    3423:	cmovge rcx,QWORD PTR [rip+0x15d]        # 3588 <botlish_fn_21+0x240>
    342b:	mov    eax,0x6
    3430:	mov    QWORD PTR [rsp+0x30],rax
    3435:	cmp    rcx,0x6
    3439:	je     355c <botlish_fn_21+0x214>
    343f:	lea    rcx,[rsp+0x20]
    3444:	mov    rdx,r12
    3447:	mov    rsi,r14
    344a:	mov    rdi,rbx
    344d:	call   3452 <botlish_fn_21+0x10a>
			344e: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    3452:	test   rax,rax
    3455:	mov    r15,rax
    3458:	je     3486 <botlish_fn_21+0x13e>
    345e:	mov    rdx,QWORD PTR [rsp+0x20]
    3463:	mov    QWORD PTR [rsp+0x40],rdx
    3468:	mov    rcx,QWORD PTR [rsp+0x28]
    346d:	mov    QWORD PTR [rsp+0x38],rcx
    3472:	mov    rsi,r15
    3475:	mov    rdi,rbx
    3478:	call   347d <botlish_fn_21+0x135>
			3479: R_X86_64_PLT32	rt_str_region_is_tcl_alnum-0x4
    347d:	test   rax,rax
    3480:	jne    34ae <botlish_fn_21+0x166>
    3486:	xor    rax,rax
    3489:	mov    rbx,QWORD PTR [rsp+0x50]
    348e:	mov    r12,QWORD PTR [rsp+0x58]
    3493:	mov    r13,QWORD PTR [rsp+0x60]
    3498:	mov    r14,QWORD PTR [rsp+0x68]
    349d:	mov    r15,QWORD PTR [rsp+0x70]
    34a2:	add    rsp,0x80
    34a9:	mov    rsp,rbp
    34ac:	pop    rbp
    34ad:	ret
    34ae:	cmp    rax,0x6
    34b2:	je     34dd <botlish_fn_21+0x195>
    34b8:	mov    r11,QWORD PTR [rbx+0x10]
    34bc:	mov    r8,QWORD PTR [r11+0x130]
    34c3:	mov    rcx,QWORD PTR [rsp+0x38]
    34c8:	mov    rdx,QWORD PTR [rsp+0x40]
    34cd:	mov    rsi,r15
    34d0:	mov    rdi,rbx
    34d3:	call   34d8 <botlish_fn_21+0x190>
			34d4: R_X86_64_PLT32	rt_str_region_eq-0x4
    34d8:	jmp    34e2 <botlish_fn_21+0x19a>
    34dd:	mov    rax,QWORD PTR [rsp+0x30]
    34e2:	cmp    rax,0x6
    34e6:	je     34f4 <botlish_fn_21+0x1ac>
    34ec:	mov    rax,r14
    34ef:	jmp    355f <botlish_fn_21+0x217>
    34f4:	mov    QWORD PTR [rsp+0x18],0x3
    34fd:	mov    rsi,r14
    3500:	test   rsi,0x1
    3507:	je     352d <botlish_fn_21+0x1e5>
    350d:	mov    rsi,r14
    3510:	mov    rax,rsi
    3513:	add    rax,0x2
    3517:	seto   cl
    351a:	test   cl,cl
    351c:	jne    352d <botlish_fn_21+0x1e5>
    3522:	mov    rsi,rax
    3525:	mov    r14,rax
    3528:	jmp    3543 <botlish_fn_21+0x1fb>
    352d:	mov    edx,0x3
    3532:	mov    rsi,r14
    3535:	mov    rdi,rbx
    3538:	call   353d <botlish_fn_21+0x1f5>
			3539: R_X86_64_PLT32	rt_int_add-0x4
    353d:	mov    rsi,rax
    3540:	mov    r14,rax
    3543:	mov    QWORD PTR [rsp],rsi
    3547:	mov    QWORD PTR [rsp+0x8],r13
    354c:	mov    QWORD PTR [rsp+0x10],r12
    3551:	mov    rdx,r13
    3554:	mov    rdi,rbx
    3557:	jmp    3389 <botlish_fn_21+0x41>
    355c:	mov    rax,r14
    355f:	mov    rbx,QWORD PTR [rsp+0x50]
    3564:	mov    r12,QWORD PTR [rsp+0x58]
    3569:	mov    r13,QWORD PTR [rsp+0x60]
    356e:	mov    r14,QWORD PTR [rsp+0x68]
    3573:	mov    r15,QWORD PTR [rsp+0x70]
    3578:	add    rsp,0x80
    357f:	mov    rsp,rbp
    3582:	pop    rbp
    3583:	ret
    3584:	add    BYTE PTR [rax],al
    3586:	add    BYTE PTR [rax],al
    3588:	(bad)
    3589:	add    BYTE PTR [rax],al
    358b:	add    BYTE PTR [rax],al
    358d:	add    BYTE PTR [rax],al
	...

0000000000003590 <botlish_entry_21: scan_label<generic>>:
    3590:	push   rbp
    3591:	mov    rbp,rsp
    3594:	mov    rsi,QWORD PTR [rdx]
    3597:	mov    r8,QWORD PTR [rdx+0x8]
    359b:	mov    rcx,QWORD PTR [rdx+0x10]
    359f:	mov    rdx,r8
    35a2:	call   35a7 <botlish_entry_21+0x17>
			35a3: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    35a7:	mov    rsp,rbp
    35aa:	pop    rbp
    35ab:	ret
    35ac:	add    BYTE PTR [rax],al
	...

00000000000035b0 <botlish_fn_22: scan_alpha<generic>>:
    35b0:	push   rbp
    35b1:	mov    rbp,rsp
    35b4:	sub    rsp,0x50
    35b8:	mov    QWORD PTR [rsp+0x30],rbx
    35bd:	mov    QWORD PTR [rsp+0x38],r12
    35c2:	mov    QWORD PTR [rsp+0x40],r13
    35c7:	mov    QWORD PTR [rsp+0x48],r14
    35cc:	mov    r14,rdi
    35cf:	mov    QWORD PTR [rsp+0x18],0x0
    35d8:	mov    QWORD PTR [rsp],rsi
    35dc:	mov    r13,rsi
    35df:	mov    QWORD PTR [rsp+0x8],rdx
    35e4:	mov    r12,rdx
    35e7:	mov    QWORD PTR [rsp+0x10],rcx
    35ec:	mov    rbx,rcx
    35ef:	mov    r11d,0x1
    35f5:	mov    rsi,r13
    35f8:	test   rsi,0x1
    35ff:	jne    361f <botlish_fn_22+0x6f>
    3605:	xor    r11d,r11d
    3608:	test   rsi,0x7
    360f:	jne    361f <botlish_fn_22+0x6f>
    3615:	movzx  rax,BYTE PTR [rsi]
    3619:	cmp    al,0x1
    361b:	sete   r11b
    361f:	test   r11b,r11b
    3622:	jne    3643 <botlish_fn_22+0x93>
    3628:	mov    rdi,r14
    362b:	mov    rax,QWORD PTR [rdi+0x10]
    362f:	mov    rcx,QWORD PTR [rax+0xc0]
    3636:	xor    rdx,rdx
    3639:	call   363e <botlish_fn_22+0x8e>
			363a: R_X86_64_PLT32	rt_type_error-0x4
    363e:	jmp    36d2 <botlish_fn_22+0x122>
    3643:	mov    rax,rsi
    3646:	and    rax,r12
    3649:	mov    r13,rsi
    364c:	test   rax,0x1
    3652:	jne    367b <botlish_fn_22+0xcb>
    3658:	mov    rdx,r12
    365b:	mov    rsi,r13
    365e:	mov    rdi,r14
    3661:	call   3666 <botlish_fn_22+0xb6>
			3662: R_X86_64_PLT32	rt_int_cmp-0x4
    3666:	mov    ecx,0x2
    366b:	test   rax,rax
    366e:	cmovge rcx,QWORD PTR [rip+0x112]        # 3788 <botlish_fn_22+0x1d8>
    3676:	jmp    368e <botlish_fn_22+0xde>
    367b:	mov    ecx,0x2
    3680:	mov    rsi,r13
    3683:	cmp    rsi,r12
    3686:	cmovge rcx,QWORD PTR [rip+0xfa]        # 3788 <botlish_fn_22+0x1d8>
    368e:	cmp    rcx,0x6
    3692:	je     3766 <botlish_fn_22+0x1b6>
    3698:	lea    rcx,[rsp+0x20]
    369d:	mov    rdx,rbx
    36a0:	mov    rsi,r13
    36a3:	mov    rdi,r14
    36a6:	call   36ab <botlish_fn_22+0xfb>
			36a7: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    36ab:	test   rax,rax
    36ae:	mov    rsi,rax
    36b1:	je     36d2 <botlish_fn_22+0x122>
    36b7:	mov    rdx,QWORD PTR [rsp+0x20]
    36bc:	mov    rcx,QWORD PTR [rsp+0x28]
    36c1:	mov    rdi,r14
    36c4:	call   36c9 <botlish_fn_22+0x119>
			36c5: R_X86_64_PLT32	rt_str_region_is_tcl_alpha-0x4
    36c9:	test   rax,rax
    36cc:	jne    36f2 <botlish_fn_22+0x142>
    36d2:	xor    rax,rax
    36d5:	mov    rbx,QWORD PTR [rsp+0x30]
    36da:	mov    r12,QWORD PTR [rsp+0x38]
    36df:	mov    r13,QWORD PTR [rsp+0x40]
    36e4:	mov    r14,QWORD PTR [rsp+0x48]
    36e9:	add    rsp,0x50
    36ed:	mov    rsp,rbp
    36f0:	pop    rbp
    36f1:	ret
    36f2:	cmp    rax,0x6
    36f6:	je     3704 <botlish_fn_22+0x154>
    36fc:	mov    rax,r13
    36ff:	jmp    3769 <botlish_fn_22+0x1b9>
    3704:	mov    QWORD PTR [rsp+0x18],0x3
    370d:	mov    rsi,r13
    3710:	test   rsi,0x1
    3717:	je     373d <botlish_fn_22+0x18d>
    371d:	mov    rsi,r13
    3720:	mov    r11,rsi
    3723:	add    r11,0x2
    3727:	seto   al
    372a:	test   al,al
    372c:	jne    373d <botlish_fn_22+0x18d>
    3732:	mov    rsi,r11
    3735:	mov    r13,r11
    3738:	jmp    3753 <botlish_fn_22+0x1a3>
    373d:	mov    edx,0x3
    3742:	mov    rsi,r13
    3745:	mov    rdi,r14
    3748:	call   374d <botlish_fn_22+0x19d>
			3749: R_X86_64_PLT32	rt_int_add-0x4
    374d:	mov    rsi,rax
    3750:	mov    r13,rax
    3753:	mov    QWORD PTR [rsp],rsi
    3757:	mov    QWORD PTR [rsp+0x8],r12
    375c:	mov    QWORD PTR [rsp+0x10],rbx
    3761:	jmp    35ef <botlish_fn_22+0x3f>
    3766:	mov    rax,r13
    3769:	mov    rbx,QWORD PTR [rsp+0x30]
    376e:	mov    r12,QWORD PTR [rsp+0x38]
    3773:	mov    r13,QWORD PTR [rsp+0x40]
    3778:	mov    r14,QWORD PTR [rsp+0x48]
    377d:	add    rsp,0x50
    3781:	mov    rsp,rbp
    3784:	pop    rbp
    3785:	ret
    3786:	add    BYTE PTR [rax],al
    3788:	(bad)
    3789:	add    BYTE PTR [rax],al
    378b:	add    BYTE PTR [rax],al
    378d:	add    BYTE PTR [rax],al
	...

0000000000003790 <botlish_entry_22: scan_alpha<generic>>:
    3790:	push   rbp
    3791:	mov    rbp,rsp
    3794:	mov    rsi,QWORD PTR [rdx]
    3797:	mov    r8,QWORD PTR [rdx+0x8]
    379b:	mov    rcx,QWORD PTR [rdx+0x10]
    379f:	mov    rdx,r8
    37a2:	call   37a7 <botlish_entry_22+0x17>
			37a3: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    37a7:	mov    rsp,rbp
    37aa:	pop    rbp
    37ab:	ret
    37ac:	add    BYTE PTR [rax],al
	...

00000000000037b0 <botlish_fn_23: tld_ok<generic>>:
    37b0:	push   rbp
    37b1:	mov    rbp,rsp
    37b4:	sub    rsp,0x40
    37b8:	mov    QWORD PTR [rsp+0x20],rbx
    37bd:	mov    QWORD PTR [rsp+0x28],r12
    37c2:	mov    QWORD PTR [rsp+0x30],r13
    37c7:	mov    QWORD PTR [rsp+0x38],r14
    37cc:	mov    rbx,rdi
    37cf:	mov    QWORD PTR [rsp],rsi
    37d3:	mov    r12,rsi
    37d6:	mov    QWORD PTR [rsp+0x8],rdx
    37db:	mov    r14,rdx
    37de:	mov    QWORD PTR [rsp+0x10],rcx
    37e3:	mov    rdx,r14
    37e6:	mov    rsi,r12
    37e9:	mov    rdi,rbx
    37ec:	call   37f1 <botlish_fn_23+0x41>
			37ed: R_X86_64_PLT32	botlish_fn_22-0x4 ; scan_alpha<generic>
    37f1:	mov    rsi,rax
    37f4:	mov    r13,rax
    37f7:	test   rax,rsi
    37fa:	je     38bd <botlish_fn_23+0x10d>
    3800:	mov    rax,r13
    3803:	mov    QWORD PTR [rsp+0x8],rax
    3808:	mov    rdx,r14
    380b:	and    rax,rdx
    380e:	test   rax,0x1
    3814:	jne    383d <botlish_fn_23+0x8d>
    381a:	mov    rsi,r13
    381d:	mov    rdi,rbx
    3820:	call   3825 <botlish_fn_23+0x75>
			3821: R_X86_64_PLT32	rt_int_cmp-0x4
    3825:	mov    ecx,0x2
    382a:	test   rax,rax
    382d:	cmove  rcx,QWORD PTR [rip+0x15b]        # 3990 <botlish_fn_23+0x1e0>
    3835:	mov    rax,r13
    3838:	jmp    3850 <botlish_fn_23+0xa0>
    383d:	mov    ecx,0x2
    3842:	mov    rax,r13
    3845:	cmp    rax,rdx
    3848:	cmove  rcx,QWORD PTR [rip+0x140]        # 3990 <botlish_fn_23+0x1e0>
    3850:	cmp    rcx,0x6
    3854:	je     3867 <botlish_fn_23+0xb7>
    385a:	mov    ecx,0x2
    385f:	mov    rax,rcx
    3862:	jmp    396f <botlish_fn_23+0x1bf>
    3867:	mov    ecx,0x1
    386c:	mov    rsi,r12
    386f:	test   rsi,0x1
    3876:	jne    389c <botlish_fn_23+0xec>
    387c:	xor    ecx,ecx
    387e:	mov    rsi,r12
    3881:	test   rsi,0x7
    3888:	jne    389c <botlish_fn_23+0xec>
    388e:	mov    rsi,r12
    3891:	movzx  rcx,BYTE PTR [rsi]
    3895:	rex cmp cl,0x1
    3899:	sete   cl
    389c:	test   cl,cl
    389e:	jne    38dd <botlish_fn_23+0x12d>
    38a4:	mov    rdi,rbx
    38a7:	mov    rsi,QWORD PTR [rdi+0x10]
    38ab:	mov    rcx,QWORD PTR [rsi+0x130]
    38b2:	xor    rdx,rdx
    38b5:	mov    rsi,r12
    38b8:	call   38bd <botlish_fn_23+0x10d>
			38b9: R_X86_64_PLT32	rt_type_error-0x4
    38bd:	xor    rax,rax
    38c0:	mov    rbx,QWORD PTR [rsp+0x20]
    38c5:	mov    r12,QWORD PTR [rsp+0x28]
    38ca:	mov    r13,QWORD PTR [rsp+0x30]
    38cf:	mov    r14,QWORD PTR [rsp+0x38]
    38d4:	add    rsp,0x40
    38d8:	mov    rsp,rbp
    38db:	pop    rbp
    38dc:	ret
    38dd:	mov    rsi,r12
    38e0:	mov    rdi,rax
    38e3:	and    rdi,rsi
    38e6:	test   rdi,0x1
    38ed:	jne    38fe <botlish_fn_23+0x14e>
    38f3:	mov    rdx,r12
    38f6:	mov    rsi,rax
    38f9:	jmp    3921 <botlish_fn_23+0x171>
    38fe:	mov    rsi,r12
    3901:	mov    r8,rax
    3904:	sub    r8,rsi
    3907:	mov    r13,rax
    390a:	seto   r10b
    390e:	lea    rsi,[r8+0x1]
    3912:	test   r10b,r10b
    3915:	je     392c <botlish_fn_23+0x17c>
    391b:	mov    rdx,r12
    391e:	mov    rsi,r13
    3921:	mov    rdi,rbx
    3924:	call   3929 <botlish_fn_23+0x179>
			3925: R_X86_64_PLT32	rt_int_sub-0x4
    3929:	mov    rsi,rax
    392c:	test   rsi,0x1
    3933:	jne    395e <botlish_fn_23+0x1ae>
    3939:	mov    edx,0x5
    393e:	mov    rdi,rbx
    3941:	call   3946 <botlish_fn_23+0x196>
			3942: R_X86_64_PLT32	rt_int_cmp-0x4
    3946:	mov    ecx,0x2
    394b:	test   rax,rax
    394e:	mov    rax,rcx
    3951:	cmovge rax,QWORD PTR [rip+0x37]        # 3990 <botlish_fn_23+0x1e0>
    3959:	jmp    396f <botlish_fn_23+0x1bf>
    395e:	mov    eax,0x2
    3963:	cmp    rsi,0x5
    3967:	cmovge rax,QWORD PTR [rip+0x21]        # 3990 <botlish_fn_23+0x1e0>
    396f:	mov    rbx,QWORD PTR [rsp+0x20]
    3974:	mov    r12,QWORD PTR [rsp+0x28]
    3979:	mov    r13,QWORD PTR [rsp+0x30]
    397e:	mov    r14,QWORD PTR [rsp+0x38]
    3983:	add    rsp,0x40
    3987:	mov    rsp,rbp
    398a:	pop    rbp
    398b:	ret
    398c:	add    BYTE PTR [rax],al
    398e:	add    BYTE PTR [rax],al
    3990:	(bad)
    3991:	add    BYTE PTR [rax],al
    3993:	add    BYTE PTR [rax],al
    3995:	add    BYTE PTR [rax],al
	...

0000000000003998 <botlish_entry_23: tld_ok<generic>>:
    3998:	push   rbp
    3999:	mov    rbp,rsp
    399c:	mov    rsi,QWORD PTR [rdx]
    399f:	mov    r8,QWORD PTR [rdx+0x8]
    39a3:	mov    rcx,QWORD PTR [rdx+0x10]
    39a7:	mov    rdx,r8
    39aa:	call   39af <botlish_entry_23+0x17>
			39ab: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    39af:	mov    rsp,rbp
    39b2:	pop    rbp
    39b3:	ret
    39b4:	add    BYTE PTR [rax],al
	...

00000000000039b8 <botlish_fn_24: domain_loop<generic>>:
    39b8:	push   rbp
    39b9:	mov    rbp,rsp
    39bc:	sub    rsp,0x70
    39c0:	mov    QWORD PTR [rsp+0x40],rbx
    39c5:	mov    QWORD PTR [rsp+0x48],r12
    39ca:	mov    QWORD PTR [rsp+0x50],r13
    39cf:	mov    QWORD PTR [rsp+0x58],r14
    39d4:	mov    QWORD PTR [rsp+0x60],r15
    39d9:	mov    QWORD PTR [rsp+0x18],0x0
    39e2:	mov    QWORD PTR [rsp],rsi
    39e6:	mov    QWORD PTR [rsp+0x8],rdx
    39eb:	mov    QWORD PTR [rsp+0x10],rcx
    39f0:	lea    rbx,[rsp+0x20]
    39f5:	mov    r12,rdi
    39f8:	mov    r13,rcx
    39fb:	mov    r14,rdx
    39fe:	mov    QWORD PTR [rsp+0x30],rsi
    3a03:	mov    rcx,r13
    3a06:	mov    rdx,r14
    3a09:	mov    rsi,QWORD PTR [rsp+0x30]
    3a0e:	mov    rdi,r12
    3a11:	call   3a16 <botlish_fn_24+0x5e>
			3a12: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_label<generic>
    3a16:	mov    rcx,rax
    3a19:	mov    r15,rax
    3a1c:	test   rax,rcx
    3a1f:	je     3b6f <botlish_fn_24+0x1b7>
    3a25:	mov    rax,r15
    3a28:	mov    QWORD PTR [rsp],rax
    3a2c:	mov    rdx,QWORD PTR [rsp+0x30]
    3a31:	and    rax,rdx
    3a34:	test   rax,0x1
    3a3a:	jne    3a59 <botlish_fn_24+0xa1>
    3a40:	mov    rsi,r15
    3a43:	mov    rdi,r12
    3a46:	call   3a4b <botlish_fn_24+0x93>
			3a47: R_X86_64_PLT32	rt_value_eq-0x4
    3a4b:	test   rax,rax
    3a4e:	je     3b6f <botlish_fn_24+0x1b7>
    3a54:	jmp    3a69 <botlish_fn_24+0xb1>
    3a59:	mov    eax,0x2
    3a5e:	cmp    r15,rdx
    3a61:	cmove  rax,QWORD PTR [rip+0x187]        # 3bf0 <botlish_fn_24+0x238>
    3a69:	cmp    rax,0x6
    3a6d:	je     3bc5 <botlish_fn_24+0x20d>
    3a73:	mov    rax,r15
    3a76:	and    rax,r14
    3a79:	test   rax,0x1
    3a7f:	jne    3aa8 <botlish_fn_24+0xf0>
    3a85:	mov    rdx,r14
    3a88:	mov    rsi,r15
    3a8b:	mov    rdi,r12
    3a8e:	call   3a93 <botlish_fn_24+0xdb>
			3a8f: R_X86_64_PLT32	rt_int_cmp-0x4
    3a93:	mov    ecx,0x2
    3a98:	test   rax,rax
    3a9b:	cmovge rcx,QWORD PTR [rip+0x14d]        # 3bf0 <botlish_fn_24+0x238>
    3aa3:	jmp    3ab8 <botlish_fn_24+0x100>
    3aa8:	mov    ecx,0x2
    3aad:	cmp    r15,r14
    3ab0:	cmovge rcx,QWORD PTR [rip+0x138]        # 3bf0 <botlish_fn_24+0x238>
    3ab8:	cmp    rcx,0x6
    3abc:	je     3bb6 <botlish_fn_24+0x1fe>
    3ac2:	mov    rcx,rbx
    3ac5:	mov    rdx,r13
    3ac8:	mov    rsi,r15
    3acb:	mov    rdi,r12
    3ace:	call   3ad3 <botlish_fn_24+0x11b>
			3acf: R_X86_64_PLT32	botlish_fn_19-0x4 ; char_at<generic>
    3ad3:	test   rax,rax
    3ad6:	je     3b6f <botlish_fn_24+0x1b7>
    3adc:	mov    rdx,QWORD PTR [rsp+0x20]
    3ae1:	mov    rcx,QWORD PTR [rsp+0x28]
    3ae6:	mov    rsi,QWORD PTR [r12+0x10]
    3aeb:	mov    r8,QWORD PTR [rsi+0x120]
    3af2:	mov    rsi,rax
    3af5:	mov    rdi,r12
    3af8:	call   3afd <botlish_fn_24+0x145>
			3af9: R_X86_64_PLT32	rt_str_region_eq-0x4
    3afd:	cmp    rax,0x6
    3b01:	je     3b13 <botlish_fn_24+0x15b>
    3b07:	mov    r14,0xffffffffffffffff
    3b0e:	jmp    3bbd <botlish_fn_24+0x205>
    3b13:	mov    QWORD PTR [rsp+0x18],0x3
    3b1c:	test   r15,0x1
    3b23:	je     3b3b <botlish_fn_24+0x183>
    3b29:	mov    rdx,r15
    3b2c:	add    rdx,0x2
    3b30:	seto   al
    3b33:	test   al,al
    3b35:	je     3b4e <botlish_fn_24+0x196>
    3b3b:	mov    edx,0x3
    3b40:	mov    rsi,r15
    3b43:	mov    rdi,r12
    3b46:	call   3b4b <botlish_fn_24+0x193>
			3b47: R_X86_64_PLT32	rt_int_add-0x4
    3b4b:	mov    rdx,rax
    3b4e:	mov    QWORD PTR [rsp],rdx
    3b52:	mov    r15,rdx
    3b55:	mov    rcx,r13
    3b58:	mov    rdx,r14
    3b5b:	mov    rsi,r15
    3b5e:	mov    rdi,r12
    3b61:	call   3b66 <botlish_fn_24+0x1ae>
			3b62: R_X86_64_PLT32	botlish_fn_23-0x4 ; tld_ok<generic>
    3b66:	test   rax,rax
    3b69:	jne    3b94 <botlish_fn_24+0x1dc>
    3b6f:	xor    rax,rax
    3b72:	mov    rbx,QWORD PTR [rsp+0x40]
    3b77:	mov    r12,QWORD PTR [rsp+0x48]
    3b7c:	mov    r13,QWORD PTR [rsp+0x50]
    3b81:	mov    r14,QWORD PTR [rsp+0x58]
    3b86:	mov    r15,QWORD PTR [rsp+0x60]
    3b8b:	add    rsp,0x70
    3b8f:	mov    rsp,rbp
    3b92:	pop    rbp
    3b93:	ret
    3b94:	cmp    rax,0x6
    3b98:	je     3bbd <botlish_fn_24+0x205>
    3b9e:	mov    QWORD PTR [rsp],r15
    3ba2:	mov    QWORD PTR [rsp+0x8],r14
    3ba7:	mov    QWORD PTR [rsp+0x10],r13
    3bac:	mov    QWORD PTR [rsp+0x30],r15
    3bb1:	jmp    3a03 <botlish_fn_24+0x4b>
    3bb6:	mov    r14,0xffffffffffffffff
    3bbd:	mov    rax,r14
    3bc0:	jmp    3bcc <botlish_fn_24+0x214>
    3bc5:	mov    rax,0xffffffffffffffff
    3bcc:	mov    rbx,QWORD PTR [rsp+0x40]
    3bd1:	mov    r12,QWORD PTR [rsp+0x48]
    3bd6:	mov    r13,QWORD PTR [rsp+0x50]
    3bdb:	mov    r14,QWORD PTR [rsp+0x58]
    3be0:	mov    r15,QWORD PTR [rsp+0x60]
    3be5:	add    rsp,0x70
    3be9:	mov    rsp,rbp
    3bec:	pop    rbp
    3bed:	ret
    3bee:	add    BYTE PTR [rax],al
    3bf0:	(bad)
    3bf1:	add    BYTE PTR [rax],al
    3bf3:	add    BYTE PTR [rax],al
    3bf5:	add    BYTE PTR [rax],al
	...

0000000000003bf8 <botlish_entry_24: domain_loop<generic>>:
    3bf8:	push   rbp
    3bf9:	mov    rbp,rsp
    3bfc:	mov    rsi,QWORD PTR [rdx]
    3bff:	mov    r8,QWORD PTR [rdx+0x8]
    3c03:	mov    rcx,QWORD PTR [rdx+0x10]
    3c07:	mov    rdx,r8
    3c0a:	call   3c0f <botlish_entry_24+0x17>
			3c0b: R_X86_64_PLT32	botlish_fn_24-0x4 ; domain_loop<generic>
    3c0f:	mov    rsp,rbp
    3c12:	pop    rbp
    3c13:	ret

; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 24327  (per function: 1183 478 1713 1425 687 1084 697 1140 624 1449 1417 427 456 401 165 617 617 625 681 793 1449 1417 427 456 401 165 617 617 625 681 793)
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
       4:	sub    rsp,0x180
       b:	mov    QWORD PTR [rsp+0x150],rbx
      13:	mov    QWORD PTR [rsp+0x158],r12
      1b:	mov    QWORD PTR [rsp+0x160],r13
      23:	mov    QWORD PTR [rsp+0x168],r14
      2b:	mov    QWORD PTR [rsp+0x170],r15
      33:	mov    r8,QWORD PTR [rdi]
      36:	mov    rdx,QWORD PTR [rdi+0x8]
      3a:	lea    rsi,[r8+0x8]
      3e:	cmp    rsi,rdx
      41:	ja     430 <botlish_fn_0+0x430>
      47:	lea    rsi,[r8+0x8]
      4b:	mov    QWORD PTR [rdi],rsi
      4e:	mov    QWORD PTR [r8],0x0
      55:	mov    QWORD PTR [rsp+0x140],r8
      5d:	mov    r8,QWORD PTR [rdi+0x10]
      61:	mov    r9,QWORD PTR [r8]
      64:	mov    QWORD PTR [rsp],r9
      68:	mov    QWORD PTR [rsp+0x138],r9
      70:	mov    r8,QWORD PTR [rdi+0x10]
      74:	mov    r10,QWORD PTR [r8+0x8]
      78:	mov    QWORD PTR [rsp+0x8],r10
      7d:	mov    QWORD PTR [rsp+0x130],r10
      85:	mov    r9,QWORD PTR [rdi+0x10]
      89:	mov    r11,QWORD PTR [r9+0x10]
      8d:	mov    QWORD PTR [rsp+0x10],r11
      92:	mov    QWORD PTR [rsp+0x128],r11
      9a:	mov    r10,QWORD PTR [rdi+0x10]
      9e:	mov    rcx,QWORD PTR [r10+0x18]
      a2:	mov    QWORD PTR [rsp+0x18],rcx
      a7:	mov    QWORD PTR [rsp+0x120],rcx
      af:	mov    rax,QWORD PTR [rdi+0x10]
      b3:	mov    rcx,QWORD PTR [rax+0x20]
      b7:	mov    QWORD PTR [rsp+0x20],rcx
      bc:	mov    rax,QWORD PTR [rdi+0x10]
      c0:	mov    r10,QWORD PTR [rax+0x28]
      c4:	mov    QWORD PTR [rsp+0x28],r10
      c9:	mov    rax,QWORD PTR [rdi+0x10]
      cd:	mov    rsi,QWORD PTR [rax+0x30]
      d1:	mov    QWORD PTR [rsp+0x30],rsi
      d6:	mov    rax,QWORD PTR [rdi+0x10]
      da:	mov    r14,QWORD PTR [rax+0x38]
      de:	mov    QWORD PTR [rsp+0x38],r14
      e3:	mov    rax,QWORD PTR [rdi+0x10]
      e7:	mov    r15,QWORD PTR [rax+0x40]
      eb:	mov    QWORD PTR [rsp+0x40],r15
      f0:	mov    rax,QWORD PTR [rdi+0x10]
      f4:	mov    rbx,QWORD PTR [rax+0x48]
      f8:	mov    QWORD PTR [rsp+0x48],rbx
      fd:	mov    rax,QWORD PTR [rdi+0x10]
     101:	mov    r12,QWORD PTR [rax+0x50]
     105:	mov    QWORD PTR [rsp+0x50],r12
     10a:	mov    rax,QWORD PTR [rdi+0x10]
     10e:	mov    r13,QWORD PTR [rax+0x58]
     112:	mov    QWORD PTR [rsp+0x58],r13
     117:	mov    rax,QWORD PTR [rdi+0x10]
     11b:	mov    rax,QWORD PTR [rax+0x60]
     11f:	mov    QWORD PTR [rsp+0x60],rax
     124:	mov    rdx,QWORD PTR [rdi+0x10]
     128:	mov    r8,QWORD PTR [rdx+0x68]
     12c:	mov    QWORD PTR [rsp+0x68],r8
     131:	mov    rdx,QWORD PTR [rdi+0x10]
     135:	mov    r9,QWORD PTR [rdx+0x70]
     139:	mov    QWORD PTR [rsp+0x70],r9
     13e:	mov    rdx,QWORD PTR [rdi+0x10]
     142:	mov    QWORD PTR [rsp+0x118],rdi
     14a:	mov    rdi,QWORD PTR [rdx+0x78]
     14e:	mov    QWORD PTR [rsp+0x78],rdi
     153:	lea    rdx,[rsp+0x80]
     15b:	mov    r11,QWORD PTR [rsp+0x138]
     163:	mov    QWORD PTR [rsp+0x80],r11
     16b:	mov    r11,QWORD PTR [rsp+0x130]
     173:	mov    QWORD PTR [rsp+0x88],r11
     17b:	mov    r11,QWORD PTR [rsp+0x128]
     183:	mov    QWORD PTR [rsp+0x90],r11
     18b:	mov    r11,QWORD PTR [rsp+0x120]
     193:	mov    QWORD PTR [rsp+0x98],r11
     19b:	mov    QWORD PTR [rsp+0xa0],rcx
     1a3:	mov    QWORD PTR [rsp+0xa8],r10
     1ab:	mov    QWORD PTR [rsp+0xb0],rsi
     1b3:	mov    QWORD PTR [rsp+0xb8],r14
     1bb:	mov    QWORD PTR [rsp+0xc0],r15
     1c3:	mov    QWORD PTR [rsp+0xc8],rbx
     1cb:	mov    QWORD PTR [rsp+0xd0],r12
     1d3:	mov    QWORD PTR [rsp+0xd8],r13
     1db:	mov    QWORD PTR [rsp+0xe0],rax
     1e3:	mov    QWORD PTR [rsp+0xe8],r8
     1eb:	mov    QWORD PTR [rsp+0xf0],r9
     1f3:	mov    QWORD PTR [rsp+0xf8],rdi
     1fb:	mov    esi,0x10
     200:	mov    rdi,QWORD PTR [rsp+0x118]
     208:	call   20d <botlish_fn_0+0x20d>
			209: R_X86_64_PLT32	rt_list_new-0x4
     20d:	test   rax,rax
     210:	jne    22b <botlish_fn_0+0x22b>
     216:	mov    rdi,QWORD PTR [rsp+0x118]
     21e:	mov    r8,QWORD PTR [rsp+0x140]
     226:	jmp    3a7 <botlish_fn_0+0x3a7>
     22b:	mov    QWORD PTR [rsp],rax
     22f:	lea    r8,[rsp+0x100]
     237:	mov    QWORD PTR [rsp+0x100],rax
     23f:	mov    ecx,0x1
     244:	mov    rdx,QWORD PTR [rip+0x0]        # 24b <botlish_fn_0+0x24b>
			247: R_X86_64_GOTPCREL	botlish_entry_1-0x4 ; web::uri_escape_text<generic>
     24b:	mov    rdi,QWORD PTR [rsp+0x118]
     253:	mov    rsi,rcx
     256:	call   25b <botlish_fn_0+0x25b>
			257: R_X86_64_PLT32	rt_closure_new-0x4
     25b:	mov    QWORD PTR [rsp],rax
     25f:	mov    rdi,QWORD PTR [rsp+0x118]
     267:	mov    rcx,QWORD PTR [rdi+0x10]
     26b:	mov    rdx,QWORD PTR [rcx+0x80]
     272:	mov    QWORD PTR [rsp+0x8],rdx
     277:	mov    rsi,rax
     27a:	call   27f <botlish_fn_0+0x27f>
			27b: R_X86_64_PLT32	botlish_fn_1-0x4 ; web::uri_escape_text<generic>
     27f:	test   rax,rax
     282:	jne    29d <botlish_fn_0+0x29d>
     288:	mov    rdi,QWORD PTR [rsp+0x118]
     290:	mov    r8,QWORD PTR [rsp+0x140]
     298:	jmp    3a7 <botlish_fn_0+0x3a7>
     29d:	mov    QWORD PTR [rsp],rax
     2a1:	mov    r12,rax
     2a4:	mov    esi,0x321
     2a9:	mov    QWORD PTR [rsp+0x8],0x321
     2b2:	mov    edx,0x1
     2b7:	mov    QWORD PTR [rsp+0x10],0x1
     2c0:	mov    rdi,QWORD PTR [rsp+0x118]
     2c8:	mov    rcx,QWORD PTR [rdi+0x10]
     2cc:	mov    rcx,QWORD PTR [rcx+0x88]
     2d3:	mov    QWORD PTR [rsp+0x18],rcx
     2d8:	mov    r8,r12
     2db:	call   2e0 <botlish_fn_0+0x2e0>
			2dc: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
     2e0:	mov    rbx,rax
     2e3:	test   rbx,rbx
     2e6:	jne    301 <botlish_fn_0+0x301>
     2ec:	mov    rdi,QWORD PTR [rsp+0x118]
     2f4:	mov    r8,QWORD PTR [rsp+0x140]
     2fc:	jmp    3a7 <botlish_fn_0+0x3a7>
     301:	mov    QWORD PTR [rsp+0x8],rbx
     306:	mov    esi,0x321
     30b:	mov    QWORD PTR [rsp+0x10],0x321
     314:	mov    edx,0x1
     319:	mov    QWORD PTR [rsp+0x18],0x1
     322:	mov    rdi,QWORD PTR [rsp+0x118]
     32a:	mov    rax,QWORD PTR [rdi+0x10]
     32e:	mov    rcx,QWORD PTR [rax+0x90]
     335:	mov    QWORD PTR [rsp+0x20],rcx
     33a:	mov    r8,r12
     33d:	call   342 <botlish_fn_0+0x342>
			33e: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
     342:	test   rax,rax
     345:	jne    360 <botlish_fn_0+0x360>
     34b:	mov    rdi,QWORD PTR [rsp+0x118]
     353:	mov    r8,QWORD PTR [rsp+0x140]
     35b:	jmp    3a7 <botlish_fn_0+0x3a7>
     360:	mov    QWORD PTR [rsp],rax
     364:	lea    rdx,[rsp+0x108]
     36c:	mov    QWORD PTR [rsp+0x108],rbx
     374:	mov    QWORD PTR [rsp+0x110],rax
     37c:	mov    esi,0x2
     381:	mov    rdi,QWORD PTR [rsp+0x118]
     389:	call   38e <botlish_fn_0+0x38e>
			38a: R_X86_64_PLT32	rt_list_new-0x4
     38e:	test   rax,rax
     391:	jne    3e9 <botlish_fn_0+0x3e9>
     397:	mov    rdi,QWORD PTR [rsp+0x118]
     39f:	mov    r8,QWORD PTR [rsp+0x140]
     3a7:	mov    rdi,QWORD PTR [rsp+0x118]
     3af:	mov    QWORD PTR [rdi],r8
     3b2:	xor    rax,rax
     3b5:	mov    rbx,QWORD PTR [rsp+0x150]
     3bd:	mov    r12,QWORD PTR [rsp+0x158]
     3c5:	mov    r13,QWORD PTR [rsp+0x160]
     3cd:	mov    r14,QWORD PTR [rsp+0x168]
     3d5:	mov    r15,QWORD PTR [rsp+0x170]
     3dd:	add    rsp,0x180
     3e4:	mov    rsp,rbp
     3e7:	pop    rbp
     3e8:	ret
     3e9:	mov    rdi,QWORD PTR [rsp+0x118]
     3f1:	mov    r8,QWORD PTR [rsp+0x140]
     3f9:	mov    QWORD PTR [rdi],r8
     3fc:	mov    rbx,QWORD PTR [rsp+0x150]
     404:	mov    r12,QWORD PTR [rsp+0x158]
     40c:	mov    r13,QWORD PTR [rsp+0x160]
     414:	mov    r14,QWORD PTR [rsp+0x168]
     41c:	mov    r15,QWORD PTR [rsp+0x170]
     424:	add    rsp,0x180
     42b:	mov    rsp,rbp
     42e:	pop    rbp
     42f:	ret
     430:	mov    QWORD PTR [rsp+0x118],rdi
     438:	call   43d <botlish_fn_0+0x43d>
			439: R_X86_64_PLT32	rt_stack_overflow-0x4
     43d:	xor    rax,rax
     440:	mov    rbx,QWORD PTR [rsp+0x150]
     448:	mov    r12,QWORD PTR [rsp+0x158]
     450:	mov    r13,QWORD PTR [rsp+0x160]
     458:	mov    r14,QWORD PTR [rsp+0x168]
     460:	mov    r15,QWORD PTR [rsp+0x170]
     468:	add    rsp,0x180
     46f:	mov    rsp,rbp
     472:	pop    rbp
     473:	ret

0000000000000474 <botlish_entry_0: <program entry>>:
     474:	push   rbp
     475:	mov    rbp,rsp
     478:	call   47d <botlish_entry_0+0x9>
			479: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     47d:	mov    rsp,rbp
     480:	pop    rbp
     481:	ret

0000000000000482 <botlish_fn_1: web::uri_escape_text<generic>>:
     482:	push   rbp
     483:	mov    rbp,rsp
     486:	sub    rsp,0x60
     48a:	mov    QWORD PTR [rsp+0x40],rbx
     48f:	mov    QWORD PTR [rsp+0x48],r12
     494:	mov    QWORD PTR [rsp+0x50],r13
     499:	mov    QWORD PTR [rsp+0x58],r14
     49e:	mov    r12,QWORD PTR [rdi]
     4a1:	mov    rax,QWORD PTR [rdi+0x8]
     4a5:	lea    rcx,[r12+0x8]
     4aa:	cmp    rcx,rax
     4ad:	ja     604 <botlish_fn_1+0x182>
     4b3:	lea    rax,[r12+0x8]
     4b8:	mov    QWORD PTR [rdi],rax
     4bb:	mov    r13,rdi
     4be:	mov    QWORD PTR [r12],0x0
     4c6:	mov    QWORD PTR [rsp+0x10],0x0
     4cf:	mov    QWORD PTR [rsp+0x18],0x0
     4d8:	mov    QWORD PTR [rsp],rdx
     4dc:	mov    r14,rdx
     4df:	mov    rax,QWORD PTR [rsi+0x20]
     4e3:	mov    rax,QWORD PTR [rax]
     4e6:	mov    QWORD PTR [rsp+0x8],rax
     4eb:	lea    r8,[rsp+0x20]
     4f0:	mov    QWORD PTR [rsp+0x20],rax
     4f5:	mov    esi,0x4
     4fa:	mov    rdx,QWORD PTR [rip+0x0]        # 501 <botlish_fn_1+0x7f>
			4fd: R_X86_64_GOTPCREL	botlish_entry_4-0x4 ; hex_pair<generic>
     501:	mov    ebx,0x1
     506:	mov    rcx,rbx
     509:	mov    rdi,r13
     50c:	call   511 <botlish_fn_1+0x8f>
			50d: R_X86_64_PLT32	rt_closure_new-0x4
     511:	mov    QWORD PTR [rsp+0x8],rax
     516:	lea    r8,[rsp+0x28]
     51b:	mov    QWORD PTR [rsp+0x28],rax
     520:	mov    esi,0x5
     525:	mov    rdx,QWORD PTR [rip+0x0]        # 52c <botlish_fn_1+0xaa>
			528: R_X86_64_GOTPCREL	botlish_entry_5-0x4 ; esc_bytes<generic>
     52c:	mov    rcx,rbx
     52f:	mov    rdi,r13
     532:	call   537 <botlish_fn_1+0xb5>
			533: R_X86_64_PLT32	rt_closure_new-0x4
     537:	mov    QWORD PTR [rsp+0x8],rax
     53c:	lea    r8,[rsp+0x30]
     541:	mov    QWORD PTR [rsp+0x30],rax
     546:	mov    esi,0x6
     54b:	mov    rdx,QWORD PTR [rip+0x0]        # 552 <botlish_fn_1+0xd0>
			54e: R_X86_64_GOTPCREL	botlish_entry_6-0x4 ; esc_char<generic>
     552:	mov    rcx,rbx
     555:	mov    rdi,r13
     558:	call   55d <botlish_fn_1+0xdb>
			559: R_X86_64_PLT32	rt_closure_new-0x4
     55d:	mov    QWORD PTR [rsp+0x8],rax
     562:	lea    r8,[rsp+0x38]
     567:	mov    QWORD PTR [rsp+0x38],rax
     56c:	mov    esi,0x7
     571:	mov    rdx,QWORD PTR [rip+0x0]        # 578 <botlish_fn_1+0xf6>
			574: R_X86_64_GOTPCREL	botlish_entry_7-0x4 ; esc_from<generic>
     578:	mov    rcx,rbx
     57b:	mov    rdi,r13
     57e:	call   583 <botlish_fn_1+0x101>
			57f: R_X86_64_PLT32	rt_closure_new-0x4
     583:	mov    QWORD PTR [rsp+0x8],rax
     588:	mov    QWORD PTR [rsp+0x10],0x1
     591:	mov    rdi,r13
     594:	mov    rcx,QWORD PTR [rdi+0x10]
     598:	mov    r8,QWORD PTR [rcx+0x98]
     59f:	mov    QWORD PTR [rsp+0x18],r8
     5a4:	mov    rcx,rbx
     5a7:	mov    rdx,r14
     5aa:	mov    rsi,rax
     5ad:	call   5b2 <botlish_fn_1+0x130>
			5ae: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
     5b2:	test   rax,rax
     5b5:	jne    5e1 <botlish_fn_1+0x15f>
     5bb:	mov    rdi,r13
     5be:	mov    QWORD PTR [rdi],r12
     5c1:	xor    rax,rax
     5c4:	mov    rbx,QWORD PTR [rsp+0x40]
     5c9:	mov    r12,QWORD PTR [rsp+0x48]
     5ce:	mov    r13,QWORD PTR [rsp+0x50]
     5d3:	mov    r14,QWORD PTR [rsp+0x58]
     5d8:	add    rsp,0x60
     5dc:	mov    rsp,rbp
     5df:	pop    rbp
     5e0:	ret
     5e1:	mov    rdi,r13
     5e4:	mov    QWORD PTR [rdi],r12
     5e7:	mov    rbx,QWORD PTR [rsp+0x40]
     5ec:	mov    r12,QWORD PTR [rsp+0x48]
     5f1:	mov    r13,QWORD PTR [rsp+0x50]
     5f6:	mov    r14,QWORD PTR [rsp+0x58]
     5fb:	add    rsp,0x60
     5ff:	mov    rsp,rbp
     602:	pop    rbp
     603:	ret
     604:	mov    r13,rdi
     607:	call   60c <botlish_fn_1+0x18a>
			608: R_X86_64_PLT32	rt_stack_overflow-0x4
     60c:	xor    rax,rax
     60f:	mov    rbx,QWORD PTR [rsp+0x40]
     614:	mov    r12,QWORD PTR [rsp+0x48]
     619:	mov    r13,QWORD PTR [rsp+0x50]
     61e:	mov    r14,QWORD PTR [rsp+0x58]
     623:	add    rsp,0x60
     627:	mov    rsp,rbp
     62a:	pop    rbp
     62b:	ret

000000000000062c <botlish_entry_1: web::uri_escape_text<generic>>:
     62c:	push   rbp
     62d:	mov    rbp,rsp
     630:	mov    rdx,QWORD PTR [rdx]
     633:	call   638 <botlish_entry_1+0xc>
			634: R_X86_64_PLT32	botlish_fn_1-0x4 ; web::uri_escape_text<generic>
     638:	mov    rsp,rbp
     63b:	pop    rbp
     63c:	ret
     63d:	add    BYTE PTR [rax],al
	...

0000000000000640 <botlish_fn_2: high_nibble<generic>>:
     640:	push   rbp
     641:	mov    rbp,rsp
     644:	sub    rsp,0x10
     648:	mov    QWORD PTR [rsp],rbx
     64c:	mov    QWORD PTR [rsp+0x8],r12
     651:	mov    r8d,0x1
     657:	test   rsi,0x1
     65e:	jne    67e <botlish_fn_2+0x3e>
     664:	xor    r8d,r8d
     667:	test   rsi,0x7
     66e:	jne    67e <botlish_fn_2+0x3e>
     674:	movzx  rax,BYTE PTR [rsi]
     678:	cmp    al,0x1
     67a:	sete   r8b
     67e:	test   r8b,r8b
     681:	jne    6b2 <botlish_fn_2+0x72>
     687:	mov    rax,QWORD PTR [rdi+0x10]
     68b:	mov    rcx,QWORD PTR [rax+0xa0]
     692:	xor    rbx,rbx
     695:	mov    rdx,rbx
     698:	call   69d <botlish_fn_2+0x5d>
			699: R_X86_64_PLT32	rt_type_error-0x4
     69d:	mov    rax,rbx
     6a0:	mov    rbx,QWORD PTR [rsp]
     6a4:	mov    r12,QWORD PTR [rsp+0x8]
     6a9:	add    rsp,0x10
     6ad:	mov    rsp,rbp
     6b0:	pop    rbp
     6b1:	ret
     6b2:	mov    r12,rdi
     6b5:	test   rsi,0x1
     6bc:	mov    rbx,rsi
     6bf:	jne    6ea <botlish_fn_2+0xaa>
     6c5:	mov    edx,0x1f
     6ca:	mov    rsi,rbx
     6cd:	mov    rdi,r12
     6d0:	call   6d5 <botlish_fn_2+0x95>
			6d1: R_X86_64_PLT32	rt_int_cmp-0x4
     6d5:	mov    ecx,0x2
     6da:	test   rax,rax
     6dd:	cmovle rcx,QWORD PTR [rip+0x583]        # c68 <botlish_fn_2+0x628>
     6e5:	jmp    6fe <botlish_fn_2+0xbe>
     6ea:	mov    ecx,0x2
     6ef:	mov    rsi,rbx
     6f2:	cmp    rsi,0x1f
     6f6:	cmovle rcx,QWORD PTR [rip+0x56a]        # c68 <botlish_fn_2+0x628>
     6fe:	cmp    rcx,0x6
     702:	je     c4b <botlish_fn_2+0x60b>
     708:	mov    rsi,rbx
     70b:	test   rsi,0x1
     712:	jne    73d <botlish_fn_2+0xfd>
     718:	mov    edx,0x3f
     71d:	mov    rsi,rbx
     720:	mov    rdi,r12
     723:	call   728 <botlish_fn_2+0xe8>
			724: R_X86_64_PLT32	rt_int_cmp-0x4
     728:	mov    ecx,0x2
     72d:	test   rax,rax
     730:	cmovle rcx,QWORD PTR [rip+0x530]        # c68 <botlish_fn_2+0x628>
     738:	jmp    751 <botlish_fn_2+0x111>
     73d:	mov    ecx,0x2
     742:	mov    rsi,rbx
     745:	cmp    rsi,0x3f
     749:	cmovle rcx,QWORD PTR [rip+0x517]        # c68 <botlish_fn_2+0x628>
     751:	cmp    rcx,0x6
     755:	je     c41 <botlish_fn_2+0x601>
     75b:	mov    rsi,rbx
     75e:	test   rsi,0x1
     765:	jne    790 <botlish_fn_2+0x150>
     76b:	mov    edx,0x5f
     770:	mov    rsi,rbx
     773:	mov    rdi,r12
     776:	call   77b <botlish_fn_2+0x13b>
			777: R_X86_64_PLT32	rt_int_cmp-0x4
     77b:	mov    ecx,0x2
     780:	test   rax,rax
     783:	cmovle rcx,QWORD PTR [rip+0x4dd]        # c68 <botlish_fn_2+0x628>
     78b:	jmp    7a4 <botlish_fn_2+0x164>
     790:	mov    ecx,0x2
     795:	mov    rsi,rbx
     798:	cmp    rsi,0x5f
     79c:	cmovle rcx,QWORD PTR [rip+0x4c4]        # c68 <botlish_fn_2+0x628>
     7a4:	cmp    rcx,0x6
     7a8:	je     c37 <botlish_fn_2+0x5f7>
     7ae:	mov    rsi,rbx
     7b1:	test   rsi,0x1
     7b8:	jne    7e3 <botlish_fn_2+0x1a3>
     7be:	mov    edx,0x7f
     7c3:	mov    rsi,rbx
     7c6:	mov    rdi,r12
     7c9:	call   7ce <botlish_fn_2+0x18e>
			7ca: R_X86_64_PLT32	rt_int_cmp-0x4
     7ce:	mov    ecx,0x2
     7d3:	test   rax,rax
     7d6:	cmovle rcx,QWORD PTR [rip+0x48a]        # c68 <botlish_fn_2+0x628>
     7de:	jmp    7f7 <botlish_fn_2+0x1b7>
     7e3:	mov    ecx,0x2
     7e8:	mov    rsi,rbx
     7eb:	cmp    rsi,0x7f
     7ef:	cmovle rcx,QWORD PTR [rip+0x471]        # c68 <botlish_fn_2+0x628>
     7f7:	cmp    rcx,0x6
     7fb:	je     c2d <botlish_fn_2+0x5ed>
     801:	mov    rsi,rbx
     804:	test   rsi,0x1
     80b:	jne    836 <botlish_fn_2+0x1f6>
     811:	mov    edx,0x9f
     816:	mov    rsi,rbx
     819:	mov    rdi,r12
     81c:	call   821 <botlish_fn_2+0x1e1>
			81d: R_X86_64_PLT32	rt_int_cmp-0x4
     821:	mov    ecx,0x2
     826:	test   rax,rax
     829:	cmovle rcx,QWORD PTR [rip+0x437]        # c68 <botlish_fn_2+0x628>
     831:	jmp    84d <botlish_fn_2+0x20d>
     836:	mov    ecx,0x2
     83b:	mov    rsi,rbx
     83e:	cmp    rsi,0x9f
     845:	cmovle rcx,QWORD PTR [rip+0x41b]        # c68 <botlish_fn_2+0x628>
     84d:	cmp    rcx,0x6
     851:	je     c23 <botlish_fn_2+0x5e3>
     857:	mov    rsi,rbx
     85a:	test   rsi,0x1
     861:	jne    88c <botlish_fn_2+0x24c>
     867:	mov    edx,0xbf
     86c:	mov    rsi,rbx
     86f:	mov    rdi,r12
     872:	call   877 <botlish_fn_2+0x237>
			873: R_X86_64_PLT32	rt_int_cmp-0x4
     877:	mov    ecx,0x2
     87c:	test   rax,rax
     87f:	cmovle rcx,QWORD PTR [rip+0x3e1]        # c68 <botlish_fn_2+0x628>
     887:	jmp    8a3 <botlish_fn_2+0x263>
     88c:	mov    ecx,0x2
     891:	mov    rsi,rbx
     894:	cmp    rsi,0xbf
     89b:	cmovle rcx,QWORD PTR [rip+0x3c5]        # c68 <botlish_fn_2+0x628>
     8a3:	cmp    rcx,0x6
     8a7:	je     c19 <botlish_fn_2+0x5d9>
     8ad:	mov    rsi,rbx
     8b0:	test   rsi,0x1
     8b7:	jne    8e2 <botlish_fn_2+0x2a2>
     8bd:	mov    edx,0xdf
     8c2:	mov    rsi,rbx
     8c5:	mov    rdi,r12
     8c8:	call   8cd <botlish_fn_2+0x28d>
			8c9: R_X86_64_PLT32	rt_int_cmp-0x4
     8cd:	mov    ecx,0x2
     8d2:	test   rax,rax
     8d5:	cmovle rcx,QWORD PTR [rip+0x38b]        # c68 <botlish_fn_2+0x628>
     8dd:	jmp    8f9 <botlish_fn_2+0x2b9>
     8e2:	mov    ecx,0x2
     8e7:	mov    rsi,rbx
     8ea:	cmp    rsi,0xdf
     8f1:	cmovle rcx,QWORD PTR [rip+0x36f]        # c68 <botlish_fn_2+0x628>
     8f9:	cmp    rcx,0x6
     8fd:	je     c0f <botlish_fn_2+0x5cf>
     903:	mov    rsi,rbx
     906:	test   rsi,0x1
     90d:	jne    939 <botlish_fn_2+0x2f9>
     913:	mov    edx,0xff
     918:	mov    rsi,rbx
     91b:	mov    rdi,r12
     91e:	call   923 <botlish_fn_2+0x2e3>
			91f: R_X86_64_PLT32	rt_int_cmp-0x4
     923:	mov    r10d,0x2
     929:	test   rax,rax
     92c:	cmovle r10,QWORD PTR [rip+0x334]        # c68 <botlish_fn_2+0x628>
     934:	jmp    951 <botlish_fn_2+0x311>
     939:	mov    r10d,0x2
     93f:	mov    rsi,rbx
     942:	cmp    rsi,0xff
     949:	cmovle r10,QWORD PTR [rip+0x317]        # c68 <botlish_fn_2+0x628>
     951:	cmp    r10,0x6
     955:	je     c05 <botlish_fn_2+0x5c5>
     95b:	mov    rsi,rbx
     95e:	test   rsi,0x1
     965:	jne    990 <botlish_fn_2+0x350>
     96b:	mov    edx,0x11f
     970:	mov    rsi,rbx
     973:	mov    rdi,r12
     976:	call   97b <botlish_fn_2+0x33b>
			977: R_X86_64_PLT32	rt_int_cmp-0x4
     97b:	mov    ecx,0x2
     980:	test   rax,rax
     983:	cmovle rcx,QWORD PTR [rip+0x2dd]        # c68 <botlish_fn_2+0x628>
     98b:	jmp    9a7 <botlish_fn_2+0x367>
     990:	mov    ecx,0x2
     995:	mov    rsi,rbx
     998:	cmp    rsi,0x11f
     99f:	cmovle rcx,QWORD PTR [rip+0x2c1]        # c68 <botlish_fn_2+0x628>
     9a7:	cmp    rcx,0x6
     9ab:	je     bfb <botlish_fn_2+0x5bb>
     9b1:	mov    rsi,rbx
     9b4:	test   rsi,0x1
     9bb:	jne    9e6 <botlish_fn_2+0x3a6>
     9c1:	mov    edx,0x13f
     9c6:	mov    rsi,rbx
     9c9:	mov    rdi,r12
     9cc:	call   9d1 <botlish_fn_2+0x391>
			9cd: R_X86_64_PLT32	rt_int_cmp-0x4
     9d1:	mov    ecx,0x2
     9d6:	test   rax,rax
     9d9:	cmovle rcx,QWORD PTR [rip+0x287]        # c68 <botlish_fn_2+0x628>
     9e1:	jmp    9fd <botlish_fn_2+0x3bd>
     9e6:	mov    ecx,0x2
     9eb:	mov    rsi,rbx
     9ee:	cmp    rsi,0x13f
     9f5:	cmovle rcx,QWORD PTR [rip+0x26b]        # c68 <botlish_fn_2+0x628>
     9fd:	cmp    rcx,0x6
     a01:	je     bf1 <botlish_fn_2+0x5b1>
     a07:	mov    rsi,rbx
     a0a:	test   rsi,0x1
     a11:	jne    a3c <botlish_fn_2+0x3fc>
     a17:	mov    edx,0x15f
     a1c:	mov    rsi,rbx
     a1f:	mov    rdi,r12
     a22:	call   a27 <botlish_fn_2+0x3e7>
			a23: R_X86_64_PLT32	rt_int_cmp-0x4
     a27:	mov    ecx,0x2
     a2c:	test   rax,rax
     a2f:	cmovle rcx,QWORD PTR [rip+0x231]        # c68 <botlish_fn_2+0x628>
     a37:	jmp    a53 <botlish_fn_2+0x413>
     a3c:	mov    ecx,0x2
     a41:	mov    rsi,rbx
     a44:	cmp    rsi,0x15f
     a4b:	cmovle rcx,QWORD PTR [rip+0x215]        # c68 <botlish_fn_2+0x628>
     a53:	cmp    rcx,0x6
     a57:	je     be7 <botlish_fn_2+0x5a7>
     a5d:	mov    rsi,rbx
     a60:	test   rsi,0x1
     a67:	jne    a92 <botlish_fn_2+0x452>
     a6d:	mov    edx,0x17f
     a72:	mov    rsi,rbx
     a75:	mov    rdi,r12
     a78:	call   a7d <botlish_fn_2+0x43d>
			a79: R_X86_64_PLT32	rt_int_cmp-0x4
     a7d:	mov    edi,0x2
     a82:	test   rax,rax
     a85:	cmovle rdi,QWORD PTR [rip+0x1db]        # c68 <botlish_fn_2+0x628>
     a8d:	jmp    aa9 <botlish_fn_2+0x469>
     a92:	mov    edi,0x2
     a97:	mov    rsi,rbx
     a9a:	cmp    rsi,0x17f
     aa1:	cmovle rdi,QWORD PTR [rip+0x1bf]        # c68 <botlish_fn_2+0x628>
     aa9:	cmp    rdi,0x6
     aad:	je     bdd <botlish_fn_2+0x59d>
     ab3:	mov    rsi,rbx
     ab6:	test   rsi,0x1
     abd:	jne    ae8 <botlish_fn_2+0x4a8>
     ac3:	mov    edx,0x19f
     ac8:	mov    rsi,rbx
     acb:	mov    rdi,r12
     ace:	call   ad3 <botlish_fn_2+0x493>
			acf: R_X86_64_PLT32	rt_int_cmp-0x4
     ad3:	mov    ecx,0x2
     ad8:	test   rax,rax
     adb:	cmovle rcx,QWORD PTR [rip+0x185]        # c68 <botlish_fn_2+0x628>
     ae3:	jmp    aff <botlish_fn_2+0x4bf>
     ae8:	mov    ecx,0x2
     aed:	mov    rsi,rbx
     af0:	cmp    rsi,0x19f
     af7:	cmovle rcx,QWORD PTR [rip+0x169]        # c68 <botlish_fn_2+0x628>
     aff:	cmp    rcx,0x6
     b03:	je     bd3 <botlish_fn_2+0x593>
     b09:	mov    rsi,rbx
     b0c:	test   rsi,0x1
     b13:	jne    b3e <botlish_fn_2+0x4fe>
     b19:	mov    edx,0x1bf
     b1e:	mov    rsi,rbx
     b21:	mov    rdi,r12
     b24:	call   b29 <botlish_fn_2+0x4e9>
			b25: R_X86_64_PLT32	rt_int_cmp-0x4
     b29:	mov    ecx,0x2
     b2e:	test   rax,rax
     b31:	cmovle rcx,QWORD PTR [rip+0x12f]        # c68 <botlish_fn_2+0x628>
     b39:	jmp    b55 <botlish_fn_2+0x515>
     b3e:	mov    ecx,0x2
     b43:	mov    rsi,rbx
     b46:	cmp    rsi,0x1bf
     b4d:	cmovle rcx,QWORD PTR [rip+0x113]        # c68 <botlish_fn_2+0x628>
     b55:	cmp    rcx,0x6
     b59:	je     bc9 <botlish_fn_2+0x589>
     b5f:	mov    rsi,rbx
     b62:	test   rsi,0x1
     b69:	jne    b94 <botlish_fn_2+0x554>
     b6f:	mov    edx,0x1df
     b74:	mov    rsi,rbx
     b77:	mov    rdi,r12
     b7a:	call   b7f <botlish_fn_2+0x53f>
			b7b: R_X86_64_PLT32	rt_int_cmp-0x4
     b7f:	mov    ecx,0x2
     b84:	test   rax,rax
     b87:	cmovle rcx,QWORD PTR [rip+0xd9]        # c68 <botlish_fn_2+0x628>
     b8f:	jmp    bab <botlish_fn_2+0x56b>
     b94:	mov    ecx,0x2
     b99:	mov    rsi,rbx
     b9c:	cmp    rsi,0x1df
     ba3:	cmovle rcx,QWORD PTR [rip+0xbd]        # c68 <botlish_fn_2+0x628>
     bab:	cmp    rcx,0x6
     baf:	je     bbf <botlish_fn_2+0x57f>
     bb5:	mov    eax,0x1f
     bba:	jmp    c50 <botlish_fn_2+0x610>
     bbf:	mov    eax,0x1d
     bc4:	jmp    c50 <botlish_fn_2+0x610>
     bc9:	mov    eax,0x1b
     bce:	jmp    c50 <botlish_fn_2+0x610>
     bd3:	mov    eax,0x19
     bd8:	jmp    c50 <botlish_fn_2+0x610>
     bdd:	mov    eax,0x17
     be2:	jmp    c50 <botlish_fn_2+0x610>
     be7:	mov    eax,0x15
     bec:	jmp    c50 <botlish_fn_2+0x610>
     bf1:	mov    eax,0x13
     bf6:	jmp    c50 <botlish_fn_2+0x610>
     bfb:	mov    eax,0x11
     c00:	jmp    c50 <botlish_fn_2+0x610>
     c05:	mov    eax,0xf
     c0a:	jmp    c50 <botlish_fn_2+0x610>
     c0f:	mov    eax,0xd
     c14:	jmp    c50 <botlish_fn_2+0x610>
     c19:	mov    eax,0xb
     c1e:	jmp    c50 <botlish_fn_2+0x610>
     c23:	mov    eax,0x9
     c28:	jmp    c50 <botlish_fn_2+0x610>
     c2d:	mov    eax,0x7
     c32:	jmp    c50 <botlish_fn_2+0x610>
     c37:	mov    eax,0x5
     c3c:	jmp    c50 <botlish_fn_2+0x610>
     c41:	mov    eax,0x3
     c46:	jmp    c50 <botlish_fn_2+0x610>
     c4b:	mov    eax,0x1
     c50:	mov    rbx,QWORD PTR [rsp]
     c54:	mov    r12,QWORD PTR [rsp+0x8]
     c59:	add    rsp,0x10
     c5d:	mov    rsp,rbp
     c60:	pop    rbp
     c61:	ret
     c62:	add    BYTE PTR [rax],al
     c64:	add    BYTE PTR [rax],al
     c66:	add    BYTE PTR [rax],al
     c68:	(bad)
     c69:	add    BYTE PTR [rax],al
     c6b:	add    BYTE PTR [rax],al
     c6d:	add    BYTE PTR [rax],al
	...

0000000000000c70 <botlish_entry_2: high_nibble<generic>>:
     c70:	push   rbp
     c71:	mov    rbp,rsp
     c74:	mov    rsi,QWORD PTR [rdx]
     c77:	call   c7c <botlish_entry_2+0xc>
			c78: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
     c7c:	mov    rsp,rbp
     c7f:	pop    rbp
     c80:	ret
     c81:	add    BYTE PTR [rax],al
     c83:	add    BYTE PTR [rax],al
     c85:	add    BYTE PTR [rax],al
	...

0000000000000c88 <botlish_fn_3: is_unreserved<generic>>:
     c88:	push   rbp
     c89:	mov    rbp,rsp
     c8c:	sub    rsp,0x20
     c90:	mov    QWORD PTR [rsp],rbx
     c94:	mov    QWORD PTR [rsp+0x8],r12
     c99:	mov    QWORD PTR [rsp+0x10],r13
     c9e:	mov    r8d,0x1
     ca4:	test   rsi,0x1
     cab:	jne    ccb <botlish_fn_3+0x43>
     cb1:	xor    r8d,r8d
     cb4:	test   rsi,0x7
     cbb:	jne    ccb <botlish_fn_3+0x43>
     cc1:	movzx  rax,BYTE PTR [rsi]
     cc5:	cmp    al,0x1
     cc7:	sete   r8b
     ccb:	test   r8b,r8b
     cce:	jne    d04 <botlish_fn_3+0x7c>
     cd4:	mov    rdx,QWORD PTR [rdi+0x10]
     cd8:	mov    rcx,QWORD PTR [rdx+0xa0]
     cdf:	xor    rbx,rbx
     ce2:	mov    rdx,rbx
     ce5:	call   cea <botlish_fn_3+0x62>
			ce6: R_X86_64_PLT32	rt_type_error-0x4
     cea:	mov    rax,rbx
     ced:	mov    rbx,QWORD PTR [rsp]
     cf1:	mov    r12,QWORD PTR [rsp+0x8]
     cf6:	mov    r13,QWORD PTR [rsp+0x10]
     cfb:	add    rsp,0x20
     cff:	mov    rsp,rbp
     d02:	pop    rbp
     d03:	ret
     d04:	mov    r12,rdi
     d07:	test   rsi,0x1
     d0e:	mov    rbx,rsi
     d11:	jne    d3c <botlish_fn_3+0xb4>
     d17:	mov    edx,0x59
     d1c:	mov    rsi,rbx
     d1f:	mov    rdi,r12
     d22:	call   d27 <botlish_fn_3+0x9f>
			d23: R_X86_64_PLT32	rt_int_cmp-0x4
     d27:	mov    ecx,0x2
     d2c:	test   rax,rax
     d2f:	cmovle rcx,QWORD PTR [rip+0x461]        # 1198 <botlish_fn_3+0x510>
     d37:	jmp    d50 <botlish_fn_3+0xc8>
     d3c:	mov    ecx,0x2
     d41:	mov    rsi,rbx
     d44:	cmp    rsi,0x59
     d48:	cmovle rcx,QWORD PTR [rip+0x448]        # 1198 <botlish_fn_3+0x510>
     d50:	mov    eax,0x6
     d55:	mov    r13,rax
     d58:	cmp    rcx,0x6
     d5c:	je     117b <botlish_fn_3+0x4f3>
     d62:	mov    rsi,rbx
     d65:	test   rsi,0x1
     d6c:	jne    d97 <botlish_fn_3+0x10f>
     d72:	mov    edx,0x5d
     d77:	mov    rsi,rbx
     d7a:	mov    rdi,r12
     d7d:	call   d82 <botlish_fn_3+0xfa>
			d7e: R_X86_64_PLT32	rt_int_cmp-0x4
     d82:	mov    ecx,0x2
     d87:	test   rax,rax
     d8a:	cmovle rcx,QWORD PTR [rip+0x406]        # 1198 <botlish_fn_3+0x510>
     d92:	jmp    dab <botlish_fn_3+0x123>
     d97:	mov    ecx,0x2
     d9c:	mov    rsi,rbx
     d9f:	cmp    rsi,0x5d
     da3:	cmovle rcx,QWORD PTR [rip+0x3ed]        # 1198 <botlish_fn_3+0x510>
     dab:	cmp    rcx,0x6
     daf:	je     1173 <botlish_fn_3+0x4eb>
     db5:	mov    rsi,rbx
     db8:	test   rsi,0x1
     dbf:	jne    dea <botlish_fn_3+0x162>
     dc5:	mov    edx,0x5f
     dca:	mov    rsi,rbx
     dcd:	mov    rdi,r12
     dd0:	call   dd5 <botlish_fn_3+0x14d>
			dd1: R_X86_64_PLT32	rt_int_cmp-0x4
     dd5:	mov    ecx,0x2
     dda:	test   rax,rax
     ddd:	cmovle rcx,QWORD PTR [rip+0x3b3]        # 1198 <botlish_fn_3+0x510>
     de5:	jmp    dfe <botlish_fn_3+0x176>
     dea:	mov    ecx,0x2
     def:	mov    rsi,rbx
     df2:	cmp    rsi,0x5f
     df6:	cmovle rcx,QWORD PTR [rip+0x39a]        # 1198 <botlish_fn_3+0x510>
     dfe:	cmp    rcx,0x6
     e02:	je     1169 <botlish_fn_3+0x4e1>
     e08:	mov    rsi,rbx
     e0b:	test   rsi,0x1
     e12:	jne    e3d <botlish_fn_3+0x1b5>
     e18:	mov    edx,0x73
     e1d:	mov    rsi,rbx
     e20:	mov    rdi,r12
     e23:	call   e28 <botlish_fn_3+0x1a0>
			e24: R_X86_64_PLT32	rt_int_cmp-0x4
     e28:	mov    ecx,0x2
     e2d:	test   rax,rax
     e30:	cmovle rcx,QWORD PTR [rip+0x360]        # 1198 <botlish_fn_3+0x510>
     e38:	jmp    e51 <botlish_fn_3+0x1c9>
     e3d:	mov    ecx,0x2
     e42:	mov    rsi,rbx
     e45:	cmp    rsi,0x73
     e49:	cmovle rcx,QWORD PTR [rip+0x347]        # 1198 <botlish_fn_3+0x510>
     e51:	cmp    rcx,0x6
     e55:	je     1161 <botlish_fn_3+0x4d9>
     e5b:	mov    rsi,rbx
     e5e:	test   rsi,0x1
     e65:	jne    e90 <botlish_fn_3+0x208>
     e6b:	mov    edx,0x81
     e70:	mov    rsi,rbx
     e73:	mov    rdi,r12
     e76:	call   e7b <botlish_fn_3+0x1f3>
			e77: R_X86_64_PLT32	rt_int_cmp-0x4
     e7b:	mov    ecx,0x2
     e80:	test   rax,rax
     e83:	cmovle rcx,QWORD PTR [rip+0x30d]        # 1198 <botlish_fn_3+0x510>
     e8b:	jmp    ea7 <botlish_fn_3+0x21f>
     e90:	mov    ecx,0x2
     e95:	mov    rsi,rbx
     e98:	cmp    rsi,0x81
     e9f:	cmovle rcx,QWORD PTR [rip+0x2f1]        # 1198 <botlish_fn_3+0x510>
     ea7:	cmp    rcx,0x6
     eab:	je     1157 <botlish_fn_3+0x4cf>
     eb1:	mov    rsi,rbx
     eb4:	test   rsi,0x1
     ebb:	jne    ee6 <botlish_fn_3+0x25e>
     ec1:	mov    edx,0xb5
     ec6:	mov    rsi,rbx
     ec9:	mov    rdi,r12
     ecc:	call   ed1 <botlish_fn_3+0x249>
			ecd: R_X86_64_PLT32	rt_int_cmp-0x4
     ed1:	mov    ecx,0x2
     ed6:	test   rax,rax
     ed9:	cmovle rcx,QWORD PTR [rip+0x2b7]        # 1198 <botlish_fn_3+0x510>
     ee1:	jmp    efd <botlish_fn_3+0x275>
     ee6:	mov    ecx,0x2
     eeb:	mov    rsi,rbx
     eee:	cmp    rsi,0xb5
     ef5:	cmovle rcx,QWORD PTR [rip+0x29b]        # 1198 <botlish_fn_3+0x510>
     efd:	cmp    rcx,0x6
     f01:	je     114f <botlish_fn_3+0x4c7>
     f07:	mov    rsi,rbx
     f0a:	test   rsi,0x1
     f11:	jne    f3c <botlish_fn_3+0x2b4>
     f17:	mov    edx,0xbd
     f1c:	mov    rsi,rbx
     f1f:	mov    rdi,r12
     f22:	call   f27 <botlish_fn_3+0x29f>
			f23: R_X86_64_PLT32	rt_int_cmp-0x4
     f27:	mov    ecx,0x2
     f2c:	test   rax,rax
     f2f:	cmovle rcx,QWORD PTR [rip+0x261]        # 1198 <botlish_fn_3+0x510>
     f37:	jmp    f53 <botlish_fn_3+0x2cb>
     f3c:	mov    ecx,0x2
     f41:	mov    rsi,rbx
     f44:	cmp    rsi,0xbd
     f4b:	cmovle rcx,QWORD PTR [rip+0x245]        # 1198 <botlish_fn_3+0x510>
     f53:	cmp    rcx,0x6
     f57:	je     1145 <botlish_fn_3+0x4bd>
     f5d:	mov    rsi,rbx
     f60:	test   rsi,0x1
     f67:	jne    f93 <botlish_fn_3+0x30b>
     f6d:	mov    edx,0xbf
     f72:	mov    rsi,rbx
     f75:	mov    rdi,r12
     f78:	call   f7d <botlish_fn_3+0x2f5>
			f79: R_X86_64_PLT32	rt_int_cmp-0x4
     f7d:	mov    r11d,0x2
     f83:	test   rax,rax
     f86:	cmovle r11,QWORD PTR [rip+0x20a]        # 1198 <botlish_fn_3+0x510>
     f8e:	jmp    fab <botlish_fn_3+0x323>
     f93:	mov    r11d,0x2
     f99:	mov    rsi,rbx
     f9c:	cmp    rsi,0xbf
     fa3:	cmovle r11,QWORD PTR [rip+0x1ed]        # 1198 <botlish_fn_3+0x510>
     fab:	cmp    r11,0x6
     faf:	je     113d <botlish_fn_3+0x4b5>
     fb5:	mov    rsi,rbx
     fb8:	test   rsi,0x1
     fbf:	jne    fea <botlish_fn_3+0x362>
     fc5:	mov    edx,0xc1
     fca:	mov    rsi,rbx
     fcd:	mov    rdi,r12
     fd0:	call   fd5 <botlish_fn_3+0x34d>
			fd1: R_X86_64_PLT32	rt_int_cmp-0x4
     fd5:	mov    ecx,0x2
     fda:	test   rax,rax
     fdd:	cmovle rcx,QWORD PTR [rip+0x1b3]        # 1198 <botlish_fn_3+0x510>
     fe5:	jmp    1001 <botlish_fn_3+0x379>
     fea:	mov    ecx,0x2
     fef:	mov    rsi,rbx
     ff2:	cmp    rsi,0xc1
     ff9:	cmovle rcx,QWORD PTR [rip+0x197]        # 1198 <botlish_fn_3+0x510>
    1001:	cmp    rcx,0x6
    1005:	je     1133 <botlish_fn_3+0x4ab>
    100b:	mov    rsi,rbx
    100e:	test   rsi,0x1
    1015:	jne    1040 <botlish_fn_3+0x3b8>
    101b:	mov    edx,0xf5
    1020:	mov    rsi,rbx
    1023:	mov    rdi,r12
    1026:	call   102b <botlish_fn_3+0x3a3>
			1027: R_X86_64_PLT32	rt_int_cmp-0x4
    102b:	mov    ecx,0x2
    1030:	test   rax,rax
    1033:	cmovle rcx,QWORD PTR [rip+0x15d]        # 1198 <botlish_fn_3+0x510>
    103b:	jmp    1057 <botlish_fn_3+0x3cf>
    1040:	mov    ecx,0x2
    1045:	mov    rsi,rbx
    1048:	cmp    rsi,0xf5
    104f:	cmovle rcx,QWORD PTR [rip+0x141]        # 1198 <botlish_fn_3+0x510>
    1057:	cmp    rcx,0x6
    105b:	je     112b <botlish_fn_3+0x4a3>
    1061:	mov    rsi,rbx
    1064:	test   rsi,0x1
    106b:	jne    1096 <botlish_fn_3+0x40e>
    1071:	mov    edx,0xfb
    1076:	mov    rsi,rbx
    1079:	mov    rdi,r12
    107c:	call   1081 <botlish_fn_3+0x3f9>
			107d: R_X86_64_PLT32	rt_int_cmp-0x4
    1081:	mov    ecx,0x2
    1086:	test   rax,rax
    1089:	cmovle rcx,QWORD PTR [rip+0x107]        # 1198 <botlish_fn_3+0x510>
    1091:	jmp    10ad <botlish_fn_3+0x425>
    1096:	mov    ecx,0x2
    109b:	mov    rsi,rbx
    109e:	cmp    rsi,0xfb
    10a5:	cmovle rcx,QWORD PTR [rip+0xeb]        # 1198 <botlish_fn_3+0x510>
    10ad:	cmp    rcx,0x6
    10b1:	je     1121 <botlish_fn_3+0x499>
    10b7:	mov    rsi,rbx
    10ba:	test   rsi,0x1
    10c1:	jne    10ed <botlish_fn_3+0x465>
    10c7:	mov    edx,0xfd
    10cc:	mov    rsi,rbx
    10cf:	mov    rdi,r12
    10d2:	call   10d7 <botlish_fn_3+0x44f>
			10d3: R_X86_64_PLT32	rt_int_cmp-0x4
    10d7:	mov    r8d,0x2
    10dd:	test   rax,rax
    10e0:	cmovle r8,QWORD PTR [rip+0xb0]        # 1198 <botlish_fn_3+0x510>
    10e8:	jmp    1105 <botlish_fn_3+0x47d>
    10ed:	mov    r8d,0x2
    10f3:	mov    rsi,rbx
    10f6:	cmp    rsi,0xfd
    10fd:	cmovle r8,QWORD PTR [rip+0x93]        # 1198 <botlish_fn_3+0x510>
    1105:	cmp    r8,0x6
    1109:	je     1119 <botlish_fn_3+0x491>
    110f:	mov    eax,0x2
    1114:	jmp    1180 <botlish_fn_3+0x4f8>
    1119:	mov    rax,r13
    111c:	jmp    1180 <botlish_fn_3+0x4f8>
    1121:	mov    eax,0x2
    1126:	jmp    1180 <botlish_fn_3+0x4f8>
    112b:	mov    rax,r13
    112e:	jmp    1180 <botlish_fn_3+0x4f8>
    1133:	mov    eax,0x2
    1138:	jmp    1180 <botlish_fn_3+0x4f8>
    113d:	mov    rax,r13
    1140:	jmp    1180 <botlish_fn_3+0x4f8>
    1145:	mov    eax,0x2
    114a:	jmp    1180 <botlish_fn_3+0x4f8>
    114f:	mov    rax,r13
    1152:	jmp    1180 <botlish_fn_3+0x4f8>
    1157:	mov    eax,0x2
    115c:	jmp    1180 <botlish_fn_3+0x4f8>
    1161:	mov    rax,r13
    1164:	jmp    1180 <botlish_fn_3+0x4f8>
    1169:	mov    eax,0x2
    116e:	jmp    1180 <botlish_fn_3+0x4f8>
    1173:	mov    rax,r13
    1176:	jmp    1180 <botlish_fn_3+0x4f8>
    117b:	mov    eax,0x2
    1180:	mov    rbx,QWORD PTR [rsp]
    1184:	mov    r12,QWORD PTR [rsp+0x8]
    1189:	mov    r13,QWORD PTR [rsp+0x10]
    118e:	add    rsp,0x20
    1192:	mov    rsp,rbp
    1195:	pop    rbp
    1196:	ret
    1197:	add    BYTE PTR [rsi],al
    1199:	add    BYTE PTR [rax],al
    119b:	add    BYTE PTR [rax],al
    119d:	add    BYTE PTR [rax],al
	...

00000000000011a0 <botlish_entry_3: is_unreserved<generic>>:
    11a0:	push   rbp
    11a1:	mov    rbp,rsp
    11a4:	mov    rsi,QWORD PTR [rdx]
    11a7:	call   11ac <botlish_entry_3+0xc>
			11a8: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    11ac:	mov    rsp,rbp
    11af:	pop    rbp
    11b0:	ret

00000000000011b1 <botlish_fn_4: hex_pair<generic>>:
    11b1:	push   rbp
    11b2:	mov    rbp,rsp
    11b5:	sub    rsp,0x40
    11b9:	mov    QWORD PTR [rsp+0x10],rbx
    11be:	mov    QWORD PTR [rsp+0x18],r12
    11c3:	mov    QWORD PTR [rsp+0x20],r13
    11c8:	mov    QWORD PTR [rsp+0x28],r14
    11cd:	mov    QWORD PTR [rsp+0x30],r15
    11d2:	mov    r13,rdx
    11d5:	mov    rbx,QWORD PTR [rdi]
    11d8:	mov    rax,QWORD PTR [rdi+0x8]
    11dc:	lea    rcx,[rbx+0x8]
    11e0:	cmp    rcx,rax
    11e3:	ja     13f9 <botlish_fn_4+0x248>
    11e9:	lea    rax,[rbx+0x8]
    11ed:	mov    QWORD PTR [rdi],rax
    11f0:	mov    r12,rdi
    11f3:	mov    QWORD PTR [rbx],0x0
    11fa:	mov    rdx,r13
    11fd:	mov    QWORD PTR [rsp],rdx
    1201:	mov    rax,QWORD PTR [rsi+0x20]
    1205:	mov    r14,rsi
    1208:	mov    rsi,QWORD PTR [rax]
    120b:	mov    QWORD PTR [rsp+0x8],rsi
    1210:	mov    r15,rsi
    1213:	mov    rsi,r13
    1216:	mov    rdi,r12
    1219:	call   121e <botlish_fn_4+0x6d>
			121a: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
    121e:	test   rax,rax
    1221:	jne    122f <botlish_fn_4+0x7e>
    1227:	mov    rdi,r12
    122a:	jmp    13a6 <botlish_fn_4+0x1f5>
    122f:	test   rax,0x1
    1235:	jne    1246 <botlish_fn_4+0x95>
    123b:	mov    rdx,rax
    123e:	mov    rsi,r15
    1241:	jmp    1262 <botlish_fn_4+0xb1>
    1246:	mov    rsi,r15
    1249:	mov    rdx,QWORD PTR [rsi+0x8]
    124d:	mov    rcx,rax
    1250:	sar    rcx,1
    1253:	mov    rdi,rax
    1256:	cmp    rcx,rdx
    1259:	jb     1283 <botlish_fn_4+0xd2>
    125f:	mov    rdx,rdi
    1262:	mov    rdi,r12
    1265:	call   126a <botlish_fn_4+0xb9>
			1266: R_X86_64_PLT32	rt_list_get-0x4
    126a:	test   rax,rax
    126d:	jne    127b <botlish_fn_4+0xca>
    1273:	mov    rdi,r12
    1276:	jmp    13a6 <botlish_fn_4+0x1f5>
    127b:	mov    rsi,rax
    127e:	jmp    128b <botlish_fn_4+0xda>
    1283:	mov    rdx,QWORD PTR [rsi+0x10]
    1287:	mov    rsi,QWORD PTR [rdx+rcx*8]
    128b:	mov    QWORD PTR [rsp],rsi
    128f:	mov    rax,rsi
    1292:	mov    rsi,r14
    1295:	mov    r14,rax
    1298:	mov    rsi,QWORD PTR [rsi+0x20]
    129c:	mov    rsi,QWORD PTR [rsi]
    129f:	mov    r15,rsi
    12a2:	mov    ecx,0x1
    12a7:	mov    rdx,r13
    12aa:	test   rdx,0x1
    12b1:	je     12bf <botlish_fn_4+0x10e>
    12b7:	mov    r13,rdx
    12ba:	jmp    12e4 <botlish_fn_4+0x133>
    12bf:	xor    ecx,ecx
    12c1:	test   rdx,0x7
    12c8:	je     12d6 <botlish_fn_4+0x125>
    12ce:	mov    r13,rdx
    12d1:	jmp    12e4 <botlish_fn_4+0x133>
    12d6:	movzx  r9,BYTE PTR [rdx]
    12da:	mov    r13,rdx
    12dd:	cmp    r9b,0x1
    12e1:	sete   cl
    12e4:	test   cl,cl
    12e6:	jne    130d <botlish_fn_4+0x15c>
    12ec:	mov    rdi,r12
    12ef:	mov    rax,QWORD PTR [rdi+0x10]
    12f3:	mov    rcx,QWORD PTR [rax+0xa8]
    12fa:	xor    rdx,rdx
    12fd:	mov    rsi,r13
    1300:	call   1305 <botlish_fn_4+0x154>
			1301: R_X86_64_PLT32	rt_type_error-0x4
    1305:	mov    rdi,r12
    1308:	jmp    13a6 <botlish_fn_4+0x1f5>
    130d:	mov    rsi,r13
    1310:	mov    edx,0x21
    1315:	mov    rdi,r12
    1318:	call   131d <botlish_fn_4+0x16c>
			1319: R_X86_64_PLT32	rt_int_mod-0x4
    131d:	test   rax,rax
    1320:	jne    132e <botlish_fn_4+0x17d>
    1326:	mov    rdi,r12
    1329:	jmp    13a6 <botlish_fn_4+0x1f5>
    132e:	test   rax,0x1
    1334:	jne    1345 <botlish_fn_4+0x194>
    133a:	mov    rdx,rax
    133d:	mov    rsi,r15
    1340:	jmp    1361 <botlish_fn_4+0x1b0>
    1345:	mov    rsi,r15
    1348:	mov    rdx,QWORD PTR [rsi+0x8]
    134c:	mov    rcx,rax
    134f:	sar    rcx,1
    1352:	mov    rdi,rax
    1355:	cmp    rcx,rdx
    1358:	jb     1382 <botlish_fn_4+0x1d1>
    135e:	mov    rdx,rdi
    1361:	mov    rdi,r12
    1364:	call   1369 <botlish_fn_4+0x1b8>
			1365: R_X86_64_PLT32	rt_list_get-0x4
    1369:	test   rax,rax
    136c:	jne    137a <botlish_fn_4+0x1c9>
    1372:	mov    rdi,r12
    1375:	jmp    13a6 <botlish_fn_4+0x1f5>
    137a:	mov    rdx,rax
    137d:	jmp    138a <botlish_fn_4+0x1d9>
    1382:	mov    rax,QWORD PTR [rsi+0x10]
    1386:	mov    rdx,QWORD PTR [rax+rcx*8]
    138a:	mov    QWORD PTR [rsp+0x8],rdx
    138f:	mov    rsi,r14
    1392:	mov    rdi,r12
    1395:	call   139a <botlish_fn_4+0x1e9>
			1396: R_X86_64_PLT32	rt_str_cat-0x4
    139a:	test   rax,rax
    139d:	jne    13d1 <botlish_fn_4+0x220>
    13a3:	mov    rdi,r12
    13a6:	mov    rdi,r12
    13a9:	mov    QWORD PTR [rdi],rbx
    13ac:	xor    rax,rax
    13af:	mov    rbx,QWORD PTR [rsp+0x10]
    13b4:	mov    r12,QWORD PTR [rsp+0x18]
    13b9:	mov    r13,QWORD PTR [rsp+0x20]
    13be:	mov    r14,QWORD PTR [rsp+0x28]
    13c3:	mov    r15,QWORD PTR [rsp+0x30]
    13c8:	add    rsp,0x40
    13cc:	mov    rsp,rbp
    13cf:	pop    rbp
    13d0:	ret
    13d1:	mov    rdi,r12
    13d4:	mov    QWORD PTR [rdi],rbx
    13d7:	mov    rbx,QWORD PTR [rsp+0x10]
    13dc:	mov    r12,QWORD PTR [rsp+0x18]
    13e1:	mov    r13,QWORD PTR [rsp+0x20]
    13e6:	mov    r14,QWORD PTR [rsp+0x28]
    13eb:	mov    r15,QWORD PTR [rsp+0x30]
    13f0:	add    rsp,0x40
    13f4:	mov    rsp,rbp
    13f7:	pop    rbp
    13f8:	ret
    13f9:	mov    r12,rdi
    13fc:	call   1401 <botlish_fn_4+0x250>
			13fd: R_X86_64_PLT32	rt_stack_overflow-0x4
    1401:	xor    rax,rax
    1404:	mov    rbx,QWORD PTR [rsp+0x10]
    1409:	mov    r12,QWORD PTR [rsp+0x18]
    140e:	mov    r13,QWORD PTR [rsp+0x20]
    1413:	mov    r14,QWORD PTR [rsp+0x28]
    1418:	mov    r15,QWORD PTR [rsp+0x30]
    141d:	add    rsp,0x40
    1421:	mov    rsp,rbp
    1424:	pop    rbp
    1425:	ret

0000000000001426 <botlish_entry_4: hex_pair<generic>>:
    1426:	push   rbp
    1427:	mov    rbp,rsp
    142a:	mov    rdx,QWORD PTR [rdx]
    142d:	call   1432 <botlish_entry_4+0xc>
			142e: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    1432:	mov    rsp,rbp
    1435:	pop    rbp
    1436:	ret
	...

0000000000001438 <botlish_fn_5: esc_bytes<generic>>:
    1438:	push   rbp
    1439:	mov    rbp,rsp
    143c:	sub    rsp,0x90
    1443:	mov    QWORD PTR [rsp+0x60],rbx
    1448:	mov    QWORD PTR [rsp+0x68],r12
    144d:	mov    QWORD PTR [rsp+0x70],r13
    1452:	mov    QWORD PTR [rsp+0x78],r14
    1457:	mov    QWORD PTR [rsp+0x80],r15
    145f:	mov    r15,rsi
    1462:	mov    r13,QWORD PTR [rdi]
    1465:	mov    r9,QWORD PTR [rdi+0x8]
    1469:	lea    r10,[r13+0x8]
    146d:	cmp    r10,r9
    1470:	ja     17e1 <botlish_fn_5+0x3a9>
    1476:	lea    r10,[r13+0x8]
    147a:	mov    QWORD PTR [rdi],r10
    147d:	mov    r14,rdi
    1480:	mov    QWORD PTR [r13+0x0],0x0
    1488:	mov    QWORD PTR [rsp+0x28],0x0
    1491:	mov    QWORD PTR [rsp+0x30],0x0
    149a:	mov    QWORD PTR [rsp],rdx
    149e:	mov    QWORD PTR [rsp+0x8],rcx
    14a3:	mov    QWORD PTR [rsp+0x10],r8
    14a8:	mov    QWORD PTR [rsp+0x38],rcx
    14ad:	mov    QWORD PTR [rsp+0x40],r8
    14b2:	xor    eax,eax
    14b4:	test   rdx,0x7
    14bb:	je     14c9 <botlish_fn_5+0x91>
    14c1:	mov    rsi,rdx
    14c4:	jmp    14d5 <botlish_fn_5+0x9d>
    14c9:	movzx  rax,BYTE PTR [rdx]
    14cd:	mov    rsi,rdx
    14d0:	cmp    al,0x3
    14d2:	sete   al
    14d5:	test   al,al
    14d7:	jne    14fd <botlish_fn_5+0xc5>
    14dd:	mov    rdi,r14
    14e0:	mov    rax,QWORD PTR [rdi+0x10]
    14e4:	mov    rcx,QWORD PTR [rax+0xb0]
    14eb:	mov    edx,0x4
    14f0:	call   14f5 <botlish_fn_5+0xbd>
			14f1: R_X86_64_PLT32	rt_type_error-0x4
    14f5:	mov    rdi,r14
    14f8:	jmp    1755 <botlish_fn_5+0x31d>
    14fd:	mov    rbx,rsi
    1500:	mov    rdi,r14
    1503:	call   1508 <botlish_fn_5+0xd0>
			1504: R_X86_64_PLT32	rt_list_len-0x4
    1508:	mov    ecx,0x1
    150d:	mov    rsi,QWORD PTR [rsp+0x38]
    1512:	test   rsi,0x1
    1519:	jne    1543 <botlish_fn_5+0x10b>
    151f:	xor    ecx,ecx
    1521:	mov    rsi,QWORD PTR [rsp+0x38]
    1526:	test   rsi,0x7
    152d:	jne    1543 <botlish_fn_5+0x10b>
    1533:	mov    rsi,QWORD PTR [rsp+0x38]
    1538:	movzx  rcx,BYTE PTR [rsi]
    153c:	rex cmp cl,0x1
    1540:	sete   cl
    1543:	test   cl,cl
    1545:	jne    156e <botlish_fn_5+0x136>
    154b:	mov    rdi,r14
    154e:	mov    rax,QWORD PTR [rdi+0x10]
    1552:	mov    rcx,QWORD PTR [rax+0xb8]
    1559:	xor    rdx,rdx
    155c:	mov    rsi,QWORD PTR [rsp+0x38]
    1561:	call   1566 <botlish_fn_5+0x12e>
			1562: R_X86_64_PLT32	rt_type_error-0x4
    1566:	mov    rdi,r14
    1569:	jmp    1755 <botlish_fn_5+0x31d>
    156e:	mov    rsi,QWORD PTR [rsp+0x38]
    1573:	mov    rcx,rsi
    1576:	and    rcx,rax
    1579:	mov    rdx,rax
    157c:	test   rcx,0x1
    1583:	jne    15ab <botlish_fn_5+0x173>
    1589:	mov    rsi,QWORD PTR [rsp+0x38]
    158e:	mov    rdi,r14
    1591:	call   1596 <botlish_fn_5+0x15e>
			1592: R_X86_64_PLT32	rt_int_cmp-0x4
    1596:	mov    esi,0x2
    159b:	test   rax,rax
    159e:	cmovge rsi,QWORD PTR [rip+0x272]        # 1818 <botlish_fn_5+0x3e0>
    15a6:	jmp    15c0 <botlish_fn_5+0x188>
    15ab:	mov    esi,0x2
    15b0:	mov    rax,QWORD PTR [rsp+0x38]
    15b5:	cmp    rax,rdx
    15b8:	cmovge rsi,QWORD PTR [rip+0x258]        # 1818 <botlish_fn_5+0x3e0>
    15c0:	cmp    rsi,0x6
    15c4:	je     17ae <botlish_fn_5+0x376>
    15ca:	mov    r12,r15
    15cd:	mov    QWORD PTR [rsp+0x18],r12
    15d2:	mov    QWORD PTR [rsp+0x20],0x3
    15db:	mov    rsi,QWORD PTR [rsp+0x38]
    15e0:	test   rsi,0x1
    15e7:	je     1604 <botlish_fn_5+0x1cc>
    15ed:	mov    rsi,QWORD PTR [rsp+0x38]
    15f2:	mov    rax,rsi
    15f5:	add    rax,0x2
    15f9:	seto   cl
    15fc:	test   cl,cl
    15fe:	je     1616 <botlish_fn_5+0x1de>
    1604:	mov    edx,0x3
    1609:	mov    rsi,QWORD PTR [rsp+0x38]
    160e:	mov    rdi,r14
    1611:	call   1616 <botlish_fn_5+0x1de>
			1612: R_X86_64_PLT32	rt_int_add-0x4
    1616:	mov    QWORD PTR [rsp+0x8],rax
    161b:	mov    rdi,r14
    161e:	mov    QWORD PTR [rsp+0x48],rax
    1623:	mov    rax,QWORD PTR [rdi+0x10]
    1627:	mov    rsi,QWORD PTR [rax+0xc0]
    162e:	mov    QWORD PTR [rsp+0x20],rsi
    1633:	mov    r15,rsi
    1636:	mov    rax,QWORD PTR [r12+0x20]
    163b:	mov    rsi,QWORD PTR [rax]
    163e:	mov    QWORD PTR [rsp+0x28],rsi
    1643:	mov    QWORD PTR [rsp+0x50],rsi
    1648:	mov    rsi,QWORD PTR [rsp+0x38]
    164d:	test   rsi,0x1
    1654:	jne    1664 <botlish_fn_5+0x22c>
    165a:	mov    rdx,QWORD PTR [rsp+0x38]
    165f:	jmp    1681 <botlish_fn_5+0x249>
    1664:	mov    rcx,QWORD PTR [rbx+0x8]
    1668:	mov    rsi,QWORD PTR [rsp+0x38]
    166d:	mov    rax,rsi
    1670:	sar    rax,1
    1673:	cmp    rax,rcx
    1676:	jb     16a5 <botlish_fn_5+0x26d>
    167c:	mov    rdx,QWORD PTR [rsp+0x38]
    1681:	mov    rsi,rbx
    1684:	mov    rdi,r14
    1687:	call   168c <botlish_fn_5+0x254>
			1688: R_X86_64_PLT32	rt_list_get-0x4
    168c:	test   rax,rax
    168f:	jne    169d <botlish_fn_5+0x265>
    1695:	mov    rdi,r14
    1698:	jmp    1755 <botlish_fn_5+0x31d>
    169d:	mov    rdx,rax
    16a0:	jmp    16ad <botlish_fn_5+0x275>
    16a5:	mov    rsi,QWORD PTR [rbx+0x10]
    16a9:	mov    rdx,QWORD PTR [rsi+rax*8]
    16ad:	mov    QWORD PTR [rsp+0x30],rdx
    16b2:	mov    rsi,QWORD PTR [rsp+0x50]
    16b7:	mov    rdi,r14
    16ba:	call   16bf <botlish_fn_5+0x287>
			16bb: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    16bf:	test   rax,rax
    16c2:	jne    16d0 <botlish_fn_5+0x298>
    16c8:	mov    rdi,r14
    16cb:	jmp    1755 <botlish_fn_5+0x31d>
    16d0:	mov    QWORD PTR [rsp+0x28],rax
    16d5:	mov    rdx,rax
    16d8:	mov    rsi,r15
    16db:	mov    rdi,r14
    16de:	call   16e3 <botlish_fn_5+0x2ab>
			16df: R_X86_64_PLT32	rt_str_cat-0x4
    16e3:	test   rax,rax
    16e6:	jne    16f4 <botlish_fn_5+0x2bc>
    16ec:	mov    rdi,r14
    16ef:	jmp    1755 <botlish_fn_5+0x31d>
    16f4:	mov    QWORD PTR [rsp+0x20],rax
    16f9:	mov    rdx,rax
    16fc:	xor    ecx,ecx
    16fe:	mov    rsi,QWORD PTR [rsp+0x40]
    1703:	test   rsi,0x7
    170a:	jne    1719 <botlish_fn_5+0x2e1>
    1710:	movzx  rax,BYTE PTR [rsi]
    1714:	cmp    al,0x2
    1716:	sete   cl
    1719:	test   cl,cl
    171b:	jne    1741 <botlish_fn_5+0x309>
    1721:	mov    rdi,r14
    1724:	mov    rax,QWORD PTR [rdi+0x10]
    1728:	mov    rcx,QWORD PTR [rax+0xc8]
    172f:	mov    edx,0x1
    1734:	call   1739 <botlish_fn_5+0x301>
			1735: R_X86_64_PLT32	rt_type_error-0x4
    1739:	mov    rdi,r14
    173c:	jmp    1755 <botlish_fn_5+0x31d>
    1741:	mov    rdi,r14
    1744:	call   1749 <botlish_fn_5+0x311>
			1745: R_X86_64_PLT32	rt_str_cat-0x4
    1749:	test   rax,rax
    174c:	jne    1786 <botlish_fn_5+0x34e>
    1752:	mov    rdi,r14
    1755:	mov    rdi,r14
    1758:	mov    QWORD PTR [rdi],r13
    175b:	xor    rax,rax
    175e:	mov    rbx,QWORD PTR [rsp+0x60]
    1763:	mov    r12,QWORD PTR [rsp+0x68]
    1768:	mov    r13,QWORD PTR [rsp+0x70]
    176d:	mov    r14,QWORD PTR [rsp+0x78]
    1772:	mov    r15,QWORD PTR [rsp+0x80]
    177a:	add    rsp,0x90
    1781:	mov    rsp,rbp
    1784:	pop    rbp
    1785:	ret
    1786:	mov    QWORD PTR [rsp],rbx
    178a:	mov    rcx,QWORD PTR [rsp+0x48]
    178f:	mov    QWORD PTR [rsp+0x8],rcx
    1794:	mov    QWORD PTR [rsp+0x10],rax
    1799:	mov    rdx,rbx
    179c:	mov    r15,r12
    179f:	mov    QWORD PTR [rsp+0x38],rcx
    17a4:	mov    QWORD PTR [rsp+0x40],rax
    17a9:	jmp    14b2 <botlish_fn_5+0x7a>
    17ae:	mov    rdi,r14
    17b1:	mov    QWORD PTR [rdi],r13
    17b4:	mov    rax,QWORD PTR [rsp+0x40]
    17b9:	mov    rbx,QWORD PTR [rsp+0x60]
    17be:	mov    r12,QWORD PTR [rsp+0x68]
    17c3:	mov    r13,QWORD PTR [rsp+0x70]
    17c8:	mov    r14,QWORD PTR [rsp+0x78]
    17cd:	mov    r15,QWORD PTR [rsp+0x80]
    17d5:	add    rsp,0x90
    17dc:	mov    rsp,rbp
    17df:	pop    rbp
    17e0:	ret
    17e1:	mov    r14,rdi
    17e4:	call   17e9 <botlish_fn_5+0x3b1>
			17e5: R_X86_64_PLT32	rt_stack_overflow-0x4
    17e9:	xor    rax,rax
    17ec:	mov    rbx,QWORD PTR [rsp+0x60]
    17f1:	mov    r12,QWORD PTR [rsp+0x68]
    17f6:	mov    r13,QWORD PTR [rsp+0x70]
    17fb:	mov    r14,QWORD PTR [rsp+0x78]
    1800:	mov    r15,QWORD PTR [rsp+0x80]
    1808:	add    rsp,0x90
    180f:	mov    rsp,rbp
    1812:	pop    rbp
    1813:	ret
    1814:	add    BYTE PTR [rax],al
    1816:	add    BYTE PTR [rax],al
    1818:	(bad)
    1819:	add    BYTE PTR [rax],al
    181b:	add    BYTE PTR [rax],al
    181d:	add    BYTE PTR [rax],al
	...

0000000000001820 <botlish_entry_5: esc_bytes<generic>>:
    1820:	push   rbp
    1821:	mov    rbp,rsp
    1824:	mov    r9,QWORD PTR [rdx]
    1827:	mov    rcx,QWORD PTR [rdx+0x8]
    182b:	mov    r8,QWORD PTR [rdx+0x10]
    182f:	mov    rdx,r9
    1832:	call   1837 <botlish_entry_5+0x17>
			1833: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    1837:	mov    rsp,rbp
    183a:	pop    rbp
    183b:	ret

000000000000183c <botlish_fn_6: esc_char<generic>>:
    183c:	push   rbp
    183d:	mov    rbp,rsp
    1840:	sub    rsp,0x60
    1844:	mov    QWORD PTR [rsp+0x30],rbx
    1849:	mov    QWORD PTR [rsp+0x38],r12
    184e:	mov    QWORD PTR [rsp+0x40],r13
    1853:	mov    QWORD PTR [rsp+0x48],r14
    1858:	mov    QWORD PTR [rsp+0x50],r15
    185d:	mov    rbx,rsi
    1860:	mov    r12,QWORD PTR [rdi]
    1863:	mov    rax,QWORD PTR [rdi+0x8]
    1867:	lea    rcx,[r12+0x8]
    186c:	cmp    rcx,rax
    186f:	ja     1a95 <botlish_fn_6+0x259>
    1875:	lea    rax,[r12+0x8]
    187a:	mov    QWORD PTR [rdi],rax
    187d:	mov    QWORD PTR [r12],0x0
    1885:	mov    QWORD PTR [rsp+0x8],0x0
    188e:	mov    QWORD PTR [rsp+0x10],0x0
    1897:	mov    QWORD PTR [rsp+0x18],0x0
    18a0:	mov    QWORD PTR [rsp],rdx
    18a4:	xor    eax,eax
    18a6:	test   rdx,0x7
    18ad:	je     18bb <botlish_fn_6+0x7f>
    18b3:	mov    r14,rdx
    18b6:	jmp    18c7 <botlish_fn_6+0x8b>
    18bb:	movzx  rax,BYTE PTR [rdx]
    18bf:	mov    r14,rdx
    18c2:	cmp    al,0x2
    18c4:	sete   al
    18c7:	test   al,al
    18c9:	jne    18f2 <botlish_fn_6+0xb6>
    18cf:	mov    rax,QWORD PTR [rdi+0x10]
    18d3:	mov    r13,rdi
    18d6:	mov    rcx,QWORD PTR [rax+0xd0]
    18dd:	mov    edx,0x1
    18e2:	mov    rsi,r14
    18e5:	call   18ea <botlish_fn_6+0xae>
			18e6: R_X86_64_PLT32	rt_type_error-0x4
    18ea:	mov    rdi,r13
    18ed:	jmp    1a37 <botlish_fn_6+0x1fb>
    18f2:	mov    r13,rdi
    18f5:	mov    rsi,r14
    18f8:	call   18fd <botlish_fn_6+0xc1>
			18f9: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    18fd:	mov    rcx,rax
    1900:	mov    r15,rax
    1903:	test   rax,rcx
    1906:	jne    1914 <botlish_fn_6+0xd8>
    190c:	mov    rdi,r13
    190f:	jmp    1a37 <botlish_fn_6+0x1fb>
    1914:	mov    rax,r15
    1917:	mov    QWORD PTR [rsp+0x8],rax
    191c:	mov    rsi,r15
    191f:	mov    rdi,r13
    1922:	call   1927 <botlish_fn_6+0xeb>
			1923: R_X86_64_PLT32	rt_list_len-0x4
    1927:	mov    ecx,0x1
    192c:	sar    rax,1
    192f:	cmp    rax,0x1
    1933:	je     1984 <botlish_fn_6+0x148>
    1939:	mov    rsi,QWORD PTR [rbx+0x20]
    193d:	mov    rsi,QWORD PTR [rsi]
    1940:	mov    QWORD PTR [rsp],rsi
    1944:	mov    QWORD PTR [rsp+0x10],0x1
    194d:	mov    rdi,r13
    1950:	mov    rdi,QWORD PTR [rdi+0x10]
    1954:	mov    r8,QWORD PTR [rdi+0x98]
    195b:	mov    QWORD PTR [rsp+0x18],r8
    1960:	mov    rdx,r15
    1963:	mov    rdi,r13
    1966:	call   196b <botlish_fn_6+0x12f>
			1967: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    196b:	test   rax,rax
    196e:	jne    197c <botlish_fn_6+0x140>
    1974:	mov    rdi,r13
    1977:	jmp    1a37 <botlish_fn_6+0x1fb>
    197c:	mov    rdi,r13
    197f:	jmp    1a6d <botlish_fn_6+0x231>
    1984:	mov    rdx,r15
    1987:	mov    QWORD PTR [rsp+0x20],rcx
    198c:	mov    r11,QWORD PTR [rdx+0x8]
    1990:	mov    r15,rdx
    1993:	test   r11,r11
    1996:	jne    19c5 <botlish_fn_6+0x189>
    199c:	mov    rdx,QWORD PTR [rsp+0x20]
    19a1:	mov    rsi,r15
    19a4:	mov    rdi,r13
    19a7:	call   19ac <botlish_fn_6+0x170>
			19a8: R_X86_64_PLT32	rt_list_get-0x4
    19ac:	test   rax,rax
    19af:	jne    19bd <botlish_fn_6+0x181>
    19b5:	mov    rdi,r13
    19b8:	jmp    1a37 <botlish_fn_6+0x1fb>
    19bd:	mov    rsi,rax
    19c0:	jmp    19cf <botlish_fn_6+0x193>
    19c5:	mov    rdx,r15
    19c8:	mov    rax,QWORD PTR [rdx+0x10]
    19cc:	mov    rsi,QWORD PTR [rax]
    19cf:	mov    QWORD PTR [rsp+0x10],rsi
    19d4:	mov    rdi,r13
    19d7:	call   19dc <botlish_fn_6+0x1a0>
			19d8: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    19dc:	test   rax,rax
    19df:	jne    19ed <botlish_fn_6+0x1b1>
    19e5:	mov    rdi,r13
    19e8:	jmp    1a37 <botlish_fn_6+0x1fb>
    19ed:	cmp    rax,0x6
    19f1:	je     1a67 <botlish_fn_6+0x22b>
    19f7:	mov    rax,QWORD PTR [rbx+0x20]
    19fb:	mov    rsi,QWORD PTR [rax]
    19fe:	mov    QWORD PTR [rsp],rsi
    1a02:	mov    QWORD PTR [rsp+0x10],0x1
    1a0b:	mov    rdi,r13
    1a0e:	mov    rax,QWORD PTR [rdi+0x10]
    1a12:	mov    r8,QWORD PTR [rax+0x98]
    1a19:	mov    QWORD PTR [rsp+0x18],r8
    1a1e:	mov    rcx,QWORD PTR [rsp+0x20]
    1a23:	mov    rdx,r15
    1a26:	call   1a2b <botlish_fn_6+0x1ef>
			1a27: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    1a2b:	test   rax,rax
    1a2e:	jne    1a6a <botlish_fn_6+0x22e>
    1a34:	mov    rdi,r13
    1a37:	mov    rdi,r13
    1a3a:	mov    QWORD PTR [rdi],r12
    1a3d:	xor    rax,rax
    1a40:	mov    rbx,QWORD PTR [rsp+0x30]
    1a45:	mov    r12,QWORD PTR [rsp+0x38]
    1a4a:	mov    r13,QWORD PTR [rsp+0x40]
    1a4f:	mov    r14,QWORD PTR [rsp+0x48]
    1a54:	mov    r15,QWORD PTR [rsp+0x50]
    1a59:	add    rsp,0x60
    1a5d:	mov    rsp,rbp
    1a60:	pop    rbp
    1a61:	ret
    1a62:	jmp    1a6a <botlish_fn_6+0x22e>
    1a67:	mov    rax,r14
    1a6a:	mov    rdi,r13
    1a6d:	mov    rdi,r13
    1a70:	mov    QWORD PTR [rdi],r12
    1a73:	mov    rbx,QWORD PTR [rsp+0x30]
    1a78:	mov    r12,QWORD PTR [rsp+0x38]
    1a7d:	mov    r13,QWORD PTR [rsp+0x40]
    1a82:	mov    r14,QWORD PTR [rsp+0x48]
    1a87:	mov    r15,QWORD PTR [rsp+0x50]
    1a8c:	add    rsp,0x60
    1a90:	mov    rsp,rbp
    1a93:	pop    rbp
    1a94:	ret
    1a95:	mov    r13,rdi
    1a98:	call   1a9d <botlish_fn_6+0x261>
			1a99: R_X86_64_PLT32	rt_stack_overflow-0x4
    1a9d:	xor    rax,rax
    1aa0:	mov    rbx,QWORD PTR [rsp+0x30]
    1aa5:	mov    r12,QWORD PTR [rsp+0x38]
    1aaa:	mov    r13,QWORD PTR [rsp+0x40]
    1aaf:	mov    r14,QWORD PTR [rsp+0x48]
    1ab4:	mov    r15,QWORD PTR [rsp+0x50]
    1ab9:	add    rsp,0x60
    1abd:	mov    rsp,rbp
    1ac0:	pop    rbp
    1ac1:	ret

0000000000001ac2 <botlish_entry_6: esc_char<generic>>:
    1ac2:	push   rbp
    1ac3:	mov    rbp,rsp
    1ac6:	mov    rdx,QWORD PTR [rdx]
    1ac9:	call   1ace <botlish_entry_6+0xc>
			1aca: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    1ace:	mov    rsp,rbp
    1ad1:	pop    rbp
    1ad2:	ret
    1ad3:	add    BYTE PTR [rax],al
    1ad5:	add    BYTE PTR [rax],al
	...

0000000000001ad8 <botlish_fn_7: esc_from<generic>>:
    1ad8:	push   rbp
    1ad9:	mov    rbp,rsp
    1adc:	sub    rsp,0x90
    1ae3:	mov    QWORD PTR [rsp+0x60],rbx
    1ae8:	mov    QWORD PTR [rsp+0x68],r12
    1aed:	mov    QWORD PTR [rsp+0x70],r13
    1af2:	mov    QWORD PTR [rsp+0x78],r14
    1af7:	mov    QWORD PTR [rsp+0x80],r15
    1aff:	mov    r12,rsi
    1b02:	mov    r13,QWORD PTR [rdi]
    1b05:	mov    rax,QWORD PTR [rdi+0x8]
    1b09:	lea    rsi,[r13+0x8]
    1b0d:	cmp    rsi,rax
    1b10:	ja     1ea1 <botlish_fn_7+0x3c9>
    1b16:	lea    rax,[r13+0x8]
    1b1a:	mov    QWORD PTR [rdi],rax
    1b1d:	mov    r14,rdi
    1b20:	mov    QWORD PTR [r13+0x0],0x0
    1b28:	mov    QWORD PTR [rsp+0x28],0x0
    1b31:	mov    QWORD PTR [rsp+0x30],0x0
    1b3a:	mov    QWORD PTR [rsp],rdx
    1b3e:	mov    QWORD PTR [rsp+0x8],rcx
    1b43:	mov    QWORD PTR [rsp+0x10],r8
    1b48:	mov    r15,r8
    1b4b:	mov    QWORD PTR [rsp+0x38],rcx
    1b50:	xor    eax,eax
    1b52:	test   rdx,0x7
    1b59:	je     1b67 <botlish_fn_7+0x8f>
    1b5f:	mov    rsi,rdx
    1b62:	jmp    1b73 <botlish_fn_7+0x9b>
    1b67:	movzx  rax,BYTE PTR [rdx]
    1b6b:	mov    rsi,rdx
    1b6e:	cmp    al,0x2
    1b70:	sete   al
    1b73:	test   al,al
    1b75:	jne    1b9b <botlish_fn_7+0xc3>
    1b7b:	mov    rdi,r14
    1b7e:	mov    rax,QWORD PTR [rdi+0x10]
    1b82:	mov    rcx,QWORD PTR [rax+0xd8]
    1b89:	mov    edx,0x1
    1b8e:	call   1b93 <botlish_fn_7+0xbb>
			1b8f: R_X86_64_PLT32	rt_type_error-0x4
    1b93:	mov    rdi,r14
    1b96:	jmp    1e1c <botlish_fn_7+0x344>
    1b9b:	mov    rbx,rsi
    1b9e:	mov    rdi,r14
    1ba1:	call   1ba6 <botlish_fn_7+0xce>
			1ba2: R_X86_64_PLT32	rt_str_len-0x4
    1ba6:	mov    edx,0x1
    1bab:	mov    QWORD PTR [rsp+0x50],rdx
    1bb0:	mov    ecx,0x1
    1bb5:	mov    rsi,QWORD PTR [rsp+0x38]
    1bba:	test   rsi,0x1
    1bc1:	jne    1beb <botlish_fn_7+0x113>
    1bc7:	xor    ecx,ecx
    1bc9:	mov    rsi,QWORD PTR [rsp+0x38]
    1bce:	test   rsi,0x7
    1bd5:	jne    1beb <botlish_fn_7+0x113>
    1bdb:	mov    rsi,QWORD PTR [rsp+0x38]
    1be0:	movzx  rcx,BYTE PTR [rsi]
    1be4:	rex cmp cl,0x1
    1be8:	sete   cl
    1beb:	test   cl,cl
    1bed:	jne    1c16 <botlish_fn_7+0x13e>
    1bf3:	mov    rdi,r14
    1bf6:	mov    rax,QWORD PTR [rdi+0x10]
    1bfa:	mov    rcx,QWORD PTR [rax+0xb8]
    1c01:	xor    rdx,rdx
    1c04:	mov    rsi,QWORD PTR [rsp+0x38]
    1c09:	call   1c0e <botlish_fn_7+0x136>
			1c0a: R_X86_64_PLT32	rt_type_error-0x4
    1c0e:	mov    rdi,r14
    1c11:	jmp    1e1c <botlish_fn_7+0x344>
    1c16:	mov    rsi,QWORD PTR [rsp+0x38]
    1c1b:	mov    rcx,rsi
    1c1e:	and    rcx,rax
    1c21:	mov    rdx,rax
    1c24:	test   rcx,0x1
    1c2b:	jne    1c53 <botlish_fn_7+0x17b>
    1c31:	mov    rsi,QWORD PTR [rsp+0x38]
    1c36:	mov    rdi,r14
    1c39:	call   1c3e <botlish_fn_7+0x166>
			1c3a: R_X86_64_PLT32	rt_int_cmp-0x4
    1c3e:	mov    esi,0x2
    1c43:	test   rax,rax
    1c46:	cmovge rsi,QWORD PTR [rip+0x28a]        # 1ed8 <botlish_fn_7+0x400>
    1c4e:	jmp    1c68 <botlish_fn_7+0x190>
    1c53:	mov    esi,0x2
    1c58:	mov    rax,QWORD PTR [rsp+0x38]
    1c5d:	cmp    rax,rdx
    1c60:	cmovge rsi,QWORD PTR [rip+0x270]        # 1ed8 <botlish_fn_7+0x400>
    1c68:	cmp    rsi,0x6
    1c6c:	je     1e70 <botlish_fn_7+0x398>
    1c72:	mov    QWORD PTR [rsp+0x18],r12
    1c77:	mov    QWORD PTR [rsp+0x20],0x3
    1c80:	mov    rsi,QWORD PTR [rsp+0x38]
    1c85:	test   rsi,0x1
    1c8c:	je     1ca9 <botlish_fn_7+0x1d1>
    1c92:	mov    rsi,QWORD PTR [rsp+0x38]
    1c97:	mov    rax,rsi
    1c9a:	add    rax,0x2
    1c9e:	seto   cl
    1ca1:	test   cl,cl
    1ca3:	je     1cbb <botlish_fn_7+0x1e3>
    1ca9:	mov    edx,0x3
    1cae:	mov    rsi,QWORD PTR [rsp+0x38]
    1cb3:	mov    rdi,r14
    1cb6:	call   1cbb <botlish_fn_7+0x1e3>
			1cb7: R_X86_64_PLT32	rt_int_add-0x4
    1cbb:	mov    QWORD PTR [rsp+0x20],rax
    1cc0:	mov    QWORD PTR [rsp+0x40],rax
    1cc5:	mov    rax,QWORD PTR [r12+0x20]
    1cca:	mov    rsi,QWORD PTR [rax]
    1ccd:	mov    QWORD PTR [rsp+0x28],rsi
    1cd2:	mov    QWORD PTR [rsp+0x48],rsi
    1cd7:	mov    QWORD PTR [rsp+0x30],0x3
    1ce0:	mov    rsi,QWORD PTR [rsp+0x38]
    1ce5:	test   rsi,0x1
    1cec:	je     1d0b <botlish_fn_7+0x233>
    1cf2:	mov    rsi,QWORD PTR [rsp+0x38]
    1cf7:	mov    rcx,rsi
    1cfa:	add    rcx,0x2
    1cfe:	seto   sil
    1d02:	test   sil,sil
    1d05:	je     1d20 <botlish_fn_7+0x248>
    1d0b:	mov    edx,0x3
    1d10:	mov    rsi,QWORD PTR [rsp+0x38]
    1d15:	mov    rdi,r14
    1d18:	call   1d1d <botlish_fn_7+0x245>
			1d19: R_X86_64_PLT32	rt_int_add-0x4
    1d1d:	mov    rcx,rax
    1d20:	mov    QWORD PTR [rsp+0x30],rcx
    1d25:	mov    rdx,QWORD PTR [rsp+0x38]
    1d2a:	mov    rsi,rbx
    1d2d:	mov    rdi,r14
    1d30:	call   1d35 <botlish_fn_7+0x25d>
			1d31: R_X86_64_PLT32	rt_substr-0x4
    1d35:	test   rax,rax
    1d38:	jne    1d46 <botlish_fn_7+0x26e>
    1d3e:	mov    rdi,r14
    1d41:	jmp    1e1c <botlish_fn_7+0x344>
    1d46:	mov    QWORD PTR [rsp+0x8],rax
    1d4b:	mov    rdx,rax
    1d4e:	mov    rsi,QWORD PTR [rsp+0x48]
    1d53:	mov    rdi,r14
    1d56:	call   1d5b <botlish_fn_7+0x283>
			1d57: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    1d5b:	test   rax,rax
    1d5e:	jne    1d6c <botlish_fn_7+0x294>
    1d64:	mov    rdi,r14
    1d67:	jmp    1e1c <botlish_fn_7+0x344>
    1d6c:	mov    QWORD PTR [rsp+0x8],rax
    1d71:	xor    ecx,ecx
    1d73:	mov    rsi,r15
    1d76:	test   rsi,0x7
    1d7d:	jne    1d8e <botlish_fn_7+0x2b6>
    1d83:	movzx  rcx,BYTE PTR [rsi]
    1d87:	rex cmp cl,0x2
    1d8b:	sete   cl
    1d8e:	test   cl,cl
    1d90:	jne    1db6 <botlish_fn_7+0x2de>
    1d96:	mov    rdi,r14
    1d99:	mov    rax,QWORD PTR [rdi+0x10]
    1d9d:	mov    rcx,QWORD PTR [rax+0xc8]
    1da4:	mov    rdx,QWORD PTR [rsp+0x50]
    1da9:	call   1dae <botlish_fn_7+0x2d6>
			1daa: R_X86_64_PLT32	rt_type_error-0x4
    1dae:	mov    rdi,r14
    1db1:	jmp    1e1c <botlish_fn_7+0x344>
    1db6:	mov    rdx,QWORD PTR [rsp+0x50]
    1dbb:	xor    ecx,ecx
    1dbd:	test   rax,0x7
    1dc3:	je     1dd1 <botlish_fn_7+0x2f9>
    1dc9:	mov    r8,rax
    1dcc:	jmp    1ddf <botlish_fn_7+0x307>
    1dd1:	movzx  rcx,BYTE PTR [rax]
    1dd5:	mov    r8,rax
    1dd8:	rex cmp cl,0x2
    1ddc:	sete   cl
    1ddf:	test   cl,cl
    1de1:	jne    1e05 <botlish_fn_7+0x32d>
    1de7:	mov    rdi,r14
    1dea:	mov    rax,QWORD PTR [rdi+0x10]
    1dee:	mov    rcx,QWORD PTR [rax+0xc8]
    1df5:	mov    rsi,r8
    1df8:	call   1dfd <botlish_fn_7+0x325>
			1df9: R_X86_64_PLT32	rt_type_error-0x4
    1dfd:	mov    rdi,r14
    1e00:	jmp    1e1c <botlish_fn_7+0x344>
    1e05:	mov    rdx,r8
    1e08:	mov    rdi,r14
    1e0b:	call   1e10 <botlish_fn_7+0x338>
			1e0c: R_X86_64_PLT32	rt_str_cat-0x4
    1e10:	test   rax,rax
    1e13:	jne    1e4d <botlish_fn_7+0x375>
    1e19:	mov    rdi,r14
    1e1c:	mov    rdi,r14
    1e1f:	mov    QWORD PTR [rdi],r13
    1e22:	xor    rax,rax
    1e25:	mov    rbx,QWORD PTR [rsp+0x60]
    1e2a:	mov    r12,QWORD PTR [rsp+0x68]
    1e2f:	mov    r13,QWORD PTR [rsp+0x70]
    1e34:	mov    r14,QWORD PTR [rsp+0x78]
    1e39:	mov    r15,QWORD PTR [rsp+0x80]
    1e41:	add    rsp,0x90
    1e48:	mov    rsp,rbp
    1e4b:	pop    rbp
    1e4c:	ret
    1e4d:	mov    QWORD PTR [rsp],rbx
    1e51:	mov    r9,QWORD PTR [rsp+0x40]
    1e56:	mov    QWORD PTR [rsp+0x8],r9
    1e5b:	mov    QWORD PTR [rsp+0x10],rax
    1e60:	mov    rdx,rbx
    1e63:	mov    r15,rax
    1e66:	mov    QWORD PTR [rsp+0x38],r9
    1e6b:	jmp    1b50 <botlish_fn_7+0x78>
    1e70:	mov    rdi,r14
    1e73:	mov    QWORD PTR [rdi],r13
    1e76:	mov    rax,r15
    1e79:	mov    rbx,QWORD PTR [rsp+0x60]
    1e7e:	mov    r12,QWORD PTR [rsp+0x68]
    1e83:	mov    r13,QWORD PTR [rsp+0x70]
    1e88:	mov    r14,QWORD PTR [rsp+0x78]
    1e8d:	mov    r15,QWORD PTR [rsp+0x80]
    1e95:	add    rsp,0x90
    1e9c:	mov    rsp,rbp
    1e9f:	pop    rbp
    1ea0:	ret
    1ea1:	mov    r14,rdi
    1ea4:	call   1ea9 <botlish_fn_7+0x3d1>
			1ea5: R_X86_64_PLT32	rt_stack_overflow-0x4
    1ea9:	xor    rax,rax
    1eac:	mov    rbx,QWORD PTR [rsp+0x60]
    1eb1:	mov    r12,QWORD PTR [rsp+0x68]
    1eb6:	mov    r13,QWORD PTR [rsp+0x70]
    1ebb:	mov    r14,QWORD PTR [rsp+0x78]
    1ec0:	mov    r15,QWORD PTR [rsp+0x80]
    1ec8:	add    rsp,0x90
    1ecf:	mov    rsp,rbp
    1ed2:	pop    rbp
    1ed3:	ret
    1ed4:	add    BYTE PTR [rax],al
    1ed6:	add    BYTE PTR [rax],al
    1ed8:	(bad)
    1ed9:	add    BYTE PTR [rax],al
    1edb:	add    BYTE PTR [rax],al
    1edd:	add    BYTE PTR [rax],al
	...

0000000000001ee0 <botlish_entry_7: esc_from<generic>>:
    1ee0:	push   rbp
    1ee1:	mov    rbp,rsp
    1ee4:	mov    r9,QWORD PTR [rdx]
    1ee7:	mov    rcx,QWORD PTR [rdx+0x8]
    1eeb:	mov    r8,QWORD PTR [rdx+0x10]
    1eef:	mov    rdx,r9
    1ef2:	call   1ef7 <botlish_entry_7+0x17>
			1ef3: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
    1ef7:	mov    rsp,rbp
    1efa:	pop    rbp
    1efb:	ret
    1efc:	add    BYTE PTR [rax],al
	...

0000000000001f00 <botlish_fn_8: check<int, int, str, str>>:
    1f00:	push   rbp
    1f01:	mov    rbp,rsp
    1f04:	sub    rsp,0x60
    1f08:	mov    QWORD PTR [rsp+0x30],rbx
    1f0d:	mov    QWORD PTR [rsp+0x38],r12
    1f12:	mov    QWORD PTR [rsp+0x40],r13
    1f17:	mov    QWORD PTR [rsp+0x48],r14
    1f1c:	mov    QWORD PTR [rsp+0x50],r15
    1f21:	mov    r13,QWORD PTR [rdi]
    1f24:	mov    rax,QWORD PTR [rdi+0x8]
    1f28:	lea    r9,[r13+0x8]
    1f2c:	cmp    r9,rax
    1f2f:	ja     20ff <botlish_fn_8+0x1ff>
    1f35:	lea    rax,[r13+0x8]
    1f39:	mov    QWORD PTR [rdi],rax
    1f3c:	mov    r14,rdi
    1f3f:	mov    QWORD PTR [r13+0x0],0x0
    1f47:	mov    QWORD PTR [rsp+0x20],0x0
    1f50:	mov    QWORD PTR [rsp],rsi
    1f54:	mov    QWORD PTR [rsp+0x8],rdx
    1f59:	mov    QWORD PTR [rsp+0x10],rcx
    1f5e:	mov    r12,rcx
    1f61:	mov    QWORD PTR [rsp+0x18],r8
    1f66:	mov    r15,r8
    1f69:	mov    rbx,rsi
    1f6c:	mov    QWORD PTR [rsp+0x28],rdx
    1f71:	test   rbx,0x1
    1f78:	jne    1fa3 <botlish_fn_8+0xa3>
    1f7e:	mov    edx,0x1
    1f83:	mov    rsi,rbx
    1f86:	mov    rdi,r14
    1f89:	call   1f8e <botlish_fn_8+0x8e>
			1f8a: R_X86_64_PLT32	rt_int_cmp-0x4
    1f8e:	mov    ecx,0x2
    1f93:	test   rax,rax
    1f96:	cmovle rcx,QWORD PTR [rip+0x192]        # 2130 <botlish_fn_8+0x230>
    1f9e:	jmp    1fb4 <botlish_fn_8+0xb4>
    1fa3:	mov    ecx,0x2
    1fa8:	cmp    rbx,0x1
    1fac:	cmovle rcx,QWORD PTR [rip+0x17c]        # 2130 <botlish_fn_8+0x230>
    1fb4:	cmp    rcx,0x6
    1fb8:	je     20d2 <botlish_fn_8+0x1d2>
    1fbe:	mov    rdi,r14
    1fc1:	mov    rax,QWORD PTR [rdi+0x10]
    1fc5:	mov    rax,QWORD PTR [rax+0xe0]
    1fcc:	mov    rsi,r12
    1fcf:	call   1fd4 <botlish_fn_8+0xd4>
			1fd0: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    1fd4:	test   rax,rax
    1fd7:	jne    1fe5 <botlish_fn_8+0xe5>
    1fdd:	mov    rdi,r14
    1fe0:	jmp    2023 <botlish_fn_8+0x123>
    1fe5:	cmp    rax,0x6
    1fe9:	je     2001 <botlish_fn_8+0x101>
    1fef:	mov    edx,0x1
    1ff4:	mov    QWORD PTR [rsp],0x1
    1ffc:	jmp    206b <botlish_fn_8+0x16b>
    2001:	mov    rdi,r14
    2004:	mov    rsi,QWORD PTR [rdi+0x10]
    2008:	mov    rsi,QWORD PTR [rsi+0xe8]
    200f:	mov    rsi,r12
    2012:	call   2017 <botlish_fn_8+0x117>
			2013: R_X86_64_PLT32	botlish_fn_20-0x4 ; <str>
    2017:	test   rax,rax
    201a:	jne    204e <botlish_fn_8+0x14e>
    2020:	mov    rdi,r14
    2023:	mov    rdi,r14
    2026:	mov    QWORD PTR [rdi],r13
    2029:	xor    rax,rax
    202c:	mov    rbx,QWORD PTR [rsp+0x30]
    2031:	mov    r12,QWORD PTR [rsp+0x38]
    2036:	mov    r13,QWORD PTR [rsp+0x40]
    203b:	mov    r14,QWORD PTR [rsp+0x48]
    2040:	mov    r15,QWORD PTR [rsp+0x50]
    2045:	add    rsp,0x60
    2049:	mov    rsp,rbp
    204c:	pop    rbp
    204d:	ret
    204e:	cmp    rax,0x6
    2052:	je     2062 <botlish_fn_8+0x162>
    2058:	mov    edx,0x1
    205d:	jmp    2067 <botlish_fn_8+0x167>
    2062:	mov    edx,0x3
    2067:	mov    QWORD PTR [rsp],rdx
    206b:	sar    rbx,1
    206e:	sub    rbx,0x1
    2072:	shl    rbx,1
    2075:	or     rbx,0x1
    2079:	mov    QWORD PTR [rsp+0x20],rbx
    207e:	mov    rsi,QWORD PTR [rsp+0x28]
    2083:	mov    rax,rsi
    2086:	and    rax,rdx
    2089:	test   rax,0x1
    208f:	je     20aa <botlish_fn_8+0x1aa>
    2095:	lea    rcx,[rdx-0x1]
    2099:	mov    rax,rsi
    209c:	add    rax,rcx
    209f:	seto   cl
    20a2:	test   cl,cl
    20a4:	je     20b2 <botlish_fn_8+0x1b2>
    20aa:	mov    rdi,r14
    20ad:	call   20b2 <botlish_fn_8+0x1b2>
			20ae: R_X86_64_PLT32	rt_int_add-0x4
    20b2:	mov    QWORD PTR [rsp],rbx
    20b6:	mov    QWORD PTR [rsp+0x8],rax
    20bb:	mov    QWORD PTR [rsp+0x10],r12
    20c0:	mov    r8,r15
    20c3:	mov    QWORD PTR [rsp+0x18],r8
    20c8:	mov    QWORD PTR [rsp+0x28],rax
    20cd:	jmp    1f71 <botlish_fn_8+0x71>
    20d2:	mov    rdi,r14
    20d5:	mov    QWORD PTR [rdi],r13
    20d8:	mov    rax,QWORD PTR [rsp+0x28]
    20dd:	mov    rbx,QWORD PTR [rsp+0x30]
    20e2:	mov    r12,QWORD PTR [rsp+0x38]
    20e7:	mov    r13,QWORD PTR [rsp+0x40]
    20ec:	mov    r14,QWORD PTR [rsp+0x48]
    20f1:	mov    r15,QWORD PTR [rsp+0x50]
    20f6:	add    rsp,0x60
    20fa:	mov    rsp,rbp
    20fd:	pop    rbp
    20fe:	ret
    20ff:	mov    r14,rdi
    2102:	call   2107 <botlish_fn_8+0x207>
			2103: R_X86_64_PLT32	rt_stack_overflow-0x4
    2107:	xor    rax,rax
    210a:	mov    rbx,QWORD PTR [rsp+0x30]
    210f:	mov    r12,QWORD PTR [rsp+0x38]
    2114:	mov    r13,QWORD PTR [rsp+0x40]
    2119:	mov    r14,QWORD PTR [rsp+0x48]
    211e:	mov    r15,QWORD PTR [rsp+0x50]
    2123:	add    rsp,0x60
    2127:	mov    rsp,rbp
    212a:	pop    rbp
    212b:	ret
    212c:	add    BYTE PTR [rax],al
    212e:	add    BYTE PTR [rax],al
    2130:	(bad)
    2131:	add    BYTE PTR [rax],al
    2133:	add    BYTE PTR [rax],al
    2135:	add    BYTE PTR [rax],al
	...

0000000000002138 <botlish_entry_8: check<int, int, str, str>>:
    2138:	push   rbp
    2139:	mov    rbp,rsp
    213c:	mov    rsi,QWORD PTR [rdx]
    213f:	mov    r9,QWORD PTR [rdx+0x8]
    2143:	mov    rcx,QWORD PTR [rdx+0x10]
    2147:	mov    r8,QWORD PTR [rdx+0x18]
    214b:	mov    rdx,r9
    214e:	call   2153 <botlish_entry_8+0x1b>
			214f: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
    2153:	mov    rsp,rbp
    2156:	pop    rbp
    2157:	ret

0000000000002158 <botlish_fn_9: <str>>:
    2158:	push   rbp
    2159:	mov    rbp,rsp
    215c:	sub    rsp,0xf0
    2163:	mov    QWORD PTR [rsp+0xc0],rbx
    216b:	mov    QWORD PTR [rsp+0xc8],r12
    2173:	mov    QWORD PTR [rsp+0xd0],r13
    217b:	mov    QWORD PTR [rsp+0xd8],r14
    2183:	mov    QWORD PTR [rsp+0xe0],r15
    218b:	mov    rbx,QWORD PTR [rdi]
    218e:	mov    rax,QWORD PTR [rdi+0x8]
    2192:	lea    rcx,[rbx+0x8]
    2196:	cmp    rcx,rax
    2199:	ja     2649 <botlish_fn_9+0x4f1>
    219f:	lea    rax,[rbx+0x8]
    21a3:	mov    QWORD PTR [rdi],rax
    21a6:	mov    QWORD PTR [rsp+0xa0],rdi
    21ae:	mov    QWORD PTR [rbx],0x0
    21b5:	mov    QWORD PTR [rsp+0x10],0x0
    21be:	mov    QWORD PTR [rsp+0x18],0x0
    21c7:	mov    QWORD PTR [rsp+0x20],0x0
    21d0:	mov    QWORD PTR [rsp],rsi
    21d4:	mov    r12,rsi
    21d7:	mov    rsi,r12
    21da:	mov    rdi,QWORD PTR [rsp+0xa0]
    21e2:	call   21e7 <botlish_fn_9+0x8f>
			21e3: R_X86_64_PLT32	rt_str_len-0x4
    21e7:	mov    QWORD PTR [rsp+0xb0],rax
    21ef:	mov    QWORD PTR [rsp+0x8],rax
    21f4:	lea    r8,[rsp+0x28]
    21f9:	mov    QWORD PTR [rsp+0x28],r12
    21fe:	mov    esi,0xb
    2203:	mov    rdx,QWORD PTR [rip+0x0]        # 220a <botlish_fn_9+0xb2>
			2206: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    220a:	mov    r12d,0x1
    2210:	mov    rcx,r12
    2213:	mov    rdi,QWORD PTR [rsp+0xa0]
    221b:	call   2220 <botlish_fn_9+0xc8>
			221c: R_X86_64_PLT32	rt_closure_new-0x4
    2220:	mov    r15,rax
    2223:	mov    QWORD PTR [rsp],rax
    2227:	lea    r8,[rsp+0x30]
    222c:	mov    rax,QWORD PTR [rsp+0xb0]
    2234:	mov    QWORD PTR [rsp+0x30],rax
    2239:	mov    rax,r15
    223c:	mov    QWORD PTR [rsp+0x38],rax
    2241:	mov    esi,0xf
    2246:	mov    rdx,QWORD PTR [rip+0x0]        # 224d <botlish_fn_9+0xf5>
			2249: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_local<generic>
    224d:	mov    r14d,0x2
    2253:	mov    rcx,r14
    2256:	mov    rdi,QWORD PTR [rsp+0xa0]
    225e:	call   2263 <botlish_fn_9+0x10b>
			225f: R_X86_64_PLT32	rt_closure_new-0x4
    2263:	mov    r13,rax
    2266:	mov    QWORD PTR [rsp+0x10],r13
    226b:	lea    r8,[rsp+0x40]
    2270:	mov    rax,QWORD PTR [rsp+0xb0]
    2278:	mov    QWORD PTR [rsp+0x40],rax
    227d:	mov    rax,r15
    2280:	mov    QWORD PTR [rsp+0x48],rax
    2285:	mov    esi,0x10
    228a:	mov    rdx,QWORD PTR [rip+0x0]        # 2291 <botlish_fn_9+0x139>
			228d: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; scan_label<generic>
    2291:	mov    rcx,r14
    2294:	mov    rdi,QWORD PTR [rsp+0xa0]
    229c:	call   22a1 <botlish_fn_9+0x149>
			229d: R_X86_64_PLT32	rt_closure_new-0x4
    22a1:	mov    QWORD PTR [rsp+0x18],rax
    22a6:	mov    QWORD PTR [rsp+0xa8],rax
    22ae:	lea    r8,[rsp+0x50]
    22b3:	mov    rax,QWORD PTR [rsp+0xb0]
    22bb:	mov    QWORD PTR [rsp+0x50],rax
    22c0:	mov    QWORD PTR [rsp+0x58],r15
    22c5:	mov    esi,0x11
    22ca:	mov    rdx,QWORD PTR [rip+0x0]        # 22d1 <botlish_fn_9+0x179>
			22cd: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; scan_alpha<generic>
    22d1:	mov    rcx,r14
    22d4:	mov    rdi,QWORD PTR [rsp+0xa0]
    22dc:	call   22e1 <botlish_fn_9+0x189>
			22dd: R_X86_64_PLT32	rt_closure_new-0x4
    22e1:	mov    QWORD PTR [rsp+0x20],rax
    22e6:	lea    r8,[rsp+0x60]
    22eb:	mov    QWORD PTR [rsp+0x60],rax
    22f0:	mov    rax,QWORD PTR [rsp+0xb0]
    22f8:	mov    QWORD PTR [rsp+0x68],rax
    22fd:	mov    esi,0x12
    2302:	mov    rdx,QWORD PTR [rip+0x0]        # 2309 <botlish_fn_9+0x1b1>
			2305: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; tld_ok<generic>
    2309:	mov    rcx,r14
    230c:	mov    rdi,QWORD PTR [rsp+0xa0]
    2314:	call   2319 <botlish_fn_9+0x1c1>
			2315: R_X86_64_PLT32	rt_closure_new-0x4
    2319:	mov    QWORD PTR [rsp+0x20],rax
    231e:	lea    r8,[rsp+0x70]
    2323:	mov    rcx,QWORD PTR [rsp+0xa8]
    232b:	mov    QWORD PTR [rsp+0x70],rcx
    2330:	mov    rcx,QWORD PTR [rsp+0xb0]
    2338:	mov    QWORD PTR [rsp+0x78],rcx
    233d:	mov    QWORD PTR [rsp+0x80],r15
    2345:	mov    QWORD PTR [rsp+0x88],rax
    234d:	mov    esi,0x13
    2352:	mov    rdx,QWORD PTR [rip+0x0]        # 2359 <botlish_fn_9+0x201>
			2355: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; domain_loop<generic>
    2359:	mov    ecx,0x4
    235e:	mov    rdi,QWORD PTR [rsp+0xa0]
    2366:	call   236b <botlish_fn_9+0x213>
			2367: R_X86_64_PLT32	rt_closure_new-0x4
    236b:	mov    QWORD PTR [rsp+0x18],rax
    2370:	mov    r14,rax
    2373:	mov    QWORD PTR [rsp+0x20],0x1
    237c:	mov    rdx,r12
    237f:	mov    rsi,r13
    2382:	mov    rdi,QWORD PTR [rsp+0xa0]
    238a:	call   238f <botlish_fn_9+0x237>
			238b: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    238f:	mov    rcx,rax
    2392:	mov    r13,rax
    2395:	test   rax,rcx
    2398:	jne    23ab <botlish_fn_9+0x253>
    239e:	mov    rdi,QWORD PTR [rsp+0xa0]
    23a6:	jmp    2541 <botlish_fn_9+0x3e9>
    23ab:	mov    rax,r13
    23ae:	mov    QWORD PTR [rsp+0x10],rax
    23b3:	test   rax,0x1
    23b9:	jne    23ea <botlish_fn_9+0x292>
    23bf:	mov    edx,0x1
    23c4:	mov    rsi,r13
    23c7:	mov    rdi,QWORD PTR [rsp+0xa0]
    23cf:	call   23d4 <botlish_fn_9+0x27c>
			23d0: R_X86_64_PLT32	rt_int_cmp-0x4
    23d4:	mov    r11d,0x2
    23da:	test   rax,rax
    23dd:	cmove  r11,QWORD PTR [rip+0x2ab]        # 2690 <botlish_fn_9+0x538>
    23e5:	jmp    23fc <botlish_fn_9+0x2a4>
    23ea:	mov    r11d,0x2
    23f0:	cmp    r13,0x1
    23f4:	cmove  r11,QWORD PTR [rip+0x294]        # 2690 <botlish_fn_9+0x538>
    23fc:	cmp    r11,0x6
    2400:	je     25fd <botlish_fn_9+0x4a5>
    2406:	mov    r12,QWORD PTR [rsp+0xb0]
    240e:	mov    rax,r13
    2411:	and    rax,r12
    2414:	test   rax,0x1
    241a:	jne    2448 <botlish_fn_9+0x2f0>
    2420:	mov    rdx,r12
    2423:	mov    rsi,r13
    2426:	mov    rdi,QWORD PTR [rsp+0xa0]
    242e:	call   2433 <botlish_fn_9+0x2db>
			242f: R_X86_64_PLT32	rt_int_cmp-0x4
    2433:	mov    ecx,0x2
    2438:	test   rax,rax
    243b:	cmovge rcx,QWORD PTR [rip+0x24d]        # 2690 <botlish_fn_9+0x538>
    2443:	jmp    2458 <botlish_fn_9+0x300>
    2448:	mov    ecx,0x2
    244d:	cmp    r13,r12
    2450:	cmovge rcx,QWORD PTR [rip+0x238]        # 2690 <botlish_fn_9+0x538>
    2458:	cmp    rcx,0x6
    245c:	je     25eb <botlish_fn_9+0x493>
    2462:	lea    rcx,[rsp+0x90]
    246a:	mov    rsi,r15
    246d:	mov    rdx,r13
    2470:	mov    rdi,QWORD PTR [rsp+0xa0]
    2478:	call   247d <botlish_fn_9+0x325>
			2479: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    247d:	test   rax,rax
    2480:	mov    rsi,rax
    2483:	jne    2496 <botlish_fn_9+0x33e>
    2489:	mov    rdi,QWORD PTR [rsp+0xa0]
    2491:	jmp    2541 <botlish_fn_9+0x3e9>
    2496:	mov    rdx,QWORD PTR [rsp+0x90]
    249e:	mov    rcx,QWORD PTR [rsp+0x98]
    24a6:	mov    rdi,QWORD PTR [rsp+0xa0]
    24ae:	mov    rdi,QWORD PTR [rdi+0x10]
    24b2:	mov    r8,QWORD PTR [rdi+0x100]
    24b9:	mov    rdi,QWORD PTR [rsp+0xa0]
    24c1:	call   24c6 <botlish_fn_9+0x36e>
			24c2: R_X86_64_PLT32	rt_str_region_eq-0x4
    24c6:	cmp    rax,0x6
    24ca:	je     24dd <botlish_fn_9+0x385>
    24d0:	mov    ecx,0x2
    24d5:	mov    rax,rcx
    24d8:	jmp    25f0 <botlish_fn_9+0x498>
    24dd:	mov    QWORD PTR [rsp],0x3
    24e5:	test   r13,0x1
    24ec:	je     2504 <botlish_fn_9+0x3ac>
    24f2:	mov    rdx,r13
    24f5:	add    rdx,0x2
    24f9:	seto   al
    24fc:	test   al,al
    24fe:	je     251c <botlish_fn_9+0x3c4>
    2504:	mov    edx,0x3
    2509:	mov    rsi,r13
    250c:	mov    rdi,QWORD PTR [rsp+0xa0]
    2514:	call   2519 <botlish_fn_9+0x3c1>
			2515: R_X86_64_PLT32	rt_int_add-0x4
    2519:	mov    rdx,rax
    251c:	mov    QWORD PTR [rsp],rdx
    2520:	mov    rsi,r14
    2523:	mov    rdi,QWORD PTR [rsp+0xa0]
    252b:	call   2530 <botlish_fn_9+0x3d8>
			252c: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    2530:	test   rax,rax
    2533:	jne    2583 <botlish_fn_9+0x42b>
    2539:	mov    rdi,QWORD PTR [rsp+0xa0]
    2541:	mov    rdi,QWORD PTR [rsp+0xa0]
    2549:	mov    QWORD PTR [rdi],rbx
    254c:	xor    rax,rax
    254f:	mov    rbx,QWORD PTR [rsp+0xc0]
    2557:	mov    r12,QWORD PTR [rsp+0xc8]
    255f:	mov    r13,QWORD PTR [rsp+0xd0]
    2567:	mov    r14,QWORD PTR [rsp+0xd8]
    256f:	mov    r15,QWORD PTR [rsp+0xe0]
    2577:	add    rsp,0xf0
    257e:	mov    rsp,rbp
    2581:	pop    rbp
    2582:	ret
    2583:	mov    rcx,rax
    2586:	and    rcx,r12
    2589:	mov    rsi,rax
    258c:	mov    QWORD PTR [rsp+0xb0],r12
    2594:	test   rcx,0x1
    259b:	jne    25ce <botlish_fn_9+0x476>
    25a1:	mov    rdx,QWORD PTR [rsp+0xb0]
    25a9:	mov    rdi,QWORD PTR [rsp+0xa0]
    25b1:	call   25b6 <botlish_fn_9+0x45e>
			25b2: R_X86_64_PLT32	rt_int_cmp-0x4
    25b6:	mov    ecx,0x2
    25bb:	test   rax,rax
    25be:	mov    rax,rcx
    25c1:	cmove  rax,QWORD PTR [rip+0xc7]        # 2690 <botlish_fn_9+0x538>
    25c9:	jmp    25f0 <botlish_fn_9+0x498>
    25ce:	mov    rdx,QWORD PTR [rsp+0xb0]
    25d6:	mov    eax,0x2
    25db:	cmp    rsi,rdx
    25de:	cmove  rax,QWORD PTR [rip+0xaa]        # 2690 <botlish_fn_9+0x538>
    25e6:	jmp    25f0 <botlish_fn_9+0x498>
    25eb:	mov    eax,0x2
    25f0:	mov    rdi,QWORD PTR [rsp+0xa0]
    25f8:	jmp    260a <botlish_fn_9+0x4b2>
    25fd:	mov    eax,0x2
    2602:	mov    rdi,QWORD PTR [rsp+0xa0]
    260a:	mov    rdi,QWORD PTR [rsp+0xa0]
    2612:	mov    QWORD PTR [rdi],rbx
    2615:	mov    rbx,QWORD PTR [rsp+0xc0]
    261d:	mov    r12,QWORD PTR [rsp+0xc8]
    2625:	mov    r13,QWORD PTR [rsp+0xd0]
    262d:	mov    r14,QWORD PTR [rsp+0xd8]
    2635:	mov    r15,QWORD PTR [rsp+0xe0]
    263d:	add    rsp,0xf0
    2644:	mov    rsp,rbp
    2647:	pop    rbp
    2648:	ret
    2649:	mov    QWORD PTR [rsp+0xa0],rdi
    2651:	call   2656 <botlish_fn_9+0x4fe>
			2652: R_X86_64_PLT32	rt_stack_overflow-0x4
    2656:	xor    rax,rax
    2659:	mov    rbx,QWORD PTR [rsp+0xc0]
    2661:	mov    r12,QWORD PTR [rsp+0xc8]
    2669:	mov    r13,QWORD PTR [rsp+0xd0]
    2671:	mov    r14,QWORD PTR [rsp+0xd8]
    2679:	mov    r15,QWORD PTR [rsp+0xe0]
    2681:	add    rsp,0xf0
    2688:	mov    rsp,rbp
    268b:	pop    rbp
    268c:	ret
    268d:	add    BYTE PTR [rax],al
    268f:	add    BYTE PTR [rsi],al
    2691:	add    BYTE PTR [rax],al
    2693:	add    BYTE PTR [rax],al
    2695:	add    BYTE PTR [rax],al
	...

0000000000002698 <botlish_entry_9: <str>>:
    2698:	push   rbp
    2699:	mov    rbp,rsp
    269c:	mov    rsi,QWORD PTR [rdx]
    269f:	call   26a4 <botlish_entry_9+0xc>
			26a0: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    26a4:	mov    rsp,rbp
    26a7:	pop    rbp
    26a8:	ret
    26a9:	add    BYTE PTR [rax],al
    26ab:	add    BYTE PTR [rax],al
    26ad:	add    BYTE PTR [rax],al
	...

00000000000026b0 <botlish_fn_10: <generic>>:
    26b0:	push   rbp
    26b1:	mov    rbp,rsp
    26b4:	sub    rsp,0xf0
    26bb:	mov    QWORD PTR [rsp+0xc0],rbx
    26c3:	mov    QWORD PTR [rsp+0xc8],r12
    26cb:	mov    QWORD PTR [rsp+0xd0],r13
    26d3:	mov    QWORD PTR [rsp+0xd8],r14
    26db:	mov    QWORD PTR [rsp+0xe0],r15
    26e3:	mov    rbx,QWORD PTR [rdi]
    26e6:	mov    rax,QWORD PTR [rdi+0x8]
    26ea:	lea    rcx,[rbx+0x8]
    26ee:	cmp    rcx,rax
    26f1:	ja     2b78 <botlish_fn_10+0x4c8>
    26f7:	lea    rax,[rbx+0x8]
    26fb:	mov    QWORD PTR [rdi],rax
    26fe:	mov    QWORD PTR [rbx],0x0
    2705:	mov    QWORD PTR [rsp+0x10],0x0
    270e:	mov    QWORD PTR [rsp+0x18],0x0
    2717:	mov    QWORD PTR [rsp+0x20],0x0
    2720:	mov    QWORD PTR [rsp],rsi
    2724:	xor    eax,eax
    2726:	test   rsi,0x7
    272d:	jne    273c <botlish_fn_10+0x8c>
    2733:	movzx  rax,BYTE PTR [rsi]
    2737:	cmp    al,0x2
    2739:	sete   al
    273c:	test   al,al
    273e:	jne    2764 <botlish_fn_10+0xb4>
    2744:	mov    rax,QWORD PTR [rdi+0x10]
    2748:	mov    r15,rdi
    274b:	mov    rcx,QWORD PTR [rax+0xd8]
    2752:	mov    edx,0x1
    2757:	call   275c <botlish_fn_10+0xac>
			2758: R_X86_64_PLT32	rt_type_error-0x4
    275c:	mov    rdi,r15
    275f:	jmp    2a89 <botlish_fn_10+0x3d9>
    2764:	mov    r12,rsi
    2767:	mov    r15,rdi
    276a:	call   276f <botlish_fn_10+0xbf>
			276b: R_X86_64_PLT32	rt_str_len-0x4
    276f:	mov    QWORD PTR [rsp+0xb0],rax
    2777:	mov    QWORD PTR [rsp+0x8],rax
    277c:	lea    r8,[rsp+0x28]
    2781:	mov    QWORD PTR [rsp+0x28],r12
    2786:	mov    esi,0xb
    278b:	mov    rdx,QWORD PTR [rip+0x0]        # 2792 <botlish_fn_10+0xe2>
			278e: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    2792:	mov    r12d,0x1
    2798:	mov    rcx,r12
    279b:	mov    rdi,r15
    279e:	call   27a3 <botlish_fn_10+0xf3>
			279f: R_X86_64_PLT32	rt_closure_new-0x4
    27a3:	mov    r14,rax
    27a6:	mov    QWORD PTR [rsp+0xa8],r12
    27ae:	mov    QWORD PTR [rsp],rax
    27b2:	lea    r8,[rsp+0x30]
    27b7:	mov    rax,QWORD PTR [rsp+0xb0]
    27bf:	mov    QWORD PTR [rsp+0x30],rax
    27c4:	mov    rax,r14
    27c7:	mov    QWORD PTR [rsp+0x38],rax
    27cc:	mov    esi,0xf
    27d1:	mov    rdx,QWORD PTR [rip+0x0]        # 27d8 <botlish_fn_10+0x128>
			27d4: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_local<generic>
    27d8:	mov    r13d,0x2
    27de:	mov    rcx,r13
    27e1:	mov    rdi,r15
    27e4:	call   27e9 <botlish_fn_10+0x139>
			27e5: R_X86_64_PLT32	rt_closure_new-0x4
    27e9:	mov    r12,rax
    27ec:	mov    QWORD PTR [rsp+0x10],r12
    27f1:	lea    r8,[rsp+0x40]
    27f6:	mov    rax,QWORD PTR [rsp+0xb0]
    27fe:	mov    QWORD PTR [rsp+0x40],rax
    2803:	mov    rax,r14
    2806:	mov    QWORD PTR [rsp+0x48],rax
    280b:	mov    esi,0x10
    2810:	mov    rdx,QWORD PTR [rip+0x0]        # 2817 <botlish_fn_10+0x167>
			2813: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; scan_label<generic>
    2817:	mov    rcx,r13
    281a:	mov    rdi,r15
    281d:	call   2822 <botlish_fn_10+0x172>
			281e: R_X86_64_PLT32	rt_closure_new-0x4
    2822:	mov    QWORD PTR [rsp+0x18],rax
    2827:	mov    QWORD PTR [rsp+0xa0],rax
    282f:	lea    r8,[rsp+0x50]
    2834:	mov    rax,QWORD PTR [rsp+0xb0]
    283c:	mov    QWORD PTR [rsp+0x50],rax
    2841:	mov    QWORD PTR [rsp+0x58],r14
    2846:	mov    esi,0x11
    284b:	mov    rdx,QWORD PTR [rip+0x0]        # 2852 <botlish_fn_10+0x1a2>
			284e: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; scan_alpha<generic>
    2852:	mov    rcx,r13
    2855:	mov    rdi,r15
    2858:	call   285d <botlish_fn_10+0x1ad>
			2859: R_X86_64_PLT32	rt_closure_new-0x4
    285d:	mov    QWORD PTR [rsp+0x20],rax
    2862:	lea    r8,[rsp+0x60]
    2867:	mov    QWORD PTR [rsp+0x60],rax
    286c:	mov    rax,QWORD PTR [rsp+0xb0]
    2874:	mov    QWORD PTR [rsp+0x68],rax
    2879:	mov    esi,0x12
    287e:	mov    rdx,QWORD PTR [rip+0x0]        # 2885 <botlish_fn_10+0x1d5>
			2881: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; tld_ok<generic>
    2885:	mov    rcx,r13
    2888:	mov    rdi,r15
    288b:	call   2890 <botlish_fn_10+0x1e0>
			288c: R_X86_64_PLT32	rt_closure_new-0x4
    2890:	mov    QWORD PTR [rsp+0x20],rax
    2895:	lea    r8,[rsp+0x70]
    289a:	mov    rsi,QWORD PTR [rsp+0xa0]
    28a2:	mov    QWORD PTR [rsp+0x70],rsi
    28a7:	mov    rcx,QWORD PTR [rsp+0xb0]
    28af:	mov    QWORD PTR [rsp+0x78],rcx
    28b4:	mov    QWORD PTR [rsp+0x80],r14
    28bc:	mov    QWORD PTR [rsp+0x88],rax
    28c4:	mov    esi,0x13
    28c9:	mov    rdx,QWORD PTR [rip+0x0]        # 28d0 <botlish_fn_10+0x220>
			28cc: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; domain_loop<generic>
    28d0:	mov    ecx,0x4
    28d5:	mov    rdi,r15
    28d8:	call   28dd <botlish_fn_10+0x22d>
			28d9: R_X86_64_PLT32	rt_closure_new-0x4
    28dd:	mov    QWORD PTR [rsp+0x18],rax
    28e2:	mov    QWORD PTR [rsp+0xa0],rax
    28ea:	mov    QWORD PTR [rsp+0x20],0x1
    28f3:	mov    rsi,r12
    28f6:	mov    rdx,QWORD PTR [rsp+0xa8]
    28fe:	mov    rdi,r15
    2901:	call   2906 <botlish_fn_10+0x256>
			2902: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    2906:	mov    rcx,rax
    2909:	mov    r12,rax
    290c:	test   rax,rcx
    290f:	jne    291d <botlish_fn_10+0x26d>
    2915:	mov    rdi,r15
    2918:	jmp    2a89 <botlish_fn_10+0x3d9>
    291d:	mov    rax,r12
    2920:	mov    QWORD PTR [rsp+0x10],rax
    2925:	test   rax,0x1
    292b:	jne    2959 <botlish_fn_10+0x2a9>
    2931:	mov    rdx,QWORD PTR [rsp+0xa8]
    2939:	mov    rsi,r12
    293c:	mov    rdi,r15
    293f:	call   2944 <botlish_fn_10+0x294>
			2940: R_X86_64_PLT32	rt_int_cmp-0x4
    2944:	mov    ecx,0x2
    2949:	test   rax,rax
    294c:	cmove  rcx,QWORD PTR [rip+0x264]        # 2bb8 <botlish_fn_10+0x508>
    2954:	jmp    296a <botlish_fn_10+0x2ba>
    2959:	mov    ecx,0x2
    295e:	cmp    r12,0x1
    2962:	cmove  rcx,QWORD PTR [rip+0x24e]        # 2bb8 <botlish_fn_10+0x508>
    296a:	cmp    rcx,0x6
    296e:	je     2b36 <botlish_fn_10+0x486>
    2974:	mov    r13,QWORD PTR [rsp+0xb0]
    297c:	mov    rax,r12
    297f:	and    rax,r13
    2982:	test   rax,0x1
    2988:	jne    29b1 <botlish_fn_10+0x301>
    298e:	mov    rdx,r13
    2991:	mov    rsi,r12
    2994:	mov    rdi,r15
    2997:	call   299c <botlish_fn_10+0x2ec>
			2998: R_X86_64_PLT32	rt_int_cmp-0x4
    299c:	mov    ecx,0x2
    29a1:	test   rax,rax
    29a4:	cmovge rcx,QWORD PTR [rip+0x20c]        # 2bb8 <botlish_fn_10+0x508>
    29ac:	jmp    29c1 <botlish_fn_10+0x311>
    29b1:	mov    ecx,0x2
    29b6:	cmp    r12,r13
    29b9:	cmovge rcx,QWORD PTR [rip+0x1f7]        # 2bb8 <botlish_fn_10+0x508>
    29c1:	cmp    rcx,0x6
    29c5:	je     2b29 <botlish_fn_10+0x479>
    29cb:	lea    rcx,[rsp+0x90]
    29d3:	mov    rsi,r14
    29d6:	mov    rdx,r12
    29d9:	mov    rdi,r15
    29dc:	call   29e1 <botlish_fn_10+0x331>
			29dd: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    29e1:	test   rax,rax
    29e4:	mov    rsi,rax
    29e7:	jne    29f5 <botlish_fn_10+0x345>
    29ed:	mov    rdi,r15
    29f0:	jmp    2a89 <botlish_fn_10+0x3d9>
    29f5:	mov    rdx,QWORD PTR [rsp+0x90]
    29fd:	mov    rcx,QWORD PTR [rsp+0x98]
    2a05:	mov    rdi,r15
    2a08:	mov    rax,QWORD PTR [rdi+0x10]
    2a0c:	mov    r8,QWORD PTR [rax+0x100]
    2a13:	call   2a18 <botlish_fn_10+0x368>
			2a14: R_X86_64_PLT32	rt_str_region_eq-0x4
    2a18:	cmp    rax,0x6
    2a1c:	je     2a2f <botlish_fn_10+0x37f>
    2a22:	mov    esi,0x2
    2a27:	mov    rax,rsi
    2a2a:	jmp    2b2e <botlish_fn_10+0x47e>
    2a2f:	mov    QWORD PTR [rsp],0x3
    2a37:	test   r12,0x1
    2a3e:	je     2a56 <botlish_fn_10+0x3a6>
    2a44:	mov    rdx,r12
    2a47:	add    rdx,0x2
    2a4b:	seto   al
    2a4e:	test   al,al
    2a50:	je     2a69 <botlish_fn_10+0x3b9>
    2a56:	mov    edx,0x3
    2a5b:	mov    rsi,r12
    2a5e:	mov    rdi,r15
    2a61:	call   2a66 <botlish_fn_10+0x3b6>
			2a62: R_X86_64_PLT32	rt_int_add-0x4
    2a66:	mov    rdx,rax
    2a69:	mov    QWORD PTR [rsp],rdx
    2a6d:	mov    rsi,QWORD PTR [rsp+0xa0]
    2a75:	mov    rdi,r15
    2a78:	call   2a7d <botlish_fn_10+0x3cd>
			2a79: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    2a7d:	test   rax,rax
    2a80:	jne    2ac6 <botlish_fn_10+0x416>
    2a86:	mov    rdi,r15
    2a89:	mov    rdi,r15
    2a8c:	mov    QWORD PTR [rdi],rbx
    2a8f:	xor    rax,rax
    2a92:	mov    rbx,QWORD PTR [rsp+0xc0]
    2a9a:	mov    r12,QWORD PTR [rsp+0xc8]
    2aa2:	mov    r13,QWORD PTR [rsp+0xd0]
    2aaa:	mov    r14,QWORD PTR [rsp+0xd8]
    2ab2:	mov    r15,QWORD PTR [rsp+0xe0]
    2aba:	add    rsp,0xf0
    2ac1:	mov    rsp,rbp
    2ac4:	pop    rbp
    2ac5:	ret
    2ac6:	mov    rcx,rax
    2ac9:	and    rcx,r13
    2acc:	mov    rsi,rax
    2acf:	mov    QWORD PTR [rsp+0xb0],r13
    2ad7:	test   rcx,0x1
    2ade:	jne    2b0c <botlish_fn_10+0x45c>
    2ae4:	mov    rdx,QWORD PTR [rsp+0xb0]
    2aec:	mov    rdi,r15
    2aef:	call   2af4 <botlish_fn_10+0x444>
			2af0: R_X86_64_PLT32	rt_int_cmp-0x4
    2af4:	mov    esi,0x2
    2af9:	test   rax,rax
    2afc:	mov    rax,rsi
    2aff:	cmove  rax,QWORD PTR [rip+0xb1]        # 2bb8 <botlish_fn_10+0x508>
    2b07:	jmp    2b2e <botlish_fn_10+0x47e>
    2b0c:	mov    rdx,QWORD PTR [rsp+0xb0]
    2b14:	mov    eax,0x2
    2b19:	cmp    rsi,rdx
    2b1c:	cmove  rax,QWORD PTR [rip+0x94]        # 2bb8 <botlish_fn_10+0x508>
    2b24:	jmp    2b2e <botlish_fn_10+0x47e>
    2b29:	mov    eax,0x2
    2b2e:	mov    rdi,r15
    2b31:	jmp    2b3e <botlish_fn_10+0x48e>
    2b36:	mov    eax,0x2
    2b3b:	mov    rdi,r15
    2b3e:	mov    rdi,r15
    2b41:	mov    QWORD PTR [rdi],rbx
    2b44:	mov    rbx,QWORD PTR [rsp+0xc0]
    2b4c:	mov    r12,QWORD PTR [rsp+0xc8]
    2b54:	mov    r13,QWORD PTR [rsp+0xd0]
    2b5c:	mov    r14,QWORD PTR [rsp+0xd8]
    2b64:	mov    r15,QWORD PTR [rsp+0xe0]
    2b6c:	add    rsp,0xf0
    2b73:	mov    rsp,rbp
    2b76:	pop    rbp
    2b77:	ret
    2b78:	mov    r15,rdi
    2b7b:	call   2b80 <botlish_fn_10+0x4d0>
			2b7c: R_X86_64_PLT32	rt_stack_overflow-0x4
    2b80:	xor    rax,rax
    2b83:	mov    rbx,QWORD PTR [rsp+0xc0]
    2b8b:	mov    r12,QWORD PTR [rsp+0xc8]
    2b93:	mov    r13,QWORD PTR [rsp+0xd0]
    2b9b:	mov    r14,QWORD PTR [rsp+0xd8]
    2ba3:	mov    r15,QWORD PTR [rsp+0xe0]
    2bab:	add    rsp,0xf0
    2bb2:	mov    rsp,rbp
    2bb5:	pop    rbp
    2bb6:	ret
    2bb7:	add    BYTE PTR [rsi],al
    2bb9:	add    BYTE PTR [rax],al
    2bbb:	add    BYTE PTR [rax],al
    2bbd:	add    BYTE PTR [rax],al
	...

0000000000002bc0 <botlish_entry_10: <generic>>:
    2bc0:	push   rbp
    2bc1:	mov    rbp,rsp
    2bc4:	mov    rsi,QWORD PTR [rdx]
    2bc7:	call   2bcc <botlish_entry_10+0xc>
			2bc8: R_X86_64_PLT32	botlish_fn_10-0x4 ; <generic>
    2bcc:	mov    rsp,rbp
    2bcf:	pop    rbp
    2bd0:	ret

0000000000002bd1 <botlish_fn_11: char_at<generic>>:
    2bd1:	push   rbp
    2bd2:	mov    rbp,rsp
    2bd5:	sub    rsp,0x40
    2bd9:	mov    QWORD PTR [rsp+0x20],rbx
    2bde:	mov    QWORD PTR [rsp+0x28],r12
    2be3:	mov    QWORD PTR [rsp+0x30],r13
    2be8:	mov    QWORD PTR [rsp],rdx
    2bec:	mov    rax,QWORD PTR [rsi+0x20]
    2bf0:	mov    rsi,QWORD PTR [rax]
    2bf3:	mov    QWORD PTR [rsp+0x8],rsi
    2bf8:	mov    r13,rsi
    2bfb:	mov    QWORD PTR [rsp+0x10],0x3
    2c04:	mov    r10d,0x1
    2c0a:	test   rdx,0x1
    2c11:	je     2c1f <botlish_fn_11+0x4e>
    2c17:	mov    rbx,rdx
    2c1a:	jmp    2c44 <botlish_fn_11+0x73>
    2c1f:	xor    r10d,r10d
    2c22:	test   rdx,0x7
    2c29:	je     2c37 <botlish_fn_11+0x66>
    2c2f:	mov    rbx,rdx
    2c32:	jmp    2c44 <botlish_fn_11+0x73>
    2c37:	movzx  rax,BYTE PTR [rdx]
    2c3b:	mov    rbx,rdx
    2c3e:	cmp    al,0x1
    2c40:	sete   r10b
    2c44:	test   r10b,r10b
    2c47:	jne    2c68 <botlish_fn_11+0x97>
    2c4d:	mov    rax,QWORD PTR [rdi+0x10]
    2c51:	mov    rcx,QWORD PTR [rax+0x108]
    2c58:	xor    rdx,rdx
    2c5b:	mov    rsi,rbx
    2c5e:	call   2c63 <botlish_fn_11+0x92>
			2c5f: R_X86_64_PLT32	rt_type_error-0x4
    2c63:	jmp    2d1a <botlish_fn_11+0x149>
    2c68:	mov    rsi,rbx
    2c6b:	mov    r12,rdi
    2c6e:	test   rsi,0x1
    2c75:	je     2c90 <botlish_fn_11+0xbf>
    2c7b:	mov    rsi,rbx
    2c7e:	mov    rcx,rsi
    2c81:	add    rcx,0x2
    2c85:	seto   al
    2c88:	test   al,al
    2c8a:	je     2ca3 <botlish_fn_11+0xd2>
    2c90:	mov    edx,0x3
    2c95:	mov    rsi,rbx
    2c98:	mov    rdi,r12
    2c9b:	call   2ca0 <botlish_fn_11+0xcf>
			2c9c: R_X86_64_PLT32	rt_int_add-0x4
    2ca0:	mov    rcx,rax
    2ca3:	mov    QWORD PTR [rsp+0x10],rcx
    2ca8:	mov    eax,0x1
    2cad:	mov    rsi,rbx
    2cb0:	test   rsi,0x1
    2cb7:	jne    2cdd <botlish_fn_11+0x10c>
    2cbd:	xor    eax,eax
    2cbf:	mov    rsi,rbx
    2cc2:	test   rsi,0x7
    2cc9:	jne    2cdd <botlish_fn_11+0x10c>
    2ccf:	mov    rsi,rbx
    2cd2:	movzx  rdx,BYTE PTR [rsi]
    2cd6:	rex cmp dl,0x1
    2cda:	sete   al
    2cdd:	test   al,al
    2cdf:	jne    2d03 <botlish_fn_11+0x132>
    2ce5:	mov    rdi,r12
    2ce8:	mov    rsi,QWORD PTR [rdi+0x10]
    2cec:	mov    rcx,QWORD PTR [rsi+0x110]
    2cf3:	xor    rdx,rdx
    2cf6:	mov    rsi,rbx
    2cf9:	call   2cfe <botlish_fn_11+0x12d>
			2cfa: R_X86_64_PLT32	rt_type_error-0x4
    2cfe:	jmp    2d1a <botlish_fn_11+0x149>
    2d03:	mov    rdx,rbx
    2d06:	mov    rsi,r13
    2d09:	mov    rdi,r12
    2d0c:	call   2d11 <botlish_fn_11+0x140>
			2d0d: R_X86_64_PLT32	rt_substr-0x4
    2d11:	test   rax,rax
    2d14:	jne    2d35 <botlish_fn_11+0x164>
    2d1a:	xor    rax,rax
    2d1d:	mov    rbx,QWORD PTR [rsp+0x20]
    2d22:	mov    r12,QWORD PTR [rsp+0x28]
    2d27:	mov    r13,QWORD PTR [rsp+0x30]
    2d2c:	add    rsp,0x40
    2d30:	mov    rsp,rbp
    2d33:	pop    rbp
    2d34:	ret
    2d35:	mov    rbx,QWORD PTR [rsp+0x20]
    2d3a:	mov    r12,QWORD PTR [rsp+0x28]
    2d3f:	mov    r13,QWORD PTR [rsp+0x30]
    2d44:	add    rsp,0x40
    2d48:	mov    rsp,rbp
    2d4b:	pop    rbp
    2d4c:	ret

0000000000002d4d <botlish_entry_11: char_at<generic>>:
    2d4d:	push   rbp
    2d4e:	mov    rbp,rsp
    2d51:	mov    rdx,QWORD PTR [rdx]
    2d54:	call   2d59 <botlish_entry_11+0xc>
			2d55: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2d59:	mov    rsp,rbp
    2d5c:	pop    rbp
    2d5d:	ret

0000000000002d5e <botlish_fn_12: char_at<generic>>:
    2d5e:	push   rbp
    2d5f:	mov    rbp,rsp
    2d62:	sub    rsp,0x40
    2d66:	mov    QWORD PTR [rsp+0x20],rbx
    2d6b:	mov    QWORD PTR [rsp+0x28],r12
    2d70:	mov    QWORD PTR [rsp+0x30],r13
    2d75:	mov    QWORD PTR [rsp+0x38],r14
    2d7a:	mov    r13,rcx
    2d7d:	mov    QWORD PTR [rsp],rdx
    2d81:	mov    rax,QWORD PTR [rsi+0x20]
    2d85:	mov    rax,QWORD PTR [rax]
    2d88:	mov    QWORD PTR [rsp+0x8],rax
    2d8d:	mov    r14,rax
    2d90:	mov    QWORD PTR [rsp+0x10],0x3
    2d99:	mov    r11d,0x1
    2d9f:	test   rdx,0x1
    2da6:	je     2db4 <botlish_fn_12+0x56>
    2dac:	mov    r12,rdx
    2daf:	jmp    2dd9 <botlish_fn_12+0x7b>
    2db4:	xor    r11d,r11d
    2db7:	test   rdx,0x7
    2dbe:	je     2dcc <botlish_fn_12+0x6e>
    2dc4:	mov    r12,rdx
    2dc7:	jmp    2dd9 <botlish_fn_12+0x7b>
    2dcc:	movzx  rax,BYTE PTR [rdx]
    2dd0:	mov    r12,rdx
    2dd3:	cmp    al,0x1
    2dd5:	sete   r11b
    2dd9:	test   r11b,r11b
    2ddc:	jne    2dfd <botlish_fn_12+0x9f>
    2de2:	mov    rax,QWORD PTR [rdi+0x10]
    2de6:	mov    rcx,QWORD PTR [rax+0x108]
    2ded:	xor    rdx,rdx
    2df0:	mov    rsi,r12
    2df3:	call   2df8 <botlish_fn_12+0x9a>
			2df4: R_X86_64_PLT32	rt_type_error-0x4
    2df8:	jmp    2eb5 <botlish_fn_12+0x157>
    2dfd:	mov    rbx,rdi
    2e00:	mov    rsi,r12
    2e03:	test   rsi,0x1
    2e0a:	jne    2e18 <botlish_fn_12+0xba>
    2e10:	mov    r12,rsi
    2e13:	jmp    2e2d <botlish_fn_12+0xcf>
    2e18:	mov    rax,rsi
    2e1b:	add    rax,0x2
    2e1f:	mov    r12,rsi
    2e22:	seto   cl
    2e25:	test   cl,cl
    2e27:	je     2e3d <botlish_fn_12+0xdf>
    2e2d:	mov    edx,0x3
    2e32:	mov    rsi,r12
    2e35:	mov    rdi,rbx
    2e38:	call   2e3d <botlish_fn_12+0xdf>
			2e39: R_X86_64_PLT32	rt_int_add-0x4
    2e3d:	mov    ecx,0x1
    2e42:	mov    rsi,r12
    2e45:	test   rsi,0x1
    2e4c:	jne    2e72 <botlish_fn_12+0x114>
    2e52:	xor    ecx,ecx
    2e54:	mov    rsi,r12
    2e57:	test   rsi,0x7
    2e5e:	jne    2e72 <botlish_fn_12+0x114>
    2e64:	mov    rsi,r12
    2e67:	movzx  rdx,BYTE PTR [rsi]
    2e6b:	rex cmp dl,0x1
    2e6f:	sete   cl
    2e72:	test   cl,cl
    2e74:	jne    2e98 <botlish_fn_12+0x13a>
    2e7a:	mov    rdi,rbx
    2e7d:	mov    rsi,QWORD PTR [rdi+0x10]
    2e81:	mov    rcx,QWORD PTR [rsi+0x110]
    2e88:	xor    rdx,rdx
    2e8b:	mov    rsi,r12
    2e8e:	call   2e93 <botlish_fn_12+0x135>
			2e8f: R_X86_64_PLT32	rt_type_error-0x4
    2e93:	jmp    2eb5 <botlish_fn_12+0x157>
    2e98:	mov    rdi,rbx
    2e9b:	mov    rbx,rax
    2e9e:	mov    rcx,rbx
    2ea1:	mov    rdx,r12
    2ea4:	mov    rsi,r14
    2ea7:	call   2eac <botlish_fn_12+0x14e>
			2ea8: R_X86_64_PLT32	rt_str_region_check-0x4
    2eac:	test   rax,rax
    2eaf:	jne    2ed5 <botlish_fn_12+0x177>
    2eb5:	xor    rax,rax
    2eb8:	mov    rbx,QWORD PTR [rsp+0x20]
    2ebd:	mov    r12,QWORD PTR [rsp+0x28]
    2ec2:	mov    r13,QWORD PTR [rsp+0x30]
    2ec7:	mov    r14,QWORD PTR [rsp+0x38]
    2ecc:	add    rsp,0x40
    2ed0:	mov    rsp,rbp
    2ed3:	pop    rbp
    2ed4:	ret
    2ed5:	mov    rcx,r13
    2ed8:	mov    rsi,r12
    2edb:	mov    QWORD PTR [rcx],rsi
    2ede:	mov    QWORD PTR [rcx+0x8],rbx
    2ee2:	mov    rax,r14
    2ee5:	mov    rbx,QWORD PTR [rsp+0x20]
    2eea:	mov    r12,QWORD PTR [rsp+0x28]
    2eef:	mov    r13,QWORD PTR [rsp+0x30]
    2ef4:	mov    r14,QWORD PTR [rsp+0x38]
    2ef9:	add    rsp,0x40
    2efd:	mov    rsp,rbp
    2f00:	pop    rbp
    2f01:	ret

0000000000002f02 <botlish_entry_12: char_at<generic>>:
    2f02:	push   rbp
    2f03:	mov    rbp,rsp
    2f06:	ud2

0000000000002f08 <botlish_fn_13: is_local_char<str>>:
    2f08:	push   rbp
    2f09:	mov    rbp,rsp
    2f0c:	sub    rsp,0x10
    2f10:	mov    QWORD PTR [rsp],rbx
    2f14:	mov    QWORD PTR [rsp+0x8],r12
    2f19:	mov    rbx,rsi
    2f1c:	mov    r12,rdi
    2f1f:	mov    rsi,rbx
    2f22:	mov    rdi,r12
    2f25:	call   2f2a <botlish_fn_13+0x22>
			2f26: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    2f2a:	test   rax,rax
    2f2d:	jne    2f48 <botlish_fn_13+0x40>
    2f33:	xor    rax,rax
    2f36:	mov    rbx,QWORD PTR [rsp]
    2f3a:	mov    r12,QWORD PTR [rsp+0x8]
    2f3f:	add    rsp,0x10
    2f43:	mov    rsp,rbp
    2f46:	pop    rbp
    2f47:	ret
    2f48:	cmp    rax,0x6
    2f4c:	je     3047 <botlish_fn_13+0x13f>
    2f52:	mov    rdi,r12
    2f55:	mov    rax,QWORD PTR [rdi+0x10]
    2f59:	mov    rsi,QWORD PTR [rax+0x118]
    2f60:	mov    edx,0x1
    2f65:	mov    ecx,0x3
    2f6a:	mov    r8,rbx
    2f6d:	call   2f72 <botlish_fn_13+0x6a>
			2f6e: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f72:	cmp    rax,0x6
    2f76:	je     303d <botlish_fn_13+0x135>
    2f7c:	mov    rdi,r12
    2f7f:	mov    rax,QWORD PTR [rdi+0x10]
    2f83:	mov    rsi,QWORD PTR [rax+0x120]
    2f8a:	mov    edx,0x1
    2f8f:	mov    ecx,0x3
    2f94:	mov    r8,rbx
    2f97:	call   2f9c <botlish_fn_13+0x94>
			2f98: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f9c:	cmp    rax,0x6
    2fa0:	je     3033 <botlish_fn_13+0x12b>
    2fa6:	mov    rdi,r12
    2fa9:	mov    rax,QWORD PTR [rdi+0x10]
    2fad:	mov    rsi,QWORD PTR [rax+0xc0]
    2fb4:	mov    edx,0x1
    2fb9:	mov    ecx,0x3
    2fbe:	mov    r8,rbx
    2fc1:	call   2fc6 <botlish_fn_13+0xbe>
			2fc2: R_X86_64_PLT32	rt_str_region_eq-0x4
    2fc6:	cmp    rax,0x6
    2fca:	je     3029 <botlish_fn_13+0x121>
    2fd0:	mov    rdi,r12
    2fd3:	mov    rax,QWORD PTR [rdi+0x10]
    2fd7:	mov    rsi,QWORD PTR [rax+0x108]
    2fde:	mov    edx,0x1
    2fe3:	mov    ecx,0x3
    2fe8:	mov    r8,rbx
    2feb:	call   2ff0 <botlish_fn_13+0xe8>
			2fec: R_X86_64_PLT32	rt_str_region_eq-0x4
    2ff0:	cmp    rax,0x6
    2ff4:	je     301f <botlish_fn_13+0x117>
    2ffa:	mov    rdi,r12
    2ffd:	mov    rax,QWORD PTR [rdi+0x10]
    3001:	mov    rsi,QWORD PTR [rax+0x128]
    3008:	mov    edx,0x1
    300d:	mov    ecx,0x3
    3012:	mov    r8,rbx
    3015:	call   301a <botlish_fn_13+0x112>
			3016: R_X86_64_PLT32	rt_str_region_eq-0x4
    301a:	jmp    304c <botlish_fn_13+0x144>
    301f:	mov    eax,0x6
    3024:	jmp    304c <botlish_fn_13+0x144>
    3029:	mov    eax,0x6
    302e:	jmp    304c <botlish_fn_13+0x144>
    3033:	mov    eax,0x6
    3038:	jmp    304c <botlish_fn_13+0x144>
    303d:	mov    eax,0x6
    3042:	jmp    304c <botlish_fn_13+0x144>
    3047:	mov    eax,0x6
    304c:	mov    rbx,QWORD PTR [rsp]
    3050:	mov    r12,QWORD PTR [rsp+0x8]
    3055:	add    rsp,0x10
    3059:	mov    rsp,rbp
    305c:	pop    rbp
    305d:	ret

000000000000305e <botlish_entry_13: is_local_char<str>>:
    305e:	push   rbp
    305f:	mov    rbp,rsp
    3062:	mov    rsi,QWORD PTR [rdx]
    3065:	call   306a <botlish_entry_13+0xc>
			3066: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_local_char<str>
    306a:	mov    rsp,rbp
    306d:	pop    rbp
    306e:	ret

000000000000306f <botlish_fn_14: is_label_char<str>>:
    306f:	push   rbp
    3070:	mov    rbp,rsp
    3073:	sub    rsp,0x10
    3077:	mov    QWORD PTR [rsp],r13
    307b:	mov    QWORD PTR [rsp+0x8],r15
    3080:	mov    r13,rsi
    3083:	mov    r15,rdi
    3086:	mov    rsi,r13
    3089:	mov    rdi,r15
    308c:	call   3091 <botlish_fn_14+0x22>
			308d: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    3091:	test   rax,rax
    3094:	jne    30af <botlish_fn_14+0x40>
    309a:	xor    rax,rax
    309d:	mov    r13,QWORD PTR [rsp]
    30a1:	mov    r15,QWORD PTR [rsp+0x8]
    30a6:	add    rsp,0x10
    30aa:	mov    rsp,rbp
    30ad:	pop    rbp
    30ae:	ret
    30af:	cmp    rax,0x6
    30b3:	je     30de <botlish_fn_14+0x6f>
    30b9:	mov    rdi,r15
    30bc:	mov    rax,QWORD PTR [rdi+0x10]
    30c0:	mov    rsi,QWORD PTR [rax+0x128]
    30c7:	mov    edx,0x1
    30cc:	mov    ecx,0x3
    30d1:	mov    r8,r13
    30d4:	call   30d9 <botlish_fn_14+0x6a>
			30d5: R_X86_64_PLT32	rt_str_region_eq-0x4
    30d9:	jmp    30e3 <botlish_fn_14+0x74>
    30de:	mov    eax,0x6
    30e3:	mov    r13,QWORD PTR [rsp]
    30e7:	mov    r15,QWORD PTR [rsp+0x8]
    30ec:	add    rsp,0x10
    30f0:	mov    rsp,rbp
    30f3:	pop    rbp
    30f4:	ret

00000000000030f5 <botlish_entry_14: is_label_char<str>>:
    30f5:	push   rbp
    30f6:	mov    rbp,rsp
    30f9:	mov    rsi,QWORD PTR [rdx]
    30fc:	call   3101 <botlish_entry_14+0xc>
			30fd: R_X86_64_PLT32	botlish_fn_14-0x4 ; is_label_char<str>
    3101:	mov    rsp,rbp
    3104:	pop    rbp
    3105:	ret
	...

0000000000003108 <botlish_fn_15: scan_local<generic>>:
    3108:	push   rbp
    3109:	mov    rbp,rsp
    310c:	sub    rsp,0x40
    3110:	mov    QWORD PTR [rsp+0x20],rbx
    3115:	mov    QWORD PTR [rsp+0x28],r12
    311a:	mov    QWORD PTR [rsp+0x30],r13
    311f:	mov    QWORD PTR [rsp+0x38],r14
    3124:	mov    r12,QWORD PTR [rdi]
    3127:	mov    rax,QWORD PTR [rdi+0x8]
    312b:	lea    rcx,[r12+0x8]
    3130:	cmp    rcx,rax
    3133:	ja     3311 <botlish_fn_15+0x209>
    3139:	lea    rax,[r12+0x8]
    313e:	mov    QWORD PTR [rdi],rax
    3141:	mov    r13,rdi
    3144:	mov    QWORD PTR [r12],0x0
    314c:	mov    QWORD PTR [rsp+0x10],0x0
    3155:	mov    QWORD PTR [rsp],rdx
    3159:	mov    rbx,rsi
    315c:	mov    rsi,rdx
    315f:	mov    rax,QWORD PTR [rbx+0x20]
    3163:	mov    rdx,QWORD PTR [rax]
    3166:	mov    ecx,0x1
    316b:	test   rsi,0x1
    3172:	jne    3190 <botlish_fn_15+0x88>
    3178:	xor    ecx,ecx
    317a:	test   rsi,0x7
    3181:	jne    3190 <botlish_fn_15+0x88>
    3187:	movzx  rax,BYTE PTR [rsi]
    318b:	cmp    al,0x1
    318d:	sete   cl
    3190:	test   cl,cl
    3192:	jne    31b6 <botlish_fn_15+0xae>
    3198:	mov    rdi,r13
    319b:	mov    rax,QWORD PTR [rdi+0x10]
    319f:	mov    rcx,QWORD PTR [rax+0xb8]
    31a6:	xor    rdx,rdx
    31a9:	call   31ae <botlish_fn_15+0xa6>
			31aa: R_X86_64_PLT32	rt_type_error-0x4
    31ae:	mov    rdi,r13
    31b1:	jmp    324d <botlish_fn_15+0x145>
    31b6:	mov    rax,rsi
    31b9:	and    rax,rdx
    31bc:	mov    r14,rsi
    31bf:	test   rax,0x1
    31c5:	jne    31eb <botlish_fn_15+0xe3>
    31cb:	mov    rsi,r14
    31ce:	mov    rdi,r13
    31d1:	call   31d6 <botlish_fn_15+0xce>
			31d2: R_X86_64_PLT32	rt_int_cmp-0x4
    31d6:	mov    ecx,0x2
    31db:	test   rax,rax
    31de:	cmovge rcx,QWORD PTR [rip+0x15a]        # 3340 <botlish_fn_15+0x238>
    31e6:	jmp    31fe <botlish_fn_15+0xf6>
    31eb:	mov    ecx,0x2
    31f0:	mov    rsi,r14
    31f3:	cmp    rsi,rdx
    31f6:	cmovge rcx,QWORD PTR [rip+0x142]        # 3340 <botlish_fn_15+0x238>
    31fe:	cmp    rcx,0x6
    3202:	je     32e8 <botlish_fn_15+0x1e0>
    3208:	mov    rsi,QWORD PTR [rbx+0x20]
    320c:	mov    rsi,QWORD PTR [rsi+0x8]
    3210:	mov    QWORD PTR [rsp+0x8],rsi
    3215:	mov    rdx,r14
    3218:	mov    rdi,r13
    321b:	call   3220 <botlish_fn_15+0x118>
			321c: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    3220:	test   rax,rax
    3223:	jne    3231 <botlish_fn_15+0x129>
    3229:	mov    rdi,r13
    322c:	jmp    324d <botlish_fn_15+0x145>
    3231:	mov    QWORD PTR [rsp+0x8],rax
    3236:	mov    rsi,rax
    3239:	mov    rdi,r13
    323c:	call   3241 <botlish_fn_15+0x139>
			323d: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_local_char<str>
    3241:	test   rax,rax
    3244:	jne    3273 <botlish_fn_15+0x16b>
    324a:	mov    rdi,r13
    324d:	mov    rdi,r13
    3250:	mov    QWORD PTR [rdi],r12
    3253:	xor    rax,rax
    3256:	mov    rbx,QWORD PTR [rsp+0x20]
    325b:	mov    r12,QWORD PTR [rsp+0x28]
    3260:	mov    r13,QWORD PTR [rsp+0x30]
    3265:	mov    r14,QWORD PTR [rsp+0x38]
    326a:	add    rsp,0x40
    326e:	mov    rsp,rbp
    3271:	pop    rbp
    3272:	ret
    3273:	cmp    rax,0x6
    3277:	je     3288 <botlish_fn_15+0x180>
    327d:	mov    rax,r14
    3280:	mov    rdi,r13
    3283:	jmp    32ee <botlish_fn_15+0x1e6>
    3288:	mov    QWORD PTR [rsp+0x8],rbx
    328d:	mov    QWORD PTR [rsp+0x10],0x3
    3296:	mov    rsi,r14
    3299:	test   rsi,0x1
    32a0:	je     32c6 <botlish_fn_15+0x1be>
    32a6:	mov    rsi,r14
    32a9:	mov    rcx,rsi
    32ac:	add    rcx,0x2
    32b0:	seto   al
    32b3:	test   al,al
    32b5:	jne    32c6 <botlish_fn_15+0x1be>
    32bb:	mov    rsi,rcx
    32be:	mov    r14,rcx
    32c1:	jmp    32dc <botlish_fn_15+0x1d4>
    32c6:	mov    edx,0x3
    32cb:	mov    rsi,r14
    32ce:	mov    rdi,r13
    32d1:	call   32d6 <botlish_fn_15+0x1ce>
			32d2: R_X86_64_PLT32	rt_int_add-0x4
    32d6:	mov    rsi,rax
    32d9:	mov    r14,rax
    32dc:	mov    QWORD PTR [rsp],rsi
    32e0:	mov    rsi,r14
    32e3:	jmp    315f <botlish_fn_15+0x57>
    32e8:	mov    rax,r14
    32eb:	mov    rdi,r13
    32ee:	mov    rdi,r13
    32f1:	mov    QWORD PTR [rdi],r12
    32f4:	mov    rbx,QWORD PTR [rsp+0x20]
    32f9:	mov    r12,QWORD PTR [rsp+0x28]
    32fe:	mov    r13,QWORD PTR [rsp+0x30]
    3303:	mov    r14,QWORD PTR [rsp+0x38]
    3308:	add    rsp,0x40
    330c:	mov    rsp,rbp
    330f:	pop    rbp
    3310:	ret
    3311:	mov    r13,rdi
    3314:	call   3319 <botlish_fn_15+0x211>
			3315: R_X86_64_PLT32	rt_stack_overflow-0x4
    3319:	xor    rax,rax
    331c:	mov    rbx,QWORD PTR [rsp+0x20]
    3321:	mov    r12,QWORD PTR [rsp+0x28]
    3326:	mov    r13,QWORD PTR [rsp+0x30]
    332b:	mov    r14,QWORD PTR [rsp+0x38]
    3330:	add    rsp,0x40
    3334:	mov    rsp,rbp
    3337:	pop    rbp
    3338:	ret
    3339:	add    BYTE PTR [rax],al
    333b:	add    BYTE PTR [rax],al
    333d:	add    BYTE PTR [rax],al
    333f:	add    BYTE PTR [rsi],al
    3341:	add    BYTE PTR [rax],al
    3343:	add    BYTE PTR [rax],al
    3345:	add    BYTE PTR [rax],al
	...

0000000000003348 <botlish_entry_15: scan_local<generic>>:
    3348:	push   rbp
    3349:	mov    rbp,rsp
    334c:	mov    rdx,QWORD PTR [rdx]
    334f:	call   3354 <botlish_entry_15+0xc>
			3350: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    3354:	mov    rsp,rbp
    3357:	pop    rbp
    3358:	ret
    3359:	add    BYTE PTR [rax],al
    335b:	add    BYTE PTR [rax],al
    335d:	add    BYTE PTR [rax],al
	...

0000000000003360 <botlish_fn_16: scan_label<generic>>:
    3360:	push   rbp
    3361:	mov    rbp,rsp
    3364:	sub    rsp,0x40
    3368:	mov    QWORD PTR [rsp+0x20],rbx
    336d:	mov    QWORD PTR [rsp+0x28],r12
    3372:	mov    QWORD PTR [rsp+0x30],r13
    3377:	mov    QWORD PTR [rsp+0x38],r14
    337c:	mov    r12,QWORD PTR [rdi]
    337f:	mov    rax,QWORD PTR [rdi+0x8]
    3383:	lea    rcx,[r12+0x8]
    3388:	cmp    rcx,rax
    338b:	ja     3569 <botlish_fn_16+0x209>
    3391:	lea    rax,[r12+0x8]
    3396:	mov    QWORD PTR [rdi],rax
    3399:	mov    r13,rdi
    339c:	mov    QWORD PTR [r12],0x0
    33a4:	mov    QWORD PTR [rsp+0x10],0x0
    33ad:	mov    QWORD PTR [rsp],rdx
    33b1:	mov    rbx,rsi
    33b4:	mov    rsi,rdx
    33b7:	mov    rax,QWORD PTR [rbx+0x20]
    33bb:	mov    rdx,QWORD PTR [rax]
    33be:	mov    ecx,0x1
    33c3:	test   rsi,0x1
    33ca:	jne    33e8 <botlish_fn_16+0x88>
    33d0:	xor    ecx,ecx
    33d2:	test   rsi,0x7
    33d9:	jne    33e8 <botlish_fn_16+0x88>
    33df:	movzx  rax,BYTE PTR [rsi]
    33e3:	cmp    al,0x1
    33e5:	sete   cl
    33e8:	test   cl,cl
    33ea:	jne    340e <botlish_fn_16+0xae>
    33f0:	mov    rdi,r13
    33f3:	mov    rax,QWORD PTR [rdi+0x10]
    33f7:	mov    rcx,QWORD PTR [rax+0xb8]
    33fe:	xor    rdx,rdx
    3401:	call   3406 <botlish_fn_16+0xa6>
			3402: R_X86_64_PLT32	rt_type_error-0x4
    3406:	mov    rdi,r13
    3409:	jmp    34a5 <botlish_fn_16+0x145>
    340e:	mov    rax,rsi
    3411:	and    rax,rdx
    3414:	mov    r14,rsi
    3417:	test   rax,0x1
    341d:	jne    3443 <botlish_fn_16+0xe3>
    3423:	mov    rsi,r14
    3426:	mov    rdi,r13
    3429:	call   342e <botlish_fn_16+0xce>
			342a: R_X86_64_PLT32	rt_int_cmp-0x4
    342e:	mov    ecx,0x2
    3433:	test   rax,rax
    3436:	cmovge rcx,QWORD PTR [rip+0x15a]        # 3598 <botlish_fn_16+0x238>
    343e:	jmp    3456 <botlish_fn_16+0xf6>
    3443:	mov    ecx,0x2
    3448:	mov    rsi,r14
    344b:	cmp    rsi,rdx
    344e:	cmovge rcx,QWORD PTR [rip+0x142]        # 3598 <botlish_fn_16+0x238>
    3456:	cmp    rcx,0x6
    345a:	je     3540 <botlish_fn_16+0x1e0>
    3460:	mov    rsi,QWORD PTR [rbx+0x20]
    3464:	mov    rsi,QWORD PTR [rsi+0x8]
    3468:	mov    QWORD PTR [rsp+0x8],rsi
    346d:	mov    rdx,r14
    3470:	mov    rdi,r13
    3473:	call   3478 <botlish_fn_16+0x118>
			3474: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    3478:	test   rax,rax
    347b:	jne    3489 <botlish_fn_16+0x129>
    3481:	mov    rdi,r13
    3484:	jmp    34a5 <botlish_fn_16+0x145>
    3489:	mov    QWORD PTR [rsp+0x8],rax
    348e:	mov    rsi,rax
    3491:	mov    rdi,r13
    3494:	call   3499 <botlish_fn_16+0x139>
			3495: R_X86_64_PLT32	botlish_fn_14-0x4 ; is_label_char<str>
    3499:	test   rax,rax
    349c:	jne    34cb <botlish_fn_16+0x16b>
    34a2:	mov    rdi,r13
    34a5:	mov    rdi,r13
    34a8:	mov    QWORD PTR [rdi],r12
    34ab:	xor    rax,rax
    34ae:	mov    rbx,QWORD PTR [rsp+0x20]
    34b3:	mov    r12,QWORD PTR [rsp+0x28]
    34b8:	mov    r13,QWORD PTR [rsp+0x30]
    34bd:	mov    r14,QWORD PTR [rsp+0x38]
    34c2:	add    rsp,0x40
    34c6:	mov    rsp,rbp
    34c9:	pop    rbp
    34ca:	ret
    34cb:	cmp    rax,0x6
    34cf:	je     34e0 <botlish_fn_16+0x180>
    34d5:	mov    rax,r14
    34d8:	mov    rdi,r13
    34db:	jmp    3546 <botlish_fn_16+0x1e6>
    34e0:	mov    QWORD PTR [rsp+0x8],rbx
    34e5:	mov    QWORD PTR [rsp+0x10],0x3
    34ee:	mov    rsi,r14
    34f1:	test   rsi,0x1
    34f8:	je     351e <botlish_fn_16+0x1be>
    34fe:	mov    rsi,r14
    3501:	mov    rcx,rsi
    3504:	add    rcx,0x2
    3508:	seto   al
    350b:	test   al,al
    350d:	jne    351e <botlish_fn_16+0x1be>
    3513:	mov    rsi,rcx
    3516:	mov    r14,rcx
    3519:	jmp    3534 <botlish_fn_16+0x1d4>
    351e:	mov    edx,0x3
    3523:	mov    rsi,r14
    3526:	mov    rdi,r13
    3529:	call   352e <botlish_fn_16+0x1ce>
			352a: R_X86_64_PLT32	rt_int_add-0x4
    352e:	mov    rsi,rax
    3531:	mov    r14,rax
    3534:	mov    QWORD PTR [rsp],rsi
    3538:	mov    rsi,r14
    353b:	jmp    33b7 <botlish_fn_16+0x57>
    3540:	mov    rax,r14
    3543:	mov    rdi,r13
    3546:	mov    rdi,r13
    3549:	mov    QWORD PTR [rdi],r12
    354c:	mov    rbx,QWORD PTR [rsp+0x20]
    3551:	mov    r12,QWORD PTR [rsp+0x28]
    3556:	mov    r13,QWORD PTR [rsp+0x30]
    355b:	mov    r14,QWORD PTR [rsp+0x38]
    3560:	add    rsp,0x40
    3564:	mov    rsp,rbp
    3567:	pop    rbp
    3568:	ret
    3569:	mov    r13,rdi
    356c:	call   3571 <botlish_fn_16+0x211>
			356d: R_X86_64_PLT32	rt_stack_overflow-0x4
    3571:	xor    rax,rax
    3574:	mov    rbx,QWORD PTR [rsp+0x20]
    3579:	mov    r12,QWORD PTR [rsp+0x28]
    357e:	mov    r13,QWORD PTR [rsp+0x30]
    3583:	mov    r14,QWORD PTR [rsp+0x38]
    3588:	add    rsp,0x40
    358c:	mov    rsp,rbp
    358f:	pop    rbp
    3590:	ret
    3591:	add    BYTE PTR [rax],al
    3593:	add    BYTE PTR [rax],al
    3595:	add    BYTE PTR [rax],al
    3597:	add    BYTE PTR [rsi],al
    3599:	add    BYTE PTR [rax],al
    359b:	add    BYTE PTR [rax],al
    359d:	add    BYTE PTR [rax],al
	...

00000000000035a0 <botlish_entry_16: scan_label<generic>>:
    35a0:	push   rbp
    35a1:	mov    rbp,rsp
    35a4:	mov    rdx,QWORD PTR [rdx]
    35a7:	call   35ac <botlish_entry_16+0xc>
			35a8: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_label<generic>
    35ac:	mov    rsp,rbp
    35af:	pop    rbp
    35b0:	ret
    35b1:	add    BYTE PTR [rax],al
    35b3:	add    BYTE PTR [rax],al
    35b5:	add    BYTE PTR [rax],al
	...

00000000000035b8 <botlish_fn_17: scan_alpha<generic>>:
    35b8:	push   rbp
    35b9:	mov    rbp,rsp
    35bc:	sub    rsp,0x40
    35c0:	mov    QWORD PTR [rsp+0x20],rbx
    35c5:	mov    QWORD PTR [rsp+0x28],r12
    35ca:	mov    QWORD PTR [rsp+0x30],r13
    35cf:	mov    QWORD PTR [rsp+0x38],r14
    35d4:	mov    r12,QWORD PTR [rdi]
    35d7:	mov    rax,QWORD PTR [rdi+0x8]
    35db:	lea    rcx,[r12+0x8]
    35e0:	cmp    rcx,rax
    35e3:	ja     37bc <botlish_fn_17+0x204>
    35e9:	lea    rax,[r12+0x8]
    35ee:	mov    QWORD PTR [rdi],rax
    35f1:	mov    r13,rdi
    35f4:	mov    QWORD PTR [r12],0x0
    35fc:	mov    QWORD PTR [rsp+0x10],0x0
    3605:	mov    QWORD PTR [rsp],rdx
    3609:	mov    rbx,rsi
    360c:	mov    rsi,rdx
    360f:	mov    rax,QWORD PTR [rbx+0x20]
    3613:	mov    rdx,QWORD PTR [rax]
    3616:	mov    ecx,0x1
    361b:	test   rsi,0x1
    3622:	jne    3640 <botlish_fn_17+0x88>
    3628:	xor    ecx,ecx
    362a:	test   rsi,0x7
    3631:	jne    3640 <botlish_fn_17+0x88>
    3637:	movzx  rax,BYTE PTR [rsi]
    363b:	cmp    al,0x1
    363d:	sete   cl
    3640:	test   cl,cl
    3642:	jne    3666 <botlish_fn_17+0xae>
    3648:	mov    rdi,r13
    364b:	mov    rax,QWORD PTR [rdi+0x10]
    364f:	mov    rcx,QWORD PTR [rax+0xb8]
    3656:	xor    rdx,rdx
    3659:	call   365e <botlish_fn_17+0xa6>
			365a: R_X86_64_PLT32	rt_type_error-0x4
    365e:	mov    rdi,r13
    3661:	jmp    36f8 <botlish_fn_17+0x140>
    3666:	mov    rax,rsi
    3669:	and    rax,rdx
    366c:	mov    r14,rsi
    366f:	test   rax,0x1
    3675:	jne    369b <botlish_fn_17+0xe3>
    367b:	mov    rsi,r14
    367e:	mov    rdi,r13
    3681:	call   3686 <botlish_fn_17+0xce>
			3682: R_X86_64_PLT32	rt_int_cmp-0x4
    3686:	mov    ecx,0x2
    368b:	test   rax,rax
    368e:	cmovge rcx,QWORD PTR [rip+0x152]        # 37e8 <botlish_fn_17+0x230>
    3696:	jmp    36ae <botlish_fn_17+0xf6>
    369b:	mov    ecx,0x2
    36a0:	mov    rsi,r14
    36a3:	cmp    rsi,rdx
    36a6:	cmovge rcx,QWORD PTR [rip+0x13a]        # 37e8 <botlish_fn_17+0x230>
    36ae:	cmp    rcx,0x6
    36b2:	je     3793 <botlish_fn_17+0x1db>
    36b8:	mov    rsi,QWORD PTR [rbx+0x20]
    36bc:	mov    rsi,QWORD PTR [rsi+0x8]
    36c0:	mov    QWORD PTR [rsp+0x8],rsi
    36c5:	mov    rdx,r14
    36c8:	mov    rdi,r13
    36cb:	call   36d0 <botlish_fn_17+0x118>
			36cc: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    36d0:	test   rax,rax
    36d3:	mov    rsi,rax
    36d6:	jne    36e4 <botlish_fn_17+0x12c>
    36dc:	mov    rdi,r13
    36df:	jmp    36f8 <botlish_fn_17+0x140>
    36e4:	mov    rdi,r13
    36e7:	call   36ec <botlish_fn_17+0x134>
			36e8: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    36ec:	test   rax,rax
    36ef:	jne    371e <botlish_fn_17+0x166>
    36f5:	mov    rdi,r13
    36f8:	mov    rdi,r13
    36fb:	mov    QWORD PTR [rdi],r12
    36fe:	xor    rax,rax
    3701:	mov    rbx,QWORD PTR [rsp+0x20]
    3706:	mov    r12,QWORD PTR [rsp+0x28]
    370b:	mov    r13,QWORD PTR [rsp+0x30]
    3710:	mov    r14,QWORD PTR [rsp+0x38]
    3715:	add    rsp,0x40
    3719:	mov    rsp,rbp
    371c:	pop    rbp
    371d:	ret
    371e:	cmp    rax,0x6
    3722:	je     3733 <botlish_fn_17+0x17b>
    3728:	mov    rax,r14
    372b:	mov    rdi,r13
    372e:	jmp    3799 <botlish_fn_17+0x1e1>
    3733:	mov    QWORD PTR [rsp+0x8],rbx
    3738:	mov    QWORD PTR [rsp+0x10],0x3
    3741:	mov    rsi,r14
    3744:	test   rsi,0x1
    374b:	je     3771 <botlish_fn_17+0x1b9>
    3751:	mov    rsi,r14
    3754:	mov    rcx,rsi
    3757:	add    rcx,0x2
    375b:	seto   al
    375e:	test   al,al
    3760:	jne    3771 <botlish_fn_17+0x1b9>
    3766:	mov    rsi,rcx
    3769:	mov    r14,rcx
    376c:	jmp    3787 <botlish_fn_17+0x1cf>
    3771:	mov    edx,0x3
    3776:	mov    rsi,r14
    3779:	mov    rdi,r13
    377c:	call   3781 <botlish_fn_17+0x1c9>
			377d: R_X86_64_PLT32	rt_int_add-0x4
    3781:	mov    rsi,rax
    3784:	mov    r14,rax
    3787:	mov    QWORD PTR [rsp],rsi
    378b:	mov    rsi,r14
    378e:	jmp    360f <botlish_fn_17+0x57>
    3793:	mov    rax,r14
    3796:	mov    rdi,r13
    3799:	mov    rdi,r13
    379c:	mov    QWORD PTR [rdi],r12
    379f:	mov    rbx,QWORD PTR [rsp+0x20]
    37a4:	mov    r12,QWORD PTR [rsp+0x28]
    37a9:	mov    r13,QWORD PTR [rsp+0x30]
    37ae:	mov    r14,QWORD PTR [rsp+0x38]
    37b3:	add    rsp,0x40
    37b7:	mov    rsp,rbp
    37ba:	pop    rbp
    37bb:	ret
    37bc:	mov    r13,rdi
    37bf:	call   37c4 <botlish_fn_17+0x20c>
			37c0: R_X86_64_PLT32	rt_stack_overflow-0x4
    37c4:	xor    rax,rax
    37c7:	mov    rbx,QWORD PTR [rsp+0x20]
    37cc:	mov    r12,QWORD PTR [rsp+0x28]
    37d1:	mov    r13,QWORD PTR [rsp+0x30]
    37d6:	mov    r14,QWORD PTR [rsp+0x38]
    37db:	add    rsp,0x40
    37df:	mov    rsp,rbp
    37e2:	pop    rbp
    37e3:	ret
    37e4:	add    BYTE PTR [rax],al
    37e6:	add    BYTE PTR [rax],al
    37e8:	(bad)
    37e9:	add    BYTE PTR [rax],al
    37eb:	add    BYTE PTR [rax],al
    37ed:	add    BYTE PTR [rax],al
	...

00000000000037f0 <botlish_entry_17: scan_alpha<generic>>:
    37f0:	push   rbp
    37f1:	mov    rbp,rsp
    37f4:	mov    rdx,QWORD PTR [rdx]
    37f7:	call   37fc <botlish_entry_17+0xc>
			37f8: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_alpha<generic>
    37fc:	mov    rsp,rbp
    37ff:	pop    rbp
    3800:	ret
    3801:	add    BYTE PTR [rax],al
    3803:	add    BYTE PTR [rax],al
    3805:	add    BYTE PTR [rax],al
	...

0000000000003808 <botlish_fn_18: tld_ok<generic>>:
    3808:	push   rbp
    3809:	mov    rbp,rsp
    380c:	sub    rsp,0x40
    3810:	mov    QWORD PTR [rsp+0x10],rbx
    3815:	mov    QWORD PTR [rsp+0x18],r12
    381a:	mov    QWORD PTR [rsp+0x20],r13
    381f:	mov    QWORD PTR [rsp+0x28],r14
    3824:	mov    QWORD PTR [rsp+0x30],r15
    3829:	mov    rbx,QWORD PTR [rdi]
    382c:	mov    rax,QWORD PTR [rdi+0x8]
    3830:	lea    rcx,[rbx+0x8]
    3834:	cmp    rcx,rax
    3837:	ja     3a48 <botlish_fn_18+0x240>
    383d:	lea    rax,[rbx+0x8]
    3841:	mov    QWORD PTR [rdi],rax
    3844:	mov    r13,rdi
    3847:	mov    QWORD PTR [rbx],0x0
    384e:	mov    QWORD PTR [rsp],rdx
    3852:	mov    r8,rdx
    3855:	mov    rax,QWORD PTR [rsi+0x20]
    3859:	mov    r15,rsi
    385c:	mov    rsi,QWORD PTR [rax]
    385f:	mov    QWORD PTR [rsp+0x8],rsi
    3864:	mov    r12,r8
    3867:	mov    rdx,r12
    386a:	mov    rdi,r13
    386d:	call   3872 <botlish_fn_18+0x6a>
			386e: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_alpha<generic>
    3872:	mov    rcx,rax
    3875:	mov    r14,rax
    3878:	test   rax,rcx
    387b:	jne    3889 <botlish_fn_18+0x81>
    3881:	mov    rdi,r13
    3884:	jmp    3962 <botlish_fn_18+0x15a>
    3889:	mov    rax,r14
    388c:	mov    QWORD PTR [rsp+0x8],rax
    3891:	mov    rsi,r15
    3894:	mov    rax,QWORD PTR [rsi+0x20]
    3898:	mov    rdx,QWORD PTR [rax+0x8]
    389c:	mov    rax,r14
    389f:	and    rax,rdx
    38a2:	test   rax,0x1
    38a8:	jne    38d1 <botlish_fn_18+0xc9>
    38ae:	mov    rsi,r14
    38b1:	mov    rdi,r13
    38b4:	call   38b9 <botlish_fn_18+0xb1>
			38b5: R_X86_64_PLT32	rt_int_cmp-0x4
    38b9:	mov    ecx,0x2
    38be:	test   rax,rax
    38c1:	cmove  rcx,QWORD PTR [rip+0x1af]        # 3a78 <botlish_fn_18+0x270>
    38c9:	mov    rax,r14
    38cc:	jmp    38e4 <botlish_fn_18+0xdc>
    38d1:	mov    ecx,0x2
    38d6:	mov    rax,r14
    38d9:	cmp    rax,rdx
    38dc:	cmove  rcx,QWORD PTR [rip+0x194]        # 3a78 <botlish_fn_18+0x270>
    38e4:	cmp    rcx,0x6
    38e8:	je     38fe <botlish_fn_18+0xf6>
    38ee:	mov    ecx,0x2
    38f3:	mov    rax,rcx
    38f6:	mov    rdi,r13
    38f9:	jmp    3a20 <botlish_fn_18+0x218>
    38fe:	mov    ecx,0x1
    3903:	test   r12,0x1
    390a:	je     3918 <botlish_fn_18+0x110>
    3910:	mov    r8,r12
    3913:	jmp    393e <botlish_fn_18+0x136>
    3918:	xor    ecx,ecx
    391a:	test   r12,0x7
    3921:	je     392f <botlish_fn_18+0x127>
    3927:	mov    r8,r12
    392a:	jmp    393e <botlish_fn_18+0x136>
    392f:	movzx  rcx,BYTE PTR [r12]
    3934:	mov    r8,r12
    3937:	rex cmp cl,0x1
    393b:	sete   cl
    393e:	test   cl,cl
    3940:	jne    398d <botlish_fn_18+0x185>
    3946:	mov    rdi,r13
    3949:	mov    rax,QWORD PTR [rdi+0x10]
    394d:	mov    rcx,QWORD PTR [rax+0x128]
    3954:	xor    rdx,rdx
    3957:	mov    rsi,r8
    395a:	call   395f <botlish_fn_18+0x157>
			395b: R_X86_64_PLT32	rt_type_error-0x4
    395f:	mov    rdi,r13
    3962:	mov    rdi,r13
    3965:	mov    QWORD PTR [rdi],rbx
    3968:	xor    rax,rax
    396b:	mov    rbx,QWORD PTR [rsp+0x10]
    3970:	mov    r12,QWORD PTR [rsp+0x18]
    3975:	mov    r13,QWORD PTR [rsp+0x20]
    397a:	mov    r14,QWORD PTR [rsp+0x28]
    397f:	mov    r15,QWORD PTR [rsp+0x30]
    3984:	add    rsp,0x40
    3988:	mov    rsp,rbp
    398b:	pop    rbp
    398c:	ret
    398d:	mov    r12,r8
    3990:	mov    rcx,rax
    3993:	and    rcx,r12
    3996:	test   rcx,0x1
    399d:	jne    39ae <botlish_fn_18+0x1a6>
    39a3:	mov    rdx,r8
    39a6:	mov    rsi,rax
    39a9:	jmp    39cf <botlish_fn_18+0x1c7>
    39ae:	mov    r12,r8
    39b1:	mov    rcx,rax
    39b4:	sub    rcx,r12
    39b7:	mov    r14,rax
    39ba:	seto   al
    39bd:	lea    rsi,[rcx+0x1]
    39c1:	test   al,al
    39c3:	je     39da <botlish_fn_18+0x1d2>
    39c9:	mov    rdx,r8
    39cc:	mov    rsi,r14
    39cf:	mov    rdi,r13
    39d2:	call   39d7 <botlish_fn_18+0x1cf>
			39d3: R_X86_64_PLT32	rt_int_sub-0x4
    39d7:	mov    rsi,rax
    39da:	test   rsi,0x1
    39e1:	jne    3a0c <botlish_fn_18+0x204>
    39e7:	mov    edx,0x5
    39ec:	mov    rdi,r13
    39ef:	call   39f4 <botlish_fn_18+0x1ec>
			39f0: R_X86_64_PLT32	rt_int_cmp-0x4
    39f4:	mov    ecx,0x2
    39f9:	test   rax,rax
    39fc:	mov    rax,rcx
    39ff:	cmovge rax,QWORD PTR [rip+0x71]        # 3a78 <botlish_fn_18+0x270>
    3a07:	jmp    3a1d <botlish_fn_18+0x215>
    3a0c:	mov    eax,0x2
    3a11:	cmp    rsi,0x5
    3a15:	cmovge rax,QWORD PTR [rip+0x5b]        # 3a78 <botlish_fn_18+0x270>
    3a1d:	mov    rdi,r13
    3a20:	mov    rdi,r13
    3a23:	mov    QWORD PTR [rdi],rbx
    3a26:	mov    rbx,QWORD PTR [rsp+0x10]
    3a2b:	mov    r12,QWORD PTR [rsp+0x18]
    3a30:	mov    r13,QWORD PTR [rsp+0x20]
    3a35:	mov    r14,QWORD PTR [rsp+0x28]
    3a3a:	mov    r15,QWORD PTR [rsp+0x30]
    3a3f:	add    rsp,0x40
    3a43:	mov    rsp,rbp
    3a46:	pop    rbp
    3a47:	ret
    3a48:	mov    r13,rdi
    3a4b:	call   3a50 <botlish_fn_18+0x248>
			3a4c: R_X86_64_PLT32	rt_stack_overflow-0x4
    3a50:	xor    rax,rax
    3a53:	mov    rbx,QWORD PTR [rsp+0x10]
    3a58:	mov    r12,QWORD PTR [rsp+0x18]
    3a5d:	mov    r13,QWORD PTR [rsp+0x20]
    3a62:	mov    r14,QWORD PTR [rsp+0x28]
    3a67:	mov    r15,QWORD PTR [rsp+0x30]
    3a6c:	add    rsp,0x40
    3a70:	mov    rsp,rbp
    3a73:	pop    rbp
    3a74:	ret
    3a75:	add    BYTE PTR [rax],al
    3a77:	add    BYTE PTR [rsi],al
    3a79:	add    BYTE PTR [rax],al
    3a7b:	add    BYTE PTR [rax],al
    3a7d:	add    BYTE PTR [rax],al
	...

0000000000003a80 <botlish_entry_18: tld_ok<generic>>:
    3a80:	push   rbp
    3a81:	mov    rbp,rsp
    3a84:	mov    rdx,QWORD PTR [rdx]
    3a87:	call   3a8c <botlish_entry_18+0xc>
			3a88: R_X86_64_PLT32	botlish_fn_18-0x4 ; tld_ok<generic>
    3a8c:	mov    rsp,rbp
    3a8f:	pop    rbp
    3a90:	ret
    3a91:	add    BYTE PTR [rax],al
    3a93:	add    BYTE PTR [rax],al
    3a95:	add    BYTE PTR [rax],al
	...

0000000000003a98 <botlish_fn_19: domain_loop<generic>>:
    3a98:	push   rbp
    3a99:	mov    rbp,rsp
    3a9c:	sub    rsp,0x60
    3aa0:	mov    QWORD PTR [rsp+0x30],rbx
    3aa5:	mov    QWORD PTR [rsp+0x38],r12
    3aaa:	mov    QWORD PTR [rsp+0x40],r13
    3aaf:	mov    QWORD PTR [rsp+0x48],r14
    3ab4:	mov    QWORD PTR [rsp+0x50],r15
    3ab9:	mov    r13,QWORD PTR [rdi]
    3abc:	mov    rax,QWORD PTR [rdi+0x8]
    3ac0:	lea    rcx,[r13+0x8]
    3ac4:	cmp    rcx,rax
    3ac7:	ja     3d44 <botlish_fn_19+0x2ac>
    3acd:	lea    rax,[r13+0x8]
    3ad1:	mov    QWORD PTR [rdi],rax
    3ad4:	mov    r15,rdi
    3ad7:	mov    QWORD PTR [r13+0x0],0x0
    3adf:	mov    QWORD PTR [rsp],rdx
    3ae3:	mov    QWORD PTR [rsp+0x20],rdx
    3ae8:	lea    rbx,[rsp+0x10]
    3aed:	mov    r12,rsi
    3af0:	mov    rax,QWORD PTR [r12+0x20]
    3af5:	mov    rsi,QWORD PTR [rax]
    3af8:	mov    QWORD PTR [rsp+0x8],rsi
    3afd:	mov    rdx,QWORD PTR [rsp+0x20]
    3b02:	mov    rdi,r15
    3b05:	call   3b0a <botlish_fn_19+0x72>
			3b06: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_label<generic>
    3b0a:	mov    rcx,rax
    3b0d:	mov    r14,rax
    3b10:	test   rax,rcx
    3b13:	jne    3b21 <botlish_fn_19+0x89>
    3b19:	mov    rdi,r15
    3b1c:	jmp    3cb2 <botlish_fn_19+0x21a>
    3b21:	mov    rax,r14
    3b24:	mov    QWORD PTR [rsp],rax
    3b28:	mov    rdx,QWORD PTR [rsp+0x20]
    3b2d:	mov    rsi,rax
    3b30:	and    rsi,rdx
    3b33:	test   rsi,0x1
    3b3a:	jne    3b61 <botlish_fn_19+0xc9>
    3b40:	mov    rdx,QWORD PTR [rsp+0x20]
    3b45:	mov    rsi,r14
    3b48:	mov    rdi,r15
    3b4b:	call   3b50 <botlish_fn_19+0xb8>
			3b4c: R_X86_64_PLT32	rt_value_eq-0x4
    3b50:	test   rax,rax
    3b53:	jne    3b76 <botlish_fn_19+0xde>
    3b59:	mov    rdi,r15
    3b5c:	jmp    3cb2 <botlish_fn_19+0x21a>
    3b61:	mov    eax,0x2
    3b66:	mov    rdx,QWORD PTR [rsp+0x20]
    3b6b:	cmp    r14,rdx
    3b6e:	cmove  rax,QWORD PTR [rip+0x202]        # 3d78 <botlish_fn_19+0x2e0>
    3b76:	cmp    rax,0x6
    3b7a:	je     3d12 <botlish_fn_19+0x27a>
    3b80:	mov    rax,QWORD PTR [r12+0x20]
    3b85:	mov    rdx,QWORD PTR [rax+0x8]
    3b89:	mov    rax,r14
    3b8c:	and    rax,rdx
    3b8f:	test   rax,0x1
    3b95:	jne    3bbb <botlish_fn_19+0x123>
    3b9b:	mov    rsi,r14
    3b9e:	mov    rdi,r15
    3ba1:	call   3ba6 <botlish_fn_19+0x10e>
			3ba2: R_X86_64_PLT32	rt_int_cmp-0x4
    3ba6:	mov    ecx,0x2
    3bab:	test   rax,rax
    3bae:	cmovge rcx,QWORD PTR [rip+0x1c2]        # 3d78 <botlish_fn_19+0x2e0>
    3bb6:	jmp    3bcb <botlish_fn_19+0x133>
    3bbb:	mov    ecx,0x2
    3bc0:	cmp    r14,rdx
    3bc3:	cmovge rcx,QWORD PTR [rip+0x1ad]        # 3d78 <botlish_fn_19+0x2e0>
    3bcb:	cmp    rcx,0x6
    3bcf:	je     3d03 <botlish_fn_19+0x26b>
    3bd5:	mov    rax,QWORD PTR [r12+0x20]
    3bda:	mov    rsi,QWORD PTR [rax+0x10]
    3bde:	mov    QWORD PTR [rsp+0x8],rsi
    3be3:	mov    rcx,rbx
    3be6:	mov    rdx,r14
    3be9:	mov    rdi,r15
    3bec:	call   3bf1 <botlish_fn_19+0x159>
			3bed: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    3bf1:	test   rax,rax
    3bf4:	mov    rsi,rax
    3bf7:	jne    3c05 <botlish_fn_19+0x16d>
    3bfd:	mov    rdi,r15
    3c00:	jmp    3cb2 <botlish_fn_19+0x21a>
    3c05:	mov    rdx,QWORD PTR [rsp+0x10]
    3c0a:	mov    rcx,QWORD PTR [rsp+0x18]
    3c0f:	mov    rdi,r15
    3c12:	mov    rax,QWORD PTR [rdi+0x10]
    3c16:	mov    r8,QWORD PTR [rax+0x118]
    3c1d:	call   3c22 <botlish_fn_19+0x18a>
			3c1e: R_X86_64_PLT32	rt_str_region_eq-0x4
    3c22:	cmp    rax,0x6
    3c26:	je     3c38 <botlish_fn_19+0x1a0>
    3c2c:	mov    rax,0xffffffffffffffff
    3c33:	jmp    3d0a <botlish_fn_19+0x272>
    3c38:	mov    QWORD PTR [rsp+0x8],0x3
    3c41:	test   r14,0x1
    3c48:	je     3c6f <botlish_fn_19+0x1d7>
    3c4e:	mov    rdx,r14
    3c51:	add    rdx,0x2
    3c55:	mov    QWORD PTR [rsp+0x20],rdx
    3c5a:	seto   al
    3c5d:	test   al,al
    3c5f:	jne    3c6f <botlish_fn_19+0x1d7>
    3c65:	mov    rdx,QWORD PTR [rsp+0x20]
    3c6a:	jmp    3c87 <botlish_fn_19+0x1ef>
    3c6f:	mov    edx,0x3
    3c74:	mov    rsi,r14
    3c77:	mov    rdi,r15
    3c7a:	call   3c7f <botlish_fn_19+0x1e7>
			3c7b: R_X86_64_PLT32	rt_int_add-0x4
    3c7f:	mov    rdx,rax
    3c82:	mov    QWORD PTR [rsp+0x20],rax
    3c87:	mov    QWORD PTR [rsp],rdx
    3c8b:	mov    rax,QWORD PTR [r12+0x20]
    3c90:	mov    rsi,QWORD PTR [rax+0x18]
    3c94:	mov    QWORD PTR [rsp+0x8],rsi
    3c99:	mov    rdx,QWORD PTR [rsp+0x20]
    3c9e:	mov    rdi,r15
    3ca1:	call   3ca6 <botlish_fn_19+0x20e>
			3ca2: R_X86_64_PLT32	botlish_fn_18-0x4 ; tld_ok<generic>
    3ca6:	test   rax,rax
    3ca9:	jne    3cdd <botlish_fn_19+0x245>
    3caf:	mov    rdi,r15
    3cb2:	mov    rdi,r15
    3cb5:	mov    QWORD PTR [rdi],r13
    3cb8:	xor    rax,rax
    3cbb:	mov    rbx,QWORD PTR [rsp+0x30]
    3cc0:	mov    r12,QWORD PTR [rsp+0x38]
    3cc5:	mov    r13,QWORD PTR [rsp+0x40]
    3cca:	mov    r14,QWORD PTR [rsp+0x48]
    3ccf:	mov    r15,QWORD PTR [rsp+0x50]
    3cd4:	add    rsp,0x60
    3cd8:	mov    rsp,rbp
    3cdb:	pop    rbp
    3cdc:	ret
    3cdd:	cmp    rax,0x6
    3ce1:	je     3cf5 <botlish_fn_19+0x25d>
    3ce7:	mov    rdx,QWORD PTR [rsp+0x20]
    3cec:	mov    QWORD PTR [rsp],rdx
    3cf0:	jmp    3af0 <botlish_fn_19+0x58>
    3cf5:	mov    rax,QWORD PTR [r12+0x20]
    3cfa:	mov    rax,QWORD PTR [rax+0x8]
    3cfe:	jmp    3d0a <botlish_fn_19+0x272>
    3d03:	mov    rax,0xffffffffffffffff
    3d0a:	mov    rdi,r15
    3d0d:	jmp    3d1c <botlish_fn_19+0x284>
    3d12:	mov    rax,0xffffffffffffffff
    3d19:	mov    rdi,r15
    3d1c:	mov    rdi,r15
    3d1f:	mov    QWORD PTR [rdi],r13
    3d22:	mov    rbx,QWORD PTR [rsp+0x30]
    3d27:	mov    r12,QWORD PTR [rsp+0x38]
    3d2c:	mov    r13,QWORD PTR [rsp+0x40]
    3d31:	mov    r14,QWORD PTR [rsp+0x48]
    3d36:	mov    r15,QWORD PTR [rsp+0x50]
    3d3b:	add    rsp,0x60
    3d3f:	mov    rsp,rbp
    3d42:	pop    rbp
    3d43:	ret
    3d44:	mov    r15,rdi
    3d47:	call   3d4c <botlish_fn_19+0x2b4>
			3d48: R_X86_64_PLT32	rt_stack_overflow-0x4
    3d4c:	xor    rax,rax
    3d4f:	mov    rbx,QWORD PTR [rsp+0x30]
    3d54:	mov    r12,QWORD PTR [rsp+0x38]
    3d59:	mov    r13,QWORD PTR [rsp+0x40]
    3d5e:	mov    r14,QWORD PTR [rsp+0x48]
    3d63:	mov    r15,QWORD PTR [rsp+0x50]
    3d68:	add    rsp,0x60
    3d6c:	mov    rsp,rbp
    3d6f:	pop    rbp
    3d70:	ret
    3d71:	add    BYTE PTR [rax],al
    3d73:	add    BYTE PTR [rax],al
    3d75:	add    BYTE PTR [rax],al
    3d77:	add    BYTE PTR [rsi],al
    3d79:	add    BYTE PTR [rax],al
    3d7b:	add    BYTE PTR [rax],al
    3d7d:	add    BYTE PTR [rax],al
	...

0000000000003d80 <botlish_entry_19: domain_loop<generic>>:
    3d80:	push   rbp
    3d81:	mov    rbp,rsp
    3d84:	mov    rdx,QWORD PTR [rdx]
    3d87:	call   3d8c <botlish_entry_19+0xc>
			3d88: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    3d8c:	mov    rsp,rbp
    3d8f:	pop    rbp
    3d90:	ret
    3d91:	add    BYTE PTR [rax],al
    3d93:	add    BYTE PTR [rax],al
    3d95:	add    BYTE PTR [rax],al
	...

0000000000003d98 <botlish_fn_20: <str>>:
    3d98:	push   rbp
    3d99:	mov    rbp,rsp
    3d9c:	sub    rsp,0xf0
    3da3:	mov    QWORD PTR [rsp+0xc0],rbx
    3dab:	mov    QWORD PTR [rsp+0xc8],r12
    3db3:	mov    QWORD PTR [rsp+0xd0],r13
    3dbb:	mov    QWORD PTR [rsp+0xd8],r14
    3dc3:	mov    QWORD PTR [rsp+0xe0],r15
    3dcb:	mov    rbx,QWORD PTR [rdi]
    3dce:	mov    rax,QWORD PTR [rdi+0x8]
    3dd2:	lea    rcx,[rbx+0x8]
    3dd6:	cmp    rcx,rax
    3dd9:	ja     4289 <botlish_fn_20+0x4f1>
    3ddf:	lea    rax,[rbx+0x8]
    3de3:	mov    QWORD PTR [rdi],rax
    3de6:	mov    QWORD PTR [rsp+0xa0],rdi
    3dee:	mov    QWORD PTR [rbx],0x0
    3df5:	mov    QWORD PTR [rsp+0x10],0x0
    3dfe:	mov    QWORD PTR [rsp+0x18],0x0
    3e07:	mov    QWORD PTR [rsp+0x20],0x0
    3e10:	mov    QWORD PTR [rsp],rsi
    3e14:	mov    r12,rsi
    3e17:	mov    rsi,r12
    3e1a:	mov    rdi,QWORD PTR [rsp+0xa0]
    3e22:	call   3e27 <botlish_fn_20+0x8f>
			3e23: R_X86_64_PLT32	rt_str_len-0x4
    3e27:	mov    QWORD PTR [rsp+0xb0],rax
    3e2f:	mov    QWORD PTR [rsp+0x8],rax
    3e34:	lea    r8,[rsp+0x28]
    3e39:	mov    QWORD PTR [rsp+0x28],r12
    3e3e:	mov    esi,0x16
    3e43:	mov    rdx,QWORD PTR [rip+0x0]        # 3e4a <botlish_fn_20+0xb2>
			3e46: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; char_at<generic>
    3e4a:	mov    r12d,0x1
    3e50:	mov    rcx,r12
    3e53:	mov    rdi,QWORD PTR [rsp+0xa0]
    3e5b:	call   3e60 <botlish_fn_20+0xc8>
			3e5c: R_X86_64_PLT32	rt_closure_new-0x4
    3e60:	mov    r15,rax
    3e63:	mov    QWORD PTR [rsp],rax
    3e67:	lea    r8,[rsp+0x30]
    3e6c:	mov    rax,QWORD PTR [rsp+0xb0]
    3e74:	mov    QWORD PTR [rsp+0x30],rax
    3e79:	mov    rax,r15
    3e7c:	mov    QWORD PTR [rsp+0x38],rax
    3e81:	mov    esi,0x1a
    3e86:	mov    rdx,QWORD PTR [rip+0x0]        # 3e8d <botlish_fn_20+0xf5>
			3e89: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; scan_local<generic>
    3e8d:	mov    r14d,0x2
    3e93:	mov    rcx,r14
    3e96:	mov    rdi,QWORD PTR [rsp+0xa0]
    3e9e:	call   3ea3 <botlish_fn_20+0x10b>
			3e9f: R_X86_64_PLT32	rt_closure_new-0x4
    3ea3:	mov    r13,rax
    3ea6:	mov    QWORD PTR [rsp+0x10],r13
    3eab:	lea    r8,[rsp+0x40]
    3eb0:	mov    rax,QWORD PTR [rsp+0xb0]
    3eb8:	mov    QWORD PTR [rsp+0x40],rax
    3ebd:	mov    rax,r15
    3ec0:	mov    QWORD PTR [rsp+0x48],rax
    3ec5:	mov    esi,0x1b
    3eca:	mov    rdx,QWORD PTR [rip+0x0]        # 3ed1 <botlish_fn_20+0x139>
			3ecd: R_X86_64_GOTPCREL	botlish_entry_27-0x4 ; scan_label<generic>
    3ed1:	mov    rcx,r14
    3ed4:	mov    rdi,QWORD PTR [rsp+0xa0]
    3edc:	call   3ee1 <botlish_fn_20+0x149>
			3edd: R_X86_64_PLT32	rt_closure_new-0x4
    3ee1:	mov    QWORD PTR [rsp+0x18],rax
    3ee6:	mov    QWORD PTR [rsp+0xa8],rax
    3eee:	lea    r8,[rsp+0x50]
    3ef3:	mov    rax,QWORD PTR [rsp+0xb0]
    3efb:	mov    QWORD PTR [rsp+0x50],rax
    3f00:	mov    QWORD PTR [rsp+0x58],r15
    3f05:	mov    esi,0x1c
    3f0a:	mov    rdx,QWORD PTR [rip+0x0]        # 3f11 <botlish_fn_20+0x179>
			3f0d: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; scan_alpha<generic>
    3f11:	mov    rcx,r14
    3f14:	mov    rdi,QWORD PTR [rsp+0xa0]
    3f1c:	call   3f21 <botlish_fn_20+0x189>
			3f1d: R_X86_64_PLT32	rt_closure_new-0x4
    3f21:	mov    QWORD PTR [rsp+0x20],rax
    3f26:	lea    r8,[rsp+0x60]
    3f2b:	mov    QWORD PTR [rsp+0x60],rax
    3f30:	mov    rax,QWORD PTR [rsp+0xb0]
    3f38:	mov    QWORD PTR [rsp+0x68],rax
    3f3d:	mov    esi,0x1d
    3f42:	mov    rdx,QWORD PTR [rip+0x0]        # 3f49 <botlish_fn_20+0x1b1>
			3f45: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; tld_ok<generic>
    3f49:	mov    rcx,r14
    3f4c:	mov    rdi,QWORD PTR [rsp+0xa0]
    3f54:	call   3f59 <botlish_fn_20+0x1c1>
			3f55: R_X86_64_PLT32	rt_closure_new-0x4
    3f59:	mov    QWORD PTR [rsp+0x20],rax
    3f5e:	lea    r8,[rsp+0x70]
    3f63:	mov    rcx,QWORD PTR [rsp+0xa8]
    3f6b:	mov    QWORD PTR [rsp+0x70],rcx
    3f70:	mov    rcx,QWORD PTR [rsp+0xb0]
    3f78:	mov    QWORD PTR [rsp+0x78],rcx
    3f7d:	mov    QWORD PTR [rsp+0x80],r15
    3f85:	mov    QWORD PTR [rsp+0x88],rax
    3f8d:	mov    esi,0x1e
    3f92:	mov    rdx,QWORD PTR [rip+0x0]        # 3f99 <botlish_fn_20+0x201>
			3f95: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; domain_loop<generic>
    3f99:	mov    ecx,0x4
    3f9e:	mov    rdi,QWORD PTR [rsp+0xa0]
    3fa6:	call   3fab <botlish_fn_20+0x213>
			3fa7: R_X86_64_PLT32	rt_closure_new-0x4
    3fab:	mov    QWORD PTR [rsp+0x18],rax
    3fb0:	mov    r14,rax
    3fb3:	mov    QWORD PTR [rsp+0x20],0x1
    3fbc:	mov    rdx,r12
    3fbf:	mov    rsi,r13
    3fc2:	mov    rdi,QWORD PTR [rsp+0xa0]
    3fca:	call   3fcf <botlish_fn_20+0x237>
			3fcb: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    3fcf:	mov    rcx,rax
    3fd2:	mov    r13,rax
    3fd5:	test   rax,rcx
    3fd8:	jne    3feb <botlish_fn_20+0x253>
    3fde:	mov    rdi,QWORD PTR [rsp+0xa0]
    3fe6:	jmp    4181 <botlish_fn_20+0x3e9>
    3feb:	mov    rax,r13
    3fee:	mov    QWORD PTR [rsp+0x10],rax
    3ff3:	test   rax,0x1
    3ff9:	jne    402a <botlish_fn_20+0x292>
    3fff:	mov    edx,0x1
    4004:	mov    rsi,r13
    4007:	mov    rdi,QWORD PTR [rsp+0xa0]
    400f:	call   4014 <botlish_fn_20+0x27c>
			4010: R_X86_64_PLT32	rt_int_cmp-0x4
    4014:	mov    r11d,0x2
    401a:	test   rax,rax
    401d:	cmove  r11,QWORD PTR [rip+0x2ab]        # 42d0 <botlish_fn_20+0x538>
    4025:	jmp    403c <botlish_fn_20+0x2a4>
    402a:	mov    r11d,0x2
    4030:	cmp    r13,0x1
    4034:	cmove  r11,QWORD PTR [rip+0x294]        # 42d0 <botlish_fn_20+0x538>
    403c:	cmp    r11,0x6
    4040:	je     423d <botlish_fn_20+0x4a5>
    4046:	mov    r12,QWORD PTR [rsp+0xb0]
    404e:	mov    rax,r13
    4051:	and    rax,r12
    4054:	test   rax,0x1
    405a:	jne    4088 <botlish_fn_20+0x2f0>
    4060:	mov    rdx,r12
    4063:	mov    rsi,r13
    4066:	mov    rdi,QWORD PTR [rsp+0xa0]
    406e:	call   4073 <botlish_fn_20+0x2db>
			406f: R_X86_64_PLT32	rt_int_cmp-0x4
    4073:	mov    ecx,0x2
    4078:	test   rax,rax
    407b:	cmovge rcx,QWORD PTR [rip+0x24d]        # 42d0 <botlish_fn_20+0x538>
    4083:	jmp    4098 <botlish_fn_20+0x300>
    4088:	mov    ecx,0x2
    408d:	cmp    r13,r12
    4090:	cmovge rcx,QWORD PTR [rip+0x238]        # 42d0 <botlish_fn_20+0x538>
    4098:	cmp    rcx,0x6
    409c:	je     422b <botlish_fn_20+0x493>
    40a2:	lea    rcx,[rsp+0x90]
    40aa:	mov    rsi,r15
    40ad:	mov    rdx,r13
    40b0:	mov    rdi,QWORD PTR [rsp+0xa0]
    40b8:	call   40bd <botlish_fn_20+0x325>
			40b9: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    40bd:	test   rax,rax
    40c0:	mov    rsi,rax
    40c3:	jne    40d6 <botlish_fn_20+0x33e>
    40c9:	mov    rdi,QWORD PTR [rsp+0xa0]
    40d1:	jmp    4181 <botlish_fn_20+0x3e9>
    40d6:	mov    rdx,QWORD PTR [rsp+0x90]
    40de:	mov    rcx,QWORD PTR [rsp+0x98]
    40e6:	mov    rdi,QWORD PTR [rsp+0xa0]
    40ee:	mov    rdi,QWORD PTR [rdi+0x10]
    40f2:	mov    r8,QWORD PTR [rdi+0x100]
    40f9:	mov    rdi,QWORD PTR [rsp+0xa0]
    4101:	call   4106 <botlish_fn_20+0x36e>
			4102: R_X86_64_PLT32	rt_str_region_eq-0x4
    4106:	cmp    rax,0x6
    410a:	je     411d <botlish_fn_20+0x385>
    4110:	mov    ecx,0x2
    4115:	mov    rax,rcx
    4118:	jmp    4230 <botlish_fn_20+0x498>
    411d:	mov    QWORD PTR [rsp],0x3
    4125:	test   r13,0x1
    412c:	je     4144 <botlish_fn_20+0x3ac>
    4132:	mov    rdx,r13
    4135:	add    rdx,0x2
    4139:	seto   al
    413c:	test   al,al
    413e:	je     415c <botlish_fn_20+0x3c4>
    4144:	mov    edx,0x3
    4149:	mov    rsi,r13
    414c:	mov    rdi,QWORD PTR [rsp+0xa0]
    4154:	call   4159 <botlish_fn_20+0x3c1>
			4155: R_X86_64_PLT32	rt_int_add-0x4
    4159:	mov    rdx,rax
    415c:	mov    QWORD PTR [rsp],rdx
    4160:	mov    rsi,r14
    4163:	mov    rdi,QWORD PTR [rsp+0xa0]
    416b:	call   4170 <botlish_fn_20+0x3d8>
			416c: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    4170:	test   rax,rax
    4173:	jne    41c3 <botlish_fn_20+0x42b>
    4179:	mov    rdi,QWORD PTR [rsp+0xa0]
    4181:	mov    rdi,QWORD PTR [rsp+0xa0]
    4189:	mov    QWORD PTR [rdi],rbx
    418c:	xor    rax,rax
    418f:	mov    rbx,QWORD PTR [rsp+0xc0]
    4197:	mov    r12,QWORD PTR [rsp+0xc8]
    419f:	mov    r13,QWORD PTR [rsp+0xd0]
    41a7:	mov    r14,QWORD PTR [rsp+0xd8]
    41af:	mov    r15,QWORD PTR [rsp+0xe0]
    41b7:	add    rsp,0xf0
    41be:	mov    rsp,rbp
    41c1:	pop    rbp
    41c2:	ret
    41c3:	mov    rcx,rax
    41c6:	and    rcx,r12
    41c9:	mov    rsi,rax
    41cc:	mov    QWORD PTR [rsp+0xb0],r12
    41d4:	test   rcx,0x1
    41db:	jne    420e <botlish_fn_20+0x476>
    41e1:	mov    rdx,QWORD PTR [rsp+0xb0]
    41e9:	mov    rdi,QWORD PTR [rsp+0xa0]
    41f1:	call   41f6 <botlish_fn_20+0x45e>
			41f2: R_X86_64_PLT32	rt_int_cmp-0x4
    41f6:	mov    ecx,0x2
    41fb:	test   rax,rax
    41fe:	mov    rax,rcx
    4201:	cmove  rax,QWORD PTR [rip+0xc7]        # 42d0 <botlish_fn_20+0x538>
    4209:	jmp    4230 <botlish_fn_20+0x498>
    420e:	mov    rdx,QWORD PTR [rsp+0xb0]
    4216:	mov    eax,0x2
    421b:	cmp    rsi,rdx
    421e:	cmove  rax,QWORD PTR [rip+0xaa]        # 42d0 <botlish_fn_20+0x538>
    4226:	jmp    4230 <botlish_fn_20+0x498>
    422b:	mov    eax,0x2
    4230:	mov    rdi,QWORD PTR [rsp+0xa0]
    4238:	jmp    424a <botlish_fn_20+0x4b2>
    423d:	mov    eax,0x2
    4242:	mov    rdi,QWORD PTR [rsp+0xa0]
    424a:	mov    rdi,QWORD PTR [rsp+0xa0]
    4252:	mov    QWORD PTR [rdi],rbx
    4255:	mov    rbx,QWORD PTR [rsp+0xc0]
    425d:	mov    r12,QWORD PTR [rsp+0xc8]
    4265:	mov    r13,QWORD PTR [rsp+0xd0]
    426d:	mov    r14,QWORD PTR [rsp+0xd8]
    4275:	mov    r15,QWORD PTR [rsp+0xe0]
    427d:	add    rsp,0xf0
    4284:	mov    rsp,rbp
    4287:	pop    rbp
    4288:	ret
    4289:	mov    QWORD PTR [rsp+0xa0],rdi
    4291:	call   4296 <botlish_fn_20+0x4fe>
			4292: R_X86_64_PLT32	rt_stack_overflow-0x4
    4296:	xor    rax,rax
    4299:	mov    rbx,QWORD PTR [rsp+0xc0]
    42a1:	mov    r12,QWORD PTR [rsp+0xc8]
    42a9:	mov    r13,QWORD PTR [rsp+0xd0]
    42b1:	mov    r14,QWORD PTR [rsp+0xd8]
    42b9:	mov    r15,QWORD PTR [rsp+0xe0]
    42c1:	add    rsp,0xf0
    42c8:	mov    rsp,rbp
    42cb:	pop    rbp
    42cc:	ret
    42cd:	add    BYTE PTR [rax],al
    42cf:	add    BYTE PTR [rsi],al
    42d1:	add    BYTE PTR [rax],al
    42d3:	add    BYTE PTR [rax],al
    42d5:	add    BYTE PTR [rax],al
	...

00000000000042d8 <botlish_entry_20: <str>>:
    42d8:	push   rbp
    42d9:	mov    rbp,rsp
    42dc:	mov    rsi,QWORD PTR [rdx]
    42df:	call   42e4 <botlish_entry_20+0xc>
			42e0: R_X86_64_PLT32	botlish_fn_20-0x4 ; <str>
    42e4:	mov    rsp,rbp
    42e7:	pop    rbp
    42e8:	ret
    42e9:	add    BYTE PTR [rax],al
    42eb:	add    BYTE PTR [rax],al
    42ed:	add    BYTE PTR [rax],al
	...

00000000000042f0 <botlish_fn_21: <generic>>:
    42f0:	push   rbp
    42f1:	mov    rbp,rsp
    42f4:	sub    rsp,0xf0
    42fb:	mov    QWORD PTR [rsp+0xc0],rbx
    4303:	mov    QWORD PTR [rsp+0xc8],r12
    430b:	mov    QWORD PTR [rsp+0xd0],r13
    4313:	mov    QWORD PTR [rsp+0xd8],r14
    431b:	mov    QWORD PTR [rsp+0xe0],r15
    4323:	mov    rbx,QWORD PTR [rdi]
    4326:	mov    rax,QWORD PTR [rdi+0x8]
    432a:	lea    rcx,[rbx+0x8]
    432e:	cmp    rcx,rax
    4331:	ja     47b8 <botlish_fn_21+0x4c8>
    4337:	lea    rax,[rbx+0x8]
    433b:	mov    QWORD PTR [rdi],rax
    433e:	mov    QWORD PTR [rbx],0x0
    4345:	mov    QWORD PTR [rsp+0x10],0x0
    434e:	mov    QWORD PTR [rsp+0x18],0x0
    4357:	mov    QWORD PTR [rsp+0x20],0x0
    4360:	mov    QWORD PTR [rsp],rsi
    4364:	xor    eax,eax
    4366:	test   rsi,0x7
    436d:	jne    437c <botlish_fn_21+0x8c>
    4373:	movzx  rax,BYTE PTR [rsi]
    4377:	cmp    al,0x2
    4379:	sete   al
    437c:	test   al,al
    437e:	jne    43a4 <botlish_fn_21+0xb4>
    4384:	mov    rax,QWORD PTR [rdi+0x10]
    4388:	mov    r15,rdi
    438b:	mov    rcx,QWORD PTR [rax+0xd8]
    4392:	mov    edx,0x1
    4397:	call   439c <botlish_fn_21+0xac>
			4398: R_X86_64_PLT32	rt_type_error-0x4
    439c:	mov    rdi,r15
    439f:	jmp    46c9 <botlish_fn_21+0x3d9>
    43a4:	mov    r12,rsi
    43a7:	mov    r15,rdi
    43aa:	call   43af <botlish_fn_21+0xbf>
			43ab: R_X86_64_PLT32	rt_str_len-0x4
    43af:	mov    QWORD PTR [rsp+0xb0],rax
    43b7:	mov    QWORD PTR [rsp+0x8],rax
    43bc:	lea    r8,[rsp+0x28]
    43c1:	mov    QWORD PTR [rsp+0x28],r12
    43c6:	mov    esi,0x16
    43cb:	mov    rdx,QWORD PTR [rip+0x0]        # 43d2 <botlish_fn_21+0xe2>
			43ce: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; char_at<generic>
    43d2:	mov    r12d,0x1
    43d8:	mov    rcx,r12
    43db:	mov    rdi,r15
    43de:	call   43e3 <botlish_fn_21+0xf3>
			43df: R_X86_64_PLT32	rt_closure_new-0x4
    43e3:	mov    r14,rax
    43e6:	mov    QWORD PTR [rsp+0xa8],r12
    43ee:	mov    QWORD PTR [rsp],rax
    43f2:	lea    r8,[rsp+0x30]
    43f7:	mov    rax,QWORD PTR [rsp+0xb0]
    43ff:	mov    QWORD PTR [rsp+0x30],rax
    4404:	mov    rax,r14
    4407:	mov    QWORD PTR [rsp+0x38],rax
    440c:	mov    esi,0x1a
    4411:	mov    rdx,QWORD PTR [rip+0x0]        # 4418 <botlish_fn_21+0x128>
			4414: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; scan_local<generic>
    4418:	mov    r13d,0x2
    441e:	mov    rcx,r13
    4421:	mov    rdi,r15
    4424:	call   4429 <botlish_fn_21+0x139>
			4425: R_X86_64_PLT32	rt_closure_new-0x4
    4429:	mov    r12,rax
    442c:	mov    QWORD PTR [rsp+0x10],r12
    4431:	lea    r8,[rsp+0x40]
    4436:	mov    rax,QWORD PTR [rsp+0xb0]
    443e:	mov    QWORD PTR [rsp+0x40],rax
    4443:	mov    rax,r14
    4446:	mov    QWORD PTR [rsp+0x48],rax
    444b:	mov    esi,0x1b
    4450:	mov    rdx,QWORD PTR [rip+0x0]        # 4457 <botlish_fn_21+0x167>
			4453: R_X86_64_GOTPCREL	botlish_entry_27-0x4 ; scan_label<generic>
    4457:	mov    rcx,r13
    445a:	mov    rdi,r15
    445d:	call   4462 <botlish_fn_21+0x172>
			445e: R_X86_64_PLT32	rt_closure_new-0x4
    4462:	mov    QWORD PTR [rsp+0x18],rax
    4467:	mov    QWORD PTR [rsp+0xa0],rax
    446f:	lea    r8,[rsp+0x50]
    4474:	mov    rax,QWORD PTR [rsp+0xb0]
    447c:	mov    QWORD PTR [rsp+0x50],rax
    4481:	mov    QWORD PTR [rsp+0x58],r14
    4486:	mov    esi,0x1c
    448b:	mov    rdx,QWORD PTR [rip+0x0]        # 4492 <botlish_fn_21+0x1a2>
			448e: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; scan_alpha<generic>
    4492:	mov    rcx,r13
    4495:	mov    rdi,r15
    4498:	call   449d <botlish_fn_21+0x1ad>
			4499: R_X86_64_PLT32	rt_closure_new-0x4
    449d:	mov    QWORD PTR [rsp+0x20],rax
    44a2:	lea    r8,[rsp+0x60]
    44a7:	mov    QWORD PTR [rsp+0x60],rax
    44ac:	mov    rax,QWORD PTR [rsp+0xb0]
    44b4:	mov    QWORD PTR [rsp+0x68],rax
    44b9:	mov    esi,0x1d
    44be:	mov    rdx,QWORD PTR [rip+0x0]        # 44c5 <botlish_fn_21+0x1d5>
			44c1: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; tld_ok<generic>
    44c5:	mov    rcx,r13
    44c8:	mov    rdi,r15
    44cb:	call   44d0 <botlish_fn_21+0x1e0>
			44cc: R_X86_64_PLT32	rt_closure_new-0x4
    44d0:	mov    QWORD PTR [rsp+0x20],rax
    44d5:	lea    r8,[rsp+0x70]
    44da:	mov    rsi,QWORD PTR [rsp+0xa0]
    44e2:	mov    QWORD PTR [rsp+0x70],rsi
    44e7:	mov    rcx,QWORD PTR [rsp+0xb0]
    44ef:	mov    QWORD PTR [rsp+0x78],rcx
    44f4:	mov    QWORD PTR [rsp+0x80],r14
    44fc:	mov    QWORD PTR [rsp+0x88],rax
    4504:	mov    esi,0x1e
    4509:	mov    rdx,QWORD PTR [rip+0x0]        # 4510 <botlish_fn_21+0x220>
			450c: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; domain_loop<generic>
    4510:	mov    ecx,0x4
    4515:	mov    rdi,r15
    4518:	call   451d <botlish_fn_21+0x22d>
			4519: R_X86_64_PLT32	rt_closure_new-0x4
    451d:	mov    QWORD PTR [rsp+0x18],rax
    4522:	mov    QWORD PTR [rsp+0xa0],rax
    452a:	mov    QWORD PTR [rsp+0x20],0x1
    4533:	mov    rsi,r12
    4536:	mov    rdx,QWORD PTR [rsp+0xa8]
    453e:	mov    rdi,r15
    4541:	call   4546 <botlish_fn_21+0x256>
			4542: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    4546:	mov    rcx,rax
    4549:	mov    r12,rax
    454c:	test   rax,rcx
    454f:	jne    455d <botlish_fn_21+0x26d>
    4555:	mov    rdi,r15
    4558:	jmp    46c9 <botlish_fn_21+0x3d9>
    455d:	mov    rax,r12
    4560:	mov    QWORD PTR [rsp+0x10],rax
    4565:	test   rax,0x1
    456b:	jne    4599 <botlish_fn_21+0x2a9>
    4571:	mov    rdx,QWORD PTR [rsp+0xa8]
    4579:	mov    rsi,r12
    457c:	mov    rdi,r15
    457f:	call   4584 <botlish_fn_21+0x294>
			4580: R_X86_64_PLT32	rt_int_cmp-0x4
    4584:	mov    ecx,0x2
    4589:	test   rax,rax
    458c:	cmove  rcx,QWORD PTR [rip+0x264]        # 47f8 <botlish_fn_21+0x508>
    4594:	jmp    45aa <botlish_fn_21+0x2ba>
    4599:	mov    ecx,0x2
    459e:	cmp    r12,0x1
    45a2:	cmove  rcx,QWORD PTR [rip+0x24e]        # 47f8 <botlish_fn_21+0x508>
    45aa:	cmp    rcx,0x6
    45ae:	je     4776 <botlish_fn_21+0x486>
    45b4:	mov    r13,QWORD PTR [rsp+0xb0]
    45bc:	mov    rax,r12
    45bf:	and    rax,r13
    45c2:	test   rax,0x1
    45c8:	jne    45f1 <botlish_fn_21+0x301>
    45ce:	mov    rdx,r13
    45d1:	mov    rsi,r12
    45d4:	mov    rdi,r15
    45d7:	call   45dc <botlish_fn_21+0x2ec>
			45d8: R_X86_64_PLT32	rt_int_cmp-0x4
    45dc:	mov    ecx,0x2
    45e1:	test   rax,rax
    45e4:	cmovge rcx,QWORD PTR [rip+0x20c]        # 47f8 <botlish_fn_21+0x508>
    45ec:	jmp    4601 <botlish_fn_21+0x311>
    45f1:	mov    ecx,0x2
    45f6:	cmp    r12,r13
    45f9:	cmovge rcx,QWORD PTR [rip+0x1f7]        # 47f8 <botlish_fn_21+0x508>
    4601:	cmp    rcx,0x6
    4605:	je     4769 <botlish_fn_21+0x479>
    460b:	lea    rcx,[rsp+0x90]
    4613:	mov    rsi,r14
    4616:	mov    rdx,r12
    4619:	mov    rdi,r15
    461c:	call   4621 <botlish_fn_21+0x331>
			461d: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    4621:	test   rax,rax
    4624:	mov    rsi,rax
    4627:	jne    4635 <botlish_fn_21+0x345>
    462d:	mov    rdi,r15
    4630:	jmp    46c9 <botlish_fn_21+0x3d9>
    4635:	mov    rdx,QWORD PTR [rsp+0x90]
    463d:	mov    rcx,QWORD PTR [rsp+0x98]
    4645:	mov    rdi,r15
    4648:	mov    rax,QWORD PTR [rdi+0x10]
    464c:	mov    r8,QWORD PTR [rax+0x100]
    4653:	call   4658 <botlish_fn_21+0x368>
			4654: R_X86_64_PLT32	rt_str_region_eq-0x4
    4658:	cmp    rax,0x6
    465c:	je     466f <botlish_fn_21+0x37f>
    4662:	mov    esi,0x2
    4667:	mov    rax,rsi
    466a:	jmp    476e <botlish_fn_21+0x47e>
    466f:	mov    QWORD PTR [rsp],0x3
    4677:	test   r12,0x1
    467e:	je     4696 <botlish_fn_21+0x3a6>
    4684:	mov    rdx,r12
    4687:	add    rdx,0x2
    468b:	seto   al
    468e:	test   al,al
    4690:	je     46a9 <botlish_fn_21+0x3b9>
    4696:	mov    edx,0x3
    469b:	mov    rsi,r12
    469e:	mov    rdi,r15
    46a1:	call   46a6 <botlish_fn_21+0x3b6>
			46a2: R_X86_64_PLT32	rt_int_add-0x4
    46a6:	mov    rdx,rax
    46a9:	mov    QWORD PTR [rsp],rdx
    46ad:	mov    rsi,QWORD PTR [rsp+0xa0]
    46b5:	mov    rdi,r15
    46b8:	call   46bd <botlish_fn_21+0x3cd>
			46b9: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    46bd:	test   rax,rax
    46c0:	jne    4706 <botlish_fn_21+0x416>
    46c6:	mov    rdi,r15
    46c9:	mov    rdi,r15
    46cc:	mov    QWORD PTR [rdi],rbx
    46cf:	xor    rax,rax
    46d2:	mov    rbx,QWORD PTR [rsp+0xc0]
    46da:	mov    r12,QWORD PTR [rsp+0xc8]
    46e2:	mov    r13,QWORD PTR [rsp+0xd0]
    46ea:	mov    r14,QWORD PTR [rsp+0xd8]
    46f2:	mov    r15,QWORD PTR [rsp+0xe0]
    46fa:	add    rsp,0xf0
    4701:	mov    rsp,rbp
    4704:	pop    rbp
    4705:	ret
    4706:	mov    rcx,rax
    4709:	and    rcx,r13
    470c:	mov    rsi,rax
    470f:	mov    QWORD PTR [rsp+0xb0],r13
    4717:	test   rcx,0x1
    471e:	jne    474c <botlish_fn_21+0x45c>
    4724:	mov    rdx,QWORD PTR [rsp+0xb0]
    472c:	mov    rdi,r15
    472f:	call   4734 <botlish_fn_21+0x444>
			4730: R_X86_64_PLT32	rt_int_cmp-0x4
    4734:	mov    esi,0x2
    4739:	test   rax,rax
    473c:	mov    rax,rsi
    473f:	cmove  rax,QWORD PTR [rip+0xb1]        # 47f8 <botlish_fn_21+0x508>
    4747:	jmp    476e <botlish_fn_21+0x47e>
    474c:	mov    rdx,QWORD PTR [rsp+0xb0]
    4754:	mov    eax,0x2
    4759:	cmp    rsi,rdx
    475c:	cmove  rax,QWORD PTR [rip+0x94]        # 47f8 <botlish_fn_21+0x508>
    4764:	jmp    476e <botlish_fn_21+0x47e>
    4769:	mov    eax,0x2
    476e:	mov    rdi,r15
    4771:	jmp    477e <botlish_fn_21+0x48e>
    4776:	mov    eax,0x2
    477b:	mov    rdi,r15
    477e:	mov    rdi,r15
    4781:	mov    QWORD PTR [rdi],rbx
    4784:	mov    rbx,QWORD PTR [rsp+0xc0]
    478c:	mov    r12,QWORD PTR [rsp+0xc8]
    4794:	mov    r13,QWORD PTR [rsp+0xd0]
    479c:	mov    r14,QWORD PTR [rsp+0xd8]
    47a4:	mov    r15,QWORD PTR [rsp+0xe0]
    47ac:	add    rsp,0xf0
    47b3:	mov    rsp,rbp
    47b6:	pop    rbp
    47b7:	ret
    47b8:	mov    r15,rdi
    47bb:	call   47c0 <botlish_fn_21+0x4d0>
			47bc: R_X86_64_PLT32	rt_stack_overflow-0x4
    47c0:	xor    rax,rax
    47c3:	mov    rbx,QWORD PTR [rsp+0xc0]
    47cb:	mov    r12,QWORD PTR [rsp+0xc8]
    47d3:	mov    r13,QWORD PTR [rsp+0xd0]
    47db:	mov    r14,QWORD PTR [rsp+0xd8]
    47e3:	mov    r15,QWORD PTR [rsp+0xe0]
    47eb:	add    rsp,0xf0
    47f2:	mov    rsp,rbp
    47f5:	pop    rbp
    47f6:	ret
    47f7:	add    BYTE PTR [rsi],al
    47f9:	add    BYTE PTR [rax],al
    47fb:	add    BYTE PTR [rax],al
    47fd:	add    BYTE PTR [rax],al
	...

0000000000004800 <botlish_entry_21: <generic>>:
    4800:	push   rbp
    4801:	mov    rbp,rsp
    4804:	mov    rsi,QWORD PTR [rdx]
    4807:	call   480c <botlish_entry_21+0xc>
			4808: R_X86_64_PLT32	botlish_fn_21-0x4 ; <generic>
    480c:	mov    rsp,rbp
    480f:	pop    rbp
    4810:	ret

0000000000004811 <botlish_fn_22: char_at<generic>>:
    4811:	push   rbp
    4812:	mov    rbp,rsp
    4815:	sub    rsp,0x40
    4819:	mov    QWORD PTR [rsp+0x20],rbx
    481e:	mov    QWORD PTR [rsp+0x28],r12
    4823:	mov    QWORD PTR [rsp+0x30],r13
    4828:	mov    QWORD PTR [rsp],rdx
    482c:	mov    rax,QWORD PTR [rsi+0x20]
    4830:	mov    rsi,QWORD PTR [rax]
    4833:	mov    QWORD PTR [rsp+0x8],rsi
    4838:	mov    r13,rsi
    483b:	mov    QWORD PTR [rsp+0x10],0x3
    4844:	mov    r10d,0x1
    484a:	test   rdx,0x1
    4851:	je     485f <botlish_fn_22+0x4e>
    4857:	mov    rbx,rdx
    485a:	jmp    4884 <botlish_fn_22+0x73>
    485f:	xor    r10d,r10d
    4862:	test   rdx,0x7
    4869:	je     4877 <botlish_fn_22+0x66>
    486f:	mov    rbx,rdx
    4872:	jmp    4884 <botlish_fn_22+0x73>
    4877:	movzx  rax,BYTE PTR [rdx]
    487b:	mov    rbx,rdx
    487e:	cmp    al,0x1
    4880:	sete   r10b
    4884:	test   r10b,r10b
    4887:	jne    48a8 <botlish_fn_22+0x97>
    488d:	mov    rax,QWORD PTR [rdi+0x10]
    4891:	mov    rcx,QWORD PTR [rax+0x108]
    4898:	xor    rdx,rdx
    489b:	mov    rsi,rbx
    489e:	call   48a3 <botlish_fn_22+0x92>
			489f: R_X86_64_PLT32	rt_type_error-0x4
    48a3:	jmp    495a <botlish_fn_22+0x149>
    48a8:	mov    rsi,rbx
    48ab:	mov    r12,rdi
    48ae:	test   rsi,0x1
    48b5:	je     48d0 <botlish_fn_22+0xbf>
    48bb:	mov    rsi,rbx
    48be:	mov    rcx,rsi
    48c1:	add    rcx,0x2
    48c5:	seto   al
    48c8:	test   al,al
    48ca:	je     48e3 <botlish_fn_22+0xd2>
    48d0:	mov    edx,0x3
    48d5:	mov    rsi,rbx
    48d8:	mov    rdi,r12
    48db:	call   48e0 <botlish_fn_22+0xcf>
			48dc: R_X86_64_PLT32	rt_int_add-0x4
    48e0:	mov    rcx,rax
    48e3:	mov    QWORD PTR [rsp+0x10],rcx
    48e8:	mov    eax,0x1
    48ed:	mov    rsi,rbx
    48f0:	test   rsi,0x1
    48f7:	jne    491d <botlish_fn_22+0x10c>
    48fd:	xor    eax,eax
    48ff:	mov    rsi,rbx
    4902:	test   rsi,0x7
    4909:	jne    491d <botlish_fn_22+0x10c>
    490f:	mov    rsi,rbx
    4912:	movzx  rdx,BYTE PTR [rsi]
    4916:	rex cmp dl,0x1
    491a:	sete   al
    491d:	test   al,al
    491f:	jne    4943 <botlish_fn_22+0x132>
    4925:	mov    rdi,r12
    4928:	mov    rsi,QWORD PTR [rdi+0x10]
    492c:	mov    rcx,QWORD PTR [rsi+0x110]
    4933:	xor    rdx,rdx
    4936:	mov    rsi,rbx
    4939:	call   493e <botlish_fn_22+0x12d>
			493a: R_X86_64_PLT32	rt_type_error-0x4
    493e:	jmp    495a <botlish_fn_22+0x149>
    4943:	mov    rdx,rbx
    4946:	mov    rsi,r13
    4949:	mov    rdi,r12
    494c:	call   4951 <botlish_fn_22+0x140>
			494d: R_X86_64_PLT32	rt_substr-0x4
    4951:	test   rax,rax
    4954:	jne    4975 <botlish_fn_22+0x164>
    495a:	xor    rax,rax
    495d:	mov    rbx,QWORD PTR [rsp+0x20]
    4962:	mov    r12,QWORD PTR [rsp+0x28]
    4967:	mov    r13,QWORD PTR [rsp+0x30]
    496c:	add    rsp,0x40
    4970:	mov    rsp,rbp
    4973:	pop    rbp
    4974:	ret
    4975:	mov    rbx,QWORD PTR [rsp+0x20]
    497a:	mov    r12,QWORD PTR [rsp+0x28]
    497f:	mov    r13,QWORD PTR [rsp+0x30]
    4984:	add    rsp,0x40
    4988:	mov    rsp,rbp
    498b:	pop    rbp
    498c:	ret

000000000000498d <botlish_entry_22: char_at<generic>>:
    498d:	push   rbp
    498e:	mov    rbp,rsp
    4991:	mov    rdx,QWORD PTR [rdx]
    4994:	call   4999 <botlish_entry_22+0xc>
			4995: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    4999:	mov    rsp,rbp
    499c:	pop    rbp
    499d:	ret

000000000000499e <botlish_fn_23: char_at<generic>>:
    499e:	push   rbp
    499f:	mov    rbp,rsp
    49a2:	sub    rsp,0x40
    49a6:	mov    QWORD PTR [rsp+0x20],rbx
    49ab:	mov    QWORD PTR [rsp+0x28],r12
    49b0:	mov    QWORD PTR [rsp+0x30],r13
    49b5:	mov    QWORD PTR [rsp+0x38],r14
    49ba:	mov    r13,rcx
    49bd:	mov    QWORD PTR [rsp],rdx
    49c1:	mov    rax,QWORD PTR [rsi+0x20]
    49c5:	mov    rax,QWORD PTR [rax]
    49c8:	mov    QWORD PTR [rsp+0x8],rax
    49cd:	mov    r14,rax
    49d0:	mov    QWORD PTR [rsp+0x10],0x3
    49d9:	mov    r11d,0x1
    49df:	test   rdx,0x1
    49e6:	je     49f4 <botlish_fn_23+0x56>
    49ec:	mov    r12,rdx
    49ef:	jmp    4a19 <botlish_fn_23+0x7b>
    49f4:	xor    r11d,r11d
    49f7:	test   rdx,0x7
    49fe:	je     4a0c <botlish_fn_23+0x6e>
    4a04:	mov    r12,rdx
    4a07:	jmp    4a19 <botlish_fn_23+0x7b>
    4a0c:	movzx  rax,BYTE PTR [rdx]
    4a10:	mov    r12,rdx
    4a13:	cmp    al,0x1
    4a15:	sete   r11b
    4a19:	test   r11b,r11b
    4a1c:	jne    4a3d <botlish_fn_23+0x9f>
    4a22:	mov    rax,QWORD PTR [rdi+0x10]
    4a26:	mov    rcx,QWORD PTR [rax+0x108]
    4a2d:	xor    rdx,rdx
    4a30:	mov    rsi,r12
    4a33:	call   4a38 <botlish_fn_23+0x9a>
			4a34: R_X86_64_PLT32	rt_type_error-0x4
    4a38:	jmp    4af5 <botlish_fn_23+0x157>
    4a3d:	mov    rbx,rdi
    4a40:	mov    rsi,r12
    4a43:	test   rsi,0x1
    4a4a:	jne    4a58 <botlish_fn_23+0xba>
    4a50:	mov    r12,rsi
    4a53:	jmp    4a6d <botlish_fn_23+0xcf>
    4a58:	mov    rax,rsi
    4a5b:	add    rax,0x2
    4a5f:	mov    r12,rsi
    4a62:	seto   cl
    4a65:	test   cl,cl
    4a67:	je     4a7d <botlish_fn_23+0xdf>
    4a6d:	mov    edx,0x3
    4a72:	mov    rsi,r12
    4a75:	mov    rdi,rbx
    4a78:	call   4a7d <botlish_fn_23+0xdf>
			4a79: R_X86_64_PLT32	rt_int_add-0x4
    4a7d:	mov    ecx,0x1
    4a82:	mov    rsi,r12
    4a85:	test   rsi,0x1
    4a8c:	jne    4ab2 <botlish_fn_23+0x114>
    4a92:	xor    ecx,ecx
    4a94:	mov    rsi,r12
    4a97:	test   rsi,0x7
    4a9e:	jne    4ab2 <botlish_fn_23+0x114>
    4aa4:	mov    rsi,r12
    4aa7:	movzx  rdx,BYTE PTR [rsi]
    4aab:	rex cmp dl,0x1
    4aaf:	sete   cl
    4ab2:	test   cl,cl
    4ab4:	jne    4ad8 <botlish_fn_23+0x13a>
    4aba:	mov    rdi,rbx
    4abd:	mov    rsi,QWORD PTR [rdi+0x10]
    4ac1:	mov    rcx,QWORD PTR [rsi+0x110]
    4ac8:	xor    rdx,rdx
    4acb:	mov    rsi,r12
    4ace:	call   4ad3 <botlish_fn_23+0x135>
			4acf: R_X86_64_PLT32	rt_type_error-0x4
    4ad3:	jmp    4af5 <botlish_fn_23+0x157>
    4ad8:	mov    rdi,rbx
    4adb:	mov    rbx,rax
    4ade:	mov    rcx,rbx
    4ae1:	mov    rdx,r12
    4ae4:	mov    rsi,r14
    4ae7:	call   4aec <botlish_fn_23+0x14e>
			4ae8: R_X86_64_PLT32	rt_str_region_check-0x4
    4aec:	test   rax,rax
    4aef:	jne    4b15 <botlish_fn_23+0x177>
    4af5:	xor    rax,rax
    4af8:	mov    rbx,QWORD PTR [rsp+0x20]
    4afd:	mov    r12,QWORD PTR [rsp+0x28]
    4b02:	mov    r13,QWORD PTR [rsp+0x30]
    4b07:	mov    r14,QWORD PTR [rsp+0x38]
    4b0c:	add    rsp,0x40
    4b10:	mov    rsp,rbp
    4b13:	pop    rbp
    4b14:	ret
    4b15:	mov    rcx,r13
    4b18:	mov    rsi,r12
    4b1b:	mov    QWORD PTR [rcx],rsi
    4b1e:	mov    QWORD PTR [rcx+0x8],rbx
    4b22:	mov    rax,r14
    4b25:	mov    rbx,QWORD PTR [rsp+0x20]
    4b2a:	mov    r12,QWORD PTR [rsp+0x28]
    4b2f:	mov    r13,QWORD PTR [rsp+0x30]
    4b34:	mov    r14,QWORD PTR [rsp+0x38]
    4b39:	add    rsp,0x40
    4b3d:	mov    rsp,rbp
    4b40:	pop    rbp
    4b41:	ret

0000000000004b42 <botlish_entry_23: char_at<generic>>:
    4b42:	push   rbp
    4b43:	mov    rbp,rsp
    4b46:	ud2

0000000000004b48 <botlish_fn_24: is_local_char<str>>:
    4b48:	push   rbp
    4b49:	mov    rbp,rsp
    4b4c:	sub    rsp,0x10
    4b50:	mov    QWORD PTR [rsp],rbx
    4b54:	mov    QWORD PTR [rsp+0x8],r12
    4b59:	mov    rbx,rsi
    4b5c:	mov    r12,rdi
    4b5f:	mov    rsi,rbx
    4b62:	mov    rdi,r12
    4b65:	call   4b6a <botlish_fn_24+0x22>
			4b66: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    4b6a:	test   rax,rax
    4b6d:	jne    4b88 <botlish_fn_24+0x40>
    4b73:	xor    rax,rax
    4b76:	mov    rbx,QWORD PTR [rsp]
    4b7a:	mov    r12,QWORD PTR [rsp+0x8]
    4b7f:	add    rsp,0x10
    4b83:	mov    rsp,rbp
    4b86:	pop    rbp
    4b87:	ret
    4b88:	cmp    rax,0x6
    4b8c:	je     4c87 <botlish_fn_24+0x13f>
    4b92:	mov    rdi,r12
    4b95:	mov    rax,QWORD PTR [rdi+0x10]
    4b99:	mov    rsi,QWORD PTR [rax+0x118]
    4ba0:	mov    edx,0x1
    4ba5:	mov    ecx,0x3
    4baa:	mov    r8,rbx
    4bad:	call   4bb2 <botlish_fn_24+0x6a>
			4bae: R_X86_64_PLT32	rt_str_region_eq-0x4
    4bb2:	cmp    rax,0x6
    4bb6:	je     4c7d <botlish_fn_24+0x135>
    4bbc:	mov    rdi,r12
    4bbf:	mov    rax,QWORD PTR [rdi+0x10]
    4bc3:	mov    rsi,QWORD PTR [rax+0x120]
    4bca:	mov    edx,0x1
    4bcf:	mov    ecx,0x3
    4bd4:	mov    r8,rbx
    4bd7:	call   4bdc <botlish_fn_24+0x94>
			4bd8: R_X86_64_PLT32	rt_str_region_eq-0x4
    4bdc:	cmp    rax,0x6
    4be0:	je     4c73 <botlish_fn_24+0x12b>
    4be6:	mov    rdi,r12
    4be9:	mov    rax,QWORD PTR [rdi+0x10]
    4bed:	mov    rsi,QWORD PTR [rax+0xc0]
    4bf4:	mov    edx,0x1
    4bf9:	mov    ecx,0x3
    4bfe:	mov    r8,rbx
    4c01:	call   4c06 <botlish_fn_24+0xbe>
			4c02: R_X86_64_PLT32	rt_str_region_eq-0x4
    4c06:	cmp    rax,0x6
    4c0a:	je     4c69 <botlish_fn_24+0x121>
    4c10:	mov    rdi,r12
    4c13:	mov    rax,QWORD PTR [rdi+0x10]
    4c17:	mov    rsi,QWORD PTR [rax+0x108]
    4c1e:	mov    edx,0x1
    4c23:	mov    ecx,0x3
    4c28:	mov    r8,rbx
    4c2b:	call   4c30 <botlish_fn_24+0xe8>
			4c2c: R_X86_64_PLT32	rt_str_region_eq-0x4
    4c30:	cmp    rax,0x6
    4c34:	je     4c5f <botlish_fn_24+0x117>
    4c3a:	mov    rdi,r12
    4c3d:	mov    rax,QWORD PTR [rdi+0x10]
    4c41:	mov    rsi,QWORD PTR [rax+0x128]
    4c48:	mov    edx,0x1
    4c4d:	mov    ecx,0x3
    4c52:	mov    r8,rbx
    4c55:	call   4c5a <botlish_fn_24+0x112>
			4c56: R_X86_64_PLT32	rt_str_region_eq-0x4
    4c5a:	jmp    4c8c <botlish_fn_24+0x144>
    4c5f:	mov    eax,0x6
    4c64:	jmp    4c8c <botlish_fn_24+0x144>
    4c69:	mov    eax,0x6
    4c6e:	jmp    4c8c <botlish_fn_24+0x144>
    4c73:	mov    eax,0x6
    4c78:	jmp    4c8c <botlish_fn_24+0x144>
    4c7d:	mov    eax,0x6
    4c82:	jmp    4c8c <botlish_fn_24+0x144>
    4c87:	mov    eax,0x6
    4c8c:	mov    rbx,QWORD PTR [rsp]
    4c90:	mov    r12,QWORD PTR [rsp+0x8]
    4c95:	add    rsp,0x10
    4c99:	mov    rsp,rbp
    4c9c:	pop    rbp
    4c9d:	ret

0000000000004c9e <botlish_entry_24: is_local_char<str>>:
    4c9e:	push   rbp
    4c9f:	mov    rbp,rsp
    4ca2:	mov    rsi,QWORD PTR [rdx]
    4ca5:	call   4caa <botlish_entry_24+0xc>
			4ca6: R_X86_64_PLT32	botlish_fn_24-0x4 ; is_local_char<str>
    4caa:	mov    rsp,rbp
    4cad:	pop    rbp
    4cae:	ret

0000000000004caf <botlish_fn_25: is_label_char<str>>:
    4caf:	push   rbp
    4cb0:	mov    rbp,rsp
    4cb3:	sub    rsp,0x10
    4cb7:	mov    QWORD PTR [rsp],r13
    4cbb:	mov    QWORD PTR [rsp+0x8],r15
    4cc0:	mov    r13,rsi
    4cc3:	mov    r15,rdi
    4cc6:	mov    rsi,r13
    4cc9:	mov    rdi,r15
    4ccc:	call   4cd1 <botlish_fn_25+0x22>
			4ccd: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    4cd1:	test   rax,rax
    4cd4:	jne    4cef <botlish_fn_25+0x40>
    4cda:	xor    rax,rax
    4cdd:	mov    r13,QWORD PTR [rsp]
    4ce1:	mov    r15,QWORD PTR [rsp+0x8]
    4ce6:	add    rsp,0x10
    4cea:	mov    rsp,rbp
    4ced:	pop    rbp
    4cee:	ret
    4cef:	cmp    rax,0x6
    4cf3:	je     4d1e <botlish_fn_25+0x6f>
    4cf9:	mov    rdi,r15
    4cfc:	mov    rax,QWORD PTR [rdi+0x10]
    4d00:	mov    rsi,QWORD PTR [rax+0x128]
    4d07:	mov    edx,0x1
    4d0c:	mov    ecx,0x3
    4d11:	mov    r8,r13
    4d14:	call   4d19 <botlish_fn_25+0x6a>
			4d15: R_X86_64_PLT32	rt_str_region_eq-0x4
    4d19:	jmp    4d23 <botlish_fn_25+0x74>
    4d1e:	mov    eax,0x6
    4d23:	mov    r13,QWORD PTR [rsp]
    4d27:	mov    r15,QWORD PTR [rsp+0x8]
    4d2c:	add    rsp,0x10
    4d30:	mov    rsp,rbp
    4d33:	pop    rbp
    4d34:	ret

0000000000004d35 <botlish_entry_25: is_label_char<str>>:
    4d35:	push   rbp
    4d36:	mov    rbp,rsp
    4d39:	mov    rsi,QWORD PTR [rdx]
    4d3c:	call   4d41 <botlish_entry_25+0xc>
			4d3d: R_X86_64_PLT32	botlish_fn_25-0x4 ; is_label_char<str>
    4d41:	mov    rsp,rbp
    4d44:	pop    rbp
    4d45:	ret
	...

0000000000004d48 <botlish_fn_26: scan_local<generic>>:
    4d48:	push   rbp
    4d49:	mov    rbp,rsp
    4d4c:	sub    rsp,0x40
    4d50:	mov    QWORD PTR [rsp+0x20],rbx
    4d55:	mov    QWORD PTR [rsp+0x28],r12
    4d5a:	mov    QWORD PTR [rsp+0x30],r13
    4d5f:	mov    QWORD PTR [rsp+0x38],r14
    4d64:	mov    r12,QWORD PTR [rdi]
    4d67:	mov    rax,QWORD PTR [rdi+0x8]
    4d6b:	lea    rcx,[r12+0x8]
    4d70:	cmp    rcx,rax
    4d73:	ja     4f51 <botlish_fn_26+0x209>
    4d79:	lea    rax,[r12+0x8]
    4d7e:	mov    QWORD PTR [rdi],rax
    4d81:	mov    r13,rdi
    4d84:	mov    QWORD PTR [r12],0x0
    4d8c:	mov    QWORD PTR [rsp+0x10],0x0
    4d95:	mov    QWORD PTR [rsp],rdx
    4d99:	mov    rbx,rsi
    4d9c:	mov    rsi,rdx
    4d9f:	mov    rax,QWORD PTR [rbx+0x20]
    4da3:	mov    rdx,QWORD PTR [rax]
    4da6:	mov    ecx,0x1
    4dab:	test   rsi,0x1
    4db2:	jne    4dd0 <botlish_fn_26+0x88>
    4db8:	xor    ecx,ecx
    4dba:	test   rsi,0x7
    4dc1:	jne    4dd0 <botlish_fn_26+0x88>
    4dc7:	movzx  rax,BYTE PTR [rsi]
    4dcb:	cmp    al,0x1
    4dcd:	sete   cl
    4dd0:	test   cl,cl
    4dd2:	jne    4df6 <botlish_fn_26+0xae>
    4dd8:	mov    rdi,r13
    4ddb:	mov    rax,QWORD PTR [rdi+0x10]
    4ddf:	mov    rcx,QWORD PTR [rax+0xb8]
    4de6:	xor    rdx,rdx
    4de9:	call   4dee <botlish_fn_26+0xa6>
			4dea: R_X86_64_PLT32	rt_type_error-0x4
    4dee:	mov    rdi,r13
    4df1:	jmp    4e8d <botlish_fn_26+0x145>
    4df6:	mov    rax,rsi
    4df9:	and    rax,rdx
    4dfc:	mov    r14,rsi
    4dff:	test   rax,0x1
    4e05:	jne    4e2b <botlish_fn_26+0xe3>
    4e0b:	mov    rsi,r14
    4e0e:	mov    rdi,r13
    4e11:	call   4e16 <botlish_fn_26+0xce>
			4e12: R_X86_64_PLT32	rt_int_cmp-0x4
    4e16:	mov    ecx,0x2
    4e1b:	test   rax,rax
    4e1e:	cmovge rcx,QWORD PTR [rip+0x15a]        # 4f80 <botlish_fn_26+0x238>
    4e26:	jmp    4e3e <botlish_fn_26+0xf6>
    4e2b:	mov    ecx,0x2
    4e30:	mov    rsi,r14
    4e33:	cmp    rsi,rdx
    4e36:	cmovge rcx,QWORD PTR [rip+0x142]        # 4f80 <botlish_fn_26+0x238>
    4e3e:	cmp    rcx,0x6
    4e42:	je     4f28 <botlish_fn_26+0x1e0>
    4e48:	mov    rsi,QWORD PTR [rbx+0x20]
    4e4c:	mov    rsi,QWORD PTR [rsi+0x8]
    4e50:	mov    QWORD PTR [rsp+0x8],rsi
    4e55:	mov    rdx,r14
    4e58:	mov    rdi,r13
    4e5b:	call   4e60 <botlish_fn_26+0x118>
			4e5c: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    4e60:	test   rax,rax
    4e63:	jne    4e71 <botlish_fn_26+0x129>
    4e69:	mov    rdi,r13
    4e6c:	jmp    4e8d <botlish_fn_26+0x145>
    4e71:	mov    QWORD PTR [rsp+0x8],rax
    4e76:	mov    rsi,rax
    4e79:	mov    rdi,r13
    4e7c:	call   4e81 <botlish_fn_26+0x139>
			4e7d: R_X86_64_PLT32	botlish_fn_24-0x4 ; is_local_char<str>
    4e81:	test   rax,rax
    4e84:	jne    4eb3 <botlish_fn_26+0x16b>
    4e8a:	mov    rdi,r13
    4e8d:	mov    rdi,r13
    4e90:	mov    QWORD PTR [rdi],r12
    4e93:	xor    rax,rax
    4e96:	mov    rbx,QWORD PTR [rsp+0x20]
    4e9b:	mov    r12,QWORD PTR [rsp+0x28]
    4ea0:	mov    r13,QWORD PTR [rsp+0x30]
    4ea5:	mov    r14,QWORD PTR [rsp+0x38]
    4eaa:	add    rsp,0x40
    4eae:	mov    rsp,rbp
    4eb1:	pop    rbp
    4eb2:	ret
    4eb3:	cmp    rax,0x6
    4eb7:	je     4ec8 <botlish_fn_26+0x180>
    4ebd:	mov    rax,r14
    4ec0:	mov    rdi,r13
    4ec3:	jmp    4f2e <botlish_fn_26+0x1e6>
    4ec8:	mov    QWORD PTR [rsp+0x8],rbx
    4ecd:	mov    QWORD PTR [rsp+0x10],0x3
    4ed6:	mov    rsi,r14
    4ed9:	test   rsi,0x1
    4ee0:	je     4f06 <botlish_fn_26+0x1be>
    4ee6:	mov    rsi,r14
    4ee9:	mov    rcx,rsi
    4eec:	add    rcx,0x2
    4ef0:	seto   al
    4ef3:	test   al,al
    4ef5:	jne    4f06 <botlish_fn_26+0x1be>
    4efb:	mov    rsi,rcx
    4efe:	mov    r14,rcx
    4f01:	jmp    4f1c <botlish_fn_26+0x1d4>
    4f06:	mov    edx,0x3
    4f0b:	mov    rsi,r14
    4f0e:	mov    rdi,r13
    4f11:	call   4f16 <botlish_fn_26+0x1ce>
			4f12: R_X86_64_PLT32	rt_int_add-0x4
    4f16:	mov    rsi,rax
    4f19:	mov    r14,rax
    4f1c:	mov    QWORD PTR [rsp],rsi
    4f20:	mov    rsi,r14
    4f23:	jmp    4d9f <botlish_fn_26+0x57>
    4f28:	mov    rax,r14
    4f2b:	mov    rdi,r13
    4f2e:	mov    rdi,r13
    4f31:	mov    QWORD PTR [rdi],r12
    4f34:	mov    rbx,QWORD PTR [rsp+0x20]
    4f39:	mov    r12,QWORD PTR [rsp+0x28]
    4f3e:	mov    r13,QWORD PTR [rsp+0x30]
    4f43:	mov    r14,QWORD PTR [rsp+0x38]
    4f48:	add    rsp,0x40
    4f4c:	mov    rsp,rbp
    4f4f:	pop    rbp
    4f50:	ret
    4f51:	mov    r13,rdi
    4f54:	call   4f59 <botlish_fn_26+0x211>
			4f55: R_X86_64_PLT32	rt_stack_overflow-0x4
    4f59:	xor    rax,rax
    4f5c:	mov    rbx,QWORD PTR [rsp+0x20]
    4f61:	mov    r12,QWORD PTR [rsp+0x28]
    4f66:	mov    r13,QWORD PTR [rsp+0x30]
    4f6b:	mov    r14,QWORD PTR [rsp+0x38]
    4f70:	add    rsp,0x40
    4f74:	mov    rsp,rbp
    4f77:	pop    rbp
    4f78:	ret
    4f79:	add    BYTE PTR [rax],al
    4f7b:	add    BYTE PTR [rax],al
    4f7d:	add    BYTE PTR [rax],al
    4f7f:	add    BYTE PTR [rsi],al
    4f81:	add    BYTE PTR [rax],al
    4f83:	add    BYTE PTR [rax],al
    4f85:	add    BYTE PTR [rax],al
	...

0000000000004f88 <botlish_entry_26: scan_local<generic>>:
    4f88:	push   rbp
    4f89:	mov    rbp,rsp
    4f8c:	mov    rdx,QWORD PTR [rdx]
    4f8f:	call   4f94 <botlish_entry_26+0xc>
			4f90: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    4f94:	mov    rsp,rbp
    4f97:	pop    rbp
    4f98:	ret
    4f99:	add    BYTE PTR [rax],al
    4f9b:	add    BYTE PTR [rax],al
    4f9d:	add    BYTE PTR [rax],al
	...

0000000000004fa0 <botlish_fn_27: scan_label<generic>>:
    4fa0:	push   rbp
    4fa1:	mov    rbp,rsp
    4fa4:	sub    rsp,0x40
    4fa8:	mov    QWORD PTR [rsp+0x20],rbx
    4fad:	mov    QWORD PTR [rsp+0x28],r12
    4fb2:	mov    QWORD PTR [rsp+0x30],r13
    4fb7:	mov    QWORD PTR [rsp+0x38],r14
    4fbc:	mov    r12,QWORD PTR [rdi]
    4fbf:	mov    rax,QWORD PTR [rdi+0x8]
    4fc3:	lea    rcx,[r12+0x8]
    4fc8:	cmp    rcx,rax
    4fcb:	ja     51a9 <botlish_fn_27+0x209>
    4fd1:	lea    rax,[r12+0x8]
    4fd6:	mov    QWORD PTR [rdi],rax
    4fd9:	mov    r13,rdi
    4fdc:	mov    QWORD PTR [r12],0x0
    4fe4:	mov    QWORD PTR [rsp+0x10],0x0
    4fed:	mov    QWORD PTR [rsp],rdx
    4ff1:	mov    rbx,rsi
    4ff4:	mov    rsi,rdx
    4ff7:	mov    rax,QWORD PTR [rbx+0x20]
    4ffb:	mov    rdx,QWORD PTR [rax]
    4ffe:	mov    ecx,0x1
    5003:	test   rsi,0x1
    500a:	jne    5028 <botlish_fn_27+0x88>
    5010:	xor    ecx,ecx
    5012:	test   rsi,0x7
    5019:	jne    5028 <botlish_fn_27+0x88>
    501f:	movzx  rax,BYTE PTR [rsi]
    5023:	cmp    al,0x1
    5025:	sete   cl
    5028:	test   cl,cl
    502a:	jne    504e <botlish_fn_27+0xae>
    5030:	mov    rdi,r13
    5033:	mov    rax,QWORD PTR [rdi+0x10]
    5037:	mov    rcx,QWORD PTR [rax+0xb8]
    503e:	xor    rdx,rdx
    5041:	call   5046 <botlish_fn_27+0xa6>
			5042: R_X86_64_PLT32	rt_type_error-0x4
    5046:	mov    rdi,r13
    5049:	jmp    50e5 <botlish_fn_27+0x145>
    504e:	mov    rax,rsi
    5051:	and    rax,rdx
    5054:	mov    r14,rsi
    5057:	test   rax,0x1
    505d:	jne    5083 <botlish_fn_27+0xe3>
    5063:	mov    rsi,r14
    5066:	mov    rdi,r13
    5069:	call   506e <botlish_fn_27+0xce>
			506a: R_X86_64_PLT32	rt_int_cmp-0x4
    506e:	mov    ecx,0x2
    5073:	test   rax,rax
    5076:	cmovge rcx,QWORD PTR [rip+0x15a]        # 51d8 <botlish_fn_27+0x238>
    507e:	jmp    5096 <botlish_fn_27+0xf6>
    5083:	mov    ecx,0x2
    5088:	mov    rsi,r14
    508b:	cmp    rsi,rdx
    508e:	cmovge rcx,QWORD PTR [rip+0x142]        # 51d8 <botlish_fn_27+0x238>
    5096:	cmp    rcx,0x6
    509a:	je     5180 <botlish_fn_27+0x1e0>
    50a0:	mov    rsi,QWORD PTR [rbx+0x20]
    50a4:	mov    rsi,QWORD PTR [rsi+0x8]
    50a8:	mov    QWORD PTR [rsp+0x8],rsi
    50ad:	mov    rdx,r14
    50b0:	mov    rdi,r13
    50b3:	call   50b8 <botlish_fn_27+0x118>
			50b4: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    50b8:	test   rax,rax
    50bb:	jne    50c9 <botlish_fn_27+0x129>
    50c1:	mov    rdi,r13
    50c4:	jmp    50e5 <botlish_fn_27+0x145>
    50c9:	mov    QWORD PTR [rsp+0x8],rax
    50ce:	mov    rsi,rax
    50d1:	mov    rdi,r13
    50d4:	call   50d9 <botlish_fn_27+0x139>
			50d5: R_X86_64_PLT32	botlish_fn_25-0x4 ; is_label_char<str>
    50d9:	test   rax,rax
    50dc:	jne    510b <botlish_fn_27+0x16b>
    50e2:	mov    rdi,r13
    50e5:	mov    rdi,r13
    50e8:	mov    QWORD PTR [rdi],r12
    50eb:	xor    rax,rax
    50ee:	mov    rbx,QWORD PTR [rsp+0x20]
    50f3:	mov    r12,QWORD PTR [rsp+0x28]
    50f8:	mov    r13,QWORD PTR [rsp+0x30]
    50fd:	mov    r14,QWORD PTR [rsp+0x38]
    5102:	add    rsp,0x40
    5106:	mov    rsp,rbp
    5109:	pop    rbp
    510a:	ret
    510b:	cmp    rax,0x6
    510f:	je     5120 <botlish_fn_27+0x180>
    5115:	mov    rax,r14
    5118:	mov    rdi,r13
    511b:	jmp    5186 <botlish_fn_27+0x1e6>
    5120:	mov    QWORD PTR [rsp+0x8],rbx
    5125:	mov    QWORD PTR [rsp+0x10],0x3
    512e:	mov    rsi,r14
    5131:	test   rsi,0x1
    5138:	je     515e <botlish_fn_27+0x1be>
    513e:	mov    rsi,r14
    5141:	mov    rcx,rsi
    5144:	add    rcx,0x2
    5148:	seto   al
    514b:	test   al,al
    514d:	jne    515e <botlish_fn_27+0x1be>
    5153:	mov    rsi,rcx
    5156:	mov    r14,rcx
    5159:	jmp    5174 <botlish_fn_27+0x1d4>
    515e:	mov    edx,0x3
    5163:	mov    rsi,r14
    5166:	mov    rdi,r13
    5169:	call   516e <botlish_fn_27+0x1ce>
			516a: R_X86_64_PLT32	rt_int_add-0x4
    516e:	mov    rsi,rax
    5171:	mov    r14,rax
    5174:	mov    QWORD PTR [rsp],rsi
    5178:	mov    rsi,r14
    517b:	jmp    4ff7 <botlish_fn_27+0x57>
    5180:	mov    rax,r14
    5183:	mov    rdi,r13
    5186:	mov    rdi,r13
    5189:	mov    QWORD PTR [rdi],r12
    518c:	mov    rbx,QWORD PTR [rsp+0x20]
    5191:	mov    r12,QWORD PTR [rsp+0x28]
    5196:	mov    r13,QWORD PTR [rsp+0x30]
    519b:	mov    r14,QWORD PTR [rsp+0x38]
    51a0:	add    rsp,0x40
    51a4:	mov    rsp,rbp
    51a7:	pop    rbp
    51a8:	ret
    51a9:	mov    r13,rdi
    51ac:	call   51b1 <botlish_fn_27+0x211>
			51ad: R_X86_64_PLT32	rt_stack_overflow-0x4
    51b1:	xor    rax,rax
    51b4:	mov    rbx,QWORD PTR [rsp+0x20]
    51b9:	mov    r12,QWORD PTR [rsp+0x28]
    51be:	mov    r13,QWORD PTR [rsp+0x30]
    51c3:	mov    r14,QWORD PTR [rsp+0x38]
    51c8:	add    rsp,0x40
    51cc:	mov    rsp,rbp
    51cf:	pop    rbp
    51d0:	ret
    51d1:	add    BYTE PTR [rax],al
    51d3:	add    BYTE PTR [rax],al
    51d5:	add    BYTE PTR [rax],al
    51d7:	add    BYTE PTR [rsi],al
    51d9:	add    BYTE PTR [rax],al
    51db:	add    BYTE PTR [rax],al
    51dd:	add    BYTE PTR [rax],al
	...

00000000000051e0 <botlish_entry_27: scan_label<generic>>:
    51e0:	push   rbp
    51e1:	mov    rbp,rsp
    51e4:	mov    rdx,QWORD PTR [rdx]
    51e7:	call   51ec <botlish_entry_27+0xc>
			51e8: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_label<generic>
    51ec:	mov    rsp,rbp
    51ef:	pop    rbp
    51f0:	ret
    51f1:	add    BYTE PTR [rax],al
    51f3:	add    BYTE PTR [rax],al
    51f5:	add    BYTE PTR [rax],al
	...

00000000000051f8 <botlish_fn_28: scan_alpha<generic>>:
    51f8:	push   rbp
    51f9:	mov    rbp,rsp
    51fc:	sub    rsp,0x40
    5200:	mov    QWORD PTR [rsp+0x20],rbx
    5205:	mov    QWORD PTR [rsp+0x28],r12
    520a:	mov    QWORD PTR [rsp+0x30],r13
    520f:	mov    QWORD PTR [rsp+0x38],r14
    5214:	mov    r12,QWORD PTR [rdi]
    5217:	mov    rax,QWORD PTR [rdi+0x8]
    521b:	lea    rcx,[r12+0x8]
    5220:	cmp    rcx,rax
    5223:	ja     53fc <botlish_fn_28+0x204>
    5229:	lea    rax,[r12+0x8]
    522e:	mov    QWORD PTR [rdi],rax
    5231:	mov    r13,rdi
    5234:	mov    QWORD PTR [r12],0x0
    523c:	mov    QWORD PTR [rsp+0x10],0x0
    5245:	mov    QWORD PTR [rsp],rdx
    5249:	mov    rbx,rsi
    524c:	mov    rsi,rdx
    524f:	mov    rax,QWORD PTR [rbx+0x20]
    5253:	mov    rdx,QWORD PTR [rax]
    5256:	mov    ecx,0x1
    525b:	test   rsi,0x1
    5262:	jne    5280 <botlish_fn_28+0x88>
    5268:	xor    ecx,ecx
    526a:	test   rsi,0x7
    5271:	jne    5280 <botlish_fn_28+0x88>
    5277:	movzx  rax,BYTE PTR [rsi]
    527b:	cmp    al,0x1
    527d:	sete   cl
    5280:	test   cl,cl
    5282:	jne    52a6 <botlish_fn_28+0xae>
    5288:	mov    rdi,r13
    528b:	mov    rax,QWORD PTR [rdi+0x10]
    528f:	mov    rcx,QWORD PTR [rax+0xb8]
    5296:	xor    rdx,rdx
    5299:	call   529e <botlish_fn_28+0xa6>
			529a: R_X86_64_PLT32	rt_type_error-0x4
    529e:	mov    rdi,r13
    52a1:	jmp    5338 <botlish_fn_28+0x140>
    52a6:	mov    rax,rsi
    52a9:	and    rax,rdx
    52ac:	mov    r14,rsi
    52af:	test   rax,0x1
    52b5:	jne    52db <botlish_fn_28+0xe3>
    52bb:	mov    rsi,r14
    52be:	mov    rdi,r13
    52c1:	call   52c6 <botlish_fn_28+0xce>
			52c2: R_X86_64_PLT32	rt_int_cmp-0x4
    52c6:	mov    ecx,0x2
    52cb:	test   rax,rax
    52ce:	cmovge rcx,QWORD PTR [rip+0x152]        # 5428 <botlish_fn_28+0x230>
    52d6:	jmp    52ee <botlish_fn_28+0xf6>
    52db:	mov    ecx,0x2
    52e0:	mov    rsi,r14
    52e3:	cmp    rsi,rdx
    52e6:	cmovge rcx,QWORD PTR [rip+0x13a]        # 5428 <botlish_fn_28+0x230>
    52ee:	cmp    rcx,0x6
    52f2:	je     53d3 <botlish_fn_28+0x1db>
    52f8:	mov    rsi,QWORD PTR [rbx+0x20]
    52fc:	mov    rsi,QWORD PTR [rsi+0x8]
    5300:	mov    QWORD PTR [rsp+0x8],rsi
    5305:	mov    rdx,r14
    5308:	mov    rdi,r13
    530b:	call   5310 <botlish_fn_28+0x118>
			530c: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    5310:	test   rax,rax
    5313:	mov    rsi,rax
    5316:	jne    5324 <botlish_fn_28+0x12c>
    531c:	mov    rdi,r13
    531f:	jmp    5338 <botlish_fn_28+0x140>
    5324:	mov    rdi,r13
    5327:	call   532c <botlish_fn_28+0x134>
			5328: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    532c:	test   rax,rax
    532f:	jne    535e <botlish_fn_28+0x166>
    5335:	mov    rdi,r13
    5338:	mov    rdi,r13
    533b:	mov    QWORD PTR [rdi],r12
    533e:	xor    rax,rax
    5341:	mov    rbx,QWORD PTR [rsp+0x20]
    5346:	mov    r12,QWORD PTR [rsp+0x28]
    534b:	mov    r13,QWORD PTR [rsp+0x30]
    5350:	mov    r14,QWORD PTR [rsp+0x38]
    5355:	add    rsp,0x40
    5359:	mov    rsp,rbp
    535c:	pop    rbp
    535d:	ret
    535e:	cmp    rax,0x6
    5362:	je     5373 <botlish_fn_28+0x17b>
    5368:	mov    rax,r14
    536b:	mov    rdi,r13
    536e:	jmp    53d9 <botlish_fn_28+0x1e1>
    5373:	mov    QWORD PTR [rsp+0x8],rbx
    5378:	mov    QWORD PTR [rsp+0x10],0x3
    5381:	mov    rsi,r14
    5384:	test   rsi,0x1
    538b:	je     53b1 <botlish_fn_28+0x1b9>
    5391:	mov    rsi,r14
    5394:	mov    rcx,rsi
    5397:	add    rcx,0x2
    539b:	seto   al
    539e:	test   al,al
    53a0:	jne    53b1 <botlish_fn_28+0x1b9>
    53a6:	mov    rsi,rcx
    53a9:	mov    r14,rcx
    53ac:	jmp    53c7 <botlish_fn_28+0x1cf>
    53b1:	mov    edx,0x3
    53b6:	mov    rsi,r14
    53b9:	mov    rdi,r13
    53bc:	call   53c1 <botlish_fn_28+0x1c9>
			53bd: R_X86_64_PLT32	rt_int_add-0x4
    53c1:	mov    rsi,rax
    53c4:	mov    r14,rax
    53c7:	mov    QWORD PTR [rsp],rsi
    53cb:	mov    rsi,r14
    53ce:	jmp    524f <botlish_fn_28+0x57>
    53d3:	mov    rax,r14
    53d6:	mov    rdi,r13
    53d9:	mov    rdi,r13
    53dc:	mov    QWORD PTR [rdi],r12
    53df:	mov    rbx,QWORD PTR [rsp+0x20]
    53e4:	mov    r12,QWORD PTR [rsp+0x28]
    53e9:	mov    r13,QWORD PTR [rsp+0x30]
    53ee:	mov    r14,QWORD PTR [rsp+0x38]
    53f3:	add    rsp,0x40
    53f7:	mov    rsp,rbp
    53fa:	pop    rbp
    53fb:	ret
    53fc:	mov    r13,rdi
    53ff:	call   5404 <botlish_fn_28+0x20c>
			5400: R_X86_64_PLT32	rt_stack_overflow-0x4
    5404:	xor    rax,rax
    5407:	mov    rbx,QWORD PTR [rsp+0x20]
    540c:	mov    r12,QWORD PTR [rsp+0x28]
    5411:	mov    r13,QWORD PTR [rsp+0x30]
    5416:	mov    r14,QWORD PTR [rsp+0x38]
    541b:	add    rsp,0x40
    541f:	mov    rsp,rbp
    5422:	pop    rbp
    5423:	ret
    5424:	add    BYTE PTR [rax],al
    5426:	add    BYTE PTR [rax],al
    5428:	(bad)
    5429:	add    BYTE PTR [rax],al
    542b:	add    BYTE PTR [rax],al
    542d:	add    BYTE PTR [rax],al
	...

0000000000005430 <botlish_entry_28: scan_alpha<generic>>:
    5430:	push   rbp
    5431:	mov    rbp,rsp
    5434:	mov    rdx,QWORD PTR [rdx]
    5437:	call   543c <botlish_entry_28+0xc>
			5438: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_alpha<generic>
    543c:	mov    rsp,rbp
    543f:	pop    rbp
    5440:	ret
    5441:	add    BYTE PTR [rax],al
    5443:	add    BYTE PTR [rax],al
    5445:	add    BYTE PTR [rax],al
	...

0000000000005448 <botlish_fn_29: tld_ok<generic>>:
    5448:	push   rbp
    5449:	mov    rbp,rsp
    544c:	sub    rsp,0x40
    5450:	mov    QWORD PTR [rsp+0x10],rbx
    5455:	mov    QWORD PTR [rsp+0x18],r12
    545a:	mov    QWORD PTR [rsp+0x20],r13
    545f:	mov    QWORD PTR [rsp+0x28],r14
    5464:	mov    QWORD PTR [rsp+0x30],r15
    5469:	mov    rbx,QWORD PTR [rdi]
    546c:	mov    rax,QWORD PTR [rdi+0x8]
    5470:	lea    rcx,[rbx+0x8]
    5474:	cmp    rcx,rax
    5477:	ja     5688 <botlish_fn_29+0x240>
    547d:	lea    rax,[rbx+0x8]
    5481:	mov    QWORD PTR [rdi],rax
    5484:	mov    r13,rdi
    5487:	mov    QWORD PTR [rbx],0x0
    548e:	mov    QWORD PTR [rsp],rdx
    5492:	mov    r8,rdx
    5495:	mov    rax,QWORD PTR [rsi+0x20]
    5499:	mov    r15,rsi
    549c:	mov    rsi,QWORD PTR [rax]
    549f:	mov    QWORD PTR [rsp+0x8],rsi
    54a4:	mov    r12,r8
    54a7:	mov    rdx,r12
    54aa:	mov    rdi,r13
    54ad:	call   54b2 <botlish_fn_29+0x6a>
			54ae: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_alpha<generic>
    54b2:	mov    rcx,rax
    54b5:	mov    r14,rax
    54b8:	test   rax,rcx
    54bb:	jne    54c9 <botlish_fn_29+0x81>
    54c1:	mov    rdi,r13
    54c4:	jmp    55a2 <botlish_fn_29+0x15a>
    54c9:	mov    rax,r14
    54cc:	mov    QWORD PTR [rsp+0x8],rax
    54d1:	mov    rsi,r15
    54d4:	mov    rax,QWORD PTR [rsi+0x20]
    54d8:	mov    rdx,QWORD PTR [rax+0x8]
    54dc:	mov    rax,r14
    54df:	and    rax,rdx
    54e2:	test   rax,0x1
    54e8:	jne    5511 <botlish_fn_29+0xc9>
    54ee:	mov    rsi,r14
    54f1:	mov    rdi,r13
    54f4:	call   54f9 <botlish_fn_29+0xb1>
			54f5: R_X86_64_PLT32	rt_int_cmp-0x4
    54f9:	mov    ecx,0x2
    54fe:	test   rax,rax
    5501:	cmove  rcx,QWORD PTR [rip+0x1af]        # 56b8 <botlish_fn_29+0x270>
    5509:	mov    rax,r14
    550c:	jmp    5524 <botlish_fn_29+0xdc>
    5511:	mov    ecx,0x2
    5516:	mov    rax,r14
    5519:	cmp    rax,rdx
    551c:	cmove  rcx,QWORD PTR [rip+0x194]        # 56b8 <botlish_fn_29+0x270>
    5524:	cmp    rcx,0x6
    5528:	je     553e <botlish_fn_29+0xf6>
    552e:	mov    ecx,0x2
    5533:	mov    rax,rcx
    5536:	mov    rdi,r13
    5539:	jmp    5660 <botlish_fn_29+0x218>
    553e:	mov    ecx,0x1
    5543:	test   r12,0x1
    554a:	je     5558 <botlish_fn_29+0x110>
    5550:	mov    r8,r12
    5553:	jmp    557e <botlish_fn_29+0x136>
    5558:	xor    ecx,ecx
    555a:	test   r12,0x7
    5561:	je     556f <botlish_fn_29+0x127>
    5567:	mov    r8,r12
    556a:	jmp    557e <botlish_fn_29+0x136>
    556f:	movzx  rcx,BYTE PTR [r12]
    5574:	mov    r8,r12
    5577:	rex cmp cl,0x1
    557b:	sete   cl
    557e:	test   cl,cl
    5580:	jne    55cd <botlish_fn_29+0x185>
    5586:	mov    rdi,r13
    5589:	mov    rax,QWORD PTR [rdi+0x10]
    558d:	mov    rcx,QWORD PTR [rax+0x128]
    5594:	xor    rdx,rdx
    5597:	mov    rsi,r8
    559a:	call   559f <botlish_fn_29+0x157>
			559b: R_X86_64_PLT32	rt_type_error-0x4
    559f:	mov    rdi,r13
    55a2:	mov    rdi,r13
    55a5:	mov    QWORD PTR [rdi],rbx
    55a8:	xor    rax,rax
    55ab:	mov    rbx,QWORD PTR [rsp+0x10]
    55b0:	mov    r12,QWORD PTR [rsp+0x18]
    55b5:	mov    r13,QWORD PTR [rsp+0x20]
    55ba:	mov    r14,QWORD PTR [rsp+0x28]
    55bf:	mov    r15,QWORD PTR [rsp+0x30]
    55c4:	add    rsp,0x40
    55c8:	mov    rsp,rbp
    55cb:	pop    rbp
    55cc:	ret
    55cd:	mov    r12,r8
    55d0:	mov    rcx,rax
    55d3:	and    rcx,r12
    55d6:	test   rcx,0x1
    55dd:	jne    55ee <botlish_fn_29+0x1a6>
    55e3:	mov    rdx,r8
    55e6:	mov    rsi,rax
    55e9:	jmp    560f <botlish_fn_29+0x1c7>
    55ee:	mov    r12,r8
    55f1:	mov    rcx,rax
    55f4:	sub    rcx,r12
    55f7:	mov    r14,rax
    55fa:	seto   al
    55fd:	lea    rsi,[rcx+0x1]
    5601:	test   al,al
    5603:	je     561a <botlish_fn_29+0x1d2>
    5609:	mov    rdx,r8
    560c:	mov    rsi,r14
    560f:	mov    rdi,r13
    5612:	call   5617 <botlish_fn_29+0x1cf>
			5613: R_X86_64_PLT32	rt_int_sub-0x4
    5617:	mov    rsi,rax
    561a:	test   rsi,0x1
    5621:	jne    564c <botlish_fn_29+0x204>
    5627:	mov    edx,0x5
    562c:	mov    rdi,r13
    562f:	call   5634 <botlish_fn_29+0x1ec>
			5630: R_X86_64_PLT32	rt_int_cmp-0x4
    5634:	mov    ecx,0x2
    5639:	test   rax,rax
    563c:	mov    rax,rcx
    563f:	cmovge rax,QWORD PTR [rip+0x71]        # 56b8 <botlish_fn_29+0x270>
    5647:	jmp    565d <botlish_fn_29+0x215>
    564c:	mov    eax,0x2
    5651:	cmp    rsi,0x5
    5655:	cmovge rax,QWORD PTR [rip+0x5b]        # 56b8 <botlish_fn_29+0x270>
    565d:	mov    rdi,r13
    5660:	mov    rdi,r13
    5663:	mov    QWORD PTR [rdi],rbx
    5666:	mov    rbx,QWORD PTR [rsp+0x10]
    566b:	mov    r12,QWORD PTR [rsp+0x18]
    5670:	mov    r13,QWORD PTR [rsp+0x20]
    5675:	mov    r14,QWORD PTR [rsp+0x28]
    567a:	mov    r15,QWORD PTR [rsp+0x30]
    567f:	add    rsp,0x40
    5683:	mov    rsp,rbp
    5686:	pop    rbp
    5687:	ret
    5688:	mov    r13,rdi
    568b:	call   5690 <botlish_fn_29+0x248>
			568c: R_X86_64_PLT32	rt_stack_overflow-0x4
    5690:	xor    rax,rax
    5693:	mov    rbx,QWORD PTR [rsp+0x10]
    5698:	mov    r12,QWORD PTR [rsp+0x18]
    569d:	mov    r13,QWORD PTR [rsp+0x20]
    56a2:	mov    r14,QWORD PTR [rsp+0x28]
    56a7:	mov    r15,QWORD PTR [rsp+0x30]
    56ac:	add    rsp,0x40
    56b0:	mov    rsp,rbp
    56b3:	pop    rbp
    56b4:	ret
    56b5:	add    BYTE PTR [rax],al
    56b7:	add    BYTE PTR [rsi],al
    56b9:	add    BYTE PTR [rax],al
    56bb:	add    BYTE PTR [rax],al
    56bd:	add    BYTE PTR [rax],al
	...

00000000000056c0 <botlish_entry_29: tld_ok<generic>>:
    56c0:	push   rbp
    56c1:	mov    rbp,rsp
    56c4:	mov    rdx,QWORD PTR [rdx]
    56c7:	call   56cc <botlish_entry_29+0xc>
			56c8: R_X86_64_PLT32	botlish_fn_29-0x4 ; tld_ok<generic>
    56cc:	mov    rsp,rbp
    56cf:	pop    rbp
    56d0:	ret
    56d1:	add    BYTE PTR [rax],al
    56d3:	add    BYTE PTR [rax],al
    56d5:	add    BYTE PTR [rax],al
	...

00000000000056d8 <botlish_fn_30: domain_loop<generic>>:
    56d8:	push   rbp
    56d9:	mov    rbp,rsp
    56dc:	sub    rsp,0x60
    56e0:	mov    QWORD PTR [rsp+0x30],rbx
    56e5:	mov    QWORD PTR [rsp+0x38],r12
    56ea:	mov    QWORD PTR [rsp+0x40],r13
    56ef:	mov    QWORD PTR [rsp+0x48],r14
    56f4:	mov    QWORD PTR [rsp+0x50],r15
    56f9:	mov    r13,QWORD PTR [rdi]
    56fc:	mov    rax,QWORD PTR [rdi+0x8]
    5700:	lea    rcx,[r13+0x8]
    5704:	cmp    rcx,rax
    5707:	ja     5984 <botlish_fn_30+0x2ac>
    570d:	lea    rax,[r13+0x8]
    5711:	mov    QWORD PTR [rdi],rax
    5714:	mov    r15,rdi
    5717:	mov    QWORD PTR [r13+0x0],0x0
    571f:	mov    QWORD PTR [rsp],rdx
    5723:	mov    QWORD PTR [rsp+0x20],rdx
    5728:	lea    rbx,[rsp+0x10]
    572d:	mov    r12,rsi
    5730:	mov    rax,QWORD PTR [r12+0x20]
    5735:	mov    rsi,QWORD PTR [rax]
    5738:	mov    QWORD PTR [rsp+0x8],rsi
    573d:	mov    rdx,QWORD PTR [rsp+0x20]
    5742:	mov    rdi,r15
    5745:	call   574a <botlish_fn_30+0x72>
			5746: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_label<generic>
    574a:	mov    rcx,rax
    574d:	mov    r14,rax
    5750:	test   rax,rcx
    5753:	jne    5761 <botlish_fn_30+0x89>
    5759:	mov    rdi,r15
    575c:	jmp    58f2 <botlish_fn_30+0x21a>
    5761:	mov    rax,r14
    5764:	mov    QWORD PTR [rsp],rax
    5768:	mov    rdx,QWORD PTR [rsp+0x20]
    576d:	mov    rsi,rax
    5770:	and    rsi,rdx
    5773:	test   rsi,0x1
    577a:	jne    57a1 <botlish_fn_30+0xc9>
    5780:	mov    rdx,QWORD PTR [rsp+0x20]
    5785:	mov    rsi,r14
    5788:	mov    rdi,r15
    578b:	call   5790 <botlish_fn_30+0xb8>
			578c: R_X86_64_PLT32	rt_value_eq-0x4
    5790:	test   rax,rax
    5793:	jne    57b6 <botlish_fn_30+0xde>
    5799:	mov    rdi,r15
    579c:	jmp    58f2 <botlish_fn_30+0x21a>
    57a1:	mov    eax,0x2
    57a6:	mov    rdx,QWORD PTR [rsp+0x20]
    57ab:	cmp    r14,rdx
    57ae:	cmove  rax,QWORD PTR [rip+0x202]        # 59b8 <botlish_fn_30+0x2e0>
    57b6:	cmp    rax,0x6
    57ba:	je     5952 <botlish_fn_30+0x27a>
    57c0:	mov    rax,QWORD PTR [r12+0x20]
    57c5:	mov    rdx,QWORD PTR [rax+0x8]
    57c9:	mov    rax,r14
    57cc:	and    rax,rdx
    57cf:	test   rax,0x1
    57d5:	jne    57fb <botlish_fn_30+0x123>
    57db:	mov    rsi,r14
    57de:	mov    rdi,r15
    57e1:	call   57e6 <botlish_fn_30+0x10e>
			57e2: R_X86_64_PLT32	rt_int_cmp-0x4
    57e6:	mov    ecx,0x2
    57eb:	test   rax,rax
    57ee:	cmovge rcx,QWORD PTR [rip+0x1c2]        # 59b8 <botlish_fn_30+0x2e0>
    57f6:	jmp    580b <botlish_fn_30+0x133>
    57fb:	mov    ecx,0x2
    5800:	cmp    r14,rdx
    5803:	cmovge rcx,QWORD PTR [rip+0x1ad]        # 59b8 <botlish_fn_30+0x2e0>
    580b:	cmp    rcx,0x6
    580f:	je     5943 <botlish_fn_30+0x26b>
    5815:	mov    rax,QWORD PTR [r12+0x20]
    581a:	mov    rsi,QWORD PTR [rax+0x10]
    581e:	mov    QWORD PTR [rsp+0x8],rsi
    5823:	mov    rcx,rbx
    5826:	mov    rdx,r14
    5829:	mov    rdi,r15
    582c:	call   5831 <botlish_fn_30+0x159>
			582d: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    5831:	test   rax,rax
    5834:	mov    rsi,rax
    5837:	jne    5845 <botlish_fn_30+0x16d>
    583d:	mov    rdi,r15
    5840:	jmp    58f2 <botlish_fn_30+0x21a>
    5845:	mov    rdx,QWORD PTR [rsp+0x10]
    584a:	mov    rcx,QWORD PTR [rsp+0x18]
    584f:	mov    rdi,r15
    5852:	mov    rax,QWORD PTR [rdi+0x10]
    5856:	mov    r8,QWORD PTR [rax+0x118]
    585d:	call   5862 <botlish_fn_30+0x18a>
			585e: R_X86_64_PLT32	rt_str_region_eq-0x4
    5862:	cmp    rax,0x6
    5866:	je     5878 <botlish_fn_30+0x1a0>
    586c:	mov    rax,0xffffffffffffffff
    5873:	jmp    594a <botlish_fn_30+0x272>
    5878:	mov    QWORD PTR [rsp+0x8],0x3
    5881:	test   r14,0x1
    5888:	je     58af <botlish_fn_30+0x1d7>
    588e:	mov    rdx,r14
    5891:	add    rdx,0x2
    5895:	mov    QWORD PTR [rsp+0x20],rdx
    589a:	seto   al
    589d:	test   al,al
    589f:	jne    58af <botlish_fn_30+0x1d7>
    58a5:	mov    rdx,QWORD PTR [rsp+0x20]
    58aa:	jmp    58c7 <botlish_fn_30+0x1ef>
    58af:	mov    edx,0x3
    58b4:	mov    rsi,r14
    58b7:	mov    rdi,r15
    58ba:	call   58bf <botlish_fn_30+0x1e7>
			58bb: R_X86_64_PLT32	rt_int_add-0x4
    58bf:	mov    rdx,rax
    58c2:	mov    QWORD PTR [rsp+0x20],rax
    58c7:	mov    QWORD PTR [rsp],rdx
    58cb:	mov    rax,QWORD PTR [r12+0x20]
    58d0:	mov    rsi,QWORD PTR [rax+0x18]
    58d4:	mov    QWORD PTR [rsp+0x8],rsi
    58d9:	mov    rdx,QWORD PTR [rsp+0x20]
    58de:	mov    rdi,r15
    58e1:	call   58e6 <botlish_fn_30+0x20e>
			58e2: R_X86_64_PLT32	botlish_fn_29-0x4 ; tld_ok<generic>
    58e6:	test   rax,rax
    58e9:	jne    591d <botlish_fn_30+0x245>
    58ef:	mov    rdi,r15
    58f2:	mov    rdi,r15
    58f5:	mov    QWORD PTR [rdi],r13
    58f8:	xor    rax,rax
    58fb:	mov    rbx,QWORD PTR [rsp+0x30]
    5900:	mov    r12,QWORD PTR [rsp+0x38]
    5905:	mov    r13,QWORD PTR [rsp+0x40]
    590a:	mov    r14,QWORD PTR [rsp+0x48]
    590f:	mov    r15,QWORD PTR [rsp+0x50]
    5914:	add    rsp,0x60
    5918:	mov    rsp,rbp
    591b:	pop    rbp
    591c:	ret
    591d:	cmp    rax,0x6
    5921:	je     5935 <botlish_fn_30+0x25d>
    5927:	mov    rdx,QWORD PTR [rsp+0x20]
    592c:	mov    QWORD PTR [rsp],rdx
    5930:	jmp    5730 <botlish_fn_30+0x58>
    5935:	mov    rax,QWORD PTR [r12+0x20]
    593a:	mov    rax,QWORD PTR [rax+0x8]
    593e:	jmp    594a <botlish_fn_30+0x272>
    5943:	mov    rax,0xffffffffffffffff
    594a:	mov    rdi,r15
    594d:	jmp    595c <botlish_fn_30+0x284>
    5952:	mov    rax,0xffffffffffffffff
    5959:	mov    rdi,r15
    595c:	mov    rdi,r15
    595f:	mov    QWORD PTR [rdi],r13
    5962:	mov    rbx,QWORD PTR [rsp+0x30]
    5967:	mov    r12,QWORD PTR [rsp+0x38]
    596c:	mov    r13,QWORD PTR [rsp+0x40]
    5971:	mov    r14,QWORD PTR [rsp+0x48]
    5976:	mov    r15,QWORD PTR [rsp+0x50]
    597b:	add    rsp,0x60
    597f:	mov    rsp,rbp
    5982:	pop    rbp
    5983:	ret
    5984:	mov    r15,rdi
    5987:	call   598c <botlish_fn_30+0x2b4>
			5988: R_X86_64_PLT32	rt_stack_overflow-0x4
    598c:	xor    rax,rax
    598f:	mov    rbx,QWORD PTR [rsp+0x30]
    5994:	mov    r12,QWORD PTR [rsp+0x38]
    5999:	mov    r13,QWORD PTR [rsp+0x40]
    599e:	mov    r14,QWORD PTR [rsp+0x48]
    59a3:	mov    r15,QWORD PTR [rsp+0x50]
    59a8:	add    rsp,0x60
    59ac:	mov    rsp,rbp
    59af:	pop    rbp
    59b0:	ret
    59b1:	add    BYTE PTR [rax],al
    59b3:	add    BYTE PTR [rax],al
    59b5:	add    BYTE PTR [rax],al
    59b7:	add    BYTE PTR [rsi],al
    59b9:	add    BYTE PTR [rax],al
    59bb:	add    BYTE PTR [rax],al
    59bd:	add    BYTE PTR [rax],al
	...

00000000000059c0 <botlish_entry_30: domain_loop<generic>>:
    59c0:	push   rbp
    59c1:	mov    rbp,rsp
    59c4:	mov    rdx,QWORD PTR [rdx]
    59c7:	call   59cc <botlish_entry_30+0xc>
			59c8: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    59cc:	mov    rsp,rbp
    59cf:	pop    rbp
    59d0:	ret

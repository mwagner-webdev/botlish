; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 24269  (per function: 472 1131 1713 1425 687 1084 697 1140 624 1449 1417 427 456 401 165 617 617 625 681 793 1449 1417 427 456 401 165 617 617 625 681 793)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> web::uri_escape_text<str>
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
       4:	sub    rsp,0x60
       8:	mov    QWORD PTR [rsp+0x40],rbx
       d:	mov    QWORD PTR [rsp+0x48],r12
      12:	mov    QWORD PTR [rsp+0x50],r13
      17:	mov    QWORD PTR [rsp+0x58],r14
      1c:	mov    rbx,QWORD PTR [rdi]
      1f:	mov    rax,QWORD PTR [rdi+0x8]
      23:	lea    rcx,[rbx+0x8]
      27:	cmp    rcx,rax
      2a:	ja     194 <botlish_fn_0+0x194>
      30:	lea    rax,[rbx+0x8]
      34:	mov    QWORD PTR [rdi],rax
      37:	mov    QWORD PTR [rbx],0x0
      3e:	mov    QWORD PTR [rsp+0x8],0x0
      47:	mov    QWORD PTR [rsp+0x10],0x0
      50:	mov    QWORD PTR [rsp+0x18],0x0
      59:	mov    QWORD PTR [rsp+0x20],0x0
      62:	mov    rax,QWORD PTR [rdi+0x10]
      66:	mov    r13,rdi
      69:	mov    rsi,QWORD PTR [rax]
      6c:	mov    QWORD PTR [rsp],rsi
      70:	call   75 <botlish_fn_0+0x75>
			71: R_X86_64_PLT32	botlish_fn_1-0x4 ; web::uri_escape_text<str>
      75:	test   rax,rax
      78:	jne    86 <botlish_fn_0+0x86>
      7e:	mov    rdi,r13
      81:	jmp    14b <botlish_fn_0+0x14b>
      86:	mov    QWORD PTR [rsp],rax
      8a:	mov    r14,rax
      8d:	mov    esi,0x321
      92:	mov    QWORD PTR [rsp+0x8],0x321
      9b:	mov    edx,0x1
      a0:	mov    QWORD PTR [rsp+0x10],0x1
      a9:	mov    rdi,r13
      ac:	mov    rcx,QWORD PTR [rdi+0x10]
      b0:	mov    rcx,QWORD PTR [rcx+0x8]
      b4:	mov    QWORD PTR [rsp+0x18],rcx
      b9:	mov    r8,r14
      bc:	call   c1 <botlish_fn_0+0xc1>
			bd: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
      c1:	mov    r12,rax
      c4:	test   r12,r12
      c7:	jne    d5 <botlish_fn_0+0xd5>
      cd:	mov    rdi,r13
      d0:	jmp    14b <botlish_fn_0+0x14b>
      d5:	mov    QWORD PTR [rsp+0x8],r12
      da:	mov    esi,0x321
      df:	mov    QWORD PTR [rsp+0x10],0x321
      e8:	mov    edx,0x1
      ed:	mov    QWORD PTR [rsp+0x18],0x1
      f6:	mov    rdi,r13
      f9:	mov    rax,QWORD PTR [rdi+0x10]
      fd:	mov    rcx,QWORD PTR [rax+0x10]
     101:	mov    QWORD PTR [rsp+0x20],rcx
     106:	mov    r8,r14
     109:	call   10e <botlish_fn_0+0x10e>
			10a: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
     10e:	test   rax,rax
     111:	jne    11f <botlish_fn_0+0x11f>
     117:	mov    rdi,r13
     11a:	jmp    14b <botlish_fn_0+0x14b>
     11f:	mov    QWORD PTR [rsp],rax
     123:	lea    rdx,[rsp+0x28]
     128:	mov    QWORD PTR [rsp+0x28],r12
     12d:	mov    QWORD PTR [rsp+0x30],rax
     132:	mov    esi,0x2
     137:	mov    rdi,r13
     13a:	call   13f <botlish_fn_0+0x13f>
			13b: R_X86_64_PLT32	rt_list_new-0x4
     13f:	test   rax,rax
     142:	jne    171 <botlish_fn_0+0x171>
     148:	mov    rdi,r13
     14b:	mov    rdi,r13
     14e:	mov    QWORD PTR [rdi],rbx
     151:	xor    rax,rax
     154:	mov    rbx,QWORD PTR [rsp+0x40]
     159:	mov    r12,QWORD PTR [rsp+0x48]
     15e:	mov    r13,QWORD PTR [rsp+0x50]
     163:	mov    r14,QWORD PTR [rsp+0x58]
     168:	add    rsp,0x60
     16c:	mov    rsp,rbp
     16f:	pop    rbp
     170:	ret
     171:	mov    rdi,r13
     174:	mov    QWORD PTR [rdi],rbx
     177:	mov    rbx,QWORD PTR [rsp+0x40]
     17c:	mov    r12,QWORD PTR [rsp+0x48]
     181:	mov    r13,QWORD PTR [rsp+0x50]
     186:	mov    r14,QWORD PTR [rsp+0x58]
     18b:	add    rsp,0x60
     18f:	mov    rsp,rbp
     192:	pop    rbp
     193:	ret
     194:	mov    r13,rdi
     197:	call   19c <botlish_fn_0+0x19c>
			198: R_X86_64_PLT32	rt_stack_overflow-0x4
     19c:	xor    rax,rax
     19f:	mov    rbx,QWORD PTR [rsp+0x40]
     1a4:	mov    r12,QWORD PTR [rsp+0x48]
     1a9:	mov    r13,QWORD PTR [rsp+0x50]
     1ae:	mov    r14,QWORD PTR [rsp+0x58]
     1b3:	add    rsp,0x60
     1b7:	mov    rsp,rbp
     1ba:	pop    rbp
     1bb:	ret

00000000000001bc <botlish_entry_0: <program entry>>:
     1bc:	push   rbp
     1bd:	mov    rbp,rsp
     1c0:	call   1c5 <botlish_entry_0+0x9>
			1c1: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     1c5:	mov    rsp,rbp
     1c8:	pop    rbp
     1c9:	ret

00000000000001ca <botlish_fn_1: web::uri_escape_text<str>>:
     1ca:	push   rbp
     1cb:	mov    rbp,rsp
     1ce:	sub    rsp,0x190
     1d5:	mov    QWORD PTR [rsp+0x160],rbx
     1dd:	mov    QWORD PTR [rsp+0x168],r12
     1e5:	mov    QWORD PTR [rsp+0x170],r13
     1ed:	mov    QWORD PTR [rsp+0x178],r14
     1f5:	mov    QWORD PTR [rsp+0x180],r15
     1fd:	mov    r9,QWORD PTR [rdi]
     200:	mov    r8,QWORD PTR [rdi+0x8]
     204:	lea    r10,[r9+0x8]
     208:	cmp    r10,r8
     20b:	ja     5b3 <botlish_fn_1+0x3e9>
     211:	lea    r8,[r9+0x8]
     215:	mov    QWORD PTR [rdi],r8
     218:	mov    QWORD PTR [r9],0x0
     21f:	mov    QWORD PTR [rsp+0x158],r9
     227:	mov    QWORD PTR [rsp],rsi
     22b:	mov    QWORD PTR [rsp+0x130],rsi
     233:	mov    r9,QWORD PTR [rdi+0x10]
     237:	mov    r10,QWORD PTR [r9+0x18]
     23b:	mov    QWORD PTR [rsp+0x8],r10
     240:	mov    QWORD PTR [rsp+0x150],r10
     248:	mov    r10,QWORD PTR [rdi+0x10]
     24c:	mov    r11,QWORD PTR [r10+0x20]
     250:	mov    QWORD PTR [rsp+0x10],r11
     255:	mov    QWORD PTR [rsp+0x148],r11
     25d:	mov    r11,QWORD PTR [rdi+0x10]
     261:	mov    rcx,QWORD PTR [r11+0x28]
     265:	mov    QWORD PTR [rsp+0x18],rcx
     26a:	mov    QWORD PTR [rsp+0x140],rcx
     272:	mov    rax,QWORD PTR [rdi+0x10]
     276:	mov    r11,QWORD PTR [rax+0x30]
     27a:	mov    QWORD PTR [rsp+0x20],r11
     27f:	mov    QWORD PTR [rsp+0x138],r11
     287:	mov    rax,QWORD PTR [rdi+0x10]
     28b:	mov    r11,QWORD PTR [rax+0x38]
     28f:	mov    QWORD PTR [rsp+0x28],r11
     294:	mov    rax,QWORD PTR [rdi+0x10]
     298:	mov    rsi,QWORD PTR [rax+0x40]
     29c:	mov    QWORD PTR [rsp+0x30],rsi
     2a1:	mov    rax,QWORD PTR [rdi+0x10]
     2a5:	mov    r8,QWORD PTR [rax+0x48]
     2a9:	mov    QWORD PTR [rsp+0x38],r8
     2ae:	mov    rax,QWORD PTR [rdi+0x10]
     2b2:	mov    rbx,QWORD PTR [rax+0x50]
     2b6:	mov    QWORD PTR [rsp+0x40],rbx
     2bb:	mov    rax,QWORD PTR [rdi+0x10]
     2bf:	mov    r12,QWORD PTR [rax+0x58]
     2c3:	mov    QWORD PTR [rsp+0x48],r12
     2c8:	mov    rax,QWORD PTR [rdi+0x10]
     2cc:	mov    r13,QWORD PTR [rax+0x60]
     2d0:	mov    QWORD PTR [rsp+0x50],r13
     2d5:	mov    rax,QWORD PTR [rdi+0x10]
     2d9:	mov    r14,QWORD PTR [rax+0x68]
     2dd:	mov    QWORD PTR [rsp+0x58],r14
     2e2:	mov    rax,QWORD PTR [rdi+0x10]
     2e6:	mov    r15,QWORD PTR [rax+0x70]
     2ea:	mov    QWORD PTR [rsp+0x60],r15
     2ef:	mov    rax,QWORD PTR [rdi+0x10]
     2f3:	mov    rax,QWORD PTR [rax+0x78]
     2f7:	mov    QWORD PTR [rsp+0x68],rax
     2fc:	mov    rdx,QWORD PTR [rdi+0x10]
     300:	mov    r9,QWORD PTR [rdx+0x80]
     307:	mov    QWORD PTR [rsp+0x70],r9
     30c:	mov    rdx,QWORD PTR [rdi+0x10]
     310:	mov    r10,QWORD PTR [rdx+0x88]
     317:	mov    QWORD PTR [rsp+0x78],r10
     31c:	mov    rdx,QWORD PTR [rdi+0x10]
     320:	mov    QWORD PTR [rsp+0x128],rdi
     328:	mov    rdi,QWORD PTR [rdx+0x90]
     32f:	mov    QWORD PTR [rsp+0x80],rdi
     337:	lea    rdx,[rsp+0x88]
     33f:	mov    rcx,QWORD PTR [rsp+0x150]
     347:	mov    QWORD PTR [rsp+0x88],rcx
     34f:	mov    rcx,QWORD PTR [rsp+0x148]
     357:	mov    QWORD PTR [rsp+0x90],rcx
     35f:	mov    rcx,QWORD PTR [rsp+0x140]
     367:	mov    QWORD PTR [rsp+0x98],rcx
     36f:	mov    rcx,QWORD PTR [rsp+0x138]
     377:	mov    QWORD PTR [rsp+0xa0],rcx
     37f:	mov    QWORD PTR [rsp+0xa8],r11
     387:	mov    QWORD PTR [rsp+0xb0],rsi
     38f:	mov    QWORD PTR [rsp+0xb8],r8
     397:	mov    QWORD PTR [rsp+0xc0],rbx
     39f:	mov    QWORD PTR [rsp+0xc8],r12
     3a7:	mov    QWORD PTR [rsp+0xd0],r13
     3af:	mov    QWORD PTR [rsp+0xd8],r14
     3b7:	mov    QWORD PTR [rsp+0xe0],r15
     3bf:	mov    QWORD PTR [rsp+0xe8],rax
     3c7:	mov    QWORD PTR [rsp+0xf0],r9
     3cf:	mov    QWORD PTR [rsp+0xf8],r10
     3d7:	mov    QWORD PTR [rsp+0x100],rdi
     3df:	mov    esi,0x10
     3e4:	mov    rdi,QWORD PTR [rsp+0x128]
     3ec:	call   3f1 <botlish_fn_1+0x227>
			3ed: R_X86_64_PLT32	rt_list_new-0x4
     3f1:	test   rax,rax
     3f4:	jne    40f <botlish_fn_1+0x245>
     3fa:	mov    rdi,QWORD PTR [rsp+0x128]
     402:	mov    r9,QWORD PTR [rsp+0x158]
     40a:	jmp    52a <botlish_fn_1+0x360>
     40f:	mov    QWORD PTR [rsp+0x8],rax
     414:	lea    r8,[rsp+0x108]
     41c:	mov    QWORD PTR [rsp+0x108],rax
     424:	mov    esi,0x4
     429:	mov    rdx,QWORD PTR [rip+0x0]        # 430 <botlish_fn_1+0x266>
			42c: R_X86_64_GOTPCREL	botlish_entry_4-0x4 ; hex_pair<generic>
     430:	mov    ebx,0x1
     435:	mov    rcx,rbx
     438:	mov    rdi,QWORD PTR [rsp+0x128]
     440:	call   445 <botlish_fn_1+0x27b>
			441: R_X86_64_PLT32	rt_closure_new-0x4
     445:	mov    QWORD PTR [rsp+0x8],rax
     44a:	lea    r8,[rsp+0x110]
     452:	mov    QWORD PTR [rsp+0x110],rax
     45a:	mov    esi,0x5
     45f:	mov    rdx,QWORD PTR [rip+0x0]        # 466 <botlish_fn_1+0x29c>
			462: R_X86_64_GOTPCREL	botlish_entry_5-0x4 ; esc_bytes<generic>
     466:	mov    rcx,rbx
     469:	mov    rdi,QWORD PTR [rsp+0x128]
     471:	call   476 <botlish_fn_1+0x2ac>
			472: R_X86_64_PLT32	rt_closure_new-0x4
     476:	mov    QWORD PTR [rsp+0x8],rax
     47b:	lea    r8,[rsp+0x118]
     483:	mov    QWORD PTR [rsp+0x118],rax
     48b:	mov    esi,0x6
     490:	mov    rdx,QWORD PTR [rip+0x0]        # 497 <botlish_fn_1+0x2cd>
			493: R_X86_64_GOTPCREL	botlish_entry_6-0x4 ; esc_char<generic>
     497:	mov    rcx,rbx
     49a:	mov    rdi,QWORD PTR [rsp+0x128]
     4a2:	call   4a7 <botlish_fn_1+0x2dd>
			4a3: R_X86_64_PLT32	rt_closure_new-0x4
     4a7:	mov    QWORD PTR [rsp+0x8],rax
     4ac:	lea    r8,[rsp+0x120]
     4b4:	mov    QWORD PTR [rsp+0x120],rax
     4bc:	mov    esi,0x7
     4c1:	mov    rdx,QWORD PTR [rip+0x0]        # 4c8 <botlish_fn_1+0x2fe>
			4c4: R_X86_64_GOTPCREL	botlish_entry_7-0x4 ; esc_from<generic>
     4c8:	mov    rcx,rbx
     4cb:	mov    rdi,QWORD PTR [rsp+0x128]
     4d3:	call   4d8 <botlish_fn_1+0x30e>
			4d4: R_X86_64_PLT32	rt_closure_new-0x4
     4d8:	mov    QWORD PTR [rsp+0x8],rax
     4dd:	mov    QWORD PTR [rsp+0x10],0x1
     4e6:	mov    rdi,QWORD PTR [rsp+0x128]
     4ee:	mov    rcx,QWORD PTR [rdi+0x10]
     4f2:	mov    r8,QWORD PTR [rcx+0x98]
     4f9:	mov    QWORD PTR [rsp+0x18],r8
     4fe:	mov    rcx,rbx
     501:	mov    rdx,QWORD PTR [rsp+0x130]
     509:	mov    rsi,rax
     50c:	call   511 <botlish_fn_1+0x347>
			50d: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
     511:	test   rax,rax
     514:	jne    56c <botlish_fn_1+0x3a2>
     51a:	mov    rdi,QWORD PTR [rsp+0x128]
     522:	mov    r9,QWORD PTR [rsp+0x158]
     52a:	mov    rdi,QWORD PTR [rsp+0x128]
     532:	mov    QWORD PTR [rdi],r9
     535:	xor    rax,rax
     538:	mov    rbx,QWORD PTR [rsp+0x160]
     540:	mov    r12,QWORD PTR [rsp+0x168]
     548:	mov    r13,QWORD PTR [rsp+0x170]
     550:	mov    r14,QWORD PTR [rsp+0x178]
     558:	mov    r15,QWORD PTR [rsp+0x180]
     560:	add    rsp,0x190
     567:	mov    rsp,rbp
     56a:	pop    rbp
     56b:	ret
     56c:	mov    rdi,QWORD PTR [rsp+0x128]
     574:	mov    r9,QWORD PTR [rsp+0x158]
     57c:	mov    QWORD PTR [rdi],r9
     57f:	mov    rbx,QWORD PTR [rsp+0x160]
     587:	mov    r12,QWORD PTR [rsp+0x168]
     58f:	mov    r13,QWORD PTR [rsp+0x170]
     597:	mov    r14,QWORD PTR [rsp+0x178]
     59f:	mov    r15,QWORD PTR [rsp+0x180]
     5a7:	add    rsp,0x190
     5ae:	mov    rsp,rbp
     5b1:	pop    rbp
     5b2:	ret
     5b3:	mov    QWORD PTR [rsp+0x128],rdi
     5bb:	call   5c0 <botlish_fn_1+0x3f6>
			5bc: R_X86_64_PLT32	rt_stack_overflow-0x4
     5c0:	xor    rax,rax
     5c3:	mov    rbx,QWORD PTR [rsp+0x160]
     5cb:	mov    r12,QWORD PTR [rsp+0x168]
     5d3:	mov    r13,QWORD PTR [rsp+0x170]
     5db:	mov    r14,QWORD PTR [rsp+0x178]
     5e3:	mov    r15,QWORD PTR [rsp+0x180]
     5eb:	add    rsp,0x190
     5f2:	mov    rsp,rbp
     5f5:	pop    rbp
     5f6:	ret

00000000000005f7 <botlish_entry_1: web::uri_escape_text<str>>:
     5f7:	push   rbp
     5f8:	mov    rbp,rsp
     5fb:	mov    rsi,QWORD PTR [rdx]
     5fe:	call   603 <botlish_entry_1+0xc>
			5ff: R_X86_64_PLT32	botlish_fn_1-0x4 ; web::uri_escape_text<str>
     603:	mov    rsp,rbp
     606:	pop    rbp
     607:	ret

0000000000000608 <botlish_fn_2: high_nibble<generic>>:
     608:	push   rbp
     609:	mov    rbp,rsp
     60c:	sub    rsp,0x10
     610:	mov    QWORD PTR [rsp],rbx
     614:	mov    QWORD PTR [rsp+0x8],r12
     619:	mov    r8d,0x1
     61f:	test   rsi,0x1
     626:	jne    646 <botlish_fn_2+0x3e>
     62c:	xor    r8d,r8d
     62f:	test   rsi,0x7
     636:	jne    646 <botlish_fn_2+0x3e>
     63c:	movzx  rax,BYTE PTR [rsi]
     640:	cmp    al,0x1
     642:	sete   r8b
     646:	test   r8b,r8b
     649:	jne    67a <botlish_fn_2+0x72>
     64f:	mov    rax,QWORD PTR [rdi+0x10]
     653:	mov    rcx,QWORD PTR [rax+0xa0]
     65a:	xor    rbx,rbx
     65d:	mov    rdx,rbx
     660:	call   665 <botlish_fn_2+0x5d>
			661: R_X86_64_PLT32	rt_type_error-0x4
     665:	mov    rax,rbx
     668:	mov    rbx,QWORD PTR [rsp]
     66c:	mov    r12,QWORD PTR [rsp+0x8]
     671:	add    rsp,0x10
     675:	mov    rsp,rbp
     678:	pop    rbp
     679:	ret
     67a:	mov    r12,rdi
     67d:	test   rsi,0x1
     684:	mov    rbx,rsi
     687:	jne    6b2 <botlish_fn_2+0xaa>
     68d:	mov    edx,0x1f
     692:	mov    rsi,rbx
     695:	mov    rdi,r12
     698:	call   69d <botlish_fn_2+0x95>
			699: R_X86_64_PLT32	rt_int_cmp-0x4
     69d:	mov    ecx,0x2
     6a2:	test   rax,rax
     6a5:	cmovle rcx,QWORD PTR [rip+0x583]        # c30 <botlish_fn_2+0x628>
     6ad:	jmp    6c6 <botlish_fn_2+0xbe>
     6b2:	mov    ecx,0x2
     6b7:	mov    rsi,rbx
     6ba:	cmp    rsi,0x1f
     6be:	cmovle rcx,QWORD PTR [rip+0x56a]        # c30 <botlish_fn_2+0x628>
     6c6:	cmp    rcx,0x6
     6ca:	je     c13 <botlish_fn_2+0x60b>
     6d0:	mov    rsi,rbx
     6d3:	test   rsi,0x1
     6da:	jne    705 <botlish_fn_2+0xfd>
     6e0:	mov    edx,0x3f
     6e5:	mov    rsi,rbx
     6e8:	mov    rdi,r12
     6eb:	call   6f0 <botlish_fn_2+0xe8>
			6ec: R_X86_64_PLT32	rt_int_cmp-0x4
     6f0:	mov    ecx,0x2
     6f5:	test   rax,rax
     6f8:	cmovle rcx,QWORD PTR [rip+0x530]        # c30 <botlish_fn_2+0x628>
     700:	jmp    719 <botlish_fn_2+0x111>
     705:	mov    ecx,0x2
     70a:	mov    rsi,rbx
     70d:	cmp    rsi,0x3f
     711:	cmovle rcx,QWORD PTR [rip+0x517]        # c30 <botlish_fn_2+0x628>
     719:	cmp    rcx,0x6
     71d:	je     c09 <botlish_fn_2+0x601>
     723:	mov    rsi,rbx
     726:	test   rsi,0x1
     72d:	jne    758 <botlish_fn_2+0x150>
     733:	mov    edx,0x5f
     738:	mov    rsi,rbx
     73b:	mov    rdi,r12
     73e:	call   743 <botlish_fn_2+0x13b>
			73f: R_X86_64_PLT32	rt_int_cmp-0x4
     743:	mov    ecx,0x2
     748:	test   rax,rax
     74b:	cmovle rcx,QWORD PTR [rip+0x4dd]        # c30 <botlish_fn_2+0x628>
     753:	jmp    76c <botlish_fn_2+0x164>
     758:	mov    ecx,0x2
     75d:	mov    rsi,rbx
     760:	cmp    rsi,0x5f
     764:	cmovle rcx,QWORD PTR [rip+0x4c4]        # c30 <botlish_fn_2+0x628>
     76c:	cmp    rcx,0x6
     770:	je     bff <botlish_fn_2+0x5f7>
     776:	mov    rsi,rbx
     779:	test   rsi,0x1
     780:	jne    7ab <botlish_fn_2+0x1a3>
     786:	mov    edx,0x7f
     78b:	mov    rsi,rbx
     78e:	mov    rdi,r12
     791:	call   796 <botlish_fn_2+0x18e>
			792: R_X86_64_PLT32	rt_int_cmp-0x4
     796:	mov    ecx,0x2
     79b:	test   rax,rax
     79e:	cmovle rcx,QWORD PTR [rip+0x48a]        # c30 <botlish_fn_2+0x628>
     7a6:	jmp    7bf <botlish_fn_2+0x1b7>
     7ab:	mov    ecx,0x2
     7b0:	mov    rsi,rbx
     7b3:	cmp    rsi,0x7f
     7b7:	cmovle rcx,QWORD PTR [rip+0x471]        # c30 <botlish_fn_2+0x628>
     7bf:	cmp    rcx,0x6
     7c3:	je     bf5 <botlish_fn_2+0x5ed>
     7c9:	mov    rsi,rbx
     7cc:	test   rsi,0x1
     7d3:	jne    7fe <botlish_fn_2+0x1f6>
     7d9:	mov    edx,0x9f
     7de:	mov    rsi,rbx
     7e1:	mov    rdi,r12
     7e4:	call   7e9 <botlish_fn_2+0x1e1>
			7e5: R_X86_64_PLT32	rt_int_cmp-0x4
     7e9:	mov    ecx,0x2
     7ee:	test   rax,rax
     7f1:	cmovle rcx,QWORD PTR [rip+0x437]        # c30 <botlish_fn_2+0x628>
     7f9:	jmp    815 <botlish_fn_2+0x20d>
     7fe:	mov    ecx,0x2
     803:	mov    rsi,rbx
     806:	cmp    rsi,0x9f
     80d:	cmovle rcx,QWORD PTR [rip+0x41b]        # c30 <botlish_fn_2+0x628>
     815:	cmp    rcx,0x6
     819:	je     beb <botlish_fn_2+0x5e3>
     81f:	mov    rsi,rbx
     822:	test   rsi,0x1
     829:	jne    854 <botlish_fn_2+0x24c>
     82f:	mov    edx,0xbf
     834:	mov    rsi,rbx
     837:	mov    rdi,r12
     83a:	call   83f <botlish_fn_2+0x237>
			83b: R_X86_64_PLT32	rt_int_cmp-0x4
     83f:	mov    ecx,0x2
     844:	test   rax,rax
     847:	cmovle rcx,QWORD PTR [rip+0x3e1]        # c30 <botlish_fn_2+0x628>
     84f:	jmp    86b <botlish_fn_2+0x263>
     854:	mov    ecx,0x2
     859:	mov    rsi,rbx
     85c:	cmp    rsi,0xbf
     863:	cmovle rcx,QWORD PTR [rip+0x3c5]        # c30 <botlish_fn_2+0x628>
     86b:	cmp    rcx,0x6
     86f:	je     be1 <botlish_fn_2+0x5d9>
     875:	mov    rsi,rbx
     878:	test   rsi,0x1
     87f:	jne    8aa <botlish_fn_2+0x2a2>
     885:	mov    edx,0xdf
     88a:	mov    rsi,rbx
     88d:	mov    rdi,r12
     890:	call   895 <botlish_fn_2+0x28d>
			891: R_X86_64_PLT32	rt_int_cmp-0x4
     895:	mov    ecx,0x2
     89a:	test   rax,rax
     89d:	cmovle rcx,QWORD PTR [rip+0x38b]        # c30 <botlish_fn_2+0x628>
     8a5:	jmp    8c1 <botlish_fn_2+0x2b9>
     8aa:	mov    ecx,0x2
     8af:	mov    rsi,rbx
     8b2:	cmp    rsi,0xdf
     8b9:	cmovle rcx,QWORD PTR [rip+0x36f]        # c30 <botlish_fn_2+0x628>
     8c1:	cmp    rcx,0x6
     8c5:	je     bd7 <botlish_fn_2+0x5cf>
     8cb:	mov    rsi,rbx
     8ce:	test   rsi,0x1
     8d5:	jne    901 <botlish_fn_2+0x2f9>
     8db:	mov    edx,0xff
     8e0:	mov    rsi,rbx
     8e3:	mov    rdi,r12
     8e6:	call   8eb <botlish_fn_2+0x2e3>
			8e7: R_X86_64_PLT32	rt_int_cmp-0x4
     8eb:	mov    r10d,0x2
     8f1:	test   rax,rax
     8f4:	cmovle r10,QWORD PTR [rip+0x334]        # c30 <botlish_fn_2+0x628>
     8fc:	jmp    919 <botlish_fn_2+0x311>
     901:	mov    r10d,0x2
     907:	mov    rsi,rbx
     90a:	cmp    rsi,0xff
     911:	cmovle r10,QWORD PTR [rip+0x317]        # c30 <botlish_fn_2+0x628>
     919:	cmp    r10,0x6
     91d:	je     bcd <botlish_fn_2+0x5c5>
     923:	mov    rsi,rbx
     926:	test   rsi,0x1
     92d:	jne    958 <botlish_fn_2+0x350>
     933:	mov    edx,0x11f
     938:	mov    rsi,rbx
     93b:	mov    rdi,r12
     93e:	call   943 <botlish_fn_2+0x33b>
			93f: R_X86_64_PLT32	rt_int_cmp-0x4
     943:	mov    ecx,0x2
     948:	test   rax,rax
     94b:	cmovle rcx,QWORD PTR [rip+0x2dd]        # c30 <botlish_fn_2+0x628>
     953:	jmp    96f <botlish_fn_2+0x367>
     958:	mov    ecx,0x2
     95d:	mov    rsi,rbx
     960:	cmp    rsi,0x11f
     967:	cmovle rcx,QWORD PTR [rip+0x2c1]        # c30 <botlish_fn_2+0x628>
     96f:	cmp    rcx,0x6
     973:	je     bc3 <botlish_fn_2+0x5bb>
     979:	mov    rsi,rbx
     97c:	test   rsi,0x1
     983:	jne    9ae <botlish_fn_2+0x3a6>
     989:	mov    edx,0x13f
     98e:	mov    rsi,rbx
     991:	mov    rdi,r12
     994:	call   999 <botlish_fn_2+0x391>
			995: R_X86_64_PLT32	rt_int_cmp-0x4
     999:	mov    ecx,0x2
     99e:	test   rax,rax
     9a1:	cmovle rcx,QWORD PTR [rip+0x287]        # c30 <botlish_fn_2+0x628>
     9a9:	jmp    9c5 <botlish_fn_2+0x3bd>
     9ae:	mov    ecx,0x2
     9b3:	mov    rsi,rbx
     9b6:	cmp    rsi,0x13f
     9bd:	cmovle rcx,QWORD PTR [rip+0x26b]        # c30 <botlish_fn_2+0x628>
     9c5:	cmp    rcx,0x6
     9c9:	je     bb9 <botlish_fn_2+0x5b1>
     9cf:	mov    rsi,rbx
     9d2:	test   rsi,0x1
     9d9:	jne    a04 <botlish_fn_2+0x3fc>
     9df:	mov    edx,0x15f
     9e4:	mov    rsi,rbx
     9e7:	mov    rdi,r12
     9ea:	call   9ef <botlish_fn_2+0x3e7>
			9eb: R_X86_64_PLT32	rt_int_cmp-0x4
     9ef:	mov    ecx,0x2
     9f4:	test   rax,rax
     9f7:	cmovle rcx,QWORD PTR [rip+0x231]        # c30 <botlish_fn_2+0x628>
     9ff:	jmp    a1b <botlish_fn_2+0x413>
     a04:	mov    ecx,0x2
     a09:	mov    rsi,rbx
     a0c:	cmp    rsi,0x15f
     a13:	cmovle rcx,QWORD PTR [rip+0x215]        # c30 <botlish_fn_2+0x628>
     a1b:	cmp    rcx,0x6
     a1f:	je     baf <botlish_fn_2+0x5a7>
     a25:	mov    rsi,rbx
     a28:	test   rsi,0x1
     a2f:	jne    a5a <botlish_fn_2+0x452>
     a35:	mov    edx,0x17f
     a3a:	mov    rsi,rbx
     a3d:	mov    rdi,r12
     a40:	call   a45 <botlish_fn_2+0x43d>
			a41: R_X86_64_PLT32	rt_int_cmp-0x4
     a45:	mov    edi,0x2
     a4a:	test   rax,rax
     a4d:	cmovle rdi,QWORD PTR [rip+0x1db]        # c30 <botlish_fn_2+0x628>
     a55:	jmp    a71 <botlish_fn_2+0x469>
     a5a:	mov    edi,0x2
     a5f:	mov    rsi,rbx
     a62:	cmp    rsi,0x17f
     a69:	cmovle rdi,QWORD PTR [rip+0x1bf]        # c30 <botlish_fn_2+0x628>
     a71:	cmp    rdi,0x6
     a75:	je     ba5 <botlish_fn_2+0x59d>
     a7b:	mov    rsi,rbx
     a7e:	test   rsi,0x1
     a85:	jne    ab0 <botlish_fn_2+0x4a8>
     a8b:	mov    edx,0x19f
     a90:	mov    rsi,rbx
     a93:	mov    rdi,r12
     a96:	call   a9b <botlish_fn_2+0x493>
			a97: R_X86_64_PLT32	rt_int_cmp-0x4
     a9b:	mov    ecx,0x2
     aa0:	test   rax,rax
     aa3:	cmovle rcx,QWORD PTR [rip+0x185]        # c30 <botlish_fn_2+0x628>
     aab:	jmp    ac7 <botlish_fn_2+0x4bf>
     ab0:	mov    ecx,0x2
     ab5:	mov    rsi,rbx
     ab8:	cmp    rsi,0x19f
     abf:	cmovle rcx,QWORD PTR [rip+0x169]        # c30 <botlish_fn_2+0x628>
     ac7:	cmp    rcx,0x6
     acb:	je     b9b <botlish_fn_2+0x593>
     ad1:	mov    rsi,rbx
     ad4:	test   rsi,0x1
     adb:	jne    b06 <botlish_fn_2+0x4fe>
     ae1:	mov    edx,0x1bf
     ae6:	mov    rsi,rbx
     ae9:	mov    rdi,r12
     aec:	call   af1 <botlish_fn_2+0x4e9>
			aed: R_X86_64_PLT32	rt_int_cmp-0x4
     af1:	mov    ecx,0x2
     af6:	test   rax,rax
     af9:	cmovle rcx,QWORD PTR [rip+0x12f]        # c30 <botlish_fn_2+0x628>
     b01:	jmp    b1d <botlish_fn_2+0x515>
     b06:	mov    ecx,0x2
     b0b:	mov    rsi,rbx
     b0e:	cmp    rsi,0x1bf
     b15:	cmovle rcx,QWORD PTR [rip+0x113]        # c30 <botlish_fn_2+0x628>
     b1d:	cmp    rcx,0x6
     b21:	je     b91 <botlish_fn_2+0x589>
     b27:	mov    rsi,rbx
     b2a:	test   rsi,0x1
     b31:	jne    b5c <botlish_fn_2+0x554>
     b37:	mov    edx,0x1df
     b3c:	mov    rsi,rbx
     b3f:	mov    rdi,r12
     b42:	call   b47 <botlish_fn_2+0x53f>
			b43: R_X86_64_PLT32	rt_int_cmp-0x4
     b47:	mov    ecx,0x2
     b4c:	test   rax,rax
     b4f:	cmovle rcx,QWORD PTR [rip+0xd9]        # c30 <botlish_fn_2+0x628>
     b57:	jmp    b73 <botlish_fn_2+0x56b>
     b5c:	mov    ecx,0x2
     b61:	mov    rsi,rbx
     b64:	cmp    rsi,0x1df
     b6b:	cmovle rcx,QWORD PTR [rip+0xbd]        # c30 <botlish_fn_2+0x628>
     b73:	cmp    rcx,0x6
     b77:	je     b87 <botlish_fn_2+0x57f>
     b7d:	mov    eax,0x1f
     b82:	jmp    c18 <botlish_fn_2+0x610>
     b87:	mov    eax,0x1d
     b8c:	jmp    c18 <botlish_fn_2+0x610>
     b91:	mov    eax,0x1b
     b96:	jmp    c18 <botlish_fn_2+0x610>
     b9b:	mov    eax,0x19
     ba0:	jmp    c18 <botlish_fn_2+0x610>
     ba5:	mov    eax,0x17
     baa:	jmp    c18 <botlish_fn_2+0x610>
     baf:	mov    eax,0x15
     bb4:	jmp    c18 <botlish_fn_2+0x610>
     bb9:	mov    eax,0x13
     bbe:	jmp    c18 <botlish_fn_2+0x610>
     bc3:	mov    eax,0x11
     bc8:	jmp    c18 <botlish_fn_2+0x610>
     bcd:	mov    eax,0xf
     bd2:	jmp    c18 <botlish_fn_2+0x610>
     bd7:	mov    eax,0xd
     bdc:	jmp    c18 <botlish_fn_2+0x610>
     be1:	mov    eax,0xb
     be6:	jmp    c18 <botlish_fn_2+0x610>
     beb:	mov    eax,0x9
     bf0:	jmp    c18 <botlish_fn_2+0x610>
     bf5:	mov    eax,0x7
     bfa:	jmp    c18 <botlish_fn_2+0x610>
     bff:	mov    eax,0x5
     c04:	jmp    c18 <botlish_fn_2+0x610>
     c09:	mov    eax,0x3
     c0e:	jmp    c18 <botlish_fn_2+0x610>
     c13:	mov    eax,0x1
     c18:	mov    rbx,QWORD PTR [rsp]
     c1c:	mov    r12,QWORD PTR [rsp+0x8]
     c21:	add    rsp,0x10
     c25:	mov    rsp,rbp
     c28:	pop    rbp
     c29:	ret
     c2a:	add    BYTE PTR [rax],al
     c2c:	add    BYTE PTR [rax],al
     c2e:	add    BYTE PTR [rax],al
     c30:	(bad)
     c31:	add    BYTE PTR [rax],al
     c33:	add    BYTE PTR [rax],al
     c35:	add    BYTE PTR [rax],al
	...

0000000000000c38 <botlish_entry_2: high_nibble<generic>>:
     c38:	push   rbp
     c39:	mov    rbp,rsp
     c3c:	mov    rsi,QWORD PTR [rdx]
     c3f:	call   c44 <botlish_entry_2+0xc>
			c40: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
     c44:	mov    rsp,rbp
     c47:	pop    rbp
     c48:	ret
     c49:	add    BYTE PTR [rax],al
     c4b:	add    BYTE PTR [rax],al
     c4d:	add    BYTE PTR [rax],al
	...

0000000000000c50 <botlish_fn_3: is_unreserved<generic>>:
     c50:	push   rbp
     c51:	mov    rbp,rsp
     c54:	sub    rsp,0x20
     c58:	mov    QWORD PTR [rsp],rbx
     c5c:	mov    QWORD PTR [rsp+0x8],r12
     c61:	mov    QWORD PTR [rsp+0x10],r13
     c66:	mov    r8d,0x1
     c6c:	test   rsi,0x1
     c73:	jne    c93 <botlish_fn_3+0x43>
     c79:	xor    r8d,r8d
     c7c:	test   rsi,0x7
     c83:	jne    c93 <botlish_fn_3+0x43>
     c89:	movzx  rax,BYTE PTR [rsi]
     c8d:	cmp    al,0x1
     c8f:	sete   r8b
     c93:	test   r8b,r8b
     c96:	jne    ccc <botlish_fn_3+0x7c>
     c9c:	mov    rdx,QWORD PTR [rdi+0x10]
     ca0:	mov    rcx,QWORD PTR [rdx+0xa0]
     ca7:	xor    rbx,rbx
     caa:	mov    rdx,rbx
     cad:	call   cb2 <botlish_fn_3+0x62>
			cae: R_X86_64_PLT32	rt_type_error-0x4
     cb2:	mov    rax,rbx
     cb5:	mov    rbx,QWORD PTR [rsp]
     cb9:	mov    r12,QWORD PTR [rsp+0x8]
     cbe:	mov    r13,QWORD PTR [rsp+0x10]
     cc3:	add    rsp,0x20
     cc7:	mov    rsp,rbp
     cca:	pop    rbp
     ccb:	ret
     ccc:	mov    r12,rdi
     ccf:	test   rsi,0x1
     cd6:	mov    rbx,rsi
     cd9:	jne    d04 <botlish_fn_3+0xb4>
     cdf:	mov    edx,0x59
     ce4:	mov    rsi,rbx
     ce7:	mov    rdi,r12
     cea:	call   cef <botlish_fn_3+0x9f>
			ceb: R_X86_64_PLT32	rt_int_cmp-0x4
     cef:	mov    ecx,0x2
     cf4:	test   rax,rax
     cf7:	cmovle rcx,QWORD PTR [rip+0x461]        # 1160 <botlish_fn_3+0x510>
     cff:	jmp    d18 <botlish_fn_3+0xc8>
     d04:	mov    ecx,0x2
     d09:	mov    rsi,rbx
     d0c:	cmp    rsi,0x59
     d10:	cmovle rcx,QWORD PTR [rip+0x448]        # 1160 <botlish_fn_3+0x510>
     d18:	mov    eax,0x6
     d1d:	mov    r13,rax
     d20:	cmp    rcx,0x6
     d24:	je     1143 <botlish_fn_3+0x4f3>
     d2a:	mov    rsi,rbx
     d2d:	test   rsi,0x1
     d34:	jne    d5f <botlish_fn_3+0x10f>
     d3a:	mov    edx,0x5d
     d3f:	mov    rsi,rbx
     d42:	mov    rdi,r12
     d45:	call   d4a <botlish_fn_3+0xfa>
			d46: R_X86_64_PLT32	rt_int_cmp-0x4
     d4a:	mov    ecx,0x2
     d4f:	test   rax,rax
     d52:	cmovle rcx,QWORD PTR [rip+0x406]        # 1160 <botlish_fn_3+0x510>
     d5a:	jmp    d73 <botlish_fn_3+0x123>
     d5f:	mov    ecx,0x2
     d64:	mov    rsi,rbx
     d67:	cmp    rsi,0x5d
     d6b:	cmovle rcx,QWORD PTR [rip+0x3ed]        # 1160 <botlish_fn_3+0x510>
     d73:	cmp    rcx,0x6
     d77:	je     113b <botlish_fn_3+0x4eb>
     d7d:	mov    rsi,rbx
     d80:	test   rsi,0x1
     d87:	jne    db2 <botlish_fn_3+0x162>
     d8d:	mov    edx,0x5f
     d92:	mov    rsi,rbx
     d95:	mov    rdi,r12
     d98:	call   d9d <botlish_fn_3+0x14d>
			d99: R_X86_64_PLT32	rt_int_cmp-0x4
     d9d:	mov    ecx,0x2
     da2:	test   rax,rax
     da5:	cmovle rcx,QWORD PTR [rip+0x3b3]        # 1160 <botlish_fn_3+0x510>
     dad:	jmp    dc6 <botlish_fn_3+0x176>
     db2:	mov    ecx,0x2
     db7:	mov    rsi,rbx
     dba:	cmp    rsi,0x5f
     dbe:	cmovle rcx,QWORD PTR [rip+0x39a]        # 1160 <botlish_fn_3+0x510>
     dc6:	cmp    rcx,0x6
     dca:	je     1131 <botlish_fn_3+0x4e1>
     dd0:	mov    rsi,rbx
     dd3:	test   rsi,0x1
     dda:	jne    e05 <botlish_fn_3+0x1b5>
     de0:	mov    edx,0x73
     de5:	mov    rsi,rbx
     de8:	mov    rdi,r12
     deb:	call   df0 <botlish_fn_3+0x1a0>
			dec: R_X86_64_PLT32	rt_int_cmp-0x4
     df0:	mov    ecx,0x2
     df5:	test   rax,rax
     df8:	cmovle rcx,QWORD PTR [rip+0x360]        # 1160 <botlish_fn_3+0x510>
     e00:	jmp    e19 <botlish_fn_3+0x1c9>
     e05:	mov    ecx,0x2
     e0a:	mov    rsi,rbx
     e0d:	cmp    rsi,0x73
     e11:	cmovle rcx,QWORD PTR [rip+0x347]        # 1160 <botlish_fn_3+0x510>
     e19:	cmp    rcx,0x6
     e1d:	je     1129 <botlish_fn_3+0x4d9>
     e23:	mov    rsi,rbx
     e26:	test   rsi,0x1
     e2d:	jne    e58 <botlish_fn_3+0x208>
     e33:	mov    edx,0x81
     e38:	mov    rsi,rbx
     e3b:	mov    rdi,r12
     e3e:	call   e43 <botlish_fn_3+0x1f3>
			e3f: R_X86_64_PLT32	rt_int_cmp-0x4
     e43:	mov    ecx,0x2
     e48:	test   rax,rax
     e4b:	cmovle rcx,QWORD PTR [rip+0x30d]        # 1160 <botlish_fn_3+0x510>
     e53:	jmp    e6f <botlish_fn_3+0x21f>
     e58:	mov    ecx,0x2
     e5d:	mov    rsi,rbx
     e60:	cmp    rsi,0x81
     e67:	cmovle rcx,QWORD PTR [rip+0x2f1]        # 1160 <botlish_fn_3+0x510>
     e6f:	cmp    rcx,0x6
     e73:	je     111f <botlish_fn_3+0x4cf>
     e79:	mov    rsi,rbx
     e7c:	test   rsi,0x1
     e83:	jne    eae <botlish_fn_3+0x25e>
     e89:	mov    edx,0xb5
     e8e:	mov    rsi,rbx
     e91:	mov    rdi,r12
     e94:	call   e99 <botlish_fn_3+0x249>
			e95: R_X86_64_PLT32	rt_int_cmp-0x4
     e99:	mov    ecx,0x2
     e9e:	test   rax,rax
     ea1:	cmovle rcx,QWORD PTR [rip+0x2b7]        # 1160 <botlish_fn_3+0x510>
     ea9:	jmp    ec5 <botlish_fn_3+0x275>
     eae:	mov    ecx,0x2
     eb3:	mov    rsi,rbx
     eb6:	cmp    rsi,0xb5
     ebd:	cmovle rcx,QWORD PTR [rip+0x29b]        # 1160 <botlish_fn_3+0x510>
     ec5:	cmp    rcx,0x6
     ec9:	je     1117 <botlish_fn_3+0x4c7>
     ecf:	mov    rsi,rbx
     ed2:	test   rsi,0x1
     ed9:	jne    f04 <botlish_fn_3+0x2b4>
     edf:	mov    edx,0xbd
     ee4:	mov    rsi,rbx
     ee7:	mov    rdi,r12
     eea:	call   eef <botlish_fn_3+0x29f>
			eeb: R_X86_64_PLT32	rt_int_cmp-0x4
     eef:	mov    ecx,0x2
     ef4:	test   rax,rax
     ef7:	cmovle rcx,QWORD PTR [rip+0x261]        # 1160 <botlish_fn_3+0x510>
     eff:	jmp    f1b <botlish_fn_3+0x2cb>
     f04:	mov    ecx,0x2
     f09:	mov    rsi,rbx
     f0c:	cmp    rsi,0xbd
     f13:	cmovle rcx,QWORD PTR [rip+0x245]        # 1160 <botlish_fn_3+0x510>
     f1b:	cmp    rcx,0x6
     f1f:	je     110d <botlish_fn_3+0x4bd>
     f25:	mov    rsi,rbx
     f28:	test   rsi,0x1
     f2f:	jne    f5b <botlish_fn_3+0x30b>
     f35:	mov    edx,0xbf
     f3a:	mov    rsi,rbx
     f3d:	mov    rdi,r12
     f40:	call   f45 <botlish_fn_3+0x2f5>
			f41: R_X86_64_PLT32	rt_int_cmp-0x4
     f45:	mov    r11d,0x2
     f4b:	test   rax,rax
     f4e:	cmovle r11,QWORD PTR [rip+0x20a]        # 1160 <botlish_fn_3+0x510>
     f56:	jmp    f73 <botlish_fn_3+0x323>
     f5b:	mov    r11d,0x2
     f61:	mov    rsi,rbx
     f64:	cmp    rsi,0xbf
     f6b:	cmovle r11,QWORD PTR [rip+0x1ed]        # 1160 <botlish_fn_3+0x510>
     f73:	cmp    r11,0x6
     f77:	je     1105 <botlish_fn_3+0x4b5>
     f7d:	mov    rsi,rbx
     f80:	test   rsi,0x1
     f87:	jne    fb2 <botlish_fn_3+0x362>
     f8d:	mov    edx,0xc1
     f92:	mov    rsi,rbx
     f95:	mov    rdi,r12
     f98:	call   f9d <botlish_fn_3+0x34d>
			f99: R_X86_64_PLT32	rt_int_cmp-0x4
     f9d:	mov    ecx,0x2
     fa2:	test   rax,rax
     fa5:	cmovle rcx,QWORD PTR [rip+0x1b3]        # 1160 <botlish_fn_3+0x510>
     fad:	jmp    fc9 <botlish_fn_3+0x379>
     fb2:	mov    ecx,0x2
     fb7:	mov    rsi,rbx
     fba:	cmp    rsi,0xc1
     fc1:	cmovle rcx,QWORD PTR [rip+0x197]        # 1160 <botlish_fn_3+0x510>
     fc9:	cmp    rcx,0x6
     fcd:	je     10fb <botlish_fn_3+0x4ab>
     fd3:	mov    rsi,rbx
     fd6:	test   rsi,0x1
     fdd:	jne    1008 <botlish_fn_3+0x3b8>
     fe3:	mov    edx,0xf5
     fe8:	mov    rsi,rbx
     feb:	mov    rdi,r12
     fee:	call   ff3 <botlish_fn_3+0x3a3>
			fef: R_X86_64_PLT32	rt_int_cmp-0x4
     ff3:	mov    ecx,0x2
     ff8:	test   rax,rax
     ffb:	cmovle rcx,QWORD PTR [rip+0x15d]        # 1160 <botlish_fn_3+0x510>
    1003:	jmp    101f <botlish_fn_3+0x3cf>
    1008:	mov    ecx,0x2
    100d:	mov    rsi,rbx
    1010:	cmp    rsi,0xf5
    1017:	cmovle rcx,QWORD PTR [rip+0x141]        # 1160 <botlish_fn_3+0x510>
    101f:	cmp    rcx,0x6
    1023:	je     10f3 <botlish_fn_3+0x4a3>
    1029:	mov    rsi,rbx
    102c:	test   rsi,0x1
    1033:	jne    105e <botlish_fn_3+0x40e>
    1039:	mov    edx,0xfb
    103e:	mov    rsi,rbx
    1041:	mov    rdi,r12
    1044:	call   1049 <botlish_fn_3+0x3f9>
			1045: R_X86_64_PLT32	rt_int_cmp-0x4
    1049:	mov    ecx,0x2
    104e:	test   rax,rax
    1051:	cmovle rcx,QWORD PTR [rip+0x107]        # 1160 <botlish_fn_3+0x510>
    1059:	jmp    1075 <botlish_fn_3+0x425>
    105e:	mov    ecx,0x2
    1063:	mov    rsi,rbx
    1066:	cmp    rsi,0xfb
    106d:	cmovle rcx,QWORD PTR [rip+0xeb]        # 1160 <botlish_fn_3+0x510>
    1075:	cmp    rcx,0x6
    1079:	je     10e9 <botlish_fn_3+0x499>
    107f:	mov    rsi,rbx
    1082:	test   rsi,0x1
    1089:	jne    10b5 <botlish_fn_3+0x465>
    108f:	mov    edx,0xfd
    1094:	mov    rsi,rbx
    1097:	mov    rdi,r12
    109a:	call   109f <botlish_fn_3+0x44f>
			109b: R_X86_64_PLT32	rt_int_cmp-0x4
    109f:	mov    r8d,0x2
    10a5:	test   rax,rax
    10a8:	cmovle r8,QWORD PTR [rip+0xb0]        # 1160 <botlish_fn_3+0x510>
    10b0:	jmp    10cd <botlish_fn_3+0x47d>
    10b5:	mov    r8d,0x2
    10bb:	mov    rsi,rbx
    10be:	cmp    rsi,0xfd
    10c5:	cmovle r8,QWORD PTR [rip+0x93]        # 1160 <botlish_fn_3+0x510>
    10cd:	cmp    r8,0x6
    10d1:	je     10e1 <botlish_fn_3+0x491>
    10d7:	mov    eax,0x2
    10dc:	jmp    1148 <botlish_fn_3+0x4f8>
    10e1:	mov    rax,r13
    10e4:	jmp    1148 <botlish_fn_3+0x4f8>
    10e9:	mov    eax,0x2
    10ee:	jmp    1148 <botlish_fn_3+0x4f8>
    10f3:	mov    rax,r13
    10f6:	jmp    1148 <botlish_fn_3+0x4f8>
    10fb:	mov    eax,0x2
    1100:	jmp    1148 <botlish_fn_3+0x4f8>
    1105:	mov    rax,r13
    1108:	jmp    1148 <botlish_fn_3+0x4f8>
    110d:	mov    eax,0x2
    1112:	jmp    1148 <botlish_fn_3+0x4f8>
    1117:	mov    rax,r13
    111a:	jmp    1148 <botlish_fn_3+0x4f8>
    111f:	mov    eax,0x2
    1124:	jmp    1148 <botlish_fn_3+0x4f8>
    1129:	mov    rax,r13
    112c:	jmp    1148 <botlish_fn_3+0x4f8>
    1131:	mov    eax,0x2
    1136:	jmp    1148 <botlish_fn_3+0x4f8>
    113b:	mov    rax,r13
    113e:	jmp    1148 <botlish_fn_3+0x4f8>
    1143:	mov    eax,0x2
    1148:	mov    rbx,QWORD PTR [rsp]
    114c:	mov    r12,QWORD PTR [rsp+0x8]
    1151:	mov    r13,QWORD PTR [rsp+0x10]
    1156:	add    rsp,0x20
    115a:	mov    rsp,rbp
    115d:	pop    rbp
    115e:	ret
    115f:	add    BYTE PTR [rsi],al
    1161:	add    BYTE PTR [rax],al
    1163:	add    BYTE PTR [rax],al
    1165:	add    BYTE PTR [rax],al
	...

0000000000001168 <botlish_entry_3: is_unreserved<generic>>:
    1168:	push   rbp
    1169:	mov    rbp,rsp
    116c:	mov    rsi,QWORD PTR [rdx]
    116f:	call   1174 <botlish_entry_3+0xc>
			1170: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    1174:	mov    rsp,rbp
    1177:	pop    rbp
    1178:	ret

0000000000001179 <botlish_fn_4: hex_pair<generic>>:
    1179:	push   rbp
    117a:	mov    rbp,rsp
    117d:	sub    rsp,0x40
    1181:	mov    QWORD PTR [rsp+0x10],rbx
    1186:	mov    QWORD PTR [rsp+0x18],r12
    118b:	mov    QWORD PTR [rsp+0x20],r13
    1190:	mov    QWORD PTR [rsp+0x28],r14
    1195:	mov    QWORD PTR [rsp+0x30],r15
    119a:	mov    r13,rdx
    119d:	mov    rbx,QWORD PTR [rdi]
    11a0:	mov    rax,QWORD PTR [rdi+0x8]
    11a4:	lea    rcx,[rbx+0x8]
    11a8:	cmp    rcx,rax
    11ab:	ja     13c1 <botlish_fn_4+0x248>
    11b1:	lea    rax,[rbx+0x8]
    11b5:	mov    QWORD PTR [rdi],rax
    11b8:	mov    r12,rdi
    11bb:	mov    QWORD PTR [rbx],0x0
    11c2:	mov    rdx,r13
    11c5:	mov    QWORD PTR [rsp],rdx
    11c9:	mov    rax,QWORD PTR [rsi+0x20]
    11cd:	mov    r14,rsi
    11d0:	mov    rsi,QWORD PTR [rax]
    11d3:	mov    QWORD PTR [rsp+0x8],rsi
    11d8:	mov    r15,rsi
    11db:	mov    rsi,r13
    11de:	mov    rdi,r12
    11e1:	call   11e6 <botlish_fn_4+0x6d>
			11e2: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
    11e6:	test   rax,rax
    11e9:	jne    11f7 <botlish_fn_4+0x7e>
    11ef:	mov    rdi,r12
    11f2:	jmp    136e <botlish_fn_4+0x1f5>
    11f7:	test   rax,0x1
    11fd:	jne    120e <botlish_fn_4+0x95>
    1203:	mov    rdx,rax
    1206:	mov    rsi,r15
    1209:	jmp    122a <botlish_fn_4+0xb1>
    120e:	mov    rsi,r15
    1211:	mov    rdx,QWORD PTR [rsi+0x8]
    1215:	mov    rcx,rax
    1218:	sar    rcx,1
    121b:	mov    rdi,rax
    121e:	cmp    rcx,rdx
    1221:	jb     124b <botlish_fn_4+0xd2>
    1227:	mov    rdx,rdi
    122a:	mov    rdi,r12
    122d:	call   1232 <botlish_fn_4+0xb9>
			122e: R_X86_64_PLT32	rt_list_get-0x4
    1232:	test   rax,rax
    1235:	jne    1243 <botlish_fn_4+0xca>
    123b:	mov    rdi,r12
    123e:	jmp    136e <botlish_fn_4+0x1f5>
    1243:	mov    rsi,rax
    1246:	jmp    1253 <botlish_fn_4+0xda>
    124b:	mov    rdx,QWORD PTR [rsi+0x10]
    124f:	mov    rsi,QWORD PTR [rdx+rcx*8]
    1253:	mov    QWORD PTR [rsp],rsi
    1257:	mov    rax,rsi
    125a:	mov    rsi,r14
    125d:	mov    r14,rax
    1260:	mov    rsi,QWORD PTR [rsi+0x20]
    1264:	mov    rsi,QWORD PTR [rsi]
    1267:	mov    r15,rsi
    126a:	mov    ecx,0x1
    126f:	mov    rdx,r13
    1272:	test   rdx,0x1
    1279:	je     1287 <botlish_fn_4+0x10e>
    127f:	mov    r13,rdx
    1282:	jmp    12ac <botlish_fn_4+0x133>
    1287:	xor    ecx,ecx
    1289:	test   rdx,0x7
    1290:	je     129e <botlish_fn_4+0x125>
    1296:	mov    r13,rdx
    1299:	jmp    12ac <botlish_fn_4+0x133>
    129e:	movzx  r9,BYTE PTR [rdx]
    12a2:	mov    r13,rdx
    12a5:	cmp    r9b,0x1
    12a9:	sete   cl
    12ac:	test   cl,cl
    12ae:	jne    12d5 <botlish_fn_4+0x15c>
    12b4:	mov    rdi,r12
    12b7:	mov    rax,QWORD PTR [rdi+0x10]
    12bb:	mov    rcx,QWORD PTR [rax+0xa8]
    12c2:	xor    rdx,rdx
    12c5:	mov    rsi,r13
    12c8:	call   12cd <botlish_fn_4+0x154>
			12c9: R_X86_64_PLT32	rt_type_error-0x4
    12cd:	mov    rdi,r12
    12d0:	jmp    136e <botlish_fn_4+0x1f5>
    12d5:	mov    rsi,r13
    12d8:	mov    edx,0x21
    12dd:	mov    rdi,r12
    12e0:	call   12e5 <botlish_fn_4+0x16c>
			12e1: R_X86_64_PLT32	rt_int_mod-0x4
    12e5:	test   rax,rax
    12e8:	jne    12f6 <botlish_fn_4+0x17d>
    12ee:	mov    rdi,r12
    12f1:	jmp    136e <botlish_fn_4+0x1f5>
    12f6:	test   rax,0x1
    12fc:	jne    130d <botlish_fn_4+0x194>
    1302:	mov    rdx,rax
    1305:	mov    rsi,r15
    1308:	jmp    1329 <botlish_fn_4+0x1b0>
    130d:	mov    rsi,r15
    1310:	mov    rdx,QWORD PTR [rsi+0x8]
    1314:	mov    rcx,rax
    1317:	sar    rcx,1
    131a:	mov    rdi,rax
    131d:	cmp    rcx,rdx
    1320:	jb     134a <botlish_fn_4+0x1d1>
    1326:	mov    rdx,rdi
    1329:	mov    rdi,r12
    132c:	call   1331 <botlish_fn_4+0x1b8>
			132d: R_X86_64_PLT32	rt_list_get-0x4
    1331:	test   rax,rax
    1334:	jne    1342 <botlish_fn_4+0x1c9>
    133a:	mov    rdi,r12
    133d:	jmp    136e <botlish_fn_4+0x1f5>
    1342:	mov    rdx,rax
    1345:	jmp    1352 <botlish_fn_4+0x1d9>
    134a:	mov    rax,QWORD PTR [rsi+0x10]
    134e:	mov    rdx,QWORD PTR [rax+rcx*8]
    1352:	mov    QWORD PTR [rsp+0x8],rdx
    1357:	mov    rsi,r14
    135a:	mov    rdi,r12
    135d:	call   1362 <botlish_fn_4+0x1e9>
			135e: R_X86_64_PLT32	rt_str_cat-0x4
    1362:	test   rax,rax
    1365:	jne    1399 <botlish_fn_4+0x220>
    136b:	mov    rdi,r12
    136e:	mov    rdi,r12
    1371:	mov    QWORD PTR [rdi],rbx
    1374:	xor    rax,rax
    1377:	mov    rbx,QWORD PTR [rsp+0x10]
    137c:	mov    r12,QWORD PTR [rsp+0x18]
    1381:	mov    r13,QWORD PTR [rsp+0x20]
    1386:	mov    r14,QWORD PTR [rsp+0x28]
    138b:	mov    r15,QWORD PTR [rsp+0x30]
    1390:	add    rsp,0x40
    1394:	mov    rsp,rbp
    1397:	pop    rbp
    1398:	ret
    1399:	mov    rdi,r12
    139c:	mov    QWORD PTR [rdi],rbx
    139f:	mov    rbx,QWORD PTR [rsp+0x10]
    13a4:	mov    r12,QWORD PTR [rsp+0x18]
    13a9:	mov    r13,QWORD PTR [rsp+0x20]
    13ae:	mov    r14,QWORD PTR [rsp+0x28]
    13b3:	mov    r15,QWORD PTR [rsp+0x30]
    13b8:	add    rsp,0x40
    13bc:	mov    rsp,rbp
    13bf:	pop    rbp
    13c0:	ret
    13c1:	mov    r12,rdi
    13c4:	call   13c9 <botlish_fn_4+0x250>
			13c5: R_X86_64_PLT32	rt_stack_overflow-0x4
    13c9:	xor    rax,rax
    13cc:	mov    rbx,QWORD PTR [rsp+0x10]
    13d1:	mov    r12,QWORD PTR [rsp+0x18]
    13d6:	mov    r13,QWORD PTR [rsp+0x20]
    13db:	mov    r14,QWORD PTR [rsp+0x28]
    13e0:	mov    r15,QWORD PTR [rsp+0x30]
    13e5:	add    rsp,0x40
    13e9:	mov    rsp,rbp
    13ec:	pop    rbp
    13ed:	ret

00000000000013ee <botlish_entry_4: hex_pair<generic>>:
    13ee:	push   rbp
    13ef:	mov    rbp,rsp
    13f2:	mov    rdx,QWORD PTR [rdx]
    13f5:	call   13fa <botlish_entry_4+0xc>
			13f6: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    13fa:	mov    rsp,rbp
    13fd:	pop    rbp
    13fe:	ret
	...

0000000000001400 <botlish_fn_5: esc_bytes<generic>>:
    1400:	push   rbp
    1401:	mov    rbp,rsp
    1404:	sub    rsp,0x90
    140b:	mov    QWORD PTR [rsp+0x60],rbx
    1410:	mov    QWORD PTR [rsp+0x68],r12
    1415:	mov    QWORD PTR [rsp+0x70],r13
    141a:	mov    QWORD PTR [rsp+0x78],r14
    141f:	mov    QWORD PTR [rsp+0x80],r15
    1427:	mov    r15,rsi
    142a:	mov    r13,QWORD PTR [rdi]
    142d:	mov    r9,QWORD PTR [rdi+0x8]
    1431:	lea    r10,[r13+0x8]
    1435:	cmp    r10,r9
    1438:	ja     17a9 <botlish_fn_5+0x3a9>
    143e:	lea    r10,[r13+0x8]
    1442:	mov    QWORD PTR [rdi],r10
    1445:	mov    r14,rdi
    1448:	mov    QWORD PTR [r13+0x0],0x0
    1450:	mov    QWORD PTR [rsp+0x28],0x0
    1459:	mov    QWORD PTR [rsp+0x30],0x0
    1462:	mov    QWORD PTR [rsp],rdx
    1466:	mov    QWORD PTR [rsp+0x8],rcx
    146b:	mov    QWORD PTR [rsp+0x10],r8
    1470:	mov    QWORD PTR [rsp+0x38],rcx
    1475:	mov    QWORD PTR [rsp+0x40],r8
    147a:	xor    eax,eax
    147c:	test   rdx,0x7
    1483:	je     1491 <botlish_fn_5+0x91>
    1489:	mov    rsi,rdx
    148c:	jmp    149d <botlish_fn_5+0x9d>
    1491:	movzx  rax,BYTE PTR [rdx]
    1495:	mov    rsi,rdx
    1498:	cmp    al,0x3
    149a:	sete   al
    149d:	test   al,al
    149f:	jne    14c5 <botlish_fn_5+0xc5>
    14a5:	mov    rdi,r14
    14a8:	mov    rax,QWORD PTR [rdi+0x10]
    14ac:	mov    rcx,QWORD PTR [rax+0xb0]
    14b3:	mov    edx,0x4
    14b8:	call   14bd <botlish_fn_5+0xbd>
			14b9: R_X86_64_PLT32	rt_type_error-0x4
    14bd:	mov    rdi,r14
    14c0:	jmp    171d <botlish_fn_5+0x31d>
    14c5:	mov    rbx,rsi
    14c8:	mov    rdi,r14
    14cb:	call   14d0 <botlish_fn_5+0xd0>
			14cc: R_X86_64_PLT32	rt_list_len-0x4
    14d0:	mov    ecx,0x1
    14d5:	mov    rsi,QWORD PTR [rsp+0x38]
    14da:	test   rsi,0x1
    14e1:	jne    150b <botlish_fn_5+0x10b>
    14e7:	xor    ecx,ecx
    14e9:	mov    rsi,QWORD PTR [rsp+0x38]
    14ee:	test   rsi,0x7
    14f5:	jne    150b <botlish_fn_5+0x10b>
    14fb:	mov    rsi,QWORD PTR [rsp+0x38]
    1500:	movzx  rcx,BYTE PTR [rsi]
    1504:	rex cmp cl,0x1
    1508:	sete   cl
    150b:	test   cl,cl
    150d:	jne    1536 <botlish_fn_5+0x136>
    1513:	mov    rdi,r14
    1516:	mov    rax,QWORD PTR [rdi+0x10]
    151a:	mov    rcx,QWORD PTR [rax+0xb8]
    1521:	xor    rdx,rdx
    1524:	mov    rsi,QWORD PTR [rsp+0x38]
    1529:	call   152e <botlish_fn_5+0x12e>
			152a: R_X86_64_PLT32	rt_type_error-0x4
    152e:	mov    rdi,r14
    1531:	jmp    171d <botlish_fn_5+0x31d>
    1536:	mov    rsi,QWORD PTR [rsp+0x38]
    153b:	mov    rcx,rsi
    153e:	and    rcx,rax
    1541:	mov    rdx,rax
    1544:	test   rcx,0x1
    154b:	jne    1573 <botlish_fn_5+0x173>
    1551:	mov    rsi,QWORD PTR [rsp+0x38]
    1556:	mov    rdi,r14
    1559:	call   155e <botlish_fn_5+0x15e>
			155a: R_X86_64_PLT32	rt_int_cmp-0x4
    155e:	mov    esi,0x2
    1563:	test   rax,rax
    1566:	cmovge rsi,QWORD PTR [rip+0x272]        # 17e0 <botlish_fn_5+0x3e0>
    156e:	jmp    1588 <botlish_fn_5+0x188>
    1573:	mov    esi,0x2
    1578:	mov    rax,QWORD PTR [rsp+0x38]
    157d:	cmp    rax,rdx
    1580:	cmovge rsi,QWORD PTR [rip+0x258]        # 17e0 <botlish_fn_5+0x3e0>
    1588:	cmp    rsi,0x6
    158c:	je     1776 <botlish_fn_5+0x376>
    1592:	mov    r12,r15
    1595:	mov    QWORD PTR [rsp+0x18],r12
    159a:	mov    QWORD PTR [rsp+0x20],0x3
    15a3:	mov    rsi,QWORD PTR [rsp+0x38]
    15a8:	test   rsi,0x1
    15af:	je     15cc <botlish_fn_5+0x1cc>
    15b5:	mov    rsi,QWORD PTR [rsp+0x38]
    15ba:	mov    rax,rsi
    15bd:	add    rax,0x2
    15c1:	seto   cl
    15c4:	test   cl,cl
    15c6:	je     15de <botlish_fn_5+0x1de>
    15cc:	mov    edx,0x3
    15d1:	mov    rsi,QWORD PTR [rsp+0x38]
    15d6:	mov    rdi,r14
    15d9:	call   15de <botlish_fn_5+0x1de>
			15da: R_X86_64_PLT32	rt_int_add-0x4
    15de:	mov    QWORD PTR [rsp+0x8],rax
    15e3:	mov    rdi,r14
    15e6:	mov    QWORD PTR [rsp+0x48],rax
    15eb:	mov    rax,QWORD PTR [rdi+0x10]
    15ef:	mov    rsi,QWORD PTR [rax+0xc0]
    15f6:	mov    QWORD PTR [rsp+0x20],rsi
    15fb:	mov    r15,rsi
    15fe:	mov    rax,QWORD PTR [r12+0x20]
    1603:	mov    rsi,QWORD PTR [rax]
    1606:	mov    QWORD PTR [rsp+0x28],rsi
    160b:	mov    QWORD PTR [rsp+0x50],rsi
    1610:	mov    rsi,QWORD PTR [rsp+0x38]
    1615:	test   rsi,0x1
    161c:	jne    162c <botlish_fn_5+0x22c>
    1622:	mov    rdx,QWORD PTR [rsp+0x38]
    1627:	jmp    1649 <botlish_fn_5+0x249>
    162c:	mov    rcx,QWORD PTR [rbx+0x8]
    1630:	mov    rsi,QWORD PTR [rsp+0x38]
    1635:	mov    rax,rsi
    1638:	sar    rax,1
    163b:	cmp    rax,rcx
    163e:	jb     166d <botlish_fn_5+0x26d>
    1644:	mov    rdx,QWORD PTR [rsp+0x38]
    1649:	mov    rsi,rbx
    164c:	mov    rdi,r14
    164f:	call   1654 <botlish_fn_5+0x254>
			1650: R_X86_64_PLT32	rt_list_get-0x4
    1654:	test   rax,rax
    1657:	jne    1665 <botlish_fn_5+0x265>
    165d:	mov    rdi,r14
    1660:	jmp    171d <botlish_fn_5+0x31d>
    1665:	mov    rdx,rax
    1668:	jmp    1675 <botlish_fn_5+0x275>
    166d:	mov    rsi,QWORD PTR [rbx+0x10]
    1671:	mov    rdx,QWORD PTR [rsi+rax*8]
    1675:	mov    QWORD PTR [rsp+0x30],rdx
    167a:	mov    rsi,QWORD PTR [rsp+0x50]
    167f:	mov    rdi,r14
    1682:	call   1687 <botlish_fn_5+0x287>
			1683: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    1687:	test   rax,rax
    168a:	jne    1698 <botlish_fn_5+0x298>
    1690:	mov    rdi,r14
    1693:	jmp    171d <botlish_fn_5+0x31d>
    1698:	mov    QWORD PTR [rsp+0x28],rax
    169d:	mov    rdx,rax
    16a0:	mov    rsi,r15
    16a3:	mov    rdi,r14
    16a6:	call   16ab <botlish_fn_5+0x2ab>
			16a7: R_X86_64_PLT32	rt_str_cat-0x4
    16ab:	test   rax,rax
    16ae:	jne    16bc <botlish_fn_5+0x2bc>
    16b4:	mov    rdi,r14
    16b7:	jmp    171d <botlish_fn_5+0x31d>
    16bc:	mov    QWORD PTR [rsp+0x20],rax
    16c1:	mov    rdx,rax
    16c4:	xor    ecx,ecx
    16c6:	mov    rsi,QWORD PTR [rsp+0x40]
    16cb:	test   rsi,0x7
    16d2:	jne    16e1 <botlish_fn_5+0x2e1>
    16d8:	movzx  rax,BYTE PTR [rsi]
    16dc:	cmp    al,0x2
    16de:	sete   cl
    16e1:	test   cl,cl
    16e3:	jne    1709 <botlish_fn_5+0x309>
    16e9:	mov    rdi,r14
    16ec:	mov    rax,QWORD PTR [rdi+0x10]
    16f0:	mov    rcx,QWORD PTR [rax+0xc8]
    16f7:	mov    edx,0x1
    16fc:	call   1701 <botlish_fn_5+0x301>
			16fd: R_X86_64_PLT32	rt_type_error-0x4
    1701:	mov    rdi,r14
    1704:	jmp    171d <botlish_fn_5+0x31d>
    1709:	mov    rdi,r14
    170c:	call   1711 <botlish_fn_5+0x311>
			170d: R_X86_64_PLT32	rt_str_cat-0x4
    1711:	test   rax,rax
    1714:	jne    174e <botlish_fn_5+0x34e>
    171a:	mov    rdi,r14
    171d:	mov    rdi,r14
    1720:	mov    QWORD PTR [rdi],r13
    1723:	xor    rax,rax
    1726:	mov    rbx,QWORD PTR [rsp+0x60]
    172b:	mov    r12,QWORD PTR [rsp+0x68]
    1730:	mov    r13,QWORD PTR [rsp+0x70]
    1735:	mov    r14,QWORD PTR [rsp+0x78]
    173a:	mov    r15,QWORD PTR [rsp+0x80]
    1742:	add    rsp,0x90
    1749:	mov    rsp,rbp
    174c:	pop    rbp
    174d:	ret
    174e:	mov    QWORD PTR [rsp],rbx
    1752:	mov    rcx,QWORD PTR [rsp+0x48]
    1757:	mov    QWORD PTR [rsp+0x8],rcx
    175c:	mov    QWORD PTR [rsp+0x10],rax
    1761:	mov    rdx,rbx
    1764:	mov    r15,r12
    1767:	mov    QWORD PTR [rsp+0x38],rcx
    176c:	mov    QWORD PTR [rsp+0x40],rax
    1771:	jmp    147a <botlish_fn_5+0x7a>
    1776:	mov    rdi,r14
    1779:	mov    QWORD PTR [rdi],r13
    177c:	mov    rax,QWORD PTR [rsp+0x40]
    1781:	mov    rbx,QWORD PTR [rsp+0x60]
    1786:	mov    r12,QWORD PTR [rsp+0x68]
    178b:	mov    r13,QWORD PTR [rsp+0x70]
    1790:	mov    r14,QWORD PTR [rsp+0x78]
    1795:	mov    r15,QWORD PTR [rsp+0x80]
    179d:	add    rsp,0x90
    17a4:	mov    rsp,rbp
    17a7:	pop    rbp
    17a8:	ret
    17a9:	mov    r14,rdi
    17ac:	call   17b1 <botlish_fn_5+0x3b1>
			17ad: R_X86_64_PLT32	rt_stack_overflow-0x4
    17b1:	xor    rax,rax
    17b4:	mov    rbx,QWORD PTR [rsp+0x60]
    17b9:	mov    r12,QWORD PTR [rsp+0x68]
    17be:	mov    r13,QWORD PTR [rsp+0x70]
    17c3:	mov    r14,QWORD PTR [rsp+0x78]
    17c8:	mov    r15,QWORD PTR [rsp+0x80]
    17d0:	add    rsp,0x90
    17d7:	mov    rsp,rbp
    17da:	pop    rbp
    17db:	ret
    17dc:	add    BYTE PTR [rax],al
    17de:	add    BYTE PTR [rax],al
    17e0:	(bad)
    17e1:	add    BYTE PTR [rax],al
    17e3:	add    BYTE PTR [rax],al
    17e5:	add    BYTE PTR [rax],al
	...

00000000000017e8 <botlish_entry_5: esc_bytes<generic>>:
    17e8:	push   rbp
    17e9:	mov    rbp,rsp
    17ec:	mov    r9,QWORD PTR [rdx]
    17ef:	mov    rcx,QWORD PTR [rdx+0x8]
    17f3:	mov    r8,QWORD PTR [rdx+0x10]
    17f7:	mov    rdx,r9
    17fa:	call   17ff <botlish_entry_5+0x17>
			17fb: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    17ff:	mov    rsp,rbp
    1802:	pop    rbp
    1803:	ret

0000000000001804 <botlish_fn_6: esc_char<generic>>:
    1804:	push   rbp
    1805:	mov    rbp,rsp
    1808:	sub    rsp,0x60
    180c:	mov    QWORD PTR [rsp+0x30],rbx
    1811:	mov    QWORD PTR [rsp+0x38],r12
    1816:	mov    QWORD PTR [rsp+0x40],r13
    181b:	mov    QWORD PTR [rsp+0x48],r14
    1820:	mov    QWORD PTR [rsp+0x50],r15
    1825:	mov    rbx,rsi
    1828:	mov    r12,QWORD PTR [rdi]
    182b:	mov    rax,QWORD PTR [rdi+0x8]
    182f:	lea    rcx,[r12+0x8]
    1834:	cmp    rcx,rax
    1837:	ja     1a5d <botlish_fn_6+0x259>
    183d:	lea    rax,[r12+0x8]
    1842:	mov    QWORD PTR [rdi],rax
    1845:	mov    QWORD PTR [r12],0x0
    184d:	mov    QWORD PTR [rsp+0x8],0x0
    1856:	mov    QWORD PTR [rsp+0x10],0x0
    185f:	mov    QWORD PTR [rsp+0x18],0x0
    1868:	mov    QWORD PTR [rsp],rdx
    186c:	xor    eax,eax
    186e:	test   rdx,0x7
    1875:	je     1883 <botlish_fn_6+0x7f>
    187b:	mov    r14,rdx
    187e:	jmp    188f <botlish_fn_6+0x8b>
    1883:	movzx  rax,BYTE PTR [rdx]
    1887:	mov    r14,rdx
    188a:	cmp    al,0x2
    188c:	sete   al
    188f:	test   al,al
    1891:	jne    18ba <botlish_fn_6+0xb6>
    1897:	mov    rax,QWORD PTR [rdi+0x10]
    189b:	mov    r13,rdi
    189e:	mov    rcx,QWORD PTR [rax+0xd0]
    18a5:	mov    edx,0x1
    18aa:	mov    rsi,r14
    18ad:	call   18b2 <botlish_fn_6+0xae>
			18ae: R_X86_64_PLT32	rt_type_error-0x4
    18b2:	mov    rdi,r13
    18b5:	jmp    19ff <botlish_fn_6+0x1fb>
    18ba:	mov    r13,rdi
    18bd:	mov    rsi,r14
    18c0:	call   18c5 <botlish_fn_6+0xc1>
			18c1: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    18c5:	mov    rcx,rax
    18c8:	mov    r15,rax
    18cb:	test   rax,rcx
    18ce:	jne    18dc <botlish_fn_6+0xd8>
    18d4:	mov    rdi,r13
    18d7:	jmp    19ff <botlish_fn_6+0x1fb>
    18dc:	mov    rax,r15
    18df:	mov    QWORD PTR [rsp+0x8],rax
    18e4:	mov    rsi,r15
    18e7:	mov    rdi,r13
    18ea:	call   18ef <botlish_fn_6+0xeb>
			18eb: R_X86_64_PLT32	rt_list_len-0x4
    18ef:	mov    ecx,0x1
    18f4:	sar    rax,1
    18f7:	cmp    rax,0x1
    18fb:	je     194c <botlish_fn_6+0x148>
    1901:	mov    rsi,QWORD PTR [rbx+0x20]
    1905:	mov    rsi,QWORD PTR [rsi]
    1908:	mov    QWORD PTR [rsp],rsi
    190c:	mov    QWORD PTR [rsp+0x10],0x1
    1915:	mov    rdi,r13
    1918:	mov    rdi,QWORD PTR [rdi+0x10]
    191c:	mov    r8,QWORD PTR [rdi+0x98]
    1923:	mov    QWORD PTR [rsp+0x18],r8
    1928:	mov    rdx,r15
    192b:	mov    rdi,r13
    192e:	call   1933 <botlish_fn_6+0x12f>
			192f: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    1933:	test   rax,rax
    1936:	jne    1944 <botlish_fn_6+0x140>
    193c:	mov    rdi,r13
    193f:	jmp    19ff <botlish_fn_6+0x1fb>
    1944:	mov    rdi,r13
    1947:	jmp    1a35 <botlish_fn_6+0x231>
    194c:	mov    rdx,r15
    194f:	mov    QWORD PTR [rsp+0x20],rcx
    1954:	mov    r11,QWORD PTR [rdx+0x8]
    1958:	mov    r15,rdx
    195b:	test   r11,r11
    195e:	jne    198d <botlish_fn_6+0x189>
    1964:	mov    rdx,QWORD PTR [rsp+0x20]
    1969:	mov    rsi,r15
    196c:	mov    rdi,r13
    196f:	call   1974 <botlish_fn_6+0x170>
			1970: R_X86_64_PLT32	rt_list_get-0x4
    1974:	test   rax,rax
    1977:	jne    1985 <botlish_fn_6+0x181>
    197d:	mov    rdi,r13
    1980:	jmp    19ff <botlish_fn_6+0x1fb>
    1985:	mov    rsi,rax
    1988:	jmp    1997 <botlish_fn_6+0x193>
    198d:	mov    rdx,r15
    1990:	mov    rax,QWORD PTR [rdx+0x10]
    1994:	mov    rsi,QWORD PTR [rax]
    1997:	mov    QWORD PTR [rsp+0x10],rsi
    199c:	mov    rdi,r13
    199f:	call   19a4 <botlish_fn_6+0x1a0>
			19a0: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    19a4:	test   rax,rax
    19a7:	jne    19b5 <botlish_fn_6+0x1b1>
    19ad:	mov    rdi,r13
    19b0:	jmp    19ff <botlish_fn_6+0x1fb>
    19b5:	cmp    rax,0x6
    19b9:	je     1a2f <botlish_fn_6+0x22b>
    19bf:	mov    rax,QWORD PTR [rbx+0x20]
    19c3:	mov    rsi,QWORD PTR [rax]
    19c6:	mov    QWORD PTR [rsp],rsi
    19ca:	mov    QWORD PTR [rsp+0x10],0x1
    19d3:	mov    rdi,r13
    19d6:	mov    rax,QWORD PTR [rdi+0x10]
    19da:	mov    r8,QWORD PTR [rax+0x98]
    19e1:	mov    QWORD PTR [rsp+0x18],r8
    19e6:	mov    rcx,QWORD PTR [rsp+0x20]
    19eb:	mov    rdx,r15
    19ee:	call   19f3 <botlish_fn_6+0x1ef>
			19ef: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    19f3:	test   rax,rax
    19f6:	jne    1a32 <botlish_fn_6+0x22e>
    19fc:	mov    rdi,r13
    19ff:	mov    rdi,r13
    1a02:	mov    QWORD PTR [rdi],r12
    1a05:	xor    rax,rax
    1a08:	mov    rbx,QWORD PTR [rsp+0x30]
    1a0d:	mov    r12,QWORD PTR [rsp+0x38]
    1a12:	mov    r13,QWORD PTR [rsp+0x40]
    1a17:	mov    r14,QWORD PTR [rsp+0x48]
    1a1c:	mov    r15,QWORD PTR [rsp+0x50]
    1a21:	add    rsp,0x60
    1a25:	mov    rsp,rbp
    1a28:	pop    rbp
    1a29:	ret
    1a2a:	jmp    1a32 <botlish_fn_6+0x22e>
    1a2f:	mov    rax,r14
    1a32:	mov    rdi,r13
    1a35:	mov    rdi,r13
    1a38:	mov    QWORD PTR [rdi],r12
    1a3b:	mov    rbx,QWORD PTR [rsp+0x30]
    1a40:	mov    r12,QWORD PTR [rsp+0x38]
    1a45:	mov    r13,QWORD PTR [rsp+0x40]
    1a4a:	mov    r14,QWORD PTR [rsp+0x48]
    1a4f:	mov    r15,QWORD PTR [rsp+0x50]
    1a54:	add    rsp,0x60
    1a58:	mov    rsp,rbp
    1a5b:	pop    rbp
    1a5c:	ret
    1a5d:	mov    r13,rdi
    1a60:	call   1a65 <botlish_fn_6+0x261>
			1a61: R_X86_64_PLT32	rt_stack_overflow-0x4
    1a65:	xor    rax,rax
    1a68:	mov    rbx,QWORD PTR [rsp+0x30]
    1a6d:	mov    r12,QWORD PTR [rsp+0x38]
    1a72:	mov    r13,QWORD PTR [rsp+0x40]
    1a77:	mov    r14,QWORD PTR [rsp+0x48]
    1a7c:	mov    r15,QWORD PTR [rsp+0x50]
    1a81:	add    rsp,0x60
    1a85:	mov    rsp,rbp
    1a88:	pop    rbp
    1a89:	ret

0000000000001a8a <botlish_entry_6: esc_char<generic>>:
    1a8a:	push   rbp
    1a8b:	mov    rbp,rsp
    1a8e:	mov    rdx,QWORD PTR [rdx]
    1a91:	call   1a96 <botlish_entry_6+0xc>
			1a92: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    1a96:	mov    rsp,rbp
    1a99:	pop    rbp
    1a9a:	ret
    1a9b:	add    BYTE PTR [rax],al
    1a9d:	add    BYTE PTR [rax],al
	...

0000000000001aa0 <botlish_fn_7: esc_from<generic>>:
    1aa0:	push   rbp
    1aa1:	mov    rbp,rsp
    1aa4:	sub    rsp,0x90
    1aab:	mov    QWORD PTR [rsp+0x60],rbx
    1ab0:	mov    QWORD PTR [rsp+0x68],r12
    1ab5:	mov    QWORD PTR [rsp+0x70],r13
    1aba:	mov    QWORD PTR [rsp+0x78],r14
    1abf:	mov    QWORD PTR [rsp+0x80],r15
    1ac7:	mov    r12,rsi
    1aca:	mov    r13,QWORD PTR [rdi]
    1acd:	mov    rax,QWORD PTR [rdi+0x8]
    1ad1:	lea    rsi,[r13+0x8]
    1ad5:	cmp    rsi,rax
    1ad8:	ja     1e69 <botlish_fn_7+0x3c9>
    1ade:	lea    rax,[r13+0x8]
    1ae2:	mov    QWORD PTR [rdi],rax
    1ae5:	mov    r14,rdi
    1ae8:	mov    QWORD PTR [r13+0x0],0x0
    1af0:	mov    QWORD PTR [rsp+0x28],0x0
    1af9:	mov    QWORD PTR [rsp+0x30],0x0
    1b02:	mov    QWORD PTR [rsp],rdx
    1b06:	mov    QWORD PTR [rsp+0x8],rcx
    1b0b:	mov    QWORD PTR [rsp+0x10],r8
    1b10:	mov    r15,r8
    1b13:	mov    QWORD PTR [rsp+0x38],rcx
    1b18:	xor    eax,eax
    1b1a:	test   rdx,0x7
    1b21:	je     1b2f <botlish_fn_7+0x8f>
    1b27:	mov    rsi,rdx
    1b2a:	jmp    1b3b <botlish_fn_7+0x9b>
    1b2f:	movzx  rax,BYTE PTR [rdx]
    1b33:	mov    rsi,rdx
    1b36:	cmp    al,0x2
    1b38:	sete   al
    1b3b:	test   al,al
    1b3d:	jne    1b63 <botlish_fn_7+0xc3>
    1b43:	mov    rdi,r14
    1b46:	mov    rax,QWORD PTR [rdi+0x10]
    1b4a:	mov    rcx,QWORD PTR [rax+0xd8]
    1b51:	mov    edx,0x1
    1b56:	call   1b5b <botlish_fn_7+0xbb>
			1b57: R_X86_64_PLT32	rt_type_error-0x4
    1b5b:	mov    rdi,r14
    1b5e:	jmp    1de4 <botlish_fn_7+0x344>
    1b63:	mov    rbx,rsi
    1b66:	mov    rdi,r14
    1b69:	call   1b6e <botlish_fn_7+0xce>
			1b6a: R_X86_64_PLT32	rt_str_len-0x4
    1b6e:	mov    edx,0x1
    1b73:	mov    QWORD PTR [rsp+0x50],rdx
    1b78:	mov    ecx,0x1
    1b7d:	mov    rsi,QWORD PTR [rsp+0x38]
    1b82:	test   rsi,0x1
    1b89:	jne    1bb3 <botlish_fn_7+0x113>
    1b8f:	xor    ecx,ecx
    1b91:	mov    rsi,QWORD PTR [rsp+0x38]
    1b96:	test   rsi,0x7
    1b9d:	jne    1bb3 <botlish_fn_7+0x113>
    1ba3:	mov    rsi,QWORD PTR [rsp+0x38]
    1ba8:	movzx  rcx,BYTE PTR [rsi]
    1bac:	rex cmp cl,0x1
    1bb0:	sete   cl
    1bb3:	test   cl,cl
    1bb5:	jne    1bde <botlish_fn_7+0x13e>
    1bbb:	mov    rdi,r14
    1bbe:	mov    rax,QWORD PTR [rdi+0x10]
    1bc2:	mov    rcx,QWORD PTR [rax+0xb8]
    1bc9:	xor    rdx,rdx
    1bcc:	mov    rsi,QWORD PTR [rsp+0x38]
    1bd1:	call   1bd6 <botlish_fn_7+0x136>
			1bd2: R_X86_64_PLT32	rt_type_error-0x4
    1bd6:	mov    rdi,r14
    1bd9:	jmp    1de4 <botlish_fn_7+0x344>
    1bde:	mov    rsi,QWORD PTR [rsp+0x38]
    1be3:	mov    rcx,rsi
    1be6:	and    rcx,rax
    1be9:	mov    rdx,rax
    1bec:	test   rcx,0x1
    1bf3:	jne    1c1b <botlish_fn_7+0x17b>
    1bf9:	mov    rsi,QWORD PTR [rsp+0x38]
    1bfe:	mov    rdi,r14
    1c01:	call   1c06 <botlish_fn_7+0x166>
			1c02: R_X86_64_PLT32	rt_int_cmp-0x4
    1c06:	mov    esi,0x2
    1c0b:	test   rax,rax
    1c0e:	cmovge rsi,QWORD PTR [rip+0x28a]        # 1ea0 <botlish_fn_7+0x400>
    1c16:	jmp    1c30 <botlish_fn_7+0x190>
    1c1b:	mov    esi,0x2
    1c20:	mov    rax,QWORD PTR [rsp+0x38]
    1c25:	cmp    rax,rdx
    1c28:	cmovge rsi,QWORD PTR [rip+0x270]        # 1ea0 <botlish_fn_7+0x400>
    1c30:	cmp    rsi,0x6
    1c34:	je     1e38 <botlish_fn_7+0x398>
    1c3a:	mov    QWORD PTR [rsp+0x18],r12
    1c3f:	mov    QWORD PTR [rsp+0x20],0x3
    1c48:	mov    rsi,QWORD PTR [rsp+0x38]
    1c4d:	test   rsi,0x1
    1c54:	je     1c71 <botlish_fn_7+0x1d1>
    1c5a:	mov    rsi,QWORD PTR [rsp+0x38]
    1c5f:	mov    rax,rsi
    1c62:	add    rax,0x2
    1c66:	seto   cl
    1c69:	test   cl,cl
    1c6b:	je     1c83 <botlish_fn_7+0x1e3>
    1c71:	mov    edx,0x3
    1c76:	mov    rsi,QWORD PTR [rsp+0x38]
    1c7b:	mov    rdi,r14
    1c7e:	call   1c83 <botlish_fn_7+0x1e3>
			1c7f: R_X86_64_PLT32	rt_int_add-0x4
    1c83:	mov    QWORD PTR [rsp+0x20],rax
    1c88:	mov    QWORD PTR [rsp+0x40],rax
    1c8d:	mov    rax,QWORD PTR [r12+0x20]
    1c92:	mov    rsi,QWORD PTR [rax]
    1c95:	mov    QWORD PTR [rsp+0x28],rsi
    1c9a:	mov    QWORD PTR [rsp+0x48],rsi
    1c9f:	mov    QWORD PTR [rsp+0x30],0x3
    1ca8:	mov    rsi,QWORD PTR [rsp+0x38]
    1cad:	test   rsi,0x1
    1cb4:	je     1cd3 <botlish_fn_7+0x233>
    1cba:	mov    rsi,QWORD PTR [rsp+0x38]
    1cbf:	mov    rcx,rsi
    1cc2:	add    rcx,0x2
    1cc6:	seto   sil
    1cca:	test   sil,sil
    1ccd:	je     1ce8 <botlish_fn_7+0x248>
    1cd3:	mov    edx,0x3
    1cd8:	mov    rsi,QWORD PTR [rsp+0x38]
    1cdd:	mov    rdi,r14
    1ce0:	call   1ce5 <botlish_fn_7+0x245>
			1ce1: R_X86_64_PLT32	rt_int_add-0x4
    1ce5:	mov    rcx,rax
    1ce8:	mov    QWORD PTR [rsp+0x30],rcx
    1ced:	mov    rdx,QWORD PTR [rsp+0x38]
    1cf2:	mov    rsi,rbx
    1cf5:	mov    rdi,r14
    1cf8:	call   1cfd <botlish_fn_7+0x25d>
			1cf9: R_X86_64_PLT32	rt_substr-0x4
    1cfd:	test   rax,rax
    1d00:	jne    1d0e <botlish_fn_7+0x26e>
    1d06:	mov    rdi,r14
    1d09:	jmp    1de4 <botlish_fn_7+0x344>
    1d0e:	mov    QWORD PTR [rsp+0x8],rax
    1d13:	mov    rdx,rax
    1d16:	mov    rsi,QWORD PTR [rsp+0x48]
    1d1b:	mov    rdi,r14
    1d1e:	call   1d23 <botlish_fn_7+0x283>
			1d1f: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    1d23:	test   rax,rax
    1d26:	jne    1d34 <botlish_fn_7+0x294>
    1d2c:	mov    rdi,r14
    1d2f:	jmp    1de4 <botlish_fn_7+0x344>
    1d34:	mov    QWORD PTR [rsp+0x8],rax
    1d39:	xor    ecx,ecx
    1d3b:	mov    rsi,r15
    1d3e:	test   rsi,0x7
    1d45:	jne    1d56 <botlish_fn_7+0x2b6>
    1d4b:	movzx  rcx,BYTE PTR [rsi]
    1d4f:	rex cmp cl,0x2
    1d53:	sete   cl
    1d56:	test   cl,cl
    1d58:	jne    1d7e <botlish_fn_7+0x2de>
    1d5e:	mov    rdi,r14
    1d61:	mov    rax,QWORD PTR [rdi+0x10]
    1d65:	mov    rcx,QWORD PTR [rax+0xc8]
    1d6c:	mov    rdx,QWORD PTR [rsp+0x50]
    1d71:	call   1d76 <botlish_fn_7+0x2d6>
			1d72: R_X86_64_PLT32	rt_type_error-0x4
    1d76:	mov    rdi,r14
    1d79:	jmp    1de4 <botlish_fn_7+0x344>
    1d7e:	mov    rdx,QWORD PTR [rsp+0x50]
    1d83:	xor    ecx,ecx
    1d85:	test   rax,0x7
    1d8b:	je     1d99 <botlish_fn_7+0x2f9>
    1d91:	mov    r8,rax
    1d94:	jmp    1da7 <botlish_fn_7+0x307>
    1d99:	movzx  rcx,BYTE PTR [rax]
    1d9d:	mov    r8,rax
    1da0:	rex cmp cl,0x2
    1da4:	sete   cl
    1da7:	test   cl,cl
    1da9:	jne    1dcd <botlish_fn_7+0x32d>
    1daf:	mov    rdi,r14
    1db2:	mov    rax,QWORD PTR [rdi+0x10]
    1db6:	mov    rcx,QWORD PTR [rax+0xc8]
    1dbd:	mov    rsi,r8
    1dc0:	call   1dc5 <botlish_fn_7+0x325>
			1dc1: R_X86_64_PLT32	rt_type_error-0x4
    1dc5:	mov    rdi,r14
    1dc8:	jmp    1de4 <botlish_fn_7+0x344>
    1dcd:	mov    rdx,r8
    1dd0:	mov    rdi,r14
    1dd3:	call   1dd8 <botlish_fn_7+0x338>
			1dd4: R_X86_64_PLT32	rt_str_cat-0x4
    1dd8:	test   rax,rax
    1ddb:	jne    1e15 <botlish_fn_7+0x375>
    1de1:	mov    rdi,r14
    1de4:	mov    rdi,r14
    1de7:	mov    QWORD PTR [rdi],r13
    1dea:	xor    rax,rax
    1ded:	mov    rbx,QWORD PTR [rsp+0x60]
    1df2:	mov    r12,QWORD PTR [rsp+0x68]
    1df7:	mov    r13,QWORD PTR [rsp+0x70]
    1dfc:	mov    r14,QWORD PTR [rsp+0x78]
    1e01:	mov    r15,QWORD PTR [rsp+0x80]
    1e09:	add    rsp,0x90
    1e10:	mov    rsp,rbp
    1e13:	pop    rbp
    1e14:	ret
    1e15:	mov    QWORD PTR [rsp],rbx
    1e19:	mov    r9,QWORD PTR [rsp+0x40]
    1e1e:	mov    QWORD PTR [rsp+0x8],r9
    1e23:	mov    QWORD PTR [rsp+0x10],rax
    1e28:	mov    rdx,rbx
    1e2b:	mov    r15,rax
    1e2e:	mov    QWORD PTR [rsp+0x38],r9
    1e33:	jmp    1b18 <botlish_fn_7+0x78>
    1e38:	mov    rdi,r14
    1e3b:	mov    QWORD PTR [rdi],r13
    1e3e:	mov    rax,r15
    1e41:	mov    rbx,QWORD PTR [rsp+0x60]
    1e46:	mov    r12,QWORD PTR [rsp+0x68]
    1e4b:	mov    r13,QWORD PTR [rsp+0x70]
    1e50:	mov    r14,QWORD PTR [rsp+0x78]
    1e55:	mov    r15,QWORD PTR [rsp+0x80]
    1e5d:	add    rsp,0x90
    1e64:	mov    rsp,rbp
    1e67:	pop    rbp
    1e68:	ret
    1e69:	mov    r14,rdi
    1e6c:	call   1e71 <botlish_fn_7+0x3d1>
			1e6d: R_X86_64_PLT32	rt_stack_overflow-0x4
    1e71:	xor    rax,rax
    1e74:	mov    rbx,QWORD PTR [rsp+0x60]
    1e79:	mov    r12,QWORD PTR [rsp+0x68]
    1e7e:	mov    r13,QWORD PTR [rsp+0x70]
    1e83:	mov    r14,QWORD PTR [rsp+0x78]
    1e88:	mov    r15,QWORD PTR [rsp+0x80]
    1e90:	add    rsp,0x90
    1e97:	mov    rsp,rbp
    1e9a:	pop    rbp
    1e9b:	ret
    1e9c:	add    BYTE PTR [rax],al
    1e9e:	add    BYTE PTR [rax],al
    1ea0:	(bad)
    1ea1:	add    BYTE PTR [rax],al
    1ea3:	add    BYTE PTR [rax],al
    1ea5:	add    BYTE PTR [rax],al
	...

0000000000001ea8 <botlish_entry_7: esc_from<generic>>:
    1ea8:	push   rbp
    1ea9:	mov    rbp,rsp
    1eac:	mov    r9,QWORD PTR [rdx]
    1eaf:	mov    rcx,QWORD PTR [rdx+0x8]
    1eb3:	mov    r8,QWORD PTR [rdx+0x10]
    1eb7:	mov    rdx,r9
    1eba:	call   1ebf <botlish_entry_7+0x17>
			1ebb: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
    1ebf:	mov    rsp,rbp
    1ec2:	pop    rbp
    1ec3:	ret
    1ec4:	add    BYTE PTR [rax],al
	...

0000000000001ec8 <botlish_fn_8: check<int, int, str, str>>:
    1ec8:	push   rbp
    1ec9:	mov    rbp,rsp
    1ecc:	sub    rsp,0x60
    1ed0:	mov    QWORD PTR [rsp+0x30],rbx
    1ed5:	mov    QWORD PTR [rsp+0x38],r12
    1eda:	mov    QWORD PTR [rsp+0x40],r13
    1edf:	mov    QWORD PTR [rsp+0x48],r14
    1ee4:	mov    QWORD PTR [rsp+0x50],r15
    1ee9:	mov    r13,QWORD PTR [rdi]
    1eec:	mov    rax,QWORD PTR [rdi+0x8]
    1ef0:	lea    r9,[r13+0x8]
    1ef4:	cmp    r9,rax
    1ef7:	ja     20c7 <botlish_fn_8+0x1ff>
    1efd:	lea    rax,[r13+0x8]
    1f01:	mov    QWORD PTR [rdi],rax
    1f04:	mov    r14,rdi
    1f07:	mov    QWORD PTR [r13+0x0],0x0
    1f0f:	mov    QWORD PTR [rsp+0x20],0x0
    1f18:	mov    QWORD PTR [rsp],rsi
    1f1c:	mov    QWORD PTR [rsp+0x8],rdx
    1f21:	mov    QWORD PTR [rsp+0x10],rcx
    1f26:	mov    r12,rcx
    1f29:	mov    QWORD PTR [rsp+0x18],r8
    1f2e:	mov    r15,r8
    1f31:	mov    rbx,rsi
    1f34:	mov    QWORD PTR [rsp+0x28],rdx
    1f39:	test   rbx,0x1
    1f40:	jne    1f6b <botlish_fn_8+0xa3>
    1f46:	mov    edx,0x1
    1f4b:	mov    rsi,rbx
    1f4e:	mov    rdi,r14
    1f51:	call   1f56 <botlish_fn_8+0x8e>
			1f52: R_X86_64_PLT32	rt_int_cmp-0x4
    1f56:	mov    ecx,0x2
    1f5b:	test   rax,rax
    1f5e:	cmovle rcx,QWORD PTR [rip+0x192]        # 20f8 <botlish_fn_8+0x230>
    1f66:	jmp    1f7c <botlish_fn_8+0xb4>
    1f6b:	mov    ecx,0x2
    1f70:	cmp    rbx,0x1
    1f74:	cmovle rcx,QWORD PTR [rip+0x17c]        # 20f8 <botlish_fn_8+0x230>
    1f7c:	cmp    rcx,0x6
    1f80:	je     209a <botlish_fn_8+0x1d2>
    1f86:	mov    rdi,r14
    1f89:	mov    rax,QWORD PTR [rdi+0x10]
    1f8d:	mov    rax,QWORD PTR [rax+0xe0]
    1f94:	mov    rsi,r12
    1f97:	call   1f9c <botlish_fn_8+0xd4>
			1f98: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    1f9c:	test   rax,rax
    1f9f:	jne    1fad <botlish_fn_8+0xe5>
    1fa5:	mov    rdi,r14
    1fa8:	jmp    1feb <botlish_fn_8+0x123>
    1fad:	cmp    rax,0x6
    1fb1:	je     1fc9 <botlish_fn_8+0x101>
    1fb7:	mov    edx,0x1
    1fbc:	mov    QWORD PTR [rsp],0x1
    1fc4:	jmp    2033 <botlish_fn_8+0x16b>
    1fc9:	mov    rdi,r14
    1fcc:	mov    rsi,QWORD PTR [rdi+0x10]
    1fd0:	mov    rsi,QWORD PTR [rsi+0xe8]
    1fd7:	mov    rsi,r12
    1fda:	call   1fdf <botlish_fn_8+0x117>
			1fdb: R_X86_64_PLT32	botlish_fn_20-0x4 ; <str>
    1fdf:	test   rax,rax
    1fe2:	jne    2016 <botlish_fn_8+0x14e>
    1fe8:	mov    rdi,r14
    1feb:	mov    rdi,r14
    1fee:	mov    QWORD PTR [rdi],r13
    1ff1:	xor    rax,rax
    1ff4:	mov    rbx,QWORD PTR [rsp+0x30]
    1ff9:	mov    r12,QWORD PTR [rsp+0x38]
    1ffe:	mov    r13,QWORD PTR [rsp+0x40]
    2003:	mov    r14,QWORD PTR [rsp+0x48]
    2008:	mov    r15,QWORD PTR [rsp+0x50]
    200d:	add    rsp,0x60
    2011:	mov    rsp,rbp
    2014:	pop    rbp
    2015:	ret
    2016:	cmp    rax,0x6
    201a:	je     202a <botlish_fn_8+0x162>
    2020:	mov    edx,0x1
    2025:	jmp    202f <botlish_fn_8+0x167>
    202a:	mov    edx,0x3
    202f:	mov    QWORD PTR [rsp],rdx
    2033:	sar    rbx,1
    2036:	sub    rbx,0x1
    203a:	shl    rbx,1
    203d:	or     rbx,0x1
    2041:	mov    QWORD PTR [rsp+0x20],rbx
    2046:	mov    rsi,QWORD PTR [rsp+0x28]
    204b:	mov    rax,rsi
    204e:	and    rax,rdx
    2051:	test   rax,0x1
    2057:	je     2072 <botlish_fn_8+0x1aa>
    205d:	lea    rcx,[rdx-0x1]
    2061:	mov    rax,rsi
    2064:	add    rax,rcx
    2067:	seto   cl
    206a:	test   cl,cl
    206c:	je     207a <botlish_fn_8+0x1b2>
    2072:	mov    rdi,r14
    2075:	call   207a <botlish_fn_8+0x1b2>
			2076: R_X86_64_PLT32	rt_int_add-0x4
    207a:	mov    QWORD PTR [rsp],rbx
    207e:	mov    QWORD PTR [rsp+0x8],rax
    2083:	mov    QWORD PTR [rsp+0x10],r12
    2088:	mov    r8,r15
    208b:	mov    QWORD PTR [rsp+0x18],r8
    2090:	mov    QWORD PTR [rsp+0x28],rax
    2095:	jmp    1f39 <botlish_fn_8+0x71>
    209a:	mov    rdi,r14
    209d:	mov    QWORD PTR [rdi],r13
    20a0:	mov    rax,QWORD PTR [rsp+0x28]
    20a5:	mov    rbx,QWORD PTR [rsp+0x30]
    20aa:	mov    r12,QWORD PTR [rsp+0x38]
    20af:	mov    r13,QWORD PTR [rsp+0x40]
    20b4:	mov    r14,QWORD PTR [rsp+0x48]
    20b9:	mov    r15,QWORD PTR [rsp+0x50]
    20be:	add    rsp,0x60
    20c2:	mov    rsp,rbp
    20c5:	pop    rbp
    20c6:	ret
    20c7:	mov    r14,rdi
    20ca:	call   20cf <botlish_fn_8+0x207>
			20cb: R_X86_64_PLT32	rt_stack_overflow-0x4
    20cf:	xor    rax,rax
    20d2:	mov    rbx,QWORD PTR [rsp+0x30]
    20d7:	mov    r12,QWORD PTR [rsp+0x38]
    20dc:	mov    r13,QWORD PTR [rsp+0x40]
    20e1:	mov    r14,QWORD PTR [rsp+0x48]
    20e6:	mov    r15,QWORD PTR [rsp+0x50]
    20eb:	add    rsp,0x60
    20ef:	mov    rsp,rbp
    20f2:	pop    rbp
    20f3:	ret
    20f4:	add    BYTE PTR [rax],al
    20f6:	add    BYTE PTR [rax],al
    20f8:	(bad)
    20f9:	add    BYTE PTR [rax],al
    20fb:	add    BYTE PTR [rax],al
    20fd:	add    BYTE PTR [rax],al
	...

0000000000002100 <botlish_entry_8: check<int, int, str, str>>:
    2100:	push   rbp
    2101:	mov    rbp,rsp
    2104:	mov    rsi,QWORD PTR [rdx]
    2107:	mov    r9,QWORD PTR [rdx+0x8]
    210b:	mov    rcx,QWORD PTR [rdx+0x10]
    210f:	mov    r8,QWORD PTR [rdx+0x18]
    2113:	mov    rdx,r9
    2116:	call   211b <botlish_entry_8+0x1b>
			2117: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
    211b:	mov    rsp,rbp
    211e:	pop    rbp
    211f:	ret

0000000000002120 <botlish_fn_9: <str>>:
    2120:	push   rbp
    2121:	mov    rbp,rsp
    2124:	sub    rsp,0xf0
    212b:	mov    QWORD PTR [rsp+0xc0],rbx
    2133:	mov    QWORD PTR [rsp+0xc8],r12
    213b:	mov    QWORD PTR [rsp+0xd0],r13
    2143:	mov    QWORD PTR [rsp+0xd8],r14
    214b:	mov    QWORD PTR [rsp+0xe0],r15
    2153:	mov    rbx,QWORD PTR [rdi]
    2156:	mov    rax,QWORD PTR [rdi+0x8]
    215a:	lea    rcx,[rbx+0x8]
    215e:	cmp    rcx,rax
    2161:	ja     2611 <botlish_fn_9+0x4f1>
    2167:	lea    rax,[rbx+0x8]
    216b:	mov    QWORD PTR [rdi],rax
    216e:	mov    QWORD PTR [rsp+0xa0],rdi
    2176:	mov    QWORD PTR [rbx],0x0
    217d:	mov    QWORD PTR [rsp+0x10],0x0
    2186:	mov    QWORD PTR [rsp+0x18],0x0
    218f:	mov    QWORD PTR [rsp+0x20],0x0
    2198:	mov    QWORD PTR [rsp],rsi
    219c:	mov    r12,rsi
    219f:	mov    rsi,r12
    21a2:	mov    rdi,QWORD PTR [rsp+0xa0]
    21aa:	call   21af <botlish_fn_9+0x8f>
			21ab: R_X86_64_PLT32	rt_str_len-0x4
    21af:	mov    QWORD PTR [rsp+0xb0],rax
    21b7:	mov    QWORD PTR [rsp+0x8],rax
    21bc:	lea    r8,[rsp+0x28]
    21c1:	mov    QWORD PTR [rsp+0x28],r12
    21c6:	mov    esi,0xb
    21cb:	mov    rdx,QWORD PTR [rip+0x0]        # 21d2 <botlish_fn_9+0xb2>
			21ce: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    21d2:	mov    r12d,0x1
    21d8:	mov    rcx,r12
    21db:	mov    rdi,QWORD PTR [rsp+0xa0]
    21e3:	call   21e8 <botlish_fn_9+0xc8>
			21e4: R_X86_64_PLT32	rt_closure_new-0x4
    21e8:	mov    r15,rax
    21eb:	mov    QWORD PTR [rsp],rax
    21ef:	lea    r8,[rsp+0x30]
    21f4:	mov    rax,QWORD PTR [rsp+0xb0]
    21fc:	mov    QWORD PTR [rsp+0x30],rax
    2201:	mov    rax,r15
    2204:	mov    QWORD PTR [rsp+0x38],rax
    2209:	mov    esi,0xf
    220e:	mov    rdx,QWORD PTR [rip+0x0]        # 2215 <botlish_fn_9+0xf5>
			2211: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_local<generic>
    2215:	mov    r14d,0x2
    221b:	mov    rcx,r14
    221e:	mov    rdi,QWORD PTR [rsp+0xa0]
    2226:	call   222b <botlish_fn_9+0x10b>
			2227: R_X86_64_PLT32	rt_closure_new-0x4
    222b:	mov    r13,rax
    222e:	mov    QWORD PTR [rsp+0x10],r13
    2233:	lea    r8,[rsp+0x40]
    2238:	mov    rax,QWORD PTR [rsp+0xb0]
    2240:	mov    QWORD PTR [rsp+0x40],rax
    2245:	mov    rax,r15
    2248:	mov    QWORD PTR [rsp+0x48],rax
    224d:	mov    esi,0x10
    2252:	mov    rdx,QWORD PTR [rip+0x0]        # 2259 <botlish_fn_9+0x139>
			2255: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; scan_label<generic>
    2259:	mov    rcx,r14
    225c:	mov    rdi,QWORD PTR [rsp+0xa0]
    2264:	call   2269 <botlish_fn_9+0x149>
			2265: R_X86_64_PLT32	rt_closure_new-0x4
    2269:	mov    QWORD PTR [rsp+0x18],rax
    226e:	mov    QWORD PTR [rsp+0xa8],rax
    2276:	lea    r8,[rsp+0x50]
    227b:	mov    rax,QWORD PTR [rsp+0xb0]
    2283:	mov    QWORD PTR [rsp+0x50],rax
    2288:	mov    QWORD PTR [rsp+0x58],r15
    228d:	mov    esi,0x11
    2292:	mov    rdx,QWORD PTR [rip+0x0]        # 2299 <botlish_fn_9+0x179>
			2295: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; scan_alpha<generic>
    2299:	mov    rcx,r14
    229c:	mov    rdi,QWORD PTR [rsp+0xa0]
    22a4:	call   22a9 <botlish_fn_9+0x189>
			22a5: R_X86_64_PLT32	rt_closure_new-0x4
    22a9:	mov    QWORD PTR [rsp+0x20],rax
    22ae:	lea    r8,[rsp+0x60]
    22b3:	mov    QWORD PTR [rsp+0x60],rax
    22b8:	mov    rax,QWORD PTR [rsp+0xb0]
    22c0:	mov    QWORD PTR [rsp+0x68],rax
    22c5:	mov    esi,0x12
    22ca:	mov    rdx,QWORD PTR [rip+0x0]        # 22d1 <botlish_fn_9+0x1b1>
			22cd: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; tld_ok<generic>
    22d1:	mov    rcx,r14
    22d4:	mov    rdi,QWORD PTR [rsp+0xa0]
    22dc:	call   22e1 <botlish_fn_9+0x1c1>
			22dd: R_X86_64_PLT32	rt_closure_new-0x4
    22e1:	mov    QWORD PTR [rsp+0x20],rax
    22e6:	lea    r8,[rsp+0x70]
    22eb:	mov    rcx,QWORD PTR [rsp+0xa8]
    22f3:	mov    QWORD PTR [rsp+0x70],rcx
    22f8:	mov    rcx,QWORD PTR [rsp+0xb0]
    2300:	mov    QWORD PTR [rsp+0x78],rcx
    2305:	mov    QWORD PTR [rsp+0x80],r15
    230d:	mov    QWORD PTR [rsp+0x88],rax
    2315:	mov    esi,0x13
    231a:	mov    rdx,QWORD PTR [rip+0x0]        # 2321 <botlish_fn_9+0x201>
			231d: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; domain_loop<generic>
    2321:	mov    ecx,0x4
    2326:	mov    rdi,QWORD PTR [rsp+0xa0]
    232e:	call   2333 <botlish_fn_9+0x213>
			232f: R_X86_64_PLT32	rt_closure_new-0x4
    2333:	mov    QWORD PTR [rsp+0x18],rax
    2338:	mov    r14,rax
    233b:	mov    QWORD PTR [rsp+0x20],0x1
    2344:	mov    rdx,r12
    2347:	mov    rsi,r13
    234a:	mov    rdi,QWORD PTR [rsp+0xa0]
    2352:	call   2357 <botlish_fn_9+0x237>
			2353: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    2357:	mov    rcx,rax
    235a:	mov    r13,rax
    235d:	test   rax,rcx
    2360:	jne    2373 <botlish_fn_9+0x253>
    2366:	mov    rdi,QWORD PTR [rsp+0xa0]
    236e:	jmp    2509 <botlish_fn_9+0x3e9>
    2373:	mov    rax,r13
    2376:	mov    QWORD PTR [rsp+0x10],rax
    237b:	test   rax,0x1
    2381:	jne    23b2 <botlish_fn_9+0x292>
    2387:	mov    edx,0x1
    238c:	mov    rsi,r13
    238f:	mov    rdi,QWORD PTR [rsp+0xa0]
    2397:	call   239c <botlish_fn_9+0x27c>
			2398: R_X86_64_PLT32	rt_int_cmp-0x4
    239c:	mov    r11d,0x2
    23a2:	test   rax,rax
    23a5:	cmove  r11,QWORD PTR [rip+0x2ab]        # 2658 <botlish_fn_9+0x538>
    23ad:	jmp    23c4 <botlish_fn_9+0x2a4>
    23b2:	mov    r11d,0x2
    23b8:	cmp    r13,0x1
    23bc:	cmove  r11,QWORD PTR [rip+0x294]        # 2658 <botlish_fn_9+0x538>
    23c4:	cmp    r11,0x6
    23c8:	je     25c5 <botlish_fn_9+0x4a5>
    23ce:	mov    r12,QWORD PTR [rsp+0xb0]
    23d6:	mov    rax,r13
    23d9:	and    rax,r12
    23dc:	test   rax,0x1
    23e2:	jne    2410 <botlish_fn_9+0x2f0>
    23e8:	mov    rdx,r12
    23eb:	mov    rsi,r13
    23ee:	mov    rdi,QWORD PTR [rsp+0xa0]
    23f6:	call   23fb <botlish_fn_9+0x2db>
			23f7: R_X86_64_PLT32	rt_int_cmp-0x4
    23fb:	mov    ecx,0x2
    2400:	test   rax,rax
    2403:	cmovge rcx,QWORD PTR [rip+0x24d]        # 2658 <botlish_fn_9+0x538>
    240b:	jmp    2420 <botlish_fn_9+0x300>
    2410:	mov    ecx,0x2
    2415:	cmp    r13,r12
    2418:	cmovge rcx,QWORD PTR [rip+0x238]        # 2658 <botlish_fn_9+0x538>
    2420:	cmp    rcx,0x6
    2424:	je     25b3 <botlish_fn_9+0x493>
    242a:	lea    rcx,[rsp+0x90]
    2432:	mov    rsi,r15
    2435:	mov    rdx,r13
    2438:	mov    rdi,QWORD PTR [rsp+0xa0]
    2440:	call   2445 <botlish_fn_9+0x325>
			2441: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    2445:	test   rax,rax
    2448:	mov    rsi,rax
    244b:	jne    245e <botlish_fn_9+0x33e>
    2451:	mov    rdi,QWORD PTR [rsp+0xa0]
    2459:	jmp    2509 <botlish_fn_9+0x3e9>
    245e:	mov    rdx,QWORD PTR [rsp+0x90]
    2466:	mov    rcx,QWORD PTR [rsp+0x98]
    246e:	mov    rdi,QWORD PTR [rsp+0xa0]
    2476:	mov    rdi,QWORD PTR [rdi+0x10]
    247a:	mov    r8,QWORD PTR [rdi+0x100]
    2481:	mov    rdi,QWORD PTR [rsp+0xa0]
    2489:	call   248e <botlish_fn_9+0x36e>
			248a: R_X86_64_PLT32	rt_str_region_eq-0x4
    248e:	cmp    rax,0x6
    2492:	je     24a5 <botlish_fn_9+0x385>
    2498:	mov    ecx,0x2
    249d:	mov    rax,rcx
    24a0:	jmp    25b8 <botlish_fn_9+0x498>
    24a5:	mov    QWORD PTR [rsp],0x3
    24ad:	test   r13,0x1
    24b4:	je     24cc <botlish_fn_9+0x3ac>
    24ba:	mov    rdx,r13
    24bd:	add    rdx,0x2
    24c1:	seto   al
    24c4:	test   al,al
    24c6:	je     24e4 <botlish_fn_9+0x3c4>
    24cc:	mov    edx,0x3
    24d1:	mov    rsi,r13
    24d4:	mov    rdi,QWORD PTR [rsp+0xa0]
    24dc:	call   24e1 <botlish_fn_9+0x3c1>
			24dd: R_X86_64_PLT32	rt_int_add-0x4
    24e1:	mov    rdx,rax
    24e4:	mov    QWORD PTR [rsp],rdx
    24e8:	mov    rsi,r14
    24eb:	mov    rdi,QWORD PTR [rsp+0xa0]
    24f3:	call   24f8 <botlish_fn_9+0x3d8>
			24f4: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    24f8:	test   rax,rax
    24fb:	jne    254b <botlish_fn_9+0x42b>
    2501:	mov    rdi,QWORD PTR [rsp+0xa0]
    2509:	mov    rdi,QWORD PTR [rsp+0xa0]
    2511:	mov    QWORD PTR [rdi],rbx
    2514:	xor    rax,rax
    2517:	mov    rbx,QWORD PTR [rsp+0xc0]
    251f:	mov    r12,QWORD PTR [rsp+0xc8]
    2527:	mov    r13,QWORD PTR [rsp+0xd0]
    252f:	mov    r14,QWORD PTR [rsp+0xd8]
    2537:	mov    r15,QWORD PTR [rsp+0xe0]
    253f:	add    rsp,0xf0
    2546:	mov    rsp,rbp
    2549:	pop    rbp
    254a:	ret
    254b:	mov    rcx,rax
    254e:	and    rcx,r12
    2551:	mov    rsi,rax
    2554:	mov    QWORD PTR [rsp+0xb0],r12
    255c:	test   rcx,0x1
    2563:	jne    2596 <botlish_fn_9+0x476>
    2569:	mov    rdx,QWORD PTR [rsp+0xb0]
    2571:	mov    rdi,QWORD PTR [rsp+0xa0]
    2579:	call   257e <botlish_fn_9+0x45e>
			257a: R_X86_64_PLT32	rt_int_cmp-0x4
    257e:	mov    ecx,0x2
    2583:	test   rax,rax
    2586:	mov    rax,rcx
    2589:	cmove  rax,QWORD PTR [rip+0xc7]        # 2658 <botlish_fn_9+0x538>
    2591:	jmp    25b8 <botlish_fn_9+0x498>
    2596:	mov    rdx,QWORD PTR [rsp+0xb0]
    259e:	mov    eax,0x2
    25a3:	cmp    rsi,rdx
    25a6:	cmove  rax,QWORD PTR [rip+0xaa]        # 2658 <botlish_fn_9+0x538>
    25ae:	jmp    25b8 <botlish_fn_9+0x498>
    25b3:	mov    eax,0x2
    25b8:	mov    rdi,QWORD PTR [rsp+0xa0]
    25c0:	jmp    25d2 <botlish_fn_9+0x4b2>
    25c5:	mov    eax,0x2
    25ca:	mov    rdi,QWORD PTR [rsp+0xa0]
    25d2:	mov    rdi,QWORD PTR [rsp+0xa0]
    25da:	mov    QWORD PTR [rdi],rbx
    25dd:	mov    rbx,QWORD PTR [rsp+0xc0]
    25e5:	mov    r12,QWORD PTR [rsp+0xc8]
    25ed:	mov    r13,QWORD PTR [rsp+0xd0]
    25f5:	mov    r14,QWORD PTR [rsp+0xd8]
    25fd:	mov    r15,QWORD PTR [rsp+0xe0]
    2605:	add    rsp,0xf0
    260c:	mov    rsp,rbp
    260f:	pop    rbp
    2610:	ret
    2611:	mov    QWORD PTR [rsp+0xa0],rdi
    2619:	call   261e <botlish_fn_9+0x4fe>
			261a: R_X86_64_PLT32	rt_stack_overflow-0x4
    261e:	xor    rax,rax
    2621:	mov    rbx,QWORD PTR [rsp+0xc0]
    2629:	mov    r12,QWORD PTR [rsp+0xc8]
    2631:	mov    r13,QWORD PTR [rsp+0xd0]
    2639:	mov    r14,QWORD PTR [rsp+0xd8]
    2641:	mov    r15,QWORD PTR [rsp+0xe0]
    2649:	add    rsp,0xf0
    2650:	mov    rsp,rbp
    2653:	pop    rbp
    2654:	ret
    2655:	add    BYTE PTR [rax],al
    2657:	add    BYTE PTR [rsi],al
    2659:	add    BYTE PTR [rax],al
    265b:	add    BYTE PTR [rax],al
    265d:	add    BYTE PTR [rax],al
	...

0000000000002660 <botlish_entry_9: <str>>:
    2660:	push   rbp
    2661:	mov    rbp,rsp
    2664:	mov    rsi,QWORD PTR [rdx]
    2667:	call   266c <botlish_entry_9+0xc>
			2668: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    266c:	mov    rsp,rbp
    266f:	pop    rbp
    2670:	ret
    2671:	add    BYTE PTR [rax],al
    2673:	add    BYTE PTR [rax],al
    2675:	add    BYTE PTR [rax],al
	...

0000000000002678 <botlish_fn_10: <generic>>:
    2678:	push   rbp
    2679:	mov    rbp,rsp
    267c:	sub    rsp,0xf0
    2683:	mov    QWORD PTR [rsp+0xc0],rbx
    268b:	mov    QWORD PTR [rsp+0xc8],r12
    2693:	mov    QWORD PTR [rsp+0xd0],r13
    269b:	mov    QWORD PTR [rsp+0xd8],r14
    26a3:	mov    QWORD PTR [rsp+0xe0],r15
    26ab:	mov    rbx,QWORD PTR [rdi]
    26ae:	mov    rax,QWORD PTR [rdi+0x8]
    26b2:	lea    rcx,[rbx+0x8]
    26b6:	cmp    rcx,rax
    26b9:	ja     2b40 <botlish_fn_10+0x4c8>
    26bf:	lea    rax,[rbx+0x8]
    26c3:	mov    QWORD PTR [rdi],rax
    26c6:	mov    QWORD PTR [rbx],0x0
    26cd:	mov    QWORD PTR [rsp+0x10],0x0
    26d6:	mov    QWORD PTR [rsp+0x18],0x0
    26df:	mov    QWORD PTR [rsp+0x20],0x0
    26e8:	mov    QWORD PTR [rsp],rsi
    26ec:	xor    eax,eax
    26ee:	test   rsi,0x7
    26f5:	jne    2704 <botlish_fn_10+0x8c>
    26fb:	movzx  rax,BYTE PTR [rsi]
    26ff:	cmp    al,0x2
    2701:	sete   al
    2704:	test   al,al
    2706:	jne    272c <botlish_fn_10+0xb4>
    270c:	mov    rax,QWORD PTR [rdi+0x10]
    2710:	mov    r15,rdi
    2713:	mov    rcx,QWORD PTR [rax+0xd8]
    271a:	mov    edx,0x1
    271f:	call   2724 <botlish_fn_10+0xac>
			2720: R_X86_64_PLT32	rt_type_error-0x4
    2724:	mov    rdi,r15
    2727:	jmp    2a51 <botlish_fn_10+0x3d9>
    272c:	mov    r12,rsi
    272f:	mov    r15,rdi
    2732:	call   2737 <botlish_fn_10+0xbf>
			2733: R_X86_64_PLT32	rt_str_len-0x4
    2737:	mov    QWORD PTR [rsp+0xb0],rax
    273f:	mov    QWORD PTR [rsp+0x8],rax
    2744:	lea    r8,[rsp+0x28]
    2749:	mov    QWORD PTR [rsp+0x28],r12
    274e:	mov    esi,0xb
    2753:	mov    rdx,QWORD PTR [rip+0x0]        # 275a <botlish_fn_10+0xe2>
			2756: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    275a:	mov    r12d,0x1
    2760:	mov    rcx,r12
    2763:	mov    rdi,r15
    2766:	call   276b <botlish_fn_10+0xf3>
			2767: R_X86_64_PLT32	rt_closure_new-0x4
    276b:	mov    r14,rax
    276e:	mov    QWORD PTR [rsp+0xa8],r12
    2776:	mov    QWORD PTR [rsp],rax
    277a:	lea    r8,[rsp+0x30]
    277f:	mov    rax,QWORD PTR [rsp+0xb0]
    2787:	mov    QWORD PTR [rsp+0x30],rax
    278c:	mov    rax,r14
    278f:	mov    QWORD PTR [rsp+0x38],rax
    2794:	mov    esi,0xf
    2799:	mov    rdx,QWORD PTR [rip+0x0]        # 27a0 <botlish_fn_10+0x128>
			279c: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_local<generic>
    27a0:	mov    r13d,0x2
    27a6:	mov    rcx,r13
    27a9:	mov    rdi,r15
    27ac:	call   27b1 <botlish_fn_10+0x139>
			27ad: R_X86_64_PLT32	rt_closure_new-0x4
    27b1:	mov    r12,rax
    27b4:	mov    QWORD PTR [rsp+0x10],r12
    27b9:	lea    r8,[rsp+0x40]
    27be:	mov    rax,QWORD PTR [rsp+0xb0]
    27c6:	mov    QWORD PTR [rsp+0x40],rax
    27cb:	mov    rax,r14
    27ce:	mov    QWORD PTR [rsp+0x48],rax
    27d3:	mov    esi,0x10
    27d8:	mov    rdx,QWORD PTR [rip+0x0]        # 27df <botlish_fn_10+0x167>
			27db: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; scan_label<generic>
    27df:	mov    rcx,r13
    27e2:	mov    rdi,r15
    27e5:	call   27ea <botlish_fn_10+0x172>
			27e6: R_X86_64_PLT32	rt_closure_new-0x4
    27ea:	mov    QWORD PTR [rsp+0x18],rax
    27ef:	mov    QWORD PTR [rsp+0xa0],rax
    27f7:	lea    r8,[rsp+0x50]
    27fc:	mov    rax,QWORD PTR [rsp+0xb0]
    2804:	mov    QWORD PTR [rsp+0x50],rax
    2809:	mov    QWORD PTR [rsp+0x58],r14
    280e:	mov    esi,0x11
    2813:	mov    rdx,QWORD PTR [rip+0x0]        # 281a <botlish_fn_10+0x1a2>
			2816: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; scan_alpha<generic>
    281a:	mov    rcx,r13
    281d:	mov    rdi,r15
    2820:	call   2825 <botlish_fn_10+0x1ad>
			2821: R_X86_64_PLT32	rt_closure_new-0x4
    2825:	mov    QWORD PTR [rsp+0x20],rax
    282a:	lea    r8,[rsp+0x60]
    282f:	mov    QWORD PTR [rsp+0x60],rax
    2834:	mov    rax,QWORD PTR [rsp+0xb0]
    283c:	mov    QWORD PTR [rsp+0x68],rax
    2841:	mov    esi,0x12
    2846:	mov    rdx,QWORD PTR [rip+0x0]        # 284d <botlish_fn_10+0x1d5>
			2849: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; tld_ok<generic>
    284d:	mov    rcx,r13
    2850:	mov    rdi,r15
    2853:	call   2858 <botlish_fn_10+0x1e0>
			2854: R_X86_64_PLT32	rt_closure_new-0x4
    2858:	mov    QWORD PTR [rsp+0x20],rax
    285d:	lea    r8,[rsp+0x70]
    2862:	mov    rsi,QWORD PTR [rsp+0xa0]
    286a:	mov    QWORD PTR [rsp+0x70],rsi
    286f:	mov    rcx,QWORD PTR [rsp+0xb0]
    2877:	mov    QWORD PTR [rsp+0x78],rcx
    287c:	mov    QWORD PTR [rsp+0x80],r14
    2884:	mov    QWORD PTR [rsp+0x88],rax
    288c:	mov    esi,0x13
    2891:	mov    rdx,QWORD PTR [rip+0x0]        # 2898 <botlish_fn_10+0x220>
			2894: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; domain_loop<generic>
    2898:	mov    ecx,0x4
    289d:	mov    rdi,r15
    28a0:	call   28a5 <botlish_fn_10+0x22d>
			28a1: R_X86_64_PLT32	rt_closure_new-0x4
    28a5:	mov    QWORD PTR [rsp+0x18],rax
    28aa:	mov    QWORD PTR [rsp+0xa0],rax
    28b2:	mov    QWORD PTR [rsp+0x20],0x1
    28bb:	mov    rsi,r12
    28be:	mov    rdx,QWORD PTR [rsp+0xa8]
    28c6:	mov    rdi,r15
    28c9:	call   28ce <botlish_fn_10+0x256>
			28ca: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    28ce:	mov    rcx,rax
    28d1:	mov    r12,rax
    28d4:	test   rax,rcx
    28d7:	jne    28e5 <botlish_fn_10+0x26d>
    28dd:	mov    rdi,r15
    28e0:	jmp    2a51 <botlish_fn_10+0x3d9>
    28e5:	mov    rax,r12
    28e8:	mov    QWORD PTR [rsp+0x10],rax
    28ed:	test   rax,0x1
    28f3:	jne    2921 <botlish_fn_10+0x2a9>
    28f9:	mov    rdx,QWORD PTR [rsp+0xa8]
    2901:	mov    rsi,r12
    2904:	mov    rdi,r15
    2907:	call   290c <botlish_fn_10+0x294>
			2908: R_X86_64_PLT32	rt_int_cmp-0x4
    290c:	mov    ecx,0x2
    2911:	test   rax,rax
    2914:	cmove  rcx,QWORD PTR [rip+0x264]        # 2b80 <botlish_fn_10+0x508>
    291c:	jmp    2932 <botlish_fn_10+0x2ba>
    2921:	mov    ecx,0x2
    2926:	cmp    r12,0x1
    292a:	cmove  rcx,QWORD PTR [rip+0x24e]        # 2b80 <botlish_fn_10+0x508>
    2932:	cmp    rcx,0x6
    2936:	je     2afe <botlish_fn_10+0x486>
    293c:	mov    r13,QWORD PTR [rsp+0xb0]
    2944:	mov    rax,r12
    2947:	and    rax,r13
    294a:	test   rax,0x1
    2950:	jne    2979 <botlish_fn_10+0x301>
    2956:	mov    rdx,r13
    2959:	mov    rsi,r12
    295c:	mov    rdi,r15
    295f:	call   2964 <botlish_fn_10+0x2ec>
			2960: R_X86_64_PLT32	rt_int_cmp-0x4
    2964:	mov    ecx,0x2
    2969:	test   rax,rax
    296c:	cmovge rcx,QWORD PTR [rip+0x20c]        # 2b80 <botlish_fn_10+0x508>
    2974:	jmp    2989 <botlish_fn_10+0x311>
    2979:	mov    ecx,0x2
    297e:	cmp    r12,r13
    2981:	cmovge rcx,QWORD PTR [rip+0x1f7]        # 2b80 <botlish_fn_10+0x508>
    2989:	cmp    rcx,0x6
    298d:	je     2af1 <botlish_fn_10+0x479>
    2993:	lea    rcx,[rsp+0x90]
    299b:	mov    rsi,r14
    299e:	mov    rdx,r12
    29a1:	mov    rdi,r15
    29a4:	call   29a9 <botlish_fn_10+0x331>
			29a5: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    29a9:	test   rax,rax
    29ac:	mov    rsi,rax
    29af:	jne    29bd <botlish_fn_10+0x345>
    29b5:	mov    rdi,r15
    29b8:	jmp    2a51 <botlish_fn_10+0x3d9>
    29bd:	mov    rdx,QWORD PTR [rsp+0x90]
    29c5:	mov    rcx,QWORD PTR [rsp+0x98]
    29cd:	mov    rdi,r15
    29d0:	mov    rax,QWORD PTR [rdi+0x10]
    29d4:	mov    r8,QWORD PTR [rax+0x100]
    29db:	call   29e0 <botlish_fn_10+0x368>
			29dc: R_X86_64_PLT32	rt_str_region_eq-0x4
    29e0:	cmp    rax,0x6
    29e4:	je     29f7 <botlish_fn_10+0x37f>
    29ea:	mov    esi,0x2
    29ef:	mov    rax,rsi
    29f2:	jmp    2af6 <botlish_fn_10+0x47e>
    29f7:	mov    QWORD PTR [rsp],0x3
    29ff:	test   r12,0x1
    2a06:	je     2a1e <botlish_fn_10+0x3a6>
    2a0c:	mov    rdx,r12
    2a0f:	add    rdx,0x2
    2a13:	seto   al
    2a16:	test   al,al
    2a18:	je     2a31 <botlish_fn_10+0x3b9>
    2a1e:	mov    edx,0x3
    2a23:	mov    rsi,r12
    2a26:	mov    rdi,r15
    2a29:	call   2a2e <botlish_fn_10+0x3b6>
			2a2a: R_X86_64_PLT32	rt_int_add-0x4
    2a2e:	mov    rdx,rax
    2a31:	mov    QWORD PTR [rsp],rdx
    2a35:	mov    rsi,QWORD PTR [rsp+0xa0]
    2a3d:	mov    rdi,r15
    2a40:	call   2a45 <botlish_fn_10+0x3cd>
			2a41: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    2a45:	test   rax,rax
    2a48:	jne    2a8e <botlish_fn_10+0x416>
    2a4e:	mov    rdi,r15
    2a51:	mov    rdi,r15
    2a54:	mov    QWORD PTR [rdi],rbx
    2a57:	xor    rax,rax
    2a5a:	mov    rbx,QWORD PTR [rsp+0xc0]
    2a62:	mov    r12,QWORD PTR [rsp+0xc8]
    2a6a:	mov    r13,QWORD PTR [rsp+0xd0]
    2a72:	mov    r14,QWORD PTR [rsp+0xd8]
    2a7a:	mov    r15,QWORD PTR [rsp+0xe0]
    2a82:	add    rsp,0xf0
    2a89:	mov    rsp,rbp
    2a8c:	pop    rbp
    2a8d:	ret
    2a8e:	mov    rcx,rax
    2a91:	and    rcx,r13
    2a94:	mov    rsi,rax
    2a97:	mov    QWORD PTR [rsp+0xb0],r13
    2a9f:	test   rcx,0x1
    2aa6:	jne    2ad4 <botlish_fn_10+0x45c>
    2aac:	mov    rdx,QWORD PTR [rsp+0xb0]
    2ab4:	mov    rdi,r15
    2ab7:	call   2abc <botlish_fn_10+0x444>
			2ab8: R_X86_64_PLT32	rt_int_cmp-0x4
    2abc:	mov    esi,0x2
    2ac1:	test   rax,rax
    2ac4:	mov    rax,rsi
    2ac7:	cmove  rax,QWORD PTR [rip+0xb1]        # 2b80 <botlish_fn_10+0x508>
    2acf:	jmp    2af6 <botlish_fn_10+0x47e>
    2ad4:	mov    rdx,QWORD PTR [rsp+0xb0]
    2adc:	mov    eax,0x2
    2ae1:	cmp    rsi,rdx
    2ae4:	cmove  rax,QWORD PTR [rip+0x94]        # 2b80 <botlish_fn_10+0x508>
    2aec:	jmp    2af6 <botlish_fn_10+0x47e>
    2af1:	mov    eax,0x2
    2af6:	mov    rdi,r15
    2af9:	jmp    2b06 <botlish_fn_10+0x48e>
    2afe:	mov    eax,0x2
    2b03:	mov    rdi,r15
    2b06:	mov    rdi,r15
    2b09:	mov    QWORD PTR [rdi],rbx
    2b0c:	mov    rbx,QWORD PTR [rsp+0xc0]
    2b14:	mov    r12,QWORD PTR [rsp+0xc8]
    2b1c:	mov    r13,QWORD PTR [rsp+0xd0]
    2b24:	mov    r14,QWORD PTR [rsp+0xd8]
    2b2c:	mov    r15,QWORD PTR [rsp+0xe0]
    2b34:	add    rsp,0xf0
    2b3b:	mov    rsp,rbp
    2b3e:	pop    rbp
    2b3f:	ret
    2b40:	mov    r15,rdi
    2b43:	call   2b48 <botlish_fn_10+0x4d0>
			2b44: R_X86_64_PLT32	rt_stack_overflow-0x4
    2b48:	xor    rax,rax
    2b4b:	mov    rbx,QWORD PTR [rsp+0xc0]
    2b53:	mov    r12,QWORD PTR [rsp+0xc8]
    2b5b:	mov    r13,QWORD PTR [rsp+0xd0]
    2b63:	mov    r14,QWORD PTR [rsp+0xd8]
    2b6b:	mov    r15,QWORD PTR [rsp+0xe0]
    2b73:	add    rsp,0xf0
    2b7a:	mov    rsp,rbp
    2b7d:	pop    rbp
    2b7e:	ret
    2b7f:	add    BYTE PTR [rsi],al
    2b81:	add    BYTE PTR [rax],al
    2b83:	add    BYTE PTR [rax],al
    2b85:	add    BYTE PTR [rax],al
	...

0000000000002b88 <botlish_entry_10: <generic>>:
    2b88:	push   rbp
    2b89:	mov    rbp,rsp
    2b8c:	mov    rsi,QWORD PTR [rdx]
    2b8f:	call   2b94 <botlish_entry_10+0xc>
			2b90: R_X86_64_PLT32	botlish_fn_10-0x4 ; <generic>
    2b94:	mov    rsp,rbp
    2b97:	pop    rbp
    2b98:	ret

0000000000002b99 <botlish_fn_11: char_at<generic>>:
    2b99:	push   rbp
    2b9a:	mov    rbp,rsp
    2b9d:	sub    rsp,0x40
    2ba1:	mov    QWORD PTR [rsp+0x20],rbx
    2ba6:	mov    QWORD PTR [rsp+0x28],r12
    2bab:	mov    QWORD PTR [rsp+0x30],r13
    2bb0:	mov    QWORD PTR [rsp],rdx
    2bb4:	mov    rax,QWORD PTR [rsi+0x20]
    2bb8:	mov    rsi,QWORD PTR [rax]
    2bbb:	mov    QWORD PTR [rsp+0x8],rsi
    2bc0:	mov    r13,rsi
    2bc3:	mov    QWORD PTR [rsp+0x10],0x3
    2bcc:	mov    r10d,0x1
    2bd2:	test   rdx,0x1
    2bd9:	je     2be7 <botlish_fn_11+0x4e>
    2bdf:	mov    rbx,rdx
    2be2:	jmp    2c0c <botlish_fn_11+0x73>
    2be7:	xor    r10d,r10d
    2bea:	test   rdx,0x7
    2bf1:	je     2bff <botlish_fn_11+0x66>
    2bf7:	mov    rbx,rdx
    2bfa:	jmp    2c0c <botlish_fn_11+0x73>
    2bff:	movzx  rax,BYTE PTR [rdx]
    2c03:	mov    rbx,rdx
    2c06:	cmp    al,0x1
    2c08:	sete   r10b
    2c0c:	test   r10b,r10b
    2c0f:	jne    2c30 <botlish_fn_11+0x97>
    2c15:	mov    rax,QWORD PTR [rdi+0x10]
    2c19:	mov    rcx,QWORD PTR [rax+0x108]
    2c20:	xor    rdx,rdx
    2c23:	mov    rsi,rbx
    2c26:	call   2c2b <botlish_fn_11+0x92>
			2c27: R_X86_64_PLT32	rt_type_error-0x4
    2c2b:	jmp    2ce2 <botlish_fn_11+0x149>
    2c30:	mov    rsi,rbx
    2c33:	mov    r12,rdi
    2c36:	test   rsi,0x1
    2c3d:	je     2c58 <botlish_fn_11+0xbf>
    2c43:	mov    rsi,rbx
    2c46:	mov    rcx,rsi
    2c49:	add    rcx,0x2
    2c4d:	seto   al
    2c50:	test   al,al
    2c52:	je     2c6b <botlish_fn_11+0xd2>
    2c58:	mov    edx,0x3
    2c5d:	mov    rsi,rbx
    2c60:	mov    rdi,r12
    2c63:	call   2c68 <botlish_fn_11+0xcf>
			2c64: R_X86_64_PLT32	rt_int_add-0x4
    2c68:	mov    rcx,rax
    2c6b:	mov    QWORD PTR [rsp+0x10],rcx
    2c70:	mov    eax,0x1
    2c75:	mov    rsi,rbx
    2c78:	test   rsi,0x1
    2c7f:	jne    2ca5 <botlish_fn_11+0x10c>
    2c85:	xor    eax,eax
    2c87:	mov    rsi,rbx
    2c8a:	test   rsi,0x7
    2c91:	jne    2ca5 <botlish_fn_11+0x10c>
    2c97:	mov    rsi,rbx
    2c9a:	movzx  rdx,BYTE PTR [rsi]
    2c9e:	rex cmp dl,0x1
    2ca2:	sete   al
    2ca5:	test   al,al
    2ca7:	jne    2ccb <botlish_fn_11+0x132>
    2cad:	mov    rdi,r12
    2cb0:	mov    rsi,QWORD PTR [rdi+0x10]
    2cb4:	mov    rcx,QWORD PTR [rsi+0x110]
    2cbb:	xor    rdx,rdx
    2cbe:	mov    rsi,rbx
    2cc1:	call   2cc6 <botlish_fn_11+0x12d>
			2cc2: R_X86_64_PLT32	rt_type_error-0x4
    2cc6:	jmp    2ce2 <botlish_fn_11+0x149>
    2ccb:	mov    rdx,rbx
    2cce:	mov    rsi,r13
    2cd1:	mov    rdi,r12
    2cd4:	call   2cd9 <botlish_fn_11+0x140>
			2cd5: R_X86_64_PLT32	rt_substr-0x4
    2cd9:	test   rax,rax
    2cdc:	jne    2cfd <botlish_fn_11+0x164>
    2ce2:	xor    rax,rax
    2ce5:	mov    rbx,QWORD PTR [rsp+0x20]
    2cea:	mov    r12,QWORD PTR [rsp+0x28]
    2cef:	mov    r13,QWORD PTR [rsp+0x30]
    2cf4:	add    rsp,0x40
    2cf8:	mov    rsp,rbp
    2cfb:	pop    rbp
    2cfc:	ret
    2cfd:	mov    rbx,QWORD PTR [rsp+0x20]
    2d02:	mov    r12,QWORD PTR [rsp+0x28]
    2d07:	mov    r13,QWORD PTR [rsp+0x30]
    2d0c:	add    rsp,0x40
    2d10:	mov    rsp,rbp
    2d13:	pop    rbp
    2d14:	ret

0000000000002d15 <botlish_entry_11: char_at<generic>>:
    2d15:	push   rbp
    2d16:	mov    rbp,rsp
    2d19:	mov    rdx,QWORD PTR [rdx]
    2d1c:	call   2d21 <botlish_entry_11+0xc>
			2d1d: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2d21:	mov    rsp,rbp
    2d24:	pop    rbp
    2d25:	ret

0000000000002d26 <botlish_fn_12: char_at<generic>>:
    2d26:	push   rbp
    2d27:	mov    rbp,rsp
    2d2a:	sub    rsp,0x40
    2d2e:	mov    QWORD PTR [rsp+0x20],rbx
    2d33:	mov    QWORD PTR [rsp+0x28],r12
    2d38:	mov    QWORD PTR [rsp+0x30],r13
    2d3d:	mov    QWORD PTR [rsp+0x38],r14
    2d42:	mov    r13,rcx
    2d45:	mov    QWORD PTR [rsp],rdx
    2d49:	mov    rax,QWORD PTR [rsi+0x20]
    2d4d:	mov    rax,QWORD PTR [rax]
    2d50:	mov    QWORD PTR [rsp+0x8],rax
    2d55:	mov    r14,rax
    2d58:	mov    QWORD PTR [rsp+0x10],0x3
    2d61:	mov    r11d,0x1
    2d67:	test   rdx,0x1
    2d6e:	je     2d7c <botlish_fn_12+0x56>
    2d74:	mov    r12,rdx
    2d77:	jmp    2da1 <botlish_fn_12+0x7b>
    2d7c:	xor    r11d,r11d
    2d7f:	test   rdx,0x7
    2d86:	je     2d94 <botlish_fn_12+0x6e>
    2d8c:	mov    r12,rdx
    2d8f:	jmp    2da1 <botlish_fn_12+0x7b>
    2d94:	movzx  rax,BYTE PTR [rdx]
    2d98:	mov    r12,rdx
    2d9b:	cmp    al,0x1
    2d9d:	sete   r11b
    2da1:	test   r11b,r11b
    2da4:	jne    2dc5 <botlish_fn_12+0x9f>
    2daa:	mov    rax,QWORD PTR [rdi+0x10]
    2dae:	mov    rcx,QWORD PTR [rax+0x108]
    2db5:	xor    rdx,rdx
    2db8:	mov    rsi,r12
    2dbb:	call   2dc0 <botlish_fn_12+0x9a>
			2dbc: R_X86_64_PLT32	rt_type_error-0x4
    2dc0:	jmp    2e7d <botlish_fn_12+0x157>
    2dc5:	mov    rbx,rdi
    2dc8:	mov    rsi,r12
    2dcb:	test   rsi,0x1
    2dd2:	jne    2de0 <botlish_fn_12+0xba>
    2dd8:	mov    r12,rsi
    2ddb:	jmp    2df5 <botlish_fn_12+0xcf>
    2de0:	mov    rax,rsi
    2de3:	add    rax,0x2
    2de7:	mov    r12,rsi
    2dea:	seto   cl
    2ded:	test   cl,cl
    2def:	je     2e05 <botlish_fn_12+0xdf>
    2df5:	mov    edx,0x3
    2dfa:	mov    rsi,r12
    2dfd:	mov    rdi,rbx
    2e00:	call   2e05 <botlish_fn_12+0xdf>
			2e01: R_X86_64_PLT32	rt_int_add-0x4
    2e05:	mov    ecx,0x1
    2e0a:	mov    rsi,r12
    2e0d:	test   rsi,0x1
    2e14:	jne    2e3a <botlish_fn_12+0x114>
    2e1a:	xor    ecx,ecx
    2e1c:	mov    rsi,r12
    2e1f:	test   rsi,0x7
    2e26:	jne    2e3a <botlish_fn_12+0x114>
    2e2c:	mov    rsi,r12
    2e2f:	movzx  rdx,BYTE PTR [rsi]
    2e33:	rex cmp dl,0x1
    2e37:	sete   cl
    2e3a:	test   cl,cl
    2e3c:	jne    2e60 <botlish_fn_12+0x13a>
    2e42:	mov    rdi,rbx
    2e45:	mov    rsi,QWORD PTR [rdi+0x10]
    2e49:	mov    rcx,QWORD PTR [rsi+0x110]
    2e50:	xor    rdx,rdx
    2e53:	mov    rsi,r12
    2e56:	call   2e5b <botlish_fn_12+0x135>
			2e57: R_X86_64_PLT32	rt_type_error-0x4
    2e5b:	jmp    2e7d <botlish_fn_12+0x157>
    2e60:	mov    rdi,rbx
    2e63:	mov    rbx,rax
    2e66:	mov    rcx,rbx
    2e69:	mov    rdx,r12
    2e6c:	mov    rsi,r14
    2e6f:	call   2e74 <botlish_fn_12+0x14e>
			2e70: R_X86_64_PLT32	rt_str_region_check-0x4
    2e74:	test   rax,rax
    2e77:	jne    2e9d <botlish_fn_12+0x177>
    2e7d:	xor    rax,rax
    2e80:	mov    rbx,QWORD PTR [rsp+0x20]
    2e85:	mov    r12,QWORD PTR [rsp+0x28]
    2e8a:	mov    r13,QWORD PTR [rsp+0x30]
    2e8f:	mov    r14,QWORD PTR [rsp+0x38]
    2e94:	add    rsp,0x40
    2e98:	mov    rsp,rbp
    2e9b:	pop    rbp
    2e9c:	ret
    2e9d:	mov    rcx,r13
    2ea0:	mov    rsi,r12
    2ea3:	mov    QWORD PTR [rcx],rsi
    2ea6:	mov    QWORD PTR [rcx+0x8],rbx
    2eaa:	mov    rax,r14
    2ead:	mov    rbx,QWORD PTR [rsp+0x20]
    2eb2:	mov    r12,QWORD PTR [rsp+0x28]
    2eb7:	mov    r13,QWORD PTR [rsp+0x30]
    2ebc:	mov    r14,QWORD PTR [rsp+0x38]
    2ec1:	add    rsp,0x40
    2ec5:	mov    rsp,rbp
    2ec8:	pop    rbp
    2ec9:	ret

0000000000002eca <botlish_entry_12: char_at<generic>>:
    2eca:	push   rbp
    2ecb:	mov    rbp,rsp
    2ece:	ud2

0000000000002ed0 <botlish_fn_13: is_local_char<str>>:
    2ed0:	push   rbp
    2ed1:	mov    rbp,rsp
    2ed4:	sub    rsp,0x10
    2ed8:	mov    QWORD PTR [rsp],rbx
    2edc:	mov    QWORD PTR [rsp+0x8],r12
    2ee1:	mov    rbx,rsi
    2ee4:	mov    r12,rdi
    2ee7:	mov    rsi,rbx
    2eea:	mov    rdi,r12
    2eed:	call   2ef2 <botlish_fn_13+0x22>
			2eee: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    2ef2:	test   rax,rax
    2ef5:	jne    2f10 <botlish_fn_13+0x40>
    2efb:	xor    rax,rax
    2efe:	mov    rbx,QWORD PTR [rsp]
    2f02:	mov    r12,QWORD PTR [rsp+0x8]
    2f07:	add    rsp,0x10
    2f0b:	mov    rsp,rbp
    2f0e:	pop    rbp
    2f0f:	ret
    2f10:	cmp    rax,0x6
    2f14:	je     300f <botlish_fn_13+0x13f>
    2f1a:	mov    rdi,r12
    2f1d:	mov    rax,QWORD PTR [rdi+0x10]
    2f21:	mov    rsi,QWORD PTR [rax+0x118]
    2f28:	mov    edx,0x1
    2f2d:	mov    ecx,0x3
    2f32:	mov    r8,rbx
    2f35:	call   2f3a <botlish_fn_13+0x6a>
			2f36: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f3a:	cmp    rax,0x6
    2f3e:	je     3005 <botlish_fn_13+0x135>
    2f44:	mov    rdi,r12
    2f47:	mov    rax,QWORD PTR [rdi+0x10]
    2f4b:	mov    rsi,QWORD PTR [rax+0x120]
    2f52:	mov    edx,0x1
    2f57:	mov    ecx,0x3
    2f5c:	mov    r8,rbx
    2f5f:	call   2f64 <botlish_fn_13+0x94>
			2f60: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f64:	cmp    rax,0x6
    2f68:	je     2ffb <botlish_fn_13+0x12b>
    2f6e:	mov    rdi,r12
    2f71:	mov    rax,QWORD PTR [rdi+0x10]
    2f75:	mov    rsi,QWORD PTR [rax+0xc0]
    2f7c:	mov    edx,0x1
    2f81:	mov    ecx,0x3
    2f86:	mov    r8,rbx
    2f89:	call   2f8e <botlish_fn_13+0xbe>
			2f8a: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f8e:	cmp    rax,0x6
    2f92:	je     2ff1 <botlish_fn_13+0x121>
    2f98:	mov    rdi,r12
    2f9b:	mov    rax,QWORD PTR [rdi+0x10]
    2f9f:	mov    rsi,QWORD PTR [rax+0x108]
    2fa6:	mov    edx,0x1
    2fab:	mov    ecx,0x3
    2fb0:	mov    r8,rbx
    2fb3:	call   2fb8 <botlish_fn_13+0xe8>
			2fb4: R_X86_64_PLT32	rt_str_region_eq-0x4
    2fb8:	cmp    rax,0x6
    2fbc:	je     2fe7 <botlish_fn_13+0x117>
    2fc2:	mov    rdi,r12
    2fc5:	mov    rax,QWORD PTR [rdi+0x10]
    2fc9:	mov    rsi,QWORD PTR [rax+0x128]
    2fd0:	mov    edx,0x1
    2fd5:	mov    ecx,0x3
    2fda:	mov    r8,rbx
    2fdd:	call   2fe2 <botlish_fn_13+0x112>
			2fde: R_X86_64_PLT32	rt_str_region_eq-0x4
    2fe2:	jmp    3014 <botlish_fn_13+0x144>
    2fe7:	mov    eax,0x6
    2fec:	jmp    3014 <botlish_fn_13+0x144>
    2ff1:	mov    eax,0x6
    2ff6:	jmp    3014 <botlish_fn_13+0x144>
    2ffb:	mov    eax,0x6
    3000:	jmp    3014 <botlish_fn_13+0x144>
    3005:	mov    eax,0x6
    300a:	jmp    3014 <botlish_fn_13+0x144>
    300f:	mov    eax,0x6
    3014:	mov    rbx,QWORD PTR [rsp]
    3018:	mov    r12,QWORD PTR [rsp+0x8]
    301d:	add    rsp,0x10
    3021:	mov    rsp,rbp
    3024:	pop    rbp
    3025:	ret

0000000000003026 <botlish_entry_13: is_local_char<str>>:
    3026:	push   rbp
    3027:	mov    rbp,rsp
    302a:	mov    rsi,QWORD PTR [rdx]
    302d:	call   3032 <botlish_entry_13+0xc>
			302e: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_local_char<str>
    3032:	mov    rsp,rbp
    3035:	pop    rbp
    3036:	ret

0000000000003037 <botlish_fn_14: is_label_char<str>>:
    3037:	push   rbp
    3038:	mov    rbp,rsp
    303b:	sub    rsp,0x10
    303f:	mov    QWORD PTR [rsp],r13
    3043:	mov    QWORD PTR [rsp+0x8],r15
    3048:	mov    r13,rsi
    304b:	mov    r15,rdi
    304e:	mov    rsi,r13
    3051:	mov    rdi,r15
    3054:	call   3059 <botlish_fn_14+0x22>
			3055: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    3059:	test   rax,rax
    305c:	jne    3077 <botlish_fn_14+0x40>
    3062:	xor    rax,rax
    3065:	mov    r13,QWORD PTR [rsp]
    3069:	mov    r15,QWORD PTR [rsp+0x8]
    306e:	add    rsp,0x10
    3072:	mov    rsp,rbp
    3075:	pop    rbp
    3076:	ret
    3077:	cmp    rax,0x6
    307b:	je     30a6 <botlish_fn_14+0x6f>
    3081:	mov    rdi,r15
    3084:	mov    rax,QWORD PTR [rdi+0x10]
    3088:	mov    rsi,QWORD PTR [rax+0x128]
    308f:	mov    edx,0x1
    3094:	mov    ecx,0x3
    3099:	mov    r8,r13
    309c:	call   30a1 <botlish_fn_14+0x6a>
			309d: R_X86_64_PLT32	rt_str_region_eq-0x4
    30a1:	jmp    30ab <botlish_fn_14+0x74>
    30a6:	mov    eax,0x6
    30ab:	mov    r13,QWORD PTR [rsp]
    30af:	mov    r15,QWORD PTR [rsp+0x8]
    30b4:	add    rsp,0x10
    30b8:	mov    rsp,rbp
    30bb:	pop    rbp
    30bc:	ret

00000000000030bd <botlish_entry_14: is_label_char<str>>:
    30bd:	push   rbp
    30be:	mov    rbp,rsp
    30c1:	mov    rsi,QWORD PTR [rdx]
    30c4:	call   30c9 <botlish_entry_14+0xc>
			30c5: R_X86_64_PLT32	botlish_fn_14-0x4 ; is_label_char<str>
    30c9:	mov    rsp,rbp
    30cc:	pop    rbp
    30cd:	ret
	...

00000000000030d0 <botlish_fn_15: scan_local<generic>>:
    30d0:	push   rbp
    30d1:	mov    rbp,rsp
    30d4:	sub    rsp,0x40
    30d8:	mov    QWORD PTR [rsp+0x20],rbx
    30dd:	mov    QWORD PTR [rsp+0x28],r12
    30e2:	mov    QWORD PTR [rsp+0x30],r13
    30e7:	mov    QWORD PTR [rsp+0x38],r14
    30ec:	mov    r12,QWORD PTR [rdi]
    30ef:	mov    rax,QWORD PTR [rdi+0x8]
    30f3:	lea    rcx,[r12+0x8]
    30f8:	cmp    rcx,rax
    30fb:	ja     32d9 <botlish_fn_15+0x209>
    3101:	lea    rax,[r12+0x8]
    3106:	mov    QWORD PTR [rdi],rax
    3109:	mov    r13,rdi
    310c:	mov    QWORD PTR [r12],0x0
    3114:	mov    QWORD PTR [rsp+0x10],0x0
    311d:	mov    QWORD PTR [rsp],rdx
    3121:	mov    rbx,rsi
    3124:	mov    rsi,rdx
    3127:	mov    rax,QWORD PTR [rbx+0x20]
    312b:	mov    rdx,QWORD PTR [rax]
    312e:	mov    ecx,0x1
    3133:	test   rsi,0x1
    313a:	jne    3158 <botlish_fn_15+0x88>
    3140:	xor    ecx,ecx
    3142:	test   rsi,0x7
    3149:	jne    3158 <botlish_fn_15+0x88>
    314f:	movzx  rax,BYTE PTR [rsi]
    3153:	cmp    al,0x1
    3155:	sete   cl
    3158:	test   cl,cl
    315a:	jne    317e <botlish_fn_15+0xae>
    3160:	mov    rdi,r13
    3163:	mov    rax,QWORD PTR [rdi+0x10]
    3167:	mov    rcx,QWORD PTR [rax+0xb8]
    316e:	xor    rdx,rdx
    3171:	call   3176 <botlish_fn_15+0xa6>
			3172: R_X86_64_PLT32	rt_type_error-0x4
    3176:	mov    rdi,r13
    3179:	jmp    3215 <botlish_fn_15+0x145>
    317e:	mov    rax,rsi
    3181:	and    rax,rdx
    3184:	mov    r14,rsi
    3187:	test   rax,0x1
    318d:	jne    31b3 <botlish_fn_15+0xe3>
    3193:	mov    rsi,r14
    3196:	mov    rdi,r13
    3199:	call   319e <botlish_fn_15+0xce>
			319a: R_X86_64_PLT32	rt_int_cmp-0x4
    319e:	mov    ecx,0x2
    31a3:	test   rax,rax
    31a6:	cmovge rcx,QWORD PTR [rip+0x15a]        # 3308 <botlish_fn_15+0x238>
    31ae:	jmp    31c6 <botlish_fn_15+0xf6>
    31b3:	mov    ecx,0x2
    31b8:	mov    rsi,r14
    31bb:	cmp    rsi,rdx
    31be:	cmovge rcx,QWORD PTR [rip+0x142]        # 3308 <botlish_fn_15+0x238>
    31c6:	cmp    rcx,0x6
    31ca:	je     32b0 <botlish_fn_15+0x1e0>
    31d0:	mov    rsi,QWORD PTR [rbx+0x20]
    31d4:	mov    rsi,QWORD PTR [rsi+0x8]
    31d8:	mov    QWORD PTR [rsp+0x8],rsi
    31dd:	mov    rdx,r14
    31e0:	mov    rdi,r13
    31e3:	call   31e8 <botlish_fn_15+0x118>
			31e4: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    31e8:	test   rax,rax
    31eb:	jne    31f9 <botlish_fn_15+0x129>
    31f1:	mov    rdi,r13
    31f4:	jmp    3215 <botlish_fn_15+0x145>
    31f9:	mov    QWORD PTR [rsp+0x8],rax
    31fe:	mov    rsi,rax
    3201:	mov    rdi,r13
    3204:	call   3209 <botlish_fn_15+0x139>
			3205: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_local_char<str>
    3209:	test   rax,rax
    320c:	jne    323b <botlish_fn_15+0x16b>
    3212:	mov    rdi,r13
    3215:	mov    rdi,r13
    3218:	mov    QWORD PTR [rdi],r12
    321b:	xor    rax,rax
    321e:	mov    rbx,QWORD PTR [rsp+0x20]
    3223:	mov    r12,QWORD PTR [rsp+0x28]
    3228:	mov    r13,QWORD PTR [rsp+0x30]
    322d:	mov    r14,QWORD PTR [rsp+0x38]
    3232:	add    rsp,0x40
    3236:	mov    rsp,rbp
    3239:	pop    rbp
    323a:	ret
    323b:	cmp    rax,0x6
    323f:	je     3250 <botlish_fn_15+0x180>
    3245:	mov    rax,r14
    3248:	mov    rdi,r13
    324b:	jmp    32b6 <botlish_fn_15+0x1e6>
    3250:	mov    QWORD PTR [rsp+0x8],rbx
    3255:	mov    QWORD PTR [rsp+0x10],0x3
    325e:	mov    rsi,r14
    3261:	test   rsi,0x1
    3268:	je     328e <botlish_fn_15+0x1be>
    326e:	mov    rsi,r14
    3271:	mov    rcx,rsi
    3274:	add    rcx,0x2
    3278:	seto   al
    327b:	test   al,al
    327d:	jne    328e <botlish_fn_15+0x1be>
    3283:	mov    rsi,rcx
    3286:	mov    r14,rcx
    3289:	jmp    32a4 <botlish_fn_15+0x1d4>
    328e:	mov    edx,0x3
    3293:	mov    rsi,r14
    3296:	mov    rdi,r13
    3299:	call   329e <botlish_fn_15+0x1ce>
			329a: R_X86_64_PLT32	rt_int_add-0x4
    329e:	mov    rsi,rax
    32a1:	mov    r14,rax
    32a4:	mov    QWORD PTR [rsp],rsi
    32a8:	mov    rsi,r14
    32ab:	jmp    3127 <botlish_fn_15+0x57>
    32b0:	mov    rax,r14
    32b3:	mov    rdi,r13
    32b6:	mov    rdi,r13
    32b9:	mov    QWORD PTR [rdi],r12
    32bc:	mov    rbx,QWORD PTR [rsp+0x20]
    32c1:	mov    r12,QWORD PTR [rsp+0x28]
    32c6:	mov    r13,QWORD PTR [rsp+0x30]
    32cb:	mov    r14,QWORD PTR [rsp+0x38]
    32d0:	add    rsp,0x40
    32d4:	mov    rsp,rbp
    32d7:	pop    rbp
    32d8:	ret
    32d9:	mov    r13,rdi
    32dc:	call   32e1 <botlish_fn_15+0x211>
			32dd: R_X86_64_PLT32	rt_stack_overflow-0x4
    32e1:	xor    rax,rax
    32e4:	mov    rbx,QWORD PTR [rsp+0x20]
    32e9:	mov    r12,QWORD PTR [rsp+0x28]
    32ee:	mov    r13,QWORD PTR [rsp+0x30]
    32f3:	mov    r14,QWORD PTR [rsp+0x38]
    32f8:	add    rsp,0x40
    32fc:	mov    rsp,rbp
    32ff:	pop    rbp
    3300:	ret
    3301:	add    BYTE PTR [rax],al
    3303:	add    BYTE PTR [rax],al
    3305:	add    BYTE PTR [rax],al
    3307:	add    BYTE PTR [rsi],al
    3309:	add    BYTE PTR [rax],al
    330b:	add    BYTE PTR [rax],al
    330d:	add    BYTE PTR [rax],al
	...

0000000000003310 <botlish_entry_15: scan_local<generic>>:
    3310:	push   rbp
    3311:	mov    rbp,rsp
    3314:	mov    rdx,QWORD PTR [rdx]
    3317:	call   331c <botlish_entry_15+0xc>
			3318: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    331c:	mov    rsp,rbp
    331f:	pop    rbp
    3320:	ret
    3321:	add    BYTE PTR [rax],al
    3323:	add    BYTE PTR [rax],al
    3325:	add    BYTE PTR [rax],al
	...

0000000000003328 <botlish_fn_16: scan_label<generic>>:
    3328:	push   rbp
    3329:	mov    rbp,rsp
    332c:	sub    rsp,0x40
    3330:	mov    QWORD PTR [rsp+0x20],rbx
    3335:	mov    QWORD PTR [rsp+0x28],r12
    333a:	mov    QWORD PTR [rsp+0x30],r13
    333f:	mov    QWORD PTR [rsp+0x38],r14
    3344:	mov    r12,QWORD PTR [rdi]
    3347:	mov    rax,QWORD PTR [rdi+0x8]
    334b:	lea    rcx,[r12+0x8]
    3350:	cmp    rcx,rax
    3353:	ja     3531 <botlish_fn_16+0x209>
    3359:	lea    rax,[r12+0x8]
    335e:	mov    QWORD PTR [rdi],rax
    3361:	mov    r13,rdi
    3364:	mov    QWORD PTR [r12],0x0
    336c:	mov    QWORD PTR [rsp+0x10],0x0
    3375:	mov    QWORD PTR [rsp],rdx
    3379:	mov    rbx,rsi
    337c:	mov    rsi,rdx
    337f:	mov    rax,QWORD PTR [rbx+0x20]
    3383:	mov    rdx,QWORD PTR [rax]
    3386:	mov    ecx,0x1
    338b:	test   rsi,0x1
    3392:	jne    33b0 <botlish_fn_16+0x88>
    3398:	xor    ecx,ecx
    339a:	test   rsi,0x7
    33a1:	jne    33b0 <botlish_fn_16+0x88>
    33a7:	movzx  rax,BYTE PTR [rsi]
    33ab:	cmp    al,0x1
    33ad:	sete   cl
    33b0:	test   cl,cl
    33b2:	jne    33d6 <botlish_fn_16+0xae>
    33b8:	mov    rdi,r13
    33bb:	mov    rax,QWORD PTR [rdi+0x10]
    33bf:	mov    rcx,QWORD PTR [rax+0xb8]
    33c6:	xor    rdx,rdx
    33c9:	call   33ce <botlish_fn_16+0xa6>
			33ca: R_X86_64_PLT32	rt_type_error-0x4
    33ce:	mov    rdi,r13
    33d1:	jmp    346d <botlish_fn_16+0x145>
    33d6:	mov    rax,rsi
    33d9:	and    rax,rdx
    33dc:	mov    r14,rsi
    33df:	test   rax,0x1
    33e5:	jne    340b <botlish_fn_16+0xe3>
    33eb:	mov    rsi,r14
    33ee:	mov    rdi,r13
    33f1:	call   33f6 <botlish_fn_16+0xce>
			33f2: R_X86_64_PLT32	rt_int_cmp-0x4
    33f6:	mov    ecx,0x2
    33fb:	test   rax,rax
    33fe:	cmovge rcx,QWORD PTR [rip+0x15a]        # 3560 <botlish_fn_16+0x238>
    3406:	jmp    341e <botlish_fn_16+0xf6>
    340b:	mov    ecx,0x2
    3410:	mov    rsi,r14
    3413:	cmp    rsi,rdx
    3416:	cmovge rcx,QWORD PTR [rip+0x142]        # 3560 <botlish_fn_16+0x238>
    341e:	cmp    rcx,0x6
    3422:	je     3508 <botlish_fn_16+0x1e0>
    3428:	mov    rsi,QWORD PTR [rbx+0x20]
    342c:	mov    rsi,QWORD PTR [rsi+0x8]
    3430:	mov    QWORD PTR [rsp+0x8],rsi
    3435:	mov    rdx,r14
    3438:	mov    rdi,r13
    343b:	call   3440 <botlish_fn_16+0x118>
			343c: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    3440:	test   rax,rax
    3443:	jne    3451 <botlish_fn_16+0x129>
    3449:	mov    rdi,r13
    344c:	jmp    346d <botlish_fn_16+0x145>
    3451:	mov    QWORD PTR [rsp+0x8],rax
    3456:	mov    rsi,rax
    3459:	mov    rdi,r13
    345c:	call   3461 <botlish_fn_16+0x139>
			345d: R_X86_64_PLT32	botlish_fn_14-0x4 ; is_label_char<str>
    3461:	test   rax,rax
    3464:	jne    3493 <botlish_fn_16+0x16b>
    346a:	mov    rdi,r13
    346d:	mov    rdi,r13
    3470:	mov    QWORD PTR [rdi],r12
    3473:	xor    rax,rax
    3476:	mov    rbx,QWORD PTR [rsp+0x20]
    347b:	mov    r12,QWORD PTR [rsp+0x28]
    3480:	mov    r13,QWORD PTR [rsp+0x30]
    3485:	mov    r14,QWORD PTR [rsp+0x38]
    348a:	add    rsp,0x40
    348e:	mov    rsp,rbp
    3491:	pop    rbp
    3492:	ret
    3493:	cmp    rax,0x6
    3497:	je     34a8 <botlish_fn_16+0x180>
    349d:	mov    rax,r14
    34a0:	mov    rdi,r13
    34a3:	jmp    350e <botlish_fn_16+0x1e6>
    34a8:	mov    QWORD PTR [rsp+0x8],rbx
    34ad:	mov    QWORD PTR [rsp+0x10],0x3
    34b6:	mov    rsi,r14
    34b9:	test   rsi,0x1
    34c0:	je     34e6 <botlish_fn_16+0x1be>
    34c6:	mov    rsi,r14
    34c9:	mov    rcx,rsi
    34cc:	add    rcx,0x2
    34d0:	seto   al
    34d3:	test   al,al
    34d5:	jne    34e6 <botlish_fn_16+0x1be>
    34db:	mov    rsi,rcx
    34de:	mov    r14,rcx
    34e1:	jmp    34fc <botlish_fn_16+0x1d4>
    34e6:	mov    edx,0x3
    34eb:	mov    rsi,r14
    34ee:	mov    rdi,r13
    34f1:	call   34f6 <botlish_fn_16+0x1ce>
			34f2: R_X86_64_PLT32	rt_int_add-0x4
    34f6:	mov    rsi,rax
    34f9:	mov    r14,rax
    34fc:	mov    QWORD PTR [rsp],rsi
    3500:	mov    rsi,r14
    3503:	jmp    337f <botlish_fn_16+0x57>
    3508:	mov    rax,r14
    350b:	mov    rdi,r13
    350e:	mov    rdi,r13
    3511:	mov    QWORD PTR [rdi],r12
    3514:	mov    rbx,QWORD PTR [rsp+0x20]
    3519:	mov    r12,QWORD PTR [rsp+0x28]
    351e:	mov    r13,QWORD PTR [rsp+0x30]
    3523:	mov    r14,QWORD PTR [rsp+0x38]
    3528:	add    rsp,0x40
    352c:	mov    rsp,rbp
    352f:	pop    rbp
    3530:	ret
    3531:	mov    r13,rdi
    3534:	call   3539 <botlish_fn_16+0x211>
			3535: R_X86_64_PLT32	rt_stack_overflow-0x4
    3539:	xor    rax,rax
    353c:	mov    rbx,QWORD PTR [rsp+0x20]
    3541:	mov    r12,QWORD PTR [rsp+0x28]
    3546:	mov    r13,QWORD PTR [rsp+0x30]
    354b:	mov    r14,QWORD PTR [rsp+0x38]
    3550:	add    rsp,0x40
    3554:	mov    rsp,rbp
    3557:	pop    rbp
    3558:	ret
    3559:	add    BYTE PTR [rax],al
    355b:	add    BYTE PTR [rax],al
    355d:	add    BYTE PTR [rax],al
    355f:	add    BYTE PTR [rsi],al
    3561:	add    BYTE PTR [rax],al
    3563:	add    BYTE PTR [rax],al
    3565:	add    BYTE PTR [rax],al
	...

0000000000003568 <botlish_entry_16: scan_label<generic>>:
    3568:	push   rbp
    3569:	mov    rbp,rsp
    356c:	mov    rdx,QWORD PTR [rdx]
    356f:	call   3574 <botlish_entry_16+0xc>
			3570: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_label<generic>
    3574:	mov    rsp,rbp
    3577:	pop    rbp
    3578:	ret
    3579:	add    BYTE PTR [rax],al
    357b:	add    BYTE PTR [rax],al
    357d:	add    BYTE PTR [rax],al
	...

0000000000003580 <botlish_fn_17: scan_alpha<generic>>:
    3580:	push   rbp
    3581:	mov    rbp,rsp
    3584:	sub    rsp,0x40
    3588:	mov    QWORD PTR [rsp+0x20],rbx
    358d:	mov    QWORD PTR [rsp+0x28],r12
    3592:	mov    QWORD PTR [rsp+0x30],r13
    3597:	mov    QWORD PTR [rsp+0x38],r14
    359c:	mov    r12,QWORD PTR [rdi]
    359f:	mov    rax,QWORD PTR [rdi+0x8]
    35a3:	lea    rcx,[r12+0x8]
    35a8:	cmp    rcx,rax
    35ab:	ja     3784 <botlish_fn_17+0x204>
    35b1:	lea    rax,[r12+0x8]
    35b6:	mov    QWORD PTR [rdi],rax
    35b9:	mov    r13,rdi
    35bc:	mov    QWORD PTR [r12],0x0
    35c4:	mov    QWORD PTR [rsp+0x10],0x0
    35cd:	mov    QWORD PTR [rsp],rdx
    35d1:	mov    rbx,rsi
    35d4:	mov    rsi,rdx
    35d7:	mov    rax,QWORD PTR [rbx+0x20]
    35db:	mov    rdx,QWORD PTR [rax]
    35de:	mov    ecx,0x1
    35e3:	test   rsi,0x1
    35ea:	jne    3608 <botlish_fn_17+0x88>
    35f0:	xor    ecx,ecx
    35f2:	test   rsi,0x7
    35f9:	jne    3608 <botlish_fn_17+0x88>
    35ff:	movzx  rax,BYTE PTR [rsi]
    3603:	cmp    al,0x1
    3605:	sete   cl
    3608:	test   cl,cl
    360a:	jne    362e <botlish_fn_17+0xae>
    3610:	mov    rdi,r13
    3613:	mov    rax,QWORD PTR [rdi+0x10]
    3617:	mov    rcx,QWORD PTR [rax+0xb8]
    361e:	xor    rdx,rdx
    3621:	call   3626 <botlish_fn_17+0xa6>
			3622: R_X86_64_PLT32	rt_type_error-0x4
    3626:	mov    rdi,r13
    3629:	jmp    36c0 <botlish_fn_17+0x140>
    362e:	mov    rax,rsi
    3631:	and    rax,rdx
    3634:	mov    r14,rsi
    3637:	test   rax,0x1
    363d:	jne    3663 <botlish_fn_17+0xe3>
    3643:	mov    rsi,r14
    3646:	mov    rdi,r13
    3649:	call   364e <botlish_fn_17+0xce>
			364a: R_X86_64_PLT32	rt_int_cmp-0x4
    364e:	mov    ecx,0x2
    3653:	test   rax,rax
    3656:	cmovge rcx,QWORD PTR [rip+0x152]        # 37b0 <botlish_fn_17+0x230>
    365e:	jmp    3676 <botlish_fn_17+0xf6>
    3663:	mov    ecx,0x2
    3668:	mov    rsi,r14
    366b:	cmp    rsi,rdx
    366e:	cmovge rcx,QWORD PTR [rip+0x13a]        # 37b0 <botlish_fn_17+0x230>
    3676:	cmp    rcx,0x6
    367a:	je     375b <botlish_fn_17+0x1db>
    3680:	mov    rsi,QWORD PTR [rbx+0x20]
    3684:	mov    rsi,QWORD PTR [rsi+0x8]
    3688:	mov    QWORD PTR [rsp+0x8],rsi
    368d:	mov    rdx,r14
    3690:	mov    rdi,r13
    3693:	call   3698 <botlish_fn_17+0x118>
			3694: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    3698:	test   rax,rax
    369b:	mov    rsi,rax
    369e:	jne    36ac <botlish_fn_17+0x12c>
    36a4:	mov    rdi,r13
    36a7:	jmp    36c0 <botlish_fn_17+0x140>
    36ac:	mov    rdi,r13
    36af:	call   36b4 <botlish_fn_17+0x134>
			36b0: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    36b4:	test   rax,rax
    36b7:	jne    36e6 <botlish_fn_17+0x166>
    36bd:	mov    rdi,r13
    36c0:	mov    rdi,r13
    36c3:	mov    QWORD PTR [rdi],r12
    36c6:	xor    rax,rax
    36c9:	mov    rbx,QWORD PTR [rsp+0x20]
    36ce:	mov    r12,QWORD PTR [rsp+0x28]
    36d3:	mov    r13,QWORD PTR [rsp+0x30]
    36d8:	mov    r14,QWORD PTR [rsp+0x38]
    36dd:	add    rsp,0x40
    36e1:	mov    rsp,rbp
    36e4:	pop    rbp
    36e5:	ret
    36e6:	cmp    rax,0x6
    36ea:	je     36fb <botlish_fn_17+0x17b>
    36f0:	mov    rax,r14
    36f3:	mov    rdi,r13
    36f6:	jmp    3761 <botlish_fn_17+0x1e1>
    36fb:	mov    QWORD PTR [rsp+0x8],rbx
    3700:	mov    QWORD PTR [rsp+0x10],0x3
    3709:	mov    rsi,r14
    370c:	test   rsi,0x1
    3713:	je     3739 <botlish_fn_17+0x1b9>
    3719:	mov    rsi,r14
    371c:	mov    rcx,rsi
    371f:	add    rcx,0x2
    3723:	seto   al
    3726:	test   al,al
    3728:	jne    3739 <botlish_fn_17+0x1b9>
    372e:	mov    rsi,rcx
    3731:	mov    r14,rcx
    3734:	jmp    374f <botlish_fn_17+0x1cf>
    3739:	mov    edx,0x3
    373e:	mov    rsi,r14
    3741:	mov    rdi,r13
    3744:	call   3749 <botlish_fn_17+0x1c9>
			3745: R_X86_64_PLT32	rt_int_add-0x4
    3749:	mov    rsi,rax
    374c:	mov    r14,rax
    374f:	mov    QWORD PTR [rsp],rsi
    3753:	mov    rsi,r14
    3756:	jmp    35d7 <botlish_fn_17+0x57>
    375b:	mov    rax,r14
    375e:	mov    rdi,r13
    3761:	mov    rdi,r13
    3764:	mov    QWORD PTR [rdi],r12
    3767:	mov    rbx,QWORD PTR [rsp+0x20]
    376c:	mov    r12,QWORD PTR [rsp+0x28]
    3771:	mov    r13,QWORD PTR [rsp+0x30]
    3776:	mov    r14,QWORD PTR [rsp+0x38]
    377b:	add    rsp,0x40
    377f:	mov    rsp,rbp
    3782:	pop    rbp
    3783:	ret
    3784:	mov    r13,rdi
    3787:	call   378c <botlish_fn_17+0x20c>
			3788: R_X86_64_PLT32	rt_stack_overflow-0x4
    378c:	xor    rax,rax
    378f:	mov    rbx,QWORD PTR [rsp+0x20]
    3794:	mov    r12,QWORD PTR [rsp+0x28]
    3799:	mov    r13,QWORD PTR [rsp+0x30]
    379e:	mov    r14,QWORD PTR [rsp+0x38]
    37a3:	add    rsp,0x40
    37a7:	mov    rsp,rbp
    37aa:	pop    rbp
    37ab:	ret
    37ac:	add    BYTE PTR [rax],al
    37ae:	add    BYTE PTR [rax],al
    37b0:	(bad)
    37b1:	add    BYTE PTR [rax],al
    37b3:	add    BYTE PTR [rax],al
    37b5:	add    BYTE PTR [rax],al
	...

00000000000037b8 <botlish_entry_17: scan_alpha<generic>>:
    37b8:	push   rbp
    37b9:	mov    rbp,rsp
    37bc:	mov    rdx,QWORD PTR [rdx]
    37bf:	call   37c4 <botlish_entry_17+0xc>
			37c0: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_alpha<generic>
    37c4:	mov    rsp,rbp
    37c7:	pop    rbp
    37c8:	ret
    37c9:	add    BYTE PTR [rax],al
    37cb:	add    BYTE PTR [rax],al
    37cd:	add    BYTE PTR [rax],al
	...

00000000000037d0 <botlish_fn_18: tld_ok<generic>>:
    37d0:	push   rbp
    37d1:	mov    rbp,rsp
    37d4:	sub    rsp,0x40
    37d8:	mov    QWORD PTR [rsp+0x10],rbx
    37dd:	mov    QWORD PTR [rsp+0x18],r12
    37e2:	mov    QWORD PTR [rsp+0x20],r13
    37e7:	mov    QWORD PTR [rsp+0x28],r14
    37ec:	mov    QWORD PTR [rsp+0x30],r15
    37f1:	mov    rbx,QWORD PTR [rdi]
    37f4:	mov    rax,QWORD PTR [rdi+0x8]
    37f8:	lea    rcx,[rbx+0x8]
    37fc:	cmp    rcx,rax
    37ff:	ja     3a10 <botlish_fn_18+0x240>
    3805:	lea    rax,[rbx+0x8]
    3809:	mov    QWORD PTR [rdi],rax
    380c:	mov    r13,rdi
    380f:	mov    QWORD PTR [rbx],0x0
    3816:	mov    QWORD PTR [rsp],rdx
    381a:	mov    r8,rdx
    381d:	mov    rax,QWORD PTR [rsi+0x20]
    3821:	mov    r15,rsi
    3824:	mov    rsi,QWORD PTR [rax]
    3827:	mov    QWORD PTR [rsp+0x8],rsi
    382c:	mov    r12,r8
    382f:	mov    rdx,r12
    3832:	mov    rdi,r13
    3835:	call   383a <botlish_fn_18+0x6a>
			3836: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_alpha<generic>
    383a:	mov    rcx,rax
    383d:	mov    r14,rax
    3840:	test   rax,rcx
    3843:	jne    3851 <botlish_fn_18+0x81>
    3849:	mov    rdi,r13
    384c:	jmp    392a <botlish_fn_18+0x15a>
    3851:	mov    rax,r14
    3854:	mov    QWORD PTR [rsp+0x8],rax
    3859:	mov    rsi,r15
    385c:	mov    rax,QWORD PTR [rsi+0x20]
    3860:	mov    rdx,QWORD PTR [rax+0x8]
    3864:	mov    rax,r14
    3867:	and    rax,rdx
    386a:	test   rax,0x1
    3870:	jne    3899 <botlish_fn_18+0xc9>
    3876:	mov    rsi,r14
    3879:	mov    rdi,r13
    387c:	call   3881 <botlish_fn_18+0xb1>
			387d: R_X86_64_PLT32	rt_int_cmp-0x4
    3881:	mov    ecx,0x2
    3886:	test   rax,rax
    3889:	cmove  rcx,QWORD PTR [rip+0x1af]        # 3a40 <botlish_fn_18+0x270>
    3891:	mov    rax,r14
    3894:	jmp    38ac <botlish_fn_18+0xdc>
    3899:	mov    ecx,0x2
    389e:	mov    rax,r14
    38a1:	cmp    rax,rdx
    38a4:	cmove  rcx,QWORD PTR [rip+0x194]        # 3a40 <botlish_fn_18+0x270>
    38ac:	cmp    rcx,0x6
    38b0:	je     38c6 <botlish_fn_18+0xf6>
    38b6:	mov    ecx,0x2
    38bb:	mov    rax,rcx
    38be:	mov    rdi,r13
    38c1:	jmp    39e8 <botlish_fn_18+0x218>
    38c6:	mov    ecx,0x1
    38cb:	test   r12,0x1
    38d2:	je     38e0 <botlish_fn_18+0x110>
    38d8:	mov    r8,r12
    38db:	jmp    3906 <botlish_fn_18+0x136>
    38e0:	xor    ecx,ecx
    38e2:	test   r12,0x7
    38e9:	je     38f7 <botlish_fn_18+0x127>
    38ef:	mov    r8,r12
    38f2:	jmp    3906 <botlish_fn_18+0x136>
    38f7:	movzx  rcx,BYTE PTR [r12]
    38fc:	mov    r8,r12
    38ff:	rex cmp cl,0x1
    3903:	sete   cl
    3906:	test   cl,cl
    3908:	jne    3955 <botlish_fn_18+0x185>
    390e:	mov    rdi,r13
    3911:	mov    rax,QWORD PTR [rdi+0x10]
    3915:	mov    rcx,QWORD PTR [rax+0x128]
    391c:	xor    rdx,rdx
    391f:	mov    rsi,r8
    3922:	call   3927 <botlish_fn_18+0x157>
			3923: R_X86_64_PLT32	rt_type_error-0x4
    3927:	mov    rdi,r13
    392a:	mov    rdi,r13
    392d:	mov    QWORD PTR [rdi],rbx
    3930:	xor    rax,rax
    3933:	mov    rbx,QWORD PTR [rsp+0x10]
    3938:	mov    r12,QWORD PTR [rsp+0x18]
    393d:	mov    r13,QWORD PTR [rsp+0x20]
    3942:	mov    r14,QWORD PTR [rsp+0x28]
    3947:	mov    r15,QWORD PTR [rsp+0x30]
    394c:	add    rsp,0x40
    3950:	mov    rsp,rbp
    3953:	pop    rbp
    3954:	ret
    3955:	mov    r12,r8
    3958:	mov    rcx,rax
    395b:	and    rcx,r12
    395e:	test   rcx,0x1
    3965:	jne    3976 <botlish_fn_18+0x1a6>
    396b:	mov    rdx,r8
    396e:	mov    rsi,rax
    3971:	jmp    3997 <botlish_fn_18+0x1c7>
    3976:	mov    r12,r8
    3979:	mov    rcx,rax
    397c:	sub    rcx,r12
    397f:	mov    r14,rax
    3982:	seto   al
    3985:	lea    rsi,[rcx+0x1]
    3989:	test   al,al
    398b:	je     39a2 <botlish_fn_18+0x1d2>
    3991:	mov    rdx,r8
    3994:	mov    rsi,r14
    3997:	mov    rdi,r13
    399a:	call   399f <botlish_fn_18+0x1cf>
			399b: R_X86_64_PLT32	rt_int_sub-0x4
    399f:	mov    rsi,rax
    39a2:	test   rsi,0x1
    39a9:	jne    39d4 <botlish_fn_18+0x204>
    39af:	mov    edx,0x5
    39b4:	mov    rdi,r13
    39b7:	call   39bc <botlish_fn_18+0x1ec>
			39b8: R_X86_64_PLT32	rt_int_cmp-0x4
    39bc:	mov    ecx,0x2
    39c1:	test   rax,rax
    39c4:	mov    rax,rcx
    39c7:	cmovge rax,QWORD PTR [rip+0x71]        # 3a40 <botlish_fn_18+0x270>
    39cf:	jmp    39e5 <botlish_fn_18+0x215>
    39d4:	mov    eax,0x2
    39d9:	cmp    rsi,0x5
    39dd:	cmovge rax,QWORD PTR [rip+0x5b]        # 3a40 <botlish_fn_18+0x270>
    39e5:	mov    rdi,r13
    39e8:	mov    rdi,r13
    39eb:	mov    QWORD PTR [rdi],rbx
    39ee:	mov    rbx,QWORD PTR [rsp+0x10]
    39f3:	mov    r12,QWORD PTR [rsp+0x18]
    39f8:	mov    r13,QWORD PTR [rsp+0x20]
    39fd:	mov    r14,QWORD PTR [rsp+0x28]
    3a02:	mov    r15,QWORD PTR [rsp+0x30]
    3a07:	add    rsp,0x40
    3a0b:	mov    rsp,rbp
    3a0e:	pop    rbp
    3a0f:	ret
    3a10:	mov    r13,rdi
    3a13:	call   3a18 <botlish_fn_18+0x248>
			3a14: R_X86_64_PLT32	rt_stack_overflow-0x4
    3a18:	xor    rax,rax
    3a1b:	mov    rbx,QWORD PTR [rsp+0x10]
    3a20:	mov    r12,QWORD PTR [rsp+0x18]
    3a25:	mov    r13,QWORD PTR [rsp+0x20]
    3a2a:	mov    r14,QWORD PTR [rsp+0x28]
    3a2f:	mov    r15,QWORD PTR [rsp+0x30]
    3a34:	add    rsp,0x40
    3a38:	mov    rsp,rbp
    3a3b:	pop    rbp
    3a3c:	ret
    3a3d:	add    BYTE PTR [rax],al
    3a3f:	add    BYTE PTR [rsi],al
    3a41:	add    BYTE PTR [rax],al
    3a43:	add    BYTE PTR [rax],al
    3a45:	add    BYTE PTR [rax],al
	...

0000000000003a48 <botlish_entry_18: tld_ok<generic>>:
    3a48:	push   rbp
    3a49:	mov    rbp,rsp
    3a4c:	mov    rdx,QWORD PTR [rdx]
    3a4f:	call   3a54 <botlish_entry_18+0xc>
			3a50: R_X86_64_PLT32	botlish_fn_18-0x4 ; tld_ok<generic>
    3a54:	mov    rsp,rbp
    3a57:	pop    rbp
    3a58:	ret
    3a59:	add    BYTE PTR [rax],al
    3a5b:	add    BYTE PTR [rax],al
    3a5d:	add    BYTE PTR [rax],al
	...

0000000000003a60 <botlish_fn_19: domain_loop<generic>>:
    3a60:	push   rbp
    3a61:	mov    rbp,rsp
    3a64:	sub    rsp,0x60
    3a68:	mov    QWORD PTR [rsp+0x30],rbx
    3a6d:	mov    QWORD PTR [rsp+0x38],r12
    3a72:	mov    QWORD PTR [rsp+0x40],r13
    3a77:	mov    QWORD PTR [rsp+0x48],r14
    3a7c:	mov    QWORD PTR [rsp+0x50],r15
    3a81:	mov    r13,QWORD PTR [rdi]
    3a84:	mov    rax,QWORD PTR [rdi+0x8]
    3a88:	lea    rcx,[r13+0x8]
    3a8c:	cmp    rcx,rax
    3a8f:	ja     3d0c <botlish_fn_19+0x2ac>
    3a95:	lea    rax,[r13+0x8]
    3a99:	mov    QWORD PTR [rdi],rax
    3a9c:	mov    r15,rdi
    3a9f:	mov    QWORD PTR [r13+0x0],0x0
    3aa7:	mov    QWORD PTR [rsp],rdx
    3aab:	mov    QWORD PTR [rsp+0x20],rdx
    3ab0:	lea    rbx,[rsp+0x10]
    3ab5:	mov    r12,rsi
    3ab8:	mov    rax,QWORD PTR [r12+0x20]
    3abd:	mov    rsi,QWORD PTR [rax]
    3ac0:	mov    QWORD PTR [rsp+0x8],rsi
    3ac5:	mov    rdx,QWORD PTR [rsp+0x20]
    3aca:	mov    rdi,r15
    3acd:	call   3ad2 <botlish_fn_19+0x72>
			3ace: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_label<generic>
    3ad2:	mov    rcx,rax
    3ad5:	mov    r14,rax
    3ad8:	test   rax,rcx
    3adb:	jne    3ae9 <botlish_fn_19+0x89>
    3ae1:	mov    rdi,r15
    3ae4:	jmp    3c7a <botlish_fn_19+0x21a>
    3ae9:	mov    rax,r14
    3aec:	mov    QWORD PTR [rsp],rax
    3af0:	mov    rdx,QWORD PTR [rsp+0x20]
    3af5:	mov    rsi,rax
    3af8:	and    rsi,rdx
    3afb:	test   rsi,0x1
    3b02:	jne    3b29 <botlish_fn_19+0xc9>
    3b08:	mov    rdx,QWORD PTR [rsp+0x20]
    3b0d:	mov    rsi,r14
    3b10:	mov    rdi,r15
    3b13:	call   3b18 <botlish_fn_19+0xb8>
			3b14: R_X86_64_PLT32	rt_value_eq-0x4
    3b18:	test   rax,rax
    3b1b:	jne    3b3e <botlish_fn_19+0xde>
    3b21:	mov    rdi,r15
    3b24:	jmp    3c7a <botlish_fn_19+0x21a>
    3b29:	mov    eax,0x2
    3b2e:	mov    rdx,QWORD PTR [rsp+0x20]
    3b33:	cmp    r14,rdx
    3b36:	cmove  rax,QWORD PTR [rip+0x202]        # 3d40 <botlish_fn_19+0x2e0>
    3b3e:	cmp    rax,0x6
    3b42:	je     3cda <botlish_fn_19+0x27a>
    3b48:	mov    rax,QWORD PTR [r12+0x20]
    3b4d:	mov    rdx,QWORD PTR [rax+0x8]
    3b51:	mov    rax,r14
    3b54:	and    rax,rdx
    3b57:	test   rax,0x1
    3b5d:	jne    3b83 <botlish_fn_19+0x123>
    3b63:	mov    rsi,r14
    3b66:	mov    rdi,r15
    3b69:	call   3b6e <botlish_fn_19+0x10e>
			3b6a: R_X86_64_PLT32	rt_int_cmp-0x4
    3b6e:	mov    ecx,0x2
    3b73:	test   rax,rax
    3b76:	cmovge rcx,QWORD PTR [rip+0x1c2]        # 3d40 <botlish_fn_19+0x2e0>
    3b7e:	jmp    3b93 <botlish_fn_19+0x133>
    3b83:	mov    ecx,0x2
    3b88:	cmp    r14,rdx
    3b8b:	cmovge rcx,QWORD PTR [rip+0x1ad]        # 3d40 <botlish_fn_19+0x2e0>
    3b93:	cmp    rcx,0x6
    3b97:	je     3ccb <botlish_fn_19+0x26b>
    3b9d:	mov    rax,QWORD PTR [r12+0x20]
    3ba2:	mov    rsi,QWORD PTR [rax+0x10]
    3ba6:	mov    QWORD PTR [rsp+0x8],rsi
    3bab:	mov    rcx,rbx
    3bae:	mov    rdx,r14
    3bb1:	mov    rdi,r15
    3bb4:	call   3bb9 <botlish_fn_19+0x159>
			3bb5: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    3bb9:	test   rax,rax
    3bbc:	mov    rsi,rax
    3bbf:	jne    3bcd <botlish_fn_19+0x16d>
    3bc5:	mov    rdi,r15
    3bc8:	jmp    3c7a <botlish_fn_19+0x21a>
    3bcd:	mov    rdx,QWORD PTR [rsp+0x10]
    3bd2:	mov    rcx,QWORD PTR [rsp+0x18]
    3bd7:	mov    rdi,r15
    3bda:	mov    rax,QWORD PTR [rdi+0x10]
    3bde:	mov    r8,QWORD PTR [rax+0x118]
    3be5:	call   3bea <botlish_fn_19+0x18a>
			3be6: R_X86_64_PLT32	rt_str_region_eq-0x4
    3bea:	cmp    rax,0x6
    3bee:	je     3c00 <botlish_fn_19+0x1a0>
    3bf4:	mov    rax,0xffffffffffffffff
    3bfb:	jmp    3cd2 <botlish_fn_19+0x272>
    3c00:	mov    QWORD PTR [rsp+0x8],0x3
    3c09:	test   r14,0x1
    3c10:	je     3c37 <botlish_fn_19+0x1d7>
    3c16:	mov    rdx,r14
    3c19:	add    rdx,0x2
    3c1d:	mov    QWORD PTR [rsp+0x20],rdx
    3c22:	seto   al
    3c25:	test   al,al
    3c27:	jne    3c37 <botlish_fn_19+0x1d7>
    3c2d:	mov    rdx,QWORD PTR [rsp+0x20]
    3c32:	jmp    3c4f <botlish_fn_19+0x1ef>
    3c37:	mov    edx,0x3
    3c3c:	mov    rsi,r14
    3c3f:	mov    rdi,r15
    3c42:	call   3c47 <botlish_fn_19+0x1e7>
			3c43: R_X86_64_PLT32	rt_int_add-0x4
    3c47:	mov    rdx,rax
    3c4a:	mov    QWORD PTR [rsp+0x20],rax
    3c4f:	mov    QWORD PTR [rsp],rdx
    3c53:	mov    rax,QWORD PTR [r12+0x20]
    3c58:	mov    rsi,QWORD PTR [rax+0x18]
    3c5c:	mov    QWORD PTR [rsp+0x8],rsi
    3c61:	mov    rdx,QWORD PTR [rsp+0x20]
    3c66:	mov    rdi,r15
    3c69:	call   3c6e <botlish_fn_19+0x20e>
			3c6a: R_X86_64_PLT32	botlish_fn_18-0x4 ; tld_ok<generic>
    3c6e:	test   rax,rax
    3c71:	jne    3ca5 <botlish_fn_19+0x245>
    3c77:	mov    rdi,r15
    3c7a:	mov    rdi,r15
    3c7d:	mov    QWORD PTR [rdi],r13
    3c80:	xor    rax,rax
    3c83:	mov    rbx,QWORD PTR [rsp+0x30]
    3c88:	mov    r12,QWORD PTR [rsp+0x38]
    3c8d:	mov    r13,QWORD PTR [rsp+0x40]
    3c92:	mov    r14,QWORD PTR [rsp+0x48]
    3c97:	mov    r15,QWORD PTR [rsp+0x50]
    3c9c:	add    rsp,0x60
    3ca0:	mov    rsp,rbp
    3ca3:	pop    rbp
    3ca4:	ret
    3ca5:	cmp    rax,0x6
    3ca9:	je     3cbd <botlish_fn_19+0x25d>
    3caf:	mov    rdx,QWORD PTR [rsp+0x20]
    3cb4:	mov    QWORD PTR [rsp],rdx
    3cb8:	jmp    3ab8 <botlish_fn_19+0x58>
    3cbd:	mov    rax,QWORD PTR [r12+0x20]
    3cc2:	mov    rax,QWORD PTR [rax+0x8]
    3cc6:	jmp    3cd2 <botlish_fn_19+0x272>
    3ccb:	mov    rax,0xffffffffffffffff
    3cd2:	mov    rdi,r15
    3cd5:	jmp    3ce4 <botlish_fn_19+0x284>
    3cda:	mov    rax,0xffffffffffffffff
    3ce1:	mov    rdi,r15
    3ce4:	mov    rdi,r15
    3ce7:	mov    QWORD PTR [rdi],r13
    3cea:	mov    rbx,QWORD PTR [rsp+0x30]
    3cef:	mov    r12,QWORD PTR [rsp+0x38]
    3cf4:	mov    r13,QWORD PTR [rsp+0x40]
    3cf9:	mov    r14,QWORD PTR [rsp+0x48]
    3cfe:	mov    r15,QWORD PTR [rsp+0x50]
    3d03:	add    rsp,0x60
    3d07:	mov    rsp,rbp
    3d0a:	pop    rbp
    3d0b:	ret
    3d0c:	mov    r15,rdi
    3d0f:	call   3d14 <botlish_fn_19+0x2b4>
			3d10: R_X86_64_PLT32	rt_stack_overflow-0x4
    3d14:	xor    rax,rax
    3d17:	mov    rbx,QWORD PTR [rsp+0x30]
    3d1c:	mov    r12,QWORD PTR [rsp+0x38]
    3d21:	mov    r13,QWORD PTR [rsp+0x40]
    3d26:	mov    r14,QWORD PTR [rsp+0x48]
    3d2b:	mov    r15,QWORD PTR [rsp+0x50]
    3d30:	add    rsp,0x60
    3d34:	mov    rsp,rbp
    3d37:	pop    rbp
    3d38:	ret
    3d39:	add    BYTE PTR [rax],al
    3d3b:	add    BYTE PTR [rax],al
    3d3d:	add    BYTE PTR [rax],al
    3d3f:	add    BYTE PTR [rsi],al
    3d41:	add    BYTE PTR [rax],al
    3d43:	add    BYTE PTR [rax],al
    3d45:	add    BYTE PTR [rax],al
	...

0000000000003d48 <botlish_entry_19: domain_loop<generic>>:
    3d48:	push   rbp
    3d49:	mov    rbp,rsp
    3d4c:	mov    rdx,QWORD PTR [rdx]
    3d4f:	call   3d54 <botlish_entry_19+0xc>
			3d50: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    3d54:	mov    rsp,rbp
    3d57:	pop    rbp
    3d58:	ret
    3d59:	add    BYTE PTR [rax],al
    3d5b:	add    BYTE PTR [rax],al
    3d5d:	add    BYTE PTR [rax],al
	...

0000000000003d60 <botlish_fn_20: <str>>:
    3d60:	push   rbp
    3d61:	mov    rbp,rsp
    3d64:	sub    rsp,0xf0
    3d6b:	mov    QWORD PTR [rsp+0xc0],rbx
    3d73:	mov    QWORD PTR [rsp+0xc8],r12
    3d7b:	mov    QWORD PTR [rsp+0xd0],r13
    3d83:	mov    QWORD PTR [rsp+0xd8],r14
    3d8b:	mov    QWORD PTR [rsp+0xe0],r15
    3d93:	mov    rbx,QWORD PTR [rdi]
    3d96:	mov    rax,QWORD PTR [rdi+0x8]
    3d9a:	lea    rcx,[rbx+0x8]
    3d9e:	cmp    rcx,rax
    3da1:	ja     4251 <botlish_fn_20+0x4f1>
    3da7:	lea    rax,[rbx+0x8]
    3dab:	mov    QWORD PTR [rdi],rax
    3dae:	mov    QWORD PTR [rsp+0xa0],rdi
    3db6:	mov    QWORD PTR [rbx],0x0
    3dbd:	mov    QWORD PTR [rsp+0x10],0x0
    3dc6:	mov    QWORD PTR [rsp+0x18],0x0
    3dcf:	mov    QWORD PTR [rsp+0x20],0x0
    3dd8:	mov    QWORD PTR [rsp],rsi
    3ddc:	mov    r12,rsi
    3ddf:	mov    rsi,r12
    3de2:	mov    rdi,QWORD PTR [rsp+0xa0]
    3dea:	call   3def <botlish_fn_20+0x8f>
			3deb: R_X86_64_PLT32	rt_str_len-0x4
    3def:	mov    QWORD PTR [rsp+0xb0],rax
    3df7:	mov    QWORD PTR [rsp+0x8],rax
    3dfc:	lea    r8,[rsp+0x28]
    3e01:	mov    QWORD PTR [rsp+0x28],r12
    3e06:	mov    esi,0x16
    3e0b:	mov    rdx,QWORD PTR [rip+0x0]        # 3e12 <botlish_fn_20+0xb2>
			3e0e: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; char_at<generic>
    3e12:	mov    r12d,0x1
    3e18:	mov    rcx,r12
    3e1b:	mov    rdi,QWORD PTR [rsp+0xa0]
    3e23:	call   3e28 <botlish_fn_20+0xc8>
			3e24: R_X86_64_PLT32	rt_closure_new-0x4
    3e28:	mov    r15,rax
    3e2b:	mov    QWORD PTR [rsp],rax
    3e2f:	lea    r8,[rsp+0x30]
    3e34:	mov    rax,QWORD PTR [rsp+0xb0]
    3e3c:	mov    QWORD PTR [rsp+0x30],rax
    3e41:	mov    rax,r15
    3e44:	mov    QWORD PTR [rsp+0x38],rax
    3e49:	mov    esi,0x1a
    3e4e:	mov    rdx,QWORD PTR [rip+0x0]        # 3e55 <botlish_fn_20+0xf5>
			3e51: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; scan_local<generic>
    3e55:	mov    r14d,0x2
    3e5b:	mov    rcx,r14
    3e5e:	mov    rdi,QWORD PTR [rsp+0xa0]
    3e66:	call   3e6b <botlish_fn_20+0x10b>
			3e67: R_X86_64_PLT32	rt_closure_new-0x4
    3e6b:	mov    r13,rax
    3e6e:	mov    QWORD PTR [rsp+0x10],r13
    3e73:	lea    r8,[rsp+0x40]
    3e78:	mov    rax,QWORD PTR [rsp+0xb0]
    3e80:	mov    QWORD PTR [rsp+0x40],rax
    3e85:	mov    rax,r15
    3e88:	mov    QWORD PTR [rsp+0x48],rax
    3e8d:	mov    esi,0x1b
    3e92:	mov    rdx,QWORD PTR [rip+0x0]        # 3e99 <botlish_fn_20+0x139>
			3e95: R_X86_64_GOTPCREL	botlish_entry_27-0x4 ; scan_label<generic>
    3e99:	mov    rcx,r14
    3e9c:	mov    rdi,QWORD PTR [rsp+0xa0]
    3ea4:	call   3ea9 <botlish_fn_20+0x149>
			3ea5: R_X86_64_PLT32	rt_closure_new-0x4
    3ea9:	mov    QWORD PTR [rsp+0x18],rax
    3eae:	mov    QWORD PTR [rsp+0xa8],rax
    3eb6:	lea    r8,[rsp+0x50]
    3ebb:	mov    rax,QWORD PTR [rsp+0xb0]
    3ec3:	mov    QWORD PTR [rsp+0x50],rax
    3ec8:	mov    QWORD PTR [rsp+0x58],r15
    3ecd:	mov    esi,0x1c
    3ed2:	mov    rdx,QWORD PTR [rip+0x0]        # 3ed9 <botlish_fn_20+0x179>
			3ed5: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; scan_alpha<generic>
    3ed9:	mov    rcx,r14
    3edc:	mov    rdi,QWORD PTR [rsp+0xa0]
    3ee4:	call   3ee9 <botlish_fn_20+0x189>
			3ee5: R_X86_64_PLT32	rt_closure_new-0x4
    3ee9:	mov    QWORD PTR [rsp+0x20],rax
    3eee:	lea    r8,[rsp+0x60]
    3ef3:	mov    QWORD PTR [rsp+0x60],rax
    3ef8:	mov    rax,QWORD PTR [rsp+0xb0]
    3f00:	mov    QWORD PTR [rsp+0x68],rax
    3f05:	mov    esi,0x1d
    3f0a:	mov    rdx,QWORD PTR [rip+0x0]        # 3f11 <botlish_fn_20+0x1b1>
			3f0d: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; tld_ok<generic>
    3f11:	mov    rcx,r14
    3f14:	mov    rdi,QWORD PTR [rsp+0xa0]
    3f1c:	call   3f21 <botlish_fn_20+0x1c1>
			3f1d: R_X86_64_PLT32	rt_closure_new-0x4
    3f21:	mov    QWORD PTR [rsp+0x20],rax
    3f26:	lea    r8,[rsp+0x70]
    3f2b:	mov    rcx,QWORD PTR [rsp+0xa8]
    3f33:	mov    QWORD PTR [rsp+0x70],rcx
    3f38:	mov    rcx,QWORD PTR [rsp+0xb0]
    3f40:	mov    QWORD PTR [rsp+0x78],rcx
    3f45:	mov    QWORD PTR [rsp+0x80],r15
    3f4d:	mov    QWORD PTR [rsp+0x88],rax
    3f55:	mov    esi,0x1e
    3f5a:	mov    rdx,QWORD PTR [rip+0x0]        # 3f61 <botlish_fn_20+0x201>
			3f5d: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; domain_loop<generic>
    3f61:	mov    ecx,0x4
    3f66:	mov    rdi,QWORD PTR [rsp+0xa0]
    3f6e:	call   3f73 <botlish_fn_20+0x213>
			3f6f: R_X86_64_PLT32	rt_closure_new-0x4
    3f73:	mov    QWORD PTR [rsp+0x18],rax
    3f78:	mov    r14,rax
    3f7b:	mov    QWORD PTR [rsp+0x20],0x1
    3f84:	mov    rdx,r12
    3f87:	mov    rsi,r13
    3f8a:	mov    rdi,QWORD PTR [rsp+0xa0]
    3f92:	call   3f97 <botlish_fn_20+0x237>
			3f93: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    3f97:	mov    rcx,rax
    3f9a:	mov    r13,rax
    3f9d:	test   rax,rcx
    3fa0:	jne    3fb3 <botlish_fn_20+0x253>
    3fa6:	mov    rdi,QWORD PTR [rsp+0xa0]
    3fae:	jmp    4149 <botlish_fn_20+0x3e9>
    3fb3:	mov    rax,r13
    3fb6:	mov    QWORD PTR [rsp+0x10],rax
    3fbb:	test   rax,0x1
    3fc1:	jne    3ff2 <botlish_fn_20+0x292>
    3fc7:	mov    edx,0x1
    3fcc:	mov    rsi,r13
    3fcf:	mov    rdi,QWORD PTR [rsp+0xa0]
    3fd7:	call   3fdc <botlish_fn_20+0x27c>
			3fd8: R_X86_64_PLT32	rt_int_cmp-0x4
    3fdc:	mov    r11d,0x2
    3fe2:	test   rax,rax
    3fe5:	cmove  r11,QWORD PTR [rip+0x2ab]        # 4298 <botlish_fn_20+0x538>
    3fed:	jmp    4004 <botlish_fn_20+0x2a4>
    3ff2:	mov    r11d,0x2
    3ff8:	cmp    r13,0x1
    3ffc:	cmove  r11,QWORD PTR [rip+0x294]        # 4298 <botlish_fn_20+0x538>
    4004:	cmp    r11,0x6
    4008:	je     4205 <botlish_fn_20+0x4a5>
    400e:	mov    r12,QWORD PTR [rsp+0xb0]
    4016:	mov    rax,r13
    4019:	and    rax,r12
    401c:	test   rax,0x1
    4022:	jne    4050 <botlish_fn_20+0x2f0>
    4028:	mov    rdx,r12
    402b:	mov    rsi,r13
    402e:	mov    rdi,QWORD PTR [rsp+0xa0]
    4036:	call   403b <botlish_fn_20+0x2db>
			4037: R_X86_64_PLT32	rt_int_cmp-0x4
    403b:	mov    ecx,0x2
    4040:	test   rax,rax
    4043:	cmovge rcx,QWORD PTR [rip+0x24d]        # 4298 <botlish_fn_20+0x538>
    404b:	jmp    4060 <botlish_fn_20+0x300>
    4050:	mov    ecx,0x2
    4055:	cmp    r13,r12
    4058:	cmovge rcx,QWORD PTR [rip+0x238]        # 4298 <botlish_fn_20+0x538>
    4060:	cmp    rcx,0x6
    4064:	je     41f3 <botlish_fn_20+0x493>
    406a:	lea    rcx,[rsp+0x90]
    4072:	mov    rsi,r15
    4075:	mov    rdx,r13
    4078:	mov    rdi,QWORD PTR [rsp+0xa0]
    4080:	call   4085 <botlish_fn_20+0x325>
			4081: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    4085:	test   rax,rax
    4088:	mov    rsi,rax
    408b:	jne    409e <botlish_fn_20+0x33e>
    4091:	mov    rdi,QWORD PTR [rsp+0xa0]
    4099:	jmp    4149 <botlish_fn_20+0x3e9>
    409e:	mov    rdx,QWORD PTR [rsp+0x90]
    40a6:	mov    rcx,QWORD PTR [rsp+0x98]
    40ae:	mov    rdi,QWORD PTR [rsp+0xa0]
    40b6:	mov    rdi,QWORD PTR [rdi+0x10]
    40ba:	mov    r8,QWORD PTR [rdi+0x100]
    40c1:	mov    rdi,QWORD PTR [rsp+0xa0]
    40c9:	call   40ce <botlish_fn_20+0x36e>
			40ca: R_X86_64_PLT32	rt_str_region_eq-0x4
    40ce:	cmp    rax,0x6
    40d2:	je     40e5 <botlish_fn_20+0x385>
    40d8:	mov    ecx,0x2
    40dd:	mov    rax,rcx
    40e0:	jmp    41f8 <botlish_fn_20+0x498>
    40e5:	mov    QWORD PTR [rsp],0x3
    40ed:	test   r13,0x1
    40f4:	je     410c <botlish_fn_20+0x3ac>
    40fa:	mov    rdx,r13
    40fd:	add    rdx,0x2
    4101:	seto   al
    4104:	test   al,al
    4106:	je     4124 <botlish_fn_20+0x3c4>
    410c:	mov    edx,0x3
    4111:	mov    rsi,r13
    4114:	mov    rdi,QWORD PTR [rsp+0xa0]
    411c:	call   4121 <botlish_fn_20+0x3c1>
			411d: R_X86_64_PLT32	rt_int_add-0x4
    4121:	mov    rdx,rax
    4124:	mov    QWORD PTR [rsp],rdx
    4128:	mov    rsi,r14
    412b:	mov    rdi,QWORD PTR [rsp+0xa0]
    4133:	call   4138 <botlish_fn_20+0x3d8>
			4134: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    4138:	test   rax,rax
    413b:	jne    418b <botlish_fn_20+0x42b>
    4141:	mov    rdi,QWORD PTR [rsp+0xa0]
    4149:	mov    rdi,QWORD PTR [rsp+0xa0]
    4151:	mov    QWORD PTR [rdi],rbx
    4154:	xor    rax,rax
    4157:	mov    rbx,QWORD PTR [rsp+0xc0]
    415f:	mov    r12,QWORD PTR [rsp+0xc8]
    4167:	mov    r13,QWORD PTR [rsp+0xd0]
    416f:	mov    r14,QWORD PTR [rsp+0xd8]
    4177:	mov    r15,QWORD PTR [rsp+0xe0]
    417f:	add    rsp,0xf0
    4186:	mov    rsp,rbp
    4189:	pop    rbp
    418a:	ret
    418b:	mov    rcx,rax
    418e:	and    rcx,r12
    4191:	mov    rsi,rax
    4194:	mov    QWORD PTR [rsp+0xb0],r12
    419c:	test   rcx,0x1
    41a3:	jne    41d6 <botlish_fn_20+0x476>
    41a9:	mov    rdx,QWORD PTR [rsp+0xb0]
    41b1:	mov    rdi,QWORD PTR [rsp+0xa0]
    41b9:	call   41be <botlish_fn_20+0x45e>
			41ba: R_X86_64_PLT32	rt_int_cmp-0x4
    41be:	mov    ecx,0x2
    41c3:	test   rax,rax
    41c6:	mov    rax,rcx
    41c9:	cmove  rax,QWORD PTR [rip+0xc7]        # 4298 <botlish_fn_20+0x538>
    41d1:	jmp    41f8 <botlish_fn_20+0x498>
    41d6:	mov    rdx,QWORD PTR [rsp+0xb0]
    41de:	mov    eax,0x2
    41e3:	cmp    rsi,rdx
    41e6:	cmove  rax,QWORD PTR [rip+0xaa]        # 4298 <botlish_fn_20+0x538>
    41ee:	jmp    41f8 <botlish_fn_20+0x498>
    41f3:	mov    eax,0x2
    41f8:	mov    rdi,QWORD PTR [rsp+0xa0]
    4200:	jmp    4212 <botlish_fn_20+0x4b2>
    4205:	mov    eax,0x2
    420a:	mov    rdi,QWORD PTR [rsp+0xa0]
    4212:	mov    rdi,QWORD PTR [rsp+0xa0]
    421a:	mov    QWORD PTR [rdi],rbx
    421d:	mov    rbx,QWORD PTR [rsp+0xc0]
    4225:	mov    r12,QWORD PTR [rsp+0xc8]
    422d:	mov    r13,QWORD PTR [rsp+0xd0]
    4235:	mov    r14,QWORD PTR [rsp+0xd8]
    423d:	mov    r15,QWORD PTR [rsp+0xe0]
    4245:	add    rsp,0xf0
    424c:	mov    rsp,rbp
    424f:	pop    rbp
    4250:	ret
    4251:	mov    QWORD PTR [rsp+0xa0],rdi
    4259:	call   425e <botlish_fn_20+0x4fe>
			425a: R_X86_64_PLT32	rt_stack_overflow-0x4
    425e:	xor    rax,rax
    4261:	mov    rbx,QWORD PTR [rsp+0xc0]
    4269:	mov    r12,QWORD PTR [rsp+0xc8]
    4271:	mov    r13,QWORD PTR [rsp+0xd0]
    4279:	mov    r14,QWORD PTR [rsp+0xd8]
    4281:	mov    r15,QWORD PTR [rsp+0xe0]
    4289:	add    rsp,0xf0
    4290:	mov    rsp,rbp
    4293:	pop    rbp
    4294:	ret
    4295:	add    BYTE PTR [rax],al
    4297:	add    BYTE PTR [rsi],al
    4299:	add    BYTE PTR [rax],al
    429b:	add    BYTE PTR [rax],al
    429d:	add    BYTE PTR [rax],al
	...

00000000000042a0 <botlish_entry_20: <str>>:
    42a0:	push   rbp
    42a1:	mov    rbp,rsp
    42a4:	mov    rsi,QWORD PTR [rdx]
    42a7:	call   42ac <botlish_entry_20+0xc>
			42a8: R_X86_64_PLT32	botlish_fn_20-0x4 ; <str>
    42ac:	mov    rsp,rbp
    42af:	pop    rbp
    42b0:	ret
    42b1:	add    BYTE PTR [rax],al
    42b3:	add    BYTE PTR [rax],al
    42b5:	add    BYTE PTR [rax],al
	...

00000000000042b8 <botlish_fn_21: <generic>>:
    42b8:	push   rbp
    42b9:	mov    rbp,rsp
    42bc:	sub    rsp,0xf0
    42c3:	mov    QWORD PTR [rsp+0xc0],rbx
    42cb:	mov    QWORD PTR [rsp+0xc8],r12
    42d3:	mov    QWORD PTR [rsp+0xd0],r13
    42db:	mov    QWORD PTR [rsp+0xd8],r14
    42e3:	mov    QWORD PTR [rsp+0xe0],r15
    42eb:	mov    rbx,QWORD PTR [rdi]
    42ee:	mov    rax,QWORD PTR [rdi+0x8]
    42f2:	lea    rcx,[rbx+0x8]
    42f6:	cmp    rcx,rax
    42f9:	ja     4780 <botlish_fn_21+0x4c8>
    42ff:	lea    rax,[rbx+0x8]
    4303:	mov    QWORD PTR [rdi],rax
    4306:	mov    QWORD PTR [rbx],0x0
    430d:	mov    QWORD PTR [rsp+0x10],0x0
    4316:	mov    QWORD PTR [rsp+0x18],0x0
    431f:	mov    QWORD PTR [rsp+0x20],0x0
    4328:	mov    QWORD PTR [rsp],rsi
    432c:	xor    eax,eax
    432e:	test   rsi,0x7
    4335:	jne    4344 <botlish_fn_21+0x8c>
    433b:	movzx  rax,BYTE PTR [rsi]
    433f:	cmp    al,0x2
    4341:	sete   al
    4344:	test   al,al
    4346:	jne    436c <botlish_fn_21+0xb4>
    434c:	mov    rax,QWORD PTR [rdi+0x10]
    4350:	mov    r15,rdi
    4353:	mov    rcx,QWORD PTR [rax+0xd8]
    435a:	mov    edx,0x1
    435f:	call   4364 <botlish_fn_21+0xac>
			4360: R_X86_64_PLT32	rt_type_error-0x4
    4364:	mov    rdi,r15
    4367:	jmp    4691 <botlish_fn_21+0x3d9>
    436c:	mov    r12,rsi
    436f:	mov    r15,rdi
    4372:	call   4377 <botlish_fn_21+0xbf>
			4373: R_X86_64_PLT32	rt_str_len-0x4
    4377:	mov    QWORD PTR [rsp+0xb0],rax
    437f:	mov    QWORD PTR [rsp+0x8],rax
    4384:	lea    r8,[rsp+0x28]
    4389:	mov    QWORD PTR [rsp+0x28],r12
    438e:	mov    esi,0x16
    4393:	mov    rdx,QWORD PTR [rip+0x0]        # 439a <botlish_fn_21+0xe2>
			4396: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; char_at<generic>
    439a:	mov    r12d,0x1
    43a0:	mov    rcx,r12
    43a3:	mov    rdi,r15
    43a6:	call   43ab <botlish_fn_21+0xf3>
			43a7: R_X86_64_PLT32	rt_closure_new-0x4
    43ab:	mov    r14,rax
    43ae:	mov    QWORD PTR [rsp+0xa8],r12
    43b6:	mov    QWORD PTR [rsp],rax
    43ba:	lea    r8,[rsp+0x30]
    43bf:	mov    rax,QWORD PTR [rsp+0xb0]
    43c7:	mov    QWORD PTR [rsp+0x30],rax
    43cc:	mov    rax,r14
    43cf:	mov    QWORD PTR [rsp+0x38],rax
    43d4:	mov    esi,0x1a
    43d9:	mov    rdx,QWORD PTR [rip+0x0]        # 43e0 <botlish_fn_21+0x128>
			43dc: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; scan_local<generic>
    43e0:	mov    r13d,0x2
    43e6:	mov    rcx,r13
    43e9:	mov    rdi,r15
    43ec:	call   43f1 <botlish_fn_21+0x139>
			43ed: R_X86_64_PLT32	rt_closure_new-0x4
    43f1:	mov    r12,rax
    43f4:	mov    QWORD PTR [rsp+0x10],r12
    43f9:	lea    r8,[rsp+0x40]
    43fe:	mov    rax,QWORD PTR [rsp+0xb0]
    4406:	mov    QWORD PTR [rsp+0x40],rax
    440b:	mov    rax,r14
    440e:	mov    QWORD PTR [rsp+0x48],rax
    4413:	mov    esi,0x1b
    4418:	mov    rdx,QWORD PTR [rip+0x0]        # 441f <botlish_fn_21+0x167>
			441b: R_X86_64_GOTPCREL	botlish_entry_27-0x4 ; scan_label<generic>
    441f:	mov    rcx,r13
    4422:	mov    rdi,r15
    4425:	call   442a <botlish_fn_21+0x172>
			4426: R_X86_64_PLT32	rt_closure_new-0x4
    442a:	mov    QWORD PTR [rsp+0x18],rax
    442f:	mov    QWORD PTR [rsp+0xa0],rax
    4437:	lea    r8,[rsp+0x50]
    443c:	mov    rax,QWORD PTR [rsp+0xb0]
    4444:	mov    QWORD PTR [rsp+0x50],rax
    4449:	mov    QWORD PTR [rsp+0x58],r14
    444e:	mov    esi,0x1c
    4453:	mov    rdx,QWORD PTR [rip+0x0]        # 445a <botlish_fn_21+0x1a2>
			4456: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; scan_alpha<generic>
    445a:	mov    rcx,r13
    445d:	mov    rdi,r15
    4460:	call   4465 <botlish_fn_21+0x1ad>
			4461: R_X86_64_PLT32	rt_closure_new-0x4
    4465:	mov    QWORD PTR [rsp+0x20],rax
    446a:	lea    r8,[rsp+0x60]
    446f:	mov    QWORD PTR [rsp+0x60],rax
    4474:	mov    rax,QWORD PTR [rsp+0xb0]
    447c:	mov    QWORD PTR [rsp+0x68],rax
    4481:	mov    esi,0x1d
    4486:	mov    rdx,QWORD PTR [rip+0x0]        # 448d <botlish_fn_21+0x1d5>
			4489: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; tld_ok<generic>
    448d:	mov    rcx,r13
    4490:	mov    rdi,r15
    4493:	call   4498 <botlish_fn_21+0x1e0>
			4494: R_X86_64_PLT32	rt_closure_new-0x4
    4498:	mov    QWORD PTR [rsp+0x20],rax
    449d:	lea    r8,[rsp+0x70]
    44a2:	mov    rsi,QWORD PTR [rsp+0xa0]
    44aa:	mov    QWORD PTR [rsp+0x70],rsi
    44af:	mov    rcx,QWORD PTR [rsp+0xb0]
    44b7:	mov    QWORD PTR [rsp+0x78],rcx
    44bc:	mov    QWORD PTR [rsp+0x80],r14
    44c4:	mov    QWORD PTR [rsp+0x88],rax
    44cc:	mov    esi,0x1e
    44d1:	mov    rdx,QWORD PTR [rip+0x0]        # 44d8 <botlish_fn_21+0x220>
			44d4: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; domain_loop<generic>
    44d8:	mov    ecx,0x4
    44dd:	mov    rdi,r15
    44e0:	call   44e5 <botlish_fn_21+0x22d>
			44e1: R_X86_64_PLT32	rt_closure_new-0x4
    44e5:	mov    QWORD PTR [rsp+0x18],rax
    44ea:	mov    QWORD PTR [rsp+0xa0],rax
    44f2:	mov    QWORD PTR [rsp+0x20],0x1
    44fb:	mov    rsi,r12
    44fe:	mov    rdx,QWORD PTR [rsp+0xa8]
    4506:	mov    rdi,r15
    4509:	call   450e <botlish_fn_21+0x256>
			450a: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    450e:	mov    rcx,rax
    4511:	mov    r12,rax
    4514:	test   rax,rcx
    4517:	jne    4525 <botlish_fn_21+0x26d>
    451d:	mov    rdi,r15
    4520:	jmp    4691 <botlish_fn_21+0x3d9>
    4525:	mov    rax,r12
    4528:	mov    QWORD PTR [rsp+0x10],rax
    452d:	test   rax,0x1
    4533:	jne    4561 <botlish_fn_21+0x2a9>
    4539:	mov    rdx,QWORD PTR [rsp+0xa8]
    4541:	mov    rsi,r12
    4544:	mov    rdi,r15
    4547:	call   454c <botlish_fn_21+0x294>
			4548: R_X86_64_PLT32	rt_int_cmp-0x4
    454c:	mov    ecx,0x2
    4551:	test   rax,rax
    4554:	cmove  rcx,QWORD PTR [rip+0x264]        # 47c0 <botlish_fn_21+0x508>
    455c:	jmp    4572 <botlish_fn_21+0x2ba>
    4561:	mov    ecx,0x2
    4566:	cmp    r12,0x1
    456a:	cmove  rcx,QWORD PTR [rip+0x24e]        # 47c0 <botlish_fn_21+0x508>
    4572:	cmp    rcx,0x6
    4576:	je     473e <botlish_fn_21+0x486>
    457c:	mov    r13,QWORD PTR [rsp+0xb0]
    4584:	mov    rax,r12
    4587:	and    rax,r13
    458a:	test   rax,0x1
    4590:	jne    45b9 <botlish_fn_21+0x301>
    4596:	mov    rdx,r13
    4599:	mov    rsi,r12
    459c:	mov    rdi,r15
    459f:	call   45a4 <botlish_fn_21+0x2ec>
			45a0: R_X86_64_PLT32	rt_int_cmp-0x4
    45a4:	mov    ecx,0x2
    45a9:	test   rax,rax
    45ac:	cmovge rcx,QWORD PTR [rip+0x20c]        # 47c0 <botlish_fn_21+0x508>
    45b4:	jmp    45c9 <botlish_fn_21+0x311>
    45b9:	mov    ecx,0x2
    45be:	cmp    r12,r13
    45c1:	cmovge rcx,QWORD PTR [rip+0x1f7]        # 47c0 <botlish_fn_21+0x508>
    45c9:	cmp    rcx,0x6
    45cd:	je     4731 <botlish_fn_21+0x479>
    45d3:	lea    rcx,[rsp+0x90]
    45db:	mov    rsi,r14
    45de:	mov    rdx,r12
    45e1:	mov    rdi,r15
    45e4:	call   45e9 <botlish_fn_21+0x331>
			45e5: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    45e9:	test   rax,rax
    45ec:	mov    rsi,rax
    45ef:	jne    45fd <botlish_fn_21+0x345>
    45f5:	mov    rdi,r15
    45f8:	jmp    4691 <botlish_fn_21+0x3d9>
    45fd:	mov    rdx,QWORD PTR [rsp+0x90]
    4605:	mov    rcx,QWORD PTR [rsp+0x98]
    460d:	mov    rdi,r15
    4610:	mov    rax,QWORD PTR [rdi+0x10]
    4614:	mov    r8,QWORD PTR [rax+0x100]
    461b:	call   4620 <botlish_fn_21+0x368>
			461c: R_X86_64_PLT32	rt_str_region_eq-0x4
    4620:	cmp    rax,0x6
    4624:	je     4637 <botlish_fn_21+0x37f>
    462a:	mov    esi,0x2
    462f:	mov    rax,rsi
    4632:	jmp    4736 <botlish_fn_21+0x47e>
    4637:	mov    QWORD PTR [rsp],0x3
    463f:	test   r12,0x1
    4646:	je     465e <botlish_fn_21+0x3a6>
    464c:	mov    rdx,r12
    464f:	add    rdx,0x2
    4653:	seto   al
    4656:	test   al,al
    4658:	je     4671 <botlish_fn_21+0x3b9>
    465e:	mov    edx,0x3
    4663:	mov    rsi,r12
    4666:	mov    rdi,r15
    4669:	call   466e <botlish_fn_21+0x3b6>
			466a: R_X86_64_PLT32	rt_int_add-0x4
    466e:	mov    rdx,rax
    4671:	mov    QWORD PTR [rsp],rdx
    4675:	mov    rsi,QWORD PTR [rsp+0xa0]
    467d:	mov    rdi,r15
    4680:	call   4685 <botlish_fn_21+0x3cd>
			4681: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    4685:	test   rax,rax
    4688:	jne    46ce <botlish_fn_21+0x416>
    468e:	mov    rdi,r15
    4691:	mov    rdi,r15
    4694:	mov    QWORD PTR [rdi],rbx
    4697:	xor    rax,rax
    469a:	mov    rbx,QWORD PTR [rsp+0xc0]
    46a2:	mov    r12,QWORD PTR [rsp+0xc8]
    46aa:	mov    r13,QWORD PTR [rsp+0xd0]
    46b2:	mov    r14,QWORD PTR [rsp+0xd8]
    46ba:	mov    r15,QWORD PTR [rsp+0xe0]
    46c2:	add    rsp,0xf0
    46c9:	mov    rsp,rbp
    46cc:	pop    rbp
    46cd:	ret
    46ce:	mov    rcx,rax
    46d1:	and    rcx,r13
    46d4:	mov    rsi,rax
    46d7:	mov    QWORD PTR [rsp+0xb0],r13
    46df:	test   rcx,0x1
    46e6:	jne    4714 <botlish_fn_21+0x45c>
    46ec:	mov    rdx,QWORD PTR [rsp+0xb0]
    46f4:	mov    rdi,r15
    46f7:	call   46fc <botlish_fn_21+0x444>
			46f8: R_X86_64_PLT32	rt_int_cmp-0x4
    46fc:	mov    esi,0x2
    4701:	test   rax,rax
    4704:	mov    rax,rsi
    4707:	cmove  rax,QWORD PTR [rip+0xb1]        # 47c0 <botlish_fn_21+0x508>
    470f:	jmp    4736 <botlish_fn_21+0x47e>
    4714:	mov    rdx,QWORD PTR [rsp+0xb0]
    471c:	mov    eax,0x2
    4721:	cmp    rsi,rdx
    4724:	cmove  rax,QWORD PTR [rip+0x94]        # 47c0 <botlish_fn_21+0x508>
    472c:	jmp    4736 <botlish_fn_21+0x47e>
    4731:	mov    eax,0x2
    4736:	mov    rdi,r15
    4739:	jmp    4746 <botlish_fn_21+0x48e>
    473e:	mov    eax,0x2
    4743:	mov    rdi,r15
    4746:	mov    rdi,r15
    4749:	mov    QWORD PTR [rdi],rbx
    474c:	mov    rbx,QWORD PTR [rsp+0xc0]
    4754:	mov    r12,QWORD PTR [rsp+0xc8]
    475c:	mov    r13,QWORD PTR [rsp+0xd0]
    4764:	mov    r14,QWORD PTR [rsp+0xd8]
    476c:	mov    r15,QWORD PTR [rsp+0xe0]
    4774:	add    rsp,0xf0
    477b:	mov    rsp,rbp
    477e:	pop    rbp
    477f:	ret
    4780:	mov    r15,rdi
    4783:	call   4788 <botlish_fn_21+0x4d0>
			4784: R_X86_64_PLT32	rt_stack_overflow-0x4
    4788:	xor    rax,rax
    478b:	mov    rbx,QWORD PTR [rsp+0xc0]
    4793:	mov    r12,QWORD PTR [rsp+0xc8]
    479b:	mov    r13,QWORD PTR [rsp+0xd0]
    47a3:	mov    r14,QWORD PTR [rsp+0xd8]
    47ab:	mov    r15,QWORD PTR [rsp+0xe0]
    47b3:	add    rsp,0xf0
    47ba:	mov    rsp,rbp
    47bd:	pop    rbp
    47be:	ret
    47bf:	add    BYTE PTR [rsi],al
    47c1:	add    BYTE PTR [rax],al
    47c3:	add    BYTE PTR [rax],al
    47c5:	add    BYTE PTR [rax],al
	...

00000000000047c8 <botlish_entry_21: <generic>>:
    47c8:	push   rbp
    47c9:	mov    rbp,rsp
    47cc:	mov    rsi,QWORD PTR [rdx]
    47cf:	call   47d4 <botlish_entry_21+0xc>
			47d0: R_X86_64_PLT32	botlish_fn_21-0x4 ; <generic>
    47d4:	mov    rsp,rbp
    47d7:	pop    rbp
    47d8:	ret

00000000000047d9 <botlish_fn_22: char_at<generic>>:
    47d9:	push   rbp
    47da:	mov    rbp,rsp
    47dd:	sub    rsp,0x40
    47e1:	mov    QWORD PTR [rsp+0x20],rbx
    47e6:	mov    QWORD PTR [rsp+0x28],r12
    47eb:	mov    QWORD PTR [rsp+0x30],r13
    47f0:	mov    QWORD PTR [rsp],rdx
    47f4:	mov    rax,QWORD PTR [rsi+0x20]
    47f8:	mov    rsi,QWORD PTR [rax]
    47fb:	mov    QWORD PTR [rsp+0x8],rsi
    4800:	mov    r13,rsi
    4803:	mov    QWORD PTR [rsp+0x10],0x3
    480c:	mov    r10d,0x1
    4812:	test   rdx,0x1
    4819:	je     4827 <botlish_fn_22+0x4e>
    481f:	mov    rbx,rdx
    4822:	jmp    484c <botlish_fn_22+0x73>
    4827:	xor    r10d,r10d
    482a:	test   rdx,0x7
    4831:	je     483f <botlish_fn_22+0x66>
    4837:	mov    rbx,rdx
    483a:	jmp    484c <botlish_fn_22+0x73>
    483f:	movzx  rax,BYTE PTR [rdx]
    4843:	mov    rbx,rdx
    4846:	cmp    al,0x1
    4848:	sete   r10b
    484c:	test   r10b,r10b
    484f:	jne    4870 <botlish_fn_22+0x97>
    4855:	mov    rax,QWORD PTR [rdi+0x10]
    4859:	mov    rcx,QWORD PTR [rax+0x108]
    4860:	xor    rdx,rdx
    4863:	mov    rsi,rbx
    4866:	call   486b <botlish_fn_22+0x92>
			4867: R_X86_64_PLT32	rt_type_error-0x4
    486b:	jmp    4922 <botlish_fn_22+0x149>
    4870:	mov    rsi,rbx
    4873:	mov    r12,rdi
    4876:	test   rsi,0x1
    487d:	je     4898 <botlish_fn_22+0xbf>
    4883:	mov    rsi,rbx
    4886:	mov    rcx,rsi
    4889:	add    rcx,0x2
    488d:	seto   al
    4890:	test   al,al
    4892:	je     48ab <botlish_fn_22+0xd2>
    4898:	mov    edx,0x3
    489d:	mov    rsi,rbx
    48a0:	mov    rdi,r12
    48a3:	call   48a8 <botlish_fn_22+0xcf>
			48a4: R_X86_64_PLT32	rt_int_add-0x4
    48a8:	mov    rcx,rax
    48ab:	mov    QWORD PTR [rsp+0x10],rcx
    48b0:	mov    eax,0x1
    48b5:	mov    rsi,rbx
    48b8:	test   rsi,0x1
    48bf:	jne    48e5 <botlish_fn_22+0x10c>
    48c5:	xor    eax,eax
    48c7:	mov    rsi,rbx
    48ca:	test   rsi,0x7
    48d1:	jne    48e5 <botlish_fn_22+0x10c>
    48d7:	mov    rsi,rbx
    48da:	movzx  rdx,BYTE PTR [rsi]
    48de:	rex cmp dl,0x1
    48e2:	sete   al
    48e5:	test   al,al
    48e7:	jne    490b <botlish_fn_22+0x132>
    48ed:	mov    rdi,r12
    48f0:	mov    rsi,QWORD PTR [rdi+0x10]
    48f4:	mov    rcx,QWORD PTR [rsi+0x110]
    48fb:	xor    rdx,rdx
    48fe:	mov    rsi,rbx
    4901:	call   4906 <botlish_fn_22+0x12d>
			4902: R_X86_64_PLT32	rt_type_error-0x4
    4906:	jmp    4922 <botlish_fn_22+0x149>
    490b:	mov    rdx,rbx
    490e:	mov    rsi,r13
    4911:	mov    rdi,r12
    4914:	call   4919 <botlish_fn_22+0x140>
			4915: R_X86_64_PLT32	rt_substr-0x4
    4919:	test   rax,rax
    491c:	jne    493d <botlish_fn_22+0x164>
    4922:	xor    rax,rax
    4925:	mov    rbx,QWORD PTR [rsp+0x20]
    492a:	mov    r12,QWORD PTR [rsp+0x28]
    492f:	mov    r13,QWORD PTR [rsp+0x30]
    4934:	add    rsp,0x40
    4938:	mov    rsp,rbp
    493b:	pop    rbp
    493c:	ret
    493d:	mov    rbx,QWORD PTR [rsp+0x20]
    4942:	mov    r12,QWORD PTR [rsp+0x28]
    4947:	mov    r13,QWORD PTR [rsp+0x30]
    494c:	add    rsp,0x40
    4950:	mov    rsp,rbp
    4953:	pop    rbp
    4954:	ret

0000000000004955 <botlish_entry_22: char_at<generic>>:
    4955:	push   rbp
    4956:	mov    rbp,rsp
    4959:	mov    rdx,QWORD PTR [rdx]
    495c:	call   4961 <botlish_entry_22+0xc>
			495d: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    4961:	mov    rsp,rbp
    4964:	pop    rbp
    4965:	ret

0000000000004966 <botlish_fn_23: char_at<generic>>:
    4966:	push   rbp
    4967:	mov    rbp,rsp
    496a:	sub    rsp,0x40
    496e:	mov    QWORD PTR [rsp+0x20],rbx
    4973:	mov    QWORD PTR [rsp+0x28],r12
    4978:	mov    QWORD PTR [rsp+0x30],r13
    497d:	mov    QWORD PTR [rsp+0x38],r14
    4982:	mov    r13,rcx
    4985:	mov    QWORD PTR [rsp],rdx
    4989:	mov    rax,QWORD PTR [rsi+0x20]
    498d:	mov    rax,QWORD PTR [rax]
    4990:	mov    QWORD PTR [rsp+0x8],rax
    4995:	mov    r14,rax
    4998:	mov    QWORD PTR [rsp+0x10],0x3
    49a1:	mov    r11d,0x1
    49a7:	test   rdx,0x1
    49ae:	je     49bc <botlish_fn_23+0x56>
    49b4:	mov    r12,rdx
    49b7:	jmp    49e1 <botlish_fn_23+0x7b>
    49bc:	xor    r11d,r11d
    49bf:	test   rdx,0x7
    49c6:	je     49d4 <botlish_fn_23+0x6e>
    49cc:	mov    r12,rdx
    49cf:	jmp    49e1 <botlish_fn_23+0x7b>
    49d4:	movzx  rax,BYTE PTR [rdx]
    49d8:	mov    r12,rdx
    49db:	cmp    al,0x1
    49dd:	sete   r11b
    49e1:	test   r11b,r11b
    49e4:	jne    4a05 <botlish_fn_23+0x9f>
    49ea:	mov    rax,QWORD PTR [rdi+0x10]
    49ee:	mov    rcx,QWORD PTR [rax+0x108]
    49f5:	xor    rdx,rdx
    49f8:	mov    rsi,r12
    49fb:	call   4a00 <botlish_fn_23+0x9a>
			49fc: R_X86_64_PLT32	rt_type_error-0x4
    4a00:	jmp    4abd <botlish_fn_23+0x157>
    4a05:	mov    rbx,rdi
    4a08:	mov    rsi,r12
    4a0b:	test   rsi,0x1
    4a12:	jne    4a20 <botlish_fn_23+0xba>
    4a18:	mov    r12,rsi
    4a1b:	jmp    4a35 <botlish_fn_23+0xcf>
    4a20:	mov    rax,rsi
    4a23:	add    rax,0x2
    4a27:	mov    r12,rsi
    4a2a:	seto   cl
    4a2d:	test   cl,cl
    4a2f:	je     4a45 <botlish_fn_23+0xdf>
    4a35:	mov    edx,0x3
    4a3a:	mov    rsi,r12
    4a3d:	mov    rdi,rbx
    4a40:	call   4a45 <botlish_fn_23+0xdf>
			4a41: R_X86_64_PLT32	rt_int_add-0x4
    4a45:	mov    ecx,0x1
    4a4a:	mov    rsi,r12
    4a4d:	test   rsi,0x1
    4a54:	jne    4a7a <botlish_fn_23+0x114>
    4a5a:	xor    ecx,ecx
    4a5c:	mov    rsi,r12
    4a5f:	test   rsi,0x7
    4a66:	jne    4a7a <botlish_fn_23+0x114>
    4a6c:	mov    rsi,r12
    4a6f:	movzx  rdx,BYTE PTR [rsi]
    4a73:	rex cmp dl,0x1
    4a77:	sete   cl
    4a7a:	test   cl,cl
    4a7c:	jne    4aa0 <botlish_fn_23+0x13a>
    4a82:	mov    rdi,rbx
    4a85:	mov    rsi,QWORD PTR [rdi+0x10]
    4a89:	mov    rcx,QWORD PTR [rsi+0x110]
    4a90:	xor    rdx,rdx
    4a93:	mov    rsi,r12
    4a96:	call   4a9b <botlish_fn_23+0x135>
			4a97: R_X86_64_PLT32	rt_type_error-0x4
    4a9b:	jmp    4abd <botlish_fn_23+0x157>
    4aa0:	mov    rdi,rbx
    4aa3:	mov    rbx,rax
    4aa6:	mov    rcx,rbx
    4aa9:	mov    rdx,r12
    4aac:	mov    rsi,r14
    4aaf:	call   4ab4 <botlish_fn_23+0x14e>
			4ab0: R_X86_64_PLT32	rt_str_region_check-0x4
    4ab4:	test   rax,rax
    4ab7:	jne    4add <botlish_fn_23+0x177>
    4abd:	xor    rax,rax
    4ac0:	mov    rbx,QWORD PTR [rsp+0x20]
    4ac5:	mov    r12,QWORD PTR [rsp+0x28]
    4aca:	mov    r13,QWORD PTR [rsp+0x30]
    4acf:	mov    r14,QWORD PTR [rsp+0x38]
    4ad4:	add    rsp,0x40
    4ad8:	mov    rsp,rbp
    4adb:	pop    rbp
    4adc:	ret
    4add:	mov    rcx,r13
    4ae0:	mov    rsi,r12
    4ae3:	mov    QWORD PTR [rcx],rsi
    4ae6:	mov    QWORD PTR [rcx+0x8],rbx
    4aea:	mov    rax,r14
    4aed:	mov    rbx,QWORD PTR [rsp+0x20]
    4af2:	mov    r12,QWORD PTR [rsp+0x28]
    4af7:	mov    r13,QWORD PTR [rsp+0x30]
    4afc:	mov    r14,QWORD PTR [rsp+0x38]
    4b01:	add    rsp,0x40
    4b05:	mov    rsp,rbp
    4b08:	pop    rbp
    4b09:	ret

0000000000004b0a <botlish_entry_23: char_at<generic>>:
    4b0a:	push   rbp
    4b0b:	mov    rbp,rsp
    4b0e:	ud2

0000000000004b10 <botlish_fn_24: is_local_char<str>>:
    4b10:	push   rbp
    4b11:	mov    rbp,rsp
    4b14:	sub    rsp,0x10
    4b18:	mov    QWORD PTR [rsp],rbx
    4b1c:	mov    QWORD PTR [rsp+0x8],r12
    4b21:	mov    rbx,rsi
    4b24:	mov    r12,rdi
    4b27:	mov    rsi,rbx
    4b2a:	mov    rdi,r12
    4b2d:	call   4b32 <botlish_fn_24+0x22>
			4b2e: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    4b32:	test   rax,rax
    4b35:	jne    4b50 <botlish_fn_24+0x40>
    4b3b:	xor    rax,rax
    4b3e:	mov    rbx,QWORD PTR [rsp]
    4b42:	mov    r12,QWORD PTR [rsp+0x8]
    4b47:	add    rsp,0x10
    4b4b:	mov    rsp,rbp
    4b4e:	pop    rbp
    4b4f:	ret
    4b50:	cmp    rax,0x6
    4b54:	je     4c4f <botlish_fn_24+0x13f>
    4b5a:	mov    rdi,r12
    4b5d:	mov    rax,QWORD PTR [rdi+0x10]
    4b61:	mov    rsi,QWORD PTR [rax+0x118]
    4b68:	mov    edx,0x1
    4b6d:	mov    ecx,0x3
    4b72:	mov    r8,rbx
    4b75:	call   4b7a <botlish_fn_24+0x6a>
			4b76: R_X86_64_PLT32	rt_str_region_eq-0x4
    4b7a:	cmp    rax,0x6
    4b7e:	je     4c45 <botlish_fn_24+0x135>
    4b84:	mov    rdi,r12
    4b87:	mov    rax,QWORD PTR [rdi+0x10]
    4b8b:	mov    rsi,QWORD PTR [rax+0x120]
    4b92:	mov    edx,0x1
    4b97:	mov    ecx,0x3
    4b9c:	mov    r8,rbx
    4b9f:	call   4ba4 <botlish_fn_24+0x94>
			4ba0: R_X86_64_PLT32	rt_str_region_eq-0x4
    4ba4:	cmp    rax,0x6
    4ba8:	je     4c3b <botlish_fn_24+0x12b>
    4bae:	mov    rdi,r12
    4bb1:	mov    rax,QWORD PTR [rdi+0x10]
    4bb5:	mov    rsi,QWORD PTR [rax+0xc0]
    4bbc:	mov    edx,0x1
    4bc1:	mov    ecx,0x3
    4bc6:	mov    r8,rbx
    4bc9:	call   4bce <botlish_fn_24+0xbe>
			4bca: R_X86_64_PLT32	rt_str_region_eq-0x4
    4bce:	cmp    rax,0x6
    4bd2:	je     4c31 <botlish_fn_24+0x121>
    4bd8:	mov    rdi,r12
    4bdb:	mov    rax,QWORD PTR [rdi+0x10]
    4bdf:	mov    rsi,QWORD PTR [rax+0x108]
    4be6:	mov    edx,0x1
    4beb:	mov    ecx,0x3
    4bf0:	mov    r8,rbx
    4bf3:	call   4bf8 <botlish_fn_24+0xe8>
			4bf4: R_X86_64_PLT32	rt_str_region_eq-0x4
    4bf8:	cmp    rax,0x6
    4bfc:	je     4c27 <botlish_fn_24+0x117>
    4c02:	mov    rdi,r12
    4c05:	mov    rax,QWORD PTR [rdi+0x10]
    4c09:	mov    rsi,QWORD PTR [rax+0x128]
    4c10:	mov    edx,0x1
    4c15:	mov    ecx,0x3
    4c1a:	mov    r8,rbx
    4c1d:	call   4c22 <botlish_fn_24+0x112>
			4c1e: R_X86_64_PLT32	rt_str_region_eq-0x4
    4c22:	jmp    4c54 <botlish_fn_24+0x144>
    4c27:	mov    eax,0x6
    4c2c:	jmp    4c54 <botlish_fn_24+0x144>
    4c31:	mov    eax,0x6
    4c36:	jmp    4c54 <botlish_fn_24+0x144>
    4c3b:	mov    eax,0x6
    4c40:	jmp    4c54 <botlish_fn_24+0x144>
    4c45:	mov    eax,0x6
    4c4a:	jmp    4c54 <botlish_fn_24+0x144>
    4c4f:	mov    eax,0x6
    4c54:	mov    rbx,QWORD PTR [rsp]
    4c58:	mov    r12,QWORD PTR [rsp+0x8]
    4c5d:	add    rsp,0x10
    4c61:	mov    rsp,rbp
    4c64:	pop    rbp
    4c65:	ret

0000000000004c66 <botlish_entry_24: is_local_char<str>>:
    4c66:	push   rbp
    4c67:	mov    rbp,rsp
    4c6a:	mov    rsi,QWORD PTR [rdx]
    4c6d:	call   4c72 <botlish_entry_24+0xc>
			4c6e: R_X86_64_PLT32	botlish_fn_24-0x4 ; is_local_char<str>
    4c72:	mov    rsp,rbp
    4c75:	pop    rbp
    4c76:	ret

0000000000004c77 <botlish_fn_25: is_label_char<str>>:
    4c77:	push   rbp
    4c78:	mov    rbp,rsp
    4c7b:	sub    rsp,0x10
    4c7f:	mov    QWORD PTR [rsp],r13
    4c83:	mov    QWORD PTR [rsp+0x8],r15
    4c88:	mov    r13,rsi
    4c8b:	mov    r15,rdi
    4c8e:	mov    rsi,r13
    4c91:	mov    rdi,r15
    4c94:	call   4c99 <botlish_fn_25+0x22>
			4c95: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    4c99:	test   rax,rax
    4c9c:	jne    4cb7 <botlish_fn_25+0x40>
    4ca2:	xor    rax,rax
    4ca5:	mov    r13,QWORD PTR [rsp]
    4ca9:	mov    r15,QWORD PTR [rsp+0x8]
    4cae:	add    rsp,0x10
    4cb2:	mov    rsp,rbp
    4cb5:	pop    rbp
    4cb6:	ret
    4cb7:	cmp    rax,0x6
    4cbb:	je     4ce6 <botlish_fn_25+0x6f>
    4cc1:	mov    rdi,r15
    4cc4:	mov    rax,QWORD PTR [rdi+0x10]
    4cc8:	mov    rsi,QWORD PTR [rax+0x128]
    4ccf:	mov    edx,0x1
    4cd4:	mov    ecx,0x3
    4cd9:	mov    r8,r13
    4cdc:	call   4ce1 <botlish_fn_25+0x6a>
			4cdd: R_X86_64_PLT32	rt_str_region_eq-0x4
    4ce1:	jmp    4ceb <botlish_fn_25+0x74>
    4ce6:	mov    eax,0x6
    4ceb:	mov    r13,QWORD PTR [rsp]
    4cef:	mov    r15,QWORD PTR [rsp+0x8]
    4cf4:	add    rsp,0x10
    4cf8:	mov    rsp,rbp
    4cfb:	pop    rbp
    4cfc:	ret

0000000000004cfd <botlish_entry_25: is_label_char<str>>:
    4cfd:	push   rbp
    4cfe:	mov    rbp,rsp
    4d01:	mov    rsi,QWORD PTR [rdx]
    4d04:	call   4d09 <botlish_entry_25+0xc>
			4d05: R_X86_64_PLT32	botlish_fn_25-0x4 ; is_label_char<str>
    4d09:	mov    rsp,rbp
    4d0c:	pop    rbp
    4d0d:	ret
	...

0000000000004d10 <botlish_fn_26: scan_local<generic>>:
    4d10:	push   rbp
    4d11:	mov    rbp,rsp
    4d14:	sub    rsp,0x40
    4d18:	mov    QWORD PTR [rsp+0x20],rbx
    4d1d:	mov    QWORD PTR [rsp+0x28],r12
    4d22:	mov    QWORD PTR [rsp+0x30],r13
    4d27:	mov    QWORD PTR [rsp+0x38],r14
    4d2c:	mov    r12,QWORD PTR [rdi]
    4d2f:	mov    rax,QWORD PTR [rdi+0x8]
    4d33:	lea    rcx,[r12+0x8]
    4d38:	cmp    rcx,rax
    4d3b:	ja     4f19 <botlish_fn_26+0x209>
    4d41:	lea    rax,[r12+0x8]
    4d46:	mov    QWORD PTR [rdi],rax
    4d49:	mov    r13,rdi
    4d4c:	mov    QWORD PTR [r12],0x0
    4d54:	mov    QWORD PTR [rsp+0x10],0x0
    4d5d:	mov    QWORD PTR [rsp],rdx
    4d61:	mov    rbx,rsi
    4d64:	mov    rsi,rdx
    4d67:	mov    rax,QWORD PTR [rbx+0x20]
    4d6b:	mov    rdx,QWORD PTR [rax]
    4d6e:	mov    ecx,0x1
    4d73:	test   rsi,0x1
    4d7a:	jne    4d98 <botlish_fn_26+0x88>
    4d80:	xor    ecx,ecx
    4d82:	test   rsi,0x7
    4d89:	jne    4d98 <botlish_fn_26+0x88>
    4d8f:	movzx  rax,BYTE PTR [rsi]
    4d93:	cmp    al,0x1
    4d95:	sete   cl
    4d98:	test   cl,cl
    4d9a:	jne    4dbe <botlish_fn_26+0xae>
    4da0:	mov    rdi,r13
    4da3:	mov    rax,QWORD PTR [rdi+0x10]
    4da7:	mov    rcx,QWORD PTR [rax+0xb8]
    4dae:	xor    rdx,rdx
    4db1:	call   4db6 <botlish_fn_26+0xa6>
			4db2: R_X86_64_PLT32	rt_type_error-0x4
    4db6:	mov    rdi,r13
    4db9:	jmp    4e55 <botlish_fn_26+0x145>
    4dbe:	mov    rax,rsi
    4dc1:	and    rax,rdx
    4dc4:	mov    r14,rsi
    4dc7:	test   rax,0x1
    4dcd:	jne    4df3 <botlish_fn_26+0xe3>
    4dd3:	mov    rsi,r14
    4dd6:	mov    rdi,r13
    4dd9:	call   4dde <botlish_fn_26+0xce>
			4dda: R_X86_64_PLT32	rt_int_cmp-0x4
    4dde:	mov    ecx,0x2
    4de3:	test   rax,rax
    4de6:	cmovge rcx,QWORD PTR [rip+0x15a]        # 4f48 <botlish_fn_26+0x238>
    4dee:	jmp    4e06 <botlish_fn_26+0xf6>
    4df3:	mov    ecx,0x2
    4df8:	mov    rsi,r14
    4dfb:	cmp    rsi,rdx
    4dfe:	cmovge rcx,QWORD PTR [rip+0x142]        # 4f48 <botlish_fn_26+0x238>
    4e06:	cmp    rcx,0x6
    4e0a:	je     4ef0 <botlish_fn_26+0x1e0>
    4e10:	mov    rsi,QWORD PTR [rbx+0x20]
    4e14:	mov    rsi,QWORD PTR [rsi+0x8]
    4e18:	mov    QWORD PTR [rsp+0x8],rsi
    4e1d:	mov    rdx,r14
    4e20:	mov    rdi,r13
    4e23:	call   4e28 <botlish_fn_26+0x118>
			4e24: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    4e28:	test   rax,rax
    4e2b:	jne    4e39 <botlish_fn_26+0x129>
    4e31:	mov    rdi,r13
    4e34:	jmp    4e55 <botlish_fn_26+0x145>
    4e39:	mov    QWORD PTR [rsp+0x8],rax
    4e3e:	mov    rsi,rax
    4e41:	mov    rdi,r13
    4e44:	call   4e49 <botlish_fn_26+0x139>
			4e45: R_X86_64_PLT32	botlish_fn_24-0x4 ; is_local_char<str>
    4e49:	test   rax,rax
    4e4c:	jne    4e7b <botlish_fn_26+0x16b>
    4e52:	mov    rdi,r13
    4e55:	mov    rdi,r13
    4e58:	mov    QWORD PTR [rdi],r12
    4e5b:	xor    rax,rax
    4e5e:	mov    rbx,QWORD PTR [rsp+0x20]
    4e63:	mov    r12,QWORD PTR [rsp+0x28]
    4e68:	mov    r13,QWORD PTR [rsp+0x30]
    4e6d:	mov    r14,QWORD PTR [rsp+0x38]
    4e72:	add    rsp,0x40
    4e76:	mov    rsp,rbp
    4e79:	pop    rbp
    4e7a:	ret
    4e7b:	cmp    rax,0x6
    4e7f:	je     4e90 <botlish_fn_26+0x180>
    4e85:	mov    rax,r14
    4e88:	mov    rdi,r13
    4e8b:	jmp    4ef6 <botlish_fn_26+0x1e6>
    4e90:	mov    QWORD PTR [rsp+0x8],rbx
    4e95:	mov    QWORD PTR [rsp+0x10],0x3
    4e9e:	mov    rsi,r14
    4ea1:	test   rsi,0x1
    4ea8:	je     4ece <botlish_fn_26+0x1be>
    4eae:	mov    rsi,r14
    4eb1:	mov    rcx,rsi
    4eb4:	add    rcx,0x2
    4eb8:	seto   al
    4ebb:	test   al,al
    4ebd:	jne    4ece <botlish_fn_26+0x1be>
    4ec3:	mov    rsi,rcx
    4ec6:	mov    r14,rcx
    4ec9:	jmp    4ee4 <botlish_fn_26+0x1d4>
    4ece:	mov    edx,0x3
    4ed3:	mov    rsi,r14
    4ed6:	mov    rdi,r13
    4ed9:	call   4ede <botlish_fn_26+0x1ce>
			4eda: R_X86_64_PLT32	rt_int_add-0x4
    4ede:	mov    rsi,rax
    4ee1:	mov    r14,rax
    4ee4:	mov    QWORD PTR [rsp],rsi
    4ee8:	mov    rsi,r14
    4eeb:	jmp    4d67 <botlish_fn_26+0x57>
    4ef0:	mov    rax,r14
    4ef3:	mov    rdi,r13
    4ef6:	mov    rdi,r13
    4ef9:	mov    QWORD PTR [rdi],r12
    4efc:	mov    rbx,QWORD PTR [rsp+0x20]
    4f01:	mov    r12,QWORD PTR [rsp+0x28]
    4f06:	mov    r13,QWORD PTR [rsp+0x30]
    4f0b:	mov    r14,QWORD PTR [rsp+0x38]
    4f10:	add    rsp,0x40
    4f14:	mov    rsp,rbp
    4f17:	pop    rbp
    4f18:	ret
    4f19:	mov    r13,rdi
    4f1c:	call   4f21 <botlish_fn_26+0x211>
			4f1d: R_X86_64_PLT32	rt_stack_overflow-0x4
    4f21:	xor    rax,rax
    4f24:	mov    rbx,QWORD PTR [rsp+0x20]
    4f29:	mov    r12,QWORD PTR [rsp+0x28]
    4f2e:	mov    r13,QWORD PTR [rsp+0x30]
    4f33:	mov    r14,QWORD PTR [rsp+0x38]
    4f38:	add    rsp,0x40
    4f3c:	mov    rsp,rbp
    4f3f:	pop    rbp
    4f40:	ret
    4f41:	add    BYTE PTR [rax],al
    4f43:	add    BYTE PTR [rax],al
    4f45:	add    BYTE PTR [rax],al
    4f47:	add    BYTE PTR [rsi],al
    4f49:	add    BYTE PTR [rax],al
    4f4b:	add    BYTE PTR [rax],al
    4f4d:	add    BYTE PTR [rax],al
	...

0000000000004f50 <botlish_entry_26: scan_local<generic>>:
    4f50:	push   rbp
    4f51:	mov    rbp,rsp
    4f54:	mov    rdx,QWORD PTR [rdx]
    4f57:	call   4f5c <botlish_entry_26+0xc>
			4f58: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    4f5c:	mov    rsp,rbp
    4f5f:	pop    rbp
    4f60:	ret
    4f61:	add    BYTE PTR [rax],al
    4f63:	add    BYTE PTR [rax],al
    4f65:	add    BYTE PTR [rax],al
	...

0000000000004f68 <botlish_fn_27: scan_label<generic>>:
    4f68:	push   rbp
    4f69:	mov    rbp,rsp
    4f6c:	sub    rsp,0x40
    4f70:	mov    QWORD PTR [rsp+0x20],rbx
    4f75:	mov    QWORD PTR [rsp+0x28],r12
    4f7a:	mov    QWORD PTR [rsp+0x30],r13
    4f7f:	mov    QWORD PTR [rsp+0x38],r14
    4f84:	mov    r12,QWORD PTR [rdi]
    4f87:	mov    rax,QWORD PTR [rdi+0x8]
    4f8b:	lea    rcx,[r12+0x8]
    4f90:	cmp    rcx,rax
    4f93:	ja     5171 <botlish_fn_27+0x209>
    4f99:	lea    rax,[r12+0x8]
    4f9e:	mov    QWORD PTR [rdi],rax
    4fa1:	mov    r13,rdi
    4fa4:	mov    QWORD PTR [r12],0x0
    4fac:	mov    QWORD PTR [rsp+0x10],0x0
    4fb5:	mov    QWORD PTR [rsp],rdx
    4fb9:	mov    rbx,rsi
    4fbc:	mov    rsi,rdx
    4fbf:	mov    rax,QWORD PTR [rbx+0x20]
    4fc3:	mov    rdx,QWORD PTR [rax]
    4fc6:	mov    ecx,0x1
    4fcb:	test   rsi,0x1
    4fd2:	jne    4ff0 <botlish_fn_27+0x88>
    4fd8:	xor    ecx,ecx
    4fda:	test   rsi,0x7
    4fe1:	jne    4ff0 <botlish_fn_27+0x88>
    4fe7:	movzx  rax,BYTE PTR [rsi]
    4feb:	cmp    al,0x1
    4fed:	sete   cl
    4ff0:	test   cl,cl
    4ff2:	jne    5016 <botlish_fn_27+0xae>
    4ff8:	mov    rdi,r13
    4ffb:	mov    rax,QWORD PTR [rdi+0x10]
    4fff:	mov    rcx,QWORD PTR [rax+0xb8]
    5006:	xor    rdx,rdx
    5009:	call   500e <botlish_fn_27+0xa6>
			500a: R_X86_64_PLT32	rt_type_error-0x4
    500e:	mov    rdi,r13
    5011:	jmp    50ad <botlish_fn_27+0x145>
    5016:	mov    rax,rsi
    5019:	and    rax,rdx
    501c:	mov    r14,rsi
    501f:	test   rax,0x1
    5025:	jne    504b <botlish_fn_27+0xe3>
    502b:	mov    rsi,r14
    502e:	mov    rdi,r13
    5031:	call   5036 <botlish_fn_27+0xce>
			5032: R_X86_64_PLT32	rt_int_cmp-0x4
    5036:	mov    ecx,0x2
    503b:	test   rax,rax
    503e:	cmovge rcx,QWORD PTR [rip+0x15a]        # 51a0 <botlish_fn_27+0x238>
    5046:	jmp    505e <botlish_fn_27+0xf6>
    504b:	mov    ecx,0x2
    5050:	mov    rsi,r14
    5053:	cmp    rsi,rdx
    5056:	cmovge rcx,QWORD PTR [rip+0x142]        # 51a0 <botlish_fn_27+0x238>
    505e:	cmp    rcx,0x6
    5062:	je     5148 <botlish_fn_27+0x1e0>
    5068:	mov    rsi,QWORD PTR [rbx+0x20]
    506c:	mov    rsi,QWORD PTR [rsi+0x8]
    5070:	mov    QWORD PTR [rsp+0x8],rsi
    5075:	mov    rdx,r14
    5078:	mov    rdi,r13
    507b:	call   5080 <botlish_fn_27+0x118>
			507c: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    5080:	test   rax,rax
    5083:	jne    5091 <botlish_fn_27+0x129>
    5089:	mov    rdi,r13
    508c:	jmp    50ad <botlish_fn_27+0x145>
    5091:	mov    QWORD PTR [rsp+0x8],rax
    5096:	mov    rsi,rax
    5099:	mov    rdi,r13
    509c:	call   50a1 <botlish_fn_27+0x139>
			509d: R_X86_64_PLT32	botlish_fn_25-0x4 ; is_label_char<str>
    50a1:	test   rax,rax
    50a4:	jne    50d3 <botlish_fn_27+0x16b>
    50aa:	mov    rdi,r13
    50ad:	mov    rdi,r13
    50b0:	mov    QWORD PTR [rdi],r12
    50b3:	xor    rax,rax
    50b6:	mov    rbx,QWORD PTR [rsp+0x20]
    50bb:	mov    r12,QWORD PTR [rsp+0x28]
    50c0:	mov    r13,QWORD PTR [rsp+0x30]
    50c5:	mov    r14,QWORD PTR [rsp+0x38]
    50ca:	add    rsp,0x40
    50ce:	mov    rsp,rbp
    50d1:	pop    rbp
    50d2:	ret
    50d3:	cmp    rax,0x6
    50d7:	je     50e8 <botlish_fn_27+0x180>
    50dd:	mov    rax,r14
    50e0:	mov    rdi,r13
    50e3:	jmp    514e <botlish_fn_27+0x1e6>
    50e8:	mov    QWORD PTR [rsp+0x8],rbx
    50ed:	mov    QWORD PTR [rsp+0x10],0x3
    50f6:	mov    rsi,r14
    50f9:	test   rsi,0x1
    5100:	je     5126 <botlish_fn_27+0x1be>
    5106:	mov    rsi,r14
    5109:	mov    rcx,rsi
    510c:	add    rcx,0x2
    5110:	seto   al
    5113:	test   al,al
    5115:	jne    5126 <botlish_fn_27+0x1be>
    511b:	mov    rsi,rcx
    511e:	mov    r14,rcx
    5121:	jmp    513c <botlish_fn_27+0x1d4>
    5126:	mov    edx,0x3
    512b:	mov    rsi,r14
    512e:	mov    rdi,r13
    5131:	call   5136 <botlish_fn_27+0x1ce>
			5132: R_X86_64_PLT32	rt_int_add-0x4
    5136:	mov    rsi,rax
    5139:	mov    r14,rax
    513c:	mov    QWORD PTR [rsp],rsi
    5140:	mov    rsi,r14
    5143:	jmp    4fbf <botlish_fn_27+0x57>
    5148:	mov    rax,r14
    514b:	mov    rdi,r13
    514e:	mov    rdi,r13
    5151:	mov    QWORD PTR [rdi],r12
    5154:	mov    rbx,QWORD PTR [rsp+0x20]
    5159:	mov    r12,QWORD PTR [rsp+0x28]
    515e:	mov    r13,QWORD PTR [rsp+0x30]
    5163:	mov    r14,QWORD PTR [rsp+0x38]
    5168:	add    rsp,0x40
    516c:	mov    rsp,rbp
    516f:	pop    rbp
    5170:	ret
    5171:	mov    r13,rdi
    5174:	call   5179 <botlish_fn_27+0x211>
			5175: R_X86_64_PLT32	rt_stack_overflow-0x4
    5179:	xor    rax,rax
    517c:	mov    rbx,QWORD PTR [rsp+0x20]
    5181:	mov    r12,QWORD PTR [rsp+0x28]
    5186:	mov    r13,QWORD PTR [rsp+0x30]
    518b:	mov    r14,QWORD PTR [rsp+0x38]
    5190:	add    rsp,0x40
    5194:	mov    rsp,rbp
    5197:	pop    rbp
    5198:	ret
    5199:	add    BYTE PTR [rax],al
    519b:	add    BYTE PTR [rax],al
    519d:	add    BYTE PTR [rax],al
    519f:	add    BYTE PTR [rsi],al
    51a1:	add    BYTE PTR [rax],al
    51a3:	add    BYTE PTR [rax],al
    51a5:	add    BYTE PTR [rax],al
	...

00000000000051a8 <botlish_entry_27: scan_label<generic>>:
    51a8:	push   rbp
    51a9:	mov    rbp,rsp
    51ac:	mov    rdx,QWORD PTR [rdx]
    51af:	call   51b4 <botlish_entry_27+0xc>
			51b0: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_label<generic>
    51b4:	mov    rsp,rbp
    51b7:	pop    rbp
    51b8:	ret
    51b9:	add    BYTE PTR [rax],al
    51bb:	add    BYTE PTR [rax],al
    51bd:	add    BYTE PTR [rax],al
	...

00000000000051c0 <botlish_fn_28: scan_alpha<generic>>:
    51c0:	push   rbp
    51c1:	mov    rbp,rsp
    51c4:	sub    rsp,0x40
    51c8:	mov    QWORD PTR [rsp+0x20],rbx
    51cd:	mov    QWORD PTR [rsp+0x28],r12
    51d2:	mov    QWORD PTR [rsp+0x30],r13
    51d7:	mov    QWORD PTR [rsp+0x38],r14
    51dc:	mov    r12,QWORD PTR [rdi]
    51df:	mov    rax,QWORD PTR [rdi+0x8]
    51e3:	lea    rcx,[r12+0x8]
    51e8:	cmp    rcx,rax
    51eb:	ja     53c4 <botlish_fn_28+0x204>
    51f1:	lea    rax,[r12+0x8]
    51f6:	mov    QWORD PTR [rdi],rax
    51f9:	mov    r13,rdi
    51fc:	mov    QWORD PTR [r12],0x0
    5204:	mov    QWORD PTR [rsp+0x10],0x0
    520d:	mov    QWORD PTR [rsp],rdx
    5211:	mov    rbx,rsi
    5214:	mov    rsi,rdx
    5217:	mov    rax,QWORD PTR [rbx+0x20]
    521b:	mov    rdx,QWORD PTR [rax]
    521e:	mov    ecx,0x1
    5223:	test   rsi,0x1
    522a:	jne    5248 <botlish_fn_28+0x88>
    5230:	xor    ecx,ecx
    5232:	test   rsi,0x7
    5239:	jne    5248 <botlish_fn_28+0x88>
    523f:	movzx  rax,BYTE PTR [rsi]
    5243:	cmp    al,0x1
    5245:	sete   cl
    5248:	test   cl,cl
    524a:	jne    526e <botlish_fn_28+0xae>
    5250:	mov    rdi,r13
    5253:	mov    rax,QWORD PTR [rdi+0x10]
    5257:	mov    rcx,QWORD PTR [rax+0xb8]
    525e:	xor    rdx,rdx
    5261:	call   5266 <botlish_fn_28+0xa6>
			5262: R_X86_64_PLT32	rt_type_error-0x4
    5266:	mov    rdi,r13
    5269:	jmp    5300 <botlish_fn_28+0x140>
    526e:	mov    rax,rsi
    5271:	and    rax,rdx
    5274:	mov    r14,rsi
    5277:	test   rax,0x1
    527d:	jne    52a3 <botlish_fn_28+0xe3>
    5283:	mov    rsi,r14
    5286:	mov    rdi,r13
    5289:	call   528e <botlish_fn_28+0xce>
			528a: R_X86_64_PLT32	rt_int_cmp-0x4
    528e:	mov    ecx,0x2
    5293:	test   rax,rax
    5296:	cmovge rcx,QWORD PTR [rip+0x152]        # 53f0 <botlish_fn_28+0x230>
    529e:	jmp    52b6 <botlish_fn_28+0xf6>
    52a3:	mov    ecx,0x2
    52a8:	mov    rsi,r14
    52ab:	cmp    rsi,rdx
    52ae:	cmovge rcx,QWORD PTR [rip+0x13a]        # 53f0 <botlish_fn_28+0x230>
    52b6:	cmp    rcx,0x6
    52ba:	je     539b <botlish_fn_28+0x1db>
    52c0:	mov    rsi,QWORD PTR [rbx+0x20]
    52c4:	mov    rsi,QWORD PTR [rsi+0x8]
    52c8:	mov    QWORD PTR [rsp+0x8],rsi
    52cd:	mov    rdx,r14
    52d0:	mov    rdi,r13
    52d3:	call   52d8 <botlish_fn_28+0x118>
			52d4: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    52d8:	test   rax,rax
    52db:	mov    rsi,rax
    52de:	jne    52ec <botlish_fn_28+0x12c>
    52e4:	mov    rdi,r13
    52e7:	jmp    5300 <botlish_fn_28+0x140>
    52ec:	mov    rdi,r13
    52ef:	call   52f4 <botlish_fn_28+0x134>
			52f0: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    52f4:	test   rax,rax
    52f7:	jne    5326 <botlish_fn_28+0x166>
    52fd:	mov    rdi,r13
    5300:	mov    rdi,r13
    5303:	mov    QWORD PTR [rdi],r12
    5306:	xor    rax,rax
    5309:	mov    rbx,QWORD PTR [rsp+0x20]
    530e:	mov    r12,QWORD PTR [rsp+0x28]
    5313:	mov    r13,QWORD PTR [rsp+0x30]
    5318:	mov    r14,QWORD PTR [rsp+0x38]
    531d:	add    rsp,0x40
    5321:	mov    rsp,rbp
    5324:	pop    rbp
    5325:	ret
    5326:	cmp    rax,0x6
    532a:	je     533b <botlish_fn_28+0x17b>
    5330:	mov    rax,r14
    5333:	mov    rdi,r13
    5336:	jmp    53a1 <botlish_fn_28+0x1e1>
    533b:	mov    QWORD PTR [rsp+0x8],rbx
    5340:	mov    QWORD PTR [rsp+0x10],0x3
    5349:	mov    rsi,r14
    534c:	test   rsi,0x1
    5353:	je     5379 <botlish_fn_28+0x1b9>
    5359:	mov    rsi,r14
    535c:	mov    rcx,rsi
    535f:	add    rcx,0x2
    5363:	seto   al
    5366:	test   al,al
    5368:	jne    5379 <botlish_fn_28+0x1b9>
    536e:	mov    rsi,rcx
    5371:	mov    r14,rcx
    5374:	jmp    538f <botlish_fn_28+0x1cf>
    5379:	mov    edx,0x3
    537e:	mov    rsi,r14
    5381:	mov    rdi,r13
    5384:	call   5389 <botlish_fn_28+0x1c9>
			5385: R_X86_64_PLT32	rt_int_add-0x4
    5389:	mov    rsi,rax
    538c:	mov    r14,rax
    538f:	mov    QWORD PTR [rsp],rsi
    5393:	mov    rsi,r14
    5396:	jmp    5217 <botlish_fn_28+0x57>
    539b:	mov    rax,r14
    539e:	mov    rdi,r13
    53a1:	mov    rdi,r13
    53a4:	mov    QWORD PTR [rdi],r12
    53a7:	mov    rbx,QWORD PTR [rsp+0x20]
    53ac:	mov    r12,QWORD PTR [rsp+0x28]
    53b1:	mov    r13,QWORD PTR [rsp+0x30]
    53b6:	mov    r14,QWORD PTR [rsp+0x38]
    53bb:	add    rsp,0x40
    53bf:	mov    rsp,rbp
    53c2:	pop    rbp
    53c3:	ret
    53c4:	mov    r13,rdi
    53c7:	call   53cc <botlish_fn_28+0x20c>
			53c8: R_X86_64_PLT32	rt_stack_overflow-0x4
    53cc:	xor    rax,rax
    53cf:	mov    rbx,QWORD PTR [rsp+0x20]
    53d4:	mov    r12,QWORD PTR [rsp+0x28]
    53d9:	mov    r13,QWORD PTR [rsp+0x30]
    53de:	mov    r14,QWORD PTR [rsp+0x38]
    53e3:	add    rsp,0x40
    53e7:	mov    rsp,rbp
    53ea:	pop    rbp
    53eb:	ret
    53ec:	add    BYTE PTR [rax],al
    53ee:	add    BYTE PTR [rax],al
    53f0:	(bad)
    53f1:	add    BYTE PTR [rax],al
    53f3:	add    BYTE PTR [rax],al
    53f5:	add    BYTE PTR [rax],al
	...

00000000000053f8 <botlish_entry_28: scan_alpha<generic>>:
    53f8:	push   rbp
    53f9:	mov    rbp,rsp
    53fc:	mov    rdx,QWORD PTR [rdx]
    53ff:	call   5404 <botlish_entry_28+0xc>
			5400: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_alpha<generic>
    5404:	mov    rsp,rbp
    5407:	pop    rbp
    5408:	ret
    5409:	add    BYTE PTR [rax],al
    540b:	add    BYTE PTR [rax],al
    540d:	add    BYTE PTR [rax],al
	...

0000000000005410 <botlish_fn_29: tld_ok<generic>>:
    5410:	push   rbp
    5411:	mov    rbp,rsp
    5414:	sub    rsp,0x40
    5418:	mov    QWORD PTR [rsp+0x10],rbx
    541d:	mov    QWORD PTR [rsp+0x18],r12
    5422:	mov    QWORD PTR [rsp+0x20],r13
    5427:	mov    QWORD PTR [rsp+0x28],r14
    542c:	mov    QWORD PTR [rsp+0x30],r15
    5431:	mov    rbx,QWORD PTR [rdi]
    5434:	mov    rax,QWORD PTR [rdi+0x8]
    5438:	lea    rcx,[rbx+0x8]
    543c:	cmp    rcx,rax
    543f:	ja     5650 <botlish_fn_29+0x240>
    5445:	lea    rax,[rbx+0x8]
    5449:	mov    QWORD PTR [rdi],rax
    544c:	mov    r13,rdi
    544f:	mov    QWORD PTR [rbx],0x0
    5456:	mov    QWORD PTR [rsp],rdx
    545a:	mov    r8,rdx
    545d:	mov    rax,QWORD PTR [rsi+0x20]
    5461:	mov    r15,rsi
    5464:	mov    rsi,QWORD PTR [rax]
    5467:	mov    QWORD PTR [rsp+0x8],rsi
    546c:	mov    r12,r8
    546f:	mov    rdx,r12
    5472:	mov    rdi,r13
    5475:	call   547a <botlish_fn_29+0x6a>
			5476: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_alpha<generic>
    547a:	mov    rcx,rax
    547d:	mov    r14,rax
    5480:	test   rax,rcx
    5483:	jne    5491 <botlish_fn_29+0x81>
    5489:	mov    rdi,r13
    548c:	jmp    556a <botlish_fn_29+0x15a>
    5491:	mov    rax,r14
    5494:	mov    QWORD PTR [rsp+0x8],rax
    5499:	mov    rsi,r15
    549c:	mov    rax,QWORD PTR [rsi+0x20]
    54a0:	mov    rdx,QWORD PTR [rax+0x8]
    54a4:	mov    rax,r14
    54a7:	and    rax,rdx
    54aa:	test   rax,0x1
    54b0:	jne    54d9 <botlish_fn_29+0xc9>
    54b6:	mov    rsi,r14
    54b9:	mov    rdi,r13
    54bc:	call   54c1 <botlish_fn_29+0xb1>
			54bd: R_X86_64_PLT32	rt_int_cmp-0x4
    54c1:	mov    ecx,0x2
    54c6:	test   rax,rax
    54c9:	cmove  rcx,QWORD PTR [rip+0x1af]        # 5680 <botlish_fn_29+0x270>
    54d1:	mov    rax,r14
    54d4:	jmp    54ec <botlish_fn_29+0xdc>
    54d9:	mov    ecx,0x2
    54de:	mov    rax,r14
    54e1:	cmp    rax,rdx
    54e4:	cmove  rcx,QWORD PTR [rip+0x194]        # 5680 <botlish_fn_29+0x270>
    54ec:	cmp    rcx,0x6
    54f0:	je     5506 <botlish_fn_29+0xf6>
    54f6:	mov    ecx,0x2
    54fb:	mov    rax,rcx
    54fe:	mov    rdi,r13
    5501:	jmp    5628 <botlish_fn_29+0x218>
    5506:	mov    ecx,0x1
    550b:	test   r12,0x1
    5512:	je     5520 <botlish_fn_29+0x110>
    5518:	mov    r8,r12
    551b:	jmp    5546 <botlish_fn_29+0x136>
    5520:	xor    ecx,ecx
    5522:	test   r12,0x7
    5529:	je     5537 <botlish_fn_29+0x127>
    552f:	mov    r8,r12
    5532:	jmp    5546 <botlish_fn_29+0x136>
    5537:	movzx  rcx,BYTE PTR [r12]
    553c:	mov    r8,r12
    553f:	rex cmp cl,0x1
    5543:	sete   cl
    5546:	test   cl,cl
    5548:	jne    5595 <botlish_fn_29+0x185>
    554e:	mov    rdi,r13
    5551:	mov    rax,QWORD PTR [rdi+0x10]
    5555:	mov    rcx,QWORD PTR [rax+0x128]
    555c:	xor    rdx,rdx
    555f:	mov    rsi,r8
    5562:	call   5567 <botlish_fn_29+0x157>
			5563: R_X86_64_PLT32	rt_type_error-0x4
    5567:	mov    rdi,r13
    556a:	mov    rdi,r13
    556d:	mov    QWORD PTR [rdi],rbx
    5570:	xor    rax,rax
    5573:	mov    rbx,QWORD PTR [rsp+0x10]
    5578:	mov    r12,QWORD PTR [rsp+0x18]
    557d:	mov    r13,QWORD PTR [rsp+0x20]
    5582:	mov    r14,QWORD PTR [rsp+0x28]
    5587:	mov    r15,QWORD PTR [rsp+0x30]
    558c:	add    rsp,0x40
    5590:	mov    rsp,rbp
    5593:	pop    rbp
    5594:	ret
    5595:	mov    r12,r8
    5598:	mov    rcx,rax
    559b:	and    rcx,r12
    559e:	test   rcx,0x1
    55a5:	jne    55b6 <botlish_fn_29+0x1a6>
    55ab:	mov    rdx,r8
    55ae:	mov    rsi,rax
    55b1:	jmp    55d7 <botlish_fn_29+0x1c7>
    55b6:	mov    r12,r8
    55b9:	mov    rcx,rax
    55bc:	sub    rcx,r12
    55bf:	mov    r14,rax
    55c2:	seto   al
    55c5:	lea    rsi,[rcx+0x1]
    55c9:	test   al,al
    55cb:	je     55e2 <botlish_fn_29+0x1d2>
    55d1:	mov    rdx,r8
    55d4:	mov    rsi,r14
    55d7:	mov    rdi,r13
    55da:	call   55df <botlish_fn_29+0x1cf>
			55db: R_X86_64_PLT32	rt_int_sub-0x4
    55df:	mov    rsi,rax
    55e2:	test   rsi,0x1
    55e9:	jne    5614 <botlish_fn_29+0x204>
    55ef:	mov    edx,0x5
    55f4:	mov    rdi,r13
    55f7:	call   55fc <botlish_fn_29+0x1ec>
			55f8: R_X86_64_PLT32	rt_int_cmp-0x4
    55fc:	mov    ecx,0x2
    5601:	test   rax,rax
    5604:	mov    rax,rcx
    5607:	cmovge rax,QWORD PTR [rip+0x71]        # 5680 <botlish_fn_29+0x270>
    560f:	jmp    5625 <botlish_fn_29+0x215>
    5614:	mov    eax,0x2
    5619:	cmp    rsi,0x5
    561d:	cmovge rax,QWORD PTR [rip+0x5b]        # 5680 <botlish_fn_29+0x270>
    5625:	mov    rdi,r13
    5628:	mov    rdi,r13
    562b:	mov    QWORD PTR [rdi],rbx
    562e:	mov    rbx,QWORD PTR [rsp+0x10]
    5633:	mov    r12,QWORD PTR [rsp+0x18]
    5638:	mov    r13,QWORD PTR [rsp+0x20]
    563d:	mov    r14,QWORD PTR [rsp+0x28]
    5642:	mov    r15,QWORD PTR [rsp+0x30]
    5647:	add    rsp,0x40
    564b:	mov    rsp,rbp
    564e:	pop    rbp
    564f:	ret
    5650:	mov    r13,rdi
    5653:	call   5658 <botlish_fn_29+0x248>
			5654: R_X86_64_PLT32	rt_stack_overflow-0x4
    5658:	xor    rax,rax
    565b:	mov    rbx,QWORD PTR [rsp+0x10]
    5660:	mov    r12,QWORD PTR [rsp+0x18]
    5665:	mov    r13,QWORD PTR [rsp+0x20]
    566a:	mov    r14,QWORD PTR [rsp+0x28]
    566f:	mov    r15,QWORD PTR [rsp+0x30]
    5674:	add    rsp,0x40
    5678:	mov    rsp,rbp
    567b:	pop    rbp
    567c:	ret
    567d:	add    BYTE PTR [rax],al
    567f:	add    BYTE PTR [rsi],al
    5681:	add    BYTE PTR [rax],al
    5683:	add    BYTE PTR [rax],al
    5685:	add    BYTE PTR [rax],al
	...

0000000000005688 <botlish_entry_29: tld_ok<generic>>:
    5688:	push   rbp
    5689:	mov    rbp,rsp
    568c:	mov    rdx,QWORD PTR [rdx]
    568f:	call   5694 <botlish_entry_29+0xc>
			5690: R_X86_64_PLT32	botlish_fn_29-0x4 ; tld_ok<generic>
    5694:	mov    rsp,rbp
    5697:	pop    rbp
    5698:	ret
    5699:	add    BYTE PTR [rax],al
    569b:	add    BYTE PTR [rax],al
    569d:	add    BYTE PTR [rax],al
	...

00000000000056a0 <botlish_fn_30: domain_loop<generic>>:
    56a0:	push   rbp
    56a1:	mov    rbp,rsp
    56a4:	sub    rsp,0x60
    56a8:	mov    QWORD PTR [rsp+0x30],rbx
    56ad:	mov    QWORD PTR [rsp+0x38],r12
    56b2:	mov    QWORD PTR [rsp+0x40],r13
    56b7:	mov    QWORD PTR [rsp+0x48],r14
    56bc:	mov    QWORD PTR [rsp+0x50],r15
    56c1:	mov    r13,QWORD PTR [rdi]
    56c4:	mov    rax,QWORD PTR [rdi+0x8]
    56c8:	lea    rcx,[r13+0x8]
    56cc:	cmp    rcx,rax
    56cf:	ja     594c <botlish_fn_30+0x2ac>
    56d5:	lea    rax,[r13+0x8]
    56d9:	mov    QWORD PTR [rdi],rax
    56dc:	mov    r15,rdi
    56df:	mov    QWORD PTR [r13+0x0],0x0
    56e7:	mov    QWORD PTR [rsp],rdx
    56eb:	mov    QWORD PTR [rsp+0x20],rdx
    56f0:	lea    rbx,[rsp+0x10]
    56f5:	mov    r12,rsi
    56f8:	mov    rax,QWORD PTR [r12+0x20]
    56fd:	mov    rsi,QWORD PTR [rax]
    5700:	mov    QWORD PTR [rsp+0x8],rsi
    5705:	mov    rdx,QWORD PTR [rsp+0x20]
    570a:	mov    rdi,r15
    570d:	call   5712 <botlish_fn_30+0x72>
			570e: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_label<generic>
    5712:	mov    rcx,rax
    5715:	mov    r14,rax
    5718:	test   rax,rcx
    571b:	jne    5729 <botlish_fn_30+0x89>
    5721:	mov    rdi,r15
    5724:	jmp    58ba <botlish_fn_30+0x21a>
    5729:	mov    rax,r14
    572c:	mov    QWORD PTR [rsp],rax
    5730:	mov    rdx,QWORD PTR [rsp+0x20]
    5735:	mov    rsi,rax
    5738:	and    rsi,rdx
    573b:	test   rsi,0x1
    5742:	jne    5769 <botlish_fn_30+0xc9>
    5748:	mov    rdx,QWORD PTR [rsp+0x20]
    574d:	mov    rsi,r14
    5750:	mov    rdi,r15
    5753:	call   5758 <botlish_fn_30+0xb8>
			5754: R_X86_64_PLT32	rt_value_eq-0x4
    5758:	test   rax,rax
    575b:	jne    577e <botlish_fn_30+0xde>
    5761:	mov    rdi,r15
    5764:	jmp    58ba <botlish_fn_30+0x21a>
    5769:	mov    eax,0x2
    576e:	mov    rdx,QWORD PTR [rsp+0x20]
    5773:	cmp    r14,rdx
    5776:	cmove  rax,QWORD PTR [rip+0x202]        # 5980 <botlish_fn_30+0x2e0>
    577e:	cmp    rax,0x6
    5782:	je     591a <botlish_fn_30+0x27a>
    5788:	mov    rax,QWORD PTR [r12+0x20]
    578d:	mov    rdx,QWORD PTR [rax+0x8]
    5791:	mov    rax,r14
    5794:	and    rax,rdx
    5797:	test   rax,0x1
    579d:	jne    57c3 <botlish_fn_30+0x123>
    57a3:	mov    rsi,r14
    57a6:	mov    rdi,r15
    57a9:	call   57ae <botlish_fn_30+0x10e>
			57aa: R_X86_64_PLT32	rt_int_cmp-0x4
    57ae:	mov    ecx,0x2
    57b3:	test   rax,rax
    57b6:	cmovge rcx,QWORD PTR [rip+0x1c2]        # 5980 <botlish_fn_30+0x2e0>
    57be:	jmp    57d3 <botlish_fn_30+0x133>
    57c3:	mov    ecx,0x2
    57c8:	cmp    r14,rdx
    57cb:	cmovge rcx,QWORD PTR [rip+0x1ad]        # 5980 <botlish_fn_30+0x2e0>
    57d3:	cmp    rcx,0x6
    57d7:	je     590b <botlish_fn_30+0x26b>
    57dd:	mov    rax,QWORD PTR [r12+0x20]
    57e2:	mov    rsi,QWORD PTR [rax+0x10]
    57e6:	mov    QWORD PTR [rsp+0x8],rsi
    57eb:	mov    rcx,rbx
    57ee:	mov    rdx,r14
    57f1:	mov    rdi,r15
    57f4:	call   57f9 <botlish_fn_30+0x159>
			57f5: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    57f9:	test   rax,rax
    57fc:	mov    rsi,rax
    57ff:	jne    580d <botlish_fn_30+0x16d>
    5805:	mov    rdi,r15
    5808:	jmp    58ba <botlish_fn_30+0x21a>
    580d:	mov    rdx,QWORD PTR [rsp+0x10]
    5812:	mov    rcx,QWORD PTR [rsp+0x18]
    5817:	mov    rdi,r15
    581a:	mov    rax,QWORD PTR [rdi+0x10]
    581e:	mov    r8,QWORD PTR [rax+0x118]
    5825:	call   582a <botlish_fn_30+0x18a>
			5826: R_X86_64_PLT32	rt_str_region_eq-0x4
    582a:	cmp    rax,0x6
    582e:	je     5840 <botlish_fn_30+0x1a0>
    5834:	mov    rax,0xffffffffffffffff
    583b:	jmp    5912 <botlish_fn_30+0x272>
    5840:	mov    QWORD PTR [rsp+0x8],0x3
    5849:	test   r14,0x1
    5850:	je     5877 <botlish_fn_30+0x1d7>
    5856:	mov    rdx,r14
    5859:	add    rdx,0x2
    585d:	mov    QWORD PTR [rsp+0x20],rdx
    5862:	seto   al
    5865:	test   al,al
    5867:	jne    5877 <botlish_fn_30+0x1d7>
    586d:	mov    rdx,QWORD PTR [rsp+0x20]
    5872:	jmp    588f <botlish_fn_30+0x1ef>
    5877:	mov    edx,0x3
    587c:	mov    rsi,r14
    587f:	mov    rdi,r15
    5882:	call   5887 <botlish_fn_30+0x1e7>
			5883: R_X86_64_PLT32	rt_int_add-0x4
    5887:	mov    rdx,rax
    588a:	mov    QWORD PTR [rsp+0x20],rax
    588f:	mov    QWORD PTR [rsp],rdx
    5893:	mov    rax,QWORD PTR [r12+0x20]
    5898:	mov    rsi,QWORD PTR [rax+0x18]
    589c:	mov    QWORD PTR [rsp+0x8],rsi
    58a1:	mov    rdx,QWORD PTR [rsp+0x20]
    58a6:	mov    rdi,r15
    58a9:	call   58ae <botlish_fn_30+0x20e>
			58aa: R_X86_64_PLT32	botlish_fn_29-0x4 ; tld_ok<generic>
    58ae:	test   rax,rax
    58b1:	jne    58e5 <botlish_fn_30+0x245>
    58b7:	mov    rdi,r15
    58ba:	mov    rdi,r15
    58bd:	mov    QWORD PTR [rdi],r13
    58c0:	xor    rax,rax
    58c3:	mov    rbx,QWORD PTR [rsp+0x30]
    58c8:	mov    r12,QWORD PTR [rsp+0x38]
    58cd:	mov    r13,QWORD PTR [rsp+0x40]
    58d2:	mov    r14,QWORD PTR [rsp+0x48]
    58d7:	mov    r15,QWORD PTR [rsp+0x50]
    58dc:	add    rsp,0x60
    58e0:	mov    rsp,rbp
    58e3:	pop    rbp
    58e4:	ret
    58e5:	cmp    rax,0x6
    58e9:	je     58fd <botlish_fn_30+0x25d>
    58ef:	mov    rdx,QWORD PTR [rsp+0x20]
    58f4:	mov    QWORD PTR [rsp],rdx
    58f8:	jmp    56f8 <botlish_fn_30+0x58>
    58fd:	mov    rax,QWORD PTR [r12+0x20]
    5902:	mov    rax,QWORD PTR [rax+0x8]
    5906:	jmp    5912 <botlish_fn_30+0x272>
    590b:	mov    rax,0xffffffffffffffff
    5912:	mov    rdi,r15
    5915:	jmp    5924 <botlish_fn_30+0x284>
    591a:	mov    rax,0xffffffffffffffff
    5921:	mov    rdi,r15
    5924:	mov    rdi,r15
    5927:	mov    QWORD PTR [rdi],r13
    592a:	mov    rbx,QWORD PTR [rsp+0x30]
    592f:	mov    r12,QWORD PTR [rsp+0x38]
    5934:	mov    r13,QWORD PTR [rsp+0x40]
    5939:	mov    r14,QWORD PTR [rsp+0x48]
    593e:	mov    r15,QWORD PTR [rsp+0x50]
    5943:	add    rsp,0x60
    5947:	mov    rsp,rbp
    594a:	pop    rbp
    594b:	ret
    594c:	mov    r15,rdi
    594f:	call   5954 <botlish_fn_30+0x2b4>
			5950: R_X86_64_PLT32	rt_stack_overflow-0x4
    5954:	xor    rax,rax
    5957:	mov    rbx,QWORD PTR [rsp+0x30]
    595c:	mov    r12,QWORD PTR [rsp+0x38]
    5961:	mov    r13,QWORD PTR [rsp+0x40]
    5966:	mov    r14,QWORD PTR [rsp+0x48]
    596b:	mov    r15,QWORD PTR [rsp+0x50]
    5970:	add    rsp,0x60
    5974:	mov    rsp,rbp
    5977:	pop    rbp
    5978:	ret
    5979:	add    BYTE PTR [rax],al
    597b:	add    BYTE PTR [rax],al
    597d:	add    BYTE PTR [rax],al
    597f:	add    BYTE PTR [rsi],al
    5981:	add    BYTE PTR [rax],al
    5983:	add    BYTE PTR [rax],al
    5985:	add    BYTE PTR [rax],al
	...

0000000000005988 <botlish_entry_30: domain_loop<generic>>:
    5988:	push   rbp
    5989:	mov    rbp,rsp
    598c:	mov    rdx,QWORD PTR [rdx]
    598f:	call   5994 <botlish_entry_30+0xc>
			5990: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    5994:	mov    rsp,rbp
    5997:	pop    rbp
    5998:	ret

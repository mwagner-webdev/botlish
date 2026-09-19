; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 25602  (per function: 453 592 1297 1369 522 573 495 263 609 609 609 665 777 1289 1353 522 573 495 263 609 609 609 665 777 1099 1099 1817 1529 672 1028 685 1076)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> check<int, int, str, str>
;   botlish_fn_2 / botlish_entry_2 -> <str>
;   botlish_fn_3 / botlish_entry_3 -> <generic>
;   botlish_fn_4 / botlish_entry_4 -> char_at<generic>
;   botlish_fn_5 / botlish_entry_5 -> char_at<generic>
;   botlish_fn_6 / botlish_entry_6 -> is_local_char<str>
;   botlish_fn_7 / botlish_entry_7 -> is_label_char<str>
;   botlish_fn_8 / botlish_entry_8 -> scan_local<generic>
;   botlish_fn_9 / botlish_entry_9 -> scan_label<generic>
;   botlish_fn_10 / botlish_entry_10 -> scan_alpha<generic>
;   botlish_fn_11 / botlish_entry_11 -> tld_ok<generic>
;   botlish_fn_12 / botlish_entry_12 -> domain_loop<generic>
;   botlish_fn_13 / botlish_entry_13 -> <str>
;   botlish_fn_14 / botlish_entry_14 -> <generic>
;   botlish_fn_15 / botlish_entry_15 -> char_at<generic>
;   botlish_fn_16 / botlish_entry_16 -> char_at<generic>
;   botlish_fn_17 / botlish_entry_17 -> is_local_char<str>
;   botlish_fn_18 / botlish_entry_18 -> is_label_char<str>
;   botlish_fn_19 / botlish_entry_19 -> scan_local<generic>
;   botlish_fn_20 / botlish_entry_20 -> scan_label<generic>
;   botlish_fn_21 / botlish_entry_21 -> scan_alpha<generic>
;   botlish_fn_22 / botlish_entry_22 -> tld_ok<generic>
;   botlish_fn_23 / botlish_entry_23 -> domain_loop<generic>
;   botlish_fn_24 / botlish_entry_24 -> <str>
;   botlish_fn_25 / botlish_entry_25 -> <generic>
;   botlish_fn_26 / botlish_entry_26 -> high_nibble<generic>
;   botlish_fn_27 / botlish_entry_27 -> is_unreserved<generic>
;   botlish_fn_28 / botlish_entry_28 -> hex_pair<generic>
;   botlish_fn_29 / botlish_entry_29 -> esc_bytes<generic>
;   botlish_fn_30 / botlish_entry_30 -> esc_char<generic>
;   botlish_fn_31 / botlish_entry_31 -> esc_from<generic>


refined-checks.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x30
       8:	mov    QWORD PTR [rsp+0x10],rbx
       d:	mov    QWORD PTR [rsp+0x18],r12
      12:	mov    QWORD PTR [rsp+0x20],r13
      17:	mov    QWORD PTR [rsp+0x28],r14
      1c:	mov    rbx,QWORD PTR [rdi]
      1f:	mov    rax,QWORD PTR [rdi+0x8]
      23:	lea    rcx,[rbx+0x28]
      27:	cmp    rcx,rax
      2a:	ja     181 <botlish_fn_0+0x181>
      30:	lea    rax,[rbx+0x28]
      34:	mov    QWORD PTR [rdi],rax
      37:	mov    QWORD PTR [rbx+0x8],0x0
      3f:	mov    QWORD PTR [rbx+0x10],0x0
      47:	mov    QWORD PTR [rbx+0x18],0x0
      4f:	mov    QWORD PTR [rbx+0x20],0x0
      57:	mov    rax,QWORD PTR [rdi+0x10]
      5b:	mov    r13,rdi
      5e:	mov    rcx,QWORD PTR [rax]
      61:	mov    rsi,QWORD PTR [rax+0x8]
      65:	mov    QWORD PTR [rbx],rsi
      68:	call   6d <botlish_fn_0+0x6d>
			69: R_X86_64_PLT32	botlish_fn_24-0x4 ; <str>
      6d:	test   rax,rax
      70:	jne    7e <botlish_fn_0+0x7e>
      76:	mov    rdi,r13
      79:	jmp    138 <botlish_fn_0+0x138>
      7e:	mov    QWORD PTR [rbx],rax
      81:	mov    r14,rax
      84:	mov    esi,0x321
      89:	mov    QWORD PTR [rbx+0x8],0x321
      91:	mov    edx,0x1
      96:	mov    QWORD PTR [rbx+0x10],0x1
      9e:	mov    rdi,r13
      a1:	mov    rcx,QWORD PTR [rdi+0x10]
      a5:	mov    rcx,QWORD PTR [rcx+0x10]
      a9:	mov    QWORD PTR [rbx+0x18],rcx
      ad:	mov    r8,r14
      b0:	call   b5 <botlish_fn_0+0xb5>
			b1: R_X86_64_PLT32	botlish_fn_1-0x4 ; check<int, int, str, str>
      b5:	mov    r12,rax
      b8:	test   r12,r12
      bb:	jne    c9 <botlish_fn_0+0xc9>
      c1:	mov    rdi,r13
      c4:	jmp    138 <botlish_fn_0+0x138>
      c9:	mov    QWORD PTR [rbx+0x8],r12
      cd:	mov    esi,0x321
      d2:	mov    QWORD PTR [rbx+0x10],0x321
      da:	mov    edx,0x1
      df:	mov    QWORD PTR [rbx+0x18],0x1
      e7:	mov    rdi,r13
      ea:	mov    rax,QWORD PTR [rdi+0x10]
      ee:	mov    rcx,QWORD PTR [rax+0x18]
      f2:	mov    QWORD PTR [rbx+0x20],rcx
      f6:	mov    r8,r14
      f9:	call   fe <botlish_fn_0+0xfe>
			fa: R_X86_64_PLT32	botlish_fn_1-0x4 ; check<int, int, str, str>
      fe:	test   rax,rax
     101:	jne    10f <botlish_fn_0+0x10f>
     107:	mov    rdi,r13
     10a:	jmp    138 <botlish_fn_0+0x138>
     10f:	mov    QWORD PTR [rbx],rax
     112:	lea    rdx,[rsp]
     116:	mov    QWORD PTR [rsp],r12
     11a:	mov    QWORD PTR [rsp+0x8],rax
     11f:	mov    esi,0x2
     124:	mov    rdi,r13
     127:	call   12c <botlish_fn_0+0x12c>
			128: R_X86_64_PLT32	rt_list_new-0x4
     12c:	test   rax,rax
     12f:	jne    15e <botlish_fn_0+0x15e>
     135:	mov    rdi,r13
     138:	mov    rdi,r13
     13b:	mov    QWORD PTR [rdi],rbx
     13e:	xor    rax,rax
     141:	mov    rbx,QWORD PTR [rsp+0x10]
     146:	mov    r12,QWORD PTR [rsp+0x18]
     14b:	mov    r13,QWORD PTR [rsp+0x20]
     150:	mov    r14,QWORD PTR [rsp+0x28]
     155:	add    rsp,0x30
     159:	mov    rsp,rbp
     15c:	pop    rbp
     15d:	ret
     15e:	mov    rdi,r13
     161:	mov    QWORD PTR [rdi],rbx
     164:	mov    rbx,QWORD PTR [rsp+0x10]
     169:	mov    r12,QWORD PTR [rsp+0x18]
     16e:	mov    r13,QWORD PTR [rsp+0x20]
     173:	mov    r14,QWORD PTR [rsp+0x28]
     178:	add    rsp,0x30
     17c:	mov    rsp,rbp
     17f:	pop    rbp
     180:	ret
     181:	mov    r13,rdi
     184:	call   189 <botlish_fn_0+0x189>
			185: R_X86_64_PLT32	rt_stack_overflow-0x4
     189:	xor    rax,rax
     18c:	mov    rbx,QWORD PTR [rsp+0x10]
     191:	mov    r12,QWORD PTR [rsp+0x18]
     196:	mov    r13,QWORD PTR [rsp+0x20]
     19b:	mov    r14,QWORD PTR [rsp+0x28]
     1a0:	add    rsp,0x30
     1a4:	mov    rsp,rbp
     1a7:	pop    rbp
     1a8:	ret

00000000000001a9 <botlish_entry_0: <program entry>>:
     1a9:	push   rbp
     1aa:	mov    rbp,rsp
     1ad:	call   1b2 <botlish_entry_0+0x9>
			1ae: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     1b2:	mov    rsp,rbp
     1b5:	pop    rbp
     1b6:	ret
	...

00000000000001b8 <botlish_fn_1: check<int, int, str, str>>:
     1b8:	push   rbp
     1b9:	mov    rbp,rsp
     1bc:	sub    rsp,0x40
     1c0:	mov    QWORD PTR [rsp+0x10],rbx
     1c5:	mov    QWORD PTR [rsp+0x18],r12
     1ca:	mov    QWORD PTR [rsp+0x20],r13
     1cf:	mov    QWORD PTR [rsp+0x28],r14
     1d4:	mov    QWORD PTR [rsp+0x30],r15
     1d9:	mov    r13,QWORD PTR [rdi]
     1dc:	mov    rax,QWORD PTR [rdi+0x8]
     1e0:	lea    r9,[r13+0x28]
     1e4:	cmp    r9,rax
     1e7:	ja     39d <botlish_fn_1+0x1e5>
     1ed:	lea    rax,[r13+0x28]
     1f1:	mov    QWORD PTR [rdi],rax
     1f4:	mov    r14,rdi
     1f7:	mov    QWORD PTR [r13+0x20],0x0
     1ff:	mov    QWORD PTR [r13+0x0],rsi
     203:	mov    QWORD PTR [r13+0x8],rdx
     207:	mov    QWORD PTR [r13+0x10],rcx
     20b:	mov    r12,rcx
     20e:	mov    QWORD PTR [r13+0x18],r8
     212:	mov    r15,r8
     215:	mov    rbx,rsi
     218:	mov    QWORD PTR [rsp],rdx
     21c:	test   rbx,0x1
     223:	jne    24e <botlish_fn_1+0x96>
     229:	mov    edx,0x1
     22e:	mov    rsi,rbx
     231:	mov    rdi,r14
     234:	call   239 <botlish_fn_1+0x81>
			235: R_X86_64_PLT32	rt_int_cmp-0x4
     239:	mov    ecx,0x2
     23e:	test   rax,rax
     241:	cmovle rcx,QWORD PTR [rip+0x187]        # 3d0 <botlish_fn_1+0x218>
     249:	jmp    25f <botlish_fn_1+0xa7>
     24e:	mov    ecx,0x2
     253:	cmp    rbx,0x1
     257:	cmovle rcx,QWORD PTR [rip+0x171]        # 3d0 <botlish_fn_1+0x218>
     25f:	cmp    rcx,0x6
     263:	je     371 <botlish_fn_1+0x1b9>
     269:	mov    rdi,r14
     26c:	mov    rax,QWORD PTR [rdi+0x10]
     270:	mov    rax,QWORD PTR [rax+0x20]
     274:	mov    rsi,r12
     277:	call   27c <botlish_fn_1+0xc4>
			278: R_X86_64_PLT32	botlish_fn_2-0x4 ; <str>
     27c:	test   rax,rax
     27f:	jne    28d <botlish_fn_1+0xd5>
     285:	mov    rdi,r14
     288:	jmp    2c8 <botlish_fn_1+0x110>
     28d:	cmp    rax,0x6
     291:	je     2a9 <botlish_fn_1+0xf1>
     297:	mov    edx,0x1
     29c:	mov    QWORD PTR [r13+0x0],0x1
     2a4:	jmp    310 <botlish_fn_1+0x158>
     2a9:	mov    rdi,r14
     2ac:	mov    rsi,QWORD PTR [rdi+0x10]
     2b0:	mov    rsi,QWORD PTR [rsi+0x28]
     2b4:	mov    rsi,r12
     2b7:	call   2bc <botlish_fn_1+0x104>
			2b8: R_X86_64_PLT32	botlish_fn_13-0x4 ; <str>
     2bc:	test   rax,rax
     2bf:	jne    2f3 <botlish_fn_1+0x13b>
     2c5:	mov    rdi,r14
     2c8:	mov    rdi,r14
     2cb:	mov    QWORD PTR [rdi],r13
     2ce:	xor    rax,rax
     2d1:	mov    rbx,QWORD PTR [rsp+0x10]
     2d6:	mov    r12,QWORD PTR [rsp+0x18]
     2db:	mov    r13,QWORD PTR [rsp+0x20]
     2e0:	mov    r14,QWORD PTR [rsp+0x28]
     2e5:	mov    r15,QWORD PTR [rsp+0x30]
     2ea:	add    rsp,0x40
     2ee:	mov    rsp,rbp
     2f1:	pop    rbp
     2f2:	ret
     2f3:	cmp    rax,0x6
     2f7:	je     307 <botlish_fn_1+0x14f>
     2fd:	mov    edx,0x1
     302:	jmp    30c <botlish_fn_1+0x154>
     307:	mov    edx,0x3
     30c:	mov    QWORD PTR [r13+0x0],rdx
     310:	sar    rbx,1
     313:	sub    rbx,0x1
     317:	shl    rbx,1
     31a:	or     rbx,0x1
     31e:	mov    QWORD PTR [r13+0x20],rbx
     322:	mov    rsi,QWORD PTR [rsp]
     326:	mov    rax,rsi
     329:	and    rax,rdx
     32c:	test   rax,0x1
     332:	je     34d <botlish_fn_1+0x195>
     338:	lea    rcx,[rdx-0x1]
     33c:	mov    rax,rsi
     33f:	add    rax,rcx
     342:	seto   cl
     345:	test   cl,cl
     347:	je     355 <botlish_fn_1+0x19d>
     34d:	mov    rdi,r14
     350:	call   355 <botlish_fn_1+0x19d>
			351: R_X86_64_PLT32	rt_int_add-0x4
     355:	mov    QWORD PTR [r13+0x0],rbx
     359:	mov    QWORD PTR [r13+0x8],rax
     35d:	mov    QWORD PTR [r13+0x10],r12
     361:	mov    r8,r15
     364:	mov    QWORD PTR [r13+0x18],r8
     368:	mov    QWORD PTR [rsp],rax
     36c:	jmp    21c <botlish_fn_1+0x64>
     371:	mov    rdi,r14
     374:	mov    QWORD PTR [rdi],r13
     377:	mov    rax,QWORD PTR [rsp]
     37b:	mov    rbx,QWORD PTR [rsp+0x10]
     380:	mov    r12,QWORD PTR [rsp+0x18]
     385:	mov    r13,QWORD PTR [rsp+0x20]
     38a:	mov    r14,QWORD PTR [rsp+0x28]
     38f:	mov    r15,QWORD PTR [rsp+0x30]
     394:	add    rsp,0x40
     398:	mov    rsp,rbp
     39b:	pop    rbp
     39c:	ret
     39d:	mov    r14,rdi
     3a0:	call   3a5 <botlish_fn_1+0x1ed>
			3a1: R_X86_64_PLT32	rt_stack_overflow-0x4
     3a5:	xor    rax,rax
     3a8:	mov    rbx,QWORD PTR [rsp+0x10]
     3ad:	mov    r12,QWORD PTR [rsp+0x18]
     3b2:	mov    r13,QWORD PTR [rsp+0x20]
     3b7:	mov    r14,QWORD PTR [rsp+0x28]
     3bc:	mov    r15,QWORD PTR [rsp+0x30]
     3c1:	add    rsp,0x40
     3c5:	mov    rsp,rbp
     3c8:	pop    rbp
     3c9:	ret
     3ca:	add    BYTE PTR [rax],al
     3cc:	add    BYTE PTR [rax],al
     3ce:	add    BYTE PTR [rax],al
     3d0:	(bad)
     3d1:	add    BYTE PTR [rax],al
     3d3:	add    BYTE PTR [rax],al
     3d5:	add    BYTE PTR [rax],al
	...

00000000000003d8 <botlish_entry_1: check<int, int, str, str>>:
     3d8:	push   rbp
     3d9:	mov    rbp,rsp
     3dc:	mov    rsi,QWORD PTR [rdx]
     3df:	mov    r9,QWORD PTR [rdx+0x8]
     3e3:	mov    rcx,QWORD PTR [rdx+0x10]
     3e7:	mov    r8,QWORD PTR [rdx+0x18]
     3eb:	mov    rdx,r9
     3ee:	call   3f3 <botlish_entry_1+0x1b>
			3ef: R_X86_64_PLT32	botlish_fn_1-0x4 ; check<int, int, str, str>
     3f3:	mov    rsp,rbp
     3f6:	pop    rbp
     3f7:	ret

00000000000003f8 <botlish_fn_2: <str>>:
     3f8:	push   rbp
     3f9:	mov    rbp,rsp
     3fc:	sub    rsp,0xd0
     403:	mov    QWORD PTR [rsp+0xa0],rbx
     40b:	mov    QWORD PTR [rsp+0xa8],r12
     413:	mov    QWORD PTR [rsp+0xb0],r13
     41b:	mov    QWORD PTR [rsp+0xb8],r14
     423:	mov    QWORD PTR [rsp+0xc0],r15
     42b:	mov    r12,QWORD PTR [rdi]
     42e:	mov    rax,QWORD PTR [rdi+0x8]
     432:	lea    rcx,[r12+0x28]
     437:	cmp    rcx,rax
     43a:	ja     854 <botlish_fn_2+0x45c>
     440:	lea    rax,[r12+0x28]
     445:	mov    QWORD PTR [rdi],rax
     448:	mov    QWORD PTR [rsp+0x78],rdi
     44d:	mov    QWORD PTR [r12+0x10],0x0
     456:	mov    QWORD PTR [r12+0x18],0x0
     45f:	mov    QWORD PTR [r12+0x20],0x0
     468:	mov    QWORD PTR [r12],rsi
     46c:	mov    r13,rsi
     46f:	mov    rsi,r13
     472:	mov    rdi,QWORD PTR [rsp+0x78]
     477:	call   47c <botlish_fn_2+0x84>
			478: R_X86_64_PLT32	rt_str_len-0x4
     47c:	mov    rbx,rax
     47f:	mov    QWORD PTR [r12+0x8],rbx
     484:	lea    r8,[rsp]
     488:	mov    QWORD PTR [rsp],r13
     48c:	mov    r13d,0x4
     492:	mov    rdx,QWORD PTR [rip+0x0]        # 499 <botlish_fn_2+0xa1>
			495: R_X86_64_GOTPCREL	botlish_entry_4-0x4 ; char_at<generic>
     499:	mov    ecx,0x1
     49e:	mov    QWORD PTR [rsp+0x90],rcx
     4a6:	mov    rsi,r13
     4a9:	mov    rdi,QWORD PTR [rsp+0x78]
     4ae:	call   4b3 <botlish_fn_2+0xbb>
			4af: R_X86_64_PLT32	rt_closure_new-0x4
     4b3:	mov    r14,rax
     4b6:	mov    QWORD PTR [r12],rax
     4ba:	lea    r8,[rsp+0x8]
     4bf:	mov    QWORD PTR [rsp+0x8],rbx
     4c4:	mov    QWORD PTR [rsp+0x10],rax
     4c9:	mov    esi,0x8
     4ce:	mov    rdx,QWORD PTR [rip+0x0]        # 4d5 <botlish_fn_2+0xdd>
			4d1: R_X86_64_GOTPCREL	botlish_entry_8-0x4 ; scan_local<generic>
     4d5:	mov    r15d,0x2
     4db:	mov    rcx,r15
     4de:	mov    rdi,QWORD PTR [rsp+0x78]
     4e3:	call   4e8 <botlish_fn_2+0xf0>
			4e4: R_X86_64_PLT32	rt_closure_new-0x4
     4e8:	mov    rcx,rax
     4eb:	mov    QWORD PTR [rsp+0x88],rax
     4f3:	mov    QWORD PTR [r12+0x10],rcx
     4f8:	lea    r8,[rsp+0x18]
     4fd:	mov    QWORD PTR [rsp+0x18],rbx
     502:	mov    rax,r14
     505:	mov    QWORD PTR [rsp+0x20],rax
     50a:	mov    esi,0x9
     50f:	mov    rdx,QWORD PTR [rip+0x0]        # 516 <botlish_fn_2+0x11e>
			512: R_X86_64_GOTPCREL	botlish_entry_9-0x4 ; scan_label<generic>
     516:	mov    rcx,r15
     519:	mov    rdi,QWORD PTR [rsp+0x78]
     51e:	call   523 <botlish_fn_2+0x12b>
			51f: R_X86_64_PLT32	rt_closure_new-0x4
     523:	mov    QWORD PTR [r12+0x18],rax
     528:	mov    QWORD PTR [rsp+0x80],rax
     530:	lea    r8,[rsp+0x28]
     535:	mov    QWORD PTR [rsp+0x28],rbx
     53a:	mov    QWORD PTR [rsp+0x30],r14
     53f:	mov    esi,0xa
     544:	mov    rdx,QWORD PTR [rip+0x0]        # 54b <botlish_fn_2+0x153>
			547: R_X86_64_GOTPCREL	botlish_entry_10-0x4 ; scan_alpha<generic>
     54b:	mov    rcx,r15
     54e:	mov    rdi,QWORD PTR [rsp+0x78]
     553:	call   558 <botlish_fn_2+0x160>
			554: R_X86_64_PLT32	rt_closure_new-0x4
     558:	mov    QWORD PTR [r12+0x20],rax
     55d:	lea    r8,[rsp+0x38]
     562:	mov    QWORD PTR [rsp+0x38],rax
     567:	mov    QWORD PTR [rsp+0x40],rbx
     56c:	mov    esi,0xb
     571:	mov    rdx,QWORD PTR [rip+0x0]        # 578 <botlish_fn_2+0x180>
			574: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; tld_ok<generic>
     578:	mov    rcx,r15
     57b:	mov    rdi,QWORD PTR [rsp+0x78]
     580:	call   585 <botlish_fn_2+0x18d>
			581: R_X86_64_PLT32	rt_closure_new-0x4
     585:	mov    QWORD PTR [r12+0x20],rax
     58a:	lea    r8,[rsp+0x48]
     58f:	mov    rcx,QWORD PTR [rsp+0x80]
     597:	mov    QWORD PTR [rsp+0x48],rcx
     59c:	mov    QWORD PTR [rsp+0x50],rbx
     5a1:	mov    QWORD PTR [rsp+0x58],r14
     5a6:	mov    QWORD PTR [rsp+0x60],rax
     5ab:	mov    esi,0xc
     5b0:	mov    rdx,QWORD PTR [rip+0x0]        # 5b7 <botlish_fn_2+0x1bf>
			5b3: R_X86_64_GOTPCREL	botlish_entry_12-0x4 ; domain_loop<generic>
     5b7:	mov    rcx,r13
     5ba:	mov    rdi,QWORD PTR [rsp+0x78]
     5bf:	call   5c4 <botlish_fn_2+0x1cc>
			5c0: R_X86_64_PLT32	rt_closure_new-0x4
     5c4:	mov    QWORD PTR [r12+0x18],rax
     5c9:	mov    r15,rax
     5cc:	mov    QWORD PTR [r12+0x20],0x1
     5d5:	mov    rdx,QWORD PTR [rsp+0x90]
     5dd:	mov    rsi,QWORD PTR [rsp+0x88]
     5e5:	mov    rdi,QWORD PTR [rsp+0x78]
     5ea:	call   5ef <botlish_fn_2+0x1f7>
			5eb: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_local<generic>
     5ef:	mov    rcx,rax
     5f2:	mov    r13,rax
     5f5:	test   rax,rcx
     5f8:	jne    608 <botlish_fn_2+0x210>
     5fe:	mov    rdi,QWORD PTR [rsp+0x78]
     603:	jmp    76a <botlish_fn_2+0x372>
     608:	mov    rax,r13
     60b:	mov    QWORD PTR [r12+0x10],rax
     610:	test   rax,0x1
     616:	jne    644 <botlish_fn_2+0x24c>
     61c:	mov    edx,0x1
     621:	mov    rsi,r13
     624:	mov    rdi,QWORD PTR [rsp+0x78]
     629:	call   62e <botlish_fn_2+0x236>
			62a: R_X86_64_PLT32	rt_int_cmp-0x4
     62e:	mov    r9d,0x2
     634:	test   rax,rax
     637:	cmove  r9,QWORD PTR [rip+0x259]        # 898 <botlish_fn_2+0x4a0>
     63f:	jmp    656 <botlish_fn_2+0x25e>
     644:	mov    r9d,0x2
     64a:	cmp    r13,0x1
     64e:	cmove  r9,QWORD PTR [rip+0x242]        # 898 <botlish_fn_2+0x4a0>
     656:	cmp    r9,0x6
     65a:	je     80e <botlish_fn_2+0x416>
     660:	mov    rax,r13
     663:	and    rax,rbx
     666:	test   rax,0x1
     66c:	jne    697 <botlish_fn_2+0x29f>
     672:	mov    rdx,rbx
     675:	mov    rsi,r13
     678:	mov    rdi,QWORD PTR [rsp+0x78]
     67d:	call   682 <botlish_fn_2+0x28a>
			67e: R_X86_64_PLT32	rt_int_cmp-0x4
     682:	mov    ecx,0x2
     687:	test   rax,rax
     68a:	cmovge rcx,QWORD PTR [rip+0x206]        # 898 <botlish_fn_2+0x4a0>
     692:	jmp    6a7 <botlish_fn_2+0x2af>
     697:	mov    ecx,0x2
     69c:	cmp    r13,rbx
     69f:	cmovge rcx,QWORD PTR [rip+0x1f1]        # 898 <botlish_fn_2+0x4a0>
     6a7:	cmp    rcx,0x6
     6ab:	je     7ff <botlish_fn_2+0x407>
     6b1:	lea    rcx,[rsp+0x68]
     6b6:	mov    rsi,r14
     6b9:	mov    rdx,r13
     6bc:	mov    rdi,QWORD PTR [rsp+0x78]
     6c1:	call   6c6 <botlish_fn_2+0x2ce>
			6c2: R_X86_64_PLT32	botlish_fn_5-0x4 ; char_at<generic>
     6c6:	test   rax,rax
     6c9:	jne    6d9 <botlish_fn_2+0x2e1>
     6cf:	mov    rdi,QWORD PTR [rsp+0x78]
     6d4:	jmp    76a <botlish_fn_2+0x372>
     6d9:	mov    rdx,QWORD PTR [rsp+0x68]
     6de:	mov    rcx,QWORD PTR [rsp+0x70]
     6e3:	mov    rdi,QWORD PTR [rsp+0x78]
     6e8:	mov    rsi,QWORD PTR [rdi+0x10]
     6ec:	mov    r8,QWORD PTR [rsi+0x40]
     6f0:	mov    rsi,rax
     6f3:	call   6f8 <botlish_fn_2+0x300>
			6f4: R_X86_64_PLT32	rt_str_region_eq-0x4
     6f8:	cmp    rax,0x6
     6fc:	je     70f <botlish_fn_2+0x317>
     702:	mov    ecx,0x2
     707:	mov    rax,rcx
     70a:	jmp    804 <botlish_fn_2+0x40c>
     70f:	mov    QWORD PTR [r12],0x3
     717:	test   r13,0x1
     71e:	je     736 <botlish_fn_2+0x33e>
     724:	mov    rdx,r13
     727:	add    rdx,0x2
     72b:	seto   al
     72e:	test   al,al
     730:	je     74b <botlish_fn_2+0x353>
     736:	mov    edx,0x3
     73b:	mov    rsi,r13
     73e:	mov    rdi,QWORD PTR [rsp+0x78]
     743:	call   748 <botlish_fn_2+0x350>
			744: R_X86_64_PLT32	rt_int_add-0x4
     748:	mov    rdx,rax
     74b:	mov    QWORD PTR [r12],rdx
     74f:	mov    rsi,r15
     752:	mov    rdi,QWORD PTR [rsp+0x78]
     757:	call   75c <botlish_fn_2+0x364>
			758: R_X86_64_PLT32	botlish_fn_12-0x4 ; domain_loop<generic>
     75c:	test   rax,rax
     75f:	jne    7a9 <botlish_fn_2+0x3b1>
     765:	mov    rdi,QWORD PTR [rsp+0x78]
     76a:	mov    rdi,QWORD PTR [rsp+0x78]
     76f:	mov    QWORD PTR [rdi],r12
     772:	xor    rax,rax
     775:	mov    rbx,QWORD PTR [rsp+0xa0]
     77d:	mov    r12,QWORD PTR [rsp+0xa8]
     785:	mov    r13,QWORD PTR [rsp+0xb0]
     78d:	mov    r14,QWORD PTR [rsp+0xb8]
     795:	mov    r15,QWORD PTR [rsp+0xc0]
     79d:	add    rsp,0xd0
     7a4:	mov    rsp,rbp
     7a7:	pop    rbp
     7a8:	ret
     7a9:	mov    rcx,rax
     7ac:	and    rcx,rbx
     7af:	mov    rsi,rax
     7b2:	mov    rax,rbx
     7b5:	test   rcx,0x1
     7bc:	jne    7e7 <botlish_fn_2+0x3ef>
     7c2:	mov    rdx,rax
     7c5:	mov    rdi,QWORD PTR [rsp+0x78]
     7ca:	call   7cf <botlish_fn_2+0x3d7>
			7cb: R_X86_64_PLT32	rt_int_cmp-0x4
     7cf:	mov    ecx,0x2
     7d4:	test   rax,rax
     7d7:	mov    rax,rcx
     7da:	cmove  rax,QWORD PTR [rip+0xb6]        # 898 <botlish_fn_2+0x4a0>
     7e2:	jmp    804 <botlish_fn_2+0x40c>
     7e7:	mov    rdx,rax
     7ea:	mov    eax,0x2
     7ef:	cmp    rsi,rdx
     7f2:	cmove  rax,QWORD PTR [rip+0x9e]        # 898 <botlish_fn_2+0x4a0>
     7fa:	jmp    804 <botlish_fn_2+0x40c>
     7ff:	mov    eax,0x2
     804:	mov    rdi,QWORD PTR [rsp+0x78]
     809:	jmp    818 <botlish_fn_2+0x420>
     80e:	mov    eax,0x2
     813:	mov    rdi,QWORD PTR [rsp+0x78]
     818:	mov    rdi,QWORD PTR [rsp+0x78]
     81d:	mov    QWORD PTR [rdi],r12
     820:	mov    rbx,QWORD PTR [rsp+0xa0]
     828:	mov    r12,QWORD PTR [rsp+0xa8]
     830:	mov    r13,QWORD PTR [rsp+0xb0]
     838:	mov    r14,QWORD PTR [rsp+0xb8]
     840:	mov    r15,QWORD PTR [rsp+0xc0]
     848:	add    rsp,0xd0
     84f:	mov    rsp,rbp
     852:	pop    rbp
     853:	ret
     854:	mov    QWORD PTR [rsp+0x78],rdi
     859:	call   85e <botlish_fn_2+0x466>
			85a: R_X86_64_PLT32	rt_stack_overflow-0x4
     85e:	xor    rax,rax
     861:	mov    rbx,QWORD PTR [rsp+0xa0]
     869:	mov    r12,QWORD PTR [rsp+0xa8]
     871:	mov    r13,QWORD PTR [rsp+0xb0]
     879:	mov    r14,QWORD PTR [rsp+0xb8]
     881:	mov    r15,QWORD PTR [rsp+0xc0]
     889:	add    rsp,0xd0
     890:	mov    rsp,rbp
     893:	pop    rbp
     894:	ret
     895:	add    BYTE PTR [rax],al
     897:	add    BYTE PTR [rsi],al
     899:	add    BYTE PTR [rax],al
     89b:	add    BYTE PTR [rax],al
     89d:	add    BYTE PTR [rax],al
	...

00000000000008a0 <botlish_entry_2: <str>>:
     8a0:	push   rbp
     8a1:	mov    rbp,rsp
     8a4:	mov    rsi,QWORD PTR [rdx]
     8a7:	call   8ac <botlish_entry_2+0xc>
			8a8: R_X86_64_PLT32	botlish_fn_2-0x4 ; <str>
     8ac:	mov    rsp,rbp
     8af:	pop    rbp
     8b0:	ret
     8b1:	add    BYTE PTR [rax],al
     8b3:	add    BYTE PTR [rax],al
     8b5:	add    BYTE PTR [rax],al
	...

00000000000008b8 <botlish_fn_3: <generic>>:
     8b8:	push   rbp
     8b9:	mov    rbp,rsp
     8bc:	sub    rsp,0xd0
     8c3:	mov    QWORD PTR [rsp+0xa0],rbx
     8cb:	mov    QWORD PTR [rsp+0xa8],r12
     8d3:	mov    QWORD PTR [rsp+0xb0],r13
     8db:	mov    QWORD PTR [rsp+0xb8],r14
     8e3:	mov    QWORD PTR [rsp+0xc0],r15
     8eb:	mov    r12,QWORD PTR [rdi]
     8ee:	mov    rax,QWORD PTR [rdi+0x8]
     8f2:	lea    rcx,[r12+0x28]
     8f7:	cmp    rcx,rax
     8fa:	ja     d53 <botlish_fn_3+0x49b>
     900:	lea    rax,[r12+0x28]
     905:	mov    QWORD PTR [rdi],rax
     908:	mov    QWORD PTR [r12+0x10],0x0
     911:	mov    QWORD PTR [r12+0x18],0x0
     91a:	mov    QWORD PTR [r12+0x20],0x0
     923:	mov    QWORD PTR [r12],rsi
     927:	xor    eax,eax
     929:	test   rsi,0x7
     930:	jne    93f <botlish_fn_3+0x87>
     936:	movzx  rax,BYTE PTR [rsi]
     93a:	cmp    al,0x2
     93c:	sete   al
     93f:	test   al,al
     941:	jne    968 <botlish_fn_3+0xb0>
     947:	mov    rax,QWORD PTR [rdi+0x10]
     94b:	mov    QWORD PTR [rsp+0x78],rdi
     950:	mov    rcx,QWORD PTR [rax+0x48]
     954:	mov    edx,0x1
     959:	call   95e <botlish_fn_3+0xa6>
			95a: R_X86_64_PLT32	rt_type_error-0x4
     95e:	mov    rdi,QWORD PTR [rsp+0x78]
     963:	jmp    c69 <botlish_fn_3+0x3b1>
     968:	mov    r13,rsi
     96b:	mov    QWORD PTR [rsp+0x78],rdi
     970:	call   975 <botlish_fn_3+0xbd>
			971: R_X86_64_PLT32	rt_str_len-0x4
     975:	mov    rbx,rax
     978:	mov    QWORD PTR [r12+0x8],rbx
     97d:	lea    r8,[rsp]
     981:	mov    QWORD PTR [rsp],r13
     985:	mov    r13d,0x4
     98b:	mov    rdx,QWORD PTR [rip+0x0]        # 992 <botlish_fn_3+0xda>
			98e: R_X86_64_GOTPCREL	botlish_entry_4-0x4 ; char_at<generic>
     992:	mov    r14d,0x1
     998:	mov    rcx,r14
     99b:	mov    rsi,r13
     99e:	mov    rdi,QWORD PTR [rsp+0x78]
     9a3:	call   9a8 <botlish_fn_3+0xf0>
			9a4: R_X86_64_PLT32	rt_closure_new-0x4
     9a8:	mov    QWORD PTR [rsp+0x90],r14
     9b0:	mov    r14,rax
     9b3:	mov    QWORD PTR [r12],rax
     9b7:	lea    r8,[rsp+0x8]
     9bc:	mov    QWORD PTR [rsp+0x8],rbx
     9c1:	mov    QWORD PTR [rsp+0x10],rax
     9c6:	mov    esi,0x8
     9cb:	mov    rdx,QWORD PTR [rip+0x0]        # 9d2 <botlish_fn_3+0x11a>
			9ce: R_X86_64_GOTPCREL	botlish_entry_8-0x4 ; scan_local<generic>
     9d2:	mov    r15d,0x2
     9d8:	mov    rcx,r15
     9db:	mov    rdi,QWORD PTR [rsp+0x78]
     9e0:	call   9e5 <botlish_fn_3+0x12d>
			9e1: R_X86_64_PLT32	rt_closure_new-0x4
     9e5:	mov    rcx,rax
     9e8:	mov    QWORD PTR [rsp+0x88],rax
     9f0:	mov    QWORD PTR [r12+0x10],rcx
     9f5:	lea    r8,[rsp+0x18]
     9fa:	mov    QWORD PTR [rsp+0x18],rbx
     9ff:	mov    rax,r14
     a02:	mov    QWORD PTR [rsp+0x20],rax
     a07:	mov    esi,0x9
     a0c:	mov    rdx,QWORD PTR [rip+0x0]        # a13 <botlish_fn_3+0x15b>
			a0f: R_X86_64_GOTPCREL	botlish_entry_9-0x4 ; scan_label<generic>
     a13:	mov    rcx,r15
     a16:	mov    rdi,QWORD PTR [rsp+0x78]
     a1b:	call   a20 <botlish_fn_3+0x168>
			a1c: R_X86_64_PLT32	rt_closure_new-0x4
     a20:	mov    QWORD PTR [r12+0x18],rax
     a25:	mov    QWORD PTR [rsp+0x80],rax
     a2d:	lea    r8,[rsp+0x28]
     a32:	mov    QWORD PTR [rsp+0x28],rbx
     a37:	mov    QWORD PTR [rsp+0x30],r14
     a3c:	mov    esi,0xa
     a41:	mov    rdx,QWORD PTR [rip+0x0]        # a48 <botlish_fn_3+0x190>
			a44: R_X86_64_GOTPCREL	botlish_entry_10-0x4 ; scan_alpha<generic>
     a48:	mov    rcx,r15
     a4b:	mov    rdi,QWORD PTR [rsp+0x78]
     a50:	call   a55 <botlish_fn_3+0x19d>
			a51: R_X86_64_PLT32	rt_closure_new-0x4
     a55:	mov    QWORD PTR [r12+0x20],rax
     a5a:	lea    r8,[rsp+0x38]
     a5f:	mov    QWORD PTR [rsp+0x38],rax
     a64:	mov    QWORD PTR [rsp+0x40],rbx
     a69:	mov    esi,0xb
     a6e:	mov    rdx,QWORD PTR [rip+0x0]        # a75 <botlish_fn_3+0x1bd>
			a71: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; tld_ok<generic>
     a75:	mov    rcx,r15
     a78:	mov    rdi,QWORD PTR [rsp+0x78]
     a7d:	call   a82 <botlish_fn_3+0x1ca>
			a7e: R_X86_64_PLT32	rt_closure_new-0x4
     a82:	mov    QWORD PTR [r12+0x20],rax
     a87:	lea    r8,[rsp+0x48]
     a8c:	mov    rcx,QWORD PTR [rsp+0x80]
     a94:	mov    QWORD PTR [rsp+0x48],rcx
     a99:	mov    QWORD PTR [rsp+0x50],rbx
     a9e:	mov    QWORD PTR [rsp+0x58],r14
     aa3:	mov    QWORD PTR [rsp+0x60],rax
     aa8:	mov    esi,0xc
     aad:	mov    rdx,QWORD PTR [rip+0x0]        # ab4 <botlish_fn_3+0x1fc>
			ab0: R_X86_64_GOTPCREL	botlish_entry_12-0x4 ; domain_loop<generic>
     ab4:	mov    rcx,r13
     ab7:	mov    rdi,QWORD PTR [rsp+0x78]
     abc:	call   ac1 <botlish_fn_3+0x209>
			abd: R_X86_64_PLT32	rt_closure_new-0x4
     ac1:	mov    QWORD PTR [r12+0x18],rax
     ac6:	mov    r15,rax
     ac9:	mov    QWORD PTR [r12+0x20],0x1
     ad2:	mov    rsi,QWORD PTR [rsp+0x88]
     ada:	mov    rdx,QWORD PTR [rsp+0x90]
     ae2:	mov    rdi,QWORD PTR [rsp+0x78]
     ae7:	call   aec <botlish_fn_3+0x234>
			ae8: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_local<generic>
     aec:	mov    r11,rax
     aef:	mov    r13,rax
     af2:	test   rax,r11
     af5:	jne    b05 <botlish_fn_3+0x24d>
     afb:	mov    rdi,QWORD PTR [rsp+0x78]
     b00:	jmp    c69 <botlish_fn_3+0x3b1>
     b05:	mov    rax,r13
     b08:	mov    QWORD PTR [r12+0x10],rax
     b0d:	test   rax,0x1
     b13:	jne    b43 <botlish_fn_3+0x28b>
     b19:	mov    rdx,QWORD PTR [rsp+0x90]
     b21:	mov    rsi,r13
     b24:	mov    rdi,QWORD PTR [rsp+0x78]
     b29:	call   b2e <botlish_fn_3+0x276>
			b2a: R_X86_64_PLT32	rt_int_cmp-0x4
     b2e:	mov    ecx,0x2
     b33:	test   rax,rax
     b36:	cmove  rcx,QWORD PTR [rip+0x25a]        # d98 <botlish_fn_3+0x4e0>
     b3e:	jmp    b54 <botlish_fn_3+0x29c>
     b43:	mov    ecx,0x2
     b48:	cmp    r13,0x1
     b4c:	cmove  rcx,QWORD PTR [rip+0x244]        # d98 <botlish_fn_3+0x4e0>
     b54:	cmp    rcx,0x6
     b58:	je     d0d <botlish_fn_3+0x455>
     b5e:	mov    r10,r13
     b61:	and    r10,rbx
     b64:	test   r10,0x1
     b6b:	jne    b96 <botlish_fn_3+0x2de>
     b71:	mov    rdx,rbx
     b74:	mov    rsi,r13
     b77:	mov    rdi,QWORD PTR [rsp+0x78]
     b7c:	call   b81 <botlish_fn_3+0x2c9>
			b7d: R_X86_64_PLT32	rt_int_cmp-0x4
     b81:	mov    ecx,0x2
     b86:	test   rax,rax
     b89:	cmovge rcx,QWORD PTR [rip+0x207]        # d98 <botlish_fn_3+0x4e0>
     b91:	jmp    ba6 <botlish_fn_3+0x2ee>
     b96:	mov    ecx,0x2
     b9b:	cmp    r13,rbx
     b9e:	cmovge rcx,QWORD PTR [rip+0x1f2]        # d98 <botlish_fn_3+0x4e0>
     ba6:	cmp    rcx,0x6
     baa:	je     cfe <botlish_fn_3+0x446>
     bb0:	lea    rcx,[rsp+0x68]
     bb5:	mov    rsi,r14
     bb8:	mov    rdx,r13
     bbb:	mov    rdi,QWORD PTR [rsp+0x78]
     bc0:	call   bc5 <botlish_fn_3+0x30d>
			bc1: R_X86_64_PLT32	botlish_fn_5-0x4 ; char_at<generic>
     bc5:	test   rax,rax
     bc8:	mov    rsi,rax
     bcb:	jne    bdb <botlish_fn_3+0x323>
     bd1:	mov    rdi,QWORD PTR [rsp+0x78]
     bd6:	jmp    c69 <botlish_fn_3+0x3b1>
     bdb:	mov    rdx,QWORD PTR [rsp+0x68]
     be0:	mov    rcx,QWORD PTR [rsp+0x70]
     be5:	mov    rdi,QWORD PTR [rsp+0x78]
     bea:	mov    rax,QWORD PTR [rdi+0x10]
     bee:	mov    r8,QWORD PTR [rax+0x40]
     bf2:	call   bf7 <botlish_fn_3+0x33f>
			bf3: R_X86_64_PLT32	rt_str_region_eq-0x4
     bf7:	cmp    rax,0x6
     bfb:	je     c0e <botlish_fn_3+0x356>
     c01:	mov    esi,0x2
     c06:	mov    rax,rsi
     c09:	jmp    d03 <botlish_fn_3+0x44b>
     c0e:	mov    QWORD PTR [r12],0x3
     c16:	test   r13,0x1
     c1d:	je     c35 <botlish_fn_3+0x37d>
     c23:	mov    rdx,r13
     c26:	add    rdx,0x2
     c2a:	seto   al
     c2d:	test   al,al
     c2f:	je     c4a <botlish_fn_3+0x392>
     c35:	mov    edx,0x3
     c3a:	mov    rsi,r13
     c3d:	mov    rdi,QWORD PTR [rsp+0x78]
     c42:	call   c47 <botlish_fn_3+0x38f>
			c43: R_X86_64_PLT32	rt_int_add-0x4
     c47:	mov    rdx,rax
     c4a:	mov    QWORD PTR [r12],rdx
     c4e:	mov    rsi,r15
     c51:	mov    rdi,QWORD PTR [rsp+0x78]
     c56:	call   c5b <botlish_fn_3+0x3a3>
			c57: R_X86_64_PLT32	botlish_fn_12-0x4 ; domain_loop<generic>
     c5b:	test   rax,rax
     c5e:	jne    ca8 <botlish_fn_3+0x3f0>
     c64:	mov    rdi,QWORD PTR [rsp+0x78]
     c69:	mov    rdi,QWORD PTR [rsp+0x78]
     c6e:	mov    QWORD PTR [rdi],r12
     c71:	xor    rax,rax
     c74:	mov    rbx,QWORD PTR [rsp+0xa0]
     c7c:	mov    r12,QWORD PTR [rsp+0xa8]
     c84:	mov    r13,QWORD PTR [rsp+0xb0]
     c8c:	mov    r14,QWORD PTR [rsp+0xb8]
     c94:	mov    r15,QWORD PTR [rsp+0xc0]
     c9c:	add    rsp,0xd0
     ca3:	mov    rsp,rbp
     ca6:	pop    rbp
     ca7:	ret
     ca8:	mov    rcx,rax
     cab:	and    rcx,rbx
     cae:	mov    rsi,rax
     cb1:	mov    rax,rbx
     cb4:	test   rcx,0x1
     cbb:	jne    ce6 <botlish_fn_3+0x42e>
     cc1:	mov    rdx,rax
     cc4:	mov    rdi,QWORD PTR [rsp+0x78]
     cc9:	call   cce <botlish_fn_3+0x416>
			cca: R_X86_64_PLT32	rt_int_cmp-0x4
     cce:	mov    esi,0x2
     cd3:	test   rax,rax
     cd6:	mov    rax,rsi
     cd9:	cmove  rax,QWORD PTR [rip+0xb7]        # d98 <botlish_fn_3+0x4e0>
     ce1:	jmp    d03 <botlish_fn_3+0x44b>
     ce6:	mov    rdx,rax
     ce9:	mov    eax,0x2
     cee:	cmp    rsi,rdx
     cf1:	cmove  rax,QWORD PTR [rip+0x9f]        # d98 <botlish_fn_3+0x4e0>
     cf9:	jmp    d03 <botlish_fn_3+0x44b>
     cfe:	mov    eax,0x2
     d03:	mov    rdi,QWORD PTR [rsp+0x78]
     d08:	jmp    d17 <botlish_fn_3+0x45f>
     d0d:	mov    eax,0x2
     d12:	mov    rdi,QWORD PTR [rsp+0x78]
     d17:	mov    rdi,QWORD PTR [rsp+0x78]
     d1c:	mov    QWORD PTR [rdi],r12
     d1f:	mov    rbx,QWORD PTR [rsp+0xa0]
     d27:	mov    r12,QWORD PTR [rsp+0xa8]
     d2f:	mov    r13,QWORD PTR [rsp+0xb0]
     d37:	mov    r14,QWORD PTR [rsp+0xb8]
     d3f:	mov    r15,QWORD PTR [rsp+0xc0]
     d47:	add    rsp,0xd0
     d4e:	mov    rsp,rbp
     d51:	pop    rbp
     d52:	ret
     d53:	mov    QWORD PTR [rsp+0x78],rdi
     d58:	call   d5d <botlish_fn_3+0x4a5>
			d59: R_X86_64_PLT32	rt_stack_overflow-0x4
     d5d:	xor    rax,rax
     d60:	mov    rbx,QWORD PTR [rsp+0xa0]
     d68:	mov    r12,QWORD PTR [rsp+0xa8]
     d70:	mov    r13,QWORD PTR [rsp+0xb0]
     d78:	mov    r14,QWORD PTR [rsp+0xb8]
     d80:	mov    r15,QWORD PTR [rsp+0xc0]
     d88:	add    rsp,0xd0
     d8f:	mov    rsp,rbp
     d92:	pop    rbp
     d93:	ret
     d94:	add    BYTE PTR [rax],al
     d96:	add    BYTE PTR [rax],al
     d98:	(bad)
     d99:	add    BYTE PTR [rax],al
     d9b:	add    BYTE PTR [rax],al
     d9d:	add    BYTE PTR [rax],al
	...

0000000000000da0 <botlish_entry_3: <generic>>:
     da0:	push   rbp
     da1:	mov    rbp,rsp
     da4:	mov    rsi,QWORD PTR [rdx]
     da7:	call   dac <botlish_entry_3+0xc>
			da8: R_X86_64_PLT32	botlish_fn_3-0x4 ; <generic>
     dac:	mov    rsp,rbp
     daf:	pop    rbp
     db0:	ret

0000000000000db1 <botlish_fn_4: char_at<generic>>:
     db1:	push   rbp
     db2:	mov    rbp,rsp
     db5:	sub    rsp,0x20
     db9:	mov    QWORD PTR [rsp],rbx
     dbd:	mov    QWORD PTR [rsp+0x8],r12
     dc2:	mov    QWORD PTR [rsp+0x10],r13
     dc7:	mov    QWORD PTR [rsp+0x18],r14
     dcc:	mov    rbx,QWORD PTR [rdi]
     dcf:	mov    rax,QWORD PTR [rdi+0x8]
     dd3:	lea    rcx,[rbx+0x18]
     dd7:	cmp    rcx,rax
     dda:	ja     f5c <botlish_fn_4+0x1ab>
     de0:	lea    rax,[rbx+0x18]
     de4:	mov    QWORD PTR [rdi],rax
     de7:	mov    QWORD PTR [rbx],rdx
     dea:	mov    rax,QWORD PTR [rsi+0x20]
     dee:	mov    rsi,QWORD PTR [rax]
     df1:	mov    QWORD PTR [rbx+0x8],rsi
     df5:	mov    r14,rsi
     df8:	mov    QWORD PTR [rbx+0x10],0x3
     e00:	mov    ecx,0x1
     e05:	test   rdx,0x1
     e0c:	je     e1a <botlish_fn_4+0x69>
     e12:	mov    r13,rdx
     e15:	jmp    e3d <botlish_fn_4+0x8c>
     e1a:	xor    ecx,ecx
     e1c:	test   rdx,0x7
     e23:	je     e31 <botlish_fn_4+0x80>
     e29:	mov    r13,rdx
     e2c:	jmp    e3d <botlish_fn_4+0x8c>
     e31:	movzx  rax,BYTE PTR [rdx]
     e35:	mov    r13,rdx
     e38:	cmp    al,0x1
     e3a:	sete   cl
     e3d:	test   cl,cl
     e3f:	jne    e63 <botlish_fn_4+0xb2>
     e45:	mov    rax,QWORD PTR [rdi+0x10]
     e49:	mov    r12,rdi
     e4c:	mov    rcx,QWORD PTR [rax+0x50]
     e50:	xor    rdx,rdx
     e53:	mov    rsi,r13
     e56:	call   e5b <botlish_fn_4+0xaa>
			e57: R_X86_64_PLT32	rt_type_error-0x4
     e5b:	mov    rdi,r12
     e5e:	jmp    f15 <botlish_fn_4+0x164>
     e63:	mov    rsi,r13
     e66:	mov    r12,rdi
     e69:	test   rsi,0x1
     e70:	je     e8b <botlish_fn_4+0xda>
     e76:	mov    rsi,r13
     e79:	mov    rcx,rsi
     e7c:	add    rcx,0x2
     e80:	seto   dl
     e83:	test   dl,dl
     e85:	je     e9e <botlish_fn_4+0xed>
     e8b:	mov    edx,0x3
     e90:	mov    rsi,r13
     e93:	mov    rdi,r12
     e96:	call   e9b <botlish_fn_4+0xea>
			e97: R_X86_64_PLT32	rt_int_add-0x4
     e9b:	mov    rcx,rax
     e9e:	mov    QWORD PTR [rbx+0x10],rcx
     ea2:	mov    edx,0x1
     ea7:	mov    rsi,r13
     eaa:	test   rsi,0x1
     eb1:	jne    ed5 <botlish_fn_4+0x124>
     eb7:	xor    edx,edx
     eb9:	mov    rsi,r13
     ebc:	test   rsi,0x7
     ec3:	jne    ed5 <botlish_fn_4+0x124>
     ec9:	mov    rsi,r13
     ecc:	movzx  rax,BYTE PTR [rsi]
     ed0:	cmp    al,0x1
     ed2:	sete   dl
     ed5:	test   dl,dl
     ed7:	jne    efb <botlish_fn_4+0x14a>
     edd:	mov    rdi,r12
     ee0:	mov    rax,QWORD PTR [rdi+0x10]
     ee4:	mov    rcx,QWORD PTR [rax+0x58]
     ee8:	xor    rdx,rdx
     eeb:	mov    rsi,r13
     eee:	call   ef3 <botlish_fn_4+0x142>
			eef: R_X86_64_PLT32	rt_type_error-0x4
     ef3:	mov    rdi,r12
     ef6:	jmp    f15 <botlish_fn_4+0x164>
     efb:	mov    rdx,r13
     efe:	mov    rsi,r14
     f01:	mov    rdi,r12
     f04:	call   f09 <botlish_fn_4+0x158>
			f05: R_X86_64_PLT32	rt_substr-0x4
     f09:	test   rax,rax
     f0c:	jne    f3a <botlish_fn_4+0x189>
     f12:	mov    rdi,r12
     f15:	mov    rdi,r12
     f18:	mov    QWORD PTR [rdi],rbx
     f1b:	xor    rax,rax
     f1e:	mov    rbx,QWORD PTR [rsp]
     f22:	mov    r12,QWORD PTR [rsp+0x8]
     f27:	mov    r13,QWORD PTR [rsp+0x10]
     f2c:	mov    r14,QWORD PTR [rsp+0x18]
     f31:	add    rsp,0x20
     f35:	mov    rsp,rbp
     f38:	pop    rbp
     f39:	ret
     f3a:	mov    rdi,r12
     f3d:	mov    QWORD PTR [rdi],rbx
     f40:	mov    rbx,QWORD PTR [rsp]
     f44:	mov    r12,QWORD PTR [rsp+0x8]
     f49:	mov    r13,QWORD PTR [rsp+0x10]
     f4e:	mov    r14,QWORD PTR [rsp+0x18]
     f53:	add    rsp,0x20
     f57:	mov    rsp,rbp
     f5a:	pop    rbp
     f5b:	ret
     f5c:	mov    r12,rdi
     f5f:	call   f64 <botlish_fn_4+0x1b3>
			f60: R_X86_64_PLT32	rt_stack_overflow-0x4
     f64:	xor    rax,rax
     f67:	mov    rbx,QWORD PTR [rsp]
     f6b:	mov    r12,QWORD PTR [rsp+0x8]
     f70:	mov    r13,QWORD PTR [rsp+0x10]
     f75:	mov    r14,QWORD PTR [rsp+0x18]
     f7a:	add    rsp,0x20
     f7e:	mov    rsp,rbp
     f81:	pop    rbp
     f82:	ret

0000000000000f83 <botlish_entry_4: char_at<generic>>:
     f83:	push   rbp
     f84:	mov    rbp,rsp
     f87:	mov    rdx,QWORD PTR [rdx]
     f8a:	call   f8f <botlish_entry_4+0xc>
			f8b: R_X86_64_PLT32	botlish_fn_4-0x4 ; char_at<generic>
     f8f:	mov    rsp,rbp
     f92:	pop    rbp
     f93:	ret

0000000000000f94 <botlish_fn_5: char_at<generic>>:
     f94:	push   rbp
     f95:	mov    rbp,rsp
     f98:	sub    rsp,0x40
     f9c:	mov    QWORD PTR [rsp+0x10],rbx
     fa1:	mov    QWORD PTR [rsp+0x18],r12
     fa6:	mov    QWORD PTR [rsp+0x20],r13
     fab:	mov    QWORD PTR [rsp+0x28],r14
     fb0:	mov    QWORD PTR [rsp+0x30],r15
     fb5:	mov    r15,rcx
     fb8:	mov    rbx,QWORD PTR [rdi]
     fbb:	mov    rax,QWORD PTR [rdi+0x8]
     fbf:	lea    rcx,[rbx+0x18]
     fc3:	cmp    rcx,rax
     fc6:	ja     1176 <botlish_fn_5+0x1e2>
     fcc:	lea    rax,[rbx+0x18]
     fd0:	mov    QWORD PTR [rdi],rax
     fd3:	mov    QWORD PTR [rbx],rdx
     fd6:	mov    rax,QWORD PTR [rsi+0x20]
     fda:	mov    rax,QWORD PTR [rax]
     fdd:	mov    QWORD PTR [rbx+0x8],rax
     fe1:	mov    QWORD PTR [rsp],rax
     fe5:	mov    QWORD PTR [rbx+0x10],0x3
     fed:	mov    eax,0x1
     ff2:	test   rdx,0x1
     ff9:	je     1007 <botlish_fn_5+0x73>
     fff:	mov    r14,rdx
    1002:	jmp    102a <botlish_fn_5+0x96>
    1007:	xor    eax,eax
    1009:	test   rdx,0x7
    1010:	je     101e <botlish_fn_5+0x8a>
    1016:	mov    r14,rdx
    1019:	jmp    102a <botlish_fn_5+0x96>
    101e:	movzx  rax,BYTE PTR [rdx]
    1022:	mov    r14,rdx
    1025:	cmp    al,0x1
    1027:	sete   al
    102a:	test   al,al
    102c:	jne    1050 <botlish_fn_5+0xbc>
    1032:	mov    rax,QWORD PTR [rdi+0x10]
    1036:	mov    r13,rdi
    1039:	mov    rcx,QWORD PTR [rax+0x50]
    103d:	xor    rdx,rdx
    1040:	mov    rsi,r14
    1043:	call   1048 <botlish_fn_5+0xb4>
			1044: R_X86_64_PLT32	rt_type_error-0x4
    1048:	mov    rdi,r13
    104b:	jmp    1112 <botlish_fn_5+0x17e>
    1050:	mov    rsi,r14
    1053:	mov    r13,rdi
    1056:	test   rsi,0x1
    105d:	jne    106b <botlish_fn_5+0xd7>
    1063:	mov    r14,rsi
    1066:	jmp    1088 <botlish_fn_5+0xf4>
    106b:	mov    rax,rsi
    106e:	add    rax,0x2
    1072:	mov    r14,rsi
    1075:	seto   dl
    1078:	test   dl,dl
    107a:	jne    1088 <botlish_fn_5+0xf4>
    1080:	mov    r12,rax
    1083:	jmp    109b <botlish_fn_5+0x107>
    1088:	mov    edx,0x3
    108d:	mov    rsi,r14
    1090:	mov    rdi,r13
    1093:	call   1098 <botlish_fn_5+0x104>
			1094: R_X86_64_PLT32	rt_int_add-0x4
    1098:	mov    r12,rax
    109b:	mov    ecx,0x1
    10a0:	mov    rsi,r14
    10a3:	test   rsi,0x1
    10aa:	jne    10ce <botlish_fn_5+0x13a>
    10b0:	xor    ecx,ecx
    10b2:	mov    rsi,r14
    10b5:	test   rsi,0x7
    10bc:	jne    10ce <botlish_fn_5+0x13a>
    10c2:	mov    rsi,r14
    10c5:	movzx  rax,BYTE PTR [rsi]
    10c9:	cmp    al,0x1
    10cb:	sete   cl
    10ce:	test   cl,cl
    10d0:	jne    10f4 <botlish_fn_5+0x160>
    10d6:	mov    rdi,r13
    10d9:	mov    rax,QWORD PTR [rdi+0x10]
    10dd:	mov    rcx,QWORD PTR [rax+0x58]
    10e1:	xor    rdx,rdx
    10e4:	mov    rsi,r14
    10e7:	call   10ec <botlish_fn_5+0x158>
			10e8: R_X86_64_PLT32	rt_type_error-0x4
    10ec:	mov    rdi,r13
    10ef:	jmp    1112 <botlish_fn_5+0x17e>
    10f4:	mov    rcx,r12
    10f7:	mov    rdx,r14
    10fa:	mov    rsi,QWORD PTR [rsp]
    10fe:	mov    rdi,r13
    1101:	call   1106 <botlish_fn_5+0x172>
			1102: R_X86_64_PLT32	rt_str_region_check-0x4
    1106:	test   rax,rax
    1109:	jne    113d <botlish_fn_5+0x1a9>
    110f:	mov    rdi,r13
    1112:	mov    rdi,r13
    1115:	mov    QWORD PTR [rdi],rbx
    1118:	xor    rax,rax
    111b:	mov    rbx,QWORD PTR [rsp+0x10]
    1120:	mov    r12,QWORD PTR [rsp+0x18]
    1125:	mov    r13,QWORD PTR [rsp+0x20]
    112a:	mov    r14,QWORD PTR [rsp+0x28]
    112f:	mov    r15,QWORD PTR [rsp+0x30]
    1134:	add    rsp,0x40
    1138:	mov    rsp,rbp
    113b:	pop    rbp
    113c:	ret
    113d:	mov    rdi,r13
    1140:	mov    QWORD PTR [rdi],rbx
    1143:	mov    rcx,r15
    1146:	mov    rsi,r14
    1149:	mov    QWORD PTR [rcx],rsi
    114c:	mov    QWORD PTR [rcx+0x8],r12
    1150:	mov    rax,QWORD PTR [rsp]
    1154:	mov    rbx,QWORD PTR [rsp+0x10]
    1159:	mov    r12,QWORD PTR [rsp+0x18]
    115e:	mov    r13,QWORD PTR [rsp+0x20]
    1163:	mov    r14,QWORD PTR [rsp+0x28]
    1168:	mov    r15,QWORD PTR [rsp+0x30]
    116d:	add    rsp,0x40
    1171:	mov    rsp,rbp
    1174:	pop    rbp
    1175:	ret
    1176:	mov    r13,rdi
    1179:	call   117e <botlish_fn_5+0x1ea>
			117a: R_X86_64_PLT32	rt_stack_overflow-0x4
    117e:	xor    rax,rax
    1181:	mov    rbx,QWORD PTR [rsp+0x10]
    1186:	mov    r12,QWORD PTR [rsp+0x18]
    118b:	mov    r13,QWORD PTR [rsp+0x20]
    1190:	mov    r14,QWORD PTR [rsp+0x28]
    1195:	mov    r15,QWORD PTR [rsp+0x30]
    119a:	add    rsp,0x40
    119e:	mov    rsp,rbp
    11a1:	pop    rbp
    11a2:	ret

00000000000011a3 <botlish_entry_5: char_at<generic>>:
    11a3:	push   rbp
    11a4:	mov    rbp,rsp
    11a7:	ud2

00000000000011a9 <botlish_fn_6: is_local_char<str>>:
    11a9:	push   rbp
    11aa:	mov    rbp,rsp
    11ad:	sub    rsp,0x20
    11b1:	mov    QWORD PTR [rsp],rbx
    11b5:	mov    QWORD PTR [rsp+0x8],r12
    11ba:	mov    QWORD PTR [rsp+0x10],r13
    11bf:	mov    r13,rsi
    11c2:	mov    rbx,QWORD PTR [rdi]
    11c5:	mov    rax,QWORD PTR [rdi+0x8]
    11c9:	lea    rcx,[rbx+0x8]
    11cd:	cmp    rcx,rax
    11d0:	ja     132c <botlish_fn_6+0x183>
    11d6:	lea    rax,[rbx+0x8]
    11da:	mov    QWORD PTR [rdi],rax
    11dd:	mov    r12,rdi
    11e0:	mov    rsi,r13
    11e3:	mov    rdi,r12
    11e6:	call   11eb <botlish_fn_6+0x42>
			11e7: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    11eb:	test   rax,rax
    11ee:	jne    1214 <botlish_fn_6+0x6b>
    11f4:	mov    rdi,r12
    11f7:	mov    QWORD PTR [rdi],rbx
    11fa:	xor    rax,rax
    11fd:	mov    rbx,QWORD PTR [rsp]
    1201:	mov    r12,QWORD PTR [rsp+0x8]
    1206:	mov    r13,QWORD PTR [rsp+0x10]
    120b:	add    rsp,0x20
    120f:	mov    rsp,rbp
    1212:	pop    rbp
    1213:	ret
    1214:	cmp    rax,0x6
    1218:	je     1307 <botlish_fn_6+0x15e>
    121e:	mov    rdi,r12
    1221:	mov    rax,QWORD PTR [rdi+0x10]
    1225:	mov    rsi,QWORD PTR [rax+0x60]
    1229:	mov    edx,0x1
    122e:	mov    ecx,0x3
    1233:	mov    r8,r13
    1236:	call   123b <botlish_fn_6+0x92>
			1237: R_X86_64_PLT32	rt_str_region_eq-0x4
    123b:	cmp    rax,0x6
    123f:	je     12fa <botlish_fn_6+0x151>
    1245:	mov    rdi,r12
    1248:	mov    rax,QWORD PTR [rdi+0x10]
    124c:	mov    rsi,QWORD PTR [rax+0x68]
    1250:	mov    edx,0x1
    1255:	mov    ecx,0x3
    125a:	mov    r8,r13
    125d:	call   1262 <botlish_fn_6+0xb9>
			125e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1262:	cmp    rax,0x6
    1266:	je     12f0 <botlish_fn_6+0x147>
    126c:	mov    rdi,r12
    126f:	mov    rax,QWORD PTR [rdi+0x10]
    1273:	mov    rsi,QWORD PTR [rax+0x70]
    1277:	mov    edx,0x1
    127c:	mov    ecx,0x3
    1281:	mov    r8,r13
    1284:	call   1289 <botlish_fn_6+0xe0>
			1285: R_X86_64_PLT32	rt_str_region_eq-0x4
    1289:	cmp    rax,0x6
    128d:	je     12e6 <botlish_fn_6+0x13d>
    1293:	mov    rdi,r12
    1296:	mov    rax,QWORD PTR [rdi+0x10]
    129a:	mov    rsi,QWORD PTR [rax+0x50]
    129e:	mov    edx,0x1
    12a3:	mov    ecx,0x3
    12a8:	mov    r8,r13
    12ab:	call   12b0 <botlish_fn_6+0x107>
			12ac: R_X86_64_PLT32	rt_str_region_eq-0x4
    12b0:	cmp    rax,0x6
    12b4:	je     12dc <botlish_fn_6+0x133>
    12ba:	mov    rdi,r12
    12bd:	mov    rdx,QWORD PTR [rdi+0x10]
    12c1:	mov    rsi,QWORD PTR [rdx+0x78]
    12c5:	mov    edx,0x1
    12ca:	mov    ecx,0x3
    12cf:	mov    r8,r13
    12d2:	call   12d7 <botlish_fn_6+0x12e>
			12d3: R_X86_64_PLT32	rt_str_region_eq-0x4
    12d7:	jmp    12ff <botlish_fn_6+0x156>
    12dc:	mov    eax,0x6
    12e1:	jmp    12ff <botlish_fn_6+0x156>
    12e6:	mov    eax,0x6
    12eb:	jmp    12ff <botlish_fn_6+0x156>
    12f0:	mov    eax,0x6
    12f5:	jmp    12ff <botlish_fn_6+0x156>
    12fa:	mov    eax,0x6
    12ff:	mov    rdi,r12
    1302:	jmp    130f <botlish_fn_6+0x166>
    1307:	mov    eax,0x6
    130c:	mov    rdi,r12
    130f:	mov    rdi,r12
    1312:	mov    QWORD PTR [rdi],rbx
    1315:	mov    rbx,QWORD PTR [rsp]
    1319:	mov    r12,QWORD PTR [rsp+0x8]
    131e:	mov    r13,QWORD PTR [rsp+0x10]
    1323:	add    rsp,0x20
    1327:	mov    rsp,rbp
    132a:	pop    rbp
    132b:	ret
    132c:	mov    r12,rdi
    132f:	call   1334 <botlish_fn_6+0x18b>
			1330: R_X86_64_PLT32	rt_stack_overflow-0x4
    1334:	xor    rax,rax
    1337:	mov    rbx,QWORD PTR [rsp]
    133b:	mov    r12,QWORD PTR [rsp+0x8]
    1340:	mov    r13,QWORD PTR [rsp+0x10]
    1345:	add    rsp,0x20
    1349:	mov    rsp,rbp
    134c:	pop    rbp
    134d:	ret

000000000000134e <botlish_entry_6: is_local_char<str>>:
    134e:	push   rbp
    134f:	mov    rbp,rsp
    1352:	mov    rsi,QWORD PTR [rdx]
    1355:	call   135a <botlish_entry_6+0xc>
			1356: R_X86_64_PLT32	botlish_fn_6-0x4 ; is_local_char<str>
    135a:	mov    rsp,rbp
    135d:	pop    rbp
    135e:	ret

000000000000135f <botlish_fn_7: is_label_char<str>>:
    135f:	push   rbp
    1360:	mov    rbp,rsp
    1363:	sub    rsp,0x20
    1367:	mov    QWORD PTR [rsp],rbx
    136b:	mov    QWORD PTR [rsp+0x8],r12
    1370:	mov    QWORD PTR [rsp+0x10],r13
    1375:	mov    r13,rsi
    1378:	mov    rbx,QWORD PTR [rdi]
    137b:	mov    rax,QWORD PTR [rdi+0x8]
    137f:	lea    rcx,[rbx+0x8]
    1383:	cmp    rcx,rax
    1386:	ja     141e <botlish_fn_7+0xbf>
    138c:	lea    rax,[rbx+0x8]
    1390:	mov    QWORD PTR [rdi],rax
    1393:	mov    r12,rdi
    1396:	mov    rsi,r13
    1399:	mov    rdi,r12
    139c:	call   13a1 <botlish_fn_7+0x42>
			139d: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    13a1:	test   rax,rax
    13a4:	jne    13ca <botlish_fn_7+0x6b>
    13aa:	mov    rdi,r12
    13ad:	mov    QWORD PTR [rdi],rbx
    13b0:	xor    rax,rax
    13b3:	mov    rbx,QWORD PTR [rsp]
    13b7:	mov    r12,QWORD PTR [rsp+0x8]
    13bc:	mov    r13,QWORD PTR [rsp+0x10]
    13c1:	add    rsp,0x20
    13c5:	mov    rsp,rbp
    13c8:	pop    rbp
    13c9:	ret
    13ca:	cmp    rax,0x6
    13ce:	je     13f9 <botlish_fn_7+0x9a>
    13d4:	mov    rdi,r12
    13d7:	mov    rax,QWORD PTR [rdi+0x10]
    13db:	mov    rsi,QWORD PTR [rax+0x78]
    13df:	mov    edx,0x1
    13e4:	mov    ecx,0x3
    13e9:	mov    r8,r13
    13ec:	call   13f1 <botlish_fn_7+0x92>
			13ed: R_X86_64_PLT32	rt_str_region_eq-0x4
    13f1:	mov    rdi,r12
    13f4:	jmp    1401 <botlish_fn_7+0xa2>
    13f9:	mov    eax,0x6
    13fe:	mov    rdi,r12
    1401:	mov    rdi,r12
    1404:	mov    QWORD PTR [rdi],rbx
    1407:	mov    rbx,QWORD PTR [rsp]
    140b:	mov    r12,QWORD PTR [rsp+0x8]
    1410:	mov    r13,QWORD PTR [rsp+0x10]
    1415:	add    rsp,0x20
    1419:	mov    rsp,rbp
    141c:	pop    rbp
    141d:	ret
    141e:	mov    r12,rdi
    1421:	call   1426 <botlish_fn_7+0xc7>
			1422: R_X86_64_PLT32	rt_stack_overflow-0x4
    1426:	xor    rax,rax
    1429:	mov    rbx,QWORD PTR [rsp]
    142d:	mov    r12,QWORD PTR [rsp+0x8]
    1432:	mov    r13,QWORD PTR [rsp+0x10]
    1437:	add    rsp,0x20
    143b:	mov    rsp,rbp
    143e:	pop    rbp
    143f:	ret

0000000000001440 <botlish_entry_7: is_label_char<str>>:
    1440:	push   rbp
    1441:	mov    rbp,rsp
    1444:	mov    rsi,QWORD PTR [rdx]
    1447:	call   144c <botlish_entry_7+0xc>
			1448: R_X86_64_PLT32	botlish_fn_7-0x4 ; is_label_char<str>
    144c:	mov    rsp,rbp
    144f:	pop    rbp
    1450:	ret
    1451:	add    BYTE PTR [rax],al
    1453:	add    BYTE PTR [rax],al
    1455:	add    BYTE PTR [rax],al
	...

0000000000001458 <botlish_fn_8: scan_local<generic>>:
    1458:	push   rbp
    1459:	mov    rbp,rsp
    145c:	sub    rsp,0x20
    1460:	mov    QWORD PTR [rsp],rbx
    1464:	mov    QWORD PTR [rsp+0x8],r12
    1469:	mov    QWORD PTR [rsp+0x10],r13
    146e:	mov    QWORD PTR [rsp+0x18],r14
    1473:	mov    r12,QWORD PTR [rdi]
    1476:	mov    rax,QWORD PTR [rdi+0x8]
    147a:	lea    rcx,[r12+0x18]
    147f:	cmp    rcx,rax
    1482:	ja     1656 <botlish_fn_8+0x1fe>
    1488:	lea    rax,[r12+0x18]
    148d:	mov    QWORD PTR [rdi],rax
    1490:	mov    r13,rdi
    1493:	mov    QWORD PTR [r12+0x10],0x0
    149c:	mov    QWORD PTR [r12],rdx
    14a0:	mov    rbx,rsi
    14a3:	mov    rsi,rdx
    14a6:	mov    rax,QWORD PTR [rbx+0x20]
    14aa:	mov    rdx,QWORD PTR [rax]
    14ad:	mov    ecx,0x1
    14b2:	test   rsi,0x1
    14b9:	jne    14d7 <botlish_fn_8+0x7f>
    14bf:	xor    ecx,ecx
    14c1:	test   rsi,0x7
    14c8:	jne    14d7 <botlish_fn_8+0x7f>
    14ce:	movzx  rax,BYTE PTR [rsi]
    14d2:	cmp    al,0x1
    14d4:	sete   cl
    14d7:	test   cl,cl
    14d9:	jne    14fd <botlish_fn_8+0xa5>
    14df:	mov    rdi,r13
    14e2:	mov    rax,QWORD PTR [rdi+0x10]
    14e6:	mov    rcx,QWORD PTR [rax+0x80]
    14ed:	xor    rdx,rdx
    14f0:	call   14f5 <botlish_fn_8+0x9d>
			14f1: R_X86_64_PLT32	rt_type_error-0x4
    14f5:	mov    rdi,r13
    14f8:	jmp    1594 <botlish_fn_8+0x13c>
    14fd:	mov    rax,rsi
    1500:	and    rax,rdx
    1503:	mov    r14,rsi
    1506:	test   rax,0x1
    150c:	jne    1532 <botlish_fn_8+0xda>
    1512:	mov    rsi,r14
    1515:	mov    rdi,r13
    1518:	call   151d <botlish_fn_8+0xc5>
			1519: R_X86_64_PLT32	rt_int_cmp-0x4
    151d:	mov    ecx,0x2
    1522:	test   rax,rax
    1525:	cmovge rcx,QWORD PTR [rip+0x153]        # 1680 <botlish_fn_8+0x228>
    152d:	jmp    1545 <botlish_fn_8+0xed>
    1532:	mov    ecx,0x2
    1537:	mov    rsi,r14
    153a:	cmp    rsi,rdx
    153d:	cmovge rcx,QWORD PTR [rip+0x13b]        # 1680 <botlish_fn_8+0x228>
    1545:	cmp    rcx,0x6
    1549:	je     162e <botlish_fn_8+0x1d6>
    154f:	mov    rsi,QWORD PTR [rbx+0x20]
    1553:	mov    rsi,QWORD PTR [rsi+0x8]
    1557:	mov    QWORD PTR [r12+0x8],rsi
    155c:	mov    rdx,r14
    155f:	mov    rdi,r13
    1562:	call   1567 <botlish_fn_8+0x10f>
			1563: R_X86_64_PLT32	botlish_fn_4-0x4 ; char_at<generic>
    1567:	test   rax,rax
    156a:	jne    1578 <botlish_fn_8+0x120>
    1570:	mov    rdi,r13
    1573:	jmp    1594 <botlish_fn_8+0x13c>
    1578:	mov    QWORD PTR [r12+0x8],rax
    157d:	mov    rsi,rax
    1580:	mov    rdi,r13
    1583:	call   1588 <botlish_fn_8+0x130>
			1584: R_X86_64_PLT32	botlish_fn_6-0x4 ; is_local_char<str>
    1588:	test   rax,rax
    158b:	jne    15b9 <botlish_fn_8+0x161>
    1591:	mov    rdi,r13
    1594:	mov    rdi,r13
    1597:	mov    QWORD PTR [rdi],r12
    159a:	xor    rax,rax
    159d:	mov    rbx,QWORD PTR [rsp]
    15a1:	mov    r12,QWORD PTR [rsp+0x8]
    15a6:	mov    r13,QWORD PTR [rsp+0x10]
    15ab:	mov    r14,QWORD PTR [rsp+0x18]
    15b0:	add    rsp,0x20
    15b4:	mov    rsp,rbp
    15b7:	pop    rbp
    15b8:	ret
    15b9:	cmp    rax,0x6
    15bd:	je     15ce <botlish_fn_8+0x176>
    15c3:	mov    rax,r14
    15c6:	mov    rdi,r13
    15c9:	jmp    1634 <botlish_fn_8+0x1dc>
    15ce:	mov    QWORD PTR [r12+0x8],rbx
    15d3:	mov    QWORD PTR [r12+0x10],0x3
    15dc:	mov    rsi,r14
    15df:	test   rsi,0x1
    15e6:	je     160c <botlish_fn_8+0x1b4>
    15ec:	mov    rsi,r14
    15ef:	mov    rcx,rsi
    15f2:	add    rcx,0x2
    15f6:	seto   al
    15f9:	test   al,al
    15fb:	jne    160c <botlish_fn_8+0x1b4>
    1601:	mov    rsi,rcx
    1604:	mov    r14,rcx
    1607:	jmp    1622 <botlish_fn_8+0x1ca>
    160c:	mov    edx,0x3
    1611:	mov    rsi,r14
    1614:	mov    rdi,r13
    1617:	call   161c <botlish_fn_8+0x1c4>
			1618: R_X86_64_PLT32	rt_int_add-0x4
    161c:	mov    rsi,rax
    161f:	mov    r14,rax
    1622:	mov    QWORD PTR [r12],rsi
    1626:	mov    rsi,r14
    1629:	jmp    14a6 <botlish_fn_8+0x4e>
    162e:	mov    rax,r14
    1631:	mov    rdi,r13
    1634:	mov    rdi,r13
    1637:	mov    QWORD PTR [rdi],r12
    163a:	mov    rbx,QWORD PTR [rsp]
    163e:	mov    r12,QWORD PTR [rsp+0x8]
    1643:	mov    r13,QWORD PTR [rsp+0x10]
    1648:	mov    r14,QWORD PTR [rsp+0x18]
    164d:	add    rsp,0x20
    1651:	mov    rsp,rbp
    1654:	pop    rbp
    1655:	ret
    1656:	mov    r13,rdi
    1659:	call   165e <botlish_fn_8+0x206>
			165a: R_X86_64_PLT32	rt_stack_overflow-0x4
    165e:	xor    rax,rax
    1661:	mov    rbx,QWORD PTR [rsp]
    1665:	mov    r12,QWORD PTR [rsp+0x8]
    166a:	mov    r13,QWORD PTR [rsp+0x10]
    166f:	mov    r14,QWORD PTR [rsp+0x18]
    1674:	add    rsp,0x20
    1678:	mov    rsp,rbp
    167b:	pop    rbp
    167c:	ret
    167d:	add    BYTE PTR [rax],al
    167f:	add    BYTE PTR [rsi],al
    1681:	add    BYTE PTR [rax],al
    1683:	add    BYTE PTR [rax],al
    1685:	add    BYTE PTR [rax],al
	...

0000000000001688 <botlish_entry_8: scan_local<generic>>:
    1688:	push   rbp
    1689:	mov    rbp,rsp
    168c:	mov    rdx,QWORD PTR [rdx]
    168f:	call   1694 <botlish_entry_8+0xc>
			1690: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_local<generic>
    1694:	mov    rsp,rbp
    1697:	pop    rbp
    1698:	ret
    1699:	add    BYTE PTR [rax],al
    169b:	add    BYTE PTR [rax],al
    169d:	add    BYTE PTR [rax],al
	...

00000000000016a0 <botlish_fn_9: scan_label<generic>>:
    16a0:	push   rbp
    16a1:	mov    rbp,rsp
    16a4:	sub    rsp,0x20
    16a8:	mov    QWORD PTR [rsp],rbx
    16ac:	mov    QWORD PTR [rsp+0x8],r12
    16b1:	mov    QWORD PTR [rsp+0x10],r13
    16b6:	mov    QWORD PTR [rsp+0x18],r14
    16bb:	mov    r12,QWORD PTR [rdi]
    16be:	mov    rax,QWORD PTR [rdi+0x8]
    16c2:	lea    rcx,[r12+0x18]
    16c7:	cmp    rcx,rax
    16ca:	ja     189e <botlish_fn_9+0x1fe>
    16d0:	lea    rax,[r12+0x18]
    16d5:	mov    QWORD PTR [rdi],rax
    16d8:	mov    r13,rdi
    16db:	mov    QWORD PTR [r12+0x10],0x0
    16e4:	mov    QWORD PTR [r12],rdx
    16e8:	mov    rbx,rsi
    16eb:	mov    rsi,rdx
    16ee:	mov    rax,QWORD PTR [rbx+0x20]
    16f2:	mov    rdx,QWORD PTR [rax]
    16f5:	mov    ecx,0x1
    16fa:	test   rsi,0x1
    1701:	jne    171f <botlish_fn_9+0x7f>
    1707:	xor    ecx,ecx
    1709:	test   rsi,0x7
    1710:	jne    171f <botlish_fn_9+0x7f>
    1716:	movzx  rax,BYTE PTR [rsi]
    171a:	cmp    al,0x1
    171c:	sete   cl
    171f:	test   cl,cl
    1721:	jne    1745 <botlish_fn_9+0xa5>
    1727:	mov    rdi,r13
    172a:	mov    rax,QWORD PTR [rdi+0x10]
    172e:	mov    rcx,QWORD PTR [rax+0x80]
    1735:	xor    rdx,rdx
    1738:	call   173d <botlish_fn_9+0x9d>
			1739: R_X86_64_PLT32	rt_type_error-0x4
    173d:	mov    rdi,r13
    1740:	jmp    17dc <botlish_fn_9+0x13c>
    1745:	mov    rax,rsi
    1748:	and    rax,rdx
    174b:	mov    r14,rsi
    174e:	test   rax,0x1
    1754:	jne    177a <botlish_fn_9+0xda>
    175a:	mov    rsi,r14
    175d:	mov    rdi,r13
    1760:	call   1765 <botlish_fn_9+0xc5>
			1761: R_X86_64_PLT32	rt_int_cmp-0x4
    1765:	mov    ecx,0x2
    176a:	test   rax,rax
    176d:	cmovge rcx,QWORD PTR [rip+0x153]        # 18c8 <botlish_fn_9+0x228>
    1775:	jmp    178d <botlish_fn_9+0xed>
    177a:	mov    ecx,0x2
    177f:	mov    rsi,r14
    1782:	cmp    rsi,rdx
    1785:	cmovge rcx,QWORD PTR [rip+0x13b]        # 18c8 <botlish_fn_9+0x228>
    178d:	cmp    rcx,0x6
    1791:	je     1876 <botlish_fn_9+0x1d6>
    1797:	mov    rsi,QWORD PTR [rbx+0x20]
    179b:	mov    rsi,QWORD PTR [rsi+0x8]
    179f:	mov    QWORD PTR [r12+0x8],rsi
    17a4:	mov    rdx,r14
    17a7:	mov    rdi,r13
    17aa:	call   17af <botlish_fn_9+0x10f>
			17ab: R_X86_64_PLT32	botlish_fn_4-0x4 ; char_at<generic>
    17af:	test   rax,rax
    17b2:	jne    17c0 <botlish_fn_9+0x120>
    17b8:	mov    rdi,r13
    17bb:	jmp    17dc <botlish_fn_9+0x13c>
    17c0:	mov    QWORD PTR [r12+0x8],rax
    17c5:	mov    rsi,rax
    17c8:	mov    rdi,r13
    17cb:	call   17d0 <botlish_fn_9+0x130>
			17cc: R_X86_64_PLT32	botlish_fn_7-0x4 ; is_label_char<str>
    17d0:	test   rax,rax
    17d3:	jne    1801 <botlish_fn_9+0x161>
    17d9:	mov    rdi,r13
    17dc:	mov    rdi,r13
    17df:	mov    QWORD PTR [rdi],r12
    17e2:	xor    rax,rax
    17e5:	mov    rbx,QWORD PTR [rsp]
    17e9:	mov    r12,QWORD PTR [rsp+0x8]
    17ee:	mov    r13,QWORD PTR [rsp+0x10]
    17f3:	mov    r14,QWORD PTR [rsp+0x18]
    17f8:	add    rsp,0x20
    17fc:	mov    rsp,rbp
    17ff:	pop    rbp
    1800:	ret
    1801:	cmp    rax,0x6
    1805:	je     1816 <botlish_fn_9+0x176>
    180b:	mov    rax,r14
    180e:	mov    rdi,r13
    1811:	jmp    187c <botlish_fn_9+0x1dc>
    1816:	mov    QWORD PTR [r12+0x8],rbx
    181b:	mov    QWORD PTR [r12+0x10],0x3
    1824:	mov    rsi,r14
    1827:	test   rsi,0x1
    182e:	je     1854 <botlish_fn_9+0x1b4>
    1834:	mov    rsi,r14
    1837:	mov    rcx,rsi
    183a:	add    rcx,0x2
    183e:	seto   al
    1841:	test   al,al
    1843:	jne    1854 <botlish_fn_9+0x1b4>
    1849:	mov    rsi,rcx
    184c:	mov    r14,rcx
    184f:	jmp    186a <botlish_fn_9+0x1ca>
    1854:	mov    edx,0x3
    1859:	mov    rsi,r14
    185c:	mov    rdi,r13
    185f:	call   1864 <botlish_fn_9+0x1c4>
			1860: R_X86_64_PLT32	rt_int_add-0x4
    1864:	mov    rsi,rax
    1867:	mov    r14,rax
    186a:	mov    QWORD PTR [r12],rsi
    186e:	mov    rsi,r14
    1871:	jmp    16ee <botlish_fn_9+0x4e>
    1876:	mov    rax,r14
    1879:	mov    rdi,r13
    187c:	mov    rdi,r13
    187f:	mov    QWORD PTR [rdi],r12
    1882:	mov    rbx,QWORD PTR [rsp]
    1886:	mov    r12,QWORD PTR [rsp+0x8]
    188b:	mov    r13,QWORD PTR [rsp+0x10]
    1890:	mov    r14,QWORD PTR [rsp+0x18]
    1895:	add    rsp,0x20
    1899:	mov    rsp,rbp
    189c:	pop    rbp
    189d:	ret
    189e:	mov    r13,rdi
    18a1:	call   18a6 <botlish_fn_9+0x206>
			18a2: R_X86_64_PLT32	rt_stack_overflow-0x4
    18a6:	xor    rax,rax
    18a9:	mov    rbx,QWORD PTR [rsp]
    18ad:	mov    r12,QWORD PTR [rsp+0x8]
    18b2:	mov    r13,QWORD PTR [rsp+0x10]
    18b7:	mov    r14,QWORD PTR [rsp+0x18]
    18bc:	add    rsp,0x20
    18c0:	mov    rsp,rbp
    18c3:	pop    rbp
    18c4:	ret
    18c5:	add    BYTE PTR [rax],al
    18c7:	add    BYTE PTR [rsi],al
    18c9:	add    BYTE PTR [rax],al
    18cb:	add    BYTE PTR [rax],al
    18cd:	add    BYTE PTR [rax],al
	...

00000000000018d0 <botlish_entry_9: scan_label<generic>>:
    18d0:	push   rbp
    18d1:	mov    rbp,rsp
    18d4:	mov    rdx,QWORD PTR [rdx]
    18d7:	call   18dc <botlish_entry_9+0xc>
			18d8: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_label<generic>
    18dc:	mov    rsp,rbp
    18df:	pop    rbp
    18e0:	ret
    18e1:	add    BYTE PTR [rax],al
    18e3:	add    BYTE PTR [rax],al
    18e5:	add    BYTE PTR [rax],al
	...

00000000000018e8 <botlish_fn_10: scan_alpha<generic>>:
    18e8:	push   rbp
    18e9:	mov    rbp,rsp
    18ec:	sub    rsp,0x20
    18f0:	mov    QWORD PTR [rsp],rbx
    18f4:	mov    QWORD PTR [rsp+0x8],r12
    18f9:	mov    QWORD PTR [rsp+0x10],r13
    18fe:	mov    QWORD PTR [rsp+0x18],r14
    1903:	mov    r12,QWORD PTR [rdi]
    1906:	mov    rax,QWORD PTR [rdi+0x8]
    190a:	lea    rcx,[r12+0x18]
    190f:	cmp    rcx,rax
    1912:	ja     1ae1 <botlish_fn_10+0x1f9>
    1918:	lea    rax,[r12+0x18]
    191d:	mov    QWORD PTR [rdi],rax
    1920:	mov    r13,rdi
    1923:	mov    QWORD PTR [r12+0x10],0x0
    192c:	mov    QWORD PTR [r12],rdx
    1930:	mov    rbx,rsi
    1933:	mov    rsi,rdx
    1936:	mov    rax,QWORD PTR [rbx+0x20]
    193a:	mov    rdx,QWORD PTR [rax]
    193d:	mov    ecx,0x1
    1942:	test   rsi,0x1
    1949:	jne    1967 <botlish_fn_10+0x7f>
    194f:	xor    ecx,ecx
    1951:	test   rsi,0x7
    1958:	jne    1967 <botlish_fn_10+0x7f>
    195e:	movzx  rax,BYTE PTR [rsi]
    1962:	cmp    al,0x1
    1964:	sete   cl
    1967:	test   cl,cl
    1969:	jne    198d <botlish_fn_10+0xa5>
    196f:	mov    rdi,r13
    1972:	mov    rax,QWORD PTR [rdi+0x10]
    1976:	mov    rcx,QWORD PTR [rax+0x80]
    197d:	xor    rdx,rdx
    1980:	call   1985 <botlish_fn_10+0x9d>
			1981: R_X86_64_PLT32	rt_type_error-0x4
    1985:	mov    rdi,r13
    1988:	jmp    1a1f <botlish_fn_10+0x137>
    198d:	mov    rax,rsi
    1990:	and    rax,rdx
    1993:	mov    r14,rsi
    1996:	test   rax,0x1
    199c:	jne    19c2 <botlish_fn_10+0xda>
    19a2:	mov    rsi,r14
    19a5:	mov    rdi,r13
    19a8:	call   19ad <botlish_fn_10+0xc5>
			19a9: R_X86_64_PLT32	rt_int_cmp-0x4
    19ad:	mov    ecx,0x2
    19b2:	test   rax,rax
    19b5:	cmovge rcx,QWORD PTR [rip+0x14b]        # 1b08 <botlish_fn_10+0x220>
    19bd:	jmp    19d5 <botlish_fn_10+0xed>
    19c2:	mov    ecx,0x2
    19c7:	mov    rsi,r14
    19ca:	cmp    rsi,rdx
    19cd:	cmovge rcx,QWORD PTR [rip+0x133]        # 1b08 <botlish_fn_10+0x220>
    19d5:	cmp    rcx,0x6
    19d9:	je     1ab9 <botlish_fn_10+0x1d1>
    19df:	mov    rsi,QWORD PTR [rbx+0x20]
    19e3:	mov    rsi,QWORD PTR [rsi+0x8]
    19e7:	mov    QWORD PTR [r12+0x8],rsi
    19ec:	mov    rdx,r14
    19ef:	mov    rdi,r13
    19f2:	call   19f7 <botlish_fn_10+0x10f>
			19f3: R_X86_64_PLT32	botlish_fn_4-0x4 ; char_at<generic>
    19f7:	test   rax,rax
    19fa:	mov    rsi,rax
    19fd:	jne    1a0b <botlish_fn_10+0x123>
    1a03:	mov    rdi,r13
    1a06:	jmp    1a1f <botlish_fn_10+0x137>
    1a0b:	mov    rdi,r13
    1a0e:	call   1a13 <botlish_fn_10+0x12b>
			1a0f: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    1a13:	test   rax,rax
    1a16:	jne    1a44 <botlish_fn_10+0x15c>
    1a1c:	mov    rdi,r13
    1a1f:	mov    rdi,r13
    1a22:	mov    QWORD PTR [rdi],r12
    1a25:	xor    rax,rax
    1a28:	mov    rbx,QWORD PTR [rsp]
    1a2c:	mov    r12,QWORD PTR [rsp+0x8]
    1a31:	mov    r13,QWORD PTR [rsp+0x10]
    1a36:	mov    r14,QWORD PTR [rsp+0x18]
    1a3b:	add    rsp,0x20
    1a3f:	mov    rsp,rbp
    1a42:	pop    rbp
    1a43:	ret
    1a44:	cmp    rax,0x6
    1a48:	je     1a59 <botlish_fn_10+0x171>
    1a4e:	mov    rax,r14
    1a51:	mov    rdi,r13
    1a54:	jmp    1abf <botlish_fn_10+0x1d7>
    1a59:	mov    QWORD PTR [r12+0x8],rbx
    1a5e:	mov    QWORD PTR [r12+0x10],0x3
    1a67:	mov    rsi,r14
    1a6a:	test   rsi,0x1
    1a71:	je     1a97 <botlish_fn_10+0x1af>
    1a77:	mov    rsi,r14
    1a7a:	mov    rcx,rsi
    1a7d:	add    rcx,0x2
    1a81:	seto   al
    1a84:	test   al,al
    1a86:	jne    1a97 <botlish_fn_10+0x1af>
    1a8c:	mov    rsi,rcx
    1a8f:	mov    r14,rcx
    1a92:	jmp    1aad <botlish_fn_10+0x1c5>
    1a97:	mov    edx,0x3
    1a9c:	mov    rsi,r14
    1a9f:	mov    rdi,r13
    1aa2:	call   1aa7 <botlish_fn_10+0x1bf>
			1aa3: R_X86_64_PLT32	rt_int_add-0x4
    1aa7:	mov    rsi,rax
    1aaa:	mov    r14,rax
    1aad:	mov    QWORD PTR [r12],rsi
    1ab1:	mov    rsi,r14
    1ab4:	jmp    1936 <botlish_fn_10+0x4e>
    1ab9:	mov    rax,r14
    1abc:	mov    rdi,r13
    1abf:	mov    rdi,r13
    1ac2:	mov    QWORD PTR [rdi],r12
    1ac5:	mov    rbx,QWORD PTR [rsp]
    1ac9:	mov    r12,QWORD PTR [rsp+0x8]
    1ace:	mov    r13,QWORD PTR [rsp+0x10]
    1ad3:	mov    r14,QWORD PTR [rsp+0x18]
    1ad8:	add    rsp,0x20
    1adc:	mov    rsp,rbp
    1adf:	pop    rbp
    1ae0:	ret
    1ae1:	mov    r13,rdi
    1ae4:	call   1ae9 <botlish_fn_10+0x201>
			1ae5: R_X86_64_PLT32	rt_stack_overflow-0x4
    1ae9:	xor    rax,rax
    1aec:	mov    rbx,QWORD PTR [rsp]
    1af0:	mov    r12,QWORD PTR [rsp+0x8]
    1af5:	mov    r13,QWORD PTR [rsp+0x10]
    1afa:	mov    r14,QWORD PTR [rsp+0x18]
    1aff:	add    rsp,0x20
    1b03:	mov    rsp,rbp
    1b06:	pop    rbp
    1b07:	ret
    1b08:	(bad)
    1b09:	add    BYTE PTR [rax],al
    1b0b:	add    BYTE PTR [rax],al
    1b0d:	add    BYTE PTR [rax],al
	...

0000000000001b10 <botlish_entry_10: scan_alpha<generic>>:
    1b10:	push   rbp
    1b11:	mov    rbp,rsp
    1b14:	mov    rdx,QWORD PTR [rdx]
    1b17:	call   1b1c <botlish_entry_10+0xc>
			1b18: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_alpha<generic>
    1b1c:	mov    rsp,rbp
    1b1f:	pop    rbp
    1b20:	ret
    1b21:	add    BYTE PTR [rax],al
    1b23:	add    BYTE PTR [rax],al
    1b25:	add    BYTE PTR [rax],al
	...

0000000000001b28 <botlish_fn_11: tld_ok<generic>>:
    1b28:	push   rbp
    1b29:	mov    rbp,rsp
    1b2c:	sub    rsp,0x30
    1b30:	mov    QWORD PTR [rsp],rbx
    1b34:	mov    QWORD PTR [rsp+0x8],r12
    1b39:	mov    QWORD PTR [rsp+0x10],r13
    1b3e:	mov    QWORD PTR [rsp+0x18],r14
    1b43:	mov    QWORD PTR [rsp+0x20],r15
    1b48:	mov    rbx,QWORD PTR [rdi]
    1b4b:	mov    rax,QWORD PTR [rdi+0x8]
    1b4f:	lea    rcx,[rbx+0x10]
    1b53:	cmp    rcx,rax
    1b56:	ja     1d58 <botlish_fn_11+0x230>
    1b5c:	lea    rax,[rbx+0x10]
    1b60:	mov    QWORD PTR [rdi],rax
    1b63:	mov    r13,rdi
    1b66:	mov    QWORD PTR [rbx],rdx
    1b69:	mov    r8,rdx
    1b6c:	mov    rax,QWORD PTR [rsi+0x20]
    1b70:	mov    r15,rsi
    1b73:	mov    rsi,QWORD PTR [rax]
    1b76:	mov    QWORD PTR [rbx+0x8],rsi
    1b7a:	mov    r12,r8
    1b7d:	mov    rdx,r12
    1b80:	mov    rdi,r13
    1b83:	call   1b88 <botlish_fn_11+0x60>
			1b84: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_alpha<generic>
    1b88:	mov    rcx,rax
    1b8b:	mov    r14,rax
    1b8e:	test   rax,rcx
    1b91:	jne    1b9f <botlish_fn_11+0x77>
    1b97:	mov    rdi,r13
    1b9a:	jmp    1c74 <botlish_fn_11+0x14c>
    1b9f:	mov    rax,r14
    1ba2:	mov    QWORD PTR [rbx+0x8],rax
    1ba6:	mov    rsi,r15
    1ba9:	mov    rax,QWORD PTR [rsi+0x20]
    1bad:	mov    rdx,QWORD PTR [rax+0x8]
    1bb1:	mov    rax,r14
    1bb4:	and    rax,rdx
    1bb7:	test   rax,0x1
    1bbd:	jne    1be6 <botlish_fn_11+0xbe>
    1bc3:	mov    rsi,r14
    1bc6:	mov    rdi,r13
    1bc9:	call   1bce <botlish_fn_11+0xa6>
			1bca: R_X86_64_PLT32	rt_int_cmp-0x4
    1bce:	mov    ecx,0x2
    1bd3:	test   rax,rax
    1bd6:	cmove  rcx,QWORD PTR [rip+0x1aa]        # 1d88 <botlish_fn_11+0x260>
    1bde:	mov    rax,r14
    1be1:	jmp    1bf9 <botlish_fn_11+0xd1>
    1be6:	mov    ecx,0x2
    1beb:	mov    rax,r14
    1bee:	cmp    rax,rdx
    1bf1:	cmove  rcx,QWORD PTR [rip+0x18f]        # 1d88 <botlish_fn_11+0x260>
    1bf9:	cmp    rcx,0x6
    1bfd:	je     1c13 <botlish_fn_11+0xeb>
    1c03:	mov    ecx,0x2
    1c08:	mov    rax,rcx
    1c0b:	mov    rdi,r13
    1c0e:	jmp    1d31 <botlish_fn_11+0x209>
    1c13:	mov    ecx,0x1
    1c18:	test   r12,0x1
    1c1f:	je     1c2d <botlish_fn_11+0x105>
    1c25:	mov    r8,r12
    1c28:	jmp    1c53 <botlish_fn_11+0x12b>
    1c2d:	xor    ecx,ecx
    1c2f:	test   r12,0x7
    1c36:	je     1c44 <botlish_fn_11+0x11c>
    1c3c:	mov    r8,r12
    1c3f:	jmp    1c53 <botlish_fn_11+0x12b>
    1c44:	movzx  rcx,BYTE PTR [r12]
    1c49:	mov    r8,r12
    1c4c:	rex cmp cl,0x1
    1c50:	sete   cl
    1c53:	test   cl,cl
    1c55:	jne    1c9e <botlish_fn_11+0x176>
    1c5b:	mov    rdi,r13
    1c5e:	mov    rax,QWORD PTR [rdi+0x10]
    1c62:	mov    rcx,QWORD PTR [rax+0x78]
    1c66:	xor    rdx,rdx
    1c69:	mov    rsi,r8
    1c6c:	call   1c71 <botlish_fn_11+0x149>
			1c6d: R_X86_64_PLT32	rt_type_error-0x4
    1c71:	mov    rdi,r13
    1c74:	mov    rdi,r13
    1c77:	mov    QWORD PTR [rdi],rbx
    1c7a:	xor    rax,rax
    1c7d:	mov    rbx,QWORD PTR [rsp]
    1c81:	mov    r12,QWORD PTR [rsp+0x8]
    1c86:	mov    r13,QWORD PTR [rsp+0x10]
    1c8b:	mov    r14,QWORD PTR [rsp+0x18]
    1c90:	mov    r15,QWORD PTR [rsp+0x20]
    1c95:	add    rsp,0x30
    1c99:	mov    rsp,rbp
    1c9c:	pop    rbp
    1c9d:	ret
    1c9e:	mov    r12,r8
    1ca1:	mov    rcx,rax
    1ca4:	and    rcx,r12
    1ca7:	test   rcx,0x1
    1cae:	jne    1cbf <botlish_fn_11+0x197>
    1cb4:	mov    rdx,r8
    1cb7:	mov    rsi,rax
    1cba:	jmp    1ce0 <botlish_fn_11+0x1b8>
    1cbf:	mov    r12,r8
    1cc2:	mov    rcx,rax
    1cc5:	sub    rcx,r12
    1cc8:	mov    r14,rax
    1ccb:	seto   al
    1cce:	lea    rsi,[rcx+0x1]
    1cd2:	test   al,al
    1cd4:	je     1ceb <botlish_fn_11+0x1c3>
    1cda:	mov    rdx,r8
    1cdd:	mov    rsi,r14
    1ce0:	mov    rdi,r13
    1ce3:	call   1ce8 <botlish_fn_11+0x1c0>
			1ce4: R_X86_64_PLT32	rt_int_sub-0x4
    1ce8:	mov    rsi,rax
    1ceb:	test   rsi,0x1
    1cf2:	jne    1d1d <botlish_fn_11+0x1f5>
    1cf8:	mov    edx,0x5
    1cfd:	mov    rdi,r13
    1d00:	call   1d05 <botlish_fn_11+0x1dd>
			1d01: R_X86_64_PLT32	rt_int_cmp-0x4
    1d05:	mov    ecx,0x2
    1d0a:	test   rax,rax
    1d0d:	mov    rax,rcx
    1d10:	cmovge rax,QWORD PTR [rip+0x70]        # 1d88 <botlish_fn_11+0x260>
    1d18:	jmp    1d2e <botlish_fn_11+0x206>
    1d1d:	mov    eax,0x2
    1d22:	cmp    rsi,0x5
    1d26:	cmovge rax,QWORD PTR [rip+0x5a]        # 1d88 <botlish_fn_11+0x260>
    1d2e:	mov    rdi,r13
    1d31:	mov    rdi,r13
    1d34:	mov    QWORD PTR [rdi],rbx
    1d37:	mov    rbx,QWORD PTR [rsp]
    1d3b:	mov    r12,QWORD PTR [rsp+0x8]
    1d40:	mov    r13,QWORD PTR [rsp+0x10]
    1d45:	mov    r14,QWORD PTR [rsp+0x18]
    1d4a:	mov    r15,QWORD PTR [rsp+0x20]
    1d4f:	add    rsp,0x30
    1d53:	mov    rsp,rbp
    1d56:	pop    rbp
    1d57:	ret
    1d58:	mov    r13,rdi
    1d5b:	call   1d60 <botlish_fn_11+0x238>
			1d5c: R_X86_64_PLT32	rt_stack_overflow-0x4
    1d60:	xor    rax,rax
    1d63:	mov    rbx,QWORD PTR [rsp]
    1d67:	mov    r12,QWORD PTR [rsp+0x8]
    1d6c:	mov    r13,QWORD PTR [rsp+0x10]
    1d71:	mov    r14,QWORD PTR [rsp+0x18]
    1d76:	mov    r15,QWORD PTR [rsp+0x20]
    1d7b:	add    rsp,0x30
    1d7f:	mov    rsp,rbp
    1d82:	pop    rbp
    1d83:	ret
    1d84:	add    BYTE PTR [rax],al
    1d86:	add    BYTE PTR [rax],al
    1d88:	(bad)
    1d89:	add    BYTE PTR [rax],al
    1d8b:	add    BYTE PTR [rax],al
    1d8d:	add    BYTE PTR [rax],al
	...

0000000000001d90 <botlish_entry_11: tld_ok<generic>>:
    1d90:	push   rbp
    1d91:	mov    rbp,rsp
    1d94:	mov    rdx,QWORD PTR [rdx]
    1d97:	call   1d9c <botlish_entry_11+0xc>
			1d98: R_X86_64_PLT32	botlish_fn_11-0x4 ; tld_ok<generic>
    1d9c:	mov    rsp,rbp
    1d9f:	pop    rbp
    1da0:	ret
    1da1:	add    BYTE PTR [rax],al
    1da3:	add    BYTE PTR [rax],al
    1da5:	add    BYTE PTR [rax],al
	...

0000000000001da8 <botlish_fn_12: domain_loop<generic>>:
    1da8:	push   rbp
    1da9:	mov    rbp,rsp
    1dac:	sub    rsp,0x50
    1db0:	mov    QWORD PTR [rsp+0x20],rbx
    1db5:	mov    QWORD PTR [rsp+0x28],r12
    1dba:	mov    QWORD PTR [rsp+0x30],r13
    1dbf:	mov    QWORD PTR [rsp+0x38],r14
    1dc4:	mov    QWORD PTR [rsp+0x40],r15
    1dc9:	mov    r13,QWORD PTR [rdi]
    1dcc:	mov    rax,QWORD PTR [rdi+0x8]
    1dd0:	lea    rcx,[r13+0x10]
    1dd4:	cmp    rcx,rax
    1dd7:	ja     2043 <botlish_fn_12+0x29b>
    1ddd:	lea    rax,[r13+0x10]
    1de1:	mov    QWORD PTR [rdi],rax
    1de4:	mov    r15,rdi
    1de7:	mov    QWORD PTR [r13+0x0],rdx
    1deb:	mov    QWORD PTR [rsp+0x10],rdx
    1df0:	lea    rbx,[rsp]
    1df4:	mov    r12,rsi
    1df7:	mov    rax,QWORD PTR [r12+0x20]
    1dfc:	mov    rsi,QWORD PTR [rax]
    1dff:	mov    QWORD PTR [r13+0x8],rsi
    1e03:	mov    rdx,QWORD PTR [rsp+0x10]
    1e08:	mov    rdi,r15
    1e0b:	call   1e10 <botlish_fn_12+0x68>
			1e0c: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_label<generic>
    1e10:	mov    rcx,rax
    1e13:	mov    r14,rax
    1e16:	test   rax,rcx
    1e19:	jne    1e27 <botlish_fn_12+0x7f>
    1e1f:	mov    rdi,r15
    1e22:	jmp    1fb1 <botlish_fn_12+0x209>
    1e27:	mov    rax,r14
    1e2a:	mov    QWORD PTR [r13+0x0],rax
    1e2e:	mov    rdx,QWORD PTR [rsp+0x10]
    1e33:	mov    rsi,rax
    1e36:	and    rsi,rdx
    1e39:	test   rsi,0x1
    1e40:	jne    1e67 <botlish_fn_12+0xbf>
    1e46:	mov    rdx,QWORD PTR [rsp+0x10]
    1e4b:	mov    rsi,r14
    1e4e:	mov    rdi,r15
    1e51:	call   1e56 <botlish_fn_12+0xae>
			1e52: R_X86_64_PLT32	rt_value_eq-0x4
    1e56:	test   rax,rax
    1e59:	jne    1e7c <botlish_fn_12+0xd4>
    1e5f:	mov    rdi,r15
    1e62:	jmp    1fb1 <botlish_fn_12+0x209>
    1e67:	mov    eax,0x2
    1e6c:	mov    rdx,QWORD PTR [rsp+0x10]
    1e71:	cmp    r14,rdx
    1e74:	cmove  rax,QWORD PTR [rip+0x1f4]        # 2070 <botlish_fn_12+0x2c8>
    1e7c:	cmp    rax,0x6
    1e80:	je     2011 <botlish_fn_12+0x269>
    1e86:	mov    rax,QWORD PTR [r12+0x20]
    1e8b:	mov    rdx,QWORD PTR [rax+0x8]
    1e8f:	mov    rax,r14
    1e92:	and    rax,rdx
    1e95:	test   rax,0x1
    1e9b:	jne    1ec1 <botlish_fn_12+0x119>
    1ea1:	mov    rsi,r14
    1ea4:	mov    rdi,r15
    1ea7:	call   1eac <botlish_fn_12+0x104>
			1ea8: R_X86_64_PLT32	rt_int_cmp-0x4
    1eac:	mov    ecx,0x2
    1eb1:	test   rax,rax
    1eb4:	cmovge rcx,QWORD PTR [rip+0x1b4]        # 2070 <botlish_fn_12+0x2c8>
    1ebc:	jmp    1ed1 <botlish_fn_12+0x129>
    1ec1:	mov    ecx,0x2
    1ec6:	cmp    r14,rdx
    1ec9:	cmovge rcx,QWORD PTR [rip+0x19f]        # 2070 <botlish_fn_12+0x2c8>
    1ed1:	cmp    rcx,0x6
    1ed5:	je     2002 <botlish_fn_12+0x25a>
    1edb:	mov    rax,QWORD PTR [r12+0x20]
    1ee0:	mov    rsi,QWORD PTR [rax+0x10]
    1ee4:	mov    QWORD PTR [r13+0x8],rsi
    1ee8:	mov    rcx,rbx
    1eeb:	mov    rdx,r14
    1eee:	mov    rdi,r15
    1ef1:	call   1ef6 <botlish_fn_12+0x14e>
			1ef2: R_X86_64_PLT32	botlish_fn_5-0x4 ; char_at<generic>
    1ef6:	test   rax,rax
    1ef9:	mov    rsi,rax
    1efc:	jne    1f0a <botlish_fn_12+0x162>
    1f02:	mov    rdi,r15
    1f05:	jmp    1fb1 <botlish_fn_12+0x209>
    1f0a:	mov    rdx,QWORD PTR [rsp]
    1f0e:	mov    rcx,QWORD PTR [rsp+0x8]
    1f13:	mov    rdi,r15
    1f16:	mov    rax,QWORD PTR [rdi+0x10]
    1f1a:	mov    r8,QWORD PTR [rax+0x60]
    1f1e:	call   1f23 <botlish_fn_12+0x17b>
			1f1f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1f23:	cmp    rax,0x6
    1f27:	je     1f39 <botlish_fn_12+0x191>
    1f2d:	mov    rax,0xffffffffffffffff
    1f34:	jmp    2009 <botlish_fn_12+0x261>
    1f39:	mov    QWORD PTR [r13+0x8],0x3
    1f41:	test   r14,0x1
    1f48:	je     1f6f <botlish_fn_12+0x1c7>
    1f4e:	mov    rdx,r14
    1f51:	add    rdx,0x2
    1f55:	mov    QWORD PTR [rsp+0x10],rdx
    1f5a:	seto   al
    1f5d:	test   al,al
    1f5f:	jne    1f6f <botlish_fn_12+0x1c7>
    1f65:	mov    rdx,QWORD PTR [rsp+0x10]
    1f6a:	jmp    1f87 <botlish_fn_12+0x1df>
    1f6f:	mov    edx,0x3
    1f74:	mov    rsi,r14
    1f77:	mov    rdi,r15
    1f7a:	call   1f7f <botlish_fn_12+0x1d7>
			1f7b: R_X86_64_PLT32	rt_int_add-0x4
    1f7f:	mov    rdx,rax
    1f82:	mov    QWORD PTR [rsp+0x10],rax
    1f87:	mov    QWORD PTR [r13+0x0],rdx
    1f8b:	mov    rax,QWORD PTR [r12+0x20]
    1f90:	mov    rsi,QWORD PTR [rax+0x18]
    1f94:	mov    QWORD PTR [r13+0x8],rsi
    1f98:	mov    rdx,QWORD PTR [rsp+0x10]
    1f9d:	mov    rdi,r15
    1fa0:	call   1fa5 <botlish_fn_12+0x1fd>
			1fa1: R_X86_64_PLT32	botlish_fn_11-0x4 ; tld_ok<generic>
    1fa5:	test   rax,rax
    1fa8:	jne    1fdc <botlish_fn_12+0x234>
    1fae:	mov    rdi,r15
    1fb1:	mov    rdi,r15
    1fb4:	mov    QWORD PTR [rdi],r13
    1fb7:	xor    rax,rax
    1fba:	mov    rbx,QWORD PTR [rsp+0x20]
    1fbf:	mov    r12,QWORD PTR [rsp+0x28]
    1fc4:	mov    r13,QWORD PTR [rsp+0x30]
    1fc9:	mov    r14,QWORD PTR [rsp+0x38]
    1fce:	mov    r15,QWORD PTR [rsp+0x40]
    1fd3:	add    rsp,0x50
    1fd7:	mov    rsp,rbp
    1fda:	pop    rbp
    1fdb:	ret
    1fdc:	cmp    rax,0x6
    1fe0:	je     1ff4 <botlish_fn_12+0x24c>
    1fe6:	mov    rdx,QWORD PTR [rsp+0x10]
    1feb:	mov    QWORD PTR [r13+0x0],rdx
    1fef:	jmp    1df7 <botlish_fn_12+0x4f>
    1ff4:	mov    rax,QWORD PTR [r12+0x20]
    1ff9:	mov    rax,QWORD PTR [rax+0x8]
    1ffd:	jmp    2009 <botlish_fn_12+0x261>
    2002:	mov    rax,0xffffffffffffffff
    2009:	mov    rdi,r15
    200c:	jmp    201b <botlish_fn_12+0x273>
    2011:	mov    rax,0xffffffffffffffff
    2018:	mov    rdi,r15
    201b:	mov    rdi,r15
    201e:	mov    QWORD PTR [rdi],r13
    2021:	mov    rbx,QWORD PTR [rsp+0x20]
    2026:	mov    r12,QWORD PTR [rsp+0x28]
    202b:	mov    r13,QWORD PTR [rsp+0x30]
    2030:	mov    r14,QWORD PTR [rsp+0x38]
    2035:	mov    r15,QWORD PTR [rsp+0x40]
    203a:	add    rsp,0x50
    203e:	mov    rsp,rbp
    2041:	pop    rbp
    2042:	ret
    2043:	mov    r15,rdi
    2046:	call   204b <botlish_fn_12+0x2a3>
			2047: R_X86_64_PLT32	rt_stack_overflow-0x4
    204b:	xor    rax,rax
    204e:	mov    rbx,QWORD PTR [rsp+0x20]
    2053:	mov    r12,QWORD PTR [rsp+0x28]
    2058:	mov    r13,QWORD PTR [rsp+0x30]
    205d:	mov    r14,QWORD PTR [rsp+0x38]
    2062:	mov    r15,QWORD PTR [rsp+0x40]
    2067:	add    rsp,0x50
    206b:	mov    rsp,rbp
    206e:	pop    rbp
    206f:	ret
    2070:	(bad)
    2071:	add    BYTE PTR [rax],al
    2073:	add    BYTE PTR [rax],al
    2075:	add    BYTE PTR [rax],al
	...

0000000000002078 <botlish_entry_12: domain_loop<generic>>:
    2078:	push   rbp
    2079:	mov    rbp,rsp
    207c:	mov    rdx,QWORD PTR [rdx]
    207f:	call   2084 <botlish_entry_12+0xc>
			2080: R_X86_64_PLT32	botlish_fn_12-0x4 ; domain_loop<generic>
    2084:	mov    rsp,rbp
    2087:	pop    rbp
    2088:	ret
    2089:	add    BYTE PTR [rax],al
    208b:	add    BYTE PTR [rax],al
    208d:	add    BYTE PTR [rax],al
	...

0000000000002090 <botlish_fn_13: <str>>:
    2090:	push   rbp
    2091:	mov    rbp,rsp
    2094:	sub    rsp,0xc0
    209b:	mov    QWORD PTR [rsp+0x90],rbx
    20a3:	mov    QWORD PTR [rsp+0x98],r12
    20ab:	mov    QWORD PTR [rsp+0xa0],r13
    20b3:	mov    QWORD PTR [rsp+0xa8],r14
    20bb:	mov    QWORD PTR [rsp+0xb0],r15
    20c3:	mov    r12,QWORD PTR [rdi]
    20c6:	mov    rax,QWORD PTR [rdi+0x8]
    20ca:	lea    rcx,[r12+0x28]
    20cf:	cmp    rcx,rax
    20d2:	ja     24e1 <botlish_fn_13+0x451>
    20d8:	lea    rax,[r12+0x28]
    20dd:	mov    QWORD PTR [rdi],rax
    20e0:	mov    QWORD PTR [rsp+0x78],rdi
    20e5:	mov    QWORD PTR [r12+0x10],0x0
    20ee:	mov    QWORD PTR [r12+0x18],0x0
    20f7:	mov    QWORD PTR [r12+0x20],0x0
    2100:	mov    QWORD PTR [r12],rsi
    2104:	mov    r13,rsi
    2107:	mov    rsi,r13
    210a:	mov    rdi,QWORD PTR [rsp+0x78]
    210f:	call   2114 <botlish_fn_13+0x84>
			2110: R_X86_64_PLT32	rt_str_len-0x4
    2114:	mov    rbx,rax
    2117:	mov    QWORD PTR [r12+0x8],rbx
    211c:	lea    r8,[rsp]
    2120:	mov    QWORD PTR [rsp],r13
    2124:	mov    esi,0xf
    2129:	mov    rdx,QWORD PTR [rip+0x0]        # 2130 <botlish_fn_13+0xa0>
			212c: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; char_at<generic>
    2130:	mov    r13d,0x1
    2136:	mov    rcx,r13
    2139:	mov    rdi,QWORD PTR [rsp+0x78]
    213e:	call   2143 <botlish_fn_13+0xb3>
			213f: R_X86_64_PLT32	rt_closure_new-0x4
    2143:	mov    r14,rax
    2146:	mov    QWORD PTR [r12],rax
    214a:	lea    r8,[rsp+0x8]
    214f:	mov    QWORD PTR [rsp+0x8],rbx
    2154:	mov    QWORD PTR [rsp+0x10],rax
    2159:	mov    esi,0x13
    215e:	mov    rdx,QWORD PTR [rip+0x0]        # 2165 <botlish_fn_13+0xd5>
			2161: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; scan_local<generic>
    2165:	mov    r15d,0x2
    216b:	mov    rcx,r15
    216e:	mov    rdi,QWORD PTR [rsp+0x78]
    2173:	call   2178 <botlish_fn_13+0xe8>
			2174: R_X86_64_PLT32	rt_closure_new-0x4
    2178:	mov    rcx,rax
    217b:	mov    QWORD PTR [rsp+0x88],rax
    2183:	mov    QWORD PTR [r12+0x10],rcx
    2188:	lea    r8,[rsp+0x18]
    218d:	mov    QWORD PTR [rsp+0x18],rbx
    2192:	mov    rax,r14
    2195:	mov    QWORD PTR [rsp+0x20],rax
    219a:	mov    esi,0x14
    219f:	mov    rdx,QWORD PTR [rip+0x0]        # 21a6 <botlish_fn_13+0x116>
			21a2: R_X86_64_GOTPCREL	botlish_entry_20-0x4 ; scan_label<generic>
    21a6:	mov    rcx,r15
    21a9:	mov    rdi,QWORD PTR [rsp+0x78]
    21ae:	call   21b3 <botlish_fn_13+0x123>
			21af: R_X86_64_PLT32	rt_closure_new-0x4
    21b3:	mov    QWORD PTR [r12+0x18],rax
    21b8:	mov    QWORD PTR [rsp+0x80],rax
    21c0:	lea    r8,[rsp+0x28]
    21c5:	mov    QWORD PTR [rsp+0x28],rbx
    21ca:	mov    QWORD PTR [rsp+0x30],r14
    21cf:	mov    esi,0x15
    21d4:	mov    rdx,QWORD PTR [rip+0x0]        # 21db <botlish_fn_13+0x14b>
			21d7: R_X86_64_GOTPCREL	botlish_entry_21-0x4 ; scan_alpha<generic>
    21db:	mov    rcx,r15
    21de:	mov    rdi,QWORD PTR [rsp+0x78]
    21e3:	call   21e8 <botlish_fn_13+0x158>
			21e4: R_X86_64_PLT32	rt_closure_new-0x4
    21e8:	mov    QWORD PTR [r12+0x20],rax
    21ed:	lea    r8,[rsp+0x38]
    21f2:	mov    QWORD PTR [rsp+0x38],rax
    21f7:	mov    QWORD PTR [rsp+0x40],rbx
    21fc:	mov    esi,0x16
    2201:	mov    rdx,QWORD PTR [rip+0x0]        # 2208 <botlish_fn_13+0x178>
			2204: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; tld_ok<generic>
    2208:	mov    rcx,r15
    220b:	mov    rdi,QWORD PTR [rsp+0x78]
    2210:	call   2215 <botlish_fn_13+0x185>
			2211: R_X86_64_PLT32	rt_closure_new-0x4
    2215:	mov    QWORD PTR [r12+0x20],rax
    221a:	lea    r8,[rsp+0x48]
    221f:	mov    rcx,QWORD PTR [rsp+0x80]
    2227:	mov    QWORD PTR [rsp+0x48],rcx
    222c:	mov    QWORD PTR [rsp+0x50],rbx
    2231:	mov    QWORD PTR [rsp+0x58],r14
    2236:	mov    QWORD PTR [rsp+0x60],rax
    223b:	mov    esi,0x17
    2240:	mov    rdx,QWORD PTR [rip+0x0]        # 2247 <botlish_fn_13+0x1b7>
			2243: R_X86_64_GOTPCREL	botlish_entry_23-0x4 ; domain_loop<generic>
    2247:	mov    ecx,0x4
    224c:	mov    rdi,QWORD PTR [rsp+0x78]
    2251:	call   2256 <botlish_fn_13+0x1c6>
			2252: R_X86_64_PLT32	rt_closure_new-0x4
    2256:	mov    QWORD PTR [r12+0x18],rax
    225b:	mov    r15,rax
    225e:	mov    QWORD PTR [r12+0x20],0x1
    2267:	mov    rdx,r13
    226a:	mov    rsi,QWORD PTR [rsp+0x88]
    2272:	mov    rdi,QWORD PTR [rsp+0x78]
    2277:	call   227c <botlish_fn_13+0x1ec>
			2278: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_local<generic>
    227c:	mov    rcx,rax
    227f:	mov    r13,rax
    2282:	test   rax,rcx
    2285:	jne    2295 <botlish_fn_13+0x205>
    228b:	mov    rdi,QWORD PTR [rsp+0x78]
    2290:	jmp    23f7 <botlish_fn_13+0x367>
    2295:	mov    rax,r13
    2298:	mov    QWORD PTR [r12+0x10],rax
    229d:	test   rax,0x1
    22a3:	jne    22d1 <botlish_fn_13+0x241>
    22a9:	mov    edx,0x1
    22ae:	mov    rsi,r13
    22b1:	mov    rdi,QWORD PTR [rsp+0x78]
    22b6:	call   22bb <botlish_fn_13+0x22b>
			22b7: R_X86_64_PLT32	rt_int_cmp-0x4
    22bb:	mov    r10d,0x2
    22c1:	test   rax,rax
    22c4:	cmove  r10,QWORD PTR [rip+0x25c]        # 2528 <botlish_fn_13+0x498>
    22cc:	jmp    22e3 <botlish_fn_13+0x253>
    22d1:	mov    r10d,0x2
    22d7:	cmp    r13,0x1
    22db:	cmove  r10,QWORD PTR [rip+0x245]        # 2528 <botlish_fn_13+0x498>
    22e3:	cmp    r10,0x6
    22e7:	je     249b <botlish_fn_13+0x40b>
    22ed:	mov    rax,r13
    22f0:	and    rax,rbx
    22f3:	test   rax,0x1
    22f9:	jne    2324 <botlish_fn_13+0x294>
    22ff:	mov    rdx,rbx
    2302:	mov    rsi,r13
    2305:	mov    rdi,QWORD PTR [rsp+0x78]
    230a:	call   230f <botlish_fn_13+0x27f>
			230b: R_X86_64_PLT32	rt_int_cmp-0x4
    230f:	mov    ecx,0x2
    2314:	test   rax,rax
    2317:	cmovge rcx,QWORD PTR [rip+0x209]        # 2528 <botlish_fn_13+0x498>
    231f:	jmp    2334 <botlish_fn_13+0x2a4>
    2324:	mov    ecx,0x2
    2329:	cmp    r13,rbx
    232c:	cmovge rcx,QWORD PTR [rip+0x1f4]        # 2528 <botlish_fn_13+0x498>
    2334:	cmp    rcx,0x6
    2338:	je     248c <botlish_fn_13+0x3fc>
    233e:	lea    rcx,[rsp+0x68]
    2343:	mov    rsi,r14
    2346:	mov    rdx,r13
    2349:	mov    rdi,QWORD PTR [rsp+0x78]
    234e:	call   2353 <botlish_fn_13+0x2c3>
			234f: R_X86_64_PLT32	botlish_fn_16-0x4 ; char_at<generic>
    2353:	test   rax,rax
    2356:	jne    2366 <botlish_fn_13+0x2d6>
    235c:	mov    rdi,QWORD PTR [rsp+0x78]
    2361:	jmp    23f7 <botlish_fn_13+0x367>
    2366:	mov    rdx,QWORD PTR [rsp+0x68]
    236b:	mov    rcx,QWORD PTR [rsp+0x70]
    2370:	mov    rdi,QWORD PTR [rsp+0x78]
    2375:	mov    rsi,QWORD PTR [rdi+0x10]
    2379:	mov    r8,QWORD PTR [rsi+0x40]
    237d:	mov    rsi,rax
    2380:	call   2385 <botlish_fn_13+0x2f5>
			2381: R_X86_64_PLT32	rt_str_region_eq-0x4
    2385:	cmp    rax,0x6
    2389:	je     239c <botlish_fn_13+0x30c>
    238f:	mov    ecx,0x2
    2394:	mov    rax,rcx
    2397:	jmp    2491 <botlish_fn_13+0x401>
    239c:	mov    QWORD PTR [r12],0x3
    23a4:	test   r13,0x1
    23ab:	je     23c3 <botlish_fn_13+0x333>
    23b1:	mov    rdx,r13
    23b4:	add    rdx,0x2
    23b8:	seto   al
    23bb:	test   al,al
    23bd:	je     23d8 <botlish_fn_13+0x348>
    23c3:	mov    edx,0x3
    23c8:	mov    rsi,r13
    23cb:	mov    rdi,QWORD PTR [rsp+0x78]
    23d0:	call   23d5 <botlish_fn_13+0x345>
			23d1: R_X86_64_PLT32	rt_int_add-0x4
    23d5:	mov    rdx,rax
    23d8:	mov    QWORD PTR [r12],rdx
    23dc:	mov    rsi,r15
    23df:	mov    rdi,QWORD PTR [rsp+0x78]
    23e4:	call   23e9 <botlish_fn_13+0x359>
			23e5: R_X86_64_PLT32	botlish_fn_23-0x4 ; domain_loop<generic>
    23e9:	test   rax,rax
    23ec:	jne    2436 <botlish_fn_13+0x3a6>
    23f2:	mov    rdi,QWORD PTR [rsp+0x78]
    23f7:	mov    rdi,QWORD PTR [rsp+0x78]
    23fc:	mov    QWORD PTR [rdi],r12
    23ff:	xor    rax,rax
    2402:	mov    rbx,QWORD PTR [rsp+0x90]
    240a:	mov    r12,QWORD PTR [rsp+0x98]
    2412:	mov    r13,QWORD PTR [rsp+0xa0]
    241a:	mov    r14,QWORD PTR [rsp+0xa8]
    2422:	mov    r15,QWORD PTR [rsp+0xb0]
    242a:	add    rsp,0xc0
    2431:	mov    rsp,rbp
    2434:	pop    rbp
    2435:	ret
    2436:	mov    rcx,rax
    2439:	and    rcx,rbx
    243c:	mov    rsi,rax
    243f:	mov    rax,rbx
    2442:	test   rcx,0x1
    2449:	jne    2474 <botlish_fn_13+0x3e4>
    244f:	mov    rdx,rax
    2452:	mov    rdi,QWORD PTR [rsp+0x78]
    2457:	call   245c <botlish_fn_13+0x3cc>
			2458: R_X86_64_PLT32	rt_int_cmp-0x4
    245c:	mov    ecx,0x2
    2461:	test   rax,rax
    2464:	mov    rax,rcx
    2467:	cmove  rax,QWORD PTR [rip+0xb9]        # 2528 <botlish_fn_13+0x498>
    246f:	jmp    2491 <botlish_fn_13+0x401>
    2474:	mov    rdx,rax
    2477:	mov    eax,0x2
    247c:	cmp    rsi,rdx
    247f:	cmove  rax,QWORD PTR [rip+0xa1]        # 2528 <botlish_fn_13+0x498>
    2487:	jmp    2491 <botlish_fn_13+0x401>
    248c:	mov    eax,0x2
    2491:	mov    rdi,QWORD PTR [rsp+0x78]
    2496:	jmp    24a5 <botlish_fn_13+0x415>
    249b:	mov    eax,0x2
    24a0:	mov    rdi,QWORD PTR [rsp+0x78]
    24a5:	mov    rdi,QWORD PTR [rsp+0x78]
    24aa:	mov    QWORD PTR [rdi],r12
    24ad:	mov    rbx,QWORD PTR [rsp+0x90]
    24b5:	mov    r12,QWORD PTR [rsp+0x98]
    24bd:	mov    r13,QWORD PTR [rsp+0xa0]
    24c5:	mov    r14,QWORD PTR [rsp+0xa8]
    24cd:	mov    r15,QWORD PTR [rsp+0xb0]
    24d5:	add    rsp,0xc0
    24dc:	mov    rsp,rbp
    24df:	pop    rbp
    24e0:	ret
    24e1:	mov    QWORD PTR [rsp+0x78],rdi
    24e6:	call   24eb <botlish_fn_13+0x45b>
			24e7: R_X86_64_PLT32	rt_stack_overflow-0x4
    24eb:	xor    rax,rax
    24ee:	mov    rbx,QWORD PTR [rsp+0x90]
    24f6:	mov    r12,QWORD PTR [rsp+0x98]
    24fe:	mov    r13,QWORD PTR [rsp+0xa0]
    2506:	mov    r14,QWORD PTR [rsp+0xa8]
    250e:	mov    r15,QWORD PTR [rsp+0xb0]
    2516:	add    rsp,0xc0
    251d:	mov    rsp,rbp
    2520:	pop    rbp
    2521:	ret
    2522:	add    BYTE PTR [rax],al
    2524:	add    BYTE PTR [rax],al
    2526:	add    BYTE PTR [rax],al
    2528:	(bad)
    2529:	add    BYTE PTR [rax],al
    252b:	add    BYTE PTR [rax],al
    252d:	add    BYTE PTR [rax],al
	...

0000000000002530 <botlish_entry_13: <str>>:
    2530:	push   rbp
    2531:	mov    rbp,rsp
    2534:	mov    rsi,QWORD PTR [rdx]
    2537:	call   253c <botlish_entry_13+0xc>
			2538: R_X86_64_PLT32	botlish_fn_13-0x4 ; <str>
    253c:	mov    rsp,rbp
    253f:	pop    rbp
    2540:	ret
    2541:	add    BYTE PTR [rax],al
    2543:	add    BYTE PTR [rax],al
    2545:	add    BYTE PTR [rax],al
	...

0000000000002548 <botlish_fn_14: <generic>>:
    2548:	push   rbp
    2549:	mov    rbp,rsp
    254c:	sub    rsp,0xc0
    2553:	mov    QWORD PTR [rsp+0x90],rbx
    255b:	mov    QWORD PTR [rsp+0x98],r12
    2563:	mov    QWORD PTR [rsp+0xa0],r13
    256b:	mov    QWORD PTR [rsp+0xa8],r14
    2573:	mov    QWORD PTR [rsp+0xb0],r15
    257b:	mov    r12,QWORD PTR [rdi]
    257e:	mov    rax,QWORD PTR [rdi+0x8]
    2582:	lea    rcx,[r12+0x28]
    2587:	cmp    rcx,rax
    258a:	ja     29d4 <botlish_fn_14+0x48c>
    2590:	lea    rax,[r12+0x28]
    2595:	mov    QWORD PTR [rdi],rax
    2598:	mov    QWORD PTR [r12+0x10],0x0
    25a1:	mov    QWORD PTR [r12+0x18],0x0
    25aa:	mov    QWORD PTR [r12+0x20],0x0
    25b3:	mov    QWORD PTR [r12],rsi
    25b7:	xor    eax,eax
    25b9:	test   rsi,0x7
    25c0:	jne    25cf <botlish_fn_14+0x87>
    25c6:	movzx  rax,BYTE PTR [rsi]
    25ca:	cmp    al,0x2
    25cc:	sete   al
    25cf:	test   al,al
    25d1:	jne    25f8 <botlish_fn_14+0xb0>
    25d7:	mov    rax,QWORD PTR [rdi+0x10]
    25db:	mov    QWORD PTR [rsp+0x78],rdi
    25e0:	mov    rcx,QWORD PTR [rax+0x48]
    25e4:	mov    edx,0x1
    25e9:	call   25ee <botlish_fn_14+0xa6>
			25ea: R_X86_64_PLT32	rt_type_error-0x4
    25ee:	mov    rdi,QWORD PTR [rsp+0x78]
    25f3:	jmp    28ea <botlish_fn_14+0x3a2>
    25f8:	mov    r13,rsi
    25fb:	mov    QWORD PTR [rsp+0x78],rdi
    2600:	call   2605 <botlish_fn_14+0xbd>
			2601: R_X86_64_PLT32	rt_str_len-0x4
    2605:	mov    rbx,rax
    2608:	mov    QWORD PTR [r12+0x8],rbx
    260d:	lea    r8,[rsp]
    2611:	mov    QWORD PTR [rsp],r13
    2615:	mov    esi,0xf
    261a:	mov    rdx,QWORD PTR [rip+0x0]        # 2621 <botlish_fn_14+0xd9>
			261d: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; char_at<generic>
    2621:	mov    r13d,0x1
    2627:	mov    rcx,r13
    262a:	mov    rdi,QWORD PTR [rsp+0x78]
    262f:	call   2634 <botlish_fn_14+0xec>
			2630: R_X86_64_PLT32	rt_closure_new-0x4
    2634:	mov    r15,rax
    2637:	mov    QWORD PTR [rsp+0x88],r13
    263f:	mov    QWORD PTR [r12],rax
    2643:	lea    r8,[rsp+0x8]
    2648:	mov    QWORD PTR [rsp+0x8],rbx
    264d:	mov    QWORD PTR [rsp+0x10],rax
    2652:	mov    esi,0x13
    2657:	mov    rdx,QWORD PTR [rip+0x0]        # 265e <botlish_fn_14+0x116>
			265a: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; scan_local<generic>
    265e:	mov    r14d,0x2
    2664:	mov    rcx,r14
    2667:	mov    rdi,QWORD PTR [rsp+0x78]
    266c:	call   2671 <botlish_fn_14+0x129>
			266d: R_X86_64_PLT32	rt_closure_new-0x4
    2671:	mov    r13,rax
    2674:	mov    QWORD PTR [r12+0x10],r13
    2679:	lea    r8,[rsp+0x18]
    267e:	mov    QWORD PTR [rsp+0x18],rbx
    2683:	mov    rax,r15
    2686:	mov    QWORD PTR [rsp+0x20],rax
    268b:	mov    esi,0x14
    2690:	mov    rdx,QWORD PTR [rip+0x0]        # 2697 <botlish_fn_14+0x14f>
			2693: R_X86_64_GOTPCREL	botlish_entry_20-0x4 ; scan_label<generic>
    2697:	mov    rcx,r14
    269a:	mov    rdi,QWORD PTR [rsp+0x78]
    269f:	call   26a4 <botlish_fn_14+0x15c>
			26a0: R_X86_64_PLT32	rt_closure_new-0x4
    26a4:	mov    QWORD PTR [r12+0x18],rax
    26a9:	mov    QWORD PTR [rsp+0x80],rax
    26b1:	lea    r8,[rsp+0x28]
    26b6:	mov    QWORD PTR [rsp+0x28],rbx
    26bb:	mov    QWORD PTR [rsp+0x30],r15
    26c0:	mov    esi,0x15
    26c5:	mov    rdx,QWORD PTR [rip+0x0]        # 26cc <botlish_fn_14+0x184>
			26c8: R_X86_64_GOTPCREL	botlish_entry_21-0x4 ; scan_alpha<generic>
    26cc:	mov    rcx,r14
    26cf:	mov    rdi,QWORD PTR [rsp+0x78]
    26d4:	call   26d9 <botlish_fn_14+0x191>
			26d5: R_X86_64_PLT32	rt_closure_new-0x4
    26d9:	mov    QWORD PTR [r12+0x20],rax
    26de:	lea    r8,[rsp+0x38]
    26e3:	mov    QWORD PTR [rsp+0x38],rax
    26e8:	mov    QWORD PTR [rsp+0x40],rbx
    26ed:	mov    esi,0x16
    26f2:	mov    rdx,QWORD PTR [rip+0x0]        # 26f9 <botlish_fn_14+0x1b1>
			26f5: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; tld_ok<generic>
    26f9:	mov    rcx,r14
    26fc:	mov    rdi,QWORD PTR [rsp+0x78]
    2701:	call   2706 <botlish_fn_14+0x1be>
			2702: R_X86_64_PLT32	rt_closure_new-0x4
    2706:	mov    QWORD PTR [r12+0x20],rax
    270b:	lea    r8,[rsp+0x48]
    2710:	mov    rcx,QWORD PTR [rsp+0x80]
    2718:	mov    QWORD PTR [rsp+0x48],rcx
    271d:	mov    QWORD PTR [rsp+0x50],rbx
    2722:	mov    QWORD PTR [rsp+0x58],r15
    2727:	mov    QWORD PTR [rsp+0x60],rax
    272c:	mov    esi,0x17
    2731:	mov    rdx,QWORD PTR [rip+0x0]        # 2738 <botlish_fn_14+0x1f0>
			2734: R_X86_64_GOTPCREL	botlish_entry_23-0x4 ; domain_loop<generic>
    2738:	mov    ecx,0x4
    273d:	mov    rdi,QWORD PTR [rsp+0x78]
    2742:	call   2747 <botlish_fn_14+0x1ff>
			2743: R_X86_64_PLT32	rt_closure_new-0x4
    2747:	mov    QWORD PTR [r12+0x18],rax
    274c:	mov    r14,rax
    274f:	mov    QWORD PTR [r12+0x20],0x1
    2758:	mov    rsi,r13
    275b:	mov    rdx,QWORD PTR [rsp+0x88]
    2763:	mov    rdi,QWORD PTR [rsp+0x78]
    2768:	call   276d <botlish_fn_14+0x225>
			2769: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_local<generic>
    276d:	mov    r10,rax
    2770:	mov    r13,rax
    2773:	test   rax,r10
    2776:	jne    2786 <botlish_fn_14+0x23e>
    277c:	mov    rdi,QWORD PTR [rsp+0x78]
    2781:	jmp    28ea <botlish_fn_14+0x3a2>
    2786:	mov    rax,r13
    2789:	mov    QWORD PTR [r12+0x10],rax
    278e:	test   rax,0x1
    2794:	jne    27c4 <botlish_fn_14+0x27c>
    279a:	mov    rdx,QWORD PTR [rsp+0x88]
    27a2:	mov    rsi,r13
    27a5:	mov    rdi,QWORD PTR [rsp+0x78]
    27aa:	call   27af <botlish_fn_14+0x267>
			27ab: R_X86_64_PLT32	rt_int_cmp-0x4
    27af:	mov    ecx,0x2
    27b4:	test   rax,rax
    27b7:	cmove  rcx,QWORD PTR [rip+0x259]        # 2a18 <botlish_fn_14+0x4d0>
    27bf:	jmp    27d5 <botlish_fn_14+0x28d>
    27c4:	mov    ecx,0x2
    27c9:	cmp    r13,0x1
    27cd:	cmove  rcx,QWORD PTR [rip+0x243]        # 2a18 <botlish_fn_14+0x4d0>
    27d5:	cmp    rcx,0x6
    27d9:	je     298e <botlish_fn_14+0x446>
    27df:	mov    r11,r13
    27e2:	and    r11,rbx
    27e5:	test   r11,0x1
    27ec:	jne    2817 <botlish_fn_14+0x2cf>
    27f2:	mov    rdx,rbx
    27f5:	mov    rsi,r13
    27f8:	mov    rdi,QWORD PTR [rsp+0x78]
    27fd:	call   2802 <botlish_fn_14+0x2ba>
			27fe: R_X86_64_PLT32	rt_int_cmp-0x4
    2802:	mov    ecx,0x2
    2807:	test   rax,rax
    280a:	cmovge rcx,QWORD PTR [rip+0x206]        # 2a18 <botlish_fn_14+0x4d0>
    2812:	jmp    2827 <botlish_fn_14+0x2df>
    2817:	mov    ecx,0x2
    281c:	cmp    r13,rbx
    281f:	cmovge rcx,QWORD PTR [rip+0x1f1]        # 2a18 <botlish_fn_14+0x4d0>
    2827:	cmp    rcx,0x6
    282b:	je     297f <botlish_fn_14+0x437>
    2831:	lea    rcx,[rsp+0x68]
    2836:	mov    rsi,r15
    2839:	mov    rdx,r13
    283c:	mov    rdi,QWORD PTR [rsp+0x78]
    2841:	call   2846 <botlish_fn_14+0x2fe>
			2842: R_X86_64_PLT32	botlish_fn_16-0x4 ; char_at<generic>
    2846:	test   rax,rax
    2849:	mov    rsi,rax
    284c:	jne    285c <botlish_fn_14+0x314>
    2852:	mov    rdi,QWORD PTR [rsp+0x78]
    2857:	jmp    28ea <botlish_fn_14+0x3a2>
    285c:	mov    rdx,QWORD PTR [rsp+0x68]
    2861:	mov    rcx,QWORD PTR [rsp+0x70]
    2866:	mov    rdi,QWORD PTR [rsp+0x78]
    286b:	mov    rax,QWORD PTR [rdi+0x10]
    286f:	mov    r8,QWORD PTR [rax+0x40]
    2873:	call   2878 <botlish_fn_14+0x330>
			2874: R_X86_64_PLT32	rt_str_region_eq-0x4
    2878:	cmp    rax,0x6
    287c:	je     288f <botlish_fn_14+0x347>
    2882:	mov    esi,0x2
    2887:	mov    rax,rsi
    288a:	jmp    2984 <botlish_fn_14+0x43c>
    288f:	mov    QWORD PTR [r12],0x3
    2897:	test   r13,0x1
    289e:	je     28b6 <botlish_fn_14+0x36e>
    28a4:	mov    rdx,r13
    28a7:	add    rdx,0x2
    28ab:	seto   al
    28ae:	test   al,al
    28b0:	je     28cb <botlish_fn_14+0x383>
    28b6:	mov    edx,0x3
    28bb:	mov    rsi,r13
    28be:	mov    rdi,QWORD PTR [rsp+0x78]
    28c3:	call   28c8 <botlish_fn_14+0x380>
			28c4: R_X86_64_PLT32	rt_int_add-0x4
    28c8:	mov    rdx,rax
    28cb:	mov    QWORD PTR [r12],rdx
    28cf:	mov    rsi,r14
    28d2:	mov    rdi,QWORD PTR [rsp+0x78]
    28d7:	call   28dc <botlish_fn_14+0x394>
			28d8: R_X86_64_PLT32	botlish_fn_23-0x4 ; domain_loop<generic>
    28dc:	test   rax,rax
    28df:	jne    2929 <botlish_fn_14+0x3e1>
    28e5:	mov    rdi,QWORD PTR [rsp+0x78]
    28ea:	mov    rdi,QWORD PTR [rsp+0x78]
    28ef:	mov    QWORD PTR [rdi],r12
    28f2:	xor    rax,rax
    28f5:	mov    rbx,QWORD PTR [rsp+0x90]
    28fd:	mov    r12,QWORD PTR [rsp+0x98]
    2905:	mov    r13,QWORD PTR [rsp+0xa0]
    290d:	mov    r14,QWORD PTR [rsp+0xa8]
    2915:	mov    r15,QWORD PTR [rsp+0xb0]
    291d:	add    rsp,0xc0
    2924:	mov    rsp,rbp
    2927:	pop    rbp
    2928:	ret
    2929:	mov    rcx,rax
    292c:	and    rcx,rbx
    292f:	mov    rsi,rax
    2932:	mov    rax,rbx
    2935:	test   rcx,0x1
    293c:	jne    2967 <botlish_fn_14+0x41f>
    2942:	mov    rdx,rax
    2945:	mov    rdi,QWORD PTR [rsp+0x78]
    294a:	call   294f <botlish_fn_14+0x407>
			294b: R_X86_64_PLT32	rt_int_cmp-0x4
    294f:	mov    esi,0x2
    2954:	test   rax,rax
    2957:	mov    rax,rsi
    295a:	cmove  rax,QWORD PTR [rip+0xb6]        # 2a18 <botlish_fn_14+0x4d0>
    2962:	jmp    2984 <botlish_fn_14+0x43c>
    2967:	mov    rdx,rax
    296a:	mov    eax,0x2
    296f:	cmp    rsi,rdx
    2972:	cmove  rax,QWORD PTR [rip+0x9e]        # 2a18 <botlish_fn_14+0x4d0>
    297a:	jmp    2984 <botlish_fn_14+0x43c>
    297f:	mov    eax,0x2
    2984:	mov    rdi,QWORD PTR [rsp+0x78]
    2989:	jmp    2998 <botlish_fn_14+0x450>
    298e:	mov    eax,0x2
    2993:	mov    rdi,QWORD PTR [rsp+0x78]
    2998:	mov    rdi,QWORD PTR [rsp+0x78]
    299d:	mov    QWORD PTR [rdi],r12
    29a0:	mov    rbx,QWORD PTR [rsp+0x90]
    29a8:	mov    r12,QWORD PTR [rsp+0x98]
    29b0:	mov    r13,QWORD PTR [rsp+0xa0]
    29b8:	mov    r14,QWORD PTR [rsp+0xa8]
    29c0:	mov    r15,QWORD PTR [rsp+0xb0]
    29c8:	add    rsp,0xc0
    29cf:	mov    rsp,rbp
    29d2:	pop    rbp
    29d3:	ret
    29d4:	mov    QWORD PTR [rsp+0x78],rdi
    29d9:	call   29de <botlish_fn_14+0x496>
			29da: R_X86_64_PLT32	rt_stack_overflow-0x4
    29de:	xor    rax,rax
    29e1:	mov    rbx,QWORD PTR [rsp+0x90]
    29e9:	mov    r12,QWORD PTR [rsp+0x98]
    29f1:	mov    r13,QWORD PTR [rsp+0xa0]
    29f9:	mov    r14,QWORD PTR [rsp+0xa8]
    2a01:	mov    r15,QWORD PTR [rsp+0xb0]
    2a09:	add    rsp,0xc0
    2a10:	mov    rsp,rbp
    2a13:	pop    rbp
    2a14:	ret
    2a15:	add    BYTE PTR [rax],al
    2a17:	add    BYTE PTR [rsi],al
    2a19:	add    BYTE PTR [rax],al
    2a1b:	add    BYTE PTR [rax],al
    2a1d:	add    BYTE PTR [rax],al
	...

0000000000002a20 <botlish_entry_14: <generic>>:
    2a20:	push   rbp
    2a21:	mov    rbp,rsp
    2a24:	mov    rsi,QWORD PTR [rdx]
    2a27:	call   2a2c <botlish_entry_14+0xc>
			2a28: R_X86_64_PLT32	botlish_fn_14-0x4 ; <generic>
    2a2c:	mov    rsp,rbp
    2a2f:	pop    rbp
    2a30:	ret

0000000000002a31 <botlish_fn_15: char_at<generic>>:
    2a31:	push   rbp
    2a32:	mov    rbp,rsp
    2a35:	sub    rsp,0x20
    2a39:	mov    QWORD PTR [rsp],rbx
    2a3d:	mov    QWORD PTR [rsp+0x8],r12
    2a42:	mov    QWORD PTR [rsp+0x10],r13
    2a47:	mov    QWORD PTR [rsp+0x18],r14
    2a4c:	mov    rbx,QWORD PTR [rdi]
    2a4f:	mov    rax,QWORD PTR [rdi+0x8]
    2a53:	lea    rcx,[rbx+0x18]
    2a57:	cmp    rcx,rax
    2a5a:	ja     2bdc <botlish_fn_15+0x1ab>
    2a60:	lea    rax,[rbx+0x18]
    2a64:	mov    QWORD PTR [rdi],rax
    2a67:	mov    QWORD PTR [rbx],rdx
    2a6a:	mov    rax,QWORD PTR [rsi+0x20]
    2a6e:	mov    rsi,QWORD PTR [rax]
    2a71:	mov    QWORD PTR [rbx+0x8],rsi
    2a75:	mov    r14,rsi
    2a78:	mov    QWORD PTR [rbx+0x10],0x3
    2a80:	mov    ecx,0x1
    2a85:	test   rdx,0x1
    2a8c:	je     2a9a <botlish_fn_15+0x69>
    2a92:	mov    r13,rdx
    2a95:	jmp    2abd <botlish_fn_15+0x8c>
    2a9a:	xor    ecx,ecx
    2a9c:	test   rdx,0x7
    2aa3:	je     2ab1 <botlish_fn_15+0x80>
    2aa9:	mov    r13,rdx
    2aac:	jmp    2abd <botlish_fn_15+0x8c>
    2ab1:	movzx  rax,BYTE PTR [rdx]
    2ab5:	mov    r13,rdx
    2ab8:	cmp    al,0x1
    2aba:	sete   cl
    2abd:	test   cl,cl
    2abf:	jne    2ae3 <botlish_fn_15+0xb2>
    2ac5:	mov    rax,QWORD PTR [rdi+0x10]
    2ac9:	mov    r12,rdi
    2acc:	mov    rcx,QWORD PTR [rax+0x50]
    2ad0:	xor    rdx,rdx
    2ad3:	mov    rsi,r13
    2ad6:	call   2adb <botlish_fn_15+0xaa>
			2ad7: R_X86_64_PLT32	rt_type_error-0x4
    2adb:	mov    rdi,r12
    2ade:	jmp    2b95 <botlish_fn_15+0x164>
    2ae3:	mov    rsi,r13
    2ae6:	mov    r12,rdi
    2ae9:	test   rsi,0x1
    2af0:	je     2b0b <botlish_fn_15+0xda>
    2af6:	mov    rsi,r13
    2af9:	mov    rcx,rsi
    2afc:	add    rcx,0x2
    2b00:	seto   dl
    2b03:	test   dl,dl
    2b05:	je     2b1e <botlish_fn_15+0xed>
    2b0b:	mov    edx,0x3
    2b10:	mov    rsi,r13
    2b13:	mov    rdi,r12
    2b16:	call   2b1b <botlish_fn_15+0xea>
			2b17: R_X86_64_PLT32	rt_int_add-0x4
    2b1b:	mov    rcx,rax
    2b1e:	mov    QWORD PTR [rbx+0x10],rcx
    2b22:	mov    edx,0x1
    2b27:	mov    rsi,r13
    2b2a:	test   rsi,0x1
    2b31:	jne    2b55 <botlish_fn_15+0x124>
    2b37:	xor    edx,edx
    2b39:	mov    rsi,r13
    2b3c:	test   rsi,0x7
    2b43:	jne    2b55 <botlish_fn_15+0x124>
    2b49:	mov    rsi,r13
    2b4c:	movzx  rax,BYTE PTR [rsi]
    2b50:	cmp    al,0x1
    2b52:	sete   dl
    2b55:	test   dl,dl
    2b57:	jne    2b7b <botlish_fn_15+0x14a>
    2b5d:	mov    rdi,r12
    2b60:	mov    rax,QWORD PTR [rdi+0x10]
    2b64:	mov    rcx,QWORD PTR [rax+0x58]
    2b68:	xor    rdx,rdx
    2b6b:	mov    rsi,r13
    2b6e:	call   2b73 <botlish_fn_15+0x142>
			2b6f: R_X86_64_PLT32	rt_type_error-0x4
    2b73:	mov    rdi,r12
    2b76:	jmp    2b95 <botlish_fn_15+0x164>
    2b7b:	mov    rdx,r13
    2b7e:	mov    rsi,r14
    2b81:	mov    rdi,r12
    2b84:	call   2b89 <botlish_fn_15+0x158>
			2b85: R_X86_64_PLT32	rt_substr-0x4
    2b89:	test   rax,rax
    2b8c:	jne    2bba <botlish_fn_15+0x189>
    2b92:	mov    rdi,r12
    2b95:	mov    rdi,r12
    2b98:	mov    QWORD PTR [rdi],rbx
    2b9b:	xor    rax,rax
    2b9e:	mov    rbx,QWORD PTR [rsp]
    2ba2:	mov    r12,QWORD PTR [rsp+0x8]
    2ba7:	mov    r13,QWORD PTR [rsp+0x10]
    2bac:	mov    r14,QWORD PTR [rsp+0x18]
    2bb1:	add    rsp,0x20
    2bb5:	mov    rsp,rbp
    2bb8:	pop    rbp
    2bb9:	ret
    2bba:	mov    rdi,r12
    2bbd:	mov    QWORD PTR [rdi],rbx
    2bc0:	mov    rbx,QWORD PTR [rsp]
    2bc4:	mov    r12,QWORD PTR [rsp+0x8]
    2bc9:	mov    r13,QWORD PTR [rsp+0x10]
    2bce:	mov    r14,QWORD PTR [rsp+0x18]
    2bd3:	add    rsp,0x20
    2bd7:	mov    rsp,rbp
    2bda:	pop    rbp
    2bdb:	ret
    2bdc:	mov    r12,rdi
    2bdf:	call   2be4 <botlish_fn_15+0x1b3>
			2be0: R_X86_64_PLT32	rt_stack_overflow-0x4
    2be4:	xor    rax,rax
    2be7:	mov    rbx,QWORD PTR [rsp]
    2beb:	mov    r12,QWORD PTR [rsp+0x8]
    2bf0:	mov    r13,QWORD PTR [rsp+0x10]
    2bf5:	mov    r14,QWORD PTR [rsp+0x18]
    2bfa:	add    rsp,0x20
    2bfe:	mov    rsp,rbp
    2c01:	pop    rbp
    2c02:	ret

0000000000002c03 <botlish_entry_15: char_at<generic>>:
    2c03:	push   rbp
    2c04:	mov    rbp,rsp
    2c07:	mov    rdx,QWORD PTR [rdx]
    2c0a:	call   2c0f <botlish_entry_15+0xc>
			2c0b: R_X86_64_PLT32	botlish_fn_15-0x4 ; char_at<generic>
    2c0f:	mov    rsp,rbp
    2c12:	pop    rbp
    2c13:	ret

0000000000002c14 <botlish_fn_16: char_at<generic>>:
    2c14:	push   rbp
    2c15:	mov    rbp,rsp
    2c18:	sub    rsp,0x40
    2c1c:	mov    QWORD PTR [rsp+0x10],rbx
    2c21:	mov    QWORD PTR [rsp+0x18],r12
    2c26:	mov    QWORD PTR [rsp+0x20],r13
    2c2b:	mov    QWORD PTR [rsp+0x28],r14
    2c30:	mov    QWORD PTR [rsp+0x30],r15
    2c35:	mov    r15,rcx
    2c38:	mov    rbx,QWORD PTR [rdi]
    2c3b:	mov    rax,QWORD PTR [rdi+0x8]
    2c3f:	lea    rcx,[rbx+0x18]
    2c43:	cmp    rcx,rax
    2c46:	ja     2df6 <botlish_fn_16+0x1e2>
    2c4c:	lea    rax,[rbx+0x18]
    2c50:	mov    QWORD PTR [rdi],rax
    2c53:	mov    QWORD PTR [rbx],rdx
    2c56:	mov    rax,QWORD PTR [rsi+0x20]
    2c5a:	mov    rax,QWORD PTR [rax]
    2c5d:	mov    QWORD PTR [rbx+0x8],rax
    2c61:	mov    QWORD PTR [rsp],rax
    2c65:	mov    QWORD PTR [rbx+0x10],0x3
    2c6d:	mov    eax,0x1
    2c72:	test   rdx,0x1
    2c79:	je     2c87 <botlish_fn_16+0x73>
    2c7f:	mov    r14,rdx
    2c82:	jmp    2caa <botlish_fn_16+0x96>
    2c87:	xor    eax,eax
    2c89:	test   rdx,0x7
    2c90:	je     2c9e <botlish_fn_16+0x8a>
    2c96:	mov    r14,rdx
    2c99:	jmp    2caa <botlish_fn_16+0x96>
    2c9e:	movzx  rax,BYTE PTR [rdx]
    2ca2:	mov    r14,rdx
    2ca5:	cmp    al,0x1
    2ca7:	sete   al
    2caa:	test   al,al
    2cac:	jne    2cd0 <botlish_fn_16+0xbc>
    2cb2:	mov    rax,QWORD PTR [rdi+0x10]
    2cb6:	mov    r13,rdi
    2cb9:	mov    rcx,QWORD PTR [rax+0x50]
    2cbd:	xor    rdx,rdx
    2cc0:	mov    rsi,r14
    2cc3:	call   2cc8 <botlish_fn_16+0xb4>
			2cc4: R_X86_64_PLT32	rt_type_error-0x4
    2cc8:	mov    rdi,r13
    2ccb:	jmp    2d92 <botlish_fn_16+0x17e>
    2cd0:	mov    rsi,r14
    2cd3:	mov    r13,rdi
    2cd6:	test   rsi,0x1
    2cdd:	jne    2ceb <botlish_fn_16+0xd7>
    2ce3:	mov    r14,rsi
    2ce6:	jmp    2d08 <botlish_fn_16+0xf4>
    2ceb:	mov    rax,rsi
    2cee:	add    rax,0x2
    2cf2:	mov    r14,rsi
    2cf5:	seto   dl
    2cf8:	test   dl,dl
    2cfa:	jne    2d08 <botlish_fn_16+0xf4>
    2d00:	mov    r12,rax
    2d03:	jmp    2d1b <botlish_fn_16+0x107>
    2d08:	mov    edx,0x3
    2d0d:	mov    rsi,r14
    2d10:	mov    rdi,r13
    2d13:	call   2d18 <botlish_fn_16+0x104>
			2d14: R_X86_64_PLT32	rt_int_add-0x4
    2d18:	mov    r12,rax
    2d1b:	mov    ecx,0x1
    2d20:	mov    rsi,r14
    2d23:	test   rsi,0x1
    2d2a:	jne    2d4e <botlish_fn_16+0x13a>
    2d30:	xor    ecx,ecx
    2d32:	mov    rsi,r14
    2d35:	test   rsi,0x7
    2d3c:	jne    2d4e <botlish_fn_16+0x13a>
    2d42:	mov    rsi,r14
    2d45:	movzx  rax,BYTE PTR [rsi]
    2d49:	cmp    al,0x1
    2d4b:	sete   cl
    2d4e:	test   cl,cl
    2d50:	jne    2d74 <botlish_fn_16+0x160>
    2d56:	mov    rdi,r13
    2d59:	mov    rax,QWORD PTR [rdi+0x10]
    2d5d:	mov    rcx,QWORD PTR [rax+0x58]
    2d61:	xor    rdx,rdx
    2d64:	mov    rsi,r14
    2d67:	call   2d6c <botlish_fn_16+0x158>
			2d68: R_X86_64_PLT32	rt_type_error-0x4
    2d6c:	mov    rdi,r13
    2d6f:	jmp    2d92 <botlish_fn_16+0x17e>
    2d74:	mov    rcx,r12
    2d77:	mov    rdx,r14
    2d7a:	mov    rsi,QWORD PTR [rsp]
    2d7e:	mov    rdi,r13
    2d81:	call   2d86 <botlish_fn_16+0x172>
			2d82: R_X86_64_PLT32	rt_str_region_check-0x4
    2d86:	test   rax,rax
    2d89:	jne    2dbd <botlish_fn_16+0x1a9>
    2d8f:	mov    rdi,r13
    2d92:	mov    rdi,r13
    2d95:	mov    QWORD PTR [rdi],rbx
    2d98:	xor    rax,rax
    2d9b:	mov    rbx,QWORD PTR [rsp+0x10]
    2da0:	mov    r12,QWORD PTR [rsp+0x18]
    2da5:	mov    r13,QWORD PTR [rsp+0x20]
    2daa:	mov    r14,QWORD PTR [rsp+0x28]
    2daf:	mov    r15,QWORD PTR [rsp+0x30]
    2db4:	add    rsp,0x40
    2db8:	mov    rsp,rbp
    2dbb:	pop    rbp
    2dbc:	ret
    2dbd:	mov    rdi,r13
    2dc0:	mov    QWORD PTR [rdi],rbx
    2dc3:	mov    rcx,r15
    2dc6:	mov    rsi,r14
    2dc9:	mov    QWORD PTR [rcx],rsi
    2dcc:	mov    QWORD PTR [rcx+0x8],r12
    2dd0:	mov    rax,QWORD PTR [rsp]
    2dd4:	mov    rbx,QWORD PTR [rsp+0x10]
    2dd9:	mov    r12,QWORD PTR [rsp+0x18]
    2dde:	mov    r13,QWORD PTR [rsp+0x20]
    2de3:	mov    r14,QWORD PTR [rsp+0x28]
    2de8:	mov    r15,QWORD PTR [rsp+0x30]
    2ded:	add    rsp,0x40
    2df1:	mov    rsp,rbp
    2df4:	pop    rbp
    2df5:	ret
    2df6:	mov    r13,rdi
    2df9:	call   2dfe <botlish_fn_16+0x1ea>
			2dfa: R_X86_64_PLT32	rt_stack_overflow-0x4
    2dfe:	xor    rax,rax
    2e01:	mov    rbx,QWORD PTR [rsp+0x10]
    2e06:	mov    r12,QWORD PTR [rsp+0x18]
    2e0b:	mov    r13,QWORD PTR [rsp+0x20]
    2e10:	mov    r14,QWORD PTR [rsp+0x28]
    2e15:	mov    r15,QWORD PTR [rsp+0x30]
    2e1a:	add    rsp,0x40
    2e1e:	mov    rsp,rbp
    2e21:	pop    rbp
    2e22:	ret

0000000000002e23 <botlish_entry_16: char_at<generic>>:
    2e23:	push   rbp
    2e24:	mov    rbp,rsp
    2e27:	ud2

0000000000002e29 <botlish_fn_17: is_local_char<str>>:
    2e29:	push   rbp
    2e2a:	mov    rbp,rsp
    2e2d:	sub    rsp,0x20
    2e31:	mov    QWORD PTR [rsp],rbx
    2e35:	mov    QWORD PTR [rsp+0x8],r12
    2e3a:	mov    QWORD PTR [rsp+0x10],r13
    2e3f:	mov    r13,rsi
    2e42:	mov    rbx,QWORD PTR [rdi]
    2e45:	mov    rax,QWORD PTR [rdi+0x8]
    2e49:	lea    rcx,[rbx+0x8]
    2e4d:	cmp    rcx,rax
    2e50:	ja     2fac <botlish_fn_17+0x183>
    2e56:	lea    rax,[rbx+0x8]
    2e5a:	mov    QWORD PTR [rdi],rax
    2e5d:	mov    r12,rdi
    2e60:	mov    rsi,r13
    2e63:	mov    rdi,r12
    2e66:	call   2e6b <botlish_fn_17+0x42>
			2e67: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    2e6b:	test   rax,rax
    2e6e:	jne    2e94 <botlish_fn_17+0x6b>
    2e74:	mov    rdi,r12
    2e77:	mov    QWORD PTR [rdi],rbx
    2e7a:	xor    rax,rax
    2e7d:	mov    rbx,QWORD PTR [rsp]
    2e81:	mov    r12,QWORD PTR [rsp+0x8]
    2e86:	mov    r13,QWORD PTR [rsp+0x10]
    2e8b:	add    rsp,0x20
    2e8f:	mov    rsp,rbp
    2e92:	pop    rbp
    2e93:	ret
    2e94:	cmp    rax,0x6
    2e98:	je     2f87 <botlish_fn_17+0x15e>
    2e9e:	mov    rdi,r12
    2ea1:	mov    rax,QWORD PTR [rdi+0x10]
    2ea5:	mov    rsi,QWORD PTR [rax+0x60]
    2ea9:	mov    edx,0x1
    2eae:	mov    ecx,0x3
    2eb3:	mov    r8,r13
    2eb6:	call   2ebb <botlish_fn_17+0x92>
			2eb7: R_X86_64_PLT32	rt_str_region_eq-0x4
    2ebb:	cmp    rax,0x6
    2ebf:	je     2f7a <botlish_fn_17+0x151>
    2ec5:	mov    rdi,r12
    2ec8:	mov    rax,QWORD PTR [rdi+0x10]
    2ecc:	mov    rsi,QWORD PTR [rax+0x68]
    2ed0:	mov    edx,0x1
    2ed5:	mov    ecx,0x3
    2eda:	mov    r8,r13
    2edd:	call   2ee2 <botlish_fn_17+0xb9>
			2ede: R_X86_64_PLT32	rt_str_region_eq-0x4
    2ee2:	cmp    rax,0x6
    2ee6:	je     2f70 <botlish_fn_17+0x147>
    2eec:	mov    rdi,r12
    2eef:	mov    rax,QWORD PTR [rdi+0x10]
    2ef3:	mov    rsi,QWORD PTR [rax+0x70]
    2ef7:	mov    edx,0x1
    2efc:	mov    ecx,0x3
    2f01:	mov    r8,r13
    2f04:	call   2f09 <botlish_fn_17+0xe0>
			2f05: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f09:	cmp    rax,0x6
    2f0d:	je     2f66 <botlish_fn_17+0x13d>
    2f13:	mov    rdi,r12
    2f16:	mov    rax,QWORD PTR [rdi+0x10]
    2f1a:	mov    rsi,QWORD PTR [rax+0x50]
    2f1e:	mov    edx,0x1
    2f23:	mov    ecx,0x3
    2f28:	mov    r8,r13
    2f2b:	call   2f30 <botlish_fn_17+0x107>
			2f2c: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f30:	cmp    rax,0x6
    2f34:	je     2f5c <botlish_fn_17+0x133>
    2f3a:	mov    rdi,r12
    2f3d:	mov    rdx,QWORD PTR [rdi+0x10]
    2f41:	mov    rsi,QWORD PTR [rdx+0x78]
    2f45:	mov    edx,0x1
    2f4a:	mov    ecx,0x3
    2f4f:	mov    r8,r13
    2f52:	call   2f57 <botlish_fn_17+0x12e>
			2f53: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f57:	jmp    2f7f <botlish_fn_17+0x156>
    2f5c:	mov    eax,0x6
    2f61:	jmp    2f7f <botlish_fn_17+0x156>
    2f66:	mov    eax,0x6
    2f6b:	jmp    2f7f <botlish_fn_17+0x156>
    2f70:	mov    eax,0x6
    2f75:	jmp    2f7f <botlish_fn_17+0x156>
    2f7a:	mov    eax,0x6
    2f7f:	mov    rdi,r12
    2f82:	jmp    2f8f <botlish_fn_17+0x166>
    2f87:	mov    eax,0x6
    2f8c:	mov    rdi,r12
    2f8f:	mov    rdi,r12
    2f92:	mov    QWORD PTR [rdi],rbx
    2f95:	mov    rbx,QWORD PTR [rsp]
    2f99:	mov    r12,QWORD PTR [rsp+0x8]
    2f9e:	mov    r13,QWORD PTR [rsp+0x10]
    2fa3:	add    rsp,0x20
    2fa7:	mov    rsp,rbp
    2faa:	pop    rbp
    2fab:	ret
    2fac:	mov    r12,rdi
    2faf:	call   2fb4 <botlish_fn_17+0x18b>
			2fb0: R_X86_64_PLT32	rt_stack_overflow-0x4
    2fb4:	xor    rax,rax
    2fb7:	mov    rbx,QWORD PTR [rsp]
    2fbb:	mov    r12,QWORD PTR [rsp+0x8]
    2fc0:	mov    r13,QWORD PTR [rsp+0x10]
    2fc5:	add    rsp,0x20
    2fc9:	mov    rsp,rbp
    2fcc:	pop    rbp
    2fcd:	ret

0000000000002fce <botlish_entry_17: is_local_char<str>>:
    2fce:	push   rbp
    2fcf:	mov    rbp,rsp
    2fd2:	mov    rsi,QWORD PTR [rdx]
    2fd5:	call   2fda <botlish_entry_17+0xc>
			2fd6: R_X86_64_PLT32	botlish_fn_17-0x4 ; is_local_char<str>
    2fda:	mov    rsp,rbp
    2fdd:	pop    rbp
    2fde:	ret

0000000000002fdf <botlish_fn_18: is_label_char<str>>:
    2fdf:	push   rbp
    2fe0:	mov    rbp,rsp
    2fe3:	sub    rsp,0x20
    2fe7:	mov    QWORD PTR [rsp],rbx
    2feb:	mov    QWORD PTR [rsp+0x8],r12
    2ff0:	mov    QWORD PTR [rsp+0x10],r13
    2ff5:	mov    r13,rsi
    2ff8:	mov    rbx,QWORD PTR [rdi]
    2ffb:	mov    rax,QWORD PTR [rdi+0x8]
    2fff:	lea    rcx,[rbx+0x8]
    3003:	cmp    rcx,rax
    3006:	ja     309e <botlish_fn_18+0xbf>
    300c:	lea    rax,[rbx+0x8]
    3010:	mov    QWORD PTR [rdi],rax
    3013:	mov    r12,rdi
    3016:	mov    rsi,r13
    3019:	mov    rdi,r12
    301c:	call   3021 <botlish_fn_18+0x42>
			301d: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    3021:	test   rax,rax
    3024:	jne    304a <botlish_fn_18+0x6b>
    302a:	mov    rdi,r12
    302d:	mov    QWORD PTR [rdi],rbx
    3030:	xor    rax,rax
    3033:	mov    rbx,QWORD PTR [rsp]
    3037:	mov    r12,QWORD PTR [rsp+0x8]
    303c:	mov    r13,QWORD PTR [rsp+0x10]
    3041:	add    rsp,0x20
    3045:	mov    rsp,rbp
    3048:	pop    rbp
    3049:	ret
    304a:	cmp    rax,0x6
    304e:	je     3079 <botlish_fn_18+0x9a>
    3054:	mov    rdi,r12
    3057:	mov    rax,QWORD PTR [rdi+0x10]
    305b:	mov    rsi,QWORD PTR [rax+0x78]
    305f:	mov    edx,0x1
    3064:	mov    ecx,0x3
    3069:	mov    r8,r13
    306c:	call   3071 <botlish_fn_18+0x92>
			306d: R_X86_64_PLT32	rt_str_region_eq-0x4
    3071:	mov    rdi,r12
    3074:	jmp    3081 <botlish_fn_18+0xa2>
    3079:	mov    eax,0x6
    307e:	mov    rdi,r12
    3081:	mov    rdi,r12
    3084:	mov    QWORD PTR [rdi],rbx
    3087:	mov    rbx,QWORD PTR [rsp]
    308b:	mov    r12,QWORD PTR [rsp+0x8]
    3090:	mov    r13,QWORD PTR [rsp+0x10]
    3095:	add    rsp,0x20
    3099:	mov    rsp,rbp
    309c:	pop    rbp
    309d:	ret
    309e:	mov    r12,rdi
    30a1:	call   30a6 <botlish_fn_18+0xc7>
			30a2: R_X86_64_PLT32	rt_stack_overflow-0x4
    30a6:	xor    rax,rax
    30a9:	mov    rbx,QWORD PTR [rsp]
    30ad:	mov    r12,QWORD PTR [rsp+0x8]
    30b2:	mov    r13,QWORD PTR [rsp+0x10]
    30b7:	add    rsp,0x20
    30bb:	mov    rsp,rbp
    30be:	pop    rbp
    30bf:	ret

00000000000030c0 <botlish_entry_18: is_label_char<str>>:
    30c0:	push   rbp
    30c1:	mov    rbp,rsp
    30c4:	mov    rsi,QWORD PTR [rdx]
    30c7:	call   30cc <botlish_entry_18+0xc>
			30c8: R_X86_64_PLT32	botlish_fn_18-0x4 ; is_label_char<str>
    30cc:	mov    rsp,rbp
    30cf:	pop    rbp
    30d0:	ret
    30d1:	add    BYTE PTR [rax],al
    30d3:	add    BYTE PTR [rax],al
    30d5:	add    BYTE PTR [rax],al
	...

00000000000030d8 <botlish_fn_19: scan_local<generic>>:
    30d8:	push   rbp
    30d9:	mov    rbp,rsp
    30dc:	sub    rsp,0x20
    30e0:	mov    QWORD PTR [rsp],rbx
    30e4:	mov    QWORD PTR [rsp+0x8],r12
    30e9:	mov    QWORD PTR [rsp+0x10],r13
    30ee:	mov    QWORD PTR [rsp+0x18],r14
    30f3:	mov    r12,QWORD PTR [rdi]
    30f6:	mov    rax,QWORD PTR [rdi+0x8]
    30fa:	lea    rcx,[r12+0x18]
    30ff:	cmp    rcx,rax
    3102:	ja     32d6 <botlish_fn_19+0x1fe>
    3108:	lea    rax,[r12+0x18]
    310d:	mov    QWORD PTR [rdi],rax
    3110:	mov    r13,rdi
    3113:	mov    QWORD PTR [r12+0x10],0x0
    311c:	mov    QWORD PTR [r12],rdx
    3120:	mov    rbx,rsi
    3123:	mov    rsi,rdx
    3126:	mov    rax,QWORD PTR [rbx+0x20]
    312a:	mov    rdx,QWORD PTR [rax]
    312d:	mov    ecx,0x1
    3132:	test   rsi,0x1
    3139:	jne    3157 <botlish_fn_19+0x7f>
    313f:	xor    ecx,ecx
    3141:	test   rsi,0x7
    3148:	jne    3157 <botlish_fn_19+0x7f>
    314e:	movzx  rax,BYTE PTR [rsi]
    3152:	cmp    al,0x1
    3154:	sete   cl
    3157:	test   cl,cl
    3159:	jne    317d <botlish_fn_19+0xa5>
    315f:	mov    rdi,r13
    3162:	mov    rax,QWORD PTR [rdi+0x10]
    3166:	mov    rcx,QWORD PTR [rax+0x80]
    316d:	xor    rdx,rdx
    3170:	call   3175 <botlish_fn_19+0x9d>
			3171: R_X86_64_PLT32	rt_type_error-0x4
    3175:	mov    rdi,r13
    3178:	jmp    3214 <botlish_fn_19+0x13c>
    317d:	mov    rax,rsi
    3180:	and    rax,rdx
    3183:	mov    r14,rsi
    3186:	test   rax,0x1
    318c:	jne    31b2 <botlish_fn_19+0xda>
    3192:	mov    rsi,r14
    3195:	mov    rdi,r13
    3198:	call   319d <botlish_fn_19+0xc5>
			3199: R_X86_64_PLT32	rt_int_cmp-0x4
    319d:	mov    ecx,0x2
    31a2:	test   rax,rax
    31a5:	cmovge rcx,QWORD PTR [rip+0x153]        # 3300 <botlish_fn_19+0x228>
    31ad:	jmp    31c5 <botlish_fn_19+0xed>
    31b2:	mov    ecx,0x2
    31b7:	mov    rsi,r14
    31ba:	cmp    rsi,rdx
    31bd:	cmovge rcx,QWORD PTR [rip+0x13b]        # 3300 <botlish_fn_19+0x228>
    31c5:	cmp    rcx,0x6
    31c9:	je     32ae <botlish_fn_19+0x1d6>
    31cf:	mov    rsi,QWORD PTR [rbx+0x20]
    31d3:	mov    rsi,QWORD PTR [rsi+0x8]
    31d7:	mov    QWORD PTR [r12+0x8],rsi
    31dc:	mov    rdx,r14
    31df:	mov    rdi,r13
    31e2:	call   31e7 <botlish_fn_19+0x10f>
			31e3: R_X86_64_PLT32	botlish_fn_15-0x4 ; char_at<generic>
    31e7:	test   rax,rax
    31ea:	jne    31f8 <botlish_fn_19+0x120>
    31f0:	mov    rdi,r13
    31f3:	jmp    3214 <botlish_fn_19+0x13c>
    31f8:	mov    QWORD PTR [r12+0x8],rax
    31fd:	mov    rsi,rax
    3200:	mov    rdi,r13
    3203:	call   3208 <botlish_fn_19+0x130>
			3204: R_X86_64_PLT32	botlish_fn_17-0x4 ; is_local_char<str>
    3208:	test   rax,rax
    320b:	jne    3239 <botlish_fn_19+0x161>
    3211:	mov    rdi,r13
    3214:	mov    rdi,r13
    3217:	mov    QWORD PTR [rdi],r12
    321a:	xor    rax,rax
    321d:	mov    rbx,QWORD PTR [rsp]
    3221:	mov    r12,QWORD PTR [rsp+0x8]
    3226:	mov    r13,QWORD PTR [rsp+0x10]
    322b:	mov    r14,QWORD PTR [rsp+0x18]
    3230:	add    rsp,0x20
    3234:	mov    rsp,rbp
    3237:	pop    rbp
    3238:	ret
    3239:	cmp    rax,0x6
    323d:	je     324e <botlish_fn_19+0x176>
    3243:	mov    rax,r14
    3246:	mov    rdi,r13
    3249:	jmp    32b4 <botlish_fn_19+0x1dc>
    324e:	mov    QWORD PTR [r12+0x8],rbx
    3253:	mov    QWORD PTR [r12+0x10],0x3
    325c:	mov    rsi,r14
    325f:	test   rsi,0x1
    3266:	je     328c <botlish_fn_19+0x1b4>
    326c:	mov    rsi,r14
    326f:	mov    rcx,rsi
    3272:	add    rcx,0x2
    3276:	seto   al
    3279:	test   al,al
    327b:	jne    328c <botlish_fn_19+0x1b4>
    3281:	mov    rsi,rcx
    3284:	mov    r14,rcx
    3287:	jmp    32a2 <botlish_fn_19+0x1ca>
    328c:	mov    edx,0x3
    3291:	mov    rsi,r14
    3294:	mov    rdi,r13
    3297:	call   329c <botlish_fn_19+0x1c4>
			3298: R_X86_64_PLT32	rt_int_add-0x4
    329c:	mov    rsi,rax
    329f:	mov    r14,rax
    32a2:	mov    QWORD PTR [r12],rsi
    32a6:	mov    rsi,r14
    32a9:	jmp    3126 <botlish_fn_19+0x4e>
    32ae:	mov    rax,r14
    32b1:	mov    rdi,r13
    32b4:	mov    rdi,r13
    32b7:	mov    QWORD PTR [rdi],r12
    32ba:	mov    rbx,QWORD PTR [rsp]
    32be:	mov    r12,QWORD PTR [rsp+0x8]
    32c3:	mov    r13,QWORD PTR [rsp+0x10]
    32c8:	mov    r14,QWORD PTR [rsp+0x18]
    32cd:	add    rsp,0x20
    32d1:	mov    rsp,rbp
    32d4:	pop    rbp
    32d5:	ret
    32d6:	mov    r13,rdi
    32d9:	call   32de <botlish_fn_19+0x206>
			32da: R_X86_64_PLT32	rt_stack_overflow-0x4
    32de:	xor    rax,rax
    32e1:	mov    rbx,QWORD PTR [rsp]
    32e5:	mov    r12,QWORD PTR [rsp+0x8]
    32ea:	mov    r13,QWORD PTR [rsp+0x10]
    32ef:	mov    r14,QWORD PTR [rsp+0x18]
    32f4:	add    rsp,0x20
    32f8:	mov    rsp,rbp
    32fb:	pop    rbp
    32fc:	ret
    32fd:	add    BYTE PTR [rax],al
    32ff:	add    BYTE PTR [rsi],al
    3301:	add    BYTE PTR [rax],al
    3303:	add    BYTE PTR [rax],al
    3305:	add    BYTE PTR [rax],al
	...

0000000000003308 <botlish_entry_19: scan_local<generic>>:
    3308:	push   rbp
    3309:	mov    rbp,rsp
    330c:	mov    rdx,QWORD PTR [rdx]
    330f:	call   3314 <botlish_entry_19+0xc>
			3310: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_local<generic>
    3314:	mov    rsp,rbp
    3317:	pop    rbp
    3318:	ret
    3319:	add    BYTE PTR [rax],al
    331b:	add    BYTE PTR [rax],al
    331d:	add    BYTE PTR [rax],al
	...

0000000000003320 <botlish_fn_20: scan_label<generic>>:
    3320:	push   rbp
    3321:	mov    rbp,rsp
    3324:	sub    rsp,0x20
    3328:	mov    QWORD PTR [rsp],rbx
    332c:	mov    QWORD PTR [rsp+0x8],r12
    3331:	mov    QWORD PTR [rsp+0x10],r13
    3336:	mov    QWORD PTR [rsp+0x18],r14
    333b:	mov    r12,QWORD PTR [rdi]
    333e:	mov    rax,QWORD PTR [rdi+0x8]
    3342:	lea    rcx,[r12+0x18]
    3347:	cmp    rcx,rax
    334a:	ja     351e <botlish_fn_20+0x1fe>
    3350:	lea    rax,[r12+0x18]
    3355:	mov    QWORD PTR [rdi],rax
    3358:	mov    r13,rdi
    335b:	mov    QWORD PTR [r12+0x10],0x0
    3364:	mov    QWORD PTR [r12],rdx
    3368:	mov    rbx,rsi
    336b:	mov    rsi,rdx
    336e:	mov    rax,QWORD PTR [rbx+0x20]
    3372:	mov    rdx,QWORD PTR [rax]
    3375:	mov    ecx,0x1
    337a:	test   rsi,0x1
    3381:	jne    339f <botlish_fn_20+0x7f>
    3387:	xor    ecx,ecx
    3389:	test   rsi,0x7
    3390:	jne    339f <botlish_fn_20+0x7f>
    3396:	movzx  rax,BYTE PTR [rsi]
    339a:	cmp    al,0x1
    339c:	sete   cl
    339f:	test   cl,cl
    33a1:	jne    33c5 <botlish_fn_20+0xa5>
    33a7:	mov    rdi,r13
    33aa:	mov    rax,QWORD PTR [rdi+0x10]
    33ae:	mov    rcx,QWORD PTR [rax+0x80]
    33b5:	xor    rdx,rdx
    33b8:	call   33bd <botlish_fn_20+0x9d>
			33b9: R_X86_64_PLT32	rt_type_error-0x4
    33bd:	mov    rdi,r13
    33c0:	jmp    345c <botlish_fn_20+0x13c>
    33c5:	mov    rax,rsi
    33c8:	and    rax,rdx
    33cb:	mov    r14,rsi
    33ce:	test   rax,0x1
    33d4:	jne    33fa <botlish_fn_20+0xda>
    33da:	mov    rsi,r14
    33dd:	mov    rdi,r13
    33e0:	call   33e5 <botlish_fn_20+0xc5>
			33e1: R_X86_64_PLT32	rt_int_cmp-0x4
    33e5:	mov    ecx,0x2
    33ea:	test   rax,rax
    33ed:	cmovge rcx,QWORD PTR [rip+0x153]        # 3548 <botlish_fn_20+0x228>
    33f5:	jmp    340d <botlish_fn_20+0xed>
    33fa:	mov    ecx,0x2
    33ff:	mov    rsi,r14
    3402:	cmp    rsi,rdx
    3405:	cmovge rcx,QWORD PTR [rip+0x13b]        # 3548 <botlish_fn_20+0x228>
    340d:	cmp    rcx,0x6
    3411:	je     34f6 <botlish_fn_20+0x1d6>
    3417:	mov    rsi,QWORD PTR [rbx+0x20]
    341b:	mov    rsi,QWORD PTR [rsi+0x8]
    341f:	mov    QWORD PTR [r12+0x8],rsi
    3424:	mov    rdx,r14
    3427:	mov    rdi,r13
    342a:	call   342f <botlish_fn_20+0x10f>
			342b: R_X86_64_PLT32	botlish_fn_15-0x4 ; char_at<generic>
    342f:	test   rax,rax
    3432:	jne    3440 <botlish_fn_20+0x120>
    3438:	mov    rdi,r13
    343b:	jmp    345c <botlish_fn_20+0x13c>
    3440:	mov    QWORD PTR [r12+0x8],rax
    3445:	mov    rsi,rax
    3448:	mov    rdi,r13
    344b:	call   3450 <botlish_fn_20+0x130>
			344c: R_X86_64_PLT32	botlish_fn_18-0x4 ; is_label_char<str>
    3450:	test   rax,rax
    3453:	jne    3481 <botlish_fn_20+0x161>
    3459:	mov    rdi,r13
    345c:	mov    rdi,r13
    345f:	mov    QWORD PTR [rdi],r12
    3462:	xor    rax,rax
    3465:	mov    rbx,QWORD PTR [rsp]
    3469:	mov    r12,QWORD PTR [rsp+0x8]
    346e:	mov    r13,QWORD PTR [rsp+0x10]
    3473:	mov    r14,QWORD PTR [rsp+0x18]
    3478:	add    rsp,0x20
    347c:	mov    rsp,rbp
    347f:	pop    rbp
    3480:	ret
    3481:	cmp    rax,0x6
    3485:	je     3496 <botlish_fn_20+0x176>
    348b:	mov    rax,r14
    348e:	mov    rdi,r13
    3491:	jmp    34fc <botlish_fn_20+0x1dc>
    3496:	mov    QWORD PTR [r12+0x8],rbx
    349b:	mov    QWORD PTR [r12+0x10],0x3
    34a4:	mov    rsi,r14
    34a7:	test   rsi,0x1
    34ae:	je     34d4 <botlish_fn_20+0x1b4>
    34b4:	mov    rsi,r14
    34b7:	mov    rcx,rsi
    34ba:	add    rcx,0x2
    34be:	seto   al
    34c1:	test   al,al
    34c3:	jne    34d4 <botlish_fn_20+0x1b4>
    34c9:	mov    rsi,rcx
    34cc:	mov    r14,rcx
    34cf:	jmp    34ea <botlish_fn_20+0x1ca>
    34d4:	mov    edx,0x3
    34d9:	mov    rsi,r14
    34dc:	mov    rdi,r13
    34df:	call   34e4 <botlish_fn_20+0x1c4>
			34e0: R_X86_64_PLT32	rt_int_add-0x4
    34e4:	mov    rsi,rax
    34e7:	mov    r14,rax
    34ea:	mov    QWORD PTR [r12],rsi
    34ee:	mov    rsi,r14
    34f1:	jmp    336e <botlish_fn_20+0x4e>
    34f6:	mov    rax,r14
    34f9:	mov    rdi,r13
    34fc:	mov    rdi,r13
    34ff:	mov    QWORD PTR [rdi],r12
    3502:	mov    rbx,QWORD PTR [rsp]
    3506:	mov    r12,QWORD PTR [rsp+0x8]
    350b:	mov    r13,QWORD PTR [rsp+0x10]
    3510:	mov    r14,QWORD PTR [rsp+0x18]
    3515:	add    rsp,0x20
    3519:	mov    rsp,rbp
    351c:	pop    rbp
    351d:	ret
    351e:	mov    r13,rdi
    3521:	call   3526 <botlish_fn_20+0x206>
			3522: R_X86_64_PLT32	rt_stack_overflow-0x4
    3526:	xor    rax,rax
    3529:	mov    rbx,QWORD PTR [rsp]
    352d:	mov    r12,QWORD PTR [rsp+0x8]
    3532:	mov    r13,QWORD PTR [rsp+0x10]
    3537:	mov    r14,QWORD PTR [rsp+0x18]
    353c:	add    rsp,0x20
    3540:	mov    rsp,rbp
    3543:	pop    rbp
    3544:	ret
    3545:	add    BYTE PTR [rax],al
    3547:	add    BYTE PTR [rsi],al
    3549:	add    BYTE PTR [rax],al
    354b:	add    BYTE PTR [rax],al
    354d:	add    BYTE PTR [rax],al
	...

0000000000003550 <botlish_entry_20: scan_label<generic>>:
    3550:	push   rbp
    3551:	mov    rbp,rsp
    3554:	mov    rdx,QWORD PTR [rdx]
    3557:	call   355c <botlish_entry_20+0xc>
			3558: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_label<generic>
    355c:	mov    rsp,rbp
    355f:	pop    rbp
    3560:	ret
    3561:	add    BYTE PTR [rax],al
    3563:	add    BYTE PTR [rax],al
    3565:	add    BYTE PTR [rax],al
	...

0000000000003568 <botlish_fn_21: scan_alpha<generic>>:
    3568:	push   rbp
    3569:	mov    rbp,rsp
    356c:	sub    rsp,0x20
    3570:	mov    QWORD PTR [rsp],rbx
    3574:	mov    QWORD PTR [rsp+0x8],r12
    3579:	mov    QWORD PTR [rsp+0x10],r13
    357e:	mov    QWORD PTR [rsp+0x18],r14
    3583:	mov    r12,QWORD PTR [rdi]
    3586:	mov    rax,QWORD PTR [rdi+0x8]
    358a:	lea    rcx,[r12+0x18]
    358f:	cmp    rcx,rax
    3592:	ja     3761 <botlish_fn_21+0x1f9>
    3598:	lea    rax,[r12+0x18]
    359d:	mov    QWORD PTR [rdi],rax
    35a0:	mov    r13,rdi
    35a3:	mov    QWORD PTR [r12+0x10],0x0
    35ac:	mov    QWORD PTR [r12],rdx
    35b0:	mov    rbx,rsi
    35b3:	mov    rsi,rdx
    35b6:	mov    rax,QWORD PTR [rbx+0x20]
    35ba:	mov    rdx,QWORD PTR [rax]
    35bd:	mov    ecx,0x1
    35c2:	test   rsi,0x1
    35c9:	jne    35e7 <botlish_fn_21+0x7f>
    35cf:	xor    ecx,ecx
    35d1:	test   rsi,0x7
    35d8:	jne    35e7 <botlish_fn_21+0x7f>
    35de:	movzx  rax,BYTE PTR [rsi]
    35e2:	cmp    al,0x1
    35e4:	sete   cl
    35e7:	test   cl,cl
    35e9:	jne    360d <botlish_fn_21+0xa5>
    35ef:	mov    rdi,r13
    35f2:	mov    rax,QWORD PTR [rdi+0x10]
    35f6:	mov    rcx,QWORD PTR [rax+0x80]
    35fd:	xor    rdx,rdx
    3600:	call   3605 <botlish_fn_21+0x9d>
			3601: R_X86_64_PLT32	rt_type_error-0x4
    3605:	mov    rdi,r13
    3608:	jmp    369f <botlish_fn_21+0x137>
    360d:	mov    rax,rsi
    3610:	and    rax,rdx
    3613:	mov    r14,rsi
    3616:	test   rax,0x1
    361c:	jne    3642 <botlish_fn_21+0xda>
    3622:	mov    rsi,r14
    3625:	mov    rdi,r13
    3628:	call   362d <botlish_fn_21+0xc5>
			3629: R_X86_64_PLT32	rt_int_cmp-0x4
    362d:	mov    ecx,0x2
    3632:	test   rax,rax
    3635:	cmovge rcx,QWORD PTR [rip+0x14b]        # 3788 <botlish_fn_21+0x220>
    363d:	jmp    3655 <botlish_fn_21+0xed>
    3642:	mov    ecx,0x2
    3647:	mov    rsi,r14
    364a:	cmp    rsi,rdx
    364d:	cmovge rcx,QWORD PTR [rip+0x133]        # 3788 <botlish_fn_21+0x220>
    3655:	cmp    rcx,0x6
    3659:	je     3739 <botlish_fn_21+0x1d1>
    365f:	mov    rsi,QWORD PTR [rbx+0x20]
    3663:	mov    rsi,QWORD PTR [rsi+0x8]
    3667:	mov    QWORD PTR [r12+0x8],rsi
    366c:	mov    rdx,r14
    366f:	mov    rdi,r13
    3672:	call   3677 <botlish_fn_21+0x10f>
			3673: R_X86_64_PLT32	botlish_fn_15-0x4 ; char_at<generic>
    3677:	test   rax,rax
    367a:	mov    rsi,rax
    367d:	jne    368b <botlish_fn_21+0x123>
    3683:	mov    rdi,r13
    3686:	jmp    369f <botlish_fn_21+0x137>
    368b:	mov    rdi,r13
    368e:	call   3693 <botlish_fn_21+0x12b>
			368f: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    3693:	test   rax,rax
    3696:	jne    36c4 <botlish_fn_21+0x15c>
    369c:	mov    rdi,r13
    369f:	mov    rdi,r13
    36a2:	mov    QWORD PTR [rdi],r12
    36a5:	xor    rax,rax
    36a8:	mov    rbx,QWORD PTR [rsp]
    36ac:	mov    r12,QWORD PTR [rsp+0x8]
    36b1:	mov    r13,QWORD PTR [rsp+0x10]
    36b6:	mov    r14,QWORD PTR [rsp+0x18]
    36bb:	add    rsp,0x20
    36bf:	mov    rsp,rbp
    36c2:	pop    rbp
    36c3:	ret
    36c4:	cmp    rax,0x6
    36c8:	je     36d9 <botlish_fn_21+0x171>
    36ce:	mov    rax,r14
    36d1:	mov    rdi,r13
    36d4:	jmp    373f <botlish_fn_21+0x1d7>
    36d9:	mov    QWORD PTR [r12+0x8],rbx
    36de:	mov    QWORD PTR [r12+0x10],0x3
    36e7:	mov    rsi,r14
    36ea:	test   rsi,0x1
    36f1:	je     3717 <botlish_fn_21+0x1af>
    36f7:	mov    rsi,r14
    36fa:	mov    rcx,rsi
    36fd:	add    rcx,0x2
    3701:	seto   al
    3704:	test   al,al
    3706:	jne    3717 <botlish_fn_21+0x1af>
    370c:	mov    rsi,rcx
    370f:	mov    r14,rcx
    3712:	jmp    372d <botlish_fn_21+0x1c5>
    3717:	mov    edx,0x3
    371c:	mov    rsi,r14
    371f:	mov    rdi,r13
    3722:	call   3727 <botlish_fn_21+0x1bf>
			3723: R_X86_64_PLT32	rt_int_add-0x4
    3727:	mov    rsi,rax
    372a:	mov    r14,rax
    372d:	mov    QWORD PTR [r12],rsi
    3731:	mov    rsi,r14
    3734:	jmp    35b6 <botlish_fn_21+0x4e>
    3739:	mov    rax,r14
    373c:	mov    rdi,r13
    373f:	mov    rdi,r13
    3742:	mov    QWORD PTR [rdi],r12
    3745:	mov    rbx,QWORD PTR [rsp]
    3749:	mov    r12,QWORD PTR [rsp+0x8]
    374e:	mov    r13,QWORD PTR [rsp+0x10]
    3753:	mov    r14,QWORD PTR [rsp+0x18]
    3758:	add    rsp,0x20
    375c:	mov    rsp,rbp
    375f:	pop    rbp
    3760:	ret
    3761:	mov    r13,rdi
    3764:	call   3769 <botlish_fn_21+0x201>
			3765: R_X86_64_PLT32	rt_stack_overflow-0x4
    3769:	xor    rax,rax
    376c:	mov    rbx,QWORD PTR [rsp]
    3770:	mov    r12,QWORD PTR [rsp+0x8]
    3775:	mov    r13,QWORD PTR [rsp+0x10]
    377a:	mov    r14,QWORD PTR [rsp+0x18]
    377f:	add    rsp,0x20
    3783:	mov    rsp,rbp
    3786:	pop    rbp
    3787:	ret
    3788:	(bad)
    3789:	add    BYTE PTR [rax],al
    378b:	add    BYTE PTR [rax],al
    378d:	add    BYTE PTR [rax],al
	...

0000000000003790 <botlish_entry_21: scan_alpha<generic>>:
    3790:	push   rbp
    3791:	mov    rbp,rsp
    3794:	mov    rdx,QWORD PTR [rdx]
    3797:	call   379c <botlish_entry_21+0xc>
			3798: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_alpha<generic>
    379c:	mov    rsp,rbp
    379f:	pop    rbp
    37a0:	ret
    37a1:	add    BYTE PTR [rax],al
    37a3:	add    BYTE PTR [rax],al
    37a5:	add    BYTE PTR [rax],al
	...

00000000000037a8 <botlish_fn_22: tld_ok<generic>>:
    37a8:	push   rbp
    37a9:	mov    rbp,rsp
    37ac:	sub    rsp,0x30
    37b0:	mov    QWORD PTR [rsp],rbx
    37b4:	mov    QWORD PTR [rsp+0x8],r12
    37b9:	mov    QWORD PTR [rsp+0x10],r13
    37be:	mov    QWORD PTR [rsp+0x18],r14
    37c3:	mov    QWORD PTR [rsp+0x20],r15
    37c8:	mov    rbx,QWORD PTR [rdi]
    37cb:	mov    rax,QWORD PTR [rdi+0x8]
    37cf:	lea    rcx,[rbx+0x10]
    37d3:	cmp    rcx,rax
    37d6:	ja     39d8 <botlish_fn_22+0x230>
    37dc:	lea    rax,[rbx+0x10]
    37e0:	mov    QWORD PTR [rdi],rax
    37e3:	mov    r13,rdi
    37e6:	mov    QWORD PTR [rbx],rdx
    37e9:	mov    r8,rdx
    37ec:	mov    rax,QWORD PTR [rsi+0x20]
    37f0:	mov    r15,rsi
    37f3:	mov    rsi,QWORD PTR [rax]
    37f6:	mov    QWORD PTR [rbx+0x8],rsi
    37fa:	mov    r12,r8
    37fd:	mov    rdx,r12
    3800:	mov    rdi,r13
    3803:	call   3808 <botlish_fn_22+0x60>
			3804: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_alpha<generic>
    3808:	mov    rcx,rax
    380b:	mov    r14,rax
    380e:	test   rax,rcx
    3811:	jne    381f <botlish_fn_22+0x77>
    3817:	mov    rdi,r13
    381a:	jmp    38f4 <botlish_fn_22+0x14c>
    381f:	mov    rax,r14
    3822:	mov    QWORD PTR [rbx+0x8],rax
    3826:	mov    rsi,r15
    3829:	mov    rax,QWORD PTR [rsi+0x20]
    382d:	mov    rdx,QWORD PTR [rax+0x8]
    3831:	mov    rax,r14
    3834:	and    rax,rdx
    3837:	test   rax,0x1
    383d:	jne    3866 <botlish_fn_22+0xbe>
    3843:	mov    rsi,r14
    3846:	mov    rdi,r13
    3849:	call   384e <botlish_fn_22+0xa6>
			384a: R_X86_64_PLT32	rt_int_cmp-0x4
    384e:	mov    ecx,0x2
    3853:	test   rax,rax
    3856:	cmove  rcx,QWORD PTR [rip+0x1aa]        # 3a08 <botlish_fn_22+0x260>
    385e:	mov    rax,r14
    3861:	jmp    3879 <botlish_fn_22+0xd1>
    3866:	mov    ecx,0x2
    386b:	mov    rax,r14
    386e:	cmp    rax,rdx
    3871:	cmove  rcx,QWORD PTR [rip+0x18f]        # 3a08 <botlish_fn_22+0x260>
    3879:	cmp    rcx,0x6
    387d:	je     3893 <botlish_fn_22+0xeb>
    3883:	mov    ecx,0x2
    3888:	mov    rax,rcx
    388b:	mov    rdi,r13
    388e:	jmp    39b1 <botlish_fn_22+0x209>
    3893:	mov    ecx,0x1
    3898:	test   r12,0x1
    389f:	je     38ad <botlish_fn_22+0x105>
    38a5:	mov    r8,r12
    38a8:	jmp    38d3 <botlish_fn_22+0x12b>
    38ad:	xor    ecx,ecx
    38af:	test   r12,0x7
    38b6:	je     38c4 <botlish_fn_22+0x11c>
    38bc:	mov    r8,r12
    38bf:	jmp    38d3 <botlish_fn_22+0x12b>
    38c4:	movzx  rcx,BYTE PTR [r12]
    38c9:	mov    r8,r12
    38cc:	rex cmp cl,0x1
    38d0:	sete   cl
    38d3:	test   cl,cl
    38d5:	jne    391e <botlish_fn_22+0x176>
    38db:	mov    rdi,r13
    38de:	mov    rax,QWORD PTR [rdi+0x10]
    38e2:	mov    rcx,QWORD PTR [rax+0x78]
    38e6:	xor    rdx,rdx
    38e9:	mov    rsi,r8
    38ec:	call   38f1 <botlish_fn_22+0x149>
			38ed: R_X86_64_PLT32	rt_type_error-0x4
    38f1:	mov    rdi,r13
    38f4:	mov    rdi,r13
    38f7:	mov    QWORD PTR [rdi],rbx
    38fa:	xor    rax,rax
    38fd:	mov    rbx,QWORD PTR [rsp]
    3901:	mov    r12,QWORD PTR [rsp+0x8]
    3906:	mov    r13,QWORD PTR [rsp+0x10]
    390b:	mov    r14,QWORD PTR [rsp+0x18]
    3910:	mov    r15,QWORD PTR [rsp+0x20]
    3915:	add    rsp,0x30
    3919:	mov    rsp,rbp
    391c:	pop    rbp
    391d:	ret
    391e:	mov    r12,r8
    3921:	mov    rcx,rax
    3924:	and    rcx,r12
    3927:	test   rcx,0x1
    392e:	jne    393f <botlish_fn_22+0x197>
    3934:	mov    rdx,r8
    3937:	mov    rsi,rax
    393a:	jmp    3960 <botlish_fn_22+0x1b8>
    393f:	mov    r12,r8
    3942:	mov    rcx,rax
    3945:	sub    rcx,r12
    3948:	mov    r14,rax
    394b:	seto   al
    394e:	lea    rsi,[rcx+0x1]
    3952:	test   al,al
    3954:	je     396b <botlish_fn_22+0x1c3>
    395a:	mov    rdx,r8
    395d:	mov    rsi,r14
    3960:	mov    rdi,r13
    3963:	call   3968 <botlish_fn_22+0x1c0>
			3964: R_X86_64_PLT32	rt_int_sub-0x4
    3968:	mov    rsi,rax
    396b:	test   rsi,0x1
    3972:	jne    399d <botlish_fn_22+0x1f5>
    3978:	mov    edx,0x5
    397d:	mov    rdi,r13
    3980:	call   3985 <botlish_fn_22+0x1dd>
			3981: R_X86_64_PLT32	rt_int_cmp-0x4
    3985:	mov    ecx,0x2
    398a:	test   rax,rax
    398d:	mov    rax,rcx
    3990:	cmovge rax,QWORD PTR [rip+0x70]        # 3a08 <botlish_fn_22+0x260>
    3998:	jmp    39ae <botlish_fn_22+0x206>
    399d:	mov    eax,0x2
    39a2:	cmp    rsi,0x5
    39a6:	cmovge rax,QWORD PTR [rip+0x5a]        # 3a08 <botlish_fn_22+0x260>
    39ae:	mov    rdi,r13
    39b1:	mov    rdi,r13
    39b4:	mov    QWORD PTR [rdi],rbx
    39b7:	mov    rbx,QWORD PTR [rsp]
    39bb:	mov    r12,QWORD PTR [rsp+0x8]
    39c0:	mov    r13,QWORD PTR [rsp+0x10]
    39c5:	mov    r14,QWORD PTR [rsp+0x18]
    39ca:	mov    r15,QWORD PTR [rsp+0x20]
    39cf:	add    rsp,0x30
    39d3:	mov    rsp,rbp
    39d6:	pop    rbp
    39d7:	ret
    39d8:	mov    r13,rdi
    39db:	call   39e0 <botlish_fn_22+0x238>
			39dc: R_X86_64_PLT32	rt_stack_overflow-0x4
    39e0:	xor    rax,rax
    39e3:	mov    rbx,QWORD PTR [rsp]
    39e7:	mov    r12,QWORD PTR [rsp+0x8]
    39ec:	mov    r13,QWORD PTR [rsp+0x10]
    39f1:	mov    r14,QWORD PTR [rsp+0x18]
    39f6:	mov    r15,QWORD PTR [rsp+0x20]
    39fb:	add    rsp,0x30
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

0000000000003a10 <botlish_entry_22: tld_ok<generic>>:
    3a10:	push   rbp
    3a11:	mov    rbp,rsp
    3a14:	mov    rdx,QWORD PTR [rdx]
    3a17:	call   3a1c <botlish_entry_22+0xc>
			3a18: R_X86_64_PLT32	botlish_fn_22-0x4 ; tld_ok<generic>
    3a1c:	mov    rsp,rbp
    3a1f:	pop    rbp
    3a20:	ret
    3a21:	add    BYTE PTR [rax],al
    3a23:	add    BYTE PTR [rax],al
    3a25:	add    BYTE PTR [rax],al
	...

0000000000003a28 <botlish_fn_23: domain_loop<generic>>:
    3a28:	push   rbp
    3a29:	mov    rbp,rsp
    3a2c:	sub    rsp,0x50
    3a30:	mov    QWORD PTR [rsp+0x20],rbx
    3a35:	mov    QWORD PTR [rsp+0x28],r12
    3a3a:	mov    QWORD PTR [rsp+0x30],r13
    3a3f:	mov    QWORD PTR [rsp+0x38],r14
    3a44:	mov    QWORD PTR [rsp+0x40],r15
    3a49:	mov    r13,QWORD PTR [rdi]
    3a4c:	mov    rax,QWORD PTR [rdi+0x8]
    3a50:	lea    rcx,[r13+0x10]
    3a54:	cmp    rcx,rax
    3a57:	ja     3cc3 <botlish_fn_23+0x29b>
    3a5d:	lea    rax,[r13+0x10]
    3a61:	mov    QWORD PTR [rdi],rax
    3a64:	mov    r15,rdi
    3a67:	mov    QWORD PTR [r13+0x0],rdx
    3a6b:	mov    QWORD PTR [rsp+0x10],rdx
    3a70:	lea    rbx,[rsp]
    3a74:	mov    r12,rsi
    3a77:	mov    rax,QWORD PTR [r12+0x20]
    3a7c:	mov    rsi,QWORD PTR [rax]
    3a7f:	mov    QWORD PTR [r13+0x8],rsi
    3a83:	mov    rdx,QWORD PTR [rsp+0x10]
    3a88:	mov    rdi,r15
    3a8b:	call   3a90 <botlish_fn_23+0x68>
			3a8c: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_label<generic>
    3a90:	mov    rcx,rax
    3a93:	mov    r14,rax
    3a96:	test   rax,rcx
    3a99:	jne    3aa7 <botlish_fn_23+0x7f>
    3a9f:	mov    rdi,r15
    3aa2:	jmp    3c31 <botlish_fn_23+0x209>
    3aa7:	mov    rax,r14
    3aaa:	mov    QWORD PTR [r13+0x0],rax
    3aae:	mov    rdx,QWORD PTR [rsp+0x10]
    3ab3:	mov    rsi,rax
    3ab6:	and    rsi,rdx
    3ab9:	test   rsi,0x1
    3ac0:	jne    3ae7 <botlish_fn_23+0xbf>
    3ac6:	mov    rdx,QWORD PTR [rsp+0x10]
    3acb:	mov    rsi,r14
    3ace:	mov    rdi,r15
    3ad1:	call   3ad6 <botlish_fn_23+0xae>
			3ad2: R_X86_64_PLT32	rt_value_eq-0x4
    3ad6:	test   rax,rax
    3ad9:	jne    3afc <botlish_fn_23+0xd4>
    3adf:	mov    rdi,r15
    3ae2:	jmp    3c31 <botlish_fn_23+0x209>
    3ae7:	mov    eax,0x2
    3aec:	mov    rdx,QWORD PTR [rsp+0x10]
    3af1:	cmp    r14,rdx
    3af4:	cmove  rax,QWORD PTR [rip+0x1f4]        # 3cf0 <botlish_fn_23+0x2c8>
    3afc:	cmp    rax,0x6
    3b00:	je     3c91 <botlish_fn_23+0x269>
    3b06:	mov    rax,QWORD PTR [r12+0x20]
    3b0b:	mov    rdx,QWORD PTR [rax+0x8]
    3b0f:	mov    rax,r14
    3b12:	and    rax,rdx
    3b15:	test   rax,0x1
    3b1b:	jne    3b41 <botlish_fn_23+0x119>
    3b21:	mov    rsi,r14
    3b24:	mov    rdi,r15
    3b27:	call   3b2c <botlish_fn_23+0x104>
			3b28: R_X86_64_PLT32	rt_int_cmp-0x4
    3b2c:	mov    ecx,0x2
    3b31:	test   rax,rax
    3b34:	cmovge rcx,QWORD PTR [rip+0x1b4]        # 3cf0 <botlish_fn_23+0x2c8>
    3b3c:	jmp    3b51 <botlish_fn_23+0x129>
    3b41:	mov    ecx,0x2
    3b46:	cmp    r14,rdx
    3b49:	cmovge rcx,QWORD PTR [rip+0x19f]        # 3cf0 <botlish_fn_23+0x2c8>
    3b51:	cmp    rcx,0x6
    3b55:	je     3c82 <botlish_fn_23+0x25a>
    3b5b:	mov    rax,QWORD PTR [r12+0x20]
    3b60:	mov    rsi,QWORD PTR [rax+0x10]
    3b64:	mov    QWORD PTR [r13+0x8],rsi
    3b68:	mov    rcx,rbx
    3b6b:	mov    rdx,r14
    3b6e:	mov    rdi,r15
    3b71:	call   3b76 <botlish_fn_23+0x14e>
			3b72: R_X86_64_PLT32	botlish_fn_16-0x4 ; char_at<generic>
    3b76:	test   rax,rax
    3b79:	mov    rsi,rax
    3b7c:	jne    3b8a <botlish_fn_23+0x162>
    3b82:	mov    rdi,r15
    3b85:	jmp    3c31 <botlish_fn_23+0x209>
    3b8a:	mov    rdx,QWORD PTR [rsp]
    3b8e:	mov    rcx,QWORD PTR [rsp+0x8]
    3b93:	mov    rdi,r15
    3b96:	mov    rax,QWORD PTR [rdi+0x10]
    3b9a:	mov    r8,QWORD PTR [rax+0x60]
    3b9e:	call   3ba3 <botlish_fn_23+0x17b>
			3b9f: R_X86_64_PLT32	rt_str_region_eq-0x4
    3ba3:	cmp    rax,0x6
    3ba7:	je     3bb9 <botlish_fn_23+0x191>
    3bad:	mov    rax,0xffffffffffffffff
    3bb4:	jmp    3c89 <botlish_fn_23+0x261>
    3bb9:	mov    QWORD PTR [r13+0x8],0x3
    3bc1:	test   r14,0x1
    3bc8:	je     3bef <botlish_fn_23+0x1c7>
    3bce:	mov    rdx,r14
    3bd1:	add    rdx,0x2
    3bd5:	mov    QWORD PTR [rsp+0x10],rdx
    3bda:	seto   al
    3bdd:	test   al,al
    3bdf:	jne    3bef <botlish_fn_23+0x1c7>
    3be5:	mov    rdx,QWORD PTR [rsp+0x10]
    3bea:	jmp    3c07 <botlish_fn_23+0x1df>
    3bef:	mov    edx,0x3
    3bf4:	mov    rsi,r14
    3bf7:	mov    rdi,r15
    3bfa:	call   3bff <botlish_fn_23+0x1d7>
			3bfb: R_X86_64_PLT32	rt_int_add-0x4
    3bff:	mov    rdx,rax
    3c02:	mov    QWORD PTR [rsp+0x10],rax
    3c07:	mov    QWORD PTR [r13+0x0],rdx
    3c0b:	mov    rax,QWORD PTR [r12+0x20]
    3c10:	mov    rsi,QWORD PTR [rax+0x18]
    3c14:	mov    QWORD PTR [r13+0x8],rsi
    3c18:	mov    rdx,QWORD PTR [rsp+0x10]
    3c1d:	mov    rdi,r15
    3c20:	call   3c25 <botlish_fn_23+0x1fd>
			3c21: R_X86_64_PLT32	botlish_fn_22-0x4 ; tld_ok<generic>
    3c25:	test   rax,rax
    3c28:	jne    3c5c <botlish_fn_23+0x234>
    3c2e:	mov    rdi,r15
    3c31:	mov    rdi,r15
    3c34:	mov    QWORD PTR [rdi],r13
    3c37:	xor    rax,rax
    3c3a:	mov    rbx,QWORD PTR [rsp+0x20]
    3c3f:	mov    r12,QWORD PTR [rsp+0x28]
    3c44:	mov    r13,QWORD PTR [rsp+0x30]
    3c49:	mov    r14,QWORD PTR [rsp+0x38]
    3c4e:	mov    r15,QWORD PTR [rsp+0x40]
    3c53:	add    rsp,0x50
    3c57:	mov    rsp,rbp
    3c5a:	pop    rbp
    3c5b:	ret
    3c5c:	cmp    rax,0x6
    3c60:	je     3c74 <botlish_fn_23+0x24c>
    3c66:	mov    rdx,QWORD PTR [rsp+0x10]
    3c6b:	mov    QWORD PTR [r13+0x0],rdx
    3c6f:	jmp    3a77 <botlish_fn_23+0x4f>
    3c74:	mov    rax,QWORD PTR [r12+0x20]
    3c79:	mov    rax,QWORD PTR [rax+0x8]
    3c7d:	jmp    3c89 <botlish_fn_23+0x261>
    3c82:	mov    rax,0xffffffffffffffff
    3c89:	mov    rdi,r15
    3c8c:	jmp    3c9b <botlish_fn_23+0x273>
    3c91:	mov    rax,0xffffffffffffffff
    3c98:	mov    rdi,r15
    3c9b:	mov    rdi,r15
    3c9e:	mov    QWORD PTR [rdi],r13
    3ca1:	mov    rbx,QWORD PTR [rsp+0x20]
    3ca6:	mov    r12,QWORD PTR [rsp+0x28]
    3cab:	mov    r13,QWORD PTR [rsp+0x30]
    3cb0:	mov    r14,QWORD PTR [rsp+0x38]
    3cb5:	mov    r15,QWORD PTR [rsp+0x40]
    3cba:	add    rsp,0x50
    3cbe:	mov    rsp,rbp
    3cc1:	pop    rbp
    3cc2:	ret
    3cc3:	mov    r15,rdi
    3cc6:	call   3ccb <botlish_fn_23+0x2a3>
			3cc7: R_X86_64_PLT32	rt_stack_overflow-0x4
    3ccb:	xor    rax,rax
    3cce:	mov    rbx,QWORD PTR [rsp+0x20]
    3cd3:	mov    r12,QWORD PTR [rsp+0x28]
    3cd8:	mov    r13,QWORD PTR [rsp+0x30]
    3cdd:	mov    r14,QWORD PTR [rsp+0x38]
    3ce2:	mov    r15,QWORD PTR [rsp+0x40]
    3ce7:	add    rsp,0x50
    3ceb:	mov    rsp,rbp
    3cee:	pop    rbp
    3cef:	ret
    3cf0:	(bad)
    3cf1:	add    BYTE PTR [rax],al
    3cf3:	add    BYTE PTR [rax],al
    3cf5:	add    BYTE PTR [rax],al
	...

0000000000003cf8 <botlish_entry_23: domain_loop<generic>>:
    3cf8:	push   rbp
    3cf9:	mov    rbp,rsp
    3cfc:	mov    rdx,QWORD PTR [rdx]
    3cff:	call   3d04 <botlish_entry_23+0xc>
			3d00: R_X86_64_PLT32	botlish_fn_23-0x4 ; domain_loop<generic>
    3d04:	mov    rsp,rbp
    3d07:	pop    rbp
    3d08:	ret

0000000000003d09 <botlish_fn_24: <str>>:
    3d09:	push   rbp
    3d0a:	mov    rbp,rsp
    3d0d:	sub    rsp,0x110
    3d14:	mov    QWORD PTR [rsp+0xe0],rbx
    3d1c:	mov    QWORD PTR [rsp+0xe8],r12
    3d24:	mov    QWORD PTR [rsp+0xf0],r13
    3d2c:	mov    QWORD PTR [rsp+0xf8],r14
    3d34:	mov    QWORD PTR [rsp+0x100],r15
    3d3c:	mov    r15,QWORD PTR [rdi]
    3d3f:	mov    r8,QWORD PTR [rdi+0x8]
    3d43:	lea    r9,[r15+0x88]
    3d4a:	cmp    r9,r8
    3d4d:	ja     40bb <botlish_fn_24+0x3b2>
    3d53:	lea    r8,[r15+0x88]
    3d5a:	mov    QWORD PTR [rdi],r8
    3d5d:	mov    QWORD PTR [r15],rsi
    3d60:	mov    QWORD PTR [rsp+0xa8],rsi
    3d68:	mov    r8,QWORD PTR [rdi+0x10]
    3d6c:	mov    r9,QWORD PTR [r8+0x88]
    3d73:	mov    QWORD PTR [r15+0x8],r9
    3d77:	mov    QWORD PTR [rsp+0xd0],r9
    3d7f:	mov    r9,QWORD PTR [rdi+0x10]
    3d83:	mov    r10,QWORD PTR [r9+0x90]
    3d8a:	mov    QWORD PTR [r15+0x10],r10
    3d8e:	mov    QWORD PTR [rsp+0xc8],r10
    3d96:	mov    r10,QWORD PTR [rdi+0x10]
    3d9a:	mov    r11,QWORD PTR [r10+0x98]
    3da1:	mov    QWORD PTR [r15+0x18],r11
    3da5:	mov    QWORD PTR [rsp+0xc0],r11
    3dad:	mov    r11,QWORD PTR [rdi+0x10]
    3db1:	mov    rcx,QWORD PTR [r11+0xa0]
    3db8:	mov    QWORD PTR [r15+0x20],rcx
    3dbc:	mov    QWORD PTR [rsp+0xb8],rcx
    3dc4:	mov    rax,QWORD PTR [rdi+0x10]
    3dc8:	mov    r11,QWORD PTR [rax+0xa8]
    3dcf:	mov    QWORD PTR [r15+0x28],r11
    3dd3:	mov    QWORD PTR [rsp+0xb0],r11
    3ddb:	mov    rax,QWORD PTR [rdi+0x10]
    3ddf:	mov    r11,QWORD PTR [rax+0xb0]
    3de6:	mov    QWORD PTR [r15+0x30],r11
    3dea:	mov    rax,QWORD PTR [rdi+0x10]
    3dee:	mov    rsi,QWORD PTR [rax+0xb8]
    3df5:	mov    QWORD PTR [r15+0x38],rsi
    3df9:	mov    rax,QWORD PTR [rdi+0x10]
    3dfd:	mov    rax,QWORD PTR [rax+0xc0]
    3e04:	mov    QWORD PTR [r15+0x40],rax
    3e08:	mov    rdx,QWORD PTR [rdi+0x10]
    3e0c:	mov    rbx,QWORD PTR [rdx+0xc8]
    3e13:	mov    QWORD PTR [r15+0x48],rbx
    3e17:	mov    rdx,QWORD PTR [rdi+0x10]
    3e1b:	mov    r12,QWORD PTR [rdx+0xd0]
    3e22:	mov    QWORD PTR [r15+0x50],r12
    3e26:	mov    rdx,QWORD PTR [rdi+0x10]
    3e2a:	mov    r13,QWORD PTR [rdx+0xd8]
    3e31:	mov    QWORD PTR [r15+0x58],r13
    3e35:	mov    rdx,QWORD PTR [rdi+0x10]
    3e39:	mov    r14,QWORD PTR [rdx+0xe0]
    3e40:	mov    QWORD PTR [r15+0x60],r14
    3e44:	mov    rdx,QWORD PTR [rdi+0x10]
    3e48:	mov    r8,QWORD PTR [rdx+0xe8]
    3e4f:	mov    QWORD PTR [r15+0x68],r8
    3e53:	mov    rdx,QWORD PTR [rdi+0x10]
    3e57:	mov    r9,QWORD PTR [rdx+0xf0]
    3e5e:	mov    QWORD PTR [r15+0x70],r9
    3e62:	mov    rdx,QWORD PTR [rdi+0x10]
    3e66:	mov    r10,QWORD PTR [rdx+0xf8]
    3e6d:	mov    QWORD PTR [r15+0x78],r10
    3e71:	mov    rdx,QWORD PTR [rdi+0x10]
    3e75:	mov    QWORD PTR [rsp+0xa0],rdi
    3e7d:	mov    rdi,QWORD PTR [rdx+0x100]
    3e84:	mov    QWORD PTR [r15+0x80],rdi
    3e8b:	lea    rdx,[rsp]
    3e8f:	mov    rcx,QWORD PTR [rsp+0xd0]
    3e97:	mov    QWORD PTR [rsp],rcx
    3e9b:	mov    rcx,QWORD PTR [rsp+0xc8]
    3ea3:	mov    QWORD PTR [rsp+0x8],rcx
    3ea8:	mov    rcx,QWORD PTR [rsp+0xc0]
    3eb0:	mov    QWORD PTR [rsp+0x10],rcx
    3eb5:	mov    rcx,QWORD PTR [rsp+0xb8]
    3ebd:	mov    QWORD PTR [rsp+0x18],rcx
    3ec2:	mov    rcx,QWORD PTR [rsp+0xb0]
    3eca:	mov    QWORD PTR [rsp+0x20],rcx
    3ecf:	mov    QWORD PTR [rsp+0x28],r11
    3ed4:	mov    QWORD PTR [rsp+0x30],rsi
    3ed9:	mov    QWORD PTR [rsp+0x38],rax
    3ede:	mov    QWORD PTR [rsp+0x40],rbx
    3ee3:	mov    QWORD PTR [rsp+0x48],r12
    3ee8:	mov    QWORD PTR [rsp+0x50],r13
    3eed:	mov    QWORD PTR [rsp+0x58],r14
    3ef2:	mov    QWORD PTR [rsp+0x60],r8
    3ef7:	mov    QWORD PTR [rsp+0x68],r9
    3efc:	mov    QWORD PTR [rsp+0x70],r10
    3f01:	mov    QWORD PTR [rsp+0x78],rdi
    3f06:	mov    esi,0x10
    3f0b:	mov    rdi,QWORD PTR [rsp+0xa0]
    3f13:	call   3f18 <botlish_fn_24+0x20f>
			3f14: R_X86_64_PLT32	rt_list_new-0x4
    3f18:	test   rax,rax
    3f1b:	jne    3f2e <botlish_fn_24+0x225>
    3f21:	mov    rdi,QWORD PTR [rsp+0xa0]
    3f29:	jmp    403a <botlish_fn_24+0x331>
    3f2e:	mov    QWORD PTR [r15+0x8],rax
    3f32:	lea    r8,[rsp+0x80]
    3f3a:	mov    QWORD PTR [rsp+0x80],rax
    3f42:	mov    esi,0x1c
    3f47:	mov    rdx,QWORD PTR [rip+0x0]        # 3f4e <botlish_fn_24+0x245>
			3f4a: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; hex_pair<generic>
    3f4e:	mov    ebx,0x1
    3f53:	mov    rcx,rbx
    3f56:	mov    rdi,QWORD PTR [rsp+0xa0]
    3f5e:	call   3f63 <botlish_fn_24+0x25a>
			3f5f: R_X86_64_PLT32	rt_closure_new-0x4
    3f63:	mov    QWORD PTR [r15+0x8],rax
    3f67:	lea    r8,[rsp+0x88]
    3f6f:	mov    QWORD PTR [rsp+0x88],rax
    3f77:	mov    esi,0x1d
    3f7c:	mov    rdx,QWORD PTR [rip+0x0]        # 3f83 <botlish_fn_24+0x27a>
			3f7f: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; esc_bytes<generic>
    3f83:	mov    rcx,rbx
    3f86:	mov    rdi,QWORD PTR [rsp+0xa0]
    3f8e:	call   3f93 <botlish_fn_24+0x28a>
			3f8f: R_X86_64_PLT32	rt_closure_new-0x4
    3f93:	mov    QWORD PTR [r15+0x8],rax
    3f97:	lea    r8,[rsp+0x90]
    3f9f:	mov    QWORD PTR [rsp+0x90],rax
    3fa7:	mov    esi,0x1e
    3fac:	mov    rdx,QWORD PTR [rip+0x0]        # 3fb3 <botlish_fn_24+0x2aa>
			3faf: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; esc_char<generic>
    3fb3:	mov    rcx,rbx
    3fb6:	mov    rdi,QWORD PTR [rsp+0xa0]
    3fbe:	call   3fc3 <botlish_fn_24+0x2ba>
			3fbf: R_X86_64_PLT32	rt_closure_new-0x4
    3fc3:	mov    QWORD PTR [r15+0x8],rax
    3fc7:	lea    r8,[rsp+0x98]
    3fcf:	mov    QWORD PTR [rsp+0x98],rax
    3fd7:	mov    esi,0x1f
    3fdc:	mov    rdx,QWORD PTR [rip+0x0]        # 3fe3 <botlish_fn_24+0x2da>
			3fdf: R_X86_64_GOTPCREL	botlish_entry_31-0x4 ; esc_from<generic>
    3fe3:	mov    rcx,rbx
    3fe6:	mov    rdi,QWORD PTR [rsp+0xa0]
    3fee:	call   3ff3 <botlish_fn_24+0x2ea>
			3fef: R_X86_64_PLT32	rt_closure_new-0x4
    3ff3:	mov    QWORD PTR [r15+0x8],rax
    3ff7:	mov    QWORD PTR [r15+0x10],0x1
    3fff:	mov    rdi,QWORD PTR [rsp+0xa0]
    4007:	mov    rcx,QWORD PTR [rdi+0x10]
    400b:	mov    r8,QWORD PTR [rcx+0x108]
    4012:	mov    QWORD PTR [r15+0x18],r8
    4016:	mov    rcx,rbx
    4019:	mov    rdx,QWORD PTR [rsp+0xa8]
    4021:	mov    rsi,rax
    4024:	call   4029 <botlish_fn_24+0x320>
			4025: R_X86_64_PLT32	botlish_fn_31-0x4 ; esc_from<generic>
    4029:	test   rax,rax
    402c:	jne    407c <botlish_fn_24+0x373>
    4032:	mov    rdi,QWORD PTR [rsp+0xa0]
    403a:	mov    rdi,QWORD PTR [rsp+0xa0]
    4042:	mov    QWORD PTR [rdi],r15
    4045:	xor    rax,rax
    4048:	mov    rbx,QWORD PTR [rsp+0xe0]
    4050:	mov    r12,QWORD PTR [rsp+0xe8]
    4058:	mov    r13,QWORD PTR [rsp+0xf0]
    4060:	mov    r14,QWORD PTR [rsp+0xf8]
    4068:	mov    r15,QWORD PTR [rsp+0x100]
    4070:	add    rsp,0x110
    4077:	mov    rsp,rbp
    407a:	pop    rbp
    407b:	ret
    407c:	mov    rdi,QWORD PTR [rsp+0xa0]
    4084:	mov    QWORD PTR [rdi],r15
    4087:	mov    rbx,QWORD PTR [rsp+0xe0]
    408f:	mov    r12,QWORD PTR [rsp+0xe8]
    4097:	mov    r13,QWORD PTR [rsp+0xf0]
    409f:	mov    r14,QWORD PTR [rsp+0xf8]
    40a7:	mov    r15,QWORD PTR [rsp+0x100]
    40af:	add    rsp,0x110
    40b6:	mov    rsp,rbp
    40b9:	pop    rbp
    40ba:	ret
    40bb:	mov    QWORD PTR [rsp+0xa0],rdi
    40c3:	call   40c8 <botlish_fn_24+0x3bf>
			40c4: R_X86_64_PLT32	rt_stack_overflow-0x4
    40c8:	xor    rax,rax
    40cb:	mov    rbx,QWORD PTR [rsp+0xe0]
    40d3:	mov    r12,QWORD PTR [rsp+0xe8]
    40db:	mov    r13,QWORD PTR [rsp+0xf0]
    40e3:	mov    r14,QWORD PTR [rsp+0xf8]
    40eb:	mov    r15,QWORD PTR [rsp+0x100]
    40f3:	add    rsp,0x110
    40fa:	mov    rsp,rbp
    40fd:	pop    rbp
    40fe:	ret

00000000000040ff <botlish_entry_24: <str>>:
    40ff:	push   rbp
    4100:	mov    rbp,rsp
    4103:	mov    rsi,QWORD PTR [rdx]
    4106:	call   410b <botlish_entry_24+0xc>
			4107: R_X86_64_PLT32	botlish_fn_24-0x4 ; <str>
    410b:	mov    rsp,rbp
    410e:	pop    rbp
    410f:	ret

0000000000004110 <botlish_fn_25: <generic>>:
    4110:	push   rbp
    4111:	mov    rbp,rsp
    4114:	sub    rsp,0x110
    411b:	mov    QWORD PTR [rsp+0xe0],rbx
    4123:	mov    QWORD PTR [rsp+0xe8],r12
    412b:	mov    QWORD PTR [rsp+0xf0],r13
    4133:	mov    QWORD PTR [rsp+0xf8],r14
    413b:	mov    QWORD PTR [rsp+0x100],r15
    4143:	mov    r15,QWORD PTR [rdi]
    4146:	mov    r8,QWORD PTR [rdi+0x8]
    414a:	lea    r9,[r15+0x88]
    4151:	cmp    r9,r8
    4154:	ja     44c2 <botlish_fn_25+0x3b2>
    415a:	lea    r8,[r15+0x88]
    4161:	mov    QWORD PTR [rdi],r8
    4164:	mov    QWORD PTR [r15],rsi
    4167:	mov    QWORD PTR [rsp+0xa8],rsi
    416f:	mov    r8,QWORD PTR [rdi+0x10]
    4173:	mov    r9,QWORD PTR [r8+0x88]
    417a:	mov    QWORD PTR [r15+0x8],r9
    417e:	mov    QWORD PTR [rsp+0xd0],r9
    4186:	mov    r9,QWORD PTR [rdi+0x10]
    418a:	mov    r10,QWORD PTR [r9+0x90]
    4191:	mov    QWORD PTR [r15+0x10],r10
    4195:	mov    QWORD PTR [rsp+0xc8],r10
    419d:	mov    r10,QWORD PTR [rdi+0x10]
    41a1:	mov    r11,QWORD PTR [r10+0x98]
    41a8:	mov    QWORD PTR [r15+0x18],r11
    41ac:	mov    QWORD PTR [rsp+0xc0],r11
    41b4:	mov    r11,QWORD PTR [rdi+0x10]
    41b8:	mov    rcx,QWORD PTR [r11+0xa0]
    41bf:	mov    QWORD PTR [r15+0x20],rcx
    41c3:	mov    QWORD PTR [rsp+0xb8],rcx
    41cb:	mov    rax,QWORD PTR [rdi+0x10]
    41cf:	mov    r11,QWORD PTR [rax+0xa8]
    41d6:	mov    QWORD PTR [r15+0x28],r11
    41da:	mov    QWORD PTR [rsp+0xb0],r11
    41e2:	mov    rax,QWORD PTR [rdi+0x10]
    41e6:	mov    r11,QWORD PTR [rax+0xb0]
    41ed:	mov    QWORD PTR [r15+0x30],r11
    41f1:	mov    rax,QWORD PTR [rdi+0x10]
    41f5:	mov    rsi,QWORD PTR [rax+0xb8]
    41fc:	mov    QWORD PTR [r15+0x38],rsi
    4200:	mov    rax,QWORD PTR [rdi+0x10]
    4204:	mov    rax,QWORD PTR [rax+0xc0]
    420b:	mov    QWORD PTR [r15+0x40],rax
    420f:	mov    rdx,QWORD PTR [rdi+0x10]
    4213:	mov    rbx,QWORD PTR [rdx+0xc8]
    421a:	mov    QWORD PTR [r15+0x48],rbx
    421e:	mov    rdx,QWORD PTR [rdi+0x10]
    4222:	mov    r12,QWORD PTR [rdx+0xd0]
    4229:	mov    QWORD PTR [r15+0x50],r12
    422d:	mov    rdx,QWORD PTR [rdi+0x10]
    4231:	mov    r13,QWORD PTR [rdx+0xd8]
    4238:	mov    QWORD PTR [r15+0x58],r13
    423c:	mov    rdx,QWORD PTR [rdi+0x10]
    4240:	mov    r14,QWORD PTR [rdx+0xe0]
    4247:	mov    QWORD PTR [r15+0x60],r14
    424b:	mov    rdx,QWORD PTR [rdi+0x10]
    424f:	mov    r8,QWORD PTR [rdx+0xe8]
    4256:	mov    QWORD PTR [r15+0x68],r8
    425a:	mov    rdx,QWORD PTR [rdi+0x10]
    425e:	mov    r9,QWORD PTR [rdx+0xf0]
    4265:	mov    QWORD PTR [r15+0x70],r9
    4269:	mov    rdx,QWORD PTR [rdi+0x10]
    426d:	mov    r10,QWORD PTR [rdx+0xf8]
    4274:	mov    QWORD PTR [r15+0x78],r10
    4278:	mov    rdx,QWORD PTR [rdi+0x10]
    427c:	mov    QWORD PTR [rsp+0xa0],rdi
    4284:	mov    rdi,QWORD PTR [rdx+0x100]
    428b:	mov    QWORD PTR [r15+0x80],rdi
    4292:	lea    rdx,[rsp]
    4296:	mov    rcx,QWORD PTR [rsp+0xd0]
    429e:	mov    QWORD PTR [rsp],rcx
    42a2:	mov    rcx,QWORD PTR [rsp+0xc8]
    42aa:	mov    QWORD PTR [rsp+0x8],rcx
    42af:	mov    rcx,QWORD PTR [rsp+0xc0]
    42b7:	mov    QWORD PTR [rsp+0x10],rcx
    42bc:	mov    rcx,QWORD PTR [rsp+0xb8]
    42c4:	mov    QWORD PTR [rsp+0x18],rcx
    42c9:	mov    rcx,QWORD PTR [rsp+0xb0]
    42d1:	mov    QWORD PTR [rsp+0x20],rcx
    42d6:	mov    QWORD PTR [rsp+0x28],r11
    42db:	mov    QWORD PTR [rsp+0x30],rsi
    42e0:	mov    QWORD PTR [rsp+0x38],rax
    42e5:	mov    QWORD PTR [rsp+0x40],rbx
    42ea:	mov    QWORD PTR [rsp+0x48],r12
    42ef:	mov    QWORD PTR [rsp+0x50],r13
    42f4:	mov    QWORD PTR [rsp+0x58],r14
    42f9:	mov    QWORD PTR [rsp+0x60],r8
    42fe:	mov    QWORD PTR [rsp+0x68],r9
    4303:	mov    QWORD PTR [rsp+0x70],r10
    4308:	mov    QWORD PTR [rsp+0x78],rdi
    430d:	mov    esi,0x10
    4312:	mov    rdi,QWORD PTR [rsp+0xa0]
    431a:	call   431f <botlish_fn_25+0x20f>
			431b: R_X86_64_PLT32	rt_list_new-0x4
    431f:	test   rax,rax
    4322:	jne    4335 <botlish_fn_25+0x225>
    4328:	mov    rdi,QWORD PTR [rsp+0xa0]
    4330:	jmp    4441 <botlish_fn_25+0x331>
    4335:	mov    QWORD PTR [r15+0x8],rax
    4339:	lea    r8,[rsp+0x80]
    4341:	mov    QWORD PTR [rsp+0x80],rax
    4349:	mov    esi,0x1c
    434e:	mov    rdx,QWORD PTR [rip+0x0]        # 4355 <botlish_fn_25+0x245>
			4351: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; hex_pair<generic>
    4355:	mov    ebx,0x1
    435a:	mov    rcx,rbx
    435d:	mov    rdi,QWORD PTR [rsp+0xa0]
    4365:	call   436a <botlish_fn_25+0x25a>
			4366: R_X86_64_PLT32	rt_closure_new-0x4
    436a:	mov    QWORD PTR [r15+0x8],rax
    436e:	lea    r8,[rsp+0x88]
    4376:	mov    QWORD PTR [rsp+0x88],rax
    437e:	mov    esi,0x1d
    4383:	mov    rdx,QWORD PTR [rip+0x0]        # 438a <botlish_fn_25+0x27a>
			4386: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; esc_bytes<generic>
    438a:	mov    rcx,rbx
    438d:	mov    rdi,QWORD PTR [rsp+0xa0]
    4395:	call   439a <botlish_fn_25+0x28a>
			4396: R_X86_64_PLT32	rt_closure_new-0x4
    439a:	mov    QWORD PTR [r15+0x8],rax
    439e:	lea    r8,[rsp+0x90]
    43a6:	mov    QWORD PTR [rsp+0x90],rax
    43ae:	mov    esi,0x1e
    43b3:	mov    rdx,QWORD PTR [rip+0x0]        # 43ba <botlish_fn_25+0x2aa>
			43b6: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; esc_char<generic>
    43ba:	mov    rcx,rbx
    43bd:	mov    rdi,QWORD PTR [rsp+0xa0]
    43c5:	call   43ca <botlish_fn_25+0x2ba>
			43c6: R_X86_64_PLT32	rt_closure_new-0x4
    43ca:	mov    QWORD PTR [r15+0x8],rax
    43ce:	lea    r8,[rsp+0x98]
    43d6:	mov    QWORD PTR [rsp+0x98],rax
    43de:	mov    esi,0x1f
    43e3:	mov    rdx,QWORD PTR [rip+0x0]        # 43ea <botlish_fn_25+0x2da>
			43e6: R_X86_64_GOTPCREL	botlish_entry_31-0x4 ; esc_from<generic>
    43ea:	mov    rcx,rbx
    43ed:	mov    rdi,QWORD PTR [rsp+0xa0]
    43f5:	call   43fa <botlish_fn_25+0x2ea>
			43f6: R_X86_64_PLT32	rt_closure_new-0x4
    43fa:	mov    QWORD PTR [r15+0x8],rax
    43fe:	mov    QWORD PTR [r15+0x10],0x1
    4406:	mov    rdi,QWORD PTR [rsp+0xa0]
    440e:	mov    rcx,QWORD PTR [rdi+0x10]
    4412:	mov    r8,QWORD PTR [rcx+0x108]
    4419:	mov    QWORD PTR [r15+0x18],r8
    441d:	mov    rcx,rbx
    4420:	mov    rdx,QWORD PTR [rsp+0xa8]
    4428:	mov    rsi,rax
    442b:	call   4430 <botlish_fn_25+0x320>
			442c: R_X86_64_PLT32	botlish_fn_31-0x4 ; esc_from<generic>
    4430:	test   rax,rax
    4433:	jne    4483 <botlish_fn_25+0x373>
    4439:	mov    rdi,QWORD PTR [rsp+0xa0]
    4441:	mov    rdi,QWORD PTR [rsp+0xa0]
    4449:	mov    QWORD PTR [rdi],r15
    444c:	xor    rax,rax
    444f:	mov    rbx,QWORD PTR [rsp+0xe0]
    4457:	mov    r12,QWORD PTR [rsp+0xe8]
    445f:	mov    r13,QWORD PTR [rsp+0xf0]
    4467:	mov    r14,QWORD PTR [rsp+0xf8]
    446f:	mov    r15,QWORD PTR [rsp+0x100]
    4477:	add    rsp,0x110
    447e:	mov    rsp,rbp
    4481:	pop    rbp
    4482:	ret
    4483:	mov    rdi,QWORD PTR [rsp+0xa0]
    448b:	mov    QWORD PTR [rdi],r15
    448e:	mov    rbx,QWORD PTR [rsp+0xe0]
    4496:	mov    r12,QWORD PTR [rsp+0xe8]
    449e:	mov    r13,QWORD PTR [rsp+0xf0]
    44a6:	mov    r14,QWORD PTR [rsp+0xf8]
    44ae:	mov    r15,QWORD PTR [rsp+0x100]
    44b6:	add    rsp,0x110
    44bd:	mov    rsp,rbp
    44c0:	pop    rbp
    44c1:	ret
    44c2:	mov    QWORD PTR [rsp+0xa0],rdi
    44ca:	call   44cf <botlish_fn_25+0x3bf>
			44cb: R_X86_64_PLT32	rt_stack_overflow-0x4
    44cf:	xor    rax,rax
    44d2:	mov    rbx,QWORD PTR [rsp+0xe0]
    44da:	mov    r12,QWORD PTR [rsp+0xe8]
    44e2:	mov    r13,QWORD PTR [rsp+0xf0]
    44ea:	mov    r14,QWORD PTR [rsp+0xf8]
    44f2:	mov    r15,QWORD PTR [rsp+0x100]
    44fa:	add    rsp,0x110
    4501:	mov    rsp,rbp
    4504:	pop    rbp
    4505:	ret

0000000000004506 <botlish_entry_25: <generic>>:
    4506:	push   rbp
    4507:	mov    rbp,rsp
    450a:	mov    rsi,QWORD PTR [rdx]
    450d:	call   4512 <botlish_entry_25+0xc>
			450e: R_X86_64_PLT32	botlish_fn_25-0x4 ; <generic>
    4512:	mov    rsp,rbp
    4515:	pop    rbp
    4516:	ret
	...

0000000000004518 <botlish_fn_26: high_nibble<generic>>:
    4518:	push   rbp
    4519:	mov    rbp,rsp
    451c:	sub    rsp,0x20
    4520:	mov    QWORD PTR [rsp],rbx
    4524:	mov    QWORD PTR [rsp+0x8],r12
    4529:	mov    QWORD PTR [rsp+0x10],r13
    452e:	mov    rbx,QWORD PTR [rdi]
    4531:	mov    rax,QWORD PTR [rdi+0x8]
    4535:	lea    rcx,[rbx+0x8]
    4539:	cmp    rcx,rax
    453c:	ja     4b76 <botlish_fn_26+0x65e>
    4542:	lea    rax,[rbx+0x8]
    4546:	mov    QWORD PTR [rdi],rax
    4549:	mov    r11d,0x1
    454f:	test   rsi,0x1
    4556:	jne    4576 <botlish_fn_26+0x5e>
    455c:	xor    r11d,r11d
    455f:	test   rsi,0x7
    4566:	jne    4576 <botlish_fn_26+0x5e>
    456c:	movzx  rax,BYTE PTR [rsi]
    4570:	cmp    al,0x1
    4572:	sete   r11b
    4576:	test   r11b,r11b
    4579:	jne    45b8 <botlish_fn_26+0xa0>
    457f:	mov    rax,QWORD PTR [rdi+0x10]
    4583:	mov    r13,rdi
    4586:	mov    rcx,QWORD PTR [rax+0x110]
    458d:	xor    r12,r12
    4590:	mov    rdx,r12
    4593:	call   4598 <botlish_fn_26+0x80>
			4594: R_X86_64_PLT32	rt_type_error-0x4
    4598:	mov    rax,r12
    459b:	mov    rdi,r13
    459e:	mov    QWORD PTR [rdi],rbx
    45a1:	mov    rbx,QWORD PTR [rsp]
    45a5:	mov    r12,QWORD PTR [rsp+0x8]
    45aa:	mov    r13,QWORD PTR [rsp+0x10]
    45af:	add    rsp,0x20
    45b3:	mov    rsp,rbp
    45b6:	pop    rbp
    45b7:	ret
    45b8:	mov    r13,rdi
    45bb:	test   rsi,0x1
    45c2:	mov    r12,rsi
    45c5:	jne    45f0 <botlish_fn_26+0xd8>
    45cb:	mov    edx,0x1f
    45d0:	mov    rsi,r12
    45d3:	mov    rdi,r13
    45d6:	call   45db <botlish_fn_26+0xc3>
			45d7: R_X86_64_PLT32	rt_int_cmp-0x4
    45db:	mov    ecx,0x2
    45e0:	test   rax,rax
    45e3:	cmovle rcx,QWORD PTR [rip+0x5ad]        # 4b98 <botlish_fn_26+0x680>
    45eb:	jmp    4604 <botlish_fn_26+0xec>
    45f0:	mov    ecx,0x2
    45f5:	mov    rsi,r12
    45f8:	cmp    rsi,0x1f
    45fc:	cmovle rcx,QWORD PTR [rip+0x594]        # 4b98 <botlish_fn_26+0x680>
    4604:	cmp    rcx,0x6
    4608:	je     4b51 <botlish_fn_26+0x639>
    460e:	mov    rsi,r12
    4611:	test   rsi,0x1
    4618:	jne    4643 <botlish_fn_26+0x12b>
    461e:	mov    edx,0x3f
    4623:	mov    rsi,r12
    4626:	mov    rdi,r13
    4629:	call   462e <botlish_fn_26+0x116>
			462a: R_X86_64_PLT32	rt_int_cmp-0x4
    462e:	mov    ecx,0x2
    4633:	test   rax,rax
    4636:	cmovle rcx,QWORD PTR [rip+0x55a]        # 4b98 <botlish_fn_26+0x680>
    463e:	jmp    4657 <botlish_fn_26+0x13f>
    4643:	mov    ecx,0x2
    4648:	mov    rsi,r12
    464b:	cmp    rsi,0x3f
    464f:	cmovle rcx,QWORD PTR [rip+0x541]        # 4b98 <botlish_fn_26+0x680>
    4657:	cmp    rcx,0x6
    465b:	je     4b44 <botlish_fn_26+0x62c>
    4661:	mov    rsi,r12
    4664:	test   rsi,0x1
    466b:	jne    4696 <botlish_fn_26+0x17e>
    4671:	mov    edx,0x5f
    4676:	mov    rsi,r12
    4679:	mov    rdi,r13
    467c:	call   4681 <botlish_fn_26+0x169>
			467d: R_X86_64_PLT32	rt_int_cmp-0x4
    4681:	mov    esi,0x2
    4686:	test   rax,rax
    4689:	cmovle rsi,QWORD PTR [rip+0x507]        # 4b98 <botlish_fn_26+0x680>
    4691:	jmp    46aa <botlish_fn_26+0x192>
    4696:	mov    esi,0x2
    469b:	mov    rax,r12
    469e:	cmp    rax,0x5f
    46a2:	cmovle rsi,QWORD PTR [rip+0x4ee]        # 4b98 <botlish_fn_26+0x680>
    46aa:	cmp    rsi,0x6
    46ae:	je     4b3a <botlish_fn_26+0x622>
    46b4:	mov    rsi,r12
    46b7:	test   rsi,0x1
    46be:	jne    46e9 <botlish_fn_26+0x1d1>
    46c4:	mov    edx,0x7f
    46c9:	mov    rsi,r12
    46cc:	mov    rdi,r13
    46cf:	call   46d4 <botlish_fn_26+0x1bc>
			46d0: R_X86_64_PLT32	rt_int_cmp-0x4
    46d4:	mov    ecx,0x2
    46d9:	test   rax,rax
    46dc:	cmovle rcx,QWORD PTR [rip+0x4b4]        # 4b98 <botlish_fn_26+0x680>
    46e4:	jmp    46fd <botlish_fn_26+0x1e5>
    46e9:	mov    ecx,0x2
    46ee:	mov    rsi,r12
    46f1:	cmp    rsi,0x7f
    46f5:	cmovle rcx,QWORD PTR [rip+0x49b]        # 4b98 <botlish_fn_26+0x680>
    46fd:	cmp    rcx,0x6
    4701:	je     4b30 <botlish_fn_26+0x618>
    4707:	mov    rsi,r12
    470a:	test   rsi,0x1
    4711:	jne    473c <botlish_fn_26+0x224>
    4717:	mov    edx,0x9f
    471c:	mov    rsi,r12
    471f:	mov    rdi,r13
    4722:	call   4727 <botlish_fn_26+0x20f>
			4723: R_X86_64_PLT32	rt_int_cmp-0x4
    4727:	mov    ecx,0x2
    472c:	test   rax,rax
    472f:	cmovle rcx,QWORD PTR [rip+0x461]        # 4b98 <botlish_fn_26+0x680>
    4737:	jmp    4753 <botlish_fn_26+0x23b>
    473c:	mov    ecx,0x2
    4741:	mov    rsi,r12
    4744:	cmp    rsi,0x9f
    474b:	cmovle rcx,QWORD PTR [rip+0x445]        # 4b98 <botlish_fn_26+0x680>
    4753:	cmp    rcx,0x6
    4757:	je     4b26 <botlish_fn_26+0x60e>
    475d:	mov    rsi,r12
    4760:	test   rsi,0x1
    4767:	jne    4792 <botlish_fn_26+0x27a>
    476d:	mov    edx,0xbf
    4772:	mov    rsi,r12
    4775:	mov    rdi,r13
    4778:	call   477d <botlish_fn_26+0x265>
			4779: R_X86_64_PLT32	rt_int_cmp-0x4
    477d:	mov    ecx,0x2
    4782:	test   rax,rax
    4785:	cmovle rcx,QWORD PTR [rip+0x40b]        # 4b98 <botlish_fn_26+0x680>
    478d:	jmp    47a9 <botlish_fn_26+0x291>
    4792:	mov    ecx,0x2
    4797:	mov    rsi,r12
    479a:	cmp    rsi,0xbf
    47a1:	cmovle rcx,QWORD PTR [rip+0x3ef]        # 4b98 <botlish_fn_26+0x680>
    47a9:	cmp    rcx,0x6
    47ad:	je     4b1c <botlish_fn_26+0x604>
    47b3:	mov    rsi,r12
    47b6:	test   rsi,0x1
    47bd:	jne    47e8 <botlish_fn_26+0x2d0>
    47c3:	mov    edx,0xdf
    47c8:	mov    rsi,r12
    47cb:	mov    rdi,r13
    47ce:	call   47d3 <botlish_fn_26+0x2bb>
			47cf: R_X86_64_PLT32	rt_int_cmp-0x4
    47d3:	mov    esi,0x2
    47d8:	test   rax,rax
    47db:	cmovle rsi,QWORD PTR [rip+0x3b5]        # 4b98 <botlish_fn_26+0x680>
    47e3:	jmp    47fe <botlish_fn_26+0x2e6>
    47e8:	mov    esi,0x2
    47ed:	mov    rax,r12
    47f0:	cmp    rax,0xdf
    47f6:	cmovle rsi,QWORD PTR [rip+0x39a]        # 4b98 <botlish_fn_26+0x680>
    47fe:	cmp    rsi,0x6
    4802:	je     4b12 <botlish_fn_26+0x5fa>
    4808:	mov    rsi,r12
    480b:	test   rsi,0x1
    4812:	jne    483d <botlish_fn_26+0x325>
    4818:	mov    edx,0xff
    481d:	mov    rsi,r12
    4820:	mov    rdi,r13
    4823:	call   4828 <botlish_fn_26+0x310>
			4824: R_X86_64_PLT32	rt_int_cmp-0x4
    4828:	mov    ecx,0x2
    482d:	test   rax,rax
    4830:	cmovle rcx,QWORD PTR [rip+0x360]        # 4b98 <botlish_fn_26+0x680>
    4838:	jmp    4854 <botlish_fn_26+0x33c>
    483d:	mov    ecx,0x2
    4842:	mov    rsi,r12
    4845:	cmp    rsi,0xff
    484c:	cmovle rcx,QWORD PTR [rip+0x344]        # 4b98 <botlish_fn_26+0x680>
    4854:	cmp    rcx,0x6
    4858:	je     4b08 <botlish_fn_26+0x5f0>
    485e:	mov    rsi,r12
    4861:	test   rsi,0x1
    4868:	jne    4893 <botlish_fn_26+0x37b>
    486e:	mov    edx,0x11f
    4873:	mov    rsi,r12
    4876:	mov    rdi,r13
    4879:	call   487e <botlish_fn_26+0x366>
			487a: R_X86_64_PLT32	rt_int_cmp-0x4
    487e:	mov    ecx,0x2
    4883:	test   rax,rax
    4886:	cmovle rcx,QWORD PTR [rip+0x30a]        # 4b98 <botlish_fn_26+0x680>
    488e:	jmp    48aa <botlish_fn_26+0x392>
    4893:	mov    ecx,0x2
    4898:	mov    rsi,r12
    489b:	cmp    rsi,0x11f
    48a2:	cmovle rcx,QWORD PTR [rip+0x2ee]        # 4b98 <botlish_fn_26+0x680>
    48aa:	cmp    rcx,0x6
    48ae:	je     4afe <botlish_fn_26+0x5e6>
    48b4:	mov    rsi,r12
    48b7:	test   rsi,0x1
    48be:	jne    48e9 <botlish_fn_26+0x3d1>
    48c4:	mov    edx,0x13f
    48c9:	mov    rsi,r12
    48cc:	mov    rdi,r13
    48cf:	call   48d4 <botlish_fn_26+0x3bc>
			48d0: R_X86_64_PLT32	rt_int_cmp-0x4
    48d4:	mov    ecx,0x2
    48d9:	test   rax,rax
    48dc:	cmovle rcx,QWORD PTR [rip+0x2b4]        # 4b98 <botlish_fn_26+0x680>
    48e4:	jmp    4900 <botlish_fn_26+0x3e8>
    48e9:	mov    ecx,0x2
    48ee:	mov    rsi,r12
    48f1:	cmp    rsi,0x13f
    48f8:	cmovle rcx,QWORD PTR [rip+0x298]        # 4b98 <botlish_fn_26+0x680>
    4900:	cmp    rcx,0x6
    4904:	je     4af4 <botlish_fn_26+0x5dc>
    490a:	mov    rsi,r12
    490d:	test   rsi,0x1
    4914:	jne    493f <botlish_fn_26+0x427>
    491a:	mov    edx,0x15f
    491f:	mov    rsi,r12
    4922:	mov    rdi,r13
    4925:	call   492a <botlish_fn_26+0x412>
			4926: R_X86_64_PLT32	rt_int_cmp-0x4
    492a:	mov    ecx,0x2
    492f:	test   rax,rax
    4932:	cmovle rcx,QWORD PTR [rip+0x25e]        # 4b98 <botlish_fn_26+0x680>
    493a:	jmp    4956 <botlish_fn_26+0x43e>
    493f:	mov    ecx,0x2
    4944:	mov    rsi,r12
    4947:	cmp    rsi,0x15f
    494e:	cmovle rcx,QWORD PTR [rip+0x242]        # 4b98 <botlish_fn_26+0x680>
    4956:	cmp    rcx,0x6
    495a:	je     4aea <botlish_fn_26+0x5d2>
    4960:	mov    rsi,r12
    4963:	test   rsi,0x1
    496a:	jne    4995 <botlish_fn_26+0x47d>
    4970:	mov    edx,0x17f
    4975:	mov    rsi,r12
    4978:	mov    rdi,r13
    497b:	call   4980 <botlish_fn_26+0x468>
			497c: R_X86_64_PLT32	rt_int_cmp-0x4
    4980:	mov    ecx,0x2
    4985:	test   rax,rax
    4988:	cmovle rcx,QWORD PTR [rip+0x208]        # 4b98 <botlish_fn_26+0x680>
    4990:	jmp    49ac <botlish_fn_26+0x494>
    4995:	mov    ecx,0x2
    499a:	mov    rsi,r12
    499d:	cmp    rsi,0x17f
    49a4:	cmovle rcx,QWORD PTR [rip+0x1ec]        # 4b98 <botlish_fn_26+0x680>
    49ac:	cmp    rcx,0x6
    49b0:	je     4ae0 <botlish_fn_26+0x5c8>
    49b6:	mov    rsi,r12
    49b9:	test   rsi,0x1
    49c0:	jne    49eb <botlish_fn_26+0x4d3>
    49c6:	mov    edx,0x19f
    49cb:	mov    rsi,r12
    49ce:	mov    rdi,r13
    49d1:	call   49d6 <botlish_fn_26+0x4be>
			49d2: R_X86_64_PLT32	rt_int_cmp-0x4
    49d6:	mov    ecx,0x2
    49db:	test   rax,rax
    49de:	cmovle rcx,QWORD PTR [rip+0x1b2]        # 4b98 <botlish_fn_26+0x680>
    49e6:	jmp    4a02 <botlish_fn_26+0x4ea>
    49eb:	mov    ecx,0x2
    49f0:	mov    rsi,r12
    49f3:	cmp    rsi,0x19f
    49fa:	cmovle rcx,QWORD PTR [rip+0x196]        # 4b98 <botlish_fn_26+0x680>
    4a02:	cmp    rcx,0x6
    4a06:	je     4ad6 <botlish_fn_26+0x5be>
    4a0c:	mov    rsi,r12
    4a0f:	test   rsi,0x1
    4a16:	jne    4a41 <botlish_fn_26+0x529>
    4a1c:	mov    edx,0x1bf
    4a21:	mov    rsi,r12
    4a24:	mov    rdi,r13
    4a27:	call   4a2c <botlish_fn_26+0x514>
			4a28: R_X86_64_PLT32	rt_int_cmp-0x4
    4a2c:	mov    ecx,0x2
    4a31:	test   rax,rax
    4a34:	cmovle rcx,QWORD PTR [rip+0x15c]        # 4b98 <botlish_fn_26+0x680>
    4a3c:	jmp    4a58 <botlish_fn_26+0x540>
    4a41:	mov    ecx,0x2
    4a46:	mov    rsi,r12
    4a49:	cmp    rsi,0x1bf
    4a50:	cmovle rcx,QWORD PTR [rip+0x140]        # 4b98 <botlish_fn_26+0x680>
    4a58:	cmp    rcx,0x6
    4a5c:	je     4acc <botlish_fn_26+0x5b4>
    4a62:	mov    rsi,r12
    4a65:	test   rsi,0x1
    4a6c:	jne    4a97 <botlish_fn_26+0x57f>
    4a72:	mov    edx,0x1df
    4a77:	mov    rsi,r12
    4a7a:	mov    rdi,r13
    4a7d:	call   4a82 <botlish_fn_26+0x56a>
			4a7e: R_X86_64_PLT32	rt_int_cmp-0x4
    4a82:	mov    ecx,0x2
    4a87:	test   rax,rax
    4a8a:	cmovle rcx,QWORD PTR [rip+0x106]        # 4b98 <botlish_fn_26+0x680>
    4a92:	jmp    4aae <botlish_fn_26+0x596>
    4a97:	mov    ecx,0x2
    4a9c:	mov    rsi,r12
    4a9f:	cmp    rsi,0x1df
    4aa6:	cmovle rcx,QWORD PTR [rip+0xea]        # 4b98 <botlish_fn_26+0x680>
    4aae:	cmp    rcx,0x6
    4ab2:	je     4ac2 <botlish_fn_26+0x5aa>
    4ab8:	mov    eax,0x1f
    4abd:	jmp    4b49 <botlish_fn_26+0x631>
    4ac2:	mov    eax,0x1d
    4ac7:	jmp    4b49 <botlish_fn_26+0x631>
    4acc:	mov    eax,0x1b
    4ad1:	jmp    4b49 <botlish_fn_26+0x631>
    4ad6:	mov    eax,0x19
    4adb:	jmp    4b49 <botlish_fn_26+0x631>
    4ae0:	mov    eax,0x17
    4ae5:	jmp    4b49 <botlish_fn_26+0x631>
    4aea:	mov    eax,0x15
    4aef:	jmp    4b49 <botlish_fn_26+0x631>
    4af4:	mov    eax,0x13
    4af9:	jmp    4b49 <botlish_fn_26+0x631>
    4afe:	mov    eax,0x11
    4b03:	jmp    4b49 <botlish_fn_26+0x631>
    4b08:	mov    eax,0xf
    4b0d:	jmp    4b49 <botlish_fn_26+0x631>
    4b12:	mov    eax,0xd
    4b17:	jmp    4b49 <botlish_fn_26+0x631>
    4b1c:	mov    eax,0xb
    4b21:	jmp    4b49 <botlish_fn_26+0x631>
    4b26:	mov    eax,0x9
    4b2b:	jmp    4b49 <botlish_fn_26+0x631>
    4b30:	mov    eax,0x7
    4b35:	jmp    4b49 <botlish_fn_26+0x631>
    4b3a:	mov    eax,0x5
    4b3f:	jmp    4b49 <botlish_fn_26+0x631>
    4b44:	mov    eax,0x3
    4b49:	mov    rdi,r13
    4b4c:	jmp    4b59 <botlish_fn_26+0x641>
    4b51:	mov    eax,0x1
    4b56:	mov    rdi,r13
    4b59:	mov    rdi,r13
    4b5c:	mov    QWORD PTR [rdi],rbx
    4b5f:	mov    rbx,QWORD PTR [rsp]
    4b63:	mov    r12,QWORD PTR [rsp+0x8]
    4b68:	mov    r13,QWORD PTR [rsp+0x10]
    4b6d:	add    rsp,0x20
    4b71:	mov    rsp,rbp
    4b74:	pop    rbp
    4b75:	ret
    4b76:	mov    r13,rdi
    4b79:	call   4b7e <botlish_fn_26+0x666>
			4b7a: R_X86_64_PLT32	rt_stack_overflow-0x4
    4b7e:	xor    rax,rax
    4b81:	mov    rbx,QWORD PTR [rsp]
    4b85:	mov    r12,QWORD PTR [rsp+0x8]
    4b8a:	mov    r13,QWORD PTR [rsp+0x10]
    4b8f:	add    rsp,0x20
    4b93:	mov    rsp,rbp
    4b96:	pop    rbp
    4b97:	ret
    4b98:	(bad)
    4b99:	add    BYTE PTR [rax],al
    4b9b:	add    BYTE PTR [rax],al
    4b9d:	add    BYTE PTR [rax],al
	...

0000000000004ba0 <botlish_entry_26: high_nibble<generic>>:
    4ba0:	push   rbp
    4ba1:	mov    rbp,rsp
    4ba4:	mov    rsi,QWORD PTR [rdx]
    4ba7:	call   4bac <botlish_entry_26+0xc>
			4ba8: R_X86_64_PLT32	botlish_fn_26-0x4 ; high_nibble<generic>
    4bac:	mov    rsp,rbp
    4baf:	pop    rbp
    4bb0:	ret
    4bb1:	add    BYTE PTR [rax],al
    4bb3:	add    BYTE PTR [rax],al
    4bb5:	add    BYTE PTR [rax],al
	...

0000000000004bb8 <botlish_fn_27: is_unreserved<generic>>:
    4bb8:	push   rbp
    4bb9:	mov    rbp,rsp
    4bbc:	sub    rsp,0x20
    4bc0:	mov    QWORD PTR [rsp],rbx
    4bc4:	mov    QWORD PTR [rsp+0x8],r12
    4bc9:	mov    QWORD PTR [rsp+0x10],r13
    4bce:	mov    QWORD PTR [rsp+0x18],r14
    4bd3:	mov    rbx,QWORD PTR [rdi]
    4bd6:	mov    rax,QWORD PTR [rdi+0x8]
    4bda:	lea    rcx,[rbx+0x8]
    4bde:	cmp    rcx,rax
    4be1:	ja     5103 <botlish_fn_27+0x54b>
    4be7:	lea    rax,[rbx+0x8]
    4beb:	mov    QWORD PTR [rdi],rax
    4bee:	mov    r11d,0x1
    4bf4:	test   rsi,0x1
    4bfb:	jne    4c1d <botlish_fn_27+0x65>
    4c01:	xor    r11d,r11d
    4c04:	test   rsi,0x7
    4c0b:	jne    4c1d <botlish_fn_27+0x65>
    4c11:	movzx  r8,BYTE PTR [rsi]
    4c15:	cmp    r8b,0x1
    4c19:	sete   r11b
    4c1d:	test   r11b,r11b
    4c20:	jne    4c64 <botlish_fn_27+0xac>
    4c26:	mov    rax,QWORD PTR [rdi+0x10]
    4c2a:	mov    r13,rdi
    4c2d:	mov    rcx,QWORD PTR [rax+0x110]
    4c34:	xor    r12,r12
    4c37:	mov    rdx,r12
    4c3a:	call   4c3f <botlish_fn_27+0x87>
			4c3b: R_X86_64_PLT32	rt_type_error-0x4
    4c3f:	mov    rax,r12
    4c42:	mov    rdi,r13
    4c45:	mov    QWORD PTR [rdi],rbx
    4c48:	mov    rbx,QWORD PTR [rsp]
    4c4c:	mov    r12,QWORD PTR [rsp+0x8]
    4c51:	mov    r13,QWORD PTR [rsp+0x10]
    4c56:	mov    r14,QWORD PTR [rsp+0x18]
    4c5b:	add    rsp,0x20
    4c5f:	mov    rsp,rbp
    4c62:	pop    rbp
    4c63:	ret
    4c64:	mov    r13,rdi
    4c67:	test   rsi,0x1
    4c6e:	mov    r12,rsi
    4c71:	jne    4c9c <botlish_fn_27+0xe4>
    4c77:	mov    edx,0x59
    4c7c:	mov    rsi,r12
    4c7f:	mov    rdi,r13
    4c82:	call   4c87 <botlish_fn_27+0xcf>
			4c83: R_X86_64_PLT32	rt_int_cmp-0x4
    4c87:	mov    ecx,0x2
    4c8c:	test   rax,rax
    4c8f:	cmovle rcx,QWORD PTR [rip+0x499]        # 5130 <botlish_fn_27+0x578>
    4c97:	jmp    4cb0 <botlish_fn_27+0xf8>
    4c9c:	mov    ecx,0x2
    4ca1:	mov    rsi,r12
    4ca4:	cmp    rsi,0x59
    4ca8:	cmovle rcx,QWORD PTR [rip+0x480]        # 5130 <botlish_fn_27+0x578>
    4cb0:	mov    eax,0x6
    4cb5:	mov    r14,rax
    4cb8:	cmp    rcx,0x6
    4cbc:	je     50d9 <botlish_fn_27+0x521>
    4cc2:	mov    rsi,r12
    4cc5:	test   rsi,0x1
    4ccc:	jne    4cf7 <botlish_fn_27+0x13f>
    4cd2:	mov    edx,0x5d
    4cd7:	mov    rsi,r12
    4cda:	mov    rdi,r13
    4cdd:	call   4ce2 <botlish_fn_27+0x12a>
			4cde: R_X86_64_PLT32	rt_int_cmp-0x4
    4ce2:	mov    ecx,0x2
    4ce7:	test   rax,rax
    4cea:	cmovle rcx,QWORD PTR [rip+0x43e]        # 5130 <botlish_fn_27+0x578>
    4cf2:	jmp    4d0b <botlish_fn_27+0x153>
    4cf7:	mov    ecx,0x2
    4cfc:	mov    rsi,r12
    4cff:	cmp    rsi,0x5d
    4d03:	cmovle rcx,QWORD PTR [rip+0x425]        # 5130 <botlish_fn_27+0x578>
    4d0b:	cmp    rcx,0x6
    4d0f:	je     50ce <botlish_fn_27+0x516>
    4d15:	mov    rsi,r12
    4d18:	test   rsi,0x1
    4d1f:	jne    4d4a <botlish_fn_27+0x192>
    4d25:	mov    edx,0x5f
    4d2a:	mov    rsi,r12
    4d2d:	mov    rdi,r13
    4d30:	call   4d35 <botlish_fn_27+0x17d>
			4d31: R_X86_64_PLT32	rt_int_cmp-0x4
    4d35:	mov    edi,0x2
    4d3a:	test   rax,rax
    4d3d:	cmovle rdi,QWORD PTR [rip+0x3eb]        # 5130 <botlish_fn_27+0x578>
    4d45:	jmp    4d5e <botlish_fn_27+0x1a6>
    4d4a:	mov    edi,0x2
    4d4f:	mov    rsi,r12
    4d52:	cmp    rsi,0x5f
    4d56:	cmovle rdi,QWORD PTR [rip+0x3d2]        # 5130 <botlish_fn_27+0x578>
    4d5e:	cmp    rdi,0x6
    4d62:	je     50c4 <botlish_fn_27+0x50c>
    4d68:	mov    rsi,r12
    4d6b:	test   rsi,0x1
    4d72:	jne    4d9d <botlish_fn_27+0x1e5>
    4d78:	mov    edx,0x73
    4d7d:	mov    rsi,r12
    4d80:	mov    rdi,r13
    4d83:	call   4d88 <botlish_fn_27+0x1d0>
			4d84: R_X86_64_PLT32	rt_int_cmp-0x4
    4d88:	mov    ecx,0x2
    4d8d:	test   rax,rax
    4d90:	cmovle rcx,QWORD PTR [rip+0x398]        # 5130 <botlish_fn_27+0x578>
    4d98:	jmp    4db1 <botlish_fn_27+0x1f9>
    4d9d:	mov    ecx,0x2
    4da2:	mov    rsi,r12
    4da5:	cmp    rsi,0x73
    4da9:	cmovle rcx,QWORD PTR [rip+0x37f]        # 5130 <botlish_fn_27+0x578>
    4db1:	cmp    rcx,0x6
    4db5:	je     50bc <botlish_fn_27+0x504>
    4dbb:	mov    rsi,r12
    4dbe:	test   rsi,0x1
    4dc5:	jne    4df0 <botlish_fn_27+0x238>
    4dcb:	mov    edx,0x81
    4dd0:	mov    rsi,r12
    4dd3:	mov    rdi,r13
    4dd6:	call   4ddb <botlish_fn_27+0x223>
			4dd7: R_X86_64_PLT32	rt_int_cmp-0x4
    4ddb:	mov    ecx,0x2
    4de0:	test   rax,rax
    4de3:	cmovle rcx,QWORD PTR [rip+0x345]        # 5130 <botlish_fn_27+0x578>
    4deb:	jmp    4e07 <botlish_fn_27+0x24f>
    4df0:	mov    ecx,0x2
    4df5:	mov    rsi,r12
    4df8:	cmp    rsi,0x81
    4dff:	cmovle rcx,QWORD PTR [rip+0x329]        # 5130 <botlish_fn_27+0x578>
    4e07:	cmp    rcx,0x6
    4e0b:	je     50b2 <botlish_fn_27+0x4fa>
    4e11:	mov    rsi,r12
    4e14:	test   rsi,0x1
    4e1b:	jne    4e46 <botlish_fn_27+0x28e>
    4e21:	mov    edx,0xb5
    4e26:	mov    rsi,r12
    4e29:	mov    rdi,r13
    4e2c:	call   4e31 <botlish_fn_27+0x279>
			4e2d: R_X86_64_PLT32	rt_int_cmp-0x4
    4e31:	mov    ecx,0x2
    4e36:	test   rax,rax
    4e39:	cmovle rcx,QWORD PTR [rip+0x2ef]        # 5130 <botlish_fn_27+0x578>
    4e41:	jmp    4e5d <botlish_fn_27+0x2a5>
    4e46:	mov    ecx,0x2
    4e4b:	mov    rsi,r12
    4e4e:	cmp    rsi,0xb5
    4e55:	cmovle rcx,QWORD PTR [rip+0x2d3]        # 5130 <botlish_fn_27+0x578>
    4e5d:	cmp    rcx,0x6
    4e61:	je     50aa <botlish_fn_27+0x4f2>
    4e67:	mov    rsi,r12
    4e6a:	test   rsi,0x1
    4e71:	jne    4e9c <botlish_fn_27+0x2e4>
    4e77:	mov    edx,0xbd
    4e7c:	mov    rsi,r12
    4e7f:	mov    rdi,r13
    4e82:	call   4e87 <botlish_fn_27+0x2cf>
			4e83: R_X86_64_PLT32	rt_int_cmp-0x4
    4e87:	mov    esi,0x2
    4e8c:	test   rax,rax
    4e8f:	cmovle rsi,QWORD PTR [rip+0x299]        # 5130 <botlish_fn_27+0x578>
    4e97:	jmp    4eb2 <botlish_fn_27+0x2fa>
    4e9c:	mov    esi,0x2
    4ea1:	mov    rax,r12
    4ea4:	cmp    rax,0xbd
    4eaa:	cmovle rsi,QWORD PTR [rip+0x27e]        # 5130 <botlish_fn_27+0x578>
    4eb2:	cmp    rsi,0x6
    4eb6:	je     50a0 <botlish_fn_27+0x4e8>
    4ebc:	mov    rsi,r12
    4ebf:	test   rsi,0x1
    4ec6:	jne    4ef1 <botlish_fn_27+0x339>
    4ecc:	mov    edx,0xbf
    4ed1:	mov    rsi,r12
    4ed4:	mov    rdi,r13
    4ed7:	call   4edc <botlish_fn_27+0x324>
			4ed8: R_X86_64_PLT32	rt_int_cmp-0x4
    4edc:	mov    ecx,0x2
    4ee1:	test   rax,rax
    4ee4:	cmovle rcx,QWORD PTR [rip+0x244]        # 5130 <botlish_fn_27+0x578>
    4eec:	jmp    4f08 <botlish_fn_27+0x350>
    4ef1:	mov    ecx,0x2
    4ef6:	mov    rsi,r12
    4ef9:	cmp    rsi,0xbf
    4f00:	cmovle rcx,QWORD PTR [rip+0x228]        # 5130 <botlish_fn_27+0x578>
    4f08:	cmp    rcx,0x6
    4f0c:	je     5098 <botlish_fn_27+0x4e0>
    4f12:	mov    rsi,r12
    4f15:	test   rsi,0x1
    4f1c:	jne    4f47 <botlish_fn_27+0x38f>
    4f22:	mov    edx,0xc1
    4f27:	mov    rsi,r12
    4f2a:	mov    rdi,r13
    4f2d:	call   4f32 <botlish_fn_27+0x37a>
			4f2e: R_X86_64_PLT32	rt_int_cmp-0x4
    4f32:	mov    ecx,0x2
    4f37:	test   rax,rax
    4f3a:	cmovle rcx,QWORD PTR [rip+0x1ee]        # 5130 <botlish_fn_27+0x578>
    4f42:	jmp    4f5e <botlish_fn_27+0x3a6>
    4f47:	mov    ecx,0x2
    4f4c:	mov    rsi,r12
    4f4f:	cmp    rsi,0xc1
    4f56:	cmovle rcx,QWORD PTR [rip+0x1d2]        # 5130 <botlish_fn_27+0x578>
    4f5e:	cmp    rcx,0x6
    4f62:	je     508e <botlish_fn_27+0x4d6>
    4f68:	mov    rsi,r12
    4f6b:	test   rsi,0x1
    4f72:	jne    4f9d <botlish_fn_27+0x3e5>
    4f78:	mov    edx,0xf5
    4f7d:	mov    rsi,r12
    4f80:	mov    rdi,r13
    4f83:	call   4f88 <botlish_fn_27+0x3d0>
			4f84: R_X86_64_PLT32	rt_int_cmp-0x4
    4f88:	mov    ecx,0x2
    4f8d:	test   rax,rax
    4f90:	cmovle rcx,QWORD PTR [rip+0x198]        # 5130 <botlish_fn_27+0x578>
    4f98:	jmp    4fb4 <botlish_fn_27+0x3fc>
    4f9d:	mov    ecx,0x2
    4fa2:	mov    rsi,r12
    4fa5:	cmp    rsi,0xf5
    4fac:	cmovle rcx,QWORD PTR [rip+0x17c]        # 5130 <botlish_fn_27+0x578>
    4fb4:	cmp    rcx,0x6
    4fb8:	je     5086 <botlish_fn_27+0x4ce>
    4fbe:	mov    rsi,r12
    4fc1:	test   rsi,0x1
    4fc8:	jne    4ff3 <botlish_fn_27+0x43b>
    4fce:	mov    edx,0xfb
    4fd3:	mov    rsi,r12
    4fd6:	mov    rdi,r13
    4fd9:	call   4fde <botlish_fn_27+0x426>
			4fda: R_X86_64_PLT32	rt_int_cmp-0x4
    4fde:	mov    ecx,0x2
    4fe3:	test   rax,rax
    4fe6:	cmovle rcx,QWORD PTR [rip+0x142]        # 5130 <botlish_fn_27+0x578>
    4fee:	jmp    500a <botlish_fn_27+0x452>
    4ff3:	mov    ecx,0x2
    4ff8:	mov    rsi,r12
    4ffb:	cmp    rsi,0xfb
    5002:	cmovle rcx,QWORD PTR [rip+0x126]        # 5130 <botlish_fn_27+0x578>
    500a:	cmp    rcx,0x6
    500e:	je     507c <botlish_fn_27+0x4c4>
    5014:	mov    rsi,r12
    5017:	test   rsi,0x1
    501e:	jne    5049 <botlish_fn_27+0x491>
    5024:	mov    edx,0xfd
    5029:	mov    rsi,r12
    502c:	mov    rdi,r13
    502f:	call   5034 <botlish_fn_27+0x47c>
			5030: R_X86_64_PLT32	rt_int_cmp-0x4
    5034:	mov    ecx,0x2
    5039:	test   rax,rax
    503c:	cmovle rcx,QWORD PTR [rip+0xec]        # 5130 <botlish_fn_27+0x578>
    5044:	jmp    5060 <botlish_fn_27+0x4a8>
    5049:	mov    ecx,0x2
    504e:	mov    rsi,r12
    5051:	cmp    rsi,0xfd
    5058:	cmovle rcx,QWORD PTR [rip+0xd0]        # 5130 <botlish_fn_27+0x578>
    5060:	cmp    rcx,0x6
    5064:	je     5074 <botlish_fn_27+0x4bc>
    506a:	mov    eax,0x2
    506f:	jmp    50d1 <botlish_fn_27+0x519>
    5074:	mov    rax,r14
    5077:	jmp    50d1 <botlish_fn_27+0x519>
    507c:	mov    eax,0x2
    5081:	jmp    50d1 <botlish_fn_27+0x519>
    5086:	mov    rax,r14
    5089:	jmp    50d1 <botlish_fn_27+0x519>
    508e:	mov    eax,0x2
    5093:	jmp    50d1 <botlish_fn_27+0x519>
    5098:	mov    rax,r14
    509b:	jmp    50d1 <botlish_fn_27+0x519>
    50a0:	mov    eax,0x2
    50a5:	jmp    50d1 <botlish_fn_27+0x519>
    50aa:	mov    rax,r14
    50ad:	jmp    50d1 <botlish_fn_27+0x519>
    50b2:	mov    eax,0x2
    50b7:	jmp    50d1 <botlish_fn_27+0x519>
    50bc:	mov    rax,r14
    50bf:	jmp    50d1 <botlish_fn_27+0x519>
    50c4:	mov    eax,0x2
    50c9:	jmp    50d1 <botlish_fn_27+0x519>
    50ce:	mov    rax,r14
    50d1:	mov    rdi,r13
    50d4:	jmp    50e1 <botlish_fn_27+0x529>
    50d9:	mov    eax,0x2
    50de:	mov    rdi,r13
    50e1:	mov    rdi,r13
    50e4:	mov    QWORD PTR [rdi],rbx
    50e7:	mov    rbx,QWORD PTR [rsp]
    50eb:	mov    r12,QWORD PTR [rsp+0x8]
    50f0:	mov    r13,QWORD PTR [rsp+0x10]
    50f5:	mov    r14,QWORD PTR [rsp+0x18]
    50fa:	add    rsp,0x20
    50fe:	mov    rsp,rbp
    5101:	pop    rbp
    5102:	ret
    5103:	mov    r13,rdi
    5106:	call   510b <botlish_fn_27+0x553>
			5107: R_X86_64_PLT32	rt_stack_overflow-0x4
    510b:	xor    rax,rax
    510e:	mov    rbx,QWORD PTR [rsp]
    5112:	mov    r12,QWORD PTR [rsp+0x8]
    5117:	mov    r13,QWORD PTR [rsp+0x10]
    511c:	mov    r14,QWORD PTR [rsp+0x18]
    5121:	add    rsp,0x20
    5125:	mov    rsp,rbp
    5128:	pop    rbp
    5129:	ret
    512a:	add    BYTE PTR [rax],al
    512c:	add    BYTE PTR [rax],al
    512e:	add    BYTE PTR [rax],al
    5130:	(bad)
    5131:	add    BYTE PTR [rax],al
    5133:	add    BYTE PTR [rax],al
    5135:	add    BYTE PTR [rax],al
	...

0000000000005138 <botlish_entry_27: is_unreserved<generic>>:
    5138:	push   rbp
    5139:	mov    rbp,rsp
    513c:	mov    rsi,QWORD PTR [rdx]
    513f:	call   5144 <botlish_entry_27+0xc>
			5140: R_X86_64_PLT32	botlish_fn_27-0x4 ; is_unreserved<generic>
    5144:	mov    rsp,rbp
    5147:	pop    rbp
    5148:	ret

0000000000005149 <botlish_fn_28: hex_pair<generic>>:
    5149:	push   rbp
    514a:	mov    rbp,rsp
    514d:	sub    rsp,0x30
    5151:	mov    QWORD PTR [rsp],rbx
    5155:	mov    QWORD PTR [rsp+0x8],r12
    515a:	mov    QWORD PTR [rsp+0x10],r13
    515f:	mov    QWORD PTR [rsp+0x18],r14
    5164:	mov    QWORD PTR [rsp+0x20],r15
    5169:	mov    r13,rdx
    516c:	mov    rbx,QWORD PTR [rdi]
    516f:	mov    rax,QWORD PTR [rdi+0x8]
    5173:	lea    rcx,[rbx+0x10]
    5177:	cmp    rcx,rax
    517a:	ja     5383 <botlish_fn_28+0x23a>
    5180:	lea    rax,[rbx+0x10]
    5184:	mov    QWORD PTR [rdi],rax
    5187:	mov    rdx,r13
    518a:	mov    r12,rdi
    518d:	mov    QWORD PTR [rbx],rdx
    5190:	mov    rax,QWORD PTR [rsi+0x20]
    5194:	mov    r14,rsi
    5197:	mov    rsi,QWORD PTR [rax]
    519a:	mov    QWORD PTR [rbx+0x8],rsi
    519e:	mov    r15,rsi
    51a1:	mov    rsi,r13
    51a4:	mov    rdi,r12
    51a7:	call   51ac <botlish_fn_28+0x63>
			51a8: R_X86_64_PLT32	botlish_fn_26-0x4 ; high_nibble<generic>
    51ac:	test   rax,rax
    51af:	jne    51bd <botlish_fn_28+0x74>
    51b5:	mov    rdi,r12
    51b8:	jmp    5332 <botlish_fn_28+0x1e9>
    51bd:	test   rax,0x1
    51c3:	jne    51d4 <botlish_fn_28+0x8b>
    51c9:	mov    rdx,rax
    51cc:	mov    rsi,r15
    51cf:	jmp    51f0 <botlish_fn_28+0xa7>
    51d4:	mov    rsi,r15
    51d7:	mov    rdx,QWORD PTR [rsi+0x8]
    51db:	mov    rcx,rax
    51de:	sar    rcx,1
    51e1:	mov    rdi,rax
    51e4:	cmp    rcx,rdx
    51e7:	jb     5211 <botlish_fn_28+0xc8>
    51ed:	mov    rdx,rdi
    51f0:	mov    rdi,r12
    51f3:	call   51f8 <botlish_fn_28+0xaf>
			51f4: R_X86_64_PLT32	rt_list_get-0x4
    51f8:	test   rax,rax
    51fb:	jne    5209 <botlish_fn_28+0xc0>
    5201:	mov    rdi,r12
    5204:	jmp    5332 <botlish_fn_28+0x1e9>
    5209:	mov    rsi,rax
    520c:	jmp    5219 <botlish_fn_28+0xd0>
    5211:	mov    rax,QWORD PTR [rsi+0x10]
    5215:	mov    rsi,QWORD PTR [rax+rcx*8]
    5219:	mov    QWORD PTR [rbx],rsi
    521c:	mov    rax,rsi
    521f:	mov    rsi,r14
    5222:	mov    r14,rax
    5225:	mov    rdx,QWORD PTR [rsi+0x20]
    5229:	mov    rsi,QWORD PTR [rdx]
    522c:	mov    r15,rsi
    522f:	mov    ecx,0x1
    5234:	mov    rdx,r13
    5237:	test   rdx,0x1
    523e:	je     524c <botlish_fn_28+0x103>
    5244:	mov    r13,rdx
    5247:	jmp    5271 <botlish_fn_28+0x128>
    524c:	xor    ecx,ecx
    524e:	test   rdx,0x7
    5255:	je     5263 <botlish_fn_28+0x11a>
    525b:	mov    r13,rdx
    525e:	jmp    5271 <botlish_fn_28+0x128>
    5263:	movzx  r8,BYTE PTR [rdx]
    5267:	mov    r13,rdx
    526a:	cmp    r8b,0x1
    526e:	sete   cl
    5271:	test   cl,cl
    5273:	jne    529a <botlish_fn_28+0x151>
    5279:	mov    rdi,r12
    527c:	mov    rax,QWORD PTR [rdi+0x10]
    5280:	mov    rcx,QWORD PTR [rax+0x118]
    5287:	xor    rdx,rdx
    528a:	mov    rsi,r13
    528d:	call   5292 <botlish_fn_28+0x149>
			528e: R_X86_64_PLT32	rt_type_error-0x4
    5292:	mov    rdi,r12
    5295:	jmp    5332 <botlish_fn_28+0x1e9>
    529a:	mov    rsi,r13
    529d:	mov    edx,0x21
    52a2:	mov    rdi,r12
    52a5:	call   52aa <botlish_fn_28+0x161>
			52a6: R_X86_64_PLT32	rt_int_mod-0x4
    52aa:	test   rax,rax
    52ad:	jne    52bb <botlish_fn_28+0x172>
    52b3:	mov    rdi,r12
    52b6:	jmp    5332 <botlish_fn_28+0x1e9>
    52bb:	test   rax,0x1
    52c1:	jne    52d2 <botlish_fn_28+0x189>
    52c7:	mov    rdx,rax
    52ca:	mov    rsi,r15
    52cd:	jmp    52ee <botlish_fn_28+0x1a5>
    52d2:	mov    rsi,r15
    52d5:	mov    rdx,QWORD PTR [rsi+0x8]
    52d9:	mov    rcx,rax
    52dc:	sar    rcx,1
    52df:	mov    rdi,rax
    52e2:	cmp    rcx,rdx
    52e5:	jb     530f <botlish_fn_28+0x1c6>
    52eb:	mov    rdx,rdi
    52ee:	mov    rdi,r12
    52f1:	call   52f6 <botlish_fn_28+0x1ad>
			52f2: R_X86_64_PLT32	rt_list_get-0x4
    52f6:	test   rax,rax
    52f9:	jne    5307 <botlish_fn_28+0x1be>
    52ff:	mov    rdi,r12
    5302:	jmp    5332 <botlish_fn_28+0x1e9>
    5307:	mov    rdx,rax
    530a:	jmp    5317 <botlish_fn_28+0x1ce>
    530f:	mov    rax,QWORD PTR [rsi+0x10]
    5313:	mov    rdx,QWORD PTR [rax+rcx*8]
    5317:	mov    QWORD PTR [rbx+0x8],rdx
    531b:	mov    rsi,r14
    531e:	mov    rdi,r12
    5321:	call   5326 <botlish_fn_28+0x1dd>
			5322: R_X86_64_PLT32	rt_str_cat-0x4
    5326:	test   rax,rax
    5329:	jne    535c <botlish_fn_28+0x213>
    532f:	mov    rdi,r12
    5332:	mov    rdi,r12
    5335:	mov    QWORD PTR [rdi],rbx
    5338:	xor    rax,rax
    533b:	mov    rbx,QWORD PTR [rsp]
    533f:	mov    r12,QWORD PTR [rsp+0x8]
    5344:	mov    r13,QWORD PTR [rsp+0x10]
    5349:	mov    r14,QWORD PTR [rsp+0x18]
    534e:	mov    r15,QWORD PTR [rsp+0x20]
    5353:	add    rsp,0x30
    5357:	mov    rsp,rbp
    535a:	pop    rbp
    535b:	ret
    535c:	mov    rdi,r12
    535f:	mov    QWORD PTR [rdi],rbx
    5362:	mov    rbx,QWORD PTR [rsp]
    5366:	mov    r12,QWORD PTR [rsp+0x8]
    536b:	mov    r13,QWORD PTR [rsp+0x10]
    5370:	mov    r14,QWORD PTR [rsp+0x18]
    5375:	mov    r15,QWORD PTR [rsp+0x20]
    537a:	add    rsp,0x30
    537e:	mov    rsp,rbp
    5381:	pop    rbp
    5382:	ret
    5383:	mov    r12,rdi
    5386:	call   538b <botlish_fn_28+0x242>
			5387: R_X86_64_PLT32	rt_stack_overflow-0x4
    538b:	xor    rax,rax
    538e:	mov    rbx,QWORD PTR [rsp]
    5392:	mov    r12,QWORD PTR [rsp+0x8]
    5397:	mov    r13,QWORD PTR [rsp+0x10]
    539c:	mov    r14,QWORD PTR [rsp+0x18]
    53a1:	mov    r15,QWORD PTR [rsp+0x20]
    53a6:	add    rsp,0x30
    53aa:	mov    rsp,rbp
    53ad:	pop    rbp
    53ae:	ret

00000000000053af <botlish_entry_28: hex_pair<generic>>:
    53af:	push   rbp
    53b0:	mov    rbp,rsp
    53b3:	mov    rdx,QWORD PTR [rdx]
    53b6:	call   53bb <botlish_entry_28+0xc>
			53b7: R_X86_64_PLT32	botlish_fn_28-0x4 ; hex_pair<generic>
    53bb:	mov    rsp,rbp
    53be:	pop    rbp
    53bf:	ret

00000000000053c0 <botlish_fn_29: esc_bytes<generic>>:
    53c0:	push   rbp
    53c1:	mov    rbp,rsp
    53c4:	sub    rsp,0x50
    53c8:	mov    QWORD PTR [rsp+0x20],rbx
    53cd:	mov    QWORD PTR [rsp+0x28],r12
    53d2:	mov    QWORD PTR [rsp+0x30],r13
    53d7:	mov    QWORD PTR [rsp+0x38],r14
    53dc:	mov    QWORD PTR [rsp+0x40],r15
    53e1:	mov    r15,rsi
    53e4:	mov    r13,QWORD PTR [rdi]
    53e7:	mov    r9,QWORD PTR [rdi+0x8]
    53eb:	lea    r10,[r13+0x38]
    53ef:	cmp    r10,r9
    53f2:	ja     5732 <botlish_fn_29+0x372>
    53f8:	lea    r10,[r13+0x38]
    53fc:	mov    QWORD PTR [rdi],r10
    53ff:	mov    r14,rdi
    5402:	mov    QWORD PTR [r13+0x28],0x0
    540a:	mov    QWORD PTR [r13+0x30],0x0
    5412:	mov    QWORD PTR [r13+0x0],rdx
    5416:	mov    QWORD PTR [r13+0x8],rcx
    541a:	mov    QWORD PTR [r13+0x10],r8
    541e:	mov    QWORD PTR [rsp],rcx
    5422:	mov    QWORD PTR [rsp+0x8],r8
    5427:	xor    eax,eax
    5429:	test   rdx,0x7
    5430:	je     543e <botlish_fn_29+0x7e>
    5436:	mov    rsi,rdx
    5439:	jmp    544a <botlish_fn_29+0x8a>
    543e:	movzx  rax,BYTE PTR [rdx]
    5442:	mov    rsi,rdx
    5445:	cmp    al,0x3
    5447:	sete   al
    544a:	test   al,al
    544c:	jne    5472 <botlish_fn_29+0xb2>
    5452:	mov    rdi,r14
    5455:	mov    rax,QWORD PTR [rdi+0x10]
    5459:	mov    rcx,QWORD PTR [rax+0x120]
    5460:	mov    edx,0x4
    5465:	call   546a <botlish_fn_29+0xaa>
			5466: R_X86_64_PLT32	rt_type_error-0x4
    546a:	mov    rdi,r14
    546d:	jmp    56bd <botlish_fn_29+0x2fd>
    5472:	mov    rbx,rsi
    5475:	mov    rdi,r14
    5478:	call   547d <botlish_fn_29+0xbd>
			5479: R_X86_64_PLT32	rt_list_len-0x4
    547d:	mov    ecx,0x1
    5482:	mov    rsi,QWORD PTR [rsp]
    5486:	test   rsi,0x1
    548d:	jne    54b5 <botlish_fn_29+0xf5>
    5493:	xor    ecx,ecx
    5495:	mov    rsi,QWORD PTR [rsp]
    5499:	test   rsi,0x7
    54a0:	jne    54b5 <botlish_fn_29+0xf5>
    54a6:	mov    rsi,QWORD PTR [rsp]
    54aa:	movzx  rcx,BYTE PTR [rsi]
    54ae:	rex cmp cl,0x1
    54b2:	sete   cl
    54b5:	test   cl,cl
    54b7:	jne    54df <botlish_fn_29+0x11f>
    54bd:	mov    rdi,r14
    54c0:	mov    rax,QWORD PTR [rdi+0x10]
    54c4:	mov    rcx,QWORD PTR [rax+0x80]
    54cb:	xor    rdx,rdx
    54ce:	mov    rsi,QWORD PTR [rsp]
    54d2:	call   54d7 <botlish_fn_29+0x117>
			54d3: R_X86_64_PLT32	rt_type_error-0x4
    54d7:	mov    rdi,r14
    54da:	jmp    56bd <botlish_fn_29+0x2fd>
    54df:	mov    rsi,QWORD PTR [rsp]
    54e3:	mov    rcx,rsi
    54e6:	and    rcx,rax
    54e9:	mov    rdx,rax
    54ec:	test   rcx,0x1
    54f3:	jne    551a <botlish_fn_29+0x15a>
    54f9:	mov    rsi,QWORD PTR [rsp]
    54fd:	mov    rdi,r14
    5500:	call   5505 <botlish_fn_29+0x145>
			5501: R_X86_64_PLT32	rt_int_cmp-0x4
    5505:	mov    esi,0x2
    550a:	test   rax,rax
    550d:	cmovge rsi,QWORD PTR [rip+0x24b]        # 5760 <botlish_fn_29+0x3a0>
    5515:	jmp    552e <botlish_fn_29+0x16e>
    551a:	mov    esi,0x2
    551f:	mov    rax,QWORD PTR [rsp]
    5523:	cmp    rax,rdx
    5526:	cmovge rsi,QWORD PTR [rip+0x232]        # 5760 <botlish_fn_29+0x3a0>
    552e:	cmp    rsi,0x6
    5532:	je     5705 <botlish_fn_29+0x345>
    5538:	mov    QWORD PTR [r13+0x18],r15
    553c:	mov    QWORD PTR [r13+0x20],0x3
    5544:	mov    rsi,QWORD PTR [rsp]
    5548:	test   rsi,0x1
    554f:	je     5576 <botlish_fn_29+0x1b6>
    5555:	mov    rsi,QWORD PTR [rsp]
    5559:	mov    rax,rsi
    555c:	add    rax,0x2
    5560:	mov    rcx,rax
    5563:	seto   al
    5566:	test   al,al
    5568:	jne    5576 <botlish_fn_29+0x1b6>
    556e:	mov    r12,rcx
    5571:	jmp    558d <botlish_fn_29+0x1cd>
    5576:	mov    edx,0x3
    557b:	mov    rsi,QWORD PTR [rsp]
    557f:	mov    rdi,r14
    5582:	call   5587 <botlish_fn_29+0x1c7>
			5583: R_X86_64_PLT32	rt_int_add-0x4
    5587:	mov    rcx,rax
    558a:	mov    r12,rcx
    558d:	mov    QWORD PTR [r13+0x8],r12
    5591:	mov    rdi,r14
    5594:	mov    rax,QWORD PTR [rdi+0x10]
    5598:	mov    rsi,QWORD PTR [rax+0x70]
    559c:	mov    QWORD PTR [r13+0x20],rsi
    55a0:	mov    QWORD PTR [rsp+0x18],rsi
    55a5:	mov    rax,QWORD PTR [r15+0x20]
    55a9:	mov    rsi,QWORD PTR [rax]
    55ac:	mov    QWORD PTR [r13+0x28],rsi
    55b0:	mov    QWORD PTR [rsp+0x10],rsi
    55b5:	mov    rsi,QWORD PTR [rsp]
    55b9:	test   rsi,0x1
    55c0:	jne    55cf <botlish_fn_29+0x20f>
    55c6:	mov    rdx,QWORD PTR [rsp]
    55ca:	jmp    55ea <botlish_fn_29+0x22a>
    55cf:	mov    rcx,QWORD PTR [rbx+0x8]
    55d3:	mov    rsi,QWORD PTR [rsp]
    55d7:	mov    rax,rsi
    55da:	sar    rax,1
    55dd:	cmp    rax,rcx
    55e0:	jb     560e <botlish_fn_29+0x24e>
    55e6:	mov    rdx,QWORD PTR [rsp]
    55ea:	mov    rsi,rbx
    55ed:	mov    rdi,r14
    55f0:	call   55f5 <botlish_fn_29+0x235>
			55f1: R_X86_64_PLT32	rt_list_get-0x4
    55f5:	test   rax,rax
    55f8:	jne    5606 <botlish_fn_29+0x246>
    55fe:	mov    rdi,r14
    5601:	jmp    56bd <botlish_fn_29+0x2fd>
    5606:	mov    rdx,rax
    5609:	jmp    5616 <botlish_fn_29+0x256>
    560e:	mov    rsi,QWORD PTR [rbx+0x10]
    5612:	mov    rdx,QWORD PTR [rsi+rax*8]
    5616:	mov    QWORD PTR [r13+0x30],rdx
    561a:	mov    rsi,QWORD PTR [rsp+0x10]
    561f:	mov    rdi,r14
    5622:	call   5627 <botlish_fn_29+0x267>
			5623: R_X86_64_PLT32	botlish_fn_28-0x4 ; hex_pair<generic>
    5627:	test   rax,rax
    562a:	jne    5638 <botlish_fn_29+0x278>
    5630:	mov    rdi,r14
    5633:	jmp    56bd <botlish_fn_29+0x2fd>
    5638:	mov    QWORD PTR [r13+0x28],rax
    563c:	mov    rdx,rax
    563f:	mov    rsi,QWORD PTR [rsp+0x18]
    5644:	mov    rdi,r14
    5647:	call   564c <botlish_fn_29+0x28c>
			5648: R_X86_64_PLT32	rt_str_cat-0x4
    564c:	test   rax,rax
    564f:	jne    565d <botlish_fn_29+0x29d>
    5655:	mov    rdi,r14
    5658:	jmp    56bd <botlish_fn_29+0x2fd>
    565d:	mov    QWORD PTR [r13+0x20],rax
    5661:	mov    rdx,rax
    5664:	xor    eax,eax
    5666:	mov    rsi,QWORD PTR [rsp+0x8]
    566b:	test   rsi,0x7
    5672:	jne    5681 <botlish_fn_29+0x2c1>
    5678:	movzx  rax,BYTE PTR [rsi]
    567c:	cmp    al,0x2
    567e:	sete   al
    5681:	test   al,al
    5683:	jne    56a9 <botlish_fn_29+0x2e9>
    5689:	mov    rdi,r14
    568c:	mov    rax,QWORD PTR [rdi+0x10]
    5690:	mov    rcx,QWORD PTR [rax+0x128]
    5697:	mov    edx,0x1
    569c:	call   56a1 <botlish_fn_29+0x2e1>
			569d: R_X86_64_PLT32	rt_type_error-0x4
    56a1:	mov    rdi,r14
    56a4:	jmp    56bd <botlish_fn_29+0x2fd>
    56a9:	mov    rdi,r14
    56ac:	call   56b1 <botlish_fn_29+0x2f1>
			56ad: R_X86_64_PLT32	rt_str_cat-0x4
    56b1:	test   rax,rax
    56b4:	jne    56e8 <botlish_fn_29+0x328>
    56ba:	mov    rdi,r14
    56bd:	mov    rdi,r14
    56c0:	mov    QWORD PTR [rdi],r13
    56c3:	xor    rax,rax
    56c6:	mov    rbx,QWORD PTR [rsp+0x20]
    56cb:	mov    r12,QWORD PTR [rsp+0x28]
    56d0:	mov    r13,QWORD PTR [rsp+0x30]
    56d5:	mov    r14,QWORD PTR [rsp+0x38]
    56da:	mov    r15,QWORD PTR [rsp+0x40]
    56df:	add    rsp,0x50
    56e3:	mov    rsp,rbp
    56e6:	pop    rbp
    56e7:	ret
    56e8:	mov    QWORD PTR [r13+0x0],rbx
    56ec:	mov    QWORD PTR [r13+0x8],r12
    56f0:	mov    QWORD PTR [r13+0x10],rax
    56f4:	mov    rdx,rbx
    56f7:	mov    QWORD PTR [rsp],r12
    56fb:	mov    QWORD PTR [rsp+0x8],rax
    5700:	jmp    5427 <botlish_fn_29+0x67>
    5705:	mov    rdi,r14
    5708:	mov    QWORD PTR [rdi],r13
    570b:	mov    rax,QWORD PTR [rsp+0x8]
    5710:	mov    rbx,QWORD PTR [rsp+0x20]
    5715:	mov    r12,QWORD PTR [rsp+0x28]
    571a:	mov    r13,QWORD PTR [rsp+0x30]
    571f:	mov    r14,QWORD PTR [rsp+0x38]
    5724:	mov    r15,QWORD PTR [rsp+0x40]
    5729:	add    rsp,0x50
    572d:	mov    rsp,rbp
    5730:	pop    rbp
    5731:	ret
    5732:	mov    r14,rdi
    5735:	call   573a <botlish_fn_29+0x37a>
			5736: R_X86_64_PLT32	rt_stack_overflow-0x4
    573a:	xor    rax,rax
    573d:	mov    rbx,QWORD PTR [rsp+0x20]
    5742:	mov    r12,QWORD PTR [rsp+0x28]
    5747:	mov    r13,QWORD PTR [rsp+0x30]
    574c:	mov    r14,QWORD PTR [rsp+0x38]
    5751:	mov    r15,QWORD PTR [rsp+0x40]
    5756:	add    rsp,0x50
    575a:	mov    rsp,rbp
    575d:	pop    rbp
    575e:	ret
    575f:	add    BYTE PTR [rsi],al
    5761:	add    BYTE PTR [rax],al
    5763:	add    BYTE PTR [rax],al
    5765:	add    BYTE PTR [rax],al
	...

0000000000005768 <botlish_entry_29: esc_bytes<generic>>:
    5768:	push   rbp
    5769:	mov    rbp,rsp
    576c:	mov    r9,QWORD PTR [rdx]
    576f:	mov    rcx,QWORD PTR [rdx+0x8]
    5773:	mov    r8,QWORD PTR [rdx+0x10]
    5777:	mov    rdx,r9
    577a:	call   577f <botlish_entry_29+0x17>
			577b: R_X86_64_PLT32	botlish_fn_29-0x4 ; esc_bytes<generic>
    577f:	mov    rsp,rbp
    5782:	pop    rbp
    5783:	ret

0000000000005784 <botlish_fn_30: esc_char<generic>>:
    5784:	push   rbp
    5785:	mov    rbp,rsp
    5788:	sub    rsp,0x40
    578c:	mov    QWORD PTR [rsp+0x10],rbx
    5791:	mov    QWORD PTR [rsp+0x18],r12
    5796:	mov    QWORD PTR [rsp+0x20],r13
    579b:	mov    QWORD PTR [rsp+0x28],r14
    57a0:	mov    QWORD PTR [rsp+0x30],r15
    57a5:	mov    rbx,rsi
    57a8:	mov    r12,QWORD PTR [rdi]
    57ab:	mov    rax,QWORD PTR [rdi+0x8]
    57af:	lea    rcx,[r12+0x20]
    57b4:	cmp    rcx,rax
    57b7:	ja     59d2 <botlish_fn_30+0x24e>
    57bd:	lea    rax,[r12+0x20]
    57c2:	mov    QWORD PTR [rdi],rax
    57c5:	mov    QWORD PTR [r12+0x8],0x0
    57ce:	mov    QWORD PTR [r12+0x10],0x0
    57d7:	mov    QWORD PTR [r12+0x18],0x0
    57e0:	mov    QWORD PTR [r12],rdx
    57e4:	xor    eax,eax
    57e6:	test   rdx,0x7
    57ed:	je     57fb <botlish_fn_30+0x77>
    57f3:	mov    r14,rdx
    57f6:	jmp    5807 <botlish_fn_30+0x83>
    57fb:	movzx  rax,BYTE PTR [rdx]
    57ff:	mov    r14,rdx
    5802:	cmp    al,0x2
    5804:	sete   al
    5807:	test   al,al
    5809:	jne    5832 <botlish_fn_30+0xae>
    580f:	mov    rax,QWORD PTR [rdi+0x10]
    5813:	mov    r13,rdi
    5816:	mov    rcx,QWORD PTR [rax+0x130]
    581d:	mov    edx,0x1
    5822:	mov    rsi,r14
    5825:	call   582a <botlish_fn_30+0xa6>
			5826: R_X86_64_PLT32	rt_type_error-0x4
    582a:	mov    rdi,r13
    582d:	jmp    5974 <botlish_fn_30+0x1f0>
    5832:	mov    r13,rdi
    5835:	mov    rsi,r14
    5838:	call   583d <botlish_fn_30+0xb9>
			5839: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    583d:	mov    rcx,rax
    5840:	mov    r15,rax
    5843:	test   rax,rcx
    5846:	jne    5854 <botlish_fn_30+0xd0>
    584c:	mov    rdi,r13
    584f:	jmp    5974 <botlish_fn_30+0x1f0>
    5854:	mov    rax,r15
    5857:	mov    QWORD PTR [r12+0x8],rax
    585c:	mov    rsi,r15
    585f:	mov    rdi,r13
    5862:	call   5867 <botlish_fn_30+0xe3>
			5863: R_X86_64_PLT32	rt_list_len-0x4
    5867:	mov    ecx,0x1
    586c:	sar    rax,1
    586f:	cmp    rax,0x1
    5873:	je     58c4 <botlish_fn_30+0x140>
    5879:	mov    rdx,QWORD PTR [rbx+0x20]
    587d:	mov    rsi,QWORD PTR [rdx]
    5880:	mov    QWORD PTR [r12],rsi
    5884:	mov    QWORD PTR [r12+0x10],0x1
    588d:	mov    rdi,r13
    5890:	mov    rdi,QWORD PTR [rdi+0x10]
    5894:	mov    r8,QWORD PTR [rdi+0x108]
    589b:	mov    QWORD PTR [r12+0x18],r8
    58a0:	mov    rdx,r15
    58a3:	mov    rdi,r13
    58a6:	call   58ab <botlish_fn_30+0x127>
			58a7: R_X86_64_PLT32	botlish_fn_29-0x4 ; esc_bytes<generic>
    58ab:	test   rax,rax
    58ae:	jne    58bc <botlish_fn_30+0x138>
    58b4:	mov    rdi,r13
    58b7:	jmp    5974 <botlish_fn_30+0x1f0>
    58bc:	mov    rdi,r13
    58bf:	jmp    59aa <botlish_fn_30+0x226>
    58c4:	mov    rdx,r15
    58c7:	mov    QWORD PTR [rsp],rcx
    58cb:	mov    r10,QWORD PTR [rdx+0x8]
    58cf:	mov    r15,rdx
    58d2:	test   r10,r10
    58d5:	jne    5903 <botlish_fn_30+0x17f>
    58db:	mov    rdx,QWORD PTR [rsp]
    58df:	mov    rsi,r15
    58e2:	mov    rdi,r13
    58e5:	call   58ea <botlish_fn_30+0x166>
			58e6: R_X86_64_PLT32	rt_list_get-0x4
    58ea:	test   rax,rax
    58ed:	jne    58fb <botlish_fn_30+0x177>
    58f3:	mov    rdi,r13
    58f6:	jmp    5974 <botlish_fn_30+0x1f0>
    58fb:	mov    rsi,rax
    58fe:	jmp    590d <botlish_fn_30+0x189>
    5903:	mov    rdx,r15
    5906:	mov    rax,QWORD PTR [rdx+0x10]
    590a:	mov    rsi,QWORD PTR [rax]
    590d:	mov    QWORD PTR [r12+0x10],rsi
    5912:	mov    rdi,r13
    5915:	call   591a <botlish_fn_30+0x196>
			5916: R_X86_64_PLT32	botlish_fn_27-0x4 ; is_unreserved<generic>
    591a:	test   rax,rax
    591d:	jne    592b <botlish_fn_30+0x1a7>
    5923:	mov    rdi,r13
    5926:	jmp    5974 <botlish_fn_30+0x1f0>
    592b:	cmp    rax,0x6
    592f:	je     59a4 <botlish_fn_30+0x220>
    5935:	mov    rax,QWORD PTR [rbx+0x20]
    5939:	mov    rsi,QWORD PTR [rax]
    593c:	mov    QWORD PTR [r12],rsi
    5940:	mov    QWORD PTR [r12+0x10],0x1
    5949:	mov    rdi,r13
    594c:	mov    rax,QWORD PTR [rdi+0x10]
    5950:	mov    r8,QWORD PTR [rax+0x108]
    5957:	mov    QWORD PTR [r12+0x18],r8
    595c:	mov    rcx,QWORD PTR [rsp]
    5960:	mov    rdx,r15
    5963:	call   5968 <botlish_fn_30+0x1e4>
			5964: R_X86_64_PLT32	botlish_fn_29-0x4 ; esc_bytes<generic>
    5968:	test   rax,rax
    596b:	jne    59a7 <botlish_fn_30+0x223>
    5971:	mov    rdi,r13
    5974:	mov    rdi,r13
    5977:	mov    QWORD PTR [rdi],r12
    597a:	xor    rax,rax
    597d:	mov    rbx,QWORD PTR [rsp+0x10]
    5982:	mov    r12,QWORD PTR [rsp+0x18]
    5987:	mov    r13,QWORD PTR [rsp+0x20]
    598c:	mov    r14,QWORD PTR [rsp+0x28]
    5991:	mov    r15,QWORD PTR [rsp+0x30]
    5996:	add    rsp,0x40
    599a:	mov    rsp,rbp
    599d:	pop    rbp
    599e:	ret
    599f:	jmp    59a7 <botlish_fn_30+0x223>
    59a4:	mov    rax,r14
    59a7:	mov    rdi,r13
    59aa:	mov    rdi,r13
    59ad:	mov    QWORD PTR [rdi],r12
    59b0:	mov    rbx,QWORD PTR [rsp+0x10]
    59b5:	mov    r12,QWORD PTR [rsp+0x18]
    59ba:	mov    r13,QWORD PTR [rsp+0x20]
    59bf:	mov    r14,QWORD PTR [rsp+0x28]
    59c4:	mov    r15,QWORD PTR [rsp+0x30]
    59c9:	add    rsp,0x40
    59cd:	mov    rsp,rbp
    59d0:	pop    rbp
    59d1:	ret
    59d2:	mov    r13,rdi
    59d5:	call   59da <botlish_fn_30+0x256>
			59d6: R_X86_64_PLT32	rt_stack_overflow-0x4
    59da:	xor    rax,rax
    59dd:	mov    rbx,QWORD PTR [rsp+0x10]
    59e2:	mov    r12,QWORD PTR [rsp+0x18]
    59e7:	mov    r13,QWORD PTR [rsp+0x20]
    59ec:	mov    r14,QWORD PTR [rsp+0x28]
    59f1:	mov    r15,QWORD PTR [rsp+0x30]
    59f6:	add    rsp,0x40
    59fa:	mov    rsp,rbp
    59fd:	pop    rbp
    59fe:	ret

00000000000059ff <botlish_entry_30: esc_char<generic>>:
    59ff:	push   rbp
    5a00:	mov    rbp,rsp
    5a03:	mov    rdx,QWORD PTR [rdx]
    5a06:	call   5a0b <botlish_entry_30+0xc>
			5a07: R_X86_64_PLT32	botlish_fn_30-0x4 ; esc_char<generic>
    5a0b:	mov    rsp,rbp
    5a0e:	pop    rbp
    5a0f:	ret

0000000000005a10 <botlish_fn_31: esc_from<generic>>:
    5a10:	push   rbp
    5a11:	mov    rbp,rsp
    5a14:	sub    rsp,0x50
    5a18:	mov    QWORD PTR [rsp+0x20],rbx
    5a1d:	mov    QWORD PTR [rsp+0x28],r12
    5a22:	mov    QWORD PTR [rsp+0x30],r13
    5a27:	mov    QWORD PTR [rsp+0x38],r14
    5a2c:	mov    QWORD PTR [rsp+0x40],r15
    5a31:	mov    r12,rsi
    5a34:	mov    r14,QWORD PTR [rdi]
    5a37:	mov    rax,QWORD PTR [rdi+0x8]
    5a3b:	lea    rsi,[r14+0x38]
    5a3f:	cmp    rsi,rax
    5a42:	ja     5dae <botlish_fn_31+0x39e>
    5a48:	lea    rax,[r14+0x38]
    5a4c:	mov    QWORD PTR [rdi],rax
    5a4f:	mov    r15,rdi
    5a52:	mov    QWORD PTR [r14+0x28],0x0
    5a5a:	mov    QWORD PTR [r14+0x30],0x0
    5a62:	mov    QWORD PTR [r14],rdx
    5a65:	mov    QWORD PTR [r14+0x8],rcx
    5a69:	mov    QWORD PTR [r14+0x10],r8
    5a6d:	mov    QWORD PTR [rsp],rcx
    5a71:	mov    QWORD PTR [rsp+0x8],r8
    5a76:	xor    eax,eax
    5a78:	test   rdx,0x7
    5a7f:	je     5a8d <botlish_fn_31+0x7d>
    5a85:	mov    rsi,rdx
    5a88:	jmp    5a99 <botlish_fn_31+0x89>
    5a8d:	movzx  rax,BYTE PTR [rdx]
    5a91:	mov    rsi,rdx
    5a94:	cmp    al,0x2
    5a96:	sete   al
    5a99:	test   al,al
    5a9b:	jne    5abe <botlish_fn_31+0xae>
    5aa1:	mov    rdi,r15
    5aa4:	mov    rax,QWORD PTR [rdi+0x10]
    5aa8:	mov    rcx,QWORD PTR [rax+0x48]
    5aac:	mov    edx,0x1
    5ab1:	call   5ab6 <botlish_fn_31+0xa6>
			5ab2: R_X86_64_PLT32	rt_type_error-0x4
    5ab6:	mov    rdi,r15
    5ab9:	jmp    5d3a <botlish_fn_31+0x32a>
    5abe:	mov    rbx,rsi
    5ac1:	mov    rdi,r15
    5ac4:	call   5ac9 <botlish_fn_31+0xb9>
			5ac5: R_X86_64_PLT32	rt_str_len-0x4
    5ac9:	mov    edx,0x1
    5ace:	mov    QWORD PTR [rsp+0x18],rdx
    5ad3:	mov    ecx,0x1
    5ad8:	mov    rsi,QWORD PTR [rsp]
    5adc:	test   rsi,0x1
    5ae3:	jne    5b0b <botlish_fn_31+0xfb>
    5ae9:	xor    ecx,ecx
    5aeb:	mov    rsi,QWORD PTR [rsp]
    5aef:	test   rsi,0x7
    5af6:	jne    5b0b <botlish_fn_31+0xfb>
    5afc:	mov    rsi,QWORD PTR [rsp]
    5b00:	movzx  rcx,BYTE PTR [rsi]
    5b04:	rex cmp cl,0x1
    5b08:	sete   cl
    5b0b:	test   cl,cl
    5b0d:	jne    5b35 <botlish_fn_31+0x125>
    5b13:	mov    rdi,r15
    5b16:	mov    rax,QWORD PTR [rdi+0x10]
    5b1a:	mov    rcx,QWORD PTR [rax+0x80]
    5b21:	xor    rdx,rdx
    5b24:	mov    rsi,QWORD PTR [rsp]
    5b28:	call   5b2d <botlish_fn_31+0x11d>
			5b29: R_X86_64_PLT32	rt_type_error-0x4
    5b2d:	mov    rdi,r15
    5b30:	jmp    5d3a <botlish_fn_31+0x32a>
    5b35:	mov    rsi,QWORD PTR [rsp]
    5b39:	mov    rcx,rsi
    5b3c:	and    rcx,rax
    5b3f:	mov    rdx,rax
    5b42:	test   rcx,0x1
    5b49:	jne    5b70 <botlish_fn_31+0x160>
    5b4f:	mov    rsi,QWORD PTR [rsp]
    5b53:	mov    rdi,r15
    5b56:	call   5b5b <botlish_fn_31+0x14b>
			5b57: R_X86_64_PLT32	rt_int_cmp-0x4
    5b5b:	mov    esi,0x2
    5b60:	test   rax,rax
    5b63:	cmovge rsi,QWORD PTR [rip+0x275]        # 5de0 <botlish_fn_31+0x3d0>
    5b6b:	jmp    5b84 <botlish_fn_31+0x174>
    5b70:	mov    esi,0x2
    5b75:	mov    rax,QWORD PTR [rsp]
    5b79:	cmp    rax,rdx
    5b7c:	cmovge rsi,QWORD PTR [rip+0x25c]        # 5de0 <botlish_fn_31+0x3d0>
    5b84:	cmp    rsi,0x6
    5b88:	je     5d81 <botlish_fn_31+0x371>
    5b8e:	mov    QWORD PTR [r14+0x18],r12
    5b92:	mov    QWORD PTR [r14+0x20],0x3
    5b9a:	mov    rsi,QWORD PTR [rsp]
    5b9e:	test   rsi,0x1
    5ba5:	je     5bcc <botlish_fn_31+0x1bc>
    5bab:	mov    rsi,QWORD PTR [rsp]
    5baf:	mov    rax,rsi
    5bb2:	add    rax,0x2
    5bb6:	mov    rcx,rax
    5bb9:	seto   al
    5bbc:	test   al,al
    5bbe:	jne    5bcc <botlish_fn_31+0x1bc>
    5bc4:	mov    r13,rcx
    5bc7:	jmp    5be3 <botlish_fn_31+0x1d3>
    5bcc:	mov    edx,0x3
    5bd1:	mov    rsi,QWORD PTR [rsp]
    5bd5:	mov    rdi,r15
    5bd8:	call   5bdd <botlish_fn_31+0x1cd>
			5bd9: R_X86_64_PLT32	rt_int_add-0x4
    5bdd:	mov    rcx,rax
    5be0:	mov    r13,rcx
    5be3:	mov    QWORD PTR [r14+0x20],r13
    5be7:	mov    rax,QWORD PTR [r12+0x20]
    5bec:	mov    rsi,QWORD PTR [rax]
    5bef:	mov    QWORD PTR [r14+0x28],rsi
    5bf3:	mov    QWORD PTR [rsp+0x10],rsi
    5bf8:	mov    QWORD PTR [r14+0x30],0x3
    5c00:	mov    rsi,QWORD PTR [rsp]
    5c04:	test   rsi,0x1
    5c0b:	je     5c29 <botlish_fn_31+0x219>
    5c11:	mov    rsi,QWORD PTR [rsp]
    5c15:	mov    rcx,rsi
    5c18:	add    rcx,0x2
    5c1c:	seto   sil
    5c20:	test   sil,sil
    5c23:	je     5c3d <botlish_fn_31+0x22d>
    5c29:	mov    edx,0x3
    5c2e:	mov    rsi,QWORD PTR [rsp]
    5c32:	mov    rdi,r15
    5c35:	call   5c3a <botlish_fn_31+0x22a>
			5c36: R_X86_64_PLT32	rt_int_add-0x4
    5c3a:	mov    rcx,rax
    5c3d:	mov    QWORD PTR [r14+0x30],rcx
    5c41:	mov    rdx,QWORD PTR [rsp]
    5c45:	mov    rsi,rbx
    5c48:	mov    rdi,r15
    5c4b:	call   5c50 <botlish_fn_31+0x240>
			5c4c: R_X86_64_PLT32	rt_substr-0x4
    5c50:	test   rax,rax
    5c53:	jne    5c61 <botlish_fn_31+0x251>
    5c59:	mov    rdi,r15
    5c5c:	jmp    5d3a <botlish_fn_31+0x32a>
    5c61:	mov    QWORD PTR [r14+0x8],rax
    5c65:	mov    rdx,rax
    5c68:	mov    rsi,QWORD PTR [rsp+0x10]
    5c6d:	mov    rdi,r15
    5c70:	call   5c75 <botlish_fn_31+0x265>
			5c71: R_X86_64_PLT32	botlish_fn_30-0x4 ; esc_char<generic>
    5c75:	test   rax,rax
    5c78:	jne    5c86 <botlish_fn_31+0x276>
    5c7e:	mov    rdi,r15
    5c81:	jmp    5d3a <botlish_fn_31+0x32a>
    5c86:	mov    QWORD PTR [r14+0x8],rax
    5c8a:	xor    ecx,ecx
    5c8c:	mov    rsi,QWORD PTR [rsp+0x8]
    5c91:	test   rsi,0x7
    5c98:	jne    5ca9 <botlish_fn_31+0x299>
    5c9e:	movzx  rcx,BYTE PTR [rsi]
    5ca2:	rex cmp cl,0x2
    5ca6:	sete   cl
    5ca9:	test   cl,cl
    5cab:	jne    5cd1 <botlish_fn_31+0x2c1>
    5cb1:	mov    rdi,r15
    5cb4:	mov    rax,QWORD PTR [rdi+0x10]
    5cb8:	mov    rcx,QWORD PTR [rax+0x128]
    5cbf:	mov    rdx,QWORD PTR [rsp+0x18]
    5cc4:	call   5cc9 <botlish_fn_31+0x2b9>
			5cc5: R_X86_64_PLT32	rt_type_error-0x4
    5cc9:	mov    rdi,r15
    5ccc:	jmp    5d3a <botlish_fn_31+0x32a>
    5cd1:	mov    rdx,QWORD PTR [rsp+0x18]
    5cd6:	xor    r11d,r11d
    5cd9:	test   rax,0x7
    5cdf:	je     5ced <botlish_fn_31+0x2dd>
    5ce5:	mov    r8,rax
    5ce8:	jmp    5cfc <botlish_fn_31+0x2ec>
    5ced:	movzx  rcx,BYTE PTR [rax]
    5cf1:	mov    r8,rax
    5cf4:	rex cmp cl,0x2
    5cf8:	sete   r11b
    5cfc:	test   r11b,r11b
    5cff:	jne    5d23 <botlish_fn_31+0x313>
    5d05:	mov    rdi,r15
    5d08:	mov    rax,QWORD PTR [rdi+0x10]
    5d0c:	mov    rcx,QWORD PTR [rax+0x128]
    5d13:	mov    rsi,r8
    5d16:	call   5d1b <botlish_fn_31+0x30b>
			5d17: R_X86_64_PLT32	rt_type_error-0x4
    5d1b:	mov    rdi,r15
    5d1e:	jmp    5d3a <botlish_fn_31+0x32a>
    5d23:	mov    rdx,r8
    5d26:	mov    rdi,r15
    5d29:	call   5d2e <botlish_fn_31+0x31e>
			5d2a: R_X86_64_PLT32	rt_str_cat-0x4
    5d2e:	test   rax,rax
    5d31:	jne    5d65 <botlish_fn_31+0x355>
    5d37:	mov    rdi,r15
    5d3a:	mov    rdi,r15
    5d3d:	mov    QWORD PTR [rdi],r14
    5d40:	xor    rax,rax
    5d43:	mov    rbx,QWORD PTR [rsp+0x20]
    5d48:	mov    r12,QWORD PTR [rsp+0x28]
    5d4d:	mov    r13,QWORD PTR [rsp+0x30]
    5d52:	mov    r14,QWORD PTR [rsp+0x38]
    5d57:	mov    r15,QWORD PTR [rsp+0x40]
    5d5c:	add    rsp,0x50
    5d60:	mov    rsp,rbp
    5d63:	pop    rbp
    5d64:	ret
    5d65:	mov    QWORD PTR [r14],rbx
    5d68:	mov    QWORD PTR [r14+0x8],r13
    5d6c:	mov    QWORD PTR [r14+0x10],rax
    5d70:	mov    rdx,rbx
    5d73:	mov    QWORD PTR [rsp],r13
    5d77:	mov    QWORD PTR [rsp+0x8],rax
    5d7c:	jmp    5a76 <botlish_fn_31+0x66>
    5d81:	mov    rdi,r15
    5d84:	mov    QWORD PTR [rdi],r14
    5d87:	mov    rax,QWORD PTR [rsp+0x8]
    5d8c:	mov    rbx,QWORD PTR [rsp+0x20]
    5d91:	mov    r12,QWORD PTR [rsp+0x28]
    5d96:	mov    r13,QWORD PTR [rsp+0x30]
    5d9b:	mov    r14,QWORD PTR [rsp+0x38]
    5da0:	mov    r15,QWORD PTR [rsp+0x40]
    5da5:	add    rsp,0x50
    5da9:	mov    rsp,rbp
    5dac:	pop    rbp
    5dad:	ret
    5dae:	mov    r15,rdi
    5db1:	call   5db6 <botlish_fn_31+0x3a6>
			5db2: R_X86_64_PLT32	rt_stack_overflow-0x4
    5db6:	xor    rax,rax
    5db9:	mov    rbx,QWORD PTR [rsp+0x20]
    5dbe:	mov    r12,QWORD PTR [rsp+0x28]
    5dc3:	mov    r13,QWORD PTR [rsp+0x30]
    5dc8:	mov    r14,QWORD PTR [rsp+0x38]
    5dcd:	mov    r15,QWORD PTR [rsp+0x40]
    5dd2:	add    rsp,0x50
    5dd6:	mov    rsp,rbp
    5dd9:	pop    rbp
    5dda:	ret
    5ddb:	add    BYTE PTR [rax],al
    5ddd:	add    BYTE PTR [rax],al
    5ddf:	add    BYTE PTR [rsi],al
    5de1:	add    BYTE PTR [rax],al
    5de3:	add    BYTE PTR [rax],al
    5de5:	add    BYTE PTR [rax],al
	...

0000000000005de8 <botlish_entry_31: esc_from<generic>>:
    5de8:	push   rbp
    5de9:	mov    rbp,rsp
    5dec:	mov    r9,QWORD PTR [rdx]
    5def:	mov    rcx,QWORD PTR [rdx+0x8]
    5df3:	mov    r8,QWORD PTR [rdx+0x10]
    5df7:	mov    rdx,r9
    5dfa:	call   5dff <botlish_entry_31+0x17>
			5dfb: R_X86_64_PLT32	botlish_fn_31-0x4 ; esc_from<generic>
    5dff:	mov    rsp,rbp
    5e02:	pop    rbp
    5e03:	ret

; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 26317  (per function: 460 624 1313 1385 544 597 499 270 625 625 625 681 793 1305 1369 544 597 499 270 625 625 625 681 793 1216 1216 1817 1521 687 1068 694 1124)
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
      2a:	ja     188 <botlish_fn_0+0x188>
      30:	lea    rax,[rbx+0x28]
      34:	mov    QWORD PTR [rdi],rax
      37:	mov    QWORD PTR [rbx],0x0
      3e:	mov    QWORD PTR [rbx+0x8],0x0
      46:	mov    QWORD PTR [rbx+0x10],0x0
      4e:	mov    QWORD PTR [rbx+0x18],0x0
      56:	mov    QWORD PTR [rbx+0x20],0x0
      5e:	mov    rax,QWORD PTR [rdi+0x10]
      62:	mov    r13,rdi
      65:	mov    rcx,QWORD PTR [rax]
      68:	mov    rsi,QWORD PTR [rax+0x8]
      6c:	mov    QWORD PTR [rbx],rsi
      6f:	call   74 <botlish_fn_0+0x74>
			70: R_X86_64_PLT32	botlish_fn_24-0x4 ; <str>
      74:	test   rax,rax
      77:	jne    85 <botlish_fn_0+0x85>
      7d:	mov    rdi,r13
      80:	jmp    13f <botlish_fn_0+0x13f>
      85:	mov    QWORD PTR [rbx],rax
      88:	mov    r14,rax
      8b:	mov    esi,0x321
      90:	mov    QWORD PTR [rbx+0x8],0x321
      98:	mov    edx,0x1
      9d:	mov    QWORD PTR [rbx+0x10],0x1
      a5:	mov    rdi,r13
      a8:	mov    rcx,QWORD PTR [rdi+0x10]
      ac:	mov    rcx,QWORD PTR [rcx+0x10]
      b0:	mov    QWORD PTR [rbx+0x18],rcx
      b4:	mov    r8,r14
      b7:	call   bc <botlish_fn_0+0xbc>
			b8: R_X86_64_PLT32	botlish_fn_1-0x4 ; check<int, int, str, str>
      bc:	mov    r12,rax
      bf:	test   r12,r12
      c2:	jne    d0 <botlish_fn_0+0xd0>
      c8:	mov    rdi,r13
      cb:	jmp    13f <botlish_fn_0+0x13f>
      d0:	mov    QWORD PTR [rbx+0x8],r12
      d4:	mov    esi,0x321
      d9:	mov    QWORD PTR [rbx+0x10],0x321
      e1:	mov    edx,0x1
      e6:	mov    QWORD PTR [rbx+0x18],0x1
      ee:	mov    rdi,r13
      f1:	mov    rax,QWORD PTR [rdi+0x10]
      f5:	mov    rcx,QWORD PTR [rax+0x18]
      f9:	mov    QWORD PTR [rbx+0x20],rcx
      fd:	mov    r8,r14
     100:	call   105 <botlish_fn_0+0x105>
			101: R_X86_64_PLT32	botlish_fn_1-0x4 ; check<int, int, str, str>
     105:	test   rax,rax
     108:	jne    116 <botlish_fn_0+0x116>
     10e:	mov    rdi,r13
     111:	jmp    13f <botlish_fn_0+0x13f>
     116:	mov    QWORD PTR [rbx],rax
     119:	lea    rdx,[rsp]
     11d:	mov    QWORD PTR [rsp],r12
     121:	mov    QWORD PTR [rsp+0x8],rax
     126:	mov    esi,0x2
     12b:	mov    rdi,r13
     12e:	call   133 <botlish_fn_0+0x133>
			12f: R_X86_64_PLT32	rt_list_new-0x4
     133:	test   rax,rax
     136:	jne    165 <botlish_fn_0+0x165>
     13c:	mov    rdi,r13
     13f:	mov    rdi,r13
     142:	mov    QWORD PTR [rdi],rbx
     145:	xor    rax,rax
     148:	mov    rbx,QWORD PTR [rsp+0x10]
     14d:	mov    r12,QWORD PTR [rsp+0x18]
     152:	mov    r13,QWORD PTR [rsp+0x20]
     157:	mov    r14,QWORD PTR [rsp+0x28]
     15c:	add    rsp,0x30
     160:	mov    rsp,rbp
     163:	pop    rbp
     164:	ret
     165:	mov    rdi,r13
     168:	mov    QWORD PTR [rdi],rbx
     16b:	mov    rbx,QWORD PTR [rsp+0x10]
     170:	mov    r12,QWORD PTR [rsp+0x18]
     175:	mov    r13,QWORD PTR [rsp+0x20]
     17a:	mov    r14,QWORD PTR [rsp+0x28]
     17f:	add    rsp,0x30
     183:	mov    rsp,rbp
     186:	pop    rbp
     187:	ret
     188:	mov    r13,rdi
     18b:	call   190 <botlish_fn_0+0x190>
			18c: R_X86_64_PLT32	rt_stack_overflow-0x4
     190:	xor    rax,rax
     193:	mov    rbx,QWORD PTR [rsp+0x10]
     198:	mov    r12,QWORD PTR [rsp+0x18]
     19d:	mov    r13,QWORD PTR [rsp+0x20]
     1a2:	mov    r14,QWORD PTR [rsp+0x28]
     1a7:	add    rsp,0x30
     1ab:	mov    rsp,rbp
     1ae:	pop    rbp
     1af:	ret

00000000000001b0 <botlish_entry_0: <program entry>>:
     1b0:	push   rbp
     1b1:	mov    rbp,rsp
     1b4:	call   1b9 <botlish_entry_0+0x9>
			1b5: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     1b9:	mov    rsp,rbp
     1bc:	pop    rbp
     1bd:	ret
	...

00000000000001c0 <botlish_fn_1: check<int, int, str, str>>:
     1c0:	push   rbp
     1c1:	mov    rbp,rsp
     1c4:	sub    rsp,0x40
     1c8:	mov    QWORD PTR [rsp+0x10],rbx
     1cd:	mov    QWORD PTR [rsp+0x18],r12
     1d2:	mov    QWORD PTR [rsp+0x20],r13
     1d7:	mov    QWORD PTR [rsp+0x28],r14
     1dc:	mov    QWORD PTR [rsp+0x30],r15
     1e1:	mov    r13,QWORD PTR [rdi]
     1e4:	mov    rax,QWORD PTR [rdi+0x8]
     1e8:	lea    r9,[r13+0x28]
     1ec:	cmp    r9,rax
     1ef:	ja     3c5 <botlish_fn_1+0x205>
     1f5:	lea    rax,[r13+0x28]
     1f9:	mov    QWORD PTR [rdi],rax
     1fc:	mov    r14,rdi
     1ff:	mov    QWORD PTR [r13+0x0],0x0
     207:	mov    QWORD PTR [r13+0x8],0x0
     20f:	mov    QWORD PTR [r13+0x10],0x0
     217:	mov    QWORD PTR [r13+0x18],0x0
     21f:	mov    QWORD PTR [r13+0x20],0x0
     227:	mov    QWORD PTR [r13+0x0],rsi
     22b:	mov    QWORD PTR [r13+0x8],rdx
     22f:	mov    QWORD PTR [r13+0x10],rcx
     233:	mov    r12,rcx
     236:	mov    QWORD PTR [r13+0x18],r8
     23a:	mov    r15,r8
     23d:	mov    rbx,rsi
     240:	mov    QWORD PTR [rsp],rdx
     244:	test   rbx,0x1
     24b:	jne    276 <botlish_fn_1+0xb6>
     251:	mov    edx,0x1
     256:	mov    rsi,rbx
     259:	mov    rdi,r14
     25c:	call   261 <botlish_fn_1+0xa1>
			25d: R_X86_64_PLT32	rt_int_cmp-0x4
     261:	mov    ecx,0x2
     266:	test   rax,rax
     269:	cmovle rcx,QWORD PTR [rip+0x187]        # 3f8 <botlish_fn_1+0x238>
     271:	jmp    287 <botlish_fn_1+0xc7>
     276:	mov    ecx,0x2
     27b:	cmp    rbx,0x1
     27f:	cmovle rcx,QWORD PTR [rip+0x171]        # 3f8 <botlish_fn_1+0x238>
     287:	cmp    rcx,0x6
     28b:	je     399 <botlish_fn_1+0x1d9>
     291:	mov    rdi,r14
     294:	mov    rdx,QWORD PTR [rdi+0x10]
     298:	mov    rdx,QWORD PTR [rdx+0x20]
     29c:	mov    rsi,r12
     29f:	call   2a4 <botlish_fn_1+0xe4>
			2a0: R_X86_64_PLT32	botlish_fn_2-0x4 ; <str>
     2a4:	test   rax,rax
     2a7:	jne    2b5 <botlish_fn_1+0xf5>
     2ad:	mov    rdi,r14
     2b0:	jmp    2f0 <botlish_fn_1+0x130>
     2b5:	cmp    rax,0x6
     2b9:	je     2d1 <botlish_fn_1+0x111>
     2bf:	mov    edx,0x1
     2c4:	mov    QWORD PTR [r13+0x0],0x1
     2cc:	jmp    338 <botlish_fn_1+0x178>
     2d1:	mov    rdi,r14
     2d4:	mov    r9,QWORD PTR [rdi+0x10]
     2d8:	mov    r9,QWORD PTR [r9+0x28]
     2dc:	mov    rsi,r12
     2df:	call   2e4 <botlish_fn_1+0x124>
			2e0: R_X86_64_PLT32	botlish_fn_13-0x4 ; <str>
     2e4:	test   rax,rax
     2e7:	jne    31b <botlish_fn_1+0x15b>
     2ed:	mov    rdi,r14
     2f0:	mov    rdi,r14
     2f3:	mov    QWORD PTR [rdi],r13
     2f6:	xor    rax,rax
     2f9:	mov    rbx,QWORD PTR [rsp+0x10]
     2fe:	mov    r12,QWORD PTR [rsp+0x18]
     303:	mov    r13,QWORD PTR [rsp+0x20]
     308:	mov    r14,QWORD PTR [rsp+0x28]
     30d:	mov    r15,QWORD PTR [rsp+0x30]
     312:	add    rsp,0x40
     316:	mov    rsp,rbp
     319:	pop    rbp
     31a:	ret
     31b:	cmp    rax,0x6
     31f:	je     32f <botlish_fn_1+0x16f>
     325:	mov    edx,0x1
     32a:	jmp    334 <botlish_fn_1+0x174>
     32f:	mov    edx,0x3
     334:	mov    QWORD PTR [r13+0x0],rdx
     338:	sar    rbx,1
     33b:	sub    rbx,0x1
     33f:	shl    rbx,1
     342:	or     rbx,0x1
     346:	mov    QWORD PTR [r13+0x20],rbx
     34a:	mov    rsi,QWORD PTR [rsp]
     34e:	mov    rax,rsi
     351:	and    rax,rdx
     354:	test   rax,0x1
     35a:	je     375 <botlish_fn_1+0x1b5>
     360:	lea    rcx,[rdx-0x1]
     364:	mov    rax,rsi
     367:	add    rax,rcx
     36a:	seto   cl
     36d:	test   cl,cl
     36f:	je     37d <botlish_fn_1+0x1bd>
     375:	mov    rdi,r14
     378:	call   37d <botlish_fn_1+0x1bd>
			379: R_X86_64_PLT32	rt_int_add-0x4
     37d:	mov    QWORD PTR [r13+0x0],rbx
     381:	mov    QWORD PTR [r13+0x8],rax
     385:	mov    QWORD PTR [r13+0x10],r12
     389:	mov    r8,r15
     38c:	mov    QWORD PTR [r13+0x18],r8
     390:	mov    QWORD PTR [rsp],rax
     394:	jmp    244 <botlish_fn_1+0x84>
     399:	mov    rdi,r14
     39c:	mov    QWORD PTR [rdi],r13
     39f:	mov    rax,QWORD PTR [rsp]
     3a3:	mov    rbx,QWORD PTR [rsp+0x10]
     3a8:	mov    r12,QWORD PTR [rsp+0x18]
     3ad:	mov    r13,QWORD PTR [rsp+0x20]
     3b2:	mov    r14,QWORD PTR [rsp+0x28]
     3b7:	mov    r15,QWORD PTR [rsp+0x30]
     3bc:	add    rsp,0x40
     3c0:	mov    rsp,rbp
     3c3:	pop    rbp
     3c4:	ret
     3c5:	mov    r14,rdi
     3c8:	call   3cd <botlish_fn_1+0x20d>
			3c9: R_X86_64_PLT32	rt_stack_overflow-0x4
     3cd:	xor    rax,rax
     3d0:	mov    rbx,QWORD PTR [rsp+0x10]
     3d5:	mov    r12,QWORD PTR [rsp+0x18]
     3da:	mov    r13,QWORD PTR [rsp+0x20]
     3df:	mov    r14,QWORD PTR [rsp+0x28]
     3e4:	mov    r15,QWORD PTR [rsp+0x30]
     3e9:	add    rsp,0x40
     3ed:	mov    rsp,rbp
     3f0:	pop    rbp
     3f1:	ret
     3f2:	add    BYTE PTR [rax],al
     3f4:	add    BYTE PTR [rax],al
     3f6:	add    BYTE PTR [rax],al
     3f8:	(bad)
     3f9:	add    BYTE PTR [rax],al
     3fb:	add    BYTE PTR [rax],al
     3fd:	add    BYTE PTR [rax],al
	...

0000000000000400 <botlish_entry_1: check<int, int, str, str>>:
     400:	push   rbp
     401:	mov    rbp,rsp
     404:	mov    rsi,QWORD PTR [rdx]
     407:	mov    r9,QWORD PTR [rdx+0x8]
     40b:	mov    rcx,QWORD PTR [rdx+0x10]
     40f:	mov    r8,QWORD PTR [rdx+0x18]
     413:	mov    rdx,r9
     416:	call   41b <botlish_entry_1+0x1b>
			417: R_X86_64_PLT32	botlish_fn_1-0x4 ; check<int, int, str, str>
     41b:	mov    rsp,rbp
     41e:	pop    rbp
     41f:	ret

0000000000000420 <botlish_fn_2: <str>>:
     420:	push   rbp
     421:	mov    rbp,rsp
     424:	sub    rsp,0xd0
     42b:	mov    QWORD PTR [rsp+0xa0],rbx
     433:	mov    QWORD PTR [rsp+0xa8],r12
     43b:	mov    QWORD PTR [rsp+0xb0],r13
     443:	mov    QWORD PTR [rsp+0xb8],r14
     44b:	mov    QWORD PTR [rsp+0xc0],r15
     453:	mov    r12,QWORD PTR [rdi]
     456:	mov    rax,QWORD PTR [rdi+0x8]
     45a:	lea    rcx,[r12+0x28]
     45f:	cmp    rcx,rax
     462:	ja     892 <botlish_fn_2+0x472>
     468:	lea    rax,[r12+0x28]
     46d:	mov    QWORD PTR [rdi],rax
     470:	mov    QWORD PTR [rsp+0x78],rdi
     475:	mov    QWORD PTR [r12],0x0
     47d:	mov    QWORD PTR [r12+0x8],0x0
     486:	mov    QWORD PTR [r12+0x10],0x0
     48f:	mov    QWORD PTR [r12+0x18],0x0
     498:	mov    QWORD PTR [r12+0x20],0x0
     4a1:	mov    QWORD PTR [r12],rsi
     4a5:	mov    r13,rsi
     4a8:	mov    rsi,r13
     4ab:	mov    rdi,QWORD PTR [rsp+0x78]
     4b0:	call   4b5 <botlish_fn_2+0x95>
			4b1: R_X86_64_PLT32	rt_str_len-0x4
     4b5:	mov    rbx,rax
     4b8:	mov    QWORD PTR [r12+0x8],rbx
     4bd:	lea    r8,[rsp]
     4c1:	mov    QWORD PTR [rsp],r13
     4c5:	mov    r13d,0x4
     4cb:	mov    rdx,QWORD PTR [rip+0x0]        # 4d2 <botlish_fn_2+0xb2>
			4ce: R_X86_64_GOTPCREL	botlish_entry_4-0x4 ; char_at<generic>
     4d2:	mov    ecx,0x1
     4d7:	mov    QWORD PTR [rsp+0x90],rcx
     4df:	mov    rsi,r13
     4e2:	mov    rdi,QWORD PTR [rsp+0x78]
     4e7:	call   4ec <botlish_fn_2+0xcc>
			4e8: R_X86_64_PLT32	rt_closure_new-0x4
     4ec:	mov    r14,rax
     4ef:	mov    QWORD PTR [r12],rax
     4f3:	lea    r8,[rsp+0x8]
     4f8:	mov    QWORD PTR [rsp+0x8],rbx
     4fd:	mov    QWORD PTR [rsp+0x10],rax
     502:	mov    esi,0x8
     507:	mov    rdx,QWORD PTR [rip+0x0]        # 50e <botlish_fn_2+0xee>
			50a: R_X86_64_GOTPCREL	botlish_entry_8-0x4 ; scan_local<generic>
     50e:	mov    r15d,0x2
     514:	mov    rcx,r15
     517:	mov    rdi,QWORD PTR [rsp+0x78]
     51c:	call   521 <botlish_fn_2+0x101>
			51d: R_X86_64_PLT32	rt_closure_new-0x4
     521:	mov    rsi,rax
     524:	mov    QWORD PTR [rsp+0x88],rax
     52c:	mov    QWORD PTR [r12+0x10],rsi
     531:	lea    r8,[rsp+0x18]
     536:	mov    QWORD PTR [rsp+0x18],rbx
     53b:	mov    rax,r14
     53e:	mov    QWORD PTR [rsp+0x20],rax
     543:	mov    esi,0x9
     548:	mov    rdx,QWORD PTR [rip+0x0]        # 54f <botlish_fn_2+0x12f>
			54b: R_X86_64_GOTPCREL	botlish_entry_9-0x4 ; scan_label<generic>
     54f:	mov    rcx,r15
     552:	mov    rdi,QWORD PTR [rsp+0x78]
     557:	call   55c <botlish_fn_2+0x13c>
			558: R_X86_64_PLT32	rt_closure_new-0x4
     55c:	mov    QWORD PTR [r12+0x18],rax
     561:	mov    QWORD PTR [rsp+0x80],rax
     569:	lea    r8,[rsp+0x28]
     56e:	mov    QWORD PTR [rsp+0x28],rbx
     573:	mov    QWORD PTR [rsp+0x30],r14
     578:	mov    esi,0xa
     57d:	mov    rdx,QWORD PTR [rip+0x0]        # 584 <botlish_fn_2+0x164>
			580: R_X86_64_GOTPCREL	botlish_entry_10-0x4 ; scan_alpha<generic>
     584:	mov    rcx,r15
     587:	mov    rdi,QWORD PTR [rsp+0x78]
     58c:	call   591 <botlish_fn_2+0x171>
			58d: R_X86_64_PLT32	rt_closure_new-0x4
     591:	mov    QWORD PTR [r12+0x20],rax
     596:	lea    r8,[rsp+0x38]
     59b:	mov    QWORD PTR [rsp+0x38],rax
     5a0:	mov    QWORD PTR [rsp+0x40],rbx
     5a5:	mov    esi,0xb
     5aa:	mov    rdx,QWORD PTR [rip+0x0]        # 5b1 <botlish_fn_2+0x191>
			5ad: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; tld_ok<generic>
     5b1:	mov    rcx,r15
     5b4:	mov    rdi,QWORD PTR [rsp+0x78]
     5b9:	call   5be <botlish_fn_2+0x19e>
			5ba: R_X86_64_PLT32	rt_closure_new-0x4
     5be:	mov    QWORD PTR [r12+0x20],rax
     5c3:	lea    r8,[rsp+0x48]
     5c8:	mov    rcx,QWORD PTR [rsp+0x80]
     5d0:	mov    QWORD PTR [rsp+0x48],rcx
     5d5:	mov    QWORD PTR [rsp+0x50],rbx
     5da:	mov    QWORD PTR [rsp+0x58],r14
     5df:	mov    QWORD PTR [rsp+0x60],rax
     5e4:	mov    esi,0xc
     5e9:	mov    rdx,QWORD PTR [rip+0x0]        # 5f0 <botlish_fn_2+0x1d0>
			5ec: R_X86_64_GOTPCREL	botlish_entry_12-0x4 ; domain_loop<generic>
     5f0:	mov    rcx,r13
     5f3:	mov    rdi,QWORD PTR [rsp+0x78]
     5f8:	call   5fd <botlish_fn_2+0x1dd>
			5f9: R_X86_64_PLT32	rt_closure_new-0x4
     5fd:	mov    QWORD PTR [r12+0x18],rax
     602:	mov    r15,rax
     605:	mov    QWORD PTR [r12+0x20],0x1
     60e:	mov    rdx,QWORD PTR [rsp+0x90]
     616:	mov    rsi,QWORD PTR [rsp+0x88]
     61e:	mov    rdi,QWORD PTR [rsp+0x78]
     623:	call   628 <botlish_fn_2+0x208>
			624: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_local<generic>
     628:	mov    rcx,rax
     62b:	mov    r13,rax
     62e:	test   rax,rcx
     631:	jne    641 <botlish_fn_2+0x221>
     637:	mov    rdi,QWORD PTR [rsp+0x78]
     63c:	jmp    7a8 <botlish_fn_2+0x388>
     641:	mov    rax,r13
     644:	mov    QWORD PTR [r12+0x10],rax
     649:	test   rax,0x1
     64f:	jne    67d <botlish_fn_2+0x25d>
     655:	mov    edx,0x1
     65a:	mov    rsi,r13
     65d:	mov    rdi,QWORD PTR [rsp+0x78]
     662:	call   667 <botlish_fn_2+0x247>
			663: R_X86_64_PLT32	rt_int_cmp-0x4
     667:	mov    r11d,0x2
     66d:	test   rax,rax
     670:	cmove  r11,QWORD PTR [rip+0x260]        # 8d8 <botlish_fn_2+0x4b8>
     678:	jmp    68f <botlish_fn_2+0x26f>
     67d:	mov    r11d,0x2
     683:	cmp    r13,0x1
     687:	cmove  r11,QWORD PTR [rip+0x249]        # 8d8 <botlish_fn_2+0x4b8>
     68f:	cmp    r11,0x6
     693:	je     84c <botlish_fn_2+0x42c>
     699:	mov    rax,r13
     69c:	and    rax,rbx
     69f:	test   rax,0x1
     6a5:	jne    6d0 <botlish_fn_2+0x2b0>
     6ab:	mov    rdx,rbx
     6ae:	mov    rsi,r13
     6b1:	mov    rdi,QWORD PTR [rsp+0x78]
     6b6:	call   6bb <botlish_fn_2+0x29b>
			6b7: R_X86_64_PLT32	rt_int_cmp-0x4
     6bb:	mov    ecx,0x2
     6c0:	test   rax,rax
     6c3:	cmovge rcx,QWORD PTR [rip+0x20d]        # 8d8 <botlish_fn_2+0x4b8>
     6cb:	jmp    6e0 <botlish_fn_2+0x2c0>
     6d0:	mov    ecx,0x2
     6d5:	cmp    r13,rbx
     6d8:	cmovge rcx,QWORD PTR [rip+0x1f8]        # 8d8 <botlish_fn_2+0x4b8>
     6e0:	cmp    rcx,0x6
     6e4:	je     83d <botlish_fn_2+0x41d>
     6ea:	lea    rcx,[rsp+0x68]
     6ef:	mov    rsi,r14
     6f2:	mov    rdx,r13
     6f5:	mov    rdi,QWORD PTR [rsp+0x78]
     6fa:	call   6ff <botlish_fn_2+0x2df>
			6fb: R_X86_64_PLT32	botlish_fn_5-0x4 ; char_at<generic>
     6ff:	test   rax,rax
     702:	mov    rsi,rax
     705:	jne    715 <botlish_fn_2+0x2f5>
     70b:	mov    rdi,QWORD PTR [rsp+0x78]
     710:	jmp    7a8 <botlish_fn_2+0x388>
     715:	mov    rdx,QWORD PTR [rsp+0x68]
     71a:	mov    rcx,QWORD PTR [rsp+0x70]
     71f:	mov    rdi,QWORD PTR [rsp+0x78]
     724:	mov    rdi,QWORD PTR [rdi+0x10]
     728:	mov    r8,QWORD PTR [rdi+0x40]
     72c:	mov    rdi,QWORD PTR [rsp+0x78]
     731:	call   736 <botlish_fn_2+0x316>
			732: R_X86_64_PLT32	rt_str_region_eq-0x4
     736:	cmp    rax,0x6
     73a:	je     74d <botlish_fn_2+0x32d>
     740:	mov    ecx,0x2
     745:	mov    rax,rcx
     748:	jmp    842 <botlish_fn_2+0x422>
     74d:	mov    QWORD PTR [r12],0x3
     755:	test   r13,0x1
     75c:	je     774 <botlish_fn_2+0x354>
     762:	mov    rdx,r13
     765:	add    rdx,0x2
     769:	seto   al
     76c:	test   al,al
     76e:	je     789 <botlish_fn_2+0x369>
     774:	mov    edx,0x3
     779:	mov    rsi,r13
     77c:	mov    rdi,QWORD PTR [rsp+0x78]
     781:	call   786 <botlish_fn_2+0x366>
			782: R_X86_64_PLT32	rt_int_add-0x4
     786:	mov    rdx,rax
     789:	mov    QWORD PTR [r12],rdx
     78d:	mov    rsi,r15
     790:	mov    rdi,QWORD PTR [rsp+0x78]
     795:	call   79a <botlish_fn_2+0x37a>
			796: R_X86_64_PLT32	botlish_fn_12-0x4 ; domain_loop<generic>
     79a:	test   rax,rax
     79d:	jne    7e7 <botlish_fn_2+0x3c7>
     7a3:	mov    rdi,QWORD PTR [rsp+0x78]
     7a8:	mov    rdi,QWORD PTR [rsp+0x78]
     7ad:	mov    QWORD PTR [rdi],r12
     7b0:	xor    rax,rax
     7b3:	mov    rbx,QWORD PTR [rsp+0xa0]
     7bb:	mov    r12,QWORD PTR [rsp+0xa8]
     7c3:	mov    r13,QWORD PTR [rsp+0xb0]
     7cb:	mov    r14,QWORD PTR [rsp+0xb8]
     7d3:	mov    r15,QWORD PTR [rsp+0xc0]
     7db:	add    rsp,0xd0
     7e2:	mov    rsp,rbp
     7e5:	pop    rbp
     7e6:	ret
     7e7:	mov    rcx,rax
     7ea:	and    rcx,rbx
     7ed:	mov    rsi,rax
     7f0:	mov    rax,rbx
     7f3:	test   rcx,0x1
     7fa:	jne    825 <botlish_fn_2+0x405>
     800:	mov    rdx,rax
     803:	mov    rdi,QWORD PTR [rsp+0x78]
     808:	call   80d <botlish_fn_2+0x3ed>
			809: R_X86_64_PLT32	rt_int_cmp-0x4
     80d:	mov    ecx,0x2
     812:	test   rax,rax
     815:	mov    rax,rcx
     818:	cmove  rax,QWORD PTR [rip+0xb8]        # 8d8 <botlish_fn_2+0x4b8>
     820:	jmp    842 <botlish_fn_2+0x422>
     825:	mov    rdx,rax
     828:	mov    eax,0x2
     82d:	cmp    rsi,rdx
     830:	cmove  rax,QWORD PTR [rip+0xa0]        # 8d8 <botlish_fn_2+0x4b8>
     838:	jmp    842 <botlish_fn_2+0x422>
     83d:	mov    eax,0x2
     842:	mov    rdi,QWORD PTR [rsp+0x78]
     847:	jmp    856 <botlish_fn_2+0x436>
     84c:	mov    eax,0x2
     851:	mov    rdi,QWORD PTR [rsp+0x78]
     856:	mov    rdi,QWORD PTR [rsp+0x78]
     85b:	mov    QWORD PTR [rdi],r12
     85e:	mov    rbx,QWORD PTR [rsp+0xa0]
     866:	mov    r12,QWORD PTR [rsp+0xa8]
     86e:	mov    r13,QWORD PTR [rsp+0xb0]
     876:	mov    r14,QWORD PTR [rsp+0xb8]
     87e:	mov    r15,QWORD PTR [rsp+0xc0]
     886:	add    rsp,0xd0
     88d:	mov    rsp,rbp
     890:	pop    rbp
     891:	ret
     892:	mov    QWORD PTR [rsp+0x78],rdi
     897:	call   89c <botlish_fn_2+0x47c>
			898: R_X86_64_PLT32	rt_stack_overflow-0x4
     89c:	xor    rax,rax
     89f:	mov    rbx,QWORD PTR [rsp+0xa0]
     8a7:	mov    r12,QWORD PTR [rsp+0xa8]
     8af:	mov    r13,QWORD PTR [rsp+0xb0]
     8b7:	mov    r14,QWORD PTR [rsp+0xb8]
     8bf:	mov    r15,QWORD PTR [rsp+0xc0]
     8c7:	add    rsp,0xd0
     8ce:	mov    rsp,rbp
     8d1:	pop    rbp
     8d2:	ret
     8d3:	add    BYTE PTR [rax],al
     8d5:	add    BYTE PTR [rax],al
     8d7:	add    BYTE PTR [rsi],al
     8d9:	add    BYTE PTR [rax],al
     8db:	add    BYTE PTR [rax],al
     8dd:	add    BYTE PTR [rax],al
	...

00000000000008e0 <botlish_entry_2: <str>>:
     8e0:	push   rbp
     8e1:	mov    rbp,rsp
     8e4:	mov    rsi,QWORD PTR [rdx]
     8e7:	call   8ec <botlish_entry_2+0xc>
			8e8: R_X86_64_PLT32	botlish_fn_2-0x4 ; <str>
     8ec:	mov    rsp,rbp
     8ef:	pop    rbp
     8f0:	ret
     8f1:	add    BYTE PTR [rax],al
     8f3:	add    BYTE PTR [rax],al
     8f5:	add    BYTE PTR [rax],al
	...

00000000000008f8 <botlish_fn_3: <generic>>:
     8f8:	push   rbp
     8f9:	mov    rbp,rsp
     8fc:	sub    rsp,0xd0
     903:	mov    QWORD PTR [rsp+0xa0],rbx
     90b:	mov    QWORD PTR [rsp+0xa8],r12
     913:	mov    QWORD PTR [rsp+0xb0],r13
     91b:	mov    QWORD PTR [rsp+0xb8],r14
     923:	mov    QWORD PTR [rsp+0xc0],r15
     92b:	mov    r12,QWORD PTR [rdi]
     92e:	mov    rax,QWORD PTR [rdi+0x8]
     932:	lea    rcx,[r12+0x28]
     937:	cmp    rcx,rax
     93a:	ja     da3 <botlish_fn_3+0x4ab>
     940:	lea    rax,[r12+0x28]
     945:	mov    QWORD PTR [rdi],rax
     948:	mov    QWORD PTR [r12],0x0
     950:	mov    QWORD PTR [r12+0x8],0x0
     959:	mov    QWORD PTR [r12+0x10],0x0
     962:	mov    QWORD PTR [r12+0x18],0x0
     96b:	mov    QWORD PTR [r12+0x20],0x0
     974:	mov    QWORD PTR [r12],rsi
     978:	xor    eax,eax
     97a:	test   rsi,0x7
     981:	jne    990 <botlish_fn_3+0x98>
     987:	movzx  rax,BYTE PTR [rsi]
     98b:	cmp    al,0x2
     98d:	sete   al
     990:	test   al,al
     992:	jne    9b9 <botlish_fn_3+0xc1>
     998:	mov    rax,QWORD PTR [rdi+0x10]
     99c:	mov    QWORD PTR [rsp+0x78],rdi
     9a1:	mov    rcx,QWORD PTR [rax+0x48]
     9a5:	mov    edx,0x1
     9aa:	call   9af <botlish_fn_3+0xb7>
			9ab: R_X86_64_PLT32	rt_type_error-0x4
     9af:	mov    rdi,QWORD PTR [rsp+0x78]
     9b4:	jmp    cb9 <botlish_fn_3+0x3c1>
     9b9:	mov    r13,rsi
     9bc:	mov    QWORD PTR [rsp+0x78],rdi
     9c1:	call   9c6 <botlish_fn_3+0xce>
			9c2: R_X86_64_PLT32	rt_str_len-0x4
     9c6:	mov    rbx,rax
     9c9:	mov    QWORD PTR [r12+0x8],rbx
     9ce:	lea    r8,[rsp]
     9d2:	mov    QWORD PTR [rsp],r13
     9d6:	mov    r13d,0x4
     9dc:	mov    rdx,QWORD PTR [rip+0x0]        # 9e3 <botlish_fn_3+0xeb>
			9df: R_X86_64_GOTPCREL	botlish_entry_4-0x4 ; char_at<generic>
     9e3:	mov    r14d,0x1
     9e9:	mov    rcx,r14
     9ec:	mov    rsi,r13
     9ef:	mov    rdi,QWORD PTR [rsp+0x78]
     9f4:	call   9f9 <botlish_fn_3+0x101>
			9f5: R_X86_64_PLT32	rt_closure_new-0x4
     9f9:	mov    QWORD PTR [rsp+0x90],r14
     a01:	mov    r14,rax
     a04:	mov    QWORD PTR [r12],rax
     a08:	lea    r8,[rsp+0x8]
     a0d:	mov    QWORD PTR [rsp+0x8],rbx
     a12:	mov    QWORD PTR [rsp+0x10],rax
     a17:	mov    esi,0x8
     a1c:	mov    rdx,QWORD PTR [rip+0x0]        # a23 <botlish_fn_3+0x12b>
			a1f: R_X86_64_GOTPCREL	botlish_entry_8-0x4 ; scan_local<generic>
     a23:	mov    r15d,0x2
     a29:	mov    rcx,r15
     a2c:	mov    rdi,QWORD PTR [rsp+0x78]
     a31:	call   a36 <botlish_fn_3+0x13e>
			a32: R_X86_64_PLT32	rt_closure_new-0x4
     a36:	mov    rcx,rax
     a39:	mov    QWORD PTR [rsp+0x88],rax
     a41:	mov    QWORD PTR [r12+0x10],rcx
     a46:	lea    r8,[rsp+0x18]
     a4b:	mov    QWORD PTR [rsp+0x18],rbx
     a50:	mov    rax,r14
     a53:	mov    QWORD PTR [rsp+0x20],rax
     a58:	mov    esi,0x9
     a5d:	mov    rdx,QWORD PTR [rip+0x0]        # a64 <botlish_fn_3+0x16c>
			a60: R_X86_64_GOTPCREL	botlish_entry_9-0x4 ; scan_label<generic>
     a64:	mov    rcx,r15
     a67:	mov    rdi,QWORD PTR [rsp+0x78]
     a6c:	call   a71 <botlish_fn_3+0x179>
			a6d: R_X86_64_PLT32	rt_closure_new-0x4
     a71:	mov    QWORD PTR [r12+0x18],rax
     a76:	mov    QWORD PTR [rsp+0x80],rax
     a7e:	lea    r8,[rsp+0x28]
     a83:	mov    QWORD PTR [rsp+0x28],rbx
     a88:	mov    QWORD PTR [rsp+0x30],r14
     a8d:	mov    esi,0xa
     a92:	mov    rdx,QWORD PTR [rip+0x0]        # a99 <botlish_fn_3+0x1a1>
			a95: R_X86_64_GOTPCREL	botlish_entry_10-0x4 ; scan_alpha<generic>
     a99:	mov    rcx,r15
     a9c:	mov    rdi,QWORD PTR [rsp+0x78]
     aa1:	call   aa6 <botlish_fn_3+0x1ae>
			aa2: R_X86_64_PLT32	rt_closure_new-0x4
     aa6:	mov    QWORD PTR [r12+0x20],rax
     aab:	lea    r8,[rsp+0x38]
     ab0:	mov    QWORD PTR [rsp+0x38],rax
     ab5:	mov    QWORD PTR [rsp+0x40],rbx
     aba:	mov    esi,0xb
     abf:	mov    rdx,QWORD PTR [rip+0x0]        # ac6 <botlish_fn_3+0x1ce>
			ac2: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; tld_ok<generic>
     ac6:	mov    rcx,r15
     ac9:	mov    rdi,QWORD PTR [rsp+0x78]
     ace:	call   ad3 <botlish_fn_3+0x1db>
			acf: R_X86_64_PLT32	rt_closure_new-0x4
     ad3:	mov    QWORD PTR [r12+0x20],rax
     ad8:	lea    r8,[rsp+0x48]
     add:	mov    rcx,QWORD PTR [rsp+0x80]
     ae5:	mov    QWORD PTR [rsp+0x48],rcx
     aea:	mov    QWORD PTR [rsp+0x50],rbx
     aef:	mov    QWORD PTR [rsp+0x58],r14
     af4:	mov    QWORD PTR [rsp+0x60],rax
     af9:	mov    esi,0xc
     afe:	mov    rdx,QWORD PTR [rip+0x0]        # b05 <botlish_fn_3+0x20d>
			b01: R_X86_64_GOTPCREL	botlish_entry_12-0x4 ; domain_loop<generic>
     b05:	mov    rcx,r13
     b08:	mov    rdi,QWORD PTR [rsp+0x78]
     b0d:	call   b12 <botlish_fn_3+0x21a>
			b0e: R_X86_64_PLT32	rt_closure_new-0x4
     b12:	mov    QWORD PTR [r12+0x18],rax
     b17:	mov    r15,rax
     b1a:	mov    QWORD PTR [r12+0x20],0x1
     b23:	mov    rsi,QWORD PTR [rsp+0x88]
     b2b:	mov    rdx,QWORD PTR [rsp+0x90]
     b33:	mov    rdi,QWORD PTR [rsp+0x78]
     b38:	call   b3d <botlish_fn_3+0x245>
			b39: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_local<generic>
     b3d:	mov    rcx,rax
     b40:	mov    r13,rax
     b43:	test   rax,rcx
     b46:	jne    b56 <botlish_fn_3+0x25e>
     b4c:	mov    rdi,QWORD PTR [rsp+0x78]
     b51:	jmp    cb9 <botlish_fn_3+0x3c1>
     b56:	mov    rax,r13
     b59:	mov    QWORD PTR [r12+0x10],rax
     b5e:	test   rax,0x1
     b64:	jne    b94 <botlish_fn_3+0x29c>
     b6a:	mov    rdx,QWORD PTR [rsp+0x90]
     b72:	mov    rsi,r13
     b75:	mov    rdi,QWORD PTR [rsp+0x78]
     b7a:	call   b7f <botlish_fn_3+0x287>
			b7b: R_X86_64_PLT32	rt_int_cmp-0x4
     b7f:	mov    ecx,0x2
     b84:	test   rax,rax
     b87:	cmove  rcx,QWORD PTR [rip+0x259]        # de8 <botlish_fn_3+0x4f0>
     b8f:	jmp    ba5 <botlish_fn_3+0x2ad>
     b94:	mov    ecx,0x2
     b99:	cmp    r13,0x1
     b9d:	cmove  rcx,QWORD PTR [rip+0x243]        # de8 <botlish_fn_3+0x4f0>
     ba5:	cmp    rcx,0x6
     ba9:	je     d5d <botlish_fn_3+0x465>
     baf:	mov    rax,r13
     bb2:	and    rax,rbx
     bb5:	test   rax,0x1
     bbb:	jne    be6 <botlish_fn_3+0x2ee>
     bc1:	mov    rdx,rbx
     bc4:	mov    rsi,r13
     bc7:	mov    rdi,QWORD PTR [rsp+0x78]
     bcc:	call   bd1 <botlish_fn_3+0x2d9>
			bcd: R_X86_64_PLT32	rt_int_cmp-0x4
     bd1:	mov    ecx,0x2
     bd6:	test   rax,rax
     bd9:	cmovge rcx,QWORD PTR [rip+0x207]        # de8 <botlish_fn_3+0x4f0>
     be1:	jmp    bf6 <botlish_fn_3+0x2fe>
     be6:	mov    ecx,0x2
     beb:	cmp    r13,rbx
     bee:	cmovge rcx,QWORD PTR [rip+0x1f2]        # de8 <botlish_fn_3+0x4f0>
     bf6:	cmp    rcx,0x6
     bfa:	je     d4e <botlish_fn_3+0x456>
     c00:	lea    rcx,[rsp+0x68]
     c05:	mov    rsi,r14
     c08:	mov    rdx,r13
     c0b:	mov    rdi,QWORD PTR [rsp+0x78]
     c10:	call   c15 <botlish_fn_3+0x31d>
			c11: R_X86_64_PLT32	botlish_fn_5-0x4 ; char_at<generic>
     c15:	test   rax,rax
     c18:	mov    rsi,rax
     c1b:	jne    c2b <botlish_fn_3+0x333>
     c21:	mov    rdi,QWORD PTR [rsp+0x78]
     c26:	jmp    cb9 <botlish_fn_3+0x3c1>
     c2b:	mov    rdx,QWORD PTR [rsp+0x68]
     c30:	mov    rcx,QWORD PTR [rsp+0x70]
     c35:	mov    rdi,QWORD PTR [rsp+0x78]
     c3a:	mov    rax,QWORD PTR [rdi+0x10]
     c3e:	mov    r8,QWORD PTR [rax+0x40]
     c42:	call   c47 <botlish_fn_3+0x34f>
			c43: R_X86_64_PLT32	rt_str_region_eq-0x4
     c47:	cmp    rax,0x6
     c4b:	je     c5e <botlish_fn_3+0x366>
     c51:	mov    esi,0x2
     c56:	mov    rax,rsi
     c59:	jmp    d53 <botlish_fn_3+0x45b>
     c5e:	mov    QWORD PTR [r12],0x3
     c66:	test   r13,0x1
     c6d:	je     c85 <botlish_fn_3+0x38d>
     c73:	mov    rdx,r13
     c76:	add    rdx,0x2
     c7a:	seto   al
     c7d:	test   al,al
     c7f:	je     c9a <botlish_fn_3+0x3a2>
     c85:	mov    edx,0x3
     c8a:	mov    rsi,r13
     c8d:	mov    rdi,QWORD PTR [rsp+0x78]
     c92:	call   c97 <botlish_fn_3+0x39f>
			c93: R_X86_64_PLT32	rt_int_add-0x4
     c97:	mov    rdx,rax
     c9a:	mov    QWORD PTR [r12],rdx
     c9e:	mov    rsi,r15
     ca1:	mov    rdi,QWORD PTR [rsp+0x78]
     ca6:	call   cab <botlish_fn_3+0x3b3>
			ca7: R_X86_64_PLT32	botlish_fn_12-0x4 ; domain_loop<generic>
     cab:	test   rax,rax
     cae:	jne    cf8 <botlish_fn_3+0x400>
     cb4:	mov    rdi,QWORD PTR [rsp+0x78]
     cb9:	mov    rdi,QWORD PTR [rsp+0x78]
     cbe:	mov    QWORD PTR [rdi],r12
     cc1:	xor    rax,rax
     cc4:	mov    rbx,QWORD PTR [rsp+0xa0]
     ccc:	mov    r12,QWORD PTR [rsp+0xa8]
     cd4:	mov    r13,QWORD PTR [rsp+0xb0]
     cdc:	mov    r14,QWORD PTR [rsp+0xb8]
     ce4:	mov    r15,QWORD PTR [rsp+0xc0]
     cec:	add    rsp,0xd0
     cf3:	mov    rsp,rbp
     cf6:	pop    rbp
     cf7:	ret
     cf8:	mov    rcx,rax
     cfb:	and    rcx,rbx
     cfe:	mov    rsi,rax
     d01:	mov    rax,rbx
     d04:	test   rcx,0x1
     d0b:	jne    d36 <botlish_fn_3+0x43e>
     d11:	mov    rdx,rax
     d14:	mov    rdi,QWORD PTR [rsp+0x78]
     d19:	call   d1e <botlish_fn_3+0x426>
			d1a: R_X86_64_PLT32	rt_int_cmp-0x4
     d1e:	mov    esi,0x2
     d23:	test   rax,rax
     d26:	mov    rax,rsi
     d29:	cmove  rax,QWORD PTR [rip+0xb7]        # de8 <botlish_fn_3+0x4f0>
     d31:	jmp    d53 <botlish_fn_3+0x45b>
     d36:	mov    rdx,rax
     d39:	mov    eax,0x2
     d3e:	cmp    rsi,rdx
     d41:	cmove  rax,QWORD PTR [rip+0x9f]        # de8 <botlish_fn_3+0x4f0>
     d49:	jmp    d53 <botlish_fn_3+0x45b>
     d4e:	mov    eax,0x2
     d53:	mov    rdi,QWORD PTR [rsp+0x78]
     d58:	jmp    d67 <botlish_fn_3+0x46f>
     d5d:	mov    eax,0x2
     d62:	mov    rdi,QWORD PTR [rsp+0x78]
     d67:	mov    rdi,QWORD PTR [rsp+0x78]
     d6c:	mov    QWORD PTR [rdi],r12
     d6f:	mov    rbx,QWORD PTR [rsp+0xa0]
     d77:	mov    r12,QWORD PTR [rsp+0xa8]
     d7f:	mov    r13,QWORD PTR [rsp+0xb0]
     d87:	mov    r14,QWORD PTR [rsp+0xb8]
     d8f:	mov    r15,QWORD PTR [rsp+0xc0]
     d97:	add    rsp,0xd0
     d9e:	mov    rsp,rbp
     da1:	pop    rbp
     da2:	ret
     da3:	mov    QWORD PTR [rsp+0x78],rdi
     da8:	call   dad <botlish_fn_3+0x4b5>
			da9: R_X86_64_PLT32	rt_stack_overflow-0x4
     dad:	xor    rax,rax
     db0:	mov    rbx,QWORD PTR [rsp+0xa0]
     db8:	mov    r12,QWORD PTR [rsp+0xa8]
     dc0:	mov    r13,QWORD PTR [rsp+0xb0]
     dc8:	mov    r14,QWORD PTR [rsp+0xb8]
     dd0:	mov    r15,QWORD PTR [rsp+0xc0]
     dd8:	add    rsp,0xd0
     ddf:	mov    rsp,rbp
     de2:	pop    rbp
     de3:	ret
     de4:	add    BYTE PTR [rax],al
     de6:	add    BYTE PTR [rax],al
     de8:	(bad)
     de9:	add    BYTE PTR [rax],al
     deb:	add    BYTE PTR [rax],al
     ded:	add    BYTE PTR [rax],al
	...

0000000000000df0 <botlish_entry_3: <generic>>:
     df0:	push   rbp
     df1:	mov    rbp,rsp
     df4:	mov    rsi,QWORD PTR [rdx]
     df7:	call   dfc <botlish_entry_3+0xc>
			df8: R_X86_64_PLT32	botlish_fn_3-0x4 ; <generic>
     dfc:	mov    rsp,rbp
     dff:	pop    rbp
     e00:	ret

0000000000000e01 <botlish_fn_4: char_at<generic>>:
     e01:	push   rbp
     e02:	mov    rbp,rsp
     e05:	sub    rsp,0x20
     e09:	mov    QWORD PTR [rsp],rbx
     e0d:	mov    QWORD PTR [rsp+0x8],r12
     e12:	mov    QWORD PTR [rsp+0x10],r13
     e17:	mov    QWORD PTR [rsp+0x18],r14
     e1c:	mov    rbx,QWORD PTR [rdi]
     e1f:	mov    rax,QWORD PTR [rdi+0x8]
     e23:	lea    rcx,[rbx+0x18]
     e27:	cmp    rcx,rax
     e2a:	ja     fc5 <botlish_fn_4+0x1c4>
     e30:	lea    rax,[rbx+0x18]
     e34:	mov    QWORD PTR [rdi],rax
     e37:	mov    QWORD PTR [rbx],0x0
     e3e:	mov    QWORD PTR [rbx+0x8],0x0
     e46:	mov    QWORD PTR [rbx+0x10],0x0
     e4e:	mov    QWORD PTR [rbx],rdx
     e51:	mov    rax,QWORD PTR [rsi+0x20]
     e55:	mov    rsi,QWORD PTR [rax]
     e58:	mov    QWORD PTR [rbx+0x8],rsi
     e5c:	mov    r14,rsi
     e5f:	mov    QWORD PTR [rbx+0x10],0x3
     e67:	mov    ecx,0x1
     e6c:	test   rdx,0x1
     e73:	je     e81 <botlish_fn_4+0x80>
     e79:	mov    r13,rdx
     e7c:	jmp    ea4 <botlish_fn_4+0xa3>
     e81:	xor    ecx,ecx
     e83:	test   rdx,0x7
     e8a:	je     e98 <botlish_fn_4+0x97>
     e90:	mov    r13,rdx
     e93:	jmp    ea4 <botlish_fn_4+0xa3>
     e98:	movzx  rax,BYTE PTR [rdx]
     e9c:	mov    r13,rdx
     e9f:	cmp    al,0x1
     ea1:	sete   cl
     ea4:	test   cl,cl
     ea6:	jne    eca <botlish_fn_4+0xc9>
     eac:	mov    rax,QWORD PTR [rdi+0x10]
     eb0:	mov    r12,rdi
     eb3:	mov    rcx,QWORD PTR [rax+0x50]
     eb7:	xor    rdx,rdx
     eba:	mov    rsi,r13
     ebd:	call   ec2 <botlish_fn_4+0xc1>
			ebe: R_X86_64_PLT32	rt_type_error-0x4
     ec2:	mov    rdi,r12
     ec5:	jmp    f7e <botlish_fn_4+0x17d>
     eca:	mov    rsi,r13
     ecd:	mov    r12,rdi
     ed0:	test   rsi,0x1
     ed7:	je     ef4 <botlish_fn_4+0xf3>
     edd:	mov    rsi,r13
     ee0:	mov    rcx,rsi
     ee3:	add    rcx,0x2
     ee7:	seto   sil
     eeb:	test   sil,sil
     eee:	je     f07 <botlish_fn_4+0x106>
     ef4:	mov    edx,0x3
     ef9:	mov    rsi,r13
     efc:	mov    rdi,r12
     eff:	call   f04 <botlish_fn_4+0x103>
			f00: R_X86_64_PLT32	rt_int_add-0x4
     f04:	mov    rcx,rax
     f07:	mov    QWORD PTR [rbx+0x10],rcx
     f0b:	mov    edx,0x1
     f10:	mov    rsi,r13
     f13:	test   rsi,0x1
     f1a:	jne    f3e <botlish_fn_4+0x13d>
     f20:	xor    edx,edx
     f22:	mov    rsi,r13
     f25:	test   rsi,0x7
     f2c:	jne    f3e <botlish_fn_4+0x13d>
     f32:	mov    rsi,r13
     f35:	movzx  rax,BYTE PTR [rsi]
     f39:	cmp    al,0x1
     f3b:	sete   dl
     f3e:	test   dl,dl
     f40:	jne    f64 <botlish_fn_4+0x163>
     f46:	mov    rdi,r12
     f49:	mov    rax,QWORD PTR [rdi+0x10]
     f4d:	mov    rcx,QWORD PTR [rax+0x58]
     f51:	xor    rdx,rdx
     f54:	mov    rsi,r13
     f57:	call   f5c <botlish_fn_4+0x15b>
			f58: R_X86_64_PLT32	rt_type_error-0x4
     f5c:	mov    rdi,r12
     f5f:	jmp    f7e <botlish_fn_4+0x17d>
     f64:	mov    rdx,r13
     f67:	mov    rsi,r14
     f6a:	mov    rdi,r12
     f6d:	call   f72 <botlish_fn_4+0x171>
			f6e: R_X86_64_PLT32	rt_substr-0x4
     f72:	test   rax,rax
     f75:	jne    fa3 <botlish_fn_4+0x1a2>
     f7b:	mov    rdi,r12
     f7e:	mov    rdi,r12
     f81:	mov    QWORD PTR [rdi],rbx
     f84:	xor    rax,rax
     f87:	mov    rbx,QWORD PTR [rsp]
     f8b:	mov    r12,QWORD PTR [rsp+0x8]
     f90:	mov    r13,QWORD PTR [rsp+0x10]
     f95:	mov    r14,QWORD PTR [rsp+0x18]
     f9a:	add    rsp,0x20
     f9e:	mov    rsp,rbp
     fa1:	pop    rbp
     fa2:	ret
     fa3:	mov    rdi,r12
     fa6:	mov    QWORD PTR [rdi],rbx
     fa9:	mov    rbx,QWORD PTR [rsp]
     fad:	mov    r12,QWORD PTR [rsp+0x8]
     fb2:	mov    r13,QWORD PTR [rsp+0x10]
     fb7:	mov    r14,QWORD PTR [rsp+0x18]
     fbc:	add    rsp,0x20
     fc0:	mov    rsp,rbp
     fc3:	pop    rbp
     fc4:	ret
     fc5:	mov    r12,rdi
     fc8:	call   fcd <botlish_fn_4+0x1cc>
			fc9: R_X86_64_PLT32	rt_stack_overflow-0x4
     fcd:	xor    rax,rax
     fd0:	mov    rbx,QWORD PTR [rsp]
     fd4:	mov    r12,QWORD PTR [rsp+0x8]
     fd9:	mov    r13,QWORD PTR [rsp+0x10]
     fde:	mov    r14,QWORD PTR [rsp+0x18]
     fe3:	add    rsp,0x20
     fe7:	mov    rsp,rbp
     fea:	pop    rbp
     feb:	ret

0000000000000fec <botlish_entry_4: char_at<generic>>:
     fec:	push   rbp
     fed:	mov    rbp,rsp
     ff0:	mov    rdx,QWORD PTR [rdx]
     ff3:	call   ff8 <botlish_entry_4+0xc>
			ff4: R_X86_64_PLT32	botlish_fn_4-0x4 ; char_at<generic>
     ff8:	mov    rsp,rbp
     ffb:	pop    rbp
     ffc:	ret

0000000000000ffd <botlish_fn_5: char_at<generic>>:
     ffd:	push   rbp
     ffe:	mov    rbp,rsp
    1001:	sub    rsp,0x40
    1005:	mov    QWORD PTR [rsp+0x10],rbx
    100a:	mov    QWORD PTR [rsp+0x18],r12
    100f:	mov    QWORD PTR [rsp+0x20],r13
    1014:	mov    QWORD PTR [rsp+0x28],r14
    1019:	mov    QWORD PTR [rsp+0x30],r15
    101e:	mov    r15,rcx
    1021:	mov    rbx,QWORD PTR [rdi]
    1024:	mov    rax,QWORD PTR [rdi+0x8]
    1028:	lea    rcx,[rbx+0x18]
    102c:	cmp    rcx,rax
    102f:	ja     11f8 <botlish_fn_5+0x1fb>
    1035:	lea    rax,[rbx+0x18]
    1039:	mov    QWORD PTR [rdi],rax
    103c:	mov    QWORD PTR [rbx],0x0
    1043:	mov    QWORD PTR [rbx+0x8],0x0
    104b:	mov    QWORD PTR [rbx+0x10],0x0
    1053:	mov    QWORD PTR [rbx],rdx
    1056:	mov    rax,QWORD PTR [rsi+0x20]
    105a:	mov    rax,QWORD PTR [rax]
    105d:	mov    QWORD PTR [rbx+0x8],rax
    1061:	mov    QWORD PTR [rsp],rax
    1065:	mov    QWORD PTR [rbx+0x10],0x3
    106d:	mov    eax,0x1
    1072:	test   rdx,0x1
    1079:	je     1087 <botlish_fn_5+0x8a>
    107f:	mov    r14,rdx
    1082:	jmp    10aa <botlish_fn_5+0xad>
    1087:	xor    eax,eax
    1089:	test   rdx,0x7
    1090:	je     109e <botlish_fn_5+0xa1>
    1096:	mov    r14,rdx
    1099:	jmp    10aa <botlish_fn_5+0xad>
    109e:	movzx  rax,BYTE PTR [rdx]
    10a2:	mov    r14,rdx
    10a5:	cmp    al,0x1
    10a7:	sete   al
    10aa:	test   al,al
    10ac:	jne    10d0 <botlish_fn_5+0xd3>
    10b2:	mov    rax,QWORD PTR [rdi+0x10]
    10b6:	mov    r13,rdi
    10b9:	mov    rcx,QWORD PTR [rax+0x50]
    10bd:	xor    rdx,rdx
    10c0:	mov    rsi,r14
    10c3:	call   10c8 <botlish_fn_5+0xcb>
			10c4: R_X86_64_PLT32	rt_type_error-0x4
    10c8:	mov    rdi,r13
    10cb:	jmp    1194 <botlish_fn_5+0x197>
    10d0:	mov    rsi,r14
    10d3:	mov    r13,rdi
    10d6:	test   rsi,0x1
    10dd:	jne    10eb <botlish_fn_5+0xee>
    10e3:	mov    r14,rsi
    10e6:	jmp    110a <botlish_fn_5+0x10d>
    10eb:	mov    rax,rsi
    10ee:	add    rax,0x2
    10f2:	mov    r14,rsi
    10f5:	seto   sil
    10f9:	test   sil,sil
    10fc:	jne    110a <botlish_fn_5+0x10d>
    1102:	mov    r12,rax
    1105:	jmp    111d <botlish_fn_5+0x120>
    110a:	mov    edx,0x3
    110f:	mov    rsi,r14
    1112:	mov    rdi,r13
    1115:	call   111a <botlish_fn_5+0x11d>
			1116: R_X86_64_PLT32	rt_int_add-0x4
    111a:	mov    r12,rax
    111d:	mov    ecx,0x1
    1122:	mov    rsi,r14
    1125:	test   rsi,0x1
    112c:	jne    1150 <botlish_fn_5+0x153>
    1132:	xor    ecx,ecx
    1134:	mov    rsi,r14
    1137:	test   rsi,0x7
    113e:	jne    1150 <botlish_fn_5+0x153>
    1144:	mov    rsi,r14
    1147:	movzx  rax,BYTE PTR [rsi]
    114b:	cmp    al,0x1
    114d:	sete   cl
    1150:	test   cl,cl
    1152:	jne    1176 <botlish_fn_5+0x179>
    1158:	mov    rdi,r13
    115b:	mov    rax,QWORD PTR [rdi+0x10]
    115f:	mov    rcx,QWORD PTR [rax+0x58]
    1163:	xor    rdx,rdx
    1166:	mov    rsi,r14
    1169:	call   116e <botlish_fn_5+0x171>
			116a: R_X86_64_PLT32	rt_type_error-0x4
    116e:	mov    rdi,r13
    1171:	jmp    1194 <botlish_fn_5+0x197>
    1176:	mov    rcx,r12
    1179:	mov    rdx,r14
    117c:	mov    rsi,QWORD PTR [rsp]
    1180:	mov    rdi,r13
    1183:	call   1188 <botlish_fn_5+0x18b>
			1184: R_X86_64_PLT32	rt_str_region_check-0x4
    1188:	test   rax,rax
    118b:	jne    11bf <botlish_fn_5+0x1c2>
    1191:	mov    rdi,r13
    1194:	mov    rdi,r13
    1197:	mov    QWORD PTR [rdi],rbx
    119a:	xor    rax,rax
    119d:	mov    rbx,QWORD PTR [rsp+0x10]
    11a2:	mov    r12,QWORD PTR [rsp+0x18]
    11a7:	mov    r13,QWORD PTR [rsp+0x20]
    11ac:	mov    r14,QWORD PTR [rsp+0x28]
    11b1:	mov    r15,QWORD PTR [rsp+0x30]
    11b6:	add    rsp,0x40
    11ba:	mov    rsp,rbp
    11bd:	pop    rbp
    11be:	ret
    11bf:	mov    rdi,r13
    11c2:	mov    QWORD PTR [rdi],rbx
    11c5:	mov    rcx,r15
    11c8:	mov    rsi,r14
    11cb:	mov    QWORD PTR [rcx],rsi
    11ce:	mov    QWORD PTR [rcx+0x8],r12
    11d2:	mov    rax,QWORD PTR [rsp]
    11d6:	mov    rbx,QWORD PTR [rsp+0x10]
    11db:	mov    r12,QWORD PTR [rsp+0x18]
    11e0:	mov    r13,QWORD PTR [rsp+0x20]
    11e5:	mov    r14,QWORD PTR [rsp+0x28]
    11ea:	mov    r15,QWORD PTR [rsp+0x30]
    11ef:	add    rsp,0x40
    11f3:	mov    rsp,rbp
    11f6:	pop    rbp
    11f7:	ret
    11f8:	mov    r13,rdi
    11fb:	call   1200 <botlish_fn_5+0x203>
			11fc: R_X86_64_PLT32	rt_stack_overflow-0x4
    1200:	xor    rax,rax
    1203:	mov    rbx,QWORD PTR [rsp+0x10]
    1208:	mov    r12,QWORD PTR [rsp+0x18]
    120d:	mov    r13,QWORD PTR [rsp+0x20]
    1212:	mov    r14,QWORD PTR [rsp+0x28]
    1217:	mov    r15,QWORD PTR [rsp+0x30]
    121c:	add    rsp,0x40
    1220:	mov    rsp,rbp
    1223:	pop    rbp
    1224:	ret

0000000000001225 <botlish_entry_5: char_at<generic>>:
    1225:	push   rbp
    1226:	mov    rbp,rsp
    1229:	ud2

000000000000122b <botlish_fn_6: is_local_char<str>>:
    122b:	push   rbp
    122c:	mov    rbp,rsp
    122f:	sub    rsp,0x20
    1233:	mov    QWORD PTR [rsp],rbx
    1237:	mov    QWORD PTR [rsp+0x8],r12
    123c:	mov    QWORD PTR [rsp+0x10],r13
    1241:	mov    r13,rsi
    1244:	mov    rbx,QWORD PTR [rdi]
    1247:	mov    rax,QWORD PTR [rdi+0x8]
    124b:	lea    rcx,[rbx+0x8]
    124f:	cmp    rcx,rax
    1252:	ja     13b5 <botlish_fn_6+0x18a>
    1258:	lea    rax,[rbx+0x8]
    125c:	mov    QWORD PTR [rdi],rax
    125f:	mov    r12,rdi
    1262:	mov    QWORD PTR [rbx],0x0
    1269:	mov    rsi,r13
    126c:	mov    rdi,r12
    126f:	call   1274 <botlish_fn_6+0x49>
			1270: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    1274:	test   rax,rax
    1277:	jne    129d <botlish_fn_6+0x72>
    127d:	mov    rdi,r12
    1280:	mov    QWORD PTR [rdi],rbx
    1283:	xor    rax,rax
    1286:	mov    rbx,QWORD PTR [rsp]
    128a:	mov    r12,QWORD PTR [rsp+0x8]
    128f:	mov    r13,QWORD PTR [rsp+0x10]
    1294:	add    rsp,0x20
    1298:	mov    rsp,rbp
    129b:	pop    rbp
    129c:	ret
    129d:	cmp    rax,0x6
    12a1:	je     1390 <botlish_fn_6+0x165>
    12a7:	mov    rdi,r12
    12aa:	mov    rax,QWORD PTR [rdi+0x10]
    12ae:	mov    rsi,QWORD PTR [rax+0x60]
    12b2:	mov    edx,0x1
    12b7:	mov    ecx,0x3
    12bc:	mov    r8,r13
    12bf:	call   12c4 <botlish_fn_6+0x99>
			12c0: R_X86_64_PLT32	rt_str_region_eq-0x4
    12c4:	cmp    rax,0x6
    12c8:	je     1383 <botlish_fn_6+0x158>
    12ce:	mov    rdi,r12
    12d1:	mov    rax,QWORD PTR [rdi+0x10]
    12d5:	mov    rsi,QWORD PTR [rax+0x68]
    12d9:	mov    edx,0x1
    12de:	mov    ecx,0x3
    12e3:	mov    r8,r13
    12e6:	call   12eb <botlish_fn_6+0xc0>
			12e7: R_X86_64_PLT32	rt_str_region_eq-0x4
    12eb:	cmp    rax,0x6
    12ef:	je     1379 <botlish_fn_6+0x14e>
    12f5:	mov    rdi,r12
    12f8:	mov    rax,QWORD PTR [rdi+0x10]
    12fc:	mov    rsi,QWORD PTR [rax+0x70]
    1300:	mov    edx,0x1
    1305:	mov    ecx,0x3
    130a:	mov    r8,r13
    130d:	call   1312 <botlish_fn_6+0xe7>
			130e: R_X86_64_PLT32	rt_str_region_eq-0x4
    1312:	cmp    rax,0x6
    1316:	je     136f <botlish_fn_6+0x144>
    131c:	mov    rdi,r12
    131f:	mov    rcx,QWORD PTR [rdi+0x10]
    1323:	mov    rsi,QWORD PTR [rcx+0x50]
    1327:	mov    edx,0x1
    132c:	mov    ecx,0x3
    1331:	mov    r8,r13
    1334:	call   1339 <botlish_fn_6+0x10e>
			1335: R_X86_64_PLT32	rt_str_region_eq-0x4
    1339:	cmp    rax,0x6
    133d:	je     1365 <botlish_fn_6+0x13a>
    1343:	mov    rdi,r12
    1346:	mov    rsi,QWORD PTR [rdi+0x10]
    134a:	mov    rsi,QWORD PTR [rsi+0x78]
    134e:	mov    edx,0x1
    1353:	mov    ecx,0x3
    1358:	mov    r8,r13
    135b:	call   1360 <botlish_fn_6+0x135>
			135c: R_X86_64_PLT32	rt_str_region_eq-0x4
    1360:	jmp    1388 <botlish_fn_6+0x15d>
    1365:	mov    eax,0x6
    136a:	jmp    1388 <botlish_fn_6+0x15d>
    136f:	mov    eax,0x6
    1374:	jmp    1388 <botlish_fn_6+0x15d>
    1379:	mov    eax,0x6
    137e:	jmp    1388 <botlish_fn_6+0x15d>
    1383:	mov    eax,0x6
    1388:	mov    rdi,r12
    138b:	jmp    1398 <botlish_fn_6+0x16d>
    1390:	mov    eax,0x6
    1395:	mov    rdi,r12
    1398:	mov    rdi,r12
    139b:	mov    QWORD PTR [rdi],rbx
    139e:	mov    rbx,QWORD PTR [rsp]
    13a2:	mov    r12,QWORD PTR [rsp+0x8]
    13a7:	mov    r13,QWORD PTR [rsp+0x10]
    13ac:	add    rsp,0x20
    13b0:	mov    rsp,rbp
    13b3:	pop    rbp
    13b4:	ret
    13b5:	mov    r12,rdi
    13b8:	call   13bd <botlish_fn_6+0x192>
			13b9: R_X86_64_PLT32	rt_stack_overflow-0x4
    13bd:	xor    rax,rax
    13c0:	mov    rbx,QWORD PTR [rsp]
    13c4:	mov    r12,QWORD PTR [rsp+0x8]
    13c9:	mov    r13,QWORD PTR [rsp+0x10]
    13ce:	add    rsp,0x20
    13d2:	mov    rsp,rbp
    13d5:	pop    rbp
    13d6:	ret

00000000000013d7 <botlish_entry_6: is_local_char<str>>:
    13d7:	push   rbp
    13d8:	mov    rbp,rsp
    13db:	mov    rsi,QWORD PTR [rdx]
    13de:	call   13e3 <botlish_entry_6+0xc>
			13df: R_X86_64_PLT32	botlish_fn_6-0x4 ; is_local_char<str>
    13e3:	mov    rsp,rbp
    13e6:	pop    rbp
    13e7:	ret

00000000000013e8 <botlish_fn_7: is_label_char<str>>:
    13e8:	push   rbp
    13e9:	mov    rbp,rsp
    13ec:	sub    rsp,0x20
    13f0:	mov    QWORD PTR [rsp],rbx
    13f4:	mov    QWORD PTR [rsp+0x8],r12
    13f9:	mov    QWORD PTR [rsp+0x10],r13
    13fe:	mov    r13,rsi
    1401:	mov    rbx,QWORD PTR [rdi]
    1404:	mov    rax,QWORD PTR [rdi+0x8]
    1408:	lea    rcx,[rbx+0x8]
    140c:	cmp    rcx,rax
    140f:	ja     14ae <botlish_fn_7+0xc6>
    1415:	lea    rax,[rbx+0x8]
    1419:	mov    QWORD PTR [rdi],rax
    141c:	mov    r12,rdi
    141f:	mov    QWORD PTR [rbx],0x0
    1426:	mov    rsi,r13
    1429:	mov    rdi,r12
    142c:	call   1431 <botlish_fn_7+0x49>
			142d: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    1431:	test   rax,rax
    1434:	jne    145a <botlish_fn_7+0x72>
    143a:	mov    rdi,r12
    143d:	mov    QWORD PTR [rdi],rbx
    1440:	xor    rax,rax
    1443:	mov    rbx,QWORD PTR [rsp]
    1447:	mov    r12,QWORD PTR [rsp+0x8]
    144c:	mov    r13,QWORD PTR [rsp+0x10]
    1451:	add    rsp,0x20
    1455:	mov    rsp,rbp
    1458:	pop    rbp
    1459:	ret
    145a:	cmp    rax,0x6
    145e:	je     1489 <botlish_fn_7+0xa1>
    1464:	mov    rdi,r12
    1467:	mov    rax,QWORD PTR [rdi+0x10]
    146b:	mov    rsi,QWORD PTR [rax+0x78]
    146f:	mov    edx,0x1
    1474:	mov    ecx,0x3
    1479:	mov    r8,r13
    147c:	call   1481 <botlish_fn_7+0x99>
			147d: R_X86_64_PLT32	rt_str_region_eq-0x4
    1481:	mov    rdi,r12
    1484:	jmp    1491 <botlish_fn_7+0xa9>
    1489:	mov    eax,0x6
    148e:	mov    rdi,r12
    1491:	mov    rdi,r12
    1494:	mov    QWORD PTR [rdi],rbx
    1497:	mov    rbx,QWORD PTR [rsp]
    149b:	mov    r12,QWORD PTR [rsp+0x8]
    14a0:	mov    r13,QWORD PTR [rsp+0x10]
    14a5:	add    rsp,0x20
    14a9:	mov    rsp,rbp
    14ac:	pop    rbp
    14ad:	ret
    14ae:	mov    r12,rdi
    14b1:	call   14b6 <botlish_fn_7+0xce>
			14b2: R_X86_64_PLT32	rt_stack_overflow-0x4
    14b6:	xor    rax,rax
    14b9:	mov    rbx,QWORD PTR [rsp]
    14bd:	mov    r12,QWORD PTR [rsp+0x8]
    14c2:	mov    r13,QWORD PTR [rsp+0x10]
    14c7:	add    rsp,0x20
    14cb:	mov    rsp,rbp
    14ce:	pop    rbp
    14cf:	ret

00000000000014d0 <botlish_entry_7: is_label_char<str>>:
    14d0:	push   rbp
    14d1:	mov    rbp,rsp
    14d4:	mov    rsi,QWORD PTR [rdx]
    14d7:	call   14dc <botlish_entry_7+0xc>
			14d8: R_X86_64_PLT32	botlish_fn_7-0x4 ; is_label_char<str>
    14dc:	mov    rsp,rbp
    14df:	pop    rbp
    14e0:	ret
    14e1:	add    BYTE PTR [rax],al
    14e3:	add    BYTE PTR [rax],al
    14e5:	add    BYTE PTR [rax],al
	...

00000000000014e8 <botlish_fn_8: scan_local<generic>>:
    14e8:	push   rbp
    14e9:	mov    rbp,rsp
    14ec:	sub    rsp,0x20
    14f0:	mov    QWORD PTR [rsp],rbx
    14f4:	mov    QWORD PTR [rsp+0x8],r12
    14f9:	mov    QWORD PTR [rsp+0x10],r13
    14fe:	mov    QWORD PTR [rsp+0x18],r14
    1503:	mov    r12,QWORD PTR [rdi]
    1506:	mov    rax,QWORD PTR [rdi+0x8]
    150a:	lea    rcx,[r12+0x18]
    150f:	cmp    rcx,rax
    1512:	ja     16f7 <botlish_fn_8+0x20f>
    1518:	lea    rax,[r12+0x18]
    151d:	mov    QWORD PTR [rdi],rax
    1520:	mov    r13,rdi
    1523:	mov    QWORD PTR [r12],0x0
    152b:	mov    QWORD PTR [r12+0x8],0x0
    1534:	mov    QWORD PTR [r12+0x10],0x0
    153d:	mov    QWORD PTR [r12],rdx
    1541:	mov    rbx,rsi
    1544:	mov    rsi,rdx
    1547:	mov    rax,QWORD PTR [rbx+0x20]
    154b:	mov    rdx,QWORD PTR [rax]
    154e:	mov    ecx,0x1
    1553:	test   rsi,0x1
    155a:	jne    1578 <botlish_fn_8+0x90>
    1560:	xor    ecx,ecx
    1562:	test   rsi,0x7
    1569:	jne    1578 <botlish_fn_8+0x90>
    156f:	movzx  rax,BYTE PTR [rsi]
    1573:	cmp    al,0x1
    1575:	sete   cl
    1578:	test   cl,cl
    157a:	jne    159e <botlish_fn_8+0xb6>
    1580:	mov    rdi,r13
    1583:	mov    rax,QWORD PTR [rdi+0x10]
    1587:	mov    rcx,QWORD PTR [rax+0x80]
    158e:	xor    rdx,rdx
    1591:	call   1596 <botlish_fn_8+0xae>
			1592: R_X86_64_PLT32	rt_type_error-0x4
    1596:	mov    rdi,r13
    1599:	jmp    1635 <botlish_fn_8+0x14d>
    159e:	mov    rax,rsi
    15a1:	and    rax,rdx
    15a4:	mov    r14,rsi
    15a7:	test   rax,0x1
    15ad:	jne    15d3 <botlish_fn_8+0xeb>
    15b3:	mov    rsi,r14
    15b6:	mov    rdi,r13
    15b9:	call   15be <botlish_fn_8+0xd6>
			15ba: R_X86_64_PLT32	rt_int_cmp-0x4
    15be:	mov    ecx,0x2
    15c3:	test   rax,rax
    15c6:	cmovge rcx,QWORD PTR [rip+0x152]        # 1720 <botlish_fn_8+0x238>
    15ce:	jmp    15e6 <botlish_fn_8+0xfe>
    15d3:	mov    ecx,0x2
    15d8:	mov    rsi,r14
    15db:	cmp    rsi,rdx
    15de:	cmovge rcx,QWORD PTR [rip+0x13a]        # 1720 <botlish_fn_8+0x238>
    15e6:	cmp    rcx,0x6
    15ea:	je     16cf <botlish_fn_8+0x1e7>
    15f0:	mov    rdi,QWORD PTR [rbx+0x20]
    15f4:	mov    rsi,QWORD PTR [rdi+0x8]
    15f8:	mov    QWORD PTR [r12+0x8],rsi
    15fd:	mov    rdx,r14
    1600:	mov    rdi,r13
    1603:	call   1608 <botlish_fn_8+0x120>
			1604: R_X86_64_PLT32	botlish_fn_4-0x4 ; char_at<generic>
    1608:	test   rax,rax
    160b:	jne    1619 <botlish_fn_8+0x131>
    1611:	mov    rdi,r13
    1614:	jmp    1635 <botlish_fn_8+0x14d>
    1619:	mov    QWORD PTR [r12+0x8],rax
    161e:	mov    rsi,rax
    1621:	mov    rdi,r13
    1624:	call   1629 <botlish_fn_8+0x141>
			1625: R_X86_64_PLT32	botlish_fn_6-0x4 ; is_local_char<str>
    1629:	test   rax,rax
    162c:	jne    165a <botlish_fn_8+0x172>
    1632:	mov    rdi,r13
    1635:	mov    rdi,r13
    1638:	mov    QWORD PTR [rdi],r12
    163b:	xor    rax,rax
    163e:	mov    rbx,QWORD PTR [rsp]
    1642:	mov    r12,QWORD PTR [rsp+0x8]
    1647:	mov    r13,QWORD PTR [rsp+0x10]
    164c:	mov    r14,QWORD PTR [rsp+0x18]
    1651:	add    rsp,0x20
    1655:	mov    rsp,rbp
    1658:	pop    rbp
    1659:	ret
    165a:	cmp    rax,0x6
    165e:	je     166f <botlish_fn_8+0x187>
    1664:	mov    rax,r14
    1667:	mov    rdi,r13
    166a:	jmp    16d5 <botlish_fn_8+0x1ed>
    166f:	mov    QWORD PTR [r12+0x8],rbx
    1674:	mov    QWORD PTR [r12+0x10],0x3
    167d:	mov    rsi,r14
    1680:	test   rsi,0x1
    1687:	je     16ad <botlish_fn_8+0x1c5>
    168d:	mov    rsi,r14
    1690:	mov    rcx,rsi
    1693:	add    rcx,0x2
    1697:	seto   al
    169a:	test   al,al
    169c:	jne    16ad <botlish_fn_8+0x1c5>
    16a2:	mov    rsi,rcx
    16a5:	mov    r14,rcx
    16a8:	jmp    16c3 <botlish_fn_8+0x1db>
    16ad:	mov    edx,0x3
    16b2:	mov    rsi,r14
    16b5:	mov    rdi,r13
    16b8:	call   16bd <botlish_fn_8+0x1d5>
			16b9: R_X86_64_PLT32	rt_int_add-0x4
    16bd:	mov    rsi,rax
    16c0:	mov    r14,rax
    16c3:	mov    QWORD PTR [r12],rsi
    16c7:	mov    rsi,r14
    16ca:	jmp    1547 <botlish_fn_8+0x5f>
    16cf:	mov    rax,r14
    16d2:	mov    rdi,r13
    16d5:	mov    rdi,r13
    16d8:	mov    QWORD PTR [rdi],r12
    16db:	mov    rbx,QWORD PTR [rsp]
    16df:	mov    r12,QWORD PTR [rsp+0x8]
    16e4:	mov    r13,QWORD PTR [rsp+0x10]
    16e9:	mov    r14,QWORD PTR [rsp+0x18]
    16ee:	add    rsp,0x20
    16f2:	mov    rsp,rbp
    16f5:	pop    rbp
    16f6:	ret
    16f7:	mov    r13,rdi
    16fa:	call   16ff <botlish_fn_8+0x217>
			16fb: R_X86_64_PLT32	rt_stack_overflow-0x4
    16ff:	xor    rax,rax
    1702:	mov    rbx,QWORD PTR [rsp]
    1706:	mov    r12,QWORD PTR [rsp+0x8]
    170b:	mov    r13,QWORD PTR [rsp+0x10]
    1710:	mov    r14,QWORD PTR [rsp+0x18]
    1715:	add    rsp,0x20
    1719:	mov    rsp,rbp
    171c:	pop    rbp
    171d:	ret
    171e:	add    BYTE PTR [rax],al
    1720:	(bad)
    1721:	add    BYTE PTR [rax],al
    1723:	add    BYTE PTR [rax],al
    1725:	add    BYTE PTR [rax],al
	...

0000000000001728 <botlish_entry_8: scan_local<generic>>:
    1728:	push   rbp
    1729:	mov    rbp,rsp
    172c:	mov    rdx,QWORD PTR [rdx]
    172f:	call   1734 <botlish_entry_8+0xc>
			1730: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_local<generic>
    1734:	mov    rsp,rbp
    1737:	pop    rbp
    1738:	ret
    1739:	add    BYTE PTR [rax],al
    173b:	add    BYTE PTR [rax],al
    173d:	add    BYTE PTR [rax],al
	...

0000000000001740 <botlish_fn_9: scan_label<generic>>:
    1740:	push   rbp
    1741:	mov    rbp,rsp
    1744:	sub    rsp,0x20
    1748:	mov    QWORD PTR [rsp],rbx
    174c:	mov    QWORD PTR [rsp+0x8],r12
    1751:	mov    QWORD PTR [rsp+0x10],r13
    1756:	mov    QWORD PTR [rsp+0x18],r14
    175b:	mov    r12,QWORD PTR [rdi]
    175e:	mov    rax,QWORD PTR [rdi+0x8]
    1762:	lea    rcx,[r12+0x18]
    1767:	cmp    rcx,rax
    176a:	ja     194f <botlish_fn_9+0x20f>
    1770:	lea    rax,[r12+0x18]
    1775:	mov    QWORD PTR [rdi],rax
    1778:	mov    r13,rdi
    177b:	mov    QWORD PTR [r12],0x0
    1783:	mov    QWORD PTR [r12+0x8],0x0
    178c:	mov    QWORD PTR [r12+0x10],0x0
    1795:	mov    QWORD PTR [r12],rdx
    1799:	mov    rbx,rsi
    179c:	mov    rsi,rdx
    179f:	mov    rax,QWORD PTR [rbx+0x20]
    17a3:	mov    rdx,QWORD PTR [rax]
    17a6:	mov    ecx,0x1
    17ab:	test   rsi,0x1
    17b2:	jne    17d0 <botlish_fn_9+0x90>
    17b8:	xor    ecx,ecx
    17ba:	test   rsi,0x7
    17c1:	jne    17d0 <botlish_fn_9+0x90>
    17c7:	movzx  rax,BYTE PTR [rsi]
    17cb:	cmp    al,0x1
    17cd:	sete   cl
    17d0:	test   cl,cl
    17d2:	jne    17f6 <botlish_fn_9+0xb6>
    17d8:	mov    rdi,r13
    17db:	mov    rax,QWORD PTR [rdi+0x10]
    17df:	mov    rcx,QWORD PTR [rax+0x80]
    17e6:	xor    rdx,rdx
    17e9:	call   17ee <botlish_fn_9+0xae>
			17ea: R_X86_64_PLT32	rt_type_error-0x4
    17ee:	mov    rdi,r13
    17f1:	jmp    188d <botlish_fn_9+0x14d>
    17f6:	mov    rax,rsi
    17f9:	and    rax,rdx
    17fc:	mov    r14,rsi
    17ff:	test   rax,0x1
    1805:	jne    182b <botlish_fn_9+0xeb>
    180b:	mov    rsi,r14
    180e:	mov    rdi,r13
    1811:	call   1816 <botlish_fn_9+0xd6>
			1812: R_X86_64_PLT32	rt_int_cmp-0x4
    1816:	mov    ecx,0x2
    181b:	test   rax,rax
    181e:	cmovge rcx,QWORD PTR [rip+0x152]        # 1978 <botlish_fn_9+0x238>
    1826:	jmp    183e <botlish_fn_9+0xfe>
    182b:	mov    ecx,0x2
    1830:	mov    rsi,r14
    1833:	cmp    rsi,rdx
    1836:	cmovge rcx,QWORD PTR [rip+0x13a]        # 1978 <botlish_fn_9+0x238>
    183e:	cmp    rcx,0x6
    1842:	je     1927 <botlish_fn_9+0x1e7>
    1848:	mov    rdi,QWORD PTR [rbx+0x20]
    184c:	mov    rsi,QWORD PTR [rdi+0x8]
    1850:	mov    QWORD PTR [r12+0x8],rsi
    1855:	mov    rdx,r14
    1858:	mov    rdi,r13
    185b:	call   1860 <botlish_fn_9+0x120>
			185c: R_X86_64_PLT32	botlish_fn_4-0x4 ; char_at<generic>
    1860:	test   rax,rax
    1863:	jne    1871 <botlish_fn_9+0x131>
    1869:	mov    rdi,r13
    186c:	jmp    188d <botlish_fn_9+0x14d>
    1871:	mov    QWORD PTR [r12+0x8],rax
    1876:	mov    rsi,rax
    1879:	mov    rdi,r13
    187c:	call   1881 <botlish_fn_9+0x141>
			187d: R_X86_64_PLT32	botlish_fn_7-0x4 ; is_label_char<str>
    1881:	test   rax,rax
    1884:	jne    18b2 <botlish_fn_9+0x172>
    188a:	mov    rdi,r13
    188d:	mov    rdi,r13
    1890:	mov    QWORD PTR [rdi],r12
    1893:	xor    rax,rax
    1896:	mov    rbx,QWORD PTR [rsp]
    189a:	mov    r12,QWORD PTR [rsp+0x8]
    189f:	mov    r13,QWORD PTR [rsp+0x10]
    18a4:	mov    r14,QWORD PTR [rsp+0x18]
    18a9:	add    rsp,0x20
    18ad:	mov    rsp,rbp
    18b0:	pop    rbp
    18b1:	ret
    18b2:	cmp    rax,0x6
    18b6:	je     18c7 <botlish_fn_9+0x187>
    18bc:	mov    rax,r14
    18bf:	mov    rdi,r13
    18c2:	jmp    192d <botlish_fn_9+0x1ed>
    18c7:	mov    QWORD PTR [r12+0x8],rbx
    18cc:	mov    QWORD PTR [r12+0x10],0x3
    18d5:	mov    rsi,r14
    18d8:	test   rsi,0x1
    18df:	je     1905 <botlish_fn_9+0x1c5>
    18e5:	mov    rsi,r14
    18e8:	mov    rcx,rsi
    18eb:	add    rcx,0x2
    18ef:	seto   al
    18f2:	test   al,al
    18f4:	jne    1905 <botlish_fn_9+0x1c5>
    18fa:	mov    rsi,rcx
    18fd:	mov    r14,rcx
    1900:	jmp    191b <botlish_fn_9+0x1db>
    1905:	mov    edx,0x3
    190a:	mov    rsi,r14
    190d:	mov    rdi,r13
    1910:	call   1915 <botlish_fn_9+0x1d5>
			1911: R_X86_64_PLT32	rt_int_add-0x4
    1915:	mov    rsi,rax
    1918:	mov    r14,rax
    191b:	mov    QWORD PTR [r12],rsi
    191f:	mov    rsi,r14
    1922:	jmp    179f <botlish_fn_9+0x5f>
    1927:	mov    rax,r14
    192a:	mov    rdi,r13
    192d:	mov    rdi,r13
    1930:	mov    QWORD PTR [rdi],r12
    1933:	mov    rbx,QWORD PTR [rsp]
    1937:	mov    r12,QWORD PTR [rsp+0x8]
    193c:	mov    r13,QWORD PTR [rsp+0x10]
    1941:	mov    r14,QWORD PTR [rsp+0x18]
    1946:	add    rsp,0x20
    194a:	mov    rsp,rbp
    194d:	pop    rbp
    194e:	ret
    194f:	mov    r13,rdi
    1952:	call   1957 <botlish_fn_9+0x217>
			1953: R_X86_64_PLT32	rt_stack_overflow-0x4
    1957:	xor    rax,rax
    195a:	mov    rbx,QWORD PTR [rsp]
    195e:	mov    r12,QWORD PTR [rsp+0x8]
    1963:	mov    r13,QWORD PTR [rsp+0x10]
    1968:	mov    r14,QWORD PTR [rsp+0x18]
    196d:	add    rsp,0x20
    1971:	mov    rsp,rbp
    1974:	pop    rbp
    1975:	ret
    1976:	add    BYTE PTR [rax],al
    1978:	(bad)
    1979:	add    BYTE PTR [rax],al
    197b:	add    BYTE PTR [rax],al
    197d:	add    BYTE PTR [rax],al
	...

0000000000001980 <botlish_entry_9: scan_label<generic>>:
    1980:	push   rbp
    1981:	mov    rbp,rsp
    1984:	mov    rdx,QWORD PTR [rdx]
    1987:	call   198c <botlish_entry_9+0xc>
			1988: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_label<generic>
    198c:	mov    rsp,rbp
    198f:	pop    rbp
    1990:	ret
    1991:	add    BYTE PTR [rax],al
    1993:	add    BYTE PTR [rax],al
    1995:	add    BYTE PTR [rax],al
	...

0000000000001998 <botlish_fn_10: scan_alpha<generic>>:
    1998:	push   rbp
    1999:	mov    rbp,rsp
    199c:	sub    rsp,0x20
    19a0:	mov    QWORD PTR [rsp],rbx
    19a4:	mov    QWORD PTR [rsp+0x8],r12
    19a9:	mov    QWORD PTR [rsp+0x10],r13
    19ae:	mov    QWORD PTR [rsp+0x18],r14
    19b3:	mov    r12,QWORD PTR [rdi]
    19b6:	mov    rax,QWORD PTR [rdi+0x8]
    19ba:	lea    rcx,[r12+0x18]
    19bf:	cmp    rcx,rax
    19c2:	ja     1ba2 <botlish_fn_10+0x20a>
    19c8:	lea    rax,[r12+0x18]
    19cd:	mov    QWORD PTR [rdi],rax
    19d0:	mov    r13,rdi
    19d3:	mov    QWORD PTR [r12],0x0
    19db:	mov    QWORD PTR [r12+0x8],0x0
    19e4:	mov    QWORD PTR [r12+0x10],0x0
    19ed:	mov    QWORD PTR [r12],rdx
    19f1:	mov    rbx,rsi
    19f4:	mov    rsi,rdx
    19f7:	mov    rax,QWORD PTR [rbx+0x20]
    19fb:	mov    rdx,QWORD PTR [rax]
    19fe:	mov    ecx,0x1
    1a03:	test   rsi,0x1
    1a0a:	jne    1a28 <botlish_fn_10+0x90>
    1a10:	xor    ecx,ecx
    1a12:	test   rsi,0x7
    1a19:	jne    1a28 <botlish_fn_10+0x90>
    1a1f:	movzx  rax,BYTE PTR [rsi]
    1a23:	cmp    al,0x1
    1a25:	sete   cl
    1a28:	test   cl,cl
    1a2a:	jne    1a4e <botlish_fn_10+0xb6>
    1a30:	mov    rdi,r13
    1a33:	mov    rax,QWORD PTR [rdi+0x10]
    1a37:	mov    rcx,QWORD PTR [rax+0x80]
    1a3e:	xor    rdx,rdx
    1a41:	call   1a46 <botlish_fn_10+0xae>
			1a42: R_X86_64_PLT32	rt_type_error-0x4
    1a46:	mov    rdi,r13
    1a49:	jmp    1ae0 <botlish_fn_10+0x148>
    1a4e:	mov    rax,rsi
    1a51:	and    rax,rdx
    1a54:	mov    r14,rsi
    1a57:	test   rax,0x1
    1a5d:	jne    1a83 <botlish_fn_10+0xeb>
    1a63:	mov    rsi,r14
    1a66:	mov    rdi,r13
    1a69:	call   1a6e <botlish_fn_10+0xd6>
			1a6a: R_X86_64_PLT32	rt_int_cmp-0x4
    1a6e:	mov    ecx,0x2
    1a73:	test   rax,rax
    1a76:	cmovge rcx,QWORD PTR [rip+0x152]        # 1bd0 <botlish_fn_10+0x238>
    1a7e:	jmp    1a96 <botlish_fn_10+0xfe>
    1a83:	mov    ecx,0x2
    1a88:	mov    rsi,r14
    1a8b:	cmp    rsi,rdx
    1a8e:	cmovge rcx,QWORD PTR [rip+0x13a]        # 1bd0 <botlish_fn_10+0x238>
    1a96:	cmp    rcx,0x6
    1a9a:	je     1b7a <botlish_fn_10+0x1e2>
    1aa0:	mov    rdi,QWORD PTR [rbx+0x20]
    1aa4:	mov    rsi,QWORD PTR [rdi+0x8]
    1aa8:	mov    QWORD PTR [r12+0x8],rsi
    1aad:	mov    rdx,r14
    1ab0:	mov    rdi,r13
    1ab3:	call   1ab8 <botlish_fn_10+0x120>
			1ab4: R_X86_64_PLT32	botlish_fn_4-0x4 ; char_at<generic>
    1ab8:	test   rax,rax
    1abb:	mov    rsi,rax
    1abe:	jne    1acc <botlish_fn_10+0x134>
    1ac4:	mov    rdi,r13
    1ac7:	jmp    1ae0 <botlish_fn_10+0x148>
    1acc:	mov    rdi,r13
    1acf:	call   1ad4 <botlish_fn_10+0x13c>
			1ad0: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    1ad4:	test   rax,rax
    1ad7:	jne    1b05 <botlish_fn_10+0x16d>
    1add:	mov    rdi,r13
    1ae0:	mov    rdi,r13
    1ae3:	mov    QWORD PTR [rdi],r12
    1ae6:	xor    rax,rax
    1ae9:	mov    rbx,QWORD PTR [rsp]
    1aed:	mov    r12,QWORD PTR [rsp+0x8]
    1af2:	mov    r13,QWORD PTR [rsp+0x10]
    1af7:	mov    r14,QWORD PTR [rsp+0x18]
    1afc:	add    rsp,0x20
    1b00:	mov    rsp,rbp
    1b03:	pop    rbp
    1b04:	ret
    1b05:	cmp    rax,0x6
    1b09:	je     1b1a <botlish_fn_10+0x182>
    1b0f:	mov    rax,r14
    1b12:	mov    rdi,r13
    1b15:	jmp    1b80 <botlish_fn_10+0x1e8>
    1b1a:	mov    QWORD PTR [r12+0x8],rbx
    1b1f:	mov    QWORD PTR [r12+0x10],0x3
    1b28:	mov    rsi,r14
    1b2b:	test   rsi,0x1
    1b32:	je     1b58 <botlish_fn_10+0x1c0>
    1b38:	mov    rsi,r14
    1b3b:	mov    rcx,rsi
    1b3e:	add    rcx,0x2
    1b42:	seto   al
    1b45:	test   al,al
    1b47:	jne    1b58 <botlish_fn_10+0x1c0>
    1b4d:	mov    rsi,rcx
    1b50:	mov    r14,rcx
    1b53:	jmp    1b6e <botlish_fn_10+0x1d6>
    1b58:	mov    edx,0x3
    1b5d:	mov    rsi,r14
    1b60:	mov    rdi,r13
    1b63:	call   1b68 <botlish_fn_10+0x1d0>
			1b64: R_X86_64_PLT32	rt_int_add-0x4
    1b68:	mov    rsi,rax
    1b6b:	mov    r14,rax
    1b6e:	mov    QWORD PTR [r12],rsi
    1b72:	mov    rsi,r14
    1b75:	jmp    19f7 <botlish_fn_10+0x5f>
    1b7a:	mov    rax,r14
    1b7d:	mov    rdi,r13
    1b80:	mov    rdi,r13
    1b83:	mov    QWORD PTR [rdi],r12
    1b86:	mov    rbx,QWORD PTR [rsp]
    1b8a:	mov    r12,QWORD PTR [rsp+0x8]
    1b8f:	mov    r13,QWORD PTR [rsp+0x10]
    1b94:	mov    r14,QWORD PTR [rsp+0x18]
    1b99:	add    rsp,0x20
    1b9d:	mov    rsp,rbp
    1ba0:	pop    rbp
    1ba1:	ret
    1ba2:	mov    r13,rdi
    1ba5:	call   1baa <botlish_fn_10+0x212>
			1ba6: R_X86_64_PLT32	rt_stack_overflow-0x4
    1baa:	xor    rax,rax
    1bad:	mov    rbx,QWORD PTR [rsp]
    1bb1:	mov    r12,QWORD PTR [rsp+0x8]
    1bb6:	mov    r13,QWORD PTR [rsp+0x10]
    1bbb:	mov    r14,QWORD PTR [rsp+0x18]
    1bc0:	add    rsp,0x20
    1bc4:	mov    rsp,rbp
    1bc7:	pop    rbp
    1bc8:	ret
    1bc9:	add    BYTE PTR [rax],al
    1bcb:	add    BYTE PTR [rax],al
    1bcd:	add    BYTE PTR [rax],al
    1bcf:	add    BYTE PTR [rsi],al
    1bd1:	add    BYTE PTR [rax],al
    1bd3:	add    BYTE PTR [rax],al
    1bd5:	add    BYTE PTR [rax],al
	...

0000000000001bd8 <botlish_entry_10: scan_alpha<generic>>:
    1bd8:	push   rbp
    1bd9:	mov    rbp,rsp
    1bdc:	mov    rdx,QWORD PTR [rdx]
    1bdf:	call   1be4 <botlish_entry_10+0xc>
			1be0: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_alpha<generic>
    1be4:	mov    rsp,rbp
    1be7:	pop    rbp
    1be8:	ret
    1be9:	add    BYTE PTR [rax],al
    1beb:	add    BYTE PTR [rax],al
    1bed:	add    BYTE PTR [rax],al
	...

0000000000001bf0 <botlish_fn_11: tld_ok<generic>>:
    1bf0:	push   rbp
    1bf1:	mov    rbp,rsp
    1bf4:	sub    rsp,0x30
    1bf8:	mov    QWORD PTR [rsp],rbx
    1bfc:	mov    QWORD PTR [rsp+0x8],r12
    1c01:	mov    QWORD PTR [rsp+0x10],r13
    1c06:	mov    QWORD PTR [rsp+0x18],r14
    1c0b:	mov    QWORD PTR [rsp+0x20],r15
    1c10:	mov    rbx,QWORD PTR [rdi]
    1c13:	mov    rax,QWORD PTR [rdi+0x8]
    1c17:	lea    rcx,[rbx+0x10]
    1c1b:	cmp    rcx,rax
    1c1e:	ja     1e2f <botlish_fn_11+0x23f>
    1c24:	lea    rax,[rbx+0x10]
    1c28:	mov    QWORD PTR [rdi],rax
    1c2b:	mov    r12,rdi
    1c2e:	mov    QWORD PTR [rbx],0x0
    1c35:	mov    QWORD PTR [rbx+0x8],0x0
    1c3d:	mov    QWORD PTR [rbx],rdx
    1c40:	mov    r8,rdx
    1c43:	mov    rax,QWORD PTR [rsi+0x20]
    1c47:	mov    r15,rsi
    1c4a:	mov    rsi,QWORD PTR [rax]
    1c4d:	mov    QWORD PTR [rbx+0x8],rsi
    1c51:	mov    r13,r8
    1c54:	mov    rdx,r13
    1c57:	mov    rdi,r12
    1c5a:	call   1c5f <botlish_fn_11+0x6f>
			1c5b: R_X86_64_PLT32	botlish_fn_10-0x4 ; scan_alpha<generic>
    1c5f:	mov    rcx,rax
    1c62:	mov    r14,rax
    1c65:	test   rax,rcx
    1c68:	jne    1c76 <botlish_fn_11+0x86>
    1c6e:	mov    rdi,r12
    1c71:	jmp    1d4b <botlish_fn_11+0x15b>
    1c76:	mov    rax,r14
    1c79:	mov    QWORD PTR [rbx+0x8],rax
    1c7d:	mov    rsi,r15
    1c80:	mov    rax,QWORD PTR [rsi+0x20]
    1c84:	mov    rdx,QWORD PTR [rax+0x8]
    1c88:	mov    rax,r14
    1c8b:	and    rax,rdx
    1c8e:	test   rax,0x1
    1c94:	jne    1cbd <botlish_fn_11+0xcd>
    1c9a:	mov    rsi,r14
    1c9d:	mov    rdi,r12
    1ca0:	call   1ca5 <botlish_fn_11+0xb5>
			1ca1: R_X86_64_PLT32	rt_int_cmp-0x4
    1ca5:	mov    ecx,0x2
    1caa:	test   rax,rax
    1cad:	cmove  rcx,QWORD PTR [rip+0x1ab]        # 1e60 <botlish_fn_11+0x270>
    1cb5:	mov    rax,r14
    1cb8:	jmp    1cd0 <botlish_fn_11+0xe0>
    1cbd:	mov    ecx,0x2
    1cc2:	mov    rax,r14
    1cc5:	cmp    rax,rdx
    1cc8:	cmove  rcx,QWORD PTR [rip+0x190]        # 1e60 <botlish_fn_11+0x270>
    1cd0:	cmp    rcx,0x6
    1cd4:	je     1cea <botlish_fn_11+0xfa>
    1cda:	mov    ecx,0x2
    1cdf:	mov    rax,rcx
    1ce2:	mov    rdi,r12
    1ce5:	jmp    1e08 <botlish_fn_11+0x218>
    1cea:	mov    ecx,0x1
    1cef:	test   r13,0x1
    1cf6:	je     1d04 <botlish_fn_11+0x114>
    1cfc:	mov    r8,r13
    1cff:	jmp    1d2a <botlish_fn_11+0x13a>
    1d04:	xor    ecx,ecx
    1d06:	test   r13,0x7
    1d0d:	je     1d1b <botlish_fn_11+0x12b>
    1d13:	mov    r8,r13
    1d16:	jmp    1d2a <botlish_fn_11+0x13a>
    1d1b:	movzx  rcx,BYTE PTR [r13+0x0]
    1d20:	mov    r8,r13
    1d23:	rex cmp cl,0x1
    1d27:	sete   cl
    1d2a:	test   cl,cl
    1d2c:	jne    1d75 <botlish_fn_11+0x185>
    1d32:	mov    rdi,r12
    1d35:	mov    rax,QWORD PTR [rdi+0x10]
    1d39:	mov    rcx,QWORD PTR [rax+0x78]
    1d3d:	xor    rdx,rdx
    1d40:	mov    rsi,r8
    1d43:	call   1d48 <botlish_fn_11+0x158>
			1d44: R_X86_64_PLT32	rt_type_error-0x4
    1d48:	mov    rdi,r12
    1d4b:	mov    rdi,r12
    1d4e:	mov    QWORD PTR [rdi],rbx
    1d51:	xor    rax,rax
    1d54:	mov    rbx,QWORD PTR [rsp]
    1d58:	mov    r12,QWORD PTR [rsp+0x8]
    1d5d:	mov    r13,QWORD PTR [rsp+0x10]
    1d62:	mov    r14,QWORD PTR [rsp+0x18]
    1d67:	mov    r15,QWORD PTR [rsp+0x20]
    1d6c:	add    rsp,0x30
    1d70:	mov    rsp,rbp
    1d73:	pop    rbp
    1d74:	ret
    1d75:	mov    rdx,r8
    1d78:	mov    rcx,rax
    1d7b:	and    rcx,rdx
    1d7e:	test   rcx,0x1
    1d85:	jne    1d96 <botlish_fn_11+0x1a6>
    1d8b:	mov    rdx,r8
    1d8e:	mov    rsi,rax
    1d91:	jmp    1db7 <botlish_fn_11+0x1c7>
    1d96:	mov    rdx,r8
    1d99:	mov    rcx,rax
    1d9c:	sub    rcx,rdx
    1d9f:	mov    r14,rax
    1da2:	seto   al
    1da5:	lea    rsi,[rcx+0x1]
    1da9:	test   al,al
    1dab:	je     1dc2 <botlish_fn_11+0x1d2>
    1db1:	mov    rdx,r8
    1db4:	mov    rsi,r14
    1db7:	mov    rdi,r12
    1dba:	call   1dbf <botlish_fn_11+0x1cf>
			1dbb: R_X86_64_PLT32	rt_int_sub-0x4
    1dbf:	mov    rsi,rax
    1dc2:	test   rsi,0x1
    1dc9:	jne    1df4 <botlish_fn_11+0x204>
    1dcf:	mov    edx,0x5
    1dd4:	mov    rdi,r12
    1dd7:	call   1ddc <botlish_fn_11+0x1ec>
			1dd8: R_X86_64_PLT32	rt_int_cmp-0x4
    1ddc:	mov    ecx,0x2
    1de1:	test   rax,rax
    1de4:	mov    rax,rcx
    1de7:	cmovge rax,QWORD PTR [rip+0x71]        # 1e60 <botlish_fn_11+0x270>
    1def:	jmp    1e05 <botlish_fn_11+0x215>
    1df4:	mov    eax,0x2
    1df9:	cmp    rsi,0x5
    1dfd:	cmovge rax,QWORD PTR [rip+0x5b]        # 1e60 <botlish_fn_11+0x270>
    1e05:	mov    rdi,r12
    1e08:	mov    rdi,r12
    1e0b:	mov    QWORD PTR [rdi],rbx
    1e0e:	mov    rbx,QWORD PTR [rsp]
    1e12:	mov    r12,QWORD PTR [rsp+0x8]
    1e17:	mov    r13,QWORD PTR [rsp+0x10]
    1e1c:	mov    r14,QWORD PTR [rsp+0x18]
    1e21:	mov    r15,QWORD PTR [rsp+0x20]
    1e26:	add    rsp,0x30
    1e2a:	mov    rsp,rbp
    1e2d:	pop    rbp
    1e2e:	ret
    1e2f:	mov    r12,rdi
    1e32:	call   1e37 <botlish_fn_11+0x247>
			1e33: R_X86_64_PLT32	rt_stack_overflow-0x4
    1e37:	xor    rax,rax
    1e3a:	mov    rbx,QWORD PTR [rsp]
    1e3e:	mov    r12,QWORD PTR [rsp+0x8]
    1e43:	mov    r13,QWORD PTR [rsp+0x10]
    1e48:	mov    r14,QWORD PTR [rsp+0x18]
    1e4d:	mov    r15,QWORD PTR [rsp+0x20]
    1e52:	add    rsp,0x30
    1e56:	mov    rsp,rbp
    1e59:	pop    rbp
    1e5a:	ret
    1e5b:	add    BYTE PTR [rax],al
    1e5d:	add    BYTE PTR [rax],al
    1e5f:	add    BYTE PTR [rsi],al
    1e61:	add    BYTE PTR [rax],al
    1e63:	add    BYTE PTR [rax],al
    1e65:	add    BYTE PTR [rax],al
	...

0000000000001e68 <botlish_entry_11: tld_ok<generic>>:
    1e68:	push   rbp
    1e69:	mov    rbp,rsp
    1e6c:	mov    rdx,QWORD PTR [rdx]
    1e6f:	call   1e74 <botlish_entry_11+0xc>
			1e70: R_X86_64_PLT32	botlish_fn_11-0x4 ; tld_ok<generic>
    1e74:	mov    rsp,rbp
    1e77:	pop    rbp
    1e78:	ret
    1e79:	add    BYTE PTR [rax],al
    1e7b:	add    BYTE PTR [rax],al
    1e7d:	add    BYTE PTR [rax],al
	...

0000000000001e80 <botlish_fn_12: domain_loop<generic>>:
    1e80:	push   rbp
    1e81:	mov    rbp,rsp
    1e84:	sub    rsp,0x50
    1e88:	mov    QWORD PTR [rsp+0x20],rbx
    1e8d:	mov    QWORD PTR [rsp+0x28],r12
    1e92:	mov    QWORD PTR [rsp+0x30],r13
    1e97:	mov    QWORD PTR [rsp+0x38],r14
    1e9c:	mov    QWORD PTR [rsp+0x40],r15
    1ea1:	mov    r13,QWORD PTR [rdi]
    1ea4:	mov    rax,QWORD PTR [rdi+0x8]
    1ea8:	lea    rcx,[r13+0x10]
    1eac:	cmp    rcx,rax
    1eaf:	ja     212b <botlish_fn_12+0x2ab>
    1eb5:	lea    rax,[r13+0x10]
    1eb9:	mov    QWORD PTR [rdi],rax
    1ebc:	mov    r15,rdi
    1ebf:	mov    QWORD PTR [r13+0x0],0x0
    1ec7:	mov    QWORD PTR [r13+0x8],0x0
    1ecf:	mov    QWORD PTR [r13+0x0],rdx
    1ed3:	mov    QWORD PTR [rsp+0x10],rdx
    1ed8:	lea    rbx,[rsp]
    1edc:	mov    r12,rsi
    1edf:	mov    rax,QWORD PTR [r12+0x20]
    1ee4:	mov    rsi,QWORD PTR [rax]
    1ee7:	mov    QWORD PTR [r13+0x8],rsi
    1eeb:	mov    rdx,QWORD PTR [rsp+0x10]
    1ef0:	mov    rdi,r15
    1ef3:	call   1ef8 <botlish_fn_12+0x78>
			1ef4: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_label<generic>
    1ef8:	mov    rcx,rax
    1efb:	mov    r14,rax
    1efe:	test   rax,rcx
    1f01:	jne    1f0f <botlish_fn_12+0x8f>
    1f07:	mov    rdi,r15
    1f0a:	jmp    2099 <botlish_fn_12+0x219>
    1f0f:	mov    rax,r14
    1f12:	mov    QWORD PTR [r13+0x0],rax
    1f16:	mov    rdx,QWORD PTR [rsp+0x10]
    1f1b:	mov    rsi,rax
    1f1e:	and    rsi,rdx
    1f21:	test   rsi,0x1
    1f28:	jne    1f4f <botlish_fn_12+0xcf>
    1f2e:	mov    rdx,QWORD PTR [rsp+0x10]
    1f33:	mov    rsi,r14
    1f36:	mov    rdi,r15
    1f39:	call   1f3e <botlish_fn_12+0xbe>
			1f3a: R_X86_64_PLT32	rt_value_eq-0x4
    1f3e:	test   rax,rax
    1f41:	jne    1f64 <botlish_fn_12+0xe4>
    1f47:	mov    rdi,r15
    1f4a:	jmp    2099 <botlish_fn_12+0x219>
    1f4f:	mov    eax,0x2
    1f54:	mov    rdx,QWORD PTR [rsp+0x10]
    1f59:	cmp    r14,rdx
    1f5c:	cmove  rax,QWORD PTR [rip+0x1f4]        # 2158 <botlish_fn_12+0x2d8>
    1f64:	cmp    rax,0x6
    1f68:	je     20f9 <botlish_fn_12+0x279>
    1f6e:	mov    rax,QWORD PTR [r12+0x20]
    1f73:	mov    rdx,QWORD PTR [rax+0x8]
    1f77:	mov    rax,r14
    1f7a:	and    rax,rdx
    1f7d:	test   rax,0x1
    1f83:	jne    1fa9 <botlish_fn_12+0x129>
    1f89:	mov    rsi,r14
    1f8c:	mov    rdi,r15
    1f8f:	call   1f94 <botlish_fn_12+0x114>
			1f90: R_X86_64_PLT32	rt_int_cmp-0x4
    1f94:	mov    ecx,0x2
    1f99:	test   rax,rax
    1f9c:	cmovge rcx,QWORD PTR [rip+0x1b4]        # 2158 <botlish_fn_12+0x2d8>
    1fa4:	jmp    1fb9 <botlish_fn_12+0x139>
    1fa9:	mov    ecx,0x2
    1fae:	cmp    r14,rdx
    1fb1:	cmovge rcx,QWORD PTR [rip+0x19f]        # 2158 <botlish_fn_12+0x2d8>
    1fb9:	cmp    rcx,0x6
    1fbd:	je     20ea <botlish_fn_12+0x26a>
    1fc3:	mov    rax,QWORD PTR [r12+0x20]
    1fc8:	mov    rsi,QWORD PTR [rax+0x10]
    1fcc:	mov    QWORD PTR [r13+0x8],rsi
    1fd0:	mov    rcx,rbx
    1fd3:	mov    rdx,r14
    1fd6:	mov    rdi,r15
    1fd9:	call   1fde <botlish_fn_12+0x15e>
			1fda: R_X86_64_PLT32	botlish_fn_5-0x4 ; char_at<generic>
    1fde:	test   rax,rax
    1fe1:	mov    rsi,rax
    1fe4:	jne    1ff2 <botlish_fn_12+0x172>
    1fea:	mov    rdi,r15
    1fed:	jmp    2099 <botlish_fn_12+0x219>
    1ff2:	mov    rdx,QWORD PTR [rsp]
    1ff6:	mov    rcx,QWORD PTR [rsp+0x8]
    1ffb:	mov    rdi,r15
    1ffe:	mov    rax,QWORD PTR [rdi+0x10]
    2002:	mov    r8,QWORD PTR [rax+0x60]
    2006:	call   200b <botlish_fn_12+0x18b>
			2007: R_X86_64_PLT32	rt_str_region_eq-0x4
    200b:	cmp    rax,0x6
    200f:	je     2021 <botlish_fn_12+0x1a1>
    2015:	mov    rax,0xffffffffffffffff
    201c:	jmp    20f1 <botlish_fn_12+0x271>
    2021:	mov    QWORD PTR [r13+0x8],0x3
    2029:	test   r14,0x1
    2030:	je     2057 <botlish_fn_12+0x1d7>
    2036:	mov    rdx,r14
    2039:	add    rdx,0x2
    203d:	mov    QWORD PTR [rsp+0x10],rdx
    2042:	seto   al
    2045:	test   al,al
    2047:	jne    2057 <botlish_fn_12+0x1d7>
    204d:	mov    rdx,QWORD PTR [rsp+0x10]
    2052:	jmp    206f <botlish_fn_12+0x1ef>
    2057:	mov    edx,0x3
    205c:	mov    rsi,r14
    205f:	mov    rdi,r15
    2062:	call   2067 <botlish_fn_12+0x1e7>
			2063: R_X86_64_PLT32	rt_int_add-0x4
    2067:	mov    rdx,rax
    206a:	mov    QWORD PTR [rsp+0x10],rax
    206f:	mov    QWORD PTR [r13+0x0],rdx
    2073:	mov    rax,QWORD PTR [r12+0x20]
    2078:	mov    rsi,QWORD PTR [rax+0x18]
    207c:	mov    QWORD PTR [r13+0x8],rsi
    2080:	mov    rdx,QWORD PTR [rsp+0x10]
    2085:	mov    rdi,r15
    2088:	call   208d <botlish_fn_12+0x20d>
			2089: R_X86_64_PLT32	botlish_fn_11-0x4 ; tld_ok<generic>
    208d:	test   rax,rax
    2090:	jne    20c4 <botlish_fn_12+0x244>
    2096:	mov    rdi,r15
    2099:	mov    rdi,r15
    209c:	mov    QWORD PTR [rdi],r13
    209f:	xor    rax,rax
    20a2:	mov    rbx,QWORD PTR [rsp+0x20]
    20a7:	mov    r12,QWORD PTR [rsp+0x28]
    20ac:	mov    r13,QWORD PTR [rsp+0x30]
    20b1:	mov    r14,QWORD PTR [rsp+0x38]
    20b6:	mov    r15,QWORD PTR [rsp+0x40]
    20bb:	add    rsp,0x50
    20bf:	mov    rsp,rbp
    20c2:	pop    rbp
    20c3:	ret
    20c4:	cmp    rax,0x6
    20c8:	je     20dc <botlish_fn_12+0x25c>
    20ce:	mov    rdx,QWORD PTR [rsp+0x10]
    20d3:	mov    QWORD PTR [r13+0x0],rdx
    20d7:	jmp    1edf <botlish_fn_12+0x5f>
    20dc:	mov    rax,QWORD PTR [r12+0x20]
    20e1:	mov    rax,QWORD PTR [rax+0x8]
    20e5:	jmp    20f1 <botlish_fn_12+0x271>
    20ea:	mov    rax,0xffffffffffffffff
    20f1:	mov    rdi,r15
    20f4:	jmp    2103 <botlish_fn_12+0x283>
    20f9:	mov    rax,0xffffffffffffffff
    2100:	mov    rdi,r15
    2103:	mov    rdi,r15
    2106:	mov    QWORD PTR [rdi],r13
    2109:	mov    rbx,QWORD PTR [rsp+0x20]
    210e:	mov    r12,QWORD PTR [rsp+0x28]
    2113:	mov    r13,QWORD PTR [rsp+0x30]
    2118:	mov    r14,QWORD PTR [rsp+0x38]
    211d:	mov    r15,QWORD PTR [rsp+0x40]
    2122:	add    rsp,0x50
    2126:	mov    rsp,rbp
    2129:	pop    rbp
    212a:	ret
    212b:	mov    r15,rdi
    212e:	call   2133 <botlish_fn_12+0x2b3>
			212f: R_X86_64_PLT32	rt_stack_overflow-0x4
    2133:	xor    rax,rax
    2136:	mov    rbx,QWORD PTR [rsp+0x20]
    213b:	mov    r12,QWORD PTR [rsp+0x28]
    2140:	mov    r13,QWORD PTR [rsp+0x30]
    2145:	mov    r14,QWORD PTR [rsp+0x38]
    214a:	mov    r15,QWORD PTR [rsp+0x40]
    214f:	add    rsp,0x50
    2153:	mov    rsp,rbp
    2156:	pop    rbp
    2157:	ret
    2158:	(bad)
    2159:	add    BYTE PTR [rax],al
    215b:	add    BYTE PTR [rax],al
    215d:	add    BYTE PTR [rax],al
	...

0000000000002160 <botlish_entry_12: domain_loop<generic>>:
    2160:	push   rbp
    2161:	mov    rbp,rsp
    2164:	mov    rdx,QWORD PTR [rdx]
    2167:	call   216c <botlish_entry_12+0xc>
			2168: R_X86_64_PLT32	botlish_fn_12-0x4 ; domain_loop<generic>
    216c:	mov    rsp,rbp
    216f:	pop    rbp
    2170:	ret
    2171:	add    BYTE PTR [rax],al
    2173:	add    BYTE PTR [rax],al
    2175:	add    BYTE PTR [rax],al
	...

0000000000002178 <botlish_fn_13: <str>>:
    2178:	push   rbp
    2179:	mov    rbp,rsp
    217c:	sub    rsp,0xc0
    2183:	mov    QWORD PTR [rsp+0x90],rbx
    218b:	mov    QWORD PTR [rsp+0x98],r12
    2193:	mov    QWORD PTR [rsp+0xa0],r13
    219b:	mov    QWORD PTR [rsp+0xa8],r14
    21a3:	mov    QWORD PTR [rsp+0xb0],r15
    21ab:	mov    r12,QWORD PTR [rdi]
    21ae:	mov    rax,QWORD PTR [rdi+0x8]
    21b2:	lea    rcx,[r12+0x28]
    21b7:	cmp    rcx,rax
    21ba:	ja     25d8 <botlish_fn_13+0x460>
    21c0:	lea    rax,[r12+0x28]
    21c5:	mov    QWORD PTR [rdi],rax
    21c8:	mov    QWORD PTR [rsp+0x78],rdi
    21cd:	mov    QWORD PTR [r12],0x0
    21d5:	mov    QWORD PTR [r12+0x8],0x0
    21de:	mov    QWORD PTR [r12+0x10],0x0
    21e7:	mov    QWORD PTR [r12+0x18],0x0
    21f0:	mov    QWORD PTR [r12+0x20],0x0
    21f9:	mov    QWORD PTR [r12],rsi
    21fd:	mov    r13,rsi
    2200:	mov    rsi,r13
    2203:	mov    rdi,QWORD PTR [rsp+0x78]
    2208:	call   220d <botlish_fn_13+0x95>
			2209: R_X86_64_PLT32	rt_str_len-0x4
    220d:	mov    rbx,rax
    2210:	mov    QWORD PTR [r12+0x8],rbx
    2215:	lea    r8,[rsp]
    2219:	mov    QWORD PTR [rsp],r13
    221d:	mov    esi,0xf
    2222:	mov    rdx,QWORD PTR [rip+0x0]        # 2229 <botlish_fn_13+0xb1>
			2225: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; char_at<generic>
    2229:	mov    r13d,0x1
    222f:	mov    rcx,r13
    2232:	mov    rdi,QWORD PTR [rsp+0x78]
    2237:	call   223c <botlish_fn_13+0xc4>
			2238: R_X86_64_PLT32	rt_closure_new-0x4
    223c:	mov    r14,rax
    223f:	mov    QWORD PTR [r12],rax
    2243:	lea    r8,[rsp+0x8]
    2248:	mov    QWORD PTR [rsp+0x8],rbx
    224d:	mov    QWORD PTR [rsp+0x10],rax
    2252:	mov    esi,0x13
    2257:	mov    rdx,QWORD PTR [rip+0x0]        # 225e <botlish_fn_13+0xe6>
			225a: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; scan_local<generic>
    225e:	mov    r15d,0x2
    2264:	mov    rcx,r15
    2267:	mov    rdi,QWORD PTR [rsp+0x78]
    226c:	call   2271 <botlish_fn_13+0xf9>
			226d: R_X86_64_PLT32	rt_closure_new-0x4
    2271:	mov    rsi,rax
    2274:	mov    QWORD PTR [rsp+0x88],rax
    227c:	mov    QWORD PTR [r12+0x10],rsi
    2281:	lea    r8,[rsp+0x18]
    2286:	mov    QWORD PTR [rsp+0x18],rbx
    228b:	mov    rax,r14
    228e:	mov    QWORD PTR [rsp+0x20],rax
    2293:	mov    esi,0x14
    2298:	mov    rdx,QWORD PTR [rip+0x0]        # 229f <botlish_fn_13+0x127>
			229b: R_X86_64_GOTPCREL	botlish_entry_20-0x4 ; scan_label<generic>
    229f:	mov    rcx,r15
    22a2:	mov    rdi,QWORD PTR [rsp+0x78]
    22a7:	call   22ac <botlish_fn_13+0x134>
			22a8: R_X86_64_PLT32	rt_closure_new-0x4
    22ac:	mov    QWORD PTR [r12+0x18],rax
    22b1:	mov    QWORD PTR [rsp+0x80],rax
    22b9:	lea    r8,[rsp+0x28]
    22be:	mov    QWORD PTR [rsp+0x28],rbx
    22c3:	mov    QWORD PTR [rsp+0x30],r14
    22c8:	mov    esi,0x15
    22cd:	mov    rdx,QWORD PTR [rip+0x0]        # 22d4 <botlish_fn_13+0x15c>
			22d0: R_X86_64_GOTPCREL	botlish_entry_21-0x4 ; scan_alpha<generic>
    22d4:	mov    rcx,r15
    22d7:	mov    rdi,QWORD PTR [rsp+0x78]
    22dc:	call   22e1 <botlish_fn_13+0x169>
			22dd: R_X86_64_PLT32	rt_closure_new-0x4
    22e1:	mov    QWORD PTR [r12+0x20],rax
    22e6:	lea    r8,[rsp+0x38]
    22eb:	mov    QWORD PTR [rsp+0x38],rax
    22f0:	mov    QWORD PTR [rsp+0x40],rbx
    22f5:	mov    esi,0x16
    22fa:	mov    rdx,QWORD PTR [rip+0x0]        # 2301 <botlish_fn_13+0x189>
			22fd: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; tld_ok<generic>
    2301:	mov    rcx,r15
    2304:	mov    rdi,QWORD PTR [rsp+0x78]
    2309:	call   230e <botlish_fn_13+0x196>
			230a: R_X86_64_PLT32	rt_closure_new-0x4
    230e:	mov    QWORD PTR [r12+0x20],rax
    2313:	lea    r8,[rsp+0x48]
    2318:	mov    rcx,QWORD PTR [rsp+0x80]
    2320:	mov    QWORD PTR [rsp+0x48],rcx
    2325:	mov    QWORD PTR [rsp+0x50],rbx
    232a:	mov    QWORD PTR [rsp+0x58],r14
    232f:	mov    QWORD PTR [rsp+0x60],rax
    2334:	mov    esi,0x17
    2339:	mov    rdx,QWORD PTR [rip+0x0]        # 2340 <botlish_fn_13+0x1c8>
			233c: R_X86_64_GOTPCREL	botlish_entry_23-0x4 ; domain_loop<generic>
    2340:	mov    ecx,0x4
    2345:	mov    rdi,QWORD PTR [rsp+0x78]
    234a:	call   234f <botlish_fn_13+0x1d7>
			234b: R_X86_64_PLT32	rt_closure_new-0x4
    234f:	mov    QWORD PTR [r12+0x18],rax
    2354:	mov    r15,rax
    2357:	mov    QWORD PTR [r12+0x20],0x1
    2360:	mov    rdx,r13
    2363:	mov    rsi,QWORD PTR [rsp+0x88]
    236b:	mov    rdi,QWORD PTR [rsp+0x78]
    2370:	call   2375 <botlish_fn_13+0x1fd>
			2371: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_local<generic>
    2375:	mov    rcx,rax
    2378:	mov    r13,rax
    237b:	test   rax,rcx
    237e:	jne    238e <botlish_fn_13+0x216>
    2384:	mov    rdi,QWORD PTR [rsp+0x78]
    2389:	jmp    24ee <botlish_fn_13+0x376>
    238e:	mov    rax,r13
    2391:	mov    QWORD PTR [r12+0x10],rax
    2396:	test   rax,0x1
    239c:	jne    23c9 <botlish_fn_13+0x251>
    23a2:	mov    edx,0x1
    23a7:	mov    rsi,r13
    23aa:	mov    rdi,QWORD PTR [rsp+0x78]
    23af:	call   23b4 <botlish_fn_13+0x23c>
			23b0: R_X86_64_PLT32	rt_int_cmp-0x4
    23b4:	mov    ecx,0x2
    23b9:	test   rax,rax
    23bc:	cmove  rcx,QWORD PTR [rip+0x25c]        # 2620 <botlish_fn_13+0x4a8>
    23c4:	jmp    23da <botlish_fn_13+0x262>
    23c9:	mov    ecx,0x2
    23ce:	cmp    r13,0x1
    23d2:	cmove  rcx,QWORD PTR [rip+0x246]        # 2620 <botlish_fn_13+0x4a8>
    23da:	cmp    rcx,0x6
    23de:	je     2592 <botlish_fn_13+0x41a>
    23e4:	mov    rax,r13
    23e7:	and    rax,rbx
    23ea:	test   rax,0x1
    23f0:	jne    241b <botlish_fn_13+0x2a3>
    23f6:	mov    rdx,rbx
    23f9:	mov    rsi,r13
    23fc:	mov    rdi,QWORD PTR [rsp+0x78]
    2401:	call   2406 <botlish_fn_13+0x28e>
			2402: R_X86_64_PLT32	rt_int_cmp-0x4
    2406:	mov    ecx,0x2
    240b:	test   rax,rax
    240e:	cmovge rcx,QWORD PTR [rip+0x20a]        # 2620 <botlish_fn_13+0x4a8>
    2416:	jmp    242b <botlish_fn_13+0x2b3>
    241b:	mov    ecx,0x2
    2420:	cmp    r13,rbx
    2423:	cmovge rcx,QWORD PTR [rip+0x1f5]        # 2620 <botlish_fn_13+0x4a8>
    242b:	cmp    rcx,0x6
    242f:	je     2583 <botlish_fn_13+0x40b>
    2435:	lea    rcx,[rsp+0x68]
    243a:	mov    rsi,r14
    243d:	mov    rdx,r13
    2440:	mov    rdi,QWORD PTR [rsp+0x78]
    2445:	call   244a <botlish_fn_13+0x2d2>
			2446: R_X86_64_PLT32	botlish_fn_16-0x4 ; char_at<generic>
    244a:	test   rax,rax
    244d:	mov    rsi,rax
    2450:	jne    2460 <botlish_fn_13+0x2e8>
    2456:	mov    rdi,QWORD PTR [rsp+0x78]
    245b:	jmp    24ee <botlish_fn_13+0x376>
    2460:	mov    rdx,QWORD PTR [rsp+0x68]
    2465:	mov    rcx,QWORD PTR [rsp+0x70]
    246a:	mov    rdi,QWORD PTR [rsp+0x78]
    246f:	mov    r8,QWORD PTR [rdi+0x10]
    2473:	mov    r8,QWORD PTR [r8+0x40]
    2477:	call   247c <botlish_fn_13+0x304>
			2478: R_X86_64_PLT32	rt_str_region_eq-0x4
    247c:	cmp    rax,0x6
    2480:	je     2493 <botlish_fn_13+0x31b>
    2486:	mov    ecx,0x2
    248b:	mov    rax,rcx
    248e:	jmp    2588 <botlish_fn_13+0x410>
    2493:	mov    QWORD PTR [r12],0x3
    249b:	test   r13,0x1
    24a2:	je     24ba <botlish_fn_13+0x342>
    24a8:	mov    rdx,r13
    24ab:	add    rdx,0x2
    24af:	seto   al
    24b2:	test   al,al
    24b4:	je     24cf <botlish_fn_13+0x357>
    24ba:	mov    edx,0x3
    24bf:	mov    rsi,r13
    24c2:	mov    rdi,QWORD PTR [rsp+0x78]
    24c7:	call   24cc <botlish_fn_13+0x354>
			24c8: R_X86_64_PLT32	rt_int_add-0x4
    24cc:	mov    rdx,rax
    24cf:	mov    QWORD PTR [r12],rdx
    24d3:	mov    rsi,r15
    24d6:	mov    rdi,QWORD PTR [rsp+0x78]
    24db:	call   24e0 <botlish_fn_13+0x368>
			24dc: R_X86_64_PLT32	botlish_fn_23-0x4 ; domain_loop<generic>
    24e0:	test   rax,rax
    24e3:	jne    252d <botlish_fn_13+0x3b5>
    24e9:	mov    rdi,QWORD PTR [rsp+0x78]
    24ee:	mov    rdi,QWORD PTR [rsp+0x78]
    24f3:	mov    QWORD PTR [rdi],r12
    24f6:	xor    rax,rax
    24f9:	mov    rbx,QWORD PTR [rsp+0x90]
    2501:	mov    r12,QWORD PTR [rsp+0x98]
    2509:	mov    r13,QWORD PTR [rsp+0xa0]
    2511:	mov    r14,QWORD PTR [rsp+0xa8]
    2519:	mov    r15,QWORD PTR [rsp+0xb0]
    2521:	add    rsp,0xc0
    2528:	mov    rsp,rbp
    252b:	pop    rbp
    252c:	ret
    252d:	mov    rcx,rax
    2530:	and    rcx,rbx
    2533:	mov    rsi,rax
    2536:	mov    rax,rbx
    2539:	test   rcx,0x1
    2540:	jne    256b <botlish_fn_13+0x3f3>
    2546:	mov    rdx,rax
    2549:	mov    rdi,QWORD PTR [rsp+0x78]
    254e:	call   2553 <botlish_fn_13+0x3db>
			254f: R_X86_64_PLT32	rt_int_cmp-0x4
    2553:	mov    ecx,0x2
    2558:	test   rax,rax
    255b:	mov    rax,rcx
    255e:	cmove  rax,QWORD PTR [rip+0xba]        # 2620 <botlish_fn_13+0x4a8>
    2566:	jmp    2588 <botlish_fn_13+0x410>
    256b:	mov    rdx,rax
    256e:	mov    eax,0x2
    2573:	cmp    rsi,rdx
    2576:	cmove  rax,QWORD PTR [rip+0xa2]        # 2620 <botlish_fn_13+0x4a8>
    257e:	jmp    2588 <botlish_fn_13+0x410>
    2583:	mov    eax,0x2
    2588:	mov    rdi,QWORD PTR [rsp+0x78]
    258d:	jmp    259c <botlish_fn_13+0x424>
    2592:	mov    eax,0x2
    2597:	mov    rdi,QWORD PTR [rsp+0x78]
    259c:	mov    rdi,QWORD PTR [rsp+0x78]
    25a1:	mov    QWORD PTR [rdi],r12
    25a4:	mov    rbx,QWORD PTR [rsp+0x90]
    25ac:	mov    r12,QWORD PTR [rsp+0x98]
    25b4:	mov    r13,QWORD PTR [rsp+0xa0]
    25bc:	mov    r14,QWORD PTR [rsp+0xa8]
    25c4:	mov    r15,QWORD PTR [rsp+0xb0]
    25cc:	add    rsp,0xc0
    25d3:	mov    rsp,rbp
    25d6:	pop    rbp
    25d7:	ret
    25d8:	mov    QWORD PTR [rsp+0x78],rdi
    25dd:	call   25e2 <botlish_fn_13+0x46a>
			25de: R_X86_64_PLT32	rt_stack_overflow-0x4
    25e2:	xor    rax,rax
    25e5:	mov    rbx,QWORD PTR [rsp+0x90]
    25ed:	mov    r12,QWORD PTR [rsp+0x98]
    25f5:	mov    r13,QWORD PTR [rsp+0xa0]
    25fd:	mov    r14,QWORD PTR [rsp+0xa8]
    2605:	mov    r15,QWORD PTR [rsp+0xb0]
    260d:	add    rsp,0xc0
    2614:	mov    rsp,rbp
    2617:	pop    rbp
    2618:	ret
    2619:	add    BYTE PTR [rax],al
    261b:	add    BYTE PTR [rax],al
    261d:	add    BYTE PTR [rax],al
    261f:	add    BYTE PTR [rsi],al
    2621:	add    BYTE PTR [rax],al
    2623:	add    BYTE PTR [rax],al
    2625:	add    BYTE PTR [rax],al
	...

0000000000002628 <botlish_entry_13: <str>>:
    2628:	push   rbp
    2629:	mov    rbp,rsp
    262c:	mov    rsi,QWORD PTR [rdx]
    262f:	call   2634 <botlish_entry_13+0xc>
			2630: R_X86_64_PLT32	botlish_fn_13-0x4 ; <str>
    2634:	mov    rsp,rbp
    2637:	pop    rbp
    2638:	ret
    2639:	add    BYTE PTR [rax],al
    263b:	add    BYTE PTR [rax],al
    263d:	add    BYTE PTR [rax],al
	...

0000000000002640 <botlish_fn_14: <generic>>:
    2640:	push   rbp
    2641:	mov    rbp,rsp
    2644:	sub    rsp,0xc0
    264b:	mov    QWORD PTR [rsp+0x90],rbx
    2653:	mov    QWORD PTR [rsp+0x98],r12
    265b:	mov    QWORD PTR [rsp+0xa0],r13
    2663:	mov    QWORD PTR [rsp+0xa8],r14
    266b:	mov    QWORD PTR [rsp+0xb0],r15
    2673:	mov    r12,QWORD PTR [rdi]
    2676:	mov    rax,QWORD PTR [rdi+0x8]
    267a:	lea    rcx,[r12+0x28]
    267f:	cmp    rcx,rax
    2682:	ja     2adc <botlish_fn_14+0x49c>
    2688:	lea    rax,[r12+0x28]
    268d:	mov    QWORD PTR [rdi],rax
    2690:	mov    QWORD PTR [r12],0x0
    2698:	mov    QWORD PTR [r12+0x8],0x0
    26a1:	mov    QWORD PTR [r12+0x10],0x0
    26aa:	mov    QWORD PTR [r12+0x18],0x0
    26b3:	mov    QWORD PTR [r12+0x20],0x0
    26bc:	mov    QWORD PTR [r12],rsi
    26c0:	xor    eax,eax
    26c2:	test   rsi,0x7
    26c9:	jne    26d8 <botlish_fn_14+0x98>
    26cf:	movzx  rax,BYTE PTR [rsi]
    26d3:	cmp    al,0x2
    26d5:	sete   al
    26d8:	test   al,al
    26da:	jne    2701 <botlish_fn_14+0xc1>
    26e0:	mov    rax,QWORD PTR [rdi+0x10]
    26e4:	mov    QWORD PTR [rsp+0x78],rdi
    26e9:	mov    rcx,QWORD PTR [rax+0x48]
    26ed:	mov    edx,0x1
    26f2:	call   26f7 <botlish_fn_14+0xb7>
			26f3: R_X86_64_PLT32	rt_type_error-0x4
    26f7:	mov    rdi,QWORD PTR [rsp+0x78]
    26fc:	jmp    29f2 <botlish_fn_14+0x3b2>
    2701:	mov    r13,rsi
    2704:	mov    QWORD PTR [rsp+0x78],rdi
    2709:	call   270e <botlish_fn_14+0xce>
			270a: R_X86_64_PLT32	rt_str_len-0x4
    270e:	mov    rbx,rax
    2711:	mov    QWORD PTR [r12+0x8],rbx
    2716:	lea    r8,[rsp]
    271a:	mov    QWORD PTR [rsp],r13
    271e:	mov    esi,0xf
    2723:	mov    rdx,QWORD PTR [rip+0x0]        # 272a <botlish_fn_14+0xea>
			2726: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; char_at<generic>
    272a:	mov    r13d,0x1
    2730:	mov    rcx,r13
    2733:	mov    rdi,QWORD PTR [rsp+0x78]
    2738:	call   273d <botlish_fn_14+0xfd>
			2739: R_X86_64_PLT32	rt_closure_new-0x4
    273d:	mov    r15,rax
    2740:	mov    QWORD PTR [rsp+0x88],r13
    2748:	mov    QWORD PTR [r12],rax
    274c:	lea    r8,[rsp+0x8]
    2751:	mov    QWORD PTR [rsp+0x8],rbx
    2756:	mov    QWORD PTR [rsp+0x10],rax
    275b:	mov    esi,0x13
    2760:	mov    rdx,QWORD PTR [rip+0x0]        # 2767 <botlish_fn_14+0x127>
			2763: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; scan_local<generic>
    2767:	mov    r14d,0x2
    276d:	mov    rcx,r14
    2770:	mov    rdi,QWORD PTR [rsp+0x78]
    2775:	call   277a <botlish_fn_14+0x13a>
			2776: R_X86_64_PLT32	rt_closure_new-0x4
    277a:	mov    r13,rax
    277d:	mov    QWORD PTR [r12+0x10],r13
    2782:	lea    r8,[rsp+0x18]
    2787:	mov    QWORD PTR [rsp+0x18],rbx
    278c:	mov    rax,r15
    278f:	mov    QWORD PTR [rsp+0x20],rax
    2794:	mov    esi,0x14
    2799:	mov    rdx,QWORD PTR [rip+0x0]        # 27a0 <botlish_fn_14+0x160>
			279c: R_X86_64_GOTPCREL	botlish_entry_20-0x4 ; scan_label<generic>
    27a0:	mov    rcx,r14
    27a3:	mov    rdi,QWORD PTR [rsp+0x78]
    27a8:	call   27ad <botlish_fn_14+0x16d>
			27a9: R_X86_64_PLT32	rt_closure_new-0x4
    27ad:	mov    QWORD PTR [r12+0x18],rax
    27b2:	mov    QWORD PTR [rsp+0x80],rax
    27ba:	lea    r8,[rsp+0x28]
    27bf:	mov    QWORD PTR [rsp+0x28],rbx
    27c4:	mov    QWORD PTR [rsp+0x30],r15
    27c9:	mov    esi,0x15
    27ce:	mov    rdx,QWORD PTR [rip+0x0]        # 27d5 <botlish_fn_14+0x195>
			27d1: R_X86_64_GOTPCREL	botlish_entry_21-0x4 ; scan_alpha<generic>
    27d5:	mov    rcx,r14
    27d8:	mov    rdi,QWORD PTR [rsp+0x78]
    27dd:	call   27e2 <botlish_fn_14+0x1a2>
			27de: R_X86_64_PLT32	rt_closure_new-0x4
    27e2:	mov    QWORD PTR [r12+0x20],rax
    27e7:	lea    r8,[rsp+0x38]
    27ec:	mov    QWORD PTR [rsp+0x38],rax
    27f1:	mov    QWORD PTR [rsp+0x40],rbx
    27f6:	mov    esi,0x16
    27fb:	mov    rdx,QWORD PTR [rip+0x0]        # 2802 <botlish_fn_14+0x1c2>
			27fe: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; tld_ok<generic>
    2802:	mov    rcx,r14
    2805:	mov    rdi,QWORD PTR [rsp+0x78]
    280a:	call   280f <botlish_fn_14+0x1cf>
			280b: R_X86_64_PLT32	rt_closure_new-0x4
    280f:	mov    QWORD PTR [r12+0x20],rax
    2814:	lea    r8,[rsp+0x48]
    2819:	mov    rcx,QWORD PTR [rsp+0x80]
    2821:	mov    QWORD PTR [rsp+0x48],rcx
    2826:	mov    QWORD PTR [rsp+0x50],rbx
    282b:	mov    QWORD PTR [rsp+0x58],r15
    2830:	mov    QWORD PTR [rsp+0x60],rax
    2835:	mov    esi,0x17
    283a:	mov    rdx,QWORD PTR [rip+0x0]        # 2841 <botlish_fn_14+0x201>
			283d: R_X86_64_GOTPCREL	botlish_entry_23-0x4 ; domain_loop<generic>
    2841:	mov    ecx,0x4
    2846:	mov    rdi,QWORD PTR [rsp+0x78]
    284b:	call   2850 <botlish_fn_14+0x210>
			284c: R_X86_64_PLT32	rt_closure_new-0x4
    2850:	mov    QWORD PTR [r12+0x18],rax
    2855:	mov    r14,rax
    2858:	mov    QWORD PTR [r12+0x20],0x1
    2861:	mov    rsi,r13
    2864:	mov    rdx,QWORD PTR [rsp+0x88]
    286c:	mov    rdi,QWORD PTR [rsp+0x78]
    2871:	call   2876 <botlish_fn_14+0x236>
			2872: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_local<generic>
    2876:	mov    rcx,rax
    2879:	mov    r13,rax
    287c:	test   rax,rcx
    287f:	jne    288f <botlish_fn_14+0x24f>
    2885:	mov    rdi,QWORD PTR [rsp+0x78]
    288a:	jmp    29f2 <botlish_fn_14+0x3b2>
    288f:	mov    rax,r13
    2892:	mov    QWORD PTR [r12+0x10],rax
    2897:	test   rax,0x1
    289d:	jne    28cd <botlish_fn_14+0x28d>
    28a3:	mov    rdx,QWORD PTR [rsp+0x88]
    28ab:	mov    rsi,r13
    28ae:	mov    rdi,QWORD PTR [rsp+0x78]
    28b3:	call   28b8 <botlish_fn_14+0x278>
			28b4: R_X86_64_PLT32	rt_int_cmp-0x4
    28b8:	mov    ecx,0x2
    28bd:	test   rax,rax
    28c0:	cmove  rcx,QWORD PTR [rip+0x258]        # 2b20 <botlish_fn_14+0x4e0>
    28c8:	jmp    28de <botlish_fn_14+0x29e>
    28cd:	mov    ecx,0x2
    28d2:	cmp    r13,0x1
    28d6:	cmove  rcx,QWORD PTR [rip+0x242]        # 2b20 <botlish_fn_14+0x4e0>
    28de:	cmp    rcx,0x6
    28e2:	je     2a96 <botlish_fn_14+0x456>
    28e8:	mov    rax,r13
    28eb:	and    rax,rbx
    28ee:	test   rax,0x1
    28f4:	jne    291f <botlish_fn_14+0x2df>
    28fa:	mov    rdx,rbx
    28fd:	mov    rsi,r13
    2900:	mov    rdi,QWORD PTR [rsp+0x78]
    2905:	call   290a <botlish_fn_14+0x2ca>
			2906: R_X86_64_PLT32	rt_int_cmp-0x4
    290a:	mov    ecx,0x2
    290f:	test   rax,rax
    2912:	cmovge rcx,QWORD PTR [rip+0x206]        # 2b20 <botlish_fn_14+0x4e0>
    291a:	jmp    292f <botlish_fn_14+0x2ef>
    291f:	mov    ecx,0x2
    2924:	cmp    r13,rbx
    2927:	cmovge rcx,QWORD PTR [rip+0x1f1]        # 2b20 <botlish_fn_14+0x4e0>
    292f:	cmp    rcx,0x6
    2933:	je     2a87 <botlish_fn_14+0x447>
    2939:	lea    rcx,[rsp+0x68]
    293e:	mov    rsi,r15
    2941:	mov    rdx,r13
    2944:	mov    rdi,QWORD PTR [rsp+0x78]
    2949:	call   294e <botlish_fn_14+0x30e>
			294a: R_X86_64_PLT32	botlish_fn_16-0x4 ; char_at<generic>
    294e:	test   rax,rax
    2951:	mov    rsi,rax
    2954:	jne    2964 <botlish_fn_14+0x324>
    295a:	mov    rdi,QWORD PTR [rsp+0x78]
    295f:	jmp    29f2 <botlish_fn_14+0x3b2>
    2964:	mov    rdx,QWORD PTR [rsp+0x68]
    2969:	mov    rcx,QWORD PTR [rsp+0x70]
    296e:	mov    rdi,QWORD PTR [rsp+0x78]
    2973:	mov    rax,QWORD PTR [rdi+0x10]
    2977:	mov    r8,QWORD PTR [rax+0x40]
    297b:	call   2980 <botlish_fn_14+0x340>
			297c: R_X86_64_PLT32	rt_str_region_eq-0x4
    2980:	cmp    rax,0x6
    2984:	je     2997 <botlish_fn_14+0x357>
    298a:	mov    edi,0x2
    298f:	mov    rax,rdi
    2992:	jmp    2a8c <botlish_fn_14+0x44c>
    2997:	mov    QWORD PTR [r12],0x3
    299f:	test   r13,0x1
    29a6:	je     29be <botlish_fn_14+0x37e>
    29ac:	mov    rdx,r13
    29af:	add    rdx,0x2
    29b3:	seto   al
    29b6:	test   al,al
    29b8:	je     29d3 <botlish_fn_14+0x393>
    29be:	mov    edx,0x3
    29c3:	mov    rsi,r13
    29c6:	mov    rdi,QWORD PTR [rsp+0x78]
    29cb:	call   29d0 <botlish_fn_14+0x390>
			29cc: R_X86_64_PLT32	rt_int_add-0x4
    29d0:	mov    rdx,rax
    29d3:	mov    QWORD PTR [r12],rdx
    29d7:	mov    rsi,r14
    29da:	mov    rdi,QWORD PTR [rsp+0x78]
    29df:	call   29e4 <botlish_fn_14+0x3a4>
			29e0: R_X86_64_PLT32	botlish_fn_23-0x4 ; domain_loop<generic>
    29e4:	test   rax,rax
    29e7:	jne    2a31 <botlish_fn_14+0x3f1>
    29ed:	mov    rdi,QWORD PTR [rsp+0x78]
    29f2:	mov    rdi,QWORD PTR [rsp+0x78]
    29f7:	mov    QWORD PTR [rdi],r12
    29fa:	xor    rax,rax
    29fd:	mov    rbx,QWORD PTR [rsp+0x90]
    2a05:	mov    r12,QWORD PTR [rsp+0x98]
    2a0d:	mov    r13,QWORD PTR [rsp+0xa0]
    2a15:	mov    r14,QWORD PTR [rsp+0xa8]
    2a1d:	mov    r15,QWORD PTR [rsp+0xb0]
    2a25:	add    rsp,0xc0
    2a2c:	mov    rsp,rbp
    2a2f:	pop    rbp
    2a30:	ret
    2a31:	mov    rcx,rax
    2a34:	and    rcx,rbx
    2a37:	mov    rsi,rax
    2a3a:	mov    rax,rbx
    2a3d:	test   rcx,0x1
    2a44:	jne    2a6f <botlish_fn_14+0x42f>
    2a4a:	mov    rdx,rax
    2a4d:	mov    rdi,QWORD PTR [rsp+0x78]
    2a52:	call   2a57 <botlish_fn_14+0x417>
			2a53: R_X86_64_PLT32	rt_int_cmp-0x4
    2a57:	mov    edi,0x2
    2a5c:	test   rax,rax
    2a5f:	mov    rax,rdi
    2a62:	cmove  rax,QWORD PTR [rip+0xb6]        # 2b20 <botlish_fn_14+0x4e0>
    2a6a:	jmp    2a8c <botlish_fn_14+0x44c>
    2a6f:	mov    rdx,rax
    2a72:	mov    eax,0x2
    2a77:	cmp    rsi,rdx
    2a7a:	cmove  rax,QWORD PTR [rip+0x9e]        # 2b20 <botlish_fn_14+0x4e0>
    2a82:	jmp    2a8c <botlish_fn_14+0x44c>
    2a87:	mov    eax,0x2
    2a8c:	mov    rdi,QWORD PTR [rsp+0x78]
    2a91:	jmp    2aa0 <botlish_fn_14+0x460>
    2a96:	mov    eax,0x2
    2a9b:	mov    rdi,QWORD PTR [rsp+0x78]
    2aa0:	mov    rdi,QWORD PTR [rsp+0x78]
    2aa5:	mov    QWORD PTR [rdi],r12
    2aa8:	mov    rbx,QWORD PTR [rsp+0x90]
    2ab0:	mov    r12,QWORD PTR [rsp+0x98]
    2ab8:	mov    r13,QWORD PTR [rsp+0xa0]
    2ac0:	mov    r14,QWORD PTR [rsp+0xa8]
    2ac8:	mov    r15,QWORD PTR [rsp+0xb0]
    2ad0:	add    rsp,0xc0
    2ad7:	mov    rsp,rbp
    2ada:	pop    rbp
    2adb:	ret
    2adc:	mov    QWORD PTR [rsp+0x78],rdi
    2ae1:	call   2ae6 <botlish_fn_14+0x4a6>
			2ae2: R_X86_64_PLT32	rt_stack_overflow-0x4
    2ae6:	xor    rax,rax
    2ae9:	mov    rbx,QWORD PTR [rsp+0x90]
    2af1:	mov    r12,QWORD PTR [rsp+0x98]
    2af9:	mov    r13,QWORD PTR [rsp+0xa0]
    2b01:	mov    r14,QWORD PTR [rsp+0xa8]
    2b09:	mov    r15,QWORD PTR [rsp+0xb0]
    2b11:	add    rsp,0xc0
    2b18:	mov    rsp,rbp
    2b1b:	pop    rbp
    2b1c:	ret
    2b1d:	add    BYTE PTR [rax],al
    2b1f:	add    BYTE PTR [rsi],al
    2b21:	add    BYTE PTR [rax],al
    2b23:	add    BYTE PTR [rax],al
    2b25:	add    BYTE PTR [rax],al
	...

0000000000002b28 <botlish_entry_14: <generic>>:
    2b28:	push   rbp
    2b29:	mov    rbp,rsp
    2b2c:	mov    rsi,QWORD PTR [rdx]
    2b2f:	call   2b34 <botlish_entry_14+0xc>
			2b30: R_X86_64_PLT32	botlish_fn_14-0x4 ; <generic>
    2b34:	mov    rsp,rbp
    2b37:	pop    rbp
    2b38:	ret

0000000000002b39 <botlish_fn_15: char_at<generic>>:
    2b39:	push   rbp
    2b3a:	mov    rbp,rsp
    2b3d:	sub    rsp,0x20
    2b41:	mov    QWORD PTR [rsp],rbx
    2b45:	mov    QWORD PTR [rsp+0x8],r12
    2b4a:	mov    QWORD PTR [rsp+0x10],r13
    2b4f:	mov    QWORD PTR [rsp+0x18],r14
    2b54:	mov    rbx,QWORD PTR [rdi]
    2b57:	mov    rax,QWORD PTR [rdi+0x8]
    2b5b:	lea    rcx,[rbx+0x18]
    2b5f:	cmp    rcx,rax
    2b62:	ja     2cfd <botlish_fn_15+0x1c4>
    2b68:	lea    rax,[rbx+0x18]
    2b6c:	mov    QWORD PTR [rdi],rax
    2b6f:	mov    QWORD PTR [rbx],0x0
    2b76:	mov    QWORD PTR [rbx+0x8],0x0
    2b7e:	mov    QWORD PTR [rbx+0x10],0x0
    2b86:	mov    QWORD PTR [rbx],rdx
    2b89:	mov    rax,QWORD PTR [rsi+0x20]
    2b8d:	mov    rsi,QWORD PTR [rax]
    2b90:	mov    QWORD PTR [rbx+0x8],rsi
    2b94:	mov    r14,rsi
    2b97:	mov    QWORD PTR [rbx+0x10],0x3
    2b9f:	mov    ecx,0x1
    2ba4:	test   rdx,0x1
    2bab:	je     2bb9 <botlish_fn_15+0x80>
    2bb1:	mov    r13,rdx
    2bb4:	jmp    2bdc <botlish_fn_15+0xa3>
    2bb9:	xor    ecx,ecx
    2bbb:	test   rdx,0x7
    2bc2:	je     2bd0 <botlish_fn_15+0x97>
    2bc8:	mov    r13,rdx
    2bcb:	jmp    2bdc <botlish_fn_15+0xa3>
    2bd0:	movzx  rax,BYTE PTR [rdx]
    2bd4:	mov    r13,rdx
    2bd7:	cmp    al,0x1
    2bd9:	sete   cl
    2bdc:	test   cl,cl
    2bde:	jne    2c02 <botlish_fn_15+0xc9>
    2be4:	mov    rax,QWORD PTR [rdi+0x10]
    2be8:	mov    r12,rdi
    2beb:	mov    rcx,QWORD PTR [rax+0x50]
    2bef:	xor    rdx,rdx
    2bf2:	mov    rsi,r13
    2bf5:	call   2bfa <botlish_fn_15+0xc1>
			2bf6: R_X86_64_PLT32	rt_type_error-0x4
    2bfa:	mov    rdi,r12
    2bfd:	jmp    2cb6 <botlish_fn_15+0x17d>
    2c02:	mov    rsi,r13
    2c05:	mov    r12,rdi
    2c08:	test   rsi,0x1
    2c0f:	je     2c2c <botlish_fn_15+0xf3>
    2c15:	mov    rsi,r13
    2c18:	mov    rcx,rsi
    2c1b:	add    rcx,0x2
    2c1f:	seto   sil
    2c23:	test   sil,sil
    2c26:	je     2c3f <botlish_fn_15+0x106>
    2c2c:	mov    edx,0x3
    2c31:	mov    rsi,r13
    2c34:	mov    rdi,r12
    2c37:	call   2c3c <botlish_fn_15+0x103>
			2c38: R_X86_64_PLT32	rt_int_add-0x4
    2c3c:	mov    rcx,rax
    2c3f:	mov    QWORD PTR [rbx+0x10],rcx
    2c43:	mov    edx,0x1
    2c48:	mov    rsi,r13
    2c4b:	test   rsi,0x1
    2c52:	jne    2c76 <botlish_fn_15+0x13d>
    2c58:	xor    edx,edx
    2c5a:	mov    rsi,r13
    2c5d:	test   rsi,0x7
    2c64:	jne    2c76 <botlish_fn_15+0x13d>
    2c6a:	mov    rsi,r13
    2c6d:	movzx  rax,BYTE PTR [rsi]
    2c71:	cmp    al,0x1
    2c73:	sete   dl
    2c76:	test   dl,dl
    2c78:	jne    2c9c <botlish_fn_15+0x163>
    2c7e:	mov    rdi,r12
    2c81:	mov    rax,QWORD PTR [rdi+0x10]
    2c85:	mov    rcx,QWORD PTR [rax+0x58]
    2c89:	xor    rdx,rdx
    2c8c:	mov    rsi,r13
    2c8f:	call   2c94 <botlish_fn_15+0x15b>
			2c90: R_X86_64_PLT32	rt_type_error-0x4
    2c94:	mov    rdi,r12
    2c97:	jmp    2cb6 <botlish_fn_15+0x17d>
    2c9c:	mov    rdx,r13
    2c9f:	mov    rsi,r14
    2ca2:	mov    rdi,r12
    2ca5:	call   2caa <botlish_fn_15+0x171>
			2ca6: R_X86_64_PLT32	rt_substr-0x4
    2caa:	test   rax,rax
    2cad:	jne    2cdb <botlish_fn_15+0x1a2>
    2cb3:	mov    rdi,r12
    2cb6:	mov    rdi,r12
    2cb9:	mov    QWORD PTR [rdi],rbx
    2cbc:	xor    rax,rax
    2cbf:	mov    rbx,QWORD PTR [rsp]
    2cc3:	mov    r12,QWORD PTR [rsp+0x8]
    2cc8:	mov    r13,QWORD PTR [rsp+0x10]
    2ccd:	mov    r14,QWORD PTR [rsp+0x18]
    2cd2:	add    rsp,0x20
    2cd6:	mov    rsp,rbp
    2cd9:	pop    rbp
    2cda:	ret
    2cdb:	mov    rdi,r12
    2cde:	mov    QWORD PTR [rdi],rbx
    2ce1:	mov    rbx,QWORD PTR [rsp]
    2ce5:	mov    r12,QWORD PTR [rsp+0x8]
    2cea:	mov    r13,QWORD PTR [rsp+0x10]
    2cef:	mov    r14,QWORD PTR [rsp+0x18]
    2cf4:	add    rsp,0x20
    2cf8:	mov    rsp,rbp
    2cfb:	pop    rbp
    2cfc:	ret
    2cfd:	mov    r12,rdi
    2d00:	call   2d05 <botlish_fn_15+0x1cc>
			2d01: R_X86_64_PLT32	rt_stack_overflow-0x4
    2d05:	xor    rax,rax
    2d08:	mov    rbx,QWORD PTR [rsp]
    2d0c:	mov    r12,QWORD PTR [rsp+0x8]
    2d11:	mov    r13,QWORD PTR [rsp+0x10]
    2d16:	mov    r14,QWORD PTR [rsp+0x18]
    2d1b:	add    rsp,0x20
    2d1f:	mov    rsp,rbp
    2d22:	pop    rbp
    2d23:	ret

0000000000002d24 <botlish_entry_15: char_at<generic>>:
    2d24:	push   rbp
    2d25:	mov    rbp,rsp
    2d28:	mov    rdx,QWORD PTR [rdx]
    2d2b:	call   2d30 <botlish_entry_15+0xc>
			2d2c: R_X86_64_PLT32	botlish_fn_15-0x4 ; char_at<generic>
    2d30:	mov    rsp,rbp
    2d33:	pop    rbp
    2d34:	ret

0000000000002d35 <botlish_fn_16: char_at<generic>>:
    2d35:	push   rbp
    2d36:	mov    rbp,rsp
    2d39:	sub    rsp,0x40
    2d3d:	mov    QWORD PTR [rsp+0x10],rbx
    2d42:	mov    QWORD PTR [rsp+0x18],r12
    2d47:	mov    QWORD PTR [rsp+0x20],r13
    2d4c:	mov    QWORD PTR [rsp+0x28],r14
    2d51:	mov    QWORD PTR [rsp+0x30],r15
    2d56:	mov    r15,rcx
    2d59:	mov    rbx,QWORD PTR [rdi]
    2d5c:	mov    rax,QWORD PTR [rdi+0x8]
    2d60:	lea    rcx,[rbx+0x18]
    2d64:	cmp    rcx,rax
    2d67:	ja     2f30 <botlish_fn_16+0x1fb>
    2d6d:	lea    rax,[rbx+0x18]
    2d71:	mov    QWORD PTR [rdi],rax
    2d74:	mov    QWORD PTR [rbx],0x0
    2d7b:	mov    QWORD PTR [rbx+0x8],0x0
    2d83:	mov    QWORD PTR [rbx+0x10],0x0
    2d8b:	mov    QWORD PTR [rbx],rdx
    2d8e:	mov    rax,QWORD PTR [rsi+0x20]
    2d92:	mov    rax,QWORD PTR [rax]
    2d95:	mov    QWORD PTR [rbx+0x8],rax
    2d99:	mov    QWORD PTR [rsp],rax
    2d9d:	mov    QWORD PTR [rbx+0x10],0x3
    2da5:	mov    eax,0x1
    2daa:	test   rdx,0x1
    2db1:	je     2dbf <botlish_fn_16+0x8a>
    2db7:	mov    r14,rdx
    2dba:	jmp    2de2 <botlish_fn_16+0xad>
    2dbf:	xor    eax,eax
    2dc1:	test   rdx,0x7
    2dc8:	je     2dd6 <botlish_fn_16+0xa1>
    2dce:	mov    r14,rdx
    2dd1:	jmp    2de2 <botlish_fn_16+0xad>
    2dd6:	movzx  rax,BYTE PTR [rdx]
    2dda:	mov    r14,rdx
    2ddd:	cmp    al,0x1
    2ddf:	sete   al
    2de2:	test   al,al
    2de4:	jne    2e08 <botlish_fn_16+0xd3>
    2dea:	mov    rax,QWORD PTR [rdi+0x10]
    2dee:	mov    r13,rdi
    2df1:	mov    rcx,QWORD PTR [rax+0x50]
    2df5:	xor    rdx,rdx
    2df8:	mov    rsi,r14
    2dfb:	call   2e00 <botlish_fn_16+0xcb>
			2dfc: R_X86_64_PLT32	rt_type_error-0x4
    2e00:	mov    rdi,r13
    2e03:	jmp    2ecc <botlish_fn_16+0x197>
    2e08:	mov    rsi,r14
    2e0b:	mov    r13,rdi
    2e0e:	test   rsi,0x1
    2e15:	jne    2e23 <botlish_fn_16+0xee>
    2e1b:	mov    r14,rsi
    2e1e:	jmp    2e42 <botlish_fn_16+0x10d>
    2e23:	mov    rax,rsi
    2e26:	add    rax,0x2
    2e2a:	mov    r14,rsi
    2e2d:	seto   sil
    2e31:	test   sil,sil
    2e34:	jne    2e42 <botlish_fn_16+0x10d>
    2e3a:	mov    r12,rax
    2e3d:	jmp    2e55 <botlish_fn_16+0x120>
    2e42:	mov    edx,0x3
    2e47:	mov    rsi,r14
    2e4a:	mov    rdi,r13
    2e4d:	call   2e52 <botlish_fn_16+0x11d>
			2e4e: R_X86_64_PLT32	rt_int_add-0x4
    2e52:	mov    r12,rax
    2e55:	mov    ecx,0x1
    2e5a:	mov    rsi,r14
    2e5d:	test   rsi,0x1
    2e64:	jne    2e88 <botlish_fn_16+0x153>
    2e6a:	xor    ecx,ecx
    2e6c:	mov    rsi,r14
    2e6f:	test   rsi,0x7
    2e76:	jne    2e88 <botlish_fn_16+0x153>
    2e7c:	mov    rsi,r14
    2e7f:	movzx  rax,BYTE PTR [rsi]
    2e83:	cmp    al,0x1
    2e85:	sete   cl
    2e88:	test   cl,cl
    2e8a:	jne    2eae <botlish_fn_16+0x179>
    2e90:	mov    rdi,r13
    2e93:	mov    rax,QWORD PTR [rdi+0x10]
    2e97:	mov    rcx,QWORD PTR [rax+0x58]
    2e9b:	xor    rdx,rdx
    2e9e:	mov    rsi,r14
    2ea1:	call   2ea6 <botlish_fn_16+0x171>
			2ea2: R_X86_64_PLT32	rt_type_error-0x4
    2ea6:	mov    rdi,r13
    2ea9:	jmp    2ecc <botlish_fn_16+0x197>
    2eae:	mov    rcx,r12
    2eb1:	mov    rdx,r14
    2eb4:	mov    rsi,QWORD PTR [rsp]
    2eb8:	mov    rdi,r13
    2ebb:	call   2ec0 <botlish_fn_16+0x18b>
			2ebc: R_X86_64_PLT32	rt_str_region_check-0x4
    2ec0:	test   rax,rax
    2ec3:	jne    2ef7 <botlish_fn_16+0x1c2>
    2ec9:	mov    rdi,r13
    2ecc:	mov    rdi,r13
    2ecf:	mov    QWORD PTR [rdi],rbx
    2ed2:	xor    rax,rax
    2ed5:	mov    rbx,QWORD PTR [rsp+0x10]
    2eda:	mov    r12,QWORD PTR [rsp+0x18]
    2edf:	mov    r13,QWORD PTR [rsp+0x20]
    2ee4:	mov    r14,QWORD PTR [rsp+0x28]
    2ee9:	mov    r15,QWORD PTR [rsp+0x30]
    2eee:	add    rsp,0x40
    2ef2:	mov    rsp,rbp
    2ef5:	pop    rbp
    2ef6:	ret
    2ef7:	mov    rdi,r13
    2efa:	mov    QWORD PTR [rdi],rbx
    2efd:	mov    rcx,r15
    2f00:	mov    rsi,r14
    2f03:	mov    QWORD PTR [rcx],rsi
    2f06:	mov    QWORD PTR [rcx+0x8],r12
    2f0a:	mov    rax,QWORD PTR [rsp]
    2f0e:	mov    rbx,QWORD PTR [rsp+0x10]
    2f13:	mov    r12,QWORD PTR [rsp+0x18]
    2f18:	mov    r13,QWORD PTR [rsp+0x20]
    2f1d:	mov    r14,QWORD PTR [rsp+0x28]
    2f22:	mov    r15,QWORD PTR [rsp+0x30]
    2f27:	add    rsp,0x40
    2f2b:	mov    rsp,rbp
    2f2e:	pop    rbp
    2f2f:	ret
    2f30:	mov    r13,rdi
    2f33:	call   2f38 <botlish_fn_16+0x203>
			2f34: R_X86_64_PLT32	rt_stack_overflow-0x4
    2f38:	xor    rax,rax
    2f3b:	mov    rbx,QWORD PTR [rsp+0x10]
    2f40:	mov    r12,QWORD PTR [rsp+0x18]
    2f45:	mov    r13,QWORD PTR [rsp+0x20]
    2f4a:	mov    r14,QWORD PTR [rsp+0x28]
    2f4f:	mov    r15,QWORD PTR [rsp+0x30]
    2f54:	add    rsp,0x40
    2f58:	mov    rsp,rbp
    2f5b:	pop    rbp
    2f5c:	ret

0000000000002f5d <botlish_entry_16: char_at<generic>>:
    2f5d:	push   rbp
    2f5e:	mov    rbp,rsp
    2f61:	ud2

0000000000002f63 <botlish_fn_17: is_local_char<str>>:
    2f63:	push   rbp
    2f64:	mov    rbp,rsp
    2f67:	sub    rsp,0x20
    2f6b:	mov    QWORD PTR [rsp],rbx
    2f6f:	mov    QWORD PTR [rsp+0x8],r12
    2f74:	mov    QWORD PTR [rsp+0x10],r13
    2f79:	mov    r13,rsi
    2f7c:	mov    rbx,QWORD PTR [rdi]
    2f7f:	mov    rax,QWORD PTR [rdi+0x8]
    2f83:	lea    rcx,[rbx+0x8]
    2f87:	cmp    rcx,rax
    2f8a:	ja     30ed <botlish_fn_17+0x18a>
    2f90:	lea    rax,[rbx+0x8]
    2f94:	mov    QWORD PTR [rdi],rax
    2f97:	mov    r12,rdi
    2f9a:	mov    QWORD PTR [rbx],0x0
    2fa1:	mov    rsi,r13
    2fa4:	mov    rdi,r12
    2fa7:	call   2fac <botlish_fn_17+0x49>
			2fa8: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    2fac:	test   rax,rax
    2faf:	jne    2fd5 <botlish_fn_17+0x72>
    2fb5:	mov    rdi,r12
    2fb8:	mov    QWORD PTR [rdi],rbx
    2fbb:	xor    rax,rax
    2fbe:	mov    rbx,QWORD PTR [rsp]
    2fc2:	mov    r12,QWORD PTR [rsp+0x8]
    2fc7:	mov    r13,QWORD PTR [rsp+0x10]
    2fcc:	add    rsp,0x20
    2fd0:	mov    rsp,rbp
    2fd3:	pop    rbp
    2fd4:	ret
    2fd5:	cmp    rax,0x6
    2fd9:	je     30c8 <botlish_fn_17+0x165>
    2fdf:	mov    rdi,r12
    2fe2:	mov    rax,QWORD PTR [rdi+0x10]
    2fe6:	mov    rsi,QWORD PTR [rax+0x60]
    2fea:	mov    edx,0x1
    2fef:	mov    ecx,0x3
    2ff4:	mov    r8,r13
    2ff7:	call   2ffc <botlish_fn_17+0x99>
			2ff8: R_X86_64_PLT32	rt_str_region_eq-0x4
    2ffc:	cmp    rax,0x6
    3000:	je     30bb <botlish_fn_17+0x158>
    3006:	mov    rdi,r12
    3009:	mov    rax,QWORD PTR [rdi+0x10]
    300d:	mov    rsi,QWORD PTR [rax+0x68]
    3011:	mov    edx,0x1
    3016:	mov    ecx,0x3
    301b:	mov    r8,r13
    301e:	call   3023 <botlish_fn_17+0xc0>
			301f: R_X86_64_PLT32	rt_str_region_eq-0x4
    3023:	cmp    rax,0x6
    3027:	je     30b1 <botlish_fn_17+0x14e>
    302d:	mov    rdi,r12
    3030:	mov    rax,QWORD PTR [rdi+0x10]
    3034:	mov    rsi,QWORD PTR [rax+0x70]
    3038:	mov    edx,0x1
    303d:	mov    ecx,0x3
    3042:	mov    r8,r13
    3045:	call   304a <botlish_fn_17+0xe7>
			3046: R_X86_64_PLT32	rt_str_region_eq-0x4
    304a:	cmp    rax,0x6
    304e:	je     30a7 <botlish_fn_17+0x144>
    3054:	mov    rdi,r12
    3057:	mov    rcx,QWORD PTR [rdi+0x10]
    305b:	mov    rsi,QWORD PTR [rcx+0x50]
    305f:	mov    edx,0x1
    3064:	mov    ecx,0x3
    3069:	mov    r8,r13
    306c:	call   3071 <botlish_fn_17+0x10e>
			306d: R_X86_64_PLT32	rt_str_region_eq-0x4
    3071:	cmp    rax,0x6
    3075:	je     309d <botlish_fn_17+0x13a>
    307b:	mov    rdi,r12
    307e:	mov    rsi,QWORD PTR [rdi+0x10]
    3082:	mov    rsi,QWORD PTR [rsi+0x78]
    3086:	mov    edx,0x1
    308b:	mov    ecx,0x3
    3090:	mov    r8,r13
    3093:	call   3098 <botlish_fn_17+0x135>
			3094: R_X86_64_PLT32	rt_str_region_eq-0x4
    3098:	jmp    30c0 <botlish_fn_17+0x15d>
    309d:	mov    eax,0x6
    30a2:	jmp    30c0 <botlish_fn_17+0x15d>
    30a7:	mov    eax,0x6
    30ac:	jmp    30c0 <botlish_fn_17+0x15d>
    30b1:	mov    eax,0x6
    30b6:	jmp    30c0 <botlish_fn_17+0x15d>
    30bb:	mov    eax,0x6
    30c0:	mov    rdi,r12
    30c3:	jmp    30d0 <botlish_fn_17+0x16d>
    30c8:	mov    eax,0x6
    30cd:	mov    rdi,r12
    30d0:	mov    rdi,r12
    30d3:	mov    QWORD PTR [rdi],rbx
    30d6:	mov    rbx,QWORD PTR [rsp]
    30da:	mov    r12,QWORD PTR [rsp+0x8]
    30df:	mov    r13,QWORD PTR [rsp+0x10]
    30e4:	add    rsp,0x20
    30e8:	mov    rsp,rbp
    30eb:	pop    rbp
    30ec:	ret
    30ed:	mov    r12,rdi
    30f0:	call   30f5 <botlish_fn_17+0x192>
			30f1: R_X86_64_PLT32	rt_stack_overflow-0x4
    30f5:	xor    rax,rax
    30f8:	mov    rbx,QWORD PTR [rsp]
    30fc:	mov    r12,QWORD PTR [rsp+0x8]
    3101:	mov    r13,QWORD PTR [rsp+0x10]
    3106:	add    rsp,0x20
    310a:	mov    rsp,rbp
    310d:	pop    rbp
    310e:	ret

000000000000310f <botlish_entry_17: is_local_char<str>>:
    310f:	push   rbp
    3110:	mov    rbp,rsp
    3113:	mov    rsi,QWORD PTR [rdx]
    3116:	call   311b <botlish_entry_17+0xc>
			3117: R_X86_64_PLT32	botlish_fn_17-0x4 ; is_local_char<str>
    311b:	mov    rsp,rbp
    311e:	pop    rbp
    311f:	ret

0000000000003120 <botlish_fn_18: is_label_char<str>>:
    3120:	push   rbp
    3121:	mov    rbp,rsp
    3124:	sub    rsp,0x20
    3128:	mov    QWORD PTR [rsp],rbx
    312c:	mov    QWORD PTR [rsp+0x8],r12
    3131:	mov    QWORD PTR [rsp+0x10],r13
    3136:	mov    r13,rsi
    3139:	mov    rbx,QWORD PTR [rdi]
    313c:	mov    rax,QWORD PTR [rdi+0x8]
    3140:	lea    rcx,[rbx+0x8]
    3144:	cmp    rcx,rax
    3147:	ja     31e6 <botlish_fn_18+0xc6>
    314d:	lea    rax,[rbx+0x8]
    3151:	mov    QWORD PTR [rdi],rax
    3154:	mov    r12,rdi
    3157:	mov    QWORD PTR [rbx],0x0
    315e:	mov    rsi,r13
    3161:	mov    rdi,r12
    3164:	call   3169 <botlish_fn_18+0x49>
			3165: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    3169:	test   rax,rax
    316c:	jne    3192 <botlish_fn_18+0x72>
    3172:	mov    rdi,r12
    3175:	mov    QWORD PTR [rdi],rbx
    3178:	xor    rax,rax
    317b:	mov    rbx,QWORD PTR [rsp]
    317f:	mov    r12,QWORD PTR [rsp+0x8]
    3184:	mov    r13,QWORD PTR [rsp+0x10]
    3189:	add    rsp,0x20
    318d:	mov    rsp,rbp
    3190:	pop    rbp
    3191:	ret
    3192:	cmp    rax,0x6
    3196:	je     31c1 <botlish_fn_18+0xa1>
    319c:	mov    rdi,r12
    319f:	mov    rax,QWORD PTR [rdi+0x10]
    31a3:	mov    rsi,QWORD PTR [rax+0x78]
    31a7:	mov    edx,0x1
    31ac:	mov    ecx,0x3
    31b1:	mov    r8,r13
    31b4:	call   31b9 <botlish_fn_18+0x99>
			31b5: R_X86_64_PLT32	rt_str_region_eq-0x4
    31b9:	mov    rdi,r12
    31bc:	jmp    31c9 <botlish_fn_18+0xa9>
    31c1:	mov    eax,0x6
    31c6:	mov    rdi,r12
    31c9:	mov    rdi,r12
    31cc:	mov    QWORD PTR [rdi],rbx
    31cf:	mov    rbx,QWORD PTR [rsp]
    31d3:	mov    r12,QWORD PTR [rsp+0x8]
    31d8:	mov    r13,QWORD PTR [rsp+0x10]
    31dd:	add    rsp,0x20
    31e1:	mov    rsp,rbp
    31e4:	pop    rbp
    31e5:	ret
    31e6:	mov    r12,rdi
    31e9:	call   31ee <botlish_fn_18+0xce>
			31ea: R_X86_64_PLT32	rt_stack_overflow-0x4
    31ee:	xor    rax,rax
    31f1:	mov    rbx,QWORD PTR [rsp]
    31f5:	mov    r12,QWORD PTR [rsp+0x8]
    31fa:	mov    r13,QWORD PTR [rsp+0x10]
    31ff:	add    rsp,0x20
    3203:	mov    rsp,rbp
    3206:	pop    rbp
    3207:	ret

0000000000003208 <botlish_entry_18: is_label_char<str>>:
    3208:	push   rbp
    3209:	mov    rbp,rsp
    320c:	mov    rsi,QWORD PTR [rdx]
    320f:	call   3214 <botlish_entry_18+0xc>
			3210: R_X86_64_PLT32	botlish_fn_18-0x4 ; is_label_char<str>
    3214:	mov    rsp,rbp
    3217:	pop    rbp
    3218:	ret
    3219:	add    BYTE PTR [rax],al
    321b:	add    BYTE PTR [rax],al
    321d:	add    BYTE PTR [rax],al
	...

0000000000003220 <botlish_fn_19: scan_local<generic>>:
    3220:	push   rbp
    3221:	mov    rbp,rsp
    3224:	sub    rsp,0x20
    3228:	mov    QWORD PTR [rsp],rbx
    322c:	mov    QWORD PTR [rsp+0x8],r12
    3231:	mov    QWORD PTR [rsp+0x10],r13
    3236:	mov    QWORD PTR [rsp+0x18],r14
    323b:	mov    r12,QWORD PTR [rdi]
    323e:	mov    rax,QWORD PTR [rdi+0x8]
    3242:	lea    rcx,[r12+0x18]
    3247:	cmp    rcx,rax
    324a:	ja     342f <botlish_fn_19+0x20f>
    3250:	lea    rax,[r12+0x18]
    3255:	mov    QWORD PTR [rdi],rax
    3258:	mov    r13,rdi
    325b:	mov    QWORD PTR [r12],0x0
    3263:	mov    QWORD PTR [r12+0x8],0x0
    326c:	mov    QWORD PTR [r12+0x10],0x0
    3275:	mov    QWORD PTR [r12],rdx
    3279:	mov    rbx,rsi
    327c:	mov    rsi,rdx
    327f:	mov    rax,QWORD PTR [rbx+0x20]
    3283:	mov    rdx,QWORD PTR [rax]
    3286:	mov    ecx,0x1
    328b:	test   rsi,0x1
    3292:	jne    32b0 <botlish_fn_19+0x90>
    3298:	xor    ecx,ecx
    329a:	test   rsi,0x7
    32a1:	jne    32b0 <botlish_fn_19+0x90>
    32a7:	movzx  rax,BYTE PTR [rsi]
    32ab:	cmp    al,0x1
    32ad:	sete   cl
    32b0:	test   cl,cl
    32b2:	jne    32d6 <botlish_fn_19+0xb6>
    32b8:	mov    rdi,r13
    32bb:	mov    rax,QWORD PTR [rdi+0x10]
    32bf:	mov    rcx,QWORD PTR [rax+0x80]
    32c6:	xor    rdx,rdx
    32c9:	call   32ce <botlish_fn_19+0xae>
			32ca: R_X86_64_PLT32	rt_type_error-0x4
    32ce:	mov    rdi,r13
    32d1:	jmp    336d <botlish_fn_19+0x14d>
    32d6:	mov    rax,rsi
    32d9:	and    rax,rdx
    32dc:	mov    r14,rsi
    32df:	test   rax,0x1
    32e5:	jne    330b <botlish_fn_19+0xeb>
    32eb:	mov    rsi,r14
    32ee:	mov    rdi,r13
    32f1:	call   32f6 <botlish_fn_19+0xd6>
			32f2: R_X86_64_PLT32	rt_int_cmp-0x4
    32f6:	mov    ecx,0x2
    32fb:	test   rax,rax
    32fe:	cmovge rcx,QWORD PTR [rip+0x152]        # 3458 <botlish_fn_19+0x238>
    3306:	jmp    331e <botlish_fn_19+0xfe>
    330b:	mov    ecx,0x2
    3310:	mov    rsi,r14
    3313:	cmp    rsi,rdx
    3316:	cmovge rcx,QWORD PTR [rip+0x13a]        # 3458 <botlish_fn_19+0x238>
    331e:	cmp    rcx,0x6
    3322:	je     3407 <botlish_fn_19+0x1e7>
    3328:	mov    rdi,QWORD PTR [rbx+0x20]
    332c:	mov    rsi,QWORD PTR [rdi+0x8]
    3330:	mov    QWORD PTR [r12+0x8],rsi
    3335:	mov    rdx,r14
    3338:	mov    rdi,r13
    333b:	call   3340 <botlish_fn_19+0x120>
			333c: R_X86_64_PLT32	botlish_fn_15-0x4 ; char_at<generic>
    3340:	test   rax,rax
    3343:	jne    3351 <botlish_fn_19+0x131>
    3349:	mov    rdi,r13
    334c:	jmp    336d <botlish_fn_19+0x14d>
    3351:	mov    QWORD PTR [r12+0x8],rax
    3356:	mov    rsi,rax
    3359:	mov    rdi,r13
    335c:	call   3361 <botlish_fn_19+0x141>
			335d: R_X86_64_PLT32	botlish_fn_17-0x4 ; is_local_char<str>
    3361:	test   rax,rax
    3364:	jne    3392 <botlish_fn_19+0x172>
    336a:	mov    rdi,r13
    336d:	mov    rdi,r13
    3370:	mov    QWORD PTR [rdi],r12
    3373:	xor    rax,rax
    3376:	mov    rbx,QWORD PTR [rsp]
    337a:	mov    r12,QWORD PTR [rsp+0x8]
    337f:	mov    r13,QWORD PTR [rsp+0x10]
    3384:	mov    r14,QWORD PTR [rsp+0x18]
    3389:	add    rsp,0x20
    338d:	mov    rsp,rbp
    3390:	pop    rbp
    3391:	ret
    3392:	cmp    rax,0x6
    3396:	je     33a7 <botlish_fn_19+0x187>
    339c:	mov    rax,r14
    339f:	mov    rdi,r13
    33a2:	jmp    340d <botlish_fn_19+0x1ed>
    33a7:	mov    QWORD PTR [r12+0x8],rbx
    33ac:	mov    QWORD PTR [r12+0x10],0x3
    33b5:	mov    rsi,r14
    33b8:	test   rsi,0x1
    33bf:	je     33e5 <botlish_fn_19+0x1c5>
    33c5:	mov    rsi,r14
    33c8:	mov    rcx,rsi
    33cb:	add    rcx,0x2
    33cf:	seto   al
    33d2:	test   al,al
    33d4:	jne    33e5 <botlish_fn_19+0x1c5>
    33da:	mov    rsi,rcx
    33dd:	mov    r14,rcx
    33e0:	jmp    33fb <botlish_fn_19+0x1db>
    33e5:	mov    edx,0x3
    33ea:	mov    rsi,r14
    33ed:	mov    rdi,r13
    33f0:	call   33f5 <botlish_fn_19+0x1d5>
			33f1: R_X86_64_PLT32	rt_int_add-0x4
    33f5:	mov    rsi,rax
    33f8:	mov    r14,rax
    33fb:	mov    QWORD PTR [r12],rsi
    33ff:	mov    rsi,r14
    3402:	jmp    327f <botlish_fn_19+0x5f>
    3407:	mov    rax,r14
    340a:	mov    rdi,r13
    340d:	mov    rdi,r13
    3410:	mov    QWORD PTR [rdi],r12
    3413:	mov    rbx,QWORD PTR [rsp]
    3417:	mov    r12,QWORD PTR [rsp+0x8]
    341c:	mov    r13,QWORD PTR [rsp+0x10]
    3421:	mov    r14,QWORD PTR [rsp+0x18]
    3426:	add    rsp,0x20
    342a:	mov    rsp,rbp
    342d:	pop    rbp
    342e:	ret
    342f:	mov    r13,rdi
    3432:	call   3437 <botlish_fn_19+0x217>
			3433: R_X86_64_PLT32	rt_stack_overflow-0x4
    3437:	xor    rax,rax
    343a:	mov    rbx,QWORD PTR [rsp]
    343e:	mov    r12,QWORD PTR [rsp+0x8]
    3443:	mov    r13,QWORD PTR [rsp+0x10]
    3448:	mov    r14,QWORD PTR [rsp+0x18]
    344d:	add    rsp,0x20
    3451:	mov    rsp,rbp
    3454:	pop    rbp
    3455:	ret
    3456:	add    BYTE PTR [rax],al
    3458:	(bad)
    3459:	add    BYTE PTR [rax],al
    345b:	add    BYTE PTR [rax],al
    345d:	add    BYTE PTR [rax],al
	...

0000000000003460 <botlish_entry_19: scan_local<generic>>:
    3460:	push   rbp
    3461:	mov    rbp,rsp
    3464:	mov    rdx,QWORD PTR [rdx]
    3467:	call   346c <botlish_entry_19+0xc>
			3468: R_X86_64_PLT32	botlish_fn_19-0x4 ; scan_local<generic>
    346c:	mov    rsp,rbp
    346f:	pop    rbp
    3470:	ret
    3471:	add    BYTE PTR [rax],al
    3473:	add    BYTE PTR [rax],al
    3475:	add    BYTE PTR [rax],al
	...

0000000000003478 <botlish_fn_20: scan_label<generic>>:
    3478:	push   rbp
    3479:	mov    rbp,rsp
    347c:	sub    rsp,0x20
    3480:	mov    QWORD PTR [rsp],rbx
    3484:	mov    QWORD PTR [rsp+0x8],r12
    3489:	mov    QWORD PTR [rsp+0x10],r13
    348e:	mov    QWORD PTR [rsp+0x18],r14
    3493:	mov    r12,QWORD PTR [rdi]
    3496:	mov    rax,QWORD PTR [rdi+0x8]
    349a:	lea    rcx,[r12+0x18]
    349f:	cmp    rcx,rax
    34a2:	ja     3687 <botlish_fn_20+0x20f>
    34a8:	lea    rax,[r12+0x18]
    34ad:	mov    QWORD PTR [rdi],rax
    34b0:	mov    r13,rdi
    34b3:	mov    QWORD PTR [r12],0x0
    34bb:	mov    QWORD PTR [r12+0x8],0x0
    34c4:	mov    QWORD PTR [r12+0x10],0x0
    34cd:	mov    QWORD PTR [r12],rdx
    34d1:	mov    rbx,rsi
    34d4:	mov    rsi,rdx
    34d7:	mov    rax,QWORD PTR [rbx+0x20]
    34db:	mov    rdx,QWORD PTR [rax]
    34de:	mov    ecx,0x1
    34e3:	test   rsi,0x1
    34ea:	jne    3508 <botlish_fn_20+0x90>
    34f0:	xor    ecx,ecx
    34f2:	test   rsi,0x7
    34f9:	jne    3508 <botlish_fn_20+0x90>
    34ff:	movzx  rax,BYTE PTR [rsi]
    3503:	cmp    al,0x1
    3505:	sete   cl
    3508:	test   cl,cl
    350a:	jne    352e <botlish_fn_20+0xb6>
    3510:	mov    rdi,r13
    3513:	mov    rax,QWORD PTR [rdi+0x10]
    3517:	mov    rcx,QWORD PTR [rax+0x80]
    351e:	xor    rdx,rdx
    3521:	call   3526 <botlish_fn_20+0xae>
			3522: R_X86_64_PLT32	rt_type_error-0x4
    3526:	mov    rdi,r13
    3529:	jmp    35c5 <botlish_fn_20+0x14d>
    352e:	mov    rax,rsi
    3531:	and    rax,rdx
    3534:	mov    r14,rsi
    3537:	test   rax,0x1
    353d:	jne    3563 <botlish_fn_20+0xeb>
    3543:	mov    rsi,r14
    3546:	mov    rdi,r13
    3549:	call   354e <botlish_fn_20+0xd6>
			354a: R_X86_64_PLT32	rt_int_cmp-0x4
    354e:	mov    ecx,0x2
    3553:	test   rax,rax
    3556:	cmovge rcx,QWORD PTR [rip+0x152]        # 36b0 <botlish_fn_20+0x238>
    355e:	jmp    3576 <botlish_fn_20+0xfe>
    3563:	mov    ecx,0x2
    3568:	mov    rsi,r14
    356b:	cmp    rsi,rdx
    356e:	cmovge rcx,QWORD PTR [rip+0x13a]        # 36b0 <botlish_fn_20+0x238>
    3576:	cmp    rcx,0x6
    357a:	je     365f <botlish_fn_20+0x1e7>
    3580:	mov    rdi,QWORD PTR [rbx+0x20]
    3584:	mov    rsi,QWORD PTR [rdi+0x8]
    3588:	mov    QWORD PTR [r12+0x8],rsi
    358d:	mov    rdx,r14
    3590:	mov    rdi,r13
    3593:	call   3598 <botlish_fn_20+0x120>
			3594: R_X86_64_PLT32	botlish_fn_15-0x4 ; char_at<generic>
    3598:	test   rax,rax
    359b:	jne    35a9 <botlish_fn_20+0x131>
    35a1:	mov    rdi,r13
    35a4:	jmp    35c5 <botlish_fn_20+0x14d>
    35a9:	mov    QWORD PTR [r12+0x8],rax
    35ae:	mov    rsi,rax
    35b1:	mov    rdi,r13
    35b4:	call   35b9 <botlish_fn_20+0x141>
			35b5: R_X86_64_PLT32	botlish_fn_18-0x4 ; is_label_char<str>
    35b9:	test   rax,rax
    35bc:	jne    35ea <botlish_fn_20+0x172>
    35c2:	mov    rdi,r13
    35c5:	mov    rdi,r13
    35c8:	mov    QWORD PTR [rdi],r12
    35cb:	xor    rax,rax
    35ce:	mov    rbx,QWORD PTR [rsp]
    35d2:	mov    r12,QWORD PTR [rsp+0x8]
    35d7:	mov    r13,QWORD PTR [rsp+0x10]
    35dc:	mov    r14,QWORD PTR [rsp+0x18]
    35e1:	add    rsp,0x20
    35e5:	mov    rsp,rbp
    35e8:	pop    rbp
    35e9:	ret
    35ea:	cmp    rax,0x6
    35ee:	je     35ff <botlish_fn_20+0x187>
    35f4:	mov    rax,r14
    35f7:	mov    rdi,r13
    35fa:	jmp    3665 <botlish_fn_20+0x1ed>
    35ff:	mov    QWORD PTR [r12+0x8],rbx
    3604:	mov    QWORD PTR [r12+0x10],0x3
    360d:	mov    rsi,r14
    3610:	test   rsi,0x1
    3617:	je     363d <botlish_fn_20+0x1c5>
    361d:	mov    rsi,r14
    3620:	mov    rcx,rsi
    3623:	add    rcx,0x2
    3627:	seto   al
    362a:	test   al,al
    362c:	jne    363d <botlish_fn_20+0x1c5>
    3632:	mov    rsi,rcx
    3635:	mov    r14,rcx
    3638:	jmp    3653 <botlish_fn_20+0x1db>
    363d:	mov    edx,0x3
    3642:	mov    rsi,r14
    3645:	mov    rdi,r13
    3648:	call   364d <botlish_fn_20+0x1d5>
			3649: R_X86_64_PLT32	rt_int_add-0x4
    364d:	mov    rsi,rax
    3650:	mov    r14,rax
    3653:	mov    QWORD PTR [r12],rsi
    3657:	mov    rsi,r14
    365a:	jmp    34d7 <botlish_fn_20+0x5f>
    365f:	mov    rax,r14
    3662:	mov    rdi,r13
    3665:	mov    rdi,r13
    3668:	mov    QWORD PTR [rdi],r12
    366b:	mov    rbx,QWORD PTR [rsp]
    366f:	mov    r12,QWORD PTR [rsp+0x8]
    3674:	mov    r13,QWORD PTR [rsp+0x10]
    3679:	mov    r14,QWORD PTR [rsp+0x18]
    367e:	add    rsp,0x20
    3682:	mov    rsp,rbp
    3685:	pop    rbp
    3686:	ret
    3687:	mov    r13,rdi
    368a:	call   368f <botlish_fn_20+0x217>
			368b: R_X86_64_PLT32	rt_stack_overflow-0x4
    368f:	xor    rax,rax
    3692:	mov    rbx,QWORD PTR [rsp]
    3696:	mov    r12,QWORD PTR [rsp+0x8]
    369b:	mov    r13,QWORD PTR [rsp+0x10]
    36a0:	mov    r14,QWORD PTR [rsp+0x18]
    36a5:	add    rsp,0x20
    36a9:	mov    rsp,rbp
    36ac:	pop    rbp
    36ad:	ret
    36ae:	add    BYTE PTR [rax],al
    36b0:	(bad)
    36b1:	add    BYTE PTR [rax],al
    36b3:	add    BYTE PTR [rax],al
    36b5:	add    BYTE PTR [rax],al
	...

00000000000036b8 <botlish_entry_20: scan_label<generic>>:
    36b8:	push   rbp
    36b9:	mov    rbp,rsp
    36bc:	mov    rdx,QWORD PTR [rdx]
    36bf:	call   36c4 <botlish_entry_20+0xc>
			36c0: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_label<generic>
    36c4:	mov    rsp,rbp
    36c7:	pop    rbp
    36c8:	ret
    36c9:	add    BYTE PTR [rax],al
    36cb:	add    BYTE PTR [rax],al
    36cd:	add    BYTE PTR [rax],al
	...

00000000000036d0 <botlish_fn_21: scan_alpha<generic>>:
    36d0:	push   rbp
    36d1:	mov    rbp,rsp
    36d4:	sub    rsp,0x20
    36d8:	mov    QWORD PTR [rsp],rbx
    36dc:	mov    QWORD PTR [rsp+0x8],r12
    36e1:	mov    QWORD PTR [rsp+0x10],r13
    36e6:	mov    QWORD PTR [rsp+0x18],r14
    36eb:	mov    r12,QWORD PTR [rdi]
    36ee:	mov    rax,QWORD PTR [rdi+0x8]
    36f2:	lea    rcx,[r12+0x18]
    36f7:	cmp    rcx,rax
    36fa:	ja     38da <botlish_fn_21+0x20a>
    3700:	lea    rax,[r12+0x18]
    3705:	mov    QWORD PTR [rdi],rax
    3708:	mov    r13,rdi
    370b:	mov    QWORD PTR [r12],0x0
    3713:	mov    QWORD PTR [r12+0x8],0x0
    371c:	mov    QWORD PTR [r12+0x10],0x0
    3725:	mov    QWORD PTR [r12],rdx
    3729:	mov    rbx,rsi
    372c:	mov    rsi,rdx
    372f:	mov    rax,QWORD PTR [rbx+0x20]
    3733:	mov    rdx,QWORD PTR [rax]
    3736:	mov    ecx,0x1
    373b:	test   rsi,0x1
    3742:	jne    3760 <botlish_fn_21+0x90>
    3748:	xor    ecx,ecx
    374a:	test   rsi,0x7
    3751:	jne    3760 <botlish_fn_21+0x90>
    3757:	movzx  rax,BYTE PTR [rsi]
    375b:	cmp    al,0x1
    375d:	sete   cl
    3760:	test   cl,cl
    3762:	jne    3786 <botlish_fn_21+0xb6>
    3768:	mov    rdi,r13
    376b:	mov    rax,QWORD PTR [rdi+0x10]
    376f:	mov    rcx,QWORD PTR [rax+0x80]
    3776:	xor    rdx,rdx
    3779:	call   377e <botlish_fn_21+0xae>
			377a: R_X86_64_PLT32	rt_type_error-0x4
    377e:	mov    rdi,r13
    3781:	jmp    3818 <botlish_fn_21+0x148>
    3786:	mov    rax,rsi
    3789:	and    rax,rdx
    378c:	mov    r14,rsi
    378f:	test   rax,0x1
    3795:	jne    37bb <botlish_fn_21+0xeb>
    379b:	mov    rsi,r14
    379e:	mov    rdi,r13
    37a1:	call   37a6 <botlish_fn_21+0xd6>
			37a2: R_X86_64_PLT32	rt_int_cmp-0x4
    37a6:	mov    ecx,0x2
    37ab:	test   rax,rax
    37ae:	cmovge rcx,QWORD PTR [rip+0x152]        # 3908 <botlish_fn_21+0x238>
    37b6:	jmp    37ce <botlish_fn_21+0xfe>
    37bb:	mov    ecx,0x2
    37c0:	mov    rsi,r14
    37c3:	cmp    rsi,rdx
    37c6:	cmovge rcx,QWORD PTR [rip+0x13a]        # 3908 <botlish_fn_21+0x238>
    37ce:	cmp    rcx,0x6
    37d2:	je     38b2 <botlish_fn_21+0x1e2>
    37d8:	mov    rdi,QWORD PTR [rbx+0x20]
    37dc:	mov    rsi,QWORD PTR [rdi+0x8]
    37e0:	mov    QWORD PTR [r12+0x8],rsi
    37e5:	mov    rdx,r14
    37e8:	mov    rdi,r13
    37eb:	call   37f0 <botlish_fn_21+0x120>
			37ec: R_X86_64_PLT32	botlish_fn_15-0x4 ; char_at<generic>
    37f0:	test   rax,rax
    37f3:	mov    rsi,rax
    37f6:	jne    3804 <botlish_fn_21+0x134>
    37fc:	mov    rdi,r13
    37ff:	jmp    3818 <botlish_fn_21+0x148>
    3804:	mov    rdi,r13
    3807:	call   380c <botlish_fn_21+0x13c>
			3808: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    380c:	test   rax,rax
    380f:	jne    383d <botlish_fn_21+0x16d>
    3815:	mov    rdi,r13
    3818:	mov    rdi,r13
    381b:	mov    QWORD PTR [rdi],r12
    381e:	xor    rax,rax
    3821:	mov    rbx,QWORD PTR [rsp]
    3825:	mov    r12,QWORD PTR [rsp+0x8]
    382a:	mov    r13,QWORD PTR [rsp+0x10]
    382f:	mov    r14,QWORD PTR [rsp+0x18]
    3834:	add    rsp,0x20
    3838:	mov    rsp,rbp
    383b:	pop    rbp
    383c:	ret
    383d:	cmp    rax,0x6
    3841:	je     3852 <botlish_fn_21+0x182>
    3847:	mov    rax,r14
    384a:	mov    rdi,r13
    384d:	jmp    38b8 <botlish_fn_21+0x1e8>
    3852:	mov    QWORD PTR [r12+0x8],rbx
    3857:	mov    QWORD PTR [r12+0x10],0x3
    3860:	mov    rsi,r14
    3863:	test   rsi,0x1
    386a:	je     3890 <botlish_fn_21+0x1c0>
    3870:	mov    rsi,r14
    3873:	mov    rcx,rsi
    3876:	add    rcx,0x2
    387a:	seto   al
    387d:	test   al,al
    387f:	jne    3890 <botlish_fn_21+0x1c0>
    3885:	mov    rsi,rcx
    3888:	mov    r14,rcx
    388b:	jmp    38a6 <botlish_fn_21+0x1d6>
    3890:	mov    edx,0x3
    3895:	mov    rsi,r14
    3898:	mov    rdi,r13
    389b:	call   38a0 <botlish_fn_21+0x1d0>
			389c: R_X86_64_PLT32	rt_int_add-0x4
    38a0:	mov    rsi,rax
    38a3:	mov    r14,rax
    38a6:	mov    QWORD PTR [r12],rsi
    38aa:	mov    rsi,r14
    38ad:	jmp    372f <botlish_fn_21+0x5f>
    38b2:	mov    rax,r14
    38b5:	mov    rdi,r13
    38b8:	mov    rdi,r13
    38bb:	mov    QWORD PTR [rdi],r12
    38be:	mov    rbx,QWORD PTR [rsp]
    38c2:	mov    r12,QWORD PTR [rsp+0x8]
    38c7:	mov    r13,QWORD PTR [rsp+0x10]
    38cc:	mov    r14,QWORD PTR [rsp+0x18]
    38d1:	add    rsp,0x20
    38d5:	mov    rsp,rbp
    38d8:	pop    rbp
    38d9:	ret
    38da:	mov    r13,rdi
    38dd:	call   38e2 <botlish_fn_21+0x212>
			38de: R_X86_64_PLT32	rt_stack_overflow-0x4
    38e2:	xor    rax,rax
    38e5:	mov    rbx,QWORD PTR [rsp]
    38e9:	mov    r12,QWORD PTR [rsp+0x8]
    38ee:	mov    r13,QWORD PTR [rsp+0x10]
    38f3:	mov    r14,QWORD PTR [rsp+0x18]
    38f8:	add    rsp,0x20
    38fc:	mov    rsp,rbp
    38ff:	pop    rbp
    3900:	ret
    3901:	add    BYTE PTR [rax],al
    3903:	add    BYTE PTR [rax],al
    3905:	add    BYTE PTR [rax],al
    3907:	add    BYTE PTR [rsi],al
    3909:	add    BYTE PTR [rax],al
    390b:	add    BYTE PTR [rax],al
    390d:	add    BYTE PTR [rax],al
	...

0000000000003910 <botlish_entry_21: scan_alpha<generic>>:
    3910:	push   rbp
    3911:	mov    rbp,rsp
    3914:	mov    rdx,QWORD PTR [rdx]
    3917:	call   391c <botlish_entry_21+0xc>
			3918: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_alpha<generic>
    391c:	mov    rsp,rbp
    391f:	pop    rbp
    3920:	ret
    3921:	add    BYTE PTR [rax],al
    3923:	add    BYTE PTR [rax],al
    3925:	add    BYTE PTR [rax],al
	...

0000000000003928 <botlish_fn_22: tld_ok<generic>>:
    3928:	push   rbp
    3929:	mov    rbp,rsp
    392c:	sub    rsp,0x30
    3930:	mov    QWORD PTR [rsp],rbx
    3934:	mov    QWORD PTR [rsp+0x8],r12
    3939:	mov    QWORD PTR [rsp+0x10],r13
    393e:	mov    QWORD PTR [rsp+0x18],r14
    3943:	mov    QWORD PTR [rsp+0x20],r15
    3948:	mov    rbx,QWORD PTR [rdi]
    394b:	mov    rax,QWORD PTR [rdi+0x8]
    394f:	lea    rcx,[rbx+0x10]
    3953:	cmp    rcx,rax
    3956:	ja     3b67 <botlish_fn_22+0x23f>
    395c:	lea    rax,[rbx+0x10]
    3960:	mov    QWORD PTR [rdi],rax
    3963:	mov    r12,rdi
    3966:	mov    QWORD PTR [rbx],0x0
    396d:	mov    QWORD PTR [rbx+0x8],0x0
    3975:	mov    QWORD PTR [rbx],rdx
    3978:	mov    r8,rdx
    397b:	mov    rax,QWORD PTR [rsi+0x20]
    397f:	mov    r15,rsi
    3982:	mov    rsi,QWORD PTR [rax]
    3985:	mov    QWORD PTR [rbx+0x8],rsi
    3989:	mov    r13,r8
    398c:	mov    rdx,r13
    398f:	mov    rdi,r12
    3992:	call   3997 <botlish_fn_22+0x6f>
			3993: R_X86_64_PLT32	botlish_fn_21-0x4 ; scan_alpha<generic>
    3997:	mov    rcx,rax
    399a:	mov    r14,rax
    399d:	test   rax,rcx
    39a0:	jne    39ae <botlish_fn_22+0x86>
    39a6:	mov    rdi,r12
    39a9:	jmp    3a83 <botlish_fn_22+0x15b>
    39ae:	mov    rax,r14
    39b1:	mov    QWORD PTR [rbx+0x8],rax
    39b5:	mov    rsi,r15
    39b8:	mov    rax,QWORD PTR [rsi+0x20]
    39bc:	mov    rdx,QWORD PTR [rax+0x8]
    39c0:	mov    rax,r14
    39c3:	and    rax,rdx
    39c6:	test   rax,0x1
    39cc:	jne    39f5 <botlish_fn_22+0xcd>
    39d2:	mov    rsi,r14
    39d5:	mov    rdi,r12
    39d8:	call   39dd <botlish_fn_22+0xb5>
			39d9: R_X86_64_PLT32	rt_int_cmp-0x4
    39dd:	mov    ecx,0x2
    39e2:	test   rax,rax
    39e5:	cmove  rcx,QWORD PTR [rip+0x1ab]        # 3b98 <botlish_fn_22+0x270>
    39ed:	mov    rax,r14
    39f0:	jmp    3a08 <botlish_fn_22+0xe0>
    39f5:	mov    ecx,0x2
    39fa:	mov    rax,r14
    39fd:	cmp    rax,rdx
    3a00:	cmove  rcx,QWORD PTR [rip+0x190]        # 3b98 <botlish_fn_22+0x270>
    3a08:	cmp    rcx,0x6
    3a0c:	je     3a22 <botlish_fn_22+0xfa>
    3a12:	mov    ecx,0x2
    3a17:	mov    rax,rcx
    3a1a:	mov    rdi,r12
    3a1d:	jmp    3b40 <botlish_fn_22+0x218>
    3a22:	mov    ecx,0x1
    3a27:	test   r13,0x1
    3a2e:	je     3a3c <botlish_fn_22+0x114>
    3a34:	mov    r8,r13
    3a37:	jmp    3a62 <botlish_fn_22+0x13a>
    3a3c:	xor    ecx,ecx
    3a3e:	test   r13,0x7
    3a45:	je     3a53 <botlish_fn_22+0x12b>
    3a4b:	mov    r8,r13
    3a4e:	jmp    3a62 <botlish_fn_22+0x13a>
    3a53:	movzx  rcx,BYTE PTR [r13+0x0]
    3a58:	mov    r8,r13
    3a5b:	rex cmp cl,0x1
    3a5f:	sete   cl
    3a62:	test   cl,cl
    3a64:	jne    3aad <botlish_fn_22+0x185>
    3a6a:	mov    rdi,r12
    3a6d:	mov    rax,QWORD PTR [rdi+0x10]
    3a71:	mov    rcx,QWORD PTR [rax+0x78]
    3a75:	xor    rdx,rdx
    3a78:	mov    rsi,r8
    3a7b:	call   3a80 <botlish_fn_22+0x158>
			3a7c: R_X86_64_PLT32	rt_type_error-0x4
    3a80:	mov    rdi,r12
    3a83:	mov    rdi,r12
    3a86:	mov    QWORD PTR [rdi],rbx
    3a89:	xor    rax,rax
    3a8c:	mov    rbx,QWORD PTR [rsp]
    3a90:	mov    r12,QWORD PTR [rsp+0x8]
    3a95:	mov    r13,QWORD PTR [rsp+0x10]
    3a9a:	mov    r14,QWORD PTR [rsp+0x18]
    3a9f:	mov    r15,QWORD PTR [rsp+0x20]
    3aa4:	add    rsp,0x30
    3aa8:	mov    rsp,rbp
    3aab:	pop    rbp
    3aac:	ret
    3aad:	mov    rdx,r8
    3ab0:	mov    rcx,rax
    3ab3:	and    rcx,rdx
    3ab6:	test   rcx,0x1
    3abd:	jne    3ace <botlish_fn_22+0x1a6>
    3ac3:	mov    rdx,r8
    3ac6:	mov    rsi,rax
    3ac9:	jmp    3aef <botlish_fn_22+0x1c7>
    3ace:	mov    rdx,r8
    3ad1:	mov    rcx,rax
    3ad4:	sub    rcx,rdx
    3ad7:	mov    r14,rax
    3ada:	seto   al
    3add:	lea    rsi,[rcx+0x1]
    3ae1:	test   al,al
    3ae3:	je     3afa <botlish_fn_22+0x1d2>
    3ae9:	mov    rdx,r8
    3aec:	mov    rsi,r14
    3aef:	mov    rdi,r12
    3af2:	call   3af7 <botlish_fn_22+0x1cf>
			3af3: R_X86_64_PLT32	rt_int_sub-0x4
    3af7:	mov    rsi,rax
    3afa:	test   rsi,0x1
    3b01:	jne    3b2c <botlish_fn_22+0x204>
    3b07:	mov    edx,0x5
    3b0c:	mov    rdi,r12
    3b0f:	call   3b14 <botlish_fn_22+0x1ec>
			3b10: R_X86_64_PLT32	rt_int_cmp-0x4
    3b14:	mov    ecx,0x2
    3b19:	test   rax,rax
    3b1c:	mov    rax,rcx
    3b1f:	cmovge rax,QWORD PTR [rip+0x71]        # 3b98 <botlish_fn_22+0x270>
    3b27:	jmp    3b3d <botlish_fn_22+0x215>
    3b2c:	mov    eax,0x2
    3b31:	cmp    rsi,0x5
    3b35:	cmovge rax,QWORD PTR [rip+0x5b]        # 3b98 <botlish_fn_22+0x270>
    3b3d:	mov    rdi,r12
    3b40:	mov    rdi,r12
    3b43:	mov    QWORD PTR [rdi],rbx
    3b46:	mov    rbx,QWORD PTR [rsp]
    3b4a:	mov    r12,QWORD PTR [rsp+0x8]
    3b4f:	mov    r13,QWORD PTR [rsp+0x10]
    3b54:	mov    r14,QWORD PTR [rsp+0x18]
    3b59:	mov    r15,QWORD PTR [rsp+0x20]
    3b5e:	add    rsp,0x30
    3b62:	mov    rsp,rbp
    3b65:	pop    rbp
    3b66:	ret
    3b67:	mov    r12,rdi
    3b6a:	call   3b6f <botlish_fn_22+0x247>
			3b6b: R_X86_64_PLT32	rt_stack_overflow-0x4
    3b6f:	xor    rax,rax
    3b72:	mov    rbx,QWORD PTR [rsp]
    3b76:	mov    r12,QWORD PTR [rsp+0x8]
    3b7b:	mov    r13,QWORD PTR [rsp+0x10]
    3b80:	mov    r14,QWORD PTR [rsp+0x18]
    3b85:	mov    r15,QWORD PTR [rsp+0x20]
    3b8a:	add    rsp,0x30
    3b8e:	mov    rsp,rbp
    3b91:	pop    rbp
    3b92:	ret
    3b93:	add    BYTE PTR [rax],al
    3b95:	add    BYTE PTR [rax],al
    3b97:	add    BYTE PTR [rsi],al
    3b99:	add    BYTE PTR [rax],al
    3b9b:	add    BYTE PTR [rax],al
    3b9d:	add    BYTE PTR [rax],al
	...

0000000000003ba0 <botlish_entry_22: tld_ok<generic>>:
    3ba0:	push   rbp
    3ba1:	mov    rbp,rsp
    3ba4:	mov    rdx,QWORD PTR [rdx]
    3ba7:	call   3bac <botlish_entry_22+0xc>
			3ba8: R_X86_64_PLT32	botlish_fn_22-0x4 ; tld_ok<generic>
    3bac:	mov    rsp,rbp
    3baf:	pop    rbp
    3bb0:	ret
    3bb1:	add    BYTE PTR [rax],al
    3bb3:	add    BYTE PTR [rax],al
    3bb5:	add    BYTE PTR [rax],al
	...

0000000000003bb8 <botlish_fn_23: domain_loop<generic>>:
    3bb8:	push   rbp
    3bb9:	mov    rbp,rsp
    3bbc:	sub    rsp,0x50
    3bc0:	mov    QWORD PTR [rsp+0x20],rbx
    3bc5:	mov    QWORD PTR [rsp+0x28],r12
    3bca:	mov    QWORD PTR [rsp+0x30],r13
    3bcf:	mov    QWORD PTR [rsp+0x38],r14
    3bd4:	mov    QWORD PTR [rsp+0x40],r15
    3bd9:	mov    r13,QWORD PTR [rdi]
    3bdc:	mov    rax,QWORD PTR [rdi+0x8]
    3be0:	lea    rcx,[r13+0x10]
    3be4:	cmp    rcx,rax
    3be7:	ja     3e63 <botlish_fn_23+0x2ab>
    3bed:	lea    rax,[r13+0x10]
    3bf1:	mov    QWORD PTR [rdi],rax
    3bf4:	mov    r15,rdi
    3bf7:	mov    QWORD PTR [r13+0x0],0x0
    3bff:	mov    QWORD PTR [r13+0x8],0x0
    3c07:	mov    QWORD PTR [r13+0x0],rdx
    3c0b:	mov    QWORD PTR [rsp+0x10],rdx
    3c10:	lea    rbx,[rsp]
    3c14:	mov    r12,rsi
    3c17:	mov    rax,QWORD PTR [r12+0x20]
    3c1c:	mov    rsi,QWORD PTR [rax]
    3c1f:	mov    QWORD PTR [r13+0x8],rsi
    3c23:	mov    rdx,QWORD PTR [rsp+0x10]
    3c28:	mov    rdi,r15
    3c2b:	call   3c30 <botlish_fn_23+0x78>
			3c2c: R_X86_64_PLT32	botlish_fn_20-0x4 ; scan_label<generic>
    3c30:	mov    rcx,rax
    3c33:	mov    r14,rax
    3c36:	test   rax,rcx
    3c39:	jne    3c47 <botlish_fn_23+0x8f>
    3c3f:	mov    rdi,r15
    3c42:	jmp    3dd1 <botlish_fn_23+0x219>
    3c47:	mov    rax,r14
    3c4a:	mov    QWORD PTR [r13+0x0],rax
    3c4e:	mov    rdx,QWORD PTR [rsp+0x10]
    3c53:	mov    rsi,rax
    3c56:	and    rsi,rdx
    3c59:	test   rsi,0x1
    3c60:	jne    3c87 <botlish_fn_23+0xcf>
    3c66:	mov    rdx,QWORD PTR [rsp+0x10]
    3c6b:	mov    rsi,r14
    3c6e:	mov    rdi,r15
    3c71:	call   3c76 <botlish_fn_23+0xbe>
			3c72: R_X86_64_PLT32	rt_value_eq-0x4
    3c76:	test   rax,rax
    3c79:	jne    3c9c <botlish_fn_23+0xe4>
    3c7f:	mov    rdi,r15
    3c82:	jmp    3dd1 <botlish_fn_23+0x219>
    3c87:	mov    eax,0x2
    3c8c:	mov    rdx,QWORD PTR [rsp+0x10]
    3c91:	cmp    r14,rdx
    3c94:	cmove  rax,QWORD PTR [rip+0x1f4]        # 3e90 <botlish_fn_23+0x2d8>
    3c9c:	cmp    rax,0x6
    3ca0:	je     3e31 <botlish_fn_23+0x279>
    3ca6:	mov    rax,QWORD PTR [r12+0x20]
    3cab:	mov    rdx,QWORD PTR [rax+0x8]
    3caf:	mov    rax,r14
    3cb2:	and    rax,rdx
    3cb5:	test   rax,0x1
    3cbb:	jne    3ce1 <botlish_fn_23+0x129>
    3cc1:	mov    rsi,r14
    3cc4:	mov    rdi,r15
    3cc7:	call   3ccc <botlish_fn_23+0x114>
			3cc8: R_X86_64_PLT32	rt_int_cmp-0x4
    3ccc:	mov    ecx,0x2
    3cd1:	test   rax,rax
    3cd4:	cmovge rcx,QWORD PTR [rip+0x1b4]        # 3e90 <botlish_fn_23+0x2d8>
    3cdc:	jmp    3cf1 <botlish_fn_23+0x139>
    3ce1:	mov    ecx,0x2
    3ce6:	cmp    r14,rdx
    3ce9:	cmovge rcx,QWORD PTR [rip+0x19f]        # 3e90 <botlish_fn_23+0x2d8>
    3cf1:	cmp    rcx,0x6
    3cf5:	je     3e22 <botlish_fn_23+0x26a>
    3cfb:	mov    rax,QWORD PTR [r12+0x20]
    3d00:	mov    rsi,QWORD PTR [rax+0x10]
    3d04:	mov    QWORD PTR [r13+0x8],rsi
    3d08:	mov    rcx,rbx
    3d0b:	mov    rdx,r14
    3d0e:	mov    rdi,r15
    3d11:	call   3d16 <botlish_fn_23+0x15e>
			3d12: R_X86_64_PLT32	botlish_fn_16-0x4 ; char_at<generic>
    3d16:	test   rax,rax
    3d19:	mov    rsi,rax
    3d1c:	jne    3d2a <botlish_fn_23+0x172>
    3d22:	mov    rdi,r15
    3d25:	jmp    3dd1 <botlish_fn_23+0x219>
    3d2a:	mov    rdx,QWORD PTR [rsp]
    3d2e:	mov    rcx,QWORD PTR [rsp+0x8]
    3d33:	mov    rdi,r15
    3d36:	mov    rax,QWORD PTR [rdi+0x10]
    3d3a:	mov    r8,QWORD PTR [rax+0x60]
    3d3e:	call   3d43 <botlish_fn_23+0x18b>
			3d3f: R_X86_64_PLT32	rt_str_region_eq-0x4
    3d43:	cmp    rax,0x6
    3d47:	je     3d59 <botlish_fn_23+0x1a1>
    3d4d:	mov    rax,0xffffffffffffffff
    3d54:	jmp    3e29 <botlish_fn_23+0x271>
    3d59:	mov    QWORD PTR [r13+0x8],0x3
    3d61:	test   r14,0x1
    3d68:	je     3d8f <botlish_fn_23+0x1d7>
    3d6e:	mov    rdx,r14
    3d71:	add    rdx,0x2
    3d75:	mov    QWORD PTR [rsp+0x10],rdx
    3d7a:	seto   al
    3d7d:	test   al,al
    3d7f:	jne    3d8f <botlish_fn_23+0x1d7>
    3d85:	mov    rdx,QWORD PTR [rsp+0x10]
    3d8a:	jmp    3da7 <botlish_fn_23+0x1ef>
    3d8f:	mov    edx,0x3
    3d94:	mov    rsi,r14
    3d97:	mov    rdi,r15
    3d9a:	call   3d9f <botlish_fn_23+0x1e7>
			3d9b: R_X86_64_PLT32	rt_int_add-0x4
    3d9f:	mov    rdx,rax
    3da2:	mov    QWORD PTR [rsp+0x10],rax
    3da7:	mov    QWORD PTR [r13+0x0],rdx
    3dab:	mov    rax,QWORD PTR [r12+0x20]
    3db0:	mov    rsi,QWORD PTR [rax+0x18]
    3db4:	mov    QWORD PTR [r13+0x8],rsi
    3db8:	mov    rdx,QWORD PTR [rsp+0x10]
    3dbd:	mov    rdi,r15
    3dc0:	call   3dc5 <botlish_fn_23+0x20d>
			3dc1: R_X86_64_PLT32	botlish_fn_22-0x4 ; tld_ok<generic>
    3dc5:	test   rax,rax
    3dc8:	jne    3dfc <botlish_fn_23+0x244>
    3dce:	mov    rdi,r15
    3dd1:	mov    rdi,r15
    3dd4:	mov    QWORD PTR [rdi],r13
    3dd7:	xor    rax,rax
    3dda:	mov    rbx,QWORD PTR [rsp+0x20]
    3ddf:	mov    r12,QWORD PTR [rsp+0x28]
    3de4:	mov    r13,QWORD PTR [rsp+0x30]
    3de9:	mov    r14,QWORD PTR [rsp+0x38]
    3dee:	mov    r15,QWORD PTR [rsp+0x40]
    3df3:	add    rsp,0x50
    3df7:	mov    rsp,rbp
    3dfa:	pop    rbp
    3dfb:	ret
    3dfc:	cmp    rax,0x6
    3e00:	je     3e14 <botlish_fn_23+0x25c>
    3e06:	mov    rdx,QWORD PTR [rsp+0x10]
    3e0b:	mov    QWORD PTR [r13+0x0],rdx
    3e0f:	jmp    3c17 <botlish_fn_23+0x5f>
    3e14:	mov    rax,QWORD PTR [r12+0x20]
    3e19:	mov    rax,QWORD PTR [rax+0x8]
    3e1d:	jmp    3e29 <botlish_fn_23+0x271>
    3e22:	mov    rax,0xffffffffffffffff
    3e29:	mov    rdi,r15
    3e2c:	jmp    3e3b <botlish_fn_23+0x283>
    3e31:	mov    rax,0xffffffffffffffff
    3e38:	mov    rdi,r15
    3e3b:	mov    rdi,r15
    3e3e:	mov    QWORD PTR [rdi],r13
    3e41:	mov    rbx,QWORD PTR [rsp+0x20]
    3e46:	mov    r12,QWORD PTR [rsp+0x28]
    3e4b:	mov    r13,QWORD PTR [rsp+0x30]
    3e50:	mov    r14,QWORD PTR [rsp+0x38]
    3e55:	mov    r15,QWORD PTR [rsp+0x40]
    3e5a:	add    rsp,0x50
    3e5e:	mov    rsp,rbp
    3e61:	pop    rbp
    3e62:	ret
    3e63:	mov    r15,rdi
    3e66:	call   3e6b <botlish_fn_23+0x2b3>
			3e67: R_X86_64_PLT32	rt_stack_overflow-0x4
    3e6b:	xor    rax,rax
    3e6e:	mov    rbx,QWORD PTR [rsp+0x20]
    3e73:	mov    r12,QWORD PTR [rsp+0x28]
    3e78:	mov    r13,QWORD PTR [rsp+0x30]
    3e7d:	mov    r14,QWORD PTR [rsp+0x38]
    3e82:	mov    r15,QWORD PTR [rsp+0x40]
    3e87:	add    rsp,0x50
    3e8b:	mov    rsp,rbp
    3e8e:	pop    rbp
    3e8f:	ret
    3e90:	(bad)
    3e91:	add    BYTE PTR [rax],al
    3e93:	add    BYTE PTR [rax],al
    3e95:	add    BYTE PTR [rax],al
	...

0000000000003e98 <botlish_entry_23: domain_loop<generic>>:
    3e98:	push   rbp
    3e99:	mov    rbp,rsp
    3e9c:	mov    rdx,QWORD PTR [rdx]
    3e9f:	call   3ea4 <botlish_entry_23+0xc>
			3ea0: R_X86_64_PLT32	botlish_fn_23-0x4 ; domain_loop<generic>
    3ea4:	mov    rsp,rbp
    3ea7:	pop    rbp
    3ea8:	ret

0000000000003ea9 <botlish_fn_24: <str>>:
    3ea9:	push   rbp
    3eaa:	mov    rbp,rsp
    3ead:	sub    rsp,0x110
    3eb4:	mov    QWORD PTR [rsp+0xe0],rbx
    3ebc:	mov    QWORD PTR [rsp+0xe8],r12
    3ec4:	mov    QWORD PTR [rsp+0xf0],r13
    3ecc:	mov    QWORD PTR [rsp+0xf8],r14
    3ed4:	mov    QWORD PTR [rsp+0x100],r15
    3edc:	mov    r12,QWORD PTR [rdi]
    3edf:	mov    r8,QWORD PTR [rdi+0x8]
    3ee3:	lea    r9,[r12+0x88]
    3eeb:	cmp    r9,r8
    3eee:	ja     431b <botlish_fn_24+0x472>
    3ef4:	lea    r8,[r12+0x88]
    3efc:	mov    QWORD PTR [rdi],r8
    3eff:	mov    QWORD PTR [r12],0x0
    3f07:	mov    QWORD PTR [r12+0x8],0x0
    3f10:	mov    QWORD PTR [r12+0x10],0x0
    3f19:	mov    QWORD PTR [r12+0x18],0x0
    3f22:	mov    QWORD PTR [r12+0x20],0x0
    3f2b:	mov    QWORD PTR [r12+0x28],0x0
    3f34:	mov    QWORD PTR [r12+0x30],0x0
    3f3d:	mov    QWORD PTR [r12+0x38],0x0
    3f46:	mov    QWORD PTR [r12+0x40],0x0
    3f4f:	mov    QWORD PTR [r12+0x48],0x0
    3f58:	mov    QWORD PTR [r12+0x50],0x0
    3f61:	mov    QWORD PTR [r12+0x58],0x0
    3f6a:	mov    QWORD PTR [r12+0x60],0x0
    3f73:	mov    QWORD PTR [r12+0x68],0x0
    3f7c:	mov    QWORD PTR [r12+0x70],0x0
    3f85:	mov    QWORD PTR [r12+0x78],0x0
    3f8e:	mov    QWORD PTR [r12+0x80],0x0
    3f9a:	mov    QWORD PTR [r12],rsi
    3f9e:	mov    QWORD PTR [rsp+0xa8],rsi
    3fa6:	mov    rax,QWORD PTR [rdi+0x10]
    3faa:	mov    rdx,QWORD PTR [rax+0x88]
    3fb1:	mov    QWORD PTR [r12+0x8],rdx
    3fb6:	mov    QWORD PTR [rsp+0xd0],rdx
    3fbe:	mov    rax,QWORD PTR [rdi+0x10]
    3fc2:	mov    rsi,QWORD PTR [rax+0x90]
    3fc9:	mov    QWORD PTR [r12+0x10],rsi
    3fce:	mov    QWORD PTR [rsp+0xc8],rsi
    3fd6:	mov    rax,QWORD PTR [rdi+0x10]
    3fda:	mov    r8,QWORD PTR [rax+0x98]
    3fe1:	mov    QWORD PTR [r12+0x18],r8
    3fe6:	mov    QWORD PTR [rsp+0xc0],r8
    3fee:	mov    rax,QWORD PTR [rdi+0x10]
    3ff2:	mov    r9,QWORD PTR [rax+0xa0]
    3ff9:	mov    QWORD PTR [r12+0x20],r9
    3ffe:	mov    QWORD PTR [rsp+0xb8],r9
    4006:	mov    rax,QWORD PTR [rdi+0x10]
    400a:	mov    r10,QWORD PTR [rax+0xa8]
    4011:	mov    QWORD PTR [r12+0x28],r10
    4016:	mov    QWORD PTR [rsp+0xb0],r10
    401e:	mov    rax,QWORD PTR [rdi+0x10]
    4022:	mov    r10,QWORD PTR [rax+0xb0]
    4029:	mov    QWORD PTR [r12+0x30],r10
    402e:	mov    rax,QWORD PTR [rdi+0x10]
    4032:	mov    r11,QWORD PTR [rax+0xb8]
    4039:	mov    QWORD PTR [r12+0x38],r11
    403e:	mov    rax,QWORD PTR [rdi+0x10]
    4042:	mov    rbx,QWORD PTR [rax+0xc0]
    4049:	mov    QWORD PTR [r12+0x40],rbx
    404e:	mov    rax,QWORD PTR [rdi+0x10]
    4052:	mov    rax,QWORD PTR [rax+0xc8]
    4059:	mov    QWORD PTR [r12+0x48],rax
    405e:	mov    rcx,QWORD PTR [rdi+0x10]
    4062:	mov    r13,QWORD PTR [rcx+0xd0]
    4069:	mov    QWORD PTR [r12+0x50],r13
    406e:	mov    rcx,QWORD PTR [rdi+0x10]
    4072:	mov    r14,QWORD PTR [rcx+0xd8]
    4079:	mov    QWORD PTR [r12+0x58],r14
    407e:	mov    rcx,QWORD PTR [rdi+0x10]
    4082:	mov    r15,QWORD PTR [rcx+0xe0]
    4089:	mov    QWORD PTR [r12+0x60],r15
    408e:	mov    rcx,QWORD PTR [rdi+0x10]
    4092:	mov    rcx,QWORD PTR [rcx+0xe8]
    4099:	mov    QWORD PTR [r12+0x68],rcx
    409e:	mov    rdx,QWORD PTR [rdi+0x10]
    40a2:	mov    rdx,QWORD PTR [rdx+0xf0]
    40a9:	mov    QWORD PTR [r12+0x70],rdx
    40ae:	mov    rsi,QWORD PTR [rdi+0x10]
    40b2:	mov    rsi,QWORD PTR [rsi+0xf8]
    40b9:	mov    QWORD PTR [r12+0x78],rsi
    40be:	mov    r8,QWORD PTR [rdi+0x10]
    40c2:	mov    QWORD PTR [rsp+0xa0],rdi
    40ca:	mov    rdi,QWORD PTR [r8+0x100]
    40d1:	mov    QWORD PTR [r12+0x80],rdi
    40d9:	lea    r8,[rsp]
    40dd:	mov    r9,QWORD PTR [rsp+0xd0]
    40e5:	mov    QWORD PTR [rsp],r9
    40e9:	mov    r9,QWORD PTR [rsp+0xc8]
    40f1:	mov    QWORD PTR [rsp+0x8],r9
    40f6:	mov    r9,QWORD PTR [rsp+0xc0]
    40fe:	mov    QWORD PTR [rsp+0x10],r9
    4103:	mov    r9,QWORD PTR [rsp+0xb8]
    410b:	mov    QWORD PTR [rsp+0x18],r9
    4110:	mov    r9,QWORD PTR [rsp+0xb0]
    4118:	mov    QWORD PTR [rsp+0x20],r9
    411d:	mov    QWORD PTR [rsp+0x28],r10
    4122:	mov    QWORD PTR [rsp+0x30],r11
    4127:	mov    QWORD PTR [rsp+0x38],rbx
    412c:	mov    QWORD PTR [rsp+0x40],rax
    4131:	mov    QWORD PTR [rsp+0x48],r13
    4136:	mov    QWORD PTR [rsp+0x50],r14
    413b:	mov    QWORD PTR [rsp+0x58],r15
    4140:	mov    QWORD PTR [rsp+0x60],rcx
    4145:	mov    QWORD PTR [rsp+0x68],rdx
    414a:	mov    QWORD PTR [rsp+0x70],rsi
    414f:	mov    QWORD PTR [rsp+0x78],rdi
    4154:	mov    esi,0x10
    4159:	mov    rdx,r8
    415c:	mov    rdi,QWORD PTR [rsp+0xa0]
    4164:	call   4169 <botlish_fn_24+0x2c0>
			4165: R_X86_64_PLT32	rt_list_new-0x4
    4169:	test   rax,rax
    416c:	jne    417f <botlish_fn_24+0x2d6>
    4172:	mov    rdi,QWORD PTR [rsp+0xa0]
    417a:	jmp    429a <botlish_fn_24+0x3f1>
    417f:	mov    QWORD PTR [r12+0x8],rax
    4184:	lea    r8,[rsp+0x80]
    418c:	mov    QWORD PTR [rsp+0x80],rax
    4194:	mov    esi,0x1c
    4199:	mov    rdx,QWORD PTR [rip+0x0]        # 41a0 <botlish_fn_24+0x2f7>
			419c: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; hex_pair<generic>
    41a0:	mov    ebx,0x1
    41a5:	mov    rcx,rbx
    41a8:	mov    rdi,QWORD PTR [rsp+0xa0]
    41b0:	call   41b5 <botlish_fn_24+0x30c>
			41b1: R_X86_64_PLT32	rt_closure_new-0x4
    41b5:	mov    QWORD PTR [r12+0x8],rax
    41ba:	lea    r8,[rsp+0x88]
    41c2:	mov    QWORD PTR [rsp+0x88],rax
    41ca:	mov    esi,0x1d
    41cf:	mov    rdx,QWORD PTR [rip+0x0]        # 41d6 <botlish_fn_24+0x32d>
			41d2: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; esc_bytes<generic>
    41d6:	mov    rcx,rbx
    41d9:	mov    rdi,QWORD PTR [rsp+0xa0]
    41e1:	call   41e6 <botlish_fn_24+0x33d>
			41e2: R_X86_64_PLT32	rt_closure_new-0x4
    41e6:	mov    QWORD PTR [r12+0x8],rax
    41eb:	lea    r8,[rsp+0x90]
    41f3:	mov    QWORD PTR [rsp+0x90],rax
    41fb:	mov    esi,0x1e
    4200:	mov    rdx,QWORD PTR [rip+0x0]        # 4207 <botlish_fn_24+0x35e>
			4203: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; esc_char<generic>
    4207:	mov    rcx,rbx
    420a:	mov    rdi,QWORD PTR [rsp+0xa0]
    4212:	call   4217 <botlish_fn_24+0x36e>
			4213: R_X86_64_PLT32	rt_closure_new-0x4
    4217:	mov    QWORD PTR [r12+0x8],rax
    421c:	lea    r8,[rsp+0x98]
    4224:	mov    QWORD PTR [rsp+0x98],rax
    422c:	mov    esi,0x1f
    4231:	mov    rdx,QWORD PTR [rip+0x0]        # 4238 <botlish_fn_24+0x38f>
			4234: R_X86_64_GOTPCREL	botlish_entry_31-0x4 ; esc_from<generic>
    4238:	mov    rcx,rbx
    423b:	mov    rdi,QWORD PTR [rsp+0xa0]
    4243:	call   4248 <botlish_fn_24+0x39f>
			4244: R_X86_64_PLT32	rt_closure_new-0x4
    4248:	mov    QWORD PTR [r12+0x8],rax
    424d:	mov    QWORD PTR [r12+0x10],0x1
    4256:	mov    rdi,QWORD PTR [rsp+0xa0]
    425e:	mov    rdi,QWORD PTR [rdi+0x10]
    4262:	mov    r8,QWORD PTR [rdi+0x108]
    4269:	mov    QWORD PTR [r12+0x18],r8
    426e:	mov    rcx,rbx
    4271:	mov    rdx,QWORD PTR [rsp+0xa8]
    4279:	mov    rsi,rax
    427c:	mov    rdi,QWORD PTR [rsp+0xa0]
    4284:	call   4289 <botlish_fn_24+0x3e0>
			4285: R_X86_64_PLT32	botlish_fn_31-0x4 ; esc_from<generic>
    4289:	test   rax,rax
    428c:	jne    42dc <botlish_fn_24+0x433>
    4292:	mov    rdi,QWORD PTR [rsp+0xa0]
    429a:	mov    rdi,QWORD PTR [rsp+0xa0]
    42a2:	mov    QWORD PTR [rdi],r12
    42a5:	xor    rax,rax
    42a8:	mov    rbx,QWORD PTR [rsp+0xe0]
    42b0:	mov    r12,QWORD PTR [rsp+0xe8]
    42b8:	mov    r13,QWORD PTR [rsp+0xf0]
    42c0:	mov    r14,QWORD PTR [rsp+0xf8]
    42c8:	mov    r15,QWORD PTR [rsp+0x100]
    42d0:	add    rsp,0x110
    42d7:	mov    rsp,rbp
    42da:	pop    rbp
    42db:	ret
    42dc:	mov    rdi,QWORD PTR [rsp+0xa0]
    42e4:	mov    QWORD PTR [rdi],r12
    42e7:	mov    rbx,QWORD PTR [rsp+0xe0]
    42ef:	mov    r12,QWORD PTR [rsp+0xe8]
    42f7:	mov    r13,QWORD PTR [rsp+0xf0]
    42ff:	mov    r14,QWORD PTR [rsp+0xf8]
    4307:	mov    r15,QWORD PTR [rsp+0x100]
    430f:	add    rsp,0x110
    4316:	mov    rsp,rbp
    4319:	pop    rbp
    431a:	ret
    431b:	mov    QWORD PTR [rsp+0xa0],rdi
    4323:	call   4328 <botlish_fn_24+0x47f>
			4324: R_X86_64_PLT32	rt_stack_overflow-0x4
    4328:	xor    rax,rax
    432b:	mov    rbx,QWORD PTR [rsp+0xe0]
    4333:	mov    r12,QWORD PTR [rsp+0xe8]
    433b:	mov    r13,QWORD PTR [rsp+0xf0]
    4343:	mov    r14,QWORD PTR [rsp+0xf8]
    434b:	mov    r15,QWORD PTR [rsp+0x100]
    4353:	add    rsp,0x110
    435a:	mov    rsp,rbp
    435d:	pop    rbp
    435e:	ret

000000000000435f <botlish_entry_24: <str>>:
    435f:	push   rbp
    4360:	mov    rbp,rsp
    4363:	mov    rsi,QWORD PTR [rdx]
    4366:	call   436b <botlish_entry_24+0xc>
			4367: R_X86_64_PLT32	botlish_fn_24-0x4 ; <str>
    436b:	mov    rsp,rbp
    436e:	pop    rbp
    436f:	ret

0000000000004370 <botlish_fn_25: <generic>>:
    4370:	push   rbp
    4371:	mov    rbp,rsp
    4374:	sub    rsp,0x110
    437b:	mov    QWORD PTR [rsp+0xe0],rbx
    4383:	mov    QWORD PTR [rsp+0xe8],r12
    438b:	mov    QWORD PTR [rsp+0xf0],r13
    4393:	mov    QWORD PTR [rsp+0xf8],r14
    439b:	mov    QWORD PTR [rsp+0x100],r15
    43a3:	mov    r12,QWORD PTR [rdi]
    43a6:	mov    r8,QWORD PTR [rdi+0x8]
    43aa:	lea    r9,[r12+0x88]
    43b2:	cmp    r9,r8
    43b5:	ja     47e2 <botlish_fn_25+0x472>
    43bb:	lea    r8,[r12+0x88]
    43c3:	mov    QWORD PTR [rdi],r8
    43c6:	mov    QWORD PTR [r12],0x0
    43ce:	mov    QWORD PTR [r12+0x8],0x0
    43d7:	mov    QWORD PTR [r12+0x10],0x0
    43e0:	mov    QWORD PTR [r12+0x18],0x0
    43e9:	mov    QWORD PTR [r12+0x20],0x0
    43f2:	mov    QWORD PTR [r12+0x28],0x0
    43fb:	mov    QWORD PTR [r12+0x30],0x0
    4404:	mov    QWORD PTR [r12+0x38],0x0
    440d:	mov    QWORD PTR [r12+0x40],0x0
    4416:	mov    QWORD PTR [r12+0x48],0x0
    441f:	mov    QWORD PTR [r12+0x50],0x0
    4428:	mov    QWORD PTR [r12+0x58],0x0
    4431:	mov    QWORD PTR [r12+0x60],0x0
    443a:	mov    QWORD PTR [r12+0x68],0x0
    4443:	mov    QWORD PTR [r12+0x70],0x0
    444c:	mov    QWORD PTR [r12+0x78],0x0
    4455:	mov    QWORD PTR [r12+0x80],0x0
    4461:	mov    QWORD PTR [r12],rsi
    4465:	mov    QWORD PTR [rsp+0xa8],rsi
    446d:	mov    rax,QWORD PTR [rdi+0x10]
    4471:	mov    rdx,QWORD PTR [rax+0x88]
    4478:	mov    QWORD PTR [r12+0x8],rdx
    447d:	mov    QWORD PTR [rsp+0xd0],rdx
    4485:	mov    rax,QWORD PTR [rdi+0x10]
    4489:	mov    rsi,QWORD PTR [rax+0x90]
    4490:	mov    QWORD PTR [r12+0x10],rsi
    4495:	mov    QWORD PTR [rsp+0xc8],rsi
    449d:	mov    rax,QWORD PTR [rdi+0x10]
    44a1:	mov    r8,QWORD PTR [rax+0x98]
    44a8:	mov    QWORD PTR [r12+0x18],r8
    44ad:	mov    QWORD PTR [rsp+0xc0],r8
    44b5:	mov    rax,QWORD PTR [rdi+0x10]
    44b9:	mov    r9,QWORD PTR [rax+0xa0]
    44c0:	mov    QWORD PTR [r12+0x20],r9
    44c5:	mov    QWORD PTR [rsp+0xb8],r9
    44cd:	mov    rax,QWORD PTR [rdi+0x10]
    44d1:	mov    r10,QWORD PTR [rax+0xa8]
    44d8:	mov    QWORD PTR [r12+0x28],r10
    44dd:	mov    QWORD PTR [rsp+0xb0],r10
    44e5:	mov    rax,QWORD PTR [rdi+0x10]
    44e9:	mov    r10,QWORD PTR [rax+0xb0]
    44f0:	mov    QWORD PTR [r12+0x30],r10
    44f5:	mov    rax,QWORD PTR [rdi+0x10]
    44f9:	mov    r11,QWORD PTR [rax+0xb8]
    4500:	mov    QWORD PTR [r12+0x38],r11
    4505:	mov    rax,QWORD PTR [rdi+0x10]
    4509:	mov    rbx,QWORD PTR [rax+0xc0]
    4510:	mov    QWORD PTR [r12+0x40],rbx
    4515:	mov    rax,QWORD PTR [rdi+0x10]
    4519:	mov    rax,QWORD PTR [rax+0xc8]
    4520:	mov    QWORD PTR [r12+0x48],rax
    4525:	mov    rcx,QWORD PTR [rdi+0x10]
    4529:	mov    r13,QWORD PTR [rcx+0xd0]
    4530:	mov    QWORD PTR [r12+0x50],r13
    4535:	mov    rcx,QWORD PTR [rdi+0x10]
    4539:	mov    r14,QWORD PTR [rcx+0xd8]
    4540:	mov    QWORD PTR [r12+0x58],r14
    4545:	mov    rcx,QWORD PTR [rdi+0x10]
    4549:	mov    r15,QWORD PTR [rcx+0xe0]
    4550:	mov    QWORD PTR [r12+0x60],r15
    4555:	mov    rcx,QWORD PTR [rdi+0x10]
    4559:	mov    rcx,QWORD PTR [rcx+0xe8]
    4560:	mov    QWORD PTR [r12+0x68],rcx
    4565:	mov    rdx,QWORD PTR [rdi+0x10]
    4569:	mov    rdx,QWORD PTR [rdx+0xf0]
    4570:	mov    QWORD PTR [r12+0x70],rdx
    4575:	mov    rsi,QWORD PTR [rdi+0x10]
    4579:	mov    rsi,QWORD PTR [rsi+0xf8]
    4580:	mov    QWORD PTR [r12+0x78],rsi
    4585:	mov    r8,QWORD PTR [rdi+0x10]
    4589:	mov    QWORD PTR [rsp+0xa0],rdi
    4591:	mov    rdi,QWORD PTR [r8+0x100]
    4598:	mov    QWORD PTR [r12+0x80],rdi
    45a0:	lea    r8,[rsp]
    45a4:	mov    r9,QWORD PTR [rsp+0xd0]
    45ac:	mov    QWORD PTR [rsp],r9
    45b0:	mov    r9,QWORD PTR [rsp+0xc8]
    45b8:	mov    QWORD PTR [rsp+0x8],r9
    45bd:	mov    r9,QWORD PTR [rsp+0xc0]
    45c5:	mov    QWORD PTR [rsp+0x10],r9
    45ca:	mov    r9,QWORD PTR [rsp+0xb8]
    45d2:	mov    QWORD PTR [rsp+0x18],r9
    45d7:	mov    r9,QWORD PTR [rsp+0xb0]
    45df:	mov    QWORD PTR [rsp+0x20],r9
    45e4:	mov    QWORD PTR [rsp+0x28],r10
    45e9:	mov    QWORD PTR [rsp+0x30],r11
    45ee:	mov    QWORD PTR [rsp+0x38],rbx
    45f3:	mov    QWORD PTR [rsp+0x40],rax
    45f8:	mov    QWORD PTR [rsp+0x48],r13
    45fd:	mov    QWORD PTR [rsp+0x50],r14
    4602:	mov    QWORD PTR [rsp+0x58],r15
    4607:	mov    QWORD PTR [rsp+0x60],rcx
    460c:	mov    QWORD PTR [rsp+0x68],rdx
    4611:	mov    QWORD PTR [rsp+0x70],rsi
    4616:	mov    QWORD PTR [rsp+0x78],rdi
    461b:	mov    esi,0x10
    4620:	mov    rdx,r8
    4623:	mov    rdi,QWORD PTR [rsp+0xa0]
    462b:	call   4630 <botlish_fn_25+0x2c0>
			462c: R_X86_64_PLT32	rt_list_new-0x4
    4630:	test   rax,rax
    4633:	jne    4646 <botlish_fn_25+0x2d6>
    4639:	mov    rdi,QWORD PTR [rsp+0xa0]
    4641:	jmp    4761 <botlish_fn_25+0x3f1>
    4646:	mov    QWORD PTR [r12+0x8],rax
    464b:	lea    r8,[rsp+0x80]
    4653:	mov    QWORD PTR [rsp+0x80],rax
    465b:	mov    esi,0x1c
    4660:	mov    rdx,QWORD PTR [rip+0x0]        # 4667 <botlish_fn_25+0x2f7>
			4663: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; hex_pair<generic>
    4667:	mov    ebx,0x1
    466c:	mov    rcx,rbx
    466f:	mov    rdi,QWORD PTR [rsp+0xa0]
    4677:	call   467c <botlish_fn_25+0x30c>
			4678: R_X86_64_PLT32	rt_closure_new-0x4
    467c:	mov    QWORD PTR [r12+0x8],rax
    4681:	lea    r8,[rsp+0x88]
    4689:	mov    QWORD PTR [rsp+0x88],rax
    4691:	mov    esi,0x1d
    4696:	mov    rdx,QWORD PTR [rip+0x0]        # 469d <botlish_fn_25+0x32d>
			4699: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; esc_bytes<generic>
    469d:	mov    rcx,rbx
    46a0:	mov    rdi,QWORD PTR [rsp+0xa0]
    46a8:	call   46ad <botlish_fn_25+0x33d>
			46a9: R_X86_64_PLT32	rt_closure_new-0x4
    46ad:	mov    QWORD PTR [r12+0x8],rax
    46b2:	lea    r8,[rsp+0x90]
    46ba:	mov    QWORD PTR [rsp+0x90],rax
    46c2:	mov    esi,0x1e
    46c7:	mov    rdx,QWORD PTR [rip+0x0]        # 46ce <botlish_fn_25+0x35e>
			46ca: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; esc_char<generic>
    46ce:	mov    rcx,rbx
    46d1:	mov    rdi,QWORD PTR [rsp+0xa0]
    46d9:	call   46de <botlish_fn_25+0x36e>
			46da: R_X86_64_PLT32	rt_closure_new-0x4
    46de:	mov    QWORD PTR [r12+0x8],rax
    46e3:	lea    r8,[rsp+0x98]
    46eb:	mov    QWORD PTR [rsp+0x98],rax
    46f3:	mov    esi,0x1f
    46f8:	mov    rdx,QWORD PTR [rip+0x0]        # 46ff <botlish_fn_25+0x38f>
			46fb: R_X86_64_GOTPCREL	botlish_entry_31-0x4 ; esc_from<generic>
    46ff:	mov    rcx,rbx
    4702:	mov    rdi,QWORD PTR [rsp+0xa0]
    470a:	call   470f <botlish_fn_25+0x39f>
			470b: R_X86_64_PLT32	rt_closure_new-0x4
    470f:	mov    QWORD PTR [r12+0x8],rax
    4714:	mov    QWORD PTR [r12+0x10],0x1
    471d:	mov    rdi,QWORD PTR [rsp+0xa0]
    4725:	mov    rdi,QWORD PTR [rdi+0x10]
    4729:	mov    r8,QWORD PTR [rdi+0x108]
    4730:	mov    QWORD PTR [r12+0x18],r8
    4735:	mov    rcx,rbx
    4738:	mov    rdx,QWORD PTR [rsp+0xa8]
    4740:	mov    rsi,rax
    4743:	mov    rdi,QWORD PTR [rsp+0xa0]
    474b:	call   4750 <botlish_fn_25+0x3e0>
			474c: R_X86_64_PLT32	botlish_fn_31-0x4 ; esc_from<generic>
    4750:	test   rax,rax
    4753:	jne    47a3 <botlish_fn_25+0x433>
    4759:	mov    rdi,QWORD PTR [rsp+0xa0]
    4761:	mov    rdi,QWORD PTR [rsp+0xa0]
    4769:	mov    QWORD PTR [rdi],r12
    476c:	xor    rax,rax
    476f:	mov    rbx,QWORD PTR [rsp+0xe0]
    4777:	mov    r12,QWORD PTR [rsp+0xe8]
    477f:	mov    r13,QWORD PTR [rsp+0xf0]
    4787:	mov    r14,QWORD PTR [rsp+0xf8]
    478f:	mov    r15,QWORD PTR [rsp+0x100]
    4797:	add    rsp,0x110
    479e:	mov    rsp,rbp
    47a1:	pop    rbp
    47a2:	ret
    47a3:	mov    rdi,QWORD PTR [rsp+0xa0]
    47ab:	mov    QWORD PTR [rdi],r12
    47ae:	mov    rbx,QWORD PTR [rsp+0xe0]
    47b6:	mov    r12,QWORD PTR [rsp+0xe8]
    47be:	mov    r13,QWORD PTR [rsp+0xf0]
    47c6:	mov    r14,QWORD PTR [rsp+0xf8]
    47ce:	mov    r15,QWORD PTR [rsp+0x100]
    47d6:	add    rsp,0x110
    47dd:	mov    rsp,rbp
    47e0:	pop    rbp
    47e1:	ret
    47e2:	mov    QWORD PTR [rsp+0xa0],rdi
    47ea:	call   47ef <botlish_fn_25+0x47f>
			47eb: R_X86_64_PLT32	rt_stack_overflow-0x4
    47ef:	xor    rax,rax
    47f2:	mov    rbx,QWORD PTR [rsp+0xe0]
    47fa:	mov    r12,QWORD PTR [rsp+0xe8]
    4802:	mov    r13,QWORD PTR [rsp+0xf0]
    480a:	mov    r14,QWORD PTR [rsp+0xf8]
    4812:	mov    r15,QWORD PTR [rsp+0x100]
    481a:	add    rsp,0x110
    4821:	mov    rsp,rbp
    4824:	pop    rbp
    4825:	ret

0000000000004826 <botlish_entry_25: <generic>>:
    4826:	push   rbp
    4827:	mov    rbp,rsp
    482a:	mov    rsi,QWORD PTR [rdx]
    482d:	call   4832 <botlish_entry_25+0xc>
			482e: R_X86_64_PLT32	botlish_fn_25-0x4 ; <generic>
    4832:	mov    rsp,rbp
    4835:	pop    rbp
    4836:	ret
	...

0000000000004838 <botlish_fn_26: high_nibble<generic>>:
    4838:	push   rbp
    4839:	mov    rbp,rsp
    483c:	sub    rsp,0x20
    4840:	mov    QWORD PTR [rsp],rbx
    4844:	mov    QWORD PTR [rsp+0x8],r12
    4849:	mov    QWORD PTR [rsp+0x10],r13
    484e:	mov    rbx,QWORD PTR [rdi]
    4851:	mov    rax,QWORD PTR [rdi+0x8]
    4855:	lea    rcx,[rbx+0x8]
    4859:	cmp    rcx,rax
    485c:	ja     4e97 <botlish_fn_26+0x65f>
    4862:	lea    rax,[rbx+0x8]
    4866:	mov    QWORD PTR [rdi],rax
    4869:	mov    QWORD PTR [rbx],0x0
    4870:	mov    eax,0x1
    4875:	test   rsi,0x1
    487c:	jne    489a <botlish_fn_26+0x62>
    4882:	xor    eax,eax
    4884:	test   rsi,0x7
    488b:	jne    489a <botlish_fn_26+0x62>
    4891:	movzx  rax,BYTE PTR [rsi]
    4895:	cmp    al,0x1
    4897:	sete   al
    489a:	test   al,al
    489c:	jne    48d8 <botlish_fn_26+0xa0>
    48a2:	mov    rax,QWORD PTR [rdi+0x10]
    48a6:	mov    r12,rdi
    48a9:	mov    rcx,QWORD PTR [rax+0x110]
    48b0:	xor    rdx,rdx
    48b3:	call   48b8 <botlish_fn_26+0x80>
			48b4: R_X86_64_PLT32	rt_type_error-0x4
    48b8:	mov    rdi,r12
    48bb:	mov    QWORD PTR [rdi],rbx
    48be:	xor    rax,rax
    48c1:	mov    rbx,QWORD PTR [rsp]
    48c5:	mov    r12,QWORD PTR [rsp+0x8]
    48ca:	mov    r13,QWORD PTR [rsp+0x10]
    48cf:	add    rsp,0x20
    48d3:	mov    rsp,rbp
    48d6:	pop    rbp
    48d7:	ret
    48d8:	mov    r12,rdi
    48db:	test   rsi,0x1
    48e2:	mov    r13,rsi
    48e5:	jne    4910 <botlish_fn_26+0xd8>
    48eb:	mov    edx,0x1f
    48f0:	mov    rsi,r13
    48f3:	mov    rdi,r12
    48f6:	call   48fb <botlish_fn_26+0xc3>
			48f7: R_X86_64_PLT32	rt_int_cmp-0x4
    48fb:	mov    ecx,0x2
    4900:	test   rax,rax
    4903:	cmovle rcx,QWORD PTR [rip+0x5b5]        # 4ec0 <botlish_fn_26+0x688>
    490b:	jmp    4924 <botlish_fn_26+0xec>
    4910:	mov    ecx,0x2
    4915:	mov    rsi,r13
    4918:	cmp    rsi,0x1f
    491c:	cmovle rcx,QWORD PTR [rip+0x59c]        # 4ec0 <botlish_fn_26+0x688>
    4924:	cmp    rcx,0x6
    4928:	je     4e72 <botlish_fn_26+0x63a>
    492e:	mov    rsi,r13
    4931:	test   rsi,0x1
    4938:	jne    4963 <botlish_fn_26+0x12b>
    493e:	mov    edx,0x3f
    4943:	mov    rsi,r13
    4946:	mov    rdi,r12
    4949:	call   494e <botlish_fn_26+0x116>
			494a: R_X86_64_PLT32	rt_int_cmp-0x4
    494e:	mov    ecx,0x2
    4953:	test   rax,rax
    4956:	cmovle rcx,QWORD PTR [rip+0x562]        # 4ec0 <botlish_fn_26+0x688>
    495e:	jmp    4977 <botlish_fn_26+0x13f>
    4963:	mov    ecx,0x2
    4968:	mov    rsi,r13
    496b:	cmp    rsi,0x3f
    496f:	cmovle rcx,QWORD PTR [rip+0x549]        # 4ec0 <botlish_fn_26+0x688>
    4977:	cmp    rcx,0x6
    497b:	je     4e65 <botlish_fn_26+0x62d>
    4981:	mov    rsi,r13
    4984:	test   rsi,0x1
    498b:	jne    49b7 <botlish_fn_26+0x17f>
    4991:	mov    edx,0x5f
    4996:	mov    rsi,r13
    4999:	mov    rdi,r12
    499c:	call   49a1 <botlish_fn_26+0x169>
			499d: R_X86_64_PLT32	rt_int_cmp-0x4
    49a1:	mov    r9d,0x2
    49a7:	test   rax,rax
    49aa:	cmovle r9,QWORD PTR [rip+0x50e]        # 4ec0 <botlish_fn_26+0x688>
    49b2:	jmp    49cc <botlish_fn_26+0x194>
    49b7:	mov    r9d,0x2
    49bd:	mov    rsi,r13
    49c0:	cmp    rsi,0x5f
    49c4:	cmovle r9,QWORD PTR [rip+0x4f4]        # 4ec0 <botlish_fn_26+0x688>
    49cc:	cmp    r9,0x6
    49d0:	je     4e5b <botlish_fn_26+0x623>
    49d6:	mov    rsi,r13
    49d9:	test   rsi,0x1
    49e0:	jne    4a0b <botlish_fn_26+0x1d3>
    49e6:	mov    edx,0x7f
    49eb:	mov    rsi,r13
    49ee:	mov    rdi,r12
    49f1:	call   49f6 <botlish_fn_26+0x1be>
			49f2: R_X86_64_PLT32	rt_int_cmp-0x4
    49f6:	mov    ecx,0x2
    49fb:	test   rax,rax
    49fe:	cmovle rcx,QWORD PTR [rip+0x4ba]        # 4ec0 <botlish_fn_26+0x688>
    4a06:	jmp    4a1f <botlish_fn_26+0x1e7>
    4a0b:	mov    ecx,0x2
    4a10:	mov    rsi,r13
    4a13:	cmp    rsi,0x7f
    4a17:	cmovle rcx,QWORD PTR [rip+0x4a1]        # 4ec0 <botlish_fn_26+0x688>
    4a1f:	cmp    rcx,0x6
    4a23:	je     4e51 <botlish_fn_26+0x619>
    4a29:	mov    rsi,r13
    4a2c:	test   rsi,0x1
    4a33:	jne    4a5e <botlish_fn_26+0x226>
    4a39:	mov    edx,0x9f
    4a3e:	mov    rsi,r13
    4a41:	mov    rdi,r12
    4a44:	call   4a49 <botlish_fn_26+0x211>
			4a45: R_X86_64_PLT32	rt_int_cmp-0x4
    4a49:	mov    ecx,0x2
    4a4e:	test   rax,rax
    4a51:	cmovle rcx,QWORD PTR [rip+0x467]        # 4ec0 <botlish_fn_26+0x688>
    4a59:	jmp    4a75 <botlish_fn_26+0x23d>
    4a5e:	mov    ecx,0x2
    4a63:	mov    rsi,r13
    4a66:	cmp    rsi,0x9f
    4a6d:	cmovle rcx,QWORD PTR [rip+0x44b]        # 4ec0 <botlish_fn_26+0x688>
    4a75:	cmp    rcx,0x6
    4a79:	je     4e47 <botlish_fn_26+0x60f>
    4a7f:	mov    rsi,r13
    4a82:	test   rsi,0x1
    4a89:	jne    4ab4 <botlish_fn_26+0x27c>
    4a8f:	mov    edx,0xbf
    4a94:	mov    rsi,r13
    4a97:	mov    rdi,r12
    4a9a:	call   4a9f <botlish_fn_26+0x267>
			4a9b: R_X86_64_PLT32	rt_int_cmp-0x4
    4a9f:	mov    ecx,0x2
    4aa4:	test   rax,rax
    4aa7:	cmovle rcx,QWORD PTR [rip+0x411]        # 4ec0 <botlish_fn_26+0x688>
    4aaf:	jmp    4acb <botlish_fn_26+0x293>
    4ab4:	mov    ecx,0x2
    4ab9:	mov    rsi,r13
    4abc:	cmp    rsi,0xbf
    4ac3:	cmovle rcx,QWORD PTR [rip+0x3f5]        # 4ec0 <botlish_fn_26+0x688>
    4acb:	cmp    rcx,0x6
    4acf:	je     4e3d <botlish_fn_26+0x605>
    4ad5:	mov    rsi,r13
    4ad8:	test   rsi,0x1
    4adf:	jne    4b0a <botlish_fn_26+0x2d2>
    4ae5:	mov    edx,0xdf
    4aea:	mov    rsi,r13
    4aed:	mov    rdi,r12
    4af0:	call   4af5 <botlish_fn_26+0x2bd>
			4af1: R_X86_64_PLT32	rt_int_cmp-0x4
    4af5:	mov    esi,0x2
    4afa:	test   rax,rax
    4afd:	cmovle rsi,QWORD PTR [rip+0x3bb]        # 4ec0 <botlish_fn_26+0x688>
    4b05:	jmp    4b20 <botlish_fn_26+0x2e8>
    4b0a:	mov    esi,0x2
    4b0f:	mov    rax,r13
    4b12:	cmp    rax,0xdf
    4b18:	cmovle rsi,QWORD PTR [rip+0x3a0]        # 4ec0 <botlish_fn_26+0x688>
    4b20:	cmp    rsi,0x6
    4b24:	je     4e33 <botlish_fn_26+0x5fb>
    4b2a:	mov    rsi,r13
    4b2d:	test   rsi,0x1
    4b34:	jne    4b5f <botlish_fn_26+0x327>
    4b3a:	mov    edx,0xff
    4b3f:	mov    rsi,r13
    4b42:	mov    rdi,r12
    4b45:	call   4b4a <botlish_fn_26+0x312>
			4b46: R_X86_64_PLT32	rt_int_cmp-0x4
    4b4a:	mov    ecx,0x2
    4b4f:	test   rax,rax
    4b52:	cmovle rcx,QWORD PTR [rip+0x366]        # 4ec0 <botlish_fn_26+0x688>
    4b5a:	jmp    4b76 <botlish_fn_26+0x33e>
    4b5f:	mov    ecx,0x2
    4b64:	mov    rsi,r13
    4b67:	cmp    rsi,0xff
    4b6e:	cmovle rcx,QWORD PTR [rip+0x34a]        # 4ec0 <botlish_fn_26+0x688>
    4b76:	cmp    rcx,0x6
    4b7a:	je     4e29 <botlish_fn_26+0x5f1>
    4b80:	mov    rsi,r13
    4b83:	test   rsi,0x1
    4b8a:	jne    4bb5 <botlish_fn_26+0x37d>
    4b90:	mov    edx,0x11f
    4b95:	mov    rsi,r13
    4b98:	mov    rdi,r12
    4b9b:	call   4ba0 <botlish_fn_26+0x368>
			4b9c: R_X86_64_PLT32	rt_int_cmp-0x4
    4ba0:	mov    ecx,0x2
    4ba5:	test   rax,rax
    4ba8:	cmovle rcx,QWORD PTR [rip+0x310]        # 4ec0 <botlish_fn_26+0x688>
    4bb0:	jmp    4bcc <botlish_fn_26+0x394>
    4bb5:	mov    ecx,0x2
    4bba:	mov    rsi,r13
    4bbd:	cmp    rsi,0x11f
    4bc4:	cmovle rcx,QWORD PTR [rip+0x2f4]        # 4ec0 <botlish_fn_26+0x688>
    4bcc:	cmp    rcx,0x6
    4bd0:	je     4e1f <botlish_fn_26+0x5e7>
    4bd6:	mov    rsi,r13
    4bd9:	test   rsi,0x1
    4be0:	jne    4c0b <botlish_fn_26+0x3d3>
    4be6:	mov    edx,0x13f
    4beb:	mov    rsi,r13
    4bee:	mov    rdi,r12
    4bf1:	call   4bf6 <botlish_fn_26+0x3be>
			4bf2: R_X86_64_PLT32	rt_int_cmp-0x4
    4bf6:	mov    ecx,0x2
    4bfb:	test   rax,rax
    4bfe:	cmovle rcx,QWORD PTR [rip+0x2ba]        # 4ec0 <botlish_fn_26+0x688>
    4c06:	jmp    4c22 <botlish_fn_26+0x3ea>
    4c0b:	mov    ecx,0x2
    4c10:	mov    rsi,r13
    4c13:	cmp    rsi,0x13f
    4c1a:	cmovle rcx,QWORD PTR [rip+0x29e]        # 4ec0 <botlish_fn_26+0x688>
    4c22:	cmp    rcx,0x6
    4c26:	je     4e15 <botlish_fn_26+0x5dd>
    4c2c:	mov    rsi,r13
    4c2f:	test   rsi,0x1
    4c36:	jne    4c61 <botlish_fn_26+0x429>
    4c3c:	mov    edx,0x15f
    4c41:	mov    rsi,r13
    4c44:	mov    rdi,r12
    4c47:	call   4c4c <botlish_fn_26+0x414>
			4c48: R_X86_64_PLT32	rt_int_cmp-0x4
    4c4c:	mov    esi,0x2
    4c51:	test   rax,rax
    4c54:	cmovle rsi,QWORD PTR [rip+0x264]        # 4ec0 <botlish_fn_26+0x688>
    4c5c:	jmp    4c77 <botlish_fn_26+0x43f>
    4c61:	mov    esi,0x2
    4c66:	mov    rax,r13
    4c69:	cmp    rax,0x15f
    4c6f:	cmovle rsi,QWORD PTR [rip+0x249]        # 4ec0 <botlish_fn_26+0x688>
    4c77:	cmp    rsi,0x6
    4c7b:	je     4e0b <botlish_fn_26+0x5d3>
    4c81:	mov    rsi,r13
    4c84:	test   rsi,0x1
    4c8b:	jne    4cb6 <botlish_fn_26+0x47e>
    4c91:	mov    edx,0x17f
    4c96:	mov    rsi,r13
    4c99:	mov    rdi,r12
    4c9c:	call   4ca1 <botlish_fn_26+0x469>
			4c9d: R_X86_64_PLT32	rt_int_cmp-0x4
    4ca1:	mov    ecx,0x2
    4ca6:	test   rax,rax
    4ca9:	cmovle rcx,QWORD PTR [rip+0x20f]        # 4ec0 <botlish_fn_26+0x688>
    4cb1:	jmp    4ccd <botlish_fn_26+0x495>
    4cb6:	mov    ecx,0x2
    4cbb:	mov    rsi,r13
    4cbe:	cmp    rsi,0x17f
    4cc5:	cmovle rcx,QWORD PTR [rip+0x1f3]        # 4ec0 <botlish_fn_26+0x688>
    4ccd:	cmp    rcx,0x6
    4cd1:	je     4e01 <botlish_fn_26+0x5c9>
    4cd7:	mov    rsi,r13
    4cda:	test   rsi,0x1
    4ce1:	jne    4d0c <botlish_fn_26+0x4d4>
    4ce7:	mov    edx,0x19f
    4cec:	mov    rsi,r13
    4cef:	mov    rdi,r12
    4cf2:	call   4cf7 <botlish_fn_26+0x4bf>
			4cf3: R_X86_64_PLT32	rt_int_cmp-0x4
    4cf7:	mov    ecx,0x2
    4cfc:	test   rax,rax
    4cff:	cmovle rcx,QWORD PTR [rip+0x1b9]        # 4ec0 <botlish_fn_26+0x688>
    4d07:	jmp    4d23 <botlish_fn_26+0x4eb>
    4d0c:	mov    ecx,0x2
    4d11:	mov    rsi,r13
    4d14:	cmp    rsi,0x19f
    4d1b:	cmovle rcx,QWORD PTR [rip+0x19d]        # 4ec0 <botlish_fn_26+0x688>
    4d23:	cmp    rcx,0x6
    4d27:	je     4df7 <botlish_fn_26+0x5bf>
    4d2d:	mov    rsi,r13
    4d30:	test   rsi,0x1
    4d37:	jne    4d62 <botlish_fn_26+0x52a>
    4d3d:	mov    edx,0x1bf
    4d42:	mov    rsi,r13
    4d45:	mov    rdi,r12
    4d48:	call   4d4d <botlish_fn_26+0x515>
			4d49: R_X86_64_PLT32	rt_int_cmp-0x4
    4d4d:	mov    ecx,0x2
    4d52:	test   rax,rax
    4d55:	cmovle rcx,QWORD PTR [rip+0x163]        # 4ec0 <botlish_fn_26+0x688>
    4d5d:	jmp    4d79 <botlish_fn_26+0x541>
    4d62:	mov    ecx,0x2
    4d67:	mov    rsi,r13
    4d6a:	cmp    rsi,0x1bf
    4d71:	cmovle rcx,QWORD PTR [rip+0x147]        # 4ec0 <botlish_fn_26+0x688>
    4d79:	cmp    rcx,0x6
    4d7d:	je     4ded <botlish_fn_26+0x5b5>
    4d83:	mov    rsi,r13
    4d86:	test   rsi,0x1
    4d8d:	jne    4db8 <botlish_fn_26+0x580>
    4d93:	mov    edx,0x1df
    4d98:	mov    rsi,r13
    4d9b:	mov    rdi,r12
    4d9e:	call   4da3 <botlish_fn_26+0x56b>
			4d9f: R_X86_64_PLT32	rt_int_cmp-0x4
    4da3:	mov    ecx,0x2
    4da8:	test   rax,rax
    4dab:	cmovle rcx,QWORD PTR [rip+0x10d]        # 4ec0 <botlish_fn_26+0x688>
    4db3:	jmp    4dcf <botlish_fn_26+0x597>
    4db8:	mov    ecx,0x2
    4dbd:	mov    rsi,r13
    4dc0:	cmp    rsi,0x1df
    4dc7:	cmovle rcx,QWORD PTR [rip+0xf1]        # 4ec0 <botlish_fn_26+0x688>
    4dcf:	cmp    rcx,0x6
    4dd3:	je     4de3 <botlish_fn_26+0x5ab>
    4dd9:	mov    eax,0x1f
    4dde:	jmp    4e6a <botlish_fn_26+0x632>
    4de3:	mov    eax,0x1d
    4de8:	jmp    4e6a <botlish_fn_26+0x632>
    4ded:	mov    eax,0x1b
    4df2:	jmp    4e6a <botlish_fn_26+0x632>
    4df7:	mov    eax,0x19
    4dfc:	jmp    4e6a <botlish_fn_26+0x632>
    4e01:	mov    eax,0x17
    4e06:	jmp    4e6a <botlish_fn_26+0x632>
    4e0b:	mov    eax,0x15
    4e10:	jmp    4e6a <botlish_fn_26+0x632>
    4e15:	mov    eax,0x13
    4e1a:	jmp    4e6a <botlish_fn_26+0x632>
    4e1f:	mov    eax,0x11
    4e24:	jmp    4e6a <botlish_fn_26+0x632>
    4e29:	mov    eax,0xf
    4e2e:	jmp    4e6a <botlish_fn_26+0x632>
    4e33:	mov    eax,0xd
    4e38:	jmp    4e6a <botlish_fn_26+0x632>
    4e3d:	mov    eax,0xb
    4e42:	jmp    4e6a <botlish_fn_26+0x632>
    4e47:	mov    eax,0x9
    4e4c:	jmp    4e6a <botlish_fn_26+0x632>
    4e51:	mov    eax,0x7
    4e56:	jmp    4e6a <botlish_fn_26+0x632>
    4e5b:	mov    eax,0x5
    4e60:	jmp    4e6a <botlish_fn_26+0x632>
    4e65:	mov    eax,0x3
    4e6a:	mov    rdi,r12
    4e6d:	jmp    4e7a <botlish_fn_26+0x642>
    4e72:	mov    eax,0x1
    4e77:	mov    rdi,r12
    4e7a:	mov    rdi,r12
    4e7d:	mov    QWORD PTR [rdi],rbx
    4e80:	mov    rbx,QWORD PTR [rsp]
    4e84:	mov    r12,QWORD PTR [rsp+0x8]
    4e89:	mov    r13,QWORD PTR [rsp+0x10]
    4e8e:	add    rsp,0x20
    4e92:	mov    rsp,rbp
    4e95:	pop    rbp
    4e96:	ret
    4e97:	mov    r12,rdi
    4e9a:	call   4e9f <botlish_fn_26+0x667>
			4e9b: R_X86_64_PLT32	rt_stack_overflow-0x4
    4e9f:	xor    rax,rax
    4ea2:	mov    rbx,QWORD PTR [rsp]
    4ea6:	mov    r12,QWORD PTR [rsp+0x8]
    4eab:	mov    r13,QWORD PTR [rsp+0x10]
    4eb0:	add    rsp,0x20
    4eb4:	mov    rsp,rbp
    4eb7:	pop    rbp
    4eb8:	ret
    4eb9:	add    BYTE PTR [rax],al
    4ebb:	add    BYTE PTR [rax],al
    4ebd:	add    BYTE PTR [rax],al
    4ebf:	add    BYTE PTR [rsi],al
    4ec1:	add    BYTE PTR [rax],al
    4ec3:	add    BYTE PTR [rax],al
    4ec5:	add    BYTE PTR [rax],al
	...

0000000000004ec8 <botlish_entry_26: high_nibble<generic>>:
    4ec8:	push   rbp
    4ec9:	mov    rbp,rsp
    4ecc:	mov    rsi,QWORD PTR [rdx]
    4ecf:	call   4ed4 <botlish_entry_26+0xc>
			4ed0: R_X86_64_PLT32	botlish_fn_26-0x4 ; high_nibble<generic>
    4ed4:	mov    rsp,rbp
    4ed7:	pop    rbp
    4ed8:	ret
    4ed9:	add    BYTE PTR [rax],al
    4edb:	add    BYTE PTR [rax],al
    4edd:	add    BYTE PTR [rax],al
	...

0000000000004ee0 <botlish_fn_27: is_unreserved<generic>>:
    4ee0:	push   rbp
    4ee1:	mov    rbp,rsp
    4ee4:	sub    rsp,0x20
    4ee8:	mov    QWORD PTR [rsp],rbx
    4eec:	mov    QWORD PTR [rsp+0x8],r12
    4ef1:	mov    QWORD PTR [rsp+0x10],r13
    4ef6:	mov    QWORD PTR [rsp+0x18],r14
    4efb:	mov    rbx,QWORD PTR [rdi]
    4efe:	mov    rax,QWORD PTR [rdi+0x8]
    4f02:	lea    rcx,[rbx+0x8]
    4f06:	cmp    rcx,rax
    4f09:	ja     542d <botlish_fn_27+0x54d>
    4f0f:	lea    rdx,[rbx+0x8]
    4f13:	mov    QWORD PTR [rdi],rdx
    4f16:	mov    QWORD PTR [rbx],0x0
    4f1d:	mov    eax,0x1
    4f22:	test   rsi,0x1
    4f29:	jne    4f49 <botlish_fn_27+0x69>
    4f2f:	xor    eax,eax
    4f31:	test   rsi,0x7
    4f38:	jne    4f49 <botlish_fn_27+0x69>
    4f3e:	movzx  r11,BYTE PTR [rsi]
    4f42:	cmp    r11b,0x1
    4f46:	sete   al
    4f49:	test   al,al
    4f4b:	jne    4f8c <botlish_fn_27+0xac>
    4f51:	mov    rax,QWORD PTR [rdi+0x10]
    4f55:	mov    r12,rdi
    4f58:	mov    rcx,QWORD PTR [rax+0x110]
    4f5f:	xor    rdx,rdx
    4f62:	call   4f67 <botlish_fn_27+0x87>
			4f63: R_X86_64_PLT32	rt_type_error-0x4
    4f67:	mov    rdi,r12
    4f6a:	mov    QWORD PTR [rdi],rbx
    4f6d:	xor    rax,rax
    4f70:	mov    rbx,QWORD PTR [rsp]
    4f74:	mov    r12,QWORD PTR [rsp+0x8]
    4f79:	mov    r13,QWORD PTR [rsp+0x10]
    4f7e:	mov    r14,QWORD PTR [rsp+0x18]
    4f83:	add    rsp,0x20
    4f87:	mov    rsp,rbp
    4f8a:	pop    rbp
    4f8b:	ret
    4f8c:	mov    r12,rdi
    4f8f:	test   rsi,0x1
    4f96:	mov    r13,rsi
    4f99:	jne    4fc4 <botlish_fn_27+0xe4>
    4f9f:	mov    edx,0x59
    4fa4:	mov    rsi,r13
    4fa7:	mov    rdi,r12
    4faa:	call   4faf <botlish_fn_27+0xcf>
			4fab: R_X86_64_PLT32	rt_int_cmp-0x4
    4faf:	mov    ecx,0x2
    4fb4:	test   rax,rax
    4fb7:	cmovle rcx,QWORD PTR [rip+0x499]        # 5458 <botlish_fn_27+0x578>
    4fbf:	jmp    4fd8 <botlish_fn_27+0xf8>
    4fc4:	mov    ecx,0x2
    4fc9:	mov    rsi,r13
    4fcc:	cmp    rsi,0x59
    4fd0:	cmovle rcx,QWORD PTR [rip+0x480]        # 5458 <botlish_fn_27+0x578>
    4fd8:	mov    eax,0x6
    4fdd:	mov    r14,rax
    4fe0:	cmp    rcx,0x6
    4fe4:	je     5403 <botlish_fn_27+0x523>
    4fea:	mov    rsi,r13
    4fed:	test   rsi,0x1
    4ff4:	jne    501f <botlish_fn_27+0x13f>
    4ffa:	mov    edx,0x5d
    4fff:	mov    rsi,r13
    5002:	mov    rdi,r12
    5005:	call   500a <botlish_fn_27+0x12a>
			5006: R_X86_64_PLT32	rt_int_cmp-0x4
    500a:	mov    ecx,0x2
    500f:	test   rax,rax
    5012:	cmovle rcx,QWORD PTR [rip+0x43e]        # 5458 <botlish_fn_27+0x578>
    501a:	jmp    5033 <botlish_fn_27+0x153>
    501f:	mov    ecx,0x2
    5024:	mov    rsi,r13
    5027:	cmp    rsi,0x5d
    502b:	cmovle rcx,QWORD PTR [rip+0x425]        # 5458 <botlish_fn_27+0x578>
    5033:	cmp    rcx,0x6
    5037:	je     53f8 <botlish_fn_27+0x518>
    503d:	mov    rsi,r13
    5040:	test   rsi,0x1
    5047:	jne    5073 <botlish_fn_27+0x193>
    504d:	mov    edx,0x5f
    5052:	mov    rsi,r13
    5055:	mov    rdi,r12
    5058:	call   505d <botlish_fn_27+0x17d>
			5059: R_X86_64_PLT32	rt_int_cmp-0x4
    505d:	mov    r10d,0x2
    5063:	test   rax,rax
    5066:	cmovle r10,QWORD PTR [rip+0x3ea]        # 5458 <botlish_fn_27+0x578>
    506e:	jmp    5088 <botlish_fn_27+0x1a8>
    5073:	mov    r10d,0x2
    5079:	mov    rsi,r13
    507c:	cmp    rsi,0x5f
    5080:	cmovle r10,QWORD PTR [rip+0x3d0]        # 5458 <botlish_fn_27+0x578>
    5088:	cmp    r10,0x6
    508c:	je     53ee <botlish_fn_27+0x50e>
    5092:	mov    rsi,r13
    5095:	test   rsi,0x1
    509c:	jne    50c7 <botlish_fn_27+0x1e7>
    50a2:	mov    edx,0x73
    50a7:	mov    rsi,r13
    50aa:	mov    rdi,r12
    50ad:	call   50b2 <botlish_fn_27+0x1d2>
			50ae: R_X86_64_PLT32	rt_int_cmp-0x4
    50b2:	mov    ecx,0x2
    50b7:	test   rax,rax
    50ba:	cmovle rcx,QWORD PTR [rip+0x396]        # 5458 <botlish_fn_27+0x578>
    50c2:	jmp    50db <botlish_fn_27+0x1fb>
    50c7:	mov    ecx,0x2
    50cc:	mov    rsi,r13
    50cf:	cmp    rsi,0x73
    50d3:	cmovle rcx,QWORD PTR [rip+0x37d]        # 5458 <botlish_fn_27+0x578>
    50db:	cmp    rcx,0x6
    50df:	je     53e6 <botlish_fn_27+0x506>
    50e5:	mov    rsi,r13
    50e8:	test   rsi,0x1
    50ef:	jne    511a <botlish_fn_27+0x23a>
    50f5:	mov    edx,0x81
    50fa:	mov    rsi,r13
    50fd:	mov    rdi,r12
    5100:	call   5105 <botlish_fn_27+0x225>
			5101: R_X86_64_PLT32	rt_int_cmp-0x4
    5105:	mov    ecx,0x2
    510a:	test   rax,rax
    510d:	cmovle rcx,QWORD PTR [rip+0x343]        # 5458 <botlish_fn_27+0x578>
    5115:	jmp    5131 <botlish_fn_27+0x251>
    511a:	mov    ecx,0x2
    511f:	mov    rsi,r13
    5122:	cmp    rsi,0x81
    5129:	cmovle rcx,QWORD PTR [rip+0x327]        # 5458 <botlish_fn_27+0x578>
    5131:	cmp    rcx,0x6
    5135:	je     53dc <botlish_fn_27+0x4fc>
    513b:	mov    rsi,r13
    513e:	test   rsi,0x1
    5145:	jne    5170 <botlish_fn_27+0x290>
    514b:	mov    edx,0xb5
    5150:	mov    rsi,r13
    5153:	mov    rdi,r12
    5156:	call   515b <botlish_fn_27+0x27b>
			5157: R_X86_64_PLT32	rt_int_cmp-0x4
    515b:	mov    ecx,0x2
    5160:	test   rax,rax
    5163:	cmovle rcx,QWORD PTR [rip+0x2ed]        # 5458 <botlish_fn_27+0x578>
    516b:	jmp    5187 <botlish_fn_27+0x2a7>
    5170:	mov    ecx,0x2
    5175:	mov    rsi,r13
    5178:	cmp    rsi,0xb5
    517f:	cmovle rcx,QWORD PTR [rip+0x2d1]        # 5458 <botlish_fn_27+0x578>
    5187:	cmp    rcx,0x6
    518b:	je     53d4 <botlish_fn_27+0x4f4>
    5191:	mov    rsi,r13
    5194:	test   rsi,0x1
    519b:	jne    51c6 <botlish_fn_27+0x2e6>
    51a1:	mov    edx,0xbd
    51a6:	mov    rsi,r13
    51a9:	mov    rdi,r12
    51ac:	call   51b1 <botlish_fn_27+0x2d1>
			51ad: R_X86_64_PLT32	rt_int_cmp-0x4
    51b1:	mov    edi,0x2
    51b6:	test   rax,rax
    51b9:	cmovle rdi,QWORD PTR [rip+0x297]        # 5458 <botlish_fn_27+0x578>
    51c1:	jmp    51dd <botlish_fn_27+0x2fd>
    51c6:	mov    edi,0x2
    51cb:	mov    rsi,r13
    51ce:	cmp    rsi,0xbd
    51d5:	cmovle rdi,QWORD PTR [rip+0x27b]        # 5458 <botlish_fn_27+0x578>
    51dd:	cmp    rdi,0x6
    51e1:	je     53ca <botlish_fn_27+0x4ea>
    51e7:	mov    rsi,r13
    51ea:	test   rsi,0x1
    51f1:	jne    521c <botlish_fn_27+0x33c>
    51f7:	mov    edx,0xbf
    51fc:	mov    rsi,r13
    51ff:	mov    rdi,r12
    5202:	call   5207 <botlish_fn_27+0x327>
			5203: R_X86_64_PLT32	rt_int_cmp-0x4
    5207:	mov    ecx,0x2
    520c:	test   rax,rax
    520f:	cmovle rcx,QWORD PTR [rip+0x241]        # 5458 <botlish_fn_27+0x578>
    5217:	jmp    5233 <botlish_fn_27+0x353>
    521c:	mov    ecx,0x2
    5221:	mov    rsi,r13
    5224:	cmp    rsi,0xbf
    522b:	cmovle rcx,QWORD PTR [rip+0x225]        # 5458 <botlish_fn_27+0x578>
    5233:	cmp    rcx,0x6
    5237:	je     53c2 <botlish_fn_27+0x4e2>
    523d:	mov    rsi,r13
    5240:	test   rsi,0x1
    5247:	jne    5272 <botlish_fn_27+0x392>
    524d:	mov    edx,0xc1
    5252:	mov    rsi,r13
    5255:	mov    rdi,r12
    5258:	call   525d <botlish_fn_27+0x37d>
			5259: R_X86_64_PLT32	rt_int_cmp-0x4
    525d:	mov    ecx,0x2
    5262:	test   rax,rax
    5265:	cmovle rcx,QWORD PTR [rip+0x1eb]        # 5458 <botlish_fn_27+0x578>
    526d:	jmp    5289 <botlish_fn_27+0x3a9>
    5272:	mov    ecx,0x2
    5277:	mov    rsi,r13
    527a:	cmp    rsi,0xc1
    5281:	cmovle rcx,QWORD PTR [rip+0x1cf]        # 5458 <botlish_fn_27+0x578>
    5289:	cmp    rcx,0x6
    528d:	je     53b8 <botlish_fn_27+0x4d8>
    5293:	mov    rsi,r13
    5296:	test   rsi,0x1
    529d:	jne    52c8 <botlish_fn_27+0x3e8>
    52a3:	mov    edx,0xf5
    52a8:	mov    rsi,r13
    52ab:	mov    rdi,r12
    52ae:	call   52b3 <botlish_fn_27+0x3d3>
			52af: R_X86_64_PLT32	rt_int_cmp-0x4
    52b3:	mov    ecx,0x2
    52b8:	test   rax,rax
    52bb:	cmovle rcx,QWORD PTR [rip+0x195]        # 5458 <botlish_fn_27+0x578>
    52c3:	jmp    52df <botlish_fn_27+0x3ff>
    52c8:	mov    ecx,0x2
    52cd:	mov    rsi,r13
    52d0:	cmp    rsi,0xf5
    52d7:	cmovle rcx,QWORD PTR [rip+0x179]        # 5458 <botlish_fn_27+0x578>
    52df:	cmp    rcx,0x6
    52e3:	je     53b0 <botlish_fn_27+0x4d0>
    52e9:	mov    rsi,r13
    52ec:	test   rsi,0x1
    52f3:	jne    531e <botlish_fn_27+0x43e>
    52f9:	mov    edx,0xfb
    52fe:	mov    rsi,r13
    5301:	mov    rdi,r12
    5304:	call   5309 <botlish_fn_27+0x429>
			5305: R_X86_64_PLT32	rt_int_cmp-0x4
    5309:	mov    esi,0x2
    530e:	test   rax,rax
    5311:	cmovle rsi,QWORD PTR [rip+0x13f]        # 5458 <botlish_fn_27+0x578>
    5319:	jmp    5334 <botlish_fn_27+0x454>
    531e:	mov    esi,0x2
    5323:	mov    rax,r13
    5326:	cmp    rax,0xfb
    532c:	cmovle rsi,QWORD PTR [rip+0x124]        # 5458 <botlish_fn_27+0x578>
    5334:	cmp    rsi,0x6
    5338:	je     53a6 <botlish_fn_27+0x4c6>
    533e:	mov    rsi,r13
    5341:	test   rsi,0x1
    5348:	jne    5373 <botlish_fn_27+0x493>
    534e:	mov    edx,0xfd
    5353:	mov    rsi,r13
    5356:	mov    rdi,r12
    5359:	call   535e <botlish_fn_27+0x47e>
			535a: R_X86_64_PLT32	rt_int_cmp-0x4
    535e:	mov    ecx,0x2
    5363:	test   rax,rax
    5366:	cmovle rcx,QWORD PTR [rip+0xea]        # 5458 <botlish_fn_27+0x578>
    536e:	jmp    538a <botlish_fn_27+0x4aa>
    5373:	mov    ecx,0x2
    5378:	mov    rsi,r13
    537b:	cmp    rsi,0xfd
    5382:	cmovle rcx,QWORD PTR [rip+0xce]        # 5458 <botlish_fn_27+0x578>
    538a:	cmp    rcx,0x6
    538e:	je     539e <botlish_fn_27+0x4be>
    5394:	mov    eax,0x2
    5399:	jmp    53fb <botlish_fn_27+0x51b>
    539e:	mov    rax,r14
    53a1:	jmp    53fb <botlish_fn_27+0x51b>
    53a6:	mov    eax,0x2
    53ab:	jmp    53fb <botlish_fn_27+0x51b>
    53b0:	mov    rax,r14
    53b3:	jmp    53fb <botlish_fn_27+0x51b>
    53b8:	mov    eax,0x2
    53bd:	jmp    53fb <botlish_fn_27+0x51b>
    53c2:	mov    rax,r14
    53c5:	jmp    53fb <botlish_fn_27+0x51b>
    53ca:	mov    eax,0x2
    53cf:	jmp    53fb <botlish_fn_27+0x51b>
    53d4:	mov    rax,r14
    53d7:	jmp    53fb <botlish_fn_27+0x51b>
    53dc:	mov    eax,0x2
    53e1:	jmp    53fb <botlish_fn_27+0x51b>
    53e6:	mov    rax,r14
    53e9:	jmp    53fb <botlish_fn_27+0x51b>
    53ee:	mov    eax,0x2
    53f3:	jmp    53fb <botlish_fn_27+0x51b>
    53f8:	mov    rax,r14
    53fb:	mov    rdi,r12
    53fe:	jmp    540b <botlish_fn_27+0x52b>
    5403:	mov    eax,0x2
    5408:	mov    rdi,r12
    540b:	mov    rdi,r12
    540e:	mov    QWORD PTR [rdi],rbx
    5411:	mov    rbx,QWORD PTR [rsp]
    5415:	mov    r12,QWORD PTR [rsp+0x8]
    541a:	mov    r13,QWORD PTR [rsp+0x10]
    541f:	mov    r14,QWORD PTR [rsp+0x18]
    5424:	add    rsp,0x20
    5428:	mov    rsp,rbp
    542b:	pop    rbp
    542c:	ret
    542d:	mov    r12,rdi
    5430:	call   5435 <botlish_fn_27+0x555>
			5431: R_X86_64_PLT32	rt_stack_overflow-0x4
    5435:	xor    rax,rax
    5438:	mov    rbx,QWORD PTR [rsp]
    543c:	mov    r12,QWORD PTR [rsp+0x8]
    5441:	mov    r13,QWORD PTR [rsp+0x10]
    5446:	mov    r14,QWORD PTR [rsp+0x18]
    544b:	add    rsp,0x20
    544f:	mov    rsp,rbp
    5452:	pop    rbp
    5453:	ret
    5454:	add    BYTE PTR [rax],al
    5456:	add    BYTE PTR [rax],al
    5458:	(bad)
    5459:	add    BYTE PTR [rax],al
    545b:	add    BYTE PTR [rax],al
    545d:	add    BYTE PTR [rax],al
	...

0000000000005460 <botlish_entry_27: is_unreserved<generic>>:
    5460:	push   rbp
    5461:	mov    rbp,rsp
    5464:	mov    rsi,QWORD PTR [rdx]
    5467:	call   546c <botlish_entry_27+0xc>
			5468: R_X86_64_PLT32	botlish_fn_27-0x4 ; is_unreserved<generic>
    546c:	mov    rsp,rbp
    546f:	pop    rbp
    5470:	ret

0000000000005471 <botlish_fn_28: hex_pair<generic>>:
    5471:	push   rbp
    5472:	mov    rbp,rsp
    5475:	sub    rsp,0x30
    5479:	mov    QWORD PTR [rsp],rbx
    547d:	mov    QWORD PTR [rsp+0x8],r12
    5482:	mov    QWORD PTR [rsp+0x10],r13
    5487:	mov    QWORD PTR [rsp+0x18],r14
    548c:	mov    QWORD PTR [rsp+0x20],r15
    5491:	mov    r13,rdx
    5494:	mov    rbx,QWORD PTR [rdi]
    5497:	mov    rax,QWORD PTR [rdi+0x8]
    549b:	lea    rcx,[rbx+0x10]
    549f:	cmp    rcx,rax
    54a2:	ja     56ba <botlish_fn_28+0x249>
    54a8:	lea    rax,[rbx+0x10]
    54ac:	mov    QWORD PTR [rdi],rax
    54af:	mov    r12,rdi
    54b2:	mov    QWORD PTR [rbx],0x0
    54b9:	mov    QWORD PTR [rbx+0x8],0x0
    54c1:	mov    rdx,r13
    54c4:	mov    QWORD PTR [rbx],rdx
    54c7:	mov    rax,QWORD PTR [rsi+0x20]
    54cb:	mov    r14,rsi
    54ce:	mov    rsi,QWORD PTR [rax]
    54d1:	mov    QWORD PTR [rbx+0x8],rsi
    54d5:	mov    r15,rsi
    54d8:	mov    rsi,r13
    54db:	mov    rdi,r12
    54de:	call   54e3 <botlish_fn_28+0x72>
			54df: R_X86_64_PLT32	botlish_fn_26-0x4 ; high_nibble<generic>
    54e3:	test   rax,rax
    54e6:	jne    54f4 <botlish_fn_28+0x83>
    54ec:	mov    rdi,r12
    54ef:	jmp    5669 <botlish_fn_28+0x1f8>
    54f4:	test   rax,0x1
    54fa:	jne    550b <botlish_fn_28+0x9a>
    5500:	mov    rdx,rax
    5503:	mov    rsi,r15
    5506:	jmp    5527 <botlish_fn_28+0xb6>
    550b:	mov    rsi,r15
    550e:	mov    rdx,QWORD PTR [rsi+0x8]
    5512:	mov    rcx,rax
    5515:	sar    rcx,1
    5518:	mov    rdi,rax
    551b:	cmp    rcx,rdx
    551e:	jb     5548 <botlish_fn_28+0xd7>
    5524:	mov    rdx,rdi
    5527:	mov    rdi,r12
    552a:	call   552f <botlish_fn_28+0xbe>
			552b: R_X86_64_PLT32	rt_list_get-0x4
    552f:	test   rax,rax
    5532:	jne    5540 <botlish_fn_28+0xcf>
    5538:	mov    rdi,r12
    553b:	jmp    5669 <botlish_fn_28+0x1f8>
    5540:	mov    rsi,rax
    5543:	jmp    5550 <botlish_fn_28+0xdf>
    5548:	mov    rdx,QWORD PTR [rsi+0x10]
    554c:	mov    rsi,QWORD PTR [rdx+rcx*8]
    5550:	mov    QWORD PTR [rbx],rsi
    5553:	mov    rax,rsi
    5556:	mov    rsi,r14
    5559:	mov    r14,rax
    555c:	mov    rsi,QWORD PTR [rsi+0x20]
    5560:	mov    rsi,QWORD PTR [rsi]
    5563:	mov    r15,rsi
    5566:	mov    ecx,0x1
    556b:	mov    rdx,r13
    556e:	test   rdx,0x1
    5575:	je     5583 <botlish_fn_28+0x112>
    557b:	mov    r13,rdx
    557e:	jmp    55a8 <botlish_fn_28+0x137>
    5583:	xor    ecx,ecx
    5585:	test   rdx,0x7
    558c:	je     559a <botlish_fn_28+0x129>
    5592:	mov    r13,rdx
    5595:	jmp    55a8 <botlish_fn_28+0x137>
    559a:	movzx  r10,BYTE PTR [rdx]
    559e:	mov    r13,rdx
    55a1:	cmp    r10b,0x1
    55a5:	sete   cl
    55a8:	test   cl,cl
    55aa:	jne    55d1 <botlish_fn_28+0x160>
    55b0:	mov    rdi,r12
    55b3:	mov    rax,QWORD PTR [rdi+0x10]
    55b7:	mov    rcx,QWORD PTR [rax+0x118]
    55be:	xor    rdx,rdx
    55c1:	mov    rsi,r13
    55c4:	call   55c9 <botlish_fn_28+0x158>
			55c5: R_X86_64_PLT32	rt_type_error-0x4
    55c9:	mov    rdi,r12
    55cc:	jmp    5669 <botlish_fn_28+0x1f8>
    55d1:	mov    rsi,r13
    55d4:	mov    edx,0x21
    55d9:	mov    rdi,r12
    55dc:	call   55e1 <botlish_fn_28+0x170>
			55dd: R_X86_64_PLT32	rt_int_mod-0x4
    55e1:	test   rax,rax
    55e4:	jne    55f2 <botlish_fn_28+0x181>
    55ea:	mov    rdi,r12
    55ed:	jmp    5669 <botlish_fn_28+0x1f8>
    55f2:	test   rax,0x1
    55f8:	jne    5609 <botlish_fn_28+0x198>
    55fe:	mov    rdx,rax
    5601:	mov    rsi,r15
    5604:	jmp    5625 <botlish_fn_28+0x1b4>
    5609:	mov    rsi,r15
    560c:	mov    rdx,QWORD PTR [rsi+0x8]
    5610:	mov    rcx,rax
    5613:	sar    rcx,1
    5616:	mov    rdi,rax
    5619:	cmp    rcx,rdx
    561c:	jb     5646 <botlish_fn_28+0x1d5>
    5622:	mov    rdx,rdi
    5625:	mov    rdi,r12
    5628:	call   562d <botlish_fn_28+0x1bc>
			5629: R_X86_64_PLT32	rt_list_get-0x4
    562d:	test   rax,rax
    5630:	jne    563e <botlish_fn_28+0x1cd>
    5636:	mov    rdi,r12
    5639:	jmp    5669 <botlish_fn_28+0x1f8>
    563e:	mov    rdx,rax
    5641:	jmp    564e <botlish_fn_28+0x1dd>
    5646:	mov    rax,QWORD PTR [rsi+0x10]
    564a:	mov    rdx,QWORD PTR [rax+rcx*8]
    564e:	mov    QWORD PTR [rbx+0x8],rdx
    5652:	mov    rsi,r14
    5655:	mov    rdi,r12
    5658:	call   565d <botlish_fn_28+0x1ec>
			5659: R_X86_64_PLT32	rt_str_cat-0x4
    565d:	test   rax,rax
    5660:	jne    5693 <botlish_fn_28+0x222>
    5666:	mov    rdi,r12
    5669:	mov    rdi,r12
    566c:	mov    QWORD PTR [rdi],rbx
    566f:	xor    rax,rax
    5672:	mov    rbx,QWORD PTR [rsp]
    5676:	mov    r12,QWORD PTR [rsp+0x8]
    567b:	mov    r13,QWORD PTR [rsp+0x10]
    5680:	mov    r14,QWORD PTR [rsp+0x18]
    5685:	mov    r15,QWORD PTR [rsp+0x20]
    568a:	add    rsp,0x30
    568e:	mov    rsp,rbp
    5691:	pop    rbp
    5692:	ret
    5693:	mov    rdi,r12
    5696:	mov    QWORD PTR [rdi],rbx
    5699:	mov    rbx,QWORD PTR [rsp]
    569d:	mov    r12,QWORD PTR [rsp+0x8]
    56a2:	mov    r13,QWORD PTR [rsp+0x10]
    56a7:	mov    r14,QWORD PTR [rsp+0x18]
    56ac:	mov    r15,QWORD PTR [rsp+0x20]
    56b1:	add    rsp,0x30
    56b5:	mov    rsp,rbp
    56b8:	pop    rbp
    56b9:	ret
    56ba:	mov    r12,rdi
    56bd:	call   56c2 <botlish_fn_28+0x251>
			56be: R_X86_64_PLT32	rt_stack_overflow-0x4
    56c2:	xor    rax,rax
    56c5:	mov    rbx,QWORD PTR [rsp]
    56c9:	mov    r12,QWORD PTR [rsp+0x8]
    56ce:	mov    r13,QWORD PTR [rsp+0x10]
    56d3:	mov    r14,QWORD PTR [rsp+0x18]
    56d8:	mov    r15,QWORD PTR [rsp+0x20]
    56dd:	add    rsp,0x30
    56e1:	mov    rsp,rbp
    56e4:	pop    rbp
    56e5:	ret

00000000000056e6 <botlish_entry_28: hex_pair<generic>>:
    56e6:	push   rbp
    56e7:	mov    rbp,rsp
    56ea:	mov    rdx,QWORD PTR [rdx]
    56ed:	call   56f2 <botlish_entry_28+0xc>
			56ee: R_X86_64_PLT32	botlish_fn_28-0x4 ; hex_pair<generic>
    56f2:	mov    rsp,rbp
    56f5:	pop    rbp
    56f6:	ret
	...

00000000000056f8 <botlish_fn_29: esc_bytes<generic>>:
    56f8:	push   rbp
    56f9:	mov    rbp,rsp
    56fc:	sub    rsp,0x50
    5700:	mov    QWORD PTR [rsp+0x20],rbx
    5705:	mov    QWORD PTR [rsp+0x28],r12
    570a:	mov    QWORD PTR [rsp+0x30],r13
    570f:	mov    QWORD PTR [rsp+0x38],r14
    5714:	mov    QWORD PTR [rsp+0x40],r15
    5719:	mov    r13,rsi
    571c:	mov    r14,QWORD PTR [rdi]
    571f:	mov    r9,QWORD PTR [rdi+0x8]
    5723:	lea    r10,[r14+0x38]
    5727:	cmp    r10,r9
    572a:	ja     5a98 <botlish_fn_29+0x3a0>
    5730:	lea    r10,[r14+0x38]
    5734:	mov    QWORD PTR [rdi],r10
    5737:	mov    r15,rdi
    573a:	mov    QWORD PTR [r14],0x0
    5741:	mov    QWORD PTR [r14+0x8],0x0
    5749:	mov    QWORD PTR [r14+0x10],0x0
    5751:	mov    QWORD PTR [r14+0x18],0x0
    5759:	mov    QWORD PTR [r14+0x20],0x0
    5761:	mov    QWORD PTR [r14+0x28],0x0
    5769:	mov    QWORD PTR [r14+0x30],0x0
    5771:	mov    QWORD PTR [r14],rdx
    5774:	mov    QWORD PTR [r14+0x8],rcx
    5778:	mov    QWORD PTR [r14+0x10],r8
    577c:	mov    QWORD PTR [rsp],rcx
    5780:	mov    QWORD PTR [rsp+0x8],r8
    5785:	xor    eax,eax
    5787:	test   rdx,0x7
    578e:	je     579c <botlish_fn_29+0xa4>
    5794:	mov    rsi,rdx
    5797:	jmp    57a8 <botlish_fn_29+0xb0>
    579c:	movzx  rax,BYTE PTR [rdx]
    57a0:	mov    rsi,rdx
    57a3:	cmp    al,0x3
    57a5:	sete   al
    57a8:	test   al,al
    57aa:	jne    57d0 <botlish_fn_29+0xd8>
    57b0:	mov    rdi,r15
    57b3:	mov    rax,QWORD PTR [rdi+0x10]
    57b7:	mov    rcx,QWORD PTR [rax+0x120]
    57be:	mov    edx,0x4
    57c3:	call   57c8 <botlish_fn_29+0xd0>
			57c4: R_X86_64_PLT32	rt_type_error-0x4
    57c8:	mov    rdi,r15
    57cb:	jmp    5a21 <botlish_fn_29+0x329>
    57d0:	mov    rbx,rsi
    57d3:	mov    rdi,r15
    57d6:	call   57db <botlish_fn_29+0xe3>
			57d7: R_X86_64_PLT32	rt_list_len-0x4
    57db:	mov    ecx,0x1
    57e0:	mov    rsi,QWORD PTR [rsp]
    57e4:	test   rsi,0x1
    57eb:	jne    5813 <botlish_fn_29+0x11b>
    57f1:	xor    ecx,ecx
    57f3:	mov    rsi,QWORD PTR [rsp]
    57f7:	test   rsi,0x7
    57fe:	jne    5813 <botlish_fn_29+0x11b>
    5804:	mov    rsi,QWORD PTR [rsp]
    5808:	movzx  rcx,BYTE PTR [rsi]
    580c:	rex cmp cl,0x1
    5810:	sete   cl
    5813:	test   cl,cl
    5815:	jne    583d <botlish_fn_29+0x145>
    581b:	mov    rdi,r15
    581e:	mov    rax,QWORD PTR [rdi+0x10]
    5822:	mov    rcx,QWORD PTR [rax+0x80]
    5829:	xor    rdx,rdx
    582c:	mov    rsi,QWORD PTR [rsp]
    5830:	call   5835 <botlish_fn_29+0x13d>
			5831: R_X86_64_PLT32	rt_type_error-0x4
    5835:	mov    rdi,r15
    5838:	jmp    5a21 <botlish_fn_29+0x329>
    583d:	mov    rsi,QWORD PTR [rsp]
    5841:	mov    rcx,rsi
    5844:	and    rcx,rax
    5847:	mov    rdx,rax
    584a:	test   rcx,0x1
    5851:	jne    5878 <botlish_fn_29+0x180>
    5857:	mov    rsi,QWORD PTR [rsp]
    585b:	mov    rdi,r15
    585e:	call   5863 <botlish_fn_29+0x16b>
			585f: R_X86_64_PLT32	rt_int_cmp-0x4
    5863:	mov    edi,0x2
    5868:	test   rax,rax
    586b:	cmovge rdi,QWORD PTR [rip+0x255]        # 5ac8 <botlish_fn_29+0x3d0>
    5873:	jmp    588c <botlish_fn_29+0x194>
    5878:	mov    edi,0x2
    587d:	mov    rsi,QWORD PTR [rsp]
    5881:	cmp    rsi,rdx
    5884:	cmovge rdi,QWORD PTR [rip+0x23c]        # 5ac8 <botlish_fn_29+0x3d0>
    588c:	cmp    rdi,0x6
    5890:	je     5a6b <botlish_fn_29+0x373>
    5896:	mov    r12,r13
    5899:	mov    QWORD PTR [r14+0x18],r12
    589d:	mov    QWORD PTR [r14+0x20],0x3
    58a5:	mov    rsi,QWORD PTR [rsp]
    58a9:	test   rsi,0x1
    58b0:	je     58d7 <botlish_fn_29+0x1df>
    58b6:	mov    rsi,QWORD PTR [rsp]
    58ba:	mov    rax,rsi
    58bd:	add    rax,0x2
    58c1:	mov    rcx,rax
    58c4:	seto   al
    58c7:	test   al,al
    58c9:	jne    58d7 <botlish_fn_29+0x1df>
    58cf:	mov    r13,rcx
    58d2:	jmp    58ee <botlish_fn_29+0x1f6>
    58d7:	mov    edx,0x3
    58dc:	mov    rsi,QWORD PTR [rsp]
    58e0:	mov    rdi,r15
    58e3:	call   58e8 <botlish_fn_29+0x1f0>
			58e4: R_X86_64_PLT32	rt_int_add-0x4
    58e8:	mov    rcx,rax
    58eb:	mov    r13,rcx
    58ee:	mov    QWORD PTR [r14+0x8],r13
    58f2:	mov    rdi,r15
    58f5:	mov    rax,QWORD PTR [rdi+0x10]
    58f9:	mov    rsi,QWORD PTR [rax+0x70]
    58fd:	mov    QWORD PTR [r14+0x20],rsi
    5901:	mov    QWORD PTR [rsp+0x18],rsi
    5906:	mov    rax,QWORD PTR [r12+0x20]
    590b:	mov    rsi,QWORD PTR [rax]
    590e:	mov    QWORD PTR [r14+0x28],rsi
    5912:	mov    QWORD PTR [rsp+0x10],rsi
    5917:	mov    rsi,QWORD PTR [rsp]
    591b:	test   rsi,0x1
    5922:	jne    5931 <botlish_fn_29+0x239>
    5928:	mov    rdx,QWORD PTR [rsp]
    592c:	jmp    594c <botlish_fn_29+0x254>
    5931:	mov    rsi,QWORD PTR [rbx+0x8]
    5935:	mov    rdi,QWORD PTR [rsp]
    5939:	mov    rdx,rdi
    593c:	sar    rdx,1
    593f:	cmp    rdx,rsi
    5942:	jb     5970 <botlish_fn_29+0x278>
    5948:	mov    rdx,QWORD PTR [rsp]
    594c:	mov    rsi,rbx
    594f:	mov    rdi,r15
    5952:	call   5957 <botlish_fn_29+0x25f>
			5953: R_X86_64_PLT32	rt_list_get-0x4
    5957:	test   rax,rax
    595a:	jne    5968 <botlish_fn_29+0x270>
    5960:	mov    rdi,r15
    5963:	jmp    5a21 <botlish_fn_29+0x329>
    5968:	mov    rdx,rax
    596b:	jmp    5978 <botlish_fn_29+0x280>
    5970:	mov    r9,QWORD PTR [rbx+0x10]
    5974:	mov    rdx,QWORD PTR [r9+rdx*8]
    5978:	mov    QWORD PTR [r14+0x30],rdx
    597c:	mov    rsi,QWORD PTR [rsp+0x10]
    5981:	mov    rdi,r15
    5984:	call   5989 <botlish_fn_29+0x291>
			5985: R_X86_64_PLT32	botlish_fn_28-0x4 ; hex_pair<generic>
    5989:	test   rax,rax
    598c:	jne    599a <botlish_fn_29+0x2a2>
    5992:	mov    rdi,r15
    5995:	jmp    5a21 <botlish_fn_29+0x329>
    599a:	mov    QWORD PTR [r14+0x28],rax
    599e:	mov    rdx,rax
    59a1:	mov    rsi,QWORD PTR [rsp+0x18]
    59a6:	mov    rdi,r15
    59a9:	call   59ae <botlish_fn_29+0x2b6>
			59aa: R_X86_64_PLT32	rt_str_cat-0x4
    59ae:	test   rax,rax
    59b1:	jne    59bf <botlish_fn_29+0x2c7>
    59b7:	mov    rdi,r15
    59ba:	jmp    5a21 <botlish_fn_29+0x329>
    59bf:	mov    QWORD PTR [r14+0x20],rax
    59c3:	mov    rdx,rax
    59c6:	xor    edi,edi
    59c8:	mov    rsi,QWORD PTR [rsp+0x8]
    59cd:	test   rsi,0x7
    59d4:	jne    59e4 <botlish_fn_29+0x2ec>
    59da:	movzx  rax,BYTE PTR [rsi]
    59de:	cmp    al,0x2
    59e0:	sete   dil
    59e4:	test   dil,dil
    59e7:	jne    5a0d <botlish_fn_29+0x315>
    59ed:	mov    rdi,r15
    59f0:	mov    rax,QWORD PTR [rdi+0x10]
    59f4:	mov    rcx,QWORD PTR [rax+0x128]
    59fb:	mov    edx,0x1
    5a00:	call   5a05 <botlish_fn_29+0x30d>
			5a01: R_X86_64_PLT32	rt_type_error-0x4
    5a05:	mov    rdi,r15
    5a08:	jmp    5a21 <botlish_fn_29+0x329>
    5a0d:	mov    rdi,r15
    5a10:	call   5a15 <botlish_fn_29+0x31d>
			5a11: R_X86_64_PLT32	rt_str_cat-0x4
    5a15:	test   rax,rax
    5a18:	jne    5a4c <botlish_fn_29+0x354>
    5a1e:	mov    rdi,r15
    5a21:	mov    rdi,r15
    5a24:	mov    QWORD PTR [rdi],r14
    5a27:	xor    rax,rax
    5a2a:	mov    rbx,QWORD PTR [rsp+0x20]
    5a2f:	mov    r12,QWORD PTR [rsp+0x28]
    5a34:	mov    r13,QWORD PTR [rsp+0x30]
    5a39:	mov    r14,QWORD PTR [rsp+0x38]
    5a3e:	mov    r15,QWORD PTR [rsp+0x40]
    5a43:	add    rsp,0x50
    5a47:	mov    rsp,rbp
    5a4a:	pop    rbp
    5a4b:	ret
    5a4c:	mov    QWORD PTR [r14],rbx
    5a4f:	mov    QWORD PTR [r14+0x8],r13
    5a53:	mov    QWORD PTR [r14+0x10],rax
    5a57:	mov    QWORD PTR [rsp+0x8],rax
    5a5c:	mov    QWORD PTR [rsp],r13
    5a60:	mov    r13,r12
    5a63:	mov    rdx,rbx
    5a66:	jmp    5785 <botlish_fn_29+0x8d>
    5a6b:	mov    rdi,r15
    5a6e:	mov    QWORD PTR [rdi],r14
    5a71:	mov    rax,QWORD PTR [rsp+0x8]
    5a76:	mov    rbx,QWORD PTR [rsp+0x20]
    5a7b:	mov    r12,QWORD PTR [rsp+0x28]
    5a80:	mov    r13,QWORD PTR [rsp+0x30]
    5a85:	mov    r14,QWORD PTR [rsp+0x38]
    5a8a:	mov    r15,QWORD PTR [rsp+0x40]
    5a8f:	add    rsp,0x50
    5a93:	mov    rsp,rbp
    5a96:	pop    rbp
    5a97:	ret
    5a98:	mov    r15,rdi
    5a9b:	call   5aa0 <botlish_fn_29+0x3a8>
			5a9c: R_X86_64_PLT32	rt_stack_overflow-0x4
    5aa0:	xor    rax,rax
    5aa3:	mov    rbx,QWORD PTR [rsp+0x20]
    5aa8:	mov    r12,QWORD PTR [rsp+0x28]
    5aad:	mov    r13,QWORD PTR [rsp+0x30]
    5ab2:	mov    r14,QWORD PTR [rsp+0x38]
    5ab7:	mov    r15,QWORD PTR [rsp+0x40]
    5abc:	add    rsp,0x50
    5ac0:	mov    rsp,rbp
    5ac3:	pop    rbp
    5ac4:	ret
    5ac5:	add    BYTE PTR [rax],al
    5ac7:	add    BYTE PTR [rsi],al
    5ac9:	add    BYTE PTR [rax],al
    5acb:	add    BYTE PTR [rax],al
    5acd:	add    BYTE PTR [rax],al
	...

0000000000005ad0 <botlish_entry_29: esc_bytes<generic>>:
    5ad0:	push   rbp
    5ad1:	mov    rbp,rsp
    5ad4:	mov    r9,QWORD PTR [rdx]
    5ad7:	mov    rcx,QWORD PTR [rdx+0x8]
    5adb:	mov    r8,QWORD PTR [rdx+0x10]
    5adf:	mov    rdx,r9
    5ae2:	call   5ae7 <botlish_entry_29+0x17>
			5ae3: R_X86_64_PLT32	botlish_fn_29-0x4 ; esc_bytes<generic>
    5ae7:	mov    rsp,rbp
    5aea:	pop    rbp
    5aeb:	ret

0000000000005aec <botlish_fn_30: esc_char<generic>>:
    5aec:	push   rbp
    5aed:	mov    rbp,rsp
    5af0:	sub    rsp,0x40
    5af4:	mov    QWORD PTR [rsp+0x10],rbx
    5af9:	mov    QWORD PTR [rsp+0x18],r12
    5afe:	mov    QWORD PTR [rsp+0x20],r13
    5b03:	mov    QWORD PTR [rsp+0x28],r14
    5b08:	mov    QWORD PTR [rsp+0x30],r15
    5b0d:	mov    rbx,rsi
    5b10:	mov    r12,QWORD PTR [rdi]
    5b13:	mov    rax,QWORD PTR [rdi+0x8]
    5b17:	lea    rcx,[r12+0x20]
    5b1c:	cmp    rcx,rax
    5b1f:	ja     5d42 <botlish_fn_30+0x256>
    5b25:	lea    rax,[r12+0x20]
    5b2a:	mov    QWORD PTR [rdi],rax
    5b2d:	mov    QWORD PTR [r12],0x0
    5b35:	mov    QWORD PTR [r12+0x8],0x0
    5b3e:	mov    QWORD PTR [r12+0x10],0x0
    5b47:	mov    QWORD PTR [r12+0x18],0x0
    5b50:	mov    QWORD PTR [r12],rdx
    5b54:	xor    eax,eax
    5b56:	test   rdx,0x7
    5b5d:	je     5b6b <botlish_fn_30+0x7f>
    5b63:	mov    r14,rdx
    5b66:	jmp    5b77 <botlish_fn_30+0x8b>
    5b6b:	movzx  rax,BYTE PTR [rdx]
    5b6f:	mov    r14,rdx
    5b72:	cmp    al,0x2
    5b74:	sete   al
    5b77:	test   al,al
    5b79:	jne    5ba2 <botlish_fn_30+0xb6>
    5b7f:	mov    rax,QWORD PTR [rdi+0x10]
    5b83:	mov    r13,rdi
    5b86:	mov    rcx,QWORD PTR [rax+0x130]
    5b8d:	mov    edx,0x1
    5b92:	mov    rsi,r14
    5b95:	call   5b9a <botlish_fn_30+0xae>
			5b96: R_X86_64_PLT32	rt_type_error-0x4
    5b9a:	mov    rdi,r13
    5b9d:	jmp    5ce4 <botlish_fn_30+0x1f8>
    5ba2:	mov    r13,rdi
    5ba5:	mov    rsi,r14
    5ba8:	call   5bad <botlish_fn_30+0xc1>
			5ba9: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    5bad:	mov    rcx,rax
    5bb0:	mov    r15,rax
    5bb3:	test   rax,rcx
    5bb6:	jne    5bc4 <botlish_fn_30+0xd8>
    5bbc:	mov    rdi,r13
    5bbf:	jmp    5ce4 <botlish_fn_30+0x1f8>
    5bc4:	mov    rax,r15
    5bc7:	mov    QWORD PTR [r12+0x8],rax
    5bcc:	mov    rsi,r15
    5bcf:	mov    rdi,r13
    5bd2:	call   5bd7 <botlish_fn_30+0xeb>
			5bd3: R_X86_64_PLT32	rt_list_len-0x4
    5bd7:	mov    ecx,0x1
    5bdc:	sar    rax,1
    5bdf:	cmp    rax,0x1
    5be3:	je     5c34 <botlish_fn_30+0x148>
    5be9:	mov    rsi,QWORD PTR [rbx+0x20]
    5bed:	mov    rsi,QWORD PTR [rsi]
    5bf0:	mov    QWORD PTR [r12],rsi
    5bf4:	mov    QWORD PTR [r12+0x10],0x1
    5bfd:	mov    rdi,r13
    5c00:	mov    rdi,QWORD PTR [rdi+0x10]
    5c04:	mov    r8,QWORD PTR [rdi+0x108]
    5c0b:	mov    QWORD PTR [r12+0x18],r8
    5c10:	mov    rdx,r15
    5c13:	mov    rdi,r13
    5c16:	call   5c1b <botlish_fn_30+0x12f>
			5c17: R_X86_64_PLT32	botlish_fn_29-0x4 ; esc_bytes<generic>
    5c1b:	test   rax,rax
    5c1e:	jne    5c2c <botlish_fn_30+0x140>
    5c24:	mov    rdi,r13
    5c27:	jmp    5ce4 <botlish_fn_30+0x1f8>
    5c2c:	mov    rdi,r13
    5c2f:	jmp    5d1a <botlish_fn_30+0x22e>
    5c34:	mov    rdx,r15
    5c37:	mov    QWORD PTR [rsp],rcx
    5c3b:	mov    r11,QWORD PTR [rdx+0x8]
    5c3f:	mov    r15,rdx
    5c42:	test   r11,r11
    5c45:	jne    5c73 <botlish_fn_30+0x187>
    5c4b:	mov    rdx,QWORD PTR [rsp]
    5c4f:	mov    rsi,r15
    5c52:	mov    rdi,r13
    5c55:	call   5c5a <botlish_fn_30+0x16e>
			5c56: R_X86_64_PLT32	rt_list_get-0x4
    5c5a:	test   rax,rax
    5c5d:	jne    5c6b <botlish_fn_30+0x17f>
    5c63:	mov    rdi,r13
    5c66:	jmp    5ce4 <botlish_fn_30+0x1f8>
    5c6b:	mov    rsi,rax
    5c6e:	jmp    5c7d <botlish_fn_30+0x191>
    5c73:	mov    rdx,r15
    5c76:	mov    rax,QWORD PTR [rdx+0x10]
    5c7a:	mov    rsi,QWORD PTR [rax]
    5c7d:	mov    QWORD PTR [r12+0x10],rsi
    5c82:	mov    rdi,r13
    5c85:	call   5c8a <botlish_fn_30+0x19e>
			5c86: R_X86_64_PLT32	botlish_fn_27-0x4 ; is_unreserved<generic>
    5c8a:	test   rax,rax
    5c8d:	jne    5c9b <botlish_fn_30+0x1af>
    5c93:	mov    rdi,r13
    5c96:	jmp    5ce4 <botlish_fn_30+0x1f8>
    5c9b:	cmp    rax,0x6
    5c9f:	je     5d14 <botlish_fn_30+0x228>
    5ca5:	mov    rax,QWORD PTR [rbx+0x20]
    5ca9:	mov    rsi,QWORD PTR [rax]
    5cac:	mov    QWORD PTR [r12],rsi
    5cb0:	mov    QWORD PTR [r12+0x10],0x1
    5cb9:	mov    rdi,r13
    5cbc:	mov    rax,QWORD PTR [rdi+0x10]
    5cc0:	mov    r8,QWORD PTR [rax+0x108]
    5cc7:	mov    QWORD PTR [r12+0x18],r8
    5ccc:	mov    rcx,QWORD PTR [rsp]
    5cd0:	mov    rdx,r15
    5cd3:	call   5cd8 <botlish_fn_30+0x1ec>
			5cd4: R_X86_64_PLT32	botlish_fn_29-0x4 ; esc_bytes<generic>
    5cd8:	test   rax,rax
    5cdb:	jne    5d17 <botlish_fn_30+0x22b>
    5ce1:	mov    rdi,r13
    5ce4:	mov    rdi,r13
    5ce7:	mov    QWORD PTR [rdi],r12
    5cea:	xor    rax,rax
    5ced:	mov    rbx,QWORD PTR [rsp+0x10]
    5cf2:	mov    r12,QWORD PTR [rsp+0x18]
    5cf7:	mov    r13,QWORD PTR [rsp+0x20]
    5cfc:	mov    r14,QWORD PTR [rsp+0x28]
    5d01:	mov    r15,QWORD PTR [rsp+0x30]
    5d06:	add    rsp,0x40
    5d0a:	mov    rsp,rbp
    5d0d:	pop    rbp
    5d0e:	ret
    5d0f:	jmp    5d17 <botlish_fn_30+0x22b>
    5d14:	mov    rax,r14
    5d17:	mov    rdi,r13
    5d1a:	mov    rdi,r13
    5d1d:	mov    QWORD PTR [rdi],r12
    5d20:	mov    rbx,QWORD PTR [rsp+0x10]
    5d25:	mov    r12,QWORD PTR [rsp+0x18]
    5d2a:	mov    r13,QWORD PTR [rsp+0x20]
    5d2f:	mov    r14,QWORD PTR [rsp+0x28]
    5d34:	mov    r15,QWORD PTR [rsp+0x30]
    5d39:	add    rsp,0x40
    5d3d:	mov    rsp,rbp
    5d40:	pop    rbp
    5d41:	ret
    5d42:	mov    r13,rdi
    5d45:	call   5d4a <botlish_fn_30+0x25e>
			5d46: R_X86_64_PLT32	rt_stack_overflow-0x4
    5d4a:	xor    rax,rax
    5d4d:	mov    rbx,QWORD PTR [rsp+0x10]
    5d52:	mov    r12,QWORD PTR [rsp+0x18]
    5d57:	mov    r13,QWORD PTR [rsp+0x20]
    5d5c:	mov    r14,QWORD PTR [rsp+0x28]
    5d61:	mov    r15,QWORD PTR [rsp+0x30]
    5d66:	add    rsp,0x40
    5d6a:	mov    rsp,rbp
    5d6d:	pop    rbp
    5d6e:	ret

0000000000005d6f <botlish_entry_30: esc_char<generic>>:
    5d6f:	push   rbp
    5d70:	mov    rbp,rsp
    5d73:	mov    rdx,QWORD PTR [rdx]
    5d76:	call   5d7b <botlish_entry_30+0xc>
			5d77: R_X86_64_PLT32	botlish_fn_30-0x4 ; esc_char<generic>
    5d7b:	mov    rsp,rbp
    5d7e:	pop    rbp
    5d7f:	ret

0000000000005d80 <botlish_fn_31: esc_from<generic>>:
    5d80:	push   rbp
    5d81:	mov    rbp,rsp
    5d84:	sub    rsp,0x50
    5d88:	mov    QWORD PTR [rsp+0x20],rbx
    5d8d:	mov    QWORD PTR [rsp+0x28],r12
    5d92:	mov    QWORD PTR [rsp+0x30],r13
    5d97:	mov    QWORD PTR [rsp+0x38],r14
    5d9c:	mov    QWORD PTR [rsp+0x40],r15
    5da1:	mov    r12,rsi
    5da4:	mov    r14,QWORD PTR [rdi]
    5da7:	mov    rax,QWORD PTR [rdi+0x8]
    5dab:	lea    rsi,[r14+0x38]
    5daf:	cmp    rsi,rax
    5db2:	ja     6144 <botlish_fn_31+0x3c4>
    5db8:	lea    rax,[r14+0x38]
    5dbc:	mov    QWORD PTR [rdi],rax
    5dbf:	mov    r15,rdi
    5dc2:	mov    QWORD PTR [r14],0x0
    5dc9:	mov    QWORD PTR [r14+0x8],0x0
    5dd1:	mov    QWORD PTR [r14+0x10],0x0
    5dd9:	mov    QWORD PTR [r14+0x18],0x0
    5de1:	mov    QWORD PTR [r14+0x20],0x0
    5de9:	mov    QWORD PTR [r14+0x28],0x0
    5df1:	mov    QWORD PTR [r14+0x30],0x0
    5df9:	mov    QWORD PTR [r14],rdx
    5dfc:	mov    QWORD PTR [r14+0x8],rcx
    5e00:	mov    QWORD PTR [r14+0x10],r8
    5e04:	mov    QWORD PTR [rsp],rcx
    5e08:	mov    QWORD PTR [rsp+0x8],r8
    5e0d:	xor    eax,eax
    5e0f:	test   rdx,0x7
    5e16:	je     5e24 <botlish_fn_31+0xa4>
    5e1c:	mov    rsi,rdx
    5e1f:	jmp    5e30 <botlish_fn_31+0xb0>
    5e24:	movzx  rax,BYTE PTR [rdx]
    5e28:	mov    rsi,rdx
    5e2b:	cmp    al,0x2
    5e2d:	sete   al
    5e30:	test   al,al
    5e32:	jne    5e55 <botlish_fn_31+0xd5>
    5e38:	mov    rdi,r15
    5e3b:	mov    rax,QWORD PTR [rdi+0x10]
    5e3f:	mov    rcx,QWORD PTR [rax+0x48]
    5e43:	mov    edx,0x1
    5e48:	call   5e4d <botlish_fn_31+0xcd>
			5e49: R_X86_64_PLT32	rt_type_error-0x4
    5e4d:	mov    rdi,r15
    5e50:	jmp    60d0 <botlish_fn_31+0x350>
    5e55:	mov    rbx,rsi
    5e58:	mov    rdi,r15
    5e5b:	call   5e60 <botlish_fn_31+0xe0>
			5e5c: R_X86_64_PLT32	rt_str_len-0x4
    5e60:	mov    edx,0x1
    5e65:	mov    QWORD PTR [rsp+0x18],rdx
    5e6a:	mov    ecx,0x1
    5e6f:	mov    rsi,QWORD PTR [rsp]
    5e73:	test   rsi,0x1
    5e7a:	jne    5ea2 <botlish_fn_31+0x122>
    5e80:	xor    ecx,ecx
    5e82:	mov    rsi,QWORD PTR [rsp]
    5e86:	test   rsi,0x7
    5e8d:	jne    5ea2 <botlish_fn_31+0x122>
    5e93:	mov    rsi,QWORD PTR [rsp]
    5e97:	movzx  rcx,BYTE PTR [rsi]
    5e9b:	rex cmp cl,0x1
    5e9f:	sete   cl
    5ea2:	test   cl,cl
    5ea4:	jne    5ecc <botlish_fn_31+0x14c>
    5eaa:	mov    rdi,r15
    5ead:	mov    rax,QWORD PTR [rdi+0x10]
    5eb1:	mov    rcx,QWORD PTR [rax+0x80]
    5eb8:	xor    rdx,rdx
    5ebb:	mov    rsi,QWORD PTR [rsp]
    5ebf:	call   5ec4 <botlish_fn_31+0x144>
			5ec0: R_X86_64_PLT32	rt_type_error-0x4
    5ec4:	mov    rdi,r15
    5ec7:	jmp    60d0 <botlish_fn_31+0x350>
    5ecc:	mov    rsi,QWORD PTR [rsp]
    5ed0:	mov    rcx,rsi
    5ed3:	and    rcx,rax
    5ed6:	mov    rdx,rax
    5ed9:	test   rcx,0x1
    5ee0:	jne    5f08 <botlish_fn_31+0x188>
    5ee6:	mov    rsi,QWORD PTR [rsp]
    5eea:	mov    rdi,r15
    5eed:	call   5ef2 <botlish_fn_31+0x172>
			5eee: R_X86_64_PLT32	rt_int_cmp-0x4
    5ef2:	mov    r8d,0x2
    5ef8:	test   rax,rax
    5efb:	cmovge r8,QWORD PTR [rip+0x275]        # 6178 <botlish_fn_31+0x3f8>
    5f03:	jmp    5f1d <botlish_fn_31+0x19d>
    5f08:	mov    r8d,0x2
    5f0e:	mov    rsi,QWORD PTR [rsp]
    5f12:	cmp    rsi,rdx
    5f15:	cmovge r8,QWORD PTR [rip+0x25b]        # 6178 <botlish_fn_31+0x3f8>
    5f1d:	cmp    r8,0x6
    5f21:	je     6117 <botlish_fn_31+0x397>
    5f27:	mov    QWORD PTR [r14+0x18],r12
    5f2b:	mov    QWORD PTR [r14+0x20],0x3
    5f33:	mov    rsi,QWORD PTR [rsp]
    5f37:	test   rsi,0x1
    5f3e:	je     5f65 <botlish_fn_31+0x1e5>
    5f44:	mov    rsi,QWORD PTR [rsp]
    5f48:	mov    rax,rsi
    5f4b:	add    rax,0x2
    5f4f:	mov    rcx,rax
    5f52:	seto   al
    5f55:	test   al,al
    5f57:	jne    5f65 <botlish_fn_31+0x1e5>
    5f5d:	mov    r13,rcx
    5f60:	jmp    5f7c <botlish_fn_31+0x1fc>
    5f65:	mov    edx,0x3
    5f6a:	mov    rsi,QWORD PTR [rsp]
    5f6e:	mov    rdi,r15
    5f71:	call   5f76 <botlish_fn_31+0x1f6>
			5f72: R_X86_64_PLT32	rt_int_add-0x4
    5f76:	mov    rcx,rax
    5f79:	mov    r13,rcx
    5f7c:	mov    QWORD PTR [r14+0x20],r13
    5f80:	mov    rdx,QWORD PTR [r12+0x20]
    5f85:	mov    rsi,QWORD PTR [rdx]
    5f88:	mov    QWORD PTR [r14+0x28],rsi
    5f8c:	mov    QWORD PTR [rsp+0x10],rsi
    5f91:	mov    QWORD PTR [r14+0x30],0x3
    5f99:	mov    rsi,QWORD PTR [rsp]
    5f9d:	test   rsi,0x1
    5fa4:	je     5fc2 <botlish_fn_31+0x242>
    5faa:	mov    rsi,QWORD PTR [rsp]
    5fae:	mov    rcx,rsi
    5fb1:	add    rcx,0x2
    5fb5:	seto   r8b
    5fb9:	test   r8b,r8b
    5fbc:	je     5fd6 <botlish_fn_31+0x256>
    5fc2:	mov    edx,0x3
    5fc7:	mov    rsi,QWORD PTR [rsp]
    5fcb:	mov    rdi,r15
    5fce:	call   5fd3 <botlish_fn_31+0x253>
			5fcf: R_X86_64_PLT32	rt_int_add-0x4
    5fd3:	mov    rcx,rax
    5fd6:	mov    QWORD PTR [r14+0x30],rcx
    5fda:	mov    rdx,QWORD PTR [rsp]
    5fde:	mov    rsi,rbx
    5fe1:	mov    rdi,r15
    5fe4:	call   5fe9 <botlish_fn_31+0x269>
			5fe5: R_X86_64_PLT32	rt_substr-0x4
    5fe9:	test   rax,rax
    5fec:	jne    5ffa <botlish_fn_31+0x27a>
    5ff2:	mov    rdi,r15
    5ff5:	jmp    60d0 <botlish_fn_31+0x350>
    5ffa:	mov    QWORD PTR [r14+0x8],rax
    5ffe:	mov    rdx,rax
    6001:	mov    rsi,QWORD PTR [rsp+0x10]
    6006:	mov    rdi,r15
    6009:	call   600e <botlish_fn_31+0x28e>
			600a: R_X86_64_PLT32	botlish_fn_30-0x4 ; esc_char<generic>
    600e:	test   rax,rax
    6011:	jne    601f <botlish_fn_31+0x29f>
    6017:	mov    rdi,r15
    601a:	jmp    60d0 <botlish_fn_31+0x350>
    601f:	mov    QWORD PTR [r14+0x8],rax
    6023:	xor    ecx,ecx
    6025:	mov    rsi,QWORD PTR [rsp+0x8]
    602a:	test   rsi,0x7
    6031:	jne    6042 <botlish_fn_31+0x2c2>
    6037:	movzx  rcx,BYTE PTR [rsi]
    603b:	rex cmp cl,0x2
    603f:	sete   cl
    6042:	test   cl,cl
    6044:	jne    606a <botlish_fn_31+0x2ea>
    604a:	mov    rdi,r15
    604d:	mov    rax,QWORD PTR [rdi+0x10]
    6051:	mov    rcx,QWORD PTR [rax+0x128]
    6058:	mov    rdx,QWORD PTR [rsp+0x18]
    605d:	call   6062 <botlish_fn_31+0x2e2>
			605e: R_X86_64_PLT32	rt_type_error-0x4
    6062:	mov    rdi,r15
    6065:	jmp    60d0 <botlish_fn_31+0x350>
    606a:	mov    rdx,QWORD PTR [rsp+0x18]
    606f:	xor    ecx,ecx
    6071:	test   rax,0x7
    6077:	je     6085 <botlish_fn_31+0x305>
    607d:	mov    r8,rax
    6080:	jmp    6093 <botlish_fn_31+0x313>
    6085:	movzx  rcx,BYTE PTR [rax]
    6089:	mov    r8,rax
    608c:	rex cmp cl,0x2
    6090:	sete   cl
    6093:	test   cl,cl
    6095:	jne    60b9 <botlish_fn_31+0x339>
    609b:	mov    rdi,r15
    609e:	mov    rax,QWORD PTR [rdi+0x10]
    60a2:	mov    rcx,QWORD PTR [rax+0x128]
    60a9:	mov    rsi,r8
    60ac:	call   60b1 <botlish_fn_31+0x331>
			60ad: R_X86_64_PLT32	rt_type_error-0x4
    60b1:	mov    rdi,r15
    60b4:	jmp    60d0 <botlish_fn_31+0x350>
    60b9:	mov    rdx,r8
    60bc:	mov    rdi,r15
    60bf:	call   60c4 <botlish_fn_31+0x344>
			60c0: R_X86_64_PLT32	rt_str_cat-0x4
    60c4:	test   rax,rax
    60c7:	jne    60fb <botlish_fn_31+0x37b>
    60cd:	mov    rdi,r15
    60d0:	mov    rdi,r15
    60d3:	mov    QWORD PTR [rdi],r14
    60d6:	xor    rax,rax
    60d9:	mov    rbx,QWORD PTR [rsp+0x20]
    60de:	mov    r12,QWORD PTR [rsp+0x28]
    60e3:	mov    r13,QWORD PTR [rsp+0x30]
    60e8:	mov    r14,QWORD PTR [rsp+0x38]
    60ed:	mov    r15,QWORD PTR [rsp+0x40]
    60f2:	add    rsp,0x50
    60f6:	mov    rsp,rbp
    60f9:	pop    rbp
    60fa:	ret
    60fb:	mov    QWORD PTR [r14],rbx
    60fe:	mov    QWORD PTR [r14+0x8],r13
    6102:	mov    QWORD PTR [r14+0x10],rax
    6106:	mov    rdx,rbx
    6109:	mov    QWORD PTR [rsp],r13
    610d:	mov    QWORD PTR [rsp+0x8],rax
    6112:	jmp    5e0d <botlish_fn_31+0x8d>
    6117:	mov    rdi,r15
    611a:	mov    QWORD PTR [rdi],r14
    611d:	mov    rax,QWORD PTR [rsp+0x8]
    6122:	mov    rbx,QWORD PTR [rsp+0x20]
    6127:	mov    r12,QWORD PTR [rsp+0x28]
    612c:	mov    r13,QWORD PTR [rsp+0x30]
    6131:	mov    r14,QWORD PTR [rsp+0x38]
    6136:	mov    r15,QWORD PTR [rsp+0x40]
    613b:	add    rsp,0x50
    613f:	mov    rsp,rbp
    6142:	pop    rbp
    6143:	ret
    6144:	mov    r15,rdi
    6147:	call   614c <botlish_fn_31+0x3cc>
			6148: R_X86_64_PLT32	rt_stack_overflow-0x4
    614c:	xor    rax,rax
    614f:	mov    rbx,QWORD PTR [rsp+0x20]
    6154:	mov    r12,QWORD PTR [rsp+0x28]
    6159:	mov    r13,QWORD PTR [rsp+0x30]
    615e:	mov    r14,QWORD PTR [rsp+0x38]
    6163:	mov    r15,QWORD PTR [rsp+0x40]
    6168:	add    rsp,0x50
    616c:	mov    rsp,rbp
    616f:	pop    rbp
    6170:	ret
    6171:	add    BYTE PTR [rax],al
    6173:	add    BYTE PTR [rax],al
    6175:	add    BYTE PTR [rax],al
    6177:	add    BYTE PTR [rsi],al
    6179:	add    BYTE PTR [rax],al
    617b:	add    BYTE PTR [rax],al
    617d:	add    BYTE PTR [rax],al
	...

0000000000006180 <botlish_entry_31: esc_from<generic>>:
    6180:	push   rbp
    6181:	mov    rbp,rsp
    6184:	mov    r9,QWORD PTR [rdx]
    6187:	mov    rcx,QWORD PTR [rdx+0x8]
    618b:	mov    r8,QWORD PTR [rdx+0x10]
    618f:	mov    rdx,r9
    6192:	call   6197 <botlish_entry_31+0x17>
			6193: R_X86_64_PLT32	botlish_fn_31-0x4 ; esc_from<generic>
    6197:	mov    rsp,rbp
    619a:	pop    rbp
    619b:	ret

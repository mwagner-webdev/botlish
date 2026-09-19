; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 23770  (per function: 1061 468 1713 1425 672 1036 685 1084 600 1289 1361 500 520 401 165 609 609 609 673 777 1289 1361 500 520 401 165 609 609 609 673 777)
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
       4:	sub    rsp,0x100
       b:	mov    QWORD PTR [rsp+0xd0],rbx
      13:	mov    QWORD PTR [rsp+0xd8],r12
      1b:	mov    QWORD PTR [rsp+0xe0],r13
      23:	mov    QWORD PTR [rsp+0xe8],r14
      2b:	mov    QWORD PTR [rsp+0xf0],r15
      33:	mov    r13,QWORD PTR [rdi]
      36:	mov    rdx,QWORD PTR [rdi+0x8]
      3a:	lea    rsi,[r13+0x80]
      41:	cmp    rsi,rdx
      44:	ja     3bb <botlish_fn_0+0x3bb>
      4a:	lea    rsi,[r13+0x80]
      51:	mov    QWORD PTR [rdi],rsi
      54:	mov    rsi,QWORD PTR [rdi+0x10]
      58:	mov    r8,QWORD PTR [rsi]
      5b:	mov    QWORD PTR [r13+0x0],r8
      5f:	mov    QWORD PTR [rsp+0xc0],r8
      67:	mov    r8,QWORD PTR [rdi+0x10]
      6b:	mov    r9,QWORD PTR [r8+0x8]
      6f:	mov    QWORD PTR [r13+0x8],r9
      73:	mov    QWORD PTR [rsp+0xb8],r9
      7b:	mov    r8,QWORD PTR [rdi+0x10]
      7f:	mov    r10,QWORD PTR [r8+0x10]
      83:	mov    QWORD PTR [r13+0x10],r10
      87:	mov    QWORD PTR [rsp+0xb0],r10
      8f:	mov    r9,QWORD PTR [rdi+0x10]
      93:	mov    r11,QWORD PTR [r9+0x18]
      97:	mov    QWORD PTR [r13+0x18],r11
      9b:	mov    QWORD PTR [rsp+0xa8],r11
      a3:	mov    r10,QWORD PTR [rdi+0x10]
      a7:	mov    rcx,QWORD PTR [r10+0x20]
      ab:	mov    QWORD PTR [r13+0x20],rcx
      af:	mov    QWORD PTR [rsp+0xa0],rcx
      b7:	mov    rax,QWORD PTR [rdi+0x10]
      bb:	mov    rcx,QWORD PTR [rax+0x28]
      bf:	mov    QWORD PTR [r13+0x28],rcx
      c3:	mov    rax,QWORD PTR [rdi+0x10]
      c7:	mov    r10,QWORD PTR [rax+0x30]
      cb:	mov    QWORD PTR [r13+0x30],r10
      cf:	mov    rax,QWORD PTR [rdi+0x10]
      d3:	mov    rax,QWORD PTR [rax+0x38]
      d7:	mov    QWORD PTR [r13+0x38],rax
      db:	mov    rdx,QWORD PTR [rdi+0x10]
      df:	mov    r14,QWORD PTR [rdx+0x40]
      e3:	mov    QWORD PTR [r13+0x40],r14
      e7:	mov    rdx,QWORD PTR [rdi+0x10]
      eb:	mov    r15,QWORD PTR [rdx+0x48]
      ef:	mov    QWORD PTR [r13+0x48],r15
      f3:	mov    rdx,QWORD PTR [rdi+0x10]
      f7:	mov    rbx,QWORD PTR [rdx+0x50]
      fb:	mov    QWORD PTR [r13+0x50],rbx
      ff:	mov    rdx,QWORD PTR [rdi+0x10]
     103:	mov    r12,QWORD PTR [rdx+0x58]
     107:	mov    QWORD PTR [r13+0x58],r12
     10b:	mov    rdx,QWORD PTR [rdi+0x10]
     10f:	mov    rsi,QWORD PTR [rdx+0x60]
     113:	mov    QWORD PTR [r13+0x60],rsi
     117:	mov    rdx,QWORD PTR [rdi+0x10]
     11b:	mov    r8,QWORD PTR [rdx+0x68]
     11f:	mov    QWORD PTR [r13+0x68],r8
     123:	mov    rdx,QWORD PTR [rdi+0x10]
     127:	mov    r9,QWORD PTR [rdx+0x70]
     12b:	mov    QWORD PTR [r13+0x70],r9
     12f:	mov    rdx,QWORD PTR [rdi+0x10]
     133:	mov    QWORD PTR [rsp+0x98],rdi
     13b:	mov    rdi,QWORD PTR [rdx+0x78]
     13f:	mov    QWORD PTR [r13+0x78],rdi
     143:	lea    rdx,[rsp]
     147:	mov    r11,QWORD PTR [rsp+0xc0]
     14f:	mov    QWORD PTR [rsp],r11
     153:	mov    r11,QWORD PTR [rsp+0xb8]
     15b:	mov    QWORD PTR [rsp+0x8],r11
     160:	mov    r11,QWORD PTR [rsp+0xb0]
     168:	mov    QWORD PTR [rsp+0x10],r11
     16d:	mov    r11,QWORD PTR [rsp+0xa8]
     175:	mov    QWORD PTR [rsp+0x18],r11
     17a:	mov    r11,QWORD PTR [rsp+0xa0]
     182:	mov    QWORD PTR [rsp+0x20],r11
     187:	mov    QWORD PTR [rsp+0x28],rcx
     18c:	mov    QWORD PTR [rsp+0x30],r10
     191:	mov    QWORD PTR [rsp+0x38],rax
     196:	mov    QWORD PTR [rsp+0x40],r14
     19b:	mov    QWORD PTR [rsp+0x48],r15
     1a0:	mov    QWORD PTR [rsp+0x50],rbx
     1a5:	mov    QWORD PTR [rsp+0x58],r12
     1aa:	mov    QWORD PTR [rsp+0x60],rsi
     1af:	mov    QWORD PTR [rsp+0x68],r8
     1b4:	mov    QWORD PTR [rsp+0x70],r9
     1b9:	mov    QWORD PTR [rsp+0x78],rdi
     1be:	mov    esi,0x10
     1c3:	mov    rdi,QWORD PTR [rsp+0x98]
     1cb:	call   1d0 <botlish_fn_0+0x1d0>
			1cc: R_X86_64_PLT32	rt_list_new-0x4
     1d0:	test   rax,rax
     1d3:	jne    1e6 <botlish_fn_0+0x1e6>
     1d9:	mov    rdi,QWORD PTR [rsp+0x98]
     1e1:	jmp    33a <botlish_fn_0+0x33a>
     1e6:	mov    QWORD PTR [r13+0x0],rax
     1ea:	lea    r8,[rsp+0x80]
     1f2:	mov    QWORD PTR [rsp+0x80],rax
     1fa:	mov    ecx,0x1
     1ff:	mov    rdx,QWORD PTR [rip+0x0]        # 206 <botlish_fn_0+0x206>
			202: R_X86_64_GOTPCREL	botlish_entry_1-0x4 ; web::uri_escape_text<generic>
     206:	mov    rdi,QWORD PTR [rsp+0x98]
     20e:	mov    rsi,rcx
     211:	call   216 <botlish_fn_0+0x216>
			212: R_X86_64_PLT32	rt_closure_new-0x4
     216:	mov    QWORD PTR [r13+0x0],rax
     21a:	mov    rdi,QWORD PTR [rsp+0x98]
     222:	mov    rcx,QWORD PTR [rdi+0x10]
     226:	mov    rdx,QWORD PTR [rcx+0x80]
     22d:	mov    QWORD PTR [r13+0x8],rdx
     231:	mov    rsi,rax
     234:	call   239 <botlish_fn_0+0x239>
			235: R_X86_64_PLT32	botlish_fn_1-0x4 ; web::uri_escape_text<generic>
     239:	test   rax,rax
     23c:	jne    24f <botlish_fn_0+0x24f>
     242:	mov    rdi,QWORD PTR [rsp+0x98]
     24a:	jmp    33a <botlish_fn_0+0x33a>
     24f:	mov    QWORD PTR [r13+0x0],rax
     253:	mov    r12,rax
     256:	mov    esi,0x321
     25b:	mov    QWORD PTR [r13+0x8],0x321
     263:	mov    edx,0x1
     268:	mov    QWORD PTR [r13+0x10],0x1
     270:	mov    rdi,QWORD PTR [rsp+0x98]
     278:	mov    rcx,QWORD PTR [rdi+0x10]
     27c:	mov    rcx,QWORD PTR [rcx+0x88]
     283:	mov    QWORD PTR [r13+0x18],rcx
     287:	mov    r8,r12
     28a:	call   28f <botlish_fn_0+0x28f>
			28b: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
     28f:	mov    rbx,rax
     292:	test   rbx,rbx
     295:	jne    2a8 <botlish_fn_0+0x2a8>
     29b:	mov    rdi,QWORD PTR [rsp+0x98]
     2a3:	jmp    33a <botlish_fn_0+0x33a>
     2a8:	mov    QWORD PTR [r13+0x8],rbx
     2ac:	mov    esi,0x321
     2b1:	mov    QWORD PTR [r13+0x10],0x321
     2b9:	mov    edx,0x1
     2be:	mov    QWORD PTR [r13+0x18],0x1
     2c6:	mov    rdi,QWORD PTR [rsp+0x98]
     2ce:	mov    rax,QWORD PTR [rdi+0x10]
     2d2:	mov    rcx,QWORD PTR [rax+0x90]
     2d9:	mov    QWORD PTR [r13+0x20],rcx
     2dd:	mov    r8,r12
     2e0:	call   2e5 <botlish_fn_0+0x2e5>
			2e1: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
     2e5:	test   rax,rax
     2e8:	jne    2fb <botlish_fn_0+0x2fb>
     2ee:	mov    rdi,QWORD PTR [rsp+0x98]
     2f6:	jmp    33a <botlish_fn_0+0x33a>
     2fb:	mov    QWORD PTR [r13+0x0],rax
     2ff:	lea    rdx,[rsp+0x88]
     307:	mov    QWORD PTR [rsp+0x88],rbx
     30f:	mov    QWORD PTR [rsp+0x90],rax
     317:	mov    esi,0x2
     31c:	mov    rdi,QWORD PTR [rsp+0x98]
     324:	call   329 <botlish_fn_0+0x329>
			325: R_X86_64_PLT32	rt_list_new-0x4
     329:	test   rax,rax
     32c:	jne    37c <botlish_fn_0+0x37c>
     332:	mov    rdi,QWORD PTR [rsp+0x98]
     33a:	mov    rdi,QWORD PTR [rsp+0x98]
     342:	mov    QWORD PTR [rdi],r13
     345:	xor    rax,rax
     348:	mov    rbx,QWORD PTR [rsp+0xd0]
     350:	mov    r12,QWORD PTR [rsp+0xd8]
     358:	mov    r13,QWORD PTR [rsp+0xe0]
     360:	mov    r14,QWORD PTR [rsp+0xe8]
     368:	mov    r15,QWORD PTR [rsp+0xf0]
     370:	add    rsp,0x100
     377:	mov    rsp,rbp
     37a:	pop    rbp
     37b:	ret
     37c:	mov    rdi,QWORD PTR [rsp+0x98]
     384:	mov    QWORD PTR [rdi],r13
     387:	mov    rbx,QWORD PTR [rsp+0xd0]
     38f:	mov    r12,QWORD PTR [rsp+0xd8]
     397:	mov    r13,QWORD PTR [rsp+0xe0]
     39f:	mov    r14,QWORD PTR [rsp+0xe8]
     3a7:	mov    r15,QWORD PTR [rsp+0xf0]
     3af:	add    rsp,0x100
     3b6:	mov    rsp,rbp
     3b9:	pop    rbp
     3ba:	ret
     3bb:	mov    QWORD PTR [rsp+0x98],rdi
     3c3:	call   3c8 <botlish_fn_0+0x3c8>
			3c4: R_X86_64_PLT32	rt_stack_overflow-0x4
     3c8:	xor    rax,rax
     3cb:	mov    rbx,QWORD PTR [rsp+0xd0]
     3d3:	mov    r12,QWORD PTR [rsp+0xd8]
     3db:	mov    r13,QWORD PTR [rsp+0xe0]
     3e3:	mov    r14,QWORD PTR [rsp+0xe8]
     3eb:	mov    r15,QWORD PTR [rsp+0xf0]
     3f3:	add    rsp,0x100
     3fa:	mov    rsp,rbp
     3fd:	pop    rbp
     3fe:	ret

00000000000003ff <botlish_entry_0: <program entry>>:
     3ff:	push   rbp
     400:	mov    rbp,rsp
     403:	call   408 <botlish_entry_0+0x9>
			404: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     408:	mov    rsp,rbp
     40b:	pop    rbp
     40c:	ret

000000000000040d <botlish_fn_1: web::uri_escape_text<generic>>:
     40d:	push   rbp
     40e:	mov    rbp,rsp
     411:	sub    rsp,0x40
     415:	mov    QWORD PTR [rsp+0x20],rbx
     41a:	mov    QWORD PTR [rsp+0x28],r12
     41f:	mov    QWORD PTR [rsp+0x30],r13
     424:	mov    QWORD PTR [rsp+0x38],r14
     429:	mov    r12,QWORD PTR [rdi]
     42c:	mov    rax,QWORD PTR [rdi+0x8]
     430:	lea    rcx,[r12+0x20]
     435:	cmp    rcx,rax
     438:	ja     585 <botlish_fn_1+0x178>
     43e:	lea    rax,[r12+0x20]
     443:	mov    QWORD PTR [rdi],rax
     446:	mov    r13,rdi
     449:	mov    QWORD PTR [r12+0x10],0x0
     452:	mov    QWORD PTR [r12+0x18],0x0
     45b:	mov    QWORD PTR [r12],rdx
     45f:	mov    r14,rdx
     462:	mov    rax,QWORD PTR [rsi+0x20]
     466:	mov    rax,QWORD PTR [rax]
     469:	mov    QWORD PTR [r12+0x8],rax
     46e:	lea    r8,[rsp]
     472:	mov    QWORD PTR [rsp],rax
     476:	mov    esi,0x4
     47b:	mov    rdx,QWORD PTR [rip+0x0]        # 482 <botlish_fn_1+0x75>
			47e: R_X86_64_GOTPCREL	botlish_entry_4-0x4 ; hex_pair<generic>
     482:	mov    ebx,0x1
     487:	mov    rcx,rbx
     48a:	mov    rdi,r13
     48d:	call   492 <botlish_fn_1+0x85>
			48e: R_X86_64_PLT32	rt_closure_new-0x4
     492:	mov    QWORD PTR [r12+0x8],rax
     497:	lea    r8,[rsp+0x8]
     49c:	mov    QWORD PTR [rsp+0x8],rax
     4a1:	mov    esi,0x5
     4a6:	mov    rdx,QWORD PTR [rip+0x0]        # 4ad <botlish_fn_1+0xa0>
			4a9: R_X86_64_GOTPCREL	botlish_entry_5-0x4 ; esc_bytes<generic>
     4ad:	mov    rcx,rbx
     4b0:	mov    rdi,r13
     4b3:	call   4b8 <botlish_fn_1+0xab>
			4b4: R_X86_64_PLT32	rt_closure_new-0x4
     4b8:	mov    QWORD PTR [r12+0x8],rax
     4bd:	lea    r8,[rsp+0x10]
     4c2:	mov    QWORD PTR [rsp+0x10],rax
     4c7:	mov    esi,0x6
     4cc:	mov    rdx,QWORD PTR [rip+0x0]        # 4d3 <botlish_fn_1+0xc6>
			4cf: R_X86_64_GOTPCREL	botlish_entry_6-0x4 ; esc_char<generic>
     4d3:	mov    rcx,rbx
     4d6:	mov    rdi,r13
     4d9:	call   4de <botlish_fn_1+0xd1>
			4da: R_X86_64_PLT32	rt_closure_new-0x4
     4de:	mov    QWORD PTR [r12+0x8],rax
     4e3:	lea    r8,[rsp+0x18]
     4e8:	mov    QWORD PTR [rsp+0x18],rax
     4ed:	mov    esi,0x7
     4f2:	mov    rdx,QWORD PTR [rip+0x0]        # 4f9 <botlish_fn_1+0xec>
			4f5: R_X86_64_GOTPCREL	botlish_entry_7-0x4 ; esc_from<generic>
     4f9:	mov    rcx,rbx
     4fc:	mov    rdi,r13
     4ff:	call   504 <botlish_fn_1+0xf7>
			500: R_X86_64_PLT32	rt_closure_new-0x4
     504:	mov    QWORD PTR [r12+0x8],rax
     509:	mov    QWORD PTR [r12+0x10],0x1
     512:	mov    rdi,r13
     515:	mov    rcx,QWORD PTR [rdi+0x10]
     519:	mov    r8,QWORD PTR [rcx+0x98]
     520:	mov    QWORD PTR [r12+0x18],r8
     525:	mov    rcx,rbx
     528:	mov    rdx,r14
     52b:	mov    rsi,rax
     52e:	call   533 <botlish_fn_1+0x126>
			52f: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
     533:	test   rax,rax
     536:	jne    562 <botlish_fn_1+0x155>
     53c:	mov    rdi,r13
     53f:	mov    QWORD PTR [rdi],r12
     542:	xor    rax,rax
     545:	mov    rbx,QWORD PTR [rsp+0x20]
     54a:	mov    r12,QWORD PTR [rsp+0x28]
     54f:	mov    r13,QWORD PTR [rsp+0x30]
     554:	mov    r14,QWORD PTR [rsp+0x38]
     559:	add    rsp,0x40
     55d:	mov    rsp,rbp
     560:	pop    rbp
     561:	ret
     562:	mov    rdi,r13
     565:	mov    QWORD PTR [rdi],r12
     568:	mov    rbx,QWORD PTR [rsp+0x20]
     56d:	mov    r12,QWORD PTR [rsp+0x28]
     572:	mov    r13,QWORD PTR [rsp+0x30]
     577:	mov    r14,QWORD PTR [rsp+0x38]
     57c:	add    rsp,0x40
     580:	mov    rsp,rbp
     583:	pop    rbp
     584:	ret
     585:	mov    r13,rdi
     588:	call   58d <botlish_fn_1+0x180>
			589: R_X86_64_PLT32	rt_stack_overflow-0x4
     58d:	xor    rax,rax
     590:	mov    rbx,QWORD PTR [rsp+0x20]
     595:	mov    r12,QWORD PTR [rsp+0x28]
     59a:	mov    r13,QWORD PTR [rsp+0x30]
     59f:	mov    r14,QWORD PTR [rsp+0x38]
     5a4:	add    rsp,0x40
     5a8:	mov    rsp,rbp
     5ab:	pop    rbp
     5ac:	ret

00000000000005ad <botlish_entry_1: web::uri_escape_text<generic>>:
     5ad:	push   rbp
     5ae:	mov    rbp,rsp
     5b1:	mov    rdx,QWORD PTR [rdx]
     5b4:	call   5b9 <botlish_entry_1+0xc>
			5b5: R_X86_64_PLT32	botlish_fn_1-0x4 ; web::uri_escape_text<generic>
     5b9:	mov    rsp,rbp
     5bc:	pop    rbp
     5bd:	ret
	...

00000000000005c0 <botlish_fn_2: high_nibble<generic>>:
     5c0:	push   rbp
     5c1:	mov    rbp,rsp
     5c4:	sub    rsp,0x10
     5c8:	mov    QWORD PTR [rsp],rbx
     5cc:	mov    QWORD PTR [rsp+0x8],r12
     5d1:	mov    r8d,0x1
     5d7:	test   rsi,0x1
     5de:	jne    5fe <botlish_fn_2+0x3e>
     5e4:	xor    r8d,r8d
     5e7:	test   rsi,0x7
     5ee:	jne    5fe <botlish_fn_2+0x3e>
     5f4:	movzx  rax,BYTE PTR [rsi]
     5f8:	cmp    al,0x1
     5fa:	sete   r8b
     5fe:	test   r8b,r8b
     601:	jne    632 <botlish_fn_2+0x72>
     607:	mov    rax,QWORD PTR [rdi+0x10]
     60b:	mov    rcx,QWORD PTR [rax+0xa0]
     612:	xor    rbx,rbx
     615:	mov    rdx,rbx
     618:	call   61d <botlish_fn_2+0x5d>
			619: R_X86_64_PLT32	rt_type_error-0x4
     61d:	mov    rax,rbx
     620:	mov    rbx,QWORD PTR [rsp]
     624:	mov    r12,QWORD PTR [rsp+0x8]
     629:	add    rsp,0x10
     62d:	mov    rsp,rbp
     630:	pop    rbp
     631:	ret
     632:	mov    r12,rdi
     635:	test   rsi,0x1
     63c:	mov    rbx,rsi
     63f:	jne    66a <botlish_fn_2+0xaa>
     645:	mov    edx,0x1f
     64a:	mov    rsi,rbx
     64d:	mov    rdi,r12
     650:	call   655 <botlish_fn_2+0x95>
			651: R_X86_64_PLT32	rt_int_cmp-0x4
     655:	mov    ecx,0x2
     65a:	test   rax,rax
     65d:	cmovle rcx,QWORD PTR [rip+0x583]        # be8 <botlish_fn_2+0x628>
     665:	jmp    67e <botlish_fn_2+0xbe>
     66a:	mov    ecx,0x2
     66f:	mov    rsi,rbx
     672:	cmp    rsi,0x1f
     676:	cmovle rcx,QWORD PTR [rip+0x56a]        # be8 <botlish_fn_2+0x628>
     67e:	cmp    rcx,0x6
     682:	je     bcb <botlish_fn_2+0x60b>
     688:	mov    rsi,rbx
     68b:	test   rsi,0x1
     692:	jne    6bd <botlish_fn_2+0xfd>
     698:	mov    edx,0x3f
     69d:	mov    rsi,rbx
     6a0:	mov    rdi,r12
     6a3:	call   6a8 <botlish_fn_2+0xe8>
			6a4: R_X86_64_PLT32	rt_int_cmp-0x4
     6a8:	mov    ecx,0x2
     6ad:	test   rax,rax
     6b0:	cmovle rcx,QWORD PTR [rip+0x530]        # be8 <botlish_fn_2+0x628>
     6b8:	jmp    6d1 <botlish_fn_2+0x111>
     6bd:	mov    ecx,0x2
     6c2:	mov    rsi,rbx
     6c5:	cmp    rsi,0x3f
     6c9:	cmovle rcx,QWORD PTR [rip+0x517]        # be8 <botlish_fn_2+0x628>
     6d1:	cmp    rcx,0x6
     6d5:	je     bc1 <botlish_fn_2+0x601>
     6db:	mov    rsi,rbx
     6de:	test   rsi,0x1
     6e5:	jne    710 <botlish_fn_2+0x150>
     6eb:	mov    edx,0x5f
     6f0:	mov    rsi,rbx
     6f3:	mov    rdi,r12
     6f6:	call   6fb <botlish_fn_2+0x13b>
			6f7: R_X86_64_PLT32	rt_int_cmp-0x4
     6fb:	mov    ecx,0x2
     700:	test   rax,rax
     703:	cmovle rcx,QWORD PTR [rip+0x4dd]        # be8 <botlish_fn_2+0x628>
     70b:	jmp    724 <botlish_fn_2+0x164>
     710:	mov    ecx,0x2
     715:	mov    rsi,rbx
     718:	cmp    rsi,0x5f
     71c:	cmovle rcx,QWORD PTR [rip+0x4c4]        # be8 <botlish_fn_2+0x628>
     724:	cmp    rcx,0x6
     728:	je     bb7 <botlish_fn_2+0x5f7>
     72e:	mov    rsi,rbx
     731:	test   rsi,0x1
     738:	jne    763 <botlish_fn_2+0x1a3>
     73e:	mov    edx,0x7f
     743:	mov    rsi,rbx
     746:	mov    rdi,r12
     749:	call   74e <botlish_fn_2+0x18e>
			74a: R_X86_64_PLT32	rt_int_cmp-0x4
     74e:	mov    ecx,0x2
     753:	test   rax,rax
     756:	cmovle rcx,QWORD PTR [rip+0x48a]        # be8 <botlish_fn_2+0x628>
     75e:	jmp    777 <botlish_fn_2+0x1b7>
     763:	mov    ecx,0x2
     768:	mov    rsi,rbx
     76b:	cmp    rsi,0x7f
     76f:	cmovle rcx,QWORD PTR [rip+0x471]        # be8 <botlish_fn_2+0x628>
     777:	cmp    rcx,0x6
     77b:	je     bad <botlish_fn_2+0x5ed>
     781:	mov    rsi,rbx
     784:	test   rsi,0x1
     78b:	jne    7b6 <botlish_fn_2+0x1f6>
     791:	mov    edx,0x9f
     796:	mov    rsi,rbx
     799:	mov    rdi,r12
     79c:	call   7a1 <botlish_fn_2+0x1e1>
			79d: R_X86_64_PLT32	rt_int_cmp-0x4
     7a1:	mov    ecx,0x2
     7a6:	test   rax,rax
     7a9:	cmovle rcx,QWORD PTR [rip+0x437]        # be8 <botlish_fn_2+0x628>
     7b1:	jmp    7cd <botlish_fn_2+0x20d>
     7b6:	mov    ecx,0x2
     7bb:	mov    rsi,rbx
     7be:	cmp    rsi,0x9f
     7c5:	cmovle rcx,QWORD PTR [rip+0x41b]        # be8 <botlish_fn_2+0x628>
     7cd:	cmp    rcx,0x6
     7d1:	je     ba3 <botlish_fn_2+0x5e3>
     7d7:	mov    rsi,rbx
     7da:	test   rsi,0x1
     7e1:	jne    80c <botlish_fn_2+0x24c>
     7e7:	mov    edx,0xbf
     7ec:	mov    rsi,rbx
     7ef:	mov    rdi,r12
     7f2:	call   7f7 <botlish_fn_2+0x237>
			7f3: R_X86_64_PLT32	rt_int_cmp-0x4
     7f7:	mov    ecx,0x2
     7fc:	test   rax,rax
     7ff:	cmovle rcx,QWORD PTR [rip+0x3e1]        # be8 <botlish_fn_2+0x628>
     807:	jmp    823 <botlish_fn_2+0x263>
     80c:	mov    ecx,0x2
     811:	mov    rsi,rbx
     814:	cmp    rsi,0xbf
     81b:	cmovle rcx,QWORD PTR [rip+0x3c5]        # be8 <botlish_fn_2+0x628>
     823:	cmp    rcx,0x6
     827:	je     b99 <botlish_fn_2+0x5d9>
     82d:	mov    rsi,rbx
     830:	test   rsi,0x1
     837:	jne    862 <botlish_fn_2+0x2a2>
     83d:	mov    edx,0xdf
     842:	mov    rsi,rbx
     845:	mov    rdi,r12
     848:	call   84d <botlish_fn_2+0x28d>
			849: R_X86_64_PLT32	rt_int_cmp-0x4
     84d:	mov    ecx,0x2
     852:	test   rax,rax
     855:	cmovle rcx,QWORD PTR [rip+0x38b]        # be8 <botlish_fn_2+0x628>
     85d:	jmp    879 <botlish_fn_2+0x2b9>
     862:	mov    ecx,0x2
     867:	mov    rsi,rbx
     86a:	cmp    rsi,0xdf
     871:	cmovle rcx,QWORD PTR [rip+0x36f]        # be8 <botlish_fn_2+0x628>
     879:	cmp    rcx,0x6
     87d:	je     b8f <botlish_fn_2+0x5cf>
     883:	mov    rsi,rbx
     886:	test   rsi,0x1
     88d:	jne    8b9 <botlish_fn_2+0x2f9>
     893:	mov    edx,0xff
     898:	mov    rsi,rbx
     89b:	mov    rdi,r12
     89e:	call   8a3 <botlish_fn_2+0x2e3>
			89f: R_X86_64_PLT32	rt_int_cmp-0x4
     8a3:	mov    r10d,0x2
     8a9:	test   rax,rax
     8ac:	cmovle r10,QWORD PTR [rip+0x334]        # be8 <botlish_fn_2+0x628>
     8b4:	jmp    8d1 <botlish_fn_2+0x311>
     8b9:	mov    r10d,0x2
     8bf:	mov    rsi,rbx
     8c2:	cmp    rsi,0xff
     8c9:	cmovle r10,QWORD PTR [rip+0x317]        # be8 <botlish_fn_2+0x628>
     8d1:	cmp    r10,0x6
     8d5:	je     b85 <botlish_fn_2+0x5c5>
     8db:	mov    rsi,rbx
     8de:	test   rsi,0x1
     8e5:	jne    910 <botlish_fn_2+0x350>
     8eb:	mov    edx,0x11f
     8f0:	mov    rsi,rbx
     8f3:	mov    rdi,r12
     8f6:	call   8fb <botlish_fn_2+0x33b>
			8f7: R_X86_64_PLT32	rt_int_cmp-0x4
     8fb:	mov    ecx,0x2
     900:	test   rax,rax
     903:	cmovle rcx,QWORD PTR [rip+0x2dd]        # be8 <botlish_fn_2+0x628>
     90b:	jmp    927 <botlish_fn_2+0x367>
     910:	mov    ecx,0x2
     915:	mov    rsi,rbx
     918:	cmp    rsi,0x11f
     91f:	cmovle rcx,QWORD PTR [rip+0x2c1]        # be8 <botlish_fn_2+0x628>
     927:	cmp    rcx,0x6
     92b:	je     b7b <botlish_fn_2+0x5bb>
     931:	mov    rsi,rbx
     934:	test   rsi,0x1
     93b:	jne    966 <botlish_fn_2+0x3a6>
     941:	mov    edx,0x13f
     946:	mov    rsi,rbx
     949:	mov    rdi,r12
     94c:	call   951 <botlish_fn_2+0x391>
			94d: R_X86_64_PLT32	rt_int_cmp-0x4
     951:	mov    ecx,0x2
     956:	test   rax,rax
     959:	cmovle rcx,QWORD PTR [rip+0x287]        # be8 <botlish_fn_2+0x628>
     961:	jmp    97d <botlish_fn_2+0x3bd>
     966:	mov    ecx,0x2
     96b:	mov    rsi,rbx
     96e:	cmp    rsi,0x13f
     975:	cmovle rcx,QWORD PTR [rip+0x26b]        # be8 <botlish_fn_2+0x628>
     97d:	cmp    rcx,0x6
     981:	je     b71 <botlish_fn_2+0x5b1>
     987:	mov    rsi,rbx
     98a:	test   rsi,0x1
     991:	jne    9bc <botlish_fn_2+0x3fc>
     997:	mov    edx,0x15f
     99c:	mov    rsi,rbx
     99f:	mov    rdi,r12
     9a2:	call   9a7 <botlish_fn_2+0x3e7>
			9a3: R_X86_64_PLT32	rt_int_cmp-0x4
     9a7:	mov    ecx,0x2
     9ac:	test   rax,rax
     9af:	cmovle rcx,QWORD PTR [rip+0x231]        # be8 <botlish_fn_2+0x628>
     9b7:	jmp    9d3 <botlish_fn_2+0x413>
     9bc:	mov    ecx,0x2
     9c1:	mov    rsi,rbx
     9c4:	cmp    rsi,0x15f
     9cb:	cmovle rcx,QWORD PTR [rip+0x215]        # be8 <botlish_fn_2+0x628>
     9d3:	cmp    rcx,0x6
     9d7:	je     b67 <botlish_fn_2+0x5a7>
     9dd:	mov    rsi,rbx
     9e0:	test   rsi,0x1
     9e7:	jne    a12 <botlish_fn_2+0x452>
     9ed:	mov    edx,0x17f
     9f2:	mov    rsi,rbx
     9f5:	mov    rdi,r12
     9f8:	call   9fd <botlish_fn_2+0x43d>
			9f9: R_X86_64_PLT32	rt_int_cmp-0x4
     9fd:	mov    edi,0x2
     a02:	test   rax,rax
     a05:	cmovle rdi,QWORD PTR [rip+0x1db]        # be8 <botlish_fn_2+0x628>
     a0d:	jmp    a29 <botlish_fn_2+0x469>
     a12:	mov    edi,0x2
     a17:	mov    rsi,rbx
     a1a:	cmp    rsi,0x17f
     a21:	cmovle rdi,QWORD PTR [rip+0x1bf]        # be8 <botlish_fn_2+0x628>
     a29:	cmp    rdi,0x6
     a2d:	je     b5d <botlish_fn_2+0x59d>
     a33:	mov    rsi,rbx
     a36:	test   rsi,0x1
     a3d:	jne    a68 <botlish_fn_2+0x4a8>
     a43:	mov    edx,0x19f
     a48:	mov    rsi,rbx
     a4b:	mov    rdi,r12
     a4e:	call   a53 <botlish_fn_2+0x493>
			a4f: R_X86_64_PLT32	rt_int_cmp-0x4
     a53:	mov    ecx,0x2
     a58:	test   rax,rax
     a5b:	cmovle rcx,QWORD PTR [rip+0x185]        # be8 <botlish_fn_2+0x628>
     a63:	jmp    a7f <botlish_fn_2+0x4bf>
     a68:	mov    ecx,0x2
     a6d:	mov    rsi,rbx
     a70:	cmp    rsi,0x19f
     a77:	cmovle rcx,QWORD PTR [rip+0x169]        # be8 <botlish_fn_2+0x628>
     a7f:	cmp    rcx,0x6
     a83:	je     b53 <botlish_fn_2+0x593>
     a89:	mov    rsi,rbx
     a8c:	test   rsi,0x1
     a93:	jne    abe <botlish_fn_2+0x4fe>
     a99:	mov    edx,0x1bf
     a9e:	mov    rsi,rbx
     aa1:	mov    rdi,r12
     aa4:	call   aa9 <botlish_fn_2+0x4e9>
			aa5: R_X86_64_PLT32	rt_int_cmp-0x4
     aa9:	mov    ecx,0x2
     aae:	test   rax,rax
     ab1:	cmovle rcx,QWORD PTR [rip+0x12f]        # be8 <botlish_fn_2+0x628>
     ab9:	jmp    ad5 <botlish_fn_2+0x515>
     abe:	mov    ecx,0x2
     ac3:	mov    rsi,rbx
     ac6:	cmp    rsi,0x1bf
     acd:	cmovle rcx,QWORD PTR [rip+0x113]        # be8 <botlish_fn_2+0x628>
     ad5:	cmp    rcx,0x6
     ad9:	je     b49 <botlish_fn_2+0x589>
     adf:	mov    rsi,rbx
     ae2:	test   rsi,0x1
     ae9:	jne    b14 <botlish_fn_2+0x554>
     aef:	mov    edx,0x1df
     af4:	mov    rsi,rbx
     af7:	mov    rdi,r12
     afa:	call   aff <botlish_fn_2+0x53f>
			afb: R_X86_64_PLT32	rt_int_cmp-0x4
     aff:	mov    ecx,0x2
     b04:	test   rax,rax
     b07:	cmovle rcx,QWORD PTR [rip+0xd9]        # be8 <botlish_fn_2+0x628>
     b0f:	jmp    b2b <botlish_fn_2+0x56b>
     b14:	mov    ecx,0x2
     b19:	mov    rsi,rbx
     b1c:	cmp    rsi,0x1df
     b23:	cmovle rcx,QWORD PTR [rip+0xbd]        # be8 <botlish_fn_2+0x628>
     b2b:	cmp    rcx,0x6
     b2f:	je     b3f <botlish_fn_2+0x57f>
     b35:	mov    eax,0x1f
     b3a:	jmp    bd0 <botlish_fn_2+0x610>
     b3f:	mov    eax,0x1d
     b44:	jmp    bd0 <botlish_fn_2+0x610>
     b49:	mov    eax,0x1b
     b4e:	jmp    bd0 <botlish_fn_2+0x610>
     b53:	mov    eax,0x19
     b58:	jmp    bd0 <botlish_fn_2+0x610>
     b5d:	mov    eax,0x17
     b62:	jmp    bd0 <botlish_fn_2+0x610>
     b67:	mov    eax,0x15
     b6c:	jmp    bd0 <botlish_fn_2+0x610>
     b71:	mov    eax,0x13
     b76:	jmp    bd0 <botlish_fn_2+0x610>
     b7b:	mov    eax,0x11
     b80:	jmp    bd0 <botlish_fn_2+0x610>
     b85:	mov    eax,0xf
     b8a:	jmp    bd0 <botlish_fn_2+0x610>
     b8f:	mov    eax,0xd
     b94:	jmp    bd0 <botlish_fn_2+0x610>
     b99:	mov    eax,0xb
     b9e:	jmp    bd0 <botlish_fn_2+0x610>
     ba3:	mov    eax,0x9
     ba8:	jmp    bd0 <botlish_fn_2+0x610>
     bad:	mov    eax,0x7
     bb2:	jmp    bd0 <botlish_fn_2+0x610>
     bb7:	mov    eax,0x5
     bbc:	jmp    bd0 <botlish_fn_2+0x610>
     bc1:	mov    eax,0x3
     bc6:	jmp    bd0 <botlish_fn_2+0x610>
     bcb:	mov    eax,0x1
     bd0:	mov    rbx,QWORD PTR [rsp]
     bd4:	mov    r12,QWORD PTR [rsp+0x8]
     bd9:	add    rsp,0x10
     bdd:	mov    rsp,rbp
     be0:	pop    rbp
     be1:	ret
     be2:	add    BYTE PTR [rax],al
     be4:	add    BYTE PTR [rax],al
     be6:	add    BYTE PTR [rax],al
     be8:	(bad)
     be9:	add    BYTE PTR [rax],al
     beb:	add    BYTE PTR [rax],al
     bed:	add    BYTE PTR [rax],al
	...

0000000000000bf0 <botlish_entry_2: high_nibble<generic>>:
     bf0:	push   rbp
     bf1:	mov    rbp,rsp
     bf4:	mov    rsi,QWORD PTR [rdx]
     bf7:	call   bfc <botlish_entry_2+0xc>
			bf8: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
     bfc:	mov    rsp,rbp
     bff:	pop    rbp
     c00:	ret
     c01:	add    BYTE PTR [rax],al
     c03:	add    BYTE PTR [rax],al
     c05:	add    BYTE PTR [rax],al
	...

0000000000000c08 <botlish_fn_3: is_unreserved<generic>>:
     c08:	push   rbp
     c09:	mov    rbp,rsp
     c0c:	sub    rsp,0x20
     c10:	mov    QWORD PTR [rsp],rbx
     c14:	mov    QWORD PTR [rsp+0x8],r12
     c19:	mov    QWORD PTR [rsp+0x10],r13
     c1e:	mov    r8d,0x1
     c24:	test   rsi,0x1
     c2b:	jne    c4b <botlish_fn_3+0x43>
     c31:	xor    r8d,r8d
     c34:	test   rsi,0x7
     c3b:	jne    c4b <botlish_fn_3+0x43>
     c41:	movzx  rax,BYTE PTR [rsi]
     c45:	cmp    al,0x1
     c47:	sete   r8b
     c4b:	test   r8b,r8b
     c4e:	jne    c84 <botlish_fn_3+0x7c>
     c54:	mov    rdx,QWORD PTR [rdi+0x10]
     c58:	mov    rcx,QWORD PTR [rdx+0xa0]
     c5f:	xor    rbx,rbx
     c62:	mov    rdx,rbx
     c65:	call   c6a <botlish_fn_3+0x62>
			c66: R_X86_64_PLT32	rt_type_error-0x4
     c6a:	mov    rax,rbx
     c6d:	mov    rbx,QWORD PTR [rsp]
     c71:	mov    r12,QWORD PTR [rsp+0x8]
     c76:	mov    r13,QWORD PTR [rsp+0x10]
     c7b:	add    rsp,0x20
     c7f:	mov    rsp,rbp
     c82:	pop    rbp
     c83:	ret
     c84:	mov    r12,rdi
     c87:	test   rsi,0x1
     c8e:	mov    rbx,rsi
     c91:	jne    cbc <botlish_fn_3+0xb4>
     c97:	mov    edx,0x59
     c9c:	mov    rsi,rbx
     c9f:	mov    rdi,r12
     ca2:	call   ca7 <botlish_fn_3+0x9f>
			ca3: R_X86_64_PLT32	rt_int_cmp-0x4
     ca7:	mov    ecx,0x2
     cac:	test   rax,rax
     caf:	cmovle rcx,QWORD PTR [rip+0x461]        # 1118 <botlish_fn_3+0x510>
     cb7:	jmp    cd0 <botlish_fn_3+0xc8>
     cbc:	mov    ecx,0x2
     cc1:	mov    rsi,rbx
     cc4:	cmp    rsi,0x59
     cc8:	cmovle rcx,QWORD PTR [rip+0x448]        # 1118 <botlish_fn_3+0x510>
     cd0:	mov    eax,0x6
     cd5:	mov    r13,rax
     cd8:	cmp    rcx,0x6
     cdc:	je     10fb <botlish_fn_3+0x4f3>
     ce2:	mov    rsi,rbx
     ce5:	test   rsi,0x1
     cec:	jne    d17 <botlish_fn_3+0x10f>
     cf2:	mov    edx,0x5d
     cf7:	mov    rsi,rbx
     cfa:	mov    rdi,r12
     cfd:	call   d02 <botlish_fn_3+0xfa>
			cfe: R_X86_64_PLT32	rt_int_cmp-0x4
     d02:	mov    ecx,0x2
     d07:	test   rax,rax
     d0a:	cmovle rcx,QWORD PTR [rip+0x406]        # 1118 <botlish_fn_3+0x510>
     d12:	jmp    d2b <botlish_fn_3+0x123>
     d17:	mov    ecx,0x2
     d1c:	mov    rsi,rbx
     d1f:	cmp    rsi,0x5d
     d23:	cmovle rcx,QWORD PTR [rip+0x3ed]        # 1118 <botlish_fn_3+0x510>
     d2b:	cmp    rcx,0x6
     d2f:	je     10f3 <botlish_fn_3+0x4eb>
     d35:	mov    rsi,rbx
     d38:	test   rsi,0x1
     d3f:	jne    d6a <botlish_fn_3+0x162>
     d45:	mov    edx,0x5f
     d4a:	mov    rsi,rbx
     d4d:	mov    rdi,r12
     d50:	call   d55 <botlish_fn_3+0x14d>
			d51: R_X86_64_PLT32	rt_int_cmp-0x4
     d55:	mov    ecx,0x2
     d5a:	test   rax,rax
     d5d:	cmovle rcx,QWORD PTR [rip+0x3b3]        # 1118 <botlish_fn_3+0x510>
     d65:	jmp    d7e <botlish_fn_3+0x176>
     d6a:	mov    ecx,0x2
     d6f:	mov    rsi,rbx
     d72:	cmp    rsi,0x5f
     d76:	cmovle rcx,QWORD PTR [rip+0x39a]        # 1118 <botlish_fn_3+0x510>
     d7e:	cmp    rcx,0x6
     d82:	je     10e9 <botlish_fn_3+0x4e1>
     d88:	mov    rsi,rbx
     d8b:	test   rsi,0x1
     d92:	jne    dbd <botlish_fn_3+0x1b5>
     d98:	mov    edx,0x73
     d9d:	mov    rsi,rbx
     da0:	mov    rdi,r12
     da3:	call   da8 <botlish_fn_3+0x1a0>
			da4: R_X86_64_PLT32	rt_int_cmp-0x4
     da8:	mov    ecx,0x2
     dad:	test   rax,rax
     db0:	cmovle rcx,QWORD PTR [rip+0x360]        # 1118 <botlish_fn_3+0x510>
     db8:	jmp    dd1 <botlish_fn_3+0x1c9>
     dbd:	mov    ecx,0x2
     dc2:	mov    rsi,rbx
     dc5:	cmp    rsi,0x73
     dc9:	cmovle rcx,QWORD PTR [rip+0x347]        # 1118 <botlish_fn_3+0x510>
     dd1:	cmp    rcx,0x6
     dd5:	je     10e1 <botlish_fn_3+0x4d9>
     ddb:	mov    rsi,rbx
     dde:	test   rsi,0x1
     de5:	jne    e10 <botlish_fn_3+0x208>
     deb:	mov    edx,0x81
     df0:	mov    rsi,rbx
     df3:	mov    rdi,r12
     df6:	call   dfb <botlish_fn_3+0x1f3>
			df7: R_X86_64_PLT32	rt_int_cmp-0x4
     dfb:	mov    ecx,0x2
     e00:	test   rax,rax
     e03:	cmovle rcx,QWORD PTR [rip+0x30d]        # 1118 <botlish_fn_3+0x510>
     e0b:	jmp    e27 <botlish_fn_3+0x21f>
     e10:	mov    ecx,0x2
     e15:	mov    rsi,rbx
     e18:	cmp    rsi,0x81
     e1f:	cmovle rcx,QWORD PTR [rip+0x2f1]        # 1118 <botlish_fn_3+0x510>
     e27:	cmp    rcx,0x6
     e2b:	je     10d7 <botlish_fn_3+0x4cf>
     e31:	mov    rsi,rbx
     e34:	test   rsi,0x1
     e3b:	jne    e66 <botlish_fn_3+0x25e>
     e41:	mov    edx,0xb5
     e46:	mov    rsi,rbx
     e49:	mov    rdi,r12
     e4c:	call   e51 <botlish_fn_3+0x249>
			e4d: R_X86_64_PLT32	rt_int_cmp-0x4
     e51:	mov    ecx,0x2
     e56:	test   rax,rax
     e59:	cmovle rcx,QWORD PTR [rip+0x2b7]        # 1118 <botlish_fn_3+0x510>
     e61:	jmp    e7d <botlish_fn_3+0x275>
     e66:	mov    ecx,0x2
     e6b:	mov    rsi,rbx
     e6e:	cmp    rsi,0xb5
     e75:	cmovle rcx,QWORD PTR [rip+0x29b]        # 1118 <botlish_fn_3+0x510>
     e7d:	cmp    rcx,0x6
     e81:	je     10cf <botlish_fn_3+0x4c7>
     e87:	mov    rsi,rbx
     e8a:	test   rsi,0x1
     e91:	jne    ebc <botlish_fn_3+0x2b4>
     e97:	mov    edx,0xbd
     e9c:	mov    rsi,rbx
     e9f:	mov    rdi,r12
     ea2:	call   ea7 <botlish_fn_3+0x29f>
			ea3: R_X86_64_PLT32	rt_int_cmp-0x4
     ea7:	mov    ecx,0x2
     eac:	test   rax,rax
     eaf:	cmovle rcx,QWORD PTR [rip+0x261]        # 1118 <botlish_fn_3+0x510>
     eb7:	jmp    ed3 <botlish_fn_3+0x2cb>
     ebc:	mov    ecx,0x2
     ec1:	mov    rsi,rbx
     ec4:	cmp    rsi,0xbd
     ecb:	cmovle rcx,QWORD PTR [rip+0x245]        # 1118 <botlish_fn_3+0x510>
     ed3:	cmp    rcx,0x6
     ed7:	je     10c5 <botlish_fn_3+0x4bd>
     edd:	mov    rsi,rbx
     ee0:	test   rsi,0x1
     ee7:	jne    f13 <botlish_fn_3+0x30b>
     eed:	mov    edx,0xbf
     ef2:	mov    rsi,rbx
     ef5:	mov    rdi,r12
     ef8:	call   efd <botlish_fn_3+0x2f5>
			ef9: R_X86_64_PLT32	rt_int_cmp-0x4
     efd:	mov    r11d,0x2
     f03:	test   rax,rax
     f06:	cmovle r11,QWORD PTR [rip+0x20a]        # 1118 <botlish_fn_3+0x510>
     f0e:	jmp    f2b <botlish_fn_3+0x323>
     f13:	mov    r11d,0x2
     f19:	mov    rsi,rbx
     f1c:	cmp    rsi,0xbf
     f23:	cmovle r11,QWORD PTR [rip+0x1ed]        # 1118 <botlish_fn_3+0x510>
     f2b:	cmp    r11,0x6
     f2f:	je     10bd <botlish_fn_3+0x4b5>
     f35:	mov    rsi,rbx
     f38:	test   rsi,0x1
     f3f:	jne    f6a <botlish_fn_3+0x362>
     f45:	mov    edx,0xc1
     f4a:	mov    rsi,rbx
     f4d:	mov    rdi,r12
     f50:	call   f55 <botlish_fn_3+0x34d>
			f51: R_X86_64_PLT32	rt_int_cmp-0x4
     f55:	mov    ecx,0x2
     f5a:	test   rax,rax
     f5d:	cmovle rcx,QWORD PTR [rip+0x1b3]        # 1118 <botlish_fn_3+0x510>
     f65:	jmp    f81 <botlish_fn_3+0x379>
     f6a:	mov    ecx,0x2
     f6f:	mov    rsi,rbx
     f72:	cmp    rsi,0xc1
     f79:	cmovle rcx,QWORD PTR [rip+0x197]        # 1118 <botlish_fn_3+0x510>
     f81:	cmp    rcx,0x6
     f85:	je     10b3 <botlish_fn_3+0x4ab>
     f8b:	mov    rsi,rbx
     f8e:	test   rsi,0x1
     f95:	jne    fc0 <botlish_fn_3+0x3b8>
     f9b:	mov    edx,0xf5
     fa0:	mov    rsi,rbx
     fa3:	mov    rdi,r12
     fa6:	call   fab <botlish_fn_3+0x3a3>
			fa7: R_X86_64_PLT32	rt_int_cmp-0x4
     fab:	mov    ecx,0x2
     fb0:	test   rax,rax
     fb3:	cmovle rcx,QWORD PTR [rip+0x15d]        # 1118 <botlish_fn_3+0x510>
     fbb:	jmp    fd7 <botlish_fn_3+0x3cf>
     fc0:	mov    ecx,0x2
     fc5:	mov    rsi,rbx
     fc8:	cmp    rsi,0xf5
     fcf:	cmovle rcx,QWORD PTR [rip+0x141]        # 1118 <botlish_fn_3+0x510>
     fd7:	cmp    rcx,0x6
     fdb:	je     10ab <botlish_fn_3+0x4a3>
     fe1:	mov    rsi,rbx
     fe4:	test   rsi,0x1
     feb:	jne    1016 <botlish_fn_3+0x40e>
     ff1:	mov    edx,0xfb
     ff6:	mov    rsi,rbx
     ff9:	mov    rdi,r12
     ffc:	call   1001 <botlish_fn_3+0x3f9>
			ffd: R_X86_64_PLT32	rt_int_cmp-0x4
    1001:	mov    ecx,0x2
    1006:	test   rax,rax
    1009:	cmovle rcx,QWORD PTR [rip+0x107]        # 1118 <botlish_fn_3+0x510>
    1011:	jmp    102d <botlish_fn_3+0x425>
    1016:	mov    ecx,0x2
    101b:	mov    rsi,rbx
    101e:	cmp    rsi,0xfb
    1025:	cmovle rcx,QWORD PTR [rip+0xeb]        # 1118 <botlish_fn_3+0x510>
    102d:	cmp    rcx,0x6
    1031:	je     10a1 <botlish_fn_3+0x499>
    1037:	mov    rsi,rbx
    103a:	test   rsi,0x1
    1041:	jne    106d <botlish_fn_3+0x465>
    1047:	mov    edx,0xfd
    104c:	mov    rsi,rbx
    104f:	mov    rdi,r12
    1052:	call   1057 <botlish_fn_3+0x44f>
			1053: R_X86_64_PLT32	rt_int_cmp-0x4
    1057:	mov    r8d,0x2
    105d:	test   rax,rax
    1060:	cmovle r8,QWORD PTR [rip+0xb0]        # 1118 <botlish_fn_3+0x510>
    1068:	jmp    1085 <botlish_fn_3+0x47d>
    106d:	mov    r8d,0x2
    1073:	mov    rsi,rbx
    1076:	cmp    rsi,0xfd
    107d:	cmovle r8,QWORD PTR [rip+0x93]        # 1118 <botlish_fn_3+0x510>
    1085:	cmp    r8,0x6
    1089:	je     1099 <botlish_fn_3+0x491>
    108f:	mov    eax,0x2
    1094:	jmp    1100 <botlish_fn_3+0x4f8>
    1099:	mov    rax,r13
    109c:	jmp    1100 <botlish_fn_3+0x4f8>
    10a1:	mov    eax,0x2
    10a6:	jmp    1100 <botlish_fn_3+0x4f8>
    10ab:	mov    rax,r13
    10ae:	jmp    1100 <botlish_fn_3+0x4f8>
    10b3:	mov    eax,0x2
    10b8:	jmp    1100 <botlish_fn_3+0x4f8>
    10bd:	mov    rax,r13
    10c0:	jmp    1100 <botlish_fn_3+0x4f8>
    10c5:	mov    eax,0x2
    10ca:	jmp    1100 <botlish_fn_3+0x4f8>
    10cf:	mov    rax,r13
    10d2:	jmp    1100 <botlish_fn_3+0x4f8>
    10d7:	mov    eax,0x2
    10dc:	jmp    1100 <botlish_fn_3+0x4f8>
    10e1:	mov    rax,r13
    10e4:	jmp    1100 <botlish_fn_3+0x4f8>
    10e9:	mov    eax,0x2
    10ee:	jmp    1100 <botlish_fn_3+0x4f8>
    10f3:	mov    rax,r13
    10f6:	jmp    1100 <botlish_fn_3+0x4f8>
    10fb:	mov    eax,0x2
    1100:	mov    rbx,QWORD PTR [rsp]
    1104:	mov    r12,QWORD PTR [rsp+0x8]
    1109:	mov    r13,QWORD PTR [rsp+0x10]
    110e:	add    rsp,0x20
    1112:	mov    rsp,rbp
    1115:	pop    rbp
    1116:	ret
    1117:	add    BYTE PTR [rsi],al
    1119:	add    BYTE PTR [rax],al
    111b:	add    BYTE PTR [rax],al
    111d:	add    BYTE PTR [rax],al
	...

0000000000001120 <botlish_entry_3: is_unreserved<generic>>:
    1120:	push   rbp
    1121:	mov    rbp,rsp
    1124:	mov    rsi,QWORD PTR [rdx]
    1127:	call   112c <botlish_entry_3+0xc>
			1128: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    112c:	mov    rsp,rbp
    112f:	pop    rbp
    1130:	ret

0000000000001131 <botlish_fn_4: hex_pair<generic>>:
    1131:	push   rbp
    1132:	mov    rbp,rsp
    1135:	sub    rsp,0x30
    1139:	mov    QWORD PTR [rsp],rbx
    113d:	mov    QWORD PTR [rsp+0x8],r12
    1142:	mov    QWORD PTR [rsp+0x10],r13
    1147:	mov    QWORD PTR [rsp+0x18],r14
    114c:	mov    QWORD PTR [rsp+0x20],r15
    1151:	mov    r13,rdx
    1154:	mov    rbx,QWORD PTR [rdi]
    1157:	mov    rax,QWORD PTR [rdi+0x8]
    115b:	lea    rcx,[rbx+0x10]
    115f:	cmp    rcx,rax
    1162:	ja     136b <botlish_fn_4+0x23a>
    1168:	lea    rax,[rbx+0x10]
    116c:	mov    QWORD PTR [rdi],rax
    116f:	mov    rdx,r13
    1172:	mov    r12,rdi
    1175:	mov    QWORD PTR [rbx],rdx
    1178:	mov    rax,QWORD PTR [rsi+0x20]
    117c:	mov    r14,rsi
    117f:	mov    rsi,QWORD PTR [rax]
    1182:	mov    QWORD PTR [rbx+0x8],rsi
    1186:	mov    r15,rsi
    1189:	mov    rsi,r13
    118c:	mov    rdi,r12
    118f:	call   1194 <botlish_fn_4+0x63>
			1190: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
    1194:	test   rax,rax
    1197:	jne    11a5 <botlish_fn_4+0x74>
    119d:	mov    rdi,r12
    11a0:	jmp    131a <botlish_fn_4+0x1e9>
    11a5:	test   rax,0x1
    11ab:	jne    11bc <botlish_fn_4+0x8b>
    11b1:	mov    rdx,rax
    11b4:	mov    rsi,r15
    11b7:	jmp    11d8 <botlish_fn_4+0xa7>
    11bc:	mov    rsi,r15
    11bf:	mov    rdx,QWORD PTR [rsi+0x8]
    11c3:	mov    rcx,rax
    11c6:	sar    rcx,1
    11c9:	mov    rdi,rax
    11cc:	cmp    rcx,rdx
    11cf:	jb     11f9 <botlish_fn_4+0xc8>
    11d5:	mov    rdx,rdi
    11d8:	mov    rdi,r12
    11db:	call   11e0 <botlish_fn_4+0xaf>
			11dc: R_X86_64_PLT32	rt_list_get-0x4
    11e0:	test   rax,rax
    11e3:	jne    11f1 <botlish_fn_4+0xc0>
    11e9:	mov    rdi,r12
    11ec:	jmp    131a <botlish_fn_4+0x1e9>
    11f1:	mov    rsi,rax
    11f4:	jmp    1201 <botlish_fn_4+0xd0>
    11f9:	mov    rax,QWORD PTR [rsi+0x10]
    11fd:	mov    rsi,QWORD PTR [rax+rcx*8]
    1201:	mov    QWORD PTR [rbx],rsi
    1204:	mov    rax,rsi
    1207:	mov    rsi,r14
    120a:	mov    r14,rax
    120d:	mov    rdx,QWORD PTR [rsi+0x20]
    1211:	mov    rsi,QWORD PTR [rdx]
    1214:	mov    r15,rsi
    1217:	mov    ecx,0x1
    121c:	mov    rdx,r13
    121f:	test   rdx,0x1
    1226:	je     1234 <botlish_fn_4+0x103>
    122c:	mov    r13,rdx
    122f:	jmp    1259 <botlish_fn_4+0x128>
    1234:	xor    ecx,ecx
    1236:	test   rdx,0x7
    123d:	je     124b <botlish_fn_4+0x11a>
    1243:	mov    r13,rdx
    1246:	jmp    1259 <botlish_fn_4+0x128>
    124b:	movzx  r8,BYTE PTR [rdx]
    124f:	mov    r13,rdx
    1252:	cmp    r8b,0x1
    1256:	sete   cl
    1259:	test   cl,cl
    125b:	jne    1282 <botlish_fn_4+0x151>
    1261:	mov    rdi,r12
    1264:	mov    rax,QWORD PTR [rdi+0x10]
    1268:	mov    rcx,QWORD PTR [rax+0xa8]
    126f:	xor    rdx,rdx
    1272:	mov    rsi,r13
    1275:	call   127a <botlish_fn_4+0x149>
			1276: R_X86_64_PLT32	rt_type_error-0x4
    127a:	mov    rdi,r12
    127d:	jmp    131a <botlish_fn_4+0x1e9>
    1282:	mov    rsi,r13
    1285:	mov    edx,0x21
    128a:	mov    rdi,r12
    128d:	call   1292 <botlish_fn_4+0x161>
			128e: R_X86_64_PLT32	rt_int_mod-0x4
    1292:	test   rax,rax
    1295:	jne    12a3 <botlish_fn_4+0x172>
    129b:	mov    rdi,r12
    129e:	jmp    131a <botlish_fn_4+0x1e9>
    12a3:	test   rax,0x1
    12a9:	jne    12ba <botlish_fn_4+0x189>
    12af:	mov    rdx,rax
    12b2:	mov    rsi,r15
    12b5:	jmp    12d6 <botlish_fn_4+0x1a5>
    12ba:	mov    rsi,r15
    12bd:	mov    rdx,QWORD PTR [rsi+0x8]
    12c1:	mov    rcx,rax
    12c4:	sar    rcx,1
    12c7:	mov    rdi,rax
    12ca:	cmp    rcx,rdx
    12cd:	jb     12f7 <botlish_fn_4+0x1c6>
    12d3:	mov    rdx,rdi
    12d6:	mov    rdi,r12
    12d9:	call   12de <botlish_fn_4+0x1ad>
			12da: R_X86_64_PLT32	rt_list_get-0x4
    12de:	test   rax,rax
    12e1:	jne    12ef <botlish_fn_4+0x1be>
    12e7:	mov    rdi,r12
    12ea:	jmp    131a <botlish_fn_4+0x1e9>
    12ef:	mov    rdx,rax
    12f2:	jmp    12ff <botlish_fn_4+0x1ce>
    12f7:	mov    rax,QWORD PTR [rsi+0x10]
    12fb:	mov    rdx,QWORD PTR [rax+rcx*8]
    12ff:	mov    QWORD PTR [rbx+0x8],rdx
    1303:	mov    rsi,r14
    1306:	mov    rdi,r12
    1309:	call   130e <botlish_fn_4+0x1dd>
			130a: R_X86_64_PLT32	rt_str_cat-0x4
    130e:	test   rax,rax
    1311:	jne    1344 <botlish_fn_4+0x213>
    1317:	mov    rdi,r12
    131a:	mov    rdi,r12
    131d:	mov    QWORD PTR [rdi],rbx
    1320:	xor    rax,rax
    1323:	mov    rbx,QWORD PTR [rsp]
    1327:	mov    r12,QWORD PTR [rsp+0x8]
    132c:	mov    r13,QWORD PTR [rsp+0x10]
    1331:	mov    r14,QWORD PTR [rsp+0x18]
    1336:	mov    r15,QWORD PTR [rsp+0x20]
    133b:	add    rsp,0x30
    133f:	mov    rsp,rbp
    1342:	pop    rbp
    1343:	ret
    1344:	mov    rdi,r12
    1347:	mov    QWORD PTR [rdi],rbx
    134a:	mov    rbx,QWORD PTR [rsp]
    134e:	mov    r12,QWORD PTR [rsp+0x8]
    1353:	mov    r13,QWORD PTR [rsp+0x10]
    1358:	mov    r14,QWORD PTR [rsp+0x18]
    135d:	mov    r15,QWORD PTR [rsp+0x20]
    1362:	add    rsp,0x30
    1366:	mov    rsp,rbp
    1369:	pop    rbp
    136a:	ret
    136b:	mov    r12,rdi
    136e:	call   1373 <botlish_fn_4+0x242>
			136f: R_X86_64_PLT32	rt_stack_overflow-0x4
    1373:	xor    rax,rax
    1376:	mov    rbx,QWORD PTR [rsp]
    137a:	mov    r12,QWORD PTR [rsp+0x8]
    137f:	mov    r13,QWORD PTR [rsp+0x10]
    1384:	mov    r14,QWORD PTR [rsp+0x18]
    1389:	mov    r15,QWORD PTR [rsp+0x20]
    138e:	add    rsp,0x30
    1392:	mov    rsp,rbp
    1395:	pop    rbp
    1396:	ret

0000000000001397 <botlish_entry_4: hex_pair<generic>>:
    1397:	push   rbp
    1398:	mov    rbp,rsp
    139b:	mov    rdx,QWORD PTR [rdx]
    139e:	call   13a3 <botlish_entry_4+0xc>
			139f: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    13a3:	mov    rsp,rbp
    13a6:	pop    rbp
    13a7:	ret

00000000000013a8 <botlish_fn_5: esc_bytes<generic>>:
    13a8:	push   rbp
    13a9:	mov    rbp,rsp
    13ac:	sub    rsp,0x50
    13b0:	mov    QWORD PTR [rsp+0x20],rbx
    13b5:	mov    QWORD PTR [rsp+0x28],r12
    13ba:	mov    QWORD PTR [rsp+0x30],r13
    13bf:	mov    QWORD PTR [rsp+0x38],r14
    13c4:	mov    QWORD PTR [rsp+0x40],r15
    13c9:	mov    r15,rsi
    13cc:	mov    r13,QWORD PTR [rdi]
    13cf:	mov    r9,QWORD PTR [rdi+0x8]
    13d3:	lea    r10,[r13+0x38]
    13d7:	cmp    r10,r9
    13da:	ja     171d <botlish_fn_5+0x375>
    13e0:	lea    r10,[r13+0x38]
    13e4:	mov    QWORD PTR [rdi],r10
    13e7:	mov    r14,rdi
    13ea:	mov    QWORD PTR [r13+0x28],0x0
    13f2:	mov    QWORD PTR [r13+0x30],0x0
    13fa:	mov    QWORD PTR [r13+0x0],rdx
    13fe:	mov    QWORD PTR [r13+0x8],rcx
    1402:	mov    QWORD PTR [r13+0x10],r8
    1406:	mov    QWORD PTR [rsp],rcx
    140a:	mov    QWORD PTR [rsp+0x8],r8
    140f:	xor    eax,eax
    1411:	test   rdx,0x7
    1418:	je     1426 <botlish_fn_5+0x7e>
    141e:	mov    rsi,rdx
    1421:	jmp    1432 <botlish_fn_5+0x8a>
    1426:	movzx  rax,BYTE PTR [rdx]
    142a:	mov    rsi,rdx
    142d:	cmp    al,0x3
    142f:	sete   al
    1432:	test   al,al
    1434:	jne    145a <botlish_fn_5+0xb2>
    143a:	mov    rdi,r14
    143d:	mov    rax,QWORD PTR [rdi+0x10]
    1441:	mov    rcx,QWORD PTR [rax+0xb0]
    1448:	mov    edx,0x4
    144d:	call   1452 <botlish_fn_5+0xaa>
			144e: R_X86_64_PLT32	rt_type_error-0x4
    1452:	mov    rdi,r14
    1455:	jmp    16a8 <botlish_fn_5+0x300>
    145a:	mov    rbx,rsi
    145d:	mov    rdi,r14
    1460:	call   1465 <botlish_fn_5+0xbd>
			1461: R_X86_64_PLT32	rt_list_len-0x4
    1465:	mov    ecx,0x1
    146a:	mov    rsi,QWORD PTR [rsp]
    146e:	test   rsi,0x1
    1475:	jne    149d <botlish_fn_5+0xf5>
    147b:	xor    ecx,ecx
    147d:	mov    rsi,QWORD PTR [rsp]
    1481:	test   rsi,0x7
    1488:	jne    149d <botlish_fn_5+0xf5>
    148e:	mov    rsi,QWORD PTR [rsp]
    1492:	movzx  rcx,BYTE PTR [rsi]
    1496:	rex cmp cl,0x1
    149a:	sete   cl
    149d:	test   cl,cl
    149f:	jne    14c7 <botlish_fn_5+0x11f>
    14a5:	mov    rdi,r14
    14a8:	mov    rax,QWORD PTR [rdi+0x10]
    14ac:	mov    rcx,QWORD PTR [rax+0xb8]
    14b3:	xor    rdx,rdx
    14b6:	mov    rsi,QWORD PTR [rsp]
    14ba:	call   14bf <botlish_fn_5+0x117>
			14bb: R_X86_64_PLT32	rt_type_error-0x4
    14bf:	mov    rdi,r14
    14c2:	jmp    16a8 <botlish_fn_5+0x300>
    14c7:	mov    rsi,QWORD PTR [rsp]
    14cb:	mov    rcx,rsi
    14ce:	and    rcx,rax
    14d1:	mov    rdx,rax
    14d4:	test   rcx,0x1
    14db:	jne    1502 <botlish_fn_5+0x15a>
    14e1:	mov    rsi,QWORD PTR [rsp]
    14e5:	mov    rdi,r14
    14e8:	call   14ed <botlish_fn_5+0x145>
			14e9: R_X86_64_PLT32	rt_int_cmp-0x4
    14ed:	mov    esi,0x2
    14f2:	test   rax,rax
    14f5:	cmovge rsi,QWORD PTR [rip+0x253]        # 1750 <botlish_fn_5+0x3a8>
    14fd:	jmp    1516 <botlish_fn_5+0x16e>
    1502:	mov    esi,0x2
    1507:	mov    rax,QWORD PTR [rsp]
    150b:	cmp    rax,rdx
    150e:	cmovge rsi,QWORD PTR [rip+0x23a]        # 1750 <botlish_fn_5+0x3a8>
    1516:	cmp    rsi,0x6
    151a:	je     16f0 <botlish_fn_5+0x348>
    1520:	mov    QWORD PTR [r13+0x18],r15
    1524:	mov    QWORD PTR [r13+0x20],0x3
    152c:	mov    rsi,QWORD PTR [rsp]
    1530:	test   rsi,0x1
    1537:	je     155e <botlish_fn_5+0x1b6>
    153d:	mov    rsi,QWORD PTR [rsp]
    1541:	mov    rax,rsi
    1544:	add    rax,0x2
    1548:	mov    rcx,rax
    154b:	seto   al
    154e:	test   al,al
    1550:	jne    155e <botlish_fn_5+0x1b6>
    1556:	mov    r12,rcx
    1559:	jmp    1575 <botlish_fn_5+0x1cd>
    155e:	mov    edx,0x3
    1563:	mov    rsi,QWORD PTR [rsp]
    1567:	mov    rdi,r14
    156a:	call   156f <botlish_fn_5+0x1c7>
			156b: R_X86_64_PLT32	rt_int_add-0x4
    156f:	mov    rcx,rax
    1572:	mov    r12,rcx
    1575:	mov    QWORD PTR [r13+0x8],r12
    1579:	mov    rdi,r14
    157c:	mov    rax,QWORD PTR [rdi+0x10]
    1580:	mov    rsi,QWORD PTR [rax+0xc0]
    1587:	mov    QWORD PTR [r13+0x20],rsi
    158b:	mov    QWORD PTR [rsp+0x18],rsi
    1590:	mov    rax,QWORD PTR [r15+0x20]
    1594:	mov    rsi,QWORD PTR [rax]
    1597:	mov    QWORD PTR [r13+0x28],rsi
    159b:	mov    QWORD PTR [rsp+0x10],rsi
    15a0:	mov    rsi,QWORD PTR [rsp]
    15a4:	test   rsi,0x1
    15ab:	jne    15ba <botlish_fn_5+0x212>
    15b1:	mov    rdx,QWORD PTR [rsp]
    15b5:	jmp    15d5 <botlish_fn_5+0x22d>
    15ba:	mov    rcx,QWORD PTR [rbx+0x8]
    15be:	mov    rsi,QWORD PTR [rsp]
    15c2:	mov    rax,rsi
    15c5:	sar    rax,1
    15c8:	cmp    rax,rcx
    15cb:	jb     15f9 <botlish_fn_5+0x251>
    15d1:	mov    rdx,QWORD PTR [rsp]
    15d5:	mov    rsi,rbx
    15d8:	mov    rdi,r14
    15db:	call   15e0 <botlish_fn_5+0x238>
			15dc: R_X86_64_PLT32	rt_list_get-0x4
    15e0:	test   rax,rax
    15e3:	jne    15f1 <botlish_fn_5+0x249>
    15e9:	mov    rdi,r14
    15ec:	jmp    16a8 <botlish_fn_5+0x300>
    15f1:	mov    rdx,rax
    15f4:	jmp    1601 <botlish_fn_5+0x259>
    15f9:	mov    rsi,QWORD PTR [rbx+0x10]
    15fd:	mov    rdx,QWORD PTR [rsi+rax*8]
    1601:	mov    QWORD PTR [r13+0x30],rdx
    1605:	mov    rsi,QWORD PTR [rsp+0x10]
    160a:	mov    rdi,r14
    160d:	call   1612 <botlish_fn_5+0x26a>
			160e: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    1612:	test   rax,rax
    1615:	jne    1623 <botlish_fn_5+0x27b>
    161b:	mov    rdi,r14
    161e:	jmp    16a8 <botlish_fn_5+0x300>
    1623:	mov    QWORD PTR [r13+0x28],rax
    1627:	mov    rdx,rax
    162a:	mov    rsi,QWORD PTR [rsp+0x18]
    162f:	mov    rdi,r14
    1632:	call   1637 <botlish_fn_5+0x28f>
			1633: R_X86_64_PLT32	rt_str_cat-0x4
    1637:	test   rax,rax
    163a:	jne    1648 <botlish_fn_5+0x2a0>
    1640:	mov    rdi,r14
    1643:	jmp    16a8 <botlish_fn_5+0x300>
    1648:	mov    QWORD PTR [r13+0x20],rax
    164c:	mov    rdx,rax
    164f:	xor    eax,eax
    1651:	mov    rsi,QWORD PTR [rsp+0x8]
    1656:	test   rsi,0x7
    165d:	jne    166c <botlish_fn_5+0x2c4>
    1663:	movzx  rax,BYTE PTR [rsi]
    1667:	cmp    al,0x2
    1669:	sete   al
    166c:	test   al,al
    166e:	jne    1694 <botlish_fn_5+0x2ec>
    1674:	mov    rdi,r14
    1677:	mov    rax,QWORD PTR [rdi+0x10]
    167b:	mov    rcx,QWORD PTR [rax+0xc8]
    1682:	mov    edx,0x1
    1687:	call   168c <botlish_fn_5+0x2e4>
			1688: R_X86_64_PLT32	rt_type_error-0x4
    168c:	mov    rdi,r14
    168f:	jmp    16a8 <botlish_fn_5+0x300>
    1694:	mov    rdi,r14
    1697:	call   169c <botlish_fn_5+0x2f4>
			1698: R_X86_64_PLT32	rt_str_cat-0x4
    169c:	test   rax,rax
    169f:	jne    16d3 <botlish_fn_5+0x32b>
    16a5:	mov    rdi,r14
    16a8:	mov    rdi,r14
    16ab:	mov    QWORD PTR [rdi],r13
    16ae:	xor    rax,rax
    16b1:	mov    rbx,QWORD PTR [rsp+0x20]
    16b6:	mov    r12,QWORD PTR [rsp+0x28]
    16bb:	mov    r13,QWORD PTR [rsp+0x30]
    16c0:	mov    r14,QWORD PTR [rsp+0x38]
    16c5:	mov    r15,QWORD PTR [rsp+0x40]
    16ca:	add    rsp,0x50
    16ce:	mov    rsp,rbp
    16d1:	pop    rbp
    16d2:	ret
    16d3:	mov    QWORD PTR [r13+0x0],rbx
    16d7:	mov    QWORD PTR [r13+0x8],r12
    16db:	mov    QWORD PTR [r13+0x10],rax
    16df:	mov    rdx,rbx
    16e2:	mov    QWORD PTR [rsp],r12
    16e6:	mov    QWORD PTR [rsp+0x8],rax
    16eb:	jmp    140f <botlish_fn_5+0x67>
    16f0:	mov    rdi,r14
    16f3:	mov    QWORD PTR [rdi],r13
    16f6:	mov    rax,QWORD PTR [rsp+0x8]
    16fb:	mov    rbx,QWORD PTR [rsp+0x20]
    1700:	mov    r12,QWORD PTR [rsp+0x28]
    1705:	mov    r13,QWORD PTR [rsp+0x30]
    170a:	mov    r14,QWORD PTR [rsp+0x38]
    170f:	mov    r15,QWORD PTR [rsp+0x40]
    1714:	add    rsp,0x50
    1718:	mov    rsp,rbp
    171b:	pop    rbp
    171c:	ret
    171d:	mov    r14,rdi
    1720:	call   1725 <botlish_fn_5+0x37d>
			1721: R_X86_64_PLT32	rt_stack_overflow-0x4
    1725:	xor    rax,rax
    1728:	mov    rbx,QWORD PTR [rsp+0x20]
    172d:	mov    r12,QWORD PTR [rsp+0x28]
    1732:	mov    r13,QWORD PTR [rsp+0x30]
    1737:	mov    r14,QWORD PTR [rsp+0x38]
    173c:	mov    r15,QWORD PTR [rsp+0x40]
    1741:	add    rsp,0x50
    1745:	mov    rsp,rbp
    1748:	pop    rbp
    1749:	ret
    174a:	add    BYTE PTR [rax],al
    174c:	add    BYTE PTR [rax],al
    174e:	add    BYTE PTR [rax],al
    1750:	(bad)
    1751:	add    BYTE PTR [rax],al
    1753:	add    BYTE PTR [rax],al
    1755:	add    BYTE PTR [rax],al
	...

0000000000001758 <botlish_entry_5: esc_bytes<generic>>:
    1758:	push   rbp
    1759:	mov    rbp,rsp
    175c:	mov    r9,QWORD PTR [rdx]
    175f:	mov    rcx,QWORD PTR [rdx+0x8]
    1763:	mov    r8,QWORD PTR [rdx+0x10]
    1767:	mov    rdx,r9
    176a:	call   176f <botlish_entry_5+0x17>
			176b: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    176f:	mov    rsp,rbp
    1772:	pop    rbp
    1773:	ret

0000000000001774 <botlish_fn_6: esc_char<generic>>:
    1774:	push   rbp
    1775:	mov    rbp,rsp
    1778:	sub    rsp,0x40
    177c:	mov    QWORD PTR [rsp+0x10],rbx
    1781:	mov    QWORD PTR [rsp+0x18],r12
    1786:	mov    QWORD PTR [rsp+0x20],r13
    178b:	mov    QWORD PTR [rsp+0x28],r14
    1790:	mov    QWORD PTR [rsp+0x30],r15
    1795:	mov    rbx,rsi
    1798:	mov    r12,QWORD PTR [rdi]
    179b:	mov    rax,QWORD PTR [rdi+0x8]
    179f:	lea    rcx,[r12+0x20]
    17a4:	cmp    rcx,rax
    17a7:	ja     19c2 <botlish_fn_6+0x24e>
    17ad:	lea    rax,[r12+0x20]
    17b2:	mov    QWORD PTR [rdi],rax
    17b5:	mov    QWORD PTR [r12+0x8],0x0
    17be:	mov    QWORD PTR [r12+0x10],0x0
    17c7:	mov    QWORD PTR [r12+0x18],0x0
    17d0:	mov    QWORD PTR [r12],rdx
    17d4:	xor    eax,eax
    17d6:	test   rdx,0x7
    17dd:	je     17eb <botlish_fn_6+0x77>
    17e3:	mov    r14,rdx
    17e6:	jmp    17f7 <botlish_fn_6+0x83>
    17eb:	movzx  rax,BYTE PTR [rdx]
    17ef:	mov    r14,rdx
    17f2:	cmp    al,0x2
    17f4:	sete   al
    17f7:	test   al,al
    17f9:	jne    1822 <botlish_fn_6+0xae>
    17ff:	mov    rax,QWORD PTR [rdi+0x10]
    1803:	mov    r13,rdi
    1806:	mov    rcx,QWORD PTR [rax+0xd0]
    180d:	mov    edx,0x1
    1812:	mov    rsi,r14
    1815:	call   181a <botlish_fn_6+0xa6>
			1816: R_X86_64_PLT32	rt_type_error-0x4
    181a:	mov    rdi,r13
    181d:	jmp    1964 <botlish_fn_6+0x1f0>
    1822:	mov    r13,rdi
    1825:	mov    rsi,r14
    1828:	call   182d <botlish_fn_6+0xb9>
			1829: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    182d:	mov    rcx,rax
    1830:	mov    r15,rax
    1833:	test   rax,rcx
    1836:	jne    1844 <botlish_fn_6+0xd0>
    183c:	mov    rdi,r13
    183f:	jmp    1964 <botlish_fn_6+0x1f0>
    1844:	mov    rax,r15
    1847:	mov    QWORD PTR [r12+0x8],rax
    184c:	mov    rsi,r15
    184f:	mov    rdi,r13
    1852:	call   1857 <botlish_fn_6+0xe3>
			1853: R_X86_64_PLT32	rt_list_len-0x4
    1857:	mov    ecx,0x1
    185c:	sar    rax,1
    185f:	cmp    rax,0x1
    1863:	je     18b4 <botlish_fn_6+0x140>
    1869:	mov    rdx,QWORD PTR [rbx+0x20]
    186d:	mov    rsi,QWORD PTR [rdx]
    1870:	mov    QWORD PTR [r12],rsi
    1874:	mov    QWORD PTR [r12+0x10],0x1
    187d:	mov    rdi,r13
    1880:	mov    rdi,QWORD PTR [rdi+0x10]
    1884:	mov    r8,QWORD PTR [rdi+0x98]
    188b:	mov    QWORD PTR [r12+0x18],r8
    1890:	mov    rdx,r15
    1893:	mov    rdi,r13
    1896:	call   189b <botlish_fn_6+0x127>
			1897: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    189b:	test   rax,rax
    189e:	jne    18ac <botlish_fn_6+0x138>
    18a4:	mov    rdi,r13
    18a7:	jmp    1964 <botlish_fn_6+0x1f0>
    18ac:	mov    rdi,r13
    18af:	jmp    199a <botlish_fn_6+0x226>
    18b4:	mov    rdx,r15
    18b7:	mov    QWORD PTR [rsp],rcx
    18bb:	mov    r10,QWORD PTR [rdx+0x8]
    18bf:	mov    r15,rdx
    18c2:	test   r10,r10
    18c5:	jne    18f3 <botlish_fn_6+0x17f>
    18cb:	mov    rdx,QWORD PTR [rsp]
    18cf:	mov    rsi,r15
    18d2:	mov    rdi,r13
    18d5:	call   18da <botlish_fn_6+0x166>
			18d6: R_X86_64_PLT32	rt_list_get-0x4
    18da:	test   rax,rax
    18dd:	jne    18eb <botlish_fn_6+0x177>
    18e3:	mov    rdi,r13
    18e6:	jmp    1964 <botlish_fn_6+0x1f0>
    18eb:	mov    rsi,rax
    18ee:	jmp    18fd <botlish_fn_6+0x189>
    18f3:	mov    rdx,r15
    18f6:	mov    rax,QWORD PTR [rdx+0x10]
    18fa:	mov    rsi,QWORD PTR [rax]
    18fd:	mov    QWORD PTR [r12+0x10],rsi
    1902:	mov    rdi,r13
    1905:	call   190a <botlish_fn_6+0x196>
			1906: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    190a:	test   rax,rax
    190d:	jne    191b <botlish_fn_6+0x1a7>
    1913:	mov    rdi,r13
    1916:	jmp    1964 <botlish_fn_6+0x1f0>
    191b:	cmp    rax,0x6
    191f:	je     1994 <botlish_fn_6+0x220>
    1925:	mov    rax,QWORD PTR [rbx+0x20]
    1929:	mov    rsi,QWORD PTR [rax]
    192c:	mov    QWORD PTR [r12],rsi
    1930:	mov    QWORD PTR [r12+0x10],0x1
    1939:	mov    rdi,r13
    193c:	mov    rax,QWORD PTR [rdi+0x10]
    1940:	mov    r8,QWORD PTR [rax+0x98]
    1947:	mov    QWORD PTR [r12+0x18],r8
    194c:	mov    rcx,QWORD PTR [rsp]
    1950:	mov    rdx,r15
    1953:	call   1958 <botlish_fn_6+0x1e4>
			1954: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    1958:	test   rax,rax
    195b:	jne    1997 <botlish_fn_6+0x223>
    1961:	mov    rdi,r13
    1964:	mov    rdi,r13
    1967:	mov    QWORD PTR [rdi],r12
    196a:	xor    rax,rax
    196d:	mov    rbx,QWORD PTR [rsp+0x10]
    1972:	mov    r12,QWORD PTR [rsp+0x18]
    1977:	mov    r13,QWORD PTR [rsp+0x20]
    197c:	mov    r14,QWORD PTR [rsp+0x28]
    1981:	mov    r15,QWORD PTR [rsp+0x30]
    1986:	add    rsp,0x40
    198a:	mov    rsp,rbp
    198d:	pop    rbp
    198e:	ret
    198f:	jmp    1997 <botlish_fn_6+0x223>
    1994:	mov    rax,r14
    1997:	mov    rdi,r13
    199a:	mov    rdi,r13
    199d:	mov    QWORD PTR [rdi],r12
    19a0:	mov    rbx,QWORD PTR [rsp+0x10]
    19a5:	mov    r12,QWORD PTR [rsp+0x18]
    19aa:	mov    r13,QWORD PTR [rsp+0x20]
    19af:	mov    r14,QWORD PTR [rsp+0x28]
    19b4:	mov    r15,QWORD PTR [rsp+0x30]
    19b9:	add    rsp,0x40
    19bd:	mov    rsp,rbp
    19c0:	pop    rbp
    19c1:	ret
    19c2:	mov    r13,rdi
    19c5:	call   19ca <botlish_fn_6+0x256>
			19c6: R_X86_64_PLT32	rt_stack_overflow-0x4
    19ca:	xor    rax,rax
    19cd:	mov    rbx,QWORD PTR [rsp+0x10]
    19d2:	mov    r12,QWORD PTR [rsp+0x18]
    19d7:	mov    r13,QWORD PTR [rsp+0x20]
    19dc:	mov    r14,QWORD PTR [rsp+0x28]
    19e1:	mov    r15,QWORD PTR [rsp+0x30]
    19e6:	add    rsp,0x40
    19ea:	mov    rsp,rbp
    19ed:	pop    rbp
    19ee:	ret

00000000000019ef <botlish_entry_6: esc_char<generic>>:
    19ef:	push   rbp
    19f0:	mov    rbp,rsp
    19f3:	mov    rdx,QWORD PTR [rdx]
    19f6:	call   19fb <botlish_entry_6+0xc>
			19f7: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    19fb:	mov    rsp,rbp
    19fe:	pop    rbp
    19ff:	ret

0000000000001a00 <botlish_fn_7: esc_from<generic>>:
    1a00:	push   rbp
    1a01:	mov    rbp,rsp
    1a04:	sub    rsp,0x50
    1a08:	mov    QWORD PTR [rsp+0x20],rbx
    1a0d:	mov    QWORD PTR [rsp+0x28],r12
    1a12:	mov    QWORD PTR [rsp+0x30],r13
    1a17:	mov    QWORD PTR [rsp+0x38],r14
    1a1c:	mov    QWORD PTR [rsp+0x40],r15
    1a21:	mov    r12,rsi
    1a24:	mov    r14,QWORD PTR [rdi]
    1a27:	mov    rax,QWORD PTR [rdi+0x8]
    1a2b:	lea    rsi,[r14+0x38]
    1a2f:	cmp    rsi,rax
    1a32:	ja     1da1 <botlish_fn_7+0x3a1>
    1a38:	lea    rax,[r14+0x38]
    1a3c:	mov    QWORD PTR [rdi],rax
    1a3f:	mov    r15,rdi
    1a42:	mov    QWORD PTR [r14+0x28],0x0
    1a4a:	mov    QWORD PTR [r14+0x30],0x0
    1a52:	mov    QWORD PTR [r14],rdx
    1a55:	mov    QWORD PTR [r14+0x8],rcx
    1a59:	mov    QWORD PTR [r14+0x10],r8
    1a5d:	mov    QWORD PTR [rsp],rcx
    1a61:	mov    QWORD PTR [rsp+0x8],r8
    1a66:	xor    eax,eax
    1a68:	test   rdx,0x7
    1a6f:	je     1a7d <botlish_fn_7+0x7d>
    1a75:	mov    rsi,rdx
    1a78:	jmp    1a89 <botlish_fn_7+0x89>
    1a7d:	movzx  rax,BYTE PTR [rdx]
    1a81:	mov    rsi,rdx
    1a84:	cmp    al,0x2
    1a86:	sete   al
    1a89:	test   al,al
    1a8b:	jne    1ab1 <botlish_fn_7+0xb1>
    1a91:	mov    rdi,r15
    1a94:	mov    rax,QWORD PTR [rdi+0x10]
    1a98:	mov    rcx,QWORD PTR [rax+0xd8]
    1a9f:	mov    edx,0x1
    1aa4:	call   1aa9 <botlish_fn_7+0xa9>
			1aa5: R_X86_64_PLT32	rt_type_error-0x4
    1aa9:	mov    rdi,r15
    1aac:	jmp    1d2d <botlish_fn_7+0x32d>
    1ab1:	mov    rbx,rsi
    1ab4:	mov    rdi,r15
    1ab7:	call   1abc <botlish_fn_7+0xbc>
			1ab8: R_X86_64_PLT32	rt_str_len-0x4
    1abc:	mov    edx,0x1
    1ac1:	mov    QWORD PTR [rsp+0x18],rdx
    1ac6:	mov    ecx,0x1
    1acb:	mov    rsi,QWORD PTR [rsp]
    1acf:	test   rsi,0x1
    1ad6:	jne    1afe <botlish_fn_7+0xfe>
    1adc:	xor    ecx,ecx
    1ade:	mov    rsi,QWORD PTR [rsp]
    1ae2:	test   rsi,0x7
    1ae9:	jne    1afe <botlish_fn_7+0xfe>
    1aef:	mov    rsi,QWORD PTR [rsp]
    1af3:	movzx  rcx,BYTE PTR [rsi]
    1af7:	rex cmp cl,0x1
    1afb:	sete   cl
    1afe:	test   cl,cl
    1b00:	jne    1b28 <botlish_fn_7+0x128>
    1b06:	mov    rdi,r15
    1b09:	mov    rax,QWORD PTR [rdi+0x10]
    1b0d:	mov    rcx,QWORD PTR [rax+0xb8]
    1b14:	xor    rdx,rdx
    1b17:	mov    rsi,QWORD PTR [rsp]
    1b1b:	call   1b20 <botlish_fn_7+0x120>
			1b1c: R_X86_64_PLT32	rt_type_error-0x4
    1b20:	mov    rdi,r15
    1b23:	jmp    1d2d <botlish_fn_7+0x32d>
    1b28:	mov    rsi,QWORD PTR [rsp]
    1b2c:	mov    rcx,rsi
    1b2f:	and    rcx,rax
    1b32:	mov    rdx,rax
    1b35:	test   rcx,0x1
    1b3c:	jne    1b63 <botlish_fn_7+0x163>
    1b42:	mov    rsi,QWORD PTR [rsp]
    1b46:	mov    rdi,r15
    1b49:	call   1b4e <botlish_fn_7+0x14e>
			1b4a: R_X86_64_PLT32	rt_int_cmp-0x4
    1b4e:	mov    esi,0x2
    1b53:	test   rax,rax
    1b56:	cmovge rsi,QWORD PTR [rip+0x272]        # 1dd0 <botlish_fn_7+0x3d0>
    1b5e:	jmp    1b77 <botlish_fn_7+0x177>
    1b63:	mov    esi,0x2
    1b68:	mov    rax,QWORD PTR [rsp]
    1b6c:	cmp    rax,rdx
    1b6f:	cmovge rsi,QWORD PTR [rip+0x259]        # 1dd0 <botlish_fn_7+0x3d0>
    1b77:	cmp    rsi,0x6
    1b7b:	je     1d74 <botlish_fn_7+0x374>
    1b81:	mov    QWORD PTR [r14+0x18],r12
    1b85:	mov    QWORD PTR [r14+0x20],0x3
    1b8d:	mov    rsi,QWORD PTR [rsp]
    1b91:	test   rsi,0x1
    1b98:	je     1bbf <botlish_fn_7+0x1bf>
    1b9e:	mov    rsi,QWORD PTR [rsp]
    1ba2:	mov    rax,rsi
    1ba5:	add    rax,0x2
    1ba9:	mov    rcx,rax
    1bac:	seto   al
    1baf:	test   al,al
    1bb1:	jne    1bbf <botlish_fn_7+0x1bf>
    1bb7:	mov    r13,rcx
    1bba:	jmp    1bd6 <botlish_fn_7+0x1d6>
    1bbf:	mov    edx,0x3
    1bc4:	mov    rsi,QWORD PTR [rsp]
    1bc8:	mov    rdi,r15
    1bcb:	call   1bd0 <botlish_fn_7+0x1d0>
			1bcc: R_X86_64_PLT32	rt_int_add-0x4
    1bd0:	mov    rcx,rax
    1bd3:	mov    r13,rcx
    1bd6:	mov    QWORD PTR [r14+0x20],r13
    1bda:	mov    rax,QWORD PTR [r12+0x20]
    1bdf:	mov    rsi,QWORD PTR [rax]
    1be2:	mov    QWORD PTR [r14+0x28],rsi
    1be6:	mov    QWORD PTR [rsp+0x10],rsi
    1beb:	mov    QWORD PTR [r14+0x30],0x3
    1bf3:	mov    rsi,QWORD PTR [rsp]
    1bf7:	test   rsi,0x1
    1bfe:	je     1c1c <botlish_fn_7+0x21c>
    1c04:	mov    rsi,QWORD PTR [rsp]
    1c08:	mov    rcx,rsi
    1c0b:	add    rcx,0x2
    1c0f:	seto   sil
    1c13:	test   sil,sil
    1c16:	je     1c30 <botlish_fn_7+0x230>
    1c1c:	mov    edx,0x3
    1c21:	mov    rsi,QWORD PTR [rsp]
    1c25:	mov    rdi,r15
    1c28:	call   1c2d <botlish_fn_7+0x22d>
			1c29: R_X86_64_PLT32	rt_int_add-0x4
    1c2d:	mov    rcx,rax
    1c30:	mov    QWORD PTR [r14+0x30],rcx
    1c34:	mov    rdx,QWORD PTR [rsp]
    1c38:	mov    rsi,rbx
    1c3b:	mov    rdi,r15
    1c3e:	call   1c43 <botlish_fn_7+0x243>
			1c3f: R_X86_64_PLT32	rt_substr-0x4
    1c43:	test   rax,rax
    1c46:	jne    1c54 <botlish_fn_7+0x254>
    1c4c:	mov    rdi,r15
    1c4f:	jmp    1d2d <botlish_fn_7+0x32d>
    1c54:	mov    QWORD PTR [r14+0x8],rax
    1c58:	mov    rdx,rax
    1c5b:	mov    rsi,QWORD PTR [rsp+0x10]
    1c60:	mov    rdi,r15
    1c63:	call   1c68 <botlish_fn_7+0x268>
			1c64: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    1c68:	test   rax,rax
    1c6b:	jne    1c79 <botlish_fn_7+0x279>
    1c71:	mov    rdi,r15
    1c74:	jmp    1d2d <botlish_fn_7+0x32d>
    1c79:	mov    QWORD PTR [r14+0x8],rax
    1c7d:	xor    ecx,ecx
    1c7f:	mov    rsi,QWORD PTR [rsp+0x8]
    1c84:	test   rsi,0x7
    1c8b:	jne    1c9c <botlish_fn_7+0x29c>
    1c91:	movzx  rcx,BYTE PTR [rsi]
    1c95:	rex cmp cl,0x2
    1c99:	sete   cl
    1c9c:	test   cl,cl
    1c9e:	jne    1cc4 <botlish_fn_7+0x2c4>
    1ca4:	mov    rdi,r15
    1ca7:	mov    rax,QWORD PTR [rdi+0x10]
    1cab:	mov    rcx,QWORD PTR [rax+0xc8]
    1cb2:	mov    rdx,QWORD PTR [rsp+0x18]
    1cb7:	call   1cbc <botlish_fn_7+0x2bc>
			1cb8: R_X86_64_PLT32	rt_type_error-0x4
    1cbc:	mov    rdi,r15
    1cbf:	jmp    1d2d <botlish_fn_7+0x32d>
    1cc4:	mov    rdx,QWORD PTR [rsp+0x18]
    1cc9:	xor    r11d,r11d
    1ccc:	test   rax,0x7
    1cd2:	je     1ce0 <botlish_fn_7+0x2e0>
    1cd8:	mov    r8,rax
    1cdb:	jmp    1cef <botlish_fn_7+0x2ef>
    1ce0:	movzx  rcx,BYTE PTR [rax]
    1ce4:	mov    r8,rax
    1ce7:	rex cmp cl,0x2
    1ceb:	sete   r11b
    1cef:	test   r11b,r11b
    1cf2:	jne    1d16 <botlish_fn_7+0x316>
    1cf8:	mov    rdi,r15
    1cfb:	mov    rax,QWORD PTR [rdi+0x10]
    1cff:	mov    rcx,QWORD PTR [rax+0xc8]
    1d06:	mov    rsi,r8
    1d09:	call   1d0e <botlish_fn_7+0x30e>
			1d0a: R_X86_64_PLT32	rt_type_error-0x4
    1d0e:	mov    rdi,r15
    1d11:	jmp    1d2d <botlish_fn_7+0x32d>
    1d16:	mov    rdx,r8
    1d19:	mov    rdi,r15
    1d1c:	call   1d21 <botlish_fn_7+0x321>
			1d1d: R_X86_64_PLT32	rt_str_cat-0x4
    1d21:	test   rax,rax
    1d24:	jne    1d58 <botlish_fn_7+0x358>
    1d2a:	mov    rdi,r15
    1d2d:	mov    rdi,r15
    1d30:	mov    QWORD PTR [rdi],r14
    1d33:	xor    rax,rax
    1d36:	mov    rbx,QWORD PTR [rsp+0x20]
    1d3b:	mov    r12,QWORD PTR [rsp+0x28]
    1d40:	mov    r13,QWORD PTR [rsp+0x30]
    1d45:	mov    r14,QWORD PTR [rsp+0x38]
    1d4a:	mov    r15,QWORD PTR [rsp+0x40]
    1d4f:	add    rsp,0x50
    1d53:	mov    rsp,rbp
    1d56:	pop    rbp
    1d57:	ret
    1d58:	mov    QWORD PTR [r14],rbx
    1d5b:	mov    QWORD PTR [r14+0x8],r13
    1d5f:	mov    QWORD PTR [r14+0x10],rax
    1d63:	mov    rdx,rbx
    1d66:	mov    QWORD PTR [rsp],r13
    1d6a:	mov    QWORD PTR [rsp+0x8],rax
    1d6f:	jmp    1a66 <botlish_fn_7+0x66>
    1d74:	mov    rdi,r15
    1d77:	mov    QWORD PTR [rdi],r14
    1d7a:	mov    rax,QWORD PTR [rsp+0x8]
    1d7f:	mov    rbx,QWORD PTR [rsp+0x20]
    1d84:	mov    r12,QWORD PTR [rsp+0x28]
    1d89:	mov    r13,QWORD PTR [rsp+0x30]
    1d8e:	mov    r14,QWORD PTR [rsp+0x38]
    1d93:	mov    r15,QWORD PTR [rsp+0x40]
    1d98:	add    rsp,0x50
    1d9c:	mov    rsp,rbp
    1d9f:	pop    rbp
    1da0:	ret
    1da1:	mov    r15,rdi
    1da4:	call   1da9 <botlish_fn_7+0x3a9>
			1da5: R_X86_64_PLT32	rt_stack_overflow-0x4
    1da9:	xor    rax,rax
    1dac:	mov    rbx,QWORD PTR [rsp+0x20]
    1db1:	mov    r12,QWORD PTR [rsp+0x28]
    1db6:	mov    r13,QWORD PTR [rsp+0x30]
    1dbb:	mov    r14,QWORD PTR [rsp+0x38]
    1dc0:	mov    r15,QWORD PTR [rsp+0x40]
    1dc5:	add    rsp,0x50
    1dc9:	mov    rsp,rbp
    1dcc:	pop    rbp
    1dcd:	ret
    1dce:	add    BYTE PTR [rax],al
    1dd0:	(bad)
    1dd1:	add    BYTE PTR [rax],al
    1dd3:	add    BYTE PTR [rax],al
    1dd5:	add    BYTE PTR [rax],al
	...

0000000000001dd8 <botlish_entry_7: esc_from<generic>>:
    1dd8:	push   rbp
    1dd9:	mov    rbp,rsp
    1ddc:	mov    r9,QWORD PTR [rdx]
    1ddf:	mov    rcx,QWORD PTR [rdx+0x8]
    1de3:	mov    r8,QWORD PTR [rdx+0x10]
    1de7:	mov    rdx,r9
    1dea:	call   1def <botlish_entry_7+0x17>
			1deb: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
    1def:	mov    rsp,rbp
    1df2:	pop    rbp
    1df3:	ret
    1df4:	add    BYTE PTR [rax],al
	...

0000000000001df8 <botlish_fn_8: check<int, int, str, str>>:
    1df8:	push   rbp
    1df9:	mov    rbp,rsp
    1dfc:	sub    rsp,0x40
    1e00:	mov    QWORD PTR [rsp+0x10],rbx
    1e05:	mov    QWORD PTR [rsp+0x18],r12
    1e0a:	mov    QWORD PTR [rsp+0x20],r13
    1e0f:	mov    QWORD PTR [rsp+0x28],r14
    1e14:	mov    QWORD PTR [rsp+0x30],r15
    1e19:	mov    r13,QWORD PTR [rdi]
    1e1c:	mov    rax,QWORD PTR [rdi+0x8]
    1e20:	lea    r9,[r13+0x28]
    1e24:	cmp    r9,rax
    1e27:	ja     1fe3 <botlish_fn_8+0x1eb>
    1e2d:	lea    rax,[r13+0x28]
    1e31:	mov    QWORD PTR [rdi],rax
    1e34:	mov    r14,rdi
    1e37:	mov    QWORD PTR [r13+0x20],0x0
    1e3f:	mov    QWORD PTR [r13+0x0],rsi
    1e43:	mov    QWORD PTR [r13+0x8],rdx
    1e47:	mov    QWORD PTR [r13+0x10],rcx
    1e4b:	mov    r12,rcx
    1e4e:	mov    QWORD PTR [r13+0x18],r8
    1e52:	mov    r15,r8
    1e55:	mov    rbx,rsi
    1e58:	mov    QWORD PTR [rsp],rdx
    1e5c:	test   rbx,0x1
    1e63:	jne    1e8e <botlish_fn_8+0x96>
    1e69:	mov    edx,0x1
    1e6e:	mov    rsi,rbx
    1e71:	mov    rdi,r14
    1e74:	call   1e79 <botlish_fn_8+0x81>
			1e75: R_X86_64_PLT32	rt_int_cmp-0x4
    1e79:	mov    ecx,0x2
    1e7e:	test   rax,rax
    1e81:	cmovle rcx,QWORD PTR [rip+0x187]        # 2010 <botlish_fn_8+0x218>
    1e89:	jmp    1e9f <botlish_fn_8+0xa7>
    1e8e:	mov    ecx,0x2
    1e93:	cmp    rbx,0x1
    1e97:	cmovle rcx,QWORD PTR [rip+0x171]        # 2010 <botlish_fn_8+0x218>
    1e9f:	cmp    rcx,0x6
    1ea3:	je     1fb7 <botlish_fn_8+0x1bf>
    1ea9:	mov    rdi,r14
    1eac:	mov    rax,QWORD PTR [rdi+0x10]
    1eb0:	mov    rax,QWORD PTR [rax+0xe0]
    1eb7:	mov    rsi,r12
    1eba:	call   1ebf <botlish_fn_8+0xc7>
			1ebb: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    1ebf:	test   rax,rax
    1ec2:	jne    1ed0 <botlish_fn_8+0xd8>
    1ec8:	mov    rdi,r14
    1ecb:	jmp    1f0e <botlish_fn_8+0x116>
    1ed0:	cmp    rax,0x6
    1ed4:	je     1eec <botlish_fn_8+0xf4>
    1eda:	mov    edx,0x1
    1edf:	mov    QWORD PTR [r13+0x0],0x1
    1ee7:	jmp    1f56 <botlish_fn_8+0x15e>
    1eec:	mov    rdi,r14
    1eef:	mov    rsi,QWORD PTR [rdi+0x10]
    1ef3:	mov    rsi,QWORD PTR [rsi+0xe8]
    1efa:	mov    rsi,r12
    1efd:	call   1f02 <botlish_fn_8+0x10a>
			1efe: R_X86_64_PLT32	botlish_fn_20-0x4 ; <str>
    1f02:	test   rax,rax
    1f05:	jne    1f39 <botlish_fn_8+0x141>
    1f0b:	mov    rdi,r14
    1f0e:	mov    rdi,r14
    1f11:	mov    QWORD PTR [rdi],r13
    1f14:	xor    rax,rax
    1f17:	mov    rbx,QWORD PTR [rsp+0x10]
    1f1c:	mov    r12,QWORD PTR [rsp+0x18]
    1f21:	mov    r13,QWORD PTR [rsp+0x20]
    1f26:	mov    r14,QWORD PTR [rsp+0x28]
    1f2b:	mov    r15,QWORD PTR [rsp+0x30]
    1f30:	add    rsp,0x40
    1f34:	mov    rsp,rbp
    1f37:	pop    rbp
    1f38:	ret
    1f39:	cmp    rax,0x6
    1f3d:	je     1f4d <botlish_fn_8+0x155>
    1f43:	mov    edx,0x1
    1f48:	jmp    1f52 <botlish_fn_8+0x15a>
    1f4d:	mov    edx,0x3
    1f52:	mov    QWORD PTR [r13+0x0],rdx
    1f56:	sar    rbx,1
    1f59:	sub    rbx,0x1
    1f5d:	shl    rbx,1
    1f60:	or     rbx,0x1
    1f64:	mov    QWORD PTR [r13+0x20],rbx
    1f68:	mov    rsi,QWORD PTR [rsp]
    1f6c:	mov    rax,rsi
    1f6f:	and    rax,rdx
    1f72:	test   rax,0x1
    1f78:	je     1f93 <botlish_fn_8+0x19b>
    1f7e:	lea    rcx,[rdx-0x1]
    1f82:	mov    rax,rsi
    1f85:	add    rax,rcx
    1f88:	seto   cl
    1f8b:	test   cl,cl
    1f8d:	je     1f9b <botlish_fn_8+0x1a3>
    1f93:	mov    rdi,r14
    1f96:	call   1f9b <botlish_fn_8+0x1a3>
			1f97: R_X86_64_PLT32	rt_int_add-0x4
    1f9b:	mov    QWORD PTR [r13+0x0],rbx
    1f9f:	mov    QWORD PTR [r13+0x8],rax
    1fa3:	mov    QWORD PTR [r13+0x10],r12
    1fa7:	mov    r8,r15
    1faa:	mov    QWORD PTR [r13+0x18],r8
    1fae:	mov    QWORD PTR [rsp],rax
    1fb2:	jmp    1e5c <botlish_fn_8+0x64>
    1fb7:	mov    rdi,r14
    1fba:	mov    QWORD PTR [rdi],r13
    1fbd:	mov    rax,QWORD PTR [rsp]
    1fc1:	mov    rbx,QWORD PTR [rsp+0x10]
    1fc6:	mov    r12,QWORD PTR [rsp+0x18]
    1fcb:	mov    r13,QWORD PTR [rsp+0x20]
    1fd0:	mov    r14,QWORD PTR [rsp+0x28]
    1fd5:	mov    r15,QWORD PTR [rsp+0x30]
    1fda:	add    rsp,0x40
    1fde:	mov    rsp,rbp
    1fe1:	pop    rbp
    1fe2:	ret
    1fe3:	mov    r14,rdi
    1fe6:	call   1feb <botlish_fn_8+0x1f3>
			1fe7: R_X86_64_PLT32	rt_stack_overflow-0x4
    1feb:	xor    rax,rax
    1fee:	mov    rbx,QWORD PTR [rsp+0x10]
    1ff3:	mov    r12,QWORD PTR [rsp+0x18]
    1ff8:	mov    r13,QWORD PTR [rsp+0x20]
    1ffd:	mov    r14,QWORD PTR [rsp+0x28]
    2002:	mov    r15,QWORD PTR [rsp+0x30]
    2007:	add    rsp,0x40
    200b:	mov    rsp,rbp
    200e:	pop    rbp
    200f:	ret
    2010:	(bad)
    2011:	add    BYTE PTR [rax],al
    2013:	add    BYTE PTR [rax],al
    2015:	add    BYTE PTR [rax],al
	...

0000000000002018 <botlish_entry_8: check<int, int, str, str>>:
    2018:	push   rbp
    2019:	mov    rbp,rsp
    201c:	mov    rsi,QWORD PTR [rdx]
    201f:	mov    r9,QWORD PTR [rdx+0x8]
    2023:	mov    rcx,QWORD PTR [rdx+0x10]
    2027:	mov    r8,QWORD PTR [rdx+0x18]
    202b:	mov    rdx,r9
    202e:	call   2033 <botlish_entry_8+0x1b>
			202f: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
    2033:	mov    rsp,rbp
    2036:	pop    rbp
    2037:	ret

0000000000002038 <botlish_fn_9: <str>>:
    2038:	push   rbp
    2039:	mov    rbp,rsp
    203c:	sub    rsp,0xc0
    2043:	mov    QWORD PTR [rsp+0x90],rbx
    204b:	mov    QWORD PTR [rsp+0x98],r12
    2053:	mov    QWORD PTR [rsp+0xa0],r13
    205b:	mov    QWORD PTR [rsp+0xa8],r14
    2063:	mov    QWORD PTR [rsp+0xb0],r15
    206b:	mov    r12,QWORD PTR [rdi]
    206e:	mov    rax,QWORD PTR [rdi+0x8]
    2072:	lea    rcx,[r12+0x28]
    2077:	cmp    rcx,rax
    207a:	ja     248c <botlish_fn_9+0x454>
    2080:	lea    rax,[r12+0x28]
    2085:	mov    QWORD PTR [rdi],rax
    2088:	mov    QWORD PTR [rsp+0x78],rdi
    208d:	mov    QWORD PTR [r12+0x10],0x0
    2096:	mov    QWORD PTR [r12+0x18],0x0
    209f:	mov    QWORD PTR [r12+0x20],0x0
    20a8:	mov    QWORD PTR [r12],rsi
    20ac:	mov    r13,rsi
    20af:	mov    rsi,r13
    20b2:	mov    rdi,QWORD PTR [rsp+0x78]
    20b7:	call   20bc <botlish_fn_9+0x84>
			20b8: R_X86_64_PLT32	rt_str_len-0x4
    20bc:	mov    rbx,rax
    20bf:	mov    QWORD PTR [r12+0x8],rbx
    20c4:	lea    r8,[rsp]
    20c8:	mov    QWORD PTR [rsp],r13
    20cc:	mov    esi,0xb
    20d1:	mov    rdx,QWORD PTR [rip+0x0]        # 20d8 <botlish_fn_9+0xa0>
			20d4: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    20d8:	mov    r13d,0x1
    20de:	mov    rcx,r13
    20e1:	mov    rdi,QWORD PTR [rsp+0x78]
    20e6:	call   20eb <botlish_fn_9+0xb3>
			20e7: R_X86_64_PLT32	rt_closure_new-0x4
    20eb:	mov    r14,rax
    20ee:	mov    QWORD PTR [r12],rax
    20f2:	lea    r8,[rsp+0x8]
    20f7:	mov    QWORD PTR [rsp+0x8],rbx
    20fc:	mov    QWORD PTR [rsp+0x10],rax
    2101:	mov    esi,0xf
    2106:	mov    rdx,QWORD PTR [rip+0x0]        # 210d <botlish_fn_9+0xd5>
			2109: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_local<generic>
    210d:	mov    r15d,0x2
    2113:	mov    rcx,r15
    2116:	mov    rdi,QWORD PTR [rsp+0x78]
    211b:	call   2120 <botlish_fn_9+0xe8>
			211c: R_X86_64_PLT32	rt_closure_new-0x4
    2120:	mov    rcx,rax
    2123:	mov    QWORD PTR [rsp+0x88],rax
    212b:	mov    QWORD PTR [r12+0x10],rcx
    2130:	lea    r8,[rsp+0x18]
    2135:	mov    QWORD PTR [rsp+0x18],rbx
    213a:	mov    rax,r14
    213d:	mov    QWORD PTR [rsp+0x20],rax
    2142:	mov    esi,0x10
    2147:	mov    rdx,QWORD PTR [rip+0x0]        # 214e <botlish_fn_9+0x116>
			214a: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; scan_label<generic>
    214e:	mov    rcx,r15
    2151:	mov    rdi,QWORD PTR [rsp+0x78]
    2156:	call   215b <botlish_fn_9+0x123>
			2157: R_X86_64_PLT32	rt_closure_new-0x4
    215b:	mov    QWORD PTR [r12+0x18],rax
    2160:	mov    QWORD PTR [rsp+0x80],rax
    2168:	lea    r8,[rsp+0x28]
    216d:	mov    QWORD PTR [rsp+0x28],rbx
    2172:	mov    QWORD PTR [rsp+0x30],r14
    2177:	mov    esi,0x11
    217c:	mov    rdx,QWORD PTR [rip+0x0]        # 2183 <botlish_fn_9+0x14b>
			217f: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; scan_alpha<generic>
    2183:	mov    rcx,r15
    2186:	mov    rdi,QWORD PTR [rsp+0x78]
    218b:	call   2190 <botlish_fn_9+0x158>
			218c: R_X86_64_PLT32	rt_closure_new-0x4
    2190:	mov    QWORD PTR [r12+0x20],rax
    2195:	lea    r8,[rsp+0x38]
    219a:	mov    QWORD PTR [rsp+0x38],rax
    219f:	mov    QWORD PTR [rsp+0x40],rbx
    21a4:	mov    esi,0x12
    21a9:	mov    rdx,QWORD PTR [rip+0x0]        # 21b0 <botlish_fn_9+0x178>
			21ac: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; tld_ok<generic>
    21b0:	mov    rcx,r15
    21b3:	mov    rdi,QWORD PTR [rsp+0x78]
    21b8:	call   21bd <botlish_fn_9+0x185>
			21b9: R_X86_64_PLT32	rt_closure_new-0x4
    21bd:	mov    QWORD PTR [r12+0x20],rax
    21c2:	lea    r8,[rsp+0x48]
    21c7:	mov    rcx,QWORD PTR [rsp+0x80]
    21cf:	mov    QWORD PTR [rsp+0x48],rcx
    21d4:	mov    QWORD PTR [rsp+0x50],rbx
    21d9:	mov    QWORD PTR [rsp+0x58],r14
    21de:	mov    QWORD PTR [rsp+0x60],rax
    21e3:	mov    esi,0x13
    21e8:	mov    rdx,QWORD PTR [rip+0x0]        # 21ef <botlish_fn_9+0x1b7>
			21eb: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; domain_loop<generic>
    21ef:	mov    ecx,0x4
    21f4:	mov    rdi,QWORD PTR [rsp+0x78]
    21f9:	call   21fe <botlish_fn_9+0x1c6>
			21fa: R_X86_64_PLT32	rt_closure_new-0x4
    21fe:	mov    QWORD PTR [r12+0x18],rax
    2203:	mov    r15,rax
    2206:	mov    QWORD PTR [r12+0x20],0x1
    220f:	mov    rdx,r13
    2212:	mov    rsi,QWORD PTR [rsp+0x88]
    221a:	mov    rdi,QWORD PTR [rsp+0x78]
    221f:	call   2224 <botlish_fn_9+0x1ec>
			2220: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    2224:	mov    rcx,rax
    2227:	mov    r13,rax
    222a:	test   rax,rcx
    222d:	jne    223d <botlish_fn_9+0x205>
    2233:	mov    rdi,QWORD PTR [rsp+0x78]
    2238:	jmp    23a2 <botlish_fn_9+0x36a>
    223d:	mov    rax,r13
    2240:	mov    QWORD PTR [r12+0x10],rax
    2245:	test   rax,0x1
    224b:	jne    2279 <botlish_fn_9+0x241>
    2251:	mov    edx,0x1
    2256:	mov    rsi,r13
    2259:	mov    rdi,QWORD PTR [rsp+0x78]
    225e:	call   2263 <botlish_fn_9+0x22b>
			225f: R_X86_64_PLT32	rt_int_cmp-0x4
    2263:	mov    r10d,0x2
    2269:	test   rax,rax
    226c:	cmove  r10,QWORD PTR [rip+0x25c]        # 24d0 <botlish_fn_9+0x498>
    2274:	jmp    228b <botlish_fn_9+0x253>
    2279:	mov    r10d,0x2
    227f:	cmp    r13,0x1
    2283:	cmove  r10,QWORD PTR [rip+0x245]        # 24d0 <botlish_fn_9+0x498>
    228b:	cmp    r10,0x6
    228f:	je     2446 <botlish_fn_9+0x40e>
    2295:	mov    rax,r13
    2298:	and    rax,rbx
    229b:	test   rax,0x1
    22a1:	jne    22cc <botlish_fn_9+0x294>
    22a7:	mov    rdx,rbx
    22aa:	mov    rsi,r13
    22ad:	mov    rdi,QWORD PTR [rsp+0x78]
    22b2:	call   22b7 <botlish_fn_9+0x27f>
			22b3: R_X86_64_PLT32	rt_int_cmp-0x4
    22b7:	mov    ecx,0x2
    22bc:	test   rax,rax
    22bf:	cmovge rcx,QWORD PTR [rip+0x209]        # 24d0 <botlish_fn_9+0x498>
    22c7:	jmp    22dc <botlish_fn_9+0x2a4>
    22cc:	mov    ecx,0x2
    22d1:	cmp    r13,rbx
    22d4:	cmovge rcx,QWORD PTR [rip+0x1f4]        # 24d0 <botlish_fn_9+0x498>
    22dc:	cmp    rcx,0x6
    22e0:	je     2437 <botlish_fn_9+0x3ff>
    22e6:	lea    rcx,[rsp+0x68]
    22eb:	mov    rsi,r14
    22ee:	mov    rdx,r13
    22f1:	mov    rdi,QWORD PTR [rsp+0x78]
    22f6:	call   22fb <botlish_fn_9+0x2c3>
			22f7: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    22fb:	test   rax,rax
    22fe:	jne    230e <botlish_fn_9+0x2d6>
    2304:	mov    rdi,QWORD PTR [rsp+0x78]
    2309:	jmp    23a2 <botlish_fn_9+0x36a>
    230e:	mov    rdx,QWORD PTR [rsp+0x68]
    2313:	mov    rcx,QWORD PTR [rsp+0x70]
    2318:	mov    rdi,QWORD PTR [rsp+0x78]
    231d:	mov    rsi,QWORD PTR [rdi+0x10]
    2321:	mov    r8,QWORD PTR [rsi+0x100]
    2328:	mov    rsi,rax
    232b:	call   2330 <botlish_fn_9+0x2f8>
			232c: R_X86_64_PLT32	rt_str_region_eq-0x4
    2330:	cmp    rax,0x6
    2334:	je     2347 <botlish_fn_9+0x30f>
    233a:	mov    ecx,0x2
    233f:	mov    rax,rcx
    2342:	jmp    243c <botlish_fn_9+0x404>
    2347:	mov    QWORD PTR [r12],0x3
    234f:	test   r13,0x1
    2356:	je     236e <botlish_fn_9+0x336>
    235c:	mov    rdx,r13
    235f:	add    rdx,0x2
    2363:	seto   al
    2366:	test   al,al
    2368:	je     2383 <botlish_fn_9+0x34b>
    236e:	mov    edx,0x3
    2373:	mov    rsi,r13
    2376:	mov    rdi,QWORD PTR [rsp+0x78]
    237b:	call   2380 <botlish_fn_9+0x348>
			237c: R_X86_64_PLT32	rt_int_add-0x4
    2380:	mov    rdx,rax
    2383:	mov    QWORD PTR [r12],rdx
    2387:	mov    rsi,r15
    238a:	mov    rdi,QWORD PTR [rsp+0x78]
    238f:	call   2394 <botlish_fn_9+0x35c>
			2390: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    2394:	test   rax,rax
    2397:	jne    23e1 <botlish_fn_9+0x3a9>
    239d:	mov    rdi,QWORD PTR [rsp+0x78]
    23a2:	mov    rdi,QWORD PTR [rsp+0x78]
    23a7:	mov    QWORD PTR [rdi],r12
    23aa:	xor    rax,rax
    23ad:	mov    rbx,QWORD PTR [rsp+0x90]
    23b5:	mov    r12,QWORD PTR [rsp+0x98]
    23bd:	mov    r13,QWORD PTR [rsp+0xa0]
    23c5:	mov    r14,QWORD PTR [rsp+0xa8]
    23cd:	mov    r15,QWORD PTR [rsp+0xb0]
    23d5:	add    rsp,0xc0
    23dc:	mov    rsp,rbp
    23df:	pop    rbp
    23e0:	ret
    23e1:	mov    rcx,rax
    23e4:	and    rcx,rbx
    23e7:	mov    rsi,rax
    23ea:	mov    rax,rbx
    23ed:	test   rcx,0x1
    23f4:	jne    241f <botlish_fn_9+0x3e7>
    23fa:	mov    rdx,rax
    23fd:	mov    rdi,QWORD PTR [rsp+0x78]
    2402:	call   2407 <botlish_fn_9+0x3cf>
			2403: R_X86_64_PLT32	rt_int_cmp-0x4
    2407:	mov    ecx,0x2
    240c:	test   rax,rax
    240f:	mov    rax,rcx
    2412:	cmove  rax,QWORD PTR [rip+0xb6]        # 24d0 <botlish_fn_9+0x498>
    241a:	jmp    243c <botlish_fn_9+0x404>
    241f:	mov    rdx,rax
    2422:	mov    eax,0x2
    2427:	cmp    rsi,rdx
    242a:	cmove  rax,QWORD PTR [rip+0x9e]        # 24d0 <botlish_fn_9+0x498>
    2432:	jmp    243c <botlish_fn_9+0x404>
    2437:	mov    eax,0x2
    243c:	mov    rdi,QWORD PTR [rsp+0x78]
    2441:	jmp    2450 <botlish_fn_9+0x418>
    2446:	mov    eax,0x2
    244b:	mov    rdi,QWORD PTR [rsp+0x78]
    2450:	mov    rdi,QWORD PTR [rsp+0x78]
    2455:	mov    QWORD PTR [rdi],r12
    2458:	mov    rbx,QWORD PTR [rsp+0x90]
    2460:	mov    r12,QWORD PTR [rsp+0x98]
    2468:	mov    r13,QWORD PTR [rsp+0xa0]
    2470:	mov    r14,QWORD PTR [rsp+0xa8]
    2478:	mov    r15,QWORD PTR [rsp+0xb0]
    2480:	add    rsp,0xc0
    2487:	mov    rsp,rbp
    248a:	pop    rbp
    248b:	ret
    248c:	mov    QWORD PTR [rsp+0x78],rdi
    2491:	call   2496 <botlish_fn_9+0x45e>
			2492: R_X86_64_PLT32	rt_stack_overflow-0x4
    2496:	xor    rax,rax
    2499:	mov    rbx,QWORD PTR [rsp+0x90]
    24a1:	mov    r12,QWORD PTR [rsp+0x98]
    24a9:	mov    r13,QWORD PTR [rsp+0xa0]
    24b1:	mov    r14,QWORD PTR [rsp+0xa8]
    24b9:	mov    r15,QWORD PTR [rsp+0xb0]
    24c1:	add    rsp,0xc0
    24c8:	mov    rsp,rbp
    24cb:	pop    rbp
    24cc:	ret
    24cd:	add    BYTE PTR [rax],al
    24cf:	add    BYTE PTR [rsi],al
    24d1:	add    BYTE PTR [rax],al
    24d3:	add    BYTE PTR [rax],al
    24d5:	add    BYTE PTR [rax],al
	...

00000000000024d8 <botlish_entry_9: <str>>:
    24d8:	push   rbp
    24d9:	mov    rbp,rsp
    24dc:	mov    rsi,QWORD PTR [rdx]
    24df:	call   24e4 <botlish_entry_9+0xc>
			24e0: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    24e4:	mov    rsp,rbp
    24e7:	pop    rbp
    24e8:	ret
    24e9:	add    BYTE PTR [rax],al
    24eb:	add    BYTE PTR [rax],al
    24ed:	add    BYTE PTR [rax],al
	...

00000000000024f0 <botlish_fn_10: <generic>>:
    24f0:	push   rbp
    24f1:	mov    rbp,rsp
    24f4:	sub    rsp,0xc0
    24fb:	mov    QWORD PTR [rsp+0x90],rbx
    2503:	mov    QWORD PTR [rsp+0x98],r12
    250b:	mov    QWORD PTR [rsp+0xa0],r13
    2513:	mov    QWORD PTR [rsp+0xa8],r14
    251b:	mov    QWORD PTR [rsp+0xb0],r15
    2523:	mov    r12,QWORD PTR [rdi]
    2526:	mov    rax,QWORD PTR [rdi+0x8]
    252a:	lea    rcx,[r12+0x28]
    252f:	cmp    rcx,rax
    2532:	ja     2982 <botlish_fn_10+0x492>
    2538:	lea    rax,[r12+0x28]
    253d:	mov    QWORD PTR [rdi],rax
    2540:	mov    QWORD PTR [r12+0x10],0x0
    2549:	mov    QWORD PTR [r12+0x18],0x0
    2552:	mov    QWORD PTR [r12+0x20],0x0
    255b:	mov    QWORD PTR [r12],rsi
    255f:	xor    eax,eax
    2561:	test   rsi,0x7
    2568:	jne    2577 <botlish_fn_10+0x87>
    256e:	movzx  rax,BYTE PTR [rsi]
    2572:	cmp    al,0x2
    2574:	sete   al
    2577:	test   al,al
    2579:	jne    25a3 <botlish_fn_10+0xb3>
    257f:	mov    rax,QWORD PTR [rdi+0x10]
    2583:	mov    QWORD PTR [rsp+0x78],rdi
    2588:	mov    rcx,QWORD PTR [rax+0xd8]
    258f:	mov    edx,0x1
    2594:	call   2599 <botlish_fn_10+0xa9>
			2595: R_X86_64_PLT32	rt_type_error-0x4
    2599:	mov    rdi,QWORD PTR [rsp+0x78]
    259e:	jmp    2898 <botlish_fn_10+0x3a8>
    25a3:	mov    r13,rsi
    25a6:	mov    QWORD PTR [rsp+0x78],rdi
    25ab:	call   25b0 <botlish_fn_10+0xc0>
			25ac: R_X86_64_PLT32	rt_str_len-0x4
    25b0:	mov    rbx,rax
    25b3:	mov    QWORD PTR [r12+0x8],rbx
    25b8:	lea    r8,[rsp]
    25bc:	mov    QWORD PTR [rsp],r13
    25c0:	mov    esi,0xb
    25c5:	mov    rdx,QWORD PTR [rip+0x0]        # 25cc <botlish_fn_10+0xdc>
			25c8: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    25cc:	mov    r13d,0x1
    25d2:	mov    rcx,r13
    25d5:	mov    rdi,QWORD PTR [rsp+0x78]
    25da:	call   25df <botlish_fn_10+0xef>
			25db: R_X86_64_PLT32	rt_closure_new-0x4
    25df:	mov    r15,rax
    25e2:	mov    QWORD PTR [rsp+0x88],r13
    25ea:	mov    QWORD PTR [r12],rax
    25ee:	lea    r8,[rsp+0x8]
    25f3:	mov    QWORD PTR [rsp+0x8],rbx
    25f8:	mov    QWORD PTR [rsp+0x10],rax
    25fd:	mov    esi,0xf
    2602:	mov    rdx,QWORD PTR [rip+0x0]        # 2609 <botlish_fn_10+0x119>
			2605: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_local<generic>
    2609:	mov    r14d,0x2
    260f:	mov    rcx,r14
    2612:	mov    rdi,QWORD PTR [rsp+0x78]
    2617:	call   261c <botlish_fn_10+0x12c>
			2618: R_X86_64_PLT32	rt_closure_new-0x4
    261c:	mov    r13,rax
    261f:	mov    QWORD PTR [r12+0x10],r13
    2624:	lea    r8,[rsp+0x18]
    2629:	mov    QWORD PTR [rsp+0x18],rbx
    262e:	mov    rax,r15
    2631:	mov    QWORD PTR [rsp+0x20],rax
    2636:	mov    esi,0x10
    263b:	mov    rdx,QWORD PTR [rip+0x0]        # 2642 <botlish_fn_10+0x152>
			263e: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; scan_label<generic>
    2642:	mov    rcx,r14
    2645:	mov    rdi,QWORD PTR [rsp+0x78]
    264a:	call   264f <botlish_fn_10+0x15f>
			264b: R_X86_64_PLT32	rt_closure_new-0x4
    264f:	mov    QWORD PTR [r12+0x18],rax
    2654:	mov    QWORD PTR [rsp+0x80],rax
    265c:	lea    r8,[rsp+0x28]
    2661:	mov    QWORD PTR [rsp+0x28],rbx
    2666:	mov    QWORD PTR [rsp+0x30],r15
    266b:	mov    esi,0x11
    2670:	mov    rdx,QWORD PTR [rip+0x0]        # 2677 <botlish_fn_10+0x187>
			2673: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; scan_alpha<generic>
    2677:	mov    rcx,r14
    267a:	mov    rdi,QWORD PTR [rsp+0x78]
    267f:	call   2684 <botlish_fn_10+0x194>
			2680: R_X86_64_PLT32	rt_closure_new-0x4
    2684:	mov    QWORD PTR [r12+0x20],rax
    2689:	lea    r8,[rsp+0x38]
    268e:	mov    QWORD PTR [rsp+0x38],rax
    2693:	mov    QWORD PTR [rsp+0x40],rbx
    2698:	mov    esi,0x12
    269d:	mov    rdx,QWORD PTR [rip+0x0]        # 26a4 <botlish_fn_10+0x1b4>
			26a0: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; tld_ok<generic>
    26a4:	mov    rcx,r14
    26a7:	mov    rdi,QWORD PTR [rsp+0x78]
    26ac:	call   26b1 <botlish_fn_10+0x1c1>
			26ad: R_X86_64_PLT32	rt_closure_new-0x4
    26b1:	mov    QWORD PTR [r12+0x20],rax
    26b6:	lea    r8,[rsp+0x48]
    26bb:	mov    rcx,QWORD PTR [rsp+0x80]
    26c3:	mov    QWORD PTR [rsp+0x48],rcx
    26c8:	mov    QWORD PTR [rsp+0x50],rbx
    26cd:	mov    QWORD PTR [rsp+0x58],r15
    26d2:	mov    QWORD PTR [rsp+0x60],rax
    26d7:	mov    esi,0x13
    26dc:	mov    rdx,QWORD PTR [rip+0x0]        # 26e3 <botlish_fn_10+0x1f3>
			26df: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; domain_loop<generic>
    26e3:	mov    ecx,0x4
    26e8:	mov    rdi,QWORD PTR [rsp+0x78]
    26ed:	call   26f2 <botlish_fn_10+0x202>
			26ee: R_X86_64_PLT32	rt_closure_new-0x4
    26f2:	mov    QWORD PTR [r12+0x18],rax
    26f7:	mov    r14,rax
    26fa:	mov    QWORD PTR [r12+0x20],0x1
    2703:	mov    rsi,r13
    2706:	mov    rdx,QWORD PTR [rsp+0x88]
    270e:	mov    rdi,QWORD PTR [rsp+0x78]
    2713:	call   2718 <botlish_fn_10+0x228>
			2714: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    2718:	mov    r10,rax
    271b:	mov    r13,rax
    271e:	test   rax,r10
    2721:	jne    2731 <botlish_fn_10+0x241>
    2727:	mov    rdi,QWORD PTR [rsp+0x78]
    272c:	jmp    2898 <botlish_fn_10+0x3a8>
    2731:	mov    rax,r13
    2734:	mov    QWORD PTR [r12+0x10],rax
    2739:	test   rax,0x1
    273f:	jne    276f <botlish_fn_10+0x27f>
    2745:	mov    rdx,QWORD PTR [rsp+0x88]
    274d:	mov    rsi,r13
    2750:	mov    rdi,QWORD PTR [rsp+0x78]
    2755:	call   275a <botlish_fn_10+0x26a>
			2756: R_X86_64_PLT32	rt_int_cmp-0x4
    275a:	mov    ecx,0x2
    275f:	test   rax,rax
    2762:	cmove  rcx,QWORD PTR [rip+0x25e]        # 29c8 <botlish_fn_10+0x4d8>
    276a:	jmp    2780 <botlish_fn_10+0x290>
    276f:	mov    ecx,0x2
    2774:	cmp    r13,0x1
    2778:	cmove  rcx,QWORD PTR [rip+0x248]        # 29c8 <botlish_fn_10+0x4d8>
    2780:	cmp    rcx,0x6
    2784:	je     293c <botlish_fn_10+0x44c>
    278a:	mov    r11,r13
    278d:	and    r11,rbx
    2790:	test   r11,0x1
    2797:	jne    27c2 <botlish_fn_10+0x2d2>
    279d:	mov    rdx,rbx
    27a0:	mov    rsi,r13
    27a3:	mov    rdi,QWORD PTR [rsp+0x78]
    27a8:	call   27ad <botlish_fn_10+0x2bd>
			27a9: R_X86_64_PLT32	rt_int_cmp-0x4
    27ad:	mov    ecx,0x2
    27b2:	test   rax,rax
    27b5:	cmovge rcx,QWORD PTR [rip+0x20b]        # 29c8 <botlish_fn_10+0x4d8>
    27bd:	jmp    27d2 <botlish_fn_10+0x2e2>
    27c2:	mov    ecx,0x2
    27c7:	cmp    r13,rbx
    27ca:	cmovge rcx,QWORD PTR [rip+0x1f6]        # 29c8 <botlish_fn_10+0x4d8>
    27d2:	cmp    rcx,0x6
    27d6:	je     292d <botlish_fn_10+0x43d>
    27dc:	lea    rcx,[rsp+0x68]
    27e1:	mov    rsi,r15
    27e4:	mov    rdx,r13
    27e7:	mov    rdi,QWORD PTR [rsp+0x78]
    27ec:	call   27f1 <botlish_fn_10+0x301>
			27ed: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    27f1:	test   rax,rax
    27f4:	mov    rsi,rax
    27f7:	jne    2807 <botlish_fn_10+0x317>
    27fd:	mov    rdi,QWORD PTR [rsp+0x78]
    2802:	jmp    2898 <botlish_fn_10+0x3a8>
    2807:	mov    rdx,QWORD PTR [rsp+0x68]
    280c:	mov    rcx,QWORD PTR [rsp+0x70]
    2811:	mov    rdi,QWORD PTR [rsp+0x78]
    2816:	mov    rax,QWORD PTR [rdi+0x10]
    281a:	mov    r8,QWORD PTR [rax+0x100]
    2821:	call   2826 <botlish_fn_10+0x336>
			2822: R_X86_64_PLT32	rt_str_region_eq-0x4
    2826:	cmp    rax,0x6
    282a:	je     283d <botlish_fn_10+0x34d>
    2830:	mov    esi,0x2
    2835:	mov    rax,rsi
    2838:	jmp    2932 <botlish_fn_10+0x442>
    283d:	mov    QWORD PTR [r12],0x3
    2845:	test   r13,0x1
    284c:	je     2864 <botlish_fn_10+0x374>
    2852:	mov    rdx,r13
    2855:	add    rdx,0x2
    2859:	seto   al
    285c:	test   al,al
    285e:	je     2879 <botlish_fn_10+0x389>
    2864:	mov    edx,0x3
    2869:	mov    rsi,r13
    286c:	mov    rdi,QWORD PTR [rsp+0x78]
    2871:	call   2876 <botlish_fn_10+0x386>
			2872: R_X86_64_PLT32	rt_int_add-0x4
    2876:	mov    rdx,rax
    2879:	mov    QWORD PTR [r12],rdx
    287d:	mov    rsi,r14
    2880:	mov    rdi,QWORD PTR [rsp+0x78]
    2885:	call   288a <botlish_fn_10+0x39a>
			2886: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    288a:	test   rax,rax
    288d:	jne    28d7 <botlish_fn_10+0x3e7>
    2893:	mov    rdi,QWORD PTR [rsp+0x78]
    2898:	mov    rdi,QWORD PTR [rsp+0x78]
    289d:	mov    QWORD PTR [rdi],r12
    28a0:	xor    rax,rax
    28a3:	mov    rbx,QWORD PTR [rsp+0x90]
    28ab:	mov    r12,QWORD PTR [rsp+0x98]
    28b3:	mov    r13,QWORD PTR [rsp+0xa0]
    28bb:	mov    r14,QWORD PTR [rsp+0xa8]
    28c3:	mov    r15,QWORD PTR [rsp+0xb0]
    28cb:	add    rsp,0xc0
    28d2:	mov    rsp,rbp
    28d5:	pop    rbp
    28d6:	ret
    28d7:	mov    rcx,rax
    28da:	and    rcx,rbx
    28dd:	mov    rsi,rax
    28e0:	mov    rax,rbx
    28e3:	test   rcx,0x1
    28ea:	jne    2915 <botlish_fn_10+0x425>
    28f0:	mov    rdx,rax
    28f3:	mov    rdi,QWORD PTR [rsp+0x78]
    28f8:	call   28fd <botlish_fn_10+0x40d>
			28f9: R_X86_64_PLT32	rt_int_cmp-0x4
    28fd:	mov    esi,0x2
    2902:	test   rax,rax
    2905:	mov    rax,rsi
    2908:	cmove  rax,QWORD PTR [rip+0xb8]        # 29c8 <botlish_fn_10+0x4d8>
    2910:	jmp    2932 <botlish_fn_10+0x442>
    2915:	mov    rdx,rax
    2918:	mov    eax,0x2
    291d:	cmp    rsi,rdx
    2920:	cmove  rax,QWORD PTR [rip+0xa0]        # 29c8 <botlish_fn_10+0x4d8>
    2928:	jmp    2932 <botlish_fn_10+0x442>
    292d:	mov    eax,0x2
    2932:	mov    rdi,QWORD PTR [rsp+0x78]
    2937:	jmp    2946 <botlish_fn_10+0x456>
    293c:	mov    eax,0x2
    2941:	mov    rdi,QWORD PTR [rsp+0x78]
    2946:	mov    rdi,QWORD PTR [rsp+0x78]
    294b:	mov    QWORD PTR [rdi],r12
    294e:	mov    rbx,QWORD PTR [rsp+0x90]
    2956:	mov    r12,QWORD PTR [rsp+0x98]
    295e:	mov    r13,QWORD PTR [rsp+0xa0]
    2966:	mov    r14,QWORD PTR [rsp+0xa8]
    296e:	mov    r15,QWORD PTR [rsp+0xb0]
    2976:	add    rsp,0xc0
    297d:	mov    rsp,rbp
    2980:	pop    rbp
    2981:	ret
    2982:	mov    QWORD PTR [rsp+0x78],rdi
    2987:	call   298c <botlish_fn_10+0x49c>
			2988: R_X86_64_PLT32	rt_stack_overflow-0x4
    298c:	xor    rax,rax
    298f:	mov    rbx,QWORD PTR [rsp+0x90]
    2997:	mov    r12,QWORD PTR [rsp+0x98]
    299f:	mov    r13,QWORD PTR [rsp+0xa0]
    29a7:	mov    r14,QWORD PTR [rsp+0xa8]
    29af:	mov    r15,QWORD PTR [rsp+0xb0]
    29b7:	add    rsp,0xc0
    29be:	mov    rsp,rbp
    29c1:	pop    rbp
    29c2:	ret
    29c3:	add    BYTE PTR [rax],al
    29c5:	add    BYTE PTR [rax],al
    29c7:	add    BYTE PTR [rsi],al
    29c9:	add    BYTE PTR [rax],al
    29cb:	add    BYTE PTR [rax],al
    29cd:	add    BYTE PTR [rax],al
	...

00000000000029d0 <botlish_entry_10: <generic>>:
    29d0:	push   rbp
    29d1:	mov    rbp,rsp
    29d4:	mov    rsi,QWORD PTR [rdx]
    29d7:	call   29dc <botlish_entry_10+0xc>
			29d8: R_X86_64_PLT32	botlish_fn_10-0x4 ; <generic>
    29dc:	mov    rsp,rbp
    29df:	pop    rbp
    29e0:	ret

00000000000029e1 <botlish_fn_11: char_at<generic>>:
    29e1:	push   rbp
    29e2:	mov    rbp,rsp
    29e5:	sub    rsp,0x50
    29e9:	mov    QWORD PTR [rsp+0x20],rbx
    29ee:	mov    QWORD PTR [rsp+0x28],r12
    29f3:	mov    QWORD PTR [rsp+0x30],r13
    29f8:	mov    QWORD PTR [rsp+0x38],r14
    29fd:	mov    QWORD PTR [rsp+0x40],r15
    2a02:	mov    rbx,QWORD PTR [rdi+0x20]
    2a06:	mov    r13,QWORD PTR [rdi+0x28]
    2a0a:	lea    rax,[rsp]
    2a0e:	mov    QWORD PTR [rdi+0x20],rax
    2a12:	mov    QWORD PTR [rdi+0x28],0x3
    2a1a:	mov    QWORD PTR [rsp],rdx
    2a1e:	mov    rax,QWORD PTR [rsi+0x20]
    2a22:	mov    rsi,QWORD PTR [rax]
    2a25:	mov    QWORD PTR [rsp+0x8],rsi
    2a2a:	mov    r15,rsi
    2a2d:	mov    QWORD PTR [rsp+0x10],0x3
    2a36:	mov    ecx,0x1
    2a3b:	test   rdx,0x1
    2a42:	je     2a50 <botlish_fn_11+0x6f>
    2a48:	mov    r14,rdx
    2a4b:	jmp    2a73 <botlish_fn_11+0x92>
    2a50:	xor    ecx,ecx
    2a52:	test   rdx,0x7
    2a59:	je     2a67 <botlish_fn_11+0x86>
    2a5f:	mov    r14,rdx
    2a62:	jmp    2a73 <botlish_fn_11+0x92>
    2a67:	movzx  rax,BYTE PTR [rdx]
    2a6b:	mov    r14,rdx
    2a6e:	cmp    al,0x1
    2a70:	sete   cl
    2a73:	test   cl,cl
    2a75:	jne    2a99 <botlish_fn_11+0xb8>
    2a7b:	mov    rax,QWORD PTR [rdi+0x10]
    2a7f:	mov    rcx,QWORD PTR [rax+0x108]
    2a86:	xor    rdx,rdx
    2a89:	mov    rsi,r14
    2a8c:	mov    r12,rdi
    2a8f:	call   2a94 <botlish_fn_11+0xb3>
			2a90: R_X86_64_PLT32	rt_type_error-0x4
    2a94:	jmp    2b4c <botlish_fn_11+0x16b>
    2a99:	mov    rsi,r14
    2a9c:	mov    r12,rdi
    2a9f:	test   rsi,0x1
    2aa6:	je     2ac1 <botlish_fn_11+0xe0>
    2aac:	mov    rsi,r14
    2aaf:	mov    rcx,rsi
    2ab2:	add    rcx,0x2
    2ab6:	seto   al
    2ab9:	test   al,al
    2abb:	je     2ad4 <botlish_fn_11+0xf3>
    2ac1:	mov    edx,0x3
    2ac6:	mov    rsi,r14
    2ac9:	mov    rdi,r12
    2acc:	call   2ad1 <botlish_fn_11+0xf0>
			2acd: R_X86_64_PLT32	rt_int_add-0x4
    2ad1:	mov    rcx,rax
    2ad4:	mov    QWORD PTR [rsp+0x10],rcx
    2ad9:	mov    edx,0x1
    2ade:	mov    rsi,r14
    2ae1:	test   rsi,0x1
    2ae8:	jne    2b0e <botlish_fn_11+0x12d>
    2aee:	xor    edx,edx
    2af0:	mov    rsi,r14
    2af3:	test   rsi,0x7
    2afa:	jne    2b0e <botlish_fn_11+0x12d>
    2b00:	mov    rsi,r14
    2b03:	movzx  rdi,BYTE PTR [rsi]
    2b07:	cmp    dil,0x1
    2b0b:	sete   dl
    2b0e:	test   dl,dl
    2b10:	jne    2b35 <botlish_fn_11+0x154>
    2b16:	mov    r11,QWORD PTR [r12+0x10]
    2b1b:	mov    rcx,QWORD PTR [r11+0x110]
    2b22:	xor    rdx,rdx
    2b25:	mov    rsi,r14
    2b28:	mov    rdi,r12
    2b2b:	call   2b30 <botlish_fn_11+0x14f>
			2b2c: R_X86_64_PLT32	rt_type_error-0x4
    2b30:	jmp    2b4c <botlish_fn_11+0x16b>
    2b35:	mov    rdx,r14
    2b38:	mov    rsi,r15
    2b3b:	mov    rdi,r12
    2b3e:	call   2b43 <botlish_fn_11+0x162>
			2b3f: R_X86_64_PLT32	rt_substr-0x4
    2b43:	test   rax,rax
    2b46:	jne    2b7b <botlish_fn_11+0x19a>
    2b4c:	mov    QWORD PTR [r12+0x20],rbx
    2b51:	mov    QWORD PTR [r12+0x28],r13
    2b56:	xor    rax,rax
    2b59:	mov    rbx,QWORD PTR [rsp+0x20]
    2b5e:	mov    r12,QWORD PTR [rsp+0x28]
    2b63:	mov    r13,QWORD PTR [rsp+0x30]
    2b68:	mov    r14,QWORD PTR [rsp+0x38]
    2b6d:	mov    r15,QWORD PTR [rsp+0x40]
    2b72:	add    rsp,0x50
    2b76:	mov    rsp,rbp
    2b79:	pop    rbp
    2b7a:	ret
    2b7b:	mov    QWORD PTR [r12+0x20],rbx
    2b80:	mov    QWORD PTR [r12+0x28],r13
    2b85:	mov    rbx,QWORD PTR [rsp+0x20]
    2b8a:	mov    r12,QWORD PTR [rsp+0x28]
    2b8f:	mov    r13,QWORD PTR [rsp+0x30]
    2b94:	mov    r14,QWORD PTR [rsp+0x38]
    2b99:	mov    r15,QWORD PTR [rsp+0x40]
    2b9e:	add    rsp,0x50
    2ba2:	mov    rsp,rbp
    2ba5:	pop    rbp
    2ba6:	ret

0000000000002ba7 <botlish_entry_11: char_at<generic>>:
    2ba7:	push   rbp
    2ba8:	mov    rbp,rsp
    2bab:	mov    rdx,QWORD PTR [rdx]
    2bae:	call   2bb3 <botlish_entry_11+0xc>
			2baf: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2bb3:	mov    rsp,rbp
    2bb6:	pop    rbp
    2bb7:	ret

0000000000002bb8 <botlish_fn_12: char_at<generic>>:
    2bb8:	push   rbp
    2bb9:	mov    rbp,rsp
    2bbc:	sub    rsp,0x60
    2bc0:	mov    QWORD PTR [rsp+0x30],rbx
    2bc5:	mov    QWORD PTR [rsp+0x38],r12
    2bca:	mov    QWORD PTR [rsp+0x40],r13
    2bcf:	mov    QWORD PTR [rsp+0x48],r14
    2bd4:	mov    QWORD PTR [rsp+0x50],r15
    2bd9:	mov    QWORD PTR [rsp+0x18],rcx
    2bde:	mov    rbx,QWORD PTR [rdi+0x20]
    2be2:	mov    r12,QWORD PTR [rdi+0x28]
    2be6:	lea    rax,[rsp]
    2bea:	mov    QWORD PTR [rdi+0x20],rax
    2bee:	mov    QWORD PTR [rdi+0x28],0x3
    2bf6:	mov    QWORD PTR [rsp],rdx
    2bfa:	mov    rax,QWORD PTR [rsi+0x20]
    2bfe:	mov    rax,QWORD PTR [rax]
    2c01:	mov    QWORD PTR [rsp+0x8],rax
    2c06:	mov    QWORD PTR [rsp+0x20],rax
    2c0b:	mov    QWORD PTR [rsp+0x10],0x3
    2c14:	mov    eax,0x1
    2c19:	test   rdx,0x1
    2c20:	je     2c2e <botlish_fn_12+0x76>
    2c26:	mov    r15,rdx
    2c29:	jmp    2c51 <botlish_fn_12+0x99>
    2c2e:	xor    eax,eax
    2c30:	test   rdx,0x7
    2c37:	je     2c45 <botlish_fn_12+0x8d>
    2c3d:	mov    r15,rdx
    2c40:	jmp    2c51 <botlish_fn_12+0x99>
    2c45:	movzx  rax,BYTE PTR [rdx]
    2c49:	mov    r15,rdx
    2c4c:	cmp    al,0x1
    2c4e:	sete   al
    2c51:	test   al,al
    2c53:	jne    2c77 <botlish_fn_12+0xbf>
    2c59:	mov    rax,QWORD PTR [rdi+0x10]
    2c5d:	mov    rcx,QWORD PTR [rax+0x108]
    2c64:	xor    rdx,rdx
    2c67:	mov    rsi,r15
    2c6a:	mov    r13,rdi
    2c6d:	call   2c72 <botlish_fn_12+0xba>
			2c6e: R_X86_64_PLT32	rt_type_error-0x4
    2c72:	jmp    2d31 <botlish_fn_12+0x179>
    2c77:	mov    rsi,r15
    2c7a:	mov    r13,rdi
    2c7d:	test   rsi,0x1
    2c84:	jne    2c92 <botlish_fn_12+0xda>
    2c8a:	mov    r15,rsi
    2c8d:	jmp    2ca7 <botlish_fn_12+0xef>
    2c92:	mov    rax,rsi
    2c95:	add    rax,0x2
    2c99:	mov    r15,rsi
    2c9c:	seto   cl
    2c9f:	test   cl,cl
    2ca1:	je     2cb7 <botlish_fn_12+0xff>
    2ca7:	mov    edx,0x3
    2cac:	mov    rsi,r15
    2caf:	mov    rdi,r13
    2cb2:	call   2cb7 <botlish_fn_12+0xff>
			2cb3: R_X86_64_PLT32	rt_int_add-0x4
    2cb7:	mov    ecx,0x1
    2cbc:	mov    rsi,r15
    2cbf:	test   rsi,0x1
    2cc6:	jne    2cec <botlish_fn_12+0x134>
    2ccc:	xor    ecx,ecx
    2cce:	mov    rsi,r15
    2cd1:	test   rsi,0x7
    2cd8:	jne    2cec <botlish_fn_12+0x134>
    2cde:	mov    rsi,r15
    2ce1:	movzx  rdi,BYTE PTR [rsi]
    2ce5:	cmp    dil,0x1
    2ce9:	sete   cl
    2cec:	test   cl,cl
    2cee:	jne    2d12 <botlish_fn_12+0x15a>
    2cf4:	mov    r11,QWORD PTR [r13+0x10]
    2cf8:	mov    rcx,QWORD PTR [r11+0x110]
    2cff:	xor    rdx,rdx
    2d02:	mov    rsi,r15
    2d05:	mov    rdi,r13
    2d08:	call   2d0d <botlish_fn_12+0x155>
			2d09: R_X86_64_PLT32	rt_type_error-0x4
    2d0d:	jmp    2d31 <botlish_fn_12+0x179>
    2d12:	mov    r14,rax
    2d15:	mov    rcx,r14
    2d18:	mov    rdx,r15
    2d1b:	mov    rsi,QWORD PTR [rsp+0x20]
    2d20:	mov    rdi,r13
    2d23:	call   2d28 <botlish_fn_12+0x170>
			2d24: R_X86_64_PLT32	rt_str_region_check-0x4
    2d28:	test   rax,rax
    2d2b:	jne    2d5e <botlish_fn_12+0x1a6>
    2d31:	mov    QWORD PTR [r13+0x20],rbx
    2d35:	mov    QWORD PTR [r13+0x28],r12
    2d39:	xor    rax,rax
    2d3c:	mov    rbx,QWORD PTR [rsp+0x30]
    2d41:	mov    r12,QWORD PTR [rsp+0x38]
    2d46:	mov    r13,QWORD PTR [rsp+0x40]
    2d4b:	mov    r14,QWORD PTR [rsp+0x48]
    2d50:	mov    r15,QWORD PTR [rsp+0x50]
    2d55:	add    rsp,0x60
    2d59:	mov    rsp,rbp
    2d5c:	pop    rbp
    2d5d:	ret
    2d5e:	mov    QWORD PTR [r13+0x20],rbx
    2d62:	mov    QWORD PTR [r13+0x28],r12
    2d66:	mov    rcx,QWORD PTR [rsp+0x18]
    2d6b:	mov    rsi,r15
    2d6e:	mov    QWORD PTR [rcx],rsi
    2d71:	mov    QWORD PTR [rcx+0x8],r14
    2d75:	mov    rax,QWORD PTR [rsp+0x20]
    2d7a:	mov    rbx,QWORD PTR [rsp+0x30]
    2d7f:	mov    r12,QWORD PTR [rsp+0x38]
    2d84:	mov    r13,QWORD PTR [rsp+0x40]
    2d89:	mov    r14,QWORD PTR [rsp+0x48]
    2d8e:	mov    r15,QWORD PTR [rsp+0x50]
    2d93:	add    rsp,0x60
    2d97:	mov    rsp,rbp
    2d9a:	pop    rbp
    2d9b:	ret

0000000000002d9c <botlish_entry_12: char_at<generic>>:
    2d9c:	push   rbp
    2d9d:	mov    rbp,rsp
    2da0:	ud2

0000000000002da2 <botlish_fn_13: is_local_char<str>>:
    2da2:	push   rbp
    2da3:	mov    rbp,rsp
    2da6:	sub    rsp,0x10
    2daa:	mov    QWORD PTR [rsp],rbx
    2dae:	mov    QWORD PTR [rsp+0x8],r12
    2db3:	mov    rbx,rsi
    2db6:	mov    r12,rdi
    2db9:	mov    rsi,rbx
    2dbc:	mov    rdi,r12
    2dbf:	call   2dc4 <botlish_fn_13+0x22>
			2dc0: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    2dc4:	test   rax,rax
    2dc7:	jne    2de2 <botlish_fn_13+0x40>
    2dcd:	xor    rax,rax
    2dd0:	mov    rbx,QWORD PTR [rsp]
    2dd4:	mov    r12,QWORD PTR [rsp+0x8]
    2dd9:	add    rsp,0x10
    2ddd:	mov    rsp,rbp
    2de0:	pop    rbp
    2de1:	ret
    2de2:	cmp    rax,0x6
    2de6:	je     2ee1 <botlish_fn_13+0x13f>
    2dec:	mov    rdi,r12
    2def:	mov    rax,QWORD PTR [rdi+0x10]
    2df3:	mov    rsi,QWORD PTR [rax+0x118]
    2dfa:	mov    edx,0x1
    2dff:	mov    ecx,0x3
    2e04:	mov    r8,rbx
    2e07:	call   2e0c <botlish_fn_13+0x6a>
			2e08: R_X86_64_PLT32	rt_str_region_eq-0x4
    2e0c:	cmp    rax,0x6
    2e10:	je     2ed7 <botlish_fn_13+0x135>
    2e16:	mov    rdi,r12
    2e19:	mov    rax,QWORD PTR [rdi+0x10]
    2e1d:	mov    rsi,QWORD PTR [rax+0x120]
    2e24:	mov    edx,0x1
    2e29:	mov    ecx,0x3
    2e2e:	mov    r8,rbx
    2e31:	call   2e36 <botlish_fn_13+0x94>
			2e32: R_X86_64_PLT32	rt_str_region_eq-0x4
    2e36:	cmp    rax,0x6
    2e3a:	je     2ecd <botlish_fn_13+0x12b>
    2e40:	mov    rdi,r12
    2e43:	mov    rax,QWORD PTR [rdi+0x10]
    2e47:	mov    rsi,QWORD PTR [rax+0xc0]
    2e4e:	mov    edx,0x1
    2e53:	mov    ecx,0x3
    2e58:	mov    r8,rbx
    2e5b:	call   2e60 <botlish_fn_13+0xbe>
			2e5c: R_X86_64_PLT32	rt_str_region_eq-0x4
    2e60:	cmp    rax,0x6
    2e64:	je     2ec3 <botlish_fn_13+0x121>
    2e6a:	mov    rdi,r12
    2e6d:	mov    rax,QWORD PTR [rdi+0x10]
    2e71:	mov    rsi,QWORD PTR [rax+0x108]
    2e78:	mov    edx,0x1
    2e7d:	mov    ecx,0x3
    2e82:	mov    r8,rbx
    2e85:	call   2e8a <botlish_fn_13+0xe8>
			2e86: R_X86_64_PLT32	rt_str_region_eq-0x4
    2e8a:	cmp    rax,0x6
    2e8e:	je     2eb9 <botlish_fn_13+0x117>
    2e94:	mov    rdi,r12
    2e97:	mov    rax,QWORD PTR [rdi+0x10]
    2e9b:	mov    rsi,QWORD PTR [rax+0x128]
    2ea2:	mov    edx,0x1
    2ea7:	mov    ecx,0x3
    2eac:	mov    r8,rbx
    2eaf:	call   2eb4 <botlish_fn_13+0x112>
			2eb0: R_X86_64_PLT32	rt_str_region_eq-0x4
    2eb4:	jmp    2ee6 <botlish_fn_13+0x144>
    2eb9:	mov    eax,0x6
    2ebe:	jmp    2ee6 <botlish_fn_13+0x144>
    2ec3:	mov    eax,0x6
    2ec8:	jmp    2ee6 <botlish_fn_13+0x144>
    2ecd:	mov    eax,0x6
    2ed2:	jmp    2ee6 <botlish_fn_13+0x144>
    2ed7:	mov    eax,0x6
    2edc:	jmp    2ee6 <botlish_fn_13+0x144>
    2ee1:	mov    eax,0x6
    2ee6:	mov    rbx,QWORD PTR [rsp]
    2eea:	mov    r12,QWORD PTR [rsp+0x8]
    2eef:	add    rsp,0x10
    2ef3:	mov    rsp,rbp
    2ef6:	pop    rbp
    2ef7:	ret

0000000000002ef8 <botlish_entry_13: is_local_char<str>>:
    2ef8:	push   rbp
    2ef9:	mov    rbp,rsp
    2efc:	mov    rsi,QWORD PTR [rdx]
    2eff:	call   2f04 <botlish_entry_13+0xc>
			2f00: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_local_char<str>
    2f04:	mov    rsp,rbp
    2f07:	pop    rbp
    2f08:	ret

0000000000002f09 <botlish_fn_14: is_label_char<str>>:
    2f09:	push   rbp
    2f0a:	mov    rbp,rsp
    2f0d:	sub    rsp,0x10
    2f11:	mov    QWORD PTR [rsp],r13
    2f15:	mov    QWORD PTR [rsp+0x8],r15
    2f1a:	mov    r13,rsi
    2f1d:	mov    r15,rdi
    2f20:	mov    rsi,r13
    2f23:	mov    rdi,r15
    2f26:	call   2f2b <botlish_fn_14+0x22>
			2f27: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    2f2b:	test   rax,rax
    2f2e:	jne    2f49 <botlish_fn_14+0x40>
    2f34:	xor    rax,rax
    2f37:	mov    r13,QWORD PTR [rsp]
    2f3b:	mov    r15,QWORD PTR [rsp+0x8]
    2f40:	add    rsp,0x10
    2f44:	mov    rsp,rbp
    2f47:	pop    rbp
    2f48:	ret
    2f49:	cmp    rax,0x6
    2f4d:	je     2f78 <botlish_fn_14+0x6f>
    2f53:	mov    rdi,r15
    2f56:	mov    rax,QWORD PTR [rdi+0x10]
    2f5a:	mov    rsi,QWORD PTR [rax+0x128]
    2f61:	mov    edx,0x1
    2f66:	mov    ecx,0x3
    2f6b:	mov    r8,r13
    2f6e:	call   2f73 <botlish_fn_14+0x6a>
			2f6f: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f73:	jmp    2f7d <botlish_fn_14+0x74>
    2f78:	mov    eax,0x6
    2f7d:	mov    r13,QWORD PTR [rsp]
    2f81:	mov    r15,QWORD PTR [rsp+0x8]
    2f86:	add    rsp,0x10
    2f8a:	mov    rsp,rbp
    2f8d:	pop    rbp
    2f8e:	ret

0000000000002f8f <botlish_entry_14: is_label_char<str>>:
    2f8f:	push   rbp
    2f90:	mov    rbp,rsp
    2f93:	mov    rsi,QWORD PTR [rdx]
    2f96:	call   2f9b <botlish_entry_14+0xc>
			2f97: R_X86_64_PLT32	botlish_fn_14-0x4 ; is_label_char<str>
    2f9b:	mov    rsp,rbp
    2f9e:	pop    rbp
    2f9f:	ret

0000000000002fa0 <botlish_fn_15: scan_local<generic>>:
    2fa0:	push   rbp
    2fa1:	mov    rbp,rsp
    2fa4:	sub    rsp,0x20
    2fa8:	mov    QWORD PTR [rsp],rbx
    2fac:	mov    QWORD PTR [rsp+0x8],r12
    2fb1:	mov    QWORD PTR [rsp+0x10],r13
    2fb6:	mov    QWORD PTR [rsp+0x18],r14
    2fbb:	mov    r12,QWORD PTR [rdi]
    2fbe:	mov    rax,QWORD PTR [rdi+0x8]
    2fc2:	lea    rcx,[r12+0x18]
    2fc7:	cmp    rcx,rax
    2fca:	ja     319e <botlish_fn_15+0x1fe>
    2fd0:	lea    rax,[r12+0x18]
    2fd5:	mov    QWORD PTR [rdi],rax
    2fd8:	mov    r13,rdi
    2fdb:	mov    QWORD PTR [r12+0x10],0x0
    2fe4:	mov    QWORD PTR [r12],rdx
    2fe8:	mov    rbx,rsi
    2feb:	mov    rsi,rdx
    2fee:	mov    rax,QWORD PTR [rbx+0x20]
    2ff2:	mov    rdx,QWORD PTR [rax]
    2ff5:	mov    ecx,0x1
    2ffa:	test   rsi,0x1
    3001:	jne    301f <botlish_fn_15+0x7f>
    3007:	xor    ecx,ecx
    3009:	test   rsi,0x7
    3010:	jne    301f <botlish_fn_15+0x7f>
    3016:	movzx  rax,BYTE PTR [rsi]
    301a:	cmp    al,0x1
    301c:	sete   cl
    301f:	test   cl,cl
    3021:	jne    3045 <botlish_fn_15+0xa5>
    3027:	mov    rdi,r13
    302a:	mov    rax,QWORD PTR [rdi+0x10]
    302e:	mov    rcx,QWORD PTR [rax+0xb8]
    3035:	xor    rdx,rdx
    3038:	call   303d <botlish_fn_15+0x9d>
			3039: R_X86_64_PLT32	rt_type_error-0x4
    303d:	mov    rdi,r13
    3040:	jmp    30dc <botlish_fn_15+0x13c>
    3045:	mov    rax,rsi
    3048:	and    rax,rdx
    304b:	mov    r14,rsi
    304e:	test   rax,0x1
    3054:	jne    307a <botlish_fn_15+0xda>
    305a:	mov    rsi,r14
    305d:	mov    rdi,r13
    3060:	call   3065 <botlish_fn_15+0xc5>
			3061: R_X86_64_PLT32	rt_int_cmp-0x4
    3065:	mov    ecx,0x2
    306a:	test   rax,rax
    306d:	cmovge rcx,QWORD PTR [rip+0x153]        # 31c8 <botlish_fn_15+0x228>
    3075:	jmp    308d <botlish_fn_15+0xed>
    307a:	mov    ecx,0x2
    307f:	mov    rsi,r14
    3082:	cmp    rsi,rdx
    3085:	cmovge rcx,QWORD PTR [rip+0x13b]        # 31c8 <botlish_fn_15+0x228>
    308d:	cmp    rcx,0x6
    3091:	je     3176 <botlish_fn_15+0x1d6>
    3097:	mov    rsi,QWORD PTR [rbx+0x20]
    309b:	mov    rsi,QWORD PTR [rsi+0x8]
    309f:	mov    QWORD PTR [r12+0x8],rsi
    30a4:	mov    rdx,r14
    30a7:	mov    rdi,r13
    30aa:	call   30af <botlish_fn_15+0x10f>
			30ab: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    30af:	test   rax,rax
    30b2:	jne    30c0 <botlish_fn_15+0x120>
    30b8:	mov    rdi,r13
    30bb:	jmp    30dc <botlish_fn_15+0x13c>
    30c0:	mov    QWORD PTR [r12+0x8],rax
    30c5:	mov    rsi,rax
    30c8:	mov    rdi,r13
    30cb:	call   30d0 <botlish_fn_15+0x130>
			30cc: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_local_char<str>
    30d0:	test   rax,rax
    30d3:	jne    3101 <botlish_fn_15+0x161>
    30d9:	mov    rdi,r13
    30dc:	mov    rdi,r13
    30df:	mov    QWORD PTR [rdi],r12
    30e2:	xor    rax,rax
    30e5:	mov    rbx,QWORD PTR [rsp]
    30e9:	mov    r12,QWORD PTR [rsp+0x8]
    30ee:	mov    r13,QWORD PTR [rsp+0x10]
    30f3:	mov    r14,QWORD PTR [rsp+0x18]
    30f8:	add    rsp,0x20
    30fc:	mov    rsp,rbp
    30ff:	pop    rbp
    3100:	ret
    3101:	cmp    rax,0x6
    3105:	je     3116 <botlish_fn_15+0x176>
    310b:	mov    rax,r14
    310e:	mov    rdi,r13
    3111:	jmp    317c <botlish_fn_15+0x1dc>
    3116:	mov    QWORD PTR [r12+0x8],rbx
    311b:	mov    QWORD PTR [r12+0x10],0x3
    3124:	mov    rsi,r14
    3127:	test   rsi,0x1
    312e:	je     3154 <botlish_fn_15+0x1b4>
    3134:	mov    rsi,r14
    3137:	mov    rcx,rsi
    313a:	add    rcx,0x2
    313e:	seto   al
    3141:	test   al,al
    3143:	jne    3154 <botlish_fn_15+0x1b4>
    3149:	mov    rsi,rcx
    314c:	mov    r14,rcx
    314f:	jmp    316a <botlish_fn_15+0x1ca>
    3154:	mov    edx,0x3
    3159:	mov    rsi,r14
    315c:	mov    rdi,r13
    315f:	call   3164 <botlish_fn_15+0x1c4>
			3160: R_X86_64_PLT32	rt_int_add-0x4
    3164:	mov    rsi,rax
    3167:	mov    r14,rax
    316a:	mov    QWORD PTR [r12],rsi
    316e:	mov    rsi,r14
    3171:	jmp    2fee <botlish_fn_15+0x4e>
    3176:	mov    rax,r14
    3179:	mov    rdi,r13
    317c:	mov    rdi,r13
    317f:	mov    QWORD PTR [rdi],r12
    3182:	mov    rbx,QWORD PTR [rsp]
    3186:	mov    r12,QWORD PTR [rsp+0x8]
    318b:	mov    r13,QWORD PTR [rsp+0x10]
    3190:	mov    r14,QWORD PTR [rsp+0x18]
    3195:	add    rsp,0x20
    3199:	mov    rsp,rbp
    319c:	pop    rbp
    319d:	ret
    319e:	mov    r13,rdi
    31a1:	call   31a6 <botlish_fn_15+0x206>
			31a2: R_X86_64_PLT32	rt_stack_overflow-0x4
    31a6:	xor    rax,rax
    31a9:	mov    rbx,QWORD PTR [rsp]
    31ad:	mov    r12,QWORD PTR [rsp+0x8]
    31b2:	mov    r13,QWORD PTR [rsp+0x10]
    31b7:	mov    r14,QWORD PTR [rsp+0x18]
    31bc:	add    rsp,0x20
    31c0:	mov    rsp,rbp
    31c3:	pop    rbp
    31c4:	ret
    31c5:	add    BYTE PTR [rax],al
    31c7:	add    BYTE PTR [rsi],al
    31c9:	add    BYTE PTR [rax],al
    31cb:	add    BYTE PTR [rax],al
    31cd:	add    BYTE PTR [rax],al
	...

00000000000031d0 <botlish_entry_15: scan_local<generic>>:
    31d0:	push   rbp
    31d1:	mov    rbp,rsp
    31d4:	mov    rdx,QWORD PTR [rdx]
    31d7:	call   31dc <botlish_entry_15+0xc>
			31d8: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    31dc:	mov    rsp,rbp
    31df:	pop    rbp
    31e0:	ret
    31e1:	add    BYTE PTR [rax],al
    31e3:	add    BYTE PTR [rax],al
    31e5:	add    BYTE PTR [rax],al
	...

00000000000031e8 <botlish_fn_16: scan_label<generic>>:
    31e8:	push   rbp
    31e9:	mov    rbp,rsp
    31ec:	sub    rsp,0x20
    31f0:	mov    QWORD PTR [rsp],rbx
    31f4:	mov    QWORD PTR [rsp+0x8],r12
    31f9:	mov    QWORD PTR [rsp+0x10],r13
    31fe:	mov    QWORD PTR [rsp+0x18],r14
    3203:	mov    r12,QWORD PTR [rdi]
    3206:	mov    rax,QWORD PTR [rdi+0x8]
    320a:	lea    rcx,[r12+0x18]
    320f:	cmp    rcx,rax
    3212:	ja     33e6 <botlish_fn_16+0x1fe>
    3218:	lea    rax,[r12+0x18]
    321d:	mov    QWORD PTR [rdi],rax
    3220:	mov    r13,rdi
    3223:	mov    QWORD PTR [r12+0x10],0x0
    322c:	mov    QWORD PTR [r12],rdx
    3230:	mov    rbx,rsi
    3233:	mov    rsi,rdx
    3236:	mov    rax,QWORD PTR [rbx+0x20]
    323a:	mov    rdx,QWORD PTR [rax]
    323d:	mov    ecx,0x1
    3242:	test   rsi,0x1
    3249:	jne    3267 <botlish_fn_16+0x7f>
    324f:	xor    ecx,ecx
    3251:	test   rsi,0x7
    3258:	jne    3267 <botlish_fn_16+0x7f>
    325e:	movzx  rax,BYTE PTR [rsi]
    3262:	cmp    al,0x1
    3264:	sete   cl
    3267:	test   cl,cl
    3269:	jne    328d <botlish_fn_16+0xa5>
    326f:	mov    rdi,r13
    3272:	mov    rax,QWORD PTR [rdi+0x10]
    3276:	mov    rcx,QWORD PTR [rax+0xb8]
    327d:	xor    rdx,rdx
    3280:	call   3285 <botlish_fn_16+0x9d>
			3281: R_X86_64_PLT32	rt_type_error-0x4
    3285:	mov    rdi,r13
    3288:	jmp    3324 <botlish_fn_16+0x13c>
    328d:	mov    rax,rsi
    3290:	and    rax,rdx
    3293:	mov    r14,rsi
    3296:	test   rax,0x1
    329c:	jne    32c2 <botlish_fn_16+0xda>
    32a2:	mov    rsi,r14
    32a5:	mov    rdi,r13
    32a8:	call   32ad <botlish_fn_16+0xc5>
			32a9: R_X86_64_PLT32	rt_int_cmp-0x4
    32ad:	mov    ecx,0x2
    32b2:	test   rax,rax
    32b5:	cmovge rcx,QWORD PTR [rip+0x153]        # 3410 <botlish_fn_16+0x228>
    32bd:	jmp    32d5 <botlish_fn_16+0xed>
    32c2:	mov    ecx,0x2
    32c7:	mov    rsi,r14
    32ca:	cmp    rsi,rdx
    32cd:	cmovge rcx,QWORD PTR [rip+0x13b]        # 3410 <botlish_fn_16+0x228>
    32d5:	cmp    rcx,0x6
    32d9:	je     33be <botlish_fn_16+0x1d6>
    32df:	mov    rsi,QWORD PTR [rbx+0x20]
    32e3:	mov    rsi,QWORD PTR [rsi+0x8]
    32e7:	mov    QWORD PTR [r12+0x8],rsi
    32ec:	mov    rdx,r14
    32ef:	mov    rdi,r13
    32f2:	call   32f7 <botlish_fn_16+0x10f>
			32f3: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    32f7:	test   rax,rax
    32fa:	jne    3308 <botlish_fn_16+0x120>
    3300:	mov    rdi,r13
    3303:	jmp    3324 <botlish_fn_16+0x13c>
    3308:	mov    QWORD PTR [r12+0x8],rax
    330d:	mov    rsi,rax
    3310:	mov    rdi,r13
    3313:	call   3318 <botlish_fn_16+0x130>
			3314: R_X86_64_PLT32	botlish_fn_14-0x4 ; is_label_char<str>
    3318:	test   rax,rax
    331b:	jne    3349 <botlish_fn_16+0x161>
    3321:	mov    rdi,r13
    3324:	mov    rdi,r13
    3327:	mov    QWORD PTR [rdi],r12
    332a:	xor    rax,rax
    332d:	mov    rbx,QWORD PTR [rsp]
    3331:	mov    r12,QWORD PTR [rsp+0x8]
    3336:	mov    r13,QWORD PTR [rsp+0x10]
    333b:	mov    r14,QWORD PTR [rsp+0x18]
    3340:	add    rsp,0x20
    3344:	mov    rsp,rbp
    3347:	pop    rbp
    3348:	ret
    3349:	cmp    rax,0x6
    334d:	je     335e <botlish_fn_16+0x176>
    3353:	mov    rax,r14
    3356:	mov    rdi,r13
    3359:	jmp    33c4 <botlish_fn_16+0x1dc>
    335e:	mov    QWORD PTR [r12+0x8],rbx
    3363:	mov    QWORD PTR [r12+0x10],0x3
    336c:	mov    rsi,r14
    336f:	test   rsi,0x1
    3376:	je     339c <botlish_fn_16+0x1b4>
    337c:	mov    rsi,r14
    337f:	mov    rcx,rsi
    3382:	add    rcx,0x2
    3386:	seto   al
    3389:	test   al,al
    338b:	jne    339c <botlish_fn_16+0x1b4>
    3391:	mov    rsi,rcx
    3394:	mov    r14,rcx
    3397:	jmp    33b2 <botlish_fn_16+0x1ca>
    339c:	mov    edx,0x3
    33a1:	mov    rsi,r14
    33a4:	mov    rdi,r13
    33a7:	call   33ac <botlish_fn_16+0x1c4>
			33a8: R_X86_64_PLT32	rt_int_add-0x4
    33ac:	mov    rsi,rax
    33af:	mov    r14,rax
    33b2:	mov    QWORD PTR [r12],rsi
    33b6:	mov    rsi,r14
    33b9:	jmp    3236 <botlish_fn_16+0x4e>
    33be:	mov    rax,r14
    33c1:	mov    rdi,r13
    33c4:	mov    rdi,r13
    33c7:	mov    QWORD PTR [rdi],r12
    33ca:	mov    rbx,QWORD PTR [rsp]
    33ce:	mov    r12,QWORD PTR [rsp+0x8]
    33d3:	mov    r13,QWORD PTR [rsp+0x10]
    33d8:	mov    r14,QWORD PTR [rsp+0x18]
    33dd:	add    rsp,0x20
    33e1:	mov    rsp,rbp
    33e4:	pop    rbp
    33e5:	ret
    33e6:	mov    r13,rdi
    33e9:	call   33ee <botlish_fn_16+0x206>
			33ea: R_X86_64_PLT32	rt_stack_overflow-0x4
    33ee:	xor    rax,rax
    33f1:	mov    rbx,QWORD PTR [rsp]
    33f5:	mov    r12,QWORD PTR [rsp+0x8]
    33fa:	mov    r13,QWORD PTR [rsp+0x10]
    33ff:	mov    r14,QWORD PTR [rsp+0x18]
    3404:	add    rsp,0x20
    3408:	mov    rsp,rbp
    340b:	pop    rbp
    340c:	ret
    340d:	add    BYTE PTR [rax],al
    340f:	add    BYTE PTR [rsi],al
    3411:	add    BYTE PTR [rax],al
    3413:	add    BYTE PTR [rax],al
    3415:	add    BYTE PTR [rax],al
	...

0000000000003418 <botlish_entry_16: scan_label<generic>>:
    3418:	push   rbp
    3419:	mov    rbp,rsp
    341c:	mov    rdx,QWORD PTR [rdx]
    341f:	call   3424 <botlish_entry_16+0xc>
			3420: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_label<generic>
    3424:	mov    rsp,rbp
    3427:	pop    rbp
    3428:	ret
    3429:	add    BYTE PTR [rax],al
    342b:	add    BYTE PTR [rax],al
    342d:	add    BYTE PTR [rax],al
	...

0000000000003430 <botlish_fn_17: scan_alpha<generic>>:
    3430:	push   rbp
    3431:	mov    rbp,rsp
    3434:	sub    rsp,0x20
    3438:	mov    QWORD PTR [rsp],rbx
    343c:	mov    QWORD PTR [rsp+0x8],r12
    3441:	mov    QWORD PTR [rsp+0x10],r13
    3446:	mov    QWORD PTR [rsp+0x18],r14
    344b:	mov    r12,QWORD PTR [rdi]
    344e:	mov    rax,QWORD PTR [rdi+0x8]
    3452:	lea    rcx,[r12+0x18]
    3457:	cmp    rcx,rax
    345a:	ja     3629 <botlish_fn_17+0x1f9>
    3460:	lea    rax,[r12+0x18]
    3465:	mov    QWORD PTR [rdi],rax
    3468:	mov    r13,rdi
    346b:	mov    QWORD PTR [r12+0x10],0x0
    3474:	mov    QWORD PTR [r12],rdx
    3478:	mov    rbx,rsi
    347b:	mov    rsi,rdx
    347e:	mov    rax,QWORD PTR [rbx+0x20]
    3482:	mov    rdx,QWORD PTR [rax]
    3485:	mov    ecx,0x1
    348a:	test   rsi,0x1
    3491:	jne    34af <botlish_fn_17+0x7f>
    3497:	xor    ecx,ecx
    3499:	test   rsi,0x7
    34a0:	jne    34af <botlish_fn_17+0x7f>
    34a6:	movzx  rax,BYTE PTR [rsi]
    34aa:	cmp    al,0x1
    34ac:	sete   cl
    34af:	test   cl,cl
    34b1:	jne    34d5 <botlish_fn_17+0xa5>
    34b7:	mov    rdi,r13
    34ba:	mov    rax,QWORD PTR [rdi+0x10]
    34be:	mov    rcx,QWORD PTR [rax+0xb8]
    34c5:	xor    rdx,rdx
    34c8:	call   34cd <botlish_fn_17+0x9d>
			34c9: R_X86_64_PLT32	rt_type_error-0x4
    34cd:	mov    rdi,r13
    34d0:	jmp    3567 <botlish_fn_17+0x137>
    34d5:	mov    rax,rsi
    34d8:	and    rax,rdx
    34db:	mov    r14,rsi
    34de:	test   rax,0x1
    34e4:	jne    350a <botlish_fn_17+0xda>
    34ea:	mov    rsi,r14
    34ed:	mov    rdi,r13
    34f0:	call   34f5 <botlish_fn_17+0xc5>
			34f1: R_X86_64_PLT32	rt_int_cmp-0x4
    34f5:	mov    ecx,0x2
    34fa:	test   rax,rax
    34fd:	cmovge rcx,QWORD PTR [rip+0x14b]        # 3650 <botlish_fn_17+0x220>
    3505:	jmp    351d <botlish_fn_17+0xed>
    350a:	mov    ecx,0x2
    350f:	mov    rsi,r14
    3512:	cmp    rsi,rdx
    3515:	cmovge rcx,QWORD PTR [rip+0x133]        # 3650 <botlish_fn_17+0x220>
    351d:	cmp    rcx,0x6
    3521:	je     3601 <botlish_fn_17+0x1d1>
    3527:	mov    rsi,QWORD PTR [rbx+0x20]
    352b:	mov    rsi,QWORD PTR [rsi+0x8]
    352f:	mov    QWORD PTR [r12+0x8],rsi
    3534:	mov    rdx,r14
    3537:	mov    rdi,r13
    353a:	call   353f <botlish_fn_17+0x10f>
			353b: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    353f:	test   rax,rax
    3542:	mov    rsi,rax
    3545:	jne    3553 <botlish_fn_17+0x123>
    354b:	mov    rdi,r13
    354e:	jmp    3567 <botlish_fn_17+0x137>
    3553:	mov    rdi,r13
    3556:	call   355b <botlish_fn_17+0x12b>
			3557: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    355b:	test   rax,rax
    355e:	jne    358c <botlish_fn_17+0x15c>
    3564:	mov    rdi,r13
    3567:	mov    rdi,r13
    356a:	mov    QWORD PTR [rdi],r12
    356d:	xor    rax,rax
    3570:	mov    rbx,QWORD PTR [rsp]
    3574:	mov    r12,QWORD PTR [rsp+0x8]
    3579:	mov    r13,QWORD PTR [rsp+0x10]
    357e:	mov    r14,QWORD PTR [rsp+0x18]
    3583:	add    rsp,0x20
    3587:	mov    rsp,rbp
    358a:	pop    rbp
    358b:	ret
    358c:	cmp    rax,0x6
    3590:	je     35a1 <botlish_fn_17+0x171>
    3596:	mov    rax,r14
    3599:	mov    rdi,r13
    359c:	jmp    3607 <botlish_fn_17+0x1d7>
    35a1:	mov    QWORD PTR [r12+0x8],rbx
    35a6:	mov    QWORD PTR [r12+0x10],0x3
    35af:	mov    rsi,r14
    35b2:	test   rsi,0x1
    35b9:	je     35df <botlish_fn_17+0x1af>
    35bf:	mov    rsi,r14
    35c2:	mov    rcx,rsi
    35c5:	add    rcx,0x2
    35c9:	seto   al
    35cc:	test   al,al
    35ce:	jne    35df <botlish_fn_17+0x1af>
    35d4:	mov    rsi,rcx
    35d7:	mov    r14,rcx
    35da:	jmp    35f5 <botlish_fn_17+0x1c5>
    35df:	mov    edx,0x3
    35e4:	mov    rsi,r14
    35e7:	mov    rdi,r13
    35ea:	call   35ef <botlish_fn_17+0x1bf>
			35eb: R_X86_64_PLT32	rt_int_add-0x4
    35ef:	mov    rsi,rax
    35f2:	mov    r14,rax
    35f5:	mov    QWORD PTR [r12],rsi
    35f9:	mov    rsi,r14
    35fc:	jmp    347e <botlish_fn_17+0x4e>
    3601:	mov    rax,r14
    3604:	mov    rdi,r13
    3607:	mov    rdi,r13
    360a:	mov    QWORD PTR [rdi],r12
    360d:	mov    rbx,QWORD PTR [rsp]
    3611:	mov    r12,QWORD PTR [rsp+0x8]
    3616:	mov    r13,QWORD PTR [rsp+0x10]
    361b:	mov    r14,QWORD PTR [rsp+0x18]
    3620:	add    rsp,0x20
    3624:	mov    rsp,rbp
    3627:	pop    rbp
    3628:	ret
    3629:	mov    r13,rdi
    362c:	call   3631 <botlish_fn_17+0x201>
			362d: R_X86_64_PLT32	rt_stack_overflow-0x4
    3631:	xor    rax,rax
    3634:	mov    rbx,QWORD PTR [rsp]
    3638:	mov    r12,QWORD PTR [rsp+0x8]
    363d:	mov    r13,QWORD PTR [rsp+0x10]
    3642:	mov    r14,QWORD PTR [rsp+0x18]
    3647:	add    rsp,0x20
    364b:	mov    rsp,rbp
    364e:	pop    rbp
    364f:	ret
    3650:	(bad)
    3651:	add    BYTE PTR [rax],al
    3653:	add    BYTE PTR [rax],al
    3655:	add    BYTE PTR [rax],al
	...

0000000000003658 <botlish_entry_17: scan_alpha<generic>>:
    3658:	push   rbp
    3659:	mov    rbp,rsp
    365c:	mov    rdx,QWORD PTR [rdx]
    365f:	call   3664 <botlish_entry_17+0xc>
			3660: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_alpha<generic>
    3664:	mov    rsp,rbp
    3667:	pop    rbp
    3668:	ret
    3669:	add    BYTE PTR [rax],al
    366b:	add    BYTE PTR [rax],al
    366d:	add    BYTE PTR [rax],al
	...

0000000000003670 <botlish_fn_18: tld_ok<generic>>:
    3670:	push   rbp
    3671:	mov    rbp,rsp
    3674:	sub    rsp,0x30
    3678:	mov    QWORD PTR [rsp],rbx
    367c:	mov    QWORD PTR [rsp+0x8],r12
    3681:	mov    QWORD PTR [rsp+0x10],r13
    3686:	mov    QWORD PTR [rsp+0x18],r14
    368b:	mov    QWORD PTR [rsp+0x20],r15
    3690:	mov    rbx,QWORD PTR [rdi]
    3693:	mov    rax,QWORD PTR [rdi+0x8]
    3697:	lea    rcx,[rbx+0x10]
    369b:	cmp    rcx,rax
    369e:	ja     38a3 <botlish_fn_18+0x233>
    36a4:	lea    rax,[rbx+0x10]
    36a8:	mov    QWORD PTR [rdi],rax
    36ab:	mov    r13,rdi
    36ae:	mov    QWORD PTR [rbx],rdx
    36b1:	mov    r8,rdx
    36b4:	mov    rax,QWORD PTR [rsi+0x20]
    36b8:	mov    r15,rsi
    36bb:	mov    rsi,QWORD PTR [rax]
    36be:	mov    QWORD PTR [rbx+0x8],rsi
    36c2:	mov    r12,r8
    36c5:	mov    rdx,r12
    36c8:	mov    rdi,r13
    36cb:	call   36d0 <botlish_fn_18+0x60>
			36cc: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_alpha<generic>
    36d0:	mov    rcx,rax
    36d3:	mov    r14,rax
    36d6:	test   rax,rcx
    36d9:	jne    36e7 <botlish_fn_18+0x77>
    36df:	mov    rdi,r13
    36e2:	jmp    37bf <botlish_fn_18+0x14f>
    36e7:	mov    rax,r14
    36ea:	mov    QWORD PTR [rbx+0x8],rax
    36ee:	mov    rsi,r15
    36f1:	mov    rax,QWORD PTR [rsi+0x20]
    36f5:	mov    rdx,QWORD PTR [rax+0x8]
    36f9:	mov    rax,r14
    36fc:	and    rax,rdx
    36ff:	test   rax,0x1
    3705:	jne    372e <botlish_fn_18+0xbe>
    370b:	mov    rsi,r14
    370e:	mov    rdi,r13
    3711:	call   3716 <botlish_fn_18+0xa6>
			3712: R_X86_64_PLT32	rt_int_cmp-0x4
    3716:	mov    ecx,0x2
    371b:	test   rax,rax
    371e:	cmove  rcx,QWORD PTR [rip+0x1aa]        # 38d0 <botlish_fn_18+0x260>
    3726:	mov    rax,r14
    3729:	jmp    3741 <botlish_fn_18+0xd1>
    372e:	mov    ecx,0x2
    3733:	mov    rax,r14
    3736:	cmp    rax,rdx
    3739:	cmove  rcx,QWORD PTR [rip+0x18f]        # 38d0 <botlish_fn_18+0x260>
    3741:	cmp    rcx,0x6
    3745:	je     375b <botlish_fn_18+0xeb>
    374b:	mov    ecx,0x2
    3750:	mov    rax,rcx
    3753:	mov    rdi,r13
    3756:	jmp    387c <botlish_fn_18+0x20c>
    375b:	mov    ecx,0x1
    3760:	test   r12,0x1
    3767:	je     3775 <botlish_fn_18+0x105>
    376d:	mov    r8,r12
    3770:	jmp    379b <botlish_fn_18+0x12b>
    3775:	xor    ecx,ecx
    3777:	test   r12,0x7
    377e:	je     378c <botlish_fn_18+0x11c>
    3784:	mov    r8,r12
    3787:	jmp    379b <botlish_fn_18+0x12b>
    378c:	movzx  rcx,BYTE PTR [r12]
    3791:	mov    r8,r12
    3794:	rex cmp cl,0x1
    3798:	sete   cl
    379b:	test   cl,cl
    379d:	jne    37e9 <botlish_fn_18+0x179>
    37a3:	mov    rdi,r13
    37a6:	mov    rax,QWORD PTR [rdi+0x10]
    37aa:	mov    rcx,QWORD PTR [rax+0x128]
    37b1:	xor    rdx,rdx
    37b4:	mov    rsi,r8
    37b7:	call   37bc <botlish_fn_18+0x14c>
			37b8: R_X86_64_PLT32	rt_type_error-0x4
    37bc:	mov    rdi,r13
    37bf:	mov    rdi,r13
    37c2:	mov    QWORD PTR [rdi],rbx
    37c5:	xor    rax,rax
    37c8:	mov    rbx,QWORD PTR [rsp]
    37cc:	mov    r12,QWORD PTR [rsp+0x8]
    37d1:	mov    r13,QWORD PTR [rsp+0x10]
    37d6:	mov    r14,QWORD PTR [rsp+0x18]
    37db:	mov    r15,QWORD PTR [rsp+0x20]
    37e0:	add    rsp,0x30
    37e4:	mov    rsp,rbp
    37e7:	pop    rbp
    37e8:	ret
    37e9:	mov    r12,r8
    37ec:	mov    rcx,rax
    37ef:	and    rcx,r12
    37f2:	test   rcx,0x1
    37f9:	jne    380a <botlish_fn_18+0x19a>
    37ff:	mov    rdx,r8
    3802:	mov    rsi,rax
    3805:	jmp    382b <botlish_fn_18+0x1bb>
    380a:	mov    r12,r8
    380d:	mov    rcx,rax
    3810:	sub    rcx,r12
    3813:	mov    r14,rax
    3816:	seto   al
    3819:	lea    rsi,[rcx+0x1]
    381d:	test   al,al
    381f:	je     3836 <botlish_fn_18+0x1c6>
    3825:	mov    rdx,r8
    3828:	mov    rsi,r14
    382b:	mov    rdi,r13
    382e:	call   3833 <botlish_fn_18+0x1c3>
			382f: R_X86_64_PLT32	rt_int_sub-0x4
    3833:	mov    rsi,rax
    3836:	test   rsi,0x1
    383d:	jne    3868 <botlish_fn_18+0x1f8>
    3843:	mov    edx,0x5
    3848:	mov    rdi,r13
    384b:	call   3850 <botlish_fn_18+0x1e0>
			384c: R_X86_64_PLT32	rt_int_cmp-0x4
    3850:	mov    ecx,0x2
    3855:	test   rax,rax
    3858:	mov    rax,rcx
    385b:	cmovge rax,QWORD PTR [rip+0x6d]        # 38d0 <botlish_fn_18+0x260>
    3863:	jmp    3879 <botlish_fn_18+0x209>
    3868:	mov    eax,0x2
    386d:	cmp    rsi,0x5
    3871:	cmovge rax,QWORD PTR [rip+0x57]        # 38d0 <botlish_fn_18+0x260>
    3879:	mov    rdi,r13
    387c:	mov    rdi,r13
    387f:	mov    QWORD PTR [rdi],rbx
    3882:	mov    rbx,QWORD PTR [rsp]
    3886:	mov    r12,QWORD PTR [rsp+0x8]
    388b:	mov    r13,QWORD PTR [rsp+0x10]
    3890:	mov    r14,QWORD PTR [rsp+0x18]
    3895:	mov    r15,QWORD PTR [rsp+0x20]
    389a:	add    rsp,0x30
    389e:	mov    rsp,rbp
    38a1:	pop    rbp
    38a2:	ret
    38a3:	mov    r13,rdi
    38a6:	call   38ab <botlish_fn_18+0x23b>
			38a7: R_X86_64_PLT32	rt_stack_overflow-0x4
    38ab:	xor    rax,rax
    38ae:	mov    rbx,QWORD PTR [rsp]
    38b2:	mov    r12,QWORD PTR [rsp+0x8]
    38b7:	mov    r13,QWORD PTR [rsp+0x10]
    38bc:	mov    r14,QWORD PTR [rsp+0x18]
    38c1:	mov    r15,QWORD PTR [rsp+0x20]
    38c6:	add    rsp,0x30
    38ca:	mov    rsp,rbp
    38cd:	pop    rbp
    38ce:	ret
    38cf:	add    BYTE PTR [rsi],al
    38d1:	add    BYTE PTR [rax],al
    38d3:	add    BYTE PTR [rax],al
    38d5:	add    BYTE PTR [rax],al
	...

00000000000038d8 <botlish_entry_18: tld_ok<generic>>:
    38d8:	push   rbp
    38d9:	mov    rbp,rsp
    38dc:	mov    rdx,QWORD PTR [rdx]
    38df:	call   38e4 <botlish_entry_18+0xc>
			38e0: R_X86_64_PLT32	botlish_fn_18-0x4 ; tld_ok<generic>
    38e4:	mov    rsp,rbp
    38e7:	pop    rbp
    38e8:	ret
    38e9:	add    BYTE PTR [rax],al
    38eb:	add    BYTE PTR [rax],al
    38ed:	add    BYTE PTR [rax],al
	...

00000000000038f0 <botlish_fn_19: domain_loop<generic>>:
    38f0:	push   rbp
    38f1:	mov    rbp,rsp
    38f4:	sub    rsp,0x50
    38f8:	mov    QWORD PTR [rsp+0x20],rbx
    38fd:	mov    QWORD PTR [rsp+0x28],r12
    3902:	mov    QWORD PTR [rsp+0x30],r13
    3907:	mov    QWORD PTR [rsp+0x38],r14
    390c:	mov    QWORD PTR [rsp+0x40],r15
    3911:	mov    r13,QWORD PTR [rdi]
    3914:	mov    rax,QWORD PTR [rdi+0x8]
    3918:	lea    rcx,[r13+0x10]
    391c:	cmp    rcx,rax
    391f:	ja     3b8e <botlish_fn_19+0x29e>
    3925:	lea    rax,[r13+0x10]
    3929:	mov    QWORD PTR [rdi],rax
    392c:	mov    r15,rdi
    392f:	mov    QWORD PTR [r13+0x0],rdx
    3933:	mov    QWORD PTR [rsp+0x10],rdx
    3938:	lea    rbx,[rsp]
    393c:	mov    r12,rsi
    393f:	mov    rax,QWORD PTR [r12+0x20]
    3944:	mov    rsi,QWORD PTR [rax]
    3947:	mov    QWORD PTR [r13+0x8],rsi
    394b:	mov    rdx,QWORD PTR [rsp+0x10]
    3950:	mov    rdi,r15
    3953:	call   3958 <botlish_fn_19+0x68>
			3954: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_label<generic>
    3958:	mov    rcx,rax
    395b:	mov    r14,rax
    395e:	test   rax,rcx
    3961:	jne    396f <botlish_fn_19+0x7f>
    3967:	mov    rdi,r15
    396a:	jmp    3afc <botlish_fn_19+0x20c>
    396f:	mov    rax,r14
    3972:	mov    QWORD PTR [r13+0x0],rax
    3976:	mov    rdx,QWORD PTR [rsp+0x10]
    397b:	mov    rsi,rax
    397e:	and    rsi,rdx
    3981:	test   rsi,0x1
    3988:	jne    39af <botlish_fn_19+0xbf>
    398e:	mov    rdx,QWORD PTR [rsp+0x10]
    3993:	mov    rsi,r14
    3996:	mov    rdi,r15
    3999:	call   399e <botlish_fn_19+0xae>
			399a: R_X86_64_PLT32	rt_value_eq-0x4
    399e:	test   rax,rax
    39a1:	jne    39c4 <botlish_fn_19+0xd4>
    39a7:	mov    rdi,r15
    39aa:	jmp    3afc <botlish_fn_19+0x20c>
    39af:	mov    eax,0x2
    39b4:	mov    rdx,QWORD PTR [rsp+0x10]
    39b9:	cmp    r14,rdx
    39bc:	cmove  rax,QWORD PTR [rip+0x1fc]        # 3bc0 <botlish_fn_19+0x2d0>
    39c4:	cmp    rax,0x6
    39c8:	je     3b5c <botlish_fn_19+0x26c>
    39ce:	mov    rax,QWORD PTR [r12+0x20]
    39d3:	mov    rdx,QWORD PTR [rax+0x8]
    39d7:	mov    rax,r14
    39da:	and    rax,rdx
    39dd:	test   rax,0x1
    39e3:	jne    3a09 <botlish_fn_19+0x119>
    39e9:	mov    rsi,r14
    39ec:	mov    rdi,r15
    39ef:	call   39f4 <botlish_fn_19+0x104>
			39f0: R_X86_64_PLT32	rt_int_cmp-0x4
    39f4:	mov    ecx,0x2
    39f9:	test   rax,rax
    39fc:	cmovge rcx,QWORD PTR [rip+0x1bc]        # 3bc0 <botlish_fn_19+0x2d0>
    3a04:	jmp    3a19 <botlish_fn_19+0x129>
    3a09:	mov    ecx,0x2
    3a0e:	cmp    r14,rdx
    3a11:	cmovge rcx,QWORD PTR [rip+0x1a7]        # 3bc0 <botlish_fn_19+0x2d0>
    3a19:	cmp    rcx,0x6
    3a1d:	je     3b4d <botlish_fn_19+0x25d>
    3a23:	mov    rax,QWORD PTR [r12+0x20]
    3a28:	mov    rsi,QWORD PTR [rax+0x10]
    3a2c:	mov    QWORD PTR [r13+0x8],rsi
    3a30:	mov    rcx,rbx
    3a33:	mov    rdx,r14
    3a36:	mov    rdi,r15
    3a39:	call   3a3e <botlish_fn_19+0x14e>
			3a3a: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    3a3e:	test   rax,rax
    3a41:	mov    rsi,rax
    3a44:	jne    3a52 <botlish_fn_19+0x162>
    3a4a:	mov    rdi,r15
    3a4d:	jmp    3afc <botlish_fn_19+0x20c>
    3a52:	mov    rdx,QWORD PTR [rsp]
    3a56:	mov    rcx,QWORD PTR [rsp+0x8]
    3a5b:	mov    rdi,r15
    3a5e:	mov    rax,QWORD PTR [rdi+0x10]
    3a62:	mov    r8,QWORD PTR [rax+0x118]
    3a69:	call   3a6e <botlish_fn_19+0x17e>
			3a6a: R_X86_64_PLT32	rt_str_region_eq-0x4
    3a6e:	cmp    rax,0x6
    3a72:	je     3a84 <botlish_fn_19+0x194>
    3a78:	mov    rax,0xffffffffffffffff
    3a7f:	jmp    3b54 <botlish_fn_19+0x264>
    3a84:	mov    QWORD PTR [r13+0x8],0x3
    3a8c:	test   r14,0x1
    3a93:	je     3aba <botlish_fn_19+0x1ca>
    3a99:	mov    rdx,r14
    3a9c:	add    rdx,0x2
    3aa0:	mov    QWORD PTR [rsp+0x10],rdx
    3aa5:	seto   al
    3aa8:	test   al,al
    3aaa:	jne    3aba <botlish_fn_19+0x1ca>
    3ab0:	mov    rdx,QWORD PTR [rsp+0x10]
    3ab5:	jmp    3ad2 <botlish_fn_19+0x1e2>
    3aba:	mov    edx,0x3
    3abf:	mov    rsi,r14
    3ac2:	mov    rdi,r15
    3ac5:	call   3aca <botlish_fn_19+0x1da>
			3ac6: R_X86_64_PLT32	rt_int_add-0x4
    3aca:	mov    rdx,rax
    3acd:	mov    QWORD PTR [rsp+0x10],rax
    3ad2:	mov    QWORD PTR [r13+0x0],rdx
    3ad6:	mov    rax,QWORD PTR [r12+0x20]
    3adb:	mov    rsi,QWORD PTR [rax+0x18]
    3adf:	mov    QWORD PTR [r13+0x8],rsi
    3ae3:	mov    rdx,QWORD PTR [rsp+0x10]
    3ae8:	mov    rdi,r15
    3aeb:	call   3af0 <botlish_fn_19+0x200>
			3aec: R_X86_64_PLT32	botlish_fn_18-0x4 ; tld_ok<generic>
    3af0:	test   rax,rax
    3af3:	jne    3b27 <botlish_fn_19+0x237>
    3af9:	mov    rdi,r15
    3afc:	mov    rdi,r15
    3aff:	mov    QWORD PTR [rdi],r13
    3b02:	xor    rax,rax
    3b05:	mov    rbx,QWORD PTR [rsp+0x20]
    3b0a:	mov    r12,QWORD PTR [rsp+0x28]
    3b0f:	mov    r13,QWORD PTR [rsp+0x30]
    3b14:	mov    r14,QWORD PTR [rsp+0x38]
    3b19:	mov    r15,QWORD PTR [rsp+0x40]
    3b1e:	add    rsp,0x50
    3b22:	mov    rsp,rbp
    3b25:	pop    rbp
    3b26:	ret
    3b27:	cmp    rax,0x6
    3b2b:	je     3b3f <botlish_fn_19+0x24f>
    3b31:	mov    rdx,QWORD PTR [rsp+0x10]
    3b36:	mov    QWORD PTR [r13+0x0],rdx
    3b3a:	jmp    393f <botlish_fn_19+0x4f>
    3b3f:	mov    rax,QWORD PTR [r12+0x20]
    3b44:	mov    rax,QWORD PTR [rax+0x8]
    3b48:	jmp    3b54 <botlish_fn_19+0x264>
    3b4d:	mov    rax,0xffffffffffffffff
    3b54:	mov    rdi,r15
    3b57:	jmp    3b66 <botlish_fn_19+0x276>
    3b5c:	mov    rax,0xffffffffffffffff
    3b63:	mov    rdi,r15
    3b66:	mov    rdi,r15
    3b69:	mov    QWORD PTR [rdi],r13
    3b6c:	mov    rbx,QWORD PTR [rsp+0x20]
    3b71:	mov    r12,QWORD PTR [rsp+0x28]
    3b76:	mov    r13,QWORD PTR [rsp+0x30]
    3b7b:	mov    r14,QWORD PTR [rsp+0x38]
    3b80:	mov    r15,QWORD PTR [rsp+0x40]
    3b85:	add    rsp,0x50
    3b89:	mov    rsp,rbp
    3b8c:	pop    rbp
    3b8d:	ret
    3b8e:	mov    r15,rdi
    3b91:	call   3b96 <botlish_fn_19+0x2a6>
			3b92: R_X86_64_PLT32	rt_stack_overflow-0x4
    3b96:	xor    rax,rax
    3b99:	mov    rbx,QWORD PTR [rsp+0x20]
    3b9e:	mov    r12,QWORD PTR [rsp+0x28]
    3ba3:	mov    r13,QWORD PTR [rsp+0x30]
    3ba8:	mov    r14,QWORD PTR [rsp+0x38]
    3bad:	mov    r15,QWORD PTR [rsp+0x40]
    3bb2:	add    rsp,0x50
    3bb6:	mov    rsp,rbp
    3bb9:	pop    rbp
    3bba:	ret
    3bbb:	add    BYTE PTR [rax],al
    3bbd:	add    BYTE PTR [rax],al
    3bbf:	add    BYTE PTR [rsi],al
    3bc1:	add    BYTE PTR [rax],al
    3bc3:	add    BYTE PTR [rax],al
    3bc5:	add    BYTE PTR [rax],al
	...

0000000000003bc8 <botlish_entry_19: domain_loop<generic>>:
    3bc8:	push   rbp
    3bc9:	mov    rbp,rsp
    3bcc:	mov    rdx,QWORD PTR [rdx]
    3bcf:	call   3bd4 <botlish_entry_19+0xc>
			3bd0: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    3bd4:	mov    rsp,rbp
    3bd7:	pop    rbp
    3bd8:	ret
    3bd9:	add    BYTE PTR [rax],al
    3bdb:	add    BYTE PTR [rax],al
    3bdd:	add    BYTE PTR [rax],al
	...

0000000000003be0 <botlish_fn_20: <str>>:
    3be0:	push   rbp
    3be1:	mov    rbp,rsp
    3be4:	sub    rsp,0xc0
    3beb:	mov    QWORD PTR [rsp+0x90],rbx
    3bf3:	mov    QWORD PTR [rsp+0x98],r12
    3bfb:	mov    QWORD PTR [rsp+0xa0],r13
    3c03:	mov    QWORD PTR [rsp+0xa8],r14
    3c0b:	mov    QWORD PTR [rsp+0xb0],r15
    3c13:	mov    r12,QWORD PTR [rdi]
    3c16:	mov    rax,QWORD PTR [rdi+0x8]
    3c1a:	lea    rcx,[r12+0x28]
    3c1f:	cmp    rcx,rax
    3c22:	ja     4034 <botlish_fn_20+0x454>
    3c28:	lea    rax,[r12+0x28]
    3c2d:	mov    QWORD PTR [rdi],rax
    3c30:	mov    QWORD PTR [rsp+0x78],rdi
    3c35:	mov    QWORD PTR [r12+0x10],0x0
    3c3e:	mov    QWORD PTR [r12+0x18],0x0
    3c47:	mov    QWORD PTR [r12+0x20],0x0
    3c50:	mov    QWORD PTR [r12],rsi
    3c54:	mov    r13,rsi
    3c57:	mov    rsi,r13
    3c5a:	mov    rdi,QWORD PTR [rsp+0x78]
    3c5f:	call   3c64 <botlish_fn_20+0x84>
			3c60: R_X86_64_PLT32	rt_str_len-0x4
    3c64:	mov    rbx,rax
    3c67:	mov    QWORD PTR [r12+0x8],rbx
    3c6c:	lea    r8,[rsp]
    3c70:	mov    QWORD PTR [rsp],r13
    3c74:	mov    esi,0x16
    3c79:	mov    rdx,QWORD PTR [rip+0x0]        # 3c80 <botlish_fn_20+0xa0>
			3c7c: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; char_at<generic>
    3c80:	mov    r13d,0x1
    3c86:	mov    rcx,r13
    3c89:	mov    rdi,QWORD PTR [rsp+0x78]
    3c8e:	call   3c93 <botlish_fn_20+0xb3>
			3c8f: R_X86_64_PLT32	rt_closure_new-0x4
    3c93:	mov    r14,rax
    3c96:	mov    QWORD PTR [r12],rax
    3c9a:	lea    r8,[rsp+0x8]
    3c9f:	mov    QWORD PTR [rsp+0x8],rbx
    3ca4:	mov    QWORD PTR [rsp+0x10],rax
    3ca9:	mov    esi,0x1a
    3cae:	mov    rdx,QWORD PTR [rip+0x0]        # 3cb5 <botlish_fn_20+0xd5>
			3cb1: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; scan_local<generic>
    3cb5:	mov    r15d,0x2
    3cbb:	mov    rcx,r15
    3cbe:	mov    rdi,QWORD PTR [rsp+0x78]
    3cc3:	call   3cc8 <botlish_fn_20+0xe8>
			3cc4: R_X86_64_PLT32	rt_closure_new-0x4
    3cc8:	mov    rcx,rax
    3ccb:	mov    QWORD PTR [rsp+0x88],rax
    3cd3:	mov    QWORD PTR [r12+0x10],rcx
    3cd8:	lea    r8,[rsp+0x18]
    3cdd:	mov    QWORD PTR [rsp+0x18],rbx
    3ce2:	mov    rax,r14
    3ce5:	mov    QWORD PTR [rsp+0x20],rax
    3cea:	mov    esi,0x1b
    3cef:	mov    rdx,QWORD PTR [rip+0x0]        # 3cf6 <botlish_fn_20+0x116>
			3cf2: R_X86_64_GOTPCREL	botlish_entry_27-0x4 ; scan_label<generic>
    3cf6:	mov    rcx,r15
    3cf9:	mov    rdi,QWORD PTR [rsp+0x78]
    3cfe:	call   3d03 <botlish_fn_20+0x123>
			3cff: R_X86_64_PLT32	rt_closure_new-0x4
    3d03:	mov    QWORD PTR [r12+0x18],rax
    3d08:	mov    QWORD PTR [rsp+0x80],rax
    3d10:	lea    r8,[rsp+0x28]
    3d15:	mov    QWORD PTR [rsp+0x28],rbx
    3d1a:	mov    QWORD PTR [rsp+0x30],r14
    3d1f:	mov    esi,0x1c
    3d24:	mov    rdx,QWORD PTR [rip+0x0]        # 3d2b <botlish_fn_20+0x14b>
			3d27: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; scan_alpha<generic>
    3d2b:	mov    rcx,r15
    3d2e:	mov    rdi,QWORD PTR [rsp+0x78]
    3d33:	call   3d38 <botlish_fn_20+0x158>
			3d34: R_X86_64_PLT32	rt_closure_new-0x4
    3d38:	mov    QWORD PTR [r12+0x20],rax
    3d3d:	lea    r8,[rsp+0x38]
    3d42:	mov    QWORD PTR [rsp+0x38],rax
    3d47:	mov    QWORD PTR [rsp+0x40],rbx
    3d4c:	mov    esi,0x1d
    3d51:	mov    rdx,QWORD PTR [rip+0x0]        # 3d58 <botlish_fn_20+0x178>
			3d54: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; tld_ok<generic>
    3d58:	mov    rcx,r15
    3d5b:	mov    rdi,QWORD PTR [rsp+0x78]
    3d60:	call   3d65 <botlish_fn_20+0x185>
			3d61: R_X86_64_PLT32	rt_closure_new-0x4
    3d65:	mov    QWORD PTR [r12+0x20],rax
    3d6a:	lea    r8,[rsp+0x48]
    3d6f:	mov    rcx,QWORD PTR [rsp+0x80]
    3d77:	mov    QWORD PTR [rsp+0x48],rcx
    3d7c:	mov    QWORD PTR [rsp+0x50],rbx
    3d81:	mov    QWORD PTR [rsp+0x58],r14
    3d86:	mov    QWORD PTR [rsp+0x60],rax
    3d8b:	mov    esi,0x1e
    3d90:	mov    rdx,QWORD PTR [rip+0x0]        # 3d97 <botlish_fn_20+0x1b7>
			3d93: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; domain_loop<generic>
    3d97:	mov    ecx,0x4
    3d9c:	mov    rdi,QWORD PTR [rsp+0x78]
    3da1:	call   3da6 <botlish_fn_20+0x1c6>
			3da2: R_X86_64_PLT32	rt_closure_new-0x4
    3da6:	mov    QWORD PTR [r12+0x18],rax
    3dab:	mov    r15,rax
    3dae:	mov    QWORD PTR [r12+0x20],0x1
    3db7:	mov    rdx,r13
    3dba:	mov    rsi,QWORD PTR [rsp+0x88]
    3dc2:	mov    rdi,QWORD PTR [rsp+0x78]
    3dc7:	call   3dcc <botlish_fn_20+0x1ec>
			3dc8: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    3dcc:	mov    rcx,rax
    3dcf:	mov    r13,rax
    3dd2:	test   rax,rcx
    3dd5:	jne    3de5 <botlish_fn_20+0x205>
    3ddb:	mov    rdi,QWORD PTR [rsp+0x78]
    3de0:	jmp    3f4a <botlish_fn_20+0x36a>
    3de5:	mov    rax,r13
    3de8:	mov    QWORD PTR [r12+0x10],rax
    3ded:	test   rax,0x1
    3df3:	jne    3e21 <botlish_fn_20+0x241>
    3df9:	mov    edx,0x1
    3dfe:	mov    rsi,r13
    3e01:	mov    rdi,QWORD PTR [rsp+0x78]
    3e06:	call   3e0b <botlish_fn_20+0x22b>
			3e07: R_X86_64_PLT32	rt_int_cmp-0x4
    3e0b:	mov    r10d,0x2
    3e11:	test   rax,rax
    3e14:	cmove  r10,QWORD PTR [rip+0x25c]        # 4078 <botlish_fn_20+0x498>
    3e1c:	jmp    3e33 <botlish_fn_20+0x253>
    3e21:	mov    r10d,0x2
    3e27:	cmp    r13,0x1
    3e2b:	cmove  r10,QWORD PTR [rip+0x245]        # 4078 <botlish_fn_20+0x498>
    3e33:	cmp    r10,0x6
    3e37:	je     3fee <botlish_fn_20+0x40e>
    3e3d:	mov    rax,r13
    3e40:	and    rax,rbx
    3e43:	test   rax,0x1
    3e49:	jne    3e74 <botlish_fn_20+0x294>
    3e4f:	mov    rdx,rbx
    3e52:	mov    rsi,r13
    3e55:	mov    rdi,QWORD PTR [rsp+0x78]
    3e5a:	call   3e5f <botlish_fn_20+0x27f>
			3e5b: R_X86_64_PLT32	rt_int_cmp-0x4
    3e5f:	mov    ecx,0x2
    3e64:	test   rax,rax
    3e67:	cmovge rcx,QWORD PTR [rip+0x209]        # 4078 <botlish_fn_20+0x498>
    3e6f:	jmp    3e84 <botlish_fn_20+0x2a4>
    3e74:	mov    ecx,0x2
    3e79:	cmp    r13,rbx
    3e7c:	cmovge rcx,QWORD PTR [rip+0x1f4]        # 4078 <botlish_fn_20+0x498>
    3e84:	cmp    rcx,0x6
    3e88:	je     3fdf <botlish_fn_20+0x3ff>
    3e8e:	lea    rcx,[rsp+0x68]
    3e93:	mov    rsi,r14
    3e96:	mov    rdx,r13
    3e99:	mov    rdi,QWORD PTR [rsp+0x78]
    3e9e:	call   3ea3 <botlish_fn_20+0x2c3>
			3e9f: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    3ea3:	test   rax,rax
    3ea6:	jne    3eb6 <botlish_fn_20+0x2d6>
    3eac:	mov    rdi,QWORD PTR [rsp+0x78]
    3eb1:	jmp    3f4a <botlish_fn_20+0x36a>
    3eb6:	mov    rdx,QWORD PTR [rsp+0x68]
    3ebb:	mov    rcx,QWORD PTR [rsp+0x70]
    3ec0:	mov    rdi,QWORD PTR [rsp+0x78]
    3ec5:	mov    rsi,QWORD PTR [rdi+0x10]
    3ec9:	mov    r8,QWORD PTR [rsi+0x100]
    3ed0:	mov    rsi,rax
    3ed3:	call   3ed8 <botlish_fn_20+0x2f8>
			3ed4: R_X86_64_PLT32	rt_str_region_eq-0x4
    3ed8:	cmp    rax,0x6
    3edc:	je     3eef <botlish_fn_20+0x30f>
    3ee2:	mov    ecx,0x2
    3ee7:	mov    rax,rcx
    3eea:	jmp    3fe4 <botlish_fn_20+0x404>
    3eef:	mov    QWORD PTR [r12],0x3
    3ef7:	test   r13,0x1
    3efe:	je     3f16 <botlish_fn_20+0x336>
    3f04:	mov    rdx,r13
    3f07:	add    rdx,0x2
    3f0b:	seto   al
    3f0e:	test   al,al
    3f10:	je     3f2b <botlish_fn_20+0x34b>
    3f16:	mov    edx,0x3
    3f1b:	mov    rsi,r13
    3f1e:	mov    rdi,QWORD PTR [rsp+0x78]
    3f23:	call   3f28 <botlish_fn_20+0x348>
			3f24: R_X86_64_PLT32	rt_int_add-0x4
    3f28:	mov    rdx,rax
    3f2b:	mov    QWORD PTR [r12],rdx
    3f2f:	mov    rsi,r15
    3f32:	mov    rdi,QWORD PTR [rsp+0x78]
    3f37:	call   3f3c <botlish_fn_20+0x35c>
			3f38: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    3f3c:	test   rax,rax
    3f3f:	jne    3f89 <botlish_fn_20+0x3a9>
    3f45:	mov    rdi,QWORD PTR [rsp+0x78]
    3f4a:	mov    rdi,QWORD PTR [rsp+0x78]
    3f4f:	mov    QWORD PTR [rdi],r12
    3f52:	xor    rax,rax
    3f55:	mov    rbx,QWORD PTR [rsp+0x90]
    3f5d:	mov    r12,QWORD PTR [rsp+0x98]
    3f65:	mov    r13,QWORD PTR [rsp+0xa0]
    3f6d:	mov    r14,QWORD PTR [rsp+0xa8]
    3f75:	mov    r15,QWORD PTR [rsp+0xb0]
    3f7d:	add    rsp,0xc0
    3f84:	mov    rsp,rbp
    3f87:	pop    rbp
    3f88:	ret
    3f89:	mov    rcx,rax
    3f8c:	and    rcx,rbx
    3f8f:	mov    rsi,rax
    3f92:	mov    rax,rbx
    3f95:	test   rcx,0x1
    3f9c:	jne    3fc7 <botlish_fn_20+0x3e7>
    3fa2:	mov    rdx,rax
    3fa5:	mov    rdi,QWORD PTR [rsp+0x78]
    3faa:	call   3faf <botlish_fn_20+0x3cf>
			3fab: R_X86_64_PLT32	rt_int_cmp-0x4
    3faf:	mov    ecx,0x2
    3fb4:	test   rax,rax
    3fb7:	mov    rax,rcx
    3fba:	cmove  rax,QWORD PTR [rip+0xb6]        # 4078 <botlish_fn_20+0x498>
    3fc2:	jmp    3fe4 <botlish_fn_20+0x404>
    3fc7:	mov    rdx,rax
    3fca:	mov    eax,0x2
    3fcf:	cmp    rsi,rdx
    3fd2:	cmove  rax,QWORD PTR [rip+0x9e]        # 4078 <botlish_fn_20+0x498>
    3fda:	jmp    3fe4 <botlish_fn_20+0x404>
    3fdf:	mov    eax,0x2
    3fe4:	mov    rdi,QWORD PTR [rsp+0x78]
    3fe9:	jmp    3ff8 <botlish_fn_20+0x418>
    3fee:	mov    eax,0x2
    3ff3:	mov    rdi,QWORD PTR [rsp+0x78]
    3ff8:	mov    rdi,QWORD PTR [rsp+0x78]
    3ffd:	mov    QWORD PTR [rdi],r12
    4000:	mov    rbx,QWORD PTR [rsp+0x90]
    4008:	mov    r12,QWORD PTR [rsp+0x98]
    4010:	mov    r13,QWORD PTR [rsp+0xa0]
    4018:	mov    r14,QWORD PTR [rsp+0xa8]
    4020:	mov    r15,QWORD PTR [rsp+0xb0]
    4028:	add    rsp,0xc0
    402f:	mov    rsp,rbp
    4032:	pop    rbp
    4033:	ret
    4034:	mov    QWORD PTR [rsp+0x78],rdi
    4039:	call   403e <botlish_fn_20+0x45e>
			403a: R_X86_64_PLT32	rt_stack_overflow-0x4
    403e:	xor    rax,rax
    4041:	mov    rbx,QWORD PTR [rsp+0x90]
    4049:	mov    r12,QWORD PTR [rsp+0x98]
    4051:	mov    r13,QWORD PTR [rsp+0xa0]
    4059:	mov    r14,QWORD PTR [rsp+0xa8]
    4061:	mov    r15,QWORD PTR [rsp+0xb0]
    4069:	add    rsp,0xc0
    4070:	mov    rsp,rbp
    4073:	pop    rbp
    4074:	ret
    4075:	add    BYTE PTR [rax],al
    4077:	add    BYTE PTR [rsi],al
    4079:	add    BYTE PTR [rax],al
    407b:	add    BYTE PTR [rax],al
    407d:	add    BYTE PTR [rax],al
	...

0000000000004080 <botlish_entry_20: <str>>:
    4080:	push   rbp
    4081:	mov    rbp,rsp
    4084:	mov    rsi,QWORD PTR [rdx]
    4087:	call   408c <botlish_entry_20+0xc>
			4088: R_X86_64_PLT32	botlish_fn_20-0x4 ; <str>
    408c:	mov    rsp,rbp
    408f:	pop    rbp
    4090:	ret
    4091:	add    BYTE PTR [rax],al
    4093:	add    BYTE PTR [rax],al
    4095:	add    BYTE PTR [rax],al
	...

0000000000004098 <botlish_fn_21: <generic>>:
    4098:	push   rbp
    4099:	mov    rbp,rsp
    409c:	sub    rsp,0xc0
    40a3:	mov    QWORD PTR [rsp+0x90],rbx
    40ab:	mov    QWORD PTR [rsp+0x98],r12
    40b3:	mov    QWORD PTR [rsp+0xa0],r13
    40bb:	mov    QWORD PTR [rsp+0xa8],r14
    40c3:	mov    QWORD PTR [rsp+0xb0],r15
    40cb:	mov    r12,QWORD PTR [rdi]
    40ce:	mov    rax,QWORD PTR [rdi+0x8]
    40d2:	lea    rcx,[r12+0x28]
    40d7:	cmp    rcx,rax
    40da:	ja     452a <botlish_fn_21+0x492>
    40e0:	lea    rax,[r12+0x28]
    40e5:	mov    QWORD PTR [rdi],rax
    40e8:	mov    QWORD PTR [r12+0x10],0x0
    40f1:	mov    QWORD PTR [r12+0x18],0x0
    40fa:	mov    QWORD PTR [r12+0x20],0x0
    4103:	mov    QWORD PTR [r12],rsi
    4107:	xor    eax,eax
    4109:	test   rsi,0x7
    4110:	jne    411f <botlish_fn_21+0x87>
    4116:	movzx  rax,BYTE PTR [rsi]
    411a:	cmp    al,0x2
    411c:	sete   al
    411f:	test   al,al
    4121:	jne    414b <botlish_fn_21+0xb3>
    4127:	mov    rax,QWORD PTR [rdi+0x10]
    412b:	mov    QWORD PTR [rsp+0x78],rdi
    4130:	mov    rcx,QWORD PTR [rax+0xd8]
    4137:	mov    edx,0x1
    413c:	call   4141 <botlish_fn_21+0xa9>
			413d: R_X86_64_PLT32	rt_type_error-0x4
    4141:	mov    rdi,QWORD PTR [rsp+0x78]
    4146:	jmp    4440 <botlish_fn_21+0x3a8>
    414b:	mov    r13,rsi
    414e:	mov    QWORD PTR [rsp+0x78],rdi
    4153:	call   4158 <botlish_fn_21+0xc0>
			4154: R_X86_64_PLT32	rt_str_len-0x4
    4158:	mov    rbx,rax
    415b:	mov    QWORD PTR [r12+0x8],rbx
    4160:	lea    r8,[rsp]
    4164:	mov    QWORD PTR [rsp],r13
    4168:	mov    esi,0x16
    416d:	mov    rdx,QWORD PTR [rip+0x0]        # 4174 <botlish_fn_21+0xdc>
			4170: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; char_at<generic>
    4174:	mov    r13d,0x1
    417a:	mov    rcx,r13
    417d:	mov    rdi,QWORD PTR [rsp+0x78]
    4182:	call   4187 <botlish_fn_21+0xef>
			4183: R_X86_64_PLT32	rt_closure_new-0x4
    4187:	mov    r15,rax
    418a:	mov    QWORD PTR [rsp+0x88],r13
    4192:	mov    QWORD PTR [r12],rax
    4196:	lea    r8,[rsp+0x8]
    419b:	mov    QWORD PTR [rsp+0x8],rbx
    41a0:	mov    QWORD PTR [rsp+0x10],rax
    41a5:	mov    esi,0x1a
    41aa:	mov    rdx,QWORD PTR [rip+0x0]        # 41b1 <botlish_fn_21+0x119>
			41ad: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; scan_local<generic>
    41b1:	mov    r14d,0x2
    41b7:	mov    rcx,r14
    41ba:	mov    rdi,QWORD PTR [rsp+0x78]
    41bf:	call   41c4 <botlish_fn_21+0x12c>
			41c0: R_X86_64_PLT32	rt_closure_new-0x4
    41c4:	mov    r13,rax
    41c7:	mov    QWORD PTR [r12+0x10],r13
    41cc:	lea    r8,[rsp+0x18]
    41d1:	mov    QWORD PTR [rsp+0x18],rbx
    41d6:	mov    rax,r15
    41d9:	mov    QWORD PTR [rsp+0x20],rax
    41de:	mov    esi,0x1b
    41e3:	mov    rdx,QWORD PTR [rip+0x0]        # 41ea <botlish_fn_21+0x152>
			41e6: R_X86_64_GOTPCREL	botlish_entry_27-0x4 ; scan_label<generic>
    41ea:	mov    rcx,r14
    41ed:	mov    rdi,QWORD PTR [rsp+0x78]
    41f2:	call   41f7 <botlish_fn_21+0x15f>
			41f3: R_X86_64_PLT32	rt_closure_new-0x4
    41f7:	mov    QWORD PTR [r12+0x18],rax
    41fc:	mov    QWORD PTR [rsp+0x80],rax
    4204:	lea    r8,[rsp+0x28]
    4209:	mov    QWORD PTR [rsp+0x28],rbx
    420e:	mov    QWORD PTR [rsp+0x30],r15
    4213:	mov    esi,0x1c
    4218:	mov    rdx,QWORD PTR [rip+0x0]        # 421f <botlish_fn_21+0x187>
			421b: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; scan_alpha<generic>
    421f:	mov    rcx,r14
    4222:	mov    rdi,QWORD PTR [rsp+0x78]
    4227:	call   422c <botlish_fn_21+0x194>
			4228: R_X86_64_PLT32	rt_closure_new-0x4
    422c:	mov    QWORD PTR [r12+0x20],rax
    4231:	lea    r8,[rsp+0x38]
    4236:	mov    QWORD PTR [rsp+0x38],rax
    423b:	mov    QWORD PTR [rsp+0x40],rbx
    4240:	mov    esi,0x1d
    4245:	mov    rdx,QWORD PTR [rip+0x0]        # 424c <botlish_fn_21+0x1b4>
			4248: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; tld_ok<generic>
    424c:	mov    rcx,r14
    424f:	mov    rdi,QWORD PTR [rsp+0x78]
    4254:	call   4259 <botlish_fn_21+0x1c1>
			4255: R_X86_64_PLT32	rt_closure_new-0x4
    4259:	mov    QWORD PTR [r12+0x20],rax
    425e:	lea    r8,[rsp+0x48]
    4263:	mov    rcx,QWORD PTR [rsp+0x80]
    426b:	mov    QWORD PTR [rsp+0x48],rcx
    4270:	mov    QWORD PTR [rsp+0x50],rbx
    4275:	mov    QWORD PTR [rsp+0x58],r15
    427a:	mov    QWORD PTR [rsp+0x60],rax
    427f:	mov    esi,0x1e
    4284:	mov    rdx,QWORD PTR [rip+0x0]        # 428b <botlish_fn_21+0x1f3>
			4287: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; domain_loop<generic>
    428b:	mov    ecx,0x4
    4290:	mov    rdi,QWORD PTR [rsp+0x78]
    4295:	call   429a <botlish_fn_21+0x202>
			4296: R_X86_64_PLT32	rt_closure_new-0x4
    429a:	mov    QWORD PTR [r12+0x18],rax
    429f:	mov    r14,rax
    42a2:	mov    QWORD PTR [r12+0x20],0x1
    42ab:	mov    rsi,r13
    42ae:	mov    rdx,QWORD PTR [rsp+0x88]
    42b6:	mov    rdi,QWORD PTR [rsp+0x78]
    42bb:	call   42c0 <botlish_fn_21+0x228>
			42bc: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    42c0:	mov    r10,rax
    42c3:	mov    r13,rax
    42c6:	test   rax,r10
    42c9:	jne    42d9 <botlish_fn_21+0x241>
    42cf:	mov    rdi,QWORD PTR [rsp+0x78]
    42d4:	jmp    4440 <botlish_fn_21+0x3a8>
    42d9:	mov    rax,r13
    42dc:	mov    QWORD PTR [r12+0x10],rax
    42e1:	test   rax,0x1
    42e7:	jne    4317 <botlish_fn_21+0x27f>
    42ed:	mov    rdx,QWORD PTR [rsp+0x88]
    42f5:	mov    rsi,r13
    42f8:	mov    rdi,QWORD PTR [rsp+0x78]
    42fd:	call   4302 <botlish_fn_21+0x26a>
			42fe: R_X86_64_PLT32	rt_int_cmp-0x4
    4302:	mov    ecx,0x2
    4307:	test   rax,rax
    430a:	cmove  rcx,QWORD PTR [rip+0x25e]        # 4570 <botlish_fn_21+0x4d8>
    4312:	jmp    4328 <botlish_fn_21+0x290>
    4317:	mov    ecx,0x2
    431c:	cmp    r13,0x1
    4320:	cmove  rcx,QWORD PTR [rip+0x248]        # 4570 <botlish_fn_21+0x4d8>
    4328:	cmp    rcx,0x6
    432c:	je     44e4 <botlish_fn_21+0x44c>
    4332:	mov    r11,r13
    4335:	and    r11,rbx
    4338:	test   r11,0x1
    433f:	jne    436a <botlish_fn_21+0x2d2>
    4345:	mov    rdx,rbx
    4348:	mov    rsi,r13
    434b:	mov    rdi,QWORD PTR [rsp+0x78]
    4350:	call   4355 <botlish_fn_21+0x2bd>
			4351: R_X86_64_PLT32	rt_int_cmp-0x4
    4355:	mov    ecx,0x2
    435a:	test   rax,rax
    435d:	cmovge rcx,QWORD PTR [rip+0x20b]        # 4570 <botlish_fn_21+0x4d8>
    4365:	jmp    437a <botlish_fn_21+0x2e2>
    436a:	mov    ecx,0x2
    436f:	cmp    r13,rbx
    4372:	cmovge rcx,QWORD PTR [rip+0x1f6]        # 4570 <botlish_fn_21+0x4d8>
    437a:	cmp    rcx,0x6
    437e:	je     44d5 <botlish_fn_21+0x43d>
    4384:	lea    rcx,[rsp+0x68]
    4389:	mov    rsi,r15
    438c:	mov    rdx,r13
    438f:	mov    rdi,QWORD PTR [rsp+0x78]
    4394:	call   4399 <botlish_fn_21+0x301>
			4395: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    4399:	test   rax,rax
    439c:	mov    rsi,rax
    439f:	jne    43af <botlish_fn_21+0x317>
    43a5:	mov    rdi,QWORD PTR [rsp+0x78]
    43aa:	jmp    4440 <botlish_fn_21+0x3a8>
    43af:	mov    rdx,QWORD PTR [rsp+0x68]
    43b4:	mov    rcx,QWORD PTR [rsp+0x70]
    43b9:	mov    rdi,QWORD PTR [rsp+0x78]
    43be:	mov    rax,QWORD PTR [rdi+0x10]
    43c2:	mov    r8,QWORD PTR [rax+0x100]
    43c9:	call   43ce <botlish_fn_21+0x336>
			43ca: R_X86_64_PLT32	rt_str_region_eq-0x4
    43ce:	cmp    rax,0x6
    43d2:	je     43e5 <botlish_fn_21+0x34d>
    43d8:	mov    esi,0x2
    43dd:	mov    rax,rsi
    43e0:	jmp    44da <botlish_fn_21+0x442>
    43e5:	mov    QWORD PTR [r12],0x3
    43ed:	test   r13,0x1
    43f4:	je     440c <botlish_fn_21+0x374>
    43fa:	mov    rdx,r13
    43fd:	add    rdx,0x2
    4401:	seto   al
    4404:	test   al,al
    4406:	je     4421 <botlish_fn_21+0x389>
    440c:	mov    edx,0x3
    4411:	mov    rsi,r13
    4414:	mov    rdi,QWORD PTR [rsp+0x78]
    4419:	call   441e <botlish_fn_21+0x386>
			441a: R_X86_64_PLT32	rt_int_add-0x4
    441e:	mov    rdx,rax
    4421:	mov    QWORD PTR [r12],rdx
    4425:	mov    rsi,r14
    4428:	mov    rdi,QWORD PTR [rsp+0x78]
    442d:	call   4432 <botlish_fn_21+0x39a>
			442e: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    4432:	test   rax,rax
    4435:	jne    447f <botlish_fn_21+0x3e7>
    443b:	mov    rdi,QWORD PTR [rsp+0x78]
    4440:	mov    rdi,QWORD PTR [rsp+0x78]
    4445:	mov    QWORD PTR [rdi],r12
    4448:	xor    rax,rax
    444b:	mov    rbx,QWORD PTR [rsp+0x90]
    4453:	mov    r12,QWORD PTR [rsp+0x98]
    445b:	mov    r13,QWORD PTR [rsp+0xa0]
    4463:	mov    r14,QWORD PTR [rsp+0xa8]
    446b:	mov    r15,QWORD PTR [rsp+0xb0]
    4473:	add    rsp,0xc0
    447a:	mov    rsp,rbp
    447d:	pop    rbp
    447e:	ret
    447f:	mov    rcx,rax
    4482:	and    rcx,rbx
    4485:	mov    rsi,rax
    4488:	mov    rax,rbx
    448b:	test   rcx,0x1
    4492:	jne    44bd <botlish_fn_21+0x425>
    4498:	mov    rdx,rax
    449b:	mov    rdi,QWORD PTR [rsp+0x78]
    44a0:	call   44a5 <botlish_fn_21+0x40d>
			44a1: R_X86_64_PLT32	rt_int_cmp-0x4
    44a5:	mov    esi,0x2
    44aa:	test   rax,rax
    44ad:	mov    rax,rsi
    44b0:	cmove  rax,QWORD PTR [rip+0xb8]        # 4570 <botlish_fn_21+0x4d8>
    44b8:	jmp    44da <botlish_fn_21+0x442>
    44bd:	mov    rdx,rax
    44c0:	mov    eax,0x2
    44c5:	cmp    rsi,rdx
    44c8:	cmove  rax,QWORD PTR [rip+0xa0]        # 4570 <botlish_fn_21+0x4d8>
    44d0:	jmp    44da <botlish_fn_21+0x442>
    44d5:	mov    eax,0x2
    44da:	mov    rdi,QWORD PTR [rsp+0x78]
    44df:	jmp    44ee <botlish_fn_21+0x456>
    44e4:	mov    eax,0x2
    44e9:	mov    rdi,QWORD PTR [rsp+0x78]
    44ee:	mov    rdi,QWORD PTR [rsp+0x78]
    44f3:	mov    QWORD PTR [rdi],r12
    44f6:	mov    rbx,QWORD PTR [rsp+0x90]
    44fe:	mov    r12,QWORD PTR [rsp+0x98]
    4506:	mov    r13,QWORD PTR [rsp+0xa0]
    450e:	mov    r14,QWORD PTR [rsp+0xa8]
    4516:	mov    r15,QWORD PTR [rsp+0xb0]
    451e:	add    rsp,0xc0
    4525:	mov    rsp,rbp
    4528:	pop    rbp
    4529:	ret
    452a:	mov    QWORD PTR [rsp+0x78],rdi
    452f:	call   4534 <botlish_fn_21+0x49c>
			4530: R_X86_64_PLT32	rt_stack_overflow-0x4
    4534:	xor    rax,rax
    4537:	mov    rbx,QWORD PTR [rsp+0x90]
    453f:	mov    r12,QWORD PTR [rsp+0x98]
    4547:	mov    r13,QWORD PTR [rsp+0xa0]
    454f:	mov    r14,QWORD PTR [rsp+0xa8]
    4557:	mov    r15,QWORD PTR [rsp+0xb0]
    455f:	add    rsp,0xc0
    4566:	mov    rsp,rbp
    4569:	pop    rbp
    456a:	ret
    456b:	add    BYTE PTR [rax],al
    456d:	add    BYTE PTR [rax],al
    456f:	add    BYTE PTR [rsi],al
    4571:	add    BYTE PTR [rax],al
    4573:	add    BYTE PTR [rax],al
    4575:	add    BYTE PTR [rax],al
	...

0000000000004578 <botlish_entry_21: <generic>>:
    4578:	push   rbp
    4579:	mov    rbp,rsp
    457c:	mov    rsi,QWORD PTR [rdx]
    457f:	call   4584 <botlish_entry_21+0xc>
			4580: R_X86_64_PLT32	botlish_fn_21-0x4 ; <generic>
    4584:	mov    rsp,rbp
    4587:	pop    rbp
    4588:	ret

0000000000004589 <botlish_fn_22: char_at<generic>>:
    4589:	push   rbp
    458a:	mov    rbp,rsp
    458d:	sub    rsp,0x50
    4591:	mov    QWORD PTR [rsp+0x20],rbx
    4596:	mov    QWORD PTR [rsp+0x28],r12
    459b:	mov    QWORD PTR [rsp+0x30],r13
    45a0:	mov    QWORD PTR [rsp+0x38],r14
    45a5:	mov    QWORD PTR [rsp+0x40],r15
    45aa:	mov    rbx,QWORD PTR [rdi+0x20]
    45ae:	mov    r13,QWORD PTR [rdi+0x28]
    45b2:	lea    rax,[rsp]
    45b6:	mov    QWORD PTR [rdi+0x20],rax
    45ba:	mov    QWORD PTR [rdi+0x28],0x3
    45c2:	mov    QWORD PTR [rsp],rdx
    45c6:	mov    rax,QWORD PTR [rsi+0x20]
    45ca:	mov    rsi,QWORD PTR [rax]
    45cd:	mov    QWORD PTR [rsp+0x8],rsi
    45d2:	mov    r15,rsi
    45d5:	mov    QWORD PTR [rsp+0x10],0x3
    45de:	mov    ecx,0x1
    45e3:	test   rdx,0x1
    45ea:	je     45f8 <botlish_fn_22+0x6f>
    45f0:	mov    r14,rdx
    45f3:	jmp    461b <botlish_fn_22+0x92>
    45f8:	xor    ecx,ecx
    45fa:	test   rdx,0x7
    4601:	je     460f <botlish_fn_22+0x86>
    4607:	mov    r14,rdx
    460a:	jmp    461b <botlish_fn_22+0x92>
    460f:	movzx  rax,BYTE PTR [rdx]
    4613:	mov    r14,rdx
    4616:	cmp    al,0x1
    4618:	sete   cl
    461b:	test   cl,cl
    461d:	jne    4641 <botlish_fn_22+0xb8>
    4623:	mov    rax,QWORD PTR [rdi+0x10]
    4627:	mov    rcx,QWORD PTR [rax+0x108]
    462e:	xor    rdx,rdx
    4631:	mov    rsi,r14
    4634:	mov    r12,rdi
    4637:	call   463c <botlish_fn_22+0xb3>
			4638: R_X86_64_PLT32	rt_type_error-0x4
    463c:	jmp    46f4 <botlish_fn_22+0x16b>
    4641:	mov    rsi,r14
    4644:	mov    r12,rdi
    4647:	test   rsi,0x1
    464e:	je     4669 <botlish_fn_22+0xe0>
    4654:	mov    rsi,r14
    4657:	mov    rcx,rsi
    465a:	add    rcx,0x2
    465e:	seto   al
    4661:	test   al,al
    4663:	je     467c <botlish_fn_22+0xf3>
    4669:	mov    edx,0x3
    466e:	mov    rsi,r14
    4671:	mov    rdi,r12
    4674:	call   4679 <botlish_fn_22+0xf0>
			4675: R_X86_64_PLT32	rt_int_add-0x4
    4679:	mov    rcx,rax
    467c:	mov    QWORD PTR [rsp+0x10],rcx
    4681:	mov    edx,0x1
    4686:	mov    rsi,r14
    4689:	test   rsi,0x1
    4690:	jne    46b6 <botlish_fn_22+0x12d>
    4696:	xor    edx,edx
    4698:	mov    rsi,r14
    469b:	test   rsi,0x7
    46a2:	jne    46b6 <botlish_fn_22+0x12d>
    46a8:	mov    rsi,r14
    46ab:	movzx  rdi,BYTE PTR [rsi]
    46af:	cmp    dil,0x1
    46b3:	sete   dl
    46b6:	test   dl,dl
    46b8:	jne    46dd <botlish_fn_22+0x154>
    46be:	mov    r11,QWORD PTR [r12+0x10]
    46c3:	mov    rcx,QWORD PTR [r11+0x110]
    46ca:	xor    rdx,rdx
    46cd:	mov    rsi,r14
    46d0:	mov    rdi,r12
    46d3:	call   46d8 <botlish_fn_22+0x14f>
			46d4: R_X86_64_PLT32	rt_type_error-0x4
    46d8:	jmp    46f4 <botlish_fn_22+0x16b>
    46dd:	mov    rdx,r14
    46e0:	mov    rsi,r15
    46e3:	mov    rdi,r12
    46e6:	call   46eb <botlish_fn_22+0x162>
			46e7: R_X86_64_PLT32	rt_substr-0x4
    46eb:	test   rax,rax
    46ee:	jne    4723 <botlish_fn_22+0x19a>
    46f4:	mov    QWORD PTR [r12+0x20],rbx
    46f9:	mov    QWORD PTR [r12+0x28],r13
    46fe:	xor    rax,rax
    4701:	mov    rbx,QWORD PTR [rsp+0x20]
    4706:	mov    r12,QWORD PTR [rsp+0x28]
    470b:	mov    r13,QWORD PTR [rsp+0x30]
    4710:	mov    r14,QWORD PTR [rsp+0x38]
    4715:	mov    r15,QWORD PTR [rsp+0x40]
    471a:	add    rsp,0x50
    471e:	mov    rsp,rbp
    4721:	pop    rbp
    4722:	ret
    4723:	mov    QWORD PTR [r12+0x20],rbx
    4728:	mov    QWORD PTR [r12+0x28],r13
    472d:	mov    rbx,QWORD PTR [rsp+0x20]
    4732:	mov    r12,QWORD PTR [rsp+0x28]
    4737:	mov    r13,QWORD PTR [rsp+0x30]
    473c:	mov    r14,QWORD PTR [rsp+0x38]
    4741:	mov    r15,QWORD PTR [rsp+0x40]
    4746:	add    rsp,0x50
    474a:	mov    rsp,rbp
    474d:	pop    rbp
    474e:	ret

000000000000474f <botlish_entry_22: char_at<generic>>:
    474f:	push   rbp
    4750:	mov    rbp,rsp
    4753:	mov    rdx,QWORD PTR [rdx]
    4756:	call   475b <botlish_entry_22+0xc>
			4757: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    475b:	mov    rsp,rbp
    475e:	pop    rbp
    475f:	ret

0000000000004760 <botlish_fn_23: char_at<generic>>:
    4760:	push   rbp
    4761:	mov    rbp,rsp
    4764:	sub    rsp,0x60
    4768:	mov    QWORD PTR [rsp+0x30],rbx
    476d:	mov    QWORD PTR [rsp+0x38],r12
    4772:	mov    QWORD PTR [rsp+0x40],r13
    4777:	mov    QWORD PTR [rsp+0x48],r14
    477c:	mov    QWORD PTR [rsp+0x50],r15
    4781:	mov    QWORD PTR [rsp+0x18],rcx
    4786:	mov    rbx,QWORD PTR [rdi+0x20]
    478a:	mov    r12,QWORD PTR [rdi+0x28]
    478e:	lea    rax,[rsp]
    4792:	mov    QWORD PTR [rdi+0x20],rax
    4796:	mov    QWORD PTR [rdi+0x28],0x3
    479e:	mov    QWORD PTR [rsp],rdx
    47a2:	mov    rax,QWORD PTR [rsi+0x20]
    47a6:	mov    rax,QWORD PTR [rax]
    47a9:	mov    QWORD PTR [rsp+0x8],rax
    47ae:	mov    QWORD PTR [rsp+0x20],rax
    47b3:	mov    QWORD PTR [rsp+0x10],0x3
    47bc:	mov    eax,0x1
    47c1:	test   rdx,0x1
    47c8:	je     47d6 <botlish_fn_23+0x76>
    47ce:	mov    r15,rdx
    47d1:	jmp    47f9 <botlish_fn_23+0x99>
    47d6:	xor    eax,eax
    47d8:	test   rdx,0x7
    47df:	je     47ed <botlish_fn_23+0x8d>
    47e5:	mov    r15,rdx
    47e8:	jmp    47f9 <botlish_fn_23+0x99>
    47ed:	movzx  rax,BYTE PTR [rdx]
    47f1:	mov    r15,rdx
    47f4:	cmp    al,0x1
    47f6:	sete   al
    47f9:	test   al,al
    47fb:	jne    481f <botlish_fn_23+0xbf>
    4801:	mov    rax,QWORD PTR [rdi+0x10]
    4805:	mov    rcx,QWORD PTR [rax+0x108]
    480c:	xor    rdx,rdx
    480f:	mov    rsi,r15
    4812:	mov    r13,rdi
    4815:	call   481a <botlish_fn_23+0xba>
			4816: R_X86_64_PLT32	rt_type_error-0x4
    481a:	jmp    48d9 <botlish_fn_23+0x179>
    481f:	mov    rsi,r15
    4822:	mov    r13,rdi
    4825:	test   rsi,0x1
    482c:	jne    483a <botlish_fn_23+0xda>
    4832:	mov    r15,rsi
    4835:	jmp    484f <botlish_fn_23+0xef>
    483a:	mov    rax,rsi
    483d:	add    rax,0x2
    4841:	mov    r15,rsi
    4844:	seto   cl
    4847:	test   cl,cl
    4849:	je     485f <botlish_fn_23+0xff>
    484f:	mov    edx,0x3
    4854:	mov    rsi,r15
    4857:	mov    rdi,r13
    485a:	call   485f <botlish_fn_23+0xff>
			485b: R_X86_64_PLT32	rt_int_add-0x4
    485f:	mov    ecx,0x1
    4864:	mov    rsi,r15
    4867:	test   rsi,0x1
    486e:	jne    4894 <botlish_fn_23+0x134>
    4874:	xor    ecx,ecx
    4876:	mov    rsi,r15
    4879:	test   rsi,0x7
    4880:	jne    4894 <botlish_fn_23+0x134>
    4886:	mov    rsi,r15
    4889:	movzx  rdi,BYTE PTR [rsi]
    488d:	cmp    dil,0x1
    4891:	sete   cl
    4894:	test   cl,cl
    4896:	jne    48ba <botlish_fn_23+0x15a>
    489c:	mov    r11,QWORD PTR [r13+0x10]
    48a0:	mov    rcx,QWORD PTR [r11+0x110]
    48a7:	xor    rdx,rdx
    48aa:	mov    rsi,r15
    48ad:	mov    rdi,r13
    48b0:	call   48b5 <botlish_fn_23+0x155>
			48b1: R_X86_64_PLT32	rt_type_error-0x4
    48b5:	jmp    48d9 <botlish_fn_23+0x179>
    48ba:	mov    r14,rax
    48bd:	mov    rcx,r14
    48c0:	mov    rdx,r15
    48c3:	mov    rsi,QWORD PTR [rsp+0x20]
    48c8:	mov    rdi,r13
    48cb:	call   48d0 <botlish_fn_23+0x170>
			48cc: R_X86_64_PLT32	rt_str_region_check-0x4
    48d0:	test   rax,rax
    48d3:	jne    4906 <botlish_fn_23+0x1a6>
    48d9:	mov    QWORD PTR [r13+0x20],rbx
    48dd:	mov    QWORD PTR [r13+0x28],r12
    48e1:	xor    rax,rax
    48e4:	mov    rbx,QWORD PTR [rsp+0x30]
    48e9:	mov    r12,QWORD PTR [rsp+0x38]
    48ee:	mov    r13,QWORD PTR [rsp+0x40]
    48f3:	mov    r14,QWORD PTR [rsp+0x48]
    48f8:	mov    r15,QWORD PTR [rsp+0x50]
    48fd:	add    rsp,0x60
    4901:	mov    rsp,rbp
    4904:	pop    rbp
    4905:	ret
    4906:	mov    QWORD PTR [r13+0x20],rbx
    490a:	mov    QWORD PTR [r13+0x28],r12
    490e:	mov    rcx,QWORD PTR [rsp+0x18]
    4913:	mov    rsi,r15
    4916:	mov    QWORD PTR [rcx],rsi
    4919:	mov    QWORD PTR [rcx+0x8],r14
    491d:	mov    rax,QWORD PTR [rsp+0x20]
    4922:	mov    rbx,QWORD PTR [rsp+0x30]
    4927:	mov    r12,QWORD PTR [rsp+0x38]
    492c:	mov    r13,QWORD PTR [rsp+0x40]
    4931:	mov    r14,QWORD PTR [rsp+0x48]
    4936:	mov    r15,QWORD PTR [rsp+0x50]
    493b:	add    rsp,0x60
    493f:	mov    rsp,rbp
    4942:	pop    rbp
    4943:	ret

0000000000004944 <botlish_entry_23: char_at<generic>>:
    4944:	push   rbp
    4945:	mov    rbp,rsp
    4948:	ud2

000000000000494a <botlish_fn_24: is_local_char<str>>:
    494a:	push   rbp
    494b:	mov    rbp,rsp
    494e:	sub    rsp,0x10
    4952:	mov    QWORD PTR [rsp],rbx
    4956:	mov    QWORD PTR [rsp+0x8],r12
    495b:	mov    rbx,rsi
    495e:	mov    r12,rdi
    4961:	mov    rsi,rbx
    4964:	mov    rdi,r12
    4967:	call   496c <botlish_fn_24+0x22>
			4968: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    496c:	test   rax,rax
    496f:	jne    498a <botlish_fn_24+0x40>
    4975:	xor    rax,rax
    4978:	mov    rbx,QWORD PTR [rsp]
    497c:	mov    r12,QWORD PTR [rsp+0x8]
    4981:	add    rsp,0x10
    4985:	mov    rsp,rbp
    4988:	pop    rbp
    4989:	ret
    498a:	cmp    rax,0x6
    498e:	je     4a89 <botlish_fn_24+0x13f>
    4994:	mov    rdi,r12
    4997:	mov    rax,QWORD PTR [rdi+0x10]
    499b:	mov    rsi,QWORD PTR [rax+0x118]
    49a2:	mov    edx,0x1
    49a7:	mov    ecx,0x3
    49ac:	mov    r8,rbx
    49af:	call   49b4 <botlish_fn_24+0x6a>
			49b0: R_X86_64_PLT32	rt_str_region_eq-0x4
    49b4:	cmp    rax,0x6
    49b8:	je     4a7f <botlish_fn_24+0x135>
    49be:	mov    rdi,r12
    49c1:	mov    rax,QWORD PTR [rdi+0x10]
    49c5:	mov    rsi,QWORD PTR [rax+0x120]
    49cc:	mov    edx,0x1
    49d1:	mov    ecx,0x3
    49d6:	mov    r8,rbx
    49d9:	call   49de <botlish_fn_24+0x94>
			49da: R_X86_64_PLT32	rt_str_region_eq-0x4
    49de:	cmp    rax,0x6
    49e2:	je     4a75 <botlish_fn_24+0x12b>
    49e8:	mov    rdi,r12
    49eb:	mov    rax,QWORD PTR [rdi+0x10]
    49ef:	mov    rsi,QWORD PTR [rax+0xc0]
    49f6:	mov    edx,0x1
    49fb:	mov    ecx,0x3
    4a00:	mov    r8,rbx
    4a03:	call   4a08 <botlish_fn_24+0xbe>
			4a04: R_X86_64_PLT32	rt_str_region_eq-0x4
    4a08:	cmp    rax,0x6
    4a0c:	je     4a6b <botlish_fn_24+0x121>
    4a12:	mov    rdi,r12
    4a15:	mov    rax,QWORD PTR [rdi+0x10]
    4a19:	mov    rsi,QWORD PTR [rax+0x108]
    4a20:	mov    edx,0x1
    4a25:	mov    ecx,0x3
    4a2a:	mov    r8,rbx
    4a2d:	call   4a32 <botlish_fn_24+0xe8>
			4a2e: R_X86_64_PLT32	rt_str_region_eq-0x4
    4a32:	cmp    rax,0x6
    4a36:	je     4a61 <botlish_fn_24+0x117>
    4a3c:	mov    rdi,r12
    4a3f:	mov    rax,QWORD PTR [rdi+0x10]
    4a43:	mov    rsi,QWORD PTR [rax+0x128]
    4a4a:	mov    edx,0x1
    4a4f:	mov    ecx,0x3
    4a54:	mov    r8,rbx
    4a57:	call   4a5c <botlish_fn_24+0x112>
			4a58: R_X86_64_PLT32	rt_str_region_eq-0x4
    4a5c:	jmp    4a8e <botlish_fn_24+0x144>
    4a61:	mov    eax,0x6
    4a66:	jmp    4a8e <botlish_fn_24+0x144>
    4a6b:	mov    eax,0x6
    4a70:	jmp    4a8e <botlish_fn_24+0x144>
    4a75:	mov    eax,0x6
    4a7a:	jmp    4a8e <botlish_fn_24+0x144>
    4a7f:	mov    eax,0x6
    4a84:	jmp    4a8e <botlish_fn_24+0x144>
    4a89:	mov    eax,0x6
    4a8e:	mov    rbx,QWORD PTR [rsp]
    4a92:	mov    r12,QWORD PTR [rsp+0x8]
    4a97:	add    rsp,0x10
    4a9b:	mov    rsp,rbp
    4a9e:	pop    rbp
    4a9f:	ret

0000000000004aa0 <botlish_entry_24: is_local_char<str>>:
    4aa0:	push   rbp
    4aa1:	mov    rbp,rsp
    4aa4:	mov    rsi,QWORD PTR [rdx]
    4aa7:	call   4aac <botlish_entry_24+0xc>
			4aa8: R_X86_64_PLT32	botlish_fn_24-0x4 ; is_local_char<str>
    4aac:	mov    rsp,rbp
    4aaf:	pop    rbp
    4ab0:	ret

0000000000004ab1 <botlish_fn_25: is_label_char<str>>:
    4ab1:	push   rbp
    4ab2:	mov    rbp,rsp
    4ab5:	sub    rsp,0x10
    4ab9:	mov    QWORD PTR [rsp],r13
    4abd:	mov    QWORD PTR [rsp+0x8],r15
    4ac2:	mov    r13,rsi
    4ac5:	mov    r15,rdi
    4ac8:	mov    rsi,r13
    4acb:	mov    rdi,r15
    4ace:	call   4ad3 <botlish_fn_25+0x22>
			4acf: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    4ad3:	test   rax,rax
    4ad6:	jne    4af1 <botlish_fn_25+0x40>
    4adc:	xor    rax,rax
    4adf:	mov    r13,QWORD PTR [rsp]
    4ae3:	mov    r15,QWORD PTR [rsp+0x8]
    4ae8:	add    rsp,0x10
    4aec:	mov    rsp,rbp
    4aef:	pop    rbp
    4af0:	ret
    4af1:	cmp    rax,0x6
    4af5:	je     4b20 <botlish_fn_25+0x6f>
    4afb:	mov    rdi,r15
    4afe:	mov    rax,QWORD PTR [rdi+0x10]
    4b02:	mov    rsi,QWORD PTR [rax+0x128]
    4b09:	mov    edx,0x1
    4b0e:	mov    ecx,0x3
    4b13:	mov    r8,r13
    4b16:	call   4b1b <botlish_fn_25+0x6a>
			4b17: R_X86_64_PLT32	rt_str_region_eq-0x4
    4b1b:	jmp    4b25 <botlish_fn_25+0x74>
    4b20:	mov    eax,0x6
    4b25:	mov    r13,QWORD PTR [rsp]
    4b29:	mov    r15,QWORD PTR [rsp+0x8]
    4b2e:	add    rsp,0x10
    4b32:	mov    rsp,rbp
    4b35:	pop    rbp
    4b36:	ret

0000000000004b37 <botlish_entry_25: is_label_char<str>>:
    4b37:	push   rbp
    4b38:	mov    rbp,rsp
    4b3b:	mov    rsi,QWORD PTR [rdx]
    4b3e:	call   4b43 <botlish_entry_25+0xc>
			4b3f: R_X86_64_PLT32	botlish_fn_25-0x4 ; is_label_char<str>
    4b43:	mov    rsp,rbp
    4b46:	pop    rbp
    4b47:	ret

0000000000004b48 <botlish_fn_26: scan_local<generic>>:
    4b48:	push   rbp
    4b49:	mov    rbp,rsp
    4b4c:	sub    rsp,0x20
    4b50:	mov    QWORD PTR [rsp],rbx
    4b54:	mov    QWORD PTR [rsp+0x8],r12
    4b59:	mov    QWORD PTR [rsp+0x10],r13
    4b5e:	mov    QWORD PTR [rsp+0x18],r14
    4b63:	mov    r12,QWORD PTR [rdi]
    4b66:	mov    rax,QWORD PTR [rdi+0x8]
    4b6a:	lea    rcx,[r12+0x18]
    4b6f:	cmp    rcx,rax
    4b72:	ja     4d46 <botlish_fn_26+0x1fe>
    4b78:	lea    rax,[r12+0x18]
    4b7d:	mov    QWORD PTR [rdi],rax
    4b80:	mov    r13,rdi
    4b83:	mov    QWORD PTR [r12+0x10],0x0
    4b8c:	mov    QWORD PTR [r12],rdx
    4b90:	mov    rbx,rsi
    4b93:	mov    rsi,rdx
    4b96:	mov    rax,QWORD PTR [rbx+0x20]
    4b9a:	mov    rdx,QWORD PTR [rax]
    4b9d:	mov    ecx,0x1
    4ba2:	test   rsi,0x1
    4ba9:	jne    4bc7 <botlish_fn_26+0x7f>
    4baf:	xor    ecx,ecx
    4bb1:	test   rsi,0x7
    4bb8:	jne    4bc7 <botlish_fn_26+0x7f>
    4bbe:	movzx  rax,BYTE PTR [rsi]
    4bc2:	cmp    al,0x1
    4bc4:	sete   cl
    4bc7:	test   cl,cl
    4bc9:	jne    4bed <botlish_fn_26+0xa5>
    4bcf:	mov    rdi,r13
    4bd2:	mov    rax,QWORD PTR [rdi+0x10]
    4bd6:	mov    rcx,QWORD PTR [rax+0xb8]
    4bdd:	xor    rdx,rdx
    4be0:	call   4be5 <botlish_fn_26+0x9d>
			4be1: R_X86_64_PLT32	rt_type_error-0x4
    4be5:	mov    rdi,r13
    4be8:	jmp    4c84 <botlish_fn_26+0x13c>
    4bed:	mov    rax,rsi
    4bf0:	and    rax,rdx
    4bf3:	mov    r14,rsi
    4bf6:	test   rax,0x1
    4bfc:	jne    4c22 <botlish_fn_26+0xda>
    4c02:	mov    rsi,r14
    4c05:	mov    rdi,r13
    4c08:	call   4c0d <botlish_fn_26+0xc5>
			4c09: R_X86_64_PLT32	rt_int_cmp-0x4
    4c0d:	mov    ecx,0x2
    4c12:	test   rax,rax
    4c15:	cmovge rcx,QWORD PTR [rip+0x153]        # 4d70 <botlish_fn_26+0x228>
    4c1d:	jmp    4c35 <botlish_fn_26+0xed>
    4c22:	mov    ecx,0x2
    4c27:	mov    rsi,r14
    4c2a:	cmp    rsi,rdx
    4c2d:	cmovge rcx,QWORD PTR [rip+0x13b]        # 4d70 <botlish_fn_26+0x228>
    4c35:	cmp    rcx,0x6
    4c39:	je     4d1e <botlish_fn_26+0x1d6>
    4c3f:	mov    rsi,QWORD PTR [rbx+0x20]
    4c43:	mov    rsi,QWORD PTR [rsi+0x8]
    4c47:	mov    QWORD PTR [r12+0x8],rsi
    4c4c:	mov    rdx,r14
    4c4f:	mov    rdi,r13
    4c52:	call   4c57 <botlish_fn_26+0x10f>
			4c53: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    4c57:	test   rax,rax
    4c5a:	jne    4c68 <botlish_fn_26+0x120>
    4c60:	mov    rdi,r13
    4c63:	jmp    4c84 <botlish_fn_26+0x13c>
    4c68:	mov    QWORD PTR [r12+0x8],rax
    4c6d:	mov    rsi,rax
    4c70:	mov    rdi,r13
    4c73:	call   4c78 <botlish_fn_26+0x130>
			4c74: R_X86_64_PLT32	botlish_fn_24-0x4 ; is_local_char<str>
    4c78:	test   rax,rax
    4c7b:	jne    4ca9 <botlish_fn_26+0x161>
    4c81:	mov    rdi,r13
    4c84:	mov    rdi,r13
    4c87:	mov    QWORD PTR [rdi],r12
    4c8a:	xor    rax,rax
    4c8d:	mov    rbx,QWORD PTR [rsp]
    4c91:	mov    r12,QWORD PTR [rsp+0x8]
    4c96:	mov    r13,QWORD PTR [rsp+0x10]
    4c9b:	mov    r14,QWORD PTR [rsp+0x18]
    4ca0:	add    rsp,0x20
    4ca4:	mov    rsp,rbp
    4ca7:	pop    rbp
    4ca8:	ret
    4ca9:	cmp    rax,0x6
    4cad:	je     4cbe <botlish_fn_26+0x176>
    4cb3:	mov    rax,r14
    4cb6:	mov    rdi,r13
    4cb9:	jmp    4d24 <botlish_fn_26+0x1dc>
    4cbe:	mov    QWORD PTR [r12+0x8],rbx
    4cc3:	mov    QWORD PTR [r12+0x10],0x3
    4ccc:	mov    rsi,r14
    4ccf:	test   rsi,0x1
    4cd6:	je     4cfc <botlish_fn_26+0x1b4>
    4cdc:	mov    rsi,r14
    4cdf:	mov    rcx,rsi
    4ce2:	add    rcx,0x2
    4ce6:	seto   al
    4ce9:	test   al,al
    4ceb:	jne    4cfc <botlish_fn_26+0x1b4>
    4cf1:	mov    rsi,rcx
    4cf4:	mov    r14,rcx
    4cf7:	jmp    4d12 <botlish_fn_26+0x1ca>
    4cfc:	mov    edx,0x3
    4d01:	mov    rsi,r14
    4d04:	mov    rdi,r13
    4d07:	call   4d0c <botlish_fn_26+0x1c4>
			4d08: R_X86_64_PLT32	rt_int_add-0x4
    4d0c:	mov    rsi,rax
    4d0f:	mov    r14,rax
    4d12:	mov    QWORD PTR [r12],rsi
    4d16:	mov    rsi,r14
    4d19:	jmp    4b96 <botlish_fn_26+0x4e>
    4d1e:	mov    rax,r14
    4d21:	mov    rdi,r13
    4d24:	mov    rdi,r13
    4d27:	mov    QWORD PTR [rdi],r12
    4d2a:	mov    rbx,QWORD PTR [rsp]
    4d2e:	mov    r12,QWORD PTR [rsp+0x8]
    4d33:	mov    r13,QWORD PTR [rsp+0x10]
    4d38:	mov    r14,QWORD PTR [rsp+0x18]
    4d3d:	add    rsp,0x20
    4d41:	mov    rsp,rbp
    4d44:	pop    rbp
    4d45:	ret
    4d46:	mov    r13,rdi
    4d49:	call   4d4e <botlish_fn_26+0x206>
			4d4a: R_X86_64_PLT32	rt_stack_overflow-0x4
    4d4e:	xor    rax,rax
    4d51:	mov    rbx,QWORD PTR [rsp]
    4d55:	mov    r12,QWORD PTR [rsp+0x8]
    4d5a:	mov    r13,QWORD PTR [rsp+0x10]
    4d5f:	mov    r14,QWORD PTR [rsp+0x18]
    4d64:	add    rsp,0x20
    4d68:	mov    rsp,rbp
    4d6b:	pop    rbp
    4d6c:	ret
    4d6d:	add    BYTE PTR [rax],al
    4d6f:	add    BYTE PTR [rsi],al
    4d71:	add    BYTE PTR [rax],al
    4d73:	add    BYTE PTR [rax],al
    4d75:	add    BYTE PTR [rax],al
	...

0000000000004d78 <botlish_entry_26: scan_local<generic>>:
    4d78:	push   rbp
    4d79:	mov    rbp,rsp
    4d7c:	mov    rdx,QWORD PTR [rdx]
    4d7f:	call   4d84 <botlish_entry_26+0xc>
			4d80: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    4d84:	mov    rsp,rbp
    4d87:	pop    rbp
    4d88:	ret
    4d89:	add    BYTE PTR [rax],al
    4d8b:	add    BYTE PTR [rax],al
    4d8d:	add    BYTE PTR [rax],al
	...

0000000000004d90 <botlish_fn_27: scan_label<generic>>:
    4d90:	push   rbp
    4d91:	mov    rbp,rsp
    4d94:	sub    rsp,0x20
    4d98:	mov    QWORD PTR [rsp],rbx
    4d9c:	mov    QWORD PTR [rsp+0x8],r12
    4da1:	mov    QWORD PTR [rsp+0x10],r13
    4da6:	mov    QWORD PTR [rsp+0x18],r14
    4dab:	mov    r12,QWORD PTR [rdi]
    4dae:	mov    rax,QWORD PTR [rdi+0x8]
    4db2:	lea    rcx,[r12+0x18]
    4db7:	cmp    rcx,rax
    4dba:	ja     4f8e <botlish_fn_27+0x1fe>
    4dc0:	lea    rax,[r12+0x18]
    4dc5:	mov    QWORD PTR [rdi],rax
    4dc8:	mov    r13,rdi
    4dcb:	mov    QWORD PTR [r12+0x10],0x0
    4dd4:	mov    QWORD PTR [r12],rdx
    4dd8:	mov    rbx,rsi
    4ddb:	mov    rsi,rdx
    4dde:	mov    rax,QWORD PTR [rbx+0x20]
    4de2:	mov    rdx,QWORD PTR [rax]
    4de5:	mov    ecx,0x1
    4dea:	test   rsi,0x1
    4df1:	jne    4e0f <botlish_fn_27+0x7f>
    4df7:	xor    ecx,ecx
    4df9:	test   rsi,0x7
    4e00:	jne    4e0f <botlish_fn_27+0x7f>
    4e06:	movzx  rax,BYTE PTR [rsi]
    4e0a:	cmp    al,0x1
    4e0c:	sete   cl
    4e0f:	test   cl,cl
    4e11:	jne    4e35 <botlish_fn_27+0xa5>
    4e17:	mov    rdi,r13
    4e1a:	mov    rax,QWORD PTR [rdi+0x10]
    4e1e:	mov    rcx,QWORD PTR [rax+0xb8]
    4e25:	xor    rdx,rdx
    4e28:	call   4e2d <botlish_fn_27+0x9d>
			4e29: R_X86_64_PLT32	rt_type_error-0x4
    4e2d:	mov    rdi,r13
    4e30:	jmp    4ecc <botlish_fn_27+0x13c>
    4e35:	mov    rax,rsi
    4e38:	and    rax,rdx
    4e3b:	mov    r14,rsi
    4e3e:	test   rax,0x1
    4e44:	jne    4e6a <botlish_fn_27+0xda>
    4e4a:	mov    rsi,r14
    4e4d:	mov    rdi,r13
    4e50:	call   4e55 <botlish_fn_27+0xc5>
			4e51: R_X86_64_PLT32	rt_int_cmp-0x4
    4e55:	mov    ecx,0x2
    4e5a:	test   rax,rax
    4e5d:	cmovge rcx,QWORD PTR [rip+0x153]        # 4fb8 <botlish_fn_27+0x228>
    4e65:	jmp    4e7d <botlish_fn_27+0xed>
    4e6a:	mov    ecx,0x2
    4e6f:	mov    rsi,r14
    4e72:	cmp    rsi,rdx
    4e75:	cmovge rcx,QWORD PTR [rip+0x13b]        # 4fb8 <botlish_fn_27+0x228>
    4e7d:	cmp    rcx,0x6
    4e81:	je     4f66 <botlish_fn_27+0x1d6>
    4e87:	mov    rsi,QWORD PTR [rbx+0x20]
    4e8b:	mov    rsi,QWORD PTR [rsi+0x8]
    4e8f:	mov    QWORD PTR [r12+0x8],rsi
    4e94:	mov    rdx,r14
    4e97:	mov    rdi,r13
    4e9a:	call   4e9f <botlish_fn_27+0x10f>
			4e9b: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    4e9f:	test   rax,rax
    4ea2:	jne    4eb0 <botlish_fn_27+0x120>
    4ea8:	mov    rdi,r13
    4eab:	jmp    4ecc <botlish_fn_27+0x13c>
    4eb0:	mov    QWORD PTR [r12+0x8],rax
    4eb5:	mov    rsi,rax
    4eb8:	mov    rdi,r13
    4ebb:	call   4ec0 <botlish_fn_27+0x130>
			4ebc: R_X86_64_PLT32	botlish_fn_25-0x4 ; is_label_char<str>
    4ec0:	test   rax,rax
    4ec3:	jne    4ef1 <botlish_fn_27+0x161>
    4ec9:	mov    rdi,r13
    4ecc:	mov    rdi,r13
    4ecf:	mov    QWORD PTR [rdi],r12
    4ed2:	xor    rax,rax
    4ed5:	mov    rbx,QWORD PTR [rsp]
    4ed9:	mov    r12,QWORD PTR [rsp+0x8]
    4ede:	mov    r13,QWORD PTR [rsp+0x10]
    4ee3:	mov    r14,QWORD PTR [rsp+0x18]
    4ee8:	add    rsp,0x20
    4eec:	mov    rsp,rbp
    4eef:	pop    rbp
    4ef0:	ret
    4ef1:	cmp    rax,0x6
    4ef5:	je     4f06 <botlish_fn_27+0x176>
    4efb:	mov    rax,r14
    4efe:	mov    rdi,r13
    4f01:	jmp    4f6c <botlish_fn_27+0x1dc>
    4f06:	mov    QWORD PTR [r12+0x8],rbx
    4f0b:	mov    QWORD PTR [r12+0x10],0x3
    4f14:	mov    rsi,r14
    4f17:	test   rsi,0x1
    4f1e:	je     4f44 <botlish_fn_27+0x1b4>
    4f24:	mov    rsi,r14
    4f27:	mov    rcx,rsi
    4f2a:	add    rcx,0x2
    4f2e:	seto   al
    4f31:	test   al,al
    4f33:	jne    4f44 <botlish_fn_27+0x1b4>
    4f39:	mov    rsi,rcx
    4f3c:	mov    r14,rcx
    4f3f:	jmp    4f5a <botlish_fn_27+0x1ca>
    4f44:	mov    edx,0x3
    4f49:	mov    rsi,r14
    4f4c:	mov    rdi,r13
    4f4f:	call   4f54 <botlish_fn_27+0x1c4>
			4f50: R_X86_64_PLT32	rt_int_add-0x4
    4f54:	mov    rsi,rax
    4f57:	mov    r14,rax
    4f5a:	mov    QWORD PTR [r12],rsi
    4f5e:	mov    rsi,r14
    4f61:	jmp    4dde <botlish_fn_27+0x4e>
    4f66:	mov    rax,r14
    4f69:	mov    rdi,r13
    4f6c:	mov    rdi,r13
    4f6f:	mov    QWORD PTR [rdi],r12
    4f72:	mov    rbx,QWORD PTR [rsp]
    4f76:	mov    r12,QWORD PTR [rsp+0x8]
    4f7b:	mov    r13,QWORD PTR [rsp+0x10]
    4f80:	mov    r14,QWORD PTR [rsp+0x18]
    4f85:	add    rsp,0x20
    4f89:	mov    rsp,rbp
    4f8c:	pop    rbp
    4f8d:	ret
    4f8e:	mov    r13,rdi
    4f91:	call   4f96 <botlish_fn_27+0x206>
			4f92: R_X86_64_PLT32	rt_stack_overflow-0x4
    4f96:	xor    rax,rax
    4f99:	mov    rbx,QWORD PTR [rsp]
    4f9d:	mov    r12,QWORD PTR [rsp+0x8]
    4fa2:	mov    r13,QWORD PTR [rsp+0x10]
    4fa7:	mov    r14,QWORD PTR [rsp+0x18]
    4fac:	add    rsp,0x20
    4fb0:	mov    rsp,rbp
    4fb3:	pop    rbp
    4fb4:	ret
    4fb5:	add    BYTE PTR [rax],al
    4fb7:	add    BYTE PTR [rsi],al
    4fb9:	add    BYTE PTR [rax],al
    4fbb:	add    BYTE PTR [rax],al
    4fbd:	add    BYTE PTR [rax],al
	...

0000000000004fc0 <botlish_entry_27: scan_label<generic>>:
    4fc0:	push   rbp
    4fc1:	mov    rbp,rsp
    4fc4:	mov    rdx,QWORD PTR [rdx]
    4fc7:	call   4fcc <botlish_entry_27+0xc>
			4fc8: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_label<generic>
    4fcc:	mov    rsp,rbp
    4fcf:	pop    rbp
    4fd0:	ret
    4fd1:	add    BYTE PTR [rax],al
    4fd3:	add    BYTE PTR [rax],al
    4fd5:	add    BYTE PTR [rax],al
	...

0000000000004fd8 <botlish_fn_28: scan_alpha<generic>>:
    4fd8:	push   rbp
    4fd9:	mov    rbp,rsp
    4fdc:	sub    rsp,0x20
    4fe0:	mov    QWORD PTR [rsp],rbx
    4fe4:	mov    QWORD PTR [rsp+0x8],r12
    4fe9:	mov    QWORD PTR [rsp+0x10],r13
    4fee:	mov    QWORD PTR [rsp+0x18],r14
    4ff3:	mov    r12,QWORD PTR [rdi]
    4ff6:	mov    rax,QWORD PTR [rdi+0x8]
    4ffa:	lea    rcx,[r12+0x18]
    4fff:	cmp    rcx,rax
    5002:	ja     51d1 <botlish_fn_28+0x1f9>
    5008:	lea    rax,[r12+0x18]
    500d:	mov    QWORD PTR [rdi],rax
    5010:	mov    r13,rdi
    5013:	mov    QWORD PTR [r12+0x10],0x0
    501c:	mov    QWORD PTR [r12],rdx
    5020:	mov    rbx,rsi
    5023:	mov    rsi,rdx
    5026:	mov    rax,QWORD PTR [rbx+0x20]
    502a:	mov    rdx,QWORD PTR [rax]
    502d:	mov    ecx,0x1
    5032:	test   rsi,0x1
    5039:	jne    5057 <botlish_fn_28+0x7f>
    503f:	xor    ecx,ecx
    5041:	test   rsi,0x7
    5048:	jne    5057 <botlish_fn_28+0x7f>
    504e:	movzx  rax,BYTE PTR [rsi]
    5052:	cmp    al,0x1
    5054:	sete   cl
    5057:	test   cl,cl
    5059:	jne    507d <botlish_fn_28+0xa5>
    505f:	mov    rdi,r13
    5062:	mov    rax,QWORD PTR [rdi+0x10]
    5066:	mov    rcx,QWORD PTR [rax+0xb8]
    506d:	xor    rdx,rdx
    5070:	call   5075 <botlish_fn_28+0x9d>
			5071: R_X86_64_PLT32	rt_type_error-0x4
    5075:	mov    rdi,r13
    5078:	jmp    510f <botlish_fn_28+0x137>
    507d:	mov    rax,rsi
    5080:	and    rax,rdx
    5083:	mov    r14,rsi
    5086:	test   rax,0x1
    508c:	jne    50b2 <botlish_fn_28+0xda>
    5092:	mov    rsi,r14
    5095:	mov    rdi,r13
    5098:	call   509d <botlish_fn_28+0xc5>
			5099: R_X86_64_PLT32	rt_int_cmp-0x4
    509d:	mov    ecx,0x2
    50a2:	test   rax,rax
    50a5:	cmovge rcx,QWORD PTR [rip+0x14b]        # 51f8 <botlish_fn_28+0x220>
    50ad:	jmp    50c5 <botlish_fn_28+0xed>
    50b2:	mov    ecx,0x2
    50b7:	mov    rsi,r14
    50ba:	cmp    rsi,rdx
    50bd:	cmovge rcx,QWORD PTR [rip+0x133]        # 51f8 <botlish_fn_28+0x220>
    50c5:	cmp    rcx,0x6
    50c9:	je     51a9 <botlish_fn_28+0x1d1>
    50cf:	mov    rsi,QWORD PTR [rbx+0x20]
    50d3:	mov    rsi,QWORD PTR [rsi+0x8]
    50d7:	mov    QWORD PTR [r12+0x8],rsi
    50dc:	mov    rdx,r14
    50df:	mov    rdi,r13
    50e2:	call   50e7 <botlish_fn_28+0x10f>
			50e3: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    50e7:	test   rax,rax
    50ea:	mov    rsi,rax
    50ed:	jne    50fb <botlish_fn_28+0x123>
    50f3:	mov    rdi,r13
    50f6:	jmp    510f <botlish_fn_28+0x137>
    50fb:	mov    rdi,r13
    50fe:	call   5103 <botlish_fn_28+0x12b>
			50ff: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    5103:	test   rax,rax
    5106:	jne    5134 <botlish_fn_28+0x15c>
    510c:	mov    rdi,r13
    510f:	mov    rdi,r13
    5112:	mov    QWORD PTR [rdi],r12
    5115:	xor    rax,rax
    5118:	mov    rbx,QWORD PTR [rsp]
    511c:	mov    r12,QWORD PTR [rsp+0x8]
    5121:	mov    r13,QWORD PTR [rsp+0x10]
    5126:	mov    r14,QWORD PTR [rsp+0x18]
    512b:	add    rsp,0x20
    512f:	mov    rsp,rbp
    5132:	pop    rbp
    5133:	ret
    5134:	cmp    rax,0x6
    5138:	je     5149 <botlish_fn_28+0x171>
    513e:	mov    rax,r14
    5141:	mov    rdi,r13
    5144:	jmp    51af <botlish_fn_28+0x1d7>
    5149:	mov    QWORD PTR [r12+0x8],rbx
    514e:	mov    QWORD PTR [r12+0x10],0x3
    5157:	mov    rsi,r14
    515a:	test   rsi,0x1
    5161:	je     5187 <botlish_fn_28+0x1af>
    5167:	mov    rsi,r14
    516a:	mov    rcx,rsi
    516d:	add    rcx,0x2
    5171:	seto   al
    5174:	test   al,al
    5176:	jne    5187 <botlish_fn_28+0x1af>
    517c:	mov    rsi,rcx
    517f:	mov    r14,rcx
    5182:	jmp    519d <botlish_fn_28+0x1c5>
    5187:	mov    edx,0x3
    518c:	mov    rsi,r14
    518f:	mov    rdi,r13
    5192:	call   5197 <botlish_fn_28+0x1bf>
			5193: R_X86_64_PLT32	rt_int_add-0x4
    5197:	mov    rsi,rax
    519a:	mov    r14,rax
    519d:	mov    QWORD PTR [r12],rsi
    51a1:	mov    rsi,r14
    51a4:	jmp    5026 <botlish_fn_28+0x4e>
    51a9:	mov    rax,r14
    51ac:	mov    rdi,r13
    51af:	mov    rdi,r13
    51b2:	mov    QWORD PTR [rdi],r12
    51b5:	mov    rbx,QWORD PTR [rsp]
    51b9:	mov    r12,QWORD PTR [rsp+0x8]
    51be:	mov    r13,QWORD PTR [rsp+0x10]
    51c3:	mov    r14,QWORD PTR [rsp+0x18]
    51c8:	add    rsp,0x20
    51cc:	mov    rsp,rbp
    51cf:	pop    rbp
    51d0:	ret
    51d1:	mov    r13,rdi
    51d4:	call   51d9 <botlish_fn_28+0x201>
			51d5: R_X86_64_PLT32	rt_stack_overflow-0x4
    51d9:	xor    rax,rax
    51dc:	mov    rbx,QWORD PTR [rsp]
    51e0:	mov    r12,QWORD PTR [rsp+0x8]
    51e5:	mov    r13,QWORD PTR [rsp+0x10]
    51ea:	mov    r14,QWORD PTR [rsp+0x18]
    51ef:	add    rsp,0x20
    51f3:	mov    rsp,rbp
    51f6:	pop    rbp
    51f7:	ret
    51f8:	(bad)
    51f9:	add    BYTE PTR [rax],al
    51fb:	add    BYTE PTR [rax],al
    51fd:	add    BYTE PTR [rax],al
	...

0000000000005200 <botlish_entry_28: scan_alpha<generic>>:
    5200:	push   rbp
    5201:	mov    rbp,rsp
    5204:	mov    rdx,QWORD PTR [rdx]
    5207:	call   520c <botlish_entry_28+0xc>
			5208: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_alpha<generic>
    520c:	mov    rsp,rbp
    520f:	pop    rbp
    5210:	ret
    5211:	add    BYTE PTR [rax],al
    5213:	add    BYTE PTR [rax],al
    5215:	add    BYTE PTR [rax],al
	...

0000000000005218 <botlish_fn_29: tld_ok<generic>>:
    5218:	push   rbp
    5219:	mov    rbp,rsp
    521c:	sub    rsp,0x30
    5220:	mov    QWORD PTR [rsp],rbx
    5224:	mov    QWORD PTR [rsp+0x8],r12
    5229:	mov    QWORD PTR [rsp+0x10],r13
    522e:	mov    QWORD PTR [rsp+0x18],r14
    5233:	mov    QWORD PTR [rsp+0x20],r15
    5238:	mov    rbx,QWORD PTR [rdi]
    523b:	mov    rax,QWORD PTR [rdi+0x8]
    523f:	lea    rcx,[rbx+0x10]
    5243:	cmp    rcx,rax
    5246:	ja     544b <botlish_fn_29+0x233>
    524c:	lea    rax,[rbx+0x10]
    5250:	mov    QWORD PTR [rdi],rax
    5253:	mov    r13,rdi
    5256:	mov    QWORD PTR [rbx],rdx
    5259:	mov    r8,rdx
    525c:	mov    rax,QWORD PTR [rsi+0x20]
    5260:	mov    r15,rsi
    5263:	mov    rsi,QWORD PTR [rax]
    5266:	mov    QWORD PTR [rbx+0x8],rsi
    526a:	mov    r12,r8
    526d:	mov    rdx,r12
    5270:	mov    rdi,r13
    5273:	call   5278 <botlish_fn_29+0x60>
			5274: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_alpha<generic>
    5278:	mov    rcx,rax
    527b:	mov    r14,rax
    527e:	test   rax,rcx
    5281:	jne    528f <botlish_fn_29+0x77>
    5287:	mov    rdi,r13
    528a:	jmp    5367 <botlish_fn_29+0x14f>
    528f:	mov    rax,r14
    5292:	mov    QWORD PTR [rbx+0x8],rax
    5296:	mov    rsi,r15
    5299:	mov    rax,QWORD PTR [rsi+0x20]
    529d:	mov    rdx,QWORD PTR [rax+0x8]
    52a1:	mov    rax,r14
    52a4:	and    rax,rdx
    52a7:	test   rax,0x1
    52ad:	jne    52d6 <botlish_fn_29+0xbe>
    52b3:	mov    rsi,r14
    52b6:	mov    rdi,r13
    52b9:	call   52be <botlish_fn_29+0xa6>
			52ba: R_X86_64_PLT32	rt_int_cmp-0x4
    52be:	mov    ecx,0x2
    52c3:	test   rax,rax
    52c6:	cmove  rcx,QWORD PTR [rip+0x1aa]        # 5478 <botlish_fn_29+0x260>
    52ce:	mov    rax,r14
    52d1:	jmp    52e9 <botlish_fn_29+0xd1>
    52d6:	mov    ecx,0x2
    52db:	mov    rax,r14
    52de:	cmp    rax,rdx
    52e1:	cmove  rcx,QWORD PTR [rip+0x18f]        # 5478 <botlish_fn_29+0x260>
    52e9:	cmp    rcx,0x6
    52ed:	je     5303 <botlish_fn_29+0xeb>
    52f3:	mov    ecx,0x2
    52f8:	mov    rax,rcx
    52fb:	mov    rdi,r13
    52fe:	jmp    5424 <botlish_fn_29+0x20c>
    5303:	mov    ecx,0x1
    5308:	test   r12,0x1
    530f:	je     531d <botlish_fn_29+0x105>
    5315:	mov    r8,r12
    5318:	jmp    5343 <botlish_fn_29+0x12b>
    531d:	xor    ecx,ecx
    531f:	test   r12,0x7
    5326:	je     5334 <botlish_fn_29+0x11c>
    532c:	mov    r8,r12
    532f:	jmp    5343 <botlish_fn_29+0x12b>
    5334:	movzx  rcx,BYTE PTR [r12]
    5339:	mov    r8,r12
    533c:	rex cmp cl,0x1
    5340:	sete   cl
    5343:	test   cl,cl
    5345:	jne    5391 <botlish_fn_29+0x179>
    534b:	mov    rdi,r13
    534e:	mov    rax,QWORD PTR [rdi+0x10]
    5352:	mov    rcx,QWORD PTR [rax+0x128]
    5359:	xor    rdx,rdx
    535c:	mov    rsi,r8
    535f:	call   5364 <botlish_fn_29+0x14c>
			5360: R_X86_64_PLT32	rt_type_error-0x4
    5364:	mov    rdi,r13
    5367:	mov    rdi,r13
    536a:	mov    QWORD PTR [rdi],rbx
    536d:	xor    rax,rax
    5370:	mov    rbx,QWORD PTR [rsp]
    5374:	mov    r12,QWORD PTR [rsp+0x8]
    5379:	mov    r13,QWORD PTR [rsp+0x10]
    537e:	mov    r14,QWORD PTR [rsp+0x18]
    5383:	mov    r15,QWORD PTR [rsp+0x20]
    5388:	add    rsp,0x30
    538c:	mov    rsp,rbp
    538f:	pop    rbp
    5390:	ret
    5391:	mov    r12,r8
    5394:	mov    rcx,rax
    5397:	and    rcx,r12
    539a:	test   rcx,0x1
    53a1:	jne    53b2 <botlish_fn_29+0x19a>
    53a7:	mov    rdx,r8
    53aa:	mov    rsi,rax
    53ad:	jmp    53d3 <botlish_fn_29+0x1bb>
    53b2:	mov    r12,r8
    53b5:	mov    rcx,rax
    53b8:	sub    rcx,r12
    53bb:	mov    r14,rax
    53be:	seto   al
    53c1:	lea    rsi,[rcx+0x1]
    53c5:	test   al,al
    53c7:	je     53de <botlish_fn_29+0x1c6>
    53cd:	mov    rdx,r8
    53d0:	mov    rsi,r14
    53d3:	mov    rdi,r13
    53d6:	call   53db <botlish_fn_29+0x1c3>
			53d7: R_X86_64_PLT32	rt_int_sub-0x4
    53db:	mov    rsi,rax
    53de:	test   rsi,0x1
    53e5:	jne    5410 <botlish_fn_29+0x1f8>
    53eb:	mov    edx,0x5
    53f0:	mov    rdi,r13
    53f3:	call   53f8 <botlish_fn_29+0x1e0>
			53f4: R_X86_64_PLT32	rt_int_cmp-0x4
    53f8:	mov    ecx,0x2
    53fd:	test   rax,rax
    5400:	mov    rax,rcx
    5403:	cmovge rax,QWORD PTR [rip+0x6d]        # 5478 <botlish_fn_29+0x260>
    540b:	jmp    5421 <botlish_fn_29+0x209>
    5410:	mov    eax,0x2
    5415:	cmp    rsi,0x5
    5419:	cmovge rax,QWORD PTR [rip+0x57]        # 5478 <botlish_fn_29+0x260>
    5421:	mov    rdi,r13
    5424:	mov    rdi,r13
    5427:	mov    QWORD PTR [rdi],rbx
    542a:	mov    rbx,QWORD PTR [rsp]
    542e:	mov    r12,QWORD PTR [rsp+0x8]
    5433:	mov    r13,QWORD PTR [rsp+0x10]
    5438:	mov    r14,QWORD PTR [rsp+0x18]
    543d:	mov    r15,QWORD PTR [rsp+0x20]
    5442:	add    rsp,0x30
    5446:	mov    rsp,rbp
    5449:	pop    rbp
    544a:	ret
    544b:	mov    r13,rdi
    544e:	call   5453 <botlish_fn_29+0x23b>
			544f: R_X86_64_PLT32	rt_stack_overflow-0x4
    5453:	xor    rax,rax
    5456:	mov    rbx,QWORD PTR [rsp]
    545a:	mov    r12,QWORD PTR [rsp+0x8]
    545f:	mov    r13,QWORD PTR [rsp+0x10]
    5464:	mov    r14,QWORD PTR [rsp+0x18]
    5469:	mov    r15,QWORD PTR [rsp+0x20]
    546e:	add    rsp,0x30
    5472:	mov    rsp,rbp
    5475:	pop    rbp
    5476:	ret
    5477:	add    BYTE PTR [rsi],al
    5479:	add    BYTE PTR [rax],al
    547b:	add    BYTE PTR [rax],al
    547d:	add    BYTE PTR [rax],al
	...

0000000000005480 <botlish_entry_29: tld_ok<generic>>:
    5480:	push   rbp
    5481:	mov    rbp,rsp
    5484:	mov    rdx,QWORD PTR [rdx]
    5487:	call   548c <botlish_entry_29+0xc>
			5488: R_X86_64_PLT32	botlish_fn_29-0x4 ; tld_ok<generic>
    548c:	mov    rsp,rbp
    548f:	pop    rbp
    5490:	ret
    5491:	add    BYTE PTR [rax],al
    5493:	add    BYTE PTR [rax],al
    5495:	add    BYTE PTR [rax],al
	...

0000000000005498 <botlish_fn_30: domain_loop<generic>>:
    5498:	push   rbp
    5499:	mov    rbp,rsp
    549c:	sub    rsp,0x50
    54a0:	mov    QWORD PTR [rsp+0x20],rbx
    54a5:	mov    QWORD PTR [rsp+0x28],r12
    54aa:	mov    QWORD PTR [rsp+0x30],r13
    54af:	mov    QWORD PTR [rsp+0x38],r14
    54b4:	mov    QWORD PTR [rsp+0x40],r15
    54b9:	mov    r13,QWORD PTR [rdi]
    54bc:	mov    rax,QWORD PTR [rdi+0x8]
    54c0:	lea    rcx,[r13+0x10]
    54c4:	cmp    rcx,rax
    54c7:	ja     5736 <botlish_fn_30+0x29e>
    54cd:	lea    rax,[r13+0x10]
    54d1:	mov    QWORD PTR [rdi],rax
    54d4:	mov    r15,rdi
    54d7:	mov    QWORD PTR [r13+0x0],rdx
    54db:	mov    QWORD PTR [rsp+0x10],rdx
    54e0:	lea    rbx,[rsp]
    54e4:	mov    r12,rsi
    54e7:	mov    rax,QWORD PTR [r12+0x20]
    54ec:	mov    rsi,QWORD PTR [rax]
    54ef:	mov    QWORD PTR [r13+0x8],rsi
    54f3:	mov    rdx,QWORD PTR [rsp+0x10]
    54f8:	mov    rdi,r15
    54fb:	call   5500 <botlish_fn_30+0x68>
			54fc: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_label<generic>
    5500:	mov    rcx,rax
    5503:	mov    r14,rax
    5506:	test   rax,rcx
    5509:	jne    5517 <botlish_fn_30+0x7f>
    550f:	mov    rdi,r15
    5512:	jmp    56a4 <botlish_fn_30+0x20c>
    5517:	mov    rax,r14
    551a:	mov    QWORD PTR [r13+0x0],rax
    551e:	mov    rdx,QWORD PTR [rsp+0x10]
    5523:	mov    rsi,rax
    5526:	and    rsi,rdx
    5529:	test   rsi,0x1
    5530:	jne    5557 <botlish_fn_30+0xbf>
    5536:	mov    rdx,QWORD PTR [rsp+0x10]
    553b:	mov    rsi,r14
    553e:	mov    rdi,r15
    5541:	call   5546 <botlish_fn_30+0xae>
			5542: R_X86_64_PLT32	rt_value_eq-0x4
    5546:	test   rax,rax
    5549:	jne    556c <botlish_fn_30+0xd4>
    554f:	mov    rdi,r15
    5552:	jmp    56a4 <botlish_fn_30+0x20c>
    5557:	mov    eax,0x2
    555c:	mov    rdx,QWORD PTR [rsp+0x10]
    5561:	cmp    r14,rdx
    5564:	cmove  rax,QWORD PTR [rip+0x1fc]        # 5768 <botlish_fn_30+0x2d0>
    556c:	cmp    rax,0x6
    5570:	je     5704 <botlish_fn_30+0x26c>
    5576:	mov    rax,QWORD PTR [r12+0x20]
    557b:	mov    rdx,QWORD PTR [rax+0x8]
    557f:	mov    rax,r14
    5582:	and    rax,rdx
    5585:	test   rax,0x1
    558b:	jne    55b1 <botlish_fn_30+0x119>
    5591:	mov    rsi,r14
    5594:	mov    rdi,r15
    5597:	call   559c <botlish_fn_30+0x104>
			5598: R_X86_64_PLT32	rt_int_cmp-0x4
    559c:	mov    ecx,0x2
    55a1:	test   rax,rax
    55a4:	cmovge rcx,QWORD PTR [rip+0x1bc]        # 5768 <botlish_fn_30+0x2d0>
    55ac:	jmp    55c1 <botlish_fn_30+0x129>
    55b1:	mov    ecx,0x2
    55b6:	cmp    r14,rdx
    55b9:	cmovge rcx,QWORD PTR [rip+0x1a7]        # 5768 <botlish_fn_30+0x2d0>
    55c1:	cmp    rcx,0x6
    55c5:	je     56f5 <botlish_fn_30+0x25d>
    55cb:	mov    rax,QWORD PTR [r12+0x20]
    55d0:	mov    rsi,QWORD PTR [rax+0x10]
    55d4:	mov    QWORD PTR [r13+0x8],rsi
    55d8:	mov    rcx,rbx
    55db:	mov    rdx,r14
    55de:	mov    rdi,r15
    55e1:	call   55e6 <botlish_fn_30+0x14e>
			55e2: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    55e6:	test   rax,rax
    55e9:	mov    rsi,rax
    55ec:	jne    55fa <botlish_fn_30+0x162>
    55f2:	mov    rdi,r15
    55f5:	jmp    56a4 <botlish_fn_30+0x20c>
    55fa:	mov    rdx,QWORD PTR [rsp]
    55fe:	mov    rcx,QWORD PTR [rsp+0x8]
    5603:	mov    rdi,r15
    5606:	mov    rax,QWORD PTR [rdi+0x10]
    560a:	mov    r8,QWORD PTR [rax+0x118]
    5611:	call   5616 <botlish_fn_30+0x17e>
			5612: R_X86_64_PLT32	rt_str_region_eq-0x4
    5616:	cmp    rax,0x6
    561a:	je     562c <botlish_fn_30+0x194>
    5620:	mov    rax,0xffffffffffffffff
    5627:	jmp    56fc <botlish_fn_30+0x264>
    562c:	mov    QWORD PTR [r13+0x8],0x3
    5634:	test   r14,0x1
    563b:	je     5662 <botlish_fn_30+0x1ca>
    5641:	mov    rdx,r14
    5644:	add    rdx,0x2
    5648:	mov    QWORD PTR [rsp+0x10],rdx
    564d:	seto   al
    5650:	test   al,al
    5652:	jne    5662 <botlish_fn_30+0x1ca>
    5658:	mov    rdx,QWORD PTR [rsp+0x10]
    565d:	jmp    567a <botlish_fn_30+0x1e2>
    5662:	mov    edx,0x3
    5667:	mov    rsi,r14
    566a:	mov    rdi,r15
    566d:	call   5672 <botlish_fn_30+0x1da>
			566e: R_X86_64_PLT32	rt_int_add-0x4
    5672:	mov    rdx,rax
    5675:	mov    QWORD PTR [rsp+0x10],rax
    567a:	mov    QWORD PTR [r13+0x0],rdx
    567e:	mov    rax,QWORD PTR [r12+0x20]
    5683:	mov    rsi,QWORD PTR [rax+0x18]
    5687:	mov    QWORD PTR [r13+0x8],rsi
    568b:	mov    rdx,QWORD PTR [rsp+0x10]
    5690:	mov    rdi,r15
    5693:	call   5698 <botlish_fn_30+0x200>
			5694: R_X86_64_PLT32	botlish_fn_29-0x4 ; tld_ok<generic>
    5698:	test   rax,rax
    569b:	jne    56cf <botlish_fn_30+0x237>
    56a1:	mov    rdi,r15
    56a4:	mov    rdi,r15
    56a7:	mov    QWORD PTR [rdi],r13
    56aa:	xor    rax,rax
    56ad:	mov    rbx,QWORD PTR [rsp+0x20]
    56b2:	mov    r12,QWORD PTR [rsp+0x28]
    56b7:	mov    r13,QWORD PTR [rsp+0x30]
    56bc:	mov    r14,QWORD PTR [rsp+0x38]
    56c1:	mov    r15,QWORD PTR [rsp+0x40]
    56c6:	add    rsp,0x50
    56ca:	mov    rsp,rbp
    56cd:	pop    rbp
    56ce:	ret
    56cf:	cmp    rax,0x6
    56d3:	je     56e7 <botlish_fn_30+0x24f>
    56d9:	mov    rdx,QWORD PTR [rsp+0x10]
    56de:	mov    QWORD PTR [r13+0x0],rdx
    56e2:	jmp    54e7 <botlish_fn_30+0x4f>
    56e7:	mov    rax,QWORD PTR [r12+0x20]
    56ec:	mov    rax,QWORD PTR [rax+0x8]
    56f0:	jmp    56fc <botlish_fn_30+0x264>
    56f5:	mov    rax,0xffffffffffffffff
    56fc:	mov    rdi,r15
    56ff:	jmp    570e <botlish_fn_30+0x276>
    5704:	mov    rax,0xffffffffffffffff
    570b:	mov    rdi,r15
    570e:	mov    rdi,r15
    5711:	mov    QWORD PTR [rdi],r13
    5714:	mov    rbx,QWORD PTR [rsp+0x20]
    5719:	mov    r12,QWORD PTR [rsp+0x28]
    571e:	mov    r13,QWORD PTR [rsp+0x30]
    5723:	mov    r14,QWORD PTR [rsp+0x38]
    5728:	mov    r15,QWORD PTR [rsp+0x40]
    572d:	add    rsp,0x50
    5731:	mov    rsp,rbp
    5734:	pop    rbp
    5735:	ret
    5736:	mov    r15,rdi
    5739:	call   573e <botlish_fn_30+0x2a6>
			573a: R_X86_64_PLT32	rt_stack_overflow-0x4
    573e:	xor    rax,rax
    5741:	mov    rbx,QWORD PTR [rsp+0x20]
    5746:	mov    r12,QWORD PTR [rsp+0x28]
    574b:	mov    r13,QWORD PTR [rsp+0x30]
    5750:	mov    r14,QWORD PTR [rsp+0x38]
    5755:	mov    r15,QWORD PTR [rsp+0x40]
    575a:	add    rsp,0x50
    575e:	mov    rsp,rbp
    5761:	pop    rbp
    5762:	ret
    5763:	add    BYTE PTR [rax],al
    5765:	add    BYTE PTR [rax],al
    5767:	add    BYTE PTR [rsi],al
    5769:	add    BYTE PTR [rax],al
    576b:	add    BYTE PTR [rax],al
    576d:	add    BYTE PTR [rax],al
	...

0000000000005770 <botlish_entry_30: domain_loop<generic>>:
    5770:	push   rbp
    5771:	mov    rbp,rsp
    5774:	mov    rdx,QWORD PTR [rdx]
    5777:	call   577c <botlish_entry_30+0xc>
			5778: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    577c:	mov    rsp,rbp
    577f:	pop    rbp
    5780:	ret

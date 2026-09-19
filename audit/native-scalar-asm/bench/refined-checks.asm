; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 24552  (per function: 449 1060 1817 1529 672 1036 685 1084 600 1289 1361 528 579 510 266 609 609 609 673 777 1289 1361 528 579 510 266 609 609 609 673 777)
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
       4:	sub    rsp,0x30
       8:	mov    QWORD PTR [rsp+0x10],rbx
       d:	mov    QWORD PTR [rsp+0x18],r12
      12:	mov    QWORD PTR [rsp+0x20],r13
      17:	mov    QWORD PTR [rsp+0x28],r14
      1c:	mov    r12,QWORD PTR [rdi]
      1f:	mov    rax,QWORD PTR [rdi+0x8]
      23:	lea    rcx,[r12+0x28]
      28:	cmp    rcx,rax
      2b:	ja     18d <botlish_fn_0+0x18d>
      31:	lea    rax,[r12+0x28]
      36:	mov    QWORD PTR [rdi],rax
      39:	mov    QWORD PTR [r12+0x8],0x0
      42:	mov    QWORD PTR [r12+0x10],0x0
      4b:	mov    QWORD PTR [r12+0x18],0x0
      54:	mov    QWORD PTR [r12+0x20],0x0
      5d:	mov    rax,QWORD PTR [rdi+0x10]
      61:	mov    r13,rdi
      64:	mov    rsi,QWORD PTR [rax]
      67:	mov    QWORD PTR [r12],rsi
      6b:	call   70 <botlish_fn_0+0x70>
			6c: R_X86_64_PLT32	botlish_fn_1-0x4 ; web::uri_escape_text<str>
      70:	test   rax,rax
      73:	jne    81 <botlish_fn_0+0x81>
      79:	mov    rdi,r13
      7c:	jmp    144 <botlish_fn_0+0x144>
      81:	mov    QWORD PTR [r12],rax
      85:	mov    r14,rax
      88:	mov    esi,0x321
      8d:	mov    QWORD PTR [r12+0x8],0x321
      96:	mov    edx,0x1
      9b:	mov    QWORD PTR [r12+0x10],0x1
      a4:	mov    rdi,r13
      a7:	mov    rcx,QWORD PTR [rdi+0x10]
      ab:	mov    rcx,QWORD PTR [rcx+0x8]
      af:	mov    QWORD PTR [r12+0x18],rcx
      b4:	mov    r8,r14
      b7:	call   bc <botlish_fn_0+0xbc>
			b8: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
      bc:	mov    rbx,rax
      bf:	test   rbx,rbx
      c2:	jne    d0 <botlish_fn_0+0xd0>
      c8:	mov    rdi,r13
      cb:	jmp    144 <botlish_fn_0+0x144>
      d0:	mov    QWORD PTR [r12+0x8],rbx
      d5:	mov    esi,0x321
      da:	mov    QWORD PTR [r12+0x10],0x321
      e3:	mov    edx,0x1
      e8:	mov    QWORD PTR [r12+0x18],0x1
      f1:	mov    rdi,r13
      f4:	mov    rax,QWORD PTR [rdi+0x10]
      f8:	mov    rcx,QWORD PTR [rax+0x10]
      fc:	mov    QWORD PTR [r12+0x20],rcx
     101:	mov    r8,r14
     104:	call   109 <botlish_fn_0+0x109>
			105: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
     109:	test   rax,rax
     10c:	jne    11a <botlish_fn_0+0x11a>
     112:	mov    rdi,r13
     115:	jmp    144 <botlish_fn_0+0x144>
     11a:	mov    QWORD PTR [r12],rax
     11e:	lea    rdx,[rsp]
     122:	mov    QWORD PTR [rsp],rbx
     126:	mov    QWORD PTR [rsp+0x8],rax
     12b:	mov    esi,0x2
     130:	mov    rdi,r13
     133:	call   138 <botlish_fn_0+0x138>
			134: R_X86_64_PLT32	rt_list_new-0x4
     138:	test   rax,rax
     13b:	jne    16a <botlish_fn_0+0x16a>
     141:	mov    rdi,r13
     144:	mov    rdi,r13
     147:	mov    QWORD PTR [rdi],r12
     14a:	xor    rax,rax
     14d:	mov    rbx,QWORD PTR [rsp+0x10]
     152:	mov    r12,QWORD PTR [rsp+0x18]
     157:	mov    r13,QWORD PTR [rsp+0x20]
     15c:	mov    r14,QWORD PTR [rsp+0x28]
     161:	add    rsp,0x30
     165:	mov    rsp,rbp
     168:	pop    rbp
     169:	ret
     16a:	mov    rdi,r13
     16d:	mov    QWORD PTR [rdi],r12
     170:	mov    rbx,QWORD PTR [rsp+0x10]
     175:	mov    r12,QWORD PTR [rsp+0x18]
     17a:	mov    r13,QWORD PTR [rsp+0x20]
     17f:	mov    r14,QWORD PTR [rsp+0x28]
     184:	add    rsp,0x30
     188:	mov    rsp,rbp
     18b:	pop    rbp
     18c:	ret
     18d:	mov    r13,rdi
     190:	call   195 <botlish_fn_0+0x195>
			191: R_X86_64_PLT32	rt_stack_overflow-0x4
     195:	xor    rax,rax
     198:	mov    rbx,QWORD PTR [rsp+0x10]
     19d:	mov    r12,QWORD PTR [rsp+0x18]
     1a2:	mov    r13,QWORD PTR [rsp+0x20]
     1a7:	mov    r14,QWORD PTR [rsp+0x28]
     1ac:	add    rsp,0x30
     1b0:	mov    rsp,rbp
     1b3:	pop    rbp
     1b4:	ret

00000000000001b5 <botlish_entry_0: <program entry>>:
     1b5:	push   rbp
     1b6:	mov    rbp,rsp
     1b9:	call   1be <botlish_entry_0+0x9>
			1ba: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
     1be:	mov    rsp,rbp
     1c1:	pop    rbp
     1c2:	ret

00000000000001c3 <botlish_fn_1: web::uri_escape_text<str>>:
     1c3:	push   rbp
     1c4:	mov    rbp,rsp
     1c7:	sub    rsp,0x110
     1ce:	mov    QWORD PTR [rsp+0xe0],rbx
     1d6:	mov    QWORD PTR [rsp+0xe8],r12
     1de:	mov    QWORD PTR [rsp+0xf0],r13
     1e6:	mov    QWORD PTR [rsp+0xf8],r14
     1ee:	mov    QWORD PTR [rsp+0x100],r15
     1f6:	mov    r15,QWORD PTR [rdi]
     1f9:	mov    r8,QWORD PTR [rdi+0x8]
     1fd:	lea    r9,[r15+0x88]
     204:	cmp    r9,r8
     207:	ja     54e <botlish_fn_1+0x38b>
     20d:	lea    r8,[r15+0x88]
     214:	mov    QWORD PTR [rdi],r8
     217:	mov    QWORD PTR [r15],rsi
     21a:	mov    QWORD PTR [rsp+0xa8],rsi
     222:	mov    r8,QWORD PTR [rdi+0x10]
     226:	mov    r9,QWORD PTR [r8+0x18]
     22a:	mov    QWORD PTR [r15+0x8],r9
     22e:	mov    QWORD PTR [rsp+0xd0],r9
     236:	mov    r9,QWORD PTR [rdi+0x10]
     23a:	mov    r10,QWORD PTR [r9+0x20]
     23e:	mov    QWORD PTR [r15+0x10],r10
     242:	mov    QWORD PTR [rsp+0xc8],r10
     24a:	mov    r10,QWORD PTR [rdi+0x10]
     24e:	mov    r11,QWORD PTR [r10+0x28]
     252:	mov    QWORD PTR [r15+0x18],r11
     256:	mov    QWORD PTR [rsp+0xc0],r11
     25e:	mov    r11,QWORD PTR [rdi+0x10]
     262:	mov    rcx,QWORD PTR [r11+0x30]
     266:	mov    QWORD PTR [r15+0x20],rcx
     26a:	mov    QWORD PTR [rsp+0xb8],rcx
     272:	mov    rax,QWORD PTR [rdi+0x10]
     276:	mov    r11,QWORD PTR [rax+0x38]
     27a:	mov    QWORD PTR [r15+0x28],r11
     27e:	mov    QWORD PTR [rsp+0xb0],r11
     286:	mov    rax,QWORD PTR [rdi+0x10]
     28a:	mov    r11,QWORD PTR [rax+0x40]
     28e:	mov    QWORD PTR [r15+0x30],r11
     292:	mov    rax,QWORD PTR [rdi+0x10]
     296:	mov    rsi,QWORD PTR [rax+0x48]
     29a:	mov    QWORD PTR [r15+0x38],rsi
     29e:	mov    rax,QWORD PTR [rdi+0x10]
     2a2:	mov    rax,QWORD PTR [rax+0x50]
     2a6:	mov    QWORD PTR [r15+0x40],rax
     2aa:	mov    rdx,QWORD PTR [rdi+0x10]
     2ae:	mov    rbx,QWORD PTR [rdx+0x58]
     2b2:	mov    QWORD PTR [r15+0x48],rbx
     2b6:	mov    rdx,QWORD PTR [rdi+0x10]
     2ba:	mov    r12,QWORD PTR [rdx+0x60]
     2be:	mov    QWORD PTR [r15+0x50],r12
     2c2:	mov    rdx,QWORD PTR [rdi+0x10]
     2c6:	mov    r13,QWORD PTR [rdx+0x68]
     2ca:	mov    QWORD PTR [r15+0x58],r13
     2ce:	mov    rdx,QWORD PTR [rdi+0x10]
     2d2:	mov    r14,QWORD PTR [rdx+0x70]
     2d6:	mov    QWORD PTR [r15+0x60],r14
     2da:	mov    rdx,QWORD PTR [rdi+0x10]
     2de:	mov    r8,QWORD PTR [rdx+0x78]
     2e2:	mov    QWORD PTR [r15+0x68],r8
     2e6:	mov    rdx,QWORD PTR [rdi+0x10]
     2ea:	mov    r9,QWORD PTR [rdx+0x80]
     2f1:	mov    QWORD PTR [r15+0x70],r9
     2f5:	mov    rdx,QWORD PTR [rdi+0x10]
     2f9:	mov    r10,QWORD PTR [rdx+0x88]
     300:	mov    QWORD PTR [r15+0x78],r10
     304:	mov    rdx,QWORD PTR [rdi+0x10]
     308:	mov    QWORD PTR [rsp+0xa0],rdi
     310:	mov    rdi,QWORD PTR [rdx+0x90]
     317:	mov    QWORD PTR [r15+0x80],rdi
     31e:	lea    rdx,[rsp]
     322:	mov    rcx,QWORD PTR [rsp+0xd0]
     32a:	mov    QWORD PTR [rsp],rcx
     32e:	mov    rcx,QWORD PTR [rsp+0xc8]
     336:	mov    QWORD PTR [rsp+0x8],rcx
     33b:	mov    rcx,QWORD PTR [rsp+0xc0]
     343:	mov    QWORD PTR [rsp+0x10],rcx
     348:	mov    rcx,QWORD PTR [rsp+0xb8]
     350:	mov    QWORD PTR [rsp+0x18],rcx
     355:	mov    rcx,QWORD PTR [rsp+0xb0]
     35d:	mov    QWORD PTR [rsp+0x20],rcx
     362:	mov    QWORD PTR [rsp+0x28],r11
     367:	mov    QWORD PTR [rsp+0x30],rsi
     36c:	mov    QWORD PTR [rsp+0x38],rax
     371:	mov    QWORD PTR [rsp+0x40],rbx
     376:	mov    QWORD PTR [rsp+0x48],r12
     37b:	mov    QWORD PTR [rsp+0x50],r13
     380:	mov    QWORD PTR [rsp+0x58],r14
     385:	mov    QWORD PTR [rsp+0x60],r8
     38a:	mov    QWORD PTR [rsp+0x68],r9
     38f:	mov    QWORD PTR [rsp+0x70],r10
     394:	mov    QWORD PTR [rsp+0x78],rdi
     399:	mov    esi,0x10
     39e:	mov    rdi,QWORD PTR [rsp+0xa0]
     3a6:	call   3ab <botlish_fn_1+0x1e8>
			3a7: R_X86_64_PLT32	rt_list_new-0x4
     3ab:	test   rax,rax
     3ae:	jne    3c1 <botlish_fn_1+0x1fe>
     3b4:	mov    rdi,QWORD PTR [rsp+0xa0]
     3bc:	jmp    4cd <botlish_fn_1+0x30a>
     3c1:	mov    QWORD PTR [r15+0x8],rax
     3c5:	lea    r8,[rsp+0x80]
     3cd:	mov    QWORD PTR [rsp+0x80],rax
     3d5:	mov    esi,0x4
     3da:	mov    rdx,QWORD PTR [rip+0x0]        # 3e1 <botlish_fn_1+0x21e>
			3dd: R_X86_64_GOTPCREL	botlish_entry_4-0x4 ; hex_pair<generic>
     3e1:	mov    ebx,0x1
     3e6:	mov    rcx,rbx
     3e9:	mov    rdi,QWORD PTR [rsp+0xa0]
     3f1:	call   3f6 <botlish_fn_1+0x233>
			3f2: R_X86_64_PLT32	rt_closure_new-0x4
     3f6:	mov    QWORD PTR [r15+0x8],rax
     3fa:	lea    r8,[rsp+0x88]
     402:	mov    QWORD PTR [rsp+0x88],rax
     40a:	mov    esi,0x5
     40f:	mov    rdx,QWORD PTR [rip+0x0]        # 416 <botlish_fn_1+0x253>
			412: R_X86_64_GOTPCREL	botlish_entry_5-0x4 ; esc_bytes<generic>
     416:	mov    rcx,rbx
     419:	mov    rdi,QWORD PTR [rsp+0xa0]
     421:	call   426 <botlish_fn_1+0x263>
			422: R_X86_64_PLT32	rt_closure_new-0x4
     426:	mov    QWORD PTR [r15+0x8],rax
     42a:	lea    r8,[rsp+0x90]
     432:	mov    QWORD PTR [rsp+0x90],rax
     43a:	mov    esi,0x6
     43f:	mov    rdx,QWORD PTR [rip+0x0]        # 446 <botlish_fn_1+0x283>
			442: R_X86_64_GOTPCREL	botlish_entry_6-0x4 ; esc_char<generic>
     446:	mov    rcx,rbx
     449:	mov    rdi,QWORD PTR [rsp+0xa0]
     451:	call   456 <botlish_fn_1+0x293>
			452: R_X86_64_PLT32	rt_closure_new-0x4
     456:	mov    QWORD PTR [r15+0x8],rax
     45a:	lea    r8,[rsp+0x98]
     462:	mov    QWORD PTR [rsp+0x98],rax
     46a:	mov    esi,0x7
     46f:	mov    rdx,QWORD PTR [rip+0x0]        # 476 <botlish_fn_1+0x2b3>
			472: R_X86_64_GOTPCREL	botlish_entry_7-0x4 ; esc_from<generic>
     476:	mov    rcx,rbx
     479:	mov    rdi,QWORD PTR [rsp+0xa0]
     481:	call   486 <botlish_fn_1+0x2c3>
			482: R_X86_64_PLT32	rt_closure_new-0x4
     486:	mov    QWORD PTR [r15+0x8],rax
     48a:	mov    QWORD PTR [r15+0x10],0x1
     492:	mov    rdi,QWORD PTR [rsp+0xa0]
     49a:	mov    rcx,QWORD PTR [rdi+0x10]
     49e:	mov    r8,QWORD PTR [rcx+0x98]
     4a5:	mov    QWORD PTR [r15+0x18],r8
     4a9:	mov    rcx,rbx
     4ac:	mov    rdx,QWORD PTR [rsp+0xa8]
     4b4:	mov    rsi,rax
     4b7:	call   4bc <botlish_fn_1+0x2f9>
			4b8: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
     4bc:	test   rax,rax
     4bf:	jne    50f <botlish_fn_1+0x34c>
     4c5:	mov    rdi,QWORD PTR [rsp+0xa0]
     4cd:	mov    rdi,QWORD PTR [rsp+0xa0]
     4d5:	mov    QWORD PTR [rdi],r15
     4d8:	xor    rax,rax
     4db:	mov    rbx,QWORD PTR [rsp+0xe0]
     4e3:	mov    r12,QWORD PTR [rsp+0xe8]
     4eb:	mov    r13,QWORD PTR [rsp+0xf0]
     4f3:	mov    r14,QWORD PTR [rsp+0xf8]
     4fb:	mov    r15,QWORD PTR [rsp+0x100]
     503:	add    rsp,0x110
     50a:	mov    rsp,rbp
     50d:	pop    rbp
     50e:	ret
     50f:	mov    rdi,QWORD PTR [rsp+0xa0]
     517:	mov    QWORD PTR [rdi],r15
     51a:	mov    rbx,QWORD PTR [rsp+0xe0]
     522:	mov    r12,QWORD PTR [rsp+0xe8]
     52a:	mov    r13,QWORD PTR [rsp+0xf0]
     532:	mov    r14,QWORD PTR [rsp+0xf8]
     53a:	mov    r15,QWORD PTR [rsp+0x100]
     542:	add    rsp,0x110
     549:	mov    rsp,rbp
     54c:	pop    rbp
     54d:	ret
     54e:	mov    QWORD PTR [rsp+0xa0],rdi
     556:	call   55b <botlish_fn_1+0x398>
			557: R_X86_64_PLT32	rt_stack_overflow-0x4
     55b:	xor    rax,rax
     55e:	mov    rbx,QWORD PTR [rsp+0xe0]
     566:	mov    r12,QWORD PTR [rsp+0xe8]
     56e:	mov    r13,QWORD PTR [rsp+0xf0]
     576:	mov    r14,QWORD PTR [rsp+0xf8]
     57e:	mov    r15,QWORD PTR [rsp+0x100]
     586:	add    rsp,0x110
     58d:	mov    rsp,rbp
     590:	pop    rbp
     591:	ret

0000000000000592 <botlish_entry_1: web::uri_escape_text<str>>:
     592:	push   rbp
     593:	mov    rbp,rsp
     596:	mov    rsi,QWORD PTR [rdx]
     599:	call   59e <botlish_entry_1+0xc>
			59a: R_X86_64_PLT32	botlish_fn_1-0x4 ; web::uri_escape_text<str>
     59e:	mov    rsp,rbp
     5a1:	pop    rbp
     5a2:	ret
     5a3:	add    BYTE PTR [rax],al
     5a5:	add    BYTE PTR [rax],al
	...

00000000000005a8 <botlish_fn_2: high_nibble<generic>>:
     5a8:	push   rbp
     5a9:	mov    rbp,rsp
     5ac:	sub    rsp,0x20
     5b0:	mov    QWORD PTR [rsp],rbx
     5b4:	mov    QWORD PTR [rsp+0x8],r12
     5b9:	mov    QWORD PTR [rsp+0x10],r13
     5be:	mov    rbx,QWORD PTR [rdi]
     5c1:	mov    rax,QWORD PTR [rdi+0x8]
     5c5:	lea    rcx,[rbx+0x8]
     5c9:	cmp    rcx,rax
     5cc:	ja     c06 <botlish_fn_2+0x65e>
     5d2:	lea    rax,[rbx+0x8]
     5d6:	mov    QWORD PTR [rdi],rax
     5d9:	mov    r11d,0x1
     5df:	test   rsi,0x1
     5e6:	jne    606 <botlish_fn_2+0x5e>
     5ec:	xor    r11d,r11d
     5ef:	test   rsi,0x7
     5f6:	jne    606 <botlish_fn_2+0x5e>
     5fc:	movzx  rax,BYTE PTR [rsi]
     600:	cmp    al,0x1
     602:	sete   r11b
     606:	test   r11b,r11b
     609:	jne    648 <botlish_fn_2+0xa0>
     60f:	mov    rax,QWORD PTR [rdi+0x10]
     613:	mov    r13,rdi
     616:	mov    rcx,QWORD PTR [rax+0xa0]
     61d:	xor    r12,r12
     620:	mov    rdx,r12
     623:	call   628 <botlish_fn_2+0x80>
			624: R_X86_64_PLT32	rt_type_error-0x4
     628:	mov    rax,r12
     62b:	mov    rdi,r13
     62e:	mov    QWORD PTR [rdi],rbx
     631:	mov    rbx,QWORD PTR [rsp]
     635:	mov    r12,QWORD PTR [rsp+0x8]
     63a:	mov    r13,QWORD PTR [rsp+0x10]
     63f:	add    rsp,0x20
     643:	mov    rsp,rbp
     646:	pop    rbp
     647:	ret
     648:	mov    r13,rdi
     64b:	test   rsi,0x1
     652:	mov    r12,rsi
     655:	jne    680 <botlish_fn_2+0xd8>
     65b:	mov    edx,0x1f
     660:	mov    rsi,r12
     663:	mov    rdi,r13
     666:	call   66b <botlish_fn_2+0xc3>
			667: R_X86_64_PLT32	rt_int_cmp-0x4
     66b:	mov    ecx,0x2
     670:	test   rax,rax
     673:	cmovle rcx,QWORD PTR [rip+0x5ad]        # c28 <botlish_fn_2+0x680>
     67b:	jmp    694 <botlish_fn_2+0xec>
     680:	mov    ecx,0x2
     685:	mov    rsi,r12
     688:	cmp    rsi,0x1f
     68c:	cmovle rcx,QWORD PTR [rip+0x594]        # c28 <botlish_fn_2+0x680>
     694:	cmp    rcx,0x6
     698:	je     be1 <botlish_fn_2+0x639>
     69e:	mov    rsi,r12
     6a1:	test   rsi,0x1
     6a8:	jne    6d3 <botlish_fn_2+0x12b>
     6ae:	mov    edx,0x3f
     6b3:	mov    rsi,r12
     6b6:	mov    rdi,r13
     6b9:	call   6be <botlish_fn_2+0x116>
			6ba: R_X86_64_PLT32	rt_int_cmp-0x4
     6be:	mov    ecx,0x2
     6c3:	test   rax,rax
     6c6:	cmovle rcx,QWORD PTR [rip+0x55a]        # c28 <botlish_fn_2+0x680>
     6ce:	jmp    6e7 <botlish_fn_2+0x13f>
     6d3:	mov    ecx,0x2
     6d8:	mov    rsi,r12
     6db:	cmp    rsi,0x3f
     6df:	cmovle rcx,QWORD PTR [rip+0x541]        # c28 <botlish_fn_2+0x680>
     6e7:	cmp    rcx,0x6
     6eb:	je     bd4 <botlish_fn_2+0x62c>
     6f1:	mov    rsi,r12
     6f4:	test   rsi,0x1
     6fb:	jne    726 <botlish_fn_2+0x17e>
     701:	mov    edx,0x5f
     706:	mov    rsi,r12
     709:	mov    rdi,r13
     70c:	call   711 <botlish_fn_2+0x169>
			70d: R_X86_64_PLT32	rt_int_cmp-0x4
     711:	mov    esi,0x2
     716:	test   rax,rax
     719:	cmovle rsi,QWORD PTR [rip+0x507]        # c28 <botlish_fn_2+0x680>
     721:	jmp    73a <botlish_fn_2+0x192>
     726:	mov    esi,0x2
     72b:	mov    rax,r12
     72e:	cmp    rax,0x5f
     732:	cmovle rsi,QWORD PTR [rip+0x4ee]        # c28 <botlish_fn_2+0x680>
     73a:	cmp    rsi,0x6
     73e:	je     bca <botlish_fn_2+0x622>
     744:	mov    rsi,r12
     747:	test   rsi,0x1
     74e:	jne    779 <botlish_fn_2+0x1d1>
     754:	mov    edx,0x7f
     759:	mov    rsi,r12
     75c:	mov    rdi,r13
     75f:	call   764 <botlish_fn_2+0x1bc>
			760: R_X86_64_PLT32	rt_int_cmp-0x4
     764:	mov    ecx,0x2
     769:	test   rax,rax
     76c:	cmovle rcx,QWORD PTR [rip+0x4b4]        # c28 <botlish_fn_2+0x680>
     774:	jmp    78d <botlish_fn_2+0x1e5>
     779:	mov    ecx,0x2
     77e:	mov    rsi,r12
     781:	cmp    rsi,0x7f
     785:	cmovle rcx,QWORD PTR [rip+0x49b]        # c28 <botlish_fn_2+0x680>
     78d:	cmp    rcx,0x6
     791:	je     bc0 <botlish_fn_2+0x618>
     797:	mov    rsi,r12
     79a:	test   rsi,0x1
     7a1:	jne    7cc <botlish_fn_2+0x224>
     7a7:	mov    edx,0x9f
     7ac:	mov    rsi,r12
     7af:	mov    rdi,r13
     7b2:	call   7b7 <botlish_fn_2+0x20f>
			7b3: R_X86_64_PLT32	rt_int_cmp-0x4
     7b7:	mov    ecx,0x2
     7bc:	test   rax,rax
     7bf:	cmovle rcx,QWORD PTR [rip+0x461]        # c28 <botlish_fn_2+0x680>
     7c7:	jmp    7e3 <botlish_fn_2+0x23b>
     7cc:	mov    ecx,0x2
     7d1:	mov    rsi,r12
     7d4:	cmp    rsi,0x9f
     7db:	cmovle rcx,QWORD PTR [rip+0x445]        # c28 <botlish_fn_2+0x680>
     7e3:	cmp    rcx,0x6
     7e7:	je     bb6 <botlish_fn_2+0x60e>
     7ed:	mov    rsi,r12
     7f0:	test   rsi,0x1
     7f7:	jne    822 <botlish_fn_2+0x27a>
     7fd:	mov    edx,0xbf
     802:	mov    rsi,r12
     805:	mov    rdi,r13
     808:	call   80d <botlish_fn_2+0x265>
			809: R_X86_64_PLT32	rt_int_cmp-0x4
     80d:	mov    ecx,0x2
     812:	test   rax,rax
     815:	cmovle rcx,QWORD PTR [rip+0x40b]        # c28 <botlish_fn_2+0x680>
     81d:	jmp    839 <botlish_fn_2+0x291>
     822:	mov    ecx,0x2
     827:	mov    rsi,r12
     82a:	cmp    rsi,0xbf
     831:	cmovle rcx,QWORD PTR [rip+0x3ef]        # c28 <botlish_fn_2+0x680>
     839:	cmp    rcx,0x6
     83d:	je     bac <botlish_fn_2+0x604>
     843:	mov    rsi,r12
     846:	test   rsi,0x1
     84d:	jne    878 <botlish_fn_2+0x2d0>
     853:	mov    edx,0xdf
     858:	mov    rsi,r12
     85b:	mov    rdi,r13
     85e:	call   863 <botlish_fn_2+0x2bb>
			85f: R_X86_64_PLT32	rt_int_cmp-0x4
     863:	mov    esi,0x2
     868:	test   rax,rax
     86b:	cmovle rsi,QWORD PTR [rip+0x3b5]        # c28 <botlish_fn_2+0x680>
     873:	jmp    88e <botlish_fn_2+0x2e6>
     878:	mov    esi,0x2
     87d:	mov    rax,r12
     880:	cmp    rax,0xdf
     886:	cmovle rsi,QWORD PTR [rip+0x39a]        # c28 <botlish_fn_2+0x680>
     88e:	cmp    rsi,0x6
     892:	je     ba2 <botlish_fn_2+0x5fa>
     898:	mov    rsi,r12
     89b:	test   rsi,0x1
     8a2:	jne    8cd <botlish_fn_2+0x325>
     8a8:	mov    edx,0xff
     8ad:	mov    rsi,r12
     8b0:	mov    rdi,r13
     8b3:	call   8b8 <botlish_fn_2+0x310>
			8b4: R_X86_64_PLT32	rt_int_cmp-0x4
     8b8:	mov    ecx,0x2
     8bd:	test   rax,rax
     8c0:	cmovle rcx,QWORD PTR [rip+0x360]        # c28 <botlish_fn_2+0x680>
     8c8:	jmp    8e4 <botlish_fn_2+0x33c>
     8cd:	mov    ecx,0x2
     8d2:	mov    rsi,r12
     8d5:	cmp    rsi,0xff
     8dc:	cmovle rcx,QWORD PTR [rip+0x344]        # c28 <botlish_fn_2+0x680>
     8e4:	cmp    rcx,0x6
     8e8:	je     b98 <botlish_fn_2+0x5f0>
     8ee:	mov    rsi,r12
     8f1:	test   rsi,0x1
     8f8:	jne    923 <botlish_fn_2+0x37b>
     8fe:	mov    edx,0x11f
     903:	mov    rsi,r12
     906:	mov    rdi,r13
     909:	call   90e <botlish_fn_2+0x366>
			90a: R_X86_64_PLT32	rt_int_cmp-0x4
     90e:	mov    ecx,0x2
     913:	test   rax,rax
     916:	cmovle rcx,QWORD PTR [rip+0x30a]        # c28 <botlish_fn_2+0x680>
     91e:	jmp    93a <botlish_fn_2+0x392>
     923:	mov    ecx,0x2
     928:	mov    rsi,r12
     92b:	cmp    rsi,0x11f
     932:	cmovle rcx,QWORD PTR [rip+0x2ee]        # c28 <botlish_fn_2+0x680>
     93a:	cmp    rcx,0x6
     93e:	je     b8e <botlish_fn_2+0x5e6>
     944:	mov    rsi,r12
     947:	test   rsi,0x1
     94e:	jne    979 <botlish_fn_2+0x3d1>
     954:	mov    edx,0x13f
     959:	mov    rsi,r12
     95c:	mov    rdi,r13
     95f:	call   964 <botlish_fn_2+0x3bc>
			960: R_X86_64_PLT32	rt_int_cmp-0x4
     964:	mov    ecx,0x2
     969:	test   rax,rax
     96c:	cmovle rcx,QWORD PTR [rip+0x2b4]        # c28 <botlish_fn_2+0x680>
     974:	jmp    990 <botlish_fn_2+0x3e8>
     979:	mov    ecx,0x2
     97e:	mov    rsi,r12
     981:	cmp    rsi,0x13f
     988:	cmovle rcx,QWORD PTR [rip+0x298]        # c28 <botlish_fn_2+0x680>
     990:	cmp    rcx,0x6
     994:	je     b84 <botlish_fn_2+0x5dc>
     99a:	mov    rsi,r12
     99d:	test   rsi,0x1
     9a4:	jne    9cf <botlish_fn_2+0x427>
     9aa:	mov    edx,0x15f
     9af:	mov    rsi,r12
     9b2:	mov    rdi,r13
     9b5:	call   9ba <botlish_fn_2+0x412>
			9b6: R_X86_64_PLT32	rt_int_cmp-0x4
     9ba:	mov    ecx,0x2
     9bf:	test   rax,rax
     9c2:	cmovle rcx,QWORD PTR [rip+0x25e]        # c28 <botlish_fn_2+0x680>
     9ca:	jmp    9e6 <botlish_fn_2+0x43e>
     9cf:	mov    ecx,0x2
     9d4:	mov    rsi,r12
     9d7:	cmp    rsi,0x15f
     9de:	cmovle rcx,QWORD PTR [rip+0x242]        # c28 <botlish_fn_2+0x680>
     9e6:	cmp    rcx,0x6
     9ea:	je     b7a <botlish_fn_2+0x5d2>
     9f0:	mov    rsi,r12
     9f3:	test   rsi,0x1
     9fa:	jne    a25 <botlish_fn_2+0x47d>
     a00:	mov    edx,0x17f
     a05:	mov    rsi,r12
     a08:	mov    rdi,r13
     a0b:	call   a10 <botlish_fn_2+0x468>
			a0c: R_X86_64_PLT32	rt_int_cmp-0x4
     a10:	mov    ecx,0x2
     a15:	test   rax,rax
     a18:	cmovle rcx,QWORD PTR [rip+0x208]        # c28 <botlish_fn_2+0x680>
     a20:	jmp    a3c <botlish_fn_2+0x494>
     a25:	mov    ecx,0x2
     a2a:	mov    rsi,r12
     a2d:	cmp    rsi,0x17f
     a34:	cmovle rcx,QWORD PTR [rip+0x1ec]        # c28 <botlish_fn_2+0x680>
     a3c:	cmp    rcx,0x6
     a40:	je     b70 <botlish_fn_2+0x5c8>
     a46:	mov    rsi,r12
     a49:	test   rsi,0x1
     a50:	jne    a7b <botlish_fn_2+0x4d3>
     a56:	mov    edx,0x19f
     a5b:	mov    rsi,r12
     a5e:	mov    rdi,r13
     a61:	call   a66 <botlish_fn_2+0x4be>
			a62: R_X86_64_PLT32	rt_int_cmp-0x4
     a66:	mov    ecx,0x2
     a6b:	test   rax,rax
     a6e:	cmovle rcx,QWORD PTR [rip+0x1b2]        # c28 <botlish_fn_2+0x680>
     a76:	jmp    a92 <botlish_fn_2+0x4ea>
     a7b:	mov    ecx,0x2
     a80:	mov    rsi,r12
     a83:	cmp    rsi,0x19f
     a8a:	cmovle rcx,QWORD PTR [rip+0x196]        # c28 <botlish_fn_2+0x680>
     a92:	cmp    rcx,0x6
     a96:	je     b66 <botlish_fn_2+0x5be>
     a9c:	mov    rsi,r12
     a9f:	test   rsi,0x1
     aa6:	jne    ad1 <botlish_fn_2+0x529>
     aac:	mov    edx,0x1bf
     ab1:	mov    rsi,r12
     ab4:	mov    rdi,r13
     ab7:	call   abc <botlish_fn_2+0x514>
			ab8: R_X86_64_PLT32	rt_int_cmp-0x4
     abc:	mov    ecx,0x2
     ac1:	test   rax,rax
     ac4:	cmovle rcx,QWORD PTR [rip+0x15c]        # c28 <botlish_fn_2+0x680>
     acc:	jmp    ae8 <botlish_fn_2+0x540>
     ad1:	mov    ecx,0x2
     ad6:	mov    rsi,r12
     ad9:	cmp    rsi,0x1bf
     ae0:	cmovle rcx,QWORD PTR [rip+0x140]        # c28 <botlish_fn_2+0x680>
     ae8:	cmp    rcx,0x6
     aec:	je     b5c <botlish_fn_2+0x5b4>
     af2:	mov    rsi,r12
     af5:	test   rsi,0x1
     afc:	jne    b27 <botlish_fn_2+0x57f>
     b02:	mov    edx,0x1df
     b07:	mov    rsi,r12
     b0a:	mov    rdi,r13
     b0d:	call   b12 <botlish_fn_2+0x56a>
			b0e: R_X86_64_PLT32	rt_int_cmp-0x4
     b12:	mov    ecx,0x2
     b17:	test   rax,rax
     b1a:	cmovle rcx,QWORD PTR [rip+0x106]        # c28 <botlish_fn_2+0x680>
     b22:	jmp    b3e <botlish_fn_2+0x596>
     b27:	mov    ecx,0x2
     b2c:	mov    rsi,r12
     b2f:	cmp    rsi,0x1df
     b36:	cmovle rcx,QWORD PTR [rip+0xea]        # c28 <botlish_fn_2+0x680>
     b3e:	cmp    rcx,0x6
     b42:	je     b52 <botlish_fn_2+0x5aa>
     b48:	mov    eax,0x1f
     b4d:	jmp    bd9 <botlish_fn_2+0x631>
     b52:	mov    eax,0x1d
     b57:	jmp    bd9 <botlish_fn_2+0x631>
     b5c:	mov    eax,0x1b
     b61:	jmp    bd9 <botlish_fn_2+0x631>
     b66:	mov    eax,0x19
     b6b:	jmp    bd9 <botlish_fn_2+0x631>
     b70:	mov    eax,0x17
     b75:	jmp    bd9 <botlish_fn_2+0x631>
     b7a:	mov    eax,0x15
     b7f:	jmp    bd9 <botlish_fn_2+0x631>
     b84:	mov    eax,0x13
     b89:	jmp    bd9 <botlish_fn_2+0x631>
     b8e:	mov    eax,0x11
     b93:	jmp    bd9 <botlish_fn_2+0x631>
     b98:	mov    eax,0xf
     b9d:	jmp    bd9 <botlish_fn_2+0x631>
     ba2:	mov    eax,0xd
     ba7:	jmp    bd9 <botlish_fn_2+0x631>
     bac:	mov    eax,0xb
     bb1:	jmp    bd9 <botlish_fn_2+0x631>
     bb6:	mov    eax,0x9
     bbb:	jmp    bd9 <botlish_fn_2+0x631>
     bc0:	mov    eax,0x7
     bc5:	jmp    bd9 <botlish_fn_2+0x631>
     bca:	mov    eax,0x5
     bcf:	jmp    bd9 <botlish_fn_2+0x631>
     bd4:	mov    eax,0x3
     bd9:	mov    rdi,r13
     bdc:	jmp    be9 <botlish_fn_2+0x641>
     be1:	mov    eax,0x1
     be6:	mov    rdi,r13
     be9:	mov    rdi,r13
     bec:	mov    QWORD PTR [rdi],rbx
     bef:	mov    rbx,QWORD PTR [rsp]
     bf3:	mov    r12,QWORD PTR [rsp+0x8]
     bf8:	mov    r13,QWORD PTR [rsp+0x10]
     bfd:	add    rsp,0x20
     c01:	mov    rsp,rbp
     c04:	pop    rbp
     c05:	ret
     c06:	mov    r13,rdi
     c09:	call   c0e <botlish_fn_2+0x666>
			c0a: R_X86_64_PLT32	rt_stack_overflow-0x4
     c0e:	xor    rax,rax
     c11:	mov    rbx,QWORD PTR [rsp]
     c15:	mov    r12,QWORD PTR [rsp+0x8]
     c1a:	mov    r13,QWORD PTR [rsp+0x10]
     c1f:	add    rsp,0x20
     c23:	mov    rsp,rbp
     c26:	pop    rbp
     c27:	ret
     c28:	(bad)
     c29:	add    BYTE PTR [rax],al
     c2b:	add    BYTE PTR [rax],al
     c2d:	add    BYTE PTR [rax],al
	...

0000000000000c30 <botlish_entry_2: high_nibble<generic>>:
     c30:	push   rbp
     c31:	mov    rbp,rsp
     c34:	mov    rsi,QWORD PTR [rdx]
     c37:	call   c3c <botlish_entry_2+0xc>
			c38: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
     c3c:	mov    rsp,rbp
     c3f:	pop    rbp
     c40:	ret
     c41:	add    BYTE PTR [rax],al
     c43:	add    BYTE PTR [rax],al
     c45:	add    BYTE PTR [rax],al
	...

0000000000000c48 <botlish_fn_3: is_unreserved<generic>>:
     c48:	push   rbp
     c49:	mov    rbp,rsp
     c4c:	sub    rsp,0x20
     c50:	mov    QWORD PTR [rsp],rbx
     c54:	mov    QWORD PTR [rsp+0x8],r12
     c59:	mov    QWORD PTR [rsp+0x10],r13
     c5e:	mov    QWORD PTR [rsp+0x18],r14
     c63:	mov    rbx,QWORD PTR [rdi]
     c66:	mov    rax,QWORD PTR [rdi+0x8]
     c6a:	lea    rcx,[rbx+0x8]
     c6e:	cmp    rcx,rax
     c71:	ja     1193 <botlish_fn_3+0x54b>
     c77:	lea    rax,[rbx+0x8]
     c7b:	mov    QWORD PTR [rdi],rax
     c7e:	mov    r11d,0x1
     c84:	test   rsi,0x1
     c8b:	jne    cad <botlish_fn_3+0x65>
     c91:	xor    r11d,r11d
     c94:	test   rsi,0x7
     c9b:	jne    cad <botlish_fn_3+0x65>
     ca1:	movzx  r8,BYTE PTR [rsi]
     ca5:	cmp    r8b,0x1
     ca9:	sete   r11b
     cad:	test   r11b,r11b
     cb0:	jne    cf4 <botlish_fn_3+0xac>
     cb6:	mov    rax,QWORD PTR [rdi+0x10]
     cba:	mov    r13,rdi
     cbd:	mov    rcx,QWORD PTR [rax+0xa0]
     cc4:	xor    r12,r12
     cc7:	mov    rdx,r12
     cca:	call   ccf <botlish_fn_3+0x87>
			ccb: R_X86_64_PLT32	rt_type_error-0x4
     ccf:	mov    rax,r12
     cd2:	mov    rdi,r13
     cd5:	mov    QWORD PTR [rdi],rbx
     cd8:	mov    rbx,QWORD PTR [rsp]
     cdc:	mov    r12,QWORD PTR [rsp+0x8]
     ce1:	mov    r13,QWORD PTR [rsp+0x10]
     ce6:	mov    r14,QWORD PTR [rsp+0x18]
     ceb:	add    rsp,0x20
     cef:	mov    rsp,rbp
     cf2:	pop    rbp
     cf3:	ret
     cf4:	mov    r13,rdi
     cf7:	test   rsi,0x1
     cfe:	mov    r12,rsi
     d01:	jne    d2c <botlish_fn_3+0xe4>
     d07:	mov    edx,0x59
     d0c:	mov    rsi,r12
     d0f:	mov    rdi,r13
     d12:	call   d17 <botlish_fn_3+0xcf>
			d13: R_X86_64_PLT32	rt_int_cmp-0x4
     d17:	mov    ecx,0x2
     d1c:	test   rax,rax
     d1f:	cmovle rcx,QWORD PTR [rip+0x499]        # 11c0 <botlish_fn_3+0x578>
     d27:	jmp    d40 <botlish_fn_3+0xf8>
     d2c:	mov    ecx,0x2
     d31:	mov    rsi,r12
     d34:	cmp    rsi,0x59
     d38:	cmovle rcx,QWORD PTR [rip+0x480]        # 11c0 <botlish_fn_3+0x578>
     d40:	mov    eax,0x6
     d45:	mov    r14,rax
     d48:	cmp    rcx,0x6
     d4c:	je     1169 <botlish_fn_3+0x521>
     d52:	mov    rsi,r12
     d55:	test   rsi,0x1
     d5c:	jne    d87 <botlish_fn_3+0x13f>
     d62:	mov    edx,0x5d
     d67:	mov    rsi,r12
     d6a:	mov    rdi,r13
     d6d:	call   d72 <botlish_fn_3+0x12a>
			d6e: R_X86_64_PLT32	rt_int_cmp-0x4
     d72:	mov    ecx,0x2
     d77:	test   rax,rax
     d7a:	cmovle rcx,QWORD PTR [rip+0x43e]        # 11c0 <botlish_fn_3+0x578>
     d82:	jmp    d9b <botlish_fn_3+0x153>
     d87:	mov    ecx,0x2
     d8c:	mov    rsi,r12
     d8f:	cmp    rsi,0x5d
     d93:	cmovle rcx,QWORD PTR [rip+0x425]        # 11c0 <botlish_fn_3+0x578>
     d9b:	cmp    rcx,0x6
     d9f:	je     115e <botlish_fn_3+0x516>
     da5:	mov    rsi,r12
     da8:	test   rsi,0x1
     daf:	jne    dda <botlish_fn_3+0x192>
     db5:	mov    edx,0x5f
     dba:	mov    rsi,r12
     dbd:	mov    rdi,r13
     dc0:	call   dc5 <botlish_fn_3+0x17d>
			dc1: R_X86_64_PLT32	rt_int_cmp-0x4
     dc5:	mov    edi,0x2
     dca:	test   rax,rax
     dcd:	cmovle rdi,QWORD PTR [rip+0x3eb]        # 11c0 <botlish_fn_3+0x578>
     dd5:	jmp    dee <botlish_fn_3+0x1a6>
     dda:	mov    edi,0x2
     ddf:	mov    rsi,r12
     de2:	cmp    rsi,0x5f
     de6:	cmovle rdi,QWORD PTR [rip+0x3d2]        # 11c0 <botlish_fn_3+0x578>
     dee:	cmp    rdi,0x6
     df2:	je     1154 <botlish_fn_3+0x50c>
     df8:	mov    rsi,r12
     dfb:	test   rsi,0x1
     e02:	jne    e2d <botlish_fn_3+0x1e5>
     e08:	mov    edx,0x73
     e0d:	mov    rsi,r12
     e10:	mov    rdi,r13
     e13:	call   e18 <botlish_fn_3+0x1d0>
			e14: R_X86_64_PLT32	rt_int_cmp-0x4
     e18:	mov    ecx,0x2
     e1d:	test   rax,rax
     e20:	cmovle rcx,QWORD PTR [rip+0x398]        # 11c0 <botlish_fn_3+0x578>
     e28:	jmp    e41 <botlish_fn_3+0x1f9>
     e2d:	mov    ecx,0x2
     e32:	mov    rsi,r12
     e35:	cmp    rsi,0x73
     e39:	cmovle rcx,QWORD PTR [rip+0x37f]        # 11c0 <botlish_fn_3+0x578>
     e41:	cmp    rcx,0x6
     e45:	je     114c <botlish_fn_3+0x504>
     e4b:	mov    rsi,r12
     e4e:	test   rsi,0x1
     e55:	jne    e80 <botlish_fn_3+0x238>
     e5b:	mov    edx,0x81
     e60:	mov    rsi,r12
     e63:	mov    rdi,r13
     e66:	call   e6b <botlish_fn_3+0x223>
			e67: R_X86_64_PLT32	rt_int_cmp-0x4
     e6b:	mov    ecx,0x2
     e70:	test   rax,rax
     e73:	cmovle rcx,QWORD PTR [rip+0x345]        # 11c0 <botlish_fn_3+0x578>
     e7b:	jmp    e97 <botlish_fn_3+0x24f>
     e80:	mov    ecx,0x2
     e85:	mov    rsi,r12
     e88:	cmp    rsi,0x81
     e8f:	cmovle rcx,QWORD PTR [rip+0x329]        # 11c0 <botlish_fn_3+0x578>
     e97:	cmp    rcx,0x6
     e9b:	je     1142 <botlish_fn_3+0x4fa>
     ea1:	mov    rsi,r12
     ea4:	test   rsi,0x1
     eab:	jne    ed6 <botlish_fn_3+0x28e>
     eb1:	mov    edx,0xb5
     eb6:	mov    rsi,r12
     eb9:	mov    rdi,r13
     ebc:	call   ec1 <botlish_fn_3+0x279>
			ebd: R_X86_64_PLT32	rt_int_cmp-0x4
     ec1:	mov    ecx,0x2
     ec6:	test   rax,rax
     ec9:	cmovle rcx,QWORD PTR [rip+0x2ef]        # 11c0 <botlish_fn_3+0x578>
     ed1:	jmp    eed <botlish_fn_3+0x2a5>
     ed6:	mov    ecx,0x2
     edb:	mov    rsi,r12
     ede:	cmp    rsi,0xb5
     ee5:	cmovle rcx,QWORD PTR [rip+0x2d3]        # 11c0 <botlish_fn_3+0x578>
     eed:	cmp    rcx,0x6
     ef1:	je     113a <botlish_fn_3+0x4f2>
     ef7:	mov    rsi,r12
     efa:	test   rsi,0x1
     f01:	jne    f2c <botlish_fn_3+0x2e4>
     f07:	mov    edx,0xbd
     f0c:	mov    rsi,r12
     f0f:	mov    rdi,r13
     f12:	call   f17 <botlish_fn_3+0x2cf>
			f13: R_X86_64_PLT32	rt_int_cmp-0x4
     f17:	mov    esi,0x2
     f1c:	test   rax,rax
     f1f:	cmovle rsi,QWORD PTR [rip+0x299]        # 11c0 <botlish_fn_3+0x578>
     f27:	jmp    f42 <botlish_fn_3+0x2fa>
     f2c:	mov    esi,0x2
     f31:	mov    rax,r12
     f34:	cmp    rax,0xbd
     f3a:	cmovle rsi,QWORD PTR [rip+0x27e]        # 11c0 <botlish_fn_3+0x578>
     f42:	cmp    rsi,0x6
     f46:	je     1130 <botlish_fn_3+0x4e8>
     f4c:	mov    rsi,r12
     f4f:	test   rsi,0x1
     f56:	jne    f81 <botlish_fn_3+0x339>
     f5c:	mov    edx,0xbf
     f61:	mov    rsi,r12
     f64:	mov    rdi,r13
     f67:	call   f6c <botlish_fn_3+0x324>
			f68: R_X86_64_PLT32	rt_int_cmp-0x4
     f6c:	mov    ecx,0x2
     f71:	test   rax,rax
     f74:	cmovle rcx,QWORD PTR [rip+0x244]        # 11c0 <botlish_fn_3+0x578>
     f7c:	jmp    f98 <botlish_fn_3+0x350>
     f81:	mov    ecx,0x2
     f86:	mov    rsi,r12
     f89:	cmp    rsi,0xbf
     f90:	cmovle rcx,QWORD PTR [rip+0x228]        # 11c0 <botlish_fn_3+0x578>
     f98:	cmp    rcx,0x6
     f9c:	je     1128 <botlish_fn_3+0x4e0>
     fa2:	mov    rsi,r12
     fa5:	test   rsi,0x1
     fac:	jne    fd7 <botlish_fn_3+0x38f>
     fb2:	mov    edx,0xc1
     fb7:	mov    rsi,r12
     fba:	mov    rdi,r13
     fbd:	call   fc2 <botlish_fn_3+0x37a>
			fbe: R_X86_64_PLT32	rt_int_cmp-0x4
     fc2:	mov    ecx,0x2
     fc7:	test   rax,rax
     fca:	cmovle rcx,QWORD PTR [rip+0x1ee]        # 11c0 <botlish_fn_3+0x578>
     fd2:	jmp    fee <botlish_fn_3+0x3a6>
     fd7:	mov    ecx,0x2
     fdc:	mov    rsi,r12
     fdf:	cmp    rsi,0xc1
     fe6:	cmovle rcx,QWORD PTR [rip+0x1d2]        # 11c0 <botlish_fn_3+0x578>
     fee:	cmp    rcx,0x6
     ff2:	je     111e <botlish_fn_3+0x4d6>
     ff8:	mov    rsi,r12
     ffb:	test   rsi,0x1
    1002:	jne    102d <botlish_fn_3+0x3e5>
    1008:	mov    edx,0xf5
    100d:	mov    rsi,r12
    1010:	mov    rdi,r13
    1013:	call   1018 <botlish_fn_3+0x3d0>
			1014: R_X86_64_PLT32	rt_int_cmp-0x4
    1018:	mov    ecx,0x2
    101d:	test   rax,rax
    1020:	cmovle rcx,QWORD PTR [rip+0x198]        # 11c0 <botlish_fn_3+0x578>
    1028:	jmp    1044 <botlish_fn_3+0x3fc>
    102d:	mov    ecx,0x2
    1032:	mov    rsi,r12
    1035:	cmp    rsi,0xf5
    103c:	cmovle rcx,QWORD PTR [rip+0x17c]        # 11c0 <botlish_fn_3+0x578>
    1044:	cmp    rcx,0x6
    1048:	je     1116 <botlish_fn_3+0x4ce>
    104e:	mov    rsi,r12
    1051:	test   rsi,0x1
    1058:	jne    1083 <botlish_fn_3+0x43b>
    105e:	mov    edx,0xfb
    1063:	mov    rsi,r12
    1066:	mov    rdi,r13
    1069:	call   106e <botlish_fn_3+0x426>
			106a: R_X86_64_PLT32	rt_int_cmp-0x4
    106e:	mov    ecx,0x2
    1073:	test   rax,rax
    1076:	cmovle rcx,QWORD PTR [rip+0x142]        # 11c0 <botlish_fn_3+0x578>
    107e:	jmp    109a <botlish_fn_3+0x452>
    1083:	mov    ecx,0x2
    1088:	mov    rsi,r12
    108b:	cmp    rsi,0xfb
    1092:	cmovle rcx,QWORD PTR [rip+0x126]        # 11c0 <botlish_fn_3+0x578>
    109a:	cmp    rcx,0x6
    109e:	je     110c <botlish_fn_3+0x4c4>
    10a4:	mov    rsi,r12
    10a7:	test   rsi,0x1
    10ae:	jne    10d9 <botlish_fn_3+0x491>
    10b4:	mov    edx,0xfd
    10b9:	mov    rsi,r12
    10bc:	mov    rdi,r13
    10bf:	call   10c4 <botlish_fn_3+0x47c>
			10c0: R_X86_64_PLT32	rt_int_cmp-0x4
    10c4:	mov    ecx,0x2
    10c9:	test   rax,rax
    10cc:	cmovle rcx,QWORD PTR [rip+0xec]        # 11c0 <botlish_fn_3+0x578>
    10d4:	jmp    10f0 <botlish_fn_3+0x4a8>
    10d9:	mov    ecx,0x2
    10de:	mov    rsi,r12
    10e1:	cmp    rsi,0xfd
    10e8:	cmovle rcx,QWORD PTR [rip+0xd0]        # 11c0 <botlish_fn_3+0x578>
    10f0:	cmp    rcx,0x6
    10f4:	je     1104 <botlish_fn_3+0x4bc>
    10fa:	mov    eax,0x2
    10ff:	jmp    1161 <botlish_fn_3+0x519>
    1104:	mov    rax,r14
    1107:	jmp    1161 <botlish_fn_3+0x519>
    110c:	mov    eax,0x2
    1111:	jmp    1161 <botlish_fn_3+0x519>
    1116:	mov    rax,r14
    1119:	jmp    1161 <botlish_fn_3+0x519>
    111e:	mov    eax,0x2
    1123:	jmp    1161 <botlish_fn_3+0x519>
    1128:	mov    rax,r14
    112b:	jmp    1161 <botlish_fn_3+0x519>
    1130:	mov    eax,0x2
    1135:	jmp    1161 <botlish_fn_3+0x519>
    113a:	mov    rax,r14
    113d:	jmp    1161 <botlish_fn_3+0x519>
    1142:	mov    eax,0x2
    1147:	jmp    1161 <botlish_fn_3+0x519>
    114c:	mov    rax,r14
    114f:	jmp    1161 <botlish_fn_3+0x519>
    1154:	mov    eax,0x2
    1159:	jmp    1161 <botlish_fn_3+0x519>
    115e:	mov    rax,r14
    1161:	mov    rdi,r13
    1164:	jmp    1171 <botlish_fn_3+0x529>
    1169:	mov    eax,0x2
    116e:	mov    rdi,r13
    1171:	mov    rdi,r13
    1174:	mov    QWORD PTR [rdi],rbx
    1177:	mov    rbx,QWORD PTR [rsp]
    117b:	mov    r12,QWORD PTR [rsp+0x8]
    1180:	mov    r13,QWORD PTR [rsp+0x10]
    1185:	mov    r14,QWORD PTR [rsp+0x18]
    118a:	add    rsp,0x20
    118e:	mov    rsp,rbp
    1191:	pop    rbp
    1192:	ret
    1193:	mov    r13,rdi
    1196:	call   119b <botlish_fn_3+0x553>
			1197: R_X86_64_PLT32	rt_stack_overflow-0x4
    119b:	xor    rax,rax
    119e:	mov    rbx,QWORD PTR [rsp]
    11a2:	mov    r12,QWORD PTR [rsp+0x8]
    11a7:	mov    r13,QWORD PTR [rsp+0x10]
    11ac:	mov    r14,QWORD PTR [rsp+0x18]
    11b1:	add    rsp,0x20
    11b5:	mov    rsp,rbp
    11b8:	pop    rbp
    11b9:	ret
    11ba:	add    BYTE PTR [rax],al
    11bc:	add    BYTE PTR [rax],al
    11be:	add    BYTE PTR [rax],al
    11c0:	(bad)
    11c1:	add    BYTE PTR [rax],al
    11c3:	add    BYTE PTR [rax],al
    11c5:	add    BYTE PTR [rax],al
	...

00000000000011c8 <botlish_entry_3: is_unreserved<generic>>:
    11c8:	push   rbp
    11c9:	mov    rbp,rsp
    11cc:	mov    rsi,QWORD PTR [rdx]
    11cf:	call   11d4 <botlish_entry_3+0xc>
			11d0: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    11d4:	mov    rsp,rbp
    11d7:	pop    rbp
    11d8:	ret

00000000000011d9 <botlish_fn_4: hex_pair<generic>>:
    11d9:	push   rbp
    11da:	mov    rbp,rsp
    11dd:	sub    rsp,0x30
    11e1:	mov    QWORD PTR [rsp],rbx
    11e5:	mov    QWORD PTR [rsp+0x8],r12
    11ea:	mov    QWORD PTR [rsp+0x10],r13
    11ef:	mov    QWORD PTR [rsp+0x18],r14
    11f4:	mov    QWORD PTR [rsp+0x20],r15
    11f9:	mov    r13,rdx
    11fc:	mov    rbx,QWORD PTR [rdi]
    11ff:	mov    rax,QWORD PTR [rdi+0x8]
    1203:	lea    rcx,[rbx+0x10]
    1207:	cmp    rcx,rax
    120a:	ja     1413 <botlish_fn_4+0x23a>
    1210:	lea    rax,[rbx+0x10]
    1214:	mov    QWORD PTR [rdi],rax
    1217:	mov    rdx,r13
    121a:	mov    r12,rdi
    121d:	mov    QWORD PTR [rbx],rdx
    1220:	mov    rax,QWORD PTR [rsi+0x20]
    1224:	mov    r14,rsi
    1227:	mov    rsi,QWORD PTR [rax]
    122a:	mov    QWORD PTR [rbx+0x8],rsi
    122e:	mov    r15,rsi
    1231:	mov    rsi,r13
    1234:	mov    rdi,r12
    1237:	call   123c <botlish_fn_4+0x63>
			1238: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
    123c:	test   rax,rax
    123f:	jne    124d <botlish_fn_4+0x74>
    1245:	mov    rdi,r12
    1248:	jmp    13c2 <botlish_fn_4+0x1e9>
    124d:	test   rax,0x1
    1253:	jne    1264 <botlish_fn_4+0x8b>
    1259:	mov    rdx,rax
    125c:	mov    rsi,r15
    125f:	jmp    1280 <botlish_fn_4+0xa7>
    1264:	mov    rsi,r15
    1267:	mov    rdx,QWORD PTR [rsi+0x8]
    126b:	mov    rcx,rax
    126e:	sar    rcx,1
    1271:	mov    rdi,rax
    1274:	cmp    rcx,rdx
    1277:	jb     12a1 <botlish_fn_4+0xc8>
    127d:	mov    rdx,rdi
    1280:	mov    rdi,r12
    1283:	call   1288 <botlish_fn_4+0xaf>
			1284: R_X86_64_PLT32	rt_list_get-0x4
    1288:	test   rax,rax
    128b:	jne    1299 <botlish_fn_4+0xc0>
    1291:	mov    rdi,r12
    1294:	jmp    13c2 <botlish_fn_4+0x1e9>
    1299:	mov    rsi,rax
    129c:	jmp    12a9 <botlish_fn_4+0xd0>
    12a1:	mov    rax,QWORD PTR [rsi+0x10]
    12a5:	mov    rsi,QWORD PTR [rax+rcx*8]
    12a9:	mov    QWORD PTR [rbx],rsi
    12ac:	mov    rax,rsi
    12af:	mov    rsi,r14
    12b2:	mov    r14,rax
    12b5:	mov    rdx,QWORD PTR [rsi+0x20]
    12b9:	mov    rsi,QWORD PTR [rdx]
    12bc:	mov    r15,rsi
    12bf:	mov    ecx,0x1
    12c4:	mov    rdx,r13
    12c7:	test   rdx,0x1
    12ce:	je     12dc <botlish_fn_4+0x103>
    12d4:	mov    r13,rdx
    12d7:	jmp    1301 <botlish_fn_4+0x128>
    12dc:	xor    ecx,ecx
    12de:	test   rdx,0x7
    12e5:	je     12f3 <botlish_fn_4+0x11a>
    12eb:	mov    r13,rdx
    12ee:	jmp    1301 <botlish_fn_4+0x128>
    12f3:	movzx  r8,BYTE PTR [rdx]
    12f7:	mov    r13,rdx
    12fa:	cmp    r8b,0x1
    12fe:	sete   cl
    1301:	test   cl,cl
    1303:	jne    132a <botlish_fn_4+0x151>
    1309:	mov    rdi,r12
    130c:	mov    rax,QWORD PTR [rdi+0x10]
    1310:	mov    rcx,QWORD PTR [rax+0xa8]
    1317:	xor    rdx,rdx
    131a:	mov    rsi,r13
    131d:	call   1322 <botlish_fn_4+0x149>
			131e: R_X86_64_PLT32	rt_type_error-0x4
    1322:	mov    rdi,r12
    1325:	jmp    13c2 <botlish_fn_4+0x1e9>
    132a:	mov    rsi,r13
    132d:	mov    edx,0x21
    1332:	mov    rdi,r12
    1335:	call   133a <botlish_fn_4+0x161>
			1336: R_X86_64_PLT32	rt_int_mod-0x4
    133a:	test   rax,rax
    133d:	jne    134b <botlish_fn_4+0x172>
    1343:	mov    rdi,r12
    1346:	jmp    13c2 <botlish_fn_4+0x1e9>
    134b:	test   rax,0x1
    1351:	jne    1362 <botlish_fn_4+0x189>
    1357:	mov    rdx,rax
    135a:	mov    rsi,r15
    135d:	jmp    137e <botlish_fn_4+0x1a5>
    1362:	mov    rsi,r15
    1365:	mov    rdx,QWORD PTR [rsi+0x8]
    1369:	mov    rcx,rax
    136c:	sar    rcx,1
    136f:	mov    rdi,rax
    1372:	cmp    rcx,rdx
    1375:	jb     139f <botlish_fn_4+0x1c6>
    137b:	mov    rdx,rdi
    137e:	mov    rdi,r12
    1381:	call   1386 <botlish_fn_4+0x1ad>
			1382: R_X86_64_PLT32	rt_list_get-0x4
    1386:	test   rax,rax
    1389:	jne    1397 <botlish_fn_4+0x1be>
    138f:	mov    rdi,r12
    1392:	jmp    13c2 <botlish_fn_4+0x1e9>
    1397:	mov    rdx,rax
    139a:	jmp    13a7 <botlish_fn_4+0x1ce>
    139f:	mov    rax,QWORD PTR [rsi+0x10]
    13a3:	mov    rdx,QWORD PTR [rax+rcx*8]
    13a7:	mov    QWORD PTR [rbx+0x8],rdx
    13ab:	mov    rsi,r14
    13ae:	mov    rdi,r12
    13b1:	call   13b6 <botlish_fn_4+0x1dd>
			13b2: R_X86_64_PLT32	rt_str_cat-0x4
    13b6:	test   rax,rax
    13b9:	jne    13ec <botlish_fn_4+0x213>
    13bf:	mov    rdi,r12
    13c2:	mov    rdi,r12
    13c5:	mov    QWORD PTR [rdi],rbx
    13c8:	xor    rax,rax
    13cb:	mov    rbx,QWORD PTR [rsp]
    13cf:	mov    r12,QWORD PTR [rsp+0x8]
    13d4:	mov    r13,QWORD PTR [rsp+0x10]
    13d9:	mov    r14,QWORD PTR [rsp+0x18]
    13de:	mov    r15,QWORD PTR [rsp+0x20]
    13e3:	add    rsp,0x30
    13e7:	mov    rsp,rbp
    13ea:	pop    rbp
    13eb:	ret
    13ec:	mov    rdi,r12
    13ef:	mov    QWORD PTR [rdi],rbx
    13f2:	mov    rbx,QWORD PTR [rsp]
    13f6:	mov    r12,QWORD PTR [rsp+0x8]
    13fb:	mov    r13,QWORD PTR [rsp+0x10]
    1400:	mov    r14,QWORD PTR [rsp+0x18]
    1405:	mov    r15,QWORD PTR [rsp+0x20]
    140a:	add    rsp,0x30
    140e:	mov    rsp,rbp
    1411:	pop    rbp
    1412:	ret
    1413:	mov    r12,rdi
    1416:	call   141b <botlish_fn_4+0x242>
			1417: R_X86_64_PLT32	rt_stack_overflow-0x4
    141b:	xor    rax,rax
    141e:	mov    rbx,QWORD PTR [rsp]
    1422:	mov    r12,QWORD PTR [rsp+0x8]
    1427:	mov    r13,QWORD PTR [rsp+0x10]
    142c:	mov    r14,QWORD PTR [rsp+0x18]
    1431:	mov    r15,QWORD PTR [rsp+0x20]
    1436:	add    rsp,0x30
    143a:	mov    rsp,rbp
    143d:	pop    rbp
    143e:	ret

000000000000143f <botlish_entry_4: hex_pair<generic>>:
    143f:	push   rbp
    1440:	mov    rbp,rsp
    1443:	mov    rdx,QWORD PTR [rdx]
    1446:	call   144b <botlish_entry_4+0xc>
			1447: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    144b:	mov    rsp,rbp
    144e:	pop    rbp
    144f:	ret

0000000000001450 <botlish_fn_5: esc_bytes<generic>>:
    1450:	push   rbp
    1451:	mov    rbp,rsp
    1454:	sub    rsp,0x50
    1458:	mov    QWORD PTR [rsp+0x20],rbx
    145d:	mov    QWORD PTR [rsp+0x28],r12
    1462:	mov    QWORD PTR [rsp+0x30],r13
    1467:	mov    QWORD PTR [rsp+0x38],r14
    146c:	mov    QWORD PTR [rsp+0x40],r15
    1471:	mov    r15,rsi
    1474:	mov    r13,QWORD PTR [rdi]
    1477:	mov    r9,QWORD PTR [rdi+0x8]
    147b:	lea    r10,[r13+0x38]
    147f:	cmp    r10,r9
    1482:	ja     17c5 <botlish_fn_5+0x375>
    1488:	lea    r10,[r13+0x38]
    148c:	mov    QWORD PTR [rdi],r10
    148f:	mov    r14,rdi
    1492:	mov    QWORD PTR [r13+0x28],0x0
    149a:	mov    QWORD PTR [r13+0x30],0x0
    14a2:	mov    QWORD PTR [r13+0x0],rdx
    14a6:	mov    QWORD PTR [r13+0x8],rcx
    14aa:	mov    QWORD PTR [r13+0x10],r8
    14ae:	mov    QWORD PTR [rsp],rcx
    14b2:	mov    QWORD PTR [rsp+0x8],r8
    14b7:	xor    eax,eax
    14b9:	test   rdx,0x7
    14c0:	je     14ce <botlish_fn_5+0x7e>
    14c6:	mov    rsi,rdx
    14c9:	jmp    14da <botlish_fn_5+0x8a>
    14ce:	movzx  rax,BYTE PTR [rdx]
    14d2:	mov    rsi,rdx
    14d5:	cmp    al,0x3
    14d7:	sete   al
    14da:	test   al,al
    14dc:	jne    1502 <botlish_fn_5+0xb2>
    14e2:	mov    rdi,r14
    14e5:	mov    rax,QWORD PTR [rdi+0x10]
    14e9:	mov    rcx,QWORD PTR [rax+0xb0]
    14f0:	mov    edx,0x4
    14f5:	call   14fa <botlish_fn_5+0xaa>
			14f6: R_X86_64_PLT32	rt_type_error-0x4
    14fa:	mov    rdi,r14
    14fd:	jmp    1750 <botlish_fn_5+0x300>
    1502:	mov    rbx,rsi
    1505:	mov    rdi,r14
    1508:	call   150d <botlish_fn_5+0xbd>
			1509: R_X86_64_PLT32	rt_list_len-0x4
    150d:	mov    ecx,0x1
    1512:	mov    rsi,QWORD PTR [rsp]
    1516:	test   rsi,0x1
    151d:	jne    1545 <botlish_fn_5+0xf5>
    1523:	xor    ecx,ecx
    1525:	mov    rsi,QWORD PTR [rsp]
    1529:	test   rsi,0x7
    1530:	jne    1545 <botlish_fn_5+0xf5>
    1536:	mov    rsi,QWORD PTR [rsp]
    153a:	movzx  rcx,BYTE PTR [rsi]
    153e:	rex cmp cl,0x1
    1542:	sete   cl
    1545:	test   cl,cl
    1547:	jne    156f <botlish_fn_5+0x11f>
    154d:	mov    rdi,r14
    1550:	mov    rax,QWORD PTR [rdi+0x10]
    1554:	mov    rcx,QWORD PTR [rax+0xb8]
    155b:	xor    rdx,rdx
    155e:	mov    rsi,QWORD PTR [rsp]
    1562:	call   1567 <botlish_fn_5+0x117>
			1563: R_X86_64_PLT32	rt_type_error-0x4
    1567:	mov    rdi,r14
    156a:	jmp    1750 <botlish_fn_5+0x300>
    156f:	mov    rsi,QWORD PTR [rsp]
    1573:	mov    rcx,rsi
    1576:	and    rcx,rax
    1579:	mov    rdx,rax
    157c:	test   rcx,0x1
    1583:	jne    15aa <botlish_fn_5+0x15a>
    1589:	mov    rsi,QWORD PTR [rsp]
    158d:	mov    rdi,r14
    1590:	call   1595 <botlish_fn_5+0x145>
			1591: R_X86_64_PLT32	rt_int_cmp-0x4
    1595:	mov    esi,0x2
    159a:	test   rax,rax
    159d:	cmovge rsi,QWORD PTR [rip+0x253]        # 17f8 <botlish_fn_5+0x3a8>
    15a5:	jmp    15be <botlish_fn_5+0x16e>
    15aa:	mov    esi,0x2
    15af:	mov    rax,QWORD PTR [rsp]
    15b3:	cmp    rax,rdx
    15b6:	cmovge rsi,QWORD PTR [rip+0x23a]        # 17f8 <botlish_fn_5+0x3a8>
    15be:	cmp    rsi,0x6
    15c2:	je     1798 <botlish_fn_5+0x348>
    15c8:	mov    QWORD PTR [r13+0x18],r15
    15cc:	mov    QWORD PTR [r13+0x20],0x3
    15d4:	mov    rsi,QWORD PTR [rsp]
    15d8:	test   rsi,0x1
    15df:	je     1606 <botlish_fn_5+0x1b6>
    15e5:	mov    rsi,QWORD PTR [rsp]
    15e9:	mov    rax,rsi
    15ec:	add    rax,0x2
    15f0:	mov    rcx,rax
    15f3:	seto   al
    15f6:	test   al,al
    15f8:	jne    1606 <botlish_fn_5+0x1b6>
    15fe:	mov    r12,rcx
    1601:	jmp    161d <botlish_fn_5+0x1cd>
    1606:	mov    edx,0x3
    160b:	mov    rsi,QWORD PTR [rsp]
    160f:	mov    rdi,r14
    1612:	call   1617 <botlish_fn_5+0x1c7>
			1613: R_X86_64_PLT32	rt_int_add-0x4
    1617:	mov    rcx,rax
    161a:	mov    r12,rcx
    161d:	mov    QWORD PTR [r13+0x8],r12
    1621:	mov    rdi,r14
    1624:	mov    rax,QWORD PTR [rdi+0x10]
    1628:	mov    rsi,QWORD PTR [rax+0xc0]
    162f:	mov    QWORD PTR [r13+0x20],rsi
    1633:	mov    QWORD PTR [rsp+0x18],rsi
    1638:	mov    rax,QWORD PTR [r15+0x20]
    163c:	mov    rsi,QWORD PTR [rax]
    163f:	mov    QWORD PTR [r13+0x28],rsi
    1643:	mov    QWORD PTR [rsp+0x10],rsi
    1648:	mov    rsi,QWORD PTR [rsp]
    164c:	test   rsi,0x1
    1653:	jne    1662 <botlish_fn_5+0x212>
    1659:	mov    rdx,QWORD PTR [rsp]
    165d:	jmp    167d <botlish_fn_5+0x22d>
    1662:	mov    rcx,QWORD PTR [rbx+0x8]
    1666:	mov    rsi,QWORD PTR [rsp]
    166a:	mov    rax,rsi
    166d:	sar    rax,1
    1670:	cmp    rax,rcx
    1673:	jb     16a1 <botlish_fn_5+0x251>
    1679:	mov    rdx,QWORD PTR [rsp]
    167d:	mov    rsi,rbx
    1680:	mov    rdi,r14
    1683:	call   1688 <botlish_fn_5+0x238>
			1684: R_X86_64_PLT32	rt_list_get-0x4
    1688:	test   rax,rax
    168b:	jne    1699 <botlish_fn_5+0x249>
    1691:	mov    rdi,r14
    1694:	jmp    1750 <botlish_fn_5+0x300>
    1699:	mov    rdx,rax
    169c:	jmp    16a9 <botlish_fn_5+0x259>
    16a1:	mov    rsi,QWORD PTR [rbx+0x10]
    16a5:	mov    rdx,QWORD PTR [rsi+rax*8]
    16a9:	mov    QWORD PTR [r13+0x30],rdx
    16ad:	mov    rsi,QWORD PTR [rsp+0x10]
    16b2:	mov    rdi,r14
    16b5:	call   16ba <botlish_fn_5+0x26a>
			16b6: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    16ba:	test   rax,rax
    16bd:	jne    16cb <botlish_fn_5+0x27b>
    16c3:	mov    rdi,r14
    16c6:	jmp    1750 <botlish_fn_5+0x300>
    16cb:	mov    QWORD PTR [r13+0x28],rax
    16cf:	mov    rdx,rax
    16d2:	mov    rsi,QWORD PTR [rsp+0x18]
    16d7:	mov    rdi,r14
    16da:	call   16df <botlish_fn_5+0x28f>
			16db: R_X86_64_PLT32	rt_str_cat-0x4
    16df:	test   rax,rax
    16e2:	jne    16f0 <botlish_fn_5+0x2a0>
    16e8:	mov    rdi,r14
    16eb:	jmp    1750 <botlish_fn_5+0x300>
    16f0:	mov    QWORD PTR [r13+0x20],rax
    16f4:	mov    rdx,rax
    16f7:	xor    eax,eax
    16f9:	mov    rsi,QWORD PTR [rsp+0x8]
    16fe:	test   rsi,0x7
    1705:	jne    1714 <botlish_fn_5+0x2c4>
    170b:	movzx  rax,BYTE PTR [rsi]
    170f:	cmp    al,0x2
    1711:	sete   al
    1714:	test   al,al
    1716:	jne    173c <botlish_fn_5+0x2ec>
    171c:	mov    rdi,r14
    171f:	mov    rax,QWORD PTR [rdi+0x10]
    1723:	mov    rcx,QWORD PTR [rax+0xc8]
    172a:	mov    edx,0x1
    172f:	call   1734 <botlish_fn_5+0x2e4>
			1730: R_X86_64_PLT32	rt_type_error-0x4
    1734:	mov    rdi,r14
    1737:	jmp    1750 <botlish_fn_5+0x300>
    173c:	mov    rdi,r14
    173f:	call   1744 <botlish_fn_5+0x2f4>
			1740: R_X86_64_PLT32	rt_str_cat-0x4
    1744:	test   rax,rax
    1747:	jne    177b <botlish_fn_5+0x32b>
    174d:	mov    rdi,r14
    1750:	mov    rdi,r14
    1753:	mov    QWORD PTR [rdi],r13
    1756:	xor    rax,rax
    1759:	mov    rbx,QWORD PTR [rsp+0x20]
    175e:	mov    r12,QWORD PTR [rsp+0x28]
    1763:	mov    r13,QWORD PTR [rsp+0x30]
    1768:	mov    r14,QWORD PTR [rsp+0x38]
    176d:	mov    r15,QWORD PTR [rsp+0x40]
    1772:	add    rsp,0x50
    1776:	mov    rsp,rbp
    1779:	pop    rbp
    177a:	ret
    177b:	mov    QWORD PTR [r13+0x0],rbx
    177f:	mov    QWORD PTR [r13+0x8],r12
    1783:	mov    QWORD PTR [r13+0x10],rax
    1787:	mov    rdx,rbx
    178a:	mov    QWORD PTR [rsp],r12
    178e:	mov    QWORD PTR [rsp+0x8],rax
    1793:	jmp    14b7 <botlish_fn_5+0x67>
    1798:	mov    rdi,r14
    179b:	mov    QWORD PTR [rdi],r13
    179e:	mov    rax,QWORD PTR [rsp+0x8]
    17a3:	mov    rbx,QWORD PTR [rsp+0x20]
    17a8:	mov    r12,QWORD PTR [rsp+0x28]
    17ad:	mov    r13,QWORD PTR [rsp+0x30]
    17b2:	mov    r14,QWORD PTR [rsp+0x38]
    17b7:	mov    r15,QWORD PTR [rsp+0x40]
    17bc:	add    rsp,0x50
    17c0:	mov    rsp,rbp
    17c3:	pop    rbp
    17c4:	ret
    17c5:	mov    r14,rdi
    17c8:	call   17cd <botlish_fn_5+0x37d>
			17c9: R_X86_64_PLT32	rt_stack_overflow-0x4
    17cd:	xor    rax,rax
    17d0:	mov    rbx,QWORD PTR [rsp+0x20]
    17d5:	mov    r12,QWORD PTR [rsp+0x28]
    17da:	mov    r13,QWORD PTR [rsp+0x30]
    17df:	mov    r14,QWORD PTR [rsp+0x38]
    17e4:	mov    r15,QWORD PTR [rsp+0x40]
    17e9:	add    rsp,0x50
    17ed:	mov    rsp,rbp
    17f0:	pop    rbp
    17f1:	ret
    17f2:	add    BYTE PTR [rax],al
    17f4:	add    BYTE PTR [rax],al
    17f6:	add    BYTE PTR [rax],al
    17f8:	(bad)
    17f9:	add    BYTE PTR [rax],al
    17fb:	add    BYTE PTR [rax],al
    17fd:	add    BYTE PTR [rax],al
	...

0000000000001800 <botlish_entry_5: esc_bytes<generic>>:
    1800:	push   rbp
    1801:	mov    rbp,rsp
    1804:	mov    r9,QWORD PTR [rdx]
    1807:	mov    rcx,QWORD PTR [rdx+0x8]
    180b:	mov    r8,QWORD PTR [rdx+0x10]
    180f:	mov    rdx,r9
    1812:	call   1817 <botlish_entry_5+0x17>
			1813: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    1817:	mov    rsp,rbp
    181a:	pop    rbp
    181b:	ret

000000000000181c <botlish_fn_6: esc_char<generic>>:
    181c:	push   rbp
    181d:	mov    rbp,rsp
    1820:	sub    rsp,0x40
    1824:	mov    QWORD PTR [rsp+0x10],rbx
    1829:	mov    QWORD PTR [rsp+0x18],r12
    182e:	mov    QWORD PTR [rsp+0x20],r13
    1833:	mov    QWORD PTR [rsp+0x28],r14
    1838:	mov    QWORD PTR [rsp+0x30],r15
    183d:	mov    rbx,rsi
    1840:	mov    r12,QWORD PTR [rdi]
    1843:	mov    rax,QWORD PTR [rdi+0x8]
    1847:	lea    rcx,[r12+0x20]
    184c:	cmp    rcx,rax
    184f:	ja     1a6a <botlish_fn_6+0x24e>
    1855:	lea    rax,[r12+0x20]
    185a:	mov    QWORD PTR [rdi],rax
    185d:	mov    QWORD PTR [r12+0x8],0x0
    1866:	mov    QWORD PTR [r12+0x10],0x0
    186f:	mov    QWORD PTR [r12+0x18],0x0
    1878:	mov    QWORD PTR [r12],rdx
    187c:	xor    eax,eax
    187e:	test   rdx,0x7
    1885:	je     1893 <botlish_fn_6+0x77>
    188b:	mov    r14,rdx
    188e:	jmp    189f <botlish_fn_6+0x83>
    1893:	movzx  rax,BYTE PTR [rdx]
    1897:	mov    r14,rdx
    189a:	cmp    al,0x2
    189c:	sete   al
    189f:	test   al,al
    18a1:	jne    18ca <botlish_fn_6+0xae>
    18a7:	mov    rax,QWORD PTR [rdi+0x10]
    18ab:	mov    r13,rdi
    18ae:	mov    rcx,QWORD PTR [rax+0xd0]
    18b5:	mov    edx,0x1
    18ba:	mov    rsi,r14
    18bd:	call   18c2 <botlish_fn_6+0xa6>
			18be: R_X86_64_PLT32	rt_type_error-0x4
    18c2:	mov    rdi,r13
    18c5:	jmp    1a0c <botlish_fn_6+0x1f0>
    18ca:	mov    r13,rdi
    18cd:	mov    rsi,r14
    18d0:	call   18d5 <botlish_fn_6+0xb9>
			18d1: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    18d5:	mov    rcx,rax
    18d8:	mov    r15,rax
    18db:	test   rax,rcx
    18de:	jne    18ec <botlish_fn_6+0xd0>
    18e4:	mov    rdi,r13
    18e7:	jmp    1a0c <botlish_fn_6+0x1f0>
    18ec:	mov    rax,r15
    18ef:	mov    QWORD PTR [r12+0x8],rax
    18f4:	mov    rsi,r15
    18f7:	mov    rdi,r13
    18fa:	call   18ff <botlish_fn_6+0xe3>
			18fb: R_X86_64_PLT32	rt_list_len-0x4
    18ff:	mov    ecx,0x1
    1904:	sar    rax,1
    1907:	cmp    rax,0x1
    190b:	je     195c <botlish_fn_6+0x140>
    1911:	mov    rdx,QWORD PTR [rbx+0x20]
    1915:	mov    rsi,QWORD PTR [rdx]
    1918:	mov    QWORD PTR [r12],rsi
    191c:	mov    QWORD PTR [r12+0x10],0x1
    1925:	mov    rdi,r13
    1928:	mov    rdi,QWORD PTR [rdi+0x10]
    192c:	mov    r8,QWORD PTR [rdi+0x98]
    1933:	mov    QWORD PTR [r12+0x18],r8
    1938:	mov    rdx,r15
    193b:	mov    rdi,r13
    193e:	call   1943 <botlish_fn_6+0x127>
			193f: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    1943:	test   rax,rax
    1946:	jne    1954 <botlish_fn_6+0x138>
    194c:	mov    rdi,r13
    194f:	jmp    1a0c <botlish_fn_6+0x1f0>
    1954:	mov    rdi,r13
    1957:	jmp    1a42 <botlish_fn_6+0x226>
    195c:	mov    rdx,r15
    195f:	mov    QWORD PTR [rsp],rcx
    1963:	mov    r10,QWORD PTR [rdx+0x8]
    1967:	mov    r15,rdx
    196a:	test   r10,r10
    196d:	jne    199b <botlish_fn_6+0x17f>
    1973:	mov    rdx,QWORD PTR [rsp]
    1977:	mov    rsi,r15
    197a:	mov    rdi,r13
    197d:	call   1982 <botlish_fn_6+0x166>
			197e: R_X86_64_PLT32	rt_list_get-0x4
    1982:	test   rax,rax
    1985:	jne    1993 <botlish_fn_6+0x177>
    198b:	mov    rdi,r13
    198e:	jmp    1a0c <botlish_fn_6+0x1f0>
    1993:	mov    rsi,rax
    1996:	jmp    19a5 <botlish_fn_6+0x189>
    199b:	mov    rdx,r15
    199e:	mov    rax,QWORD PTR [rdx+0x10]
    19a2:	mov    rsi,QWORD PTR [rax]
    19a5:	mov    QWORD PTR [r12+0x10],rsi
    19aa:	mov    rdi,r13
    19ad:	call   19b2 <botlish_fn_6+0x196>
			19ae: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    19b2:	test   rax,rax
    19b5:	jne    19c3 <botlish_fn_6+0x1a7>
    19bb:	mov    rdi,r13
    19be:	jmp    1a0c <botlish_fn_6+0x1f0>
    19c3:	cmp    rax,0x6
    19c7:	je     1a3c <botlish_fn_6+0x220>
    19cd:	mov    rax,QWORD PTR [rbx+0x20]
    19d1:	mov    rsi,QWORD PTR [rax]
    19d4:	mov    QWORD PTR [r12],rsi
    19d8:	mov    QWORD PTR [r12+0x10],0x1
    19e1:	mov    rdi,r13
    19e4:	mov    rax,QWORD PTR [rdi+0x10]
    19e8:	mov    r8,QWORD PTR [rax+0x98]
    19ef:	mov    QWORD PTR [r12+0x18],r8
    19f4:	mov    rcx,QWORD PTR [rsp]
    19f8:	mov    rdx,r15
    19fb:	call   1a00 <botlish_fn_6+0x1e4>
			19fc: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    1a00:	test   rax,rax
    1a03:	jne    1a3f <botlish_fn_6+0x223>
    1a09:	mov    rdi,r13
    1a0c:	mov    rdi,r13
    1a0f:	mov    QWORD PTR [rdi],r12
    1a12:	xor    rax,rax
    1a15:	mov    rbx,QWORD PTR [rsp+0x10]
    1a1a:	mov    r12,QWORD PTR [rsp+0x18]
    1a1f:	mov    r13,QWORD PTR [rsp+0x20]
    1a24:	mov    r14,QWORD PTR [rsp+0x28]
    1a29:	mov    r15,QWORD PTR [rsp+0x30]
    1a2e:	add    rsp,0x40
    1a32:	mov    rsp,rbp
    1a35:	pop    rbp
    1a36:	ret
    1a37:	jmp    1a3f <botlish_fn_6+0x223>
    1a3c:	mov    rax,r14
    1a3f:	mov    rdi,r13
    1a42:	mov    rdi,r13
    1a45:	mov    QWORD PTR [rdi],r12
    1a48:	mov    rbx,QWORD PTR [rsp+0x10]
    1a4d:	mov    r12,QWORD PTR [rsp+0x18]
    1a52:	mov    r13,QWORD PTR [rsp+0x20]
    1a57:	mov    r14,QWORD PTR [rsp+0x28]
    1a5c:	mov    r15,QWORD PTR [rsp+0x30]
    1a61:	add    rsp,0x40
    1a65:	mov    rsp,rbp
    1a68:	pop    rbp
    1a69:	ret
    1a6a:	mov    r13,rdi
    1a6d:	call   1a72 <botlish_fn_6+0x256>
			1a6e: R_X86_64_PLT32	rt_stack_overflow-0x4
    1a72:	xor    rax,rax
    1a75:	mov    rbx,QWORD PTR [rsp+0x10]
    1a7a:	mov    r12,QWORD PTR [rsp+0x18]
    1a7f:	mov    r13,QWORD PTR [rsp+0x20]
    1a84:	mov    r14,QWORD PTR [rsp+0x28]
    1a89:	mov    r15,QWORD PTR [rsp+0x30]
    1a8e:	add    rsp,0x40
    1a92:	mov    rsp,rbp
    1a95:	pop    rbp
    1a96:	ret

0000000000001a97 <botlish_entry_6: esc_char<generic>>:
    1a97:	push   rbp
    1a98:	mov    rbp,rsp
    1a9b:	mov    rdx,QWORD PTR [rdx]
    1a9e:	call   1aa3 <botlish_entry_6+0xc>
			1a9f: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    1aa3:	mov    rsp,rbp
    1aa6:	pop    rbp
    1aa7:	ret

0000000000001aa8 <botlish_fn_7: esc_from<generic>>:
    1aa8:	push   rbp
    1aa9:	mov    rbp,rsp
    1aac:	sub    rsp,0x50
    1ab0:	mov    QWORD PTR [rsp+0x20],rbx
    1ab5:	mov    QWORD PTR [rsp+0x28],r12
    1aba:	mov    QWORD PTR [rsp+0x30],r13
    1abf:	mov    QWORD PTR [rsp+0x38],r14
    1ac4:	mov    QWORD PTR [rsp+0x40],r15
    1ac9:	mov    r12,rsi
    1acc:	mov    r14,QWORD PTR [rdi]
    1acf:	mov    rax,QWORD PTR [rdi+0x8]
    1ad3:	lea    rsi,[r14+0x38]
    1ad7:	cmp    rsi,rax
    1ada:	ja     1e49 <botlish_fn_7+0x3a1>
    1ae0:	lea    rax,[r14+0x38]
    1ae4:	mov    QWORD PTR [rdi],rax
    1ae7:	mov    r15,rdi
    1aea:	mov    QWORD PTR [r14+0x28],0x0
    1af2:	mov    QWORD PTR [r14+0x30],0x0
    1afa:	mov    QWORD PTR [r14],rdx
    1afd:	mov    QWORD PTR [r14+0x8],rcx
    1b01:	mov    QWORD PTR [r14+0x10],r8
    1b05:	mov    QWORD PTR [rsp],rcx
    1b09:	mov    QWORD PTR [rsp+0x8],r8
    1b0e:	xor    eax,eax
    1b10:	test   rdx,0x7
    1b17:	je     1b25 <botlish_fn_7+0x7d>
    1b1d:	mov    rsi,rdx
    1b20:	jmp    1b31 <botlish_fn_7+0x89>
    1b25:	movzx  rax,BYTE PTR [rdx]
    1b29:	mov    rsi,rdx
    1b2c:	cmp    al,0x2
    1b2e:	sete   al
    1b31:	test   al,al
    1b33:	jne    1b59 <botlish_fn_7+0xb1>
    1b39:	mov    rdi,r15
    1b3c:	mov    rax,QWORD PTR [rdi+0x10]
    1b40:	mov    rcx,QWORD PTR [rax+0xd8]
    1b47:	mov    edx,0x1
    1b4c:	call   1b51 <botlish_fn_7+0xa9>
			1b4d: R_X86_64_PLT32	rt_type_error-0x4
    1b51:	mov    rdi,r15
    1b54:	jmp    1dd5 <botlish_fn_7+0x32d>
    1b59:	mov    rbx,rsi
    1b5c:	mov    rdi,r15
    1b5f:	call   1b64 <botlish_fn_7+0xbc>
			1b60: R_X86_64_PLT32	rt_str_len-0x4
    1b64:	mov    edx,0x1
    1b69:	mov    QWORD PTR [rsp+0x18],rdx
    1b6e:	mov    ecx,0x1
    1b73:	mov    rsi,QWORD PTR [rsp]
    1b77:	test   rsi,0x1
    1b7e:	jne    1ba6 <botlish_fn_7+0xfe>
    1b84:	xor    ecx,ecx
    1b86:	mov    rsi,QWORD PTR [rsp]
    1b8a:	test   rsi,0x7
    1b91:	jne    1ba6 <botlish_fn_7+0xfe>
    1b97:	mov    rsi,QWORD PTR [rsp]
    1b9b:	movzx  rcx,BYTE PTR [rsi]
    1b9f:	rex cmp cl,0x1
    1ba3:	sete   cl
    1ba6:	test   cl,cl
    1ba8:	jne    1bd0 <botlish_fn_7+0x128>
    1bae:	mov    rdi,r15
    1bb1:	mov    rax,QWORD PTR [rdi+0x10]
    1bb5:	mov    rcx,QWORD PTR [rax+0xb8]
    1bbc:	xor    rdx,rdx
    1bbf:	mov    rsi,QWORD PTR [rsp]
    1bc3:	call   1bc8 <botlish_fn_7+0x120>
			1bc4: R_X86_64_PLT32	rt_type_error-0x4
    1bc8:	mov    rdi,r15
    1bcb:	jmp    1dd5 <botlish_fn_7+0x32d>
    1bd0:	mov    rsi,QWORD PTR [rsp]
    1bd4:	mov    rcx,rsi
    1bd7:	and    rcx,rax
    1bda:	mov    rdx,rax
    1bdd:	test   rcx,0x1
    1be4:	jne    1c0b <botlish_fn_7+0x163>
    1bea:	mov    rsi,QWORD PTR [rsp]
    1bee:	mov    rdi,r15
    1bf1:	call   1bf6 <botlish_fn_7+0x14e>
			1bf2: R_X86_64_PLT32	rt_int_cmp-0x4
    1bf6:	mov    esi,0x2
    1bfb:	test   rax,rax
    1bfe:	cmovge rsi,QWORD PTR [rip+0x272]        # 1e78 <botlish_fn_7+0x3d0>
    1c06:	jmp    1c1f <botlish_fn_7+0x177>
    1c0b:	mov    esi,0x2
    1c10:	mov    rax,QWORD PTR [rsp]
    1c14:	cmp    rax,rdx
    1c17:	cmovge rsi,QWORD PTR [rip+0x259]        # 1e78 <botlish_fn_7+0x3d0>
    1c1f:	cmp    rsi,0x6
    1c23:	je     1e1c <botlish_fn_7+0x374>
    1c29:	mov    QWORD PTR [r14+0x18],r12
    1c2d:	mov    QWORD PTR [r14+0x20],0x3
    1c35:	mov    rsi,QWORD PTR [rsp]
    1c39:	test   rsi,0x1
    1c40:	je     1c67 <botlish_fn_7+0x1bf>
    1c46:	mov    rsi,QWORD PTR [rsp]
    1c4a:	mov    rax,rsi
    1c4d:	add    rax,0x2
    1c51:	mov    rcx,rax
    1c54:	seto   al
    1c57:	test   al,al
    1c59:	jne    1c67 <botlish_fn_7+0x1bf>
    1c5f:	mov    r13,rcx
    1c62:	jmp    1c7e <botlish_fn_7+0x1d6>
    1c67:	mov    edx,0x3
    1c6c:	mov    rsi,QWORD PTR [rsp]
    1c70:	mov    rdi,r15
    1c73:	call   1c78 <botlish_fn_7+0x1d0>
			1c74: R_X86_64_PLT32	rt_int_add-0x4
    1c78:	mov    rcx,rax
    1c7b:	mov    r13,rcx
    1c7e:	mov    QWORD PTR [r14+0x20],r13
    1c82:	mov    rax,QWORD PTR [r12+0x20]
    1c87:	mov    rsi,QWORD PTR [rax]
    1c8a:	mov    QWORD PTR [r14+0x28],rsi
    1c8e:	mov    QWORD PTR [rsp+0x10],rsi
    1c93:	mov    QWORD PTR [r14+0x30],0x3
    1c9b:	mov    rsi,QWORD PTR [rsp]
    1c9f:	test   rsi,0x1
    1ca6:	je     1cc4 <botlish_fn_7+0x21c>
    1cac:	mov    rsi,QWORD PTR [rsp]
    1cb0:	mov    rcx,rsi
    1cb3:	add    rcx,0x2
    1cb7:	seto   sil
    1cbb:	test   sil,sil
    1cbe:	je     1cd8 <botlish_fn_7+0x230>
    1cc4:	mov    edx,0x3
    1cc9:	mov    rsi,QWORD PTR [rsp]
    1ccd:	mov    rdi,r15
    1cd0:	call   1cd5 <botlish_fn_7+0x22d>
			1cd1: R_X86_64_PLT32	rt_int_add-0x4
    1cd5:	mov    rcx,rax
    1cd8:	mov    QWORD PTR [r14+0x30],rcx
    1cdc:	mov    rdx,QWORD PTR [rsp]
    1ce0:	mov    rsi,rbx
    1ce3:	mov    rdi,r15
    1ce6:	call   1ceb <botlish_fn_7+0x243>
			1ce7: R_X86_64_PLT32	rt_substr-0x4
    1ceb:	test   rax,rax
    1cee:	jne    1cfc <botlish_fn_7+0x254>
    1cf4:	mov    rdi,r15
    1cf7:	jmp    1dd5 <botlish_fn_7+0x32d>
    1cfc:	mov    QWORD PTR [r14+0x8],rax
    1d00:	mov    rdx,rax
    1d03:	mov    rsi,QWORD PTR [rsp+0x10]
    1d08:	mov    rdi,r15
    1d0b:	call   1d10 <botlish_fn_7+0x268>
			1d0c: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    1d10:	test   rax,rax
    1d13:	jne    1d21 <botlish_fn_7+0x279>
    1d19:	mov    rdi,r15
    1d1c:	jmp    1dd5 <botlish_fn_7+0x32d>
    1d21:	mov    QWORD PTR [r14+0x8],rax
    1d25:	xor    ecx,ecx
    1d27:	mov    rsi,QWORD PTR [rsp+0x8]
    1d2c:	test   rsi,0x7
    1d33:	jne    1d44 <botlish_fn_7+0x29c>
    1d39:	movzx  rcx,BYTE PTR [rsi]
    1d3d:	rex cmp cl,0x2
    1d41:	sete   cl
    1d44:	test   cl,cl
    1d46:	jne    1d6c <botlish_fn_7+0x2c4>
    1d4c:	mov    rdi,r15
    1d4f:	mov    rax,QWORD PTR [rdi+0x10]
    1d53:	mov    rcx,QWORD PTR [rax+0xc8]
    1d5a:	mov    rdx,QWORD PTR [rsp+0x18]
    1d5f:	call   1d64 <botlish_fn_7+0x2bc>
			1d60: R_X86_64_PLT32	rt_type_error-0x4
    1d64:	mov    rdi,r15
    1d67:	jmp    1dd5 <botlish_fn_7+0x32d>
    1d6c:	mov    rdx,QWORD PTR [rsp+0x18]
    1d71:	xor    r11d,r11d
    1d74:	test   rax,0x7
    1d7a:	je     1d88 <botlish_fn_7+0x2e0>
    1d80:	mov    r8,rax
    1d83:	jmp    1d97 <botlish_fn_7+0x2ef>
    1d88:	movzx  rcx,BYTE PTR [rax]
    1d8c:	mov    r8,rax
    1d8f:	rex cmp cl,0x2
    1d93:	sete   r11b
    1d97:	test   r11b,r11b
    1d9a:	jne    1dbe <botlish_fn_7+0x316>
    1da0:	mov    rdi,r15
    1da3:	mov    rax,QWORD PTR [rdi+0x10]
    1da7:	mov    rcx,QWORD PTR [rax+0xc8]
    1dae:	mov    rsi,r8
    1db1:	call   1db6 <botlish_fn_7+0x30e>
			1db2: R_X86_64_PLT32	rt_type_error-0x4
    1db6:	mov    rdi,r15
    1db9:	jmp    1dd5 <botlish_fn_7+0x32d>
    1dbe:	mov    rdx,r8
    1dc1:	mov    rdi,r15
    1dc4:	call   1dc9 <botlish_fn_7+0x321>
			1dc5: R_X86_64_PLT32	rt_str_cat-0x4
    1dc9:	test   rax,rax
    1dcc:	jne    1e00 <botlish_fn_7+0x358>
    1dd2:	mov    rdi,r15
    1dd5:	mov    rdi,r15
    1dd8:	mov    QWORD PTR [rdi],r14
    1ddb:	xor    rax,rax
    1dde:	mov    rbx,QWORD PTR [rsp+0x20]
    1de3:	mov    r12,QWORD PTR [rsp+0x28]
    1de8:	mov    r13,QWORD PTR [rsp+0x30]
    1ded:	mov    r14,QWORD PTR [rsp+0x38]
    1df2:	mov    r15,QWORD PTR [rsp+0x40]
    1df7:	add    rsp,0x50
    1dfb:	mov    rsp,rbp
    1dfe:	pop    rbp
    1dff:	ret
    1e00:	mov    QWORD PTR [r14],rbx
    1e03:	mov    QWORD PTR [r14+0x8],r13
    1e07:	mov    QWORD PTR [r14+0x10],rax
    1e0b:	mov    rdx,rbx
    1e0e:	mov    QWORD PTR [rsp],r13
    1e12:	mov    QWORD PTR [rsp+0x8],rax
    1e17:	jmp    1b0e <botlish_fn_7+0x66>
    1e1c:	mov    rdi,r15
    1e1f:	mov    QWORD PTR [rdi],r14
    1e22:	mov    rax,QWORD PTR [rsp+0x8]
    1e27:	mov    rbx,QWORD PTR [rsp+0x20]
    1e2c:	mov    r12,QWORD PTR [rsp+0x28]
    1e31:	mov    r13,QWORD PTR [rsp+0x30]
    1e36:	mov    r14,QWORD PTR [rsp+0x38]
    1e3b:	mov    r15,QWORD PTR [rsp+0x40]
    1e40:	add    rsp,0x50
    1e44:	mov    rsp,rbp
    1e47:	pop    rbp
    1e48:	ret
    1e49:	mov    r15,rdi
    1e4c:	call   1e51 <botlish_fn_7+0x3a9>
			1e4d: R_X86_64_PLT32	rt_stack_overflow-0x4
    1e51:	xor    rax,rax
    1e54:	mov    rbx,QWORD PTR [rsp+0x20]
    1e59:	mov    r12,QWORD PTR [rsp+0x28]
    1e5e:	mov    r13,QWORD PTR [rsp+0x30]
    1e63:	mov    r14,QWORD PTR [rsp+0x38]
    1e68:	mov    r15,QWORD PTR [rsp+0x40]
    1e6d:	add    rsp,0x50
    1e71:	mov    rsp,rbp
    1e74:	pop    rbp
    1e75:	ret
    1e76:	add    BYTE PTR [rax],al
    1e78:	(bad)
    1e79:	add    BYTE PTR [rax],al
    1e7b:	add    BYTE PTR [rax],al
    1e7d:	add    BYTE PTR [rax],al
	...

0000000000001e80 <botlish_entry_7: esc_from<generic>>:
    1e80:	push   rbp
    1e81:	mov    rbp,rsp
    1e84:	mov    r9,QWORD PTR [rdx]
    1e87:	mov    rcx,QWORD PTR [rdx+0x8]
    1e8b:	mov    r8,QWORD PTR [rdx+0x10]
    1e8f:	mov    rdx,r9
    1e92:	call   1e97 <botlish_entry_7+0x17>
			1e93: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
    1e97:	mov    rsp,rbp
    1e9a:	pop    rbp
    1e9b:	ret
    1e9c:	add    BYTE PTR [rax],al
	...

0000000000001ea0 <botlish_fn_8: check<int, int, str, str>>:
    1ea0:	push   rbp
    1ea1:	mov    rbp,rsp
    1ea4:	sub    rsp,0x40
    1ea8:	mov    QWORD PTR [rsp+0x10],rbx
    1ead:	mov    QWORD PTR [rsp+0x18],r12
    1eb2:	mov    QWORD PTR [rsp+0x20],r13
    1eb7:	mov    QWORD PTR [rsp+0x28],r14
    1ebc:	mov    QWORD PTR [rsp+0x30],r15
    1ec1:	mov    r13,QWORD PTR [rdi]
    1ec4:	mov    rax,QWORD PTR [rdi+0x8]
    1ec8:	lea    r9,[r13+0x28]
    1ecc:	cmp    r9,rax
    1ecf:	ja     208b <botlish_fn_8+0x1eb>
    1ed5:	lea    rax,[r13+0x28]
    1ed9:	mov    QWORD PTR [rdi],rax
    1edc:	mov    r14,rdi
    1edf:	mov    QWORD PTR [r13+0x20],0x0
    1ee7:	mov    QWORD PTR [r13+0x0],rsi
    1eeb:	mov    QWORD PTR [r13+0x8],rdx
    1eef:	mov    QWORD PTR [r13+0x10],rcx
    1ef3:	mov    r12,rcx
    1ef6:	mov    QWORD PTR [r13+0x18],r8
    1efa:	mov    r15,r8
    1efd:	mov    rbx,rsi
    1f00:	mov    QWORD PTR [rsp],rdx
    1f04:	test   rbx,0x1
    1f0b:	jne    1f36 <botlish_fn_8+0x96>
    1f11:	mov    edx,0x1
    1f16:	mov    rsi,rbx
    1f19:	mov    rdi,r14
    1f1c:	call   1f21 <botlish_fn_8+0x81>
			1f1d: R_X86_64_PLT32	rt_int_cmp-0x4
    1f21:	mov    ecx,0x2
    1f26:	test   rax,rax
    1f29:	cmovle rcx,QWORD PTR [rip+0x187]        # 20b8 <botlish_fn_8+0x218>
    1f31:	jmp    1f47 <botlish_fn_8+0xa7>
    1f36:	mov    ecx,0x2
    1f3b:	cmp    rbx,0x1
    1f3f:	cmovle rcx,QWORD PTR [rip+0x171]        # 20b8 <botlish_fn_8+0x218>
    1f47:	cmp    rcx,0x6
    1f4b:	je     205f <botlish_fn_8+0x1bf>
    1f51:	mov    rdi,r14
    1f54:	mov    rax,QWORD PTR [rdi+0x10]
    1f58:	mov    rax,QWORD PTR [rax+0xe0]
    1f5f:	mov    rsi,r12
    1f62:	call   1f67 <botlish_fn_8+0xc7>
			1f63: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    1f67:	test   rax,rax
    1f6a:	jne    1f78 <botlish_fn_8+0xd8>
    1f70:	mov    rdi,r14
    1f73:	jmp    1fb6 <botlish_fn_8+0x116>
    1f78:	cmp    rax,0x6
    1f7c:	je     1f94 <botlish_fn_8+0xf4>
    1f82:	mov    edx,0x1
    1f87:	mov    QWORD PTR [r13+0x0],0x1
    1f8f:	jmp    1ffe <botlish_fn_8+0x15e>
    1f94:	mov    rdi,r14
    1f97:	mov    rsi,QWORD PTR [rdi+0x10]
    1f9b:	mov    rsi,QWORD PTR [rsi+0xe8]
    1fa2:	mov    rsi,r12
    1fa5:	call   1faa <botlish_fn_8+0x10a>
			1fa6: R_X86_64_PLT32	botlish_fn_20-0x4 ; <str>
    1faa:	test   rax,rax
    1fad:	jne    1fe1 <botlish_fn_8+0x141>
    1fb3:	mov    rdi,r14
    1fb6:	mov    rdi,r14
    1fb9:	mov    QWORD PTR [rdi],r13
    1fbc:	xor    rax,rax
    1fbf:	mov    rbx,QWORD PTR [rsp+0x10]
    1fc4:	mov    r12,QWORD PTR [rsp+0x18]
    1fc9:	mov    r13,QWORD PTR [rsp+0x20]
    1fce:	mov    r14,QWORD PTR [rsp+0x28]
    1fd3:	mov    r15,QWORD PTR [rsp+0x30]
    1fd8:	add    rsp,0x40
    1fdc:	mov    rsp,rbp
    1fdf:	pop    rbp
    1fe0:	ret
    1fe1:	cmp    rax,0x6
    1fe5:	je     1ff5 <botlish_fn_8+0x155>
    1feb:	mov    edx,0x1
    1ff0:	jmp    1ffa <botlish_fn_8+0x15a>
    1ff5:	mov    edx,0x3
    1ffa:	mov    QWORD PTR [r13+0x0],rdx
    1ffe:	sar    rbx,1
    2001:	sub    rbx,0x1
    2005:	shl    rbx,1
    2008:	or     rbx,0x1
    200c:	mov    QWORD PTR [r13+0x20],rbx
    2010:	mov    rsi,QWORD PTR [rsp]
    2014:	mov    rax,rsi
    2017:	and    rax,rdx
    201a:	test   rax,0x1
    2020:	je     203b <botlish_fn_8+0x19b>
    2026:	lea    rcx,[rdx-0x1]
    202a:	mov    rax,rsi
    202d:	add    rax,rcx
    2030:	seto   cl
    2033:	test   cl,cl
    2035:	je     2043 <botlish_fn_8+0x1a3>
    203b:	mov    rdi,r14
    203e:	call   2043 <botlish_fn_8+0x1a3>
			203f: R_X86_64_PLT32	rt_int_add-0x4
    2043:	mov    QWORD PTR [r13+0x0],rbx
    2047:	mov    QWORD PTR [r13+0x8],rax
    204b:	mov    QWORD PTR [r13+0x10],r12
    204f:	mov    r8,r15
    2052:	mov    QWORD PTR [r13+0x18],r8
    2056:	mov    QWORD PTR [rsp],rax
    205a:	jmp    1f04 <botlish_fn_8+0x64>
    205f:	mov    rdi,r14
    2062:	mov    QWORD PTR [rdi],r13
    2065:	mov    rax,QWORD PTR [rsp]
    2069:	mov    rbx,QWORD PTR [rsp+0x10]
    206e:	mov    r12,QWORD PTR [rsp+0x18]
    2073:	mov    r13,QWORD PTR [rsp+0x20]
    2078:	mov    r14,QWORD PTR [rsp+0x28]
    207d:	mov    r15,QWORD PTR [rsp+0x30]
    2082:	add    rsp,0x40
    2086:	mov    rsp,rbp
    2089:	pop    rbp
    208a:	ret
    208b:	mov    r14,rdi
    208e:	call   2093 <botlish_fn_8+0x1f3>
			208f: R_X86_64_PLT32	rt_stack_overflow-0x4
    2093:	xor    rax,rax
    2096:	mov    rbx,QWORD PTR [rsp+0x10]
    209b:	mov    r12,QWORD PTR [rsp+0x18]
    20a0:	mov    r13,QWORD PTR [rsp+0x20]
    20a5:	mov    r14,QWORD PTR [rsp+0x28]
    20aa:	mov    r15,QWORD PTR [rsp+0x30]
    20af:	add    rsp,0x40
    20b3:	mov    rsp,rbp
    20b6:	pop    rbp
    20b7:	ret
    20b8:	(bad)
    20b9:	add    BYTE PTR [rax],al
    20bb:	add    BYTE PTR [rax],al
    20bd:	add    BYTE PTR [rax],al
	...

00000000000020c0 <botlish_entry_8: check<int, int, str, str>>:
    20c0:	push   rbp
    20c1:	mov    rbp,rsp
    20c4:	mov    rsi,QWORD PTR [rdx]
    20c7:	mov    r9,QWORD PTR [rdx+0x8]
    20cb:	mov    rcx,QWORD PTR [rdx+0x10]
    20cf:	mov    r8,QWORD PTR [rdx+0x18]
    20d3:	mov    rdx,r9
    20d6:	call   20db <botlish_entry_8+0x1b>
			20d7: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
    20db:	mov    rsp,rbp
    20de:	pop    rbp
    20df:	ret

00000000000020e0 <botlish_fn_9: <str>>:
    20e0:	push   rbp
    20e1:	mov    rbp,rsp
    20e4:	sub    rsp,0xc0
    20eb:	mov    QWORD PTR [rsp+0x90],rbx
    20f3:	mov    QWORD PTR [rsp+0x98],r12
    20fb:	mov    QWORD PTR [rsp+0xa0],r13
    2103:	mov    QWORD PTR [rsp+0xa8],r14
    210b:	mov    QWORD PTR [rsp+0xb0],r15
    2113:	mov    r12,QWORD PTR [rdi]
    2116:	mov    rax,QWORD PTR [rdi+0x8]
    211a:	lea    rcx,[r12+0x28]
    211f:	cmp    rcx,rax
    2122:	ja     2534 <botlish_fn_9+0x454>
    2128:	lea    rax,[r12+0x28]
    212d:	mov    QWORD PTR [rdi],rax
    2130:	mov    QWORD PTR [rsp+0x78],rdi
    2135:	mov    QWORD PTR [r12+0x10],0x0
    213e:	mov    QWORD PTR [r12+0x18],0x0
    2147:	mov    QWORD PTR [r12+0x20],0x0
    2150:	mov    QWORD PTR [r12],rsi
    2154:	mov    r13,rsi
    2157:	mov    rsi,r13
    215a:	mov    rdi,QWORD PTR [rsp+0x78]
    215f:	call   2164 <botlish_fn_9+0x84>
			2160: R_X86_64_PLT32	rt_str_len-0x4
    2164:	mov    rbx,rax
    2167:	mov    QWORD PTR [r12+0x8],rbx
    216c:	lea    r8,[rsp]
    2170:	mov    QWORD PTR [rsp],r13
    2174:	mov    esi,0xb
    2179:	mov    rdx,QWORD PTR [rip+0x0]        # 2180 <botlish_fn_9+0xa0>
			217c: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    2180:	mov    r13d,0x1
    2186:	mov    rcx,r13
    2189:	mov    rdi,QWORD PTR [rsp+0x78]
    218e:	call   2193 <botlish_fn_9+0xb3>
			218f: R_X86_64_PLT32	rt_closure_new-0x4
    2193:	mov    r14,rax
    2196:	mov    QWORD PTR [r12],rax
    219a:	lea    r8,[rsp+0x8]
    219f:	mov    QWORD PTR [rsp+0x8],rbx
    21a4:	mov    QWORD PTR [rsp+0x10],rax
    21a9:	mov    esi,0xf
    21ae:	mov    rdx,QWORD PTR [rip+0x0]        # 21b5 <botlish_fn_9+0xd5>
			21b1: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_local<generic>
    21b5:	mov    r15d,0x2
    21bb:	mov    rcx,r15
    21be:	mov    rdi,QWORD PTR [rsp+0x78]
    21c3:	call   21c8 <botlish_fn_9+0xe8>
			21c4: R_X86_64_PLT32	rt_closure_new-0x4
    21c8:	mov    rcx,rax
    21cb:	mov    QWORD PTR [rsp+0x88],rax
    21d3:	mov    QWORD PTR [r12+0x10],rcx
    21d8:	lea    r8,[rsp+0x18]
    21dd:	mov    QWORD PTR [rsp+0x18],rbx
    21e2:	mov    rax,r14
    21e5:	mov    QWORD PTR [rsp+0x20],rax
    21ea:	mov    esi,0x10
    21ef:	mov    rdx,QWORD PTR [rip+0x0]        # 21f6 <botlish_fn_9+0x116>
			21f2: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; scan_label<generic>
    21f6:	mov    rcx,r15
    21f9:	mov    rdi,QWORD PTR [rsp+0x78]
    21fe:	call   2203 <botlish_fn_9+0x123>
			21ff: R_X86_64_PLT32	rt_closure_new-0x4
    2203:	mov    QWORD PTR [r12+0x18],rax
    2208:	mov    QWORD PTR [rsp+0x80],rax
    2210:	lea    r8,[rsp+0x28]
    2215:	mov    QWORD PTR [rsp+0x28],rbx
    221a:	mov    QWORD PTR [rsp+0x30],r14
    221f:	mov    esi,0x11
    2224:	mov    rdx,QWORD PTR [rip+0x0]        # 222b <botlish_fn_9+0x14b>
			2227: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; scan_alpha<generic>
    222b:	mov    rcx,r15
    222e:	mov    rdi,QWORD PTR [rsp+0x78]
    2233:	call   2238 <botlish_fn_9+0x158>
			2234: R_X86_64_PLT32	rt_closure_new-0x4
    2238:	mov    QWORD PTR [r12+0x20],rax
    223d:	lea    r8,[rsp+0x38]
    2242:	mov    QWORD PTR [rsp+0x38],rax
    2247:	mov    QWORD PTR [rsp+0x40],rbx
    224c:	mov    esi,0x12
    2251:	mov    rdx,QWORD PTR [rip+0x0]        # 2258 <botlish_fn_9+0x178>
			2254: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; tld_ok<generic>
    2258:	mov    rcx,r15
    225b:	mov    rdi,QWORD PTR [rsp+0x78]
    2260:	call   2265 <botlish_fn_9+0x185>
			2261: R_X86_64_PLT32	rt_closure_new-0x4
    2265:	mov    QWORD PTR [r12+0x20],rax
    226a:	lea    r8,[rsp+0x48]
    226f:	mov    rcx,QWORD PTR [rsp+0x80]
    2277:	mov    QWORD PTR [rsp+0x48],rcx
    227c:	mov    QWORD PTR [rsp+0x50],rbx
    2281:	mov    QWORD PTR [rsp+0x58],r14
    2286:	mov    QWORD PTR [rsp+0x60],rax
    228b:	mov    esi,0x13
    2290:	mov    rdx,QWORD PTR [rip+0x0]        # 2297 <botlish_fn_9+0x1b7>
			2293: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; domain_loop<generic>
    2297:	mov    ecx,0x4
    229c:	mov    rdi,QWORD PTR [rsp+0x78]
    22a1:	call   22a6 <botlish_fn_9+0x1c6>
			22a2: R_X86_64_PLT32	rt_closure_new-0x4
    22a6:	mov    QWORD PTR [r12+0x18],rax
    22ab:	mov    r15,rax
    22ae:	mov    QWORD PTR [r12+0x20],0x1
    22b7:	mov    rdx,r13
    22ba:	mov    rsi,QWORD PTR [rsp+0x88]
    22c2:	mov    rdi,QWORD PTR [rsp+0x78]
    22c7:	call   22cc <botlish_fn_9+0x1ec>
			22c8: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    22cc:	mov    rcx,rax
    22cf:	mov    r13,rax
    22d2:	test   rax,rcx
    22d5:	jne    22e5 <botlish_fn_9+0x205>
    22db:	mov    rdi,QWORD PTR [rsp+0x78]
    22e0:	jmp    244a <botlish_fn_9+0x36a>
    22e5:	mov    rax,r13
    22e8:	mov    QWORD PTR [r12+0x10],rax
    22ed:	test   rax,0x1
    22f3:	jne    2321 <botlish_fn_9+0x241>
    22f9:	mov    edx,0x1
    22fe:	mov    rsi,r13
    2301:	mov    rdi,QWORD PTR [rsp+0x78]
    2306:	call   230b <botlish_fn_9+0x22b>
			2307: R_X86_64_PLT32	rt_int_cmp-0x4
    230b:	mov    r10d,0x2
    2311:	test   rax,rax
    2314:	cmove  r10,QWORD PTR [rip+0x25c]        # 2578 <botlish_fn_9+0x498>
    231c:	jmp    2333 <botlish_fn_9+0x253>
    2321:	mov    r10d,0x2
    2327:	cmp    r13,0x1
    232b:	cmove  r10,QWORD PTR [rip+0x245]        # 2578 <botlish_fn_9+0x498>
    2333:	cmp    r10,0x6
    2337:	je     24ee <botlish_fn_9+0x40e>
    233d:	mov    rax,r13
    2340:	and    rax,rbx
    2343:	test   rax,0x1
    2349:	jne    2374 <botlish_fn_9+0x294>
    234f:	mov    rdx,rbx
    2352:	mov    rsi,r13
    2355:	mov    rdi,QWORD PTR [rsp+0x78]
    235a:	call   235f <botlish_fn_9+0x27f>
			235b: R_X86_64_PLT32	rt_int_cmp-0x4
    235f:	mov    ecx,0x2
    2364:	test   rax,rax
    2367:	cmovge rcx,QWORD PTR [rip+0x209]        # 2578 <botlish_fn_9+0x498>
    236f:	jmp    2384 <botlish_fn_9+0x2a4>
    2374:	mov    ecx,0x2
    2379:	cmp    r13,rbx
    237c:	cmovge rcx,QWORD PTR [rip+0x1f4]        # 2578 <botlish_fn_9+0x498>
    2384:	cmp    rcx,0x6
    2388:	je     24df <botlish_fn_9+0x3ff>
    238e:	lea    rcx,[rsp+0x68]
    2393:	mov    rsi,r14
    2396:	mov    rdx,r13
    2399:	mov    rdi,QWORD PTR [rsp+0x78]
    239e:	call   23a3 <botlish_fn_9+0x2c3>
			239f: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    23a3:	test   rax,rax
    23a6:	jne    23b6 <botlish_fn_9+0x2d6>
    23ac:	mov    rdi,QWORD PTR [rsp+0x78]
    23b1:	jmp    244a <botlish_fn_9+0x36a>
    23b6:	mov    rdx,QWORD PTR [rsp+0x68]
    23bb:	mov    rcx,QWORD PTR [rsp+0x70]
    23c0:	mov    rdi,QWORD PTR [rsp+0x78]
    23c5:	mov    rsi,QWORD PTR [rdi+0x10]
    23c9:	mov    r8,QWORD PTR [rsi+0x100]
    23d0:	mov    rsi,rax
    23d3:	call   23d8 <botlish_fn_9+0x2f8>
			23d4: R_X86_64_PLT32	rt_str_region_eq-0x4
    23d8:	cmp    rax,0x6
    23dc:	je     23ef <botlish_fn_9+0x30f>
    23e2:	mov    ecx,0x2
    23e7:	mov    rax,rcx
    23ea:	jmp    24e4 <botlish_fn_9+0x404>
    23ef:	mov    QWORD PTR [r12],0x3
    23f7:	test   r13,0x1
    23fe:	je     2416 <botlish_fn_9+0x336>
    2404:	mov    rdx,r13
    2407:	add    rdx,0x2
    240b:	seto   al
    240e:	test   al,al
    2410:	je     242b <botlish_fn_9+0x34b>
    2416:	mov    edx,0x3
    241b:	mov    rsi,r13
    241e:	mov    rdi,QWORD PTR [rsp+0x78]
    2423:	call   2428 <botlish_fn_9+0x348>
			2424: R_X86_64_PLT32	rt_int_add-0x4
    2428:	mov    rdx,rax
    242b:	mov    QWORD PTR [r12],rdx
    242f:	mov    rsi,r15
    2432:	mov    rdi,QWORD PTR [rsp+0x78]
    2437:	call   243c <botlish_fn_9+0x35c>
			2438: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    243c:	test   rax,rax
    243f:	jne    2489 <botlish_fn_9+0x3a9>
    2445:	mov    rdi,QWORD PTR [rsp+0x78]
    244a:	mov    rdi,QWORD PTR [rsp+0x78]
    244f:	mov    QWORD PTR [rdi],r12
    2452:	xor    rax,rax
    2455:	mov    rbx,QWORD PTR [rsp+0x90]
    245d:	mov    r12,QWORD PTR [rsp+0x98]
    2465:	mov    r13,QWORD PTR [rsp+0xa0]
    246d:	mov    r14,QWORD PTR [rsp+0xa8]
    2475:	mov    r15,QWORD PTR [rsp+0xb0]
    247d:	add    rsp,0xc0
    2484:	mov    rsp,rbp
    2487:	pop    rbp
    2488:	ret
    2489:	mov    rcx,rax
    248c:	and    rcx,rbx
    248f:	mov    rsi,rax
    2492:	mov    rax,rbx
    2495:	test   rcx,0x1
    249c:	jne    24c7 <botlish_fn_9+0x3e7>
    24a2:	mov    rdx,rax
    24a5:	mov    rdi,QWORD PTR [rsp+0x78]
    24aa:	call   24af <botlish_fn_9+0x3cf>
			24ab: R_X86_64_PLT32	rt_int_cmp-0x4
    24af:	mov    ecx,0x2
    24b4:	test   rax,rax
    24b7:	mov    rax,rcx
    24ba:	cmove  rax,QWORD PTR [rip+0xb6]        # 2578 <botlish_fn_9+0x498>
    24c2:	jmp    24e4 <botlish_fn_9+0x404>
    24c7:	mov    rdx,rax
    24ca:	mov    eax,0x2
    24cf:	cmp    rsi,rdx
    24d2:	cmove  rax,QWORD PTR [rip+0x9e]        # 2578 <botlish_fn_9+0x498>
    24da:	jmp    24e4 <botlish_fn_9+0x404>
    24df:	mov    eax,0x2
    24e4:	mov    rdi,QWORD PTR [rsp+0x78]
    24e9:	jmp    24f8 <botlish_fn_9+0x418>
    24ee:	mov    eax,0x2
    24f3:	mov    rdi,QWORD PTR [rsp+0x78]
    24f8:	mov    rdi,QWORD PTR [rsp+0x78]
    24fd:	mov    QWORD PTR [rdi],r12
    2500:	mov    rbx,QWORD PTR [rsp+0x90]
    2508:	mov    r12,QWORD PTR [rsp+0x98]
    2510:	mov    r13,QWORD PTR [rsp+0xa0]
    2518:	mov    r14,QWORD PTR [rsp+0xa8]
    2520:	mov    r15,QWORD PTR [rsp+0xb0]
    2528:	add    rsp,0xc0
    252f:	mov    rsp,rbp
    2532:	pop    rbp
    2533:	ret
    2534:	mov    QWORD PTR [rsp+0x78],rdi
    2539:	call   253e <botlish_fn_9+0x45e>
			253a: R_X86_64_PLT32	rt_stack_overflow-0x4
    253e:	xor    rax,rax
    2541:	mov    rbx,QWORD PTR [rsp+0x90]
    2549:	mov    r12,QWORD PTR [rsp+0x98]
    2551:	mov    r13,QWORD PTR [rsp+0xa0]
    2559:	mov    r14,QWORD PTR [rsp+0xa8]
    2561:	mov    r15,QWORD PTR [rsp+0xb0]
    2569:	add    rsp,0xc0
    2570:	mov    rsp,rbp
    2573:	pop    rbp
    2574:	ret
    2575:	add    BYTE PTR [rax],al
    2577:	add    BYTE PTR [rsi],al
    2579:	add    BYTE PTR [rax],al
    257b:	add    BYTE PTR [rax],al
    257d:	add    BYTE PTR [rax],al
	...

0000000000002580 <botlish_entry_9: <str>>:
    2580:	push   rbp
    2581:	mov    rbp,rsp
    2584:	mov    rsi,QWORD PTR [rdx]
    2587:	call   258c <botlish_entry_9+0xc>
			2588: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    258c:	mov    rsp,rbp
    258f:	pop    rbp
    2590:	ret
    2591:	add    BYTE PTR [rax],al
    2593:	add    BYTE PTR [rax],al
    2595:	add    BYTE PTR [rax],al
	...

0000000000002598 <botlish_fn_10: <generic>>:
    2598:	push   rbp
    2599:	mov    rbp,rsp
    259c:	sub    rsp,0xc0
    25a3:	mov    QWORD PTR [rsp+0x90],rbx
    25ab:	mov    QWORD PTR [rsp+0x98],r12
    25b3:	mov    QWORD PTR [rsp+0xa0],r13
    25bb:	mov    QWORD PTR [rsp+0xa8],r14
    25c3:	mov    QWORD PTR [rsp+0xb0],r15
    25cb:	mov    r12,QWORD PTR [rdi]
    25ce:	mov    rax,QWORD PTR [rdi+0x8]
    25d2:	lea    rcx,[r12+0x28]
    25d7:	cmp    rcx,rax
    25da:	ja     2a2a <botlish_fn_10+0x492>
    25e0:	lea    rax,[r12+0x28]
    25e5:	mov    QWORD PTR [rdi],rax
    25e8:	mov    QWORD PTR [r12+0x10],0x0
    25f1:	mov    QWORD PTR [r12+0x18],0x0
    25fa:	mov    QWORD PTR [r12+0x20],0x0
    2603:	mov    QWORD PTR [r12],rsi
    2607:	xor    eax,eax
    2609:	test   rsi,0x7
    2610:	jne    261f <botlish_fn_10+0x87>
    2616:	movzx  rax,BYTE PTR [rsi]
    261a:	cmp    al,0x2
    261c:	sete   al
    261f:	test   al,al
    2621:	jne    264b <botlish_fn_10+0xb3>
    2627:	mov    rax,QWORD PTR [rdi+0x10]
    262b:	mov    QWORD PTR [rsp+0x78],rdi
    2630:	mov    rcx,QWORD PTR [rax+0xd8]
    2637:	mov    edx,0x1
    263c:	call   2641 <botlish_fn_10+0xa9>
			263d: R_X86_64_PLT32	rt_type_error-0x4
    2641:	mov    rdi,QWORD PTR [rsp+0x78]
    2646:	jmp    2940 <botlish_fn_10+0x3a8>
    264b:	mov    r13,rsi
    264e:	mov    QWORD PTR [rsp+0x78],rdi
    2653:	call   2658 <botlish_fn_10+0xc0>
			2654: R_X86_64_PLT32	rt_str_len-0x4
    2658:	mov    rbx,rax
    265b:	mov    QWORD PTR [r12+0x8],rbx
    2660:	lea    r8,[rsp]
    2664:	mov    QWORD PTR [rsp],r13
    2668:	mov    esi,0xb
    266d:	mov    rdx,QWORD PTR [rip+0x0]        # 2674 <botlish_fn_10+0xdc>
			2670: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    2674:	mov    r13d,0x1
    267a:	mov    rcx,r13
    267d:	mov    rdi,QWORD PTR [rsp+0x78]
    2682:	call   2687 <botlish_fn_10+0xef>
			2683: R_X86_64_PLT32	rt_closure_new-0x4
    2687:	mov    r15,rax
    268a:	mov    QWORD PTR [rsp+0x88],r13
    2692:	mov    QWORD PTR [r12],rax
    2696:	lea    r8,[rsp+0x8]
    269b:	mov    QWORD PTR [rsp+0x8],rbx
    26a0:	mov    QWORD PTR [rsp+0x10],rax
    26a5:	mov    esi,0xf
    26aa:	mov    rdx,QWORD PTR [rip+0x0]        # 26b1 <botlish_fn_10+0x119>
			26ad: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_local<generic>
    26b1:	mov    r14d,0x2
    26b7:	mov    rcx,r14
    26ba:	mov    rdi,QWORD PTR [rsp+0x78]
    26bf:	call   26c4 <botlish_fn_10+0x12c>
			26c0: R_X86_64_PLT32	rt_closure_new-0x4
    26c4:	mov    r13,rax
    26c7:	mov    QWORD PTR [r12+0x10],r13
    26cc:	lea    r8,[rsp+0x18]
    26d1:	mov    QWORD PTR [rsp+0x18],rbx
    26d6:	mov    rax,r15
    26d9:	mov    QWORD PTR [rsp+0x20],rax
    26de:	mov    esi,0x10
    26e3:	mov    rdx,QWORD PTR [rip+0x0]        # 26ea <botlish_fn_10+0x152>
			26e6: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; scan_label<generic>
    26ea:	mov    rcx,r14
    26ed:	mov    rdi,QWORD PTR [rsp+0x78]
    26f2:	call   26f7 <botlish_fn_10+0x15f>
			26f3: R_X86_64_PLT32	rt_closure_new-0x4
    26f7:	mov    QWORD PTR [r12+0x18],rax
    26fc:	mov    QWORD PTR [rsp+0x80],rax
    2704:	lea    r8,[rsp+0x28]
    2709:	mov    QWORD PTR [rsp+0x28],rbx
    270e:	mov    QWORD PTR [rsp+0x30],r15
    2713:	mov    esi,0x11
    2718:	mov    rdx,QWORD PTR [rip+0x0]        # 271f <botlish_fn_10+0x187>
			271b: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; scan_alpha<generic>
    271f:	mov    rcx,r14
    2722:	mov    rdi,QWORD PTR [rsp+0x78]
    2727:	call   272c <botlish_fn_10+0x194>
			2728: R_X86_64_PLT32	rt_closure_new-0x4
    272c:	mov    QWORD PTR [r12+0x20],rax
    2731:	lea    r8,[rsp+0x38]
    2736:	mov    QWORD PTR [rsp+0x38],rax
    273b:	mov    QWORD PTR [rsp+0x40],rbx
    2740:	mov    esi,0x12
    2745:	mov    rdx,QWORD PTR [rip+0x0]        # 274c <botlish_fn_10+0x1b4>
			2748: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; tld_ok<generic>
    274c:	mov    rcx,r14
    274f:	mov    rdi,QWORD PTR [rsp+0x78]
    2754:	call   2759 <botlish_fn_10+0x1c1>
			2755: R_X86_64_PLT32	rt_closure_new-0x4
    2759:	mov    QWORD PTR [r12+0x20],rax
    275e:	lea    r8,[rsp+0x48]
    2763:	mov    rcx,QWORD PTR [rsp+0x80]
    276b:	mov    QWORD PTR [rsp+0x48],rcx
    2770:	mov    QWORD PTR [rsp+0x50],rbx
    2775:	mov    QWORD PTR [rsp+0x58],r15
    277a:	mov    QWORD PTR [rsp+0x60],rax
    277f:	mov    esi,0x13
    2784:	mov    rdx,QWORD PTR [rip+0x0]        # 278b <botlish_fn_10+0x1f3>
			2787: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; domain_loop<generic>
    278b:	mov    ecx,0x4
    2790:	mov    rdi,QWORD PTR [rsp+0x78]
    2795:	call   279a <botlish_fn_10+0x202>
			2796: R_X86_64_PLT32	rt_closure_new-0x4
    279a:	mov    QWORD PTR [r12+0x18],rax
    279f:	mov    r14,rax
    27a2:	mov    QWORD PTR [r12+0x20],0x1
    27ab:	mov    rsi,r13
    27ae:	mov    rdx,QWORD PTR [rsp+0x88]
    27b6:	mov    rdi,QWORD PTR [rsp+0x78]
    27bb:	call   27c0 <botlish_fn_10+0x228>
			27bc: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    27c0:	mov    r10,rax
    27c3:	mov    r13,rax
    27c6:	test   rax,r10
    27c9:	jne    27d9 <botlish_fn_10+0x241>
    27cf:	mov    rdi,QWORD PTR [rsp+0x78]
    27d4:	jmp    2940 <botlish_fn_10+0x3a8>
    27d9:	mov    rax,r13
    27dc:	mov    QWORD PTR [r12+0x10],rax
    27e1:	test   rax,0x1
    27e7:	jne    2817 <botlish_fn_10+0x27f>
    27ed:	mov    rdx,QWORD PTR [rsp+0x88]
    27f5:	mov    rsi,r13
    27f8:	mov    rdi,QWORD PTR [rsp+0x78]
    27fd:	call   2802 <botlish_fn_10+0x26a>
			27fe: R_X86_64_PLT32	rt_int_cmp-0x4
    2802:	mov    ecx,0x2
    2807:	test   rax,rax
    280a:	cmove  rcx,QWORD PTR [rip+0x25e]        # 2a70 <botlish_fn_10+0x4d8>
    2812:	jmp    2828 <botlish_fn_10+0x290>
    2817:	mov    ecx,0x2
    281c:	cmp    r13,0x1
    2820:	cmove  rcx,QWORD PTR [rip+0x248]        # 2a70 <botlish_fn_10+0x4d8>
    2828:	cmp    rcx,0x6
    282c:	je     29e4 <botlish_fn_10+0x44c>
    2832:	mov    r11,r13
    2835:	and    r11,rbx
    2838:	test   r11,0x1
    283f:	jne    286a <botlish_fn_10+0x2d2>
    2845:	mov    rdx,rbx
    2848:	mov    rsi,r13
    284b:	mov    rdi,QWORD PTR [rsp+0x78]
    2850:	call   2855 <botlish_fn_10+0x2bd>
			2851: R_X86_64_PLT32	rt_int_cmp-0x4
    2855:	mov    ecx,0x2
    285a:	test   rax,rax
    285d:	cmovge rcx,QWORD PTR [rip+0x20b]        # 2a70 <botlish_fn_10+0x4d8>
    2865:	jmp    287a <botlish_fn_10+0x2e2>
    286a:	mov    ecx,0x2
    286f:	cmp    r13,rbx
    2872:	cmovge rcx,QWORD PTR [rip+0x1f6]        # 2a70 <botlish_fn_10+0x4d8>
    287a:	cmp    rcx,0x6
    287e:	je     29d5 <botlish_fn_10+0x43d>
    2884:	lea    rcx,[rsp+0x68]
    2889:	mov    rsi,r15
    288c:	mov    rdx,r13
    288f:	mov    rdi,QWORD PTR [rsp+0x78]
    2894:	call   2899 <botlish_fn_10+0x301>
			2895: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    2899:	test   rax,rax
    289c:	mov    rsi,rax
    289f:	jne    28af <botlish_fn_10+0x317>
    28a5:	mov    rdi,QWORD PTR [rsp+0x78]
    28aa:	jmp    2940 <botlish_fn_10+0x3a8>
    28af:	mov    rdx,QWORD PTR [rsp+0x68]
    28b4:	mov    rcx,QWORD PTR [rsp+0x70]
    28b9:	mov    rdi,QWORD PTR [rsp+0x78]
    28be:	mov    rax,QWORD PTR [rdi+0x10]
    28c2:	mov    r8,QWORD PTR [rax+0x100]
    28c9:	call   28ce <botlish_fn_10+0x336>
			28ca: R_X86_64_PLT32	rt_str_region_eq-0x4
    28ce:	cmp    rax,0x6
    28d2:	je     28e5 <botlish_fn_10+0x34d>
    28d8:	mov    esi,0x2
    28dd:	mov    rax,rsi
    28e0:	jmp    29da <botlish_fn_10+0x442>
    28e5:	mov    QWORD PTR [r12],0x3
    28ed:	test   r13,0x1
    28f4:	je     290c <botlish_fn_10+0x374>
    28fa:	mov    rdx,r13
    28fd:	add    rdx,0x2
    2901:	seto   al
    2904:	test   al,al
    2906:	je     2921 <botlish_fn_10+0x389>
    290c:	mov    edx,0x3
    2911:	mov    rsi,r13
    2914:	mov    rdi,QWORD PTR [rsp+0x78]
    2919:	call   291e <botlish_fn_10+0x386>
			291a: R_X86_64_PLT32	rt_int_add-0x4
    291e:	mov    rdx,rax
    2921:	mov    QWORD PTR [r12],rdx
    2925:	mov    rsi,r14
    2928:	mov    rdi,QWORD PTR [rsp+0x78]
    292d:	call   2932 <botlish_fn_10+0x39a>
			292e: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    2932:	test   rax,rax
    2935:	jne    297f <botlish_fn_10+0x3e7>
    293b:	mov    rdi,QWORD PTR [rsp+0x78]
    2940:	mov    rdi,QWORD PTR [rsp+0x78]
    2945:	mov    QWORD PTR [rdi],r12
    2948:	xor    rax,rax
    294b:	mov    rbx,QWORD PTR [rsp+0x90]
    2953:	mov    r12,QWORD PTR [rsp+0x98]
    295b:	mov    r13,QWORD PTR [rsp+0xa0]
    2963:	mov    r14,QWORD PTR [rsp+0xa8]
    296b:	mov    r15,QWORD PTR [rsp+0xb0]
    2973:	add    rsp,0xc0
    297a:	mov    rsp,rbp
    297d:	pop    rbp
    297e:	ret
    297f:	mov    rcx,rax
    2982:	and    rcx,rbx
    2985:	mov    rsi,rax
    2988:	mov    rax,rbx
    298b:	test   rcx,0x1
    2992:	jne    29bd <botlish_fn_10+0x425>
    2998:	mov    rdx,rax
    299b:	mov    rdi,QWORD PTR [rsp+0x78]
    29a0:	call   29a5 <botlish_fn_10+0x40d>
			29a1: R_X86_64_PLT32	rt_int_cmp-0x4
    29a5:	mov    esi,0x2
    29aa:	test   rax,rax
    29ad:	mov    rax,rsi
    29b0:	cmove  rax,QWORD PTR [rip+0xb8]        # 2a70 <botlish_fn_10+0x4d8>
    29b8:	jmp    29da <botlish_fn_10+0x442>
    29bd:	mov    rdx,rax
    29c0:	mov    eax,0x2
    29c5:	cmp    rsi,rdx
    29c8:	cmove  rax,QWORD PTR [rip+0xa0]        # 2a70 <botlish_fn_10+0x4d8>
    29d0:	jmp    29da <botlish_fn_10+0x442>
    29d5:	mov    eax,0x2
    29da:	mov    rdi,QWORD PTR [rsp+0x78]
    29df:	jmp    29ee <botlish_fn_10+0x456>
    29e4:	mov    eax,0x2
    29e9:	mov    rdi,QWORD PTR [rsp+0x78]
    29ee:	mov    rdi,QWORD PTR [rsp+0x78]
    29f3:	mov    QWORD PTR [rdi],r12
    29f6:	mov    rbx,QWORD PTR [rsp+0x90]
    29fe:	mov    r12,QWORD PTR [rsp+0x98]
    2a06:	mov    r13,QWORD PTR [rsp+0xa0]
    2a0e:	mov    r14,QWORD PTR [rsp+0xa8]
    2a16:	mov    r15,QWORD PTR [rsp+0xb0]
    2a1e:	add    rsp,0xc0
    2a25:	mov    rsp,rbp
    2a28:	pop    rbp
    2a29:	ret
    2a2a:	mov    QWORD PTR [rsp+0x78],rdi
    2a2f:	call   2a34 <botlish_fn_10+0x49c>
			2a30: R_X86_64_PLT32	rt_stack_overflow-0x4
    2a34:	xor    rax,rax
    2a37:	mov    rbx,QWORD PTR [rsp+0x90]
    2a3f:	mov    r12,QWORD PTR [rsp+0x98]
    2a47:	mov    r13,QWORD PTR [rsp+0xa0]
    2a4f:	mov    r14,QWORD PTR [rsp+0xa8]
    2a57:	mov    r15,QWORD PTR [rsp+0xb0]
    2a5f:	add    rsp,0xc0
    2a66:	mov    rsp,rbp
    2a69:	pop    rbp
    2a6a:	ret
    2a6b:	add    BYTE PTR [rax],al
    2a6d:	add    BYTE PTR [rax],al
    2a6f:	add    BYTE PTR [rsi],al
    2a71:	add    BYTE PTR [rax],al
    2a73:	add    BYTE PTR [rax],al
    2a75:	add    BYTE PTR [rax],al
	...

0000000000002a78 <botlish_entry_10: <generic>>:
    2a78:	push   rbp
    2a79:	mov    rbp,rsp
    2a7c:	mov    rsi,QWORD PTR [rdx]
    2a7f:	call   2a84 <botlish_entry_10+0xc>
			2a80: R_X86_64_PLT32	botlish_fn_10-0x4 ; <generic>
    2a84:	mov    rsp,rbp
    2a87:	pop    rbp
    2a88:	ret

0000000000002a89 <botlish_fn_11: char_at<generic>>:
    2a89:	push   rbp
    2a8a:	mov    rbp,rsp
    2a8d:	sub    rsp,0x20
    2a91:	mov    QWORD PTR [rsp],rbx
    2a95:	mov    QWORD PTR [rsp+0x8],r12
    2a9a:	mov    QWORD PTR [rsp+0x10],r13
    2a9f:	mov    QWORD PTR [rsp+0x18],r14
    2aa4:	mov    rbx,QWORD PTR [rdi]
    2aa7:	mov    rax,QWORD PTR [rdi+0x8]
    2aab:	lea    rcx,[rbx+0x18]
    2aaf:	cmp    rcx,rax
    2ab2:	ja     2c3a <botlish_fn_11+0x1b1>
    2ab8:	lea    rax,[rbx+0x18]
    2abc:	mov    QWORD PTR [rdi],rax
    2abf:	mov    QWORD PTR [rbx],rdx
    2ac2:	mov    rax,QWORD PTR [rsi+0x20]
    2ac6:	mov    rsi,QWORD PTR [rax]
    2ac9:	mov    QWORD PTR [rbx+0x8],rsi
    2acd:	mov    r14,rsi
    2ad0:	mov    QWORD PTR [rbx+0x10],0x3
    2ad8:	mov    ecx,0x1
    2add:	test   rdx,0x1
    2ae4:	je     2af2 <botlish_fn_11+0x69>
    2aea:	mov    r13,rdx
    2aed:	jmp    2b15 <botlish_fn_11+0x8c>
    2af2:	xor    ecx,ecx
    2af4:	test   rdx,0x7
    2afb:	je     2b09 <botlish_fn_11+0x80>
    2b01:	mov    r13,rdx
    2b04:	jmp    2b15 <botlish_fn_11+0x8c>
    2b09:	movzx  rax,BYTE PTR [rdx]
    2b0d:	mov    r13,rdx
    2b10:	cmp    al,0x1
    2b12:	sete   cl
    2b15:	test   cl,cl
    2b17:	jne    2b3e <botlish_fn_11+0xb5>
    2b1d:	mov    rax,QWORD PTR [rdi+0x10]
    2b21:	mov    r12,rdi
    2b24:	mov    rcx,QWORD PTR [rax+0x108]
    2b2b:	xor    rdx,rdx
    2b2e:	mov    rsi,r13
    2b31:	call   2b36 <botlish_fn_11+0xad>
			2b32: R_X86_64_PLT32	rt_type_error-0x4
    2b36:	mov    rdi,r12
    2b39:	jmp    2bf3 <botlish_fn_11+0x16a>
    2b3e:	mov    rsi,r13
    2b41:	mov    r12,rdi
    2b44:	test   rsi,0x1
    2b4b:	je     2b66 <botlish_fn_11+0xdd>
    2b51:	mov    rsi,r13
    2b54:	mov    rcx,rsi
    2b57:	add    rcx,0x2
    2b5b:	seto   dl
    2b5e:	test   dl,dl
    2b60:	je     2b79 <botlish_fn_11+0xf0>
    2b66:	mov    edx,0x3
    2b6b:	mov    rsi,r13
    2b6e:	mov    rdi,r12
    2b71:	call   2b76 <botlish_fn_11+0xed>
			2b72: R_X86_64_PLT32	rt_int_add-0x4
    2b76:	mov    rcx,rax
    2b79:	mov    QWORD PTR [rbx+0x10],rcx
    2b7d:	mov    edx,0x1
    2b82:	mov    rsi,r13
    2b85:	test   rsi,0x1
    2b8c:	jne    2bb0 <botlish_fn_11+0x127>
    2b92:	xor    edx,edx
    2b94:	mov    rsi,r13
    2b97:	test   rsi,0x7
    2b9e:	jne    2bb0 <botlish_fn_11+0x127>
    2ba4:	mov    rsi,r13
    2ba7:	movzx  rax,BYTE PTR [rsi]
    2bab:	cmp    al,0x1
    2bad:	sete   dl
    2bb0:	test   dl,dl
    2bb2:	jne    2bd9 <botlish_fn_11+0x150>
    2bb8:	mov    rdi,r12
    2bbb:	mov    rax,QWORD PTR [rdi+0x10]
    2bbf:	mov    rcx,QWORD PTR [rax+0x110]
    2bc6:	xor    rdx,rdx
    2bc9:	mov    rsi,r13
    2bcc:	call   2bd1 <botlish_fn_11+0x148>
			2bcd: R_X86_64_PLT32	rt_type_error-0x4
    2bd1:	mov    rdi,r12
    2bd4:	jmp    2bf3 <botlish_fn_11+0x16a>
    2bd9:	mov    rdx,r13
    2bdc:	mov    rsi,r14
    2bdf:	mov    rdi,r12
    2be2:	call   2be7 <botlish_fn_11+0x15e>
			2be3: R_X86_64_PLT32	rt_substr-0x4
    2be7:	test   rax,rax
    2bea:	jne    2c18 <botlish_fn_11+0x18f>
    2bf0:	mov    rdi,r12
    2bf3:	mov    rdi,r12
    2bf6:	mov    QWORD PTR [rdi],rbx
    2bf9:	xor    rax,rax
    2bfc:	mov    rbx,QWORD PTR [rsp]
    2c00:	mov    r12,QWORD PTR [rsp+0x8]
    2c05:	mov    r13,QWORD PTR [rsp+0x10]
    2c0a:	mov    r14,QWORD PTR [rsp+0x18]
    2c0f:	add    rsp,0x20
    2c13:	mov    rsp,rbp
    2c16:	pop    rbp
    2c17:	ret
    2c18:	mov    rdi,r12
    2c1b:	mov    QWORD PTR [rdi],rbx
    2c1e:	mov    rbx,QWORD PTR [rsp]
    2c22:	mov    r12,QWORD PTR [rsp+0x8]
    2c27:	mov    r13,QWORD PTR [rsp+0x10]
    2c2c:	mov    r14,QWORD PTR [rsp+0x18]
    2c31:	add    rsp,0x20
    2c35:	mov    rsp,rbp
    2c38:	pop    rbp
    2c39:	ret
    2c3a:	mov    r12,rdi
    2c3d:	call   2c42 <botlish_fn_11+0x1b9>
			2c3e: R_X86_64_PLT32	rt_stack_overflow-0x4
    2c42:	xor    rax,rax
    2c45:	mov    rbx,QWORD PTR [rsp]
    2c49:	mov    r12,QWORD PTR [rsp+0x8]
    2c4e:	mov    r13,QWORD PTR [rsp+0x10]
    2c53:	mov    r14,QWORD PTR [rsp+0x18]
    2c58:	add    rsp,0x20
    2c5c:	mov    rsp,rbp
    2c5f:	pop    rbp
    2c60:	ret

0000000000002c61 <botlish_entry_11: char_at<generic>>:
    2c61:	push   rbp
    2c62:	mov    rbp,rsp
    2c65:	mov    rdx,QWORD PTR [rdx]
    2c68:	call   2c6d <botlish_entry_11+0xc>
			2c69: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2c6d:	mov    rsp,rbp
    2c70:	pop    rbp
    2c71:	ret

0000000000002c72 <botlish_fn_12: char_at<generic>>:
    2c72:	push   rbp
    2c73:	mov    rbp,rsp
    2c76:	sub    rsp,0x40
    2c7a:	mov    QWORD PTR [rsp+0x10],rbx
    2c7f:	mov    QWORD PTR [rsp+0x18],r12
    2c84:	mov    QWORD PTR [rsp+0x20],r13
    2c89:	mov    QWORD PTR [rsp+0x28],r14
    2c8e:	mov    QWORD PTR [rsp+0x30],r15
    2c93:	mov    r15,rcx
    2c96:	mov    rbx,QWORD PTR [rdi]
    2c99:	mov    rax,QWORD PTR [rdi+0x8]
    2c9d:	lea    rcx,[rbx+0x18]
    2ca1:	cmp    rcx,rax
    2ca4:	ja     2e5a <botlish_fn_12+0x1e8>
    2caa:	lea    rax,[rbx+0x18]
    2cae:	mov    QWORD PTR [rdi],rax
    2cb1:	mov    QWORD PTR [rbx],rdx
    2cb4:	mov    rax,QWORD PTR [rsi+0x20]
    2cb8:	mov    rax,QWORD PTR [rax]
    2cbb:	mov    QWORD PTR [rbx+0x8],rax
    2cbf:	mov    QWORD PTR [rsp],rax
    2cc3:	mov    QWORD PTR [rbx+0x10],0x3
    2ccb:	mov    eax,0x1
    2cd0:	test   rdx,0x1
    2cd7:	je     2ce5 <botlish_fn_12+0x73>
    2cdd:	mov    r14,rdx
    2ce0:	jmp    2d08 <botlish_fn_12+0x96>
    2ce5:	xor    eax,eax
    2ce7:	test   rdx,0x7
    2cee:	je     2cfc <botlish_fn_12+0x8a>
    2cf4:	mov    r14,rdx
    2cf7:	jmp    2d08 <botlish_fn_12+0x96>
    2cfc:	movzx  rax,BYTE PTR [rdx]
    2d00:	mov    r14,rdx
    2d03:	cmp    al,0x1
    2d05:	sete   al
    2d08:	test   al,al
    2d0a:	jne    2d31 <botlish_fn_12+0xbf>
    2d10:	mov    rax,QWORD PTR [rdi+0x10]
    2d14:	mov    r13,rdi
    2d17:	mov    rcx,QWORD PTR [rax+0x108]
    2d1e:	xor    rdx,rdx
    2d21:	mov    rsi,r14
    2d24:	call   2d29 <botlish_fn_12+0xb7>
			2d25: R_X86_64_PLT32	rt_type_error-0x4
    2d29:	mov    rdi,r13
    2d2c:	jmp    2df6 <botlish_fn_12+0x184>
    2d31:	mov    rsi,r14
    2d34:	mov    r13,rdi
    2d37:	test   rsi,0x1
    2d3e:	jne    2d4c <botlish_fn_12+0xda>
    2d44:	mov    r14,rsi
    2d47:	jmp    2d69 <botlish_fn_12+0xf7>
    2d4c:	mov    rax,rsi
    2d4f:	add    rax,0x2
    2d53:	mov    r14,rsi
    2d56:	seto   dl
    2d59:	test   dl,dl
    2d5b:	jne    2d69 <botlish_fn_12+0xf7>
    2d61:	mov    r12,rax
    2d64:	jmp    2d7c <botlish_fn_12+0x10a>
    2d69:	mov    edx,0x3
    2d6e:	mov    rsi,r14
    2d71:	mov    rdi,r13
    2d74:	call   2d79 <botlish_fn_12+0x107>
			2d75: R_X86_64_PLT32	rt_int_add-0x4
    2d79:	mov    r12,rax
    2d7c:	mov    ecx,0x1
    2d81:	mov    rsi,r14
    2d84:	test   rsi,0x1
    2d8b:	jne    2daf <botlish_fn_12+0x13d>
    2d91:	xor    ecx,ecx
    2d93:	mov    rsi,r14
    2d96:	test   rsi,0x7
    2d9d:	jne    2daf <botlish_fn_12+0x13d>
    2da3:	mov    rsi,r14
    2da6:	movzx  rax,BYTE PTR [rsi]
    2daa:	cmp    al,0x1
    2dac:	sete   cl
    2daf:	test   cl,cl
    2db1:	jne    2dd8 <botlish_fn_12+0x166>
    2db7:	mov    rdi,r13
    2dba:	mov    rax,QWORD PTR [rdi+0x10]
    2dbe:	mov    rcx,QWORD PTR [rax+0x110]
    2dc5:	xor    rdx,rdx
    2dc8:	mov    rsi,r14
    2dcb:	call   2dd0 <botlish_fn_12+0x15e>
			2dcc: R_X86_64_PLT32	rt_type_error-0x4
    2dd0:	mov    rdi,r13
    2dd3:	jmp    2df6 <botlish_fn_12+0x184>
    2dd8:	mov    rcx,r12
    2ddb:	mov    rdx,r14
    2dde:	mov    rsi,QWORD PTR [rsp]
    2de2:	mov    rdi,r13
    2de5:	call   2dea <botlish_fn_12+0x178>
			2de6: R_X86_64_PLT32	rt_str_region_check-0x4
    2dea:	test   rax,rax
    2ded:	jne    2e21 <botlish_fn_12+0x1af>
    2df3:	mov    rdi,r13
    2df6:	mov    rdi,r13
    2df9:	mov    QWORD PTR [rdi],rbx
    2dfc:	xor    rax,rax
    2dff:	mov    rbx,QWORD PTR [rsp+0x10]
    2e04:	mov    r12,QWORD PTR [rsp+0x18]
    2e09:	mov    r13,QWORD PTR [rsp+0x20]
    2e0e:	mov    r14,QWORD PTR [rsp+0x28]
    2e13:	mov    r15,QWORD PTR [rsp+0x30]
    2e18:	add    rsp,0x40
    2e1c:	mov    rsp,rbp
    2e1f:	pop    rbp
    2e20:	ret
    2e21:	mov    rdi,r13
    2e24:	mov    QWORD PTR [rdi],rbx
    2e27:	mov    rcx,r15
    2e2a:	mov    rsi,r14
    2e2d:	mov    QWORD PTR [rcx],rsi
    2e30:	mov    QWORD PTR [rcx+0x8],r12
    2e34:	mov    rax,QWORD PTR [rsp]
    2e38:	mov    rbx,QWORD PTR [rsp+0x10]
    2e3d:	mov    r12,QWORD PTR [rsp+0x18]
    2e42:	mov    r13,QWORD PTR [rsp+0x20]
    2e47:	mov    r14,QWORD PTR [rsp+0x28]
    2e4c:	mov    r15,QWORD PTR [rsp+0x30]
    2e51:	add    rsp,0x40
    2e55:	mov    rsp,rbp
    2e58:	pop    rbp
    2e59:	ret
    2e5a:	mov    r13,rdi
    2e5d:	call   2e62 <botlish_fn_12+0x1f0>
			2e5e: R_X86_64_PLT32	rt_stack_overflow-0x4
    2e62:	xor    rax,rax
    2e65:	mov    rbx,QWORD PTR [rsp+0x10]
    2e6a:	mov    r12,QWORD PTR [rsp+0x18]
    2e6f:	mov    r13,QWORD PTR [rsp+0x20]
    2e74:	mov    r14,QWORD PTR [rsp+0x28]
    2e79:	mov    r15,QWORD PTR [rsp+0x30]
    2e7e:	add    rsp,0x40
    2e82:	mov    rsp,rbp
    2e85:	pop    rbp
    2e86:	ret

0000000000002e87 <botlish_entry_12: char_at<generic>>:
    2e87:	push   rbp
    2e88:	mov    rbp,rsp
    2e8b:	ud2

0000000000002e8d <botlish_fn_13: is_local_char<str>>:
    2e8d:	push   rbp
    2e8e:	mov    rbp,rsp
    2e91:	sub    rsp,0x20
    2e95:	mov    QWORD PTR [rsp],rbx
    2e99:	mov    QWORD PTR [rsp+0x8],r12
    2e9e:	mov    QWORD PTR [rsp+0x10],r13
    2ea3:	mov    r13,rsi
    2ea6:	mov    rbx,QWORD PTR [rdi]
    2ea9:	mov    rax,QWORD PTR [rdi+0x8]
    2ead:	lea    rcx,[rbx+0x8]
    2eb1:	cmp    rcx,rax
    2eb4:	ja     301f <botlish_fn_13+0x192>
    2eba:	lea    rax,[rbx+0x8]
    2ebe:	mov    QWORD PTR [rdi],rax
    2ec1:	mov    r12,rdi
    2ec4:	mov    rsi,r13
    2ec7:	mov    rdi,r12
    2eca:	call   2ecf <botlish_fn_13+0x42>
			2ecb: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    2ecf:	test   rax,rax
    2ed2:	jne    2ef8 <botlish_fn_13+0x6b>
    2ed8:	mov    rdi,r12
    2edb:	mov    QWORD PTR [rdi],rbx
    2ede:	xor    rax,rax
    2ee1:	mov    rbx,QWORD PTR [rsp]
    2ee5:	mov    r12,QWORD PTR [rsp+0x8]
    2eea:	mov    r13,QWORD PTR [rsp+0x10]
    2eef:	add    rsp,0x20
    2ef3:	mov    rsp,rbp
    2ef6:	pop    rbp
    2ef7:	ret
    2ef8:	cmp    rax,0x6
    2efc:	je     2ffa <botlish_fn_13+0x16d>
    2f02:	mov    rdi,r12
    2f05:	mov    rax,QWORD PTR [rdi+0x10]
    2f09:	mov    rsi,QWORD PTR [rax+0x118]
    2f10:	mov    edx,0x1
    2f15:	mov    ecx,0x3
    2f1a:	mov    r8,r13
    2f1d:	call   2f22 <botlish_fn_13+0x95>
			2f1e: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f22:	cmp    rax,0x6
    2f26:	je     2fed <botlish_fn_13+0x160>
    2f2c:	mov    rdi,r12
    2f2f:	mov    rax,QWORD PTR [rdi+0x10]
    2f33:	mov    rsi,QWORD PTR [rax+0x120]
    2f3a:	mov    edx,0x1
    2f3f:	mov    ecx,0x3
    2f44:	mov    r8,r13
    2f47:	call   2f4c <botlish_fn_13+0xbf>
			2f48: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f4c:	cmp    rax,0x6
    2f50:	je     2fe3 <botlish_fn_13+0x156>
    2f56:	mov    rdi,r12
    2f59:	mov    rax,QWORD PTR [rdi+0x10]
    2f5d:	mov    rsi,QWORD PTR [rax+0xc0]
    2f64:	mov    edx,0x1
    2f69:	mov    ecx,0x3
    2f6e:	mov    r8,r13
    2f71:	call   2f76 <botlish_fn_13+0xe9>
			2f72: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f76:	cmp    rax,0x6
    2f7a:	je     2fd9 <botlish_fn_13+0x14c>
    2f80:	mov    rdi,r12
    2f83:	mov    rax,QWORD PTR [rdi+0x10]
    2f87:	mov    rsi,QWORD PTR [rax+0x108]
    2f8e:	mov    edx,0x1
    2f93:	mov    ecx,0x3
    2f98:	mov    r8,r13
    2f9b:	call   2fa0 <botlish_fn_13+0x113>
			2f9c: R_X86_64_PLT32	rt_str_region_eq-0x4
    2fa0:	cmp    rax,0x6
    2fa4:	je     2fcf <botlish_fn_13+0x142>
    2faa:	mov    rdi,r12
    2fad:	mov    rdx,QWORD PTR [rdi+0x10]
    2fb1:	mov    rsi,QWORD PTR [rdx+0x128]
    2fb8:	mov    edx,0x1
    2fbd:	mov    ecx,0x3
    2fc2:	mov    r8,r13
    2fc5:	call   2fca <botlish_fn_13+0x13d>
			2fc6: R_X86_64_PLT32	rt_str_region_eq-0x4
    2fca:	jmp    2ff2 <botlish_fn_13+0x165>
    2fcf:	mov    eax,0x6
    2fd4:	jmp    2ff2 <botlish_fn_13+0x165>
    2fd9:	mov    eax,0x6
    2fde:	jmp    2ff2 <botlish_fn_13+0x165>
    2fe3:	mov    eax,0x6
    2fe8:	jmp    2ff2 <botlish_fn_13+0x165>
    2fed:	mov    eax,0x6
    2ff2:	mov    rdi,r12
    2ff5:	jmp    3002 <botlish_fn_13+0x175>
    2ffa:	mov    eax,0x6
    2fff:	mov    rdi,r12
    3002:	mov    rdi,r12
    3005:	mov    QWORD PTR [rdi],rbx
    3008:	mov    rbx,QWORD PTR [rsp]
    300c:	mov    r12,QWORD PTR [rsp+0x8]
    3011:	mov    r13,QWORD PTR [rsp+0x10]
    3016:	add    rsp,0x20
    301a:	mov    rsp,rbp
    301d:	pop    rbp
    301e:	ret
    301f:	mov    r12,rdi
    3022:	call   3027 <botlish_fn_13+0x19a>
			3023: R_X86_64_PLT32	rt_stack_overflow-0x4
    3027:	xor    rax,rax
    302a:	mov    rbx,QWORD PTR [rsp]
    302e:	mov    r12,QWORD PTR [rsp+0x8]
    3033:	mov    r13,QWORD PTR [rsp+0x10]
    3038:	add    rsp,0x20
    303c:	mov    rsp,rbp
    303f:	pop    rbp
    3040:	ret

0000000000003041 <botlish_entry_13: is_local_char<str>>:
    3041:	push   rbp
    3042:	mov    rbp,rsp
    3045:	mov    rsi,QWORD PTR [rdx]
    3048:	call   304d <botlish_entry_13+0xc>
			3049: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_local_char<str>
    304d:	mov    rsp,rbp
    3050:	pop    rbp
    3051:	ret

0000000000003052 <botlish_fn_14: is_label_char<str>>:
    3052:	push   rbp
    3053:	mov    rbp,rsp
    3056:	sub    rsp,0x20
    305a:	mov    QWORD PTR [rsp],rbx
    305e:	mov    QWORD PTR [rsp+0x8],r12
    3063:	mov    QWORD PTR [rsp+0x10],r13
    3068:	mov    r13,rsi
    306b:	mov    rbx,QWORD PTR [rdi]
    306e:	mov    rax,QWORD PTR [rdi+0x8]
    3072:	lea    rcx,[rbx+0x8]
    3076:	cmp    rcx,rax
    3079:	ja     3114 <botlish_fn_14+0xc2>
    307f:	lea    rax,[rbx+0x8]
    3083:	mov    QWORD PTR [rdi],rax
    3086:	mov    r12,rdi
    3089:	mov    rsi,r13
    308c:	mov    rdi,r12
    308f:	call   3094 <botlish_fn_14+0x42>
			3090: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    3094:	test   rax,rax
    3097:	jne    30bd <botlish_fn_14+0x6b>
    309d:	mov    rdi,r12
    30a0:	mov    QWORD PTR [rdi],rbx
    30a3:	xor    rax,rax
    30a6:	mov    rbx,QWORD PTR [rsp]
    30aa:	mov    r12,QWORD PTR [rsp+0x8]
    30af:	mov    r13,QWORD PTR [rsp+0x10]
    30b4:	add    rsp,0x20
    30b8:	mov    rsp,rbp
    30bb:	pop    rbp
    30bc:	ret
    30bd:	cmp    rax,0x6
    30c1:	je     30ef <botlish_fn_14+0x9d>
    30c7:	mov    rdi,r12
    30ca:	mov    rax,QWORD PTR [rdi+0x10]
    30ce:	mov    rsi,QWORD PTR [rax+0x128]
    30d5:	mov    edx,0x1
    30da:	mov    ecx,0x3
    30df:	mov    r8,r13
    30e2:	call   30e7 <botlish_fn_14+0x95>
			30e3: R_X86_64_PLT32	rt_str_region_eq-0x4
    30e7:	mov    rdi,r12
    30ea:	jmp    30f7 <botlish_fn_14+0xa5>
    30ef:	mov    eax,0x6
    30f4:	mov    rdi,r12
    30f7:	mov    rdi,r12
    30fa:	mov    QWORD PTR [rdi],rbx
    30fd:	mov    rbx,QWORD PTR [rsp]
    3101:	mov    r12,QWORD PTR [rsp+0x8]
    3106:	mov    r13,QWORD PTR [rsp+0x10]
    310b:	add    rsp,0x20
    310f:	mov    rsp,rbp
    3112:	pop    rbp
    3113:	ret
    3114:	mov    r12,rdi
    3117:	call   311c <botlish_fn_14+0xca>
			3118: R_X86_64_PLT32	rt_stack_overflow-0x4
    311c:	xor    rax,rax
    311f:	mov    rbx,QWORD PTR [rsp]
    3123:	mov    r12,QWORD PTR [rsp+0x8]
    3128:	mov    r13,QWORD PTR [rsp+0x10]
    312d:	add    rsp,0x20
    3131:	mov    rsp,rbp
    3134:	pop    rbp
    3135:	ret

0000000000003136 <botlish_entry_14: is_label_char<str>>:
    3136:	push   rbp
    3137:	mov    rbp,rsp
    313a:	mov    rsi,QWORD PTR [rdx]
    313d:	call   3142 <botlish_entry_14+0xc>
			313e: R_X86_64_PLT32	botlish_fn_14-0x4 ; is_label_char<str>
    3142:	mov    rsp,rbp
    3145:	pop    rbp
    3146:	ret
	...

0000000000003148 <botlish_fn_15: scan_local<generic>>:
    3148:	push   rbp
    3149:	mov    rbp,rsp
    314c:	sub    rsp,0x20
    3150:	mov    QWORD PTR [rsp],rbx
    3154:	mov    QWORD PTR [rsp+0x8],r12
    3159:	mov    QWORD PTR [rsp+0x10],r13
    315e:	mov    QWORD PTR [rsp+0x18],r14
    3163:	mov    r12,QWORD PTR [rdi]
    3166:	mov    rax,QWORD PTR [rdi+0x8]
    316a:	lea    rcx,[r12+0x18]
    316f:	cmp    rcx,rax
    3172:	ja     3346 <botlish_fn_15+0x1fe>
    3178:	lea    rax,[r12+0x18]
    317d:	mov    QWORD PTR [rdi],rax
    3180:	mov    r13,rdi
    3183:	mov    QWORD PTR [r12+0x10],0x0
    318c:	mov    QWORD PTR [r12],rdx
    3190:	mov    rbx,rsi
    3193:	mov    rsi,rdx
    3196:	mov    rax,QWORD PTR [rbx+0x20]
    319a:	mov    rdx,QWORD PTR [rax]
    319d:	mov    ecx,0x1
    31a2:	test   rsi,0x1
    31a9:	jne    31c7 <botlish_fn_15+0x7f>
    31af:	xor    ecx,ecx
    31b1:	test   rsi,0x7
    31b8:	jne    31c7 <botlish_fn_15+0x7f>
    31be:	movzx  rax,BYTE PTR [rsi]
    31c2:	cmp    al,0x1
    31c4:	sete   cl
    31c7:	test   cl,cl
    31c9:	jne    31ed <botlish_fn_15+0xa5>
    31cf:	mov    rdi,r13
    31d2:	mov    rax,QWORD PTR [rdi+0x10]
    31d6:	mov    rcx,QWORD PTR [rax+0xb8]
    31dd:	xor    rdx,rdx
    31e0:	call   31e5 <botlish_fn_15+0x9d>
			31e1: R_X86_64_PLT32	rt_type_error-0x4
    31e5:	mov    rdi,r13
    31e8:	jmp    3284 <botlish_fn_15+0x13c>
    31ed:	mov    rax,rsi
    31f0:	and    rax,rdx
    31f3:	mov    r14,rsi
    31f6:	test   rax,0x1
    31fc:	jne    3222 <botlish_fn_15+0xda>
    3202:	mov    rsi,r14
    3205:	mov    rdi,r13
    3208:	call   320d <botlish_fn_15+0xc5>
			3209: R_X86_64_PLT32	rt_int_cmp-0x4
    320d:	mov    ecx,0x2
    3212:	test   rax,rax
    3215:	cmovge rcx,QWORD PTR [rip+0x153]        # 3370 <botlish_fn_15+0x228>
    321d:	jmp    3235 <botlish_fn_15+0xed>
    3222:	mov    ecx,0x2
    3227:	mov    rsi,r14
    322a:	cmp    rsi,rdx
    322d:	cmovge rcx,QWORD PTR [rip+0x13b]        # 3370 <botlish_fn_15+0x228>
    3235:	cmp    rcx,0x6
    3239:	je     331e <botlish_fn_15+0x1d6>
    323f:	mov    rsi,QWORD PTR [rbx+0x20]
    3243:	mov    rsi,QWORD PTR [rsi+0x8]
    3247:	mov    QWORD PTR [r12+0x8],rsi
    324c:	mov    rdx,r14
    324f:	mov    rdi,r13
    3252:	call   3257 <botlish_fn_15+0x10f>
			3253: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    3257:	test   rax,rax
    325a:	jne    3268 <botlish_fn_15+0x120>
    3260:	mov    rdi,r13
    3263:	jmp    3284 <botlish_fn_15+0x13c>
    3268:	mov    QWORD PTR [r12+0x8],rax
    326d:	mov    rsi,rax
    3270:	mov    rdi,r13
    3273:	call   3278 <botlish_fn_15+0x130>
			3274: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_local_char<str>
    3278:	test   rax,rax
    327b:	jne    32a9 <botlish_fn_15+0x161>
    3281:	mov    rdi,r13
    3284:	mov    rdi,r13
    3287:	mov    QWORD PTR [rdi],r12
    328a:	xor    rax,rax
    328d:	mov    rbx,QWORD PTR [rsp]
    3291:	mov    r12,QWORD PTR [rsp+0x8]
    3296:	mov    r13,QWORD PTR [rsp+0x10]
    329b:	mov    r14,QWORD PTR [rsp+0x18]
    32a0:	add    rsp,0x20
    32a4:	mov    rsp,rbp
    32a7:	pop    rbp
    32a8:	ret
    32a9:	cmp    rax,0x6
    32ad:	je     32be <botlish_fn_15+0x176>
    32b3:	mov    rax,r14
    32b6:	mov    rdi,r13
    32b9:	jmp    3324 <botlish_fn_15+0x1dc>
    32be:	mov    QWORD PTR [r12+0x8],rbx
    32c3:	mov    QWORD PTR [r12+0x10],0x3
    32cc:	mov    rsi,r14
    32cf:	test   rsi,0x1
    32d6:	je     32fc <botlish_fn_15+0x1b4>
    32dc:	mov    rsi,r14
    32df:	mov    rcx,rsi
    32e2:	add    rcx,0x2
    32e6:	seto   al
    32e9:	test   al,al
    32eb:	jne    32fc <botlish_fn_15+0x1b4>
    32f1:	mov    rsi,rcx
    32f4:	mov    r14,rcx
    32f7:	jmp    3312 <botlish_fn_15+0x1ca>
    32fc:	mov    edx,0x3
    3301:	mov    rsi,r14
    3304:	mov    rdi,r13
    3307:	call   330c <botlish_fn_15+0x1c4>
			3308: R_X86_64_PLT32	rt_int_add-0x4
    330c:	mov    rsi,rax
    330f:	mov    r14,rax
    3312:	mov    QWORD PTR [r12],rsi
    3316:	mov    rsi,r14
    3319:	jmp    3196 <botlish_fn_15+0x4e>
    331e:	mov    rax,r14
    3321:	mov    rdi,r13
    3324:	mov    rdi,r13
    3327:	mov    QWORD PTR [rdi],r12
    332a:	mov    rbx,QWORD PTR [rsp]
    332e:	mov    r12,QWORD PTR [rsp+0x8]
    3333:	mov    r13,QWORD PTR [rsp+0x10]
    3338:	mov    r14,QWORD PTR [rsp+0x18]
    333d:	add    rsp,0x20
    3341:	mov    rsp,rbp
    3344:	pop    rbp
    3345:	ret
    3346:	mov    r13,rdi
    3349:	call   334e <botlish_fn_15+0x206>
			334a: R_X86_64_PLT32	rt_stack_overflow-0x4
    334e:	xor    rax,rax
    3351:	mov    rbx,QWORD PTR [rsp]
    3355:	mov    r12,QWORD PTR [rsp+0x8]
    335a:	mov    r13,QWORD PTR [rsp+0x10]
    335f:	mov    r14,QWORD PTR [rsp+0x18]
    3364:	add    rsp,0x20
    3368:	mov    rsp,rbp
    336b:	pop    rbp
    336c:	ret
    336d:	add    BYTE PTR [rax],al
    336f:	add    BYTE PTR [rsi],al
    3371:	add    BYTE PTR [rax],al
    3373:	add    BYTE PTR [rax],al
    3375:	add    BYTE PTR [rax],al
	...

0000000000003378 <botlish_entry_15: scan_local<generic>>:
    3378:	push   rbp
    3379:	mov    rbp,rsp
    337c:	mov    rdx,QWORD PTR [rdx]
    337f:	call   3384 <botlish_entry_15+0xc>
			3380: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    3384:	mov    rsp,rbp
    3387:	pop    rbp
    3388:	ret
    3389:	add    BYTE PTR [rax],al
    338b:	add    BYTE PTR [rax],al
    338d:	add    BYTE PTR [rax],al
	...

0000000000003390 <botlish_fn_16: scan_label<generic>>:
    3390:	push   rbp
    3391:	mov    rbp,rsp
    3394:	sub    rsp,0x20
    3398:	mov    QWORD PTR [rsp],rbx
    339c:	mov    QWORD PTR [rsp+0x8],r12
    33a1:	mov    QWORD PTR [rsp+0x10],r13
    33a6:	mov    QWORD PTR [rsp+0x18],r14
    33ab:	mov    r12,QWORD PTR [rdi]
    33ae:	mov    rax,QWORD PTR [rdi+0x8]
    33b2:	lea    rcx,[r12+0x18]
    33b7:	cmp    rcx,rax
    33ba:	ja     358e <botlish_fn_16+0x1fe>
    33c0:	lea    rax,[r12+0x18]
    33c5:	mov    QWORD PTR [rdi],rax
    33c8:	mov    r13,rdi
    33cb:	mov    QWORD PTR [r12+0x10],0x0
    33d4:	mov    QWORD PTR [r12],rdx
    33d8:	mov    rbx,rsi
    33db:	mov    rsi,rdx
    33de:	mov    rax,QWORD PTR [rbx+0x20]
    33e2:	mov    rdx,QWORD PTR [rax]
    33e5:	mov    ecx,0x1
    33ea:	test   rsi,0x1
    33f1:	jne    340f <botlish_fn_16+0x7f>
    33f7:	xor    ecx,ecx
    33f9:	test   rsi,0x7
    3400:	jne    340f <botlish_fn_16+0x7f>
    3406:	movzx  rax,BYTE PTR [rsi]
    340a:	cmp    al,0x1
    340c:	sete   cl
    340f:	test   cl,cl
    3411:	jne    3435 <botlish_fn_16+0xa5>
    3417:	mov    rdi,r13
    341a:	mov    rax,QWORD PTR [rdi+0x10]
    341e:	mov    rcx,QWORD PTR [rax+0xb8]
    3425:	xor    rdx,rdx
    3428:	call   342d <botlish_fn_16+0x9d>
			3429: R_X86_64_PLT32	rt_type_error-0x4
    342d:	mov    rdi,r13
    3430:	jmp    34cc <botlish_fn_16+0x13c>
    3435:	mov    rax,rsi
    3438:	and    rax,rdx
    343b:	mov    r14,rsi
    343e:	test   rax,0x1
    3444:	jne    346a <botlish_fn_16+0xda>
    344a:	mov    rsi,r14
    344d:	mov    rdi,r13
    3450:	call   3455 <botlish_fn_16+0xc5>
			3451: R_X86_64_PLT32	rt_int_cmp-0x4
    3455:	mov    ecx,0x2
    345a:	test   rax,rax
    345d:	cmovge rcx,QWORD PTR [rip+0x153]        # 35b8 <botlish_fn_16+0x228>
    3465:	jmp    347d <botlish_fn_16+0xed>
    346a:	mov    ecx,0x2
    346f:	mov    rsi,r14
    3472:	cmp    rsi,rdx
    3475:	cmovge rcx,QWORD PTR [rip+0x13b]        # 35b8 <botlish_fn_16+0x228>
    347d:	cmp    rcx,0x6
    3481:	je     3566 <botlish_fn_16+0x1d6>
    3487:	mov    rsi,QWORD PTR [rbx+0x20]
    348b:	mov    rsi,QWORD PTR [rsi+0x8]
    348f:	mov    QWORD PTR [r12+0x8],rsi
    3494:	mov    rdx,r14
    3497:	mov    rdi,r13
    349a:	call   349f <botlish_fn_16+0x10f>
			349b: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    349f:	test   rax,rax
    34a2:	jne    34b0 <botlish_fn_16+0x120>
    34a8:	mov    rdi,r13
    34ab:	jmp    34cc <botlish_fn_16+0x13c>
    34b0:	mov    QWORD PTR [r12+0x8],rax
    34b5:	mov    rsi,rax
    34b8:	mov    rdi,r13
    34bb:	call   34c0 <botlish_fn_16+0x130>
			34bc: R_X86_64_PLT32	botlish_fn_14-0x4 ; is_label_char<str>
    34c0:	test   rax,rax
    34c3:	jne    34f1 <botlish_fn_16+0x161>
    34c9:	mov    rdi,r13
    34cc:	mov    rdi,r13
    34cf:	mov    QWORD PTR [rdi],r12
    34d2:	xor    rax,rax
    34d5:	mov    rbx,QWORD PTR [rsp]
    34d9:	mov    r12,QWORD PTR [rsp+0x8]
    34de:	mov    r13,QWORD PTR [rsp+0x10]
    34e3:	mov    r14,QWORD PTR [rsp+0x18]
    34e8:	add    rsp,0x20
    34ec:	mov    rsp,rbp
    34ef:	pop    rbp
    34f0:	ret
    34f1:	cmp    rax,0x6
    34f5:	je     3506 <botlish_fn_16+0x176>
    34fb:	mov    rax,r14
    34fe:	mov    rdi,r13
    3501:	jmp    356c <botlish_fn_16+0x1dc>
    3506:	mov    QWORD PTR [r12+0x8],rbx
    350b:	mov    QWORD PTR [r12+0x10],0x3
    3514:	mov    rsi,r14
    3517:	test   rsi,0x1
    351e:	je     3544 <botlish_fn_16+0x1b4>
    3524:	mov    rsi,r14
    3527:	mov    rcx,rsi
    352a:	add    rcx,0x2
    352e:	seto   al
    3531:	test   al,al
    3533:	jne    3544 <botlish_fn_16+0x1b4>
    3539:	mov    rsi,rcx
    353c:	mov    r14,rcx
    353f:	jmp    355a <botlish_fn_16+0x1ca>
    3544:	mov    edx,0x3
    3549:	mov    rsi,r14
    354c:	mov    rdi,r13
    354f:	call   3554 <botlish_fn_16+0x1c4>
			3550: R_X86_64_PLT32	rt_int_add-0x4
    3554:	mov    rsi,rax
    3557:	mov    r14,rax
    355a:	mov    QWORD PTR [r12],rsi
    355e:	mov    rsi,r14
    3561:	jmp    33de <botlish_fn_16+0x4e>
    3566:	mov    rax,r14
    3569:	mov    rdi,r13
    356c:	mov    rdi,r13
    356f:	mov    QWORD PTR [rdi],r12
    3572:	mov    rbx,QWORD PTR [rsp]
    3576:	mov    r12,QWORD PTR [rsp+0x8]
    357b:	mov    r13,QWORD PTR [rsp+0x10]
    3580:	mov    r14,QWORD PTR [rsp+0x18]
    3585:	add    rsp,0x20
    3589:	mov    rsp,rbp
    358c:	pop    rbp
    358d:	ret
    358e:	mov    r13,rdi
    3591:	call   3596 <botlish_fn_16+0x206>
			3592: R_X86_64_PLT32	rt_stack_overflow-0x4
    3596:	xor    rax,rax
    3599:	mov    rbx,QWORD PTR [rsp]
    359d:	mov    r12,QWORD PTR [rsp+0x8]
    35a2:	mov    r13,QWORD PTR [rsp+0x10]
    35a7:	mov    r14,QWORD PTR [rsp+0x18]
    35ac:	add    rsp,0x20
    35b0:	mov    rsp,rbp
    35b3:	pop    rbp
    35b4:	ret
    35b5:	add    BYTE PTR [rax],al
    35b7:	add    BYTE PTR [rsi],al
    35b9:	add    BYTE PTR [rax],al
    35bb:	add    BYTE PTR [rax],al
    35bd:	add    BYTE PTR [rax],al
	...

00000000000035c0 <botlish_entry_16: scan_label<generic>>:
    35c0:	push   rbp
    35c1:	mov    rbp,rsp
    35c4:	mov    rdx,QWORD PTR [rdx]
    35c7:	call   35cc <botlish_entry_16+0xc>
			35c8: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_label<generic>
    35cc:	mov    rsp,rbp
    35cf:	pop    rbp
    35d0:	ret
    35d1:	add    BYTE PTR [rax],al
    35d3:	add    BYTE PTR [rax],al
    35d5:	add    BYTE PTR [rax],al
	...

00000000000035d8 <botlish_fn_17: scan_alpha<generic>>:
    35d8:	push   rbp
    35d9:	mov    rbp,rsp
    35dc:	sub    rsp,0x20
    35e0:	mov    QWORD PTR [rsp],rbx
    35e4:	mov    QWORD PTR [rsp+0x8],r12
    35e9:	mov    QWORD PTR [rsp+0x10],r13
    35ee:	mov    QWORD PTR [rsp+0x18],r14
    35f3:	mov    r12,QWORD PTR [rdi]
    35f6:	mov    rax,QWORD PTR [rdi+0x8]
    35fa:	lea    rcx,[r12+0x18]
    35ff:	cmp    rcx,rax
    3602:	ja     37d1 <botlish_fn_17+0x1f9>
    3608:	lea    rax,[r12+0x18]
    360d:	mov    QWORD PTR [rdi],rax
    3610:	mov    r13,rdi
    3613:	mov    QWORD PTR [r12+0x10],0x0
    361c:	mov    QWORD PTR [r12],rdx
    3620:	mov    rbx,rsi
    3623:	mov    rsi,rdx
    3626:	mov    rax,QWORD PTR [rbx+0x20]
    362a:	mov    rdx,QWORD PTR [rax]
    362d:	mov    ecx,0x1
    3632:	test   rsi,0x1
    3639:	jne    3657 <botlish_fn_17+0x7f>
    363f:	xor    ecx,ecx
    3641:	test   rsi,0x7
    3648:	jne    3657 <botlish_fn_17+0x7f>
    364e:	movzx  rax,BYTE PTR [rsi]
    3652:	cmp    al,0x1
    3654:	sete   cl
    3657:	test   cl,cl
    3659:	jne    367d <botlish_fn_17+0xa5>
    365f:	mov    rdi,r13
    3662:	mov    rax,QWORD PTR [rdi+0x10]
    3666:	mov    rcx,QWORD PTR [rax+0xb8]
    366d:	xor    rdx,rdx
    3670:	call   3675 <botlish_fn_17+0x9d>
			3671: R_X86_64_PLT32	rt_type_error-0x4
    3675:	mov    rdi,r13
    3678:	jmp    370f <botlish_fn_17+0x137>
    367d:	mov    rax,rsi
    3680:	and    rax,rdx
    3683:	mov    r14,rsi
    3686:	test   rax,0x1
    368c:	jne    36b2 <botlish_fn_17+0xda>
    3692:	mov    rsi,r14
    3695:	mov    rdi,r13
    3698:	call   369d <botlish_fn_17+0xc5>
			3699: R_X86_64_PLT32	rt_int_cmp-0x4
    369d:	mov    ecx,0x2
    36a2:	test   rax,rax
    36a5:	cmovge rcx,QWORD PTR [rip+0x14b]        # 37f8 <botlish_fn_17+0x220>
    36ad:	jmp    36c5 <botlish_fn_17+0xed>
    36b2:	mov    ecx,0x2
    36b7:	mov    rsi,r14
    36ba:	cmp    rsi,rdx
    36bd:	cmovge rcx,QWORD PTR [rip+0x133]        # 37f8 <botlish_fn_17+0x220>
    36c5:	cmp    rcx,0x6
    36c9:	je     37a9 <botlish_fn_17+0x1d1>
    36cf:	mov    rsi,QWORD PTR [rbx+0x20]
    36d3:	mov    rsi,QWORD PTR [rsi+0x8]
    36d7:	mov    QWORD PTR [r12+0x8],rsi
    36dc:	mov    rdx,r14
    36df:	mov    rdi,r13
    36e2:	call   36e7 <botlish_fn_17+0x10f>
			36e3: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    36e7:	test   rax,rax
    36ea:	mov    rsi,rax
    36ed:	jne    36fb <botlish_fn_17+0x123>
    36f3:	mov    rdi,r13
    36f6:	jmp    370f <botlish_fn_17+0x137>
    36fb:	mov    rdi,r13
    36fe:	call   3703 <botlish_fn_17+0x12b>
			36ff: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    3703:	test   rax,rax
    3706:	jne    3734 <botlish_fn_17+0x15c>
    370c:	mov    rdi,r13
    370f:	mov    rdi,r13
    3712:	mov    QWORD PTR [rdi],r12
    3715:	xor    rax,rax
    3718:	mov    rbx,QWORD PTR [rsp]
    371c:	mov    r12,QWORD PTR [rsp+0x8]
    3721:	mov    r13,QWORD PTR [rsp+0x10]
    3726:	mov    r14,QWORD PTR [rsp+0x18]
    372b:	add    rsp,0x20
    372f:	mov    rsp,rbp
    3732:	pop    rbp
    3733:	ret
    3734:	cmp    rax,0x6
    3738:	je     3749 <botlish_fn_17+0x171>
    373e:	mov    rax,r14
    3741:	mov    rdi,r13
    3744:	jmp    37af <botlish_fn_17+0x1d7>
    3749:	mov    QWORD PTR [r12+0x8],rbx
    374e:	mov    QWORD PTR [r12+0x10],0x3
    3757:	mov    rsi,r14
    375a:	test   rsi,0x1
    3761:	je     3787 <botlish_fn_17+0x1af>
    3767:	mov    rsi,r14
    376a:	mov    rcx,rsi
    376d:	add    rcx,0x2
    3771:	seto   al
    3774:	test   al,al
    3776:	jne    3787 <botlish_fn_17+0x1af>
    377c:	mov    rsi,rcx
    377f:	mov    r14,rcx
    3782:	jmp    379d <botlish_fn_17+0x1c5>
    3787:	mov    edx,0x3
    378c:	mov    rsi,r14
    378f:	mov    rdi,r13
    3792:	call   3797 <botlish_fn_17+0x1bf>
			3793: R_X86_64_PLT32	rt_int_add-0x4
    3797:	mov    rsi,rax
    379a:	mov    r14,rax
    379d:	mov    QWORD PTR [r12],rsi
    37a1:	mov    rsi,r14
    37a4:	jmp    3626 <botlish_fn_17+0x4e>
    37a9:	mov    rax,r14
    37ac:	mov    rdi,r13
    37af:	mov    rdi,r13
    37b2:	mov    QWORD PTR [rdi],r12
    37b5:	mov    rbx,QWORD PTR [rsp]
    37b9:	mov    r12,QWORD PTR [rsp+0x8]
    37be:	mov    r13,QWORD PTR [rsp+0x10]
    37c3:	mov    r14,QWORD PTR [rsp+0x18]
    37c8:	add    rsp,0x20
    37cc:	mov    rsp,rbp
    37cf:	pop    rbp
    37d0:	ret
    37d1:	mov    r13,rdi
    37d4:	call   37d9 <botlish_fn_17+0x201>
			37d5: R_X86_64_PLT32	rt_stack_overflow-0x4
    37d9:	xor    rax,rax
    37dc:	mov    rbx,QWORD PTR [rsp]
    37e0:	mov    r12,QWORD PTR [rsp+0x8]
    37e5:	mov    r13,QWORD PTR [rsp+0x10]
    37ea:	mov    r14,QWORD PTR [rsp+0x18]
    37ef:	add    rsp,0x20
    37f3:	mov    rsp,rbp
    37f6:	pop    rbp
    37f7:	ret
    37f8:	(bad)
    37f9:	add    BYTE PTR [rax],al
    37fb:	add    BYTE PTR [rax],al
    37fd:	add    BYTE PTR [rax],al
	...

0000000000003800 <botlish_entry_17: scan_alpha<generic>>:
    3800:	push   rbp
    3801:	mov    rbp,rsp
    3804:	mov    rdx,QWORD PTR [rdx]
    3807:	call   380c <botlish_entry_17+0xc>
			3808: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_alpha<generic>
    380c:	mov    rsp,rbp
    380f:	pop    rbp
    3810:	ret
    3811:	add    BYTE PTR [rax],al
    3813:	add    BYTE PTR [rax],al
    3815:	add    BYTE PTR [rax],al
	...

0000000000003818 <botlish_fn_18: tld_ok<generic>>:
    3818:	push   rbp
    3819:	mov    rbp,rsp
    381c:	sub    rsp,0x30
    3820:	mov    QWORD PTR [rsp],rbx
    3824:	mov    QWORD PTR [rsp+0x8],r12
    3829:	mov    QWORD PTR [rsp+0x10],r13
    382e:	mov    QWORD PTR [rsp+0x18],r14
    3833:	mov    QWORD PTR [rsp+0x20],r15
    3838:	mov    rbx,QWORD PTR [rdi]
    383b:	mov    rax,QWORD PTR [rdi+0x8]
    383f:	lea    rcx,[rbx+0x10]
    3843:	cmp    rcx,rax
    3846:	ja     3a4b <botlish_fn_18+0x233>
    384c:	lea    rax,[rbx+0x10]
    3850:	mov    QWORD PTR [rdi],rax
    3853:	mov    r13,rdi
    3856:	mov    QWORD PTR [rbx],rdx
    3859:	mov    r8,rdx
    385c:	mov    rax,QWORD PTR [rsi+0x20]
    3860:	mov    r15,rsi
    3863:	mov    rsi,QWORD PTR [rax]
    3866:	mov    QWORD PTR [rbx+0x8],rsi
    386a:	mov    r12,r8
    386d:	mov    rdx,r12
    3870:	mov    rdi,r13
    3873:	call   3878 <botlish_fn_18+0x60>
			3874: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_alpha<generic>
    3878:	mov    rcx,rax
    387b:	mov    r14,rax
    387e:	test   rax,rcx
    3881:	jne    388f <botlish_fn_18+0x77>
    3887:	mov    rdi,r13
    388a:	jmp    3967 <botlish_fn_18+0x14f>
    388f:	mov    rax,r14
    3892:	mov    QWORD PTR [rbx+0x8],rax
    3896:	mov    rsi,r15
    3899:	mov    rax,QWORD PTR [rsi+0x20]
    389d:	mov    rdx,QWORD PTR [rax+0x8]
    38a1:	mov    rax,r14
    38a4:	and    rax,rdx
    38a7:	test   rax,0x1
    38ad:	jne    38d6 <botlish_fn_18+0xbe>
    38b3:	mov    rsi,r14
    38b6:	mov    rdi,r13
    38b9:	call   38be <botlish_fn_18+0xa6>
			38ba: R_X86_64_PLT32	rt_int_cmp-0x4
    38be:	mov    ecx,0x2
    38c3:	test   rax,rax
    38c6:	cmove  rcx,QWORD PTR [rip+0x1aa]        # 3a78 <botlish_fn_18+0x260>
    38ce:	mov    rax,r14
    38d1:	jmp    38e9 <botlish_fn_18+0xd1>
    38d6:	mov    ecx,0x2
    38db:	mov    rax,r14
    38de:	cmp    rax,rdx
    38e1:	cmove  rcx,QWORD PTR [rip+0x18f]        # 3a78 <botlish_fn_18+0x260>
    38e9:	cmp    rcx,0x6
    38ed:	je     3903 <botlish_fn_18+0xeb>
    38f3:	mov    ecx,0x2
    38f8:	mov    rax,rcx
    38fb:	mov    rdi,r13
    38fe:	jmp    3a24 <botlish_fn_18+0x20c>
    3903:	mov    ecx,0x1
    3908:	test   r12,0x1
    390f:	je     391d <botlish_fn_18+0x105>
    3915:	mov    r8,r12
    3918:	jmp    3943 <botlish_fn_18+0x12b>
    391d:	xor    ecx,ecx
    391f:	test   r12,0x7
    3926:	je     3934 <botlish_fn_18+0x11c>
    392c:	mov    r8,r12
    392f:	jmp    3943 <botlish_fn_18+0x12b>
    3934:	movzx  rcx,BYTE PTR [r12]
    3939:	mov    r8,r12
    393c:	rex cmp cl,0x1
    3940:	sete   cl
    3943:	test   cl,cl
    3945:	jne    3991 <botlish_fn_18+0x179>
    394b:	mov    rdi,r13
    394e:	mov    rax,QWORD PTR [rdi+0x10]
    3952:	mov    rcx,QWORD PTR [rax+0x128]
    3959:	xor    rdx,rdx
    395c:	mov    rsi,r8
    395f:	call   3964 <botlish_fn_18+0x14c>
			3960: R_X86_64_PLT32	rt_type_error-0x4
    3964:	mov    rdi,r13
    3967:	mov    rdi,r13
    396a:	mov    QWORD PTR [rdi],rbx
    396d:	xor    rax,rax
    3970:	mov    rbx,QWORD PTR [rsp]
    3974:	mov    r12,QWORD PTR [rsp+0x8]
    3979:	mov    r13,QWORD PTR [rsp+0x10]
    397e:	mov    r14,QWORD PTR [rsp+0x18]
    3983:	mov    r15,QWORD PTR [rsp+0x20]
    3988:	add    rsp,0x30
    398c:	mov    rsp,rbp
    398f:	pop    rbp
    3990:	ret
    3991:	mov    r12,r8
    3994:	mov    rcx,rax
    3997:	and    rcx,r12
    399a:	test   rcx,0x1
    39a1:	jne    39b2 <botlish_fn_18+0x19a>
    39a7:	mov    rdx,r8
    39aa:	mov    rsi,rax
    39ad:	jmp    39d3 <botlish_fn_18+0x1bb>
    39b2:	mov    r12,r8
    39b5:	mov    rcx,rax
    39b8:	sub    rcx,r12
    39bb:	mov    r14,rax
    39be:	seto   al
    39c1:	lea    rsi,[rcx+0x1]
    39c5:	test   al,al
    39c7:	je     39de <botlish_fn_18+0x1c6>
    39cd:	mov    rdx,r8
    39d0:	mov    rsi,r14
    39d3:	mov    rdi,r13
    39d6:	call   39db <botlish_fn_18+0x1c3>
			39d7: R_X86_64_PLT32	rt_int_sub-0x4
    39db:	mov    rsi,rax
    39de:	test   rsi,0x1
    39e5:	jne    3a10 <botlish_fn_18+0x1f8>
    39eb:	mov    edx,0x5
    39f0:	mov    rdi,r13
    39f3:	call   39f8 <botlish_fn_18+0x1e0>
			39f4: R_X86_64_PLT32	rt_int_cmp-0x4
    39f8:	mov    ecx,0x2
    39fd:	test   rax,rax
    3a00:	mov    rax,rcx
    3a03:	cmovge rax,QWORD PTR [rip+0x6d]        # 3a78 <botlish_fn_18+0x260>
    3a0b:	jmp    3a21 <botlish_fn_18+0x209>
    3a10:	mov    eax,0x2
    3a15:	cmp    rsi,0x5
    3a19:	cmovge rax,QWORD PTR [rip+0x57]        # 3a78 <botlish_fn_18+0x260>
    3a21:	mov    rdi,r13
    3a24:	mov    rdi,r13
    3a27:	mov    QWORD PTR [rdi],rbx
    3a2a:	mov    rbx,QWORD PTR [rsp]
    3a2e:	mov    r12,QWORD PTR [rsp+0x8]
    3a33:	mov    r13,QWORD PTR [rsp+0x10]
    3a38:	mov    r14,QWORD PTR [rsp+0x18]
    3a3d:	mov    r15,QWORD PTR [rsp+0x20]
    3a42:	add    rsp,0x30
    3a46:	mov    rsp,rbp
    3a49:	pop    rbp
    3a4a:	ret
    3a4b:	mov    r13,rdi
    3a4e:	call   3a53 <botlish_fn_18+0x23b>
			3a4f: R_X86_64_PLT32	rt_stack_overflow-0x4
    3a53:	xor    rax,rax
    3a56:	mov    rbx,QWORD PTR [rsp]
    3a5a:	mov    r12,QWORD PTR [rsp+0x8]
    3a5f:	mov    r13,QWORD PTR [rsp+0x10]
    3a64:	mov    r14,QWORD PTR [rsp+0x18]
    3a69:	mov    r15,QWORD PTR [rsp+0x20]
    3a6e:	add    rsp,0x30
    3a72:	mov    rsp,rbp
    3a75:	pop    rbp
    3a76:	ret
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
    3a9c:	sub    rsp,0x50
    3aa0:	mov    QWORD PTR [rsp+0x20],rbx
    3aa5:	mov    QWORD PTR [rsp+0x28],r12
    3aaa:	mov    QWORD PTR [rsp+0x30],r13
    3aaf:	mov    QWORD PTR [rsp+0x38],r14
    3ab4:	mov    QWORD PTR [rsp+0x40],r15
    3ab9:	mov    r13,QWORD PTR [rdi]
    3abc:	mov    rax,QWORD PTR [rdi+0x8]
    3ac0:	lea    rcx,[r13+0x10]
    3ac4:	cmp    rcx,rax
    3ac7:	ja     3d36 <botlish_fn_19+0x29e>
    3acd:	lea    rax,[r13+0x10]
    3ad1:	mov    QWORD PTR [rdi],rax
    3ad4:	mov    r15,rdi
    3ad7:	mov    QWORD PTR [r13+0x0],rdx
    3adb:	mov    QWORD PTR [rsp+0x10],rdx
    3ae0:	lea    rbx,[rsp]
    3ae4:	mov    r12,rsi
    3ae7:	mov    rax,QWORD PTR [r12+0x20]
    3aec:	mov    rsi,QWORD PTR [rax]
    3aef:	mov    QWORD PTR [r13+0x8],rsi
    3af3:	mov    rdx,QWORD PTR [rsp+0x10]
    3af8:	mov    rdi,r15
    3afb:	call   3b00 <botlish_fn_19+0x68>
			3afc: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_label<generic>
    3b00:	mov    rcx,rax
    3b03:	mov    r14,rax
    3b06:	test   rax,rcx
    3b09:	jne    3b17 <botlish_fn_19+0x7f>
    3b0f:	mov    rdi,r15
    3b12:	jmp    3ca4 <botlish_fn_19+0x20c>
    3b17:	mov    rax,r14
    3b1a:	mov    QWORD PTR [r13+0x0],rax
    3b1e:	mov    rdx,QWORD PTR [rsp+0x10]
    3b23:	mov    rsi,rax
    3b26:	and    rsi,rdx
    3b29:	test   rsi,0x1
    3b30:	jne    3b57 <botlish_fn_19+0xbf>
    3b36:	mov    rdx,QWORD PTR [rsp+0x10]
    3b3b:	mov    rsi,r14
    3b3e:	mov    rdi,r15
    3b41:	call   3b46 <botlish_fn_19+0xae>
			3b42: R_X86_64_PLT32	rt_value_eq-0x4
    3b46:	test   rax,rax
    3b49:	jne    3b6c <botlish_fn_19+0xd4>
    3b4f:	mov    rdi,r15
    3b52:	jmp    3ca4 <botlish_fn_19+0x20c>
    3b57:	mov    eax,0x2
    3b5c:	mov    rdx,QWORD PTR [rsp+0x10]
    3b61:	cmp    r14,rdx
    3b64:	cmove  rax,QWORD PTR [rip+0x1fc]        # 3d68 <botlish_fn_19+0x2d0>
    3b6c:	cmp    rax,0x6
    3b70:	je     3d04 <botlish_fn_19+0x26c>
    3b76:	mov    rax,QWORD PTR [r12+0x20]
    3b7b:	mov    rdx,QWORD PTR [rax+0x8]
    3b7f:	mov    rax,r14
    3b82:	and    rax,rdx
    3b85:	test   rax,0x1
    3b8b:	jne    3bb1 <botlish_fn_19+0x119>
    3b91:	mov    rsi,r14
    3b94:	mov    rdi,r15
    3b97:	call   3b9c <botlish_fn_19+0x104>
			3b98: R_X86_64_PLT32	rt_int_cmp-0x4
    3b9c:	mov    ecx,0x2
    3ba1:	test   rax,rax
    3ba4:	cmovge rcx,QWORD PTR [rip+0x1bc]        # 3d68 <botlish_fn_19+0x2d0>
    3bac:	jmp    3bc1 <botlish_fn_19+0x129>
    3bb1:	mov    ecx,0x2
    3bb6:	cmp    r14,rdx
    3bb9:	cmovge rcx,QWORD PTR [rip+0x1a7]        # 3d68 <botlish_fn_19+0x2d0>
    3bc1:	cmp    rcx,0x6
    3bc5:	je     3cf5 <botlish_fn_19+0x25d>
    3bcb:	mov    rax,QWORD PTR [r12+0x20]
    3bd0:	mov    rsi,QWORD PTR [rax+0x10]
    3bd4:	mov    QWORD PTR [r13+0x8],rsi
    3bd8:	mov    rcx,rbx
    3bdb:	mov    rdx,r14
    3bde:	mov    rdi,r15
    3be1:	call   3be6 <botlish_fn_19+0x14e>
			3be2: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    3be6:	test   rax,rax
    3be9:	mov    rsi,rax
    3bec:	jne    3bfa <botlish_fn_19+0x162>
    3bf2:	mov    rdi,r15
    3bf5:	jmp    3ca4 <botlish_fn_19+0x20c>
    3bfa:	mov    rdx,QWORD PTR [rsp]
    3bfe:	mov    rcx,QWORD PTR [rsp+0x8]
    3c03:	mov    rdi,r15
    3c06:	mov    rax,QWORD PTR [rdi+0x10]
    3c0a:	mov    r8,QWORD PTR [rax+0x118]
    3c11:	call   3c16 <botlish_fn_19+0x17e>
			3c12: R_X86_64_PLT32	rt_str_region_eq-0x4
    3c16:	cmp    rax,0x6
    3c1a:	je     3c2c <botlish_fn_19+0x194>
    3c20:	mov    rax,0xffffffffffffffff
    3c27:	jmp    3cfc <botlish_fn_19+0x264>
    3c2c:	mov    QWORD PTR [r13+0x8],0x3
    3c34:	test   r14,0x1
    3c3b:	je     3c62 <botlish_fn_19+0x1ca>
    3c41:	mov    rdx,r14
    3c44:	add    rdx,0x2
    3c48:	mov    QWORD PTR [rsp+0x10],rdx
    3c4d:	seto   al
    3c50:	test   al,al
    3c52:	jne    3c62 <botlish_fn_19+0x1ca>
    3c58:	mov    rdx,QWORD PTR [rsp+0x10]
    3c5d:	jmp    3c7a <botlish_fn_19+0x1e2>
    3c62:	mov    edx,0x3
    3c67:	mov    rsi,r14
    3c6a:	mov    rdi,r15
    3c6d:	call   3c72 <botlish_fn_19+0x1da>
			3c6e: R_X86_64_PLT32	rt_int_add-0x4
    3c72:	mov    rdx,rax
    3c75:	mov    QWORD PTR [rsp+0x10],rax
    3c7a:	mov    QWORD PTR [r13+0x0],rdx
    3c7e:	mov    rax,QWORD PTR [r12+0x20]
    3c83:	mov    rsi,QWORD PTR [rax+0x18]
    3c87:	mov    QWORD PTR [r13+0x8],rsi
    3c8b:	mov    rdx,QWORD PTR [rsp+0x10]
    3c90:	mov    rdi,r15
    3c93:	call   3c98 <botlish_fn_19+0x200>
			3c94: R_X86_64_PLT32	botlish_fn_18-0x4 ; tld_ok<generic>
    3c98:	test   rax,rax
    3c9b:	jne    3ccf <botlish_fn_19+0x237>
    3ca1:	mov    rdi,r15
    3ca4:	mov    rdi,r15
    3ca7:	mov    QWORD PTR [rdi],r13
    3caa:	xor    rax,rax
    3cad:	mov    rbx,QWORD PTR [rsp+0x20]
    3cb2:	mov    r12,QWORD PTR [rsp+0x28]
    3cb7:	mov    r13,QWORD PTR [rsp+0x30]
    3cbc:	mov    r14,QWORD PTR [rsp+0x38]
    3cc1:	mov    r15,QWORD PTR [rsp+0x40]
    3cc6:	add    rsp,0x50
    3cca:	mov    rsp,rbp
    3ccd:	pop    rbp
    3cce:	ret
    3ccf:	cmp    rax,0x6
    3cd3:	je     3ce7 <botlish_fn_19+0x24f>
    3cd9:	mov    rdx,QWORD PTR [rsp+0x10]
    3cde:	mov    QWORD PTR [r13+0x0],rdx
    3ce2:	jmp    3ae7 <botlish_fn_19+0x4f>
    3ce7:	mov    rax,QWORD PTR [r12+0x20]
    3cec:	mov    rax,QWORD PTR [rax+0x8]
    3cf0:	jmp    3cfc <botlish_fn_19+0x264>
    3cf5:	mov    rax,0xffffffffffffffff
    3cfc:	mov    rdi,r15
    3cff:	jmp    3d0e <botlish_fn_19+0x276>
    3d04:	mov    rax,0xffffffffffffffff
    3d0b:	mov    rdi,r15
    3d0e:	mov    rdi,r15
    3d11:	mov    QWORD PTR [rdi],r13
    3d14:	mov    rbx,QWORD PTR [rsp+0x20]
    3d19:	mov    r12,QWORD PTR [rsp+0x28]
    3d1e:	mov    r13,QWORD PTR [rsp+0x30]
    3d23:	mov    r14,QWORD PTR [rsp+0x38]
    3d28:	mov    r15,QWORD PTR [rsp+0x40]
    3d2d:	add    rsp,0x50
    3d31:	mov    rsp,rbp
    3d34:	pop    rbp
    3d35:	ret
    3d36:	mov    r15,rdi
    3d39:	call   3d3e <botlish_fn_19+0x2a6>
			3d3a: R_X86_64_PLT32	rt_stack_overflow-0x4
    3d3e:	xor    rax,rax
    3d41:	mov    rbx,QWORD PTR [rsp+0x20]
    3d46:	mov    r12,QWORD PTR [rsp+0x28]
    3d4b:	mov    r13,QWORD PTR [rsp+0x30]
    3d50:	mov    r14,QWORD PTR [rsp+0x38]
    3d55:	mov    r15,QWORD PTR [rsp+0x40]
    3d5a:	add    rsp,0x50
    3d5e:	mov    rsp,rbp
    3d61:	pop    rbp
    3d62:	ret
    3d63:	add    BYTE PTR [rax],al
    3d65:	add    BYTE PTR [rax],al
    3d67:	add    BYTE PTR [rsi],al
    3d69:	add    BYTE PTR [rax],al
    3d6b:	add    BYTE PTR [rax],al
    3d6d:	add    BYTE PTR [rax],al
	...

0000000000003d70 <botlish_entry_19: domain_loop<generic>>:
    3d70:	push   rbp
    3d71:	mov    rbp,rsp
    3d74:	mov    rdx,QWORD PTR [rdx]
    3d77:	call   3d7c <botlish_entry_19+0xc>
			3d78: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    3d7c:	mov    rsp,rbp
    3d7f:	pop    rbp
    3d80:	ret
    3d81:	add    BYTE PTR [rax],al
    3d83:	add    BYTE PTR [rax],al
    3d85:	add    BYTE PTR [rax],al
	...

0000000000003d88 <botlish_fn_20: <str>>:
    3d88:	push   rbp
    3d89:	mov    rbp,rsp
    3d8c:	sub    rsp,0xc0
    3d93:	mov    QWORD PTR [rsp+0x90],rbx
    3d9b:	mov    QWORD PTR [rsp+0x98],r12
    3da3:	mov    QWORD PTR [rsp+0xa0],r13
    3dab:	mov    QWORD PTR [rsp+0xa8],r14
    3db3:	mov    QWORD PTR [rsp+0xb0],r15
    3dbb:	mov    r12,QWORD PTR [rdi]
    3dbe:	mov    rax,QWORD PTR [rdi+0x8]
    3dc2:	lea    rcx,[r12+0x28]
    3dc7:	cmp    rcx,rax
    3dca:	ja     41dc <botlish_fn_20+0x454>
    3dd0:	lea    rax,[r12+0x28]
    3dd5:	mov    QWORD PTR [rdi],rax
    3dd8:	mov    QWORD PTR [rsp+0x78],rdi
    3ddd:	mov    QWORD PTR [r12+0x10],0x0
    3de6:	mov    QWORD PTR [r12+0x18],0x0
    3def:	mov    QWORD PTR [r12+0x20],0x0
    3df8:	mov    QWORD PTR [r12],rsi
    3dfc:	mov    r13,rsi
    3dff:	mov    rsi,r13
    3e02:	mov    rdi,QWORD PTR [rsp+0x78]
    3e07:	call   3e0c <botlish_fn_20+0x84>
			3e08: R_X86_64_PLT32	rt_str_len-0x4
    3e0c:	mov    rbx,rax
    3e0f:	mov    QWORD PTR [r12+0x8],rbx
    3e14:	lea    r8,[rsp]
    3e18:	mov    QWORD PTR [rsp],r13
    3e1c:	mov    esi,0x16
    3e21:	mov    rdx,QWORD PTR [rip+0x0]        # 3e28 <botlish_fn_20+0xa0>
			3e24: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; char_at<generic>
    3e28:	mov    r13d,0x1
    3e2e:	mov    rcx,r13
    3e31:	mov    rdi,QWORD PTR [rsp+0x78]
    3e36:	call   3e3b <botlish_fn_20+0xb3>
			3e37: R_X86_64_PLT32	rt_closure_new-0x4
    3e3b:	mov    r14,rax
    3e3e:	mov    QWORD PTR [r12],rax
    3e42:	lea    r8,[rsp+0x8]
    3e47:	mov    QWORD PTR [rsp+0x8],rbx
    3e4c:	mov    QWORD PTR [rsp+0x10],rax
    3e51:	mov    esi,0x1a
    3e56:	mov    rdx,QWORD PTR [rip+0x0]        # 3e5d <botlish_fn_20+0xd5>
			3e59: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; scan_local<generic>
    3e5d:	mov    r15d,0x2
    3e63:	mov    rcx,r15
    3e66:	mov    rdi,QWORD PTR [rsp+0x78]
    3e6b:	call   3e70 <botlish_fn_20+0xe8>
			3e6c: R_X86_64_PLT32	rt_closure_new-0x4
    3e70:	mov    rcx,rax
    3e73:	mov    QWORD PTR [rsp+0x88],rax
    3e7b:	mov    QWORD PTR [r12+0x10],rcx
    3e80:	lea    r8,[rsp+0x18]
    3e85:	mov    QWORD PTR [rsp+0x18],rbx
    3e8a:	mov    rax,r14
    3e8d:	mov    QWORD PTR [rsp+0x20],rax
    3e92:	mov    esi,0x1b
    3e97:	mov    rdx,QWORD PTR [rip+0x0]        # 3e9e <botlish_fn_20+0x116>
			3e9a: R_X86_64_GOTPCREL	botlish_entry_27-0x4 ; scan_label<generic>
    3e9e:	mov    rcx,r15
    3ea1:	mov    rdi,QWORD PTR [rsp+0x78]
    3ea6:	call   3eab <botlish_fn_20+0x123>
			3ea7: R_X86_64_PLT32	rt_closure_new-0x4
    3eab:	mov    QWORD PTR [r12+0x18],rax
    3eb0:	mov    QWORD PTR [rsp+0x80],rax
    3eb8:	lea    r8,[rsp+0x28]
    3ebd:	mov    QWORD PTR [rsp+0x28],rbx
    3ec2:	mov    QWORD PTR [rsp+0x30],r14
    3ec7:	mov    esi,0x1c
    3ecc:	mov    rdx,QWORD PTR [rip+0x0]        # 3ed3 <botlish_fn_20+0x14b>
			3ecf: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; scan_alpha<generic>
    3ed3:	mov    rcx,r15
    3ed6:	mov    rdi,QWORD PTR [rsp+0x78]
    3edb:	call   3ee0 <botlish_fn_20+0x158>
			3edc: R_X86_64_PLT32	rt_closure_new-0x4
    3ee0:	mov    QWORD PTR [r12+0x20],rax
    3ee5:	lea    r8,[rsp+0x38]
    3eea:	mov    QWORD PTR [rsp+0x38],rax
    3eef:	mov    QWORD PTR [rsp+0x40],rbx
    3ef4:	mov    esi,0x1d
    3ef9:	mov    rdx,QWORD PTR [rip+0x0]        # 3f00 <botlish_fn_20+0x178>
			3efc: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; tld_ok<generic>
    3f00:	mov    rcx,r15
    3f03:	mov    rdi,QWORD PTR [rsp+0x78]
    3f08:	call   3f0d <botlish_fn_20+0x185>
			3f09: R_X86_64_PLT32	rt_closure_new-0x4
    3f0d:	mov    QWORD PTR [r12+0x20],rax
    3f12:	lea    r8,[rsp+0x48]
    3f17:	mov    rcx,QWORD PTR [rsp+0x80]
    3f1f:	mov    QWORD PTR [rsp+0x48],rcx
    3f24:	mov    QWORD PTR [rsp+0x50],rbx
    3f29:	mov    QWORD PTR [rsp+0x58],r14
    3f2e:	mov    QWORD PTR [rsp+0x60],rax
    3f33:	mov    esi,0x1e
    3f38:	mov    rdx,QWORD PTR [rip+0x0]        # 3f3f <botlish_fn_20+0x1b7>
			3f3b: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; domain_loop<generic>
    3f3f:	mov    ecx,0x4
    3f44:	mov    rdi,QWORD PTR [rsp+0x78]
    3f49:	call   3f4e <botlish_fn_20+0x1c6>
			3f4a: R_X86_64_PLT32	rt_closure_new-0x4
    3f4e:	mov    QWORD PTR [r12+0x18],rax
    3f53:	mov    r15,rax
    3f56:	mov    QWORD PTR [r12+0x20],0x1
    3f5f:	mov    rdx,r13
    3f62:	mov    rsi,QWORD PTR [rsp+0x88]
    3f6a:	mov    rdi,QWORD PTR [rsp+0x78]
    3f6f:	call   3f74 <botlish_fn_20+0x1ec>
			3f70: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    3f74:	mov    rcx,rax
    3f77:	mov    r13,rax
    3f7a:	test   rax,rcx
    3f7d:	jne    3f8d <botlish_fn_20+0x205>
    3f83:	mov    rdi,QWORD PTR [rsp+0x78]
    3f88:	jmp    40f2 <botlish_fn_20+0x36a>
    3f8d:	mov    rax,r13
    3f90:	mov    QWORD PTR [r12+0x10],rax
    3f95:	test   rax,0x1
    3f9b:	jne    3fc9 <botlish_fn_20+0x241>
    3fa1:	mov    edx,0x1
    3fa6:	mov    rsi,r13
    3fa9:	mov    rdi,QWORD PTR [rsp+0x78]
    3fae:	call   3fb3 <botlish_fn_20+0x22b>
			3faf: R_X86_64_PLT32	rt_int_cmp-0x4
    3fb3:	mov    r10d,0x2
    3fb9:	test   rax,rax
    3fbc:	cmove  r10,QWORD PTR [rip+0x25c]        # 4220 <botlish_fn_20+0x498>
    3fc4:	jmp    3fdb <botlish_fn_20+0x253>
    3fc9:	mov    r10d,0x2
    3fcf:	cmp    r13,0x1
    3fd3:	cmove  r10,QWORD PTR [rip+0x245]        # 4220 <botlish_fn_20+0x498>
    3fdb:	cmp    r10,0x6
    3fdf:	je     4196 <botlish_fn_20+0x40e>
    3fe5:	mov    rax,r13
    3fe8:	and    rax,rbx
    3feb:	test   rax,0x1
    3ff1:	jne    401c <botlish_fn_20+0x294>
    3ff7:	mov    rdx,rbx
    3ffa:	mov    rsi,r13
    3ffd:	mov    rdi,QWORD PTR [rsp+0x78]
    4002:	call   4007 <botlish_fn_20+0x27f>
			4003: R_X86_64_PLT32	rt_int_cmp-0x4
    4007:	mov    ecx,0x2
    400c:	test   rax,rax
    400f:	cmovge rcx,QWORD PTR [rip+0x209]        # 4220 <botlish_fn_20+0x498>
    4017:	jmp    402c <botlish_fn_20+0x2a4>
    401c:	mov    ecx,0x2
    4021:	cmp    r13,rbx
    4024:	cmovge rcx,QWORD PTR [rip+0x1f4]        # 4220 <botlish_fn_20+0x498>
    402c:	cmp    rcx,0x6
    4030:	je     4187 <botlish_fn_20+0x3ff>
    4036:	lea    rcx,[rsp+0x68]
    403b:	mov    rsi,r14
    403e:	mov    rdx,r13
    4041:	mov    rdi,QWORD PTR [rsp+0x78]
    4046:	call   404b <botlish_fn_20+0x2c3>
			4047: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    404b:	test   rax,rax
    404e:	jne    405e <botlish_fn_20+0x2d6>
    4054:	mov    rdi,QWORD PTR [rsp+0x78]
    4059:	jmp    40f2 <botlish_fn_20+0x36a>
    405e:	mov    rdx,QWORD PTR [rsp+0x68]
    4063:	mov    rcx,QWORD PTR [rsp+0x70]
    4068:	mov    rdi,QWORD PTR [rsp+0x78]
    406d:	mov    rsi,QWORD PTR [rdi+0x10]
    4071:	mov    r8,QWORD PTR [rsi+0x100]
    4078:	mov    rsi,rax
    407b:	call   4080 <botlish_fn_20+0x2f8>
			407c: R_X86_64_PLT32	rt_str_region_eq-0x4
    4080:	cmp    rax,0x6
    4084:	je     4097 <botlish_fn_20+0x30f>
    408a:	mov    ecx,0x2
    408f:	mov    rax,rcx
    4092:	jmp    418c <botlish_fn_20+0x404>
    4097:	mov    QWORD PTR [r12],0x3
    409f:	test   r13,0x1
    40a6:	je     40be <botlish_fn_20+0x336>
    40ac:	mov    rdx,r13
    40af:	add    rdx,0x2
    40b3:	seto   al
    40b6:	test   al,al
    40b8:	je     40d3 <botlish_fn_20+0x34b>
    40be:	mov    edx,0x3
    40c3:	mov    rsi,r13
    40c6:	mov    rdi,QWORD PTR [rsp+0x78]
    40cb:	call   40d0 <botlish_fn_20+0x348>
			40cc: R_X86_64_PLT32	rt_int_add-0x4
    40d0:	mov    rdx,rax
    40d3:	mov    QWORD PTR [r12],rdx
    40d7:	mov    rsi,r15
    40da:	mov    rdi,QWORD PTR [rsp+0x78]
    40df:	call   40e4 <botlish_fn_20+0x35c>
			40e0: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    40e4:	test   rax,rax
    40e7:	jne    4131 <botlish_fn_20+0x3a9>
    40ed:	mov    rdi,QWORD PTR [rsp+0x78]
    40f2:	mov    rdi,QWORD PTR [rsp+0x78]
    40f7:	mov    QWORD PTR [rdi],r12
    40fa:	xor    rax,rax
    40fd:	mov    rbx,QWORD PTR [rsp+0x90]
    4105:	mov    r12,QWORD PTR [rsp+0x98]
    410d:	mov    r13,QWORD PTR [rsp+0xa0]
    4115:	mov    r14,QWORD PTR [rsp+0xa8]
    411d:	mov    r15,QWORD PTR [rsp+0xb0]
    4125:	add    rsp,0xc0
    412c:	mov    rsp,rbp
    412f:	pop    rbp
    4130:	ret
    4131:	mov    rcx,rax
    4134:	and    rcx,rbx
    4137:	mov    rsi,rax
    413a:	mov    rax,rbx
    413d:	test   rcx,0x1
    4144:	jne    416f <botlish_fn_20+0x3e7>
    414a:	mov    rdx,rax
    414d:	mov    rdi,QWORD PTR [rsp+0x78]
    4152:	call   4157 <botlish_fn_20+0x3cf>
			4153: R_X86_64_PLT32	rt_int_cmp-0x4
    4157:	mov    ecx,0x2
    415c:	test   rax,rax
    415f:	mov    rax,rcx
    4162:	cmove  rax,QWORD PTR [rip+0xb6]        # 4220 <botlish_fn_20+0x498>
    416a:	jmp    418c <botlish_fn_20+0x404>
    416f:	mov    rdx,rax
    4172:	mov    eax,0x2
    4177:	cmp    rsi,rdx
    417a:	cmove  rax,QWORD PTR [rip+0x9e]        # 4220 <botlish_fn_20+0x498>
    4182:	jmp    418c <botlish_fn_20+0x404>
    4187:	mov    eax,0x2
    418c:	mov    rdi,QWORD PTR [rsp+0x78]
    4191:	jmp    41a0 <botlish_fn_20+0x418>
    4196:	mov    eax,0x2
    419b:	mov    rdi,QWORD PTR [rsp+0x78]
    41a0:	mov    rdi,QWORD PTR [rsp+0x78]
    41a5:	mov    QWORD PTR [rdi],r12
    41a8:	mov    rbx,QWORD PTR [rsp+0x90]
    41b0:	mov    r12,QWORD PTR [rsp+0x98]
    41b8:	mov    r13,QWORD PTR [rsp+0xa0]
    41c0:	mov    r14,QWORD PTR [rsp+0xa8]
    41c8:	mov    r15,QWORD PTR [rsp+0xb0]
    41d0:	add    rsp,0xc0
    41d7:	mov    rsp,rbp
    41da:	pop    rbp
    41db:	ret
    41dc:	mov    QWORD PTR [rsp+0x78],rdi
    41e1:	call   41e6 <botlish_fn_20+0x45e>
			41e2: R_X86_64_PLT32	rt_stack_overflow-0x4
    41e6:	xor    rax,rax
    41e9:	mov    rbx,QWORD PTR [rsp+0x90]
    41f1:	mov    r12,QWORD PTR [rsp+0x98]
    41f9:	mov    r13,QWORD PTR [rsp+0xa0]
    4201:	mov    r14,QWORD PTR [rsp+0xa8]
    4209:	mov    r15,QWORD PTR [rsp+0xb0]
    4211:	add    rsp,0xc0
    4218:	mov    rsp,rbp
    421b:	pop    rbp
    421c:	ret
    421d:	add    BYTE PTR [rax],al
    421f:	add    BYTE PTR [rsi],al
    4221:	add    BYTE PTR [rax],al
    4223:	add    BYTE PTR [rax],al
    4225:	add    BYTE PTR [rax],al
	...

0000000000004228 <botlish_entry_20: <str>>:
    4228:	push   rbp
    4229:	mov    rbp,rsp
    422c:	mov    rsi,QWORD PTR [rdx]
    422f:	call   4234 <botlish_entry_20+0xc>
			4230: R_X86_64_PLT32	botlish_fn_20-0x4 ; <str>
    4234:	mov    rsp,rbp
    4237:	pop    rbp
    4238:	ret
    4239:	add    BYTE PTR [rax],al
    423b:	add    BYTE PTR [rax],al
    423d:	add    BYTE PTR [rax],al
	...

0000000000004240 <botlish_fn_21: <generic>>:
    4240:	push   rbp
    4241:	mov    rbp,rsp
    4244:	sub    rsp,0xc0
    424b:	mov    QWORD PTR [rsp+0x90],rbx
    4253:	mov    QWORD PTR [rsp+0x98],r12
    425b:	mov    QWORD PTR [rsp+0xa0],r13
    4263:	mov    QWORD PTR [rsp+0xa8],r14
    426b:	mov    QWORD PTR [rsp+0xb0],r15
    4273:	mov    r12,QWORD PTR [rdi]
    4276:	mov    rax,QWORD PTR [rdi+0x8]
    427a:	lea    rcx,[r12+0x28]
    427f:	cmp    rcx,rax
    4282:	ja     46d2 <botlish_fn_21+0x492>
    4288:	lea    rax,[r12+0x28]
    428d:	mov    QWORD PTR [rdi],rax
    4290:	mov    QWORD PTR [r12+0x10],0x0
    4299:	mov    QWORD PTR [r12+0x18],0x0
    42a2:	mov    QWORD PTR [r12+0x20],0x0
    42ab:	mov    QWORD PTR [r12],rsi
    42af:	xor    eax,eax
    42b1:	test   rsi,0x7
    42b8:	jne    42c7 <botlish_fn_21+0x87>
    42be:	movzx  rax,BYTE PTR [rsi]
    42c2:	cmp    al,0x2
    42c4:	sete   al
    42c7:	test   al,al
    42c9:	jne    42f3 <botlish_fn_21+0xb3>
    42cf:	mov    rax,QWORD PTR [rdi+0x10]
    42d3:	mov    QWORD PTR [rsp+0x78],rdi
    42d8:	mov    rcx,QWORD PTR [rax+0xd8]
    42df:	mov    edx,0x1
    42e4:	call   42e9 <botlish_fn_21+0xa9>
			42e5: R_X86_64_PLT32	rt_type_error-0x4
    42e9:	mov    rdi,QWORD PTR [rsp+0x78]
    42ee:	jmp    45e8 <botlish_fn_21+0x3a8>
    42f3:	mov    r13,rsi
    42f6:	mov    QWORD PTR [rsp+0x78],rdi
    42fb:	call   4300 <botlish_fn_21+0xc0>
			42fc: R_X86_64_PLT32	rt_str_len-0x4
    4300:	mov    rbx,rax
    4303:	mov    QWORD PTR [r12+0x8],rbx
    4308:	lea    r8,[rsp]
    430c:	mov    QWORD PTR [rsp],r13
    4310:	mov    esi,0x16
    4315:	mov    rdx,QWORD PTR [rip+0x0]        # 431c <botlish_fn_21+0xdc>
			4318: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; char_at<generic>
    431c:	mov    r13d,0x1
    4322:	mov    rcx,r13
    4325:	mov    rdi,QWORD PTR [rsp+0x78]
    432a:	call   432f <botlish_fn_21+0xef>
			432b: R_X86_64_PLT32	rt_closure_new-0x4
    432f:	mov    r15,rax
    4332:	mov    QWORD PTR [rsp+0x88],r13
    433a:	mov    QWORD PTR [r12],rax
    433e:	lea    r8,[rsp+0x8]
    4343:	mov    QWORD PTR [rsp+0x8],rbx
    4348:	mov    QWORD PTR [rsp+0x10],rax
    434d:	mov    esi,0x1a
    4352:	mov    rdx,QWORD PTR [rip+0x0]        # 4359 <botlish_fn_21+0x119>
			4355: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; scan_local<generic>
    4359:	mov    r14d,0x2
    435f:	mov    rcx,r14
    4362:	mov    rdi,QWORD PTR [rsp+0x78]
    4367:	call   436c <botlish_fn_21+0x12c>
			4368: R_X86_64_PLT32	rt_closure_new-0x4
    436c:	mov    r13,rax
    436f:	mov    QWORD PTR [r12+0x10],r13
    4374:	lea    r8,[rsp+0x18]
    4379:	mov    QWORD PTR [rsp+0x18],rbx
    437e:	mov    rax,r15
    4381:	mov    QWORD PTR [rsp+0x20],rax
    4386:	mov    esi,0x1b
    438b:	mov    rdx,QWORD PTR [rip+0x0]        # 4392 <botlish_fn_21+0x152>
			438e: R_X86_64_GOTPCREL	botlish_entry_27-0x4 ; scan_label<generic>
    4392:	mov    rcx,r14
    4395:	mov    rdi,QWORD PTR [rsp+0x78]
    439a:	call   439f <botlish_fn_21+0x15f>
			439b: R_X86_64_PLT32	rt_closure_new-0x4
    439f:	mov    QWORD PTR [r12+0x18],rax
    43a4:	mov    QWORD PTR [rsp+0x80],rax
    43ac:	lea    r8,[rsp+0x28]
    43b1:	mov    QWORD PTR [rsp+0x28],rbx
    43b6:	mov    QWORD PTR [rsp+0x30],r15
    43bb:	mov    esi,0x1c
    43c0:	mov    rdx,QWORD PTR [rip+0x0]        # 43c7 <botlish_fn_21+0x187>
			43c3: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; scan_alpha<generic>
    43c7:	mov    rcx,r14
    43ca:	mov    rdi,QWORD PTR [rsp+0x78]
    43cf:	call   43d4 <botlish_fn_21+0x194>
			43d0: R_X86_64_PLT32	rt_closure_new-0x4
    43d4:	mov    QWORD PTR [r12+0x20],rax
    43d9:	lea    r8,[rsp+0x38]
    43de:	mov    QWORD PTR [rsp+0x38],rax
    43e3:	mov    QWORD PTR [rsp+0x40],rbx
    43e8:	mov    esi,0x1d
    43ed:	mov    rdx,QWORD PTR [rip+0x0]        # 43f4 <botlish_fn_21+0x1b4>
			43f0: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; tld_ok<generic>
    43f4:	mov    rcx,r14
    43f7:	mov    rdi,QWORD PTR [rsp+0x78]
    43fc:	call   4401 <botlish_fn_21+0x1c1>
			43fd: R_X86_64_PLT32	rt_closure_new-0x4
    4401:	mov    QWORD PTR [r12+0x20],rax
    4406:	lea    r8,[rsp+0x48]
    440b:	mov    rcx,QWORD PTR [rsp+0x80]
    4413:	mov    QWORD PTR [rsp+0x48],rcx
    4418:	mov    QWORD PTR [rsp+0x50],rbx
    441d:	mov    QWORD PTR [rsp+0x58],r15
    4422:	mov    QWORD PTR [rsp+0x60],rax
    4427:	mov    esi,0x1e
    442c:	mov    rdx,QWORD PTR [rip+0x0]        # 4433 <botlish_fn_21+0x1f3>
			442f: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; domain_loop<generic>
    4433:	mov    ecx,0x4
    4438:	mov    rdi,QWORD PTR [rsp+0x78]
    443d:	call   4442 <botlish_fn_21+0x202>
			443e: R_X86_64_PLT32	rt_closure_new-0x4
    4442:	mov    QWORD PTR [r12+0x18],rax
    4447:	mov    r14,rax
    444a:	mov    QWORD PTR [r12+0x20],0x1
    4453:	mov    rsi,r13
    4456:	mov    rdx,QWORD PTR [rsp+0x88]
    445e:	mov    rdi,QWORD PTR [rsp+0x78]
    4463:	call   4468 <botlish_fn_21+0x228>
			4464: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    4468:	mov    r10,rax
    446b:	mov    r13,rax
    446e:	test   rax,r10
    4471:	jne    4481 <botlish_fn_21+0x241>
    4477:	mov    rdi,QWORD PTR [rsp+0x78]
    447c:	jmp    45e8 <botlish_fn_21+0x3a8>
    4481:	mov    rax,r13
    4484:	mov    QWORD PTR [r12+0x10],rax
    4489:	test   rax,0x1
    448f:	jne    44bf <botlish_fn_21+0x27f>
    4495:	mov    rdx,QWORD PTR [rsp+0x88]
    449d:	mov    rsi,r13
    44a0:	mov    rdi,QWORD PTR [rsp+0x78]
    44a5:	call   44aa <botlish_fn_21+0x26a>
			44a6: R_X86_64_PLT32	rt_int_cmp-0x4
    44aa:	mov    ecx,0x2
    44af:	test   rax,rax
    44b2:	cmove  rcx,QWORD PTR [rip+0x25e]        # 4718 <botlish_fn_21+0x4d8>
    44ba:	jmp    44d0 <botlish_fn_21+0x290>
    44bf:	mov    ecx,0x2
    44c4:	cmp    r13,0x1
    44c8:	cmove  rcx,QWORD PTR [rip+0x248]        # 4718 <botlish_fn_21+0x4d8>
    44d0:	cmp    rcx,0x6
    44d4:	je     468c <botlish_fn_21+0x44c>
    44da:	mov    r11,r13
    44dd:	and    r11,rbx
    44e0:	test   r11,0x1
    44e7:	jne    4512 <botlish_fn_21+0x2d2>
    44ed:	mov    rdx,rbx
    44f0:	mov    rsi,r13
    44f3:	mov    rdi,QWORD PTR [rsp+0x78]
    44f8:	call   44fd <botlish_fn_21+0x2bd>
			44f9: R_X86_64_PLT32	rt_int_cmp-0x4
    44fd:	mov    ecx,0x2
    4502:	test   rax,rax
    4505:	cmovge rcx,QWORD PTR [rip+0x20b]        # 4718 <botlish_fn_21+0x4d8>
    450d:	jmp    4522 <botlish_fn_21+0x2e2>
    4512:	mov    ecx,0x2
    4517:	cmp    r13,rbx
    451a:	cmovge rcx,QWORD PTR [rip+0x1f6]        # 4718 <botlish_fn_21+0x4d8>
    4522:	cmp    rcx,0x6
    4526:	je     467d <botlish_fn_21+0x43d>
    452c:	lea    rcx,[rsp+0x68]
    4531:	mov    rsi,r15
    4534:	mov    rdx,r13
    4537:	mov    rdi,QWORD PTR [rsp+0x78]
    453c:	call   4541 <botlish_fn_21+0x301>
			453d: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    4541:	test   rax,rax
    4544:	mov    rsi,rax
    4547:	jne    4557 <botlish_fn_21+0x317>
    454d:	mov    rdi,QWORD PTR [rsp+0x78]
    4552:	jmp    45e8 <botlish_fn_21+0x3a8>
    4557:	mov    rdx,QWORD PTR [rsp+0x68]
    455c:	mov    rcx,QWORD PTR [rsp+0x70]
    4561:	mov    rdi,QWORD PTR [rsp+0x78]
    4566:	mov    rax,QWORD PTR [rdi+0x10]
    456a:	mov    r8,QWORD PTR [rax+0x100]
    4571:	call   4576 <botlish_fn_21+0x336>
			4572: R_X86_64_PLT32	rt_str_region_eq-0x4
    4576:	cmp    rax,0x6
    457a:	je     458d <botlish_fn_21+0x34d>
    4580:	mov    esi,0x2
    4585:	mov    rax,rsi
    4588:	jmp    4682 <botlish_fn_21+0x442>
    458d:	mov    QWORD PTR [r12],0x3
    4595:	test   r13,0x1
    459c:	je     45b4 <botlish_fn_21+0x374>
    45a2:	mov    rdx,r13
    45a5:	add    rdx,0x2
    45a9:	seto   al
    45ac:	test   al,al
    45ae:	je     45c9 <botlish_fn_21+0x389>
    45b4:	mov    edx,0x3
    45b9:	mov    rsi,r13
    45bc:	mov    rdi,QWORD PTR [rsp+0x78]
    45c1:	call   45c6 <botlish_fn_21+0x386>
			45c2: R_X86_64_PLT32	rt_int_add-0x4
    45c6:	mov    rdx,rax
    45c9:	mov    QWORD PTR [r12],rdx
    45cd:	mov    rsi,r14
    45d0:	mov    rdi,QWORD PTR [rsp+0x78]
    45d5:	call   45da <botlish_fn_21+0x39a>
			45d6: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    45da:	test   rax,rax
    45dd:	jne    4627 <botlish_fn_21+0x3e7>
    45e3:	mov    rdi,QWORD PTR [rsp+0x78]
    45e8:	mov    rdi,QWORD PTR [rsp+0x78]
    45ed:	mov    QWORD PTR [rdi],r12
    45f0:	xor    rax,rax
    45f3:	mov    rbx,QWORD PTR [rsp+0x90]
    45fb:	mov    r12,QWORD PTR [rsp+0x98]
    4603:	mov    r13,QWORD PTR [rsp+0xa0]
    460b:	mov    r14,QWORD PTR [rsp+0xa8]
    4613:	mov    r15,QWORD PTR [rsp+0xb0]
    461b:	add    rsp,0xc0
    4622:	mov    rsp,rbp
    4625:	pop    rbp
    4626:	ret
    4627:	mov    rcx,rax
    462a:	and    rcx,rbx
    462d:	mov    rsi,rax
    4630:	mov    rax,rbx
    4633:	test   rcx,0x1
    463a:	jne    4665 <botlish_fn_21+0x425>
    4640:	mov    rdx,rax
    4643:	mov    rdi,QWORD PTR [rsp+0x78]
    4648:	call   464d <botlish_fn_21+0x40d>
			4649: R_X86_64_PLT32	rt_int_cmp-0x4
    464d:	mov    esi,0x2
    4652:	test   rax,rax
    4655:	mov    rax,rsi
    4658:	cmove  rax,QWORD PTR [rip+0xb8]        # 4718 <botlish_fn_21+0x4d8>
    4660:	jmp    4682 <botlish_fn_21+0x442>
    4665:	mov    rdx,rax
    4668:	mov    eax,0x2
    466d:	cmp    rsi,rdx
    4670:	cmove  rax,QWORD PTR [rip+0xa0]        # 4718 <botlish_fn_21+0x4d8>
    4678:	jmp    4682 <botlish_fn_21+0x442>
    467d:	mov    eax,0x2
    4682:	mov    rdi,QWORD PTR [rsp+0x78]
    4687:	jmp    4696 <botlish_fn_21+0x456>
    468c:	mov    eax,0x2
    4691:	mov    rdi,QWORD PTR [rsp+0x78]
    4696:	mov    rdi,QWORD PTR [rsp+0x78]
    469b:	mov    QWORD PTR [rdi],r12
    469e:	mov    rbx,QWORD PTR [rsp+0x90]
    46a6:	mov    r12,QWORD PTR [rsp+0x98]
    46ae:	mov    r13,QWORD PTR [rsp+0xa0]
    46b6:	mov    r14,QWORD PTR [rsp+0xa8]
    46be:	mov    r15,QWORD PTR [rsp+0xb0]
    46c6:	add    rsp,0xc0
    46cd:	mov    rsp,rbp
    46d0:	pop    rbp
    46d1:	ret
    46d2:	mov    QWORD PTR [rsp+0x78],rdi
    46d7:	call   46dc <botlish_fn_21+0x49c>
			46d8: R_X86_64_PLT32	rt_stack_overflow-0x4
    46dc:	xor    rax,rax
    46df:	mov    rbx,QWORD PTR [rsp+0x90]
    46e7:	mov    r12,QWORD PTR [rsp+0x98]
    46ef:	mov    r13,QWORD PTR [rsp+0xa0]
    46f7:	mov    r14,QWORD PTR [rsp+0xa8]
    46ff:	mov    r15,QWORD PTR [rsp+0xb0]
    4707:	add    rsp,0xc0
    470e:	mov    rsp,rbp
    4711:	pop    rbp
    4712:	ret
    4713:	add    BYTE PTR [rax],al
    4715:	add    BYTE PTR [rax],al
    4717:	add    BYTE PTR [rsi],al
    4719:	add    BYTE PTR [rax],al
    471b:	add    BYTE PTR [rax],al
    471d:	add    BYTE PTR [rax],al
	...

0000000000004720 <botlish_entry_21: <generic>>:
    4720:	push   rbp
    4721:	mov    rbp,rsp
    4724:	mov    rsi,QWORD PTR [rdx]
    4727:	call   472c <botlish_entry_21+0xc>
			4728: R_X86_64_PLT32	botlish_fn_21-0x4 ; <generic>
    472c:	mov    rsp,rbp
    472f:	pop    rbp
    4730:	ret

0000000000004731 <botlish_fn_22: char_at<generic>>:
    4731:	push   rbp
    4732:	mov    rbp,rsp
    4735:	sub    rsp,0x20
    4739:	mov    QWORD PTR [rsp],rbx
    473d:	mov    QWORD PTR [rsp+0x8],r12
    4742:	mov    QWORD PTR [rsp+0x10],r13
    4747:	mov    QWORD PTR [rsp+0x18],r14
    474c:	mov    rbx,QWORD PTR [rdi]
    474f:	mov    rax,QWORD PTR [rdi+0x8]
    4753:	lea    rcx,[rbx+0x18]
    4757:	cmp    rcx,rax
    475a:	ja     48e2 <botlish_fn_22+0x1b1>
    4760:	lea    rax,[rbx+0x18]
    4764:	mov    QWORD PTR [rdi],rax
    4767:	mov    QWORD PTR [rbx],rdx
    476a:	mov    rax,QWORD PTR [rsi+0x20]
    476e:	mov    rsi,QWORD PTR [rax]
    4771:	mov    QWORD PTR [rbx+0x8],rsi
    4775:	mov    r14,rsi
    4778:	mov    QWORD PTR [rbx+0x10],0x3
    4780:	mov    ecx,0x1
    4785:	test   rdx,0x1
    478c:	je     479a <botlish_fn_22+0x69>
    4792:	mov    r13,rdx
    4795:	jmp    47bd <botlish_fn_22+0x8c>
    479a:	xor    ecx,ecx
    479c:	test   rdx,0x7
    47a3:	je     47b1 <botlish_fn_22+0x80>
    47a9:	mov    r13,rdx
    47ac:	jmp    47bd <botlish_fn_22+0x8c>
    47b1:	movzx  rax,BYTE PTR [rdx]
    47b5:	mov    r13,rdx
    47b8:	cmp    al,0x1
    47ba:	sete   cl
    47bd:	test   cl,cl
    47bf:	jne    47e6 <botlish_fn_22+0xb5>
    47c5:	mov    rax,QWORD PTR [rdi+0x10]
    47c9:	mov    r12,rdi
    47cc:	mov    rcx,QWORD PTR [rax+0x108]
    47d3:	xor    rdx,rdx
    47d6:	mov    rsi,r13
    47d9:	call   47de <botlish_fn_22+0xad>
			47da: R_X86_64_PLT32	rt_type_error-0x4
    47de:	mov    rdi,r12
    47e1:	jmp    489b <botlish_fn_22+0x16a>
    47e6:	mov    rsi,r13
    47e9:	mov    r12,rdi
    47ec:	test   rsi,0x1
    47f3:	je     480e <botlish_fn_22+0xdd>
    47f9:	mov    rsi,r13
    47fc:	mov    rcx,rsi
    47ff:	add    rcx,0x2
    4803:	seto   dl
    4806:	test   dl,dl
    4808:	je     4821 <botlish_fn_22+0xf0>
    480e:	mov    edx,0x3
    4813:	mov    rsi,r13
    4816:	mov    rdi,r12
    4819:	call   481e <botlish_fn_22+0xed>
			481a: R_X86_64_PLT32	rt_int_add-0x4
    481e:	mov    rcx,rax
    4821:	mov    QWORD PTR [rbx+0x10],rcx
    4825:	mov    edx,0x1
    482a:	mov    rsi,r13
    482d:	test   rsi,0x1
    4834:	jne    4858 <botlish_fn_22+0x127>
    483a:	xor    edx,edx
    483c:	mov    rsi,r13
    483f:	test   rsi,0x7
    4846:	jne    4858 <botlish_fn_22+0x127>
    484c:	mov    rsi,r13
    484f:	movzx  rax,BYTE PTR [rsi]
    4853:	cmp    al,0x1
    4855:	sete   dl
    4858:	test   dl,dl
    485a:	jne    4881 <botlish_fn_22+0x150>
    4860:	mov    rdi,r12
    4863:	mov    rax,QWORD PTR [rdi+0x10]
    4867:	mov    rcx,QWORD PTR [rax+0x110]
    486e:	xor    rdx,rdx
    4871:	mov    rsi,r13
    4874:	call   4879 <botlish_fn_22+0x148>
			4875: R_X86_64_PLT32	rt_type_error-0x4
    4879:	mov    rdi,r12
    487c:	jmp    489b <botlish_fn_22+0x16a>
    4881:	mov    rdx,r13
    4884:	mov    rsi,r14
    4887:	mov    rdi,r12
    488a:	call   488f <botlish_fn_22+0x15e>
			488b: R_X86_64_PLT32	rt_substr-0x4
    488f:	test   rax,rax
    4892:	jne    48c0 <botlish_fn_22+0x18f>
    4898:	mov    rdi,r12
    489b:	mov    rdi,r12
    489e:	mov    QWORD PTR [rdi],rbx
    48a1:	xor    rax,rax
    48a4:	mov    rbx,QWORD PTR [rsp]
    48a8:	mov    r12,QWORD PTR [rsp+0x8]
    48ad:	mov    r13,QWORD PTR [rsp+0x10]
    48b2:	mov    r14,QWORD PTR [rsp+0x18]
    48b7:	add    rsp,0x20
    48bb:	mov    rsp,rbp
    48be:	pop    rbp
    48bf:	ret
    48c0:	mov    rdi,r12
    48c3:	mov    QWORD PTR [rdi],rbx
    48c6:	mov    rbx,QWORD PTR [rsp]
    48ca:	mov    r12,QWORD PTR [rsp+0x8]
    48cf:	mov    r13,QWORD PTR [rsp+0x10]
    48d4:	mov    r14,QWORD PTR [rsp+0x18]
    48d9:	add    rsp,0x20
    48dd:	mov    rsp,rbp
    48e0:	pop    rbp
    48e1:	ret
    48e2:	mov    r12,rdi
    48e5:	call   48ea <botlish_fn_22+0x1b9>
			48e6: R_X86_64_PLT32	rt_stack_overflow-0x4
    48ea:	xor    rax,rax
    48ed:	mov    rbx,QWORD PTR [rsp]
    48f1:	mov    r12,QWORD PTR [rsp+0x8]
    48f6:	mov    r13,QWORD PTR [rsp+0x10]
    48fb:	mov    r14,QWORD PTR [rsp+0x18]
    4900:	add    rsp,0x20
    4904:	mov    rsp,rbp
    4907:	pop    rbp
    4908:	ret

0000000000004909 <botlish_entry_22: char_at<generic>>:
    4909:	push   rbp
    490a:	mov    rbp,rsp
    490d:	mov    rdx,QWORD PTR [rdx]
    4910:	call   4915 <botlish_entry_22+0xc>
			4911: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    4915:	mov    rsp,rbp
    4918:	pop    rbp
    4919:	ret

000000000000491a <botlish_fn_23: char_at<generic>>:
    491a:	push   rbp
    491b:	mov    rbp,rsp
    491e:	sub    rsp,0x40
    4922:	mov    QWORD PTR [rsp+0x10],rbx
    4927:	mov    QWORD PTR [rsp+0x18],r12
    492c:	mov    QWORD PTR [rsp+0x20],r13
    4931:	mov    QWORD PTR [rsp+0x28],r14
    4936:	mov    QWORD PTR [rsp+0x30],r15
    493b:	mov    r15,rcx
    493e:	mov    rbx,QWORD PTR [rdi]
    4941:	mov    rax,QWORD PTR [rdi+0x8]
    4945:	lea    rcx,[rbx+0x18]
    4949:	cmp    rcx,rax
    494c:	ja     4b02 <botlish_fn_23+0x1e8>
    4952:	lea    rax,[rbx+0x18]
    4956:	mov    QWORD PTR [rdi],rax
    4959:	mov    QWORD PTR [rbx],rdx
    495c:	mov    rax,QWORD PTR [rsi+0x20]
    4960:	mov    rax,QWORD PTR [rax]
    4963:	mov    QWORD PTR [rbx+0x8],rax
    4967:	mov    QWORD PTR [rsp],rax
    496b:	mov    QWORD PTR [rbx+0x10],0x3
    4973:	mov    eax,0x1
    4978:	test   rdx,0x1
    497f:	je     498d <botlish_fn_23+0x73>
    4985:	mov    r14,rdx
    4988:	jmp    49b0 <botlish_fn_23+0x96>
    498d:	xor    eax,eax
    498f:	test   rdx,0x7
    4996:	je     49a4 <botlish_fn_23+0x8a>
    499c:	mov    r14,rdx
    499f:	jmp    49b0 <botlish_fn_23+0x96>
    49a4:	movzx  rax,BYTE PTR [rdx]
    49a8:	mov    r14,rdx
    49ab:	cmp    al,0x1
    49ad:	sete   al
    49b0:	test   al,al
    49b2:	jne    49d9 <botlish_fn_23+0xbf>
    49b8:	mov    rax,QWORD PTR [rdi+0x10]
    49bc:	mov    r13,rdi
    49bf:	mov    rcx,QWORD PTR [rax+0x108]
    49c6:	xor    rdx,rdx
    49c9:	mov    rsi,r14
    49cc:	call   49d1 <botlish_fn_23+0xb7>
			49cd: R_X86_64_PLT32	rt_type_error-0x4
    49d1:	mov    rdi,r13
    49d4:	jmp    4a9e <botlish_fn_23+0x184>
    49d9:	mov    rsi,r14
    49dc:	mov    r13,rdi
    49df:	test   rsi,0x1
    49e6:	jne    49f4 <botlish_fn_23+0xda>
    49ec:	mov    r14,rsi
    49ef:	jmp    4a11 <botlish_fn_23+0xf7>
    49f4:	mov    rax,rsi
    49f7:	add    rax,0x2
    49fb:	mov    r14,rsi
    49fe:	seto   dl
    4a01:	test   dl,dl
    4a03:	jne    4a11 <botlish_fn_23+0xf7>
    4a09:	mov    r12,rax
    4a0c:	jmp    4a24 <botlish_fn_23+0x10a>
    4a11:	mov    edx,0x3
    4a16:	mov    rsi,r14
    4a19:	mov    rdi,r13
    4a1c:	call   4a21 <botlish_fn_23+0x107>
			4a1d: R_X86_64_PLT32	rt_int_add-0x4
    4a21:	mov    r12,rax
    4a24:	mov    ecx,0x1
    4a29:	mov    rsi,r14
    4a2c:	test   rsi,0x1
    4a33:	jne    4a57 <botlish_fn_23+0x13d>
    4a39:	xor    ecx,ecx
    4a3b:	mov    rsi,r14
    4a3e:	test   rsi,0x7
    4a45:	jne    4a57 <botlish_fn_23+0x13d>
    4a4b:	mov    rsi,r14
    4a4e:	movzx  rax,BYTE PTR [rsi]
    4a52:	cmp    al,0x1
    4a54:	sete   cl
    4a57:	test   cl,cl
    4a59:	jne    4a80 <botlish_fn_23+0x166>
    4a5f:	mov    rdi,r13
    4a62:	mov    rax,QWORD PTR [rdi+0x10]
    4a66:	mov    rcx,QWORD PTR [rax+0x110]
    4a6d:	xor    rdx,rdx
    4a70:	mov    rsi,r14
    4a73:	call   4a78 <botlish_fn_23+0x15e>
			4a74: R_X86_64_PLT32	rt_type_error-0x4
    4a78:	mov    rdi,r13
    4a7b:	jmp    4a9e <botlish_fn_23+0x184>
    4a80:	mov    rcx,r12
    4a83:	mov    rdx,r14
    4a86:	mov    rsi,QWORD PTR [rsp]
    4a8a:	mov    rdi,r13
    4a8d:	call   4a92 <botlish_fn_23+0x178>
			4a8e: R_X86_64_PLT32	rt_str_region_check-0x4
    4a92:	test   rax,rax
    4a95:	jne    4ac9 <botlish_fn_23+0x1af>
    4a9b:	mov    rdi,r13
    4a9e:	mov    rdi,r13
    4aa1:	mov    QWORD PTR [rdi],rbx
    4aa4:	xor    rax,rax
    4aa7:	mov    rbx,QWORD PTR [rsp+0x10]
    4aac:	mov    r12,QWORD PTR [rsp+0x18]
    4ab1:	mov    r13,QWORD PTR [rsp+0x20]
    4ab6:	mov    r14,QWORD PTR [rsp+0x28]
    4abb:	mov    r15,QWORD PTR [rsp+0x30]
    4ac0:	add    rsp,0x40
    4ac4:	mov    rsp,rbp
    4ac7:	pop    rbp
    4ac8:	ret
    4ac9:	mov    rdi,r13
    4acc:	mov    QWORD PTR [rdi],rbx
    4acf:	mov    rcx,r15
    4ad2:	mov    rsi,r14
    4ad5:	mov    QWORD PTR [rcx],rsi
    4ad8:	mov    QWORD PTR [rcx+0x8],r12
    4adc:	mov    rax,QWORD PTR [rsp]
    4ae0:	mov    rbx,QWORD PTR [rsp+0x10]
    4ae5:	mov    r12,QWORD PTR [rsp+0x18]
    4aea:	mov    r13,QWORD PTR [rsp+0x20]
    4aef:	mov    r14,QWORD PTR [rsp+0x28]
    4af4:	mov    r15,QWORD PTR [rsp+0x30]
    4af9:	add    rsp,0x40
    4afd:	mov    rsp,rbp
    4b00:	pop    rbp
    4b01:	ret
    4b02:	mov    r13,rdi
    4b05:	call   4b0a <botlish_fn_23+0x1f0>
			4b06: R_X86_64_PLT32	rt_stack_overflow-0x4
    4b0a:	xor    rax,rax
    4b0d:	mov    rbx,QWORD PTR [rsp+0x10]
    4b12:	mov    r12,QWORD PTR [rsp+0x18]
    4b17:	mov    r13,QWORD PTR [rsp+0x20]
    4b1c:	mov    r14,QWORD PTR [rsp+0x28]
    4b21:	mov    r15,QWORD PTR [rsp+0x30]
    4b26:	add    rsp,0x40
    4b2a:	mov    rsp,rbp
    4b2d:	pop    rbp
    4b2e:	ret

0000000000004b2f <botlish_entry_23: char_at<generic>>:
    4b2f:	push   rbp
    4b30:	mov    rbp,rsp
    4b33:	ud2

0000000000004b35 <botlish_fn_24: is_local_char<str>>:
    4b35:	push   rbp
    4b36:	mov    rbp,rsp
    4b39:	sub    rsp,0x20
    4b3d:	mov    QWORD PTR [rsp],rbx
    4b41:	mov    QWORD PTR [rsp+0x8],r12
    4b46:	mov    QWORD PTR [rsp+0x10],r13
    4b4b:	mov    r13,rsi
    4b4e:	mov    rbx,QWORD PTR [rdi]
    4b51:	mov    rax,QWORD PTR [rdi+0x8]
    4b55:	lea    rcx,[rbx+0x8]
    4b59:	cmp    rcx,rax
    4b5c:	ja     4cc7 <botlish_fn_24+0x192>
    4b62:	lea    rax,[rbx+0x8]
    4b66:	mov    QWORD PTR [rdi],rax
    4b69:	mov    r12,rdi
    4b6c:	mov    rsi,r13
    4b6f:	mov    rdi,r12
    4b72:	call   4b77 <botlish_fn_24+0x42>
			4b73: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    4b77:	test   rax,rax
    4b7a:	jne    4ba0 <botlish_fn_24+0x6b>
    4b80:	mov    rdi,r12
    4b83:	mov    QWORD PTR [rdi],rbx
    4b86:	xor    rax,rax
    4b89:	mov    rbx,QWORD PTR [rsp]
    4b8d:	mov    r12,QWORD PTR [rsp+0x8]
    4b92:	mov    r13,QWORD PTR [rsp+0x10]
    4b97:	add    rsp,0x20
    4b9b:	mov    rsp,rbp
    4b9e:	pop    rbp
    4b9f:	ret
    4ba0:	cmp    rax,0x6
    4ba4:	je     4ca2 <botlish_fn_24+0x16d>
    4baa:	mov    rdi,r12
    4bad:	mov    rax,QWORD PTR [rdi+0x10]
    4bb1:	mov    rsi,QWORD PTR [rax+0x118]
    4bb8:	mov    edx,0x1
    4bbd:	mov    ecx,0x3
    4bc2:	mov    r8,r13
    4bc5:	call   4bca <botlish_fn_24+0x95>
			4bc6: R_X86_64_PLT32	rt_str_region_eq-0x4
    4bca:	cmp    rax,0x6
    4bce:	je     4c95 <botlish_fn_24+0x160>
    4bd4:	mov    rdi,r12
    4bd7:	mov    rax,QWORD PTR [rdi+0x10]
    4bdb:	mov    rsi,QWORD PTR [rax+0x120]
    4be2:	mov    edx,0x1
    4be7:	mov    ecx,0x3
    4bec:	mov    r8,r13
    4bef:	call   4bf4 <botlish_fn_24+0xbf>
			4bf0: R_X86_64_PLT32	rt_str_region_eq-0x4
    4bf4:	cmp    rax,0x6
    4bf8:	je     4c8b <botlish_fn_24+0x156>
    4bfe:	mov    rdi,r12
    4c01:	mov    rax,QWORD PTR [rdi+0x10]
    4c05:	mov    rsi,QWORD PTR [rax+0xc0]
    4c0c:	mov    edx,0x1
    4c11:	mov    ecx,0x3
    4c16:	mov    r8,r13
    4c19:	call   4c1e <botlish_fn_24+0xe9>
			4c1a: R_X86_64_PLT32	rt_str_region_eq-0x4
    4c1e:	cmp    rax,0x6
    4c22:	je     4c81 <botlish_fn_24+0x14c>
    4c28:	mov    rdi,r12
    4c2b:	mov    rax,QWORD PTR [rdi+0x10]
    4c2f:	mov    rsi,QWORD PTR [rax+0x108]
    4c36:	mov    edx,0x1
    4c3b:	mov    ecx,0x3
    4c40:	mov    r8,r13
    4c43:	call   4c48 <botlish_fn_24+0x113>
			4c44: R_X86_64_PLT32	rt_str_region_eq-0x4
    4c48:	cmp    rax,0x6
    4c4c:	je     4c77 <botlish_fn_24+0x142>
    4c52:	mov    rdi,r12
    4c55:	mov    rdx,QWORD PTR [rdi+0x10]
    4c59:	mov    rsi,QWORD PTR [rdx+0x128]
    4c60:	mov    edx,0x1
    4c65:	mov    ecx,0x3
    4c6a:	mov    r8,r13
    4c6d:	call   4c72 <botlish_fn_24+0x13d>
			4c6e: R_X86_64_PLT32	rt_str_region_eq-0x4
    4c72:	jmp    4c9a <botlish_fn_24+0x165>
    4c77:	mov    eax,0x6
    4c7c:	jmp    4c9a <botlish_fn_24+0x165>
    4c81:	mov    eax,0x6
    4c86:	jmp    4c9a <botlish_fn_24+0x165>
    4c8b:	mov    eax,0x6
    4c90:	jmp    4c9a <botlish_fn_24+0x165>
    4c95:	mov    eax,0x6
    4c9a:	mov    rdi,r12
    4c9d:	jmp    4caa <botlish_fn_24+0x175>
    4ca2:	mov    eax,0x6
    4ca7:	mov    rdi,r12
    4caa:	mov    rdi,r12
    4cad:	mov    QWORD PTR [rdi],rbx
    4cb0:	mov    rbx,QWORD PTR [rsp]
    4cb4:	mov    r12,QWORD PTR [rsp+0x8]
    4cb9:	mov    r13,QWORD PTR [rsp+0x10]
    4cbe:	add    rsp,0x20
    4cc2:	mov    rsp,rbp
    4cc5:	pop    rbp
    4cc6:	ret
    4cc7:	mov    r12,rdi
    4cca:	call   4ccf <botlish_fn_24+0x19a>
			4ccb: R_X86_64_PLT32	rt_stack_overflow-0x4
    4ccf:	xor    rax,rax
    4cd2:	mov    rbx,QWORD PTR [rsp]
    4cd6:	mov    r12,QWORD PTR [rsp+0x8]
    4cdb:	mov    r13,QWORD PTR [rsp+0x10]
    4ce0:	add    rsp,0x20
    4ce4:	mov    rsp,rbp
    4ce7:	pop    rbp
    4ce8:	ret

0000000000004ce9 <botlish_entry_24: is_local_char<str>>:
    4ce9:	push   rbp
    4cea:	mov    rbp,rsp
    4ced:	mov    rsi,QWORD PTR [rdx]
    4cf0:	call   4cf5 <botlish_entry_24+0xc>
			4cf1: R_X86_64_PLT32	botlish_fn_24-0x4 ; is_local_char<str>
    4cf5:	mov    rsp,rbp
    4cf8:	pop    rbp
    4cf9:	ret

0000000000004cfa <botlish_fn_25: is_label_char<str>>:
    4cfa:	push   rbp
    4cfb:	mov    rbp,rsp
    4cfe:	sub    rsp,0x20
    4d02:	mov    QWORD PTR [rsp],rbx
    4d06:	mov    QWORD PTR [rsp+0x8],r12
    4d0b:	mov    QWORD PTR [rsp+0x10],r13
    4d10:	mov    r13,rsi
    4d13:	mov    rbx,QWORD PTR [rdi]
    4d16:	mov    rax,QWORD PTR [rdi+0x8]
    4d1a:	lea    rcx,[rbx+0x8]
    4d1e:	cmp    rcx,rax
    4d21:	ja     4dbc <botlish_fn_25+0xc2>
    4d27:	lea    rax,[rbx+0x8]
    4d2b:	mov    QWORD PTR [rdi],rax
    4d2e:	mov    r12,rdi
    4d31:	mov    rsi,r13
    4d34:	mov    rdi,r12
    4d37:	call   4d3c <botlish_fn_25+0x42>
			4d38: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    4d3c:	test   rax,rax
    4d3f:	jne    4d65 <botlish_fn_25+0x6b>
    4d45:	mov    rdi,r12
    4d48:	mov    QWORD PTR [rdi],rbx
    4d4b:	xor    rax,rax
    4d4e:	mov    rbx,QWORD PTR [rsp]
    4d52:	mov    r12,QWORD PTR [rsp+0x8]
    4d57:	mov    r13,QWORD PTR [rsp+0x10]
    4d5c:	add    rsp,0x20
    4d60:	mov    rsp,rbp
    4d63:	pop    rbp
    4d64:	ret
    4d65:	cmp    rax,0x6
    4d69:	je     4d97 <botlish_fn_25+0x9d>
    4d6f:	mov    rdi,r12
    4d72:	mov    rax,QWORD PTR [rdi+0x10]
    4d76:	mov    rsi,QWORD PTR [rax+0x128]
    4d7d:	mov    edx,0x1
    4d82:	mov    ecx,0x3
    4d87:	mov    r8,r13
    4d8a:	call   4d8f <botlish_fn_25+0x95>
			4d8b: R_X86_64_PLT32	rt_str_region_eq-0x4
    4d8f:	mov    rdi,r12
    4d92:	jmp    4d9f <botlish_fn_25+0xa5>
    4d97:	mov    eax,0x6
    4d9c:	mov    rdi,r12
    4d9f:	mov    rdi,r12
    4da2:	mov    QWORD PTR [rdi],rbx
    4da5:	mov    rbx,QWORD PTR [rsp]
    4da9:	mov    r12,QWORD PTR [rsp+0x8]
    4dae:	mov    r13,QWORD PTR [rsp+0x10]
    4db3:	add    rsp,0x20
    4db7:	mov    rsp,rbp
    4dba:	pop    rbp
    4dbb:	ret
    4dbc:	mov    r12,rdi
    4dbf:	call   4dc4 <botlish_fn_25+0xca>
			4dc0: R_X86_64_PLT32	rt_stack_overflow-0x4
    4dc4:	xor    rax,rax
    4dc7:	mov    rbx,QWORD PTR [rsp]
    4dcb:	mov    r12,QWORD PTR [rsp+0x8]
    4dd0:	mov    r13,QWORD PTR [rsp+0x10]
    4dd5:	add    rsp,0x20
    4dd9:	mov    rsp,rbp
    4ddc:	pop    rbp
    4ddd:	ret

0000000000004dde <botlish_entry_25: is_label_char<str>>:
    4dde:	push   rbp
    4ddf:	mov    rbp,rsp
    4de2:	mov    rsi,QWORD PTR [rdx]
    4de5:	call   4dea <botlish_entry_25+0xc>
			4de6: R_X86_64_PLT32	botlish_fn_25-0x4 ; is_label_char<str>
    4dea:	mov    rsp,rbp
    4ded:	pop    rbp
    4dee:	ret
	...

0000000000004df0 <botlish_fn_26: scan_local<generic>>:
    4df0:	push   rbp
    4df1:	mov    rbp,rsp
    4df4:	sub    rsp,0x20
    4df8:	mov    QWORD PTR [rsp],rbx
    4dfc:	mov    QWORD PTR [rsp+0x8],r12
    4e01:	mov    QWORD PTR [rsp+0x10],r13
    4e06:	mov    QWORD PTR [rsp+0x18],r14
    4e0b:	mov    r12,QWORD PTR [rdi]
    4e0e:	mov    rax,QWORD PTR [rdi+0x8]
    4e12:	lea    rcx,[r12+0x18]
    4e17:	cmp    rcx,rax
    4e1a:	ja     4fee <botlish_fn_26+0x1fe>
    4e20:	lea    rax,[r12+0x18]
    4e25:	mov    QWORD PTR [rdi],rax
    4e28:	mov    r13,rdi
    4e2b:	mov    QWORD PTR [r12+0x10],0x0
    4e34:	mov    QWORD PTR [r12],rdx
    4e38:	mov    rbx,rsi
    4e3b:	mov    rsi,rdx
    4e3e:	mov    rax,QWORD PTR [rbx+0x20]
    4e42:	mov    rdx,QWORD PTR [rax]
    4e45:	mov    ecx,0x1
    4e4a:	test   rsi,0x1
    4e51:	jne    4e6f <botlish_fn_26+0x7f>
    4e57:	xor    ecx,ecx
    4e59:	test   rsi,0x7
    4e60:	jne    4e6f <botlish_fn_26+0x7f>
    4e66:	movzx  rax,BYTE PTR [rsi]
    4e6a:	cmp    al,0x1
    4e6c:	sete   cl
    4e6f:	test   cl,cl
    4e71:	jne    4e95 <botlish_fn_26+0xa5>
    4e77:	mov    rdi,r13
    4e7a:	mov    rax,QWORD PTR [rdi+0x10]
    4e7e:	mov    rcx,QWORD PTR [rax+0xb8]
    4e85:	xor    rdx,rdx
    4e88:	call   4e8d <botlish_fn_26+0x9d>
			4e89: R_X86_64_PLT32	rt_type_error-0x4
    4e8d:	mov    rdi,r13
    4e90:	jmp    4f2c <botlish_fn_26+0x13c>
    4e95:	mov    rax,rsi
    4e98:	and    rax,rdx
    4e9b:	mov    r14,rsi
    4e9e:	test   rax,0x1
    4ea4:	jne    4eca <botlish_fn_26+0xda>
    4eaa:	mov    rsi,r14
    4ead:	mov    rdi,r13
    4eb0:	call   4eb5 <botlish_fn_26+0xc5>
			4eb1: R_X86_64_PLT32	rt_int_cmp-0x4
    4eb5:	mov    ecx,0x2
    4eba:	test   rax,rax
    4ebd:	cmovge rcx,QWORD PTR [rip+0x153]        # 5018 <botlish_fn_26+0x228>
    4ec5:	jmp    4edd <botlish_fn_26+0xed>
    4eca:	mov    ecx,0x2
    4ecf:	mov    rsi,r14
    4ed2:	cmp    rsi,rdx
    4ed5:	cmovge rcx,QWORD PTR [rip+0x13b]        # 5018 <botlish_fn_26+0x228>
    4edd:	cmp    rcx,0x6
    4ee1:	je     4fc6 <botlish_fn_26+0x1d6>
    4ee7:	mov    rsi,QWORD PTR [rbx+0x20]
    4eeb:	mov    rsi,QWORD PTR [rsi+0x8]
    4eef:	mov    QWORD PTR [r12+0x8],rsi
    4ef4:	mov    rdx,r14
    4ef7:	mov    rdi,r13
    4efa:	call   4eff <botlish_fn_26+0x10f>
			4efb: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    4eff:	test   rax,rax
    4f02:	jne    4f10 <botlish_fn_26+0x120>
    4f08:	mov    rdi,r13
    4f0b:	jmp    4f2c <botlish_fn_26+0x13c>
    4f10:	mov    QWORD PTR [r12+0x8],rax
    4f15:	mov    rsi,rax
    4f18:	mov    rdi,r13
    4f1b:	call   4f20 <botlish_fn_26+0x130>
			4f1c: R_X86_64_PLT32	botlish_fn_24-0x4 ; is_local_char<str>
    4f20:	test   rax,rax
    4f23:	jne    4f51 <botlish_fn_26+0x161>
    4f29:	mov    rdi,r13
    4f2c:	mov    rdi,r13
    4f2f:	mov    QWORD PTR [rdi],r12
    4f32:	xor    rax,rax
    4f35:	mov    rbx,QWORD PTR [rsp]
    4f39:	mov    r12,QWORD PTR [rsp+0x8]
    4f3e:	mov    r13,QWORD PTR [rsp+0x10]
    4f43:	mov    r14,QWORD PTR [rsp+0x18]
    4f48:	add    rsp,0x20
    4f4c:	mov    rsp,rbp
    4f4f:	pop    rbp
    4f50:	ret
    4f51:	cmp    rax,0x6
    4f55:	je     4f66 <botlish_fn_26+0x176>
    4f5b:	mov    rax,r14
    4f5e:	mov    rdi,r13
    4f61:	jmp    4fcc <botlish_fn_26+0x1dc>
    4f66:	mov    QWORD PTR [r12+0x8],rbx
    4f6b:	mov    QWORD PTR [r12+0x10],0x3
    4f74:	mov    rsi,r14
    4f77:	test   rsi,0x1
    4f7e:	je     4fa4 <botlish_fn_26+0x1b4>
    4f84:	mov    rsi,r14
    4f87:	mov    rcx,rsi
    4f8a:	add    rcx,0x2
    4f8e:	seto   al
    4f91:	test   al,al
    4f93:	jne    4fa4 <botlish_fn_26+0x1b4>
    4f99:	mov    rsi,rcx
    4f9c:	mov    r14,rcx
    4f9f:	jmp    4fba <botlish_fn_26+0x1ca>
    4fa4:	mov    edx,0x3
    4fa9:	mov    rsi,r14
    4fac:	mov    rdi,r13
    4faf:	call   4fb4 <botlish_fn_26+0x1c4>
			4fb0: R_X86_64_PLT32	rt_int_add-0x4
    4fb4:	mov    rsi,rax
    4fb7:	mov    r14,rax
    4fba:	mov    QWORD PTR [r12],rsi
    4fbe:	mov    rsi,r14
    4fc1:	jmp    4e3e <botlish_fn_26+0x4e>
    4fc6:	mov    rax,r14
    4fc9:	mov    rdi,r13
    4fcc:	mov    rdi,r13
    4fcf:	mov    QWORD PTR [rdi],r12
    4fd2:	mov    rbx,QWORD PTR [rsp]
    4fd6:	mov    r12,QWORD PTR [rsp+0x8]
    4fdb:	mov    r13,QWORD PTR [rsp+0x10]
    4fe0:	mov    r14,QWORD PTR [rsp+0x18]
    4fe5:	add    rsp,0x20
    4fe9:	mov    rsp,rbp
    4fec:	pop    rbp
    4fed:	ret
    4fee:	mov    r13,rdi
    4ff1:	call   4ff6 <botlish_fn_26+0x206>
			4ff2: R_X86_64_PLT32	rt_stack_overflow-0x4
    4ff6:	xor    rax,rax
    4ff9:	mov    rbx,QWORD PTR [rsp]
    4ffd:	mov    r12,QWORD PTR [rsp+0x8]
    5002:	mov    r13,QWORD PTR [rsp+0x10]
    5007:	mov    r14,QWORD PTR [rsp+0x18]
    500c:	add    rsp,0x20
    5010:	mov    rsp,rbp
    5013:	pop    rbp
    5014:	ret
    5015:	add    BYTE PTR [rax],al
    5017:	add    BYTE PTR [rsi],al
    5019:	add    BYTE PTR [rax],al
    501b:	add    BYTE PTR [rax],al
    501d:	add    BYTE PTR [rax],al
	...

0000000000005020 <botlish_entry_26: scan_local<generic>>:
    5020:	push   rbp
    5021:	mov    rbp,rsp
    5024:	mov    rdx,QWORD PTR [rdx]
    5027:	call   502c <botlish_entry_26+0xc>
			5028: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    502c:	mov    rsp,rbp
    502f:	pop    rbp
    5030:	ret
    5031:	add    BYTE PTR [rax],al
    5033:	add    BYTE PTR [rax],al
    5035:	add    BYTE PTR [rax],al
	...

0000000000005038 <botlish_fn_27: scan_label<generic>>:
    5038:	push   rbp
    5039:	mov    rbp,rsp
    503c:	sub    rsp,0x20
    5040:	mov    QWORD PTR [rsp],rbx
    5044:	mov    QWORD PTR [rsp+0x8],r12
    5049:	mov    QWORD PTR [rsp+0x10],r13
    504e:	mov    QWORD PTR [rsp+0x18],r14
    5053:	mov    r12,QWORD PTR [rdi]
    5056:	mov    rax,QWORD PTR [rdi+0x8]
    505a:	lea    rcx,[r12+0x18]
    505f:	cmp    rcx,rax
    5062:	ja     5236 <botlish_fn_27+0x1fe>
    5068:	lea    rax,[r12+0x18]
    506d:	mov    QWORD PTR [rdi],rax
    5070:	mov    r13,rdi
    5073:	mov    QWORD PTR [r12+0x10],0x0
    507c:	mov    QWORD PTR [r12],rdx
    5080:	mov    rbx,rsi
    5083:	mov    rsi,rdx
    5086:	mov    rax,QWORD PTR [rbx+0x20]
    508a:	mov    rdx,QWORD PTR [rax]
    508d:	mov    ecx,0x1
    5092:	test   rsi,0x1
    5099:	jne    50b7 <botlish_fn_27+0x7f>
    509f:	xor    ecx,ecx
    50a1:	test   rsi,0x7
    50a8:	jne    50b7 <botlish_fn_27+0x7f>
    50ae:	movzx  rax,BYTE PTR [rsi]
    50b2:	cmp    al,0x1
    50b4:	sete   cl
    50b7:	test   cl,cl
    50b9:	jne    50dd <botlish_fn_27+0xa5>
    50bf:	mov    rdi,r13
    50c2:	mov    rax,QWORD PTR [rdi+0x10]
    50c6:	mov    rcx,QWORD PTR [rax+0xb8]
    50cd:	xor    rdx,rdx
    50d0:	call   50d5 <botlish_fn_27+0x9d>
			50d1: R_X86_64_PLT32	rt_type_error-0x4
    50d5:	mov    rdi,r13
    50d8:	jmp    5174 <botlish_fn_27+0x13c>
    50dd:	mov    rax,rsi
    50e0:	and    rax,rdx
    50e3:	mov    r14,rsi
    50e6:	test   rax,0x1
    50ec:	jne    5112 <botlish_fn_27+0xda>
    50f2:	mov    rsi,r14
    50f5:	mov    rdi,r13
    50f8:	call   50fd <botlish_fn_27+0xc5>
			50f9: R_X86_64_PLT32	rt_int_cmp-0x4
    50fd:	mov    ecx,0x2
    5102:	test   rax,rax
    5105:	cmovge rcx,QWORD PTR [rip+0x153]        # 5260 <botlish_fn_27+0x228>
    510d:	jmp    5125 <botlish_fn_27+0xed>
    5112:	mov    ecx,0x2
    5117:	mov    rsi,r14
    511a:	cmp    rsi,rdx
    511d:	cmovge rcx,QWORD PTR [rip+0x13b]        # 5260 <botlish_fn_27+0x228>
    5125:	cmp    rcx,0x6
    5129:	je     520e <botlish_fn_27+0x1d6>
    512f:	mov    rsi,QWORD PTR [rbx+0x20]
    5133:	mov    rsi,QWORD PTR [rsi+0x8]
    5137:	mov    QWORD PTR [r12+0x8],rsi
    513c:	mov    rdx,r14
    513f:	mov    rdi,r13
    5142:	call   5147 <botlish_fn_27+0x10f>
			5143: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    5147:	test   rax,rax
    514a:	jne    5158 <botlish_fn_27+0x120>
    5150:	mov    rdi,r13
    5153:	jmp    5174 <botlish_fn_27+0x13c>
    5158:	mov    QWORD PTR [r12+0x8],rax
    515d:	mov    rsi,rax
    5160:	mov    rdi,r13
    5163:	call   5168 <botlish_fn_27+0x130>
			5164: R_X86_64_PLT32	botlish_fn_25-0x4 ; is_label_char<str>
    5168:	test   rax,rax
    516b:	jne    5199 <botlish_fn_27+0x161>
    5171:	mov    rdi,r13
    5174:	mov    rdi,r13
    5177:	mov    QWORD PTR [rdi],r12
    517a:	xor    rax,rax
    517d:	mov    rbx,QWORD PTR [rsp]
    5181:	mov    r12,QWORD PTR [rsp+0x8]
    5186:	mov    r13,QWORD PTR [rsp+0x10]
    518b:	mov    r14,QWORD PTR [rsp+0x18]
    5190:	add    rsp,0x20
    5194:	mov    rsp,rbp
    5197:	pop    rbp
    5198:	ret
    5199:	cmp    rax,0x6
    519d:	je     51ae <botlish_fn_27+0x176>
    51a3:	mov    rax,r14
    51a6:	mov    rdi,r13
    51a9:	jmp    5214 <botlish_fn_27+0x1dc>
    51ae:	mov    QWORD PTR [r12+0x8],rbx
    51b3:	mov    QWORD PTR [r12+0x10],0x3
    51bc:	mov    rsi,r14
    51bf:	test   rsi,0x1
    51c6:	je     51ec <botlish_fn_27+0x1b4>
    51cc:	mov    rsi,r14
    51cf:	mov    rcx,rsi
    51d2:	add    rcx,0x2
    51d6:	seto   al
    51d9:	test   al,al
    51db:	jne    51ec <botlish_fn_27+0x1b4>
    51e1:	mov    rsi,rcx
    51e4:	mov    r14,rcx
    51e7:	jmp    5202 <botlish_fn_27+0x1ca>
    51ec:	mov    edx,0x3
    51f1:	mov    rsi,r14
    51f4:	mov    rdi,r13
    51f7:	call   51fc <botlish_fn_27+0x1c4>
			51f8: R_X86_64_PLT32	rt_int_add-0x4
    51fc:	mov    rsi,rax
    51ff:	mov    r14,rax
    5202:	mov    QWORD PTR [r12],rsi
    5206:	mov    rsi,r14
    5209:	jmp    5086 <botlish_fn_27+0x4e>
    520e:	mov    rax,r14
    5211:	mov    rdi,r13
    5214:	mov    rdi,r13
    5217:	mov    QWORD PTR [rdi],r12
    521a:	mov    rbx,QWORD PTR [rsp]
    521e:	mov    r12,QWORD PTR [rsp+0x8]
    5223:	mov    r13,QWORD PTR [rsp+0x10]
    5228:	mov    r14,QWORD PTR [rsp+0x18]
    522d:	add    rsp,0x20
    5231:	mov    rsp,rbp
    5234:	pop    rbp
    5235:	ret
    5236:	mov    r13,rdi
    5239:	call   523e <botlish_fn_27+0x206>
			523a: R_X86_64_PLT32	rt_stack_overflow-0x4
    523e:	xor    rax,rax
    5241:	mov    rbx,QWORD PTR [rsp]
    5245:	mov    r12,QWORD PTR [rsp+0x8]
    524a:	mov    r13,QWORD PTR [rsp+0x10]
    524f:	mov    r14,QWORD PTR [rsp+0x18]
    5254:	add    rsp,0x20
    5258:	mov    rsp,rbp
    525b:	pop    rbp
    525c:	ret
    525d:	add    BYTE PTR [rax],al
    525f:	add    BYTE PTR [rsi],al
    5261:	add    BYTE PTR [rax],al
    5263:	add    BYTE PTR [rax],al
    5265:	add    BYTE PTR [rax],al
	...

0000000000005268 <botlish_entry_27: scan_label<generic>>:
    5268:	push   rbp
    5269:	mov    rbp,rsp
    526c:	mov    rdx,QWORD PTR [rdx]
    526f:	call   5274 <botlish_entry_27+0xc>
			5270: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_label<generic>
    5274:	mov    rsp,rbp
    5277:	pop    rbp
    5278:	ret
    5279:	add    BYTE PTR [rax],al
    527b:	add    BYTE PTR [rax],al
    527d:	add    BYTE PTR [rax],al
	...

0000000000005280 <botlish_fn_28: scan_alpha<generic>>:
    5280:	push   rbp
    5281:	mov    rbp,rsp
    5284:	sub    rsp,0x20
    5288:	mov    QWORD PTR [rsp],rbx
    528c:	mov    QWORD PTR [rsp+0x8],r12
    5291:	mov    QWORD PTR [rsp+0x10],r13
    5296:	mov    QWORD PTR [rsp+0x18],r14
    529b:	mov    r12,QWORD PTR [rdi]
    529e:	mov    rax,QWORD PTR [rdi+0x8]
    52a2:	lea    rcx,[r12+0x18]
    52a7:	cmp    rcx,rax
    52aa:	ja     5479 <botlish_fn_28+0x1f9>
    52b0:	lea    rax,[r12+0x18]
    52b5:	mov    QWORD PTR [rdi],rax
    52b8:	mov    r13,rdi
    52bb:	mov    QWORD PTR [r12+0x10],0x0
    52c4:	mov    QWORD PTR [r12],rdx
    52c8:	mov    rbx,rsi
    52cb:	mov    rsi,rdx
    52ce:	mov    rax,QWORD PTR [rbx+0x20]
    52d2:	mov    rdx,QWORD PTR [rax]
    52d5:	mov    ecx,0x1
    52da:	test   rsi,0x1
    52e1:	jne    52ff <botlish_fn_28+0x7f>
    52e7:	xor    ecx,ecx
    52e9:	test   rsi,0x7
    52f0:	jne    52ff <botlish_fn_28+0x7f>
    52f6:	movzx  rax,BYTE PTR [rsi]
    52fa:	cmp    al,0x1
    52fc:	sete   cl
    52ff:	test   cl,cl
    5301:	jne    5325 <botlish_fn_28+0xa5>
    5307:	mov    rdi,r13
    530a:	mov    rax,QWORD PTR [rdi+0x10]
    530e:	mov    rcx,QWORD PTR [rax+0xb8]
    5315:	xor    rdx,rdx
    5318:	call   531d <botlish_fn_28+0x9d>
			5319: R_X86_64_PLT32	rt_type_error-0x4
    531d:	mov    rdi,r13
    5320:	jmp    53b7 <botlish_fn_28+0x137>
    5325:	mov    rax,rsi
    5328:	and    rax,rdx
    532b:	mov    r14,rsi
    532e:	test   rax,0x1
    5334:	jne    535a <botlish_fn_28+0xda>
    533a:	mov    rsi,r14
    533d:	mov    rdi,r13
    5340:	call   5345 <botlish_fn_28+0xc5>
			5341: R_X86_64_PLT32	rt_int_cmp-0x4
    5345:	mov    ecx,0x2
    534a:	test   rax,rax
    534d:	cmovge rcx,QWORD PTR [rip+0x14b]        # 54a0 <botlish_fn_28+0x220>
    5355:	jmp    536d <botlish_fn_28+0xed>
    535a:	mov    ecx,0x2
    535f:	mov    rsi,r14
    5362:	cmp    rsi,rdx
    5365:	cmovge rcx,QWORD PTR [rip+0x133]        # 54a0 <botlish_fn_28+0x220>
    536d:	cmp    rcx,0x6
    5371:	je     5451 <botlish_fn_28+0x1d1>
    5377:	mov    rsi,QWORD PTR [rbx+0x20]
    537b:	mov    rsi,QWORD PTR [rsi+0x8]
    537f:	mov    QWORD PTR [r12+0x8],rsi
    5384:	mov    rdx,r14
    5387:	mov    rdi,r13
    538a:	call   538f <botlish_fn_28+0x10f>
			538b: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    538f:	test   rax,rax
    5392:	mov    rsi,rax
    5395:	jne    53a3 <botlish_fn_28+0x123>
    539b:	mov    rdi,r13
    539e:	jmp    53b7 <botlish_fn_28+0x137>
    53a3:	mov    rdi,r13
    53a6:	call   53ab <botlish_fn_28+0x12b>
			53a7: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    53ab:	test   rax,rax
    53ae:	jne    53dc <botlish_fn_28+0x15c>
    53b4:	mov    rdi,r13
    53b7:	mov    rdi,r13
    53ba:	mov    QWORD PTR [rdi],r12
    53bd:	xor    rax,rax
    53c0:	mov    rbx,QWORD PTR [rsp]
    53c4:	mov    r12,QWORD PTR [rsp+0x8]
    53c9:	mov    r13,QWORD PTR [rsp+0x10]
    53ce:	mov    r14,QWORD PTR [rsp+0x18]
    53d3:	add    rsp,0x20
    53d7:	mov    rsp,rbp
    53da:	pop    rbp
    53db:	ret
    53dc:	cmp    rax,0x6
    53e0:	je     53f1 <botlish_fn_28+0x171>
    53e6:	mov    rax,r14
    53e9:	mov    rdi,r13
    53ec:	jmp    5457 <botlish_fn_28+0x1d7>
    53f1:	mov    QWORD PTR [r12+0x8],rbx
    53f6:	mov    QWORD PTR [r12+0x10],0x3
    53ff:	mov    rsi,r14
    5402:	test   rsi,0x1
    5409:	je     542f <botlish_fn_28+0x1af>
    540f:	mov    rsi,r14
    5412:	mov    rcx,rsi
    5415:	add    rcx,0x2
    5419:	seto   al
    541c:	test   al,al
    541e:	jne    542f <botlish_fn_28+0x1af>
    5424:	mov    rsi,rcx
    5427:	mov    r14,rcx
    542a:	jmp    5445 <botlish_fn_28+0x1c5>
    542f:	mov    edx,0x3
    5434:	mov    rsi,r14
    5437:	mov    rdi,r13
    543a:	call   543f <botlish_fn_28+0x1bf>
			543b: R_X86_64_PLT32	rt_int_add-0x4
    543f:	mov    rsi,rax
    5442:	mov    r14,rax
    5445:	mov    QWORD PTR [r12],rsi
    5449:	mov    rsi,r14
    544c:	jmp    52ce <botlish_fn_28+0x4e>
    5451:	mov    rax,r14
    5454:	mov    rdi,r13
    5457:	mov    rdi,r13
    545a:	mov    QWORD PTR [rdi],r12
    545d:	mov    rbx,QWORD PTR [rsp]
    5461:	mov    r12,QWORD PTR [rsp+0x8]
    5466:	mov    r13,QWORD PTR [rsp+0x10]
    546b:	mov    r14,QWORD PTR [rsp+0x18]
    5470:	add    rsp,0x20
    5474:	mov    rsp,rbp
    5477:	pop    rbp
    5478:	ret
    5479:	mov    r13,rdi
    547c:	call   5481 <botlish_fn_28+0x201>
			547d: R_X86_64_PLT32	rt_stack_overflow-0x4
    5481:	xor    rax,rax
    5484:	mov    rbx,QWORD PTR [rsp]
    5488:	mov    r12,QWORD PTR [rsp+0x8]
    548d:	mov    r13,QWORD PTR [rsp+0x10]
    5492:	mov    r14,QWORD PTR [rsp+0x18]
    5497:	add    rsp,0x20
    549b:	mov    rsp,rbp
    549e:	pop    rbp
    549f:	ret
    54a0:	(bad)
    54a1:	add    BYTE PTR [rax],al
    54a3:	add    BYTE PTR [rax],al
    54a5:	add    BYTE PTR [rax],al
	...

00000000000054a8 <botlish_entry_28: scan_alpha<generic>>:
    54a8:	push   rbp
    54a9:	mov    rbp,rsp
    54ac:	mov    rdx,QWORD PTR [rdx]
    54af:	call   54b4 <botlish_entry_28+0xc>
			54b0: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_alpha<generic>
    54b4:	mov    rsp,rbp
    54b7:	pop    rbp
    54b8:	ret
    54b9:	add    BYTE PTR [rax],al
    54bb:	add    BYTE PTR [rax],al
    54bd:	add    BYTE PTR [rax],al
	...

00000000000054c0 <botlish_fn_29: tld_ok<generic>>:
    54c0:	push   rbp
    54c1:	mov    rbp,rsp
    54c4:	sub    rsp,0x30
    54c8:	mov    QWORD PTR [rsp],rbx
    54cc:	mov    QWORD PTR [rsp+0x8],r12
    54d1:	mov    QWORD PTR [rsp+0x10],r13
    54d6:	mov    QWORD PTR [rsp+0x18],r14
    54db:	mov    QWORD PTR [rsp+0x20],r15
    54e0:	mov    rbx,QWORD PTR [rdi]
    54e3:	mov    rax,QWORD PTR [rdi+0x8]
    54e7:	lea    rcx,[rbx+0x10]
    54eb:	cmp    rcx,rax
    54ee:	ja     56f3 <botlish_fn_29+0x233>
    54f4:	lea    rax,[rbx+0x10]
    54f8:	mov    QWORD PTR [rdi],rax
    54fb:	mov    r13,rdi
    54fe:	mov    QWORD PTR [rbx],rdx
    5501:	mov    r8,rdx
    5504:	mov    rax,QWORD PTR [rsi+0x20]
    5508:	mov    r15,rsi
    550b:	mov    rsi,QWORD PTR [rax]
    550e:	mov    QWORD PTR [rbx+0x8],rsi
    5512:	mov    r12,r8
    5515:	mov    rdx,r12
    5518:	mov    rdi,r13
    551b:	call   5520 <botlish_fn_29+0x60>
			551c: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_alpha<generic>
    5520:	mov    rcx,rax
    5523:	mov    r14,rax
    5526:	test   rax,rcx
    5529:	jne    5537 <botlish_fn_29+0x77>
    552f:	mov    rdi,r13
    5532:	jmp    560f <botlish_fn_29+0x14f>
    5537:	mov    rax,r14
    553a:	mov    QWORD PTR [rbx+0x8],rax
    553e:	mov    rsi,r15
    5541:	mov    rax,QWORD PTR [rsi+0x20]
    5545:	mov    rdx,QWORD PTR [rax+0x8]
    5549:	mov    rax,r14
    554c:	and    rax,rdx
    554f:	test   rax,0x1
    5555:	jne    557e <botlish_fn_29+0xbe>
    555b:	mov    rsi,r14
    555e:	mov    rdi,r13
    5561:	call   5566 <botlish_fn_29+0xa6>
			5562: R_X86_64_PLT32	rt_int_cmp-0x4
    5566:	mov    ecx,0x2
    556b:	test   rax,rax
    556e:	cmove  rcx,QWORD PTR [rip+0x1aa]        # 5720 <botlish_fn_29+0x260>
    5576:	mov    rax,r14
    5579:	jmp    5591 <botlish_fn_29+0xd1>
    557e:	mov    ecx,0x2
    5583:	mov    rax,r14
    5586:	cmp    rax,rdx
    5589:	cmove  rcx,QWORD PTR [rip+0x18f]        # 5720 <botlish_fn_29+0x260>
    5591:	cmp    rcx,0x6
    5595:	je     55ab <botlish_fn_29+0xeb>
    559b:	mov    ecx,0x2
    55a0:	mov    rax,rcx
    55a3:	mov    rdi,r13
    55a6:	jmp    56cc <botlish_fn_29+0x20c>
    55ab:	mov    ecx,0x1
    55b0:	test   r12,0x1
    55b7:	je     55c5 <botlish_fn_29+0x105>
    55bd:	mov    r8,r12
    55c0:	jmp    55eb <botlish_fn_29+0x12b>
    55c5:	xor    ecx,ecx
    55c7:	test   r12,0x7
    55ce:	je     55dc <botlish_fn_29+0x11c>
    55d4:	mov    r8,r12
    55d7:	jmp    55eb <botlish_fn_29+0x12b>
    55dc:	movzx  rcx,BYTE PTR [r12]
    55e1:	mov    r8,r12
    55e4:	rex cmp cl,0x1
    55e8:	sete   cl
    55eb:	test   cl,cl
    55ed:	jne    5639 <botlish_fn_29+0x179>
    55f3:	mov    rdi,r13
    55f6:	mov    rax,QWORD PTR [rdi+0x10]
    55fa:	mov    rcx,QWORD PTR [rax+0x128]
    5601:	xor    rdx,rdx
    5604:	mov    rsi,r8
    5607:	call   560c <botlish_fn_29+0x14c>
			5608: R_X86_64_PLT32	rt_type_error-0x4
    560c:	mov    rdi,r13
    560f:	mov    rdi,r13
    5612:	mov    QWORD PTR [rdi],rbx
    5615:	xor    rax,rax
    5618:	mov    rbx,QWORD PTR [rsp]
    561c:	mov    r12,QWORD PTR [rsp+0x8]
    5621:	mov    r13,QWORD PTR [rsp+0x10]
    5626:	mov    r14,QWORD PTR [rsp+0x18]
    562b:	mov    r15,QWORD PTR [rsp+0x20]
    5630:	add    rsp,0x30
    5634:	mov    rsp,rbp
    5637:	pop    rbp
    5638:	ret
    5639:	mov    r12,r8
    563c:	mov    rcx,rax
    563f:	and    rcx,r12
    5642:	test   rcx,0x1
    5649:	jne    565a <botlish_fn_29+0x19a>
    564f:	mov    rdx,r8
    5652:	mov    rsi,rax
    5655:	jmp    567b <botlish_fn_29+0x1bb>
    565a:	mov    r12,r8
    565d:	mov    rcx,rax
    5660:	sub    rcx,r12
    5663:	mov    r14,rax
    5666:	seto   al
    5669:	lea    rsi,[rcx+0x1]
    566d:	test   al,al
    566f:	je     5686 <botlish_fn_29+0x1c6>
    5675:	mov    rdx,r8
    5678:	mov    rsi,r14
    567b:	mov    rdi,r13
    567e:	call   5683 <botlish_fn_29+0x1c3>
			567f: R_X86_64_PLT32	rt_int_sub-0x4
    5683:	mov    rsi,rax
    5686:	test   rsi,0x1
    568d:	jne    56b8 <botlish_fn_29+0x1f8>
    5693:	mov    edx,0x5
    5698:	mov    rdi,r13
    569b:	call   56a0 <botlish_fn_29+0x1e0>
			569c: R_X86_64_PLT32	rt_int_cmp-0x4
    56a0:	mov    ecx,0x2
    56a5:	test   rax,rax
    56a8:	mov    rax,rcx
    56ab:	cmovge rax,QWORD PTR [rip+0x6d]        # 5720 <botlish_fn_29+0x260>
    56b3:	jmp    56c9 <botlish_fn_29+0x209>
    56b8:	mov    eax,0x2
    56bd:	cmp    rsi,0x5
    56c1:	cmovge rax,QWORD PTR [rip+0x57]        # 5720 <botlish_fn_29+0x260>
    56c9:	mov    rdi,r13
    56cc:	mov    rdi,r13
    56cf:	mov    QWORD PTR [rdi],rbx
    56d2:	mov    rbx,QWORD PTR [rsp]
    56d6:	mov    r12,QWORD PTR [rsp+0x8]
    56db:	mov    r13,QWORD PTR [rsp+0x10]
    56e0:	mov    r14,QWORD PTR [rsp+0x18]
    56e5:	mov    r15,QWORD PTR [rsp+0x20]
    56ea:	add    rsp,0x30
    56ee:	mov    rsp,rbp
    56f1:	pop    rbp
    56f2:	ret
    56f3:	mov    r13,rdi
    56f6:	call   56fb <botlish_fn_29+0x23b>
			56f7: R_X86_64_PLT32	rt_stack_overflow-0x4
    56fb:	xor    rax,rax
    56fe:	mov    rbx,QWORD PTR [rsp]
    5702:	mov    r12,QWORD PTR [rsp+0x8]
    5707:	mov    r13,QWORD PTR [rsp+0x10]
    570c:	mov    r14,QWORD PTR [rsp+0x18]
    5711:	mov    r15,QWORD PTR [rsp+0x20]
    5716:	add    rsp,0x30
    571a:	mov    rsp,rbp
    571d:	pop    rbp
    571e:	ret
    571f:	add    BYTE PTR [rsi],al
    5721:	add    BYTE PTR [rax],al
    5723:	add    BYTE PTR [rax],al
    5725:	add    BYTE PTR [rax],al
	...

0000000000005728 <botlish_entry_29: tld_ok<generic>>:
    5728:	push   rbp
    5729:	mov    rbp,rsp
    572c:	mov    rdx,QWORD PTR [rdx]
    572f:	call   5734 <botlish_entry_29+0xc>
			5730: R_X86_64_PLT32	botlish_fn_29-0x4 ; tld_ok<generic>
    5734:	mov    rsp,rbp
    5737:	pop    rbp
    5738:	ret
    5739:	add    BYTE PTR [rax],al
    573b:	add    BYTE PTR [rax],al
    573d:	add    BYTE PTR [rax],al
	...

0000000000005740 <botlish_fn_30: domain_loop<generic>>:
    5740:	push   rbp
    5741:	mov    rbp,rsp
    5744:	sub    rsp,0x50
    5748:	mov    QWORD PTR [rsp+0x20],rbx
    574d:	mov    QWORD PTR [rsp+0x28],r12
    5752:	mov    QWORD PTR [rsp+0x30],r13
    5757:	mov    QWORD PTR [rsp+0x38],r14
    575c:	mov    QWORD PTR [rsp+0x40],r15
    5761:	mov    r13,QWORD PTR [rdi]
    5764:	mov    rax,QWORD PTR [rdi+0x8]
    5768:	lea    rcx,[r13+0x10]
    576c:	cmp    rcx,rax
    576f:	ja     59de <botlish_fn_30+0x29e>
    5775:	lea    rax,[r13+0x10]
    5779:	mov    QWORD PTR [rdi],rax
    577c:	mov    r15,rdi
    577f:	mov    QWORD PTR [r13+0x0],rdx
    5783:	mov    QWORD PTR [rsp+0x10],rdx
    5788:	lea    rbx,[rsp]
    578c:	mov    r12,rsi
    578f:	mov    rax,QWORD PTR [r12+0x20]
    5794:	mov    rsi,QWORD PTR [rax]
    5797:	mov    QWORD PTR [r13+0x8],rsi
    579b:	mov    rdx,QWORD PTR [rsp+0x10]
    57a0:	mov    rdi,r15
    57a3:	call   57a8 <botlish_fn_30+0x68>
			57a4: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_label<generic>
    57a8:	mov    rcx,rax
    57ab:	mov    r14,rax
    57ae:	test   rax,rcx
    57b1:	jne    57bf <botlish_fn_30+0x7f>
    57b7:	mov    rdi,r15
    57ba:	jmp    594c <botlish_fn_30+0x20c>
    57bf:	mov    rax,r14
    57c2:	mov    QWORD PTR [r13+0x0],rax
    57c6:	mov    rdx,QWORD PTR [rsp+0x10]
    57cb:	mov    rsi,rax
    57ce:	and    rsi,rdx
    57d1:	test   rsi,0x1
    57d8:	jne    57ff <botlish_fn_30+0xbf>
    57de:	mov    rdx,QWORD PTR [rsp+0x10]
    57e3:	mov    rsi,r14
    57e6:	mov    rdi,r15
    57e9:	call   57ee <botlish_fn_30+0xae>
			57ea: R_X86_64_PLT32	rt_value_eq-0x4
    57ee:	test   rax,rax
    57f1:	jne    5814 <botlish_fn_30+0xd4>
    57f7:	mov    rdi,r15
    57fa:	jmp    594c <botlish_fn_30+0x20c>
    57ff:	mov    eax,0x2
    5804:	mov    rdx,QWORD PTR [rsp+0x10]
    5809:	cmp    r14,rdx
    580c:	cmove  rax,QWORD PTR [rip+0x1fc]        # 5a10 <botlish_fn_30+0x2d0>
    5814:	cmp    rax,0x6
    5818:	je     59ac <botlish_fn_30+0x26c>
    581e:	mov    rax,QWORD PTR [r12+0x20]
    5823:	mov    rdx,QWORD PTR [rax+0x8]
    5827:	mov    rax,r14
    582a:	and    rax,rdx
    582d:	test   rax,0x1
    5833:	jne    5859 <botlish_fn_30+0x119>
    5839:	mov    rsi,r14
    583c:	mov    rdi,r15
    583f:	call   5844 <botlish_fn_30+0x104>
			5840: R_X86_64_PLT32	rt_int_cmp-0x4
    5844:	mov    ecx,0x2
    5849:	test   rax,rax
    584c:	cmovge rcx,QWORD PTR [rip+0x1bc]        # 5a10 <botlish_fn_30+0x2d0>
    5854:	jmp    5869 <botlish_fn_30+0x129>
    5859:	mov    ecx,0x2
    585e:	cmp    r14,rdx
    5861:	cmovge rcx,QWORD PTR [rip+0x1a7]        # 5a10 <botlish_fn_30+0x2d0>
    5869:	cmp    rcx,0x6
    586d:	je     599d <botlish_fn_30+0x25d>
    5873:	mov    rax,QWORD PTR [r12+0x20]
    5878:	mov    rsi,QWORD PTR [rax+0x10]
    587c:	mov    QWORD PTR [r13+0x8],rsi
    5880:	mov    rcx,rbx
    5883:	mov    rdx,r14
    5886:	mov    rdi,r15
    5889:	call   588e <botlish_fn_30+0x14e>
			588a: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    588e:	test   rax,rax
    5891:	mov    rsi,rax
    5894:	jne    58a2 <botlish_fn_30+0x162>
    589a:	mov    rdi,r15
    589d:	jmp    594c <botlish_fn_30+0x20c>
    58a2:	mov    rdx,QWORD PTR [rsp]
    58a6:	mov    rcx,QWORD PTR [rsp+0x8]
    58ab:	mov    rdi,r15
    58ae:	mov    rax,QWORD PTR [rdi+0x10]
    58b2:	mov    r8,QWORD PTR [rax+0x118]
    58b9:	call   58be <botlish_fn_30+0x17e>
			58ba: R_X86_64_PLT32	rt_str_region_eq-0x4
    58be:	cmp    rax,0x6
    58c2:	je     58d4 <botlish_fn_30+0x194>
    58c8:	mov    rax,0xffffffffffffffff
    58cf:	jmp    59a4 <botlish_fn_30+0x264>
    58d4:	mov    QWORD PTR [r13+0x8],0x3
    58dc:	test   r14,0x1
    58e3:	je     590a <botlish_fn_30+0x1ca>
    58e9:	mov    rdx,r14
    58ec:	add    rdx,0x2
    58f0:	mov    QWORD PTR [rsp+0x10],rdx
    58f5:	seto   al
    58f8:	test   al,al
    58fa:	jne    590a <botlish_fn_30+0x1ca>
    5900:	mov    rdx,QWORD PTR [rsp+0x10]
    5905:	jmp    5922 <botlish_fn_30+0x1e2>
    590a:	mov    edx,0x3
    590f:	mov    rsi,r14
    5912:	mov    rdi,r15
    5915:	call   591a <botlish_fn_30+0x1da>
			5916: R_X86_64_PLT32	rt_int_add-0x4
    591a:	mov    rdx,rax
    591d:	mov    QWORD PTR [rsp+0x10],rax
    5922:	mov    QWORD PTR [r13+0x0],rdx
    5926:	mov    rax,QWORD PTR [r12+0x20]
    592b:	mov    rsi,QWORD PTR [rax+0x18]
    592f:	mov    QWORD PTR [r13+0x8],rsi
    5933:	mov    rdx,QWORD PTR [rsp+0x10]
    5938:	mov    rdi,r15
    593b:	call   5940 <botlish_fn_30+0x200>
			593c: R_X86_64_PLT32	botlish_fn_29-0x4 ; tld_ok<generic>
    5940:	test   rax,rax
    5943:	jne    5977 <botlish_fn_30+0x237>
    5949:	mov    rdi,r15
    594c:	mov    rdi,r15
    594f:	mov    QWORD PTR [rdi],r13
    5952:	xor    rax,rax
    5955:	mov    rbx,QWORD PTR [rsp+0x20]
    595a:	mov    r12,QWORD PTR [rsp+0x28]
    595f:	mov    r13,QWORD PTR [rsp+0x30]
    5964:	mov    r14,QWORD PTR [rsp+0x38]
    5969:	mov    r15,QWORD PTR [rsp+0x40]
    596e:	add    rsp,0x50
    5972:	mov    rsp,rbp
    5975:	pop    rbp
    5976:	ret
    5977:	cmp    rax,0x6
    597b:	je     598f <botlish_fn_30+0x24f>
    5981:	mov    rdx,QWORD PTR [rsp+0x10]
    5986:	mov    QWORD PTR [r13+0x0],rdx
    598a:	jmp    578f <botlish_fn_30+0x4f>
    598f:	mov    rax,QWORD PTR [r12+0x20]
    5994:	mov    rax,QWORD PTR [rax+0x8]
    5998:	jmp    59a4 <botlish_fn_30+0x264>
    599d:	mov    rax,0xffffffffffffffff
    59a4:	mov    rdi,r15
    59a7:	jmp    59b6 <botlish_fn_30+0x276>
    59ac:	mov    rax,0xffffffffffffffff
    59b3:	mov    rdi,r15
    59b6:	mov    rdi,r15
    59b9:	mov    QWORD PTR [rdi],r13
    59bc:	mov    rbx,QWORD PTR [rsp+0x20]
    59c1:	mov    r12,QWORD PTR [rsp+0x28]
    59c6:	mov    r13,QWORD PTR [rsp+0x30]
    59cb:	mov    r14,QWORD PTR [rsp+0x38]
    59d0:	mov    r15,QWORD PTR [rsp+0x40]
    59d5:	add    rsp,0x50
    59d9:	mov    rsp,rbp
    59dc:	pop    rbp
    59dd:	ret
    59de:	mov    r15,rdi
    59e1:	call   59e6 <botlish_fn_30+0x2a6>
			59e2: R_X86_64_PLT32	rt_stack_overflow-0x4
    59e6:	xor    rax,rax
    59e9:	mov    rbx,QWORD PTR [rsp+0x20]
    59ee:	mov    r12,QWORD PTR [rsp+0x28]
    59f3:	mov    r13,QWORD PTR [rsp+0x30]
    59f8:	mov    r14,QWORD PTR [rsp+0x38]
    59fd:	mov    r15,QWORD PTR [rsp+0x40]
    5a02:	add    rsp,0x50
    5a06:	mov    rsp,rbp
    5a09:	pop    rbp
    5a0a:	ret
    5a0b:	add    BYTE PTR [rax],al
    5a0d:	add    BYTE PTR [rax],al
    5a0f:	add    BYTE PTR [rsi],al
    5a11:	add    BYTE PTR [rax],al
    5a13:	add    BYTE PTR [rax],al
    5a15:	add    BYTE PTR [rax],al
	...

0000000000005a18 <botlish_entry_30: domain_loop<generic>>:
    5a18:	push   rbp
    5a19:	mov    rbp,rsp
    5a1c:	mov    rdx,QWORD PTR [rdx]
    5a1f:	call   5a24 <botlish_entry_30+0xc>
			5a20: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    5a24:	mov    rsp,rbp
    5a27:	pop    rbp
    5a28:	ret

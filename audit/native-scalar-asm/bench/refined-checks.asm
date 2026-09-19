; source:  bench/refined-checks.ir
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 23750  (per function: 449 1060 1713 1425 672 1036 685 1084 600 1289 1361 500 520 401 165 609 609 609 673 777 1289 1361 500 520 401 165 609 609 609 673 777)
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
     5ac:	sub    rsp,0x10
     5b0:	mov    QWORD PTR [rsp],rbx
     5b4:	mov    QWORD PTR [rsp+0x8],r12
     5b9:	mov    r8d,0x1
     5bf:	test   rsi,0x1
     5c6:	jne    5e6 <botlish_fn_2+0x3e>
     5cc:	xor    r8d,r8d
     5cf:	test   rsi,0x7
     5d6:	jne    5e6 <botlish_fn_2+0x3e>
     5dc:	movzx  rax,BYTE PTR [rsi]
     5e0:	cmp    al,0x1
     5e2:	sete   r8b
     5e6:	test   r8b,r8b
     5e9:	jne    61a <botlish_fn_2+0x72>
     5ef:	mov    rax,QWORD PTR [rdi+0x10]
     5f3:	mov    rcx,QWORD PTR [rax+0xa0]
     5fa:	xor    rbx,rbx
     5fd:	mov    rdx,rbx
     600:	call   605 <botlish_fn_2+0x5d>
			601: R_X86_64_PLT32	rt_type_error-0x4
     605:	mov    rax,rbx
     608:	mov    rbx,QWORD PTR [rsp]
     60c:	mov    r12,QWORD PTR [rsp+0x8]
     611:	add    rsp,0x10
     615:	mov    rsp,rbp
     618:	pop    rbp
     619:	ret
     61a:	mov    r12,rdi
     61d:	test   rsi,0x1
     624:	mov    rbx,rsi
     627:	jne    652 <botlish_fn_2+0xaa>
     62d:	mov    edx,0x1f
     632:	mov    rsi,rbx
     635:	mov    rdi,r12
     638:	call   63d <botlish_fn_2+0x95>
			639: R_X86_64_PLT32	rt_int_cmp-0x4
     63d:	mov    ecx,0x2
     642:	test   rax,rax
     645:	cmovle rcx,QWORD PTR [rip+0x583]        # bd0 <botlish_fn_2+0x628>
     64d:	jmp    666 <botlish_fn_2+0xbe>
     652:	mov    ecx,0x2
     657:	mov    rsi,rbx
     65a:	cmp    rsi,0x1f
     65e:	cmovle rcx,QWORD PTR [rip+0x56a]        # bd0 <botlish_fn_2+0x628>
     666:	cmp    rcx,0x6
     66a:	je     bb3 <botlish_fn_2+0x60b>
     670:	mov    rsi,rbx
     673:	test   rsi,0x1
     67a:	jne    6a5 <botlish_fn_2+0xfd>
     680:	mov    edx,0x3f
     685:	mov    rsi,rbx
     688:	mov    rdi,r12
     68b:	call   690 <botlish_fn_2+0xe8>
			68c: R_X86_64_PLT32	rt_int_cmp-0x4
     690:	mov    ecx,0x2
     695:	test   rax,rax
     698:	cmovle rcx,QWORD PTR [rip+0x530]        # bd0 <botlish_fn_2+0x628>
     6a0:	jmp    6b9 <botlish_fn_2+0x111>
     6a5:	mov    ecx,0x2
     6aa:	mov    rsi,rbx
     6ad:	cmp    rsi,0x3f
     6b1:	cmovle rcx,QWORD PTR [rip+0x517]        # bd0 <botlish_fn_2+0x628>
     6b9:	cmp    rcx,0x6
     6bd:	je     ba9 <botlish_fn_2+0x601>
     6c3:	mov    rsi,rbx
     6c6:	test   rsi,0x1
     6cd:	jne    6f8 <botlish_fn_2+0x150>
     6d3:	mov    edx,0x5f
     6d8:	mov    rsi,rbx
     6db:	mov    rdi,r12
     6de:	call   6e3 <botlish_fn_2+0x13b>
			6df: R_X86_64_PLT32	rt_int_cmp-0x4
     6e3:	mov    ecx,0x2
     6e8:	test   rax,rax
     6eb:	cmovle rcx,QWORD PTR [rip+0x4dd]        # bd0 <botlish_fn_2+0x628>
     6f3:	jmp    70c <botlish_fn_2+0x164>
     6f8:	mov    ecx,0x2
     6fd:	mov    rsi,rbx
     700:	cmp    rsi,0x5f
     704:	cmovle rcx,QWORD PTR [rip+0x4c4]        # bd0 <botlish_fn_2+0x628>
     70c:	cmp    rcx,0x6
     710:	je     b9f <botlish_fn_2+0x5f7>
     716:	mov    rsi,rbx
     719:	test   rsi,0x1
     720:	jne    74b <botlish_fn_2+0x1a3>
     726:	mov    edx,0x7f
     72b:	mov    rsi,rbx
     72e:	mov    rdi,r12
     731:	call   736 <botlish_fn_2+0x18e>
			732: R_X86_64_PLT32	rt_int_cmp-0x4
     736:	mov    ecx,0x2
     73b:	test   rax,rax
     73e:	cmovle rcx,QWORD PTR [rip+0x48a]        # bd0 <botlish_fn_2+0x628>
     746:	jmp    75f <botlish_fn_2+0x1b7>
     74b:	mov    ecx,0x2
     750:	mov    rsi,rbx
     753:	cmp    rsi,0x7f
     757:	cmovle rcx,QWORD PTR [rip+0x471]        # bd0 <botlish_fn_2+0x628>
     75f:	cmp    rcx,0x6
     763:	je     b95 <botlish_fn_2+0x5ed>
     769:	mov    rsi,rbx
     76c:	test   rsi,0x1
     773:	jne    79e <botlish_fn_2+0x1f6>
     779:	mov    edx,0x9f
     77e:	mov    rsi,rbx
     781:	mov    rdi,r12
     784:	call   789 <botlish_fn_2+0x1e1>
			785: R_X86_64_PLT32	rt_int_cmp-0x4
     789:	mov    ecx,0x2
     78e:	test   rax,rax
     791:	cmovle rcx,QWORD PTR [rip+0x437]        # bd0 <botlish_fn_2+0x628>
     799:	jmp    7b5 <botlish_fn_2+0x20d>
     79e:	mov    ecx,0x2
     7a3:	mov    rsi,rbx
     7a6:	cmp    rsi,0x9f
     7ad:	cmovle rcx,QWORD PTR [rip+0x41b]        # bd0 <botlish_fn_2+0x628>
     7b5:	cmp    rcx,0x6
     7b9:	je     b8b <botlish_fn_2+0x5e3>
     7bf:	mov    rsi,rbx
     7c2:	test   rsi,0x1
     7c9:	jne    7f4 <botlish_fn_2+0x24c>
     7cf:	mov    edx,0xbf
     7d4:	mov    rsi,rbx
     7d7:	mov    rdi,r12
     7da:	call   7df <botlish_fn_2+0x237>
			7db: R_X86_64_PLT32	rt_int_cmp-0x4
     7df:	mov    ecx,0x2
     7e4:	test   rax,rax
     7e7:	cmovle rcx,QWORD PTR [rip+0x3e1]        # bd0 <botlish_fn_2+0x628>
     7ef:	jmp    80b <botlish_fn_2+0x263>
     7f4:	mov    ecx,0x2
     7f9:	mov    rsi,rbx
     7fc:	cmp    rsi,0xbf
     803:	cmovle rcx,QWORD PTR [rip+0x3c5]        # bd0 <botlish_fn_2+0x628>
     80b:	cmp    rcx,0x6
     80f:	je     b81 <botlish_fn_2+0x5d9>
     815:	mov    rsi,rbx
     818:	test   rsi,0x1
     81f:	jne    84a <botlish_fn_2+0x2a2>
     825:	mov    edx,0xdf
     82a:	mov    rsi,rbx
     82d:	mov    rdi,r12
     830:	call   835 <botlish_fn_2+0x28d>
			831: R_X86_64_PLT32	rt_int_cmp-0x4
     835:	mov    ecx,0x2
     83a:	test   rax,rax
     83d:	cmovle rcx,QWORD PTR [rip+0x38b]        # bd0 <botlish_fn_2+0x628>
     845:	jmp    861 <botlish_fn_2+0x2b9>
     84a:	mov    ecx,0x2
     84f:	mov    rsi,rbx
     852:	cmp    rsi,0xdf
     859:	cmovle rcx,QWORD PTR [rip+0x36f]        # bd0 <botlish_fn_2+0x628>
     861:	cmp    rcx,0x6
     865:	je     b77 <botlish_fn_2+0x5cf>
     86b:	mov    rsi,rbx
     86e:	test   rsi,0x1
     875:	jne    8a1 <botlish_fn_2+0x2f9>
     87b:	mov    edx,0xff
     880:	mov    rsi,rbx
     883:	mov    rdi,r12
     886:	call   88b <botlish_fn_2+0x2e3>
			887: R_X86_64_PLT32	rt_int_cmp-0x4
     88b:	mov    r10d,0x2
     891:	test   rax,rax
     894:	cmovle r10,QWORD PTR [rip+0x334]        # bd0 <botlish_fn_2+0x628>
     89c:	jmp    8b9 <botlish_fn_2+0x311>
     8a1:	mov    r10d,0x2
     8a7:	mov    rsi,rbx
     8aa:	cmp    rsi,0xff
     8b1:	cmovle r10,QWORD PTR [rip+0x317]        # bd0 <botlish_fn_2+0x628>
     8b9:	cmp    r10,0x6
     8bd:	je     b6d <botlish_fn_2+0x5c5>
     8c3:	mov    rsi,rbx
     8c6:	test   rsi,0x1
     8cd:	jne    8f8 <botlish_fn_2+0x350>
     8d3:	mov    edx,0x11f
     8d8:	mov    rsi,rbx
     8db:	mov    rdi,r12
     8de:	call   8e3 <botlish_fn_2+0x33b>
			8df: R_X86_64_PLT32	rt_int_cmp-0x4
     8e3:	mov    ecx,0x2
     8e8:	test   rax,rax
     8eb:	cmovle rcx,QWORD PTR [rip+0x2dd]        # bd0 <botlish_fn_2+0x628>
     8f3:	jmp    90f <botlish_fn_2+0x367>
     8f8:	mov    ecx,0x2
     8fd:	mov    rsi,rbx
     900:	cmp    rsi,0x11f
     907:	cmovle rcx,QWORD PTR [rip+0x2c1]        # bd0 <botlish_fn_2+0x628>
     90f:	cmp    rcx,0x6
     913:	je     b63 <botlish_fn_2+0x5bb>
     919:	mov    rsi,rbx
     91c:	test   rsi,0x1
     923:	jne    94e <botlish_fn_2+0x3a6>
     929:	mov    edx,0x13f
     92e:	mov    rsi,rbx
     931:	mov    rdi,r12
     934:	call   939 <botlish_fn_2+0x391>
			935: R_X86_64_PLT32	rt_int_cmp-0x4
     939:	mov    ecx,0x2
     93e:	test   rax,rax
     941:	cmovle rcx,QWORD PTR [rip+0x287]        # bd0 <botlish_fn_2+0x628>
     949:	jmp    965 <botlish_fn_2+0x3bd>
     94e:	mov    ecx,0x2
     953:	mov    rsi,rbx
     956:	cmp    rsi,0x13f
     95d:	cmovle rcx,QWORD PTR [rip+0x26b]        # bd0 <botlish_fn_2+0x628>
     965:	cmp    rcx,0x6
     969:	je     b59 <botlish_fn_2+0x5b1>
     96f:	mov    rsi,rbx
     972:	test   rsi,0x1
     979:	jne    9a4 <botlish_fn_2+0x3fc>
     97f:	mov    edx,0x15f
     984:	mov    rsi,rbx
     987:	mov    rdi,r12
     98a:	call   98f <botlish_fn_2+0x3e7>
			98b: R_X86_64_PLT32	rt_int_cmp-0x4
     98f:	mov    ecx,0x2
     994:	test   rax,rax
     997:	cmovle rcx,QWORD PTR [rip+0x231]        # bd0 <botlish_fn_2+0x628>
     99f:	jmp    9bb <botlish_fn_2+0x413>
     9a4:	mov    ecx,0x2
     9a9:	mov    rsi,rbx
     9ac:	cmp    rsi,0x15f
     9b3:	cmovle rcx,QWORD PTR [rip+0x215]        # bd0 <botlish_fn_2+0x628>
     9bb:	cmp    rcx,0x6
     9bf:	je     b4f <botlish_fn_2+0x5a7>
     9c5:	mov    rsi,rbx
     9c8:	test   rsi,0x1
     9cf:	jne    9fa <botlish_fn_2+0x452>
     9d5:	mov    edx,0x17f
     9da:	mov    rsi,rbx
     9dd:	mov    rdi,r12
     9e0:	call   9e5 <botlish_fn_2+0x43d>
			9e1: R_X86_64_PLT32	rt_int_cmp-0x4
     9e5:	mov    edi,0x2
     9ea:	test   rax,rax
     9ed:	cmovle rdi,QWORD PTR [rip+0x1db]        # bd0 <botlish_fn_2+0x628>
     9f5:	jmp    a11 <botlish_fn_2+0x469>
     9fa:	mov    edi,0x2
     9ff:	mov    rsi,rbx
     a02:	cmp    rsi,0x17f
     a09:	cmovle rdi,QWORD PTR [rip+0x1bf]        # bd0 <botlish_fn_2+0x628>
     a11:	cmp    rdi,0x6
     a15:	je     b45 <botlish_fn_2+0x59d>
     a1b:	mov    rsi,rbx
     a1e:	test   rsi,0x1
     a25:	jne    a50 <botlish_fn_2+0x4a8>
     a2b:	mov    edx,0x19f
     a30:	mov    rsi,rbx
     a33:	mov    rdi,r12
     a36:	call   a3b <botlish_fn_2+0x493>
			a37: R_X86_64_PLT32	rt_int_cmp-0x4
     a3b:	mov    ecx,0x2
     a40:	test   rax,rax
     a43:	cmovle rcx,QWORD PTR [rip+0x185]        # bd0 <botlish_fn_2+0x628>
     a4b:	jmp    a67 <botlish_fn_2+0x4bf>
     a50:	mov    ecx,0x2
     a55:	mov    rsi,rbx
     a58:	cmp    rsi,0x19f
     a5f:	cmovle rcx,QWORD PTR [rip+0x169]        # bd0 <botlish_fn_2+0x628>
     a67:	cmp    rcx,0x6
     a6b:	je     b3b <botlish_fn_2+0x593>
     a71:	mov    rsi,rbx
     a74:	test   rsi,0x1
     a7b:	jne    aa6 <botlish_fn_2+0x4fe>
     a81:	mov    edx,0x1bf
     a86:	mov    rsi,rbx
     a89:	mov    rdi,r12
     a8c:	call   a91 <botlish_fn_2+0x4e9>
			a8d: R_X86_64_PLT32	rt_int_cmp-0x4
     a91:	mov    ecx,0x2
     a96:	test   rax,rax
     a99:	cmovle rcx,QWORD PTR [rip+0x12f]        # bd0 <botlish_fn_2+0x628>
     aa1:	jmp    abd <botlish_fn_2+0x515>
     aa6:	mov    ecx,0x2
     aab:	mov    rsi,rbx
     aae:	cmp    rsi,0x1bf
     ab5:	cmovle rcx,QWORD PTR [rip+0x113]        # bd0 <botlish_fn_2+0x628>
     abd:	cmp    rcx,0x6
     ac1:	je     b31 <botlish_fn_2+0x589>
     ac7:	mov    rsi,rbx
     aca:	test   rsi,0x1
     ad1:	jne    afc <botlish_fn_2+0x554>
     ad7:	mov    edx,0x1df
     adc:	mov    rsi,rbx
     adf:	mov    rdi,r12
     ae2:	call   ae7 <botlish_fn_2+0x53f>
			ae3: R_X86_64_PLT32	rt_int_cmp-0x4
     ae7:	mov    ecx,0x2
     aec:	test   rax,rax
     aef:	cmovle rcx,QWORD PTR [rip+0xd9]        # bd0 <botlish_fn_2+0x628>
     af7:	jmp    b13 <botlish_fn_2+0x56b>
     afc:	mov    ecx,0x2
     b01:	mov    rsi,rbx
     b04:	cmp    rsi,0x1df
     b0b:	cmovle rcx,QWORD PTR [rip+0xbd]        # bd0 <botlish_fn_2+0x628>
     b13:	cmp    rcx,0x6
     b17:	je     b27 <botlish_fn_2+0x57f>
     b1d:	mov    eax,0x1f
     b22:	jmp    bb8 <botlish_fn_2+0x610>
     b27:	mov    eax,0x1d
     b2c:	jmp    bb8 <botlish_fn_2+0x610>
     b31:	mov    eax,0x1b
     b36:	jmp    bb8 <botlish_fn_2+0x610>
     b3b:	mov    eax,0x19
     b40:	jmp    bb8 <botlish_fn_2+0x610>
     b45:	mov    eax,0x17
     b4a:	jmp    bb8 <botlish_fn_2+0x610>
     b4f:	mov    eax,0x15
     b54:	jmp    bb8 <botlish_fn_2+0x610>
     b59:	mov    eax,0x13
     b5e:	jmp    bb8 <botlish_fn_2+0x610>
     b63:	mov    eax,0x11
     b68:	jmp    bb8 <botlish_fn_2+0x610>
     b6d:	mov    eax,0xf
     b72:	jmp    bb8 <botlish_fn_2+0x610>
     b77:	mov    eax,0xd
     b7c:	jmp    bb8 <botlish_fn_2+0x610>
     b81:	mov    eax,0xb
     b86:	jmp    bb8 <botlish_fn_2+0x610>
     b8b:	mov    eax,0x9
     b90:	jmp    bb8 <botlish_fn_2+0x610>
     b95:	mov    eax,0x7
     b9a:	jmp    bb8 <botlish_fn_2+0x610>
     b9f:	mov    eax,0x5
     ba4:	jmp    bb8 <botlish_fn_2+0x610>
     ba9:	mov    eax,0x3
     bae:	jmp    bb8 <botlish_fn_2+0x610>
     bb3:	mov    eax,0x1
     bb8:	mov    rbx,QWORD PTR [rsp]
     bbc:	mov    r12,QWORD PTR [rsp+0x8]
     bc1:	add    rsp,0x10
     bc5:	mov    rsp,rbp
     bc8:	pop    rbp
     bc9:	ret
     bca:	add    BYTE PTR [rax],al
     bcc:	add    BYTE PTR [rax],al
     bce:	add    BYTE PTR [rax],al
     bd0:	(bad)
     bd1:	add    BYTE PTR [rax],al
     bd3:	add    BYTE PTR [rax],al
     bd5:	add    BYTE PTR [rax],al
	...

0000000000000bd8 <botlish_entry_2: high_nibble<generic>>:
     bd8:	push   rbp
     bd9:	mov    rbp,rsp
     bdc:	mov    rsi,QWORD PTR [rdx]
     bdf:	call   be4 <botlish_entry_2+0xc>
			be0: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
     be4:	mov    rsp,rbp
     be7:	pop    rbp
     be8:	ret
     be9:	add    BYTE PTR [rax],al
     beb:	add    BYTE PTR [rax],al
     bed:	add    BYTE PTR [rax],al
	...

0000000000000bf0 <botlish_fn_3: is_unreserved<generic>>:
     bf0:	push   rbp
     bf1:	mov    rbp,rsp
     bf4:	sub    rsp,0x20
     bf8:	mov    QWORD PTR [rsp],rbx
     bfc:	mov    QWORD PTR [rsp+0x8],r12
     c01:	mov    QWORD PTR [rsp+0x10],r13
     c06:	mov    r8d,0x1
     c0c:	test   rsi,0x1
     c13:	jne    c33 <botlish_fn_3+0x43>
     c19:	xor    r8d,r8d
     c1c:	test   rsi,0x7
     c23:	jne    c33 <botlish_fn_3+0x43>
     c29:	movzx  rax,BYTE PTR [rsi]
     c2d:	cmp    al,0x1
     c2f:	sete   r8b
     c33:	test   r8b,r8b
     c36:	jne    c6c <botlish_fn_3+0x7c>
     c3c:	mov    rdx,QWORD PTR [rdi+0x10]
     c40:	mov    rcx,QWORD PTR [rdx+0xa0]
     c47:	xor    rbx,rbx
     c4a:	mov    rdx,rbx
     c4d:	call   c52 <botlish_fn_3+0x62>
			c4e: R_X86_64_PLT32	rt_type_error-0x4
     c52:	mov    rax,rbx
     c55:	mov    rbx,QWORD PTR [rsp]
     c59:	mov    r12,QWORD PTR [rsp+0x8]
     c5e:	mov    r13,QWORD PTR [rsp+0x10]
     c63:	add    rsp,0x20
     c67:	mov    rsp,rbp
     c6a:	pop    rbp
     c6b:	ret
     c6c:	mov    r12,rdi
     c6f:	test   rsi,0x1
     c76:	mov    rbx,rsi
     c79:	jne    ca4 <botlish_fn_3+0xb4>
     c7f:	mov    edx,0x59
     c84:	mov    rsi,rbx
     c87:	mov    rdi,r12
     c8a:	call   c8f <botlish_fn_3+0x9f>
			c8b: R_X86_64_PLT32	rt_int_cmp-0x4
     c8f:	mov    ecx,0x2
     c94:	test   rax,rax
     c97:	cmovle rcx,QWORD PTR [rip+0x461]        # 1100 <botlish_fn_3+0x510>
     c9f:	jmp    cb8 <botlish_fn_3+0xc8>
     ca4:	mov    ecx,0x2
     ca9:	mov    rsi,rbx
     cac:	cmp    rsi,0x59
     cb0:	cmovle rcx,QWORD PTR [rip+0x448]        # 1100 <botlish_fn_3+0x510>
     cb8:	mov    eax,0x6
     cbd:	mov    r13,rax
     cc0:	cmp    rcx,0x6
     cc4:	je     10e3 <botlish_fn_3+0x4f3>
     cca:	mov    rsi,rbx
     ccd:	test   rsi,0x1
     cd4:	jne    cff <botlish_fn_3+0x10f>
     cda:	mov    edx,0x5d
     cdf:	mov    rsi,rbx
     ce2:	mov    rdi,r12
     ce5:	call   cea <botlish_fn_3+0xfa>
			ce6: R_X86_64_PLT32	rt_int_cmp-0x4
     cea:	mov    ecx,0x2
     cef:	test   rax,rax
     cf2:	cmovle rcx,QWORD PTR [rip+0x406]        # 1100 <botlish_fn_3+0x510>
     cfa:	jmp    d13 <botlish_fn_3+0x123>
     cff:	mov    ecx,0x2
     d04:	mov    rsi,rbx
     d07:	cmp    rsi,0x5d
     d0b:	cmovle rcx,QWORD PTR [rip+0x3ed]        # 1100 <botlish_fn_3+0x510>
     d13:	cmp    rcx,0x6
     d17:	je     10db <botlish_fn_3+0x4eb>
     d1d:	mov    rsi,rbx
     d20:	test   rsi,0x1
     d27:	jne    d52 <botlish_fn_3+0x162>
     d2d:	mov    edx,0x5f
     d32:	mov    rsi,rbx
     d35:	mov    rdi,r12
     d38:	call   d3d <botlish_fn_3+0x14d>
			d39: R_X86_64_PLT32	rt_int_cmp-0x4
     d3d:	mov    ecx,0x2
     d42:	test   rax,rax
     d45:	cmovle rcx,QWORD PTR [rip+0x3b3]        # 1100 <botlish_fn_3+0x510>
     d4d:	jmp    d66 <botlish_fn_3+0x176>
     d52:	mov    ecx,0x2
     d57:	mov    rsi,rbx
     d5a:	cmp    rsi,0x5f
     d5e:	cmovle rcx,QWORD PTR [rip+0x39a]        # 1100 <botlish_fn_3+0x510>
     d66:	cmp    rcx,0x6
     d6a:	je     10d1 <botlish_fn_3+0x4e1>
     d70:	mov    rsi,rbx
     d73:	test   rsi,0x1
     d7a:	jne    da5 <botlish_fn_3+0x1b5>
     d80:	mov    edx,0x73
     d85:	mov    rsi,rbx
     d88:	mov    rdi,r12
     d8b:	call   d90 <botlish_fn_3+0x1a0>
			d8c: R_X86_64_PLT32	rt_int_cmp-0x4
     d90:	mov    ecx,0x2
     d95:	test   rax,rax
     d98:	cmovle rcx,QWORD PTR [rip+0x360]        # 1100 <botlish_fn_3+0x510>
     da0:	jmp    db9 <botlish_fn_3+0x1c9>
     da5:	mov    ecx,0x2
     daa:	mov    rsi,rbx
     dad:	cmp    rsi,0x73
     db1:	cmovle rcx,QWORD PTR [rip+0x347]        # 1100 <botlish_fn_3+0x510>
     db9:	cmp    rcx,0x6
     dbd:	je     10c9 <botlish_fn_3+0x4d9>
     dc3:	mov    rsi,rbx
     dc6:	test   rsi,0x1
     dcd:	jne    df8 <botlish_fn_3+0x208>
     dd3:	mov    edx,0x81
     dd8:	mov    rsi,rbx
     ddb:	mov    rdi,r12
     dde:	call   de3 <botlish_fn_3+0x1f3>
			ddf: R_X86_64_PLT32	rt_int_cmp-0x4
     de3:	mov    ecx,0x2
     de8:	test   rax,rax
     deb:	cmovle rcx,QWORD PTR [rip+0x30d]        # 1100 <botlish_fn_3+0x510>
     df3:	jmp    e0f <botlish_fn_3+0x21f>
     df8:	mov    ecx,0x2
     dfd:	mov    rsi,rbx
     e00:	cmp    rsi,0x81
     e07:	cmovle rcx,QWORD PTR [rip+0x2f1]        # 1100 <botlish_fn_3+0x510>
     e0f:	cmp    rcx,0x6
     e13:	je     10bf <botlish_fn_3+0x4cf>
     e19:	mov    rsi,rbx
     e1c:	test   rsi,0x1
     e23:	jne    e4e <botlish_fn_3+0x25e>
     e29:	mov    edx,0xb5
     e2e:	mov    rsi,rbx
     e31:	mov    rdi,r12
     e34:	call   e39 <botlish_fn_3+0x249>
			e35: R_X86_64_PLT32	rt_int_cmp-0x4
     e39:	mov    ecx,0x2
     e3e:	test   rax,rax
     e41:	cmovle rcx,QWORD PTR [rip+0x2b7]        # 1100 <botlish_fn_3+0x510>
     e49:	jmp    e65 <botlish_fn_3+0x275>
     e4e:	mov    ecx,0x2
     e53:	mov    rsi,rbx
     e56:	cmp    rsi,0xb5
     e5d:	cmovle rcx,QWORD PTR [rip+0x29b]        # 1100 <botlish_fn_3+0x510>
     e65:	cmp    rcx,0x6
     e69:	je     10b7 <botlish_fn_3+0x4c7>
     e6f:	mov    rsi,rbx
     e72:	test   rsi,0x1
     e79:	jne    ea4 <botlish_fn_3+0x2b4>
     e7f:	mov    edx,0xbd
     e84:	mov    rsi,rbx
     e87:	mov    rdi,r12
     e8a:	call   e8f <botlish_fn_3+0x29f>
			e8b: R_X86_64_PLT32	rt_int_cmp-0x4
     e8f:	mov    ecx,0x2
     e94:	test   rax,rax
     e97:	cmovle rcx,QWORD PTR [rip+0x261]        # 1100 <botlish_fn_3+0x510>
     e9f:	jmp    ebb <botlish_fn_3+0x2cb>
     ea4:	mov    ecx,0x2
     ea9:	mov    rsi,rbx
     eac:	cmp    rsi,0xbd
     eb3:	cmovle rcx,QWORD PTR [rip+0x245]        # 1100 <botlish_fn_3+0x510>
     ebb:	cmp    rcx,0x6
     ebf:	je     10ad <botlish_fn_3+0x4bd>
     ec5:	mov    rsi,rbx
     ec8:	test   rsi,0x1
     ecf:	jne    efb <botlish_fn_3+0x30b>
     ed5:	mov    edx,0xbf
     eda:	mov    rsi,rbx
     edd:	mov    rdi,r12
     ee0:	call   ee5 <botlish_fn_3+0x2f5>
			ee1: R_X86_64_PLT32	rt_int_cmp-0x4
     ee5:	mov    r11d,0x2
     eeb:	test   rax,rax
     eee:	cmovle r11,QWORD PTR [rip+0x20a]        # 1100 <botlish_fn_3+0x510>
     ef6:	jmp    f13 <botlish_fn_3+0x323>
     efb:	mov    r11d,0x2
     f01:	mov    rsi,rbx
     f04:	cmp    rsi,0xbf
     f0b:	cmovle r11,QWORD PTR [rip+0x1ed]        # 1100 <botlish_fn_3+0x510>
     f13:	cmp    r11,0x6
     f17:	je     10a5 <botlish_fn_3+0x4b5>
     f1d:	mov    rsi,rbx
     f20:	test   rsi,0x1
     f27:	jne    f52 <botlish_fn_3+0x362>
     f2d:	mov    edx,0xc1
     f32:	mov    rsi,rbx
     f35:	mov    rdi,r12
     f38:	call   f3d <botlish_fn_3+0x34d>
			f39: R_X86_64_PLT32	rt_int_cmp-0x4
     f3d:	mov    ecx,0x2
     f42:	test   rax,rax
     f45:	cmovle rcx,QWORD PTR [rip+0x1b3]        # 1100 <botlish_fn_3+0x510>
     f4d:	jmp    f69 <botlish_fn_3+0x379>
     f52:	mov    ecx,0x2
     f57:	mov    rsi,rbx
     f5a:	cmp    rsi,0xc1
     f61:	cmovle rcx,QWORD PTR [rip+0x197]        # 1100 <botlish_fn_3+0x510>
     f69:	cmp    rcx,0x6
     f6d:	je     109b <botlish_fn_3+0x4ab>
     f73:	mov    rsi,rbx
     f76:	test   rsi,0x1
     f7d:	jne    fa8 <botlish_fn_3+0x3b8>
     f83:	mov    edx,0xf5
     f88:	mov    rsi,rbx
     f8b:	mov    rdi,r12
     f8e:	call   f93 <botlish_fn_3+0x3a3>
			f8f: R_X86_64_PLT32	rt_int_cmp-0x4
     f93:	mov    ecx,0x2
     f98:	test   rax,rax
     f9b:	cmovle rcx,QWORD PTR [rip+0x15d]        # 1100 <botlish_fn_3+0x510>
     fa3:	jmp    fbf <botlish_fn_3+0x3cf>
     fa8:	mov    ecx,0x2
     fad:	mov    rsi,rbx
     fb0:	cmp    rsi,0xf5
     fb7:	cmovle rcx,QWORD PTR [rip+0x141]        # 1100 <botlish_fn_3+0x510>
     fbf:	cmp    rcx,0x6
     fc3:	je     1093 <botlish_fn_3+0x4a3>
     fc9:	mov    rsi,rbx
     fcc:	test   rsi,0x1
     fd3:	jne    ffe <botlish_fn_3+0x40e>
     fd9:	mov    edx,0xfb
     fde:	mov    rsi,rbx
     fe1:	mov    rdi,r12
     fe4:	call   fe9 <botlish_fn_3+0x3f9>
			fe5: R_X86_64_PLT32	rt_int_cmp-0x4
     fe9:	mov    ecx,0x2
     fee:	test   rax,rax
     ff1:	cmovle rcx,QWORD PTR [rip+0x107]        # 1100 <botlish_fn_3+0x510>
     ff9:	jmp    1015 <botlish_fn_3+0x425>
     ffe:	mov    ecx,0x2
    1003:	mov    rsi,rbx
    1006:	cmp    rsi,0xfb
    100d:	cmovle rcx,QWORD PTR [rip+0xeb]        # 1100 <botlish_fn_3+0x510>
    1015:	cmp    rcx,0x6
    1019:	je     1089 <botlish_fn_3+0x499>
    101f:	mov    rsi,rbx
    1022:	test   rsi,0x1
    1029:	jne    1055 <botlish_fn_3+0x465>
    102f:	mov    edx,0xfd
    1034:	mov    rsi,rbx
    1037:	mov    rdi,r12
    103a:	call   103f <botlish_fn_3+0x44f>
			103b: R_X86_64_PLT32	rt_int_cmp-0x4
    103f:	mov    r8d,0x2
    1045:	test   rax,rax
    1048:	cmovle r8,QWORD PTR [rip+0xb0]        # 1100 <botlish_fn_3+0x510>
    1050:	jmp    106d <botlish_fn_3+0x47d>
    1055:	mov    r8d,0x2
    105b:	mov    rsi,rbx
    105e:	cmp    rsi,0xfd
    1065:	cmovle r8,QWORD PTR [rip+0x93]        # 1100 <botlish_fn_3+0x510>
    106d:	cmp    r8,0x6
    1071:	je     1081 <botlish_fn_3+0x491>
    1077:	mov    eax,0x2
    107c:	jmp    10e8 <botlish_fn_3+0x4f8>
    1081:	mov    rax,r13
    1084:	jmp    10e8 <botlish_fn_3+0x4f8>
    1089:	mov    eax,0x2
    108e:	jmp    10e8 <botlish_fn_3+0x4f8>
    1093:	mov    rax,r13
    1096:	jmp    10e8 <botlish_fn_3+0x4f8>
    109b:	mov    eax,0x2
    10a0:	jmp    10e8 <botlish_fn_3+0x4f8>
    10a5:	mov    rax,r13
    10a8:	jmp    10e8 <botlish_fn_3+0x4f8>
    10ad:	mov    eax,0x2
    10b2:	jmp    10e8 <botlish_fn_3+0x4f8>
    10b7:	mov    rax,r13
    10ba:	jmp    10e8 <botlish_fn_3+0x4f8>
    10bf:	mov    eax,0x2
    10c4:	jmp    10e8 <botlish_fn_3+0x4f8>
    10c9:	mov    rax,r13
    10cc:	jmp    10e8 <botlish_fn_3+0x4f8>
    10d1:	mov    eax,0x2
    10d6:	jmp    10e8 <botlish_fn_3+0x4f8>
    10db:	mov    rax,r13
    10de:	jmp    10e8 <botlish_fn_3+0x4f8>
    10e3:	mov    eax,0x2
    10e8:	mov    rbx,QWORD PTR [rsp]
    10ec:	mov    r12,QWORD PTR [rsp+0x8]
    10f1:	mov    r13,QWORD PTR [rsp+0x10]
    10f6:	add    rsp,0x20
    10fa:	mov    rsp,rbp
    10fd:	pop    rbp
    10fe:	ret
    10ff:	add    BYTE PTR [rsi],al
    1101:	add    BYTE PTR [rax],al
    1103:	add    BYTE PTR [rax],al
    1105:	add    BYTE PTR [rax],al
	...

0000000000001108 <botlish_entry_3: is_unreserved<generic>>:
    1108:	push   rbp
    1109:	mov    rbp,rsp
    110c:	mov    rsi,QWORD PTR [rdx]
    110f:	call   1114 <botlish_entry_3+0xc>
			1110: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    1114:	mov    rsp,rbp
    1117:	pop    rbp
    1118:	ret

0000000000001119 <botlish_fn_4: hex_pair<generic>>:
    1119:	push   rbp
    111a:	mov    rbp,rsp
    111d:	sub    rsp,0x30
    1121:	mov    QWORD PTR [rsp],rbx
    1125:	mov    QWORD PTR [rsp+0x8],r12
    112a:	mov    QWORD PTR [rsp+0x10],r13
    112f:	mov    QWORD PTR [rsp+0x18],r14
    1134:	mov    QWORD PTR [rsp+0x20],r15
    1139:	mov    r13,rdx
    113c:	mov    rbx,QWORD PTR [rdi]
    113f:	mov    rax,QWORD PTR [rdi+0x8]
    1143:	lea    rcx,[rbx+0x10]
    1147:	cmp    rcx,rax
    114a:	ja     1353 <botlish_fn_4+0x23a>
    1150:	lea    rax,[rbx+0x10]
    1154:	mov    QWORD PTR [rdi],rax
    1157:	mov    rdx,r13
    115a:	mov    r12,rdi
    115d:	mov    QWORD PTR [rbx],rdx
    1160:	mov    rax,QWORD PTR [rsi+0x20]
    1164:	mov    r14,rsi
    1167:	mov    rsi,QWORD PTR [rax]
    116a:	mov    QWORD PTR [rbx+0x8],rsi
    116e:	mov    r15,rsi
    1171:	mov    rsi,r13
    1174:	mov    rdi,r12
    1177:	call   117c <botlish_fn_4+0x63>
			1178: R_X86_64_PLT32	botlish_fn_2-0x4 ; high_nibble<generic>
    117c:	test   rax,rax
    117f:	jne    118d <botlish_fn_4+0x74>
    1185:	mov    rdi,r12
    1188:	jmp    1302 <botlish_fn_4+0x1e9>
    118d:	test   rax,0x1
    1193:	jne    11a4 <botlish_fn_4+0x8b>
    1199:	mov    rdx,rax
    119c:	mov    rsi,r15
    119f:	jmp    11c0 <botlish_fn_4+0xa7>
    11a4:	mov    rsi,r15
    11a7:	mov    rdx,QWORD PTR [rsi+0x8]
    11ab:	mov    rcx,rax
    11ae:	sar    rcx,1
    11b1:	mov    rdi,rax
    11b4:	cmp    rcx,rdx
    11b7:	jb     11e1 <botlish_fn_4+0xc8>
    11bd:	mov    rdx,rdi
    11c0:	mov    rdi,r12
    11c3:	call   11c8 <botlish_fn_4+0xaf>
			11c4: R_X86_64_PLT32	rt_list_get-0x4
    11c8:	test   rax,rax
    11cb:	jne    11d9 <botlish_fn_4+0xc0>
    11d1:	mov    rdi,r12
    11d4:	jmp    1302 <botlish_fn_4+0x1e9>
    11d9:	mov    rsi,rax
    11dc:	jmp    11e9 <botlish_fn_4+0xd0>
    11e1:	mov    rax,QWORD PTR [rsi+0x10]
    11e5:	mov    rsi,QWORD PTR [rax+rcx*8]
    11e9:	mov    QWORD PTR [rbx],rsi
    11ec:	mov    rax,rsi
    11ef:	mov    rsi,r14
    11f2:	mov    r14,rax
    11f5:	mov    rdx,QWORD PTR [rsi+0x20]
    11f9:	mov    rsi,QWORD PTR [rdx]
    11fc:	mov    r15,rsi
    11ff:	mov    ecx,0x1
    1204:	mov    rdx,r13
    1207:	test   rdx,0x1
    120e:	je     121c <botlish_fn_4+0x103>
    1214:	mov    r13,rdx
    1217:	jmp    1241 <botlish_fn_4+0x128>
    121c:	xor    ecx,ecx
    121e:	test   rdx,0x7
    1225:	je     1233 <botlish_fn_4+0x11a>
    122b:	mov    r13,rdx
    122e:	jmp    1241 <botlish_fn_4+0x128>
    1233:	movzx  r8,BYTE PTR [rdx]
    1237:	mov    r13,rdx
    123a:	cmp    r8b,0x1
    123e:	sete   cl
    1241:	test   cl,cl
    1243:	jne    126a <botlish_fn_4+0x151>
    1249:	mov    rdi,r12
    124c:	mov    rax,QWORD PTR [rdi+0x10]
    1250:	mov    rcx,QWORD PTR [rax+0xa8]
    1257:	xor    rdx,rdx
    125a:	mov    rsi,r13
    125d:	call   1262 <botlish_fn_4+0x149>
			125e: R_X86_64_PLT32	rt_type_error-0x4
    1262:	mov    rdi,r12
    1265:	jmp    1302 <botlish_fn_4+0x1e9>
    126a:	mov    rsi,r13
    126d:	mov    edx,0x21
    1272:	mov    rdi,r12
    1275:	call   127a <botlish_fn_4+0x161>
			1276: R_X86_64_PLT32	rt_int_mod-0x4
    127a:	test   rax,rax
    127d:	jne    128b <botlish_fn_4+0x172>
    1283:	mov    rdi,r12
    1286:	jmp    1302 <botlish_fn_4+0x1e9>
    128b:	test   rax,0x1
    1291:	jne    12a2 <botlish_fn_4+0x189>
    1297:	mov    rdx,rax
    129a:	mov    rsi,r15
    129d:	jmp    12be <botlish_fn_4+0x1a5>
    12a2:	mov    rsi,r15
    12a5:	mov    rdx,QWORD PTR [rsi+0x8]
    12a9:	mov    rcx,rax
    12ac:	sar    rcx,1
    12af:	mov    rdi,rax
    12b2:	cmp    rcx,rdx
    12b5:	jb     12df <botlish_fn_4+0x1c6>
    12bb:	mov    rdx,rdi
    12be:	mov    rdi,r12
    12c1:	call   12c6 <botlish_fn_4+0x1ad>
			12c2: R_X86_64_PLT32	rt_list_get-0x4
    12c6:	test   rax,rax
    12c9:	jne    12d7 <botlish_fn_4+0x1be>
    12cf:	mov    rdi,r12
    12d2:	jmp    1302 <botlish_fn_4+0x1e9>
    12d7:	mov    rdx,rax
    12da:	jmp    12e7 <botlish_fn_4+0x1ce>
    12df:	mov    rax,QWORD PTR [rsi+0x10]
    12e3:	mov    rdx,QWORD PTR [rax+rcx*8]
    12e7:	mov    QWORD PTR [rbx+0x8],rdx
    12eb:	mov    rsi,r14
    12ee:	mov    rdi,r12
    12f1:	call   12f6 <botlish_fn_4+0x1dd>
			12f2: R_X86_64_PLT32	rt_str_cat-0x4
    12f6:	test   rax,rax
    12f9:	jne    132c <botlish_fn_4+0x213>
    12ff:	mov    rdi,r12
    1302:	mov    rdi,r12
    1305:	mov    QWORD PTR [rdi],rbx
    1308:	xor    rax,rax
    130b:	mov    rbx,QWORD PTR [rsp]
    130f:	mov    r12,QWORD PTR [rsp+0x8]
    1314:	mov    r13,QWORD PTR [rsp+0x10]
    1319:	mov    r14,QWORD PTR [rsp+0x18]
    131e:	mov    r15,QWORD PTR [rsp+0x20]
    1323:	add    rsp,0x30
    1327:	mov    rsp,rbp
    132a:	pop    rbp
    132b:	ret
    132c:	mov    rdi,r12
    132f:	mov    QWORD PTR [rdi],rbx
    1332:	mov    rbx,QWORD PTR [rsp]
    1336:	mov    r12,QWORD PTR [rsp+0x8]
    133b:	mov    r13,QWORD PTR [rsp+0x10]
    1340:	mov    r14,QWORD PTR [rsp+0x18]
    1345:	mov    r15,QWORD PTR [rsp+0x20]
    134a:	add    rsp,0x30
    134e:	mov    rsp,rbp
    1351:	pop    rbp
    1352:	ret
    1353:	mov    r12,rdi
    1356:	call   135b <botlish_fn_4+0x242>
			1357: R_X86_64_PLT32	rt_stack_overflow-0x4
    135b:	xor    rax,rax
    135e:	mov    rbx,QWORD PTR [rsp]
    1362:	mov    r12,QWORD PTR [rsp+0x8]
    1367:	mov    r13,QWORD PTR [rsp+0x10]
    136c:	mov    r14,QWORD PTR [rsp+0x18]
    1371:	mov    r15,QWORD PTR [rsp+0x20]
    1376:	add    rsp,0x30
    137a:	mov    rsp,rbp
    137d:	pop    rbp
    137e:	ret

000000000000137f <botlish_entry_4: hex_pair<generic>>:
    137f:	push   rbp
    1380:	mov    rbp,rsp
    1383:	mov    rdx,QWORD PTR [rdx]
    1386:	call   138b <botlish_entry_4+0xc>
			1387: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    138b:	mov    rsp,rbp
    138e:	pop    rbp
    138f:	ret

0000000000001390 <botlish_fn_5: esc_bytes<generic>>:
    1390:	push   rbp
    1391:	mov    rbp,rsp
    1394:	sub    rsp,0x50
    1398:	mov    QWORD PTR [rsp+0x20],rbx
    139d:	mov    QWORD PTR [rsp+0x28],r12
    13a2:	mov    QWORD PTR [rsp+0x30],r13
    13a7:	mov    QWORD PTR [rsp+0x38],r14
    13ac:	mov    QWORD PTR [rsp+0x40],r15
    13b1:	mov    r15,rsi
    13b4:	mov    r13,QWORD PTR [rdi]
    13b7:	mov    r9,QWORD PTR [rdi+0x8]
    13bb:	lea    r10,[r13+0x38]
    13bf:	cmp    r10,r9
    13c2:	ja     1705 <botlish_fn_5+0x375>
    13c8:	lea    r10,[r13+0x38]
    13cc:	mov    QWORD PTR [rdi],r10
    13cf:	mov    r14,rdi
    13d2:	mov    QWORD PTR [r13+0x28],0x0
    13da:	mov    QWORD PTR [r13+0x30],0x0
    13e2:	mov    QWORD PTR [r13+0x0],rdx
    13e6:	mov    QWORD PTR [r13+0x8],rcx
    13ea:	mov    QWORD PTR [r13+0x10],r8
    13ee:	mov    QWORD PTR [rsp],rcx
    13f2:	mov    QWORD PTR [rsp+0x8],r8
    13f7:	xor    eax,eax
    13f9:	test   rdx,0x7
    1400:	je     140e <botlish_fn_5+0x7e>
    1406:	mov    rsi,rdx
    1409:	jmp    141a <botlish_fn_5+0x8a>
    140e:	movzx  rax,BYTE PTR [rdx]
    1412:	mov    rsi,rdx
    1415:	cmp    al,0x3
    1417:	sete   al
    141a:	test   al,al
    141c:	jne    1442 <botlish_fn_5+0xb2>
    1422:	mov    rdi,r14
    1425:	mov    rax,QWORD PTR [rdi+0x10]
    1429:	mov    rcx,QWORD PTR [rax+0xb0]
    1430:	mov    edx,0x4
    1435:	call   143a <botlish_fn_5+0xaa>
			1436: R_X86_64_PLT32	rt_type_error-0x4
    143a:	mov    rdi,r14
    143d:	jmp    1690 <botlish_fn_5+0x300>
    1442:	mov    rbx,rsi
    1445:	mov    rdi,r14
    1448:	call   144d <botlish_fn_5+0xbd>
			1449: R_X86_64_PLT32	rt_list_len-0x4
    144d:	mov    ecx,0x1
    1452:	mov    rsi,QWORD PTR [rsp]
    1456:	test   rsi,0x1
    145d:	jne    1485 <botlish_fn_5+0xf5>
    1463:	xor    ecx,ecx
    1465:	mov    rsi,QWORD PTR [rsp]
    1469:	test   rsi,0x7
    1470:	jne    1485 <botlish_fn_5+0xf5>
    1476:	mov    rsi,QWORD PTR [rsp]
    147a:	movzx  rcx,BYTE PTR [rsi]
    147e:	rex cmp cl,0x1
    1482:	sete   cl
    1485:	test   cl,cl
    1487:	jne    14af <botlish_fn_5+0x11f>
    148d:	mov    rdi,r14
    1490:	mov    rax,QWORD PTR [rdi+0x10]
    1494:	mov    rcx,QWORD PTR [rax+0xb8]
    149b:	xor    rdx,rdx
    149e:	mov    rsi,QWORD PTR [rsp]
    14a2:	call   14a7 <botlish_fn_5+0x117>
			14a3: R_X86_64_PLT32	rt_type_error-0x4
    14a7:	mov    rdi,r14
    14aa:	jmp    1690 <botlish_fn_5+0x300>
    14af:	mov    rsi,QWORD PTR [rsp]
    14b3:	mov    rcx,rsi
    14b6:	and    rcx,rax
    14b9:	mov    rdx,rax
    14bc:	test   rcx,0x1
    14c3:	jne    14ea <botlish_fn_5+0x15a>
    14c9:	mov    rsi,QWORD PTR [rsp]
    14cd:	mov    rdi,r14
    14d0:	call   14d5 <botlish_fn_5+0x145>
			14d1: R_X86_64_PLT32	rt_int_cmp-0x4
    14d5:	mov    esi,0x2
    14da:	test   rax,rax
    14dd:	cmovge rsi,QWORD PTR [rip+0x253]        # 1738 <botlish_fn_5+0x3a8>
    14e5:	jmp    14fe <botlish_fn_5+0x16e>
    14ea:	mov    esi,0x2
    14ef:	mov    rax,QWORD PTR [rsp]
    14f3:	cmp    rax,rdx
    14f6:	cmovge rsi,QWORD PTR [rip+0x23a]        # 1738 <botlish_fn_5+0x3a8>
    14fe:	cmp    rsi,0x6
    1502:	je     16d8 <botlish_fn_5+0x348>
    1508:	mov    QWORD PTR [r13+0x18],r15
    150c:	mov    QWORD PTR [r13+0x20],0x3
    1514:	mov    rsi,QWORD PTR [rsp]
    1518:	test   rsi,0x1
    151f:	je     1546 <botlish_fn_5+0x1b6>
    1525:	mov    rsi,QWORD PTR [rsp]
    1529:	mov    rax,rsi
    152c:	add    rax,0x2
    1530:	mov    rcx,rax
    1533:	seto   al
    1536:	test   al,al
    1538:	jne    1546 <botlish_fn_5+0x1b6>
    153e:	mov    r12,rcx
    1541:	jmp    155d <botlish_fn_5+0x1cd>
    1546:	mov    edx,0x3
    154b:	mov    rsi,QWORD PTR [rsp]
    154f:	mov    rdi,r14
    1552:	call   1557 <botlish_fn_5+0x1c7>
			1553: R_X86_64_PLT32	rt_int_add-0x4
    1557:	mov    rcx,rax
    155a:	mov    r12,rcx
    155d:	mov    QWORD PTR [r13+0x8],r12
    1561:	mov    rdi,r14
    1564:	mov    rax,QWORD PTR [rdi+0x10]
    1568:	mov    rsi,QWORD PTR [rax+0xc0]
    156f:	mov    QWORD PTR [r13+0x20],rsi
    1573:	mov    QWORD PTR [rsp+0x18],rsi
    1578:	mov    rax,QWORD PTR [r15+0x20]
    157c:	mov    rsi,QWORD PTR [rax]
    157f:	mov    QWORD PTR [r13+0x28],rsi
    1583:	mov    QWORD PTR [rsp+0x10],rsi
    1588:	mov    rsi,QWORD PTR [rsp]
    158c:	test   rsi,0x1
    1593:	jne    15a2 <botlish_fn_5+0x212>
    1599:	mov    rdx,QWORD PTR [rsp]
    159d:	jmp    15bd <botlish_fn_5+0x22d>
    15a2:	mov    rcx,QWORD PTR [rbx+0x8]
    15a6:	mov    rsi,QWORD PTR [rsp]
    15aa:	mov    rax,rsi
    15ad:	sar    rax,1
    15b0:	cmp    rax,rcx
    15b3:	jb     15e1 <botlish_fn_5+0x251>
    15b9:	mov    rdx,QWORD PTR [rsp]
    15bd:	mov    rsi,rbx
    15c0:	mov    rdi,r14
    15c3:	call   15c8 <botlish_fn_5+0x238>
			15c4: R_X86_64_PLT32	rt_list_get-0x4
    15c8:	test   rax,rax
    15cb:	jne    15d9 <botlish_fn_5+0x249>
    15d1:	mov    rdi,r14
    15d4:	jmp    1690 <botlish_fn_5+0x300>
    15d9:	mov    rdx,rax
    15dc:	jmp    15e9 <botlish_fn_5+0x259>
    15e1:	mov    rsi,QWORD PTR [rbx+0x10]
    15e5:	mov    rdx,QWORD PTR [rsi+rax*8]
    15e9:	mov    QWORD PTR [r13+0x30],rdx
    15ed:	mov    rsi,QWORD PTR [rsp+0x10]
    15f2:	mov    rdi,r14
    15f5:	call   15fa <botlish_fn_5+0x26a>
			15f6: R_X86_64_PLT32	botlish_fn_4-0x4 ; hex_pair<generic>
    15fa:	test   rax,rax
    15fd:	jne    160b <botlish_fn_5+0x27b>
    1603:	mov    rdi,r14
    1606:	jmp    1690 <botlish_fn_5+0x300>
    160b:	mov    QWORD PTR [r13+0x28],rax
    160f:	mov    rdx,rax
    1612:	mov    rsi,QWORD PTR [rsp+0x18]
    1617:	mov    rdi,r14
    161a:	call   161f <botlish_fn_5+0x28f>
			161b: R_X86_64_PLT32	rt_str_cat-0x4
    161f:	test   rax,rax
    1622:	jne    1630 <botlish_fn_5+0x2a0>
    1628:	mov    rdi,r14
    162b:	jmp    1690 <botlish_fn_5+0x300>
    1630:	mov    QWORD PTR [r13+0x20],rax
    1634:	mov    rdx,rax
    1637:	xor    eax,eax
    1639:	mov    rsi,QWORD PTR [rsp+0x8]
    163e:	test   rsi,0x7
    1645:	jne    1654 <botlish_fn_5+0x2c4>
    164b:	movzx  rax,BYTE PTR [rsi]
    164f:	cmp    al,0x2
    1651:	sete   al
    1654:	test   al,al
    1656:	jne    167c <botlish_fn_5+0x2ec>
    165c:	mov    rdi,r14
    165f:	mov    rax,QWORD PTR [rdi+0x10]
    1663:	mov    rcx,QWORD PTR [rax+0xc8]
    166a:	mov    edx,0x1
    166f:	call   1674 <botlish_fn_5+0x2e4>
			1670: R_X86_64_PLT32	rt_type_error-0x4
    1674:	mov    rdi,r14
    1677:	jmp    1690 <botlish_fn_5+0x300>
    167c:	mov    rdi,r14
    167f:	call   1684 <botlish_fn_5+0x2f4>
			1680: R_X86_64_PLT32	rt_str_cat-0x4
    1684:	test   rax,rax
    1687:	jne    16bb <botlish_fn_5+0x32b>
    168d:	mov    rdi,r14
    1690:	mov    rdi,r14
    1693:	mov    QWORD PTR [rdi],r13
    1696:	xor    rax,rax
    1699:	mov    rbx,QWORD PTR [rsp+0x20]
    169e:	mov    r12,QWORD PTR [rsp+0x28]
    16a3:	mov    r13,QWORD PTR [rsp+0x30]
    16a8:	mov    r14,QWORD PTR [rsp+0x38]
    16ad:	mov    r15,QWORD PTR [rsp+0x40]
    16b2:	add    rsp,0x50
    16b6:	mov    rsp,rbp
    16b9:	pop    rbp
    16ba:	ret
    16bb:	mov    QWORD PTR [r13+0x0],rbx
    16bf:	mov    QWORD PTR [r13+0x8],r12
    16c3:	mov    QWORD PTR [r13+0x10],rax
    16c7:	mov    rdx,rbx
    16ca:	mov    QWORD PTR [rsp],r12
    16ce:	mov    QWORD PTR [rsp+0x8],rax
    16d3:	jmp    13f7 <botlish_fn_5+0x67>
    16d8:	mov    rdi,r14
    16db:	mov    QWORD PTR [rdi],r13
    16de:	mov    rax,QWORD PTR [rsp+0x8]
    16e3:	mov    rbx,QWORD PTR [rsp+0x20]
    16e8:	mov    r12,QWORD PTR [rsp+0x28]
    16ed:	mov    r13,QWORD PTR [rsp+0x30]
    16f2:	mov    r14,QWORD PTR [rsp+0x38]
    16f7:	mov    r15,QWORD PTR [rsp+0x40]
    16fc:	add    rsp,0x50
    1700:	mov    rsp,rbp
    1703:	pop    rbp
    1704:	ret
    1705:	mov    r14,rdi
    1708:	call   170d <botlish_fn_5+0x37d>
			1709: R_X86_64_PLT32	rt_stack_overflow-0x4
    170d:	xor    rax,rax
    1710:	mov    rbx,QWORD PTR [rsp+0x20]
    1715:	mov    r12,QWORD PTR [rsp+0x28]
    171a:	mov    r13,QWORD PTR [rsp+0x30]
    171f:	mov    r14,QWORD PTR [rsp+0x38]
    1724:	mov    r15,QWORD PTR [rsp+0x40]
    1729:	add    rsp,0x50
    172d:	mov    rsp,rbp
    1730:	pop    rbp
    1731:	ret
    1732:	add    BYTE PTR [rax],al
    1734:	add    BYTE PTR [rax],al
    1736:	add    BYTE PTR [rax],al
    1738:	(bad)
    1739:	add    BYTE PTR [rax],al
    173b:	add    BYTE PTR [rax],al
    173d:	add    BYTE PTR [rax],al
	...

0000000000001740 <botlish_entry_5: esc_bytes<generic>>:
    1740:	push   rbp
    1741:	mov    rbp,rsp
    1744:	mov    r9,QWORD PTR [rdx]
    1747:	mov    rcx,QWORD PTR [rdx+0x8]
    174b:	mov    r8,QWORD PTR [rdx+0x10]
    174f:	mov    rdx,r9
    1752:	call   1757 <botlish_entry_5+0x17>
			1753: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    1757:	mov    rsp,rbp
    175a:	pop    rbp
    175b:	ret

000000000000175c <botlish_fn_6: esc_char<generic>>:
    175c:	push   rbp
    175d:	mov    rbp,rsp
    1760:	sub    rsp,0x40
    1764:	mov    QWORD PTR [rsp+0x10],rbx
    1769:	mov    QWORD PTR [rsp+0x18],r12
    176e:	mov    QWORD PTR [rsp+0x20],r13
    1773:	mov    QWORD PTR [rsp+0x28],r14
    1778:	mov    QWORD PTR [rsp+0x30],r15
    177d:	mov    rbx,rsi
    1780:	mov    r12,QWORD PTR [rdi]
    1783:	mov    rax,QWORD PTR [rdi+0x8]
    1787:	lea    rcx,[r12+0x20]
    178c:	cmp    rcx,rax
    178f:	ja     19aa <botlish_fn_6+0x24e>
    1795:	lea    rax,[r12+0x20]
    179a:	mov    QWORD PTR [rdi],rax
    179d:	mov    QWORD PTR [r12+0x8],0x0
    17a6:	mov    QWORD PTR [r12+0x10],0x0
    17af:	mov    QWORD PTR [r12+0x18],0x0
    17b8:	mov    QWORD PTR [r12],rdx
    17bc:	xor    eax,eax
    17be:	test   rdx,0x7
    17c5:	je     17d3 <botlish_fn_6+0x77>
    17cb:	mov    r14,rdx
    17ce:	jmp    17df <botlish_fn_6+0x83>
    17d3:	movzx  rax,BYTE PTR [rdx]
    17d7:	mov    r14,rdx
    17da:	cmp    al,0x2
    17dc:	sete   al
    17df:	test   al,al
    17e1:	jne    180a <botlish_fn_6+0xae>
    17e7:	mov    rax,QWORD PTR [rdi+0x10]
    17eb:	mov    r13,rdi
    17ee:	mov    rcx,QWORD PTR [rax+0xd0]
    17f5:	mov    edx,0x1
    17fa:	mov    rsi,r14
    17fd:	call   1802 <botlish_fn_6+0xa6>
			17fe: R_X86_64_PLT32	rt_type_error-0x4
    1802:	mov    rdi,r13
    1805:	jmp    194c <botlish_fn_6+0x1f0>
    180a:	mov    r13,rdi
    180d:	mov    rsi,r14
    1810:	call   1815 <botlish_fn_6+0xb9>
			1811: R_X86_64_PLT32	rt_str_utf8_bytes-0x4
    1815:	mov    rcx,rax
    1818:	mov    r15,rax
    181b:	test   rax,rcx
    181e:	jne    182c <botlish_fn_6+0xd0>
    1824:	mov    rdi,r13
    1827:	jmp    194c <botlish_fn_6+0x1f0>
    182c:	mov    rax,r15
    182f:	mov    QWORD PTR [r12+0x8],rax
    1834:	mov    rsi,r15
    1837:	mov    rdi,r13
    183a:	call   183f <botlish_fn_6+0xe3>
			183b: R_X86_64_PLT32	rt_list_len-0x4
    183f:	mov    ecx,0x1
    1844:	sar    rax,1
    1847:	cmp    rax,0x1
    184b:	je     189c <botlish_fn_6+0x140>
    1851:	mov    rdx,QWORD PTR [rbx+0x20]
    1855:	mov    rsi,QWORD PTR [rdx]
    1858:	mov    QWORD PTR [r12],rsi
    185c:	mov    QWORD PTR [r12+0x10],0x1
    1865:	mov    rdi,r13
    1868:	mov    rdi,QWORD PTR [rdi+0x10]
    186c:	mov    r8,QWORD PTR [rdi+0x98]
    1873:	mov    QWORD PTR [r12+0x18],r8
    1878:	mov    rdx,r15
    187b:	mov    rdi,r13
    187e:	call   1883 <botlish_fn_6+0x127>
			187f: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    1883:	test   rax,rax
    1886:	jne    1894 <botlish_fn_6+0x138>
    188c:	mov    rdi,r13
    188f:	jmp    194c <botlish_fn_6+0x1f0>
    1894:	mov    rdi,r13
    1897:	jmp    1982 <botlish_fn_6+0x226>
    189c:	mov    rdx,r15
    189f:	mov    QWORD PTR [rsp],rcx
    18a3:	mov    r10,QWORD PTR [rdx+0x8]
    18a7:	mov    r15,rdx
    18aa:	test   r10,r10
    18ad:	jne    18db <botlish_fn_6+0x17f>
    18b3:	mov    rdx,QWORD PTR [rsp]
    18b7:	mov    rsi,r15
    18ba:	mov    rdi,r13
    18bd:	call   18c2 <botlish_fn_6+0x166>
			18be: R_X86_64_PLT32	rt_list_get-0x4
    18c2:	test   rax,rax
    18c5:	jne    18d3 <botlish_fn_6+0x177>
    18cb:	mov    rdi,r13
    18ce:	jmp    194c <botlish_fn_6+0x1f0>
    18d3:	mov    rsi,rax
    18d6:	jmp    18e5 <botlish_fn_6+0x189>
    18db:	mov    rdx,r15
    18de:	mov    rax,QWORD PTR [rdx+0x10]
    18e2:	mov    rsi,QWORD PTR [rax]
    18e5:	mov    QWORD PTR [r12+0x10],rsi
    18ea:	mov    rdi,r13
    18ed:	call   18f2 <botlish_fn_6+0x196>
			18ee: R_X86_64_PLT32	botlish_fn_3-0x4 ; is_unreserved<generic>
    18f2:	test   rax,rax
    18f5:	jne    1903 <botlish_fn_6+0x1a7>
    18fb:	mov    rdi,r13
    18fe:	jmp    194c <botlish_fn_6+0x1f0>
    1903:	cmp    rax,0x6
    1907:	je     197c <botlish_fn_6+0x220>
    190d:	mov    rax,QWORD PTR [rbx+0x20]
    1911:	mov    rsi,QWORD PTR [rax]
    1914:	mov    QWORD PTR [r12],rsi
    1918:	mov    QWORD PTR [r12+0x10],0x1
    1921:	mov    rdi,r13
    1924:	mov    rax,QWORD PTR [rdi+0x10]
    1928:	mov    r8,QWORD PTR [rax+0x98]
    192f:	mov    QWORD PTR [r12+0x18],r8
    1934:	mov    rcx,QWORD PTR [rsp]
    1938:	mov    rdx,r15
    193b:	call   1940 <botlish_fn_6+0x1e4>
			193c: R_X86_64_PLT32	botlish_fn_5-0x4 ; esc_bytes<generic>
    1940:	test   rax,rax
    1943:	jne    197f <botlish_fn_6+0x223>
    1949:	mov    rdi,r13
    194c:	mov    rdi,r13
    194f:	mov    QWORD PTR [rdi],r12
    1952:	xor    rax,rax
    1955:	mov    rbx,QWORD PTR [rsp+0x10]
    195a:	mov    r12,QWORD PTR [rsp+0x18]
    195f:	mov    r13,QWORD PTR [rsp+0x20]
    1964:	mov    r14,QWORD PTR [rsp+0x28]
    1969:	mov    r15,QWORD PTR [rsp+0x30]
    196e:	add    rsp,0x40
    1972:	mov    rsp,rbp
    1975:	pop    rbp
    1976:	ret
    1977:	jmp    197f <botlish_fn_6+0x223>
    197c:	mov    rax,r14
    197f:	mov    rdi,r13
    1982:	mov    rdi,r13
    1985:	mov    QWORD PTR [rdi],r12
    1988:	mov    rbx,QWORD PTR [rsp+0x10]
    198d:	mov    r12,QWORD PTR [rsp+0x18]
    1992:	mov    r13,QWORD PTR [rsp+0x20]
    1997:	mov    r14,QWORD PTR [rsp+0x28]
    199c:	mov    r15,QWORD PTR [rsp+0x30]
    19a1:	add    rsp,0x40
    19a5:	mov    rsp,rbp
    19a8:	pop    rbp
    19a9:	ret
    19aa:	mov    r13,rdi
    19ad:	call   19b2 <botlish_fn_6+0x256>
			19ae: R_X86_64_PLT32	rt_stack_overflow-0x4
    19b2:	xor    rax,rax
    19b5:	mov    rbx,QWORD PTR [rsp+0x10]
    19ba:	mov    r12,QWORD PTR [rsp+0x18]
    19bf:	mov    r13,QWORD PTR [rsp+0x20]
    19c4:	mov    r14,QWORD PTR [rsp+0x28]
    19c9:	mov    r15,QWORD PTR [rsp+0x30]
    19ce:	add    rsp,0x40
    19d2:	mov    rsp,rbp
    19d5:	pop    rbp
    19d6:	ret

00000000000019d7 <botlish_entry_6: esc_char<generic>>:
    19d7:	push   rbp
    19d8:	mov    rbp,rsp
    19db:	mov    rdx,QWORD PTR [rdx]
    19de:	call   19e3 <botlish_entry_6+0xc>
			19df: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    19e3:	mov    rsp,rbp
    19e6:	pop    rbp
    19e7:	ret

00000000000019e8 <botlish_fn_7: esc_from<generic>>:
    19e8:	push   rbp
    19e9:	mov    rbp,rsp
    19ec:	sub    rsp,0x50
    19f0:	mov    QWORD PTR [rsp+0x20],rbx
    19f5:	mov    QWORD PTR [rsp+0x28],r12
    19fa:	mov    QWORD PTR [rsp+0x30],r13
    19ff:	mov    QWORD PTR [rsp+0x38],r14
    1a04:	mov    QWORD PTR [rsp+0x40],r15
    1a09:	mov    r12,rsi
    1a0c:	mov    r14,QWORD PTR [rdi]
    1a0f:	mov    rax,QWORD PTR [rdi+0x8]
    1a13:	lea    rsi,[r14+0x38]
    1a17:	cmp    rsi,rax
    1a1a:	ja     1d89 <botlish_fn_7+0x3a1>
    1a20:	lea    rax,[r14+0x38]
    1a24:	mov    QWORD PTR [rdi],rax
    1a27:	mov    r15,rdi
    1a2a:	mov    QWORD PTR [r14+0x28],0x0
    1a32:	mov    QWORD PTR [r14+0x30],0x0
    1a3a:	mov    QWORD PTR [r14],rdx
    1a3d:	mov    QWORD PTR [r14+0x8],rcx
    1a41:	mov    QWORD PTR [r14+0x10],r8
    1a45:	mov    QWORD PTR [rsp],rcx
    1a49:	mov    QWORD PTR [rsp+0x8],r8
    1a4e:	xor    eax,eax
    1a50:	test   rdx,0x7
    1a57:	je     1a65 <botlish_fn_7+0x7d>
    1a5d:	mov    rsi,rdx
    1a60:	jmp    1a71 <botlish_fn_7+0x89>
    1a65:	movzx  rax,BYTE PTR [rdx]
    1a69:	mov    rsi,rdx
    1a6c:	cmp    al,0x2
    1a6e:	sete   al
    1a71:	test   al,al
    1a73:	jne    1a99 <botlish_fn_7+0xb1>
    1a79:	mov    rdi,r15
    1a7c:	mov    rax,QWORD PTR [rdi+0x10]
    1a80:	mov    rcx,QWORD PTR [rax+0xd8]
    1a87:	mov    edx,0x1
    1a8c:	call   1a91 <botlish_fn_7+0xa9>
			1a8d: R_X86_64_PLT32	rt_type_error-0x4
    1a91:	mov    rdi,r15
    1a94:	jmp    1d15 <botlish_fn_7+0x32d>
    1a99:	mov    rbx,rsi
    1a9c:	mov    rdi,r15
    1a9f:	call   1aa4 <botlish_fn_7+0xbc>
			1aa0: R_X86_64_PLT32	rt_str_len-0x4
    1aa4:	mov    edx,0x1
    1aa9:	mov    QWORD PTR [rsp+0x18],rdx
    1aae:	mov    ecx,0x1
    1ab3:	mov    rsi,QWORD PTR [rsp]
    1ab7:	test   rsi,0x1
    1abe:	jne    1ae6 <botlish_fn_7+0xfe>
    1ac4:	xor    ecx,ecx
    1ac6:	mov    rsi,QWORD PTR [rsp]
    1aca:	test   rsi,0x7
    1ad1:	jne    1ae6 <botlish_fn_7+0xfe>
    1ad7:	mov    rsi,QWORD PTR [rsp]
    1adb:	movzx  rcx,BYTE PTR [rsi]
    1adf:	rex cmp cl,0x1
    1ae3:	sete   cl
    1ae6:	test   cl,cl
    1ae8:	jne    1b10 <botlish_fn_7+0x128>
    1aee:	mov    rdi,r15
    1af1:	mov    rax,QWORD PTR [rdi+0x10]
    1af5:	mov    rcx,QWORD PTR [rax+0xb8]
    1afc:	xor    rdx,rdx
    1aff:	mov    rsi,QWORD PTR [rsp]
    1b03:	call   1b08 <botlish_fn_7+0x120>
			1b04: R_X86_64_PLT32	rt_type_error-0x4
    1b08:	mov    rdi,r15
    1b0b:	jmp    1d15 <botlish_fn_7+0x32d>
    1b10:	mov    rsi,QWORD PTR [rsp]
    1b14:	mov    rcx,rsi
    1b17:	and    rcx,rax
    1b1a:	mov    rdx,rax
    1b1d:	test   rcx,0x1
    1b24:	jne    1b4b <botlish_fn_7+0x163>
    1b2a:	mov    rsi,QWORD PTR [rsp]
    1b2e:	mov    rdi,r15
    1b31:	call   1b36 <botlish_fn_7+0x14e>
			1b32: R_X86_64_PLT32	rt_int_cmp-0x4
    1b36:	mov    esi,0x2
    1b3b:	test   rax,rax
    1b3e:	cmovge rsi,QWORD PTR [rip+0x272]        # 1db8 <botlish_fn_7+0x3d0>
    1b46:	jmp    1b5f <botlish_fn_7+0x177>
    1b4b:	mov    esi,0x2
    1b50:	mov    rax,QWORD PTR [rsp]
    1b54:	cmp    rax,rdx
    1b57:	cmovge rsi,QWORD PTR [rip+0x259]        # 1db8 <botlish_fn_7+0x3d0>
    1b5f:	cmp    rsi,0x6
    1b63:	je     1d5c <botlish_fn_7+0x374>
    1b69:	mov    QWORD PTR [r14+0x18],r12
    1b6d:	mov    QWORD PTR [r14+0x20],0x3
    1b75:	mov    rsi,QWORD PTR [rsp]
    1b79:	test   rsi,0x1
    1b80:	je     1ba7 <botlish_fn_7+0x1bf>
    1b86:	mov    rsi,QWORD PTR [rsp]
    1b8a:	mov    rax,rsi
    1b8d:	add    rax,0x2
    1b91:	mov    rcx,rax
    1b94:	seto   al
    1b97:	test   al,al
    1b99:	jne    1ba7 <botlish_fn_7+0x1bf>
    1b9f:	mov    r13,rcx
    1ba2:	jmp    1bbe <botlish_fn_7+0x1d6>
    1ba7:	mov    edx,0x3
    1bac:	mov    rsi,QWORD PTR [rsp]
    1bb0:	mov    rdi,r15
    1bb3:	call   1bb8 <botlish_fn_7+0x1d0>
			1bb4: R_X86_64_PLT32	rt_int_add-0x4
    1bb8:	mov    rcx,rax
    1bbb:	mov    r13,rcx
    1bbe:	mov    QWORD PTR [r14+0x20],r13
    1bc2:	mov    rax,QWORD PTR [r12+0x20]
    1bc7:	mov    rsi,QWORD PTR [rax]
    1bca:	mov    QWORD PTR [r14+0x28],rsi
    1bce:	mov    QWORD PTR [rsp+0x10],rsi
    1bd3:	mov    QWORD PTR [r14+0x30],0x3
    1bdb:	mov    rsi,QWORD PTR [rsp]
    1bdf:	test   rsi,0x1
    1be6:	je     1c04 <botlish_fn_7+0x21c>
    1bec:	mov    rsi,QWORD PTR [rsp]
    1bf0:	mov    rcx,rsi
    1bf3:	add    rcx,0x2
    1bf7:	seto   sil
    1bfb:	test   sil,sil
    1bfe:	je     1c18 <botlish_fn_7+0x230>
    1c04:	mov    edx,0x3
    1c09:	mov    rsi,QWORD PTR [rsp]
    1c0d:	mov    rdi,r15
    1c10:	call   1c15 <botlish_fn_7+0x22d>
			1c11: R_X86_64_PLT32	rt_int_add-0x4
    1c15:	mov    rcx,rax
    1c18:	mov    QWORD PTR [r14+0x30],rcx
    1c1c:	mov    rdx,QWORD PTR [rsp]
    1c20:	mov    rsi,rbx
    1c23:	mov    rdi,r15
    1c26:	call   1c2b <botlish_fn_7+0x243>
			1c27: R_X86_64_PLT32	rt_substr-0x4
    1c2b:	test   rax,rax
    1c2e:	jne    1c3c <botlish_fn_7+0x254>
    1c34:	mov    rdi,r15
    1c37:	jmp    1d15 <botlish_fn_7+0x32d>
    1c3c:	mov    QWORD PTR [r14+0x8],rax
    1c40:	mov    rdx,rax
    1c43:	mov    rsi,QWORD PTR [rsp+0x10]
    1c48:	mov    rdi,r15
    1c4b:	call   1c50 <botlish_fn_7+0x268>
			1c4c: R_X86_64_PLT32	botlish_fn_6-0x4 ; esc_char<generic>
    1c50:	test   rax,rax
    1c53:	jne    1c61 <botlish_fn_7+0x279>
    1c59:	mov    rdi,r15
    1c5c:	jmp    1d15 <botlish_fn_7+0x32d>
    1c61:	mov    QWORD PTR [r14+0x8],rax
    1c65:	xor    ecx,ecx
    1c67:	mov    rsi,QWORD PTR [rsp+0x8]
    1c6c:	test   rsi,0x7
    1c73:	jne    1c84 <botlish_fn_7+0x29c>
    1c79:	movzx  rcx,BYTE PTR [rsi]
    1c7d:	rex cmp cl,0x2
    1c81:	sete   cl
    1c84:	test   cl,cl
    1c86:	jne    1cac <botlish_fn_7+0x2c4>
    1c8c:	mov    rdi,r15
    1c8f:	mov    rax,QWORD PTR [rdi+0x10]
    1c93:	mov    rcx,QWORD PTR [rax+0xc8]
    1c9a:	mov    rdx,QWORD PTR [rsp+0x18]
    1c9f:	call   1ca4 <botlish_fn_7+0x2bc>
			1ca0: R_X86_64_PLT32	rt_type_error-0x4
    1ca4:	mov    rdi,r15
    1ca7:	jmp    1d15 <botlish_fn_7+0x32d>
    1cac:	mov    rdx,QWORD PTR [rsp+0x18]
    1cb1:	xor    r11d,r11d
    1cb4:	test   rax,0x7
    1cba:	je     1cc8 <botlish_fn_7+0x2e0>
    1cc0:	mov    r8,rax
    1cc3:	jmp    1cd7 <botlish_fn_7+0x2ef>
    1cc8:	movzx  rcx,BYTE PTR [rax]
    1ccc:	mov    r8,rax
    1ccf:	rex cmp cl,0x2
    1cd3:	sete   r11b
    1cd7:	test   r11b,r11b
    1cda:	jne    1cfe <botlish_fn_7+0x316>
    1ce0:	mov    rdi,r15
    1ce3:	mov    rax,QWORD PTR [rdi+0x10]
    1ce7:	mov    rcx,QWORD PTR [rax+0xc8]
    1cee:	mov    rsi,r8
    1cf1:	call   1cf6 <botlish_fn_7+0x30e>
			1cf2: R_X86_64_PLT32	rt_type_error-0x4
    1cf6:	mov    rdi,r15
    1cf9:	jmp    1d15 <botlish_fn_7+0x32d>
    1cfe:	mov    rdx,r8
    1d01:	mov    rdi,r15
    1d04:	call   1d09 <botlish_fn_7+0x321>
			1d05: R_X86_64_PLT32	rt_str_cat-0x4
    1d09:	test   rax,rax
    1d0c:	jne    1d40 <botlish_fn_7+0x358>
    1d12:	mov    rdi,r15
    1d15:	mov    rdi,r15
    1d18:	mov    QWORD PTR [rdi],r14
    1d1b:	xor    rax,rax
    1d1e:	mov    rbx,QWORD PTR [rsp+0x20]
    1d23:	mov    r12,QWORD PTR [rsp+0x28]
    1d28:	mov    r13,QWORD PTR [rsp+0x30]
    1d2d:	mov    r14,QWORD PTR [rsp+0x38]
    1d32:	mov    r15,QWORD PTR [rsp+0x40]
    1d37:	add    rsp,0x50
    1d3b:	mov    rsp,rbp
    1d3e:	pop    rbp
    1d3f:	ret
    1d40:	mov    QWORD PTR [r14],rbx
    1d43:	mov    QWORD PTR [r14+0x8],r13
    1d47:	mov    QWORD PTR [r14+0x10],rax
    1d4b:	mov    rdx,rbx
    1d4e:	mov    QWORD PTR [rsp],r13
    1d52:	mov    QWORD PTR [rsp+0x8],rax
    1d57:	jmp    1a4e <botlish_fn_7+0x66>
    1d5c:	mov    rdi,r15
    1d5f:	mov    QWORD PTR [rdi],r14
    1d62:	mov    rax,QWORD PTR [rsp+0x8]
    1d67:	mov    rbx,QWORD PTR [rsp+0x20]
    1d6c:	mov    r12,QWORD PTR [rsp+0x28]
    1d71:	mov    r13,QWORD PTR [rsp+0x30]
    1d76:	mov    r14,QWORD PTR [rsp+0x38]
    1d7b:	mov    r15,QWORD PTR [rsp+0x40]
    1d80:	add    rsp,0x50
    1d84:	mov    rsp,rbp
    1d87:	pop    rbp
    1d88:	ret
    1d89:	mov    r15,rdi
    1d8c:	call   1d91 <botlish_fn_7+0x3a9>
			1d8d: R_X86_64_PLT32	rt_stack_overflow-0x4
    1d91:	xor    rax,rax
    1d94:	mov    rbx,QWORD PTR [rsp+0x20]
    1d99:	mov    r12,QWORD PTR [rsp+0x28]
    1d9e:	mov    r13,QWORD PTR [rsp+0x30]
    1da3:	mov    r14,QWORD PTR [rsp+0x38]
    1da8:	mov    r15,QWORD PTR [rsp+0x40]
    1dad:	add    rsp,0x50
    1db1:	mov    rsp,rbp
    1db4:	pop    rbp
    1db5:	ret
    1db6:	add    BYTE PTR [rax],al
    1db8:	(bad)
    1db9:	add    BYTE PTR [rax],al
    1dbb:	add    BYTE PTR [rax],al
    1dbd:	add    BYTE PTR [rax],al
	...

0000000000001dc0 <botlish_entry_7: esc_from<generic>>:
    1dc0:	push   rbp
    1dc1:	mov    rbp,rsp
    1dc4:	mov    r9,QWORD PTR [rdx]
    1dc7:	mov    rcx,QWORD PTR [rdx+0x8]
    1dcb:	mov    r8,QWORD PTR [rdx+0x10]
    1dcf:	mov    rdx,r9
    1dd2:	call   1dd7 <botlish_entry_7+0x17>
			1dd3: R_X86_64_PLT32	botlish_fn_7-0x4 ; esc_from<generic>
    1dd7:	mov    rsp,rbp
    1dda:	pop    rbp
    1ddb:	ret
    1ddc:	add    BYTE PTR [rax],al
	...

0000000000001de0 <botlish_fn_8: check<int, int, str, str>>:
    1de0:	push   rbp
    1de1:	mov    rbp,rsp
    1de4:	sub    rsp,0x40
    1de8:	mov    QWORD PTR [rsp+0x10],rbx
    1ded:	mov    QWORD PTR [rsp+0x18],r12
    1df2:	mov    QWORD PTR [rsp+0x20],r13
    1df7:	mov    QWORD PTR [rsp+0x28],r14
    1dfc:	mov    QWORD PTR [rsp+0x30],r15
    1e01:	mov    r13,QWORD PTR [rdi]
    1e04:	mov    rax,QWORD PTR [rdi+0x8]
    1e08:	lea    r9,[r13+0x28]
    1e0c:	cmp    r9,rax
    1e0f:	ja     1fcb <botlish_fn_8+0x1eb>
    1e15:	lea    rax,[r13+0x28]
    1e19:	mov    QWORD PTR [rdi],rax
    1e1c:	mov    r14,rdi
    1e1f:	mov    QWORD PTR [r13+0x20],0x0
    1e27:	mov    QWORD PTR [r13+0x0],rsi
    1e2b:	mov    QWORD PTR [r13+0x8],rdx
    1e2f:	mov    QWORD PTR [r13+0x10],rcx
    1e33:	mov    r12,rcx
    1e36:	mov    QWORD PTR [r13+0x18],r8
    1e3a:	mov    r15,r8
    1e3d:	mov    rbx,rsi
    1e40:	mov    QWORD PTR [rsp],rdx
    1e44:	test   rbx,0x1
    1e4b:	jne    1e76 <botlish_fn_8+0x96>
    1e51:	mov    edx,0x1
    1e56:	mov    rsi,rbx
    1e59:	mov    rdi,r14
    1e5c:	call   1e61 <botlish_fn_8+0x81>
			1e5d: R_X86_64_PLT32	rt_int_cmp-0x4
    1e61:	mov    ecx,0x2
    1e66:	test   rax,rax
    1e69:	cmovle rcx,QWORD PTR [rip+0x187]        # 1ff8 <botlish_fn_8+0x218>
    1e71:	jmp    1e87 <botlish_fn_8+0xa7>
    1e76:	mov    ecx,0x2
    1e7b:	cmp    rbx,0x1
    1e7f:	cmovle rcx,QWORD PTR [rip+0x171]        # 1ff8 <botlish_fn_8+0x218>
    1e87:	cmp    rcx,0x6
    1e8b:	je     1f9f <botlish_fn_8+0x1bf>
    1e91:	mov    rdi,r14
    1e94:	mov    rax,QWORD PTR [rdi+0x10]
    1e98:	mov    rax,QWORD PTR [rax+0xe0]
    1e9f:	mov    rsi,r12
    1ea2:	call   1ea7 <botlish_fn_8+0xc7>
			1ea3: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    1ea7:	test   rax,rax
    1eaa:	jne    1eb8 <botlish_fn_8+0xd8>
    1eb0:	mov    rdi,r14
    1eb3:	jmp    1ef6 <botlish_fn_8+0x116>
    1eb8:	cmp    rax,0x6
    1ebc:	je     1ed4 <botlish_fn_8+0xf4>
    1ec2:	mov    edx,0x1
    1ec7:	mov    QWORD PTR [r13+0x0],0x1
    1ecf:	jmp    1f3e <botlish_fn_8+0x15e>
    1ed4:	mov    rdi,r14
    1ed7:	mov    rsi,QWORD PTR [rdi+0x10]
    1edb:	mov    rsi,QWORD PTR [rsi+0xe8]
    1ee2:	mov    rsi,r12
    1ee5:	call   1eea <botlish_fn_8+0x10a>
			1ee6: R_X86_64_PLT32	botlish_fn_20-0x4 ; <str>
    1eea:	test   rax,rax
    1eed:	jne    1f21 <botlish_fn_8+0x141>
    1ef3:	mov    rdi,r14
    1ef6:	mov    rdi,r14
    1ef9:	mov    QWORD PTR [rdi],r13
    1efc:	xor    rax,rax
    1eff:	mov    rbx,QWORD PTR [rsp+0x10]
    1f04:	mov    r12,QWORD PTR [rsp+0x18]
    1f09:	mov    r13,QWORD PTR [rsp+0x20]
    1f0e:	mov    r14,QWORD PTR [rsp+0x28]
    1f13:	mov    r15,QWORD PTR [rsp+0x30]
    1f18:	add    rsp,0x40
    1f1c:	mov    rsp,rbp
    1f1f:	pop    rbp
    1f20:	ret
    1f21:	cmp    rax,0x6
    1f25:	je     1f35 <botlish_fn_8+0x155>
    1f2b:	mov    edx,0x1
    1f30:	jmp    1f3a <botlish_fn_8+0x15a>
    1f35:	mov    edx,0x3
    1f3a:	mov    QWORD PTR [r13+0x0],rdx
    1f3e:	sar    rbx,1
    1f41:	sub    rbx,0x1
    1f45:	shl    rbx,1
    1f48:	or     rbx,0x1
    1f4c:	mov    QWORD PTR [r13+0x20],rbx
    1f50:	mov    rsi,QWORD PTR [rsp]
    1f54:	mov    rax,rsi
    1f57:	and    rax,rdx
    1f5a:	test   rax,0x1
    1f60:	je     1f7b <botlish_fn_8+0x19b>
    1f66:	lea    rcx,[rdx-0x1]
    1f6a:	mov    rax,rsi
    1f6d:	add    rax,rcx
    1f70:	seto   cl
    1f73:	test   cl,cl
    1f75:	je     1f83 <botlish_fn_8+0x1a3>
    1f7b:	mov    rdi,r14
    1f7e:	call   1f83 <botlish_fn_8+0x1a3>
			1f7f: R_X86_64_PLT32	rt_int_add-0x4
    1f83:	mov    QWORD PTR [r13+0x0],rbx
    1f87:	mov    QWORD PTR [r13+0x8],rax
    1f8b:	mov    QWORD PTR [r13+0x10],r12
    1f8f:	mov    r8,r15
    1f92:	mov    QWORD PTR [r13+0x18],r8
    1f96:	mov    QWORD PTR [rsp],rax
    1f9a:	jmp    1e44 <botlish_fn_8+0x64>
    1f9f:	mov    rdi,r14
    1fa2:	mov    QWORD PTR [rdi],r13
    1fa5:	mov    rax,QWORD PTR [rsp]
    1fa9:	mov    rbx,QWORD PTR [rsp+0x10]
    1fae:	mov    r12,QWORD PTR [rsp+0x18]
    1fb3:	mov    r13,QWORD PTR [rsp+0x20]
    1fb8:	mov    r14,QWORD PTR [rsp+0x28]
    1fbd:	mov    r15,QWORD PTR [rsp+0x30]
    1fc2:	add    rsp,0x40
    1fc6:	mov    rsp,rbp
    1fc9:	pop    rbp
    1fca:	ret
    1fcb:	mov    r14,rdi
    1fce:	call   1fd3 <botlish_fn_8+0x1f3>
			1fcf: R_X86_64_PLT32	rt_stack_overflow-0x4
    1fd3:	xor    rax,rax
    1fd6:	mov    rbx,QWORD PTR [rsp+0x10]
    1fdb:	mov    r12,QWORD PTR [rsp+0x18]
    1fe0:	mov    r13,QWORD PTR [rsp+0x20]
    1fe5:	mov    r14,QWORD PTR [rsp+0x28]
    1fea:	mov    r15,QWORD PTR [rsp+0x30]
    1fef:	add    rsp,0x40
    1ff3:	mov    rsp,rbp
    1ff6:	pop    rbp
    1ff7:	ret
    1ff8:	(bad)
    1ff9:	add    BYTE PTR [rax],al
    1ffb:	add    BYTE PTR [rax],al
    1ffd:	add    BYTE PTR [rax],al
	...

0000000000002000 <botlish_entry_8: check<int, int, str, str>>:
    2000:	push   rbp
    2001:	mov    rbp,rsp
    2004:	mov    rsi,QWORD PTR [rdx]
    2007:	mov    r9,QWORD PTR [rdx+0x8]
    200b:	mov    rcx,QWORD PTR [rdx+0x10]
    200f:	mov    r8,QWORD PTR [rdx+0x18]
    2013:	mov    rdx,r9
    2016:	call   201b <botlish_entry_8+0x1b>
			2017: R_X86_64_PLT32	botlish_fn_8-0x4 ; check<int, int, str, str>
    201b:	mov    rsp,rbp
    201e:	pop    rbp
    201f:	ret

0000000000002020 <botlish_fn_9: <str>>:
    2020:	push   rbp
    2021:	mov    rbp,rsp
    2024:	sub    rsp,0xc0
    202b:	mov    QWORD PTR [rsp+0x90],rbx
    2033:	mov    QWORD PTR [rsp+0x98],r12
    203b:	mov    QWORD PTR [rsp+0xa0],r13
    2043:	mov    QWORD PTR [rsp+0xa8],r14
    204b:	mov    QWORD PTR [rsp+0xb0],r15
    2053:	mov    r12,QWORD PTR [rdi]
    2056:	mov    rax,QWORD PTR [rdi+0x8]
    205a:	lea    rcx,[r12+0x28]
    205f:	cmp    rcx,rax
    2062:	ja     2474 <botlish_fn_9+0x454>
    2068:	lea    rax,[r12+0x28]
    206d:	mov    QWORD PTR [rdi],rax
    2070:	mov    QWORD PTR [rsp+0x78],rdi
    2075:	mov    QWORD PTR [r12+0x10],0x0
    207e:	mov    QWORD PTR [r12+0x18],0x0
    2087:	mov    QWORD PTR [r12+0x20],0x0
    2090:	mov    QWORD PTR [r12],rsi
    2094:	mov    r13,rsi
    2097:	mov    rsi,r13
    209a:	mov    rdi,QWORD PTR [rsp+0x78]
    209f:	call   20a4 <botlish_fn_9+0x84>
			20a0: R_X86_64_PLT32	rt_str_len-0x4
    20a4:	mov    rbx,rax
    20a7:	mov    QWORD PTR [r12+0x8],rbx
    20ac:	lea    r8,[rsp]
    20b0:	mov    QWORD PTR [rsp],r13
    20b4:	mov    esi,0xb
    20b9:	mov    rdx,QWORD PTR [rip+0x0]        # 20c0 <botlish_fn_9+0xa0>
			20bc: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    20c0:	mov    r13d,0x1
    20c6:	mov    rcx,r13
    20c9:	mov    rdi,QWORD PTR [rsp+0x78]
    20ce:	call   20d3 <botlish_fn_9+0xb3>
			20cf: R_X86_64_PLT32	rt_closure_new-0x4
    20d3:	mov    r14,rax
    20d6:	mov    QWORD PTR [r12],rax
    20da:	lea    r8,[rsp+0x8]
    20df:	mov    QWORD PTR [rsp+0x8],rbx
    20e4:	mov    QWORD PTR [rsp+0x10],rax
    20e9:	mov    esi,0xf
    20ee:	mov    rdx,QWORD PTR [rip+0x0]        # 20f5 <botlish_fn_9+0xd5>
			20f1: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_local<generic>
    20f5:	mov    r15d,0x2
    20fb:	mov    rcx,r15
    20fe:	mov    rdi,QWORD PTR [rsp+0x78]
    2103:	call   2108 <botlish_fn_9+0xe8>
			2104: R_X86_64_PLT32	rt_closure_new-0x4
    2108:	mov    rcx,rax
    210b:	mov    QWORD PTR [rsp+0x88],rax
    2113:	mov    QWORD PTR [r12+0x10],rcx
    2118:	lea    r8,[rsp+0x18]
    211d:	mov    QWORD PTR [rsp+0x18],rbx
    2122:	mov    rax,r14
    2125:	mov    QWORD PTR [rsp+0x20],rax
    212a:	mov    esi,0x10
    212f:	mov    rdx,QWORD PTR [rip+0x0]        # 2136 <botlish_fn_9+0x116>
			2132: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; scan_label<generic>
    2136:	mov    rcx,r15
    2139:	mov    rdi,QWORD PTR [rsp+0x78]
    213e:	call   2143 <botlish_fn_9+0x123>
			213f: R_X86_64_PLT32	rt_closure_new-0x4
    2143:	mov    QWORD PTR [r12+0x18],rax
    2148:	mov    QWORD PTR [rsp+0x80],rax
    2150:	lea    r8,[rsp+0x28]
    2155:	mov    QWORD PTR [rsp+0x28],rbx
    215a:	mov    QWORD PTR [rsp+0x30],r14
    215f:	mov    esi,0x11
    2164:	mov    rdx,QWORD PTR [rip+0x0]        # 216b <botlish_fn_9+0x14b>
			2167: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; scan_alpha<generic>
    216b:	mov    rcx,r15
    216e:	mov    rdi,QWORD PTR [rsp+0x78]
    2173:	call   2178 <botlish_fn_9+0x158>
			2174: R_X86_64_PLT32	rt_closure_new-0x4
    2178:	mov    QWORD PTR [r12+0x20],rax
    217d:	lea    r8,[rsp+0x38]
    2182:	mov    QWORD PTR [rsp+0x38],rax
    2187:	mov    QWORD PTR [rsp+0x40],rbx
    218c:	mov    esi,0x12
    2191:	mov    rdx,QWORD PTR [rip+0x0]        # 2198 <botlish_fn_9+0x178>
			2194: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; tld_ok<generic>
    2198:	mov    rcx,r15
    219b:	mov    rdi,QWORD PTR [rsp+0x78]
    21a0:	call   21a5 <botlish_fn_9+0x185>
			21a1: R_X86_64_PLT32	rt_closure_new-0x4
    21a5:	mov    QWORD PTR [r12+0x20],rax
    21aa:	lea    r8,[rsp+0x48]
    21af:	mov    rcx,QWORD PTR [rsp+0x80]
    21b7:	mov    QWORD PTR [rsp+0x48],rcx
    21bc:	mov    QWORD PTR [rsp+0x50],rbx
    21c1:	mov    QWORD PTR [rsp+0x58],r14
    21c6:	mov    QWORD PTR [rsp+0x60],rax
    21cb:	mov    esi,0x13
    21d0:	mov    rdx,QWORD PTR [rip+0x0]        # 21d7 <botlish_fn_9+0x1b7>
			21d3: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; domain_loop<generic>
    21d7:	mov    ecx,0x4
    21dc:	mov    rdi,QWORD PTR [rsp+0x78]
    21e1:	call   21e6 <botlish_fn_9+0x1c6>
			21e2: R_X86_64_PLT32	rt_closure_new-0x4
    21e6:	mov    QWORD PTR [r12+0x18],rax
    21eb:	mov    r15,rax
    21ee:	mov    QWORD PTR [r12+0x20],0x1
    21f7:	mov    rdx,r13
    21fa:	mov    rsi,QWORD PTR [rsp+0x88]
    2202:	mov    rdi,QWORD PTR [rsp+0x78]
    2207:	call   220c <botlish_fn_9+0x1ec>
			2208: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    220c:	mov    rcx,rax
    220f:	mov    r13,rax
    2212:	test   rax,rcx
    2215:	jne    2225 <botlish_fn_9+0x205>
    221b:	mov    rdi,QWORD PTR [rsp+0x78]
    2220:	jmp    238a <botlish_fn_9+0x36a>
    2225:	mov    rax,r13
    2228:	mov    QWORD PTR [r12+0x10],rax
    222d:	test   rax,0x1
    2233:	jne    2261 <botlish_fn_9+0x241>
    2239:	mov    edx,0x1
    223e:	mov    rsi,r13
    2241:	mov    rdi,QWORD PTR [rsp+0x78]
    2246:	call   224b <botlish_fn_9+0x22b>
			2247: R_X86_64_PLT32	rt_int_cmp-0x4
    224b:	mov    r10d,0x2
    2251:	test   rax,rax
    2254:	cmove  r10,QWORD PTR [rip+0x25c]        # 24b8 <botlish_fn_9+0x498>
    225c:	jmp    2273 <botlish_fn_9+0x253>
    2261:	mov    r10d,0x2
    2267:	cmp    r13,0x1
    226b:	cmove  r10,QWORD PTR [rip+0x245]        # 24b8 <botlish_fn_9+0x498>
    2273:	cmp    r10,0x6
    2277:	je     242e <botlish_fn_9+0x40e>
    227d:	mov    rax,r13
    2280:	and    rax,rbx
    2283:	test   rax,0x1
    2289:	jne    22b4 <botlish_fn_9+0x294>
    228f:	mov    rdx,rbx
    2292:	mov    rsi,r13
    2295:	mov    rdi,QWORD PTR [rsp+0x78]
    229a:	call   229f <botlish_fn_9+0x27f>
			229b: R_X86_64_PLT32	rt_int_cmp-0x4
    229f:	mov    ecx,0x2
    22a4:	test   rax,rax
    22a7:	cmovge rcx,QWORD PTR [rip+0x209]        # 24b8 <botlish_fn_9+0x498>
    22af:	jmp    22c4 <botlish_fn_9+0x2a4>
    22b4:	mov    ecx,0x2
    22b9:	cmp    r13,rbx
    22bc:	cmovge rcx,QWORD PTR [rip+0x1f4]        # 24b8 <botlish_fn_9+0x498>
    22c4:	cmp    rcx,0x6
    22c8:	je     241f <botlish_fn_9+0x3ff>
    22ce:	lea    rcx,[rsp+0x68]
    22d3:	mov    rsi,r14
    22d6:	mov    rdx,r13
    22d9:	mov    rdi,QWORD PTR [rsp+0x78]
    22de:	call   22e3 <botlish_fn_9+0x2c3>
			22df: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    22e3:	test   rax,rax
    22e6:	jne    22f6 <botlish_fn_9+0x2d6>
    22ec:	mov    rdi,QWORD PTR [rsp+0x78]
    22f1:	jmp    238a <botlish_fn_9+0x36a>
    22f6:	mov    rdx,QWORD PTR [rsp+0x68]
    22fb:	mov    rcx,QWORD PTR [rsp+0x70]
    2300:	mov    rdi,QWORD PTR [rsp+0x78]
    2305:	mov    rsi,QWORD PTR [rdi+0x10]
    2309:	mov    r8,QWORD PTR [rsi+0x100]
    2310:	mov    rsi,rax
    2313:	call   2318 <botlish_fn_9+0x2f8>
			2314: R_X86_64_PLT32	rt_str_region_eq-0x4
    2318:	cmp    rax,0x6
    231c:	je     232f <botlish_fn_9+0x30f>
    2322:	mov    ecx,0x2
    2327:	mov    rax,rcx
    232a:	jmp    2424 <botlish_fn_9+0x404>
    232f:	mov    QWORD PTR [r12],0x3
    2337:	test   r13,0x1
    233e:	je     2356 <botlish_fn_9+0x336>
    2344:	mov    rdx,r13
    2347:	add    rdx,0x2
    234b:	seto   al
    234e:	test   al,al
    2350:	je     236b <botlish_fn_9+0x34b>
    2356:	mov    edx,0x3
    235b:	mov    rsi,r13
    235e:	mov    rdi,QWORD PTR [rsp+0x78]
    2363:	call   2368 <botlish_fn_9+0x348>
			2364: R_X86_64_PLT32	rt_int_add-0x4
    2368:	mov    rdx,rax
    236b:	mov    QWORD PTR [r12],rdx
    236f:	mov    rsi,r15
    2372:	mov    rdi,QWORD PTR [rsp+0x78]
    2377:	call   237c <botlish_fn_9+0x35c>
			2378: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    237c:	test   rax,rax
    237f:	jne    23c9 <botlish_fn_9+0x3a9>
    2385:	mov    rdi,QWORD PTR [rsp+0x78]
    238a:	mov    rdi,QWORD PTR [rsp+0x78]
    238f:	mov    QWORD PTR [rdi],r12
    2392:	xor    rax,rax
    2395:	mov    rbx,QWORD PTR [rsp+0x90]
    239d:	mov    r12,QWORD PTR [rsp+0x98]
    23a5:	mov    r13,QWORD PTR [rsp+0xa0]
    23ad:	mov    r14,QWORD PTR [rsp+0xa8]
    23b5:	mov    r15,QWORD PTR [rsp+0xb0]
    23bd:	add    rsp,0xc0
    23c4:	mov    rsp,rbp
    23c7:	pop    rbp
    23c8:	ret
    23c9:	mov    rcx,rax
    23cc:	and    rcx,rbx
    23cf:	mov    rsi,rax
    23d2:	mov    rax,rbx
    23d5:	test   rcx,0x1
    23dc:	jne    2407 <botlish_fn_9+0x3e7>
    23e2:	mov    rdx,rax
    23e5:	mov    rdi,QWORD PTR [rsp+0x78]
    23ea:	call   23ef <botlish_fn_9+0x3cf>
			23eb: R_X86_64_PLT32	rt_int_cmp-0x4
    23ef:	mov    ecx,0x2
    23f4:	test   rax,rax
    23f7:	mov    rax,rcx
    23fa:	cmove  rax,QWORD PTR [rip+0xb6]        # 24b8 <botlish_fn_9+0x498>
    2402:	jmp    2424 <botlish_fn_9+0x404>
    2407:	mov    rdx,rax
    240a:	mov    eax,0x2
    240f:	cmp    rsi,rdx
    2412:	cmove  rax,QWORD PTR [rip+0x9e]        # 24b8 <botlish_fn_9+0x498>
    241a:	jmp    2424 <botlish_fn_9+0x404>
    241f:	mov    eax,0x2
    2424:	mov    rdi,QWORD PTR [rsp+0x78]
    2429:	jmp    2438 <botlish_fn_9+0x418>
    242e:	mov    eax,0x2
    2433:	mov    rdi,QWORD PTR [rsp+0x78]
    2438:	mov    rdi,QWORD PTR [rsp+0x78]
    243d:	mov    QWORD PTR [rdi],r12
    2440:	mov    rbx,QWORD PTR [rsp+0x90]
    2448:	mov    r12,QWORD PTR [rsp+0x98]
    2450:	mov    r13,QWORD PTR [rsp+0xa0]
    2458:	mov    r14,QWORD PTR [rsp+0xa8]
    2460:	mov    r15,QWORD PTR [rsp+0xb0]
    2468:	add    rsp,0xc0
    246f:	mov    rsp,rbp
    2472:	pop    rbp
    2473:	ret
    2474:	mov    QWORD PTR [rsp+0x78],rdi
    2479:	call   247e <botlish_fn_9+0x45e>
			247a: R_X86_64_PLT32	rt_stack_overflow-0x4
    247e:	xor    rax,rax
    2481:	mov    rbx,QWORD PTR [rsp+0x90]
    2489:	mov    r12,QWORD PTR [rsp+0x98]
    2491:	mov    r13,QWORD PTR [rsp+0xa0]
    2499:	mov    r14,QWORD PTR [rsp+0xa8]
    24a1:	mov    r15,QWORD PTR [rsp+0xb0]
    24a9:	add    rsp,0xc0
    24b0:	mov    rsp,rbp
    24b3:	pop    rbp
    24b4:	ret
    24b5:	add    BYTE PTR [rax],al
    24b7:	add    BYTE PTR [rsi],al
    24b9:	add    BYTE PTR [rax],al
    24bb:	add    BYTE PTR [rax],al
    24bd:	add    BYTE PTR [rax],al
	...

00000000000024c0 <botlish_entry_9: <str>>:
    24c0:	push   rbp
    24c1:	mov    rbp,rsp
    24c4:	mov    rsi,QWORD PTR [rdx]
    24c7:	call   24cc <botlish_entry_9+0xc>
			24c8: R_X86_64_PLT32	botlish_fn_9-0x4 ; <str>
    24cc:	mov    rsp,rbp
    24cf:	pop    rbp
    24d0:	ret
    24d1:	add    BYTE PTR [rax],al
    24d3:	add    BYTE PTR [rax],al
    24d5:	add    BYTE PTR [rax],al
	...

00000000000024d8 <botlish_fn_10: <generic>>:
    24d8:	push   rbp
    24d9:	mov    rbp,rsp
    24dc:	sub    rsp,0xc0
    24e3:	mov    QWORD PTR [rsp+0x90],rbx
    24eb:	mov    QWORD PTR [rsp+0x98],r12
    24f3:	mov    QWORD PTR [rsp+0xa0],r13
    24fb:	mov    QWORD PTR [rsp+0xa8],r14
    2503:	mov    QWORD PTR [rsp+0xb0],r15
    250b:	mov    r12,QWORD PTR [rdi]
    250e:	mov    rax,QWORD PTR [rdi+0x8]
    2512:	lea    rcx,[r12+0x28]
    2517:	cmp    rcx,rax
    251a:	ja     296a <botlish_fn_10+0x492>
    2520:	lea    rax,[r12+0x28]
    2525:	mov    QWORD PTR [rdi],rax
    2528:	mov    QWORD PTR [r12+0x10],0x0
    2531:	mov    QWORD PTR [r12+0x18],0x0
    253a:	mov    QWORD PTR [r12+0x20],0x0
    2543:	mov    QWORD PTR [r12],rsi
    2547:	xor    eax,eax
    2549:	test   rsi,0x7
    2550:	jne    255f <botlish_fn_10+0x87>
    2556:	movzx  rax,BYTE PTR [rsi]
    255a:	cmp    al,0x2
    255c:	sete   al
    255f:	test   al,al
    2561:	jne    258b <botlish_fn_10+0xb3>
    2567:	mov    rax,QWORD PTR [rdi+0x10]
    256b:	mov    QWORD PTR [rsp+0x78],rdi
    2570:	mov    rcx,QWORD PTR [rax+0xd8]
    2577:	mov    edx,0x1
    257c:	call   2581 <botlish_fn_10+0xa9>
			257d: R_X86_64_PLT32	rt_type_error-0x4
    2581:	mov    rdi,QWORD PTR [rsp+0x78]
    2586:	jmp    2880 <botlish_fn_10+0x3a8>
    258b:	mov    r13,rsi
    258e:	mov    QWORD PTR [rsp+0x78],rdi
    2593:	call   2598 <botlish_fn_10+0xc0>
			2594: R_X86_64_PLT32	rt_str_len-0x4
    2598:	mov    rbx,rax
    259b:	mov    QWORD PTR [r12+0x8],rbx
    25a0:	lea    r8,[rsp]
    25a4:	mov    QWORD PTR [rsp],r13
    25a8:	mov    esi,0xb
    25ad:	mov    rdx,QWORD PTR [rip+0x0]        # 25b4 <botlish_fn_10+0xdc>
			25b0: R_X86_64_GOTPCREL	botlish_entry_11-0x4 ; char_at<generic>
    25b4:	mov    r13d,0x1
    25ba:	mov    rcx,r13
    25bd:	mov    rdi,QWORD PTR [rsp+0x78]
    25c2:	call   25c7 <botlish_fn_10+0xef>
			25c3: R_X86_64_PLT32	rt_closure_new-0x4
    25c7:	mov    r15,rax
    25ca:	mov    QWORD PTR [rsp+0x88],r13
    25d2:	mov    QWORD PTR [r12],rax
    25d6:	lea    r8,[rsp+0x8]
    25db:	mov    QWORD PTR [rsp+0x8],rbx
    25e0:	mov    QWORD PTR [rsp+0x10],rax
    25e5:	mov    esi,0xf
    25ea:	mov    rdx,QWORD PTR [rip+0x0]        # 25f1 <botlish_fn_10+0x119>
			25ed: R_X86_64_GOTPCREL	botlish_entry_15-0x4 ; scan_local<generic>
    25f1:	mov    r14d,0x2
    25f7:	mov    rcx,r14
    25fa:	mov    rdi,QWORD PTR [rsp+0x78]
    25ff:	call   2604 <botlish_fn_10+0x12c>
			2600: R_X86_64_PLT32	rt_closure_new-0x4
    2604:	mov    r13,rax
    2607:	mov    QWORD PTR [r12+0x10],r13
    260c:	lea    r8,[rsp+0x18]
    2611:	mov    QWORD PTR [rsp+0x18],rbx
    2616:	mov    rax,r15
    2619:	mov    QWORD PTR [rsp+0x20],rax
    261e:	mov    esi,0x10
    2623:	mov    rdx,QWORD PTR [rip+0x0]        # 262a <botlish_fn_10+0x152>
			2626: R_X86_64_GOTPCREL	botlish_entry_16-0x4 ; scan_label<generic>
    262a:	mov    rcx,r14
    262d:	mov    rdi,QWORD PTR [rsp+0x78]
    2632:	call   2637 <botlish_fn_10+0x15f>
			2633: R_X86_64_PLT32	rt_closure_new-0x4
    2637:	mov    QWORD PTR [r12+0x18],rax
    263c:	mov    QWORD PTR [rsp+0x80],rax
    2644:	lea    r8,[rsp+0x28]
    2649:	mov    QWORD PTR [rsp+0x28],rbx
    264e:	mov    QWORD PTR [rsp+0x30],r15
    2653:	mov    esi,0x11
    2658:	mov    rdx,QWORD PTR [rip+0x0]        # 265f <botlish_fn_10+0x187>
			265b: R_X86_64_GOTPCREL	botlish_entry_17-0x4 ; scan_alpha<generic>
    265f:	mov    rcx,r14
    2662:	mov    rdi,QWORD PTR [rsp+0x78]
    2667:	call   266c <botlish_fn_10+0x194>
			2668: R_X86_64_PLT32	rt_closure_new-0x4
    266c:	mov    QWORD PTR [r12+0x20],rax
    2671:	lea    r8,[rsp+0x38]
    2676:	mov    QWORD PTR [rsp+0x38],rax
    267b:	mov    QWORD PTR [rsp+0x40],rbx
    2680:	mov    esi,0x12
    2685:	mov    rdx,QWORD PTR [rip+0x0]        # 268c <botlish_fn_10+0x1b4>
			2688: R_X86_64_GOTPCREL	botlish_entry_18-0x4 ; tld_ok<generic>
    268c:	mov    rcx,r14
    268f:	mov    rdi,QWORD PTR [rsp+0x78]
    2694:	call   2699 <botlish_fn_10+0x1c1>
			2695: R_X86_64_PLT32	rt_closure_new-0x4
    2699:	mov    QWORD PTR [r12+0x20],rax
    269e:	lea    r8,[rsp+0x48]
    26a3:	mov    rcx,QWORD PTR [rsp+0x80]
    26ab:	mov    QWORD PTR [rsp+0x48],rcx
    26b0:	mov    QWORD PTR [rsp+0x50],rbx
    26b5:	mov    QWORD PTR [rsp+0x58],r15
    26ba:	mov    QWORD PTR [rsp+0x60],rax
    26bf:	mov    esi,0x13
    26c4:	mov    rdx,QWORD PTR [rip+0x0]        # 26cb <botlish_fn_10+0x1f3>
			26c7: R_X86_64_GOTPCREL	botlish_entry_19-0x4 ; domain_loop<generic>
    26cb:	mov    ecx,0x4
    26d0:	mov    rdi,QWORD PTR [rsp+0x78]
    26d5:	call   26da <botlish_fn_10+0x202>
			26d6: R_X86_64_PLT32	rt_closure_new-0x4
    26da:	mov    QWORD PTR [r12+0x18],rax
    26df:	mov    r14,rax
    26e2:	mov    QWORD PTR [r12+0x20],0x1
    26eb:	mov    rsi,r13
    26ee:	mov    rdx,QWORD PTR [rsp+0x88]
    26f6:	mov    rdi,QWORD PTR [rsp+0x78]
    26fb:	call   2700 <botlish_fn_10+0x228>
			26fc: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    2700:	mov    r10,rax
    2703:	mov    r13,rax
    2706:	test   rax,r10
    2709:	jne    2719 <botlish_fn_10+0x241>
    270f:	mov    rdi,QWORD PTR [rsp+0x78]
    2714:	jmp    2880 <botlish_fn_10+0x3a8>
    2719:	mov    rax,r13
    271c:	mov    QWORD PTR [r12+0x10],rax
    2721:	test   rax,0x1
    2727:	jne    2757 <botlish_fn_10+0x27f>
    272d:	mov    rdx,QWORD PTR [rsp+0x88]
    2735:	mov    rsi,r13
    2738:	mov    rdi,QWORD PTR [rsp+0x78]
    273d:	call   2742 <botlish_fn_10+0x26a>
			273e: R_X86_64_PLT32	rt_int_cmp-0x4
    2742:	mov    ecx,0x2
    2747:	test   rax,rax
    274a:	cmove  rcx,QWORD PTR [rip+0x25e]        # 29b0 <botlish_fn_10+0x4d8>
    2752:	jmp    2768 <botlish_fn_10+0x290>
    2757:	mov    ecx,0x2
    275c:	cmp    r13,0x1
    2760:	cmove  rcx,QWORD PTR [rip+0x248]        # 29b0 <botlish_fn_10+0x4d8>
    2768:	cmp    rcx,0x6
    276c:	je     2924 <botlish_fn_10+0x44c>
    2772:	mov    r11,r13
    2775:	and    r11,rbx
    2778:	test   r11,0x1
    277f:	jne    27aa <botlish_fn_10+0x2d2>
    2785:	mov    rdx,rbx
    2788:	mov    rsi,r13
    278b:	mov    rdi,QWORD PTR [rsp+0x78]
    2790:	call   2795 <botlish_fn_10+0x2bd>
			2791: R_X86_64_PLT32	rt_int_cmp-0x4
    2795:	mov    ecx,0x2
    279a:	test   rax,rax
    279d:	cmovge rcx,QWORD PTR [rip+0x20b]        # 29b0 <botlish_fn_10+0x4d8>
    27a5:	jmp    27ba <botlish_fn_10+0x2e2>
    27aa:	mov    ecx,0x2
    27af:	cmp    r13,rbx
    27b2:	cmovge rcx,QWORD PTR [rip+0x1f6]        # 29b0 <botlish_fn_10+0x4d8>
    27ba:	cmp    rcx,0x6
    27be:	je     2915 <botlish_fn_10+0x43d>
    27c4:	lea    rcx,[rsp+0x68]
    27c9:	mov    rsi,r15
    27cc:	mov    rdx,r13
    27cf:	mov    rdi,QWORD PTR [rsp+0x78]
    27d4:	call   27d9 <botlish_fn_10+0x301>
			27d5: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    27d9:	test   rax,rax
    27dc:	mov    rsi,rax
    27df:	jne    27ef <botlish_fn_10+0x317>
    27e5:	mov    rdi,QWORD PTR [rsp+0x78]
    27ea:	jmp    2880 <botlish_fn_10+0x3a8>
    27ef:	mov    rdx,QWORD PTR [rsp+0x68]
    27f4:	mov    rcx,QWORD PTR [rsp+0x70]
    27f9:	mov    rdi,QWORD PTR [rsp+0x78]
    27fe:	mov    rax,QWORD PTR [rdi+0x10]
    2802:	mov    r8,QWORD PTR [rax+0x100]
    2809:	call   280e <botlish_fn_10+0x336>
			280a: R_X86_64_PLT32	rt_str_region_eq-0x4
    280e:	cmp    rax,0x6
    2812:	je     2825 <botlish_fn_10+0x34d>
    2818:	mov    esi,0x2
    281d:	mov    rax,rsi
    2820:	jmp    291a <botlish_fn_10+0x442>
    2825:	mov    QWORD PTR [r12],0x3
    282d:	test   r13,0x1
    2834:	je     284c <botlish_fn_10+0x374>
    283a:	mov    rdx,r13
    283d:	add    rdx,0x2
    2841:	seto   al
    2844:	test   al,al
    2846:	je     2861 <botlish_fn_10+0x389>
    284c:	mov    edx,0x3
    2851:	mov    rsi,r13
    2854:	mov    rdi,QWORD PTR [rsp+0x78]
    2859:	call   285e <botlish_fn_10+0x386>
			285a: R_X86_64_PLT32	rt_int_add-0x4
    285e:	mov    rdx,rax
    2861:	mov    QWORD PTR [r12],rdx
    2865:	mov    rsi,r14
    2868:	mov    rdi,QWORD PTR [rsp+0x78]
    286d:	call   2872 <botlish_fn_10+0x39a>
			286e: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    2872:	test   rax,rax
    2875:	jne    28bf <botlish_fn_10+0x3e7>
    287b:	mov    rdi,QWORD PTR [rsp+0x78]
    2880:	mov    rdi,QWORD PTR [rsp+0x78]
    2885:	mov    QWORD PTR [rdi],r12
    2888:	xor    rax,rax
    288b:	mov    rbx,QWORD PTR [rsp+0x90]
    2893:	mov    r12,QWORD PTR [rsp+0x98]
    289b:	mov    r13,QWORD PTR [rsp+0xa0]
    28a3:	mov    r14,QWORD PTR [rsp+0xa8]
    28ab:	mov    r15,QWORD PTR [rsp+0xb0]
    28b3:	add    rsp,0xc0
    28ba:	mov    rsp,rbp
    28bd:	pop    rbp
    28be:	ret
    28bf:	mov    rcx,rax
    28c2:	and    rcx,rbx
    28c5:	mov    rsi,rax
    28c8:	mov    rax,rbx
    28cb:	test   rcx,0x1
    28d2:	jne    28fd <botlish_fn_10+0x425>
    28d8:	mov    rdx,rax
    28db:	mov    rdi,QWORD PTR [rsp+0x78]
    28e0:	call   28e5 <botlish_fn_10+0x40d>
			28e1: R_X86_64_PLT32	rt_int_cmp-0x4
    28e5:	mov    esi,0x2
    28ea:	test   rax,rax
    28ed:	mov    rax,rsi
    28f0:	cmove  rax,QWORD PTR [rip+0xb8]        # 29b0 <botlish_fn_10+0x4d8>
    28f8:	jmp    291a <botlish_fn_10+0x442>
    28fd:	mov    rdx,rax
    2900:	mov    eax,0x2
    2905:	cmp    rsi,rdx
    2908:	cmove  rax,QWORD PTR [rip+0xa0]        # 29b0 <botlish_fn_10+0x4d8>
    2910:	jmp    291a <botlish_fn_10+0x442>
    2915:	mov    eax,0x2
    291a:	mov    rdi,QWORD PTR [rsp+0x78]
    291f:	jmp    292e <botlish_fn_10+0x456>
    2924:	mov    eax,0x2
    2929:	mov    rdi,QWORD PTR [rsp+0x78]
    292e:	mov    rdi,QWORD PTR [rsp+0x78]
    2933:	mov    QWORD PTR [rdi],r12
    2936:	mov    rbx,QWORD PTR [rsp+0x90]
    293e:	mov    r12,QWORD PTR [rsp+0x98]
    2946:	mov    r13,QWORD PTR [rsp+0xa0]
    294e:	mov    r14,QWORD PTR [rsp+0xa8]
    2956:	mov    r15,QWORD PTR [rsp+0xb0]
    295e:	add    rsp,0xc0
    2965:	mov    rsp,rbp
    2968:	pop    rbp
    2969:	ret
    296a:	mov    QWORD PTR [rsp+0x78],rdi
    296f:	call   2974 <botlish_fn_10+0x49c>
			2970: R_X86_64_PLT32	rt_stack_overflow-0x4
    2974:	xor    rax,rax
    2977:	mov    rbx,QWORD PTR [rsp+0x90]
    297f:	mov    r12,QWORD PTR [rsp+0x98]
    2987:	mov    r13,QWORD PTR [rsp+0xa0]
    298f:	mov    r14,QWORD PTR [rsp+0xa8]
    2997:	mov    r15,QWORD PTR [rsp+0xb0]
    299f:	add    rsp,0xc0
    29a6:	mov    rsp,rbp
    29a9:	pop    rbp
    29aa:	ret
    29ab:	add    BYTE PTR [rax],al
    29ad:	add    BYTE PTR [rax],al
    29af:	add    BYTE PTR [rsi],al
    29b1:	add    BYTE PTR [rax],al
    29b3:	add    BYTE PTR [rax],al
    29b5:	add    BYTE PTR [rax],al
	...

00000000000029b8 <botlish_entry_10: <generic>>:
    29b8:	push   rbp
    29b9:	mov    rbp,rsp
    29bc:	mov    rsi,QWORD PTR [rdx]
    29bf:	call   29c4 <botlish_entry_10+0xc>
			29c0: R_X86_64_PLT32	botlish_fn_10-0x4 ; <generic>
    29c4:	mov    rsp,rbp
    29c7:	pop    rbp
    29c8:	ret

00000000000029c9 <botlish_fn_11: char_at<generic>>:
    29c9:	push   rbp
    29ca:	mov    rbp,rsp
    29cd:	sub    rsp,0x50
    29d1:	mov    QWORD PTR [rsp+0x20],rbx
    29d6:	mov    QWORD PTR [rsp+0x28],r12
    29db:	mov    QWORD PTR [rsp+0x30],r13
    29e0:	mov    QWORD PTR [rsp+0x38],r14
    29e5:	mov    QWORD PTR [rsp+0x40],r15
    29ea:	mov    rbx,QWORD PTR [rdi+0x20]
    29ee:	mov    r13,QWORD PTR [rdi+0x28]
    29f2:	lea    rax,[rsp]
    29f6:	mov    QWORD PTR [rdi+0x20],rax
    29fa:	mov    QWORD PTR [rdi+0x28],0x3
    2a02:	mov    QWORD PTR [rsp],rdx
    2a06:	mov    rax,QWORD PTR [rsi+0x20]
    2a0a:	mov    rsi,QWORD PTR [rax]
    2a0d:	mov    QWORD PTR [rsp+0x8],rsi
    2a12:	mov    r15,rsi
    2a15:	mov    QWORD PTR [rsp+0x10],0x3
    2a1e:	mov    ecx,0x1
    2a23:	test   rdx,0x1
    2a2a:	je     2a38 <botlish_fn_11+0x6f>
    2a30:	mov    r14,rdx
    2a33:	jmp    2a5b <botlish_fn_11+0x92>
    2a38:	xor    ecx,ecx
    2a3a:	test   rdx,0x7
    2a41:	je     2a4f <botlish_fn_11+0x86>
    2a47:	mov    r14,rdx
    2a4a:	jmp    2a5b <botlish_fn_11+0x92>
    2a4f:	movzx  rax,BYTE PTR [rdx]
    2a53:	mov    r14,rdx
    2a56:	cmp    al,0x1
    2a58:	sete   cl
    2a5b:	test   cl,cl
    2a5d:	jne    2a81 <botlish_fn_11+0xb8>
    2a63:	mov    rax,QWORD PTR [rdi+0x10]
    2a67:	mov    rcx,QWORD PTR [rax+0x108]
    2a6e:	xor    rdx,rdx
    2a71:	mov    rsi,r14
    2a74:	mov    r12,rdi
    2a77:	call   2a7c <botlish_fn_11+0xb3>
			2a78: R_X86_64_PLT32	rt_type_error-0x4
    2a7c:	jmp    2b34 <botlish_fn_11+0x16b>
    2a81:	mov    rsi,r14
    2a84:	mov    r12,rdi
    2a87:	test   rsi,0x1
    2a8e:	je     2aa9 <botlish_fn_11+0xe0>
    2a94:	mov    rsi,r14
    2a97:	mov    rcx,rsi
    2a9a:	add    rcx,0x2
    2a9e:	seto   al
    2aa1:	test   al,al
    2aa3:	je     2abc <botlish_fn_11+0xf3>
    2aa9:	mov    edx,0x3
    2aae:	mov    rsi,r14
    2ab1:	mov    rdi,r12
    2ab4:	call   2ab9 <botlish_fn_11+0xf0>
			2ab5: R_X86_64_PLT32	rt_int_add-0x4
    2ab9:	mov    rcx,rax
    2abc:	mov    QWORD PTR [rsp+0x10],rcx
    2ac1:	mov    edx,0x1
    2ac6:	mov    rsi,r14
    2ac9:	test   rsi,0x1
    2ad0:	jne    2af6 <botlish_fn_11+0x12d>
    2ad6:	xor    edx,edx
    2ad8:	mov    rsi,r14
    2adb:	test   rsi,0x7
    2ae2:	jne    2af6 <botlish_fn_11+0x12d>
    2ae8:	mov    rsi,r14
    2aeb:	movzx  rdi,BYTE PTR [rsi]
    2aef:	cmp    dil,0x1
    2af3:	sete   dl
    2af6:	test   dl,dl
    2af8:	jne    2b1d <botlish_fn_11+0x154>
    2afe:	mov    r11,QWORD PTR [r12+0x10]
    2b03:	mov    rcx,QWORD PTR [r11+0x110]
    2b0a:	xor    rdx,rdx
    2b0d:	mov    rsi,r14
    2b10:	mov    rdi,r12
    2b13:	call   2b18 <botlish_fn_11+0x14f>
			2b14: R_X86_64_PLT32	rt_type_error-0x4
    2b18:	jmp    2b34 <botlish_fn_11+0x16b>
    2b1d:	mov    rdx,r14
    2b20:	mov    rsi,r15
    2b23:	mov    rdi,r12
    2b26:	call   2b2b <botlish_fn_11+0x162>
			2b27: R_X86_64_PLT32	rt_substr-0x4
    2b2b:	test   rax,rax
    2b2e:	jne    2b63 <botlish_fn_11+0x19a>
    2b34:	mov    QWORD PTR [r12+0x20],rbx
    2b39:	mov    QWORD PTR [r12+0x28],r13
    2b3e:	xor    rax,rax
    2b41:	mov    rbx,QWORD PTR [rsp+0x20]
    2b46:	mov    r12,QWORD PTR [rsp+0x28]
    2b4b:	mov    r13,QWORD PTR [rsp+0x30]
    2b50:	mov    r14,QWORD PTR [rsp+0x38]
    2b55:	mov    r15,QWORD PTR [rsp+0x40]
    2b5a:	add    rsp,0x50
    2b5e:	mov    rsp,rbp
    2b61:	pop    rbp
    2b62:	ret
    2b63:	mov    QWORD PTR [r12+0x20],rbx
    2b68:	mov    QWORD PTR [r12+0x28],r13
    2b6d:	mov    rbx,QWORD PTR [rsp+0x20]
    2b72:	mov    r12,QWORD PTR [rsp+0x28]
    2b77:	mov    r13,QWORD PTR [rsp+0x30]
    2b7c:	mov    r14,QWORD PTR [rsp+0x38]
    2b81:	mov    r15,QWORD PTR [rsp+0x40]
    2b86:	add    rsp,0x50
    2b8a:	mov    rsp,rbp
    2b8d:	pop    rbp
    2b8e:	ret

0000000000002b8f <botlish_entry_11: char_at<generic>>:
    2b8f:	push   rbp
    2b90:	mov    rbp,rsp
    2b93:	mov    rdx,QWORD PTR [rdx]
    2b96:	call   2b9b <botlish_entry_11+0xc>
			2b97: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    2b9b:	mov    rsp,rbp
    2b9e:	pop    rbp
    2b9f:	ret

0000000000002ba0 <botlish_fn_12: char_at<generic>>:
    2ba0:	push   rbp
    2ba1:	mov    rbp,rsp
    2ba4:	sub    rsp,0x60
    2ba8:	mov    QWORD PTR [rsp+0x30],rbx
    2bad:	mov    QWORD PTR [rsp+0x38],r12
    2bb2:	mov    QWORD PTR [rsp+0x40],r13
    2bb7:	mov    QWORD PTR [rsp+0x48],r14
    2bbc:	mov    QWORD PTR [rsp+0x50],r15
    2bc1:	mov    QWORD PTR [rsp+0x18],rcx
    2bc6:	mov    rbx,QWORD PTR [rdi+0x20]
    2bca:	mov    r12,QWORD PTR [rdi+0x28]
    2bce:	lea    rax,[rsp]
    2bd2:	mov    QWORD PTR [rdi+0x20],rax
    2bd6:	mov    QWORD PTR [rdi+0x28],0x3
    2bde:	mov    QWORD PTR [rsp],rdx
    2be2:	mov    rax,QWORD PTR [rsi+0x20]
    2be6:	mov    rax,QWORD PTR [rax]
    2be9:	mov    QWORD PTR [rsp+0x8],rax
    2bee:	mov    QWORD PTR [rsp+0x20],rax
    2bf3:	mov    QWORD PTR [rsp+0x10],0x3
    2bfc:	mov    eax,0x1
    2c01:	test   rdx,0x1
    2c08:	je     2c16 <botlish_fn_12+0x76>
    2c0e:	mov    r15,rdx
    2c11:	jmp    2c39 <botlish_fn_12+0x99>
    2c16:	xor    eax,eax
    2c18:	test   rdx,0x7
    2c1f:	je     2c2d <botlish_fn_12+0x8d>
    2c25:	mov    r15,rdx
    2c28:	jmp    2c39 <botlish_fn_12+0x99>
    2c2d:	movzx  rax,BYTE PTR [rdx]
    2c31:	mov    r15,rdx
    2c34:	cmp    al,0x1
    2c36:	sete   al
    2c39:	test   al,al
    2c3b:	jne    2c5f <botlish_fn_12+0xbf>
    2c41:	mov    rax,QWORD PTR [rdi+0x10]
    2c45:	mov    rcx,QWORD PTR [rax+0x108]
    2c4c:	xor    rdx,rdx
    2c4f:	mov    rsi,r15
    2c52:	mov    r13,rdi
    2c55:	call   2c5a <botlish_fn_12+0xba>
			2c56: R_X86_64_PLT32	rt_type_error-0x4
    2c5a:	jmp    2d19 <botlish_fn_12+0x179>
    2c5f:	mov    rsi,r15
    2c62:	mov    r13,rdi
    2c65:	test   rsi,0x1
    2c6c:	jne    2c7a <botlish_fn_12+0xda>
    2c72:	mov    r15,rsi
    2c75:	jmp    2c8f <botlish_fn_12+0xef>
    2c7a:	mov    rax,rsi
    2c7d:	add    rax,0x2
    2c81:	mov    r15,rsi
    2c84:	seto   cl
    2c87:	test   cl,cl
    2c89:	je     2c9f <botlish_fn_12+0xff>
    2c8f:	mov    edx,0x3
    2c94:	mov    rsi,r15
    2c97:	mov    rdi,r13
    2c9a:	call   2c9f <botlish_fn_12+0xff>
			2c9b: R_X86_64_PLT32	rt_int_add-0x4
    2c9f:	mov    ecx,0x1
    2ca4:	mov    rsi,r15
    2ca7:	test   rsi,0x1
    2cae:	jne    2cd4 <botlish_fn_12+0x134>
    2cb4:	xor    ecx,ecx
    2cb6:	mov    rsi,r15
    2cb9:	test   rsi,0x7
    2cc0:	jne    2cd4 <botlish_fn_12+0x134>
    2cc6:	mov    rsi,r15
    2cc9:	movzx  rdi,BYTE PTR [rsi]
    2ccd:	cmp    dil,0x1
    2cd1:	sete   cl
    2cd4:	test   cl,cl
    2cd6:	jne    2cfa <botlish_fn_12+0x15a>
    2cdc:	mov    r11,QWORD PTR [r13+0x10]
    2ce0:	mov    rcx,QWORD PTR [r11+0x110]
    2ce7:	xor    rdx,rdx
    2cea:	mov    rsi,r15
    2ced:	mov    rdi,r13
    2cf0:	call   2cf5 <botlish_fn_12+0x155>
			2cf1: R_X86_64_PLT32	rt_type_error-0x4
    2cf5:	jmp    2d19 <botlish_fn_12+0x179>
    2cfa:	mov    r14,rax
    2cfd:	mov    rcx,r14
    2d00:	mov    rdx,r15
    2d03:	mov    rsi,QWORD PTR [rsp+0x20]
    2d08:	mov    rdi,r13
    2d0b:	call   2d10 <botlish_fn_12+0x170>
			2d0c: R_X86_64_PLT32	rt_str_region_check-0x4
    2d10:	test   rax,rax
    2d13:	jne    2d46 <botlish_fn_12+0x1a6>
    2d19:	mov    QWORD PTR [r13+0x20],rbx
    2d1d:	mov    QWORD PTR [r13+0x28],r12
    2d21:	xor    rax,rax
    2d24:	mov    rbx,QWORD PTR [rsp+0x30]
    2d29:	mov    r12,QWORD PTR [rsp+0x38]
    2d2e:	mov    r13,QWORD PTR [rsp+0x40]
    2d33:	mov    r14,QWORD PTR [rsp+0x48]
    2d38:	mov    r15,QWORD PTR [rsp+0x50]
    2d3d:	add    rsp,0x60
    2d41:	mov    rsp,rbp
    2d44:	pop    rbp
    2d45:	ret
    2d46:	mov    QWORD PTR [r13+0x20],rbx
    2d4a:	mov    QWORD PTR [r13+0x28],r12
    2d4e:	mov    rcx,QWORD PTR [rsp+0x18]
    2d53:	mov    rsi,r15
    2d56:	mov    QWORD PTR [rcx],rsi
    2d59:	mov    QWORD PTR [rcx+0x8],r14
    2d5d:	mov    rax,QWORD PTR [rsp+0x20]
    2d62:	mov    rbx,QWORD PTR [rsp+0x30]
    2d67:	mov    r12,QWORD PTR [rsp+0x38]
    2d6c:	mov    r13,QWORD PTR [rsp+0x40]
    2d71:	mov    r14,QWORD PTR [rsp+0x48]
    2d76:	mov    r15,QWORD PTR [rsp+0x50]
    2d7b:	add    rsp,0x60
    2d7f:	mov    rsp,rbp
    2d82:	pop    rbp
    2d83:	ret

0000000000002d84 <botlish_entry_12: char_at<generic>>:
    2d84:	push   rbp
    2d85:	mov    rbp,rsp
    2d88:	ud2

0000000000002d8a <botlish_fn_13: is_local_char<str>>:
    2d8a:	push   rbp
    2d8b:	mov    rbp,rsp
    2d8e:	sub    rsp,0x10
    2d92:	mov    QWORD PTR [rsp],rbx
    2d96:	mov    QWORD PTR [rsp+0x8],r12
    2d9b:	mov    rbx,rsi
    2d9e:	mov    r12,rdi
    2da1:	mov    rsi,rbx
    2da4:	mov    rdi,r12
    2da7:	call   2dac <botlish_fn_13+0x22>
			2da8: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    2dac:	test   rax,rax
    2daf:	jne    2dca <botlish_fn_13+0x40>
    2db5:	xor    rax,rax
    2db8:	mov    rbx,QWORD PTR [rsp]
    2dbc:	mov    r12,QWORD PTR [rsp+0x8]
    2dc1:	add    rsp,0x10
    2dc5:	mov    rsp,rbp
    2dc8:	pop    rbp
    2dc9:	ret
    2dca:	cmp    rax,0x6
    2dce:	je     2ec9 <botlish_fn_13+0x13f>
    2dd4:	mov    rdi,r12
    2dd7:	mov    rax,QWORD PTR [rdi+0x10]
    2ddb:	mov    rsi,QWORD PTR [rax+0x118]
    2de2:	mov    edx,0x1
    2de7:	mov    ecx,0x3
    2dec:	mov    r8,rbx
    2def:	call   2df4 <botlish_fn_13+0x6a>
			2df0: R_X86_64_PLT32	rt_str_region_eq-0x4
    2df4:	cmp    rax,0x6
    2df8:	je     2ebf <botlish_fn_13+0x135>
    2dfe:	mov    rdi,r12
    2e01:	mov    rax,QWORD PTR [rdi+0x10]
    2e05:	mov    rsi,QWORD PTR [rax+0x120]
    2e0c:	mov    edx,0x1
    2e11:	mov    ecx,0x3
    2e16:	mov    r8,rbx
    2e19:	call   2e1e <botlish_fn_13+0x94>
			2e1a: R_X86_64_PLT32	rt_str_region_eq-0x4
    2e1e:	cmp    rax,0x6
    2e22:	je     2eb5 <botlish_fn_13+0x12b>
    2e28:	mov    rdi,r12
    2e2b:	mov    rax,QWORD PTR [rdi+0x10]
    2e2f:	mov    rsi,QWORD PTR [rax+0xc0]
    2e36:	mov    edx,0x1
    2e3b:	mov    ecx,0x3
    2e40:	mov    r8,rbx
    2e43:	call   2e48 <botlish_fn_13+0xbe>
			2e44: R_X86_64_PLT32	rt_str_region_eq-0x4
    2e48:	cmp    rax,0x6
    2e4c:	je     2eab <botlish_fn_13+0x121>
    2e52:	mov    rdi,r12
    2e55:	mov    rax,QWORD PTR [rdi+0x10]
    2e59:	mov    rsi,QWORD PTR [rax+0x108]
    2e60:	mov    edx,0x1
    2e65:	mov    ecx,0x3
    2e6a:	mov    r8,rbx
    2e6d:	call   2e72 <botlish_fn_13+0xe8>
			2e6e: R_X86_64_PLT32	rt_str_region_eq-0x4
    2e72:	cmp    rax,0x6
    2e76:	je     2ea1 <botlish_fn_13+0x117>
    2e7c:	mov    rdi,r12
    2e7f:	mov    rax,QWORD PTR [rdi+0x10]
    2e83:	mov    rsi,QWORD PTR [rax+0x128]
    2e8a:	mov    edx,0x1
    2e8f:	mov    ecx,0x3
    2e94:	mov    r8,rbx
    2e97:	call   2e9c <botlish_fn_13+0x112>
			2e98: R_X86_64_PLT32	rt_str_region_eq-0x4
    2e9c:	jmp    2ece <botlish_fn_13+0x144>
    2ea1:	mov    eax,0x6
    2ea6:	jmp    2ece <botlish_fn_13+0x144>
    2eab:	mov    eax,0x6
    2eb0:	jmp    2ece <botlish_fn_13+0x144>
    2eb5:	mov    eax,0x6
    2eba:	jmp    2ece <botlish_fn_13+0x144>
    2ebf:	mov    eax,0x6
    2ec4:	jmp    2ece <botlish_fn_13+0x144>
    2ec9:	mov    eax,0x6
    2ece:	mov    rbx,QWORD PTR [rsp]
    2ed2:	mov    r12,QWORD PTR [rsp+0x8]
    2ed7:	add    rsp,0x10
    2edb:	mov    rsp,rbp
    2ede:	pop    rbp
    2edf:	ret

0000000000002ee0 <botlish_entry_13: is_local_char<str>>:
    2ee0:	push   rbp
    2ee1:	mov    rbp,rsp
    2ee4:	mov    rsi,QWORD PTR [rdx]
    2ee7:	call   2eec <botlish_entry_13+0xc>
			2ee8: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_local_char<str>
    2eec:	mov    rsp,rbp
    2eef:	pop    rbp
    2ef0:	ret

0000000000002ef1 <botlish_fn_14: is_label_char<str>>:
    2ef1:	push   rbp
    2ef2:	mov    rbp,rsp
    2ef5:	sub    rsp,0x10
    2ef9:	mov    QWORD PTR [rsp],r13
    2efd:	mov    QWORD PTR [rsp+0x8],r15
    2f02:	mov    r13,rsi
    2f05:	mov    r15,rdi
    2f08:	mov    rsi,r13
    2f0b:	mov    rdi,r15
    2f0e:	call   2f13 <botlish_fn_14+0x22>
			2f0f: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    2f13:	test   rax,rax
    2f16:	jne    2f31 <botlish_fn_14+0x40>
    2f1c:	xor    rax,rax
    2f1f:	mov    r13,QWORD PTR [rsp]
    2f23:	mov    r15,QWORD PTR [rsp+0x8]
    2f28:	add    rsp,0x10
    2f2c:	mov    rsp,rbp
    2f2f:	pop    rbp
    2f30:	ret
    2f31:	cmp    rax,0x6
    2f35:	je     2f60 <botlish_fn_14+0x6f>
    2f3b:	mov    rdi,r15
    2f3e:	mov    rax,QWORD PTR [rdi+0x10]
    2f42:	mov    rsi,QWORD PTR [rax+0x128]
    2f49:	mov    edx,0x1
    2f4e:	mov    ecx,0x3
    2f53:	mov    r8,r13
    2f56:	call   2f5b <botlish_fn_14+0x6a>
			2f57: R_X86_64_PLT32	rt_str_region_eq-0x4
    2f5b:	jmp    2f65 <botlish_fn_14+0x74>
    2f60:	mov    eax,0x6
    2f65:	mov    r13,QWORD PTR [rsp]
    2f69:	mov    r15,QWORD PTR [rsp+0x8]
    2f6e:	add    rsp,0x10
    2f72:	mov    rsp,rbp
    2f75:	pop    rbp
    2f76:	ret

0000000000002f77 <botlish_entry_14: is_label_char<str>>:
    2f77:	push   rbp
    2f78:	mov    rbp,rsp
    2f7b:	mov    rsi,QWORD PTR [rdx]
    2f7e:	call   2f83 <botlish_entry_14+0xc>
			2f7f: R_X86_64_PLT32	botlish_fn_14-0x4 ; is_label_char<str>
    2f83:	mov    rsp,rbp
    2f86:	pop    rbp
    2f87:	ret

0000000000002f88 <botlish_fn_15: scan_local<generic>>:
    2f88:	push   rbp
    2f89:	mov    rbp,rsp
    2f8c:	sub    rsp,0x20
    2f90:	mov    QWORD PTR [rsp],rbx
    2f94:	mov    QWORD PTR [rsp+0x8],r12
    2f99:	mov    QWORD PTR [rsp+0x10],r13
    2f9e:	mov    QWORD PTR [rsp+0x18],r14
    2fa3:	mov    r12,QWORD PTR [rdi]
    2fa6:	mov    rax,QWORD PTR [rdi+0x8]
    2faa:	lea    rcx,[r12+0x18]
    2faf:	cmp    rcx,rax
    2fb2:	ja     3186 <botlish_fn_15+0x1fe>
    2fb8:	lea    rax,[r12+0x18]
    2fbd:	mov    QWORD PTR [rdi],rax
    2fc0:	mov    r13,rdi
    2fc3:	mov    QWORD PTR [r12+0x10],0x0
    2fcc:	mov    QWORD PTR [r12],rdx
    2fd0:	mov    rbx,rsi
    2fd3:	mov    rsi,rdx
    2fd6:	mov    rax,QWORD PTR [rbx+0x20]
    2fda:	mov    rdx,QWORD PTR [rax]
    2fdd:	mov    ecx,0x1
    2fe2:	test   rsi,0x1
    2fe9:	jne    3007 <botlish_fn_15+0x7f>
    2fef:	xor    ecx,ecx
    2ff1:	test   rsi,0x7
    2ff8:	jne    3007 <botlish_fn_15+0x7f>
    2ffe:	movzx  rax,BYTE PTR [rsi]
    3002:	cmp    al,0x1
    3004:	sete   cl
    3007:	test   cl,cl
    3009:	jne    302d <botlish_fn_15+0xa5>
    300f:	mov    rdi,r13
    3012:	mov    rax,QWORD PTR [rdi+0x10]
    3016:	mov    rcx,QWORD PTR [rax+0xb8]
    301d:	xor    rdx,rdx
    3020:	call   3025 <botlish_fn_15+0x9d>
			3021: R_X86_64_PLT32	rt_type_error-0x4
    3025:	mov    rdi,r13
    3028:	jmp    30c4 <botlish_fn_15+0x13c>
    302d:	mov    rax,rsi
    3030:	and    rax,rdx
    3033:	mov    r14,rsi
    3036:	test   rax,0x1
    303c:	jne    3062 <botlish_fn_15+0xda>
    3042:	mov    rsi,r14
    3045:	mov    rdi,r13
    3048:	call   304d <botlish_fn_15+0xc5>
			3049: R_X86_64_PLT32	rt_int_cmp-0x4
    304d:	mov    ecx,0x2
    3052:	test   rax,rax
    3055:	cmovge rcx,QWORD PTR [rip+0x153]        # 31b0 <botlish_fn_15+0x228>
    305d:	jmp    3075 <botlish_fn_15+0xed>
    3062:	mov    ecx,0x2
    3067:	mov    rsi,r14
    306a:	cmp    rsi,rdx
    306d:	cmovge rcx,QWORD PTR [rip+0x13b]        # 31b0 <botlish_fn_15+0x228>
    3075:	cmp    rcx,0x6
    3079:	je     315e <botlish_fn_15+0x1d6>
    307f:	mov    rsi,QWORD PTR [rbx+0x20]
    3083:	mov    rsi,QWORD PTR [rsi+0x8]
    3087:	mov    QWORD PTR [r12+0x8],rsi
    308c:	mov    rdx,r14
    308f:	mov    rdi,r13
    3092:	call   3097 <botlish_fn_15+0x10f>
			3093: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    3097:	test   rax,rax
    309a:	jne    30a8 <botlish_fn_15+0x120>
    30a0:	mov    rdi,r13
    30a3:	jmp    30c4 <botlish_fn_15+0x13c>
    30a8:	mov    QWORD PTR [r12+0x8],rax
    30ad:	mov    rsi,rax
    30b0:	mov    rdi,r13
    30b3:	call   30b8 <botlish_fn_15+0x130>
			30b4: R_X86_64_PLT32	botlish_fn_13-0x4 ; is_local_char<str>
    30b8:	test   rax,rax
    30bb:	jne    30e9 <botlish_fn_15+0x161>
    30c1:	mov    rdi,r13
    30c4:	mov    rdi,r13
    30c7:	mov    QWORD PTR [rdi],r12
    30ca:	xor    rax,rax
    30cd:	mov    rbx,QWORD PTR [rsp]
    30d1:	mov    r12,QWORD PTR [rsp+0x8]
    30d6:	mov    r13,QWORD PTR [rsp+0x10]
    30db:	mov    r14,QWORD PTR [rsp+0x18]
    30e0:	add    rsp,0x20
    30e4:	mov    rsp,rbp
    30e7:	pop    rbp
    30e8:	ret
    30e9:	cmp    rax,0x6
    30ed:	je     30fe <botlish_fn_15+0x176>
    30f3:	mov    rax,r14
    30f6:	mov    rdi,r13
    30f9:	jmp    3164 <botlish_fn_15+0x1dc>
    30fe:	mov    QWORD PTR [r12+0x8],rbx
    3103:	mov    QWORD PTR [r12+0x10],0x3
    310c:	mov    rsi,r14
    310f:	test   rsi,0x1
    3116:	je     313c <botlish_fn_15+0x1b4>
    311c:	mov    rsi,r14
    311f:	mov    rcx,rsi
    3122:	add    rcx,0x2
    3126:	seto   al
    3129:	test   al,al
    312b:	jne    313c <botlish_fn_15+0x1b4>
    3131:	mov    rsi,rcx
    3134:	mov    r14,rcx
    3137:	jmp    3152 <botlish_fn_15+0x1ca>
    313c:	mov    edx,0x3
    3141:	mov    rsi,r14
    3144:	mov    rdi,r13
    3147:	call   314c <botlish_fn_15+0x1c4>
			3148: R_X86_64_PLT32	rt_int_add-0x4
    314c:	mov    rsi,rax
    314f:	mov    r14,rax
    3152:	mov    QWORD PTR [r12],rsi
    3156:	mov    rsi,r14
    3159:	jmp    2fd6 <botlish_fn_15+0x4e>
    315e:	mov    rax,r14
    3161:	mov    rdi,r13
    3164:	mov    rdi,r13
    3167:	mov    QWORD PTR [rdi],r12
    316a:	mov    rbx,QWORD PTR [rsp]
    316e:	mov    r12,QWORD PTR [rsp+0x8]
    3173:	mov    r13,QWORD PTR [rsp+0x10]
    3178:	mov    r14,QWORD PTR [rsp+0x18]
    317d:	add    rsp,0x20
    3181:	mov    rsp,rbp
    3184:	pop    rbp
    3185:	ret
    3186:	mov    r13,rdi
    3189:	call   318e <botlish_fn_15+0x206>
			318a: R_X86_64_PLT32	rt_stack_overflow-0x4
    318e:	xor    rax,rax
    3191:	mov    rbx,QWORD PTR [rsp]
    3195:	mov    r12,QWORD PTR [rsp+0x8]
    319a:	mov    r13,QWORD PTR [rsp+0x10]
    319f:	mov    r14,QWORD PTR [rsp+0x18]
    31a4:	add    rsp,0x20
    31a8:	mov    rsp,rbp
    31ab:	pop    rbp
    31ac:	ret
    31ad:	add    BYTE PTR [rax],al
    31af:	add    BYTE PTR [rsi],al
    31b1:	add    BYTE PTR [rax],al
    31b3:	add    BYTE PTR [rax],al
    31b5:	add    BYTE PTR [rax],al
	...

00000000000031b8 <botlish_entry_15: scan_local<generic>>:
    31b8:	push   rbp
    31b9:	mov    rbp,rsp
    31bc:	mov    rdx,QWORD PTR [rdx]
    31bf:	call   31c4 <botlish_entry_15+0xc>
			31c0: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_local<generic>
    31c4:	mov    rsp,rbp
    31c7:	pop    rbp
    31c8:	ret
    31c9:	add    BYTE PTR [rax],al
    31cb:	add    BYTE PTR [rax],al
    31cd:	add    BYTE PTR [rax],al
	...

00000000000031d0 <botlish_fn_16: scan_label<generic>>:
    31d0:	push   rbp
    31d1:	mov    rbp,rsp
    31d4:	sub    rsp,0x20
    31d8:	mov    QWORD PTR [rsp],rbx
    31dc:	mov    QWORD PTR [rsp+0x8],r12
    31e1:	mov    QWORD PTR [rsp+0x10],r13
    31e6:	mov    QWORD PTR [rsp+0x18],r14
    31eb:	mov    r12,QWORD PTR [rdi]
    31ee:	mov    rax,QWORD PTR [rdi+0x8]
    31f2:	lea    rcx,[r12+0x18]
    31f7:	cmp    rcx,rax
    31fa:	ja     33ce <botlish_fn_16+0x1fe>
    3200:	lea    rax,[r12+0x18]
    3205:	mov    QWORD PTR [rdi],rax
    3208:	mov    r13,rdi
    320b:	mov    QWORD PTR [r12+0x10],0x0
    3214:	mov    QWORD PTR [r12],rdx
    3218:	mov    rbx,rsi
    321b:	mov    rsi,rdx
    321e:	mov    rax,QWORD PTR [rbx+0x20]
    3222:	mov    rdx,QWORD PTR [rax]
    3225:	mov    ecx,0x1
    322a:	test   rsi,0x1
    3231:	jne    324f <botlish_fn_16+0x7f>
    3237:	xor    ecx,ecx
    3239:	test   rsi,0x7
    3240:	jne    324f <botlish_fn_16+0x7f>
    3246:	movzx  rax,BYTE PTR [rsi]
    324a:	cmp    al,0x1
    324c:	sete   cl
    324f:	test   cl,cl
    3251:	jne    3275 <botlish_fn_16+0xa5>
    3257:	mov    rdi,r13
    325a:	mov    rax,QWORD PTR [rdi+0x10]
    325e:	mov    rcx,QWORD PTR [rax+0xb8]
    3265:	xor    rdx,rdx
    3268:	call   326d <botlish_fn_16+0x9d>
			3269: R_X86_64_PLT32	rt_type_error-0x4
    326d:	mov    rdi,r13
    3270:	jmp    330c <botlish_fn_16+0x13c>
    3275:	mov    rax,rsi
    3278:	and    rax,rdx
    327b:	mov    r14,rsi
    327e:	test   rax,0x1
    3284:	jne    32aa <botlish_fn_16+0xda>
    328a:	mov    rsi,r14
    328d:	mov    rdi,r13
    3290:	call   3295 <botlish_fn_16+0xc5>
			3291: R_X86_64_PLT32	rt_int_cmp-0x4
    3295:	mov    ecx,0x2
    329a:	test   rax,rax
    329d:	cmovge rcx,QWORD PTR [rip+0x153]        # 33f8 <botlish_fn_16+0x228>
    32a5:	jmp    32bd <botlish_fn_16+0xed>
    32aa:	mov    ecx,0x2
    32af:	mov    rsi,r14
    32b2:	cmp    rsi,rdx
    32b5:	cmovge rcx,QWORD PTR [rip+0x13b]        # 33f8 <botlish_fn_16+0x228>
    32bd:	cmp    rcx,0x6
    32c1:	je     33a6 <botlish_fn_16+0x1d6>
    32c7:	mov    rsi,QWORD PTR [rbx+0x20]
    32cb:	mov    rsi,QWORD PTR [rsi+0x8]
    32cf:	mov    QWORD PTR [r12+0x8],rsi
    32d4:	mov    rdx,r14
    32d7:	mov    rdi,r13
    32da:	call   32df <botlish_fn_16+0x10f>
			32db: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    32df:	test   rax,rax
    32e2:	jne    32f0 <botlish_fn_16+0x120>
    32e8:	mov    rdi,r13
    32eb:	jmp    330c <botlish_fn_16+0x13c>
    32f0:	mov    QWORD PTR [r12+0x8],rax
    32f5:	mov    rsi,rax
    32f8:	mov    rdi,r13
    32fb:	call   3300 <botlish_fn_16+0x130>
			32fc: R_X86_64_PLT32	botlish_fn_14-0x4 ; is_label_char<str>
    3300:	test   rax,rax
    3303:	jne    3331 <botlish_fn_16+0x161>
    3309:	mov    rdi,r13
    330c:	mov    rdi,r13
    330f:	mov    QWORD PTR [rdi],r12
    3312:	xor    rax,rax
    3315:	mov    rbx,QWORD PTR [rsp]
    3319:	mov    r12,QWORD PTR [rsp+0x8]
    331e:	mov    r13,QWORD PTR [rsp+0x10]
    3323:	mov    r14,QWORD PTR [rsp+0x18]
    3328:	add    rsp,0x20
    332c:	mov    rsp,rbp
    332f:	pop    rbp
    3330:	ret
    3331:	cmp    rax,0x6
    3335:	je     3346 <botlish_fn_16+0x176>
    333b:	mov    rax,r14
    333e:	mov    rdi,r13
    3341:	jmp    33ac <botlish_fn_16+0x1dc>
    3346:	mov    QWORD PTR [r12+0x8],rbx
    334b:	mov    QWORD PTR [r12+0x10],0x3
    3354:	mov    rsi,r14
    3357:	test   rsi,0x1
    335e:	je     3384 <botlish_fn_16+0x1b4>
    3364:	mov    rsi,r14
    3367:	mov    rcx,rsi
    336a:	add    rcx,0x2
    336e:	seto   al
    3371:	test   al,al
    3373:	jne    3384 <botlish_fn_16+0x1b4>
    3379:	mov    rsi,rcx
    337c:	mov    r14,rcx
    337f:	jmp    339a <botlish_fn_16+0x1ca>
    3384:	mov    edx,0x3
    3389:	mov    rsi,r14
    338c:	mov    rdi,r13
    338f:	call   3394 <botlish_fn_16+0x1c4>
			3390: R_X86_64_PLT32	rt_int_add-0x4
    3394:	mov    rsi,rax
    3397:	mov    r14,rax
    339a:	mov    QWORD PTR [r12],rsi
    339e:	mov    rsi,r14
    33a1:	jmp    321e <botlish_fn_16+0x4e>
    33a6:	mov    rax,r14
    33a9:	mov    rdi,r13
    33ac:	mov    rdi,r13
    33af:	mov    QWORD PTR [rdi],r12
    33b2:	mov    rbx,QWORD PTR [rsp]
    33b6:	mov    r12,QWORD PTR [rsp+0x8]
    33bb:	mov    r13,QWORD PTR [rsp+0x10]
    33c0:	mov    r14,QWORD PTR [rsp+0x18]
    33c5:	add    rsp,0x20
    33c9:	mov    rsp,rbp
    33cc:	pop    rbp
    33cd:	ret
    33ce:	mov    r13,rdi
    33d1:	call   33d6 <botlish_fn_16+0x206>
			33d2: R_X86_64_PLT32	rt_stack_overflow-0x4
    33d6:	xor    rax,rax
    33d9:	mov    rbx,QWORD PTR [rsp]
    33dd:	mov    r12,QWORD PTR [rsp+0x8]
    33e2:	mov    r13,QWORD PTR [rsp+0x10]
    33e7:	mov    r14,QWORD PTR [rsp+0x18]
    33ec:	add    rsp,0x20
    33f0:	mov    rsp,rbp
    33f3:	pop    rbp
    33f4:	ret
    33f5:	add    BYTE PTR [rax],al
    33f7:	add    BYTE PTR [rsi],al
    33f9:	add    BYTE PTR [rax],al
    33fb:	add    BYTE PTR [rax],al
    33fd:	add    BYTE PTR [rax],al
	...

0000000000003400 <botlish_entry_16: scan_label<generic>>:
    3400:	push   rbp
    3401:	mov    rbp,rsp
    3404:	mov    rdx,QWORD PTR [rdx]
    3407:	call   340c <botlish_entry_16+0xc>
			3408: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_label<generic>
    340c:	mov    rsp,rbp
    340f:	pop    rbp
    3410:	ret
    3411:	add    BYTE PTR [rax],al
    3413:	add    BYTE PTR [rax],al
    3415:	add    BYTE PTR [rax],al
	...

0000000000003418 <botlish_fn_17: scan_alpha<generic>>:
    3418:	push   rbp
    3419:	mov    rbp,rsp
    341c:	sub    rsp,0x20
    3420:	mov    QWORD PTR [rsp],rbx
    3424:	mov    QWORD PTR [rsp+0x8],r12
    3429:	mov    QWORD PTR [rsp+0x10],r13
    342e:	mov    QWORD PTR [rsp+0x18],r14
    3433:	mov    r12,QWORD PTR [rdi]
    3436:	mov    rax,QWORD PTR [rdi+0x8]
    343a:	lea    rcx,[r12+0x18]
    343f:	cmp    rcx,rax
    3442:	ja     3611 <botlish_fn_17+0x1f9>
    3448:	lea    rax,[r12+0x18]
    344d:	mov    QWORD PTR [rdi],rax
    3450:	mov    r13,rdi
    3453:	mov    QWORD PTR [r12+0x10],0x0
    345c:	mov    QWORD PTR [r12],rdx
    3460:	mov    rbx,rsi
    3463:	mov    rsi,rdx
    3466:	mov    rax,QWORD PTR [rbx+0x20]
    346a:	mov    rdx,QWORD PTR [rax]
    346d:	mov    ecx,0x1
    3472:	test   rsi,0x1
    3479:	jne    3497 <botlish_fn_17+0x7f>
    347f:	xor    ecx,ecx
    3481:	test   rsi,0x7
    3488:	jne    3497 <botlish_fn_17+0x7f>
    348e:	movzx  rax,BYTE PTR [rsi]
    3492:	cmp    al,0x1
    3494:	sete   cl
    3497:	test   cl,cl
    3499:	jne    34bd <botlish_fn_17+0xa5>
    349f:	mov    rdi,r13
    34a2:	mov    rax,QWORD PTR [rdi+0x10]
    34a6:	mov    rcx,QWORD PTR [rax+0xb8]
    34ad:	xor    rdx,rdx
    34b0:	call   34b5 <botlish_fn_17+0x9d>
			34b1: R_X86_64_PLT32	rt_type_error-0x4
    34b5:	mov    rdi,r13
    34b8:	jmp    354f <botlish_fn_17+0x137>
    34bd:	mov    rax,rsi
    34c0:	and    rax,rdx
    34c3:	mov    r14,rsi
    34c6:	test   rax,0x1
    34cc:	jne    34f2 <botlish_fn_17+0xda>
    34d2:	mov    rsi,r14
    34d5:	mov    rdi,r13
    34d8:	call   34dd <botlish_fn_17+0xc5>
			34d9: R_X86_64_PLT32	rt_int_cmp-0x4
    34dd:	mov    ecx,0x2
    34e2:	test   rax,rax
    34e5:	cmovge rcx,QWORD PTR [rip+0x14b]        # 3638 <botlish_fn_17+0x220>
    34ed:	jmp    3505 <botlish_fn_17+0xed>
    34f2:	mov    ecx,0x2
    34f7:	mov    rsi,r14
    34fa:	cmp    rsi,rdx
    34fd:	cmovge rcx,QWORD PTR [rip+0x133]        # 3638 <botlish_fn_17+0x220>
    3505:	cmp    rcx,0x6
    3509:	je     35e9 <botlish_fn_17+0x1d1>
    350f:	mov    rsi,QWORD PTR [rbx+0x20]
    3513:	mov    rsi,QWORD PTR [rsi+0x8]
    3517:	mov    QWORD PTR [r12+0x8],rsi
    351c:	mov    rdx,r14
    351f:	mov    rdi,r13
    3522:	call   3527 <botlish_fn_17+0x10f>
			3523: R_X86_64_PLT32	botlish_fn_11-0x4 ; char_at<generic>
    3527:	test   rax,rax
    352a:	mov    rsi,rax
    352d:	jne    353b <botlish_fn_17+0x123>
    3533:	mov    rdi,r13
    3536:	jmp    354f <botlish_fn_17+0x137>
    353b:	mov    rdi,r13
    353e:	call   3543 <botlish_fn_17+0x12b>
			353f: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    3543:	test   rax,rax
    3546:	jne    3574 <botlish_fn_17+0x15c>
    354c:	mov    rdi,r13
    354f:	mov    rdi,r13
    3552:	mov    QWORD PTR [rdi],r12
    3555:	xor    rax,rax
    3558:	mov    rbx,QWORD PTR [rsp]
    355c:	mov    r12,QWORD PTR [rsp+0x8]
    3561:	mov    r13,QWORD PTR [rsp+0x10]
    3566:	mov    r14,QWORD PTR [rsp+0x18]
    356b:	add    rsp,0x20
    356f:	mov    rsp,rbp
    3572:	pop    rbp
    3573:	ret
    3574:	cmp    rax,0x6
    3578:	je     3589 <botlish_fn_17+0x171>
    357e:	mov    rax,r14
    3581:	mov    rdi,r13
    3584:	jmp    35ef <botlish_fn_17+0x1d7>
    3589:	mov    QWORD PTR [r12+0x8],rbx
    358e:	mov    QWORD PTR [r12+0x10],0x3
    3597:	mov    rsi,r14
    359a:	test   rsi,0x1
    35a1:	je     35c7 <botlish_fn_17+0x1af>
    35a7:	mov    rsi,r14
    35aa:	mov    rcx,rsi
    35ad:	add    rcx,0x2
    35b1:	seto   al
    35b4:	test   al,al
    35b6:	jne    35c7 <botlish_fn_17+0x1af>
    35bc:	mov    rsi,rcx
    35bf:	mov    r14,rcx
    35c2:	jmp    35dd <botlish_fn_17+0x1c5>
    35c7:	mov    edx,0x3
    35cc:	mov    rsi,r14
    35cf:	mov    rdi,r13
    35d2:	call   35d7 <botlish_fn_17+0x1bf>
			35d3: R_X86_64_PLT32	rt_int_add-0x4
    35d7:	mov    rsi,rax
    35da:	mov    r14,rax
    35dd:	mov    QWORD PTR [r12],rsi
    35e1:	mov    rsi,r14
    35e4:	jmp    3466 <botlish_fn_17+0x4e>
    35e9:	mov    rax,r14
    35ec:	mov    rdi,r13
    35ef:	mov    rdi,r13
    35f2:	mov    QWORD PTR [rdi],r12
    35f5:	mov    rbx,QWORD PTR [rsp]
    35f9:	mov    r12,QWORD PTR [rsp+0x8]
    35fe:	mov    r13,QWORD PTR [rsp+0x10]
    3603:	mov    r14,QWORD PTR [rsp+0x18]
    3608:	add    rsp,0x20
    360c:	mov    rsp,rbp
    360f:	pop    rbp
    3610:	ret
    3611:	mov    r13,rdi
    3614:	call   3619 <botlish_fn_17+0x201>
			3615: R_X86_64_PLT32	rt_stack_overflow-0x4
    3619:	xor    rax,rax
    361c:	mov    rbx,QWORD PTR [rsp]
    3620:	mov    r12,QWORD PTR [rsp+0x8]
    3625:	mov    r13,QWORD PTR [rsp+0x10]
    362a:	mov    r14,QWORD PTR [rsp+0x18]
    362f:	add    rsp,0x20
    3633:	mov    rsp,rbp
    3636:	pop    rbp
    3637:	ret
    3638:	(bad)
    3639:	add    BYTE PTR [rax],al
    363b:	add    BYTE PTR [rax],al
    363d:	add    BYTE PTR [rax],al
	...

0000000000003640 <botlish_entry_17: scan_alpha<generic>>:
    3640:	push   rbp
    3641:	mov    rbp,rsp
    3644:	mov    rdx,QWORD PTR [rdx]
    3647:	call   364c <botlish_entry_17+0xc>
			3648: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_alpha<generic>
    364c:	mov    rsp,rbp
    364f:	pop    rbp
    3650:	ret
    3651:	add    BYTE PTR [rax],al
    3653:	add    BYTE PTR [rax],al
    3655:	add    BYTE PTR [rax],al
	...

0000000000003658 <botlish_fn_18: tld_ok<generic>>:
    3658:	push   rbp
    3659:	mov    rbp,rsp
    365c:	sub    rsp,0x30
    3660:	mov    QWORD PTR [rsp],rbx
    3664:	mov    QWORD PTR [rsp+0x8],r12
    3669:	mov    QWORD PTR [rsp+0x10],r13
    366e:	mov    QWORD PTR [rsp+0x18],r14
    3673:	mov    QWORD PTR [rsp+0x20],r15
    3678:	mov    rbx,QWORD PTR [rdi]
    367b:	mov    rax,QWORD PTR [rdi+0x8]
    367f:	lea    rcx,[rbx+0x10]
    3683:	cmp    rcx,rax
    3686:	ja     388b <botlish_fn_18+0x233>
    368c:	lea    rax,[rbx+0x10]
    3690:	mov    QWORD PTR [rdi],rax
    3693:	mov    r13,rdi
    3696:	mov    QWORD PTR [rbx],rdx
    3699:	mov    r8,rdx
    369c:	mov    rax,QWORD PTR [rsi+0x20]
    36a0:	mov    r15,rsi
    36a3:	mov    rsi,QWORD PTR [rax]
    36a6:	mov    QWORD PTR [rbx+0x8],rsi
    36aa:	mov    r12,r8
    36ad:	mov    rdx,r12
    36b0:	mov    rdi,r13
    36b3:	call   36b8 <botlish_fn_18+0x60>
			36b4: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_alpha<generic>
    36b8:	mov    rcx,rax
    36bb:	mov    r14,rax
    36be:	test   rax,rcx
    36c1:	jne    36cf <botlish_fn_18+0x77>
    36c7:	mov    rdi,r13
    36ca:	jmp    37a7 <botlish_fn_18+0x14f>
    36cf:	mov    rax,r14
    36d2:	mov    QWORD PTR [rbx+0x8],rax
    36d6:	mov    rsi,r15
    36d9:	mov    rax,QWORD PTR [rsi+0x20]
    36dd:	mov    rdx,QWORD PTR [rax+0x8]
    36e1:	mov    rax,r14
    36e4:	and    rax,rdx
    36e7:	test   rax,0x1
    36ed:	jne    3716 <botlish_fn_18+0xbe>
    36f3:	mov    rsi,r14
    36f6:	mov    rdi,r13
    36f9:	call   36fe <botlish_fn_18+0xa6>
			36fa: R_X86_64_PLT32	rt_int_cmp-0x4
    36fe:	mov    ecx,0x2
    3703:	test   rax,rax
    3706:	cmove  rcx,QWORD PTR [rip+0x1aa]        # 38b8 <botlish_fn_18+0x260>
    370e:	mov    rax,r14
    3711:	jmp    3729 <botlish_fn_18+0xd1>
    3716:	mov    ecx,0x2
    371b:	mov    rax,r14
    371e:	cmp    rax,rdx
    3721:	cmove  rcx,QWORD PTR [rip+0x18f]        # 38b8 <botlish_fn_18+0x260>
    3729:	cmp    rcx,0x6
    372d:	je     3743 <botlish_fn_18+0xeb>
    3733:	mov    ecx,0x2
    3738:	mov    rax,rcx
    373b:	mov    rdi,r13
    373e:	jmp    3864 <botlish_fn_18+0x20c>
    3743:	mov    ecx,0x1
    3748:	test   r12,0x1
    374f:	je     375d <botlish_fn_18+0x105>
    3755:	mov    r8,r12
    3758:	jmp    3783 <botlish_fn_18+0x12b>
    375d:	xor    ecx,ecx
    375f:	test   r12,0x7
    3766:	je     3774 <botlish_fn_18+0x11c>
    376c:	mov    r8,r12
    376f:	jmp    3783 <botlish_fn_18+0x12b>
    3774:	movzx  rcx,BYTE PTR [r12]
    3779:	mov    r8,r12
    377c:	rex cmp cl,0x1
    3780:	sete   cl
    3783:	test   cl,cl
    3785:	jne    37d1 <botlish_fn_18+0x179>
    378b:	mov    rdi,r13
    378e:	mov    rax,QWORD PTR [rdi+0x10]
    3792:	mov    rcx,QWORD PTR [rax+0x128]
    3799:	xor    rdx,rdx
    379c:	mov    rsi,r8
    379f:	call   37a4 <botlish_fn_18+0x14c>
			37a0: R_X86_64_PLT32	rt_type_error-0x4
    37a4:	mov    rdi,r13
    37a7:	mov    rdi,r13
    37aa:	mov    QWORD PTR [rdi],rbx
    37ad:	xor    rax,rax
    37b0:	mov    rbx,QWORD PTR [rsp]
    37b4:	mov    r12,QWORD PTR [rsp+0x8]
    37b9:	mov    r13,QWORD PTR [rsp+0x10]
    37be:	mov    r14,QWORD PTR [rsp+0x18]
    37c3:	mov    r15,QWORD PTR [rsp+0x20]
    37c8:	add    rsp,0x30
    37cc:	mov    rsp,rbp
    37cf:	pop    rbp
    37d0:	ret
    37d1:	mov    r12,r8
    37d4:	mov    rcx,rax
    37d7:	and    rcx,r12
    37da:	test   rcx,0x1
    37e1:	jne    37f2 <botlish_fn_18+0x19a>
    37e7:	mov    rdx,r8
    37ea:	mov    rsi,rax
    37ed:	jmp    3813 <botlish_fn_18+0x1bb>
    37f2:	mov    r12,r8
    37f5:	mov    rcx,rax
    37f8:	sub    rcx,r12
    37fb:	mov    r14,rax
    37fe:	seto   al
    3801:	lea    rsi,[rcx+0x1]
    3805:	test   al,al
    3807:	je     381e <botlish_fn_18+0x1c6>
    380d:	mov    rdx,r8
    3810:	mov    rsi,r14
    3813:	mov    rdi,r13
    3816:	call   381b <botlish_fn_18+0x1c3>
			3817: R_X86_64_PLT32	rt_int_sub-0x4
    381b:	mov    rsi,rax
    381e:	test   rsi,0x1
    3825:	jne    3850 <botlish_fn_18+0x1f8>
    382b:	mov    edx,0x5
    3830:	mov    rdi,r13
    3833:	call   3838 <botlish_fn_18+0x1e0>
			3834: R_X86_64_PLT32	rt_int_cmp-0x4
    3838:	mov    ecx,0x2
    383d:	test   rax,rax
    3840:	mov    rax,rcx
    3843:	cmovge rax,QWORD PTR [rip+0x6d]        # 38b8 <botlish_fn_18+0x260>
    384b:	jmp    3861 <botlish_fn_18+0x209>
    3850:	mov    eax,0x2
    3855:	cmp    rsi,0x5
    3859:	cmovge rax,QWORD PTR [rip+0x57]        # 38b8 <botlish_fn_18+0x260>
    3861:	mov    rdi,r13
    3864:	mov    rdi,r13
    3867:	mov    QWORD PTR [rdi],rbx
    386a:	mov    rbx,QWORD PTR [rsp]
    386e:	mov    r12,QWORD PTR [rsp+0x8]
    3873:	mov    r13,QWORD PTR [rsp+0x10]
    3878:	mov    r14,QWORD PTR [rsp+0x18]
    387d:	mov    r15,QWORD PTR [rsp+0x20]
    3882:	add    rsp,0x30
    3886:	mov    rsp,rbp
    3889:	pop    rbp
    388a:	ret
    388b:	mov    r13,rdi
    388e:	call   3893 <botlish_fn_18+0x23b>
			388f: R_X86_64_PLT32	rt_stack_overflow-0x4
    3893:	xor    rax,rax
    3896:	mov    rbx,QWORD PTR [rsp]
    389a:	mov    r12,QWORD PTR [rsp+0x8]
    389f:	mov    r13,QWORD PTR [rsp+0x10]
    38a4:	mov    r14,QWORD PTR [rsp+0x18]
    38a9:	mov    r15,QWORD PTR [rsp+0x20]
    38ae:	add    rsp,0x30
    38b2:	mov    rsp,rbp
    38b5:	pop    rbp
    38b6:	ret
    38b7:	add    BYTE PTR [rsi],al
    38b9:	add    BYTE PTR [rax],al
    38bb:	add    BYTE PTR [rax],al
    38bd:	add    BYTE PTR [rax],al
	...

00000000000038c0 <botlish_entry_18: tld_ok<generic>>:
    38c0:	push   rbp
    38c1:	mov    rbp,rsp
    38c4:	mov    rdx,QWORD PTR [rdx]
    38c7:	call   38cc <botlish_entry_18+0xc>
			38c8: R_X86_64_PLT32	botlish_fn_18-0x4 ; tld_ok<generic>
    38cc:	mov    rsp,rbp
    38cf:	pop    rbp
    38d0:	ret
    38d1:	add    BYTE PTR [rax],al
    38d3:	add    BYTE PTR [rax],al
    38d5:	add    BYTE PTR [rax],al
	...

00000000000038d8 <botlish_fn_19: domain_loop<generic>>:
    38d8:	push   rbp
    38d9:	mov    rbp,rsp
    38dc:	sub    rsp,0x50
    38e0:	mov    QWORD PTR [rsp+0x20],rbx
    38e5:	mov    QWORD PTR [rsp+0x28],r12
    38ea:	mov    QWORD PTR [rsp+0x30],r13
    38ef:	mov    QWORD PTR [rsp+0x38],r14
    38f4:	mov    QWORD PTR [rsp+0x40],r15
    38f9:	mov    r13,QWORD PTR [rdi]
    38fc:	mov    rax,QWORD PTR [rdi+0x8]
    3900:	lea    rcx,[r13+0x10]
    3904:	cmp    rcx,rax
    3907:	ja     3b76 <botlish_fn_19+0x29e>
    390d:	lea    rax,[r13+0x10]
    3911:	mov    QWORD PTR [rdi],rax
    3914:	mov    r15,rdi
    3917:	mov    QWORD PTR [r13+0x0],rdx
    391b:	mov    QWORD PTR [rsp+0x10],rdx
    3920:	lea    rbx,[rsp]
    3924:	mov    r12,rsi
    3927:	mov    rax,QWORD PTR [r12+0x20]
    392c:	mov    rsi,QWORD PTR [rax]
    392f:	mov    QWORD PTR [r13+0x8],rsi
    3933:	mov    rdx,QWORD PTR [rsp+0x10]
    3938:	mov    rdi,r15
    393b:	call   3940 <botlish_fn_19+0x68>
			393c: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_label<generic>
    3940:	mov    rcx,rax
    3943:	mov    r14,rax
    3946:	test   rax,rcx
    3949:	jne    3957 <botlish_fn_19+0x7f>
    394f:	mov    rdi,r15
    3952:	jmp    3ae4 <botlish_fn_19+0x20c>
    3957:	mov    rax,r14
    395a:	mov    QWORD PTR [r13+0x0],rax
    395e:	mov    rdx,QWORD PTR [rsp+0x10]
    3963:	mov    rsi,rax
    3966:	and    rsi,rdx
    3969:	test   rsi,0x1
    3970:	jne    3997 <botlish_fn_19+0xbf>
    3976:	mov    rdx,QWORD PTR [rsp+0x10]
    397b:	mov    rsi,r14
    397e:	mov    rdi,r15
    3981:	call   3986 <botlish_fn_19+0xae>
			3982: R_X86_64_PLT32	rt_value_eq-0x4
    3986:	test   rax,rax
    3989:	jne    39ac <botlish_fn_19+0xd4>
    398f:	mov    rdi,r15
    3992:	jmp    3ae4 <botlish_fn_19+0x20c>
    3997:	mov    eax,0x2
    399c:	mov    rdx,QWORD PTR [rsp+0x10]
    39a1:	cmp    r14,rdx
    39a4:	cmove  rax,QWORD PTR [rip+0x1fc]        # 3ba8 <botlish_fn_19+0x2d0>
    39ac:	cmp    rax,0x6
    39b0:	je     3b44 <botlish_fn_19+0x26c>
    39b6:	mov    rax,QWORD PTR [r12+0x20]
    39bb:	mov    rdx,QWORD PTR [rax+0x8]
    39bf:	mov    rax,r14
    39c2:	and    rax,rdx
    39c5:	test   rax,0x1
    39cb:	jne    39f1 <botlish_fn_19+0x119>
    39d1:	mov    rsi,r14
    39d4:	mov    rdi,r15
    39d7:	call   39dc <botlish_fn_19+0x104>
			39d8: R_X86_64_PLT32	rt_int_cmp-0x4
    39dc:	mov    ecx,0x2
    39e1:	test   rax,rax
    39e4:	cmovge rcx,QWORD PTR [rip+0x1bc]        # 3ba8 <botlish_fn_19+0x2d0>
    39ec:	jmp    3a01 <botlish_fn_19+0x129>
    39f1:	mov    ecx,0x2
    39f6:	cmp    r14,rdx
    39f9:	cmovge rcx,QWORD PTR [rip+0x1a7]        # 3ba8 <botlish_fn_19+0x2d0>
    3a01:	cmp    rcx,0x6
    3a05:	je     3b35 <botlish_fn_19+0x25d>
    3a0b:	mov    rax,QWORD PTR [r12+0x20]
    3a10:	mov    rsi,QWORD PTR [rax+0x10]
    3a14:	mov    QWORD PTR [r13+0x8],rsi
    3a18:	mov    rcx,rbx
    3a1b:	mov    rdx,r14
    3a1e:	mov    rdi,r15
    3a21:	call   3a26 <botlish_fn_19+0x14e>
			3a22: R_X86_64_PLT32	botlish_fn_12-0x4 ; char_at<generic>
    3a26:	test   rax,rax
    3a29:	mov    rsi,rax
    3a2c:	jne    3a3a <botlish_fn_19+0x162>
    3a32:	mov    rdi,r15
    3a35:	jmp    3ae4 <botlish_fn_19+0x20c>
    3a3a:	mov    rdx,QWORD PTR [rsp]
    3a3e:	mov    rcx,QWORD PTR [rsp+0x8]
    3a43:	mov    rdi,r15
    3a46:	mov    rax,QWORD PTR [rdi+0x10]
    3a4a:	mov    r8,QWORD PTR [rax+0x118]
    3a51:	call   3a56 <botlish_fn_19+0x17e>
			3a52: R_X86_64_PLT32	rt_str_region_eq-0x4
    3a56:	cmp    rax,0x6
    3a5a:	je     3a6c <botlish_fn_19+0x194>
    3a60:	mov    rax,0xffffffffffffffff
    3a67:	jmp    3b3c <botlish_fn_19+0x264>
    3a6c:	mov    QWORD PTR [r13+0x8],0x3
    3a74:	test   r14,0x1
    3a7b:	je     3aa2 <botlish_fn_19+0x1ca>
    3a81:	mov    rdx,r14
    3a84:	add    rdx,0x2
    3a88:	mov    QWORD PTR [rsp+0x10],rdx
    3a8d:	seto   al
    3a90:	test   al,al
    3a92:	jne    3aa2 <botlish_fn_19+0x1ca>
    3a98:	mov    rdx,QWORD PTR [rsp+0x10]
    3a9d:	jmp    3aba <botlish_fn_19+0x1e2>
    3aa2:	mov    edx,0x3
    3aa7:	mov    rsi,r14
    3aaa:	mov    rdi,r15
    3aad:	call   3ab2 <botlish_fn_19+0x1da>
			3aae: R_X86_64_PLT32	rt_int_add-0x4
    3ab2:	mov    rdx,rax
    3ab5:	mov    QWORD PTR [rsp+0x10],rax
    3aba:	mov    QWORD PTR [r13+0x0],rdx
    3abe:	mov    rax,QWORD PTR [r12+0x20]
    3ac3:	mov    rsi,QWORD PTR [rax+0x18]
    3ac7:	mov    QWORD PTR [r13+0x8],rsi
    3acb:	mov    rdx,QWORD PTR [rsp+0x10]
    3ad0:	mov    rdi,r15
    3ad3:	call   3ad8 <botlish_fn_19+0x200>
			3ad4: R_X86_64_PLT32	botlish_fn_18-0x4 ; tld_ok<generic>
    3ad8:	test   rax,rax
    3adb:	jne    3b0f <botlish_fn_19+0x237>
    3ae1:	mov    rdi,r15
    3ae4:	mov    rdi,r15
    3ae7:	mov    QWORD PTR [rdi],r13
    3aea:	xor    rax,rax
    3aed:	mov    rbx,QWORD PTR [rsp+0x20]
    3af2:	mov    r12,QWORD PTR [rsp+0x28]
    3af7:	mov    r13,QWORD PTR [rsp+0x30]
    3afc:	mov    r14,QWORD PTR [rsp+0x38]
    3b01:	mov    r15,QWORD PTR [rsp+0x40]
    3b06:	add    rsp,0x50
    3b0a:	mov    rsp,rbp
    3b0d:	pop    rbp
    3b0e:	ret
    3b0f:	cmp    rax,0x6
    3b13:	je     3b27 <botlish_fn_19+0x24f>
    3b19:	mov    rdx,QWORD PTR [rsp+0x10]
    3b1e:	mov    QWORD PTR [r13+0x0],rdx
    3b22:	jmp    3927 <botlish_fn_19+0x4f>
    3b27:	mov    rax,QWORD PTR [r12+0x20]
    3b2c:	mov    rax,QWORD PTR [rax+0x8]
    3b30:	jmp    3b3c <botlish_fn_19+0x264>
    3b35:	mov    rax,0xffffffffffffffff
    3b3c:	mov    rdi,r15
    3b3f:	jmp    3b4e <botlish_fn_19+0x276>
    3b44:	mov    rax,0xffffffffffffffff
    3b4b:	mov    rdi,r15
    3b4e:	mov    rdi,r15
    3b51:	mov    QWORD PTR [rdi],r13
    3b54:	mov    rbx,QWORD PTR [rsp+0x20]
    3b59:	mov    r12,QWORD PTR [rsp+0x28]
    3b5e:	mov    r13,QWORD PTR [rsp+0x30]
    3b63:	mov    r14,QWORD PTR [rsp+0x38]
    3b68:	mov    r15,QWORD PTR [rsp+0x40]
    3b6d:	add    rsp,0x50
    3b71:	mov    rsp,rbp
    3b74:	pop    rbp
    3b75:	ret
    3b76:	mov    r15,rdi
    3b79:	call   3b7e <botlish_fn_19+0x2a6>
			3b7a: R_X86_64_PLT32	rt_stack_overflow-0x4
    3b7e:	xor    rax,rax
    3b81:	mov    rbx,QWORD PTR [rsp+0x20]
    3b86:	mov    r12,QWORD PTR [rsp+0x28]
    3b8b:	mov    r13,QWORD PTR [rsp+0x30]
    3b90:	mov    r14,QWORD PTR [rsp+0x38]
    3b95:	mov    r15,QWORD PTR [rsp+0x40]
    3b9a:	add    rsp,0x50
    3b9e:	mov    rsp,rbp
    3ba1:	pop    rbp
    3ba2:	ret
    3ba3:	add    BYTE PTR [rax],al
    3ba5:	add    BYTE PTR [rax],al
    3ba7:	add    BYTE PTR [rsi],al
    3ba9:	add    BYTE PTR [rax],al
    3bab:	add    BYTE PTR [rax],al
    3bad:	add    BYTE PTR [rax],al
	...

0000000000003bb0 <botlish_entry_19: domain_loop<generic>>:
    3bb0:	push   rbp
    3bb1:	mov    rbp,rsp
    3bb4:	mov    rdx,QWORD PTR [rdx]
    3bb7:	call   3bbc <botlish_entry_19+0xc>
			3bb8: R_X86_64_PLT32	botlish_fn_19-0x4 ; domain_loop<generic>
    3bbc:	mov    rsp,rbp
    3bbf:	pop    rbp
    3bc0:	ret
    3bc1:	add    BYTE PTR [rax],al
    3bc3:	add    BYTE PTR [rax],al
    3bc5:	add    BYTE PTR [rax],al
	...

0000000000003bc8 <botlish_fn_20: <str>>:
    3bc8:	push   rbp
    3bc9:	mov    rbp,rsp
    3bcc:	sub    rsp,0xc0
    3bd3:	mov    QWORD PTR [rsp+0x90],rbx
    3bdb:	mov    QWORD PTR [rsp+0x98],r12
    3be3:	mov    QWORD PTR [rsp+0xa0],r13
    3beb:	mov    QWORD PTR [rsp+0xa8],r14
    3bf3:	mov    QWORD PTR [rsp+0xb0],r15
    3bfb:	mov    r12,QWORD PTR [rdi]
    3bfe:	mov    rax,QWORD PTR [rdi+0x8]
    3c02:	lea    rcx,[r12+0x28]
    3c07:	cmp    rcx,rax
    3c0a:	ja     401c <botlish_fn_20+0x454>
    3c10:	lea    rax,[r12+0x28]
    3c15:	mov    QWORD PTR [rdi],rax
    3c18:	mov    QWORD PTR [rsp+0x78],rdi
    3c1d:	mov    QWORD PTR [r12+0x10],0x0
    3c26:	mov    QWORD PTR [r12+0x18],0x0
    3c2f:	mov    QWORD PTR [r12+0x20],0x0
    3c38:	mov    QWORD PTR [r12],rsi
    3c3c:	mov    r13,rsi
    3c3f:	mov    rsi,r13
    3c42:	mov    rdi,QWORD PTR [rsp+0x78]
    3c47:	call   3c4c <botlish_fn_20+0x84>
			3c48: R_X86_64_PLT32	rt_str_len-0x4
    3c4c:	mov    rbx,rax
    3c4f:	mov    QWORD PTR [r12+0x8],rbx
    3c54:	lea    r8,[rsp]
    3c58:	mov    QWORD PTR [rsp],r13
    3c5c:	mov    esi,0x16
    3c61:	mov    rdx,QWORD PTR [rip+0x0]        # 3c68 <botlish_fn_20+0xa0>
			3c64: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; char_at<generic>
    3c68:	mov    r13d,0x1
    3c6e:	mov    rcx,r13
    3c71:	mov    rdi,QWORD PTR [rsp+0x78]
    3c76:	call   3c7b <botlish_fn_20+0xb3>
			3c77: R_X86_64_PLT32	rt_closure_new-0x4
    3c7b:	mov    r14,rax
    3c7e:	mov    QWORD PTR [r12],rax
    3c82:	lea    r8,[rsp+0x8]
    3c87:	mov    QWORD PTR [rsp+0x8],rbx
    3c8c:	mov    QWORD PTR [rsp+0x10],rax
    3c91:	mov    esi,0x1a
    3c96:	mov    rdx,QWORD PTR [rip+0x0]        # 3c9d <botlish_fn_20+0xd5>
			3c99: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; scan_local<generic>
    3c9d:	mov    r15d,0x2
    3ca3:	mov    rcx,r15
    3ca6:	mov    rdi,QWORD PTR [rsp+0x78]
    3cab:	call   3cb0 <botlish_fn_20+0xe8>
			3cac: R_X86_64_PLT32	rt_closure_new-0x4
    3cb0:	mov    rcx,rax
    3cb3:	mov    QWORD PTR [rsp+0x88],rax
    3cbb:	mov    QWORD PTR [r12+0x10],rcx
    3cc0:	lea    r8,[rsp+0x18]
    3cc5:	mov    QWORD PTR [rsp+0x18],rbx
    3cca:	mov    rax,r14
    3ccd:	mov    QWORD PTR [rsp+0x20],rax
    3cd2:	mov    esi,0x1b
    3cd7:	mov    rdx,QWORD PTR [rip+0x0]        # 3cde <botlish_fn_20+0x116>
			3cda: R_X86_64_GOTPCREL	botlish_entry_27-0x4 ; scan_label<generic>
    3cde:	mov    rcx,r15
    3ce1:	mov    rdi,QWORD PTR [rsp+0x78]
    3ce6:	call   3ceb <botlish_fn_20+0x123>
			3ce7: R_X86_64_PLT32	rt_closure_new-0x4
    3ceb:	mov    QWORD PTR [r12+0x18],rax
    3cf0:	mov    QWORD PTR [rsp+0x80],rax
    3cf8:	lea    r8,[rsp+0x28]
    3cfd:	mov    QWORD PTR [rsp+0x28],rbx
    3d02:	mov    QWORD PTR [rsp+0x30],r14
    3d07:	mov    esi,0x1c
    3d0c:	mov    rdx,QWORD PTR [rip+0x0]        # 3d13 <botlish_fn_20+0x14b>
			3d0f: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; scan_alpha<generic>
    3d13:	mov    rcx,r15
    3d16:	mov    rdi,QWORD PTR [rsp+0x78]
    3d1b:	call   3d20 <botlish_fn_20+0x158>
			3d1c: R_X86_64_PLT32	rt_closure_new-0x4
    3d20:	mov    QWORD PTR [r12+0x20],rax
    3d25:	lea    r8,[rsp+0x38]
    3d2a:	mov    QWORD PTR [rsp+0x38],rax
    3d2f:	mov    QWORD PTR [rsp+0x40],rbx
    3d34:	mov    esi,0x1d
    3d39:	mov    rdx,QWORD PTR [rip+0x0]        # 3d40 <botlish_fn_20+0x178>
			3d3c: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; tld_ok<generic>
    3d40:	mov    rcx,r15
    3d43:	mov    rdi,QWORD PTR [rsp+0x78]
    3d48:	call   3d4d <botlish_fn_20+0x185>
			3d49: R_X86_64_PLT32	rt_closure_new-0x4
    3d4d:	mov    QWORD PTR [r12+0x20],rax
    3d52:	lea    r8,[rsp+0x48]
    3d57:	mov    rcx,QWORD PTR [rsp+0x80]
    3d5f:	mov    QWORD PTR [rsp+0x48],rcx
    3d64:	mov    QWORD PTR [rsp+0x50],rbx
    3d69:	mov    QWORD PTR [rsp+0x58],r14
    3d6e:	mov    QWORD PTR [rsp+0x60],rax
    3d73:	mov    esi,0x1e
    3d78:	mov    rdx,QWORD PTR [rip+0x0]        # 3d7f <botlish_fn_20+0x1b7>
			3d7b: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; domain_loop<generic>
    3d7f:	mov    ecx,0x4
    3d84:	mov    rdi,QWORD PTR [rsp+0x78]
    3d89:	call   3d8e <botlish_fn_20+0x1c6>
			3d8a: R_X86_64_PLT32	rt_closure_new-0x4
    3d8e:	mov    QWORD PTR [r12+0x18],rax
    3d93:	mov    r15,rax
    3d96:	mov    QWORD PTR [r12+0x20],0x1
    3d9f:	mov    rdx,r13
    3da2:	mov    rsi,QWORD PTR [rsp+0x88]
    3daa:	mov    rdi,QWORD PTR [rsp+0x78]
    3daf:	call   3db4 <botlish_fn_20+0x1ec>
			3db0: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    3db4:	mov    rcx,rax
    3db7:	mov    r13,rax
    3dba:	test   rax,rcx
    3dbd:	jne    3dcd <botlish_fn_20+0x205>
    3dc3:	mov    rdi,QWORD PTR [rsp+0x78]
    3dc8:	jmp    3f32 <botlish_fn_20+0x36a>
    3dcd:	mov    rax,r13
    3dd0:	mov    QWORD PTR [r12+0x10],rax
    3dd5:	test   rax,0x1
    3ddb:	jne    3e09 <botlish_fn_20+0x241>
    3de1:	mov    edx,0x1
    3de6:	mov    rsi,r13
    3de9:	mov    rdi,QWORD PTR [rsp+0x78]
    3dee:	call   3df3 <botlish_fn_20+0x22b>
			3def: R_X86_64_PLT32	rt_int_cmp-0x4
    3df3:	mov    r10d,0x2
    3df9:	test   rax,rax
    3dfc:	cmove  r10,QWORD PTR [rip+0x25c]        # 4060 <botlish_fn_20+0x498>
    3e04:	jmp    3e1b <botlish_fn_20+0x253>
    3e09:	mov    r10d,0x2
    3e0f:	cmp    r13,0x1
    3e13:	cmove  r10,QWORD PTR [rip+0x245]        # 4060 <botlish_fn_20+0x498>
    3e1b:	cmp    r10,0x6
    3e1f:	je     3fd6 <botlish_fn_20+0x40e>
    3e25:	mov    rax,r13
    3e28:	and    rax,rbx
    3e2b:	test   rax,0x1
    3e31:	jne    3e5c <botlish_fn_20+0x294>
    3e37:	mov    rdx,rbx
    3e3a:	mov    rsi,r13
    3e3d:	mov    rdi,QWORD PTR [rsp+0x78]
    3e42:	call   3e47 <botlish_fn_20+0x27f>
			3e43: R_X86_64_PLT32	rt_int_cmp-0x4
    3e47:	mov    ecx,0x2
    3e4c:	test   rax,rax
    3e4f:	cmovge rcx,QWORD PTR [rip+0x209]        # 4060 <botlish_fn_20+0x498>
    3e57:	jmp    3e6c <botlish_fn_20+0x2a4>
    3e5c:	mov    ecx,0x2
    3e61:	cmp    r13,rbx
    3e64:	cmovge rcx,QWORD PTR [rip+0x1f4]        # 4060 <botlish_fn_20+0x498>
    3e6c:	cmp    rcx,0x6
    3e70:	je     3fc7 <botlish_fn_20+0x3ff>
    3e76:	lea    rcx,[rsp+0x68]
    3e7b:	mov    rsi,r14
    3e7e:	mov    rdx,r13
    3e81:	mov    rdi,QWORD PTR [rsp+0x78]
    3e86:	call   3e8b <botlish_fn_20+0x2c3>
			3e87: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    3e8b:	test   rax,rax
    3e8e:	jne    3e9e <botlish_fn_20+0x2d6>
    3e94:	mov    rdi,QWORD PTR [rsp+0x78]
    3e99:	jmp    3f32 <botlish_fn_20+0x36a>
    3e9e:	mov    rdx,QWORD PTR [rsp+0x68]
    3ea3:	mov    rcx,QWORD PTR [rsp+0x70]
    3ea8:	mov    rdi,QWORD PTR [rsp+0x78]
    3ead:	mov    rsi,QWORD PTR [rdi+0x10]
    3eb1:	mov    r8,QWORD PTR [rsi+0x100]
    3eb8:	mov    rsi,rax
    3ebb:	call   3ec0 <botlish_fn_20+0x2f8>
			3ebc: R_X86_64_PLT32	rt_str_region_eq-0x4
    3ec0:	cmp    rax,0x6
    3ec4:	je     3ed7 <botlish_fn_20+0x30f>
    3eca:	mov    ecx,0x2
    3ecf:	mov    rax,rcx
    3ed2:	jmp    3fcc <botlish_fn_20+0x404>
    3ed7:	mov    QWORD PTR [r12],0x3
    3edf:	test   r13,0x1
    3ee6:	je     3efe <botlish_fn_20+0x336>
    3eec:	mov    rdx,r13
    3eef:	add    rdx,0x2
    3ef3:	seto   al
    3ef6:	test   al,al
    3ef8:	je     3f13 <botlish_fn_20+0x34b>
    3efe:	mov    edx,0x3
    3f03:	mov    rsi,r13
    3f06:	mov    rdi,QWORD PTR [rsp+0x78]
    3f0b:	call   3f10 <botlish_fn_20+0x348>
			3f0c: R_X86_64_PLT32	rt_int_add-0x4
    3f10:	mov    rdx,rax
    3f13:	mov    QWORD PTR [r12],rdx
    3f17:	mov    rsi,r15
    3f1a:	mov    rdi,QWORD PTR [rsp+0x78]
    3f1f:	call   3f24 <botlish_fn_20+0x35c>
			3f20: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    3f24:	test   rax,rax
    3f27:	jne    3f71 <botlish_fn_20+0x3a9>
    3f2d:	mov    rdi,QWORD PTR [rsp+0x78]
    3f32:	mov    rdi,QWORD PTR [rsp+0x78]
    3f37:	mov    QWORD PTR [rdi],r12
    3f3a:	xor    rax,rax
    3f3d:	mov    rbx,QWORD PTR [rsp+0x90]
    3f45:	mov    r12,QWORD PTR [rsp+0x98]
    3f4d:	mov    r13,QWORD PTR [rsp+0xa0]
    3f55:	mov    r14,QWORD PTR [rsp+0xa8]
    3f5d:	mov    r15,QWORD PTR [rsp+0xb0]
    3f65:	add    rsp,0xc0
    3f6c:	mov    rsp,rbp
    3f6f:	pop    rbp
    3f70:	ret
    3f71:	mov    rcx,rax
    3f74:	and    rcx,rbx
    3f77:	mov    rsi,rax
    3f7a:	mov    rax,rbx
    3f7d:	test   rcx,0x1
    3f84:	jne    3faf <botlish_fn_20+0x3e7>
    3f8a:	mov    rdx,rax
    3f8d:	mov    rdi,QWORD PTR [rsp+0x78]
    3f92:	call   3f97 <botlish_fn_20+0x3cf>
			3f93: R_X86_64_PLT32	rt_int_cmp-0x4
    3f97:	mov    ecx,0x2
    3f9c:	test   rax,rax
    3f9f:	mov    rax,rcx
    3fa2:	cmove  rax,QWORD PTR [rip+0xb6]        # 4060 <botlish_fn_20+0x498>
    3faa:	jmp    3fcc <botlish_fn_20+0x404>
    3faf:	mov    rdx,rax
    3fb2:	mov    eax,0x2
    3fb7:	cmp    rsi,rdx
    3fba:	cmove  rax,QWORD PTR [rip+0x9e]        # 4060 <botlish_fn_20+0x498>
    3fc2:	jmp    3fcc <botlish_fn_20+0x404>
    3fc7:	mov    eax,0x2
    3fcc:	mov    rdi,QWORD PTR [rsp+0x78]
    3fd1:	jmp    3fe0 <botlish_fn_20+0x418>
    3fd6:	mov    eax,0x2
    3fdb:	mov    rdi,QWORD PTR [rsp+0x78]
    3fe0:	mov    rdi,QWORD PTR [rsp+0x78]
    3fe5:	mov    QWORD PTR [rdi],r12
    3fe8:	mov    rbx,QWORD PTR [rsp+0x90]
    3ff0:	mov    r12,QWORD PTR [rsp+0x98]
    3ff8:	mov    r13,QWORD PTR [rsp+0xa0]
    4000:	mov    r14,QWORD PTR [rsp+0xa8]
    4008:	mov    r15,QWORD PTR [rsp+0xb0]
    4010:	add    rsp,0xc0
    4017:	mov    rsp,rbp
    401a:	pop    rbp
    401b:	ret
    401c:	mov    QWORD PTR [rsp+0x78],rdi
    4021:	call   4026 <botlish_fn_20+0x45e>
			4022: R_X86_64_PLT32	rt_stack_overflow-0x4
    4026:	xor    rax,rax
    4029:	mov    rbx,QWORD PTR [rsp+0x90]
    4031:	mov    r12,QWORD PTR [rsp+0x98]
    4039:	mov    r13,QWORD PTR [rsp+0xa0]
    4041:	mov    r14,QWORD PTR [rsp+0xa8]
    4049:	mov    r15,QWORD PTR [rsp+0xb0]
    4051:	add    rsp,0xc0
    4058:	mov    rsp,rbp
    405b:	pop    rbp
    405c:	ret
    405d:	add    BYTE PTR [rax],al
    405f:	add    BYTE PTR [rsi],al
    4061:	add    BYTE PTR [rax],al
    4063:	add    BYTE PTR [rax],al
    4065:	add    BYTE PTR [rax],al
	...

0000000000004068 <botlish_entry_20: <str>>:
    4068:	push   rbp
    4069:	mov    rbp,rsp
    406c:	mov    rsi,QWORD PTR [rdx]
    406f:	call   4074 <botlish_entry_20+0xc>
			4070: R_X86_64_PLT32	botlish_fn_20-0x4 ; <str>
    4074:	mov    rsp,rbp
    4077:	pop    rbp
    4078:	ret
    4079:	add    BYTE PTR [rax],al
    407b:	add    BYTE PTR [rax],al
    407d:	add    BYTE PTR [rax],al
	...

0000000000004080 <botlish_fn_21: <generic>>:
    4080:	push   rbp
    4081:	mov    rbp,rsp
    4084:	sub    rsp,0xc0
    408b:	mov    QWORD PTR [rsp+0x90],rbx
    4093:	mov    QWORD PTR [rsp+0x98],r12
    409b:	mov    QWORD PTR [rsp+0xa0],r13
    40a3:	mov    QWORD PTR [rsp+0xa8],r14
    40ab:	mov    QWORD PTR [rsp+0xb0],r15
    40b3:	mov    r12,QWORD PTR [rdi]
    40b6:	mov    rax,QWORD PTR [rdi+0x8]
    40ba:	lea    rcx,[r12+0x28]
    40bf:	cmp    rcx,rax
    40c2:	ja     4512 <botlish_fn_21+0x492>
    40c8:	lea    rax,[r12+0x28]
    40cd:	mov    QWORD PTR [rdi],rax
    40d0:	mov    QWORD PTR [r12+0x10],0x0
    40d9:	mov    QWORD PTR [r12+0x18],0x0
    40e2:	mov    QWORD PTR [r12+0x20],0x0
    40eb:	mov    QWORD PTR [r12],rsi
    40ef:	xor    eax,eax
    40f1:	test   rsi,0x7
    40f8:	jne    4107 <botlish_fn_21+0x87>
    40fe:	movzx  rax,BYTE PTR [rsi]
    4102:	cmp    al,0x2
    4104:	sete   al
    4107:	test   al,al
    4109:	jne    4133 <botlish_fn_21+0xb3>
    410f:	mov    rax,QWORD PTR [rdi+0x10]
    4113:	mov    QWORD PTR [rsp+0x78],rdi
    4118:	mov    rcx,QWORD PTR [rax+0xd8]
    411f:	mov    edx,0x1
    4124:	call   4129 <botlish_fn_21+0xa9>
			4125: R_X86_64_PLT32	rt_type_error-0x4
    4129:	mov    rdi,QWORD PTR [rsp+0x78]
    412e:	jmp    4428 <botlish_fn_21+0x3a8>
    4133:	mov    r13,rsi
    4136:	mov    QWORD PTR [rsp+0x78],rdi
    413b:	call   4140 <botlish_fn_21+0xc0>
			413c: R_X86_64_PLT32	rt_str_len-0x4
    4140:	mov    rbx,rax
    4143:	mov    QWORD PTR [r12+0x8],rbx
    4148:	lea    r8,[rsp]
    414c:	mov    QWORD PTR [rsp],r13
    4150:	mov    esi,0x16
    4155:	mov    rdx,QWORD PTR [rip+0x0]        # 415c <botlish_fn_21+0xdc>
			4158: R_X86_64_GOTPCREL	botlish_entry_22-0x4 ; char_at<generic>
    415c:	mov    r13d,0x1
    4162:	mov    rcx,r13
    4165:	mov    rdi,QWORD PTR [rsp+0x78]
    416a:	call   416f <botlish_fn_21+0xef>
			416b: R_X86_64_PLT32	rt_closure_new-0x4
    416f:	mov    r15,rax
    4172:	mov    QWORD PTR [rsp+0x88],r13
    417a:	mov    QWORD PTR [r12],rax
    417e:	lea    r8,[rsp+0x8]
    4183:	mov    QWORD PTR [rsp+0x8],rbx
    4188:	mov    QWORD PTR [rsp+0x10],rax
    418d:	mov    esi,0x1a
    4192:	mov    rdx,QWORD PTR [rip+0x0]        # 4199 <botlish_fn_21+0x119>
			4195: R_X86_64_GOTPCREL	botlish_entry_26-0x4 ; scan_local<generic>
    4199:	mov    r14d,0x2
    419f:	mov    rcx,r14
    41a2:	mov    rdi,QWORD PTR [rsp+0x78]
    41a7:	call   41ac <botlish_fn_21+0x12c>
			41a8: R_X86_64_PLT32	rt_closure_new-0x4
    41ac:	mov    r13,rax
    41af:	mov    QWORD PTR [r12+0x10],r13
    41b4:	lea    r8,[rsp+0x18]
    41b9:	mov    QWORD PTR [rsp+0x18],rbx
    41be:	mov    rax,r15
    41c1:	mov    QWORD PTR [rsp+0x20],rax
    41c6:	mov    esi,0x1b
    41cb:	mov    rdx,QWORD PTR [rip+0x0]        # 41d2 <botlish_fn_21+0x152>
			41ce: R_X86_64_GOTPCREL	botlish_entry_27-0x4 ; scan_label<generic>
    41d2:	mov    rcx,r14
    41d5:	mov    rdi,QWORD PTR [rsp+0x78]
    41da:	call   41df <botlish_fn_21+0x15f>
			41db: R_X86_64_PLT32	rt_closure_new-0x4
    41df:	mov    QWORD PTR [r12+0x18],rax
    41e4:	mov    QWORD PTR [rsp+0x80],rax
    41ec:	lea    r8,[rsp+0x28]
    41f1:	mov    QWORD PTR [rsp+0x28],rbx
    41f6:	mov    QWORD PTR [rsp+0x30],r15
    41fb:	mov    esi,0x1c
    4200:	mov    rdx,QWORD PTR [rip+0x0]        # 4207 <botlish_fn_21+0x187>
			4203: R_X86_64_GOTPCREL	botlish_entry_28-0x4 ; scan_alpha<generic>
    4207:	mov    rcx,r14
    420a:	mov    rdi,QWORD PTR [rsp+0x78]
    420f:	call   4214 <botlish_fn_21+0x194>
			4210: R_X86_64_PLT32	rt_closure_new-0x4
    4214:	mov    QWORD PTR [r12+0x20],rax
    4219:	lea    r8,[rsp+0x38]
    421e:	mov    QWORD PTR [rsp+0x38],rax
    4223:	mov    QWORD PTR [rsp+0x40],rbx
    4228:	mov    esi,0x1d
    422d:	mov    rdx,QWORD PTR [rip+0x0]        # 4234 <botlish_fn_21+0x1b4>
			4230: R_X86_64_GOTPCREL	botlish_entry_29-0x4 ; tld_ok<generic>
    4234:	mov    rcx,r14
    4237:	mov    rdi,QWORD PTR [rsp+0x78]
    423c:	call   4241 <botlish_fn_21+0x1c1>
			423d: R_X86_64_PLT32	rt_closure_new-0x4
    4241:	mov    QWORD PTR [r12+0x20],rax
    4246:	lea    r8,[rsp+0x48]
    424b:	mov    rcx,QWORD PTR [rsp+0x80]
    4253:	mov    QWORD PTR [rsp+0x48],rcx
    4258:	mov    QWORD PTR [rsp+0x50],rbx
    425d:	mov    QWORD PTR [rsp+0x58],r15
    4262:	mov    QWORD PTR [rsp+0x60],rax
    4267:	mov    esi,0x1e
    426c:	mov    rdx,QWORD PTR [rip+0x0]        # 4273 <botlish_fn_21+0x1f3>
			426f: R_X86_64_GOTPCREL	botlish_entry_30-0x4 ; domain_loop<generic>
    4273:	mov    ecx,0x4
    4278:	mov    rdi,QWORD PTR [rsp+0x78]
    427d:	call   4282 <botlish_fn_21+0x202>
			427e: R_X86_64_PLT32	rt_closure_new-0x4
    4282:	mov    QWORD PTR [r12+0x18],rax
    4287:	mov    r14,rax
    428a:	mov    QWORD PTR [r12+0x20],0x1
    4293:	mov    rsi,r13
    4296:	mov    rdx,QWORD PTR [rsp+0x88]
    429e:	mov    rdi,QWORD PTR [rsp+0x78]
    42a3:	call   42a8 <botlish_fn_21+0x228>
			42a4: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    42a8:	mov    r10,rax
    42ab:	mov    r13,rax
    42ae:	test   rax,r10
    42b1:	jne    42c1 <botlish_fn_21+0x241>
    42b7:	mov    rdi,QWORD PTR [rsp+0x78]
    42bc:	jmp    4428 <botlish_fn_21+0x3a8>
    42c1:	mov    rax,r13
    42c4:	mov    QWORD PTR [r12+0x10],rax
    42c9:	test   rax,0x1
    42cf:	jne    42ff <botlish_fn_21+0x27f>
    42d5:	mov    rdx,QWORD PTR [rsp+0x88]
    42dd:	mov    rsi,r13
    42e0:	mov    rdi,QWORD PTR [rsp+0x78]
    42e5:	call   42ea <botlish_fn_21+0x26a>
			42e6: R_X86_64_PLT32	rt_int_cmp-0x4
    42ea:	mov    ecx,0x2
    42ef:	test   rax,rax
    42f2:	cmove  rcx,QWORD PTR [rip+0x25e]        # 4558 <botlish_fn_21+0x4d8>
    42fa:	jmp    4310 <botlish_fn_21+0x290>
    42ff:	mov    ecx,0x2
    4304:	cmp    r13,0x1
    4308:	cmove  rcx,QWORD PTR [rip+0x248]        # 4558 <botlish_fn_21+0x4d8>
    4310:	cmp    rcx,0x6
    4314:	je     44cc <botlish_fn_21+0x44c>
    431a:	mov    r11,r13
    431d:	and    r11,rbx
    4320:	test   r11,0x1
    4327:	jne    4352 <botlish_fn_21+0x2d2>
    432d:	mov    rdx,rbx
    4330:	mov    rsi,r13
    4333:	mov    rdi,QWORD PTR [rsp+0x78]
    4338:	call   433d <botlish_fn_21+0x2bd>
			4339: R_X86_64_PLT32	rt_int_cmp-0x4
    433d:	mov    ecx,0x2
    4342:	test   rax,rax
    4345:	cmovge rcx,QWORD PTR [rip+0x20b]        # 4558 <botlish_fn_21+0x4d8>
    434d:	jmp    4362 <botlish_fn_21+0x2e2>
    4352:	mov    ecx,0x2
    4357:	cmp    r13,rbx
    435a:	cmovge rcx,QWORD PTR [rip+0x1f6]        # 4558 <botlish_fn_21+0x4d8>
    4362:	cmp    rcx,0x6
    4366:	je     44bd <botlish_fn_21+0x43d>
    436c:	lea    rcx,[rsp+0x68]
    4371:	mov    rsi,r15
    4374:	mov    rdx,r13
    4377:	mov    rdi,QWORD PTR [rsp+0x78]
    437c:	call   4381 <botlish_fn_21+0x301>
			437d: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    4381:	test   rax,rax
    4384:	mov    rsi,rax
    4387:	jne    4397 <botlish_fn_21+0x317>
    438d:	mov    rdi,QWORD PTR [rsp+0x78]
    4392:	jmp    4428 <botlish_fn_21+0x3a8>
    4397:	mov    rdx,QWORD PTR [rsp+0x68]
    439c:	mov    rcx,QWORD PTR [rsp+0x70]
    43a1:	mov    rdi,QWORD PTR [rsp+0x78]
    43a6:	mov    rax,QWORD PTR [rdi+0x10]
    43aa:	mov    r8,QWORD PTR [rax+0x100]
    43b1:	call   43b6 <botlish_fn_21+0x336>
			43b2: R_X86_64_PLT32	rt_str_region_eq-0x4
    43b6:	cmp    rax,0x6
    43ba:	je     43cd <botlish_fn_21+0x34d>
    43c0:	mov    esi,0x2
    43c5:	mov    rax,rsi
    43c8:	jmp    44c2 <botlish_fn_21+0x442>
    43cd:	mov    QWORD PTR [r12],0x3
    43d5:	test   r13,0x1
    43dc:	je     43f4 <botlish_fn_21+0x374>
    43e2:	mov    rdx,r13
    43e5:	add    rdx,0x2
    43e9:	seto   al
    43ec:	test   al,al
    43ee:	je     4409 <botlish_fn_21+0x389>
    43f4:	mov    edx,0x3
    43f9:	mov    rsi,r13
    43fc:	mov    rdi,QWORD PTR [rsp+0x78]
    4401:	call   4406 <botlish_fn_21+0x386>
			4402: R_X86_64_PLT32	rt_int_add-0x4
    4406:	mov    rdx,rax
    4409:	mov    QWORD PTR [r12],rdx
    440d:	mov    rsi,r14
    4410:	mov    rdi,QWORD PTR [rsp+0x78]
    4415:	call   441a <botlish_fn_21+0x39a>
			4416: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    441a:	test   rax,rax
    441d:	jne    4467 <botlish_fn_21+0x3e7>
    4423:	mov    rdi,QWORD PTR [rsp+0x78]
    4428:	mov    rdi,QWORD PTR [rsp+0x78]
    442d:	mov    QWORD PTR [rdi],r12
    4430:	xor    rax,rax
    4433:	mov    rbx,QWORD PTR [rsp+0x90]
    443b:	mov    r12,QWORD PTR [rsp+0x98]
    4443:	mov    r13,QWORD PTR [rsp+0xa0]
    444b:	mov    r14,QWORD PTR [rsp+0xa8]
    4453:	mov    r15,QWORD PTR [rsp+0xb0]
    445b:	add    rsp,0xc0
    4462:	mov    rsp,rbp
    4465:	pop    rbp
    4466:	ret
    4467:	mov    rcx,rax
    446a:	and    rcx,rbx
    446d:	mov    rsi,rax
    4470:	mov    rax,rbx
    4473:	test   rcx,0x1
    447a:	jne    44a5 <botlish_fn_21+0x425>
    4480:	mov    rdx,rax
    4483:	mov    rdi,QWORD PTR [rsp+0x78]
    4488:	call   448d <botlish_fn_21+0x40d>
			4489: R_X86_64_PLT32	rt_int_cmp-0x4
    448d:	mov    esi,0x2
    4492:	test   rax,rax
    4495:	mov    rax,rsi
    4498:	cmove  rax,QWORD PTR [rip+0xb8]        # 4558 <botlish_fn_21+0x4d8>
    44a0:	jmp    44c2 <botlish_fn_21+0x442>
    44a5:	mov    rdx,rax
    44a8:	mov    eax,0x2
    44ad:	cmp    rsi,rdx
    44b0:	cmove  rax,QWORD PTR [rip+0xa0]        # 4558 <botlish_fn_21+0x4d8>
    44b8:	jmp    44c2 <botlish_fn_21+0x442>
    44bd:	mov    eax,0x2
    44c2:	mov    rdi,QWORD PTR [rsp+0x78]
    44c7:	jmp    44d6 <botlish_fn_21+0x456>
    44cc:	mov    eax,0x2
    44d1:	mov    rdi,QWORD PTR [rsp+0x78]
    44d6:	mov    rdi,QWORD PTR [rsp+0x78]
    44db:	mov    QWORD PTR [rdi],r12
    44de:	mov    rbx,QWORD PTR [rsp+0x90]
    44e6:	mov    r12,QWORD PTR [rsp+0x98]
    44ee:	mov    r13,QWORD PTR [rsp+0xa0]
    44f6:	mov    r14,QWORD PTR [rsp+0xa8]
    44fe:	mov    r15,QWORD PTR [rsp+0xb0]
    4506:	add    rsp,0xc0
    450d:	mov    rsp,rbp
    4510:	pop    rbp
    4511:	ret
    4512:	mov    QWORD PTR [rsp+0x78],rdi
    4517:	call   451c <botlish_fn_21+0x49c>
			4518: R_X86_64_PLT32	rt_stack_overflow-0x4
    451c:	xor    rax,rax
    451f:	mov    rbx,QWORD PTR [rsp+0x90]
    4527:	mov    r12,QWORD PTR [rsp+0x98]
    452f:	mov    r13,QWORD PTR [rsp+0xa0]
    4537:	mov    r14,QWORD PTR [rsp+0xa8]
    453f:	mov    r15,QWORD PTR [rsp+0xb0]
    4547:	add    rsp,0xc0
    454e:	mov    rsp,rbp
    4551:	pop    rbp
    4552:	ret
    4553:	add    BYTE PTR [rax],al
    4555:	add    BYTE PTR [rax],al
    4557:	add    BYTE PTR [rsi],al
    4559:	add    BYTE PTR [rax],al
    455b:	add    BYTE PTR [rax],al
    455d:	add    BYTE PTR [rax],al
	...

0000000000004560 <botlish_entry_21: <generic>>:
    4560:	push   rbp
    4561:	mov    rbp,rsp
    4564:	mov    rsi,QWORD PTR [rdx]
    4567:	call   456c <botlish_entry_21+0xc>
			4568: R_X86_64_PLT32	botlish_fn_21-0x4 ; <generic>
    456c:	mov    rsp,rbp
    456f:	pop    rbp
    4570:	ret

0000000000004571 <botlish_fn_22: char_at<generic>>:
    4571:	push   rbp
    4572:	mov    rbp,rsp
    4575:	sub    rsp,0x50
    4579:	mov    QWORD PTR [rsp+0x20],rbx
    457e:	mov    QWORD PTR [rsp+0x28],r12
    4583:	mov    QWORD PTR [rsp+0x30],r13
    4588:	mov    QWORD PTR [rsp+0x38],r14
    458d:	mov    QWORD PTR [rsp+0x40],r15
    4592:	mov    rbx,QWORD PTR [rdi+0x20]
    4596:	mov    r13,QWORD PTR [rdi+0x28]
    459a:	lea    rax,[rsp]
    459e:	mov    QWORD PTR [rdi+0x20],rax
    45a2:	mov    QWORD PTR [rdi+0x28],0x3
    45aa:	mov    QWORD PTR [rsp],rdx
    45ae:	mov    rax,QWORD PTR [rsi+0x20]
    45b2:	mov    rsi,QWORD PTR [rax]
    45b5:	mov    QWORD PTR [rsp+0x8],rsi
    45ba:	mov    r15,rsi
    45bd:	mov    QWORD PTR [rsp+0x10],0x3
    45c6:	mov    ecx,0x1
    45cb:	test   rdx,0x1
    45d2:	je     45e0 <botlish_fn_22+0x6f>
    45d8:	mov    r14,rdx
    45db:	jmp    4603 <botlish_fn_22+0x92>
    45e0:	xor    ecx,ecx
    45e2:	test   rdx,0x7
    45e9:	je     45f7 <botlish_fn_22+0x86>
    45ef:	mov    r14,rdx
    45f2:	jmp    4603 <botlish_fn_22+0x92>
    45f7:	movzx  rax,BYTE PTR [rdx]
    45fb:	mov    r14,rdx
    45fe:	cmp    al,0x1
    4600:	sete   cl
    4603:	test   cl,cl
    4605:	jne    4629 <botlish_fn_22+0xb8>
    460b:	mov    rax,QWORD PTR [rdi+0x10]
    460f:	mov    rcx,QWORD PTR [rax+0x108]
    4616:	xor    rdx,rdx
    4619:	mov    rsi,r14
    461c:	mov    r12,rdi
    461f:	call   4624 <botlish_fn_22+0xb3>
			4620: R_X86_64_PLT32	rt_type_error-0x4
    4624:	jmp    46dc <botlish_fn_22+0x16b>
    4629:	mov    rsi,r14
    462c:	mov    r12,rdi
    462f:	test   rsi,0x1
    4636:	je     4651 <botlish_fn_22+0xe0>
    463c:	mov    rsi,r14
    463f:	mov    rcx,rsi
    4642:	add    rcx,0x2
    4646:	seto   al
    4649:	test   al,al
    464b:	je     4664 <botlish_fn_22+0xf3>
    4651:	mov    edx,0x3
    4656:	mov    rsi,r14
    4659:	mov    rdi,r12
    465c:	call   4661 <botlish_fn_22+0xf0>
			465d: R_X86_64_PLT32	rt_int_add-0x4
    4661:	mov    rcx,rax
    4664:	mov    QWORD PTR [rsp+0x10],rcx
    4669:	mov    edx,0x1
    466e:	mov    rsi,r14
    4671:	test   rsi,0x1
    4678:	jne    469e <botlish_fn_22+0x12d>
    467e:	xor    edx,edx
    4680:	mov    rsi,r14
    4683:	test   rsi,0x7
    468a:	jne    469e <botlish_fn_22+0x12d>
    4690:	mov    rsi,r14
    4693:	movzx  rdi,BYTE PTR [rsi]
    4697:	cmp    dil,0x1
    469b:	sete   dl
    469e:	test   dl,dl
    46a0:	jne    46c5 <botlish_fn_22+0x154>
    46a6:	mov    r11,QWORD PTR [r12+0x10]
    46ab:	mov    rcx,QWORD PTR [r11+0x110]
    46b2:	xor    rdx,rdx
    46b5:	mov    rsi,r14
    46b8:	mov    rdi,r12
    46bb:	call   46c0 <botlish_fn_22+0x14f>
			46bc: R_X86_64_PLT32	rt_type_error-0x4
    46c0:	jmp    46dc <botlish_fn_22+0x16b>
    46c5:	mov    rdx,r14
    46c8:	mov    rsi,r15
    46cb:	mov    rdi,r12
    46ce:	call   46d3 <botlish_fn_22+0x162>
			46cf: R_X86_64_PLT32	rt_substr-0x4
    46d3:	test   rax,rax
    46d6:	jne    470b <botlish_fn_22+0x19a>
    46dc:	mov    QWORD PTR [r12+0x20],rbx
    46e1:	mov    QWORD PTR [r12+0x28],r13
    46e6:	xor    rax,rax
    46e9:	mov    rbx,QWORD PTR [rsp+0x20]
    46ee:	mov    r12,QWORD PTR [rsp+0x28]
    46f3:	mov    r13,QWORD PTR [rsp+0x30]
    46f8:	mov    r14,QWORD PTR [rsp+0x38]
    46fd:	mov    r15,QWORD PTR [rsp+0x40]
    4702:	add    rsp,0x50
    4706:	mov    rsp,rbp
    4709:	pop    rbp
    470a:	ret
    470b:	mov    QWORD PTR [r12+0x20],rbx
    4710:	mov    QWORD PTR [r12+0x28],r13
    4715:	mov    rbx,QWORD PTR [rsp+0x20]
    471a:	mov    r12,QWORD PTR [rsp+0x28]
    471f:	mov    r13,QWORD PTR [rsp+0x30]
    4724:	mov    r14,QWORD PTR [rsp+0x38]
    4729:	mov    r15,QWORD PTR [rsp+0x40]
    472e:	add    rsp,0x50
    4732:	mov    rsp,rbp
    4735:	pop    rbp
    4736:	ret

0000000000004737 <botlish_entry_22: char_at<generic>>:
    4737:	push   rbp
    4738:	mov    rbp,rsp
    473b:	mov    rdx,QWORD PTR [rdx]
    473e:	call   4743 <botlish_entry_22+0xc>
			473f: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    4743:	mov    rsp,rbp
    4746:	pop    rbp
    4747:	ret

0000000000004748 <botlish_fn_23: char_at<generic>>:
    4748:	push   rbp
    4749:	mov    rbp,rsp
    474c:	sub    rsp,0x60
    4750:	mov    QWORD PTR [rsp+0x30],rbx
    4755:	mov    QWORD PTR [rsp+0x38],r12
    475a:	mov    QWORD PTR [rsp+0x40],r13
    475f:	mov    QWORD PTR [rsp+0x48],r14
    4764:	mov    QWORD PTR [rsp+0x50],r15
    4769:	mov    QWORD PTR [rsp+0x18],rcx
    476e:	mov    rbx,QWORD PTR [rdi+0x20]
    4772:	mov    r12,QWORD PTR [rdi+0x28]
    4776:	lea    rax,[rsp]
    477a:	mov    QWORD PTR [rdi+0x20],rax
    477e:	mov    QWORD PTR [rdi+0x28],0x3
    4786:	mov    QWORD PTR [rsp],rdx
    478a:	mov    rax,QWORD PTR [rsi+0x20]
    478e:	mov    rax,QWORD PTR [rax]
    4791:	mov    QWORD PTR [rsp+0x8],rax
    4796:	mov    QWORD PTR [rsp+0x20],rax
    479b:	mov    QWORD PTR [rsp+0x10],0x3
    47a4:	mov    eax,0x1
    47a9:	test   rdx,0x1
    47b0:	je     47be <botlish_fn_23+0x76>
    47b6:	mov    r15,rdx
    47b9:	jmp    47e1 <botlish_fn_23+0x99>
    47be:	xor    eax,eax
    47c0:	test   rdx,0x7
    47c7:	je     47d5 <botlish_fn_23+0x8d>
    47cd:	mov    r15,rdx
    47d0:	jmp    47e1 <botlish_fn_23+0x99>
    47d5:	movzx  rax,BYTE PTR [rdx]
    47d9:	mov    r15,rdx
    47dc:	cmp    al,0x1
    47de:	sete   al
    47e1:	test   al,al
    47e3:	jne    4807 <botlish_fn_23+0xbf>
    47e9:	mov    rax,QWORD PTR [rdi+0x10]
    47ed:	mov    rcx,QWORD PTR [rax+0x108]
    47f4:	xor    rdx,rdx
    47f7:	mov    rsi,r15
    47fa:	mov    r13,rdi
    47fd:	call   4802 <botlish_fn_23+0xba>
			47fe: R_X86_64_PLT32	rt_type_error-0x4
    4802:	jmp    48c1 <botlish_fn_23+0x179>
    4807:	mov    rsi,r15
    480a:	mov    r13,rdi
    480d:	test   rsi,0x1
    4814:	jne    4822 <botlish_fn_23+0xda>
    481a:	mov    r15,rsi
    481d:	jmp    4837 <botlish_fn_23+0xef>
    4822:	mov    rax,rsi
    4825:	add    rax,0x2
    4829:	mov    r15,rsi
    482c:	seto   cl
    482f:	test   cl,cl
    4831:	je     4847 <botlish_fn_23+0xff>
    4837:	mov    edx,0x3
    483c:	mov    rsi,r15
    483f:	mov    rdi,r13
    4842:	call   4847 <botlish_fn_23+0xff>
			4843: R_X86_64_PLT32	rt_int_add-0x4
    4847:	mov    ecx,0x1
    484c:	mov    rsi,r15
    484f:	test   rsi,0x1
    4856:	jne    487c <botlish_fn_23+0x134>
    485c:	xor    ecx,ecx
    485e:	mov    rsi,r15
    4861:	test   rsi,0x7
    4868:	jne    487c <botlish_fn_23+0x134>
    486e:	mov    rsi,r15
    4871:	movzx  rdi,BYTE PTR [rsi]
    4875:	cmp    dil,0x1
    4879:	sete   cl
    487c:	test   cl,cl
    487e:	jne    48a2 <botlish_fn_23+0x15a>
    4884:	mov    r11,QWORD PTR [r13+0x10]
    4888:	mov    rcx,QWORD PTR [r11+0x110]
    488f:	xor    rdx,rdx
    4892:	mov    rsi,r15
    4895:	mov    rdi,r13
    4898:	call   489d <botlish_fn_23+0x155>
			4899: R_X86_64_PLT32	rt_type_error-0x4
    489d:	jmp    48c1 <botlish_fn_23+0x179>
    48a2:	mov    r14,rax
    48a5:	mov    rcx,r14
    48a8:	mov    rdx,r15
    48ab:	mov    rsi,QWORD PTR [rsp+0x20]
    48b0:	mov    rdi,r13
    48b3:	call   48b8 <botlish_fn_23+0x170>
			48b4: R_X86_64_PLT32	rt_str_region_check-0x4
    48b8:	test   rax,rax
    48bb:	jne    48ee <botlish_fn_23+0x1a6>
    48c1:	mov    QWORD PTR [r13+0x20],rbx
    48c5:	mov    QWORD PTR [r13+0x28],r12
    48c9:	xor    rax,rax
    48cc:	mov    rbx,QWORD PTR [rsp+0x30]
    48d1:	mov    r12,QWORD PTR [rsp+0x38]
    48d6:	mov    r13,QWORD PTR [rsp+0x40]
    48db:	mov    r14,QWORD PTR [rsp+0x48]
    48e0:	mov    r15,QWORD PTR [rsp+0x50]
    48e5:	add    rsp,0x60
    48e9:	mov    rsp,rbp
    48ec:	pop    rbp
    48ed:	ret
    48ee:	mov    QWORD PTR [r13+0x20],rbx
    48f2:	mov    QWORD PTR [r13+0x28],r12
    48f6:	mov    rcx,QWORD PTR [rsp+0x18]
    48fb:	mov    rsi,r15
    48fe:	mov    QWORD PTR [rcx],rsi
    4901:	mov    QWORD PTR [rcx+0x8],r14
    4905:	mov    rax,QWORD PTR [rsp+0x20]
    490a:	mov    rbx,QWORD PTR [rsp+0x30]
    490f:	mov    r12,QWORD PTR [rsp+0x38]
    4914:	mov    r13,QWORD PTR [rsp+0x40]
    4919:	mov    r14,QWORD PTR [rsp+0x48]
    491e:	mov    r15,QWORD PTR [rsp+0x50]
    4923:	add    rsp,0x60
    4927:	mov    rsp,rbp
    492a:	pop    rbp
    492b:	ret

000000000000492c <botlish_entry_23: char_at<generic>>:
    492c:	push   rbp
    492d:	mov    rbp,rsp
    4930:	ud2

0000000000004932 <botlish_fn_24: is_local_char<str>>:
    4932:	push   rbp
    4933:	mov    rbp,rsp
    4936:	sub    rsp,0x10
    493a:	mov    QWORD PTR [rsp],rbx
    493e:	mov    QWORD PTR [rsp+0x8],r12
    4943:	mov    rbx,rsi
    4946:	mov    r12,rdi
    4949:	mov    rsi,rbx
    494c:	mov    rdi,r12
    494f:	call   4954 <botlish_fn_24+0x22>
			4950: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    4954:	test   rax,rax
    4957:	jne    4972 <botlish_fn_24+0x40>
    495d:	xor    rax,rax
    4960:	mov    rbx,QWORD PTR [rsp]
    4964:	mov    r12,QWORD PTR [rsp+0x8]
    4969:	add    rsp,0x10
    496d:	mov    rsp,rbp
    4970:	pop    rbp
    4971:	ret
    4972:	cmp    rax,0x6
    4976:	je     4a71 <botlish_fn_24+0x13f>
    497c:	mov    rdi,r12
    497f:	mov    rax,QWORD PTR [rdi+0x10]
    4983:	mov    rsi,QWORD PTR [rax+0x118]
    498a:	mov    edx,0x1
    498f:	mov    ecx,0x3
    4994:	mov    r8,rbx
    4997:	call   499c <botlish_fn_24+0x6a>
			4998: R_X86_64_PLT32	rt_str_region_eq-0x4
    499c:	cmp    rax,0x6
    49a0:	je     4a67 <botlish_fn_24+0x135>
    49a6:	mov    rdi,r12
    49a9:	mov    rax,QWORD PTR [rdi+0x10]
    49ad:	mov    rsi,QWORD PTR [rax+0x120]
    49b4:	mov    edx,0x1
    49b9:	mov    ecx,0x3
    49be:	mov    r8,rbx
    49c1:	call   49c6 <botlish_fn_24+0x94>
			49c2: R_X86_64_PLT32	rt_str_region_eq-0x4
    49c6:	cmp    rax,0x6
    49ca:	je     4a5d <botlish_fn_24+0x12b>
    49d0:	mov    rdi,r12
    49d3:	mov    rax,QWORD PTR [rdi+0x10]
    49d7:	mov    rsi,QWORD PTR [rax+0xc0]
    49de:	mov    edx,0x1
    49e3:	mov    ecx,0x3
    49e8:	mov    r8,rbx
    49eb:	call   49f0 <botlish_fn_24+0xbe>
			49ec: R_X86_64_PLT32	rt_str_region_eq-0x4
    49f0:	cmp    rax,0x6
    49f4:	je     4a53 <botlish_fn_24+0x121>
    49fa:	mov    rdi,r12
    49fd:	mov    rax,QWORD PTR [rdi+0x10]
    4a01:	mov    rsi,QWORD PTR [rax+0x108]
    4a08:	mov    edx,0x1
    4a0d:	mov    ecx,0x3
    4a12:	mov    r8,rbx
    4a15:	call   4a1a <botlish_fn_24+0xe8>
			4a16: R_X86_64_PLT32	rt_str_region_eq-0x4
    4a1a:	cmp    rax,0x6
    4a1e:	je     4a49 <botlish_fn_24+0x117>
    4a24:	mov    rdi,r12
    4a27:	mov    rax,QWORD PTR [rdi+0x10]
    4a2b:	mov    rsi,QWORD PTR [rax+0x128]
    4a32:	mov    edx,0x1
    4a37:	mov    ecx,0x3
    4a3c:	mov    r8,rbx
    4a3f:	call   4a44 <botlish_fn_24+0x112>
			4a40: R_X86_64_PLT32	rt_str_region_eq-0x4
    4a44:	jmp    4a76 <botlish_fn_24+0x144>
    4a49:	mov    eax,0x6
    4a4e:	jmp    4a76 <botlish_fn_24+0x144>
    4a53:	mov    eax,0x6
    4a58:	jmp    4a76 <botlish_fn_24+0x144>
    4a5d:	mov    eax,0x6
    4a62:	jmp    4a76 <botlish_fn_24+0x144>
    4a67:	mov    eax,0x6
    4a6c:	jmp    4a76 <botlish_fn_24+0x144>
    4a71:	mov    eax,0x6
    4a76:	mov    rbx,QWORD PTR [rsp]
    4a7a:	mov    r12,QWORD PTR [rsp+0x8]
    4a7f:	add    rsp,0x10
    4a83:	mov    rsp,rbp
    4a86:	pop    rbp
    4a87:	ret

0000000000004a88 <botlish_entry_24: is_local_char<str>>:
    4a88:	push   rbp
    4a89:	mov    rbp,rsp
    4a8c:	mov    rsi,QWORD PTR [rdx]
    4a8f:	call   4a94 <botlish_entry_24+0xc>
			4a90: R_X86_64_PLT32	botlish_fn_24-0x4 ; is_local_char<str>
    4a94:	mov    rsp,rbp
    4a97:	pop    rbp
    4a98:	ret

0000000000004a99 <botlish_fn_25: is_label_char<str>>:
    4a99:	push   rbp
    4a9a:	mov    rbp,rsp
    4a9d:	sub    rsp,0x10
    4aa1:	mov    QWORD PTR [rsp],r13
    4aa5:	mov    QWORD PTR [rsp+0x8],r15
    4aaa:	mov    r13,rsi
    4aad:	mov    r15,rdi
    4ab0:	mov    rsi,r13
    4ab3:	mov    rdi,r15
    4ab6:	call   4abb <botlish_fn_25+0x22>
			4ab7: R_X86_64_PLT32	rt_is_tcl_alnum-0x4
    4abb:	test   rax,rax
    4abe:	jne    4ad9 <botlish_fn_25+0x40>
    4ac4:	xor    rax,rax
    4ac7:	mov    r13,QWORD PTR [rsp]
    4acb:	mov    r15,QWORD PTR [rsp+0x8]
    4ad0:	add    rsp,0x10
    4ad4:	mov    rsp,rbp
    4ad7:	pop    rbp
    4ad8:	ret
    4ad9:	cmp    rax,0x6
    4add:	je     4b08 <botlish_fn_25+0x6f>
    4ae3:	mov    rdi,r15
    4ae6:	mov    rax,QWORD PTR [rdi+0x10]
    4aea:	mov    rsi,QWORD PTR [rax+0x128]
    4af1:	mov    edx,0x1
    4af6:	mov    ecx,0x3
    4afb:	mov    r8,r13
    4afe:	call   4b03 <botlish_fn_25+0x6a>
			4aff: R_X86_64_PLT32	rt_str_region_eq-0x4
    4b03:	jmp    4b0d <botlish_fn_25+0x74>
    4b08:	mov    eax,0x6
    4b0d:	mov    r13,QWORD PTR [rsp]
    4b11:	mov    r15,QWORD PTR [rsp+0x8]
    4b16:	add    rsp,0x10
    4b1a:	mov    rsp,rbp
    4b1d:	pop    rbp
    4b1e:	ret

0000000000004b1f <botlish_entry_25: is_label_char<str>>:
    4b1f:	push   rbp
    4b20:	mov    rbp,rsp
    4b23:	mov    rsi,QWORD PTR [rdx]
    4b26:	call   4b2b <botlish_entry_25+0xc>
			4b27: R_X86_64_PLT32	botlish_fn_25-0x4 ; is_label_char<str>
    4b2b:	mov    rsp,rbp
    4b2e:	pop    rbp
    4b2f:	ret

0000000000004b30 <botlish_fn_26: scan_local<generic>>:
    4b30:	push   rbp
    4b31:	mov    rbp,rsp
    4b34:	sub    rsp,0x20
    4b38:	mov    QWORD PTR [rsp],rbx
    4b3c:	mov    QWORD PTR [rsp+0x8],r12
    4b41:	mov    QWORD PTR [rsp+0x10],r13
    4b46:	mov    QWORD PTR [rsp+0x18],r14
    4b4b:	mov    r12,QWORD PTR [rdi]
    4b4e:	mov    rax,QWORD PTR [rdi+0x8]
    4b52:	lea    rcx,[r12+0x18]
    4b57:	cmp    rcx,rax
    4b5a:	ja     4d2e <botlish_fn_26+0x1fe>
    4b60:	lea    rax,[r12+0x18]
    4b65:	mov    QWORD PTR [rdi],rax
    4b68:	mov    r13,rdi
    4b6b:	mov    QWORD PTR [r12+0x10],0x0
    4b74:	mov    QWORD PTR [r12],rdx
    4b78:	mov    rbx,rsi
    4b7b:	mov    rsi,rdx
    4b7e:	mov    rax,QWORD PTR [rbx+0x20]
    4b82:	mov    rdx,QWORD PTR [rax]
    4b85:	mov    ecx,0x1
    4b8a:	test   rsi,0x1
    4b91:	jne    4baf <botlish_fn_26+0x7f>
    4b97:	xor    ecx,ecx
    4b99:	test   rsi,0x7
    4ba0:	jne    4baf <botlish_fn_26+0x7f>
    4ba6:	movzx  rax,BYTE PTR [rsi]
    4baa:	cmp    al,0x1
    4bac:	sete   cl
    4baf:	test   cl,cl
    4bb1:	jne    4bd5 <botlish_fn_26+0xa5>
    4bb7:	mov    rdi,r13
    4bba:	mov    rax,QWORD PTR [rdi+0x10]
    4bbe:	mov    rcx,QWORD PTR [rax+0xb8]
    4bc5:	xor    rdx,rdx
    4bc8:	call   4bcd <botlish_fn_26+0x9d>
			4bc9: R_X86_64_PLT32	rt_type_error-0x4
    4bcd:	mov    rdi,r13
    4bd0:	jmp    4c6c <botlish_fn_26+0x13c>
    4bd5:	mov    rax,rsi
    4bd8:	and    rax,rdx
    4bdb:	mov    r14,rsi
    4bde:	test   rax,0x1
    4be4:	jne    4c0a <botlish_fn_26+0xda>
    4bea:	mov    rsi,r14
    4bed:	mov    rdi,r13
    4bf0:	call   4bf5 <botlish_fn_26+0xc5>
			4bf1: R_X86_64_PLT32	rt_int_cmp-0x4
    4bf5:	mov    ecx,0x2
    4bfa:	test   rax,rax
    4bfd:	cmovge rcx,QWORD PTR [rip+0x153]        # 4d58 <botlish_fn_26+0x228>
    4c05:	jmp    4c1d <botlish_fn_26+0xed>
    4c0a:	mov    ecx,0x2
    4c0f:	mov    rsi,r14
    4c12:	cmp    rsi,rdx
    4c15:	cmovge rcx,QWORD PTR [rip+0x13b]        # 4d58 <botlish_fn_26+0x228>
    4c1d:	cmp    rcx,0x6
    4c21:	je     4d06 <botlish_fn_26+0x1d6>
    4c27:	mov    rsi,QWORD PTR [rbx+0x20]
    4c2b:	mov    rsi,QWORD PTR [rsi+0x8]
    4c2f:	mov    QWORD PTR [r12+0x8],rsi
    4c34:	mov    rdx,r14
    4c37:	mov    rdi,r13
    4c3a:	call   4c3f <botlish_fn_26+0x10f>
			4c3b: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    4c3f:	test   rax,rax
    4c42:	jne    4c50 <botlish_fn_26+0x120>
    4c48:	mov    rdi,r13
    4c4b:	jmp    4c6c <botlish_fn_26+0x13c>
    4c50:	mov    QWORD PTR [r12+0x8],rax
    4c55:	mov    rsi,rax
    4c58:	mov    rdi,r13
    4c5b:	call   4c60 <botlish_fn_26+0x130>
			4c5c: R_X86_64_PLT32	botlish_fn_24-0x4 ; is_local_char<str>
    4c60:	test   rax,rax
    4c63:	jne    4c91 <botlish_fn_26+0x161>
    4c69:	mov    rdi,r13
    4c6c:	mov    rdi,r13
    4c6f:	mov    QWORD PTR [rdi],r12
    4c72:	xor    rax,rax
    4c75:	mov    rbx,QWORD PTR [rsp]
    4c79:	mov    r12,QWORD PTR [rsp+0x8]
    4c7e:	mov    r13,QWORD PTR [rsp+0x10]
    4c83:	mov    r14,QWORD PTR [rsp+0x18]
    4c88:	add    rsp,0x20
    4c8c:	mov    rsp,rbp
    4c8f:	pop    rbp
    4c90:	ret
    4c91:	cmp    rax,0x6
    4c95:	je     4ca6 <botlish_fn_26+0x176>
    4c9b:	mov    rax,r14
    4c9e:	mov    rdi,r13
    4ca1:	jmp    4d0c <botlish_fn_26+0x1dc>
    4ca6:	mov    QWORD PTR [r12+0x8],rbx
    4cab:	mov    QWORD PTR [r12+0x10],0x3
    4cb4:	mov    rsi,r14
    4cb7:	test   rsi,0x1
    4cbe:	je     4ce4 <botlish_fn_26+0x1b4>
    4cc4:	mov    rsi,r14
    4cc7:	mov    rcx,rsi
    4cca:	add    rcx,0x2
    4cce:	seto   al
    4cd1:	test   al,al
    4cd3:	jne    4ce4 <botlish_fn_26+0x1b4>
    4cd9:	mov    rsi,rcx
    4cdc:	mov    r14,rcx
    4cdf:	jmp    4cfa <botlish_fn_26+0x1ca>
    4ce4:	mov    edx,0x3
    4ce9:	mov    rsi,r14
    4cec:	mov    rdi,r13
    4cef:	call   4cf4 <botlish_fn_26+0x1c4>
			4cf0: R_X86_64_PLT32	rt_int_add-0x4
    4cf4:	mov    rsi,rax
    4cf7:	mov    r14,rax
    4cfa:	mov    QWORD PTR [r12],rsi
    4cfe:	mov    rsi,r14
    4d01:	jmp    4b7e <botlish_fn_26+0x4e>
    4d06:	mov    rax,r14
    4d09:	mov    rdi,r13
    4d0c:	mov    rdi,r13
    4d0f:	mov    QWORD PTR [rdi],r12
    4d12:	mov    rbx,QWORD PTR [rsp]
    4d16:	mov    r12,QWORD PTR [rsp+0x8]
    4d1b:	mov    r13,QWORD PTR [rsp+0x10]
    4d20:	mov    r14,QWORD PTR [rsp+0x18]
    4d25:	add    rsp,0x20
    4d29:	mov    rsp,rbp
    4d2c:	pop    rbp
    4d2d:	ret
    4d2e:	mov    r13,rdi
    4d31:	call   4d36 <botlish_fn_26+0x206>
			4d32: R_X86_64_PLT32	rt_stack_overflow-0x4
    4d36:	xor    rax,rax
    4d39:	mov    rbx,QWORD PTR [rsp]
    4d3d:	mov    r12,QWORD PTR [rsp+0x8]
    4d42:	mov    r13,QWORD PTR [rsp+0x10]
    4d47:	mov    r14,QWORD PTR [rsp+0x18]
    4d4c:	add    rsp,0x20
    4d50:	mov    rsp,rbp
    4d53:	pop    rbp
    4d54:	ret
    4d55:	add    BYTE PTR [rax],al
    4d57:	add    BYTE PTR [rsi],al
    4d59:	add    BYTE PTR [rax],al
    4d5b:	add    BYTE PTR [rax],al
    4d5d:	add    BYTE PTR [rax],al
	...

0000000000004d60 <botlish_entry_26: scan_local<generic>>:
    4d60:	push   rbp
    4d61:	mov    rbp,rsp
    4d64:	mov    rdx,QWORD PTR [rdx]
    4d67:	call   4d6c <botlish_entry_26+0xc>
			4d68: R_X86_64_PLT32	botlish_fn_26-0x4 ; scan_local<generic>
    4d6c:	mov    rsp,rbp
    4d6f:	pop    rbp
    4d70:	ret
    4d71:	add    BYTE PTR [rax],al
    4d73:	add    BYTE PTR [rax],al
    4d75:	add    BYTE PTR [rax],al
	...

0000000000004d78 <botlish_fn_27: scan_label<generic>>:
    4d78:	push   rbp
    4d79:	mov    rbp,rsp
    4d7c:	sub    rsp,0x20
    4d80:	mov    QWORD PTR [rsp],rbx
    4d84:	mov    QWORD PTR [rsp+0x8],r12
    4d89:	mov    QWORD PTR [rsp+0x10],r13
    4d8e:	mov    QWORD PTR [rsp+0x18],r14
    4d93:	mov    r12,QWORD PTR [rdi]
    4d96:	mov    rax,QWORD PTR [rdi+0x8]
    4d9a:	lea    rcx,[r12+0x18]
    4d9f:	cmp    rcx,rax
    4da2:	ja     4f76 <botlish_fn_27+0x1fe>
    4da8:	lea    rax,[r12+0x18]
    4dad:	mov    QWORD PTR [rdi],rax
    4db0:	mov    r13,rdi
    4db3:	mov    QWORD PTR [r12+0x10],0x0
    4dbc:	mov    QWORD PTR [r12],rdx
    4dc0:	mov    rbx,rsi
    4dc3:	mov    rsi,rdx
    4dc6:	mov    rax,QWORD PTR [rbx+0x20]
    4dca:	mov    rdx,QWORD PTR [rax]
    4dcd:	mov    ecx,0x1
    4dd2:	test   rsi,0x1
    4dd9:	jne    4df7 <botlish_fn_27+0x7f>
    4ddf:	xor    ecx,ecx
    4de1:	test   rsi,0x7
    4de8:	jne    4df7 <botlish_fn_27+0x7f>
    4dee:	movzx  rax,BYTE PTR [rsi]
    4df2:	cmp    al,0x1
    4df4:	sete   cl
    4df7:	test   cl,cl
    4df9:	jne    4e1d <botlish_fn_27+0xa5>
    4dff:	mov    rdi,r13
    4e02:	mov    rax,QWORD PTR [rdi+0x10]
    4e06:	mov    rcx,QWORD PTR [rax+0xb8]
    4e0d:	xor    rdx,rdx
    4e10:	call   4e15 <botlish_fn_27+0x9d>
			4e11: R_X86_64_PLT32	rt_type_error-0x4
    4e15:	mov    rdi,r13
    4e18:	jmp    4eb4 <botlish_fn_27+0x13c>
    4e1d:	mov    rax,rsi
    4e20:	and    rax,rdx
    4e23:	mov    r14,rsi
    4e26:	test   rax,0x1
    4e2c:	jne    4e52 <botlish_fn_27+0xda>
    4e32:	mov    rsi,r14
    4e35:	mov    rdi,r13
    4e38:	call   4e3d <botlish_fn_27+0xc5>
			4e39: R_X86_64_PLT32	rt_int_cmp-0x4
    4e3d:	mov    ecx,0x2
    4e42:	test   rax,rax
    4e45:	cmovge rcx,QWORD PTR [rip+0x153]        # 4fa0 <botlish_fn_27+0x228>
    4e4d:	jmp    4e65 <botlish_fn_27+0xed>
    4e52:	mov    ecx,0x2
    4e57:	mov    rsi,r14
    4e5a:	cmp    rsi,rdx
    4e5d:	cmovge rcx,QWORD PTR [rip+0x13b]        # 4fa0 <botlish_fn_27+0x228>
    4e65:	cmp    rcx,0x6
    4e69:	je     4f4e <botlish_fn_27+0x1d6>
    4e6f:	mov    rsi,QWORD PTR [rbx+0x20]
    4e73:	mov    rsi,QWORD PTR [rsi+0x8]
    4e77:	mov    QWORD PTR [r12+0x8],rsi
    4e7c:	mov    rdx,r14
    4e7f:	mov    rdi,r13
    4e82:	call   4e87 <botlish_fn_27+0x10f>
			4e83: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    4e87:	test   rax,rax
    4e8a:	jne    4e98 <botlish_fn_27+0x120>
    4e90:	mov    rdi,r13
    4e93:	jmp    4eb4 <botlish_fn_27+0x13c>
    4e98:	mov    QWORD PTR [r12+0x8],rax
    4e9d:	mov    rsi,rax
    4ea0:	mov    rdi,r13
    4ea3:	call   4ea8 <botlish_fn_27+0x130>
			4ea4: R_X86_64_PLT32	botlish_fn_25-0x4 ; is_label_char<str>
    4ea8:	test   rax,rax
    4eab:	jne    4ed9 <botlish_fn_27+0x161>
    4eb1:	mov    rdi,r13
    4eb4:	mov    rdi,r13
    4eb7:	mov    QWORD PTR [rdi],r12
    4eba:	xor    rax,rax
    4ebd:	mov    rbx,QWORD PTR [rsp]
    4ec1:	mov    r12,QWORD PTR [rsp+0x8]
    4ec6:	mov    r13,QWORD PTR [rsp+0x10]
    4ecb:	mov    r14,QWORD PTR [rsp+0x18]
    4ed0:	add    rsp,0x20
    4ed4:	mov    rsp,rbp
    4ed7:	pop    rbp
    4ed8:	ret
    4ed9:	cmp    rax,0x6
    4edd:	je     4eee <botlish_fn_27+0x176>
    4ee3:	mov    rax,r14
    4ee6:	mov    rdi,r13
    4ee9:	jmp    4f54 <botlish_fn_27+0x1dc>
    4eee:	mov    QWORD PTR [r12+0x8],rbx
    4ef3:	mov    QWORD PTR [r12+0x10],0x3
    4efc:	mov    rsi,r14
    4eff:	test   rsi,0x1
    4f06:	je     4f2c <botlish_fn_27+0x1b4>
    4f0c:	mov    rsi,r14
    4f0f:	mov    rcx,rsi
    4f12:	add    rcx,0x2
    4f16:	seto   al
    4f19:	test   al,al
    4f1b:	jne    4f2c <botlish_fn_27+0x1b4>
    4f21:	mov    rsi,rcx
    4f24:	mov    r14,rcx
    4f27:	jmp    4f42 <botlish_fn_27+0x1ca>
    4f2c:	mov    edx,0x3
    4f31:	mov    rsi,r14
    4f34:	mov    rdi,r13
    4f37:	call   4f3c <botlish_fn_27+0x1c4>
			4f38: R_X86_64_PLT32	rt_int_add-0x4
    4f3c:	mov    rsi,rax
    4f3f:	mov    r14,rax
    4f42:	mov    QWORD PTR [r12],rsi
    4f46:	mov    rsi,r14
    4f49:	jmp    4dc6 <botlish_fn_27+0x4e>
    4f4e:	mov    rax,r14
    4f51:	mov    rdi,r13
    4f54:	mov    rdi,r13
    4f57:	mov    QWORD PTR [rdi],r12
    4f5a:	mov    rbx,QWORD PTR [rsp]
    4f5e:	mov    r12,QWORD PTR [rsp+0x8]
    4f63:	mov    r13,QWORD PTR [rsp+0x10]
    4f68:	mov    r14,QWORD PTR [rsp+0x18]
    4f6d:	add    rsp,0x20
    4f71:	mov    rsp,rbp
    4f74:	pop    rbp
    4f75:	ret
    4f76:	mov    r13,rdi
    4f79:	call   4f7e <botlish_fn_27+0x206>
			4f7a: R_X86_64_PLT32	rt_stack_overflow-0x4
    4f7e:	xor    rax,rax
    4f81:	mov    rbx,QWORD PTR [rsp]
    4f85:	mov    r12,QWORD PTR [rsp+0x8]
    4f8a:	mov    r13,QWORD PTR [rsp+0x10]
    4f8f:	mov    r14,QWORD PTR [rsp+0x18]
    4f94:	add    rsp,0x20
    4f98:	mov    rsp,rbp
    4f9b:	pop    rbp
    4f9c:	ret
    4f9d:	add    BYTE PTR [rax],al
    4f9f:	add    BYTE PTR [rsi],al
    4fa1:	add    BYTE PTR [rax],al
    4fa3:	add    BYTE PTR [rax],al
    4fa5:	add    BYTE PTR [rax],al
	...

0000000000004fa8 <botlish_entry_27: scan_label<generic>>:
    4fa8:	push   rbp
    4fa9:	mov    rbp,rsp
    4fac:	mov    rdx,QWORD PTR [rdx]
    4faf:	call   4fb4 <botlish_entry_27+0xc>
			4fb0: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_label<generic>
    4fb4:	mov    rsp,rbp
    4fb7:	pop    rbp
    4fb8:	ret
    4fb9:	add    BYTE PTR [rax],al
    4fbb:	add    BYTE PTR [rax],al
    4fbd:	add    BYTE PTR [rax],al
	...

0000000000004fc0 <botlish_fn_28: scan_alpha<generic>>:
    4fc0:	push   rbp
    4fc1:	mov    rbp,rsp
    4fc4:	sub    rsp,0x20
    4fc8:	mov    QWORD PTR [rsp],rbx
    4fcc:	mov    QWORD PTR [rsp+0x8],r12
    4fd1:	mov    QWORD PTR [rsp+0x10],r13
    4fd6:	mov    QWORD PTR [rsp+0x18],r14
    4fdb:	mov    r12,QWORD PTR [rdi]
    4fde:	mov    rax,QWORD PTR [rdi+0x8]
    4fe2:	lea    rcx,[r12+0x18]
    4fe7:	cmp    rcx,rax
    4fea:	ja     51b9 <botlish_fn_28+0x1f9>
    4ff0:	lea    rax,[r12+0x18]
    4ff5:	mov    QWORD PTR [rdi],rax
    4ff8:	mov    r13,rdi
    4ffb:	mov    QWORD PTR [r12+0x10],0x0
    5004:	mov    QWORD PTR [r12],rdx
    5008:	mov    rbx,rsi
    500b:	mov    rsi,rdx
    500e:	mov    rax,QWORD PTR [rbx+0x20]
    5012:	mov    rdx,QWORD PTR [rax]
    5015:	mov    ecx,0x1
    501a:	test   rsi,0x1
    5021:	jne    503f <botlish_fn_28+0x7f>
    5027:	xor    ecx,ecx
    5029:	test   rsi,0x7
    5030:	jne    503f <botlish_fn_28+0x7f>
    5036:	movzx  rax,BYTE PTR [rsi]
    503a:	cmp    al,0x1
    503c:	sete   cl
    503f:	test   cl,cl
    5041:	jne    5065 <botlish_fn_28+0xa5>
    5047:	mov    rdi,r13
    504a:	mov    rax,QWORD PTR [rdi+0x10]
    504e:	mov    rcx,QWORD PTR [rax+0xb8]
    5055:	xor    rdx,rdx
    5058:	call   505d <botlish_fn_28+0x9d>
			5059: R_X86_64_PLT32	rt_type_error-0x4
    505d:	mov    rdi,r13
    5060:	jmp    50f7 <botlish_fn_28+0x137>
    5065:	mov    rax,rsi
    5068:	and    rax,rdx
    506b:	mov    r14,rsi
    506e:	test   rax,0x1
    5074:	jne    509a <botlish_fn_28+0xda>
    507a:	mov    rsi,r14
    507d:	mov    rdi,r13
    5080:	call   5085 <botlish_fn_28+0xc5>
			5081: R_X86_64_PLT32	rt_int_cmp-0x4
    5085:	mov    ecx,0x2
    508a:	test   rax,rax
    508d:	cmovge rcx,QWORD PTR [rip+0x14b]        # 51e0 <botlish_fn_28+0x220>
    5095:	jmp    50ad <botlish_fn_28+0xed>
    509a:	mov    ecx,0x2
    509f:	mov    rsi,r14
    50a2:	cmp    rsi,rdx
    50a5:	cmovge rcx,QWORD PTR [rip+0x133]        # 51e0 <botlish_fn_28+0x220>
    50ad:	cmp    rcx,0x6
    50b1:	je     5191 <botlish_fn_28+0x1d1>
    50b7:	mov    rsi,QWORD PTR [rbx+0x20]
    50bb:	mov    rsi,QWORD PTR [rsi+0x8]
    50bf:	mov    QWORD PTR [r12+0x8],rsi
    50c4:	mov    rdx,r14
    50c7:	mov    rdi,r13
    50ca:	call   50cf <botlish_fn_28+0x10f>
			50cb: R_X86_64_PLT32	botlish_fn_22-0x4 ; char_at<generic>
    50cf:	test   rax,rax
    50d2:	mov    rsi,rax
    50d5:	jne    50e3 <botlish_fn_28+0x123>
    50db:	mov    rdi,r13
    50de:	jmp    50f7 <botlish_fn_28+0x137>
    50e3:	mov    rdi,r13
    50e6:	call   50eb <botlish_fn_28+0x12b>
			50e7: R_X86_64_PLT32	rt_is_tcl_alpha-0x4
    50eb:	test   rax,rax
    50ee:	jne    511c <botlish_fn_28+0x15c>
    50f4:	mov    rdi,r13
    50f7:	mov    rdi,r13
    50fa:	mov    QWORD PTR [rdi],r12
    50fd:	xor    rax,rax
    5100:	mov    rbx,QWORD PTR [rsp]
    5104:	mov    r12,QWORD PTR [rsp+0x8]
    5109:	mov    r13,QWORD PTR [rsp+0x10]
    510e:	mov    r14,QWORD PTR [rsp+0x18]
    5113:	add    rsp,0x20
    5117:	mov    rsp,rbp
    511a:	pop    rbp
    511b:	ret
    511c:	cmp    rax,0x6
    5120:	je     5131 <botlish_fn_28+0x171>
    5126:	mov    rax,r14
    5129:	mov    rdi,r13
    512c:	jmp    5197 <botlish_fn_28+0x1d7>
    5131:	mov    QWORD PTR [r12+0x8],rbx
    5136:	mov    QWORD PTR [r12+0x10],0x3
    513f:	mov    rsi,r14
    5142:	test   rsi,0x1
    5149:	je     516f <botlish_fn_28+0x1af>
    514f:	mov    rsi,r14
    5152:	mov    rcx,rsi
    5155:	add    rcx,0x2
    5159:	seto   al
    515c:	test   al,al
    515e:	jne    516f <botlish_fn_28+0x1af>
    5164:	mov    rsi,rcx
    5167:	mov    r14,rcx
    516a:	jmp    5185 <botlish_fn_28+0x1c5>
    516f:	mov    edx,0x3
    5174:	mov    rsi,r14
    5177:	mov    rdi,r13
    517a:	call   517f <botlish_fn_28+0x1bf>
			517b: R_X86_64_PLT32	rt_int_add-0x4
    517f:	mov    rsi,rax
    5182:	mov    r14,rax
    5185:	mov    QWORD PTR [r12],rsi
    5189:	mov    rsi,r14
    518c:	jmp    500e <botlish_fn_28+0x4e>
    5191:	mov    rax,r14
    5194:	mov    rdi,r13
    5197:	mov    rdi,r13
    519a:	mov    QWORD PTR [rdi],r12
    519d:	mov    rbx,QWORD PTR [rsp]
    51a1:	mov    r12,QWORD PTR [rsp+0x8]
    51a6:	mov    r13,QWORD PTR [rsp+0x10]
    51ab:	mov    r14,QWORD PTR [rsp+0x18]
    51b0:	add    rsp,0x20
    51b4:	mov    rsp,rbp
    51b7:	pop    rbp
    51b8:	ret
    51b9:	mov    r13,rdi
    51bc:	call   51c1 <botlish_fn_28+0x201>
			51bd: R_X86_64_PLT32	rt_stack_overflow-0x4
    51c1:	xor    rax,rax
    51c4:	mov    rbx,QWORD PTR [rsp]
    51c8:	mov    r12,QWORD PTR [rsp+0x8]
    51cd:	mov    r13,QWORD PTR [rsp+0x10]
    51d2:	mov    r14,QWORD PTR [rsp+0x18]
    51d7:	add    rsp,0x20
    51db:	mov    rsp,rbp
    51de:	pop    rbp
    51df:	ret
    51e0:	(bad)
    51e1:	add    BYTE PTR [rax],al
    51e3:	add    BYTE PTR [rax],al
    51e5:	add    BYTE PTR [rax],al
	...

00000000000051e8 <botlish_entry_28: scan_alpha<generic>>:
    51e8:	push   rbp
    51e9:	mov    rbp,rsp
    51ec:	mov    rdx,QWORD PTR [rdx]
    51ef:	call   51f4 <botlish_entry_28+0xc>
			51f0: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_alpha<generic>
    51f4:	mov    rsp,rbp
    51f7:	pop    rbp
    51f8:	ret
    51f9:	add    BYTE PTR [rax],al
    51fb:	add    BYTE PTR [rax],al
    51fd:	add    BYTE PTR [rax],al
	...

0000000000005200 <botlish_fn_29: tld_ok<generic>>:
    5200:	push   rbp
    5201:	mov    rbp,rsp
    5204:	sub    rsp,0x30
    5208:	mov    QWORD PTR [rsp],rbx
    520c:	mov    QWORD PTR [rsp+0x8],r12
    5211:	mov    QWORD PTR [rsp+0x10],r13
    5216:	mov    QWORD PTR [rsp+0x18],r14
    521b:	mov    QWORD PTR [rsp+0x20],r15
    5220:	mov    rbx,QWORD PTR [rdi]
    5223:	mov    rax,QWORD PTR [rdi+0x8]
    5227:	lea    rcx,[rbx+0x10]
    522b:	cmp    rcx,rax
    522e:	ja     5433 <botlish_fn_29+0x233>
    5234:	lea    rax,[rbx+0x10]
    5238:	mov    QWORD PTR [rdi],rax
    523b:	mov    r13,rdi
    523e:	mov    QWORD PTR [rbx],rdx
    5241:	mov    r8,rdx
    5244:	mov    rax,QWORD PTR [rsi+0x20]
    5248:	mov    r15,rsi
    524b:	mov    rsi,QWORD PTR [rax]
    524e:	mov    QWORD PTR [rbx+0x8],rsi
    5252:	mov    r12,r8
    5255:	mov    rdx,r12
    5258:	mov    rdi,r13
    525b:	call   5260 <botlish_fn_29+0x60>
			525c: R_X86_64_PLT32	botlish_fn_28-0x4 ; scan_alpha<generic>
    5260:	mov    rcx,rax
    5263:	mov    r14,rax
    5266:	test   rax,rcx
    5269:	jne    5277 <botlish_fn_29+0x77>
    526f:	mov    rdi,r13
    5272:	jmp    534f <botlish_fn_29+0x14f>
    5277:	mov    rax,r14
    527a:	mov    QWORD PTR [rbx+0x8],rax
    527e:	mov    rsi,r15
    5281:	mov    rax,QWORD PTR [rsi+0x20]
    5285:	mov    rdx,QWORD PTR [rax+0x8]
    5289:	mov    rax,r14
    528c:	and    rax,rdx
    528f:	test   rax,0x1
    5295:	jne    52be <botlish_fn_29+0xbe>
    529b:	mov    rsi,r14
    529e:	mov    rdi,r13
    52a1:	call   52a6 <botlish_fn_29+0xa6>
			52a2: R_X86_64_PLT32	rt_int_cmp-0x4
    52a6:	mov    ecx,0x2
    52ab:	test   rax,rax
    52ae:	cmove  rcx,QWORD PTR [rip+0x1aa]        # 5460 <botlish_fn_29+0x260>
    52b6:	mov    rax,r14
    52b9:	jmp    52d1 <botlish_fn_29+0xd1>
    52be:	mov    ecx,0x2
    52c3:	mov    rax,r14
    52c6:	cmp    rax,rdx
    52c9:	cmove  rcx,QWORD PTR [rip+0x18f]        # 5460 <botlish_fn_29+0x260>
    52d1:	cmp    rcx,0x6
    52d5:	je     52eb <botlish_fn_29+0xeb>
    52db:	mov    ecx,0x2
    52e0:	mov    rax,rcx
    52e3:	mov    rdi,r13
    52e6:	jmp    540c <botlish_fn_29+0x20c>
    52eb:	mov    ecx,0x1
    52f0:	test   r12,0x1
    52f7:	je     5305 <botlish_fn_29+0x105>
    52fd:	mov    r8,r12
    5300:	jmp    532b <botlish_fn_29+0x12b>
    5305:	xor    ecx,ecx
    5307:	test   r12,0x7
    530e:	je     531c <botlish_fn_29+0x11c>
    5314:	mov    r8,r12
    5317:	jmp    532b <botlish_fn_29+0x12b>
    531c:	movzx  rcx,BYTE PTR [r12]
    5321:	mov    r8,r12
    5324:	rex cmp cl,0x1
    5328:	sete   cl
    532b:	test   cl,cl
    532d:	jne    5379 <botlish_fn_29+0x179>
    5333:	mov    rdi,r13
    5336:	mov    rax,QWORD PTR [rdi+0x10]
    533a:	mov    rcx,QWORD PTR [rax+0x128]
    5341:	xor    rdx,rdx
    5344:	mov    rsi,r8
    5347:	call   534c <botlish_fn_29+0x14c>
			5348: R_X86_64_PLT32	rt_type_error-0x4
    534c:	mov    rdi,r13
    534f:	mov    rdi,r13
    5352:	mov    QWORD PTR [rdi],rbx
    5355:	xor    rax,rax
    5358:	mov    rbx,QWORD PTR [rsp]
    535c:	mov    r12,QWORD PTR [rsp+0x8]
    5361:	mov    r13,QWORD PTR [rsp+0x10]
    5366:	mov    r14,QWORD PTR [rsp+0x18]
    536b:	mov    r15,QWORD PTR [rsp+0x20]
    5370:	add    rsp,0x30
    5374:	mov    rsp,rbp
    5377:	pop    rbp
    5378:	ret
    5379:	mov    r12,r8
    537c:	mov    rcx,rax
    537f:	and    rcx,r12
    5382:	test   rcx,0x1
    5389:	jne    539a <botlish_fn_29+0x19a>
    538f:	mov    rdx,r8
    5392:	mov    rsi,rax
    5395:	jmp    53bb <botlish_fn_29+0x1bb>
    539a:	mov    r12,r8
    539d:	mov    rcx,rax
    53a0:	sub    rcx,r12
    53a3:	mov    r14,rax
    53a6:	seto   al
    53a9:	lea    rsi,[rcx+0x1]
    53ad:	test   al,al
    53af:	je     53c6 <botlish_fn_29+0x1c6>
    53b5:	mov    rdx,r8
    53b8:	mov    rsi,r14
    53bb:	mov    rdi,r13
    53be:	call   53c3 <botlish_fn_29+0x1c3>
			53bf: R_X86_64_PLT32	rt_int_sub-0x4
    53c3:	mov    rsi,rax
    53c6:	test   rsi,0x1
    53cd:	jne    53f8 <botlish_fn_29+0x1f8>
    53d3:	mov    edx,0x5
    53d8:	mov    rdi,r13
    53db:	call   53e0 <botlish_fn_29+0x1e0>
			53dc: R_X86_64_PLT32	rt_int_cmp-0x4
    53e0:	mov    ecx,0x2
    53e5:	test   rax,rax
    53e8:	mov    rax,rcx
    53eb:	cmovge rax,QWORD PTR [rip+0x6d]        # 5460 <botlish_fn_29+0x260>
    53f3:	jmp    5409 <botlish_fn_29+0x209>
    53f8:	mov    eax,0x2
    53fd:	cmp    rsi,0x5
    5401:	cmovge rax,QWORD PTR [rip+0x57]        # 5460 <botlish_fn_29+0x260>
    5409:	mov    rdi,r13
    540c:	mov    rdi,r13
    540f:	mov    QWORD PTR [rdi],rbx
    5412:	mov    rbx,QWORD PTR [rsp]
    5416:	mov    r12,QWORD PTR [rsp+0x8]
    541b:	mov    r13,QWORD PTR [rsp+0x10]
    5420:	mov    r14,QWORD PTR [rsp+0x18]
    5425:	mov    r15,QWORD PTR [rsp+0x20]
    542a:	add    rsp,0x30
    542e:	mov    rsp,rbp
    5431:	pop    rbp
    5432:	ret
    5433:	mov    r13,rdi
    5436:	call   543b <botlish_fn_29+0x23b>
			5437: R_X86_64_PLT32	rt_stack_overflow-0x4
    543b:	xor    rax,rax
    543e:	mov    rbx,QWORD PTR [rsp]
    5442:	mov    r12,QWORD PTR [rsp+0x8]
    5447:	mov    r13,QWORD PTR [rsp+0x10]
    544c:	mov    r14,QWORD PTR [rsp+0x18]
    5451:	mov    r15,QWORD PTR [rsp+0x20]
    5456:	add    rsp,0x30
    545a:	mov    rsp,rbp
    545d:	pop    rbp
    545e:	ret
    545f:	add    BYTE PTR [rsi],al
    5461:	add    BYTE PTR [rax],al
    5463:	add    BYTE PTR [rax],al
    5465:	add    BYTE PTR [rax],al
	...

0000000000005468 <botlish_entry_29: tld_ok<generic>>:
    5468:	push   rbp
    5469:	mov    rbp,rsp
    546c:	mov    rdx,QWORD PTR [rdx]
    546f:	call   5474 <botlish_entry_29+0xc>
			5470: R_X86_64_PLT32	botlish_fn_29-0x4 ; tld_ok<generic>
    5474:	mov    rsp,rbp
    5477:	pop    rbp
    5478:	ret
    5479:	add    BYTE PTR [rax],al
    547b:	add    BYTE PTR [rax],al
    547d:	add    BYTE PTR [rax],al
	...

0000000000005480 <botlish_fn_30: domain_loop<generic>>:
    5480:	push   rbp
    5481:	mov    rbp,rsp
    5484:	sub    rsp,0x50
    5488:	mov    QWORD PTR [rsp+0x20],rbx
    548d:	mov    QWORD PTR [rsp+0x28],r12
    5492:	mov    QWORD PTR [rsp+0x30],r13
    5497:	mov    QWORD PTR [rsp+0x38],r14
    549c:	mov    QWORD PTR [rsp+0x40],r15
    54a1:	mov    r13,QWORD PTR [rdi]
    54a4:	mov    rax,QWORD PTR [rdi+0x8]
    54a8:	lea    rcx,[r13+0x10]
    54ac:	cmp    rcx,rax
    54af:	ja     571e <botlish_fn_30+0x29e>
    54b5:	lea    rax,[r13+0x10]
    54b9:	mov    QWORD PTR [rdi],rax
    54bc:	mov    r15,rdi
    54bf:	mov    QWORD PTR [r13+0x0],rdx
    54c3:	mov    QWORD PTR [rsp+0x10],rdx
    54c8:	lea    rbx,[rsp]
    54cc:	mov    r12,rsi
    54cf:	mov    rax,QWORD PTR [r12+0x20]
    54d4:	mov    rsi,QWORD PTR [rax]
    54d7:	mov    QWORD PTR [r13+0x8],rsi
    54db:	mov    rdx,QWORD PTR [rsp+0x10]
    54e0:	mov    rdi,r15
    54e3:	call   54e8 <botlish_fn_30+0x68>
			54e4: R_X86_64_PLT32	botlish_fn_27-0x4 ; scan_label<generic>
    54e8:	mov    rcx,rax
    54eb:	mov    r14,rax
    54ee:	test   rax,rcx
    54f1:	jne    54ff <botlish_fn_30+0x7f>
    54f7:	mov    rdi,r15
    54fa:	jmp    568c <botlish_fn_30+0x20c>
    54ff:	mov    rax,r14
    5502:	mov    QWORD PTR [r13+0x0],rax
    5506:	mov    rdx,QWORD PTR [rsp+0x10]
    550b:	mov    rsi,rax
    550e:	and    rsi,rdx
    5511:	test   rsi,0x1
    5518:	jne    553f <botlish_fn_30+0xbf>
    551e:	mov    rdx,QWORD PTR [rsp+0x10]
    5523:	mov    rsi,r14
    5526:	mov    rdi,r15
    5529:	call   552e <botlish_fn_30+0xae>
			552a: R_X86_64_PLT32	rt_value_eq-0x4
    552e:	test   rax,rax
    5531:	jne    5554 <botlish_fn_30+0xd4>
    5537:	mov    rdi,r15
    553a:	jmp    568c <botlish_fn_30+0x20c>
    553f:	mov    eax,0x2
    5544:	mov    rdx,QWORD PTR [rsp+0x10]
    5549:	cmp    r14,rdx
    554c:	cmove  rax,QWORD PTR [rip+0x1fc]        # 5750 <botlish_fn_30+0x2d0>
    5554:	cmp    rax,0x6
    5558:	je     56ec <botlish_fn_30+0x26c>
    555e:	mov    rax,QWORD PTR [r12+0x20]
    5563:	mov    rdx,QWORD PTR [rax+0x8]
    5567:	mov    rax,r14
    556a:	and    rax,rdx
    556d:	test   rax,0x1
    5573:	jne    5599 <botlish_fn_30+0x119>
    5579:	mov    rsi,r14
    557c:	mov    rdi,r15
    557f:	call   5584 <botlish_fn_30+0x104>
			5580: R_X86_64_PLT32	rt_int_cmp-0x4
    5584:	mov    ecx,0x2
    5589:	test   rax,rax
    558c:	cmovge rcx,QWORD PTR [rip+0x1bc]        # 5750 <botlish_fn_30+0x2d0>
    5594:	jmp    55a9 <botlish_fn_30+0x129>
    5599:	mov    ecx,0x2
    559e:	cmp    r14,rdx
    55a1:	cmovge rcx,QWORD PTR [rip+0x1a7]        # 5750 <botlish_fn_30+0x2d0>
    55a9:	cmp    rcx,0x6
    55ad:	je     56dd <botlish_fn_30+0x25d>
    55b3:	mov    rax,QWORD PTR [r12+0x20]
    55b8:	mov    rsi,QWORD PTR [rax+0x10]
    55bc:	mov    QWORD PTR [r13+0x8],rsi
    55c0:	mov    rcx,rbx
    55c3:	mov    rdx,r14
    55c6:	mov    rdi,r15
    55c9:	call   55ce <botlish_fn_30+0x14e>
			55ca: R_X86_64_PLT32	botlish_fn_23-0x4 ; char_at<generic>
    55ce:	test   rax,rax
    55d1:	mov    rsi,rax
    55d4:	jne    55e2 <botlish_fn_30+0x162>
    55da:	mov    rdi,r15
    55dd:	jmp    568c <botlish_fn_30+0x20c>
    55e2:	mov    rdx,QWORD PTR [rsp]
    55e6:	mov    rcx,QWORD PTR [rsp+0x8]
    55eb:	mov    rdi,r15
    55ee:	mov    rax,QWORD PTR [rdi+0x10]
    55f2:	mov    r8,QWORD PTR [rax+0x118]
    55f9:	call   55fe <botlish_fn_30+0x17e>
			55fa: R_X86_64_PLT32	rt_str_region_eq-0x4
    55fe:	cmp    rax,0x6
    5602:	je     5614 <botlish_fn_30+0x194>
    5608:	mov    rax,0xffffffffffffffff
    560f:	jmp    56e4 <botlish_fn_30+0x264>
    5614:	mov    QWORD PTR [r13+0x8],0x3
    561c:	test   r14,0x1
    5623:	je     564a <botlish_fn_30+0x1ca>
    5629:	mov    rdx,r14
    562c:	add    rdx,0x2
    5630:	mov    QWORD PTR [rsp+0x10],rdx
    5635:	seto   al
    5638:	test   al,al
    563a:	jne    564a <botlish_fn_30+0x1ca>
    5640:	mov    rdx,QWORD PTR [rsp+0x10]
    5645:	jmp    5662 <botlish_fn_30+0x1e2>
    564a:	mov    edx,0x3
    564f:	mov    rsi,r14
    5652:	mov    rdi,r15
    5655:	call   565a <botlish_fn_30+0x1da>
			5656: R_X86_64_PLT32	rt_int_add-0x4
    565a:	mov    rdx,rax
    565d:	mov    QWORD PTR [rsp+0x10],rax
    5662:	mov    QWORD PTR [r13+0x0],rdx
    5666:	mov    rax,QWORD PTR [r12+0x20]
    566b:	mov    rsi,QWORD PTR [rax+0x18]
    566f:	mov    QWORD PTR [r13+0x8],rsi
    5673:	mov    rdx,QWORD PTR [rsp+0x10]
    5678:	mov    rdi,r15
    567b:	call   5680 <botlish_fn_30+0x200>
			567c: R_X86_64_PLT32	botlish_fn_29-0x4 ; tld_ok<generic>
    5680:	test   rax,rax
    5683:	jne    56b7 <botlish_fn_30+0x237>
    5689:	mov    rdi,r15
    568c:	mov    rdi,r15
    568f:	mov    QWORD PTR [rdi],r13
    5692:	xor    rax,rax
    5695:	mov    rbx,QWORD PTR [rsp+0x20]
    569a:	mov    r12,QWORD PTR [rsp+0x28]
    569f:	mov    r13,QWORD PTR [rsp+0x30]
    56a4:	mov    r14,QWORD PTR [rsp+0x38]
    56a9:	mov    r15,QWORD PTR [rsp+0x40]
    56ae:	add    rsp,0x50
    56b2:	mov    rsp,rbp
    56b5:	pop    rbp
    56b6:	ret
    56b7:	cmp    rax,0x6
    56bb:	je     56cf <botlish_fn_30+0x24f>
    56c1:	mov    rdx,QWORD PTR [rsp+0x10]
    56c6:	mov    QWORD PTR [r13+0x0],rdx
    56ca:	jmp    54cf <botlish_fn_30+0x4f>
    56cf:	mov    rax,QWORD PTR [r12+0x20]
    56d4:	mov    rax,QWORD PTR [rax+0x8]
    56d8:	jmp    56e4 <botlish_fn_30+0x264>
    56dd:	mov    rax,0xffffffffffffffff
    56e4:	mov    rdi,r15
    56e7:	jmp    56f6 <botlish_fn_30+0x276>
    56ec:	mov    rax,0xffffffffffffffff
    56f3:	mov    rdi,r15
    56f6:	mov    rdi,r15
    56f9:	mov    QWORD PTR [rdi],r13
    56fc:	mov    rbx,QWORD PTR [rsp+0x20]
    5701:	mov    r12,QWORD PTR [rsp+0x28]
    5706:	mov    r13,QWORD PTR [rsp+0x30]
    570b:	mov    r14,QWORD PTR [rsp+0x38]
    5710:	mov    r15,QWORD PTR [rsp+0x40]
    5715:	add    rsp,0x50
    5719:	mov    rsp,rbp
    571c:	pop    rbp
    571d:	ret
    571e:	mov    r15,rdi
    5721:	call   5726 <botlish_fn_30+0x2a6>
			5722: R_X86_64_PLT32	rt_stack_overflow-0x4
    5726:	xor    rax,rax
    5729:	mov    rbx,QWORD PTR [rsp+0x20]
    572e:	mov    r12,QWORD PTR [rsp+0x28]
    5733:	mov    r13,QWORD PTR [rsp+0x30]
    5738:	mov    r14,QWORD PTR [rsp+0x38]
    573d:	mov    r15,QWORD PTR [rsp+0x40]
    5742:	add    rsp,0x50
    5746:	mov    rsp,rbp
    5749:	pop    rbp
    574a:	ret
    574b:	add    BYTE PTR [rax],al
    574d:	add    BYTE PTR [rax],al
    574f:	add    BYTE PTR [rsi],al
    5751:	add    BYTE PTR [rax],al
    5753:	add    BYTE PTR [rax],al
    5755:	add    BYTE PTR [rax],al
	...

0000000000005758 <botlish_entry_30: domain_loop<generic>>:
    5758:	push   rbp
    5759:	mov    rbp,rsp
    575c:	mov    rdx,QWORD PTR [rdx]
    575f:	call   5764 <botlish_entry_30+0xc>
			5760: R_X86_64_PLT32	botlish_fn_30-0x4 ; domain_loop<generic>
    5764:	mov    rsp,rbp
    5767:	pop    rbp
    5768:	ret

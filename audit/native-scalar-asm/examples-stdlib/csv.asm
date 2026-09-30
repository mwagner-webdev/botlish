; source:  examples/stdlib/csv.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 6218  (per function: 68 365 430 664 1122 364 972 1113 413 540 167)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> peek<str, int>
;   botlish_fn_2 / botlish_entry_2 -> peek<str, int>
;   botlish_fn_3 / botlish_entry_3 -> scan_unquoted<str, int, int>
;   botlish_fn_4 / botlish_entry_4 -> scan_quoted<str, int, str>
;   botlish_fn_5 / botlish_entry_5 -> scan_field<str, int>
;   botlish_fn_6 / botlish_entry_6 -> scan_record<str, int, List[never]>
;   botlish_fn_7 / botlish_entry_7 -> scan_record<str, int, List[str]>
;   botlish_fn_8 / botlish_entry_8 -> scan_records<str, int, List[never]>
;   botlish_fn_9 / botlish_entry_9 -> scan_records<str, int, List[List[str]]>
;   botlish_fn_10 / botlish_entry_10 -> csv_parse<str>


csv.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x10
       8:	mov    r8,QWORD PTR [rdi+0x10]
       c:	mov    rsi,QWORD PTR [r8]
       f:	mov    QWORD PTR [rsp],rsi
      13:	call   18 <botlish_fn_0+0x18>
			14: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
      18:	test   rax,rax
      1b:	jne    2d <botlish_fn_0+0x2d>
      21:	xor    rax,rax
      24:	add    rsp,0x10
      28:	mov    rsp,rbp
      2b:	pop    rbp
      2c:	ret
      2d:	add    rsp,0x10
      31:	mov    rsp,rbp
      34:	pop    rbp
      35:	ret

0000000000000036 <botlish_entry_0: <program entry>>:
      36:	push   rbp
      37:	mov    rbp,rsp
      3a:	call   3f <botlish_entry_0+0x9>
			3b: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      3f:	mov    rsp,rbp
      42:	pop    rbp
      43:	ret
      44:	add    BYTE PTR [rax],al
	...

0000000000000048 <botlish_fn_1: peek<str, int>>:
      48:	push   rbp
      49:	mov    rbp,rsp
      4c:	sub    rsp,0x40
      50:	mov    QWORD PTR [rsp+0x20],rbx
      55:	mov    QWORD PTR [rsp+0x28],r12
      5a:	mov    QWORD PTR [rsp+0x30],r13
      5f:	mov    r13,rdi
      62:	mov    QWORD PTR [rsp],rsi
      66:	mov    r12,rsi
      69:	mov    QWORD PTR [rsp+0x8],rdx
      6e:	mov    rbx,rdx
      71:	mov    rsi,r12
      74:	mov    rdi,r13
      77:	call   7c <botlish_fn_1+0x34>
			78: R_X86_64_PLT32	rt_str_len-0x4
      7c:	mov    rcx,rbx
      7f:	and    rcx,rax
      82:	mov    rdx,rax
      85:	test   rcx,0x1
      8c:	jne    b2 <botlish_fn_1+0x6a>
      92:	mov    rsi,rbx
      95:	mov    rdi,r13
      98:	call   9d <botlish_fn_1+0x55>
			99: R_X86_64_PLT32	rt_int_cmp-0x4
      9d:	mov    ecx,0x2
      a2:	test   rax,rax
      a5:	cmovge rcx,QWORD PTR [rip+0xd3]        # 180 <botlish_fn_1+0x138>
      ad:	jmp    c2 <botlish_fn_1+0x7a>
      b2:	mov    ecx,0x2
      b7:	cmp    rbx,rdx
      ba:	cmovge rcx,QWORD PTR [rip+0xbe]        # 180 <botlish_fn_1+0x138>
      c2:	cmp    rcx,0x6
      c6:	je     156 <botlish_fn_1+0x10e>
      cc:	mov    QWORD PTR [rsp+0x10],0x3
      d5:	test   rbx,0x1
      dc:	je     f4 <botlish_fn_1+0xac>
      e2:	mov    rcx,rbx
      e5:	add    rcx,0x2
      e9:	seto   al
      ec:	test   al,al
      ee:	je     107 <botlish_fn_1+0xbf>
      f4:	mov    edx,0x3
      f9:	mov    rsi,rbx
      fc:	mov    rdi,r13
      ff:	call   104 <botlish_fn_1+0xbc>
			100: R_X86_64_PLT32	rt_int_add-0x4
     104:	mov    rcx,rax
     107:	mov    QWORD PTR [rsp+0x10],rcx
     10c:	mov    rdx,rbx
     10f:	mov    rsi,r12
     112:	mov    rdi,r13
     115:	call   11a <botlish_fn_1+0xd2>
			116: R_X86_64_PLT32	rt_substr-0x4
     11a:	test   rax,rax
     11d:	jne    13e <botlish_fn_1+0xf6>
     123:	xor    rax,rax
     126:	mov    rbx,QWORD PTR [rsp+0x20]
     12b:	mov    r12,QWORD PTR [rsp+0x28]
     130:	mov    r13,QWORD PTR [rsp+0x30]
     135:	add    rsp,0x40
     139:	mov    rsp,rbp
     13c:	pop    rbp
     13d:	ret
     13e:	mov    rbx,QWORD PTR [rsp+0x20]
     143:	mov    r12,QWORD PTR [rsp+0x28]
     148:	mov    r13,QWORD PTR [rsp+0x30]
     14d:	add    rsp,0x40
     151:	mov    rsp,rbp
     154:	pop    rbp
     155:	ret
     156:	mov    rdi,r13
     159:	mov    rax,QWORD PTR [rdi+0x10]
     15d:	mov    rax,QWORD PTR [rax+0x8]
     161:	mov    rbx,QWORD PTR [rsp+0x20]
     166:	mov    r12,QWORD PTR [rsp+0x28]
     16b:	mov    r13,QWORD PTR [rsp+0x30]
     170:	add    rsp,0x40
     174:	mov    rsp,rbp
     177:	pop    rbp
     178:	ret
     179:	add    BYTE PTR [rax],al
     17b:	add    BYTE PTR [rax],al
     17d:	add    BYTE PTR [rax],al
     17f:	add    BYTE PTR [rsi],al
     181:	add    BYTE PTR [rax],al
     183:	add    BYTE PTR [rax],al
     185:	add    BYTE PTR [rax],al
	...

0000000000000188 <botlish_entry_1: peek<str, int>>:
     188:	push   rbp
     189:	mov    rbp,rsp
     18c:	mov    rsi,QWORD PTR [rdx]
     18f:	mov    rdx,QWORD PTR [rdx+0x8]
     193:	call   198 <botlish_entry_1+0x10>
			194: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     198:	mov    rsp,rbp
     19b:	pop    rbp
     19c:	ret
     19d:	add    BYTE PTR [rax],al
	...

00000000000001a0 <botlish_fn_2: peek<str, int>>:
     1a0:	push   rbp
     1a1:	mov    rbp,rsp
     1a4:	sub    rsp,0x50
     1a8:	mov    QWORD PTR [rsp+0x20],rbx
     1ad:	mov    QWORD PTR [rsp+0x28],r12
     1b2:	mov    QWORD PTR [rsp+0x30],r13
     1b7:	mov    QWORD PTR [rsp+0x38],r14
     1bc:	mov    QWORD PTR [rsp+0x40],r15
     1c1:	mov    r12,rcx
     1c4:	mov    r14,rdi
     1c7:	mov    QWORD PTR [rsp],rsi
     1cb:	mov    r13,rsi
     1ce:	mov    QWORD PTR [rsp+0x8],rdx
     1d3:	mov    rbx,rdx
     1d6:	mov    rsi,r13
     1d9:	mov    rdi,r14
     1dc:	call   1e1 <botlish_fn_2+0x41>
			1dd: R_X86_64_PLT32	rt_str_len-0x4
     1e1:	mov    rcx,rbx
     1e4:	and    rcx,rax
     1e7:	mov    rdx,rax
     1ea:	test   rcx,0x1
     1f1:	jne    217 <botlish_fn_2+0x77>
     1f7:	mov    rsi,rbx
     1fa:	mov    rdi,r14
     1fd:	call   202 <botlish_fn_2+0x62>
			1fe: R_X86_64_PLT32	rt_int_cmp-0x4
     202:	mov    ecx,0x2
     207:	test   rax,rax
     20a:	cmovge rcx,QWORD PTR [rip+0x11e]        # 330 <botlish_fn_2+0x190>
     212:	jmp    227 <botlish_fn_2+0x87>
     217:	mov    ecx,0x2
     21c:	cmp    rbx,rdx
     21f:	cmovge rcx,QWORD PTR [rip+0x109]        # 330 <botlish_fn_2+0x190>
     227:	cmp    rcx,0x6
     22b:	je     2eb <botlish_fn_2+0x14b>
     231:	mov    QWORD PTR [rsp+0x10],0x3
     23a:	test   rbx,0x1
     241:	je     264 <botlish_fn_2+0xc4>
     247:	mov    rax,rbx
     24a:	add    rax,0x2
     24e:	seto   cl
     251:	test   cl,cl
     253:	jne    264 <botlish_fn_2+0xc4>
     259:	mov    rdi,r14
     25c:	mov    r15,rax
     25f:	jmp    27a <botlish_fn_2+0xda>
     264:	mov    edx,0x3
     269:	mov    rsi,rbx
     26c:	mov    rdi,r14
     26f:	call   274 <botlish_fn_2+0xd4>
			270: R_X86_64_PLT32	rt_int_add-0x4
     274:	mov    r15,rax
     277:	mov    rdi,r14
     27a:	mov    rdi,r14
     27d:	mov    rcx,r15
     280:	mov    rdx,rbx
     283:	mov    rsi,r13
     286:	call   28b <botlish_fn_2+0xeb>
			287: R_X86_64_PLT32	rt_str_region_check-0x4
     28b:	test   rax,rax
     28e:	jne    2b9 <botlish_fn_2+0x119>
     294:	xor    rax,rax
     297:	mov    rbx,QWORD PTR [rsp+0x20]
     29c:	mov    r12,QWORD PTR [rsp+0x28]
     2a1:	mov    r13,QWORD PTR [rsp+0x30]
     2a6:	mov    r14,QWORD PTR [rsp+0x38]
     2ab:	mov    r15,QWORD PTR [rsp+0x40]
     2b0:	add    rsp,0x50
     2b4:	mov    rsp,rbp
     2b7:	pop    rbp
     2b8:	ret
     2b9:	mov    rcx,r12
     2bc:	mov    QWORD PTR [rcx],rbx
     2bf:	mov    rax,r15
     2c2:	mov    QWORD PTR [rcx+0x8],rax
     2c6:	mov    rax,r13
     2c9:	mov    rbx,QWORD PTR [rsp+0x20]
     2ce:	mov    r12,QWORD PTR [rsp+0x28]
     2d3:	mov    r13,QWORD PTR [rsp+0x30]
     2d8:	mov    r14,QWORD PTR [rsp+0x38]
     2dd:	mov    r15,QWORD PTR [rsp+0x40]
     2e2:	add    rsp,0x50
     2e6:	mov    rsp,rbp
     2e9:	pop    rbp
     2ea:	ret
     2eb:	mov    rcx,r12
     2ee:	mov    rdi,r14
     2f1:	mov    rax,QWORD PTR [rdi+0x10]
     2f5:	mov    rax,QWORD PTR [rax+0x8]
     2f9:	mov    QWORD PTR [rcx],0x1
     300:	mov    QWORD PTR [rcx+0x8],0x1
     308:	mov    rbx,QWORD PTR [rsp+0x20]
     30d:	mov    r12,QWORD PTR [rsp+0x28]
     312:	mov    r13,QWORD PTR [rsp+0x30]
     317:	mov    r14,QWORD PTR [rsp+0x38]
     31c:	mov    r15,QWORD PTR [rsp+0x40]
     321:	add    rsp,0x50
     325:	mov    rsp,rbp
     328:	pop    rbp
     329:	ret
     32a:	add    BYTE PTR [rax],al
     32c:	add    BYTE PTR [rax],al
     32e:	add    BYTE PTR [rax],al
     330:	(bad)
     331:	add    BYTE PTR [rax],al
     333:	add    BYTE PTR [rax],al
     335:	add    BYTE PTR [rax],al
	...

0000000000000338 <botlish_entry_2: peek<str, int>>:
     338:	push   rbp
     339:	mov    rbp,rsp
     33c:	ud2

000000000000033e <botlish_fn_3: scan_unquoted<str, int, int>>:
     33e:	push   rbp
     33f:	mov    rbp,rsp
     342:	sub    rsp,0x90
     349:	mov    QWORD PTR [rsp+0x60],rbx
     34e:	mov    QWORD PTR [rsp+0x68],r12
     353:	mov    QWORD PTR [rsp+0x70],r13
     358:	mov    QWORD PTR [rsp+0x78],r14
     35d:	mov    QWORD PTR [rsp+0x80],r15
     365:	mov    r14,rdi
     368:	mov    QWORD PTR [rsp+0x18],0x0
     371:	mov    QWORD PTR [rsp],rsi
     375:	mov    QWORD PTR [rsp+0x40],rsi
     37a:	mov    QWORD PTR [rsp+0x8],rdx
     37f:	mov    r15,rdx
     382:	mov    QWORD PTR [rsp+0x10],rcx
     387:	lea    r13,[rsp+0x20]
     38c:	mov    QWORD PTR [rsp+0x48],rcx
     391:	mov    rcx,r13
     394:	mov    rdx,QWORD PTR [rsp+0x48]
     399:	mov    rsi,QWORD PTR [rsp+0x40]
     39e:	mov    rdi,r14
     3a1:	call   3a6 <botlish_fn_3+0x68>
			3a2: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     3a6:	mov    r10,rax
     3a9:	mov    QWORD PTR [rsp+0x50],rax
     3ae:	test   rax,r10
     3b1:	je     513 <botlish_fn_3+0x1d5>
     3b7:	mov    rbx,QWORD PTR [rsp+0x20]
     3bc:	mov    r12,QWORD PTR [rsp+0x28]
     3c1:	mov    rdi,r14
     3c4:	mov    rcx,QWORD PTR [rdi+0x10]
     3c8:	mov    r8,QWORD PTR [rcx+0x8]
     3cc:	mov    rcx,r12
     3cf:	mov    rdx,rbx
     3d2:	mov    rsi,QWORD PTR [rsp+0x50]
     3d7:	call   3dc <botlish_fn_3+0x9e>
			3d8: R_X86_64_PLT32	rt_str_region_eq-0x4
     3dc:	cmp    rax,0x6
     3e0:	je     41f <botlish_fn_3+0xe1>
     3e6:	mov    rdi,r14
     3e9:	mov    rax,QWORD PTR [rdi+0x10]
     3ed:	mov    r8,QWORD PTR [rax+0x10]
     3f1:	mov    rcx,r12
     3f4:	mov    rdx,rbx
     3f7:	mov    rsi,QWORD PTR [rsp+0x50]
     3fc:	call   401 <botlish_fn_3+0xc3>
			3fd: R_X86_64_PLT32	rt_str_region_eq-0x4
     401:	cmp    rax,0x6
     405:	je     415 <botlish_fn_3+0xd7>
     40b:	mov    eax,0x2
     410:	jmp    424 <botlish_fn_3+0xe6>
     415:	mov    eax,0x6
     41a:	jmp    424 <botlish_fn_3+0xe6>
     41f:	mov    eax,0x6
     424:	cmp    rax,0x6
     428:	je     467 <botlish_fn_3+0x129>
     42e:	mov    rdi,r14
     431:	mov    rax,QWORD PTR [rdi+0x10]
     435:	mov    r8,QWORD PTR [rax+0x18]
     439:	mov    rcx,r12
     43c:	mov    rdx,rbx
     43f:	mov    rsi,QWORD PTR [rsp+0x50]
     444:	call   449 <botlish_fn_3+0x10b>
			445: R_X86_64_PLT32	rt_str_region_eq-0x4
     449:	cmp    rax,0x6
     44d:	je     45d <botlish_fn_3+0x11f>
     453:	mov    eax,0x2
     458:	jmp    46c <botlish_fn_3+0x12e>
     45d:	mov    eax,0x6
     462:	jmp    46c <botlish_fn_3+0x12e>
     467:	mov    eax,0x6
     46c:	cmp    rax,0x6
     470:	je     4f5 <botlish_fn_3+0x1b7>
     476:	mov    QWORD PTR [rsp+0x18],0x3
     47f:	mov    rsi,QWORD PTR [rsp+0x48]
     484:	test   rsi,0x1
     48b:	je     4b9 <botlish_fn_3+0x17b>
     491:	mov    rsi,QWORD PTR [rsp+0x48]
     496:	mov    rdi,rsi
     499:	add    rdi,0x2
     49d:	seto   r9b
     4a1:	test   r9b,r9b
     4a4:	jne    4b9 <botlish_fn_3+0x17b>
     4aa:	mov    rsi,QWORD PTR [rsp+0x40]
     4af:	mov    QWORD PTR [rsp+0x48],rdi
     4b4:	jmp    4d5 <botlish_fn_3+0x197>
     4b9:	mov    edx,0x3
     4be:	mov    rsi,QWORD PTR [rsp+0x48]
     4c3:	mov    rdi,r14
     4c6:	call   4cb <botlish_fn_3+0x18d>
			4c7: R_X86_64_PLT32	rt_int_add-0x4
     4cb:	mov    rsi,QWORD PTR [rsp+0x40]
     4d0:	mov    QWORD PTR [rsp+0x48],rax
     4d5:	mov    QWORD PTR [rsp],rsi
     4d9:	mov    rdx,r15
     4dc:	mov    QWORD PTR [rsp+0x8],rdx
     4e1:	mov    rax,QWORD PTR [rsp+0x48]
     4e6:	mov    QWORD PTR [rsp+0x10],rax
     4eb:	mov    QWORD PTR [rsp+0x40],rsi
     4f0:	jmp    391 <botlish_fn_3+0x53>
     4f5:	mov    rdx,r15
     4f8:	mov    rsi,QWORD PTR [rsp+0x40]
     4fd:	mov    rcx,QWORD PTR [rsp+0x48]
     502:	mov    rdi,r14
     505:	call   50a <botlish_fn_3+0x1cc>
			506: R_X86_64_PLT32	rt_substr-0x4
     50a:	test   rax,rax
     50d:	jne    53e <botlish_fn_3+0x200>
     513:	xor    rax,rax
     516:	mov    rbx,QWORD PTR [rsp+0x60]
     51b:	mov    r12,QWORD PTR [rsp+0x68]
     520:	mov    r13,QWORD PTR [rsp+0x70]
     525:	mov    r14,QWORD PTR [rsp+0x78]
     52a:	mov    r15,QWORD PTR [rsp+0x80]
     532:	add    rsp,0x90
     539:	mov    rsp,rbp
     53c:	pop    rbp
     53d:	ret
     53e:	mov    QWORD PTR [rsp],rax
     542:	lea    rcx,[rsp+0x30]
     547:	mov    QWORD PTR [rsp+0x30],rax
     54c:	mov    rsi,QWORD PTR [rsp+0x48]
     551:	mov    QWORD PTR [rsp+0x38],rsi
     556:	mov    esi,0x1
     55b:	mov    edx,0x2
     560:	mov    rdi,r14
     563:	call   568 <botlish_fn_3+0x22a>
			564: R_X86_64_PLT32	rt_struct_new-0x4
     568:	mov    rbx,QWORD PTR [rsp+0x60]
     56d:	mov    r12,QWORD PTR [rsp+0x68]
     572:	mov    r13,QWORD PTR [rsp+0x70]
     577:	mov    r14,QWORD PTR [rsp+0x78]
     57c:	mov    r15,QWORD PTR [rsp+0x80]
     584:	add    rsp,0x90
     58b:	mov    rsp,rbp
     58e:	pop    rbp
     58f:	ret

0000000000000590 <botlish_entry_3: scan_unquoted<str, int, int>>:
     590:	push   rbp
     591:	mov    rbp,rsp
     594:	mov    rsi,QWORD PTR [rdx]
     597:	mov    r8,QWORD PTR [rdx+0x8]
     59b:	mov    rcx,QWORD PTR [rdx+0x10]
     59f:	mov    rdx,r8
     5a2:	call   5a7 <botlish_entry_3+0x17>
			5a3: R_X86_64_PLT32	botlish_fn_3-0x4 ; scan_unquoted<str, int, int>
     5a7:	mov    rsp,rbp
     5aa:	pop    rbp
     5ab:	ret

00000000000005ac <botlish_fn_4: scan_quoted<str, int, str>>:
     5ac:	push   rbp
     5ad:	mov    rbp,rsp
     5b0:	sub    rsp,0xe0
     5b7:	mov    QWORD PTR [rsp+0xb0],rbx
     5bf:	mov    QWORD PTR [rsp+0xb8],r12
     5c7:	mov    QWORD PTR [rsp+0xc0],r13
     5cf:	mov    QWORD PTR [rsp+0xc8],r14
     5d7:	mov    QWORD PTR [rsp+0xd0],r15
     5df:	mov    r14,rdi
     5e2:	mov    QWORD PTR [rsp+0x18],0x0
     5eb:	mov    QWORD PTR [rsp+0x20],0x0
     5f4:	mov    QWORD PTR [rsp],rsi
     5f8:	mov    QWORD PTR [rsp+0x8],rdx
     5fd:	mov    QWORD PTR [rsp+0x10],rcx
     602:	mov    r12,rcx
     605:	lea    r13,[rsp+0x78]
     60a:	lea    rbx,[rsp+0x28]
     60f:	mov    r15,rsi
     612:	mov    QWORD PTR [rsp+0x98],rdx
     61a:	mov    rdx,QWORD PTR [rsp+0x98]
     622:	mov    rsi,r15
     625:	mov    rdi,r14
     628:	call   62d <botlish_fn_4+0x81>
			629: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     62d:	test   rax,rax
     630:	je     952 <botlish_fn_4+0x3a6>
     636:	mov    QWORD PTR [rsp+0x18],rax
     63b:	mov    rdi,r14
     63e:	mov    QWORD PTR [rsp+0xa0],rax
     646:	mov    rdi,QWORD PTR [rdi+0x10]
     64a:	mov    rsi,QWORD PTR [rdi+0x20]
     64e:	mov    edx,0x1
     653:	mov    ecx,0x3
     658:	mov    rdi,r14
     65b:	mov    r8,QWORD PTR [rsp+0xa0]
     663:	call   668 <botlish_fn_4+0xbc>
			664: R_X86_64_PLT32	rt_str_region_eq-0x4
     668:	cmp    rax,0x6
     66c:	je     730 <botlish_fn_4+0x184>
     672:	mov    QWORD PTR [rsp+0x20],0x3
     67b:	mov    rsi,QWORD PTR [rsp+0x98]
     683:	test   rsi,0x1
     68a:	je     6aa <botlish_fn_4+0xfe>
     690:	mov    rcx,rsi
     693:	add    rcx,0x2
     697:	seto   al
     69a:	test   al,al
     69c:	jne    6aa <botlish_fn_4+0xfe>
     6a2:	mov    rsi,rcx
     6a5:	jmp    6ba <botlish_fn_4+0x10e>
     6aa:	mov    edx,0x3
     6af:	mov    rdi,r14
     6b2:	call   6b7 <botlish_fn_4+0x10b>
			6b3: R_X86_64_PLT32	rt_int_add-0x4
     6b7:	mov    rsi,rax
     6ba:	mov    QWORD PTR [rsp+0x8],rsi
     6bf:	mov    QWORD PTR [rsp+0x98],rsi
     6c7:	mov    QWORD PTR [rsp+0x78],0x0
     6d0:	mov    QWORD PTR [rsp+0x80],r12
     6d8:	mov    QWORD PTR [rsp+0x88],0x0
     6e4:	mov    rax,QWORD PTR [rsp+0xa0]
     6ec:	mov    QWORD PTR [rsp+0x90],rax
     6f4:	mov    esi,0x2
     6f9:	mov    edx,0x4
     6fe:	mov    rcx,r13
     701:	mov    rdi,r14
     704:	call   709 <botlish_fn_4+0x15d>
			705: R_X86_64_PLT32	rt_construct-0x4
     709:	test   rax,rax
     70c:	je     952 <botlish_fn_4+0x3a6>
     712:	mov    QWORD PTR [rsp],r15
     716:	mov    rsi,QWORD PTR [rsp+0x98]
     71e:	mov    QWORD PTR [rsp+0x8],rsi
     723:	mov    QWORD PTR [rsp+0x10],rax
     728:	mov    r12,rax
     72b:	jmp    61a <botlish_fn_4+0x6e>
     730:	mov    QWORD PTR [rsp+0x18],0x3
     739:	mov    rsi,QWORD PTR [rsp+0x98]
     741:	test   rsi,0x1
     748:	je     768 <botlish_fn_4+0x1bc>
     74e:	mov    rsi,QWORD PTR [rsp+0x98]
     756:	mov    rdx,rsi
     759:	add    rdx,0x2
     75d:	seto   al
     760:	test   al,al
     762:	je     780 <botlish_fn_4+0x1d4>
     768:	mov    edx,0x3
     76d:	mov    rsi,QWORD PTR [rsp+0x98]
     775:	mov    rdi,r14
     778:	call   77d <botlish_fn_4+0x1d1>
			779: R_X86_64_PLT32	rt_int_add-0x4
     77d:	mov    rdx,rax
     780:	mov    QWORD PTR [rsp+0x18],rdx
     785:	mov    rcx,rbx
     788:	mov    rsi,r15
     78b:	mov    rdi,r14
     78e:	call   793 <botlish_fn_4+0x1e7>
			78f: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     793:	test   rax,rax
     796:	mov    rsi,rax
     799:	je     952 <botlish_fn_4+0x3a6>
     79f:	mov    rdx,QWORD PTR [rsp+0x28]
     7a4:	mov    rcx,QWORD PTR [rsp+0x30]
     7a9:	mov    rdi,r14
     7ac:	mov    rax,QWORD PTR [rdi+0x10]
     7b0:	mov    r8,QWORD PTR [rax+0x20]
     7b4:	call   7b9 <botlish_fn_4+0x20d>
			7b5: R_X86_64_PLT32	rt_str_region_eq-0x4
     7b9:	cmp    rax,0x6
     7bd:	je     8a0 <botlish_fn_4+0x2f4>
     7c3:	xor    rsi,rsi
     7c6:	lea    rcx,[rsp+0x58]
     7cb:	mov    QWORD PTR [rsp+0x58],0x0
     7d4:	mov    QWORD PTR [rsp+0x60],r12
     7d9:	mov    edx,0x2
     7de:	mov    rdi,r14
     7e1:	call   7e6 <botlish_fn_4+0x23a>
			7e2: R_X86_64_PLT32	rt_construct-0x4
     7e6:	test   rax,rax
     7e9:	je     952 <botlish_fn_4+0x3a6>
     7ef:	mov    QWORD PTR [rsp],rax
     7f3:	mov    rbx,rax
     7f6:	mov    QWORD PTR [rsp+0x10],0x3
     7ff:	mov    rsi,QWORD PTR [rsp+0x98]
     807:	test   rsi,0x1
     80e:	je     82e <botlish_fn_4+0x282>
     814:	mov    rsi,QWORD PTR [rsp+0x98]
     81c:	mov    rax,rsi
     81f:	add    rax,0x2
     823:	seto   cl
     826:	test   cl,cl
     828:	je     843 <botlish_fn_4+0x297>
     82e:	mov    edx,0x3
     833:	mov    rsi,QWORD PTR [rsp+0x98]
     83b:	mov    rdi,r14
     83e:	call   843 <botlish_fn_4+0x297>
			83f: R_X86_64_PLT32	rt_int_add-0x4
     843:	mov    QWORD PTR [rsp+0x8],rax
     848:	lea    rcx,[rsp+0x68]
     84d:	mov    rdx,rbx
     850:	mov    QWORD PTR [rsp+0x68],rdx
     855:	mov    QWORD PTR [rsp+0x70],rax
     85a:	mov    esi,0x1
     85f:	mov    edx,0x2
     864:	mov    rdi,r14
     867:	call   86c <botlish_fn_4+0x2c0>
			868: R_X86_64_PLT32	rt_struct_new-0x4
     86c:	mov    rbx,QWORD PTR [rsp+0xb0]
     874:	mov    r12,QWORD PTR [rsp+0xb8]
     87c:	mov    r13,QWORD PTR [rsp+0xc0]
     884:	mov    r14,QWORD PTR [rsp+0xc8]
     88c:	mov    r15,QWORD PTR [rsp+0xd0]
     894:	add    rsp,0xe0
     89b:	mov    rsp,rbp
     89e:	pop    rbp
     89f:	ret
     8a0:	mov    QWORD PTR [rsp+0x18],0x5
     8a9:	mov    rsi,QWORD PTR [rsp+0x98]
     8b1:	test   rsi,0x1
     8b8:	je     8e4 <botlish_fn_4+0x338>
     8be:	mov    rsi,QWORD PTR [rsp+0x98]
     8c6:	add    rsi,0x4
     8ca:	seto   r8b
     8ce:	test   r8b,r8b
     8d1:	jne    8e4 <botlish_fn_4+0x338>
     8d7:	mov    QWORD PTR [rsp+0x98],rsi
     8df:	jmp    904 <botlish_fn_4+0x358>
     8e4:	mov    edx,0x5
     8e9:	mov    rsi,QWORD PTR [rsp+0x98]
     8f1:	mov    rdi,r14
     8f4:	call   8f9 <botlish_fn_4+0x34d>
			8f5: R_X86_64_PLT32	rt_int_add-0x4
     8f9:	mov    rsi,rax
     8fc:	mov    QWORD PTR [rsp+0x98],rax
     904:	mov    QWORD PTR [rsp+0x8],rsi
     909:	mov    rdi,r14
     90c:	mov    rax,QWORD PTR [rdi+0x10]
     910:	mov    rax,QWORD PTR [rax+0x20]
     914:	mov    QWORD PTR [rsp+0x18],rax
     919:	lea    rcx,[rsp+0x38]
     91e:	mov    QWORD PTR [rsp+0x38],0x0
     927:	mov    QWORD PTR [rsp+0x40],r12
     92c:	mov    QWORD PTR [rsp+0x48],0x0
     935:	mov    QWORD PTR [rsp+0x50],rax
     93a:	mov    esi,0x2
     93f:	mov    edx,0x4
     944:	call   949 <botlish_fn_4+0x39d>
			945: R_X86_64_PLT32	rt_construct-0x4
     949:	test   rax,rax
     94c:	jne    989 <botlish_fn_4+0x3dd>
     952:	xor    rax,rax
     955:	mov    rbx,QWORD PTR [rsp+0xb0]
     95d:	mov    r12,QWORD PTR [rsp+0xb8]
     965:	mov    r13,QWORD PTR [rsp+0xc0]
     96d:	mov    r14,QWORD PTR [rsp+0xc8]
     975:	mov    r15,QWORD PTR [rsp+0xd0]
     97d:	add    rsp,0xe0
     984:	mov    rsp,rbp
     987:	pop    rbp
     988:	ret
     989:	mov    QWORD PTR [rsp],r15
     98d:	mov    rsi,QWORD PTR [rsp+0x98]
     995:	mov    QWORD PTR [rsp+0x8],rsi
     99a:	mov    QWORD PTR [rsp+0x10],rax
     99f:	mov    r12,rax
     9a2:	jmp    61a <botlish_fn_4+0x6e>

00000000000009a7 <botlish_entry_4: scan_quoted<str, int, str>>:
     9a7:	push   rbp
     9a8:	mov    rbp,rsp
     9ab:	mov    rsi,QWORD PTR [rdx]
     9ae:	mov    r8,QWORD PTR [rdx+0x8]
     9b2:	mov    rcx,QWORD PTR [rdx+0x10]
     9b6:	mov    rdx,r8
     9b9:	call   9be <botlish_entry_4+0x17>
			9ba: R_X86_64_PLT32	botlish_fn_4-0x4 ; scan_quoted<str, int, str>
     9be:	mov    rsp,rbp
     9c1:	pop    rbp
     9c2:	ret

00000000000009c3 <botlish_fn_5: scan_field<str, int>>:
     9c3:	push   rbp
     9c4:	mov    rbp,rsp
     9c7:	sub    rsp,0x50
     9cb:	mov    QWORD PTR [rsp+0x30],rbx
     9d0:	mov    QWORD PTR [rsp+0x38],r12
     9d5:	mov    QWORD PTR [rsp+0x40],r13
     9da:	mov    r12,rdi
     9dd:	mov    r13,rdx
     9e0:	mov    QWORD PTR [rsp+0x10],0x0
     9e9:	mov    QWORD PTR [rsp],rsi
     9ed:	mov    rbx,rsi
     9f0:	mov    QWORD PTR [rsp+0x8],rdx
     9f5:	lea    rcx,[rsp+0x18]
     9fa:	mov    rdx,r13
     9fd:	mov    rsi,rbx
     a00:	mov    rdi,r12
     a03:	call   a08 <botlish_fn_5+0x45>
			a04: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     a08:	test   rax,rax
     a0b:	mov    rsi,rax
     a0e:	je     ad9 <botlish_fn_5+0x116>
     a14:	mov    rdx,QWORD PTR [rsp+0x18]
     a19:	mov    rcx,QWORD PTR [rsp+0x20]
     a1e:	mov    rdi,r12
     a21:	mov    rax,QWORD PTR [rdi+0x10]
     a25:	mov    r8,QWORD PTR [rax+0x20]
     a29:	call   a2e <botlish_fn_5+0x6b>
			a2a: R_X86_64_PLT32	rt_str_region_eq-0x4
     a2e:	cmp    rax,0x6
     a32:	je     a6a <botlish_fn_5+0xa7>
     a38:	mov    rcx,r13
     a3b:	mov    rsi,rbx
     a3e:	mov    rdi,r12
     a41:	mov    rdx,rcx
     a44:	call   a49 <botlish_fn_5+0x86>
			a45: R_X86_64_PLT32	botlish_fn_3-0x4 ; scan_unquoted<str, int, int>
     a49:	test   rax,rax
     a4c:	je     ad9 <botlish_fn_5+0x116>
     a52:	mov    rbx,QWORD PTR [rsp+0x30]
     a57:	mov    r12,QWORD PTR [rsp+0x38]
     a5c:	mov    r13,QWORD PTR [rsp+0x40]
     a61:	add    rsp,0x50
     a65:	mov    rsp,rbp
     a68:	pop    rbp
     a69:	ret
     a6a:	mov    rcx,r13
     a6d:	mov    QWORD PTR [rsp+0x10],0x3
     a76:	test   rcx,0x1
     a7d:	jne    a8b <botlish_fn_5+0xc8>
     a83:	mov    r13,rcx
     a86:	jmp    aa0 <botlish_fn_5+0xdd>
     a8b:	mov    rdx,rcx
     a8e:	add    rdx,0x2
     a92:	mov    r13,rcx
     a95:	seto   al
     a98:	test   al,al
     a9a:	je     ab3 <botlish_fn_5+0xf0>
     aa0:	mov    edx,0x3
     aa5:	mov    rsi,r13
     aa8:	mov    rdi,r12
     aab:	call   ab0 <botlish_fn_5+0xed>
			aac: R_X86_64_PLT32	rt_int_add-0x4
     ab0:	mov    rdx,rax
     ab3:	mov    QWORD PTR [rsp+0x8],rdx
     ab8:	mov    rdi,r12
     abb:	mov    rax,QWORD PTR [rdi+0x10]
     abf:	mov    rcx,QWORD PTR [rax+0x8]
     ac3:	mov    QWORD PTR [rsp+0x10],rcx
     ac8:	mov    rsi,rbx
     acb:	call   ad0 <botlish_fn_5+0x10d>
			acc: R_X86_64_PLT32	botlish_fn_4-0x4 ; scan_quoted<str, int, str>
     ad0:	test   rax,rax
     ad3:	jne    af4 <botlish_fn_5+0x131>
     ad9:	xor    rax,rax
     adc:	mov    rbx,QWORD PTR [rsp+0x30]
     ae1:	mov    r12,QWORD PTR [rsp+0x38]
     ae6:	mov    r13,QWORD PTR [rsp+0x40]
     aeb:	add    rsp,0x50
     aef:	mov    rsp,rbp
     af2:	pop    rbp
     af3:	ret
     af4:	mov    rbx,QWORD PTR [rsp+0x30]
     af9:	mov    r12,QWORD PTR [rsp+0x38]
     afe:	mov    r13,QWORD PTR [rsp+0x40]
     b03:	add    rsp,0x50
     b07:	mov    rsp,rbp
     b0a:	pop    rbp
     b0b:	ret

0000000000000b0c <botlish_entry_5: scan_field<str, int>>:
     b0c:	push   rbp
     b0d:	mov    rbp,rsp
     b10:	mov    rsi,QWORD PTR [rdx]
     b13:	mov    rdx,QWORD PTR [rdx+0x8]
     b17:	call   b1c <botlish_entry_5+0x10>
			b18: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     b1c:	mov    rsp,rbp
     b1f:	pop    rbp
     b20:	ret

0000000000000b21 <botlish_fn_6: scan_record<str, int, List[never]>>:
     b21:	push   rbp
     b22:	mov    rbp,rsp
     b25:	sub    rsp,0xc0
     b2c:	mov    QWORD PTR [rsp+0x90],rbx
     b34:	mov    QWORD PTR [rsp+0x98],r12
     b3c:	mov    QWORD PTR [rsp+0xa0],r13
     b44:	mov    QWORD PTR [rsp+0xa8],r14
     b4c:	mov    QWORD PTR [rsp+0xb0],r15
     b54:	mov    r13,rdi
     b57:	mov    QWORD PTR [rsp+0x18],0x0
     b60:	mov    QWORD PTR [rsp+0x20],0x0
     b69:	mov    QWORD PTR [rsp],rsi
     b6d:	mov    r14,rsi
     b70:	mov    QWORD PTR [rsp+0x8],rdx
     b75:	mov    QWORD PTR [rsp+0x10],rcx
     b7a:	mov    QWORD PTR [rsp+0x78],rcx
     b7f:	mov    rsi,r14
     b82:	mov    rdi,r13
     b85:	call   b8a <botlish_fn_6+0x69>
			b86: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     b8a:	test   rax,rax
     b8d:	je     e25 <botlish_fn_6+0x304>
     b93:	mov    rcx,QWORD PTR [rax+0x18]
     b97:	mov    rdx,QWORD PTR [rcx]
     b9a:	mov    QWORD PTR [rsp+0x8],rdx
     b9f:	mov    QWORD PTR [rsp+0x88],rdx
     ba7:	mov    rax,QWORD PTR [rax+0x18]
     bab:	mov    rsi,QWORD PTR [rax+0x8]
     baf:	mov    QWORD PTR [rsp+0x18],rsi
     bb4:	mov    r15,rsi
     bb7:	lea    rcx,[rsp+0x28]
     bbc:	mov    rdx,r15
     bbf:	mov    rsi,r14
     bc2:	mov    rdi,r13
     bc5:	call   bca <botlish_fn_6+0xa9>
			bc6: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     bca:	test   rax,rax
     bcd:	mov    QWORD PTR [rsp+0x80],rax
     bd5:	je     e25 <botlish_fn_6+0x304>
     bdb:	mov    r12,QWORD PTR [rsp+0x28]
     be0:	mov    rbx,QWORD PTR [rsp+0x30]
     be5:	mov    rdi,r13
     be8:	mov    rcx,QWORD PTR [rdi+0x10]
     bec:	mov    r8,QWORD PTR [rcx+0x10]
     bf0:	mov    rcx,rbx
     bf3:	mov    rdx,r12
     bf6:	mov    rsi,QWORD PTR [rsp+0x80]
     bfe:	call   c03 <botlish_fn_6+0xe2>
			bff: R_X86_64_PLT32	rt_str_region_eq-0x4
     c03:	cmp    rax,0x6
     c07:	je     d6b <botlish_fn_6+0x24a>
     c0d:	mov    rdi,r13
     c10:	mov    rcx,QWORD PTR [rdi+0x10]
     c14:	mov    r8,QWORD PTR [rcx+0x18]
     c18:	mov    rcx,rbx
     c1b:	mov    rdx,r12
     c1e:	mov    rsi,QWORD PTR [rsp+0x80]
     c26:	call   c2b <botlish_fn_6+0x10a>
			c27: R_X86_64_PLT32	rt_str_region_eq-0x4
     c2b:	cmp    rax,0x6
     c2f:	je     cad <botlish_fn_6+0x18c>
     c35:	mov    rdx,QWORD PTR [rsp+0x88]
     c3d:	mov    rsi,QWORD PTR [rsp+0x78]
     c42:	mov    rdi,r13
     c45:	call   c4a <botlish_fn_6+0x129>
			c46: R_X86_64_PLT32	rt_list_append-0x4
     c4a:	test   rax,rax
     c4d:	je     e25 <botlish_fn_6+0x304>
     c53:	mov    QWORD PTR [rsp],rax
     c57:	lea    rcx,[rsp+0x68]
     c5c:	mov    QWORD PTR [rsp+0x68],rax
     c61:	mov    rsi,r15
     c64:	mov    QWORD PTR [rsp+0x70],rsi
     c69:	xor    rsi,rsi
     c6c:	mov    edx,0x2
     c71:	mov    rdi,r13
     c74:	call   c79 <botlish_fn_6+0x158>
			c75: R_X86_64_PLT32	rt_struct_new-0x4
     c79:	mov    rbx,QWORD PTR [rsp+0x90]
     c81:	mov    r12,QWORD PTR [rsp+0x98]
     c89:	mov    r13,QWORD PTR [rsp+0xa0]
     c91:	mov    r14,QWORD PTR [rsp+0xa8]
     c99:	mov    r15,QWORD PTR [rsp+0xb0]
     ca1:	add    rsp,0xc0
     ca8:	mov    rsp,rbp
     cab:	pop    rbp
     cac:	ret
     cad:	mov    rdx,QWORD PTR [rsp+0x88]
     cb5:	mov    rsi,QWORD PTR [rsp+0x78]
     cba:	mov    rdi,r13
     cbd:	call   cc2 <botlish_fn_6+0x1a1>
			cbe: R_X86_64_PLT32	rt_list_append-0x4
     cc2:	test   rax,rax
     cc5:	je     e25 <botlish_fn_6+0x304>
     ccb:	mov    QWORD PTR [rsp],rax
     ccf:	mov    rbx,rax
     cd2:	mov    QWORD PTR [rsp+0x8],0x3
     cdb:	mov    rsi,r15
     cde:	test   rsi,0x1
     ce5:	je     d00 <botlish_fn_6+0x1df>
     ceb:	mov    rsi,r15
     cee:	mov    rax,rsi
     cf1:	add    rax,0x2
     cf5:	seto   cl
     cf8:	test   cl,cl
     cfa:	je     d10 <botlish_fn_6+0x1ef>
     d00:	mov    edx,0x3
     d05:	mov    rsi,r15
     d08:	mov    rdi,r13
     d0b:	call   d10 <botlish_fn_6+0x1ef>
			d0c: R_X86_64_PLT32	rt_int_add-0x4
     d10:	mov    QWORD PTR [rsp+0x8],rax
     d15:	lea    rcx,[rsp+0x58]
     d1a:	mov    rdx,rbx
     d1d:	mov    QWORD PTR [rsp+0x58],rdx
     d22:	mov    QWORD PTR [rsp+0x60],rax
     d27:	xor    rsi,rsi
     d2a:	mov    edx,0x2
     d2f:	mov    rdi,r13
     d32:	call   d37 <botlish_fn_6+0x216>
			d33: R_X86_64_PLT32	rt_struct_new-0x4
     d37:	mov    rbx,QWORD PTR [rsp+0x90]
     d3f:	mov    r12,QWORD PTR [rsp+0x98]
     d47:	mov    r13,QWORD PTR [rsp+0xa0]
     d4f:	mov    r14,QWORD PTR [rsp+0xa8]
     d57:	mov    r15,QWORD PTR [rsp+0xb0]
     d5f:	add    rsp,0xc0
     d66:	mov    rsp,rbp
     d69:	pop    rbp
     d6a:	ret
     d6b:	mov    ebx,0x3
     d70:	mov    QWORD PTR [rsp+0x20],0x3
     d79:	mov    rsi,r15
     d7c:	test   rsi,0x1
     d83:	jne    d91 <botlish_fn_6+0x270>
     d89:	mov    rsi,r15
     d8c:	jmp    da9 <botlish_fn_6+0x288>
     d91:	mov    rsi,r15
     d94:	mov    rdx,rsi
     d97:	add    rdx,0x2
     d9b:	seto   al
     d9e:	test   al,al
     da0:	je     db7 <botlish_fn_6+0x296>
     da6:	mov    rsi,r15
     da9:	mov    rdx,rbx
     dac:	mov    rdi,r13
     daf:	call   db4 <botlish_fn_6+0x293>
			db0: R_X86_64_PLT32	rt_int_add-0x4
     db4:	mov    rdx,rax
     db7:	mov    QWORD PTR [rsp+0x18],rdx
     dbc:	mov    r15,rdx
     dbf:	lea    rcx,[rsp+0x38]
     dc4:	mov    QWORD PTR [rsp+0x38],0x0
     dcd:	mov    rsi,QWORD PTR [rsp+0x78]
     dd2:	mov    QWORD PTR [rsp+0x40],rsi
     dd7:	mov    QWORD PTR [rsp+0x48],0x2
     de0:	mov    rdx,QWORD PTR [rsp+0x88]
     de8:	mov    QWORD PTR [rsp+0x50],rdx
     ded:	mov    edx,0x4
     df2:	mov    rsi,rbx
     df5:	mov    rdi,r13
     df8:	call   dfd <botlish_fn_6+0x2dc>
			df9: R_X86_64_PLT32	rt_construct-0x4
     dfd:	test   rax,rax
     e00:	je     e25 <botlish_fn_6+0x304>
     e06:	mov    QWORD PTR [rsp+0x8],rax
     e0b:	mov    rcx,rax
     e0e:	mov    rdx,r15
     e11:	mov    rsi,r14
     e14:	mov    rdi,r13
     e17:	call   e1c <botlish_fn_6+0x2fb>
			e18: R_X86_64_PLT32	botlish_fn_7-0x4 ; scan_record<str, int, List[str]>
     e1c:	test   rax,rax
     e1f:	jne    e5c <botlish_fn_6+0x33b>
     e25:	xor    rax,rax
     e28:	mov    rbx,QWORD PTR [rsp+0x90]
     e30:	mov    r12,QWORD PTR [rsp+0x98]
     e38:	mov    r13,QWORD PTR [rsp+0xa0]
     e40:	mov    r14,QWORD PTR [rsp+0xa8]
     e48:	mov    r15,QWORD PTR [rsp+0xb0]
     e50:	add    rsp,0xc0
     e57:	mov    rsp,rbp
     e5a:	pop    rbp
     e5b:	ret
     e5c:	mov    rbx,QWORD PTR [rsp+0x90]
     e64:	mov    r12,QWORD PTR [rsp+0x98]
     e6c:	mov    r13,QWORD PTR [rsp+0xa0]
     e74:	mov    r14,QWORD PTR [rsp+0xa8]
     e7c:	mov    r15,QWORD PTR [rsp+0xb0]
     e84:	add    rsp,0xc0
     e8b:	mov    rsp,rbp
     e8e:	pop    rbp
     e8f:	ret

0000000000000e90 <botlish_entry_6: scan_record<str, int, List[never]>>:
     e90:	push   rbp
     e91:	mov    rbp,rsp
     e94:	mov    rsi,QWORD PTR [rdx]
     e97:	mov    r8,QWORD PTR [rdx+0x8]
     e9b:	mov    rcx,QWORD PTR [rdx+0x10]
     e9f:	mov    rdx,r8
     ea2:	call   ea7 <botlish_entry_6+0x17>
			ea3: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
     ea7:	mov    rsp,rbp
     eaa:	pop    rbp
     eab:	ret

0000000000000eac <botlish_fn_7: scan_record<str, int, List[str]>>:
     eac:	push   rbp
     ead:	mov    rbp,rsp
     eb0:	sub    rsp,0x110
     eb7:	mov    QWORD PTR [rsp+0xe0],rbx
     ebf:	mov    QWORD PTR [rsp+0xe8],r12
     ec7:	mov    QWORD PTR [rsp+0xf0],r13
     ecf:	mov    QWORD PTR [rsp+0xf8],r14
     ed7:	mov    QWORD PTR [rsp+0x100],r15
     edf:	mov    QWORD PTR [rsp+0xb8],rdi
     ee7:	mov    QWORD PTR [rsp+0x18],0x0
     ef0:	mov    QWORD PTR [rsp+0x20],0x0
     ef9:	mov    QWORD PTR [rsp],rsi
     efd:	mov    QWORD PTR [rsp+0x8],rdx
     f02:	mov    QWORD PTR [rsp+0xc0],rdx
     f0a:	mov    QWORD PTR [rsp+0x10],rcx
     f0f:	mov    QWORD PTR [rsp+0xc8],rcx
     f17:	lea    rbx,[rsp+0x28]
     f1c:	mov    r12,rsi
     f1f:	mov    rsi,r12
     f22:	mov    rdi,QWORD PTR [rsp+0xb8]
     f2a:	call   f2f <botlish_fn_7+0x83>
			f2b: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     f2f:	test   rax,rax
     f32:	je     1273 <botlish_fn_7+0x3c7>
     f38:	mov    rcx,QWORD PTR [rax+0x18]
     f3c:	mov    r15,QWORD PTR [rcx]
     f3f:	mov    QWORD PTR [rsp+0x8],r15
     f44:	mov    rcx,QWORD PTR [rax+0x18]
     f48:	mov    rsi,QWORD PTR [rcx+0x8]
     f4c:	mov    QWORD PTR [rsp+0x18],rsi
     f51:	mov    QWORD PTR [rsp+0xd8],rsi
     f59:	mov    rcx,rbx
     f5c:	mov    rdx,QWORD PTR [rsp+0xd8]
     f64:	mov    rsi,r12
     f67:	mov    rdi,QWORD PTR [rsp+0xb8]
     f6f:	call   f74 <botlish_fn_7+0xc8>
			f70: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     f74:	test   rax,rax
     f77:	mov    QWORD PTR [rsp+0xd0],rax
     f7f:	je     1273 <botlish_fn_7+0x3c7>
     f85:	mov    r13,QWORD PTR [rsp+0x28]
     f8a:	mov    r14,QWORD PTR [rsp+0x30]
     f8f:	mov    rdi,QWORD PTR [rsp+0xb8]
     f97:	mov    rsi,QWORD PTR [rdi+0x10]
     f9b:	mov    r8,QWORD PTR [rsi+0x10]
     f9f:	mov    rcx,r14
     fa2:	mov    rdx,r13
     fa5:	mov    rsi,QWORD PTR [rsp+0xd0]
     fad:	call   fb2 <botlish_fn_7+0x106>
			fae: R_X86_64_PLT32	rt_str_region_eq-0x4
     fb2:	cmp    rax,0x6
     fb6:	je     11b9 <botlish_fn_7+0x30d>
     fbc:	mov    rdi,QWORD PTR [rsp+0xb8]
     fc4:	mov    r8,QWORD PTR [rdi+0x10]
     fc8:	mov    r8,QWORD PTR [r8+0x18]
     fcc:	mov    rcx,r14
     fcf:	mov    rdx,r13
     fd2:	mov    rsi,QWORD PTR [rsp+0xd0]
     fda:	call   fdf <botlish_fn_7+0x133>
			fdb: R_X86_64_PLT32	rt_str_region_eq-0x4
     fdf:	cmp    rax,0x6
     fe3:	je     10ae <botlish_fn_7+0x202>
     fe9:	lea    rcx,[rsp+0x88]
     ff1:	mov    QWORD PTR [rsp+0x88],0x0
     ffd:	mov    r14,QWORD PTR [rsp+0xc8]
    1005:	mov    QWORD PTR [rsp+0x90],r14
    100d:	mov    QWORD PTR [rsp+0x98],0x2
    1019:	mov    QWORD PTR [rsp+0xa0],r15
    1021:	mov    esi,0x1
    1026:	mov    edx,0x4
    102b:	mov    rdi,QWORD PTR [rsp+0xb8]
    1033:	call   1038 <botlish_fn_7+0x18c>
			1034: R_X86_64_PLT32	rt_construct-0x4
    1038:	test   rax,rax
    103b:	je     1273 <botlish_fn_7+0x3c7>
    1041:	mov    QWORD PTR [rsp],rax
    1045:	lea    rcx,[rsp+0xa8]
    104d:	mov    QWORD PTR [rsp+0xa8],rax
    1055:	mov    rsi,QWORD PTR [rsp+0xd8]
    105d:	mov    QWORD PTR [rsp+0xb0],rsi
    1065:	xor    rsi,rsi
    1068:	mov    edx,0x2
    106d:	mov    rdi,QWORD PTR [rsp+0xb8]
    1075:	call   107a <botlish_fn_7+0x1ce>
			1076: R_X86_64_PLT32	rt_struct_new-0x4
    107a:	mov    rbx,QWORD PTR [rsp+0xe0]
    1082:	mov    r12,QWORD PTR [rsp+0xe8]
    108a:	mov    r13,QWORD PTR [rsp+0xf0]
    1092:	mov    r14,QWORD PTR [rsp+0xf8]
    109a:	mov    r15,QWORD PTR [rsp+0x100]
    10a2:	add    rsp,0x110
    10a9:	mov    rsp,rbp
    10ac:	pop    rbp
    10ad:	ret
    10ae:	mov    r14,QWORD PTR [rsp+0xc8]
    10b6:	lea    rcx,[rsp+0x58]
    10bb:	mov    QWORD PTR [rsp+0x58],0x0
    10c4:	mov    QWORD PTR [rsp+0x60],r14
    10c9:	mov    edx,0x2
    10ce:	mov    r13,rdx
    10d1:	mov    QWORD PTR [rsp+0x68],0x2
    10da:	mov    QWORD PTR [rsp+0x70],r15
    10df:	mov    esi,0x1
    10e4:	mov    edx,0x4
    10e9:	mov    rdi,QWORD PTR [rsp+0xb8]
    10f1:	call   10f6 <botlish_fn_7+0x24a>
			10f2: R_X86_64_PLT32	rt_construct-0x4
    10f6:	test   rax,rax
    10f9:	je     1273 <botlish_fn_7+0x3c7>
    10ff:	mov    QWORD PTR [rsp],rax
    1103:	mov    rbx,rax
    1106:	mov    QWORD PTR [rsp+0x8],0x3
    110f:	mov    rsi,QWORD PTR [rsp+0xd8]
    1117:	test   rsi,0x1
    111e:	je     113e <botlish_fn_7+0x292>
    1124:	mov    rsi,QWORD PTR [rsp+0xd8]
    112c:	mov    rax,rsi
    112f:	add    rax,0x2
    1133:	seto   cl
    1136:	test   cl,cl
    1138:	je     1158 <botlish_fn_7+0x2ac>
    113e:	mov    edx,0x3
    1143:	mov    rsi,QWORD PTR [rsp+0xd8]
    114b:	mov    rdi,QWORD PTR [rsp+0xb8]
    1153:	call   1158 <botlish_fn_7+0x2ac>
			1154: R_X86_64_PLT32	rt_int_add-0x4
    1158:	mov    QWORD PTR [rsp+0x8],rax
    115d:	lea    rcx,[rsp+0x78]
    1162:	mov    rdx,rbx
    1165:	mov    QWORD PTR [rsp+0x78],rdx
    116a:	mov    QWORD PTR [rsp+0x80],rax
    1172:	xor    rsi,rsi
    1175:	mov    rdx,r13
    1178:	mov    rdi,QWORD PTR [rsp+0xb8]
    1180:	call   1185 <botlish_fn_7+0x2d9>
			1181: R_X86_64_PLT32	rt_struct_new-0x4
    1185:	mov    rbx,QWORD PTR [rsp+0xe0]
    118d:	mov    r12,QWORD PTR [rsp+0xe8]
    1195:	mov    r13,QWORD PTR [rsp+0xf0]
    119d:	mov    r14,QWORD PTR [rsp+0xf8]
    11a5:	mov    r15,QWORD PTR [rsp+0x100]
    11ad:	add    rsp,0x110
    11b4:	mov    rsp,rbp
    11b7:	pop    rbp
    11b8:	ret
    11b9:	mov    r14,QWORD PTR [rsp+0xc8]
    11c1:	mov    r13d,0x3
    11c7:	mov    QWORD PTR [rsp+0x20],0x3
    11d0:	mov    rsi,QWORD PTR [rsp+0xd8]
    11d8:	test   rsi,0x1
    11df:	jne    11f2 <botlish_fn_7+0x346>
    11e5:	mov    rsi,QWORD PTR [rsp+0xd8]
    11ed:	jmp    1214 <botlish_fn_7+0x368>
    11f2:	mov    rsi,QWORD PTR [rsp+0xd8]
    11fa:	mov    rdx,rsi
    11fd:	add    rdx,0x2
    1201:	seto   al
    1204:	test   al,al
    1206:	je     1227 <botlish_fn_7+0x37b>
    120c:	mov    rsi,QWORD PTR [rsp+0xd8]
    1214:	mov    rdx,r13
    1217:	mov    rdi,QWORD PTR [rsp+0xb8]
    121f:	call   1224 <botlish_fn_7+0x378>
			1220: R_X86_64_PLT32	rt_int_add-0x4
    1224:	mov    rdx,rax
    1227:	mov    QWORD PTR [rsp+0x18],rdx
    122c:	mov    QWORD PTR [rsp+0xc0],rdx
    1234:	lea    rcx,[rsp+0x38]
    1239:	mov    QWORD PTR [rsp+0x38],0x0
    1242:	mov    QWORD PTR [rsp+0x40],r14
    1247:	mov    QWORD PTR [rsp+0x48],0x2
    1250:	mov    QWORD PTR [rsp+0x50],r15
    1255:	mov    edx,0x4
    125a:	mov    rsi,r13
    125d:	mov    rdi,QWORD PTR [rsp+0xb8]
    1265:	call   126a <botlish_fn_7+0x3be>
			1266: R_X86_64_PLT32	rt_construct-0x4
    126a:	test   rax,rax
    126d:	jne    12aa <botlish_fn_7+0x3fe>
    1273:	xor    rax,rax
    1276:	mov    rbx,QWORD PTR [rsp+0xe0]
    127e:	mov    r12,QWORD PTR [rsp+0xe8]
    1286:	mov    r13,QWORD PTR [rsp+0xf0]
    128e:	mov    r14,QWORD PTR [rsp+0xf8]
    1296:	mov    r15,QWORD PTR [rsp+0x100]
    129e:	add    rsp,0x110
    12a5:	mov    rsp,rbp
    12a8:	pop    rbp
    12a9:	ret
    12aa:	mov    QWORD PTR [rsp],r12
    12ae:	mov    rdx,QWORD PTR [rsp+0xc0]
    12b6:	mov    QWORD PTR [rsp+0x8],rdx
    12bb:	mov    QWORD PTR [rsp+0x10],rax
    12c0:	mov    QWORD PTR [rsp+0xc8],rax
    12c8:	jmp    f1f <botlish_fn_7+0x73>

00000000000012cd <botlish_entry_7: scan_record<str, int, List[str]>>:
    12cd:	push   rbp
    12ce:	mov    rbp,rsp
    12d1:	mov    rsi,QWORD PTR [rdx]
    12d4:	mov    r8,QWORD PTR [rdx+0x8]
    12d8:	mov    rcx,QWORD PTR [rdx+0x10]
    12dc:	mov    rdx,r8
    12df:	call   12e4 <botlish_entry_7+0x17>
			12e0: R_X86_64_PLT32	botlish_fn_7-0x4 ; scan_record<str, int, List[str]>
    12e4:	mov    rsp,rbp
    12e7:	pop    rbp
    12e8:	ret

00000000000012e9 <botlish_fn_8: scan_records<str, int, List[never]>>:
    12e9:	push   rbp
    12ea:	mov    rbp,rsp
    12ed:	sub    rsp,0x60
    12f1:	mov    QWORD PTR [rsp+0x40],rbx
    12f6:	mov    QWORD PTR [rsp+0x48],r12
    12fb:	mov    QWORD PTR [rsp+0x50],r13
    1300:	mov    QWORD PTR [rsp+0x58],r14
    1305:	mov    r12,rdi
    1308:	mov    QWORD PTR [rsp+0x18],0x0
    1311:	mov    QWORD PTR [rsp],rsi
    1315:	mov    rbx,rsi
    1318:	mov    QWORD PTR [rsp+0x8],rdx
    131d:	mov    r14,rdx
    1320:	mov    QWORD PTR [rsp+0x10],rcx
    1325:	mov    r13,rcx
    1328:	mov    rsi,rbx
    132b:	mov    rdi,r12
    132e:	call   1333 <botlish_fn_8+0x4a>
			132f: R_X86_64_PLT32	rt_str_len-0x4
    1333:	mov    rdx,r14
    1336:	mov    rcx,rdx
    1339:	sar    rcx,1
    133c:	sar    rax,1
    133f:	cmp    rcx,rax
    1342:	jge    1435 <botlish_fn_8+0x14c>
    1348:	xor    rdx,rdx
    134b:	mov    rdi,r12
    134e:	mov    rsi,rdx
    1351:	call   1356 <botlish_fn_8+0x6d>
			1352: R_X86_64_PLT32	rt_list_new-0x4
    1356:	test   rax,rax
    1359:	je     13f8 <botlish_fn_8+0x10f>
    135f:	mov    QWORD PTR [rsp+0x18],rax
    1364:	mov    rcx,rax
    1367:	mov    rdx,r14
    136a:	mov    rsi,rbx
    136d:	mov    rdi,r12
    1370:	call   1375 <botlish_fn_8+0x8c>
			1371: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    1375:	test   rax,rax
    1378:	je     13f8 <botlish_fn_8+0x10f>
    137e:	mov    rcx,QWORD PTR [rax+0x18]
    1382:	mov    rdx,QWORD PTR [rcx+0x8]
    1386:	mov    QWORD PTR [rsp+0x8],rdx
    138b:	mov    r14,rdx
    138e:	mov    rax,QWORD PTR [rax+0x18]
    1392:	mov    rax,QWORD PTR [rax]
    1395:	mov    QWORD PTR [rsp+0x18],rax
    139a:	lea    rcx,[rsp+0x20]
    139f:	mov    QWORD PTR [rsp+0x20],0x0
    13a8:	mov    rdx,r13
    13ab:	mov    QWORD PTR [rsp+0x28],rdx
    13b0:	mov    QWORD PTR [rsp+0x30],0x2
    13b9:	mov    QWORD PTR [rsp+0x38],rax
    13be:	mov    esi,0x3
    13c3:	mov    edx,0x4
    13c8:	mov    rdi,r12
    13cb:	call   13d0 <botlish_fn_8+0xe7>
			13cc: R_X86_64_PLT32	rt_construct-0x4
    13d0:	test   rax,rax
    13d3:	je     13f8 <botlish_fn_8+0x10f>
    13d9:	mov    QWORD PTR [rsp+0x10],rax
    13de:	mov    rcx,rax
    13e1:	mov    rdx,r14
    13e4:	mov    rsi,rbx
    13e7:	mov    rdi,r12
    13ea:	call   13ef <botlish_fn_8+0x106>
			13eb: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    13ef:	test   rax,rax
    13f2:	jne    1418 <botlish_fn_8+0x12f>
    13f8:	xor    rax,rax
    13fb:	mov    rbx,QWORD PTR [rsp+0x40]
    1400:	mov    r12,QWORD PTR [rsp+0x48]
    1405:	mov    r13,QWORD PTR [rsp+0x50]
    140a:	mov    r14,QWORD PTR [rsp+0x58]
    140f:	add    rsp,0x60
    1413:	mov    rsp,rbp
    1416:	pop    rbp
    1417:	ret
    1418:	mov    rbx,QWORD PTR [rsp+0x40]
    141d:	mov    r12,QWORD PTR [rsp+0x48]
    1422:	mov    r13,QWORD PTR [rsp+0x50]
    1427:	mov    r14,QWORD PTR [rsp+0x58]
    142c:	add    rsp,0x60
    1430:	mov    rsp,rbp
    1433:	pop    rbp
    1434:	ret
    1435:	mov    rax,r13
    1438:	mov    rbx,QWORD PTR [rsp+0x40]
    143d:	mov    r12,QWORD PTR [rsp+0x48]
    1442:	mov    r13,QWORD PTR [rsp+0x50]
    1447:	mov    r14,QWORD PTR [rsp+0x58]
    144c:	add    rsp,0x60
    1450:	mov    rsp,rbp
    1453:	pop    rbp
    1454:	ret

0000000000001455 <botlish_entry_8: scan_records<str, int, List[never]>>:
    1455:	push   rbp
    1456:	mov    rbp,rsp
    1459:	mov    rsi,QWORD PTR [rdx]
    145c:	mov    r8,QWORD PTR [rdx+0x8]
    1460:	mov    rcx,QWORD PTR [rdx+0x10]
    1464:	mov    rdx,r8
    1467:	call   146c <botlish_entry_8+0x17>
			1468: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    146c:	mov    rsp,rbp
    146f:	pop    rbp
    1470:	ret
    1471:	add    BYTE PTR [rax],al
    1473:	add    BYTE PTR [rax],al
    1475:	add    BYTE PTR [rax],al
	...

0000000000001478 <botlish_fn_9: scan_records<str, int, List[List[str]]>>:
    1478:	push   rbp
    1479:	mov    rbp,rsp
    147c:	sub    rsp,0x80
    1483:	mov    QWORD PTR [rsp+0x50],rbx
    1488:	mov    QWORD PTR [rsp+0x58],r12
    148d:	mov    QWORD PTR [rsp+0x60],r13
    1492:	mov    QWORD PTR [rsp+0x68],r14
    1497:	mov    QWORD PTR [rsp+0x70],r15
    149c:	mov    r14,rdi
    149f:	mov    QWORD PTR [rsp+0x18],0x0
    14a8:	mov    QWORD PTR [rsp],rsi
    14ac:	mov    QWORD PTR [rsp+0x8],rdx
    14b1:	mov    r13,rdx
    14b4:	mov    QWORD PTR [rsp+0x10],rcx
    14b9:	mov    r15,rcx
    14bc:	lea    r12,[rsp+0x30]
    14c1:	mov    rbx,rsi
    14c4:	mov    rsi,rbx
    14c7:	mov    rdi,r14
    14ca:	call   14cf <botlish_fn_9+0x57>
			14cb: R_X86_64_PLT32	rt_str_len-0x4
    14cf:	mov    rcx,r13
    14d2:	and    rcx,rax
    14d5:	mov    rdx,rax
    14d8:	test   rcx,0x1
    14df:	jne    1505 <botlish_fn_9+0x8d>
    14e5:	mov    rsi,r13
    14e8:	mov    rdi,r14
    14eb:	call   14f0 <botlish_fn_9+0x78>
			14ec: R_X86_64_PLT32	rt_int_cmp-0x4
    14f0:	mov    ecx,0x2
    14f5:	test   rax,rax
    14f8:	cmovge rcx,QWORD PTR [rip+0x148]        # 1648 <botlish_fn_9+0x1d0>
    1500:	jmp    1518 <botlish_fn_9+0xa0>
    1505:	mov    ecx,0x2
    150a:	mov    rax,r13
    150d:	cmp    rax,rdx
    1510:	cmovge rcx,QWORD PTR [rip+0x130]        # 1648 <botlish_fn_9+0x1d0>
    1518:	cmp    rcx,0x6
    151c:	je     15ca <botlish_fn_9+0x152>
    1522:	xor    rdx,rdx
    1525:	mov    rdi,r14
    1528:	mov    rsi,rdx
    152b:	call   1530 <botlish_fn_9+0xb8>
			152c: R_X86_64_PLT32	rt_list_new-0x4
    1530:	test   rax,rax
    1533:	je     15fb <botlish_fn_9+0x183>
    1539:	mov    QWORD PTR [rsp+0x18],rax
    153e:	mov    rcx,rax
    1541:	mov    rdx,r13
    1544:	mov    rsi,rbx
    1547:	mov    rdi,r14
    154a:	call   154f <botlish_fn_9+0xd7>
			154b: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    154f:	test   rax,rax
    1552:	je     15fb <botlish_fn_9+0x183>
    1558:	mov    rcx,QWORD PTR [rax+0x18]
    155c:	mov    rdx,QWORD PTR [rcx+0x8]
    1560:	mov    r13,rdx
    1563:	mov    QWORD PTR [rsp+0x8],rdx
    1568:	mov    rax,QWORD PTR [rax+0x18]
    156c:	mov    rax,QWORD PTR [rax]
    156f:	mov    QWORD PTR [rsp+0x18],rax
    1574:	mov    QWORD PTR [rsp+0x30],0x0
    157d:	mov    rdx,r15
    1580:	mov    QWORD PTR [rsp+0x38],rdx
    1585:	mov    QWORD PTR [rsp+0x40],0x2
    158e:	mov    QWORD PTR [rsp+0x48],rax
    1593:	mov    esi,0x3
    1598:	mov    edx,0x4
    159d:	mov    rcx,r12
    15a0:	mov    rdi,r14
    15a3:	call   15a8 <botlish_fn_9+0x130>
			15a4: R_X86_64_PLT32	rt_construct-0x4
    15a8:	test   rax,rax
    15ab:	je     15fb <botlish_fn_9+0x183>
    15b1:	mov    QWORD PTR [rsp],rbx
    15b5:	mov    rdx,r13
    15b8:	mov    QWORD PTR [rsp+0x8],rdx
    15bd:	mov    QWORD PTR [rsp+0x10],rax
    15c2:	mov    r15,rax
    15c5:	jmp    14c4 <botlish_fn_9+0x4c>
    15ca:	mov    rdx,r15
    15cd:	lea    rcx,[rsp+0x20]
    15d2:	mov    QWORD PTR [rsp+0x20],0x0
    15db:	mov    QWORD PTR [rsp+0x28],rdx
    15e0:	mov    esi,0x1
    15e5:	mov    edx,0x2
    15ea:	mov    rdi,r14
    15ed:	call   15f2 <botlish_fn_9+0x17a>
			15ee: R_X86_64_PLT32	rt_construct-0x4
    15f2:	test   rax,rax
    15f5:	jne    1623 <botlish_fn_9+0x1ab>
    15fb:	xor    rax,rax
    15fe:	mov    rbx,QWORD PTR [rsp+0x50]
    1603:	mov    r12,QWORD PTR [rsp+0x58]
    1608:	mov    r13,QWORD PTR [rsp+0x60]
    160d:	mov    r14,QWORD PTR [rsp+0x68]
    1612:	mov    r15,QWORD PTR [rsp+0x70]
    1617:	add    rsp,0x80
    161e:	mov    rsp,rbp
    1621:	pop    rbp
    1622:	ret
    1623:	mov    rbx,QWORD PTR [rsp+0x50]
    1628:	mov    r12,QWORD PTR [rsp+0x58]
    162d:	mov    r13,QWORD PTR [rsp+0x60]
    1632:	mov    r14,QWORD PTR [rsp+0x68]
    1637:	mov    r15,QWORD PTR [rsp+0x70]
    163c:	add    rsp,0x80
    1643:	mov    rsp,rbp
    1646:	pop    rbp
    1647:	ret
    1648:	(bad)
    1649:	add    BYTE PTR [rax],al
    164b:	add    BYTE PTR [rax],al
    164d:	add    BYTE PTR [rax],al
	...

0000000000001650 <botlish_entry_9: scan_records<str, int, List[List[str]]>>:
    1650:	push   rbp
    1651:	mov    rbp,rsp
    1654:	mov    rsi,QWORD PTR [rdx]
    1657:	mov    r8,QWORD PTR [rdx+0x8]
    165b:	mov    rcx,QWORD PTR [rdx+0x10]
    165f:	mov    rdx,r8
    1662:	call   1667 <botlish_entry_9+0x17>
			1663: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    1667:	mov    rsp,rbp
    166a:	pop    rbp
    166b:	ret

000000000000166c <botlish_fn_10: csv_parse<str>>:
    166c:	push   rbp
    166d:	mov    rbp,rsp
    1670:	sub    rsp,0x30
    1674:	mov    QWORD PTR [rsp+0x20],r12
    1679:	mov    QWORD PTR [rsp+0x28],r13
    167e:	mov    r13,rdi
    1681:	mov    QWORD PTR [rsp+0x10],0x0
    168a:	mov    QWORD PTR [rsp],rsi
    168e:	mov    r12,rsi
    1691:	mov    QWORD PTR [rsp+0x8],0x1
    169a:	xor    rdx,rdx
    169d:	mov    rdi,r13
    16a0:	mov    rsi,rdx
    16a3:	call   16a8 <botlish_fn_10+0x3c>
			16a4: R_X86_64_PLT32	rt_list_new-0x4
    16a8:	test   rax,rax
    16ab:	je     16d2 <botlish_fn_10+0x66>
    16b1:	mov    QWORD PTR [rsp+0x10],rax
    16b6:	mov    rcx,rax
    16b9:	mov    edx,0x1
    16be:	mov    rsi,r12
    16c1:	mov    rdi,r13
    16c4:	call   16c9 <botlish_fn_10+0x5d>
			16c5: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    16c9:	test   rax,rax
    16cc:	jne    16e8 <botlish_fn_10+0x7c>
    16d2:	xor    rax,rax
    16d5:	mov    r12,QWORD PTR [rsp+0x20]
    16da:	mov    r13,QWORD PTR [rsp+0x28]
    16df:	add    rsp,0x30
    16e3:	mov    rsp,rbp
    16e6:	pop    rbp
    16e7:	ret
    16e8:	mov    r12,QWORD PTR [rsp+0x20]
    16ed:	mov    r13,QWORD PTR [rsp+0x28]
    16f2:	add    rsp,0x30
    16f6:	mov    rsp,rbp
    16f9:	pop    rbp
    16fa:	ret

00000000000016fb <botlish_entry_10: csv_parse<str>>:
    16fb:	push   rbp
    16fc:	mov    rbp,rsp
    16ff:	mov    rsi,QWORD PTR [rdx]
    1702:	call   1707 <botlish_entry_10+0xc>
			1703: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
    1707:	mov    rsp,rbp
    170a:	pop    rbp
    170b:	ret

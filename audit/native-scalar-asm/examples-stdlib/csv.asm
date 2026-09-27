; source:  examples/stdlib/csv.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5723  (per function: 68 365 430 585 1063 352 795 976 398 524 167)
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
     342:	sub    rsp,0x80
     349:	mov    QWORD PTR [rsp+0x50],rbx
     34e:	mov    QWORD PTR [rsp+0x58],r12
     353:	mov    QWORD PTR [rsp+0x60],r13
     358:	mov    QWORD PTR [rsp+0x68],r14
     35d:	mov    QWORD PTR [rsp+0x70],r15
     362:	mov    QWORD PTR [rsp+0x30],rdi
     367:	mov    QWORD PTR [rsp+0x18],0x0
     370:	mov    QWORD PTR [rsp],rsi
     374:	mov    r15,rsi
     377:	mov    QWORD PTR [rsp+0x8],rdx
     37c:	mov    r14,rdx
     37f:	mov    QWORD PTR [rsp+0x10],rcx
     384:	lea    r13,[rsp+0x20]
     389:	mov    QWORD PTR [rsp+0x38],rcx
     38e:	mov    rcx,r13
     391:	mov    rdx,QWORD PTR [rsp+0x38]
     396:	mov    rsi,r15
     399:	mov    rdi,QWORD PTR [rsp+0x30]
     39e:	call   3a3 <botlish_fn_3+0x65>
			39f: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     3a3:	mov    rsi,rax
     3a6:	mov    QWORD PTR [rsp+0x40],rax
     3ab:	test   rax,rsi
     3ae:	je     508 <botlish_fn_3+0x1ca>
     3b4:	mov    rbx,QWORD PTR [rsp+0x20]
     3b9:	mov    r12,QWORD PTR [rsp+0x28]
     3be:	mov    rdi,QWORD PTR [rsp+0x30]
     3c3:	mov    rcx,QWORD PTR [rdi+0x10]
     3c7:	mov    r8,QWORD PTR [rcx+0x8]
     3cb:	mov    rcx,r12
     3ce:	mov    rdx,rbx
     3d1:	mov    rsi,QWORD PTR [rsp+0x40]
     3d6:	call   3db <botlish_fn_3+0x9d>
			3d7: R_X86_64_PLT32	rt_str_region_eq-0x4
     3db:	cmp    rax,0x6
     3df:	je     420 <botlish_fn_3+0xe2>
     3e5:	mov    rdi,QWORD PTR [rsp+0x30]
     3ea:	mov    rax,QWORD PTR [rdi+0x10]
     3ee:	mov    r8,QWORD PTR [rax+0x10]
     3f2:	mov    rcx,r12
     3f5:	mov    rdx,rbx
     3f8:	mov    rsi,QWORD PTR [rsp+0x40]
     3fd:	call   402 <botlish_fn_3+0xc4>
			3fe: R_X86_64_PLT32	rt_str_region_eq-0x4
     402:	cmp    rax,0x6
     406:	je     416 <botlish_fn_3+0xd8>
     40c:	mov    eax,0x2
     411:	jmp    425 <botlish_fn_3+0xe7>
     416:	mov    eax,0x6
     41b:	jmp    425 <botlish_fn_3+0xe7>
     420:	mov    eax,0x6
     425:	cmp    rax,0x6
     429:	je     46a <botlish_fn_3+0x12c>
     42f:	mov    rdi,QWORD PTR [rsp+0x30]
     434:	mov    rax,QWORD PTR [rdi+0x10]
     438:	mov    r8,QWORD PTR [rax+0x18]
     43c:	mov    rcx,r12
     43f:	mov    rdx,rbx
     442:	mov    rsi,QWORD PTR [rsp+0x40]
     447:	call   44c <botlish_fn_3+0x10e>
			448: R_X86_64_PLT32	rt_str_region_eq-0x4
     44c:	cmp    rax,0x6
     450:	je     460 <botlish_fn_3+0x122>
     456:	mov    eax,0x2
     45b:	jmp    46f <botlish_fn_3+0x131>
     460:	mov    eax,0x6
     465:	jmp    46f <botlish_fn_3+0x131>
     46a:	mov    eax,0x6
     46f:	cmp    rax,0x6
     473:	je     4ea <botlish_fn_3+0x1ac>
     479:	mov    QWORD PTR [rsp+0x18],0x3
     482:	mov    rsi,QWORD PTR [rsp+0x38]
     487:	test   rsi,0x1
     48e:	je     4b5 <botlish_fn_3+0x177>
     494:	mov    rsi,QWORD PTR [rsp+0x38]
     499:	mov    rax,rsi
     49c:	add    rax,0x2
     4a0:	seto   sil
     4a4:	test   sil,sil
     4a7:	jne    4b5 <botlish_fn_3+0x177>
     4ad:	mov    rsi,r15
     4b0:	jmp    4cc <botlish_fn_3+0x18e>
     4b5:	mov    edx,0x3
     4ba:	mov    rsi,QWORD PTR [rsp+0x38]
     4bf:	mov    rdi,QWORD PTR [rsp+0x30]
     4c4:	call   4c9 <botlish_fn_3+0x18b>
			4c5: R_X86_64_PLT32	rt_int_add-0x4
     4c9:	mov    rsi,r15
     4cc:	mov    QWORD PTR [rsp],rsi
     4d0:	mov    rdx,r14
     4d3:	mov    QWORD PTR [rsp+0x8],rdx
     4d8:	mov    QWORD PTR [rsp+0x10],rax
     4dd:	mov    r15,rsi
     4e0:	mov    QWORD PTR [rsp+0x38],rax
     4e5:	jmp    38e <botlish_fn_3+0x50>
     4ea:	mov    rdx,r14
     4ed:	mov    rsi,r15
     4f0:	mov    rdi,QWORD PTR [rsp+0x30]
     4f5:	mov    rcx,QWORD PTR [rsp+0x38]
     4fa:	call   4ff <botlish_fn_3+0x1c1>
			4fb: R_X86_64_PLT32	rt_substr-0x4
     4ff:	test   rax,rax
     502:	jne    533 <botlish_fn_3+0x1f5>
     508:	xor    rdx,rdx
     50b:	mov    rax,rdx
     50e:	mov    rbx,QWORD PTR [rsp+0x50]
     513:	mov    r12,QWORD PTR [rsp+0x58]
     518:	mov    r13,QWORD PTR [rsp+0x60]
     51d:	mov    r14,QWORD PTR [rsp+0x68]
     522:	mov    r15,QWORD PTR [rsp+0x70]
     527:	add    rsp,0x80
     52e:	mov    rsp,rbp
     531:	pop    rbp
     532:	ret
     533:	mov    rdx,QWORD PTR [rsp+0x38]
     538:	mov    rbx,QWORD PTR [rsp+0x50]
     53d:	mov    r12,QWORD PTR [rsp+0x58]
     542:	mov    r13,QWORD PTR [rsp+0x60]
     547:	mov    r14,QWORD PTR [rsp+0x68]
     54c:	mov    r15,QWORD PTR [rsp+0x70]
     551:	add    rsp,0x80
     558:	mov    rsp,rbp
     55b:	pop    rbp
     55c:	ret

000000000000055d <botlish_entry_3: scan_unquoted<str, int, int>>:
     55d:	push   rbp
     55e:	mov    rbp,rsp
     561:	ud2

0000000000000563 <botlish_fn_4: scan_quoted<str, int, str>>:
     563:	push   rbp
     564:	mov    rbp,rsp
     567:	sub    rsp,0xd0
     56e:	mov    QWORD PTR [rsp+0xa0],rbx
     576:	mov    QWORD PTR [rsp+0xa8],r12
     57e:	mov    QWORD PTR [rsp+0xb0],r13
     586:	mov    QWORD PTR [rsp+0xb8],r14
     58e:	mov    QWORD PTR [rsp+0xc0],r15
     596:	mov    r15,rdi
     599:	mov    QWORD PTR [rsp+0x18],0x0
     5a2:	mov    QWORD PTR [rsp+0x20],0x0
     5ab:	mov    QWORD PTR [rsp],rsi
     5af:	mov    QWORD PTR [rsp+0x8],rdx
     5b4:	mov    QWORD PTR [rsp+0x10],rcx
     5b9:	mov    r13,rcx
     5bc:	lea    r14,[rsp+0x68]
     5c1:	lea    rbx,[rsp+0x28]
     5c6:	mov    r12,rsi
     5c9:	mov    QWORD PTR [rsp+0x88],rdx
     5d1:	mov    rdx,QWORD PTR [rsp+0x88]
     5d9:	mov    rsi,r12
     5dc:	mov    rdi,r15
     5df:	call   5e4 <botlish_fn_4+0x81>
			5e0: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     5e4:	test   rax,rax
     5e7:	je     8eb <botlish_fn_4+0x388>
     5ed:	mov    QWORD PTR [rsp+0x18],rax
     5f2:	mov    rdi,r15
     5f5:	mov    QWORD PTR [rsp+0x90],rax
     5fd:	mov    rsi,QWORD PTR [rdi+0x10]
     601:	mov    rsi,QWORD PTR [rsi+0x20]
     605:	mov    edx,0x1
     60a:	mov    ecx,0x3
     60f:	mov    r8,QWORD PTR [rsp+0x90]
     617:	call   61c <botlish_fn_4+0xb9>
			618: R_X86_64_PLT32	rt_str_region_eq-0x4
     61c:	cmp    rax,0x6
     620:	je     6e0 <botlish_fn_4+0x17d>
     626:	mov    QWORD PTR [rsp+0x20],0x3
     62f:	mov    rsi,QWORD PTR [rsp+0x88]
     637:	test   rsi,0x1
     63e:	je     660 <botlish_fn_4+0xfd>
     644:	mov    r9,rsi
     647:	add    r9,0x2
     64b:	seto   r11b
     64f:	test   r11b,r11b
     652:	jne    660 <botlish_fn_4+0xfd>
     658:	mov    rsi,r9
     65b:	jmp    670 <botlish_fn_4+0x10d>
     660:	mov    edx,0x3
     665:	mov    rdi,r15
     668:	call   66d <botlish_fn_4+0x10a>
			669: R_X86_64_PLT32	rt_int_add-0x4
     66d:	mov    rsi,rax
     670:	mov    QWORD PTR [rsp+0x8],rsi
     675:	mov    QWORD PTR [rsp+0x88],rsi
     67d:	mov    QWORD PTR [rsp+0x68],0x0
     686:	mov    QWORD PTR [rsp+0x70],r13
     68b:	mov    QWORD PTR [rsp+0x78],0x0
     694:	mov    rax,QWORD PTR [rsp+0x90]
     69c:	mov    QWORD PTR [rsp+0x80],rax
     6a4:	mov    esi,0x2
     6a9:	mov    edx,0x4
     6ae:	mov    rcx,r14
     6b1:	mov    rdi,r15
     6b4:	call   6b9 <botlish_fn_4+0x156>
			6b5: R_X86_64_PLT32	rt_construct-0x4
     6b9:	test   rax,rax
     6bc:	je     8eb <botlish_fn_4+0x388>
     6c2:	mov    QWORD PTR [rsp],r12
     6c6:	mov    rsi,QWORD PTR [rsp+0x88]
     6ce:	mov    QWORD PTR [rsp+0x8],rsi
     6d3:	mov    QWORD PTR [rsp+0x10],rax
     6d8:	mov    r13,rax
     6db:	jmp    5d1 <botlish_fn_4+0x6e>
     6e0:	mov    QWORD PTR [rsp+0x18],0x3
     6e9:	mov    rsi,QWORD PTR [rsp+0x88]
     6f1:	test   rsi,0x1
     6f8:	je     718 <botlish_fn_4+0x1b5>
     6fe:	mov    rsi,QWORD PTR [rsp+0x88]
     706:	mov    rdx,rsi
     709:	add    rdx,0x2
     70d:	seto   al
     710:	test   al,al
     712:	je     730 <botlish_fn_4+0x1cd>
     718:	mov    edx,0x3
     71d:	mov    rsi,QWORD PTR [rsp+0x88]
     725:	mov    rdi,r15
     728:	call   72d <botlish_fn_4+0x1ca>
			729: R_X86_64_PLT32	rt_int_add-0x4
     72d:	mov    rdx,rax
     730:	mov    QWORD PTR [rsp+0x18],rdx
     735:	mov    rcx,rbx
     738:	mov    rsi,r12
     73b:	mov    rdi,r15
     73e:	call   743 <botlish_fn_4+0x1e0>
			73f: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     743:	test   rax,rax
     746:	mov    rsi,rax
     749:	je     8eb <botlish_fn_4+0x388>
     74f:	mov    rdx,QWORD PTR [rsp+0x28]
     754:	mov    rcx,QWORD PTR [rsp+0x30]
     759:	mov    rdi,r15
     75c:	mov    rax,QWORD PTR [rdi+0x10]
     760:	mov    r8,QWORD PTR [rax+0x20]
     764:	call   769 <botlish_fn_4+0x206>
			765: R_X86_64_PLT32	rt_str_region_eq-0x4
     769:	cmp    rax,0x6
     76d:	je     835 <botlish_fn_4+0x2d2>
     773:	xor    rsi,rsi
     776:	lea    rcx,[rsp+0x58]
     77b:	mov    QWORD PTR [rsp+0x58],0x0
     784:	mov    QWORD PTR [rsp+0x60],r13
     789:	mov    edx,0x2
     78e:	mov    rdi,r15
     791:	call   796 <botlish_fn_4+0x233>
			792: R_X86_64_PLT32	rt_construct-0x4
     796:	test   rax,rax
     799:	je     8eb <botlish_fn_4+0x388>
     79f:	mov    QWORD PTR [rsp],rax
     7a3:	mov    rbx,rax
     7a6:	mov    QWORD PTR [rsp+0x10],0x3
     7af:	mov    rsi,QWORD PTR [rsp+0x88]
     7b7:	test   rsi,0x1
     7be:	je     7e6 <botlish_fn_4+0x283>
     7c4:	mov    rsi,QWORD PTR [rsp+0x88]
     7cc:	mov    rdx,rsi
     7cf:	add    rdx,0x2
     7d3:	seto   al
     7d6:	test   al,al
     7d8:	jne    7e6 <botlish_fn_4+0x283>
     7de:	mov    rax,rbx
     7e1:	jmp    801 <botlish_fn_4+0x29e>
     7e6:	mov    edx,0x3
     7eb:	mov    rsi,QWORD PTR [rsp+0x88]
     7f3:	mov    rdi,r15
     7f6:	call   7fb <botlish_fn_4+0x298>
			7f7: R_X86_64_PLT32	rt_int_add-0x4
     7fb:	mov    rdx,rax
     7fe:	mov    rax,rbx
     801:	mov    rbx,QWORD PTR [rsp+0xa0]
     809:	mov    r12,QWORD PTR [rsp+0xa8]
     811:	mov    r13,QWORD PTR [rsp+0xb0]
     819:	mov    r14,QWORD PTR [rsp+0xb8]
     821:	mov    r15,QWORD PTR [rsp+0xc0]
     829:	add    rsp,0xd0
     830:	mov    rsp,rbp
     833:	pop    rbp
     834:	ret
     835:	mov    QWORD PTR [rsp+0x18],0x5
     83e:	mov    rsi,QWORD PTR [rsp+0x88]
     846:	test   rsi,0x1
     84d:	je     87d <botlish_fn_4+0x31a>
     853:	mov    rsi,QWORD PTR [rsp+0x88]
     85b:	mov    rax,rsi
     85e:	add    rax,0x4
     862:	seto   cl
     865:	test   cl,cl
     867:	jne    87d <botlish_fn_4+0x31a>
     86d:	mov    rsi,rax
     870:	mov    QWORD PTR [rsp+0x88],rax
     878:	jmp    89d <botlish_fn_4+0x33a>
     87d:	mov    edx,0x5
     882:	mov    rsi,QWORD PTR [rsp+0x88]
     88a:	mov    rdi,r15
     88d:	call   892 <botlish_fn_4+0x32f>
			88e: R_X86_64_PLT32	rt_int_add-0x4
     892:	mov    rsi,rax
     895:	mov    QWORD PTR [rsp+0x88],rax
     89d:	mov    QWORD PTR [rsp+0x8],rsi
     8a2:	mov    rdi,r15
     8a5:	mov    rsi,QWORD PTR [rdi+0x10]
     8a9:	mov    rsi,QWORD PTR [rsi+0x20]
     8ad:	mov    QWORD PTR [rsp+0x18],rsi
     8b2:	lea    rcx,[rsp+0x38]
     8b7:	mov    QWORD PTR [rsp+0x38],0x0
     8c0:	mov    QWORD PTR [rsp+0x40],r13
     8c5:	mov    QWORD PTR [rsp+0x48],0x0
     8ce:	mov    QWORD PTR [rsp+0x50],rsi
     8d3:	mov    esi,0x2
     8d8:	mov    edx,0x4
     8dd:	call   8e2 <botlish_fn_4+0x37f>
			8de: R_X86_64_PLT32	rt_construct-0x4
     8e2:	test   rax,rax
     8e5:	jne    925 <botlish_fn_4+0x3c2>
     8eb:	xor    rdx,rdx
     8ee:	mov    rax,rdx
     8f1:	mov    rbx,QWORD PTR [rsp+0xa0]
     8f9:	mov    r12,QWORD PTR [rsp+0xa8]
     901:	mov    r13,QWORD PTR [rsp+0xb0]
     909:	mov    r14,QWORD PTR [rsp+0xb8]
     911:	mov    r15,QWORD PTR [rsp+0xc0]
     919:	add    rsp,0xd0
     920:	mov    rsp,rbp
     923:	pop    rbp
     924:	ret
     925:	mov    QWORD PTR [rsp],r12
     929:	mov    rsi,QWORD PTR [rsp+0x88]
     931:	mov    QWORD PTR [rsp+0x8],rsi
     936:	mov    QWORD PTR [rsp+0x10],rax
     93b:	mov    r13,rax
     93e:	jmp    5d1 <botlish_fn_4+0x6e>

0000000000000943 <botlish_entry_4: scan_quoted<str, int, str>>:
     943:	push   rbp
     944:	mov    rbp,rsp
     947:	ud2

0000000000000949 <botlish_fn_5: scan_field<str, int>>:
     949:	push   rbp
     94a:	mov    rbp,rsp
     94d:	sub    rsp,0x50
     951:	mov    QWORD PTR [rsp+0x30],rbx
     956:	mov    QWORD PTR [rsp+0x38],r12
     95b:	mov    QWORD PTR [rsp+0x40],r13
     960:	mov    r12,rdi
     963:	mov    r13,rdx
     966:	mov    QWORD PTR [rsp+0x10],0x0
     96f:	mov    QWORD PTR [rsp],rsi
     973:	mov    rbx,rsi
     976:	mov    QWORD PTR [rsp+0x8],rdx
     97b:	lea    rcx,[rsp+0x18]
     980:	mov    rdx,r13
     983:	mov    rsi,rbx
     986:	mov    rdi,r12
     989:	call   98e <botlish_fn_5+0x45>
			98a: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     98e:	test   rax,rax
     991:	mov    rsi,rax
     994:	je     a5f <botlish_fn_5+0x116>
     99a:	mov    rdx,QWORD PTR [rsp+0x18]
     99f:	mov    rcx,QWORD PTR [rsp+0x20]
     9a4:	mov    rdi,r12
     9a7:	mov    rax,QWORD PTR [rdi+0x10]
     9ab:	mov    r8,QWORD PTR [rax+0x20]
     9af:	call   9b4 <botlish_fn_5+0x6b>
			9b0: R_X86_64_PLT32	rt_str_region_eq-0x4
     9b4:	cmp    rax,0x6
     9b8:	je     9f0 <botlish_fn_5+0xa7>
     9be:	mov    rcx,r13
     9c1:	mov    rsi,rbx
     9c4:	mov    rdi,r12
     9c7:	mov    rdx,rcx
     9ca:	call   9cf <botlish_fn_5+0x86>
			9cb: R_X86_64_PLT32	botlish_fn_3-0x4 ; scan_unquoted<str, int, int>
     9cf:	test   rax,rax
     9d2:	je     a5f <botlish_fn_5+0x116>
     9d8:	mov    rbx,QWORD PTR [rsp+0x30]
     9dd:	mov    r12,QWORD PTR [rsp+0x38]
     9e2:	mov    r13,QWORD PTR [rsp+0x40]
     9e7:	add    rsp,0x50
     9eb:	mov    rsp,rbp
     9ee:	pop    rbp
     9ef:	ret
     9f0:	mov    rcx,r13
     9f3:	mov    QWORD PTR [rsp+0x10],0x3
     9fc:	test   rcx,0x1
     a03:	jne    a11 <botlish_fn_5+0xc8>
     a09:	mov    r13,rcx
     a0c:	jmp    a26 <botlish_fn_5+0xdd>
     a11:	mov    rdx,rcx
     a14:	add    rdx,0x2
     a18:	mov    r13,rcx
     a1b:	seto   al
     a1e:	test   al,al
     a20:	je     a39 <botlish_fn_5+0xf0>
     a26:	mov    edx,0x3
     a2b:	mov    rsi,r13
     a2e:	mov    rdi,r12
     a31:	call   a36 <botlish_fn_5+0xed>
			a32: R_X86_64_PLT32	rt_int_add-0x4
     a36:	mov    rdx,rax
     a39:	mov    QWORD PTR [rsp+0x8],rdx
     a3e:	mov    rdi,r12
     a41:	mov    rax,QWORD PTR [rdi+0x10]
     a45:	mov    rcx,QWORD PTR [rax+0x8]
     a49:	mov    QWORD PTR [rsp+0x10],rcx
     a4e:	mov    rsi,rbx
     a51:	call   a56 <botlish_fn_5+0x10d>
			a52: R_X86_64_PLT32	botlish_fn_4-0x4 ; scan_quoted<str, int, str>
     a56:	test   rax,rax
     a59:	jne    a7d <botlish_fn_5+0x134>
     a5f:	xor    rdx,rdx
     a62:	mov    rax,rdx
     a65:	mov    rbx,QWORD PTR [rsp+0x30]
     a6a:	mov    r12,QWORD PTR [rsp+0x38]
     a6f:	mov    r13,QWORD PTR [rsp+0x40]
     a74:	add    rsp,0x50
     a78:	mov    rsp,rbp
     a7b:	pop    rbp
     a7c:	ret
     a7d:	mov    rbx,QWORD PTR [rsp+0x30]
     a82:	mov    r12,QWORD PTR [rsp+0x38]
     a87:	mov    r13,QWORD PTR [rsp+0x40]
     a8c:	add    rsp,0x50
     a90:	mov    rsp,rbp
     a93:	pop    rbp
     a94:	ret

0000000000000a95 <botlish_entry_5: scan_field<str, int>>:
     a95:	push   rbp
     a96:	mov    rbp,rsp
     a99:	ud2

0000000000000a9b <botlish_fn_6: scan_record<str, int, List[never]>>:
     a9b:	push   rbp
     a9c:	mov    rbp,rsp
     a9f:	sub    rsp,0xa0
     aa6:	mov    QWORD PTR [rsp+0x70],rbx
     aab:	mov    QWORD PTR [rsp+0x78],r12
     ab0:	mov    QWORD PTR [rsp+0x80],r13
     ab8:	mov    QWORD PTR [rsp+0x88],r14
     ac0:	mov    QWORD PTR [rsp+0x90],r15
     ac8:	mov    r13,rdi
     acb:	mov    QWORD PTR [rsp+0x18],0x0
     ad4:	mov    QWORD PTR [rsp+0x20],0x0
     add:	mov    QWORD PTR [rsp],rsi
     ae1:	mov    r15,rsi
     ae4:	mov    QWORD PTR [rsp+0x8],rdx
     ae9:	mov    QWORD PTR [rsp+0x10],rcx
     aee:	mov    QWORD PTR [rsp+0x58],rcx
     af3:	mov    rsi,r15
     af6:	mov    rdi,r13
     af9:	call   afe <botlish_fn_6+0x63>
			afa: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     afe:	test   rax,rax
     b01:	je     d1c <botlish_fn_6+0x281>
     b07:	mov    QWORD PTR [rsp+0x8],rax
     b0c:	mov    QWORD PTR [rsp+0x68],rax
     b11:	mov    QWORD PTR [rsp+0x18],rdx
     b16:	mov    r14,rdx
     b19:	lea    rcx,[rsp+0x28]
     b1e:	mov    rsi,r15
     b21:	mov    rdi,r13
     b24:	call   b29 <botlish_fn_6+0x8e>
			b25: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     b29:	test   rax,rax
     b2c:	mov    QWORD PTR [rsp+0x60],rax
     b31:	je     d1c <botlish_fn_6+0x281>
     b37:	mov    r12,QWORD PTR [rsp+0x28]
     b3c:	mov    rbx,QWORD PTR [rsp+0x30]
     b41:	mov    rdi,r13
     b44:	mov    rcx,QWORD PTR [rdi+0x10]
     b48:	mov    r8,QWORD PTR [rcx+0x10]
     b4c:	mov    rcx,rbx
     b4f:	mov    rdx,r12
     b52:	mov    rsi,QWORD PTR [rsp+0x60]
     b57:	call   b5c <botlish_fn_6+0xc1>
			b58: R_X86_64_PLT32	rt_str_region_eq-0x4
     b5c:	cmp    rax,0x6
     b60:	je     c72 <botlish_fn_6+0x1d7>
     b66:	mov    rdi,r13
     b69:	mov    rax,QWORD PTR [rdi+0x10]
     b6d:	mov    r8,QWORD PTR [rax+0x18]
     b71:	mov    rcx,rbx
     b74:	mov    rdx,r12
     b77:	mov    rsi,QWORD PTR [rsp+0x60]
     b7c:	call   b81 <botlish_fn_6+0xe6>
			b7d: R_X86_64_PLT32	rt_str_region_eq-0x4
     b81:	cmp    rax,0x6
     b85:	je     bd7 <botlish_fn_6+0x13c>
     b8b:	mov    rdx,QWORD PTR [rsp+0x68]
     b90:	mov    rsi,QWORD PTR [rsp+0x58]
     b95:	mov    rdi,r13
     b98:	call   b9d <botlish_fn_6+0x102>
			b99: R_X86_64_PLT32	rt_list_append-0x4
     b9d:	test   rax,rax
     ba0:	je     d1c <botlish_fn_6+0x281>
     ba6:	mov    rdx,r14
     ba9:	mov    rbx,QWORD PTR [rsp+0x70]
     bae:	mov    r12,QWORD PTR [rsp+0x78]
     bb3:	mov    r13,QWORD PTR [rsp+0x80]
     bbb:	mov    r14,QWORD PTR [rsp+0x88]
     bc3:	mov    r15,QWORD PTR [rsp+0x90]
     bcb:	add    rsp,0xa0
     bd2:	mov    rsp,rbp
     bd5:	pop    rbp
     bd6:	ret
     bd7:	mov    rdx,QWORD PTR [rsp+0x68]
     bdc:	mov    rsi,QWORD PTR [rsp+0x58]
     be1:	mov    rdi,r13
     be4:	call   be9 <botlish_fn_6+0x14e>
			be5: R_X86_64_PLT32	rt_list_append-0x4
     be9:	test   rax,rax
     bec:	je     d1c <botlish_fn_6+0x281>
     bf2:	mov    QWORD PTR [rsp],rax
     bf6:	mov    r12,rax
     bf9:	mov    QWORD PTR [rsp+0x8],0x3
     c02:	mov    rdx,r14
     c05:	test   rdx,0x1
     c0c:	je     c2e <botlish_fn_6+0x193>
     c12:	mov    rdx,r14
     c15:	add    rdx,0x2
     c19:	seto   sil
     c1d:	test   sil,sil
     c20:	jne    c2e <botlish_fn_6+0x193>
     c26:	mov    rax,r12
     c29:	jmp    c44 <botlish_fn_6+0x1a9>
     c2e:	mov    edx,0x3
     c33:	mov    rsi,r14
     c36:	mov    rdi,r13
     c39:	call   c3e <botlish_fn_6+0x1a3>
			c3a: R_X86_64_PLT32	rt_int_add-0x4
     c3e:	mov    rdx,rax
     c41:	mov    rax,r12
     c44:	mov    rbx,QWORD PTR [rsp+0x70]
     c49:	mov    r12,QWORD PTR [rsp+0x78]
     c4e:	mov    r13,QWORD PTR [rsp+0x80]
     c56:	mov    r14,QWORD PTR [rsp+0x88]
     c5e:	mov    r15,QWORD PTR [rsp+0x90]
     c66:	add    rsp,0xa0
     c6d:	mov    rsp,rbp
     c70:	pop    rbp
     c71:	ret
     c72:	mov    rsi,r14
     c75:	mov    r12d,0x3
     c7b:	mov    QWORD PTR [rsp+0x20],0x3
     c84:	test   rsi,0x1
     c8b:	je     ca3 <botlish_fn_6+0x208>
     c91:	mov    rdx,rsi
     c94:	add    rdx,0x2
     c98:	seto   al
     c9b:	test   al,al
     c9d:	je     cb1 <botlish_fn_6+0x216>
     ca3:	mov    rdx,r12
     ca6:	mov    rdi,r13
     ca9:	call   cae <botlish_fn_6+0x213>
			caa: R_X86_64_PLT32	rt_int_add-0x4
     cae:	mov    rdx,rax
     cb1:	mov    QWORD PTR [rsp+0x18],rdx
     cb6:	mov    rbx,rdx
     cb9:	lea    rcx,[rsp+0x38]
     cbe:	mov    QWORD PTR [rsp+0x38],0x0
     cc7:	mov    rsi,QWORD PTR [rsp+0x58]
     ccc:	mov    QWORD PTR [rsp+0x40],rsi
     cd1:	mov    QWORD PTR [rsp+0x48],0x2
     cda:	mov    rdx,QWORD PTR [rsp+0x68]
     cdf:	mov    QWORD PTR [rsp+0x50],rdx
     ce4:	mov    edx,0x4
     ce9:	mov    rsi,r12
     cec:	mov    rdi,r13
     cef:	call   cf4 <botlish_fn_6+0x259>
			cf0: R_X86_64_PLT32	rt_construct-0x4
     cf4:	test   rax,rax
     cf7:	je     d1c <botlish_fn_6+0x281>
     cfd:	mov    QWORD PTR [rsp+0x8],rax
     d02:	mov    rcx,rax
     d05:	mov    rdx,rbx
     d08:	mov    rsi,r15
     d0b:	mov    rdi,r13
     d0e:	call   d13 <botlish_fn_6+0x278>
			d0f: R_X86_64_PLT32	botlish_fn_7-0x4 ; scan_record<str, int, List[str]>
     d13:	test   rax,rax
     d16:	jne    d50 <botlish_fn_6+0x2b5>
     d1c:	xor    rdx,rdx
     d1f:	mov    rax,rdx
     d22:	mov    rbx,QWORD PTR [rsp+0x70]
     d27:	mov    r12,QWORD PTR [rsp+0x78]
     d2c:	mov    r13,QWORD PTR [rsp+0x80]
     d34:	mov    r14,QWORD PTR [rsp+0x88]
     d3c:	mov    r15,QWORD PTR [rsp+0x90]
     d44:	add    rsp,0xa0
     d4b:	mov    rsp,rbp
     d4e:	pop    rbp
     d4f:	ret
     d50:	mov    rbx,QWORD PTR [rsp+0x70]
     d55:	mov    r12,QWORD PTR [rsp+0x78]
     d5a:	mov    r13,QWORD PTR [rsp+0x80]
     d62:	mov    r14,QWORD PTR [rsp+0x88]
     d6a:	mov    r15,QWORD PTR [rsp+0x90]
     d72:	add    rsp,0xa0
     d79:	mov    rsp,rbp
     d7c:	pop    rbp
     d7d:	ret

0000000000000d7e <botlish_entry_6: scan_record<str, int, List[never]>>:
     d7e:	push   rbp
     d7f:	mov    rbp,rsp
     d82:	ud2

0000000000000d84 <botlish_fn_7: scan_record<str, int, List[str]>>:
     d84:	push   rbp
     d85:	mov    rbp,rsp
     d88:	sub    rsp,0xf0
     d8f:	mov    QWORD PTR [rsp+0xc0],rbx
     d97:	mov    QWORD PTR [rsp+0xc8],r12
     d9f:	mov    QWORD PTR [rsp+0xd0],r13
     da7:	mov    QWORD PTR [rsp+0xd8],r14
     daf:	mov    QWORD PTR [rsp+0xe0],r15
     db7:	mov    QWORD PTR [rsp+0x98],rdi
     dbf:	mov    QWORD PTR [rsp+0x18],0x0
     dc8:	mov    QWORD PTR [rsp+0x20],0x0
     dd1:	mov    QWORD PTR [rsp],rsi
     dd5:	mov    QWORD PTR [rsp+0x8],rdx
     dda:	mov    QWORD PTR [rsp+0xa0],rdx
     de2:	mov    QWORD PTR [rsp+0x10],rcx
     de7:	mov    r15,rcx
     dea:	lea    rbx,[rsp+0x28]
     def:	mov    r12,rsi
     df2:	mov    rsi,r12
     df5:	mov    rdi,QWORD PTR [rsp+0x98]
     dfd:	call   e02 <botlish_fn_7+0x7e>
			dfe: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     e02:	test   rax,rax
     e05:	je     10c2 <botlish_fn_7+0x33e>
     e0b:	mov    QWORD PTR [rsp+0x8],rax
     e10:	mov    QWORD PTR [rsp+0xb0],rax
     e18:	mov    QWORD PTR [rsp+0x18],rdx
     e1d:	mov    QWORD PTR [rsp+0xb8],rdx
     e25:	mov    rcx,rbx
     e28:	mov    rsi,r12
     e2b:	mov    rdi,QWORD PTR [rsp+0x98]
     e33:	call   e38 <botlish_fn_7+0xb4>
			e34: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     e38:	test   rax,rax
     e3b:	mov    QWORD PTR [rsp+0xa8],rax
     e43:	je     10c2 <botlish_fn_7+0x33e>
     e49:	mov    r13,QWORD PTR [rsp+0x28]
     e4e:	mov    r14,QWORD PTR [rsp+0x30]
     e53:	mov    rdi,QWORD PTR [rsp+0x98]
     e5b:	mov    rcx,QWORD PTR [rdi+0x10]
     e5f:	mov    r8,QWORD PTR [rcx+0x10]
     e63:	mov    rcx,r14
     e66:	mov    rdx,r13
     e69:	mov    rsi,QWORD PTR [rsp+0xa8]
     e71:	call   e76 <botlish_fn_7+0xf2>
			e72: R_X86_64_PLT32	rt_str_region_eq-0x4
     e76:	cmp    rax,0x6
     e7a:	je     1022 <botlish_fn_7+0x29e>
     e80:	mov    rdi,QWORD PTR [rsp+0x98]
     e88:	mov    rax,QWORD PTR [rdi+0x10]
     e8c:	mov    r8,QWORD PTR [rax+0x18]
     e90:	mov    rcx,r14
     e93:	mov    rdx,r13
     e96:	mov    rsi,QWORD PTR [rsp+0xa8]
     e9e:	call   ea3 <botlish_fn_7+0x11f>
			e9f: R_X86_64_PLT32	rt_str_region_eq-0x4
     ea3:	cmp    rax,0x6
     ea7:	je     f3e <botlish_fn_7+0x1ba>
     ead:	lea    rcx,[rsp+0x78]
     eb2:	mov    QWORD PTR [rsp+0x78],0x0
     ebb:	mov    r14,r15
     ebe:	mov    QWORD PTR [rsp+0x80],r14
     ec6:	mov    QWORD PTR [rsp+0x88],0x2
     ed2:	mov    r15,QWORD PTR [rsp+0xb0]
     eda:	mov    QWORD PTR [rsp+0x90],r15
     ee2:	mov    esi,0x1
     ee7:	mov    edx,0x4
     eec:	mov    rdi,QWORD PTR [rsp+0x98]
     ef4:	call   ef9 <botlish_fn_7+0x175>
			ef5: R_X86_64_PLT32	rt_construct-0x4
     ef9:	test   rax,rax
     efc:	je     10c2 <botlish_fn_7+0x33e>
     f02:	mov    rdx,QWORD PTR [rsp+0xb8]
     f0a:	mov    rbx,QWORD PTR [rsp+0xc0]
     f12:	mov    r12,QWORD PTR [rsp+0xc8]
     f1a:	mov    r13,QWORD PTR [rsp+0xd0]
     f22:	mov    r14,QWORD PTR [rsp+0xd8]
     f2a:	mov    r15,QWORD PTR [rsp+0xe0]
     f32:	add    rsp,0xf0
     f39:	mov    rsp,rbp
     f3c:	pop    rbp
     f3d:	ret
     f3e:	mov    r14,r15
     f41:	mov    r15,QWORD PTR [rsp+0xb0]
     f49:	lea    rcx,[rsp+0x58]
     f4e:	mov    QWORD PTR [rsp+0x58],0x0
     f57:	mov    QWORD PTR [rsp+0x60],r14
     f5c:	mov    QWORD PTR [rsp+0x68],0x2
     f65:	mov    QWORD PTR [rsp+0x70],r15
     f6a:	mov    esi,0x1
     f6f:	mov    edx,0x4
     f74:	mov    rdi,QWORD PTR [rsp+0x98]
     f7c:	call   f81 <botlish_fn_7+0x1fd>
			f7d: R_X86_64_PLT32	rt_construct-0x4
     f81:	test   rax,rax
     f84:	je     10c2 <botlish_fn_7+0x33e>
     f8a:	mov    QWORD PTR [rsp],rax
     f8e:	mov    r12,rax
     f91:	mov    QWORD PTR [rsp+0x8],0x3
     f9a:	mov    rdx,QWORD PTR [rsp+0xb8]
     fa2:	test   rdx,0x1
     fa9:	je     fce <botlish_fn_7+0x24a>
     faf:	mov    rdx,QWORD PTR [rsp+0xb8]
     fb7:	add    rdx,0x2
     fbb:	seto   al
     fbe:	test   al,al
     fc0:	jne    fce <botlish_fn_7+0x24a>
     fc6:	mov    rax,r12
     fc9:	jmp    fee <botlish_fn_7+0x26a>
     fce:	mov    edx,0x3
     fd3:	mov    rsi,QWORD PTR [rsp+0xb8]
     fdb:	mov    rdi,QWORD PTR [rsp+0x98]
     fe3:	call   fe8 <botlish_fn_7+0x264>
			fe4: R_X86_64_PLT32	rt_int_add-0x4
     fe8:	mov    rdx,rax
     feb:	mov    rax,r12
     fee:	mov    rbx,QWORD PTR [rsp+0xc0]
     ff6:	mov    r12,QWORD PTR [rsp+0xc8]
     ffe:	mov    r13,QWORD PTR [rsp+0xd0]
    1006:	mov    r14,QWORD PTR [rsp+0xd8]
    100e:	mov    r15,QWORD PTR [rsp+0xe0]
    1016:	add    rsp,0xf0
    101d:	mov    rsp,rbp
    1020:	pop    rbp
    1021:	ret
    1022:	mov    r14,r15
    1025:	mov    r15,QWORD PTR [rsp+0xb0]
    102d:	mov    rsi,QWORD PTR [rsp+0xb8]
    1035:	mov    r13d,0x3
    103b:	mov    QWORD PTR [rsp+0x20],0x3
    1044:	test   rsi,0x1
    104b:	je     1063 <botlish_fn_7+0x2df>
    1051:	mov    rdx,rsi
    1054:	add    rdx,0x2
    1058:	seto   al
    105b:	test   al,al
    105d:	je     1076 <botlish_fn_7+0x2f2>
    1063:	mov    rdx,r13
    1066:	mov    rdi,QWORD PTR [rsp+0x98]
    106e:	call   1073 <botlish_fn_7+0x2ef>
			106f: R_X86_64_PLT32	rt_int_add-0x4
    1073:	mov    rdx,rax
    1076:	mov    QWORD PTR [rsp+0x18],rdx
    107b:	mov    QWORD PTR [rsp+0xa0],rdx
    1083:	lea    rcx,[rsp+0x38]
    1088:	mov    QWORD PTR [rsp+0x38],0x0
    1091:	mov    QWORD PTR [rsp+0x40],r14
    1096:	mov    QWORD PTR [rsp+0x48],0x2
    109f:	mov    QWORD PTR [rsp+0x50],r15
    10a4:	mov    edx,0x4
    10a9:	mov    rsi,r13
    10ac:	mov    rdi,QWORD PTR [rsp+0x98]
    10b4:	call   10b9 <botlish_fn_7+0x335>
			10b5: R_X86_64_PLT32	rt_construct-0x4
    10b9:	test   rax,rax
    10bc:	jne    10fc <botlish_fn_7+0x378>
    10c2:	xor    rdx,rdx
    10c5:	mov    rax,rdx
    10c8:	mov    rbx,QWORD PTR [rsp+0xc0]
    10d0:	mov    r12,QWORD PTR [rsp+0xc8]
    10d8:	mov    r13,QWORD PTR [rsp+0xd0]
    10e0:	mov    r14,QWORD PTR [rsp+0xd8]
    10e8:	mov    r15,QWORD PTR [rsp+0xe0]
    10f0:	add    rsp,0xf0
    10f7:	mov    rsp,rbp
    10fa:	pop    rbp
    10fb:	ret
    10fc:	mov    QWORD PTR [rsp],r12
    1100:	mov    rdx,QWORD PTR [rsp+0xa0]
    1108:	mov    QWORD PTR [rsp+0x8],rdx
    110d:	mov    QWORD PTR [rsp+0x10],rax
    1112:	mov    r15,rax
    1115:	jmp    df2 <botlish_fn_7+0x6e>

000000000000111a <botlish_entry_7: scan_record<str, int, List[str]>>:
    111a:	push   rbp
    111b:	mov    rbp,rsp
    111e:	ud2

0000000000001120 <botlish_fn_8: scan_records<str, int, List[never]>>:
    1120:	push   rbp
    1121:	mov    rbp,rsp
    1124:	sub    rsp,0x60
    1128:	mov    QWORD PTR [rsp+0x40],rbx
    112d:	mov    QWORD PTR [rsp+0x48],r12
    1132:	mov    QWORD PTR [rsp+0x50],r13
    1137:	mov    QWORD PTR [rsp+0x58],r14
    113c:	mov    r12,rdi
    113f:	mov    QWORD PTR [rsp+0x18],0x0
    1148:	mov    QWORD PTR [rsp],rsi
    114c:	mov    rbx,rsi
    114f:	mov    QWORD PTR [rsp+0x8],rdx
    1154:	mov    r14,rdx
    1157:	mov    QWORD PTR [rsp+0x10],rcx
    115c:	mov    r13,rcx
    115f:	mov    rsi,rbx
    1162:	mov    rdi,r12
    1165:	call   116a <botlish_fn_8+0x4a>
			1166: R_X86_64_PLT32	rt_str_len-0x4
    116a:	mov    rdx,r14
    116d:	mov    rcx,rdx
    1170:	sar    rcx,1
    1173:	sar    rax,1
    1176:	cmp    rcx,rax
    1179:	jge    125d <botlish_fn_8+0x13d>
    117f:	xor    rdx,rdx
    1182:	mov    rdi,r12
    1185:	mov    rsi,rdx
    1188:	call   118d <botlish_fn_8+0x6d>
			1189: R_X86_64_PLT32	rt_list_new-0x4
    118d:	test   rax,rax
    1190:	je     1220 <botlish_fn_8+0x100>
    1196:	mov    QWORD PTR [rsp+0x18],rax
    119b:	mov    rcx,rax
    119e:	mov    rdx,r14
    11a1:	mov    rsi,rbx
    11a4:	mov    rdi,r12
    11a7:	call   11ac <botlish_fn_8+0x8c>
			11a8: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    11ac:	test   rax,rax
    11af:	je     1220 <botlish_fn_8+0x100>
    11b5:	mov    QWORD PTR [rsp+0x8],rax
    11ba:	mov    QWORD PTR [rsp+0x18],rdx
    11bf:	mov    r14,rdx
    11c2:	lea    rcx,[rsp+0x20]
    11c7:	mov    QWORD PTR [rsp+0x20],0x0
    11d0:	mov    rdx,r13
    11d3:	mov    QWORD PTR [rsp+0x28],rdx
    11d8:	mov    QWORD PTR [rsp+0x30],0x2
    11e1:	mov    QWORD PTR [rsp+0x38],rax
    11e6:	mov    esi,0x3
    11eb:	mov    edx,0x4
    11f0:	mov    rdi,r12
    11f3:	call   11f8 <botlish_fn_8+0xd8>
			11f4: R_X86_64_PLT32	rt_construct-0x4
    11f8:	test   rax,rax
    11fb:	je     1220 <botlish_fn_8+0x100>
    1201:	mov    QWORD PTR [rsp+0x8],rax
    1206:	mov    rcx,rax
    1209:	mov    rdx,r14
    120c:	mov    rsi,rbx
    120f:	mov    rdi,r12
    1212:	call   1217 <botlish_fn_8+0xf7>
			1213: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    1217:	test   rax,rax
    121a:	jne    1240 <botlish_fn_8+0x120>
    1220:	xor    rax,rax
    1223:	mov    rbx,QWORD PTR [rsp+0x40]
    1228:	mov    r12,QWORD PTR [rsp+0x48]
    122d:	mov    r13,QWORD PTR [rsp+0x50]
    1232:	mov    r14,QWORD PTR [rsp+0x58]
    1237:	add    rsp,0x60
    123b:	mov    rsp,rbp
    123e:	pop    rbp
    123f:	ret
    1240:	mov    rbx,QWORD PTR [rsp+0x40]
    1245:	mov    r12,QWORD PTR [rsp+0x48]
    124a:	mov    r13,QWORD PTR [rsp+0x50]
    124f:	mov    r14,QWORD PTR [rsp+0x58]
    1254:	add    rsp,0x60
    1258:	mov    rsp,rbp
    125b:	pop    rbp
    125c:	ret
    125d:	mov    rax,r13
    1260:	mov    rbx,QWORD PTR [rsp+0x40]
    1265:	mov    r12,QWORD PTR [rsp+0x48]
    126a:	mov    r13,QWORD PTR [rsp+0x50]
    126f:	mov    r14,QWORD PTR [rsp+0x58]
    1274:	add    rsp,0x60
    1278:	mov    rsp,rbp
    127b:	pop    rbp
    127c:	ret

000000000000127d <botlish_entry_8: scan_records<str, int, List[never]>>:
    127d:	push   rbp
    127e:	mov    rbp,rsp
    1281:	mov    rsi,QWORD PTR [rdx]
    1284:	mov    r8,QWORD PTR [rdx+0x8]
    1288:	mov    rcx,QWORD PTR [rdx+0x10]
    128c:	mov    rdx,r8
    128f:	call   1294 <botlish_entry_8+0x17>
			1290: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    1294:	mov    rsp,rbp
    1297:	pop    rbp
    1298:	ret
    1299:	add    BYTE PTR [rax],al
    129b:	add    BYTE PTR [rax],al
    129d:	add    BYTE PTR [rax],al
	...

00000000000012a0 <botlish_fn_9: scan_records<str, int, List[List[str]]>>:
    12a0:	push   rbp
    12a1:	mov    rbp,rsp
    12a4:	sub    rsp,0x80
    12ab:	mov    QWORD PTR [rsp+0x50],rbx
    12b0:	mov    QWORD PTR [rsp+0x58],r12
    12b5:	mov    QWORD PTR [rsp+0x60],r13
    12ba:	mov    QWORD PTR [rsp+0x68],r14
    12bf:	mov    QWORD PTR [rsp+0x70],r15
    12c4:	mov    r14,rdi
    12c7:	mov    QWORD PTR [rsp+0x18],0x0
    12d0:	mov    QWORD PTR [rsp],rsi
    12d4:	mov    QWORD PTR [rsp+0x8],rdx
    12d9:	mov    r13,rdx
    12dc:	mov    QWORD PTR [rsp+0x10],rcx
    12e1:	mov    r15,rcx
    12e4:	lea    r12,[rsp+0x30]
    12e9:	mov    rbx,rsi
    12ec:	mov    rsi,rbx
    12ef:	mov    rdi,r14
    12f2:	call   12f7 <botlish_fn_9+0x57>
			12f3: R_X86_64_PLT32	rt_str_len-0x4
    12f7:	mov    rcx,r13
    12fa:	and    rcx,rax
    12fd:	mov    rdx,rax
    1300:	test   rcx,0x1
    1307:	jne    132d <botlish_fn_9+0x8d>
    130d:	mov    rsi,r13
    1310:	mov    rdi,r14
    1313:	call   1318 <botlish_fn_9+0x78>
			1314: R_X86_64_PLT32	rt_int_cmp-0x4
    1318:	mov    ecx,0x2
    131d:	test   rax,rax
    1320:	cmovge rcx,QWORD PTR [rip+0x140]        # 1468 <botlish_fn_9+0x1c8>
    1328:	jmp    1340 <botlish_fn_9+0xa0>
    132d:	mov    ecx,0x2
    1332:	mov    rax,r13
    1335:	cmp    rax,rdx
    1338:	cmovge rcx,QWORD PTR [rip+0x128]        # 1468 <botlish_fn_9+0x1c8>
    1340:	cmp    rcx,0x6
    1344:	je     13e3 <botlish_fn_9+0x143>
    134a:	xor    rdx,rdx
    134d:	mov    rdi,r14
    1350:	mov    rsi,rdx
    1353:	call   1358 <botlish_fn_9+0xb8>
			1354: R_X86_64_PLT32	rt_list_new-0x4
    1358:	test   rax,rax
    135b:	je     1414 <botlish_fn_9+0x174>
    1361:	mov    QWORD PTR [rsp+0x18],rax
    1366:	mov    rcx,rax
    1369:	mov    rdx,r13
    136c:	mov    rsi,rbx
    136f:	mov    rdi,r14
    1372:	call   1377 <botlish_fn_9+0xd7>
			1373: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    1377:	test   rax,rax
    137a:	je     1414 <botlish_fn_9+0x174>
    1380:	mov    QWORD PTR [rsp+0x8],rax
    1385:	mov    QWORD PTR [rsp+0x18],rdx
    138a:	mov    r13,rdx
    138d:	mov    QWORD PTR [rsp+0x30],0x0
    1396:	mov    r9,r15
    1399:	mov    QWORD PTR [rsp+0x38],r9
    139e:	mov    QWORD PTR [rsp+0x40],0x2
    13a7:	mov    QWORD PTR [rsp+0x48],rax
    13ac:	mov    esi,0x3
    13b1:	mov    edx,0x4
    13b6:	mov    rcx,r12
    13b9:	mov    rdi,r14
    13bc:	call   13c1 <botlish_fn_9+0x121>
			13bd: R_X86_64_PLT32	rt_construct-0x4
    13c1:	test   rax,rax
    13c4:	je     1414 <botlish_fn_9+0x174>
    13ca:	mov    QWORD PTR [rsp],rbx
    13ce:	mov    rdx,r13
    13d1:	mov    QWORD PTR [rsp+0x8],rdx
    13d6:	mov    QWORD PTR [rsp+0x10],rax
    13db:	mov    r15,rax
    13de:	jmp    12ec <botlish_fn_9+0x4c>
    13e3:	mov    r9,r15
    13e6:	lea    rcx,[rsp+0x20]
    13eb:	mov    QWORD PTR [rsp+0x20],0x0
    13f4:	mov    QWORD PTR [rsp+0x28],r9
    13f9:	mov    esi,0x1
    13fe:	mov    edx,0x2
    1403:	mov    rdi,r14
    1406:	call   140b <botlish_fn_9+0x16b>
			1407: R_X86_64_PLT32	rt_construct-0x4
    140b:	test   rax,rax
    140e:	jne    143c <botlish_fn_9+0x19c>
    1414:	xor    rax,rax
    1417:	mov    rbx,QWORD PTR [rsp+0x50]
    141c:	mov    r12,QWORD PTR [rsp+0x58]
    1421:	mov    r13,QWORD PTR [rsp+0x60]
    1426:	mov    r14,QWORD PTR [rsp+0x68]
    142b:	mov    r15,QWORD PTR [rsp+0x70]
    1430:	add    rsp,0x80
    1437:	mov    rsp,rbp
    143a:	pop    rbp
    143b:	ret
    143c:	mov    rbx,QWORD PTR [rsp+0x50]
    1441:	mov    r12,QWORD PTR [rsp+0x58]
    1446:	mov    r13,QWORD PTR [rsp+0x60]
    144b:	mov    r14,QWORD PTR [rsp+0x68]
    1450:	mov    r15,QWORD PTR [rsp+0x70]
    1455:	add    rsp,0x80
    145c:	mov    rsp,rbp
    145f:	pop    rbp
    1460:	ret
    1461:	add    BYTE PTR [rax],al
    1463:	add    BYTE PTR [rax],al
    1465:	add    BYTE PTR [rax],al
    1467:	add    BYTE PTR [rsi],al
    1469:	add    BYTE PTR [rax],al
    146b:	add    BYTE PTR [rax],al
    146d:	add    BYTE PTR [rax],al
	...

0000000000001470 <botlish_entry_9: scan_records<str, int, List[List[str]]>>:
    1470:	push   rbp
    1471:	mov    rbp,rsp
    1474:	mov    rsi,QWORD PTR [rdx]
    1477:	mov    r8,QWORD PTR [rdx+0x8]
    147b:	mov    rcx,QWORD PTR [rdx+0x10]
    147f:	mov    rdx,r8
    1482:	call   1487 <botlish_entry_9+0x17>
			1483: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    1487:	mov    rsp,rbp
    148a:	pop    rbp
    148b:	ret

000000000000148c <botlish_fn_10: csv_parse<str>>:
    148c:	push   rbp
    148d:	mov    rbp,rsp
    1490:	sub    rsp,0x30
    1494:	mov    QWORD PTR [rsp+0x20],r12
    1499:	mov    QWORD PTR [rsp+0x28],r13
    149e:	mov    r13,rdi
    14a1:	mov    QWORD PTR [rsp+0x10],0x0
    14aa:	mov    QWORD PTR [rsp],rsi
    14ae:	mov    r12,rsi
    14b1:	mov    QWORD PTR [rsp+0x8],0x1
    14ba:	xor    rdx,rdx
    14bd:	mov    rdi,r13
    14c0:	mov    rsi,rdx
    14c3:	call   14c8 <botlish_fn_10+0x3c>
			14c4: R_X86_64_PLT32	rt_list_new-0x4
    14c8:	test   rax,rax
    14cb:	je     14f2 <botlish_fn_10+0x66>
    14d1:	mov    QWORD PTR [rsp+0x10],rax
    14d6:	mov    rcx,rax
    14d9:	mov    edx,0x1
    14de:	mov    rsi,r12
    14e1:	mov    rdi,r13
    14e4:	call   14e9 <botlish_fn_10+0x5d>
			14e5: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    14e9:	test   rax,rax
    14ec:	jne    1508 <botlish_fn_10+0x7c>
    14f2:	xor    rax,rax
    14f5:	mov    r12,QWORD PTR [rsp+0x20]
    14fa:	mov    r13,QWORD PTR [rsp+0x28]
    14ff:	add    rsp,0x30
    1503:	mov    rsp,rbp
    1506:	pop    rbp
    1507:	ret
    1508:	mov    r12,QWORD PTR [rsp+0x20]
    150d:	mov    r13,QWORD PTR [rsp+0x28]
    1512:	add    rsp,0x30
    1516:	mov    rsp,rbp
    1519:	pop    rbp
    151a:	ret

000000000000151b <botlish_entry_10: csv_parse<str>>:
    151b:	push   rbp
    151c:	mov    rbp,rsp
    151f:	mov    rsi,QWORD PTR [rdx]
    1522:	call   1527 <botlish_entry_10+0xc>
			1523: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
    1527:	mov    rsp,rbp
    152a:	pop    rbp
    152b:	ret

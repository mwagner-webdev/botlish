; source:  examples/stdlib/csv.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 4731  (per function: 68 365 430 585 770 352 618 611 361 404 167)
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
     567:	sub    rsp,0x70
     56b:	mov    QWORD PTR [rsp+0x40],rbx
     570:	mov    QWORD PTR [rsp+0x48],r12
     575:	mov    QWORD PTR [rsp+0x50],r13
     57a:	mov    QWORD PTR [rsp+0x58],r14
     57f:	mov    QWORD PTR [rsp+0x60],r15
     584:	mov    r13,rdi
     587:	mov    QWORD PTR [rsp+0x18],0x0
     590:	mov    QWORD PTR [rsp+0x20],0x0
     599:	mov    QWORD PTR [rsp],rsi
     59d:	mov    QWORD PTR [rsp+0x8],rdx
     5a2:	mov    QWORD PTR [rsp+0x10],rcx
     5a7:	lea    r12,[rsp+0x28]
     5ac:	mov    rbx,rsi
     5af:	mov    r14,rdx
     5b2:	mov    r15,rcx
     5b5:	mov    rdx,r14
     5b8:	mov    rsi,rbx
     5bb:	mov    rdi,r13
     5be:	call   5c3 <botlish_fn_4+0x60>
			5bf: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     5c3:	test   rax,rax
     5c6:	je     7e2 <botlish_fn_4+0x27f>
     5cc:	mov    QWORD PTR [rsp+0x18],rax
     5d1:	mov    rdi,r13
     5d4:	mov    QWORD PTR [rsp+0x38],rax
     5d9:	mov    rcx,QWORD PTR [rdi+0x10]
     5dd:	mov    rsi,QWORD PTR [rcx+0x20]
     5e1:	mov    edx,0x1
     5e6:	mov    ecx,0x3
     5eb:	mov    r8,QWORD PTR [rsp+0x38]
     5f0:	call   5f5 <botlish_fn_4+0x92>
			5f1: R_X86_64_PLT32	rt_str_region_eq-0x4
     5f5:	cmp    rax,0x6
     5f9:	je     67c <botlish_fn_4+0x119>
     5ff:	mov    QWORD PTR [rsp+0x20],0x3
     608:	mov    rsi,r14
     60b:	test   rsi,0x1
     612:	je     632 <botlish_fn_4+0xcf>
     618:	mov    rax,rsi
     61b:	add    rax,0x2
     61f:	seto   cl
     622:	test   cl,cl
     624:	jne    632 <botlish_fn_4+0xcf>
     62a:	mov    rsi,rax
     62d:	jmp    642 <botlish_fn_4+0xdf>
     632:	mov    edx,0x3
     637:	mov    rdi,r13
     63a:	call   63f <botlish_fn_4+0xdc>
			63b: R_X86_64_PLT32	rt_int_add-0x4
     63f:	mov    rsi,rax
     642:	mov    QWORD PTR [rsp+0x8],rsi
     647:	mov    r14,rsi
     64a:	mov    rsi,r15
     64d:	mov    rdx,QWORD PTR [rsp+0x38]
     652:	mov    rdi,r13
     655:	call   65a <botlish_fn_4+0xf7>
			656: R_X86_64_PLT32	rt_str_cat-0x4
     65a:	test   rax,rax
     65d:	je     7e2 <botlish_fn_4+0x27f>
     663:	mov    QWORD PTR [rsp],rbx
     667:	mov    rsi,r14
     66a:	mov    QWORD PTR [rsp+0x8],rsi
     66f:	mov    QWORD PTR [rsp+0x10],rax
     674:	mov    r15,rax
     677:	jmp    5b5 <botlish_fn_4+0x52>
     67c:	mov    QWORD PTR [rsp+0x18],0x3
     685:	mov    rsi,r14
     688:	test   rsi,0x1
     68f:	je     6aa <botlish_fn_4+0x147>
     695:	mov    rsi,r14
     698:	mov    rdx,rsi
     69b:	add    rdx,0x2
     69f:	seto   al
     6a2:	test   al,al
     6a4:	je     6bd <botlish_fn_4+0x15a>
     6aa:	mov    edx,0x3
     6af:	mov    rsi,r14
     6b2:	mov    rdi,r13
     6b5:	call   6ba <botlish_fn_4+0x157>
			6b6: R_X86_64_PLT32	rt_int_add-0x4
     6ba:	mov    rdx,rax
     6bd:	mov    QWORD PTR [rsp+0x18],rdx
     6c2:	mov    rcx,r12
     6c5:	mov    rsi,rbx
     6c8:	mov    rdi,r13
     6cb:	call   6d0 <botlish_fn_4+0x16d>
			6cc: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     6d0:	test   rax,rax
     6d3:	mov    rsi,rax
     6d6:	je     7e2 <botlish_fn_4+0x27f>
     6dc:	mov    rdx,QWORD PTR [rsp+0x28]
     6e1:	mov    rcx,QWORD PTR [rsp+0x30]
     6e6:	mov    rdi,r13
     6e9:	mov    rax,QWORD PTR [rdi+0x10]
     6ed:	mov    r8,QWORD PTR [rax+0x20]
     6f1:	call   6f6 <botlish_fn_4+0x193>
			6f2: R_X86_64_PLT32	rt_str_region_eq-0x4
     6f6:	cmp    rax,0x6
     6fa:	je     76d <botlish_fn_4+0x20a>
     700:	mov    QWORD PTR [rsp],0x3
     708:	mov    rsi,r14
     70b:	test   rsi,0x1
     712:	je     735 <botlish_fn_4+0x1d2>
     718:	mov    rsi,r14
     71b:	mov    rdx,rsi
     71e:	add    rdx,0x2
     722:	seto   al
     725:	test   al,al
     727:	jne    735 <botlish_fn_4+0x1d2>
     72d:	mov    rax,r15
     730:	jmp    74b <botlish_fn_4+0x1e8>
     735:	mov    edx,0x3
     73a:	mov    rsi,r14
     73d:	mov    rdi,r13
     740:	call   745 <botlish_fn_4+0x1e2>
			741: R_X86_64_PLT32	rt_int_add-0x4
     745:	mov    rdx,rax
     748:	mov    rax,r15
     74b:	mov    rbx,QWORD PTR [rsp+0x40]
     750:	mov    r12,QWORD PTR [rsp+0x48]
     755:	mov    r13,QWORD PTR [rsp+0x50]
     75a:	mov    r14,QWORD PTR [rsp+0x58]
     75f:	mov    r15,QWORD PTR [rsp+0x60]
     764:	add    rsp,0x70
     768:	mov    rsp,rbp
     76b:	pop    rbp
     76c:	ret
     76d:	mov    QWORD PTR [rsp+0x18],0x5
     776:	mov    rsi,r14
     779:	test   rsi,0x1
     780:	je     7a6 <botlish_fn_4+0x243>
     786:	mov    rsi,r14
     789:	mov    rax,rsi
     78c:	add    rax,0x4
     790:	seto   cl
     793:	test   cl,cl
     795:	jne    7a6 <botlish_fn_4+0x243>
     79b:	mov    rsi,rax
     79e:	mov    r14,rax
     7a1:	jmp    7bc <botlish_fn_4+0x259>
     7a6:	mov    edx,0x5
     7ab:	mov    rsi,r14
     7ae:	mov    rdi,r13
     7b1:	call   7b6 <botlish_fn_4+0x253>
			7b2: R_X86_64_PLT32	rt_int_add-0x4
     7b6:	mov    rsi,rax
     7b9:	mov    r14,rax
     7bc:	mov    QWORD PTR [rsp+0x8],rsi
     7c1:	mov    rdi,r13
     7c4:	mov    rax,QWORD PTR [rdi+0x10]
     7c8:	mov    rdx,QWORD PTR [rax+0x20]
     7cc:	mov    QWORD PTR [rsp+0x18],rdx
     7d1:	mov    rsi,r15
     7d4:	call   7d9 <botlish_fn_4+0x276>
			7d5: R_X86_64_PLT32	rt_str_cat-0x4
     7d9:	test   rax,rax
     7dc:	jne    80a <botlish_fn_4+0x2a7>
     7e2:	xor    rdx,rdx
     7e5:	mov    rax,rdx
     7e8:	mov    rbx,QWORD PTR [rsp+0x40]
     7ed:	mov    r12,QWORD PTR [rsp+0x48]
     7f2:	mov    r13,QWORD PTR [rsp+0x50]
     7f7:	mov    r14,QWORD PTR [rsp+0x58]
     7fc:	mov    r15,QWORD PTR [rsp+0x60]
     801:	add    rsp,0x70
     805:	mov    rsp,rbp
     808:	pop    rbp
     809:	ret
     80a:	mov    QWORD PTR [rsp],rbx
     80e:	mov    rsi,r14
     811:	mov    QWORD PTR [rsp+0x8],rsi
     816:	mov    QWORD PTR [rsp+0x10],rax
     81b:	mov    r15,rax
     81e:	jmp    5b5 <botlish_fn_4+0x52>

0000000000000823 <botlish_entry_4: scan_quoted<str, int, str>>:
     823:	push   rbp
     824:	mov    rbp,rsp
     827:	ud2

0000000000000829 <botlish_fn_5: scan_field<str, int>>:
     829:	push   rbp
     82a:	mov    rbp,rsp
     82d:	sub    rsp,0x50
     831:	mov    QWORD PTR [rsp+0x30],rbx
     836:	mov    QWORD PTR [rsp+0x38],r12
     83b:	mov    QWORD PTR [rsp+0x40],r13
     840:	mov    r12,rdi
     843:	mov    r13,rdx
     846:	mov    QWORD PTR [rsp+0x10],0x0
     84f:	mov    QWORD PTR [rsp],rsi
     853:	mov    rbx,rsi
     856:	mov    QWORD PTR [rsp+0x8],rdx
     85b:	lea    rcx,[rsp+0x18]
     860:	mov    rdx,r13
     863:	mov    rsi,rbx
     866:	mov    rdi,r12
     869:	call   86e <botlish_fn_5+0x45>
			86a: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     86e:	test   rax,rax
     871:	mov    rsi,rax
     874:	je     93f <botlish_fn_5+0x116>
     87a:	mov    rdx,QWORD PTR [rsp+0x18]
     87f:	mov    rcx,QWORD PTR [rsp+0x20]
     884:	mov    rdi,r12
     887:	mov    rax,QWORD PTR [rdi+0x10]
     88b:	mov    r8,QWORD PTR [rax+0x20]
     88f:	call   894 <botlish_fn_5+0x6b>
			890: R_X86_64_PLT32	rt_str_region_eq-0x4
     894:	cmp    rax,0x6
     898:	je     8d0 <botlish_fn_5+0xa7>
     89e:	mov    rcx,r13
     8a1:	mov    rsi,rbx
     8a4:	mov    rdi,r12
     8a7:	mov    rdx,rcx
     8aa:	call   8af <botlish_fn_5+0x86>
			8ab: R_X86_64_PLT32	botlish_fn_3-0x4 ; scan_unquoted<str, int, int>
     8af:	test   rax,rax
     8b2:	je     93f <botlish_fn_5+0x116>
     8b8:	mov    rbx,QWORD PTR [rsp+0x30]
     8bd:	mov    r12,QWORD PTR [rsp+0x38]
     8c2:	mov    r13,QWORD PTR [rsp+0x40]
     8c7:	add    rsp,0x50
     8cb:	mov    rsp,rbp
     8ce:	pop    rbp
     8cf:	ret
     8d0:	mov    rcx,r13
     8d3:	mov    QWORD PTR [rsp+0x10],0x3
     8dc:	test   rcx,0x1
     8e3:	jne    8f1 <botlish_fn_5+0xc8>
     8e9:	mov    r13,rcx
     8ec:	jmp    906 <botlish_fn_5+0xdd>
     8f1:	mov    rdx,rcx
     8f4:	add    rdx,0x2
     8f8:	mov    r13,rcx
     8fb:	seto   al
     8fe:	test   al,al
     900:	je     919 <botlish_fn_5+0xf0>
     906:	mov    edx,0x3
     90b:	mov    rsi,r13
     90e:	mov    rdi,r12
     911:	call   916 <botlish_fn_5+0xed>
			912: R_X86_64_PLT32	rt_int_add-0x4
     916:	mov    rdx,rax
     919:	mov    QWORD PTR [rsp+0x8],rdx
     91e:	mov    rdi,r12
     921:	mov    rax,QWORD PTR [rdi+0x10]
     925:	mov    rcx,QWORD PTR [rax+0x8]
     929:	mov    QWORD PTR [rsp+0x10],rcx
     92e:	mov    rsi,rbx
     931:	call   936 <botlish_fn_5+0x10d>
			932: R_X86_64_PLT32	botlish_fn_4-0x4 ; scan_quoted<str, int, str>
     936:	test   rax,rax
     939:	jne    95d <botlish_fn_5+0x134>
     93f:	xor    rdx,rdx
     942:	mov    rax,rdx
     945:	mov    rbx,QWORD PTR [rsp+0x30]
     94a:	mov    r12,QWORD PTR [rsp+0x38]
     94f:	mov    r13,QWORD PTR [rsp+0x40]
     954:	add    rsp,0x50
     958:	mov    rsp,rbp
     95b:	pop    rbp
     95c:	ret
     95d:	mov    rbx,QWORD PTR [rsp+0x30]
     962:	mov    r12,QWORD PTR [rsp+0x38]
     967:	mov    r13,QWORD PTR [rsp+0x40]
     96c:	add    rsp,0x50
     970:	mov    rsp,rbp
     973:	pop    rbp
     974:	ret

0000000000000975 <botlish_entry_5: scan_field<str, int>>:
     975:	push   rbp
     976:	mov    rbp,rsp
     979:	ud2

000000000000097b <botlish_fn_6: scan_record<str, int, List[never]>>:
     97b:	push   rbp
     97c:	mov    rbp,rsp
     97f:	sub    rsp,0x70
     983:	mov    QWORD PTR [rsp+0x40],rbx
     988:	mov    QWORD PTR [rsp+0x48],r12
     98d:	mov    QWORD PTR [rsp+0x50],r13
     992:	mov    QWORD PTR [rsp+0x58],r14
     997:	mov    QWORD PTR [rsp+0x60],r15
     99c:	mov    r13,rdi
     99f:	mov    QWORD PTR [rsp+0x18],0x0
     9a8:	mov    QWORD PTR [rsp],rsi
     9ac:	mov    QWORD PTR [rsp+0x30],rsi
     9b1:	mov    QWORD PTR [rsp+0x8],rdx
     9b6:	mov    QWORD PTR [rsp+0x10],rcx
     9bb:	mov    rbx,rcx
     9be:	mov    rsi,QWORD PTR [rsp+0x30]
     9c3:	mov    rdi,r13
     9c6:	call   9cb <botlish_fn_6+0x50>
			9c7: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     9cb:	test   rax,rax
     9ce:	je     b75 <botlish_fn_6+0x1fa>
     9d4:	mov    QWORD PTR [rsp+0x8],rax
     9d9:	mov    QWORD PTR [rsp+0x18],rdx
     9de:	mov    r15,rdx
     9e1:	mov    rsi,rbx
     9e4:	mov    rdx,rax
     9e7:	mov    rdi,r13
     9ea:	call   9ef <botlish_fn_6+0x74>
			9eb: R_X86_64_PLT32	rt_list_append-0x4
     9ef:	test   rax,rax
     9f2:	je     b75 <botlish_fn_6+0x1fa>
     9f8:	mov    QWORD PTR [rsp+0x8],rax
     9fd:	mov    r14,rax
     a00:	lea    rcx,[rsp+0x20]
     a05:	mov    rdx,r15
     a08:	mov    rsi,QWORD PTR [rsp+0x30]
     a0d:	mov    rdi,r13
     a10:	call   a15 <botlish_fn_6+0x9a>
			a11: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     a15:	test   rax,rax
     a18:	mov    QWORD PTR [rsp+0x38],rax
     a1d:	je     b75 <botlish_fn_6+0x1fa>
     a23:	mov    rbx,QWORD PTR [rsp+0x20]
     a28:	mov    r12,QWORD PTR [rsp+0x28]
     a2d:	mov    rdi,r13
     a30:	mov    rcx,QWORD PTR [rdi+0x10]
     a34:	mov    r8,QWORD PTR [rcx+0x10]
     a38:	mov    rcx,r12
     a3b:	mov    rdx,rbx
     a3e:	mov    rsi,QWORD PTR [rsp+0x38]
     a43:	call   a48 <botlish_fn_6+0xcd>
			a44: R_X86_64_PLT32	rt_str_region_eq-0x4
     a48:	cmp    rax,0x6
     a4c:	je     b0c <botlish_fn_6+0x191>
     a52:	mov    rdi,r13
     a55:	mov    rax,QWORD PTR [rdi+0x10]
     a59:	mov    r8,QWORD PTR [rax+0x18]
     a5d:	mov    rcx,r12
     a60:	mov    rdx,rbx
     a63:	mov    rsi,QWORD PTR [rsp+0x38]
     a68:	call   a6d <botlish_fn_6+0xf2>
			a69: R_X86_64_PLT32	rt_str_region_eq-0x4
     a6d:	cmp    rax,0x6
     a71:	je     a9f <botlish_fn_6+0x124>
     a77:	mov    rax,r14
     a7a:	mov    rdx,r15
     a7d:	mov    rbx,QWORD PTR [rsp+0x40]
     a82:	mov    r12,QWORD PTR [rsp+0x48]
     a87:	mov    r13,QWORD PTR [rsp+0x50]
     a8c:	mov    r14,QWORD PTR [rsp+0x58]
     a91:	mov    r15,QWORD PTR [rsp+0x60]
     a96:	add    rsp,0x70
     a9a:	mov    rsp,rbp
     a9d:	pop    rbp
     a9e:	ret
     a9f:	mov    QWORD PTR [rsp],0x3
     aa7:	mov    rdx,r15
     aaa:	test   rdx,0x1
     ab1:	je     ad1 <botlish_fn_6+0x156>
     ab7:	mov    rdx,r15
     aba:	add    rdx,0x2
     abe:	seto   al
     ac1:	test   al,al
     ac3:	jne    ad1 <botlish_fn_6+0x156>
     ac9:	mov    rax,r14
     acc:	jmp    ae7 <botlish_fn_6+0x16c>
     ad1:	mov    edx,0x3
     ad6:	mov    rsi,r15
     ad9:	mov    rdi,r13
     adc:	call   ae1 <botlish_fn_6+0x166>
			add: R_X86_64_PLT32	rt_int_add-0x4
     ae1:	mov    rdx,rax
     ae4:	mov    rax,r14
     ae7:	mov    rax,r14
     aea:	mov    rbx,QWORD PTR [rsp+0x40]
     aef:	mov    r12,QWORD PTR [rsp+0x48]
     af4:	mov    r13,QWORD PTR [rsp+0x50]
     af9:	mov    r14,QWORD PTR [rsp+0x58]
     afe:	mov    r15,QWORD PTR [rsp+0x60]
     b03:	add    rsp,0x70
     b07:	mov    rsp,rbp
     b0a:	pop    rbp
     b0b:	ret
     b0c:	mov    rsi,r15
     b0f:	mov    edx,0x3
     b14:	mov    rax,rdx
     b17:	mov    QWORD PTR [rsp+0x10],0x3
     b20:	test   rsi,0x1
     b27:	jne    b35 <botlish_fn_6+0x1ba>
     b2d:	mov    rdx,rax
     b30:	jmp    b4c <botlish_fn_6+0x1d1>
     b35:	mov    rdx,rsi
     b38:	add    rdx,0x2
     b3c:	seto   dil
     b40:	test   dil,dil
     b43:	je     b57 <botlish_fn_6+0x1dc>
     b49:	mov    rdx,rax
     b4c:	mov    rdi,r13
     b4f:	call   b54 <botlish_fn_6+0x1d9>
			b50: R_X86_64_PLT32	rt_int_add-0x4
     b54:	mov    rdx,rax
     b57:	mov    QWORD PTR [rsp+0x10],rdx
     b5c:	mov    rcx,r14
     b5f:	mov    rsi,QWORD PTR [rsp+0x30]
     b64:	mov    rdi,r13
     b67:	call   b6c <botlish_fn_6+0x1f1>
			b68: R_X86_64_PLT32	botlish_fn_7-0x4 ; scan_record<str, int, List[str]>
     b6c:	test   rax,rax
     b6f:	jne    b9d <botlish_fn_6+0x222>
     b75:	xor    rdx,rdx
     b78:	mov    rax,rdx
     b7b:	mov    rbx,QWORD PTR [rsp+0x40]
     b80:	mov    r12,QWORD PTR [rsp+0x48]
     b85:	mov    r13,QWORD PTR [rsp+0x50]
     b8a:	mov    r14,QWORD PTR [rsp+0x58]
     b8f:	mov    r15,QWORD PTR [rsp+0x60]
     b94:	add    rsp,0x70
     b98:	mov    rsp,rbp
     b9b:	pop    rbp
     b9c:	ret
     b9d:	mov    rbx,QWORD PTR [rsp+0x40]
     ba2:	mov    r12,QWORD PTR [rsp+0x48]
     ba7:	mov    r13,QWORD PTR [rsp+0x50]
     bac:	mov    r14,QWORD PTR [rsp+0x58]
     bb1:	mov    r15,QWORD PTR [rsp+0x60]
     bb6:	add    rsp,0x70
     bba:	mov    rsp,rbp
     bbd:	pop    rbp
     bbe:	ret

0000000000000bbf <botlish_entry_6: scan_record<str, int, List[never]>>:
     bbf:	push   rbp
     bc0:	mov    rbp,rsp
     bc3:	ud2

0000000000000bc5 <botlish_fn_7: scan_record<str, int, List[str]>>:
     bc5:	push   rbp
     bc6:	mov    rbp,rsp
     bc9:	sub    rsp,0x80
     bd0:	mov    QWORD PTR [rsp+0x50],rbx
     bd5:	mov    QWORD PTR [rsp+0x58],r12
     bda:	mov    QWORD PTR [rsp+0x60],r13
     bdf:	mov    QWORD PTR [rsp+0x68],r14
     be4:	mov    QWORD PTR [rsp+0x70],r15
     be9:	mov    r15,rdi
     bec:	mov    QWORD PTR [rsp+0x18],0x0
     bf5:	mov    QWORD PTR [rsp],rsi
     bf9:	mov    QWORD PTR [rsp+0x8],rdx
     bfe:	mov    QWORD PTR [rsp+0x10],rcx
     c03:	lea    rbx,[rsp+0x20]
     c08:	mov    r12,rsi
     c0b:	mov    r13,rcx
     c0e:	mov    rsi,r12
     c11:	mov    rdi,r15
     c14:	call   c19 <botlish_fn_7+0x54>
			c15: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     c19:	test   rax,rax
     c1c:	je     c73 <botlish_fn_7+0xae>
     c22:	mov    QWORD PTR [rsp+0x8],rax
     c27:	mov    QWORD PTR [rsp+0x18],rdx
     c2c:	mov    QWORD PTR [rsp+0x40],rdx
     c31:	mov    rsi,r13
     c34:	mov    rdx,rax
     c37:	mov    rdi,r15
     c3a:	call   c3f <botlish_fn_7+0x7a>
			c3b: R_X86_64_PLT32	rt_list_append-0x4
     c3f:	test   rax,rax
     c42:	je     c73 <botlish_fn_7+0xae>
     c48:	mov    QWORD PTR [rsp+0x8],rax
     c4d:	mov    QWORD PTR [rsp+0x38],rax
     c52:	mov    rcx,rbx
     c55:	mov    rdx,QWORD PTR [rsp+0x40]
     c5a:	mov    rsi,r12
     c5d:	mov    rdi,r15
     c60:	call   c65 <botlish_fn_7+0xa0>
			c61: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     c65:	test   rax,rax
     c68:	mov    QWORD PTR [rsp+0x30],rax
     c6d:	jne    c9e <botlish_fn_7+0xd9>
     c73:	xor    rdx,rdx
     c76:	mov    rax,rdx
     c79:	mov    rbx,QWORD PTR [rsp+0x50]
     c7e:	mov    r12,QWORD PTR [rsp+0x58]
     c83:	mov    r13,QWORD PTR [rsp+0x60]
     c88:	mov    r14,QWORD PTR [rsp+0x68]
     c8d:	mov    r15,QWORD PTR [rsp+0x70]
     c92:	add    rsp,0x80
     c99:	mov    rsp,rbp
     c9c:	pop    rbp
     c9d:	ret
     c9e:	mov    r13,QWORD PTR [rsp+0x20]
     ca3:	mov    r14,QWORD PTR [rsp+0x28]
     ca8:	mov    rdi,r15
     cab:	mov    rcx,QWORD PTR [rdi+0x10]
     caf:	mov    r8,QWORD PTR [rcx+0x10]
     cb3:	mov    rcx,r14
     cb6:	mov    rdx,r13
     cb9:	mov    rsi,QWORD PTR [rsp+0x30]
     cbe:	call   cc3 <botlish_fn_7+0xfe>
			cbf: R_X86_64_PLT32	rt_str_region_eq-0x4
     cc3:	cmp    rax,0x6
     cc7:	je     d98 <botlish_fn_7+0x1d3>
     ccd:	mov    rdi,r15
     cd0:	mov    rax,QWORD PTR [rdi+0x10]
     cd4:	mov    r8,QWORD PTR [rax+0x18]
     cd8:	mov    rcx,r14
     cdb:	mov    rdx,r13
     cde:	mov    rsi,QWORD PTR [rsp+0x30]
     ce3:	call   ce8 <botlish_fn_7+0x123>
			ce4: R_X86_64_PLT32	rt_str_region_eq-0x4
     ce8:	cmp    rax,0x6
     cec:	je     d21 <botlish_fn_7+0x15c>
     cf2:	mov    rax,QWORD PTR [rsp+0x38]
     cf7:	mov    rdx,QWORD PTR [rsp+0x40]
     cfc:	mov    rbx,QWORD PTR [rsp+0x50]
     d01:	mov    r12,QWORD PTR [rsp+0x58]
     d06:	mov    r13,QWORD PTR [rsp+0x60]
     d0b:	mov    r14,QWORD PTR [rsp+0x68]
     d10:	mov    r15,QWORD PTR [rsp+0x70]
     d15:	add    rsp,0x80
     d1c:	mov    rsp,rbp
     d1f:	pop    rbp
     d20:	ret
     d21:	mov    QWORD PTR [rsp],0x3
     d29:	mov    rdx,QWORD PTR [rsp+0x40]
     d2e:	test   rdx,0x1
     d35:	je     d59 <botlish_fn_7+0x194>
     d3b:	mov    rdx,QWORD PTR [rsp+0x40]
     d40:	add    rdx,0x2
     d44:	seto   al
     d47:	test   al,al
     d49:	jne    d59 <botlish_fn_7+0x194>
     d4f:	mov    rax,QWORD PTR [rsp+0x38]
     d54:	jmp    d73 <botlish_fn_7+0x1ae>
     d59:	mov    edx,0x3
     d5e:	mov    rsi,QWORD PTR [rsp+0x40]
     d63:	mov    rdi,r15
     d66:	call   d6b <botlish_fn_7+0x1a6>
			d67: R_X86_64_PLT32	rt_int_add-0x4
     d6b:	mov    rdx,rax
     d6e:	mov    rax,QWORD PTR [rsp+0x38]
     d73:	mov    rbx,QWORD PTR [rsp+0x50]
     d78:	mov    r12,QWORD PTR [rsp+0x58]
     d7d:	mov    r13,QWORD PTR [rsp+0x60]
     d82:	mov    r14,QWORD PTR [rsp+0x68]
     d87:	mov    r15,QWORD PTR [rsp+0x70]
     d8c:	add    rsp,0x80
     d93:	mov    rsp,rbp
     d96:	pop    rbp
     d97:	ret
     d98:	mov    rsi,QWORD PTR [rsp+0x40]
     d9d:	mov    edx,0x3
     da2:	mov    rax,rdx
     da5:	mov    QWORD PTR [rsp+0x10],0x3
     dae:	test   rsi,0x1
     db5:	jne    dc3 <botlish_fn_7+0x1fe>
     dbb:	mov    rdx,rax
     dbe:	jmp    dda <botlish_fn_7+0x215>
     dc3:	mov    rdx,rsi
     dc6:	add    rdx,0x2
     dca:	seto   dil
     dce:	test   dil,dil
     dd1:	je     de5 <botlish_fn_7+0x220>
     dd7:	mov    rdx,rax
     dda:	mov    rdi,r15
     ddd:	call   de2 <botlish_fn_7+0x21d>
			dde: R_X86_64_PLT32	rt_int_add-0x4
     de2:	mov    rdx,rax
     de5:	mov    QWORD PTR [rsp],r12
     de9:	mov    QWORD PTR [rsp+0x8],rdx
     dee:	mov    rax,QWORD PTR [rsp+0x38]
     df3:	mov    QWORD PTR [rsp+0x10],rax
     df8:	mov    r13,QWORD PTR [rsp+0x38]
     dfd:	jmp    c0e <botlish_fn_7+0x49>

0000000000000e02 <botlish_entry_7: scan_record<str, int, List[str]>>:
     e02:	push   rbp
     e03:	mov    rbp,rsp
     e06:	ud2

0000000000000e08 <botlish_fn_8: scan_records<str, int, List[never]>>:
     e08:	push   rbp
     e09:	mov    rbp,rsp
     e0c:	sub    rsp,0x40
     e10:	mov    QWORD PTR [rsp+0x20],rbx
     e15:	mov    QWORD PTR [rsp+0x28],r12
     e1a:	mov    QWORD PTR [rsp+0x30],r13
     e1f:	mov    QWORD PTR [rsp+0x38],r14
     e24:	mov    r12,rdi
     e27:	mov    QWORD PTR [rsp+0x18],0x0
     e30:	mov    QWORD PTR [rsp],rsi
     e34:	mov    rbx,rsi
     e37:	mov    QWORD PTR [rsp+0x8],rdx
     e3c:	mov    r14,rdx
     e3f:	mov    QWORD PTR [rsp+0x10],rcx
     e44:	mov    r13,rcx
     e47:	mov    rsi,rbx
     e4a:	mov    rdi,r12
     e4d:	call   e52 <botlish_fn_8+0x4a>
			e4e: R_X86_64_PLT32	rt_str_len-0x4
     e52:	mov    rdx,r14
     e55:	mov    rcx,rdx
     e58:	sar    rcx,1
     e5b:	sar    rax,1
     e5e:	cmp    rcx,rax
     e61:	jge    f1d <botlish_fn_8+0x115>
     e67:	xor    rdx,rdx
     e6a:	mov    rdi,r12
     e6d:	mov    rsi,rdx
     e70:	call   e75 <botlish_fn_8+0x6d>
			e71: R_X86_64_PLT32	rt_list_new-0x4
     e75:	test   rax,rax
     e78:	je     ee0 <botlish_fn_8+0xd8>
     e7e:	mov    QWORD PTR [rsp+0x18],rax
     e83:	mov    rcx,rax
     e86:	mov    rdx,r14
     e89:	mov    rsi,rbx
     e8c:	mov    rdi,r12
     e8f:	call   e94 <botlish_fn_8+0x8c>
			e90: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
     e94:	test   rax,rax
     e97:	je     ee0 <botlish_fn_8+0xd8>
     e9d:	mov    QWORD PTR [rsp+0x8],rax
     ea2:	mov    QWORD PTR [rsp+0x18],rdx
     ea7:	mov    rsi,r13
     eaa:	mov    r13,rdx
     ead:	mov    rdx,rax
     eb0:	mov    rdi,r12
     eb3:	call   eb8 <botlish_fn_8+0xb0>
			eb4: R_X86_64_PLT32	rt_list_append-0x4
     eb8:	test   rax,rax
     ebb:	je     ee0 <botlish_fn_8+0xd8>
     ec1:	mov    QWORD PTR [rsp+0x8],rax
     ec6:	mov    rcx,rax
     ec9:	mov    rdx,r13
     ecc:	mov    rsi,rbx
     ecf:	mov    rdi,r12
     ed2:	call   ed7 <botlish_fn_8+0xcf>
			ed3: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
     ed7:	test   rax,rax
     eda:	jne    f00 <botlish_fn_8+0xf8>
     ee0:	xor    rax,rax
     ee3:	mov    rbx,QWORD PTR [rsp+0x20]
     ee8:	mov    r12,QWORD PTR [rsp+0x28]
     eed:	mov    r13,QWORD PTR [rsp+0x30]
     ef2:	mov    r14,QWORD PTR [rsp+0x38]
     ef7:	add    rsp,0x40
     efb:	mov    rsp,rbp
     efe:	pop    rbp
     eff:	ret
     f00:	mov    rbx,QWORD PTR [rsp+0x20]
     f05:	mov    r12,QWORD PTR [rsp+0x28]
     f0a:	mov    r13,QWORD PTR [rsp+0x30]
     f0f:	mov    r14,QWORD PTR [rsp+0x38]
     f14:	add    rsp,0x40
     f18:	mov    rsp,rbp
     f1b:	pop    rbp
     f1c:	ret
     f1d:	mov    rax,r13
     f20:	mov    rbx,QWORD PTR [rsp+0x20]
     f25:	mov    r12,QWORD PTR [rsp+0x28]
     f2a:	mov    r13,QWORD PTR [rsp+0x30]
     f2f:	mov    r14,QWORD PTR [rsp+0x38]
     f34:	add    rsp,0x40
     f38:	mov    rsp,rbp
     f3b:	pop    rbp
     f3c:	ret

0000000000000f3d <botlish_entry_8: scan_records<str, int, List[never]>>:
     f3d:	push   rbp
     f3e:	mov    rbp,rsp
     f41:	mov    rsi,QWORD PTR [rdx]
     f44:	mov    r8,QWORD PTR [rdx+0x8]
     f48:	mov    rcx,QWORD PTR [rdx+0x10]
     f4c:	mov    rdx,r8
     f4f:	call   f54 <botlish_entry_8+0x17>
			f50: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
     f54:	mov    rsp,rbp
     f57:	pop    rbp
     f58:	ret
     f59:	add    BYTE PTR [rax],al
     f5b:	add    BYTE PTR [rax],al
     f5d:	add    BYTE PTR [rax],al
	...

0000000000000f60 <botlish_fn_9: scan_records<str, int, List[List[str]]>>:
     f60:	push   rbp
     f61:	mov    rbp,rsp
     f64:	sub    rsp,0x40
     f68:	mov    QWORD PTR [rsp+0x20],rbx
     f6d:	mov    QWORD PTR [rsp+0x28],r12
     f72:	mov    QWORD PTR [rsp+0x30],r13
     f77:	mov    QWORD PTR [rsp+0x38],r14
     f7c:	mov    r13,rdi
     f7f:	mov    QWORD PTR [rsp+0x18],0x0
     f88:	mov    QWORD PTR [rsp],rsi
     f8c:	mov    QWORD PTR [rsp+0x8],rdx
     f91:	mov    r12,rdx
     f94:	mov    QWORD PTR [rsp+0x10],rcx
     f99:	mov    rbx,rsi
     f9c:	mov    r14,rcx
     f9f:	mov    rsi,rbx
     fa2:	mov    rdi,r13
     fa5:	call   faa <botlish_fn_9+0x4a>
			fa6: R_X86_64_PLT32	rt_str_len-0x4
     faa:	mov    rcx,r12
     fad:	and    rcx,rax
     fb0:	mov    rdx,rax
     fb3:	test   rcx,0x1
     fba:	jne    fe0 <botlish_fn_9+0x80>
     fc0:	mov    rsi,r12
     fc3:	mov    rdi,r13
     fc6:	call   fcb <botlish_fn_9+0x6b>
			fc7: R_X86_64_PLT32	rt_int_cmp-0x4
     fcb:	mov    ecx,0x2
     fd0:	test   rax,rax
     fd3:	cmovge rcx,QWORD PTR [rip+0xd5]        # 10b0 <botlish_fn_9+0x150>
     fdb:	jmp    ff3 <botlish_fn_9+0x93>
     fe0:	mov    ecx,0x2
     fe5:	mov    rax,r12
     fe8:	cmp    rax,rdx
     feb:	cmovge rcx,QWORD PTR [rip+0xbd]        # 10b0 <botlish_fn_9+0x150>
     ff3:	cmp    rcx,0x6
     ff7:	je     1090 <botlish_fn_9+0x130>
     ffd:	xor    rdx,rdx
    1000:	mov    rdi,r13
    1003:	mov    rsi,rdx
    1006:	call   100b <botlish_fn_9+0xab>
			1007: R_X86_64_PLT32	rt_list_new-0x4
    100b:	test   rax,rax
    100e:	je     1057 <botlish_fn_9+0xf7>
    1014:	mov    QWORD PTR [rsp+0x18],rax
    1019:	mov    rcx,rax
    101c:	mov    rdx,r12
    101f:	mov    rsi,rbx
    1022:	mov    rdi,r13
    1025:	call   102a <botlish_fn_9+0xca>
			1026: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    102a:	test   rax,rax
    102d:	je     1057 <botlish_fn_9+0xf7>
    1033:	mov    QWORD PTR [rsp+0x8],rax
    1038:	mov    QWORD PTR [rsp+0x18],rdx
    103d:	mov    r12,rdx
    1040:	mov    rsi,r14
    1043:	mov    rdx,rax
    1046:	mov    rdi,r13
    1049:	call   104e <botlish_fn_9+0xee>
			104a: R_X86_64_PLT32	rt_list_append-0x4
    104e:	test   rax,rax
    1051:	jne    1077 <botlish_fn_9+0x117>
    1057:	xor    rax,rax
    105a:	mov    rbx,QWORD PTR [rsp+0x20]
    105f:	mov    r12,QWORD PTR [rsp+0x28]
    1064:	mov    r13,QWORD PTR [rsp+0x30]
    1069:	mov    r14,QWORD PTR [rsp+0x38]
    106e:	add    rsp,0x40
    1072:	mov    rsp,rbp
    1075:	pop    rbp
    1076:	ret
    1077:	mov    QWORD PTR [rsp],rbx
    107b:	mov    rdx,r12
    107e:	mov    QWORD PTR [rsp+0x8],rdx
    1083:	mov    QWORD PTR [rsp+0x10],rax
    1088:	mov    r14,rax
    108b:	jmp    f9f <botlish_fn_9+0x3f>
    1090:	mov    rax,r14
    1093:	mov    rbx,QWORD PTR [rsp+0x20]
    1098:	mov    r12,QWORD PTR [rsp+0x28]
    109d:	mov    r13,QWORD PTR [rsp+0x30]
    10a2:	mov    r14,QWORD PTR [rsp+0x38]
    10a7:	add    rsp,0x40
    10ab:	mov    rsp,rbp
    10ae:	pop    rbp
    10af:	ret
    10b0:	(bad)
    10b1:	add    BYTE PTR [rax],al
    10b3:	add    BYTE PTR [rax],al
    10b5:	add    BYTE PTR [rax],al
	...

00000000000010b8 <botlish_entry_9: scan_records<str, int, List[List[str]]>>:
    10b8:	push   rbp
    10b9:	mov    rbp,rsp
    10bc:	mov    rsi,QWORD PTR [rdx]
    10bf:	mov    r8,QWORD PTR [rdx+0x8]
    10c3:	mov    rcx,QWORD PTR [rdx+0x10]
    10c7:	mov    rdx,r8
    10ca:	call   10cf <botlish_entry_9+0x17>
			10cb: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    10cf:	mov    rsp,rbp
    10d2:	pop    rbp
    10d3:	ret

00000000000010d4 <botlish_fn_10: csv_parse<str>>:
    10d4:	push   rbp
    10d5:	mov    rbp,rsp
    10d8:	sub    rsp,0x30
    10dc:	mov    QWORD PTR [rsp+0x20],r12
    10e1:	mov    QWORD PTR [rsp+0x28],r13
    10e6:	mov    r13,rdi
    10e9:	mov    QWORD PTR [rsp+0x10],0x0
    10f2:	mov    QWORD PTR [rsp],rsi
    10f6:	mov    r12,rsi
    10f9:	mov    QWORD PTR [rsp+0x8],0x1
    1102:	xor    rdx,rdx
    1105:	mov    rdi,r13
    1108:	mov    rsi,rdx
    110b:	call   1110 <botlish_fn_10+0x3c>
			110c: R_X86_64_PLT32	rt_list_new-0x4
    1110:	test   rax,rax
    1113:	je     113a <botlish_fn_10+0x66>
    1119:	mov    QWORD PTR [rsp+0x10],rax
    111e:	mov    rcx,rax
    1121:	mov    edx,0x1
    1126:	mov    rsi,r12
    1129:	mov    rdi,r13
    112c:	call   1131 <botlish_fn_10+0x5d>
			112d: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    1131:	test   rax,rax
    1134:	jne    1150 <botlish_fn_10+0x7c>
    113a:	xor    rax,rax
    113d:	mov    r12,QWORD PTR [rsp+0x20]
    1142:	mov    r13,QWORD PTR [rsp+0x28]
    1147:	add    rsp,0x30
    114b:	mov    rsp,rbp
    114e:	pop    rbp
    114f:	ret
    1150:	mov    r12,QWORD PTR [rsp+0x20]
    1155:	mov    r13,QWORD PTR [rsp+0x28]
    115a:	add    rsp,0x30
    115e:	mov    rsp,rbp
    1161:	pop    rbp
    1162:	ret

0000000000001163 <botlish_entry_10: csv_parse<str>>:
    1163:	push   rbp
    1164:	mov    rbp,rsp
    1167:	mov    rsi,QWORD PTR [rdx]
    116a:	call   116f <botlish_entry_10+0xc>
			116b: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
    116f:	mov    rsp,rbp
    1172:	pop    rbp
    1173:	ret

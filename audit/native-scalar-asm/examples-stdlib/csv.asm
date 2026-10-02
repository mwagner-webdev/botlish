; source:  examples/stdlib/csv.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5706  (per function: 68 365 430 585 1046 352 795 976 398 524 167)
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
     563:	add    BYTE PTR [rax],al
     565:	add    BYTE PTR [rax],al
	...

0000000000000568 <botlish_fn_4: scan_quoted<str, int, str>>:
     568:	push   rbp
     569:	mov    rbp,rsp
     56c:	sub    rsp,0xd0
     573:	mov    QWORD PTR [rsp+0xa0],rbx
     57b:	mov    QWORD PTR [rsp+0xa8],r12
     583:	mov    QWORD PTR [rsp+0xb0],r13
     58b:	mov    QWORD PTR [rsp+0xb8],r14
     593:	mov    QWORD PTR [rsp+0xc0],r15
     59b:	mov    r15,rdi
     59e:	mov    QWORD PTR [rsp+0x18],0x0
     5a7:	mov    QWORD PTR [rsp+0x20],0x0
     5b0:	mov    QWORD PTR [rsp],rsi
     5b4:	mov    QWORD PTR [rsp+0x8],rdx
     5b9:	mov    QWORD PTR [rsp+0x10],rcx
     5be:	mov    r13,rcx
     5c1:	lea    r14,[rsp+0x68]
     5c6:	lea    rbx,[rsp+0x28]
     5cb:	mov    r12,rsi
     5ce:	mov    QWORD PTR [rsp+0x88],rdx
     5d6:	mov    rdx,QWORD PTR [rsp+0x88]
     5de:	mov    rsi,r12
     5e1:	mov    rdi,r15
     5e4:	call   5e9 <botlish_fn_4+0x81>
			5e5: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     5e9:	test   rax,rax
     5ec:	je     8e0 <botlish_fn_4+0x378>
     5f2:	mov    QWORD PTR [rsp+0x18],rax
     5f7:	mov    rdx,QWORD PTR [rax+0x8]
     5fb:	mov    ecx,DWORD PTR [rax+0x14]
     5fe:	mov    QWORD PTR [rsp+0x90],rax
     606:	test   rdx,rdx
     609:	cmove  rcx,QWORD PTR [rip+0x327]        # 938 <botlish_fn_4+0x3d0>
     611:	cmp    rcx,0x22
     615:	je     6d5 <botlish_fn_4+0x16d>
     61b:	mov    QWORD PTR [rsp+0x20],0x3
     624:	mov    rsi,QWORD PTR [rsp+0x88]
     62c:	test   rsi,0x1
     633:	je     655 <botlish_fn_4+0xed>
     639:	mov    r8,rsi
     63c:	add    r8,0x2
     640:	seto   r10b
     644:	test   r10b,r10b
     647:	jne    655 <botlish_fn_4+0xed>
     64d:	mov    rsi,r8
     650:	jmp    665 <botlish_fn_4+0xfd>
     655:	mov    edx,0x3
     65a:	mov    rdi,r15
     65d:	call   662 <botlish_fn_4+0xfa>
			65e: R_X86_64_PLT32	rt_int_add-0x4
     662:	mov    rsi,rax
     665:	mov    QWORD PTR [rsp+0x8],rsi
     66a:	mov    QWORD PTR [rsp+0x88],rsi
     672:	mov    QWORD PTR [rsp+0x68],0x0
     67b:	mov    QWORD PTR [rsp+0x70],r13
     680:	mov    QWORD PTR [rsp+0x78],0x0
     689:	mov    rax,QWORD PTR [rsp+0x90]
     691:	mov    QWORD PTR [rsp+0x80],rax
     699:	mov    esi,0x2
     69e:	mov    edx,0x4
     6a3:	mov    rcx,r14
     6a6:	mov    rdi,r15
     6a9:	call   6ae <botlish_fn_4+0x146>
			6aa: R_X86_64_PLT32	rt_construct-0x4
     6ae:	test   rax,rax
     6b1:	je     8e0 <botlish_fn_4+0x378>
     6b7:	mov    QWORD PTR [rsp],r12
     6bb:	mov    rsi,QWORD PTR [rsp+0x88]
     6c3:	mov    QWORD PTR [rsp+0x8],rsi
     6c8:	mov    QWORD PTR [rsp+0x10],rax
     6cd:	mov    r13,rax
     6d0:	jmp    5d6 <botlish_fn_4+0x6e>
     6d5:	mov    QWORD PTR [rsp+0x18],0x3
     6de:	mov    rsi,QWORD PTR [rsp+0x88]
     6e6:	test   rsi,0x1
     6ed:	je     70d <botlish_fn_4+0x1a5>
     6f3:	mov    rsi,QWORD PTR [rsp+0x88]
     6fb:	mov    rdx,rsi
     6fe:	add    rdx,0x2
     702:	seto   al
     705:	test   al,al
     707:	je     725 <botlish_fn_4+0x1bd>
     70d:	mov    edx,0x3
     712:	mov    rsi,QWORD PTR [rsp+0x88]
     71a:	mov    rdi,r15
     71d:	call   722 <botlish_fn_4+0x1ba>
			71e: R_X86_64_PLT32	rt_int_add-0x4
     722:	mov    rdx,rax
     725:	mov    QWORD PTR [rsp+0x18],rdx
     72a:	mov    rcx,rbx
     72d:	mov    rsi,r12
     730:	mov    rdi,r15
     733:	call   738 <botlish_fn_4+0x1d0>
			734: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     738:	test   rax,rax
     73b:	mov    rsi,rax
     73e:	je     8e0 <botlish_fn_4+0x378>
     744:	mov    rdx,QWORD PTR [rsp+0x28]
     749:	mov    rcx,QWORD PTR [rsp+0x30]
     74e:	mov    rdi,r15
     751:	mov    rax,QWORD PTR [rdi+0x10]
     755:	mov    r8,QWORD PTR [rax+0x20]
     759:	call   75e <botlish_fn_4+0x1f6>
			75a: R_X86_64_PLT32	rt_str_region_eq-0x4
     75e:	cmp    rax,0x6
     762:	je     82a <botlish_fn_4+0x2c2>
     768:	xor    rsi,rsi
     76b:	lea    rcx,[rsp+0x58]
     770:	mov    QWORD PTR [rsp+0x58],0x0
     779:	mov    QWORD PTR [rsp+0x60],r13
     77e:	mov    edx,0x2
     783:	mov    rdi,r15
     786:	call   78b <botlish_fn_4+0x223>
			787: R_X86_64_PLT32	rt_construct-0x4
     78b:	test   rax,rax
     78e:	je     8e0 <botlish_fn_4+0x378>
     794:	mov    QWORD PTR [rsp],rax
     798:	mov    rbx,rax
     79b:	mov    QWORD PTR [rsp+0x10],0x3
     7a4:	mov    rsi,QWORD PTR [rsp+0x88]
     7ac:	test   rsi,0x1
     7b3:	je     7db <botlish_fn_4+0x273>
     7b9:	mov    rsi,QWORD PTR [rsp+0x88]
     7c1:	mov    rdx,rsi
     7c4:	add    rdx,0x2
     7c8:	seto   al
     7cb:	test   al,al
     7cd:	jne    7db <botlish_fn_4+0x273>
     7d3:	mov    rax,rbx
     7d6:	jmp    7f6 <botlish_fn_4+0x28e>
     7db:	mov    edx,0x3
     7e0:	mov    rsi,QWORD PTR [rsp+0x88]
     7e8:	mov    rdi,r15
     7eb:	call   7f0 <botlish_fn_4+0x288>
			7ec: R_X86_64_PLT32	rt_int_add-0x4
     7f0:	mov    rdx,rax
     7f3:	mov    rax,rbx
     7f6:	mov    rbx,QWORD PTR [rsp+0xa0]
     7fe:	mov    r12,QWORD PTR [rsp+0xa8]
     806:	mov    r13,QWORD PTR [rsp+0xb0]
     80e:	mov    r14,QWORD PTR [rsp+0xb8]
     816:	mov    r15,QWORD PTR [rsp+0xc0]
     81e:	add    rsp,0xd0
     825:	mov    rsp,rbp
     828:	pop    rbp
     829:	ret
     82a:	mov    QWORD PTR [rsp+0x18],0x5
     833:	mov    rsi,QWORD PTR [rsp+0x88]
     83b:	test   rsi,0x1
     842:	je     872 <botlish_fn_4+0x30a>
     848:	mov    rsi,QWORD PTR [rsp+0x88]
     850:	mov    rax,rsi
     853:	add    rax,0x4
     857:	seto   cl
     85a:	test   cl,cl
     85c:	jne    872 <botlish_fn_4+0x30a>
     862:	mov    rsi,rax
     865:	mov    QWORD PTR [rsp+0x88],rax
     86d:	jmp    892 <botlish_fn_4+0x32a>
     872:	mov    edx,0x5
     877:	mov    rsi,QWORD PTR [rsp+0x88]
     87f:	mov    rdi,r15
     882:	call   887 <botlish_fn_4+0x31f>
			883: R_X86_64_PLT32	rt_int_add-0x4
     887:	mov    rsi,rax
     88a:	mov    QWORD PTR [rsp+0x88],rax
     892:	mov    QWORD PTR [rsp+0x8],rsi
     897:	mov    rdi,r15
     89a:	mov    rsi,QWORD PTR [rdi+0x10]
     89e:	mov    rsi,QWORD PTR [rsi+0x20]
     8a2:	mov    QWORD PTR [rsp+0x18],rsi
     8a7:	lea    rcx,[rsp+0x38]
     8ac:	mov    QWORD PTR [rsp+0x38],0x0
     8b5:	mov    QWORD PTR [rsp+0x40],r13
     8ba:	mov    QWORD PTR [rsp+0x48],0x0
     8c3:	mov    QWORD PTR [rsp+0x50],rsi
     8c8:	mov    esi,0x2
     8cd:	mov    edx,0x4
     8d2:	call   8d7 <botlish_fn_4+0x36f>
			8d3: R_X86_64_PLT32	rt_construct-0x4
     8d7:	test   rax,rax
     8da:	jne    91a <botlish_fn_4+0x3b2>
     8e0:	xor    rdx,rdx
     8e3:	mov    rax,rdx
     8e6:	mov    rbx,QWORD PTR [rsp+0xa0]
     8ee:	mov    r12,QWORD PTR [rsp+0xa8]
     8f6:	mov    r13,QWORD PTR [rsp+0xb0]
     8fe:	mov    r14,QWORD PTR [rsp+0xb8]
     906:	mov    r15,QWORD PTR [rsp+0xc0]
     90e:	add    rsp,0xd0
     915:	mov    rsp,rbp
     918:	pop    rbp
     919:	ret
     91a:	mov    QWORD PTR [rsp],r12
     91e:	mov    rsi,QWORD PTR [rsp+0x88]
     926:	mov    QWORD PTR [rsp+0x8],rsi
     92b:	mov    QWORD PTR [rsp+0x10],rax
     930:	mov    r13,rax
     933:	jmp    5d6 <botlish_fn_4+0x6e>
     938:	(bad)
     939:	(bad)
     93a:	(bad)
     93b:	(bad)
     93c:	(bad)
     93d:	(bad)
     93e:	(bad)
     93f:	.byte 0xff

0000000000000940 <botlish_entry_4: scan_quoted<str, int, str>>:
     940:	push   rbp
     941:	mov    rbp,rsp
     944:	ud2

0000000000000946 <botlish_fn_5: scan_field<str, int>>:
     946:	push   rbp
     947:	mov    rbp,rsp
     94a:	sub    rsp,0x50
     94e:	mov    QWORD PTR [rsp+0x30],rbx
     953:	mov    QWORD PTR [rsp+0x38],r12
     958:	mov    QWORD PTR [rsp+0x40],r13
     95d:	mov    r12,rdi
     960:	mov    r13,rdx
     963:	mov    QWORD PTR [rsp+0x10],0x0
     96c:	mov    QWORD PTR [rsp],rsi
     970:	mov    rbx,rsi
     973:	mov    QWORD PTR [rsp+0x8],rdx
     978:	lea    rcx,[rsp+0x18]
     97d:	mov    rdx,r13
     980:	mov    rsi,rbx
     983:	mov    rdi,r12
     986:	call   98b <botlish_fn_5+0x45>
			987: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     98b:	test   rax,rax
     98e:	mov    rsi,rax
     991:	je     a5c <botlish_fn_5+0x116>
     997:	mov    rdx,QWORD PTR [rsp+0x18]
     99c:	mov    rcx,QWORD PTR [rsp+0x20]
     9a1:	mov    rdi,r12
     9a4:	mov    rax,QWORD PTR [rdi+0x10]
     9a8:	mov    r8,QWORD PTR [rax+0x20]
     9ac:	call   9b1 <botlish_fn_5+0x6b>
			9ad: R_X86_64_PLT32	rt_str_region_eq-0x4
     9b1:	cmp    rax,0x6
     9b5:	je     9ed <botlish_fn_5+0xa7>
     9bb:	mov    rcx,r13
     9be:	mov    rsi,rbx
     9c1:	mov    rdi,r12
     9c4:	mov    rdx,rcx
     9c7:	call   9cc <botlish_fn_5+0x86>
			9c8: R_X86_64_PLT32	botlish_fn_3-0x4 ; scan_unquoted<str, int, int>
     9cc:	test   rax,rax
     9cf:	je     a5c <botlish_fn_5+0x116>
     9d5:	mov    rbx,QWORD PTR [rsp+0x30]
     9da:	mov    r12,QWORD PTR [rsp+0x38]
     9df:	mov    r13,QWORD PTR [rsp+0x40]
     9e4:	add    rsp,0x50
     9e8:	mov    rsp,rbp
     9eb:	pop    rbp
     9ec:	ret
     9ed:	mov    rcx,r13
     9f0:	mov    QWORD PTR [rsp+0x10],0x3
     9f9:	test   rcx,0x1
     a00:	jne    a0e <botlish_fn_5+0xc8>
     a06:	mov    r13,rcx
     a09:	jmp    a23 <botlish_fn_5+0xdd>
     a0e:	mov    rdx,rcx
     a11:	add    rdx,0x2
     a15:	mov    r13,rcx
     a18:	seto   al
     a1b:	test   al,al
     a1d:	je     a36 <botlish_fn_5+0xf0>
     a23:	mov    edx,0x3
     a28:	mov    rsi,r13
     a2b:	mov    rdi,r12
     a2e:	call   a33 <botlish_fn_5+0xed>
			a2f: R_X86_64_PLT32	rt_int_add-0x4
     a33:	mov    rdx,rax
     a36:	mov    QWORD PTR [rsp+0x8],rdx
     a3b:	mov    rdi,r12
     a3e:	mov    rax,QWORD PTR [rdi+0x10]
     a42:	mov    rcx,QWORD PTR [rax+0x8]
     a46:	mov    QWORD PTR [rsp+0x10],rcx
     a4b:	mov    rsi,rbx
     a4e:	call   a53 <botlish_fn_5+0x10d>
			a4f: R_X86_64_PLT32	botlish_fn_4-0x4 ; scan_quoted<str, int, str>
     a53:	test   rax,rax
     a56:	jne    a7a <botlish_fn_5+0x134>
     a5c:	xor    rdx,rdx
     a5f:	mov    rax,rdx
     a62:	mov    rbx,QWORD PTR [rsp+0x30]
     a67:	mov    r12,QWORD PTR [rsp+0x38]
     a6c:	mov    r13,QWORD PTR [rsp+0x40]
     a71:	add    rsp,0x50
     a75:	mov    rsp,rbp
     a78:	pop    rbp
     a79:	ret
     a7a:	mov    rbx,QWORD PTR [rsp+0x30]
     a7f:	mov    r12,QWORD PTR [rsp+0x38]
     a84:	mov    r13,QWORD PTR [rsp+0x40]
     a89:	add    rsp,0x50
     a8d:	mov    rsp,rbp
     a90:	pop    rbp
     a91:	ret

0000000000000a92 <botlish_entry_5: scan_field<str, int>>:
     a92:	push   rbp
     a93:	mov    rbp,rsp
     a96:	ud2

0000000000000a98 <botlish_fn_6: scan_record<str, int, List[never]>>:
     a98:	push   rbp
     a99:	mov    rbp,rsp
     a9c:	sub    rsp,0xa0
     aa3:	mov    QWORD PTR [rsp+0x70],rbx
     aa8:	mov    QWORD PTR [rsp+0x78],r12
     aad:	mov    QWORD PTR [rsp+0x80],r13
     ab5:	mov    QWORD PTR [rsp+0x88],r14
     abd:	mov    QWORD PTR [rsp+0x90],r15
     ac5:	mov    r13,rdi
     ac8:	mov    QWORD PTR [rsp+0x18],0x0
     ad1:	mov    QWORD PTR [rsp+0x20],0x0
     ada:	mov    QWORD PTR [rsp],rsi
     ade:	mov    r15,rsi
     ae1:	mov    QWORD PTR [rsp+0x8],rdx
     ae6:	mov    QWORD PTR [rsp+0x10],rcx
     aeb:	mov    QWORD PTR [rsp+0x58],rcx
     af0:	mov    rsi,r15
     af3:	mov    rdi,r13
     af6:	call   afb <botlish_fn_6+0x63>
			af7: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     afb:	test   rax,rax
     afe:	je     d19 <botlish_fn_6+0x281>
     b04:	mov    QWORD PTR [rsp+0x8],rax
     b09:	mov    QWORD PTR [rsp+0x68],rax
     b0e:	mov    QWORD PTR [rsp+0x18],rdx
     b13:	mov    r14,rdx
     b16:	lea    rcx,[rsp+0x28]
     b1b:	mov    rsi,r15
     b1e:	mov    rdi,r13
     b21:	call   b26 <botlish_fn_6+0x8e>
			b22: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     b26:	test   rax,rax
     b29:	mov    QWORD PTR [rsp+0x60],rax
     b2e:	je     d19 <botlish_fn_6+0x281>
     b34:	mov    r12,QWORD PTR [rsp+0x28]
     b39:	mov    rbx,QWORD PTR [rsp+0x30]
     b3e:	mov    rdi,r13
     b41:	mov    rcx,QWORD PTR [rdi+0x10]
     b45:	mov    r8,QWORD PTR [rcx+0x10]
     b49:	mov    rcx,rbx
     b4c:	mov    rdx,r12
     b4f:	mov    rsi,QWORD PTR [rsp+0x60]
     b54:	call   b59 <botlish_fn_6+0xc1>
			b55: R_X86_64_PLT32	rt_str_region_eq-0x4
     b59:	cmp    rax,0x6
     b5d:	je     c6f <botlish_fn_6+0x1d7>
     b63:	mov    rdi,r13
     b66:	mov    rax,QWORD PTR [rdi+0x10]
     b6a:	mov    r8,QWORD PTR [rax+0x18]
     b6e:	mov    rcx,rbx
     b71:	mov    rdx,r12
     b74:	mov    rsi,QWORD PTR [rsp+0x60]
     b79:	call   b7e <botlish_fn_6+0xe6>
			b7a: R_X86_64_PLT32	rt_str_region_eq-0x4
     b7e:	cmp    rax,0x6
     b82:	je     bd4 <botlish_fn_6+0x13c>
     b88:	mov    rdx,QWORD PTR [rsp+0x68]
     b8d:	mov    rsi,QWORD PTR [rsp+0x58]
     b92:	mov    rdi,r13
     b95:	call   b9a <botlish_fn_6+0x102>
			b96: R_X86_64_PLT32	rt_list_append-0x4
     b9a:	test   rax,rax
     b9d:	je     d19 <botlish_fn_6+0x281>
     ba3:	mov    rdx,r14
     ba6:	mov    rbx,QWORD PTR [rsp+0x70]
     bab:	mov    r12,QWORD PTR [rsp+0x78]
     bb0:	mov    r13,QWORD PTR [rsp+0x80]
     bb8:	mov    r14,QWORD PTR [rsp+0x88]
     bc0:	mov    r15,QWORD PTR [rsp+0x90]
     bc8:	add    rsp,0xa0
     bcf:	mov    rsp,rbp
     bd2:	pop    rbp
     bd3:	ret
     bd4:	mov    rdx,QWORD PTR [rsp+0x68]
     bd9:	mov    rsi,QWORD PTR [rsp+0x58]
     bde:	mov    rdi,r13
     be1:	call   be6 <botlish_fn_6+0x14e>
			be2: R_X86_64_PLT32	rt_list_append-0x4
     be6:	test   rax,rax
     be9:	je     d19 <botlish_fn_6+0x281>
     bef:	mov    QWORD PTR [rsp],rax
     bf3:	mov    r12,rax
     bf6:	mov    QWORD PTR [rsp+0x8],0x3
     bff:	mov    rdx,r14
     c02:	test   rdx,0x1
     c09:	je     c2b <botlish_fn_6+0x193>
     c0f:	mov    rdx,r14
     c12:	add    rdx,0x2
     c16:	seto   sil
     c1a:	test   sil,sil
     c1d:	jne    c2b <botlish_fn_6+0x193>
     c23:	mov    rax,r12
     c26:	jmp    c41 <botlish_fn_6+0x1a9>
     c2b:	mov    edx,0x3
     c30:	mov    rsi,r14
     c33:	mov    rdi,r13
     c36:	call   c3b <botlish_fn_6+0x1a3>
			c37: R_X86_64_PLT32	rt_int_add-0x4
     c3b:	mov    rdx,rax
     c3e:	mov    rax,r12
     c41:	mov    rbx,QWORD PTR [rsp+0x70]
     c46:	mov    r12,QWORD PTR [rsp+0x78]
     c4b:	mov    r13,QWORD PTR [rsp+0x80]
     c53:	mov    r14,QWORD PTR [rsp+0x88]
     c5b:	mov    r15,QWORD PTR [rsp+0x90]
     c63:	add    rsp,0xa0
     c6a:	mov    rsp,rbp
     c6d:	pop    rbp
     c6e:	ret
     c6f:	mov    rsi,r14
     c72:	mov    r12d,0x3
     c78:	mov    QWORD PTR [rsp+0x20],0x3
     c81:	test   rsi,0x1
     c88:	je     ca0 <botlish_fn_6+0x208>
     c8e:	mov    rdx,rsi
     c91:	add    rdx,0x2
     c95:	seto   al
     c98:	test   al,al
     c9a:	je     cae <botlish_fn_6+0x216>
     ca0:	mov    rdx,r12
     ca3:	mov    rdi,r13
     ca6:	call   cab <botlish_fn_6+0x213>
			ca7: R_X86_64_PLT32	rt_int_add-0x4
     cab:	mov    rdx,rax
     cae:	mov    QWORD PTR [rsp+0x18],rdx
     cb3:	mov    rbx,rdx
     cb6:	lea    rcx,[rsp+0x38]
     cbb:	mov    QWORD PTR [rsp+0x38],0x0
     cc4:	mov    rsi,QWORD PTR [rsp+0x58]
     cc9:	mov    QWORD PTR [rsp+0x40],rsi
     cce:	mov    QWORD PTR [rsp+0x48],0x2
     cd7:	mov    rdx,QWORD PTR [rsp+0x68]
     cdc:	mov    QWORD PTR [rsp+0x50],rdx
     ce1:	mov    edx,0x4
     ce6:	mov    rsi,r12
     ce9:	mov    rdi,r13
     cec:	call   cf1 <botlish_fn_6+0x259>
			ced: R_X86_64_PLT32	rt_construct-0x4
     cf1:	test   rax,rax
     cf4:	je     d19 <botlish_fn_6+0x281>
     cfa:	mov    QWORD PTR [rsp+0x8],rax
     cff:	mov    rcx,rax
     d02:	mov    rdx,rbx
     d05:	mov    rsi,r15
     d08:	mov    rdi,r13
     d0b:	call   d10 <botlish_fn_6+0x278>
			d0c: R_X86_64_PLT32	botlish_fn_7-0x4 ; scan_record<str, int, List[str]>
     d10:	test   rax,rax
     d13:	jne    d4d <botlish_fn_6+0x2b5>
     d19:	xor    rdx,rdx
     d1c:	mov    rax,rdx
     d1f:	mov    rbx,QWORD PTR [rsp+0x70]
     d24:	mov    r12,QWORD PTR [rsp+0x78]
     d29:	mov    r13,QWORD PTR [rsp+0x80]
     d31:	mov    r14,QWORD PTR [rsp+0x88]
     d39:	mov    r15,QWORD PTR [rsp+0x90]
     d41:	add    rsp,0xa0
     d48:	mov    rsp,rbp
     d4b:	pop    rbp
     d4c:	ret
     d4d:	mov    rbx,QWORD PTR [rsp+0x70]
     d52:	mov    r12,QWORD PTR [rsp+0x78]
     d57:	mov    r13,QWORD PTR [rsp+0x80]
     d5f:	mov    r14,QWORD PTR [rsp+0x88]
     d67:	mov    r15,QWORD PTR [rsp+0x90]
     d6f:	add    rsp,0xa0
     d76:	mov    rsp,rbp
     d79:	pop    rbp
     d7a:	ret

0000000000000d7b <botlish_entry_6: scan_record<str, int, List[never]>>:
     d7b:	push   rbp
     d7c:	mov    rbp,rsp
     d7f:	ud2

0000000000000d81 <botlish_fn_7: scan_record<str, int, List[str]>>:
     d81:	push   rbp
     d82:	mov    rbp,rsp
     d85:	sub    rsp,0xf0
     d8c:	mov    QWORD PTR [rsp+0xc0],rbx
     d94:	mov    QWORD PTR [rsp+0xc8],r12
     d9c:	mov    QWORD PTR [rsp+0xd0],r13
     da4:	mov    QWORD PTR [rsp+0xd8],r14
     dac:	mov    QWORD PTR [rsp+0xe0],r15
     db4:	mov    QWORD PTR [rsp+0x98],rdi
     dbc:	mov    QWORD PTR [rsp+0x18],0x0
     dc5:	mov    QWORD PTR [rsp+0x20],0x0
     dce:	mov    QWORD PTR [rsp],rsi
     dd2:	mov    QWORD PTR [rsp+0x8],rdx
     dd7:	mov    QWORD PTR [rsp+0xa0],rdx
     ddf:	mov    QWORD PTR [rsp+0x10],rcx
     de4:	mov    r15,rcx
     de7:	lea    rbx,[rsp+0x28]
     dec:	mov    r12,rsi
     def:	mov    rsi,r12
     df2:	mov    rdi,QWORD PTR [rsp+0x98]
     dfa:	call   dff <botlish_fn_7+0x7e>
			dfb: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     dff:	test   rax,rax
     e02:	je     10bf <botlish_fn_7+0x33e>
     e08:	mov    QWORD PTR [rsp+0x8],rax
     e0d:	mov    QWORD PTR [rsp+0xb0],rax
     e15:	mov    QWORD PTR [rsp+0x18],rdx
     e1a:	mov    QWORD PTR [rsp+0xb8],rdx
     e22:	mov    rcx,rbx
     e25:	mov    rsi,r12
     e28:	mov    rdi,QWORD PTR [rsp+0x98]
     e30:	call   e35 <botlish_fn_7+0xb4>
			e31: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     e35:	test   rax,rax
     e38:	mov    QWORD PTR [rsp+0xa8],rax
     e40:	je     10bf <botlish_fn_7+0x33e>
     e46:	mov    r13,QWORD PTR [rsp+0x28]
     e4b:	mov    r14,QWORD PTR [rsp+0x30]
     e50:	mov    rdi,QWORD PTR [rsp+0x98]
     e58:	mov    rcx,QWORD PTR [rdi+0x10]
     e5c:	mov    r8,QWORD PTR [rcx+0x10]
     e60:	mov    rcx,r14
     e63:	mov    rdx,r13
     e66:	mov    rsi,QWORD PTR [rsp+0xa8]
     e6e:	call   e73 <botlish_fn_7+0xf2>
			e6f: R_X86_64_PLT32	rt_str_region_eq-0x4
     e73:	cmp    rax,0x6
     e77:	je     101f <botlish_fn_7+0x29e>
     e7d:	mov    rdi,QWORD PTR [rsp+0x98]
     e85:	mov    rax,QWORD PTR [rdi+0x10]
     e89:	mov    r8,QWORD PTR [rax+0x18]
     e8d:	mov    rcx,r14
     e90:	mov    rdx,r13
     e93:	mov    rsi,QWORD PTR [rsp+0xa8]
     e9b:	call   ea0 <botlish_fn_7+0x11f>
			e9c: R_X86_64_PLT32	rt_str_region_eq-0x4
     ea0:	cmp    rax,0x6
     ea4:	je     f3b <botlish_fn_7+0x1ba>
     eaa:	lea    rcx,[rsp+0x78]
     eaf:	mov    QWORD PTR [rsp+0x78],0x0
     eb8:	mov    r14,r15
     ebb:	mov    QWORD PTR [rsp+0x80],r14
     ec3:	mov    QWORD PTR [rsp+0x88],0x2
     ecf:	mov    r15,QWORD PTR [rsp+0xb0]
     ed7:	mov    QWORD PTR [rsp+0x90],r15
     edf:	mov    esi,0x1
     ee4:	mov    edx,0x4
     ee9:	mov    rdi,QWORD PTR [rsp+0x98]
     ef1:	call   ef6 <botlish_fn_7+0x175>
			ef2: R_X86_64_PLT32	rt_construct-0x4
     ef6:	test   rax,rax
     ef9:	je     10bf <botlish_fn_7+0x33e>
     eff:	mov    rdx,QWORD PTR [rsp+0xb8]
     f07:	mov    rbx,QWORD PTR [rsp+0xc0]
     f0f:	mov    r12,QWORD PTR [rsp+0xc8]
     f17:	mov    r13,QWORD PTR [rsp+0xd0]
     f1f:	mov    r14,QWORD PTR [rsp+0xd8]
     f27:	mov    r15,QWORD PTR [rsp+0xe0]
     f2f:	add    rsp,0xf0
     f36:	mov    rsp,rbp
     f39:	pop    rbp
     f3a:	ret
     f3b:	mov    r14,r15
     f3e:	mov    r15,QWORD PTR [rsp+0xb0]
     f46:	lea    rcx,[rsp+0x58]
     f4b:	mov    QWORD PTR [rsp+0x58],0x0
     f54:	mov    QWORD PTR [rsp+0x60],r14
     f59:	mov    QWORD PTR [rsp+0x68],0x2
     f62:	mov    QWORD PTR [rsp+0x70],r15
     f67:	mov    esi,0x1
     f6c:	mov    edx,0x4
     f71:	mov    rdi,QWORD PTR [rsp+0x98]
     f79:	call   f7e <botlish_fn_7+0x1fd>
			f7a: R_X86_64_PLT32	rt_construct-0x4
     f7e:	test   rax,rax
     f81:	je     10bf <botlish_fn_7+0x33e>
     f87:	mov    QWORD PTR [rsp],rax
     f8b:	mov    r12,rax
     f8e:	mov    QWORD PTR [rsp+0x8],0x3
     f97:	mov    rdx,QWORD PTR [rsp+0xb8]
     f9f:	test   rdx,0x1
     fa6:	je     fcb <botlish_fn_7+0x24a>
     fac:	mov    rdx,QWORD PTR [rsp+0xb8]
     fb4:	add    rdx,0x2
     fb8:	seto   al
     fbb:	test   al,al
     fbd:	jne    fcb <botlish_fn_7+0x24a>
     fc3:	mov    rax,r12
     fc6:	jmp    feb <botlish_fn_7+0x26a>
     fcb:	mov    edx,0x3
     fd0:	mov    rsi,QWORD PTR [rsp+0xb8]
     fd8:	mov    rdi,QWORD PTR [rsp+0x98]
     fe0:	call   fe5 <botlish_fn_7+0x264>
			fe1: R_X86_64_PLT32	rt_int_add-0x4
     fe5:	mov    rdx,rax
     fe8:	mov    rax,r12
     feb:	mov    rbx,QWORD PTR [rsp+0xc0]
     ff3:	mov    r12,QWORD PTR [rsp+0xc8]
     ffb:	mov    r13,QWORD PTR [rsp+0xd0]
    1003:	mov    r14,QWORD PTR [rsp+0xd8]
    100b:	mov    r15,QWORD PTR [rsp+0xe0]
    1013:	add    rsp,0xf0
    101a:	mov    rsp,rbp
    101d:	pop    rbp
    101e:	ret
    101f:	mov    r14,r15
    1022:	mov    r15,QWORD PTR [rsp+0xb0]
    102a:	mov    rsi,QWORD PTR [rsp+0xb8]
    1032:	mov    r13d,0x3
    1038:	mov    QWORD PTR [rsp+0x20],0x3
    1041:	test   rsi,0x1
    1048:	je     1060 <botlish_fn_7+0x2df>
    104e:	mov    rdx,rsi
    1051:	add    rdx,0x2
    1055:	seto   al
    1058:	test   al,al
    105a:	je     1073 <botlish_fn_7+0x2f2>
    1060:	mov    rdx,r13
    1063:	mov    rdi,QWORD PTR [rsp+0x98]
    106b:	call   1070 <botlish_fn_7+0x2ef>
			106c: R_X86_64_PLT32	rt_int_add-0x4
    1070:	mov    rdx,rax
    1073:	mov    QWORD PTR [rsp+0x18],rdx
    1078:	mov    QWORD PTR [rsp+0xa0],rdx
    1080:	lea    rcx,[rsp+0x38]
    1085:	mov    QWORD PTR [rsp+0x38],0x0
    108e:	mov    QWORD PTR [rsp+0x40],r14
    1093:	mov    QWORD PTR [rsp+0x48],0x2
    109c:	mov    QWORD PTR [rsp+0x50],r15
    10a1:	mov    edx,0x4
    10a6:	mov    rsi,r13
    10a9:	mov    rdi,QWORD PTR [rsp+0x98]
    10b1:	call   10b6 <botlish_fn_7+0x335>
			10b2: R_X86_64_PLT32	rt_construct-0x4
    10b6:	test   rax,rax
    10b9:	jne    10f9 <botlish_fn_7+0x378>
    10bf:	xor    rdx,rdx
    10c2:	mov    rax,rdx
    10c5:	mov    rbx,QWORD PTR [rsp+0xc0]
    10cd:	mov    r12,QWORD PTR [rsp+0xc8]
    10d5:	mov    r13,QWORD PTR [rsp+0xd0]
    10dd:	mov    r14,QWORD PTR [rsp+0xd8]
    10e5:	mov    r15,QWORD PTR [rsp+0xe0]
    10ed:	add    rsp,0xf0
    10f4:	mov    rsp,rbp
    10f7:	pop    rbp
    10f8:	ret
    10f9:	mov    QWORD PTR [rsp],r12
    10fd:	mov    rdx,QWORD PTR [rsp+0xa0]
    1105:	mov    QWORD PTR [rsp+0x8],rdx
    110a:	mov    QWORD PTR [rsp+0x10],rax
    110f:	mov    r15,rax
    1112:	jmp    def <botlish_fn_7+0x6e>

0000000000001117 <botlish_entry_7: scan_record<str, int, List[str]>>:
    1117:	push   rbp
    1118:	mov    rbp,rsp
    111b:	ud2

000000000000111d <botlish_fn_8: scan_records<str, int, List[never]>>:
    111d:	push   rbp
    111e:	mov    rbp,rsp
    1121:	sub    rsp,0x60
    1125:	mov    QWORD PTR [rsp+0x40],rbx
    112a:	mov    QWORD PTR [rsp+0x48],r12
    112f:	mov    QWORD PTR [rsp+0x50],r13
    1134:	mov    QWORD PTR [rsp+0x58],r14
    1139:	mov    r12,rdi
    113c:	mov    QWORD PTR [rsp+0x18],0x0
    1145:	mov    QWORD PTR [rsp],rsi
    1149:	mov    rbx,rsi
    114c:	mov    QWORD PTR [rsp+0x8],rdx
    1151:	mov    r14,rdx
    1154:	mov    QWORD PTR [rsp+0x10],rcx
    1159:	mov    r13,rcx
    115c:	mov    rsi,rbx
    115f:	mov    rdi,r12
    1162:	call   1167 <botlish_fn_8+0x4a>
			1163: R_X86_64_PLT32	rt_str_len-0x4
    1167:	mov    rdx,r14
    116a:	mov    rcx,rdx
    116d:	sar    rcx,1
    1170:	sar    rax,1
    1173:	cmp    rcx,rax
    1176:	jge    125a <botlish_fn_8+0x13d>
    117c:	xor    rdx,rdx
    117f:	mov    rdi,r12
    1182:	mov    rsi,rdx
    1185:	call   118a <botlish_fn_8+0x6d>
			1186: R_X86_64_PLT32	rt_list_new-0x4
    118a:	test   rax,rax
    118d:	je     121d <botlish_fn_8+0x100>
    1193:	mov    QWORD PTR [rsp+0x18],rax
    1198:	mov    rcx,rax
    119b:	mov    rdx,r14
    119e:	mov    rsi,rbx
    11a1:	mov    rdi,r12
    11a4:	call   11a9 <botlish_fn_8+0x8c>
			11a5: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    11a9:	test   rax,rax
    11ac:	je     121d <botlish_fn_8+0x100>
    11b2:	mov    QWORD PTR [rsp+0x8],rax
    11b7:	mov    QWORD PTR [rsp+0x18],rdx
    11bc:	mov    r14,rdx
    11bf:	lea    rcx,[rsp+0x20]
    11c4:	mov    QWORD PTR [rsp+0x20],0x0
    11cd:	mov    rdx,r13
    11d0:	mov    QWORD PTR [rsp+0x28],rdx
    11d5:	mov    QWORD PTR [rsp+0x30],0x2
    11de:	mov    QWORD PTR [rsp+0x38],rax
    11e3:	mov    esi,0x3
    11e8:	mov    edx,0x4
    11ed:	mov    rdi,r12
    11f0:	call   11f5 <botlish_fn_8+0xd8>
			11f1: R_X86_64_PLT32	rt_construct-0x4
    11f5:	test   rax,rax
    11f8:	je     121d <botlish_fn_8+0x100>
    11fe:	mov    QWORD PTR [rsp+0x8],rax
    1203:	mov    rcx,rax
    1206:	mov    rdx,r14
    1209:	mov    rsi,rbx
    120c:	mov    rdi,r12
    120f:	call   1214 <botlish_fn_8+0xf7>
			1210: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    1214:	test   rax,rax
    1217:	jne    123d <botlish_fn_8+0x120>
    121d:	xor    rax,rax
    1220:	mov    rbx,QWORD PTR [rsp+0x40]
    1225:	mov    r12,QWORD PTR [rsp+0x48]
    122a:	mov    r13,QWORD PTR [rsp+0x50]
    122f:	mov    r14,QWORD PTR [rsp+0x58]
    1234:	add    rsp,0x60
    1238:	mov    rsp,rbp
    123b:	pop    rbp
    123c:	ret
    123d:	mov    rbx,QWORD PTR [rsp+0x40]
    1242:	mov    r12,QWORD PTR [rsp+0x48]
    1247:	mov    r13,QWORD PTR [rsp+0x50]
    124c:	mov    r14,QWORD PTR [rsp+0x58]
    1251:	add    rsp,0x60
    1255:	mov    rsp,rbp
    1258:	pop    rbp
    1259:	ret
    125a:	mov    rax,r13
    125d:	mov    rbx,QWORD PTR [rsp+0x40]
    1262:	mov    r12,QWORD PTR [rsp+0x48]
    1267:	mov    r13,QWORD PTR [rsp+0x50]
    126c:	mov    r14,QWORD PTR [rsp+0x58]
    1271:	add    rsp,0x60
    1275:	mov    rsp,rbp
    1278:	pop    rbp
    1279:	ret

000000000000127a <botlish_entry_8: scan_records<str, int, List[never]>>:
    127a:	push   rbp
    127b:	mov    rbp,rsp
    127e:	mov    rsi,QWORD PTR [rdx]
    1281:	mov    r8,QWORD PTR [rdx+0x8]
    1285:	mov    rcx,QWORD PTR [rdx+0x10]
    1289:	mov    rdx,r8
    128c:	call   1291 <botlish_entry_8+0x17>
			128d: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    1291:	mov    rsp,rbp
    1294:	pop    rbp
    1295:	ret
	...

0000000000001298 <botlish_fn_9: scan_records<str, int, List[List[str]]>>:
    1298:	push   rbp
    1299:	mov    rbp,rsp
    129c:	sub    rsp,0x80
    12a3:	mov    QWORD PTR [rsp+0x50],rbx
    12a8:	mov    QWORD PTR [rsp+0x58],r12
    12ad:	mov    QWORD PTR [rsp+0x60],r13
    12b2:	mov    QWORD PTR [rsp+0x68],r14
    12b7:	mov    QWORD PTR [rsp+0x70],r15
    12bc:	mov    r14,rdi
    12bf:	mov    QWORD PTR [rsp+0x18],0x0
    12c8:	mov    QWORD PTR [rsp],rsi
    12cc:	mov    QWORD PTR [rsp+0x8],rdx
    12d1:	mov    r13,rdx
    12d4:	mov    QWORD PTR [rsp+0x10],rcx
    12d9:	mov    r15,rcx
    12dc:	lea    r12,[rsp+0x30]
    12e1:	mov    rbx,rsi
    12e4:	mov    rsi,rbx
    12e7:	mov    rdi,r14
    12ea:	call   12ef <botlish_fn_9+0x57>
			12eb: R_X86_64_PLT32	rt_str_len-0x4
    12ef:	mov    rcx,r13
    12f2:	and    rcx,rax
    12f5:	mov    rdx,rax
    12f8:	test   rcx,0x1
    12ff:	jne    1325 <botlish_fn_9+0x8d>
    1305:	mov    rsi,r13
    1308:	mov    rdi,r14
    130b:	call   1310 <botlish_fn_9+0x78>
			130c: R_X86_64_PLT32	rt_int_cmp-0x4
    1310:	mov    ecx,0x2
    1315:	test   rax,rax
    1318:	cmovge rcx,QWORD PTR [rip+0x140]        # 1460 <botlish_fn_9+0x1c8>
    1320:	jmp    1338 <botlish_fn_9+0xa0>
    1325:	mov    ecx,0x2
    132a:	mov    rax,r13
    132d:	cmp    rax,rdx
    1330:	cmovge rcx,QWORD PTR [rip+0x128]        # 1460 <botlish_fn_9+0x1c8>
    1338:	cmp    rcx,0x6
    133c:	je     13db <botlish_fn_9+0x143>
    1342:	xor    rdx,rdx
    1345:	mov    rdi,r14
    1348:	mov    rsi,rdx
    134b:	call   1350 <botlish_fn_9+0xb8>
			134c: R_X86_64_PLT32	rt_list_new-0x4
    1350:	test   rax,rax
    1353:	je     140c <botlish_fn_9+0x174>
    1359:	mov    QWORD PTR [rsp+0x18],rax
    135e:	mov    rcx,rax
    1361:	mov    rdx,r13
    1364:	mov    rsi,rbx
    1367:	mov    rdi,r14
    136a:	call   136f <botlish_fn_9+0xd7>
			136b: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    136f:	test   rax,rax
    1372:	je     140c <botlish_fn_9+0x174>
    1378:	mov    QWORD PTR [rsp+0x8],rax
    137d:	mov    QWORD PTR [rsp+0x18],rdx
    1382:	mov    r13,rdx
    1385:	mov    QWORD PTR [rsp+0x30],0x0
    138e:	mov    r9,r15
    1391:	mov    QWORD PTR [rsp+0x38],r9
    1396:	mov    QWORD PTR [rsp+0x40],0x2
    139f:	mov    QWORD PTR [rsp+0x48],rax
    13a4:	mov    esi,0x3
    13a9:	mov    edx,0x4
    13ae:	mov    rcx,r12
    13b1:	mov    rdi,r14
    13b4:	call   13b9 <botlish_fn_9+0x121>
			13b5: R_X86_64_PLT32	rt_construct-0x4
    13b9:	test   rax,rax
    13bc:	je     140c <botlish_fn_9+0x174>
    13c2:	mov    QWORD PTR [rsp],rbx
    13c6:	mov    rdx,r13
    13c9:	mov    QWORD PTR [rsp+0x8],rdx
    13ce:	mov    QWORD PTR [rsp+0x10],rax
    13d3:	mov    r15,rax
    13d6:	jmp    12e4 <botlish_fn_9+0x4c>
    13db:	mov    r9,r15
    13de:	lea    rcx,[rsp+0x20]
    13e3:	mov    QWORD PTR [rsp+0x20],0x0
    13ec:	mov    QWORD PTR [rsp+0x28],r9
    13f1:	mov    esi,0x1
    13f6:	mov    edx,0x2
    13fb:	mov    rdi,r14
    13fe:	call   1403 <botlish_fn_9+0x16b>
			13ff: R_X86_64_PLT32	rt_construct-0x4
    1403:	test   rax,rax
    1406:	jne    1434 <botlish_fn_9+0x19c>
    140c:	xor    rax,rax
    140f:	mov    rbx,QWORD PTR [rsp+0x50]
    1414:	mov    r12,QWORD PTR [rsp+0x58]
    1419:	mov    r13,QWORD PTR [rsp+0x60]
    141e:	mov    r14,QWORD PTR [rsp+0x68]
    1423:	mov    r15,QWORD PTR [rsp+0x70]
    1428:	add    rsp,0x80
    142f:	mov    rsp,rbp
    1432:	pop    rbp
    1433:	ret
    1434:	mov    rbx,QWORD PTR [rsp+0x50]
    1439:	mov    r12,QWORD PTR [rsp+0x58]
    143e:	mov    r13,QWORD PTR [rsp+0x60]
    1443:	mov    r14,QWORD PTR [rsp+0x68]
    1448:	mov    r15,QWORD PTR [rsp+0x70]
    144d:	add    rsp,0x80
    1454:	mov    rsp,rbp
    1457:	pop    rbp
    1458:	ret
    1459:	add    BYTE PTR [rax],al
    145b:	add    BYTE PTR [rax],al
    145d:	add    BYTE PTR [rax],al
    145f:	add    BYTE PTR [rsi],al
    1461:	add    BYTE PTR [rax],al
    1463:	add    BYTE PTR [rax],al
    1465:	add    BYTE PTR [rax],al
	...

0000000000001468 <botlish_entry_9: scan_records<str, int, List[List[str]]>>:
    1468:	push   rbp
    1469:	mov    rbp,rsp
    146c:	mov    rsi,QWORD PTR [rdx]
    146f:	mov    r8,QWORD PTR [rdx+0x8]
    1473:	mov    rcx,QWORD PTR [rdx+0x10]
    1477:	mov    rdx,r8
    147a:	call   147f <botlish_entry_9+0x17>
			147b: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    147f:	mov    rsp,rbp
    1482:	pop    rbp
    1483:	ret

0000000000001484 <botlish_fn_10: csv_parse<str>>:
    1484:	push   rbp
    1485:	mov    rbp,rsp
    1488:	sub    rsp,0x30
    148c:	mov    QWORD PTR [rsp+0x20],r12
    1491:	mov    QWORD PTR [rsp+0x28],r13
    1496:	mov    r13,rdi
    1499:	mov    QWORD PTR [rsp+0x10],0x0
    14a2:	mov    QWORD PTR [rsp],rsi
    14a6:	mov    r12,rsi
    14a9:	mov    QWORD PTR [rsp+0x8],0x1
    14b2:	xor    rdx,rdx
    14b5:	mov    rdi,r13
    14b8:	mov    rsi,rdx
    14bb:	call   14c0 <botlish_fn_10+0x3c>
			14bc: R_X86_64_PLT32	rt_list_new-0x4
    14c0:	test   rax,rax
    14c3:	je     14ea <botlish_fn_10+0x66>
    14c9:	mov    QWORD PTR [rsp+0x10],rax
    14ce:	mov    rcx,rax
    14d1:	mov    edx,0x1
    14d6:	mov    rsi,r12
    14d9:	mov    rdi,r13
    14dc:	call   14e1 <botlish_fn_10+0x5d>
			14dd: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    14e1:	test   rax,rax
    14e4:	jne    1500 <botlish_fn_10+0x7c>
    14ea:	xor    rax,rax
    14ed:	mov    r12,QWORD PTR [rsp+0x20]
    14f2:	mov    r13,QWORD PTR [rsp+0x28]
    14f7:	add    rsp,0x30
    14fb:	mov    rsp,rbp
    14fe:	pop    rbp
    14ff:	ret
    1500:	mov    r12,QWORD PTR [rsp+0x20]
    1505:	mov    r13,QWORD PTR [rsp+0x28]
    150a:	add    rsp,0x30
    150e:	mov    rsp,rbp
    1511:	pop    rbp
    1512:	ret

0000000000001513 <botlish_entry_10: csv_parse<str>>:
    1513:	push   rbp
    1514:	mov    rbp,rsp
    1517:	mov    rsi,QWORD PTR [rdx]
    151a:	call   151f <botlish_entry_10+0xc>
			151b: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
    151f:	mov    rsp,rbp
    1522:	pop    rbp
    1523:	ret

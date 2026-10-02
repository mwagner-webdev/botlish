; source:  examples/stdlib/csv.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5801  (per function: 68 365 430 585 1141 352 795 976 398 524 167)
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
     596:	mov    QWORD PTR [rsp+0x88],rdi
     59e:	mov    QWORD PTR [rsp+0x18],0x0
     5a7:	mov    QWORD PTR [rsp+0x20],0x0
     5b0:	mov    QWORD PTR [rsp],rsi
     5b4:	mov    QWORD PTR [rsp+0x8],rdx
     5b9:	mov    QWORD PTR [rsp+0x10],rcx
     5be:	mov    r13,rcx
     5c1:	lea    r14,[rsp+0x68]
     5c6:	lea    rbx,[rsp+0x28]
     5cb:	mov    r12,rsi
     5ce:	mov    QWORD PTR [rsp+0x90],rdx
     5d6:	mov    rdx,QWORD PTR [rsp+0x90]
     5de:	mov    rsi,r12
     5e1:	mov    rdi,QWORD PTR [rsp+0x88]
     5e9:	call   5ee <botlish_fn_4+0x8b>
			5ea: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     5ee:	test   rax,rax
     5f1:	je     93a <botlish_fn_4+0x3d7>
     5f7:	mov    QWORD PTR [rsp+0x18],rax
     5fc:	mov    rsi,QWORD PTR [rax+0x8]
     600:	mov    rcx,rax
     603:	mov    rax,0xffffffffffffffff
     60a:	test   rsi,rsi
     60d:	jne    61b <botlish_fn_4+0xb8>
     613:	mov    r15,rcx
     616:	jmp    646 <botlish_fn_4+0xe3>
     61b:	mov    r15,rcx
     61e:	movzx  rdi,BYTE PTR [r15+0x18]
     623:	test   rdi,rdi
     626:	jne    641 <botlish_fn_4+0xde>
     62c:	mov    rsi,r15
     62f:	mov    rdi,QWORD PTR [rsp+0x88]
     637:	call   63c <botlish_fn_4+0xd9>
			638: R_X86_64_PLT32	rt_str_to_short-0x4
     63c:	jmp    646 <botlish_fn_4+0xe3>
     641:	movzx  rax,BYTE PTR [r15+0x19]
     646:	cmp    rax,0x22
     64a:	je     70a <botlish_fn_4+0x1a7>
     650:	mov    QWORD PTR [rsp+0x20],0x3
     659:	mov    rsi,QWORD PTR [rsp+0x90]
     661:	test   rsi,0x1
     668:	je     688 <botlish_fn_4+0x125>
     66e:	mov    rax,rsi
     671:	add    rax,0x2
     675:	seto   cl
     678:	test   cl,cl
     67a:	jne    688 <botlish_fn_4+0x125>
     680:	mov    rsi,rax
     683:	jmp    69d <botlish_fn_4+0x13a>
     688:	mov    edx,0x3
     68d:	mov    rdi,QWORD PTR [rsp+0x88]
     695:	call   69a <botlish_fn_4+0x137>
			696: R_X86_64_PLT32	rt_int_add-0x4
     69a:	mov    rsi,rax
     69d:	mov    QWORD PTR [rsp+0x8],rsi
     6a2:	mov    QWORD PTR [rsp+0x90],rsi
     6aa:	mov    QWORD PTR [rsp+0x68],0x0
     6b3:	mov    QWORD PTR [rsp+0x70],r13
     6b8:	mov    QWORD PTR [rsp+0x78],0x0
     6c1:	mov    QWORD PTR [rsp+0x80],r15
     6c9:	mov    esi,0x2
     6ce:	mov    edx,0x4
     6d3:	mov    rcx,r14
     6d6:	mov    rdi,QWORD PTR [rsp+0x88]
     6de:	call   6e3 <botlish_fn_4+0x180>
			6df: R_X86_64_PLT32	rt_construct-0x4
     6e3:	test   rax,rax
     6e6:	je     93a <botlish_fn_4+0x3d7>
     6ec:	mov    QWORD PTR [rsp],r12
     6f0:	mov    rsi,QWORD PTR [rsp+0x90]
     6f8:	mov    QWORD PTR [rsp+0x8],rsi
     6fd:	mov    QWORD PTR [rsp+0x10],rax
     702:	mov    r13,rax
     705:	jmp    5d6 <botlish_fn_4+0x73>
     70a:	mov    QWORD PTR [rsp+0x18],0x3
     713:	mov    rsi,QWORD PTR [rsp+0x90]
     71b:	test   rsi,0x1
     722:	je     742 <botlish_fn_4+0x1df>
     728:	mov    rsi,QWORD PTR [rsp+0x90]
     730:	mov    rdx,rsi
     733:	add    rdx,0x2
     737:	seto   al
     73a:	test   al,al
     73c:	je     75f <botlish_fn_4+0x1fc>
     742:	mov    edx,0x3
     747:	mov    rsi,QWORD PTR [rsp+0x90]
     74f:	mov    rdi,QWORD PTR [rsp+0x88]
     757:	call   75c <botlish_fn_4+0x1f9>
			758: R_X86_64_PLT32	rt_int_add-0x4
     75c:	mov    rdx,rax
     75f:	mov    QWORD PTR [rsp+0x18],rdx
     764:	mov    rcx,rbx
     767:	mov    rsi,r12
     76a:	mov    rdi,QWORD PTR [rsp+0x88]
     772:	call   777 <botlish_fn_4+0x214>
			773: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     777:	test   rax,rax
     77a:	mov    rsi,rax
     77d:	je     93a <botlish_fn_4+0x3d7>
     783:	mov    rdx,QWORD PTR [rsp+0x28]
     788:	mov    rcx,QWORD PTR [rsp+0x30]
     78d:	mov    rdi,QWORD PTR [rsp+0x88]
     795:	mov    rax,QWORD PTR [rdi+0x10]
     799:	mov    r8,QWORD PTR [rax+0x20]
     79d:	call   7a2 <botlish_fn_4+0x23f>
			79e: R_X86_64_PLT32	rt_str_region_eq-0x4
     7a2:	cmp    rax,0x6
     7a6:	je     878 <botlish_fn_4+0x315>
     7ac:	xor    rsi,rsi
     7af:	lea    rcx,[rsp+0x58]
     7b4:	mov    QWORD PTR [rsp+0x58],0x0
     7bd:	mov    QWORD PTR [rsp+0x60],r13
     7c2:	mov    edx,0x2
     7c7:	mov    rdi,QWORD PTR [rsp+0x88]
     7cf:	call   7d4 <botlish_fn_4+0x271>
			7d0: R_X86_64_PLT32	rt_construct-0x4
     7d4:	test   rax,rax
     7d7:	je     93a <botlish_fn_4+0x3d7>
     7dd:	mov    QWORD PTR [rsp],rax
     7e1:	mov    rbx,rax
     7e4:	mov    QWORD PTR [rsp+0x10],0x3
     7ed:	mov    rsi,QWORD PTR [rsp+0x90]
     7f5:	test   rsi,0x1
     7fc:	je     824 <botlish_fn_4+0x2c1>
     802:	mov    rsi,QWORD PTR [rsp+0x90]
     80a:	mov    rdx,rsi
     80d:	add    rdx,0x2
     811:	seto   al
     814:	test   al,al
     816:	jne    824 <botlish_fn_4+0x2c1>
     81c:	mov    rax,rbx
     81f:	jmp    844 <botlish_fn_4+0x2e1>
     824:	mov    edx,0x3
     829:	mov    rsi,QWORD PTR [rsp+0x90]
     831:	mov    rdi,QWORD PTR [rsp+0x88]
     839:	call   83e <botlish_fn_4+0x2db>
			83a: R_X86_64_PLT32	rt_int_add-0x4
     83e:	mov    rdx,rax
     841:	mov    rax,rbx
     844:	mov    rbx,QWORD PTR [rsp+0xa0]
     84c:	mov    r12,QWORD PTR [rsp+0xa8]
     854:	mov    r13,QWORD PTR [rsp+0xb0]
     85c:	mov    r14,QWORD PTR [rsp+0xb8]
     864:	mov    r15,QWORD PTR [rsp+0xc0]
     86c:	add    rsp,0xd0
     873:	mov    rsp,rbp
     876:	pop    rbp
     877:	ret
     878:	mov    QWORD PTR [rsp+0x18],0x5
     881:	mov    rsi,QWORD PTR [rsp+0x90]
     889:	test   rsi,0x1
     890:	je     8c2 <botlish_fn_4+0x35f>
     896:	mov    rsi,QWORD PTR [rsp+0x90]
     89e:	mov    rdi,rsi
     8a1:	add    rdi,0x4
     8a5:	seto   r9b
     8a9:	test   r9b,r9b
     8ac:	jne    8c2 <botlish_fn_4+0x35f>
     8b2:	mov    rsi,rdi
     8b5:	mov    QWORD PTR [rsp+0x90],rdi
     8bd:	jmp    8e7 <botlish_fn_4+0x384>
     8c2:	mov    edx,0x5
     8c7:	mov    rsi,QWORD PTR [rsp+0x90]
     8cf:	mov    rdi,QWORD PTR [rsp+0x88]
     8d7:	call   8dc <botlish_fn_4+0x379>
			8d8: R_X86_64_PLT32	rt_int_add-0x4
     8dc:	mov    rsi,rax
     8df:	mov    QWORD PTR [rsp+0x90],rax
     8e7:	mov    QWORD PTR [rsp+0x8],rsi
     8ec:	mov    rdi,QWORD PTR [rsp+0x88]
     8f4:	mov    rax,QWORD PTR [rdi+0x10]
     8f8:	mov    rax,QWORD PTR [rax+0x20]
     8fc:	mov    QWORD PTR [rsp+0x18],rax
     901:	lea    rcx,[rsp+0x38]
     906:	mov    QWORD PTR [rsp+0x38],0x0
     90f:	mov    QWORD PTR [rsp+0x40],r13
     914:	mov    QWORD PTR [rsp+0x48],0x0
     91d:	mov    QWORD PTR [rsp+0x50],rax
     922:	mov    esi,0x2
     927:	mov    edx,0x4
     92c:	call   931 <botlish_fn_4+0x3ce>
			92d: R_X86_64_PLT32	rt_construct-0x4
     931:	test   rax,rax
     934:	jne    974 <botlish_fn_4+0x411>
     93a:	xor    rdx,rdx
     93d:	mov    rax,rdx
     940:	mov    rbx,QWORD PTR [rsp+0xa0]
     948:	mov    r12,QWORD PTR [rsp+0xa8]
     950:	mov    r13,QWORD PTR [rsp+0xb0]
     958:	mov    r14,QWORD PTR [rsp+0xb8]
     960:	mov    r15,QWORD PTR [rsp+0xc0]
     968:	add    rsp,0xd0
     96f:	mov    rsp,rbp
     972:	pop    rbp
     973:	ret
     974:	mov    QWORD PTR [rsp],r12
     978:	mov    rsi,QWORD PTR [rsp+0x90]
     980:	mov    QWORD PTR [rsp+0x8],rsi
     985:	mov    QWORD PTR [rsp+0x10],rax
     98a:	mov    r13,rax
     98d:	jmp    5d6 <botlish_fn_4+0x73>

0000000000000992 <botlish_entry_4: scan_quoted<str, int, str>>:
     992:	push   rbp
     993:	mov    rbp,rsp
     996:	ud2

0000000000000998 <botlish_fn_5: scan_field<str, int>>:
     998:	push   rbp
     999:	mov    rbp,rsp
     99c:	sub    rsp,0x50
     9a0:	mov    QWORD PTR [rsp+0x30],rbx
     9a5:	mov    QWORD PTR [rsp+0x38],r12
     9aa:	mov    QWORD PTR [rsp+0x40],r13
     9af:	mov    r12,rdi
     9b2:	mov    r13,rdx
     9b5:	mov    QWORD PTR [rsp+0x10],0x0
     9be:	mov    QWORD PTR [rsp],rsi
     9c2:	mov    rbx,rsi
     9c5:	mov    QWORD PTR [rsp+0x8],rdx
     9ca:	lea    rcx,[rsp+0x18]
     9cf:	mov    rdx,r13
     9d2:	mov    rsi,rbx
     9d5:	mov    rdi,r12
     9d8:	call   9dd <botlish_fn_5+0x45>
			9d9: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     9dd:	test   rax,rax
     9e0:	mov    rsi,rax
     9e3:	je     aae <botlish_fn_5+0x116>
     9e9:	mov    rdx,QWORD PTR [rsp+0x18]
     9ee:	mov    rcx,QWORD PTR [rsp+0x20]
     9f3:	mov    rdi,r12
     9f6:	mov    rax,QWORD PTR [rdi+0x10]
     9fa:	mov    r8,QWORD PTR [rax+0x20]
     9fe:	call   a03 <botlish_fn_5+0x6b>
			9ff: R_X86_64_PLT32	rt_str_region_eq-0x4
     a03:	cmp    rax,0x6
     a07:	je     a3f <botlish_fn_5+0xa7>
     a0d:	mov    rcx,r13
     a10:	mov    rsi,rbx
     a13:	mov    rdi,r12
     a16:	mov    rdx,rcx
     a19:	call   a1e <botlish_fn_5+0x86>
			a1a: R_X86_64_PLT32	botlish_fn_3-0x4 ; scan_unquoted<str, int, int>
     a1e:	test   rax,rax
     a21:	je     aae <botlish_fn_5+0x116>
     a27:	mov    rbx,QWORD PTR [rsp+0x30]
     a2c:	mov    r12,QWORD PTR [rsp+0x38]
     a31:	mov    r13,QWORD PTR [rsp+0x40]
     a36:	add    rsp,0x50
     a3a:	mov    rsp,rbp
     a3d:	pop    rbp
     a3e:	ret
     a3f:	mov    rcx,r13
     a42:	mov    QWORD PTR [rsp+0x10],0x3
     a4b:	test   rcx,0x1
     a52:	jne    a60 <botlish_fn_5+0xc8>
     a58:	mov    r13,rcx
     a5b:	jmp    a75 <botlish_fn_5+0xdd>
     a60:	mov    rdx,rcx
     a63:	add    rdx,0x2
     a67:	mov    r13,rcx
     a6a:	seto   al
     a6d:	test   al,al
     a6f:	je     a88 <botlish_fn_5+0xf0>
     a75:	mov    edx,0x3
     a7a:	mov    rsi,r13
     a7d:	mov    rdi,r12
     a80:	call   a85 <botlish_fn_5+0xed>
			a81: R_X86_64_PLT32	rt_int_add-0x4
     a85:	mov    rdx,rax
     a88:	mov    QWORD PTR [rsp+0x8],rdx
     a8d:	mov    rdi,r12
     a90:	mov    rax,QWORD PTR [rdi+0x10]
     a94:	mov    rcx,QWORD PTR [rax+0x8]
     a98:	mov    QWORD PTR [rsp+0x10],rcx
     a9d:	mov    rsi,rbx
     aa0:	call   aa5 <botlish_fn_5+0x10d>
			aa1: R_X86_64_PLT32	botlish_fn_4-0x4 ; scan_quoted<str, int, str>
     aa5:	test   rax,rax
     aa8:	jne    acc <botlish_fn_5+0x134>
     aae:	xor    rdx,rdx
     ab1:	mov    rax,rdx
     ab4:	mov    rbx,QWORD PTR [rsp+0x30]
     ab9:	mov    r12,QWORD PTR [rsp+0x38]
     abe:	mov    r13,QWORD PTR [rsp+0x40]
     ac3:	add    rsp,0x50
     ac7:	mov    rsp,rbp
     aca:	pop    rbp
     acb:	ret
     acc:	mov    rbx,QWORD PTR [rsp+0x30]
     ad1:	mov    r12,QWORD PTR [rsp+0x38]
     ad6:	mov    r13,QWORD PTR [rsp+0x40]
     adb:	add    rsp,0x50
     adf:	mov    rsp,rbp
     ae2:	pop    rbp
     ae3:	ret

0000000000000ae4 <botlish_entry_5: scan_field<str, int>>:
     ae4:	push   rbp
     ae5:	mov    rbp,rsp
     ae8:	ud2

0000000000000aea <botlish_fn_6: scan_record<str, int, List[never]>>:
     aea:	push   rbp
     aeb:	mov    rbp,rsp
     aee:	sub    rsp,0xa0
     af5:	mov    QWORD PTR [rsp+0x70],rbx
     afa:	mov    QWORD PTR [rsp+0x78],r12
     aff:	mov    QWORD PTR [rsp+0x80],r13
     b07:	mov    QWORD PTR [rsp+0x88],r14
     b0f:	mov    QWORD PTR [rsp+0x90],r15
     b17:	mov    r13,rdi
     b1a:	mov    QWORD PTR [rsp+0x18],0x0
     b23:	mov    QWORD PTR [rsp+0x20],0x0
     b2c:	mov    QWORD PTR [rsp],rsi
     b30:	mov    r15,rsi
     b33:	mov    QWORD PTR [rsp+0x8],rdx
     b38:	mov    QWORD PTR [rsp+0x10],rcx
     b3d:	mov    QWORD PTR [rsp+0x58],rcx
     b42:	mov    rsi,r15
     b45:	mov    rdi,r13
     b48:	call   b4d <botlish_fn_6+0x63>
			b49: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     b4d:	test   rax,rax
     b50:	je     d6b <botlish_fn_6+0x281>
     b56:	mov    QWORD PTR [rsp+0x8],rax
     b5b:	mov    QWORD PTR [rsp+0x68],rax
     b60:	mov    QWORD PTR [rsp+0x18],rdx
     b65:	mov    r14,rdx
     b68:	lea    rcx,[rsp+0x28]
     b6d:	mov    rsi,r15
     b70:	mov    rdi,r13
     b73:	call   b78 <botlish_fn_6+0x8e>
			b74: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     b78:	test   rax,rax
     b7b:	mov    QWORD PTR [rsp+0x60],rax
     b80:	je     d6b <botlish_fn_6+0x281>
     b86:	mov    r12,QWORD PTR [rsp+0x28]
     b8b:	mov    rbx,QWORD PTR [rsp+0x30]
     b90:	mov    rdi,r13
     b93:	mov    rcx,QWORD PTR [rdi+0x10]
     b97:	mov    r8,QWORD PTR [rcx+0x10]
     b9b:	mov    rcx,rbx
     b9e:	mov    rdx,r12
     ba1:	mov    rsi,QWORD PTR [rsp+0x60]
     ba6:	call   bab <botlish_fn_6+0xc1>
			ba7: R_X86_64_PLT32	rt_str_region_eq-0x4
     bab:	cmp    rax,0x6
     baf:	je     cc1 <botlish_fn_6+0x1d7>
     bb5:	mov    rdi,r13
     bb8:	mov    rax,QWORD PTR [rdi+0x10]
     bbc:	mov    r8,QWORD PTR [rax+0x18]
     bc0:	mov    rcx,rbx
     bc3:	mov    rdx,r12
     bc6:	mov    rsi,QWORD PTR [rsp+0x60]
     bcb:	call   bd0 <botlish_fn_6+0xe6>
			bcc: R_X86_64_PLT32	rt_str_region_eq-0x4
     bd0:	cmp    rax,0x6
     bd4:	je     c26 <botlish_fn_6+0x13c>
     bda:	mov    rdx,QWORD PTR [rsp+0x68]
     bdf:	mov    rsi,QWORD PTR [rsp+0x58]
     be4:	mov    rdi,r13
     be7:	call   bec <botlish_fn_6+0x102>
			be8: R_X86_64_PLT32	rt_list_append-0x4
     bec:	test   rax,rax
     bef:	je     d6b <botlish_fn_6+0x281>
     bf5:	mov    rdx,r14
     bf8:	mov    rbx,QWORD PTR [rsp+0x70]
     bfd:	mov    r12,QWORD PTR [rsp+0x78]
     c02:	mov    r13,QWORD PTR [rsp+0x80]
     c0a:	mov    r14,QWORD PTR [rsp+0x88]
     c12:	mov    r15,QWORD PTR [rsp+0x90]
     c1a:	add    rsp,0xa0
     c21:	mov    rsp,rbp
     c24:	pop    rbp
     c25:	ret
     c26:	mov    rdx,QWORD PTR [rsp+0x68]
     c2b:	mov    rsi,QWORD PTR [rsp+0x58]
     c30:	mov    rdi,r13
     c33:	call   c38 <botlish_fn_6+0x14e>
			c34: R_X86_64_PLT32	rt_list_append-0x4
     c38:	test   rax,rax
     c3b:	je     d6b <botlish_fn_6+0x281>
     c41:	mov    QWORD PTR [rsp],rax
     c45:	mov    r12,rax
     c48:	mov    QWORD PTR [rsp+0x8],0x3
     c51:	mov    rdx,r14
     c54:	test   rdx,0x1
     c5b:	je     c7d <botlish_fn_6+0x193>
     c61:	mov    rdx,r14
     c64:	add    rdx,0x2
     c68:	seto   sil
     c6c:	test   sil,sil
     c6f:	jne    c7d <botlish_fn_6+0x193>
     c75:	mov    rax,r12
     c78:	jmp    c93 <botlish_fn_6+0x1a9>
     c7d:	mov    edx,0x3
     c82:	mov    rsi,r14
     c85:	mov    rdi,r13
     c88:	call   c8d <botlish_fn_6+0x1a3>
			c89: R_X86_64_PLT32	rt_int_add-0x4
     c8d:	mov    rdx,rax
     c90:	mov    rax,r12
     c93:	mov    rbx,QWORD PTR [rsp+0x70]
     c98:	mov    r12,QWORD PTR [rsp+0x78]
     c9d:	mov    r13,QWORD PTR [rsp+0x80]
     ca5:	mov    r14,QWORD PTR [rsp+0x88]
     cad:	mov    r15,QWORD PTR [rsp+0x90]
     cb5:	add    rsp,0xa0
     cbc:	mov    rsp,rbp
     cbf:	pop    rbp
     cc0:	ret
     cc1:	mov    rsi,r14
     cc4:	mov    r12d,0x3
     cca:	mov    QWORD PTR [rsp+0x20],0x3
     cd3:	test   rsi,0x1
     cda:	je     cf2 <botlish_fn_6+0x208>
     ce0:	mov    rdx,rsi
     ce3:	add    rdx,0x2
     ce7:	seto   al
     cea:	test   al,al
     cec:	je     d00 <botlish_fn_6+0x216>
     cf2:	mov    rdx,r12
     cf5:	mov    rdi,r13
     cf8:	call   cfd <botlish_fn_6+0x213>
			cf9: R_X86_64_PLT32	rt_int_add-0x4
     cfd:	mov    rdx,rax
     d00:	mov    QWORD PTR [rsp+0x18],rdx
     d05:	mov    rbx,rdx
     d08:	lea    rcx,[rsp+0x38]
     d0d:	mov    QWORD PTR [rsp+0x38],0x0
     d16:	mov    rsi,QWORD PTR [rsp+0x58]
     d1b:	mov    QWORD PTR [rsp+0x40],rsi
     d20:	mov    QWORD PTR [rsp+0x48],0x2
     d29:	mov    rdx,QWORD PTR [rsp+0x68]
     d2e:	mov    QWORD PTR [rsp+0x50],rdx
     d33:	mov    edx,0x4
     d38:	mov    rsi,r12
     d3b:	mov    rdi,r13
     d3e:	call   d43 <botlish_fn_6+0x259>
			d3f: R_X86_64_PLT32	rt_construct-0x4
     d43:	test   rax,rax
     d46:	je     d6b <botlish_fn_6+0x281>
     d4c:	mov    QWORD PTR [rsp+0x8],rax
     d51:	mov    rcx,rax
     d54:	mov    rdx,rbx
     d57:	mov    rsi,r15
     d5a:	mov    rdi,r13
     d5d:	call   d62 <botlish_fn_6+0x278>
			d5e: R_X86_64_PLT32	botlish_fn_7-0x4 ; scan_record<str, int, List[str]>
     d62:	test   rax,rax
     d65:	jne    d9f <botlish_fn_6+0x2b5>
     d6b:	xor    rdx,rdx
     d6e:	mov    rax,rdx
     d71:	mov    rbx,QWORD PTR [rsp+0x70]
     d76:	mov    r12,QWORD PTR [rsp+0x78]
     d7b:	mov    r13,QWORD PTR [rsp+0x80]
     d83:	mov    r14,QWORD PTR [rsp+0x88]
     d8b:	mov    r15,QWORD PTR [rsp+0x90]
     d93:	add    rsp,0xa0
     d9a:	mov    rsp,rbp
     d9d:	pop    rbp
     d9e:	ret
     d9f:	mov    rbx,QWORD PTR [rsp+0x70]
     da4:	mov    r12,QWORD PTR [rsp+0x78]
     da9:	mov    r13,QWORD PTR [rsp+0x80]
     db1:	mov    r14,QWORD PTR [rsp+0x88]
     db9:	mov    r15,QWORD PTR [rsp+0x90]
     dc1:	add    rsp,0xa0
     dc8:	mov    rsp,rbp
     dcb:	pop    rbp
     dcc:	ret

0000000000000dcd <botlish_entry_6: scan_record<str, int, List[never]>>:
     dcd:	push   rbp
     dce:	mov    rbp,rsp
     dd1:	ud2

0000000000000dd3 <botlish_fn_7: scan_record<str, int, List[str]>>:
     dd3:	push   rbp
     dd4:	mov    rbp,rsp
     dd7:	sub    rsp,0xf0
     dde:	mov    QWORD PTR [rsp+0xc0],rbx
     de6:	mov    QWORD PTR [rsp+0xc8],r12
     dee:	mov    QWORD PTR [rsp+0xd0],r13
     df6:	mov    QWORD PTR [rsp+0xd8],r14
     dfe:	mov    QWORD PTR [rsp+0xe0],r15
     e06:	mov    QWORD PTR [rsp+0x98],rdi
     e0e:	mov    QWORD PTR [rsp+0x18],0x0
     e17:	mov    QWORD PTR [rsp+0x20],0x0
     e20:	mov    QWORD PTR [rsp],rsi
     e24:	mov    QWORD PTR [rsp+0x8],rdx
     e29:	mov    QWORD PTR [rsp+0xa0],rdx
     e31:	mov    QWORD PTR [rsp+0x10],rcx
     e36:	mov    r15,rcx
     e39:	lea    rbx,[rsp+0x28]
     e3e:	mov    r12,rsi
     e41:	mov    rsi,r12
     e44:	mov    rdi,QWORD PTR [rsp+0x98]
     e4c:	call   e51 <botlish_fn_7+0x7e>
			e4d: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     e51:	test   rax,rax
     e54:	je     1111 <botlish_fn_7+0x33e>
     e5a:	mov    QWORD PTR [rsp+0x8],rax
     e5f:	mov    QWORD PTR [rsp+0xb0],rax
     e67:	mov    QWORD PTR [rsp+0x18],rdx
     e6c:	mov    QWORD PTR [rsp+0xb8],rdx
     e74:	mov    rcx,rbx
     e77:	mov    rsi,r12
     e7a:	mov    rdi,QWORD PTR [rsp+0x98]
     e82:	call   e87 <botlish_fn_7+0xb4>
			e83: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     e87:	test   rax,rax
     e8a:	mov    QWORD PTR [rsp+0xa8],rax
     e92:	je     1111 <botlish_fn_7+0x33e>
     e98:	mov    r13,QWORD PTR [rsp+0x28]
     e9d:	mov    r14,QWORD PTR [rsp+0x30]
     ea2:	mov    rdi,QWORD PTR [rsp+0x98]
     eaa:	mov    rcx,QWORD PTR [rdi+0x10]
     eae:	mov    r8,QWORD PTR [rcx+0x10]
     eb2:	mov    rcx,r14
     eb5:	mov    rdx,r13
     eb8:	mov    rsi,QWORD PTR [rsp+0xa8]
     ec0:	call   ec5 <botlish_fn_7+0xf2>
			ec1: R_X86_64_PLT32	rt_str_region_eq-0x4
     ec5:	cmp    rax,0x6
     ec9:	je     1071 <botlish_fn_7+0x29e>
     ecf:	mov    rdi,QWORD PTR [rsp+0x98]
     ed7:	mov    rax,QWORD PTR [rdi+0x10]
     edb:	mov    r8,QWORD PTR [rax+0x18]
     edf:	mov    rcx,r14
     ee2:	mov    rdx,r13
     ee5:	mov    rsi,QWORD PTR [rsp+0xa8]
     eed:	call   ef2 <botlish_fn_7+0x11f>
			eee: R_X86_64_PLT32	rt_str_region_eq-0x4
     ef2:	cmp    rax,0x6
     ef6:	je     f8d <botlish_fn_7+0x1ba>
     efc:	lea    rcx,[rsp+0x78]
     f01:	mov    QWORD PTR [rsp+0x78],0x0
     f0a:	mov    r14,r15
     f0d:	mov    QWORD PTR [rsp+0x80],r14
     f15:	mov    QWORD PTR [rsp+0x88],0x2
     f21:	mov    r15,QWORD PTR [rsp+0xb0]
     f29:	mov    QWORD PTR [rsp+0x90],r15
     f31:	mov    esi,0x1
     f36:	mov    edx,0x4
     f3b:	mov    rdi,QWORD PTR [rsp+0x98]
     f43:	call   f48 <botlish_fn_7+0x175>
			f44: R_X86_64_PLT32	rt_construct-0x4
     f48:	test   rax,rax
     f4b:	je     1111 <botlish_fn_7+0x33e>
     f51:	mov    rdx,QWORD PTR [rsp+0xb8]
     f59:	mov    rbx,QWORD PTR [rsp+0xc0]
     f61:	mov    r12,QWORD PTR [rsp+0xc8]
     f69:	mov    r13,QWORD PTR [rsp+0xd0]
     f71:	mov    r14,QWORD PTR [rsp+0xd8]
     f79:	mov    r15,QWORD PTR [rsp+0xe0]
     f81:	add    rsp,0xf0
     f88:	mov    rsp,rbp
     f8b:	pop    rbp
     f8c:	ret
     f8d:	mov    r14,r15
     f90:	mov    r15,QWORD PTR [rsp+0xb0]
     f98:	lea    rcx,[rsp+0x58]
     f9d:	mov    QWORD PTR [rsp+0x58],0x0
     fa6:	mov    QWORD PTR [rsp+0x60],r14
     fab:	mov    QWORD PTR [rsp+0x68],0x2
     fb4:	mov    QWORD PTR [rsp+0x70],r15
     fb9:	mov    esi,0x1
     fbe:	mov    edx,0x4
     fc3:	mov    rdi,QWORD PTR [rsp+0x98]
     fcb:	call   fd0 <botlish_fn_7+0x1fd>
			fcc: R_X86_64_PLT32	rt_construct-0x4
     fd0:	test   rax,rax
     fd3:	je     1111 <botlish_fn_7+0x33e>
     fd9:	mov    QWORD PTR [rsp],rax
     fdd:	mov    r12,rax
     fe0:	mov    QWORD PTR [rsp+0x8],0x3
     fe9:	mov    rdx,QWORD PTR [rsp+0xb8]
     ff1:	test   rdx,0x1
     ff8:	je     101d <botlish_fn_7+0x24a>
     ffe:	mov    rdx,QWORD PTR [rsp+0xb8]
    1006:	add    rdx,0x2
    100a:	seto   al
    100d:	test   al,al
    100f:	jne    101d <botlish_fn_7+0x24a>
    1015:	mov    rax,r12
    1018:	jmp    103d <botlish_fn_7+0x26a>
    101d:	mov    edx,0x3
    1022:	mov    rsi,QWORD PTR [rsp+0xb8]
    102a:	mov    rdi,QWORD PTR [rsp+0x98]
    1032:	call   1037 <botlish_fn_7+0x264>
			1033: R_X86_64_PLT32	rt_int_add-0x4
    1037:	mov    rdx,rax
    103a:	mov    rax,r12
    103d:	mov    rbx,QWORD PTR [rsp+0xc0]
    1045:	mov    r12,QWORD PTR [rsp+0xc8]
    104d:	mov    r13,QWORD PTR [rsp+0xd0]
    1055:	mov    r14,QWORD PTR [rsp+0xd8]
    105d:	mov    r15,QWORD PTR [rsp+0xe0]
    1065:	add    rsp,0xf0
    106c:	mov    rsp,rbp
    106f:	pop    rbp
    1070:	ret
    1071:	mov    r14,r15
    1074:	mov    r15,QWORD PTR [rsp+0xb0]
    107c:	mov    rsi,QWORD PTR [rsp+0xb8]
    1084:	mov    r13d,0x3
    108a:	mov    QWORD PTR [rsp+0x20],0x3
    1093:	test   rsi,0x1
    109a:	je     10b2 <botlish_fn_7+0x2df>
    10a0:	mov    rdx,rsi
    10a3:	add    rdx,0x2
    10a7:	seto   al
    10aa:	test   al,al
    10ac:	je     10c5 <botlish_fn_7+0x2f2>
    10b2:	mov    rdx,r13
    10b5:	mov    rdi,QWORD PTR [rsp+0x98]
    10bd:	call   10c2 <botlish_fn_7+0x2ef>
			10be: R_X86_64_PLT32	rt_int_add-0x4
    10c2:	mov    rdx,rax
    10c5:	mov    QWORD PTR [rsp+0x18],rdx
    10ca:	mov    QWORD PTR [rsp+0xa0],rdx
    10d2:	lea    rcx,[rsp+0x38]
    10d7:	mov    QWORD PTR [rsp+0x38],0x0
    10e0:	mov    QWORD PTR [rsp+0x40],r14
    10e5:	mov    QWORD PTR [rsp+0x48],0x2
    10ee:	mov    QWORD PTR [rsp+0x50],r15
    10f3:	mov    edx,0x4
    10f8:	mov    rsi,r13
    10fb:	mov    rdi,QWORD PTR [rsp+0x98]
    1103:	call   1108 <botlish_fn_7+0x335>
			1104: R_X86_64_PLT32	rt_construct-0x4
    1108:	test   rax,rax
    110b:	jne    114b <botlish_fn_7+0x378>
    1111:	xor    rdx,rdx
    1114:	mov    rax,rdx
    1117:	mov    rbx,QWORD PTR [rsp+0xc0]
    111f:	mov    r12,QWORD PTR [rsp+0xc8]
    1127:	mov    r13,QWORD PTR [rsp+0xd0]
    112f:	mov    r14,QWORD PTR [rsp+0xd8]
    1137:	mov    r15,QWORD PTR [rsp+0xe0]
    113f:	add    rsp,0xf0
    1146:	mov    rsp,rbp
    1149:	pop    rbp
    114a:	ret
    114b:	mov    QWORD PTR [rsp],r12
    114f:	mov    rdx,QWORD PTR [rsp+0xa0]
    1157:	mov    QWORD PTR [rsp+0x8],rdx
    115c:	mov    QWORD PTR [rsp+0x10],rax
    1161:	mov    r15,rax
    1164:	jmp    e41 <botlish_fn_7+0x6e>

0000000000001169 <botlish_entry_7: scan_record<str, int, List[str]>>:
    1169:	push   rbp
    116a:	mov    rbp,rsp
    116d:	ud2

000000000000116f <botlish_fn_8: scan_records<str, int, List[never]>>:
    116f:	push   rbp
    1170:	mov    rbp,rsp
    1173:	sub    rsp,0x60
    1177:	mov    QWORD PTR [rsp+0x40],rbx
    117c:	mov    QWORD PTR [rsp+0x48],r12
    1181:	mov    QWORD PTR [rsp+0x50],r13
    1186:	mov    QWORD PTR [rsp+0x58],r14
    118b:	mov    r12,rdi
    118e:	mov    QWORD PTR [rsp+0x18],0x0
    1197:	mov    QWORD PTR [rsp],rsi
    119b:	mov    rbx,rsi
    119e:	mov    QWORD PTR [rsp+0x8],rdx
    11a3:	mov    r14,rdx
    11a6:	mov    QWORD PTR [rsp+0x10],rcx
    11ab:	mov    r13,rcx
    11ae:	mov    rsi,rbx
    11b1:	mov    rdi,r12
    11b4:	call   11b9 <botlish_fn_8+0x4a>
			11b5: R_X86_64_PLT32	rt_str_len-0x4
    11b9:	mov    rdx,r14
    11bc:	mov    rcx,rdx
    11bf:	sar    rcx,1
    11c2:	sar    rax,1
    11c5:	cmp    rcx,rax
    11c8:	jge    12ac <botlish_fn_8+0x13d>
    11ce:	xor    rdx,rdx
    11d1:	mov    rdi,r12
    11d4:	mov    rsi,rdx
    11d7:	call   11dc <botlish_fn_8+0x6d>
			11d8: R_X86_64_PLT32	rt_list_new-0x4
    11dc:	test   rax,rax
    11df:	je     126f <botlish_fn_8+0x100>
    11e5:	mov    QWORD PTR [rsp+0x18],rax
    11ea:	mov    rcx,rax
    11ed:	mov    rdx,r14
    11f0:	mov    rsi,rbx
    11f3:	mov    rdi,r12
    11f6:	call   11fb <botlish_fn_8+0x8c>
			11f7: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    11fb:	test   rax,rax
    11fe:	je     126f <botlish_fn_8+0x100>
    1204:	mov    QWORD PTR [rsp+0x8],rax
    1209:	mov    QWORD PTR [rsp+0x18],rdx
    120e:	mov    r14,rdx
    1211:	lea    rcx,[rsp+0x20]
    1216:	mov    QWORD PTR [rsp+0x20],0x0
    121f:	mov    rdx,r13
    1222:	mov    QWORD PTR [rsp+0x28],rdx
    1227:	mov    QWORD PTR [rsp+0x30],0x2
    1230:	mov    QWORD PTR [rsp+0x38],rax
    1235:	mov    esi,0x3
    123a:	mov    edx,0x4
    123f:	mov    rdi,r12
    1242:	call   1247 <botlish_fn_8+0xd8>
			1243: R_X86_64_PLT32	rt_construct-0x4
    1247:	test   rax,rax
    124a:	je     126f <botlish_fn_8+0x100>
    1250:	mov    QWORD PTR [rsp+0x8],rax
    1255:	mov    rcx,rax
    1258:	mov    rdx,r14
    125b:	mov    rsi,rbx
    125e:	mov    rdi,r12
    1261:	call   1266 <botlish_fn_8+0xf7>
			1262: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    1266:	test   rax,rax
    1269:	jne    128f <botlish_fn_8+0x120>
    126f:	xor    rax,rax
    1272:	mov    rbx,QWORD PTR [rsp+0x40]
    1277:	mov    r12,QWORD PTR [rsp+0x48]
    127c:	mov    r13,QWORD PTR [rsp+0x50]
    1281:	mov    r14,QWORD PTR [rsp+0x58]
    1286:	add    rsp,0x60
    128a:	mov    rsp,rbp
    128d:	pop    rbp
    128e:	ret
    128f:	mov    rbx,QWORD PTR [rsp+0x40]
    1294:	mov    r12,QWORD PTR [rsp+0x48]
    1299:	mov    r13,QWORD PTR [rsp+0x50]
    129e:	mov    r14,QWORD PTR [rsp+0x58]
    12a3:	add    rsp,0x60
    12a7:	mov    rsp,rbp
    12aa:	pop    rbp
    12ab:	ret
    12ac:	mov    rax,r13
    12af:	mov    rbx,QWORD PTR [rsp+0x40]
    12b4:	mov    r12,QWORD PTR [rsp+0x48]
    12b9:	mov    r13,QWORD PTR [rsp+0x50]
    12be:	mov    r14,QWORD PTR [rsp+0x58]
    12c3:	add    rsp,0x60
    12c7:	mov    rsp,rbp
    12ca:	pop    rbp
    12cb:	ret

00000000000012cc <botlish_entry_8: scan_records<str, int, List[never]>>:
    12cc:	push   rbp
    12cd:	mov    rbp,rsp
    12d0:	mov    rsi,QWORD PTR [rdx]
    12d3:	mov    r8,QWORD PTR [rdx+0x8]
    12d7:	mov    rcx,QWORD PTR [rdx+0x10]
    12db:	mov    rdx,r8
    12de:	call   12e3 <botlish_entry_8+0x17>
			12df: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    12e3:	mov    rsp,rbp
    12e6:	pop    rbp
    12e7:	ret

00000000000012e8 <botlish_fn_9: scan_records<str, int, List[List[str]]>>:
    12e8:	push   rbp
    12e9:	mov    rbp,rsp
    12ec:	sub    rsp,0x80
    12f3:	mov    QWORD PTR [rsp+0x50],rbx
    12f8:	mov    QWORD PTR [rsp+0x58],r12
    12fd:	mov    QWORD PTR [rsp+0x60],r13
    1302:	mov    QWORD PTR [rsp+0x68],r14
    1307:	mov    QWORD PTR [rsp+0x70],r15
    130c:	mov    r14,rdi
    130f:	mov    QWORD PTR [rsp+0x18],0x0
    1318:	mov    QWORD PTR [rsp],rsi
    131c:	mov    QWORD PTR [rsp+0x8],rdx
    1321:	mov    r13,rdx
    1324:	mov    QWORD PTR [rsp+0x10],rcx
    1329:	mov    r15,rcx
    132c:	lea    r12,[rsp+0x30]
    1331:	mov    rbx,rsi
    1334:	mov    rsi,rbx
    1337:	mov    rdi,r14
    133a:	call   133f <botlish_fn_9+0x57>
			133b: R_X86_64_PLT32	rt_str_len-0x4
    133f:	mov    rcx,r13
    1342:	and    rcx,rax
    1345:	mov    rdx,rax
    1348:	test   rcx,0x1
    134f:	jne    1375 <botlish_fn_9+0x8d>
    1355:	mov    rsi,r13
    1358:	mov    rdi,r14
    135b:	call   1360 <botlish_fn_9+0x78>
			135c: R_X86_64_PLT32	rt_int_cmp-0x4
    1360:	mov    ecx,0x2
    1365:	test   rax,rax
    1368:	cmovge rcx,QWORD PTR [rip+0x140]        # 14b0 <botlish_fn_9+0x1c8>
    1370:	jmp    1388 <botlish_fn_9+0xa0>
    1375:	mov    ecx,0x2
    137a:	mov    rax,r13
    137d:	cmp    rax,rdx
    1380:	cmovge rcx,QWORD PTR [rip+0x128]        # 14b0 <botlish_fn_9+0x1c8>
    1388:	cmp    rcx,0x6
    138c:	je     142b <botlish_fn_9+0x143>
    1392:	xor    rdx,rdx
    1395:	mov    rdi,r14
    1398:	mov    rsi,rdx
    139b:	call   13a0 <botlish_fn_9+0xb8>
			139c: R_X86_64_PLT32	rt_list_new-0x4
    13a0:	test   rax,rax
    13a3:	je     145c <botlish_fn_9+0x174>
    13a9:	mov    QWORD PTR [rsp+0x18],rax
    13ae:	mov    rcx,rax
    13b1:	mov    rdx,r13
    13b4:	mov    rsi,rbx
    13b7:	mov    rdi,r14
    13ba:	call   13bf <botlish_fn_9+0xd7>
			13bb: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    13bf:	test   rax,rax
    13c2:	je     145c <botlish_fn_9+0x174>
    13c8:	mov    QWORD PTR [rsp+0x8],rax
    13cd:	mov    QWORD PTR [rsp+0x18],rdx
    13d2:	mov    r13,rdx
    13d5:	mov    QWORD PTR [rsp+0x30],0x0
    13de:	mov    r9,r15
    13e1:	mov    QWORD PTR [rsp+0x38],r9
    13e6:	mov    QWORD PTR [rsp+0x40],0x2
    13ef:	mov    QWORD PTR [rsp+0x48],rax
    13f4:	mov    esi,0x3
    13f9:	mov    edx,0x4
    13fe:	mov    rcx,r12
    1401:	mov    rdi,r14
    1404:	call   1409 <botlish_fn_9+0x121>
			1405: R_X86_64_PLT32	rt_construct-0x4
    1409:	test   rax,rax
    140c:	je     145c <botlish_fn_9+0x174>
    1412:	mov    QWORD PTR [rsp],rbx
    1416:	mov    rdx,r13
    1419:	mov    QWORD PTR [rsp+0x8],rdx
    141e:	mov    QWORD PTR [rsp+0x10],rax
    1423:	mov    r15,rax
    1426:	jmp    1334 <botlish_fn_9+0x4c>
    142b:	mov    r9,r15
    142e:	lea    rcx,[rsp+0x20]
    1433:	mov    QWORD PTR [rsp+0x20],0x0
    143c:	mov    QWORD PTR [rsp+0x28],r9
    1441:	mov    esi,0x1
    1446:	mov    edx,0x2
    144b:	mov    rdi,r14
    144e:	call   1453 <botlish_fn_9+0x16b>
			144f: R_X86_64_PLT32	rt_construct-0x4
    1453:	test   rax,rax
    1456:	jne    1484 <botlish_fn_9+0x19c>
    145c:	xor    rax,rax
    145f:	mov    rbx,QWORD PTR [rsp+0x50]
    1464:	mov    r12,QWORD PTR [rsp+0x58]
    1469:	mov    r13,QWORD PTR [rsp+0x60]
    146e:	mov    r14,QWORD PTR [rsp+0x68]
    1473:	mov    r15,QWORD PTR [rsp+0x70]
    1478:	add    rsp,0x80
    147f:	mov    rsp,rbp
    1482:	pop    rbp
    1483:	ret
    1484:	mov    rbx,QWORD PTR [rsp+0x50]
    1489:	mov    r12,QWORD PTR [rsp+0x58]
    148e:	mov    r13,QWORD PTR [rsp+0x60]
    1493:	mov    r14,QWORD PTR [rsp+0x68]
    1498:	mov    r15,QWORD PTR [rsp+0x70]
    149d:	add    rsp,0x80
    14a4:	mov    rsp,rbp
    14a7:	pop    rbp
    14a8:	ret
    14a9:	add    BYTE PTR [rax],al
    14ab:	add    BYTE PTR [rax],al
    14ad:	add    BYTE PTR [rax],al
    14af:	add    BYTE PTR [rsi],al
    14b1:	add    BYTE PTR [rax],al
    14b3:	add    BYTE PTR [rax],al
    14b5:	add    BYTE PTR [rax],al
	...

00000000000014b8 <botlish_entry_9: scan_records<str, int, List[List[str]]>>:
    14b8:	push   rbp
    14b9:	mov    rbp,rsp
    14bc:	mov    rsi,QWORD PTR [rdx]
    14bf:	mov    r8,QWORD PTR [rdx+0x8]
    14c3:	mov    rcx,QWORD PTR [rdx+0x10]
    14c7:	mov    rdx,r8
    14ca:	call   14cf <botlish_entry_9+0x17>
			14cb: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    14cf:	mov    rsp,rbp
    14d2:	pop    rbp
    14d3:	ret

00000000000014d4 <botlish_fn_10: csv_parse<str>>:
    14d4:	push   rbp
    14d5:	mov    rbp,rsp
    14d8:	sub    rsp,0x30
    14dc:	mov    QWORD PTR [rsp+0x20],r12
    14e1:	mov    QWORD PTR [rsp+0x28],r13
    14e6:	mov    r13,rdi
    14e9:	mov    QWORD PTR [rsp+0x10],0x0
    14f2:	mov    QWORD PTR [rsp],rsi
    14f6:	mov    r12,rsi
    14f9:	mov    QWORD PTR [rsp+0x8],0x1
    1502:	xor    rdx,rdx
    1505:	mov    rdi,r13
    1508:	mov    rsi,rdx
    150b:	call   1510 <botlish_fn_10+0x3c>
			150c: R_X86_64_PLT32	rt_list_new-0x4
    1510:	test   rax,rax
    1513:	je     153a <botlish_fn_10+0x66>
    1519:	mov    QWORD PTR [rsp+0x10],rax
    151e:	mov    rcx,rax
    1521:	mov    edx,0x1
    1526:	mov    rsi,r12
    1529:	mov    rdi,r13
    152c:	call   1531 <botlish_fn_10+0x5d>
			152d: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    1531:	test   rax,rax
    1534:	jne    1550 <botlish_fn_10+0x7c>
    153a:	xor    rax,rax
    153d:	mov    r12,QWORD PTR [rsp+0x20]
    1542:	mov    r13,QWORD PTR [rsp+0x28]
    1547:	add    rsp,0x30
    154b:	mov    rsp,rbp
    154e:	pop    rbp
    154f:	ret
    1550:	mov    r12,QWORD PTR [rsp+0x20]
    1555:	mov    r13,QWORD PTR [rsp+0x28]
    155a:	add    rsp,0x30
    155e:	mov    rsp,rbp
    1561:	pop    rbp
    1562:	ret

0000000000001563 <botlish_entry_10: csv_parse<str>>:
    1563:	push   rbp
    1564:	mov    rbp,rsp
    1567:	mov    rsi,QWORD PTR [rdx]
    156a:	call   156f <botlish_entry_10+0xc>
			156b: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
    156f:	mov    rsp,rbp
    1572:	pop    rbp
    1573:	ret

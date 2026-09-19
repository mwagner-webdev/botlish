; source:  examples/stdlib/csv.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5980  (per function: 181 365 430 703 925 482 788 773 512 540 281)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> peek<str, int>
;   botlish_fn_2 / botlish_entry_2 -> peek<str, int>
;   botlish_fn_3 / botlish_entry_3 -> scan_unquoted<str, int, int>
;   botlish_fn_4 / botlish_entry_4 -> scan_quoted<str, int, str>
;   botlish_fn_5 / botlish_entry_5 -> scan_field<str, int>
;   botlish_fn_6 / botlish_entry_6 -> scan_record<str, int, list<never>>
;   botlish_fn_7 / botlish_entry_7 -> scan_record<str, int, list<str>>
;   botlish_fn_8 / botlish_entry_8 -> scan_records<str, int, list<never>>
;   botlish_fn_9 / botlish_entry_9 -> scan_records<str, int, list<list<str>>>
;   botlish_fn_10 / botlish_entry_10 -> csv_parse<str>


csv.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x20
       8:	mov    QWORD PTR [rsp+0x10],r13
       d:	mov    QWORD PTR [rsp+0x18],r14
      12:	mov    r13,QWORD PTR [rdi]
      15:	mov    rax,QWORD PTR [rdi+0x8]
      19:	lea    rcx,[r13+0x8]
      1d:	cmp    rcx,rax
      20:	ja     86 <botlish_fn_0+0x86>
      26:	lea    rax,[r13+0x8]
      2a:	mov    QWORD PTR [rdi],rax
      2d:	mov    QWORD PTR [r13+0x0],0x0
      35:	mov    rax,QWORD PTR [rdi+0x10]
      39:	mov    r14,rdi
      3c:	mov    rsi,QWORD PTR [rax]
      3f:	mov    QWORD PTR [rsp],rsi
      43:	call   48 <botlish_fn_0+0x48>
			44: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
      48:	test   rax,rax
      4b:	jne    6d <botlish_fn_0+0x6d>
      51:	mov    rdi,r14
      54:	mov    QWORD PTR [rdi],r13
      57:	xor    rax,rax
      5a:	mov    r13,QWORD PTR [rsp+0x10]
      5f:	mov    r14,QWORD PTR [rsp+0x18]
      64:	add    rsp,0x20
      68:	mov    rsp,rbp
      6b:	pop    rbp
      6c:	ret
      6d:	mov    rdi,r14
      70:	mov    QWORD PTR [rdi],r13
      73:	mov    r13,QWORD PTR [rsp+0x10]
      78:	mov    r14,QWORD PTR [rsp+0x18]
      7d:	add    rsp,0x20
      81:	mov    rsp,rbp
      84:	pop    rbp
      85:	ret
      86:	call   8b <botlish_fn_0+0x8b>
			87: R_X86_64_PLT32	rt_stack_overflow-0x4
      8b:	xor    rax,rax
      8e:	mov    r13,QWORD PTR [rsp+0x10]
      93:	mov    r14,QWORD PTR [rsp+0x18]
      98:	add    rsp,0x20
      9c:	mov    rsp,rbp
      9f:	pop    rbp
      a0:	ret

00000000000000a1 <botlish_entry_0: <program entry>>:
      a1:	push   rbp
      a2:	mov    rbp,rsp
      a5:	call   aa <botlish_entry_0+0x9>
			a6: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      aa:	mov    rsp,rbp
      ad:	pop    rbp
      ae:	ret
	...

00000000000000b0 <botlish_fn_1: peek<str, int>>:
      b0:	push   rbp
      b1:	mov    rbp,rsp
      b4:	sub    rsp,0x40
      b8:	mov    QWORD PTR [rsp+0x20],rbx
      bd:	mov    QWORD PTR [rsp+0x28],r12
      c2:	mov    QWORD PTR [rsp+0x30],r13
      c7:	mov    r13,rdi
      ca:	mov    QWORD PTR [rsp],rsi
      ce:	mov    r12,rsi
      d1:	mov    QWORD PTR [rsp+0x8],rdx
      d6:	mov    rbx,rdx
      d9:	mov    rsi,r12
      dc:	mov    rdi,r13
      df:	call   e4 <botlish_fn_1+0x34>
			e0: R_X86_64_PLT32	rt_str_len-0x4
      e4:	mov    rcx,rbx
      e7:	and    rcx,rax
      ea:	mov    rdx,rax
      ed:	test   rcx,0x1
      f4:	jne    11a <botlish_fn_1+0x6a>
      fa:	mov    rsi,rbx
      fd:	mov    rdi,r13
     100:	call   105 <botlish_fn_1+0x55>
			101: R_X86_64_PLT32	rt_int_cmp-0x4
     105:	mov    ecx,0x2
     10a:	test   rax,rax
     10d:	cmovge rcx,QWORD PTR [rip+0xd3]        # 1e8 <botlish_fn_1+0x138>
     115:	jmp    12a <botlish_fn_1+0x7a>
     11a:	mov    ecx,0x2
     11f:	cmp    rbx,rdx
     122:	cmovge rcx,QWORD PTR [rip+0xbe]        # 1e8 <botlish_fn_1+0x138>
     12a:	cmp    rcx,0x6
     12e:	je     1be <botlish_fn_1+0x10e>
     134:	mov    QWORD PTR [rsp+0x10],0x3
     13d:	test   rbx,0x1
     144:	je     15c <botlish_fn_1+0xac>
     14a:	mov    rcx,rbx
     14d:	add    rcx,0x2
     151:	seto   al
     154:	test   al,al
     156:	je     16f <botlish_fn_1+0xbf>
     15c:	mov    edx,0x3
     161:	mov    rsi,rbx
     164:	mov    rdi,r13
     167:	call   16c <botlish_fn_1+0xbc>
			168: R_X86_64_PLT32	rt_int_add-0x4
     16c:	mov    rcx,rax
     16f:	mov    QWORD PTR [rsp+0x10],rcx
     174:	mov    rdx,rbx
     177:	mov    rsi,r12
     17a:	mov    rdi,r13
     17d:	call   182 <botlish_fn_1+0xd2>
			17e: R_X86_64_PLT32	rt_substr-0x4
     182:	test   rax,rax
     185:	jne    1a6 <botlish_fn_1+0xf6>
     18b:	xor    rax,rax
     18e:	mov    rbx,QWORD PTR [rsp+0x20]
     193:	mov    r12,QWORD PTR [rsp+0x28]
     198:	mov    r13,QWORD PTR [rsp+0x30]
     19d:	add    rsp,0x40
     1a1:	mov    rsp,rbp
     1a4:	pop    rbp
     1a5:	ret
     1a6:	mov    rbx,QWORD PTR [rsp+0x20]
     1ab:	mov    r12,QWORD PTR [rsp+0x28]
     1b0:	mov    r13,QWORD PTR [rsp+0x30]
     1b5:	add    rsp,0x40
     1b9:	mov    rsp,rbp
     1bc:	pop    rbp
     1bd:	ret
     1be:	mov    rdi,r13
     1c1:	mov    rax,QWORD PTR [rdi+0x10]
     1c5:	mov    rax,QWORD PTR [rax+0x8]
     1c9:	mov    rbx,QWORD PTR [rsp+0x20]
     1ce:	mov    r12,QWORD PTR [rsp+0x28]
     1d3:	mov    r13,QWORD PTR [rsp+0x30]
     1d8:	add    rsp,0x40
     1dc:	mov    rsp,rbp
     1df:	pop    rbp
     1e0:	ret
     1e1:	add    BYTE PTR [rax],al
     1e3:	add    BYTE PTR [rax],al
     1e5:	add    BYTE PTR [rax],al
     1e7:	add    BYTE PTR [rsi],al
     1e9:	add    BYTE PTR [rax],al
     1eb:	add    BYTE PTR [rax],al
     1ed:	add    BYTE PTR [rax],al
	...

00000000000001f0 <botlish_entry_1: peek<str, int>>:
     1f0:	push   rbp
     1f1:	mov    rbp,rsp
     1f4:	mov    rsi,QWORD PTR [rdx]
     1f7:	mov    rdx,QWORD PTR [rdx+0x8]
     1fb:	call   200 <botlish_entry_1+0x10>
			1fc: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     200:	mov    rsp,rbp
     203:	pop    rbp
     204:	ret
     205:	add    BYTE PTR [rax],al
	...

0000000000000208 <botlish_fn_2: peek<str, int>>:
     208:	push   rbp
     209:	mov    rbp,rsp
     20c:	sub    rsp,0x50
     210:	mov    QWORD PTR [rsp+0x20],rbx
     215:	mov    QWORD PTR [rsp+0x28],r12
     21a:	mov    QWORD PTR [rsp+0x30],r13
     21f:	mov    QWORD PTR [rsp+0x38],r14
     224:	mov    QWORD PTR [rsp+0x40],r15
     229:	mov    r12,rcx
     22c:	mov    r14,rdi
     22f:	mov    QWORD PTR [rsp],rsi
     233:	mov    r13,rsi
     236:	mov    QWORD PTR [rsp+0x8],rdx
     23b:	mov    rbx,rdx
     23e:	mov    rsi,r13
     241:	mov    rdi,r14
     244:	call   249 <botlish_fn_2+0x41>
			245: R_X86_64_PLT32	rt_str_len-0x4
     249:	mov    rcx,rbx
     24c:	and    rcx,rax
     24f:	mov    rdx,rax
     252:	test   rcx,0x1
     259:	jne    27f <botlish_fn_2+0x77>
     25f:	mov    rsi,rbx
     262:	mov    rdi,r14
     265:	call   26a <botlish_fn_2+0x62>
			266: R_X86_64_PLT32	rt_int_cmp-0x4
     26a:	mov    ecx,0x2
     26f:	test   rax,rax
     272:	cmovge rcx,QWORD PTR [rip+0x11e]        # 398 <botlish_fn_2+0x190>
     27a:	jmp    28f <botlish_fn_2+0x87>
     27f:	mov    ecx,0x2
     284:	cmp    rbx,rdx
     287:	cmovge rcx,QWORD PTR [rip+0x109]        # 398 <botlish_fn_2+0x190>
     28f:	cmp    rcx,0x6
     293:	je     353 <botlish_fn_2+0x14b>
     299:	mov    QWORD PTR [rsp+0x10],0x3
     2a2:	test   rbx,0x1
     2a9:	je     2cc <botlish_fn_2+0xc4>
     2af:	mov    rax,rbx
     2b2:	add    rax,0x2
     2b6:	seto   cl
     2b9:	test   cl,cl
     2bb:	jne    2cc <botlish_fn_2+0xc4>
     2c1:	mov    rdi,r14
     2c4:	mov    r15,rax
     2c7:	jmp    2e2 <botlish_fn_2+0xda>
     2cc:	mov    edx,0x3
     2d1:	mov    rsi,rbx
     2d4:	mov    rdi,r14
     2d7:	call   2dc <botlish_fn_2+0xd4>
			2d8: R_X86_64_PLT32	rt_int_add-0x4
     2dc:	mov    r15,rax
     2df:	mov    rdi,r14
     2e2:	mov    rdi,r14
     2e5:	mov    rcx,r15
     2e8:	mov    rdx,rbx
     2eb:	mov    rsi,r13
     2ee:	call   2f3 <botlish_fn_2+0xeb>
			2ef: R_X86_64_PLT32	rt_str_region_check-0x4
     2f3:	test   rax,rax
     2f6:	jne    321 <botlish_fn_2+0x119>
     2fc:	xor    rax,rax
     2ff:	mov    rbx,QWORD PTR [rsp+0x20]
     304:	mov    r12,QWORD PTR [rsp+0x28]
     309:	mov    r13,QWORD PTR [rsp+0x30]
     30e:	mov    r14,QWORD PTR [rsp+0x38]
     313:	mov    r15,QWORD PTR [rsp+0x40]
     318:	add    rsp,0x50
     31c:	mov    rsp,rbp
     31f:	pop    rbp
     320:	ret
     321:	mov    rcx,r12
     324:	mov    QWORD PTR [rcx],rbx
     327:	mov    rax,r15
     32a:	mov    QWORD PTR [rcx+0x8],rax
     32e:	mov    rax,r13
     331:	mov    rbx,QWORD PTR [rsp+0x20]
     336:	mov    r12,QWORD PTR [rsp+0x28]
     33b:	mov    r13,QWORD PTR [rsp+0x30]
     340:	mov    r14,QWORD PTR [rsp+0x38]
     345:	mov    r15,QWORD PTR [rsp+0x40]
     34a:	add    rsp,0x50
     34e:	mov    rsp,rbp
     351:	pop    rbp
     352:	ret
     353:	mov    rcx,r12
     356:	mov    rdi,r14
     359:	mov    rax,QWORD PTR [rdi+0x10]
     35d:	mov    rax,QWORD PTR [rax+0x8]
     361:	mov    QWORD PTR [rcx],0x1
     368:	mov    QWORD PTR [rcx+0x8],0x1
     370:	mov    rbx,QWORD PTR [rsp+0x20]
     375:	mov    r12,QWORD PTR [rsp+0x28]
     37a:	mov    r13,QWORD PTR [rsp+0x30]
     37f:	mov    r14,QWORD PTR [rsp+0x38]
     384:	mov    r15,QWORD PTR [rsp+0x40]
     389:	add    rsp,0x50
     38d:	mov    rsp,rbp
     390:	pop    rbp
     391:	ret
     392:	add    BYTE PTR [rax],al
     394:	add    BYTE PTR [rax],al
     396:	add    BYTE PTR [rax],al
     398:	(bad)
     399:	add    BYTE PTR [rax],al
     39b:	add    BYTE PTR [rax],al
     39d:	add    BYTE PTR [rax],al
	...

00000000000003a0 <botlish_entry_2: peek<str, int>>:
     3a0:	push   rbp
     3a1:	mov    rbp,rsp
     3a4:	ud2

00000000000003a6 <botlish_fn_3: scan_unquoted<str, int, int>>:
     3a6:	push   rbp
     3a7:	mov    rbp,rsp
     3aa:	sub    rsp,0x80
     3b1:	mov    QWORD PTR [rsp+0x50],rbx
     3b6:	mov    QWORD PTR [rsp+0x58],r12
     3bb:	mov    QWORD PTR [rsp+0x60],r13
     3c0:	mov    QWORD PTR [rsp+0x68],r14
     3c5:	mov    QWORD PTR [rsp+0x70],r15
     3ca:	mov    r14,QWORD PTR [rdi]
     3cd:	mov    rax,QWORD PTR [rdi+0x8]
     3d1:	lea    r8,[r14+0x8]
     3d5:	cmp    r8,rax
     3d8:	ja     600 <botlish_fn_3+0x25a>
     3de:	lea    rax,[r14+0x8]
     3e2:	mov    QWORD PTR [rdi],rax
     3e5:	mov    r15,rdi
     3e8:	mov    QWORD PTR [r14],0x0
     3ef:	mov    QWORD PTR [rsp+0x18],0x0
     3f8:	mov    QWORD PTR [rsp],rsi
     3fc:	mov    QWORD PTR [rsp+0x30],rsi
     401:	mov    QWORD PTR [rsp+0x8],rdx
     406:	mov    QWORD PTR [rsp+0x38],rdx
     40b:	mov    QWORD PTR [rsp+0x10],rcx
     410:	lea    rbx,[rsp+0x20]
     415:	mov    QWORD PTR [rsp+0x40],rcx
     41a:	mov    rcx,rbx
     41d:	mov    rdx,QWORD PTR [rsp+0x40]
     422:	mov    rsi,QWORD PTR [rsp+0x30]
     427:	mov    rdi,r15
     42a:	call   42f <botlish_fn_3+0x89>
			42b: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     42f:	mov    rcx,rax
     432:	mov    QWORD PTR [rsp+0x48],rax
     437:	test   rax,rcx
     43a:	jne    448 <botlish_fn_3+0xa2>
     440:	mov    rdi,r15
     443:	jmp    59f <botlish_fn_3+0x1f9>
     448:	mov    r12,QWORD PTR [rsp+0x20]
     44d:	mov    r13,QWORD PTR [rsp+0x28]
     452:	mov    rdi,r15
     455:	mov    rcx,QWORD PTR [rdi+0x10]
     459:	mov    r8,QWORD PTR [rcx+0x8]
     45d:	mov    rcx,r13
     460:	mov    rdx,r12
     463:	mov    rsi,QWORD PTR [rsp+0x48]
     468:	call   46d <botlish_fn_3+0xc7>
			469: R_X86_64_PLT32	rt_str_region_eq-0x4
     46d:	cmp    rax,0x6
     471:	je     4b0 <botlish_fn_3+0x10a>
     477:	mov    rdi,r15
     47a:	mov    rax,QWORD PTR [rdi+0x10]
     47e:	mov    r8,QWORD PTR [rax+0x10]
     482:	mov    rcx,r13
     485:	mov    rdx,r12
     488:	mov    rsi,QWORD PTR [rsp+0x48]
     48d:	call   492 <botlish_fn_3+0xec>
			48e: R_X86_64_PLT32	rt_str_region_eq-0x4
     492:	cmp    rax,0x6
     496:	je     4a6 <botlish_fn_3+0x100>
     49c:	mov    eax,0x2
     4a1:	jmp    4b5 <botlish_fn_3+0x10f>
     4a6:	mov    eax,0x6
     4ab:	jmp    4b5 <botlish_fn_3+0x10f>
     4b0:	mov    eax,0x6
     4b5:	cmp    rax,0x6
     4b9:	je     4f8 <botlish_fn_3+0x152>
     4bf:	mov    rdi,r15
     4c2:	mov    rdx,QWORD PTR [rdi+0x10]
     4c6:	mov    r8,QWORD PTR [rdx+0x18]
     4ca:	mov    rcx,r13
     4cd:	mov    rdx,r12
     4d0:	mov    rsi,QWORD PTR [rsp+0x48]
     4d5:	call   4da <botlish_fn_3+0x134>
			4d6: R_X86_64_PLT32	rt_str_region_eq-0x4
     4da:	cmp    rax,0x6
     4de:	je     4ee <botlish_fn_3+0x148>
     4e4:	mov    eax,0x2
     4e9:	jmp    4fd <botlish_fn_3+0x157>
     4ee:	mov    eax,0x6
     4f3:	jmp    4fd <botlish_fn_3+0x157>
     4f8:	mov    eax,0x6
     4fd:	cmp    rax,0x6
     501:	je     57c <botlish_fn_3+0x1d6>
     507:	mov    QWORD PTR [rsp+0x18],0x3
     510:	mov    rsi,QWORD PTR [rsp+0x40]
     515:	test   rsi,0x1
     51c:	je     543 <botlish_fn_3+0x19d>
     522:	mov    rsi,QWORD PTR [rsp+0x40]
     527:	mov    rax,rsi
     52a:	add    rax,0x2
     52e:	seto   cl
     531:	test   cl,cl
     533:	jne    543 <botlish_fn_3+0x19d>
     539:	mov    rsi,QWORD PTR [rsp+0x30]
     53e:	jmp    55a <botlish_fn_3+0x1b4>
     543:	mov    edx,0x3
     548:	mov    rsi,QWORD PTR [rsp+0x40]
     54d:	mov    rdi,r15
     550:	call   555 <botlish_fn_3+0x1af>
			551: R_X86_64_PLT32	rt_int_add-0x4
     555:	mov    rsi,QWORD PTR [rsp+0x30]
     55a:	mov    QWORD PTR [rsp],rsi
     55e:	mov    rdx,QWORD PTR [rsp+0x38]
     563:	mov    QWORD PTR [rsp+0x8],rdx
     568:	mov    QWORD PTR [rsp+0x10],rax
     56d:	mov    QWORD PTR [rsp+0x30],rsi
     572:	mov    QWORD PTR [rsp+0x40],rax
     577:	jmp    41a <botlish_fn_3+0x74>
     57c:	mov    rdx,QWORD PTR [rsp+0x38]
     581:	mov    rsi,QWORD PTR [rsp+0x30]
     586:	mov    rcx,QWORD PTR [rsp+0x40]
     58b:	mov    rdi,r15
     58e:	call   593 <botlish_fn_3+0x1ed>
			58f: R_X86_64_PLT32	rt_substr-0x4
     593:	test   rax,rax
     596:	jne    5d0 <botlish_fn_3+0x22a>
     59c:	mov    rdi,r15
     59f:	mov    rdi,r15
     5a2:	mov    QWORD PTR [rdi],r14
     5a5:	xor    rdx,rdx
     5a8:	mov    rax,rdx
     5ab:	mov    rbx,QWORD PTR [rsp+0x50]
     5b0:	mov    r12,QWORD PTR [rsp+0x58]
     5b5:	mov    r13,QWORD PTR [rsp+0x60]
     5ba:	mov    r14,QWORD PTR [rsp+0x68]
     5bf:	mov    r15,QWORD PTR [rsp+0x70]
     5c4:	add    rsp,0x80
     5cb:	mov    rsp,rbp
     5ce:	pop    rbp
     5cf:	ret
     5d0:	mov    rdi,r15
     5d3:	mov    QWORD PTR [rdi],r14
     5d6:	mov    rdx,QWORD PTR [rsp+0x40]
     5db:	mov    rbx,QWORD PTR [rsp+0x50]
     5e0:	mov    r12,QWORD PTR [rsp+0x58]
     5e5:	mov    r13,QWORD PTR [rsp+0x60]
     5ea:	mov    r14,QWORD PTR [rsp+0x68]
     5ef:	mov    r15,QWORD PTR [rsp+0x70]
     5f4:	add    rsp,0x80
     5fb:	mov    rsp,rbp
     5fe:	pop    rbp
     5ff:	ret
     600:	mov    r15,rdi
     603:	call   608 <botlish_fn_3+0x262>
			604: R_X86_64_PLT32	rt_stack_overflow-0x4
     608:	xor    rdx,rdx
     60b:	mov    rax,rdx
     60e:	mov    rbx,QWORD PTR [rsp+0x50]
     613:	mov    r12,QWORD PTR [rsp+0x58]
     618:	mov    r13,QWORD PTR [rsp+0x60]
     61d:	mov    r14,QWORD PTR [rsp+0x68]
     622:	mov    r15,QWORD PTR [rsp+0x70]
     627:	add    rsp,0x80
     62e:	mov    rsp,rbp
     631:	pop    rbp
     632:	ret

0000000000000633 <botlish_entry_3: scan_unquoted<str, int, int>>:
     633:	push   rbp
     634:	mov    rbp,rsp
     637:	ud2

0000000000000639 <botlish_fn_4: scan_quoted<str, int, str>>:
     639:	push   rbp
     63a:	mov    rbp,rsp
     63d:	sub    rsp,0x80
     644:	mov    QWORD PTR [rsp+0x50],rbx
     649:	mov    QWORD PTR [rsp+0x58],r12
     64e:	mov    QWORD PTR [rsp+0x60],r13
     653:	mov    QWORD PTR [rsp+0x68],r14
     658:	mov    QWORD PTR [rsp+0x70],r15
     65d:	mov    r13,QWORD PTR [rdi]
     660:	mov    rax,QWORD PTR [rdi+0x8]
     664:	lea    r8,[r13+0x8]
     668:	cmp    r8,rax
     66b:	ja     95d <botlish_fn_4+0x324>
     671:	lea    rax,[r13+0x8]
     675:	mov    QWORD PTR [rdi],rax
     678:	mov    r14,rdi
     67b:	mov    QWORD PTR [r13+0x0],0x0
     683:	mov    QWORD PTR [rsp+0x18],0x0
     68c:	mov    QWORD PTR [rsp+0x20],0x0
     695:	mov    QWORD PTR [rsp],rsi
     699:	mov    QWORD PTR [rsp+0x8],rdx
     69e:	mov    QWORD PTR [rsp+0x10],rcx
     6a3:	lea    rbx,[rsp+0x28]
     6a8:	mov    r12,rsi
     6ab:	mov    r15,rdx
     6ae:	mov    QWORD PTR [rsp+0x38],rcx
     6b3:	mov    rdx,r15
     6b6:	mov    rsi,r12
     6b9:	mov    rdi,r14
     6bc:	call   6c1 <botlish_fn_4+0x88>
			6bd: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     6c1:	test   rax,rax
     6c4:	jne    6d2 <botlish_fn_4+0x99>
     6ca:	mov    rdi,r14
     6cd:	jmp    911 <botlish_fn_4+0x2d8>
     6d2:	mov    QWORD PTR [rsp+0x18],rax
     6d7:	mov    rdi,r14
     6da:	mov    QWORD PTR [rsp+0x40],rax
     6df:	mov    rsi,QWORD PTR [rdi+0x10]
     6e3:	mov    rsi,QWORD PTR [rsi+0x20]
     6e7:	mov    edx,0x1
     6ec:	mov    ecx,0x3
     6f1:	mov    r8,QWORD PTR [rsp+0x40]
     6f6:	call   6fb <botlish_fn_4+0xc2>
			6f7: R_X86_64_PLT32	rt_str_region_eq-0x4
     6fb:	cmp    rax,0x6
     6ff:	je     790 <botlish_fn_4+0x157>
     705:	mov    QWORD PTR [rsp+0x20],0x3
     70e:	mov    rsi,r15
     711:	test   rsi,0x1
     718:	je     73a <botlish_fn_4+0x101>
     71e:	mov    r9,rsi
     721:	add    r9,0x2
     725:	seto   r11b
     729:	test   r11b,r11b
     72c:	jne    73a <botlish_fn_4+0x101>
     732:	mov    rsi,r9
     735:	jmp    74a <botlish_fn_4+0x111>
     73a:	mov    edx,0x3
     73f:	mov    rdi,r14
     742:	call   747 <botlish_fn_4+0x10e>
			743: R_X86_64_PLT32	rt_int_add-0x4
     747:	mov    rsi,rax
     74a:	mov    QWORD PTR [rsp+0x8],rsi
     74f:	mov    r15,rsi
     752:	mov    rsi,QWORD PTR [rsp+0x38]
     757:	mov    rdx,QWORD PTR [rsp+0x40]
     75c:	mov    rdi,r14
     75f:	call   764 <botlish_fn_4+0x12b>
			760: R_X86_64_PLT32	rt_str_cat-0x4
     764:	test   rax,rax
     767:	jne    775 <botlish_fn_4+0x13c>
     76d:	mov    rdi,r14
     770:	jmp    911 <botlish_fn_4+0x2d8>
     775:	mov    QWORD PTR [rsp],r12
     779:	mov    rsi,r15
     77c:	mov    QWORD PTR [rsp+0x8],rsi
     781:	mov    QWORD PTR [rsp+0x10],rax
     786:	mov    QWORD PTR [rsp+0x38],rax
     78b:	jmp    6b3 <botlish_fn_4+0x7a>
     790:	mov    QWORD PTR [rsp+0x18],0x3
     799:	mov    rsi,r15
     79c:	test   rsi,0x1
     7a3:	je     7be <botlish_fn_4+0x185>
     7a9:	mov    rsi,r15
     7ac:	mov    rdx,rsi
     7af:	add    rdx,0x2
     7b3:	seto   al
     7b6:	test   al,al
     7b8:	je     7d1 <botlish_fn_4+0x198>
     7be:	mov    edx,0x3
     7c3:	mov    rsi,r15
     7c6:	mov    rdi,r14
     7c9:	call   7ce <botlish_fn_4+0x195>
			7ca: R_X86_64_PLT32	rt_int_add-0x4
     7ce:	mov    rdx,rax
     7d1:	mov    QWORD PTR [rsp+0x18],rdx
     7d6:	mov    rcx,rbx
     7d9:	mov    rsi,r12
     7dc:	mov    rdi,r14
     7df:	call   7e4 <botlish_fn_4+0x1ab>
			7e0: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     7e4:	test   rax,rax
     7e7:	mov    rsi,rax
     7ea:	jne    7f8 <botlish_fn_4+0x1bf>
     7f0:	mov    rdi,r14
     7f3:	jmp    911 <botlish_fn_4+0x2d8>
     7f8:	mov    rdx,QWORD PTR [rsp+0x28]
     7fd:	mov    rcx,QWORD PTR [rsp+0x30]
     802:	mov    rdi,r14
     805:	mov    rax,QWORD PTR [rdi+0x10]
     809:	mov    r8,QWORD PTR [rax+0x20]
     80d:	call   812 <botlish_fn_4+0x1d9>
			80e: R_X86_64_PLT32	rt_str_region_eq-0x4
     812:	cmp    rax,0x6
     816:	je     897 <botlish_fn_4+0x25e>
     81c:	mov    QWORD PTR [rsp],0x3
     824:	mov    rsi,r15
     827:	test   rsi,0x1
     82e:	je     851 <botlish_fn_4+0x218>
     834:	mov    rsi,r15
     837:	mov    rdx,rsi
     83a:	add    rdx,0x2
     83e:	seto   al
     841:	test   al,al
     843:	jne    851 <botlish_fn_4+0x218>
     849:	mov    rdi,r14
     84c:	jmp    867 <botlish_fn_4+0x22e>
     851:	mov    edx,0x3
     856:	mov    rsi,r15
     859:	mov    rdi,r14
     85c:	call   861 <botlish_fn_4+0x228>
			85d: R_X86_64_PLT32	rt_int_add-0x4
     861:	mov    rdx,rax
     864:	mov    rdi,r14
     867:	mov    rdi,r14
     86a:	mov    QWORD PTR [rdi],r13
     86d:	mov    rax,QWORD PTR [rsp+0x38]
     872:	mov    rbx,QWORD PTR [rsp+0x50]
     877:	mov    r12,QWORD PTR [rsp+0x58]
     87c:	mov    r13,QWORD PTR [rsp+0x60]
     881:	mov    r14,QWORD PTR [rsp+0x68]
     886:	mov    r15,QWORD PTR [rsp+0x70]
     88b:	add    rsp,0x80
     892:	mov    rsp,rbp
     895:	pop    rbp
     896:	ret
     897:	mov    QWORD PTR [rsp+0x18],0x5
     8a0:	mov    rsi,r15
     8a3:	test   rsi,0x1
     8aa:	je     8d0 <botlish_fn_4+0x297>
     8b0:	mov    rsi,r15
     8b3:	mov    rax,rsi
     8b6:	add    rax,0x4
     8ba:	seto   cl
     8bd:	test   cl,cl
     8bf:	jne    8d0 <botlish_fn_4+0x297>
     8c5:	mov    rsi,rax
     8c8:	mov    r15,rax
     8cb:	jmp    8e6 <botlish_fn_4+0x2ad>
     8d0:	mov    edx,0x5
     8d5:	mov    rsi,r15
     8d8:	mov    rdi,r14
     8db:	call   8e0 <botlish_fn_4+0x2a7>
			8dc: R_X86_64_PLT32	rt_int_add-0x4
     8e0:	mov    rsi,rax
     8e3:	mov    r15,rax
     8e6:	mov    QWORD PTR [rsp+0x8],rsi
     8eb:	mov    rdi,r14
     8ee:	mov    rax,QWORD PTR [rdi+0x10]
     8f2:	mov    rdx,QWORD PTR [rax+0x20]
     8f6:	mov    QWORD PTR [rsp+0x18],rdx
     8fb:	mov    rsi,QWORD PTR [rsp+0x38]
     900:	call   905 <botlish_fn_4+0x2cc>
			901: R_X86_64_PLT32	rt_str_cat-0x4
     905:	test   rax,rax
     908:	jne    942 <botlish_fn_4+0x309>
     90e:	mov    rdi,r14
     911:	mov    rdi,r14
     914:	mov    QWORD PTR [rdi],r13
     917:	xor    rdx,rdx
     91a:	mov    rax,rdx
     91d:	mov    rbx,QWORD PTR [rsp+0x50]
     922:	mov    r12,QWORD PTR [rsp+0x58]
     927:	mov    r13,QWORD PTR [rsp+0x60]
     92c:	mov    r14,QWORD PTR [rsp+0x68]
     931:	mov    r15,QWORD PTR [rsp+0x70]
     936:	add    rsp,0x80
     93d:	mov    rsp,rbp
     940:	pop    rbp
     941:	ret
     942:	mov    QWORD PTR [rsp],r12
     946:	mov    rsi,r15
     949:	mov    QWORD PTR [rsp+0x8],rsi
     94e:	mov    QWORD PTR [rsp+0x10],rax
     953:	mov    QWORD PTR [rsp+0x38],rax
     958:	jmp    6b3 <botlish_fn_4+0x7a>
     95d:	mov    r14,rdi
     960:	call   965 <botlish_fn_4+0x32c>
			961: R_X86_64_PLT32	rt_stack_overflow-0x4
     965:	xor    rdx,rdx
     968:	mov    rax,rdx
     96b:	mov    rbx,QWORD PTR [rsp+0x50]
     970:	mov    r12,QWORD PTR [rsp+0x58]
     975:	mov    r13,QWORD PTR [rsp+0x60]
     97a:	mov    r14,QWORD PTR [rsp+0x68]
     97f:	mov    r15,QWORD PTR [rsp+0x70]
     984:	add    rsp,0x80
     98b:	mov    rsp,rbp
     98e:	pop    rbp
     98f:	ret

0000000000000990 <botlish_entry_4: scan_quoted<str, int, str>>:
     990:	push   rbp
     991:	mov    rbp,rsp
     994:	ud2

0000000000000996 <botlish_fn_5: scan_field<str, int>>:
     996:	push   rbp
     997:	mov    rbp,rsp
     99a:	sub    rsp,0x50
     99e:	mov    QWORD PTR [rsp+0x30],rbx
     9a3:	mov    QWORD PTR [rsp+0x38],r12
     9a8:	mov    QWORD PTR [rsp+0x40],r13
     9ad:	mov    QWORD PTR [rsp+0x48],r14
     9b2:	mov    rbx,QWORD PTR [rdi]
     9b5:	mov    rax,QWORD PTR [rdi+0x8]
     9b9:	lea    rcx,[rbx+0x8]
     9bd:	cmp    rcx,rax
     9c0:	ja     b32 <botlish_fn_5+0x19c>
     9c6:	lea    rax,[rbx+0x8]
     9ca:	mov    QWORD PTR [rdi],rax
     9cd:	mov    r12,rdi
     9d0:	mov    QWORD PTR [rbx],0x0
     9d7:	mov    QWORD PTR [rsp+0x10],0x0
     9e0:	mov    QWORD PTR [rsp],rsi
     9e4:	mov    r13,rsi
     9e7:	mov    QWORD PTR [rsp+0x8],rdx
     9ec:	mov    r14,rdx
     9ef:	lea    rcx,[rsp+0x18]
     9f4:	mov    rdx,r14
     9f7:	mov    rsi,r13
     9fa:	mov    rdi,r12
     9fd:	call   a02 <botlish_fn_5+0x6c>
			9fe: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     a02:	test   rax,rax
     a05:	mov    rsi,rax
     a08:	jne    a16 <botlish_fn_5+0x80>
     a0e:	mov    rdi,r12
     a11:	jmp    ae6 <botlish_fn_5+0x150>
     a16:	mov    rdx,QWORD PTR [rsp+0x18]
     a1b:	mov    rcx,QWORD PTR [rsp+0x20]
     a20:	mov    rdi,r12
     a23:	mov    rax,QWORD PTR [rdi+0x10]
     a27:	mov    r8,QWORD PTR [rax+0x20]
     a2b:	call   a30 <botlish_fn_5+0x9a>
			a2c: R_X86_64_PLT32	rt_str_region_eq-0x4
     a30:	cmp    rax,0x6
     a34:	je     a7f <botlish_fn_5+0xe9>
     a3a:	mov    rcx,r14
     a3d:	mov    rsi,r13
     a40:	mov    rdi,r12
     a43:	mov    rdx,rcx
     a46:	call   a4b <botlish_fn_5+0xb5>
			a47: R_X86_64_PLT32	botlish_fn_3-0x4 ; scan_unquoted<str, int, int>
     a4b:	test   rax,rax
     a4e:	jne    a5c <botlish_fn_5+0xc6>
     a54:	mov    rdi,r12
     a57:	jmp    ae6 <botlish_fn_5+0x150>
     a5c:	mov    rdi,r12
     a5f:	mov    QWORD PTR [rdi],rbx
     a62:	mov    rbx,QWORD PTR [rsp+0x30]
     a67:	mov    r12,QWORD PTR [rsp+0x38]
     a6c:	mov    r13,QWORD PTR [rsp+0x40]
     a71:	mov    r14,QWORD PTR [rsp+0x48]
     a76:	add    rsp,0x50
     a7a:	mov    rsp,rbp
     a7d:	pop    rbp
     a7e:	ret
     a7f:	mov    QWORD PTR [rsp+0x10],0x3
     a88:	mov    rdx,r14
     a8b:	test   rdx,0x1
     a92:	je     aaa <botlish_fn_5+0x114>
     a98:	mov    rdx,r14
     a9b:	add    rdx,0x2
     a9f:	seto   al
     aa2:	test   al,al
     aa4:	je     abd <botlish_fn_5+0x127>
     aaa:	mov    edx,0x3
     aaf:	mov    rsi,r14
     ab2:	mov    rdi,r12
     ab5:	call   aba <botlish_fn_5+0x124>
			ab6: R_X86_64_PLT32	rt_int_add-0x4
     aba:	mov    rdx,rax
     abd:	mov    QWORD PTR [rsp+0x8],rdx
     ac2:	mov    rdi,r12
     ac5:	mov    rax,QWORD PTR [rdi+0x10]
     ac9:	mov    rcx,QWORD PTR [rax+0x8]
     acd:	mov    QWORD PTR [rsp+0x10],rcx
     ad2:	mov    rsi,r13
     ad5:	call   ada <botlish_fn_5+0x144>
			ad6: R_X86_64_PLT32	botlish_fn_4-0x4 ; scan_quoted<str, int, str>
     ada:	test   rax,rax
     add:	jne    b0f <botlish_fn_5+0x179>
     ae3:	mov    rdi,r12
     ae6:	mov    rdi,r12
     ae9:	mov    QWORD PTR [rdi],rbx
     aec:	xor    rdx,rdx
     aef:	mov    rax,rdx
     af2:	mov    rbx,QWORD PTR [rsp+0x30]
     af7:	mov    r12,QWORD PTR [rsp+0x38]
     afc:	mov    r13,QWORD PTR [rsp+0x40]
     b01:	mov    r14,QWORD PTR [rsp+0x48]
     b06:	add    rsp,0x50
     b0a:	mov    rsp,rbp
     b0d:	pop    rbp
     b0e:	ret
     b0f:	mov    rdi,r12
     b12:	mov    QWORD PTR [rdi],rbx
     b15:	mov    rbx,QWORD PTR [rsp+0x30]
     b1a:	mov    r12,QWORD PTR [rsp+0x38]
     b1f:	mov    r13,QWORD PTR [rsp+0x40]
     b24:	mov    r14,QWORD PTR [rsp+0x48]
     b29:	add    rsp,0x50
     b2d:	mov    rsp,rbp
     b30:	pop    rbp
     b31:	ret
     b32:	mov    r12,rdi
     b35:	call   b3a <botlish_fn_5+0x1a4>
			b36: R_X86_64_PLT32	rt_stack_overflow-0x4
     b3a:	xor    rdx,rdx
     b3d:	mov    rax,rdx
     b40:	mov    rbx,QWORD PTR [rsp+0x30]
     b45:	mov    r12,QWORD PTR [rsp+0x38]
     b4a:	mov    r13,QWORD PTR [rsp+0x40]
     b4f:	mov    r14,QWORD PTR [rsp+0x48]
     b54:	add    rsp,0x50
     b58:	mov    rsp,rbp
     b5b:	pop    rbp
     b5c:	ret

0000000000000b5d <botlish_entry_5: scan_field<str, int>>:
     b5d:	push   rbp
     b5e:	mov    rbp,rsp
     b61:	ud2

0000000000000b63 <botlish_fn_6: scan_record<str, int, list<never>>>:
     b63:	push   rbp
     b64:	mov    rbp,rsp
     b67:	sub    rsp,0x80
     b6e:	mov    QWORD PTR [rsp+0x50],rbx
     b73:	mov    QWORD PTR [rsp+0x58],r12
     b78:	mov    QWORD PTR [rsp+0x60],r13
     b7d:	mov    QWORD PTR [rsp+0x68],r14
     b82:	mov    QWORD PTR [rsp+0x70],r15
     b87:	mov    rbx,QWORD PTR [rdi]
     b8a:	mov    rax,QWORD PTR [rdi+0x8]
     b8e:	lea    r8,[rbx+0x8]
     b92:	cmp    r8,rax
     b95:	ja     e1c <botlish_fn_6+0x2b9>
     b9b:	lea    rax,[rbx+0x8]
     b9f:	mov    QWORD PTR [rdi],rax
     ba2:	mov    r14,rdi
     ba5:	mov    QWORD PTR [rbx],0x0
     bac:	mov    QWORD PTR [rsp+0x18],0x0
     bb5:	mov    QWORD PTR [rsp],rsi
     bb9:	mov    QWORD PTR [rsp+0x30],rsi
     bbe:	mov    QWORD PTR [rsp+0x8],rdx
     bc3:	mov    QWORD PTR [rsp+0x10],rcx
     bc8:	mov    r12,rcx
     bcb:	mov    rsi,QWORD PTR [rsp+0x30]
     bd0:	mov    rdi,r14
     bd3:	call   bd8 <botlish_fn_6+0x75>
			bd4: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     bd8:	test   rax,rax
     bdb:	jne    be9 <botlish_fn_6+0x86>
     be1:	mov    rdi,r14
     be4:	jmp    dc0 <botlish_fn_6+0x25d>
     be9:	mov    QWORD PTR [rsp+0x8],rax
     bee:	mov    rdi,rax
     bf1:	mov    QWORD PTR [rsp+0x18],rdx
     bf6:	mov    QWORD PTR [rsp+0x40],rdx
     bfb:	mov    rsi,r12
     bfe:	mov    rdx,rdi
     c01:	mov    rdi,r14
     c04:	call   c09 <botlish_fn_6+0xa6>
			c05: R_X86_64_PLT32	rt_list_append-0x4
     c09:	test   rax,rax
     c0c:	jne    c1a <botlish_fn_6+0xb7>
     c12:	mov    rdi,r14
     c15:	jmp    dc0 <botlish_fn_6+0x25d>
     c1a:	mov    QWORD PTR [rsp+0x8],rax
     c1f:	mov    r15,rax
     c22:	lea    rcx,[rsp+0x20]
     c27:	mov    rdx,QWORD PTR [rsp+0x40]
     c2c:	mov    rsi,QWORD PTR [rsp+0x30]
     c31:	mov    rdi,r14
     c34:	call   c39 <botlish_fn_6+0xd6>
			c35: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     c39:	test   rax,rax
     c3c:	mov    QWORD PTR [rsp+0x38],rax
     c41:	jne    c4f <botlish_fn_6+0xec>
     c47:	mov    rdi,r14
     c4a:	jmp    dc0 <botlish_fn_6+0x25d>
     c4f:	mov    r12,QWORD PTR [rsp+0x20]
     c54:	mov    r13,QWORD PTR [rsp+0x28]
     c59:	mov    rdi,r14
     c5c:	mov    rcx,QWORD PTR [rdi+0x10]
     c60:	mov    r8,QWORD PTR [rcx+0x10]
     c64:	mov    rcx,r13
     c67:	mov    rdx,r12
     c6a:	mov    rsi,QWORD PTR [rsp+0x38]
     c6f:	call   c74 <botlish_fn_6+0x111>
			c70: R_X86_64_PLT32	rt_str_region_eq-0x4
     c74:	cmp    rax,0x6
     c78:	je     d54 <botlish_fn_6+0x1f1>
     c7e:	mov    rdi,r14
     c81:	mov    rax,QWORD PTR [rdi+0x10]
     c85:	mov    r8,QWORD PTR [rax+0x18]
     c89:	mov    rcx,r13
     c8c:	mov    rdx,r12
     c8f:	mov    rsi,QWORD PTR [rsp+0x38]
     c94:	call   c99 <botlish_fn_6+0x136>
			c95: R_X86_64_PLT32	rt_str_region_eq-0x4
     c99:	cmp    rax,0x6
     c9d:	je     cd6 <botlish_fn_6+0x173>
     ca3:	mov    rdi,r14
     ca6:	mov    QWORD PTR [rdi],rbx
     ca9:	mov    rax,r15
     cac:	mov    rdx,QWORD PTR [rsp+0x40]
     cb1:	mov    rbx,QWORD PTR [rsp+0x50]
     cb6:	mov    r12,QWORD PTR [rsp+0x58]
     cbb:	mov    r13,QWORD PTR [rsp+0x60]
     cc0:	mov    r14,QWORD PTR [rsp+0x68]
     cc5:	mov    r15,QWORD PTR [rsp+0x70]
     cca:	add    rsp,0x80
     cd1:	mov    rsp,rbp
     cd4:	pop    rbp
     cd5:	ret
     cd6:	mov    QWORD PTR [rsp],0x3
     cde:	mov    rdx,QWORD PTR [rsp+0x40]
     ce3:	test   rdx,0x1
     cea:	je     d0e <botlish_fn_6+0x1ab>
     cf0:	mov    rdx,QWORD PTR [rsp+0x40]
     cf5:	add    rdx,0x2
     cf9:	seto   r8b
     cfd:	test   r8b,r8b
     d00:	jne    d0e <botlish_fn_6+0x1ab>
     d06:	mov    rdi,r14
     d09:	jmp    d26 <botlish_fn_6+0x1c3>
     d0e:	mov    edx,0x3
     d13:	mov    rsi,QWORD PTR [rsp+0x40]
     d18:	mov    rdi,r14
     d1b:	call   d20 <botlish_fn_6+0x1bd>
			d1c: R_X86_64_PLT32	rt_int_add-0x4
     d20:	mov    rdx,rax
     d23:	mov    rdi,r14
     d26:	mov    rdi,r14
     d29:	mov    QWORD PTR [rdi],rbx
     d2c:	mov    rax,r15
     d2f:	mov    rbx,QWORD PTR [rsp+0x50]
     d34:	mov    r12,QWORD PTR [rsp+0x58]
     d39:	mov    r13,QWORD PTR [rsp+0x60]
     d3e:	mov    r14,QWORD PTR [rsp+0x68]
     d43:	mov    r15,QWORD PTR [rsp+0x70]
     d48:	add    rsp,0x80
     d4f:	mov    rsp,rbp
     d52:	pop    rbp
     d53:	ret
     d54:	mov    rsi,QWORD PTR [rsp+0x40]
     d59:	mov    edx,0x3
     d5e:	mov    rdi,rdx
     d61:	mov    QWORD PTR [rsp+0x10],0x3
     d6a:	test   rsi,0x1
     d71:	jne    d7f <botlish_fn_6+0x21c>
     d77:	mov    rdx,rdi
     d7a:	jmp    d94 <botlish_fn_6+0x231>
     d7f:	mov    rdx,rsi
     d82:	add    rdx,0x2
     d86:	seto   al
     d89:	test   al,al
     d8b:	je     d9f <botlish_fn_6+0x23c>
     d91:	mov    rdx,rdi
     d94:	mov    rdi,r14
     d97:	call   d9c <botlish_fn_6+0x239>
			d98: R_X86_64_PLT32	rt_int_add-0x4
     d9c:	mov    rdx,rax
     d9f:	mov    QWORD PTR [rsp+0x10],rdx
     da4:	mov    rcx,r15
     da7:	mov    rsi,QWORD PTR [rsp+0x30]
     dac:	mov    rdi,r14
     daf:	call   db4 <botlish_fn_6+0x251>
			db0: R_X86_64_PLT32	botlish_fn_7-0x4 ; scan_record<str, int, list<str>>
     db4:	test   rax,rax
     db7:	jne    df1 <botlish_fn_6+0x28e>
     dbd:	mov    rdi,r14
     dc0:	mov    rdi,r14
     dc3:	mov    QWORD PTR [rdi],rbx
     dc6:	xor    rdx,rdx
     dc9:	mov    rax,rdx
     dcc:	mov    rbx,QWORD PTR [rsp+0x50]
     dd1:	mov    r12,QWORD PTR [rsp+0x58]
     dd6:	mov    r13,QWORD PTR [rsp+0x60]
     ddb:	mov    r14,QWORD PTR [rsp+0x68]
     de0:	mov    r15,QWORD PTR [rsp+0x70]
     de5:	add    rsp,0x80
     dec:	mov    rsp,rbp
     def:	pop    rbp
     df0:	ret
     df1:	mov    rdi,r14
     df4:	mov    QWORD PTR [rdi],rbx
     df7:	mov    rbx,QWORD PTR [rsp+0x50]
     dfc:	mov    r12,QWORD PTR [rsp+0x58]
     e01:	mov    r13,QWORD PTR [rsp+0x60]
     e06:	mov    r14,QWORD PTR [rsp+0x68]
     e0b:	mov    r15,QWORD PTR [rsp+0x70]
     e10:	add    rsp,0x80
     e17:	mov    rsp,rbp
     e1a:	pop    rbp
     e1b:	ret
     e1c:	mov    r14,rdi
     e1f:	call   e24 <botlish_fn_6+0x2c1>
			e20: R_X86_64_PLT32	rt_stack_overflow-0x4
     e24:	xor    rdx,rdx
     e27:	mov    rax,rdx
     e2a:	mov    rbx,QWORD PTR [rsp+0x50]
     e2f:	mov    r12,QWORD PTR [rsp+0x58]
     e34:	mov    r13,QWORD PTR [rsp+0x60]
     e39:	mov    r14,QWORD PTR [rsp+0x68]
     e3e:	mov    r15,QWORD PTR [rsp+0x70]
     e43:	add    rsp,0x80
     e4a:	mov    rsp,rbp
     e4d:	pop    rbp
     e4e:	ret

0000000000000e4f <botlish_entry_6: scan_record<str, int, list<never>>>:
     e4f:	push   rbp
     e50:	mov    rbp,rsp
     e53:	ud2

0000000000000e55 <botlish_fn_7: scan_record<str, int, list<str>>>:
     e55:	push   rbp
     e56:	mov    rbp,rsp
     e59:	sub    rsp,0x80
     e60:	mov    QWORD PTR [rsp+0x50],rbx
     e65:	mov    QWORD PTR [rsp+0x58],r12
     e6a:	mov    QWORD PTR [rsp+0x60],r13
     e6f:	mov    QWORD PTR [rsp+0x68],r14
     e74:	mov    QWORD PTR [rsp+0x70],r15
     e79:	mov    rbx,QWORD PTR [rdi]
     e7c:	mov    rax,QWORD PTR [rdi+0x8]
     e80:	lea    r8,[rbx+0x8]
     e84:	cmp    r8,rax
     e87:	ja     10fd <botlish_fn_7+0x2a8>
     e8d:	lea    rax,[rbx+0x8]
     e91:	mov    QWORD PTR [rdi],rax
     e94:	mov    QWORD PTR [rsp+0x30],rdi
     e99:	mov    QWORD PTR [rbx],0x0
     ea0:	mov    QWORD PTR [rsp+0x18],0x0
     ea9:	mov    QWORD PTR [rsp],rsi
     ead:	mov    QWORD PTR [rsp+0x8],rdx
     eb2:	mov    QWORD PTR [rsp+0x10],rcx
     eb7:	lea    r12,[rsp+0x20]
     ebc:	mov    r13,rsi
     ebf:	mov    r14,rcx
     ec2:	mov    rsi,r13
     ec5:	mov    rdi,QWORD PTR [rsp+0x30]
     eca:	call   ecf <botlish_fn_7+0x7a>
			ecb: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     ecf:	test   rax,rax
     ed2:	jne    ee2 <botlish_fn_7+0x8d>
     ed8:	mov    rdi,QWORD PTR [rsp+0x30]
     edd:	jmp    f49 <botlish_fn_7+0xf4>
     ee2:	mov    QWORD PTR [rsp+0x8],rax
     ee7:	mov    rsi,rax
     eea:	mov    QWORD PTR [rsp+0x18],rdx
     eef:	mov    QWORD PTR [rsp+0x48],rdx
     ef4:	mov    rdx,rsi
     ef7:	mov    rsi,r14
     efa:	mov    rdi,QWORD PTR [rsp+0x30]
     eff:	call   f04 <botlish_fn_7+0xaf>
			f00: R_X86_64_PLT32	rt_list_append-0x4
     f04:	test   rax,rax
     f07:	jne    f17 <botlish_fn_7+0xc2>
     f0d:	mov    rdi,QWORD PTR [rsp+0x30]
     f12:	jmp    f49 <botlish_fn_7+0xf4>
     f17:	mov    QWORD PTR [rsp+0x8],rax
     f1c:	mov    QWORD PTR [rsp+0x40],rax
     f21:	mov    rcx,r12
     f24:	mov    rdx,QWORD PTR [rsp+0x48]
     f29:	mov    rsi,r13
     f2c:	mov    rdi,QWORD PTR [rsp+0x30]
     f31:	call   f36 <botlish_fn_7+0xe1>
			f32: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     f36:	test   rax,rax
     f39:	mov    QWORD PTR [rsp+0x38],rax
     f3e:	jne    f7c <botlish_fn_7+0x127>
     f44:	mov    rdi,QWORD PTR [rsp+0x30]
     f49:	mov    rdi,QWORD PTR [rsp+0x30]
     f4e:	mov    QWORD PTR [rdi],rbx
     f51:	xor    rdx,rdx
     f54:	mov    rax,rdx
     f57:	mov    rbx,QWORD PTR [rsp+0x50]
     f5c:	mov    r12,QWORD PTR [rsp+0x58]
     f61:	mov    r13,QWORD PTR [rsp+0x60]
     f66:	mov    r14,QWORD PTR [rsp+0x68]
     f6b:	mov    r15,QWORD PTR [rsp+0x70]
     f70:	add    rsp,0x80
     f77:	mov    rsp,rbp
     f7a:	pop    rbp
     f7b:	ret
     f7c:	mov    r14,QWORD PTR [rsp+0x20]
     f81:	mov    r15,QWORD PTR [rsp+0x28]
     f86:	mov    rdi,QWORD PTR [rsp+0x30]
     f8b:	mov    rcx,QWORD PTR [rdi+0x10]
     f8f:	mov    r8,QWORD PTR [rcx+0x10]
     f93:	mov    rcx,r15
     f96:	mov    rdx,r14
     f99:	mov    rsi,QWORD PTR [rsp+0x38]
     f9e:	call   fa3 <botlish_fn_7+0x14e>
			f9f: R_X86_64_PLT32	rt_str_region_eq-0x4
     fa3:	cmp    rax,0x6
     fa7:	je     1093 <botlish_fn_7+0x23e>
     fad:	mov    rdi,QWORD PTR [rsp+0x30]
     fb2:	mov    rax,QWORD PTR [rdi+0x10]
     fb6:	mov    r8,QWORD PTR [rax+0x18]
     fba:	mov    rcx,r15
     fbd:	mov    rdx,r14
     fc0:	mov    rsi,QWORD PTR [rsp+0x38]
     fc5:	call   fca <botlish_fn_7+0x175>
			fc6: R_X86_64_PLT32	rt_str_region_eq-0x4
     fca:	cmp    rax,0x6
     fce:	je     100b <botlish_fn_7+0x1b6>
     fd4:	mov    rdi,QWORD PTR [rsp+0x30]
     fd9:	mov    QWORD PTR [rdi],rbx
     fdc:	mov    rax,QWORD PTR [rsp+0x40]
     fe1:	mov    rdx,QWORD PTR [rsp+0x48]
     fe6:	mov    rbx,QWORD PTR [rsp+0x50]
     feb:	mov    r12,QWORD PTR [rsp+0x58]
     ff0:	mov    r13,QWORD PTR [rsp+0x60]
     ff5:	mov    r14,QWORD PTR [rsp+0x68]
     ffa:	mov    r15,QWORD PTR [rsp+0x70]
     fff:	add    rsp,0x80
    1006:	mov    rsp,rbp
    1009:	pop    rbp
    100a:	ret
    100b:	mov    QWORD PTR [rsp],0x3
    1013:	mov    rdx,QWORD PTR [rsp+0x48]
    1018:	test   rdx,0x1
    101f:	je     1045 <botlish_fn_7+0x1f0>
    1025:	mov    rdx,QWORD PTR [rsp+0x48]
    102a:	add    rdx,0x2
    102e:	seto   r10b
    1032:	test   r10b,r10b
    1035:	jne    1045 <botlish_fn_7+0x1f0>
    103b:	mov    rdi,QWORD PTR [rsp+0x30]
    1040:	jmp    1061 <botlish_fn_7+0x20c>
    1045:	mov    edx,0x3
    104a:	mov    rsi,QWORD PTR [rsp+0x48]
    104f:	mov    rdi,QWORD PTR [rsp+0x30]
    1054:	call   1059 <botlish_fn_7+0x204>
			1055: R_X86_64_PLT32	rt_int_add-0x4
    1059:	mov    rdx,rax
    105c:	mov    rdi,QWORD PTR [rsp+0x30]
    1061:	mov    rdi,QWORD PTR [rsp+0x30]
    1066:	mov    QWORD PTR [rdi],rbx
    1069:	mov    rax,QWORD PTR [rsp+0x40]
    106e:	mov    rbx,QWORD PTR [rsp+0x50]
    1073:	mov    r12,QWORD PTR [rsp+0x58]
    1078:	mov    r13,QWORD PTR [rsp+0x60]
    107d:	mov    r14,QWORD PTR [rsp+0x68]
    1082:	mov    r15,QWORD PTR [rsp+0x70]
    1087:	add    rsp,0x80
    108e:	mov    rsp,rbp
    1091:	pop    rbp
    1092:	ret
    1093:	mov    rsi,QWORD PTR [rsp+0x48]
    1098:	mov    edx,0x3
    109d:	mov    rcx,rdx
    10a0:	mov    QWORD PTR [rsp+0x10],0x3
    10a9:	test   rsi,0x1
    10b0:	jne    10be <botlish_fn_7+0x269>
    10b6:	mov    rdx,rcx
    10b9:	jmp    10d3 <botlish_fn_7+0x27e>
    10be:	mov    rdx,rsi
    10c1:	add    rdx,0x2
    10c5:	seto   al
    10c8:	test   al,al
    10ca:	je     10e0 <botlish_fn_7+0x28b>
    10d0:	mov    rdx,rcx
    10d3:	mov    rdi,QWORD PTR [rsp+0x30]
    10d8:	call   10dd <botlish_fn_7+0x288>
			10d9: R_X86_64_PLT32	rt_int_add-0x4
    10dd:	mov    rdx,rax
    10e0:	mov    QWORD PTR [rsp],r13
    10e4:	mov    QWORD PTR [rsp+0x8],rdx
    10e9:	mov    rax,QWORD PTR [rsp+0x40]
    10ee:	mov    QWORD PTR [rsp+0x10],rax
    10f3:	mov    r14,QWORD PTR [rsp+0x40]
    10f8:	jmp    ec2 <botlish_fn_7+0x6d>
    10fd:	mov    QWORD PTR [rsp+0x30],rdi
    1102:	call   1107 <botlish_fn_7+0x2b2>
			1103: R_X86_64_PLT32	rt_stack_overflow-0x4
    1107:	xor    rdx,rdx
    110a:	mov    rax,rdx
    110d:	mov    rbx,QWORD PTR [rsp+0x50]
    1112:	mov    r12,QWORD PTR [rsp+0x58]
    1117:	mov    r13,QWORD PTR [rsp+0x60]
    111c:	mov    r14,QWORD PTR [rsp+0x68]
    1121:	mov    r15,QWORD PTR [rsp+0x70]
    1126:	add    rsp,0x80
    112d:	mov    rsp,rbp
    1130:	pop    rbp
    1131:	ret

0000000000001132 <botlish_entry_7: scan_record<str, int, list<str>>>:
    1132:	push   rbp
    1133:	mov    rbp,rsp
    1136:	ud2

0000000000001138 <botlish_fn_8: scan_records<str, int, list<never>>>:
    1138:	push   rbp
    1139:	mov    rbp,rsp
    113c:	sub    rsp,0x50
    1140:	mov    QWORD PTR [rsp+0x20],rbx
    1145:	mov    QWORD PTR [rsp+0x28],r12
    114a:	mov    QWORD PTR [rsp+0x30],r13
    114f:	mov    QWORD PTR [rsp+0x38],r14
    1154:	mov    QWORD PTR [rsp+0x40],r15
    1159:	mov    rbx,QWORD PTR [rdi]
    115c:	mov    rax,QWORD PTR [rdi+0x8]
    1160:	lea    r8,[rbx+0x8]
    1164:	cmp    r8,rax
    1167:	ja     12d0 <botlish_fn_8+0x198>
    116d:	lea    rax,[rbx+0x8]
    1171:	mov    QWORD PTR [rdi],rax
    1174:	mov    r12,rdi
    1177:	mov    QWORD PTR [rbx],0x0
    117e:	mov    QWORD PTR [rsp+0x18],0x0
    1187:	mov    QWORD PTR [rsp],rsi
    118b:	mov    r13,rsi
    118e:	mov    QWORD PTR [rsp+0x8],rdx
    1193:	mov    r15,rdx
    1196:	mov    QWORD PTR [rsp+0x10],rcx
    119b:	mov    r14,rcx
    119e:	mov    rsi,r13
    11a1:	mov    rdi,r12
    11a4:	call   11a9 <botlish_fn_8+0x71>
			11a5: R_X86_64_PLT32	rt_str_len-0x4
    11a9:	mov    rdx,r15
    11ac:	mov    rcx,rdx
    11af:	sar    rcx,1
    11b2:	sar    rax,1
    11b5:	cmp    rcx,rax
    11b8:	jge    12a5 <botlish_fn_8+0x16d>
    11be:	xor    rdx,rdx
    11c1:	mov    rdi,r12
    11c4:	mov    rsi,rdx
    11c7:	call   11cc <botlish_fn_8+0x94>
			11c8: R_X86_64_PLT32	rt_list_new-0x4
    11cc:	test   rax,rax
    11cf:	jne    11dd <botlish_fn_8+0xa5>
    11d5:	mov    rdi,r12
    11d8:	jmp    1252 <botlish_fn_8+0x11a>
    11dd:	mov    QWORD PTR [rsp+0x18],rax
    11e2:	mov    rcx,rax
    11e5:	mov    rdx,r15
    11e8:	mov    rsi,r13
    11eb:	mov    rdi,r12
    11ee:	call   11f3 <botlish_fn_8+0xbb>
			11ef: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, list<never>>
    11f3:	test   rax,rax
    11f6:	jne    1204 <botlish_fn_8+0xcc>
    11fc:	mov    rdi,r12
    11ff:	jmp    1252 <botlish_fn_8+0x11a>
    1204:	mov    QWORD PTR [rsp+0x8],rax
    1209:	mov    QWORD PTR [rsp+0x18],rdx
    120e:	mov    rsi,r14
    1211:	mov    r14,rdx
    1214:	mov    rdx,rax
    1217:	mov    rdi,r12
    121a:	call   121f <botlish_fn_8+0xe7>
			121b: R_X86_64_PLT32	rt_list_append-0x4
    121f:	test   rax,rax
    1222:	jne    1230 <botlish_fn_8+0xf8>
    1228:	mov    rdi,r12
    122b:	jmp    1252 <botlish_fn_8+0x11a>
    1230:	mov    QWORD PTR [rsp+0x8],rax
    1235:	mov    rcx,rax
    1238:	mov    rdx,r14
    123b:	mov    rsi,r13
    123e:	mov    rdi,r12
    1241:	call   1246 <botlish_fn_8+0x10e>
			1242: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, list<list<str>>>
    1246:	test   rax,rax
    1249:	jne    127d <botlish_fn_8+0x145>
    124f:	mov    rdi,r12
    1252:	mov    rdi,r12
    1255:	mov    QWORD PTR [rdi],rbx
    1258:	xor    rax,rax
    125b:	mov    rbx,QWORD PTR [rsp+0x20]
    1260:	mov    r12,QWORD PTR [rsp+0x28]
    1265:	mov    r13,QWORD PTR [rsp+0x30]
    126a:	mov    r14,QWORD PTR [rsp+0x38]
    126f:	mov    r15,QWORD PTR [rsp+0x40]
    1274:	add    rsp,0x50
    1278:	mov    rsp,rbp
    127b:	pop    rbp
    127c:	ret
    127d:	mov    rdi,r12
    1280:	mov    QWORD PTR [rdi],rbx
    1283:	mov    rbx,QWORD PTR [rsp+0x20]
    1288:	mov    r12,QWORD PTR [rsp+0x28]
    128d:	mov    r13,QWORD PTR [rsp+0x30]
    1292:	mov    r14,QWORD PTR [rsp+0x38]
    1297:	mov    r15,QWORD PTR [rsp+0x40]
    129c:	add    rsp,0x50
    12a0:	mov    rsp,rbp
    12a3:	pop    rbp
    12a4:	ret
    12a5:	mov    rdi,r12
    12a8:	mov    QWORD PTR [rdi],rbx
    12ab:	mov    rax,r14
    12ae:	mov    rbx,QWORD PTR [rsp+0x20]
    12b3:	mov    r12,QWORD PTR [rsp+0x28]
    12b8:	mov    r13,QWORD PTR [rsp+0x30]
    12bd:	mov    r14,QWORD PTR [rsp+0x38]
    12c2:	mov    r15,QWORD PTR [rsp+0x40]
    12c7:	add    rsp,0x50
    12cb:	mov    rsp,rbp
    12ce:	pop    rbp
    12cf:	ret
    12d0:	mov    r12,rdi
    12d3:	call   12d8 <botlish_fn_8+0x1a0>
			12d4: R_X86_64_PLT32	rt_stack_overflow-0x4
    12d8:	xor    rax,rax
    12db:	mov    rbx,QWORD PTR [rsp+0x20]
    12e0:	mov    r12,QWORD PTR [rsp+0x28]
    12e5:	mov    r13,QWORD PTR [rsp+0x30]
    12ea:	mov    r14,QWORD PTR [rsp+0x38]
    12ef:	mov    r15,QWORD PTR [rsp+0x40]
    12f4:	add    rsp,0x50
    12f8:	mov    rsp,rbp
    12fb:	pop    rbp
    12fc:	ret

00000000000012fd <botlish_entry_8: scan_records<str, int, list<never>>>:
    12fd:	push   rbp
    12fe:	mov    rbp,rsp
    1301:	mov    rsi,QWORD PTR [rdx]
    1304:	mov    r8,QWORD PTR [rdx+0x8]
    1308:	mov    rcx,QWORD PTR [rdx+0x10]
    130c:	mov    rdx,r8
    130f:	call   1314 <botlish_entry_8+0x17>
			1310: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, list<never>>
    1314:	mov    rsp,rbp
    1317:	pop    rbp
    1318:	ret
    1319:	add    BYTE PTR [rax],al
    131b:	add    BYTE PTR [rax],al
    131d:	add    BYTE PTR [rax],al
	...

0000000000001320 <botlish_fn_9: scan_records<str, int, list<list<str>>>>:
    1320:	push   rbp
    1321:	mov    rbp,rsp
    1324:	sub    rsp,0x50
    1328:	mov    QWORD PTR [rsp+0x20],rbx
    132d:	mov    QWORD PTR [rsp+0x28],r12
    1332:	mov    QWORD PTR [rsp+0x30],r13
    1337:	mov    QWORD PTR [rsp+0x38],r14
    133c:	mov    QWORD PTR [rsp+0x40],r15
    1341:	mov    r12,QWORD PTR [rdi]
    1344:	mov    rax,QWORD PTR [rdi+0x8]
    1348:	lea    r8,[r12+0x8]
    134d:	cmp    r8,rax
    1350:	ja     14c3 <botlish_fn_9+0x1a3>
    1356:	lea    rax,[r12+0x8]
    135b:	mov    QWORD PTR [rdi],rax
    135e:	mov    r14,rdi
    1361:	mov    QWORD PTR [r12],0x0
    1369:	mov    QWORD PTR [rsp+0x18],0x0
    1372:	mov    QWORD PTR [rsp],rsi
    1376:	mov    QWORD PTR [rsp+0x8],rdx
    137b:	mov    r13,rdx
    137e:	mov    QWORD PTR [rsp+0x10],rcx
    1383:	mov    rbx,rsi
    1386:	mov    r15,rcx
    1389:	mov    rsi,rbx
    138c:	mov    rdi,r14
    138f:	call   1394 <botlish_fn_9+0x74>
			1390: R_X86_64_PLT32	rt_str_len-0x4
    1394:	mov    rcx,r13
    1397:	and    rcx,rax
    139a:	mov    rdx,rax
    139d:	test   rcx,0x1
    13a4:	jne    13ca <botlish_fn_9+0xaa>
    13aa:	mov    rsi,r13
    13ad:	mov    rdi,r14
    13b0:	call   13b5 <botlish_fn_9+0x95>
			13b1: R_X86_64_PLT32	rt_int_cmp-0x4
    13b5:	mov    ecx,0x2
    13ba:	test   rax,rax
    13bd:	cmovge rcx,QWORD PTR [rip+0x12b]        # 14f0 <botlish_fn_9+0x1d0>
    13c5:	jmp    13dd <botlish_fn_9+0xbd>
    13ca:	mov    ecx,0x2
    13cf:	mov    rsi,r13
    13d2:	cmp    rsi,rdx
    13d5:	cmovge rcx,QWORD PTR [rip+0x113]        # 14f0 <botlish_fn_9+0x1d0>
    13dd:	cmp    rcx,0x6
    13e1:	je     1498 <botlish_fn_9+0x178>
    13e7:	xor    rdx,rdx
    13ea:	mov    rdi,r14
    13ed:	mov    rsi,rdx
    13f0:	call   13f5 <botlish_fn_9+0xd5>
			13f1: R_X86_64_PLT32	rt_list_new-0x4
    13f5:	test   rax,rax
    13f8:	jne    1406 <botlish_fn_9+0xe6>
    13fe:	mov    rdi,r14
    1401:	jmp    1454 <botlish_fn_9+0x134>
    1406:	mov    QWORD PTR [rsp+0x18],rax
    140b:	mov    rcx,rax
    140e:	mov    rdx,r13
    1411:	mov    rsi,rbx
    1414:	mov    rdi,r14
    1417:	call   141c <botlish_fn_9+0xfc>
			1418: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, list<never>>
    141c:	test   rax,rax
    141f:	jne    142d <botlish_fn_9+0x10d>
    1425:	mov    rdi,r14
    1428:	jmp    1454 <botlish_fn_9+0x134>
    142d:	mov    QWORD PTR [rsp+0x8],rax
    1432:	mov    QWORD PTR [rsp+0x18],rdx
    1437:	mov    r13,rdx
    143a:	mov    rsi,r15
    143d:	mov    rdx,rax
    1440:	mov    rdi,r14
    1443:	call   1448 <botlish_fn_9+0x128>
			1444: R_X86_64_PLT32	rt_list_append-0x4
    1448:	test   rax,rax
    144b:	jne    147f <botlish_fn_9+0x15f>
    1451:	mov    rdi,r14
    1454:	mov    rdi,r14
    1457:	mov    QWORD PTR [rdi],r12
    145a:	xor    rax,rax
    145d:	mov    rbx,QWORD PTR [rsp+0x20]
    1462:	mov    r12,QWORD PTR [rsp+0x28]
    1467:	mov    r13,QWORD PTR [rsp+0x30]
    146c:	mov    r14,QWORD PTR [rsp+0x38]
    1471:	mov    r15,QWORD PTR [rsp+0x40]
    1476:	add    rsp,0x50
    147a:	mov    rsp,rbp
    147d:	pop    rbp
    147e:	ret
    147f:	mov    QWORD PTR [rsp],rbx
    1483:	mov    rdx,r13
    1486:	mov    QWORD PTR [rsp+0x8],rdx
    148b:	mov    QWORD PTR [rsp+0x10],rax
    1490:	mov    r15,rax
    1493:	jmp    1389 <botlish_fn_9+0x69>
    1498:	mov    rdi,r14
    149b:	mov    QWORD PTR [rdi],r12
    149e:	mov    rax,r15
    14a1:	mov    rbx,QWORD PTR [rsp+0x20]
    14a6:	mov    r12,QWORD PTR [rsp+0x28]
    14ab:	mov    r13,QWORD PTR [rsp+0x30]
    14b0:	mov    r14,QWORD PTR [rsp+0x38]
    14b5:	mov    r15,QWORD PTR [rsp+0x40]
    14ba:	add    rsp,0x50
    14be:	mov    rsp,rbp
    14c1:	pop    rbp
    14c2:	ret
    14c3:	mov    r14,rdi
    14c6:	call   14cb <botlish_fn_9+0x1ab>
			14c7: R_X86_64_PLT32	rt_stack_overflow-0x4
    14cb:	xor    rax,rax
    14ce:	mov    rbx,QWORD PTR [rsp+0x20]
    14d3:	mov    r12,QWORD PTR [rsp+0x28]
    14d8:	mov    r13,QWORD PTR [rsp+0x30]
    14dd:	mov    r14,QWORD PTR [rsp+0x38]
    14e2:	mov    r15,QWORD PTR [rsp+0x40]
    14e7:	add    rsp,0x50
    14eb:	mov    rsp,rbp
    14ee:	pop    rbp
    14ef:	ret
    14f0:	(bad)
    14f1:	add    BYTE PTR [rax],al
    14f3:	add    BYTE PTR [rax],al
    14f5:	add    BYTE PTR [rax],al
	...

00000000000014f8 <botlish_entry_9: scan_records<str, int, list<list<str>>>>:
    14f8:	push   rbp
    14f9:	mov    rbp,rsp
    14fc:	mov    rsi,QWORD PTR [rdx]
    14ff:	mov    r8,QWORD PTR [rdx+0x8]
    1503:	mov    rcx,QWORD PTR [rdx+0x10]
    1507:	mov    rdx,r8
    150a:	call   150f <botlish_entry_9+0x17>
			150b: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, list<list<str>>>
    150f:	mov    rsp,rbp
    1512:	pop    rbp
    1513:	ret

0000000000001514 <botlish_fn_10: csv_parse<str>>:
    1514:	push   rbp
    1515:	mov    rbp,rsp
    1518:	sub    rsp,0x40
    151c:	mov    QWORD PTR [rsp+0x20],rbx
    1521:	mov    QWORD PTR [rsp+0x28],r12
    1526:	mov    QWORD PTR [rsp+0x30],r13
    152b:	mov    rbx,QWORD PTR [rdi]
    152e:	mov    rax,QWORD PTR [rdi+0x8]
    1532:	lea    rcx,[rbx+0x8]
    1536:	cmp    rcx,rax
    1539:	ja     15eb <botlish_fn_10+0xd7>
    153f:	lea    rax,[rbx+0x8]
    1543:	mov    QWORD PTR [rdi],rax
    1546:	mov    r12,rdi
    1549:	mov    QWORD PTR [rbx],0x0
    1550:	mov    QWORD PTR [rsp+0x10],0x0
    1559:	mov    QWORD PTR [rsp],rsi
    155d:	mov    r13,rsi
    1560:	mov    QWORD PTR [rsp+0x8],0x1
    1569:	xor    rdx,rdx
    156c:	mov    rdi,r12
    156f:	mov    rsi,rdx
    1572:	call   1577 <botlish_fn_10+0x63>
			1573: R_X86_64_PLT32	rt_list_new-0x4
    1577:	test   rax,rax
    157a:	jne    1588 <botlish_fn_10+0x74>
    1580:	mov    rdi,r12
    1583:	jmp    15ac <botlish_fn_10+0x98>
    1588:	mov    QWORD PTR [rsp+0x10],rax
    158d:	mov    rcx,rax
    1590:	mov    edx,0x1
    1595:	mov    rsi,r13
    1598:	mov    rdi,r12
    159b:	call   15a0 <botlish_fn_10+0x8c>
			159c: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, list<never>>
    15a0:	test   rax,rax
    15a3:	jne    15cd <botlish_fn_10+0xb9>
    15a9:	mov    rdi,r12
    15ac:	mov    rdi,r12
    15af:	mov    QWORD PTR [rdi],rbx
    15b2:	xor    rax,rax
    15b5:	mov    rbx,QWORD PTR [rsp+0x20]
    15ba:	mov    r12,QWORD PTR [rsp+0x28]
    15bf:	mov    r13,QWORD PTR [rsp+0x30]
    15c4:	add    rsp,0x40
    15c8:	mov    rsp,rbp
    15cb:	pop    rbp
    15cc:	ret
    15cd:	mov    rdi,r12
    15d0:	mov    QWORD PTR [rdi],rbx
    15d3:	mov    rbx,QWORD PTR [rsp+0x20]
    15d8:	mov    r12,QWORD PTR [rsp+0x28]
    15dd:	mov    r13,QWORD PTR [rsp+0x30]
    15e2:	add    rsp,0x40
    15e6:	mov    rsp,rbp
    15e9:	pop    rbp
    15ea:	ret
    15eb:	mov    r12,rdi
    15ee:	call   15f3 <botlish_fn_10+0xdf>
			15ef: R_X86_64_PLT32	rt_stack_overflow-0x4
    15f3:	xor    rax,rax
    15f6:	mov    rbx,QWORD PTR [rsp+0x20]
    15fb:	mov    r12,QWORD PTR [rsp+0x28]
    1600:	mov    r13,QWORD PTR [rsp+0x30]
    1605:	add    rsp,0x40
    1609:	mov    rsp,rbp
    160c:	pop    rbp
    160d:	ret

000000000000160e <botlish_entry_10: csv_parse<str>>:
    160e:	push   rbp
    160f:	mov    rbp,rsp
    1612:	mov    rsi,QWORD PTR [rdx]
    1615:	call   161a <botlish_entry_10+0xc>
			1616: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
    161a:	mov    rsp,rbp
    161d:	pop    rbp
    161e:	ret

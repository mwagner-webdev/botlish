; source:  examples/stdlib/csv.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5968  (per function: 235 365 430 585 1141 352 795 976 398 524 167)
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
       4:	sub    rsp,0x20
       8:	mov    QWORD PTR [rsp+0x10],rbx
       d:	mov    rax,QWORD PTR [rdi+0x10]
      11:	mov    rbx,rdi
      14:	mov    rsi,QWORD PTR [rax]
      17:	mov    QWORD PTR [rsp],rsi
      1b:	call   20 <botlish_fn_0+0x20>
			1c: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
      20:	test   rax,rax
      23:	jne    a5 <botlish_fn_0+0xa5>
      29:	mov    rdi,rbx
      2c:	call   31 <botlish_fn_0+0x31>
			2d: R_X86_64_PLT32	rt_declared_error-0x4
      31:	cmp    rax,0x40000002
      37:	je     75 <botlish_fn_0+0x75>
      3d:	mov    rdi,rbx
      40:	call   45 <botlish_fn_0+0x45>
			41: R_X86_64_PLT32	rt_declared_error-0x4
      45:	cmp    rax,0x40000003
      4b:	jne    94 <botlish_fn_0+0x94>
      51:	mov    rdi,rbx
      54:	call   59 <botlish_fn_0+0x59>
			55: R_X86_64_PLT32	rt_clear_declared_error-0x4
      59:	xor    rdx,rdx
      5c:	mov    rdi,rbx
      5f:	mov    rsi,rdx
      62:	call   67 <botlish_fn_0+0x67>
			63: R_X86_64_PLT32	rt_list_new-0x4
      67:	test   rax,rax
      6a:	je     94 <botlish_fn_0+0x94>
      70:	jmp    a5 <botlish_fn_0+0xa5>
      75:	mov    rdi,rbx
      78:	call   7d <botlish_fn_0+0x7d>
			79: R_X86_64_PLT32	rt_clear_declared_error-0x4
      7d:	xor    rdx,rdx
      80:	mov    rdi,rbx
      83:	mov    rsi,rdx
      86:	call   8b <botlish_fn_0+0x8b>
			87: R_X86_64_PLT32	rt_list_new-0x4
      8b:	test   rax,rax
      8e:	jne    a5 <botlish_fn_0+0xa5>
      94:	xor    rax,rax
      97:	mov    rbx,QWORD PTR [rsp+0x10]
      9c:	add    rsp,0x20
      a0:	mov    rsp,rbp
      a3:	pop    rbp
      a4:	ret
      a5:	mov    rbx,QWORD PTR [rsp+0x10]
      aa:	add    rsp,0x20
      ae:	mov    rsp,rbp
      b1:	pop    rbp
      b2:	ret

00000000000000b3 <botlish_entry_0: <program entry>>:
      b3:	push   rbp
      b4:	mov    rbp,rsp
      b7:	call   bc <botlish_entry_0+0x9>
			b8: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      bc:	mov    rsp,rbp
      bf:	pop    rbp
      c0:	ret
      c1:	add    BYTE PTR [rax],al
      c3:	add    BYTE PTR [rax],al
      c5:	add    BYTE PTR [rax],al
	...

00000000000000c8 <botlish_fn_1: peek<str, int>>:
      c8:	push   rbp
      c9:	mov    rbp,rsp
      cc:	sub    rsp,0x40
      d0:	mov    QWORD PTR [rsp+0x20],rbx
      d5:	mov    QWORD PTR [rsp+0x28],r12
      da:	mov    QWORD PTR [rsp+0x30],r13
      df:	mov    r13,rdi
      e2:	mov    QWORD PTR [rsp],rsi
      e6:	mov    r12,rsi
      e9:	mov    QWORD PTR [rsp+0x8],rdx
      ee:	mov    rbx,rdx
      f1:	mov    rsi,r12
      f4:	mov    rdi,r13
      f7:	call   fc <botlish_fn_1+0x34>
			f8: R_X86_64_PLT32	rt_str_len-0x4
      fc:	mov    rcx,rbx
      ff:	and    rcx,rax
     102:	mov    rdx,rax
     105:	test   rcx,0x1
     10c:	jne    132 <botlish_fn_1+0x6a>
     112:	mov    rsi,rbx
     115:	mov    rdi,r13
     118:	call   11d <botlish_fn_1+0x55>
			119: R_X86_64_PLT32	rt_int_cmp-0x4
     11d:	mov    ecx,0x2
     122:	test   rax,rax
     125:	cmovge rcx,QWORD PTR [rip+0xd3]        # 200 <botlish_fn_1+0x138>
     12d:	jmp    142 <botlish_fn_1+0x7a>
     132:	mov    ecx,0x2
     137:	cmp    rbx,rdx
     13a:	cmovge rcx,QWORD PTR [rip+0xbe]        # 200 <botlish_fn_1+0x138>
     142:	cmp    rcx,0x6
     146:	je     1d6 <botlish_fn_1+0x10e>
     14c:	mov    QWORD PTR [rsp+0x10],0x3
     155:	test   rbx,0x1
     15c:	je     174 <botlish_fn_1+0xac>
     162:	mov    rcx,rbx
     165:	add    rcx,0x2
     169:	seto   al
     16c:	test   al,al
     16e:	je     187 <botlish_fn_1+0xbf>
     174:	mov    edx,0x3
     179:	mov    rsi,rbx
     17c:	mov    rdi,r13
     17f:	call   184 <botlish_fn_1+0xbc>
			180: R_X86_64_PLT32	rt_int_add-0x4
     184:	mov    rcx,rax
     187:	mov    QWORD PTR [rsp+0x10],rcx
     18c:	mov    rdx,rbx
     18f:	mov    rsi,r12
     192:	mov    rdi,r13
     195:	call   19a <botlish_fn_1+0xd2>
			196: R_X86_64_PLT32	rt_substr-0x4
     19a:	test   rax,rax
     19d:	jne    1be <botlish_fn_1+0xf6>
     1a3:	xor    rax,rax
     1a6:	mov    rbx,QWORD PTR [rsp+0x20]
     1ab:	mov    r12,QWORD PTR [rsp+0x28]
     1b0:	mov    r13,QWORD PTR [rsp+0x30]
     1b5:	add    rsp,0x40
     1b9:	mov    rsp,rbp
     1bc:	pop    rbp
     1bd:	ret
     1be:	mov    rbx,QWORD PTR [rsp+0x20]
     1c3:	mov    r12,QWORD PTR [rsp+0x28]
     1c8:	mov    r13,QWORD PTR [rsp+0x30]
     1cd:	add    rsp,0x40
     1d1:	mov    rsp,rbp
     1d4:	pop    rbp
     1d5:	ret
     1d6:	mov    rdi,r13
     1d9:	mov    rax,QWORD PTR [rdi+0x10]
     1dd:	mov    rax,QWORD PTR [rax+0x8]
     1e1:	mov    rbx,QWORD PTR [rsp+0x20]
     1e6:	mov    r12,QWORD PTR [rsp+0x28]
     1eb:	mov    r13,QWORD PTR [rsp+0x30]
     1f0:	add    rsp,0x40
     1f4:	mov    rsp,rbp
     1f7:	pop    rbp
     1f8:	ret
     1f9:	add    BYTE PTR [rax],al
     1fb:	add    BYTE PTR [rax],al
     1fd:	add    BYTE PTR [rax],al
     1ff:	add    BYTE PTR [rsi],al
     201:	add    BYTE PTR [rax],al
     203:	add    BYTE PTR [rax],al
     205:	add    BYTE PTR [rax],al
	...

0000000000000208 <botlish_entry_1: peek<str, int>>:
     208:	push   rbp
     209:	mov    rbp,rsp
     20c:	mov    rsi,QWORD PTR [rdx]
     20f:	mov    rdx,QWORD PTR [rdx+0x8]
     213:	call   218 <botlish_entry_1+0x10>
			214: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     218:	mov    rsp,rbp
     21b:	pop    rbp
     21c:	ret
     21d:	add    BYTE PTR [rax],al
	...

0000000000000220 <botlish_fn_2: peek<str, int>>:
     220:	push   rbp
     221:	mov    rbp,rsp
     224:	sub    rsp,0x50
     228:	mov    QWORD PTR [rsp+0x20],rbx
     22d:	mov    QWORD PTR [rsp+0x28],r12
     232:	mov    QWORD PTR [rsp+0x30],r13
     237:	mov    QWORD PTR [rsp+0x38],r14
     23c:	mov    QWORD PTR [rsp+0x40],r15
     241:	mov    r12,rcx
     244:	mov    r14,rdi
     247:	mov    QWORD PTR [rsp],rsi
     24b:	mov    r13,rsi
     24e:	mov    QWORD PTR [rsp+0x8],rdx
     253:	mov    rbx,rdx
     256:	mov    rsi,r13
     259:	mov    rdi,r14
     25c:	call   261 <botlish_fn_2+0x41>
			25d: R_X86_64_PLT32	rt_str_len-0x4
     261:	mov    rcx,rbx
     264:	and    rcx,rax
     267:	mov    rdx,rax
     26a:	test   rcx,0x1
     271:	jne    297 <botlish_fn_2+0x77>
     277:	mov    rsi,rbx
     27a:	mov    rdi,r14
     27d:	call   282 <botlish_fn_2+0x62>
			27e: R_X86_64_PLT32	rt_int_cmp-0x4
     282:	mov    ecx,0x2
     287:	test   rax,rax
     28a:	cmovge rcx,QWORD PTR [rip+0x11e]        # 3b0 <botlish_fn_2+0x190>
     292:	jmp    2a7 <botlish_fn_2+0x87>
     297:	mov    ecx,0x2
     29c:	cmp    rbx,rdx
     29f:	cmovge rcx,QWORD PTR [rip+0x109]        # 3b0 <botlish_fn_2+0x190>
     2a7:	cmp    rcx,0x6
     2ab:	je     36b <botlish_fn_2+0x14b>
     2b1:	mov    QWORD PTR [rsp+0x10],0x3
     2ba:	test   rbx,0x1
     2c1:	je     2e4 <botlish_fn_2+0xc4>
     2c7:	mov    rax,rbx
     2ca:	add    rax,0x2
     2ce:	seto   cl
     2d1:	test   cl,cl
     2d3:	jne    2e4 <botlish_fn_2+0xc4>
     2d9:	mov    rdi,r14
     2dc:	mov    r15,rax
     2df:	jmp    2fa <botlish_fn_2+0xda>
     2e4:	mov    edx,0x3
     2e9:	mov    rsi,rbx
     2ec:	mov    rdi,r14
     2ef:	call   2f4 <botlish_fn_2+0xd4>
			2f0: R_X86_64_PLT32	rt_int_add-0x4
     2f4:	mov    r15,rax
     2f7:	mov    rdi,r14
     2fa:	mov    rdi,r14
     2fd:	mov    rcx,r15
     300:	mov    rdx,rbx
     303:	mov    rsi,r13
     306:	call   30b <botlish_fn_2+0xeb>
			307: R_X86_64_PLT32	rt_str_region_check-0x4
     30b:	test   rax,rax
     30e:	jne    339 <botlish_fn_2+0x119>
     314:	xor    rax,rax
     317:	mov    rbx,QWORD PTR [rsp+0x20]
     31c:	mov    r12,QWORD PTR [rsp+0x28]
     321:	mov    r13,QWORD PTR [rsp+0x30]
     326:	mov    r14,QWORD PTR [rsp+0x38]
     32b:	mov    r15,QWORD PTR [rsp+0x40]
     330:	add    rsp,0x50
     334:	mov    rsp,rbp
     337:	pop    rbp
     338:	ret
     339:	mov    rcx,r12
     33c:	mov    QWORD PTR [rcx],rbx
     33f:	mov    rax,r15
     342:	mov    QWORD PTR [rcx+0x8],rax
     346:	mov    rax,r13
     349:	mov    rbx,QWORD PTR [rsp+0x20]
     34e:	mov    r12,QWORD PTR [rsp+0x28]
     353:	mov    r13,QWORD PTR [rsp+0x30]
     358:	mov    r14,QWORD PTR [rsp+0x38]
     35d:	mov    r15,QWORD PTR [rsp+0x40]
     362:	add    rsp,0x50
     366:	mov    rsp,rbp
     369:	pop    rbp
     36a:	ret
     36b:	mov    rcx,r12
     36e:	mov    rdi,r14
     371:	mov    rax,QWORD PTR [rdi+0x10]
     375:	mov    rax,QWORD PTR [rax+0x8]
     379:	mov    QWORD PTR [rcx],0x1
     380:	mov    QWORD PTR [rcx+0x8],0x1
     388:	mov    rbx,QWORD PTR [rsp+0x20]
     38d:	mov    r12,QWORD PTR [rsp+0x28]
     392:	mov    r13,QWORD PTR [rsp+0x30]
     397:	mov    r14,QWORD PTR [rsp+0x38]
     39c:	mov    r15,QWORD PTR [rsp+0x40]
     3a1:	add    rsp,0x50
     3a5:	mov    rsp,rbp
     3a8:	pop    rbp
     3a9:	ret
     3aa:	add    BYTE PTR [rax],al
     3ac:	add    BYTE PTR [rax],al
     3ae:	add    BYTE PTR [rax],al
     3b0:	(bad)
     3b1:	add    BYTE PTR [rax],al
     3b3:	add    BYTE PTR [rax],al
     3b5:	add    BYTE PTR [rax],al
	...

00000000000003b8 <botlish_entry_2: peek<str, int>>:
     3b8:	push   rbp
     3b9:	mov    rbp,rsp
     3bc:	ud2

00000000000003be <botlish_fn_3: scan_unquoted<str, int, int>>:
     3be:	push   rbp
     3bf:	mov    rbp,rsp
     3c2:	sub    rsp,0x80
     3c9:	mov    QWORD PTR [rsp+0x50],rbx
     3ce:	mov    QWORD PTR [rsp+0x58],r12
     3d3:	mov    QWORD PTR [rsp+0x60],r13
     3d8:	mov    QWORD PTR [rsp+0x68],r14
     3dd:	mov    QWORD PTR [rsp+0x70],r15
     3e2:	mov    QWORD PTR [rsp+0x30],rdi
     3e7:	mov    QWORD PTR [rsp+0x18],0x0
     3f0:	mov    QWORD PTR [rsp],rsi
     3f4:	mov    r15,rsi
     3f7:	mov    QWORD PTR [rsp+0x8],rdx
     3fc:	mov    r14,rdx
     3ff:	mov    QWORD PTR [rsp+0x10],rcx
     404:	lea    r13,[rsp+0x20]
     409:	mov    QWORD PTR [rsp+0x38],rcx
     40e:	mov    rcx,r13
     411:	mov    rdx,QWORD PTR [rsp+0x38]
     416:	mov    rsi,r15
     419:	mov    rdi,QWORD PTR [rsp+0x30]
     41e:	call   423 <botlish_fn_3+0x65>
			41f: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     423:	mov    rsi,rax
     426:	mov    QWORD PTR [rsp+0x40],rax
     42b:	test   rax,rsi
     42e:	je     588 <botlish_fn_3+0x1ca>
     434:	mov    rbx,QWORD PTR [rsp+0x20]
     439:	mov    r12,QWORD PTR [rsp+0x28]
     43e:	mov    rdi,QWORD PTR [rsp+0x30]
     443:	mov    rcx,QWORD PTR [rdi+0x10]
     447:	mov    r8,QWORD PTR [rcx+0x8]
     44b:	mov    rcx,r12
     44e:	mov    rdx,rbx
     451:	mov    rsi,QWORD PTR [rsp+0x40]
     456:	call   45b <botlish_fn_3+0x9d>
			457: R_X86_64_PLT32	rt_str_region_eq-0x4
     45b:	cmp    rax,0x6
     45f:	je     4a0 <botlish_fn_3+0xe2>
     465:	mov    rdi,QWORD PTR [rsp+0x30]
     46a:	mov    rax,QWORD PTR [rdi+0x10]
     46e:	mov    r8,QWORD PTR [rax+0x10]
     472:	mov    rcx,r12
     475:	mov    rdx,rbx
     478:	mov    rsi,QWORD PTR [rsp+0x40]
     47d:	call   482 <botlish_fn_3+0xc4>
			47e: R_X86_64_PLT32	rt_str_region_eq-0x4
     482:	cmp    rax,0x6
     486:	je     496 <botlish_fn_3+0xd8>
     48c:	mov    eax,0x2
     491:	jmp    4a5 <botlish_fn_3+0xe7>
     496:	mov    eax,0x6
     49b:	jmp    4a5 <botlish_fn_3+0xe7>
     4a0:	mov    eax,0x6
     4a5:	cmp    rax,0x6
     4a9:	je     4ea <botlish_fn_3+0x12c>
     4af:	mov    rdi,QWORD PTR [rsp+0x30]
     4b4:	mov    rax,QWORD PTR [rdi+0x10]
     4b8:	mov    r8,QWORD PTR [rax+0x18]
     4bc:	mov    rcx,r12
     4bf:	mov    rdx,rbx
     4c2:	mov    rsi,QWORD PTR [rsp+0x40]
     4c7:	call   4cc <botlish_fn_3+0x10e>
			4c8: R_X86_64_PLT32	rt_str_region_eq-0x4
     4cc:	cmp    rax,0x6
     4d0:	je     4e0 <botlish_fn_3+0x122>
     4d6:	mov    eax,0x2
     4db:	jmp    4ef <botlish_fn_3+0x131>
     4e0:	mov    eax,0x6
     4e5:	jmp    4ef <botlish_fn_3+0x131>
     4ea:	mov    eax,0x6
     4ef:	cmp    rax,0x6
     4f3:	je     56a <botlish_fn_3+0x1ac>
     4f9:	mov    QWORD PTR [rsp+0x18],0x3
     502:	mov    rsi,QWORD PTR [rsp+0x38]
     507:	test   rsi,0x1
     50e:	je     535 <botlish_fn_3+0x177>
     514:	mov    rsi,QWORD PTR [rsp+0x38]
     519:	mov    rax,rsi
     51c:	add    rax,0x2
     520:	seto   sil
     524:	test   sil,sil
     527:	jne    535 <botlish_fn_3+0x177>
     52d:	mov    rsi,r15
     530:	jmp    54c <botlish_fn_3+0x18e>
     535:	mov    edx,0x3
     53a:	mov    rsi,QWORD PTR [rsp+0x38]
     53f:	mov    rdi,QWORD PTR [rsp+0x30]
     544:	call   549 <botlish_fn_3+0x18b>
			545: R_X86_64_PLT32	rt_int_add-0x4
     549:	mov    rsi,r15
     54c:	mov    QWORD PTR [rsp],rsi
     550:	mov    rdx,r14
     553:	mov    QWORD PTR [rsp+0x8],rdx
     558:	mov    QWORD PTR [rsp+0x10],rax
     55d:	mov    r15,rsi
     560:	mov    QWORD PTR [rsp+0x38],rax
     565:	jmp    40e <botlish_fn_3+0x50>
     56a:	mov    rdx,r14
     56d:	mov    rsi,r15
     570:	mov    rdi,QWORD PTR [rsp+0x30]
     575:	mov    rcx,QWORD PTR [rsp+0x38]
     57a:	call   57f <botlish_fn_3+0x1c1>
			57b: R_X86_64_PLT32	rt_substr-0x4
     57f:	test   rax,rax
     582:	jne    5b3 <botlish_fn_3+0x1f5>
     588:	xor    rdx,rdx
     58b:	mov    rax,rdx
     58e:	mov    rbx,QWORD PTR [rsp+0x50]
     593:	mov    r12,QWORD PTR [rsp+0x58]
     598:	mov    r13,QWORD PTR [rsp+0x60]
     59d:	mov    r14,QWORD PTR [rsp+0x68]
     5a2:	mov    r15,QWORD PTR [rsp+0x70]
     5a7:	add    rsp,0x80
     5ae:	mov    rsp,rbp
     5b1:	pop    rbp
     5b2:	ret
     5b3:	mov    rdx,QWORD PTR [rsp+0x38]
     5b8:	mov    rbx,QWORD PTR [rsp+0x50]
     5bd:	mov    r12,QWORD PTR [rsp+0x58]
     5c2:	mov    r13,QWORD PTR [rsp+0x60]
     5c7:	mov    r14,QWORD PTR [rsp+0x68]
     5cc:	mov    r15,QWORD PTR [rsp+0x70]
     5d1:	add    rsp,0x80
     5d8:	mov    rsp,rbp
     5db:	pop    rbp
     5dc:	ret

00000000000005dd <botlish_entry_3: scan_unquoted<str, int, int>>:
     5dd:	push   rbp
     5de:	mov    rbp,rsp
     5e1:	ud2

00000000000005e3 <botlish_fn_4: scan_quoted<str, int, str>>:
     5e3:	push   rbp
     5e4:	mov    rbp,rsp
     5e7:	sub    rsp,0xd0
     5ee:	mov    QWORD PTR [rsp+0xa0],rbx
     5f6:	mov    QWORD PTR [rsp+0xa8],r12
     5fe:	mov    QWORD PTR [rsp+0xb0],r13
     606:	mov    QWORD PTR [rsp+0xb8],r14
     60e:	mov    QWORD PTR [rsp+0xc0],r15
     616:	mov    QWORD PTR [rsp+0x88],rdi
     61e:	mov    QWORD PTR [rsp+0x18],0x0
     627:	mov    QWORD PTR [rsp+0x20],0x0
     630:	mov    QWORD PTR [rsp],rsi
     634:	mov    QWORD PTR [rsp+0x8],rdx
     639:	mov    QWORD PTR [rsp+0x10],rcx
     63e:	mov    r13,rcx
     641:	lea    r14,[rsp+0x68]
     646:	lea    rbx,[rsp+0x28]
     64b:	mov    r12,rsi
     64e:	mov    QWORD PTR [rsp+0x90],rdx
     656:	mov    rdx,QWORD PTR [rsp+0x90]
     65e:	mov    rsi,r12
     661:	mov    rdi,QWORD PTR [rsp+0x88]
     669:	call   66e <botlish_fn_4+0x8b>
			66a: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     66e:	test   rax,rax
     671:	je     9ba <botlish_fn_4+0x3d7>
     677:	mov    QWORD PTR [rsp+0x18],rax
     67c:	mov    rsi,QWORD PTR [rax+0x8]
     680:	mov    rcx,rax
     683:	mov    rax,0xffffffffffffffff
     68a:	test   rsi,rsi
     68d:	jne    69b <botlish_fn_4+0xb8>
     693:	mov    r15,rcx
     696:	jmp    6c6 <botlish_fn_4+0xe3>
     69b:	mov    r15,rcx
     69e:	movzx  rdi,BYTE PTR [r15+0x18]
     6a3:	test   rdi,rdi
     6a6:	jne    6c1 <botlish_fn_4+0xde>
     6ac:	mov    rsi,r15
     6af:	mov    rdi,QWORD PTR [rsp+0x88]
     6b7:	call   6bc <botlish_fn_4+0xd9>
			6b8: R_X86_64_PLT32	rt_str_to_short-0x4
     6bc:	jmp    6c6 <botlish_fn_4+0xe3>
     6c1:	movzx  rax,BYTE PTR [r15+0x19]
     6c6:	cmp    rax,0x22
     6ca:	je     78a <botlish_fn_4+0x1a7>
     6d0:	mov    QWORD PTR [rsp+0x20],0x3
     6d9:	mov    rsi,QWORD PTR [rsp+0x90]
     6e1:	test   rsi,0x1
     6e8:	je     708 <botlish_fn_4+0x125>
     6ee:	mov    rax,rsi
     6f1:	add    rax,0x2
     6f5:	seto   cl
     6f8:	test   cl,cl
     6fa:	jne    708 <botlish_fn_4+0x125>
     700:	mov    rsi,rax
     703:	jmp    71d <botlish_fn_4+0x13a>
     708:	mov    edx,0x3
     70d:	mov    rdi,QWORD PTR [rsp+0x88]
     715:	call   71a <botlish_fn_4+0x137>
			716: R_X86_64_PLT32	rt_int_add-0x4
     71a:	mov    rsi,rax
     71d:	mov    QWORD PTR [rsp+0x8],rsi
     722:	mov    QWORD PTR [rsp+0x90],rsi
     72a:	mov    QWORD PTR [rsp+0x68],0x0
     733:	mov    QWORD PTR [rsp+0x70],r13
     738:	mov    QWORD PTR [rsp+0x78],0x0
     741:	mov    QWORD PTR [rsp+0x80],r15
     749:	mov    esi,0x2
     74e:	mov    edx,0x4
     753:	mov    rcx,r14
     756:	mov    rdi,QWORD PTR [rsp+0x88]
     75e:	call   763 <botlish_fn_4+0x180>
			75f: R_X86_64_PLT32	rt_construct-0x4
     763:	test   rax,rax
     766:	je     9ba <botlish_fn_4+0x3d7>
     76c:	mov    QWORD PTR [rsp],r12
     770:	mov    rsi,QWORD PTR [rsp+0x90]
     778:	mov    QWORD PTR [rsp+0x8],rsi
     77d:	mov    QWORD PTR [rsp+0x10],rax
     782:	mov    r13,rax
     785:	jmp    656 <botlish_fn_4+0x73>
     78a:	mov    QWORD PTR [rsp+0x18],0x3
     793:	mov    rsi,QWORD PTR [rsp+0x90]
     79b:	test   rsi,0x1
     7a2:	je     7c2 <botlish_fn_4+0x1df>
     7a8:	mov    rsi,QWORD PTR [rsp+0x90]
     7b0:	mov    rdx,rsi
     7b3:	add    rdx,0x2
     7b7:	seto   al
     7ba:	test   al,al
     7bc:	je     7df <botlish_fn_4+0x1fc>
     7c2:	mov    edx,0x3
     7c7:	mov    rsi,QWORD PTR [rsp+0x90]
     7cf:	mov    rdi,QWORD PTR [rsp+0x88]
     7d7:	call   7dc <botlish_fn_4+0x1f9>
			7d8: R_X86_64_PLT32	rt_int_add-0x4
     7dc:	mov    rdx,rax
     7df:	mov    QWORD PTR [rsp+0x18],rdx
     7e4:	mov    rcx,rbx
     7e7:	mov    rsi,r12
     7ea:	mov    rdi,QWORD PTR [rsp+0x88]
     7f2:	call   7f7 <botlish_fn_4+0x214>
			7f3: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     7f7:	test   rax,rax
     7fa:	mov    rsi,rax
     7fd:	je     9ba <botlish_fn_4+0x3d7>
     803:	mov    rdx,QWORD PTR [rsp+0x28]
     808:	mov    rcx,QWORD PTR [rsp+0x30]
     80d:	mov    rdi,QWORD PTR [rsp+0x88]
     815:	mov    rax,QWORD PTR [rdi+0x10]
     819:	mov    r8,QWORD PTR [rax+0x20]
     81d:	call   822 <botlish_fn_4+0x23f>
			81e: R_X86_64_PLT32	rt_str_region_eq-0x4
     822:	cmp    rax,0x6
     826:	je     8f8 <botlish_fn_4+0x315>
     82c:	xor    rsi,rsi
     82f:	lea    rcx,[rsp+0x58]
     834:	mov    QWORD PTR [rsp+0x58],0x0
     83d:	mov    QWORD PTR [rsp+0x60],r13
     842:	mov    edx,0x2
     847:	mov    rdi,QWORD PTR [rsp+0x88]
     84f:	call   854 <botlish_fn_4+0x271>
			850: R_X86_64_PLT32	rt_construct-0x4
     854:	test   rax,rax
     857:	je     9ba <botlish_fn_4+0x3d7>
     85d:	mov    QWORD PTR [rsp],rax
     861:	mov    rbx,rax
     864:	mov    QWORD PTR [rsp+0x10],0x3
     86d:	mov    rsi,QWORD PTR [rsp+0x90]
     875:	test   rsi,0x1
     87c:	je     8a4 <botlish_fn_4+0x2c1>
     882:	mov    rsi,QWORD PTR [rsp+0x90]
     88a:	mov    rdx,rsi
     88d:	add    rdx,0x2
     891:	seto   al
     894:	test   al,al
     896:	jne    8a4 <botlish_fn_4+0x2c1>
     89c:	mov    rax,rbx
     89f:	jmp    8c4 <botlish_fn_4+0x2e1>
     8a4:	mov    edx,0x3
     8a9:	mov    rsi,QWORD PTR [rsp+0x90]
     8b1:	mov    rdi,QWORD PTR [rsp+0x88]
     8b9:	call   8be <botlish_fn_4+0x2db>
			8ba: R_X86_64_PLT32	rt_int_add-0x4
     8be:	mov    rdx,rax
     8c1:	mov    rax,rbx
     8c4:	mov    rbx,QWORD PTR [rsp+0xa0]
     8cc:	mov    r12,QWORD PTR [rsp+0xa8]
     8d4:	mov    r13,QWORD PTR [rsp+0xb0]
     8dc:	mov    r14,QWORD PTR [rsp+0xb8]
     8e4:	mov    r15,QWORD PTR [rsp+0xc0]
     8ec:	add    rsp,0xd0
     8f3:	mov    rsp,rbp
     8f6:	pop    rbp
     8f7:	ret
     8f8:	mov    QWORD PTR [rsp+0x18],0x5
     901:	mov    rsi,QWORD PTR [rsp+0x90]
     909:	test   rsi,0x1
     910:	je     942 <botlish_fn_4+0x35f>
     916:	mov    rsi,QWORD PTR [rsp+0x90]
     91e:	mov    rdi,rsi
     921:	add    rdi,0x4
     925:	seto   r9b
     929:	test   r9b,r9b
     92c:	jne    942 <botlish_fn_4+0x35f>
     932:	mov    rsi,rdi
     935:	mov    QWORD PTR [rsp+0x90],rdi
     93d:	jmp    967 <botlish_fn_4+0x384>
     942:	mov    edx,0x5
     947:	mov    rsi,QWORD PTR [rsp+0x90]
     94f:	mov    rdi,QWORD PTR [rsp+0x88]
     957:	call   95c <botlish_fn_4+0x379>
			958: R_X86_64_PLT32	rt_int_add-0x4
     95c:	mov    rsi,rax
     95f:	mov    QWORD PTR [rsp+0x90],rax
     967:	mov    QWORD PTR [rsp+0x8],rsi
     96c:	mov    rdi,QWORD PTR [rsp+0x88]
     974:	mov    rax,QWORD PTR [rdi+0x10]
     978:	mov    rax,QWORD PTR [rax+0x20]
     97c:	mov    QWORD PTR [rsp+0x18],rax
     981:	lea    rcx,[rsp+0x38]
     986:	mov    QWORD PTR [rsp+0x38],0x0
     98f:	mov    QWORD PTR [rsp+0x40],r13
     994:	mov    QWORD PTR [rsp+0x48],0x0
     99d:	mov    QWORD PTR [rsp+0x50],rax
     9a2:	mov    esi,0x2
     9a7:	mov    edx,0x4
     9ac:	call   9b1 <botlish_fn_4+0x3ce>
			9ad: R_X86_64_PLT32	rt_construct-0x4
     9b1:	test   rax,rax
     9b4:	jne    9f4 <botlish_fn_4+0x411>
     9ba:	xor    rdx,rdx
     9bd:	mov    rax,rdx
     9c0:	mov    rbx,QWORD PTR [rsp+0xa0]
     9c8:	mov    r12,QWORD PTR [rsp+0xa8]
     9d0:	mov    r13,QWORD PTR [rsp+0xb0]
     9d8:	mov    r14,QWORD PTR [rsp+0xb8]
     9e0:	mov    r15,QWORD PTR [rsp+0xc0]
     9e8:	add    rsp,0xd0
     9ef:	mov    rsp,rbp
     9f2:	pop    rbp
     9f3:	ret
     9f4:	mov    QWORD PTR [rsp],r12
     9f8:	mov    rsi,QWORD PTR [rsp+0x90]
     a00:	mov    QWORD PTR [rsp+0x8],rsi
     a05:	mov    QWORD PTR [rsp+0x10],rax
     a0a:	mov    r13,rax
     a0d:	jmp    656 <botlish_fn_4+0x73>

0000000000000a12 <botlish_entry_4: scan_quoted<str, int, str>>:
     a12:	push   rbp
     a13:	mov    rbp,rsp
     a16:	ud2

0000000000000a18 <botlish_fn_5: scan_field<str, int>>:
     a18:	push   rbp
     a19:	mov    rbp,rsp
     a1c:	sub    rsp,0x50
     a20:	mov    QWORD PTR [rsp+0x30],rbx
     a25:	mov    QWORD PTR [rsp+0x38],r12
     a2a:	mov    QWORD PTR [rsp+0x40],r13
     a2f:	mov    r12,rdi
     a32:	mov    r13,rdx
     a35:	mov    QWORD PTR [rsp+0x10],0x0
     a3e:	mov    QWORD PTR [rsp],rsi
     a42:	mov    rbx,rsi
     a45:	mov    QWORD PTR [rsp+0x8],rdx
     a4a:	lea    rcx,[rsp+0x18]
     a4f:	mov    rdx,r13
     a52:	mov    rsi,rbx
     a55:	mov    rdi,r12
     a58:	call   a5d <botlish_fn_5+0x45>
			a59: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     a5d:	test   rax,rax
     a60:	mov    rsi,rax
     a63:	je     b2e <botlish_fn_5+0x116>
     a69:	mov    rdx,QWORD PTR [rsp+0x18]
     a6e:	mov    rcx,QWORD PTR [rsp+0x20]
     a73:	mov    rdi,r12
     a76:	mov    rax,QWORD PTR [rdi+0x10]
     a7a:	mov    r8,QWORD PTR [rax+0x20]
     a7e:	call   a83 <botlish_fn_5+0x6b>
			a7f: R_X86_64_PLT32	rt_str_region_eq-0x4
     a83:	cmp    rax,0x6
     a87:	je     abf <botlish_fn_5+0xa7>
     a8d:	mov    rcx,r13
     a90:	mov    rsi,rbx
     a93:	mov    rdi,r12
     a96:	mov    rdx,rcx
     a99:	call   a9e <botlish_fn_5+0x86>
			a9a: R_X86_64_PLT32	botlish_fn_3-0x4 ; scan_unquoted<str, int, int>
     a9e:	test   rax,rax
     aa1:	je     b2e <botlish_fn_5+0x116>
     aa7:	mov    rbx,QWORD PTR [rsp+0x30]
     aac:	mov    r12,QWORD PTR [rsp+0x38]
     ab1:	mov    r13,QWORD PTR [rsp+0x40]
     ab6:	add    rsp,0x50
     aba:	mov    rsp,rbp
     abd:	pop    rbp
     abe:	ret
     abf:	mov    rcx,r13
     ac2:	mov    QWORD PTR [rsp+0x10],0x3
     acb:	test   rcx,0x1
     ad2:	jne    ae0 <botlish_fn_5+0xc8>
     ad8:	mov    r13,rcx
     adb:	jmp    af5 <botlish_fn_5+0xdd>
     ae0:	mov    rdx,rcx
     ae3:	add    rdx,0x2
     ae7:	mov    r13,rcx
     aea:	seto   al
     aed:	test   al,al
     aef:	je     b08 <botlish_fn_5+0xf0>
     af5:	mov    edx,0x3
     afa:	mov    rsi,r13
     afd:	mov    rdi,r12
     b00:	call   b05 <botlish_fn_5+0xed>
			b01: R_X86_64_PLT32	rt_int_add-0x4
     b05:	mov    rdx,rax
     b08:	mov    QWORD PTR [rsp+0x8],rdx
     b0d:	mov    rdi,r12
     b10:	mov    rax,QWORD PTR [rdi+0x10]
     b14:	mov    rcx,QWORD PTR [rax+0x8]
     b18:	mov    QWORD PTR [rsp+0x10],rcx
     b1d:	mov    rsi,rbx
     b20:	call   b25 <botlish_fn_5+0x10d>
			b21: R_X86_64_PLT32	botlish_fn_4-0x4 ; scan_quoted<str, int, str>
     b25:	test   rax,rax
     b28:	jne    b4c <botlish_fn_5+0x134>
     b2e:	xor    rdx,rdx
     b31:	mov    rax,rdx
     b34:	mov    rbx,QWORD PTR [rsp+0x30]
     b39:	mov    r12,QWORD PTR [rsp+0x38]
     b3e:	mov    r13,QWORD PTR [rsp+0x40]
     b43:	add    rsp,0x50
     b47:	mov    rsp,rbp
     b4a:	pop    rbp
     b4b:	ret
     b4c:	mov    rbx,QWORD PTR [rsp+0x30]
     b51:	mov    r12,QWORD PTR [rsp+0x38]
     b56:	mov    r13,QWORD PTR [rsp+0x40]
     b5b:	add    rsp,0x50
     b5f:	mov    rsp,rbp
     b62:	pop    rbp
     b63:	ret

0000000000000b64 <botlish_entry_5: scan_field<str, int>>:
     b64:	push   rbp
     b65:	mov    rbp,rsp
     b68:	ud2

0000000000000b6a <botlish_fn_6: scan_record<str, int, List[never]>>:
     b6a:	push   rbp
     b6b:	mov    rbp,rsp
     b6e:	sub    rsp,0xa0
     b75:	mov    QWORD PTR [rsp+0x70],rbx
     b7a:	mov    QWORD PTR [rsp+0x78],r12
     b7f:	mov    QWORD PTR [rsp+0x80],r13
     b87:	mov    QWORD PTR [rsp+0x88],r14
     b8f:	mov    QWORD PTR [rsp+0x90],r15
     b97:	mov    r13,rdi
     b9a:	mov    QWORD PTR [rsp+0x18],0x0
     ba3:	mov    QWORD PTR [rsp+0x20],0x0
     bac:	mov    QWORD PTR [rsp],rsi
     bb0:	mov    r15,rsi
     bb3:	mov    QWORD PTR [rsp+0x8],rdx
     bb8:	mov    QWORD PTR [rsp+0x10],rcx
     bbd:	mov    QWORD PTR [rsp+0x58],rcx
     bc2:	mov    rsi,r15
     bc5:	mov    rdi,r13
     bc8:	call   bcd <botlish_fn_6+0x63>
			bc9: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     bcd:	test   rax,rax
     bd0:	je     deb <botlish_fn_6+0x281>
     bd6:	mov    QWORD PTR [rsp+0x8],rax
     bdb:	mov    QWORD PTR [rsp+0x68],rax
     be0:	mov    QWORD PTR [rsp+0x18],rdx
     be5:	mov    r14,rdx
     be8:	lea    rcx,[rsp+0x28]
     bed:	mov    rsi,r15
     bf0:	mov    rdi,r13
     bf3:	call   bf8 <botlish_fn_6+0x8e>
			bf4: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     bf8:	test   rax,rax
     bfb:	mov    QWORD PTR [rsp+0x60],rax
     c00:	je     deb <botlish_fn_6+0x281>
     c06:	mov    r12,QWORD PTR [rsp+0x28]
     c0b:	mov    rbx,QWORD PTR [rsp+0x30]
     c10:	mov    rdi,r13
     c13:	mov    rcx,QWORD PTR [rdi+0x10]
     c17:	mov    r8,QWORD PTR [rcx+0x10]
     c1b:	mov    rcx,rbx
     c1e:	mov    rdx,r12
     c21:	mov    rsi,QWORD PTR [rsp+0x60]
     c26:	call   c2b <botlish_fn_6+0xc1>
			c27: R_X86_64_PLT32	rt_str_region_eq-0x4
     c2b:	cmp    rax,0x6
     c2f:	je     d41 <botlish_fn_6+0x1d7>
     c35:	mov    rdi,r13
     c38:	mov    rax,QWORD PTR [rdi+0x10]
     c3c:	mov    r8,QWORD PTR [rax+0x18]
     c40:	mov    rcx,rbx
     c43:	mov    rdx,r12
     c46:	mov    rsi,QWORD PTR [rsp+0x60]
     c4b:	call   c50 <botlish_fn_6+0xe6>
			c4c: R_X86_64_PLT32	rt_str_region_eq-0x4
     c50:	cmp    rax,0x6
     c54:	je     ca6 <botlish_fn_6+0x13c>
     c5a:	mov    rdx,QWORD PTR [rsp+0x68]
     c5f:	mov    rsi,QWORD PTR [rsp+0x58]
     c64:	mov    rdi,r13
     c67:	call   c6c <botlish_fn_6+0x102>
			c68: R_X86_64_PLT32	rt_list_append-0x4
     c6c:	test   rax,rax
     c6f:	je     deb <botlish_fn_6+0x281>
     c75:	mov    rdx,r14
     c78:	mov    rbx,QWORD PTR [rsp+0x70]
     c7d:	mov    r12,QWORD PTR [rsp+0x78]
     c82:	mov    r13,QWORD PTR [rsp+0x80]
     c8a:	mov    r14,QWORD PTR [rsp+0x88]
     c92:	mov    r15,QWORD PTR [rsp+0x90]
     c9a:	add    rsp,0xa0
     ca1:	mov    rsp,rbp
     ca4:	pop    rbp
     ca5:	ret
     ca6:	mov    rdx,QWORD PTR [rsp+0x68]
     cab:	mov    rsi,QWORD PTR [rsp+0x58]
     cb0:	mov    rdi,r13
     cb3:	call   cb8 <botlish_fn_6+0x14e>
			cb4: R_X86_64_PLT32	rt_list_append-0x4
     cb8:	test   rax,rax
     cbb:	je     deb <botlish_fn_6+0x281>
     cc1:	mov    QWORD PTR [rsp],rax
     cc5:	mov    r12,rax
     cc8:	mov    QWORD PTR [rsp+0x8],0x3
     cd1:	mov    rdx,r14
     cd4:	test   rdx,0x1
     cdb:	je     cfd <botlish_fn_6+0x193>
     ce1:	mov    rdx,r14
     ce4:	add    rdx,0x2
     ce8:	seto   sil
     cec:	test   sil,sil
     cef:	jne    cfd <botlish_fn_6+0x193>
     cf5:	mov    rax,r12
     cf8:	jmp    d13 <botlish_fn_6+0x1a9>
     cfd:	mov    edx,0x3
     d02:	mov    rsi,r14
     d05:	mov    rdi,r13
     d08:	call   d0d <botlish_fn_6+0x1a3>
			d09: R_X86_64_PLT32	rt_int_add-0x4
     d0d:	mov    rdx,rax
     d10:	mov    rax,r12
     d13:	mov    rbx,QWORD PTR [rsp+0x70]
     d18:	mov    r12,QWORD PTR [rsp+0x78]
     d1d:	mov    r13,QWORD PTR [rsp+0x80]
     d25:	mov    r14,QWORD PTR [rsp+0x88]
     d2d:	mov    r15,QWORD PTR [rsp+0x90]
     d35:	add    rsp,0xa0
     d3c:	mov    rsp,rbp
     d3f:	pop    rbp
     d40:	ret
     d41:	mov    rsi,r14
     d44:	mov    r12d,0x3
     d4a:	mov    QWORD PTR [rsp+0x20],0x3
     d53:	test   rsi,0x1
     d5a:	je     d72 <botlish_fn_6+0x208>
     d60:	mov    rdx,rsi
     d63:	add    rdx,0x2
     d67:	seto   al
     d6a:	test   al,al
     d6c:	je     d80 <botlish_fn_6+0x216>
     d72:	mov    rdx,r12
     d75:	mov    rdi,r13
     d78:	call   d7d <botlish_fn_6+0x213>
			d79: R_X86_64_PLT32	rt_int_add-0x4
     d7d:	mov    rdx,rax
     d80:	mov    QWORD PTR [rsp+0x18],rdx
     d85:	mov    rbx,rdx
     d88:	lea    rcx,[rsp+0x38]
     d8d:	mov    QWORD PTR [rsp+0x38],0x0
     d96:	mov    rsi,QWORD PTR [rsp+0x58]
     d9b:	mov    QWORD PTR [rsp+0x40],rsi
     da0:	mov    QWORD PTR [rsp+0x48],0x2
     da9:	mov    rdx,QWORD PTR [rsp+0x68]
     dae:	mov    QWORD PTR [rsp+0x50],rdx
     db3:	mov    edx,0x4
     db8:	mov    rsi,r12
     dbb:	mov    rdi,r13
     dbe:	call   dc3 <botlish_fn_6+0x259>
			dbf: R_X86_64_PLT32	rt_construct-0x4
     dc3:	test   rax,rax
     dc6:	je     deb <botlish_fn_6+0x281>
     dcc:	mov    QWORD PTR [rsp+0x8],rax
     dd1:	mov    rcx,rax
     dd4:	mov    rdx,rbx
     dd7:	mov    rsi,r15
     dda:	mov    rdi,r13
     ddd:	call   de2 <botlish_fn_6+0x278>
			dde: R_X86_64_PLT32	botlish_fn_7-0x4 ; scan_record<str, int, List[str]>
     de2:	test   rax,rax
     de5:	jne    e1f <botlish_fn_6+0x2b5>
     deb:	xor    rdx,rdx
     dee:	mov    rax,rdx
     df1:	mov    rbx,QWORD PTR [rsp+0x70]
     df6:	mov    r12,QWORD PTR [rsp+0x78]
     dfb:	mov    r13,QWORD PTR [rsp+0x80]
     e03:	mov    r14,QWORD PTR [rsp+0x88]
     e0b:	mov    r15,QWORD PTR [rsp+0x90]
     e13:	add    rsp,0xa0
     e1a:	mov    rsp,rbp
     e1d:	pop    rbp
     e1e:	ret
     e1f:	mov    rbx,QWORD PTR [rsp+0x70]
     e24:	mov    r12,QWORD PTR [rsp+0x78]
     e29:	mov    r13,QWORD PTR [rsp+0x80]
     e31:	mov    r14,QWORD PTR [rsp+0x88]
     e39:	mov    r15,QWORD PTR [rsp+0x90]
     e41:	add    rsp,0xa0
     e48:	mov    rsp,rbp
     e4b:	pop    rbp
     e4c:	ret

0000000000000e4d <botlish_entry_6: scan_record<str, int, List[never]>>:
     e4d:	push   rbp
     e4e:	mov    rbp,rsp
     e51:	ud2

0000000000000e53 <botlish_fn_7: scan_record<str, int, List[str]>>:
     e53:	push   rbp
     e54:	mov    rbp,rsp
     e57:	sub    rsp,0xf0
     e5e:	mov    QWORD PTR [rsp+0xc0],rbx
     e66:	mov    QWORD PTR [rsp+0xc8],r12
     e6e:	mov    QWORD PTR [rsp+0xd0],r13
     e76:	mov    QWORD PTR [rsp+0xd8],r14
     e7e:	mov    QWORD PTR [rsp+0xe0],r15
     e86:	mov    QWORD PTR [rsp+0x98],rdi
     e8e:	mov    QWORD PTR [rsp+0x18],0x0
     e97:	mov    QWORD PTR [rsp+0x20],0x0
     ea0:	mov    QWORD PTR [rsp],rsi
     ea4:	mov    QWORD PTR [rsp+0x8],rdx
     ea9:	mov    QWORD PTR [rsp+0xa0],rdx
     eb1:	mov    QWORD PTR [rsp+0x10],rcx
     eb6:	mov    r15,rcx
     eb9:	lea    rbx,[rsp+0x28]
     ebe:	mov    r12,rsi
     ec1:	mov    rsi,r12
     ec4:	mov    rdi,QWORD PTR [rsp+0x98]
     ecc:	call   ed1 <botlish_fn_7+0x7e>
			ecd: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     ed1:	test   rax,rax
     ed4:	je     1191 <botlish_fn_7+0x33e>
     eda:	mov    QWORD PTR [rsp+0x8],rax
     edf:	mov    QWORD PTR [rsp+0xb0],rax
     ee7:	mov    QWORD PTR [rsp+0x18],rdx
     eec:	mov    QWORD PTR [rsp+0xb8],rdx
     ef4:	mov    rcx,rbx
     ef7:	mov    rsi,r12
     efa:	mov    rdi,QWORD PTR [rsp+0x98]
     f02:	call   f07 <botlish_fn_7+0xb4>
			f03: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     f07:	test   rax,rax
     f0a:	mov    QWORD PTR [rsp+0xa8],rax
     f12:	je     1191 <botlish_fn_7+0x33e>
     f18:	mov    r13,QWORD PTR [rsp+0x28]
     f1d:	mov    r14,QWORD PTR [rsp+0x30]
     f22:	mov    rdi,QWORD PTR [rsp+0x98]
     f2a:	mov    rcx,QWORD PTR [rdi+0x10]
     f2e:	mov    r8,QWORD PTR [rcx+0x10]
     f32:	mov    rcx,r14
     f35:	mov    rdx,r13
     f38:	mov    rsi,QWORD PTR [rsp+0xa8]
     f40:	call   f45 <botlish_fn_7+0xf2>
			f41: R_X86_64_PLT32	rt_str_region_eq-0x4
     f45:	cmp    rax,0x6
     f49:	je     10f1 <botlish_fn_7+0x29e>
     f4f:	mov    rdi,QWORD PTR [rsp+0x98]
     f57:	mov    rax,QWORD PTR [rdi+0x10]
     f5b:	mov    r8,QWORD PTR [rax+0x18]
     f5f:	mov    rcx,r14
     f62:	mov    rdx,r13
     f65:	mov    rsi,QWORD PTR [rsp+0xa8]
     f6d:	call   f72 <botlish_fn_7+0x11f>
			f6e: R_X86_64_PLT32	rt_str_region_eq-0x4
     f72:	cmp    rax,0x6
     f76:	je     100d <botlish_fn_7+0x1ba>
     f7c:	lea    rcx,[rsp+0x78]
     f81:	mov    QWORD PTR [rsp+0x78],0x0
     f8a:	mov    r14,r15
     f8d:	mov    QWORD PTR [rsp+0x80],r14
     f95:	mov    QWORD PTR [rsp+0x88],0x2
     fa1:	mov    r15,QWORD PTR [rsp+0xb0]
     fa9:	mov    QWORD PTR [rsp+0x90],r15
     fb1:	mov    esi,0x1
     fb6:	mov    edx,0x4
     fbb:	mov    rdi,QWORD PTR [rsp+0x98]
     fc3:	call   fc8 <botlish_fn_7+0x175>
			fc4: R_X86_64_PLT32	rt_construct-0x4
     fc8:	test   rax,rax
     fcb:	je     1191 <botlish_fn_7+0x33e>
     fd1:	mov    rdx,QWORD PTR [rsp+0xb8]
     fd9:	mov    rbx,QWORD PTR [rsp+0xc0]
     fe1:	mov    r12,QWORD PTR [rsp+0xc8]
     fe9:	mov    r13,QWORD PTR [rsp+0xd0]
     ff1:	mov    r14,QWORD PTR [rsp+0xd8]
     ff9:	mov    r15,QWORD PTR [rsp+0xe0]
    1001:	add    rsp,0xf0
    1008:	mov    rsp,rbp
    100b:	pop    rbp
    100c:	ret
    100d:	mov    r14,r15
    1010:	mov    r15,QWORD PTR [rsp+0xb0]
    1018:	lea    rcx,[rsp+0x58]
    101d:	mov    QWORD PTR [rsp+0x58],0x0
    1026:	mov    QWORD PTR [rsp+0x60],r14
    102b:	mov    QWORD PTR [rsp+0x68],0x2
    1034:	mov    QWORD PTR [rsp+0x70],r15
    1039:	mov    esi,0x1
    103e:	mov    edx,0x4
    1043:	mov    rdi,QWORD PTR [rsp+0x98]
    104b:	call   1050 <botlish_fn_7+0x1fd>
			104c: R_X86_64_PLT32	rt_construct-0x4
    1050:	test   rax,rax
    1053:	je     1191 <botlish_fn_7+0x33e>
    1059:	mov    QWORD PTR [rsp],rax
    105d:	mov    r12,rax
    1060:	mov    QWORD PTR [rsp+0x8],0x3
    1069:	mov    rdx,QWORD PTR [rsp+0xb8]
    1071:	test   rdx,0x1
    1078:	je     109d <botlish_fn_7+0x24a>
    107e:	mov    rdx,QWORD PTR [rsp+0xb8]
    1086:	add    rdx,0x2
    108a:	seto   al
    108d:	test   al,al
    108f:	jne    109d <botlish_fn_7+0x24a>
    1095:	mov    rax,r12
    1098:	jmp    10bd <botlish_fn_7+0x26a>
    109d:	mov    edx,0x3
    10a2:	mov    rsi,QWORD PTR [rsp+0xb8]
    10aa:	mov    rdi,QWORD PTR [rsp+0x98]
    10b2:	call   10b7 <botlish_fn_7+0x264>
			10b3: R_X86_64_PLT32	rt_int_add-0x4
    10b7:	mov    rdx,rax
    10ba:	mov    rax,r12
    10bd:	mov    rbx,QWORD PTR [rsp+0xc0]
    10c5:	mov    r12,QWORD PTR [rsp+0xc8]
    10cd:	mov    r13,QWORD PTR [rsp+0xd0]
    10d5:	mov    r14,QWORD PTR [rsp+0xd8]
    10dd:	mov    r15,QWORD PTR [rsp+0xe0]
    10e5:	add    rsp,0xf0
    10ec:	mov    rsp,rbp
    10ef:	pop    rbp
    10f0:	ret
    10f1:	mov    r14,r15
    10f4:	mov    r15,QWORD PTR [rsp+0xb0]
    10fc:	mov    rsi,QWORD PTR [rsp+0xb8]
    1104:	mov    r13d,0x3
    110a:	mov    QWORD PTR [rsp+0x20],0x3
    1113:	test   rsi,0x1
    111a:	je     1132 <botlish_fn_7+0x2df>
    1120:	mov    rdx,rsi
    1123:	add    rdx,0x2
    1127:	seto   al
    112a:	test   al,al
    112c:	je     1145 <botlish_fn_7+0x2f2>
    1132:	mov    rdx,r13
    1135:	mov    rdi,QWORD PTR [rsp+0x98]
    113d:	call   1142 <botlish_fn_7+0x2ef>
			113e: R_X86_64_PLT32	rt_int_add-0x4
    1142:	mov    rdx,rax
    1145:	mov    QWORD PTR [rsp+0x18],rdx
    114a:	mov    QWORD PTR [rsp+0xa0],rdx
    1152:	lea    rcx,[rsp+0x38]
    1157:	mov    QWORD PTR [rsp+0x38],0x0
    1160:	mov    QWORD PTR [rsp+0x40],r14
    1165:	mov    QWORD PTR [rsp+0x48],0x2
    116e:	mov    QWORD PTR [rsp+0x50],r15
    1173:	mov    edx,0x4
    1178:	mov    rsi,r13
    117b:	mov    rdi,QWORD PTR [rsp+0x98]
    1183:	call   1188 <botlish_fn_7+0x335>
			1184: R_X86_64_PLT32	rt_construct-0x4
    1188:	test   rax,rax
    118b:	jne    11cb <botlish_fn_7+0x378>
    1191:	xor    rdx,rdx
    1194:	mov    rax,rdx
    1197:	mov    rbx,QWORD PTR [rsp+0xc0]
    119f:	mov    r12,QWORD PTR [rsp+0xc8]
    11a7:	mov    r13,QWORD PTR [rsp+0xd0]
    11af:	mov    r14,QWORD PTR [rsp+0xd8]
    11b7:	mov    r15,QWORD PTR [rsp+0xe0]
    11bf:	add    rsp,0xf0
    11c6:	mov    rsp,rbp
    11c9:	pop    rbp
    11ca:	ret
    11cb:	mov    QWORD PTR [rsp],r12
    11cf:	mov    rdx,QWORD PTR [rsp+0xa0]
    11d7:	mov    QWORD PTR [rsp+0x8],rdx
    11dc:	mov    QWORD PTR [rsp+0x10],rax
    11e1:	mov    r15,rax
    11e4:	jmp    ec1 <botlish_fn_7+0x6e>

00000000000011e9 <botlish_entry_7: scan_record<str, int, List[str]>>:
    11e9:	push   rbp
    11ea:	mov    rbp,rsp
    11ed:	ud2

00000000000011ef <botlish_fn_8: scan_records<str, int, List[never]>>:
    11ef:	push   rbp
    11f0:	mov    rbp,rsp
    11f3:	sub    rsp,0x60
    11f7:	mov    QWORD PTR [rsp+0x40],rbx
    11fc:	mov    QWORD PTR [rsp+0x48],r12
    1201:	mov    QWORD PTR [rsp+0x50],r13
    1206:	mov    QWORD PTR [rsp+0x58],r14
    120b:	mov    r12,rdi
    120e:	mov    QWORD PTR [rsp+0x18],0x0
    1217:	mov    QWORD PTR [rsp],rsi
    121b:	mov    rbx,rsi
    121e:	mov    QWORD PTR [rsp+0x8],rdx
    1223:	mov    r14,rdx
    1226:	mov    QWORD PTR [rsp+0x10],rcx
    122b:	mov    r13,rcx
    122e:	mov    rsi,rbx
    1231:	mov    rdi,r12
    1234:	call   1239 <botlish_fn_8+0x4a>
			1235: R_X86_64_PLT32	rt_str_len-0x4
    1239:	mov    rdx,r14
    123c:	mov    rcx,rdx
    123f:	sar    rcx,1
    1242:	sar    rax,1
    1245:	cmp    rcx,rax
    1248:	jge    132c <botlish_fn_8+0x13d>
    124e:	xor    rdx,rdx
    1251:	mov    rdi,r12
    1254:	mov    rsi,rdx
    1257:	call   125c <botlish_fn_8+0x6d>
			1258: R_X86_64_PLT32	rt_list_new-0x4
    125c:	test   rax,rax
    125f:	je     12ef <botlish_fn_8+0x100>
    1265:	mov    QWORD PTR [rsp+0x18],rax
    126a:	mov    rcx,rax
    126d:	mov    rdx,r14
    1270:	mov    rsi,rbx
    1273:	mov    rdi,r12
    1276:	call   127b <botlish_fn_8+0x8c>
			1277: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    127b:	test   rax,rax
    127e:	je     12ef <botlish_fn_8+0x100>
    1284:	mov    QWORD PTR [rsp+0x8],rax
    1289:	mov    QWORD PTR [rsp+0x18],rdx
    128e:	mov    r14,rdx
    1291:	lea    rcx,[rsp+0x20]
    1296:	mov    QWORD PTR [rsp+0x20],0x0
    129f:	mov    rdx,r13
    12a2:	mov    QWORD PTR [rsp+0x28],rdx
    12a7:	mov    QWORD PTR [rsp+0x30],0x2
    12b0:	mov    QWORD PTR [rsp+0x38],rax
    12b5:	mov    esi,0x3
    12ba:	mov    edx,0x4
    12bf:	mov    rdi,r12
    12c2:	call   12c7 <botlish_fn_8+0xd8>
			12c3: R_X86_64_PLT32	rt_construct-0x4
    12c7:	test   rax,rax
    12ca:	je     12ef <botlish_fn_8+0x100>
    12d0:	mov    QWORD PTR [rsp+0x8],rax
    12d5:	mov    rcx,rax
    12d8:	mov    rdx,r14
    12db:	mov    rsi,rbx
    12de:	mov    rdi,r12
    12e1:	call   12e6 <botlish_fn_8+0xf7>
			12e2: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    12e6:	test   rax,rax
    12e9:	jne    130f <botlish_fn_8+0x120>
    12ef:	xor    rax,rax
    12f2:	mov    rbx,QWORD PTR [rsp+0x40]
    12f7:	mov    r12,QWORD PTR [rsp+0x48]
    12fc:	mov    r13,QWORD PTR [rsp+0x50]
    1301:	mov    r14,QWORD PTR [rsp+0x58]
    1306:	add    rsp,0x60
    130a:	mov    rsp,rbp
    130d:	pop    rbp
    130e:	ret
    130f:	mov    rbx,QWORD PTR [rsp+0x40]
    1314:	mov    r12,QWORD PTR [rsp+0x48]
    1319:	mov    r13,QWORD PTR [rsp+0x50]
    131e:	mov    r14,QWORD PTR [rsp+0x58]
    1323:	add    rsp,0x60
    1327:	mov    rsp,rbp
    132a:	pop    rbp
    132b:	ret
    132c:	mov    rax,r13
    132f:	mov    rbx,QWORD PTR [rsp+0x40]
    1334:	mov    r12,QWORD PTR [rsp+0x48]
    1339:	mov    r13,QWORD PTR [rsp+0x50]
    133e:	mov    r14,QWORD PTR [rsp+0x58]
    1343:	add    rsp,0x60
    1347:	mov    rsp,rbp
    134a:	pop    rbp
    134b:	ret

000000000000134c <botlish_entry_8: scan_records<str, int, List[never]>>:
    134c:	push   rbp
    134d:	mov    rbp,rsp
    1350:	mov    rsi,QWORD PTR [rdx]
    1353:	mov    r8,QWORD PTR [rdx+0x8]
    1357:	mov    rcx,QWORD PTR [rdx+0x10]
    135b:	mov    rdx,r8
    135e:	call   1363 <botlish_entry_8+0x17>
			135f: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    1363:	mov    rsp,rbp
    1366:	pop    rbp
    1367:	ret

0000000000001368 <botlish_fn_9: scan_records<str, int, List[List[str]]>>:
    1368:	push   rbp
    1369:	mov    rbp,rsp
    136c:	sub    rsp,0x80
    1373:	mov    QWORD PTR [rsp+0x50],rbx
    1378:	mov    QWORD PTR [rsp+0x58],r12
    137d:	mov    QWORD PTR [rsp+0x60],r13
    1382:	mov    QWORD PTR [rsp+0x68],r14
    1387:	mov    QWORD PTR [rsp+0x70],r15
    138c:	mov    r14,rdi
    138f:	mov    QWORD PTR [rsp+0x18],0x0
    1398:	mov    QWORD PTR [rsp],rsi
    139c:	mov    QWORD PTR [rsp+0x8],rdx
    13a1:	mov    r13,rdx
    13a4:	mov    QWORD PTR [rsp+0x10],rcx
    13a9:	mov    r15,rcx
    13ac:	lea    r12,[rsp+0x30]
    13b1:	mov    rbx,rsi
    13b4:	mov    rsi,rbx
    13b7:	mov    rdi,r14
    13ba:	call   13bf <botlish_fn_9+0x57>
			13bb: R_X86_64_PLT32	rt_str_len-0x4
    13bf:	mov    rcx,r13
    13c2:	and    rcx,rax
    13c5:	mov    rdx,rax
    13c8:	test   rcx,0x1
    13cf:	jne    13f5 <botlish_fn_9+0x8d>
    13d5:	mov    rsi,r13
    13d8:	mov    rdi,r14
    13db:	call   13e0 <botlish_fn_9+0x78>
			13dc: R_X86_64_PLT32	rt_int_cmp-0x4
    13e0:	mov    ecx,0x2
    13e5:	test   rax,rax
    13e8:	cmovge rcx,QWORD PTR [rip+0x140]        # 1530 <botlish_fn_9+0x1c8>
    13f0:	jmp    1408 <botlish_fn_9+0xa0>
    13f5:	mov    ecx,0x2
    13fa:	mov    rax,r13
    13fd:	cmp    rax,rdx
    1400:	cmovge rcx,QWORD PTR [rip+0x128]        # 1530 <botlish_fn_9+0x1c8>
    1408:	cmp    rcx,0x6
    140c:	je     14ab <botlish_fn_9+0x143>
    1412:	xor    rdx,rdx
    1415:	mov    rdi,r14
    1418:	mov    rsi,rdx
    141b:	call   1420 <botlish_fn_9+0xb8>
			141c: R_X86_64_PLT32	rt_list_new-0x4
    1420:	test   rax,rax
    1423:	je     14dc <botlish_fn_9+0x174>
    1429:	mov    QWORD PTR [rsp+0x18],rax
    142e:	mov    rcx,rax
    1431:	mov    rdx,r13
    1434:	mov    rsi,rbx
    1437:	mov    rdi,r14
    143a:	call   143f <botlish_fn_9+0xd7>
			143b: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    143f:	test   rax,rax
    1442:	je     14dc <botlish_fn_9+0x174>
    1448:	mov    QWORD PTR [rsp+0x8],rax
    144d:	mov    QWORD PTR [rsp+0x18],rdx
    1452:	mov    r13,rdx
    1455:	mov    QWORD PTR [rsp+0x30],0x0
    145e:	mov    r9,r15
    1461:	mov    QWORD PTR [rsp+0x38],r9
    1466:	mov    QWORD PTR [rsp+0x40],0x2
    146f:	mov    QWORD PTR [rsp+0x48],rax
    1474:	mov    esi,0x3
    1479:	mov    edx,0x4
    147e:	mov    rcx,r12
    1481:	mov    rdi,r14
    1484:	call   1489 <botlish_fn_9+0x121>
			1485: R_X86_64_PLT32	rt_construct-0x4
    1489:	test   rax,rax
    148c:	je     14dc <botlish_fn_9+0x174>
    1492:	mov    QWORD PTR [rsp],rbx
    1496:	mov    rdx,r13
    1499:	mov    QWORD PTR [rsp+0x8],rdx
    149e:	mov    QWORD PTR [rsp+0x10],rax
    14a3:	mov    r15,rax
    14a6:	jmp    13b4 <botlish_fn_9+0x4c>
    14ab:	mov    r9,r15
    14ae:	lea    rcx,[rsp+0x20]
    14b3:	mov    QWORD PTR [rsp+0x20],0x0
    14bc:	mov    QWORD PTR [rsp+0x28],r9
    14c1:	mov    esi,0x1
    14c6:	mov    edx,0x2
    14cb:	mov    rdi,r14
    14ce:	call   14d3 <botlish_fn_9+0x16b>
			14cf: R_X86_64_PLT32	rt_construct-0x4
    14d3:	test   rax,rax
    14d6:	jne    1504 <botlish_fn_9+0x19c>
    14dc:	xor    rax,rax
    14df:	mov    rbx,QWORD PTR [rsp+0x50]
    14e4:	mov    r12,QWORD PTR [rsp+0x58]
    14e9:	mov    r13,QWORD PTR [rsp+0x60]
    14ee:	mov    r14,QWORD PTR [rsp+0x68]
    14f3:	mov    r15,QWORD PTR [rsp+0x70]
    14f8:	add    rsp,0x80
    14ff:	mov    rsp,rbp
    1502:	pop    rbp
    1503:	ret
    1504:	mov    rbx,QWORD PTR [rsp+0x50]
    1509:	mov    r12,QWORD PTR [rsp+0x58]
    150e:	mov    r13,QWORD PTR [rsp+0x60]
    1513:	mov    r14,QWORD PTR [rsp+0x68]
    1518:	mov    r15,QWORD PTR [rsp+0x70]
    151d:	add    rsp,0x80
    1524:	mov    rsp,rbp
    1527:	pop    rbp
    1528:	ret
    1529:	add    BYTE PTR [rax],al
    152b:	add    BYTE PTR [rax],al
    152d:	add    BYTE PTR [rax],al
    152f:	add    BYTE PTR [rsi],al
    1531:	add    BYTE PTR [rax],al
    1533:	add    BYTE PTR [rax],al
    1535:	add    BYTE PTR [rax],al
	...

0000000000001538 <botlish_entry_9: scan_records<str, int, List[List[str]]>>:
    1538:	push   rbp
    1539:	mov    rbp,rsp
    153c:	mov    rsi,QWORD PTR [rdx]
    153f:	mov    r8,QWORD PTR [rdx+0x8]
    1543:	mov    rcx,QWORD PTR [rdx+0x10]
    1547:	mov    rdx,r8
    154a:	call   154f <botlish_entry_9+0x17>
			154b: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    154f:	mov    rsp,rbp
    1552:	pop    rbp
    1553:	ret

0000000000001554 <botlish_fn_10: csv_parse<str>>:
    1554:	push   rbp
    1555:	mov    rbp,rsp
    1558:	sub    rsp,0x30
    155c:	mov    QWORD PTR [rsp+0x20],r12
    1561:	mov    QWORD PTR [rsp+0x28],r13
    1566:	mov    r13,rdi
    1569:	mov    QWORD PTR [rsp+0x10],0x0
    1572:	mov    QWORD PTR [rsp],rsi
    1576:	mov    r12,rsi
    1579:	mov    QWORD PTR [rsp+0x8],0x1
    1582:	xor    rdx,rdx
    1585:	mov    rdi,r13
    1588:	mov    rsi,rdx
    158b:	call   1590 <botlish_fn_10+0x3c>
			158c: R_X86_64_PLT32	rt_list_new-0x4
    1590:	test   rax,rax
    1593:	je     15ba <botlish_fn_10+0x66>
    1599:	mov    QWORD PTR [rsp+0x10],rax
    159e:	mov    rcx,rax
    15a1:	mov    edx,0x1
    15a6:	mov    rsi,r12
    15a9:	mov    rdi,r13
    15ac:	call   15b1 <botlish_fn_10+0x5d>
			15ad: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    15b1:	test   rax,rax
    15b4:	jne    15d0 <botlish_fn_10+0x7c>
    15ba:	xor    rax,rax
    15bd:	mov    r12,QWORD PTR [rsp+0x20]
    15c2:	mov    r13,QWORD PTR [rsp+0x28]
    15c7:	add    rsp,0x30
    15cb:	mov    rsp,rbp
    15ce:	pop    rbp
    15cf:	ret
    15d0:	mov    r12,QWORD PTR [rsp+0x20]
    15d5:	mov    r13,QWORD PTR [rsp+0x28]
    15da:	add    rsp,0x30
    15de:	mov    rsp,rbp
    15e1:	pop    rbp
    15e2:	ret

00000000000015e3 <botlish_entry_10: csv_parse<str>>:
    15e3:	push   rbp
    15e4:	mov    rbp,rsp
    15e7:	mov    rsi,QWORD PTR [rdx]
    15ea:	call   15ef <botlish_entry_10+0xc>
			15eb: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
    15ef:	mov    rsp,rbp
    15f2:	pop    rbp
    15f3:	ret

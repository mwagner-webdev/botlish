; source:  examples/stdlib/csv.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5478  (per function: 312 365 309 526 932 311 782 870 388 516 167)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> peek<str, int>
;   botlish_fn_2 / botlish_entry_2 -> quote_at?<str, int>
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
      23:	jne    dd <botlish_fn_0+0xdd>
      29:	mov    rdi,rbx
      2c:	call   31 <botlish_fn_0+0x31>
			2d: R_X86_64_PLT32	rt_declared_error-0x4
      31:	cmp    rax,0x40000001
      37:	je     ad <botlish_fn_0+0xad>
      3d:	mov    rdi,rbx
      40:	call   45 <botlish_fn_0+0x45>
			41: R_X86_64_PLT32	rt_declared_error-0x4
      45:	cmp    rax,0x40000002
      4b:	je     89 <botlish_fn_0+0x89>
      51:	mov    rdi,rbx
      54:	call   59 <botlish_fn_0+0x59>
			55: R_X86_64_PLT32	rt_declared_error-0x4
      59:	cmp    rax,0x40000003
      5f:	jne    cc <botlish_fn_0+0xcc>
      65:	mov    rdi,rbx
      68:	call   6d <botlish_fn_0+0x6d>
			69: R_X86_64_PLT32	rt_clear_declared_error-0x4
      6d:	xor    rdx,rdx
      70:	mov    rdi,rbx
      73:	mov    rsi,rdx
      76:	call   7b <botlish_fn_0+0x7b>
			77: R_X86_64_PLT32	rt_list_new-0x4
      7b:	test   rax,rax
      7e:	je     cc <botlish_fn_0+0xcc>
      84:	jmp    dd <botlish_fn_0+0xdd>
      89:	mov    rdi,rbx
      8c:	call   91 <botlish_fn_0+0x91>
			8d: R_X86_64_PLT32	rt_clear_declared_error-0x4
      91:	xor    rdx,rdx
      94:	mov    rdi,rbx
      97:	mov    rsi,rdx
      9a:	call   9f <botlish_fn_0+0x9f>
			9b: R_X86_64_PLT32	rt_list_new-0x4
      9f:	test   rax,rax
      a2:	je     cc <botlish_fn_0+0xcc>
      a8:	jmp    dd <botlish_fn_0+0xdd>
      ad:	mov    rdi,rbx
      b0:	call   b5 <botlish_fn_0+0xb5>
			b1: R_X86_64_PLT32	rt_clear_declared_error-0x4
      b5:	xor    rdx,rdx
      b8:	mov    rdi,rbx
      bb:	mov    rsi,rdx
      be:	call   c3 <botlish_fn_0+0xc3>
			bf: R_X86_64_PLT32	rt_list_new-0x4
      c3:	test   rax,rax
      c6:	jne    dd <botlish_fn_0+0xdd>
      cc:	xor    rax,rax
      cf:	mov    rbx,QWORD PTR [rsp+0x10]
      d4:	add    rsp,0x20
      d8:	mov    rsp,rbp
      db:	pop    rbp
      dc:	ret
      dd:	mov    rbx,QWORD PTR [rsp+0x10]
      e2:	add    rsp,0x20
      e6:	mov    rsp,rbp
      e9:	pop    rbp
      ea:	ret

00000000000000eb <botlish_entry_0: <program entry>>:
      eb:	push   rbp
      ec:	mov    rbp,rsp
      ef:	call   f4 <botlish_entry_0+0x9>
			f0: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      f4:	mov    rsp,rbp
      f7:	pop    rbp
      f8:	ret
      f9:	add    BYTE PTR [rax],al
      fb:	add    BYTE PTR [rax],al
      fd:	add    BYTE PTR [rax],al
	...

0000000000000100 <botlish_fn_1: peek<str, int>>:
     100:	push   rbp
     101:	mov    rbp,rsp
     104:	sub    rsp,0x40
     108:	mov    QWORD PTR [rsp+0x20],rbx
     10d:	mov    QWORD PTR [rsp+0x28],r12
     112:	mov    QWORD PTR [rsp+0x30],r13
     117:	mov    rbx,rdx
     11a:	mov    r13,rdi
     11d:	mov    QWORD PTR [rsp],rsi
     121:	mov    QWORD PTR [rsp+0x8],rdx
     126:	mov    rdx,QWORD PTR [rsi+0x8]
     12a:	mov    r12,rsi
     12d:	shl    rdx,1
     130:	mov    rax,rdx
     133:	or     rax,0x1
     137:	mov    rcx,rbx
     13a:	and    rcx,rax
     13d:	test   rcx,0x1
     144:	jne    16e <botlish_fn_1+0x6e>
     14a:	or     rdx,0x1
     14e:	mov    rsi,rbx
     151:	mov    rdi,r13
     154:	call   159 <botlish_fn_1+0x59>
			155: R_X86_64_PLT32	rt_int_cmp-0x4
     159:	mov    ecx,0x2
     15e:	test   rax,rax
     161:	cmovge rcx,QWORD PTR [rip+0xd7]        # 240 <botlish_fn_1+0x140>
     169:	jmp    182 <botlish_fn_1+0x82>
     16e:	or     rdx,0x1
     172:	mov    ecx,0x2
     177:	cmp    rbx,rdx
     17a:	cmovge rcx,QWORD PTR [rip+0xbe]        # 240 <botlish_fn_1+0x140>
     182:	cmp    rcx,0x6
     186:	je     216 <botlish_fn_1+0x116>
     18c:	mov    QWORD PTR [rsp+0x10],0x3
     195:	test   rbx,0x1
     19c:	je     1b4 <botlish_fn_1+0xb4>
     1a2:	mov    rcx,rbx
     1a5:	add    rcx,0x2
     1a9:	seto   al
     1ac:	test   al,al
     1ae:	je     1c7 <botlish_fn_1+0xc7>
     1b4:	mov    edx,0x3
     1b9:	mov    rsi,rbx
     1bc:	mov    rdi,r13
     1bf:	call   1c4 <botlish_fn_1+0xc4>
			1c0: R_X86_64_PLT32	rt_int_add-0x4
     1c4:	mov    rcx,rax
     1c7:	mov    QWORD PTR [rsp+0x10],rcx
     1cc:	mov    rdx,rbx
     1cf:	mov    rsi,r12
     1d2:	mov    rdi,r13
     1d5:	call   1da <botlish_fn_1+0xda>
			1d6: R_X86_64_PLT32	rt_substr-0x4
     1da:	test   rax,rax
     1dd:	jne    1fe <botlish_fn_1+0xfe>
     1e3:	xor    rax,rax
     1e6:	mov    rbx,QWORD PTR [rsp+0x20]
     1eb:	mov    r12,QWORD PTR [rsp+0x28]
     1f0:	mov    r13,QWORD PTR [rsp+0x30]
     1f5:	add    rsp,0x40
     1f9:	mov    rsp,rbp
     1fc:	pop    rbp
     1fd:	ret
     1fe:	mov    rbx,QWORD PTR [rsp+0x20]
     203:	mov    r12,QWORD PTR [rsp+0x28]
     208:	mov    r13,QWORD PTR [rsp+0x30]
     20d:	add    rsp,0x40
     211:	mov    rsp,rbp
     214:	pop    rbp
     215:	ret
     216:	mov    rdi,r13
     219:	mov    rax,QWORD PTR [rdi+0x10]
     21d:	mov    rax,QWORD PTR [rax+0x8]
     221:	mov    rbx,QWORD PTR [rsp+0x20]
     226:	mov    r12,QWORD PTR [rsp+0x28]
     22b:	mov    r13,QWORD PTR [rsp+0x30]
     230:	add    rsp,0x40
     234:	mov    rsp,rbp
     237:	pop    rbp
     238:	ret
     239:	add    BYTE PTR [rax],al
     23b:	add    BYTE PTR [rax],al
     23d:	add    BYTE PTR [rax],al
     23f:	add    BYTE PTR [rsi],al
     241:	add    BYTE PTR [rax],al
     243:	add    BYTE PTR [rax],al
     245:	add    BYTE PTR [rax],al
	...

0000000000000248 <botlish_entry_1: peek<str, int>>:
     248:	push   rbp
     249:	mov    rbp,rsp
     24c:	mov    rsi,QWORD PTR [rdx]
     24f:	mov    rdx,QWORD PTR [rdx+0x8]
     253:	call   258 <botlish_entry_1+0x10>
			254: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     258:	mov    rsp,rbp
     25b:	pop    rbp
     25c:	ret
     25d:	add    BYTE PTR [rax],al
	...

0000000000000260 <botlish_fn_2: quote_at?<str, int>>:
     260:	push   rbp
     261:	mov    rbp,rsp
     264:	sub    rsp,0x20
     268:	mov    QWORD PTR [rsp],rbx
     26c:	mov    QWORD PTR [rsp+0x8],r12
     271:	mov    QWORD PTR [rsp+0x10],r13
     276:	mov    rbx,rdx
     279:	mov    r13,rdi
     27c:	mov    rdx,QWORD PTR [rsi+0x8]
     280:	mov    r12,rsi
     283:	shl    rdx,1
     286:	mov    rax,rdx
     289:	or     rax,0x1
     28d:	mov    rcx,rbx
     290:	and    rcx,rax
     293:	test   rcx,0x1
     29a:	jne    2c4 <botlish_fn_2+0x64>
     2a0:	or     rdx,0x1
     2a4:	mov    rsi,rbx
     2a7:	mov    rdi,r13
     2aa:	call   2af <botlish_fn_2+0x4f>
			2ab: R_X86_64_PLT32	rt_int_cmp-0x4
     2af:	mov    ecx,0x2
     2b4:	test   rax,rax
     2b7:	cmovl  rcx,QWORD PTR [rip+0xa1]        # 360 <botlish_fn_2+0x100>
     2bf:	jmp    2db <botlish_fn_2+0x7b>
     2c4:	or     rdx,0x1
     2c8:	mov    ecx,0x2
     2cd:	mov    rax,rbx
     2d0:	cmp    rax,rdx
     2d3:	cmovl  rcx,QWORD PTR [rip+0x85]        # 360 <botlish_fn_2+0x100>
     2db:	mov    eax,0x6
     2e0:	cmp    rcx,0x6
     2e4:	je     2f7 <botlish_fn_2+0x97>
     2ea:	mov    eax,0x2
     2ef:	mov    r12,rax
     2f2:	jmp    344 <botlish_fn_2+0xe4>
     2f7:	mov    rdi,r13
     2fa:	mov    rsi,r12
     2fd:	mov    r12,rax
     300:	mov    rdx,rbx
     303:	call   308 <botlish_fn_2+0xa8>
			304: R_X86_64_PLT32	rt_str_char_at-0x4
     308:	test   rax,rax
     30b:	jne    32b <botlish_fn_2+0xcb>
     311:	xor    rax,rax
     314:	mov    rbx,QWORD PTR [rsp]
     318:	mov    r12,QWORD PTR [rsp+0x8]
     31d:	mov    r13,QWORD PTR [rsp+0x10]
     322:	add    rsp,0x20
     326:	mov    rsp,rbp
     329:	pop    rbp
     32a:	ret
     32b:	cmp    rax,0x114
     331:	je     341 <botlish_fn_2+0xe1>
     337:	mov    eax,0x2
     33c:	jmp    344 <botlish_fn_2+0xe4>
     341:	mov    rax,r12
     344:	mov    rbx,QWORD PTR [rsp]
     348:	mov    r12,QWORD PTR [rsp+0x8]
     34d:	mov    r13,QWORD PTR [rsp+0x10]
     352:	add    rsp,0x20
     356:	mov    rsp,rbp
     359:	pop    rbp
     35a:	ret
     35b:	add    BYTE PTR [rax],al
     35d:	add    BYTE PTR [rax],al
     35f:	add    BYTE PTR [rsi],al
     361:	add    BYTE PTR [rax],al
     363:	add    BYTE PTR [rax],al
     365:	add    BYTE PTR [rax],al
	...

0000000000000368 <botlish_entry_2: quote_at?<str, int>>:
     368:	push   rbp
     369:	mov    rbp,rsp
     36c:	mov    rsi,QWORD PTR [rdx]
     36f:	mov    rdx,QWORD PTR [rdx+0x8]
     373:	call   378 <botlish_entry_2+0x10>
			374: R_X86_64_PLT32	botlish_fn_2-0x4 ; quote_at?<str, int>
     378:	mov    rsp,rbp
     37b:	pop    rbp
     37c:	ret
     37d:	add    BYTE PTR [rax],al
	...

0000000000000380 <botlish_fn_3: scan_unquoted<str, int, int>>:
     380:	push   rbp
     381:	mov    rbp,rsp
     384:	sub    rsp,0x40
     388:	mov    QWORD PTR [rsp+0x20],rbx
     38d:	mov    QWORD PTR [rsp+0x28],r12
     392:	mov    QWORD PTR [rsp+0x30],r13
     397:	mov    QWORD PTR [rsp+0x38],r14
     39c:	mov    r14,rdi
     39f:	mov    QWORD PTR [rsp+0x18],0x0
     3a8:	mov    QWORD PTR [rsp],rsi
     3ac:	mov    r13,rsi
     3af:	mov    QWORD PTR [rsp+0x8],rdx
     3b4:	mov    rbx,rdx
     3b7:	mov    QWORD PTR [rsp+0x10],rcx
     3bc:	mov    r12,rcx
     3bf:	mov    rdx,QWORD PTR [rsi+0x8]
     3c3:	mov    r13,rsi
     3c6:	shl    rdx,1
     3c9:	or     rdx,0x1
     3cd:	mov    rax,r12
     3d0:	and    rax,rdx
     3d3:	test   rax,0x1
     3d9:	jne    3ff <botlish_fn_3+0x7f>
     3df:	mov    rsi,r12
     3e2:	mov    rdi,r14
     3e5:	call   3ea <botlish_fn_3+0x6a>
			3e6: R_X86_64_PLT32	rt_int_cmp-0x4
     3ea:	mov    ecx,0x2
     3ef:	test   rax,rax
     3f2:	cmovl  rcx,QWORD PTR [rip+0x17e]        # 578 <botlish_fn_3+0x1f8>
     3fa:	jmp    412 <botlish_fn_3+0x92>
     3ff:	mov    ecx,0x2
     404:	mov    rsi,r12
     407:	cmp    rsi,rdx
     40a:	cmovl  rcx,QWORD PTR [rip+0x166]        # 578 <botlish_fn_3+0x1f8>
     412:	cmp    rcx,0x6
     416:	je     42a <botlish_fn_3+0xaa>
     41c:	mov    rdx,rbx
     41f:	mov    rsi,r13
     422:	mov    rdi,r14
     425:	jmp    4b5 <botlish_fn_3+0x135>
     42a:	mov    rdx,r12
     42d:	mov    rsi,r13
     430:	mov    rdi,r14
     433:	call   438 <botlish_fn_3+0xb8>
			434: R_X86_64_PLT32	rt_str_char_at-0x4
     438:	test   rax,rax
     43b:	je     4cc <botlish_fn_3+0x14c>
     441:	cmp    rax,0x164
     447:	je     457 <botlish_fn_3+0xd7>
     44d:	mov    ecx,0x6
     452:	jmp    45c <botlish_fn_3+0xdc>
     457:	mov    ecx,0x2
     45c:	cmp    rcx,0x6
     460:	je     470 <botlish_fn_3+0xf0>
     466:	mov    eax,0x2
     46b:	jmp    4a2 <botlish_fn_3+0x122>
     470:	cmp    rax,0x54
     474:	je     484 <botlish_fn_3+0x104>
     47a:	mov    eax,0x6
     47f:	jmp    489 <botlish_fn_3+0x109>
     484:	mov    eax,0x2
     489:	cmp    rax,0x6
     48d:	je     49d <botlish_fn_3+0x11d>
     493:	mov    eax,0x2
     498:	jmp    4a2 <botlish_fn_3+0x122>
     49d:	mov    eax,0x6
     4a2:	cmp    rax,0x6
     4a6:	je     50f <botlish_fn_3+0x18f>
     4ac:	mov    rdx,rbx
     4af:	mov    rsi,r13
     4b2:	mov    rdi,r14
     4b5:	mov    rsi,r13
     4b8:	mov    rdi,r14
     4bb:	mov    rcx,r12
     4be:	call   4c3 <botlish_fn_3+0x143>
			4bf: R_X86_64_PLT32	rt_substr-0x4
     4c3:	test   rax,rax
     4c6:	jne    4ef <botlish_fn_3+0x16f>
     4cc:	xor    rdx,rdx
     4cf:	mov    rax,rdx
     4d2:	mov    rbx,QWORD PTR [rsp+0x20]
     4d7:	mov    r12,QWORD PTR [rsp+0x28]
     4dc:	mov    r13,QWORD PTR [rsp+0x30]
     4e1:	mov    r14,QWORD PTR [rsp+0x38]
     4e6:	add    rsp,0x40
     4ea:	mov    rsp,rbp
     4ed:	pop    rbp
     4ee:	ret
     4ef:	mov    rdx,r12
     4f2:	mov    rbx,QWORD PTR [rsp+0x20]
     4f7:	mov    r12,QWORD PTR [rsp+0x28]
     4fc:	mov    r13,QWORD PTR [rsp+0x30]
     501:	mov    r14,QWORD PTR [rsp+0x38]
     506:	add    rsp,0x40
     50a:	mov    rsp,rbp
     50d:	pop    rbp
     50e:	ret
     50f:	mov    QWORD PTR [rsp+0x18],0x3
     518:	mov    rdx,r12
     51b:	test   rdx,0x1
     522:	je     545 <botlish_fn_3+0x1c5>
     528:	mov    rdx,r12
     52b:	mov    rax,rdx
     52e:	add    rax,0x2
     532:	seto   cl
     535:	test   cl,cl
     537:	jne    545 <botlish_fn_3+0x1c5>
     53d:	mov    rsi,r13
     540:	jmp    558 <botlish_fn_3+0x1d8>
     545:	mov    edx,0x3
     54a:	mov    rsi,r12
     54d:	mov    rdi,r14
     550:	call   555 <botlish_fn_3+0x1d5>
			551: R_X86_64_PLT32	rt_int_add-0x4
     555:	mov    rsi,r13
     558:	mov    rsi,r13
     55b:	mov    QWORD PTR [rsp],rsi
     55f:	mov    rdx,rbx
     562:	mov    QWORD PTR [rsp+0x8],rdx
     567:	mov    QWORD PTR [rsp+0x10],rax
     56c:	mov    r12,rax
     56f:	jmp    3bf <botlish_fn_3+0x3f>
     574:	add    BYTE PTR [rax],al
     576:	add    BYTE PTR [rax],al
     578:	(bad)
     579:	add    BYTE PTR [rax],al
     57b:	add    BYTE PTR [rax],al
     57d:	add    BYTE PTR [rax],al
	...

0000000000000580 <botlish_entry_3: scan_unquoted<str, int, int>>:
     580:	push   rbp
     581:	mov    rbp,rsp
     584:	ud2

0000000000000586 <botlish_fn_4: scan_quoted<str, int, str>>:
     586:	push   rbp
     587:	mov    rbp,rsp
     58a:	sub    rsp,0xb0
     591:	mov    QWORD PTR [rsp+0x80],rbx
     599:	mov    QWORD PTR [rsp+0x88],r12
     5a1:	mov    QWORD PTR [rsp+0x90],r13
     5a9:	mov    QWORD PTR [rsp+0x98],r14
     5b1:	mov    QWORD PTR [rsp+0xa0],r15
     5b9:	mov    r15,rdi
     5bc:	mov    QWORD PTR [rsp+0x18],0x0
     5c5:	mov    QWORD PTR [rsp+0x20],0x0
     5ce:	mov    QWORD PTR [rsp],rsi
     5d2:	mov    QWORD PTR [rsp+0x8],rdx
     5d7:	mov    QWORD PTR [rsp+0x10],rcx
     5dc:	mov    r13,rcx
     5df:	lea    r12,[rsp+0x58]
     5e4:	mov    rbx,rsi
     5e7:	mov    QWORD PTR [rsp+0x78],rdx
     5ec:	mov    rdx,QWORD PTR [rsp+0x78]
     5f1:	mov    rsi,rbx
     5f4:	mov    rdi,r15
     5f7:	call   5fc <botlish_fn_4+0x76>
			5f8: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     5fc:	test   rax,rax
     5ff:	je     89b <botlish_fn_4+0x315>
     605:	mov    QWORD PTR [rsp+0x18],rax
     60a:	mov    r14,rax
     60d:	mov    rdx,QWORD PTR [rsp+0x78]
     612:	mov    rsi,rbx
     615:	mov    rdi,r15
     618:	call   61d <botlish_fn_4+0x97>
			619: R_X86_64_PLT32	botlish_fn_2-0x4 ; quote_at?<str, int>
     61d:	test   rax,rax
     620:	je     89b <botlish_fn_4+0x315>
     626:	cmp    rax,0x6
     62a:	je     6e3 <botlish_fn_4+0x15d>
     630:	mov    QWORD PTR [rsp+0x20],0x3
     639:	mov    rsi,QWORD PTR [rsp+0x78]
     63e:	test   rsi,0x1
     645:	je     66f <botlish_fn_4+0xe9>
     64b:	mov    rsi,QWORD PTR [rsp+0x78]
     650:	mov    rcx,rsi
     653:	add    rcx,0x2
     657:	seto   dl
     65a:	test   dl,dl
     65c:	jne    66f <botlish_fn_4+0xe9>
     662:	mov    rsi,rcx
     665:	mov    QWORD PTR [rsp+0x78],rcx
     66a:	jmp    689 <botlish_fn_4+0x103>
     66f:	mov    edx,0x3
     674:	mov    rsi,QWORD PTR [rsp+0x78]
     679:	mov    rdi,r15
     67c:	call   681 <botlish_fn_4+0xfb>
			67d: R_X86_64_PLT32	rt_int_add-0x4
     681:	mov    rsi,rax
     684:	mov    QWORD PTR [rsp+0x78],rax
     689:	mov    QWORD PTR [rsp+0x8],rsi
     68e:	mov    QWORD PTR [rsp+0x58],0x0
     697:	mov    QWORD PTR [rsp+0x60],r13
     69c:	mov    QWORD PTR [rsp+0x68],0x0
     6a5:	mov    QWORD PTR [rsp+0x70],r14
     6aa:	mov    esi,0x2
     6af:	mov    edx,0x4
     6b4:	mov    rcx,r12
     6b7:	mov    rdi,r15
     6ba:	call   6bf <botlish_fn_4+0x139>
			6bb: R_X86_64_PLT32	rt_construct-0x4
     6bf:	test   rax,rax
     6c2:	je     89b <botlish_fn_4+0x315>
     6c8:	mov    QWORD PTR [rsp],rbx
     6cc:	mov    rsi,QWORD PTR [rsp+0x78]
     6d1:	mov    QWORD PTR [rsp+0x8],rsi
     6d6:	mov    QWORD PTR [rsp+0x10],rax
     6db:	mov    r13,rax
     6de:	jmp    5ec <botlish_fn_4+0x66>
     6e3:	mov    QWORD PTR [rsp+0x20],0x3
     6ec:	mov    rsi,QWORD PTR [rsp+0x78]
     6f1:	test   rsi,0x1
     6f8:	je     715 <botlish_fn_4+0x18f>
     6fe:	mov    rsi,QWORD PTR [rsp+0x78]
     703:	mov    rdx,rsi
     706:	add    rdx,0x2
     70a:	seto   al
     70d:	test   al,al
     70f:	je     72a <botlish_fn_4+0x1a4>
     715:	mov    edx,0x3
     71a:	mov    rsi,QWORD PTR [rsp+0x78]
     71f:	mov    rdi,r15
     722:	call   727 <botlish_fn_4+0x1a1>
			723: R_X86_64_PLT32	rt_int_add-0x4
     727:	mov    rdx,rax
     72a:	mov    rsi,rbx
     72d:	mov    rdi,r15
     730:	call   735 <botlish_fn_4+0x1af>
			731: R_X86_64_PLT32	botlish_fn_2-0x4 ; quote_at?<str, int>
     735:	test   rax,rax
     738:	je     89b <botlish_fn_4+0x315>
     73e:	cmp    rax,0x6
     742:	je     801 <botlish_fn_4+0x27b>
     748:	xor    rsi,rsi
     74b:	lea    rcx,[rsp+0x48]
     750:	mov    QWORD PTR [rsp+0x48],0x0
     759:	mov    QWORD PTR [rsp+0x50],r13
     75e:	mov    edx,0x2
     763:	mov    rdi,r15
     766:	call   76b <botlish_fn_4+0x1e5>
			767: R_X86_64_PLT32	rt_construct-0x4
     76b:	test   rax,rax
     76e:	je     89b <botlish_fn_4+0x315>
     774:	mov    QWORD PTR [rsp],rax
     778:	mov    r12,rax
     77b:	mov    QWORD PTR [rsp+0x10],0x3
     784:	mov    rsi,QWORD PTR [rsp+0x78]
     789:	test   rsi,0x1
     790:	je     7b5 <botlish_fn_4+0x22f>
     796:	mov    rsi,QWORD PTR [rsp+0x78]
     79b:	mov    rdx,rsi
     79e:	add    rdx,0x2
     7a2:	seto   al
     7a5:	test   al,al
     7a7:	jne    7b5 <botlish_fn_4+0x22f>
     7ad:	mov    rax,r12
     7b0:	jmp    7cd <botlish_fn_4+0x247>
     7b5:	mov    edx,0x3
     7ba:	mov    rsi,QWORD PTR [rsp+0x78]
     7bf:	mov    rdi,r15
     7c2:	call   7c7 <botlish_fn_4+0x241>
			7c3: R_X86_64_PLT32	rt_int_add-0x4
     7c7:	mov    rdx,rax
     7ca:	mov    rax,r12
     7cd:	mov    rbx,QWORD PTR [rsp+0x80]
     7d5:	mov    r12,QWORD PTR [rsp+0x88]
     7dd:	mov    r13,QWORD PTR [rsp+0x90]
     7e5:	mov    r14,QWORD PTR [rsp+0x98]
     7ed:	mov    r15,QWORD PTR [rsp+0xa0]
     7f5:	add    rsp,0xb0
     7fc:	mov    rsp,rbp
     7ff:	pop    rbp
     800:	ret
     801:	mov    QWORD PTR [rsp+0x20],0x5
     80a:	mov    rsi,QWORD PTR [rsp+0x78]
     80f:	test   rsi,0x1
     816:	je     840 <botlish_fn_4+0x2ba>
     81c:	mov    rsi,QWORD PTR [rsp+0x78]
     821:	mov    rcx,rsi
     824:	add    rcx,0x4
     828:	seto   al
     82b:	test   al,al
     82d:	jne    840 <botlish_fn_4+0x2ba>
     833:	mov    rsi,rcx
     836:	mov    QWORD PTR [rsp+0x78],rcx
     83b:	jmp    85a <botlish_fn_4+0x2d4>
     840:	mov    edx,0x5
     845:	mov    rsi,QWORD PTR [rsp+0x78]
     84a:	mov    rdi,r15
     84d:	call   852 <botlish_fn_4+0x2cc>
			84e: R_X86_64_PLT32	rt_int_add-0x4
     852:	mov    rsi,rax
     855:	mov    QWORD PTR [rsp+0x78],rax
     85a:	mov    QWORD PTR [rsp+0x8],rsi
     85f:	lea    rcx,[rsp+0x28]
     864:	mov    QWORD PTR [rsp+0x28],0x0
     86d:	mov    QWORD PTR [rsp+0x30],r13
     872:	mov    QWORD PTR [rsp+0x38],0x0
     87b:	mov    QWORD PTR [rsp+0x40],r14
     880:	mov    esi,0x2
     885:	mov    edx,0x4
     88a:	mov    rdi,r15
     88d:	call   892 <botlish_fn_4+0x30c>
			88e: R_X86_64_PLT32	rt_construct-0x4
     892:	test   rax,rax
     895:	jne    8d5 <botlish_fn_4+0x34f>
     89b:	xor    rdx,rdx
     89e:	mov    rax,rdx
     8a1:	mov    rbx,QWORD PTR [rsp+0x80]
     8a9:	mov    r12,QWORD PTR [rsp+0x88]
     8b1:	mov    r13,QWORD PTR [rsp+0x90]
     8b9:	mov    r14,QWORD PTR [rsp+0x98]
     8c1:	mov    r15,QWORD PTR [rsp+0xa0]
     8c9:	add    rsp,0xb0
     8d0:	mov    rsp,rbp
     8d3:	pop    rbp
     8d4:	ret
     8d5:	mov    QWORD PTR [rsp],rbx
     8d9:	mov    rsi,QWORD PTR [rsp+0x78]
     8de:	mov    QWORD PTR [rsp+0x8],rsi
     8e3:	mov    QWORD PTR [rsp+0x10],rax
     8e8:	mov    r13,rax
     8eb:	jmp    5ec <botlish_fn_4+0x66>

00000000000008f0 <botlish_entry_4: scan_quoted<str, int, str>>:
     8f0:	push   rbp
     8f1:	mov    rbp,rsp
     8f4:	ud2

00000000000008f6 <botlish_fn_5: scan_field<str, int>>:
     8f6:	push   rbp
     8f7:	mov    rbp,rsp
     8fa:	sub    rsp,0x40
     8fe:	mov    QWORD PTR [rsp+0x20],rbx
     903:	mov    QWORD PTR [rsp+0x28],r12
     908:	mov    QWORD PTR [rsp+0x30],r13
     90d:	mov    r12,rdi
     910:	mov    r13,rdx
     913:	mov    QWORD PTR [rsp+0x10],0x0
     91c:	mov    QWORD PTR [rsp],rsi
     920:	mov    rbx,rsi
     923:	mov    QWORD PTR [rsp+0x8],rdx
     928:	mov    rdx,r13
     92b:	mov    rsi,rbx
     92e:	mov    rdi,r12
     931:	call   936 <botlish_fn_5+0x40>
			932: R_X86_64_PLT32	botlish_fn_2-0x4 ; quote_at?<str, int>
     936:	test   rax,rax
     939:	je     9ea <botlish_fn_5+0xf4>
     93f:	cmp    rax,0x6
     943:	je     97b <botlish_fn_5+0x85>
     949:	mov    rcx,r13
     94c:	mov    rsi,rbx
     94f:	mov    rdi,r12
     952:	mov    rdx,rcx
     955:	call   95a <botlish_fn_5+0x64>
			956: R_X86_64_PLT32	botlish_fn_3-0x4 ; scan_unquoted<str, int, int>
     95a:	test   rax,rax
     95d:	je     9ea <botlish_fn_5+0xf4>
     963:	mov    rbx,QWORD PTR [rsp+0x20]
     968:	mov    r12,QWORD PTR [rsp+0x28]
     96d:	mov    r13,QWORD PTR [rsp+0x30]
     972:	add    rsp,0x40
     976:	mov    rsp,rbp
     979:	pop    rbp
     97a:	ret
     97b:	mov    rcx,r13
     97e:	mov    QWORD PTR [rsp+0x10],0x3
     987:	test   rcx,0x1
     98e:	jne    99c <botlish_fn_5+0xa6>
     994:	mov    r13,rcx
     997:	jmp    9b1 <botlish_fn_5+0xbb>
     99c:	mov    rdx,rcx
     99f:	add    rdx,0x2
     9a3:	mov    r13,rcx
     9a6:	seto   al
     9a9:	test   al,al
     9ab:	je     9c4 <botlish_fn_5+0xce>
     9b1:	mov    edx,0x3
     9b6:	mov    rsi,r13
     9b9:	mov    rdi,r12
     9bc:	call   9c1 <botlish_fn_5+0xcb>
			9bd: R_X86_64_PLT32	rt_int_add-0x4
     9c1:	mov    rdx,rax
     9c4:	mov    QWORD PTR [rsp+0x8],rdx
     9c9:	mov    rdi,r12
     9cc:	mov    rax,QWORD PTR [rdi+0x10]
     9d0:	mov    rcx,QWORD PTR [rax+0x8]
     9d4:	mov    QWORD PTR [rsp+0x10],rcx
     9d9:	mov    rsi,rbx
     9dc:	call   9e1 <botlish_fn_5+0xeb>
			9dd: R_X86_64_PLT32	botlish_fn_4-0x4 ; scan_quoted<str, int, str>
     9e1:	test   rax,rax
     9e4:	jne    a08 <botlish_fn_5+0x112>
     9ea:	xor    rdx,rdx
     9ed:	mov    rax,rdx
     9f0:	mov    rbx,QWORD PTR [rsp+0x20]
     9f5:	mov    r12,QWORD PTR [rsp+0x28]
     9fa:	mov    r13,QWORD PTR [rsp+0x30]
     9ff:	add    rsp,0x40
     a03:	mov    rsp,rbp
     a06:	pop    rbp
     a07:	ret
     a08:	mov    rbx,QWORD PTR [rsp+0x20]
     a0d:	mov    r12,QWORD PTR [rsp+0x28]
     a12:	mov    r13,QWORD PTR [rsp+0x30]
     a17:	add    rsp,0x40
     a1b:	mov    rsp,rbp
     a1e:	pop    rbp
     a1f:	ret

0000000000000a20 <botlish_entry_5: scan_field<str, int>>:
     a20:	push   rbp
     a21:	mov    rbp,rsp
     a24:	ud2
	...

0000000000000a28 <botlish_fn_6: scan_record<str, int, List[never]>>:
     a28:	push   rbp
     a29:	mov    rbp,rsp
     a2c:	sub    rsp,0x80
     a33:	mov    QWORD PTR [rsp+0x50],rbx
     a38:	mov    QWORD PTR [rsp+0x58],r12
     a3d:	mov    QWORD PTR [rsp+0x60],r13
     a42:	mov    QWORD PTR [rsp+0x68],r14
     a47:	mov    QWORD PTR [rsp+0x70],r15
     a4c:	mov    r12,rdi
     a4f:	mov    QWORD PTR [rsp+0x18],0x0
     a58:	mov    QWORD PTR [rsp+0x20],0x0
     a61:	mov    QWORD PTR [rsp],rsi
     a65:	mov    r13,rsi
     a68:	mov    QWORD PTR [rsp+0x8],rdx
     a6d:	mov    QWORD PTR [rsp+0x10],rcx
     a72:	mov    r14,rcx
     a75:	mov    rsi,r13
     a78:	mov    rdi,r12
     a7b:	call   a80 <botlish_fn_6+0x58>
			a7c: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     a80:	mov    rbx,rdx
     a83:	test   rax,rax
     a86:	je     cb7 <botlish_fn_6+0x28f>
     a8c:	mov    QWORD PTR [rsp+0x8],rax
     a91:	mov    rdx,rbx
     a94:	mov    r15,rax
     a97:	mov    QWORD PTR [rsp+0x18],rdx
     a9c:	mov    rsi,r13
     a9f:	mov    rdx,QWORD PTR [rsi+0x8]
     aa3:	shl    rdx,1
     aa6:	mov    rax,rdx
     aa9:	or     rax,0x1
     aad:	mov    rcx,rbx
     ab0:	and    rcx,rax
     ab3:	test   rcx,0x1
     aba:	jne    ae4 <botlish_fn_6+0xbc>
     ac0:	or     rdx,0x1
     ac4:	mov    rsi,rbx
     ac7:	mov    rdi,r12
     aca:	call   acf <botlish_fn_6+0xa7>
			acb: R_X86_64_PLT32	rt_int_cmp-0x4
     acf:	mov    ecx,0x2
     ad4:	test   rax,rax
     ad7:	cmovl  rcx,QWORD PTR [rip+0x229]        # d08 <botlish_fn_6+0x2e0>
     adf:	jmp    afb <botlish_fn_6+0xd3>
     ae4:	or     rdx,0x1
     ae8:	mov    ecx,0x2
     aed:	mov    rax,rbx
     af0:	cmp    rax,rdx
     af3:	cmovl  rcx,QWORD PTR [rip+0x20d]        # d08 <botlish_fn_6+0x2e0>
     afb:	cmp    rcx,0x6
     aff:	je     b13 <botlish_fn_6+0xeb>
     b05:	mov    rdx,r15
     b08:	mov    rsi,r14
     b0b:	mov    rdi,r12
     b0e:	jmp    b49 <botlish_fn_6+0x121>
     b13:	mov    rdx,rbx
     b16:	mov    rsi,r13
     b19:	mov    rdi,r12
     b1c:	call   b21 <botlish_fn_6+0xf9>
			b1d: R_X86_64_PLT32	rt_str_char_at-0x4
     b21:	test   rax,rax
     b24:	je     cb7 <botlish_fn_6+0x28f>
     b2a:	cmp    rax,0x164
     b30:	je     c0e <botlish_fn_6+0x1e6>
     b36:	cmp    rax,0x54
     b3a:	je     b82 <botlish_fn_6+0x15a>
     b40:	mov    rdx,r15
     b43:	mov    rsi,r14
     b46:	mov    rdi,r12
     b49:	mov    rdi,r12
     b4c:	call   b51 <botlish_fn_6+0x129>
			b4d: R_X86_64_PLT32	rt_list_append-0x4
     b51:	test   rax,rax
     b54:	je     cb7 <botlish_fn_6+0x28f>
     b5a:	mov    rdx,rbx
     b5d:	mov    rbx,QWORD PTR [rsp+0x50]
     b62:	mov    r12,QWORD PTR [rsp+0x58]
     b67:	mov    r13,QWORD PTR [rsp+0x60]
     b6c:	mov    r14,QWORD PTR [rsp+0x68]
     b71:	mov    r15,QWORD PTR [rsp+0x70]
     b76:	add    rsp,0x80
     b7d:	mov    rsp,rbp
     b80:	pop    rbp
     b81:	ret
     b82:	mov    rdx,r15
     b85:	mov    rsi,r14
     b88:	mov    rdi,r12
     b8b:	call   b90 <botlish_fn_6+0x168>
			b8c: R_X86_64_PLT32	rt_list_append-0x4
     b90:	test   rax,rax
     b93:	je     cb7 <botlish_fn_6+0x28f>
     b99:	mov    QWORD PTR [rsp],rax
     b9d:	mov    r13,rax
     ba0:	mov    QWORD PTR [rsp+0x8],0x3
     ba9:	mov    rdx,rbx
     bac:	test   rdx,0x1
     bb3:	je     bd3 <botlish_fn_6+0x1ab>
     bb9:	mov    rdx,rbx
     bbc:	add    rdx,0x2
     bc0:	seto   al
     bc3:	test   al,al
     bc5:	jne    bd3 <botlish_fn_6+0x1ab>
     bcb:	mov    rax,r13
     bce:	jmp    be9 <botlish_fn_6+0x1c1>
     bd3:	mov    edx,0x3
     bd8:	mov    rsi,rbx
     bdb:	mov    rdi,r12
     bde:	call   be3 <botlish_fn_6+0x1bb>
			bdf: R_X86_64_PLT32	rt_int_add-0x4
     be3:	mov    rdx,rax
     be6:	mov    rax,r13
     be9:	mov    rbx,QWORD PTR [rsp+0x50]
     bee:	mov    r12,QWORD PTR [rsp+0x58]
     bf3:	mov    r13,QWORD PTR [rsp+0x60]
     bf8:	mov    r14,QWORD PTR [rsp+0x68]
     bfd:	mov    r15,QWORD PTR [rsp+0x70]
     c02:	add    rsp,0x80
     c09:	mov    rsp,rbp
     c0c:	pop    rbp
     c0d:	ret
     c0e:	mov    rsi,rbx
     c11:	mov    ebx,0x3
     c16:	mov    QWORD PTR [rsp+0x20],0x3
     c1f:	test   rsi,0x1
     c26:	je     c3e <botlish_fn_6+0x216>
     c2c:	mov    rdx,rsi
     c2f:	add    rdx,0x2
     c33:	seto   al
     c36:	test   al,al
     c38:	je     c4c <botlish_fn_6+0x224>
     c3e:	mov    rdx,rbx
     c41:	mov    rdi,r12
     c44:	call   c49 <botlish_fn_6+0x221>
			c45: R_X86_64_PLT32	rt_int_add-0x4
     c49:	mov    rdx,rax
     c4c:	mov    QWORD PTR [rsp+0x18],rdx
     c51:	mov    QWORD PTR [rsp+0x48],rdx
     c56:	lea    rcx,[rsp+0x28]
     c5b:	mov    QWORD PTR [rsp+0x28],0x0
     c64:	mov    rsi,r14
     c67:	mov    QWORD PTR [rsp+0x30],rsi
     c6c:	mov    QWORD PTR [rsp+0x38],0x2
     c75:	mov    rdx,r15
     c78:	mov    QWORD PTR [rsp+0x40],rdx
     c7d:	mov    edx,0x4
     c82:	mov    rsi,rbx
     c85:	mov    rdi,r12
     c88:	call   c8d <botlish_fn_6+0x265>
			c89: R_X86_64_PLT32	rt_construct-0x4
     c8d:	test   rax,rax
     c90:	je     cb7 <botlish_fn_6+0x28f>
     c96:	mov    QWORD PTR [rsp+0x8],rax
     c9b:	mov    rcx,rax
     c9e:	mov    rdx,QWORD PTR [rsp+0x48]
     ca3:	mov    rsi,r13
     ca6:	mov    rdi,r12
     ca9:	call   cae <botlish_fn_6+0x286>
			caa: R_X86_64_PLT32	botlish_fn_7-0x4 ; scan_record<str, int, List[str]>
     cae:	test   rax,rax
     cb1:	jne    ce2 <botlish_fn_6+0x2ba>
     cb7:	xor    rdx,rdx
     cba:	mov    rax,rdx
     cbd:	mov    rbx,QWORD PTR [rsp+0x50]
     cc2:	mov    r12,QWORD PTR [rsp+0x58]
     cc7:	mov    r13,QWORD PTR [rsp+0x60]
     ccc:	mov    r14,QWORD PTR [rsp+0x68]
     cd1:	mov    r15,QWORD PTR [rsp+0x70]
     cd6:	add    rsp,0x80
     cdd:	mov    rsp,rbp
     ce0:	pop    rbp
     ce1:	ret
     ce2:	mov    rbx,QWORD PTR [rsp+0x50]
     ce7:	mov    r12,QWORD PTR [rsp+0x58]
     cec:	mov    r13,QWORD PTR [rsp+0x60]
     cf1:	mov    r14,QWORD PTR [rsp+0x68]
     cf6:	mov    r15,QWORD PTR [rsp+0x70]
     cfb:	add    rsp,0x80
     d02:	mov    rsp,rbp
     d05:	pop    rbp
     d06:	ret
     d07:	add    BYTE PTR [rsi],al
     d09:	add    BYTE PTR [rax],al
     d0b:	add    BYTE PTR [rax],al
     d0d:	add    BYTE PTR [rax],al
	...

0000000000000d10 <botlish_entry_6: scan_record<str, int, List[never]>>:
     d10:	push   rbp
     d11:	mov    rbp,rsp
     d14:	ud2
	...

0000000000000d18 <botlish_fn_7: scan_record<str, int, List[str]>>:
     d18:	push   rbp
     d19:	mov    rbp,rsp
     d1c:	sub    rsp,0xc0
     d23:	mov    QWORD PTR [rsp+0x90],rbx
     d2b:	mov    QWORD PTR [rsp+0x98],r12
     d33:	mov    QWORD PTR [rsp+0xa0],r13
     d3b:	mov    QWORD PTR [rsp+0xa8],r14
     d43:	mov    QWORD PTR [rsp+0xb0],r15
     d4b:	mov    r15,rdi
     d4e:	mov    QWORD PTR [rsp+0x18],0x0
     d57:	mov    QWORD PTR [rsp+0x20],0x0
     d60:	mov    QWORD PTR [rsp],rsi
     d64:	mov    QWORD PTR [rsp+0x8],rdx
     d69:	mov    QWORD PTR [rsp+0x88],rdx
     d71:	mov    QWORD PTR [rsp+0x10],rcx
     d76:	mov    r13,rcx
     d79:	mov    rbx,rsi
     d7c:	mov    rsi,rbx
     d7f:	mov    rdi,r15
     d82:	call   d87 <botlish_fn_7+0x6f>
			d83: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     d87:	mov    r12,rdx
     d8a:	test   rax,rax
     d8d:	je     fe6 <botlish_fn_7+0x2ce>
     d93:	mov    QWORD PTR [rsp+0x8],rax
     d98:	mov    rdx,r12
     d9b:	mov    r14,rax
     d9e:	mov    QWORD PTR [rsp+0x18],rdx
     da3:	mov    rdx,QWORD PTR [rbx+0x8]
     da7:	shl    rdx,1
     daa:	or     rdx,0x1
     dae:	mov    rax,r12
     db1:	and    rax,rdx
     db4:	test   rax,0x1
     dba:	jne    de0 <botlish_fn_7+0xc8>
     dc0:	mov    rsi,r12
     dc3:	mov    rdi,r15
     dc6:	call   dcb <botlish_fn_7+0xb3>
			dc7: R_X86_64_PLT32	rt_int_cmp-0x4
     dcb:	mov    ecx,0x2
     dd0:	test   rax,rax
     dd3:	cmovl  rcx,QWORD PTR [rip+0x265]        # 1040 <botlish_fn_7+0x328>
     ddb:	jmp    df3 <botlish_fn_7+0xdb>
     de0:	mov    ecx,0x2
     de5:	mov    rax,r12
     de8:	cmp    rax,rdx
     deb:	cmovl  rcx,QWORD PTR [rip+0x24d]        # 1040 <botlish_fn_7+0x328>
     df3:	cmp    rcx,0x6
     df7:	jne    e2a <botlish_fn_7+0x112>
     dfd:	mov    rdx,r12
     e00:	mov    rsi,rbx
     e03:	mov    rdi,r15
     e06:	call   e0b <botlish_fn_7+0xf3>
			e07: R_X86_64_PLT32	rt_str_char_at-0x4
     e0b:	test   rax,rax
     e0e:	je     fe6 <botlish_fn_7+0x2ce>
     e14:	cmp    rax,0x164
     e1a:	je     f60 <botlish_fn_7+0x248>
     e20:	cmp    rax,0x54
     e24:	je     ea0 <botlish_fn_7+0x188>
     e2a:	lea    rcx,[rsp+0x68]
     e2f:	mov    QWORD PTR [rsp+0x68],0x0
     e38:	mov    QWORD PTR [rsp+0x70],r13
     e3d:	mov    QWORD PTR [rsp+0x78],0x2
     e46:	mov    QWORD PTR [rsp+0x80],r14
     e4e:	mov    esi,0x1
     e53:	mov    edx,0x4
     e58:	mov    rdi,r15
     e5b:	call   e60 <botlish_fn_7+0x148>
			e5c: R_X86_64_PLT32	rt_construct-0x4
     e60:	test   rax,rax
     e63:	je     fe6 <botlish_fn_7+0x2ce>
     e69:	mov    rdx,r12
     e6c:	mov    rbx,QWORD PTR [rsp+0x90]
     e74:	mov    r12,QWORD PTR [rsp+0x98]
     e7c:	mov    r13,QWORD PTR [rsp+0xa0]
     e84:	mov    r14,QWORD PTR [rsp+0xa8]
     e8c:	mov    r15,QWORD PTR [rsp+0xb0]
     e94:	add    rsp,0xc0
     e9b:	mov    rsp,rbp
     e9e:	pop    rbp
     e9f:	ret
     ea0:	lea    rcx,[rsp+0x48]
     ea5:	mov    QWORD PTR [rsp+0x48],0x0
     eae:	mov    QWORD PTR [rsp+0x50],r13
     eb3:	mov    QWORD PTR [rsp+0x58],0x2
     ebc:	mov    QWORD PTR [rsp+0x60],r14
     ec1:	mov    esi,0x1
     ec6:	mov    edx,0x4
     ecb:	mov    rdi,r15
     ece:	call   ed3 <botlish_fn_7+0x1bb>
			ecf: R_X86_64_PLT32	rt_construct-0x4
     ed3:	test   rax,rax
     ed6:	je     fe6 <botlish_fn_7+0x2ce>
     edc:	mov    QWORD PTR [rsp],rax
     ee0:	mov    r13,rax
     ee3:	mov    QWORD PTR [rsp+0x8],0x3
     eec:	mov    rdx,r12
     eef:	test   rdx,0x1
     ef6:	je     f16 <botlish_fn_7+0x1fe>
     efc:	mov    rdx,r12
     eff:	add    rdx,0x2
     f03:	seto   al
     f06:	test   al,al
     f08:	jne    f16 <botlish_fn_7+0x1fe>
     f0e:	mov    rax,r13
     f11:	jmp    f2c <botlish_fn_7+0x214>
     f16:	mov    edx,0x3
     f1b:	mov    rsi,r12
     f1e:	mov    rdi,r15
     f21:	call   f26 <botlish_fn_7+0x20e>
			f22: R_X86_64_PLT32	rt_int_add-0x4
     f26:	mov    rdx,rax
     f29:	mov    rax,r13
     f2c:	mov    rbx,QWORD PTR [rsp+0x90]
     f34:	mov    r12,QWORD PTR [rsp+0x98]
     f3c:	mov    r13,QWORD PTR [rsp+0xa0]
     f44:	mov    r14,QWORD PTR [rsp+0xa8]
     f4c:	mov    r15,QWORD PTR [rsp+0xb0]
     f54:	add    rsp,0xc0
     f5b:	mov    rsp,rbp
     f5e:	pop    rbp
     f5f:	ret
     f60:	mov    rsi,r12
     f63:	mov    r12d,0x3
     f69:	mov    QWORD PTR [rsp+0x20],0x3
     f72:	test   rsi,0x1
     f79:	je     f91 <botlish_fn_7+0x279>
     f7f:	mov    rdx,rsi
     f82:	add    rdx,0x2
     f86:	seto   al
     f89:	test   al,al
     f8b:	je     f9f <botlish_fn_7+0x287>
     f91:	mov    rdx,r12
     f94:	mov    rdi,r15
     f97:	call   f9c <botlish_fn_7+0x284>
			f98: R_X86_64_PLT32	rt_int_add-0x4
     f9c:	mov    rdx,rax
     f9f:	mov    QWORD PTR [rsp+0x18],rdx
     fa4:	mov    QWORD PTR [rsp+0x88],rdx
     fac:	lea    rcx,[rsp+0x28]
     fb1:	mov    QWORD PTR [rsp+0x28],0x0
     fba:	mov    QWORD PTR [rsp+0x30],r13
     fbf:	mov    QWORD PTR [rsp+0x38],0x2
     fc8:	mov    QWORD PTR [rsp+0x40],r14
     fcd:	mov    edx,0x4
     fd2:	mov    rsi,r12
     fd5:	mov    rdi,r15
     fd8:	call   fdd <botlish_fn_7+0x2c5>
			fd9: R_X86_64_PLT32	rt_construct-0x4
     fdd:	test   rax,rax
     fe0:	jne    1020 <botlish_fn_7+0x308>
     fe6:	xor    rdx,rdx
     fe9:	mov    rax,rdx
     fec:	mov    rbx,QWORD PTR [rsp+0x90]
     ff4:	mov    r12,QWORD PTR [rsp+0x98]
     ffc:	mov    r13,QWORD PTR [rsp+0xa0]
    1004:	mov    r14,QWORD PTR [rsp+0xa8]
    100c:	mov    r15,QWORD PTR [rsp+0xb0]
    1014:	add    rsp,0xc0
    101b:	mov    rsp,rbp
    101e:	pop    rbp
    101f:	ret
    1020:	mov    QWORD PTR [rsp],rbx
    1024:	mov    rdx,QWORD PTR [rsp+0x88]
    102c:	mov    QWORD PTR [rsp+0x8],rdx
    1031:	mov    QWORD PTR [rsp+0x10],rax
    1036:	mov    r13,rax
    1039:	jmp    d7c <botlish_fn_7+0x64>
    103e:	add    BYTE PTR [rax],al
    1040:	(bad)
    1041:	add    BYTE PTR [rax],al
    1043:	add    BYTE PTR [rax],al
    1045:	add    BYTE PTR [rax],al
	...

0000000000001048 <botlish_entry_7: scan_record<str, int, List[str]>>:
    1048:	push   rbp
    1049:	mov    rbp,rsp
    104c:	ud2

000000000000104e <botlish_fn_8: scan_records<str, int, List[never]>>:
    104e:	push   rbp
    104f:	mov    rbp,rsp
    1052:	sub    rsp,0x60
    1056:	mov    QWORD PTR [rsp+0x40],rbx
    105b:	mov    QWORD PTR [rsp+0x48],r12
    1060:	mov    QWORD PTR [rsp+0x50],r13
    1065:	mov    QWORD PTR [rsp+0x58],r14
    106a:	mov    r12,rdi
    106d:	mov    QWORD PTR [rsp+0x18],0x0
    1076:	mov    QWORD PTR [rsp],rsi
    107a:	mov    QWORD PTR [rsp+0x8],rdx
    107f:	mov    QWORD PTR [rsp+0x10],rcx
    1084:	mov    r13,rcx
    1087:	mov    rax,QWORD PTR [rsi+0x8]
    108b:	mov    rbx,rsi
    108e:	mov    rcx,rdx
    1091:	sar    rcx,1
    1094:	mov    r14,rdx
    1097:	shl    rax,1
    109a:	or     rax,0x1
    109e:	sar    rax,1
    10a1:	cmp    rcx,rax
    10a4:	jge    1188 <botlish_fn_8+0x13a>
    10aa:	xor    rdx,rdx
    10ad:	mov    rdi,r12
    10b0:	mov    rsi,rdx
    10b3:	call   10b8 <botlish_fn_8+0x6a>
			10b4: R_X86_64_PLT32	rt_list_new-0x4
    10b8:	test   rax,rax
    10bb:	je     114b <botlish_fn_8+0xfd>
    10c1:	mov    QWORD PTR [rsp+0x18],rax
    10c6:	mov    rcx,rax
    10c9:	mov    rdx,r14
    10cc:	mov    rsi,rbx
    10cf:	mov    rdi,r12
    10d2:	call   10d7 <botlish_fn_8+0x89>
			10d3: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    10d7:	test   rax,rax
    10da:	je     114b <botlish_fn_8+0xfd>
    10e0:	mov    QWORD PTR [rsp+0x8],rax
    10e5:	mov    QWORD PTR [rsp+0x18],rdx
    10ea:	mov    r14,rdx
    10ed:	lea    rcx,[rsp+0x20]
    10f2:	mov    QWORD PTR [rsp+0x20],0x0
    10fb:	mov    rdx,r13
    10fe:	mov    QWORD PTR [rsp+0x28],rdx
    1103:	mov    QWORD PTR [rsp+0x30],0x2
    110c:	mov    QWORD PTR [rsp+0x38],rax
    1111:	mov    esi,0x3
    1116:	mov    edx,0x4
    111b:	mov    rdi,r12
    111e:	call   1123 <botlish_fn_8+0xd5>
			111f: R_X86_64_PLT32	rt_construct-0x4
    1123:	test   rax,rax
    1126:	je     114b <botlish_fn_8+0xfd>
    112c:	mov    QWORD PTR [rsp+0x8],rax
    1131:	mov    rcx,rax
    1134:	mov    rdx,r14
    1137:	mov    rsi,rbx
    113a:	mov    rdi,r12
    113d:	call   1142 <botlish_fn_8+0xf4>
			113e: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    1142:	test   rax,rax
    1145:	jne    116b <botlish_fn_8+0x11d>
    114b:	xor    rax,rax
    114e:	mov    rbx,QWORD PTR [rsp+0x40]
    1153:	mov    r12,QWORD PTR [rsp+0x48]
    1158:	mov    r13,QWORD PTR [rsp+0x50]
    115d:	mov    r14,QWORD PTR [rsp+0x58]
    1162:	add    rsp,0x60
    1166:	mov    rsp,rbp
    1169:	pop    rbp
    116a:	ret
    116b:	mov    rbx,QWORD PTR [rsp+0x40]
    1170:	mov    r12,QWORD PTR [rsp+0x48]
    1175:	mov    r13,QWORD PTR [rsp+0x50]
    117a:	mov    r14,QWORD PTR [rsp+0x58]
    117f:	add    rsp,0x60
    1183:	mov    rsp,rbp
    1186:	pop    rbp
    1187:	ret
    1188:	mov    rax,r13
    118b:	mov    rbx,QWORD PTR [rsp+0x40]
    1190:	mov    r12,QWORD PTR [rsp+0x48]
    1195:	mov    r13,QWORD PTR [rsp+0x50]
    119a:	mov    r14,QWORD PTR [rsp+0x58]
    119f:	add    rsp,0x60
    11a3:	mov    rsp,rbp
    11a6:	pop    rbp
    11a7:	ret

00000000000011a8 <botlish_entry_8: scan_records<str, int, List[never]>>:
    11a8:	push   rbp
    11a9:	mov    rbp,rsp
    11ac:	mov    rsi,QWORD PTR [rdx]
    11af:	mov    r8,QWORD PTR [rdx+0x8]
    11b3:	mov    rcx,QWORD PTR [rdx+0x10]
    11b7:	mov    rdx,r8
    11ba:	call   11bf <botlish_entry_8+0x17>
			11bb: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    11bf:	mov    rsp,rbp
    11c2:	pop    rbp
    11c3:	ret
    11c4:	add    BYTE PTR [rax],al
	...

00000000000011c8 <botlish_fn_9: scan_records<str, int, List[List[str]]>>:
    11c8:	push   rbp
    11c9:	mov    rbp,rsp
    11cc:	sub    rsp,0x80
    11d3:	mov    QWORD PTR [rsp+0x50],rbx
    11d8:	mov    QWORD PTR [rsp+0x58],r12
    11dd:	mov    QWORD PTR [rsp+0x60],r13
    11e2:	mov    QWORD PTR [rsp+0x68],r14
    11e7:	mov    QWORD PTR [rsp+0x70],r15
    11ec:	mov    r14,rdi
    11ef:	mov    QWORD PTR [rsp+0x18],0x0
    11f8:	mov    QWORD PTR [rsp],rsi
    11fc:	mov    QWORD PTR [rsp+0x8],rdx
    1201:	mov    r13,rdx
    1204:	mov    QWORD PTR [rsp+0x10],rcx
    1209:	mov    r15,rcx
    120c:	lea    r12,[rsp+0x30]
    1211:	mov    rbx,rsi
    1214:	mov    rdx,QWORD PTR [rbx+0x8]
    1218:	shl    rdx,1
    121b:	or     rdx,0x1
    121f:	mov    rax,r13
    1222:	and    rax,rdx
    1225:	test   rax,0x1
    122b:	jne    1251 <botlish_fn_9+0x89>
    1231:	mov    rsi,r13
    1234:	mov    rdi,r14
    1237:	call   123c <botlish_fn_9+0x74>
			1238: R_X86_64_PLT32	rt_int_cmp-0x4
    123c:	mov    ecx,0x2
    1241:	test   rax,rax
    1244:	cmovge rcx,QWORD PTR [rip+0x13c]        # 1388 <botlish_fn_9+0x1c0>
    124c:	jmp    1264 <botlish_fn_9+0x9c>
    1251:	mov    ecx,0x2
    1256:	mov    rax,r13
    1259:	cmp    rax,rdx
    125c:	cmovge rcx,QWORD PTR [rip+0x124]        # 1388 <botlish_fn_9+0x1c0>
    1264:	cmp    rcx,0x6
    1268:	je     1307 <botlish_fn_9+0x13f>
    126e:	xor    rdx,rdx
    1271:	mov    rdi,r14
    1274:	mov    rsi,rdx
    1277:	call   127c <botlish_fn_9+0xb4>
			1278: R_X86_64_PLT32	rt_list_new-0x4
    127c:	test   rax,rax
    127f:	je     1338 <botlish_fn_9+0x170>
    1285:	mov    QWORD PTR [rsp+0x18],rax
    128a:	mov    rcx,rax
    128d:	mov    rdx,r13
    1290:	mov    rsi,rbx
    1293:	mov    rdi,r14
    1296:	call   129b <botlish_fn_9+0xd3>
			1297: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    129b:	test   rax,rax
    129e:	je     1338 <botlish_fn_9+0x170>
    12a4:	mov    QWORD PTR [rsp+0x8],rax
    12a9:	mov    QWORD PTR [rsp+0x18],rdx
    12ae:	mov    r13,rdx
    12b1:	mov    QWORD PTR [rsp+0x30],0x0
    12ba:	mov    rdx,r15
    12bd:	mov    QWORD PTR [rsp+0x38],rdx
    12c2:	mov    QWORD PTR [rsp+0x40],0x2
    12cb:	mov    QWORD PTR [rsp+0x48],rax
    12d0:	mov    esi,0x3
    12d5:	mov    edx,0x4
    12da:	mov    rcx,r12
    12dd:	mov    rdi,r14
    12e0:	call   12e5 <botlish_fn_9+0x11d>
			12e1: R_X86_64_PLT32	rt_construct-0x4
    12e5:	test   rax,rax
    12e8:	je     1338 <botlish_fn_9+0x170>
    12ee:	mov    QWORD PTR [rsp],rbx
    12f2:	mov    rdx,r13
    12f5:	mov    QWORD PTR [rsp+0x8],rdx
    12fa:	mov    QWORD PTR [rsp+0x10],rax
    12ff:	mov    r15,rax
    1302:	jmp    1214 <botlish_fn_9+0x4c>
    1307:	mov    rdx,r15
    130a:	lea    rcx,[rsp+0x20]
    130f:	mov    QWORD PTR [rsp+0x20],0x0
    1318:	mov    QWORD PTR [rsp+0x28],rdx
    131d:	mov    esi,0x1
    1322:	mov    edx,0x2
    1327:	mov    rdi,r14
    132a:	call   132f <botlish_fn_9+0x167>
			132b: R_X86_64_PLT32	rt_construct-0x4
    132f:	test   rax,rax
    1332:	jne    1360 <botlish_fn_9+0x198>
    1338:	xor    rax,rax
    133b:	mov    rbx,QWORD PTR [rsp+0x50]
    1340:	mov    r12,QWORD PTR [rsp+0x58]
    1345:	mov    r13,QWORD PTR [rsp+0x60]
    134a:	mov    r14,QWORD PTR [rsp+0x68]
    134f:	mov    r15,QWORD PTR [rsp+0x70]
    1354:	add    rsp,0x80
    135b:	mov    rsp,rbp
    135e:	pop    rbp
    135f:	ret
    1360:	mov    rbx,QWORD PTR [rsp+0x50]
    1365:	mov    r12,QWORD PTR [rsp+0x58]
    136a:	mov    r13,QWORD PTR [rsp+0x60]
    136f:	mov    r14,QWORD PTR [rsp+0x68]
    1374:	mov    r15,QWORD PTR [rsp+0x70]
    1379:	add    rsp,0x80
    1380:	mov    rsp,rbp
    1383:	pop    rbp
    1384:	ret
    1385:	add    BYTE PTR [rax],al
    1387:	add    BYTE PTR [rsi],al
    1389:	add    BYTE PTR [rax],al
    138b:	add    BYTE PTR [rax],al
    138d:	add    BYTE PTR [rax],al
	...

0000000000001390 <botlish_entry_9: scan_records<str, int, List[List[str]]>>:
    1390:	push   rbp
    1391:	mov    rbp,rsp
    1394:	mov    rsi,QWORD PTR [rdx]
    1397:	mov    r8,QWORD PTR [rdx+0x8]
    139b:	mov    rcx,QWORD PTR [rdx+0x10]
    139f:	mov    rdx,r8
    13a2:	call   13a7 <botlish_entry_9+0x17>
			13a3: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    13a7:	mov    rsp,rbp
    13aa:	pop    rbp
    13ab:	ret

00000000000013ac <botlish_fn_10: csv_parse<str>>:
    13ac:	push   rbp
    13ad:	mov    rbp,rsp
    13b0:	sub    rsp,0x30
    13b4:	mov    QWORD PTR [rsp+0x20],r12
    13b9:	mov    QWORD PTR [rsp+0x28],r13
    13be:	mov    r13,rdi
    13c1:	mov    QWORD PTR [rsp+0x10],0x0
    13ca:	mov    QWORD PTR [rsp],rsi
    13ce:	mov    r12,rsi
    13d1:	mov    QWORD PTR [rsp+0x8],0x1
    13da:	xor    rdx,rdx
    13dd:	mov    rdi,r13
    13e0:	mov    rsi,rdx
    13e3:	call   13e8 <botlish_fn_10+0x3c>
			13e4: R_X86_64_PLT32	rt_list_new-0x4
    13e8:	test   rax,rax
    13eb:	je     1412 <botlish_fn_10+0x66>
    13f1:	mov    QWORD PTR [rsp+0x10],rax
    13f6:	mov    rcx,rax
    13f9:	mov    edx,0x1
    13fe:	mov    rsi,r12
    1401:	mov    rdi,r13
    1404:	call   1409 <botlish_fn_10+0x5d>
			1405: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    1409:	test   rax,rax
    140c:	jne    1428 <botlish_fn_10+0x7c>
    1412:	xor    rax,rax
    1415:	mov    r12,QWORD PTR [rsp+0x20]
    141a:	mov    r13,QWORD PTR [rsp+0x28]
    141f:	add    rsp,0x30
    1423:	mov    rsp,rbp
    1426:	pop    rbp
    1427:	ret
    1428:	mov    r12,QWORD PTR [rsp+0x20]
    142d:	mov    r13,QWORD PTR [rsp+0x28]
    1432:	add    rsp,0x30
    1436:	mov    rsp,rbp
    1439:	pop    rbp
    143a:	ret

000000000000143b <botlish_entry_10: csv_parse<str>>:
    143b:	push   rbp
    143c:	mov    rbp,rsp
    143f:	mov    rsi,QWORD PTR [rdx]
    1442:	call   1447 <botlish_entry_10+0xc>
			1443: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
    1447:	mov    rsp,rbp
    144a:	pop    rbp
    144b:	ret

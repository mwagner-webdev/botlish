; source:  examples/stdlib/csv.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5958  (per function: 235 365 438 585 1141 352 795 976 388 516 167)
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
      df:	mov    rbx,rdx
      e2:	mov    r13,rdi
      e5:	mov    QWORD PTR [rsp],rsi
      e9:	mov    QWORD PTR [rsp+0x8],rdx
      ee:	mov    rdx,QWORD PTR [rsi+0x8]
      f2:	mov    r12,rsi
      f5:	shl    rdx,1
      f8:	mov    rax,rdx
      fb:	or     rax,0x1
      ff:	mov    rcx,rbx
     102:	and    rcx,rax
     105:	test   rcx,0x1
     10c:	jne    136 <botlish_fn_1+0x6e>
     112:	or     rdx,0x1
     116:	mov    rsi,rbx
     119:	mov    rdi,r13
     11c:	call   121 <botlish_fn_1+0x59>
			11d: R_X86_64_PLT32	rt_int_cmp-0x4
     121:	mov    ecx,0x2
     126:	test   rax,rax
     129:	cmovge rcx,QWORD PTR [rip+0xd7]        # 208 <botlish_fn_1+0x140>
     131:	jmp    14a <botlish_fn_1+0x82>
     136:	or     rdx,0x1
     13a:	mov    ecx,0x2
     13f:	cmp    rbx,rdx
     142:	cmovge rcx,QWORD PTR [rip+0xbe]        # 208 <botlish_fn_1+0x140>
     14a:	cmp    rcx,0x6
     14e:	je     1de <botlish_fn_1+0x116>
     154:	mov    QWORD PTR [rsp+0x10],0x3
     15d:	test   rbx,0x1
     164:	je     17c <botlish_fn_1+0xb4>
     16a:	mov    rcx,rbx
     16d:	add    rcx,0x2
     171:	seto   al
     174:	test   al,al
     176:	je     18f <botlish_fn_1+0xc7>
     17c:	mov    edx,0x3
     181:	mov    rsi,rbx
     184:	mov    rdi,r13
     187:	call   18c <botlish_fn_1+0xc4>
			188: R_X86_64_PLT32	rt_int_add-0x4
     18c:	mov    rcx,rax
     18f:	mov    QWORD PTR [rsp+0x10],rcx
     194:	mov    rdx,rbx
     197:	mov    rsi,r12
     19a:	mov    rdi,r13
     19d:	call   1a2 <botlish_fn_1+0xda>
			19e: R_X86_64_PLT32	rt_substr-0x4
     1a2:	test   rax,rax
     1a5:	jne    1c6 <botlish_fn_1+0xfe>
     1ab:	xor    rax,rax
     1ae:	mov    rbx,QWORD PTR [rsp+0x20]
     1b3:	mov    r12,QWORD PTR [rsp+0x28]
     1b8:	mov    r13,QWORD PTR [rsp+0x30]
     1bd:	add    rsp,0x40
     1c1:	mov    rsp,rbp
     1c4:	pop    rbp
     1c5:	ret
     1c6:	mov    rbx,QWORD PTR [rsp+0x20]
     1cb:	mov    r12,QWORD PTR [rsp+0x28]
     1d0:	mov    r13,QWORD PTR [rsp+0x30]
     1d5:	add    rsp,0x40
     1d9:	mov    rsp,rbp
     1dc:	pop    rbp
     1dd:	ret
     1de:	mov    rdi,r13
     1e1:	mov    rax,QWORD PTR [rdi+0x10]
     1e5:	mov    rax,QWORD PTR [rax+0x8]
     1e9:	mov    rbx,QWORD PTR [rsp+0x20]
     1ee:	mov    r12,QWORD PTR [rsp+0x28]
     1f3:	mov    r13,QWORD PTR [rsp+0x30]
     1f8:	add    rsp,0x40
     1fc:	mov    rsp,rbp
     1ff:	pop    rbp
     200:	ret
     201:	add    BYTE PTR [rax],al
     203:	add    BYTE PTR [rax],al
     205:	add    BYTE PTR [rax],al
     207:	add    BYTE PTR [rsi],al
     209:	add    BYTE PTR [rax],al
     20b:	add    BYTE PTR [rax],al
     20d:	add    BYTE PTR [rax],al
	...

0000000000000210 <botlish_entry_1: peek<str, int>>:
     210:	push   rbp
     211:	mov    rbp,rsp
     214:	mov    rsi,QWORD PTR [rdx]
     217:	mov    rdx,QWORD PTR [rdx+0x8]
     21b:	call   220 <botlish_entry_1+0x10>
			21c: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     220:	mov    rsp,rbp
     223:	pop    rbp
     224:	ret
     225:	add    BYTE PTR [rax],al
	...

0000000000000228 <botlish_fn_2: peek<str, int>>:
     228:	push   rbp
     229:	mov    rbp,rsp
     22c:	sub    rsp,0x50
     230:	mov    QWORD PTR [rsp+0x20],rbx
     235:	mov    QWORD PTR [rsp+0x28],r12
     23a:	mov    QWORD PTR [rsp+0x30],r13
     23f:	mov    QWORD PTR [rsp+0x38],r14
     244:	mov    QWORD PTR [rsp+0x40],r15
     249:	mov    rbx,rdx
     24c:	mov    r12,rcx
     24f:	mov    r14,rdi
     252:	mov    QWORD PTR [rsp],rsi
     256:	mov    QWORD PTR [rsp+0x8],rdx
     25b:	mov    rdx,QWORD PTR [rsi+0x8]
     25f:	mov    r13,rsi
     262:	shl    rdx,1
     265:	mov    rax,rdx
     268:	or     rax,0x1
     26c:	mov    rcx,rbx
     26f:	and    rcx,rax
     272:	test   rcx,0x1
     279:	jne    2a3 <botlish_fn_2+0x7b>
     27f:	or     rdx,0x1
     283:	mov    rsi,rbx
     286:	mov    rdi,r14
     289:	call   28e <botlish_fn_2+0x66>
			28a: R_X86_64_PLT32	rt_int_cmp-0x4
     28e:	mov    ecx,0x2
     293:	test   rax,rax
     296:	cmovge rcx,QWORD PTR [rip+0x122]        # 3c0 <botlish_fn_2+0x198>
     29e:	jmp    2b7 <botlish_fn_2+0x8f>
     2a3:	or     rdx,0x1
     2a7:	mov    ecx,0x2
     2ac:	cmp    rbx,rdx
     2af:	cmovge rcx,QWORD PTR [rip+0x109]        # 3c0 <botlish_fn_2+0x198>
     2b7:	cmp    rcx,0x6
     2bb:	je     37b <botlish_fn_2+0x153>
     2c1:	mov    QWORD PTR [rsp+0x10],0x3
     2ca:	test   rbx,0x1
     2d1:	je     2f4 <botlish_fn_2+0xcc>
     2d7:	mov    rax,rbx
     2da:	add    rax,0x2
     2de:	seto   cl
     2e1:	test   cl,cl
     2e3:	jne    2f4 <botlish_fn_2+0xcc>
     2e9:	mov    rdi,r14
     2ec:	mov    r15,rax
     2ef:	jmp    30a <botlish_fn_2+0xe2>
     2f4:	mov    edx,0x3
     2f9:	mov    rsi,rbx
     2fc:	mov    rdi,r14
     2ff:	call   304 <botlish_fn_2+0xdc>
			300: R_X86_64_PLT32	rt_int_add-0x4
     304:	mov    r15,rax
     307:	mov    rdi,r14
     30a:	mov    rdi,r14
     30d:	mov    rcx,r15
     310:	mov    rdx,rbx
     313:	mov    rsi,r13
     316:	call   31b <botlish_fn_2+0xf3>
			317: R_X86_64_PLT32	rt_str_region_check-0x4
     31b:	test   rax,rax
     31e:	jne    349 <botlish_fn_2+0x121>
     324:	xor    rax,rax
     327:	mov    rbx,QWORD PTR [rsp+0x20]
     32c:	mov    r12,QWORD PTR [rsp+0x28]
     331:	mov    r13,QWORD PTR [rsp+0x30]
     336:	mov    r14,QWORD PTR [rsp+0x38]
     33b:	mov    r15,QWORD PTR [rsp+0x40]
     340:	add    rsp,0x50
     344:	mov    rsp,rbp
     347:	pop    rbp
     348:	ret
     349:	mov    rcx,r12
     34c:	mov    QWORD PTR [rcx],rbx
     34f:	mov    rax,r15
     352:	mov    QWORD PTR [rcx+0x8],rax
     356:	mov    rax,r13
     359:	mov    rbx,QWORD PTR [rsp+0x20]
     35e:	mov    r12,QWORD PTR [rsp+0x28]
     363:	mov    r13,QWORD PTR [rsp+0x30]
     368:	mov    r14,QWORD PTR [rsp+0x38]
     36d:	mov    r15,QWORD PTR [rsp+0x40]
     372:	add    rsp,0x50
     376:	mov    rsp,rbp
     379:	pop    rbp
     37a:	ret
     37b:	mov    rcx,r12
     37e:	mov    rdi,r14
     381:	mov    rax,QWORD PTR [rdi+0x10]
     385:	mov    rax,QWORD PTR [rax+0x8]
     389:	mov    QWORD PTR [rcx],0x1
     390:	mov    QWORD PTR [rcx+0x8],0x1
     398:	mov    rbx,QWORD PTR [rsp+0x20]
     39d:	mov    r12,QWORD PTR [rsp+0x28]
     3a2:	mov    r13,QWORD PTR [rsp+0x30]
     3a7:	mov    r14,QWORD PTR [rsp+0x38]
     3ac:	mov    r15,QWORD PTR [rsp+0x40]
     3b1:	add    rsp,0x50
     3b5:	mov    rsp,rbp
     3b8:	pop    rbp
     3b9:	ret
     3ba:	add    BYTE PTR [rax],al
     3bc:	add    BYTE PTR [rax],al
     3be:	add    BYTE PTR [rax],al
     3c0:	(bad)
     3c1:	add    BYTE PTR [rax],al
     3c3:	add    BYTE PTR [rax],al
     3c5:	add    BYTE PTR [rax],al
	...

00000000000003c8 <botlish_entry_2: peek<str, int>>:
     3c8:	push   rbp
     3c9:	mov    rbp,rsp
     3cc:	ud2

00000000000003ce <botlish_fn_3: scan_unquoted<str, int, int>>:
     3ce:	push   rbp
     3cf:	mov    rbp,rsp
     3d2:	sub    rsp,0x80
     3d9:	mov    QWORD PTR [rsp+0x50],rbx
     3de:	mov    QWORD PTR [rsp+0x58],r12
     3e3:	mov    QWORD PTR [rsp+0x60],r13
     3e8:	mov    QWORD PTR [rsp+0x68],r14
     3ed:	mov    QWORD PTR [rsp+0x70],r15
     3f2:	mov    QWORD PTR [rsp+0x30],rdi
     3f7:	mov    QWORD PTR [rsp+0x18],0x0
     400:	mov    QWORD PTR [rsp],rsi
     404:	mov    r15,rsi
     407:	mov    QWORD PTR [rsp+0x8],rdx
     40c:	mov    r14,rdx
     40f:	mov    QWORD PTR [rsp+0x10],rcx
     414:	lea    r13,[rsp+0x20]
     419:	mov    QWORD PTR [rsp+0x38],rcx
     41e:	mov    rcx,r13
     421:	mov    rdx,QWORD PTR [rsp+0x38]
     426:	mov    rsi,r15
     429:	mov    rdi,QWORD PTR [rsp+0x30]
     42e:	call   433 <botlish_fn_3+0x65>
			42f: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     433:	mov    rsi,rax
     436:	mov    QWORD PTR [rsp+0x40],rax
     43b:	test   rax,rsi
     43e:	je     598 <botlish_fn_3+0x1ca>
     444:	mov    rbx,QWORD PTR [rsp+0x20]
     449:	mov    r12,QWORD PTR [rsp+0x28]
     44e:	mov    rdi,QWORD PTR [rsp+0x30]
     453:	mov    rcx,QWORD PTR [rdi+0x10]
     457:	mov    r8,QWORD PTR [rcx+0x8]
     45b:	mov    rcx,r12
     45e:	mov    rdx,rbx
     461:	mov    rsi,QWORD PTR [rsp+0x40]
     466:	call   46b <botlish_fn_3+0x9d>
			467: R_X86_64_PLT32	rt_str_region_eq-0x4
     46b:	cmp    rax,0x6
     46f:	je     4b0 <botlish_fn_3+0xe2>
     475:	mov    rdi,QWORD PTR [rsp+0x30]
     47a:	mov    rax,QWORD PTR [rdi+0x10]
     47e:	mov    r8,QWORD PTR [rax+0x10]
     482:	mov    rcx,r12
     485:	mov    rdx,rbx
     488:	mov    rsi,QWORD PTR [rsp+0x40]
     48d:	call   492 <botlish_fn_3+0xc4>
			48e: R_X86_64_PLT32	rt_str_region_eq-0x4
     492:	cmp    rax,0x6
     496:	je     4a6 <botlish_fn_3+0xd8>
     49c:	mov    eax,0x2
     4a1:	jmp    4b5 <botlish_fn_3+0xe7>
     4a6:	mov    eax,0x6
     4ab:	jmp    4b5 <botlish_fn_3+0xe7>
     4b0:	mov    eax,0x6
     4b5:	cmp    rax,0x6
     4b9:	je     4fa <botlish_fn_3+0x12c>
     4bf:	mov    rdi,QWORD PTR [rsp+0x30]
     4c4:	mov    rax,QWORD PTR [rdi+0x10]
     4c8:	mov    r8,QWORD PTR [rax+0x18]
     4cc:	mov    rcx,r12
     4cf:	mov    rdx,rbx
     4d2:	mov    rsi,QWORD PTR [rsp+0x40]
     4d7:	call   4dc <botlish_fn_3+0x10e>
			4d8: R_X86_64_PLT32	rt_str_region_eq-0x4
     4dc:	cmp    rax,0x6
     4e0:	je     4f0 <botlish_fn_3+0x122>
     4e6:	mov    eax,0x2
     4eb:	jmp    4ff <botlish_fn_3+0x131>
     4f0:	mov    eax,0x6
     4f5:	jmp    4ff <botlish_fn_3+0x131>
     4fa:	mov    eax,0x6
     4ff:	cmp    rax,0x6
     503:	je     57a <botlish_fn_3+0x1ac>
     509:	mov    QWORD PTR [rsp+0x18],0x3
     512:	mov    rsi,QWORD PTR [rsp+0x38]
     517:	test   rsi,0x1
     51e:	je     545 <botlish_fn_3+0x177>
     524:	mov    rsi,QWORD PTR [rsp+0x38]
     529:	mov    rax,rsi
     52c:	add    rax,0x2
     530:	seto   sil
     534:	test   sil,sil
     537:	jne    545 <botlish_fn_3+0x177>
     53d:	mov    rsi,r15
     540:	jmp    55c <botlish_fn_3+0x18e>
     545:	mov    edx,0x3
     54a:	mov    rsi,QWORD PTR [rsp+0x38]
     54f:	mov    rdi,QWORD PTR [rsp+0x30]
     554:	call   559 <botlish_fn_3+0x18b>
			555: R_X86_64_PLT32	rt_int_add-0x4
     559:	mov    rsi,r15
     55c:	mov    QWORD PTR [rsp],rsi
     560:	mov    rdx,r14
     563:	mov    QWORD PTR [rsp+0x8],rdx
     568:	mov    QWORD PTR [rsp+0x10],rax
     56d:	mov    r15,rsi
     570:	mov    QWORD PTR [rsp+0x38],rax
     575:	jmp    41e <botlish_fn_3+0x50>
     57a:	mov    rdx,r14
     57d:	mov    rsi,r15
     580:	mov    rdi,QWORD PTR [rsp+0x30]
     585:	mov    rcx,QWORD PTR [rsp+0x38]
     58a:	call   58f <botlish_fn_3+0x1c1>
			58b: R_X86_64_PLT32	rt_substr-0x4
     58f:	test   rax,rax
     592:	jne    5c3 <botlish_fn_3+0x1f5>
     598:	xor    rdx,rdx
     59b:	mov    rax,rdx
     59e:	mov    rbx,QWORD PTR [rsp+0x50]
     5a3:	mov    r12,QWORD PTR [rsp+0x58]
     5a8:	mov    r13,QWORD PTR [rsp+0x60]
     5ad:	mov    r14,QWORD PTR [rsp+0x68]
     5b2:	mov    r15,QWORD PTR [rsp+0x70]
     5b7:	add    rsp,0x80
     5be:	mov    rsp,rbp
     5c1:	pop    rbp
     5c2:	ret
     5c3:	mov    rdx,QWORD PTR [rsp+0x38]
     5c8:	mov    rbx,QWORD PTR [rsp+0x50]
     5cd:	mov    r12,QWORD PTR [rsp+0x58]
     5d2:	mov    r13,QWORD PTR [rsp+0x60]
     5d7:	mov    r14,QWORD PTR [rsp+0x68]
     5dc:	mov    r15,QWORD PTR [rsp+0x70]
     5e1:	add    rsp,0x80
     5e8:	mov    rsp,rbp
     5eb:	pop    rbp
     5ec:	ret

00000000000005ed <botlish_entry_3: scan_unquoted<str, int, int>>:
     5ed:	push   rbp
     5ee:	mov    rbp,rsp
     5f1:	ud2

00000000000005f3 <botlish_fn_4: scan_quoted<str, int, str>>:
     5f3:	push   rbp
     5f4:	mov    rbp,rsp
     5f7:	sub    rsp,0xd0
     5fe:	mov    QWORD PTR [rsp+0xa0],rbx
     606:	mov    QWORD PTR [rsp+0xa8],r12
     60e:	mov    QWORD PTR [rsp+0xb0],r13
     616:	mov    QWORD PTR [rsp+0xb8],r14
     61e:	mov    QWORD PTR [rsp+0xc0],r15
     626:	mov    QWORD PTR [rsp+0x88],rdi
     62e:	mov    QWORD PTR [rsp+0x18],0x0
     637:	mov    QWORD PTR [rsp+0x20],0x0
     640:	mov    QWORD PTR [rsp],rsi
     644:	mov    QWORD PTR [rsp+0x8],rdx
     649:	mov    QWORD PTR [rsp+0x10],rcx
     64e:	mov    r13,rcx
     651:	lea    r14,[rsp+0x68]
     656:	lea    rbx,[rsp+0x28]
     65b:	mov    r12,rsi
     65e:	mov    QWORD PTR [rsp+0x90],rdx
     666:	mov    rdx,QWORD PTR [rsp+0x90]
     66e:	mov    rsi,r12
     671:	mov    rdi,QWORD PTR [rsp+0x88]
     679:	call   67e <botlish_fn_4+0x8b>
			67a: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     67e:	test   rax,rax
     681:	je     9ca <botlish_fn_4+0x3d7>
     687:	mov    QWORD PTR [rsp+0x18],rax
     68c:	mov    rsi,QWORD PTR [rax+0x8]
     690:	mov    rcx,rax
     693:	mov    rax,0xffffffffffffffff
     69a:	test   rsi,rsi
     69d:	jne    6ab <botlish_fn_4+0xb8>
     6a3:	mov    r15,rcx
     6a6:	jmp    6d6 <botlish_fn_4+0xe3>
     6ab:	mov    r15,rcx
     6ae:	movzx  rdi,BYTE PTR [r15+0x18]
     6b3:	test   rdi,rdi
     6b6:	jne    6d1 <botlish_fn_4+0xde>
     6bc:	mov    rsi,r15
     6bf:	mov    rdi,QWORD PTR [rsp+0x88]
     6c7:	call   6cc <botlish_fn_4+0xd9>
			6c8: R_X86_64_PLT32	rt_str_to_short-0x4
     6cc:	jmp    6d6 <botlish_fn_4+0xe3>
     6d1:	movzx  rax,BYTE PTR [r15+0x19]
     6d6:	cmp    rax,0x22
     6da:	je     79a <botlish_fn_4+0x1a7>
     6e0:	mov    QWORD PTR [rsp+0x20],0x3
     6e9:	mov    rsi,QWORD PTR [rsp+0x90]
     6f1:	test   rsi,0x1
     6f8:	je     718 <botlish_fn_4+0x125>
     6fe:	mov    rax,rsi
     701:	add    rax,0x2
     705:	seto   cl
     708:	test   cl,cl
     70a:	jne    718 <botlish_fn_4+0x125>
     710:	mov    rsi,rax
     713:	jmp    72d <botlish_fn_4+0x13a>
     718:	mov    edx,0x3
     71d:	mov    rdi,QWORD PTR [rsp+0x88]
     725:	call   72a <botlish_fn_4+0x137>
			726: R_X86_64_PLT32	rt_int_add-0x4
     72a:	mov    rsi,rax
     72d:	mov    QWORD PTR [rsp+0x8],rsi
     732:	mov    QWORD PTR [rsp+0x90],rsi
     73a:	mov    QWORD PTR [rsp+0x68],0x0
     743:	mov    QWORD PTR [rsp+0x70],r13
     748:	mov    QWORD PTR [rsp+0x78],0x0
     751:	mov    QWORD PTR [rsp+0x80],r15
     759:	mov    esi,0x2
     75e:	mov    edx,0x4
     763:	mov    rcx,r14
     766:	mov    rdi,QWORD PTR [rsp+0x88]
     76e:	call   773 <botlish_fn_4+0x180>
			76f: R_X86_64_PLT32	rt_construct-0x4
     773:	test   rax,rax
     776:	je     9ca <botlish_fn_4+0x3d7>
     77c:	mov    QWORD PTR [rsp],r12
     780:	mov    rsi,QWORD PTR [rsp+0x90]
     788:	mov    QWORD PTR [rsp+0x8],rsi
     78d:	mov    QWORD PTR [rsp+0x10],rax
     792:	mov    r13,rax
     795:	jmp    666 <botlish_fn_4+0x73>
     79a:	mov    QWORD PTR [rsp+0x18],0x3
     7a3:	mov    rsi,QWORD PTR [rsp+0x90]
     7ab:	test   rsi,0x1
     7b2:	je     7d2 <botlish_fn_4+0x1df>
     7b8:	mov    rsi,QWORD PTR [rsp+0x90]
     7c0:	mov    rdx,rsi
     7c3:	add    rdx,0x2
     7c7:	seto   al
     7ca:	test   al,al
     7cc:	je     7ef <botlish_fn_4+0x1fc>
     7d2:	mov    edx,0x3
     7d7:	mov    rsi,QWORD PTR [rsp+0x90]
     7df:	mov    rdi,QWORD PTR [rsp+0x88]
     7e7:	call   7ec <botlish_fn_4+0x1f9>
			7e8: R_X86_64_PLT32	rt_int_add-0x4
     7ec:	mov    rdx,rax
     7ef:	mov    QWORD PTR [rsp+0x18],rdx
     7f4:	mov    rcx,rbx
     7f7:	mov    rsi,r12
     7fa:	mov    rdi,QWORD PTR [rsp+0x88]
     802:	call   807 <botlish_fn_4+0x214>
			803: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     807:	test   rax,rax
     80a:	mov    rsi,rax
     80d:	je     9ca <botlish_fn_4+0x3d7>
     813:	mov    rdx,QWORD PTR [rsp+0x28]
     818:	mov    rcx,QWORD PTR [rsp+0x30]
     81d:	mov    rdi,QWORD PTR [rsp+0x88]
     825:	mov    rax,QWORD PTR [rdi+0x10]
     829:	mov    r8,QWORD PTR [rax+0x20]
     82d:	call   832 <botlish_fn_4+0x23f>
			82e: R_X86_64_PLT32	rt_str_region_eq-0x4
     832:	cmp    rax,0x6
     836:	je     908 <botlish_fn_4+0x315>
     83c:	xor    rsi,rsi
     83f:	lea    rcx,[rsp+0x58]
     844:	mov    QWORD PTR [rsp+0x58],0x0
     84d:	mov    QWORD PTR [rsp+0x60],r13
     852:	mov    edx,0x2
     857:	mov    rdi,QWORD PTR [rsp+0x88]
     85f:	call   864 <botlish_fn_4+0x271>
			860: R_X86_64_PLT32	rt_construct-0x4
     864:	test   rax,rax
     867:	je     9ca <botlish_fn_4+0x3d7>
     86d:	mov    QWORD PTR [rsp],rax
     871:	mov    rbx,rax
     874:	mov    QWORD PTR [rsp+0x10],0x3
     87d:	mov    rsi,QWORD PTR [rsp+0x90]
     885:	test   rsi,0x1
     88c:	je     8b4 <botlish_fn_4+0x2c1>
     892:	mov    rsi,QWORD PTR [rsp+0x90]
     89a:	mov    rdx,rsi
     89d:	add    rdx,0x2
     8a1:	seto   al
     8a4:	test   al,al
     8a6:	jne    8b4 <botlish_fn_4+0x2c1>
     8ac:	mov    rax,rbx
     8af:	jmp    8d4 <botlish_fn_4+0x2e1>
     8b4:	mov    edx,0x3
     8b9:	mov    rsi,QWORD PTR [rsp+0x90]
     8c1:	mov    rdi,QWORD PTR [rsp+0x88]
     8c9:	call   8ce <botlish_fn_4+0x2db>
			8ca: R_X86_64_PLT32	rt_int_add-0x4
     8ce:	mov    rdx,rax
     8d1:	mov    rax,rbx
     8d4:	mov    rbx,QWORD PTR [rsp+0xa0]
     8dc:	mov    r12,QWORD PTR [rsp+0xa8]
     8e4:	mov    r13,QWORD PTR [rsp+0xb0]
     8ec:	mov    r14,QWORD PTR [rsp+0xb8]
     8f4:	mov    r15,QWORD PTR [rsp+0xc0]
     8fc:	add    rsp,0xd0
     903:	mov    rsp,rbp
     906:	pop    rbp
     907:	ret
     908:	mov    QWORD PTR [rsp+0x18],0x5
     911:	mov    rsi,QWORD PTR [rsp+0x90]
     919:	test   rsi,0x1
     920:	je     952 <botlish_fn_4+0x35f>
     926:	mov    rsi,QWORD PTR [rsp+0x90]
     92e:	mov    rdi,rsi
     931:	add    rdi,0x4
     935:	seto   r9b
     939:	test   r9b,r9b
     93c:	jne    952 <botlish_fn_4+0x35f>
     942:	mov    rsi,rdi
     945:	mov    QWORD PTR [rsp+0x90],rdi
     94d:	jmp    977 <botlish_fn_4+0x384>
     952:	mov    edx,0x5
     957:	mov    rsi,QWORD PTR [rsp+0x90]
     95f:	mov    rdi,QWORD PTR [rsp+0x88]
     967:	call   96c <botlish_fn_4+0x379>
			968: R_X86_64_PLT32	rt_int_add-0x4
     96c:	mov    rsi,rax
     96f:	mov    QWORD PTR [rsp+0x90],rax
     977:	mov    QWORD PTR [rsp+0x8],rsi
     97c:	mov    rdi,QWORD PTR [rsp+0x88]
     984:	mov    rax,QWORD PTR [rdi+0x10]
     988:	mov    rax,QWORD PTR [rax+0x20]
     98c:	mov    QWORD PTR [rsp+0x18],rax
     991:	lea    rcx,[rsp+0x38]
     996:	mov    QWORD PTR [rsp+0x38],0x0
     99f:	mov    QWORD PTR [rsp+0x40],r13
     9a4:	mov    QWORD PTR [rsp+0x48],0x0
     9ad:	mov    QWORD PTR [rsp+0x50],rax
     9b2:	mov    esi,0x2
     9b7:	mov    edx,0x4
     9bc:	call   9c1 <botlish_fn_4+0x3ce>
			9bd: R_X86_64_PLT32	rt_construct-0x4
     9c1:	test   rax,rax
     9c4:	jne    a04 <botlish_fn_4+0x411>
     9ca:	xor    rdx,rdx
     9cd:	mov    rax,rdx
     9d0:	mov    rbx,QWORD PTR [rsp+0xa0]
     9d8:	mov    r12,QWORD PTR [rsp+0xa8]
     9e0:	mov    r13,QWORD PTR [rsp+0xb0]
     9e8:	mov    r14,QWORD PTR [rsp+0xb8]
     9f0:	mov    r15,QWORD PTR [rsp+0xc0]
     9f8:	add    rsp,0xd0
     9ff:	mov    rsp,rbp
     a02:	pop    rbp
     a03:	ret
     a04:	mov    QWORD PTR [rsp],r12
     a08:	mov    rsi,QWORD PTR [rsp+0x90]
     a10:	mov    QWORD PTR [rsp+0x8],rsi
     a15:	mov    QWORD PTR [rsp+0x10],rax
     a1a:	mov    r13,rax
     a1d:	jmp    666 <botlish_fn_4+0x73>

0000000000000a22 <botlish_entry_4: scan_quoted<str, int, str>>:
     a22:	push   rbp
     a23:	mov    rbp,rsp
     a26:	ud2

0000000000000a28 <botlish_fn_5: scan_field<str, int>>:
     a28:	push   rbp
     a29:	mov    rbp,rsp
     a2c:	sub    rsp,0x50
     a30:	mov    QWORD PTR [rsp+0x30],rbx
     a35:	mov    QWORD PTR [rsp+0x38],r12
     a3a:	mov    QWORD PTR [rsp+0x40],r13
     a3f:	mov    r12,rdi
     a42:	mov    r13,rdx
     a45:	mov    QWORD PTR [rsp+0x10],0x0
     a4e:	mov    QWORD PTR [rsp],rsi
     a52:	mov    rbx,rsi
     a55:	mov    QWORD PTR [rsp+0x8],rdx
     a5a:	lea    rcx,[rsp+0x18]
     a5f:	mov    rdx,r13
     a62:	mov    rsi,rbx
     a65:	mov    rdi,r12
     a68:	call   a6d <botlish_fn_5+0x45>
			a69: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     a6d:	test   rax,rax
     a70:	mov    rsi,rax
     a73:	je     b3e <botlish_fn_5+0x116>
     a79:	mov    rdx,QWORD PTR [rsp+0x18]
     a7e:	mov    rcx,QWORD PTR [rsp+0x20]
     a83:	mov    rdi,r12
     a86:	mov    rax,QWORD PTR [rdi+0x10]
     a8a:	mov    r8,QWORD PTR [rax+0x20]
     a8e:	call   a93 <botlish_fn_5+0x6b>
			a8f: R_X86_64_PLT32	rt_str_region_eq-0x4
     a93:	cmp    rax,0x6
     a97:	je     acf <botlish_fn_5+0xa7>
     a9d:	mov    rcx,r13
     aa0:	mov    rsi,rbx
     aa3:	mov    rdi,r12
     aa6:	mov    rdx,rcx
     aa9:	call   aae <botlish_fn_5+0x86>
			aaa: R_X86_64_PLT32	botlish_fn_3-0x4 ; scan_unquoted<str, int, int>
     aae:	test   rax,rax
     ab1:	je     b3e <botlish_fn_5+0x116>
     ab7:	mov    rbx,QWORD PTR [rsp+0x30]
     abc:	mov    r12,QWORD PTR [rsp+0x38]
     ac1:	mov    r13,QWORD PTR [rsp+0x40]
     ac6:	add    rsp,0x50
     aca:	mov    rsp,rbp
     acd:	pop    rbp
     ace:	ret
     acf:	mov    rcx,r13
     ad2:	mov    QWORD PTR [rsp+0x10],0x3
     adb:	test   rcx,0x1
     ae2:	jne    af0 <botlish_fn_5+0xc8>
     ae8:	mov    r13,rcx
     aeb:	jmp    b05 <botlish_fn_5+0xdd>
     af0:	mov    rdx,rcx
     af3:	add    rdx,0x2
     af7:	mov    r13,rcx
     afa:	seto   al
     afd:	test   al,al
     aff:	je     b18 <botlish_fn_5+0xf0>
     b05:	mov    edx,0x3
     b0a:	mov    rsi,r13
     b0d:	mov    rdi,r12
     b10:	call   b15 <botlish_fn_5+0xed>
			b11: R_X86_64_PLT32	rt_int_add-0x4
     b15:	mov    rdx,rax
     b18:	mov    QWORD PTR [rsp+0x8],rdx
     b1d:	mov    rdi,r12
     b20:	mov    rax,QWORD PTR [rdi+0x10]
     b24:	mov    rcx,QWORD PTR [rax+0x8]
     b28:	mov    QWORD PTR [rsp+0x10],rcx
     b2d:	mov    rsi,rbx
     b30:	call   b35 <botlish_fn_5+0x10d>
			b31: R_X86_64_PLT32	botlish_fn_4-0x4 ; scan_quoted<str, int, str>
     b35:	test   rax,rax
     b38:	jne    b5c <botlish_fn_5+0x134>
     b3e:	xor    rdx,rdx
     b41:	mov    rax,rdx
     b44:	mov    rbx,QWORD PTR [rsp+0x30]
     b49:	mov    r12,QWORD PTR [rsp+0x38]
     b4e:	mov    r13,QWORD PTR [rsp+0x40]
     b53:	add    rsp,0x50
     b57:	mov    rsp,rbp
     b5a:	pop    rbp
     b5b:	ret
     b5c:	mov    rbx,QWORD PTR [rsp+0x30]
     b61:	mov    r12,QWORD PTR [rsp+0x38]
     b66:	mov    r13,QWORD PTR [rsp+0x40]
     b6b:	add    rsp,0x50
     b6f:	mov    rsp,rbp
     b72:	pop    rbp
     b73:	ret

0000000000000b74 <botlish_entry_5: scan_field<str, int>>:
     b74:	push   rbp
     b75:	mov    rbp,rsp
     b78:	ud2

0000000000000b7a <botlish_fn_6: scan_record<str, int, List[never]>>:
     b7a:	push   rbp
     b7b:	mov    rbp,rsp
     b7e:	sub    rsp,0xa0
     b85:	mov    QWORD PTR [rsp+0x70],rbx
     b8a:	mov    QWORD PTR [rsp+0x78],r12
     b8f:	mov    QWORD PTR [rsp+0x80],r13
     b97:	mov    QWORD PTR [rsp+0x88],r14
     b9f:	mov    QWORD PTR [rsp+0x90],r15
     ba7:	mov    r13,rdi
     baa:	mov    QWORD PTR [rsp+0x18],0x0
     bb3:	mov    QWORD PTR [rsp+0x20],0x0
     bbc:	mov    QWORD PTR [rsp],rsi
     bc0:	mov    r15,rsi
     bc3:	mov    QWORD PTR [rsp+0x8],rdx
     bc8:	mov    QWORD PTR [rsp+0x10],rcx
     bcd:	mov    QWORD PTR [rsp+0x58],rcx
     bd2:	mov    rsi,r15
     bd5:	mov    rdi,r13
     bd8:	call   bdd <botlish_fn_6+0x63>
			bd9: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     bdd:	test   rax,rax
     be0:	je     dfb <botlish_fn_6+0x281>
     be6:	mov    QWORD PTR [rsp+0x8],rax
     beb:	mov    QWORD PTR [rsp+0x68],rax
     bf0:	mov    QWORD PTR [rsp+0x18],rdx
     bf5:	mov    r14,rdx
     bf8:	lea    rcx,[rsp+0x28]
     bfd:	mov    rsi,r15
     c00:	mov    rdi,r13
     c03:	call   c08 <botlish_fn_6+0x8e>
			c04: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     c08:	test   rax,rax
     c0b:	mov    QWORD PTR [rsp+0x60],rax
     c10:	je     dfb <botlish_fn_6+0x281>
     c16:	mov    r12,QWORD PTR [rsp+0x28]
     c1b:	mov    rbx,QWORD PTR [rsp+0x30]
     c20:	mov    rdi,r13
     c23:	mov    rcx,QWORD PTR [rdi+0x10]
     c27:	mov    r8,QWORD PTR [rcx+0x10]
     c2b:	mov    rcx,rbx
     c2e:	mov    rdx,r12
     c31:	mov    rsi,QWORD PTR [rsp+0x60]
     c36:	call   c3b <botlish_fn_6+0xc1>
			c37: R_X86_64_PLT32	rt_str_region_eq-0x4
     c3b:	cmp    rax,0x6
     c3f:	je     d51 <botlish_fn_6+0x1d7>
     c45:	mov    rdi,r13
     c48:	mov    rax,QWORD PTR [rdi+0x10]
     c4c:	mov    r8,QWORD PTR [rax+0x18]
     c50:	mov    rcx,rbx
     c53:	mov    rdx,r12
     c56:	mov    rsi,QWORD PTR [rsp+0x60]
     c5b:	call   c60 <botlish_fn_6+0xe6>
			c5c: R_X86_64_PLT32	rt_str_region_eq-0x4
     c60:	cmp    rax,0x6
     c64:	je     cb6 <botlish_fn_6+0x13c>
     c6a:	mov    rdx,QWORD PTR [rsp+0x68]
     c6f:	mov    rsi,QWORD PTR [rsp+0x58]
     c74:	mov    rdi,r13
     c77:	call   c7c <botlish_fn_6+0x102>
			c78: R_X86_64_PLT32	rt_list_append-0x4
     c7c:	test   rax,rax
     c7f:	je     dfb <botlish_fn_6+0x281>
     c85:	mov    rdx,r14
     c88:	mov    rbx,QWORD PTR [rsp+0x70]
     c8d:	mov    r12,QWORD PTR [rsp+0x78]
     c92:	mov    r13,QWORD PTR [rsp+0x80]
     c9a:	mov    r14,QWORD PTR [rsp+0x88]
     ca2:	mov    r15,QWORD PTR [rsp+0x90]
     caa:	add    rsp,0xa0
     cb1:	mov    rsp,rbp
     cb4:	pop    rbp
     cb5:	ret
     cb6:	mov    rdx,QWORD PTR [rsp+0x68]
     cbb:	mov    rsi,QWORD PTR [rsp+0x58]
     cc0:	mov    rdi,r13
     cc3:	call   cc8 <botlish_fn_6+0x14e>
			cc4: R_X86_64_PLT32	rt_list_append-0x4
     cc8:	test   rax,rax
     ccb:	je     dfb <botlish_fn_6+0x281>
     cd1:	mov    QWORD PTR [rsp],rax
     cd5:	mov    r12,rax
     cd8:	mov    QWORD PTR [rsp+0x8],0x3
     ce1:	mov    rdx,r14
     ce4:	test   rdx,0x1
     ceb:	je     d0d <botlish_fn_6+0x193>
     cf1:	mov    rdx,r14
     cf4:	add    rdx,0x2
     cf8:	seto   sil
     cfc:	test   sil,sil
     cff:	jne    d0d <botlish_fn_6+0x193>
     d05:	mov    rax,r12
     d08:	jmp    d23 <botlish_fn_6+0x1a9>
     d0d:	mov    edx,0x3
     d12:	mov    rsi,r14
     d15:	mov    rdi,r13
     d18:	call   d1d <botlish_fn_6+0x1a3>
			d19: R_X86_64_PLT32	rt_int_add-0x4
     d1d:	mov    rdx,rax
     d20:	mov    rax,r12
     d23:	mov    rbx,QWORD PTR [rsp+0x70]
     d28:	mov    r12,QWORD PTR [rsp+0x78]
     d2d:	mov    r13,QWORD PTR [rsp+0x80]
     d35:	mov    r14,QWORD PTR [rsp+0x88]
     d3d:	mov    r15,QWORD PTR [rsp+0x90]
     d45:	add    rsp,0xa0
     d4c:	mov    rsp,rbp
     d4f:	pop    rbp
     d50:	ret
     d51:	mov    rsi,r14
     d54:	mov    r12d,0x3
     d5a:	mov    QWORD PTR [rsp+0x20],0x3
     d63:	test   rsi,0x1
     d6a:	je     d82 <botlish_fn_6+0x208>
     d70:	mov    rdx,rsi
     d73:	add    rdx,0x2
     d77:	seto   al
     d7a:	test   al,al
     d7c:	je     d90 <botlish_fn_6+0x216>
     d82:	mov    rdx,r12
     d85:	mov    rdi,r13
     d88:	call   d8d <botlish_fn_6+0x213>
			d89: R_X86_64_PLT32	rt_int_add-0x4
     d8d:	mov    rdx,rax
     d90:	mov    QWORD PTR [rsp+0x18],rdx
     d95:	mov    rbx,rdx
     d98:	lea    rcx,[rsp+0x38]
     d9d:	mov    QWORD PTR [rsp+0x38],0x0
     da6:	mov    rsi,QWORD PTR [rsp+0x58]
     dab:	mov    QWORD PTR [rsp+0x40],rsi
     db0:	mov    QWORD PTR [rsp+0x48],0x2
     db9:	mov    rdx,QWORD PTR [rsp+0x68]
     dbe:	mov    QWORD PTR [rsp+0x50],rdx
     dc3:	mov    edx,0x4
     dc8:	mov    rsi,r12
     dcb:	mov    rdi,r13
     dce:	call   dd3 <botlish_fn_6+0x259>
			dcf: R_X86_64_PLT32	rt_construct-0x4
     dd3:	test   rax,rax
     dd6:	je     dfb <botlish_fn_6+0x281>
     ddc:	mov    QWORD PTR [rsp+0x8],rax
     de1:	mov    rcx,rax
     de4:	mov    rdx,rbx
     de7:	mov    rsi,r15
     dea:	mov    rdi,r13
     ded:	call   df2 <botlish_fn_6+0x278>
			dee: R_X86_64_PLT32	botlish_fn_7-0x4 ; scan_record<str, int, List[str]>
     df2:	test   rax,rax
     df5:	jne    e2f <botlish_fn_6+0x2b5>
     dfb:	xor    rdx,rdx
     dfe:	mov    rax,rdx
     e01:	mov    rbx,QWORD PTR [rsp+0x70]
     e06:	mov    r12,QWORD PTR [rsp+0x78]
     e0b:	mov    r13,QWORD PTR [rsp+0x80]
     e13:	mov    r14,QWORD PTR [rsp+0x88]
     e1b:	mov    r15,QWORD PTR [rsp+0x90]
     e23:	add    rsp,0xa0
     e2a:	mov    rsp,rbp
     e2d:	pop    rbp
     e2e:	ret
     e2f:	mov    rbx,QWORD PTR [rsp+0x70]
     e34:	mov    r12,QWORD PTR [rsp+0x78]
     e39:	mov    r13,QWORD PTR [rsp+0x80]
     e41:	mov    r14,QWORD PTR [rsp+0x88]
     e49:	mov    r15,QWORD PTR [rsp+0x90]
     e51:	add    rsp,0xa0
     e58:	mov    rsp,rbp
     e5b:	pop    rbp
     e5c:	ret

0000000000000e5d <botlish_entry_6: scan_record<str, int, List[never]>>:
     e5d:	push   rbp
     e5e:	mov    rbp,rsp
     e61:	ud2

0000000000000e63 <botlish_fn_7: scan_record<str, int, List[str]>>:
     e63:	push   rbp
     e64:	mov    rbp,rsp
     e67:	sub    rsp,0xf0
     e6e:	mov    QWORD PTR [rsp+0xc0],rbx
     e76:	mov    QWORD PTR [rsp+0xc8],r12
     e7e:	mov    QWORD PTR [rsp+0xd0],r13
     e86:	mov    QWORD PTR [rsp+0xd8],r14
     e8e:	mov    QWORD PTR [rsp+0xe0],r15
     e96:	mov    QWORD PTR [rsp+0x98],rdi
     e9e:	mov    QWORD PTR [rsp+0x18],0x0
     ea7:	mov    QWORD PTR [rsp+0x20],0x0
     eb0:	mov    QWORD PTR [rsp],rsi
     eb4:	mov    QWORD PTR [rsp+0x8],rdx
     eb9:	mov    QWORD PTR [rsp+0xa0],rdx
     ec1:	mov    QWORD PTR [rsp+0x10],rcx
     ec6:	mov    r15,rcx
     ec9:	lea    rbx,[rsp+0x28]
     ece:	mov    r12,rsi
     ed1:	mov    rsi,r12
     ed4:	mov    rdi,QWORD PTR [rsp+0x98]
     edc:	call   ee1 <botlish_fn_7+0x7e>
			edd: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     ee1:	test   rax,rax
     ee4:	je     11a1 <botlish_fn_7+0x33e>
     eea:	mov    QWORD PTR [rsp+0x8],rax
     eef:	mov    QWORD PTR [rsp+0xb0],rax
     ef7:	mov    QWORD PTR [rsp+0x18],rdx
     efc:	mov    QWORD PTR [rsp+0xb8],rdx
     f04:	mov    rcx,rbx
     f07:	mov    rsi,r12
     f0a:	mov    rdi,QWORD PTR [rsp+0x98]
     f12:	call   f17 <botlish_fn_7+0xb4>
			f13: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     f17:	test   rax,rax
     f1a:	mov    QWORD PTR [rsp+0xa8],rax
     f22:	je     11a1 <botlish_fn_7+0x33e>
     f28:	mov    r13,QWORD PTR [rsp+0x28]
     f2d:	mov    r14,QWORD PTR [rsp+0x30]
     f32:	mov    rdi,QWORD PTR [rsp+0x98]
     f3a:	mov    rcx,QWORD PTR [rdi+0x10]
     f3e:	mov    r8,QWORD PTR [rcx+0x10]
     f42:	mov    rcx,r14
     f45:	mov    rdx,r13
     f48:	mov    rsi,QWORD PTR [rsp+0xa8]
     f50:	call   f55 <botlish_fn_7+0xf2>
			f51: R_X86_64_PLT32	rt_str_region_eq-0x4
     f55:	cmp    rax,0x6
     f59:	je     1101 <botlish_fn_7+0x29e>
     f5f:	mov    rdi,QWORD PTR [rsp+0x98]
     f67:	mov    rax,QWORD PTR [rdi+0x10]
     f6b:	mov    r8,QWORD PTR [rax+0x18]
     f6f:	mov    rcx,r14
     f72:	mov    rdx,r13
     f75:	mov    rsi,QWORD PTR [rsp+0xa8]
     f7d:	call   f82 <botlish_fn_7+0x11f>
			f7e: R_X86_64_PLT32	rt_str_region_eq-0x4
     f82:	cmp    rax,0x6
     f86:	je     101d <botlish_fn_7+0x1ba>
     f8c:	lea    rcx,[rsp+0x78]
     f91:	mov    QWORD PTR [rsp+0x78],0x0
     f9a:	mov    r14,r15
     f9d:	mov    QWORD PTR [rsp+0x80],r14
     fa5:	mov    QWORD PTR [rsp+0x88],0x2
     fb1:	mov    r15,QWORD PTR [rsp+0xb0]
     fb9:	mov    QWORD PTR [rsp+0x90],r15
     fc1:	mov    esi,0x1
     fc6:	mov    edx,0x4
     fcb:	mov    rdi,QWORD PTR [rsp+0x98]
     fd3:	call   fd8 <botlish_fn_7+0x175>
			fd4: R_X86_64_PLT32	rt_construct-0x4
     fd8:	test   rax,rax
     fdb:	je     11a1 <botlish_fn_7+0x33e>
     fe1:	mov    rdx,QWORD PTR [rsp+0xb8]
     fe9:	mov    rbx,QWORD PTR [rsp+0xc0]
     ff1:	mov    r12,QWORD PTR [rsp+0xc8]
     ff9:	mov    r13,QWORD PTR [rsp+0xd0]
    1001:	mov    r14,QWORD PTR [rsp+0xd8]
    1009:	mov    r15,QWORD PTR [rsp+0xe0]
    1011:	add    rsp,0xf0
    1018:	mov    rsp,rbp
    101b:	pop    rbp
    101c:	ret
    101d:	mov    r14,r15
    1020:	mov    r15,QWORD PTR [rsp+0xb0]
    1028:	lea    rcx,[rsp+0x58]
    102d:	mov    QWORD PTR [rsp+0x58],0x0
    1036:	mov    QWORD PTR [rsp+0x60],r14
    103b:	mov    QWORD PTR [rsp+0x68],0x2
    1044:	mov    QWORD PTR [rsp+0x70],r15
    1049:	mov    esi,0x1
    104e:	mov    edx,0x4
    1053:	mov    rdi,QWORD PTR [rsp+0x98]
    105b:	call   1060 <botlish_fn_7+0x1fd>
			105c: R_X86_64_PLT32	rt_construct-0x4
    1060:	test   rax,rax
    1063:	je     11a1 <botlish_fn_7+0x33e>
    1069:	mov    QWORD PTR [rsp],rax
    106d:	mov    r12,rax
    1070:	mov    QWORD PTR [rsp+0x8],0x3
    1079:	mov    rdx,QWORD PTR [rsp+0xb8]
    1081:	test   rdx,0x1
    1088:	je     10ad <botlish_fn_7+0x24a>
    108e:	mov    rdx,QWORD PTR [rsp+0xb8]
    1096:	add    rdx,0x2
    109a:	seto   al
    109d:	test   al,al
    109f:	jne    10ad <botlish_fn_7+0x24a>
    10a5:	mov    rax,r12
    10a8:	jmp    10cd <botlish_fn_7+0x26a>
    10ad:	mov    edx,0x3
    10b2:	mov    rsi,QWORD PTR [rsp+0xb8]
    10ba:	mov    rdi,QWORD PTR [rsp+0x98]
    10c2:	call   10c7 <botlish_fn_7+0x264>
			10c3: R_X86_64_PLT32	rt_int_add-0x4
    10c7:	mov    rdx,rax
    10ca:	mov    rax,r12
    10cd:	mov    rbx,QWORD PTR [rsp+0xc0]
    10d5:	mov    r12,QWORD PTR [rsp+0xc8]
    10dd:	mov    r13,QWORD PTR [rsp+0xd0]
    10e5:	mov    r14,QWORD PTR [rsp+0xd8]
    10ed:	mov    r15,QWORD PTR [rsp+0xe0]
    10f5:	add    rsp,0xf0
    10fc:	mov    rsp,rbp
    10ff:	pop    rbp
    1100:	ret
    1101:	mov    r14,r15
    1104:	mov    r15,QWORD PTR [rsp+0xb0]
    110c:	mov    rsi,QWORD PTR [rsp+0xb8]
    1114:	mov    r13d,0x3
    111a:	mov    QWORD PTR [rsp+0x20],0x3
    1123:	test   rsi,0x1
    112a:	je     1142 <botlish_fn_7+0x2df>
    1130:	mov    rdx,rsi
    1133:	add    rdx,0x2
    1137:	seto   al
    113a:	test   al,al
    113c:	je     1155 <botlish_fn_7+0x2f2>
    1142:	mov    rdx,r13
    1145:	mov    rdi,QWORD PTR [rsp+0x98]
    114d:	call   1152 <botlish_fn_7+0x2ef>
			114e: R_X86_64_PLT32	rt_int_add-0x4
    1152:	mov    rdx,rax
    1155:	mov    QWORD PTR [rsp+0x18],rdx
    115a:	mov    QWORD PTR [rsp+0xa0],rdx
    1162:	lea    rcx,[rsp+0x38]
    1167:	mov    QWORD PTR [rsp+0x38],0x0
    1170:	mov    QWORD PTR [rsp+0x40],r14
    1175:	mov    QWORD PTR [rsp+0x48],0x2
    117e:	mov    QWORD PTR [rsp+0x50],r15
    1183:	mov    edx,0x4
    1188:	mov    rsi,r13
    118b:	mov    rdi,QWORD PTR [rsp+0x98]
    1193:	call   1198 <botlish_fn_7+0x335>
			1194: R_X86_64_PLT32	rt_construct-0x4
    1198:	test   rax,rax
    119b:	jne    11db <botlish_fn_7+0x378>
    11a1:	xor    rdx,rdx
    11a4:	mov    rax,rdx
    11a7:	mov    rbx,QWORD PTR [rsp+0xc0]
    11af:	mov    r12,QWORD PTR [rsp+0xc8]
    11b7:	mov    r13,QWORD PTR [rsp+0xd0]
    11bf:	mov    r14,QWORD PTR [rsp+0xd8]
    11c7:	mov    r15,QWORD PTR [rsp+0xe0]
    11cf:	add    rsp,0xf0
    11d6:	mov    rsp,rbp
    11d9:	pop    rbp
    11da:	ret
    11db:	mov    QWORD PTR [rsp],r12
    11df:	mov    rdx,QWORD PTR [rsp+0xa0]
    11e7:	mov    QWORD PTR [rsp+0x8],rdx
    11ec:	mov    QWORD PTR [rsp+0x10],rax
    11f1:	mov    r15,rax
    11f4:	jmp    ed1 <botlish_fn_7+0x6e>

00000000000011f9 <botlish_entry_7: scan_record<str, int, List[str]>>:
    11f9:	push   rbp
    11fa:	mov    rbp,rsp
    11fd:	ud2

00000000000011ff <botlish_fn_8: scan_records<str, int, List[never]>>:
    11ff:	push   rbp
    1200:	mov    rbp,rsp
    1203:	sub    rsp,0x60
    1207:	mov    QWORD PTR [rsp+0x40],rbx
    120c:	mov    QWORD PTR [rsp+0x48],r12
    1211:	mov    QWORD PTR [rsp+0x50],r13
    1216:	mov    QWORD PTR [rsp+0x58],r14
    121b:	mov    r12,rdi
    121e:	mov    QWORD PTR [rsp+0x18],0x0
    1227:	mov    QWORD PTR [rsp],rsi
    122b:	mov    QWORD PTR [rsp+0x8],rdx
    1230:	mov    QWORD PTR [rsp+0x10],rcx
    1235:	mov    r13,rcx
    1238:	mov    rax,QWORD PTR [rsi+0x8]
    123c:	mov    rbx,rsi
    123f:	mov    rcx,rdx
    1242:	sar    rcx,1
    1245:	mov    r14,rdx
    1248:	shl    rax,1
    124b:	or     rax,0x1
    124f:	sar    rax,1
    1252:	cmp    rcx,rax
    1255:	jge    1339 <botlish_fn_8+0x13a>
    125b:	xor    rdx,rdx
    125e:	mov    rdi,r12
    1261:	mov    rsi,rdx
    1264:	call   1269 <botlish_fn_8+0x6a>
			1265: R_X86_64_PLT32	rt_list_new-0x4
    1269:	test   rax,rax
    126c:	je     12fc <botlish_fn_8+0xfd>
    1272:	mov    QWORD PTR [rsp+0x18],rax
    1277:	mov    rcx,rax
    127a:	mov    rdx,r14
    127d:	mov    rsi,rbx
    1280:	mov    rdi,r12
    1283:	call   1288 <botlish_fn_8+0x89>
			1284: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    1288:	test   rax,rax
    128b:	je     12fc <botlish_fn_8+0xfd>
    1291:	mov    QWORD PTR [rsp+0x8],rax
    1296:	mov    QWORD PTR [rsp+0x18],rdx
    129b:	mov    r14,rdx
    129e:	lea    rcx,[rsp+0x20]
    12a3:	mov    QWORD PTR [rsp+0x20],0x0
    12ac:	mov    rdx,r13
    12af:	mov    QWORD PTR [rsp+0x28],rdx
    12b4:	mov    QWORD PTR [rsp+0x30],0x2
    12bd:	mov    QWORD PTR [rsp+0x38],rax
    12c2:	mov    esi,0x3
    12c7:	mov    edx,0x4
    12cc:	mov    rdi,r12
    12cf:	call   12d4 <botlish_fn_8+0xd5>
			12d0: R_X86_64_PLT32	rt_construct-0x4
    12d4:	test   rax,rax
    12d7:	je     12fc <botlish_fn_8+0xfd>
    12dd:	mov    QWORD PTR [rsp+0x8],rax
    12e2:	mov    rcx,rax
    12e5:	mov    rdx,r14
    12e8:	mov    rsi,rbx
    12eb:	mov    rdi,r12
    12ee:	call   12f3 <botlish_fn_8+0xf4>
			12ef: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    12f3:	test   rax,rax
    12f6:	jne    131c <botlish_fn_8+0x11d>
    12fc:	xor    rax,rax
    12ff:	mov    rbx,QWORD PTR [rsp+0x40]
    1304:	mov    r12,QWORD PTR [rsp+0x48]
    1309:	mov    r13,QWORD PTR [rsp+0x50]
    130e:	mov    r14,QWORD PTR [rsp+0x58]
    1313:	add    rsp,0x60
    1317:	mov    rsp,rbp
    131a:	pop    rbp
    131b:	ret
    131c:	mov    rbx,QWORD PTR [rsp+0x40]
    1321:	mov    r12,QWORD PTR [rsp+0x48]
    1326:	mov    r13,QWORD PTR [rsp+0x50]
    132b:	mov    r14,QWORD PTR [rsp+0x58]
    1330:	add    rsp,0x60
    1334:	mov    rsp,rbp
    1337:	pop    rbp
    1338:	ret
    1339:	mov    rax,r13
    133c:	mov    rbx,QWORD PTR [rsp+0x40]
    1341:	mov    r12,QWORD PTR [rsp+0x48]
    1346:	mov    r13,QWORD PTR [rsp+0x50]
    134b:	mov    r14,QWORD PTR [rsp+0x58]
    1350:	add    rsp,0x60
    1354:	mov    rsp,rbp
    1357:	pop    rbp
    1358:	ret

0000000000001359 <botlish_entry_8: scan_records<str, int, List[never]>>:
    1359:	push   rbp
    135a:	mov    rbp,rsp
    135d:	mov    rsi,QWORD PTR [rdx]
    1360:	mov    r8,QWORD PTR [rdx+0x8]
    1364:	mov    rcx,QWORD PTR [rdx+0x10]
    1368:	mov    rdx,r8
    136b:	call   1370 <botlish_entry_8+0x17>
			136c: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    1370:	mov    rsp,rbp
    1373:	pop    rbp
    1374:	ret
    1375:	add    BYTE PTR [rax],al
	...

0000000000001378 <botlish_fn_9: scan_records<str, int, List[List[str]]>>:
    1378:	push   rbp
    1379:	mov    rbp,rsp
    137c:	sub    rsp,0x80
    1383:	mov    QWORD PTR [rsp+0x50],rbx
    1388:	mov    QWORD PTR [rsp+0x58],r12
    138d:	mov    QWORD PTR [rsp+0x60],r13
    1392:	mov    QWORD PTR [rsp+0x68],r14
    1397:	mov    QWORD PTR [rsp+0x70],r15
    139c:	mov    r14,rdi
    139f:	mov    QWORD PTR [rsp+0x18],0x0
    13a8:	mov    QWORD PTR [rsp],rsi
    13ac:	mov    QWORD PTR [rsp+0x8],rdx
    13b1:	mov    r13,rdx
    13b4:	mov    QWORD PTR [rsp+0x10],rcx
    13b9:	mov    r15,rcx
    13bc:	lea    r12,[rsp+0x30]
    13c1:	mov    rbx,rsi
    13c4:	mov    rdx,QWORD PTR [rbx+0x8]
    13c8:	shl    rdx,1
    13cb:	or     rdx,0x1
    13cf:	mov    rax,r13
    13d2:	and    rax,rdx
    13d5:	test   rax,0x1
    13db:	jne    1401 <botlish_fn_9+0x89>
    13e1:	mov    rsi,r13
    13e4:	mov    rdi,r14
    13e7:	call   13ec <botlish_fn_9+0x74>
			13e8: R_X86_64_PLT32	rt_int_cmp-0x4
    13ec:	mov    ecx,0x2
    13f1:	test   rax,rax
    13f4:	cmovge rcx,QWORD PTR [rip+0x13c]        # 1538 <botlish_fn_9+0x1c0>
    13fc:	jmp    1414 <botlish_fn_9+0x9c>
    1401:	mov    ecx,0x2
    1406:	mov    rax,r13
    1409:	cmp    rax,rdx
    140c:	cmovge rcx,QWORD PTR [rip+0x124]        # 1538 <botlish_fn_9+0x1c0>
    1414:	cmp    rcx,0x6
    1418:	je     14b7 <botlish_fn_9+0x13f>
    141e:	xor    rdx,rdx
    1421:	mov    rdi,r14
    1424:	mov    rsi,rdx
    1427:	call   142c <botlish_fn_9+0xb4>
			1428: R_X86_64_PLT32	rt_list_new-0x4
    142c:	test   rax,rax
    142f:	je     14e8 <botlish_fn_9+0x170>
    1435:	mov    QWORD PTR [rsp+0x18],rax
    143a:	mov    rcx,rax
    143d:	mov    rdx,r13
    1440:	mov    rsi,rbx
    1443:	mov    rdi,r14
    1446:	call   144b <botlish_fn_9+0xd3>
			1447: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, List[never]>
    144b:	test   rax,rax
    144e:	je     14e8 <botlish_fn_9+0x170>
    1454:	mov    QWORD PTR [rsp+0x8],rax
    1459:	mov    QWORD PTR [rsp+0x18],rdx
    145e:	mov    r13,rdx
    1461:	mov    QWORD PTR [rsp+0x30],0x0
    146a:	mov    rdx,r15
    146d:	mov    QWORD PTR [rsp+0x38],rdx
    1472:	mov    QWORD PTR [rsp+0x40],0x2
    147b:	mov    QWORD PTR [rsp+0x48],rax
    1480:	mov    esi,0x3
    1485:	mov    edx,0x4
    148a:	mov    rcx,r12
    148d:	mov    rdi,r14
    1490:	call   1495 <botlish_fn_9+0x11d>
			1491: R_X86_64_PLT32	rt_construct-0x4
    1495:	test   rax,rax
    1498:	je     14e8 <botlish_fn_9+0x170>
    149e:	mov    QWORD PTR [rsp],rbx
    14a2:	mov    rdx,r13
    14a5:	mov    QWORD PTR [rsp+0x8],rdx
    14aa:	mov    QWORD PTR [rsp+0x10],rax
    14af:	mov    r15,rax
    14b2:	jmp    13c4 <botlish_fn_9+0x4c>
    14b7:	mov    rdx,r15
    14ba:	lea    rcx,[rsp+0x20]
    14bf:	mov    QWORD PTR [rsp+0x20],0x0
    14c8:	mov    QWORD PTR [rsp+0x28],rdx
    14cd:	mov    esi,0x1
    14d2:	mov    edx,0x2
    14d7:	mov    rdi,r14
    14da:	call   14df <botlish_fn_9+0x167>
			14db: R_X86_64_PLT32	rt_construct-0x4
    14df:	test   rax,rax
    14e2:	jne    1510 <botlish_fn_9+0x198>
    14e8:	xor    rax,rax
    14eb:	mov    rbx,QWORD PTR [rsp+0x50]
    14f0:	mov    r12,QWORD PTR [rsp+0x58]
    14f5:	mov    r13,QWORD PTR [rsp+0x60]
    14fa:	mov    r14,QWORD PTR [rsp+0x68]
    14ff:	mov    r15,QWORD PTR [rsp+0x70]
    1504:	add    rsp,0x80
    150b:	mov    rsp,rbp
    150e:	pop    rbp
    150f:	ret
    1510:	mov    rbx,QWORD PTR [rsp+0x50]
    1515:	mov    r12,QWORD PTR [rsp+0x58]
    151a:	mov    r13,QWORD PTR [rsp+0x60]
    151f:	mov    r14,QWORD PTR [rsp+0x68]
    1524:	mov    r15,QWORD PTR [rsp+0x70]
    1529:	add    rsp,0x80
    1530:	mov    rsp,rbp
    1533:	pop    rbp
    1534:	ret
    1535:	add    BYTE PTR [rax],al
    1537:	add    BYTE PTR [rsi],al
    1539:	add    BYTE PTR [rax],al
    153b:	add    BYTE PTR [rax],al
    153d:	add    BYTE PTR [rax],al
	...

0000000000001540 <botlish_entry_9: scan_records<str, int, List[List[str]]>>:
    1540:	push   rbp
    1541:	mov    rbp,rsp
    1544:	mov    rsi,QWORD PTR [rdx]
    1547:	mov    r8,QWORD PTR [rdx+0x8]
    154b:	mov    rcx,QWORD PTR [rdx+0x10]
    154f:	mov    rdx,r8
    1552:	call   1557 <botlish_entry_9+0x17>
			1553: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, List[List[str]]>
    1557:	mov    rsp,rbp
    155a:	pop    rbp
    155b:	ret

000000000000155c <botlish_fn_10: csv_parse<str>>:
    155c:	push   rbp
    155d:	mov    rbp,rsp
    1560:	sub    rsp,0x30
    1564:	mov    QWORD PTR [rsp+0x20],r12
    1569:	mov    QWORD PTR [rsp+0x28],r13
    156e:	mov    r13,rdi
    1571:	mov    QWORD PTR [rsp+0x10],0x0
    157a:	mov    QWORD PTR [rsp],rsi
    157e:	mov    r12,rsi
    1581:	mov    QWORD PTR [rsp+0x8],0x1
    158a:	xor    rdx,rdx
    158d:	mov    rdi,r13
    1590:	mov    rsi,rdx
    1593:	call   1598 <botlish_fn_10+0x3c>
			1594: R_X86_64_PLT32	rt_list_new-0x4
    1598:	test   rax,rax
    159b:	je     15c2 <botlish_fn_10+0x66>
    15a1:	mov    QWORD PTR [rsp+0x10],rax
    15a6:	mov    rcx,rax
    15a9:	mov    edx,0x1
    15ae:	mov    rsi,r12
    15b1:	mov    rdi,r13
    15b4:	call   15b9 <botlish_fn_10+0x5d>
			15b5: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, List[never]>
    15b9:	test   rax,rax
    15bc:	jne    15d8 <botlish_fn_10+0x7c>
    15c2:	xor    rax,rax
    15c5:	mov    r12,QWORD PTR [rsp+0x20]
    15ca:	mov    r13,QWORD PTR [rsp+0x28]
    15cf:	add    rsp,0x30
    15d3:	mov    rsp,rbp
    15d6:	pop    rbp
    15d7:	ret
    15d8:	mov    r12,QWORD PTR [rsp+0x20]
    15dd:	mov    r13,QWORD PTR [rsp+0x28]
    15e2:	add    rsp,0x30
    15e6:	mov    rsp,rbp
    15e9:	pop    rbp
    15ea:	ret

00000000000015eb <botlish_entry_10: csv_parse<str>>:
    15eb:	push   rbp
    15ec:	mov    rbp,rsp
    15ef:	mov    rsi,QWORD PTR [rdx]
    15f2:	call   15f7 <botlish_entry_10+0xc>
			15f3: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
    15f7:	mov    rsp,rbp
    15fa:	pop    rbp
    15fb:	ret

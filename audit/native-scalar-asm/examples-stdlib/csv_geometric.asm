; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 7597  (per function: 68 461 461 81 81 360 420 420 279 279 81 365 430 585 1063 352 783 215 488 325)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> mutarray::create<int, str>
;   botlish_fn_2 / botlish_entry_2 -> mutarray::create<int, List[str]>
;   botlish_fn_3 / botlish_entry_3 -> geo_new<str>
;   botlish_fn_4 / botlish_entry_4 -> geo_new<List[str]>
;   botlish_fn_5 / botlish_entry_5 -> geo_new_capacity<int, int>
;   botlish_fn_6 / botlish_entry_6 -> geo_grow<mutarray, int, str>
;   botlish_fn_7 / botlish_entry_7 -> geo_grow<mutarray, int, List[str]>
;   botlish_fn_8 / botlish_entry_8 -> geo_append<mutarray, int, str>
;   botlish_fn_9 / botlish_entry_9 -> geo_append<mutarray, int, List[str]>
;   botlish_fn_10 / botlish_entry_10 -> geo_finish<mutarray, int>
;   botlish_fn_11 / botlish_entry_11 -> peek<str, int>
;   botlish_fn_12 / botlish_entry_12 -> peek<str, int>
;   botlish_fn_13 / botlish_entry_13 -> scan_unquoted<str, int, int>
;   botlish_fn_14 / botlish_entry_14 -> scan_quoted<str, int, str>
;   botlish_fn_15 / botlish_entry_15 -> scan_field<str, int>
;   botlish_fn_16 / botlish_entry_16 -> scan_record_rest<str, int, mutarray, int>
;   botlish_fn_17 / botlish_entry_17 -> scan_record<str, int>
;   botlish_fn_18 / botlish_entry_18 -> scan_records<str, int, mutarray, int>
;   botlish_fn_19 / botlish_entry_19 -> csv_parse<str>


csv_geometric.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x10
       8:	mov    r8,QWORD PTR [rdi+0x10]
       c:	mov    rsi,QWORD PTR [r8]
       f:	mov    QWORD PTR [rsp],rsi
      13:	call   18 <botlish_fn_0+0x18>
			14: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
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

0000000000000048 <botlish_fn_1: mutarray::create<int, str>>:
      48:	push   rbp
      49:	mov    rbp,rsp
      4c:	sub    rsp,0x60
      50:	mov    QWORD PTR [rsp+0x30],rbx
      55:	mov    QWORD PTR [rsp+0x38],r12
      5a:	mov    QWORD PTR [rsp+0x40],r13
      5f:	mov    QWORD PTR [rsp+0x48],r14
      64:	mov    QWORD PTR [rsp+0x50],r15
      69:	mov    r13,rdi
      6c:	mov    QWORD PTR [rsp+0x10],0x0
      75:	mov    QWORD PTR [rsp+0x18],0x0
      7e:	mov    QWORD PTR [rsp+0x20],0x0
      87:	mov    QWORD PTR [rsp],rsi
      8b:	mov    QWORD PTR [rsp+0x8],rdx
      90:	mov    r12,rdx
      93:	mov    rbx,rsi
      96:	mov    rdi,r13
      99:	call   9e <botlish_fn_1+0x56>
			9a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
      9e:	test   rax,rax
      a1:	je     154 <botlish_fn_1+0x10c>
      a7:	mov    QWORD PTR [rsp+0x10],rax
      ac:	mov    r15,rax
      af:	mov    esi,0x1
      b4:	mov    r14,rsi
      b7:	mov    QWORD PTR [rsp+0x18],0x1
      c0:	mov    rax,rsi
      c3:	and    rax,rbx
      c6:	mov    r14,rsi
      c9:	test   rax,0x1
      cf:	jne    f8 <botlish_fn_1+0xb0>
      d5:	mov    rdx,rbx
      d8:	mov    rsi,r14
      db:	mov    rdi,r13
      de:	call   e3 <botlish_fn_1+0x9b>
			df: R_X86_64_PLT32	rt_int_cmp-0x4
      e3:	mov    ecx,0x2
      e8:	test   rax,rax
      eb:	cmovl  rcx,QWORD PTR [rip+0xe5]        # 1d8 <botlish_fn_1+0x190>
      f3:	jmp    10b <botlish_fn_1+0xc3>
      f8:	mov    ecx,0x2
      fd:	mov    rsi,r14
     100:	cmp    rsi,rbx
     103:	cmovl  rcx,QWORD PTR [rip+0xcd]        # 1d8 <botlish_fn_1+0x190>
     10b:	cmp    rcx,0x6
     10f:	je     13a <botlish_fn_1+0xf2>
     115:	mov    rax,r15
     118:	mov    rbx,QWORD PTR [rsp+0x30]
     11d:	mov    r12,QWORD PTR [rsp+0x38]
     122:	mov    r13,QWORD PTR [rsp+0x40]
     127:	mov    r14,QWORD PTR [rsp+0x48]
     12c:	mov    r15,QWORD PTR [rsp+0x50]
     131:	add    rsp,0x60
     135:	mov    rsp,rbp
     138:	pop    rbp
     139:	ret
     13a:	mov    rcx,r12
     13d:	mov    rdx,r14
     140:	mov    rsi,r15
     143:	mov    rdi,r13
     146:	call   14b <botlish_fn_1+0x103>
			147: R_X86_64_PLT32	rt_mutarray_set-0x4
     14b:	test   rax,rax
     14e:	jne    179 <botlish_fn_1+0x131>
     154:	xor    rax,rax
     157:	mov    rbx,QWORD PTR [rsp+0x30]
     15c:	mov    r12,QWORD PTR [rsp+0x38]
     161:	mov    r13,QWORD PTR [rsp+0x40]
     166:	mov    r14,QWORD PTR [rsp+0x48]
     16b:	mov    r15,QWORD PTR [rsp+0x50]
     170:	add    rsp,0x60
     174:	mov    rsp,rbp
     177:	pop    rbp
     178:	ret
     179:	mov    QWORD PTR [rsp+0x20],0x3
     182:	mov    rsi,r14
     185:	test   rsi,0x1
     18c:	je     1b2 <botlish_fn_1+0x16a>
     192:	mov    rsi,r14
     195:	mov    rcx,rsi
     198:	add    rcx,0x2
     19c:	seto   al
     19f:	test   al,al
     1a1:	jne    1b2 <botlish_fn_1+0x16a>
     1a7:	mov    rsi,rcx
     1aa:	mov    r14,rcx
     1ad:	jmp    1c8 <botlish_fn_1+0x180>
     1b2:	mov    edx,0x3
     1b7:	mov    rsi,r14
     1ba:	mov    rdi,r13
     1bd:	call   1c2 <botlish_fn_1+0x17a>
			1be: R_X86_64_PLT32	rt_int_add-0x4
     1c2:	mov    rsi,rax
     1c5:	mov    r14,rax
     1c8:	mov    QWORD PTR [rsp+0x18],rsi
     1cd:	mov    rsi,r14
     1d0:	jmp    c0 <botlish_fn_1+0x78>
     1d5:	add    BYTE PTR [rax],al
     1d7:	add    BYTE PTR [rsi],al
     1d9:	add    BYTE PTR [rax],al
     1db:	add    BYTE PTR [rax],al
     1dd:	add    BYTE PTR [rax],al
	...

00000000000001e0 <botlish_entry_1: mutarray::create<int, str>>:
     1e0:	push   rbp
     1e1:	mov    rbp,rsp
     1e4:	mov    rsi,QWORD PTR [rdx]
     1e7:	mov    rdx,QWORD PTR [rdx+0x8]
     1eb:	call   1f0 <botlish_entry_1+0x10>
			1ec: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutarray::create<int, str>
     1f0:	mov    rsp,rbp
     1f3:	pop    rbp
     1f4:	ret
     1f5:	add    BYTE PTR [rax],al
	...

00000000000001f8 <botlish_fn_2: mutarray::create<int, List[str]>>:
     1f8:	push   rbp
     1f9:	mov    rbp,rsp
     1fc:	sub    rsp,0x60
     200:	mov    QWORD PTR [rsp+0x30],rbx
     205:	mov    QWORD PTR [rsp+0x38],r12
     20a:	mov    QWORD PTR [rsp+0x40],r13
     20f:	mov    QWORD PTR [rsp+0x48],r14
     214:	mov    QWORD PTR [rsp+0x50],r15
     219:	mov    r13,rdi
     21c:	mov    QWORD PTR [rsp+0x10],0x0
     225:	mov    QWORD PTR [rsp+0x18],0x0
     22e:	mov    QWORD PTR [rsp+0x20],0x0
     237:	mov    QWORD PTR [rsp],rsi
     23b:	mov    QWORD PTR [rsp+0x8],rdx
     240:	mov    r12,rdx
     243:	mov    rbx,rsi
     246:	mov    rdi,r13
     249:	call   24e <botlish_fn_2+0x56>
			24a: R_X86_64_PLT32	rt_mutarray_allocate-0x4
     24e:	test   rax,rax
     251:	je     304 <botlish_fn_2+0x10c>
     257:	mov    QWORD PTR [rsp+0x10],rax
     25c:	mov    r15,rax
     25f:	mov    esi,0x1
     264:	mov    r14,rsi
     267:	mov    QWORD PTR [rsp+0x18],0x1
     270:	mov    rax,rsi
     273:	and    rax,rbx
     276:	mov    r14,rsi
     279:	test   rax,0x1
     27f:	jne    2a8 <botlish_fn_2+0xb0>
     285:	mov    rdx,rbx
     288:	mov    rsi,r14
     28b:	mov    rdi,r13
     28e:	call   293 <botlish_fn_2+0x9b>
			28f: R_X86_64_PLT32	rt_int_cmp-0x4
     293:	mov    ecx,0x2
     298:	test   rax,rax
     29b:	cmovl  rcx,QWORD PTR [rip+0xe5]        # 388 <botlish_fn_2+0x190>
     2a3:	jmp    2bb <botlish_fn_2+0xc3>
     2a8:	mov    ecx,0x2
     2ad:	mov    rsi,r14
     2b0:	cmp    rsi,rbx
     2b3:	cmovl  rcx,QWORD PTR [rip+0xcd]        # 388 <botlish_fn_2+0x190>
     2bb:	cmp    rcx,0x6
     2bf:	je     2ea <botlish_fn_2+0xf2>
     2c5:	mov    rax,r15
     2c8:	mov    rbx,QWORD PTR [rsp+0x30]
     2cd:	mov    r12,QWORD PTR [rsp+0x38]
     2d2:	mov    r13,QWORD PTR [rsp+0x40]
     2d7:	mov    r14,QWORD PTR [rsp+0x48]
     2dc:	mov    r15,QWORD PTR [rsp+0x50]
     2e1:	add    rsp,0x60
     2e5:	mov    rsp,rbp
     2e8:	pop    rbp
     2e9:	ret
     2ea:	mov    rcx,r12
     2ed:	mov    rdx,r14
     2f0:	mov    rsi,r15
     2f3:	mov    rdi,r13
     2f6:	call   2fb <botlish_fn_2+0x103>
			2f7: R_X86_64_PLT32	rt_mutarray_set-0x4
     2fb:	test   rax,rax
     2fe:	jne    329 <botlish_fn_2+0x131>
     304:	xor    rax,rax
     307:	mov    rbx,QWORD PTR [rsp+0x30]
     30c:	mov    r12,QWORD PTR [rsp+0x38]
     311:	mov    r13,QWORD PTR [rsp+0x40]
     316:	mov    r14,QWORD PTR [rsp+0x48]
     31b:	mov    r15,QWORD PTR [rsp+0x50]
     320:	add    rsp,0x60
     324:	mov    rsp,rbp
     327:	pop    rbp
     328:	ret
     329:	mov    QWORD PTR [rsp+0x20],0x3
     332:	mov    rsi,r14
     335:	test   rsi,0x1
     33c:	je     362 <botlish_fn_2+0x16a>
     342:	mov    rsi,r14
     345:	mov    rcx,rsi
     348:	add    rcx,0x2
     34c:	seto   al
     34f:	test   al,al
     351:	jne    362 <botlish_fn_2+0x16a>
     357:	mov    rsi,rcx
     35a:	mov    r14,rcx
     35d:	jmp    378 <botlish_fn_2+0x180>
     362:	mov    edx,0x3
     367:	mov    rsi,r14
     36a:	mov    rdi,r13
     36d:	call   372 <botlish_fn_2+0x17a>
			36e: R_X86_64_PLT32	rt_int_add-0x4
     372:	mov    rsi,rax
     375:	mov    r14,rax
     378:	mov    QWORD PTR [rsp+0x18],rsi
     37d:	mov    rsi,r14
     380:	jmp    270 <botlish_fn_2+0x78>
     385:	add    BYTE PTR [rax],al
     387:	add    BYTE PTR [rsi],al
     389:	add    BYTE PTR [rax],al
     38b:	add    BYTE PTR [rax],al
     38d:	add    BYTE PTR [rax],al
	...

0000000000000390 <botlish_entry_2: mutarray::create<int, List[str]>>:
     390:	push   rbp
     391:	mov    rbp,rsp
     394:	mov    rsi,QWORD PTR [rdx]
     397:	mov    rdx,QWORD PTR [rdx+0x8]
     39b:	call   3a0 <botlish_entry_2+0x10>
			39c: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutarray::create<int, List[str]>
     3a0:	mov    rsp,rbp
     3a3:	pop    rbp
     3a4:	ret

00000000000003a5 <botlish_fn_3: geo_new<str>>:
     3a5:	push   rbp
     3a6:	mov    rbp,rsp
     3a9:	sub    rsp,0x10
     3ad:	mov    QWORD PTR [rsp],rsi
     3b1:	mov    rdx,rsi
     3b4:	mov    esi,0x3
     3b9:	mov    QWORD PTR [rsp+0x8],0x3
     3c2:	call   3c7 <botlish_fn_3+0x22>
			3c3: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutarray::create<int, str>
     3c7:	test   rax,rax
     3ca:	jne    3dc <botlish_fn_3+0x37>
     3d0:	xor    rax,rax
     3d3:	add    rsp,0x10
     3d7:	mov    rsp,rbp
     3da:	pop    rbp
     3db:	ret
     3dc:	add    rsp,0x10
     3e0:	mov    rsp,rbp
     3e3:	pop    rbp
     3e4:	ret

00000000000003e5 <botlish_entry_3: geo_new<str>>:
     3e5:	push   rbp
     3e6:	mov    rbp,rsp
     3e9:	mov    rsi,QWORD PTR [rdx]
     3ec:	call   3f1 <botlish_entry_3+0xc>
			3ed: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<str>
     3f1:	mov    rsp,rbp
     3f4:	pop    rbp
     3f5:	ret

00000000000003f6 <botlish_fn_4: geo_new<List[str]>>:
     3f6:	push   rbp
     3f7:	mov    rbp,rsp
     3fa:	sub    rsp,0x10
     3fe:	mov    QWORD PTR [rsp],rsi
     402:	mov    rdx,rsi
     405:	mov    esi,0x3
     40a:	mov    QWORD PTR [rsp+0x8],0x3
     413:	call   418 <botlish_fn_4+0x22>
			414: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutarray::create<int, List[str]>
     418:	test   rax,rax
     41b:	jne    42d <botlish_fn_4+0x37>
     421:	xor    rax,rax
     424:	add    rsp,0x10
     428:	mov    rsp,rbp
     42b:	pop    rbp
     42c:	ret
     42d:	add    rsp,0x10
     431:	mov    rsp,rbp
     434:	pop    rbp
     435:	ret

0000000000000436 <botlish_entry_4: geo_new<List[str]>>:
     436:	push   rbp
     437:	mov    rbp,rsp
     43a:	mov    rsi,QWORD PTR [rdx]
     43d:	call   442 <botlish_entry_4+0xc>
			43e: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<List[str]>
     442:	mov    rsp,rbp
     445:	pop    rbp
     446:	ret
	...

0000000000000448 <botlish_fn_5: geo_new_capacity<int, int>>:
     448:	push   rbp
     449:	mov    rbp,rsp
     44c:	sub    rsp,0x40
     450:	mov    QWORD PTR [rsp+0x20],rbx
     455:	mov    QWORD PTR [rsp+0x28],r12
     45a:	mov    QWORD PTR [rsp+0x30],r13
     45f:	mov    r12,rdi
     462:	mov    QWORD PTR [rsp],rdx
     466:	mov    rbx,rdx
     469:	shl    rsi,1
     46c:	mov    rax,rsi
     46f:	or     rax,0x1
     473:	mov    QWORD PTR [rsp+0x8],rax
     478:	mov    QWORD PTR [rsp+0x10],0x5
     481:	mov    rax,rsi
     484:	or     rax,0x1
     488:	sar    rax,1
     48b:	imul   QWORD PTR [rip+0xe6]        # 578 <botlish_fn_5+0x130>
     492:	seto   cl
     495:	or     rax,0x1
     499:	test   cl,cl
     49b:	je     4b2 <botlish_fn_5+0x6a>
     4a1:	or     rsi,0x1
     4a5:	mov    edx,0x5
     4aa:	mov    rdi,r12
     4ad:	call   4b2 <botlish_fn_5+0x6a>
			4ae: R_X86_64_PLT32	rt_int_mul-0x4
     4b2:	mov    rcx,rax
     4b5:	and    rcx,rbx
     4b8:	mov    r13,rax
     4bb:	test   rcx,0x1
     4c2:	jne    4ee <botlish_fn_5+0xa6>
     4c8:	mov    rdx,rbx
     4cb:	mov    rsi,r13
     4ce:	mov    rdi,r12
     4d1:	call   4d6 <botlish_fn_5+0x8e>
			4d2: R_X86_64_PLT32	rt_int_cmp-0x4
     4d6:	mov    ecx,0x2
     4db:	test   rax,rax
     4de:	cmovle rcx,QWORD PTR [rip+0x9a]        # 580 <botlish_fn_5+0x138>
     4e6:	mov    rax,r13
     4e9:	jmp    501 <botlish_fn_5+0xb9>
     4ee:	mov    ecx,0x2
     4f3:	mov    rax,r13
     4f6:	cmp    rax,rbx
     4f9:	cmovle rcx,QWORD PTR [rip+0x7f]        # 580 <botlish_fn_5+0x138>
     501:	cmp    rcx,0x6
     505:	je     523 <botlish_fn_5+0xdb>
     50b:	mov    rbx,QWORD PTR [rsp+0x20]
     510:	mov    r12,QWORD PTR [rsp+0x28]
     515:	mov    r13,QWORD PTR [rsp+0x30]
     51a:	add    rsp,0x40
     51e:	mov    rsp,rbp
     521:	pop    rbp
     522:	ret
     523:	mov    QWORD PTR [rsp+0x8],0x3
     52c:	test   rbx,0x1
     533:	je     54b <botlish_fn_5+0x103>
     539:	mov    rax,rbx
     53c:	add    rax,0x2
     540:	seto   cl
     543:	test   cl,cl
     545:	je     55b <botlish_fn_5+0x113>
     54b:	mov    edx,0x3
     550:	mov    rsi,rbx
     553:	mov    rdi,r12
     556:	call   55b <botlish_fn_5+0x113>
			557: R_X86_64_PLT32	rt_int_add-0x4
     55b:	mov    rbx,QWORD PTR [rsp+0x20]
     560:	mov    r12,QWORD PTR [rsp+0x28]
     565:	mov    r13,QWORD PTR [rsp+0x30]
     56a:	add    rsp,0x40
     56e:	mov    rsp,rbp
     571:	pop    rbp
     572:	ret
     573:	add    BYTE PTR [rax],al
     575:	add    BYTE PTR [rax],al
     577:	add    BYTE PTR [rax+rax*1],al
     57a:	add    BYTE PTR [rax],al
     57c:	add    BYTE PTR [rax],al
     57e:	add    BYTE PTR [rax],al
     580:	(bad)
     581:	add    BYTE PTR [rax],al
     583:	add    BYTE PTR [rax],al
     585:	add    BYTE PTR [rax],al
	...

0000000000000588 <botlish_entry_5: geo_new_capacity<int, int>>:
     588:	push   rbp
     589:	mov    rbp,rsp
     58c:	mov    rsi,QWORD PTR [rdx]
     58f:	mov    rdx,QWORD PTR [rdx+0x8]
     593:	sar    rsi,1
     596:	call   59b <botlish_entry_5+0x13>
			597: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new_capacity<int, int>
     59b:	mov    rsp,rbp
     59e:	pop    rbp
     59f:	ret

00000000000005a0 <botlish_fn_6: geo_grow<mutarray, int, str>>:
     5a0:	push   rbp
     5a1:	mov    rbp,rsp
     5a4:	sub    rsp,0x50
     5a8:	mov    QWORD PTR [rsp+0x20],rbx
     5ad:	mov    QWORD PTR [rsp+0x28],r12
     5b2:	mov    QWORD PTR [rsp+0x30],r13
     5b7:	mov    QWORD PTR [rsp+0x38],r14
     5bc:	mov    QWORD PTR [rsp+0x40],r15
     5c1:	mov    r13,rdi
     5c4:	mov    QWORD PTR [rsp+0x18],0x0
     5cd:	mov    QWORD PTR [rsp],rsi
     5d1:	mov    r12,rsi
     5d4:	mov    QWORD PTR [rsp+0x8],rdx
     5d9:	mov    rbx,rdx
     5dc:	mov    QWORD PTR [rsp+0x10],rcx
     5e1:	mov    r14,rcx
     5e4:	mov    rsi,r12
     5e7:	mov    rdi,r13
     5ea:	call   5ef <botlish_fn_6+0x4f>
			5eb: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     5ef:	mov    rcx,rbx
     5f2:	and    rcx,rax
     5f5:	mov    r15,rax
     5f8:	test   rcx,0x1
     5ff:	jne    62b <botlish_fn_6+0x8b>
     605:	mov    rdx,r15
     608:	mov    rsi,rbx
     60b:	mov    rdi,r13
     60e:	call   613 <botlish_fn_6+0x73>
			60f: R_X86_64_PLT32	rt_int_cmp-0x4
     613:	mov    ecx,0x2
     618:	test   rax,rax
     61b:	cmovl  rcx,QWORD PTR [rip+0xed]        # 710 <botlish_fn_6+0x170>
     623:	mov    rax,r15
     626:	jmp    63e <botlish_fn_6+0x9e>
     62b:	mov    ecx,0x2
     630:	mov    rax,r15
     633:	cmp    rbx,rax
     636:	cmovl  rcx,QWORD PTR [rip+0xd2]        # 710 <botlish_fn_6+0x170>
     63e:	cmp    rcx,0x6
     642:	je     6e5 <botlish_fn_6+0x145>
     648:	mov    rsi,rax
     64b:	sar    rsi,1
     64e:	mov    rdx,rbx
     651:	mov    rdi,r13
     654:	call   659 <botlish_fn_6+0xb9>
			655: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new_capacity<int, int>
     659:	mov    QWORD PTR [rsp+0x18],rax
     65e:	mov    rdx,r14
     661:	mov    rsi,rax
     664:	mov    rdi,r13
     667:	call   66c <botlish_fn_6+0xcc>
			668: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutarray::create<int, str>
     66c:	test   rax,rax
     66f:	mov    r14,rax
     672:	je     69b <botlish_fn_6+0xfb>
     678:	mov    r8d,0x1
     67e:	mov    rcx,r12
     681:	mov    rdi,r13
     684:	mov    r9,rbx
     687:	mov    rsi,r14
     68a:	mov    rdx,r8
     68d:	call   692 <botlish_fn_6+0xf2>
			68e: R_X86_64_PLT32	rt_mutarray_copy-0x4
     692:	test   rax,rax
     695:	jne    6c0 <botlish_fn_6+0x120>
     69b:	xor    rax,rax
     69e:	mov    rbx,QWORD PTR [rsp+0x20]
     6a3:	mov    r12,QWORD PTR [rsp+0x28]
     6a8:	mov    r13,QWORD PTR [rsp+0x30]
     6ad:	mov    r14,QWORD PTR [rsp+0x38]
     6b2:	mov    r15,QWORD PTR [rsp+0x40]
     6b7:	add    rsp,0x50
     6bb:	mov    rsp,rbp
     6be:	pop    rbp
     6bf:	ret
     6c0:	mov    rax,r14
     6c3:	mov    rbx,QWORD PTR [rsp+0x20]
     6c8:	mov    r12,QWORD PTR [rsp+0x28]
     6cd:	mov    r13,QWORD PTR [rsp+0x30]
     6d2:	mov    r14,QWORD PTR [rsp+0x38]
     6d7:	mov    r15,QWORD PTR [rsp+0x40]
     6dc:	add    rsp,0x50
     6e0:	mov    rsp,rbp
     6e3:	pop    rbp
     6e4:	ret
     6e5:	mov    rax,r12
     6e8:	mov    rbx,QWORD PTR [rsp+0x20]
     6ed:	mov    r12,QWORD PTR [rsp+0x28]
     6f2:	mov    r13,QWORD PTR [rsp+0x30]
     6f7:	mov    r14,QWORD PTR [rsp+0x38]
     6fc:	mov    r15,QWORD PTR [rsp+0x40]
     701:	add    rsp,0x50
     705:	mov    rsp,rbp
     708:	pop    rbp
     709:	ret
     70a:	add    BYTE PTR [rax],al
     70c:	add    BYTE PTR [rax],al
     70e:	add    BYTE PTR [rax],al
     710:	(bad)
     711:	add    BYTE PTR [rax],al
     713:	add    BYTE PTR [rax],al
     715:	add    BYTE PTR [rax],al
	...

0000000000000718 <botlish_entry_6: geo_grow<mutarray, int, str>>:
     718:	push   rbp
     719:	mov    rbp,rsp
     71c:	mov    rsi,QWORD PTR [rdx]
     71f:	mov    r8,QWORD PTR [rdx+0x8]
     723:	mov    rcx,QWORD PTR [rdx+0x10]
     727:	mov    rdx,r8
     72a:	call   72f <botlish_entry_6+0x17>
			72b: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_grow<mutarray, int, str>
     72f:	mov    rsp,rbp
     732:	pop    rbp
     733:	ret
     734:	add    BYTE PTR [rax],al
	...

0000000000000738 <botlish_fn_7: geo_grow<mutarray, int, List[str]>>:
     738:	push   rbp
     739:	mov    rbp,rsp
     73c:	sub    rsp,0x50
     740:	mov    QWORD PTR [rsp+0x20],rbx
     745:	mov    QWORD PTR [rsp+0x28],r12
     74a:	mov    QWORD PTR [rsp+0x30],r13
     74f:	mov    QWORD PTR [rsp+0x38],r14
     754:	mov    QWORD PTR [rsp+0x40],r15
     759:	mov    r13,rdi
     75c:	mov    QWORD PTR [rsp+0x18],0x0
     765:	mov    QWORD PTR [rsp],rsi
     769:	mov    r12,rsi
     76c:	mov    QWORD PTR [rsp+0x8],rdx
     771:	mov    rbx,rdx
     774:	mov    QWORD PTR [rsp+0x10],rcx
     779:	mov    r14,rcx
     77c:	mov    rsi,r12
     77f:	mov    rdi,r13
     782:	call   787 <botlish_fn_7+0x4f>
			783: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     787:	mov    rcx,rbx
     78a:	and    rcx,rax
     78d:	mov    r15,rax
     790:	test   rcx,0x1
     797:	jne    7c3 <botlish_fn_7+0x8b>
     79d:	mov    rdx,r15
     7a0:	mov    rsi,rbx
     7a3:	mov    rdi,r13
     7a6:	call   7ab <botlish_fn_7+0x73>
			7a7: R_X86_64_PLT32	rt_int_cmp-0x4
     7ab:	mov    ecx,0x2
     7b0:	test   rax,rax
     7b3:	cmovl  rcx,QWORD PTR [rip+0xed]        # 8a8 <botlish_fn_7+0x170>
     7bb:	mov    rax,r15
     7be:	jmp    7d6 <botlish_fn_7+0x9e>
     7c3:	mov    ecx,0x2
     7c8:	mov    rax,r15
     7cb:	cmp    rbx,rax
     7ce:	cmovl  rcx,QWORD PTR [rip+0xd2]        # 8a8 <botlish_fn_7+0x170>
     7d6:	cmp    rcx,0x6
     7da:	je     87d <botlish_fn_7+0x145>
     7e0:	mov    rsi,rax
     7e3:	sar    rsi,1
     7e6:	mov    rdx,rbx
     7e9:	mov    rdi,r13
     7ec:	call   7f1 <botlish_fn_7+0xb9>
			7ed: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new_capacity<int, int>
     7f1:	mov    QWORD PTR [rsp+0x18],rax
     7f6:	mov    rdx,r14
     7f9:	mov    rsi,rax
     7fc:	mov    rdi,r13
     7ff:	call   804 <botlish_fn_7+0xcc>
			800: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutarray::create<int, List[str]>
     804:	test   rax,rax
     807:	mov    r14,rax
     80a:	je     833 <botlish_fn_7+0xfb>
     810:	mov    r8d,0x1
     816:	mov    rcx,r12
     819:	mov    rdi,r13
     81c:	mov    r9,rbx
     81f:	mov    rsi,r14
     822:	mov    rdx,r8
     825:	call   82a <botlish_fn_7+0xf2>
			826: R_X86_64_PLT32	rt_mutarray_copy-0x4
     82a:	test   rax,rax
     82d:	jne    858 <botlish_fn_7+0x120>
     833:	xor    rax,rax
     836:	mov    rbx,QWORD PTR [rsp+0x20]
     83b:	mov    r12,QWORD PTR [rsp+0x28]
     840:	mov    r13,QWORD PTR [rsp+0x30]
     845:	mov    r14,QWORD PTR [rsp+0x38]
     84a:	mov    r15,QWORD PTR [rsp+0x40]
     84f:	add    rsp,0x50
     853:	mov    rsp,rbp
     856:	pop    rbp
     857:	ret
     858:	mov    rax,r14
     85b:	mov    rbx,QWORD PTR [rsp+0x20]
     860:	mov    r12,QWORD PTR [rsp+0x28]
     865:	mov    r13,QWORD PTR [rsp+0x30]
     86a:	mov    r14,QWORD PTR [rsp+0x38]
     86f:	mov    r15,QWORD PTR [rsp+0x40]
     874:	add    rsp,0x50
     878:	mov    rsp,rbp
     87b:	pop    rbp
     87c:	ret
     87d:	mov    rax,r12
     880:	mov    rbx,QWORD PTR [rsp+0x20]
     885:	mov    r12,QWORD PTR [rsp+0x28]
     88a:	mov    r13,QWORD PTR [rsp+0x30]
     88f:	mov    r14,QWORD PTR [rsp+0x38]
     894:	mov    r15,QWORD PTR [rsp+0x40]
     899:	add    rsp,0x50
     89d:	mov    rsp,rbp
     8a0:	pop    rbp
     8a1:	ret
     8a2:	add    BYTE PTR [rax],al
     8a4:	add    BYTE PTR [rax],al
     8a6:	add    BYTE PTR [rax],al
     8a8:	(bad)
     8a9:	add    BYTE PTR [rax],al
     8ab:	add    BYTE PTR [rax],al
     8ad:	add    BYTE PTR [rax],al
	...

00000000000008b0 <botlish_entry_7: geo_grow<mutarray, int, List[str]>>:
     8b0:	push   rbp
     8b1:	mov    rbp,rsp
     8b4:	mov    rsi,QWORD PTR [rdx]
     8b7:	mov    r8,QWORD PTR [rdx+0x8]
     8bb:	mov    rcx,QWORD PTR [rdx+0x10]
     8bf:	mov    rdx,r8
     8c2:	call   8c7 <botlish_entry_7+0x17>
			8c3: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_grow<mutarray, int, List[str]>
     8c7:	mov    rsp,rbp
     8ca:	pop    rbp
     8cb:	ret

00000000000008cc <botlish_fn_8: geo_append<mutarray, int, str>>:
     8cc:	push   rbp
     8cd:	mov    rbp,rsp
     8d0:	sub    rsp,0x40
     8d4:	mov    QWORD PTR [rsp+0x20],rbx
     8d9:	mov    QWORD PTR [rsp+0x28],r12
     8de:	mov    QWORD PTR [rsp+0x30],r13
     8e3:	mov    QWORD PTR [rsp+0x38],r14
     8e8:	mov    rbx,rdi
     8eb:	mov    QWORD PTR [rsp],rsi
     8ef:	mov    QWORD PTR [rsp+0x8],rdx
     8f4:	mov    r14,rdx
     8f7:	mov    QWORD PTR [rsp+0x10],rcx
     8fc:	mov    r13,rcx
     8ff:	mov    rcx,r13
     902:	mov    rdx,r14
     905:	mov    rdi,rbx
     908:	call   90d <botlish_fn_8+0x41>
			909: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_grow<mutarray, int, str>
     90d:	test   rax,rax
     910:	je     979 <botlish_fn_8+0xad>
     916:	xor    ecx,ecx
     918:	test   rax,0x7
     91e:	je     92c <botlish_fn_8+0x60>
     924:	mov    r12,rax
     927:	jmp    93a <botlish_fn_8+0x6e>
     92c:	movzx  rcx,BYTE PTR [rax]
     930:	mov    r12,rax
     933:	rex cmp cl,0x8
     937:	sete   cl
     93a:	test   cl,cl
     93c:	jne    95f <botlish_fn_8+0x93>
     942:	mov    rdi,rbx
     945:	mov    rax,QWORD PTR [rdi+0x10]
     949:	mov    rcx,QWORD PTR [rax+0x8]
     94d:	mov    edx,0x8
     952:	mov    rsi,r12
     955:	call   95a <botlish_fn_8+0x8e>
			956: R_X86_64_PLT32	rt_type_error-0x4
     95a:	jmp    979 <botlish_fn_8+0xad>
     95f:	mov    rcx,r13
     962:	mov    rdx,r14
     965:	mov    rdi,rbx
     968:	mov    rsi,r12
     96b:	call   970 <botlish_fn_8+0xa4>
			96c: R_X86_64_PLT32	rt_mutarray_set-0x4
     970:	test   rax,rax
     973:	jne    999 <botlish_fn_8+0xcd>
     979:	xor    rax,rax
     97c:	mov    rbx,QWORD PTR [rsp+0x20]
     981:	mov    r12,QWORD PTR [rsp+0x28]
     986:	mov    r13,QWORD PTR [rsp+0x30]
     98b:	mov    r14,QWORD PTR [rsp+0x38]
     990:	add    rsp,0x40
     994:	mov    rsp,rbp
     997:	pop    rbp
     998:	ret
     999:	mov    rax,r12
     99c:	mov    rbx,QWORD PTR [rsp+0x20]
     9a1:	mov    r12,QWORD PTR [rsp+0x28]
     9a6:	mov    r13,QWORD PTR [rsp+0x30]
     9ab:	mov    r14,QWORD PTR [rsp+0x38]
     9b0:	add    rsp,0x40
     9b4:	mov    rsp,rbp
     9b7:	pop    rbp
     9b8:	ret

00000000000009b9 <botlish_entry_8: geo_append<mutarray, int, str>>:
     9b9:	push   rbp
     9ba:	mov    rbp,rsp
     9bd:	mov    rsi,QWORD PTR [rdx]
     9c0:	mov    r8,QWORD PTR [rdx+0x8]
     9c4:	mov    rcx,QWORD PTR [rdx+0x10]
     9c8:	mov    rdx,r8
     9cb:	call   9d0 <botlish_entry_8+0x17>
			9cc: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
     9d0:	mov    rsp,rbp
     9d3:	pop    rbp
     9d4:	ret

00000000000009d5 <botlish_fn_9: geo_append<mutarray, int, List[str]>>:
     9d5:	push   rbp
     9d6:	mov    rbp,rsp
     9d9:	sub    rsp,0x40
     9dd:	mov    QWORD PTR [rsp+0x20],rbx
     9e2:	mov    QWORD PTR [rsp+0x28],r12
     9e7:	mov    QWORD PTR [rsp+0x30],r13
     9ec:	mov    QWORD PTR [rsp+0x38],r14
     9f1:	mov    rbx,rdi
     9f4:	mov    QWORD PTR [rsp],rsi
     9f8:	mov    QWORD PTR [rsp+0x8],rdx
     9fd:	mov    r14,rdx
     a00:	mov    QWORD PTR [rsp+0x10],rcx
     a05:	mov    r13,rcx
     a08:	mov    rcx,r13
     a0b:	mov    rdx,r14
     a0e:	mov    rdi,rbx
     a11:	call   a16 <botlish_fn_9+0x41>
			a12: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_grow<mutarray, int, List[str]>
     a16:	test   rax,rax
     a19:	je     a82 <botlish_fn_9+0xad>
     a1f:	xor    ecx,ecx
     a21:	test   rax,0x7
     a27:	je     a35 <botlish_fn_9+0x60>
     a2d:	mov    r12,rax
     a30:	jmp    a43 <botlish_fn_9+0x6e>
     a35:	movzx  rcx,BYTE PTR [rax]
     a39:	mov    r12,rax
     a3c:	rex cmp cl,0x8
     a40:	sete   cl
     a43:	test   cl,cl
     a45:	jne    a68 <botlish_fn_9+0x93>
     a4b:	mov    rdi,rbx
     a4e:	mov    rax,QWORD PTR [rdi+0x10]
     a52:	mov    rcx,QWORD PTR [rax+0x8]
     a56:	mov    edx,0x8
     a5b:	mov    rsi,r12
     a5e:	call   a63 <botlish_fn_9+0x8e>
			a5f: R_X86_64_PLT32	rt_type_error-0x4
     a63:	jmp    a82 <botlish_fn_9+0xad>
     a68:	mov    rcx,r13
     a6b:	mov    rdx,r14
     a6e:	mov    rdi,rbx
     a71:	mov    rsi,r12
     a74:	call   a79 <botlish_fn_9+0xa4>
			a75: R_X86_64_PLT32	rt_mutarray_set-0x4
     a79:	test   rax,rax
     a7c:	jne    aa2 <botlish_fn_9+0xcd>
     a82:	xor    rax,rax
     a85:	mov    rbx,QWORD PTR [rsp+0x20]
     a8a:	mov    r12,QWORD PTR [rsp+0x28]
     a8f:	mov    r13,QWORD PTR [rsp+0x30]
     a94:	mov    r14,QWORD PTR [rsp+0x38]
     a99:	add    rsp,0x40
     a9d:	mov    rsp,rbp
     aa0:	pop    rbp
     aa1:	ret
     aa2:	mov    rax,r12
     aa5:	mov    rbx,QWORD PTR [rsp+0x20]
     aaa:	mov    r12,QWORD PTR [rsp+0x28]
     aaf:	mov    r13,QWORD PTR [rsp+0x30]
     ab4:	mov    r14,QWORD PTR [rsp+0x38]
     ab9:	add    rsp,0x40
     abd:	mov    rsp,rbp
     ac0:	pop    rbp
     ac1:	ret

0000000000000ac2 <botlish_entry_9: geo_append<mutarray, int, List[str]>>:
     ac2:	push   rbp
     ac3:	mov    rbp,rsp
     ac6:	mov    rsi,QWORD PTR [rdx]
     ac9:	mov    r8,QWORD PTR [rdx+0x8]
     acd:	mov    rcx,QWORD PTR [rdx+0x10]
     ad1:	mov    rdx,r8
     ad4:	call   ad9 <botlish_entry_9+0x17>
			ad5: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
     ad9:	mov    rsp,rbp
     adc:	pop    rbp
     add:	ret

0000000000000ade <botlish_fn_10: geo_finish<mutarray, int>>:
     ade:	push   rbp
     adf:	mov    rbp,rsp
     ae2:	sub    rsp,0x10
     ae6:	mov    QWORD PTR [rsp],rsi
     aea:	mov    QWORD PTR [rsp+0x8],rdx
     aef:	call   af4 <botlish_fn_10+0x16>
			af0: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     af4:	test   rax,rax
     af7:	jne    b09 <botlish_fn_10+0x2b>
     afd:	xor    rax,rax
     b00:	add    rsp,0x10
     b04:	mov    rsp,rbp
     b07:	pop    rbp
     b08:	ret
     b09:	add    rsp,0x10
     b0d:	mov    rsp,rbp
     b10:	pop    rbp
     b11:	ret

0000000000000b12 <botlish_entry_10: geo_finish<mutarray, int>>:
     b12:	push   rbp
     b13:	mov    rbp,rsp
     b16:	mov    rsi,QWORD PTR [rdx]
     b19:	mov    rdx,QWORD PTR [rdx+0x8]
     b1d:	call   b22 <botlish_entry_10+0x10>
			b1e: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
     b22:	mov    rsp,rbp
     b25:	pop    rbp
     b26:	ret
	...

0000000000000b28 <botlish_fn_11: peek<str, int>>:
     b28:	push   rbp
     b29:	mov    rbp,rsp
     b2c:	sub    rsp,0x40
     b30:	mov    QWORD PTR [rsp+0x20],rbx
     b35:	mov    QWORD PTR [rsp+0x28],r12
     b3a:	mov    QWORD PTR [rsp+0x30],r13
     b3f:	mov    r13,rdi
     b42:	mov    QWORD PTR [rsp],rsi
     b46:	mov    r12,rsi
     b49:	mov    QWORD PTR [rsp+0x8],rdx
     b4e:	mov    rbx,rdx
     b51:	mov    rsi,r12
     b54:	mov    rdi,r13
     b57:	call   b5c <botlish_fn_11+0x34>
			b58: R_X86_64_PLT32	rt_str_len-0x4
     b5c:	mov    rcx,rbx
     b5f:	and    rcx,rax
     b62:	mov    rdx,rax
     b65:	test   rcx,0x1
     b6c:	jne    b92 <botlish_fn_11+0x6a>
     b72:	mov    rsi,rbx
     b75:	mov    rdi,r13
     b78:	call   b7d <botlish_fn_11+0x55>
			b79: R_X86_64_PLT32	rt_int_cmp-0x4
     b7d:	mov    ecx,0x2
     b82:	test   rax,rax
     b85:	cmovge rcx,QWORD PTR [rip+0xd3]        # c60 <botlish_fn_11+0x138>
     b8d:	jmp    ba2 <botlish_fn_11+0x7a>
     b92:	mov    ecx,0x2
     b97:	cmp    rbx,rdx
     b9a:	cmovge rcx,QWORD PTR [rip+0xbe]        # c60 <botlish_fn_11+0x138>
     ba2:	cmp    rcx,0x6
     ba6:	je     c36 <botlish_fn_11+0x10e>
     bac:	mov    QWORD PTR [rsp+0x10],0x3
     bb5:	test   rbx,0x1
     bbc:	je     bd4 <botlish_fn_11+0xac>
     bc2:	mov    rcx,rbx
     bc5:	add    rcx,0x2
     bc9:	seto   al
     bcc:	test   al,al
     bce:	je     be7 <botlish_fn_11+0xbf>
     bd4:	mov    edx,0x3
     bd9:	mov    rsi,rbx
     bdc:	mov    rdi,r13
     bdf:	call   be4 <botlish_fn_11+0xbc>
			be0: R_X86_64_PLT32	rt_int_add-0x4
     be4:	mov    rcx,rax
     be7:	mov    QWORD PTR [rsp+0x10],rcx
     bec:	mov    rdx,rbx
     bef:	mov    rsi,r12
     bf2:	mov    rdi,r13
     bf5:	call   bfa <botlish_fn_11+0xd2>
			bf6: R_X86_64_PLT32	rt_substr-0x4
     bfa:	test   rax,rax
     bfd:	jne    c1e <botlish_fn_11+0xf6>
     c03:	xor    rax,rax
     c06:	mov    rbx,QWORD PTR [rsp+0x20]
     c0b:	mov    r12,QWORD PTR [rsp+0x28]
     c10:	mov    r13,QWORD PTR [rsp+0x30]
     c15:	add    rsp,0x40
     c19:	mov    rsp,rbp
     c1c:	pop    rbp
     c1d:	ret
     c1e:	mov    rbx,QWORD PTR [rsp+0x20]
     c23:	mov    r12,QWORD PTR [rsp+0x28]
     c28:	mov    r13,QWORD PTR [rsp+0x30]
     c2d:	add    rsp,0x40
     c31:	mov    rsp,rbp
     c34:	pop    rbp
     c35:	ret
     c36:	mov    rdi,r13
     c39:	mov    rax,QWORD PTR [rdi+0x10]
     c3d:	mov    rax,QWORD PTR [rax+0x10]
     c41:	mov    rbx,QWORD PTR [rsp+0x20]
     c46:	mov    r12,QWORD PTR [rsp+0x28]
     c4b:	mov    r13,QWORD PTR [rsp+0x30]
     c50:	add    rsp,0x40
     c54:	mov    rsp,rbp
     c57:	pop    rbp
     c58:	ret
     c59:	add    BYTE PTR [rax],al
     c5b:	add    BYTE PTR [rax],al
     c5d:	add    BYTE PTR [rax],al
     c5f:	add    BYTE PTR [rsi],al
     c61:	add    BYTE PTR [rax],al
     c63:	add    BYTE PTR [rax],al
     c65:	add    BYTE PTR [rax],al
	...

0000000000000c68 <botlish_entry_11: peek<str, int>>:
     c68:	push   rbp
     c69:	mov    rbp,rsp
     c6c:	mov    rsi,QWORD PTR [rdx]
     c6f:	mov    rdx,QWORD PTR [rdx+0x8]
     c73:	call   c78 <botlish_entry_11+0x10>
			c74: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
     c78:	mov    rsp,rbp
     c7b:	pop    rbp
     c7c:	ret
     c7d:	add    BYTE PTR [rax],al
	...

0000000000000c80 <botlish_fn_12: peek<str, int>>:
     c80:	push   rbp
     c81:	mov    rbp,rsp
     c84:	sub    rsp,0x50
     c88:	mov    QWORD PTR [rsp+0x20],rbx
     c8d:	mov    QWORD PTR [rsp+0x28],r12
     c92:	mov    QWORD PTR [rsp+0x30],r13
     c97:	mov    QWORD PTR [rsp+0x38],r14
     c9c:	mov    QWORD PTR [rsp+0x40],r15
     ca1:	mov    r12,rcx
     ca4:	mov    r14,rdi
     ca7:	mov    QWORD PTR [rsp],rsi
     cab:	mov    r13,rsi
     cae:	mov    QWORD PTR [rsp+0x8],rdx
     cb3:	mov    rbx,rdx
     cb6:	mov    rsi,r13
     cb9:	mov    rdi,r14
     cbc:	call   cc1 <botlish_fn_12+0x41>
			cbd: R_X86_64_PLT32	rt_str_len-0x4
     cc1:	mov    rcx,rbx
     cc4:	and    rcx,rax
     cc7:	mov    rdx,rax
     cca:	test   rcx,0x1
     cd1:	jne    cf7 <botlish_fn_12+0x77>
     cd7:	mov    rsi,rbx
     cda:	mov    rdi,r14
     cdd:	call   ce2 <botlish_fn_12+0x62>
			cde: R_X86_64_PLT32	rt_int_cmp-0x4
     ce2:	mov    ecx,0x2
     ce7:	test   rax,rax
     cea:	cmovge rcx,QWORD PTR [rip+0x11e]        # e10 <botlish_fn_12+0x190>
     cf2:	jmp    d07 <botlish_fn_12+0x87>
     cf7:	mov    ecx,0x2
     cfc:	cmp    rbx,rdx
     cff:	cmovge rcx,QWORD PTR [rip+0x109]        # e10 <botlish_fn_12+0x190>
     d07:	cmp    rcx,0x6
     d0b:	je     dcb <botlish_fn_12+0x14b>
     d11:	mov    QWORD PTR [rsp+0x10],0x3
     d1a:	test   rbx,0x1
     d21:	je     d44 <botlish_fn_12+0xc4>
     d27:	mov    rax,rbx
     d2a:	add    rax,0x2
     d2e:	seto   cl
     d31:	test   cl,cl
     d33:	jne    d44 <botlish_fn_12+0xc4>
     d39:	mov    rdi,r14
     d3c:	mov    r15,rax
     d3f:	jmp    d5a <botlish_fn_12+0xda>
     d44:	mov    edx,0x3
     d49:	mov    rsi,rbx
     d4c:	mov    rdi,r14
     d4f:	call   d54 <botlish_fn_12+0xd4>
			d50: R_X86_64_PLT32	rt_int_add-0x4
     d54:	mov    r15,rax
     d57:	mov    rdi,r14
     d5a:	mov    rdi,r14
     d5d:	mov    rcx,r15
     d60:	mov    rdx,rbx
     d63:	mov    rsi,r13
     d66:	call   d6b <botlish_fn_12+0xeb>
			d67: R_X86_64_PLT32	rt_str_region_check-0x4
     d6b:	test   rax,rax
     d6e:	jne    d99 <botlish_fn_12+0x119>
     d74:	xor    rax,rax
     d77:	mov    rbx,QWORD PTR [rsp+0x20]
     d7c:	mov    r12,QWORD PTR [rsp+0x28]
     d81:	mov    r13,QWORD PTR [rsp+0x30]
     d86:	mov    r14,QWORD PTR [rsp+0x38]
     d8b:	mov    r15,QWORD PTR [rsp+0x40]
     d90:	add    rsp,0x50
     d94:	mov    rsp,rbp
     d97:	pop    rbp
     d98:	ret
     d99:	mov    rcx,r12
     d9c:	mov    QWORD PTR [rcx],rbx
     d9f:	mov    rax,r15
     da2:	mov    QWORD PTR [rcx+0x8],rax
     da6:	mov    rax,r13
     da9:	mov    rbx,QWORD PTR [rsp+0x20]
     dae:	mov    r12,QWORD PTR [rsp+0x28]
     db3:	mov    r13,QWORD PTR [rsp+0x30]
     db8:	mov    r14,QWORD PTR [rsp+0x38]
     dbd:	mov    r15,QWORD PTR [rsp+0x40]
     dc2:	add    rsp,0x50
     dc6:	mov    rsp,rbp
     dc9:	pop    rbp
     dca:	ret
     dcb:	mov    rcx,r12
     dce:	mov    rdi,r14
     dd1:	mov    rax,QWORD PTR [rdi+0x10]
     dd5:	mov    rax,QWORD PTR [rax+0x10]
     dd9:	mov    QWORD PTR [rcx],0x1
     de0:	mov    QWORD PTR [rcx+0x8],0x1
     de8:	mov    rbx,QWORD PTR [rsp+0x20]
     ded:	mov    r12,QWORD PTR [rsp+0x28]
     df2:	mov    r13,QWORD PTR [rsp+0x30]
     df7:	mov    r14,QWORD PTR [rsp+0x38]
     dfc:	mov    r15,QWORD PTR [rsp+0x40]
     e01:	add    rsp,0x50
     e05:	mov    rsp,rbp
     e08:	pop    rbp
     e09:	ret
     e0a:	add    BYTE PTR [rax],al
     e0c:	add    BYTE PTR [rax],al
     e0e:	add    BYTE PTR [rax],al
     e10:	(bad)
     e11:	add    BYTE PTR [rax],al
     e13:	add    BYTE PTR [rax],al
     e15:	add    BYTE PTR [rax],al
	...

0000000000000e18 <botlish_entry_12: peek<str, int>>:
     e18:	push   rbp
     e19:	mov    rbp,rsp
     e1c:	ud2

0000000000000e1e <botlish_fn_13: scan_unquoted<str, int, int>>:
     e1e:	push   rbp
     e1f:	mov    rbp,rsp
     e22:	sub    rsp,0x80
     e29:	mov    QWORD PTR [rsp+0x50],rbx
     e2e:	mov    QWORD PTR [rsp+0x58],r12
     e33:	mov    QWORD PTR [rsp+0x60],r13
     e38:	mov    QWORD PTR [rsp+0x68],r14
     e3d:	mov    QWORD PTR [rsp+0x70],r15
     e42:	mov    QWORD PTR [rsp+0x30],rdi
     e47:	mov    QWORD PTR [rsp+0x18],0x0
     e50:	mov    QWORD PTR [rsp],rsi
     e54:	mov    r15,rsi
     e57:	mov    QWORD PTR [rsp+0x8],rdx
     e5c:	mov    r14,rdx
     e5f:	mov    QWORD PTR [rsp+0x10],rcx
     e64:	lea    r13,[rsp+0x20]
     e69:	mov    QWORD PTR [rsp+0x38],rcx
     e6e:	mov    rcx,r13
     e71:	mov    rdx,QWORD PTR [rsp+0x38]
     e76:	mov    rsi,r15
     e79:	mov    rdi,QWORD PTR [rsp+0x30]
     e7e:	call   e83 <botlish_fn_13+0x65>
			e7f: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
     e83:	mov    rsi,rax
     e86:	mov    QWORD PTR [rsp+0x40],rax
     e8b:	test   rax,rsi
     e8e:	je     fe8 <botlish_fn_13+0x1ca>
     e94:	mov    rbx,QWORD PTR [rsp+0x20]
     e99:	mov    r12,QWORD PTR [rsp+0x28]
     e9e:	mov    rdi,QWORD PTR [rsp+0x30]
     ea3:	mov    rcx,QWORD PTR [rdi+0x10]
     ea7:	mov    r8,QWORD PTR [rcx+0x10]
     eab:	mov    rcx,r12
     eae:	mov    rdx,rbx
     eb1:	mov    rsi,QWORD PTR [rsp+0x40]
     eb6:	call   ebb <botlish_fn_13+0x9d>
			eb7: R_X86_64_PLT32	rt_str_region_eq-0x4
     ebb:	cmp    rax,0x6
     ebf:	je     f00 <botlish_fn_13+0xe2>
     ec5:	mov    rdi,QWORD PTR [rsp+0x30]
     eca:	mov    rax,QWORD PTR [rdi+0x10]
     ece:	mov    r8,QWORD PTR [rax+0x18]
     ed2:	mov    rcx,r12
     ed5:	mov    rdx,rbx
     ed8:	mov    rsi,QWORD PTR [rsp+0x40]
     edd:	call   ee2 <botlish_fn_13+0xc4>
			ede: R_X86_64_PLT32	rt_str_region_eq-0x4
     ee2:	cmp    rax,0x6
     ee6:	je     ef6 <botlish_fn_13+0xd8>
     eec:	mov    eax,0x2
     ef1:	jmp    f05 <botlish_fn_13+0xe7>
     ef6:	mov    eax,0x6
     efb:	jmp    f05 <botlish_fn_13+0xe7>
     f00:	mov    eax,0x6
     f05:	cmp    rax,0x6
     f09:	je     f4a <botlish_fn_13+0x12c>
     f0f:	mov    rdi,QWORD PTR [rsp+0x30]
     f14:	mov    rax,QWORD PTR [rdi+0x10]
     f18:	mov    r8,QWORD PTR [rax+0x20]
     f1c:	mov    rcx,r12
     f1f:	mov    rdx,rbx
     f22:	mov    rsi,QWORD PTR [rsp+0x40]
     f27:	call   f2c <botlish_fn_13+0x10e>
			f28: R_X86_64_PLT32	rt_str_region_eq-0x4
     f2c:	cmp    rax,0x6
     f30:	je     f40 <botlish_fn_13+0x122>
     f36:	mov    eax,0x2
     f3b:	jmp    f4f <botlish_fn_13+0x131>
     f40:	mov    eax,0x6
     f45:	jmp    f4f <botlish_fn_13+0x131>
     f4a:	mov    eax,0x6
     f4f:	cmp    rax,0x6
     f53:	je     fca <botlish_fn_13+0x1ac>
     f59:	mov    QWORD PTR [rsp+0x18],0x3
     f62:	mov    rsi,QWORD PTR [rsp+0x38]
     f67:	test   rsi,0x1
     f6e:	je     f95 <botlish_fn_13+0x177>
     f74:	mov    rsi,QWORD PTR [rsp+0x38]
     f79:	mov    rax,rsi
     f7c:	add    rax,0x2
     f80:	seto   sil
     f84:	test   sil,sil
     f87:	jne    f95 <botlish_fn_13+0x177>
     f8d:	mov    rsi,r15
     f90:	jmp    fac <botlish_fn_13+0x18e>
     f95:	mov    edx,0x3
     f9a:	mov    rsi,QWORD PTR [rsp+0x38]
     f9f:	mov    rdi,QWORD PTR [rsp+0x30]
     fa4:	call   fa9 <botlish_fn_13+0x18b>
			fa5: R_X86_64_PLT32	rt_int_add-0x4
     fa9:	mov    rsi,r15
     fac:	mov    QWORD PTR [rsp],rsi
     fb0:	mov    rdx,r14
     fb3:	mov    QWORD PTR [rsp+0x8],rdx
     fb8:	mov    QWORD PTR [rsp+0x10],rax
     fbd:	mov    r15,rsi
     fc0:	mov    QWORD PTR [rsp+0x38],rax
     fc5:	jmp    e6e <botlish_fn_13+0x50>
     fca:	mov    rdx,r14
     fcd:	mov    rsi,r15
     fd0:	mov    rdi,QWORD PTR [rsp+0x30]
     fd5:	mov    rcx,QWORD PTR [rsp+0x38]
     fda:	call   fdf <botlish_fn_13+0x1c1>
			fdb: R_X86_64_PLT32	rt_substr-0x4
     fdf:	test   rax,rax
     fe2:	jne    1013 <botlish_fn_13+0x1f5>
     fe8:	xor    rdx,rdx
     feb:	mov    rax,rdx
     fee:	mov    rbx,QWORD PTR [rsp+0x50]
     ff3:	mov    r12,QWORD PTR [rsp+0x58]
     ff8:	mov    r13,QWORD PTR [rsp+0x60]
     ffd:	mov    r14,QWORD PTR [rsp+0x68]
    1002:	mov    r15,QWORD PTR [rsp+0x70]
    1007:	add    rsp,0x80
    100e:	mov    rsp,rbp
    1011:	pop    rbp
    1012:	ret
    1013:	mov    rdx,QWORD PTR [rsp+0x38]
    1018:	mov    rbx,QWORD PTR [rsp+0x50]
    101d:	mov    r12,QWORD PTR [rsp+0x58]
    1022:	mov    r13,QWORD PTR [rsp+0x60]
    1027:	mov    r14,QWORD PTR [rsp+0x68]
    102c:	mov    r15,QWORD PTR [rsp+0x70]
    1031:	add    rsp,0x80
    1038:	mov    rsp,rbp
    103b:	pop    rbp
    103c:	ret

000000000000103d <botlish_entry_13: scan_unquoted<str, int, int>>:
    103d:	push   rbp
    103e:	mov    rbp,rsp
    1041:	ud2

0000000000001043 <botlish_fn_14: scan_quoted<str, int, str>>:
    1043:	push   rbp
    1044:	mov    rbp,rsp
    1047:	sub    rsp,0xd0
    104e:	mov    QWORD PTR [rsp+0xa0],rbx
    1056:	mov    QWORD PTR [rsp+0xa8],r12
    105e:	mov    QWORD PTR [rsp+0xb0],r13
    1066:	mov    QWORD PTR [rsp+0xb8],r14
    106e:	mov    QWORD PTR [rsp+0xc0],r15
    1076:	mov    r15,rdi
    1079:	mov    QWORD PTR [rsp+0x18],0x0
    1082:	mov    QWORD PTR [rsp+0x20],0x0
    108b:	mov    QWORD PTR [rsp],rsi
    108f:	mov    QWORD PTR [rsp+0x8],rdx
    1094:	mov    QWORD PTR [rsp+0x10],rcx
    1099:	mov    r13,rcx
    109c:	lea    r14,[rsp+0x68]
    10a1:	lea    rbx,[rsp+0x28]
    10a6:	mov    r12,rsi
    10a9:	mov    QWORD PTR [rsp+0x88],rdx
    10b1:	mov    rdx,QWORD PTR [rsp+0x88]
    10b9:	mov    rsi,r12
    10bc:	mov    rdi,r15
    10bf:	call   10c4 <botlish_fn_14+0x81>
			10c0: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    10c4:	test   rax,rax
    10c7:	je     13cb <botlish_fn_14+0x388>
    10cd:	mov    QWORD PTR [rsp+0x18],rax
    10d2:	mov    rdi,r15
    10d5:	mov    QWORD PTR [rsp+0x90],rax
    10dd:	mov    rsi,QWORD PTR [rdi+0x10]
    10e1:	mov    rsi,QWORD PTR [rsi+0x28]
    10e5:	mov    edx,0x1
    10ea:	mov    ecx,0x3
    10ef:	mov    r8,QWORD PTR [rsp+0x90]
    10f7:	call   10fc <botlish_fn_14+0xb9>
			10f8: R_X86_64_PLT32	rt_str_region_eq-0x4
    10fc:	cmp    rax,0x6
    1100:	je     11c0 <botlish_fn_14+0x17d>
    1106:	mov    QWORD PTR [rsp+0x20],0x3
    110f:	mov    rsi,QWORD PTR [rsp+0x88]
    1117:	test   rsi,0x1
    111e:	je     1140 <botlish_fn_14+0xfd>
    1124:	mov    r9,rsi
    1127:	add    r9,0x2
    112b:	seto   r11b
    112f:	test   r11b,r11b
    1132:	jne    1140 <botlish_fn_14+0xfd>
    1138:	mov    rsi,r9
    113b:	jmp    1150 <botlish_fn_14+0x10d>
    1140:	mov    edx,0x3
    1145:	mov    rdi,r15
    1148:	call   114d <botlish_fn_14+0x10a>
			1149: R_X86_64_PLT32	rt_int_add-0x4
    114d:	mov    rsi,rax
    1150:	mov    QWORD PTR [rsp+0x8],rsi
    1155:	mov    QWORD PTR [rsp+0x88],rsi
    115d:	mov    QWORD PTR [rsp+0x68],0x0
    1166:	mov    QWORD PTR [rsp+0x70],r13
    116b:	mov    QWORD PTR [rsp+0x78],0x0
    1174:	mov    rax,QWORD PTR [rsp+0x90]
    117c:	mov    QWORD PTR [rsp+0x80],rax
    1184:	mov    esi,0x2
    1189:	mov    edx,0x4
    118e:	mov    rcx,r14
    1191:	mov    rdi,r15
    1194:	call   1199 <botlish_fn_14+0x156>
			1195: R_X86_64_PLT32	rt_construct-0x4
    1199:	test   rax,rax
    119c:	je     13cb <botlish_fn_14+0x388>
    11a2:	mov    QWORD PTR [rsp],r12
    11a6:	mov    rsi,QWORD PTR [rsp+0x88]
    11ae:	mov    QWORD PTR [rsp+0x8],rsi
    11b3:	mov    QWORD PTR [rsp+0x10],rax
    11b8:	mov    r13,rax
    11bb:	jmp    10b1 <botlish_fn_14+0x6e>
    11c0:	mov    QWORD PTR [rsp+0x18],0x3
    11c9:	mov    rsi,QWORD PTR [rsp+0x88]
    11d1:	test   rsi,0x1
    11d8:	je     11f8 <botlish_fn_14+0x1b5>
    11de:	mov    rsi,QWORD PTR [rsp+0x88]
    11e6:	mov    rdx,rsi
    11e9:	add    rdx,0x2
    11ed:	seto   al
    11f0:	test   al,al
    11f2:	je     1210 <botlish_fn_14+0x1cd>
    11f8:	mov    edx,0x3
    11fd:	mov    rsi,QWORD PTR [rsp+0x88]
    1205:	mov    rdi,r15
    1208:	call   120d <botlish_fn_14+0x1ca>
			1209: R_X86_64_PLT32	rt_int_add-0x4
    120d:	mov    rdx,rax
    1210:	mov    QWORD PTR [rsp+0x18],rdx
    1215:	mov    rcx,rbx
    1218:	mov    rsi,r12
    121b:	mov    rdi,r15
    121e:	call   1223 <botlish_fn_14+0x1e0>
			121f: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1223:	test   rax,rax
    1226:	mov    rsi,rax
    1229:	je     13cb <botlish_fn_14+0x388>
    122f:	mov    rdx,QWORD PTR [rsp+0x28]
    1234:	mov    rcx,QWORD PTR [rsp+0x30]
    1239:	mov    rdi,r15
    123c:	mov    rax,QWORD PTR [rdi+0x10]
    1240:	mov    r8,QWORD PTR [rax+0x28]
    1244:	call   1249 <botlish_fn_14+0x206>
			1245: R_X86_64_PLT32	rt_str_region_eq-0x4
    1249:	cmp    rax,0x6
    124d:	je     1315 <botlish_fn_14+0x2d2>
    1253:	xor    rsi,rsi
    1256:	lea    rcx,[rsp+0x58]
    125b:	mov    QWORD PTR [rsp+0x58],0x0
    1264:	mov    QWORD PTR [rsp+0x60],r13
    1269:	mov    edx,0x2
    126e:	mov    rdi,r15
    1271:	call   1276 <botlish_fn_14+0x233>
			1272: R_X86_64_PLT32	rt_construct-0x4
    1276:	test   rax,rax
    1279:	je     13cb <botlish_fn_14+0x388>
    127f:	mov    QWORD PTR [rsp],rax
    1283:	mov    rbx,rax
    1286:	mov    QWORD PTR [rsp+0x10],0x3
    128f:	mov    rsi,QWORD PTR [rsp+0x88]
    1297:	test   rsi,0x1
    129e:	je     12c6 <botlish_fn_14+0x283>
    12a4:	mov    rsi,QWORD PTR [rsp+0x88]
    12ac:	mov    rdx,rsi
    12af:	add    rdx,0x2
    12b3:	seto   al
    12b6:	test   al,al
    12b8:	jne    12c6 <botlish_fn_14+0x283>
    12be:	mov    rax,rbx
    12c1:	jmp    12e1 <botlish_fn_14+0x29e>
    12c6:	mov    edx,0x3
    12cb:	mov    rsi,QWORD PTR [rsp+0x88]
    12d3:	mov    rdi,r15
    12d6:	call   12db <botlish_fn_14+0x298>
			12d7: R_X86_64_PLT32	rt_int_add-0x4
    12db:	mov    rdx,rax
    12de:	mov    rax,rbx
    12e1:	mov    rbx,QWORD PTR [rsp+0xa0]
    12e9:	mov    r12,QWORD PTR [rsp+0xa8]
    12f1:	mov    r13,QWORD PTR [rsp+0xb0]
    12f9:	mov    r14,QWORD PTR [rsp+0xb8]
    1301:	mov    r15,QWORD PTR [rsp+0xc0]
    1309:	add    rsp,0xd0
    1310:	mov    rsp,rbp
    1313:	pop    rbp
    1314:	ret
    1315:	mov    QWORD PTR [rsp+0x18],0x5
    131e:	mov    rsi,QWORD PTR [rsp+0x88]
    1326:	test   rsi,0x1
    132d:	je     135d <botlish_fn_14+0x31a>
    1333:	mov    rsi,QWORD PTR [rsp+0x88]
    133b:	mov    rax,rsi
    133e:	add    rax,0x4
    1342:	seto   cl
    1345:	test   cl,cl
    1347:	jne    135d <botlish_fn_14+0x31a>
    134d:	mov    rsi,rax
    1350:	mov    QWORD PTR [rsp+0x88],rax
    1358:	jmp    137d <botlish_fn_14+0x33a>
    135d:	mov    edx,0x5
    1362:	mov    rsi,QWORD PTR [rsp+0x88]
    136a:	mov    rdi,r15
    136d:	call   1372 <botlish_fn_14+0x32f>
			136e: R_X86_64_PLT32	rt_int_add-0x4
    1372:	mov    rsi,rax
    1375:	mov    QWORD PTR [rsp+0x88],rax
    137d:	mov    QWORD PTR [rsp+0x8],rsi
    1382:	mov    rdi,r15
    1385:	mov    rsi,QWORD PTR [rdi+0x10]
    1389:	mov    rsi,QWORD PTR [rsi+0x28]
    138d:	mov    QWORD PTR [rsp+0x18],rsi
    1392:	lea    rcx,[rsp+0x38]
    1397:	mov    QWORD PTR [rsp+0x38],0x0
    13a0:	mov    QWORD PTR [rsp+0x40],r13
    13a5:	mov    QWORD PTR [rsp+0x48],0x0
    13ae:	mov    QWORD PTR [rsp+0x50],rsi
    13b3:	mov    esi,0x2
    13b8:	mov    edx,0x4
    13bd:	call   13c2 <botlish_fn_14+0x37f>
			13be: R_X86_64_PLT32	rt_construct-0x4
    13c2:	test   rax,rax
    13c5:	jne    1405 <botlish_fn_14+0x3c2>
    13cb:	xor    rdx,rdx
    13ce:	mov    rax,rdx
    13d1:	mov    rbx,QWORD PTR [rsp+0xa0]
    13d9:	mov    r12,QWORD PTR [rsp+0xa8]
    13e1:	mov    r13,QWORD PTR [rsp+0xb0]
    13e9:	mov    r14,QWORD PTR [rsp+0xb8]
    13f1:	mov    r15,QWORD PTR [rsp+0xc0]
    13f9:	add    rsp,0xd0
    1400:	mov    rsp,rbp
    1403:	pop    rbp
    1404:	ret
    1405:	mov    QWORD PTR [rsp],r12
    1409:	mov    rsi,QWORD PTR [rsp+0x88]
    1411:	mov    QWORD PTR [rsp+0x8],rsi
    1416:	mov    QWORD PTR [rsp+0x10],rax
    141b:	mov    r13,rax
    141e:	jmp    10b1 <botlish_fn_14+0x6e>

0000000000001423 <botlish_entry_14: scan_quoted<str, int, str>>:
    1423:	push   rbp
    1424:	mov    rbp,rsp
    1427:	ud2

0000000000001429 <botlish_fn_15: scan_field<str, int>>:
    1429:	push   rbp
    142a:	mov    rbp,rsp
    142d:	sub    rsp,0x50
    1431:	mov    QWORD PTR [rsp+0x30],rbx
    1436:	mov    QWORD PTR [rsp+0x38],r12
    143b:	mov    QWORD PTR [rsp+0x40],r13
    1440:	mov    r12,rdi
    1443:	mov    r13,rdx
    1446:	mov    QWORD PTR [rsp+0x10],0x0
    144f:	mov    QWORD PTR [rsp],rsi
    1453:	mov    rbx,rsi
    1456:	mov    QWORD PTR [rsp+0x8],rdx
    145b:	lea    rcx,[rsp+0x18]
    1460:	mov    rdx,r13
    1463:	mov    rsi,rbx
    1466:	mov    rdi,r12
    1469:	call   146e <botlish_fn_15+0x45>
			146a: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    146e:	test   rax,rax
    1471:	mov    rsi,rax
    1474:	je     153f <botlish_fn_15+0x116>
    147a:	mov    rdx,QWORD PTR [rsp+0x18]
    147f:	mov    rcx,QWORD PTR [rsp+0x20]
    1484:	mov    rdi,r12
    1487:	mov    rax,QWORD PTR [rdi+0x10]
    148b:	mov    r8,QWORD PTR [rax+0x28]
    148f:	call   1494 <botlish_fn_15+0x6b>
			1490: R_X86_64_PLT32	rt_str_region_eq-0x4
    1494:	cmp    rax,0x6
    1498:	je     14d0 <botlish_fn_15+0xa7>
    149e:	mov    rcx,r13
    14a1:	mov    rsi,rbx
    14a4:	mov    rdi,r12
    14a7:	mov    rdx,rcx
    14aa:	call   14af <botlish_fn_15+0x86>
			14ab: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    14af:	test   rax,rax
    14b2:	je     153f <botlish_fn_15+0x116>
    14b8:	mov    rbx,QWORD PTR [rsp+0x30]
    14bd:	mov    r12,QWORD PTR [rsp+0x38]
    14c2:	mov    r13,QWORD PTR [rsp+0x40]
    14c7:	add    rsp,0x50
    14cb:	mov    rsp,rbp
    14ce:	pop    rbp
    14cf:	ret
    14d0:	mov    rcx,r13
    14d3:	mov    QWORD PTR [rsp+0x10],0x3
    14dc:	test   rcx,0x1
    14e3:	jne    14f1 <botlish_fn_15+0xc8>
    14e9:	mov    r13,rcx
    14ec:	jmp    1506 <botlish_fn_15+0xdd>
    14f1:	mov    rdx,rcx
    14f4:	add    rdx,0x2
    14f8:	mov    r13,rcx
    14fb:	seto   al
    14fe:	test   al,al
    1500:	je     1519 <botlish_fn_15+0xf0>
    1506:	mov    edx,0x3
    150b:	mov    rsi,r13
    150e:	mov    rdi,r12
    1511:	call   1516 <botlish_fn_15+0xed>
			1512: R_X86_64_PLT32	rt_int_add-0x4
    1516:	mov    rdx,rax
    1519:	mov    QWORD PTR [rsp+0x8],rdx
    151e:	mov    rdi,r12
    1521:	mov    rax,QWORD PTR [rdi+0x10]
    1525:	mov    rcx,QWORD PTR [rax+0x10]
    1529:	mov    QWORD PTR [rsp+0x10],rcx
    152e:	mov    rsi,rbx
    1531:	call   1536 <botlish_fn_15+0x10d>
			1532: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    1536:	test   rax,rax
    1539:	jne    155d <botlish_fn_15+0x134>
    153f:	xor    rdx,rdx
    1542:	mov    rax,rdx
    1545:	mov    rbx,QWORD PTR [rsp+0x30]
    154a:	mov    r12,QWORD PTR [rsp+0x38]
    154f:	mov    r13,QWORD PTR [rsp+0x40]
    1554:	add    rsp,0x50
    1558:	mov    rsp,rbp
    155b:	pop    rbp
    155c:	ret
    155d:	mov    rbx,QWORD PTR [rsp+0x30]
    1562:	mov    r12,QWORD PTR [rsp+0x38]
    1567:	mov    r13,QWORD PTR [rsp+0x40]
    156c:	add    rsp,0x50
    1570:	mov    rsp,rbp
    1573:	pop    rbp
    1574:	ret

0000000000001575 <botlish_entry_15: scan_field<str, int>>:
    1575:	push   rbp
    1576:	mov    rbp,rsp
    1579:	ud2

000000000000157b <botlish_fn_16: scan_record_rest<str, int, mutarray, int>>:
    157b:	push   rbp
    157c:	mov    rbp,rsp
    157f:	sub    rsp,0x90
    1586:	mov    QWORD PTR [rsp+0x60],rbx
    158b:	mov    QWORD PTR [rsp+0x68],r12
    1590:	mov    QWORD PTR [rsp+0x70],r13
    1595:	mov    QWORD PTR [rsp+0x78],r14
    159a:	mov    QWORD PTR [rsp+0x80],r15
    15a2:	mov    r15,rdi
    15a5:	mov    QWORD PTR [rsp+0x20],0x0
    15ae:	mov    QWORD PTR [rsp],rsi
    15b2:	mov    QWORD PTR [rsp+0x8],rdx
    15b7:	mov    QWORD PTR [rsp+0x10],rcx
    15bc:	mov    QWORD PTR [rsp+0x18],r8
    15c1:	lea    r12,[rsp+0x28]
    15c6:	mov    rbx,rsi
    15c9:	mov    QWORD PTR [rsp+0x38],rdx
    15ce:	mov    QWORD PTR [rsp+0x40],rcx
    15d3:	mov    QWORD PTR [rsp+0x48],r8
    15d8:	mov    rcx,r12
    15db:	mov    rdx,QWORD PTR [rsp+0x38]
    15e0:	mov    rsi,rbx
    15e3:	mov    rdi,r15
    15e6:	call   15eb <botlish_fn_16+0x70>
			15e7: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    15eb:	test   rax,rax
    15ee:	mov    QWORD PTR [rsp+0x50],rax
    15f3:	je     17b7 <botlish_fn_16+0x23c>
    15f9:	mov    r14,QWORD PTR [rsp+0x28]
    15fe:	mov    r13,QWORD PTR [rsp+0x30]
    1603:	mov    rdi,r15
    1606:	mov    rcx,QWORD PTR [rdi+0x10]
    160a:	mov    r8,QWORD PTR [rcx+0x18]
    160e:	mov    rcx,r13
    1611:	mov    rdx,r14
    1614:	mov    rsi,QWORD PTR [rsp+0x50]
    1619:	call   161e <botlish_fn_16+0xa3>
			161a: R_X86_64_PLT32	rt_str_region_eq-0x4
    161e:	cmp    rax,0x6
    1622:	je     1730 <botlish_fn_16+0x1b5>
    1628:	mov    rdi,r15
    162b:	mov    rax,QWORD PTR [rdi+0x10]
    162f:	mov    r8,QWORD PTR [rax+0x20]
    1633:	mov    rcx,r13
    1636:	mov    rdx,r14
    1639:	mov    rsi,QWORD PTR [rsp+0x50]
    163e:	call   1643 <botlish_fn_16+0xc8>
			163f: R_X86_64_PLT32	rt_str_region_eq-0x4
    1643:	cmp    rax,0x6
    1647:	je     1695 <botlish_fn_16+0x11a>
    164d:	mov    rdx,QWORD PTR [rsp+0x48]
    1652:	mov    rsi,QWORD PTR [rsp+0x40]
    1657:	mov    rdi,r15
    165a:	call   165f <botlish_fn_16+0xe4>
			165b: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    165f:	test   rax,rax
    1662:	je     17b7 <botlish_fn_16+0x23c>
    1668:	mov    rdx,QWORD PTR [rsp+0x38]
    166d:	mov    rbx,QWORD PTR [rsp+0x60]
    1672:	mov    r12,QWORD PTR [rsp+0x68]
    1677:	mov    r13,QWORD PTR [rsp+0x70]
    167c:	mov    r14,QWORD PTR [rsp+0x78]
    1681:	mov    r15,QWORD PTR [rsp+0x80]
    1689:	add    rsp,0x90
    1690:	mov    rsp,rbp
    1693:	pop    rbp
    1694:	ret
    1695:	mov    rdx,QWORD PTR [rsp+0x48]
    169a:	mov    rsi,QWORD PTR [rsp+0x40]
    169f:	mov    rdi,r15
    16a2:	call   16a7 <botlish_fn_16+0x12c>
			16a3: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    16a7:	test   rax,rax
    16aa:	je     17b7 <botlish_fn_16+0x23c>
    16b0:	mov    QWORD PTR [rsp],rax
    16b4:	mov    rbx,rax
    16b7:	mov    QWORD PTR [rsp+0x10],0x3
    16c0:	mov    rdx,QWORD PTR [rsp+0x38]
    16c5:	test   rdx,0x1
    16cc:	je     16f0 <botlish_fn_16+0x175>
    16d2:	mov    rdx,QWORD PTR [rsp+0x38]
    16d7:	add    rdx,0x2
    16db:	seto   sil
    16df:	test   sil,sil
    16e2:	jne    16f0 <botlish_fn_16+0x175>
    16e8:	mov    rax,rbx
    16eb:	jmp    1708 <botlish_fn_16+0x18d>
    16f0:	mov    edx,0x3
    16f5:	mov    rsi,QWORD PTR [rsp+0x38]
    16fa:	mov    rdi,r15
    16fd:	call   1702 <botlish_fn_16+0x187>
			16fe: R_X86_64_PLT32	rt_int_add-0x4
    1702:	mov    rdx,rax
    1705:	mov    rax,rbx
    1708:	mov    rbx,QWORD PTR [rsp+0x60]
    170d:	mov    r12,QWORD PTR [rsp+0x68]
    1712:	mov    r13,QWORD PTR [rsp+0x70]
    1717:	mov    r14,QWORD PTR [rsp+0x78]
    171c:	mov    r15,QWORD PTR [rsp+0x80]
    1724:	add    rsp,0x90
    172b:	mov    rsp,rbp
    172e:	pop    rbp
    172f:	ret
    1730:	mov    rsi,QWORD PTR [rsp+0x38]
    1735:	mov    edx,0x3
    173a:	mov    r13,rdx
    173d:	mov    QWORD PTR [rsp+0x20],0x3
    1746:	test   rsi,0x1
    174d:	je     1765 <botlish_fn_16+0x1ea>
    1753:	mov    rdx,rsi
    1756:	add    rdx,0x2
    175a:	seto   al
    175d:	test   al,al
    175f:	je     1773 <botlish_fn_16+0x1f8>
    1765:	mov    rdx,r13
    1768:	mov    rdi,r15
    176b:	call   1770 <botlish_fn_16+0x1f5>
			176c: R_X86_64_PLT32	rt_int_add-0x4
    1770:	mov    rdx,rax
    1773:	mov    QWORD PTR [rsp+0x8],rdx
    1778:	mov    rsi,rbx
    177b:	mov    rdi,r15
    177e:	call   1783 <botlish_fn_16+0x208>
			177f: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    1783:	test   rax,rax
    1786:	je     17b7 <botlish_fn_16+0x23c>
    178c:	mov    QWORD PTR [rsp+0x8],rax
    1791:	mov    rcx,rax
    1794:	mov    QWORD PTR [rsp+0x20],rdx
    1799:	mov    rsi,QWORD PTR [rsp+0x40]
    179e:	mov    r14,rdx
    17a1:	mov    rdx,QWORD PTR [rsp+0x48]
    17a6:	mov    rdi,r15
    17a9:	call   17ae <botlish_fn_16+0x233>
			17aa: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
    17ae:	test   rax,rax
    17b1:	jne    17e5 <botlish_fn_16+0x26a>
    17b7:	xor    rdx,rdx
    17ba:	mov    rax,rdx
    17bd:	mov    rbx,QWORD PTR [rsp+0x60]
    17c2:	mov    r12,QWORD PTR [rsp+0x68]
    17c7:	mov    r13,QWORD PTR [rsp+0x70]
    17cc:	mov    r14,QWORD PTR [rsp+0x78]
    17d1:	mov    r15,QWORD PTR [rsp+0x80]
    17d9:	add    rsp,0x90
    17e0:	mov    rsp,rbp
    17e3:	pop    rbp
    17e4:	ret
    17e5:	mov    QWORD PTR [rsp+0x8],rax
    17ea:	mov    QWORD PTR [rsp+0x38],rax
    17ef:	mov    QWORD PTR [rsp+0x10],0x3
    17f8:	mov    rdx,QWORD PTR [rsp+0x48]
    17fd:	test   rdx,0x1
    1804:	jne    1817 <botlish_fn_16+0x29c>
    180a:	mov    rdx,r13
    180d:	mov    rsi,QWORD PTR [rsp+0x48]
    1812:	jmp    1836 <botlish_fn_16+0x2bb>
    1817:	mov    rdx,QWORD PTR [rsp+0x48]
    181c:	mov    rax,rdx
    181f:	add    rax,0x2
    1823:	seto   cl
    1826:	test   cl,cl
    1828:	je     183e <botlish_fn_16+0x2c3>
    182e:	mov    rdx,r13
    1831:	mov    rsi,QWORD PTR [rsp+0x48]
    1836:	mov    rdi,r15
    1839:	call   183e <botlish_fn_16+0x2c3>
			183a: R_X86_64_PLT32	rt_int_add-0x4
    183e:	mov    QWORD PTR [rsp],rbx
    1842:	mov    rdx,r14
    1845:	mov    QWORD PTR [rsp+0x8],rdx
    184a:	mov    rcx,QWORD PTR [rsp+0x38]
    184f:	mov    QWORD PTR [rsp+0x10],rcx
    1854:	mov    QWORD PTR [rsp+0x18],rax
    1859:	mov    QWORD PTR [rsp+0x38],rdx
    185e:	mov    QWORD PTR [rsp+0x40],rcx
    1863:	mov    QWORD PTR [rsp+0x48],rax
    1868:	jmp    15d8 <botlish_fn_16+0x5d>

000000000000186d <botlish_entry_16: scan_record_rest<str, int, mutarray, int>>:
    186d:	push   rbp
    186e:	mov    rbp,rsp
    1871:	ud2

0000000000001873 <botlish_fn_17: scan_record<str, int>>:
    1873:	push   rbp
    1874:	mov    rbp,rsp
    1877:	sub    rsp,0x40
    187b:	mov    QWORD PTR [rsp+0x20],rbx
    1880:	mov    QWORD PTR [rsp+0x28],r12
    1885:	mov    QWORD PTR [rsp+0x30],r14
    188a:	mov    r14,rdi
    188d:	mov    QWORD PTR [rsp+0x10],0x0
    1896:	mov    QWORD PTR [rsp+0x18],0x0
    189f:	mov    QWORD PTR [rsp],rsi
    18a3:	mov    r12,rsi
    18a6:	mov    QWORD PTR [rsp+0x8],rdx
    18ab:	mov    rsi,r12
    18ae:	mov    rdi,r14
    18b1:	call   18b6 <botlish_fn_17+0x43>
			18b2: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    18b6:	test   rax,rax
    18b9:	je     190e <botlish_fn_17+0x9b>
    18bf:	mov    QWORD PTR [rsp+0x8],rax
    18c4:	mov    rsi,rax
    18c7:	mov    QWORD PTR [rsp+0x10],rdx
    18cc:	mov    rbx,rdx
    18cf:	mov    rdi,r14
    18d2:	call   18d7 <botlish_fn_17+0x64>
			18d3: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<str>
    18d7:	test   rax,rax
    18da:	je     190e <botlish_fn_17+0x9b>
    18e0:	mov    QWORD PTR [rsp+0x8],rax
    18e5:	mov    rcx,rax
    18e8:	mov    r8d,0x3
    18ee:	mov    QWORD PTR [rsp+0x18],0x3
    18f7:	mov    rdx,rbx
    18fa:	mov    rsi,r12
    18fd:	mov    rdi,r14
    1900:	call   1905 <botlish_fn_17+0x92>
			1901: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record_rest<str, int, mutarray, int>
    1905:	test   rax,rax
    1908:	jne    192c <botlish_fn_17+0xb9>
    190e:	xor    rdx,rdx
    1911:	mov    rax,rdx
    1914:	mov    rbx,QWORD PTR [rsp+0x20]
    1919:	mov    r12,QWORD PTR [rsp+0x28]
    191e:	mov    r14,QWORD PTR [rsp+0x30]
    1923:	add    rsp,0x40
    1927:	mov    rsp,rbp
    192a:	pop    rbp
    192b:	ret
    192c:	mov    rbx,QWORD PTR [rsp+0x20]
    1931:	mov    r12,QWORD PTR [rsp+0x28]
    1936:	mov    r14,QWORD PTR [rsp+0x30]
    193b:	add    rsp,0x40
    193f:	mov    rsp,rbp
    1942:	pop    rbp
    1943:	ret

0000000000001944 <botlish_entry_17: scan_record<str, int>>:
    1944:	push   rbp
    1945:	mov    rbp,rsp
    1948:	ud2
    194a:	add    BYTE PTR [rax],al
    194c:	add    BYTE PTR [rax],al
	...

0000000000001950 <botlish_fn_18: scan_records<str, int, mutarray, int>>:
    1950:	push   rbp
    1951:	mov    rbp,rsp
    1954:	sub    rsp,0x60
    1958:	mov    QWORD PTR [rsp+0x30],rbx
    195d:	mov    QWORD PTR [rsp+0x38],r12
    1962:	mov    QWORD PTR [rsp+0x40],r13
    1967:	mov    QWORD PTR [rsp+0x48],r14
    196c:	mov    QWORD PTR [rsp+0x50],r15
    1971:	mov    r13,rdi
    1974:	mov    QWORD PTR [rsp+0x20],0x0
    197d:	mov    QWORD PTR [rsp],rsi
    1981:	mov    QWORD PTR [rsp+0x8],rdx
    1986:	mov    r12,rdx
    1989:	mov    QWORD PTR [rsp+0x10],rcx
    198e:	mov    QWORD PTR [rsp+0x18],r8
    1993:	mov    rbx,rsi
    1996:	mov    r14,r8
    1999:	mov    r15,rcx
    199c:	mov    rsi,rbx
    199f:	mov    rdi,r13
    19a2:	call   19a7 <botlish_fn_18+0x57>
			19a3: R_X86_64_PLT32	rt_str_len-0x4
    19a7:	mov    rcx,r12
    19aa:	and    rcx,rax
    19ad:	mov    rdx,rax
    19b0:	test   rcx,0x1
    19b7:	jne    19dd <botlish_fn_18+0x8d>
    19bd:	mov    rsi,r12
    19c0:	mov    rdi,r13
    19c3:	call   19c8 <botlish_fn_18+0x78>
			19c4: R_X86_64_PLT32	rt_int_cmp-0x4
    19c8:	mov    ecx,0x2
    19cd:	test   rax,rax
    19d0:	cmovge rcx,QWORD PTR [rip+0x128]        # 1b00 <botlish_fn_18+0x1b0>
    19d8:	jmp    19ed <botlish_fn_18+0x9d>
    19dd:	mov    ecx,0x2
    19e2:	cmp    r12,rdx
    19e5:	cmovge rcx,QWORD PTR [rip+0x113]        # 1b00 <botlish_fn_18+0x1b0>
    19ed:	cmp    rcx,0x6
    19f1:	je     1a9c <botlish_fn_18+0x14c>
    19f7:	mov    rdx,r12
    19fa:	mov    rsi,rbx
    19fd:	mov    rdi,r13
    1a00:	call   1a05 <botlish_fn_18+0xb5>
			1a01: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int>
    1a05:	test   rax,rax
    1a08:	je     1ab3 <botlish_fn_18+0x163>
    1a0e:	mov    QWORD PTR [rsp+0x8],rax
    1a13:	mov    rcx,rax
    1a16:	mov    QWORD PTR [rsp+0x20],rdx
    1a1b:	mov    rsi,r15
    1a1e:	mov    r12,rdx
    1a21:	mov    rdx,r14
    1a24:	mov    rdi,r13
    1a27:	call   1a2c <botlish_fn_18+0xdc>
			1a28: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
    1a2c:	test   rax,rax
    1a2f:	je     1ab3 <botlish_fn_18+0x163>
    1a35:	mov    QWORD PTR [rsp+0x8],rax
    1a3a:	mov    r15,rax
    1a3d:	mov    QWORD PTR [rsp+0x10],0x3
    1a46:	mov    rsi,r14
    1a49:	test   rsi,0x1
    1a50:	je     1a6b <botlish_fn_18+0x11b>
    1a56:	mov    rsi,r14
    1a59:	mov    rax,rsi
    1a5c:	add    rax,0x2
    1a60:	seto   cl
    1a63:	test   cl,cl
    1a65:	je     1a7b <botlish_fn_18+0x12b>
    1a6b:	mov    edx,0x3
    1a70:	mov    rsi,r14
    1a73:	mov    rdi,r13
    1a76:	call   1a7b <botlish_fn_18+0x12b>
			1a77: R_X86_64_PLT32	rt_int_add-0x4
    1a7b:	mov    QWORD PTR [rsp],rbx
    1a7f:	mov    rdx,r12
    1a82:	mov    QWORD PTR [rsp+0x8],rdx
    1a87:	mov    rcx,r15
    1a8a:	mov    QWORD PTR [rsp+0x10],rcx
    1a8f:	mov    QWORD PTR [rsp+0x18],rax
    1a94:	mov    r14,rax
    1a97:	jmp    199c <botlish_fn_18+0x4c>
    1a9c:	mov    rdx,r14
    1a9f:	mov    rsi,r15
    1aa2:	mov    rdi,r13
    1aa5:	call   1aaa <botlish_fn_18+0x15a>
			1aa6: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    1aaa:	test   rax,rax
    1aad:	jne    1ad8 <botlish_fn_18+0x188>
    1ab3:	xor    rax,rax
    1ab6:	mov    rbx,QWORD PTR [rsp+0x30]
    1abb:	mov    r12,QWORD PTR [rsp+0x38]
    1ac0:	mov    r13,QWORD PTR [rsp+0x40]
    1ac5:	mov    r14,QWORD PTR [rsp+0x48]
    1aca:	mov    r15,QWORD PTR [rsp+0x50]
    1acf:	add    rsp,0x60
    1ad3:	mov    rsp,rbp
    1ad6:	pop    rbp
    1ad7:	ret
    1ad8:	mov    rbx,QWORD PTR [rsp+0x30]
    1add:	mov    r12,QWORD PTR [rsp+0x38]
    1ae2:	mov    r13,QWORD PTR [rsp+0x40]
    1ae7:	mov    r14,QWORD PTR [rsp+0x48]
    1aec:	mov    r15,QWORD PTR [rsp+0x50]
    1af1:	add    rsp,0x60
    1af5:	mov    rsp,rbp
    1af8:	pop    rbp
    1af9:	ret
    1afa:	add    BYTE PTR [rax],al
    1afc:	add    BYTE PTR [rax],al
    1afe:	add    BYTE PTR [rax],al
    1b00:	(bad)
    1b01:	add    BYTE PTR [rax],al
    1b03:	add    BYTE PTR [rax],al
    1b05:	add    BYTE PTR [rax],al
	...

0000000000001b08 <botlish_entry_18: scan_records<str, int, mutarray, int>>:
    1b08:	push   rbp
    1b09:	mov    rbp,rsp
    1b0c:	mov    rsi,QWORD PTR [rdx]
    1b0f:	mov    r9,QWORD PTR [rdx+0x8]
    1b13:	mov    rcx,QWORD PTR [rdx+0x10]
    1b17:	mov    r8,QWORD PTR [rdx+0x18]
    1b1b:	mov    rdx,r9
    1b1e:	call   1b23 <botlish_entry_18+0x1b>
			1b1f: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, mutarray, int>
    1b23:	mov    rsp,rbp
    1b26:	pop    rbp
    1b27:	ret

0000000000001b28 <botlish_fn_19: csv_parse<str>>:
    1b28:	push   rbp
    1b29:	mov    rbp,rsp
    1b2c:	sub    rsp,0x40
    1b30:	mov    QWORD PTR [rsp+0x20],rbx
    1b35:	mov    QWORD PTR [rsp+0x28],r12
    1b3a:	mov    QWORD PTR [rsp+0x30],r13
    1b3f:	mov    rbx,rdi
    1b42:	mov    QWORD PTR [rsp+0x8],0x0
    1b4b:	mov    QWORD PTR [rsp+0x10],0x0
    1b54:	mov    QWORD PTR [rsp+0x18],0x0
    1b5d:	mov    QWORD PTR [rsp],rsi
    1b61:	mov    r12,rsi
    1b64:	mov    rsi,r12
    1b67:	mov    rdi,rbx
    1b6a:	call   1b6f <botlish_fn_19+0x47>
			1b6b: R_X86_64_PLT32	rt_str_len-0x4
    1b6f:	sar    rax,1
    1b72:	test   rax,rax
    1b75:	je     1c04 <botlish_fn_19+0xdc>
    1b7b:	mov    edx,0x1
    1b80:	mov    QWORD PTR [rsp+0x8],0x1
    1b89:	mov    rsi,r12
    1b8c:	mov    rdi,rbx
    1b8f:	call   1b94 <botlish_fn_19+0x6c>
			1b90: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int>
    1b94:	test   rax,rax
    1b97:	je     1c1b <botlish_fn_19+0xf3>
    1b9d:	mov    QWORD PTR [rsp+0x8],rax
    1ba2:	mov    rsi,rax
    1ba5:	mov    QWORD PTR [rsp+0x10],rdx
    1baa:	mov    r13,rdx
    1bad:	mov    rdi,rbx
    1bb0:	call   1bb5 <botlish_fn_19+0x8d>
			1bb1: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<List[str]>
    1bb5:	test   rax,rax
    1bb8:	je     1c1b <botlish_fn_19+0xf3>
    1bbe:	mov    QWORD PTR [rsp+0x8],rax
    1bc3:	mov    rcx,rax
    1bc6:	mov    r8d,0x3
    1bcc:	mov    QWORD PTR [rsp+0x18],0x3
    1bd5:	mov    rdx,r13
    1bd8:	mov    rsi,r12
    1bdb:	mov    rdi,rbx
    1bde:	call   1be3 <botlish_fn_19+0xbb>
			1bdf: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, mutarray, int>
    1be3:	test   rax,rax
    1be6:	je     1c1b <botlish_fn_19+0xf3>
    1bec:	mov    rbx,QWORD PTR [rsp+0x20]
    1bf1:	mov    r12,QWORD PTR [rsp+0x28]
    1bf6:	mov    r13,QWORD PTR [rsp+0x30]
    1bfb:	add    rsp,0x40
    1bff:	mov    rsp,rbp
    1c02:	pop    rbp
    1c03:	ret
    1c04:	xor    rdx,rdx
    1c07:	mov    rdi,rbx
    1c0a:	mov    rsi,rdx
    1c0d:	call   1c12 <botlish_fn_19+0xea>
			1c0e: R_X86_64_PLT32	rt_list_new-0x4
    1c12:	test   rax,rax
    1c15:	jne    1c36 <botlish_fn_19+0x10e>
    1c1b:	xor    rax,rax
    1c1e:	mov    rbx,QWORD PTR [rsp+0x20]
    1c23:	mov    r12,QWORD PTR [rsp+0x28]
    1c28:	mov    r13,QWORD PTR [rsp+0x30]
    1c2d:	add    rsp,0x40
    1c31:	mov    rsp,rbp
    1c34:	pop    rbp
    1c35:	ret
    1c36:	mov    rbx,QWORD PTR [rsp+0x20]
    1c3b:	mov    r12,QWORD PTR [rsp+0x28]
    1c40:	mov    r13,QWORD PTR [rsp+0x30]
    1c45:	add    rsp,0x40
    1c49:	mov    rsp,rbp
    1c4c:	pop    rbp
    1c4d:	ret

0000000000001c4e <botlish_entry_19: csv_parse<str>>:
    1c4e:	push   rbp
    1c4f:	mov    rbp,rsp
    1c52:	mov    rsi,QWORD PTR [rdx]
    1c55:	call   1c5a <botlish_entry_19+0xc>
			1c56: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    1c5a:	mov    rsp,rbp
    1c5d:	pop    rbp
    1c5e:	ret

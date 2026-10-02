; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 7561  (per function: 68 461 461 81 81 357 412 412 279 279 81 365 430 585 1046 352 783 215 488 325)
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
     462:	mov    QWORD PTR [rsp],rsi
     466:	mov    QWORD PTR [rsp+0x8],rdx
     46b:	mov    rbx,rdx
     46e:	mov    QWORD PTR [rsp+0x10],0x5
     477:	test   rsi,0x1
     47e:	je     4a0 <botlish_fn_5+0x58>
     484:	mov    rax,rsi
     487:	sar    rax,1
     48a:	imul   QWORD PTR [rip+0xdf]        # 570 <botlish_fn_5+0x128>
     491:	seto   cl
     494:	or     rax,0x1
     498:	test   cl,cl
     49a:	je     4ad <botlish_fn_5+0x65>
     4a0:	mov    edx,0x5
     4a5:	mov    rdi,r12
     4a8:	call   4ad <botlish_fn_5+0x65>
			4a9: R_X86_64_PLT32	rt_int_mul-0x4
     4ad:	mov    rcx,rax
     4b0:	and    rcx,rbx
     4b3:	mov    r13,rax
     4b6:	test   rcx,0x1
     4bd:	jne    4e9 <botlish_fn_5+0xa1>
     4c3:	mov    rdx,rbx
     4c6:	mov    rsi,r13
     4c9:	mov    rdi,r12
     4cc:	call   4d1 <botlish_fn_5+0x89>
			4cd: R_X86_64_PLT32	rt_int_cmp-0x4
     4d1:	mov    ecx,0x2
     4d6:	test   rax,rax
     4d9:	cmovle rcx,QWORD PTR [rip+0x97]        # 578 <botlish_fn_5+0x130>
     4e1:	mov    rax,r13
     4e4:	jmp    4fc <botlish_fn_5+0xb4>
     4e9:	mov    ecx,0x2
     4ee:	mov    rax,r13
     4f1:	cmp    rax,rbx
     4f4:	cmovle rcx,QWORD PTR [rip+0x7c]        # 578 <botlish_fn_5+0x130>
     4fc:	cmp    rcx,0x6
     500:	je     51e <botlish_fn_5+0xd6>
     506:	mov    rbx,QWORD PTR [rsp+0x20]
     50b:	mov    r12,QWORD PTR [rsp+0x28]
     510:	mov    r13,QWORD PTR [rsp+0x30]
     515:	add    rsp,0x40
     519:	mov    rsp,rbp
     51c:	pop    rbp
     51d:	ret
     51e:	mov    QWORD PTR [rsp],0x3
     526:	test   rbx,0x1
     52d:	je     545 <botlish_fn_5+0xfd>
     533:	mov    rax,rbx
     536:	add    rax,0x2
     53a:	seto   cl
     53d:	test   cl,cl
     53f:	je     555 <botlish_fn_5+0x10d>
     545:	mov    edx,0x3
     54a:	mov    rsi,rbx
     54d:	mov    rdi,r12
     550:	call   555 <botlish_fn_5+0x10d>
			551: R_X86_64_PLT32	rt_int_add-0x4
     555:	mov    rbx,QWORD PTR [rsp+0x20]
     55a:	mov    r12,QWORD PTR [rsp+0x28]
     55f:	mov    r13,QWORD PTR [rsp+0x30]
     564:	add    rsp,0x40
     568:	mov    rsp,rbp
     56b:	pop    rbp
     56c:	ret
     56d:	add    BYTE PTR [rax],al
     56f:	add    BYTE PTR [rax+rax*1],al
     572:	add    BYTE PTR [rax],al
     574:	add    BYTE PTR [rax],al
     576:	add    BYTE PTR [rax],al
     578:	(bad)
     579:	add    BYTE PTR [rax],al
     57b:	add    BYTE PTR [rax],al
     57d:	add    BYTE PTR [rax],al
	...

0000000000000580 <botlish_entry_5: geo_new_capacity<int, int>>:
     580:	push   rbp
     581:	mov    rbp,rsp
     584:	mov    rsi,QWORD PTR [rdx]
     587:	mov    rdx,QWORD PTR [rdx+0x8]
     58b:	call   590 <botlish_entry_5+0x10>
			58c: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new_capacity<int, int>
     590:	mov    rsp,rbp
     593:	pop    rbp
     594:	ret
     595:	add    BYTE PTR [rax],al
	...

0000000000000598 <botlish_fn_6: geo_grow<mutarray, int, str>>:
     598:	push   rbp
     599:	mov    rbp,rsp
     59c:	sub    rsp,0x50
     5a0:	mov    QWORD PTR [rsp+0x20],rbx
     5a5:	mov    QWORD PTR [rsp+0x28],r12
     5aa:	mov    QWORD PTR [rsp+0x30],r13
     5af:	mov    QWORD PTR [rsp+0x38],r14
     5b4:	mov    QWORD PTR [rsp+0x40],r15
     5b9:	mov    r13,rdi
     5bc:	mov    QWORD PTR [rsp],rsi
     5c0:	mov    r12,rsi
     5c3:	mov    QWORD PTR [rsp+0x8],rdx
     5c8:	mov    rbx,rdx
     5cb:	mov    QWORD PTR [rsp+0x10],rcx
     5d0:	mov    r14,rcx
     5d3:	mov    rsi,r12
     5d6:	mov    rdi,r13
     5d9:	call   5de <botlish_fn_6+0x46>
			5da: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     5de:	mov    r15,rax
     5e1:	mov    QWORD PTR [rsp+0x18],rax
     5e6:	mov    rcx,rbx
     5e9:	and    rcx,rax
     5ec:	test   rcx,0x1
     5f3:	jne    61f <botlish_fn_6+0x87>
     5f9:	mov    rdx,r15
     5fc:	mov    rsi,rbx
     5ff:	mov    rdi,r13
     602:	call   607 <botlish_fn_6+0x6f>
			603: R_X86_64_PLT32	rt_int_cmp-0x4
     607:	mov    ecx,0x2
     60c:	test   rax,rax
     60f:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 700 <botlish_fn_6+0x168>
     617:	mov    rax,r15
     61a:	jmp    632 <botlish_fn_6+0x9a>
     61f:	mov    ecx,0x2
     624:	mov    rax,r15
     627:	cmp    rbx,rax
     62a:	cmovl  rcx,QWORD PTR [rip+0xce]        # 700 <botlish_fn_6+0x168>
     632:	cmp    rcx,0x6
     636:	je     6d6 <botlish_fn_6+0x13e>
     63c:	mov    rsi,rax
     63f:	mov    rdx,rbx
     642:	mov    rdi,r13
     645:	call   64a <botlish_fn_6+0xb2>
			646: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new_capacity<int, int>
     64a:	mov    QWORD PTR [rsp+0x18],rax
     64f:	mov    rdx,r14
     652:	mov    rsi,rax
     655:	mov    rdi,r13
     658:	call   65d <botlish_fn_6+0xc5>
			659: R_X86_64_PLT32	botlish_fn_1-0x4 ; mutarray::create<int, str>
     65d:	test   rax,rax
     660:	mov    r14,rax
     663:	je     68c <botlish_fn_6+0xf4>
     669:	mov    r8d,0x1
     66f:	mov    rcx,r12
     672:	mov    rdi,r13
     675:	mov    r9,rbx
     678:	mov    rsi,r14
     67b:	mov    rdx,r8
     67e:	call   683 <botlish_fn_6+0xeb>
			67f: R_X86_64_PLT32	rt_mutarray_copy-0x4
     683:	test   rax,rax
     686:	jne    6b1 <botlish_fn_6+0x119>
     68c:	xor    rax,rax
     68f:	mov    rbx,QWORD PTR [rsp+0x20]
     694:	mov    r12,QWORD PTR [rsp+0x28]
     699:	mov    r13,QWORD PTR [rsp+0x30]
     69e:	mov    r14,QWORD PTR [rsp+0x38]
     6a3:	mov    r15,QWORD PTR [rsp+0x40]
     6a8:	add    rsp,0x50
     6ac:	mov    rsp,rbp
     6af:	pop    rbp
     6b0:	ret
     6b1:	mov    rax,r14
     6b4:	mov    rbx,QWORD PTR [rsp+0x20]
     6b9:	mov    r12,QWORD PTR [rsp+0x28]
     6be:	mov    r13,QWORD PTR [rsp+0x30]
     6c3:	mov    r14,QWORD PTR [rsp+0x38]
     6c8:	mov    r15,QWORD PTR [rsp+0x40]
     6cd:	add    rsp,0x50
     6d1:	mov    rsp,rbp
     6d4:	pop    rbp
     6d5:	ret
     6d6:	mov    rax,r12
     6d9:	mov    rbx,QWORD PTR [rsp+0x20]
     6de:	mov    r12,QWORD PTR [rsp+0x28]
     6e3:	mov    r13,QWORD PTR [rsp+0x30]
     6e8:	mov    r14,QWORD PTR [rsp+0x38]
     6ed:	mov    r15,QWORD PTR [rsp+0x40]
     6f2:	add    rsp,0x50
     6f6:	mov    rsp,rbp
     6f9:	pop    rbp
     6fa:	ret
     6fb:	add    BYTE PTR [rax],al
     6fd:	add    BYTE PTR [rax],al
     6ff:	add    BYTE PTR [rsi],al
     701:	add    BYTE PTR [rax],al
     703:	add    BYTE PTR [rax],al
     705:	add    BYTE PTR [rax],al
	...

0000000000000708 <botlish_entry_6: geo_grow<mutarray, int, str>>:
     708:	push   rbp
     709:	mov    rbp,rsp
     70c:	mov    rsi,QWORD PTR [rdx]
     70f:	mov    r8,QWORD PTR [rdx+0x8]
     713:	mov    rcx,QWORD PTR [rdx+0x10]
     717:	mov    rdx,r8
     71a:	call   71f <botlish_entry_6+0x17>
			71b: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_grow<mutarray, int, str>
     71f:	mov    rsp,rbp
     722:	pop    rbp
     723:	ret
     724:	add    BYTE PTR [rax],al
	...

0000000000000728 <botlish_fn_7: geo_grow<mutarray, int, List[str]>>:
     728:	push   rbp
     729:	mov    rbp,rsp
     72c:	sub    rsp,0x50
     730:	mov    QWORD PTR [rsp+0x20],rbx
     735:	mov    QWORD PTR [rsp+0x28],r12
     73a:	mov    QWORD PTR [rsp+0x30],r13
     73f:	mov    QWORD PTR [rsp+0x38],r14
     744:	mov    QWORD PTR [rsp+0x40],r15
     749:	mov    r13,rdi
     74c:	mov    QWORD PTR [rsp],rsi
     750:	mov    r12,rsi
     753:	mov    QWORD PTR [rsp+0x8],rdx
     758:	mov    rbx,rdx
     75b:	mov    QWORD PTR [rsp+0x10],rcx
     760:	mov    r14,rcx
     763:	mov    rsi,r12
     766:	mov    rdi,r13
     769:	call   76e <botlish_fn_7+0x46>
			76a: R_X86_64_PLT32	rt_mutarray_capacity-0x4
     76e:	mov    r15,rax
     771:	mov    QWORD PTR [rsp+0x18],rax
     776:	mov    rcx,rbx
     779:	and    rcx,rax
     77c:	test   rcx,0x1
     783:	jne    7af <botlish_fn_7+0x87>
     789:	mov    rdx,r15
     78c:	mov    rsi,rbx
     78f:	mov    rdi,r13
     792:	call   797 <botlish_fn_7+0x6f>
			793: R_X86_64_PLT32	rt_int_cmp-0x4
     797:	mov    ecx,0x2
     79c:	test   rax,rax
     79f:	cmovl  rcx,QWORD PTR [rip+0xe9]        # 890 <botlish_fn_7+0x168>
     7a7:	mov    rax,r15
     7aa:	jmp    7c2 <botlish_fn_7+0x9a>
     7af:	mov    ecx,0x2
     7b4:	mov    rax,r15
     7b7:	cmp    rbx,rax
     7ba:	cmovl  rcx,QWORD PTR [rip+0xce]        # 890 <botlish_fn_7+0x168>
     7c2:	cmp    rcx,0x6
     7c6:	je     866 <botlish_fn_7+0x13e>
     7cc:	mov    rsi,rax
     7cf:	mov    rdx,rbx
     7d2:	mov    rdi,r13
     7d5:	call   7da <botlish_fn_7+0xb2>
			7d6: R_X86_64_PLT32	botlish_fn_5-0x4 ; geo_new_capacity<int, int>
     7da:	mov    QWORD PTR [rsp+0x18],rax
     7df:	mov    rdx,r14
     7e2:	mov    rsi,rax
     7e5:	mov    rdi,r13
     7e8:	call   7ed <botlish_fn_7+0xc5>
			7e9: R_X86_64_PLT32	botlish_fn_2-0x4 ; mutarray::create<int, List[str]>
     7ed:	test   rax,rax
     7f0:	mov    r14,rax
     7f3:	je     81c <botlish_fn_7+0xf4>
     7f9:	mov    r8d,0x1
     7ff:	mov    rcx,r12
     802:	mov    rdi,r13
     805:	mov    r9,rbx
     808:	mov    rsi,r14
     80b:	mov    rdx,r8
     80e:	call   813 <botlish_fn_7+0xeb>
			80f: R_X86_64_PLT32	rt_mutarray_copy-0x4
     813:	test   rax,rax
     816:	jne    841 <botlish_fn_7+0x119>
     81c:	xor    rax,rax
     81f:	mov    rbx,QWORD PTR [rsp+0x20]
     824:	mov    r12,QWORD PTR [rsp+0x28]
     829:	mov    r13,QWORD PTR [rsp+0x30]
     82e:	mov    r14,QWORD PTR [rsp+0x38]
     833:	mov    r15,QWORD PTR [rsp+0x40]
     838:	add    rsp,0x50
     83c:	mov    rsp,rbp
     83f:	pop    rbp
     840:	ret
     841:	mov    rax,r14
     844:	mov    rbx,QWORD PTR [rsp+0x20]
     849:	mov    r12,QWORD PTR [rsp+0x28]
     84e:	mov    r13,QWORD PTR [rsp+0x30]
     853:	mov    r14,QWORD PTR [rsp+0x38]
     858:	mov    r15,QWORD PTR [rsp+0x40]
     85d:	add    rsp,0x50
     861:	mov    rsp,rbp
     864:	pop    rbp
     865:	ret
     866:	mov    rax,r12
     869:	mov    rbx,QWORD PTR [rsp+0x20]
     86e:	mov    r12,QWORD PTR [rsp+0x28]
     873:	mov    r13,QWORD PTR [rsp+0x30]
     878:	mov    r14,QWORD PTR [rsp+0x38]
     87d:	mov    r15,QWORD PTR [rsp+0x40]
     882:	add    rsp,0x50
     886:	mov    rsp,rbp
     889:	pop    rbp
     88a:	ret
     88b:	add    BYTE PTR [rax],al
     88d:	add    BYTE PTR [rax],al
     88f:	add    BYTE PTR [rsi],al
     891:	add    BYTE PTR [rax],al
     893:	add    BYTE PTR [rax],al
     895:	add    BYTE PTR [rax],al
	...

0000000000000898 <botlish_entry_7: geo_grow<mutarray, int, List[str]>>:
     898:	push   rbp
     899:	mov    rbp,rsp
     89c:	mov    rsi,QWORD PTR [rdx]
     89f:	mov    r8,QWORD PTR [rdx+0x8]
     8a3:	mov    rcx,QWORD PTR [rdx+0x10]
     8a7:	mov    rdx,r8
     8aa:	call   8af <botlish_entry_7+0x17>
			8ab: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_grow<mutarray, int, List[str]>
     8af:	mov    rsp,rbp
     8b2:	pop    rbp
     8b3:	ret

00000000000008b4 <botlish_fn_8: geo_append<mutarray, int, str>>:
     8b4:	push   rbp
     8b5:	mov    rbp,rsp
     8b8:	sub    rsp,0x40
     8bc:	mov    QWORD PTR [rsp+0x20],rbx
     8c1:	mov    QWORD PTR [rsp+0x28],r12
     8c6:	mov    QWORD PTR [rsp+0x30],r13
     8cb:	mov    QWORD PTR [rsp+0x38],r14
     8d0:	mov    rbx,rdi
     8d3:	mov    QWORD PTR [rsp],rsi
     8d7:	mov    QWORD PTR [rsp+0x8],rdx
     8dc:	mov    r14,rdx
     8df:	mov    QWORD PTR [rsp+0x10],rcx
     8e4:	mov    r13,rcx
     8e7:	mov    rcx,r13
     8ea:	mov    rdx,r14
     8ed:	mov    rdi,rbx
     8f0:	call   8f5 <botlish_fn_8+0x41>
			8f1: R_X86_64_PLT32	botlish_fn_6-0x4 ; geo_grow<mutarray, int, str>
     8f5:	test   rax,rax
     8f8:	je     961 <botlish_fn_8+0xad>
     8fe:	xor    ecx,ecx
     900:	test   rax,0x7
     906:	je     914 <botlish_fn_8+0x60>
     90c:	mov    r12,rax
     90f:	jmp    922 <botlish_fn_8+0x6e>
     914:	movzx  rcx,BYTE PTR [rax]
     918:	mov    r12,rax
     91b:	rex cmp cl,0x8
     91f:	sete   cl
     922:	test   cl,cl
     924:	jne    947 <botlish_fn_8+0x93>
     92a:	mov    rdi,rbx
     92d:	mov    rax,QWORD PTR [rdi+0x10]
     931:	mov    rcx,QWORD PTR [rax+0x8]
     935:	mov    edx,0x8
     93a:	mov    rsi,r12
     93d:	call   942 <botlish_fn_8+0x8e>
			93e: R_X86_64_PLT32	rt_type_error-0x4
     942:	jmp    961 <botlish_fn_8+0xad>
     947:	mov    rcx,r13
     94a:	mov    rdx,r14
     94d:	mov    rdi,rbx
     950:	mov    rsi,r12
     953:	call   958 <botlish_fn_8+0xa4>
			954: R_X86_64_PLT32	rt_mutarray_set-0x4
     958:	test   rax,rax
     95b:	jne    981 <botlish_fn_8+0xcd>
     961:	xor    rax,rax
     964:	mov    rbx,QWORD PTR [rsp+0x20]
     969:	mov    r12,QWORD PTR [rsp+0x28]
     96e:	mov    r13,QWORD PTR [rsp+0x30]
     973:	mov    r14,QWORD PTR [rsp+0x38]
     978:	add    rsp,0x40
     97c:	mov    rsp,rbp
     97f:	pop    rbp
     980:	ret
     981:	mov    rax,r12
     984:	mov    rbx,QWORD PTR [rsp+0x20]
     989:	mov    r12,QWORD PTR [rsp+0x28]
     98e:	mov    r13,QWORD PTR [rsp+0x30]
     993:	mov    r14,QWORD PTR [rsp+0x38]
     998:	add    rsp,0x40
     99c:	mov    rsp,rbp
     99f:	pop    rbp
     9a0:	ret

00000000000009a1 <botlish_entry_8: geo_append<mutarray, int, str>>:
     9a1:	push   rbp
     9a2:	mov    rbp,rsp
     9a5:	mov    rsi,QWORD PTR [rdx]
     9a8:	mov    r8,QWORD PTR [rdx+0x8]
     9ac:	mov    rcx,QWORD PTR [rdx+0x10]
     9b0:	mov    rdx,r8
     9b3:	call   9b8 <botlish_entry_8+0x17>
			9b4: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
     9b8:	mov    rsp,rbp
     9bb:	pop    rbp
     9bc:	ret

00000000000009bd <botlish_fn_9: geo_append<mutarray, int, List[str]>>:
     9bd:	push   rbp
     9be:	mov    rbp,rsp
     9c1:	sub    rsp,0x40
     9c5:	mov    QWORD PTR [rsp+0x20],rbx
     9ca:	mov    QWORD PTR [rsp+0x28],r12
     9cf:	mov    QWORD PTR [rsp+0x30],r13
     9d4:	mov    QWORD PTR [rsp+0x38],r14
     9d9:	mov    rbx,rdi
     9dc:	mov    QWORD PTR [rsp],rsi
     9e0:	mov    QWORD PTR [rsp+0x8],rdx
     9e5:	mov    r14,rdx
     9e8:	mov    QWORD PTR [rsp+0x10],rcx
     9ed:	mov    r13,rcx
     9f0:	mov    rcx,r13
     9f3:	mov    rdx,r14
     9f6:	mov    rdi,rbx
     9f9:	call   9fe <botlish_fn_9+0x41>
			9fa: R_X86_64_PLT32	botlish_fn_7-0x4 ; geo_grow<mutarray, int, List[str]>
     9fe:	test   rax,rax
     a01:	je     a6a <botlish_fn_9+0xad>
     a07:	xor    ecx,ecx
     a09:	test   rax,0x7
     a0f:	je     a1d <botlish_fn_9+0x60>
     a15:	mov    r12,rax
     a18:	jmp    a2b <botlish_fn_9+0x6e>
     a1d:	movzx  rcx,BYTE PTR [rax]
     a21:	mov    r12,rax
     a24:	rex cmp cl,0x8
     a28:	sete   cl
     a2b:	test   cl,cl
     a2d:	jne    a50 <botlish_fn_9+0x93>
     a33:	mov    rdi,rbx
     a36:	mov    rax,QWORD PTR [rdi+0x10]
     a3a:	mov    rcx,QWORD PTR [rax+0x8]
     a3e:	mov    edx,0x8
     a43:	mov    rsi,r12
     a46:	call   a4b <botlish_fn_9+0x8e>
			a47: R_X86_64_PLT32	rt_type_error-0x4
     a4b:	jmp    a6a <botlish_fn_9+0xad>
     a50:	mov    rcx,r13
     a53:	mov    rdx,r14
     a56:	mov    rdi,rbx
     a59:	mov    rsi,r12
     a5c:	call   a61 <botlish_fn_9+0xa4>
			a5d: R_X86_64_PLT32	rt_mutarray_set-0x4
     a61:	test   rax,rax
     a64:	jne    a8a <botlish_fn_9+0xcd>
     a6a:	xor    rax,rax
     a6d:	mov    rbx,QWORD PTR [rsp+0x20]
     a72:	mov    r12,QWORD PTR [rsp+0x28]
     a77:	mov    r13,QWORD PTR [rsp+0x30]
     a7c:	mov    r14,QWORD PTR [rsp+0x38]
     a81:	add    rsp,0x40
     a85:	mov    rsp,rbp
     a88:	pop    rbp
     a89:	ret
     a8a:	mov    rax,r12
     a8d:	mov    rbx,QWORD PTR [rsp+0x20]
     a92:	mov    r12,QWORD PTR [rsp+0x28]
     a97:	mov    r13,QWORD PTR [rsp+0x30]
     a9c:	mov    r14,QWORD PTR [rsp+0x38]
     aa1:	add    rsp,0x40
     aa5:	mov    rsp,rbp
     aa8:	pop    rbp
     aa9:	ret

0000000000000aaa <botlish_entry_9: geo_append<mutarray, int, List[str]>>:
     aaa:	push   rbp
     aab:	mov    rbp,rsp
     aae:	mov    rsi,QWORD PTR [rdx]
     ab1:	mov    r8,QWORD PTR [rdx+0x8]
     ab5:	mov    rcx,QWORD PTR [rdx+0x10]
     ab9:	mov    rdx,r8
     abc:	call   ac1 <botlish_entry_9+0x17>
			abd: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
     ac1:	mov    rsp,rbp
     ac4:	pop    rbp
     ac5:	ret

0000000000000ac6 <botlish_fn_10: geo_finish<mutarray, int>>:
     ac6:	push   rbp
     ac7:	mov    rbp,rsp
     aca:	sub    rsp,0x10
     ace:	mov    QWORD PTR [rsp],rsi
     ad2:	mov    QWORD PTR [rsp+0x8],rdx
     ad7:	call   adc <botlish_fn_10+0x16>
			ad8: R_X86_64_PLT32	rt_mutarray_freeze-0x4
     adc:	test   rax,rax
     adf:	jne    af1 <botlish_fn_10+0x2b>
     ae5:	xor    rax,rax
     ae8:	add    rsp,0x10
     aec:	mov    rsp,rbp
     aef:	pop    rbp
     af0:	ret
     af1:	add    rsp,0x10
     af5:	mov    rsp,rbp
     af8:	pop    rbp
     af9:	ret

0000000000000afa <botlish_entry_10: geo_finish<mutarray, int>>:
     afa:	push   rbp
     afb:	mov    rbp,rsp
     afe:	mov    rsi,QWORD PTR [rdx]
     b01:	mov    rdx,QWORD PTR [rdx+0x8]
     b05:	call   b0a <botlish_entry_10+0x10>
			b06: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
     b0a:	mov    rsp,rbp
     b0d:	pop    rbp
     b0e:	ret
	...

0000000000000b10 <botlish_fn_11: peek<str, int>>:
     b10:	push   rbp
     b11:	mov    rbp,rsp
     b14:	sub    rsp,0x40
     b18:	mov    QWORD PTR [rsp+0x20],rbx
     b1d:	mov    QWORD PTR [rsp+0x28],r12
     b22:	mov    QWORD PTR [rsp+0x30],r13
     b27:	mov    r13,rdi
     b2a:	mov    QWORD PTR [rsp],rsi
     b2e:	mov    r12,rsi
     b31:	mov    QWORD PTR [rsp+0x8],rdx
     b36:	mov    rbx,rdx
     b39:	mov    rsi,r12
     b3c:	mov    rdi,r13
     b3f:	call   b44 <botlish_fn_11+0x34>
			b40: R_X86_64_PLT32	rt_str_len-0x4
     b44:	mov    rcx,rbx
     b47:	and    rcx,rax
     b4a:	mov    rdx,rax
     b4d:	test   rcx,0x1
     b54:	jne    b7a <botlish_fn_11+0x6a>
     b5a:	mov    rsi,rbx
     b5d:	mov    rdi,r13
     b60:	call   b65 <botlish_fn_11+0x55>
			b61: R_X86_64_PLT32	rt_int_cmp-0x4
     b65:	mov    ecx,0x2
     b6a:	test   rax,rax
     b6d:	cmovge rcx,QWORD PTR [rip+0xd3]        # c48 <botlish_fn_11+0x138>
     b75:	jmp    b8a <botlish_fn_11+0x7a>
     b7a:	mov    ecx,0x2
     b7f:	cmp    rbx,rdx
     b82:	cmovge rcx,QWORD PTR [rip+0xbe]        # c48 <botlish_fn_11+0x138>
     b8a:	cmp    rcx,0x6
     b8e:	je     c1e <botlish_fn_11+0x10e>
     b94:	mov    QWORD PTR [rsp+0x10],0x3
     b9d:	test   rbx,0x1
     ba4:	je     bbc <botlish_fn_11+0xac>
     baa:	mov    rcx,rbx
     bad:	add    rcx,0x2
     bb1:	seto   al
     bb4:	test   al,al
     bb6:	je     bcf <botlish_fn_11+0xbf>
     bbc:	mov    edx,0x3
     bc1:	mov    rsi,rbx
     bc4:	mov    rdi,r13
     bc7:	call   bcc <botlish_fn_11+0xbc>
			bc8: R_X86_64_PLT32	rt_int_add-0x4
     bcc:	mov    rcx,rax
     bcf:	mov    QWORD PTR [rsp+0x10],rcx
     bd4:	mov    rdx,rbx
     bd7:	mov    rsi,r12
     bda:	mov    rdi,r13
     bdd:	call   be2 <botlish_fn_11+0xd2>
			bde: R_X86_64_PLT32	rt_substr-0x4
     be2:	test   rax,rax
     be5:	jne    c06 <botlish_fn_11+0xf6>
     beb:	xor    rax,rax
     bee:	mov    rbx,QWORD PTR [rsp+0x20]
     bf3:	mov    r12,QWORD PTR [rsp+0x28]
     bf8:	mov    r13,QWORD PTR [rsp+0x30]
     bfd:	add    rsp,0x40
     c01:	mov    rsp,rbp
     c04:	pop    rbp
     c05:	ret
     c06:	mov    rbx,QWORD PTR [rsp+0x20]
     c0b:	mov    r12,QWORD PTR [rsp+0x28]
     c10:	mov    r13,QWORD PTR [rsp+0x30]
     c15:	add    rsp,0x40
     c19:	mov    rsp,rbp
     c1c:	pop    rbp
     c1d:	ret
     c1e:	mov    rdi,r13
     c21:	mov    rax,QWORD PTR [rdi+0x10]
     c25:	mov    rax,QWORD PTR [rax+0x10]
     c29:	mov    rbx,QWORD PTR [rsp+0x20]
     c2e:	mov    r12,QWORD PTR [rsp+0x28]
     c33:	mov    r13,QWORD PTR [rsp+0x30]
     c38:	add    rsp,0x40
     c3c:	mov    rsp,rbp
     c3f:	pop    rbp
     c40:	ret
     c41:	add    BYTE PTR [rax],al
     c43:	add    BYTE PTR [rax],al
     c45:	add    BYTE PTR [rax],al
     c47:	add    BYTE PTR [rsi],al
     c49:	add    BYTE PTR [rax],al
     c4b:	add    BYTE PTR [rax],al
     c4d:	add    BYTE PTR [rax],al
	...

0000000000000c50 <botlish_entry_11: peek<str, int>>:
     c50:	push   rbp
     c51:	mov    rbp,rsp
     c54:	mov    rsi,QWORD PTR [rdx]
     c57:	mov    rdx,QWORD PTR [rdx+0x8]
     c5b:	call   c60 <botlish_entry_11+0x10>
			c5c: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
     c60:	mov    rsp,rbp
     c63:	pop    rbp
     c64:	ret
     c65:	add    BYTE PTR [rax],al
	...

0000000000000c68 <botlish_fn_12: peek<str, int>>:
     c68:	push   rbp
     c69:	mov    rbp,rsp
     c6c:	sub    rsp,0x50
     c70:	mov    QWORD PTR [rsp+0x20],rbx
     c75:	mov    QWORD PTR [rsp+0x28],r12
     c7a:	mov    QWORD PTR [rsp+0x30],r13
     c7f:	mov    QWORD PTR [rsp+0x38],r14
     c84:	mov    QWORD PTR [rsp+0x40],r15
     c89:	mov    r12,rcx
     c8c:	mov    r14,rdi
     c8f:	mov    QWORD PTR [rsp],rsi
     c93:	mov    r13,rsi
     c96:	mov    QWORD PTR [rsp+0x8],rdx
     c9b:	mov    rbx,rdx
     c9e:	mov    rsi,r13
     ca1:	mov    rdi,r14
     ca4:	call   ca9 <botlish_fn_12+0x41>
			ca5: R_X86_64_PLT32	rt_str_len-0x4
     ca9:	mov    rcx,rbx
     cac:	and    rcx,rax
     caf:	mov    rdx,rax
     cb2:	test   rcx,0x1
     cb9:	jne    cdf <botlish_fn_12+0x77>
     cbf:	mov    rsi,rbx
     cc2:	mov    rdi,r14
     cc5:	call   cca <botlish_fn_12+0x62>
			cc6: R_X86_64_PLT32	rt_int_cmp-0x4
     cca:	mov    ecx,0x2
     ccf:	test   rax,rax
     cd2:	cmovge rcx,QWORD PTR [rip+0x11e]        # df8 <botlish_fn_12+0x190>
     cda:	jmp    cef <botlish_fn_12+0x87>
     cdf:	mov    ecx,0x2
     ce4:	cmp    rbx,rdx
     ce7:	cmovge rcx,QWORD PTR [rip+0x109]        # df8 <botlish_fn_12+0x190>
     cef:	cmp    rcx,0x6
     cf3:	je     db3 <botlish_fn_12+0x14b>
     cf9:	mov    QWORD PTR [rsp+0x10],0x3
     d02:	test   rbx,0x1
     d09:	je     d2c <botlish_fn_12+0xc4>
     d0f:	mov    rax,rbx
     d12:	add    rax,0x2
     d16:	seto   cl
     d19:	test   cl,cl
     d1b:	jne    d2c <botlish_fn_12+0xc4>
     d21:	mov    rdi,r14
     d24:	mov    r15,rax
     d27:	jmp    d42 <botlish_fn_12+0xda>
     d2c:	mov    edx,0x3
     d31:	mov    rsi,rbx
     d34:	mov    rdi,r14
     d37:	call   d3c <botlish_fn_12+0xd4>
			d38: R_X86_64_PLT32	rt_int_add-0x4
     d3c:	mov    r15,rax
     d3f:	mov    rdi,r14
     d42:	mov    rdi,r14
     d45:	mov    rcx,r15
     d48:	mov    rdx,rbx
     d4b:	mov    rsi,r13
     d4e:	call   d53 <botlish_fn_12+0xeb>
			d4f: R_X86_64_PLT32	rt_str_region_check-0x4
     d53:	test   rax,rax
     d56:	jne    d81 <botlish_fn_12+0x119>
     d5c:	xor    rax,rax
     d5f:	mov    rbx,QWORD PTR [rsp+0x20]
     d64:	mov    r12,QWORD PTR [rsp+0x28]
     d69:	mov    r13,QWORD PTR [rsp+0x30]
     d6e:	mov    r14,QWORD PTR [rsp+0x38]
     d73:	mov    r15,QWORD PTR [rsp+0x40]
     d78:	add    rsp,0x50
     d7c:	mov    rsp,rbp
     d7f:	pop    rbp
     d80:	ret
     d81:	mov    rcx,r12
     d84:	mov    QWORD PTR [rcx],rbx
     d87:	mov    rax,r15
     d8a:	mov    QWORD PTR [rcx+0x8],rax
     d8e:	mov    rax,r13
     d91:	mov    rbx,QWORD PTR [rsp+0x20]
     d96:	mov    r12,QWORD PTR [rsp+0x28]
     d9b:	mov    r13,QWORD PTR [rsp+0x30]
     da0:	mov    r14,QWORD PTR [rsp+0x38]
     da5:	mov    r15,QWORD PTR [rsp+0x40]
     daa:	add    rsp,0x50
     dae:	mov    rsp,rbp
     db1:	pop    rbp
     db2:	ret
     db3:	mov    rcx,r12
     db6:	mov    rdi,r14
     db9:	mov    rax,QWORD PTR [rdi+0x10]
     dbd:	mov    rax,QWORD PTR [rax+0x10]
     dc1:	mov    QWORD PTR [rcx],0x1
     dc8:	mov    QWORD PTR [rcx+0x8],0x1
     dd0:	mov    rbx,QWORD PTR [rsp+0x20]
     dd5:	mov    r12,QWORD PTR [rsp+0x28]
     dda:	mov    r13,QWORD PTR [rsp+0x30]
     ddf:	mov    r14,QWORD PTR [rsp+0x38]
     de4:	mov    r15,QWORD PTR [rsp+0x40]
     de9:	add    rsp,0x50
     ded:	mov    rsp,rbp
     df0:	pop    rbp
     df1:	ret
     df2:	add    BYTE PTR [rax],al
     df4:	add    BYTE PTR [rax],al
     df6:	add    BYTE PTR [rax],al
     df8:	(bad)
     df9:	add    BYTE PTR [rax],al
     dfb:	add    BYTE PTR [rax],al
     dfd:	add    BYTE PTR [rax],al
	...

0000000000000e00 <botlish_entry_12: peek<str, int>>:
     e00:	push   rbp
     e01:	mov    rbp,rsp
     e04:	ud2

0000000000000e06 <botlish_fn_13: scan_unquoted<str, int, int>>:
     e06:	push   rbp
     e07:	mov    rbp,rsp
     e0a:	sub    rsp,0x80
     e11:	mov    QWORD PTR [rsp+0x50],rbx
     e16:	mov    QWORD PTR [rsp+0x58],r12
     e1b:	mov    QWORD PTR [rsp+0x60],r13
     e20:	mov    QWORD PTR [rsp+0x68],r14
     e25:	mov    QWORD PTR [rsp+0x70],r15
     e2a:	mov    QWORD PTR [rsp+0x30],rdi
     e2f:	mov    QWORD PTR [rsp+0x18],0x0
     e38:	mov    QWORD PTR [rsp],rsi
     e3c:	mov    r15,rsi
     e3f:	mov    QWORD PTR [rsp+0x8],rdx
     e44:	mov    r14,rdx
     e47:	mov    QWORD PTR [rsp+0x10],rcx
     e4c:	lea    r13,[rsp+0x20]
     e51:	mov    QWORD PTR [rsp+0x38],rcx
     e56:	mov    rcx,r13
     e59:	mov    rdx,QWORD PTR [rsp+0x38]
     e5e:	mov    rsi,r15
     e61:	mov    rdi,QWORD PTR [rsp+0x30]
     e66:	call   e6b <botlish_fn_13+0x65>
			e67: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
     e6b:	mov    rsi,rax
     e6e:	mov    QWORD PTR [rsp+0x40],rax
     e73:	test   rax,rsi
     e76:	je     fd0 <botlish_fn_13+0x1ca>
     e7c:	mov    rbx,QWORD PTR [rsp+0x20]
     e81:	mov    r12,QWORD PTR [rsp+0x28]
     e86:	mov    rdi,QWORD PTR [rsp+0x30]
     e8b:	mov    rcx,QWORD PTR [rdi+0x10]
     e8f:	mov    r8,QWORD PTR [rcx+0x10]
     e93:	mov    rcx,r12
     e96:	mov    rdx,rbx
     e99:	mov    rsi,QWORD PTR [rsp+0x40]
     e9e:	call   ea3 <botlish_fn_13+0x9d>
			e9f: R_X86_64_PLT32	rt_str_region_eq-0x4
     ea3:	cmp    rax,0x6
     ea7:	je     ee8 <botlish_fn_13+0xe2>
     ead:	mov    rdi,QWORD PTR [rsp+0x30]
     eb2:	mov    rax,QWORD PTR [rdi+0x10]
     eb6:	mov    r8,QWORD PTR [rax+0x18]
     eba:	mov    rcx,r12
     ebd:	mov    rdx,rbx
     ec0:	mov    rsi,QWORD PTR [rsp+0x40]
     ec5:	call   eca <botlish_fn_13+0xc4>
			ec6: R_X86_64_PLT32	rt_str_region_eq-0x4
     eca:	cmp    rax,0x6
     ece:	je     ede <botlish_fn_13+0xd8>
     ed4:	mov    eax,0x2
     ed9:	jmp    eed <botlish_fn_13+0xe7>
     ede:	mov    eax,0x6
     ee3:	jmp    eed <botlish_fn_13+0xe7>
     ee8:	mov    eax,0x6
     eed:	cmp    rax,0x6
     ef1:	je     f32 <botlish_fn_13+0x12c>
     ef7:	mov    rdi,QWORD PTR [rsp+0x30]
     efc:	mov    rax,QWORD PTR [rdi+0x10]
     f00:	mov    r8,QWORD PTR [rax+0x20]
     f04:	mov    rcx,r12
     f07:	mov    rdx,rbx
     f0a:	mov    rsi,QWORD PTR [rsp+0x40]
     f0f:	call   f14 <botlish_fn_13+0x10e>
			f10: R_X86_64_PLT32	rt_str_region_eq-0x4
     f14:	cmp    rax,0x6
     f18:	je     f28 <botlish_fn_13+0x122>
     f1e:	mov    eax,0x2
     f23:	jmp    f37 <botlish_fn_13+0x131>
     f28:	mov    eax,0x6
     f2d:	jmp    f37 <botlish_fn_13+0x131>
     f32:	mov    eax,0x6
     f37:	cmp    rax,0x6
     f3b:	je     fb2 <botlish_fn_13+0x1ac>
     f41:	mov    QWORD PTR [rsp+0x18],0x3
     f4a:	mov    rsi,QWORD PTR [rsp+0x38]
     f4f:	test   rsi,0x1
     f56:	je     f7d <botlish_fn_13+0x177>
     f5c:	mov    rsi,QWORD PTR [rsp+0x38]
     f61:	mov    rax,rsi
     f64:	add    rax,0x2
     f68:	seto   sil
     f6c:	test   sil,sil
     f6f:	jne    f7d <botlish_fn_13+0x177>
     f75:	mov    rsi,r15
     f78:	jmp    f94 <botlish_fn_13+0x18e>
     f7d:	mov    edx,0x3
     f82:	mov    rsi,QWORD PTR [rsp+0x38]
     f87:	mov    rdi,QWORD PTR [rsp+0x30]
     f8c:	call   f91 <botlish_fn_13+0x18b>
			f8d: R_X86_64_PLT32	rt_int_add-0x4
     f91:	mov    rsi,r15
     f94:	mov    QWORD PTR [rsp],rsi
     f98:	mov    rdx,r14
     f9b:	mov    QWORD PTR [rsp+0x8],rdx
     fa0:	mov    QWORD PTR [rsp+0x10],rax
     fa5:	mov    r15,rsi
     fa8:	mov    QWORD PTR [rsp+0x38],rax
     fad:	jmp    e56 <botlish_fn_13+0x50>
     fb2:	mov    rdx,r14
     fb5:	mov    rsi,r15
     fb8:	mov    rdi,QWORD PTR [rsp+0x30]
     fbd:	mov    rcx,QWORD PTR [rsp+0x38]
     fc2:	call   fc7 <botlish_fn_13+0x1c1>
			fc3: R_X86_64_PLT32	rt_substr-0x4
     fc7:	test   rax,rax
     fca:	jne    ffb <botlish_fn_13+0x1f5>
     fd0:	xor    rdx,rdx
     fd3:	mov    rax,rdx
     fd6:	mov    rbx,QWORD PTR [rsp+0x50]
     fdb:	mov    r12,QWORD PTR [rsp+0x58]
     fe0:	mov    r13,QWORD PTR [rsp+0x60]
     fe5:	mov    r14,QWORD PTR [rsp+0x68]
     fea:	mov    r15,QWORD PTR [rsp+0x70]
     fef:	add    rsp,0x80
     ff6:	mov    rsp,rbp
     ff9:	pop    rbp
     ffa:	ret
     ffb:	mov    rdx,QWORD PTR [rsp+0x38]
    1000:	mov    rbx,QWORD PTR [rsp+0x50]
    1005:	mov    r12,QWORD PTR [rsp+0x58]
    100a:	mov    r13,QWORD PTR [rsp+0x60]
    100f:	mov    r14,QWORD PTR [rsp+0x68]
    1014:	mov    r15,QWORD PTR [rsp+0x70]
    1019:	add    rsp,0x80
    1020:	mov    rsp,rbp
    1023:	pop    rbp
    1024:	ret

0000000000001025 <botlish_entry_13: scan_unquoted<str, int, int>>:
    1025:	push   rbp
    1026:	mov    rbp,rsp
    1029:	ud2
    102b:	add    BYTE PTR [rax],al
    102d:	add    BYTE PTR [rax],al
	...

0000000000001030 <botlish_fn_14: scan_quoted<str, int, str>>:
    1030:	push   rbp
    1031:	mov    rbp,rsp
    1034:	sub    rsp,0xd0
    103b:	mov    QWORD PTR [rsp+0xa0],rbx
    1043:	mov    QWORD PTR [rsp+0xa8],r12
    104b:	mov    QWORD PTR [rsp+0xb0],r13
    1053:	mov    QWORD PTR [rsp+0xb8],r14
    105b:	mov    QWORD PTR [rsp+0xc0],r15
    1063:	mov    r15,rdi
    1066:	mov    QWORD PTR [rsp+0x18],0x0
    106f:	mov    QWORD PTR [rsp+0x20],0x0
    1078:	mov    QWORD PTR [rsp],rsi
    107c:	mov    QWORD PTR [rsp+0x8],rdx
    1081:	mov    QWORD PTR [rsp+0x10],rcx
    1086:	mov    r13,rcx
    1089:	lea    r14,[rsp+0x68]
    108e:	lea    rbx,[rsp+0x28]
    1093:	mov    r12,rsi
    1096:	mov    QWORD PTR [rsp+0x88],rdx
    109e:	mov    rdx,QWORD PTR [rsp+0x88]
    10a6:	mov    rsi,r12
    10a9:	mov    rdi,r15
    10ac:	call   10b1 <botlish_fn_14+0x81>
			10ad: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    10b1:	test   rax,rax
    10b4:	je     13a8 <botlish_fn_14+0x378>
    10ba:	mov    QWORD PTR [rsp+0x18],rax
    10bf:	mov    rdx,QWORD PTR [rax+0x8]
    10c3:	mov    ecx,DWORD PTR [rax+0x14]
    10c6:	mov    QWORD PTR [rsp+0x90],rax
    10ce:	test   rdx,rdx
    10d1:	cmove  rcx,QWORD PTR [rip+0x327]        # 1400 <botlish_fn_14+0x3d0>
    10d9:	cmp    rcx,0x22
    10dd:	je     119d <botlish_fn_14+0x16d>
    10e3:	mov    QWORD PTR [rsp+0x20],0x3
    10ec:	mov    rsi,QWORD PTR [rsp+0x88]
    10f4:	test   rsi,0x1
    10fb:	je     111d <botlish_fn_14+0xed>
    1101:	mov    r8,rsi
    1104:	add    r8,0x2
    1108:	seto   r10b
    110c:	test   r10b,r10b
    110f:	jne    111d <botlish_fn_14+0xed>
    1115:	mov    rsi,r8
    1118:	jmp    112d <botlish_fn_14+0xfd>
    111d:	mov    edx,0x3
    1122:	mov    rdi,r15
    1125:	call   112a <botlish_fn_14+0xfa>
			1126: R_X86_64_PLT32	rt_int_add-0x4
    112a:	mov    rsi,rax
    112d:	mov    QWORD PTR [rsp+0x8],rsi
    1132:	mov    QWORD PTR [rsp+0x88],rsi
    113a:	mov    QWORD PTR [rsp+0x68],0x0
    1143:	mov    QWORD PTR [rsp+0x70],r13
    1148:	mov    QWORD PTR [rsp+0x78],0x0
    1151:	mov    rax,QWORD PTR [rsp+0x90]
    1159:	mov    QWORD PTR [rsp+0x80],rax
    1161:	mov    esi,0x2
    1166:	mov    edx,0x4
    116b:	mov    rcx,r14
    116e:	mov    rdi,r15
    1171:	call   1176 <botlish_fn_14+0x146>
			1172: R_X86_64_PLT32	rt_construct-0x4
    1176:	test   rax,rax
    1179:	je     13a8 <botlish_fn_14+0x378>
    117f:	mov    QWORD PTR [rsp],r12
    1183:	mov    rsi,QWORD PTR [rsp+0x88]
    118b:	mov    QWORD PTR [rsp+0x8],rsi
    1190:	mov    QWORD PTR [rsp+0x10],rax
    1195:	mov    r13,rax
    1198:	jmp    109e <botlish_fn_14+0x6e>
    119d:	mov    QWORD PTR [rsp+0x18],0x3
    11a6:	mov    rsi,QWORD PTR [rsp+0x88]
    11ae:	test   rsi,0x1
    11b5:	je     11d5 <botlish_fn_14+0x1a5>
    11bb:	mov    rsi,QWORD PTR [rsp+0x88]
    11c3:	mov    rdx,rsi
    11c6:	add    rdx,0x2
    11ca:	seto   al
    11cd:	test   al,al
    11cf:	je     11ed <botlish_fn_14+0x1bd>
    11d5:	mov    edx,0x3
    11da:	mov    rsi,QWORD PTR [rsp+0x88]
    11e2:	mov    rdi,r15
    11e5:	call   11ea <botlish_fn_14+0x1ba>
			11e6: R_X86_64_PLT32	rt_int_add-0x4
    11ea:	mov    rdx,rax
    11ed:	mov    QWORD PTR [rsp+0x18],rdx
    11f2:	mov    rcx,rbx
    11f5:	mov    rsi,r12
    11f8:	mov    rdi,r15
    11fb:	call   1200 <botlish_fn_14+0x1d0>
			11fc: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1200:	test   rax,rax
    1203:	mov    rsi,rax
    1206:	je     13a8 <botlish_fn_14+0x378>
    120c:	mov    rdx,QWORD PTR [rsp+0x28]
    1211:	mov    rcx,QWORD PTR [rsp+0x30]
    1216:	mov    rdi,r15
    1219:	mov    rax,QWORD PTR [rdi+0x10]
    121d:	mov    r8,QWORD PTR [rax+0x28]
    1221:	call   1226 <botlish_fn_14+0x1f6>
			1222: R_X86_64_PLT32	rt_str_region_eq-0x4
    1226:	cmp    rax,0x6
    122a:	je     12f2 <botlish_fn_14+0x2c2>
    1230:	xor    rsi,rsi
    1233:	lea    rcx,[rsp+0x58]
    1238:	mov    QWORD PTR [rsp+0x58],0x0
    1241:	mov    QWORD PTR [rsp+0x60],r13
    1246:	mov    edx,0x2
    124b:	mov    rdi,r15
    124e:	call   1253 <botlish_fn_14+0x223>
			124f: R_X86_64_PLT32	rt_construct-0x4
    1253:	test   rax,rax
    1256:	je     13a8 <botlish_fn_14+0x378>
    125c:	mov    QWORD PTR [rsp],rax
    1260:	mov    rbx,rax
    1263:	mov    QWORD PTR [rsp+0x10],0x3
    126c:	mov    rsi,QWORD PTR [rsp+0x88]
    1274:	test   rsi,0x1
    127b:	je     12a3 <botlish_fn_14+0x273>
    1281:	mov    rsi,QWORD PTR [rsp+0x88]
    1289:	mov    rdx,rsi
    128c:	add    rdx,0x2
    1290:	seto   al
    1293:	test   al,al
    1295:	jne    12a3 <botlish_fn_14+0x273>
    129b:	mov    rax,rbx
    129e:	jmp    12be <botlish_fn_14+0x28e>
    12a3:	mov    edx,0x3
    12a8:	mov    rsi,QWORD PTR [rsp+0x88]
    12b0:	mov    rdi,r15
    12b3:	call   12b8 <botlish_fn_14+0x288>
			12b4: R_X86_64_PLT32	rt_int_add-0x4
    12b8:	mov    rdx,rax
    12bb:	mov    rax,rbx
    12be:	mov    rbx,QWORD PTR [rsp+0xa0]
    12c6:	mov    r12,QWORD PTR [rsp+0xa8]
    12ce:	mov    r13,QWORD PTR [rsp+0xb0]
    12d6:	mov    r14,QWORD PTR [rsp+0xb8]
    12de:	mov    r15,QWORD PTR [rsp+0xc0]
    12e6:	add    rsp,0xd0
    12ed:	mov    rsp,rbp
    12f0:	pop    rbp
    12f1:	ret
    12f2:	mov    QWORD PTR [rsp+0x18],0x5
    12fb:	mov    rsi,QWORD PTR [rsp+0x88]
    1303:	test   rsi,0x1
    130a:	je     133a <botlish_fn_14+0x30a>
    1310:	mov    rsi,QWORD PTR [rsp+0x88]
    1318:	mov    rax,rsi
    131b:	add    rax,0x4
    131f:	seto   cl
    1322:	test   cl,cl
    1324:	jne    133a <botlish_fn_14+0x30a>
    132a:	mov    rsi,rax
    132d:	mov    QWORD PTR [rsp+0x88],rax
    1335:	jmp    135a <botlish_fn_14+0x32a>
    133a:	mov    edx,0x5
    133f:	mov    rsi,QWORD PTR [rsp+0x88]
    1347:	mov    rdi,r15
    134a:	call   134f <botlish_fn_14+0x31f>
			134b: R_X86_64_PLT32	rt_int_add-0x4
    134f:	mov    rsi,rax
    1352:	mov    QWORD PTR [rsp+0x88],rax
    135a:	mov    QWORD PTR [rsp+0x8],rsi
    135f:	mov    rdi,r15
    1362:	mov    rsi,QWORD PTR [rdi+0x10]
    1366:	mov    rsi,QWORD PTR [rsi+0x28]
    136a:	mov    QWORD PTR [rsp+0x18],rsi
    136f:	lea    rcx,[rsp+0x38]
    1374:	mov    QWORD PTR [rsp+0x38],0x0
    137d:	mov    QWORD PTR [rsp+0x40],r13
    1382:	mov    QWORD PTR [rsp+0x48],0x0
    138b:	mov    QWORD PTR [rsp+0x50],rsi
    1390:	mov    esi,0x2
    1395:	mov    edx,0x4
    139a:	call   139f <botlish_fn_14+0x36f>
			139b: R_X86_64_PLT32	rt_construct-0x4
    139f:	test   rax,rax
    13a2:	jne    13e2 <botlish_fn_14+0x3b2>
    13a8:	xor    rdx,rdx
    13ab:	mov    rax,rdx
    13ae:	mov    rbx,QWORD PTR [rsp+0xa0]
    13b6:	mov    r12,QWORD PTR [rsp+0xa8]
    13be:	mov    r13,QWORD PTR [rsp+0xb0]
    13c6:	mov    r14,QWORD PTR [rsp+0xb8]
    13ce:	mov    r15,QWORD PTR [rsp+0xc0]
    13d6:	add    rsp,0xd0
    13dd:	mov    rsp,rbp
    13e0:	pop    rbp
    13e1:	ret
    13e2:	mov    QWORD PTR [rsp],r12
    13e6:	mov    rsi,QWORD PTR [rsp+0x88]
    13ee:	mov    QWORD PTR [rsp+0x8],rsi
    13f3:	mov    QWORD PTR [rsp+0x10],rax
    13f8:	mov    r13,rax
    13fb:	jmp    109e <botlish_fn_14+0x6e>
    1400:	(bad)
    1401:	(bad)
    1402:	(bad)
    1403:	(bad)
    1404:	(bad)
    1405:	(bad)
    1406:	(bad)
    1407:	.byte 0xff

0000000000001408 <botlish_entry_14: scan_quoted<str, int, str>>:
    1408:	push   rbp
    1409:	mov    rbp,rsp
    140c:	ud2

000000000000140e <botlish_fn_15: scan_field<str, int>>:
    140e:	push   rbp
    140f:	mov    rbp,rsp
    1412:	sub    rsp,0x50
    1416:	mov    QWORD PTR [rsp+0x30],rbx
    141b:	mov    QWORD PTR [rsp+0x38],r12
    1420:	mov    QWORD PTR [rsp+0x40],r13
    1425:	mov    r12,rdi
    1428:	mov    r13,rdx
    142b:	mov    QWORD PTR [rsp+0x10],0x0
    1434:	mov    QWORD PTR [rsp],rsi
    1438:	mov    rbx,rsi
    143b:	mov    QWORD PTR [rsp+0x8],rdx
    1440:	lea    rcx,[rsp+0x18]
    1445:	mov    rdx,r13
    1448:	mov    rsi,rbx
    144b:	mov    rdi,r12
    144e:	call   1453 <botlish_fn_15+0x45>
			144f: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1453:	test   rax,rax
    1456:	mov    rsi,rax
    1459:	je     1524 <botlish_fn_15+0x116>
    145f:	mov    rdx,QWORD PTR [rsp+0x18]
    1464:	mov    rcx,QWORD PTR [rsp+0x20]
    1469:	mov    rdi,r12
    146c:	mov    rax,QWORD PTR [rdi+0x10]
    1470:	mov    r8,QWORD PTR [rax+0x28]
    1474:	call   1479 <botlish_fn_15+0x6b>
			1475: R_X86_64_PLT32	rt_str_region_eq-0x4
    1479:	cmp    rax,0x6
    147d:	je     14b5 <botlish_fn_15+0xa7>
    1483:	mov    rcx,r13
    1486:	mov    rsi,rbx
    1489:	mov    rdi,r12
    148c:	mov    rdx,rcx
    148f:	call   1494 <botlish_fn_15+0x86>
			1490: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    1494:	test   rax,rax
    1497:	je     1524 <botlish_fn_15+0x116>
    149d:	mov    rbx,QWORD PTR [rsp+0x30]
    14a2:	mov    r12,QWORD PTR [rsp+0x38]
    14a7:	mov    r13,QWORD PTR [rsp+0x40]
    14ac:	add    rsp,0x50
    14b0:	mov    rsp,rbp
    14b3:	pop    rbp
    14b4:	ret
    14b5:	mov    rcx,r13
    14b8:	mov    QWORD PTR [rsp+0x10],0x3
    14c1:	test   rcx,0x1
    14c8:	jne    14d6 <botlish_fn_15+0xc8>
    14ce:	mov    r13,rcx
    14d1:	jmp    14eb <botlish_fn_15+0xdd>
    14d6:	mov    rdx,rcx
    14d9:	add    rdx,0x2
    14dd:	mov    r13,rcx
    14e0:	seto   al
    14e3:	test   al,al
    14e5:	je     14fe <botlish_fn_15+0xf0>
    14eb:	mov    edx,0x3
    14f0:	mov    rsi,r13
    14f3:	mov    rdi,r12
    14f6:	call   14fb <botlish_fn_15+0xed>
			14f7: R_X86_64_PLT32	rt_int_add-0x4
    14fb:	mov    rdx,rax
    14fe:	mov    QWORD PTR [rsp+0x8],rdx
    1503:	mov    rdi,r12
    1506:	mov    rax,QWORD PTR [rdi+0x10]
    150a:	mov    rcx,QWORD PTR [rax+0x10]
    150e:	mov    QWORD PTR [rsp+0x10],rcx
    1513:	mov    rsi,rbx
    1516:	call   151b <botlish_fn_15+0x10d>
			1517: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    151b:	test   rax,rax
    151e:	jne    1542 <botlish_fn_15+0x134>
    1524:	xor    rdx,rdx
    1527:	mov    rax,rdx
    152a:	mov    rbx,QWORD PTR [rsp+0x30]
    152f:	mov    r12,QWORD PTR [rsp+0x38]
    1534:	mov    r13,QWORD PTR [rsp+0x40]
    1539:	add    rsp,0x50
    153d:	mov    rsp,rbp
    1540:	pop    rbp
    1541:	ret
    1542:	mov    rbx,QWORD PTR [rsp+0x30]
    1547:	mov    r12,QWORD PTR [rsp+0x38]
    154c:	mov    r13,QWORD PTR [rsp+0x40]
    1551:	add    rsp,0x50
    1555:	mov    rsp,rbp
    1558:	pop    rbp
    1559:	ret

000000000000155a <botlish_entry_15: scan_field<str, int>>:
    155a:	push   rbp
    155b:	mov    rbp,rsp
    155e:	ud2

0000000000001560 <botlish_fn_16: scan_record_rest<str, int, mutarray, int>>:
    1560:	push   rbp
    1561:	mov    rbp,rsp
    1564:	sub    rsp,0x90
    156b:	mov    QWORD PTR [rsp+0x60],rbx
    1570:	mov    QWORD PTR [rsp+0x68],r12
    1575:	mov    QWORD PTR [rsp+0x70],r13
    157a:	mov    QWORD PTR [rsp+0x78],r14
    157f:	mov    QWORD PTR [rsp+0x80],r15
    1587:	mov    r15,rdi
    158a:	mov    QWORD PTR [rsp+0x20],0x0
    1593:	mov    QWORD PTR [rsp],rsi
    1597:	mov    QWORD PTR [rsp+0x8],rdx
    159c:	mov    QWORD PTR [rsp+0x10],rcx
    15a1:	mov    QWORD PTR [rsp+0x18],r8
    15a6:	lea    r12,[rsp+0x28]
    15ab:	mov    rbx,rsi
    15ae:	mov    QWORD PTR [rsp+0x38],rdx
    15b3:	mov    QWORD PTR [rsp+0x40],rcx
    15b8:	mov    QWORD PTR [rsp+0x48],r8
    15bd:	mov    rcx,r12
    15c0:	mov    rdx,QWORD PTR [rsp+0x38]
    15c5:	mov    rsi,rbx
    15c8:	mov    rdi,r15
    15cb:	call   15d0 <botlish_fn_16+0x70>
			15cc: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    15d0:	test   rax,rax
    15d3:	mov    QWORD PTR [rsp+0x50],rax
    15d8:	je     179c <botlish_fn_16+0x23c>
    15de:	mov    r14,QWORD PTR [rsp+0x28]
    15e3:	mov    r13,QWORD PTR [rsp+0x30]
    15e8:	mov    rdi,r15
    15eb:	mov    rcx,QWORD PTR [rdi+0x10]
    15ef:	mov    r8,QWORD PTR [rcx+0x18]
    15f3:	mov    rcx,r13
    15f6:	mov    rdx,r14
    15f9:	mov    rsi,QWORD PTR [rsp+0x50]
    15fe:	call   1603 <botlish_fn_16+0xa3>
			15ff: R_X86_64_PLT32	rt_str_region_eq-0x4
    1603:	cmp    rax,0x6
    1607:	je     1715 <botlish_fn_16+0x1b5>
    160d:	mov    rdi,r15
    1610:	mov    rax,QWORD PTR [rdi+0x10]
    1614:	mov    r8,QWORD PTR [rax+0x20]
    1618:	mov    rcx,r13
    161b:	mov    rdx,r14
    161e:	mov    rsi,QWORD PTR [rsp+0x50]
    1623:	call   1628 <botlish_fn_16+0xc8>
			1624: R_X86_64_PLT32	rt_str_region_eq-0x4
    1628:	cmp    rax,0x6
    162c:	je     167a <botlish_fn_16+0x11a>
    1632:	mov    rdx,QWORD PTR [rsp+0x48]
    1637:	mov    rsi,QWORD PTR [rsp+0x40]
    163c:	mov    rdi,r15
    163f:	call   1644 <botlish_fn_16+0xe4>
			1640: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    1644:	test   rax,rax
    1647:	je     179c <botlish_fn_16+0x23c>
    164d:	mov    rdx,QWORD PTR [rsp+0x38]
    1652:	mov    rbx,QWORD PTR [rsp+0x60]
    1657:	mov    r12,QWORD PTR [rsp+0x68]
    165c:	mov    r13,QWORD PTR [rsp+0x70]
    1661:	mov    r14,QWORD PTR [rsp+0x78]
    1666:	mov    r15,QWORD PTR [rsp+0x80]
    166e:	add    rsp,0x90
    1675:	mov    rsp,rbp
    1678:	pop    rbp
    1679:	ret
    167a:	mov    rdx,QWORD PTR [rsp+0x48]
    167f:	mov    rsi,QWORD PTR [rsp+0x40]
    1684:	mov    rdi,r15
    1687:	call   168c <botlish_fn_16+0x12c>
			1688: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    168c:	test   rax,rax
    168f:	je     179c <botlish_fn_16+0x23c>
    1695:	mov    QWORD PTR [rsp],rax
    1699:	mov    rbx,rax
    169c:	mov    QWORD PTR [rsp+0x10],0x3
    16a5:	mov    rdx,QWORD PTR [rsp+0x38]
    16aa:	test   rdx,0x1
    16b1:	je     16d5 <botlish_fn_16+0x175>
    16b7:	mov    rdx,QWORD PTR [rsp+0x38]
    16bc:	add    rdx,0x2
    16c0:	seto   sil
    16c4:	test   sil,sil
    16c7:	jne    16d5 <botlish_fn_16+0x175>
    16cd:	mov    rax,rbx
    16d0:	jmp    16ed <botlish_fn_16+0x18d>
    16d5:	mov    edx,0x3
    16da:	mov    rsi,QWORD PTR [rsp+0x38]
    16df:	mov    rdi,r15
    16e2:	call   16e7 <botlish_fn_16+0x187>
			16e3: R_X86_64_PLT32	rt_int_add-0x4
    16e7:	mov    rdx,rax
    16ea:	mov    rax,rbx
    16ed:	mov    rbx,QWORD PTR [rsp+0x60]
    16f2:	mov    r12,QWORD PTR [rsp+0x68]
    16f7:	mov    r13,QWORD PTR [rsp+0x70]
    16fc:	mov    r14,QWORD PTR [rsp+0x78]
    1701:	mov    r15,QWORD PTR [rsp+0x80]
    1709:	add    rsp,0x90
    1710:	mov    rsp,rbp
    1713:	pop    rbp
    1714:	ret
    1715:	mov    rsi,QWORD PTR [rsp+0x38]
    171a:	mov    edx,0x3
    171f:	mov    r13,rdx
    1722:	mov    QWORD PTR [rsp+0x20],0x3
    172b:	test   rsi,0x1
    1732:	je     174a <botlish_fn_16+0x1ea>
    1738:	mov    rdx,rsi
    173b:	add    rdx,0x2
    173f:	seto   al
    1742:	test   al,al
    1744:	je     1758 <botlish_fn_16+0x1f8>
    174a:	mov    rdx,r13
    174d:	mov    rdi,r15
    1750:	call   1755 <botlish_fn_16+0x1f5>
			1751: R_X86_64_PLT32	rt_int_add-0x4
    1755:	mov    rdx,rax
    1758:	mov    QWORD PTR [rsp+0x8],rdx
    175d:	mov    rsi,rbx
    1760:	mov    rdi,r15
    1763:	call   1768 <botlish_fn_16+0x208>
			1764: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    1768:	test   rax,rax
    176b:	je     179c <botlish_fn_16+0x23c>
    1771:	mov    QWORD PTR [rsp+0x8],rax
    1776:	mov    rcx,rax
    1779:	mov    QWORD PTR [rsp+0x20],rdx
    177e:	mov    rsi,QWORD PTR [rsp+0x40]
    1783:	mov    r14,rdx
    1786:	mov    rdx,QWORD PTR [rsp+0x48]
    178b:	mov    rdi,r15
    178e:	call   1793 <botlish_fn_16+0x233>
			178f: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
    1793:	test   rax,rax
    1796:	jne    17ca <botlish_fn_16+0x26a>
    179c:	xor    rdx,rdx
    179f:	mov    rax,rdx
    17a2:	mov    rbx,QWORD PTR [rsp+0x60]
    17a7:	mov    r12,QWORD PTR [rsp+0x68]
    17ac:	mov    r13,QWORD PTR [rsp+0x70]
    17b1:	mov    r14,QWORD PTR [rsp+0x78]
    17b6:	mov    r15,QWORD PTR [rsp+0x80]
    17be:	add    rsp,0x90
    17c5:	mov    rsp,rbp
    17c8:	pop    rbp
    17c9:	ret
    17ca:	mov    QWORD PTR [rsp+0x8],rax
    17cf:	mov    QWORD PTR [rsp+0x38],rax
    17d4:	mov    QWORD PTR [rsp+0x10],0x3
    17dd:	mov    rdx,QWORD PTR [rsp+0x48]
    17e2:	test   rdx,0x1
    17e9:	jne    17fc <botlish_fn_16+0x29c>
    17ef:	mov    rdx,r13
    17f2:	mov    rsi,QWORD PTR [rsp+0x48]
    17f7:	jmp    181b <botlish_fn_16+0x2bb>
    17fc:	mov    rdx,QWORD PTR [rsp+0x48]
    1801:	mov    rax,rdx
    1804:	add    rax,0x2
    1808:	seto   cl
    180b:	test   cl,cl
    180d:	je     1823 <botlish_fn_16+0x2c3>
    1813:	mov    rdx,r13
    1816:	mov    rsi,QWORD PTR [rsp+0x48]
    181b:	mov    rdi,r15
    181e:	call   1823 <botlish_fn_16+0x2c3>
			181f: R_X86_64_PLT32	rt_int_add-0x4
    1823:	mov    QWORD PTR [rsp],rbx
    1827:	mov    rdx,r14
    182a:	mov    QWORD PTR [rsp+0x8],rdx
    182f:	mov    rcx,QWORD PTR [rsp+0x38]
    1834:	mov    QWORD PTR [rsp+0x10],rcx
    1839:	mov    QWORD PTR [rsp+0x18],rax
    183e:	mov    QWORD PTR [rsp+0x38],rdx
    1843:	mov    QWORD PTR [rsp+0x40],rcx
    1848:	mov    QWORD PTR [rsp+0x48],rax
    184d:	jmp    15bd <botlish_fn_16+0x5d>

0000000000001852 <botlish_entry_16: scan_record_rest<str, int, mutarray, int>>:
    1852:	push   rbp
    1853:	mov    rbp,rsp
    1856:	ud2

0000000000001858 <botlish_fn_17: scan_record<str, int>>:
    1858:	push   rbp
    1859:	mov    rbp,rsp
    185c:	sub    rsp,0x40
    1860:	mov    QWORD PTR [rsp+0x20],rbx
    1865:	mov    QWORD PTR [rsp+0x28],r12
    186a:	mov    QWORD PTR [rsp+0x30],r14
    186f:	mov    r14,rdi
    1872:	mov    QWORD PTR [rsp+0x10],0x0
    187b:	mov    QWORD PTR [rsp+0x18],0x0
    1884:	mov    QWORD PTR [rsp],rsi
    1888:	mov    r12,rsi
    188b:	mov    QWORD PTR [rsp+0x8],rdx
    1890:	mov    rsi,r12
    1893:	mov    rdi,r14
    1896:	call   189b <botlish_fn_17+0x43>
			1897: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    189b:	test   rax,rax
    189e:	je     18f3 <botlish_fn_17+0x9b>
    18a4:	mov    QWORD PTR [rsp+0x8],rax
    18a9:	mov    rsi,rax
    18ac:	mov    QWORD PTR [rsp+0x10],rdx
    18b1:	mov    rbx,rdx
    18b4:	mov    rdi,r14
    18b7:	call   18bc <botlish_fn_17+0x64>
			18b8: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<str>
    18bc:	test   rax,rax
    18bf:	je     18f3 <botlish_fn_17+0x9b>
    18c5:	mov    QWORD PTR [rsp+0x8],rax
    18ca:	mov    rcx,rax
    18cd:	mov    r8d,0x3
    18d3:	mov    QWORD PTR [rsp+0x18],0x3
    18dc:	mov    rdx,rbx
    18df:	mov    rsi,r12
    18e2:	mov    rdi,r14
    18e5:	call   18ea <botlish_fn_17+0x92>
			18e6: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record_rest<str, int, mutarray, int>
    18ea:	test   rax,rax
    18ed:	jne    1911 <botlish_fn_17+0xb9>
    18f3:	xor    rdx,rdx
    18f6:	mov    rax,rdx
    18f9:	mov    rbx,QWORD PTR [rsp+0x20]
    18fe:	mov    r12,QWORD PTR [rsp+0x28]
    1903:	mov    r14,QWORD PTR [rsp+0x30]
    1908:	add    rsp,0x40
    190c:	mov    rsp,rbp
    190f:	pop    rbp
    1910:	ret
    1911:	mov    rbx,QWORD PTR [rsp+0x20]
    1916:	mov    r12,QWORD PTR [rsp+0x28]
    191b:	mov    r14,QWORD PTR [rsp+0x30]
    1920:	add    rsp,0x40
    1924:	mov    rsp,rbp
    1927:	pop    rbp
    1928:	ret

0000000000001929 <botlish_entry_17: scan_record<str, int>>:
    1929:	push   rbp
    192a:	mov    rbp,rsp
    192d:	ud2
	...

0000000000001930 <botlish_fn_18: scan_records<str, int, mutarray, int>>:
    1930:	push   rbp
    1931:	mov    rbp,rsp
    1934:	sub    rsp,0x60
    1938:	mov    QWORD PTR [rsp+0x30],rbx
    193d:	mov    QWORD PTR [rsp+0x38],r12
    1942:	mov    QWORD PTR [rsp+0x40],r13
    1947:	mov    QWORD PTR [rsp+0x48],r14
    194c:	mov    QWORD PTR [rsp+0x50],r15
    1951:	mov    r13,rdi
    1954:	mov    QWORD PTR [rsp+0x20],0x0
    195d:	mov    QWORD PTR [rsp],rsi
    1961:	mov    QWORD PTR [rsp+0x8],rdx
    1966:	mov    r12,rdx
    1969:	mov    QWORD PTR [rsp+0x10],rcx
    196e:	mov    QWORD PTR [rsp+0x18],r8
    1973:	mov    rbx,rsi
    1976:	mov    r14,r8
    1979:	mov    r15,rcx
    197c:	mov    rsi,rbx
    197f:	mov    rdi,r13
    1982:	call   1987 <botlish_fn_18+0x57>
			1983: R_X86_64_PLT32	rt_str_len-0x4
    1987:	mov    rcx,r12
    198a:	and    rcx,rax
    198d:	mov    rdx,rax
    1990:	test   rcx,0x1
    1997:	jne    19bd <botlish_fn_18+0x8d>
    199d:	mov    rsi,r12
    19a0:	mov    rdi,r13
    19a3:	call   19a8 <botlish_fn_18+0x78>
			19a4: R_X86_64_PLT32	rt_int_cmp-0x4
    19a8:	mov    ecx,0x2
    19ad:	test   rax,rax
    19b0:	cmovge rcx,QWORD PTR [rip+0x128]        # 1ae0 <botlish_fn_18+0x1b0>
    19b8:	jmp    19cd <botlish_fn_18+0x9d>
    19bd:	mov    ecx,0x2
    19c2:	cmp    r12,rdx
    19c5:	cmovge rcx,QWORD PTR [rip+0x113]        # 1ae0 <botlish_fn_18+0x1b0>
    19cd:	cmp    rcx,0x6
    19d1:	je     1a7c <botlish_fn_18+0x14c>
    19d7:	mov    rdx,r12
    19da:	mov    rsi,rbx
    19dd:	mov    rdi,r13
    19e0:	call   19e5 <botlish_fn_18+0xb5>
			19e1: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int>
    19e5:	test   rax,rax
    19e8:	je     1a93 <botlish_fn_18+0x163>
    19ee:	mov    QWORD PTR [rsp+0x8],rax
    19f3:	mov    rcx,rax
    19f6:	mov    QWORD PTR [rsp+0x20],rdx
    19fb:	mov    rsi,r15
    19fe:	mov    r12,rdx
    1a01:	mov    rdx,r14
    1a04:	mov    rdi,r13
    1a07:	call   1a0c <botlish_fn_18+0xdc>
			1a08: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
    1a0c:	test   rax,rax
    1a0f:	je     1a93 <botlish_fn_18+0x163>
    1a15:	mov    QWORD PTR [rsp+0x8],rax
    1a1a:	mov    r15,rax
    1a1d:	mov    QWORD PTR [rsp+0x10],0x3
    1a26:	mov    rsi,r14
    1a29:	test   rsi,0x1
    1a30:	je     1a4b <botlish_fn_18+0x11b>
    1a36:	mov    rsi,r14
    1a39:	mov    rax,rsi
    1a3c:	add    rax,0x2
    1a40:	seto   cl
    1a43:	test   cl,cl
    1a45:	je     1a5b <botlish_fn_18+0x12b>
    1a4b:	mov    edx,0x3
    1a50:	mov    rsi,r14
    1a53:	mov    rdi,r13
    1a56:	call   1a5b <botlish_fn_18+0x12b>
			1a57: R_X86_64_PLT32	rt_int_add-0x4
    1a5b:	mov    QWORD PTR [rsp],rbx
    1a5f:	mov    rdx,r12
    1a62:	mov    QWORD PTR [rsp+0x8],rdx
    1a67:	mov    rcx,r15
    1a6a:	mov    QWORD PTR [rsp+0x10],rcx
    1a6f:	mov    QWORD PTR [rsp+0x18],rax
    1a74:	mov    r14,rax
    1a77:	jmp    197c <botlish_fn_18+0x4c>
    1a7c:	mov    rdx,r14
    1a7f:	mov    rsi,r15
    1a82:	mov    rdi,r13
    1a85:	call   1a8a <botlish_fn_18+0x15a>
			1a86: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    1a8a:	test   rax,rax
    1a8d:	jne    1ab8 <botlish_fn_18+0x188>
    1a93:	xor    rax,rax
    1a96:	mov    rbx,QWORD PTR [rsp+0x30]
    1a9b:	mov    r12,QWORD PTR [rsp+0x38]
    1aa0:	mov    r13,QWORD PTR [rsp+0x40]
    1aa5:	mov    r14,QWORD PTR [rsp+0x48]
    1aaa:	mov    r15,QWORD PTR [rsp+0x50]
    1aaf:	add    rsp,0x60
    1ab3:	mov    rsp,rbp
    1ab6:	pop    rbp
    1ab7:	ret
    1ab8:	mov    rbx,QWORD PTR [rsp+0x30]
    1abd:	mov    r12,QWORD PTR [rsp+0x38]
    1ac2:	mov    r13,QWORD PTR [rsp+0x40]
    1ac7:	mov    r14,QWORD PTR [rsp+0x48]
    1acc:	mov    r15,QWORD PTR [rsp+0x50]
    1ad1:	add    rsp,0x60
    1ad5:	mov    rsp,rbp
    1ad8:	pop    rbp
    1ad9:	ret
    1ada:	add    BYTE PTR [rax],al
    1adc:	add    BYTE PTR [rax],al
    1ade:	add    BYTE PTR [rax],al
    1ae0:	(bad)
    1ae1:	add    BYTE PTR [rax],al
    1ae3:	add    BYTE PTR [rax],al
    1ae5:	add    BYTE PTR [rax],al
	...

0000000000001ae8 <botlish_entry_18: scan_records<str, int, mutarray, int>>:
    1ae8:	push   rbp
    1ae9:	mov    rbp,rsp
    1aec:	mov    rsi,QWORD PTR [rdx]
    1aef:	mov    r9,QWORD PTR [rdx+0x8]
    1af3:	mov    rcx,QWORD PTR [rdx+0x10]
    1af7:	mov    r8,QWORD PTR [rdx+0x18]
    1afb:	mov    rdx,r9
    1afe:	call   1b03 <botlish_entry_18+0x1b>
			1aff: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, mutarray, int>
    1b03:	mov    rsp,rbp
    1b06:	pop    rbp
    1b07:	ret

0000000000001b08 <botlish_fn_19: csv_parse<str>>:
    1b08:	push   rbp
    1b09:	mov    rbp,rsp
    1b0c:	sub    rsp,0x40
    1b10:	mov    QWORD PTR [rsp+0x20],rbx
    1b15:	mov    QWORD PTR [rsp+0x28],r12
    1b1a:	mov    QWORD PTR [rsp+0x30],r13
    1b1f:	mov    rbx,rdi
    1b22:	mov    QWORD PTR [rsp+0x8],0x0
    1b2b:	mov    QWORD PTR [rsp+0x10],0x0
    1b34:	mov    QWORD PTR [rsp+0x18],0x0
    1b3d:	mov    QWORD PTR [rsp],rsi
    1b41:	mov    r12,rsi
    1b44:	mov    rsi,r12
    1b47:	mov    rdi,rbx
    1b4a:	call   1b4f <botlish_fn_19+0x47>
			1b4b: R_X86_64_PLT32	rt_str_len-0x4
    1b4f:	sar    rax,1
    1b52:	test   rax,rax
    1b55:	je     1be4 <botlish_fn_19+0xdc>
    1b5b:	mov    edx,0x1
    1b60:	mov    QWORD PTR [rsp+0x8],0x1
    1b69:	mov    rsi,r12
    1b6c:	mov    rdi,rbx
    1b6f:	call   1b74 <botlish_fn_19+0x6c>
			1b70: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int>
    1b74:	test   rax,rax
    1b77:	je     1bfb <botlish_fn_19+0xf3>
    1b7d:	mov    QWORD PTR [rsp+0x8],rax
    1b82:	mov    rsi,rax
    1b85:	mov    QWORD PTR [rsp+0x10],rdx
    1b8a:	mov    r13,rdx
    1b8d:	mov    rdi,rbx
    1b90:	call   1b95 <botlish_fn_19+0x8d>
			1b91: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<List[str]>
    1b95:	test   rax,rax
    1b98:	je     1bfb <botlish_fn_19+0xf3>
    1b9e:	mov    QWORD PTR [rsp+0x8],rax
    1ba3:	mov    rcx,rax
    1ba6:	mov    r8d,0x3
    1bac:	mov    QWORD PTR [rsp+0x18],0x3
    1bb5:	mov    rdx,r13
    1bb8:	mov    rsi,r12
    1bbb:	mov    rdi,rbx
    1bbe:	call   1bc3 <botlish_fn_19+0xbb>
			1bbf: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, mutarray, int>
    1bc3:	test   rax,rax
    1bc6:	je     1bfb <botlish_fn_19+0xf3>
    1bcc:	mov    rbx,QWORD PTR [rsp+0x20]
    1bd1:	mov    r12,QWORD PTR [rsp+0x28]
    1bd6:	mov    r13,QWORD PTR [rsp+0x30]
    1bdb:	add    rsp,0x40
    1bdf:	mov    rsp,rbp
    1be2:	pop    rbp
    1be3:	ret
    1be4:	xor    rdx,rdx
    1be7:	mov    rdi,rbx
    1bea:	mov    rsi,rdx
    1bed:	call   1bf2 <botlish_fn_19+0xea>
			1bee: R_X86_64_PLT32	rt_list_new-0x4
    1bf2:	test   rax,rax
    1bf5:	jne    1c16 <botlish_fn_19+0x10e>
    1bfb:	xor    rax,rax
    1bfe:	mov    rbx,QWORD PTR [rsp+0x20]
    1c03:	mov    r12,QWORD PTR [rsp+0x28]
    1c08:	mov    r13,QWORD PTR [rsp+0x30]
    1c0d:	add    rsp,0x40
    1c11:	mov    rsp,rbp
    1c14:	pop    rbp
    1c15:	ret
    1c16:	mov    rbx,QWORD PTR [rsp+0x20]
    1c1b:	mov    r12,QWORD PTR [rsp+0x28]
    1c20:	mov    r13,QWORD PTR [rsp+0x30]
    1c25:	add    rsp,0x40
    1c29:	mov    rsp,rbp
    1c2c:	pop    rbp
    1c2d:	ret

0000000000001c2e <botlish_entry_19: csv_parse<str>>:
    1c2e:	push   rbp
    1c2f:	mov    rbp,rsp
    1c32:	mov    rsi,QWORD PTR [rdx]
    1c35:	call   1c3a <botlish_entry_19+0xc>
			1c36: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    1c3a:	mov    rsp,rbp
    1c3d:	pop    rbp
    1c3e:	ret

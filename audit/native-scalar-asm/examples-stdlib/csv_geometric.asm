; source:  examples/stdlib/csv_geometric.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 7578  (per function: 68 461 461 81 81 357 412 412 279 279 81 365 430 585 1063 352 783 215 488 325)
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

000000000000102b <botlish_fn_14: scan_quoted<str, int, str>>:
    102b:	push   rbp
    102c:	mov    rbp,rsp
    102f:	sub    rsp,0xd0
    1036:	mov    QWORD PTR [rsp+0xa0],rbx
    103e:	mov    QWORD PTR [rsp+0xa8],r12
    1046:	mov    QWORD PTR [rsp+0xb0],r13
    104e:	mov    QWORD PTR [rsp+0xb8],r14
    1056:	mov    QWORD PTR [rsp+0xc0],r15
    105e:	mov    r15,rdi
    1061:	mov    QWORD PTR [rsp+0x18],0x0
    106a:	mov    QWORD PTR [rsp+0x20],0x0
    1073:	mov    QWORD PTR [rsp],rsi
    1077:	mov    QWORD PTR [rsp+0x8],rdx
    107c:	mov    QWORD PTR [rsp+0x10],rcx
    1081:	mov    r13,rcx
    1084:	lea    r14,[rsp+0x68]
    1089:	lea    rbx,[rsp+0x28]
    108e:	mov    r12,rsi
    1091:	mov    QWORD PTR [rsp+0x88],rdx
    1099:	mov    rdx,QWORD PTR [rsp+0x88]
    10a1:	mov    rsi,r12
    10a4:	mov    rdi,r15
    10a7:	call   10ac <botlish_fn_14+0x81>
			10a8: R_X86_64_PLT32	botlish_fn_11-0x4 ; peek<str, int>
    10ac:	test   rax,rax
    10af:	je     13b3 <botlish_fn_14+0x388>
    10b5:	mov    QWORD PTR [rsp+0x18],rax
    10ba:	mov    rdi,r15
    10bd:	mov    QWORD PTR [rsp+0x90],rax
    10c5:	mov    rsi,QWORD PTR [rdi+0x10]
    10c9:	mov    rsi,QWORD PTR [rsi+0x28]
    10cd:	mov    edx,0x1
    10d2:	mov    ecx,0x3
    10d7:	mov    r8,QWORD PTR [rsp+0x90]
    10df:	call   10e4 <botlish_fn_14+0xb9>
			10e0: R_X86_64_PLT32	rt_str_region_eq-0x4
    10e4:	cmp    rax,0x6
    10e8:	je     11a8 <botlish_fn_14+0x17d>
    10ee:	mov    QWORD PTR [rsp+0x20],0x3
    10f7:	mov    rsi,QWORD PTR [rsp+0x88]
    10ff:	test   rsi,0x1
    1106:	je     1128 <botlish_fn_14+0xfd>
    110c:	mov    r9,rsi
    110f:	add    r9,0x2
    1113:	seto   r11b
    1117:	test   r11b,r11b
    111a:	jne    1128 <botlish_fn_14+0xfd>
    1120:	mov    rsi,r9
    1123:	jmp    1138 <botlish_fn_14+0x10d>
    1128:	mov    edx,0x3
    112d:	mov    rdi,r15
    1130:	call   1135 <botlish_fn_14+0x10a>
			1131: R_X86_64_PLT32	rt_int_add-0x4
    1135:	mov    rsi,rax
    1138:	mov    QWORD PTR [rsp+0x8],rsi
    113d:	mov    QWORD PTR [rsp+0x88],rsi
    1145:	mov    QWORD PTR [rsp+0x68],0x0
    114e:	mov    QWORD PTR [rsp+0x70],r13
    1153:	mov    QWORD PTR [rsp+0x78],0x0
    115c:	mov    rax,QWORD PTR [rsp+0x90]
    1164:	mov    QWORD PTR [rsp+0x80],rax
    116c:	mov    esi,0x2
    1171:	mov    edx,0x4
    1176:	mov    rcx,r14
    1179:	mov    rdi,r15
    117c:	call   1181 <botlish_fn_14+0x156>
			117d: R_X86_64_PLT32	rt_construct-0x4
    1181:	test   rax,rax
    1184:	je     13b3 <botlish_fn_14+0x388>
    118a:	mov    QWORD PTR [rsp],r12
    118e:	mov    rsi,QWORD PTR [rsp+0x88]
    1196:	mov    QWORD PTR [rsp+0x8],rsi
    119b:	mov    QWORD PTR [rsp+0x10],rax
    11a0:	mov    r13,rax
    11a3:	jmp    1099 <botlish_fn_14+0x6e>
    11a8:	mov    QWORD PTR [rsp+0x18],0x3
    11b1:	mov    rsi,QWORD PTR [rsp+0x88]
    11b9:	test   rsi,0x1
    11c0:	je     11e0 <botlish_fn_14+0x1b5>
    11c6:	mov    rsi,QWORD PTR [rsp+0x88]
    11ce:	mov    rdx,rsi
    11d1:	add    rdx,0x2
    11d5:	seto   al
    11d8:	test   al,al
    11da:	je     11f8 <botlish_fn_14+0x1cd>
    11e0:	mov    edx,0x3
    11e5:	mov    rsi,QWORD PTR [rsp+0x88]
    11ed:	mov    rdi,r15
    11f0:	call   11f5 <botlish_fn_14+0x1ca>
			11f1: R_X86_64_PLT32	rt_int_add-0x4
    11f5:	mov    rdx,rax
    11f8:	mov    QWORD PTR [rsp+0x18],rdx
    11fd:	mov    rcx,rbx
    1200:	mov    rsi,r12
    1203:	mov    rdi,r15
    1206:	call   120b <botlish_fn_14+0x1e0>
			1207: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    120b:	test   rax,rax
    120e:	mov    rsi,rax
    1211:	je     13b3 <botlish_fn_14+0x388>
    1217:	mov    rdx,QWORD PTR [rsp+0x28]
    121c:	mov    rcx,QWORD PTR [rsp+0x30]
    1221:	mov    rdi,r15
    1224:	mov    rax,QWORD PTR [rdi+0x10]
    1228:	mov    r8,QWORD PTR [rax+0x28]
    122c:	call   1231 <botlish_fn_14+0x206>
			122d: R_X86_64_PLT32	rt_str_region_eq-0x4
    1231:	cmp    rax,0x6
    1235:	je     12fd <botlish_fn_14+0x2d2>
    123b:	xor    rsi,rsi
    123e:	lea    rcx,[rsp+0x58]
    1243:	mov    QWORD PTR [rsp+0x58],0x0
    124c:	mov    QWORD PTR [rsp+0x60],r13
    1251:	mov    edx,0x2
    1256:	mov    rdi,r15
    1259:	call   125e <botlish_fn_14+0x233>
			125a: R_X86_64_PLT32	rt_construct-0x4
    125e:	test   rax,rax
    1261:	je     13b3 <botlish_fn_14+0x388>
    1267:	mov    QWORD PTR [rsp],rax
    126b:	mov    rbx,rax
    126e:	mov    QWORD PTR [rsp+0x10],0x3
    1277:	mov    rsi,QWORD PTR [rsp+0x88]
    127f:	test   rsi,0x1
    1286:	je     12ae <botlish_fn_14+0x283>
    128c:	mov    rsi,QWORD PTR [rsp+0x88]
    1294:	mov    rdx,rsi
    1297:	add    rdx,0x2
    129b:	seto   al
    129e:	test   al,al
    12a0:	jne    12ae <botlish_fn_14+0x283>
    12a6:	mov    rax,rbx
    12a9:	jmp    12c9 <botlish_fn_14+0x29e>
    12ae:	mov    edx,0x3
    12b3:	mov    rsi,QWORD PTR [rsp+0x88]
    12bb:	mov    rdi,r15
    12be:	call   12c3 <botlish_fn_14+0x298>
			12bf: R_X86_64_PLT32	rt_int_add-0x4
    12c3:	mov    rdx,rax
    12c6:	mov    rax,rbx
    12c9:	mov    rbx,QWORD PTR [rsp+0xa0]
    12d1:	mov    r12,QWORD PTR [rsp+0xa8]
    12d9:	mov    r13,QWORD PTR [rsp+0xb0]
    12e1:	mov    r14,QWORD PTR [rsp+0xb8]
    12e9:	mov    r15,QWORD PTR [rsp+0xc0]
    12f1:	add    rsp,0xd0
    12f8:	mov    rsp,rbp
    12fb:	pop    rbp
    12fc:	ret
    12fd:	mov    QWORD PTR [rsp+0x18],0x5
    1306:	mov    rsi,QWORD PTR [rsp+0x88]
    130e:	test   rsi,0x1
    1315:	je     1345 <botlish_fn_14+0x31a>
    131b:	mov    rsi,QWORD PTR [rsp+0x88]
    1323:	mov    rax,rsi
    1326:	add    rax,0x4
    132a:	seto   cl
    132d:	test   cl,cl
    132f:	jne    1345 <botlish_fn_14+0x31a>
    1335:	mov    rsi,rax
    1338:	mov    QWORD PTR [rsp+0x88],rax
    1340:	jmp    1365 <botlish_fn_14+0x33a>
    1345:	mov    edx,0x5
    134a:	mov    rsi,QWORD PTR [rsp+0x88]
    1352:	mov    rdi,r15
    1355:	call   135a <botlish_fn_14+0x32f>
			1356: R_X86_64_PLT32	rt_int_add-0x4
    135a:	mov    rsi,rax
    135d:	mov    QWORD PTR [rsp+0x88],rax
    1365:	mov    QWORD PTR [rsp+0x8],rsi
    136a:	mov    rdi,r15
    136d:	mov    rsi,QWORD PTR [rdi+0x10]
    1371:	mov    rsi,QWORD PTR [rsi+0x28]
    1375:	mov    QWORD PTR [rsp+0x18],rsi
    137a:	lea    rcx,[rsp+0x38]
    137f:	mov    QWORD PTR [rsp+0x38],0x0
    1388:	mov    QWORD PTR [rsp+0x40],r13
    138d:	mov    QWORD PTR [rsp+0x48],0x0
    1396:	mov    QWORD PTR [rsp+0x50],rsi
    139b:	mov    esi,0x2
    13a0:	mov    edx,0x4
    13a5:	call   13aa <botlish_fn_14+0x37f>
			13a6: R_X86_64_PLT32	rt_construct-0x4
    13aa:	test   rax,rax
    13ad:	jne    13ed <botlish_fn_14+0x3c2>
    13b3:	xor    rdx,rdx
    13b6:	mov    rax,rdx
    13b9:	mov    rbx,QWORD PTR [rsp+0xa0]
    13c1:	mov    r12,QWORD PTR [rsp+0xa8]
    13c9:	mov    r13,QWORD PTR [rsp+0xb0]
    13d1:	mov    r14,QWORD PTR [rsp+0xb8]
    13d9:	mov    r15,QWORD PTR [rsp+0xc0]
    13e1:	add    rsp,0xd0
    13e8:	mov    rsp,rbp
    13eb:	pop    rbp
    13ec:	ret
    13ed:	mov    QWORD PTR [rsp],r12
    13f1:	mov    rsi,QWORD PTR [rsp+0x88]
    13f9:	mov    QWORD PTR [rsp+0x8],rsi
    13fe:	mov    QWORD PTR [rsp+0x10],rax
    1403:	mov    r13,rax
    1406:	jmp    1099 <botlish_fn_14+0x6e>

000000000000140b <botlish_entry_14: scan_quoted<str, int, str>>:
    140b:	push   rbp
    140c:	mov    rbp,rsp
    140f:	ud2

0000000000001411 <botlish_fn_15: scan_field<str, int>>:
    1411:	push   rbp
    1412:	mov    rbp,rsp
    1415:	sub    rsp,0x50
    1419:	mov    QWORD PTR [rsp+0x30],rbx
    141e:	mov    QWORD PTR [rsp+0x38],r12
    1423:	mov    QWORD PTR [rsp+0x40],r13
    1428:	mov    r12,rdi
    142b:	mov    r13,rdx
    142e:	mov    QWORD PTR [rsp+0x10],0x0
    1437:	mov    QWORD PTR [rsp],rsi
    143b:	mov    rbx,rsi
    143e:	mov    QWORD PTR [rsp+0x8],rdx
    1443:	lea    rcx,[rsp+0x18]
    1448:	mov    rdx,r13
    144b:	mov    rsi,rbx
    144e:	mov    rdi,r12
    1451:	call   1456 <botlish_fn_15+0x45>
			1452: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    1456:	test   rax,rax
    1459:	mov    rsi,rax
    145c:	je     1527 <botlish_fn_15+0x116>
    1462:	mov    rdx,QWORD PTR [rsp+0x18]
    1467:	mov    rcx,QWORD PTR [rsp+0x20]
    146c:	mov    rdi,r12
    146f:	mov    rax,QWORD PTR [rdi+0x10]
    1473:	mov    r8,QWORD PTR [rax+0x28]
    1477:	call   147c <botlish_fn_15+0x6b>
			1478: R_X86_64_PLT32	rt_str_region_eq-0x4
    147c:	cmp    rax,0x6
    1480:	je     14b8 <botlish_fn_15+0xa7>
    1486:	mov    rcx,r13
    1489:	mov    rsi,rbx
    148c:	mov    rdi,r12
    148f:	mov    rdx,rcx
    1492:	call   1497 <botlish_fn_15+0x86>
			1493: R_X86_64_PLT32	botlish_fn_13-0x4 ; scan_unquoted<str, int, int>
    1497:	test   rax,rax
    149a:	je     1527 <botlish_fn_15+0x116>
    14a0:	mov    rbx,QWORD PTR [rsp+0x30]
    14a5:	mov    r12,QWORD PTR [rsp+0x38]
    14aa:	mov    r13,QWORD PTR [rsp+0x40]
    14af:	add    rsp,0x50
    14b3:	mov    rsp,rbp
    14b6:	pop    rbp
    14b7:	ret
    14b8:	mov    rcx,r13
    14bb:	mov    QWORD PTR [rsp+0x10],0x3
    14c4:	test   rcx,0x1
    14cb:	jne    14d9 <botlish_fn_15+0xc8>
    14d1:	mov    r13,rcx
    14d4:	jmp    14ee <botlish_fn_15+0xdd>
    14d9:	mov    rdx,rcx
    14dc:	add    rdx,0x2
    14e0:	mov    r13,rcx
    14e3:	seto   al
    14e6:	test   al,al
    14e8:	je     1501 <botlish_fn_15+0xf0>
    14ee:	mov    edx,0x3
    14f3:	mov    rsi,r13
    14f6:	mov    rdi,r12
    14f9:	call   14fe <botlish_fn_15+0xed>
			14fa: R_X86_64_PLT32	rt_int_add-0x4
    14fe:	mov    rdx,rax
    1501:	mov    QWORD PTR [rsp+0x8],rdx
    1506:	mov    rdi,r12
    1509:	mov    rax,QWORD PTR [rdi+0x10]
    150d:	mov    rcx,QWORD PTR [rax+0x10]
    1511:	mov    QWORD PTR [rsp+0x10],rcx
    1516:	mov    rsi,rbx
    1519:	call   151e <botlish_fn_15+0x10d>
			151a: R_X86_64_PLT32	botlish_fn_14-0x4 ; scan_quoted<str, int, str>
    151e:	test   rax,rax
    1521:	jne    1545 <botlish_fn_15+0x134>
    1527:	xor    rdx,rdx
    152a:	mov    rax,rdx
    152d:	mov    rbx,QWORD PTR [rsp+0x30]
    1532:	mov    r12,QWORD PTR [rsp+0x38]
    1537:	mov    r13,QWORD PTR [rsp+0x40]
    153c:	add    rsp,0x50
    1540:	mov    rsp,rbp
    1543:	pop    rbp
    1544:	ret
    1545:	mov    rbx,QWORD PTR [rsp+0x30]
    154a:	mov    r12,QWORD PTR [rsp+0x38]
    154f:	mov    r13,QWORD PTR [rsp+0x40]
    1554:	add    rsp,0x50
    1558:	mov    rsp,rbp
    155b:	pop    rbp
    155c:	ret

000000000000155d <botlish_entry_15: scan_field<str, int>>:
    155d:	push   rbp
    155e:	mov    rbp,rsp
    1561:	ud2

0000000000001563 <botlish_fn_16: scan_record_rest<str, int, mutarray, int>>:
    1563:	push   rbp
    1564:	mov    rbp,rsp
    1567:	sub    rsp,0x90
    156e:	mov    QWORD PTR [rsp+0x60],rbx
    1573:	mov    QWORD PTR [rsp+0x68],r12
    1578:	mov    QWORD PTR [rsp+0x70],r13
    157d:	mov    QWORD PTR [rsp+0x78],r14
    1582:	mov    QWORD PTR [rsp+0x80],r15
    158a:	mov    r15,rdi
    158d:	mov    QWORD PTR [rsp+0x20],0x0
    1596:	mov    QWORD PTR [rsp],rsi
    159a:	mov    QWORD PTR [rsp+0x8],rdx
    159f:	mov    QWORD PTR [rsp+0x10],rcx
    15a4:	mov    QWORD PTR [rsp+0x18],r8
    15a9:	lea    r12,[rsp+0x28]
    15ae:	mov    rbx,rsi
    15b1:	mov    QWORD PTR [rsp+0x38],rdx
    15b6:	mov    QWORD PTR [rsp+0x40],rcx
    15bb:	mov    QWORD PTR [rsp+0x48],r8
    15c0:	mov    rcx,r12
    15c3:	mov    rdx,QWORD PTR [rsp+0x38]
    15c8:	mov    rsi,rbx
    15cb:	mov    rdi,r15
    15ce:	call   15d3 <botlish_fn_16+0x70>
			15cf: R_X86_64_PLT32	botlish_fn_12-0x4 ; peek<str, int>
    15d3:	test   rax,rax
    15d6:	mov    QWORD PTR [rsp+0x50],rax
    15db:	je     179f <botlish_fn_16+0x23c>
    15e1:	mov    r14,QWORD PTR [rsp+0x28]
    15e6:	mov    r13,QWORD PTR [rsp+0x30]
    15eb:	mov    rdi,r15
    15ee:	mov    rcx,QWORD PTR [rdi+0x10]
    15f2:	mov    r8,QWORD PTR [rcx+0x18]
    15f6:	mov    rcx,r13
    15f9:	mov    rdx,r14
    15fc:	mov    rsi,QWORD PTR [rsp+0x50]
    1601:	call   1606 <botlish_fn_16+0xa3>
			1602: R_X86_64_PLT32	rt_str_region_eq-0x4
    1606:	cmp    rax,0x6
    160a:	je     1718 <botlish_fn_16+0x1b5>
    1610:	mov    rdi,r15
    1613:	mov    rax,QWORD PTR [rdi+0x10]
    1617:	mov    r8,QWORD PTR [rax+0x20]
    161b:	mov    rcx,r13
    161e:	mov    rdx,r14
    1621:	mov    rsi,QWORD PTR [rsp+0x50]
    1626:	call   162b <botlish_fn_16+0xc8>
			1627: R_X86_64_PLT32	rt_str_region_eq-0x4
    162b:	cmp    rax,0x6
    162f:	je     167d <botlish_fn_16+0x11a>
    1635:	mov    rdx,QWORD PTR [rsp+0x48]
    163a:	mov    rsi,QWORD PTR [rsp+0x40]
    163f:	mov    rdi,r15
    1642:	call   1647 <botlish_fn_16+0xe4>
			1643: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    1647:	test   rax,rax
    164a:	je     179f <botlish_fn_16+0x23c>
    1650:	mov    rdx,QWORD PTR [rsp+0x38]
    1655:	mov    rbx,QWORD PTR [rsp+0x60]
    165a:	mov    r12,QWORD PTR [rsp+0x68]
    165f:	mov    r13,QWORD PTR [rsp+0x70]
    1664:	mov    r14,QWORD PTR [rsp+0x78]
    1669:	mov    r15,QWORD PTR [rsp+0x80]
    1671:	add    rsp,0x90
    1678:	mov    rsp,rbp
    167b:	pop    rbp
    167c:	ret
    167d:	mov    rdx,QWORD PTR [rsp+0x48]
    1682:	mov    rsi,QWORD PTR [rsp+0x40]
    1687:	mov    rdi,r15
    168a:	call   168f <botlish_fn_16+0x12c>
			168b: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    168f:	test   rax,rax
    1692:	je     179f <botlish_fn_16+0x23c>
    1698:	mov    QWORD PTR [rsp],rax
    169c:	mov    rbx,rax
    169f:	mov    QWORD PTR [rsp+0x10],0x3
    16a8:	mov    rdx,QWORD PTR [rsp+0x38]
    16ad:	test   rdx,0x1
    16b4:	je     16d8 <botlish_fn_16+0x175>
    16ba:	mov    rdx,QWORD PTR [rsp+0x38]
    16bf:	add    rdx,0x2
    16c3:	seto   sil
    16c7:	test   sil,sil
    16ca:	jne    16d8 <botlish_fn_16+0x175>
    16d0:	mov    rax,rbx
    16d3:	jmp    16f0 <botlish_fn_16+0x18d>
    16d8:	mov    edx,0x3
    16dd:	mov    rsi,QWORD PTR [rsp+0x38]
    16e2:	mov    rdi,r15
    16e5:	call   16ea <botlish_fn_16+0x187>
			16e6: R_X86_64_PLT32	rt_int_add-0x4
    16ea:	mov    rdx,rax
    16ed:	mov    rax,rbx
    16f0:	mov    rbx,QWORD PTR [rsp+0x60]
    16f5:	mov    r12,QWORD PTR [rsp+0x68]
    16fa:	mov    r13,QWORD PTR [rsp+0x70]
    16ff:	mov    r14,QWORD PTR [rsp+0x78]
    1704:	mov    r15,QWORD PTR [rsp+0x80]
    170c:	add    rsp,0x90
    1713:	mov    rsp,rbp
    1716:	pop    rbp
    1717:	ret
    1718:	mov    rsi,QWORD PTR [rsp+0x38]
    171d:	mov    edx,0x3
    1722:	mov    r13,rdx
    1725:	mov    QWORD PTR [rsp+0x20],0x3
    172e:	test   rsi,0x1
    1735:	je     174d <botlish_fn_16+0x1ea>
    173b:	mov    rdx,rsi
    173e:	add    rdx,0x2
    1742:	seto   al
    1745:	test   al,al
    1747:	je     175b <botlish_fn_16+0x1f8>
    174d:	mov    rdx,r13
    1750:	mov    rdi,r15
    1753:	call   1758 <botlish_fn_16+0x1f5>
			1754: R_X86_64_PLT32	rt_int_add-0x4
    1758:	mov    rdx,rax
    175b:	mov    QWORD PTR [rsp+0x8],rdx
    1760:	mov    rsi,rbx
    1763:	mov    rdi,r15
    1766:	call   176b <botlish_fn_16+0x208>
			1767: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    176b:	test   rax,rax
    176e:	je     179f <botlish_fn_16+0x23c>
    1774:	mov    QWORD PTR [rsp+0x8],rax
    1779:	mov    rcx,rax
    177c:	mov    QWORD PTR [rsp+0x20],rdx
    1781:	mov    rsi,QWORD PTR [rsp+0x40]
    1786:	mov    r14,rdx
    1789:	mov    rdx,QWORD PTR [rsp+0x48]
    178e:	mov    rdi,r15
    1791:	call   1796 <botlish_fn_16+0x233>
			1792: R_X86_64_PLT32	botlish_fn_8-0x4 ; geo_append<mutarray, int, str>
    1796:	test   rax,rax
    1799:	jne    17cd <botlish_fn_16+0x26a>
    179f:	xor    rdx,rdx
    17a2:	mov    rax,rdx
    17a5:	mov    rbx,QWORD PTR [rsp+0x60]
    17aa:	mov    r12,QWORD PTR [rsp+0x68]
    17af:	mov    r13,QWORD PTR [rsp+0x70]
    17b4:	mov    r14,QWORD PTR [rsp+0x78]
    17b9:	mov    r15,QWORD PTR [rsp+0x80]
    17c1:	add    rsp,0x90
    17c8:	mov    rsp,rbp
    17cb:	pop    rbp
    17cc:	ret
    17cd:	mov    QWORD PTR [rsp+0x8],rax
    17d2:	mov    QWORD PTR [rsp+0x38],rax
    17d7:	mov    QWORD PTR [rsp+0x10],0x3
    17e0:	mov    rdx,QWORD PTR [rsp+0x48]
    17e5:	test   rdx,0x1
    17ec:	jne    17ff <botlish_fn_16+0x29c>
    17f2:	mov    rdx,r13
    17f5:	mov    rsi,QWORD PTR [rsp+0x48]
    17fa:	jmp    181e <botlish_fn_16+0x2bb>
    17ff:	mov    rdx,QWORD PTR [rsp+0x48]
    1804:	mov    rax,rdx
    1807:	add    rax,0x2
    180b:	seto   cl
    180e:	test   cl,cl
    1810:	je     1826 <botlish_fn_16+0x2c3>
    1816:	mov    rdx,r13
    1819:	mov    rsi,QWORD PTR [rsp+0x48]
    181e:	mov    rdi,r15
    1821:	call   1826 <botlish_fn_16+0x2c3>
			1822: R_X86_64_PLT32	rt_int_add-0x4
    1826:	mov    QWORD PTR [rsp],rbx
    182a:	mov    rdx,r14
    182d:	mov    QWORD PTR [rsp+0x8],rdx
    1832:	mov    rcx,QWORD PTR [rsp+0x38]
    1837:	mov    QWORD PTR [rsp+0x10],rcx
    183c:	mov    QWORD PTR [rsp+0x18],rax
    1841:	mov    QWORD PTR [rsp+0x38],rdx
    1846:	mov    QWORD PTR [rsp+0x40],rcx
    184b:	mov    QWORD PTR [rsp+0x48],rax
    1850:	jmp    15c0 <botlish_fn_16+0x5d>

0000000000001855 <botlish_entry_16: scan_record_rest<str, int, mutarray, int>>:
    1855:	push   rbp
    1856:	mov    rbp,rsp
    1859:	ud2

000000000000185b <botlish_fn_17: scan_record<str, int>>:
    185b:	push   rbp
    185c:	mov    rbp,rsp
    185f:	sub    rsp,0x40
    1863:	mov    QWORD PTR [rsp+0x20],rbx
    1868:	mov    QWORD PTR [rsp+0x28],r12
    186d:	mov    QWORD PTR [rsp+0x30],r14
    1872:	mov    r14,rdi
    1875:	mov    QWORD PTR [rsp+0x10],0x0
    187e:	mov    QWORD PTR [rsp+0x18],0x0
    1887:	mov    QWORD PTR [rsp],rsi
    188b:	mov    r12,rsi
    188e:	mov    QWORD PTR [rsp+0x8],rdx
    1893:	mov    rsi,r12
    1896:	mov    rdi,r14
    1899:	call   189e <botlish_fn_17+0x43>
			189a: R_X86_64_PLT32	botlish_fn_15-0x4 ; scan_field<str, int>
    189e:	test   rax,rax
    18a1:	je     18f6 <botlish_fn_17+0x9b>
    18a7:	mov    QWORD PTR [rsp+0x8],rax
    18ac:	mov    rsi,rax
    18af:	mov    QWORD PTR [rsp+0x10],rdx
    18b4:	mov    rbx,rdx
    18b7:	mov    rdi,r14
    18ba:	call   18bf <botlish_fn_17+0x64>
			18bb: R_X86_64_PLT32	botlish_fn_3-0x4 ; geo_new<str>
    18bf:	test   rax,rax
    18c2:	je     18f6 <botlish_fn_17+0x9b>
    18c8:	mov    QWORD PTR [rsp+0x8],rax
    18cd:	mov    rcx,rax
    18d0:	mov    r8d,0x3
    18d6:	mov    QWORD PTR [rsp+0x18],0x3
    18df:	mov    rdx,rbx
    18e2:	mov    rsi,r12
    18e5:	mov    rdi,r14
    18e8:	call   18ed <botlish_fn_17+0x92>
			18e9: R_X86_64_PLT32	botlish_fn_16-0x4 ; scan_record_rest<str, int, mutarray, int>
    18ed:	test   rax,rax
    18f0:	jne    1914 <botlish_fn_17+0xb9>
    18f6:	xor    rdx,rdx
    18f9:	mov    rax,rdx
    18fc:	mov    rbx,QWORD PTR [rsp+0x20]
    1901:	mov    r12,QWORD PTR [rsp+0x28]
    1906:	mov    r14,QWORD PTR [rsp+0x30]
    190b:	add    rsp,0x40
    190f:	mov    rsp,rbp
    1912:	pop    rbp
    1913:	ret
    1914:	mov    rbx,QWORD PTR [rsp+0x20]
    1919:	mov    r12,QWORD PTR [rsp+0x28]
    191e:	mov    r14,QWORD PTR [rsp+0x30]
    1923:	add    rsp,0x40
    1927:	mov    rsp,rbp
    192a:	pop    rbp
    192b:	ret

000000000000192c <botlish_entry_17: scan_record<str, int>>:
    192c:	push   rbp
    192d:	mov    rbp,rsp
    1930:	ud2
    1932:	add    BYTE PTR [rax],al
    1934:	add    BYTE PTR [rax],al
	...

0000000000001938 <botlish_fn_18: scan_records<str, int, mutarray, int>>:
    1938:	push   rbp
    1939:	mov    rbp,rsp
    193c:	sub    rsp,0x60
    1940:	mov    QWORD PTR [rsp+0x30],rbx
    1945:	mov    QWORD PTR [rsp+0x38],r12
    194a:	mov    QWORD PTR [rsp+0x40],r13
    194f:	mov    QWORD PTR [rsp+0x48],r14
    1954:	mov    QWORD PTR [rsp+0x50],r15
    1959:	mov    r13,rdi
    195c:	mov    QWORD PTR [rsp+0x20],0x0
    1965:	mov    QWORD PTR [rsp],rsi
    1969:	mov    QWORD PTR [rsp+0x8],rdx
    196e:	mov    r12,rdx
    1971:	mov    QWORD PTR [rsp+0x10],rcx
    1976:	mov    QWORD PTR [rsp+0x18],r8
    197b:	mov    rbx,rsi
    197e:	mov    r14,r8
    1981:	mov    r15,rcx
    1984:	mov    rsi,rbx
    1987:	mov    rdi,r13
    198a:	call   198f <botlish_fn_18+0x57>
			198b: R_X86_64_PLT32	rt_str_len-0x4
    198f:	mov    rcx,r12
    1992:	and    rcx,rax
    1995:	mov    rdx,rax
    1998:	test   rcx,0x1
    199f:	jne    19c5 <botlish_fn_18+0x8d>
    19a5:	mov    rsi,r12
    19a8:	mov    rdi,r13
    19ab:	call   19b0 <botlish_fn_18+0x78>
			19ac: R_X86_64_PLT32	rt_int_cmp-0x4
    19b0:	mov    ecx,0x2
    19b5:	test   rax,rax
    19b8:	cmovge rcx,QWORD PTR [rip+0x128]        # 1ae8 <botlish_fn_18+0x1b0>
    19c0:	jmp    19d5 <botlish_fn_18+0x9d>
    19c5:	mov    ecx,0x2
    19ca:	cmp    r12,rdx
    19cd:	cmovge rcx,QWORD PTR [rip+0x113]        # 1ae8 <botlish_fn_18+0x1b0>
    19d5:	cmp    rcx,0x6
    19d9:	je     1a84 <botlish_fn_18+0x14c>
    19df:	mov    rdx,r12
    19e2:	mov    rsi,rbx
    19e5:	mov    rdi,r13
    19e8:	call   19ed <botlish_fn_18+0xb5>
			19e9: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int>
    19ed:	test   rax,rax
    19f0:	je     1a9b <botlish_fn_18+0x163>
    19f6:	mov    QWORD PTR [rsp+0x8],rax
    19fb:	mov    rcx,rax
    19fe:	mov    QWORD PTR [rsp+0x20],rdx
    1a03:	mov    rsi,r15
    1a06:	mov    r12,rdx
    1a09:	mov    rdx,r14
    1a0c:	mov    rdi,r13
    1a0f:	call   1a14 <botlish_fn_18+0xdc>
			1a10: R_X86_64_PLT32	botlish_fn_9-0x4 ; geo_append<mutarray, int, List[str]>
    1a14:	test   rax,rax
    1a17:	je     1a9b <botlish_fn_18+0x163>
    1a1d:	mov    QWORD PTR [rsp+0x8],rax
    1a22:	mov    r15,rax
    1a25:	mov    QWORD PTR [rsp+0x10],0x3
    1a2e:	mov    rsi,r14
    1a31:	test   rsi,0x1
    1a38:	je     1a53 <botlish_fn_18+0x11b>
    1a3e:	mov    rsi,r14
    1a41:	mov    rax,rsi
    1a44:	add    rax,0x2
    1a48:	seto   cl
    1a4b:	test   cl,cl
    1a4d:	je     1a63 <botlish_fn_18+0x12b>
    1a53:	mov    edx,0x3
    1a58:	mov    rsi,r14
    1a5b:	mov    rdi,r13
    1a5e:	call   1a63 <botlish_fn_18+0x12b>
			1a5f: R_X86_64_PLT32	rt_int_add-0x4
    1a63:	mov    QWORD PTR [rsp],rbx
    1a67:	mov    rdx,r12
    1a6a:	mov    QWORD PTR [rsp+0x8],rdx
    1a6f:	mov    rcx,r15
    1a72:	mov    QWORD PTR [rsp+0x10],rcx
    1a77:	mov    QWORD PTR [rsp+0x18],rax
    1a7c:	mov    r14,rax
    1a7f:	jmp    1984 <botlish_fn_18+0x4c>
    1a84:	mov    rdx,r14
    1a87:	mov    rsi,r15
    1a8a:	mov    rdi,r13
    1a8d:	call   1a92 <botlish_fn_18+0x15a>
			1a8e: R_X86_64_PLT32	botlish_fn_10-0x4 ; geo_finish<mutarray, int>
    1a92:	test   rax,rax
    1a95:	jne    1ac0 <botlish_fn_18+0x188>
    1a9b:	xor    rax,rax
    1a9e:	mov    rbx,QWORD PTR [rsp+0x30]
    1aa3:	mov    r12,QWORD PTR [rsp+0x38]
    1aa8:	mov    r13,QWORD PTR [rsp+0x40]
    1aad:	mov    r14,QWORD PTR [rsp+0x48]
    1ab2:	mov    r15,QWORD PTR [rsp+0x50]
    1ab7:	add    rsp,0x60
    1abb:	mov    rsp,rbp
    1abe:	pop    rbp
    1abf:	ret
    1ac0:	mov    rbx,QWORD PTR [rsp+0x30]
    1ac5:	mov    r12,QWORD PTR [rsp+0x38]
    1aca:	mov    r13,QWORD PTR [rsp+0x40]
    1acf:	mov    r14,QWORD PTR [rsp+0x48]
    1ad4:	mov    r15,QWORD PTR [rsp+0x50]
    1ad9:	add    rsp,0x60
    1add:	mov    rsp,rbp
    1ae0:	pop    rbp
    1ae1:	ret
    1ae2:	add    BYTE PTR [rax],al
    1ae4:	add    BYTE PTR [rax],al
    1ae6:	add    BYTE PTR [rax],al
    1ae8:	(bad)
    1ae9:	add    BYTE PTR [rax],al
    1aeb:	add    BYTE PTR [rax],al
    1aed:	add    BYTE PTR [rax],al
	...

0000000000001af0 <botlish_entry_18: scan_records<str, int, mutarray, int>>:
    1af0:	push   rbp
    1af1:	mov    rbp,rsp
    1af4:	mov    rsi,QWORD PTR [rdx]
    1af7:	mov    r9,QWORD PTR [rdx+0x8]
    1afb:	mov    rcx,QWORD PTR [rdx+0x10]
    1aff:	mov    r8,QWORD PTR [rdx+0x18]
    1b03:	mov    rdx,r9
    1b06:	call   1b0b <botlish_entry_18+0x1b>
			1b07: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, mutarray, int>
    1b0b:	mov    rsp,rbp
    1b0e:	pop    rbp
    1b0f:	ret

0000000000001b10 <botlish_fn_19: csv_parse<str>>:
    1b10:	push   rbp
    1b11:	mov    rbp,rsp
    1b14:	sub    rsp,0x40
    1b18:	mov    QWORD PTR [rsp+0x20],rbx
    1b1d:	mov    QWORD PTR [rsp+0x28],r12
    1b22:	mov    QWORD PTR [rsp+0x30],r13
    1b27:	mov    rbx,rdi
    1b2a:	mov    QWORD PTR [rsp+0x8],0x0
    1b33:	mov    QWORD PTR [rsp+0x10],0x0
    1b3c:	mov    QWORD PTR [rsp+0x18],0x0
    1b45:	mov    QWORD PTR [rsp],rsi
    1b49:	mov    r12,rsi
    1b4c:	mov    rsi,r12
    1b4f:	mov    rdi,rbx
    1b52:	call   1b57 <botlish_fn_19+0x47>
			1b53: R_X86_64_PLT32	rt_str_len-0x4
    1b57:	sar    rax,1
    1b5a:	test   rax,rax
    1b5d:	je     1bec <botlish_fn_19+0xdc>
    1b63:	mov    edx,0x1
    1b68:	mov    QWORD PTR [rsp+0x8],0x1
    1b71:	mov    rsi,r12
    1b74:	mov    rdi,rbx
    1b77:	call   1b7c <botlish_fn_19+0x6c>
			1b78: R_X86_64_PLT32	botlish_fn_17-0x4 ; scan_record<str, int>
    1b7c:	test   rax,rax
    1b7f:	je     1c03 <botlish_fn_19+0xf3>
    1b85:	mov    QWORD PTR [rsp+0x8],rax
    1b8a:	mov    rsi,rax
    1b8d:	mov    QWORD PTR [rsp+0x10],rdx
    1b92:	mov    r13,rdx
    1b95:	mov    rdi,rbx
    1b98:	call   1b9d <botlish_fn_19+0x8d>
			1b99: R_X86_64_PLT32	botlish_fn_4-0x4 ; geo_new<List[str]>
    1b9d:	test   rax,rax
    1ba0:	je     1c03 <botlish_fn_19+0xf3>
    1ba6:	mov    QWORD PTR [rsp+0x8],rax
    1bab:	mov    rcx,rax
    1bae:	mov    r8d,0x3
    1bb4:	mov    QWORD PTR [rsp+0x18],0x3
    1bbd:	mov    rdx,r13
    1bc0:	mov    rsi,r12
    1bc3:	mov    rdi,rbx
    1bc6:	call   1bcb <botlish_fn_19+0xbb>
			1bc7: R_X86_64_PLT32	botlish_fn_18-0x4 ; scan_records<str, int, mutarray, int>
    1bcb:	test   rax,rax
    1bce:	je     1c03 <botlish_fn_19+0xf3>
    1bd4:	mov    rbx,QWORD PTR [rsp+0x20]
    1bd9:	mov    r12,QWORD PTR [rsp+0x28]
    1bde:	mov    r13,QWORD PTR [rsp+0x30]
    1be3:	add    rsp,0x40
    1be7:	mov    rsp,rbp
    1bea:	pop    rbp
    1beb:	ret
    1bec:	xor    rdx,rdx
    1bef:	mov    rdi,rbx
    1bf2:	mov    rsi,rdx
    1bf5:	call   1bfa <botlish_fn_19+0xea>
			1bf6: R_X86_64_PLT32	rt_list_new-0x4
    1bfa:	test   rax,rax
    1bfd:	jne    1c1e <botlish_fn_19+0x10e>
    1c03:	xor    rax,rax
    1c06:	mov    rbx,QWORD PTR [rsp+0x20]
    1c0b:	mov    r12,QWORD PTR [rsp+0x28]
    1c10:	mov    r13,QWORD PTR [rsp+0x30]
    1c15:	add    rsp,0x40
    1c19:	mov    rsp,rbp
    1c1c:	pop    rbp
    1c1d:	ret
    1c1e:	mov    rbx,QWORD PTR [rsp+0x20]
    1c23:	mov    r12,QWORD PTR [rsp+0x28]
    1c28:	mov    r13,QWORD PTR [rsp+0x30]
    1c2d:	add    rsp,0x40
    1c31:	mov    rsp,rbp
    1c34:	pop    rbp
    1c35:	ret

0000000000001c36 <botlish_entry_19: csv_parse<str>>:
    1c36:	push   rbp
    1c37:	mov    rbp,rsp
    1c3a:	mov    rsi,QWORD PTR [rdx]
    1c3d:	call   1c42 <botlish_entry_19+0xc>
			1c3e: R_X86_64_PLT32	botlish_fn_19-0x4 ; csv_parse<str>
    1c42:	mov    rsp,rbp
    1c45:	pop    rbp
    1c46:	ret
